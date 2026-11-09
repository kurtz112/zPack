// ***************************************************************************
//
// zExceptions.mantis
//
// Apertura automatica di un ticket su MantisBT dalla gestione eccezioni.
// Unita' AUTONOMA: dipende solo dalla RTL (System.Net.*), NON dal progetto
// zMantisMCP. Espone:
//
// TMantisServerParams : parametri di connessione (come TSMTPServerParams).
// TMantisReport       : dati del ticket da aprire.
// SegnalaSuMantis()   : assicura progetto (=cliente) e utente reporter,
// crea il ticket con piu' contesto possibile, allega
// i file (log + screenshot) e ritorna l'ID del ticket.
//
// Note:
// - Il progetto viene fatto coincidere con il cliente/ente (ProjectName).
// - L'utente reporter viene cercato per username/email e, se assente, creato.
// Se il token non ha i permessi per gestire gli utenti, il ticket viene
// comunque aperto (reporter = utente del token) e l'identita' reale resta
// nella descrizione.
// - Include un fallback automatico su /api/rest/index.php nel caso il rewrite
// delle URL "pulite" non sia attivo sull'Apache che ospita Mantis.
// - Categoria "per modulo applicativo": la REST API di MantisBT NON supporta
// la CREAZIONE di categorie (verificato: 404 su POST /projects/{id}/categories,
// coerente con la feature request upstream tuttora aperta, issue mantisbt
// 0032470), ma la LETTURA (GET /projects/{id}/categories) funziona. Quindi
// non si creano piu' tag: se report.Category (tipicamente il nome del
// form/datamodule coinvolto, vedi zExceptions.pas/ResolveModuleTag) coincide
// con una categoria GIA' esistente nel progetto, si usa quella; altrimenti
// si ripiega sempre su ADefaultCategory (tipicamente "General").
//
// ***************************************************************************

unit zExceptions.mantis;

interface

uses
  System.SysUtils,
  System.Classes;

