---
area: Restrizioni
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/011
---

# Restrizioni

Questa specifica descrive le restrizioni d'uso dell'interfaccia: quali azioni, schede, viste, schede di dettaglio e dataset di una form un utente vede, vede in sola lettura o non vede, secondo le policy, i gruppi e le restrizioni personali salvate nel database. Il codice è in `zBase\zRestrictions.pas` (`TRestrictionManager`, `TRestriction`), `zRestrictions.Types.pas` (livelli di accesso e classi di componente), `zRestrictions.Structs.pas` (valori predefiniti, policy, alberi dell'editor), `zRestrictions.Form.pas` (editor delle policy di una form) e `zRestrictions.Component.Form.pas` (restrizioni per utente di un singolo componente). Il livello calcolato per i dataset lo leggono `zFormController.pas` e `zDbView.pas`. Lo usano WT e Gesty: `BaseFrm.pas` crea un `TRestrictionManager` per ogni form con il suo `zDataModule`, dichiara i livelli predefiniti delle azioni di base (`ActAggiorna`, `ActStampa`, `ActEsci` in piena scrittura; `actSistema`, `ActPoliticheAccessi`, gli strumenti del controller e del layout nascosti), applica le restrizioni all'apertura e dopo Ctrl+F12 (`FormCollection.UpdatePolicies`), apre l'editor da «Politiche di accesso»; `MainForm.pas` le applica alla finestra principale; Gesty registra i componenti di una form («Salva componenti») e apre le restrizioni di una singola azione dal menu contestuale. Descrive il comportamento atteso, non il codice.

**Come funziona.** Ogni componente soggetto a restrizioni è registrato nel database (`USR_APPS_FORMS_COMPONENTS`) con applicazione, form, nome e classe. All'apertura della form `ApplyRestrictions` chiede a `USR_POLICIES_APPLY_RESTRICTIONS(APP, FORM)` l'elenco dei componenti registrati con il livello che spetta all'utente collegato, già risolto dal database fra restrizioni personali, di gruppo e di policy, e i livelli predefiniti delle sue policy; poi rende ogni componente visibile, in sola lettura o nascosto. Le restrizioni agiscono solo sull'interfaccia del client: il database non le applica ai dati.

**Test che coprono quest'area.** Nessuna.

## ZBASE-RES-001 Livelli di accesso e loro codifica
I livelli sono tre (`TAccessLevel`): `alNone` (nascosto), `alRead` (sola lettura), `alFull` (piena scrittura), salvati nel database come `X`, `R`, `W`. La lettura (`Parse`) guarda solo il primo carattere: `X` e `R` danno nascosto e sola lettura, qualunque altro valore, compresi la stringa vuota e il `NULL` letto come stringa, dà piena scrittura. Nel database le colonne dei livelli usano il dominio `USR_ACCESS`, che ammette solo `X`, `R`, `W` o `NULL`: in pratica l'unico valore «altro» è `NULL`, e la piena scrittura che ne deriva è voluta (ZBASE-RES-004, utente senza policy). Le classi di componente (`TzComponentClass`) si salvano con una lettera: `?` varie, `T` scheda (`TcxTabSheet`, `TcxPageControl`), `A` azione, `D` dataset del diagramma, `V` vista, `C` scheda di dettaglio, `U` cubo, `P` visualizzatore PDF, `G` mappa; una lettera sconosciuta dà `?`.

### Scenario: codifica
- **Dato** il livello `alRead`
- **Quando** si scrive con `ToString` e si rilegge con `Parse`
- **Allora** si ottiene `R` e poi di nuovo `alRead`

### Scenario: valore sconosciuto
- **Dato** il valore `Z` nella colonna `ACCESS`
- **Quando** si legge con `Parse`
- **Allora** il livello è `alFull`

## ZBASE-RES-002 Quali componenti si possono restringere
Sono soggetti a restrizione, se hanno un nome: le azioni (`TContainedAction`), le schede e i contenitori di schede (`TcxTabSheet`, `TcxPageControl`), i divisori (`TcxSplitter`) e, solo se il modulo dati non costruisce l'interfaccia in esecuzione (`BuildGui` falso), le viste (`TzDbView`) e le schede di dettaglio (`TzDbCard`). Dei moduli dati con `BuildGui` vero si restringono invece i dataset del diagramma (`TzDiagramDataSet`, compresi i dettagli), identificati come `NomeModulo.NomeDataset`. I componenti senza nome si saltano; i componenti non ammessi si esplorano per cercare figli ammessi.

### Scenario: vista costruita dai metadati
- **Dato** una form documentale con `zDataModule.BuildGui` vero
- **Quando** si elencano i componenti nell'editor
- **Allora** le viste create in esecuzione non compaiono e compaiono i dataset come `Modulo.Dataset`

## ZBASE-RES-003 Registrazione dei componenti
`USR_APPS_FORMS_COMPONENTS_ADD(APP, FORM, COMPONENT, COMPONENT_CLASS)` crea, se mancano, l'applicazione e la form e inserisce o aggiorna il componente. `SaveFormComponents` registra tutti i componenti ammessi della form (con il nome di classe della form) e i dataset del modulo con `BuildGui`, dettagli compresi, come `NomeModulo.NomeDataset` (lo stesso nome con cui li cercano l'editor e `ApplyRestrictions`); `EditComponentRestrictions` registra un componente e apre la finestra delle sue restrizioni per utente, che lavora in una transazione propria confermata con OK e annullata altrimenti. Solo i componenti registrati ricevono restrizioni: uno mai registrato resta come l'ha disegnato il programmatore.

