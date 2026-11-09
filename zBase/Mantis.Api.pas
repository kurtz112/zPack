// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------

// Lettura e aggiornamento dei ticket MantisBT tramite la REST API.
//
// Unit autonoma: dipende solo dalla RTL, come zExceptions.mantis, che resta
// dedicata alla sola apertura del ticket dall'eccezione. Serve alla form
// "Le mie segnalazioni" di WT e Gesty (zMantis.TicketAssistenza.form) e alla
// vista dei ticket assegnati di Analysir.
//
// Endpoint usati (verificati sul Mantis Softline, MantisBT 2.x, token API):
//   GET   /issues/{id}                        dettaglio con note e allegati
//   GET   /issues?filter_id=<filtro>&...      filtri standard: assigned,
//                                             reported, monitored, unassigned
//   GET   /projects                           elenco progetti (per l'id)
//   POST  /issues/{id}/notes                  nota pubblica o privata, anche
//                                             con allegati legati alla nota
//   POST  /issues/{id}/files                  allegato in base64
//   GET   /issues/{id}/files/{file_id}        contenuto dell'allegato in base64
//   PATCH /issues/{id}                        stato e risoluzione
//   GET   /config?option=<nome>               un'opzione di configurazione
//
// Le note restituite sono solo quelle visibili all'utente del token: con un
// utente di livello reporter le note private non arrivano affatto, quindi
// non serve filtrarle qui.
//
// Ripiego su /api/rest/index.php: alla prima richiesta, se le URL "pulite"
// rispondono 404, si passa a index.php (rewrite non attivo sull'Apache che
// ospita Mantis). Stessa regola di zExceptions.mantis.

unit Mantis.Api;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Net.HttpClient;

type
  EMantisApiError = class(Exception);

  TMantisAllegato = record
    Id: Integer;
    Nome: string;
    Dimensione: Integer;
    TipoContenuto: string; // content_type dichiarato da Mantis
    CreatoIl: TDateTime;
    // Nota a cui l'allegato appartiene; 0 se e' allegato alla richiesta.
    IdNota: Integer;
  end;

  TMantisNota = record
    Id: Integer;
    Autore: string;
    AutoreNomeReale: string;
    Testo: string;
    Privata: Boolean;
    CreataIl: TDateTime;
    // Allegati caricati insieme alla nota (notes[].attachments della REST API).
    Allegati: TArray<TMantisAllegato>;
  end;

  TMantisIssue = record
    Id: Integer;
    Progetto: string;
    Categoria: string;
    Oggetto: string;
    Descrizione: string;
    Stato: string; // nome interno MantisBT: new, assigned, resolved, closed...
    Risoluzione: string;
    Priorita: string;
    Severita: string;
    Reporter: string;
    ReporterNomeReale: string;
    Assegnatario: string;
    AssegnatarioNomeReale: string;
    CreatoIl: TDateTime;
    AggiornatoIl: TDateTime;
    Note: TArray<TMantisNota>;
    Allegati: TArray<TMantisAllegato>;
    // Nome da mostrare per l'assegnatario: il nome reale se c'e', altrimenti
    // lo username, altrimenti vuoto.
    function AssegnatarioVisibile: string;
    // Allegati della richiesta, cioe' non caricati con una nota.
    function AllegatiDellaRichiesta: TArray<TMantisAllegato>;
    function Chiuso: Boolean;
    function Risolto: Boolean;
  end;

  TMantisApi = class
  private
    FHttp: THTTPClient;
    FBase: string;
    FUseIndex: Boolean; // True dopo un 404 alla prima richiesta: si passa a index.php
    FProbed: Boolean; // True dopo la prima risposta: da li' in poi un 404 e' un vero "non trovato"
    function Url(const APath: string): string;
    function SendEx(const AMethod, APath: string; ABody: TStream; const AContentType: string; out AStatus: Integer): string;
    function Send(const AMethod, APath: string; ABody: TStream; const AContentType: string): string;
    function GetJson(const APath: string): TJSONObject;
    function SendJson(const AMethod, APath: string; ABody: TJSONObject): TJSONObject;
    // Elemento {"name", "content" base64} di un array "files" della REST API.
    function FileJson(const APercorso: string): TJSONObject;
  public
    constructor Create(const ABaseUrl, AToken: string; ATimeoutMs: Integer = 30000);
    destructor Destroy; override;
    // Dettaglio completo di un ticket (note e allegati compresi).
    function Issue(AId: Integer): TMantisIssue;
    // Ticket di un filtro standard di MantisBT ("assigned", "reported",
    // "monitored", "unassigned"), risolto sull'utente del token. AProjectId = 0
    // vale per tutti i progetti. Una pagina vuota segnala la fine.
    function IssuesByStandardFilter(const AFiltro: string; AProjectId, APage, APageSize: Integer): TArray<TMantisIssue>;
    // Id di un progetto dal nome esatto (senza distinzione fra maiuscole e
    // minuscole); 0 se non esiste o non e' visibile al token.
    function ProjectId(const ANome: string): Integer;
    // Aggiunge una nota e ne restituisce l'id.
    function AddNote(AId: Integer; const ATesto: string; APrivata: Boolean = False): Integer;
    // Aggiunge una nota con i file indicati legati alla nota stessa, in una
    // sola chiamata; ne restituisce l'id.
    function AddNoteConAllegati(AId: Integer; const ATesto: string; const APercorsi: TArray<string>; APrivata: Boolean = False): Integer;
    procedure AttachFile(AId: Integer; const APercorso: string);
    procedure DownloadFile(AId, AFileId: Integer; const ADestinazione: string);
    // Cambia stato (nome interno MantisBT) ed eventualmente la risoluzione.
    procedure SetStatus(AId: Integer; const AStato: string; const ARisoluzione: string = '');
    // Chiude un ticket risolto: stato closed, risoluzione fixed.
    procedure CloseIssue(AId: Integer);
    // Indirizzo della pagina del ticket nel browser.
    function ViewUrl(AId: Integer): string;
    // Valore numerico di un'opzione di configurazione di Mantis (per esempio
    // max_file_size); ADefault se l'opzione non e' leggibile con il token.
    function ConfigNumero(const AOpzione: string; ADefault: Int64 = 0): Int64;
    property BaseUrl: string read FBase;
  end;

