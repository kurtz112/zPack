---
area: Valori e editabilità degli editor
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/001
---

# Valori e editabilità degli editor

Questa specifica descrive come `zDX` legge e scrive il valore degli editor DevExpress (`TcxCustomEdit` e discendenti), come li rende obbligatori, normali o di sola lettura, come li valida e come gestisce la tendina a selezione multipla (`TcxCheckComboBox`). Il codice è in `zBase\zDX.pas`: l'helper `TcxCustomEditHelper` (`isEmpty`, `asInteger`, `asString`, `asDateTime`, `asDouble`), il modulo dati `Tdx` (raggiungibile con la funzione `dx`: `SetValue`, `GetValue`, `ValueStr`, `ValueInt`, `ValueDate`, `ValueDouble`, `GetStatesString`, `DataBind`, `SetEditability`, `GetStyleController`, i gestori di validazione, `ActiveControl`, `IsActiveControl`, `ActiveGrid`, `GridEditable`, `FieldSize`) e l'helper `TcxCustomCheckComboBoxHelper`. Fuori da questa specifica restano colori, lookup, icone, barre, griglie, layout e skin di `zDX`. Chi lo usa: oltre che dentro zPack (`zDbCard`, `zDbView`, `zFormBuilder`: `dx.SetValue` 53 volte, `dx.GetStatesString` 33, `dx.FieldSize` 10), le form di WT e Gesty chiamano `dx.SetEditability` 45 volte (29 con `edRequired`, 9 con `edReadOnly`, 7 con `edNormal`), `dx.ValueStr` 19, `dx.ValueInt` 9, `dx.ValueDate` 8, `dx.ValueDouble` 2, `dx.GetStyleController` 3, `dx.ActiveControl` 6 (`BaseFrm` di WT e di Gesty, per sapere se una tendina è aperta), `dx.IsActiveControl` 2, e una volta ciascuna `dx.GetValue`, `dx.DataBind` (`wizVariazioneFrm`), `dx.GridEditable(dx.ActiveGrid)` (`BaseFrm` di Gesty) e `FillItems` (due filtri di Gesty). Nessuno chiama `EnableItems`, `EnableItem`, `EditValueToStates` o `StatesToEditValue` fuori da zDX, e nessuna applicazione imposta `SanificaTesto`: resta sempre vero. La unit è compilata (la usano `zDbCard`, `zDbView` e `zFormBuilder`); nessun `.dpk` o `.dproj` del mirror la cita per nome.

**Come funziona.** Un editor DevExpress tiene il suo valore in `EditValue`, una variante: `Null` vuol dire campo vuoto. Gli helper e i metodi `Value*` leggono quella variante e rispondono con un valore predefinito quando è `Null` (testo vuoto, -1, data nulla), perché una funzione tipata non può restituire `Null`. `SetEditability` applica a un editor (o alle sue proprietà, o a una colonna di griglia) una delle tre modalità di `TEditability` (`edNormal`, `edRequired`, `edReadOnly`): sola lettura, icona e regole di validazione, tabulazione e controller di stile con il colore della modalità. La validazione parte da `Properties.OnValidate`: prima ripulisce il testo (`TzSanificazione`, vedi `ZBASE-SAN-001`), poi controlla l'obbligatorietà, poi applica la regola del dizionario dati sul campo (oggi solo l'e-mail). La tendina a selezione multipla conserva nel database un solo testo con i codici delle voci scelte separati da un delimitatore (`; `): l'helper traduce fra quel testo e l'elenco degli stati di selezione.

**Test che coprono quest'area.** Nessuna in `_UnitTest\_src`. La bozza `Test.zDX.Editor.pas` (stessa cartella di questa specifica, da portare in `_UnitTest\_src`) prova gli helper e i metodi con editor creati senza finestra; i test che chiedono il modulo `Tdx` finiscono come superati, con il motivo, se `dx` non si può creare in un programma senza form. Restano senza prova: gli overload di `SetValue` per le voci di barra, `GetValue` su un `TcxSpinEdit` vuoto, `SetEditability` con `doValidate` vero, la regola e-mail del dizionario dati, la sanificazione dell'editor RTF e `ActiveControl` con un controllo attivo.

