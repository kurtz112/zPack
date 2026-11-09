---
area: Griglia dai metadati
progetto: zNg
aggiornato: 2026-11-03
rilascio: OUT/20261030-specifiche-vive-dei-progetti/005
---

# Griglia dai metadati

Questa specifica descrive come la griglia del motore zz-* (`<zz-data-grid>`) si costruisce dai metadati di un dataset di zServer, legge i dati, apre la scheda per inserire e modificare, elimina, esporta e offre i comandi di progettazione. Descrive il comportamento atteso, non il codice. Il codice oggi sta in `core/components/zz-data-grid/zz-data-grid.component.ts` e `.html`, `core/services/metadata.service.ts`, `core/services/zserver.service.ts`, `core/services/user-capabilities.service.ts` e `core/models/metadata.models.ts`; le voci di progettazione sul tasto destro vengono da `zz/meta-editor/meta-in-loco.service.ts`.

Il lato server è in zServer, `_src/_Specifiche/Contratto - Dataset dinamici.md` (requisiti `ZSRV-DSD-*`). Gli indirizzi qui sotto sono relativi all'indirizzo di zServer (`UrlService.baseUrl`).

## ZNG-GRI-001 Metadati letti una volta e condivisi
I metadati di un dataset si chiedono a zServer una volta sola e si condividono fra tutte le griglie e le schede che lo mostrano, perché la stessa pagina apre spesso griglia e scheda dello stesso dataset e ogni lettura passa da una procedura del database. Una lettura non riuscita non resta in memoria, così il tentativo successivo riparte dal server.

### Scenario: due componenti sullo stesso dataset
- **Dato** una pagina con una griglia e una scheda sullo stesso dataset
- **Quando** la pagina si apre
- **Allora** parte una sola `GET data/<dataset>/metadata` (ZSRV-DSD-002)
- **E** tutti e due i componenti ricevono la stessa risposta

### Scenario: lettura non riuscita
- **Dato** zServer che risponde con un errore alla lettura dei metadati
- **Quando** la griglia viene riaperta o ricaricata
- **Allora** parte una nuova `GET data/<dataset>/metadata`, non si riusa l'errore

### Scenario: uscita dell'utente
- **Dato** metadati già in memoria
- **Quando** la sessione si chiude (ZNG-ACC-007, ZNG-ACC-008)
- **Allora** la memoria dei metadati si svuota, e il prossimo utente li rilegge con i propri permessi

## ZNG-GRI-002 Metadati non disponibili
Se i metadati non arrivano, la griglia non compare e al suo posto c'è il messaggio d'errore con il nome del dataset: senza metadati non si sa né quali colonne mostrare né quale chiave usare.

### Scenario: dataset inesistente
- **Dato** un nome di dataset che zServer non conosce
- **Quando** la griglia si apre
- **Allora** `GET data/<dataset>/metadata` risponde 404 (ZSRV-DSD-002)
- **E** al posto della griglia compare `Errore metadati "<dataset>": <messaggio>`, e nessuna lettura dei dati parte

## ZNG-GRI-003 Colonne dai metadati
Le colonne sono i campi dei metadati con `column.visible` diverso da `false`, nell'ordine di `column.sortOrder`. I campi della chiave primaria entrano sempre, ma nascosti e non modificabili: servono alla griglia per riconoscere le righe anche quando nessuno li guarda.

### Scenario: campo nascosto nei metadati
- **Dato** un campo con `column.visible = false`
- **Quando** la griglia si costruisce
- **Allora** il campo non è fra le colonne e non compare nemmeno nella gestione colonne

### Scenario: chiave primaria
- **Dato** un campo con `isPrimaryKey = true`
- **Quando** la griglia si costruisce
- **Allora** la colonna esiste ma è nascosta, non modificabile, e non compare fra i campi dei filtri avanzati

## ZNG-GRI-004 Formati per tipo di dato
Date e numeri si mostrano nel formato italiano deciso dal tipo del campo, in griglia come nella scheda, così lo stesso valore non appare in due modi diversi. Un `column.format` esplicito nei metadati vince sul formato automatico.

