---
area: Funzioni sui testi
progetto: zLibs
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Funzioni sui testi

Questa specifica descrive le funzioni libere di `zLibs\zz.Strings.pas` (la unit si dichiara `zz.strings`, in minuscolo: per il compilatore è lo stesso nome): riempimento a sinistra e a destra, confronto dell'inizio di un testo, rimozione di sottostringhe, conteggio ed estrazione di parole, eliminazione dei ritorni a capo, scelta fra due testi. Sono funzioni pure, senza dipendenze da interfaccia o database. La unit non è elencata in nessun pacchetto (`.dpk`) né nei `.dpr`/`.dproj` di WT e Gesty: si compila perché sta nel percorso di ricerca e viene citata nelle clausole `uses`.

Chi le usa davvero (verificato con una ricerca in `D:\AI\SRC\Wintarif_Group`, `Gesty_Group` e `zPack`):

| Funzione | Chiamanti |
|---|---|
| `PadString` | WT: `dmCNC_290`, `dmMAV`, `dmRID` (nomi dei file dei flussi bancari), `dmCommon` (numero di conto a 12 cifre), `dmIntestatari` e `wizIntestatario_DM` (`CODICE_UTENZA` = Belfiore + 8 cifre), `dmStruttureFlussi` (righe di intestazione e filtri dei tracciati), `CheckScanner`, `WT.Lib` (codici a barre e nome dei bollettini), `dmRC_ExtraGestione`; zPack: `zBaseLib` |
| `PadStringRight` | WT: `frmQta_Barcode` (`PadStringRight(BelfioreDiLavoro, 12)`) |
| `StartingWith` | WT: `dmMAV` (riga che comincia con `KPDF`) |
| `RemoveStrings` | Gesty server: `Gesty_Group\_Sorgenti_Server\core\route.pas` (e la copia in `GeCo\sorgenti_wt_server`), che toglie da un filtro JSON le sequenze `[`, `{`, `"property"`, `:`, `"`, `}`, `]` |
| `WordCount`, `ExtractWord`, `RemoveCR`, `IIF`, `TCharSet` | nessun chiamante: `zFIB` usa le proprie versioni in `zSql.StrUtil`, il server Gesty ha `fib.StrUtil`, `zStringHelper` ha un suo `IIF` |

**Come funziona.** Tutte le funzioni lavorano sul testo ricevuto e restituiscono un testo nuovo; nessuna modifica i parametri. Il riempimento non tronca mai. Il confronto dell'inizio e la rimozione di sottostringhe non distinguono le maiuscole. Le funzioni sulle parole trattano una serie di delimitatori consecutivi come un solo separatore.

**Test che coprono quest'area.** `Test.zz.Strings` (in `zPack\_UnitTest\_src`): una prova per ogni requisito e per i casi limite con testo vuoto e caratteri Unicode.

## ZLIBS-STR-001 Riempimento a sinistra
`PadString(Testo, N, Carattere)` restituisce il testo preceduto da tanti `Carattere` quanti ne servono per arrivare a `N` caratteri. Il carattere predefinito è `'0'`. Se il testo ha già `N` o più caratteri è restituito invariato: **non viene mai troncato**. Un testo vuoto dà `N` caratteri di riempimento. `N` zero dà il testo invariato.

### Scenario: numero con zeri iniziali
- **Dato** il testo `7` e `N` = 3
- **Quando** si chiama `PadString('7', 3)`
- **Allora** il risultato è `007`

### Scenario: testo più lungo di N
- **Dato** il testo `12345` e `N` = 3
- **Quando** si chiama `PadString`
- **Allora** il risultato è `12345`, senza troncamento

### Scenario: riga di trattini
- **Dato** il testo vuoto, `N` = 5 e il carattere `-`
- **Quando** si chiama `PadString('', 5, '-')`
- **Allora** il risultato è `-----` (è così che `dmStruttureFlussi` disegna le righe di separazione)

### Scenario: riempimento con spazi
- **Dato** il testo `ab`, `N` = 5 e il carattere spazio
- **Quando** si chiama `PadString`
- **Allora** il risultato è tre spazi seguiti da `ab`

## ZLIBS-STR-002 Riempimento a destra
`PadStringRight(Testo, N, Carattere)` è il simmetrico di `PadString`: aggiunge in coda. Anche qui il carattere predefinito è `'0'` (non lo spazio) e il testo più lungo di `N` resta invariato.

