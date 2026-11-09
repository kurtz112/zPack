---
area: Impostazioni e cartelle
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Impostazioni e cartelle

Questa specifica descrive dove un programma costruito su zPack tiene le proprie impostazioni e le proprie cartelle di lavoro: i tre livelli di impostazione di `TzSystem` (per utente, per installazione, per computer) e le cartelle che ne derivano (radice delle configurazioni degli utenti, radice dei dati personali, radice dei file dell'applicazione, cartella e file di configurazione dell'utente collegato). Il codice sta in `zBase\zSystem.pas` (`TzSystem.Setting`, `Config`, `Folder` e le proprietà `Settings`, `Configs`, `Folders`, più `RootFolder`, `Root_Config`, `Root_PersonalData`, `Root_Files`, `ConfigFolder`, `PersonalFolder`, `ConfigFileName`). Il valore vero sta nel database, nelle procedure `USR_UTENTI_SETTINGS_*`, `USR_CONFIG_SETTINGS_*` e `USR_FOLDERS_*`: il client chiama la procedura e prende quello che risponde, senza regole proprie sul valore. Lo usano WT e Gesty allo stesso modo, sempre attraverso `Config.zSystem`: le cartelle documentali di WT (`WT.Lib.pas`: `CARTELLA_FLUSSI_RENDICONTAZIONE`, `CARTELLA_IMMAGINI_BOLLETTINI`, `CARTELLA_EXPORT_DOC_ASCII`, `CARTELLA_INTERROGAZIONI`, `CARTELLA_FLUSSI_REND_DA_PROCESS`) e le altre cartelle del `GetCartella` di `ConfigModule.pas` (WT e Gesty), la cartella dei flussi di Gesty (`dmCommon.pas`), le abilitazioni di WT (`DOCUMENTI_STAMPA_MULTIPLA` in `frmDocumenti.pas` e `GeDo.Reports.pas`, `CNC290_RENDICONTAZIONE` in `frmRendicontazioneCNC290.pas`), le preferenze di Gesty e WT (`Language` in `MainForm.pas` di WT, agenda e prenotazioni aule in Gesty), `Root_Files` e `PersonalFolder` in `ConfigModule.pas` di entrambi, `ConfigFolder` per le finestre di apertura e salvataggio. Lo skin dell'interfaccia usa gli stessi `Settings` (chiavi `Skin` e `SkinPalette`) e li ricopia nel file `.login` (`Accesso e password.md`, ZBASE-ACC-006). Descrive il comportamento atteso, non il codice.

**Come funziona.** Ogni lettura o scrittura è una chiamata a una procedura del database con il nome dell'impostazione. Le impostazioni dell'utente e quelle dell'installazione si leggono con un valore predefinito che la procedura restituisce se la voce manca; le cartelle si leggono con una cartella predefinita e, dopo la prima lettura, restano in memoria per tutta la sessione. Le cartelle derivate (`Root_*`, `ConfigFolder`, `PersonalFolder`) esistono solo a utente collegato: senza accesso restituiscono la stringa vuota. Dove la cartella manca, la si crea.

**Test che coprono quest'area.** `Test.zSystem.Sistema` prova, senza database, le cartelle derivate a utente non collegato (stringa vuota) e a utente collegato (radice scelta da `Folder`, cartella dell'utente creata), il nome del file di configurazione e `Folder` quando la procedura non risponde. Non c'è nessuna prova delle chiamate alle procedure del database: servono Firebird e le procedure `USR_*`.

## ZBASE-CFG-001 Tre livelli di impostazione
`TzSystem` conosce tre insiemi di impostazioni, ciascuno con la sua procedura del database:
- **Impostazioni dell'utente** (`Setting`, `Settings[...]`, `SettingExists`): per l'utente collegato; passano da `USR_UTENTI_SETTINGS_GET_VALUE`, `USR_UTENTI_SETTINGS_SET_VALUE` e `USR_UTENTI_SETTINGS_EXISTS` con `USER_ID` vuoto, che per la procedura vuol dire «utente corrente».
- **Impostazioni dell'installazione** (`Config`, `Configs[...]`, `ConfigExists`): uguali per tutti gli utenti del database; passano da `USR_CONFIG_SETTINGS_GET_VALUE`, `USR_CONFIG_SETTINGS_SET_VALUE` e `USR_CONFIG_SETTINGS_EXISTS`.
- **Cartelle** (`Folder`, `Folders[...]`): una cartella per nome, eventualmente diversa da computer a computer; passano da `USR_FOLDERS_GET_VALUE` (con il nome del computer) e `USR_FOLDERS_SET_VALUE`.

