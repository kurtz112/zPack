---
area: Controlli e modifica della card
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbcard/003
---

# Controlli e modifica della card

Questa specifica descrive le regole di `TzDbCard` e dei suoi controlli (`TzControl`, `TzControls`) che contano per chi la usa: quando un campo è modificabile o obbligatorio, quando la card è in sola lettura, quali pulsanti sono visibili, come si controllano i campi obbligatori, come si nasconde un campo da codice, come si formano nomi, titoli e larghezza del dialogo e come si salvano le impostazioni. Il codice è in `zBase\zDbCard.pas`; la finestra di dialogo (`TzDbCardForm`) è in `zDbCardDlg.pas`. Lo usano WT e Gesty: ogni form documentale ha card costruite dai metadati LZ e le form scritte a mano le configurano da codice. Non è in questa specifica l'interfaccia di personalizzazione (barra, popup, editor di layout, `zz.base.editor.DbCard.pas`). Descrive il comportamento atteso, non il codice.

**Come funziona.** `TzDbCard` è un frame legato a un `TzFbDataSet` (`zDataSet`) e a un `TzDbCardProps` (le impostazioni, dal dizionario LZ). `zControls` è la collezione dei controlli, uno per campo, ognuno con il proprio editor DevExpress (`cxCustomEdit`). Le impostazioni dicono quali campi mostrare e come; il dataset dice cosa è obbligatorio o in sola lettura per il database; il programma può forzare la sola lettura o nascondere campi da codice.

**Test che coprono quest'area.** `Test.zDbCard.Estrazioni` per `MakeUniqueName` e `EstraiCaptionDaIdDataSet`. Il resto richiede una card con finestra e dataset e si prova sul banco: nessun test automatico.

## ZDBCARD-CTL-001 Modificabilità di un campo
`TzControl.GetEditability` sceglie fra tre stati. È in sola lettura (`edReadOnly`) se il controllo ha `ReadOnly` o `ForcedReadOnly`, oppure se il campo del dataset è in sola lettura (`FieldReadOnly`) a meno che sia un lookup con `LookupIgnoreFieldReadOnly` (i lookup su campi di join), oppure se la card è in sola lettura. Altrimenti è obbligatorio (`edRequired`) se `Required` o `FieldRequired` (cioè il campo è `Required` nel dataset); altrimenti normale. Ogni cambio di `ReadOnly`, `FieldReadOnly`, `ForcedReadOnly`, `Required`, `FieldRequired` e `LookupIgnoreFieldReadOnly` riapplica lo stato all'editor, tranne per i gruppi (`ctGroupBox`, `ctCheckGroupBox`) che non hanno uno stato di modifica. Il dominio (`Domain.Required`) non conta: non funziona con i campi di join.

### Scenario: campo obbligatorio del database
- **Dato** un campo `NOME` non in sola lettura, con `Required` vero nel dataset
- **Quando** la card aggiorna i controlli (`UpdateColors`)
- **Allora** l'editor di `NOME` è nello stato obbligatorio

### Scenario: lookup su campo di join
- **Dato** un lookup con `LookupIgnoreFieldReadOnly` vero su un campo in sola lettura per il dataset
- **Quando** si calcola la modificabilità
- **Allora** il lookup resta modificabile

## ZDBCARD-CTL-002 Sola lettura della card
`IsCardReadOnly` dipende da `ReadOnly` (`crUseLoadedProps`, `crForceReadOnly`, `crForceWriteable`): con `crUseLoadedProps` vale `Flags.ReadOnly` delle impostazioni oppure `RestrictionReadOnly` (il permesso di sola lettura da `zRestrictions`); con `crForceReadOnly` è sempre vera; con `crForceWriteable` sempre falsa, anche se le impostazioni o le restrizioni dicono sola lettura. Cambiare `ReadOnly` o `RestrictionReadOnly` aggiorna `DataController.ReadOnly` e ricostruisce i controlli; assegnare lo stesso valore non fa niente.

### Scenario: scrittura forzata
- **Dato** una card con `Flags.ReadOnly` vero e `ReadOnly = crForceWriteable`
- **Quando** si chiede `IsCardReadOnly`
- **Allora** il risultato è falso

## ZDBCARD-CTL-003 Pulsanti e azioni di modifica
`UpdateActions` mostra le frecce (prima, precedente, successiva, ultima), l'aggiornamento e Ok/Annulla secondo i flag delle impostazioni (`ButtonArrows`, `ButtonRefresh`, `ButtonOkCancel`); Ok e Annulla compaiono solo mentre il dataset è in modifica. Inserisci, Modifica ed Elimina compaiono solo se il flag del pulsante è acceso (`ButtonInsert`, `ButtonUpdate`, `ButtonDelete`), la proprietà `DisableInsert`, `DisableEdit` o `DisableDelete` è falsa e il dataset lo consente (`CanInsert`, `CanEdit`, `CanDelete`); senza dataset valido contano solo flag e `Disable...`. Se la form assegna un gestore (`OnDataSetInsert`, `OnDataSetEdit`, `OnDataSetDelete`) l'azione corrispondente è sempre visibile e i metodi `dbInsert`, `dbEdit`, `dbDelete` chiamano il gestore al posto dell'operazione sul dataset, senza altri controlli. `dbDelete` chiede conferma («Elimino il record?») prima di cancellare; `dbInsert` imposta `Inserting` per la durata dell'inserimento.

