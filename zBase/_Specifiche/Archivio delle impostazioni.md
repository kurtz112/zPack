---
area: Archivio delle impostazioni
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/001
---

# Archivio delle impostazioni

Questa specifica descrive come un programma ricorda **posizione, dimensione e stato di una finestra** e le **dimensioni dei pannelli separati da un divisore** (`TcxSplitter`), e come le ritrova alla riapertura. Il codice è in `zBase\zStorage.pas` (classe `TzStorage`, con quattro funzioni pubbliche di classe: `ProfiloDiSchermo`, `NomeSezione`, `SaveControlToIni`, `LoadControlFromIni`); le regole di posizione stanno in funzioni della sezione di implementazione. Lo usano `TBaseForm` (alla creazione e alla distruzione della form) e `TBaseFrame` di WT, Gesty e zTicser; il file è quello che restituisce `Config.StorageFileName` (ricavato da `zSystem.ConfigFileName('.Forms')`), vuoto se la sua cartella non esiste. Altro dalle impostazioni **dell'utente** e **dell'installazione** salvate nel database (`Impostazioni e cartelle.md`) e dal layout delle colonne di una vista (`Layout colonne della vista.md`). `zBaseLib.pas` ha una coppia più vecchia `SaveFormPosition` / `LoadFormPosition` con lo stesso scopo e un'altra logica: non fa parte di questa specifica. La unit è compilata da WT, Gesty e zTicser; ShareFood, WinSinfo e `__tmp\BaseWebDesigner` hanno una propria copia, più vecchia (DIV-STO-6).

**Come funziona.** Ogni form (o frame) ha nel file una sezione per ogni **profilo di schermo**, per esempio `TWizInserimentoIncaricoForm@4M-7680x1440-96` in ufficio e `TWizInserimentoIncaricoForm@1M-1440x960-96-RDP` da casa: così chi lavora su disposizioni diverse (più monitor, portatile, desktop remoto) non si sovrascrive la disposizione dell'altro posto. Alla chiusura `SaveControlToIni` scrive la sezione del profilo corrente; all'apertura `LoadControlFromIni` la rilegge e, per la form, decide con regole di sicurezza dove metterla perché non finisca fuori dallo schermo.

**Test che coprono quest'area.** `Test.zStorage` (bozza di questo rilascio) prova, su un pannello e su una `TForm` senza finestra visibile e un file temporaneo: il nome del profilo e della sezione, ciò che si scrive e quando non si scrive niente, lo scarto delle sezioni senza PPI, il ritorno alla misura al PPI attuale, il ripiego sulla sezione del formato vecchio, la riapertura di una form dentro lo schermo, ridotta a icona, fuori dallo schermo o più grande del monitor, e lo stato massimizzato o ridotto a icona. Restano senza prova, perché servono finestre vere: i divisori (`TcxSplitter`), il controllo di `IsIconic` e la scelta del monitor della finestra principale.

## ZBASE-STO-001 Profilo di schermo e nome della sezione
`ProfiloDiSchermo` compone `<n>M-<larghezza>x<altezza>-<PPI>` con il numero dei monitor, la misura del desktop virtuale e i pixel per pollice del **monitor principale**, più il suffisso `-RDP` se la sessione è remota. `NomeSezione(controllo)` è `<Nome del controllo>@<profilo>`; è la stringa vuota se il controllo è `nil` o non ha nome: senza nome non si salva e non si legge niente.

### Scenario: formato
- **Dato** un computer con due monitor, desktop 3840x1080 e 96 PPI in locale
- **Quando** si chiede `ProfiloDiSchermo`
- **Allora** il risultato è `2M-3840x1080-96`

### Scenario: sessione remota
- **Dato** una sessione di desktop remoto
- **Quando** si chiede `ProfiloDiSchermo`
- **Allora** il risultato termina con `-RDP`

### Scenario: controllo senza nome
- **Dato** un controllo con `Name` vuoto
- **Quando** si chiede `NomeSezione`
- **Allora** il risultato è la stringa vuota

