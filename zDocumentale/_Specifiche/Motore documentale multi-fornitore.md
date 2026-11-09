---
area: Motore documentale multi-fornitore
progetto: zDocumentale
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Motore documentale multi-fornitore

Questa specifica descrive il contratto comune dei quattro motori documentali di zPack: protocollo, firma elettronica, conservazione a norma e messaggi PEC. Per ciascuno ci sono cinque unit in `zDocumentale\`: `.Types` (record, eccezioni, costanti di stato), `.Intf` (l'interfaccia `IzProtocolloProvider`, `IzFirmaProvider`, `IzConservazioneProvider`, `IzMessaggioProvider`), `.ProviderBase` (la classe base da cui derivano i fornitori), `.Factory` (il registro dei fornitori) e `.Nessuno` (il fornitore di ricaduta). `zDocumentale.Providers` è la unit che raccoglie i fornitori inclusi in libreria ed è elencata nei `.dpr` di WT (`WinTarif3.dpr`) e di Gesty (`Gesty.dpr`). Il fornitore PEC reale `zDocumentale.Messaggi.Smtp` ha una specifica a parte (`Messaggi PEC via SMTP.md`, ZDOC-PEC). Le unit non stanno in nessun pacchetto `.dpk`: le compilano direttamente i progetti. Chi le usa: i ponti applicativi `Documentazione.Bridge.Protocollo`, `.Firma`, `.Conservazione`, `.Messaggi` di WT e di Gesty (anche zTicser ne ha una copia), più i fornitori concreti che vivono nelle applicazioni: in WT `Documentazione.Protocollo.Maggioli` e `Documentazione.Firma.SignHub`, in Gesty `Documentazione.Firma.ESignAnyWhere`. zServer ha una copia propria delle unit della firma in `Products\Gesty\Firma\`, fuori da questa specifica.

**Come funziona.** Il fornitore non tocca mai il database. Il ponte applicativo legge la configurazione del tenant (`ID_AZIENDA` in WT, `ID_ENTE` in Gesty) dalle tabelle `OBJ_FILES_<MOTORE>_CONFIGURAZIONE` e `_CONFIG_PARAMETRI`, chiede alla fabbrica il fornitore per nome, gli passa la configurazione con `Configura` e aggancia le funzioni di richiamo per il registro tecnico (e, per la firma, per creare le versioni nella catena `OBJ_FILES`). Ogni operazione che il fornitore non sa fare solleva un'eccezione «non gestita»; l'interfaccia utente decide quali comandi mostrare leggendo `Funzionalita`, così un fornitore che non dichiara una funzione non la vede mai chiamare.

**Test che coprono quest'area.** Nessuna unit di prova in `zPack\_UnitTest\_src` tocca `zDocumentale`.

## ZDOC-MOT-001 Registro dei fornitori
Ogni fornitore si registra da sé nella sezione `initialization` della propria unit con `Tz<Motore>Factory.Registra(Nome, Classe)`. Il nome viene salvato in maiuscolo; registrare due volte lo stesso nome sostituisce la classe precedente senza errore. Perché un fornitore sia disponibile basta che la sua unit compaia in un `uses` del programma: per quelli di libreria lo fa `zDocumentale.Providers` (oggi i quattro `NESSUNO` e `SMTP`), per quelli delle applicazioni il `.dpr`.

### Scenario: fornitore incluso nel programma
- **Dato** un programma che include `Documentazione.Protocollo.Maggioli`
- **Quando** parte
- **Allora** `TzProtocolloFactory` conosce il fornitore `MAGGIOLI` senza altro codice

### Scenario: nome scritto in minuscolo
- **Dato** un fornitore registrato come `SignHub`
- **Quando** si chiede l'elenco dei fornitori
- **Allora** il nome compare come `SIGNHUB`

## ZDOC-MOT-002 Creazione del fornitore
`Crea(Nome)` toglie gli spazi ai bordi, porta il nome in maiuscolo e restituisce un'istanza **nuova** della classe registrata, come interfaccia (la libera il conteggio dei riferimenti). Un nome vuoto vale `NESSUNO`. Un nome sconosciuto ricade **in silenzio** sul fornitore `NESSUNO` (DIV-MOT-2). Solo se nemmeno `NESSUNO` è registrato la fabbrica solleva l'errore del motore: `Nessun provider di protocollo registrato per "<nome>"` (`EzProtocolloErrore`), `Nessun provider di firma registrato per ...` (`EzFirmaErrore`), `Nessun provider di conservazione registrato per ...` (`EzConservazioneErrore`), `Nessun provider PEC registrato per ...` (`EzMessaggioErrore`).

### Scenario: nome con spazi e minuscole
- **Dato** il fornitore `SMTP` registrato
- **Quando** si chiama `TzMessaggioFactory.Crea(' smtp ')`
- **Allora** si ottiene un'istanza di `TzMessaggioSmtpProvider`

### Scenario: nome sconosciuto
- **Dato** un nome di fornitore scritto male in configurazione, per esempio `MAGIOLI`
- **Quando** si chiama `TzProtocolloFactory.Crea('MAGIOLI')`
- **Allora** si ottiene il fornitore `NESSUNO` e nessuna eccezione

## ZDOC-MOT-003 Elenco dei fornitori
`ElencoFornitori(Elenco)` svuota la lista ricevuta e vi scrive i nomi registrati, in maiuscolo, senza un ordine garantito (è l'ordine interno del dizionario). La lista nulla è un errore di programmazione (`Assert`).

### Scenario: elenco per la schermata di configurazione
- **Dato** un programma con i fornitori di firma `NESSUNO` e `SIGNHUB`
- **Quando** si chiama `TzFirmaFactory.ElencoFornitori` su una lista con righe già presenti
- **Allora** la lista contiene esattamente `NESSUNO` e `SIGNHUB`, in un ordine qualunque

## ZDOC-MOT-004 Operazioni non gestite e funzionalità dichiarate
La classe base implementa l'intera interfaccia: ogni metodo che il fornitore concreto non ridefinisce solleva l'eccezione «non gestita» del motore, che deriva dall'errore generale del motore (così un solo `except on EzProtocolloErrore` intercetta entrambe). I messaggi sono:

| Motore | Eccezione | Messaggio |
|---|---|---|
| Protocollo | `EzProtocolloNonSupportato` | `Il fornitore di protocollo "<Nome>" non supporta l'operazione <Operazione>` |
| Firma | `EzFirmaNonSupportato` | `Il fornitore di firma "<Nome>" non supporta l'operazione <Operazione>` |
| Conservazione | `EzConservazioneNonSupportato` | `Il conservatore "<Nome>" non supporta l'operazione <Operazione>` |
| PEC | `EzMessaggioNonSupportato` | `Il fornitore PEC "<Nome>" non supporta l'operazione <Operazione>` |

