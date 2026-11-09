unit MantisProjectsEndpoint;

interface

uses
  System.SysUtils,
  System.JSON,
  MantisTypes,
  MantisConnection;

type
  // { TMantisProjectsEndpoint copre il gruppo "Projects":
  // GET    /projects
  // GET    /projects/{id}
  // POST   /projects
  // PATCH  /projects/{id}
  // DELETE /projects/{id}
  // GET    /projects/{id}/versions
  // POST   /projects/{id}/versions
  // PATCH  /projects/{id}/versions/{version_id}
  // DELETE /projects/{id}/versions/{version_id}
  // GET    /projects/{id}/categories
  // POST   /projects/{id}/categories
  // PATCH  /projects/{id}/categories/{category_id}
  // DELETE /projects/{id}/categories/{category_id} }
  TMantisProjectsEndpoint = class
  private
    FConnection: THTTPMantisConnection;
  public
    constructor Create(AConnection: THTTPMantisConnection);

    function GetAll: TMantisProjectList;
    function GetById(AProjectId: Integer): TMantisProject;
    function Create_(const AName, ADescription: string; AEnabled: Boolean = True): TMantisProject;
    procedure Update(AProjectId: Integer; APatchBody: TJSONObject);
    procedure Delete(AProjectId: Integer);

    function GetVersions(AProjectId: Integer): TMantisVersionList;
    function AddVersion(AProjectId: Integer; AVersion: TMantisVersion): TMantisVersion;
    procedure UpdateVersion(AProjectId, AVersionId: Integer; APatchBody: TJSONObject);
    procedure DeleteVersion(AProjectId, AVersionId: Integer);

    function GetCategories(AProjectId: Integer): TMantisCategoryList;
    function AddCategory(AProjectId: Integer; ACategory: TMantisCategory): TMantisCategory;
    procedure UpdateCategory(AProjectId, ACategoryId: Integer; APatchBody: TJSONObject);
    procedure DeleteCategory(AProjectId, ACategoryId: Integer);

    // { --- Utenti di progetto ---
    // ATTENZIONE: path inferito per convenzione con /versions e /categories
    // (POST /projects/{id } / users).Non ho potuto confermarlo contro la
    // documentazione ufficiale (introdotto nel core in una PR del 2023).
    // Verificare con una chiamata di prova sulla tua istanza; se il path
    // reale è diverso, è una modifica isolata a queste due funzioni. }
    function AddUserToProject(AProjectId, AUserId: Integer; AAccessLevel: TMantisEnum = nil): TJSONObject;
    procedure RemoveUserFromProject(AProjectId, AUserId: Integer);
  end;

implementation

constructor TMantisProjectsEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisProjectsEndpoint.GetAll: TMantisProjectList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisProjectList.Create(True);
  LJson := FConnection.Get('/projects');
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'projects');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisProject.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

function TMantisProjectsEndpoint.GetById(AProjectId: Integer): TMantisProject;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
begin
  LJson := FConnection.Get(Format('/projects/%d', [AProjectId]));
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'projects');
    if (LArr <> nil) and (LArr.Count > 0) then
      Result := TMantisProject.FromJSON(LArr.Items[0] as TJSONObject)
    else
      Result := nil;
  finally
    LJson.Free;
  end;
end;

function TMantisProjectsEndpoint.Create_(

  const AName, ADescription: string; AEnabled: Boolean): TMantisProject;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LProjObj: TJSONObject;
begin
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('name', AName);
    if ADescription <> '' then
      LPayload.AddPair('description', ADescription);
    LPayload.AddPair('enabled', TJSONBool.Create(AEnabled));
    LResponse := FConnection.Post('/projects', LPayload);
  finally
    LPayload.Free;
  end;
  try
    LProjObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'project');
    if LProjObj <> nil then
      Result := TMantisProject.FromJSON(LProjObj)
    else
      Result := TMantisProject.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisProjectsEndpoint.Update(AProjectId: Integer; APatchBody: TJSONObject);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Patch(Format('/projects/%d', [AProjectId]), APatchBody);
  LResponse.Free;
