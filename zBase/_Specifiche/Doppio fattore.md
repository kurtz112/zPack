---
area: Doppio fattore
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/007
---

# Doppio fattore

Questa specifica descrive il secondo fattore dell'accesso: il codice via mail e l'app di autenticazione (TOTP, RFC 6238) con i codici di recupero. In zPack il codice sta in tre punti: `zBase\zTotp.pas` (casualità del segreto e dei codici di recupero, codifica base32), `zBase\zTotp.Dialogs.pas` (finestre senza DFM: codice all'accesso, registrazione con il QR, codici di recupero) e `zBase\zSystem.pas` (metodi di `TzSecurity`: `SecondoFattoreVerifica`, `OTP_*`, `Totp*`). Il calcolo e la verifica dei codici, la cifratura del segreto e il blocco dopo troppi errori stanno nel database, nelle procedure `USR_TOTP_*` consegnate con i rilasci `OUT/20261016-secondo-fattore-totp-wt/001` e `002` (WT) e `OUT/20261017-secondo-fattore-totp-gesty/001` (Gesty). WT e Gesty offrono nel menu principale (`MainForm.pas`) la registrazione dell'app e la rigenerazione dei codici, visibili solo se `TotpDisponibile`, e in `dmGestioneUtenti.pas` l'azzeramento dell'app di un utente da parte dell'amministratore. Le unit `zTotp` e `zTotp.Dialogs` non le usa direttamente nessun programma: passano da `zSystem`. Descrive il comportamento atteso, non il codice.

**Come funziona.** Se `USR_LOGIN` risponde `OTP = TRUE`, la sessione resta in attesa e `Login` chiama `SecondoFattoreVerifica`. Senza app attiva il programma fa generare e spedire un codice via mail (`USR_GENERA_TOKEN_OTP`) e lo chiede finché il database non lo accetta (`USR_VERIFICA_TOKEN_OTP`); a codice giusto propone di registrare l'app. Con l'app attiva chiede il codice di 6 cifre o un codice di recupero nello stesso campo (`USR_TOTP_VERIFICA`), con la mail come riserva. Il client genera solo il segreto e i codici di recupero, con la sorgente casuale di Windows che Firebird non offre; il database li cifra (segreto, AES-256 in modalità CTR) o ne conserva solo l'impronta (codici di recupero, SHA-256).

**Test che coprono quest'area.** Nessuna in `zPack\_UnitTest\_src`. Il calcolo dei codici è stato provato nel database con i vettori delle RFC 2202, 4226 e 6238 durante il collaudo del rilascio WT (`OUT\20261016-secondo-fattore-totp-wt\collaudo\`), fuori da questa libreria.

## ZBASE-TOT-001 Quando si chiede il secondo fattore
Il secondo fattore si chiede solo se `USR_LOGIN` restituisce il parametro `OTP` a vero; sui database che non hanno il parametro non si chiede. Fino al codice giusto la sessione del database resta in attesa e i permessi di sistema non si leggono. Qualunque errore durante la verifica (mail non spedita, errore del database) mostra «Verifica in due passaggi non riuscita: ...» e conta come verifica fallita: l'accesso viene annullato prima di autorizzazioni, azioni automatiche e `AfterLogin`, e il programma si chiude (vedi `Accesso e password.md`, ZBASE-ACC-001).

### Scenario: server di posta irraggiungibile
- **Dato** un utente senza app e il server SMTP spento
- **Quando** parte la verifica
- **Allora** compare il messaggio di verifica non riuscita e l'accesso viene annullato

## ZBASE-TOT-002 Codice via mail
`USR_GENERA_TOKEN_OTP(ID_SESSIONE)` crea il codice e restituisce mittente, server SMTP con le sue credenziali, destinatario, oggetto e corpo (testo e HTML): il client spedisce la mail con questi dati e poi chiede «Token:» in una finestra. Un codice sbagliato mostra il messaggio del database e richiede il codice; l'utente esce solo con il codice giusto o rinunciando. Il client non pone un limite ai tentativi.

### Scenario: codice sbagliato e poi giusto
- **Dato** la mail con il codice ricevuta
- **Quando** l'utente digita prima un codice sbagliato e poi quello giusto
- **Allora** vede il messaggio di errore del database, poi l'accesso prosegue

## ZBASE-TOT-003 Disponibilità dell'app sul database
`TotpDisponibile` è vero solo se il database ha la funzione `USR_TOTP_DISPONIBILE` (controllata in `RDB$FUNCTIONS` prima di chiamarla) e questa risponde vero, cioè se la chiave di cifratura dei segreti è stata impostata. Il risultato si calcola una volta per accesso. `TotpAttivo` legge `USR_TOTP_STATO.ATTIVO` dell'utente collegato ed è falso se l'app non è disponibile.

### Scenario: database senza chiave
- **Dato** un database con le procedure TOTP ma senza chiave in `USR_CHIAVI_CIFRATURA`
- **Quando** si chiede `TotpDisponibile`
- **Allora** è falso e il menu non offre la registrazione

## ZBASE-TOT-004 Segreto dell'app
Il segreto è di 20 byte (`TotpLunghezzaSegretoByte`, 160 bit, la lunghezza consigliata dalla RFC 4226), presi da `BCryptGenRandom` con il generatore preferito dal sistema. Se Windows non risponde si solleva un'eccezione: un segreto debole non si genera mai al suo posto. Il segreto si codifica in base32 della RFC 4648 (alfabeto `A-Z` e `2-7`) senza i caratteri `=` di riempimento, la forma attesa dalle app nel parametro `secret`; per l'inserimento a mano si mostra a gruppi di quattro caratteri separati da spazi. Il buffer dei byte si azzera subito dopo la codifica.

### Scenario: lunghezza del segreto
- **Dato** la generazione di un segreto nuovo
- **Quando** si chiama `GeneraSegretoTotp`
- **Allora** il risultato ha 32 caratteri base32 (160 bit / 5)

### Scenario: codifica base32
- **Dato** i byte del testo `foobar`
- **Quando** si chiama `Base32Codifica`
- **Allora** il risultato è `MZXW6YTBOI`, come nel vettore della RFC 4648 senza riempimento

### Scenario: presentazione a gruppi
- **Dato** il segreto `JBSWY3DPEHPK3PXP`
- **Quando** si chiama `SegretoAGruppi`
- **Allora** il risultato è `JBSW Y3DP EHPK 3PXP`

## ZBASE-TOT-005 Registrazione dell'app
`TotpRegistra` rifiuta con un messaggio se l'app non è prevista sul database o se è già attiva («va prima azzerata dall'amministratore»). Altrimenti genera il segreto e lo passa a `USR_TOTP_REGISTRA`, che lo cifra e restituisce l'indirizzo `otpauth://` (emittente lasciato al database). La finestra mostra il QR (modalità byte, correzione M), la chiave a gruppi e chiede il primo codice di 6 cifre: solo quando `USR_TOTP_ATTIVA` lo accetta l'app diventa attiva; un rifiuto lascia la finestra aperta con il messaggio del database. Ogni passo si conferma subito nel database, in una transazione propria se nessuna è aperta. Un'app registrata e non attivata resta in sospeso e la registrazione successiva la sostituisce. Ad attivazione riuscita si generano i codici di recupero (ZBASE-TOT-007).

