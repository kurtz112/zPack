---
area: Finestre di dialogo
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Finestre di dialogo

Questa specifica descrive le finestre di conferma e di input che WT e Gesty usano per fare domande all'utente: `ConfirmOk`, `ConfirmYesNo`, `ConfirmOkCancel`, `ConfirmYesNoCancel` e `Confirm` per le conferme; `InputString`, `InputPassword`, `InputInteger`, `InputInt64`, `InputDouble`, `InputCurrency`, `InputDate`, `InputCombo`, `InputMemo` per i valori; `AssegnaCarattere` e `AltezzaCarattere` per il carattere delle finestre costruite in codice. Il codice è in `zBase\zMsg.pas` (classe `TInputDialog`, basata su `TdxRibbonForm`, e funzioni libere), con le finestre di conferma di DevExpress (`dxMessageDialog`). La unit è elencata nei `.dpr` di WT e di Gesty ed è usata, per numero di file con la riga nell'`uses`, da 279 file di WT, 91 di Gesty e 86 di zPack (copie di lavoro comprese). Conteggio per righe di chiamata nei sorgenti di WT, Gesty e zPack (escluse le copie di lavoro): `ConfirmOk` circa 1030, `ConfirmYesNo` circa 660, `ConfirmOkCancel` 22, `ConfirmYesNoCancel` 22, `Confirm` diretta 13, `InputDate` 76 (tre delle quali con intervallo, in `dmCommon.pas` di WT), `InputString` 33, `InputCombo` 23, `InputInteger` 16, `InputPassword` 6, `InputMemo` 5, `InputDouble` 4, `InputInt64` 3, `InputCurrency` nessuna; `TInputDialog` si usa direttamente in 15 righe (per la richiamata `proc`). `AssegnaCarattere` e `AltezzaCarattere` le usano `TInputDialog` e `zTotp.Dialogs.pas`. Descrive il comportamento atteso, non il codice né la disposizione dei controlli.

**Come funziona.** Una conferma crea il dialogo di DevExpress con `dxCreateMessageDialog`, lo ritocca (margini, misure minime, allineamento dei pulsanti) e lo mostra in modo modale; le funzioni `ConfirmXxx` sono involucri che traducono il risultato in vero o falso. I dialoghi di input costruiscono ogni volta un `TInputDialog` (proprietario `Application`), gli mettono didascalia e testo, creano l'editor adatto al tipo del valore, lo mostrano in modo modale e, solo se l'utente conferma con Ok, riscrivono il valore nella variabile del chiamante; il dialogo viene sempre liberato. **Non esiste nessun punto di aggancio per sostituire le finestre**: `Confirm` chiama `dxCreateMessageDialog` e `Execute` chiama `ShowModal` direttamente, quindi senza modificare il codice non si possono provare con un gestore al posto della finestra. Un aggancio nello stile di `OnStartWait` di `zBaseLib` (una variabile `TFunc` che, se assegnata, risponde al posto della finestra) renderebbe possibile provare i chiamanti: è una proposta, oggi non esiste.

**Test che coprono quest'area.** Nessuna prova in `D:\AI\SRC\zPack\_UnitTest\_src`. Il test `Test.zMsg` (8 prove) copre i valori iniziali di `TInputDialog` dopo `CreateNew` (ZBASE-MSG-004) e `AltezzaCarattere` e `AssegnaCarattere` (ZBASE-MSG-011), senza mostrare nessuna finestra. Restano senza prova, perché aprono finestre modali o toccano gli appunti: tutte le funzioni `Confirm` e `Input*`, il riempimento della combo (`CreateCombo`, privato), la validazione delle date (`cxDateEditPropertiesValidate`, privato) e `TcxSpinEdit.PasteFromClipboard`.

## ZBASE-MSG-001 Dialoghi di conferma
`Confirm(Messaggio, Pulsanti, Tipo=mtCustom)` mostra un dialogo con il messaggio e i pulsanti indicati e restituisce il `TModalResult` del pulsante premuto; il pulsante predefinito è il primo dell'insieme (`TMsgDlgBtn.FirstButton`). Gli involucri:
- `ConfirmOk(Messaggio, Tipo)`: un solo pulsante Ok, non restituisce nulla;
- `ConfirmOkCancel`: pulsanti `mbOKCancel`, vero solo se si preme Ok (`mrOk`);
- `ConfirmYesNo`: pulsanti `mbYesNo`, vero solo se si preme Sì (`mrYes`); ogni altro esito è falso;
- `ConfirmYesNoCancel`: pulsanti `mbYesNoCancel`, restituisce il `TModalResult` (`mrYes`, `mrNo`, `mrCancel`).
Il `Tipo` (`mtWarning`, `mtError`, ...) è facoltativo e predefinito `mtCustom`.

