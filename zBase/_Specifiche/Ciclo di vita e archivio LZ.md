---
area: Ciclo di vita e archivio LZ
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Ciclo di vita e archivio LZ

Questa specifica descrive la vita del componente `TzSystem`, il cuore di zPack: l'oggetto unico che ogni programma crea all'avvio, i parametri della riga di comando, la sequenza dopo l'accesso (impostazioni di cliente e dizionario), il file `.LZ` accanto all'eseguibile con la sua lettura, il suo salvataggio, le sue copie di sicurezza e il salvataggio senza utente per i programmi senza interfaccia. Il codice è in `zBase\zSystem.pas` (`TzSystem.Create`, `Destroy`, `InitParams`, `Login`, `LoadZip`, `SaveZip`, `SaveZipUnattended`, `WriteZip`, `BackupZip`, `BackupZipIn`, `InitializeFromDB`, `UpdateFromDB`, `SaveChanges`). Il formato del file (zip con un membro per collezione) e la sua lettura e scrittura riga per riga stanno in `Collezione LZ.md` (ZBASE-COL-015); l'accesso dell'utente in `Accesso e password.md` (ZBASE-ACC-001); la rilettura dei metadati e il riallineamento del dizionario in `Metadati del database.md` e in `Creazione e allineamento del dizionario.md`. Lo usano WT e Gesty allo stesso modo: `ConfigModule.pas` di entrambi chiama `zSystem.Login(true, false, richiamata)` in `DataModuleCreate`; `MainForm.pas` di WT offre la rilettura del file (azione `LoadZip`, che poi mostra «Impostazioni aggiornate.») e il salvataggio manuale con copia (`BackupZip` più `SaveZip(csAll, 'main')`); i personalizzatori di form e wizard salvano solo la propria collezione (`SaveZip(csForms, ...)`, `SaveZip(csWizards, ...)`). `zMCP_LZ` (`zToolsAI\MCP\zMCP_LZ\_src\zLz.Dizionario.pas`) crea il proprio `TzSystem` senza interfaccia e usa `UpdateFromDB` e `SaveZipUnattended`. Descrive il comportamento atteso, non il codice.

**Come funziona.** Il costruttore di `TzSystem` crea le 21 collezioni del dizionario, i metadati, la sicurezza e registra se stesso nella variabile globale `Base`, da cui lo trovano il resto di zPack e le funzioni come `CreateStoredProc`. `Login` fa entrare l'utente (`zSecurity.Login`) e solo dopo carica le personalizzazioni di campo del cliente, esegue la richiamata dell'applicazione e legge il dizionario dal file `.LZ`. Il salvataggio è riservato all'amministratore, tranne la prima creazione del file; ogni salvataggio copia prima il file vecchio in una cartella `BackupLZ`.

**Test che coprono quest'area.** `Test.zSystem.Sistema` prova, senza database, il secondo `TzSystem` che solleva «TzSystem Singleton», il nome predefinito del file `.LZ`, il rifiuto di `Login` senza database, le due precondizioni di `SaveZipUnattended` che non richiedono un archivio e i casi in cui `SaveZip` non scrive niente. Non c'è nessuna prova della lettura e della scrittura vera dell'archivio, della copia di sicurezza né della riga di comando: servono un archivio `.LZ` e, per la riga di comando, il controllo dei parametri del processo.

## ZBASE-AVV-001 Oggetto unico
In esecuzione può esistere un solo `TzSystem`. Il costruttore memorizza se stesso in `Base`; se `Base` è già assegnato e il componente non è in fase di progettazione (`csDesigning`), solleva `Exception` con il testo «TzSystem Singleton». Il distruttore libera tutte le collezioni e azzera `Base`. In fase di progettazione (IDE) più istanze convivono. Oggi nessun programma ne crea un secondo: `ImportaLZ` di WT e di Gesty ne crea uno per leggere un vecchio `.LZ` ma comincia con `Exit`, quindi è disattivata (DIV-AVV-1).

