unit zDataController;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  Vcl.Controls,
  zFbDataSet;

type
  TzDbOperation = (zdoMove, zdoInsert, zdoEdit, zdoDelete, zdoRefresh);
  TzDbOperations = set of TzDbOperation;

  TzRefreshMethod = (zrmRefresh, zrmReopen);

  TDataControllerShowRecordEvent = procedure(Sender: TObject; Inserting: boolean) of object;

  TzDataController = class(TComponent)
  private
    FDisableClearFields: boolean;
    FDataSet: TDataSet;
    FReadOnly: boolean;
    FDbOperations: TzDbOperations;
    FIsSQL: boolean;
    FOnShowRecord: TDataControllerShowRecordEvent;
    FRefreshMethod: TzRefreshMethod;
    function GetAutoOpen: boolean;
    function GetidDataSet: string;
    function GetPrimaryKeyFields: string;
    function GetSQL: string;
    function GetSQL_OrderBy: string;
    function GetSQL_Where: string;
    function GetzFbDataSet: TzFbDataSet;
    procedure SetReadOnly(const Value: boolean);
    procedure SetDbOperations(const Value: TzDbOperations);
    procedure SetPrimaryKeyFields(const Value: string);
    procedure SetSQL(const Value: string);
    procedure SetSQL_OrderBy(const Value: string);
    procedure SetSQL_Where(const Value: string);
    procedure SetzFbDataSet(const Value: TzFbDataSet);
  private type
    TSaveFetchOptions = record
      RecsMax: integer;
      UniDirectional: boolean;
      procedure Init;
    end;

  private
    SaveFetchOptions: TSaveFetchOptions;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetDataSet(const Value: TDataSet); virtual;
    procedure DoRefresh; virtual;
  public
    constructor Create(aOwner: TComponent); override;
    function DataSetOk: boolean;
    procedure OpenDataSet;
    procedure CloseDataSet;
    function GetField(const FieldName: string): TField;
    function GetFieldOrigin(Field: TField): string;
    function GetFieldByOrigin(const Origin: string): TField;
    function GetFieldNameByOrigin(const Origin: string): string;

    function FieldValue(const FieldName: string): variant;
    function TryGetField(const FieldName: string; var Field: TField): boolean;
    procedure ClearFields(FieldsToClear: string);
    function RequiredFieldOk(Field: TField): boolean;
    function RequiredFieldsOk: boolean;
    procedure DuplicateRecord(DoPost: boolean; ExcludeFields: string);
    function Fields: TFields;
    //
    function IsActive: boolean;
    function IsEditing: boolean;
    function IsEmpty: boolean;
    function DataSetState: TDataSetState;

    function IsFieldReadOnly(Field: TField): boolean; overload;
    function IsFieldReadOnly(FieldName: String): boolean; overload;

    function IsJoinedField(Field: TField): boolean; overload;
    function IsJoinedField(FieldName: String): boolean; overload;

    // TODO  procedure EditSQL;
    // TODO  EnumFields
    // TODO  ActivationMode
    function GetDebugInfo: string;
    //
    function ConfirmDelete(const MultiDelete: boolean = False): boolean;
    function CloseQuery: boolean;

    function GetRecordCount: integer;
    procedure GotoBookmark(Bookmark: TBookmark);
    function Validate(RaiseException: boolean): boolean;
    //
    procedure DisableControls;
    procedure EnableControls;
    //
    procedure BeforeExport;
    procedure AfterExport;
    //
    procedure First;
    procedure Prior;
    procedure Next;
    procedure Last;
    procedure Insert;
    procedure Edit;
    procedure Delete;
    procedure Post;
    procedure Refresh;
    procedure Cancel;
    procedure UpdateRecord;
    procedure CheckBrowseMode;
    procedure CheckEditMode;

    function EOF: boolean;
    function BOF: boolean;
    //
    function CanFirst: boolean;
    function CanPrior: boolean;
    function CanNext: boolean;
    function CanLast: boolean;
    function CanPost: boolean;
    function CanCancel: boolean;
    function CanDelete: boolean;
    function CanEdit: boolean;
    function CanInsert: boolean;
    function CanMove: boolean;
    function CanRefresh: boolean;
    function CanFilter: boolean;

    procedure ApplyFilter(const Filter: string);
  Public
    property AutoOpen: boolean read GetAutoOpen;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property zFbDataSet: TzFbDataSet read GetzFbDataSet write SetzFbDataSet;
    property IsSQL: boolean read FIsSQL;
    property SQL: string read GetSQL write SetSQL;
    property SQL_OrderBy: string read GetSQL_OrderBy write SetSQL_OrderBy;
    property SQL_Where: string read GetSQL_Where write SetSQL_Where;
    property PrimaryKeyFields: string read GetPrimaryKeyFields write SetPrimaryKeyFields;

    property idDataSet: string read GetidDataSet;
    property ReadOnly: boolean read FReadOnly write SetReadOnly default False;
    property RefreshMethod: TzRefreshMethod read FRefreshMethod write FRefreshMethod default zrmReopen;
    property DbOperations: TzDbOperations read FDbOperations write SetDbOperations default [zdoMove, zdoInsert, zdoEdit, zdoDelete, zdoRefresh];
    property DisableClearFields: boolean read FDisableClearFields;
    property OnShowRecord: TDataControllerShowRecordEvent read FOnShowRecord write FOnShowRecord;
  end;