## ZBASE-VED-001 Lettura del valore con l'helper dell'editor
Su ogni `TcxCustomEdit`: `isEmpty` è vero solo se `EditValue` è `Null`; la stringa vuota è un valore. `asString` restituisce `''` se l'editor è vuoto, `asInteger` restituisce -1, `asDouble` restituisce 0 e `asDateTime` restituisce 0; con un valore presente lo convertono dal valore dell'editor. Il valore predefinito di `asInteger` (-1) e quello di `asDouble` (0) non coincidono con quelli di `ValueInt` e `ValueDouble` (DIV-VED-1). Un valore `Unassigned` non è vuoto per `isEmpty` (DIV-VED-2).

### Scenario: campo di testo vuoto
- **Dato** un `TcxTextEdit` nuovo, mai valorizzato
- **Quando** si leggono `isEmpty`, `asString`, `asInteger` e `asDouble`
- **Allora** i risultati sono `True`, `''`, `-1` e `0`

### Scenario: numero in un campo di testo
- **Dato** un `TcxTextEdit` con `EditValue` uguale a 42
- **Quando** si legge `asInteger`
- **Allora** il risultato è 42 e `isEmpty` è falso

### Scenario: data
- **Dato** un `TcxDateEdit` vuoto, poi valorizzato con il 1 novembre 2026
- **Quando** si legge `asDateTime`
- **Allora** vale 0 da vuoto e il 1 novembre 2026 dopo l'assegnazione

## ZBASE-VED-002 Lettura del valore con il modulo Tdx
`dx.ValueStr` restituisce `''`, `dx.ValueInt` e `dx.ValueDouble` restituiscono -1, `dx.ValueDate` restituisce `NullDate` (-700000) se l'editor è `nil` o vuoto; altrimenti il valore dell'editor convertito nel tipo richiesto. `dx.GetValue` restituisce `Null` se l'editor è `nil`, altrimenti `EditValue`; per un `TcxCustomSpinEdit` il cui testo è vuoto restituisce `Null` invece dello 0 che DevExpress tiene nel valore. Nessuno di questi metodi solleva eccezioni per un editor `nil`. La conversione di un valore non compatibile (testo non numerico letto con `ValueInt`) è lasciata alla variante e solleva l'eccezione di conversione.

### Scenario: editor assente
- **Dato** un riferimento `nil` al posto dell'editor
- **Quando** si chiamano `ValueStr(nil)`, `ValueInt(nil)` e `GetValue(nil)`
- **Allora** i risultati sono `''`, `-1` e `Null`, senza eccezioni

### Scenario: valori presenti
- **Dato** un editor con `EditValue` uguale a 42, poi a 2,5
- **Quando** si leggono `ValueInt` e `ValueDouble`
- **Allora** i risultati sono 42 e 2,5

### Scenario: spin vuoto
- **Dato** un `TcxSpinEdit` il cui testo è stato svuotato dall'utente (il valore interno resta 0)
- **Quando** si chiama `GetValue`
- **Allora** il risultato è `Null`, non 0

## ZBASE-VED-003 Scrittura del valore di un editor
`dx.SetValue(Editor, Valore)` ignora un editor `nil`; se `Valore` è `Null` o `Empty` svuota l'editor con `Clear`, altrimenti assegna `EditValue`. L'assegnazione fa scattare le normali notifiche dell'editor (cambio di valore, ricalcolo dei dipendenti): per assegnare senza notifiche serve l'overload della casella di selezione (`ZBASE-VED-004`).

### Scenario: assegnazione e svuotamento
- **Dato** un `TcxTextEdit` vuoto
- **Quando** si chiama `SetValue(Editor, 'Mario')` e poi `SetValue(Editor, Null)`
- **Allora** dopo la prima chiamata `EditValue` è `'Mario'`, dopo la seconda l'editor è vuoto (`isEmpty` vero)