### Scenario: domanda di conferma
- **Dato** una cancellazione da confermare
- **Quando** si chiama `ConfirmYesNo('Eliminare il file X?', mtWarning)` e l'utente preme No
- **Allora** il risultato è falso

### Scenario: tre vie
- **Dato** `ConfirmYesNoCancel('Salvare le modifiche?')`
- **Quando** l'utente preme Annulla
- **Allora** il risultato è `mrCancel`

## ZBASE-MSG-002 Aspetto del dialogo di conferma
Il dialogo DevExpress si dimensiona sul testo e risulterebbe più piccolo di quello standard della VCL: `Confirm` lo riporta a una misura confrontabile con questi valori, espressi in pixel a 96 DPI e scalati sul DPI della finestra: larghezza minima del contenuto 255, altezza minima 75, margini del contenuto 12 su ogni lato, margini dei pulsanti 12 a sinistra e a destra e 8 sotto. Un messaggio lungo continua ad allargare e ad alzare la finestra (le misure sono minimi, non misure fisse). Con il solo pulsante Ok il pulsante è centrato, con più pulsanti sono allineati a destra. `HelpFile` e `HelpContext` vengono azzerati, perché la finestra non apra una guida.

### Scenario: messaggio breve
- **Dato** un messaggio di poche parole
- **Quando** si mostra la conferma
- **Allora** la finestra non è più stretta di 255 pixel a 96 DPI

### Scenario: un solo pulsante
- **Dato** `ConfirmOk('Operazione terminata')`
- **Quando** la finestra compare
- **Allora** il pulsante Ok è al centro

## ZBASE-MSG-003 Finestre di attesa sospese durante la conferma
Mentre un dialogo di conferma è aperto, `Confirm` chiama `TSmartWaitForm.SuspendForDialog` e, anche in caso di errore, `TSmartWaitForm.ResumeAfterDialog` alla chiusura: la finestra di attesa resterebbe accanto al dialogo e la schermata di avvio ci starebbe sopra. Il dialogo viene sempre liberato, qualunque sia l'esito. Durante la costruzione `Confirm` imposta per un attimo `UseLatestCommonDialogs` a falso e poi rimette il valore di prima.

### Scenario: conferma durante un'elaborazione
- **Dato** una finestra di attesa visibile
- **Quando** compare una conferma
- **Allora** la finestra di attesa viene tolta finché l'utente non risponde e poi ripristinata