implementation

uses
  System.Variants,
  Vcl.Forms,
  Vcl.Dialogs,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  zBaseLib,
  zMsg;

procedure TzDataController.TSaveFetchOptions.Init;
begin
  RecsMax := -1;
  UniDirectional := False;
end;

constructor TzDataController.Create(aOwner: TComponent);
begin
  inherited;
  FDisableClearFields := False;
  FIsSQL := False;
  FDataSet := nil;
  FReadOnly := False;
  FRefreshMethod := zrmReopen;
  FDbOperations := [zdoMove, zdoInsert, zdoEdit, zdoDelete, zdoRefresh];

  FOnShowRecord := nil;
  SaveFetchOptions.Init;
end;

procedure TzDataController.DoRefresh;
var
  recNo: integer;
  Bookmark: TBookmark;

  procedure GetBookmark;
  begin
    Bookmark := DataSet.Bookmark;
  end;

  procedure GotoBookmark;
  begin
    try
      DataSet.Bookmark := Bookmark;
    except
    end;
  end;

begin
  if not DataSetOk then
    Exit;

  if RefreshMethod = zrmReopen then
  begin
    Screen.Cursor := crSqlWait;
    try
      DataSet.DisableControls;
      try
        GetBookmark;
        try
          DataSet.Active := False;
          DataSet.Active := true;
        finally
          GotoBookmark;
        end;
      finally
        DataSet.EnableControls;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end // \reOpen
  else
    if RefreshMethod = zrmRefresh then
    begin
      if IsActive then
      begin
        Screen.Cursor := crSqlWait;
        try
          GetBookmark;
          try
            DataSet.Refresh;
          finally
            GotoBookmark;
          end;
        finally
          Screen.Cursor := crDefault;
        end;
      end
      else
        if DataSetOk then
          OpenDataSet;
    end; // \refresh
end;

function TzDataController.DataSetOk: boolean;
begin
  // Un dataset in distruzione ha gia' svuotato i campi (FindField va in violazione di accesso),
  // ma e' ancora assegnato finche' non arriva la notifica di rimozione, che segue la distruzione dei campi
  result := Assigned(FDataSet) and not(csDestroying in FDataSet.ComponentState);
end;

function TzDataController.IsActive: boolean;
begin
  result := DataSetOk and DataSet.Active;
end;

function TzDataController.IsEditing: boolean;
begin
  result := DataSetOk and IsActive and (DataSet.State in dsEditModes)