end;

procedure TMantisProjectsEndpoint.Delete(AProjectId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/projects/%d', [AProjectId]));
  LResponse.Free;
end;

function TMantisProjectsEndpoint.GetVersions(AProjectId: Integer): TMantisVersionList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisVersionList.Create(True);
  LJson := FConnection.Get(Format('/projects/%d/versions', [AProjectId]));
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'versions');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisVersion.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

function TMantisProjectsEndpoint.AddVersion(AProjectId: Integer; AVersion: TMantisVersion): TMantisVersion;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LObj: TJSONObject;
begin
  LPayload := AVersion.ToJSON;
  try
    LResponse := FConnection.Post(Format('/projects/%d/versions', [AProjectId]), LPayload);
  finally
    LPayload.Free;
  end;
  try
    LObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'version');
    if LObj <> nil then
      Result := TMantisVersion.FromJSON(LObj)
    else
      Result := TMantisVersion.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisProjectsEndpoint.UpdateVersion(AProjectId, AVersionId: Integer; APatchBody: TJSONObject);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Patch(Format('/projects/%d/versions/%d', [AProjectId, AVersionId]), APatchBody);
  LResponse.Free;
end;

procedure TMantisProjectsEndpoint.DeleteVersion(AProjectId, AVersionId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/projects/%d/versions/%d', [AProjectId, AVersionId]));
  LResponse.Free;
end;

function TMantisProjectsEndpoint.GetCategories(AProjectId: Integer): TMantisCategoryList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisCategoryList.Create(True);
  LJson := FConnection.Get(Format('/projects/%d/categories', [AProjectId]));
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'categories');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisCategory.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

function TMantisProjectsEndpoint.AddCategory(AProjectId: Integer; ACategory: TMantisCategory): TMantisCategory;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LObj: TJSONObject;
begin
  LPayload := ACategory.ToJSON;
  try
    LResponse := FConnection.Post(Format('/projects/%d/categories', [AProjectId]), LPayload);
  finally
    LPayload.Free;
  end;
  try
    LObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'category');
    if LObj <> nil then
      Result := TMantisCategory.FromJSON(LObj)
    else
      Result := TMantisCategory.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisProjectsEndpoint.UpdateCategory(AProjectId, ACategoryId: Integer; APatchBody: TJSONObject);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Patch(Format('/projects/%d/categories/%d', [AProjectId, ACategoryId]), APatchBody);
  LResponse.Free;
end;

procedure TMantisProjectsEndpoint.DeleteCategory(AProjectId, ACategoryId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/projects/%d/categories/%d', [AProjectId, ACategoryId]));
  LResponse.Free;
end;

function TMantisProjectsEndpoint.AddUserToProject(AProjectId, AUserId: Integer; AAccessLevel: TMantisEnum): TJSONObject;
var
  LPayload, LUser: TJSONObject;
  LResponse: TJSONValue;
begin
  LUser := TJSONObject.Create;
  LUser.AddPair('id', TJSONNumber.Create(AUserId));
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('user', LUser);
    if AAccessLevel <> nil then
      LPayload.AddPair('access_level', AAccessLevel.ToJSON);
    LResponse := FConnection.Post(Format('/projects/%d/users', [AProjectId]), LPayload);
  finally
    LPayload.Free;
  end;
  { Ritorna il body grezzo: la forma esatta della risposta non è confermata
    (v. commento nella dichiarazione), il chiamante può ispezionarla. }
  Result := LResponse as TJSONObject;
end;

procedure TMantisProjectsEndpoint.RemoveUserFromProject(AProjectId, AUserId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/projects/%d/users/%d', [AProjectId, AUserId]));
  LResponse.Free;
end;

end.
