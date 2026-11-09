---
area: Accesso
progetto: zNg
aggiornato: 2026-10-30
rilascio: OUT/20261028-libreria-angular-zng/016
---

# Accesso

Questa specifica descrive come un'applicazione basata su zNg (Agorà, GestyWeb) fa entrare l'utente su zServer, mantiene la sessione e la chiude. Descrive il comportamento atteso, non il codice. Il codice oggi sta in `core/services/auth.service.ts`, `core/services/accesso.config.ts`, `core/guards`, `core/interceptors/auth.interceptor.ts` e `core/services/accesso-metadati.service.ts`.

Il lato server è in zServer, `_src/_Specifiche/Contratto - Autenticazione.md` (requisiti `ZSRV-AUT-*`). Gli indirizzi qui sotto sono relativi all'indirizzo di zServer (`UrlService.baseUrl`).

## ZNG-ACC-001 Accesso con nome utente e password
L'applicazione manda le credenziali a zServer e, se le accetta, conserva i due token ricevuti: quello di accesso e quello di rinnovo.

### Scenario: credenziali accettate
- **Dato** un utente non collegato
- **Quando** inserisce nome utente e password corretti
- **Allora** parte `POST auth/login` con `jwtusername` e `jwtpassword` (ZSRV-AUT-001)
- **E** i token `token` e `refresh_token` della risposta vengono conservati (ZNG-ACC-002)
- **E** il rinnovo viene programmato (ZNG-ACC-003)

### Scenario: credenziali rifiutate
- **Dato** un utente non collegato
- **Quando** zServer rifiuta le credenziali
- **Allora** l'errore arriva alla pagina di login, che lo mostra
- **E** nessun token viene conservato

## ZNG-ACC-002 Durata della sessione nel browser
La sessione dura quanto la scheda del browser: sopravvive al ricaricamento della pagina e si perde alla chiusura della scheda.

### Scenario: ricaricamento
- **Dato** un utente collegato
- **Quando** ricarica la pagina
- **Allora** resta collegato, senza un nuovo login

### Scenario: memoria della scheda non disponibile
- **Dato** un browser che non permette di usare `sessionStorage` (navigazione privata, anteprime)
- **Quando** l'utente entra
- **Allora** la sessione funziona lo stesso, ma vive solo in memoria e si perde al ricaricamento

## ZNG-ACC-003 Rinnovo prima della scadenza
Il token di accesso si rinnova da solo due minuti prima della scadenza scritta nel token (`exp`), così l'utente non vede mai una richiesta rifiutata per un token scaduto mentre lavora.

### Scenario: rinnovo programmato
- **Dato** un utente collegato con un token che scade fra più di due minuti
- **Quando** mancano due minuti alla scadenza
- **Allora** parte `POST auth/refresh` con il token di rinnovo (ZSRV-AUT-003)
- **E** i due token nuovi sostituiscono i vecchi, e si programma il rinnovo successivo

### Scenario: applicazione aperta con un token già scaduto
- **Dato** un token di accesso scaduto, o che scade fra meno di due minuti, conservato nella scheda
- **Quando** l'applicazione si avvia
- **Allora** il rinnovo parte subito

## ZNG-ACC-004 Un rinnovo alla volta
Se più richieste hanno bisogno del rinnovo nello stesso momento, a zServer arriva una richiesta sola. Le altre aspettano il suo esito e lo ricevono, **anche quando è un fallimento**. Il motivo è doppio: zServer ruota il token di rinnovo a ogni uso e tratta un secondo uso dello stesso token come un furto (ZSRV-AUT-003); e una richiesta lasciata in attesa per sempre resterebbe nella cache dei metadati e bloccherebbe la pagina.

### Scenario: rinnovo riuscito con richieste in attesa
- **Dato** un rinnovo in corso
- **Quando** altre richieste ricevono 401 e chiedono a loro volta il rinnovo
- **Allora** non parte un secondo `auth/refresh`
- **E** alla fine del rinnovo le richieste vengono ripetute con il token nuovo

### Scenario: rinnovo fallito con richieste in attesa
- **Dato** un rinnovo in corso e altre richieste in attesa del suo esito
- **Quando** zServer rifiuta il rinnovo
- **Allora** tutte le richieste in attesa terminano con errore, e nessuna resta appesa
- **E** dopo il nuovo login le pagine caricano di nuovo i loro dati senza ricaricare il browser

## ZNG-ACC-005 Token nelle richieste
Ogni richiesta verso zServer porta l'intestazione `Authorization: Bearer <token>`, tranne login, rinnovo e uscita (`auth/login`, `auth/refresh`, `auth/logout`): non vogliono il token di accesso, e un loro 401 non va rinnovato. Le altre rotte di `auth/` (cambio password, verifica del token, uscita da tutti i dispositivi) lo portano come tutte.

