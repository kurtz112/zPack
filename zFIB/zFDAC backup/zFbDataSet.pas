unit zFbDataSet;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  SiAuto,
  SmartInspect;

type
  TActivationMode = (amManual, amAutomatic, amWhenNeeded);

  TzFbDataSet = class;

  TAfterLookupFieldsCopied = procedure(Sender: TzFbDataSet; lkDataSet: TDataset; LookupString: string) of object;

  TzFbDatabase = class(TFDConnection)
  published
    function Gen_ID(const GeneratorName: string; Step: Int64): Int64;
    property Connected stored false;
  end;

  TzFbTransaction = class(TFDTransaction)
  private
    SavePoints: TStack<string>;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetSavePoint(const SavePoint: string);
    procedure RollBackToSavePoint(const SavePoint: string);
    procedure CloseTransaction(const doCommit: boolean = True);
  published
    property Active stored false;
  end;

  TzFbStoredProc = class(TFDStoredProc)
  private
    function GetDatabase: TFDCustomConnection;
    procedure SetDatabase(const Value: TFDCustomConnection);
  public
    function DebugString: string;
    function ParamExists(const ParamName: string): boolean;
    function ParamByName(const ParamName: string): TFDParam;
    property Database: TFDCustomConnection read GetDatabase write SetDatabase;
  end;

  TzFbSQL = class(TFDQuery)
  private
    function GetDatabase: TFDCustomConnection;
    procedure SetDatabase(const Value: TFDCustomConnection);
  public
    procedure ExecQuery;
    property Database: TFDCustomConnection read GetDatabase write SetDatabase;
  end;

  TzFbDataSet = class(TFDQuery)
  private
    FOnCustomBeforePost: TDataSetNotifyEvent;
    FActivationMode: TActivationMode;
    FCountSQL: TStrings;
    FOnGetQueryParams: TDataSetNotifyEvent;
    FIdDataSet: string;
    FDefaultSQL: TStrings;
    FOnBeforeCreateFields: TDataSetNotifyEvent;
    FOnAfterCreateFields: TDataSetNotifyEvent;
    FOnAfterLookupFieldsCopied: TAfterLookupFieldsCopied;
    /// /////////////////////////////////////
    procedure SetOnCustomBeforePost(const Value: TDataSetNotifyEvent);
    procedure SetActivationMode(const Value: TActivationMode);
    procedure SetCountSQL(const Value: TStrings);
    procedure SetOnGetQueryParams(const Value: TDataSetNotifyEvent);
    procedure SetIdDataSet(const Value: string);
    procedure SetTableName(const Value: string);
    procedure SetDefaultSQL(const Value: TStrings);
    procedure SetOnAfterCreateFields(const Value: TDataSetNotifyEvent);
    procedure SetOnBeforeCreateFields(const Value: TDataSetNotifyEvent);
    /// /////////////////////////////////////
  private
    InnerUpdateObject: TFDUpdateSQL;
    LocateWhere: string;
    InLocate: boolean;
    FUseSqlLocate: boolean;
    function GetAutoCommit: boolean;
    function GetDatabase: TFDCustomConnection;
    function GetGeneratorName: string;
    function GetOrderBy: string;
    function GetPrimaryKeyFields: string;
    function GetSQL_Delete: TStrings;
    function GetSQL_Insert: TStrings;
    function GetSQL_Refresh: TStrings;
    function GetSQL_Select: TStrings;
    function GetSQL_Update: TStrings;
    function GetTableName: string;
    function GetUniDirectional: boolean;
    function GetWhere: string;
    function LocateFound(KeyFields: string; KeyValues: Variant; Options: TLocateOptions): boolean;
    function LocateParamsEmpty(KeyValues: Variant): boolean;
    function LocateSQL(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
    procedure SetAutoCommit(const Value: boolean);
    procedure SetDatabase(const Value: TFDCustomConnection);
    procedure SetGeneratorName(const Value: string);
    procedure SetOrderBy(const Value: string);
    procedure SetPrimaryKeyFields(const Value: string);
    procedure SetSQL_Delete(const Value: TStrings);
    procedure SetSQL_Insert(const Value: TStrings);
    procedure SetSQL_Refresh(const Value: TStrings);
    procedure SetSQL_Select(const Value: TStrings);
    procedure SetSQL_Update(const Value: TStrings);
    procedure SetUniDirectional(const Value: boolean);
    procedure SetWhere(const Value: string);
    procedure TryChangeSQL(const NewSql: string);
    /// /////////////////////////////////////
  protected
    procedure InternalPost; override;
    procedure InternalOpen; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforePost; override;
    procedure DoBeforeOpen; override;
    procedure DoAfterOpen; override;
    procedure DoBeforeClose; override;
    procedure DoCustomBeforePost; virtual;
    procedure doBeforeCreateFields; virtual;
    procedure doAfterCreateFields; virtual;
    function GetLocateSQL(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): string;
    /// //////////
    procedure UpdateDefaultExpressions;
    procedure SetFieldsOrigin;
    procedure SetRequiredForJoinFields;
    procedure DoCreateFields; override;
    procedure SetFieldsReadOnly;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReOpen(const ForceActive: boolean = false);
    procedure RevertSQL(const Activate: boolean = false);
    procedure BuildFields;
    procedure RebuildFields;
    procedure RefreshCalcFields;
    procedure CopyLookupFields(lkDataSet: TDataset; LookupString: string);
    function RequiredFieldOk(Field: TField): boolean;
    function RequiredFieldsOk: boolean;
    procedure CheckBeforePost;
  public
    function ParamExists(const ParamName: string): boolean;
    procedure GetParamValues(aParams: TParams);
    procedure SetParamValues(aParams: TParams);
  public
    function IsJoinedField(FieldName: string): boolean; overload;
    function IsJoinedField(Field: TField): boolean; overload;
    function IsParamUID(FieldName: string): boolean;
    function IsMasterDetailParam(ParamName: string): boolean;
    function IsGeneratorField(FieldName: string): boolean;
    function IsDetailParamField(FieldName: string): boolean;
    function FieldOrigin(Field: TField; AddTableName: boolean = false): string;
  public
    function GetDebugInfo: string;
    function DebugInsertString: string;
    function DebugUpdateString: string;
  published
    property ActivationMode: TActivationMode read FActivationMode write SetActivationMode default amAutomatic;
    property Active stored false;
    property IdDataSet: string read FIdDataSet write SetIdDataSet;

    property UseSqlLocate: boolean read FUseSqlLocate write FUseSqlLocate;
    property OnGetQueryParams: TDataSetNotifyEvent read FOnGetQueryParams write SetOnGetQueryParams;
    property OnBeforeCreateFields: TDataSetNotifyEvent read FOnBeforeCreateFields write SetOnBeforeCreateFields;
    property OnAfterCreateFields: TDataSetNotifyEvent read FOnAfterCreateFields write SetOnAfterCreateFields;
    property OnAfterLookupFieldsCopied: TAfterLookupFieldsCopied read FOnAfterLookupFieldsCopied write FOnAfterLookupFieldsCopied;
    property OnCustomBeforePost: TDataSetNotifyEvent read FOnCustomBeforePost write SetOnCustomBeforePost;
  public
    function Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean; override;
    procedure ReopenLocate(const LocateFieldName: string);
    procedure AddWhereCondition(const Condition: string);
    function RecordCountFromSrv: integer;
    property TableName: string read GetTableName write SetTableName;
    property GeneratorName: string read GetGeneratorName write SetGeneratorName;
    property PrimaryKeyFields: string read GetPrimaryKeyFields write SetPrimaryKeyFields;

    property AutoCommit: boolean read GetAutoCommit write SetAutoCommit;
    property UniDirectional: boolean read GetUniDirectional write SetUniDirectional;
  public
    property SQL_Select: TStrings read GetSQL_Select write SetSQL_Select;
    property SQL_Refresh: TStrings read GetSQL_Refresh write SetSQL_Refresh;
    property SQL_Insert: TStrings read GetSQL_Insert write SetSQL_Insert;
    property SQL_Update: TStrings read GetSQL_Update write SetSQL_Update;
    property SQL_Delete: TStrings read GetSQL_Delete write SetSQL_Delete;
    property DefaultSQL: TStrings read FDefaultSQL write SetDefaultSQL;
    property CountSQL: TStrings read FCountSQL write SetCountSQL;
    property Where: string read GetWhere write SetWhere;
    property OrderBy: string read GetOrderBy write SetOrderBy;
  public
    // alias per SQL_Select
    property SelectSQL: TStrings read GetSQL_Select write SetSQL_Select;
    property RefreshSQL: TStrings read GetSQL_Refresh write SetSQL_Refresh;
    property InsertSQL: TStrings read GetSQL_Insert write SetSQL_Insert;
    property UpdateSQL: TStrings read GetSQL_Update write SetSQL_Update;
    property DeleteSQL: TStrings read GetSQL_Delete write SetSQL_Delete;
    // alias
    property OrderClause: string read GetOrderBy write SetOrderBy;
    property MainWhereClause: string read GetWhere write SetWhere;
    property Database: TFDCustomConnection read GetDatabase write SetDatabase;
  end;

  TFDAdaptedDataSetHelper = Class Helper for TFDAdaptedDataSet
  public
    procedure CheckEditMode;
    procedure ClearFields(FieldsToClear: string);
    procedure CopyFieldValues(Source: TDataset; DoPost: boolean);
    procedure CopyRecord(Source: TDataset);
    procedure DeleteAll;
    procedure DuplicateRecord(DoPost: boolean; ExcludeFields: string);
    function IsDetailOf(DataSet: TDataset): boolean;
  End;

  TFDParamsHelper = class helper for TFDParams
    function ParamExists(const ParamName: string): boolean;
  end;

  TzFibErrors = class
  private
    FLastErrorMsg: string;
    FRaiseErrors: boolean;
    FHandleErrors: boolean;
    procedure SetHandleErrors(const Value: boolean);
  published
  public
    constructor Create;
    property LastErrorMsg: string read FLastErrorMsg write FLastErrorMsg;
    property HandleErrors: boolean read FHandleErrors write SetHandleErrors;
    property RaiseErrors: boolean read FRaiseErrors write FRaiseErrors;
  end;

function zFibErrors: TzFibErrors;

function CreateFbDataSet(Owner: TComponent; DB: TzFbDatabase; ReadTrans, WriteTrans: TzFbTransaction; const UniDirectional: boolean = false): TzFbDataSet;

function IsStringType(FieldType: TFieldType): boolean;
function IsIntegerType(FieldType: TFieldType): boolean;
function IsFloatType(FieldType: TFieldType): boolean;
function IsNumericType(FieldType: TFieldType): boolean;
function IsDateType(FieldType: TFieldType): boolean;
function IsTimeType(FieldType: TFieldType): boolean;
function IsDateTimeType(FieldType: TFieldType): boolean;
function IsBooleanType(FieldType: TFieldType): boolean;
function IsBlobType(FieldType: TFieldType): boolean;
function IsMemoType(FieldType: TFieldType): boolean;

implementation

uses
  System.Variants,
  Data.DBConsts,
  zSql.Parser;

var
  __zFibErrors: TzFibErrors;

function zFibErrors: TzFibErrors;
begin
  if not Assigned(__zFibErrors) then
    __zFibErrors := TzFibErrors.Create;

  Result := __zFibErrors
end;

//
type
  TSqlOperator = (soEqual, soGraterOrEqual, soGraterThen);

function IsStringType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftString, ftFixedChar, ftWideString, ftFixedWideChar];
end;