// Etichetta italiana di uno stato MantisBT (nome interno -> testo per
// l'utente). Uno stato sconosciuto torna com'e'.
function MantisStatoEtichetta(const AStato: string): string;

// Letture JSON tolleranti ai valori assenti o null.
function MantisJsonStr(AObj: TJSONObject; const AKey: string): string;
function MantisJsonInt(AObj: TJSONObject; const AKey: string; ADefault: Integer = 0): Integer;
// Nome di un enumerato MantisBT ({"id": n, "name": "..."}).
function MantisJsonEnumName(AObj: TJSONObject; const AKey: string): string;
// Data ISO 8601 con fuso ("2026-07-29T09:16:56+00:00") convertita in ora locale.
function MantisJsonData(AObj: TJSONObject; const AKey: string): TDateTime;
// Conversione di un oggetto "issue" della REST API nel record.
function MantisParseIssue(AObj: TJSONObject): TMantisIssue;
// Conversione di un array "attachments" (del ticket o di una nota).
function MantisParseAllegati(AElenco: TJSONValue; AIdNota: Integer): TArray<TMantisAllegato>;

implementation

uses
  System.IOUtils,
  System.NetEncoding,
  System.DateUtils,
  System.Net.URLClient;

function MantisStatoEtichetta(const AStato: string): string;
begin
  if SameText(AStato, 'new') then
    Result := 'Nuova'
  else
    if SameText(AStato, 'feedback') then
      Result := 'In attesa di informazioni'
    else
      if SameText(AStato, 'acknowledged') then
        Result := 'Presa in carico'
      else
        if SameText(AStato, 'confirmed') then
          Result := 'Confermata'
        else
          if SameText(AStato, 'assigned') then
            Result := 'Assegnata'
          else
            if SameText(AStato, 'sospesa') then
              Result := 'Sospesa'
            else
              if SameText(AStato, 'resolved') then
                Result := 'Risolta'
              else
                if SameText(AStato, 'closed') then
                  Result := 'Chiusa'
                else
                  Result := AStato;