### Scenario: richiesta normale
- **Dato** un utente collegato
- **Quando** l'applicazione chiama una rotta di zServer fuori da `auth/`
- **Allora** la richiesta porta il token di accesso

### Scenario: rotta con "login" nel nome
- **Dato** una rotta di zServer che contiene la parola `login` ma non comincia con `auth/`
- **Quando** l'applicazione la chiama
- **Allora** la richiesta porta il token come tutte le altre

### Scenario: rotta di auth/ che vuole il token
- **Dato** un utente collegato
- **Quando** l'applicazione chiama `auth/password`
- **Allora** la richiesta porta il token, e un suo 401 viene rinnovato come per le altre rotte

## ZNG-ACC-006 Richiesta rifiutata per token scaduto
Una richiesta rifiutata con 401 viene rinnovata e ripetuta una volta, senza che l'utente se ne accorga.

### Scenario: 401 con token di rinnovo valido
- **Dato** un utente collegato il cui token di accesso è appena scaduto
- **Quando** una richiesta riceve 401
- **Allora** si rinnova il token (ZNG-ACC-004) e la richiesta viene ripetuta con il token nuovo
- **E** la pagina riceve la risposta della richiesta ripetuta, non l'errore

## ZNG-ACC-007 Sessione scaduta
Quando la sessione non si può più rinnovare, l'applicazione la chiude e porta al login **dicendo perché**. L'avviso c'è una volta sola: una seconda navigazione al login lo farebbe perdere.

### Scenario: rinnovo rifiutato con 401
- **Dato** un utente collegato il cui token di rinnovo è scaduto o revocato
- **Quando** il rinnovo riceve 401 da zServer
- **Allora** i token vengono cancellati e il rinnovo programmato annullato
- **E** la cache dei metadati viene svuotata
- **E** si apre la pagina di login (`percorsoLogin`) con `?reason=session_expired`, che la pagina usa per mostrare l'avviso di sessione scaduta
- **E** non segue un'altra navigazione al login senza il motivo

### Scenario: 401 senza token di rinnovo
- **Dato** una sessione con il token di accesso ma senza token di rinnovo
- **Quando** una richiesta riceve 401
- **Allora** succede lo stesso dello scenario precedente

### Scenario: sessione già chiusa
- **Dato** una sessione già chiusa per scadenza
- **Quando** arrivano altri 401 da richieste partite prima
- **Allora** non succede niente: la pagina di login resta con il suo avviso

## ZNG-ACC-008 Uscita
L'uscita chiude la sessione anche se zServer non risponde, perché per l'utente conta che il browser non resti collegato.

### Scenario: uscita dal menu
- **Dato** un utente collegato
- **Quando** sceglie di uscire
- **Allora** parte `POST auth/logout` con il token di rinnovo (ZSRV-AUT-004)
- **E** senza aspettare la risposta i token vengono cancellati, il rinnovo annullato e la cache dei metadati svuotata
- **E** si apre la pagina di login, senza motivo

### Scenario: zServer non risponde
- **Dato** un utente collegato e zServer irraggiungibile
- **Quando** sceglie di uscire
- **Allora** la sessione locale si chiude lo stesso e non compare nessun errore

Ogni voce di uscita dell'applicazione (menu laterale, intestazione, profilo) deve arrivare a questa uscita. In GestyWeb la voce del menu laterale non lo faceva: corretto nel rilascio `OUT/20261028-libreria-angular-zng/007`.

## ZNG-ACC-009 Pagine protette
Una pagina protetta si apre solo con una sessione valida. Se la sessione è scaduta ma ancora rinnovabile, la si rinnova prima di decidere.

### Scenario: sessione valida
- **Dato** un utente collegato
- **Quando** apre una pagina protetta
- **Allora** la pagina si apre e viene ricordata come pagina da riaprire dopo un nuovo login

### Scenario: token scaduto ma rinnovabile
- **Dato** un token di accesso scaduto e un token di rinnovo valido
- **Quando** l'utente apre una pagina protetta
- **Allora** il token si rinnova e la pagina si apre, senza passare dal login

### Scenario: nessuna sessione
- **Dato** un utente non collegato
- **Quando** apre una pagina protetta
- **Allora** si apre la pagina di login al posto della pagina richiesta, senza un secondo cambio di pagina

## ZNG-ACC-010 Pagine di accesso con una sessione valida
Chi è già collegato non vede le pagine di accesso (login, recupero password: `pagineDiAccesso`) e torna alla pagina iniziale (`percorsoIniziale`).

### Scenario: login aperto da un utente collegato
- **Dato** un utente collegato
- **Quando** apre la pagina di login, per esempio dalla cronologia del browser
- **Allora** si apre la pagina iniziale

