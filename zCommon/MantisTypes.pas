unit MantisTypes;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  System.DateUtils;

type
  { ==================== ECCEZIONI ==================== }

  EMantisAPIError = class(Exception)
  private
    FStatusCode: Integer;
    FErrorCode: Integer;
    FErrorMessage: string;
  public
    constructor Create(AStatusCode, AErrorCode: Integer; const AErrorMessage: string);
    property StatusCode: Integer read FStatusCode;
    property ErrorCode: Integer read FErrorCode;
    property ErrorMessage: string read FErrorMessage;
  end;

  EMantisConnectionError = class(Exception);

  { ==================== ENUM-OGGETTI (id/name/label/color) ====================
    Mantis rappresenta priority/severity/status/reproducibility/resolution/
    view_state/access_level/relationship_type ecc. come oggetti {id,name,label,color}

  TMantisEnum = class
  private
    FId: Integer;
    FName: string;
    FLabelText: string;
    FColor: string;
  public
    constructor Create; overload;
    constructor Create(AId: Integer; const AName, ALabelText: string); overload;
    class function FromJSON(AJson: TJSONObject): TMantisEnum;
    function ToJSON: TJSONObject;
    function Clone: TMantisEnum;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property LabelText: string read FLabelText write FLabelText;
    property Color: string read FColor write FColor;
  end;

  { ==================== RIFERIMENTI BASE ==================== }

  TMantisUserRef = class
  private
    FId: Integer;
    FName: string;
    FRealName: string;
    FEmail: string;
  public
    class function FromJSON(AJson: TJSONObject): TMantisUserRef;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property RealName: string read FRealName write FRealName;
    property Email: string read FEmail write FEmail;
  end;

  TMantisProjectRef = class
  private
    FId: Integer;
    FName: string;
  public
    class function FromJSON(AJson: TJSONObject): TMantisProjectRef;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
  end;

  TMantisProjectRefList = TObjectList<TMantisProjectRef>;

  { ==================== CUSTOM FIELD ==================== }

  TMantisCustomFieldValue = class
  private
    FFieldId: Integer;
    FFieldName: string;
    FValue: string;
  public
    class function FromJSON(AJson: TJSONObject): TMantisCustomFieldValue;
    function ToJSON: TJSONObject;
    property FieldId: Integer read FFieldId write FFieldId;
    property FieldName: string read FFieldName write FFieldName;
    property Value: string read FValue write FValue;
  end;

  TMantisCustomFieldValueList = TObjectList<TMantisCustomFieldValue>;

  { ==================== TAG ==================== }

  TMantisTag = class
  private
    FId: Integer;
    FName: string;
    FDescription: string;
  public
    class function FromJSON(AJson: TJSONObject): TMantisTag;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
  end;

  TMantisTagList = TObjectList<TMantisTag>;

  { ==================== ATTACHMENT ==================== }

  TMantisAttachment = class
  private
    FId: Integer;
    FFilename: string;
    FSize: Int64;
    FContentType: string;
    FDownloadUrl: string;
    FCreatedAt: TDateTime;
    FReporter: TMantisUserRef;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisAttachment;
    property Id: Integer read FId write FId;
    property Filename: string read FFilename write FFilename;
    property Size: Int64 read FSize write FSize;
    property ContentType: string read FContentType write FContentType;
    property DownloadUrl: string read FDownloadUrl write FDownloadUrl;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property Reporter: TMantisUserRef read FReporter write FReporter;
  end;

  TMantisAttachmentList = TObjectList<TMantisAttachment>;

  { ==================== NOTE (bugnote) ==================== }

  TMantisNote = class
  private
    FId: Integer;
    FReporter: TMantisUserRef;
    FText: string;
    FViewState: TMantisEnum;
    FNoteType: TMantisEnum;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
    FAttachments: TMantisAttachmentList;
  public
    constructor Create;
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisNote;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Reporter: TMantisUserRef read FReporter write FReporter;
    property Text: string read FText write FText;
    property ViewState: TMantisEnum read FViewState write FViewState;
    property NoteType: TMantisEnum read FNoteType write FNoteType;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Attachments: TMantisAttachmentList read FAttachments;
  end;

  TMantisNoteList = TObjectList<TMantisNote>;

  { ==================== RELATIONSHIP ==================== }

  TMantisRelationship = class
  private
    FId: Integer;
    FRelationType: TMantisEnum;
    FTargetIssueId: Integer;
    FTargetIssueSummary: string;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisRelationship;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property RelationType: TMantisEnum read FRelationType write FRelationType;
    property TargetIssueId: Integer read FTargetIssueId write FTargetIssueId;
    property TargetIssueSummary: string read FTargetIssueSummary write FTargetIssueSummary;
  end;

  TMantisRelationshipList = TObjectList<TMantisRelationship>;

  { ==================== HISTORY EVENT ==================== }

  TMantisHistoryEvent = class
  private
    FCreatedAt: TDateTime;
    FUser: TMantisUserRef;
    FFieldName: string;
    FOldValue: string;
    FNewValue: string;
    FEventType: TMantisEnum;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisHistoryEvent;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UserRef: TMantisUserRef read FUser write FUser;
    property FieldName: string read FFieldName write FFieldName;
    property OldValue: string read FOldValue write FOldValue;
    property NewValue: string read FNewValue write FNewValue;
    property EventType: TMantisEnum read FEventType write FEventType;
  end;

  TMantisHistoryEventList = TObjectList<TMantisHistoryEvent>;

  { ==================== VERSION / CATEGORY ==================== }

  TMantisVersion = class
  private
    FId: Integer;
    FName: string;
    FDescription: string;
    FReleased: Boolean;
    FObsolete: Boolean;
    FTimestamp: TDateTime;
    FProject: TMantisProjectRef;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisVersion;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Released: Boolean read FReleased write FReleased;
    property Obsolete: Boolean read FObsolete write FObsolete;
    property Timestamp: TDateTime read FTimestamp write FTimestamp;
    property Project: TMantisProjectRef read FProject write FProject;
  end;

  TMantisVersionList = TObjectList<TMantisVersion>;

  TMantisCategory = class
  private
    FId: Integer;
    FName: string;
    FProject: TMantisProjectRef;
    FDefaultHandler: TMantisUserRef;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisCategory;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Project: TMantisProjectRef read FProject write FProject;
    property DefaultHandler: TMantisUserRef read FDefaultHandler write FDefaultHandler;
  end;

  TMantisCategoryList = TObjectList<TMantisCategory>;

  { ==================== CUSTOM FIELD DEFINITION (progetto) ==================== }

  TMantisCustomFieldDef = class
  private
    FId: Integer;
    FName: string;
    FFieldType: string;
    FDefaultValue: string;
    FPossibleValues: string;
    FRequired: Boolean;
  public
    class function FromJSON(AJson: TJSONObject): TMantisCustomFieldDef;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property FieldType: string read FFieldType write FFieldType;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property PossibleValues: string read FPossibleValues write FPossibleValues;
    property Required: Boolean read FRequired write FRequired;
  end;

  TMantisCustomFieldDefList = TObjectList<TMantisCustomFieldDef>;

  { ==================== PROJECT ==================== }

  TMantisProject = class
  private
    FId: Integer;
    FName: string;
    FDescription: string;
    FStatus: TMantisEnum;
    FViewState: TMantisEnum;
    FAccessLevel: TMantisEnum;
    FEnabled: Boolean;
    FVersions: TMantisVersionList;
    FCategories: TMantisCategoryList;
    FCustomFields: TMantisCustomFieldDefList;
    FSubProjects: TMantisProjectRefList;
  public
    constructor Create;
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisProject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Status: TMantisEnum read FStatus write FStatus;
    property ViewState: TMantisEnum read FViewState write FViewState;
    property AccessLevel: TMantisEnum read FAccessLevel write FAccessLevel;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Versions: TMantisVersionList read FVersions;
    property Categories: TMantisCategoryList read FCategories;
    property CustomFields: TMantisCustomFieldDefList read FCustomFields;
    property SubProjects: TMantisProjectRefList read FSubProjects;
  end;

  TMantisProjectList = TObjectList<TMantisProject>;

  { ==================== USER (dettaglio, amministrazione) ==================== }

  TMantisUser = class
  private
    FId: Integer;
    FName: string;
    FRealName: string;
    FEmail: string;
    FAccessLevel: TMantisEnum;
    FEnabled: Boolean;
    FProtectedFlag: Boolean;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisUser;
    function ToJSON: TJSONObject;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property RealName: string read FRealName write FRealName;
    property Email: string read FEmail write FEmail;
    property AccessLevel: TMantisEnum read FAccessLevel write FAccessLevel;
    property Enabled: Boolean read FEnabled write FEnabled;
    property ProtectedFlag: Boolean read FProtectedFlag write FProtectedFlag;
  end;

  TMantisUserList = TObjectList<TMantisUser>;

  { ==================== ISSUE ==================== }

  TMantisIssue = class
  private
    FId: Integer;
    FSummary: string;
    FDescription: string;
    FStepsToReproduce: string;
    FAdditionalInformation: string;
    FProject: TMantisProjectRef;
    FCategory: string;
    FReporter: TMantisUserRef;
    FHandler: TMantisUserRef;
    FPriority: TMantisEnum;
    FSeverity: TMantisEnum;
    FReproducibility: TMantisEnum;
    FStatus: TMantisEnum;
    FResolution: TMantisEnum;
    FViewState: TMantisEnum;
    FProjection: TMantisEnum;
    FEta: TMantisEnum;
    FOs: string;
    FOsBuild: string;
    FPlatform: string;
    FVersion: string;
    FFixedInVersion: string;
    FTargetVersion: string;
    FSticky: Boolean;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
    FDueDate: TDateTime;
    FCustomFields: TMantisCustomFieldValueList;
    FNotes: TMantisNoteList;
    FAttachments: TMantisAttachmentList;
    FTags: TMantisTagList;
    FRelationships: TMantisRelationshipList;
    FMonitors: TObjectList<TMantisUserRef>;
  public
    constructor Create;
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisIssue;
    { ToJSON produce il payload minimo per creazione/aggiornamento, non l'intera entità. }
    function ToCreatePayload: TJSONObject;
    property Id: Integer read FId write FId;
    property Summary: string read FSummary write FSummary;
    property Description: string read FDescription write FDescription;
    property StepsToReproduce: string read FStepsToReproduce write FStepsToReproduce;
    property AdditionalInformation: string read FAdditionalInformation write FAdditionalInformation;
    property Project: TMantisProjectRef read FProject write FProject;
    property Category: string read FCategory write FCategory;
    property Reporter: TMantisUserRef read FReporter write FReporter;
    property Handler: TMantisUserRef read FHandler write FHandler;
    property Priority: TMantisEnum read FPriority write FPriority;
    property Severity: TMantisEnum read FSeverity write FSeverity;
    property Reproducibility: TMantisEnum read FReproducibility write FReproducibility;
    property Status: TMantisEnum read FStatus write FStatus;
    property Resolution: TMantisEnum read FResolution write FResolution;
    property ViewState: TMantisEnum read FViewState write FViewState;
    property Projection: TMantisEnum read FProjection write FProjection;
    property Eta: TMantisEnum read FEta write FEta;
    property Os: string read FOs write FOs;
    property OsBuild: string read FOsBuild write FOsBuild;
    property Platform: string read FPlatform write FPlatform;
    property Version: string read FVersion write FVersion;
    property FixedInVersion: string read FFixedInVersion write FFixedInVersion;
    property TargetVersion: string read FTargetVersion write FTargetVersion;
    property Sticky: Boolean read FSticky write FSticky;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property DueDate: TDateTime read FDueDate write FDueDate;
    property CustomFields: TMantisCustomFieldValueList read FCustomFields;
    property Notes: TMantisNoteList read FNotes;
    property Attachments: TMantisAttachmentList read FAttachments;
    property Tags: TMantisTagList read FTags;
    property Relationships: TMantisRelationshipList read FRelationships;
    property Monitors: TObjectList<TMantisUserRef> read FMonitors;
  end;

  TMantisIssueList = TObjectList<TMantisIssue>;

  { ==================== FILTER (salvato) ==================== }

  TMantisFilter = class
  private
    FId: Integer;
    FName: string;
    FOwner: TMantisUserRef;
    FProjectId: Integer;
    FIsPublic: Boolean;
  public
    destructor Destroy; override;
    class function FromJSON(AJson: TJSONObject): TMantisFilter;
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Owner: TMantisUserRef read FOwner write FOwner;
    property ProjectId: Integer read FProjectId write FProjectId;
    property IsPublic: Boolean read FIsPublic write FIsPublic;
  end;

  TMantisFilterList = TObjectList<TMantisFilter>;

  { ==================== CONFIG OPTION ==================== }

  TMantisConfigOption = class
  private
    FOptionName: string;
    FRawValue: TJSONValue;
  public
    destructor Destroy; override;
    class function FromJSON(const AOptionName: string; AJson: TJSONValue): TMantisConfigOption;
    function AsString: string;
    function AsInteger: Integer;
    function AsBoolean: Boolean;
    property OptionName: string read FOptionName write FOptionName;
    property RawValue: TJSONValue read FRawValue;
  end;

  { ==================== HELPER JSON (uso interno alle unit endpoint) ==================== }

  TMantisJSONHelper = class
  public
    class function GetStr(AJson: TJSONObject; const AKey: string; const ADefault: string = ''): string;
    class function GetInt(AJson: TJSONObject; const AKey: string; ADefault: Integer = 0): Integer;
    class function GetInt64(AJson: TJSONObject; const AKey: string; ADefault: Int64 = 0): Int64;
    class function GetBool(AJson: TJSONObject; const AKey: string; ADefault: Boolean = False): Boolean;
    class function GetObj(AJson: TJSONObject; const AKey: string): TJSONObject;
    class function GetArr(AJson: TJSONObject; const AKey: string): TJSONArray;
    class function GetDateTime(AJson: TJSONObject; const AKey: string): TDateTime;
    class function DateTimeToISO8601(ADateTime: TDateTime): string;
  end;

implementation

{ TMantisJSONHelper }

class function TMantisJSONHelper.GetStr(AJson: TJSONObject; const AKey, ADefault: string): string;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if AJson = nil then Exit;
  LValue := AJson.GetValue(AKey);
  if (LValue <> nil) and not (LValue is TJSONNull) then
    Result := LValue.Value;
end;

class function TMantisJSONHelper.GetInt(AJson: TJSONObject; const AKey: string; ADefault: Integer): Integer;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if AJson = nil then Exit;
  LValue := AJson.GetValue(AKey);
  if (LValue <> nil) and not (LValue is TJSONNull) then
    LValue.TryGetValue<Integer>(Result);
end;

class function TMantisJSONHelper.GetInt64(AJson: TJSONObject; const AKey: string; ADefault: Int64): Int64;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if AJson = nil then Exit;
  LValue := AJson.GetValue(AKey);
  if (LValue <> nil) and not (LValue is TJSONNull) then
    LValue.TryGetValue<Int64>(Result);
end;

class function TMantisJSONHelper.GetBool(AJson: TJSONObject; const AKey: string; ADefault: Boolean): Boolean;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if AJson = nil then Exit;
  LValue := AJson.GetValue(AKey);
  if (LValue <> nil) and not (LValue is TJSONNull) then
    LValue.TryGetValue<Boolean>(Result);
end;

class function TMantisJSONHelper.GetObj(AJson: TJSONObject; const AKey: string): TJSONObject;
var
  LValue: TJSONValue;
begin
  Result := nil;
  if AJson = nil then Exit;
  LValue := AJson.GetValue(AKey);
  if (LValue <> nil) and (LValue is TJSONObject) then
    Result := TJSONObject(LValue);
end;

class function TMantisJSONHelper.GetArr(AJson: TJSONObject; const AKey: string): TJSONArray;
var
  LValue: TJSONValue;
begin
  Result := nil;
  if AJson = nil then Exit;
  LValue := AJson.GetValue(AKey);
  if (LValue <> nil) and (LValue is TJSONArray) then
    Result := TJSONArray(LValue);
end;

class function TMantisJSONHelper.GetDateTime(AJson: TJSONObject; const AKey: string): TDateTime;
var
  LStr: string;
begin
  Result := 0;
  LStr := GetStr(AJson, AKey);
  if LStr <> '' then
    try
      Result := ISO8601ToDate(LStr, False);
    except
      Result := 0;
    end;
end;

class function TMantisJSONHelper.DateTimeToISO8601(ADateTime: TDateTime): string;
begin
  Result := DateToISO8601(ADateTime, False);
end;

{ EMantisAPIError }

constructor EMantisAPIError.Create(AStatusCode, AErrorCode: Integer; const AErrorMessage: string);
begin
  inherited CreateFmt('Mantis API error %d (HTTP %d): %s', [AErrorCode, AStatusCode, AErrorMessage]);
  FStatusCode := AStatusCode;
  FErrorCode := AErrorCode;
  FErrorMessage := AErrorMessage;
end;

{ TMantisEnum }

constructor TMantisEnum.Create;
begin
  inherited Create;
end;

constructor TMantisEnum.Create(AId: Integer; const AName, ALabelText: string);
begin
  inherited Create;
  FId := AId;
  FName := AName;
  FLabelText := ALabelText;
end;

class function TMantisEnum.FromJSON(AJson: TJSONObject): TMantisEnum;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisEnum.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FLabelText := TMantisJSONHelper.GetStr(AJson, 'label');
  Result.FColor := TMantisJSONHelper.GetStr(AJson, 'color');
end;

function TMantisEnum.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FId <> 0 then
    Result.AddPair('id', TJSONNumber.Create(FId))
  else if FName <> '' then
    Result.AddPair('name', FName);
end;

function TMantisEnum.Clone: TMantisEnum;
begin
  Result := TMantisEnum.Create(FId, FName, FLabelText);
  Result.FColor := FColor;
end;

{ TMantisUserRef }

class function TMantisUserRef.FromJSON(AJson: TJSONObject): TMantisUserRef;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisUserRef.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FRealName := TMantisJSONHelper.GetStr(AJson, 'real_name');
  Result.FEmail := TMantisJSONHelper.GetStr(AJson, 'email');
end;

function TMantisUserRef.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FId <> 0 then
    Result.AddPair('id', TJSONNumber.Create(FId))
  else if FName <> '' then
    Result.AddPair('name', FName);
end;

{ TMantisProjectRef }

class function TMantisProjectRef.FromJSON(AJson: TJSONObject): TMantisProjectRef;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisProjectRef.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
end;

function TMantisProjectRef.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FId <> 0 then
    Result.AddPair('id', TJSONNumber.Create(FId))
  else if FName <> '' then
    Result.AddPair('name', FName);
end;

{ TMantisCustomFieldValue }

class function TMantisCustomFieldValue.FromJSON(AJson: TJSONObject): TMantisCustomFieldValue;
var
  LField: TJSONObject;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisCustomFieldValue.Create;
  LField := TMantisJSONHelper.GetObj(AJson, 'field');
  if LField <> nil then
  begin
    Result.FFieldId := TMantisJSONHelper.GetInt(LField, 'id');
    Result.FFieldName := TMantisJSONHelper.GetStr(LField, 'name');
  end;
  Result.FValue := TMantisJSONHelper.GetStr(AJson, 'value');
end;

function TMantisCustomFieldValue.ToJSON: TJSONObject;
var
  LField: TJSONObject;
begin
  Result := TJSONObject.Create;
  LField := TJSONObject.Create;
  if FFieldId <> 0 then
    LField.AddPair('id', TJSONNumber.Create(FFieldId))
  else
    LField.AddPair('name', FFieldName);
  Result.AddPair('field', LField);
  Result.AddPair('value', FValue);
end;

{ TMantisTag }

class function TMantisTag.FromJSON(AJson: TJSONObject): TMantisTag;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisTag.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FDescription := TMantisJSONHelper.GetStr(AJson, 'description');
end;

function TMantisTag.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FId <> 0 then
    Result.AddPair('id', TJSONNumber.Create(FId));
  if FName <> '' then
    Result.AddPair('name', FName);
  if FDescription <> '' then
    Result.AddPair('description', FDescription);
end;

{ TMantisAttachment }

destructor TMantisAttachment.Destroy;
begin
  FReporter.Free;
  inherited;
end;

class function TMantisAttachment.FromJSON(AJson: TJSONObject): TMantisAttachment;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisAttachment.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FFilename := TMantisJSONHelper.GetStr(AJson, 'filename');
  Result.FSize := TMantisJSONHelper.GetInt64(AJson, 'size');
  Result.FContentType := TMantisJSONHelper.GetStr(AJson, 'content_type');
  Result.FDownloadUrl := TMantisJSONHelper.GetStr(AJson, 'download_url');
  Result.FCreatedAt := TMantisJSONHelper.GetDateTime(AJson, 'created_at');
  Result.FReporter := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'user'));
