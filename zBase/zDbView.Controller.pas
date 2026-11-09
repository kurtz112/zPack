unit zDbView.Controller;

interface

uses
  System.SysUtils,
  System.Classes,
  cxGrid,
  cxGridDBTableView,
  dxPScxGridLnk,
  zDbView.Filter,
  zDbView.Footer,
  zDbView.Sort,
  zDbView.Storage,
  zDataController,
  data.DB,
  zSystem,
  dxBar,
  cxFilter,
  SmartInspect.VCL.SiAuto,
  SmartInspect.VCL;

type
  TzDbViewController = class(TObject)
  private
    DisableSorting: Boolean;
    FDataController: TzDataController;
    FView: TcxGridDBTableView;
    FSortController: TzDbViewSortController;
    FFooterController: TzDbViewFooterController;
    FFilterController: TzDbViewFilterController;
    FFlags: TzDbViewFlags;
    FStorage: TzDbViewStorage;
    function GetActiveColumn: TcxGridDBColumn;
    function GetActiveField: TField;
    function GetActiveFieldName: string;
    procedure SetActiveColumn(const Value: TcxGridDBColumn);
    procedure SetActiveField(const Value: TField);
    procedure SetActiveFieldName(const Value: string);
  private
    CalculatingFooterValues: Boolean;
    FCustomLoadCallback: TProc;
    FCustomSaveCallback: TProc;
    onPropsChanged: TNotifyEvent;
    procedure PropsChanged;
    procedure FlagsChanged(Sender: TObject);
  public
    constructor Create(aDataController: TzDataController; aView: TcxGridDBTableView; aPropsChanged: TNotifyEvent);
    destructor Destroy; override;
    procedure InitControllers;
  public
    property ActiveColumn: TcxGridDBColumn read GetActiveColumn write SetActiveColumn;
    property ActiveField: TField read GetActiveField write SetActiveField;
    property ActiveFieldName: string read GetActiveFieldName write SetActiveFieldName;
  public
    procedure LoadDefaultProps;

    function EditProps: Boolean;

    procedure LoadFromIni;
    procedure SaveToIni;
    // solo il layout personale (INI dell'utente), mai il dizionario LZ
    procedure SaveLayoutToIni;

    procedure SaveToLZ(const Silent: Boolean);
  private
    procedure Save(const Silent: Boolean; const SaveToLZ: Boolean);
    procedure SetCustomLoadCallback(const Value: TProc);
    procedure SetCustomSaveCallback(const Value: TProc);
  public
    procedure Sort;
    //
    procedure ApplyFilter;
    //
    procedure FilterByValue;
    procedure FilterByFindText;

    procedure AddFilterCondition(FieldName: string; OperatorKind: TcxFilterOperatorKind; Value: Variant; Checked: Boolean = true; Overwrite: Boolean = true);
    function FilterCount: Integer;

    procedure ClearFilters;
    procedure DeleteConditionsForField(FieldName: string);

    procedure BeginUpdateFilter;
    procedure EndUpdateFilter;
    procedure PrepareFilterMenuForField(FieldName: string; SubMenu: TdxBarSubItem);

    procedure OpenFilterDialog;

    procedure ExportToExcel(const FileName: string);

    procedure CalculateFooterValues;
    // procedure SetAdditionalFilter(const AdditionalFilter: string);
  public
    // inizializzati tramite la props. Non deve valere l'inversa,
    // le props vanno modificate solo con l'editor di base.

    property Flags: TzDbViewFlags read FFlags;
    property Storage: TzDbViewStorage read FStorage;

    property DataController: TzDataController read FDataController;
    property FilterController: TzDbViewFilterController read FFilterController;
    property FooterController: TzDbViewFooterController read FFooterController;
    property SortController: TzDbViewSortController read FSortController;
    property View: TcxGridDBTableView read FView;
  public
    property CustomSaveCallback: TProc read FCustomSaveCallback write SetCustomSaveCallback;
    property CustomLoadCallback: TProc read FCustomLoadCallback write SetCustomLoadCallback;
  end;

implementation

