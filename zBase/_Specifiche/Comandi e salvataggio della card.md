---
area: Comandi e salvataggio della card
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbcard/003
---

# Comandi e salvataggio della card

Questa specifica descrive i due meccanismi con cui `TzDbCard` rimanda del lavoro a dopo: la coda dei comandi interni differiti (`zBase\zDbCard.Commands.pas`, classe `TzDeferredCommandQueue`) e il salvataggio delle impostazioni su un thread (`zBase\zDbCard.Saver.pas`, classi `TzDeferredSaver` e `TzCardAliveGuard`). Li usa solo `TzDbCard` (`PostInternalMessage`, `MessageHandler`, `CMShowingChanged`, `SaveProperties`, `DoDeferredSaveProperties`), quindi ogni card di WT e di Gesty. Descrive il comportamento atteso, non il codice.

**Come funziona.** Ogni azione interna della card (aggiornare le azioni, ricostruire i controlli, salvare le impostazioni, e così via) è un comando di `TzDbCardCommand`. La card non lo esegue subito: lo posta a se stessa come messaggio Windows, così una raffica di richieste produce una sola esecuzione. Se la card non ha ancora la finestra o non è a video, il comando è solo ricordato e si rilancia alla prima comparsa. Il salvataggio delle impostazioni ha una parte sincrona (allineare i controlli alle impostazioni) e una parte costosa (scrittura nella base) che gira in un task, una alla volta.

**Test che coprono quest'area.** `Test.zDbCard.Comandi`: coda senza finestra, coda con una form vera (messaggi contati agganciando il `WindowProc`), guardia, salvataggio con task reale (la chiusura in coda si consuma con `CheckSynchronize`). Il collegamento con la card (`MessageHandler`, `FSaver` collegato a `DescaleDlgSizeForSave`, `InternalSaveProperties`) non ha test: richiede una card con finestra.

## ZDBCARD-CMD-001 Comandi senza finestra
`Post(Comando, Parametro)` non posta niente se il controllo proprietario non ha l'handle o non è a video (`Showing` falso): ricorda il comando come differito e conserva il parametro, senza alzare il latch. Un secondo `Post` dello stesso comando prima della comparsa sovrascrive il parametro conservato (vale l'ultimo). Comandi diversi sono indipendenti.

### Scenario: card non ancora a video
- **Dato** una card creata ma senza finestra (wizard: `Insert` prima di `ShowForm`)
- **Quando** la card posta `cmd_UpdateActions`
- **Allora** `IsPending(cmd_UpdateActions)` è vero, nessun messaggio è in coda e gli altri comandi restano non in sospeso

## ZDBCARD-CMD-002 Comandi con finestra e coalescenza
Con finestra e card a video, `Post` alza il latch del comando, ne conserva il parametro e lo invia con `PostMessage` all'handle del proprietario (`WParam` = comando, `LParam` = parametro). Finché il latch è alzato, ogni altro `Post` dello stesso comando è scartato, anche con un parametro diverso: arriva un solo messaggio, con il primo parametro. Se `PostMessage` fallisce il latch si rilascia subito. Il latch resta alzato fino a `ReleaseLatch`, chiamato dal gestore dei messaggi.

### Scenario: raffica di richieste
- **Dato** una card a video e il comando `cmd_UpdateActions` mai postato
- **Quando** la card lo posta tre volte con parametri 1, 2 e 3 prima che il messaggio sia elaborato
- **Allora** arriva un solo messaggio, con parametro 1

### Scenario: dopo il rilascio del latch
- **Dato** un comando elaborato e il suo latch rilasciato
- **Quando** la card lo posta di nuovo con parametro 2
- **Allora** arriva un secondo messaggio con parametro 2

## ZDBCARD-CMD-003 Rilascio del latch nel gestore
Il gestore (`TzDbCard.MessageHandler`) rilascia il latch di `cmd_Resize` prima di eseguire il comando, perché durante il trascinamento un nuovo `cmd_Resize` può arrivare mentre l'esecuzione è in corso e deve rimettersi in coda: così l'ultima posizione ottiene sempre la ricostruzione. Per gli altri comandi il latch si rilascia dopo, nel `finally`. Un comando con la card in distruzione non esegue le operazioni di salvataggio e di caricamento.

### Scenario: trascinamento del bordo
- **Dato** una card ridimensionata di continuo
- **Quando** un secondo `cmd_Resize` arriva mentre il primo è in esecuzione
- **Allora** il secondo si accoda e viene eseguito, e la card non resta composta sulla larghezza intermedia

## ZDBCARD-CMD-004 Distruzione della finestra e comparsa
Alla distruzione dell'handle (`DestroyWnd`) i messaggi già postati andrebbero persi con la coda dei messaggi: `MovePostedToDeferred` toglie il latch e li ricorda come differiti, con l'ultimo parametro postato. `RepostDeferred`, chiamato da `CMShowingChanged` quando la card è a video e ha la finestra, azzera ogni differito e lo riposta con il suo parametro. Se non c'è ancora una finestra il rilancio ricade nel differimento e il comando non si perde. `IsPending` è vero per un comando postato o differito (la card lo usa per forzare l'esecuzione nel distruttore).