Vale anche per `TestConnessione`: un fornitore che non la ridefinisce dice di non gestirla. `Funzionalita` della classe base è l'insieme vuoto: un fornitore dichiara solo ciò che sa fare (protocollo: `pfProtocollaUscita`, `pfImportaEntrata`, `pfRicerca`, `pfScaricaAllegati`, `pfAnnulla`, `pfAggiungiAllegato`, `pfPrenotaNumero`, `pfInviaPec`; firma: `ffFirma`, `ffScaricaCertificato`; conservazione: `cfVersa`, `cfVerificaEsito`, `cfEsibisci`, `cfScaricaRapporto`, `cfAnnulla`; PEC: `pecInvia`, `pecLeggiRicevute`, `pecVerificaConsegna`).

### Scenario: operazione non ridefinita
- **Dato** un fornitore di conservazione che ridefinisce solo `Versa`
- **Quando** si chiama `Annulla`
- **Allora** si ottiene `EzConservazioneNonSupportato` con il messaggio `Il conservatore "<Nome>" non supporta l'operazione Annulla`

## ZDOC-MOT-005 Connessione del protocollo
Solo il motore del protocollo ha `Connetti`, `Disconnetti` e `Connesso`. Nella classe base non aprono nulla: impostano e leggono un indicatore, falso alla creazione. Un fornitore con una sessione vera li ridefinisce.

