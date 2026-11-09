unit zFrmParams;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  System.Actions,
  WinApi.Windows,
  WinApi.Messages,
  Data.DB,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.ActnList,
  vcl.StdCtrls,
  vcl.ExtCtrls,
  vcl.ImgList,
  OkCancel,
  zSystem,
  pFIBStoredProc,
  FIBQuery,
  pFIBQuery,
  FIBDataSet,
  pFIBProps,
  pFIBDataSet,
  zFbDataSet,
  zStoredProc,
  zBaseLib,
  FireDAC.Stan.Param,
  cxDataStorage,
  cxCustomData,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxStyles,
  cxEdit,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  cxInplaceContainer,
  cxVGrid,
  dxScrollbarAnnotations;

type
  TzFormParams = class;

  TCustomizeParamsProc = reference to procedure(zFormParams: TzFormParams);

  TParamsDataSource = class(TcxCustomDataSource)
  private
    Params: TParams;
    FModified: boolean;
  protected
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant; override;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle; const AValue: Variant); override;
  public
    constructor Create(aParams: TParams);
    property Modified: boolean read FModified;
  end;

  TzFormParams = class(TForm)
    OkCancel: TOkCancel;
    MainPanel: TPanel;
    grid: TcxVirtualVerticalGrid;
    procedure FormShow(Sender: TObject);
  private
    zSystem: TzSystem;
    InternalParams: TParams;
    ParamsDataSource: TParamsDataSource;
    procedure CreateEditors;
    function GetValueTypeClass(DataType: TFieldType): TcxValueTypeClass;
    function GetEditPropertiesClass(DataType: TFieldType): TcxCustomEditPropertiesClass;
  private // inizializza internalParams
    procedure LoadParams(Params: TParams; HiddenParams: TStrings); overload;
    procedure LoadParams(Params: TFIBXSQLDA; HiddenParams: TStrings); overload;
    procedure LoadParams(Params: TFDParams; HiddenParams: TStrings); overload;
  private // assegna valori di ritorno
    procedure SaveParams(Params: TParams); overload;
    procedure SaveParams(Params: TFIBXSQLDA); overload;
    procedure SaveParams(Params: TFDParams); overload;
  private
    procedure UpdateHeight;

    function Edit(proc: TCustomizeParamsProc): boolean;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zFbDataSet: TzFbDataSet; const Reopen: boolean = false): boolean; overload;
    function ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zFbSQL: TzFbSQL; const Execute: boolean = false): boolean; overload;
    function ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zFbStoredProc: TzFbStoredProc; const Execute: boolean = false): boolean; overload;
    function ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zStoredProc: zStoredProc.TzStoredProc): boolean; overload;
    function ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; Params: TParams): boolean; overload;
    function ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; Params: TFDParams): boolean; overload;
  end;

function ShowParams(zSystem: TzSystem; zFbDataSet: TzFbDataSet; const Reopen: boolean = false; proc: TCustomizeParamsProc = nil): boolean; overload;
function ShowParams(zSystem: TzSystem; zFbSQL: TzFbSQL; const Execute: boolean = false; proc: TCustomizeParamsProc = nil): boolean; overload;
function ShowParams(zSystem: TzSystem; zFbStoredProc: TzFbStoredProc; const Execute: boolean = false; proc: TCustomizeParamsProc = nil): boolean; overload;
function ShowParams(zSystem: TzSystem; zStoredProc: zStoredProc.TzStoredProc; proc: TCustomizeParamsProc = nil): boolean; overload;
function ShowParams(zSystem: TzSystem; Params: TParams; proc: TCustomizeParamsProc = nil): boolean; overload;
function ShowParams(zSystem: TzSystem; Params: TFDParams; proc: TCustomizeParamsProc = nil): boolean; overload;

implementation

uses
  ibase,
  cxTextEdit,
  cxSpinEdit,
  cxCheckBox,
  cxTimeEdit,
  cxCurrencyEdit,
  cxCalc,
  cxCalendar;
{$R *.dfm}

function ShowParams(zSystem: TzSystem; zFbDataSet: TzFbDataSet; const Reopen: boolean = false; proc: TCustomizeParamsProc = nil): boolean; overload;
var
  zFormParams: TzFormParams;
begin
  Application.CreateForm(TzFormParams, zFormParams);
  try
    result := zFormParams.ShowParams(zSystem, proc, zFbDataSet, Reopen);
  finally
    FreeAndNil(zFormParams);
  end;
end;