end;

{ TMantisNote }

constructor TMantisNote.Create;
begin
  inherited Create;
  FAttachments := TMantisAttachmentList.Create(True);
end;

destructor TMantisNote.Destroy;
begin
  FReporter.Free;
  FViewState.Free;
  FNoteType.Free;
  FAttachments.Free;
  inherited;
end;

class function TMantisNote.FromJSON(AJson: TJSONObject): TMantisNote;
var
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisNote.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FReporter := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'reporter'));
  Result.FText := TMantisJSONHelper.GetStr(AJson, 'text');
  Result.FViewState := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'view_state'));
  Result.FNoteType := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'type'));
  Result.FCreatedAt := TMantisJSONHelper.GetDateTime(AJson, 'created_at');
  Result.FUpdatedAt := TMantisJSONHelper.GetDateTime(AJson, 'updated_at');
  LArr := TMantisJSONHelper.GetArr(AJson, 'attachments');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FAttachments.Add(TMantisAttachment.FromJSON(TJSONObject(LItem)));
end;

function TMantisNote.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('text', FText);
  if FViewState <> nil then
    Result.AddPair('view_state', FViewState.ToJSON);
end;

{ TMantisRelationship }

destructor TMantisRelationship.Destroy;
begin
  FRelationType.Free;
  inherited;
