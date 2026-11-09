unit zz.JsonResponse;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Json;

type
  TJsonResponse = class
  private
    FErrorMsg: string;
    ParsedObject: TJSONObject;
    FJSONValue: TJSONValue;
    FJSONObject: TJSONObject;
    FResult: boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Parse(const s: string; doRaiseError: boolean = True); overload;
    procedure Parse(const Stream: TStream; doRaiseError: boolean = True); overload;
    procedure RaiseError;
  public
    property Result: boolean read FResult;
    property ErrorMsg: string read FErrorMsg;
    property JSONValue: TJSONValue read FJSONValue;
    property JSONObject: TJSONObject read FJSONObject;
  end;

implementation

uses
  zz.Lib;

{ TJsonResponse }

constructor TJsonResponse.Create;
begin
  inherited;
  FResult := false;
  FErrorMsg := '';

  ParsedObject := nil;
  FJSONValue := nil;
  FJSONObject := nil;
end;

destructor TJsonResponse.Destroy;
begin
  FreeAndNil(ParsedObject);
  // sono proprietà di parsed
  // FreeAndNil(FJSONValue);
  // FreeAndNil(FJSONObject);
  inherited;
end;

procedure TJsonResponse.Parse(const s: string; doRaiseError: boolean);
begin
  FResult := false;

  ParsedObject := TJSONObject.Create;
  if ParsedObject.Parse(BytesOf(s), 0) >= 0 then
  begin
    if not ParsedObject.tryGetValue<boolean>('success', FResult) then
      FErrorMsg := 'Struttura json del messaggio di risposta non valida.'
    else
    begin
      if not ParsedObject.tryGetValue<TJSONValue>('result', FJSONValue) then
        FErrorMsg := 'Struttura json del messaggio di risposta non valida.';

      if FJSONValue is TJSONObject then
        FJSONObject := FJSONValue as TJSONObject;

      if not Result then
        if not ParsedObject.tryGetValue<string>('error', FErrorMsg) then
          FErrorMsg := 'Struttura json del messaggio di risposta non valida.';
    end;
  end
  else
    FErrorMsg := 'Json non valido.';

  if not Result then
    if FErrorMsg <> '' then
      if doRaiseError then
        RaiseError;
end;

procedure TJsonResponse.Parse(const Stream: TStream; doRaiseError: boolean = True);
var
  s: string;
  StringStream: TStringStream;
begin
  Assert(Assigned(Stream));

  StringStream := TStringStream.Create;
  try
    StringStream.CopyFrom(Stream, 0);
    s := StringStream.DataString;
  finally
    FreeAndNil(StringStream);
  end;

  Parse(s, doRaiseError);
end;

procedure TJsonResponse.RaiseError;
begin
  if ErrorMsg <> '' then
    raise exception.Create(ErrorMsg);
end;

end.
