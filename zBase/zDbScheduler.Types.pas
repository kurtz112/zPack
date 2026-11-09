// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-12
// ---------------------------------------------------------------------------
unit zDbScheduler.Types;

// Contratti del calendario TzDbScheduler, astratti dallo schema che Gesty e
// WinTarif usano oggi con TFrameScheduler e dmScheduler.Tools.
//
// Lo schema reale (verificato sui sorgenti il 2026-10-01):
// - il modulo dati possiede il TcxSchedulerDBStorage, imposta il periodo nei
//   parametri della procedura (DAL_GIORNO, AL_GIORNO e i propri) e lo riapre:
//   e' l'interfaccia ISchedulerStorage, qui IzSchedulerStorage con gli stessi
//   cinque metodi;
// - il copia/incolla delle ore e' ISchedulerCopyPaste, qui IzSchedulerCopyPaste;
// - gli eventi arrivano da procedure in sola lettura: lo storage non scrive
//   mai (AHandled := True su inserimento, modifica, eliminazione) e ogni
//   operazione passa dal gestore del tipo di evento, riconosciuto dalla colonna
//   SCHEDULER_TIPO_EVENTO (un codice di una lettera) e identificato dalla sua
//   colonna chiave (ID_ORARIO, ID_PRENOTAZIONE, ...). Oggi il tipo e' un
//   enumerato dell'applicazione (TSchedulerTipoEvento) e i gestori sono i rami
//   di TSchedulerTools.ApriEvento/SpostaEvento/EliminaEvento: qui il tipo e' il
//   codice e i gestori stanno nel registro TzSchedulerEvents, che ciascuna
//   applicazione riempie (Gesty.Scheduler.pas, WT.Scheduler.pas).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  System.Actions,
  Vcl.ActnList,
  cxSchedulerStorage,
  cxSchedulerDBStorage,
  cxSchedulerCustomControls,
  cxSchedulerCustomResourceView;

