---
area: Messaggi PEC via SMTP
progetto: zDocumentale
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Messaggi PEC via SMTP

Questa specifica descrive il fornitore PEC standard di zPack, `TzMessaggioSmtpProvider` in `zDocumentale\zDocumentale.Messaggi.Smtp.pas`: invia i messaggi con SMTP cifrato attraverso `TzOfficeMailWriter` (`zOffice.Mail.Utils`) e legge le ricevute PEC con IMAP dalla casella del mittente. Il contratto comune dei fornitori (registro, eccezioni, registro tecnico, configurazione) è in `Motore documentale multi-fornitore.md` (ZDOC-MOT). La unit entra nei programmi attraverso `zDocumentale.Providers`, elencata in `WinTarif3.dpr` e `Gesty.dpr`; la usano i ponti `Documentazione.Bridge.Messaggi` di WT e di Gesty (e la copia di zTicser). Il commento della unit la destina al pacchetto zOffice, perché dipende da `zOffice.Mail.Utils`; oggi sta in `zDocumentale\` e non è in nessun `.dpk`.

**Come funziona.** Il ponte registra la spedizione nello stato `P` **prima** di chiamare `Invia`, così un invio ripetuto non crea doppioni; il fornitore spedisce e restituisce il Message-ID. Più tardi il ponte chiama `LeggiRicevute` con i Message-ID in attesa: il fornitore scorre la cartella IMAP, riconosce le ricevute PEC, salva ognuna come `.eml` temporaneo e le restituisce; il ponte trasforma i file in versioni `RIC` della catena `OBJ_FILES`, applica gli stati con `OBJ_FILES_MAIL_E_MESSAGGI_RICEVUTA_ADD` (che assorbe i duplicati) e cancella i temporanei. Il fornitore non tocca mai il database.

**Test che coprono quest'area.** Nessuna.

## ZDOC-PEC-001 Nome e funzionalità
Il fornitore si registra come `SMTP` e dichiara `Funzionalita = [pecInvia, pecLeggiRicevute]`; non dichiara `pecVerificaConsegna`.

### Scenario: creazione dal nome
- **Dato** un programma che include `zDocumentale.Providers`
- **Quando** si chiama `TzMessaggioFactory.Crea('SMTP')`
- **Allora** il fornitore ha `Nome = 'SMTP'` e `Funzionalita = [pecInvia, pecLeggiRicevute]`

## ZDOC-PEC-002 Parametri e valori predefiniti
Utente e password servono sia per SMTP sia per IMAP; l'indirizzo del mittente è `IndirizzoMittente` della configurazione. Gli altri valori sono parametri (`OBJ_FILES_MAIL_E_MESSAGGI_CONFIG_PARAMETRI`):

| Parametro | Predefinito | Regola |
|---|---|---|
| `SMTP_HOST` | nessuno | obbligatorio: se vuoto `PEC: parametro SMTP_HOST non configurato` |
| `SMTP_PORT` | `465` | un valore non numerico vale il predefinito |
| `SMTP_SSL` | `S` | `S` = cifratura implicita (codice `I` passato a `TzOfficeMailWriter`), ogni altro valore = nessuna cifratura (`N`) |
| `SMTP_SSL_VERSIONE` | `TLSv1_2` | passato così com'è |
| `SMTP_AUTENTICAZIONE` | `LOGIN` | passato così com'è |
| `IMAP_HOST` | nessuno | obbligatorio: se vuoto `PEC: parametro IMAP_HOST non configurato` |
| `IMAP_PORT` | `993` | un valore non numerico vale il predefinito |
| `IMAP_SSL` | `S` | `S` = TLS 1.2 implicito, ogni altro valore = connessione in chiaro |
| `IMAP_CARTELLA` | `INBOX` | cartella dove arrivano le ricevute |

Per i parametri sì/no conta solo `S` (maiuscolo o minuscolo); il predefinito vale solo quando la chiave manca (DIV-PEC-4).

### Scenario: porta non indicata
- **Dato** una configurazione con `SMTP_HOST` e senza `SMTP_PORT`
- **Quando** il fornitore invia
- **Allora** usa la porta 465 con cifratura implicita

### Scenario: server di posta mancante
- **Dato** una configurazione senza `IMAP_HOST`
- **Quando** si chiama `TestConnessione` o `LeggiRicevute`
- **Allora** si ottiene `EzMessaggioErrore` con `PEC: parametro IMAP_HOST non configurato`

## ZDOC-PEC-003 Prova della connessione
`TestConnessione` apre e chiude la connessione IMAP con le credenziali configurate. L'invio SMTP non ha una stretta di mano separabile e non viene provato: una configurazione SMTP sbagliata emerge solo al primo invio.

### Scenario: casella raggiungibile
- **Dato** un server IMAP raggiungibile e credenziali corrette
- **Quando** si chiama `TestConnessione`
- **Allora** la chiamata termina senza eccezioni, qualunque sia la configurazione SMTP

## ZDOC-PEC-004 Controlli prima dell'invio
`Invia` mette i destinatari di tipo `pdDestinatario` nel campo «A» e quelli `pdCopiaConoscenza` in «CC», separati da `;`. Prima di qualunque collegamento verifica che:
- ci sia almeno un destinatario principale, altrimenti `PEC: nessun destinatario principale`;
- ogni allegato abbia un percorso e il file esista, altrimenti `PEC: allegato non trovato: "<percorso>"`.

Il corpo viene spedito come testo semplice. Il mittente del messaggio è `IndirizzoMittente`.

### Scenario: solo destinatari in copia
- **Dato** un messaggio con un solo destinatario di tipo `pdCopiaConoscenza`
- **Quando** si chiama `Invia`
- **Allora** si ottiene `EzMessaggioErrore` con `PEC: nessun destinatario principale` e nessuna connessione al server

### Scenario: allegato sparito
- **Dato** un allegato il cui `FullFileName` non esiste su disco
- **Quando** si chiama `Invia`
- **Allora** si ottiene `PEC: allegato non trovato: "<FullFileName>"`

## ZDOC-PEC-005 Esito dell'invio e registro
Prima dell'invio il fornitore annota la richiesta con operazione `INVIO`, punto di arrivo `<host>:<porta>` e testo `A: <destinatari> CC: <copie> Oggetto: <oggetto>` (la parte `CC` solo se ci sono copie). Se il server rifiuta l'invio (`SendMail` falso) solleva `PEC: il server SMTP ha rifiutato l'invio`; ogni eccezione dell'invio viene annotata come risposta con il messaggio d'errore e poi rilanciata. Se l'invio riesce annota `Message-ID: <id>` e restituisce `Ok = True`, `Stato = 'I'` (inviata, in attesa delle ricevute), `StatoEsterno = 'Inviata al gestore'` e il `MessageId`. Il codice HTTP annotato è sempre 0.

