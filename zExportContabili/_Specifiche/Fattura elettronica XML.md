---
area: Fattura elettronica XML
progetto: zExportContabili
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Fattura elettronica XML

Questa specifica descrive `TFEXmlExport` (unit `zExportContabili\uFE_XMLExport.pas`), che compone il file XML di una fattura elettronica italiana (formato FPA12 o FPR12, versione 1.2) leggendo le tabelle `FE_*` del database con query dirette. **La unit oggi non è compilata da nessun progetto**: non compare nei `uses` di WT, Gesty, zTicser o zServer né in un pacchetto `.dpk`, e il modulo gemello di importazione `uFE_XMLImport` citato nel commento non esiste in `SRC`. La specifica fotografa il comportamento del codice per chi lo riprenderà; i riferimenti allo schema dell'Agenzia delle Entrate nelle divergenze vengono dalla conoscenza del tracciato, non da un controllo con il file XSD.

**Come funziona.** Il chiamante crea l'esportatore con la connessione e la transazione di lettura (`TFEXmlExport.Create(Config.Database, Config.ReadTransaction)`) e chiede `EsportaXml(IdFattura)` o `EsportaSuFile(IdFattura, NomeFile)`. Ogni sezione del tracciato apre la sua query unidirezionale sulla tabella corrispondente (`FE_TRASMISSIONE`, `FE_CEDENTE`, `FE_CESSIONARIO`, `FE_INTERMEDIARIO`, `FE_FATTURA_BODY`, `FE_DATI_GENERALI`, `FE_DOCUMENTO_CORRELATO`, `FE_DATI_VEICOLI`, `FE_SCONTO_MAGGIORAZIONE`, `FE_BENE_SERVIZIO`, `FE_RIEPILOGO_IVA`, `FE_DATI_PAGAMENTO`, `FE_DETTAGLIO_PAGAMENTO`, `FE_ALLEGATO`) e aggiunge i nodi al documento.

**Test che coprono quest'area.** Nessuna.

## ZEXP-FEX-001 Documento e intestazione
Il documento è XML 1.0 in UTF-8, indentato, con radice `p:FatturaElettronica` e i prefissi `p` (`http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2`), `ds` e `xsi`. L'attributo `versione` è `FE_TRASMISSIONE.FORMATO` se valorizzato, altrimenti `FE_FATTURA.VERSIONE`. Una fattura inesistente solleva `EFEExportError` con `Fattura <id> non trovata`; una fattura senza righe in `FE_FATTURA_BODY` solleva `La fattura <id> non ha alcun corpo`. I corpi (`FatturaElettronicaBody`) si scrivono in ordine di `PROGRESSIVO`, uno per riga.

### Scenario: fattura senza corpo
- **Dato** una riga in `FE_FATTURA` senza righe in `FE_FATTURA_BODY`
- **Quando** si chiama `EsportaXml`
- **Allora** si ottiene `EFEExportError` con `La fattura <id> non ha alcun corpo`

## ZEXP-FEX-002 Nessun elemento vuoto
Il tracciato rifiuta gli elementi vuoti, quindi un valore nullo o fatto di soli spazi non produce il nodo. I testi si scrivono senza spazi ai bordi. Le date si scrivono `aaaa-mm-gg`. Gli importi usano sempre il punto decimale, a prescindere dalla lingua della macchina, con 2 decimali, salvo `Quantita`, `PrezzoUnitario`, `PrezzoTotale`, `RiferimentoNumero` e `Arrotondamento` del riepilogo IVA, che ne hanno 5. Un campo vero/falso (`Art73`) produce `SI` solo quando è vero e nessun nodo quando è falso; `BolloVirtuale` vale `SI` quando `BOLLO_VIRTUALE` è vero.

### Scenario: prezzo unitario
- **Dato** una linea con `PREZZO_UNITARIO` 12,5 su una macchina con la virgola decimale
- **Quando** si esporta la fattura
- **Allora** compare `<PrezzoUnitario>12.50000</PrezzoUnitario>`

### Scenario: causale nulla
- **Dato** un documento con `CAUSALE` nulla
- **Quando** si esporta la fattura
- **Allora** il nodo `Causale` non c'è

## ZEXP-FEX-003 Sezioni obbligatorie
Le sezioni senza le quali la fattura non ha senso fermano l'esportazione con `EFEExportError`:

| Manca | Messaggio |
|---|---|
| riga in `FE_TRASMISSIONE` | `DatiTrasmissione mancanti` |
| riga in `FE_CEDENTE` | `CedentePrestatore mancante` |
| riga in `FE_CESSIONARIO` | `CessionarioCommittente mancante` |
| riga in `FE_DATI_GENERALI` del corpo | `DatiGeneraliDocumento mancanti` |
| righe in `FE_BENE_SERVIZIO` del corpo | `DettaglioLinee mancante: la fattura non ha righe` |
| righe in `FE_RIEPILOGO_IVA` del corpo | `DatiRiepilogo mancante` |