### Scenario: date e ore
- **Dato** un campo di tipo `date`, `datetime` o `time`
- **Quando** la griglia lo mostra
- **Allora** il formato è rispettivamente `dd/MM/yyyy`, `dd/MM/yyyy HH:mm` e `HH:mm`

### Scenario: decimali
- **Dato** un campo `number` con `column.fieldDecimals = 2` e senza `column.format`
- **Quando** la griglia lo mostra
- **Allora** il formato è `#,##0.00`

### Scenario: date in arrivo dal server
- **Dato** una risposta di `GET data/<dataset>` con date in testo ISO
- **Quando** le righe arrivano alla griglia
- **Allora** diventano date; quelle del 30/12/1899 diventano ore pure (colonne `TIME`)
- **E** il tipo di ogni colonna si decide dalla prima riga della risposta

## ZNG-GRI-005 Decodifica dei codici nelle celle
Un campo con un elenco di valori (`picklist`) mostra sempre la descrizione al posto del codice. Un campo collegato a un altro dataset (`lookup`) mostra la descrizione solo se la pagina lo chiede (`enableGridLookups`) e solo se il collegamento ha una chiave semplice uguale al campo stesso: con una chiave composta la decodifica cercherebbe ogni colonna sul primo campo della chiave e mostrerebbe descrizioni sbagliate, quindi resta il codice.

### Scenario: elenco di valori
- **Dato** un campo con `picklist`
- **Quando** la griglia lo mostra
- **Allora** la cella mostra il `text` dell'elemento con quel `value`

### Scenario: collegamento a chiave semplice
- **Dato** una griglia con `enableGridLookups` e un campo il cui `lookup.valueExpr` è il campo stesso
- **Quando** la griglia lo mostra
- **Allora** la descrizione si legge da `GET data/<lookup.dataset>` (ZSRV-DSD-003): tutto il dataset in una volta, oppure a pagine di `lookup.pageSize` righe se è indicato
- **E** con più campi in `lookup.displayExpr` la descrizione è la loro unione separata da ` - `

### Scenario: collegamento a chiave composta
- **Dato** un campo con `lookup.valueExpr = 'SETTORE; CATEGORIA_SERVIZIO; CODICE_SERVIZIO'`
- **Quando** la griglia lo mostra, anche con `enableGridLookups`
- **Allora** la cella mostra il codice, non una descrizione

### Scenario: colore
- **Dato** un campo con `control.editorType = 'dxColorBox'`
- **Quando** la griglia lo mostra
- **Allora** la cella mostra un campione del colore accanto al codice esadecimale, come la scheda

## ZNG-GRI-006 Dati letti dal server pagina per pagina
Paginazione, ordinamento e filtri li fa zServer, non il browser: i dataset possono avere decine di migliaia di righe. Raggruppamenti e totali restano nel browser. La lettura usa il `datasetId` restituito dai metadati, e la pagina può aggiungere parametri propri (comune o azienda di lavoro) prima che la griglia legga i dati.

### Scenario: prima pagina
- **Dato** metadati con `gridSettings.pageSize = 20`
- **Quando** la griglia si apre
- **Allora** parte `GET data/<datasetId>` con `skip`, `take=20` e `requireTotalCount` (ZSRV-DSD-003, ZSRV-DSD-005)
- **E** il selettore propone le dimensioni di `gridSettings.allowedPageSizes`

### Scenario: parametri della pagina
- **Dato** una pagina che nell'evento `beforeLoad` aggiunge `idAzienda` a `extraParams`
- **Quando** la griglia legge i dati
- **Allora** ogni lettura porta `idAzienda` nella query, e zServer lo verifica sulle aziende abilitate (ZSRV-DSD-006)

### Scenario: ordinamento su più colonne
- **Dato** una griglia aperta
- **Quando** l'utente ordina per una colonna e poi per un'altra
- **Allora** la lettura successiva porta tutti e due i criteri in `sort`

