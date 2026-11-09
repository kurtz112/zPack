unit MantisIssuesEndpoint;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  MantisTypes,
  MantisConnection;

type
  // { TMantisIssuesEndpoint copre il gruppo "Issues" della REST API:
  // GET    /issues/{id}
  // GET    /issues                (ricerca/filtro)
  // POST   /issues
  // PATCH  /issues/{id}
  // DELETE /issues/{id}
  // GET    /issues/{id}/notes
  // POST   /issues/{id}/notes
  // PATCH  /issues/{id}/notes/{note_id}
  // DELETE /issues/{id}/notes/{note_id}
  // GET    /issues/{id}/attachments/{attachment_id}   (download)
  // POST   /issues/{id}/files                          (upload allegato)
  // DELETE /issues/{id}/attachments/{attachment_id}
  // POST   /issues/{id}/relationships
  // DELETE /issues/{id}/relationships/{relationship_id}
  // POST   /issues/{id}/tags
  // DELETE /issues/{id}/tags/{tag_id}
  // PUT    /issues/{id}/monitors
  // DELETE /issues/{id}/monitors/{user_id}
  // GET    /issues/{id}/history }
  TMantisIssuesEndpoint = class
  private
    FConnection: THTTPMantisConnection;
    function IssuesArrayFromResponse(AJson: TJSONValue): TMantisIssueList;
  public
    constructor Create(AConnection: THTTPMantisConnection);

    { --- CRUD issue --- }
    function GetById(AIssueId: Integer): TMantisIssue;

    { Ricerca issue. AFilterId: id di un filtro salvato (0 = nessuno).
      AProjectId: 0 = tutti i progetti accessibili.
      APage/APageSize: paginazione (default Mantis: page=1, page_size=50). }
    function Search(AProjectId: Integer = 0; AFilterId: Integer = 0; APage: Integer = 1; APageSize: Integer = 50): TMantisIssueList;

    function Create_(AIssue: TMantisIssue): TMantisIssue;
    procedure Update(AIssueId: Integer; APatchBody: TJSONObject);
    procedure Delete(AIssueId: Integer);

    { --- Note (bugnotes) --- }
    function GetNotes(AIssueId: Integer): TMantisNoteList;
    function AddNote(AIssueId: Integer; ANote: TMantisNote): TMantisNote;
    procedure UpdateNote(AIssueId, ANoteId: Integer; const AText: string);
    procedure DeleteNote(AIssueId, ANoteId: Integer);

    { --- Allegati --- }
    function AddAttachment(AIssueId: Integer; const AFileName: string; AFileStream: TStream; const AContentType: string): TMantisAttachment;
    function DownloadAttachment(AIssueId, AAttachmentId: Integer; out AContentType: string): TBytes;
    procedure DeleteAttachment(AIssueId, AAttachmentId: Integer);

    { --- Relazioni --- }
    function AddRelationship(AIssueId: Integer; ARelationship: TMantisRelationship): TMantisIssue;
    procedure DeleteRelationship(AIssueId, ARelationshipId: Integer);

    { --- Tag --- }
    procedure AddTag(AIssueId, ATagId: Integer);
    procedure RemoveTag(AIssueId, ATagId: Integer);

    { --- Monitor --- }
    procedure AddMonitor(AIssueId, AUserId: Integer);
    procedure RemoveMonitor(AIssueId, AUserId: Integer);

    { --- History --- }
    function GetHistory(AIssueId: Integer): TMantisHistoryEventList;
  end;

implementation

uses
  System.NetEncoding;

constructor TMantisIssuesEndpoint.Create(AConnection: THTTPMantisConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMantisIssuesEndpoint.IssuesArrayFromResponse(AJson: TJSONValue): TMantisIssueList;
var
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisIssueList.Create(True);
  if AJson = nil then
    Exit;
  LArr := TMantisJSONHelper.GetArr(AJson as TJSONObject, 'issues');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.Add(TMantisIssue.FromJSON(TJSONObject(LItem)));
end;

function TMantisIssuesEndpoint.GetById(AIssueId: Integer): TMantisIssue;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
begin
  LJson := FConnection.Get(Format('/issues/%d', [AIssueId]));
  try
    // { La risposta è { "issues": [ {...} ] } }
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'issues');
    if (LArr <> nil) and (LArr.Count > 0) then
      Result := TMantisIssue.FromJSON(LArr.Items[0] as TJSONObject)
    else
      Result := nil;
  finally
    LJson.Free;
  end;
end;

