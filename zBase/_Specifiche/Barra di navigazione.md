---
area: Barra di navigazione
progetto: zBase
aggiornato: 2026-11-02
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/007
---

# Barra di navigazione

Questa specifica descrive `TzNavBarTools` (`zBase\zNavBarTools.pas`), il componente che riempie una barra laterale `TdxNavBar` con le azioni di una lista `TActionList` e fa cambiare pagina a un contenitore a schede quando l'utente sceglie una voce. Contiene anche le due classi di appoggio `TActionTabLink` e `TActionTabLinks`, che collegano un'azione a una scheda. Il componente è registrato nella palette `zBase` da `zBaseRegister.pas` (si trascina sulla form). La unit è compilata (compare nei `uses` di `zBaseRegister` e di `MainForm.pas` di Gesty) ma l'uso reale è uno solo: la form `TFormRC_Ingiunzioni` di WT (`Wintarif_Group\_src\dbForms\frmRC_Ingiunzioni.pas`), che costruisce la barra con `BuildSideBar` e collega sedici azioni ad altrettante schede con `AddLink`; Gesty ha la unit nei `uses` di `MainForm.pas` (riga 99) ma non crea nessun `TzNavBarTools`. Le form della cartella `gera prec` di WT la citano ma sono storia, non compilate.

**Come funziona.** Il componente ha due proprietà di collegamento, `ActionList` e `dxNavBar`. `BuildSideBar` cancella i gruppi che la barra aveva costruito, poi crea una voce per ogni azione visibile della lista (le azioni nascoste non hanno voce; l'abilitazione non si controlla) e la mette in un gruppo che ha come didascalia la categoria dell'azione. Il collegamento fra azione e scheda è un elenco interno: `AddLink(Azione, Scheda)` lo riempie e, se l'azione non ha già un gestore `OnExecute`, le assegna `ChangeActivePage`, che al clic porta in primo piano tutte le schede collegate all'azione.

**Test che coprono quest'area.** Nessuna prova esistente in `zPackTests`. Il test `Test.zNavBarTools` prova senza mostrare finestre: l'azzeramento dei collegamenti alla distruzione dei componenti (ZBASE-NVB-001), la costruzione dei gruppi per categoria con una barra non visualizzata (ZBASE-NVB-002), il collegamento azione-scheda e il gestore assegnato solo se assente (ZBASE-NVB-003), il cambio pagina con contenitori a schede non visualizzati (ZBASE-NVB-004) e la proprietà `TryNavBar` sempre falsa (ZBASE-NVB-005). Prova anche che le azioni nascoste non abbiano voce e che una lista vuota non dia errori (DIV-NVB-4, rilascio 009). Resta senza prova la visualizzazione vera delle voci nella barra e la proprietà di prova a tempo di progettazione con valore vero, che apre finestre modali.

## ZBASE-NVB-001 Collegamento alla lista delle azioni e alla barra
`ActionList` e `dxNavBar` sono vuote alla creazione. Assegnarle chiede al componente collegato di avvisare `TzNavBarTools` alla distruzione (`FreeNotification`): quando la lista o la barra viene liberata, la proprietà torna `nil` da sola. Quando si assegna un altro oggetto, o `nil`, il componente restituisce l'avviso al collegato precedente (`RemoveFreeNotification`); assegnare `nil` è ammesso e lascia la proprietà vuota. La distruzione del componente libera l'elenco interno dei collegamenti.

### Scenario: lista distrutta
- **Dato** un componente con `ActionList` assegnata a una lista che ha il suo stesso proprietario
- **Quando** si libera la lista
- **Allora** `ActionList` torna `nil`

### Scenario: barra distrutta
- **Dato** un componente con `dxNavBar` assegnata a una barra con lo stesso proprietario
- **Quando** si libera la barra
- **Allora** `dxNavBar` torna `nil`

## ZBASE-NVB-002 Costruzione della barra laterale
`BuildSideBar(Barra, Lista)` assegna le due proprietà e poi costruisce; `BuildSideBar` senza parametri usa quelle già assegnate e, se manca una delle due, fallisce con una verifica (`Assert`) e non con un messaggio. La costruzione avviene con la barra e la sua raccolta di voci in aggiornamento sospeso. Prima **cancella** ogni gruppo che non è «gruppo di controllo» (`OptionsGroupControl.UseControl` falso), con i suoi collegamenti e le voci collegate; i gruppi che ospitano un controllo restano. Poi, per **ogni** azione della lista nell'ordine della lista, crea una voce (`item.Action := Azione`, `Visible := True`), cerca fra i gruppi quello con la didascalia uguale alla categoria dell'azione e, se manca, lo crea (didascalia = categoria, icone grandi: `LinksUseSmallImages` falso), e vi collega la voce. I gruppi nascono quindi nell'ordine in cui compare la prima azione di ogni categoria. Un'azione senza categoria finisce in un gruppo con didascalia vuota. Alla fine il gruppo attivo è il primo (`ActiveGroupIndex := 0`). Ricostruire due volte non accumula voci né gruppi.

### Scenario: gruppi per categoria
- **Dato** una lista con tre azioni di categoria `Elenchi`, `Atti`, `Elenchi`
- **Quando** si chiama `BuildSideBar`
- **Allora** la barra ha due gruppi, `Elenchi` (con due voci) e `Atti` (con una), in questo ordine

### Scenario: ricostruzione
- **Dato** una barra già costruita con la stessa lista
- **Quando** si richiama `BuildSideBar`
- **Allora** i gruppi restano due e le voci restano tre

### Scenario: collegamento mancante
- **Dato** un componente senza `dxNavBar`
- **Quando** si chiama `BuildSideBar` senza parametri
- **Allora** scatta la verifica (`EAssertionFailed`)

## ZBASE-NVB-003 Collegamento fra azione e scheda
`AddLink(Azione, Scheda)` aggiunge un collegamento all'elenco interno e, **solo se** `Azione.OnExecute` è vuoto, vi assegna `ChangeActivePage`. Un'azione che ha già il suo gestore lo conserva e **non** cambia pagina: il collegamento resta registrato ma nessuno lo usa (DIV-NVB-2). Azione e scheda nulle fanno scattare una verifica (`Assert`). L'overload con un vettore di schede chiama `AddLink` una volta per scheda: la stessa azione può quindi comandare più schede, di norma di contenitori diversi (per esempio un contenitore esterno e uno interno). Collegare due volte la stessa coppia aggiunge un secondo collegamento identico, senza errori. I collegamenti non sono persistenti: si ricreano a ogni apertura della form (in `TFormRC_Ingiunzioni` nell'avvio della form, subito dopo `BuildSideBar`).

