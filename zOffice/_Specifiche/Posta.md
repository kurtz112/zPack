---
area: Posta
progetto: zOffice
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/004
---

# Posta

Questa specifica descrive come zOffice compone, invia e mostra la posta elettronica: la finestra di composizione, la risposta e l'inoltro di un messaggio salvato (`.eml`), la costruzione del messaggio con destinatari e allegati, la connessione al server SMTP con i parametri dell'applicazione, l'invio per la PEC con un identificativo proprio, e la lettura di un `.eml` con immagini e allegati. Il codice è in `zOffice\zOffice.Mail.Utils.pas` (`TzOfficeMailWriter` per l'invio, `TzOfficeMailReader` per la lettura), `zOffice.Mail.Editor.pas` (composizione), `zOffice.Mail.Form.pas` (lettura) e `zOffice.Mail.Frame.pas` (riquadro del visualizzatore multiplo); i record `TMail` e `TSMTPServerParams` e i punti d'ingresso `WriteMail`, `ViewFileMail`, `SendMail`, `CheckSMTPServerParams` stanno in `zOffice.types` e `zOffice.pas`. Lo usano WT (`dmGeDoEmail`, `dmRichieste`: composizione e lettura), Gesty (`dmAttrezzature`, `dmFrontOffice`, `dmRisorse`, `dmRiunioni`, `dmScheduler.Tools` per la composizione con la rubrica `Common.GetMailRisorse`; `dmOrientamento` e `WizInserimentoIncaricoDM` inviano direttamente con `TzOfficeMailWriter`), `zBase\zExceptions` (segnalazione degli errori) e `zDocumentale.Messaggi.Smtp` (PEC). La costruzione dell'handler TLS sta in `zNet.Tls`, fuori da questa specifica.

**Come funziona.** Chi vuole far scrivere un messaggio all'utente prepara un `TMail` e chiama `WriteMail`: la finestra si apre già compilata e, al comando Invia, controlla i campi, costruisce il `TMail` dal contenuto e lo passa a `TzOfficeMailWriter.SendMail`, che apre la connessione, si autentica, invia e chiude. Chi invia senza finestra chiama `SendMail` direttamente.

**Test che coprono quest'area.** Nessuna.

## ZOFF-MAI-001 Parametri del server
`TSMTPServerParams` porta mittente (`From` nome, `FromAddress` indirizzo), `ReplyTo`, `ReceiptRecipient`, server (`Host`, `Port`), credenziali, `AuthenticationType` (`N` nessuna, `D` predefinita, `S` SASL; un valore diverso vale nessuna), `ssl` (modalità TLS) e `ssl_ver` (versione TLS), tradotti da `zNet.Tls`. Dopo `Init` valgono `Port = -1`, `AuthenticationType = 'S'`, `ssl = 'N'`, `ssl_ver = '1'`. I parametri sono validi (`IsValid`) con host, porta diversa da -1, `ssl` e `ssl_ver` valorizzati; utente e password possono mancare. `CheckSMTPServerParams` solleva «Parametri SMTP non configurati.» se i parametri globali non sono validi.

### Scenario: porta non impostata
- **Dato** parametri con `Host` valorizzato e `Port = -1`
- **Quando** si chiama `CheckSMTPServerParams`
- **Allora** viene sollevata l'eccezione «Parametri SMTP non configurati.»