### Scenario: azione mai registrata
- **Dato** un'azione nuova aggiunta a una form e mai registrata
- **Quando** la form si apre per un utente con la policy più restrittiva
- **Allora** l'azione resta visibile e abilitata

## ZBASE-RES-004 Calcolo del livello all'apertura della form
Per ogni riga di `USR_POLICIES_APPLY_RESTRICTIONS(APP, FORM)` (con `FORM` = nome della form, che in WT e Gesty coincide con il nome della classe) il livello è:
1. `alFull` se l'utente è amministratore (`zSystem.IsAdmin`), senza guardare altro;
2. altrimenti il valore di `ACCESS`, se non è `NULL` (il database ha già scelto fra restrizione personale, di gruppo e di policy, e ha messo `X` se manca un'autorizzazione richiesta dal componente);
3. altrimenti il livello predefinito dichiarato dal programma per quel componente (`AddDefaultLevel`);
4. altrimenti, per le azioni `DEFAULT_ACTION_ACCESS` e per i dataset `DEFAULT_DATASET_ACCESS` delle policy dell'utente, per ogni altra classe `alFull`;
5. nei casi 3 e 4, un dataset dichiarato con `DefaultAccessLevel = alNone` resta nascosto.

Con più policy il predefinito è il più permissivo fra quelli delle policy dell'utente, sia per le azioni (ordinando per `DEFAULT_ACTION_ACCESS`) sia per i dataset (ordinando per `DEFAULT_DATASET_ACCESS`). L'elenco dei componenti che la procedura restituisce è quello dell'applicazione e della form richieste: due applicazioni con una form dallo stesso nome non si mescolano. **Un utente senza policy** (né personale né di gruppo) riceve predefiniti `NULL`, quindi piena scrittura su ogni componente senza restrizione esplicita: è il funzionamento voluto (decisione dell'utente, 2026-11-01), perché WT usa le restrizioni solo per pochi utenti e quasi tutti i suoi utenti non hanno policy. Chi vuole un accesso ridotto per predefinito lo ottiene assegnando una policy con predefiniti `X` o `R`. In Gesty quasi tutti gli utenti stanno nel gruppo `_Default`, la cui policy ha predefiniti `W`.