### Scenario: gestore assegnato
- **Dato** un'azione senza `OnExecute`
- **Quando** si chiama `AddLink(Azione, Scheda)`
- **Allora** `Azione.OnExecute` è assegnato

### Scenario: gestore già presente
- **Dato** un'azione con un proprio `OnExecute`
- **Quando** si chiama `AddLink(Azione, Scheda)`
- **Allora** `OnExecute` resta quello originale

### Scenario: più schede per azione
- **Dato** un'azione e due schede di contenitori diversi
- **Quando** si chiama `AddLink(Azione, [SchedaUno, SchedaDue])`
- **Allora** i collegamenti sono due e entrambi puntano all'azione

## ZBASE-NVB-004 Cambio di pagina
`ChangeActivePage(Mittente)` non fa niente se il mittente non è un'azione. Altrimenti scorre l'elenco dei collegamenti nell'ordine in cui sono stati aggiunti e, per ognuno collegato a quell'azione, chiama `ActivateTab`: `TabSheet.PageControl.ActivePage := TabSheet`. Una scheda nulla non fa niente; una scheda che non appartiene più a un contenitore (`PageControl` vuoto) va in violazione di accesso (DIV-NVB-3). Se due schede collegate appartengono allo stesso contenitore vince l'ultima. Un'azione senza collegamenti non cambia nulla. La voce della barra non tiene conto della scheda attiva: il componente non evidenzia nella barra la scheda raggiunta da altre strade (clic sulla linguetta, codice).

### Scenario: cambio di pagina
- **Dato** un contenitore a schede con due pagine, la prima attiva, e un'azione collegata alla seconda
- **Quando** si esegue il gestore `OnExecute` dell'azione
- **Allora** la pagina attiva è la seconda

### Scenario: schede in contenitori diversi
- **Dato** due contenitori con due pagine ciascuno e un'azione collegata alla seconda pagina di entrambi
- **Quando** si esegue il gestore dell'azione
- **Allora** la seconda pagina è attiva in tutti e due

### Scenario: mittente non azione
- **Dato** un componente qualunque che non è un'azione
- **Quando** si chiama il gestore con quel mittente
- **Allora** nessuna pagina cambia e non si solleva alcun errore

## ZBASE-NVB-005 Prova a tempo di progettazione
La proprietà `TryNavBar` serve solo nell'ambiente di sviluppo: mettendola a vero, il componente prova a ricostruire la barra sulla form in progettazione. Non ha un valore memorizzato (`stored false`, e `FTryNavBar` non viene mai assegnato: la riga è commentata) e quindi si legge sempre falso. Con il valore vero e `ActionList` vuota mostra la finestra modale `ActionList non assegnata`; con `dxNavBar` vuota, `NavBar non assegnata`; altrimenti chiama `BuildSideBar`. Con il valore falso non fa niente.

### Scenario: valore sempre falso
- **Dato** un componente qualunque
- **Quando** si assegna `TryNavBar := False` e si legge la proprietà
- **Allora** non succede niente e la lettura restituisce falso

## Divergenze note
Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce «R-213» di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `zNavBarTools.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-NVB-2 🟢 (dedotta) | `AddLink` (97-98) assegna `ChangeActivePage` solo se `OnExecute` è vuoto; se l'azione ha già un gestore il collegamento resta inerte senza avviso | Una voce della barra collegata a un'azione che ha già un proprio `OnExecute` non cambia pagina e nessuno se ne accorge; il cambio pagina andrebbe richiamato dal gestore esistente |
| DIV-NVB-3 🟢 (dedotta) | `TActionTabLink.ActivateTab` (251-255) controlla la scheda ma non il contenitore (`TabSheet.PageControl` può essere vuoto); `Notification` (198-209) azzera solo lista e barra, non i collegamenti verso azioni e schede liberate | Un collegamento verso una scheda liberata o staccata dal contenitore dà violazione di accesso al clic. Nell'uso reale azioni, schede e componente sono della stessa form e muoiono insieme, quindi il difetto è latente |
| DIV-NVB-5 🟢 (dedotta) | `SetTryNavBar` (223-242) non memorizza il valore (225 commentata): la proprietà `stored false` si legge sempre falsa, e `ChangeActivePage` ha una variabile locale `tab` inutilizzata (184-186) | Chi imposta `TryNavBar := True` da codice vede aprirsi finestre modali e poi la proprietà torna falsa: è solo un comando di progettazione travestito da proprietà |