### Scenario: fattura senza riepilogo IVA
- **Dato** un corpo con le linee ma senza righe in `FE_RIEPILOGO_IVA`
- **Quando** si esporta la fattura
- **Allora** si ottiene `DatiRiepilogo mancante` e nessun documento

## ZEXP-FEX-004 Dati di trasmissione
`DatiTrasmissione` contiene `IdTrasmittente` (`ID_PAESE`, `ID_CODICE`), `ProgressivoInvio`, `FormatoTrasmissione`, `CodiceDestinatario`, i `ContattiTrasmittente` solo se c'è almeno uno fra telefono ed e-mail, e `PECDestinatario`.

### Scenario: senza contatti
- **Dato** `FE_TRASMISSIONE` con `TELEFONO` ed `EMAIL` nulli
- **Quando** si esporta la fattura
- **Allora** `ContattiTrasmittente` non compare

## ZEXP-FEX-005 Anagrafiche e sedi
Per cedente, cessionario, rappresentante fiscale e terzo intermediario `DatiAnagrafici` contiene: `IdFiscaleIVA` (sempre per il cedente, per gli altri solo se la partita IVA è valorizzata), `CodiceFiscale`, `Anagrafica` con `Denominazione` se valorizzata, altrimenti `Nome` e `Cognome`, poi `Titolo` e `CodEORI`; albo professionale e `RegimeFiscale` solo dove la tabella ha quelle colonne (il cedente). Le colonne del rappresentante fiscale del cessionario hanno il prefisso `RF_`. `Sede` (prefisso `SEDE_`) e `StabileOrganizzazione` (prefisso `SO_`) compaiono solo se l'indirizzo è valorizzato. Del cedente si scrivono anche `IscrizioneREA` (solo se `REA_NUMERO` è valorizzato), `Contatti` (se c'è almeno uno fra telefono, fax ed e-mail) e `RiferimentoAmministrazione`.

### Scenario: cessionario persona fisica
- **Dato** un cessionario con `DENOMINAZIONE` nulla, `NOME` e `COGNOME` valorizzati e partita IVA nulla
- **Quando** si esporta la fattura
- **Allora** `CessionarioCommittente` ha `CodiceFiscale` e `Anagrafica` con `Nome` e `Cognome`, senza `IdFiscaleIVA`

## ZEXP-FEX-006 Rappresentante fiscale e terzo intermediario
Se `FE_CESSIONARIO` ha `RF_DENOMINAZIONE` o `RF_COGNOME` valorizzati, il codice scrive un nodo `RappresentanteFiscale` nell'intestazione, subito prima di `CessionarioCommittente`. Per ogni riga di `FE_INTERMEDIARIO` con `TIPO = 'TI'` scrive `TerzoIntermediarioOSoggettoEmittente` e, dopo, `SoggettoEmittente` dalla colonna `SOGGETTO_EMITTENTE`. Le sezioni dell'intestazione si scrivono in quest'ordine: trasmissione, cedente, intermediari, rappresentante fiscale, cessionario (DIV-FEX-1, DIV-FEX-2).

### Scenario: fattura con terzo intermediario
- **Dato** una riga di `FE_INTERMEDIARIO` con `TIPO = 'TI'`
- **Quando** si esporta la fattura
- **Allora** `TerzoIntermediarioOSoggettoEmittente` compare dopo `CedentePrestatore` e prima di `CessionarioCommittente`

## ZEXP-FEX-007 Dati generali e documenti correlati
`DatiGeneraliDocumento` porta tipo, divisa, data, numero; `DatiRitenuta` solo se `RIT_IMPORTO` è valorizzato; `DatiBollo` solo se `BOLLO_VIRTUALE` è vero; gli sconti e le maggiorazioni del documento; totale, arrotondamento, causale e `Art73`. I documenti correlati si leggono in ordine di `TIPO` e poi di identificativo, e ogni codice diventa un nodo:

| `TIPO` | Nodo |
|---|---|
| `ORD` | `DatiOrdineAcquisto` |
| `CON` | `DatiContratto` |
| `CVZ` | `DatiConvenzione` |
| `RIC` | `DatiRicezione` |
| `FAC` | `DatiFattureCollegate` |
| `SAL` | `DatiSAL` (solo `RiferimentoFase`) |
| `FPR` | `FatturaPrincipale` (`NumeroFatturaPrincipale`, `DataFatturaPrincipale`) |

Un codice diverso viene ignorato. Una riga di `FE_DATI_VEICOLI` produce `DatiVeicoli` dentro `DatiGenerali` (DIV-FEX-3).

### Scenario: codice correlato sconosciuto
- **Dato** una riga di `FE_DOCUMENTO_CORRELATO` con `TIPO = 'DDT'`
- **Quando** si esporta la fattura
- **Allora** la riga non produce alcun nodo e nessun errore