function IsIntegerType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftLongWord, ftShortint, ftByte, ftSingle];
end;

function IsFloatType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended];
end;

function IsNumericType(FieldType: TFieldType): boolean;
begin
  Result := IsIntegerType(FieldType) or IsFloatType(FieldType);
end;

function IsDateType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftDate];
end;

function IsTimeType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftTime];
end;

function IsDateTimeType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftDate, ftTime, ftDateTime, ftTimeStamp];
end;

function IsBlobType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftWideMemo];
end;

function IsMemoType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftMemo, ftFmtMemo, ftWideMemo];
end;

function IsBooleanType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftBoolean];
end;

procedure TFDAdaptedDataSetHelper.CheckEditMode;
begin
  if Active then
  begin
    if State in dsEditModes then
    else
      edit;
  end;
end;

procedure TFDAdaptedDataSetHelper.ClearFields(FieldsToClear: string);
var
  I: integer;
  Str: TStringList;
begin
  if Trim(FieldsToClear) = '' then
    Exit;

  CheckEditMode;

  Str := TStringList.Create;
  try
    Str.Delimiter := ';';
    Str.DelimitedText := FieldsToClear;

    for I := 0 to Str.Count - 1 do
      if Str[I] <> '' then
        if Assigned(FindField(Str[I])) then
          FieldByName(Str[I]).Clear;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TFDAdaptedDataSetHelper.CopyFieldValues(Source: TDataset; DoPost: boolean);
var
  I: integer;
  s: string;
