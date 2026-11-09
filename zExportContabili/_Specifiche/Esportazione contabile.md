---
area: Esportazione contabile
progetto: zExportContabili
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Esportazione contabile

Questa specifica descrive il motore che scrive la prima nota (e, in prospettiva, le anagrafiche) nel tracciato di importazione del gestionale contabile del cliente. Il codice è in `zExportContabili\`: `EsportazioneContabile.Types` (movimenti, righe, anagrafiche, interfacce), `EsportazioneContabile.Base` (formattazione dei campi), `EsportazioneContabile.Registry` (registro degli esportatori) e un esportatore per gestionale: `EsportazioneContabile.AdHoc` (Zucchetti Ad Hoc), `EsportazioneContabile.Mexal` e `EsportazioneContabile.Mexal.Analitica` (Passepartout Mexal), `EsportazioneContabile.Gestionale1` (Zucchetti Gestionale 1). Lo script `sql\01 - Domini e tabelle ESPORTAZIONI_CONTABILI.sql` crea le tabelle di WT. Nessuna di queste unit è in un pacchetto `.dpk`. L'unico utilizzatore compilato è Gesty, con `dmCOGE_Gateway_Contabile` (tabelle `COGE_INTERSCAMBIO_*`), che usa `Types`, `Base`, `Registry` e `Mexal.Analitica`; le unit `AdHoc`, `Mexal` e `Gestionale1` non compaiono in nessun `uses` di WT, Gesty o zTicser (DIV-CON-1). `WT.EsportazioneContabile.Bridge` è uno scheletro di ponte per WT che nessun progetto compila (DIV-CON-7). La fattura elettronica XML, nella stessa cartella, ha una specifica a parte (`Fattura elettronica XML.md`, ZEXP-FEX).

**Come funziona.** Il ponte applicativo legge la configurazione del tenant, ricava il codice del gestionale attivo (`ADHOC`, `MEXAL`, `GESTIONALE1`), chiede al registro l'esportatore passandogli se stesso come `IzCorrispondenzeContabili`, riempie una lista di `TzMovimentoContabile` e chiama `EsportaPrimaNota` con la cartella di uscita. L'esportatore traduce ogni codice interno (conto, causale, codice IVA) nel codice del gestionale attraverso il ponte e scrive i file; il ponte registra i file prodotti nel suo registro delle esportazioni. Cambiare gestionale è solo un dato di configurazione.

**Test che coprono quest'area.** Nessuna.

## ZEXP-CON-001 Contratto dell'esportatore
Ogni esportatore implementa `IzEsportatoreContabile`: `Gestionale` (il codice), `Descrizione`, `EsportaPrimaNota(Movimenti, CartellaDestinazione)` ed `EsportaAnagrafiche(Anagrafiche, CartellaDestinazione)`. Le due esportazioni restituiscono l'elenco dei file prodotti (`TzFileEsportato`: percorso completo e ruolo `TESTATE`, `RIGHE`, `INTRA`, `ANALITICA` o `UNICO`). L'esportatore non apre transazioni e non scrive nel database.

### Scenario: esportazione Mexal
- **Dato** l'esportatore `MEXAL` e una lista di movimenti
- **Quando** si chiama `EsportaPrimaNota`
- **Allora** il risultato ha due elementi con ruolo `TESTATE` e `RIGHE`

## ZEXP-CON-002 Registro degli esportatori
Ogni unit di gestionale si registra nella propria `initialization` con `TzEsportatoriContabili.Registra(Codice, Classe)`; il codice viene salvato in maiuscolo. `Crea(Gestionale, Corrispondenze)` cerca il codice senza distinzione di maiuscole e, se non lo trova, solleva `EzEsportazioneContabile` con `Nessun esportatore registrato per il gestionale "<codice>": il tracciato non e' ancora supportato`. `GestionaliDisponibili` restituisce i codici registrati. Un esportatore è disponibile solo se la sua unit compare in un `uses` del programma. `TzEsportatoreAnaliticaMexal` non si registra: il ponte lo crea direttamente.

