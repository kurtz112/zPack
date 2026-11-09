unit MantisFiltersTagsEndpoint;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  MantisTypes,
  MantisConnection;

type
  // { TMantisFiltersEndpoint copre il gruppo "Filters":
  // GET /projects/{id}/filters   (filtri salvati visibili per il progetto)
  // GET /issues?filter_id=...    (esecuzione filtro, già coperta da
  // TMantisIssuesEndpoint.Search) }
  TMantisFiltersEndpoint = class
  private
    FConnection: THTTPMantisConnection;
  public
    constructor Create(AConnection: THTTPMantisConnection);
    function GetProjectFilters(AProjectId: Integer): TMantisFilterList;
  end;

  // { TMantisTagsEndpoint copre il gruppo "Tags":
  // GET    /tags
  // GET    /tags/{id }
  // POST / tags PATCH / tags / { id }
  // DELETE / tags / { id } }
  TMantisTagsEndpoint = class
  private
    FConnection: THTTPMantisConnection;
  public
    constructor Create(AConnection: THTTPMantisConnection);
    function GetAll: TMantisTagList;
    function GetById(ATagId: Integer): TMantisTag;
    function Create_(const AName, ADescription: string): TMantisTag;
    procedure Update(ATagId: Integer; APatchBody: TJSONObject);
    procedure DELETE(ATagId: Integer);
  end;

implementation

{ TMantisFiltersEndpoint }

constructor TMantisFiltersEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisFiltersEndpoint.GetProjectFilters(AProjectId: Integer): TMantisFilterList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisFilterList.Create(True);
  LJson := FConnection.Get(Format('/projects/%d/filters', [AProjectId]));
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'filters');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisFilter.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

{ TMantisTagsEndpoint }

constructor TMantisTagsEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisTagsEndpoint.GetAll: TMantisTagList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisTagList.Create(True);
  LJson := FConnection.Get('/tags');
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'tags');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisTag.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

function TMantisTagsEndpoint.GetById(ATagId: Integer): TMantisTag;
var
  LJson: TJSONValue;
  LObj: TJSONObject;
begin
  LJson := FConnection.Get(Format('/tags/%d', [ATagId]));
  try
    LObj := TMantisJSONHelper.GetObj(LJson as TJSONObject, 'tag');
    if LObj <> nil then
      Result := TMantisTag.FromJSON(LObj)
    else
      Result := TMantisTag.FromJSON(LJson as TJSONObject);
  finally
    LJson.Free;
  end;
end;

function TMantisTagsEndpoint.Create_(const AName, ADescription: string): TMantisTag;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LObj: TJSONObject;
begin
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('name', AName);
    if ADescription <> '' then
      LPayload.AddPair('description', ADescription);
    LResponse := FConnection.POST('/tags', LPayload);
  finally
    LPayload.Free;
  end;
  try
    LObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'tag');
    if LObj <> nil then
      Result := TMantisTag.FromJSON(LObj)
    else
      Result := TMantisTag.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisTagsEndpoint.Update(ATagId: Integer; APatchBody: TJSONObject);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.PATCH(Format('/tags/%d', [ATagId]), APatchBody);
  LResponse.Free;
end;

procedure TMantisTagsEndpoint.DELETE(ATagId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.DELETE(Format('/tags/%d', [ATagId]));
  LResponse.Free;
end;

end.