function ShowParams(zSystem: TzSystem; zFbSQL: TzFbSQL; const Execute: boolean = false; proc: TCustomizeParamsProc = nil): boolean; overload;
var
  zFormParams: TzFormParams;
begin
  Application.CreateForm(TzFormParams, zFormParams);
  try
    result := zFormParams.ShowParams(zSystem, proc, zFbSQL, Execute);
  finally
    FreeAndNil(zFormParams);
  end;
end;

function ShowParams(zSystem: TzSystem; zFbStoredProc: TzFbStoredProc; const Execute: boolean = false; proc: TCustomizeParamsProc = nil): boolean; overload;
var
  zFormParams: TzFormParams;
begin
  Application.CreateForm(TzFormParams, zFormParams);
  try
    result := zFormParams.ShowParams(zSystem, proc, zFbStoredProc, Execute);
  finally
    FreeAndNil(zFormParams);
  end;
end;

function ShowParams(zSystem: TzSystem; zStoredProc: zStoredProc.TzStoredProc; proc: TCustomizeParamsProc = nil): boolean;
var
  zFormParams: TzFormParams;
begin
  Application.CreateForm(TzFormParams, zFormParams);
  try
    result := zFormParams.ShowParams(zSystem, proc, zStoredProc);
  finally
    FreeAndNil(zFormParams);
  end;
end;

function ShowParams(zSystem: TzSystem; Params: TParams; proc: TCustomizeParamsProc = nil): boolean; overload;
var
  zFormParams: TzFormParams;
begin
  Application.CreateForm(TzFormParams, zFormParams);
  try
    result := zFormParams.ShowParams(zSystem, proc, Params);
  finally
    FreeAndNil(zFormParams);
  end;
end;

function ShowParams(zSystem: TzSystem; Params: TFDParams; proc: TCustomizeParamsProc = nil): boolean; overload;
var
  zFormParams: TzFormParams;
begin
  Application.CreateForm(TzFormParams, zFormParams);
  try
    result := zFormParams.ShowParams(zSystem, proc, Params);
  finally
    FreeAndNil(zFormParams);
  end;
end;

function SQLType2DataType(SQLType: Integer): TFieldType;
begin
  result := ftString;

  case SQLType of
    SQL_TEXT, SQL_VARYING:
      result := ftString;
    SQL_DOUBLE, SQL_FLOAT:
      result := ftFloat;
    SQL_SHORT:
      result := ftSmallint;
    SQL_LONG:
      result := ftInteger;
    SQL_INT64:
      result := ftFloat; // may be BCD for D6+?
    SQL_TIMESTAMP:
      result := ftDateTime;
    SQL_TYPE_TIME:
      result := ftTime;
    SQL_TYPE_DATE:
      result := ftDate;
    SQL_BLOB, SQL_ARRAY:
      result := ftBlob;
  end;
end;

constructor TParamsDataSource.Create(aParams: TParams);
begin
  inherited Create;
  FModified := false;
  Params := aParams;
end;

function TParamsDataSource.GetRecordCount: Integer;
begin
  result := 1;
end;

function TParamsDataSource.GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant;
begin
  result := Params[GetDefaultItemID(Integer(AItemHandle))].Value;
end;

procedure TParamsDataSource.SetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle; const AValue: Variant);
begin
  Params[GetDefaultItemID(Integer(AItemHandle))].Value := AValue;
  FModified := true;
end;

constructor TzFormParams.Create(aOwner: TComponent);
begin
  inherited;
  zSystem := nil;
  InternalParams := TParams.Create(Nil);
  ParamsDataSource := TParamsDataSource.Create(InternalParams);
  grid.DataController.CustomDataSource := ParamsDataSource;
end;

destructor TzFormParams.Destroy;
begin
  FreeAndNil(ParamsDataSource);
  FreeAndNil(InternalParams);
  inherited;
end;

function TzFormParams.GetValueTypeClass(DataType: TFieldType): TcxValueTypeClass;
begin
  case DataType of
    ftString, ftMemo, ftFmtMemo, ftFixedChar:
      result := TcxStringValueType;
    ftWideString, ftWideMemo, ftFixedWideChar:
      result := TcxStringValueType;
    ftSmallint:
      result := TcxSmallintValueType;
    ftInteger, ftAutoInc:
      result := TcxIntegerValueType;
    ftWord:
      result := TcxWordValueType;
    ftBoolean:
      result := TcxBooleanValueType;
    TFieldType.ftSingle:
      result := TcxSingleValueType;
    ftCurrency, ftFloat:
      result := TcxFloatValueType;
    { ftCurrency, } ftBCD:
      result := TcxCurrencyValueType;
    ftDate, ftTime, ftDateTime:
      result := TcxDateTimeValueType;
    ftFMTBcd:
      result := TcxFMTBcdValueType;
    ftLargeint:
      result := TcxLargeIntValueType;
    ftTimeStamp:
      result := TcxSQLTimeStampValueType;
  else
    result := TcxVariantValueType;
  end;