## ZBASE-MSG-004 Struttura dei dialoghi di input
Ogni funzione `Input*` crea un `TInputDialog` con proprietario `Application`, didascalia e testo (`lblPrompt`) indicati, gli associa la richiamata facoltativa `proc` e chiama il metodo `Edit` adatto. Il dialogo ha i pulsanti **Ok** (`ModalResult` = `mrOk`, predefinito) e **Annulla** (`mrCancel`, risponde a Esc), bordo ridimensionabile (`bsSizeToolWin`) e posizione centrata sul proprietario (`poOwnerFormCenter`). Il risultato della funzione è vero solo se la finestra si chiude con `mrOk`; con Annulla la variabile del chiamante **non cambia**. `MapList` e `EditList` valgono vero per costruzione. Il dialogo è sempre liberato (`FreeAndNil` in un `finally`).
Ordine di `Execute`: prima la richiamata `proc(Self)` (serve a riempire l'elenco di una combo, così il dialogo si dimensiona su un contenuto che esiste già), poi la disposizione dei controlli, poi `PopupParent` e `ActiveControl` sull'editor, infine `ShowModal`.

### Scenario: annullamento
- **Dato** `InputString('Titolo', 'Nome', Valore)` con `Valore` uguale a `Mario`
- **Quando** l'utente scrive `Luigi` e preme Annulla
- **Allora** il risultato è falso e `Valore` resta `Mario`

### Scenario: richiamata
- **Dato** una funzione `proc` che riempie le voci di una combo
- **Quando** si apre `InputCombo` con quella `proc`
- **Allora** `proc` è eseguita prima di mostrare la finestra

### Scenario: valori iniziali
- **Dato** un `TInputDialog` appena creato con `CreateNew`
- **Quando** si leggono le proprietà
- **Allora** `MapList` e `EditList` sono veri, `proc` e `cxCustomEdit` sono nulli, la didascalia è vuota, `btnOk.ModalResult` è `mrOk` e `btnCancel.ModalResult` è `mrCancel`

## ZBASE-MSG-005 Testo e password
`InputString(Titolo, Testo, Valore)` apre una casella di testo larga 300 pixel a 96 DPI (scalati) con il valore iniziale. `InputPassword` è uguale ma l'editor è in modo password (`EchoMode` = `eemPassword`, carattere `*`). Con Ok il valore diventa il contenuto digitato.

### Scenario: password
- **Dato** `InputPassword('Accesso', 'Password', Valore)`
- **Quando** la finestra compare
- **Allora** i caratteri digitati compaiono come asterischi

## ZBASE-MSG-006 Numeri
`InputInteger` e `InputInt64` usano un editor a rotella di tipo intero (`vtInt`); `InputDouble` e `InputCurrency` uno di tipo decimale (`vtFloat`), tutti larghi 200 pixel a 96 DPI. Con Ok il valore del chiamante è sostituito da quello dell'editor. Per `currency` il valore passa per l'editor decimale (il commento «vedere per currency» nel sorgente non è stato risolto: DIV-MSG-6).

### Scenario: intero
- **Dato** `InputInteger('Quantità', 'Pezzi', Valore)` con `Valore` uguale a 3
- **Quando** l'utente scrive 5 e preme Ok
- **Allora** `Valore` è 5

## ZBASE-MSG-007 Date e ore
- `InputDate(Titolo, Testo, TDate)`: editor di sola data (`ckDate`, senza ora, larghezza 160). `InputDate(..., TTime)`: editor dell'ora con ore e minuti (`tfHourMin`), pulsanti di incremento a destra. `InputDate(..., TDateTime, Tipo)` con `dkDate`, `dkTime` o `dkDateTime` (predefinito `dkDate`): il tipo sceglie fra data, ora e data con ora (con ora salvata e visibile, larghezza 200).
- `InputDate(Titolo, Testo, Contenuto, TDateTime, DataMinima, DataMassima, PiedeDiPagina)` è l'unica con un intervallo: l'editor accetta solo date valide fra le due, ha il pulsante **Oggi** solo se la data odierna sta nell'intervallo e sempre il pulsante **Cancella**. Una data non scritta correttamente dà l'errore `Data non valida.`; una data fuori intervallo dà `La data deve essere compresa tra il giorno <minima> e il giorno <massima>.` (date nel formato del sistema). I parametri `Contenuto` e `PiedeDiPagina` **non vengono usati** (DIV-MSG-1). Se l'utente cancella la data e conferma, il codice assegna un valore nullo a una `TDateTime` (DIV-MSG-2).

### Scenario: data fuori intervallo
- **Dato** un intervallo dal 01/11/2026 al 31/12/2026
- **Quando** l'utente scrive 15/01/2027
- **Allora** l'editor segnala `La data deve essere compresa tra il giorno 01/11/2026 e il giorno 31/12/2026.` (se Ok si possa premere lo stesso con l'errore presente non è stato verificato)

### Scenario: data odierna fuori intervallo
- **Dato** un intervallo interamente nel passato
- **Quando** la finestra compare
- **Allora** il pulsante Oggi non è presente

