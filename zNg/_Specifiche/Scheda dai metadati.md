---
area: Scheda dai metadati
progetto: zNg
aggiornato: 2026-11-05
rilascio: OUT/20261104-base-web-fieldtype/002
---

# Scheda dai metadati

Questa specifica descrive la scheda di un record costruita dai metadati di BaseWeb (il componente `zz-form`), usata da sola dentro una pagina o in finestra dalla griglia (`zz-data-grid`), in Agorà e GestyWeb. Descrive il comportamento atteso, non il codice. Il codice oggi sta in `core/components/zz-form/` (`zz-form.component.ts` e `.html`, `dependency-engine.ts`, `design-menu.builder.ts`, `form-focus-tracker.ts`), `core/services/form-items-builder.service.ts`, `core/services/metadata.service.ts`, `core/services/metadata-patch.service.ts`, `core/services/zserver.service.ts`, `core/services/user-capabilities.service.ts` e `core/models/metadata.models.ts`.

Il lato server è in zServer, `_src/_Specifiche/Contratto - Dataset dinamici.md` (requisiti `ZSRV-DSD-*`): metadati da `GET data/{dataset}/metadata` (procedura `BASE_WEB.LOAD_DATASET_METADATA`), dati da `GET`, `POST` e `PUT data/{dataset}`. Le caselle collegate a un altro dataset seguono `Ricerca dai metadati.md` (requisiti `ZNG-RIC-*`). Gli indirizzi qui sotto sono relativi all'indirizzo di zServer (`UrlService.baseUrl`).

## ZNG-SCH-001 Disposizione dall'albero dei metadati
La scheda dispone i campi seguendo l'albero `formSettings.items` dei metadati (gruppi, schede a linguette, spazi vuoti, pulsanti, campi), nell'ordine in cui arriva. Ciò che non si può mostrare sparisce senza lasciare buchi: un gruppo o una linguetta senza campi visibili non compare, perché un riquadro vuoto fa pensare a dati mancanti.

### Scenario: nodi nascosti
- **Dato** un albero con un gruppo `visible: false`, una linguetta `visible: false` e un campo con `control.visible: false`
- **Quando** la scheda si costruisce
- **Allora** nessuno dei tre compare
- **E** un gruppo che resta senza campi visibili non compare nemmeno lui

### Scenario: campo dell'albero che i metadati non conoscono
- **Dato** un nodo dell'albero con un `dataField` che non sta in `fields`
- **Quando** la scheda si costruisce
- **Allora** il nodo viene saltato e la scheda si apre lo stesso, con un avviso solo nella console

### Scenario: campi fuori dall'albero
- **Dato** un campo visibile, che non è la chiave primaria e che l'albero non colloca
- **Quando** la scheda si costruisce
- **Allora** il campo compare in fondo, in un gruppo "Altro", ordinato per `control.sortOrder` insieme agli altri campi nella stessa condizione
- **E** la chiave primaria non finisce mai in "Altro": compare solo se l'albero la colloca

## ZNG-SCH-002 Colonne e dimensioni
La scheda ha `formSettings.colCount` colonne. Un gruppo senza `colSpan` occupa tutta la larghezza, e nessun elemento può occupare più colonne di quelle del contenitore: senza questo i gruppi si affiancavano in modo casuale e la finestra si allargava oltre lo schermo.

### Scenario: gruppo senza larghezza
- **Dato** una scheda a 3 colonne e un gruppo senza `colSpan`
- **Quando** la scheda si costruisce
- **Allora** il gruppo occupa le 3 colonne

### Scenario: larghezza eccessiva
- **Dato** un campo con `colSpan` 4 in un gruppo a 2 colonne
- **Quando** la scheda si costruisce
- **Allora** il campo occupa 2 colonne

### Scenario: dimensioni della finestra
- **Dato** una scheda in finestra senza larghezza imposta né dalla pagina né da `formSettings.width`
- **Quando** si apre
- **Allora** è larga 400 pixel per colonna più 100, ma mai più del 90% della finestra del browser, e alta quanto il contenuto, al massimo il 90% dell'altezza
- **E** si ridimensiona a mano salvo `formSettings.resizable: false`
- **E** compare con una dissolvenza breve e già alla dimensione finale, così un clic immediato su un pulsante non cade a vuoto