end;

function MantisJsonStr(AObj: TJSONObject; const AKey: string): string;
var
  Valore: TJSONValue;
begin
  Result := '';
  if AObj = nil then
    Exit;
  Valore := AObj.GetValue(AKey);
  if (Valore <> nil) and not(Valore is TJSONNull) then
    Result := Valore.Value;
end;

function MantisJsonInt(AObj: TJSONObject; const AKey: string; ADefault: Integer): Integer;
var
  Valore: TJSONValue;
begin
  Result := ADefault;
  if AObj = nil then
    Exit;
  Valore := AObj.GetValue(AKey);
  if (Valore <> nil) and not(Valore is TJSONNull) then
    if not Valore.TryGetValue<Integer>(Result) then
      Result := ADefault;
end;

function MantisJsonEnumName(AObj: TJSONObject; const AKey: string): string;
var
  Valore: TJSONValue;
begin
  Result := '';
  if AObj = nil then
    Exit;
  Valore := AObj.GetValue(AKey);
  if Valore is TJSONObject then
    Result := MantisJsonStr(TJSONObject(Valore), 'name');
end;

function MantisJsonData(AObj: TJSONObject; const AKey: string): TDateTime;
var
  Testo: string;
begin
  Result := 0;
  Testo := MantisJsonStr(AObj, AKey);
  if Testo = '' then
    Exit;
  try
    // AReturnUTC = False: la data torna gia' nell'ora locale della postazione.
    Result := ISO8601ToDate(Testo, False);
  except
    Result := 0;
  end;
end;

function MantisParseAllegati(AElenco: TJSONValue; AIdNota: Integer): TArray<TMantisAllegato>;
var
  Elemento: TJSONValue;
  Oggetto: TJSONObject;
  Allegato: TMantisAllegato;
begin
  Result := [];
  if not(AElenco is TJSONArray) then
    Exit;
  for Elemento in TJSONArray(AElenco) do
    if Elemento is TJSONObject then
    begin
      Oggetto := TJSONObject(Elemento);
      Allegato := Default (TMantisAllegato);
      Allegato.Id := MantisJsonInt(Oggetto, 'id');
      Allegato.Nome := MantisJsonStr(Oggetto, 'filename');
      Allegato.Dimensione := MantisJsonInt(Oggetto, 'size');
      Allegato.TipoContenuto := MantisJsonStr(Oggetto, 'content_type');
      Allegato.CreatoIl := MantisJsonData(Oggetto, 'created_at');
      Allegato.IdNota := AIdNota;
      Result := Result + [Allegato];
    end;
end;

function MantisParseIssue(AObj: TJSONObject): TMantisIssue;
var
  Elenco: TJSONArray;
  Elemento: TJSONValue;
  Oggetto: TJSONObject;
  Utente: TJSONValue;
  Nota: TMantisNota;
  Allegato: TMantisAllegato;
  IndiceNota, IndiceAllegato: Integer;