end;

function TzDataController.IsEmpty: boolean;
begin
  result := true;
  if IsActive then
    result := DataSet.IsEmpty;
end;

procedure TzDataController.OpenDataSet;
begin
  if DataSetOk then
  begin
    Screen.Cursor := crSqlWait;
    try
      DataSet.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TzDataController.CloseDataSet;
begin
  if IsActive then
    DataSet.Active := False;
end;

function TzDataController.ConfirmDelete(const MultiDelete: boolean = False): boolean;
var
  Msg: string;
begin
  result := False;

  if MultiDelete then
    Msg := 'Elimino tutti i records selezionati?'
  else
    Msg := 'Elimino il record?';
  result := ConfirmYesNo(Msg);
end;

function TzDataController.BOF: boolean;
begin
  result := False;

  if IsActive then
    result := DataSet.BOF;
end;

function TzDataController.EOF: boolean;
begin
  result := False;

  if IsActive then
    result := DataSet.EOF;
end;

function TzDataController.GetField(const FieldName: string): TField;
begin
  result := nil;
  if DataSetOk then
    result := DataSet.FindField(FieldName);
end;

function TzDataController.TryGetField(const FieldName: string; var Field: TField): boolean;
begin
  result := False;
  Field := nil;
  if DataSetOk then
  begin
    Field := DataSet.FindField(FieldName);
    result := Assigned(Field);
  end;
end;

function TzDataController.Validate(RaiseException: boolean): boolean;
var
  Msg: string;
  ErrorFields: string;
  ErrorCount: integer;
  Field: TField;
  I: integer;
begin
  result := true;

  if not IsActive then
    Exit;

  Msg := '';
  ErrorFields := '';
  ErrorCount := 0;

  for Field in DataSet.Fields do
    if Field.Required and not Field.ReadOnly and (Field.FieldKind = fkData) and Field.IsNull then
    begin
      Inc(ErrorCount);
      ErrorFields := ErrorFields + Field.DisplayLabel + #13;
    end;

  if ErrorCount > 0 then
  begin
    result := False;
    if RaiseException then
    begin
      Msg := 'I campi seguenti devono avere un valore:' + #13 + #13 + ErrorFields;
      raise Exception.Create(Msg);
    end;
  end;
end;

procedure TzDataController.ClearFields(FieldsToClear: string);

  procedure ClearField(Field: TField);
  var
    WasReadOnly: boolean;
  begin
    WasReadOnly := Field.ReadOnly;
    Field.ReadOnly := False;
    CheckEditMode;
    Field.Clear;
    Field.ReadOnly := WasReadOnly;
  end;

var
  I: integer;
  Str: TStringList;
  Field: TField;
  FieldName: string;
begin
  if trim(FieldsToClear) = '' then
    Exit;

  if not IsActive then
    Exit;

  if DisableClearFields then
    Exit;

  FDisableClearFields := true;
  try
    // zz 07.12.2022: se ci sono card collegate provoca il locate dei lookup
    // DataSet.DisableControls;
    // try

    if IsSQL then
      zFbDataSet.ClearFields(FieldsToClear)
    else
    begin
      CheckEditMode;

      Str := TStringList.Create;
      try
        Str.Delimiter := ';';
        Str.DelimitedText := FieldsToClear;

        siMain.logString('TzDataController.ClearFields', FieldsToClear);

        for FieldName in Str do
          if not FieldName.IsEmpty then
          begin
            Field := DataSet.FindField(FieldName);

            if Assigned(Field) then
            begin
              ClearField(Field);
              siMain.logString('Field.Clear', Field.FieldName);
            end;
          end;
      finally
        FreeAndNil(Str);
      end;
    end;

    // finally
    // DataSet.EnableControls;
    // end;
  finally
    FDisableClearFields := False;
  end;
end;

procedure TzDataController.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
  FIsSQL := Assigned(Value) and (Value is TzFbDataSet);
