---
area: Fasce orarie
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/007
---

# Fasce orarie

Questa specifica descrive il controllo, durante la sessione di lavoro, della fascia oraria in cui l'utente può usare il programma. Il codice è in `zBase\zSecurity.FasceOrarie.pas` (classe `TzControlloFasciaOraria`). Lo usano WT e Gesty nello stesso modo: `ConfigModule.pas` crea il controllo dopo l'accesso (`AvviaControlloFasciaOraria`, con `zSystem.AppName` e l'utente collegato), mostra l'avviso con `dxAlertWindowManager` («L'accesso termina fra N minuti: salvare il lavoro in corso.») e alla scadenza avvisa e chiude con `Shutdown`; registra inoltre l'evento Firebird `FASCIA_ORARIA_<utente>` per la chiusura chiesta dal server. Il rifiuto all'ingresso, fuori fascia, lo dà `USR_LOGIN` (motivo `FASCIA_ORARIA` nel registro di sicurezza) e non questa classe. Descrive il comportamento atteso, non il codice.

**Come funziona.** Subito dopo l'accesso la classe chiede al server, con la procedura `USR_FASCIA_ACCESSO_CHECK(APP, USER_ID, CURRENT_TIMESTAMP)`, se l'utente è dentro la sua fascia e fra quanti secondi il verdetto può cambiare. Conta quei secondi con un cronometro monotono (`TStopwatch`), guardandolo ogni 10 secondi senza interrogare il database, dà due preavvisi e allo scadere rifà la domanda: la risposta porta il nuovo intervallo e il giro ricomincia. La classe non chiude e non mostra niente: solleva `OnAvviso` e `OnAccessoScaduto`, e decide il programma.

**Test che coprono quest'area.** Nessuna.

## ZBASE-FAS-001 Avvio e database senza fasce
`Avvia(Applicazione, UserID)` ferma un eventuale controllo in corso, verifica nel dizionario (`RDB$PROCEDURES`) che `USR_FASCIA_ACCESSO_CHECK` esista e, solo in quel caso, fa la prima verifica. Su un database che non conosce le fasce il controllo resta spento senza sollevare eccezioni. Un errore nel leggere il dizionario, invece, esce da `Avvia`.

### Scenario: database senza la procedura
- **Dato** un database senza `USR_FASCIA_ACCESSO_CHECK`
- **Quando** si chiama `Avvia`
- **Allora** `Attivo` è falso e nessun evento viene sollevato

## ZBASE-FAS-002 Verdetto del server
La verifica legge `ACCESSO_AUTORIZZATO` e `SECONDI_ALLA_PROSSIMA_VERIFICA`. Con accesso autorizzato il controllo si riarma per quei secondi; con zero o meno secondi il controllo si spegne per tutta la sessione, perché l'utente non ha fasce associate. Con accesso non autorizzato scatta subito `OnAccessoScaduto`, anche alla prima verifica di `Avvia`.

### Scenario: utente senza fasce
- **Dato** un utente per cui il server risponde `ACCESSO_AUTORIZZATO = TRUE` e `SECONDI_ALLA_PROSSIMA_VERIFICA = 0`
- **Quando** parte il controllo
- **Allora** `Attivo` è falso per tutta la sessione e il database non viene più interrogato

### Scenario: fuori fascia alla verifica
- **Dato** un utente il cui tempo è scaduto e senza deroghe
- **Quando** il server risponde `ACCESSO_AUTORIZZATO = FALSE`
- **Allora** scatta `OnAccessoScaduto` e il controllo resta fermo

## ZBASE-FAS-003 Conteggio indipendente dall'orologio del computer
I secondi concessi si contano con un cronometro monotono, non confrontando data e ora del computer: spostare indietro l'orologio non allunga la sessione. Il controllo locale gira ogni 10 secondi (`IntervalloControlloLocale`), quindi la scadenza scatta con al più 10 secondi di ritardo. Allo scadere non si chiude niente da soli: si chiede di nuovo al server, l'unico che sa se nel frattempo è arrivata una deroga.

### Scenario: orologio spostato indietro
- **Dato** un controllo riarmato per 3600 secondi
- **Quando** l'utente sposta indietro l'ora del computer di due ore
- **Allora** la verifica sul server avviene comunque dopo circa 3600 secondi di lavoro

### Scenario: deroga arrivata durante la sessione
- **Dato** un utente il cui tempo scade alle 18:00 e a cui alle 17:30 viene concessa una deroga
- **Quando** il cronometro arriva a zero
- **Allora** il server risponde autorizzato con un nuovo intervallo e il controllo si riarma senza sollevare `OnAccessoScaduto`

## ZBASE-FAS-004 Preavvisi
Prima della scadenza `OnAvviso(Sender, SecondiResidui)` scatta al più due volte per ogni intervallo: una quando mancano 10 minuti o meno (`SecondiAvvisoLungo = 600`) ma più di uno, una quando manca un minuto o meno (`SecondiAvvisoBreve = 60`). A ogni riarmo i preavvisi ripartono. Se l'intervallo concesso è già sotto i 10 minuti, il preavviso lungo scatta al primo controllo locale; se è sotto il minuto, scatta solo quello breve.

### Scenario: intervallo lungo
- **Dato** un controllo riarmato per 2 ore
- **Quando** mancano 10 minuti e poi 1 minuto alla scadenza
- **Allora** `OnAvviso` scatta due volte, con circa 600 e circa 60 secondi residui

## ZBASE-FAS-005 Server che non risponde
Se la verifica sul server solleva un'eccezione (database irraggiungibile o procedura in errore) il programma non viene chiuso: il controllo scrive l'errore nel registro come avviso, si riarma per 60 secondi (`SecondiRitentaDopoErrore`) e riprova. `Ferma` spegne il controllo (WT e Gesty lo chiamano alla chiusura).

### Scenario: rete caduta alla scadenza
- **Dato** un controllo scaduto e il server irraggiungibile
- **Quando** la verifica fallisce
- **Allora** non scatta nessun evento e la verifica si ripete dopo 60 secondi

## ZBASE-FAS-006 Chiusura chiesta dal server
Il nome dell'evento Firebird con cui il server annuncia a un singolo utente di essere uscito dalla fascia è `EventoFasciaOraria` (`FASCIA_ORARIA_`) seguito dal nome dell'utente, distinto da `SHUTDOWN_` perché il messaggio deve dire il motivo. La classe definisce solo la costante: la registrazione dell'evento e la chiusura stanno nel `ConfigModule` del programma.

### Scenario: evento del server
- **Dato** WT collegato come `MARIO`
- **Quando** il server pubblica l'evento `FASCIA_ORARIA_MARIO`
- **Allora** il programma mostra il motivo e si chiude con la stessa procedura di `SHUTDOWN`

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-200 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-FAS-1 🟡 (dedotta) | In `Verifica` ogni eccezione della verifica sul server è trattata come rete caduta, anche quando è un errore permanente della procedura (permessi, parametri cambiati). Dal rilascio `OUT/20261101-specifiche-vive-zpack/007` l'errore va almeno nel registro | Il controllo si riarma ogni 60 secondi per sempre e l'utente lavora oltre la sua fascia e solo il registro lo mostra. Lasciata documentata (rilascio `OUT/20261101-specifiche-vive-zpack/013`): il ritentare per sempre è voluto («non è un motivo per chiudere l'applicazione» con la rete caduta) e chiudere dopo N errori punirebbe un'interruzione di rete; l'errore però è ora nel registro |
| DIV-FAS-2 🟢 (dedotta) | `LoginParams.SecondiAllaVerificaAccesso`, letto da `USR_LOGIN` (`SECONDI_ALLA_PROSSIMA_VERIFICA`) e documentato come «secondi al prossimo cambio di verdetto», non lo usa nessuno: né questa classe, che rifà la domanda da sé, né WT o Gesty | Valore morto che fa pensare a un secondo canale del controllo che non esiste. Lasciata documentata (rilascio `OUT/20261101-specifiche-vive-zpack/012`): nessun effetto in esecuzione, e togliere il parametro dalla procedura obbligherebbe a ritoccare il database di ogni cliente |
| DIV-FAS-3 🟢 (dedotta) | Il controllo e la chiusura sono nel client: un programma che non chiama `Avvia` o non gestisce `OnAccessoScaduto` lascia lavorare l'utente fuori fascia fino al prossimo accesso, che `USR_LOGIN` rifiuta | La fascia è garantita solo all'ingresso; durante la sessione dipende dal programma. Lasciata documentata (rilascio `OUT/20261101-specifiche-vive-zpack/012`): WT e Gesty chiamano `Avvia` e gestiscono `OnAccessoScaduto`, quindi oggi non ha effetto; è un obbligo di chi userà la classe in un programma nuovo |