begin
  Result := Default (TMantisIssue);
  if AObj = nil then
    Exit;

  Result.Id := MantisJsonInt(AObj, 'id');
  Result.Oggetto := MantisJsonStr(AObj, 'summary');
  Result.Descrizione := MantisJsonStr(AObj, 'description');
  Result.Progetto := MantisJsonEnumName(AObj, 'project');
  Result.Categoria := MantisJsonEnumName(AObj, 'category');
  Result.Stato := MantisJsonEnumName(AObj, 'status');
  Result.Risoluzione := MantisJsonEnumName(AObj, 'resolution');
  Result.Priorita := MantisJsonEnumName(AObj, 'priority');
  Result.Severita := MantisJsonEnumName(AObj, 'severity');
  Result.CreatoIl := MantisJsonData(AObj, 'created_at');
  Result.AggiornatoIl := MantisJsonData(AObj, 'updated_at');

  Utente := AObj.GetValue('reporter');
  if Utente is TJSONObject then
  begin
    Result.Reporter := MantisJsonStr(TJSONObject(Utente), 'name');
    Result.ReporterNomeReale := MantisJsonStr(TJSONObject(Utente), 'real_name');
  end;

  Utente := AObj.GetValue('handler');
  if Utente is TJSONObject then
  begin
    Result.Assegnatario := MantisJsonStr(TJSONObject(Utente), 'name');
    Result.AssegnatarioNomeReale := MantisJsonStr(TJSONObject(Utente), 'real_name');
  end;

  // Note: arrivano solo quelle visibili al token, in ordine cronologico.
  Result.Note := [];
  Elenco := AObj.GetValue('notes') as TJSONArray;
  if Elenco <> nil then
    for Elemento in Elenco do
      if Elemento is TJSONObject then
      begin
        Oggetto := TJSONObject(Elemento);
        Nota := Default (TMantisNota);
        Nota.Id := MantisJsonInt(Oggetto, 'id');
        Nota.Testo := MantisJsonStr(Oggetto, 'text');
        Nota.Privata := SameText(MantisJsonEnumName(Oggetto, 'view_state'), 'private');
        Nota.CreataIl := MantisJsonData(Oggetto, 'created_at');
        Utente := Oggetto.GetValue('reporter');
        if Utente is TJSONObject then
        begin
          Nota.Autore := MantisJsonStr(TJSONObject(Utente), 'name');
          Nota.AutoreNomeReale := MantisJsonStr(TJSONObject(Utente), 'real_name');
        end;
        Nota.Allegati := MantisParseAllegati(Oggetto.GetValue('attachments'), Nota.Id);
        Result.Note := Result.Note + [Nota];
      end;

  // Allegati: solo i metadati, il contenuto si scarica con DownloadFile.
  // L'elenco del ticket comprende anche quelli delle note (MantisBT,
  // mci_issue_get_attachments senza filtro): qui ciascuno riceve la sua nota,
  // cosi' la richiesta iniziale mostra solo i propri.
  Result.Allegati := MantisParseAllegati(AObj.GetValue('attachments'), 0);
  for IndiceAllegato := 0 to High(Result.Allegati) do
    for IndiceNota := 0 to High(Result.Note) do
      for Allegato in Result.Note[IndiceNota].Allegati do
        if Allegato.Id = Result.Allegati[IndiceAllegato].Id then
          Result.Allegati[IndiceAllegato].IdNota := Result.Note[IndiceNota].Id;
end;

{ TMantisIssue }

function TMantisIssue.AssegnatarioVisibile: string;
begin
  Result := AssegnatarioNomeReale.Trim;
  if Result = '' then
    Result := Assegnatario.Trim;
end;

function TMantisIssue.AllegatiDellaRichiesta: TArray<TMantisAllegato>;
var
  Allegato: TMantisAllegato;
begin
  Result := [];
  for Allegato in Allegati do
    if Allegato.IdNota = 0 then
      Result := Result + [Allegato];
end;

function TMantisIssue.Chiuso: Boolean;
begin
  Result := SameText(Stato, 'closed');
end;

function TMantisIssue.Risolto: Boolean;
begin
  Result := SameText(Stato, 'resolved');
end;

{ TMantisApi }

constructor TMantisApi.Create(const ABaseUrl, AToken: string; ATimeoutMs: Integer);
begin
  inherited Create;
  FBase := ABaseUrl.Trim;
  while FBase.EndsWith('/') do
    FBase := FBase.Substring(0, FBase.Length - 1);
  FUseIndex := False;
  FProbed := False;

  if ATimeoutMs <= 0 then
    ATimeoutMs := 30000;

  FHttp := THTTPClient.Create;
  FHttp.ConnectionTimeout := ATimeoutMs;
  FHttp.ResponseTimeout := ATimeoutMs;
  FHttp.Accept := 'application/json';
  FHttp.CustomHeaders['Authorization'] := AToken;
end;

destructor TMantisApi.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TMantisApi.Url(const APath: string): string;
begin
  if FUseIndex then
    Result := FBase + '/api/rest/index.php' + APath
  else
    Result := FBase + '/api/rest' + APath;
end;

function TMantisApi.ViewUrl(AId: Integer): string;
begin
  Result := FBase + '/view.php?id=' + AId.ToString;
end;