### Scenario: primo codice sbagliato
- **Dato** la finestra di registrazione con il QR inquadrato
- **Quando** l'utente digita un codice che il database rifiuta
- **Allora** la finestra resta aperta con il messaggio e l'app non è attiva

### Scenario: app già attiva
- **Dato** un utente con l'app attiva
- **Quando** sceglie di registrarne un'altra
- **Allora** riceve il messaggio che va prima azzerata dall'amministratore

## ZBASE-TOT-006 Codice all'accesso con l'app
Con l'app attiva la finestra chiede il codice di 6 cifre dell'app o, nello stesso campo, un codice di recupero (il campo converte in maiuscolo e accetta fino a 30 caratteri). Campo vuoto: «Digitare il codice.» senza interrogare il database. La verifica la fa `USR_TOTP_VERIFICA(ID_SESSIONE, CODICE, RAISE_ERROR = FALSE)`: il messaggio d'errore restituito resta nella finestra, che rimane aperta per un altro tentativo; un messaggio vuoto diventa «Codice non valido.». «Non ho il telefono» passa al codice via mail (ZBASE-TOT-002); Annulla chiude l'accesso.

Nel database, che il client presuppone: il codice è un HOTP (RFC 4226: HMAC-SHA1 sul contatore di 8 byte con il più significativo per primo, troncamento dinamico sui 4 bit bassi dell'ultimo byte, 31 bit, modulo 10^6) con il contatore TOTP dei secondi UTC dall'1/1/1970 diviso 30 (RFC 6238); si accettano l'intervallo corrente, il precedente e il successivo; un codice di un intervallo uguale o precedente all'ultimo accettato è rifiutato come «già usato»; il blocco scatta dopo `ACCESSO_MAX_TENTATIVI` errori (predefinito 3) in `ACCESSO_MINUTI_BLOCCO` minuti (predefinito 15), contando password, codici errati e codici già usati.

### Scenario: codice dell'app giusto
- **Dato** un utente con l'app attiva
- **Quando** digita il codice di 6 cifre corrente
- **Allora** la sessione diventa valida e l'accesso prosegue

### Scenario: stesso codice usato due volte
- **Dato** un codice appena accettato
- **Quando** lo si digita di nuovo nello stesso intervallo di 30 secondi
- **Allora** la finestra mostra «Codice gia' usato: attendere il codice successivo dell'app.»

### Scenario: telefono dimenticato
- **Dato** la finestra del codice
- **Quando** l'utente preme «Non ho il telefono»
- **Allora** riceve il codice via mail e lo digita nella finestra del codice via mail

## ZBASE-TOT-007 Codici di recupero
Si generano 10 codici (`TotpNumeroCodiciRecupero`) di 16 caratteri (`TotpLunghezzaCodiceRecupero`) nella forma `XXXX-XXXX-XXXX-XXXX`, su un alfabeto di 31 simboli che esclude i caratteri confondibili su carta (`0`, `O`, `1`, `I`, `L`): circa 79 bit ciascuno. Ogni carattere viene da un byte casuale di `BCryptGenRandom`, scartando i valori oltre il multiplo più alto dell'alfabeto, così nessun simbolo esce più spesso degli altri. I codici si salvano con `USR_TOTP_CODICI_RECUPERO_IMPOSTA` (che cancella i precedenti e ne conserva solo l'impronta) e **solo dopo** il salvataggio si mostrano, una volta sola: la finestra non si chiude finché l'utente non spunta «Ho conservato i codici in un posto sicuro» e offre il pulsante Copia. Ogni codice vale una volta. `TotpRigeneraCodiciRecupero` chiede conferma («Quelli di prima non varranno piu'») e richiede l'app attiva.

