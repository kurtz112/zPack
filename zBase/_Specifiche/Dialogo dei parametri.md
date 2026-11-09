---
area: Dialogo dei parametri
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/002
---

# Dialogo dei parametri

Questa specifica descrive la finestra che chiede all'utente i parametri di una query, di una stored procedure o di una lista di parametri: il componente `TzParamDialog` e le sei funzioni libere `ShowParams` della unit `zBase\zFrmParams.pas` (con `zFrmParams.dfm`). La unit è compilata: la richiamano `zDbView`, `zDbChart`, `zDbPivot`, `zDbRecordView`, `zDbScheduler` e `zDbTree` (pacchetto `zBase`, via `zBaseRegister`) e, fuori da zPack, 18 unit di WT e 2 di Gesty (`dmAssistenzaScolastica`, `dmRisorse`) che chiamano `ShowParams`; le altre unit di Gesty e WT che hanno `zFrmParams` nella `uses` (`frmGRS`, `frmPrenotazioniAule`, `dmPersonaleScheda` e altre) non la chiamano. I file `zFrmParams - con VerticalGrid.pas` e `pippo.pas` sono storia e non fanno parte di questa specifica. Il disegno della finestra (`TzDialog`, layout, pulsanti) non è descritto qui se non per il legame con il dialogo; per il costruttore degli editor vale `TzFormBuilder`.

**Come funziona.** `TzParamDialog` è un `TComponent`, non una form: possiede un `TzDialog` (proprietà `zDialog`, la finestra vera, una `TdxRibbonForm` con layout DevExpress e pulsanti Ok/Annulla) e un elenco interno di parametri (`InternalParams`, un `TParams`). Ogni `ShowParams` copia i parametri da mostrare nell'elenco interno (`LoadParams` di `zParamsHelper`), costruisce un editor per ognuno, lascia al chiamante la possibilità di personalizzare gli editor, mostra la finestra in modo modale e, **solo se l'utente conferma**, riporta i valori nei parametri originali e, se richiesto, riapre il dataset o esegue il comando. Le funzioni libere creano un dialogo nuovo per ogni chiamata (`Application.CreateForm`) e lo liberano subito; il metodo omonimo si usa direttamente solo quando serve prima personalizzare il dialogo.

Chi la usa oggi, con le forme verificate nei sorgenti: `TzFbDataSet` (`zDbView` e le altre viste di zPack con `ShowParams(..., 'Parametri', True)`, `dmImmobili`, `dmPagoPA`, `dmInterrogazioniOLD`); la procedura wrapper `TSP_*` (classe derivata da `TzStoredProc`: 8 chiamate in WT, 2 in Gesty); `TParams` (14 chiamate fra WT e Gesty, sia per chiedere dati sia per mostrare risultati); gli overload per `TFDQuery`, `TFDStoredProc` e `TFDParams` non hanno nessuna chiamata diretta (il secondo lo usa solo l'overload di `TzStoredProc`). Una sola chiamata di Gesty e WT passa `HideParams` (`dmRisorse.Integrazione`).

**Test che coprono quest'area.** Nessuna prova in `zPackTests` oggi. La bozza `Test.zFrmParams` prova, senza mostrare mai la finestra, l'ingresso con `TParams` (metodo e funzioni libere) e `TFDParams`: quali parametri compaiono, le etichette, il tipo di editor, i valori iniziali, `GetEditor`, `Enum`, `ChangeEditorType`, il caso senza parametri e il fatto che i parametri del chiamante non cambiano prima della conferma (ZBASE-PAR-001, 002, 003, 004, 005, 006, 007, 008, 009), più le divergenze DIV-PAR-3, 4, 5, 6, 9 e 12 come fotografie del comportamento attuale. Per arrivare agli editor senza aprire il dialogo modale i test usano `BeforeShowParamsProc`, che gira dopo la costruzione degli editor e prima di `ShowModal`, e la interrompono con un'eccezione. Restano senza prova, perché aprono la finestra modale o toccano il database: `ShowModal`, conferma e annullamento, il ritorno dei valori nei parametri (`SaveParamValues` è privata), i quattro overload che richiedono un dataset o una procedura preparati (`TzFbDataSet`, `TFDQuery`, `TFDStoredProc`, `TzStoredProc`: ZBASE-PAR-002, 003 per i parametri di master/detail e `QueryParams`, ZBASE-PAR-008), la posizione salvata nel file `.Dlgs`. Si collaudano con la sonda `zapp` sul banco.

## ZBASE-PAR-001 Il dialogo e la finestra interna
`TzParamDialog.Create` crea l'elenco interno dei parametri (vuoto) e il `TzDialog` (`zDialog`, di proprietà del componente); `Destroy` libera entrambi. Prima di una `ShowParams` la finestra non ha nessun editor (`GetEditor` restituisce `nil` per qualunque nome). `TzParamDialog` non è una form: il file `zFrmParams.dfm` descrive una form `zParamDialog` di una versione precedente e non viene mai caricato (DIV-PAR-11). Le funzioni libere lo creano con `Application.CreateForm(TzParamDialog, ...)`, lo usano una volta e lo liberano in un `finally`: il dialogo non va riusato per due chiamate di seguito, perché la costruzione degli editor ripulisce il layout con `TzFormBuilder.Clear` e quella pulizia, con editor già presenti, libera due volte i controlli già distrutti dal layout e si ferma con un errore di indice (ZBASE-FRB, DIV-FRB-1).

### Scenario: dialogo appena creato
- **Dato** un `TzParamDialog` creato con `Create(nil)`
- **Quando** si legge `zDialog` e si chiede `GetEditor('QUALSIASI')`
- **Allora** `zDialog` è assegnato e `GetEditor` restituisce `nil`

## ZBASE-PAR-002 Punti di ingresso e sorgenti dei parametri
Sei forme di `ShowParams`, tutte con `LayoutID` come primo argomento e tutte restituenti `True` se l'utente ha confermato (o se non c'era niente da chiedere), `False` se ha annullato:

