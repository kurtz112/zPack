---
area: Funzioni di base
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Funzioni di base

Questa specifica descrive le funzioni libere e i tipi di `zBase\zBaseLib.pas`, la unit più usata di zPack: trasformazioni di testi (maiuscole iniziali, confronti, scomposizione), nomi di percorsi e di file, nomi di componenti, valori e date nulli, anno corrente, formattazione di importi e durate, colore del testo leggibile, memoria della posizione delle finestre, tipo di controllo `TzCtrlType` con il suo helper, conversione enumerato-testo, finestra di attesa e le due richieste di password di protezione. La unit è elencata nei `.dpr` di WT (`WinTarif3.dpr`) e di Gesty (`Gesty.dpr`) ed è usata, per numero di file con la riga nell'`uses`, da 296 file di WT, 85 di Gesty e 74 di zPack (copie di lavoro comprese; le altre cartelle di `SRC`, come `Sharefood` e `__tmp`, hanno copie vecchie e non contano). Le funzioni più chiamate nei sorgenti di WT, Gesty e zPack (conteggio per righe, escluse le copie di lavoro) sono `StartWait` (circa 840), `ActionVisible` (circa 250), `FileNameNoExt` (circa 60), `StartingWith` (circa 56), `CapFirst` e `zzCapFirst` (circa 65 insieme), `CalcPath` (circa 40), `EndsWith` (circa 40), `ComputerName`, `StrToChar` e `CtrlKey` (circa 30 ciascuna), `ValidateComponentName` e `CurrencyToStr` (circa 20 ciascuna), `GetContrastColor` e `MaxDate` (circa 13 ciascuna). Il tipo `TzCtrlType` compare in oltre 150 righe. Le due finestre di input che `PasswordOk` e `PasswordXX` aprono stanno in `zMsg.pas` (`Finestre di dialogo.md`, ZBASE-MSG-005). Descrive il comportamento atteso, non il codice. `Delay` non ha chiamanti (DIV-LIB-22).

**Come funziona.** Sono funzioni piccole e indipendenti: quasi tutte lavorano solo sui parametri e non toccano lo stato del programma. Fanno eccezione quelle che leggono l'ambiente (`Path`, `ComputerName`, `GetFileVersion`, `CtrlKey`, `ShiftKey`, `Desktop`, `Debug`), quelle che toccano il disco (`GetTempFileName`, `ComponentToDFM`, `SaveFormPosition`, `LoadFormPosition`) e quelle che aprono finestre (`PasswordOk`, `PasswordXX`, `StartWait`, `StopWait`, `UpdateWait`). Il tipo di controllo `TzCtrlType` è un enumerato i cui **nomi** si salvano come testo nel dizionario LZ (`AsString`): rinominare un valore dell'enumerato rompe i dizionari esistenti. Le funzioni `StartingWith`, `EndsWith`, `Contains`, `Coalesce`, `IsNull` e `IsNumeric` hanno nomi molto comuni: in una unit che includa altre unit con lo stesso nome vince quella scritta per ultima nell'`uses`.

**Test che coprono quest'area.** Nessuna prova in `D:\AI\SRC\zPack\_UnitTest\_src`. Il test `Test.zBaseLib` (102 prove, 10 delle quali caratterizzano le divergenze) copre i requisiti 001-014, 016, 018-021; restano senza prova, perché aprono finestre o dipendono dalla macchina, `PasswordOk`, `PasswordXX`, `StartWait`, `StopWait`, `UpdateWait`, `CtrlKey`, `ShiftKey`, `Onnipotente`, `Desktop`.

## ZBASE-LIB-001 Maiuscole iniziali
`CapFirst(Valore)` scrive la prima lettera maiuscola e tutte le altre minuscole, tranne la lettera che segue un carattere con codice minore di 33 (spazio, tabulazione, a capo), che torna maiuscola. Il trattino e l'apostrofo non separano le parole. Un testo vuoto o fatto di soli spazi restituisce il testo vuoto.
`zzCapFirst(Valore, SostituisciUnderscore)` fa lo stesso ma considera separatori solo lo spazio e il carattere `_`; con `SostituisciUnderscore` vero i `_` diventano spazi, con falso restano.
`FormatDisplayLabel(NomeCampo)` sostituisce i `_` con spazi e poi applica `CapFirst`: serve a trasformare il nome di un campo in un'etichetta.

### Scenario: nome di persona
- **Dato** il testo `mario ROSSI`
- **Quando** si chiama `CapFirst`
- **Allora** il risultato è `Mario Rossi`

### Scenario: apostrofo
- **Dato** il testo `L'AQUILA`
- **Quando** si chiama `CapFirst`
- **Allora** il risultato è `L'aquila`

### Scenario: nome di campo
- **Dato** il nome di campo `DATA_NASCITA`
- **Quando** si chiama `FormatDisplayLabel`
- **Allora** il risultato è `Data Nascita`