## ZNG-SCH-003 Casella secondo il tipo di campo
La casella di ogni campo nasce da `control.editorType` e dal tipo del dato, con le opzioni di `control.editorOptions` sopra quelle predefinite. L'etichetta è `control.label`, altrimenti `caption`.

### Scenario: date e ore
- **Dato** un campo `dxDateBox`
- **Quando** la scheda si costruisce
- **Allora** un `dataType` `datetime` si mostra `dd/MM/yyyy HH:mm`, un `time` `HH:mm` con la scelta da elenco, ogni altro `dd/MM/yyyy`

### Scenario: numeri con decimali
- **Dato** un campo `dxNumberBox` con `column.fieldDecimals` 2
- **Quando** la scheda si costruisce
- **Allora** il valore si mostra con il separatore delle migliaia e due decimali

### Scenario: valori a scelta chiusa
- **Dato** un campo con `picklist`
- **Quando** la scheda si costruisce
- **Allora** la casella propone le voci della lista, salva `value` e mostra `text`

### Scenario: campo collegato a un altro dataset
- **Dato** un campo con `lookup`
- **Quando** la scheda si costruisce
- **Allora** la casella è una `dxSelectBox`, salvo un altro `editorType`, e cerca sul server come descritto in `ZNG-RIC-*`
- **E** quando l'utente sceglie una riga, i `mappings` portano nella scheda le altre colonne della riga; un valore che il collegamento non trova non cancella niente, si svuotano i campi solo quando l'utente svuota la casella

### Scenario: casella con l'etichetta sopra
- **Dato** una scheda con `labelLocation` `top` e un campo booleano che non è `dxSwitch`
- **Quando** la scheda si costruisce
- **Allora** il testo dell'etichetta sta accanto alla casella, che si allinea ai campi della stessa riga invece di restare sola sotto un'etichetta

## ZNG-SCH-004 Campi obbligatori
Un campo è obbligatorio quando i metadati lo dicono (`control.required` o una regola `required` in `control.validation`), **tranne i booleani**: la regola di obbligatorietà di DevExtreme rifiuta `false`, quindi una casella tolta impedirebbe il salvataggio. Le altre regole di `control.validation` (lunghezza, intervallo, formato) valgono come arrivano.

### Scenario: casella obbligatoria nei metadati
- **Dato** un campo booleano (`dataType: boolean`, `dxCheckBox` o `dxSwitch`) segnato obbligatorio, con la regola `required` che zServer aggiunge in `validation`
- **Quando** l'utente salva con la casella tolta
- **Allora** il salvataggio procede

## ZNG-SCH-005 Sola lettura
La scheda è tutta di sola lettura se la pagina lo chiede (`readOnly`) o se è aperta in consultazione (`mode = 'view'`); un campo singolo lo è se ha `control.readOnly`. La chiave primaria non si cambia in modifica, perché zServer la esclude dall'aggiornamento e la usa per trovare la riga: la sua casella è di sola lettura in modifica e modificabile in inserimento, salvo `readOnly` dei metadati. Una scheda modificabile ha uno stile diverso (`zz-form--modificabile`), così si vede a colpo d'occhio quali caselle non si possono cambiare.

### Scenario: consultazione
- **Dato** una scheda aperta con `mode = 'view'`
- **Quando** compare
- **Allora** nessuna casella è modificabile, il pulsante Salva non c'è e il pulsante di chiusura dice "Chiudi" invece di "Annulla"

### Scenario: chiave in modifica e in inserimento
- **Dato** una scheda con chiave primaria `ID`
- **Quando** si apre in modifica
- **Allora** la casella di `ID` è di sola lettura
- **E** riaperta in inserimento la stessa scheda torna modificabile, perché la regola si riapplica a ogni apertura

## ZNG-SCH-006 Regole di dipendenza fra campi
Le regole `control.dependsOn` di un campo lo mostrano, lo nascondono, lo rendono modificabile o no, obbligatorio o no, o gli danno un valore, secondo il valore di un altro campo (`sourceField`). Gli operatori sono `==`, `!=`, `>`, `<`, `>=`, `<=`, `contains`, `notEmpty`, `empty`. Le regole valgono sia quando l'utente cambia il campo di origine sia all'apertura, con i valori del record caricato: altrimenti un record salvato con un campo nascosto si riaprirebbe con quel campo in vista.