| Sorgente | Argomenti propri dopo `Caption` | Che cosa succede dopo la conferma |
|---|---|---|
| `TzFbDataSet` | `doReopen`, `BeforeShowParamsProc`, `IncludeOutputParams`, `HideParams` | scrive i parametri; se `doReopen`, riapre il dataset con `Reopen` sotto `StartWait('Attendere...', true)` |
| `TFDQuery` | `doExecute`, ... | scrive i parametri; se `doExecute`, `ExecSQL` sotto `StartWait` |
| `TFDStoredProc` | `doExecute`, ... | scrive i parametri; se `doExecute`, `ExecProc` sotto `StartWait` |
| `TzStoredProc` (wrapper `TSP_*`) | `doExecute`, ... | prepara la procedura interna (`CreateInternalStoredProc`), chiama l'overload di `TFDStoredProc`, poi riporta i valori nelle proprietà del wrapper (`ApplyInternalStoredProcParams`) |
| `TParams` | `BeforeShowParamsProc`, `IncludeOutputParams`, `HideParams` | scrive i valori nella lista del chiamante |
| `TFDParams` | come `TParams` | come `TParams` |

Con un oggetto non assegnato (`nil`) le quattro forme per dataset e procedure restituiscono `False` senza fare altro. Le forme per `TzFbDataSet`, `TFDQuery` e `TFDStoredProc` preparano l'oggetto se non lo è già (`Prepare`), perché i parametri esistono solo dopo la preparazione. Le funzioni libere hanno gli stessi argomenti e lo stesso valore di ritorno del metodo; tutte inoltrano `HideParams` (DIV-PAR-1, corretta nel rilascio 002).

### Scenario: dataset non assegnato
- **Dato** un riferimento `nil` a `TzFbDataSet`
- **Quando** si chiama `ShowParams('X', DataSet)`
- **Allora** il risultato è `False` e non compare nessuna finestra

### Scenario: procedura wrapper
- **Dato** un wrapper `TSP_AZ_CREA_NUOVA_AZIENDA` con parametri di ingresso
- **Quando** si chiama `ShowParams('Azienda.CreaNuovaAzienda', sp)` e l'utente conferma
- **Allora** le proprietà del wrapper contengono i valori digitati e il chiamante può eseguire `sp.ExecuteAndCommit`