### Scenario: editor assente
- **Dato** `nil` al posto dell'editor
- **Quando** si chiama `SetValue(nil, 'Mario')`
- **Allora** non succede niente e non si solleva nessuna eccezione

## ZBASE-VED-004 Scrittura senza notifiche per caselle e voci di barra
Gli overload di `SetValue` per `TcxBarEditItem`, `TdxBarEdit`, `TdxBarSpinEdit` e `TcxCheckBox` assegnano il valore (rispettivamente `EditValue`, `Text`, `Value`, `Checked`) con il gestore di cambio sospeso: salvano `OnChange` (per `TcxCheckBox` `Properties.OnEditValueChanged`), lo azzerano, assegnano e lo rimettono in un blocco `finally`, quindi il gestore è ripristinato anche se l'assegnazione solleva un'eccezione. Servono quando il programma aggiorna un controllo per riflettere uno stato e non vuole che il gestore creda a un'azione dell'utente. Con una voce `nil` l'`Assert` fallisce (nelle versioni di rilascio senza `Assert` il metodo va in errore di accesso).

### Scenario: casella di selezione
- **Dato** un `TcxCheckBox` con un gestore in `Properties.OnEditValueChanged` che conta le chiamate
- **Quando** si chiama `SetValue(Casella, True)`
- **Allora** `Casella.Checked` è vero, il gestore non è stato chiamato e `Properties.OnEditValueChanged` è ancora il gestore di prima

## ZBASE-VED-005 Stringa degli stati
`dx.GetStatesString` trasforma un elenco di booleani in una stringa di `1` e `0`, uno per elemento, nello stesso ordine; l'elenco vuoto dà la stringa vuota. È il formato con cui `zDbCard` mostra nelle voci di barra i flag di una scheda (sola lettura, obbligatorio, pulsanti).

### Scenario: valori misti
- **Dato** l'elenco vero, falso, vero
- **Quando** si chiama `GetStatesString`
- **Allora** il risultato è `101`

## ZBASE-VED-006 Collegamento di un editor a un campo
`dx.DataBind(Editor, DataSource, DataField)` imposta `DataBinding.DataSource` e `DataBinding.DataField` dell'editor. Vale solo per editor che hanno un collegamento ai dati (`TcxDBTextEdit` e simili): su un editor non DB il metodo scrive in un oggetto del tipo sbagliato (DIV-VED-5).

### Scenario: editor DB
- **Dato** un `TcxDBTextEdit` e un `TDataSource`
- **Quando** si chiama `DataBind(Editor, Sorgente, 'COGNOME')`
- **Allora** `Editor.DataBinding.DataSource` è `Sorgente` e `Editor.DataBinding.DataField` è `COGNOME`

## ZBASE-VED-007 Editabilità applicata alle proprietà dell'editor
`dx.SetEditability(Proprieta, Editabilita)` imposta sempre: `ValidateOnEnter` vero, icona di errore a destra (`ValidationErrorIconAlignment` = `taRightJustify`), `ValidationOptions` = `[evoShowErrorIcon, evoAllowLoseFocus]` (l'icona compare e l'utente può comunque uscire dal campo). Con `edRequired` assegna anche l'icona dell'obbligatorietà (`RequiredImages`, immagine 0) e il gestore `ValidateRequired`; con `edNormal` e `edReadOnly` il gestore è `ValidateNormal`. `ReadOnly` è vero solo con `edReadOnly` e viene riportato a falso con le altre due, quindi la funzione si può richiamare più volte per cambiare modalità. Per le proprietà di un editor RTF (`TcxRichEditProperties`) `ValidateOnEnter` torna falso: con vero l'editor si mangia il tasto Invio (Mantis 958). Con `Proprieta` `nil` l'`Assert` fallisce.

### Scenario: obbligatorio
- **Dato** le proprietà di un `TcxTextEdit`
- **Quando** si chiama `SetEditability(Proprieta, edRequired)`
- **Allora** `ReadOnly` è falso, `ValidateOnEnter` è vero, `OnValidate` è assegnato e `ErrorIcon` non è vuota