### Scenario: gestionale non implementato
- **Dato** un gestionale `ONDA` inserito in tabella senza esportatore
- **Quando** il ponte chiama `TzEsportatoriContabili.Crea('ONDA', Ponte)`
- **Allora** si ottiene `EzEsportazioneContabile` con il messaggio che il tracciato non è ancora supportato

## ZEXP-CON-003 Corrispondenze obbligatorie
Un esportatore non si crea senza tabella delle corrispondenze: con `nil` il costruttore solleva `Esportatore creato senza tabella di corrispondenze`. Il ponte deve implementare `CodiceEsterno(Tipo, CodiceInterno)` sollevando `EzEsportazioneContabile` quando la corrispondenza manca, perché un codice non tradotto non deve mai finire nel file; per un codice interno vuoto restituisce la stringa vuota senza cercarlo (codice IVA e pagamento possono mancare). I tipi sono `crConto`, `crCausale`, `crCodiceIva`, `crPagamento`, `crRegistroIva`, scritti nelle tabelle come `CONTO`, `CAUSALE`, `CODICE_IVA`, `PAGAMENTO`, `REGISTRO_IVA`. `Parametro(Chiave, ValorePredefinito)` restituisce il valore del parametro del gestionale attivo o il predefinito.

### Scenario: conto non mappato
- **Dato** un movimento con un conto senza corrispondenza
- **Quando** l'esportatore traduce il conto
- **Allora** l'esportazione si ferma con `Corrispondenza mancante: CONTO "<codice>" ...`

## ZEXP-CON-004 Campi a lunghezza fissa
Per i tracciati a lunghezza fissa (Ad Hoc):
- **testo**: allineato a sinistra, completato con spazi a destra, troncato se più lungo del campo;
- **importo**: allineato a destra con spazi, virgola decimale, senza separatore delle migliaia, segno `-` davanti alla prima cifra, numero fisso di decimali; il valore zero diventa un campo **tutto spazi**; un importo che non entra nel campo solleva `Importo <testo> troppo lungo per un campo di <n> caratteri`;
- **data**: `AAAAMMGG`; la data zero diventa otto spazi.

### Scenario: importo negativo
- **Dato** un importo di -1234,5 in un campo di 18 caratteri con 2 decimali
- **Quando** si formatta il campo
- **Allora** il risultato è `-1234,50` preceduto da 10 spazi

### Scenario: importo zero
- **Dato** un importo zero in un campo di 18 caratteri
- **Quando** si formatta il campo
- **Allora** il risultato è di 18 spazi

## ZEXP-CON-005 Campi delimitati
Per i tracciati delimitati (Mexal) i campi si uniscono con il separatore senza virgolette. Se un valore contiene il separatore l'esportazione si ferma con `Il valore "<valore>" contiene il separatore "<separatore>"`, invece di produrre un file che il gestionale leggerebbe sfalsato. Gli importi hanno la virgola decimale, nessun separatore delle migliaia e il numero di decimali chiesto; lo zero si scrive `0,00`.

### Scenario: descrizione con punto e virgola
- **Dato** il separatore `;` e una descrizione di riga `Canone; acconto`
- **Quando** si esporta la prima nota Mexal
- **Allora** l'esportazione si ferma con l'errore sul separatore

## ZEXP-CON-006 Scrittura dei file
I file si scrivono nella codifica ANSI della macchina, con righe chiuse da CR+LF. Un file con lo stesso nome nella cartella di destinazione viene sovrascritto.

### Scenario: seconda esportazione nella stessa cartella
- **Dato** un file `WTPN.txt` già presente nella cartella di uscita
- **Quando** si esporta di nuovo verso Ad Hoc con lo stesso prefisso
- **Allora** il file viene riscritto da capo

## ZEXP-CON-007 Tracciato Ad Hoc
L'esportatore `ADHOC` produce un solo file `<PREFISSO_NOME_FILE>.txt` (predefinito `WTPN`) con ruolo `UNICO`. Per ogni movimento scrive un record di testata che comincia con `PT` e poi un record per riga che comincia con `PR`; dal terzo al decimo carattere tutti portano lo stesso progressivo del movimento a 8 cifre con zeri a sinistra (1 per il primo movimento della lista), che è la chiave con cui Ad Hoc lega righe e testata. Larghezze attuali, dichiarate provvisorie nel codice (DIV-CON-2):