end;

procedure TzDataController.UpdateRecord;
begin
  if not IsActive then
    Exit;

  try
    if DataSet.State in dsEditModes then
      DataSet.UpdateRecord;
  except
  end;
end;

// TODO: GetRecordCount
// function TzDataController.GetRecordCount: Integer;
// begin
// result := 0;
// if IsActive then
// result := DataSet.RecordCount;
// end;

procedure TzDataController.GotoBookmark(Bookmark: TBookmark);
begin
  if IsActive then
    if DataSet.BookmarkValid(Bookmark) then
      DataSet.GotoBookmark(Bookmark);
end;

/// //////////////////

function TzDataController.CanInsert: boolean;
begin
  result := DataSetOk and IsActive and ((zdoInsert in DbOperations)) and (not ReadOnly);
end;

procedure TzDataController.Insert;
begin

  if CanInsert then
  begin
    if Assigned(FOnShowRecord) then
      OnShowRecord(Self, true)
    else
      DataSet.Insert;
  end;
end;

function TzDataController.CanEdit: boolean;
begin
  result := DataSetOk and IsActive and (not IsEditing) and (not DataSet.IsEmpty) and (zdoEdit in DbOperations) and (not ReadOnly);
end;

procedure TzDataController.Edit;
begin
  if CanEdit then
  begin
    if Assigned(FOnShowRecord) then
      OnShowRecord(Self, False)
    else
      DataSet.Edit;
  end;
end;

function TzDataController.CanDelete: boolean;
begin
  result := DataSetOk and IsActive and (not DataSet.IsEmpty) and (zdoDelete in DbOperations) and (not ReadOnly);
end;

procedure TzDataController.Delete;
begin
  if CanDelete then
    DataSet.Delete;
end;

function TzDataController.CanCancel: boolean;
begin
  result := DataSetOk and IsEditing;
end;

procedure TzDataController.Cancel;
begin
  if CanCancel then
    DataSet.Cancel;
end;

function TzDataController.CanPost: boolean;
begin
  result := IsEditing;
end;

procedure TzDataController.Post;
begin
  if CanPost then
    DataSet.CheckBrowseMode;
end;

function TzDataController.CanMove: boolean;
begin
  result := DataSetOk and IsActive and (not DataSet.IsEmpty) and (zdoMove in DbOperations);
end;

function TzDataController.CanFilter: boolean;
begin
  result := DataSetOk and true;
end;

function TzDataController.CanFirst: boolean;
begin
  result := DataSetOk and CanMove and not DataSet.BOF;
end;

procedure TzDataController.First;
begin
  if CanFirst then
    DataSet.First;
end;

function TzDataController.CanPrior: boolean;
begin
  result := DataSetOk and CanFirst;
end;

procedure TzDataController.Prior;
begin
  if CanPrior then
    DataSet.Prior;
end;

function TzDataController.CanNext: boolean;
begin
  result := DataSetOk and CanLast;
end;

procedure TzDataController.Next;
begin
  if CanNext then
    DataSet.Next;
end;

procedure TzDataController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    if AComponent = DataSet then
      DataSet := nil;
end;

function TzDataController.CanLast: boolean;
begin
  result := CanMove and not DataSet.EOF;
end;

procedure TzDataController.Last;
begin
  if CanLast then
    DataSet.Last;
end;

function TzDataController.CanRefresh: boolean;
begin
  result := DataSetOk and IsActive and (zdoRefresh in DbOperations);
end;

procedure TzDataController.CheckBrowseMode;
begin
  if DataSetOk then
    if IsActive then
      DataSet.CheckBrowseMode
end;

procedure TzDataController.CheckEditMode;
begin
  if DataSetOk then
    if IsActive then
      if not IsEditing then
        DataSet.Edit;
end;

function TzDataController.DataSetState: TDataSetState;
begin
  result := dsInactive;

  if DataSetOk then
    result := DataSet.State;