function TMantisApi.SendEx(const AMethod, APath: string; ABody: TStream; const AContentType: string; out AStatus: Integer): string;
var
  Risposta: IHTTPResponse;
  Intestazioni: TNetHeaders;
  Tentativo: Integer;
begin
  Risposta := nil;
  for Tentativo := 0 to 1 do
  begin
    if ABody <> nil then
      ABody.Position := 0;

    if AContentType <> '' then
    begin
      FHttp.ContentType := AContentType;
      Intestazioni := [TNetHeader.Create('Content-Type', AContentType)];
    end
    else
    begin
      FHttp.ContentType := '';
      Intestazioni := [];
    end;

    if SameText(AMethod, 'GET') then
      Risposta := FHttp.Get(Url(APath))
    else
      if SameText(AMethod, 'POST') then
        Risposta := FHttp.Post(Url(APath), ABody, nil, Intestazioni)
      else
        if SameText(AMethod, 'PATCH') then
          Risposta := FHttp.Patch(Url(APath), ABody, nil, Intestazioni)
        else
          raise EMantisApiError.CreateFmt('Metodo HTTP non supportato: %s', [AMethod]);

    // Solo alla prima richiesta: un 404 con le URL pulite fa passare a
    // index.php. Dopo, un 404 e' un vero "non trovato".
    if (Risposta.StatusCode = 404) and (not FProbed) and (not FUseIndex) then
    begin
      FUseIndex := True;
      Continue;
    end;
    Break;
  end;

  FProbed := True;
  AStatus := Risposta.StatusCode;
  Result := Risposta.ContentAsString(TEncoding.UTF8);
end;

function TMantisApi.Send(const AMethod, APath: string; ABody: TStream; const AContentType: string): string;
var
  Stato: Integer;
begin
  Result := SendEx(AMethod, APath, ABody, AContentType, Stato);
  if (Stato < 200) or (Stato >= 300) then
    raise EMantisApiError.CreateFmt('Mantis HTTP %d su %s %s: %s', [Stato, AMethod, APath, Result]);
end;

function TMantisApi.GetJson(const APath: string): TJSONObject;
var
  Valore: TJSONValue;
begin
  Valore := TJSONObject.ParseJSONValue(Send('GET', APath, nil, ''));
  if Valore is TJSONObject then
    Result := TJSONObject(Valore)
  else
  begin
    Valore.Free;
    raise EMantisApiError.CreateFmt('Risposta non valida da GET %s', [APath]);
  end;
end;

function TMantisApi.SendJson(const AMethod, APath: string; ABody: TJSONObject): TJSONObject;
var
  Contenuto: TStringStream;
  Grezzo: string;
  Valore: TJSONValue;
begin
  Contenuto := TStringStream.Create(ABody.ToJSON, TEncoding.UTF8);
  try
    Grezzo := Send(AMethod, APath, Contenuto, 'application/json; charset=utf-8');
  finally
    Contenuto.Free;
  end;

  Result := nil;
  if Grezzo.Trim = '' then
    Exit;
  Valore := TJSONObject.ParseJSONValue(Grezzo);
  if Valore is TJSONObject then
    Result := TJSONObject(Valore)
  else
    Valore.Free;
end;

function TMantisApi.Issue(AId: Integer): TMantisIssue;
var
  Risposta: TJSONObject;
  Elenco: TJSONArray;
begin
  // La risposta ha forma {"issues":[{...}]} anche per un solo id.
  Risposta := GetJson('/issues/' + AId.ToString);
  try
    Elenco := Risposta.GetValue('issues') as TJSONArray;
    if (Elenco = nil) or (Elenco.Count = 0) or not(Elenco.Items[0] is TJSONObject) then
      raise EMantisApiError.CreateFmt('Ticket %d non trovato.', [AId]);
    Result := MantisParseIssue(TJSONObject(Elenco.Items[0]));
  finally
    Risposta.Free;
  end;
end;

function TMantisApi.IssuesByStandardFilter(const AFiltro: string; AProjectId, APage, APageSize: Integer): TArray<TMantisIssue>;
var
  Percorso: string;
  Risposta: TJSONObject;
  Elenco: TJSONArray;
  Elemento: TJSONValue;