end;

class function TMantisRelationship.FromJSON(AJson: TJSONObject): TMantisRelationship;
var
  LIssue: TJSONObject;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisRelationship.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FRelationType := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'type'));
  LIssue := TMantisJSONHelper.GetObj(AJson, 'issue');
  if LIssue <> nil then
  begin
    Result.FTargetIssueId := TMantisJSONHelper.GetInt(LIssue, 'id');
    Result.FTargetIssueSummary := TMantisJSONHelper.GetStr(LIssue, 'summary');
  end;
end;

function TMantisRelationship.ToJSON: TJSONObject;
var
  LIssue: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FRelationType <> nil then
    Result.AddPair('type', FRelationType.ToJSON);
  LIssue := TJSONObject.Create;
  LIssue.AddPair('id', TJSONNumber.Create(FTargetIssueId));
  Result.AddPair('issue', LIssue);
end;

{ TMantisHistoryEvent }

destructor TMantisHistoryEvent.Destroy;
begin
  FUser.Free;
  FEventType.Free;
  inherited;
end;

class function TMantisHistoryEvent.FromJSON(AJson: TJSONObject): TMantisHistoryEvent;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisHistoryEvent.Create;
  Result.FCreatedAt := TMantisJSONHelper.GetDateTime(AJson, 'created_at');
  Result.FUser := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'user'));
  Result.FFieldName := TMantisJSONHelper.GetStr(AJson, 'field_name', TMantisJSONHelper.GetStr(AJson, 'field'));
  Result.FOldValue := TMantisJSONHelper.GetStr(AJson, 'old_value');
  Result.FNewValue := TMantisJSONHelper.GetStr(AJson, 'new_value');
  Result.FEventType := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'type'));