### Scenario: secondo componente
- **Dato** un programma con un `TzSystem` già creato
- **Quando** si crea un altro `TzSystem`
- **Allora** solleva «TzSystem Singleton»

## ZBASE-AVV-002 Parametri della riga di comando
Alla creazione `InitParams` trasforma ogni argomento del processo (`ParamStr(1)` e seguenti) in una riga di `Params`: toglie le virgolette esterne (`AnsiDequotedStr`), toglie gli spazi ai bordi e **cancella da tutta la riga** i caratteri `-`, `/` e `\`. Un argomento si scrive quindi `Nome=Valore`, con o senza `-` o `/` davanti: `-User=MARIO` e `/User=MARIO` danno entrambi `Params.Values['User'] = 'MARIO'`. I parametri che il programma legge oggi sono tre, `User`, `Db` e `Password`, usati dall'accesso da riga di comando (`Accesso e password.md`, ZBASE-ACC-004). Siccome la cancellazione riguarda anche il valore, un valore che contiene uno dei tre caratteri arriva alterato (DIV-AVV-2).

### Scenario: argomenti con prefisso
- **Dato** il programma avviato con `-User=MARIO /Db=Produzione`
- **Quando** il componente viene creato
- **Allora** `Params.Values['User']` è `MARIO` e `Params.Values['Db']` è `Produzione`

### Scenario: valore con trattino
- **Dato** il programma avviato con `Password=ab-12`
- **Quando** il componente viene creato
- **Allora** `Params.Values['Password']` è `ab12`

## ZBASE-AVV-003 Sequenza dopo l'accesso (`TzSystem.Login`)
`Login(AllowParams, ShowWaitForm, Richiamata)` esegue:
1. se `zFbDatabase` non è assegnato, solleva «Database non assegnato» prima di fare altro;
2. `zSecurity.Login(AllowParams)` (`Accesso e password.md`);
3. se l'utente non è entrato, `TerminateApplication` e basta;
4. altrimenti svuota la memoria delle cartelle (`Impostazioni e cartelle.md`, ZBASE-CFG-004), carica le personalizzazioni di campo (`Overrides.LoadFromDB`, `Personalizzazioni dei campi.md`, ZBASE-OVR-001), esegue la richiamata dell'applicazione, se c'è, e legge il dizionario con `LoadZip(ShowWaitForm)`.

La richiamata passa prima della lettura del dizionario: WT e Gesty ci rimettono la schermata di avvio, che copre la parte lenta (la lettura del `.LZ`). `ShowWaitForm` decide solo se `LoadZip` mostra la finestra di attesa «System...»: WT e Gesty passano falso perché usano già la schermata di avvio.

### Scenario: database non assegnato
- **Dato** un `TzSystem` senza `zFbDatabase`
- **Quando** si chiama `Login`
- **Allora** solleva «Database non assegnato» e nessuna finestra di accesso si apre

### Scenario: accesso riuscito
- **Dato** un accesso riuscito
- **Quando** `Login` prosegue
- **Allora** le personalizzazioni sono già caricate quando la richiamata viene eseguita, e il dizionario lo è quando `Login` termina

## ZBASE-AVV-004 Nome e posizione del file `.LZ`
`FileName` è il percorso del dizionario. In esecuzione, se non è stato assegnato (o contiene solo spazi), vale il nome dell'eseguibile con l'estensione `.LZ` nella stessa cartella (`ChangeFileExt(Application.ExeName, '.LZ')`): per `WinTarif3.exe` è `WinTarif3.LZ` accanto all'eseguibile. Un valore assegnato vale così com'è; in fase di progettazione si restituisce il valore assegnato senza ripiego. Il file di backup e i membri dell'archivio sono descritti in ZBASE-AVV-007 e in `Collezione LZ.md`.

### Scenario: nome predefinito
- **Dato** un `TzSystem` senza `FileName`
- **Quando** si legge `FileName`
- **Allora** è il nome dell'eseguibile con estensione `.LZ`

### Scenario: nome esplicito
- **Dato** `FileName` assegnato a `D:\Dizionari\prova.lz`
- **Quando** lo si legge
- **Allora** è `D:\Dizionari\prova.lz`

## ZBASE-AVV-005 Lettura del dizionario (`LoadZip`)
`LoadZip` scrive nel registro quale file legge e la sua data (così presso i clienti, dove l'eseguibile e l'`.LZ` stanno spesso su cartelle di rete, si capisce se la postazione ha letto l'archivio atteso). Se il file esiste:
- se un'altra lettura o scrittura è in corso (`ZipBusy`) esce senza fare niente;
- segna il dizionario come caricato (`zLoaded`) e legge il membro `MetaData`;
- svuota le 21 collezioni e le rilegge dall'archivio nell'ordine: dizionario dei dati, moduli dati, ricerche (`zLookups`), procedure memorizzate, dataset, generatori, viste, schede, pivot, viste record, alberi, grafici, calendari, visualizzatori di file, liste di valori, form, procedure guidate, cubi, mappe, mappe Tatuk, suggerimenti;
- chiama `UpdateStructure`, che oggi comincia con `Exit` e non fa niente (DIV-AVV-4).

Se il file non esiste, chiede conferma con il testo «Il file <nome> non esiste.» e «Inizializzo dal DataBase?»: con Sì esegue `InitializeFromDB` (rilegge i metadati, riallinea il dizionario, segna il dizionario come caricato e salva tutto in un file nuovo), con No esce e il dizionario resta non caricato. WT la richiama dall'azione `LoadZip` del menu principale per rileggere il file senza riavviare.

### Scenario: file presente
- **Dato** un `.LZ` valido accanto all'eseguibile
- **Quando** si chiama `LoadZip`
- **Allora** le collezioni contengono gli elementi dell'archivio e `zLoaded` è vero

### Scenario: file assente
- **Dato** nessun `.LZ` accanto all'eseguibile
- **Quando** si chiama `LoadZip` e l'utente risponde No
- **Allora** nessuna collezione viene toccata e il dizionario resta non caricato

## ZBASE-AVV-006 Salvataggio del dizionario (`SaveZip`)
`SaveZip(Selettore, Messaggio)` porta in memoria il segno «modificato» a falso come primo passo e poi controlla, nell'ordine, se deve scrivere. Non scrive se:
1. nessun utente è collegato (in GDA un accesso senza utente spazzava il file);
2. il dizionario non è stato caricato (`zLoaded` falso);
3. l'utente non è amministratore **e** il file esiste già. Un non amministratore può scrivere solo se il file non esiste (creazione da database).

Altrimenti scrive con `WriteZip`, dopo una copia di sicurezza (ZBASE-AVV-007) nella cartella `BackupLZ` accanto all'eseguibile. Il selettore sceglie quali collezioni scrivere: `csAll` tutte; i selettori singoli, ciascuno con la collezione che dice il nome (`csForms`, `csWizards`, `csLookups`, `csStoredProcs`, `csGenerators`, `csTips`, `csMetadata`, `csDbViews`, ...); `csFieldProps` dizionario dei dati, ricerche, dataset e liste di valori; `csDataDictionary` dizionario dei dati, ricerche e liste di valori; `csDataModules` moduli dati, dataset e tutti i componenti di visualizzazione (viste, schede, pivot, viste record, alberi, grafici, calendari, file, cubi, mappe). Il valore `csPolicies` esiste ma nessuna collezione lo usa. Ogni salvataggio aggiunge in coda al membro `Log.txt` dell'archivio una riga con data, utente, messaggio e il numero delle schede. Se un salvataggio è già in corso (`ZipBusy`) `WriteZip` esce senza scrivere, e senza dirlo (DIV-AVV-5).

Il segno «modificato» è azzerato anche se non si scrive: le modifiche di un non amministratore non vengono ritentate. `SaveChanges` salva tutto solo se il segno è acceso; in WT la chiamata automatica alla chiusura di un modulo dati è spenta (`if False` in `Base_DbDataModule.pas`).

### Scenario: nessun utente collegato
- **Dato** un dizionario caricato e il segno «modificato» acceso, ma nessun accesso
- **Quando** si chiama `SaveZip(csAll, 'prova')`
- **Allora** il file non viene scritto e il segno «modificato» è falso

### Scenario: non amministratore
- **Dato** un utente collegato non amministratore e un `.LZ` esistente
- **Quando** si chiama `SaveZip(csAll, 'prova')`
- **Allora** il contenuto del file non cambia e non nasce nessuna copia di sicurezza

### Scenario: amministratore, collezione singola
- **Dato** un amministratore collegato
- **Quando** salva con `SaveZip(csForms, 'Personalizzazione Form')`
- **Allora** nell'archivio si riscrive solo il membro delle form, e `Log.txt` riceve una riga con `Personalizzazione Form`

## ZBASE-AVV-007 Copia di sicurezza (`BackupZipIn`, `BackupZip`)
Prima di ogni scrittura (`WriteZip`) `BackupZipIn(Cartella)` crea la cartella se manca e copia il file `.LZ` esistente con il nome `<nome senza estensione> - <data e ora><estensione>`, dove data e ora sono `aaaammgg`, due spazi e il testo `giorno-della-settimana, gg mese aaaa hh mm ss` nella lingua del sistema (per esempio `WinTarif3 - 20261101  domenica, 01 novembre 2026 10 15 30.LZ`). Copia solo se il file esiste e se un file con quel nome non c'è già. `BackupZip` (pubblica, usata dal menu di salvataggio di WT) fa lo stesso nella cartella `BackupLZ` accanto all'eseguibile. Il registro riceve il nome della copia. Nessuna copia vecchia viene mai tolta (DIV-AVV-6).

### Scenario: prima copia
- **Dato** un `.LZ` esistente e nessuna copia
- **Quando** si salva
- **Allora** la cartella `BackupLZ` contiene una copia con il nome nel formato indicato

## ZBASE-AVV-008 Salvataggio senza utente (`SaveZipUnattended`)
Per i programmi senza interfaccia (`zMCP_LZ` chiamato da `zBuilder`), dove la decisione di salvare l'ha già presa chi chiama. `SaveZipUnattended(Selettore, Messaggio, Utente)` non controlla né l'accesso né l'amministratore. Solleva un'eccezione se il dizionario non è stato caricato («SaveZipUnattended: dizionario non caricato, l'archivio non si salva»), se un altro salvataggio è in corso («SaveZipUnattended: un altro salvataggio dell'archivio e' in corso») o se il nome dell'archivio è vuoto («SaveZipUnattended: nome dell'archivio non impostato», DIV-AVV-3). Altrimenti scrive con `WriteZip` e mette la copia di sicurezza nella cartella `BackupLZ` accanto all'**archivio** (non all'eseguibile), con `Utente` nel `Log.txt`. Anche questo azzera il segno «modificato». Insieme a `UpdateFromDB` (che rilegge i metadati dal database indicato e riallinea il dizionario senza finestre e senza salvare, e segna il dizionario come caricato) permette di aggiornare un `.LZ` da un programma di servizio.

### Scenario: dizionario non caricato
- **Dato** un `TzSystem` creato e mai caricato
- **Quando** si chiama `SaveZipUnattended(csAll, 'prova', 'zBuilder')`
- **Allora** solleva «SaveZipUnattended: dizionario non caricato, l'archivio non si salva»

### Scenario: database o transazione mancanti
- **Dato** un `TzSystem` senza database
- **Quando** si chiama `UpdateFromDB(nil, Transazione, nil)`
- **Allora** solleva «UpdateFromDB: database non assegnato»
- **E** con database assegnato e transazione `nil` solleva «UpdateFromDB: transazione non assegnata»

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-212 di `Attivita Rinviate.md` indicata dalla sessione principale. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-AVV-1 🟡 (dedotta) | Se il secondo `TzSystem.Create` solleva «TzSystem Singleton», Delphi chiama il distruttore dell'oggetto a metà costruzione, e `TzSystem.Destroy` termina con `Base := nil`: azzera il puntatore all'oggetto che era valido | Dopo un tentativo di creare un secondo componente, `Base` è `nil` per il resto della sessione: `CreateStoredProc` (`Base.zFbDatabase`) e tutte le letture di impostazioni e cartelle vanno in violazione di accesso. Oggi nessuno lo innesca (`ImportaLZ` comincia con `Exit` in WT e in Gesty), ma basterebbe riattivarla |
| DIV-AVV-2 🟡 (dedotta) | `InitParams` cancella `-`, `/` e `\` da tutta la riga, non solo dal prefisso del nome | Un utente di dominio (`DOMINIO\mario`), una password con un trattino o una barra, un nome di connessione con un trattino (`Produzione-2026`) arrivano alterati all'accesso da riga di comando, che poi fallisce o entra come altro utente senza dire perché; il motivo si legge solo nel registro (`Accesso e password.md`, ZBASE-ACC-004) |
| DIV-AVV-3 🟢 (dedotta) | Il controllo `if FileName = ''` di `SaveZipUnattended` non può mai essere vero fuori dalla progettazione: `GetFileName` restituisce sempre il nome dell'eseguibile con `.LZ` se `FFileName` è vuoto | Il messaggio «nome dell'archivio non impostato» è codice morto che dà l'idea di una protezione che non c'è; un programma di servizio che dimentica `FileName` scrive sull'`.LZ` dell'eseguibile che lo ospita, senza avviso |
| DIV-AVV-4 🟢 (dedotta) | `UpdateStructure`, chiamata da `LoadZip`, comincia con `Exit`; sotto restano un ciclo che chiama `ConfirmOk(dm.Name)` e un `SaveZip(csAll, '')` | Codice morto che, se qualcuno togliesse `Exit`, mostrerebbe una finestra per ogni modulo dati senza form e salverebbe tutto a ogni caricamento |
| DIV-AVV-5 🟡 (dedotta) | Con un altro salvataggio in corso (`ZipBusy`) `WriteZip` esce senza scrivere né segnalare, e `SaveZip` ha già azzerato il segno «modificato» | Un salvataggio richiesto nello stesso momento di un altro (per esempio dal menu mentre un wizard salva) viene perso senza avviso e senza nuovo tentativo |
| DIV-AVV-6 🟢 (dedotta) | `BackupZipIn` ha il commento «una per minuto», ma il nome della copia contiene i secondi (`hh mm ss`), quindi la protezione contro i doppioni è al secondo; e nel codice di zPack non c'è nessuna pulizia delle copie in `BackupLZ`. Inoltre `NomeFileFromDate(Data)` usa `Data` per `aaaammgg` ma `Now` per il resto del nome | La cartella `BackupLZ` cresce a ogni salvataggio, con un `.LZ` intero ciascuno, finché qualcuno non la svuota a mano; il commento promette meno copie di quante ne escano |
| DIV-AVV-7 🟡 (dedotta) | `LoadZip` segna `zLoaded` vero **prima** di leggere e svuota le collezioni dopo aver letto `MetaData`; se la lettura di una collezione solleva un errore, le collezioni restano svuotate o a metà e `zLoaded` resta vero | Un `.LZ` danneggiato o letto a metà per un problema di rete lascia un dizionario parziale che il programma considera caricato; il successivo salvataggio da amministratore (Ctrl+F12, `SaveZip`) lo scriverebbe sul file, e la copia in `BackupLZ` è l'unica difesa |