### Scenario: finestra ricreata
- **Dato** `cmd_SaveProperties` postato con parametro 5 e la finestra della card distrutta
- **Quando** la card torna a video
- **Allora** il comando è rilanciato una volta con parametro 5

## ZDBCARD-CMD-005 Salvataggio differito e coalizzato
`TzDeferredSaver.RequestSave` esegue prima `OnPrepare` sul thread dell'interfaccia (la card vi riporta `DlgWidth` e `DlgHeight` a 96 dpi, una volta sola), poi `OnExecuteSave` in un task (la scrittura nella base, o `OnCustomSaveProps` se assegnato). Se un task è già in volo, la richiesta si accoda: `OnPrepare` non si richiama e ne resta una sola, qualunque sia il numero di richieste. A task finito, sul thread dell'interfaccia, il saver azzera lo stato «in volo» e, se c'era una richiesta accodata, la azzera e chiama `OnRepostRequest`: la card la trasforma in un nuovo `cmd_SaveProperties`, che salva anche le modifiche arrivate nel frattempo.

Se la scrittura solleva un'eccezione (database irraggiungibile, errore di scrittura), il task la intercetta: la scrive nel registro diagnostico (sessione `zDbCard.Saver`, classe e messaggio) e, a task finito sul thread dell'interfaccia, la consegna a `OnSaveError`. Lo stato «in volo» si azzera comunque e una richiesta accodata viene rilanciata: un errore non blocca i salvataggi successivi.

### Scenario: errore nel task di salvataggio
- **Dato** un salvataggio la cui scrittura solleva un'eccezione
- **Quando** il task finisce
- **Allora** `OnSaveError` riceve classe e messaggio dell'errore, l'errore è nel registro e una nuova richiesta di salvataggio parte normalmente

### Scenario: raffica di richieste mentre il task è in volo
- **Dato** un salvataggio in corso
- **Quando** arrivano tre richieste
- **Allora** `HasQueuedRequest` è vero, `OnPrepare` non è stato richiamato e, a task finito, `OnRepostRequest` scatta una sola volta

## ZDBCARD-CMD-006 Salvataggio sincrono che rinuncia
`DeferIfRunning` restituisce vero e accoda una richiesta se un task è in volo; con nessun task restituisce falso e non accoda niente. Chi voleva salvare in modo sincrono deve rinunciare: il task in volo ripartirà e salverà anche le modifiche correnti. `ClearQueuedRequest` azzera la richiesta accodata senza rilanciarla.

### Scenario: salvataggio sincrono con task in volo
- **Dato** un task in volo
- **Quando** la card chiama `DeferIfRunning`
- **Allora** il risultato è vero e `HasQueuedRequest` è vero

## ZDBCARD-CMD-007 Chiusura sicura
`Shutdown(TimeoutMs)` attende il task in volo per al più il tempo indicato (l'eccezione del task o lo scadere del tempo non sono segnalate: si prosegue, meglio una perdita di memoria che uno stallo alla chiusura), azzera lo stato e spegne la guardia (`Alive = false`). La guardia è un oggetto con conteggio dei riferimenti che sopravvive alla card: le chiusure in coda (`TThread.Queue`) la catturano e controllano `Alive` prima di toccare lo stato, quindi una card distrutta tra la fine del task e la consegna della coda non produce accessi a memoria liberata. Dopo `Shutdown` nessuna richiesta accodata viene rilanciata. Senza task `Shutdown` non fa altro che spegnere la guardia; il distruttore la spegne comunque. `TzCardAliveGuard` nasce con `Alive = true`.

### Scenario: card chiusa con una richiesta accodata
- **Dato** un task in volo e una richiesta accodata
- **Quando** la card chiama `Shutdown` e poi la coda dei messaggi viene consumata
- **Allora** `OnRepostRequest` non scatta

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-211 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita; DIV-CMD-2 è fotografata da un test.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-CMD-1 🟡 (dedotta) | La coalescenza conserva un solo parametro per comando e scarta un secondo `Post` con parametro diverso (nota «B7» in testa a `zDbCard.Commands.pas`, lasciata di proposito). `cmd_NewLookupDisplayText` ha come parametro il puntatore dell'edit da svuotare | Se due lookup chiedono lo svuotamento del testo prima che il messaggio sia elaborato, il secondo non viene svuotato e il suo testo resta nella casella |
| DIV-CMD-2 🟢 | Prima della comparsa vale l'ultimo parametro (il differito si sovrascrive), a latch alzato vale il primo; provata da `PostRipetuto_Coalizzato` | Lo stesso comando con parametri diversi si comporta in modo diverso a seconda che la card sia a video o no; senza effetto per i comandi senza parametro |
| DIV-CMD-3 🟡 (dedotta) | Se `Shutdown` scade senza che il task abbia finito, azzera comunque `FTask` e `FRunning`, e il proprietario libera i dati serializzati (`zDbCardProps`) mentre il task può ancora scrivere | Con il database bloccato più del tempo massimo, la chiusura della card può causare un errore di accesso alla memoria nel task, invece dell'attesa |