### Scenario: da sola lettura a normale
- **Dato** le proprietà già impostate con `edReadOnly`
- **Quando** si chiama `SetEditability(Proprieta, edNormal)`
- **Allora** `ReadOnly` torna falso

### Scenario: editor RTF
- **Dato** le proprietà di un `TcxRichEdit`
- **Quando** si chiama `SetEditability(Proprieta, edRequired)`
- **Allora** `ValidateOnEnter` è falso

## ZBASE-VED-008 Editabilità applicata all'editor e alla colonna
`dx.SetEditability(Editor, Editabilita, doValidate)` applica `ZBASE-VED-007` alle `ActiveProperties` dell'editor, poi (se `doValidate` è vero, il valore predefinito) chiama `ValidateEdit(False)` per far comparire subito l'icona dell'obbligatorietà, poi imposta `TabStop` a falso con `edReadOnly` e a vero con le altre modalità, e assegna all'editor il controller di stile della modalità (`ZBASE-VED-009`) se non è già quello. Con `doValidate` falso non si tocca lo stato dell'editor: serve quando la scheda è in sola consultazione e la validazione la metterebbe in modifica (nota del 07.06.2019 nel codice). `dx.SetEditability(Colonna, Editabilita)` applica `ZBASE-VED-007` alle `Properties` della colonna di griglia, senza stile né tabulazione; con una colonna priva di `Properties` o `nil` l'`Assert` fallisce.

### Scenario: sola lettura
- **Dato** un `TcxTextEdit` normale
- **Quando** si chiama `SetEditability(Editor, edReadOnly, False)`
- **Allora** `ActiveProperties.ReadOnly` è vero, `TabStop` è falso e il controller di stile è `dx.ReadOnlyStyleController`

### Scenario: ritorno a normale
- **Dato** lo stesso editor, già in sola lettura
- **Quando** si chiama `SetEditability(Editor, edNormal, False)`
- **Allora** `TabStop` è vero e il controller di stile è `dx.NormalStyleController`

### Scenario: colonna di griglia
- **Dato** una colonna `TcxGridDBColumn` con proprietà di testo
- **Quando** si chiama `SetEditability(Colonna, edReadOnly)`
- **Allora** `Colonna.Properties.ReadOnly` è vero e `OnValidate` è assegnato

## ZBASE-VED-009 Controller di stile per modalità
`dx.GetStyleController(Editabilita)` restituisce `NormalStyleController` per `edNormal`, `RequiredStyleController` per `edRequired`, `ReadOnlyStyleController` per `edReadOnly`: tre oggetti distinti, i cui colori (campo, carattere) `UpdateStyles` ricalcola dalla skin attiva.

### Scenario: tre modalità
- **Dato** il modulo `dx`
- **Quando** si chiede il controller di ciascuna modalità
- **Allora** si ottengono i tre controller dei campi omonimi, tutti diversi fra loro

## ZBASE-VED-010 Validazione di un editor obbligatorio
Il gestore `ValidateRequired` (assegnato da `SetEditability` con `edRequired`) esegue in quest'ordine: la sanificazione del testo (`ZBASE-VED-012`), il controllo dell'obbligatorietà, la regola di dominio (`ZBASE-VED-013`). Il valore è mancante se è `Null` o se, tolti gli spazi ai bordi, è vuoto: in tal caso `Error` è vero e `ErrorText` è `Valore richiesto`. Altrimenti `Error` è falso e `ErrorText` è vuoto. Siccome la sanificazione precede il controllo, un testo fatto solo di caratteri invisibili (U+200B) o di spazi unificatori (U+00A0) risulta mancante. Un numero, anche 0, non è mancante.

### Scenario: valore mancante
- **Dato** un editor obbligatorio
- **Quando** il valore da validare è `Null`, oppure quattro spazi, oppure solo U+200B e U+00A0
- **Allora** `Error` è vero e `ErrorText` è `Valore richiesto`