## ZNG-ACC-011 Strumenti dei metadati
Le pagine degli strumenti di sviluppo (vetrina e editor dei metadati) si aprono solo a chi ha l'autorizzazione `BASE_WEB_METADATI`. Il token non porta le autorizzazioni, quindi si chiede a zServer. Il controllo vero resta quello di zServer su ogni rotta dell'editor: questo serve solo a non mostrare pagine che darebbero solo errori.

### Scenario: utente autorizzato
- **Dato** un utente collegato con `BASE_WEB_METADATI`
- **Quando** apre una pagina degli strumenti dei metadati
- **Allora** `GET meta/access` risponde 200 e la pagina si apre

### Scenario: utente non autorizzato
- **Dato** un utente collegato senza `BASE_WEB_METADATI`
- **Quando** apre una pagina degli strumenti dei metadati
- **Allora** `GET meta/access` risponde 403, l'applicazione non mostra nessun errore e apre la pagina `/`

### Scenario: cambio di utente
- **Dato** un utente autorizzato che esce e un altro, non autorizzato, che entra
- **Quando** il secondo utente entra
- **Allora** le voci di menu degli strumenti non compaiono più, perché la verifica si rifà a ogni accesso

## ZNG-ACC-012 Identità dell'utente collegato
I dati dell'utente collegato si leggono dal token di accesso, senza chiederli a zServer. Il ruolo che decide strumenti di progettazione, esportazione e scrittura è il claim `tipo_user` (ZSRV-AUT-002), sostituibile dall'applicazione con `ZZ_RUOLO_UTENTE`.

### Scenario: ruolo
- **Dato** un utente collegato con `tipo_user = U`
- **Quando** il motore zz-* decide se mostrare i comandi di scrittura
- **Allora** li mostra, perché `U` è fra i ruoli che scrivono (`A`, `D`, `U`)

## ZNG-ACC-013 Configurazione per applicazione
Percorsi e testi che cambiano da un'applicazione all'altra entrano con `fornisciConfigurazioneAccesso(...)` (token `ZZ_ACCESSO_CONFIG`). Senza configurazione valgono i predefiniti: login su `/login`, pagina iniziale `/`. zNg non importa niente dall'applicazione.

Un'applicazione che ha bisogno di altri metodi di accesso estende `AuthService` e la fornisce al suo posto con `{ provide: AuthService, useExisting: <classe> }`: così guardie, intercettori e motore usano la stessa istanza. Oggi lo fa Agorà.

### Scenario: pagina di login diversa
- **Dato** Agorà, che configura `percorsoLogin: '/login-form'`
- **Quando** la sessione scade
- **Allora** si apre `/login-form?reason=session_expired`

## ZNG-ACC-014 Cambio password
L'utente collegato cambia la propria password dal modulo `<zz-cambio-password />` (`core/accesso/zz-cambio-password.component.ts`), che chiama `AuthService.cambiaPassword()` e quindi `POST /auth/password` di zServer (ZSRV-AUT-008). Il modulo chiede la password attuale, la nuova (almeno 8 caratteri, diversa dall'attuale) e la conferma. Titolo, riquadro e testi intorno sono della pagina dell'applicazione. Oggi lo usa GestyWeb (`/password`).

### Scenario: cambio riuscito
- **Dato** un utente collegato che conosce la propria password
- **Quando** compila il modulo e conferma
- **Allora** compare la notifica "Password cambiata: vale dal prossimo accesso" e il modulo si svuota
- **E** la sessione resta aperta

### Scenario: password attuale sbagliata
- **Dato** un utente collegato
- **Quando** conferma con una password attuale sbagliata
- **Allora** sotto il modulo compare "La password attuale non e' corretta.", senza notifica e senza avviso modale

### Scenario: dati non validi
- **Dato** una nuova password più corta di 8 caratteri, uguale all'attuale o diversa dalla conferma
- **Quando** l'utente conferma
- **Allora** il modulo segnala il campo e zServer non viene chiamato

## Divergenze note

Punti in cui il codice di oggi non rispetta il contratto di zServer. Si correggono nella voce R-173 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-1 | `JwtPayload` dichiara `displayname` e `role`, ma zServer emette `nominativo`, `ruolo` e `tipo_user` (ZSRV-AUT-002). Li leggono Agorà (`shared/services/auth.service.ts`) e GestyWeb (intestazione, home, anagrafica, cruscotto) | Al posto del nominativo compare il nome utente; nel cruscotto di GestyWeb il ruolo resta vuoto |
| DIV-2 | Un rinnovo rifiutato con 403 (utente non più attivo) o 500 non porta al login con un motivo: l'intercettore chiama l'uscita normale. Nella guardia, un rinnovo fallito non chiude la sessione, quindi ogni cambio di pagina riprova il rinnovo. I testi di zServer ("Utente non attivo", "Sessione invalidata per motivi di sicurezza") non arrivano all'utente | L'utente disattivato, o quello a cui è stato revocato il token per sospetto furto, torna al login senza sapere perché |