### Scenario: campo mostrato da un altro
- **Dato** il campo `DATA_FINE` con la regola `{ sourceField: 'CHIUSO', action: 'show', condition: { operator: '==', value: true } }`
- **Quando** l'utente spunta `CHIUSO`
- **Allora** `DATA_FINE` compare, e scompare di nuovo se la spunta si toglie

### Scenario: record caricato
- **Dato** un record con `CHIUSO = true`
- **Quando** la scheda si apre in modifica
- **Allora** `DATA_FINE` è già visibile, senza che l'utente tocchi niente

### Scenario: valore imposto
- **Dato** una regola `setValue` con `targetValue`
- **Quando** la condizione diventa vera
- **Allora** il campo di destinazione prende `targetValue`; quando torna falsa il valore resta

## ZNG-SCH-007 Campi da svuotare
Quando cambia un campo che ha `fields2Clear` (i campi che dipendono dal suo valore, per esempio una provincia e il comune), i campi elencati si svuotano, così la scheda non salva una combinazione che non sta in piedi.

### Scenario: cambio del campo di origine
- **Dato** il campo `PROVINCIA` con `fields2Clear` che elenca `COMUNE`
- **Quando** l'utente cambia `PROVINCIA`
- **Allora** `COMUNE` si svuota

Oggi non succede: vedi DIV-SCH-1.

## ZNG-SCH-008 Apertura e caricamento del record
La scheda in finestra si apre con `open(mode, dati)`. In inserimento parte vuota. In modifica o consultazione mostra la riga ricevuta, oppure la legge da zServer se riceve solo la chiave, oppure, se non riceve niente, mostra la prima riga del dataset (schede a riga unica, come una configurazione). I metadati si leggono alla prima apertura e poi si riusano.

### Scenario: riga passata dalla griglia
- **Dato** una griglia con la riga selezionata
- **Quando** l'utente apre la modifica
- **Allora** la scheda mostra i valori della riga, senza leggerla di nuovo

### Scenario: solo la chiave
- **Dato** la chiave di una riga
- **Quando** la pagina chiama `open('edit', chiave)`
- **Allora** parte `GET data/{dataset}` con il filtro `[chiave primaria, '=', chiave]` e `take=1`, perché zServer non ha una rotta per leggere una riga sola (ZSRV-DSD-007)
- **E** la scheda mostra la riga che arriva

### Scenario: nessun dato
- **Dato** un dataset a riga unica
- **Quando** la pagina chiama `open('edit')` senza dati
- **Allora** parte `GET data/{dataset}` con `take=1` e la scheda mostra la prima riga, o resta vuota se il dataset non ne ha

### Scenario: parametri della pagina
- **Dato** una pagina che ascolta `beforeLoad`
- **Quando** la scheda si apre
- **Allora** l'evento arriva prima della lettura, e i parametri che la pagina aggiunge a `extraParams` partono con la richiesta della riga (per esempio l'azienda o il comune di lavoro)

## ZNG-SCH-009 Valori iniziali della scheda Nuovo
In inserimento i campi che hanno un valore in `control.editorOptions.value` (`BASE_WEB_DATASETS_FIELDS.EDITOR_OPTIONS`) partono con quel valore: la casella deve mostrare quello che il database metterebbe se non la si manda, altrimenti per esempio una voce nuova sembra nascere "non attiva" quando il database la crea attiva. Si riempiono solo i campi ancora vuoti: quello che l'utente ha già scritto resta.

### Scenario: spunta Attivo
- **Dato** il campo `ATTIVO` con `editorOptions: { "value": true }`
- **Quando** l'utente apre la scheda Nuovo
- **Allora** `ATTIVO` è già spuntato

### Scenario: metadati arrivati dopo l'apertura
- **Dato** una scheda Nuovo aperta prima che i metadati siano arrivati
- **Quando** arrivano
- **Allora** i valori iniziali si applicano in quel momento, senza toccare i campi già scritti

### Scenario: modifica
- **Dato** una scheda aperta in modifica
- **Quando** compare
- **Allora** i valori iniziali non si applicano: valgono i valori del record