### Scenario: riempimento predefinito
- **Dato** il testo `X` e `N` = 3
- **Quando** si chiama `PadStringRight('X', 3)`
- **Allora** il risultato è `X00`

### Scenario: riempimento con spazi
- **Dato** il testo `ab`, `N` = 5 e il carattere spazio
- **Quando** si chiama `PadStringRight`
- **Allora** il risultato è `ab` seguito da tre spazi

## ZLIBS-STR-003 Conteggio delle parole
`WordCount(Testo, Delimitatori)` conta i gruppi di caratteri consecutivi che non sono delimitatori. I delimitatori consecutivi, iniziali o finali non producono parole vuote. Un testo vuoto o fatto di soli delimitatori vale 0.

### Scenario: delimitatori ripetuti
- **Dato** il testo `a,,b,` e il delimitatore virgola
- **Quando** si chiama `WordCount`
- **Allora** il risultato è 2

### Scenario: testo senza parole
- **Dato** il testo vuoto, oppure `,,,`
- **Quando** si chiama `WordCount` con il delimitatore virgola
- **Allora** il risultato è 0

## ZLIBS-STR-004 Estrazione di una parola
`ExtractWord(N, Testo, Delimitatori)` restituisce la `N`-esima parola, contando da 1 e saltando i delimitatori consecutivi. Se `N` è 0, negativo o maggiore del numero di parole, restituisce la stringa vuota senza sollevare errori.

### Scenario: seconda parola
- **Dato** il testo `uno,,due,tre` e il delimitatore virgola
- **Quando** si chiama `ExtractWord(2, ...)`
- **Allora** il risultato è `due`

### Scenario: indice fuori misura
- **Dato** lo stesso testo
- **Quando** si chiama `ExtractWord(0, ...)` oppure `ExtractWord(4, ...)`
- **Allora** il risultato è la stringa vuota

## ZLIBS-STR-005 Eliminazione dei ritorni a capo
`RemoveCR(Testo)` porta prima ogni interruzione di riga (CR, LF o CR LF) alla forma `CR LF` con `AdjustLineBreaks`, poi sostituisce ogni `CR LF` con **uno spazio**. Il nome è fuorviante: le righe non vengono unite senza spazio ma separate da uno spazio, e due interruzioni consecutive danno due spazi.

### Scenario: tre forme di interruzione
- **Dato** i testi `a` CR LF `b`, `a` LF `b` e `a` CR `b`
- **Quando** si chiama `RemoveCR`
- **Allora** il risultato è sempre `a b`

## ZLIBS-STR-006 Scelta fra due testi
`IIF(Condizione, SeVero, SeFalso)` restituisce `SeVero` se la condizione è vera, altrimenti `SeFalso`. Essendo una funzione, entrambi gli argomenti sono calcolati prima della chiamata.

### Scenario: condizione vera e falsa
- **Dato** i testi `si` e `no`
- **Quando** si chiama `IIF(True, 'si', 'no')` e `IIF(False, 'si', 'no')`
- **Allora** i risultati sono `si` e `no`