## ZBASE-STO-002 Che cosa si salva e quando
`SaveControlToIni(file, controllo)` non fa niente se il nome del file è vuoto, il controllo è `nil` o il nome della sezione è vuoto, e in questi casi **non crea il file**. Altrimenti scrive nella sola sezione del profilo corrente: `PPI` (il PPI del controllo; se non è positivo, 96), `State` (solo per le form, valore di `WindowState`) e, se la form è in stato normale e non ridotta a icona (nessuna coordinata inferiore a -30000), `Top`, `Left`, `Height`, `Width`. Per ogni divisore trovato in un contenitore salva la dimensione del controllo che comanda (ZBASE-STO-006). **Una form massimizzata o ridotta a icona non riscrive i limiti**: restano quelli dell'ultima chiusura in stato normale. La sezione senza profilo del formato vecchio (`<Nome>`) **non si tocca più**. Se la sezione del profilo esiste ma non ha `PPI` (le scriveva il rilascio 005, con pixel di PPI ignoto, Mantis #310) viene **cancellata** prima di scrivere, perché le chiavi che questa chiusura non riscrive sarebbero lette alla scala sbagliata. Una sezione che ha già il `PPI` conserva le chiavi che non riguardano la finestra.

### Scenario: pannello
- **Dato** un pannello `PannelloProva` con limiti 10, 20, 300 per 200
- **Quando** si salva
- **Allora** la sezione `PannelloProva@<profilo>` contiene `Left=10`, `Top=20`, `Width=300`, `Height=200` e `PPI`
- **E** non esiste la sezione `PannelloProva`

### Scenario: form massimizzata
- **Dato** una form con `WindowState = wsMaximized`
- **Quando** si salva
- **Allora** la sezione ha `State=2` e nessuna chiave `Left`

### Scenario: sezione senza PPI
- **Dato** una sezione di profilo con la sola chiave `Residuo=1`
- **Quando** si salva il controllo
- **Allora** `Residuo` non c'è più e `PPI` è presente

### Scenario: controllo senza nome
- **Dato** un controllo senza nome e un nome di file valido
- **Quando** si salva
- **Allora** il file non esiste

## ZBASE-STO-003 Lettura: quale sezione e a quale scala
`LoadControlFromIni(file, controllo, MaxWidth, MaxHeight)` non fa niente (e non crea il file) se il nome del file è vuoto, il controllo è `nil` o senza nome. La **sezione del profilo** è utilizzabile solo se dichiara un `PPI` positivo; una sezione di profilo senza `PPI` si scarta. Se il profilo non è utilizzabile e manca anche la sezione `<Nome>` del formato vecchio, non si cambia niente. Per ogni valore si cerca prima nella sezione del profilo, se utilizzabile, poi nella sezione del formato vecchio. **Posizione** (`Left`, `Top`) e **stato** sono presi così come sono; **misure** (`Width`, `Height`, dimensioni dei divisori) si riportano al PPI attuale con `valore · PPI attuale / PPI salvato`, dove il PPI salvato è quello della sezione da cui viene il valore, 96 se la sezione non lo dichiara (la sezione del formato vecchio non lo dichiara mai). Se un valore manca ovunque resta quello che il controllo ha prima della lettura. Per una form la posizione è poi decisa da ZBASE-STO-004; per ogni altro controllo (un frame) i limiti letti si applicano con `SetBounds`, senza controlli. In una form `Position` diventa `poDesigned`.

### Scenario: formato vecchio
- **Dato** una sezione `PannelloProva` con `Left=15`, `Top=25`, `Width=300`, `Height=200` e nessuna sezione di profilo
- **Quando** si legge, con PPI attuale 96
- **Allora** il pannello ha limiti 15, 25, 300 per 200

### Scenario: altro PPI
- **Dato** una sezione di profilo con `PPI=192` e `Width=600`, e PPI attuale 96
- **Quando** si legge
- **Allora** la larghezza è 300 (la posizione non cambia di scala)