### Scenario: inserimento disattivato da codice
- **Dato** `DisableInsert = true` e nessun gestore `OnDataSetInsert`
- **Quando** la card aggiorna le azioni e poi si chiama `dbInsert`
- **Allora** l'azione Inserisci è nascosta e `dbInsert` non inserisce niente

### Scenario: gestore della form
- **Dato** un gestore `OnDataSetInsert` assegnato e `DisableInsert = true`
- **Quando** la card aggiorna le azioni e poi si chiama `dbInsert`
- **Allora** l'azione Inserisci è visibile e `dbInsert` chiama il gestore

## ZDBCARD-CTL-004 Campi obbligatori
`ValidateRequiredFields(RaiseError)` non controlla niente (restituisce vero) se il dataset non è in modifica. In modifica elenca i campi delle impostazioni visibili (`Controls[].Visible`) e non nascosti da codice con `HideField` (`FieldsHiddenByCode`) il cui valore manca (`DataController.RequiredFieldOk` falso) e restituisce falso. Con `RaiseError` vero mostra il messaggio «I campi seguenti devono avere un valore:» con le etichette dei campi, una per riga, e interrompe l'operazione in corso con un'interruzione silenziosa (`Abort`).

### Scenario: due campi vuoti
- **Dato** un record in inserimento con `NOME` e `COGNOME` obbligatori e vuoti
- **Quando** la card chiama `ValidateRequiredFields(true)`
- **Allora** compare l'avviso con le etichette dei due campi e il salvataggio si ferma

### Scenario: campo obbligatorio nascosto dalla form
- **Dato** un campo obbligatorio e vuoto che la form ha nascosto con `HideField`
- **Quando** la card chiama `ValidateRequiredFields(true)`
- **Allora** il campo non viene controllato e non compare nell'avviso

## ZDBCARD-CTL-005 Campo nascosto da codice
`HideField(Nome)` rende invisibile il controllo (editor ed elemento del layout) e ricorda la visibilità precedente la prima volta (le chiamate ripetute non la sovrascrivono): `SaveToProps` salva nelle impostazioni quella precedente, così una scelta del programma resta solo di esecuzione e non diventa una preferenza persistente dell'utente. Un nome che non è nella collezione non fa niente. `TzControl.Visible` aggiorna editor, etichetta ed elemento del layout; `MakeVisible` li riaccende.

### Scenario: campo nascosto dalla form
- **Dato** un campo visibile e la form che chiama `HideField('NOTE')`
- **Quando** le impostazioni della card si salvano
- **Allora** `NOTE` risulta ancora visibile nelle impostazioni salvate

## ZDBCARD-CTL-006 Nomi e ricerca dei controlli
`MakeUniqueName(Base, Indice, Esiste)` dà `Base` se `Indice <= 0` e non esiste già, altrimenti `Base_N` con `N` che parte da `Indice` (o da 1) e sale fino al primo nome libero. `TzControls.UniqueName` parte sempre da `_1` (i nomi `LineBreak_1`, `Separator_1` sono attesi così). `TzControls.Find` per nome confronta senza distinzione fra maiuscole e minuscole. `Groups` restituisce i nomi dei gruppi usati dai controlli, senza doppioni e senza distinguere le maiuscole, saltando i controlli senza gruppo.

### Scenario: nome già usato
- **Dato** i nomi `pannello` e `pannello_1` già presenti
- **Quando** `UniqueName` riceve `pannello`
- **Allora** restituisce `pannello_2`

## ZDBCARD-CTL-007 Titolo della card e del dialogo
`GetDialogTitle` restituisce `zDbCardProps.Caption`; se la caption è quella predefinita (`zDefaultCardCaption`) usa `Title` se non è vuoto, altrimenti ricava una caption leggibile da `zDataSet.IdDataSet` con `EstraiCaptionDaIdDataSet`: tiene solo l'ultimo segmento dopo il punto (`Anagrafica.Soggetti.Altro` dà `Altro`) e separa il PascalCase con uno spazio davanti a ogni maiuscola, accentate comprese, che segue un carattere non maiuscolo; una sigla di maiuscole consecutive resta attaccata; una cifra seguita da una maiuscola ricomincia una parola. `GetTitle` restituisce il testo della label del titolo; se è vuoto, `Title`; se è vuoto, il nome del componente senza il prefisso `card` (solo il prefisso, scritto minuscolo: `cardCreditCard` dà `CreditCard`).

