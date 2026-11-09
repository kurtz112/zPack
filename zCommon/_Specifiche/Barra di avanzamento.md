---
area: Barra di avanzamento
progetto: zCommon
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/021
---

# Barra di avanzamento

Questa specifica descrive la finestra di avanzamento con il pulsante Annulla: il componente `TProgressBox` (un `TCommonDialog` da mettere su un modulo dati o su una form) e la finestra `TProgressDlg` che lo rappresenta (`zCommon\zProgressBox.pas` e `zProgressBox.dfm`). La unit è compilata dal pacchetto `zCommon` (entra per `zCommon_Register`) e da `zDbView.Export`. La usano, dentro zPack, `zDbView.Export`, `zSystem`, `zSystemFrm`, gli editor dei moduli dati e `zOffice.Mail`; fuori, WT (91 file dichiarano un `TProgressBox`, quasi tutti moduli dati con il componente nel `.dfm`), Gesty (23 file), zTicser (4), ShareFood (2) e `WinSinfo`; il ciclo tipico è `Show(...)`, un `IncProgress` per ogni elemento, `Close` in un `finally`. Esiste anche `TDualProgressDlg` (due barre, usata da `dmPagoPA_EFIL`) e altri dialoghi di avanzamento in singole unit di WT e WinSinfo: sono unit diverse e non fanno parte di questa specifica. Il componente è registrato nella tavolozza (`zCommon`) da `zCommon_Register`.

**Come funziona.** `TProgressBox` tiene solo la configurazione e inoltra tutto a un `TProgressDlg` che crea subito (a meno che il componente sia in fase di progetto). La finestra, quando compare, disabilita tutte le altre finestre dell'applicazione e non si può chiudere con la X: si chiude solo con `Close` del componente o con Annulla dopo conferma. Quattro variabili globali di unità (`OnProgressBox_Show`, `OnProgressBox_Progress`, `OnProgressBox_Paused`, `OnProgressBox_Close`) permettono all'applicazione di agganciarsi: `ConfigModule` di WT, di Gesty e di zTicser le collega alla barra delle applicazioni di Windows (`TaskbarManager`). Il componente non interrompe mai il ciclo: segnala l'annullamento con `Cancelled` e sta al chiamante controllarlo.

**Test che coprono quest'area.** Il test `Test.zProgressBox` (registrato in `zPackTests` dal rilascio 021) prova senza mostrare la finestra: valori iniziali, inoltro delle proprietà, avanzamento e ganci, chiusura senza comparsa (ZCOMMON-PRG-001, 002, 004, 006, 007, 008). Restano senza prova, perché mostrano finestre o aprono un dialogo di conferma, `Show`, la disabilitazione delle altre finestre, il pulsante Annulla e la barra delle applicazioni (ZCOMMON-PRG-003, 005): si collaudano con la sonda `zapp` sul banco.

## ZCOMMON-PRG-001 Creazione e finestra interna
`TProgressBox.Create` crea subito il `TProgressDlg` (proprietario: il componente), perché il costruttore assegna `CancelEnabled := True` e ogni accesso alle proprietà passa dalla finestra (DIV-PRG-6); in fase di progetto (`csDesigning`) la finestra non esiste e ogni proprietà si limita a ricordare il valore. All'inizio: `Cancelled` falso, `Visible` falso, `CancelEnabled` vero, `MaxValue` e `Progress` zero. `ProgressDlg` è pubblica: le form la usano per toccare la barra (`ProgressDlg.ProgressBar.Properties.Marquee` in `HelpGen.Editor` di Gesty, per l'avanzamento indeterminato). `Visible` è vero solo se la finestra esiste ed è a video. Le proprietà pubblicate (`Caption`, `FirstLabel`, `SecondLabel`, `MaxValue`, `Progress`, `CancelEnabled`) si salvano nel `.dfm` del modulo e vengono rilette alla creazione del modulo.

### Scenario: componente nuovo
- **Dato** un `TProgressBox` creato in esecuzione
- **Quando** si leggono le proprietà
- **Allora** `Cancelled = False`, `Visible = False`, `CancelEnabled = True`, `MaxValue = 0`, `Progress = 0` e `ProgressDlg` è assegnata

### Scenario: proprietà del `.dfm`
- **Dato** un modulo dati con `ProgressBox` che nel `.dfm` ha `Caption = 'Scadenze'` e `CancelEnabled = True`
- **Quando** il modulo viene creato
- **Allora** la finestra interna ha il titolo `Scadenze` e il pulsante Annulla abilitato