begin
  if (State in dsEditModes) then
  else
    Append;
  for I := 0 to Source.FieldCount - 1 do
    if not SameText(Source.Fields[I].FieldName, UpdateOptions.KeyFields) then // generatore
      if Assigned(FindField(Source.Fields[I].FieldName)) then
      begin
        s := Source.Fields[I].FieldName;
        if (not Source.Fields[I].IsNull) then
          try
            FieldByName(Source.Fields[I].FieldName).Value := Source.Fields[I].Value;
          except
          end;
      end;
  if DoPost then
    checkBrowseMode;
end;

procedure TFDAdaptedDataSetHelper.CopyRecord(Source: TDataset);
begin
  CopyFieldValues(Source, True);
end;

procedure TFDAdaptedDataSetHelper.DeleteAll;
begin
  Cancel;
  if recordCount = 0 then
    Exit;
  First;
  while not EOF do
    Delete;
end;

procedure TFDAdaptedDataSetHelper.DuplicateRecord(DoPost: boolean; ExcludeFields: string);
var
  RecArray: array [0 .. 255] of Variant;
  I: integer;
  FieldsToCopy: TStringList;
  Pos: integer;
  FieldName: string;
  GeneratorField: TField;
  GeneratorValue: integer;
begin
  FieldsToCopy := TStringList.Create;
  try
    for I := 0 to FieldCount - 1 do
      FieldsToCopy.Add(Fields[I].FieldName);

    Pos := 1;
    while Pos <= Length(ExcludeFields) do
    begin
      FieldName := ExtractFieldName(ExcludeFields, Pos);
      if Assigned(FindField(FieldName)) then
        if FieldsToCopy.IndexOf(FieldName) <> -1 then
          FieldsToCopy.Delete(FieldsToCopy.IndexOf(FieldName));
    end;

    try
      //
      for I := 0 to FieldsToCopy.Count - 1 do
        RecArray[I] := FieldByName(FieldsToCopy[I]).Value;
      //
      Insert;

      if UpdateOptions.GeneratorName <> '' then
      begin
        GeneratorField := FindField(UpdateOptions.KeyFields);
        if Assigned(GeneratorField) then
          GeneratorValue := GeneratorField.AsInteger;
      end;
      //
      for I := 0 to FieldsToCopy.Count - 1 do
        if FieldByName(FieldsToCopy[I]).CanModify then
          FieldByName(FieldsToCopy[I]).Value := RecArray[I];
      //
      if UpdateOptions.GeneratorName <> '' then
        if Assigned(GeneratorField) then
          GeneratorField.AsInteger := GeneratorValue;
      //

      if DoPost then
        Post;
    except
      on EDatabaseError do
        Cancel;
    end;
  finally
    FreeAndNil(FieldsToCopy);
  end;
end;

function TFDAdaptedDataSetHelper.IsDetailOf(DataSet: TDataset): boolean;
begin
  Result := false;

  if Assigned(DataSource) then
    if Assigned(DataSource.DataSet) then
      if DataSource.DataSet = DataSet then
        Result := True;
end;

function TFDParamsHelper.ParamExists(const ParamName: string): boolean;
begin
  Result := Assigned(ParamByName(ParamName));
end;

constructor TzFbDataSet.Create(AOwner: TComponent);
begin
  inherited;

  FUseSqlLocate := True;
  InLocate := false;
  LocateWhere := '';
  FDefaultSQL := TStringList.Create;
  FCountSQL := TStringList.Create;
  FActivationMode := amAutomatic;
  FOnAfterLookupFieldsCopied := nil;
  {
    nel caso di master detail, con
    M/D/S
    per il subdetail non vengono chiamati
    gli eventi del datasource (causa disablecontrols)
    per cui bisogna farlo a mano
  }

  InnerUpdateObject := TFDUpdateSQL.Create(Self);
  UpdateObject := InnerUpdateObject;
end;

destructor TzFbDataSet.Destroy;
begin
  UpdateObject := nil;
  FreeAndNil(InnerUpdateObject);
  FreeAndNil(FDefaultSQL);
  FreeAndNil(FCountSQL);
  inherited;
end;

procedure TzFbDataSet.DoBeforeClose;
begin
  if Modified then
    checkBrowseMode;
  inherited;
end;

procedure TzFbDataSet.ReOpen(const ForceActive: boolean = false);
var
  Book: TBookmark;
begin
  if ForceActive then
  begin
    Book := Bookmark;
    Active := false;
    Active := True;
    try
      Bookmark := Book;
    except
    end;
  end
  else
    Refresh;
end;

procedure TzFbDataSet.DoAfterOpen;
var
  s: string;
  FFileHandle: TextFile;
  TempIoRes: integer;
  FLogFileName: string;
begin
  inherited;
  SiMain.LogStringList(Name + '.DoAfterOpen', SQL);
  // Time_Open := GetTickCount - Time_Open;
  // zMonitor.LogDataSet(Self, loOpen);

  if false then // ZZ 18.11.2018: se vengono impostati dal load props vengono sovrascritti
    if not(csDesigning in ComponentState) then
    begin
      SetFieldsOrigin;
      SetFieldsReadOnly;
      SetRequiredForJoinFields;
    end;

  // ZZ 03.12.2018: inherited afterOpen sovrascrive origin
  if not(csDesigning in ComponentState) then
    SetFieldsOrigin;
end;

procedure TzFbDataSet.DoBeforePost;
begin
  inherited;
  DoCustomBeforePost;
end;

procedure TzFbDataSet.DoBeforeOpen;
begin
  // OutputDebugString(PChar(IntToStr(GetTickCount) + ' ===> Opening: ' + Name));
  if Assigned(FOnGetQueryParams) then
    OnGetQueryParams(Self);

  // Time_Open := GetTickCount;
  SiMain.LogObject(Name + '.DoBeforeOpen', Self);
  inherited;
end;

procedure TzFbDataSet.DoCustomBeforePost;
begin
  if Assigned(FOnCustomBeforePost) then
    OnCustomBeforePost(Self);
end;

procedure TzFbDataSet.SetOnCustomBeforePost(const Value: TDataSetNotifyEvent);
begin
  FOnCustomBeforePost := Value;
end;

procedure TzFbDataSet.BuildFields;
var
  I: integer;
begin
  for I := 0 to FieldCount - 1 do
    if Fields[I].FieldKind = fkData then
      Exit;

  DoCreateFields;
end;

function TzFbDataSet.RecordCountFromSrv: integer;
var
  // zFbSQL: TzFbSQL;
  I: integer;
begin
  Result := -1;

  // rimandandolo su recodcount normale anrebbe bene anche per memdata
  FetchOptions.RecordCountMode := cmTotal;
  Result := recordCount;
end;

procedure TzFbDataSet.RefreshCalcFields;
var
  SaveState: TDatasetState;
begin
  SaveState := SetTempState(dsCalcFields);
  try
    CalculateFields(ActiveBuffer);
  finally
    RestoreState(SaveState);
  end;