uses
  StrUtils,
  Controls,
  Forms,
  cxGridExportLink,
  cxExport,
  cxCustomData,
  System.Variants;

{ TzDbViewController }

constructor TzDbViewController.Create(aDataController: TzDataController; aView: TcxGridDBTableView; aPropsChanged: TNotifyEvent);
begin
  SiMain.EnterMethod(Self, 'Create');

  inherited Create;
  Assert(Assigned(aDataController));
  Assert(Assigned(aView));

  CalculatingFooterValues := False;
  onPropsChanged := aPropsChanged;

  FDataController := aDataController;
  FView := aView;

  FCustomSaveCallback := nil;
  FCustomLoadCallback := nil;

  FFlags := TzDbViewFlags.Create;
  Flags.OnChange := FlagsChanged;
  FStorage := TzDbViewStorage.Create(DataController, View);
  FSortController := TzDbViewSortController.Create(DataController, View);
  FFilterController := TzDbViewFilterController.Create(DataController, View);
  FFooterController := TzDbViewFooterController.Create(DataController, View);

  SiMain.LeaveMethod(Self, 'Create');
end;

procedure TzDbViewController.DeleteConditionsForField(FieldName: string);
begin
  SiMain.EnterMethod(Self, 'DeleteConditionsForField');

  FilterController.DeleteConditionsForField(FieldName);

  SiMain.LeaveMethod(Self, 'DeleteConditionsForField');
end;

destructor TzDbViewController.Destroy;
begin
  SiMain.EnterMethod('TzDbViewController.Destroy');

  FreeAndNil(FFlags);
  FreeAndNil(FStorage);
  FreeAndNil(FSortController);
  FreeAndNil(FFilterController);
  FreeAndNil(FFooterController);

  inherited;

  SiMain.LeaveMethod('TzDbViewController.Destroy');
end;

procedure TzDbViewController.AddFilterCondition(FieldName: string; OperatorKind: TcxFilterOperatorKind; Value: Variant; Checked: Boolean = true; Overwrite: Boolean = true);
begin
  SiMain.EnterMethod(Self, 'AddFilterCondition');

  FilterController.AddFilterCondition(FieldName, OperatorKind, Value, Checked, Overwrite);

  SiMain.LeaveMethod(Self, 'AddFilterCondition');
end;

procedure TzDbViewController.InitControllers;
begin
  SiMain.EnterMethod(Self, 'InitControllers');

  SortController.InitColumns;
  FilterController.InitFilters;

  SiMain.LeaveMethod(Self, 'InitControllers');
end;

procedure TzDbViewController.Sort;
begin
  SiMain.EnterMethod(Self, 'Sort');

  SortController.Sort;

  SiMain.LeaveMethod(Self, 'Sort');
end;

procedure TzDbViewController.FilterByValue;
begin
  SiMain.EnterMethod(Self, 'FilterByValue');

  FilterController.FilterByValue;

  SiMain.LeaveMethod(Self, 'FilterByValue');
end;

function TzDbViewController.FilterCount: Integer;
begin
  SiMain.EnterMethod(Self, 'FilterCount');

  result := FilterController.FilterCount;

  SiMain.LeaveMethod(Self, 'FilterCount');
end;

procedure TzDbViewController.FlagsChanged(Sender: TObject);
begin
  SiMain.EnterMethod(Self, 'FlagsChanged');

  PropsChanged;

  SiMain.LeaveMethod(Self, 'FlagsChanged');
end;

procedure TzDbViewController.ApplyFilter;
begin
  SiMain.EnterMethod(Self, 'ApplyFilter');

  FilterController.ApplyFilter;

  SiMain.LeaveMethod(Self, 'ApplyFilter');
end;

procedure TzDbViewController.BeginUpdateFilter;
begin
  SiMain.EnterMethod(Self, 'BeginUpdateFilter');

  FilterController.BeginUpdate;

  SiMain.LeaveMethod(Self, 'BeginUpdateFilter');
end;

procedure TzDbViewController.CalculateFooterValues;
var
  i: Integer;
  Column: TcxGridDBColumn;
  zColumn: TzColumn;
  NumericField: TNumericField;