### Scenario: fornitore senza sessione
- **Dato** un fornitore di protocollo appena creato
- **Quando** si chiama `Connetti`
- **Allora** `Connesso` diventa vero, e torna falso dopo `Disconnetti`

## ZDOC-MOT-006 Registro tecnico delle chiamate
Il fornitore annota ogni chiamata al servizio esterno con `LogRequest(Operazione, Endpoint, Richiesta)`, che restituisce l'identificativo della richiesta, e poi con `LogResponse(IdLogRequest, HttpStatus, Risposta, Errore)`. Il ponte aggancia `OnLogRequest` e `OnLogResponse` alle procedure `OBJ_FILES_<MOTORE>_LOG_REQUEST_ADD` e `_RESPONSE_ADD`. Se le funzioni di richiamo non sono assegnate il registro non fa nulla: `LogRequest` restituisce 0 e `LogResponse` non solleva errori. Una richiesta senza risposta nel registro indica una chiamata mai tornata (tempo scaduto o programma interrotto).

### Scenario: fornitore usato senza ponte
- **Dato** un fornitore creato con la fabbrica e senza `OnLogRequest`
- **Quando** il fornitore chiama `LogRequest`
- **Allora** ottiene 0 e l'operazione prosegue

## ZDOC-MOT-007 Configurazione e parametri
Ogni motore ha il suo record di configurazione (`TzProtocolloConfigurazione`, `TzFirmaConfigurazione`, `TzConservazioneConfigurazione`, `TzMessaggioConfigurazione`) con fornitore, tenant, credenziali e un dizionario `Parametri` (chiave → valore, da `OBJ_FILES_<MOTORE>_CONFIG_PARAMETRI`). `Inizializza` azzera il record e crea i dizionari; `Finalizza` li libera. `Parametro(Chiave, Default)` cerca la chiave **portata in maiuscolo** e restituisce `Default` se la chiave manca o se il dizionario non esiste: il ponte deve quindi inserire le chiavi in maiuscolo (WT e Gesty lo fanno con `.ToUpper`). Protocollo e conservazione hanno anche `Corrispondenze` (`'TIPO|CODICE_INTERNO'` → codice esterno) lette con `Corrispondenza(Tipo, CodiceInterno)`, che porta in maiuscolo entrambe le parti e restituisce la stringa vuota se manca la voce (DIV-MOT-5). La conservazione ha in più `TipoVersioneDaConservare` (per esempio `PRO`), la PEC `IndirizzoMittente` al posto di `UrlBase`.

### Scenario: chiave registrata in maiuscolo
- **Dato** un dizionario dei parametri con `SMTP_PORT = 587`
- **Quando** il fornitore chiede `Parametro('smtp_port', '465')`
- **Allora** ottiene `587`

### Scenario: parametro assente
- **Dato** un dizionario senza la chiave `IMAP_CARTELLA`
- **Quando** il fornitore chiede `Parametro('IMAP_CARTELLA', 'INBOX')`
- **Allora** ottiene `INBOX`