## ZNG-SCH-010 Controllo dei dati prima del salvataggio
Prima di chiamare zServer la scheda controlla le regole dei campi. Se qualcosa non va, l'utente vede un avviso con **l'elenco dei campi da sistemare e il motivo**, poi il fuoco va sul primo: il solo bordo rosso non si vede se il campo non ha il fuoco o sta in un'altra linguetta.

### Scenario: campo obbligatorio vuoto
- **Dato** il campo obbligatorio "Materiale" vuoto
- **Quando** l'utente preme Salva
- **Allora** compare l'avviso "Dati da completare" con la riga "Materiale: obbligatorio"
- **E** chiuso l'avviso, il fuoco è sulla casella di "Materiale"
- **E** a zServer non parte niente

### Scenario: più regole sullo stesso campo
- **Dato** due regole non rispettate che producono lo stesso testo
- **Quando** l'utente preme Salva
- **Allora** la riga compare una volta sola

## ZNG-SCH-011 Salvataggio
Con i dati a posto, la scheda in inserimento manda `POST data/{dataset}`, in modifica `PUT data/{dataset}/{chiave}`, con tutti i valori della scheda nel corpo (ZSRV-DSD-010, ZSRV-DSD-011). Con una chiave composta i valori delle parti si uniscono con la virgola nell'ordine di `primaryKey`. Durante il salvataggio il pulsante Salva è disattivato, così un doppio clic non manda due inserimenti.

### Scenario: inserimento riuscito
- **Dato** una scheda Nuovo compilata
- **Quando** l'utente preme Salva e zServer accetta
- **Allora** compare la notifica "Record inserito", la pagina riceve `saved` con modalità e valori, e la scheda in finestra si chiude

### Scenario: modifica riuscita
- **Dato** una scheda in modifica
- **Quando** l'utente preme Salva e zServer accetta
- **Allora** parte `PUT data/{dataset}/{valore della chiave}`, compare "Record aggiornato" e la scheda si chiude

### Scenario: annullamento
- **Dato** una scheda in finestra con valori cambiati e non salvati
- **Quando** l'utente preme Annulla o chiude la finestra
- **Allora** la scheda si chiude senza chiedere conferma e la pagina riceve `cancelled`

## ZNG-SCH-012 Errori mostrati all'utente
Un salvataggio rifiutato da zServer ferma l'utente con un avviso che riporta il messaggio del server, **una volta sola**: se l'intercettore degli errori dell'applicazione l'ha già mostrato, la scheda non lo ripete. La scheda resta aperta con i valori scritti, così l'utente corregge e riprova. Un errore nella lettura dei metadati compare dentro la scheda, al posto dei campi.

### Scenario: salvataggio rifiutato
- **Dato** zServer che rifiuta il salvataggio con un messaggio (per esempio 403 "Inserimento non consentito per questo dataset")
- **Quando** l'utente preme Salva
- **Allora** compare un solo avviso con il messaggio: quello dell'intercettore, oppure, se l'intercettore non l'ha mostrato, l'avviso "Salvataggio non riuscito"
- **E** la scheda resta aperta e Salva torna attivo

### Scenario: metadati non leggibili
- **Dato** un dataset di cui zServer non restituisce i metadati
- **Quando** la scheda si apre
- **Allora** al posto dei campi compare "Errore metadati form per "{dataset}": " seguito dal motivo
- **E** la lettura fallita non resta in memoria: la prossima apertura riprova

## ZNG-SCH-013 Permessi
La scheda non decide chi può scrivere: decide zServer su ogni `POST` e `PUT` (autorizzazione del dataset e consenso a inserire o modificare, ZSRV-DSD-008), e il suo rifiuto arriva all'utente come in ZNG-SCH-012. Chi apre la scheda sceglie la modalità: la griglia offre Nuovo, Modifica e Cancella secondo `gridSettings.editing`. La cancellazione non è della scheda.

### Scenario: dataset che non consente l'inserimento
- **Dato** una pagina che apre la scheda in inserimento su un dataset che zServer non consente di inserire
- **Quando** l'utente salva
- **Allora** zServer risponde 403 e l'utente vede il motivo, senza che la scheda lo abbia previsto