## ZNG-GRI-007 Ricerca e filtri
L'utente filtra in quattro modi che restano allineati fra loro: la casella di ricerca, la riga dei filtri sotto le intestazioni, il filtro dell'intestazione e il pannello dei filtri avanzati. Il filtro va sempre al server (ZNG-GRI-006). F3 sulla cella corrente filtra per il suo valore: "contiene" per il testo, "uguale" per numeri, date e caselle di spunta.

### Scenario: filtro per valore
- **Dato** la cella corrente su una colonna di testo con valore `Rossi`
- **Quando** l'utente preme F3, o sceglie "Filtro per valore" dal tasto destro
- **Allora** la colonna si filtra con "contiene `Rossi`" e si apre il pannello dei filtri avanzati con lo stesso filtro

### Scenario: filtro tolto dalla griglia
- **Dato** il pannello dei filtri avanzati aperto
- **Quando** l'utente toglie tutti i filtri dalla griglia
- **Allora** il pannello si chiude da solo

## ZNG-GRI-008 Inserimento e modifica passano dalla scheda
Inserimento, modifica e visualizzazione si fanno nella scheda del motore (`<zz-form>`) aperta in finestra sopra la griglia, mai nella finestra di modifica propria di DevExtreme: la scheda applica gruppi, regole e collegamenti dei metadati che la griglia non conosce. Solo con `gridSettings.editing.useFormForEdit = false` (o `forceFormForEdit = false`) la modifica avviene nella griglia, nel modo di `gridSettings.editing.mode`. L'inserimento passa sempre dalla scheda.

### Scenario: nuovo record
- **Dato** un dataset con `allowAdding`
- **Quando** l'utente preme "Nuovo" o sceglie "Inserisci" dal tasto destro
- **Allora** si apre una sola scheda, vuota, in inserimento
- **E** non si apre anche la finestra di inserimento di DevExtreme

### Scenario: salvataggio dalla scheda
- **Dato** una scheda aperta dalla griglia in inserimento o modifica
- **Quando** la scheda salva
- **Allora** la scheda si chiude, la griglia rilegge la pagina corrente
- **E** la griglia emette `rowInserted` o `rowUpdated` con i dati salvati

### Scenario: doppio clic e Invio
- **Dato** una riga corrente
- **Quando** l'utente fa doppio clic sulla riga o preme Invio
- **Allora** si apre la scheda nel modo di `dblClickMode` (`edit` se la pagina non dice altro, oppure `view`)

## ZNG-GRI-009 Comandi di scrittura secondo i metadati
I comandi "Nuovo", "Modifica", "Elimina" e "Visualizza" (pulsanti, colonna dei pulsanti di riga, tasto destro) compaiono secondo `gridSettings.editing`: `allowAdding`, `allowUpdating`, `allowDeleting`, `allowView` (vero se assente). Senza indicazione la griglia non scrive. Il controllo vero resta quello di zServer su ogni scrittura (autorizzazione del dataset e permessi di inserimento, modifica ed eliminazione, ZSRV-DSD-008): qui si evita solo di offrire comandi che darebbero errore.

### Scenario: dataset in sola lettura
- **Dato** metadati con `allowAdding`, `allowUpdating` e `allowDeleting` falsi
- **Quando** la griglia si apre
- **Allora** non compaiono "Nuovo", "Modifica" ed "Elimina", né fra i pulsanti né sul tasto destro
- **E** resta il pulsante di riga "Visualizza", che apre la scheda in sola lettura

### Scenario: zServer rifiuta la scrittura
- **Dato** un dataset con `allowDeleting` nei metadati ma eliminazione non consentita su zServer
- **Quando** l'utente elimina una riga
- **Allora** `DELETE data/<datasetId>/<chiave>` risponde 403 e l'utente vede il messaggio di zServer (ZNG-GRI-010)

