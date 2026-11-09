---
area: Codice fiscale
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Codice fiscale

Questa specifica descrive le funzioni di `zBase\zCodiceFiscale.pas` che calcolano e controllano il codice fiscale delle persone fisiche, ne estraggono data di nascita, sesso e comune, e controllano la partita IVA e la sigla dello stato estero. Sono funzioni libere, senza dipendenze da interfaccia o database. Chi le usa: in WT `dmIntestatari`, `dmRichieste`, `dmTools`, `wizIntestatario_DM`; in Gesty `dmCommon`, `dmDataSetEvents`, `dmEventHandler`, `dmAssistenzaScolastica`, `WizNuovaAziendaOspitanteDM`, `WizNuovaRichiestaAttivazioneDM`. I chiamanti combinano spesso `CodiceFiscaleValido` e `PartitaIvaValida`: un codice che non è un codice fiscale di persona fisica viene riprovato come partita IVA (WT usa proprio `CodiceFiscaleValido` falso per riconoscere le partite IVA).

**Come funziona.** Il codice fiscale ha 16 caratteri: tre per il cognome, tre per il nome, due per l'anno, una lettera per il mese, due cifre per il giorno (più 40 per le donne), quattro per il comune (codice catastale, o «Belfiore») e un carattere di controllo calcolato sui primi 15. Nei codici omocodici l'Agenzia delle Entrate sostituisce alcune cifre con lettere; per leggere data, sesso e comune le lettere vanno riportate alle cifre, mentre il carattere di controllo resta quello calcolato sul codice con le lettere.

**Test che coprono quest'area.** `Test.zCodiceFiscale` (in `zPack\_UnitTest\_src`, 37 prove in quattro gruppi). `TTestCodiceFiscale` prova il calcolo su esempi noti (Mario Rossi `RSSMRA80A01H501U`) e i ritorni calcola → valida → estrai per data, sesso e comune. `TTestCodiceFiscaleCasiLimite` prova dati mancanti, nomi corti, apostrofi, la regola del nome con quattro consonanti, il secolo dei nati nel 2010 e nell'anno in corso, una data al posto del codice, il codice estero, la lunghezza e i codici omocodici (difetti corretti il 2026-10-03, voce R-032). `TTestPartitaIva` prova il controllo, il prefisso `IT`, le lettere, il prefisso UE senza controllo; `TTestStatoEstero` prova vuoto, `ITA` e altre sigle.

## ZBASE-CF-001 Validità del codice fiscale
`CodiceFiscaleValido(Codice, Estero)` è falso per la stringa vuota. Con `Estero` vero è vero per qualunque testo non vuoto. Altrimenti è vero solo se il testo ha **esattamente 16 caratteri** e l'ultimo coincide (senza distinzione di maiuscole) con il carattere di controllo calcolato sui primi 15. Un codice numerico di 11 cifre (enti, società) non è un codice fiscale valido per questa funzione: va controllato con `PartitaIvaValida`. La funzione non controlla la struttura (lettere e cifre al posto giusto) né la data (DIV-CF-2).

### Scenario: codice noto
- **Dato** il codice `RSSMRA80A01H501U`
- **Quando** si chiama `CodiceFiscaleValido`
- **Allora** il risultato è vero

### Scenario: carattere in più
- **Dato** il codice `RSSMRA80A01H501U` seguito da `O`, dove `O` sarebbe il controllo coerente dei 16 caratteri precedenti
- **Quando** si chiama `CodiceFiscaleValido`
- **Allora** il risultato è falso, perché la lunghezza non è 16

### Scenario: data al posto del codice
- **Dato** il testo `01/02/2008`
- **Quando** si chiama `CodiceFiscaleValido`
- **Allora** il risultato è falso

## ZBASE-CF-002 Carattere di controllo
Il carattere di controllo si calcola sommando, per ognuno dei 15 caratteri, il valore della tabella delle posizioni dispari (1ª, 3ª, ...) o di quella delle posizioni pari, prendendo il resto della divisione per 26 e convertendolo in lettera (`0` = `A` ... `25` = `Z`). Le tabelle sono quelle ufficiali e riguardano cifre e lettere **maiuscole**: un carattere diverso vale -1 (DIV-CF-1).

### Scenario: controllo alterato
- **Dato** il codice `RSSMRA80A01H501U` con l'ultima lettera cambiata
- **Quando** si chiama `CodiceFiscaleValido`
- **Allora** il risultato è falso