type
  // Codice del tipo di evento, come nella colonna SCHEDULER_TIPO_EVENTO
  TzSchedulerKind = string;
  TzSchedulerKinds = TArray<TzSchedulerKind>;

  // Stessi campi di TSchedulerParams di Gesty e WT
  TzSchedulerParams = record
    Storage: TcxSchedulerDBStorage;
    DalGiorno: TDate;
    AlGiorno: TDate;
    OraInizio: TTime;
    OraFine: TTime;
    AfterRefreshScheduler: TProc;
    procedure SetAfterRefreshScheduler(Proc: TProc);
    procedure Init(aStorage: TcxSchedulerDBStorage);
  end;

  // Stessi metodi di ISchedulerStorage di Gesty e WT; i tipi di evento sono codici
  IzSchedulerStorage = interface
    ['{3E7C1B52-8A44-4C6E-9B0B-6F2D7A1C4E10}']
    procedure InitStorage;
    function GetSchedulerParams: TzSchedulerParams;
    procedure SetPeriodo(DalGiorno: TDate; AlGiorno: TDate);
    procedure RefreshScheduler;
    function TipoEventiPerInserimento: TzSchedulerKinds;
  end;

  // Stessi metodi di ISchedulerCopyPaste di Gesty e WT
  IzSchedulerCopyPaste = interface
    ['{9B5D2F07-1C63-4A8E-8E21-0D4C5B7A3F62}']
    function TipoEventiPerInserimento: TzSchedulerKinds;
    procedure IncollaOra(IdOrigine: Integer; DataDestinazione: TDate; OraDestinazione: TTime; Taglia: Boolean);
    procedure IncollaGiorno(GiornoOrigine, GiornoDestinazione: TDateTime);
    procedure IncollaSettimana(GiornoOrigine, GiornoDestinazione: TDateTime);
    procedure InitActions(CopiaOra, CopiaGiorno, CopiaSettimana, TagliaOra, Incolla: TContainedAction);
  end;

  TzCopiaIncollaKind = (ciNulla, ciTagliaOra, ciCopiaOra, ciCopiaGiorno, ciCopiaSettimana);

  // Come TCopiaIncolla del frame applicativo
  TzCopiaIncolla = record
  private
    FIdOra: Integer;
    FData: TDateTime;
  public
    Tipo: TzCopiaIncollaKind;
    Enabled: Boolean;
    procedure Reset;
    procedure TagliaOra(Id: Integer);
    procedure CopiaOra(Id: Integer);
    procedure CopiaGiorno(Giorno: TDateTime);
    procedure CopiaSettimana(Giorno: TDateTime);
    property IdOra: Integer read FIdOra;
    property Data: TDateTime read FData;
  end;

  // Parametri di un'operazione su un evento: la parte comune di TEventoParams
  // di Gesty e WT. ResourceFieldName e' il campo risorsa dello storage
  // (AULA, TIPO_PRENOTAZIONE, ID_DOCENTE...): il gestore dell'applicazione
  // decide in quale campo suo copiare ResourceID.
  TzSchedulerEventParams = record
  private
    FDurata: Integer;
    FOraFine: TTime;
    procedure SetDurata(const Value: Integer);
    procedure SetOraFine(const Value: TTime);
  public
    Kind: TzSchedulerKind;
    ReadOnly: Boolean;
    Id: Integer;
    Data: TDate;
    OraInizio: TTime;
    ResourceID: Variant;
    ResourceFieldName: string;
    FieldName1: string;
    Value1: Variant;
    FieldName2: string;
    Value2: Variant;
    FieldName3: string;
    Value3: Variant;
    FieldName4: string;
    Value4: Variant;
    FieldName5: string;
    Value5: Variant;
    procedure Init;
    // Durata calcola OraFine e viceversa, a partire da OraInizio: va quindi
    // impostata dopo OraInizio. La mezzanotte (OraInizio = 0) vale come ora
    // vera: un evento nuovo dalla vista mese parte alle 00:00 e finisce dopo
    // Durata minuti, come in TEventoParams di Gesty e WT. I ponti
    // (Gesty.Scheduler, WT.Scheduler) passano OraInizio e Durata, non OraFine.
    // Un evento non passa la mezzanotte: il frame limita la durata con
    // TzSchedulerCalcoli.DurataEntroLaGiornata.
    property Durata: Integer read FDurata write SetDurata;
    property OraFine: TTime read FOraFine write SetOraFine;
  end;

  TzSchedulerEventFunc = reference to function(const Params: TzSchedulerEventParams): Boolean;
  TzSchedulerEventImagesProc = reference to procedure(Event: TcxSchedulerControlEvent; Images: TcxSchedulerEventImages);

  // Un tipo di evento registrato dall'applicazione
  TzSchedulerEventKind = class
  private
    FCode: TzSchedulerKind;
    FDescription: string;
    FNewCaption: string;
    FIdFieldName: string;
    FNewImageIndex: Integer;
    FEventImageIndex: Integer;
    FDefaultDuration: Integer;
    FIntersectionAllowed: Boolean;
    FInsertKind: TzSchedulerKind;
    FApri: TzSchedulerEventFunc;
    FSposta: TzSchedulerEventFunc;
    FElimina: TzSchedulerEventFunc;
    FInitEventImages: TzSchedulerEventImagesProc;
  public
    constructor Create(const Code: TzSchedulerKind);
    property Code: TzSchedulerKind read FCode;
    property Description: string read FDescription write FDescription;
    // Didascalia dell'azione di inserimento ("Nuova Lezione"); vuota = "Nuovo " + Description
    property NewCaption: string read FNewCaption write FNewCaption;
    // Colonna con la chiave del record del tipo (ID_ORARIO, ID_PRENOTAZIONE...)
    property IdFieldName: string read FIdFieldName write FIdFieldName;
    // Indici nella ImageList del frame e nelle icone degli eventi; -1 = nessuna
    property NewImageIndex: Integer read FNewImageIndex write FNewImageIndex;
    property EventImageIndex: Integer read FEventImageIndex write FEventImageIndex;
    // Durata in minuti proposta al nuovo evento
    property DefaultDuration: Integer read FDefaultDuration write FDefaultDuration;
    // Come TSchedulerTipoEvento.CanIntersect: due eventi si sovrappongono se
    // almeno uno dei due tipi lo ammette
    property IntersectionAllowed: Boolean read FIntersectionAllowed write FIntersectionAllowed;
    // Tipo dell'evento che l'azione di inserimento di questo tipo apre davvero;
    // vuoto = questo stesso. Serve a conservare comportamenti esistenti (in
    // Gesty "Nuova Lezione" apre un rilevamento ore)
    property InsertKind: TzSchedulerKind read FInsertKind write FInsertKind;
    property Apri: TzSchedulerEventFunc read FApri write FApri;
    property Sposta: TzSchedulerEventFunc read FSposta write FSposta;
    property Elimina: TzSchedulerEventFunc read FElimina write FElimina;
    // Icone calcolate dai campi dell'evento (WT); se assente vale EventImageIndex
    property InitEventImages: TzSchedulerEventImagesProc read FInitEventImages write FInitEventImages;
  end;

  // Registro dei tipi di evento. L'applicazione lo riempie una volta, nella
  // initialization della sua unit ponte; il frame lo consulta a ogni operazione.
  TzSchedulerEvents = class
  private
    class var FKinds: TObjectDictionary<string, TzSchedulerEventKind>;
    class var FOrder: TList<string>;
    class var FExportProc: TProc<TObject>;
    class constructor Create;
    class destructor Destroy;
  public
    // Registra (o riprende, se gia' registrato) il tipo con quel codice
    class function Register(const Code: TzSchedulerKind; const Description, IdFieldName: string): TzSchedulerEventKind; static;
    class function Find(const Code: TzSchedulerKind): TzSchedulerEventKind; static;
    class function Kinds: TArray<TzSchedulerEventKind>; static;
    class function CanIntersect(const Code1, Code2: TzSchedulerKind): Boolean; static;
    class function Apri(const Params: TzSchedulerEventParams): Boolean; static;
    class function Sposta(const Params: TzSchedulerEventParams): Boolean; static;
    class function Elimina(const Params: TzSchedulerEventParams): Boolean; static;
    // Esportazione dell'applicazione (Gesty: Excel o CSV per Google e Outlook);
    // il parametro e' il TcxScheduler. Vuota = esportazione Excel del frame
    class property ExportProc: TProc<TObject> read FExportProc write FExportProc;
  end;

  // Aggancio di uno storage allo schema delegato, come TSchedulerTools.InitStorage:
  // nessuna scrittura dallo storage, sovrapposizioni decise dal registro,
  // campi della procedura e campi personalizzati dei tipi registrati.
  // Serve ai consumatori nuovi: quelli esistenti continuano a chiamare il loro
  // SchedulerTools.InitStorage.
  TzSchedulerStorageBinder = class
  private
    class var FInstance: TzSchedulerStorageBinder;
    procedure StorageEventHandled(Sender: TObject; AEvent: TcxSchedulerEvent; var AHandled: Boolean);
    procedure StorageEventIntersect(Sender: TcxCustomSchedulerStorage; AEvent1, AEvent2: TcxSchedulerEvent; var Allow: Boolean);
    class destructor Destroy;
  public
    class procedure InitDelegated(Storage: TcxSchedulerDBStorage; const ExtraCustomFields: array of string); static;
  end;

  // Calcoli del calendario TzDbScheduler senza il TcxScheduler: il frame li
  // chiama con i valori del componente, i test con valori fissi.
  TzSchedulerCalcoli = class
  public const
    // ultimo minuto del giorno: lo stesso valore dei .dfm (23:59)
    FineGiornata = 0.9993055555555556;
    MezzOra = 1 / 48;
    // giorni letti in piu' prima e dopo le settimane visibili
    GiorniDiMargine = 7;
  public
    // Momento del nuovo evento (Mantis Gesty #197). Vale il punto cliccato
    // (HitTest.Time) solo se il clic e' su una cella con data e ora
    // (HitTest.HitAtTime) e la data e' valida; altrimenti la cella
    // selezionata (SelStart). False se nemmeno questa porta una data: il
    // calendario non apre nessun evento.
    class function MomentoNuovoEvento(const HitAtTime: Boolean; const HitTime, SelStart: TDateTime;
      out Momento: TDateTime): Boolean; static;

    // Periodo da chiedere al dataset per i giorni visibili DalGiorno..AlGiorno:
    // dall'inizio della settimana del primo meno GiorniDiMargine alla fine
    // della settimana dell'ultimo piu' GiorniDiMargine (settimane da lunedi'
    // a domenica, come StartOfTheWeek). True se il dataset va riletto: False
    // solo quando un periodo gia' letto (PeriodoValido, dataset aperto)
    // contiene tutto quello nuovo, cosi' lo scorrimento vicino non rilegge.
    class function PeriodoDaLeggere(const DalGiorno, AlGiorno: TDateTime; const PeriodoValido, DataSetAttivo: Boolean;
      const PeriodoDal, PeriodoAl: TDateTime; out Dal, Al: TDateTime): Boolean; static;

    // Allarga la fascia oraria visibile (Inizio..Fine, frazioni di giorno) a
    // un evento caricato, perche' con WorkTimeOnly non sparisca dalla vista
    // giorno. Gli eventi di un giorno intero non contano; un evento che
    // finisce a mezzanotte del giorno dopo arriva a FineGiornata; un evento
    // di piu' giorni chiede la giornata intera.
    class procedure AllargaFasciaAllEvento(var Inizio, Fine: Double; const InizioEvento, FineEvento: TDateTime;
      const GiornoIntero: Boolean); static;

    // Porta la fascia a mezz'ore intere, come le celle del calendario:
    // l'inizio alla mezz'ora precedente, la fine alla successiva, mai oltre
    // FineGiornata.
    class procedure ArrotondaFasciaAMezzOre(var Inizio, Fine: Double); static;

    // Eventi entro la giornata (R-087). Le tabelle dei calendari di Gesty e WT
    // hanno una data e due ore, e i loro vincoli rifiutano una fine prima
    // dell'inizio: un evento non puo' passare la mezzanotte. La fine di
    // giornata si scrive 23:59, mai 00:00: la funzione MINUTES_BETWEEN dei due
    // database conta 23:59 come la mezzanotte (un minuto in piu') e 00:00 come
    // durata zero, e AGENDA e RISORSE_ATTIVITA_FUORI_SEDE non ammettono 00:00.

    // True se un evento che parte a OraInizio e dura Durata minuti finisce
    // dopo la mezzanotte; alle 24:00 esatte no.
    class function SuperaLaMezzanotte(const OraInizio: TTime; const Durata: Integer): Boolean; static;

    // Durata ridotta perche' la fine non passi FineGiornata (23:59); una fine
    // alle 24:00 esatte diventa 23:59.
    class function DurataEntroLaGiornata(const OraInizio: TTime; const Durata: Integer): Integer; static;

    // Durata in minuti di un evento caricato, con la regola del database: una
    // fine alle 23:59 vale come mezzanotte, e una fine prima dell'inizio nello
    // stesso giorno (le 00:00 che PRENOTAZIONI e AULE_PRENOTAZIONI ammettono)
    // e' la mezzanotte di fine giornata.
    class function DurataEvento(const Inizio, Fine: TDateTime): Integer; static;
  end;

