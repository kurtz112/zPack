---
area: Patch JSON del dizionario
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/003
---

# Patch JSON del dizionario

Questa specifica descrive le patch JSON del dizionario LZ nel formato `zCollection.Patch`: un documento che elenca correzioni puntuali agli elementi delle collezioni già caricate in memoria, invece di sostituire l'intero archivio `.lz` (AGENTS.md sezione 4, punto 11: le consegne sul dizionario sono di norma patch). Il motore è `zBase\zCollection.Patcher.pas` (`TzCollectionPatch`, `TzPatchOperation`, `EzCollectionPatchError`, `TzCollectionResolver`); non conosce `TzSystem` e riceve le collezioni da una funzione risolutrice. Lo usano: WT e Gesty dal menù **Sistema → Applica patch dizionario LZ** attraverso `zSystem.Patcher.pas` e il risolutore `LzCollectionResolver` di `zSystem.Collections.pas`; il server `zlz` per `lz_verify_patch` e per il comando `zMCP_LZ.exe --applica-patch`, che zBuilder lancia dal comando «Applica script e patch» dei rilasci. Il formato è documentato in `D:\AI\OUT\20260923-patch-json-dizionario-lz\Analisi - 20260923 - Patch JSON Del Dizionario LZ.md` e in `Patch JSON LZ.md` della stessa cartella; le differenze fra quel documento e il codice sono fra le divergenze.

**Come funziona.** `TzCollectionPatch.Create` legge e controlla la struttura del documento. `Verify` esegue davvero ogni operazione sul dizionario in memoria e poi annulla sempre tutto: così un'operazione può dipendere da quella che la precede e gli errori di tipo li trova lo stesso lettore JSON dell'archivio (`TzCollectionJson.MergeIntoItem`, `Collezione LZ.md`, ZBASE-COL-013). `Apply` riesegue le operazioni e conferma solo se nessuna è in conflitto o in errore, altrimenti annulla tutto e solleva un'eccezione. Il salvataggio dell'archivio non è compito del motore: lo fa chi lo chiama, per le sole collezioni toccate.

**Test che coprono quest'area.** Nessuna prova automatica in `D:\AI\SRC\zPack\_UnitTest\_src`. L'analisi del 2026-09-23 propone un collaudo manuale in 12 passi (prima applicazione, seconda applicazione «già presente», conflitto su `atteso`, chiave sbagliata, tutto o niente, applicazione sbagliata, aggiungi seguito da modifica); `lz_verify_patch` di `zlz` esegue `Verify` su una copia dell'archivio ed è oggi la verifica usata prima di ogni consegna.

## ZBASE-PAT-001 Struttura del documento
Il documento è un oggetto JSON, in UTF-8 con o senza BOM (il BOM iniziale viene tolto). Le chiavi si riconoscono senza distinguere maiuscole e minuscole; i valori testuali vengono ripuliti dagli spazi e un numero o un booleano vale come testo. Sono obbligatorie, in quest'ordine di controllo:
- `formato` uguale a `zCollection.Patch` (senza distinzione di maiuscole), altrimenti «Formato "<valore>" non riconosciuto: atteso "zCollection.Patch".»;
- `versione` uguale a `1` (numero o testo), altrimenti «Versione "<valore>" non gestita: atteso 1.»;
- `applicazione` non vuota, altrimenti «Manca "applicazione": ...»;
- `id` non vuoto, altrimenti «Manca "id": ...»;
- `operazioni`, un array con almeno un elemento, altrimenti «"operazioni" deve essere un elenco con almeno un'operazione.»; ogni elemento deve essere un oggetto («Operazione <n>: deve essere un oggetto JSON.»).

`ticket`, `data`, `autore` e `descrizione` sono facoltativi e finiscono nel resoconto. Un testo vuoto solleva «Il testo della patch è vuoto.», un JSON non valido «Il testo non è un JSON valido: <dettaglio>», una radice che non è un oggetto «La patch deve essere un oggetto JSON.». Tutti questi errori sono `EzCollectionPatchError` sollevate dal costruttore, prima di toccare il dizionario. Le chiavi del documento non elencate qui sono ignorate (DIV-PAT-6).

### Scenario: versione sbagliata
- **Dato** un documento con `"versione": 2`
- **Quando** si crea `TzCollectionPatch`
- **Allora** viene sollevata `EzCollectionPatchError` «Versione "2" non gestita: atteso 1.»