| Record | Campi, in ordine |
|---|---|
| Testata `PT` | esercizio (`CODICE_ESERCIZIO`, 4), data registrazione (8), causale tradotta (5), numero documento (15), data documento (8), cliente o fornitore tradotto come conto (15), totale documento (18, 2 decimali), descrizione (40) |
| Riga `PR` | tipo conto `C` cliente, `F` fornitore, `G` altro (1), conto tradotto (15), dare (18, 2 decimali), avere (18, 2 decimali), descrizione riga (40) |

Le righe si scrivono come arrivano: l'eventuale accorpamento di righe con lo stesso conto (Ad Hoc salda in una sola riga lo stesso conto ripetuto su righe consecutive) è compito del ponte. Codice IVA e imponibile non vengono esportati. `EsportaAnagrafiche` solleva `Esportazione anagrafiche verso Ad Hoc non ancora implementata`.

### Scenario: due movimenti
- **Dato** due movimenti, il primo con tre righe
- **Quando** si esporta verso Ad Hoc
- **Allora** il file contiene `PT00000001`, tre righe `PR00000001`, poi `PT00000002` con le sue righe

## ZEXP-CON-008 Tracciato Mexal
L'esportatore `MEXAL` usa il separatore del parametro `SEPARATORE`: `1` = `;` (predefinito, anche per valori non numerici o sconosciuti), `2` = `:`, `3` = `,`. Produce `<PREFISSO_NOME_FILE>_TESTATE.csv` e `<PREFISSO_NOME_FILE>_RIGHE.csv` (prefisso predefinito `WTPN`); i file dei dati Intra e dell'analitica non li produce. Le righe stanno nello stesso ordine delle testate (opzione «file righe allineato» di Mexal). Colonne attuali, in ordine provvisorio (DIV-CON-2):

| File | Colonne |
|---|---|
| Testate | data registrazione `AAAAMMGG`, causale tradotta, numero documento, data documento, cliente o fornitore tradotto come conto, totale (2 decimali), descrizione |
| Righe | data registrazione, numero documento, conto tradotto, dare, avere, codice IVA tradotto, descrizione riga |

`EsportaAnagrafiche` solleva `Esportazione anagrafiche verso Mexal non ancora implementata`.

### Scenario: separatore virgola
- **Dato** il parametro `SEPARATORE = 3`
- **Quando** si esporta la prima nota Mexal
- **Allora** i campi sono separati da `,` e gli importi, che hanno la virgola decimale, fanno fermare l'esportazione con l'errore sul separatore

## ZEXP-CON-009 Righe di contabilità analitica Mexal
`TzEsportatoreAnaliticaMexal` scrive `<PREFISSO_NOME_FILE>_ANALITICA.csv` (prefisso predefinito `GEPN`) con il separatore di ZEXP-CON-008, una riga per ogni riga contabile che ha `CodiceCommessa` o `CodiceCentroDiCosto`: data registrazione, numero documento, conto tradotto, commessa, centro di costo, dare, avere, descrizione. Commessa e centro di costo si scrivono come arrivano, senza traduzione. Se nessuna riga ha un'imputazione analitica il file viene cancellato e il risultato è vuoto, perché Mexal rifiuta un file vuoto. Il ponte di Gesty lo chiama dopo l'esportatore Mexal quando il gestionale è `MEXAL` e il parametro `ESPORTA_ANALITICA` vale `S` (predefinito). `EsportaAnagrafiche` solleva `Le anagrafiche non passano dal file di contabilita analitica`.

### Scenario: nessuna imputazione
- **Dato** movimenti le cui righe non hanno commessa né centro di costo
- **Quando** si chiama `EsportaPrimaNota` dell'analitica
- **Allora** non resta alcun file `_ANALITICA.csv` e il risultato è vuoto