### Scenario: underscore conservato
- **Dato** il testo `DATA_NASCITA`
- **Quando** si chiama `zzCapFirst(Valore, False)`
- **Allora** il risultato è `Data_Nascita`

## ZBASE-LIB-002 Confronti e valore predefinito
- `StartingWith(Testo, Prefisso)` e `EndsWith(Testo, Suffisso)` sono veri se il testo comincia o finisce con la sottostringa **senza distinguere le maiuscole**. Con una sottostringa vuota sono veri; con una sottostringa più lunga del testo sono falsi.
- `Contains(Testo, Cercato)` è vero se la sottostringa compare nel testo, **distinguendo le maiuscole**; con la sottostringa vuota è falso (DIV-LIB-15).
- `Coalesce(Primo, Secondo)` restituisce il primo se non è la stringa vuota, altrimenti il secondo se non è vuoto, altrimenti la stringa vuota. Una stringa di soli spazi conta come valorizzata.
- `StrToChar(Testo)` restituisce il primo carattere, o il carattere nullo (`#0`) se il testo è vuoto.

### Scenario: confronto senza maiuscole
- **Dato** il testo `Relazione.PDF`
- **Quando** si chiama `EndsWith(Testo, '.pdf')`
- **Allora** il risultato è vero

### Scenario: ricerca con maiuscole
- **Dato** il testo `Codice fiscale`
- **Quando** si chiama `Contains(Testo, 'FISC')`
- **Allora** il risultato è falso, mentre con `fisc` è vero

### Scenario: valore predefinito
- **Dato** il primo valore vuoto e il secondo `b`
- **Quando** si chiama `Coalesce`
- **Allora** il risultato è `b`

## ZBASE-LIB-003 Scomposizione di una stringa
`zSplitStr(Testo, Delimitatore, Voci, SenzaVuote)` svuota `Voci` e vi mette le parti del testo separate dal delimitatore (confronto con `AnsiPos`, sensibile alle maiuscole). Con `SenzaVuote` falso (predefinito) le parti vuote restano, e un delimitatore in coda produce una parte vuota finale; con `SenzaVuote` vero si scartano le parti vuote o fatte di soli spazi. Le parti non vengono ripulite dagli spazi. Un testo vuoto dà una parte vuota (o nessuna con `SenzaVuote` vero). Il delimitatore previsto è di **un solo carattere** (DIV-LIB-4): tutti i chiamanti attuali usano `;`.

### Scenario: parti vuote conservate
- **Dato** il testo `a;b;;c`
- **Quando** si chiama `zSplitStr(Testo, ';', Voci, False)`
- **Allora** `Voci` contiene `a`, `b`, la stringa vuota e `c`

### Scenario: parti vuote scartate
- **Dato** il testo `a; ;b;`
- **Quando** si chiama `zSplitStr(Testo, ';', Voci, True)`
- **Allora** `Voci` contiene solo `a` e `b`