begin
  SiMain.EnterMethod(Self, 'CalculateFooterValues');

  if not DataController.DataSetOk then
    Exit;

  if not DataController.IsActive then
    Exit;

  // ZZ 24.06.2025: possibilita' di definire totali a runtime da parte degli utenti
  // if not Flags.Footer then
  // Exit;

  if CalculatingFooterValues then
    Exit;

  CalculatingFooterValues := true;
  try
    Storage.zDbViewProps.Columns.AssignFromGridColumns(DataController.idDataSet, View, Storage.ViewID);
    if not Storage.zDbViewProps.Columns.HasFooter then
      Exit;

    if not DataController.IsActive then
    begin

      for i := 0 to View.DataController.Summary.FooterSummaryItems.Count - 1 do
        View.DataController.Summary.FooterSummaryValues[i] := Null;
      Exit;
    end;

    FooterController.CalculateFooterValues(Storage.zDbViewProps.Columns);

    for i := 0 to View.DataController.Summary.FooterSummaryItems.Count - 1 do
    begin
      Column := TcxGridDBColumn(View.DataController.Summary.FooterSummaryItems[i].ItemLink);

      if Assigned(Column) then
      begin
        if Assigned(Column.DataBinding.Field) then
          if Column.DataBinding.Field is TNumericField then
          begin
            NumericField := Column.DataBinding.Field as TNumericField;
            if not NumericField.DisplayFormat.isEmpty then
              if Column.Summary.FooterFormat <> NumericField.DisplayFormat then
                Column.Summary.FooterFormat := NumericField.DisplayFormat;
          end;

        zColumn := Storage.zDbViewProps.Columns.Get(Column.DataBinding.FieldName);
        View.DataController.Summary.FooterSummaryValues[i] := zColumn.FooterValue;
      end
      else
        View.DataController.Summary.FooterSummaryValues[i] := Null;
    end;
  finally
    CalculatingFooterValues := False;
  end;

  SiMain.LeaveMethod(Self, 'CalculateFooterValues');
end;

procedure TzDbViewController.ClearFilters;
begin
  SiMain.EnterMethod(Self, 'ClearFilters');

  FilterController.Clear;

  SiMain.LeaveMethod(Self, 'ClearFilters');
end;

procedure TzDbViewController.EndUpdateFilter;
begin
  SiMain.EnterMethod(Self, 'EndUpdateFilter');

  FilterController.EndUpdate;

  SiMain.LeaveMethod(Self, 'EndUpdateFilter');
end;

procedure TzDbViewController.FilterByFindText;
begin
  SiMain.EnterMethod(Self, 'FilterByFindText');

  FilterController.FilterByFindText;

  SiMain.LeaveMethod(Self, 'FilterByFindText');
end;

procedure TzDbViewController.OpenFilterDialog;
begin

  if DataController.CloseQuery then
    FilterController.OpenFilterDialog;
end;

function TzDbViewController.GetActiveColumn: TcxGridDBColumn;
begin
  SiMain.EnterMethod(Self, 'GetActiveColumn');

  result := TcxGridDBColumn(View.Controller.FocusedColumn);

  SiMain.LeaveMethod(Self, 'GetActiveColumn');
end;

function TzDbViewController.GetActiveField: TField;
var
  Column: TcxGridDBColumn;
begin
  SiMain.EnterMethod(Self, 'GetActiveField');

  result := nil;

  Column := ActiveColumn;

  if Assigned(Column) then
    result := Column.DataBinding.Field;

  SiMain.LeaveMethod(Self, 'GetActiveField');
end;

function TzDbViewController.GetActiveFieldName: string;
var
  Field: TField;
begin
  SiMain.EnterMethod(Self, 'GetActiveFieldName');

  result := '';

  Field := ActiveField;
  if Assigned(Field) then
    result := Field.FieldName;

  SiMain.LeaveMethod(Self, 'GetActiveFieldName');
end;

