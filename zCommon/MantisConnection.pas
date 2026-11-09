unit MantisConnection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  System.NetEncoding,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.Net.Mime,
  MantisTypes;

type
  { THTTPMantisConnection incapsula tutte le chiamate HTTP verso l'endpoint
    REST di MantisBT (https://<host>/api/rest). Gestisce:
    - Autenticazione via header 'Authorization: <token>'
    - Serializzazione/deserializzazione JSON di base
    - Mappatura degli errori HTTP/Mantis in EMantisAPIError }
  THTTPMantisConnection = class
  private
    FBaseUrl: string;
    FApiToken: string;
    FHttpClient: THTTPClient;
    FTimeoutMs: Integer;
    function BuildUrl(const APath: string; AQueryParams: TArray < TPair < string, string >> = nil): string;
    procedure ApplyAuthHeader;
    function CheckResponse(AResponse: IHTTPResponse): TJSONValue;
    procedure RaiseFromResponse(AResponse: IHTTPResponse);
  public
    constructor Create(const ABaseUrl, AApiToken: string);
    destructor Destroy; override;

    { Esegue GET su APath (relativo, es. 'issues/123') con eventuali query params.
      Ritorna il TJSONValue del body (proprietà del chiamante, va liberato). }
    function Get(const APath: string; AQueryParams: TArray < TPair < string, string >> = nil): TJSONValue;

    { Esegue GET e ritorna i byte grezzi del body (per download allegati). }
    function GetRaw(const APath: string; out AContentType: string): TBytes;

    function Post(const APath: string; ABody: TJSONValue): TJSONValue;
    function Patch(const APath: string; ABody: TJSONValue): TJSONValue;
    function Put(const APath: string; ABody: TJSONValue): TJSONValue;
    function Delete(const APath: string): TJSONValue;

    { Upload multipart per allegati issue/nota. }
    function PostMultipart(const APath: string; const AFieldName, AFileName: string; AFileStream: TStream; const AContentType: string): TJSONValue;

    property BaseUrl: string read FBaseUrl;
    property TimeoutMs: Integer read FTimeoutMs write FTimeoutMs;
  end;

implementation

{ THTTPMantisConnection }

constructor THTTPMantisConnection.Create(const ABaseUrl, AApiToken: string);
begin
  inherited Create;
  FBaseUrl := ABaseUrl.TrimRight(['/']);
  FApiToken := AApiToken;
  FTimeoutMs := 30000;
  FHttpClient := THTTPClient.Create;
  FHttpClient.ConnectionTimeout := FTimeoutMs;
  FHttpClient.ResponseTimeout := FTimeoutMs;
  FHttpClient.Accept := 'application/json';
end;

destructor THTTPMantisConnection.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

procedure THTTPMantisConnection.ApplyAuthHeader;
begin
  FHttpClient.CustomHeaders['Authorization'] := FApiToken;
end;

function THTTPMantisConnection.BuildUrl(const APath: string; AQueryParams: TArray < TPair < string, string >> ): string;
var
  LPath: string;
  LPair: TPair<string, string>;
  LQuery: string;
begin
  LPath := APath;
  if not LPath.StartsWith('/') then
    LPath := '/' + LPath;
  Result := FBaseUrl + '/api/rest' + LPath;

  if Length(AQueryParams) > 0 then
  begin
    LQuery := '';
    for LPair in AQueryParams do
    begin
      if LQuery <> '' then
        LQuery := LQuery + '&';
      LQuery := LQuery + TNetEncoding.URL.Encode(LPair.Key) + '=' + TNetEncoding.URL.Encode(LPair.Value);
    end;
    Result := Result + '?' + LQuery;
  end;
end;

procedure THTTPMantisConnection.RaiseFromResponse(AResponse: IHTTPResponse);
var
  LBody: TJSONValue;
  LErrObj: TJSONObject;
  LCode: Integer;
  LMsg: string;
begin
  LCode := 0;
  LMsg := AResponse.StatusText;
  try
    LBody := TJSONObject.ParseJSONValue(AResponse.ContentAsString(TEncoding.UTF8));
    try
      if (LBody is TJSONObject) then
      begin
        LErrObj := TMantisJSONHelper.GetObj(TJSONObject(LBody), 'error');
        if LErrObj <> nil then
        begin
          LCode := TMantisJSONHelper.GetInt(LErrObj, 'code');
          LMsg := TMantisJSONHelper.GetStr(LErrObj, 'message', LMsg);
        end
        else
          LMsg := TMantisJSONHelper.GetStr(TJSONObject(LBody), 'message', LMsg);
      end;
    finally
      LBody.Free;
    end;
  except
    { body non-JSON: si mantiene lo StatusText come messaggio }
  end;
  raise EMantisAPIError.Create(AResponse.StatusCode, LCode, LMsg);
end;

function THTTPMantisConnection.CheckResponse(AResponse: IHTTPResponse): TJSONValue;
var
  LRaw: string;
begin
  if (AResponse.StatusCode < 200) or (AResponse.StatusCode >= 300) then
    RaiseFromResponse(AResponse);

  LRaw := AResponse.ContentAsString(TEncoding.UTF8);
  if LRaw.Trim = '' then
    Exit(nil);

  Result := TJSONObject.ParseJSONValue(LRaw);
  if Result = nil then
    raise EMantisConnectionError.CreateFmt('Risposta non JSON valida da %s', [AResponse.MimeType]);
end;

function THTTPMantisConnection.Get(const APath: string; AQueryParams: TArray < TPair < string, string >> ): TJSONValue;
var
  LResponse: IHTTPResponse;
begin
  ApplyAuthHeader;
  LResponse := FHttpClient.Get(BuildUrl(APath, AQueryParams));
  Result := CheckResponse(LResponse);
end;

function THTTPMantisConnection.GetRaw(const APath: string; out AContentType: string): TBytes;
var
  LResponse: IHTTPResponse;
  LStream: TMemoryStream;
begin
  ApplyAuthHeader;
  LStream := TMemoryStream.Create;
  try
    LResponse := FHttpClient.Get(BuildUrl(APath), LStream);
    if (LResponse.StatusCode < 200) or (LResponse.StatusCode >= 300) then
      RaiseFromResponse(LResponse);
    AContentType := LResponse.MimeType;
    LStream.Position := 0;
    SetLength(Result, LStream.Size);
    if LStream.Size > 0 then
      LStream.ReadBuffer(Result[0], LStream.Size);
  finally
    LStream.Free;
  end;
end;

function THTTPMantisConnection.Post(const APath: string; ABody: TJSONValue): TJSONValue;
var
  LResponse: IHTTPResponse;
  LContent: TStringStream;
begin
  ApplyAuthHeader;
  FHttpClient.ContentType := 'application/json';
  LContent := TStringStream.Create('', TEncoding.UTF8);
  try
    if ABody <> nil then
      LContent.WriteString(ABody.ToJSON);
    LContent.Position := 0;
    LResponse := FHttpClient.Post(BuildUrl(APath), LContent, nil, [TNetHeader.Create('Content-Type', 'application/json')]);
    Result := CheckResponse(LResponse);
  finally
    LContent.Free;
  end;
end;

function THTTPMantisConnection.Patch(const APath: string; ABody: TJSONValue): TJSONValue;
var
  LResponse: IHTTPResponse;
  LContent: TStringStream;
begin
  ApplyAuthHeader;
  LContent := TStringStream.Create('', TEncoding.UTF8);
  try
    if ABody <> nil then
      LContent.WriteString(ABody.ToJSON);
    LContent.Position := 0;
    LResponse := FHttpClient.Patch(BuildUrl(APath), LContent, nil, [TNetHeader.Create('Content-Type', 'application/json')]);
    Result := CheckResponse(LResponse);
  finally
    LContent.Free;
  end;
end;

function THTTPMantisConnection.Put(const APath: string; ABody: TJSONValue): TJSONValue;
var
  LResponse: IHTTPResponse;
  LContent: TStringStream;
begin
  ApplyAuthHeader;
  LContent := TStringStream.Create('', TEncoding.UTF8);
  try
    if ABody <> nil then
      LContent.WriteString(ABody.ToJSON);
    LContent.Position := 0;
    LResponse := FHttpClient.Put(BuildUrl(APath), LContent, nil, [TNetHeader.Create('Content-Type', 'application/json')]);
    Result := CheckResponse(LResponse);
  finally
    LContent.Free;
  end;
end;

function THTTPMantisConnection.Delete(const APath: string): TJSONValue;
var
  LResponse: IHTTPResponse;
begin
  ApplyAuthHeader;
  LResponse := FHttpClient.Delete(BuildUrl(APath));
  Result := CheckResponse(LResponse);
end;

function THTTPMantisConnection.PostMultipart(const APath, AFieldName, AFileName: string; AFileStream: TStream; const AContentType: string): TJSONValue;
var
  LResponse: IHTTPResponse;
  LForm: TMultipartFormData;
begin
  ApplyAuthHeader;
  LForm := TMultipartFormData.Create;
  try
    LForm.AddStream(AFieldName, AFileStream, AFileName, AContentType);
    LResponse := FHttpClient.Post(BuildUrl(APath), LForm);
    Result := CheckResponse(LResponse);
  finally
    LForm.Free;
  end;
end;

end.