const
  zSchedulerKindField = 'SCHEDULER_TIPO_EVENTO';
  zSchedulerEditableField = 'MODIFICABILE';
  zSchedulerColorField = 'COLORE';
  zSchedulerHintField = 'CORPO_EVENTO';

// Valore di un campo personalizzato senza eccezioni: GetCustomFieldValueByName
// solleva EcxScheduler se il campo non e' dichiarato nello storage (prova A6)
function SchedulerEventValue(Event: TcxSchedulerEvent; const FieldName: string): Variant;

implementation

uses
  System.DateUtils;

function SchedulerEventValue(Event: TcxSchedulerEvent; const FieldName: string): Variant;
begin
  result := Null;

  if not Assigned(Event) then
    Exit;

  try
    result := Event.GetCustomFieldValueByName(FieldName);
  except
    on Exception do
      result := Null;
  end;
end;

{ TzSchedulerParams }

procedure TzSchedulerParams.Init(aStorage: TcxSchedulerDBStorage);
begin
  Storage := aStorage;
  DalGiorno := 0;
  AlGiorno := 0;
  OraInizio := 0;
  OraFine := 0;
  AfterRefreshScheduler := nil;
end;

procedure TzSchedulerParams.SetAfterRefreshScheduler(Proc: TProc);
begin
  AfterRefreshScheduler := Proc;
