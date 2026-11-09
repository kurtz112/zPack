unit MantisConfigEndpoint;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  MantisTypes,
  MantisConnection;

type
  // { TMantisConfigEndpoint copre il gruppo "Config":
  // GET /config/{option_name}?project_id=&user_id=
  // TMantisLangEndpoint copre il gruppo "Localization":
  // GET /lang?string[]=... }
  TMantisConfigEndpoint = class
  private
    FConnection: THTTPMantisConnection;
  public
    constructor Create(AConnection: THTTPMantisConnection);
    { AProjectId/AUserId opzionali (0 = non specificato): permettono di
      leggere la config con l'override di progetto/utente, come fa Mantis
      internamente per risolvere i valori. }
    function GetOption(const AOptionName: string; AProjectId: Integer = 0; AUserId: Integer = 0): TMantisConfigOption;
  end;

  TMantisLangEndpoint = class
  private
    FConnection: THTTPMantisConnection;
  public
    constructor Create(AConnection: THTTPMantisConnection);
    { Ritorna dizionario nome-stringa -> valore localizzato, per la lingua
      dell'utente autenticato. Le chiavi non definite vengono filtrate da Mantis. }
    function GetStrings(const AStringNames: TArray<string>): TDictionary<string, string>;
  end;

implementation

{ TMantisConfigEndpoint }

constructor TMantisConfigEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisConfigEndpoint.GetOption(const AOptionName: string; AProjectId, AUserId: Integer): TMantisConfigOption;
var
  LParams: TList<TPair<string, string>>;
  LJson: TJSONValue;
  LValue: TJSONValue;
begin
  LParams := TList < TPair < string, string >>.Create;
  try
    if AProjectId > 0 then
      LParams.Add(TPair<string, string>.Create('project_id', AProjectId.ToString));
    if AUserId > 0 then
      LParams.Add(TPair<string, string>.Create('user_id', AUserId.ToString));

    LJson := FConnection.Get('/config/' + AOptionName, LParams.ToArray);
    try
      LValue := (LJson as TJSONObject).GetValue('value');
      Result := TMantisConfigOption.FromJSON(AOptionName, LValue);
    finally
      LJson.Free;
    end;
  finally
    LParams.Free;
  end;
end;

{ TMantisLangEndpoint }

constructor TMantisLangEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisLangEndpoint.GetStrings(const AStringNames: TArray<string>): TDictionary<string, string>;
var
  LParams: TList<TPair<string, string>>;
  LName: string;
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
  LObj: TJSONObject;
begin
  Result := TDictionary<string, string>.Create;
  LParams := TList < TPair < string, string >>.Create;
  try
    for LName in AStringNames do
      LParams.Add(TPair<string, string>.Create('string[]', LName));

    LJson := FConnection.Get('/lang', LParams.ToArray);
    try
      LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'strings');
      if LArr <> nil then
        for LItem in LArr do
          if LItem is TJSONObject then
          begin
            LObj := TJSONObject(LItem);
            Result.AddOrSetValue(TMantisJSONHelper.GetStr(LObj, 'name'), TMantisJSONHelper.GetStr(LObj, 'value'));
          end;
    finally
      LJson.Free;
    end;
  finally
    LParams.Free;
  end;
end;

end.