## ZOFF-MAI-002 Costruzione del messaggio
Da un `TMail` nasce un messaggio con: oggetto; mittente dai parametri; `ReplyTo` dai parametri; richiesta di conferma di lettura indirizzata a `ReceiptRecipient` se `ConfermaLettura` è vero; destinatari `A`, `CC`, `CCN` separati da `;` o `,`; struttura `multipart/mixed` in UTF-8 con una parte di testo semplice (`quoted-printable`) e una HTML (se `CorpoHtml` è vuoto, l'HTML è il testo con gli a capo trasformati in `<br>`); un allegato per ogni percorso di `Allegati` separato da `;`, saltando i vuoti; la priorità di `Priorita` (predefinita normale); un `Message-ID` fatto di un GUID seguito dal dominio del mittente.

### Scenario: corpo solo testo
- **Dato** un `TMail` con `CorpoTxt` di due righe e `CorpoHtml` vuoto
- **Quando** si costruisce il messaggio
- **Allora** la parte HTML contiene le due righe separate da `<br>`

### Scenario: destinatari con la virgola
- **Dato** `A = 'a@x.it,b@y.it'`
- **Quando** si costruisce il messaggio
- **Allora** i destinatari sono due

## ZOFF-MAI-003 Invio
`SendMail(mail, parametri)` costruisce il messaggio, si collega (tempo massimo di connessione 30 secondi, `EHLO`, TLS secondo i parametri, meccanismi SASL dal più sicuro al meno sicuro), si autentica e invia; restituisce vero solo se autenticazione e invio sono riusciti. La disconnessione avviene sempre, anche dopo un errore, che si propaga al chiamante. Gli scambi con il server finiscono nel registro (SmartInspect) e, se passata, nella funzione di registro del chiamante; la barra di avanzamento, se passata, segue connessione, autenticazione, invio e disconnessione.

### Scenario: server irraggiungibile
- **Dato** un host che non risponde
- **Quando** si chiama `SendMail`
- **Allora** l'errore di connessione arriva al chiamante e la barra si chiude

## ZOFF-MAI-004 Invio per la PEC
La seconda forma di `SendMail` imposta sul messaggio un `Message-ID` proprio, `<GUID@dominio del mittente>`, e lo restituisce al chiamante prima dell'invio: le ricevute del gestore PEC lo citano per riconoscere l'invio (`zDocumentale.Messaggi.Smtp`).

### Scenario: identificativo restituito
- **Dato** `FromAddress = 'protocollo@pec.ente.it'`
- **Quando** si invia con la forma PEC
- **Allora** `MessageId` vale `<…@pec.ente.it>` ed è lo stesso scritto nel messaggio

## ZOFF-MAI-005 Composizione
`WriteMail(mail, parametri, rubrica)` apre la finestra con mittente, destinatari, oggetto, corpo (l'HTML vince sul testo) e allegati del `TMail`; le righe CC, CCN e allegati si mostrano solo se hanno contenuto. La rubrica, se passata, riempie una lista di nomi `indirizzo=etichetta` proposti nei tre campi dei destinatari (senza etichetta si mostra l'indirizzo). Gli allegati si aggiungono da file, trascinandoli o con la finestra; eliminarne uno chiede conferma; un doppio clic lo apre.

### Scenario: rubrica di Gesty
- **Dato** la rubrica `Common.GetMailRisorse` con `mario.rossi@ente.it=Mario Rossi`
- **Quando** l'utente scrive nel campo A
- **Allora** gli viene proposto «Mario Rossi»

## ZOFF-MAI-006 Controlli prima dell'invio dalla finestra
Al comando Invia: senza alcun destinatario (A, CC e CCN vuoti) compare «Indirizzo non specificato.» e non si invia; oggetto vuoto e corpo vuoto chiedono ciascuno conferma («Oggetto non specificato. … Si desidera inviare il messaggio?», «Corpo messaggio non specificato. …»). Il messaggio inviato porta il corpo in HTML e in testo semplice e gli allegati elencati; dopo l'invio la finestra si chiude, mentre un errore la lascia aperta.

### Scenario: nessun destinatario
- **Dato** la finestra con A, CC e CCN vuoti
- **Quando** l'utente preme Invia
- **Allora** compare «Indirizzo non specificato.» e la finestra resta aperta

## ZOFF-MAI-007 Risposta e inoltro
Da un `.eml` la composizione parte con l'oggetto preceduto da `Re: ` (risposta) o `Fwd: ` (inoltro) e il corpo del messaggio originale (HTML se c'è). La risposta è indirizzata al mittente originale; l'inoltro parte senza destinatari e porta con sé gli allegati originali. Il visualizzatore mostra i comandi Rispondi e Inoltra solo se ammessi da `AllowedForwardingTypes` (predefiniti entrambi).