begin
  Result := [];
  if APage <= 0 then
    APage := 1;
  if APageSize <= 0 then
    APageSize := 50;

  Percorso := '/issues?filter_id=' + TNetEncoding.Url.Encode(AFiltro.Trim) + '&page=' + APage.ToString + '&page_size=' + APageSize.ToString;
  if AProjectId > 0 then
    Percorso := Percorso + '&project_id=' + AProjectId.ToString;

  Risposta := GetJson(Percorso);
  try
    Elenco := Risposta.GetValue('issues') as TJSONArray;
    if Elenco <> nil then
      for Elemento in Elenco do
        if Elemento is TJSONObject then
          Result := Result + [MantisParseIssue(TJSONObject(Elemento))];
  finally
    Risposta.Free;
  end;
end;

function TMantisApi.ProjectId(const ANome: string): Integer;
var
  Risposta: TJSONObject;
  Elenco: TJSONArray;
  Elemento: TJSONValue;
begin
  Result := 0;
  Risposta := GetJson('/projects');
  try
    Elenco := Risposta.GetValue('projects') as TJSONArray;
    if Elenco <> nil then
      for Elemento in Elenco do
        if Elemento is TJSONObject then
          if SameText(MantisJsonStr(TJSONObject(Elemento), 'name').Trim, ANome.Trim) then
            Exit(MantisJsonInt(TJSONObject(Elemento), 'id'));
  finally
    Risposta.Free;
  end;
end;

function TMantisApi.AddNote(AId: Integer; const ATesto: string; APrivata: Boolean): Integer;
var
  Corpo: TJSONObject;
  Visibilita: TJSONObject;
  Risposta: TJSONObject;
  Nota: TJSONValue;
begin
  Result := 0;
  Corpo := TJSONObject.Create;
  try
    Corpo.AddPair('text', ATesto);
    Visibilita := TJSONObject.Create;
    if APrivata then
      Visibilita.AddPair('name', 'private')
    else
      Visibilita.AddPair('name', 'public');
    Corpo.AddPair('view_state', Visibilita);

    Risposta := SendJson('POST', '/issues/' + AId.ToString + '/notes', Corpo);
    try
      if Risposta <> nil then
      begin
        Nota := Risposta.GetValue('note');
        if Nota is TJSONObject then
          Result := MantisJsonInt(TJSONObject(Nota), 'id');
      end;
    finally
      Risposta.Free;
    end;
  finally
    Corpo.Free;
  end;
end;

function TMantisApi.FileJson(const APercorso: string): TJSONObject;
var
  Contenuto: TBytes;
  Base64: string;
