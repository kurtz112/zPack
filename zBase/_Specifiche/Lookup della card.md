---
area: Lookup della card
progetto: zBase
aggiornato: 2026-11-02
rilascio: Ticket_Gesty/312 - inserimento nuovo intervento/004
---

# Lookup della card

Questa specifica descrive il lato «dataset» dei lookup di un campo della card: come si leggono i campi master di un lookup (`MasterFields`), come si allineano i parametri del dataset di lookup ai campi della card, quando il dataset si apre e quando si riapre. Il codice è in `zBase\zDbCard.Lookup.pas` (`TzMasterFieldsBinder`, `TzLookupBinding`). Lo usano `TzControl` della card (`CreateLookupBinding`) e `zDbLookupEditors.pas` (lookup nelle celle della vista record), quindi WT e Gesty. La parte di interfaccia (combo, finestra F2, colori) resta su `TzControl` e non è in questa specifica. Descrive il comportamento atteso, non il codice.

**Come funziona.** Ogni campo con un lookup ha un `TzLookupBinding`, che possiede un `TzFbDataSet` e un `TDataSource` costruiti dalle impostazioni di `zSystem` (`zLookups`, `DataSetLoadProps`). Il lookup può dipendere da altri campi della card: `TzLookup.MasterFields` dice quali, nella forma `PARAM@CAMPO;PARAM2@CAMPO2` oppure `CAMPO;CAMPO2` (parametro e campo con lo stesso nome). Prima di aprirsi, e a ogni cambio dei campi master, il binding copia il valore dei campi nei parametri del dataset di lookup e, se qualcosa è cambiato, lo riapre. I lookup restano chiusi finché non servono.