procedure TzDbViewController.SetActiveColumn(const Value: TcxGridDBColumn);
begin
  SiMain.EnterMethod(Self, 'SetActiveColumn');

  if Assigned(Value) then
  begin
    Value.Focused := true;
    Value.MakeVisible;
  end;

  SiMain.LeaveMethod(Self, 'SetActiveColumn');
end;

procedure TzDbViewController.SetActiveField(const Value: TField);
var
  i: Integer;
begin
  SiMain.EnterMethod(Self, 'SetActiveField');

  if Assigned(Value) then
    for i := 0 to View.ColumnCount - 1 do
      if View.Columns[i].DataBinding.Field = Value then
      begin
        ActiveColumn := View.Columns[i];
        Break;
      end;

  SiMain.LeaveMethod(Self, 'SetActiveField');
end;

procedure TzDbViewController.SetActiveFieldName(const Value: string);
var
  i: Integer;
begin
  SiMain.EnterMethod(Self, 'SetActiveFieldName');

  // provare
  // ActiveColumn := View.GetColumnByFieldName(FieldName);

  for i := 0 to View.ColumnCount - 1 do
    if View.Columns[i].DataBinding.FieldName = Value then
    begin
      ActiveColumn := View.Columns[i];
      Break;
    end;

  SiMain.LeaveMethod(Self, 'SetActiveFieldName');
end;

procedure TzDbViewController.ExportToExcel(const FileName: string);
begin
  SiMain.EnterMethod(Self, 'ExportToExcel');

  ExportGridToExcel(FileName, View.Control as TcxGrid);

  SiMain.LeaveMethod(Self, 'ExportToExcel');
end;

procedure TzDbViewController.PrepareFilterMenuForField(FieldName: string; SubMenu: TdxBarSubItem);
begin
  FilterController.PrepareFilterMenuForField(FieldName, SubMenu);
end;

procedure TzDbViewController.PropsChanged;
begin
  SiMain.EnterMethod(Self, 'PropsChanged');

  SortController.SortingEnabled := Flags.Sort;

  if Assigned(onPropsChanged) then
    onPropsChanged(Self);

  SiMain.LeaveMethod(Self, 'PropsChanged');
end;

procedure TzDbViewController.SaveToIni;
begin
  SiMain.EnterMethod(Self, 'SaveToIni');

  Storage.SaveToIni;

  if Base.IsAdmin then
    Save(False, true);

  SiMain.LeaveMethod(Self, 'SaveToIni');
end;

procedure TzDbViewController.SaveLayoutToIni;
begin
  SiMain.EnterMethod(Self, 'SaveLayoutToIni');

  Storage.SaveToIni;

  SiMain.LeaveMethod(Self, 'SaveLayoutToIni');
end;

procedure TzDbViewController.SaveToLZ(const Silent: Boolean);
begin
  SiMain.EnterMethod(Self, 'SaveToLZ');

  Save(Silent, true);
  Storage.SaveToIni;

  SiMain.LeaveMethod(Self, 'SaveToLZ');
end;

procedure TzDbViewController.Save(const Silent: Boolean; const SaveToLZ: Boolean);
begin
  SiMain.EnterMethod(Self, 'Save');

  Storage.Save(Flags, Silent, SaveToLZ);

  SiMain.LeaveMethod(Self, 'Save');
end;

procedure TzDbViewController.LoadDefaultProps;
begin
  SiMain.EnterMethod(Self, 'LoadDefaultProps');

  Storage.Load(Flags);

  SiMain.LeaveMethod(Self, 'LoadDefaultProps');
end;

procedure TzDbViewController.LoadFromIni;
begin
  Storage.LoadFromIni;
end;

function TzDbViewController.EditProps: Boolean;
begin
  result := Storage.EditProps(Flags);

  if result then
    PropsChanged;
end;

procedure TzDbViewController.SetCustomLoadCallback(const Value: TProc);
begin
  FCustomLoadCallback := Value;
  Storage.CustomLoadCallback := CustomLoadCallback;
end;

procedure TzDbViewController.SetCustomSaveCallback(const Value: TProc);
begin
  FCustomSaveCallback := Value;
  Storage.CustomSaveCallback := CustomSaveCallback;
end;

end.
