unit zFrmParams;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  System.Actions,
  System.Generics.Collections,
  Data.DB,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.ActnList,
  vcl.StdCtrls,
  vcl.ExtCtrls,
  vcl.ImgList,
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
  dxScrollbarAnnotations,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  zFbDataSet,
  zStoredProc,
  zBaseLib,
  OkCancel,
  zSystem,
  zDialog;

type
  TzParamDialog = class;

  TBeforeShowParamsProc = reference to procedure(zParamDialog: TzParamDialog);

  /// /////////////////////////////////////////////////////////////////////////

  TzParamDialog = class(TComponent)
  private
    FzDialog: TzDialog;
    InternalParams: TParams;
  private
    function ParamCaption(Param: TParam): string;
    function CreateEditor(Param: TParam): TcxCustomEdit;
    procedure CreateEditors;

    procedure SaveParamValues;

    function Execute(const LayoutID: string; const Caption: string; BeforeShowParamsProc: TBeforeShowParamsProc): boolean;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function GetEditor(const paramName: string): TcxCustomEdit;
    function ChangeEditorType(const paramName: string; zCtrlType: TzCtrlType): TcxCustomEdit;
    procedure Enum(proc: TProc<TParam, TcxCustomEdit>);

    property zDialog: TzDialog read FzDialog;
  public
    function ShowParams(const LayoutID: string; zFbDataSet: TzFbDataSet; const Caption: string = ''; const doReopen: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
      const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

    function ShowParams(const LayoutID: string; FDQuery: TFDQuery; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
      const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

    function ShowParams(const LayoutID: string; StoredProc: TFDStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
      const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

    function ShowParams(const LayoutID: string; zStoredProc: zStoredProc.TzStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
      const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

    function ShowParams(const LayoutID: string; Params: TParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
      const HideParams: string = ''): boolean; overload;

    function ShowParams(const LayoutID: string; Params: TFDParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
      const HideParams: string = ''): boolean; overload;
  end;

function ShowParams(const LayoutID: string; zFbDataSet: TzFbDataSet; const Caption: string = ''; const doReopen: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

function ShowParams(const LayoutID: string; FDQuery: TFDQuery; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

function ShowParams(const LayoutID: string; StoredProc: TFDStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

function ShowParams(const LayoutID: string; zStoredProc: zStoredProc.TzStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean; overload;

function ShowParams(const LayoutID: string; Params: TParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
  const HideParams: string = ''): boolean; overload;

function ShowParams(const LayoutID: string; Params: TFDParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
  const HideParams: string = ''): boolean; overload;

implementation

uses
  cxTextEdit,
  cxSpinEdit,
  cxCheckBox,
  cxTimeEdit,
  cxCurrencyEdit,
  cxCalc,
  cxCalendar,
  zParamsHelper,
  zdx,
  dxLayoutContainer,
  System.Character;
{$R *.dfm}
{ TzParamDialog }

constructor TzParamDialog.Create(aOwner: TComponent);
begin
  inherited;
  InternalParams := TParams.Create(Self);
  FzDialog := TzDialog.Create(Self);
end;

destructor TzParamDialog.Destroy;
begin
  FreeAndNil(FzDialog);
  FreeAndNil(InternalParams);
  inherited;
end;

function TzParamDialog.GetEditor(const paramName: string): TcxCustomEdit;
begin
  result := zDialog.zFormBuilder.GetControl(paramName);
end;

function TzParamDialog.ChangeEditorType(const paramName: string; zCtrlType: TzCtrlType): TcxCustomEdit;
var
  Param: TParam;
begin
  result := nil;

  Param := InternalParams.ParamByName(paramName);

  if not Assigned(Param) then
    Exit;

  result := zDialog.zFormBuilder.ChangeControlType(zCtrlType, Param.Name, ParamCaption(Param), Param.Value);
end;

procedure TzParamDialog.Enum(proc: TProc<TParam, TcxCustomEdit>);
var
  i: Integer;
  Param: TParam;
begin

  for i := 0 to InternalParams.Count - 1 do
  begin
    Param := InternalParams[i];
    proc(Param, GetEditor(Param.Name));
  end;
end;

function TzParamDialog.ParamCaption(Param: TParam): string;

  function InserisciSpazioTraMaiuscole(const s: string): string;
  var
    i: Integer;
    tmp: string;
    c1, c2: char;
  begin
    tmp := '';

    if s = s.ToUpper then
      Exit(s);

    for i := 1 to s.length do
    begin
      tmp := tmp + s[i];
      if (i < length(s)) then
      begin
        c1 := tmp[i];
        c2 := s[i + 1];

        if c1.isUpper and c2.isUpper then
          tmp := tmp + ' ';
      end;
    end;

    result := tmp;
  end;

begin
  result := Param.Name;

  if result.StartsWith('PARAM_') then
    result := result.replace('PARAM_', '');

  result := zzCapFirst(result, true);
  result := InserisciSpazioTraMaiuscole(result);
end;

function TzParamDialog.CreateEditor(Param: TParam): TcxCustomEdit;
  function GetCtrlType(DataType: TFieldType; Domain: string): TzCtrlType;
  begin
    result := ctDefault;

    case DataType of
      ftUnknown:
        Exit;
      ftString, ftFixedChar, ftWideString:
        result := ctEdit;
      ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
        result := ctSpin;
      ftBoolean:
        result := ctCheckBox;
      ftFloat, ftCurrency, ftBCD:
        result := ctSpin;
      ftDate:
        result := ctDate;
      ftTime:
        result := ctTime;
      ftDateTime, ftTimeStamp:
        result := ctDateTime;
      ftMemo, ftFmtMemo:
        result := ctMemo;
      ftGraphic:
        result := ctImage;
      // ftBytes, ftVarBytes, ftBlob,  ftParadoxOle, ftDBaseOle, ftTypedBinary,
      // ftCursor, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob,
      // ftVariant, ftInterface, ftIDispatch, ftGuid, ftFMTBcd);
    end;
  end;

var
  Caption: string;
begin
  result := nil;
  Caption := ParamCaption(Param);
  result := zDialog.zFormBuilder.AddControl(GetCtrlType(Param.DataType, ''), Param.Name, Caption, Param.Value);

  result.ActiveProperties.ReadOnly := Param.ParamType = Data.DB.TParamType.ptOutput;

  // Nullstring
  if result.ActiveProperties is TcxSpinEditProperties then
  begin
    TcxSpinEditProperties(result.ActiveProperties).UseNullString := true;

    if Param.DataType in [ftSingle, ftFloat, ftExtended, ftCurrency, ftBCD, ftFMTBCD] then
      TcxSpinEditProperties(result.ActiveProperties).ValueType := vtFloat;
  end
end;

procedure TzParamDialog.CreateEditors;
var
  i: Integer;
  Param: TParam;
begin
  zDialog.zFormBuilder.Clear;

  for i := 0 to InternalParams.Count - 1 do
  begin
    Param := InternalParams[i];
    CreateEditor(Param);
  end;
end;

procedure TzParamDialog.SaveParamValues;
var
  i: Integer;
  Param: TParam;
  cxCustomEdit: TcxCustomEdit;
begin
  for i := 0 to InternalParams.Count - 1 do
  begin
    Param := InternalParams[i];
    cxCustomEdit := GetEditor(Param.Name);

    if Assigned(cxCustomEdit) then
      Param.Value := dx.GetValue(cxCustomEdit);
  end;
end;

/// //////////////////////////////

function TzParamDialog.Execute(const LayoutID: string; const Caption: string; BeforeShowParamsProc: TBeforeShowParamsProc): boolean;
begin
  result := false;

  if InternalParams.Count = 0 then
  begin // nessun parametro, esce senza mostrare la form
    result := true; // consente l'apertura
    Exit;
  end;

  CreateEditors;

  if Assigned(BeforeShowParamsProc) then
    BeforeShowParamsProc(Self);

  result := zDialog.Execute(LayoutID, Caption, nil); // vedere LayoutId

  if result then
    SaveParamValues;
end;

/// //////////////////////////////

function TzParamDialog.ShowParams(const LayoutID: string; zFbDataSet: TzFbDataSet; const Caption: string = ''; const doReopen: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  WasForceIsNull: boolean;
  HiddenParams: TStringList;
  i: Integer;
begin
  result := false;

  if not Assigned(zFbDataSet) then
    Exit;

  if not zFbDataSet.Prepared then
    zFbDataSet.Prepare;

  HiddenParams := TStringList.Create;
  try
    HiddenParams.Delimiter := ';';
    HiddenParams.DelimitedText := HideParams.replace(',', ';');

    /// /////////////////////////////////////////////////////////////////////////
    for i := 0 to zFbDataSet.Params.Count - 1 do
    begin
      if zFbDataSet.IsMasterDetailParam(zFbDataSet.Params[i].Name) then
        HiddenParams.Add(zFbDataSet.Params[i].Name);

      if Assigned(Base) then
        if Base.QueryParams.IndexOf(zFbDataSet.Params[i].Name) <> -1 then
          HiddenParams.Add(zFbDataSet.Params[i].Name);
    end;
    /// /////////////////////////////////////////////////////////////////////////
    InternalParams.LoadParams(zFbDataSet.Params, HiddenParams, IncludeOutputParams);
  finally
    FreeAndNil(HiddenParams);
  end;

  result := Execute(LayoutID, Caption, BeforeShowParamsProc);

  //

  if result then
  begin
    InternalParams.SaveParams(zFbDataSet.Params);

    if doReopen then
    begin
      StartWait('Attendere...', true);
      try
        zFbDataSet.Reopen;
      finally
        StopWait;
      end;
    end;
  end;
end;

function TzParamDialog.ShowParams(const LayoutID: string; FDQuery: TFDQuery; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  WasForceIsNull: boolean;
begin
  result := false;

  if not Assigned(FDQuery) then
    Exit;

  if not FDQuery.Prepared then
    FDQuery.Prepare;

  InternalParams.LoadParams(FDQuery.Params, HideParams, IncludeOutputParams);

  result := Execute(LayoutID, Caption, BeforeShowParamsProc);

  if result then
  begin
    InternalParams.SaveParams(FDQuery.Params);

    if doExecute then
    begin
      StartWait;
      try
        FDQuery.ExecSQL;
      finally
        StopWait;
      end;
    end;
  end;
end;

function TzParamDialog.ShowParams(const LayoutID: string; StoredProc: TFDStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  WasForceIsNull: boolean;
begin
  result := false;

  if not Assigned(StoredProc) then
    Exit;

  if not StoredProc.Prepared then
    StoredProc.Prepare;

  InternalParams.LoadParams(StoredProc.Params, HideParams, IncludeOutputParams);

  result := Execute(LayoutID, Caption, BeforeShowParamsProc);

  if result then
  begin
    InternalParams.SaveParams(StoredProc.Params);

    if doExecute then
    begin
      StartWait;
      try
        StoredProc.ExecProc;
      finally
        StopWait;
      end;
    end;
  end;
end;

function TzParamDialog.ShowParams(const LayoutID: string; zStoredProc: zStoredProc.TzStoredProc; const Caption: string = ''; const doExecute: boolean = false;
  BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
begin
  result := false;

  if not Assigned(zStoredProc) then
    Exit;

  zStoredProc.CreateInternalStoredProc;

  result := ShowParams(LayoutID, zStoredProc.StoredProc, Caption, doExecute, BeforeShowParamsProc, IncludeOutputParams, HideParams);

  if result then
    zStoredProc.ApplyInternalStoredProcParams;
end;

function TzParamDialog.ShowParams(const LayoutID: string; Params: TParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
  const HideParams: string = ''): boolean;
begin
  result := false;

  InternalParams.LoadParams(Params, HideParams, IncludeOutputParams);

  result := Execute(LayoutID, Caption, BeforeShowParamsProc);

  if result then
    InternalParams.SaveParams(Params);
end;

function TzParamDialog.ShowParams(const LayoutID: string; Params: TFDParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
  const HideParams: string = ''): boolean;
begin
  result := false;

  InternalParams.LoadParams(Params, HideParams, IncludeOutputParams);

  result := Execute(LayoutID, Caption, BeforeShowParamsProc);

  if result then
    InternalParams.SaveParams(Params);
end;

/// //////////////////////////////

function ShowParams(const LayoutID: string; zFbDataSet: TzFbDataSet; const Caption: string = ''; const doReopen: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  zParamDialog: TzParamDialog;
begin
  Application.CreateForm(TzParamDialog, zParamDialog);
  try
    result := zParamDialog.ShowParams(LayoutID, zFbDataSet, Caption, doReopen, BeforeShowParamsProc, IncludeOutputParams, HideParams);
  finally
    FreeAndNil(zParamDialog);
  end;
end;

function ShowParams(const LayoutID: string; FDQuery: TFDQuery; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  zParamDialog: TzParamDialog;
begin
  Application.CreateForm(TzParamDialog, zParamDialog);
  try
    result := zParamDialog.ShowParams(LayoutID, FDQuery, Caption, doExecute, BeforeShowParamsProc, IncludeOutputParams, HideParams);
  finally
    FreeAndNil(zParamDialog);
  end;
end;

function ShowParams(const LayoutID: string; StoredProc: TFDStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  zParamDialog: TzParamDialog;
begin
  Application.CreateForm(TzParamDialog, zParamDialog);
  try
    result := zParamDialog.ShowParams(LayoutID, StoredProc, Caption, doExecute, BeforeShowParamsProc, IncludeOutputParams, HideParams);
  finally
    FreeAndNil(zParamDialog);
  end;
end;

function ShowParams(const LayoutID: string; zStoredProc: zStoredProc.TzStoredProc; const Caption: string = ''; const doExecute: boolean = false; BeforeShowParamsProc: TBeforeShowParamsProc = nil;
  const IncludeOutputParams: boolean = false; const HideParams: string = ''): boolean;
var
  zParamDialog: TzParamDialog;
begin
  Application.CreateForm(TzParamDialog, zParamDialog);
  try
    result := zParamDialog.ShowParams(LayoutID, zStoredProc, Caption, doExecute, BeforeShowParamsProc, IncludeOutputParams, HideParams);
  finally
    FreeAndNil(zParamDialog);
  end;
end;

function ShowParams(const LayoutID: string; Params: TParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
  const HideParams: string = ''): boolean; overload;
var
  zParamDialog: TzParamDialog;
begin
  Application.CreateForm(TzParamDialog, zParamDialog);
  try
    result := zParamDialog.ShowParams(LayoutID, Params, Caption, BeforeShowParamsProc, IncludeOutputParams, HideParams);
  finally
    FreeAndNil(zParamDialog);
  end;
end;

function ShowParams(const LayoutID: string; Params: TFDParams; const Caption: string = ''; BeforeShowParamsProc: TBeforeShowParamsProc = nil; const IncludeOutputParams: boolean = false;
  const HideParams: string = ''): boolean; overload;
var
  zParamDialog: TzParamDialog;
begin
  Application.CreateForm(TzParamDialog, zParamDialog);
  try
    result := zParamDialog.ShowParams(LayoutID, Params, Caption, BeforeShowParamsProc, IncludeOutputParams, HideParams);
  finally
    FreeAndNil(zParamDialog);
  end;
end;

end.

  zDialog zFormBuilder zSystem

  zFbDataSet