end;

{ TMantisVersion }

destructor TMantisVersion.Destroy;
begin
  FProject.Free;
  inherited;
end;

class function TMantisVersion.FromJSON(AJson: TJSONObject): TMantisVersion;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisVersion.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FDescription := TMantisJSONHelper.GetStr(AJson, 'description');
  Result.FReleased := TMantisJSONHelper.GetBool(AJson, 'released');
  Result.FObsolete := TMantisJSONHelper.GetBool(AJson, 'obsolete');
  Result.FTimestamp := TMantisJSONHelper.GetDateTime(AJson, 'timestamp');
  Result.FProject := TMantisProjectRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'project'));
end;

function TMantisVersion.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', FName);
  if FDescription <> '' then
    Result.AddPair('description', FDescription);
  Result.AddPair('released', TJSONBool.Create(FReleased));
  Result.AddPair('obsolete', TJSONBool.Create(FObsolete));
end;

{ TMantisCategory }

destructor TMantisCategory.Destroy;
begin
  FProject.Free;
  FDefaultHandler.Free;
  inherited;
end;

class function TMantisCategory.FromJSON(AJson: TJSONObject): TMantisCategory;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisCategory.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FProject := TMantisProjectRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'project'));
  Result.FDefaultHandler := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'default_handler'));