## ZBASE-PAR-003 Quali parametri compaiono
Compaiono i parametri della sorgente tranne:
- quelli elencati in `HideParams`, separati da virgola o da punto e virgola, senza distinguere maiuscole e minuscole;
- i parametri di uscita (`ptOutput`, `ptResult`), a meno che `IncludeOutputParams` sia vero;
- per un `TzFbDataSet`, in aggiunta, i parametri che il dataset usa per il collegamento master/detail (`IsMasterDetailParam`: esiste un campo con lo stesso nome nel dataset del `DataSource`) e quelli elencati nei `QueryParams` della configurazione di sistema (`Base.QueryParams`, se `Base` è assegnato): i valori di entrambi li fornisce il programma, non l'utente.

L'ordine degli editor è quello dei parametri. Un parametro nascosto resta nella sorgente con il suo valore e non ha editor (`GetEditor` restituisce `nil`).

### Scenario: parametro nascosto
- **Dato** una lista con `DATA_INIZIO`, `DATA_FINE` e `NASCOSTO`
- **Quando** si chiama il dialogo con `HideParams = 'nascosto'`
- **Allora** `DATA_INIZIO` e `DATA_FINE` hanno un editor e `NASCOSTO` no

### Scenario: più nomi nascosti
- **Dato** `HideParams = 'A,B;C'`
- **Quando** si costruiscono gli editor
- **Allora** `A`, `B` e `C` non compaiono

### Scenario: parametri di uscita
- **Dato** una lista con un parametro di ingresso e uno di uscita
- **Quando** `IncludeOutputParams` è falso
- **Allora** compare solo il parametro di ingresso; con `IncludeOutputParams` vero compaiono entrambi

### Scenario: risultati mostrati senza il permesso (caso reale)
- **Dato** una lista di soli parametri `ptOutput` (come `resultParams` in `dmFattureElettroniche`)
- **Quando** si chiama `ShowParams(..., 'Risultati')` con `IncludeOutputParams` falso
- **Allora** non compare nessun editor, il dialogo non si apre e la chiamata restituisce `True` (il chiamante di `dmFattureElettroniche` passa `IncludeOutputParams = True`: DIV-PAR-12, corretta)

## ZBASE-PAR-004 Nessun parametro da chiedere
Se dopo il filtro (ZBASE-PAR-003) non resta nessun parametro, `Execute` restituisce `True` senza costruire editor, senza chiamare `BeforeShowParamsProc` e senza mostrare la finestra: la sorgente prosegue come se l'utente avesse confermato (e quindi `doReopen` o `doExecute` scattano). Vale per ogni overload e per le funzioni libere. È il comportamento voluto per le procedure senza parametri di ingresso; è ciò che nascondeva l'errore di DIV-PAR-12, ora corretto nel chiamante.

### Scenario: lista vuota
- **Dato** un `TParams` senza parametri
- **Quando** si chiama `ShowParams('X', Params)`
- **Allora** il risultato è `True` e `BeforeShowParamsProc` non viene chiamata

### Scenario: tutti i parametri nascosti
- **Dato** due parametri, `HideParams = 'P1;P2'`
- **Quando** si chiama il dialogo
- **Allora** il risultato è `True` senza finestra

## ZBASE-PAR-005 Etichetta del parametro
Il titolo accanto all'editor si ricava dal nome del parametro (`ParamCaption`, privata): si toglie il prefisso `PARAM_` (solo all'inizio, maiuscolo), le iniziali delle parole separate da sottolineatura diventano maiuscole, il resto minuscolo, le sottolineature diventano spazi. Un nome tutto maiuscolo diventa comunque «Iniziale maiuscola e resto minuscolo». Un nome fatto solo di `PARAM_` dà un'etichetta vuota e l'elemento del layout resta senza titolo.

| Nome del parametro | Etichetta |
|---|---|
| `PARAM_DATA_INIZIO` | `Data Inizio` |
| `COSTO_ORARIO` | `Costo Orario` |
| `Data_Evasione` | `Data Evasione` |
| `ID_INCARICO` | `Id Incarico` |
| `DataFine` | `Datafine` (DIV-PAR-5) |

### Scenario: prefisso e sottolineature
- **Dato** un parametro `PARAM_DATA_INIZIO`
- **Quando** si costruisce l'editor
- **Allora** l'elemento del layout ha il titolo `Data Inizio`