end;

procedure TzDataController.DisableControls;
begin
  if DataSetOk then
    DataSet.DisableControls;
end;

procedure TzDataController.EnableControls;
begin
  if DataSetOk then
    DataSet.EnableControls;
end;

procedure TzDataController.DuplicateRecord(DoPost: boolean; ExcludeFields: string);
begin
  if IsSQL then
    TzFbDataSet(DataSet).DuplicateRecord(DoPost, ExcludeFields);
end;

function TzDataController.Fields: TFields;
begin
  result := nil;
  if DataSetOk then
    result := DataSet.Fields;
end;

function TzDataController.FieldValue(const FieldName: string): variant;
var
  Field: TField;
begin
  result := null;

  if TryGetField(FieldName, Field) then
    result := Field.Value;
end;

function TzDataController.GetAutoOpen: boolean;
begin
  result := true;

  if IsSQL then
    result := TzFbDataSet(DataSet).ActivationMode <> amManual;
end;

function TzDataController.GetDebugInfo: string;
begin
  result := '';
  if IsSQL then
    result := TzFbDataSet(DataSet).GetDebugInfo;
end;

function TzDataController.GetFieldByOrigin(const Origin: string): TField;
begin
  result := nil;

  if DataSetOk then
    if IsSQL then
      result := TzFbDataSet(DataSet).GetFieldByOrigin(Origin);
end;

function TzDataController.GetFieldNameByOrigin(const Origin: string): string;
begin
  result := '';
  if DataSetOk then
    if IsSQL then
      result := TzFbDataSet(DataSet).GetFieldNameByOrigin(Origin);
end;

function TzDataController.GetFieldOrigin(Field: TField): string;
begin
  result := '';

  if not Assigned(Field) then
    Exit;

  result := Field.Origin;

  if Assigned(DataSet) then
    if IsSQL then
      result := TzFbDataSet(DataSet).FieldOrigin(Field);
end;

function TzDataController.GetidDataSet: string;
begin
  result := '';

  if IsSQL then
    result := TzFbDataSet(DataSet).idDataSet;
end;

function TzDataController.GetPrimaryKeyFields: string;
begin
  result := '';
  if DataSetOk then
    if IsSQL then
      result := TzFbDataSet(DataSet).PrimaryKeyFields;
end;

function TzDataController.GetRecordCount: integer;
begin
  result := 0;

  if not IsActive then
    Exit;

  if IsSQL then
    result := TzFbDataSet(DataSet).RecordCountFromServer()
  else
    result := DataSet.RecordCount;
end;

function TzDataController.GetSQL: string;
begin
  result := '';

  if IsSQL then
    result := TzFbDataSet(DataSet).SelectSQL.Text;
end;

function TzDataController.GetSQL_OrderBy: string;
begin
  result := '';

  if IsSQL then
    result := TzFbDataSet(DataSet).OrderClause;
end;

function TzDataController.GetSQL_Where: string;
begin
  result := '';

  if IsSQL then
    result := TzFbDataSet(DataSet).Where;
end;

function TzDataController.GetzFbDataSet: TzFbDataSet;
begin
  result := nil;

  if DataSetOk then
    if IsSQL then
      result := DataSet as TzFbDataSet;
end;

function TzDataController.IsFieldReadOnly(Field: TField): boolean;
begin
  result := False;

  if not Assigned(Field) then
    Exit;

  // comprende i casi di join (vedere zFbdataSet)
  result := Field.ReadOnly;
end;

function TzDataController.IsFieldReadOnly(FieldName: String): boolean;
var
  Field: TField;
begin

  result := False;

  if TryGetField(FieldName, Field) then
    result := IsFieldReadOnly(Field);
end;

function TzDataController.IsJoinedField(Field: TField): boolean;
begin
  result := False;

  if not IsSQL then
    Exit;

  if not Assigned(Field) then
    Exit;

  result := TzFbDataSet(DataSet).IsJoinedField(Field);