**Test che coprono quest'area.** Il confronto del requisito ZDBCARD-LKP-008 è coperto da `Test.zDbCard.Lookup.Corrispondenza` (19 test, sui soli valori). Il resto (`AssignParams`, `EnsureOpen`) richiede un `TzFbDataSet` con SQL preparabile e non ha test; si può provare su SQLite in memoria come in `Test.zFbDataSet.Predefiniti` (voce R-211). Non è coperto da test l'aggancio di `CopyMappingFields` al dataset della card: lo si prova con la sonda (Mantis #312, scheda Interventi SIA di Gesty).

## ZDBCARD-LKP-001 Lettura di MasterFields
`TzMasterFieldsBinder.AssignParams` normalizza il testo di `MasterFields`: la virgola diventa punto e virgola, la chiocciola diventa uguale, gli spazi si tolgono; poi lo divide per punto e virgola. Ogni voce è `CAMPO` (parametro e campo con lo stesso nome) oppure `PARAMETRO=CAMPO` (parametro del dataset di lookup, campo della card). Una voce con più di due parti (`A@B@C`) non è riconosciuta: è saltata e se ne scrive il motivo nel registro, senza modificare niente e senza usare i valori della voce precedente.

### Scenario: parametro e campo con nomi diversi
- **Dato** `MasterFields = "ID_CORSO@ID"` e un dataset di lookup con il parametro `ID_CORSO`
- **Quando** si allineano i parametri
- **Allora** il parametro `ID_CORSO` riceve il valore del campo `ID` della card

### Scenario: voce malformata
- **Dato** `MasterFields = "A@B@C;X"`
- **Quando** si allineano i parametri
- **Allora** la voce `A@B@C` è saltata e la voce `X` è elaborata come parametro e campo `X`

## ZDBCARD-LKP-002 Condizioni di uscita
`AssignParams` non fa niente, e restituisce `ParamsChanged = false`, se manca il lookup, il dataset di destinazione o quello sorgente, se l'SQL del dataset di lookup è vuoto o se `MasterFields` è vuoto (anche di soli spazi). Se il dataset di lookup non è attivo lo prepara (`Prepare`) prima di leggere i parametri. Un parametro che non esiste nel dataset di lookup, o un campo sorgente che non si trova, sono saltati e scritti nel registro.

### Scenario: lookup senza campi master
- **Dato** un lookup con `MasterFields` vuoto
- **Quando** si allineano i parametri
- **Allora** nessun parametro cambia e `ParamsChanged` è falso

## ZDBCARD-LKP-003 Valore dei parametri
Il parametro di destinazione si aggiorna solo se il valore cambia davvero. Con campo sorgente nullo il parametro si azzera (`Clear`) soltanto se contiene un valore reale: non nullo, non vuoto, non uguale a `0` dopo `Trim`. Con campo valorizzato il parametro si assegna se il suo valore, confrontato come testo senza spazi ai bordi, è diverso da quello del campo; fa eccezione il caso in cui il parametro sia nullo, vuoto o `0` e il campo sia una stringa vuota, che non si riassegna: assegnare `''` a un parametro di tipo data lo trasforma in nullo e a ogni giro seguente nullo e vuoto sembrerebbero diversi, con un ciclo infinito di riaperture. `ParamsChanged` è vero se almeno un parametro è stato modificato.

### Scenario: campo nullo, parametro con un valore
- **Dato** il parametro `ID_CORSO` con valore 12 e il campo sorgente nullo
- **Quando** si allineano i parametri
- **Allora** il parametro è azzerato e `ParamsChanged` è vero

### Scenario: campo vuoto, parametro nullo
- **Dato** un parametro di tipo data nullo e un campo sorgente stringa vuota
- **Quando** si allineano i parametri
- **Allora** il parametro non cambia e `ParamsChanged` è falso

## ZDBCARD-LKP-004 Campo sorgente lungo la catena master/dettaglio
Il campo sorgente si cerca nel dataset della card per nome. Se il dataset è attivo, vuoto e in navigazione (nessuna riga e nessun inserimento in corso), il campo c'è ma non ha valore: in quel caso il valore si prende dal dataset master (`DataSource.DataSet`), se lo ha, risalendo la catena. Se il campo non esiste nel dataset, la ricerca prosegue sul master. (Mantis #298: prima il campo nullo azzerava il parametro impostato da `BeforeOpen` del lookup, che si apriva vuoto.)

### Scenario: dettaglio senza righe
- **Dato** un dataset di dettaglio aperto e vuoto, con un master che ha il campo `ID_INCARICO` valorizzato
- **Quando** il lookup chiede `ID_INCARICO`
- **Allora** il valore arriva dal master e il lookup si apre filtrato

## ZDBCARD-LKP-005 Dataset del binding
`CreateMainDataSet` crea una sola volta il dataset (`LK_<IdLookup>`, nome reso valido) e il suo datasource (`<nome>Src`). Il dataset prende dal lookup di `zSystem` il dataset di riferimento (`IdDataSet`), le sue impostazioni (`DataSetLoadProps`), `AutoCommit = true`, `UseSqlLocate = true` e l'evento `OnGetQueryParams` del binding: l'evento standard assegnato da `DataSetLoadProps` va sostituito, perché prima si allineano i parametri master e poi si chiama quello standard (`DataSetQueryParams`). `CreateAuxiliaryDataSet` costruisce un secondo dataset con la stessa configurazione, che passa al chiamante (finestra F2, check-combo). `ReapplyDataSetProps` riapplica le impostazioni al dataset principale, se esiste.

### Scenario: due chiamate a CreateMainDataSet
- **Dato** un binding con il dataset già creato
- **Quando** si richiama `CreateMainDataSet`
- **Allora** non si crea un secondo dataset

## ZDBCARD-LKP-006 Apertura su richiesta
`EnsureOpen` apre il dataset solo se esiste, non è già attivo, il dataset della card è attivo e l'SQL non è vuoto: i lookup restano chiusi finché non servono (prestazioni). Un errore di apertura si scrive nel registro, con l'SQL, e si risolleva.

### Scenario: card chiusa
- **Dato** un lookup chiuso e il dataset della card non attivo
- **Quando** si chiama `EnsureOpen`
- **Allora** il lookup resta chiuso

## ZDBCARD-LKP-007 Verifica e riapertura
`VerifyParams` riallinea i parametri e riapre il dataset (`ReOpen`) se almeno un parametro è cambiato oppure se il dataset di lookup è chiuso mentre quello della card è stato aperto dopo la creazione del lookup. Senza dataset non fa niente.

### Scenario: cambio del campo master
- **Dato** un lookup aperto con parametro `ID_CORSO = 12`
- **Quando** l'utente cambia il campo master a 13 e la card chiama `VerifyParams`
- **Allora** il parametro diventa 13 e il lookup si riapre

## ZDBCARD-LKP-008 Copia dei campi mappati: solo dal record del valore digitato
Quando il valore di un controllo con lookup cambia, `TzControl.CopyMappingFields` copia nella card i campi mappati dal record **corrente** del dataset di lookup. Quel record è quello su cui sta il cursore, non necessariamente quello che corrisponde al valore del controllo: digitando in un lookup non vincolato (`OnlyFromLookup = false`) un valore che non è nell'elenco, il cursore resta sulla prima riga. Per questo la copia avviene solo se la chiave del record corrente coincide col valore del controllo. Il confronto sta in `TzCorrispondenzaChiaveLookup.Corrisponde` (`zBase\zDbCard.Lookup.pas`): con chiave intera è un'uguaglianza numerica (una chiave nulla vale 0; se il valore del controllo non è un intero non c'è niente da confrontare e la copia avviene); con chiave di testo è un'uguaglianza senza maiuscole e senza spazi ai bordi (una chiave nulla vale testo vuoto); per ogni altro tipo di chiave la copia avviene. Quando il controllo contiene un elenco di valori (selezione multipla) il confronto non si fa. (Mantis #312: un codice fiscale nuovo compilava la scheda con i dati di un'altra persona; una duplicazione riceveva l'identificativo dell'intervento di partenza.)

### Scenario: codice fiscale non presente nell'elenco
- **Dato** un lookup su codice fiscale non vincolato, con la prima riga di un'altra persona
- **Quando** l'utente digita un codice fiscale che non è nell'elenco
- **Allora** i campi mappati non si copiano e restano in bianco

### Scenario: codice fiscale presente
- **Dato** lo stesso lookup
- **Quando** l'utente digita il codice fiscale di una persona presente, anche con maiuscole diverse o spazi ai bordi
- **Allora** i campi mappati si copiano dal record di quella persona

### Scenario: identificativo provvisorio di una riga nuova
- **Dato** una duplicazione, con la chiave della riga nuova a -2 e il record corrente del lookup sull'intervento di partenza (95843)
- **Quando** il lookup sulla chiave notifica il cambio di valore
- **Allora** l'identificativo 95843 non viene copiato nella riga nuova

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-211 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LKP-1 🟢 (dedotta) | Con campo sorgente nullo, un parametro che vale `0` non si azzera: `0` è trattato come «vuoto» (stesso criterio dell'anti-ciclo) | Un lookup filtrato per un identificativo che vale davvero 0 non si ripulisce quando il campo master torna nullo, e mostra le righe di quel valore invece di nessuna |
| DIV-LKP-2 🟢 (dedotta) | Il confronto fra parametro e campo avviene sul testo senza spazi ai bordi (`VarToStrDef`): valori uguali ma scritti in modo diverso (`1` e `1,0`, formati di data) risultano diversi e due valori che differiscono solo per spazi risultano uguali | Una riapertura in più, o una riapertura mancata, in casi di formati misti: raro, senza perdita di dati |
| DIV-LKP-3 ✅ (corretta) | `BuildDataSet` usava `LookupSystem.zFbDatabase` senza controllare che il provider di `zSystem` fosse assegnato. Corretta nel rilascio 009: senza provider solleva un'eccezione con un messaggio chiaro (`Lookup <id>: provider di zSystem non assegnato`) | Nessuna |