## ZEXP-CON-010 Gestionale 1 disattivato
L'esportatore `GESTIONALE1` esiste solo per dare un errore chiaro: sia la prima nota sia le anagrafiche sollevano `Tracciato LEMCO/LEMSE non ancora disponibile: richiedere le specifiche del formato all'assistenza Zucchetti`.

### Scenario: cliente con Gestionale 1
- **Dato** un tenant configurato con `GESTIONALE1` e la unit inclusa nel programma
- **Quando** si esporta la prima nota
- **Allora** si ottiene l'errore che chiede il tracciato a Zucchetti e nessun file

## ZEXP-CON-011 Ponte di WT (scheletro)
`TdmEsportazioneContabileBridge` contiene solo le query come costanti: `CaricaConfigurazione` solleva sempre `Esportazione contabile non configurata per l'azienda di lavoro (tabella ESPORTAZIONI_CONTABILI_CONFIGURAZIONE)`, quindi `EsportatoreCorrente` fallisce sempre; `CodiceEsterno` solleva sempre l'errore di corrispondenza mancante per un codice non vuoto; `Parametro` restituisce sempre il predefinito.

### Scenario: uso dello scheletro
- **Dato** il ponte di WT così com'è
- **Quando** si chiama `EsportatoreCorrente`
- **Allora** si ottiene l'errore di configurazione mancante

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-CON-1 🟡 (dedotta) | In Gesty nessuna unit degli esportatori (`EsportazioneContabile.Mexal`, `.AdHoc`, `.Gestionale1`) compare in un `uses`: le loro `initialization` non girano e il registro resta vuoto | `dmCOGE_Gateway_Contabile.EsportaPrimaNota` fallisce sempre con «Nessun esportatore registrato», qualunque sia il gestionale configurato; l'analitica, creata direttamente, non viene mai raggiunta |
| DIV-CON-2 🟡 | I tracciati Ad Hoc e Mexal sono dichiarati provvisori («DA COMPLETARE»): posizioni, larghezze e ordine delle colonne non sono allineati ai tracciati ufficiali; Ad Hoc non esporta codice IVA e imponibile; le anagrafiche non sono implementate per nessun gestionale | Un file prodotto oggi non è garantito importabile: il motore non va usato in produzione finché i tracciati non sono ricopiati dai manuali |
| DIV-CON-3 🟡 (dedotta) | Se l'esportazione si ferma a metà (corrispondenza mancante, separatore in un valore, importo troppo lungo), il file già scritto in parte resta nella cartella di uscita; per Mexal le testate possono essere complete e le righe troncate | Il database resta coerente (Gesty registra i file solo dopo il successo), ma nella cartella condivisa con lo studio resta un file parziale che qualcuno può importare |
| DIV-CON-4 🟢 | Nelle testate Mexal la data di registrazione si scrive con `FormatDateTime` (data zero = `18991230`), la data documento con `CampoDataFissa` (data zero = otto spazi dentro un campo delimitato) | Due regole diverse per lo stesso tipo di dato nello stesso file; una data documento mancante produce un campo di spazi |
| DIV-CON-5 🟢 | L'analitica usa il prefisso predefinito `GEPN`, testate e righe Mexal `WTPN`; commessa e centro di costo non passano dalle corrispondenze, mentre il commento di `TzRigaContabile` dice «tradotto via corrispondenze» | Senza `PREFISSO_NOME_FILE` i quattro file della stessa esportazione hanno prefissi diversi; un codice progetto interno finisce nel file senza traduzione |
| DIV-CON-6 🟡 (dedotta) | Con `SEPARATORE = 3` (virgola) gli importi, scritti sempre con la virgola decimale, contengono il separatore: `RigaCsv` ferma l'esportazione al primo importo | Una delle tre scelte di separatore che Mexal prevede, e che l'esportatore dichiara, non funziona mai |
| DIV-CON-7 🟢 | `WT.EsportazioneContabile.Bridge` sta nella libreria riusabile con un nome applicativo, dichiara `{$R *.dfm}` senza un `.dfm` accanto e non è compilato da nessuno; il commento di `EsportazioneContabile.Types` lo indica come «il» ponte | Chi cerca il ponte trova uno scheletro che non compila e che solleva sempre errore; il ponte vero è in Gesty |