end;

function TMantisCategory.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', FName);
  if FDefaultHandler <> nil then
    Result.AddPair('default_handler', FDefaultHandler.ToJSON);
end;

{ TMantisCustomFieldDef }

class function TMantisCustomFieldDef.FromJSON(AJson: TJSONObject): TMantisCustomFieldDef;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisCustomFieldDef.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FFieldType := TMantisJSONHelper.GetStr(AJson, 'type');
  Result.FDefaultValue := TMantisJSONHelper.GetStr(AJson, 'default_value');
  Result.FPossibleValues := TMantisJSONHelper.GetStr(AJson, 'possible_values');
  Result.FRequired := TMantisJSONHelper.GetBool(AJson, 'require_report');
end;

{ TMantisProject }

constructor TMantisProject.Create;
begin
  inherited Create;
  FVersions := TMantisVersionList.Create(True);
  FCategories := TMantisCategoryList.Create(True);
  FCustomFields := TMantisCustomFieldDefList.Create(True);
  FSubProjects := TMantisProjectRefList.Create(True);
end;

destructor TMantisProject.Destroy;
begin
  FStatus.Free;
  FViewState.Free;
  FAccessLevel.Free;
  FVersions.Free;
  FCategories.Free;
  FCustomFields.Free;
  FSubProjects.Free;
  inherited;