end;

procedure TzFbDataSet.SetOnGetQueryParams(const Value: TDataSetNotifyEvent);
begin
  FOnGetQueryParams := Value;
end;

procedure TzFbDataSet.SetIdDataSet(const Value: string);
begin
  FIdDataSet := Value;
end;

procedure TzFbDataSet.SetTableName(const Value: string);
begin
  UpdateOptions.UpdateTableName := Value;
end;

procedure TzFbDataSet.InternalOpen;
begin
  inherited;
  UpdateDefaultExpressions;
end;

procedure TzFbDataSet.InternalPost;
begin
  CheckBeforePost;
  inherited;
end;

function TzFbDataSet.RequiredFieldsOk: boolean;
var
  Field: TField;
  I: integer;
begin
  Result := True;

  for I := 0 to FieldCount - 1 do
  begin
    Field := Fields[I];
    if not RequiredFieldOk(Field) then
    begin
      Result := false;
      Break;
    end;
  end;
end;

procedure TzFbDataSet.RevertSQL(const Activate: boolean = false);
begin
  Active := false; // ZZ 30.05.2017: prima l'active False interveniva solamente se era variato l'sql

  if not SameText(SelectSQL.Text, FDefaultSQL.Text) then
    if Trim(FDefaultSQL.Text) <> '' then
      SelectSQL.Assign(FDefaultSQL);

  if Activate then
    Active := True;
end;

procedure TzFbDataSet.SetDefaultSQL(const Value: TStrings);
begin
  FDefaultSQL := Value;
end;

procedure TzFbDataSet.doAfterCreateFields;
begin
  if Assigned(FOnAfterCreateFields) then
    OnAfterCreateFields(Self);
end;

procedure TzFbDataSet.doBeforeCreateFields;
begin
  if Assigned(FOnBeforeCreateFields) then
    OnBeforeCreateFields(Self);
end;

procedure TzFbDataSet.SetOnAfterCreateFields(const Value: TDataSetNotifyEvent);
begin
  FOnAfterCreateFields := Value;
end;

procedure TzFbDataSet.SetOnBeforeCreateFields(const Value: TDataSetNotifyEvent);
begin
  FOnBeforeCreateFields := Value;
end;

procedure TzFbDataSet.SetFieldsOrigin;
var
  I: integer;
begin
  for I := 0 to Fields.Count - 1 do
    Fields[I].Origin := FieldOrigin(Fields[I]);
end;

procedure TzFbDataSet.SetRequiredForJoinFields;
var
  I: integer;
begin
  for I := 0 to Fields.Count - 1 do
    if Fields[I].Required then
      if IsJoinedField(Fields[I].FieldName) or (Fields[I].Calculated) then
        Fields[I].Required := false;
end;

procedure TzFbDataSet.UpdateDefaultExpressions;
var
  Field: TField;