## ZBASE-MSG-008 Scelta da un elenco
`InputCombo(Titolo, Testo, Valore, Voci, Immagini=nil, MappaVoci=True, ElencoDigitabile=True, proc=nil)` mostra una casella con elenco (editor `TcxImageComboBox`, larga 300 pixel a 96 DPI, 12 righe visibili, elenco ridimensionabile, larghezza dell'elenco a tendina non automatica). Le voci vengono da `Voci`:
- con `MappaVoci` vero la riga `Descrizione=Valore` mostra `Descrizione` e restituisce `Valore`; se manca il segno `=` la riga è insieme descrizione e valore (DIV-MSG-5 per `Descrizione=` con valore vuoto);
- con `MappaVoci` falso la riga intera è descrizione e valore, anche se contiene `=`.
Con `ElencoDigitabile` vero (`lsEditList`) l'utente può scrivere un valore che non è in elenco; con falso (`lsFixedList`) solo scegliere. Se il valore iniziale non corrisponde a nessuna voce e l'elenco è digitabile, compare comunque nel campo (altrimenti sembrerebbe vuoto e il valore di partenza si perderebbe). Alla conferma il risultato è il **valore** della voce scelta; se nessuna voce è selezionata, vale il testo digitato. Fino alla correzione dell'11/09/2026 `MappaVoci` ed `ElencoDigitabile` venivano ignorati (la combo era sempre mappata e mai digitabile).
`Edit(Valore, TestoVoci, Immagini)` accetta anche un testo con una voce per riga.

### Scenario: voce mappata
- **Dato** le voci `Aperto=A` e `Chiuso=C` e `MappaVoci` vero
- **Quando** l'utente sceglie `Chiuso`
- **Allora** `Valore` diventa `C`

### Scenario: valore non in elenco
- **Dato** `ElencoDigitabile` vero e il valore iniziale `Nuova`
- **Quando** la finestra compare
- **Allora** il campo mostra `Nuova`

## ZBASE-MSG-009 Testo su più righe
`InputMemo(Titolo, Testo, Righe)` apre un editor di testo su più righe (300 per 200 pixel a 96 DPI, che cresce in tutte le direzioni se si ridimensiona il dialogo). Il contenuto parte da una copia di `Righe`; con Ok le righe del chiamante sono sostituite (`Assign`), con Annulla restano com'erano.

### Scenario: modifica del testo
- **Dato** una lista con due righe
- **Quando** l'utente le cambia e preme Ok
- **Allora** la lista del chiamante contiene il nuovo testo

## ZBASE-MSG-010 Larghezza del dialogo di input
La larghezza minima di lavoro è 200 pixel a 96 DPI. Per una combo la larghezza utile è la più larga fra le descrizioni misurate con il carattere effettivo del dialogo, più 40 pixel per bordo e pulsante di apertura, più la larghezza delle immagini e 4 pixel se ci sono, con un tetto di 600 pixel (oltre, il testo viene troncato). La larghezza scelta a mano dall'utente trascinando il bordo non si perde: la disposizione prende il massimo fra contenuto dell'editor, testo del prompt, pulsanti affiancati e larghezza attuale. Le misure si scalano con `dxGetFormDPI` della finestra (non con `CurrentPPI`, che prima della scalatura può già riportare i DPI del monitor e raddoppiare la scalatura).

### Scenario: elenco con una voce lunga
- **Dato** una combo con una descrizione più larga di 600 pixel a 96 DPI
- **Quando** la finestra compare
- **Allora** l'editor è largo 600 pixel (scalati) e il testo viene troncato

## ZBASE-MSG-011 Carattere delle finestre costruite in codice
`AssegnaCarattere(Finestra)` assegna alla finestra il carattere della finestra attiva (`Screen.ActiveCustomForm`) o, in mancanza, di quella principale (`Application.MainForm`), convertito con `dxAssignFont` secondo il rapporto fra i DPI logici delle due finestre: si scala una volta sola, evitando i caratteri enormi su monitor al 150%. Senza finestre aperte l'altezza è `-MulDiv(9, DPI, 72)`, cioè 9 punti. `AltezzaCarattere(Finestra, PuntiInPiu)` restituisce `Font.Height - MulDiv(PuntiInPiu, DPI, 72)` con i DPI di `dxGetFormDPI(Finestra)`: da assegnare a `Font.Height` di uno stile (non si passa da `Font.Size`, perché `TdxForm` tiene il carattere ai DPI di sistema). L'altezza è negativa: più punti, numero più piccolo; punti negativi la rimpiccioliscono.

### Scenario: più punti
- **Dato** una finestra con altezza di carattere −12 a 96 DPI
- **Quando** si chiama `AltezzaCarattere(Finestra, 2)`
- **Allora** il risultato è −15

### Scenario: nessuna finestra aperta
- **Dato** nessuna finestra attiva né principale
- **Quando** si chiama `AssegnaCarattere(Finestra)`
- **Allora** `Font.Height` vale −12 a 96 DPI

## ZBASE-MSG-012 Incolla nei campi numerici (`TcxSpinEdit`)
`zMsg` dichiara una propria `TcxSpinEdit`, derivata da quella di DevExpress, che prima di incollare **riscrive il testo degli appunti** togliendo gli spazi ai bordi e tutti i caratteri `.` (separatori delle migliaia dell'italiano), poi esegue l'incolla normale. Vale solo per gli editor creati da `TInputDialog` (`CreateSpin`): le form create dal DFM usano la classe registrata di DevExpress (DIV-MSG-3 e DIV-MSG-7).

### Scenario: numero con le migliaia
- **Dato** negli appunti il testo `1.234`
- **Quando** l'utente incolla in un editor numerico di un `TInputDialog`
- **Allora** nel campo compare `1234`

## ZBASE-MSG-013 Impostazioni all'avvio
Nella sezione di avvio la unit imposta `UseLatestCommonDialogs` a falso e `dxUseStandardMessageDialogs` a vero, per il corretto uso degli skin nei dialoghi comuni: basta includere `zMsg` in un programma perché valgano per tutto il programma.

### Scenario: programma con zMsg
- **Dato** un programma che include `zMsg`
- **Quando** parte
- **Allora** `UseLatestCommonDialogs` è falso e `dxUseStandardMessageDialogs` è vero prima di qualunque dialogo

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-MSG-1 🟡 (dedotta) | `InputDate` con intervallo riceve `AContent` e `FooterText` ma il corpo non li legge: passa solo `ACaption`, `APrompt`, `value`, `DateMin`, `DateMax` | I tre chiamanti di `dmCommon.pas` (data documento, data di storno, data di consolidamento) preparano un testo di contenuto e un piede di pagina che l'utente non vede mai |
| DIV-MSG-2 🟡 (dedotta) | `Edit` per le date assegna `cxCustomEdit.EditValue` a una `TDate`/`TDateTime`/`TTime` senza controllare che sia nullo: il pulsante Cancella dell'editor con intervallo (sempre presente) e, in generale, una data svuotata producono `Null` | Premendo Ok con la data cancellata la conversione da `Null` a `TDateTime` solleva un'eccezione invece di restituire falso o lasciare la data com'era |
| DIV-MSG-3 🟡 (dedotta) | `TcxSpinEdit.PasteFromClipboard` scrive `Clipboard.AsText` anche quando gli appunti non contengono testo (`AsText` è vuoto) e toglie ogni `.`, anche il punto decimale di un numero scritto all'inglese | Incollare in un campo numerico distrugge il contenuto degli appunti (un'immagine copiata sparisce, resta un testo vuoto); `12.5` incollato diventa `125` |
| DIV-MSG-4 🟢 (dedotta) | `TInputDialog.Execute` ha una copia locale di `GetPopupParent` che parte da `Self` (una form), quindi restituisce subito il dialogo stesso e non risale mai al proprietario (`Application`); la versione di `zBaseLib` ha in più il ritorno alla finestra attiva, questa no | `PopupParent` del dialogo è il dialogo stesso: l'effetto voluto («finestre modali che finiscono dietro») non dipende da questo codice ma da come la VCL tratta il caso; da verificare con un collaudo |
| DIV-MSG-5 🟢 (dedotta) | Con `MapList` vero una voce `Nome=` (valore vuoto) mostra `Nome` ma ha come valore la riga intera `Nome=`, perché `Item.value` torna alla riga quando `ValueFromIndex` è vuoto | Scegliendo quella voce `InputCombo` restituisce `Nome=` invece del valore vuoto atteso |
| DIV-MSG-6 🟢 | `Edit(var currency)` crea un editor `vtFloat` con il commento rimasto «vedere per currency»; `InputCurrency` non ha chiamanti | Il valore passa per `Double`; finché nessuno la usa non si vede |
| DIV-MSG-7 🟢 (dedotta) | `zMsg` dichiara nell'interfaccia una classe `TcxSpinEdit` con lo stesso nome di quella di DevExpress | Una unit che metta `zMsg` nell'`uses` dell'interfaccia dopo `cxSpinEdit` e dichiari un campo `TcxSpinEdit` riceverebbe la classe di `zMsg` mentre il DFM crea quella registrata di DevExpress; nessuna unit di WT, Gesty e zPack oggi lo fa (verificato: le unit con campi `TcxSpinEdit` includono `zMsg` solo nella parte implementativa) |