## ZDOC-MOT-008 Proprietà della configurazione passata al fornitore
Nel motore della **firma** il fornitore possiede una copia propria della configurazione (Mantis #61): `Configura` usa `CopiaDa`, che crea un dizionario nuovo e vi copia le coppie, e il distruttore del fornitore libera quella copia. Così il ponte può ricaricare e liberare la propria configurazione mentre un fornitore è ancora vivo. Se `CopiaDa` riceve una configurazione che usa già lo stesso dizionario, aggiorna solo i campi semplici e non tocca le coppie (altrimenti distruggerebbe la sorgente mentre la legge). Gli altri tre motori copiano invece il riferimento al dizionario del ponte (DIV-MOT-1).

### Scenario: ricarica della configurazione durante la firma
- **Dato** un fornitore di firma configurato dal ponte
- **Quando** il ponte richiama `CaricaConfigurazione`, che libera il proprio dizionario e ne crea uno nuovo
- **Allora** `Parametro` del fornitore continua a restituire i valori ricevuti con `Configura`

## ZDOC-MOT-009 Protocollo «NESSUNO»: numerazione interna
Il fornitore `NESSUNO` del protocollo non è inerte: protocolla con la numerazione interna dell'applicazione, attraverso la funzione `NumerazioneInterna` che il ponte assegna subito dopo `Crea` (unico punto in cui è lecita la conversione a `TzProtocolloNessunoProvider`). Con la funzione assegnata `Funzionalita` vale `[pfProtocollaUscita]` e `Protocolla` restituisce l'esito della funzione; senza, `Funzionalita` è vuota, `Protocolla` solleva `EzProtocolloNonSupportato` e `TestConnessione` solleva `EzProtocolloErrore` con `Nessun registro di protocollo interno configurato`. Oggi né WT né Gesty assegnano la funzione: il ponte di WT tratta `NESSUNO` come fornitore assente e nasconde il comando.

### Scenario: nessun registro interno
- **Dato** un `TzProtocolloNessunoProvider` senza `NumerazioneInterna`
- **Quando** si chiama `TestConnessione`
- **Allora** si ottiene `EzProtocolloErrore` con `Nessun registro di protocollo interno configurato`

### Scenario: registro interno agganciato
- **Dato** un ponte che assegna `NumerazioneInterna`
- **Quando** l'interfaccia legge `Funzionalita`
- **Allora** ottiene `[pfProtocollaUscita]` e può mostrare il comando di protocollazione

## ZDOC-MOT-010 Firma, conservazione e PEC «NESSUNO»
Per firma, conservazione e PEC non esiste un equivalente interno: il fornitore `NESSUNO` ha `Funzionalita` vuota e ogni operazione, compresa `TestConnessione`, solleva l'eccezione «non gestita» del motore (ZDOC-MOT-004). Senza un fornitore configurato il comando non compare.

### Scenario: firma senza fornitore
- **Dato** un tenant senza fornitore di firma configurato
- **Quando** l'applicazione crea il fornitore con nome vuoto e chiama `Firma`
- **Allora** si ottiene `EzFirmaNonSupportato`

## ZDOC-MOT-011 Firma: due modelli di fornitore e versioni create dal ponte
`TzFirmaDocumento` porta sia `Credenziale` (fornitori a certificato remoto, una persona) sia `Firmatari` (fornitori a busta, più firmatari con ruolo, segnaposto e profilo di firma remota; profilo vuoto = firma con codice monouso): ogni fornitore usa il campo che gli serve. Un fornitore a certificato firma subito e restituisce `Stato = 'F'` con `IdObjectFileFirmato`; uno a busta invia e restituisce `Stato = 'D'` con `IdDocumentoEsterno`, e completa poi con `AggiornaEstremi`. Le versioni nuove della catena `OBJ_FILES` (`FIR` per il firmato, `RIC` per la traccia di controllo) si ottengono solo con `CreaVersione`, che passa dalla funzione `OnCreaVersione` del ponte; se il ponte non l'ha assegnata solleva `EzFirmaErrore` con `Callback di creazione versione non assegnata (fornitore "<Nome>")`. `TzFirmaCredenziale.Vuota` è vera quando alias, PIN e certificato sono tutti vuoti.

### Scenario: firmato senza funzione del ponte
- **Dato** un fornitore di firma senza `OnCreaVersione`
- **Quando** deve salvare il file firmato e chiama `CreaVersione`
- **Allora** si ottiene `EzFirmaErrore` con il nome del fornitore nel messaggio

## ZDOC-MOT-012 Codici di stato
I codici di stato sono costanti condivise con i domini del database e non vanno cambiati senza cambiare anche quelli:

| Motore | Costanti | Dominio |
|---|---|---|
| Firma | `I` inserita, `A` approvata, `D` in firma, `F` firmata, `R` respinta, `S` scaduta | `OBJ_FILES_FIRMA_STATO` |
| Conservazione, pacchetto | `INS`, `GEN`, `INV`, `ACC`, `RIF`, `CON`, `ANN` | `OBJ_FILES_CONSERVAZIONE_STATO` |
| Conservazione, documento | `A` accettato, `S` scartato, `W` in attesa | `OBJ_FILES_CONSERVAZIONE_ESITO` |
| PEC | `P` preparata, `I` inviata, `A` accettata, `C` consegnata, `E` errore, `X` annullata | `OBJ_FILES_MAIL_E_MESSAGGI_STATO` |

Nel protocollo il soggetto ha `Tipo` `M` (mittente) o `D` (destinatario), dominio `OBJ_FILES_PROTOCOLLO_TIPO_SOGGETTO`.

### Scenario: fornitore a busta appena inviato
- **Dato** un fornitore a busta che ha consegnato la busta al servizio esterno
- **Quando** restituisce l'esito di `Firma`
- **Allora** `Stato` vale `FIRMA_STATO_IN_FIRMA`, cioè `D`

## ZDOC-MOT-013 Estremi del protocollo
`TzProtocolloEsito.Estremi` restituisce `<Numero>/<Anno>`, seguito da ` del gg/mm/aaaa` se `Data` è valorizzata; restituisce la stringa vuota se numero e anno sono entrambi zero. `InAttesaDiNumero` vero indica un fornitore che numera in differita: il ponte lascia la registrazione in attesa e la completa con `AggiornaEstremi`.

### Scenario: estremi completi
- **Dato** un esito con `Numero = 1234`, `Anno = 2026` e `Data` il 15/07/2026
- **Quando** si chiede `Estremi`
- **Allora** il risultato è `1234/2026 del 15/07/2026`

### Scenario: esito senza numero
- **Dato** un esito con numero e anno a zero
- **Quando** si chiede `Estremi`
- **Allora** il risultato è la stringa vuota

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-MOT-1 🟡 (dedotta) | Il difetto corretto per la firma con Mantis #61 è ancora presente negli altri tre motori: `Configura` di protocollo, conservazione e PEC fa `FConfigurazione := Configurazione`, cioè copia il riferimento al dizionario del ponte, che lo libera a ogni `CaricaConfigurazione` (WT e Gesty) | Oggi il danno è latente perché i ponti creano il fornitore subito dopo la ricarica e Maggioli copia i valori dentro `Configura`; ma il fornitore SMTP legge `Parametro` al momento dell'invio: una ricarica fatta mentre il fornitore è vivo gli fa leggere memoria liberata, con errori di accesso o parametri vuoti (`PEC: parametro SMTP_HOST non configurato`) |
| DIV-MOT-2 🟢 | Un nome di fornitore sconosciuto ricade in silenzio su `NESSUNO`, senza errore e senza traccia nel registro (il commento lo dichiara voluto) | Un errore di battitura nella colonna `FORNITORE`, o una unit del fornitore dimenticata nel `.dpr`, fa sparire il comando dall'interfaccia senza che nessuno sappia perché |
| DIV-MOT-3 🟢 | Commenti superati: la fabbrica del protocollo dice di aggiungere i fornitori «con una riga nel .dpr» (oggi la riga va in `zDocumentale.Providers`); quella dei messaggi dice che il fornitore SMTP è «fase successiva», ma esiste; `MESSAGGIO_FORNITORE_SMTP` è dichiarata due volte, in `Messaggi.Factory` e in `Messaggi.Smtp` | Chi aggiunge un fornitore segue un'istruzione vecchia; le due costanti possono divergere se ne cambia una sola |
| DIV-MOT-4 🟢 | `ElencoFornitori` restituisce i nomi nell'ordine interno del dizionario | L'ordine nella tendina di scelta del fornitore può cambiare da un avvio all'altro o con l'aggiunta di un fornitore |
| DIV-MOT-5 🟢 | `Corrispondenze` e `Corrispondenza` di protocollo e conservazione non sono usate da nessuno: i ponti non caricano il dizionario (WT trasporta `TIPO_DOCUMENTO`, `CLASSIFICA`, `UFFICIO`, `AREA_ORGANIZZATIVA`, `CANALE_INVIO` come parametri) e nessun fornitore le legge | Un fornitore nuovo che si affidasse a `Corrispondenza` riceverebbe sempre la stringa vuota senza accorgersene |
