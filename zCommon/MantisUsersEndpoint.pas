unit MantisUsersEndpoint;

interface

uses
  System.SysUtils,
  System.JSON,
  MantisTypes,
  MantisConnection;

type
  // { TMantisUsersEndpoint copre il gruppo "Users":
  // GET    /users/me
  // PATCH  /users/me
  // PUT    /users/me/password
  // GET    /users                (richiede ADMINISTRATOR)
  // POST   /users                (richiede ADMINISTRATOR)
  // DELETE /users/{id}           (richiede ADMINISTRATOR)
  // GET    /projects/{id}/users  (utenti assegnabili in un progetto) }
  TMantisUsersEndpoint = class
  private
    FConnection: THTTPMantisConnection;
  public
    constructor Create(AConnection: THTTPMantisConnection);

    function GetCurrentUser: TMantisUser;
    procedure UpdateCurrentUser(APatchBody: TJSONObject);
    procedure ChangePassword(const ANewPassword: string);

    function GetAllUsers: TMantisUserList;
    function CreateUser(AUser: TMantisUser; const APassword: string): TMantisUser;
    procedure DeleteUser(AUserId: Integer);

    function GetProjectUsers(AProjectId: Integer): TMantisUserList;
  end;

implementation

constructor TMantisUsersEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisUsersEndpoint.GetCurrentUser: TMantisUser;
var
  LJson: TJSONValue;
  LObj: TJSONObject;
begin
  LJson := FConnection.Get('/users/me');
  try
    LObj := TMantisJSONHelper.GetObj(LJson as TJSONObject, 'user');
    if LObj <> nil then
      Result := TMantisUser.FromJSON(LObj)
    else
      Result := TMantisUser.FromJSON(LJson as TJSONObject);
  finally
    LJson.Free;
  end;
end;

procedure TMantisUsersEndpoint.UpdateCurrentUser(APatchBody: TJSONObject);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Patch('/users/me', APatchBody);
  LResponse.Free;
end;

procedure TMantisUsersEndpoint.ChangePassword(const ANewPassword: string);
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
begin
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('password', ANewPassword);
    LResponse := FConnection.Put('/users/me/password', LPayload);
    LResponse.Free;
  finally
    LPayload.Free;
  end;
end;

function TMantisUsersEndpoint.GetAllUsers: TMantisUserList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisUserList.Create(True);
  LJson := FConnection.Get('/users');
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'users');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisUser.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

function TMantisUsersEndpoint.CreateUser(AUser: TMantisUser; const APassword: string): TMantisUser;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LObj: TJSONObject;
begin
  LPayload := AUser.ToJSON;
  try
    if APassword <> '' then
      LPayload.AddPair('password', APassword);
    LResponse := FConnection.Post('/users', LPayload);
  finally
    LPayload.Free;
  end;
  try
    LObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'user');
    if LObj <> nil then
      Result := TMantisUser.FromJSON(LObj)
    else
      Result := TMantisUser.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisUsersEndpoint.DeleteUser(AUserId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/users/%d', [AUserId]));
  LResponse.Free;
end;

function TMantisUsersEndpoint.GetProjectUsers(AProjectId: Integer): TMantisUserList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisUserList.Create(True);
  LJson := FConnection.Get(Format('/projects/%d/users', [AProjectId]));
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'users');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisUser.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

end.