end;

function TzFormParams.GetEditPropertiesClass(DataType: TFieldType): TcxCustomEditPropertiesClass;
begin
  case DataType of
    ftString, ftMemo, ftFmtMemo, ftFixedChar:
      result := TcxTextEditProperties;
    ftWideString, ftWideMemo, ftFixedWideChar:
      result := TcxTextEditProperties;
    ftSmallint:
      result := TcxSpinEditProperties;
    ftInteger, ftAutoInc:
      result := TcxSpinEditProperties;
    ftWord:
      result := TcxSpinEditProperties;
    ftBoolean:
      result := TcxCheckBoxProperties;
    TFieldType.ftSingle:
      result := TcxSpinEditProperties;
    ftCurrency:
      result := TcxCurrencyEditProperties;
    ftFloat:
      result := TcxCalcEditProperties;
    ftBCD:
      result := TcxCalcEditProperties;
    ftDate, ftDateTime:
      result := TcxDateEditProperties;
    ftTime:
      result := TcxTimeEditProperties;
    ftFMTBcd:
      result := TcxTextEditProperties;
    ftLargeint:
      result := TcxSpinEditProperties;
    ftTimeStamp:
      result := TcxDateEditProperties;
  else
    result := TcxTextEditProperties;
  end;
end;

procedure TzFormParams.CreateEditors;
var
  i: Integer;
  Param: TParam;
  cxEditorRow: TcxEditorRow;
  viewParams: TcxViewParams;
  bmp: TBitmap;
  W: Integer;
  ParamCaption: string;
begin
  grid.ClearRows;

  bmp := TBitmap.Create;
  try
    for i := 0 to InternalParams.Count - 1 do
    begin
      Param := InternalParams[i];

      cxEditorRow := grid.AddChild(nil, TcxEditorRow) as TcxEditorRow;

      // zz 24.03.2021
      ParamCaption := Param.Name;

      if ParamCaption.StartsWith('PARAM_') then
        ParamCaption := ParamCaption.replace('PARAM_', '');

      ParamCaption := zzCapFirst(ParamCaption, true);
      cxEditorRow.Properties.Caption := ParamCaption;
      //

      cxEditorRow.Properties.DataBinding.ValueTypeClass := GetValueTypeClass(Param.DataType);
      cxEditorRow.Properties.EditPropertiesClass := GetEditPropertiesClass(Param.DataType);

      if cxEditorRow.Properties.EditProperties is TcxSpinEditProperties then
        TcxSpinEditProperties(cxEditorRow.Properties.EditProperties).UseCtrlIncrement := true;

      /// ///

      viewParams := grid.Styles.GetHeaderParams(cxEditorRow);
      bmp.Canvas.Font := viewParams.Font;
      W := bmp.Canvas.TextWidth(cxEditorRow.Properties.Caption);
      Inc(W, grid.ViewInfo.RowIndentWidth + cxTextOffset * 2 + grid.ViewInfo.VertLineWidth * 2);

      if grid.OptionsView.RowHeaderWidth < W then
        grid.OptionsView.RowHeaderWidth := W;
    end;
  finally
    FreeAndNil(bmp);
  end;
end;

function TzFormParams.Edit(proc: TCustomizeParamsProc): boolean;
begin
  result := false;

  if InternalParams.Count = 0 then
  begin // nessun parametro, esce senza mostrare la form
    result := true; // consente l'apertura
    Exit;
  end;

  CreateEditors;

  PopupParent := GetPopupParent(Self);
  ActiveControl := grid;

  if Assigned(proc) then
    proc(Self);

  result := ShowModal = mrOk;

  if result then
    grid.HideEdit;
end;

procedure TzFormParams.FormShow(Sender: TObject);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      if grid.HasRows then
      begin
        grid.FocusedRecordIndex := 0;
        grid.FocusRow(grid.FirstVisibleRow);
        grid.ShowEdit;
      end;
    end, 300);
end;

procedure TzFormParams.LoadParams(Params: TParams; HiddenParams: TStrings);
var
  i: Integer;
begin
  InternalParams.Clear;

  for i := 0 to Params.Count - 1 do
  begin
    if Assigned(HiddenParams) and (HiddenParams.IndexOf(Params[i].Name) <> -1) then
      Continue;

    InternalParams.AddParameter.Assign(Params[i]);
  end;