### Scenario: caption dal dataset
- **Dato** `IdDataSet = "Anagrafica.SoggettiFisici"` e la caption predefinita
- **Quando** si chiede il titolo del dialogo
- **Allora** vale `Soggetti Fisici`

## ZDBCARD-CTL-008 Larghezza del dialogo
`GetDialogWidth` restituisce `DlgWidth` delle impostazioni; se è in unità a 96 dpi (dopo un salvataggio differito) lo riporta ai pixel veri con `MulDiv(valore, CurrentPPI, 96)`. Se il risultato è zero o negativo (il segnaposto -1 non vale più esattamente -1 a DPI diversi) usa `CalcSuggestedDialogWidth` (specifica `Layout della card`, ZDBCARD-LAY-007). Nel dialogo (`Owner` è `TzDbCardForm`) la card porta la `ClientWidth` della form a quel valore, senza innescare un nuovo ricalcolo.

### Scenario: DPI diverso da 96
- **Dato** `DlgWidth = 800` salvato in unità a 96 dpi e un frame a 144 dpi
- **Quando** si chiede la larghezza
- **Allora** vale 1200

## ZDBCARD-CTL-009 Salvataggio delle impostazioni
`SaveProperties` non fa niente in fase di progettazione. Altrimenti, se le impostazioni non hanno un dataset, scrive `GetID_DataSet`; poi, in modo sincrono, allinea i controlli alle impostazioni (`SaveToProps`) e legge dalla form la dimensione del dialogo (`LoadCardFormSize`); infine posta `cmd_SaveProperties`, e la scrittura vera (`SaveToBase`, o `OnCustomSaveProps` se assegnato, specifica `Comandi e salvataggio della card`) avviene dopo, in un task. Chi legge le impostazioni subito dopo `SaveProperties` vede già lo stato corrente.

### Scenario: raffica di modifiche
- **Dato** uno spinner che cambia la dimensione di un campo cento volte
- **Quando** ogni tick chiama `SaveProperties`
- **Allora** le impostazioni in memoria sono sempre aggiornate e la scrittura nella base avviene una volta per task, non cento

## ZDBCARD-CTL-010 Valori del lookup
`LookupRecordValid` è vero se il lookup non ha un campo `DISABLED`; con un campo booleano è vero quando il valore è falso; con un campo testo è vero salvo quando il testo è `S` (un valore nullo o diverso da `S` rende il record scegliibile). `CheckLookupRecordValid` solleva un'eccezione con il messaggio «Il valore selezionato è disabilitato.» quando il record scelto non è valido. All'inserimento di un record la card azzera i campi di lookup visibili, modificabili e di tipo intero il cui valore è -1 (valore predefinito non valido, `ClearInvalidDefaultValues`). `IsEmptyValue` è vero se l'editor è assegnato e il suo valore è nullo o una stringa vuota.

### Scenario: record disabilitato
- **Dato** un lookup il cui record scelto ha `DISABLED = 'S'`
- **Quando** la card controlla il record
- **Allora** `LookupRecordValid` è falso e `CheckLookupRecordValid` solleva l'eccezione con il messaggio di disabilitato

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-211 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita; DIV-CTL-3 è fotografata da un test.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-CTL-2 ✅ (corretta) | `GetTitle` controllava il prefisso con `StartsWith('card')` ma toglieva il testo con `Replace('card', '', [rfIgnoreCase])`, cioè ogni occorrenza. Corretta nel rilascio 009: si toglie solo il prefisso. Resta il confronto che distingue maiuscole e minuscole (`Card1` non perde il prefisso) | Nessuna |
| DIV-CTL-3 ✅ (corretta) | `EstraiCaptionDaIdDataSet` toglieva solo il primo prefisso con il punto e non riconosceva le maiuscole accentate. Corretta nel rilascio 009: si tiene l'ultimo segmento e le maiuscole si riconoscono con `Char.IsUpper`. Provata da `DuePrefissiConPunto_ResidioNellaCaption` e `MaiuscolaAccentata_Riconosciuta` | Nessuna |
| DIV-CTL-4 ✅ (corretta) | Il secondo ripiego di `GetDialogWidth` (300, 400, 500, 800 o 1000 secondo il numero di controlli) non scattava mai: `CalcSuggestedDialogWidth` restituisce sempre almeno il minimo di 400 px o il massimo disponibile. Tolto nel rilascio 006 | Nessuna: era codice morto |
| DIV-CTL-5 ✅ (corretta) | `LookupRecordValid` con un campo `DISABLED` di tipo testo era vero solo per `N`: un valore nullo era trattato come disabilitato. Corretta nel rilascio 010: il record è valido salvo `S` | Nessuna |