type
  EMantisReportError = class(Exception);

  TMantisServerParams = record
  private
    FBaseUrl: string; // es. https://test.zebro.it/mantis  (senza /api/rest)
    FApiToken: string;
    FDefaultCategory: string; // categoria usata se il progetto la richiede (default "General")
    FTimeoutMs: integer;
  public
    procedure Init; overload;
    procedure Init(const aBaseUrl, aApiToken: string; const aDefaultCategory: string = 'General'; aTimeoutMs: integer = 30000); overload;
    procedure Assign(src: TMantisServerParams);
    function IsValid: boolean;

    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property ApiToken: string read FApiToken write FApiToken;
    property DefaultCategory: string read FDefaultCategory write FDefaultCategory;
    property TimeoutMs: integer read FTimeoutMs write FTimeoutMs;
  end;

  TMantisReport = record
    ProjectName: string; // = cliente/ente (obbligatorio)
    ReporterUser: string; // username del segnalatore (obbligatorio)
    ReporterEmail: string; // opzionale
    ReporterRealName: string; // opzionale
    Summary: string; // oggetto (obbligatorio)
    Description: string; // corpo con tutto il contesto (obbligatorio)
    Category: string; // candidata (es. nome form/datamodule): usata
    // SOLO se esiste gia' come categoria del
    // progetto, altrimenti fallback su
    // TMantisServerParams.DefaultCategory. Vedi Run.
    Attachments: TArray<string>; // path dei file da allegare (log, png)
    // Visibilita' del ticket, nome MantisBT: vuoto = quella predefinita del
    // progetto, 'private' = solo chi lo ha aperto e chi ha il livello per i
    // ticket privati. Stringa e non boolean di proposito: i campi stringa di
    // un record locale partono sempre vuoti, un boolean no, e i chiamanti
    // esistenti non lo valorizzano.
    ViewState: string;
  end;

  { Crea/assicura progetto+utente, apre il ticket e allega i file. Ritorna
    l'ID del ticket creato. Solleva EMantisReportError in caso di errore. }
function SegnalaSuMantis(const params: TMantisServerParams; const report: TMantisReport): integer; overload;
// Come sopra, e in piu' restituisce gli allegati rifiutati, uno per voce nella
// forma "nome file: motivo". Un allegato rifiutato non annulla il ticket, ma
// chi segnala deve poterlo dire all'utente (tipico: file oltre il limite di
// dimensione del server Mantis).
function SegnalaSuMantis(const params: TMantisServerParams; const report: TMantisReport;
  out AllegatiNonRiusciti: TArray<string>): integer; overload;

// Allega un file a un ticket gia' aperto, per esempio le parti del filmato
// della registrazione per l'assistenza, che si caricano dopo l'apertura del
// ticket e una alla volta. ATimeoutMs > 0 sostituisce il tempo massimo dei
// parametri: i 30 secondi predefiniti non bastano per alcuni MB su una linea
// lenta. Solleva EMantisReportError se Mantis rifiuta il file. Si puo'
// chiamare da un thread secondario: ogni chiamata usa un client HTTP proprio.
procedure AllegaATicketMantis(const params: TMantisServerParams; NumeroTicket: integer; const NomeFile: string;
  ATimeoutMs: integer = 0);

// Aggiunge una nota a un ticket gia' aperto, privata per impostazione
// predefinita. Stesse regole di AllegaATicketMantis.
procedure AggiungiNotaATicketMantis(const params: TMantisServerParams; NumeroTicket: integer; const Testo: string;
  Privata: boolean = True);

implementation

uses
  System.IOUtils,
  System.NetEncoding,
  System.JSON,
  System.Net.HttpClient,
  System.Net.URLClient;

const
  ACCESS_LEVEL_REPORTER = 25; // livello di accesso globale "reporter" in Mantis

  { Letture JSON null-safe (compatibili da XE10.3 in su, senza overload generici opzionali). }

function JStr(o: TJSONObject; const key: string): string;
var
  v: TJSONValue;
begin
  result := '';
  if o = nil then
    Exit;
  v := o.GetValue(key);
  if (v <> nil) and not(v is TJSONNull) then
    result := v.Value;
end;

function JInt(o: TJSONObject; const key: string; out Value: integer): boolean;
var
  v: TJSONValue;
begin
  result := False;
  if o = nil then
    Exit;
  v := o.GetValue(key);
  if (v <> nil) and not(v is TJSONNull) then
    result := v.TryGetValue<integer>(Value);
end;

type
  TMantisReporter = class
  private
    FHttp: THTTPClient;
    FBase: string;
    FUseIndex: boolean; // true dopo un 404: si passa a /api/rest/index.php
    FProbed: boolean; // true dopo la prima risposta: stop al fallback su index.php
    function Url(const APath: string): string;
    { SendEx: non solleva sui 4xx; restituisce il body e lo status. Il fallback
      su index.php scatta solo alla PRIMA richiesta (prima di FProbed), cosi' un
      404 successivo e' un vero "non trovato" (es. utente inesistente). }
    function SendEx(const AMethod, APath: string; ABody: TStream; const ABodyContentType: string; out AStatus: integer): string;
    function Send(const AMethod, APath: string; ABody: TStream; const ABodyContentType: string): string;
    class function ParseObj(const ARaw: string): TJSONObject; static;
    function GetJsonObj(const APath: string): TJSONObject;
    function PostJsonObj(const APath: string; ABody: TJSONObject): TJSONObject;
    class function ExtractId(AObj: TJSONObject; const AWrapKey: string): integer; static;
    function EnsureProject(const AName: string): integer;
    function EnsureUser(const AUser, AEmail, ARealName: string): integer;
    // { True se AProjectId ha gia' una categoria chiamata esattamente AName
    // (case-insensitive). Usa GET /projects/{id}/categories: a differenza
    // della creazione, la lettura funziona su tutte le installazioni note.
    // Un eventuale errore (permessi, endpoint assente) NON blocca il ticket:
    // si ripiega semplicemente sulla categoria di default (vedi Run). }
    function CategoryExists(AProjectId: integer; const AName: string): boolean;
    function CreateIssue(AProjectId, AReporterId: integer; const ASummary, ADescription, ACategory, AViewState: string): integer;
    procedure AttachFile(AIssueId: integer; const APath: string);
    procedure AddNote(AIssueId: integer; const AText: string; APrivate: boolean);
  public
    constructor Create(const params: TMantisServerParams);
    destructor Destroy; override;
    function Run(const report: TMantisReport; const aDefaultCategory: string; out AFailed: TArray<string>): integer;
  end;

  { -------------------------------------------------- TMantisServerParams --- }

procedure TMantisServerParams.Init;
begin
  FBaseUrl := '';
  FApiToken := '';
  FDefaultCategory := 'Generica';
  FTimeoutMs := 30000;
end;

procedure TMantisServerParams.Init(const aBaseUrl, aApiToken: string; const aDefaultCategory: string; aTimeoutMs: integer);
begin
  FBaseUrl := aBaseUrl;
  FApiToken := aApiToken;
  if aDefaultCategory <> '' then
    FDefaultCategory := aDefaultCategory
  else
    FDefaultCategory := 'General';
  if aTimeoutMs > 0 then
    FTimeoutMs := aTimeoutMs
  else
    FTimeoutMs := 30000;
end;

procedure TMantisServerParams.Assign(src: TMantisServerParams);
begin
  FBaseUrl := src.FBaseUrl;
  FApiToken := src.FApiToken;
  FDefaultCategory := src.FDefaultCategory;
  FTimeoutMs := src.FTimeoutMs;
end;

function TMantisServerParams.IsValid: boolean;
begin
  result := (not FBaseUrl.Trim.IsEmpty) and (not FApiToken.Trim.IsEmpty);
end;

{ ------------------------------------------------------- TMantisReporter --- }

constructor TMantisReporter.Create(const params: TMantisServerParams);
begin
  inherited Create;
  FBase := params.BaseUrl.Trim;
  while FBase.EndsWith('/') do
    FBase := FBase.Substring(0, FBase.Length - 1);
  FUseIndex := False;
  FProbed := False;

  FHttp := THTTPClient.Create;
  FHttp.ConnectionTimeout := params.TimeoutMs;
  FHttp.ResponseTimeout := params.TimeoutMs;
  FHttp.Accept := 'application/json';
  FHttp.CustomHeaders['Authorization'] := params.ApiToken;
end;

destructor TMantisReporter.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TMantisReporter.Url(const APath: string): string;
begin
  if FUseIndex then
    result := FBase + '/api/rest/index.php' + APath
  else
    result := FBase + '/api/rest' + APath;
end;

function TMantisReporter.SendEx(const AMethod, APath: string; ABody: TStream; const ABodyContentType: string; out AStatus: integer): string;
var
  resp: IHTTPResponse;
  hdrs: TNetHeaders;
  attempt: integer;
begin
  resp := nil;
  for attempt := 0 to 1 do
  begin
    if ABody <> nil then
      ABody.Position := 0;

    if ABodyContentType <> '' then
    begin
      FHttp.ContentType := ABodyContentType;
      hdrs := [TNetHeader.Create('Content-Type', ABodyContentType)]
    end
    else
    begin
      FHttp.ContentType := '';
      hdrs := [];
    end;

    if SameText(AMethod, 'GET') then
      resp := FHttp.Get(Url(APath))
    else
      if SameText(AMethod, 'POST') then
        resp := FHttp.Post(Url(APath), ABody, nil, hdrs)
      else
        raise EMantisReportError.CreateFmt('Metodo HTTP non supportato: %s', [AMethod]);

    // Solo alla PRIMA richiesta: se 404 con URL "pulite", riprova via index.php
    // (rewrite non attivo). Dopo FProbed, un 404 e' un vero "non trovato".
    if (resp.StatusCode = 404) and (not FProbed) and (not FUseIndex) then
    begin
      FUseIndex := True;
      Continue;
    end;
    Break;
  end;

  FProbed := True;
  AStatus := resp.StatusCode;
  result := resp.ContentAsString(TEncoding.UTF8);
end;

function TMantisReporter.Send(const AMethod, APath: string; ABody: TStream; const ABodyContentType: string): string;
var
  status: integer;
begin
  result := SendEx(AMethod, APath, ABody, ABodyContentType, status);
  if (status < 200) or (status >= 300) then
    raise EMantisReportError.CreateFmt('Mantis HTTP %d su %s %s: %s', [status, AMethod, APath, result]);
end;

class function TMantisReporter.ParseObj(const ARaw: string): TJSONObject;
var
  v: TJSONValue;
begin
  v := TJSONObject.ParseJSONValue(ARaw);
  if v is TJSONObject then
    result := TJSONObject(v)
  else
  begin
    v.Free;
    result := nil;
  end;
end;

function TMantisReporter.GetJsonObj(const APath: string): TJSONObject;
begin
  result := ParseObj(Send('GET', APath, nil, ''));
  if result = nil then
    raise EMantisReportError.CreateFmt('Risposta non valida da GET %s', [APath]);
end;

function TMantisReporter.PostJsonObj(const APath: string; ABody: TJSONObject): TJSONObject;
var
  content: TStringStream;
  raw: string;
begin
  content := TStringStream.Create(ABody.ToJSON, TEncoding.UTF8);
  try
    raw := Send('POST', APath, content, 'application/json; charset=utf-8');
  finally
    content.Free;
  end;
  result := ParseObj(raw);
end;

class function TMantisReporter.ExtractId(AObj: TJSONObject; const AWrapKey: string): integer;
var
  inner: TJSONValue;
  n: integer;
begin
  result := 0;
  if AObj = nil then
    Exit;
  // forma { "<key>": { "id": N } }
  inner := AObj.GetValue(AWrapKey);
  if (inner is TJSONObject) and JInt(TJSONObject(inner), 'id', n) then
    Exit(n);
  // forma { "id": N }
  if JInt(AObj, 'id', n) then
    Exit(n);
end;

function TMantisReporter.EnsureProject(const AName: string): integer;
var
  resp, projPayload: TJSONObject;
  arr: TJSONArray;
  it: TJSONValue;
  id: integer;
begin
  result := 0;

  // 1) cerca per nome esatto (case-insensitive)
  resp := GetJsonObj('/projects');
  try
    arr := resp.GetValue('projects') as TJSONArray;
    if arr <> nil then
      for it in arr do
        if it is TJSONObject then
          if SameText(JStr(TJSONObject(it), 'name'), AName) and JInt(TJSONObject(it), 'id', id) then
            Exit(id);
  finally
    resp.Free;
  end;

  // 2) non trovato: crea il progetto
  projPayload := TJSONObject.Create;
  try
    projPayload.AddPair('name', AName);
    projPayload.AddPair('enabled', TJSONBool.Create(True));
    resp := PostJsonObj('/projects', projPayload);
    try
      result := ExtractId(resp, 'project');
    finally
      resp.Free;
    end;
  finally
    projPayload.Free;
  end;

  if result = 0 then
    raise EMantisReportError.CreateFmt('Impossibile creare/individuare il progetto "%s".', [AName]);
end;

function TMantisReporter.EnsureUser(const AUser, AEmail, ARealName: string): integer;
var
  resp, payload: TJSONObject;
  arr: TJSONArray;
  raw: string;
  status: integer;
begin
  result := 0;

  // 1) cerca per username: GET /users/username/{username}
  // (l'API MantisBT NON espone un elenco /users: solo lookup per id/username).
  // La risposta ha forma { "users": [ { "id": ... } ] }.
  raw := SendEx('GET', '/users/username/' + TNetEncoding.Url.Encode(AUser), nil, '', status);
  if status = 200 then
  begin
    resp := ParseObj(raw);
    if resp <> nil then
      try
        arr := resp.GetValue('users') as TJSONArray;
        if (arr <> nil) and (arr.Count > 0) and (arr.Items[0] is TJSONObject) then
          JInt(TJSONObject(arr.Items[0]), 'id', result)
        else
          result := ExtractId(resp, 'user'); // fallback per altre forme di risposta
      finally
        resp.Free;
      end;
    if result > 0 then
      Exit;
  end
  else
    if status <> 404 then
      // Errore diverso da "non trovato" (es. permessi): non blocca la segnalazione.
      Exit(0);

  // 2) non trovato: crea l'utente (password casuale: non fa mai login diretto)
  payload := TJSONObject.Create;
  try
    payload.AddPair('username', AUser);
    if ARealName <> '' then
      payload.AddPair('real_name', ARealName);
    if AEmail <> '' then
      payload.AddPair('email', AEmail);
    payload.AddPair('password', TGUID.NewGuid.ToString);
    // access_level e' un Enum (oggetto), non un intero: {"id":25} = reporter
    payload.AddPair('access_level', TJSONObject.Create(TJSONPair.Create('id', TJSONNumber.Create(ACCESS_LEVEL_REPORTER))));
    resp := PostJsonObj('/users', payload);
    try
      result := ExtractId(resp, 'user');
    finally
      resp.Free;
    end;
  finally
    payload.Free;
  end;
end;

function TMantisReporter.CategoryExists(AProjectId: integer; const AName: string): boolean;
var
  resp: TJSONObject;
  arr: TJSONArray;
  it: TJSONValue;
begin
  result := False;
  if AName.Trim = '' then
    Exit;

  // Solo LETTURA: a differenza di POST /projects/{id}/categories (non
  // supportato dalla REST API di MantisBT), la GET funziona regolarmente.
  // Un eventuale errore (permessi, endpoint non disponibile su qualche
  // installazione) non deve impedire l'apertura del ticket: si ripiega
  // sulla categoria di default (vedi Run).
  try
    resp := GetJsonObj(Format('/projects/%d/categories', [AProjectId]));
    try
      arr := resp.GetValue('categories') as TJSONArray;
      if arr <> nil then
        for it in arr do
          if it is TJSONObject then
            if SameText(JStr(TJSONObject(it), 'name'), AName.Trim) then
              Exit(True);
    finally
      resp.Free;
    end;
  except
    result := False;
  end;
end;

function TMantisReporter.CreateIssue(AProjectId, AReporterId: integer; const ASummary, ADescription, ACategory, AViewState: string): integer;
var
  payload, proj, cat, rep, view: TJSONObject;
  resp: TJSONObject;
begin
  payload := TJSONObject.Create;
  try
    payload.AddPair('summary', ASummary);
    payload.AddPair('description', ADescription);

    proj := TJSONObject.Create;
    proj.AddPair('id', TJSONNumber.Create(AProjectId));
    payload.AddPair('project', proj);

    // Category e' obbligatoria alla creazione nella maggior parte delle configurazioni.
    cat := TJSONObject.Create;
    cat.AddPair('name', ACategory);
    payload.AddPair('category', cat);

    if AReporterId > 0 then
    begin
      rep := TJSONObject.Create;
      rep.AddPair('id', TJSONNumber.Create(AReporterId));
      payload.AddPair('reporter', rep);
    end;

    // Visibilita' per nome ("public", "private"): senza la voce vale quella
    // predefinita del progetto.
    if AViewState.Trim <> '' then
    begin
      view := TJSONObject.Create;
      view.AddPair('name', AViewState.Trim);
      payload.AddPair('view_state', view);
    end;

    resp := PostJsonObj('/issues', payload);
    try
      result := ExtractId(resp, 'issue');
    finally
      resp.Free;
    end;
  finally
    payload.Free;
  end;

  if result = 0 then
    raise EMantisReportError.Create('Ticket creato ma ID non riconosciuto nella risposta.');
end;

procedure TMantisReporter.AttachFile(AIssueId: integer; const APath: string);
var
  bytes: TBytes;
  b64: string;
  payload, fileObj: TJSONObject;
  arr: TJSONArray;
  resp: TJSONObject;
begin
  if (APath = '') or (not FileExists(APath)) then
    Exit;

  // MantisBT vuole l'upload come JSON base64, NON multipart:
  // POST /issues/{id}/files  { "files":[ { "name":..., "content":"<base64>" } ] }
  bytes := TFile.ReadAllBytes(APath);
  b64 := TNetEncoding.Base64.EncodeBytesToString(bytes);
  b64 := b64.Replace(#13, '').Replace(#10, ''); // niente a-capo MIME

  fileObj := TJSONObject.Create;
  fileObj.AddPair('name', ExtractFileName(APath));
  fileObj.AddPair('content', b64);
  arr := TJSONArray.Create;
  arr.AddElement(fileObj);

  payload := TJSONObject.Create;
  try
    payload.AddPair('files', arr);
    resp := PostJsonObj(Format('/issues/%d/files', [AIssueId]), payload);
    resp.Free;
  finally
    payload.Free;
  end;
end;

// POST /issues/{id}/notes { "text": ..., "view_state": { "name": "private" } }
procedure TMantisReporter.AddNote(AIssueId: integer; const AText: string; APrivate: boolean);
var
  payload, viewState: TJSONObject;
  resp: TJSONObject;
begin
  payload := TJSONObject.Create;
  try
    payload.AddPair('text', AText);
    viewState := TJSONObject.Create;
    if APrivate then
      viewState.AddPair('name', 'private')
    else
      viewState.AddPair('name', 'public');
    payload.AddPair('view_state', viewState);
    resp := PostJsonObj(Format('/issues/%d/notes', [AIssueId]), payload);
    resp.Free;
  finally
    payload.Free;
  end;
end;

function TMantisReporter.Run(const report: TMantisReport; const aDefaultCategory: string; out AFailed: TArray<string>): integer;
var
  projId, reporterId: integer;
  cat, path: string;
begin
  projId := EnsureProject(report.ProjectName);

  // L'assenza di permessi sugli utenti non deve impedire l'apertura del ticket.
  reporterId := 0;
  try
    if report.ReporterUser.Trim <> '' then
      reporterId := EnsureUser(report.ReporterUser, report.ReporterEmail, report.ReporterRealName);
  except
    reporterId := 0;
  end;

  // Categoria: se report.Category (candidata, es. nome form/datamodule)
  // esiste GIA' come categoria del progetto, la si usa; altrimenti si
  // ripiega sempre sulla categoria di default. Non si crea mai una nuova
  // categoria (la REST API di MantisBT non lo supporta).
  cat := '';
  if (report.Category.Trim <> '') and CategoryExists(projId, report.Category) then
    cat := report.Category.Trim;
  if cat = '' then
    cat := aDefaultCategory;
  if cat.Trim = '' then
    cat := 'General';

  result := CreateIssue(projId, reporterId, report.Summary, report.Description, cat, report.ViewState);

  // Allegati: log + screenshot. Un allegato fallito non annulla il ticket,
  // ma viene restituito al chiamante con il motivo.
  AFailed := [];
  for path in report.Attachments do
    try
      AttachFile(result, path);
    except
      on E: Exception do
        AFailed := AFailed + [ExtractFileName(path) + ': ' + E.Message];
    end;
end;

{ ------------------------------------------------------------- funzione --- }

function SegnalaSuMantis(const params: TMantisServerParams; const report: TMantisReport): integer;
var
  AllegatiNonRiusciti: TArray<string>;
begin
  result := SegnalaSuMantis(params, report, AllegatiNonRiusciti);
end;

function SegnalaSuMantis(const params: TMantisServerParams; const report: TMantisReport;
  out AllegatiNonRiusciti: TArray<string>): integer;
var
  reporter: TMantisReporter;
begin
  AllegatiNonRiusciti := [];
  if not params.IsValid then
    raise EMantisReportError.Create('Parametri server Mantis non validi (BaseUrl/ApiToken).');
  if report.ProjectName.Trim = '' then
    raise EMantisReportError.Create('ProjectName (cliente/ente) obbligatorio.');
  if report.Summary.Trim = '' then
    raise EMantisReportError.Create('Summary obbligatorio.');

  reporter := TMantisReporter.Create(params);
  try
    result := reporter.Run(report, params.DefaultCategory, AllegatiNonRiusciti);
  finally
    reporter.Free;
  end;
end;

procedure AllegaATicketMantis(const params: TMantisServerParams; NumeroTicket: integer; const NomeFile: string;
  ATimeoutMs: integer);
var
  parametri: TMantisServerParams;
  reporter: TMantisReporter;
begin
  if not params.IsValid then
    raise EMantisReportError.Create('Parametri server Mantis non validi (BaseUrl/ApiToken).');
  if not FileExists(NomeFile) then
    raise EMantisReportError.CreateFmt('File da allegare non trovato: %s', [NomeFile]);

  parametri := params;
  if ATimeoutMs > 0 then
    parametri.TimeoutMs := ATimeoutMs;
  reporter := TMantisReporter.Create(parametri);
  try
    reporter.AttachFile(NumeroTicket, NomeFile);
  finally
    reporter.Free;
  end;
end;

procedure AggiungiNotaATicketMantis(const params: TMantisServerParams; NumeroTicket: integer; const Testo: string;
  Privata: boolean);
var
  reporter: TMantisReporter;
begin
  if not params.IsValid then
    raise EMantisReportError.Create('Parametri server Mantis non validi (BaseUrl/ApiToken).');
  reporter := TMantisReporter.Create(params);
  try
    reporter.AddNote(NumeroTicket, Testo, Privata);
  finally
    reporter.Free;
  end;
end;

end.