begin
  for Field in Self.Fields do
    if Field.DefaultExpression <> '' then
    begin
      if Field.DefaultExpression.StartsWith('DEFAULT ') then
        Field.DefaultExpression := StringReplace(Field.DefaultExpression, 'DEFAULT ', '', [rfIgnoreCase]);
      // senza replaceAll

      if SameText(AnsiDequotedStr(Field.DefaultExpression, #39), '31.12.9999') then
        Field.DefaultExpression := '31/12/9999'
      else
        if SameText(AnsiDequotedStr(Field.DefaultExpression, #39), '01.01.1900') then
          Field.DefaultExpression := '01/01/1900';

      // Firebird vuole il punto, mentre win vuole la virgola
      //
      if Field is TNumericField then
        Field.DefaultExpression := StringReplace(Field.DefaultExpression, '.', FormatSettings.DecimalSeparator, []);
      // senza replaceAll

      // ZZ 13.05.2016: FB3
      Field.DefaultExpression := AnsiDequotedStr(Field.DefaultExpression, #39);
    end;
end;

function TzFbDataSet.IsJoinedField(Field: TField): boolean;
begin
  Assert(Assigned(Field));
  Result := IsJoinedField(Field.FieldName);
end;

function TzFbDataSet.IsDetailParamField(FieldName: string): boolean;
var
  tmp: TStringList;
begin
  tmp := TStringList.Create;
  try
    tmp.Delimiter := ';';
    tmp.DelimitedText := DetailFields;
    Result := tmp.IndexOf(FieldName) <> -1;
  finally
    tmp.Free;
  end;
end;

function TzFbDataSet.IsGeneratorField(FieldName: string): boolean;
begin
  Result := SameText(FieldName, UpdateOptions.KeyFields);
end;

function TzFbDataSet.FieldOrigin(Field: TField; AddTableName: boolean = false): string;
var
  Column: TFDDatSColumn;

  Origin: string;
  Alias: string;
  TableName: string;
  FieldName: string;
begin
  Result := '';

  if Assigned(Field) then
    if Assigned(Table) then
    begin
      Column := Table.Columns.ColumnByName(Field.FieldName);

      if Assigned(Column) then
      begin
        TableName := Column.OriginTabName;
        FieldName := Column.OriginColName;

        if ((TableName = '') or (FieldName = '')) then
          Result := TableName + FieldName
        else
          Result := TableName + '.' + FieldName;
      end;
    end;
end;

function TzFbDataSet.ParamExists(const ParamName: string): boolean;
begin
  Result := Assigned(FindParam(ParamName));
end;

procedure TzFbDataSet.CopyLookupFields(lkDataSet: TDataset; LookupString: string);
var
  SourceField, DestField: string;
  link: string;
  I: integer;
  Str, Str2: TStringList;
  s: string;

  /// /////////////////////////

  procedure CopyField(SourceField, DestField: string);
  var
    Esci: boolean;
    SrcField, DstField: TField;
  begin
    DstField := FindField(DestField);

    Esci := not Assigned(DstField);

    if not Esci then
    begin
      SrcField := lkDataSet.FindField(SourceField);
      Esci := not Assigned(SrcField);
    end;

    if Esci then
    begin
      SiMain.LogString(Name, 'Lookup: non ho trovato i campi ' + SourceField + ' e ' + DestField);
      Exit;
    end;

    if DstField.Value <> SrcField.Value then
      DstField.Value := SrcField.Value;
  end;

/// ////////////////////////
begin
  if not Assigned(lkDataSet) then
    Exit;

  if lkDataSet.IsEmpty then
    Exit;

  CheckEditMode;

  Str := TStringList.Create;
  try
    Str2 := TStringList.Create;
    try
      Str2.Delimiter := '@';
      Str.Delimiter := ';';
      Str.DelimitedText := LookupString;
      for I := 0 to Str.Count - 1 do
        if Str[I] <> '' then
        begin
          s := Trim(Str[I]);
          Str2.DelimitedText := s;

          if Str2.Count = 1 then
          begin
            DestField := s;
            SourceField := s;
          end
          else
            if Str2.Count = 2 then
            begin
              SourceField := Str2[0];
              DestField := Str2[1];
            end;
          CopyField(SourceField, DestField);
        end;
    finally
      FreeAndNil(Str2);
    end;
  finally
    FreeAndNil(Str);
  end;

  if Assigned(FOnAfterLookupFieldsCopied) then
    OnAfterLookupFieldsCopied(Self, lkDataSet, LookupString);
end;

procedure TzFbDataSet.CheckBeforePost;
var
  I: integer;
  Msg: string;
  ErrorFields: string;
  ErrorCount: integer;
  Field: TField;
begin
  if not RequiredFieldsOk then
  begin
    Msg := '';
    ErrorFields := '';
    ErrorCount := 0;

    for I := 0 to FieldCount - 1 do

    begin
      Field := Fields[I];
      if not RequiredFieldOk(Field) then
      begin
        Inc(ErrorCount);
        ErrorFields := ErrorFields + Field.DisplayLabel + ' ' + #13;
      end;
    end;

    if ErrorCount > 0 then
    begin
      Msg := Name + ': i campi seguenti devono avere un valore:' + #13 + #13 + ErrorFields;
      raise Exception.Create(Msg);
    end;
  end;
end;

function TzFbDataSet.IsMasterDetailParam(ParamName: string): boolean;
begin
  Result := false;
  if ParamExists(ParamName) then
    if Assigned(DataSource) then
      if Assigned(DataSource.DataSet) then
        if Assigned(DataSource.DataSet.FindField(ParamName)) then
          Result := True;
end;

/// ////////////////////////////////////////////////////////////////////////

procedure TzFbDataSet.SetActivationMode(const Value: TActivationMode);
begin
  FActivationMode := Value;
end;

procedure TzFbDataSet.GetParamValues(aParams: TParams);
var
  I: integer;
  CurParam: TParam;
  FldType: TFieldType;
begin
  if not Assigned(aParams) then
    Exit;

  aParams.Clear;

  for I := 0 to Pred(Params.Count) do
  begin
    CurParam := aParams.CreateParam(Params[I].DataType, Params[I].Name, Params[I].ParamType);
    CurParam.Value := Params[I].Value
  end;
end;

// TODO: RefreshFromDataSet
// procedure TzFbDataSet.RefreshFromDataSet(RefreshDataSet: TDataset; const KeyFields: string; IsDeletedRecords: Boolean = false; DoAdditionalRefreshRec: Boolean = false);
// var
// fl: TList;
// p: TFIBXSQLVAR;
// KeyValues: array of variant;
// SrcKeys: array of TField;
// I: integer;
// CurRec: integer;
// OldActiveRecord: integer;
// begin
// fl := TList.Create;
// CurRec := GetRecno;
// DisableControls;
// DisableScrollEvents;
// OldActiveRecord := ActiveRecord;
// try
// GetFieldList(fl, KeyFields);
//
// if not RefreshDataSet.Active then
// begin
// if RefreshDataSet is TFIBDataSet then
// for I := 0 to Pred(self.ParamCount) do
// begin
// p := TFIBDataSet(RefreshDataSet).Params.ByName[self.Params[I].Name];
// if p <> nil then
// p.Value := self.Params[I].Value
// end;
// RefreshDataSet.Open
// end;
//
// SetLength(SrcKeys, fl.Count);
// for I := 0 to fl.Count - 1 do
// SrcKeys[I] := RefreshDataSet.fieldbyname(TField(fl.List^[I]).FieldName);
// SetLength(KeyValues, fl.Count);
//
// RefreshDataSet.First;
// while not RefreshDataSet.EOF do
// begin
// for I := 0 to fl.Count - 1 do
// KeyValues[I] := SrcKeys[I].Value;
//
// if Locate(KeyFields, KeyValues, []) then
// begin
// if IsDeletedRecords then
// CacheDelete
// else
// CacheRefresh(RefreshDataSet, frkEdit, nil);
// end
// else
// if not IsDeletedRecords then
// CacheRefresh(RefreshDataSet, frkInsert, nil);
//
// if DoAdditionalRefreshRec then
// Refresh; // For Record which anymore approach conditions
//
// RefreshDataSet.Next
// end;
//
// finally
// Recno := CurRec;
// SetRecordPosInBuffer(OldActiveRecord);
// EnableControls;
// EnableScrollEvents;
// fl.Free
// end;
//
// end;

procedure TzFbDataSet.SetParamValues(aParams: TParams);
var
  I: integer;
  CurParam: TFDParam;
begin
  if Assigned(aParams) then
    for I := 0 to aParams.Count - 1 do
    begin
      CurParam := FindParam(aParams[I].Name);
      if CurParam <> nil then
        CurParam.Value := aParams[I].Value;
    end;
end;

procedure TzFbDataSet.DoBeforeInsert;
begin
  // ZZ 18.05.2016
  // M/D: verifica che il master non sia ancora in stato di Insert

  if Assigned(DataSource) then
    if Assigned(DataSource.DataSet) then
      if DataSource.DataSet.State = dsInsert then
        DataSource.DataSet.checkBrowseMode;

  inherited;
end;

function TzFbDataSet.RequiredFieldOk(Field: TField): boolean;
begin
  Assert(Assigned(Field));
  Result := True;

  if Field.Required then
    if Field.IsNull then
      if not Field.ReadOnly then
        if Field.FieldKind = fkData then
          if not IsJoinedField(Field) then
            Result := false;
end;

procedure TzFbDataSet.SetCountSQL(const Value: TStrings);
begin
  FCountSQL := Value;
end;

function TzFbDataSet.IsJoinedField(FieldName: string): boolean;
var
  Column: TFDDatSColumn;
begin
  Result := false;

  if Assigned(Table) then
  begin
    Column := Table.Columns.ColumnByName(FieldName);

    if Assigned(Column) then
      Result := UpdateOptions.UpdateTableName <> Column.OriginTabName;
  end;
end;

function TzFbDataSet.IsParamUID(FieldName: string): boolean;
var
  Dummy: integer;
begin
  Result := false;

  if not Assigned(Adapter) then
    Exit;

  if Assigned(Adapter.InsertCommand) then
    if Assigned(Adapter.InsertCommand.Params.ParamByName(FieldName)) then
      Exit(True);

  if Assigned(Adapter.UpdateCommand) then
    if Assigned(Adapter.UpdateCommand.Params.ParamByName(FieldName)) then
      Exit(True);

  if Assigned(Adapter.DeleteCommand) then
    if Assigned(Adapter.DeleteCommand.Params.ParamByName(FieldName)) then
      Exit(True);
end;

function TzFbDataSet.GetDebugInfo: string;
var
  I: integer;
  ParamStr: string;
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrList.Add(Name + '.Active = ' + BoolToStr(Active, True));
    StrList.Add('');
    StrList.Add('SQL:'#13#10 + SQL.Text);
    StrList.Add('');

    if ParamCount > 0 then
    begin
      StrList.Add('Params:');

      for I := 0 to ParamCount - 1 do
      begin
        if Params[I].IsNull then
          ParamStr := Params[I].Name + '= (Null)'
        else
        begin
          if IsNumericType(Params[I].DataType) then
            ParamStr := Params[I].Name + '=' + Params[I].AsString
          else
            if IsFloatType(Params[I].DataType) then
              ParamStr := Params[I].Name + '=' + Params[I].AsString
            else
              if IsDateTimeType(Params[I].DataType) then
                ParamStr := Params[I].Name + '=' + AnsiQuotedStr(Params[I].AsString, #39)
              else
                ParamStr := Params[I].Name + '=' + AnsiQuotedStr(Params[I].AsString, #39);
        end;
        StrList.Add(ParamStr);
      end;
    end;
    Result := StrList.Text;
  finally
    FreeAndNil(StrList);
  end;
end;

function TzFbDataSet.DebugInsertString: string;
var
  Field: TField;
  I: integer;
  s: string;
  Str: TStringList;
  FieldNames: TStringList;
begin
  Result := '';

  FieldNames := TStringList.Create;
  try
    Connection.GetFieldNames('', '', TableName, '', FieldNames);

    if FieldNames.Count = 0 then
      Exit;

    Str := TStringList.Create;
    try
      Str.Clear;
      Str.Add('INSERT INTO ' + TableName + ' (');
      for I := 0 to FieldNames.Count - 1 do
      begin
        s := '  ' + FieldNames.Strings[I];
        if I <> FieldNames.Count - 1 then
          s := s + ','
        else
          s := s + ')';
        Str.Add(s);
      end;

      Str.Add('VALUES (');
      for I := 0 to FieldNames.Count - 1 do
      begin

        Field := FindField(FieldNames.Strings[I]);

        if not Assigned(Field) then
          s := 'NULL'
        else
          if Field.IsNull then
            s := 'NULL'
          else
            case Field.DataType of
              ftString, ftFixedChar, ftWideString:
                begin
                  s := AnsiQuotedStr(Field.AsString, #39);
                end;
              ftSmallint, ftInteger, ftWord, ftLargeint:
                s := Field.AsString;
              ftBoolean:
                s := BoolToStr(Field.asBoolean, True);
              ftFloat, ftCurrency, ftBCD:
                s := Field.AsString;
              ftDate, ftTime, ftDateTime:
                s := AnsiQuotedStr(StringReplace(Field.AsString, FormatSettings.DateSeparator, '.', [rfReplaceAll]), #39);

              ftBlob, ftMemo, ftWideMemo, ftGraphic, ftFmtMemo:
                s := '(BLOB)';
            else
              s := '(unknown)';
            end;

        if I <> FieldNames.Count - 1 then
          s := s + ','
        else
          s := s + ')';
        Str.Add(s);
      end;
      Result := Str.Text;
    finally
      FreeAndNil(Str);
    end;
  finally
    FreeAndNil(FieldNames);
  end;
end;

function TzFbDataSet.DebugUpdateString: string;
begin

end;

procedure TzFbDataSet.DoCreateFields;
  function TrimAll(const s: string): string;
  const
    ValidChar = ['A' .. 'Z', 'a' .. 'z', '_', '0' .. '9'];
  var
    I: integer;
  begin
    Result := '';
    for I := 1 to Length(s) do
      if s[I] in ValidChar then
        Result := Result + s[I];
  end;

var
  I: integer;
begin
  doBeforeCreateFields;
  inherited;

  for I := 0 to FieldCount - 1 do
    Fields[I].Name := Name + TrimAll(Fields[I].FieldName);

  BindFields(True);
  SetFieldsOrigin;
  SetFieldsReadOnly;
  SetRequiredForJoinFields;

  doAfterCreateFields;
end;

function TzFbDataSet.GetLocateSQL(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): string;
var
  Field: TField;
  FieldName: string;
  Fields: TList;
  I: integer;
  OperatorStr: string;
  ValStr: string;
  Value: Variant;
  Values: Variant;
  dummyInt: largeint;
  dummyFloat: Extended;
begin
  Result := '';
  try
    Fields := TList.Create;
    try
      GetFieldList(Fields, KeyFields);

      for I := 0 to Fields.Count - 1 do
      begin
        if (Fields.Count = 1) and not VarIsArray(KeyValues) then
          Value := KeyValues
        else
          Value := KeyValues[I];

        if VarIsNull(Value) then
          Continue;

        Field := TField(Fields[I]);
        FieldName := Field.Origin;
        if FieldName = '' then
          FieldName := Field.FieldName;

        OperatorStr := ' = ';

        case Field.DataType of
          ftString, ftFixedChar, ftWideString, ftGuid, ftFixedWideChar:
            begin
              ValStr := VarToStr(Value);
              OperatorStr := ' STARTING WITH ';

              // if ValStr = '' then
              // ValStr := #255
              // else
              // zz 13 marzo 2018: non entra mai nel giro dell' like
              // if (I = Fields.Count - 1) and (LoPartialKey in Options) then
              // begin
              // OperatorStr := ' STARTING WITH ';
              // end
              // else
              if ValStr.EndsWith('*') then
              begin
                OperatorStr := ' LIKE ';
                ValStr := System.Copy(ValStr, 1, Length(ValStr) - 1);
                ValStr := '%' + ValStr + '%';
              end;

              ValStr := QuotedStr(ValStr);

              if LoCaseInsensitive in Options then
                ValStr := UpperCase(ValStr);
            end;
          ftDate, ftTime, ftDateTime, ftTimeStamp, ftTimeStampOffset:
            begin
              ValStr := QuotedStr(FormatDateTime('dd.mm.yyyy', Values[I]));
            end;

          ftBoolean:
            begin
              ValStr := VarToStr(Value);
            end;
          ftSmallint, ftShortint, ftByte, ftInteger, ftWord, ftAutoInc, ftLargeint, TFieldType.ftSingle:
            begin
              ValStr := VarToStr(Value);
              ValStr := StringReplace(ValStr, '.', '', [rfReplaceAll]); // se arriva come stringa formattata, es 1.234.567

              if not TryStrToInt64(ValStr, dummyInt) then
                ValStr := 'null';
            end;
          ftFloat, ftCurrency, ftBCD, ftFMTBcd:
            begin
              ValStr := VarToStr(Value);
              ValStr := StringReplace(ValStr, '.', '', [rfReplaceAll]); // se arriva come stringa formattata, es 1.234.567

              if not TryStrToFloat(ValStr, dummyFloat) then
                ValStr := 'null';
            end;
        else
          DatabaseErrorFmt(SBadFieldType, [TField(Fields[I]).FieldName]);
        end;

        if Result <> '' then
          Result := Result + ' AND ';

        // if VarIsNull(Value) then
        // Result := Result + FieldName + ' IS NULL'
        // else
        Result := Result + FieldName + OperatorStr + ValStr;
      end;
    finally
      FreeAndNil(Fields);
    end;

  finally
    // OutputDebugString('');
    // OutputDebugString('----Locate------');
    // OutputDebugString('---');
    // OutputDebugString(PChar(Result));
    // OutputDebugString('---');
    // OutputDebugString(PChar('KeyFields: ' + KeyFields));
    // OutputDebugString(PChar('KeyValues: >' + VarToStr(KeyValues) + '<'));
    // if loCaseInsensitive in Options then
    // OutputDebugString('loCaseInsensitive');
    //
    // if loPartialKey in Options then
    // OutputDebugString('loPartialKey');
  end;
end;

function TzFbDataSet.GetPrimaryKeyFields: string;
begin
  Result := UpdateOptions.KeyFields;
end;

function TzFbDataSet.GetSQL_Delete: TStrings;
begin
  Result := InnerUpdateObject.DeleteSQL;
end;

function TzFbDataSet.GetSQL_Insert: TStrings;
begin
  Result := InnerUpdateObject.InsertSQL;
end;

function TzFbDataSet.GetSQL_Refresh: TStrings;
begin
  Result := InnerUpdateObject.FetchRowSQL;
end;

function TzFbDataSet.GetSQL_Select: TStrings;
begin
  Result := SQL;
end;

function TzFbDataSet.GetSQL_Update: TStrings;
begin
  Result := InnerUpdateObject.ModifySQL;
end;

function TzFbDataSet.GetTableName: string;
begin
  Result := UpdateOptions.UpdateTableName;
end;

function TzFbDataSet.Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
begin
  if UseSqlLocate then
    Result := LocateSQL(AKeyFields, AKeyValues, AOptions)
  else
    Result := inherited Locate(AKeyFields, AKeyValues, AOptions);
end;

function TzFbDataSet.LocateFound(KeyFields: string; KeyValues: Variant; Options: TLocateOptions): boolean;
  function SameValue(V1, V2: Variant; IsString, CaseInsensitive, PartialLength: boolean): boolean;
  var
    s, S1, S2: string;
  begin
    if not IsString then
      Result := VarCompareValue(V1, V2) = VrEqual
    else
    begin
      S1 := VarToStr(V1);
      S2 := VarToStr(V2);

      if PartialLength then
        S2 := Copy(S2, 1, Length(S1));

      if CaseInsensitive then
        Result := AnsiSameText(S1, S2)
      else
        Result := AnsiSameStr(S1, S2);
    end;
  end;

var
  J: integer;
  Field: TField;
  Fields: TList;
  Values: Variant;
begin
  Result := True;

  Fields := TList.Create;
  try
    GetFieldList(Fields, KeyFields);

    if VarIsArray(KeyValues) then
      Values := KeyValues
    else
      Values := VarArrayOf([KeyValues]);

    for J := 0 to Fields.Count - 1 do
    begin
      Field := TField(Fields[J]);
      if not SameValue(Field.Value, Values[J], Field.DataType in [ftString, ftFixedChar], LoCaseInsensitive in Options, LoPartialKey in Options) then
      begin
        Result := false;
        Break;
      end;
    end;

  finally
    FreeAndNil(Fields);
  end;
end;

function TzFbDataSet.LocateParamsEmpty(KeyValues: Variant): boolean;
  function Empty(KeyValue: Variant): boolean;
  begin
    Result := (KeyValue = Null) or VarIsNull(KeyValue);

    if not Result then
      if VarIsStr(KeyValue) then
        Result := VarToStr(KeyValue) = '';
  end;

var
  I: integer;
begin
  Result := True;

  if VarIsArray(KeyValues) then
  begin
    for I := VarArrayLowBound(KeyValues, 1) to VarArrayHighBound(KeyValues, 1) do
      if not Empty(KeyValues[I]) then
        Exit(false);

    Exit(True);
  end
  else
    Result := Empty(KeyValues);
end;

function TzFbDataSet.LocateSQL(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
var
  Where: string;
begin
  Result := false;

  if not Active then
    Exit(false);

  if InLocate then
    Exit;

  InLocate := True;
  try

    if LocateParamsEmpty(AKeyValues) then
    begin
      // zz 26.10.2017: per i MasterFields variati dopo la creazione dei lookup
      // if (LocateWhere <> '') then
      RevertSQL(True);

      Exit(false)
    end;

    if LocateFound(AKeyFields, AKeyValues, AOptions) then
      Exit(True); // sarebbe da verificare con il resto della lista..

    Where := GetLocateSQL(AKeyFields, AKeyValues, AOptions);

   // se non è valido con il test sopra è inutule mantenere la where precedente
    // if (LocateWhere <> Where) then
    // begin

    LocateWhere := Where;
    DisableControls;
    try
      RevertSQL(false);
      AddWhereCondition(LocateWhere);
      Active := True;
    finally
      EnableControls;
    end;
    // end;

    Result := not IsEmpty;
  finally
    InLocate := false;
  end;
end;

procedure TzFbDataSet.SetPrimaryKeyFields(const Value: string);
begin
  UpdateOptions.KeyFields := Value;
end;

procedure TzFbDataSet.SetSQL_Delete(const Value: TStrings);
begin
  InnerUpdateObject.DeleteSQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Insert(const Value: TStrings);
begin
  InnerUpdateObject.InsertSQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Refresh(const Value: TStrings);
begin
  InnerUpdateObject.FetchRowSQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Select(const Value: TStrings);
begin
  SQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Update(const Value: TStrings);
begin
  InnerUpdateObject.ModifySQL.Assign(Value);
end;

procedure TzFbDataSet.TryChangeSQL(const NewSql: string);
var
  Parser: TSQLParser;
  wasActive: boolean;
  s: string;
  oldSql: string;
  SQLParser: TSQLParser;
begin
  if SameText(SQL.Text, NewSql) then
    Exit;

  wasActive := Active;
  Active := false;
  oldSql := SQL.Text;
  SQL.Text := NewSql;

  if wasActive then
  begin
    try
      Active := True;
    except
      on e: Exception do
      begin
        SQL.Text := oldSql;
        Active := True;
        raise;
      end;
    end;
  end;
end;

procedure TzFbDataSet.AddWhereCondition(const Condition: string);
var
  Parser: TSQLParser;
begin
  Parser := TSQLParser.Create(Self);
  try
    Parser.SQL := SQL.Text;
    Parser.AddWhereCondition(Condition);
    TryChangeSQL(Parser.SQL);
  finally
    FreeAndNil(Parser);
  end;
end;

function TzFbDataSet.GetAutoCommit: boolean;
begin
  Result := UpdateOptions.AutoCommitUpdates;
end;

function TzFbDataSet.GetDatabase: TFDCustomConnection;
begin
  Result := Connection;
end;

function TzFbDataSet.GetGeneratorName: string;
begin
  Result := UpdateOptions.GeneratorName;
end;

procedure TzFbDataSet.SetWhere(const Value: string);
var
  Parser: TSQLParser;
begin
  Parser := TSQLParser.Create(Self);
  try
    Parser.SQL := SQL.Text;
    Parser.Where := Value;
    TryChangeSQL(Parser.SQL);
  finally
    FreeAndNil(Parser);
  end;
end;

procedure TzFbDataSet.SetOrderBy(const Value: string);
var
  Parser: TSQLParser;
begin
  Parser := TSQLParser.Create(Self);
  try
    Parser.SQL := SQL.Text;
    Parser.OrderBy := Value;
    TryChangeSQL(Parser.SQL);
  finally
    FreeAndNil(Parser);
  end;
end;

function TzFbDataSet.GetOrderBy: string;
var
  Parser: TSQLParser;
begin
  Parser := TSQLParser.Create(Self);
  try
    Parser.SQL := SQL.Text;
    Result := Parser.OrderBy;
  finally
    FreeAndNil(Parser);
  end;
end;

function TzFbDataSet.GetUniDirectional: boolean;
begin
  Result := FetchOptions.UniDirectional;
end;

function TzFbDataSet.GetWhere: string;
var
  Parser: TSQLParser;
begin
  Parser := TSQLParser.Create(Self);
  try
    Parser.SQL := SQL.Text;
    Result := Parser.Where;
  finally
    FreeAndNil(Parser);
  end;
end;

procedure TzFbDataSet.RebuildFields;
begin
  Fields.Clear;
  DoCreateFields;
end;

procedure TzFbDataSet.ReopenLocate(const LocateFieldName: string);
var
  CurrentValue: Variant;
  OldUseSqlLocate: boolean;
begin
  CurrentValue := FieldByName(LocateFieldName).Value;

  ReOpen(True);

  OldUseSqlLocate := UseSqlLocate;
  try
    UseSqlLocate := false;
    Locate(LocateFieldName, CurrentValue, []);
  finally
    UseSqlLocate := OldUseSqlLocate;
  end;
end;

procedure TzFbDataSet.SetAutoCommit(const Value: boolean);
begin
  UpdateOptions.AutoCommitUpdates := Value;
end;

procedure TzFbDataSet.SetDatabase(const Value: TFDCustomConnection);
begin
  Connection := Value;
end;

procedure TzFbDataSet.SetFieldsReadOnly;
var
  Field: TField;
begin
  for Field in Fields do
    if not Field.ReadOnly then
      if IsJoinedField(Field.FieldName) then
        if not IsParamUID(Field.FieldName) then
          Field.ReadOnly := True;
end;

procedure TzFbDataSet.SetGeneratorName(const Value: string);
begin
  UpdateOptions.GeneratorName := Value;
end;

procedure TzFbDataSet.SetUniDirectional(const Value: boolean);
begin
  FetchOptions.UniDirectional := Value;
end;

//
// GetSetElementName(TypeInfo(pippo), integer(x));
//
{ TzFibErrors }

constructor TzFibErrors.Create;
begin
  FLastErrorMsg := '';
  FHandleErrors := True;
  FRaiseErrors := false;
end;

procedure TzFibErrors.SetHandleErrors(const Value: boolean);
begin
  FHandleErrors := Value;
  if not Value then // se si imposta la gestione manuale deve essere pulito
    LastErrorMsg := '';
end;

procedure TzFbSQL.ExecQuery;
begin
  ExecSQL;
end;

function TzFbSQL.GetDatabase: TFDCustomConnection;
begin
  Result := Connection;
end;

procedure TzFbSQL.SetDatabase(const Value: TFDCustomConnection);
begin
  Connection := Value;
end;

function TzFbStoredProc.DebugString: string;
begin
  Result := '';
end;

function TzFbStoredProc.GetDatabase: TFDCustomConnection;
begin
  Result := Connection;
end;

function TzFbStoredProc.ParamByName(const ParamName: string): TFDParam;
begin
  Result := Params.ParamByName(ParamName);
end;

function TzFbStoredProc.ParamExists(const ParamName: string): boolean;
begin
  Result := Params.ParamExists(ParamName);
end;

procedure TzFbStoredProc.SetDatabase(const Value: TFDCustomConnection);
begin
  Connection := Value;
end;

function TzFbDatabase.Gen_ID(const GeneratorName: string; Step: Int64): Int64;
begin
  Result := ExecSQLScalar('SELECT GEN_ID(' + GeneratorName + ', ' + Step.ToString + ') FROM RDB$DATABASE');
end;

constructor TzFbTransaction.Create(AOwner: TComponent);
begin
  inherited;
  SavePoints := TStack<string>.Create;
end;

destructor TzFbTransaction.Destroy;
begin
  FreeAndNil(SavePoints);
  inherited;
end;

procedure TzFbTransaction.CloseTransaction(const doCommit: boolean = True);
begin
  if not Active then
    Exit;

  if doCommit then
    Commit
  else
    Rollback;
end;

procedure TzFbTransaction.SetSavePoint(const SavePoint: string);
begin
  StartTransaction;
  SavePoints.Push(SavePoint);
end;

procedure TzFbTransaction.RollBackToSavePoint(const SavePoint: string);
begin
  Rollback;

  if not SameText(SavePoints.Pop, SavePoint) then
    raise Exception.Create('Errore interno: pagina ' + SavePoint);
end;

function CreateFbDataSet(Owner: TComponent; DB: TzFbDatabase; ReadTrans, WriteTrans: TzFbTransaction; const UniDirectional: boolean = false): TzFbDataSet;
begin
  Result := TzFbDataSet.Create(Owner);
  Result.Connection := DB;
  Result.Transaction := ReadTrans;
  Result.UpdateTransaction := WriteTrans;
  Result.FetchOptions.UniDirectional := UniDirectional;
end;

initialization

__zFibErrors := nil;

finalization

if Assigned(__zFibErrors) then
  FreeAndNil(__zFibErrors);

end.