### Scenario: versione come testo
- **Dato** un documento con `"versione": "1"` e `"ticket": 162`
- **Quando** si crea `TzCollectionPatch`
- **Allora** la patch è valida e `Ticket` vale `162`

## ZBASE-PAT-002 Chiavi e forma di ogni operazione
Un'operazione ammette solo le chiavi `op`, `collection`, `item`, `percorso`, `atteso`, `imposta`, `valore`, `dopo`, `nota` (senza distinzione di maiuscole); qualunque altra solleva «Operazione <n>: chiave "<chiave>" sconosciuta.». `op` vale `modifica`, `aggiungi` o `elimina`; `collection` è obbligatoria; `atteso`, `imposta` e `valore`, se presenti, devono essere oggetti JSON; `dopo` vale solo per `aggiungi`. Per tipo:

| `op` | Obbligatorie | Vietate | Regole |
|---|---|---|---|
| `modifica` | `item`, `imposta` con almeno una chiave | `valore`, `Name` dentro `imposta` | «"Name" non si modifica, le chiavi LZ sono i nomi e i riferimenti resterebbero orfani.» |
| `aggiungi` | `valore` con `Name` non vuoto | `atteso`, `imposta` | senza `percorso` niente `item`; con `percorso` serve `item` |
| `elimina` | `item` | `imposta`, `valore` | `atteso` facoltativo |

La rinomina non è ammessa in nessuna forma: per rinominare servono `elimina` e `aggiungi` su tutte le collezioni coinvolte.

### Scenario: rinomina
- **Dato** un'operazione `modifica` con `"imposta": {"Name": "Nuovo"}`
- **Quando** si crea la patch
- **Allora** viene sollevata `EzCollectionPatchError` «Operazione 1: "Name" non si modifica, ...»

### Scenario: aggiungi al primo livello con item
- **Dato** un'operazione `aggiungi` con `item` e senza `percorso`
- **Quando** si crea la patch
- **Allora** viene sollevata «Operazione 1: per aggiungere al primo livello non si indica "item"; per una collection annidata serve anche "percorso".»

## ZBASE-PAT-003 Collezione, elemento e percorso
`collection` è il nome di classe della collezione (`TzDataSets`, `TzDataModules`, `TzDbViews`, ...): la trova il risolutore passato dal chiamante, e se la risposta è `nil` l'operazione va in `ERRORE` «Collection "<nome>" sconosciuta.». In WT e Gesty il risolutore ammette, senza distinzione di maiuscole, le 21 collezioni che `TzSystem.LoadZip` carica (elenco esplicito di `LzCollections`), mai le connessioni né `MetaData`. `item` è il `Name` di un elemento di primo livello; la ricerca non distingue maiuscole e minuscole, come `IndexOf`. `percorso` scende nelle collezioni annidate: segmenti separati da `/`, ognuno `Proprieta[NomeItem]`; per `aggiungi` l'ultimo segmento è la sola proprietà collezione che riceve l'elemento nuovo, senza parentesi. Segmenti malformati (parentesi non chiusa, nome vuoto, proprietà mancante, proprietà che non esiste o non è una collezione, ultimo segmento di `aggiungi` con parentesi o segmento intermedio senza) mandano l'operazione in `ERRORE`; un elemento che non si trova lungo il percorso manda `modifica` e `aggiungi` in `CONFLITTO` «item "<nome>" non trovato in <proprietà>».

### Scenario: dettaglio annidato
- **Dato** `"collection": "TzDataModules", "item": "AbitareEmergenza", "percorso": "DataSets[Abitare_Emergenza_Pronto_Intervento_Elenco]/DetailDatasets[Abitare_Emergenza_Pronto_Intervento_Coperture]"`
- **Quando** si esegue una `modifica`
- **Allora** la modifica tocca solo il dataset di dettaglio indicato

### Scenario: proprietà del percorso inesistente
- **Dato** un percorso `DataSetz[Elenco]`
- **Quando** si esegue l'operazione
- **Allora** l'esito è `ERRORE` «La classe <classe> non ha la proprietà "DataSetz".»