### Scenario: profilo senza PPI e nessun formato vecchio
- **Dato** una sezione di profilo con `Left=99` e senza `PPI`
- **Quando** si legge
- **Allora** il controllo conserva i limiti che aveva

### Scenario: profilo parziale
- **Dato** una sezione di profilo con il solo `PPI`, e una sezione `<Nome>` con `Width=300`
- **Quando** si legge, con PPI attuale 96
- **Allora** la larghezza viene dalla sezione vecchia, al PPI 96

## ZBASE-STO-004 Dove riapre una form
Prima di applicare i limiti letti a una form, `PosizioneDiRiapertura` li verifica:
1. se la **larghezza è sotto 200 pixel o l'altezza sotto 150** il limite non è credibile (una finestra ridotta a icona si salvava come -32000, -32000, circa 160 per 28): **larghezza e altezza** tornano a quelle di progetto, cioè quelle che la form aveva prima della lettura;
2. se `Left` e `Top` sono sopra -30000 e la **barra del titolo** (30 pixel sotto il bordo superiore) è visibile per almeno 100 pixel di larghezza su un monitor, la form resta dove era; se è più grande dell'area utile del monitor più vicino si **restringe** a quella e si sposta dentro;
3. altrimenti (monitor scollegato, desktop remoto) la form si **centra** nell'area utile del monitor della finestra principale (il principale se questa non esiste o non ha finestra), con la sua misura, ridotta all'area utile se più grande.

### Scenario: dentro lo schermo
- **Dato** limiti salvati dentro l'area utile del monitor principale, 500 per 400
- **Quando** si riapre la form
- **Allora** la form ha esattamente quei limiti

### Scenario: ridotta a icona
- **Dato** limiti salvati -32000, -32000, 160 per 28
- **Quando** si riapre la form (misura di progetto 400 per 300)
- **Allora** la form è 400 per 300, centrata nell'area utile del monitor principale

### Scenario: fuori dallo schermo
- **Dato** una `Left` oltre il bordo destro del desktop virtuale
- **Quando** si riapre la form
- **Allora** la form è centrata e interamente nell'area utile

### Scenario: più grande del monitor
- **Dato** una larghezza e un'altezza maggiori dell'area utile, con la barra del titolo visibile
- **Quando** si riapre la form
- **Allora** la form non esce dall'area utile del suo monitor