begin
  if (APercorso = '') or not FileExists(APercorso) then
    raise EMantisApiError.CreateFmt('File non trovato: %s', [APercorso]);

  // MantisBT vuole l'allegato come JSON base64, non multipart, senza a-capo MIME.
  Contenuto := TFile.ReadAllBytes(APercorso);
  Base64 := TNetEncoding.Base64.EncodeBytesToString(Contenuto);
  Base64 := Base64.Replace(#13, '').Replace(#10, '');

  Result := TJSONObject.Create;
  Result.AddPair('name', ExtractFileName(APercorso));
  Result.AddPair('content', Base64);
end;

function TMantisApi.AddNoteConAllegati(AId: Integer; const ATesto: string; const APercorsi: TArray<string>; APrivata: Boolean): Integer;
var
  Corpo: TJSONObject;
  Visibilita: TJSONObject;
  Elenco: TJSONArray;
  Percorso: string;
  Risposta: TJSONObject;
  Nota: TJSONValue;
begin
  Result := 0;
  Corpo := TJSONObject.Create;
  try
    Corpo.AddPair('text', ATesto);
    Visibilita := TJSONObject.Create;
    if APrivata then
      Visibilita.AddPair('name', 'private')
    else
      Visibilita.AddPair('name', 'public');
    Corpo.AddPair('view_state', Visibilita);

    // POST /issues/{id}/notes accetta "files" come POST /files: MantisBT li
    // decodifica (files_base64_to_temp) e li lega alla nota appena creata.
    if Length(APercorsi) > 0 then
    begin
      Elenco := TJSONArray.Create;
      Corpo.AddPair('files', Elenco);
      for Percorso in APercorsi do
        Elenco.AddElement(FileJson(Percorso));
    end;

    Risposta := SendJson('POST', '/issues/' + AId.ToString + '/notes', Corpo);
    try
      if Risposta <> nil then
      begin
        Nota := Risposta.GetValue('note');
        if Nota is TJSONObject then
          Result := MantisJsonInt(TJSONObject(Nota), 'id');
      end;
    finally
      Risposta.Free;
    end;
  finally
    Corpo.Free;
  end;
end;

procedure TMantisApi.AttachFile(AId: Integer; const APercorso: string);
var
  Corpo: TJSONObject;
  Elenco: TJSONArray;
  Risposta: TJSONObject;
begin
  Elenco := TJSONArray.Create;
  try
    Elenco.AddElement(FileJson(APercorso));
  except
    Elenco.Free;
    raise;
  end;

  Corpo := TJSONObject.Create;
  try
    Corpo.AddPair('files', Elenco);
    Risposta := SendJson('POST', '/issues/' + AId.ToString + '/files', Corpo);
    Risposta.Free;
  finally
    Corpo.Free;
  end;
end;

procedure TMantisApi.DownloadFile(AId, AFileId: Integer; const ADestinazione: string);
var
  Risposta: TJSONObject;
  Elenco: TJSONArray;
  Contenuto: string;
begin
  // {"files":[{"id":..,"filename":..,"content":"<base64>"}]}
  Risposta := GetJson('/issues/' + AId.ToString + '/files/' + AFileId.ToString);
  try
    Elenco := Risposta.GetValue('files') as TJSONArray;
    if (Elenco = nil) or (Elenco.Count = 0) or not(Elenco.Items[0] is TJSONObject) then
      raise EMantisApiError.CreateFmt('Allegato %d del ticket %d non trovato.', [AFileId, AId]);
    Contenuto := MantisJsonStr(TJSONObject(Elenco.Items[0]), 'content');
    TFile.WriteAllBytes(ADestinazione, TNetEncoding.Base64.DecodeStringToBytes(Contenuto));
  finally
    Risposta.Free;
  end;
end;

procedure TMantisApi.SetStatus(AId: Integer; const AStato: string; const ARisoluzione: string);
var
  Corpo: TJSONObject;
  Stato, Risoluzione: TJSONObject;
  Risposta: TJSONObject;
begin
  Corpo := TJSONObject.Create;
  try
    Stato := TJSONObject.Create;
    Stato.AddPair('name', AStato);
    Corpo.AddPair('status', Stato);
    if ARisoluzione <> '' then
    begin
      Risoluzione := TJSONObject.Create;
      Risoluzione.AddPair('name', ARisoluzione);
      Corpo.AddPair('resolution', Risoluzione);
    end;
    Risposta := SendJson('PATCH', '/issues/' + AId.ToString, Corpo);
    Risposta.Free;
  finally
    Corpo.Free;
  end;
end;

function TMantisApi.ConfigNumero(const AOpzione: string; ADefault: Int64): Int64;
var
  Risposta: TJSONObject;
  Elenco: TJSONArray;
  Valore: TJSONValue;
begin
  Result := ADefault;
  // {"configs":[{"option":"max_file_size","value":5000000}]}. Le opzioni
  // riservate non arrivano: si resta sul valore predefinito, senza errore.
  try
    Risposta := GetJson('/config?option=' + TNetEncoding.Url.Encode(AOpzione));
  except
    Exit;
  end;
  try
    Elenco := Risposta.GetValue('configs') as TJSONArray;
    if (Elenco <> nil) and (Elenco.Count > 0) and (Elenco.Items[0] is TJSONObject) then
    begin
      Valore := TJSONObject(Elenco.Items[0]).GetValue('value');
      if (Valore <> nil) and not(Valore is TJSONNull) then
        if not Valore.TryGetValue<Int64>(Result) then
          Result := StrToInt64Def(Valore.Value, ADefault);
    end;
  finally
    Risposta.Free;
  end;
end;

procedure TMantisApi.CloseIssue(AId: Integer);
begin
  SetStatus(AId, 'closed', 'fixed');
end;

end.