## ZCOMMON-PRG-002 Configurazione: titolo, etichette, massimo, avanzamento, annullabilità
Ogni proprietà del componente passa subito alla finestra e si rilegge da lì. `Caption` è il titolo. `FirstLabel` e `SecondLabel` conservano il testo **intero**, mentre sulla finestra compare abbreviato con `MinimizeName` alla larghezza dell'etichetta (lo si usa per i percorsi di file: l'abbreviazione tiene la parte finale). Assegnare una `SecondLabel` non vuota rende visibile la seconda riga e ricalcola l'altezza della finestra (la barra e il pulsante scendono sotto la seconda riga); a nasconderla, quando è vuota, ci pensa solo la `Show` (ZCOMMON-PRG-003): assegnare una stringa vuota non la nasconde. `MaxValue` è anche il massimo della barra. `Progress` è la posizione; se supera `MaxValue` il valore si ricorda e la barra si ferma al massimo (DIV-PRG-2 corretta). `CancelEnabled` abilita o disabilita il pulsante Annulla e **resta** fra una `Show` e l'altra: chi lo spegne per un'operazione lo ritrova spento alla successiva (DIV-PRG-7). Impostare le proprietà prima di `Show` è il modo usato da `dmSimulazioni` (`Progress := 0`, `CancelEnabled := False`, `MaxValue := 14`, `Caption := 'Elaborazione tariffa'`, poi `Show`).

### Scenario: etichetta lunga
- **Dato** un testo di percorso più largo dell'etichetta
- **Quando** si assegna `FirstLabel`
- **Allora** `FirstLabel` restituisce il percorso intero e l'etichetta a video mostra la versione abbreviata

### Scenario: seconda riga
- **Dato** una finestra con la seconda etichetta nascosta
- **Quando** si assegna `SecondLabel := 'Attendere...'`
- **Allora** la seconda etichetta diventa visibile

### Scenario: avanzamento oltre il massimo
- **Dato** `MaxValue = 10` e `Progress = 4`
- **Quando** si assegna `Progress := 15`
- **Allora** `Progress` restituisce 15 e la posizione della barra va al massimo, 10

## ZCOMMON-PRG-003 Avvio (`Show`)
Tre forme: `Show` (usa quanto già impostato), `Show(Massimo, Titolo, Etichetta)` e `Show(Massimo, Titolo, Etichetta1, Etichetta2)`. Le forme con parametri impostano massimo, titolo e etichette, chiamano `OnProgressBox_Show(Massimo)` se assegnato, poi la `Show` semplice; **la `Show` senza parametri non chiama `OnProgressBox_Show`** (DIV-PRG-5). La `Show` semplice della finestra azzera `Cancelled` e il permesso di chiusura, porta `Progress` a 0, decide se mostrare la seconda riga (`SecondLabel` non vuota), ricalcola l'altezza e mostra la finestra, non modale: all'apparire `DoShow` disabilita tutte le altre finestre del processo (`DisableTaskWindows`) e `DoHide` le riabilita. Per questo `Config.InterfacciaOccupata` di WT e di Gesty riconosce una barra aperta guardando se la finestra principale è disabilitata.

### Scenario: avvio con parametri
- **Dato** un componente con un ciclo di 120 elementi
- **Quando** si chiama `Show(120, 'Consolidamento Accertamenti', 'Consolidamento Accertamenti', 'Attendere...')`
- **Allora** `MaxValue = 120`, `Progress = 0`, `Cancelled = False`, la finestra è a video e la finestra principale risulta disabilitata
- **E** `OnProgressBox_Show` è chiamato con 120

### Scenario: nuova esecuzione dopo un annullamento
- **Dato** un componente su cui l'utente ha annullato l'esecuzione precedente (`Cancelled = True`)
- **Quando** si chiama di nuovo `Show`
- **Allora** `Cancelled` torna falso

## ZCOMMON-PRG-004 Avanzamento (`IncProgress`)
`IncProgress` senza parametri aggiunge 1 a `Progress`; con una stringa imposta prima `FirstLabel`; con due stringhe imposta `FirstLabel` e `SecondLabel`; con un intero e due stringhe imposta le etichette e porta `Progress` a quel valore. Il valore **-1 significa «aggiungi 1»** e non si può usare come posizione (DIV-PRG-3). Ogni chiamata fa girare `Application.ProcessMessages` (è così che il pulsante Annulla e i disegni funzionano dentro un ciclo lungo) e poi chiama `OnProgressBox_Progress(Progress)` se assegnato. Nei cicli di WT la chiamata sta **all'inizio** di ogni giro: alla fine dell'ultimo giro la barra è piena prima che l'ultimo elemento sia stato elaborato.

### Scenario: incremento semplice
- **Dato** `MaxValue = 5` e `Progress = 0`
- **Quando** si chiama `IncProgress` due volte
- **Allora** `Progress = 2` e `OnProgressBox_Progress` è stato chiamato con 1 e poi con 2