## ZBASE-CF-003 Codici omocodici
Un codice omocodico è valido se il carattere di controllo corrisponde ai 15 caratteri con le lettere. Prima di estrarre data, sesso e comune, nelle sole posizioni numeriche (anno 7-8, giorno 10-11, comune 13-15) le lettere `L M N P Q R S T U V` tornano a essere le cifre da 0 a 9.

### Scenario: anno in lettere
- **Dato** il codice omocodico `RSSMRA8LA01H501F`
- **Quando** si chiama `EstraiDataNascitaDaCodiceFiscale`
- **Allora** il risultato è il 01/01/1980

### Scenario: comune in lettere
- **Dato** il codice omocodico `RSSMRA80A01H50MM`
- **Quando** si chiama `EstraiBelfioreNascitaDaCodiceFiscale`
- **Allora** il risultato è `H501`

## ZBASE-CF-004 Calcolo del codice fiscale
`CalcolaCodiceFiscale(Cognome, Nome, Sesso, DataNascita, CodiceComune)` restituisce la stringa vuota se cognome, nome o sesso sono vuoti. Di cognome e nome contano solo le lettere `A`-`Z` dopo il passaggio in maiuscolo: spazi, apostrofi e lettere accentate vengono scartati (DIV-CF-3). Il cognome dà le prime tre fra consonanti, poi vocali, poi `X`. Il nome, se ha **quattro o più consonanti**, dà la prima, la terza e la quarta; altrimenti segue la regola del cognome. Seguono l'anno a due cifre, la lettera del mese (`A B C D E H L M P R S T`), il giorno a due cifre, più 40 se `Sesso` è `F` (senza distinzione di maiuscole: ogni altro valore vale maschio), il codice del comune così come viene passato e il carattere di controllo. Se il risultato non supera `CodiceFiscaleValido` (per esempio un codice del comune che non ha 4 caratteri) la funzione restituisce la stringa vuota.

### Scenario: esempio noto
- **Dato** `Rossi`, `Mario`, `M`, 01/01/1980, `H501`
- **Quando** si chiama `CalcolaCodiceFiscale`
- **Allora** il risultato è `RSSMRA80A01H501U`

### Scenario: nome con quattro consonanti
- **Dato** il nome `Gianfranco` (consonanti G N F R N C)
- **Quando** si calcola il codice di `Rossi Gianfranco`, maschio, nato a Roma il 01/01/1980
- **Allora** il risultato è `RSSGFR80A01H501K`

### Scenario: nome e cognome corti
- **Dato** il cognome `Fo` e il nome `Al`
- **Quando** si calcola il codice
- **Allora** i primi sei caratteri sono `FOXLAX`

### Scenario: apostrofo nel cognome
- **Dato** il cognome `D'Angelo`
- **Quando** si calcola il codice
- **Allora** i primi tre caratteri sono `DNG`

## ZBASE-CF-005 Data di nascita
`EstraiDataNascitaDaCodiceFiscale` restituisce 0 se il codice non è valido o se anno, mese o giorno non sono leggibili o non formano una data. Il giorno oltre 40 viene ridotto di 40. Il secolo si decide con la data di oggi: l'anno a due cifre è nel Novecento, salvo che la persona risulterebbe avere almeno 90 anni **e** l'anno corrispondente del Duemila non sia nel futuro: in quel caso è nel Duemila (stessa regola di `ZZ_CODICE_FISCALE_ESTRAI_DATI` di Gesty). Chi è nato nell'anno in corso viene quindi datato correttamente, e chi ha esattamente cento anni viene datato al Duemila.

### Scenario: nato nel 2010
- **Dato** il codice calcolato per un nato il 05/05/2010
- **Quando** si estrae la data di nascita
- **Allora** il risultato è il 05/05/2010 e non il 1910

### Scenario: nato nell'anno in corso
- **Dato** il codice calcolato per un nato il 1° gennaio dell'anno in corso
- **Quando** si estrae la data di nascita
- **Allora** il risultato è il 1° gennaio dell'anno in corso

