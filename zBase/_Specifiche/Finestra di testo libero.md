---
area: Finestra di testo libero
progetto: zBase
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/018
---

# Finestra di testo libero

Questa specifica descrive la finestra modale che mostra e fa modificare un testo su più righe: `zExecuteMemoDialog` (tre forme), la finestra `TzMemoForm` che la realizza e il componente `TzMemoDialog`. Il codice è in `zBase\zMemoDialog.pas` (con il suo `.dfm`). WT e Gesty la usano per due scopi: **mostrare un esito o un registro** (elaborazione tariffa, controlli prima dell'invio GEFOS, esito di invio SIUF, esito di validazione ore, esportazione di strutture) e **chiedere un testo** (note di contabilizzazione, esito di valutazione, motivazione di respingimento, «cosa stavi facendo?» della richiesta di assistenza in `zExceptions`); zPack la usa per modificare i campi memo delle schede (`zDbCard`, con le azioni del menu del tasto destro), per mostrare l'elenco dei controlli e dei campi (`zDbView`, `zz.base.editor.DbCard`) e per il verbale di `zSystem.Patcher`. In tutto vi fanno riferimento 18 file di WT, Gesty e zTicser (copie di lavoro escluse) più le unit di zPack. La unit non compare né nei `.dpk` di zBase né nei `.dpr` di WT e Gesty: si compila perché la raggiunge una catena di `uses` (per esempio da `zDbCard`) e il library path la trova.

**Non si sovrappone a `Finestre di dialogo.md` (ZBASE-MSG).** `InputMemo` di `zMsg` (ZBASE-MSG-009) è un piccolo editor nel `TInputDialog`, con soli pulsanti Ok e Annulla: non ha barra degli strumenti, ricerca, apertura e salvataggio su file, azioni personalizzate, conferma all'uscita né a capo automatico. Questa è un'altra finestra, in un'altra unit, con un altro uso: le due specifiche non descrivono lo stesso codice. L'unico legame è che la conferma all'uscita (ZBASE-MDG-004) usa `ConfirmYesNoCancel`, descritta in ZBASE-MSG-001.

**Come funziona.** `zExecuteMemoDialog` crea una `TzMemoForm` con proprietario nullo, le dà il titolo e il testo, la mostra in modo modale e la libera sempre. Il testo di partenza arriva da un memo di DevExpress (`TcxCustomMemo`, per esempio un campo memo di una scheda), da una lista di righe (`TStrings`) o da una stringa; il testo modificato torna al chiamante **solo se l'utente conferma** e la funzione restituisce vero. Un testo cambiato e non confermato non si perde senza avviso (ZBASE-MDG-004). La finestra ha una barra con taglia, copia, incolla, annulla, elimina, seleziona tutto, trova, sostituisci, successivo, apri da file e salva su file, e può ospitare azioni del chiamante.

**Test che coprono quest'area.** `Test.zMemoDialog` (bozza, 16 prove) prova, senza mai mostrare la finestra: i valori iniziali di `TzMemoDialog`, la copia delle righe, la rinuncia a una lista nulla, la regola di `CloseQuery` nei tre casi che non aprono nessuna domanda (conferma già data con Ok, memo di sola lettura, testo invariato), `SostituisciUpdate`, e l'apertura e il salvataggio su file. Non provano, perché richiedono `ShowModal` o la domanda all'utente: `Execute` e tutto ciò che fa prima di mostrare la finestra (copia delle proprietà del memo, a capo automatico, azioni personalizzate), la domanda «testo modificato», l'azione iniziale, la ricerca e la sostituzione e il risultato delle tre funzioni.

## ZBASE-MDG-001 Contratto delle funzioni `zExecuteMemoDialog`
Le tre forme hanno la stessa regola per il risultato: restituiscono **vero** solo se l'utente ha confermato (pulsante Ok, oppure la risposta Sì alla domanda di conferma di ZBASE-MDG-004), **falso** con Annulla, con la X o con No alla domanda. Solo con vero il testo modificato viene riscritto nella sorgente; con falso la sorgente resta com'era.
- `zExecuteMemoDialog(Memo: TcxCustomMemo; Titolo; Azioni; Immagini; MandaACapo; AzioneIniziale)`: parte dal testo del memo e, se confermato, scrive il nuovo testo con `Memo.Text`. Per un campo memo legato a un dataset equivale quindi a scrivere nel campo, e porta il dataset in modifica.
- `zExecuteMemoDialog(Righe: TStrings; Titolo; Azioni; Immagini; MandaACapo)`: parte da `Righe.Text` e, se confermato, assegna `Righe.Text`.
- `zExecuteMemoDialog(var Testo: string; Titolo; Azioni; Immagini; MandaACapo)`: parte da `Testo` e, se confermato, lo sostituisce.
Il testo si assegna sempre con `.Text`, non con `Lines.Assign`, perché con l'a capo automatico le righe riportano anche gli a capo aggiunti dal componente e riscriverle cambierebbe il contenuto. La finestra è sempre liberata, anche in caso di errore. Il titolo predefinito è la stringa vuota.

### Scenario: conferma con Ok
- **Dato** una variabile `Nota` uguale a `prima`
- **Quando** l'utente scrive `dopo` e preme Ok
- **Allora** la funzione restituisce vero e `Nota` vale `dopo`

### Scenario: annullamento
- **Dato** una variabile `Nota` uguale a `prima`
- **Quando** l'utente scrive `dopo` e preme Annulla, e alla domanda risponde No
- **Allora** la funzione restituisce falso e `Nota` vale ancora `prima`

### Scenario: lista di righe
- **Dato** una `TStringList` con due righe
- **Quando** l'utente le sostituisce con una sola riga e preme Ok
- **Allora** la lista contiene la riga nuova, con `Righe.Text` aggiornato

### Scenario: lista nulla
- **Dato** una variabile `TStrings` nulla
- **Quando** si chiama `zExecuteMemoDialog(Righe, 'Titolo')`
- **Allora** la funzione restituisce falso senza mostrare la finestra (DIV-MDG-1, corretta nel rilascio 018)

## ZBASE-MDG-002 Aspetto e comportamento di base della finestra
La finestra (`TzMemoForm`, derivata da `TdxRibbonForm`) si apre centrata sulla finestra principale, con un memo che occupa tutto lo spazio, barra a scorrimento verticale e orizzontale, i pulsanti Ok e Annulla in basso (nessuno dei due è predefinito). Il memo è modificabile, salvo quando la sorgente è un memo di sola lettura: nella forma `TcxCustomMemo` le proprietà del memo di origine (sola lettura, tipo di carattere, limiti, ecc.) vengono copiate con `Properties.Assign` e poi le barre di scorrimento tornano sempre entrambe presenti. Nelle altre due forme il memo è sempre modificabile (DIV-MDG-3). Ogni finestra ha una barra «Toolbar» con i comandi di modifica e una barra «Free» per le azioni del chiamante; le due barre non occupano una riga intera e stanno sulla prima riga.

Comandi: **Taglia**, **Copia**, **Incolla**, **Annulla** (annulla l'ultima modifica), **Elimina**, **Seleziona tutto** funzionano sul memo; **Trova** (`Ctrl+F`), **Sostituisci** (`Ctrl+H`) e **Successivo** (`F3`) usano `TFindReplaceHelper` di `zFindReplace.Helper`; **Sostituisci è disattivato** quando il memo è di sola lettura.

### Scenario: memo di sola lettura
- **Dato** la finestra con il memo in sola lettura
- **Quando** si aggiorna lo stato delle azioni
- **Allora** **Sostituisci** è disattivata

### Scenario: memo modificabile
- **Dato** la finestra con il memo modificabile
- **Quando** si aggiorna lo stato delle azioni
- **Allora** **Sostituisci** è attiva

## ZBASE-MDG-003 A capo automatico (`MandaACapo`)
Con `MandaACapo` vero il testo va a capo da solo e resta soltanto la barra di scorrimento verticale (`WordWrap` vero, `ScrollBars` uguale a `ssVertical`): con la barra orizzontale presente DevExpress ignora l'a capo. Con falso (predefinito) restano le due barre e il testo sbordando a destra. Il valore vero è per i riquadri che mostrano un esito, un registro o un messaggio (Mantis #152); sui memo dei dataset si lascia falso, perché con l'a capo attivo le righe del memo riportano anche gli a capo aggiunti dal componente e riscriverle nel campo ne cambierebbe il contenuto.

### Scenario: esito lungo
- **Dato** un esito con righe più larghe della finestra e `MandaACapo` vero
- **Quando** la finestra compare
- **Allora** le righe vanno a capo e non c'è la barra di scorrimento orizzontale

## ZBASE-MDG-004 Conferma all'uscita con un testo modificato
Chiudere la finestra con la X o con Annulla dopo aver modificato il testo non lo scarta senza avvisi (Mantis #257): la finestra chiede «Il testo è stato modificato ma non confermato» con tre scelte:
- **Sì**: conferma il testo e chiude; la funzione restituisce vero e il testo torna al chiamante (anche se il risultato modale del pulsante è Annulla);
- **No**: chiude senza salvare, la funzione restituisce falso;
- **Annulla**: la finestra resta aperta, per tornare al testo.
La domanda **non compare** se la finestra si chiude con Ok, se il memo è di sola lettura o se il testo è uguale a quello di apertura (il confronto è sul testo intero, con gli a capo, non sulle righe). Il testo di apertura è quello presente quando la finestra viene mostrata, dopo l'eventuale copia dalla sorgente e l'eventuale a capo automatico.

### Scenario: uscita con la X dopo una modifica
- **Dato** un testo modificato e non confermato
- **Quando** l'utente chiude con la X e risponde Sì alla domanda
- **Allora** la funzione restituisce vero e il chiamante riceve il testo modificato

### Scenario: uscita senza modifiche
- **Dato** un testo identico a quello di apertura
- **Quando** l'utente chiude con la X
- **Allora** la finestra si chiude senza nessuna domanda e la funzione restituisce falso

### Scenario: memo di sola lettura
- **Dato** un memo di sola lettura
- **Quando** l'utente chiude con Annulla
- **Allora** nessuna domanda e nessuna modifica al chiamante

## ZBASE-MDG-005 Azioni del chiamante (`CustomActions`, `ImageList`)
Il chiamante può passare un elenco di azioni (`TArray<TBasicAction>`) che la finestra mette come pulsanti nella barra «Free» e nel menu del tasto destro del memo, nell'ordine dato, con un separatore prima del primo. Per ogni azione:
- il campo `Tag` dell'azione viene impostato al **riferimento del memo della finestra** (`NativeInt` di `cxMemo`): è così che l'azione, eseguita dalla finestra, raggiunge il testo (l'azione che le serve non sa nulla della finestra);
- il pulsante ha lo stile didascalia e immagine; se l'azione è una `TAction` con `AutoCheck`, il pulsante è a due stati e parte nello stato di `Checked`;
- l'elenco delle immagini (`ImageList`) è assegnato alla barra «Free», solo se l'elenco di azioni non è vuoto.
Con un elenco nullo o vuoto non viene aggiunto nulla. Le azioni appartengono al chiamante: sopravvivono alla finestra, con `Tag` che resta il riferimento di un memo ormai distrutto (DIV-MDG-4).

### Scenario: azione del chiamante
- **Dato** una azione `Importa` passata in `CustomActions`
- **Quando** la finestra compare
- **Allora** nella barra «Free» e nel menu contestuale c'è un pulsante collegato all'azione, e `Importa.Tag` è il riferimento del memo della finestra

## ZBASE-MDG-006 Azione iniziale
Solo la forma con `TcxCustomMemo` accetta `AzioneIniziale`: un'azione che parte da sola appena la finestra è visibile, come se l'utente avesse premuto il pulsante (è il caso di «Importa» scelto dal menu del tasto destro di un campo memo, che lavora sul memo della finestra). La partenza è **posticipata** con un messaggio (`WM_ESEGUI_AZIONE_INIZIALE`) e non eseguita dentro `DoShow`: l'azione apre a sua volta un dialogo modale, che deve partire a finestra già mostrata. Parte una volta sola: la finestra azzera il riferimento prima di eseguirla.

### Scenario: importa da menu
- **Dato** un'azione iniziale che apre una finestra di scelta file
- **Quando** la finestra compare
- **Allora** la finestra di scelta del file si apre subito dopo, senza che l'utente prema nulla, e una sola volta

## ZBASE-MDG-007 Apertura e salvataggio del testo su file
**Apri** (filtro `Testo|*.txt|Tutti|*.*`, `Ctrl+O`) sostituisce il testo del memo con il contenuto del file scelto; **Salva su file...** (stesso filtro) scrive il testo del memo nel file scelto. L'apertura riconosce l'eventuale segno di ordine dei byte (BOM) UTF-8 o UTF-16; un file senza BOM è letto come UTF-8 se è UTF-8 valido, altrimenti con la tabella di caratteri ANSI del sistema. Il salvataggio scrive in UTF-8 senza BOM, quindi nessun carattere si perde (DIV-MDG-2, corretta nel rilascio 015). L'apertura sostituisce il testo senza chiedere conferma e il nuovo testo conta come modifica per la domanda di ZBASE-MDG-004.

### Scenario: file di testo semplice
- **Dato** un file `note.txt` con le righe `riga1` e `riga2`
- **Quando** l'utente lo apre con **Apri**
- **Allora** il memo contiene le due righe

### Scenario: salvataggio senza BOM
- **Dato** un memo con il testo `abc`
- **Quando** l'utente lo salva con **Salva su file...**
- **Allora** il file comincia con i tre byte `abc` (poi il fine riga), senza BOM

## ZBASE-MDG-008 Componente `TzMemoDialog`
`TzMemoDialog` è la forma componente della stessa finestra: ha `Caption`, `Lines` (una copia dell'elenco, non un riferimento: assegnare `Lines` copia le righe) e gli eventi `OnInitDialog` e `OnCloseDialog`. `Execute(Memo, Azioni, Immagini)` chiama `OnInitDialog`, crea la finestra, parte da `Lines.Text`, la mostra come le altre forme e, se confermato, riscrive `Lines.Text`; poi chiama `OnCloseDialog`. Se è passato un memo, la finestra parte dal **testo del memo** e non da `Lines`, ma il risultato torna comunque in `Lines`, non nel memo (DIV-MDG-5). Il componente non risulta registrato in `zBaseRegister` e nessun file di WT, Gesty, zTicser o zPack lo usa.

### Scenario: righe copiate
- **Dato** un `TzMemoDialog` e una lista di due righe
- **Quando** si assegna la lista a `Lines` e poi si modifica la lista originale
- **Allora** `Lines` conserva le due righe di partenza

### Scenario: valori iniziali
- **Dato** un `TzMemoDialog` appena creato
- **Quando** si leggono le proprietà
- **Allora** `Caption` è vuota, `Lines` non ha righe e gli eventi non sono assegnati

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-213 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-MDG-1 ✅ (corretta) | La forma con `TStrings` leggeva `Lines.Text` prima di controllare `Assigned(Lines)`. Corretta nel rilascio 018: con una lista nulla restituisce falso senza aprire la finestra | Nessuna |
| DIV-MDG-2 ✅ (corretta) | `FileOpenAccept` e `FileSaveAsAccept` usavano la tabella ANSI del sistema senza BOM. Corretta nel rilascio 015: l'apertura riconosce UTF-8 senza BOM (con ricaduta su ANSI se il file non è UTF-8 valido), il salvataggio scrive UTF-8 senza BOM | Nessuna. Un testo salvato con lettere accentate ora è UTF-8: un programma che lo rilegge come ANSI le vedrebbe errate |
| DIV-MDG-3 🟢 (dedotta) | Il commento di Mantis #152 dice «da usare per i riquadri di sola lettura (esiti, registri, messaggi)», ma nessuna delle tre forme con `TStrings` o `string` rende il memo di sola lettura | Un esito o un registro mostrato con `MandaACapo` vero è comunque modificabile; chiudere con la X dopo averlo toccato fa comparire la domanda di ZBASE-MDG-004, fuori luogo per un messaggio |
| DIV-MDG-4 🟢 (dedotta) | `InitCustomActions` assegna `Tag := NativeInt(cxMemo)` a ogni azione del chiamante e non lo ripristina alla chiusura | Dopo la finestra l'azione resta con un `Tag` che punta a un memo liberato: chi lo legge fuori dalla finestra usa un riferimento non valido; le azioni si riutilizzano a ogni apertura, e il valore si riscrive, ma non il valore di prima |
| DIV-MDG-5 🟡 (dedotta) | `TzMemoDialog.Caption` non viene mai usata da `Execute` (la finestra resta senza titolo); `TzMemoDialog.Execute` con un memo parte dal testo del memo ma scrive il risultato in `Lines`; `DoCloseDialog` non viene chiamata se la finestra solleva un'eccezione (nessun `try/finally`); `zMemoForm` è un campo protetto che resta con un riferimento dopo la liberazione | Il componente non è usato da nessuno: se qualcuno lo adottasse, troverebbe titolo ignorato e testo che torna in un posto diverso da quello di partenza |
| DIV-MDG-6 🟢 (dedotta) | Il filtro `DefaultExt` di **Apri** e **Salva su file...** è `*.txt` (con l'asterisco e il punto) invece di `txt` | Un nome scritto a mano senza estensione può ricevere un suffisso malformato (`nome.*.txt`); non verificato, dipende dal componente di DevExpress |