### Scenario: invio riuscito
- **Dato** un messaggio valido e un server SMTP che accetta
- **Quando** si chiama `Invia`
- **Allora** l'esito ha `Stato = MESSAGGIO_STATO_INVIATA` e il registro ha una richiesta `INVIO` con la risposta `Message-ID: ...`

### Scenario: server che rifiuta
- **Dato** un server SMTP che rifiuta il messaggio
- **Quando** si chiama `Invia`
- **Allora** il registro ha la risposta con l'errore e il chiamante riceve `EzMessaggioErrore`

## ZDOC-PEC-006 Lettura delle ricevute
`LeggiRicevute` si collega alla casella IMAP, seleziona `IMAP_CARTELLA` (se non ci riesce: `PEC: cartella IMAP "<cartella>" non selezionabile`) e scarica **tutti** i messaggi della cartella a ogni chiamata, senza filtri per data o per messaggi non letti e senza segnarli né cancellarli. I messaggi che non si riescono a scaricare vengono saltati. Il registro annota l'operazione `RICEVUTE` con `Cartella: <cartella>` e, alla fine, `Ricevute trovate: <n>`; un errore viene annotato e rilanciato. La connessione viene sempre chiusa.

### Scenario: casella con messaggi qualunque
- **Dato** una cartella con tre ricevute PEC e due messaggi ordinari
- **Quando** si chiama `LeggiRicevute` con l'elenco vuoto
- **Allora** il risultato contiene le tre ricevute e il registro dice `Ricevute trovate: 3`

## ZDOC-PEC-007 Riconoscimento delle ricevute
Un messaggio è una ricevuta se ha un tipo di ricevuta e il Message-ID del messaggio originale. Il tipo si legge dall'intestazione `X-Ricevuta`, il riferimento da `X-Riferimento-Message-ID`; solo se manca uno dei due si cerca l'allegato `daticert.xml` e se ne leggono l'attributo `tipo` di `<postacert>`, il contenuto di `<msgid>` e quello di `<consegna>`. La corrispondenza dei tipi è:

