---
area: Funzioni sui file
progetto: zLibs
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/019
---

# Funzioni sui file

Questa specifica descrive `zLibs\zz.files.pas`: l'elenco dei file di un'area dell'applicazione (modelli di documento, report, guide) con tre provenienze. I file **standard** stanno in una cartella della classe, i file **personalizzati** per un cliente in una sottocartella `__Custom` e prendono il posto di quelli standard con lo stesso nome, i file **condivisi** fra più aree in una cartella `__Shared`. `TzFile` è la scheda di un file (nome, nome del file, cartella, provenienza, estensione, percorso completo, procedura facoltativa) e `TzFiles` l'elenco, una `TCollection` creata con il nome della cartella della classe (`TzFiles.Create('MM_Templates')`). Non è un gestore di file: non apre, copia né cancella niente. Descrive il comportamento atteso, non il codice.

Chi la usa (verificato con una ricerca in `D:\AI\SRC\Wintarif_Group`, `Gesty_Group` e `zTicser`):

| Progetto | Unit | Uso |
|---|---|---|
| WT | `BASE\ConfigModule` (imposta `TzFiles.AppRoot := zSystem.Root_Files` dopo l'accesso); `BASE\zTemplates.Doc.Form` (`TzFiles.Create('MM_Templates')`, `AddFolder(Folder, '*.docx')`, scheda scelta in un elenco); `dbForms\frmGedoStampeMassive` (`TzFiles.Create('Reports')`, `AddFolder(..., '*.fr3')`, mostra `FileName` degli elementi) | modelli di documento e report |
| Gesty, zTicser | `Varie\Files.Lib` (`GetTemplate`: `TzFiles.Create('PDFTemplates')`, `AddFolder(Folder, '*.pdf')`, `GetFileNames(Elenco, True)`, `GetFullFileName`); `BASE\ConfigModule` (la riga `TzFiles.AppRoot := zSystem.Root_Files` è **commentata**: DIV-FIL-5) | modelli PDF |
| Gesty | `BASE\BaseFrm`, `dbForms\frmAbitare_Sostegno`, `frmAbitare_Sostegno_Scheda`, `frmAziendaScheda` citano la unit nella clausola `uses` | in queste unit non compaiono `TzFile` né `TzFiles` (la clausola `uses` è probabilmente un residuo) |

La unit non è elencata in nessun pacchetto (`.dpk`): si compila perché sta nel percorso di ricerca. Esiste un'altra classe `TzFile` in `zOffice\zFileSystem.pas`, con altri campi: le due non si scambiano e una unit che cita entrambe le unit senza qualificare il nome prende quella dichiarata per ultima nella clausola `uses` (DIV-FIL-6). Gli «Scenari» che seguono parlano sempre della classe di questo file.

**Come funziona.** Tre variabili **di classe** (comuni a tutta l'applicazione) decidono dove si cerca: `TzFiles.AppRoot` (la radice dei file dell'applicazione, vuota finché non la imposta il programma), `TzFiles.CustomFolder` (predefinito `__Custom`) e `TzFiles.SharedFolder` (predefinito `__Shared`). I percorsi sono sempre `AppRoot\<CartellaDellaClasse>\<Cartella>\` per i file standard, `AppRoot\<CartellaDellaClasse>\<CustomFolder>\<Cartella>\` per i personalizzati e `AppRoot\<CartellaDellaClasse>\<SharedFolder>\` per i condivisi. `AddFolder` riempie l'elenco: prima i file standard, poi i personalizzati, poi i condivisi; ogni file è aggiunto per nome, quindi quello che arriva dopo sostituisce quello con lo stesso nome già presente.

**Test che coprono quest'area.** `Test.zz.files` (in `zPack\_UnitTest\_src`, 45 prove, su una cartella temporanea nuova per ogni prova; le tre variabili di classe vengono salvate e ripristinate): schede e percorsi, aggiunta e ricerca per nome, composizione delle cartelle, scansione con le tre provenienze e la loro precedenza, filtro, file condivisi, elenco dei nomi, copia, il filtro sui tre tipi di file, l'estensione con asterisco per i condivisi e la fotografia di DIV-FIL-3.

## ZLIBS-FIL-001 La scheda di un file (`TzFile`)
Aggiungendo un file con `Add(Nome, PercorsoCompleto, Tipo, Procedura)` la scheda ricava dal percorso: `FileName` (nome con estensione), `Folder` (cartella **sempre con la barra finale**, oppure vuota se il percorso non ha cartella), `Ext` (estensione con il punto, vuota se il file non ne ha), `FileNameNoExt` (nome del file senza estensione) e `FullFileName` (`Folder` più `FileName`, oppure il solo `FileName` se `Folder` è vuota). `Custom`, `Shared` e `IsProc` dicono se il tipo è personalizzato, condiviso o procedura; per i file standard sono tutti falsi. Un elemento aggiunto con `Add` senza parametri è vuoto e di tipo standard, senza procedura.

### Scenario: percorso completo
- **Dato** `Add('Rapporto', 'C:\Dati\Rapporto.fr3', ftNormal, nil)`
- **Quando** si leggono le proprietà
- **Allora** `FileName` è `Rapporto.fr3`, `Folder` è `C:\Dati\`, `Ext` è `.fr3`, `FileNameNoExt` è `Rapporto` e `FullFileName` è `C:\Dati\Rapporto.fr3`

### Scenario: solo nome del file
- **Dato** `Add('Solo', 'solo.txt', ftNormal, nil)`
- **Quando** si leggono `Folder` e `FullFileName`
- **Allora** `Folder` è vuota e `FullFileName` è `solo.txt`

## ZLIBS-FIL-002 Aggiunta e ricerca per nome
Il nome è la chiave di un elemento. `Add(Nome, ...)` con un nome già presente (il confronto **non distingue maiuscole e minuscole**) non crea un secondo elemento: aggiorna quello esistente, ne sostituisce nome, file, cartella, tipo e procedura, e restituisce lo stesso oggetto; il nome diventa quello nuovo (`Report` e poi `REPORT` dà un elemento di nome `REPORT`). `FindFile(Nome)` restituisce l'elemento o `nil` (anche per un nome vuoto); `IndexOf(Nome)` la posizione o -1; `GetFullFileName(Nome)` il percorso completo o una stringa vuota se il nome non c'è. Una procedura passata ad `Add` resta nella scheda e si può chiamare (`Scheda.Proc(Scheda)`); `Assigned(Proc)` dice se c'è.

### Scenario: stesso nome
- **Dato** un elemento `Report` standard
- **Quando** si aggiunge `Report` con un percorso personalizzato
- **Allora** l'elenco ha un solo elemento, lo stesso oggetto, con il percorso e il tipo nuovi

### Scenario: nome assente
- **Dato** un elenco che non contiene `Z`
- **Quando** si chiamano `IndexOf('Z')`, `FindFile('Z')` e `GetFullFileName('Z')`
- **Allora** i risultati sono -1, `nil` e la stringa vuota

## ZLIBS-FIL-003 Cartelle (`GetFolder`)
`GetFolder(Cartella, Tipo)` restituisce il percorso **con la barra finale**: `AppRoot\Classe\Cartella\` per `ftNormal`, `AppRoot\Classe\<CustomFolder>\Cartella\` per `ftCustom`, `AppRoot\Classe\<SharedFolder>\` per `ftShared` (la cartella richiesta si ignora). Con una cartella vuota il risultato è quello della classe (`AppRoot\Classe\`). La barra tra la radice e la classe si aggiunge se manca. `GetFolder(Cartella, Custom)` con un booleano è la stessa cosa: falso per le standard, vero per le personalizzate. **Ogni chiamata crea le cartelle del percorso** se non esistono (DIV-FIL-3).

### Scenario: file standard
- **Dato** `AppRoot` = `D:\Dati` e una classe `Modelli`
- **Quando** si chiama `GetFolder('Sub', ftNormal)`
- **Allora** il risultato è `D:\Dati\Modelli\Sub\`

### Scenario: file personalizzati
- **Dato** gli stessi valori
- **Quando** si chiama `GetFolder('Sub', ftCustom)`
- **Allora** il risultato è `D:\Dati\Modelli\__Custom\Sub\`

### Scenario: file condivisi
- **Dato** gli stessi valori
- **Quando** si chiama `GetFolder('Sub', ftShared)`
- **Allora** il risultato è `D:\Dati\Modelli\__Shared\`

## ZLIBS-FIL-004 Elenco da una cartella (`AddFolder`)
`AddFolder(Cartella, Estensione, Condivisi, DoClear, Filtro)` elenca i file della cartella standard che corrispondono a `*` più l'estensione: l'estensione si può scrivere con l'asterisco (`'*.docx'`, come fanno i chiamanti) o senza (`'.docx'`). Per ogni file aggiunge un elemento di tipo standard con **nome uguale al nome del file senza estensione**. Con `DoClear` vero (predefinito) l'elenco viene prima svuotato; con falso gli elementi nuovi si accodano a quelli presenti, e un nome già presente viene aggiornato. Se la cartella non esiste viene creata (e l'elenco resta vuoto). `Filtro` (facoltativo) è una funzione che riceve il percorso del file e risponde falso per escluderlo, e vale per i file standard, per quelli personalizzati e per quelli condivisi (DIV-FIL-2, corretta nel rilascio 019).

### Scenario: due file su tre
- **Dato** una cartella con `a.docx`, `b.docx` e `c.txt`
- **Quando** si chiama `AddFolder('Sub', '.docx')`
- **Allora** gli elementi sono `a` e `b`, di tipo standard, con `FileName` `a.docx` e `b.docx`

### Scenario: filtro
- **Dato** una cartella con `a.docx` e `bozza.docx` e un filtro che esclude i nomi che cominciano per `bozza`
- **Quando** si chiama `AddFolder('Sub', '.docx', nil, True, Filtro)`
- **Allora** l'unico elemento è `a`

### Scenario: elementi precedenti
- **Dato** un elenco con l'elemento `Vecchio` e una cartella con `a.docx`
- **Quando** si chiama `AddFolder('Sub', '.docx')` e poi, su un elenco analogo, `AddFolder('Sub', '.docx', nil, False)`
- **Allora** nel primo caso resta solo `a`, nel secondo restano `Vecchio` e `a`

## ZLIBS-FIL-005 File personalizzati
Dopo i file standard `AddFolder` elenca quelli della cartella personalizzata (`__Custom\Cartella\`, stessa estensione). Un file personalizzato con lo stesso nome di uno standard **lo sostituisce** nell'elenco (resta un solo elemento, di tipo personalizzato, con la cartella delle personalizzazioni); uno con un nome nuovo si aggiunge come personalizzato. Se `CustomFolder` è vuota le personalizzazioni si ignorano del tutto.

### Scenario: sostituzione
- **Dato** `a.docx` sia nella cartella standard sia in quella personalizzata
- **Quando** si chiama `AddFolder('Sub', '.docx')`
- **Allora** c'è un solo elemento `a`, con `Custom` vero e la cartella personalizzata come `Folder`

### Scenario: personalizzazioni disattivate
- **Dato** gli stessi file e `CustomFolder` vuota
- **Quando** si chiama `AddFolder('Sub', '.docx')`
- **Allora** l'elemento `a` è quello standard

## ZLIBS-FIL-006 File condivisi
Il terzo parametro di `AddFolder` è un elenco di righe `Nome=file`: per ognuna cerca `__Shared\file<Estensione>` (l'estensione è quella dell'elenco, sostituita se il file ne ha già una) e, se il file esiste, aggiunge un elemento di tipo condiviso con quel nome. Una riga senza il segno uguale (o con il valore vuoto) usa lo stesso testo come nome e come file. I file che non esistono si ignorano. Un file condiviso con lo stesso nome di uno standard o personalizzato lo sostituisce. L'estensione si può scrivere con o senza asterisco: per i condivisi l'asterisco si ignora (DIV-FIL-1, corretta nel rilascio 019).

### Scenario: nome e file
- **Dato** il file `__Shared\guida.txt` e la riga `Manuale=guida`
- **Quando** si chiama `AddFolder('Sub', '.txt', Condivisi)`
- **Allora** c'è un elemento `Manuale`, di tipo condiviso, con `FileName` `guida.txt`

### Scenario: riga senza segno uguale
- **Dato** il file `__Shared\Altro.txt` e la riga `Altro`
- **Quando** si chiama `AddFolder('Sub', '.txt', Condivisi)`
- **Allora** c'è un elemento `Altro` con `FileName` `Altro.txt`

### Scenario: file assente
- **Dato** una riga `Assente=assente` e nessun file `__Shared\assente.txt`
- **Quando** si chiama `AddFolder`
- **Allora** non compare nessun elemento `Assente`

## ZLIBS-FIL-007 Elenco dei nomi (`GetFileNames`)
`GetFileNames(Elenco, RimuoviEstensione)` svuota prima l'elenco ricevuto (che non può essere `nil`), poi vi scrive un nome per elemento, in ordine. Con `RimuoviEstensione` falso (predefinito) scrive il **nome del file con l'estensione**; con vero scrive il **nome dell'elemento**, che coincide con il nome del file senza estensione solo per gli elementi nati da `AddFolder` (DIV-FIL-4).

### Scenario: nomi con estensione
- **Dato** gli elementi `Rapporto` (`file.pdf`) e `Altro` (`altro.docx`)
- **Quando** si chiama `GetFileNames(Elenco)`
- **Allora** l'elenco è `file.pdf`, `altro.docx`

### Scenario: elenco già pieno
- **Dato** un elenco di testi con due righe e un solo elemento in `TzFiles`
- **Quando** si chiama `GetFileNames(Elenco)`
- **Allora** l'elenco ha solo il nome nuovo

## ZLIBS-FIL-008 Copia, inserimento e giro
`Assign` di una scheda copia nome, tipo, nome del file, cartella e procedura da un'altra `TzFile`; da un oggetto di altro tipo solleva `EConvertError`. `Elenco[i] := Elemento` copia i valori nell'elemento in posizione `i` con `Assign` (non sostituisce l'oggetto). `Insert(i)` crea un elemento vuoto in posizione `i`. `for Scheda in Elenco` percorre gli elementi in ordine.

### Scenario: copia fra schede
- **Dato** una scheda `Origine` personalizzata con una procedura e una scheda vuota
- **Quando** si chiama `Assign(Origine)` sulla vuota
- **Allora** nome, tipo, file, cartella e procedura sono quelli di `Origine`

### Scenario: oggetto estraneo
- **Dato** una scheda e un `TPersistent` che non è una scheda
- **Quando** si chiama `Assign` con quell'oggetto
- **Allora** viene sollevata `EConvertError`

## ZLIBS-FIL-009 Valori predefiniti delle cartelle
All'avvio `TzFiles.CustomFolder` vale `__Custom` e `TzFiles.SharedFolder` vale `__Shared`; `AppRoot` è vuota, quindi i percorsi sono relativi alla cartella di lavoro del processo finché il programma non la imposta. Sono variabili di classe: cambiarle vale per tutti gli elenchi.

### Scenario: valori all'avvio
- **Dato** un programma che non ha toccato le variabili
- **Quando** si leggono `CustomFolder` e `SharedFolder`
- **Allora** sono `__Custom` e `__Shared`

## Divergenze note

Si decidono nella voce R-213 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita; DIV-FIL-3 ha una prova che la fotografa.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-FIL-1 ✅ (corretta) | Per i file condivisi l'estensione veniva applicata con `ChangeFileExt` anche con l'asterisco (`nome*.pdf`, file inesistente). Corretta nel rilascio 019: l'asterisco si toglie | Nessuna |
| DIV-FIL-2 ✅ (corretta) | Il filtro `IsValidFile` si applicava solo ai file standard. Corretta nel rilascio 019: vale anche per i personalizzati e i condivisi | Nessuna |
| DIV-FIL-3 🟢 | `GetFolder` crea sempre le cartelle del percorso, anche quando lo si chiama solo per leggere o elencare; `AddFolder` crea quindi la cartella standard e quella delle personalizzazioni anche vuote | Effetto collaterale su disco da una funzione che sembra di sola lettura: su un disco di rete o in sola lettura la creazione può fallire senza avvisare (il risultato di `ForceDirectories` non viene controllato) e la scansione lavora su una cartella inesistente |
| DIV-FIL-4 🟢 | `GetFileNames(Elenco, True)` si chiama «rimuovi l'estensione» ma scrive il nome dell'elemento, non il nome del file senza estensione | Per gli elementi di `AddFolder` il risultato coincide; per quelli aggiunti a mano con un nome diverso dal file (`Add('Rapporto', 'C:\x\file.pdf', ...)`) si ottiene `Rapporto`, non `file` |
| DIV-FIL-5 🟡 (dedotta) | In Gesty e in zTicser la riga che imposta `TzFiles.AppRoot` in `ConfigModule` è commentata e nessun'altra unit la imposta | `GetTemplate` (`Files.Lib`) cerca i modelli PDF in `PDFTemplates\...` relativi alla cartella di lavoro del processo, e `GetFolder` vi crea le cartelle: se il programma parte da una cartella diversa non trova i modelli o li cerca nel posto sbagliato. Va verificato se è voluto |
| DIV-FIL-6 🟢 (dedotta) | Esistono due classi `TzFile` diverse, una in `zz.files` e una in `zOffice\zFileSystem` | Una unit che le cita entrambe senza qualificare il nome usa quella dichiarata per ultima nella clausola `uses`; l'errore, quando capita, è un messaggio di compilazione sul tipo, non un comportamento sbagliato in esecuzione |
| DIV-FIL-7 🟢 | Per un elemento senza cartella (`Add('Solo', 'solo.txt', ...)`) `Folder` torna la sola barra (`\`) invece della stringa vuota (provato da `Scheda_SenzaCartella_PercorsoCompletoUgualeAlNomeFile`) | `FullFileName` di un elemento senza cartella comincia con una barra. |
| DIV-FIL-8 🟢 | `Add` con nome file vuoto solleva l'eccezione «Il nome file è vuoto», anche per le voci di tipo `ftProc` che non hanno un file (provato dai test su `ftProc`) | Una procedura associata deve comunque avere un nome file fittizio. |