## ZLIBS-STR-007 Inizio di un testo
`StartingWith(Testo, Prefisso)` è vera se `Testo` comincia con `Prefisso`, **senza distinzione di maiuscole**. È falsa se il prefisso è più lungo del testo e se il testo è vuoto con prefisso non vuoto. Non toglie gli spazi: `' abc'` non comincia con `abc`. Il risultato con prefisso vuoto non è stato verificato (vedi i dubbi nel rapporto: dipende dall'implementazione di `StartsWith` del compilatore).

### Scenario: maiuscole diverse
- **Dato** il testo `Wintarif`
- **Quando** si chiama `StartingWith('Wintarif', 'WIN')`
- **Allora** il risultato è vero

### Scenario: prefisso più lungo
- **Dato** il testo `Win`
- **Quando** si chiama `StartingWith('Win', 'Wintarif')`
- **Allora** il risultato è falso

## ZLIBS-STR-008 Rimozione di sottostringhe
`RemoveStrings(Testo, Elenco)` toglie, **una dopo l'altra e nell'ordine dell'elenco**, tutte le occorrenze di ciascuna sottostringa, senza distinzione di maiuscole. Il testo di partenza di ogni passo è il risultato del passo precedente: la rimozione di una sottostringa può quindi creare una nuova occorrenza di quelle seguenti, e l'ordine dell'elenco conta. Con elenco vuoto il testo è invariato.

### Scenario: più sottostringhe
- **Dato** il testo `a-b_c` e l'elenco `-`, `_`
- **Quando** si chiama `RemoveStrings`
- **Allora** il risultato è `abc`

### Scenario: senza distinzione di maiuscole
- **Dato** il testo `FooBAR` e l'elenco `bar`
- **Quando** si chiama `RemoveStrings`
- **Allora** il risultato è `Foo`

### Scenario: ordine e passi successivi
- **Dato** il testo `aabb` e l'elenco `ab`, `ab`
- **Quando** si chiama `RemoveStrings`
- **Allora** il primo passo lascia `ab` e il secondo `` (stringa vuota)

### Scenario: filtro del server Gesty
- **Dato** il testo `[{"property":"NOME"}]` e l'elenco `[`, `{`, `"property"`, `:`, `"`, `}`, `]`
- **Quando** si chiama `RemoveStrings`
- **Allora** il risultato è `NOME`

## ZLIBS-STR-009 Caratteri Unicode
Tutte le funzioni lavorano sui caratteri `Char` di Delphi (UTF-16): un carattere accentato o il simbolo dell'euro conta come un carattere nei riempimenti e nelle parole, purché non sia usato come delimitatore (DIV-STR-1).

### Scenario: parole con accenti
- **Dato** il testo `Citta` con accento finale, `di`, `Roma` separati da spazi
- **Quando** si chiama `WordCount` con il delimitatore spazio
- **Allora** il risultato è 3 e `ExtractWord(1, ...)` restituisce la prima parola intera con l'accento

### Scenario: riempimento di un testo con euro
- **Dato** il testo formato dal solo simbolo dell'euro
- **Quando** si chiama `PadString(testo, 3)`
- **Allora** il risultato è `00` seguito dal simbolo

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-STR-1 🟡 (dedotta) | `TCharSet` è `set of char`: in un insieme il compilatore riduce il carattere a un byte (avviso W1050 «WideChar reduced to byte char in set expressions»). `WordCount` e `ExtractWord` verificano `S[I] in WordDelims`, quindi un carattere oltre U+00FF coincide con quello che ha lo stesso byte basso | Un carattere come U+0120 viene scambiato per lo spazio (U+0020) e spezza una parola. Nessun chiamante oggi usa queste due funzioni (zFIB ha le sue), quindi il difetto è solo latente |
| DIV-STR-2 🟡 | Esistono più `StartingWith` con lo stesso nome e la stessa firma: `zz.Strings` (usa `StartsWith` senza distinzione di maiuscole) e `zBaseLib` (esportata: `Copy(S, 0, Length(Prefisso))` e `SameText`), più copie locali non esportate in `zFbDataSet`, `CBI_EsitiMAV` e `CBI_Riconciliazioni`. Anche `PadString` esiste in Indy (`IdGlobalProtocols`, con il terzo parametro obbligatorio) | Per le due versioni esportate quella usata dipende dall'ordine delle unit nella clausola `uses` (vince l'ultima): `dmMAV` elenca `zBaseLib` e poi `zz.strings`, quindi usa questa. Spostare una unit nell'elenco può cambiare il comportamento in silenzio, soprattutto con prefisso vuoto |
| DIV-STR-3 🟢 | `RemoveCR` non elimina i ritorni a capo: li sostituisce con uno spazio (ZLIBS-STR-005). Nessun chiamante | Chi la sceglie per «togliere i CR» ottiene parole separate da spazio; il nome andrebbe cambiato o chiarito prima di un uso nuovo |
| DIV-STR-4 🟢 | `WordCount`, `ExtractWord`, `RemoveCR`, `IIF`, `TCharSet` non hanno chiamanti in WT, Gesty e zPack; `ExtractWord` costruisce il risultato carattere per carattere con `Result := Result + S[I]` | Codice morto che duplica quello di `zSql.StrUtil` e `fib.StrUtil`: ogni correzione va fatta in più posti, oppure le copie vanno tolte |