| Tipo letto | Ricevuta |
|---|---|
| `accettazione` | `prAccettazione` |
| `avvenuta-consegna` | `prConsegna` |
| `non-accettazione` | `prNonAccettazione` |
| `errore-consegna`, `rilevazione-virus` | `prMancataConsegna` |
| `preavviso-errore-consegna` e ogni altro | ignorata, perché non definitiva |

`DataOra` è la data del messaggio di ricevuta.

### Scenario: preavviso di mancata consegna
- **Dato** un messaggio con `X-Ricevuta: preavviso-errore-consegna`
- **Quando** si leggono le ricevute
- **Allora** il messaggio non compare nel risultato

### Scenario: intestazioni mancanti
- **Dato** una ricevuta senza `X-Ricevuta` ma con `daticert.xml` che riporta `<postacert tipo="avvenuta-consegna">` e `<msgid>`
- **Quando** si leggono le ricevute
- **Allora** la ricevuta è `prConsegna` con il Message-ID letto da `<msgid>`

## ZDOC-PEC-008 Destinatario della ricevuta
Per le ricevute di consegna e mancata consegna `IndirizzoDestinatario` viene da `<consegna>` di `daticert.xml` quando l'allegato è stato letto; altrimenti è il primo destinatario («A») del messaggio di ricevuta. Per le ricevute di accettazione resta vuoto (salvo che lo dia `daticert.xml`). Vedi DIV-PEC-1.

### Scenario: ricevuta di accettazione
- **Dato** una ricevuta `accettazione` con le intestazioni complete
- **Quando** si leggono le ricevute
- **Allora** `IndirizzoDestinatario` è vuoto

## ZDOC-PEC-009 Filtro per Message-ID
Se l'elenco dei Message-ID richiesti non è vuoto, si restituiscono solo le ricevute che si riferiscono a uno di essi. Il confronto ignora spazi ai bordi, parentesi angolari e maiuscole. Con l'elenco vuoto si restituiscono tutte le ricevute della cartella.

### Scenario: parentesi angolari diverse
- **Dato** una ricevuta con `X-Riferimento-Message-ID: <ABC@pec.it>`
- **Quando** si chiama `LeggiRicevute(['abc@pec.it'])`
- **Allora** la ricevuta compare nel risultato

## ZDOC-PEC-010 File della ricevuta
Ogni ricevuta restituita è salvata per intero (è il documento firmato dal gestore) in un file temporaneo con estensione `.eml`, il cui percorso sta in `FileRicevuta`. Il fornitore non lo cancella: è compito del ponte, dopo averlo registrato come versione `RIC`.

### Scenario: ricevuta trovata
- **Dato** una ricevuta di consegna nella cartella
- **Quando** si leggono le ricevute
- **Allora** `FileRicevuta` punta a un file `.eml` esistente nella cartella temporanea

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-PEC-1 🟡 (dedotta) | Nelle ricevute PEC conformi le intestazioni `X-Ricevuta` e `X-Riferimento-Message-ID` ci sono sempre, quindi `daticert.xml` non viene mai letto e il destinatario della consegna diventa il primo «A» della ricevuta, che per lo standard PEC è la casella del mittente, non il destinatario originale | Con più destinatari principali le consegne non si distinguono per destinatario: lo stato `C` («consegna per tutti i destinatari principali») può essere calcolato male dal ponte |
| DIV-PEC-2 🟡 (dedotta) | Il nome del temporaneo è `TPath.ChangeExtension(TPath.GetTempFileName, '.eml')`: `GetTempFileName` crea su disco un file `.tmp` vuoto che resta orfano, perché si scrive in un file con un altro nome | Poiché ogni lettura riscarica tutte le ricevute (ZDOC-PEC-006), a ogni passaggio si accumulano file `.tmp` vuoti; Windows rifiuta nuovi nomi temporanei oltre 65.535 file `tmp*.tmp` nella stessa cartella, e da lì `LeggiRicevute` fallisce sempre |
| DIV-PEC-3 🟢 | La cartella IMAP viene riletta per intero a ogni lettura (il commento lo indica come ottimizzazione futura) | Con una casella che accumula migliaia di messaggi ogni passaggio scarica tutto: tempi e traffico crescono senza limite |
| DIV-PEC-4 🟢 | I parametri sì/no riconoscono solo `S`: `SI`, `1` o `TRUE` valgono «no» | Un valore scritto in modo diverso spegne la cifratura senza avviso: la connessione fallisce sulle porte cifrate o, su porte in chiaro, le credenziali viaggiano non cifrate |
