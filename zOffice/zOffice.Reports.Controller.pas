unit zOffice.Reports.Controller;

// PROPOSTA - Mantis #90 - 2026-09-05: versione modificata per la preanalisi.
// Base: zPack\zOffice\zOffice.Reports.Controller.pas
// Non sostituisce il file sorgente (di sola lettura): va confrontata e
// riportata a mano nel repository dopo revisione in RAD Studio.
//
// Modifica: TzDocumentoContesto guadagna due campi, TipoDocumento e
// TipoAllegato, valorizzati dal '.json' del template (chiavi "tipoDocumento"/
// "tipoAllegato") con lo stesso trattamento gia' riservato a Profilo/
// TipologiaDocumentale. Nessuna dipendenza applicativa aggiunta: sono
// stringhe neutre trasportate, non interpretate da zPack. Servono al
// controller applicativo (es. TDocumentazioneReportActionsController in
// Gesty) per riconoscere il tipo di documento quando lo stesso controller e'
// condiviso da piu' template (es. Contratti e Incarichi di Massima).
// Clear() non cambia: Self := Default(TzDocumentoContesto) azzera anche i
// due campi nuovi.

// Il ponte tra i viewer di zOffice.Reports e i motori documentali
// (Protocollo/Conservazione/Firma/Pec): un controller astratto, iniettato
// dall'applicazione nel TzReportsManager (ReportsManager.ActionsController := ...)
// e nei viewer di documenti persistiti (TzMultiViewer.ActionsController := ...).
//
// NESSUNA dipendenza applicativa: zPack non conosce zSystem ne' i motori.
// L'implementazione concreta (es. TDocumentazioneReportActionsController) sta
// nell'applicazione e delega ai ponti applicativi dei motori (es.
// Documentazione.Bridge.Firma in Gesty).
//
// Il controller e' SENZA STATO DI TEMPLATE: in Gesty TzReportsManager non e'
// un singleton (uno per DataModule di feature), quindi un controller condiviso
// non puo' memorizzare la config del template corrente. La config viaggia
// come parametro, dentro TzDocumentoContesto, costruito dal chiamante a ogni
// chiamata.
//
// Dal 30/07/2026 il gate 1 legge il PROFILO DOCUMENTALE dal database, con due
// porte a seconda di chi chiede:
// - anteprima report:   AzioniDelProfilo(profilo del JSON del template)
// - documento persistito: AzioniDelDocumento(ID_OBJECT_FILE), che risolve
// il profilo dalla radice della catena
// Il nodo JSON "azioni" e' ritirato.
//
// CACHE: gli OnUpdate delle Action interrogano Stato() a ogni idle, per ogni
// azione. La base tiene in cache, per il documento corrente, i tipi versione
// della catena e lo stato di ciascuna azione: senza, scorrere una griglia di
// allegati significherebbe una raffica di query. La cache si azzera da se'
// quando cambia il documento; dopo un'azione va invalidata a mano
// (InvalidaCacheDocumento, chiamata dai controller applicativi in coda a
// Esegui/AggiornaStato).
// Dal ticket Gesty #194 in cache ci sono anche gli estremi: con un'azione
// completata l'OnUpdate li chiede a ogni idle per l'hint del bottone, e senza
// cache erano una lettura sul database per idle (11122 in 5 minuti).
// L'applicazione ridefinisce EstremiRegistrazione, non Estremi.
// Dal ticket Gesty #210 la cache tiene gli ultimi MassimoDocumentiInCache
// documenti, non uno solo: con due documenti valutati in alternanza (due
// viewer sullo stesso controller) la cache a un posto si azzerava a ogni
// cambio e ogni idle rifaceva tutte le letture (1230 cicli in 4 minuti).
// Riferimento: Analisi - 20260727 - Profili Documentali.md.

interface

uses
  System.SysUtils,
  System.Classes,
  zOffice.Reports.Azioni;