end;

{ TzCopiaIncolla }

procedure TzCopiaIncolla.Reset;
begin
  FIdOra := -1;
  FData := 0;
  Tipo := ciNulla;
end;

procedure TzCopiaIncolla.TagliaOra(Id: Integer);
begin
  Reset;
  Tipo := ciTagliaOra;
  FIdOra := Id;
end;

procedure TzCopiaIncolla.CopiaOra(Id: Integer);
begin
  Reset;
  Tipo := ciCopiaOra;
  FIdOra := Id;
end;

procedure TzCopiaIncolla.CopiaGiorno(Giorno: TDateTime);
begin
  Reset;
  Tipo := ciCopiaGiorno;
  FData := Giorno;
end;

procedure TzCopiaIncolla.CopiaSettimana(Giorno: TDateTime);
begin
  Reset;
  Tipo := ciCopiaSettimana;
  FData := Giorno;
end;

{ TzSchedulerEventParams }

procedure TzSchedulerEventParams.Init;
begin
  Kind := '';
  ReadOnly := False;
  Id := -1;
  Data := 0;
  OraInizio := 0;
  FOraFine := 0;
  FDurata := 0;
  ResourceID := Null;
  ResourceFieldName := '';
  FieldName1 := '';
  Value1 := Null;
  FieldName2 := '';
  Value2 := Null;
  FieldName3 := '';
  Value3 := Null;
  FieldName4 := '';
  Value4 := Null;
  FieldName5 := '';
  Value5 := Null;