## ZNG-GRI-010 Eliminazione con conferma
Prima di eliminare la griglia chiede conferma nominando che cosa si sta per eliminare: per una riga sola il valore della prima colonna visibile di testo libero non vuota (non un codice di collegamento o di elenco, che direbbe solo "Eliminare P"), altrimenti della prima colonna visibile valorizzata. Con più righe selezionate le elimina una dopo l'altra. Se una eliminazione fallisce, la griglia si rilegge comunque, perché le righe già eliminate prima dell'errore non devono restare a video.

### Scenario: una riga
- **Dato** la riga corrente con descrizione `Corso di saldatura`
- **Quando** l'utente sceglie "Elimina" e conferma `Eliminare Corso di saldatura da <titolo del dataset>?`
- **Allora** parte `DELETE data/<datasetId>/<chiave>` (ZSRV-DSD-012)
- **E** la griglia si rilegge, la selezione si azzera, compare "Record eliminato" e la griglia emette `rowRemoved`

### Scenario: testo con caratteri HTML
- **Dato** una descrizione che contiene `<` o `&`
- **Quando** compare la conferma
- **Allora** il testo si mostra così com'è, senza essere interpretato come HTML

### Scenario: errore a metà di un'eliminazione multipla
- **Dato** cinque righe selezionate e zServer che rifiuta la terza
- **Quando** l'utente conferma
- **Allora** le prime due restano eliminate, la griglia si rilegge e non le mostra più
- **E** l'errore compare una volta sola: se l'intercettore dell'applicazione l'ha già mostrato la griglia non aggiunge un secondo avviso

## ZNG-GRI-011 Riga corrente e selezione
La griglia segue sempre una riga corrente e la comunica alla pagina (`focusedRowChanged`), che la usa per collegare altre parti della pagina e per i propri pulsanti. I pulsanti della pagina con `requiresSelection` sono disattivati finché non c'è una riga corrente. Selezione singola o multipla e caselle di spunta seguono `gridSettings.selection`; con righe selezionate compare la barra con il loro numero e, se il dataset lo consente, "Elimina N".

### Scenario: pulsante della pagina
- **Dato** un pulsante passato in `customButtons` con `requiresSelection`
- **Quando** la griglia non ha una riga corrente
- **Allora** il pulsante è disattivato
- **E** quando l'utente lo preme con una riga corrente, la pagina riceve `actionButtonClick` con una copia dei dati della riga e `source: 'grid'`

### Scenario: pulsanti passati alla scheda
- **Dato** un pulsante con `target: 'form'` o `'both'` e `passToForm` non falso
- **Quando** la griglia apre la scheda
- **Allora** il pulsante compare nella scheda e il suo clic arriva alla pagina come `actionButtonClick`

## ZNG-GRI-012 Esportazione
Dal tasto destro l'utente esporta in Excel, CSV o PDF quello che la griglia mostra, con le colonne visibili e i filtri applicati. Il file prende il nome dal titolo del dataset (`caption`) o, in mancanza, dal suo nome. Il CSV neutralizza i contenuti che un foglio di calcolo eseguirebbe come formule.

### Scenario: esportazione in Excel
- **Dato** una griglia del dataset con `caption = 'Corsi'`
- **Quando** l'utente sceglie Esporta, Excel
- **Allora** si scarica `Corsi.xlsx` con un foglio `Foglio 1`

## ZNG-GRI-013 Disposizione delle colonne
Spostamenti, larghezze e colonne nascoste dall'utente valgono fino al prossimo caricamento della pagina: la griglia non li ricorda da sola. La disposizione permanente sta nei metadati e la cambia solo chi progetta, con i comandi di ZNG-GRI-014, così tutti gli utenti vedono la stessa griglia.

### Scenario: colonna nascosta dall'utente
- **Dato** un utente che nasconde una colonna da "Gestione colonne"
- **Quando** ricarica la pagina
- **Allora** la colonna torna visibile