### Scenario: valore presente
- **Dato** lo stesso editor
- **Quando** il valore è `Codice` + U+00A0 + `fiscale`
- **Allora** `Error` è falso, `ErrorText` è vuoto e il valore diventa `Codice fiscale`

### Scenario: zero
- **Dato** lo stesso editor
- **Quando** il valore è il numero 0
- **Allora** `Error` è falso

## ZBASE-VED-011 Validazione di un editor normale
Il gestore `ValidateNormal` (con `edNormal` e `edReadOnly`) esegue la sanificazione e la regola di dominio, ma non l'obbligatorietà: parte sempre da `Error` falso e `ErrorText` vuoto, anche se chi lo chiama li aveva già impostati (DIV-VED-9). Un valore `Null` non è mai un errore.

### Scenario: campo facoltativo vuoto
- **Dato** un editor normale
- **Quando** il valore è `Null`
- **Allora** `Error` è falso e `ErrorText` è vuoto

### Scenario: testo con spazio unificatore
- **Dato** lo stesso editor
- **Quando** il valore è `Via` + U+00A0 + `Roma`
- **Allora** il valore diventa `Via Roma`

## ZBASE-VED-012 Sanificazione del testo negli editor
`SanificaDisplayValue` ripulisce il testo digitato o incollato con `TzSanificazione.Sanifica` al livello predefinito (`OpzioniPredefinite`, `ZBASE-SAN-001`), su più righe se le proprietà sono quelle di un memo (`TcxCustomMemoProperties`), su una riga altrimenti (`ZBASE-SAN-003`, `ZBASE-SAN-006`). Non tocca il valore se: la proprietà `dx.SanificaTesto` è falsa; il valore è `Null`, `Empty` o non è un testo (un numero resta numero); `Sender` non è un `TcxCustomEdit`; le proprietà non sono di un editor di testo (`TcxCustomTextEditProperties`); sono quelle di un editor RTF (`TcxRichEditProperties`); sono quelle di una tendina (`TcxCustomDropDownEditProperties`: combo, lookup, picklist, dove il testo è una chiave o una voce di elenco); l'editor è una casella password (`EchoMode` = `eemPassword`); il testo è vuoto o sembra marcatura (`TzSanificazione.SembraMarcatura`, `ZBASE-SAN-008`). `SanificaTesto` vale vero dopo la creazione di `dx`; l'applicazione può impostarlo all'avvio in base alla configurazione dell'ente, ma oggi nessuna applicazione lo fa.

### Scenario: virgolette tipografiche
- **Dato** un `TcxTextEdit` normale e `SanificaTesto` vero
- **Quando** il valore da validare è `Mario “Rossi”` con le virgolette tipografiche
- **Allora** il valore diventa `Mario "Rossi"`

### Scenario: memo e riga singola
- **Dato** il testo `Riga uno` + tre spazi + a capo + `Riga due` + spazio
- **Quando** lo valida un `TcxMemo`, e poi un `TcxTextEdit` con il testo `Via Roma` + a capo + `12`
- **Allora** il memo conserva l'a capo e toglie gli spazi (`Riga uno` + a capo + `Riga due`); il campo a riga singola trasforma l'a capo in spazio (`Via Roma 12`)

### Scenario: casi in cui non si tocca
- **Dato** un editor con `SanificaTesto` falso, oppure con `EchoMode` password, oppure un `TcxComboBox`, oppure il testo `{"nome": “x”}`
- **Quando** il valore contiene U+00A0 o virgolette tipografiche
- **Allora** il valore resta identico