## ZBASE-STO-005 Stato della finestra
Per una form lo stato viene dalla chiave `State` del profilo (se c'è) o della sezione vecchia; se `State` manca ovunque, nella sezione vecchia `ShowCmd=3` vale massimizzata (compatibilità con un formato che nessuno scrive più). **Solo la massimizzazione si ripristina**: ogni altro valore, compreso lo stato ridotto a icona, riapre la form in stato normale.

### Scenario: massimizzata
- **Dato** `State=2` nella sezione del profilo
- **Quando** si riapre la form
- **Allora** `WindowState = wsMaximized`

### Scenario: ridotta a icona
- **Dato** `State=1`
- **Quando** si riapre la form
- **Allora** `WindowState = wsNormal`

### Scenario: formato vecchio
- **Dato** una sezione `<Nome>` con `ShowCmd=3` e senza `State`
- **Quando** si riapre la form
- **Allora** `WindowState = wsMaximized`

## ZBASE-STO-006 Dimensione dei pannelli separati da un divisore
Per ogni `TcxSplitter` si individua il controllo comandato: la proprietà `Control` del divisore se assegnata; altrimenti il primo controllo visibile e abilitato, non `alClient`, il cui rettangolo (allargato di 1 pixel se è alto o largo zero e dei margini se `AlignWithMargins`) contiene il punto adiacente al divisore. Si salva `<Nome controllo>_Height` (controllo `alTop` o `alBottom`) o `<Nome controllo>_Width` (`alLeft` o `alRight`); un controllo `alClient`, `alNone` o `alCustom` non si salva. La lettura applica il valore con un **minimo di 100 pixel** e un massimo pari al minore fra `MaxWidth` (`MaxHeight`) e la larghezza (altezza) interna di ogni contenitore antenato, meno 100, **ma il minimo vince** se i due si contraddicono. L'attraversamento entra in tutti i contenitori figli, frame compresi.

### Scenario: limiti di lettura
- **Dato** un pannello a sinistra di un divisore, `_Width` salvata 5000 e un massimo di 1000
- **Quando** si legge
- **Allora** la larghezza del pannello è 900

## ZBASE-STO-007 Chi lo chiama e con quali limiti
`TBaseForm.LoadFromIni` passa `ClientWidth` e `ClientHeight` della form, meno l'altezza del controllo della barra del titolo se è visibile; `TBaseFrame.LoadFromIni` passa `Width` e `Height` del frame. `TBaseForm` legge alla creazione della form solo se il tasto Ctrl **non** è premuto (è il modo di ignorare il file) e, per una form modale, legge anche subito prima di mostrarla, senza quel controllo; salva nel distruttore. Il file è sempre quello di `Config.StorageFileName`: se la cartella delle impostazioni non esiste il nome è vuoto e non si legge né si scrive niente.

### Scenario: Ctrl premuto
- **Dato** Ctrl premuto all'apertura di una form non modale
- **Quando** la form si crea
- **Allora** non si legge il file e la form si apre con la disposizione di progetto

## Divergenze note

Si decidono nella voce R-213 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-STO-1 🟡 (dedotta) | `TBaseForm.LoadFromIni` calcola `MaxWidth` e `MaxHeight` dal `ClientWidth` e `ClientHeight` che la form ha **prima** di `LoadControlFromIni`, che poi la ridimensiona con i limiti salvati; `TBaseFrame` passa la misura attuale del frame, anche questa di progetto | Il tetto dei divisori è la misura di progetto meno 100 pixel, non quella della form riaperta: su una form riaperta più grande, un pannello salvato più largo di quel tetto torna più stretto |
| DIV-STO-2 🟢 (dedotta) | Con una sola delle due misure sotto il minimo (200 per la larghezza, 150 per l'altezza) tornano a quelle di progetto **entrambe** | Una form stretta per scelta (per esempio 180 per 600) si riapre sempre alla misura di progetto |
| DIV-STO-3 🟢 (dedotta) | `SaveControls` e `LoadControls` attraversano anche i frame figli e scrivono le dimensioni dei loro divisori nella sezione del contenitore con la sola chiave `<Nome controllo>_<Width/Height>`; il frame, se salva a sua volta con `TBaseFrame.SaveToIni`, le scrive anche nella propria sezione | Due frame della stessa classe nella stessa form hanno controlli con gli stessi nomi: le chiavi coincidono, l'ultimo che scrive vince e al ritorno ricevono tutti la stessa misura; la stessa dimensione può inoltre stare in due sezioni |
| DIV-STO-4 🟢 (dedotta) | Senza la proprietà `Control`, `FindSplittedControl` scarta i controlli non visibili o non abilitati | Un pannello nascosto o disabilitato al momento del salvataggio (o del caricamento) non ha la sua dimensione né salvata né ripristinata, e il risultato dipende da ciò che era visibile in quell'istante |
| DIV-STO-5 🟢 | Il ramo `ShowCmd=3` legge un formato che nessuno scrive più, e la riga di commento che lo introduce contiene un carattere accentato in codifica Windows-1252: il file non è in UTF-8 | Codice di compatibilità probabilmente morto; un editor UTF-8 mostra un carattere di sostituzione nel commento e rifiuta di modificare il file senza conversione |
| DIV-STO-6 🟢 | `zStorage.pas` esiste in copie più vecchie e diverse in `Sharefood\Sorgenti\BASE` (382 righe), `WinSinfo\BASE` (331) e `__tmp\BaseWebDesigner\BASE` (362), tutte senza profili di schermo | Un progetto che usa la copia locale ha ancora il comportamento senza profilo: stesso file di impostazioni, disposizione condivisa fra posti di lavoro diversi |