end;

procedure TzSchedulerEventParams.SetDurata(const Value: Integer);
begin
  FDurata := Value;

  // la mezzanotte (OraInizio = 0) e' un'ora vera: prima OraFine restava 0
  FOraFine := IncMinute(OraInizio, FDurata);
end;

procedure TzSchedulerEventParams.SetOraFine(const Value: TTime);
begin
  FOraFine := Value;

  // stessa regola di SetDurata: anche da mezzanotte la durata si calcola
  FDurata := MinutesBetween(OraInizio, FOraFine);
end;

{ TzSchedulerCalcoli }

class function TzSchedulerCalcoli.MomentoNuovoEvento(const HitAtTime: Boolean; const HitTime, SelStart: TDateTime;
  out Momento: TDateTime): Boolean;
begin
  // fuori dalle celle che portano una data (intestazione della risorsa,
  // angolo sopra il righello, sfondo) HitTime vale NullDate (-700000); sul
  // righello porta la sola ora
  Momento := HitTime;

  if not HitAtTime or (Trunc(Momento) <= 0) then
    Momento := SelStart;

  result := Trunc(Momento) > 0;
end;

class function TzSchedulerCalcoli.PeriodoDaLeggere(const DalGiorno, AlGiorno: TDateTime;
  const PeriodoValido, DataSetAttivo: Boolean; const PeriodoDal, PeriodoAl: TDateTime; out Dal, Al: TDateTime): Boolean;
begin
  Dal := IncDay(StartOfTheWeek(DalGiorno), -GiorniDiMargine);
  Al := IncDay(EndOfTheWeek(AlGiorno), GiorniDiMargine);

  result := not (PeriodoValido and DataSetAttivo and (Dal >= PeriodoDal) and (Al <= PeriodoAl));
end;

class procedure TzSchedulerCalcoli.AllargaFasciaAllEvento(var Inizio, Fine: Double;
  const InizioEvento, FineEvento: TDateTime; const GiornoIntero: Boolean);
var
  OraInizioEvento, OraFineEvento: Double;
begin
  if GiornoIntero then
    Exit;

  OraInizioEvento := Frac(InizioEvento);

  if Trunc(FineEvento) = Trunc(InizioEvento) then
    OraFineEvento := Frac(FineEvento)
  else
    if (Trunc(FineEvento) = Trunc(InizioEvento) + 1) and (Frac(FineEvento) = 0) then
      // finisce a mezzanotte
      OraFineEvento := FineGiornata
    else
    begin
      // evento di piu' giorni: serve la giornata intera
      OraInizioEvento := 0;
      OraFineEvento := FineGiornata;
    end;

  if OraInizioEvento < Inizio then
    Inizio := OraInizioEvento;

  if OraFineEvento > Fine then
    Fine := OraFineEvento;
end;

class procedure TzSchedulerCalcoli.ArrotondaFasciaAMezzOre(var Inizio, Fine: Double);
begin
  // il margine 1E-9 assorbe l'errore di rappresentazione delle mezz'ore
  // esatte: 08:30 resta 08:30 invece di scendere alle 08:00
  Inizio := Trunc(Inizio / MezzOra + 1E-9) * MezzOra;

  if Frac(Fine / MezzOra - 1E-9) > 0 then
    Fine := (Trunc(Fine / MezzOra - 1E-9) + 1) * MezzOra;

  if Fine > FineGiornata then
    Fine := FineGiornata;