Il nome dell'impostazione è una stringa libera, scelta da chi chiama; il client non la controlla. `Setting(Nome, Predefinito)` e `Config(Nome, Predefinito)` passano il predefinito alla procedura (`DEFAULT_VALUE`) e restituiscono il suo `VALORE`: se la voce manca, il predefinito lo applica la procedura, non il client.

### Scenario: stessa chiave, livelli diversi
- **Dato** la chiave `DOCUMENTI_STAMPA_MULTIPLA` scritta come impostazione dell'installazione
- **Quando** un utente la legge con `Config('DOCUMENTI_STAMPA_MULTIPLA', '')`
- **Allora** ottiene il valore dell'installazione, uguale per tutti
- **E** `Setting('DOCUMENTI_STAMPA_MULTIPLA', '')` non lo vede: sono tabelle diverse

## ZBASE-CFG-002 Proprietà indicizzate e registro
`Settings[Nome]`, `Configs[Nome]` e `Folders[Nome]` leggono con predefinito vuoto e scrivono nel registro SmartInspect il nome e il valore letti. In scrittura:
- `Settings[Nome] := Valore` scrive solo se il valore cambia davvero: prima legge `Setting(Nome, '')` e, se è già uguale, esce (Mantis #142, per non riscrivere a ogni avvio la riga globale e provocare un conflitto di aggiornamento fra utenti che entrano insieme). Conseguenza: scrivere un valore vuoto su una voce che non esiste non crea niente;
- `Configs[Nome] := Valore` chiama sempre la procedura;
- `Folders[Nome] := Valore` chiama sempre la procedura e passa un nome di computer vuoto: salva quindi la cartella **generale** dell'impostazione, non quella del computer (DIV-CFG-3).

### Scenario: stesso valore
- **Dato** l'impostazione `Language` già salvata come `it`
- **Quando** il programma assegna di nuovo `Settings['Language'] := 'it'`
- **Allora** nessuna scrittura parte verso il database

### Scenario: valore nuovo
- **Dato** l'impostazione `PrenotazioniAule.AutoRefresh` salvata come `False`
- **Quando** il programma assegna `Settings['PrenotazioniAule.AutoRefresh'] := 'True'`
- **Allora** `USR_UTENTI_SETTINGS_SET_VALUE` riceve `USER_ID` vuoto, `SETTING` e `VALORE = True`

## ZBASE-CFG-003 Esistenza di una voce e eccezione per l'amministratore
`SettingExists(Nome, TrueIfAdmin)` e `ConfigExists(Nome, TrueIdAdmin)` rispondono se la voce esiste (`SETTING_EXISTS` della procedura). Con il secondo parametro vero, **predefinito**, rispondono vero anche quando la voce manca, se l'utente è amministratore (`IsAdmin`, vale a dire amministratore e non disattivato con `IsAdminDisabled`). Chi vuole la risposta pura passa `False`. WT usa `ConfigExists('DOCUMENTI_STAMPA_MULTIPLA')` come interruttore («la stampa multipla è abilitata per questo cliente») e poi legge con `Config` il numero massimo di documenti: per l'amministratore l'interruttore risulta acceso anche se il cliente non l'ha attivato, e il numero massimo resta quello che `Config` restituisce per una voce mancante (il predefinito vuoto non è un numero, quindi nessun limite).

### Scenario: voce mancante, utente comune
- **Dato** una voce `DOCUMENTI_STAMPA_MULTIPLA` che non esiste
- **Quando** un utente non amministratore chiama `ConfigExists('DOCUMENTI_STAMPA_MULTIPLA')`
- **Allora** il risultato è falso

### Scenario: voce mancante, amministratore
- **Dato** la stessa voce mancante
- **Quando** un amministratore chiama `ConfigExists('DOCUMENTI_STAMPA_MULTIPLA')`
- **Allora** il risultato è vero
- **E** `ConfigExists('DOCUMENTI_STAMPA_MULTIPLA', False)` è falso

## ZBASE-CFG-004 Cartella di lavoro per nome (`Folder`)
`Folder(Nome, Predefinita)` restituisce la cartella configurata per quel nome:
1. se il nome è già in memoria (`FolderCache`), restituisce quel valore senza interrogare il database;
2. altrimenti chiama `USR_FOLDERS_GET_VALUE` con `SETTING = Nome`, il nome del computer in maiuscolo e `DEFAULT_FOLDER = Predefinita`, e prende `FOLDER`;
3. se la chiamata solleva un errore di qualunque tipo (database non collegato, procedura mancante), l'errore è inghiottito e il risultato è la cartella predefinita;
4. il risultato, anche se vuoto o frutto di un errore, viene messo in memoria sotto il nome;
5. se il risultato è vuoto, restituisce la cartella predefinita.

Non crea la cartella e non controlla che esista: lo fanno `RootFolder` e i chiamanti. La memoria si svuota solo a ogni `TzSystem.Login`; non si svuota quando `Folders[Nome]` scrive (DIV-CFG-1) e la chiave è il solo nome, senza la cartella predefinita (DIV-CFG-2).

### Scenario: database che non risponde
- **Dato** un programma senza connessione al database
- **Quando** si chiama `Folder('CARTELLA_PROVA', 'C:\Dati\Prova')`
- **Allora** il risultato è `C:\Dati\Prova`, senza eccezioni

### Scenario: cartella già in memoria
- **Dato** una cartella letta una volta con `Folder('CARTELLA_FLUSSI_RENDICONTAZIONE', 'C:\App\Flussi')`
- **Quando** la si rilegge nella stessa sessione
- **Allora** il database non viene interrogato di nuovo

## ZBASE-CFG-005 Radici delle cartelle (`RootFolder`)
`RootFolder(Nome, Sottocartella)` calcola una radice così: se non c'è un utente collegato restituisce la stringa vuota; altrimenti prende `Folder(Nome, <cartella dell'eseguibile> + Sottocartella)`, se il risultato non è vuoto aggiunge il separatore finale e crea la cartella con `ForceDirectories`, ignorando se la creazione riesce. Le tre radici note sono:

| Funzione | Nome in `USR_FOLDERS` | Predefinita (sotto la cartella dell'eseguibile) |
|---|---|---|
| `Root_Config` | `ROOT_CONFIG` | `CartellaConfigurazioneUtenti` |
| `Root_PersonalData` | `ROOT_PERSONAL_DATA` | `CartellaDatiPersonaliUtenti` |
| `Root_Files` | `ROOT_APP_FILES` | la cartella dell'eseguibile stessa |

`Root_Files` è la radice dei file dell'applicazione: dopo l'accesso WT la assegna a `TzFiles.AppRoot` e a `zReportConfig.ReportRoot`, Gesty solo a `zReportConfig.ReportRoot` (in `ConfigModule.pas` l'assegnazione ad `AppRoot` è commentata).

### Scenario: utente non collegato
- **Dato** un programma in cui nessuno ha ancora fatto l'accesso
- **Quando** si chiama `Root_Config`, `Root_PersonalData` o `Root_Files`
- **Allora** il risultato è la stringa vuota e nessuna cartella viene creata

### Scenario: cartella configurata
- **Dato** un utente collegato e `ROOT_CONFIG = D:\Config`
- **Quando** si chiama `Root_Config`
- **Allora** il risultato è `D:\Config\` e la cartella esiste

## ZBASE-CFG-006 Cartella e file di configurazione dell'utente
Con un utente collegato:
- `ConfigFolder` è `Root_Config` seguita dalla cartella dell'utente (`LoginParams.UserFolder`) e dal separatore finale, creata se manca; è la cartella dei file di impostazioni personali (`.Settings`, `.Forms`, `.Columns` in WT e Gesty) e quella proposta dalle finestre di apertura e salvataggio;
- `PersonalFolder` è `Root_PersonalData` seguita dalla cartella dell'utente e dal separatore, creata se manca; a differenza di `ConfigFolder` un errore nella creazione si mostra con il gestore delle eccezioni dell'applicazione e non interrompe;
- `ConfigFileName(Estensione)` è `ConfigFolder` più il nome dell'eseguibile con l'estensione data (`ChangeFileExt(ExtractFileName(Application.ExeName), Estensione)`): con l'eseguibile `WinTarif3.exe` e l'estensione `.Settings` è `<ConfigFolder>WinTarif3.Settings`.

La cartella dell'utente (`UserFolder`) è il nome utente digitato all'accesso, tale e quale (DIV-CFG-4). Senza utente collegato tutte e tre le funzioni restituiscono la stringa vuota.

### Scenario: file di impostazioni di un utente
- **Dato** l'utente `MARIO` collegato e `ROOT_CONFIG = D:\Config`
- **Quando** si chiama `ConfigFileName('.Settings')`
- **Allora** il risultato è `D:\Config\MARIO\WinTarif3.Settings` se l'eseguibile è `WinTarif3.exe`
- **E** la cartella `D:\Config\MARIO\` esiste

### Scenario: nessun utente collegato
- **Dato** un programma senza accesso
- **Quando** si chiama `ConfigFileName('.Settings')`
- **Allora** il risultato è la stringa vuota

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-212 di `Attivita Rinviate.md` indicata dalla sessione principale. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-CFG-1 🟡 (dedotta) | `SetFolders` (`Folders[Nome] := ...`) non toglie `Nome` dalla memoria di `Folder`: la memoria si svuota solo in `TzSystem.Login` | In WT l'esportazione dei documenti in ASCII (`dmEsportazioneDocumentiASCII.pas`) fa scegliere la cartella e la salva con `SetCartellaExportDocumentiASCII`; la volta dopo, nella stessa sessione, `GetCartellaExportDocumentiASCII` rilegge dalla memoria e propone ancora la cartella vecchia. La scelta vale solo dal riavvio |
| DIV-CFG-2 🟡 (dedotta) | `Folder` mette in memoria anche il risultato di un errore, e la chiave è il solo nome: una procedura che non risponde in quel momento (rete caduta, transazione sfortunata) fissa la cartella predefinita per tutta la sessione; e due chiamate con lo stesso nome e predefinite diverse restituiscono sempre il predefinito della prima | Una cartella configurata viene ignorata fino al riavvio dopo un singolo errore passeggero; chi chiama lo stesso nome da punti diversi con predefiniti diversi vede quello di chi è arrivato prima |
| DIV-CFG-3 🟡 (dedotta, da verificare sulla procedura) | `SetFolders` passa `COMPUTER_NAME` vuoto con il commento «user corrente», ma il parametro è il computer, non l'utente; `GetFolders` e `Folder` passano il nome del computer. Lo script `01 - USR_FOLDERS_SET_VALUE Gesty.sql` del rilascio `OUT/20261006-rilasci-attivita-rinviate-priorita-media/002` spiega che la procedura tiene una riga per impostazione e computer, e che il nome vuoto è la riga generale | La scelta di un utente su un PC vale per tutti i computer che non hanno una riga propria; se invece il computer ne ha una, la lettura può continuare a restituire quella e la nuova scelta passa inosservata. Il commento nel codice dice una cosa diversa da ciò che avviene |
| DIV-CFG-4 🟢 (dedotta) | La cartella personale e quella di configurazione prendono il nome utente così come è stato digitato all'accesso (`SetParams` assegna `FUserFolder := aUserName`), senza ripulirlo; `RootFolder` e `ConfigFolder` ignorano l'esito di `ForceDirectories` | Con un nome utente con grafia diversa su un disco che distingue le maiuscole si ottengono cartelle diverse per lo stesso utente; con caratteri non ammessi in un percorso la cartella non nasce e la funzione restituisce comunque il percorso, che poi fallisce al primo uso |