function TMantisIssuesEndpoint.Search(AProjectId, AFilterId, APage, APageSize: Integer): TMantisIssueList;
var
  LParams: TArray<TPair<string, string>>;
  LJson: TJSONValue;
  LList: TList<TPair<string, string>>;
begin
  LList := TList < TPair < string, string >>.Create;
  try
    if AProjectId > 0 then
      LList.Add(TPair<string, string>.Create('project_id', AProjectId.ToString));
    if AFilterId > 0 then
      LList.Add(TPair<string, string>.Create('filter_id', AFilterId.ToString));
    LList.Add(TPair<string, string>.Create('page', APage.ToString));
    LList.Add(TPair<string, string>.Create('page_size', APageSize.ToString));
    LParams := LList.ToArray;
  finally
    LList.Free;
  end;

  LJson := FConnection.Get('/issues', LParams);
  try
    Result := IssuesArrayFromResponse(LJson);
  finally
    LJson.Free;
  end;
end;

function TMantisIssuesEndpoint.Create_(AIssue: TMantisIssue): TMantisIssue;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LIssueObj: TJSONObject;
begin
  LPayload := AIssue.ToCreatePayload;
  try
    LResponse := FConnection.Post('/issues', LPayload);
  finally
    LPayload.Free;
  end;
  try
    LIssueObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'issue');
    if LIssueObj <> nil then
      Result := TMantisIssue.FromJSON(LIssueObj)
    else
      Result := TMantisIssue.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisIssuesEndpoint.Update(AIssueId: Integer; APatchBody: TJSONObject);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Patch(Format('/issues/%d', [AIssueId]), APatchBody);
  LResponse.Free;
end;