## ZNG-GRI-014 Comandi di progettazione
Chi progetta ha sulla griglia i comandi per cambiare i metadati senza lasciare la pagina. Il pulsante degli strumenti compare ai ruoli di `canDevTools` (oggi `tipo_user` `X`) o quando la pagina lo impone con `showDevTools`, e apre l'editor dei metadati (`/meta-editor`) sulla scheda del dataset: dataset, campi, gruppi della scheda, anteprima. Con l'editor in loco abilitato, il tasto destro su intestazione o righe aggiunge le voci della colonna (etichetta, nascondi, larghezza, obbligatorietà), "Mostra colonna", "Salva l'ordine e le larghezze delle colonne come le vedi" e "Modifica metadati...". Dopo un salvataggio la griglia rilegge i metadati del suo dataset senza ricaricare la pagina.

### Scenario: colonna nascosta in loco
- **Dato** un progettista con l'editor in loco abilitato
- **Quando** sceglie Colonna, Nascondi sul tasto destro
- **Allora** il campo si salva nei metadati con `VISIBLE = false`
- **E** la griglia di quel dataset rilegge `GET data/<dataset>/metadata` e la colonna sparisce
- **E** le griglie di altri dataset nella stessa pagina non si ricaricano

### Scenario: ricarica dei metadati
- **Dato** un progettista
- **Quando** sceglie "Ricarica metadati"
- **Allora** i metadati del dataset si tolgono dalla memoria e si rileggono da zServer, e la griglia si ricostruisce

### Scenario: incolla impostazioni colonne
- **Dato** negli appunti un elenco JSON di `dataField`, `viewIndex`, `viewVisible`
- **Quando** il progettista sceglie "Incolla impostazioni colonne"
- **Allora** ordine e visibilità delle colonne cambiano subito, solo in questa pagina e senza salvare niente sul server
- **E** con appunti non validi compare "Errore: clipboard non valido" e la griglia resta com'era

## ZNG-GRI-015 Griglia in finestra
Con `modal` la griglia vive in una finestra e legge metadati e dati solo quando la finestra si apre la prima volta, perché una pagina può avere molte griglie in finestra che l'utente non apre mai.

### Scenario: finestra mai aperta
- **Dato** una pagina con una griglia `modal` non visibile
- **Quando** la pagina si apre
- **Allora** non parte nessuna lettura per quel dataset
- **E** quando la pagina chiama `open()`, la finestra si apre e la griglia legge metadati e dati

## ZNG-GRI-016 Colore delle celle
La pagina può colorare una colonna con l'input `regoleColore` (chiave = campo del dataset). Tre regole: `segno` (negativo rosso, positivo verde, zero senza colore; con `invertito` i colori si scambiano, per importi ancora da incassare), `mappa` (colore secondo il valore della cella, senza maiuscole e spazi ai lati; con `cerchio` un cerchio colorato precede il testo) e `scaduto` (data già passata con un importo aperto maggiore di zero nella stessa riga: rosso in grassetto). I colori sono quattro tonalità (`positivo`, `attenzione`, `negativo`, `neutro`) leggibili su tema chiaro e scuro; l'applicazione può ridefinirle con le variabili CSS `--zz-colore-*`. Un campo senza regola o assente dal dataset non cambia.

### Scenario: saldo per segno
- **Dato** la regola `{ tipo: 'segno' }` sul campo `SALDO`
- **Quando** una riga ha saldo `-391,65`
- **Allora** la cella mostra il testo formattato dalla griglia in rosso

### Scenario: stato con cerchio
- **Dato** una `mappa` con `ATTIVA: 'positivo'` e `cerchio: true`
- **Quando** la cella vale `attiva`
- **Allora** compare un cerchio verde seguito dal testo nel colore normale