end;

// minuti dalla mezzanotte, arrotondati: 23:30 letta da un campo TIME puo'
// valere 23:29:59.999
function MinutiDelGiorno(const Ora: TDateTime): Integer;
begin
  result := Round(Frac(Ora) * MinsPerDay);
end;

class function TzSchedulerCalcoli.SuperaLaMezzanotte(const OraInizio: TTime; const Durata: Integer): Boolean;
begin
  result := MinutiDelGiorno(OraInizio) + Durata > MinsPerDay;
end;

class function TzSchedulerCalcoli.DurataEntroLaGiornata(const OraInizio: TTime; const Durata: Integer): Integer;
var
  MinutiInizio: Integer;
begin
  MinutiInizio := MinutiDelGiorno(OraInizio);

  if MinutiInizio + Durata < MinsPerDay then
    result := Durata
  else
  begin
    // fine alle 23:59
    result := MinsPerDay - 1 - MinutiInizio;
    if result < 0 then
      result := 0;
  end;
end;

class function TzSchedulerCalcoli.DurataEvento(const Inizio, Fine: TDateTime): Integer;
begin
  result := MinutiDelGiorno(Fine) - MinutiDelGiorno(Inizio);

  if Trunc(Fine) > Trunc(Inizio) then
    // fine nei giorni dopo (per esempio la mezzanotte del giorno dopo)
    result := result + (Trunc(Fine) - Trunc(Inizio)) * MinsPerDay
  else
    if result < 0 then
      // fine alle 00:00 dello stesso giorno: la mezzanotte di fine giornata
      result := MinsPerDay - MinutiDelGiorno(Inizio);

  if MinutiDelGiorno(Fine) = MinsPerDay - 1 then
    result := result + 1;
end;

{ TzSchedulerEventKind }

constructor TzSchedulerEventKind.Create(const Code: TzSchedulerKind);
begin
  inherited Create;
  FCode := Code;
  FDescription := Code;
  FNewCaption := '';
  FIdFieldName := '';
  FNewImageIndex := -1;
  FEventImageIndex := -1;
  FDefaultDuration := 60;
  FIntersectionAllowed := False;
  FInsertKind := '';
  FApri := nil;
  FSposta := nil;
  FElimina := nil;
  FInitEventImages := nil;
end;

{ TzSchedulerEvents }

class constructor TzSchedulerEvents.Create;
begin
  FKinds := TObjectDictionary<string, TzSchedulerEventKind>.Create([doOwnsValues]);
  FOrder := TList<string>.Create;
  FExportProc := nil;
end;

class destructor TzSchedulerEvents.Destroy;
begin
  FreeAndNil(FOrder);
  FreeAndNil(FKinds);
end;

class function TzSchedulerEvents.Register(const Code: TzSchedulerKind; const Description, IdFieldName: string): TzSchedulerEventKind;
var
  Key: string;
begin
  Key := UpperCase(Code);

  if not FKinds.TryGetValue(Key, result) then
  begin
    result := TzSchedulerEventKind.Create(Code);
    FKinds.Add(Key, result);
    FOrder.Add(Key);
  end;

  result.Description := Description;
  result.IdFieldName := IdFieldName;
end;

class function TzSchedulerEvents.Find(const Code: TzSchedulerKind): TzSchedulerEventKind;
begin
  if (Code = '') or not FKinds.TryGetValue(UpperCase(Code), result) then
    result := nil;
end;

class function TzSchedulerEvents.Kinds: TArray<TzSchedulerEventKind>;
var
  Key: string;
begin
  result := nil;

  // nell'ordine di registrazione: e' l'ordine delle azioni di inserimento
  for Key in FOrder do
    result := result + [FKinds[Key]];
end;

class function TzSchedulerEvents.CanIntersect(const Code1, Code2: TzSchedulerKind): Boolean;
var
  Kind1, Kind2: TzSchedulerEventKind;
begin
  Kind1 := Find(Code1);
  Kind2 := Find(Code2);

  result := (Assigned(Kind1) and Kind1.IntersectionAllowed) or (Assigned(Kind2) and Kind2.IntersectionAllowed);