## ZNG-SCH-014 Pulsanti dell'applicazione
La pagina può aggiungere pulsanti suoi alla scheda (`customButtons`), a sinistra o a destra di Annulla e Salva. Compaiono solo quelli destinati alla scheda (`target` `form` o `both`) e alla modalità corrente (`formModes`); il clic arriva alla pagina con una copia dei valori della scheda, così la pagina non li cambia per sbaglio.

### Scenario: pulsante solo in modifica
- **Dato** un pulsante con `formModes: ['edit']`
- **Quando** la scheda si apre in inserimento
- **Allora** il pulsante non c'è, e compare riaprendola in modifica

### Scenario: clic
- **Dato** un pulsante visibile
- **Quando** l'utente lo preme
- **Allora** la pagina riceve `actionButtonClick` con il pulsante, i valori della scheda, la modalità e l'origine `form`

## ZNG-SCH-015 Comandi di progettazione
Chi progetta le schede le sistema dalla scheda stessa: con il tasto destro sul corpo della scheda compare il menu di progettazione (numero di colonne, copia del nome del dataset, incolla impostazioni e, per il campo selezionato, etichetta, mostra o nascondi, sola lettura, obbligatorio, interruzione di riga, larghezza da 1 a 4 colonne o intera, indice nella scheda). Il comando si vede subito nella scheda e si salva su zServer dopo una breve pausa, accorpando i comandi vicini, con `PATCH data/{dataset}/metadata/fields` e `PATCH data/{dataset}/metadata/settings`. I comandi compaiono solo ai ruoli di progettazione (`tipo_user` `X`, ZNG-ACC-012), salvo che la pagina decida altrimenti con `showDevTools`; zServer accetta le due rotte solo con l'autorizzazione `BASE_WEB_METADATI`.

### Scenario: campo selezionato
- **Dato** un progettista che ha cliccato nella casella "Cognome"
- **Quando** apre il menu con il tasto destro
- **Allora** il menu ha la voce "Campo: Cognome" con i comandi del campo
- **E** su un campo booleano manca "Rendi obbligatorio" (ZNG-SCH-004)

### Scenario: clic fuori dai campi
- **Dato** un progettista che clicca su un'area vuota della scheda
- **Quando** apre il menu
- **Allora** i comandi del campo non ci sono e compare "Nessun campo selezionato"

### Scenario: salvataggio accorpato
- **Dato** un progettista che nasconde un campo e ne allarga un altro entro 800 millisecondi
- **Quando** passa la pausa
- **Allora** parte una sola `PATCH .../metadata/fields` con i due campi, e compare "Impostazioni form salvate"
- **E** prima di aprire l'editor dei metadati le modifiche in attesa partono subito

### Scenario: incolla impostazioni
- **Dato** negli appunti un elenco JSON di campi con `cardIndex`, `cardVisible`, `readOnly`, `required`, `lineBreak`
- **Quando** il progettista sceglie "Incolla impostazioni"
- **Allora** le impostazioni si applicano alla scheda aperta, ma non si salvano su zServer
- **E** con un testo non valido compare "Errore: contenuto clipboard non valido" e la scheda resta com'era

### Scenario: editor in loco
- **Dato** un'applicazione che fornisce l'editor dei metadati in loco (`ZzMetaInLocoService`)
- **Quando** il progettista preme il tasto destro su un campo
- **Allora** si apre il menu dell'editor in loco al posto di quello di progettazione
- **E** dopo un suo comando la scheda rilegge i metadati del dataset e ricostruisce i campi senza perdere i valori scritti

### Scenario: utente normale
- **Dato** un utente con `tipo_user` `U`
- **Quando** preme il tasto destro sulla scheda
- **Allora** non compare nessun menu di progettazione, e manca anche il pulsante "Dev Tools" in basso a sinistra

## ZNG-SCH-016 Campi interi
Una colonna intera (`column.fieldType` di un tipo intero di Firebird, `SHORT`, `LONG`, `INT64`, `INT128`, senza `column.fieldDecimals`) ha una casella che non accetta ne' virgola ne' punto: li blocca mentre l'utente digita e arrotonda quello che incolla. Perche': un valore con decimali in una colonna intera verrebbe arrotondato in silenzio al salvataggio ("125000,5" registrato come 125.001) e l'utente non se ne accorgerebbe. Vale anche per la cella della griglia in modifica e, fuori dai metadati, per ogni `<dx-number-box zzInteri>` delle applicazioni. Il rifiuto del valore con decimali resta comunque alla procedura che scrive.