end;

function TzDataController.IsJoinedField(FieldName: String): boolean;
var
  Field: TField;
begin

  result := False;

  if TryGetField(FieldName, Field) then
    result := IsJoinedField(Field);
end;

procedure TzDataController.Refresh;
begin
  DoRefresh;
end;

function TzDataController.RequiredFieldsOk: boolean;
var
  Field: TField;
  I: integer;
begin
  result := true;

  if DataSetOk then
    for Field in DataSet.Fields do
      if not RequiredFieldOk(Field) then
      begin
        result := False;
        Break;
      end;
end;

function TzDataController.RequiredFieldOk(Field: TField): boolean;
begin
  Assert(Assigned(Field));
  result := true;

  if IsSQL then
    result := TzFbDataSet(DataSet).RequiredFieldOk(Field)
  else
    if Field.Required then
      if Field.IsNull then
        if not Field.ReadOnly then
          if Field.FieldKind = fkData then
            result := False;
end;

procedure TzDataController.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;
end;

procedure TzDataController.SetDbOperations(const Value: TzDbOperations);
begin
  FDbOperations := Value;
end;

procedure TzDataController.SetPrimaryKeyFields(const Value: string);
begin
  if DataSetOk then
    if IsSQL then
      TzFbDataSet(DataSet).PrimaryKeyFields := Value;
end;

procedure TzDataController.SetSQL(const Value: string);
begin
  if IsSQL then
    TzFbDataSet(DataSet).SelectSQL.Text := Value;
end;

procedure TzDataController.SetSQL_OrderBy(const Value: string);
begin
  if IsSQL then
    TzFbDataSet(DataSet).OrderBy := Value;
end;

procedure TzDataController.SetSQL_Where(const Value: string);
begin
  if IsSQL then
    TzFbDataSet(DataSet).Where := Value;
end;

procedure TzDataController.SetzFbDataSet(const Value: TzFbDataSet);
begin
  DataSet := Value;
end;

procedure TzDataController.ApplyFilter(const Filter: string);
  procedure doStartWait;
  begin
    if DataSet.Active then
      StartWait('Attendere...', true);
  end;

  procedure doStopWait;
  begin
    if DataSet.Active then
      StopWait;
  end;

begin

  if IsSQL then
  begin
    doStartWait;
    try
      TzFbDataSet(DataSet).ApplyFilter(Filter);
    finally
      doStopWait;
    end;
  end;
end;

function TzDataController.CloseQuery: boolean;
begin
  result := true;

  if IsEditing then
  begin

    case ConfirmYesNoCancel('Salvo le modifiche?', mtInformation) of
      mrCancel:
        result := False;
      mrYes:
        Post;
      mrNo:
        Cancel;
    end;
  end;
end;

procedure TzDataController.BeforeExport;
begin
  if not IsSQL then
    Exit;

  SaveFetchOptions.RecsMax := zFbDataSet.FetchOptions.RecsMax;
  SaveFetchOptions.UniDirectional := zFbDataSet.FetchOptions.UniDirectional;

  zFbDataSet.DisableControls;
  // zFbDataSet.Active := False;
  zFbDataSet.Disconnect;
  zFbDataSet.FetchOptions.UniDirectional := true;
  zFbDataSet.FetchOptions.RecsMax := -1;

  StartWait('Attendere...', true);
  try
    zFbDataSet.Active := true;
  finally
    StopWait;
  end;
end;

procedure TzDataController.AfterExport;
begin
  zFbDataSet.Active := False;
  zFbDataSet.FetchOptions.RecsMax := SaveFetchOptions.RecsMax;
  zFbDataSet.FetchOptions.UniDirectional := SaveFetchOptions.UniDirectional;

  StartWait('Attendere...', true);
  try
    zFbDataSet.Active := true;
  finally
    StopWait;
  end;

  zFbDataSet.EnableControls;
end;

end.