## ZBASE-LIB-004 Percorsi e nomi di file
- `Path` è la cartella dell'eseguibile (`Application.ExeName`) con la barra finale. `Desktop` è la cartella del desktop dell'utente, **senza** barra finale (`SHGetFolderPath` con `CSIDL_DESKTOP`).
- `CalcPath(Testo)` toglie gli spazi ai bordi e aggiunge la barra finale se manca (DIV-LIB-5 per il testo vuoto).
- `FileNameNoExt(NomeFile)` restituisce il nome del file, senza cartella e senza l'ultima estensione. Se il nome non ha estensione resta com'è, e un punto presente solo nella cartella non conta (DIV-LIB-12 per un'estensione che compare già prima nel nome).
- `NomeFileFromDate(Data)` restituisce `aaaammgg` della data, due spazi e un testo con giorno della settimana, data e ora scritti per esteso, nella lingua del sistema (`dddd, dd mmmm yyyy hh mm ss`); il testo dopo i due spazi descrive l'istante **attuale**, non la data passata (DIV-LIB-9). Si usa per i nomi dei file di copia di sicurezza (`TzSystem.BackupZipIn` e la cartella `BackupLZ` in `zSystem.pas`), sempre con `Now`.
- `FolderFromID(ID, LunghezzaGruppo=3, LunghezzaTotale=15, Separatore='\')` porta l'identificativo a `LunghezzaTotale` cifre con zeri a sinistra, lo divide in gruppi di `LunghezzaGruppo` cifre e restituisce i gruppi **tranne l'ultimo**, ciascuno seguito dal separatore. Quindi `123` dà `000\000\000\000\` e `1234567` dà `000\000\001\234\`: tutti gli identificativi che differiscono solo per le ultime tre cifre finiscono nella stessa cartella (al massimo mille file per cartella). Con `LunghezzaGruppo` pari o minore di zero il ciclo non termina (DIV-LIB-13).
- `GetTempFileName` crea un file vuoto con nome univoco che comincia con `~` nella sottocartella `Temp` della cartella dell'eseguibile (creata se manca, vedi `TFolders.ModuleSubFolder`) e ne restituisce il percorso. Il file non viene mai cancellato: ci pensa il chiamante (DIV-LIB-8).

### Scenario: nome con più punti
- **Dato** il percorso `C:\Dati\Relazione.2026.pdf`
- **Quando** si chiama `FileNameNoExt`
- **Allora** il risultato è `Relazione.2026`

### Scenario: cartella di destinazione per identificativo
- **Dato** l'identificativo 1234567
- **Quando** si chiama `FolderFromID`
- **Allora** il risultato è `000\000\001\234\`
- **E** per 1234999 il risultato è lo stesso

### Scenario: file temporaneo
- **Dato** un programma in `D:\App\`
- **Quando** si chiama `GetTempFileName`
- **Allora** esiste un file vuoto `D:\App\Temp\~xxxx.tmp` (il nome esatto lo sceglie Windows)

## ZBASE-LIB-005 Nomi dei componenti
`ValidateComponentName(Nome)` sostituisce con `_` ogni carattere che non sia lettera `A-Z`/`a-z`, cifra o `_` (anche le lettere accentate). Non controlla che il primo carattere sia una lettera (DIV-LIB-19). `GetUniqueComponentName(Nome, Proprietario)` restituisce `Nome` se il proprietario è nullo o non ha un componente con quel nome, altrimenti `Nome0`, `Nome1`, ... il primo libero: il contatore **parte da zero** (il commento nel sorgente dice «1,2,3»).

### Scenario: nome da ripulire
- **Dato** il nome `Mario Rossi-1`
- **Quando** si chiama `ValidateComponentName`
- **Allora** il risultato è `Mario_Rossi_1`

### Scenario: nome già usato
- **Dato** un proprietario con componenti `Edit` e `Edit0`
- **Quando** si chiama `GetUniqueComponentName('Edit', Proprietario)`
- **Allora** il risultato è `Edit1`

## ZBASE-LIB-006 Valori e date nulli
- `IsNull(Valore)` è vero per un variante `Null` o non assegnato (`Unassigned`); la stringa vuota e lo zero non sono nulli.
- `NullDate` vale 0 (cioè 30/12/1899). `DateNull(Data)` è vero se la data è esattamente 0 o esattamente −700000 (il valore nullo di DevExpress); una data con ora, anche solo mezzogiorno del giorno zero, non è nulla. Una data reale del 30/12/1899 non si può quindi rappresentare.
- `DataZero` e `OraZero` valgono 0; `Data9999` vale 31/12/9999; `MaxDate(A, B)` restituisce la più recente.

### Scenario: data nulla
- **Dato** il valore 0 oppure −700000
- **Quando** si chiama `DateNull`
- **Allora** il risultato è vero

### Scenario: data vera
- **Dato** il giorno 1 novembre 2026
- **Quando** si chiama `DateNull`
- **Allora** il risultato è falso

## ZBASE-LIB-007 Anno corrente
`Year(Data)` restituisce l'anno. `Capodanno` è il 1 gennaio e `SanSilvestro` il 31 dicembre **dell'anno in corso** (letto dalla data del sistema), senza ora.

### Scenario: anno
- **Dato** il giorno 1 novembre 2026
- **Quando** si chiama `Year`
- **Allora** il risultato è 2026

## ZBASE-LIB-008 Tipi di campo
`IsNumeric(Tipo)` è vero per `ftSmallint`, `ftInteger`, `ftWord`, `ftAutoInc`, `ftLargeint`, `ftLongWord`, `ftShortint`, `ftByte`, `ftFloat`, `ftCurrency`, `ftBCD`, `ftFMTBcd`, `ftSingle`; non per `ftExtended` (DIV-LIB-11). `IsInteger(Tipo)` è vero solo per gli otto tipi interi dell'elenco.

### Scenario: campo decimale
- **Dato** un campo di tipo `ftFMTBcd`
- **Quando** si chiama `IsNumeric` e `IsInteger`
- **Allora** il primo è vero e il secondo falso

## ZBASE-LIB-009 Importi e durate
- `CurrencyToStr(Valore)` scrive l'importo con `FloatToStrF` in formato valuta, con simbolo, separatori e posizione del simbolo del sistema e con `FormatSettings.CurrencyDecimals` cifre decimali (precisione 18). Se la conversione solleva un'eccezione restituisce la stringa vuota.
- `MSecToStr(Millisecondi)` scrive la durata con `TimeToStr`, quindi nel formato dell'ora del sistema (con separatore e numero di cifre dei campi che dipendono dalla lingua). Oltre le 24 ore il numero di giorni non compare (DIV-LIB-17). Serve per i tempi trascorsi mostrati nelle barre di avanzamento.

### Scenario: importo in italiano
- **Dato** il sistema con simbolo `€` dopo l'importo, due decimali, virgola decimale e punto per le migliaia
- **Quando** si chiama `CurrencyToStr(1234.5)`
- **Allora** il risultato è `1.234,50 €`

### Scenario: durata
- **Dato** 65000 millisecondi
- **Quando** si chiama `MSecToStr`
- **Allora** il risultato è un minuto e cinque secondi nel formato dell'ora del sistema (`00:01:05` con il formato italiano)

## ZBASE-LIB-010 Colore del testo leggibile
`GetContrastColor(Sfondo)` restituisce `clBlack` o `clWhite` per il testo da scrivere su quello sfondo. Con uno sfondo minore o uguale a 0 (nero, o colore di sistema come `clBtnFace`, che è negativo) o con `clWhite` restituisce `clBlack`. Per gli altri calcola la luminanza `0.299 R + 0.587 G + 0.114 B` e restituisce nero se è almeno 127,5 (sfondo chiaro), bianco se è minore (sfondo scuro). Per lo sfondo nero e per i colori di sistema il risultato non è leggibile (DIV-LIB-6).

### Scenario: sfondo scuro
- **Dato** lo sfondo `clNavy`
- **Quando** si chiama `GetContrastColor`
- **Allora** il risultato è `clWhite`

### Scenario: sfondo chiaro
- **Dato** lo sfondo `clYellow`
- **Quando** si chiama `GetContrastColor`
- **Allora** il risultato è `clBlack`

## ZBASE-LIB-011 Posizione delle finestre
`SaveFormPosition(Form, FileIni, Sezione)` e `LoadFormPosition` ricordano posizione e misura di una finestra in un file `.ini` (la sezione predefinita è il nome della form). Le usano `TzDialog` e `zDbViewDlg` con il file delle finestre di dialogo (`Base.ConfigFileName(Ext_Dlgs)`).
- **Salvataggio:** se la cartella del file non esiste esce senza scrivere (DIV-LIB-14: un nome senza cartella non si salva mai). Scrive `State` (numero dello stato della finestra), e, se la finestra non è ridotta a icona, `Top`, `Left`, `Height`, `Width` e `PPI` (punti per pollice della finestra). Le misure sono quelle **normali**: se la finestra è massimizzata si leggono da `GetWindowPlacement`, corrette dello scarto fra area utile e area intera del monitor.
- **Caricamento:** se si tiene premuto **Ctrl** non cambia nulla (modo per ritrovare una finestra sparita). Se la sezione esiste imposta `Position` a `poDesigned`. Legge `Left`, `Top`, `Width`, `Height` (i valori mancanti restano quelli attuali). Larghezza e altezza si riportano al PPI attuale con il rapporto `PPI attuale / PPI salvato` (se la chiave `PPI` manca si presume 96, e si scala solo se `Width` o `Height` sono presenti nel file: Mantis #310). Per le finestre che non sono figlie MDI il rettangolo si riporta dentro l'area utile del monitor più vicino: prima lo si riduce se è più grande, poi lo si sposta se sborda. Infine applica le misure con `SetBounds` e lo stato; una finestra salvata ridotta a icona si riapre in stato normale.

### Scenario: riapertura
- **Dato** una finestra salvata a sinistra 100, in alto 100, larga 400 e alta 300
- **Quando** la si carica da un'altra finestra con la stessa sezione
- **Allora** la finestra ha le stesse misure

### Scenario: file salvato a un altro PPI
- **Dato** una finestra salvata larga 200 con PPI 96, aperta su un monitor a 192
- **Quando** si chiama `LoadFormPosition`
- **Allora** la larghezza diventa 400

### Scenario: monitor più piccolo
- **Dato** una finestra salvata più grande dell'area utile del monitor attuale
- **Quando** si chiama `LoadFormPosition`
- **Allora** la finestra sta interamente nell'area utile

## ZBASE-LIB-012 Tipo di controllo (`TzCtrlType`)
`TzCtrlType` elenca i tipi di editor che il dizionario LZ può assegnare a un campo (da `ctDefault` a `ctLineBreak`, 37 valori). L'helper offre:
- `AsString`: il nome dell'enumerato come testo (`ctMemo`); in scrittura converte il testo nel valore con `TRttiEnumerationType.GetValue`. È la forma con cui il dizionario salva il tipo (`zSystem.pas`, `zMetadata.Loader.pas`).
- `DefaultLookupCtrlType` = `ctLookupExt`; `DefaultPickListCtrlType` = `ctPickListImage`.
- `IsLookup`: `ctLookup`, `ctLookupExt`, `ctLookupHyperLink` (`ctComboDlg` è stato tolto di proposito: caso `REPORT_FILE` di `GedoEstrazioniMassive`). `IsPickList`: `ctPickList`, `ctPickListImage`. `IsHyperLink`: `ctHyperLink`, `ctLookupHyperLink`.
- `IsMemo`: `ctMemo`, `ctRTF`. `IsBlob`: `ctImage`, `ctMemo`, `ctRTF`. `IsBoolean`: `ctCheckBox`, `ctToggleSwitch`. `IsGroup`: `ctCheckGroupBox`, `ctGroupBox`. `IsLineBreak`: solo `ctLineBreak`; `IsSeparator`: solo `ctSeparator`.
- `IsMultiLine`: `ctMemo`, `ctRTF`, `ctImage`, `ctRadioGroup`, `ctCheckGroup`, `ctCheckGroupBox`, `ctDateTimeWheelPicker`, `ctGroupBox`.
- `IsDataAware` (legato a un campo dei dati): tutti **tranne** `ctGroupBox`, `ctButton`, `ctSeparator`, `ctLineBreak`.
- `ValidForCard`: sempre vero. `ValidForView`: `IsDataAware` e non uno fra `ctRadioGroup`, `ctCheckGroupBox`, `ctDateTimeWheelPicker`, `ctCheckGroup` (nessun chiamante trovato nei sorgenti).

### Scenario: salvataggio nel dizionario
- **Dato** il tipo `ctLookupExt`
- **Quando** si legge `AsString`
- **Allora** il risultato è `ctLookupExt`
- **E** assegnando questo testo a un altro `TzCtrlType` si ottiene `ctLookupExt`

### Scenario: gruppo con caselle di spunta
- **Dato** il tipo `ctCheckGroupBox`
- **Quando** si chiamano `IsGroup` e `IsDataAware`
- **Allora** entrambi sono veri, mentre per `ctGroupBox` `IsDataAware` è falso

## ZBASE-LIB-013 Enumerati e testo (`TEnum<T>`)
`TEnum<T>.EnumToString(Valore)` restituisce il nome del valore (`GetEnumName`); `TEnum<T>.StringToEnum(Nome)` restituisce il valore con quel nome (`GetEnumValue`). Gestiscono solo enumerati di 1, 2 o 4 byte; con altre misure il risultato resta vuoto o non assegnato. Con un nome inesistente non c'è nessun errore: il risultato è un valore fuori dall'enumerato (DIV-LIB-7). Usata in 12 righe di WT, Gesty e zPack.

### Scenario: nome noto
- **Dato** il testo `ctRTF`
- **Quando** si chiama `TEnum<TzCtrlType>.StringToEnum`
- **Allora** il risultato è `ctRTF`

## ZBASE-LIB-014 Azioni nascoste e disabilitate
`ActionVisible(Azione, Visibile)` imposta **sia** `Visible` sia `Enabled` al valore indicato: un'azione solo nascosta risponderebbe ancora alla scorciatoia da tastiera. Non conserva lo stato precedente di `Enabled`: chiamarla con vero abilita l'azione anche se era disabilitata per altri motivi. Lo usa quasi ogni form per i permessi.

### Scenario: azione nascosta
- **Dato** un'azione visibile e abilitata
- **Quando** si chiama `ActionVisible(Azione, False)`
- **Allora** `Visible` e `Enabled` sono entrambi falsi

## ZBASE-LIB-015 Finestra di attesa
`StartWait(Messaggio='Attendere...', SenzaTimer=True)` esegue prima, se assegnato, il gestore globale `OnStartWait`, poi apre la finestra di attesa di `zWaitFrm`; `StopWait` esegue `OnStopWait` e poi chiude la finestra; `UpdateWait(Messaggio)` cambia solo il testo e **non** richiama nessun gestore. I gestori sono variabili della unit (`OnStartWait`, `OnStopWait`, di tipo `TProc`), pensate perché l'applicazione intervenga (ad esempio per sospendere i timer). `zBaseLib` non tiene nessun conteggio dei livelli annidati: come si comporta la finestra con due `StartWait` seguiti da un solo `StopWait` lo decide `zWaitFrm`, che qui non è stata verificata.

### Scenario: gestore di avvio
- **Dato** `OnStartWait` assegnato
- **Quando** si chiama `StartWait('Elaboro...')`
- **Allora** il gestore viene eseguito prima della comparsa della finestra

## ZBASE-LIB-016 Ambiente e tasti
- `ComputerName` è il nome del computer in maiuscolo (`GetComputerName`); vuoto se la lettura fallisce.
- `GetFileVersion` restituisce la versione del file dell'eseguibile nella forma `a.b.c.d` (le quattro parti numeriche), o la stringa vuota se il file non ha informazioni di versione. Si legge il file indicato da `Application.ExeName` per la misura e `ParamStr(0)` per il contenuto (DIV-LIB-20). La usano la barra di stato delle finestre principali di WT e Gesty, la finestra «Informazioni» e la registrazione dell'uso (`WT.Uso`, `Gesty.Uso`, che ne tengono i primi caratteri).
- `Debug` è vero se il programma gira sotto debugger (`DebugHook <> 0`).
- `CtrlKey` e `ShiftKey` sono veri se il tasto è premuto in questo momento (`GetKeyState`), indipendentemente da quale finestra abbia il fuoco.
- `Onnipotente` è vero se `ComputerName` è `MASTER`, `LUCA` o `VOYAGER` (DIV-LIB-3). In WT la usa `frmCassa` per riservare una funzione.

### Scenario: nome del computer
- **Dato** la variabile d'ambiente `COMPUTERNAME` con valore `pc-uno`
- **Quando** si chiama `ComputerName`
- **Allora** il risultato è `PC-UNO`

### Scenario: versione
- **Dato** un eseguibile con versione 1.2.3.4
- **Quando** si chiama `GetFileVersion`
- **Allora** il risultato è `1.2.3.4`

## ZBASE-LIB-017 Password di protezione
`PasswordOk(Titolo, Doppia=False)` protegge le operazioni delicate (in WT: «Tabelle di Sistema», «Esporta Base Dati» con `Doppia` vero, «Rettifica Indirizzo Utenza», «Deconsolidamento ingiunzione»); `PasswordXX(Titolo)` protegge «Svuotamento utenze». Le password non sono personali né configurabili: sono costanti scritte nel sorgente e valgono per ogni installazione (DIV-LIB-2).
- `PasswordOk` restituisce subito vero se `Onnipotente` è vero (DIV-LIB-3). Altrimenti apre `InputPassword(Titolo, 'Password', ...)`: se l'utente annulla il risultato è falso, senza messaggio; se la password è diversa (il confronto non distingue le maiuscole) mostra `Password errata` con `ShowMessage` e il risultato è falso. Con `Doppia` vero, dopo la prima password giusta chiede una seconda (`Password 2`) con la stessa regola; se l'utente **annulla la seconda finestra il risultato resta vero** (DIV-LIB-1), mentre una seconda password sbagliata dà falso e il messaggio.
- `PasswordXX` apre una sola finestra, con la stessa regola di confronto e di messaggio, e **non** salta la richiesta sui computer di `Onnipotente`.

### Scenario: password giusta
- **Dato** un computer non riservato
- **Quando** l'utente digita la password giusta in `PasswordOk('Tabelle di Sistema')`
- **Allora** il risultato è vero

### Scenario: password sbagliata
- **Dato** lo stesso computer
- **Quando** l'utente digita una password diversa
- **Allora** compare `Password errata` e il risultato è falso

### Scenario: seconda password annullata
- **Dato** `PasswordOk('Esporta Base Dati', True)` con la prima password giusta
- **Quando** l'utente preme Annulla nella seconda finestra
- **Allora** il risultato (oggi) è vero: è DIV-LIB-1, il comportamento atteso è falso

## ZBASE-LIB-018 Finestra proprietaria
`GetPopupParent(Componente)` risale la catena dei proprietari (`Owner`), partendo dal componente stesso, e restituisce la prima `TCustomForm` che trova; se non ne trova restituisce `Screen.ActiveCustomForm` (che può essere nulla). Serve per le finestre modali che altrimenti finirebbero dietro quella che le apre. Chiamata con una form restituisce la form stessa: per i dialoghi che passano `Self` il risultato è quindi il dialogo medesimo (vedi `Finestre di dialogo.md`, DIV-MSG-4).

### Scenario: componente dentro una form
- **Dato** un componente il cui proprietario è la form `FormClienti`
- **Quando** si chiama `GetPopupParent`
- **Allora** il risultato è `FormClienti`

### Scenario: nessuna form
- **Dato** un componente senza proprietario e nessuna finestra attiva
- **Quando** si chiama `GetPopupParent`
- **Allora** il risultato è nullo

## ZBASE-LIB-019 Salvataggio del DFM di un componente
`ComponentToDFM(Componente, NomeFile, Antenato=nil)` crea o sovrascrive il file e vi scrive il testo DFM del componente (`WriteDescendent` più `ObjectBinaryToText`). Il file viene aperto **prima** della conversione: se questa fallisce resta un file vuoto o parziale. Se il percorso non è scrivibile solleva `EFCreateError`. La usano l'ispettore delle applicazioni (`FrmApplicationInspector`) e l'editor dei dataset. Esiste anche una `ComponentToDFM(Componente, NomeFile)` in `Lib_DFM.pas` con una firma diversa (DIV-LIB-22).

### Scenario: componente semplice
- **Dato** un `TComponent` di nome `ComponenteProva`
- **Quando** si chiama `ComponentToDFM(Componente, File)`
- **Allora** il file contiene `object ComponenteProva: TComponent`

## ZBASE-LIB-020 Cambio di una stringa di risorsa
`ChangeResourceString(RiferimentoRisorsa, NuovoValore)` sostituisce in memoria il testo di una `resourcestring`: toglie la protezione di scrittura alla pagina, scrive in `Identifier` il puntatore al nuovo testo e rimette la protezione. Restituisce falso se il riferimento è nullo e vero se la modifica riesce. Il nuovo testo deve restare valido finché il programma gira (si conserva solo il puntatore). Con `NuovoValore` nullo scatta un `Assert`. **Nessun progetto in `SRC` la chiama**: la usano solo le unit di traduzione di DevExpress (`dxItalian\dxItalian_Consts_*.pas`, circa mille chiamate), per questo non si toglie.

### Scenario: traduzione
- **Dato** una `resourcestring` con testo inglese
- **Quando** si chiama `ChangeResourceString(@Risorsa, 'Testo italiano')`
- **Allora** la lettura della risorsa restituisce `Testo italiano`

## ZBASE-LIB-021 Costanti e tipi condivisi
`Apice` è il carattere apostrofo (`#39`). `NullDate` vale 0. Le costanti di colore `clSkyBlue`, `clMoneyGreen`, `clCream` e `clInfo` sono definite nella unit (`clInfo` è il colore di sistema `clInfoBk`). `zException` è l'eccezione base `Exception` delle applicazioni. `TzHyperLinkEvent` e `TzCustomDialogEvent` sono i tipi di evento di collegamenti ipertestuali e dialoghi personalizzati dei controlli generati dal dizionario.

### Scenario: apostrofo
- **Dato** la costante `Apice`
- **Quando** la si usa per scrivere un valore SQL
- **Allora** vale il carattere `'`

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LIB-1 🔴 (dedotta) | In `PasswordOk` con `Doppia` vero, l'`else` della riga `if uppercase(s) = ...` appartiene al confronto e non alla finestra: se l'utente preme Annulla nella seconda finestra (`InputPassword` restituisce falso) non succede nulla e `result` resta vero dalla prima verifica | Chi conosce la prima password supera la protezione dell'esportazione della base dati in WT (`MainForm.pas`, «Esporta Base Dati») senza la seconda: basta annullare |
| DIV-LIB-2 🔴 (dedotta) | Le due password di `PasswordOk` e quella di `PasswordXX` sono costanti nel sorgente (composte lettera per lettera per non comparire intere), uguali per tutte le installazioni e confrontate in chiaro | Chiunque abbia letto il sorgente o l'eseguibile le conosce; non si possono cambiare né revocare per un cliente; proteggono operazioni distruttive come lo svuotamento delle utenze |
| DIV-LIB-3 🟡 (dedotta) | `Onnipotente` e quindi `PasswordOk` si fidano del nome del computer (`MASTER`, `LUCA`, `VOYAGER`) | Rinominando un computer si salta la richiesta della password e si apre `frmCassa` riservata; `PasswordXX` invece non salta nulla, comportamento diverso senza motivo dichiarato |
| DIV-LIB-4 🟡 (dedotta) | `zSplitStr` cerca il delimitatore con `AnsiPos` (anche di più caratteri) ma dopo averlo trovato salta un solo carattere (`copy(curStr, curpos + 1, ...)`): con `\|\|` la parte successiva comincia con una barra | Oggi tutti i chiamanti usano `;`, quindi non si vede; chi passasse un delimitatore di due caratteri otterrebbe voci sporche |
| DIV-LIB-5 🟡 (dedotta) | `CalcPath('')` restituisce `IncludeTrailingPathDelimiter('')`, che nella RTL di Delphi per la stringa vuota dà `\` (radice dell'unità corrente) e non il vuoto | Un percorso non configurato diventa la radice del disco: `CalcPath(DestFolder) + FolderFromID(...)` scriverebbe fuori dalla cartella prevista; da verificare nella RTL in uso |
| DIV-LIB-6 🟡 (dedotta) | `GetContrastColor` restituisce `clBlack` per ogni sfondo minore o uguale a 0, quindi anche per `clBlack` e per i colori di sistema (negativi), senza convertirli con `ColorToRGB` | Testo nero su sfondo nero e colori di sistema che non si adattano al tema: testo illeggibile |
| DIV-LIB-7 🟡 (provata) | `TEnum<T>.StringToEnum` con un nome inesistente assegna il risultato `-1` di `GetEnumValue` a un byte, una parola o una doppia parola senza controllo | Nessun errore e un valore dell'enumerato non valido (255 per un enumerato di un byte); i `case` successivi sul valore cadono sul ramo vuoto |
| DIV-LIB-8 🟡 (dedotta) | `GetTempFileName` non inizializza il buffer e non controlla il risultato di `Winapi.Windows.GetTempFileName`; inoltre il file non viene mai cancellato | Se la cartella `Temp` non è scrivibile restituisce il contenuto casuale del buffer come percorso; i file `~*.tmp` si accumulano se il chiamante non li elimina |
| DIV-LIB-9 🟢 (dedotta) | `NomeFileFromDate(Data)` usa `Data` solo per il prefisso `aaaammgg`; il testo seguente viene da `Now` (nella vecchia versione commentata, `CalcolaNomeFileDaData`, veniva dalla data) | Chiamata con una data diversa da `Now` produce un nome incoerente; i due chiamanti passano `Now` e non se ne accorgono |
| DIV-LIB-10 🟢 | Il commento di `GetUniqueComponentName` dice «aggiunge 1,2,3» ma il contatore parte da 0 | Il primo nome libero è `Nome0`, non `Nome1`; il comportamento è questo, il commento è sbagliato |
| DIV-LIB-11 🟢 (dedotta) | `IsNumeric` non include `ftExtended` (che invece ha tutti gli altri numerici) | Un campo `ftExtended` non è riconosciuto come numerico dai chiamanti (5 righe); FireDAC con Firebird non lo produce, quindi oggi non si vede |
| DIV-LIB-12 🟢 (dedotta) | `FileNameNoExt` toglie la **prima** occorrenza dell'estensione dentro il nome, non l'ultima: `rel.docx.doc` diventa `relx.doc` | Succede solo con un'estensione che compare già, uguale, prima nel nome; usata in 61 righe e nei nomi delle copie di sicurezza del dizionario LZ |
| DIV-LIB-13 🟢 (dedotta) | `FolderFromID` con `LunghezzaGruppo` minore o uguale a zero non termina (`copy(s, 1, 0)` e `Delete(s, 1, 0)` non accorciano la stringa) | Nessun chiamante passa zero (le due chiamate usano i valori predefiniti), quindi è latente |
| DIV-LIB-14 🟢 (dedotta) | `SaveFormPosition` con un nome di file senza cartella (`ExtractFilePath` vuoto) esce perché `TDirectory.Exists('')` è falso | I due chiamanti passano percorsi completi; un nome relativo non verrebbe mai salvato, senza errore |
| DIV-LIB-15 🟢 | `Contains` distingue le maiuscole e con la sottostringa vuota è falso, mentre `StartingWith` e `EndsWith` non le distinguono e con la sottostringa vuota sono veri | Tre funzioni dello stesso gruppo con regole diverse: chi le scambia ottiene risultati diversi senza accorgersene |
| DIV-LIB-16 🟢 | `StartingWith` esiste anche in `zz.Strings` (`zLibs`) con lo stesso nome e la stessa regola (`StartsWith(..., True)`) | Una unit che include entrambe usa quella scritta per ultima; oggi i comportamenti coincidono (a meno del trattamento di `Copy(s, 0, n)` in `zBaseLib`, da verificare) ma restano due copie da tenere allineate |
| DIV-LIB-17 🟢 (dedotta) | `MSecToStr` usa `TimeToStr`, che ignora la parte intera (i giorni); il parametro è un `Integer` (circa 24,8 giorni al massimo) | Una durata di 25 ore si scrive come 1 ora; nelle barre di avanzamento di fatture elettroniche e PagoPA (WT) un'elaborazione lunga mostrerebbe un tempo sbagliato |
| DIV-LIB-18 🟢 (dedotta) | `PasswordOk` con `Doppia` riusa la variabile `s`, che contiene ancora la prima password, come valore iniziale della seconda finestra | La casella `Password 2` si apre già riempita (mascherata) con la prima password: l'utente deve cancellarla prima di scrivere la seconda |
| DIV-LIB-19 🟢 (dedotta) | `ValidateComponentName` non gestisce il nome vuoto né un nome che comincia con una cifra | `1abc` resta `1abc`, che non è un identificativo valido; chi assegna il risultato a `Name` ottiene un'eccezione (22 chiamanti) |
| DIV-LIB-20 🟢 (dedotta) | `GetFileVersion` misura le informazioni con `Application.ExeName` ma le legge con `ParamStr(0)`, e non controlla il risultato di `VerQueryValue` | In una DLL o in un programma ospitato i due nomi possono differire; se la lettura fallisce il puntatore resta nullo e si legge da lì |
| DIV-LIB-21 🟢 (dedotta) | `ChangeResourceString` converte il puntatore con `Integer(newvalue)` | A 64 bit il puntatore verrebbe troncato; il lavoro resta corretto a 32 bit (da verificare per quale piattaforma sono compilati WT e Gesty) |
| DIV-LIB-22 🟢 | `Delay` non ha chiamanti in WT, Gesty e zPack (codice morto che ferma il flusso e rielabora i messaggi); `ComponentToDFM` esiste anche in `Lib_DFM.pas` con firma diversa e l'ordine delle `uses` decide quale si chiama | Codice che confonde e che il compilatore non segnala; la scelta fra le due `ComponentToDFM` dipende dall'ordine delle unit |