## ZNG-GRI-017 Griglia senza righe
A caricamento finito, se non ci sono righe da mostrare, al posto del testo predefinito di DevExtreme compare un riquadro con icona e testo, sotto l'intestazione. Con filtri o ricerca attivi il testo è «Nessun risultato con i filtri impostati» con il pulsante «Togli i filtri», che svuota filtri e ricerca. Altrimenti è `testoVuoto` della pagina o, in mancanza, «Nessun dato da mostrare», con l'icona `iconaVuota` (nome di un'icona di DevExtreme) o l'icona informazioni.

### Scenario: dataset senza righe
- **Dato** una griglia con `testoVuoto = 'Nessuna ingiunzione per questo contribuente'` e nessuna riga
- **Quando** la griglia ha finito di caricare
- **Allora** compare quel testo con l'icona scelta

### Scenario: filtri che nascondono tutto
- **Dato** una griglia con righe e un filtro che le esclude tutte
- **Quando** il filtro è applicato
- **Allora** compare «Nessun risultato con i filtri impostati» e «Togli i filtri» rimette tutte le righe

## ZNG-GRI-018 Righe mostrate
Ogni volta che la griglia ha finito di mostrare i dati (primo caricamento, filtri, ricerca, ordinamento, cambio di pagina, rilettura) emette `righeMostrate` con il campo della chiave primaria del dataset e le righe di dati visibili. La pagina che tiene una riga scelta fuori dalla griglia (pulsanti o dettaglio sotto la griglia) la confronta per chiave con queste righe e la toglie se non c'e' piu'.

### Scenario: filtro che nasconde la riga scelta
- **Dato** una griglia con una riga scelta e i pulsanti di quella riga sotto la griglia
- **Quando** un filtro o la ricerca escludono la riga
- **Allora** `righeMostrate` arriva senza quella riga e la pagina toglie i pulsanti

## Divergenze note

Punti in cui il codice di oggi non mantiene quello che promette o non rispetta il contratto dell'altro lato. Si correggono nella voce R-177 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-GRI-1 | zServer manda nei metadati `column.width`, `column.band` e `gridSettings.bands`, `allowResizing`, `allowReordering`, `allowHiding`, `allowGrouping`, e il modello dichiara anche `cssClass`, `wordWrap`, `summaryType`; la costruzione delle colonne non li usa (applica solo `minWidth`, `format`, `fixed`, `groupIndex`). L'editor in loco salva `WIDTH` con "Fissa la larghezza attuale" e con "Salva l'ordine e le larghezze" | Il progettista fissa una larghezza, il salvataggio riesce, ma la griglia continua a calcolare le larghezze da sola; le bande definite nei metadati non compaiono e le colonne bloccate nei metadati restano spostabili e nascondibili |
| DIV-GRI-2 | `UserCapabilitiesService` espone `canWrite` e `canExport`, e ZNG-ACC-012 dice che il ruolo decide scrittura ed esportazione, ma la griglia usa solo `canDevTools`: i comandi di scrittura dipendono solo da `gridSettings.editing`, l'esportazione da niente | Un utente con un ruolo che non scrive vede "Nuovo", "Modifica", "Elimina" e riceve l'errore di zServer solo al salvataggio; un utente senza ruolo può esportare |
| DIV-GRI-3 | `gridSettings.export.enabled` e `allowExportSelectedData` regolano solo il pulsante di esportazione della barra; la voce "Esporta" del tasto destro c'è sempre, e `export.formats` e `export.fileName` non si leggono | Un dataset dichiarato non esportabile si esporta lo stesso dal tasto destro |
| DIV-GRI-4 | Con una chiave primaria di più campi (`primaryKey = 'A,B'`) la griglia elimina mandando i valori uniti da virgola (`DELETE data/<id>/<a>,<b>`) e usa la stringa intera come nome di chiave della griglia e dello store; zServer confronta un solo campo chiave con `:KEY` (ZSRV-DSD-011, ZSRV-DSD-012; è DIV-DSD-2 visto dal server) | Su un dataset a chiave composta senza `DeleteSQL` dedicato l'eliminazione non trova la riga, o fallisce se la chiave è numerica; anche il riconoscimento delle righe (riga corrente, selezione) non funziona |