## ZEXP-FEX-008 Linee, riepilogo, pagamenti, allegati
Le linee si scrivono in ordine di `NUMERO_LINEA`, con `CodiceArticolo` solo se `CODICE_VALORE` è valorizzato, gli sconti della linea e `AltriDatiGestionali` solo se `TIPO_DATO_AGGIUNTIVO` è valorizzato. Il riepilogo IVA segue le linee, in ordine di aliquota. Ogni riga di `FE_DATI_PAGAMENTO` produce un `DatiPagamento` con i suoi `DettaglioPagamento` in ordine di scadenza. Ogni allegato produce un nodo `Allegati`; il contenuto di `ATTACHMENT` è già in base 64 e si scrive così com'è.

### Scenario: due rate
- **Dato** un pagamento con due dettagli, scadenze 30/06 e 31/05
- **Quando** si esporta la fattura
- **Allora** il dettaglio del 31/05 precede quello del 30/06

## ZEXP-FEX-009 File e nome del file
`EsportaSuFile` scrive il documento in UTF-8 **senza** distinta di byte iniziale, perché alcuni intermediari la rifiutano. `ComponiNomeFile(IdFattura)` restituisce `ID_PAESE` + `ID_CODICE` + `_` + `PROGRESSIVO_INVIO` + `.xml` presi da `FE_TRASMISSIONE`; senza riga solleva `Dati di trasmissione mancanti per la fattura <id>`.

### Scenario: nome del file
- **Dato** `ID_PAESE = 'IT'`, `ID_CODICE = '01234567890'`, `PROGRESSIVO_INVIO = '00001'`
- **Quando** si chiama `ComponiNomeFile`
- **Allora** il risultato è `IT01234567890_00001.xml`

## ZEXP-FEX-010 Dati non esportati
Non vengono scritti: `DatiCassaPrevidenziale` (la tabella ha il solo `FE_DATI_GENERALI.IMPORTO_CASSA`, segnato nel codice con `MANCA_IN_LIBRERIA`), `DataRiferimentoTerminiPagamento` (nessuna colonna), `DatiDDT` e `DatiTrasporto` (nessun codice).

### Scenario: fattura con cassa previdenziale
- **Dato** una fattura con `IMPORTO_CASSA` valorizzato
- **Quando** si esporta la fattura
- **Allora** il documento non contiene `DatiCassaPrevidenziale`

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita e senza confronto automatico con l'XSD. Pesano poco finché la unit non è compilata da nessuno.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-FEX-1 🟡 (dedotta) | Nello schema l'intestazione è in sequenza fissa: trasmissione, cedente, rappresentante fiscale, cessionario, terzo intermediario, soggetto emittente. Il codice scrive gli intermediari prima del cessionario | Una fattura con terzo intermediario non supera la validazione e viene scartata dal Sistema di Interscambio |
| DIV-FEX-2 🟡 (dedotta) | Il rappresentante fiscale del cessionario (colonne `RF_`) viene scritto come `RappresentanteFiscale` dell'intestazione, che nello schema è quello del cedente, e con la struttura `DatiAnagrafici`; quello del cessionario va dentro `CessionarioCommittente`, con `IdFiscaleIVA`, `Denominazione` o `Nome` e `Cognome` (il commento «precede il cessionario» lo conferma) | Il file dichiara un rappresentante fiscale del fornitore che non esiste e non è valido rispetto allo schema |
| DIV-FEX-3 🟡 (dedotta) | `DatiVeicoli` è scritto dentro `DatiGenerali`; nello schema sta nel corpo, fra `DatiBeniServizi` e `DatiPagamento` | Una fattura con dati dei veicoli viene scartata |
| DIV-FEX-4 🟡 (dedotta) | I documenti correlati sono ordinati per codice `TIPO` in ordine alfabetico (`CON`, `CVZ`, `FAC`, `FPR`, `ORD`, `RIC`, `SAL`), mentre lo schema chiede ordine acquisto, contratto, convenzione, ricezione, fatture collegate, SAL e, per ultima, fattura principale | Una fattura con ordine d'acquisto e contratto insieme (caso frequente verso la pubblica amministrazione, con CIG e CUP) non supera la validazione |
| DIV-FEX-5 🟢 (dedotta) | `SoggettoEmittente` viene scritto una volta per ogni riga `TI` e mai se non ce ne sono | Con due righe `TI` il nodo si ripete (lo schema ne ammette uno); senza terzo intermediario non si può indicare che la fattura è emessa dal cessionario |
| DIV-FEX-6 🟢 | Il commento di `ComponiNomeFile` dice «progressivo in base 36», ma il codice concatena `PROGRESSIVO_INVIO` così com'è, senza controllare lunghezza né caratteri | Il nome del file è corretto solo se il progressivo è già stato calcolato bene altrove |
| DIV-FEX-7 🟢 | La unit sta in libreria senza utilizzatori e cita un modulo gemello `uFE_XMLImport` che non esiste | Codice non compilato che si degrada senza che nessuno se ne accorga, e un rimando che porta a vuoto |