Il dato arriva da `BASE_WEB.LOAD_DATASET_METADATA`, che dal rilascio `OUT/20261104-base-web-fieldtype/001` scrive `column.fieldType` (il tipo Firebird: `SHORT`, `LONG`, `INT64`, `INT128`, `VARYING`, ...) accanto a `column.fieldDecimals`. I metadati sono una copia salvata e rigenerata dagli script di quel rilascio: un dataset costruito prima non ha `fieldType` finché non viene rigenerato, e senza `fieldType` la casella resta quella di prima.

### Scenario: digitazione
- **Dato** una scheda con un campo intero
- **Quando** l'utente preme la virgola o il punto
- **Allora** il carattere non compare

### Scenario: valore incollato
- **Dato** il testo "125.000,5" negli appunti
- **Quando** l'utente lo incolla nel campo intero
- **Allora** il campo mostra 125.001

### Scenario: colonna con decimali
- **Dato** una colonna `INT64` con `fieldDecimals` 2 (NUMERIC(18,2))
- **Quando** la scheda si costruisce
- **Allora** la casella accetta i decimali come prima

### Scenario: metadati senza tipo
- **Dato** una colonna senza `fieldType` (dataset non ancora rigenerato)
- **Quando** la scheda si costruisce
- **Allora** la casella non è un campo intero e accetta i decimali come prima

## Divergenze note

Punti in cui il codice di oggi non mantiene quello che promette o non rispetta il contratto dell'altro lato. Si correggono nella voce R-177 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-SCH-1 | La scheda legge `fields2Clear` al primo livello del campo e lo scorre come un elenco (`zz-form.component.ts` 541-552), ma `BASE_WEB.LOAD_DATASET_METADATA` lo scrive dentro `column`, come testo (`column.fields2Clear`) | ZNG-SCH-007 non funziona: cambiando il campo di origine i campi dipendenti restano pieni. Se il dato arrivasse al primo livello come testo, la scheda svuoterebbe campi con il nome di una lettera |
| DIV-SCH-2 | Le regole di dipendenza cercano il campo di destinazione con il solo `dataField` (`dependency-engine.ts` 65-87, `itemOption(tf, ...)`). DevExtreme non trova così un campo dentro un gruppo o una linguetta con un nome, e zServer dà sempre un nome a gruppi e linguette (`name` = contenitore) | ZNG-SCH-006 vale solo per i campi al primo livello dell'albero: per gli altri le regole non mostrano, non nascondono e non rendono obbligatorio niente, senza errori |
| DIV-SCH-3 | La sola lettura della chiave cerca la casella con `getEditor(percorso)` (`zz-form.component.ts` 512), ma `getEditor` di DevExtreme vuole il `dataField`, non il percorso `Gruppo.CAMPO` | Una chiave collocata in un gruppo resta modificabile in modifica; il `PUT` usa poi il valore cambiato come chiave (`zz-form.component.ts` 453-457), quindi aggiorna un'altra riga o nessuna |
| DIV-SCH-4 | `open(mode, chiave)` chiamato prima che arrivino i metadati legge la riga filtrando su `ID` invece che sulla chiave vera (`zz-form.component.ts` 355-356) | Su un dataset con la chiave diversa da `ID` la lettura fallisce o restituisce un'altra riga. La griglia non ne soffre perché passa la riga intera |
| DIV-SCH-5 | I comandi di progettazione mostrano e cambiano `control.cardIndex` (`form-focus-tracker.ts` 124), ma i metadati portano l'ordine in `control.sortOrder`; la costruzione della scheda non usa né `cardIndex` né `lineBreak`; i percorsi interni non coincidono con quelli di DevExtreme per i campi del gruppo "Altro" e delle linguette con spazi nel titolo (`form-items-builder.service.ts` 120 e 332) | "Indice scheda" mostra sempre 999; indice e interruzione di riga si vedono solo alla riapertura; per i campi in "Altro" o in quelle linguette etichetta, visibilità, sola lettura, obbligatorio e larghezza si salvano ma non cambiano a video |