procedure TMantisIssuesEndpoint.Delete(AIssueId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/issues/%d', [AIssueId]));
  LResponse.Free;
end;

function TMantisIssuesEndpoint.GetNotes(AIssueId: Integer): TMantisNoteList;
var
  LIssue: TMantisIssue;
begin
  { L'API Mantis non espone un endpoint dedicato di sola lettura per le note:
    sono incluse nel dettaglio issue. Si recupera l'issue e si estraggono. }
  Result := TMantisNoteList.Create(True);
  LIssue := GetById(AIssueId);
  try
    if LIssue <> nil then
      while LIssue.Notes.Count > 0 do
      begin
        Result.Add(LIssue.Notes[0]);
        LIssue.Notes.Extract(LIssue.Notes[0]);
      end;
  finally
    LIssue.Free;
  end;
end;

function TMantisIssuesEndpoint.AddNote(AIssueId: Integer; ANote: TMantisNote): TMantisNote;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LNoteObj: TJSONObject;
begin
  LPayload := ANote.ToJSON;
  try
    LResponse := FConnection.Post(Format('/issues/%d/notes', [AIssueId]), LPayload);
  finally
    LPayload.Free;
  end;
  try
    LNoteObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'note');
    if LNoteObj <> nil then
      Result := TMantisNote.FromJSON(LNoteObj)
    else
      Result := TMantisNote.FromJSON(LResponse as TJSONObject);
  finally
    LResponse.Free;
  end;
end;

procedure TMantisIssuesEndpoint.UpdateNote(AIssueId, ANoteId: Integer; const AText: string);
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
begin
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('text', AText);
    LResponse := FConnection.Patch(Format('/issues/%d/notes/%d', [AIssueId, ANoteId]), LPayload);
    LResponse.Free;
  finally
    LPayload.Free;
  end;
end;

procedure TMantisIssuesEndpoint.DeleteNote(AIssueId, ANoteId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/issues/%d/notes/%d', [AIssueId, ANoteId]));
  LResponse.Free;
end;

function TMantisIssuesEndpoint.AddAttachment(AIssueId: Integer; const AFileName: string; AFileStream: TStream; const AContentType: string): TMantisAttachment;
var
  LResponse: TJSONValue;
  LArr: TJSONArray;
begin
  LResponse := FConnection.PostMultipart(Format('/issues/%d/files', [AIssueId]), 'file', AFileName, AFileStream, AContentType);
  try
    LArr := TMantisJSONHelper.GetArr(LResponse as TJSONObject, 'files');
    if (LArr <> nil) and (LArr.Count > 0) then
      Result := TMantisAttachment.FromJSON(LArr.Items[0] as TJSONObject)
    else
      Result := nil;
  finally
    LResponse.Free;
  end;
end;

function TMantisIssuesEndpoint.DownloadAttachment(AIssueId, AAttachmentId: Integer; out AContentType: string): TBytes;
var
  LResponse: TJSONValue;
  LArr: TJSONArray;
  LFileObj: TJSONObject;
begin
  LResponse := FConnection.Get(Format('/issues/%d/files/%d', [AIssueId, AAttachmentId]));
  try
    LArr := TMantisJSONHelper.GetArr(LResponse as TJSONObject, 'files');
    if (LArr = nil) or (LArr.Count = 0) then
      raise EMantisAPIError.Create(404, 0, Format('Allegato #%d non trovato sul ticket #%d.', [AAttachmentId, AIssueId]));
    LFileObj := LArr.Items[0] as TJSONObject;
    AContentType := TMantisJSONHelper.GetStr(LFileObj, 'content_type');
    Result := TNetEncoding.Base64.DecodeStringToBytes(TMantisJSONHelper.GetStr(LFileObj, 'content'));
  finally
    LResponse.Free;
  end;
end;

procedure TMantisIssuesEndpoint.DeleteAttachment(AIssueId, AAttachmentId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/issues/%d/attachments/%d', [AIssueId, AAttachmentId]));
  LResponse.Free;
end;

function TMantisIssuesEndpoint.AddRelationship(AIssueId: Integer; ARelationship: TMantisRelationship): TMantisIssue;
var
  LPayload: TJSONObject;
  LResponse: TJSONValue;
  LIssueObj: TJSONObject;
begin
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('relationship', ARelationship.ToJSON);
    LResponse := FConnection.Post(Format('/issues/%d/relationships', [AIssueId]), LPayload);
  finally
    LPayload.Free;
  end;
  try
    LIssueObj := TMantisJSONHelper.GetObj(LResponse as TJSONObject, 'issue');
    if LIssueObj <> nil then
      Result := TMantisIssue.FromJSON(LIssueObj)
    else
      Result := nil;
  finally
    LResponse.Free;
  end;
end;

procedure TMantisIssuesEndpoint.DeleteRelationship(AIssueId, ARelationshipId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/issues/%d/relationships/%d', [AIssueId, ARelationshipId]));
  LResponse.Free;
end;

procedure TMantisIssuesEndpoint.AddTag(AIssueId, ATagId: Integer);
var
  LPayload, LTags: TJSONObject;
  LArr: TJSONArray;
  LResponse: TJSONValue;
begin
  LArr := TJSONArray.Create;
  LTags := TJSONObject.Create;
  LTags.AddPair('id', TJSONNumber.Create(ATagId));
  LArr.AddElement(LTags);
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('tags', LArr);
    LResponse := FConnection.Post(Format('/issues/%d/tags', [AIssueId]), LPayload);
    LResponse.Free;
  finally
    LPayload.Free;
  end;
end;

procedure TMantisIssuesEndpoint.RemoveTag(AIssueId, ATagId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/issues/%d/tags/%d', [AIssueId, ATagId]));
  LResponse.Free;
end;

procedure TMantisIssuesEndpoint.AddMonitor(AIssueId, AUserId: Integer);
var
  LPayload, LUser: TJSONObject;
  LResponse: TJSONValue;
begin
  LUser := TJSONObject.Create;
  LUser.AddPair('id', TJSONNumber.Create(AUserId));
  LPayload := TJSONObject.Create;
  try
    LPayload.AddPair('user', LUser);
    LResponse := FConnection.Put(Format('/issues/%d/monitors', [AIssueId]), LPayload);
    LResponse.Free;
  finally
    LPayload.Free;
  end;
end;

procedure TMantisIssuesEndpoint.RemoveMonitor(AIssueId, AUserId: Integer);
var
  LResponse: TJSONValue;
begin
  LResponse := FConnection.Delete(Format('/issues/%d/monitors/%d', [AIssueId, AUserId]));
  LResponse.Free;
end;

function TMantisIssuesEndpoint.GetHistory(AIssueId: Integer): TMantisHistoryEventList;
var
  LJson: TJSONValue;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  Result := TMantisHistoryEventList.Create(True);
  LJson := FConnection.Get(Format('/issues/%d/history', [AIssueId]));
  try
    LArr := TMantisJSONHelper.GetArr(LJson as TJSONObject, 'history');
    if LArr <> nil then
      for LItem in LArr do
        if LItem is TJSONObject then
          Result.Add(TMantisHistoryEvent.FromJSON(TJSONObject(LItem)));
  finally
    LJson.Free;
  end;
end;

end.