### Scenario: risposta
- **Dato** un `.eml` da `ufficio@ente.it` con oggetto `Richiesta`
- **Quando** l'utente preme Rispondi
- **Allora** la composizione ha A = `ufficio@ente.it` e oggetto `Re: Richiesta`

## ZOFF-MAI-008 Lettura di un messaggio salvato
`ViewFileMail` apre un `.eml` in sola lettura con mittente, destinatari, CC e CCN (le righe vuote nascoste), oggetto e data. Il corpo è l'unione delle parti `text/html`, oppure il testo semplice se non ce ne sono. Le immagini con un `Content-ID` si mostrano dentro il corpo (`cid:`) e non compaiono fra gli allegati; gli altri allegati sono elencati, e aprirne uno lo copia nella cartella temporanea con il nome originale, lo mostra e poi cancella la copia. Il riquadro del visualizzatore multiplo mostra mittente, oggetto, data, corpo e allegati con le stesse regole. Dal visualizzatore e dalla composizione si esporta il corpo in PDF scegliendo il file (cartella proposta `Documenti`, nome del messaggio), e alla fine si chiede se aprirlo.

### Scenario: immagine incorporata
- **Dato** un `.eml` con un logo `image/png` dal `Content-ID` `<logo1>` citato nel corpo
- **Quando** lo si apre
- **Allora** il logo compare nel corpo e l'elenco degli allegati non lo contiene

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-202 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-MAI-1 🟡 (dedotta) | L'invio dalla finestra ignora il valore restituito da `SendMail` e chiude la finestra comunque | Se l'autenticazione non riesce (`Authenticate` falso, senza eccezione) l'utente crede il messaggio partito |
| DIV-MAI-2 🟡 (dedotta) | Risposta e inoltro da `.eml` aggiungono gli allegati originali con il solo nome del file (`FileName`), non con il percorso in cui Indy li ha salvati; li aggiungono anche alla risposta | All'invio gli allegati non si trovano (o si allega un file omonimo della cartella corrente); la risposta porta allegati che non dovrebbe |
| DIV-MAI-3 🟡 (dedotta) | Anche l'inoltro precompila il destinatario con il mittente originale | Un inoltro confermato in fretta torna a chi aveva scritto |
| DIV-MAI-4 🟡 (dedotta) | Gli indirizzi non si ripuliscono: uno spazio dopo il separatore resta nell'indirizzo e un separatore finale produce un destinatario vuoto | Indirizzi come `a@x.it; b@y.it` o `a@x.it;` possono essere rifiutati dal server e far fallire l'intero invio |
| DIV-MAI-5 🟢 (dedotta) | «Apri con l'editor di sistema» del visualizzatore e della composizione salva prima il contenuto del controllo (`SaveDocument`) sul file corrente | Nel visualizzatore di un `.eml` in sola lettura il salvataggio non ha senso: può chiedere un nome o riscrivere il file nel formato del controllo |
| DIV-MAI-6 🟢 | Annulla durante l'invio non interrompe nulla (commento «TODO»), e la finestra di composizione non passa la propria barra a `SendMail`, che quindi non avanza | La barra resta ferma e il pulsante non serve |
| DIV-MAI-7 🟢 | `ClearFolder` non è implementata (commento «TODO»): gli allegati estratti da un `.eml` restano nella cartella temporanea | La cartella temporanea cresce a ogni messaggio letto |
| DIV-MAI-8 🟢 (dedotta) | Ogni `SendMail` crea un nuovo client SMTP e un nuovo handler TLS e libera solo l'ultimo alla distruzione dello scrittore | Riusare lo stesso scrittore in un ciclo (`dmOrientamento` di Gesty) tiene in memoria una connessione per messaggio fino alla fine |