## ZBASE-VED-013 Regola di dominio sul valore
`ValidaDominio` (gestore `ValidaDominio`, chiamato da `ValidateRequired` e `ValidateNormal` dopo la sanificazione) non fa niente se `Error` è già vero o se il valore è `Null` o `Empty`. Cerca il dominio del campo con `DominioDelSender`: restituisce `nil` se `Sender` non è un editor, se il suo collegamento non è `TcxDBEditDataBinding` (editor non DB e editor in linea delle griglie), se il campo non ha `Origin`, se `Base` non è assegnato; altrimenti il dominio dal dizionario dati (`Base.zDataDictionary.Get(Field.Origin, False)`). Solo se il dominio ha `SanificaEmail` il valore viene trattato come indirizzo (`TzSanificazioneEmail.Sanifica`, `ZBASE-SAN-009`, `ZBASE-SAN-011`): se l'esito è vuoto il valore diventa `Null`; se valido diventa l'indirizzo normalizzato; se non valido `Error` è vero e `ErrorText` è `Indirizzo e-mail non valido: ` seguito dal motivo. Il blocco definitivo resta ai trigger del database.

### Scenario: editor senza campo
- **Dato** un `TcxTextEdit` non collegato a un dataset
- **Quando** il valore è `non-un-indirizzo`
- **Allora** nessuna regola e-mail si applica: `Error` è falso e il valore resta com'è

### Scenario: campo e-mail non valido
- **Dato** un editor collegato a un campo il cui dominio ha `SanificaEmail`
- **Quando** il valore è `a@b.it, c@d.it`
- **Allora** `Error` è vero e `ErrorText` è `Indirizzo e-mail non valido: Contiene piu' di un carattere @`

## ZBASE-VED-014 Riempimento della tendina a selezione multipla
`FillItems(Elenco)` svuota le voci della tendina (`Properties.Items`) e ne aggiunge una per riga di `Elenco`, nella forma `Chiave=Descrizione`: la chiave diventa `ShortDescription` (il codice che si salva), la parte dopo il segno `=` diventa `Description` (il testo mostrato); se la descrizione è vuota si mostra la chiave. `FillItem(Descrizione, Chiave)` aggiunge una voce in coda senza svuotare. Con un elenco vuoto la tendina resta senza voci.

### Scenario: due voci
- **Dato** un `TcxCheckComboBox` e le righe `A=Alfa` e `B=Beta`
- **Quando** si chiama `FillItems`
- **Allora** le voci sono due: `A` mostrata come `Alfa` e `B` mostrata come `Beta`

### Scenario: descrizione mancante
- **Dato** la riga `C=`
- **Quando** si chiama `FillItems`
- **Allora** la voce ha chiave `C` e descrizione `C`

### Scenario: riempimento ripetuto
- **Dato** una tendina già riempita con tre voci
- **Quando** si chiama `FillItems` con una sola riga
- **Allora** resta una sola voce

## ZBASE-VED-015 Abilitazione delle voci
`EnableItems(Elenco)` abilita le voci la cui chiave (`ShortDescription`, non la descrizione) compare in `Elenco` e disabilita tutte le altre; con un elenco vuoto le disabilita tutte. `EnableItem(Chiave, Abilitata)` cambia solo la voce con quella chiave, senza distinguere maiuscole e minuscole; se non esiste non fa niente e non solleva errori.

### Scenario: abilitazione per elenco
- **Dato** le voci `A`, `B`, `C`
- **Quando** si chiama `EnableItems` con l'elenco `A`, `C`
- **Allora** `A` e `C` sono abilitate, `B` è disabilitata

### Scenario: voce singola
- **Dato** le voci `A` e `B`
- **Quando** si chiama `EnableItem('b', False)`
- **Allora** `B` è disabilitata e `A` resta com'era

## ZBASE-VED-016 Valore salvato e stati di selezione
Con `InitProperties` di tipo `ctCheckComboBox` la tendina usa un valore personalizzato: i due gestori `cxDBCheckComboBoxPropertiesEditValueToStates` e `cxDBCheckComboBoxPropertiesStatesToEditValue` (assegnati a `OnEditValueToStates` e `OnStatesToEditValue`) delegano agli helper `EditValueToStates` e `StatesToEditValue` dell'editor ricevuto come `Sender`; con `Sender` `nil` non fanno niente (DIV-VED-4). `StatesToEditValue` compone il testo `Codice1; Codice2; ` con il delimitatore (`Properties.Delimiter`, `; ` nell'inizializzazione) dopo ogni voce selezionata, anche l'ultima, e dà `Null` se nessuna è selezionata. `EditValueToStates` parte con tutte le voci deselezionate; con `Null` si ferma lì; altrimenti aggiunge il delimitatore al valore e seleziona ogni voce la cui chiave compare come sottostringa del valore (DIV-VED-3). Andata e ritorno restituiscono le stesse voci.