end;

class function TMantisProject.FromJSON(AJson: TJSONObject): TMantisProject;
var
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisProject.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FDescription := TMantisJSONHelper.GetStr(AJson, 'description');
  Result.FStatus := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'status'));
  Result.FViewState := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'view_state'));
  Result.FAccessLevel := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'access_level'));
  Result.FEnabled := TMantisJSONHelper.GetBool(AJson, 'enabled', True);

  LArr := TMantisJSONHelper.GetArr(AJson, 'versions');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FVersions.Add(TMantisVersion.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'categories');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FCategories.Add(TMantisCategory.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'custom_fields');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FCustomFields.Add(TMantisCustomFieldDef.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'subprojects');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FSubProjects.Add(TMantisProjectRef.FromJSON(TJSONObject(LItem)));
end;

{ TMantisUser }

destructor TMantisUser.Destroy;
begin
  FAccessLevel.Free;
  inherited;
end;

class function TMantisUser.FromJSON(AJson: TJSONObject): TMantisUser;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisUser.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FRealName := TMantisJSONHelper.GetStr(AJson, 'real_name');
  Result.FEmail := TMantisJSONHelper.GetStr(AJson, 'email');
  Result.FAccessLevel := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'access_level'));
  Result.FEnabled := TMantisJSONHelper.GetBool(AJson, 'enabled', True);
  Result.FProtectedFlag := TMantisJSONHelper.GetBool(AJson, 'protected');