## ZBASE-PAR-006 Editor scelto per il tipo di parametro
`CreateEditor` (privata) crea un editor per parametro con lo stesso nome del parametro (il nome del parametro diventa il nome del componente: deve essere un identificatore valido, DIV-PAR-8) e vi mette il valore iniziale; un valore nullo lascia l'editor vuoto.

| Tipo del parametro | Editor |
|---|---|
| `ftString`, `ftFixedChar`, `ftWideString` | `TcxTextEdit` |
| `ftSmallint`, `ftInteger`, `ftWord`, `ftAutoInc`, `ftLargeint` | `TcxSpinEdit` con valori interi |
| `ftFloat`, `ftCurrency`, `ftBCD` | `TcxSpinEdit` con valori decimali (`ValueType = vtFloat`) |
| `ftBoolean` | `TcxCheckBox` |
| `ftDate`, `ftDateTime`, `ftTimeStamp` | `TcxDateEdit` |
| `ftTime` | `TcxTimeEdit` |
| `ftMemo`, `ftFmtMemo` | `TcxMemo` |
| `ftGraphic` | `TcxImage` |
| `ftUnknown` e ogni altro tipo | `TcxTextEdit` (DIV-PAR-6) |

Gli editor numerici hanno `UseNullString`: lasciati vuoti restano vuoti e si leggono come nulli, non come 0 (`dx.GetValue`). Un parametro di uscita (`ptOutput`) ha l'editor in sola lettura; la sola lettura vale solo per la lista `TParams`, perché le sorgenti FireDAC portano nell'elenco interno tutti i parametri come `ptInputOutput` (DIV-PAR-3).

### Scenario: tipi
- **Dato** parametri `NOME` (`ftString`), `QUANTITA` (`ftInteger`), `IMPORTO` (`ftCurrency`), `ATTIVO` (`ftBoolean`), `DAL` (`ftDate`)
- **Quando** si costruiscono gli editor
- **Allora** gli editor sono `TcxTextEdit`, `TcxSpinEdit` (interi), `TcxSpinEdit` (decimali), `TcxCheckBox` e `TcxDateEdit`

### Scenario: valore iniziale
- **Dato** il parametro intero `NUMERO` con valore 42
- **Quando** si costruisce l'editor
- **Allora** l'editor contiene 42; con parametro nullo l'editor è vuoto e `dx.GetValue` restituisce nullo

### Scenario: parametro di uscita
- **Dato** un `TParams` con `RISULTATO` di tipo `ptOutput` e `IncludeOutputParams` vero
- **Quando** si costruiscono gli editor
- **Allora** l'editor di `RISULTATO` è in sola lettura e quello di un parametro di ingresso no

## ZBASE-PAR-007 Personalizzazione prima della visualizzazione
`BeforeShowParamsProc` (se assegnata) è chiamata **una volta**, dopo la costruzione degli editor e prima della finestra, con il dialogo stesso. Dentro si può:
- leggere un editor con `GetEditor(nome)` (cerca per nome senza distinguere maiuscole; `nil` se non esiste o se il parametro è nascosto);
- visitare tutti i parametri con `Enum(proc)`: la procedura riceve il parametro interno e il suo editor, nell'ordine dell'elenco;
- cambiare il tipo di un editor con `ChangeEditorType(nome, tipo)`: il vecchio editor è liberato, il nuovo prende lo stesso nome, la stessa etichetta e il valore del parametro, e viene restituito; chi passa il tipo lo imposta poi con `dx.InitPickList`, `dx.InitLookup` e simili (`dmIntestatari`, `dmRC_EsecuzioniForzate`); in alternativa si chiama direttamente `zDialog.zFormBuilder.ChangeControlType(tipo, nome, etichetta, valore)` (usato da `dmCommon`, `dmAssistenzaScolastica`, `dmRC_Ingiunzioni`, `dmRisorse`);
- dimensionare la finestra (`zDialog.Width`, `zDialog.Height`, usati da quasi tutte le chiamate).

Il nuovo editor creato da `ChangeEditorType` non riceve le impostazioni di `CreateEditor`: né la sola lettura per i parametri di uscita né `UseNullString` (DIV-PAR-9).