## ZBASE-PAT-004 Confronto per contenimento
`atteso`, `imposta` e `valore` si confrontano con la fotografia completa dell'elemento (`ItemToJson` con i valori predefiniti, ZBASE-COL-013) per **contenimento**: in un oggetto contano solo le chiavi dell'atteso (nome della chiave senza distinzione di maiuscole); due array devono avere la stessa lunghezza e contenersi elemento per elemento; i testi si confrontano esattamente, maiuscole comprese; i numeri con tolleranza 1E-9; i valori vuoti `""`, `0`, `false`, `null`, `[]` e `{}` sono equivalenti fra loro, perché il serializzatore omette i valori predefiniti. Prima del confronto ogni chiave di `atteso` e `imposta` (anche dentro gli oggetti annidati) deve esistere nella fotografia, altrimenti l'operazione va in `ERRORE` «"<atteso|imposta>": proprietà sconosciute per la classe <classe>: <chiavi>.»: senza questo controllo una chiave scritta male con valore vuoto risulterebbe «già presente». Le proprietà `stored False` non sono nella fotografia e quindi non si possono né attendere né modificare.

### Scenario: chiave scritta male
- **Dato** una `modifica` con `"imposta": {"Generatr": ""}`
- **Quando** si esegue `Verify`
- **Allora** l'esito è `ERRORE` «"imposta": proprietà sconosciute per la classe TzDataSet: Generatr.»

### Scenario: vuoto equivalente
- **Dato** un elemento con `Generator` vuoto e `"atteso": {"Generator": null}`
- **Quando** si esegue l'operazione
- **Allora** l'atteso è rispettato

## ZBASE-PAT-005 Operazione `modifica`
Nell'ordine: si trova l'elemento (assente → `CONFLITTO`); si controllano le chiavi (ZBASE-PAT-004); se l'elemento contiene già i valori di `imposta` l'esito è `GIÀ PRESENTE` e non si controlla `atteso`; se `atteso` c'è e non è rispettato l'esito è `CONFLITTO` con l'elenco delle differenze nella forma `<chiave>: atteso <valore>, trovato <valore>` separate da `; ` (le chiavi annidate col prefisso `Menu.`); altrimenti si registrano i valori precedenti delle **sole** proprietà nominate e si applica `imposta` con `MergeIntoItem` in modalità rigorosa (ogni problema di lettura è un errore). `imposta` fonde: cambia solo le proprietà nominate e fonde gli oggetti annidati, ma sostituisce per intero gli elenchi di stringhe e le collezioni annidate nominati; per toccare un solo elemento di una collezione annidata si usa `percorso`.

### Scenario: atteso non rispettato
- **Dato** un dataset con `Generator = 'GEN_A'` e una `modifica` con `"atteso": {"Generator": "GEN_B"}, "imposta": {"Generator": ""}`
- **Quando** si esegue `Verify`
- **Allora** l'esito è `CONFLITTO` «Generator: atteso "GEN_B", trovato "GEN_A"» e il dataset non cambia

### Scenario: seconda applicazione
- **Dato** una patch già applicata
- **Quando** la si verifica di nuovo
- **Allora** ogni `modifica` risulta `GIÀ PRESENTE`

