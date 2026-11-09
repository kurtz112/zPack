---
area: Sanificazione dei testi
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Sanificazione dei testi

Questa specifica descrive come zPack ripulisce il testo digitato o incollato dall'utente dai caratteri invisibili o tipografici che arrivano da mail, PDF, Word ed Excel (spazi unificatori, caratteri di controllo e di formato, simboli dei font, accenti scomposti, virgolette e trattini tipografici, legature) e come normalizza e valida gli indirizzi e-mail. Il codice è in tre unit di `zBase\`: `zSanificazione` (la classe `TzSanificazione`), `zSanificazione.Email` (`TzSanificazioneEmail`) e `zSanificazione.Clipboard` (`TzFiltroClipboard`, il filtro sugli appunti). Chi lo usa: `TzFbDataSet` al salvataggio con il livello sicuro (`Salvataggio e valori predefiniti.md`, ZFIB-SAL-007), gli editor DevExpress di `zDX` con il livello predefinito e la regola e-mail del dizionario dati (`TzDomain.SanificaEmail`), l'azione di pulizia di `zDbCard`, e i `ConfigModule` di WT, Gesty e zTicser, che includono `zSanificazione.Clipboard` e attivano così il filtro sugli appunti.

**Come funziona.** `TzSanificazione.Sanifica` passa il testo carattere per carattere e applica le pulizie scelte con un insieme di opzioni; due insiemi già pronti distinguono le pulizie che non cambiano il significato (applicabili ovunque, anche in automatico) da quelle tipografiche (solo sui campi compilati dall'utente). Il testo che sembra marcatura (RTF, HTML, XML, JSON) non va toccato, e i chiamanti lo controllano con `SembraMarcatura`. Per le e-mail la regola di validità è una sola espressione regolare, la stessa della funzione di database `ZZ_EMAIL_VALIDA`, e la normalizzazione è quella di `ZZ_EMAIL_NORMALIZZA`.

**Test che coprono quest'area.** Nessuna.

## ZBASE-SAN-001 Due livelli di pulizia
`OpzioniSicure` = `osRimuoviControlli`, `osRimuoviFormato`, `osSpaziUnicode`, `osRimuoviUsoPrivato`, `osNormalizzaNFC`: non perdono significato e si possono applicare ovunque. `OpzioniPredefinite` = le sicure più `osPunteggiaturaTipografica`, `osLegature`, `osComprimiSpazi`, `osTrim`. `Sanifica(Testo, Multiriga)` senza opzioni usa le predefinite; `Multiriga` vale falso se non indicato. Il testo vuoto resta vuoto.

### Scenario: livello sicuro
- **Dato** il testo `Mario  “Rossi”` con due spazi
- **Quando** si chiama `Sanifica(Testo, False, TzSanificazione.OpzioniSicure)`
- **Allora** il testo resta identico

### Scenario: livello predefinito
- **Dato** lo stesso testo
- **Quando** si chiama `Sanifica(Testo)`
- **Allora** il risultato è `Mario "Rossi"`

## ZBASE-SAN-002 Ricomposizione degli accenti
Con `osNormalizzaNFC` il testo viene prima portato nella forma canonica composta (NFC) tramite `NormalizeString` di Windows (`Normaliz.dll`), e solo dopo si valutano i singoli caratteri. Se la chiamata a Windows fallisce, il testo prosegue com'era.

### Scenario: accento scomposto
- **Dato** il testo `perche` seguito da U+0301 (accento acuto separato)
- **Quando** si sanifica al livello sicuro
- **Allora** il risultato è `perché` con un solo carattere U+00E9

## ZBASE-SAN-003 Caratteri di controllo e testi su più righe
In un testo `Multiriga` TAB, LF e CR restano sempre. Con `osRimuoviControlli`: TAB, LF, VT, FF e CR che non devono restare diventano uno spazio, così due parole separate da un a capo non si incollano; tutti gli altri controlli (C0, DEL, C1) vengono tolti. Senza `osRimuoviControlli` i controlli restano.

### Scenario: a capo in un campo a riga singola
- **Dato** il testo `Via Roma` + CR LF + `12`
- **Quando** si chiama `Sanifica(Testo, False)`
- **Allora** il risultato è `Via Roma 12`

### Scenario: fine pagina in un testo su più righe
- **Dato** un testo multiriga che contiene FF (U+000C) copiato da un PDF
- **Quando** si sanifica al livello sicuro
- **Allora** FF diventa uno spazio e gli a capo restano

## ZBASE-SAN-004 Caratteri invisibili, spazi, simboli dei font
- `osRimuoviFormato` toglie i caratteri di categoria Unicode «formato»: trattino morbido U+00AD, spazio di larghezza zero U+200B, BOM U+FEFF, segni di direzione del testo.
- `osSpaziUnicode` porta allo spazio normale ogni altro spazio Unicode: U+00A0, U+2000..U+200A, U+202F, U+3000, e anche i separatori di riga e paragrafo U+2028 e U+2029.
- `osRimuoviUsoPrivato` toglie l'area a uso privato U+E000..U+F8FF (pallini e simboli dei font PDF e Wingdings) e il carattere di sostituzione U+FFFD.

### Scenario: spazio unificatore
- **Dato** il testo `00100` preceduto da U+00A0
- **Quando** si sanifica al livello predefinito
- **Allora** il risultato è `00100`

## ZBASE-SAN-005 Punteggiatura tipografica e legature
`EquivalenteTastiera(Carattere)` restituisce la sostituzione da tastiera, o la stringa vuota se il carattere non è tipografico:

| Caratteri | Diventano |
|---|---|
| U+2018, U+2019, U+201A, U+201B, U+2032, U+00B4, U+02BC, U+02BB | `'` |
| U+201C, U+201D, U+201E, U+201F, U+2033, U+00AB, U+00BB | `"` |
| U+2010..U+2015, U+2212, U+FE58, U+FE63, U+FF0D | `-` |
| U+2022, U+2023, U+25E6, U+2043, U+00B7 (punti elenco) | `-` |
| U+2026 | `...` |
| U+2044, U+2215 | `/` |
| U+FB00 `ff`, U+FB01 `fi`, U+FB02 `fl`, U+FB03 `ffi`, U+FB04 `ffl`, U+FB05 e U+FB06 `st` | lettere separate |

Con `osPunteggiaturaTipografica` si sostituiscono le righe della tabella tranne le legature; con `osLegature` solo le legature. Le due opzioni sono indipendenti.

### Scenario: legatura da PDF
- **Dato** il testo `uf` + U+FB01 + `cio`
- **Quando** si sanifica al livello predefinito
- **Allora** il risultato è `ufficio`

## ZBASE-SAN-006 Spazi ripetuti e bordi
Con `osComprimiSpazi` più spazi consecutivi (anche nati dalle sostituzioni precedenti) diventano uno, e lo spazio che precede un a capo viene tolto. Con `osTrim` si tolgono ai bordi spazi, TAB, CR e LF, quindi in un testo su più righe anche le righe vuote iniziali e finali.

### Scenario: spazi a fine riga
- **Dato** il testo multiriga `Riga uno   ` + CR LF + `Riga due` + CR LF
- **Quando** si chiama `Sanifica(Testo, True)`
- **Allora** il risultato è `Riga uno` + CR LF + `Riga due`

## ZBASE-SAN-007 Rilevare senza modificare
`ContieneAnomalie(Testo, Multiriga, Opzioni)` è vero quando `Sanifica` con le stesse opzioni cambierebbe il testo (senza opzioni usa le predefinite). `Analizza` restituisce l'elenco dei caratteri sospetti con posizione (da 1, in unità UTF-16 come `Pos`), codice e descrizione nella forma `Spazio unificatore (U+00A0)`; le descrizioni sono `Carattere di controllo`, `Carattere di formato invisibile`, `Spazio unificatore`, `Spazio non standard`, `Simbolo di font (uso privato)`, `Carattere di sostituzione`, `Accento scomposto`, `Legatura tipografica`, `Punteggiatura tipografica`. `DescriviAnomalie` le raggruppa con il conteggio (`Spazio unificatore x2, Carattere di controllo x1`) e restituisce la stringa vuota se non ce ne sono. `Analizza` non dipende dalle opzioni e non considera gli spazi ripetuti o ai bordi (DIV-SAN-1).

### Scenario: riepilogo per l'utente
- **Dato** un testo con due U+00A0 seguiti, più avanti, da un U+0007 (i gruppi escono nell'ordine in cui compaiono)
- **Quando** si chiama `DescriviAnomalie`
- **Allora** il risultato è `Spazio unificatore x2, Carattere di controllo x1`

## ZBASE-SAN-008 Testo da non toccare
`SembraMarcatura` è vero se il testo, tolti gli spazi iniziali, comincia con `{\rtf`, `<?xml`, `<!DOCTYPE`, `<html` (questi tre senza distinzione di maiuscole), `{"`, `[{`, `[]` o `{}`. Solo i primi 64 caratteri contano. I chiamanti (dataset, editor, filtro sugli appunti) non sanificano un testo per cui è vero.

### Scenario: documento RTF
- **Dato** un testo che comincia con `{\rtf1\ansi`
- **Quando** si chiama `SembraMarcatura`
- **Allora** il risultato è vero

## ZBASE-SAN-009 Normalizzazione degli indirizzi e-mail
`TzSanificazioneEmail.Normalizza` è conservativa e idempotente: toglie controlli e caratteri di formato invisibili, porta ogni spazio Unicode allo spazio normale, toglie gli spazi ai bordi e il prefisso `mailto:` (senza distinzione di maiuscole), dalla forma `Nome Cognome <indirizzo>` tiene ciò che sta fra le **ultime** parentesi angolari, toglie virgolette, apostrofi e parentesi angolari ai bordi e i `.`, `,`, `;` finali, e porta tutto in minuscolo. Non corregge spazi interni, virgole al posto del punto, `@` mancante o doppia: sono anomalie da segnalare. Restituisce la stringa vuota per un testo vuoto o di soli spazi.

### Scenario: indirizzo copiato da un programma di posta
- **Dato** il testo `"Mario Rossi" <Mario.Rossi@Esempio.IT>;`
- **Quando** si chiama `Normalizza`
- **Allora** il risultato è `mario.rossi@esempio.it`

## ZBASE-SAN-010 Validità di un indirizzo e-mail
`Valido(Indirizzo, RichiediPuntoNelDominio)` applica l'espressione regolare `RegexEmail` (tradotta da JavaScript a PCRE: `\uXXXX` → `\x{XXXX}`, `$` → `\z`) all'indirizzo così com'è, senza normalizzarlo. Con `RichiediPuntoNelDominio` vero rifiuta anche un dominio senza punto come `nome@localhost`, che l'espressione accetterebbe; è consigliato per PEC e invii reali. La stringa vuota non è valida.

### Scenario: dominio senza punto
- **Dato** l'indirizzo `nome@localhost`
- **Quando** si chiama `Valido(Indirizzo, True)`
- **Allora** il risultato è falso, mentre con `False` è vero

## ZBASE-SAN-011 Esito con il motivo dello scarto
`Sanifica(Indirizzo, RichiediPuntoNelDominio)` restituisce originale, normalizzato ed esito: `eeVuota` se il normalizzato è vuoto, `eeValida` se è valido, altrimenti `eeNonValida` con il primo motivo che si applica, in quest'ordine: `Manca il carattere @`, `Contiene piu' di un carattere @`, `Contiene spazi`, `Contiene separatori , o ; (un solo indirizzo per campo)`, `Il dominio non contiene un punto` (solo se richiesto), `Formato non conforme`.

### Scenario: due indirizzi nello stesso campo
- **Dato** il testo `a@b.it, c@d.it`
- **Quando** si chiama `TzSanificazioneEmail.Sanifica`
- **Allora** l'esito è `eeNonValida` con `Contiene piu' di un carattere @`

## ZBASE-SAN-012 Elenchi di indirizzi
`EstraiIndirizzi` divide il testo su `;` e `,`, normalizza ogni parte e scarta quelle vuote. `SanificaElenco` restituisce gli indirizzi validi uniti da `; ` e mette in `NonValidi` quelli scartati, già normalizzati, per mostrarli all'utente.

### Scenario: elenco misto
- **Dato** il testo `a@b.it; ; x@y`
- **Quando** si chiama `SanificaElenco(Testo, NonValidi, True)`
- **Allora** il risultato è `a@b.it` e `NonValidi` contiene `x@y`

## ZBASE-SAN-013 Filtro sugli appunti
Includere `zSanificazione.Clipboard` attiva il filtro (`FiltroClipboard.Attivo` vero, opzioni predefinite); l'applicazione può spegnerlo o scegliere `OpzioniSicure`. Quando l'utente preme **Ctrl+V** o **Maiusc+Ins** (senza Alt) e il controllo attivo è un editor di testo nativo (`TCustomEdit`, che comprende gli editor interni di DevExpress e l'editor in linea delle griglie), non di sola lettura e non una casella password, il testo degli appunti viene ripulito **prima** che il tasto arrivi al controllo, considerando su più righe il controllo con lo stile `ES_MULTILINE`. Il tasto prosegue sempre e incolla. Gli appunti non si toccano se: non contengono testo Unicode, sono occupati da un altro programma, il testo è vuoto o sembra marcatura, la pulizia non cambierebbe nulla, o il testo è identico all'ultimo che il filtro ha già ripulito (DIV-SAN-2). Quando li riscrive, gli appunti contengono solo il testo ripulito, senza le versioni formattate che c'erano prima. Il comando «Incolla» del menu contestuale non passa dal filtro: lo coprono la pulizia degli editor `zDX` e quella del dataset. `RipulisciClipboard(Multiriga)` si può chiamare anche a mano e restituisce vero se ha cambiato gli appunti.

### Scenario: incolla da PDF in un campo di testo
- **Dato** negli appunti `Codice` + U+00A0 + `fiscale` copiato da un PDF
- **Quando** l'utente preme Ctrl+V in un `TcxTextEdit` modificabile
- **Allora** il campo riceve `Codice fiscale`

### Scenario: casella password
- **Dato** lo stesso testo negli appunti
- **Quando** l'utente preme Ctrl+V in una casella con stile `ES_PASSWORD`
- **Allora** gli appunti non vengono modificati

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-SAN-1 🟢 (dedotta) | `Analizza` e `DescriviAnomalie` non seguono le opzioni di `Sanifica`: non segnalano spazi ripetuti o ai bordi (che le predefinite tolgono), segnalano `Accento scomposto` anche per gli accenti che la NFC non ricompone (e che restano), e segnalano la punteggiatura tipografica anche quando le opzioni sono le sicure | Il registro di `TzFbDataSet` (livello sicuro) dice di aver tolto virgolette tipografiche che sono rimaste; per `a  b` `ContieneAnomalie` è vero ma `DescriviAnomalie` è vuoto, e l'utente non sa che cosa verrebbe cambiato |
| DIV-SAN-2 🟢 (dedotta) | Il filtro sugli appunti salta il testo identico all'ultimo ripulito, senza ricordare se era stato ripulito per un campo su più righe | Un testo incollato prima in una nota (a capo conservati) e poi in un campo a riga singola arriva con gli a capo; li toglie poi, se attiva, la pulizia dell'editor o del dataset |
| DIV-SAN-3 🟢 (dedotta) | `SembraMarcatura` riconosce l'HTML solo da `<html` o `<!DOCTYPE` | Un frammento HTML che comincia con `<p>` o `<div>` viene trattato come testo: al livello predefinito le virgolette tipografiche dentro gli attributi o il testo vengono cambiate |
| DIV-SAN-4 🟢 | `EstraiIndirizzi` divide anche sulla virgola dentro un nome visualizzato: `"Rossi, Mario" <m@x.it>` diventa due parti | La prima parte (`rossi`) finisce fra i non validi e l'utente vede un errore su un indirizzo che è corretto |