end;

procedure TzFormParams.LoadParams(Params: TFIBXSQLDA; HiddenParams: TStrings);
var
  i: Integer;
  InternalParam: TParam;
  Param: TFIBXSQLVAR;
begin
  InternalParams.Clear;

  for i := 0 to Params.Count - 1 do
  begin
    if Assigned(HiddenParams) and (HiddenParams.IndexOf(Params[i].Name) <> -1) then
      Continue;

    Param := Params[i];
    InternalParam := InternalParams.AddParameter;
    InternalParam.ParamType := ptInputOutput;
    InternalParam.Name := Param.Name;
    InternalParam.DataType := SQLType2DataType(Param.SQLType);
    InternalParam.Size := Param.Size;
    InternalParam.NumericScale := Param.Scale;
    // InternalParam.Precision := Param.Precision;

    if Param.IsNull then
      InternalParam.Clear
    else
      InternalParam.Value := Param.Value;
  end;
end;

procedure TzFormParams.LoadParams(Params: TFDParams; HiddenParams: TStrings);
var
  i: Integer;
  InternalParam: TParam;
  Param: TFDParam;
begin
  InternalParams.Clear;

  for i := 0 to Params.Count - 1 do
  begin
    if Assigned(HiddenParams) and (HiddenParams.IndexOf(Params[i].Name) <> -1) then
      Continue;

    Param := Params[i];
    InternalParam := InternalParams.AddParameter;
    InternalParam.ParamType := ptInputOutput;
    InternalParam.Name := Param.Name;
    InternalParam.DataType := Param.DataType;
    InternalParam.Size := Param.Size;
    InternalParam.NumericScale := Param.NumericScale;
    InternalParam.Precision := Param.Precision;

    if Param.IsNull then
      InternalParam.Clear
    else
      InternalParam.Value := Param.Value;
  end;
end;

procedure TzFormParams.SaveParams(Params: TParams);
begin
  if Assigned(Params) then
    Params.Assign(InternalParams);
end;

procedure TzFormParams.SaveParams(Params: TFIBXSQLDA);
var
  i: Integer;
  InternalParam: TParam;
  Param: TFIBXSQLVAR;
begin
  if not Assigned(Params) then
    Exit;

  for i := 0 to InternalParams.Count - 1 do
  begin
    InternalParam := InternalParams[i];
    Param := Params.ByName[InternalParam.Name];

    if Assigned(Param) then
      Param.Value := InternalParam.Value;
  end;
end;

procedure TzFormParams.SaveParams(Params: TFDParams);
var
  i: Integer;
  InternalParam: TParam;
  Param: TFDParam;
begin
  if not Assigned(Params) then
    Exit;

  for i := 0 to InternalParams.Count - 1 do
  begin
    InternalParam := InternalParams[i];
    Param := Params.ParamByName(InternalParam.Name);

    if Assigned(Param) then
      Param.Value := InternalParam.Value;
  end;
end;

function TzFormParams.ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zFbDataSet: TzFbDataSet; const Reopen: boolean = false): boolean;
var
  WasForceIsNull: boolean;
  HiddenParams: TStringList;
  i: Integer;
begin
  result := false;

  if not Assigned(zFbDataSet) then
    Exit;

  Self.zSystem := azSystem;

{$IFNDEF ZZZ_FDAC}
  WasForceIsNull := poNoForceIsNull in zFbDataSet.Options;

  if not WasForceIsNull then
  begin
    zFbDataSet.Options := zFbDataSet.Options + [poNoForceIsNull];
    zFbDataSet.UnPrepare;
  end;
  try
{$ENDIF}
    if not zFbDataSet.Prepared then
      zFbDataSet.Prepare;

    HiddenParams := TStringList.Create;
    try
      /// /////////////////////////////////////////////////////////////////////////
      for i := 0 to zFbDataSet.Params.Count - 1 do
      begin
        if zFbDataSet.IsMasterDetailParam(zFbDataSet.Params[i].Name) then
          HiddenParams.Add(zFbDataSet.Params[i].Name);

        if Assigned(zSystem) then
          if zSystem.QueryParams.IndexOf(zFbDataSet.Params[i].Name) <> -1 then
            HiddenParams.Add(zFbDataSet.Params[i].Name);
      end;
      /// /////////////////////////////////////////////////////////////////////////
      LoadParams(zFbDataSet.Params, HiddenParams);
    finally
      FreeAndNil(HiddenParams);
    end;

    result := Edit(proc);