end;

function TMantisUser.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('username', FName);
  if FRealName <> '' then
    Result.AddPair('real_name', FRealName);
  if FEmail <> '' then
    Result.AddPair('email', FEmail);
  if FAccessLevel <> nil then
    Result.AddPair('access_level', FAccessLevel.ToJSON);
end;

{ TMantisIssue }

constructor TMantisIssue.Create;
begin
  inherited Create;
  FCustomFields := TMantisCustomFieldValueList.Create(True);
  FNotes := TMantisNoteList.Create(True);
  FAttachments := TMantisAttachmentList.Create(True);
  FTags := TMantisTagList.Create(True);
  FRelationships := TMantisRelationshipList.Create(True);
  FMonitors := TObjectList<TMantisUserRef>.Create(True);
end;

destructor TMantisIssue.Destroy;
begin
  FProject.Free;
  FReporter.Free;
  FHandler.Free;
  FPriority.Free;
  FSeverity.Free;
  FReproducibility.Free;
  FStatus.Free;
  FResolution.Free;
  FViewState.Free;
  FProjection.Free;
  FEta.Free;
  FCustomFields.Free;
  FNotes.Free;
  FAttachments.Free;
  FTags.Free;
  FRelationships.Free;
  FMonitors.Free;
  inherited;
end;

class function TMantisIssue.FromJSON(AJson: TJSONObject): TMantisIssue;
var
  LArr: TJSONArray;
  LItem: TJSONValue;
  LCategory: TJSONValue;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisIssue.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FSummary := TMantisJSONHelper.GetStr(AJson, 'summary');
  Result.FDescription := TMantisJSONHelper.GetStr(AJson, 'description');
  Result.FStepsToReproduce := TMantisJSONHelper.GetStr(AJson, 'steps_to_reproduce');
  Result.FAdditionalInformation := TMantisJSONHelper.GetStr(AJson, 'additional_information');
  Result.FProject := TMantisProjectRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'project'));

  { category può arrivare come stringa semplice o come oggetto {name a seconda della versione }
  LCategory := AJson.GetValue('category');
  if LCategory is TJSONObject then
    Result.FCategory := TMantisJSONHelper.GetStr(TJSONObject(LCategory), 'name')
  else if (LCategory <> nil) and not (LCategory is TJSONNull) then
    Result.FCategory := LCategory.Value;

  Result.FReporter := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'reporter'));
  Result.FHandler := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'handler'));
  Result.FPriority := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'priority'));
  Result.FSeverity := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'severity'));
  Result.FReproducibility := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'reproducibility'));
  Result.FStatus := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'status'));
  Result.FResolution := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'resolution'));
  Result.FViewState := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'view_state'));
  Result.FProjection := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'projection'));
  Result.FEta := TMantisEnum.FromJSON(TMantisJSONHelper.GetObj(AJson, 'eta'));
  Result.FOs := TMantisJSONHelper.GetStr(AJson, 'os');
  Result.FOsBuild := TMantisJSONHelper.GetStr(AJson, 'os_build');
  Result.FPlatform := TMantisJSONHelper.GetStr(AJson, 'platform');
  Result.FVersion := TMantisJSONHelper.GetStr(AJson, 'version');
  Result.FFixedInVersion := TMantisJSONHelper.GetStr(AJson, 'fixed_in_version');
  Result.FTargetVersion := TMantisJSONHelper.GetStr(AJson, 'target_version');
  Result.FSticky := TMantisJSONHelper.GetBool(AJson, 'sticky');
  Result.FCreatedAt := TMantisJSONHelper.GetDateTime(AJson, 'created_at');
  Result.FUpdatedAt := TMantisJSONHelper.GetDateTime(AJson, 'updated_at');
  Result.FDueDate := TMantisJSONHelper.GetDateTime(AJson, 'due_date');

  LArr := TMantisJSONHelper.GetArr(AJson, 'custom_fields');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FCustomFields.Add(TMantisCustomFieldValue.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'notes');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FNotes.Add(TMantisNote.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'attachments');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FAttachments.Add(TMantisAttachment.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'tags');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FTags.Add(TMantisTag.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'relationships');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FRelationships.Add(TMantisRelationship.FromJSON(TJSONObject(LItem)));

  LArr := TMantisJSONHelper.GetArr(AJson, 'monitors');
  if LArr <> nil then
    for LItem in LArr do
      if LItem is TJSONObject then
        Result.FMonitors.Add(TMantisUserRef.FromJSON(TJSONObject(LItem)));
end;

function TMantisIssue.ToCreatePayload: TJSONObject;
var
  LCF: TMantisCustomFieldValue;
  LCFArr: TJSONArray;