### Scenario: conversione di andata
- **Dato** le voci `A`, `B`, `C` con delimitatore `; ` e il valore `A; C; `
- **Quando** si chiama `EditValueToStates`
- **Allora** `A` e `C` sono selezionate, `B` no

### Scenario: conversione di ritorno
- **Dato** le stesse voci con `A` selezionata e `C` selezionata
- **Quando** si chiama `StatesToEditValue`
- **Allora** il valore è `A; C; `; con nessuna voce selezionata è `Null`

### Scenario: codici che si contengono
- **Dato** le voci `A` e `AB`
- **Quando** il valore è `AB; `
- **Allora** oggi risultano selezionate entrambe (comportamento sbagliato, DIV-VED-3)

## ZBASE-VED-017 Editor attivo e griglia in modifica
`dx.ActiveControl` restituisce l'editor DevExpress che ha il focus, risalendo dal controllo interno al suo proprietario (`IcxInnerEditHelper`, `IcxContainerInnerControl`), oppure `nil` se il controllo attivo non è un editor o non c'è. `dx.IsActiveControl(Editor)` confronta l'editor con `ActiveControl`; `dx.IsActiveControl(Griglia)` è vero se l'editor attivo si trova dentro quella griglia (risalendo i `Parent`), quindi solo mentre una cella è in modifica: una griglia con il focus ma senza cella in modifica dà falso, perché la sua area non è un editor (DIV-VED-8). `dx.ActiveGrid` restituisce la vista (`TcxGridDBTableView`) della griglia che contiene l'editor attivo, con lo stesso limite, o `nil`. `dx.GridEditable(Vista)` è vero se `OptionsData.Editing` della vista è vero; con `nil` è falso.

### Scenario: nessun controllo attivo
- **Dato** un programma senza controllo attivo
- **Quando** si chiamano `ActiveControl` e `ActiveGrid`
- **Allora** i risultati sono `nil`

### Scenario: editor non attivo
- **Dato** un `TcxTextEdit` creato ma senza focus
- **Quando** si chiama `IsActiveControl(Editor)`
- **Allora** il risultato è falso

### Scenario: griglia di sola consultazione
- **Dato** una vista con `OptionsData.Editing` falso
- **Quando** si chiama `GridEditable(Vista)`
- **Allora** il risultato è falso; con `Editing` vero è vero, e con `nil` è falso

## ZBASE-VED-018 Larghezza suggerita per un campo
`dx.FieldSize(Campo)` suggerisce quanti caratteri mostrare: 20 se il campo è `nil` o di un tipo non elencato; per i campi di testo (`ftString`, `ftFixedChar`, `ftWideString`) 20 se `Size` è da 0 a 20, 50 da 21 a 50, 100 oltre; 5 per `ftBoolean`; 20 per interi, numeri con virgola, valute, date e ore; 999 per i campi lunghi (`ftBlob`, `ftMemo`, `ftGraphic`, `ftFmtMemo`, `ftTypedBinary`). Un memo Unicode (`ftWideMemo`) non è elencato e riceve 20 (DIV-VED-6).

### Scenario: campi di testo
- **Dato** campi di testo con `Size` 20, 21, 50, 51
- **Quando** si chiama `FieldSize`
- **Allora** i risultati sono 20, 50, 50, 100