type
  TzAzioneDocumento = (adFirma, adProtocolla, adConserva, adInviaPec, adInviaMail);
  TzAzioniDocumento = set of TzAzioneDocumento;

  TzAzioneDocumentoStato = (adsNonDisponibile, // gate 1 (profilo) o 2 (permesso) falliti: bottone nascosto
    adsBloccata, // gate 3 (precondizione) fallito: visibile, disabilitato, con motivo
    adsDisponibile, // eseguibile adesso
    adsInCorso, // avviata, in attesa di esito esterno (firma a busta, ricevute PEC)
    adsCompletata); // fatta: per le azioni non ripetibili il bottone diventa "Vedi estremi"

  EzAzioneDocumentoBloccata = class(Exception);

  // Il contesto della richiesta: costruito dal chiamante a ogni chiamata,
  // mai memorizzato nel controller.
  TzDocumentoContesto = record
    IdObjectFile: Int64; // 0 = documento non ancora persistito
    Oid: Int64;
    ReportName: string;
    // classificazione dichiarata dal JSON del template: alla persistenza
    // finiscono su OBJ_FILES (il profilo esplicito vince sul default della
    // tipologia dentro OBJ_FILES_ADD)
    TipologiaDocumentale: string; // chiave JSON "tipologiaDocumentale"
    Profilo: string; // chiave JSON "profilo"
    // TIPO_DOCUMENTO/TIPO_ALLEGATO dichiarati dal template (chiavi JSON
    // "tipoDocumento"/"tipoAllegato"): il controller applicativo li usa al
    // posto del proprio default quando non sono vuoti
    TipoDocumento: string;
    TipoAllegato: string;
    AzioniConfig: TzJsonAzioniConfig; // azioni del profilo, caricate dal chiamante
    procedure Clear;
  end;

  // Regola dell'applicazione sul SOGGETTO del documento, non sul documento:
  // il motore non puo' conoscerla (in Gesty: la risorsa accetta il contratto
  // in forma elettronica o lo vuole cartaceo). Restituisce False e il motivo
  // da mostrare all'operatore. Non assegnata = nessun vincolo aggiuntivo.
  TzAzioneAmmessaFunc = reference to function(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto; out Motivo: string): Boolean;

  // Quanto la base ricorda di un documento: tipi versione della catena, stato
  // ed estremi di ciascuna azione, ciascuno con il suo "gia' letto".
  TzCacheDocumento = record
    IdObjectFile: Int64;
    TipiVersione: TArray<string>;
    TipiVersioneValida: Boolean;
    Stato: array [TzAzioneDocumento] of TzAzioneDocumentoStato;
    StatoValido: TzAzioniDocumento;
    // Mantis #194 - 2026-09-29: estremi in cache come lo stato
    Estremi: array [TzAzioneDocumento] of string;
    EstremiValidi: TzAzioniDocumento;
  end;

  // Accesso per-azione alla config delle azioni del profilo.
  TzJsonAzioniConfigHelper = record helper for TzJsonAzioniConfig
    function Config(Azione: TzAzioneDocumento): TzJsonAzioneConfig;
    function Abilitata(Azione: TzAzioneDocumento): Boolean;
  end;

  TzDocumentActionsController = class abstract(TComponent)
  public
    // Azioni ammesse dal profilo (gate 1) per l'anteprima report: il profilo
    // arriva dal JSON del template. L'applicazione la implementa delegando al
    // ponte, che interroga OBJ_FILES_PROFILO_AZIONI_GET. Il manager la chiama
    // UNA volta per anteprima (BeforePrint). Default: nessuna azione.
    function AzioniDelProfilo(const Profilo: string): TzJsonAzioniConfig; virtual;

    // Azioni ammesse dal profilo del DOCUMENTO GIA' PERSISTITO (gate 1) per
    // viewer e registri, che conoscono l'ID_OBJECT_FILE e non il profilo:
    // l'applicazione delega al ponte, che interroga
    // OBJ_FILES_DOCUMENTO_AZIONI_GET (risolve la radice della catena).
    // Il chiamante la interroga una volta per documento. Default: nessuna azione.
    function AzioniDelDocumento(const IdObjectFile: Int64): TzJsonAzioniConfig; virtual;

    // Persistenza del documento generato: da file temporaneo a riga OBJ_FILES
    // (versione ORI) + riga OBJ_FILES_GENERAZIONI. Ritorna ID_OBJECT_FILE.
    // Scatta al primo click su un'azione, una volta per sessione di
    // visualizzazione (responsabilita' del manager). Il contesto porta
    // tipologia e profilo da scrivere sulla riga.
    function PersistDocument(const Contesto: TzDocumentoContesto; const TempFileName: string): Int64; virtual; abstract;

    // Gate 2-4 in un'unica risposta, per la UI.
    function Stato(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato; virtual; abstract;
    function MotivoBlocco(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string; virtual;
    function Estremi(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string; virtual; // '1234/2026 del 14/07/2026'

    // Esecuzione: RIVERIFICA le precondizioni (EzAzioneDocumentoBloccata se
    // violate). Unico punto di passaggio per viewer, batch e chiamate
    // applicative dirette: il disable a video non e' una barriera.
    procedure Esegui(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto); virtual; abstract;

    // Interroga il fornitore per le azioni asincrone (firma in attesa,
    // ricevute PEC, esito versamento). Default: no-op.
    procedure AggiornaStato(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto); virtual;

    // Butta via lo stato memorizzato del documento corrente (default: no-op;
    // la base con cache la ridefinisce).
    procedure InvalidaCacheDocumento; virtual;
  end;

  // Base con la logica comune implementata una volta per tutte:
  // il template method di Stato (gate 1-4), la valutazione delle
  // precondizioni di catena e la cache per documento. All'applicazione
  // restano due sole domande: quali TIPO_VERSIONE esistono nella catena, e
  // se l'utente ha il permesso.
  TzDocumentActionsControllerBase = class(TzDocumentActionsController)
  public const
    // documenti ricordati insieme: oltre, si scarta il meno recente
    MassimoDocumentiInCache = 8;
  private
    // cache degli ultimi documenti (vedi nota di testa): il piu' recente per
    // primo, al massimo MassimoDocumentiInCache voci
    FCache: TArray<TzCacheDocumento>;

    // indice nella cache del documento chiesto (sempre 0: lo porta in testa);
    // se manca, ne crea una voce vuota e scarta la meno recente oltre il tetto
    function IndiceCacheDelDocumento(IdObjectFile: Int64): Integer;
  private
    FOnAzioneAmmessa: TzAzioneAmmessaFunc;

    // gate 3 completo: precondizioni di catena (virtuali, l'applicazione puo'
    // sovrascriverle) piu' la regola applicativa sul soggetto. Un solo punto,
    // usato sia da Stato che da MotivoBlocco.
    function PrecondizioniComplete(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto; out Motivo: string): Boolean;
  protected
    // le due sole cose che la base chiede all'applicazione
    function TipiVersioneInCatena(IdObjectFile: Int64): TArray<string>; virtual; abstract;
    function PermessoConcesso(Azione: TzAzioneDocumento): Boolean; virtual; abstract;

    // gate 4 (registrazioni dei motori): default adsDisponibile; l'applicazione
    // lo sovrascrive leggendo l'ultima registrazione non annullata della catena
    // e mappandola con StatoAzioneDaRegistrazione. NB: la base lo chiama
    // tramite la cache, quindi una volta per azione e per documento.
    function StatoRegistrazione(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato; virtual;

    // estremi dell'ultima registrazione dell'azione ('1234/2026 del
    // 14/07/2026'): default vuoto; l'applicazione lo sovrascrive leggendoli dal
    // motore. Come StatoRegistrazione la base lo chiama tramite la cache, una
    // volta per azione e per documento.
    function EstremiRegistrazione(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string; virtual;

    // implementate qui, una volta per tutte, sulla config passata nel contesto
    function AzioneAbilitataDaProfilo(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): Boolean;
    // virtuale: l'applicazione puo' estendere la semantica di "RICHIEDE" per i
    // tipi soddisfatti da una registrazione anziche' da una versione (es. 'PRO'
    // con strategia C: protocollazione confermata ma nessuna versione PRO in
    // catena), o arricchire il motivo con lo stato dell'azione a monte
    // ("in attesa della firma, inviata il 12/07")
    function PrecondizioniSoddisfatte(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto; out Motivo: string): Boolean; virtual;
    function VersioneOperativa(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
    function Engine(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;

    // i tipi versione della catena, dalla cache del documento corrente
    function TipiVersioneInCatenaDaCache(IdObjectFile: Int64): TArray<string>;

    // da chiamare in testa a Esegui dell'implementazione applicativa:
    // solleva EzAzioneDocumentoBloccata se l'azione non e' eseguibile adesso
    // (bloccata, in corso, o gia' completata e non ripetibile)
    procedure VerificaEseguibile(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto);
  public
    constructor Create(AOwner: TComponent); override;

    function Stato(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato; override;
    function MotivoBlocco(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string; override;
    function Estremi(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string; override;

    // da chiamare dopo ogni azione che cambia lo stato del documento
    // (i controller applicativi la richiamano in coda a Esegui/AggiornaStato)
    procedure InvalidaCacheDocumento; override;
  public
    property OnAzioneAmmessa: TzAzioneAmmessaFunc read FOnAzioneAmmessa write FOnAzioneAmmessa;
  end;

  // Caption per la UI (bottoni, log, messaggi).
function DescrizioneAzioneDocumento(Azione: TzAzioneDocumento): string;

// Descrizione parlante di un TIPO_VERSIONE, per i motivi di blocco.
function DescrizioneTipoVersione(const TipoVersione: string): string;

// Firma e Protocolla si eseguono una volta sola per catena (completate
// diventano "Vedi estremi"); Conserva, Invia PEC e Invia Mail restano
// eseguibili mostrando l'ultimo esito.
function AzioneRipetibile(Azione: TzAzioneDocumento): Boolean;

// Mappa lo stato dell'ultima registrazione non annullata del motore sullo
// stato dell'azione (gate 4). StatoRegistrazione = '' significa "nessuna
// registrazione" -> adsDisponibile. Gli stati sono quelli dei domini
// OBJ_FILES_<MOTORE>_STATO:
// adFirma       I/A/D in corso, F completata, R/S riproponibile
// adProtocolla  P/A in corso, K completata, E/X riproponibile
// adConserva    INS/GEN/INV in corso, ACC/CON completata, RIF/ANN riproponibile
// adInviaPec    P/I/A in corso, C completata, E/X riproponibile
// adInviaMail   sempre disponibile (nessuna registrazione)
// Riferimento: analisi_controlli_base_e_azioni_preview.md §4.3.
function StatoAzioneDaRegistrazione(Azione: TzAzioneDocumento; const StatoRegistrazione: string): TzAzioneDocumentoStato;

implementation

function DescrizioneAzioneDocumento(Azione: TzAzioneDocumento): string;
begin
  case Azione of
    adFirma:
      result := 'Firma';
    adProtocolla:
      result := 'Protocolla';
    adConserva:
      result := 'Conserva';
    adInviaPec:
      result := 'Invia PEC';
    adInviaMail:
      result := 'Invia Mail';
  else
    result := '';
  end;
end;

function DescrizioneTipoVersione(const TipoVersione: string): string;
begin
  if SameText(TipoVersione, 'ORI') then
    result := 'la generazione del documento'
  else
    if SameText(TipoVersione, 'FIR') then
      result := 'la firma'
    else
      if SameText(TipoVersione, 'PRO') then
        result := 'la protocollazione'
      else
        if SameText(TipoVersione, 'STA') then
          result := 'la versione per lo stampatore'
        else
          if SameText(TipoVersione, 'PEC') then
            result := 'la trasmissione PEC'
          else
            if SameText(TipoVersione, 'RIC') then
              result := 'la ricevuta'
            else
              result := 'la versione ' + TipoVersione;
end;

function AzioneRipetibile(Azione: TzAzioneDocumento): Boolean;
begin
  result := Azione in [adConserva, adInviaPec, adInviaMail];
end;

function StatoAzioneDaRegistrazione(Azione: TzAzioneDocumento; const StatoRegistrazione: string): TzAzioneDocumentoStato;
var
  Stato: string;

  function InElenco(const Valori: array of string): Boolean;
  var
    valore: string;
  begin
    result := False;
    for valore in Valori do
      if SameText(Stato, valore) then
        exit(True);
  end;

begin
  result := adsDisponibile;
  Stato := StatoRegistrazione.Trim;

  // nessuna registrazione, o azione senza registrazioni (Invia Mail)
  if Stato.IsEmpty or (Azione = adInviaMail) then
    exit;

  case Azione of
    adFirma:
      if InElenco(['I', 'A', 'D']) then
        result := adsInCorso
      else
        if InElenco(['F']) then
          result := adsCompletata;
    // R (respinta) / S (scaduta): riproponibile -> adsDisponibile

    adProtocolla:
      if InElenco(['P', 'A']) then
        result := adsInCorso
      else
        if InElenco(['K']) then
          result := adsCompletata;
    // E (errore, ritentabile) / X (annullata) -> adsDisponibile

    adConserva:
      if InElenco(['INS', 'GEN', 'INV']) then
        result := adsInCorso
      else
        if InElenco(['ACC', 'CON']) then
          result := adsCompletata;
    // RIF (rifiutato) / ANN (annullato) -> adsDisponibile

    adInviaPec:
      if InElenco(['P', 'I', 'A']) then
        result := adsInCorso
      else
        if InElenco(['C']) then
          result := adsCompletata;
    // E (errore/mancata consegna) / X (annullata) -> adsDisponibile
  end;
end;

{ TzDocumentoContesto }

procedure TzDocumentoContesto.Clear;
begin
  Self := Default (TzDocumentoContesto);
end;

{ TzJsonAzioniConfigHelper }

function TzJsonAzioniConfigHelper.Config(Azione: TzAzioneDocumento): TzJsonAzioneConfig;
begin
  case Azione of
    adFirma:
      result := Firma;
    adProtocolla:
      result := Protocollo;
    adConserva:
      result := Conservazione;
    adInviaPec:
      result := InviaPec;
    adInviaMail:
      result := InviaMail;
  else
    result := Default (TzJsonAzioneConfig);
  end;
end;

function TzJsonAzioniConfigHelper.Abilitata(Azione: TzAzioneDocumento): Boolean;
var
  azioneConfig: TzJsonAzioneConfig;
begin
  azioneConfig := Config(Azione);
  result := azioneConfig.IsPresent and azioneConfig.Enabled;
end;

{ TzDocumentActionsController }

function TzDocumentActionsController.AzioniDelProfilo(const Profilo: string): TzJsonAzioniConfig;
begin
  // default: nessuna azione; l'applicazione la implementa delegando al ponte
  result.Clear;
end;

function TzDocumentActionsController.AzioniDelDocumento(const IdObjectFile: Int64): TzJsonAzioniConfig;
begin
  // default: nessuna azione; l'applicazione la implementa delegando al ponte
  result.Clear;
end;

function TzDocumentActionsController.MotivoBlocco(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
begin
  result := '';
end;

function TzDocumentActionsController.Estremi(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
begin
  result := '';
end;

procedure TzDocumentActionsController.AggiornaStato(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto);
begin
  // default: nessuna azione asincrona da interrogare
end;

procedure TzDocumentActionsController.InvalidaCacheDocumento;
begin
  // default: nessuno stato memorizzato
end;

{ TzDocumentActionsControllerBase }

constructor TzDocumentActionsControllerBase.Create(AOwner: TComponent);
begin
  inherited;
  FOnAzioneAmmessa := nil;
  FCache := nil;
end;

procedure TzDocumentActionsControllerBase.InvalidaCacheDocumento;
begin
  // dopo un'azione o prima di eseguirla non ci si fida di nessun documento
  FCache := nil;
end;

function TzDocumentActionsControllerBase.IndiceCacheDelDocumento(IdObjectFile: Int64): Integer;
var
  indice: Integer;
  spostamento: Integer;
  voce: TzCacheDocumento;
begin
  // Mantis #210 - 2026-10-05: una voce per documento. Con la cache a un solo
  // documento due documenti valutati in alternanza si azzeravano a vicenda e
  // ogni idle rifaceva tutte le letture
  for indice := 0 to High(FCache) do
    if FCache[indice].IdObjectFile = IdObjectFile then
    begin
      // il piu' recente va in testa, cosi' in fondo resta il meno usato
      if indice > 0 then
      begin
        voce := FCache[indice];
        for spostamento := indice downto 1 do
          FCache[spostamento] := FCache[spostamento - 1];
        FCache[0] := voce;
      end;
      exit(0);
    end;

  // documento nuovo: voce vuota in testa, la meno recente esce oltre il tetto
  if Length(FCache) < MassimoDocumentiInCache then
    SetLength(FCache, Length(FCache) + 1);
  for indice := High(FCache) downto 1 do
    FCache[indice] := FCache[indice - 1];
  FCache[0] := Default(TzCacheDocumento);
  FCache[0].IdObjectFile := IdObjectFile;
  result := 0;
end;

function TzDocumentActionsControllerBase.TipiVersioneInCatenaDaCache(IdObjectFile: Int64): TArray<string>;
var
  indice: Integer;
  tipiLetti: TArray<string>;
begin
  if IdObjectFile = 0 then
    exit(nil);

  indice := IndiceCacheDelDocumento(IdObjectFile);

  if not FCache[indice].TipiVersioneValida then
  begin
    // si legge prima in una variabile: la lettura puo' passare da codice che
    // invalida la cache, e FCache[indice] non sarebbe piu' valido
    tipiLetti := TipiVersioneInCatena(IdObjectFile);
    indice := IndiceCacheDelDocumento(IdObjectFile);
    FCache[indice].TipiVersione := tipiLetti;
    FCache[indice].TipiVersioneValida := True;
  end;

  result := FCache[indice].TipiVersione;
end;

function TzDocumentActionsControllerBase.AzioneAbilitataDaProfilo(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): Boolean;
begin
  result := Contesto.AzioniConfig.Abilitata(Azione);
end;

function TzDocumentActionsControllerBase.PrecondizioniSoddisfatte(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto; out Motivo: string): Boolean;
var
  azioneConfig: TzJsonAzioneConfig;
  tipiInCatena: TArray<string>;
  tipoRichiesto: string;
  tipoPresente: string;
  trovato: Boolean;
  mancanti: string;
begin
  Motivo := '';
  azioneConfig := Contesto.AzioniConfig.Config(Azione);

  // nessuna precondizione dichiarata
  if Length(azioneConfig.Richiede) = 0 then
    exit(True);

  // il documento non e' ancora stato persistito: nessuna catena da verificare
  if Contesto.IdObjectFile = 0 then
  begin
    Motivo := Format('%s disponibile solo dopo %s', [DescrizioneAzioneDocumento(Azione), DescrizioneTipoVersione(azioneConfig.Richiede[0])]);
    exit(False);
  end;

  tipiInCatena := TipiVersioneInCatenaDaCache(Contesto.IdObjectFile);

  mancanti := '';
  for tipoRichiesto in azioneConfig.Richiede do
  begin
    trovato := False;
    for tipoPresente in tipiInCatena do
      if SameText(tipoPresente, tipoRichiesto) then
      begin
        trovato := True;
        break;
      end;
    if not trovato then
    begin
      if not mancanti.IsEmpty then
        mancanti := mancanti + ' e ';
      mancanti := mancanti + DescrizioneTipoVersione(tipoRichiesto);
    end;
  end;

  result := mancanti.IsEmpty;
  if not result then
    Motivo := Format('%s disponibile solo dopo %s', [DescrizioneAzioneDocumento(Azione), mancanti]);
end;

function TzDocumentActionsControllerBase.VersioneOperativa(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
begin
  result := Contesto.AzioniConfig.Config(Azione).VersioneOperativa;
end;

function TzDocumentActionsControllerBase.Engine(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
begin
  result := Contesto.AzioniConfig.Config(Azione).Engine;
end;

function TzDocumentActionsControllerBase.StatoRegistrazione(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato;
begin
  result := adsDisponibile;
end;

function TzDocumentActionsControllerBase.EstremiRegistrazione(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
begin
  result := '';
end;

function TzDocumentActionsControllerBase.Estremi(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
var
  indice: Integer;
  estremiLetti: string;
begin
  // Mantis #194 - 2026-09-29: dalla cache, come lo stato. Con un'azione
  // completata l'OnUpdate del bottone li chiede a ogni idle: senza cache ogni
  // idle era una lettura sul database.
  // Documento non ancora persistito: niente da memorizzare, si chiede e basta
  if Contesto.IdObjectFile = 0 then
    exit(EstremiRegistrazione(Azione, Contesto));

  indice := IndiceCacheDelDocumento(Contesto.IdObjectFile);

  if not(Azione in FCache[indice].EstremiValidi) then
  begin
    estremiLetti := EstremiRegistrazione(Azione, Contesto);
    indice := IndiceCacheDelDocumento(Contesto.IdObjectFile);
    FCache[indice].Estremi[Azione] := estremiLetti;
    Include(FCache[indice].EstremiValidi, Azione);
  end;

  result := FCache[indice].Estremi[Azione];
end;

function TzDocumentActionsControllerBase.Stato(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato;
var
  Motivo: string;
  indice: Integer;
  statoLetto: TzAzioneDocumentoStato;
begin
  // gate 1: capacita' del profilo documentale
  if not AzioneAbilitataDaProfilo(Azione, Contesto) then
    exit(adsNonDisponibile);

  // gate 2: permesso dell'utente
  if not PermessoConcesso(Azione) then
    exit(adsNonDisponibile);

  // gate 3: precondizioni di catena piu' la regola dell'applicazione
  if not PrecondizioniComplete(Azione, Contesto, Motivo) then
    exit(adsBloccata);

  // gate 4: stato delle registrazioni (in corso / completata), dalla cache:
  // l'OnUpdate delle Action ripassa di qui a ogni idle
  indice := IndiceCacheDelDocumento(Contesto.IdObjectFile);

  if not(Azione in FCache[indice].StatoValido) then
  begin
    statoLetto := StatoRegistrazione(Azione, Contesto);
    indice := IndiceCacheDelDocumento(Contesto.IdObjectFile);
    FCache[indice].Stato[Azione] := statoLetto;
    Include(FCache[indice].StatoValido, Azione);
  end;

  result := FCache[indice].Stato[Azione];
end;

function TzDocumentActionsControllerBase.MotivoBlocco(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): string;
begin
  // stessa valutazione di Stato: il testo mostrato deve spiegare esattamente
  // il motivo per cui il bottone e' disabilitato
  PrecondizioniComplete(Azione, Contesto, result);
end;

function TzDocumentActionsControllerBase.PrecondizioniComplete(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto; out Motivo: string): Boolean;
begin
  result := PrecondizioniSoddisfatte(Azione, Contesto, Motivo);
  if not result then
    exit;

  if assigned(FOnAzioneAmmessa) then
    result := FOnAzioneAmmessa(Azione, Contesto, Motivo);
end;

procedure TzDocumentActionsControllerBase.VerificaEseguibile(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto);
var
  statoAzione: TzAzioneDocumentoStato;
  Motivo: string;
begin
  // stato fresco: l'esecuzione non si fida di quanto mostrato a video
  InvalidaCacheDocumento;

  statoAzione := Stato(Azione, Contesto);

  case statoAzione of
    adsNonDisponibile, adsBloccata:
      begin
        Motivo := MotivoBlocco(Azione, Contesto);
        if Motivo.IsEmpty then
          Motivo := Format('L''azione %s non e'' disponibile per questo documento', [DescrizioneAzioneDocumento(Azione)]);
        raise EzAzioneDocumentoBloccata.Create(Motivo);
      end;

    adsInCorso:
      raise EzAzioneDocumentoBloccata.CreateFmt('L''azione %s e'' gia'' in corso: attendere l''esito o usare "Aggiorna stato"', [DescrizioneAzioneDocumento(Azione)]);

    adsCompletata:
      if not AzioneRipetibile(Azione) then
      begin
        Motivo := Estremi(Azione, Contesto);
        if Motivo.IsEmpty then
          raise EzAzioneDocumentoBloccata.CreateFmt('L''azione %s e'' gia'' stata eseguita per questo documento', [DescrizioneAzioneDocumento(Azione)])
        else
          raise EzAzioneDocumentoBloccata.CreateFmt('L''azione %s e'' gia'' stata eseguita per questo documento (%s)', [DescrizioneAzioneDocumento(Azione), Motivo]);
      end;
  end;
end;

end.