begin
  Result := TJSONObject.Create;
  Result.AddPair('summary', FSummary);
  Result.AddPair('description', FDescription);
  if FProject <> nil then
    Result.AddPair('project', FProject.ToJSON)
  else
    raise EArgumentException.Create('TMantisIssue.ToCreatePayload: Project è obbligatorio.');

  if FCategory <> '' then
  begin
    var LCat := TJSONObject.Create;
    LCat.AddPair('name', FCategory);
    Result.AddPair('category', LCat);
  end;

  if FStepsToReproduce <> '' then
    Result.AddPair('steps_to_reproduce', FStepsToReproduce);
  if FAdditionalInformation <> '' then
    Result.AddPair('additional_information', FAdditionalInformation);
  if FHandler <> nil then
    Result.AddPair('handler', FHandler.ToJSON);
  if FPriority <> nil then
    Result.AddPair('priority', FPriority.ToJSON);
  if FSeverity <> nil then
    Result.AddPair('severity', FSeverity.ToJSON);
  if FReproducibility <> nil then
    Result.AddPair('reproducibility', FReproducibility.ToJSON);
  if FStatus <> nil then
    Result.AddPair('status', FStatus.ToJSON);
  if FResolution <> nil then
    Result.AddPair('resolution', FResolution.ToJSON);
  if FViewState <> nil then
    Result.AddPair('view_state', FViewState.ToJSON);
  if FOs <> '' then
    Result.AddPair('os', FOs);
  if FOsBuild <> '' then
    Result.AddPair('os_build', FOsBuild);
  if FPlatform <> '' then
    Result.AddPair('platform', FPlatform);
  if FVersion <> '' then
  begin
    var LVer := TJSONObject.Create;
    LVer.AddPair('name', FVersion);
    Result.AddPair('version', LVer);
  end;
  if FFixedInVersion <> '' then
  begin
    var LVer := TJSONObject.Create;
    LVer.AddPair('name', FFixedInVersion);
    Result.AddPair('fixed_in_version', LVer);
  end;
  if FTargetVersion <> '' then
  begin
    var LVer := TJSONObject.Create;
    LVer.AddPair('name', FTargetVersion);
    Result.AddPair('target_version', LVer);
  end;
  Result.AddPair('sticky', TJSONBool.Create(FSticky));
  if FDueDate <> 0 then
    Result.AddPair('due_date', TMantisJSONHelper.DateTimeToISO8601(FDueDate));

  if FCustomFields.Count > 0 then
  begin
    LCFArr := TJSONArray.Create;
    for LCF in FCustomFields do
      LCFArr.AddElement(LCF.ToJSON);
    Result.AddPair('custom_fields', LCFArr);
  end;

  if FTags.Count > 0 then
  begin
    LCFArr := TJSONArray.Create;
    for var LTag in FTags do
      LCFArr.AddElement(LTag.ToJSON);
    Result.AddPair('tags', LCFArr);
  end;
end;

{ TMantisFilter }

destructor TMantisFilter.Destroy;
begin
  FOwner.Free;
  inherited;
end;

class function TMantisFilter.FromJSON(AJson: TJSONObject): TMantisFilter;
begin
  if AJson = nil then Exit(nil);
  Result := TMantisFilter.Create;
  Result.FId := TMantisJSONHelper.GetInt(AJson, 'id');
  Result.FName := TMantisJSONHelper.GetStr(AJson, 'name');
  Result.FOwner := TMantisUserRef.FromJSON(TMantisJSONHelper.GetObj(AJson, 'owner'));
  Result.FProjectId := TMantisJSONHelper.GetInt(AJson, 'project_id');
  Result.FIsPublic := TMantisJSONHelper.GetBool(AJson, 'public');
end;

{ TMantisConfigOption }

destructor TMantisConfigOption.Destroy;
begin
  FRawValue.Free;
  inherited;
end;

class function TMantisConfigOption.FromJSON(const AOptionName: string; AJson: TJSONValue): TMantisConfigOption;
begin
  Result := TMantisConfigOption.Create;
  Result.FOptionName := AOptionName;
  if AJson <> nil then
    Result.FRawValue := AJson.Clone as TJSONValue;
end;

function TMantisConfigOption.AsString: string;
begin
  if FRawValue <> nil then
    Result := FRawValue.Value
  else
    Result := '';
end;

function TMantisConfigOption.AsInteger: Integer;
begin
  Result := 0;
  if FRawValue <> nil then
    FRawValue.TryGetValue<Integer>(Result);
end;

function TMantisConfigOption.AsBoolean: Boolean;
begin
  Result := False;
  if FRawValue <> nil then
    FRawValue.TryGetValue<Boolean>(Result);
end;

end.