### Scenario: forma dei codici
- **Dato** la generazione dei codici
- **Quando** si chiama `GeneraCodiciRecupero`
- **Allora** escono 10 codici di 19 caratteri con tre trattini, senza `0`, `O`, `1`, `I`, `L`

### Scenario: chiusura senza conferma
- **Dato** la finestra dei codici di recupero aperta
- **Quando** l'utente prova a chiuderla senza spuntare la casella
- **Allora** la finestra resta aperta e la casella diventa rossa

## ZBASE-TOT-008 Avviso dopo un codice di recupero
Se l'accesso è avvenuto con un codice di recupero, il programma dice quanti ne restano. Con 3 o più rimasti è solo un avviso che invita a chiedere l'azzeramento se il telefono è perso; con meno di 3 propone di generarne di nuovi subito, e un errore nella generazione non blocca l'accesso.

### Scenario: ultimi codici
- **Dato** un utente che entra con un codice di recupero e ne ha 2 rimasti
- **Quando** l'accesso si conclude
- **Allora** il programma propone di generare nuovi codici

## ZBASE-TOT-009 Proposta di registrazione e azzeramento
Chi entra con il codice via mail su un database dove l'app è disponibile riceve la proposta di attivarla: è il momento sicuro, perché ha appena dimostrato di avere sia la password sia la casella di posta. Rinunciare («Piu' tardi») o un errore nella registrazione non bloccano l'accesso. `TotpAzzera(UserID)` cancella app e codici di recupero di un utente con `USR_TOTP_AZZERA`, che lo consente solo all'amministratore e registra chi l'ha fatto.

### Scenario: proposta rifiutata
- **Dato** un utente senza app che ha appena confermato il codice via mail
- **Quando** risponde no alla proposta
- **Allora** l'accesso prosegue normalmente

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-200 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Il calcolo del codice è stato riletto nello script `WT-TOTP-SECONDO-FATTORE-E-BLOCCO.sql` del rilascio WT 001 ed è conforme alle RFC 4226 e 6238; il confronto del codice nel database non è a tempo costante, ma con 6 cifre, finestra di tre intervalli e blocco dopo 3 errori non dà un vantaggio misurabile, quindi non è riportato come divergenza.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-TOT-5 🟢 (dedotta) | Il segreto base32 (stringa), l'indirizzo `otpauth://` e i buffer casuali sostituiti durante la generazione dei codici non vengono azzerati, a differenza del buffer del segreto | Il segreto resta più a lungo nella memoria del processo di quanto il commento «non resta in memoria piu' del necessario» lasci intendere. Lasciata documentata (rilascio `OUT/20261101-specifiche-vive-zpack/012`): le stringhe di Delphi non si azzerano in modo affidabile (contate e condivise) e il segreto sta comunque in memoria mentre il codice è valido |
