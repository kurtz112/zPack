---
area: Layout colonne della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Layout colonne della vista

Questa specifica descrive dove e come una `TzDbView` conserva la disposizione delle sue colonne (visibilità, posizione, larghezza) e le impostazioni della vista, e in che ordine le rilegge all'apertura. Il codice è in `zBase\zDbView.Storage.pas` (`TzDbViewStorage`), `zDbView.Controller.pas` (`TzDbViewController`, che decide quando scrivere dove) e `zDbView.pas` (`CheckColumnWidths`, `AllargaColonneAlContenuto`, `actPersonalizzaExecute`). Lo usano tutte le viste di WT e Gesty.

**Come funziona.** Ci sono due livelli. Il **dizionario LZ** (`zDbViewProps`, caricato con `LoadFromBase` e salvato con `SaveToBase`) vale per tutti gli utenti: colonne, flag, titolo, formattazione. Il **layout personale** è un file `.Columns` per utente e per programma (`base.ConfigFileName('.Columns')`), con una sezione per vista (il nome della sezione è `ViewID`, di norma l'identificativo del dataset) e, per ogni colonna, due chiavi: `NOMECAMPO=indice` e `NOMECAMPO_Width=larghezza`. All'apertura si carica prima il dizionario, poi il layout personale lo ricopre. Il salvataggio del solo layout personale non tocca il dizionario; lo scrivono anche l'amministratore (ZDBVIEW-LAY-004) e il comando esplicito «Salva impostazioni».

**Test che coprono quest'area.** `Test.zDbView.Storage` (`TTestLayoutIni`, 6 prove) prova la scrittura e la lettura del layout su un `TMemIniFile`: andata e ritorno, colonna nascosta (indice -1, larghezza 100), larghezza limitata a 2000 in lettura, colonna assente (`Found` falso, valori invariati), riscrittura che cancella la sezione precedente, sezione inesistente. `Test.zDbView.Divergenze` (`TTestLayoutCasiLimite`) prova larghezza mancante, indice zero e le divergenze qui sotto. Non coperti: le scritture su disco e sul dizionario, che richiedono griglia e database.

## ZDBVIEW-LAY-001 Scrittura del layout personale
`WriteLayoutToIni` cancella prima l'intera sezione della vista, poi scrive per ogni colonna visibile `NOMECAMPO=indice` e `NOMECAMPO_Width=larghezza`, per ogni colonna nascosta `NOMECAMPO=-1` e `NOMECAMPO_Width=100` (la larghezza di una colonna nascosta si perde). Le colonne tolte dalla vista tra due salvataggi spariscono dal file. `SaveToIni` apre il file con `TMemIniFile` (si legge e si riscrive una volta sola, anche su cartelle di rete) e **ingoia qualunque errore** di scrittura: un file non scrivibile non interrompe il programma.

### Scenario: colonna nascosta
- **Dato** la colonna `NOTE` nascosta e larga 300
- **Quando** si salva il layout
- **Allora** il file contiene `NOTE=-1` e `NOTE_Width=100`

### Scenario: colonna tolta
- **Dato** un layout salvato con tre colonne e uno nuovo con la sola `COGNOME`
- **Quando** si salva il secondo
- **Allora** nella sezione restano solo le chiavi di `COGNOME`

## ZDBVIEW-LAY-002 Lettura e applicazione
`ReadLayoutFromIni` marca `Found` per ogni colonna che ha la sua chiave nella sezione. Per le colonne trovate: visibile se l'indice è diverso da -1, indice e larghezza letti dal file; le colonne non trovate restano invariate. `LoadFromIni` applica alla griglia **solo** le colonne con `Found` vero e presenti in griglia: imposta visibilità, posizione (solo se visibile) e larghezza, dentro `BeginUpdate` e con la griglia in ripristino (`IsRestoring`, per non scatenare i salvataggi). `LayoutPersonaleTrovato` dice se la sezione della vista esisteva: l'utente ha già un suo layout. Se il file non esiste non si fa niente. Anche qui gli errori si ingoiano.

### Scenario: colonna nuova del dizionario
- **Dato** un layout personale salvato prima che il dizionario aggiungesse la colonna `DATA_NASCITA`
- **Quando** la vista si apre
- **Allora** `DATA_NASCITA` resta come l'ha definita il dizionario, e le altre colonne seguono il file

## ZDBVIEW-LAY-003 Larghezze
In lettura la larghezza è limitata a 2000; se manca la chiave `NOMECAMPO_Width` resta la larghezza attuale della colonna. In scrittura la larghezza passa intera, senza limite. Dopo il caricamento, `CheckColumnWidths` (solo se la vista è già mostrata, il dataset è attivo e ci sono colonne) controlla una volta sola se **nessuna** colonna visibile supera 20 di larghezza (il segno di un layout vuoto o non convertito): in quel caso applica l'adattamento al contenuto di tutte le colonne.

`AllargaColonneAlContenuto` (all'apertura, a vista con righe) allarga ogni colonna visibile al contenuto delle prime 200 righe, con un tetto di 400 a 96 DPI (scalato alla risoluzione): la larghezza finale è la maggiore fra quella del layout e quella misurata, mai sotto la prima, e se la misurata supera il tetto vale il maggiore fra layout e tetto. Una colonna allargata a mano resta com'è; una colonna stretta di proposito torna larga quanto il contenuto. Con `Flags.AutoWidth` (colonne adattate alla griglia) non si fa niente. L'adattamento non salva: si ripete a ogni apertura.

### Scenario: larghezza enorme nel file
- **Dato** `COGNOME_Width=2500` nel layout personale
- **Quando** il layout si legge
- **Allora** la larghezza della colonna è 2000

### Scenario: layout vuoto
- **Dato** una vista le cui colonne visibili sono tutte larghe al massimo 20
- **Quando** la vista si apre con dati
- **Allora** viene applicato l'adattamento al contenuto

## ZDBVIEW-LAY-004 Dizionario, layout personale e amministratore
Il salvataggio ha tre forme (`TzDbViewController`): `SaveLayoutToIni` scrive solo il layout personale; `SaveToIni` scrive il layout personale e, **se l'utente è amministratore** (`Base.IsAdmin`), anche il dizionario LZ (`Save(False, True)`, con finestra di attesa); `SaveToLZ` (comando «Salva impostazioni») scrive sempre il dizionario e poi il layout personale. Il salvataggio sul dizionario avviene in un thread a parte e usa le proprietà aggiornate dalla griglia (colonne e flag), con l'eventuale funzione di salvataggio personalizzata (`CustomSaveCallback`) al posto del dizionario. Anche il caricamento (`Load`) usa la funzione personalizzata (`CustomLoadCallback`) se c'è, altrimenti il dizionario.

Dopo la modifica delle proprietà dalla finestra «Personalizza» (`actPersonalizzaExecute`) si ricaricano le proprietà e si riscrive **anche** il layout personale: senza, visibilità e ordine scelti tornerebbero quelli di prima alla riapertura, perché il layout personale ricopre il dizionario. La finestra «Seleziona colonne» salva con `SaveToIni`.

### Scenario: utente normale sposta una colonna
- **Dato** un utente non amministratore
- **Quando** sposta una colonna
- **Allora** cambia solo il suo file `.Columns`; il dizionario non cambia

### Scenario: amministratore sposta una colonna
- **Dato** un utente amministratore
- **Quando** sposta una colonna e il layout si salva con `SaveToIni`
- **Allora** cambiano il suo file `.Columns` e il dizionario LZ, e la nuova disposizione vale per tutti

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LAY-1 🟢 (provata) | Un indice negativo diverso da -1 nel file (per esempio -5) lascia la colonna **visibile** con indice negativo | Un file `.Columns` modificato a mano o corrotto può dare una posizione senza senso; la griglia la limita da sé, ma `Visible` resta vero |
| DIV-LAY-2 🟢 (provata) | La larghezza letta non ha un limite inferiore: 0 o un valore negativo passano alla griglia | Una colonna larga zero non si vede e l'utente non sa perché; si ripara solo cancellando la sezione del file |
| DIV-LAY-3 🟡 (dedotta) | `SaveToIni` scrive anche il dizionario LZ se l'utente è amministratore (`Base.IsAdmin`) e lo fa a ogni salvataggio del layout personale | L'amministratore che riordina le colonne per sé cambia, senza dirlo, la disposizione di tutti gli utenti. Chi ha scritto `SaveLayoutToIni` («solo il layout personale, mai il dizionario») mostra che la separazione serve; resta da decidere se `SaveToIni` debba fare lo stesso |
| DIV-LAY-4 🟢 (dedotta) | `ClearIniSectionAllUsers` ha il corpo tutto commentato: `ClearIniSectionAllUsersExecute` della vista non fa niente | Il comando, se esposto all'utente, sembra riuscire e non cancella nulla |
| DIV-LAY-5 🟢 (dedotta) | La larghezza di una colonna nascosta si scrive sempre 100: riportata visibile con «Seleziona colonne», torna larga 100 invece della larghezza che aveva | Perdita della larghezza personalizzata ogni volta che una colonna si nasconde e si rimostra |
| DIV-LAY-6 🟢 (dedotta) | Gli errori di scrittura e lettura del file `.Columns` si ingoiano senza scrivere nel registro (commento «sul nuovo server softline da problemi») | Un layout che non si salva non lascia nessuna traccia da cui capire perché |