### Scenario: valore esplicito
- **Dato** `Progress = 2`
- **Quando** si chiama `IncProgress(7, 'Fase 2', 'Verifica')`
- **Allora** `Progress = 7`, `FirstLabel = 'Fase 2'` e `SecondLabel = 'Verifica'`

### Scenario: -1 come incremento
- **Dato** `Progress = 3`
- **Quando** si chiama `IncProgress(-1, 'a', 'b')`
- **Allora** `Progress = 4`

## ZCOMMON-PRG-005 Annullamento
Il pulsante Annulla (`&Annulla`, sempre presente, abilitato da `CancelEnabled`) fa, nell'ordine: chiama `OnProgressBox_Paused` se assegnato; chiede `ConfirmYesNo('Si desidera terminare l''operazione')` e se la risposta è no ritorna senza altro; se è sì imposta `Cancelled := True`, consente la chiusura e chiude la finestra (come `Close`, ZCOMMON-PRG-006). La finestra **non interrompe il ciclo** e non solleva eccezioni: chi la usa deve controllare `Cancelled` a ogni giro e uscire (`dmWT_Import`, `dmGera_ExportSAP`, `zDbView.Export` con `Abort`). Annullare chiude comunque la finestra e riabilita le altre: un chiamante che non controlla `Cancelled` continua a lavorare con l'interfaccia di nuovo attiva (DIV-PRG-1). `Cancelled` si legge dal componente (falso se la finestra non esiste) e resta vero fino alla `Show` successiva.

### Scenario: annullamento confermato
- **Dato** una barra a video e un ciclo che controlla `Cancelled`
- **Quando** l'utente preme Annulla e conferma
- **Allora** `Cancelled = True`, la finestra si chiude, `OnProgressBox_Close` è chiamato e il ciclo esce al giro successivo

### Scenario: annullamento rifiutato
- **Dato** una barra a video
- **Quando** l'utente preme Annulla e risponde no
- **Allora** la finestra resta a video, `Cancelled` resta falso e `OnProgressBox_Paused` è stato chiamato una volta

## ZCOMMON-PRG-006 Chiusura (`Close`)
`TProgressBox.Close` chiude la finestra: consente la chiusura, la nasconde (`DoHide` riabilita le altre finestre), la chiude e chiama `OnProgressBox_Close` se assegnato. La chiamata è sempre eseguita senza errori, ma `OnProgressBox_Close` scatta **solo se la finestra era a video**: su una barra mai mostrata o già chiusa da Annulla non scatta (DIV-PRG-8 corretta); una chiusura ripetuta non riabilita altro, perché la finestra è già nascosta. La X della finestra, Alt+F4 e `Close` della finestra direttamente non la chiudono mai (`OnCloseQuery` risponde con il permesso di chiusura, falso finché non si arriva da `doClose`); la finestra non ha icone sul bordo. Lo schema d'uso è `Show` seguito da `try ... finally Close`.

### Scenario: chiusura senza comparsa
- **Dato** un componente su cui non si è mai chiamato `Show`
- **Quando** si chiama `Close`
- **Allora** non solleva eccezioni, `Visible` resta falso e `OnProgressBox_Close` non è chiamato

### Scenario: chiusura dopo Annulla
- **Dato** una finestra chiusa da Annulla
- **Quando** il chiamante, nel `finally`, chiama `Close`
- **Allora** `OnProgressBox_Close` non scatta una seconda volta

## ZCOMMON-PRG-007 Ganci verso l'applicazione
Le quattro variabili globali sono `TProc<integer>` (`OnProgressBox_Show` con il massimo, `OnProgressBox_Progress` con la posizione) e `TProc` (`OnProgressBox_Paused`, `OnProgressBox_Close`); valgono `nil` finché l'applicazione non le imposta e sono comuni a **tutti** i componenti del processo. WT, Gesty e zTicser le impostano in `ConfigModule` per inoltrarle a `TaskbarManager` (`ProgressBox_Start`, `ProgressBox_Progress`, `ProgressBox_Paused`, `ProgressBox_Stop`): la barra delle applicazioni mostra l'avanzamento, la pausa durante la conferma di Annulla e torna a «nessuno stato» alla chiusura. Un gancio non assegnato non è un errore.

### Scenario: nessun gancio
- **Dato** le quattro variabili a `nil`
- **Quando** si esegue un ciclo con `IncProgress` e `Close`
- **Allora** non succede niente di diverso dalla sola barra