end;

class function TzSchedulerEvents.Apri(const Params: TzSchedulerEventParams): Boolean;
var
  Kind: TzSchedulerEventKind;
  Gestore: TzSchedulerEventFunc;
begin
  result := False;
  Kind := Find(Params.Kind);

  if not Assigned(Kind) then
    Exit;

  Gestore := Kind.Apri;
  if Assigned(Gestore) then
    result := Gestore(Params);
end;

class function TzSchedulerEvents.Sposta(const Params: TzSchedulerEventParams): Boolean;
var
  Kind: TzSchedulerEventKind;
  Gestore: TzSchedulerEventFunc;
begin
  result := False;
  Kind := Find(Params.Kind);

  if not Assigned(Kind) then
    Exit;

  Gestore := Kind.Sposta;
  if Assigned(Gestore) then
    result := Gestore(Params);
end;

class function TzSchedulerEvents.Elimina(const Params: TzSchedulerEventParams): Boolean;
var
  Kind: TzSchedulerEventKind;
  Gestore: TzSchedulerEventFunc;
begin
  result := False;
  Kind := Find(Params.Kind);

  if not Assigned(Kind) then
    Exit;

  Gestore := Kind.Elimina;
  if Assigned(Gestore) then
    result := Gestore(Params);
end;

{ TzSchedulerStorageBinder }

class destructor TzSchedulerStorageBinder.Destroy;
begin
  FreeAndNil(FInstance);
end;

procedure TzSchedulerStorageBinder.StorageEventHandled(Sender: TObject; AEvent: TcxSchedulerEvent; var AHandled: Boolean);
begin
  // le scritture passano dai gestori dei tipi, mai dallo storage
  AHandled := True;
end;

procedure TzSchedulerStorageBinder.StorageEventIntersect(Sender: TcxCustomSchedulerStorage; AEvent1, AEvent2: TcxSchedulerEvent; var Allow: Boolean);
begin
  Allow := TzSchedulerEvents.CanIntersect(VarToStr(SchedulerEventValue(AEvent1, zSchedulerKindField)),
    VarToStr(SchedulerEventValue(AEvent2, zSchedulerKindField)));
end;

class procedure TzSchedulerStorageBinder.InitDelegated(Storage: TcxSchedulerDBStorage; const ExtraCustomFields: array of string);
var
  Kind: TzSchedulerEventKind;
  FieldName: string;
  Added: TList<string>;

  procedure AddCustomField(const Name: string);
  begin
    if (Name = '') or Added.Contains(UpperCase(Name)) then
      Exit;

    Added.Add(UpperCase(Name));
    Storage.CustomFields.Add.FieldName := Name;
  end;

begin
  if not Assigned(Storage) then
    Exit;

  // gestori di evento: metodi di istanza di un oggetto unico, mai class procedure
  if not Assigned(FInstance) then
    FInstance := TzSchedulerStorageBinder.Create;

  Storage.OnEventInserted := FInstance.StorageEventHandled;
  Storage.OnEventDeleted := FInstance.StorageEventHandled;
  Storage.OnEventModified := FInstance.StorageEventHandled;
  Storage.OnEventIntersect := FInstance.StorageEventIntersect;

  // stessi campi di TSchedulerTools.InitStorageFields
  Storage.FieldNames.ID := 'ID';
  Storage.FieldNames.EventType := 'TIPO_EVENTO';
  Storage.FieldNames.Start := 'INIZIO';
  Storage.FieldNames.Finish := 'FINE';
  Storage.FieldNames.Options := 'OPZIONI';
  Storage.FieldNames.Caption := 'TITOLO_EVENTO';
  Storage.FieldNames.Message := 'CORPO_EVENTO';

  Added := TList<string>.Create;
  try
    Storage.CustomFields.Clear;
    AddCustomField('TITOLO_EVENTO');
    AddCustomField('CORPO_EVENTO');
    AddCustomField(zSchedulerKindField);
    AddCustomField(zSchedulerEditableField);

    for Kind in TzSchedulerEvents.Kinds do
      AddCustomField(Kind.IdFieldName);

    AddCustomField(zSchedulerColorField);

    for FieldName in ExtraCustomFields do
      AddCustomField(FieldName);
  finally
    FreeAndNil(Added);
  end;
end;

end.