### Scenario: utente senza policy
- **Dato** un utente non amministratore che non ha policy, né personali né tramite gruppi, e un'azione registrata senza restrizioni
- **Quando** la form si apre
- **Allora** l'azione è visibile e abilitata

### Scenario: amministratore
- **Dato** un componente con restrizione `X` per la policy dell'utente
- **Quando** la form si apre per un amministratore
- **Allora** il componente è visibile e in piena scrittura

### Scenario: restrizione personale
- **Dato** un'azione registrata con `ACCESS = 'X'` per l'utente
- **Quando** la form si apre
- **Allora** l'azione è nascosta

### Scenario: predefinito del programma
- **Dato** `actSistema` dichiarata da `BaseFrm` con `AddDefaultLevel(actSistema, 'Base', alNone)` e nessuna restrizione nel database
- **Quando** la form si apre per un utente non amministratore
- **Allora** l'azione è nascosta

## ZBASE-RES-005 Effetto sui componenti
- Vista e scheda di dettaglio: nascoste con `alNone`, in sola lettura (`RestrictionReadOnly`) con ogni livello diverso da `alFull`;
- scheda (`TcxTabSheet`): linguetta nascosta con `alNone`;
- voce di barra (`TdxBarItem`) senza azione collegata: nascosta con `alNone`; con un'azione, decide la restrizione dell'azione;
- ogni altro componente con la proprietà `Visible` (azioni comprese): visibile se il livello non è `alNone`;
- ogni componente con la proprietà `ReadOnly` (viste e schede escluse): in sola lettura con `alRead`;
- azione (`TContainedAction`) con `alRead`: visibile ma disabilitata, quindi non eseguibile né dal pulsante né dalla scorciatoia da tastiera. Resta disabilitata anche se il gestore di aggiornamento della form (`OnUpdate` dell'azione o della lista) prova a riabilitarla, salvo un gestore della lista che chiude l'aggiornamento con `Handled` vero (in WT e Gesty lo fa solo il profilatore Firebird di Gesty). Quando la restrizione cade (per esempio dopo Ctrl+F12) l'azione riprende il suo gestore e lo stato di abilitazione che aveva;
- dataset del diagramma: il livello va in `ActualAccessLevel`; con `alNone` il dataset sparisce da menu, viste e schede costruite da `TzFormController`, con un livello diverso da `alFull` le sue viste, schede, alberi e calendari sono in sola lettura. `ActualAccessLevel` torna `alFull` se l'utente è amministratore anche quando il valore memorizzato è `alNone`.

Le restrizioni si possono riapplicare in qualunque momento (dopo Ctrl+F12 o «Ricarica politiche»): ogni applicazione riscrive visibilità e sola lettura dei componenti elencati.

### Scenario: scheda nascosta
- **Dato** una `TcxTabSheet` registrata con livello `X`
- **Quando** si applicano le restrizioni
- **Allora** la linguetta della scheda non si vede

### Scenario: azione in sola lettura
- **Dato** un'azione registrata con livello `R` per l'utente, con un gestore `OnUpdate` che la abilita
- **Quando** la form si apre e il gestore aggiorna l'azione
- **Allora** l'azione è visibile ma disabilitata, e la sua scorciatoia non la esegue

### Scenario: dataset in sola lettura
- **Dato** il dataset `Iscrizioni.Allievi` con livello `R`
- **Quando** il controller costruisce la vista
- **Allora** la vista è in sola lettura

## ZBASE-RES-006 Editor delle policy di una form
`EditRestrictions` mostra una griglia con i componenti ammessi della form raggruppati per gruppo (quello dichiarato con `AddDefaultLevel` o la descrizione della classe) e una colonna per ogni policy che ha restrizioni sulla form (`USR_POLICIES_LOAD_RESTRICTIONS`). Una policy nuova si aggiunge scegliendo o digitando il nome (proposti da `USR_POLICIES_GET_POLICY_NAMES`) e parte con i livelli predefiniti di quella policy (`USR_POLICIES`), o nascosto se la policy non esiste ancora: il database la creerà al salvataggio (`USR_POLICIES_ADD`) con predefiniti `X`, valore predefinito delle colonne; si può duplicare una colonna, eliminare una policy (con conferma), impostare nascosto, sola lettura o scrittura sulle celle selezionate (con Ctrl, Maiuscolo, riga, colonna), esportare la griglia in Excel. «Elimina policy» agisce solo se la colonna a fuoco è quella di una policy: senza colonna a fuoco, o con a fuoco la colonna dei nomi dei componenti, non succede niente. Con OK, dopo conferma, ogni cella valorizzata si salva con `USR_POLICIES_SAVE_RESTRICTION(POLICY, APP, FORM, COMPONENT, COMPONENT_CLASS, ACCESS, IUD)`, dove `IUD` vale `+` per una restrizione nuova, `/` per una esistente e `-` per quelle di una policy eliminata. Si salvano tutte le celle, anche quelle uguali al predefinito, compreso il livello nascosto (`X`): una riga si cancella solo con `IUD = '-'`, quindi «nascosto» si può impostare anche per una policy con predefinito `W`, come `_Default` di Gesty. Il diritto di aprire l'editor è `TzSystem.CanEditRestrictions` (permesso di sistema `USR_CAN_EDIT_RESTRICTIONS()` o amministratore), ma lo controlla il programma, non `EditRestrictions`: Gesty lo verifica in `BaseFrm.pas`, `Base_Frame.pas` e nel menu Sistema; in WT l'azione `ActPoliticheAccessi` è nascosta per predefinito (ZBASE-RES-004).

### Scenario: policy eliminata
- **Dato** la policy `SEGRETERIA` con restrizioni sulla form
- **Quando** l'utente la elimina nell'editor e conferma con OK
- **Allora** le sue restrizioni sulla form partono con `IUD = '-'`

### Scenario: elimina senza policy a fuoco
- **Dato** l'editor aperto con a fuoco la colonna dei nomi dei componenti, oppure senza colonna a fuoco
- **Quando** l'utente sceglie «Elimina policy»
- **Allora** non compare nessuna conferma e la griglia resta com'è

### Scenario: policy nuova
- **Dato** una policy `OSPITE` con `DEFAULT_ACTION_ACCESS = 'X'`
- **Quando** la si aggiunge come colonna
- **Allora** le azioni senza predefinito del programma partono nascoste

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-200 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-RES-1 🔴 (dedotta) | Le restrizioni cadono tutte per l'amministratore, e chiunque può diventarlo durante la sessione con la password costante `AdminPwd` (DIV-ACC-1 in `Accesso e password.md`); inoltre agiscono solo sull'interfaccia, mentre il database accetta le stesse scritture da chi ha la connessione | Le restrizioni proteggono da errori d'uso, non da un utente che vuole aggirarle: con Ctrl+F12 e la costante, o con le credenziali del `.Sec` (DIV-ACC-2), vede e modifica tutto |
| DIV-RES-6 🟢 (dedotta) | Il livello predefinito si calcola in due modi: `ApplyRestrictions` dà piena scrittura a un componente non trovato di classe diversa da azione e dataset, `GetDefaultAccessLevel` (usato dall'editor e da `LoadRestrictions`) dà nascosto a un componente non trovato | Un componente sparito dalla form compare nell'editor con un livello diverso da quello che avrebbe all'apertura; non corretta perché l'editor elenca solo componenti presenti nella form, quindi l'effetto pratico è nullo |
| DIV-RES-8 🟢 (dedotta) | `TRestriction.Update` ha il controllo delle modifiche commentato; «Applica» dell'editor salva e poi OK salva di nuovo, rimandando come nuove (`+`) le restrizioni già inviate | Fa credere a un salvataggio differenziale che non esiste; il doppio invio dipende dalla tolleranza di `USR_POLICIES_SAVE_RESTRICTION` |