## ZCOMMON-PRG-008 Avanzamento percentuale e interfaccia `IcxProgress`
`TProgressDlg` implementa `IcxProgress` (la usano le esportazioni di DevExpress): `OnProgress(Sender, Percent)` porta la percentuale al `MaxValue` del componente (`Progress := Percent * MaxValue / 100`, DIV-PRG-4 corretta). Con `MaxValue` 100, come fa `zDbView.Export` con `Show(100, ...)`, la posizione coincide con la percentuale; con `MaxValue` zero la posizione resta zero.

### Scenario: percentuale con massimo 100
- **Dato** `MaxValue = 100`
- **Quando** la finestra riceve `OnProgress(nil, 40)`
- **Allora** `Progress` del componente vale 40 e la barra è al 40%

### Scenario: percentuale con un altro massimo
- **Dato** `MaxValue = 200`
- **Quando** la finestra riceve `OnProgress(nil, 40)`
- **Allora** `Progress` vale 80

## Divergenze note
Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `zProgressBox.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-PRG-1 🟡 (dedotta) | Il pulsante Annulla è abilitato di default (`CancelEnabled = True` nel `.dfm` di ogni modulo) ma molte unit chiamano `Show`, `IncProgress` e `Close` senza mai leggere `Cancelled` (per esempio `dmGeDoEmail` con 11 `Show`, `dmAccertamenti`, `dmRC_Emissioni`, `dmRecuperoCrediti`); la finestra, annullata, si chiude comunque (righe 142-155, 191-199) | L'utente conferma «terminare l'operazione», la barra sparisce e le altre finestre si riabilitano, ma il ciclo (invio di mail, consolidamento di accertamenti) continua in secondo piano: l'operazione non finisce e l'interfaccia è di nuovo cliccabile |
| DIV-PRG-2 ✅ (corretta, rilascio 021) | `SetProgress` ricordava il valore ma aggiornava la barra solo se `Value <= MaxValue`. Ora oltre il massimo porta la barra al massimo | Con `Progress` oltre il massimo la barra si ferma al massimo; `Progress` legge ancora il valore assegnato. Prova `Progress_OltreIlMassimo_*` capovolta |
| DIV-PRG-3 🟢 (dedotta) | `IncProgress(aProgress = -1)` usa -1 come «incrementa» (220-232), e la forma con intero e due stringhe la usa allo stesso modo (247-252) | Non si può impostare la posizione -1; chi passa un indice calcolato che può valere -1 ottiene un incremento |
| DIV-PRG-4 ✅ (corretta, rilascio 021) | `OnProgress(Percent)` assegnava la percentuale come posizione senza riportarla al `MaxValue`. Ora usa `MulDiv(Percent, MaxValue, 100)` | Con un massimo diverso da 100 la barra segna l'avanzamento giusto; l'unico chiamante (`zDbView.Export`) usa 100 e non cambia. Prova `Divergenza_DIV_PRG_4_*` |
| DIV-PRG-5 🟢 (dedotta) | `Show` senza parametri (346-349) non chiama `OnProgressBox_Show` mentre `IncProgress` chiama `OnProgressBox_Progress` (230-231); la forma usata da `dmSimulazioni`, `dmTariffe`, `dmGeDoRaccomandate` e `dmFTP` di Gesty | La barra delle applicazioni non parte da zero con il massimo giusto: `TaskbarManager` confronta `Progress < MaxValue` con il massimo del giro precedente |
| DIV-PRG-6 🟡 (dedotta) | I controlli «se esiste la finestra» usano la proprietà `ProgressDlg` (`assigned(ProgressDlg)` righe 334, 342, 365, 373, 381, 389, 402, 410, 418) e non il campo `FProgressDlg`: la proprietà crea la finestra al primo accesso (422-435), e il costruttore la crea subito (327) | La creazione «a richiesta» voluta dal commento (`// zz 05.03.2019`) non avviene mai: ogni modulo dati con un `TProgressBox` (decine in WT e in Gesty) costruisce all'avvio una form DevExpress completa anche se la barra non si userà; i campi `FMaxValue` e `FProgress` del componente sono copie inutili |
| DIV-PRG-7 🟢 (dedotta) | `CancelEnabled` non viene rimesso a vero da `Show` (292-302); `dmBD_ImportBancheDati` lo spegne in tre punti e non lo riaccende | Nello stesso modulo le operazioni successive mostrano la barra con Annulla spento senza che nessuno l'abbia deciso |
| DIV-PRG-8 ✅ (corretta, rilascio 021) | `doClose` chiamava sempre `OnProgressBox_Close`, anche se la barra non era mai comparsa o era già chiusa. Ora il gancio scatta solo se la finestra era a video | Il gancio verso la barra delle applicazioni non scatta più a vuoto. Prove `Close_*` aggiornate |