## ZBASE-CF-006 Sesso e comune di nascita
`EstraiSessoDaCodiceFiscale` restituisce `F` se la cifra delle decine del giorno (dopo la normalizzazione dell'omocodia) è 4 o più, altrimenti `M`; restituisce la stringa vuota per un codice non valido. `EstraiBelfioreNascitaDaCodiceFiscale` restituisce i caratteri 12-15 normalizzati, o la stringa vuota per un codice non valido.

### Scenario: decina del giorno in lettere
- **Dato** il codice omocodico `RSSMRA80AL1H501F`
- **Quando** si estrae il sesso
- **Allora** il risultato è `M`

## ZBASE-CF-007 Validità della partita IVA
`PartitaIvaValida(PartitaIva, Estero)` è vera con `Estero` vero, qualunque sia il testo. Se il testo comincia con il prefisso di un paese dell'Unione diverso da `IT` (ZBASE-CF-008) è vera **senza altri controlli**. Altrimenti si tolgono le occorrenze di `IT` maiuscolo e gli spazi ai bordi, e la partita IVA è valida solo se restano 11 cifre il cui ultimo carattere è il controllo: somma delle cifre in posizione dispari (1ª, 3ª, ... 9ª) più, per quelle in posizione pari, il doppio della cifra (meno 9 se supera 9); il controllo è `(10 - somma mod 10) mod 10`.

### Scenario: prefisso italiano
- **Dato** il testo `IT01234567897`
- **Quando** si chiama `PartitaIvaValida`
- **Allora** il risultato è vero, mentre per `IT01234567890` è falso

### Scenario: prefisso di un altro paese
- **Dato** il testo `DE1`
- **Quando** si chiama `PartitaIvaValida`
- **Allora** il risultato è vero (DIV-CF-4)

## ZBASE-CF-008 Partita IVA estera
`PartitaIvaEstera` è vera se i primi due caratteri, portati in maiuscolo, sono uno dei prefissi `AT BE BG HR CZ CY DK EE FI FR DE EL HU IE LV LT LU MT NL PL PT RO SK SI ES SE GB`; è falsa per `IT` (anche minuscolo) e per una partita IVA numerica.

### Scenario: partita IVA tedesca
- **Dato** il testo `DE123456789`
- **Quando** si chiama `PartitaIvaEstera`
- **Allora** il risultato è vero

## ZBASE-CF-009 Stato estero
`StatoEstero(Sigla)` è falso per una sigla vuota o di soli spazi e per `ITA` (senza distinzione di maiuscole e senza spazi ai bordi); è vero per ogni altra sigla. La sigla italiana attesa è quella a tre lettere: `IT` risulta estero.

### Scenario: sigla in minuscolo con spazi
- **Dato** la sigla ` ita `
- **Quando** si chiama `StatoEstero`
- **Allora** il risultato è falso

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-CF-1 🟡 (dedotta) | Le tabelle del carattere di controllo conoscono solo le lettere maiuscole: un codice scritto in minuscolo dà un controllo sbagliato, e il confronto senza distinzione di maiuscole riguarda solo l'ultimo carattere | `rssmra80a01h501u` non è valido, e le funzioni di estrazione restituiscono 0 o la stringa vuota: un campo che non porta il testo in maiuscolo prima del controllo rifiuta codici giusti |
| DIV-CF-2 🟢 (dedotta) | Nessun controllo di struttura: ogni carattere sconosciuto vale -1 e una qualunque sequenza di 15 caratteri seguita dal controllo giusto è valida (per esempio quindici `A` con il loro controllo, o un mese o un giorno impossibili) | Codici formalmente sbagliati passano la validazione; l'estrazione della data restituisce poi 0 |
| DIV-CF-3 🟢 (dedotta) | Nel calcolo le lettere accentate vengono scartate invece di valere come la vocale senza accento | Per nomi o cognomi con meno di tre consonanti il codice calcolato è sbagliato: `Zoè` dà `ZOX` invece di `ZOE` |
| DIV-CF-4 🟡 | Una partita IVA con un prefisso dell'Unione è valida senza alcun controllo di lunghezza o formato (`DE1` è valida; la prova lo fotografa come comportamento attuale); l'elenco contiene ancora `GB`, fuori dall'Unione dal 2021, e non `XI` (Irlanda del Nord) | Errori di battitura sulle partite IVA estere non vengono segnalati; un cliente britannico passa per comunitario |
| DIV-CF-5 🟢 (dedotta) | `PartitaIvaValida` toglie il prefisso solo se è `IT` maiuscolo | `it01234567897` non è valida, mentre `IT01234567897` sì |