{$IFNDEF ZZZ_FDAC}
  finally
    if not WasForceIsNull then
      zFbDataSet.Options := zFbDataSet.Options - [poNoForceIsNull];
  end;
{$ENDIF}
  //

  if result then
  begin
    SaveParams(zFbDataSet.Params);

    if Reopen then
    begin
      StartWait('Attendere...', true);
      try
        zFbDataSet.Active := false;
        zFbDataSet.Active := true;
      finally
        StopWait;
      end;
    end;
  end;
end;

function TzFormParams.ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zFbSQL: TzFbSQL; const Execute: boolean = false): boolean;
var
  WasForceIsNull: boolean;
begin
  result := false;

  if not Assigned(zFbSQL) then
    Exit;

  Self.zSystem := azSystem;

{$IFNDEF ZZZ_FDAC}
  WasForceIsNull := qoNoForceIsNull in zFbSQL.Options;

  if not WasForceIsNull then
    zFbSQL.Options := zFbSQL.Options + [qoNoForceIsNull];
  try
{$ENDIF}
    if not zFbSQL.Prepared then
      zFbSQL.Prepare;

    LoadParams(zFbSQL.Params, nil);

    result := Edit(proc);
{$IFNDEF ZZZ_FDAC}
  finally
    if not WasForceIsNull then
      zFbSQL.Options := zFbSQL.Options - [qoNoForceIsNull];
  end;
{$ENDIF}
  if result then
  begin
    SaveParams(zFbSQL.Params);

    if Execute then
    begin
      StartWait;
      try
        zFbSQL.ExecQuery;
      finally
        StopWait;
      end;
    end;
  end;
end;

function TzFormParams.ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zFbStoredProc: TzFbStoredProc; const Execute: boolean = false): boolean;
var
  WasForceIsNull: boolean;
begin
  result := false;

  if not Assigned(zFbStoredProc) then
    Exit;

  Self.zSystem := azSystem;
{$IFNDEF ZZZ_FDAC}
  WasForceIsNull := qoNoForceIsNull in zFbStoredProc.Options;

  if not WasForceIsNull then
    zFbStoredProc.Options := zFbStoredProc.Options + [qoNoForceIsNull];
  try
{$ENDIF}
    if not zFbStoredProc.Prepared then
      zFbStoredProc.Prepare;

    LoadParams(zFbStoredProc.Params, nil);

    result := Edit(proc);
{$IFNDEF ZZZ_FDAC}
  finally
    if not WasForceIsNull then
      zFbStoredProc.Options := zFbStoredProc.Options - [qoNoForceIsNull];
  end;
{$ENDIF}
  if result then
  begin
    SaveParams(zFbStoredProc.Params);

    if Execute then
    begin
      StartWait;
      try
        zFbStoredProc.ExecProc;
      finally
        StopWait;
      end;
    end;
  end;
end;

function TzFormParams.ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; zStoredProc: zStoredProc.TzStoredProc): boolean;
begin
  result := false;

  if not Assigned(zStoredProc) then
    Exit;

  Self.zSystem := azSystem;

  zStoredProc.CreateInternalStoredProc;

  result := ShowParams(zSystem, proc, zStoredProc.StoredProc, false);

  if result then
    zStoredProc.ApplyInternalStoredProcParams;
end;

function TzFormParams.ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; Params: TParams): boolean;
begin
  result := false;

  Self.zSystem := azSystem;

  LoadParams(Params, nil);

  result := Edit(proc);

  if result then
    SaveParams(Params);
end;

function TzFormParams.ShowParams(azSystem: TzSystem; proc: TCustomizeParamsProc; Params: TFDParams): boolean;
begin
  result := false;

  Self.zSystem := azSystem;

  LoadParams(Params, nil);

  result := Edit(proc);

  if result then
    SaveParams(Params);
end;

procedure TzFormParams.UpdateHeight;
var
  max: Integer;
  H: Integer;
begin
  // if isDialogFilter then
  // exit;

  max := 100;

  // if PSCListBox.Items.Count = 0 then
  // H := 25
  // else
  // H := ((PSCListBox.ItemHeight * PSCListBox.Items.Count + 1)) + PSCListBox.ItemHeight;
  //
  // // H := H + Label1.Height;
  // H := H + OkCancel.Height + PSCListBox.Top + 7;
  //
  // Max := Trunc(Screen.Height / 2);
  //
  // if H > Max then
  // H := Max;
  //
  // if Self.ClientHeight < H then
  // Self.ClientHeight := H;
end;

end.

zdialog
zFormBuilder