## ZBASE-PAT-006 Operazione `aggiungi`
Si raggiunge la collezione che riceve (quella di primo livello, o quella indicata dall'ultimo segmento di `percorso`). Se esiste già un elemento con il `Name` di `valore`: con gli stessi valori (contenimento) l'esito è `GIÀ PRESENTE`, altrimenti `CONFLITTO` «esiste già un item "<nome>" con valori diversi: <differenze>». Se `dopo` nomina un elemento che non c'è l'esito è `CONFLITTO` «item "<nome>" indicato in "dopo" non trovato». Altrimenti si aggiunge un elemento, lo si registra per l'annullamento e gli si applica `valore` in modalità rigorosa, con `Name` per primo (i setter possono dipendere dal nome). Con `dopo` l'elemento va subito dopo quello indicato, ma solo se la collezione non è ordinata: nelle collezioni ordinate `dopo` è ignorato (DIV-PAT-4). Un dataset nuovo richiede le voci coerenti in `TzDataSets`, `TzDbViews`, `TzDbCards` e `TzDataModules`, nella stessa patch: il motore non lo controlla.

### Scenario: aggiunta e modifica nella stessa patch
- **Dato** una patch che aggiunge una vista in `TzDataModules` con `percorso` e poi la modifica
- **Quando** si esegue `Verify`
- **Allora** entrambe le operazioni sono `DA APPLICARE`, perché la seconda vede l'elemento aggiunto dalla prima

### Scenario: elemento già presente con altri valori
- **Dato** un elemento `X` con `Caption = 'A'` e un `aggiungi` con `"valore": {"Name": "X", "Caption": "B"}`
- **Quando** si esegue `Verify`
- **Allora** l'esito è `CONFLITTO` «esiste già un item "X" con valori diversi: Caption: atteso "B", trovato "A"»

## ZBASE-PAT-007 Operazione `elimina`
Se l'elemento non si trova l'esito è `GIÀ PRESENTE` con il messaggio «<motivo>: già assente» (la patch resta ripetibile). Se `atteso` c'è si controllano le chiavi e il contenimento come per `modifica` (conflitto con le differenze). Altrimenti l'elemento viene solo **staccato** dalla collezione (`Collection := nil`), ricordandone collezione e posizione: si libera alla conferma, e l'annullamento rimette la stessa istanza dov'era.

### Scenario: elemento già assente
- **Dato** una `elimina` di `Modulo.Vecchio` che non esiste in `TzDbViews`
- **Quando** si esegue `Verify`
- **Allora** l'esito è `GIÀ PRESENTE` «item "Modulo.Vecchio" non trovato in TzDbViews: già assente»

## ZBASE-PAT-008 Tutto o niente e annullamento
Ogni esecuzione tiene un registro con una voce per cambiamento: valori precedenti (`modifica`), elemento creato (`aggiungi`), collezione e posizione (`elimina`). Se un'operazione solleva un'eccezione a metà, si annulla subito quello che aveva fatto e l'operazione va in `ERRORE` col messaggio dell'eccezione; le altre proseguono, così il resoconto le elenca tutte. Alla fine `Verify` annulla sempre tutto, in ordine inverso; `Apply` annulla tutto se c'è almeno un `CONFLITTO` o un `ERRORE` e solleva `EzCollectionPatchError` «Patch non applicata: nessuna modifica è rimasta nel dizionario.» seguito dal riepilogo dei problemi (al massimo 10); altrimenti conferma, libera gli elementi staccati e porta gli esiti `DA APPLICARE` ad `APPLICATA`. Se l'annullamento stesso fallisce viene sollevata «Annullamento incompleto: il dizionario in memoria non è affidabile. Non salvare e ricaricare le impostazioni.» con i messaggi degli errori. L'annullamento di una `modifica` riassegna solo le proprietà nominate: un setter che cambia anche altre proprietà (per esempio `TzDataSet.SetIdentityField` con `PrimaryKeyFields` e `AutoIncFields`) di norma si ricompone, ma non è garantito.

### Scenario: seconda operazione sbagliata
- **Dato** una patch con una prima `modifica` corretta e una seconda con una proprietà sconosciuta
- **Quando** si chiama `Apply`
- **Allora** viene sollevata `EzCollectionPatchError` e anche la prima modifica è annullata
- **E** corretta la seconda, una nuova `Verify` dà la prima ancora `DA APPLICARE`

## ZBASE-PAT-009 Esiti e resoconto
Ogni operazione ha un esito fra `DA APPLICARE`, `APPLICATA`, `GIÀ PRESENTE`, `CONFLITTO`, `ERRORE` e un messaggio. `HasProblems` è vero se c'è almeno un conflitto o un errore; `HasChanges` se c'è almeno un'operazione da applicare o applicata; `TouchedCollections` elenca, senza ripetizioni, le collezioni di primo livello delle operazioni da applicare o applicate, che sono le sole da salvare. `OutcomeText` è la riga «<n> da applicare, <n> applicate, <n> già presenti, <n> conflitti, <n> errori». `ProblemsSummary(Max)` elenca le sole operazioni in conflitto o in errore, al massimo `Max`, poi «... e altre <n>: vedere il resoconto completo.». `Report` comincia con «Patch <id> - ticket <n>», la descrizione e la riga applicazione/data/autore (`-` se mancano); con problemi segue «ESITO: NON APPLICABILE (<conteggi>)», il blocco «Da correggere:» e «Tutte le operazioni:», altrimenti «Esito: <conteggi>.»; ogni operazione è una riga «<n>. [<esito>] <tipo> <collection> > <item> > <percorso> > <Name aggiunto>», con l'elenco delle proprietà per le modifiche da applicare e il messaggio, se c'è.

### Scenario: undici operazioni sbagliate
- **Dato** una patch con 11 operazioni in conflitto
- **Quando** si chiama `ProblemsSummary(8)`
- **Allora** il testo elenca 8 operazioni e finisce con «... e altre 3: vedere il resoconto completo.»

## ZBASE-PAT-010 Aggancio all'applicazione
Fuori dal motore, chi applica una patch a un archivio vero deve: rifiutarla se `applicazione` non coincide con il nome del programma, senza distinzione di maiuscole (`Gesty` per Gesty, `WINTARIF` per WT, `zSystem.AppName`); eseguire `Verify` e mostrare l'esito prima di qualunque modifica; dire «La patch <id> è già applicata: niente da fare.» se `HasChanges` è falso e non riscrivere l'archivio; dopo `Apply` salvare solo le collezioni di `TouchedCollections`, con copia di sicurezza e la riga «Patch <id> (ticket <n>): <descrizione>» nel registro `Log.txt` dell'archivio. In WT e Gesty lo fa `zSystem.Patcher` (solo amministratore, ricontrollato anche in `ApplyPatchText`); `zlz` lo fa su una copia dell'archivio e rifiuta di applicare se l'eseguibile del programma è aperto sullo stesso computer. Le finestre già aperte del programma non vedono la modifica finché non si chiudono e riaprono.

### Scenario: patch di un'altra applicazione
- **Dato** una patch con `"applicazione": "WinTarif"` aperta in Gesty
- **Quando** l'amministratore la applica
- **Allora** viene rifiutata con «La patch <id> è scritta per "WinTarif", questo programma è "Gesty".» prima della verifica

## Divergenze note
Si decidono nella voce R-201 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-PAT-1 🟡 (dedotta) | `elimina` dà `GIÀ PRESENTE` anche quando a mancare è l'elemento di primo livello o un elemento intermedio del `percorso`, non solo l'elemento da eliminare | Una patch scritta per un dizionario diverso (modulo rinominato, master assente) passa come «già applicata» invece di andare in conflitto, e nessuno se ne accorge |
| DIV-PAT-2 🟡 (dedotta) | Eliminare l'ultimo elemento di una collezione di primo livello porta l'esito ad `APPLICATA`, ma `TZipper.SaveCollection` non salva le collezioni vuote (`Collezione LZ.md`, DIV-COL-1) | Il programma dice «applicata e salvata», ma l'elemento eliminato ricompare al caricamento successivo dell'archivio |
| DIV-PAT-3 🟢 (dedotta) | Il documento del formato dice che le collezioni ammesse sono «le 17 che `TzSystem.LoadZip` carica»; `LoadZip` e `LzCollections` ne hanno 21 (anche `TzDbSchedulers`, `TzFiles`, `TzMaps`, `TzTatukMaps`) | Chi scrive una patch seguendo il documento può credere di non poter toccare collezioni che il motore accetta |
| DIV-PAT-4 🟢 (dedotta) | `dopo` è accettato al primo livello ma ignorato senza avviso nelle collezioni ordinate; l'elemento aggiunto resta in testa fino al riordino successivo (`Collezione LZ.md`, DIV-COL-4) | La posizione chiesta nella patch non viene rispettata e il resoconto non lo dice |
| DIV-PAT-5 🟢 (dedotta) | Per `modifica` le proprietà `stored False` sono rifiutate (non sono nella fotografia), ma per un elemento nuovo di `aggiungi` il `valore` le accetta, perché `MergeIntoItem` legge tutte le proprietà published scrivibili | Il documento dice che non si possono impostare; in `aggiungi` passano e il loro valore si perde al salvataggio, senza errore |
| DIV-PAT-6 🟢 (dedotta) | Le chiavi sconosciute di un'operazione sono rifiutate, quelle del documento no | Un `"descrizone"` scritto male passa in silenzio e la riga di `Log.txt` resta senza descrizione |
| DIV-PAT-7 🟢 (dedotta) | Il documento elenca `atteso` non rispettato fra i conflitti senza dire che per `modifica` vince «già presente»: se l'elemento ha già i valori di `imposta` l'`atteso` non viene nemmeno guardato | Una patch con un `atteso` sbagliato risulta «già presente» invece di segnalare che il dizionario è diverso da quello analizzato; il comportamento è voluto (patch ripetibile) ma non è scritto |