### Scenario: sostituzione del tipo
- **Dato** un parametro `ANNO` di tipo `ftString` con editor di testo
- **Quando** la procedura chiama `ChangeEditorType('ANNO', ctSpin)`
- **Allora** `GetEditor('ANNO')` restituisce il nuovo `TcxSpinEdit` e l'etichetta dell'elemento è rimasta `Anno`

### Scenario: elenco dei parametri
- **Dato** tre parametri di cui uno nascosto
- **Quando** la procedura chiama `Enum`
- **Allora** la procedura di visita è chiamata due volte, con ciascun parametro e il suo editor

### Scenario: nome inesistente
- **Dato** un nome che non è fra i parametri
- **Quando** si chiama `GetEditor`
- **Allora** il risultato è `nil`; con `ChangeEditorType` si solleva `EDatabaseError` (DIV-PAR-4)

## ZBASE-PAR-008 Conferma, annullamento e ritorno dei valori
Fino alla conferma il dialogo **non tocca** i parametri del chiamante: lavora sulla copia interna. Se l'utente conferma (`mrOk`), `SaveParamValues` scrive in ogni parametro interno il valore del suo editor (`dx.GetValue`: un editor numerico vuoto dà nullo) e poi i valori tornano alla sorgente:
- con `TFDParams`, `TFDQuery`, `TFDStoredProc`, `TzFbDataSet` e `TzStoredProc` parametro per parametro con `TzParamValue.Assegna`, che converte il valore nel tipo del parametro (Mantis #141); se la conversione non è possibile solleva `EzParamTypeMismatch`, citando parametro, tipo e valore, dopo aver svuotato il parametro: la finestra è già chiusa e le azioni successive (`doReopen`, `doExecute`) non partono;
- con `TParams` con `Params.Assign` della lista interna, che **sostituisce l'intera lista** del chiamante (DIV-PAR-2).

Se l'utente annulla, o chiude con Esc, il risultato è `False`, i parametri del chiamante restano come erano e né `doReopen` né `doExecute` né `ApplyInternalStoredProcParams` vengono eseguiti. Se la `BeforeShowParamsProc` solleva un'eccezione la finestra non si apre, l'eccezione esce da `ShowParams` e i parametri del chiamante restano com'erano.

### Scenario: annullamento
- **Dato** una lista con `DATA = 01/01/2026` e il dialogo aperto
- **Quando** l'utente cambia la data e preme Annulla
- **Allora** il risultato è `False` e `DATA` vale ancora 01/01/2026

### Scenario: conferma con riapertura
- **Dato** un dataset con `doReopen = True`
- **Quando** l'utente conferma
- **Allora** i parametri del dataset hanno i nuovi valori e il dataset viene riaperto sotto «Attendere...»

### Scenario: testo non convertibile
- **Dato** un parametro intero e un utente che digita `abc` in un editor di testo (parametro non ancora descritto dal server)
- **Quando** conferma
- **Allora** `SaveParams` solleva `EzParamTypeMismatch` e il dataset non viene riaperto

### Scenario: interruzione prima della finestra
- **Dato** una lista con `NUMERO = 7` e una procedura che solleva un'eccezione
- **Quando** si chiama `ShowParams`
- **Allora** l'eccezione esce, `NUMERO` vale ancora 7 e la lista ha lo stesso numero di parametri

## ZBASE-PAR-009 Finestra, LayoutID e legame con `TzDialog`
`Execute` passa `LayoutID`, il titolo e il momento di personalizzazione a `TzDialog.Execute`, che: assegna il titolo (anche vuoto: DIV-PAR-7), usa `LayoutID` se non è vuoto (altrimenti resta quello del costruttore di form, vuoto), assegna `PopupParent := GetPopupParent(Self)` (DIV-PAR-13), rilegge la posizione dal file di configurazione `.Dlgs` (sezione = `LayoutID`, solo se `Base` è assegnato), mostra la finestra modale e, alla chiusura, ne salva la posizione. `LayoutID` serve quindi a conservare la posizione e la dimensione per ogni dialogo (per questo ogni chiamata ha il suo: `'Azienda.CreaNuovaAzienda'`, `sp.StoredProcName + '_params'`, `ViewID + '_Params'`); `LoadLayout` e `SaveLayout` del costruttore non fanno niente (`ZBASE-FRB`), quindi il layout degli editor non si salva. Il valore predefinito della finestra: bordo `bsSizeToolWin` (ridimensionabile), posizione centrata sulla finestra madre, `EnterAsTab` vero: Invio passa al campo successivo (Maiusc+Invio al precedente) tranne dentro un memo o con un elenco aperto; il pulsante Ok è quello predefinito e Annulla risponde a Esc (`DefaultOk` e `DefaultCancel` vengono dal `.dfm` di `TzDialog`: vedi ZCOMMON-OKC-004). Il primo campo riceve il fuoco con un ritardo di 100 ms.

### Scenario: valori iniziali della finestra
- **Dato** un dialogo appena creato
- **Quando** si leggono le proprietà della finestra interna
- **Allora** `EnterAsTab` è vero, il pulsante Ok è predefinito, Annulla risponde a Esc e `zFormBuilder.LayoutID` è vuoto

### Scenario: posizione ricordata
- **Dato** `LayoutID = 'Comuni.CreaNuovoComune'` e un programma con `Base` assegnato
- **Quando** l'utente sposta la finestra e conferma
- **Allora** alla chiamata successiva la finestra riappare nella stessa posizione

## Divergenze note
Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `zFrmParams.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-PAR-1 ✅ (corretta, rilascio 002) | Le funzioni libere per `TzFbDataSet` e `TFDQuery` non inoltravano `HideParams` (le altre quattro forme sì). Ora lo inoltrano tutte e sei | `dmRisorse.Integrazione` (`ShowParams(..., 'ID_INCARICO')`) non mostra più `ID_INCARICO`. Le forme per dataset e query non si provano senza connessione: la prova copre `TParams` |
| DIV-PAR-2 🟡 (dedotta) | `SaveParams(TParams)` esegue `Params.Assign(Self)` (`zParamsHelper`), mentre `LoadParams(TParams)` ha saltato nascosti e uscita | Con `HideParams` o con parametri di uscita non inclusi, dopo la conferma la lista del chiamante contiene solo i parametri mostrati: quelli nascosti spariscono insieme al valore e `ParamByName` fallirebbe dopo. Oggi nessuna chiamata con `TParams` usa `HideParams`, per cui il difetto è latente |
| DIV-PAR-3 🟡 (dedotta) | `LoadParams(TFDParams)` porta tutti i parametri nell'elenco interno come `ptInputOutput`; `CreateEditor` imposta la sola lettura solo per `ptOutput` (riga 249). `ptResult` non è mai in sola lettura | Con `IncludeOutputParams` su una sorgente FireDAC i parametri di uscita si possono modificare, e alla conferma il valore digitato viene scritto sul parametro di uscita |
| DIV-PAR-4 🟢 (dedotta) | `ChangeEditorType` controlla `Assigned(Param)` dopo `ParamByName` (150-153), ma `TParams.ParamByName` solleva `EDatabaseError` se il nome manca e non restituisce mai `nil`; `GetEditor` invece restituisce `nil` | Un nome sbagliato in una procedura di personalizzazione interrompe il dialogo con un errore del database, invece di restituire `nil` come promette il controllo morto |
| DIV-PAR-5 🟢 (dedotta) | La funzione interna `InserisciSpazioTraMaiuscole` (174-198) non cambia mai il testo: dopo `zzCapFirst` ogni lettera maiuscola è preceduta da uno spazio o è la prima, e non esistono due maiuscole adiacenti | Un nome come `DataFine` compare come «Datafine», non «Data Fine»: l'inserimento dello spazio non scatta mai |
| DIV-PAR-6 🟡 (dedotta) | `GetCtrlType` non mappa `ftSingle`, `ftExtended`, `ftFMTBcd`, `ftByte`, `ftShortint`, `ftLongWord`, `ftWideMemo`, `ftBlob` e gli altri tipi: `ctDefault`, cioè `TcxTextEdit`. La lista `[ftSingle, ftFloat, ftExtended, ftCurrency, ftBCD, ftFMTBcd]` del blocco `vtFloat` (256) contiene tre tipi che non arrivano mai a un editor numerico | Un parametro numerico `ftFMTBcd` (se FireDAC non lo converte in `ftBCD`) o `ftSingle` si digita come testo; con `TParams` il testo resta una stringa nel parametro (nessuna conversione di tipo), con le sorgenti FireDAC lo converte `TzParamValue` |
| DIV-PAR-7 🟢 (dedotta) | `TzDialog.Execute` assegna sempre `Caption := aCaption`, anche vuoto; `ShowParams` ha `Caption = ''` come predefinito; il titolo `Parametri` del file `zFrmParams.dfm` non si carica mai (`TzParamDialog` non è una form) | Le chiamate senza titolo (6 delle 10 chiamate con `TzStoredProc`, per esempio `dmAzienda` e `dmComuni.CreaNuovoComune`) mostrano una finestra con la barra del titolo vuota |
| DIV-PAR-8 🟢 (dedotta) | `CreateEditor` dà al componente il nome del parametro, senza `ValidateComponentName`; un nome con spazi o simboli solleva `EComponentError`. Il commento di `dmCommon.pas` (riga 1315) «non usare spazi nel nome del parametro» lo conferma | Una lista `TParams` con un nome non valido fa fallire il dialogo con un errore di componente; con i parametri letti dal server non capita |
| DIV-PAR-9 🟢 (dedotta) | `ChangeEditorType` passa da `ChangeControlType`, che crea l'editor col solo tipo e il valore (`CreateControl`): non ripete `ReadOnly` per i parametri di uscita né `UseNullString` e `ValueType` degli editor numerici (252-258) | Un editor numerico sostituito legge un campo vuoto come 0 invece che nullo (anche se `dx.GetValue` copre il caso dello spin vuoto) e un parametro di uscita sostituito diventa modificabile |
| DIV-PAR-10 🟢 (dedotta) | Con `doExecute` vero l'overload di `TzStoredProc` inoltra a quello di `TFDStoredProc`, che esegue `StoredProc.ExecProc` direttamente, senza passare da `ExecuteAndCommit` del wrapper (niente commit né ripristino) | Nessuna chiamata passa `doExecute` vero (tutte falso), quindi non si manifesta; chi lo usasse eseguirebbe la procedura nella transazione del wrapper senza `Commit` |
| DIV-PAR-11 🟢 (dedotta) | `zFrmParams.dfm` descrive una form `TzParamDialog` (bordo, titolo, `KeyPreview`), il metodo `ShowParams` ha variabili mai usate (`WasForceIsNull` nei quattro overload con dataset o procedura) e sotto `end.` restano tre righe di appunti | Rumore: il `.dfm` è incollato alla unit con `{$R *.dfm}` ma nessun codice lo carica; i nomi `zDialog zFormBuilder zSystem zFbDataSet` in fondo non hanno effetto |
| DIV-PAR-12 ✅ (corretta, rilascio 002) | `dmFattureElettroniche.pas` chiamava `ShowParams(sp.StoredProcName + '_result', resultParams, 'Risultati')` con parametri tutti `ptOutput` e senza `IncludeOutputParams`: `Execute` restituiva `True` senza finestra. Ora passa `nil, True` come `dmFlussiAER600` e `dmIntestatari` | Dopo il calcolo dell'imposta di bollo compare il dialogo con «Numero Documenti» e «Imposta di Bollo». Resta vero che senza `IncludeOutputParams` e con soli parametri di uscita il dialogo non si apre (ZBASE-PAR-003). Prova `Divergenza_DIV_PAR_12_...` aggiornata: editor presenti con `IncludeOutputParams` |
| DIV-PAR-13 🟢 (dedotta, da verificare sul banco) | `TzDialog.Execute` assegna `PopupParent := GetPopupParent(Self)` (`zDialog.pas`, 145); `GetPopupParent` risale la catena dei proprietari partendo dal componente che riceve, e `Self` è già una form: restituisce la finestra stessa | La finestra madre del dialogo è il dialogo stesso e non la finestra chiamante: probabile che l'effetto voluto (dialogo sopra la finestra attiva) arrivi solo dalla posizione `poOwnerFormCenter` e dall'ordine modale; da provare con la sonda |