### Scenario: altri tipi
- **Dato** un campo booleano, uno intero, un memo e un campo `nil`
- **Quando** si chiama `FieldSize`
- **Allora** i risultati sono 5, 20, 999 e 20

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-VED-1 🟡 (dedotta) | Il valore predefinito di un editor vuoto non è lo stesso nelle due famiglie di funzioni: `ValueInt` e `ValueDouble` restituiscono -1, `asInteger` -1 ma `asDouble` 0, `ValueDate` -700000 (`NullDate`) e `asDateTime` 0 | -1 è un valore valido (un importo negativo, un indice): chi legge con `ValueDouble` non distingue un campo vuoto da -1, e lo stesso campo letto con `asDouble` dà 0. Il programma si comporta in modo diverso secondo la funzione scelta |
| DIV-VED-2 🟢 (dedotta) | `SetValue` tratta `Null` ed `Empty` come vuoto, ma `isEmpty` (e quindi `asString`, `asInteger`, `asDouble`, `asDateTime`) solo `Null` | Con un valore `Unassigned` `isEmpty` è falso e `asInteger` dà 0 invece di -1; capita solo se un editor conserva `Empty` |
| DIV-VED-3 🟡 (dedotta) | `EditValueToStates` seleziona una voce se la sua chiave compare come sottostringa del valore, e una chiave vuota compare sempre | Con le chiavi `A` e `AB` il valore `AB; ` seleziona anche `A`; una voce con chiave vuota risulta sempre selezionata. Il dato salvato viene letto in modo diverso da come è stato scritto, e un salvataggio successivo lo corregge o lo peggiora senza che l'utente se ne accorga |
| DIV-VED-4 🟡 (dedotta) | DevExpress chiama `PrepareDisplayValue` con `Sender` uguale a `nil` (`CalculateCheckStatesByEditValue(nil, ...)`) e i due gestori ignorano `nil` | Dove DevExpress calcola il testo senza un editor (probabilmente le celle di una colonna di griglia con questa tendina) gli stati restano tutti deselezionati e compare il testo di selezione vuota anche se il campo ha un valore. Da verificare con una colonna vera |
| DIV-VED-5 🟡 (dedotta) | `DataBind` converte il collegamento dati dell'editor in `TcxDBEditDataBinding` senza controllare il tipo | Chiamato su un editor non DB (`TcxTextEdit`) scrive sorgente e campo in un oggetto di classe diversa: errore di accesso o memoria alterata. Oggi lo chiama solo `wizVariazioneFrm`, con editor DB |
| DIV-VED-6 🟡 (dedotta) | `FieldSize` non conosce `ftWideMemo` (né i tipi non elencati, come GUID): dà 20 | Un memo Unicode, che FireDAC crea per i testi lunghi, viene dimensionato come un codice di 20 caratteri invece che come un campo lungo (999) |
| DIV-VED-7 🟢 (dedotta) | `IsActiveControl(Editor)` confronta `ActiveControl` con l'editor ricevuto, senza controllare che sia assegnato | `IsActiveControl(nil)` è vero quando nessun editor è attivo: «nessun editor» risulta «l'editor attivo» |
| DIV-VED-8 🟢 (dedotta) | `ActiveControl` restituisce un editor solo se il controllo attivo è un editor o un controllo interno di un editor, e per i controlli interni converte il proprietario in `TcxCustomEdit` senza controllare; `ActiveGrid` e `IsActiveControl(Griglia)` ne dipendono, e `ActiveGrid` converte la vista in `TcxGridDBTableView` senza controllare | Una griglia con il focus ma senza cella in modifica non risulta attiva (`ActiveGrid` è `nil`): chi lo legge come «la griglia ha il focus» sbaglia. Un controllo interno il cui proprietario non è un editor (per esempio una lista a discesa) produce una conversione non valida; una vista non `TcxGridDBTableView` pure |
| DIV-VED-9 🟢 (dedotta) | `ValidateNormal` imposta `Error` falso e `ErrorText` vuoto prima della regola di dominio, senza guardare quelli in ingresso | Un errore segnalato da un gestore precedente viene cancellato; nessun effetto oggi, perché `OnValidate` è il solo gestore e parte con `Error` falso |
