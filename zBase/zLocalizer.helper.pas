unit zLocalizer.helper;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Actions,
  Vcl.ActnList,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  zdbView,
  zdbCard,
  zDbPivot,
  zDbRecordView,
  zDbTree,
  zDbChart,
  zDbScheduler,
  zFileViewer,
  // zGoogleMaps,
  zTreeMenu,
  zFormController,
  OkCancel,
  zDx,
  cxPC,
  dxLayoutControl,
  cxLabel,
  zLocalizer.Types,
  dxBar,
  dxRibbon,
  cxFilterControlUtils;

Type
  TActionHelper = class helper for TContainedAction
  public
    procedure RegisterResources(const NameSpace: string; ResourceKind: TResourceKind);
    procedure Translate(const NameSpace: string);
  end;

  TActionListHelper = class helper for TActionList
  public
    procedure RegisterResources(const NameSpace: string; ResourceKind: TResourceKind);
    procedure Translate(const NameSpace: string);
  end;

  TcxPageControlHelper = class helper for TcxPageControl
  public
    procedure RegisterResources(const NameSpace: string);
    procedure Translate(const NameSpace: string);
  end;

  TcxLabelHelper = class helper for TcxLabel
  public
    procedure RegisterResources(const NameSpace: string);
    procedure Translate(const NameSpace: string);
  end;

  TdxBarHelper = class helper for TdxBar
  public
    procedure RegisterResources(const NameSpace: string);
    procedure Translate(const NameSpace: string);
  end;

  TdxRibbonTabHelper = class helper for TdxRibbonTab
  public
    procedure RegisterResources(const NameSpace: string);
    procedure Translate(const NameSpace: string);
  end;

  TOkCancelHelper = class helper for TOkCancel
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources(const NameSpace: string);
    procedure Translate(const NameSpace: string);
  end;

  TcxFilterControlOperatorHelper = record helper for TcxFilterControlOperator
  private
    class function NameSpace: string; static;
  public
    class procedure EnumResourceStrings; static;
    function GetTranslation: string;
    function ToString: string;
  end;

  TzDbViewHelper = class helper for TzDbView
  strict private
    function ViewNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  TzdbCardHelper = class helper for TzdbCard
  strict private
    function CardNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  TzDbPivotHelper = class helper for TzDbPivot
  strict private
    function PivotNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  // R-017: vista del record, albero, grafico e calendario, come TzDbPivotHelper.
  // Le azioni stanno nello spazio dei nomi della classe (una traduzione vale
  // per tutte le istanze), titolo e didascalie in quello del componente
  TzDbRecordViewHelper = class helper for TzDbRecordView
  strict private
    function RecordViewNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  TzDbTreeHelper = class helper for TzDbTree
  strict private
    function TreeNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  TzDbChartHelper = class helper for TzDbChart
  strict private
    function ChartNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  // Il calendario non ha titolo ne' didascalie proprie: solo le due liste di
  // azioni. Quelle create dal dizionario (CreateLzActions) nascono quando
  // arrivano zSystem e il dataset, quindi la classe vuota non le conosce: le
  // registra l'istanza
  TzDbSchedulerHelper = class helper for TzDbScheduler
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  TzFileViewerHelper = class helper for TzFileViewer
  strict private
    function ViewerNameSpace: string;
  public
    class procedure EnumResourceStrings;
    procedure RegisterResources;
    procedure Translate;
  end;

  // TzGoogleMapsHelper = class helper for TzGoogleMaps
  // public
  // class procedure EnumResourceStrings; //
  // procedure RegisterResources(const NameSpace: string);
  // procedure Translate(const NameSpace: string);
  // end;

  TzFormControllerHelper = class helper for TzFormController
  strict private
    function DataModuleNameSpace: string;
  public
    procedure RegisterResources(const NameSpace: string);
    procedure Translate(const NameSpace: string);
  end;

  TdxLayoutControlHelper = class helper for TdxLayoutControl
  public
    procedure RegisterResources(const NameSpace: string); // Implementare
    procedure Translate(const NameSpace: string); // Implementare
  end;


  // TzTreeMenuHelper = class helper for TzTreeMenu
  // public
  // class procedure EnumResourceStrings;
  // procedure RegisterResources(const NameSpace: string);
  // procedure Translate(const NameSpace: string);
  // end;

implementation

uses
  cxGridDBTableView,
  cxVGrid,
  cxDBVGrid,
  cxTL,
  cxDBTL,
  zLocalizer,
  zLocalizer.Utils,
  cxCustomPivotGrid,
  zSystem,
  System.Rtti;

/// ////////////////////////////////////////////////////////////////////////////

{ TActionHelper }

procedure TActionHelper.RegisterResources(const NameSpace: string; ResourceKind: TResourceKind);
begin
  Localizer.Resources.AddResource(NameSpace, ClassName, Name, 'Caption', Caption, ResourceKind);
  Localizer.Resources.AddResource(NameSpace, ClassName, Name, 'Hint', Hint, ResourceKind);
end;

procedure TActionHelper.Translate(const NameSpace: string);
begin
  Caption := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, Name, 'Caption'), Caption);
  Hint := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, Name, 'Hint'), Hint);
end;

/// ////////////////////////////////////////////////////////////////////////////
{ TActionListHelper }

procedure TActionListHelper.RegisterResources(const NameSpace: string; ResourceKind: TResourceKind);
var
  Action: TContainedAction;
begin
  for Action in Self do
    Action.RegisterResources(NameSpace, ResourceKind);
end;

procedure TActionListHelper.Translate(const NameSpace: string);
var
  Action: TContainedAction;
begin
  for Action in Self do
    Action.Translate(NameSpace);
end;

/// ////////////////////////////////////////////////////////////////////////////
{ TcxPageControlHelper }

procedure TcxPageControlHelper.RegisterResources(const NameSpace: string);
var
  i: integer;
  tab: TcxTabSheet;
begin

  for i := 0 to PageCount - 1 do
  begin
    tab := Pages[i];
    Localizer.Resources.AddResource(NameSpace, ClassName, tab.Name, 'Caption', tab.Caption, rkProp);
    Localizer.Resources.AddResource(NameSpace, ClassName, tab.Name, 'Hint', tab.Hint, rkProp);
  end;
end;

procedure TcxPageControlHelper.Translate(const NameSpace: string);
var
  i: integer;
  tab: TcxTabSheet;
begin

  for i := 0 to PageCount - 1 do
  begin
    tab := Pages[i];
    tab.Caption := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, tab.Name, 'Caption'), tab.Caption);
    tab.Hint := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, tab.Name, 'Hint'), tab.Hint);
  end;
end;
/// ////////////////////////////////////////////////////////////////////////////

{ TdxLayoutControlHelper }

procedure TdxLayoutControlHelper.RegisterResources(const NameSpace: string);
begin
  { TODO : Implementare }
end;

procedure TdxLayoutControlHelper.Translate(const NameSpace: string);
begin
  { TODO : Implementare }
end;

function TzdbCardHelper.CardNameSpace: string;
begin
  result := ClassNameSpace(ClassType, CardID);
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzdbCardHelper }

class procedure TzdbCardHelper.EnumResourceStrings;
var
  Card: TzdbCard;
begin
  Card := TzdbCard.Create(nil);
  try
    Card.ActionList.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(Card);
  end;
end;

procedure TzdbCardHelper.RegisterResources;
var
  ctrl: TzControl;
  i: integer;
begin
  if CardNameSpace.IsEmpty then
    Exit;

  Localizer.Resources.AddResource(CardNameSpace, '', Titolo.Name, 'Caption', Titolo.Caption, rkProp);

  Localizer.Resources.AddResource(CardNameSpace, '', 'ButtonInsert', 'Caption', zDbCardProps.ButtonInsert.Caption, rkProp);
  Localizer.Resources.AddResource(CardNameSpace, '', 'ButtonInsert', 'Hint', zDbCardProps.ButtonInsert.Hint, rkProp);
  Localizer.Resources.AddResource(CardNameSpace, '', 'ButtonEdit', 'Caption', zDbCardProps.ButtonEdit.Caption, rkProp);
  Localizer.Resources.AddResource(CardNameSpace, '', 'ButtonEdit', 'Hint', zDbCardProps.ButtonEdit.Hint, rkProp);
  Localizer.Resources.AddResource(CardNameSpace, '', 'ButtonDelete', 'Caption', zDbCardProps.ButtonDelete.Caption, rkProp);
  Localizer.Resources.AddResource(CardNameSpace, '', 'ButtonDelete', 'Hint', zDbCardProps.ButtonDelete.Hint, rkProp);

  for i := 0 to zControls.Count - 1 do
  begin
    ctrl := zControls[i];
    Localizer.Resources.AddResource(CardNameSpace, 'Field', ctrl.Name, 'DisplayLabel', ctrl.DisplayLabel, rkProp);

    // if ctrl.Separator then
    // Localizer.Resources.AddResource(CardNameSpace, 'Field', ctrl.Name, 'SeparatorCaption', ctrl.SeparatorCaption, rkProp);
  end;
end;

procedure TzdbCardHelper.Translate;
var
  ctrl: TzControl;
  i: integer;
begin
  ActionList.Translate(ClassName);

  if CardNameSpace.IsEmpty then
    Exit;

  Titolo.Caption := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'Titolo', 'Caption'), Titolo.Caption);

  zDbCardProps.ButtonInsert.Caption := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'ButtonInsert', 'Caption'), zDbCardProps.ButtonInsert.Caption);
  zDbCardProps.ButtonInsert.Hint := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'ButtonInsert', 'Hint'), zDbCardProps.ButtonInsert.Hint);
  zDbCardProps.ButtonEdit.Caption := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'ButtonEdit', 'Caption'), zDbCardProps.ButtonEdit.Caption);
  zDbCardProps.ButtonEdit.Hint := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'ButtonEdit', 'Hint'), zDbCardProps.ButtonEdit.Hint);
  zDbCardProps.ButtonDelete.Caption := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'ButtonDelete', 'Caption'), zDbCardProps.ButtonDelete.Caption);
  zDbCardProps.ButtonDelete.Hint := Localizer.GetTranslation(FullResourceName(CardNameSpace, '', 'ButtonDelete', 'Hint'), zDbCardProps.ButtonDelete.Hint);

  for i := 0 to zControls.Count - 1 do
  begin
    ctrl := zControls[i];
    ctrl.DisplayLabel := Localizer.GetTranslation(FullResourceName(CardNameSpace, 'Field', ctrl.Name, 'DisplayLabel'), ctrl.DisplayLabel);

    // if ctrl.Separator then
    // ctrl.SeparatorCaption := Localizer.GetTranslation(FullResourceName(CardNameSpace, 'Field', ctrl.Name, 'SeparatorCaption'), ctrl.SeparatorCaption);
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzDbViewHelper }

class procedure TzDbViewHelper.EnumResourceStrings;
var
  view: TzDbView;
begin
  view := TzDbView.Create(nil);
  try
    view.ActionList.RegisterResources(ClassName, rkZZ);
    // filtri
    // FilterControlOperators: TcxFilterControlOperators;
    // FilterControlOperator: TcxFilterControlOperator;

  finally
    FreeAndNil(view);
  end;

  TcxFilterControlOperator.EnumResourceStrings;
end;

function TzDbViewHelper.ViewNameSpace: string;
begin
  result := ClassNameSpace(ClassType, ViewID);
end;

procedure TzDbViewHelper.RegisterResources;
var
  i: integer;
  column: TcxGridDBColumn;
begin
  if ViewNameSpace.IsEmpty then
    Exit;

  Localizer.Resources.AddResource(ViewNameSpace, '', Titolo.Name, 'Caption', Titolo.Caption, rkProp);

  Localizer.Resources.AddResource(ViewNameSpace, '', 'ButtonInsert', 'Caption', GetDbViewProps.ButtonInsert.Caption, rkProp);
  Localizer.Resources.AddResource(ViewNameSpace, '', 'ButtonInsert', 'Hint', GetDbViewProps.ButtonInsert.Hint, rkProp);
  Localizer.Resources.AddResource(ViewNameSpace, '', 'ButtonEdit', 'Caption', GetDbViewProps.ButtonEdit.Caption, rkProp);
  Localizer.Resources.AddResource(ViewNameSpace, '', 'ButtonEdit', 'Hint', GetDbViewProps.ButtonEdit.Hint, rkProp);
  Localizer.Resources.AddResource(ViewNameSpace, '', 'ButtonDelete', 'Caption', GetDbViewProps.ButtonDelete.Caption, rkProp);
  Localizer.Resources.AddResource(ViewNameSpace, '', 'ButtonDelete', 'Hint', GetDbViewProps.ButtonDelete.Hint, rkProp);

  for i := 0 to cxGridDBTableView.ColumnCount - 1 do
  begin
    column := cxGridDBTableView.Columns[i];
    Localizer.Resources.AddResource(ViewNameSpace, 'Field', column.DataBinding.FieldName, 'Caption', column.Caption, rkProp);
  end;
end;

procedure TzDbViewHelper.Translate;
var
  i: integer;
  column: TcxGridDBColumn;
begin
  ActionList.Translate(ClassName);

  if ViewNameSpace.IsEmpty then
    Exit;

  Titolo.Caption := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'Titolo', 'Caption'), Titolo.Caption);

  GetDbViewProps.ButtonInsert.Caption := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'ButtonInsert', 'Caption'), GetDbViewProps.ButtonInsert.Caption);
  GetDbViewProps.ButtonInsert.Hint := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'ButtonInsert', 'Hint'), GetDbViewProps.ButtonInsert.Hint);
  GetDbViewProps.ButtonEdit.Caption := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'ButtonEdit', 'Caption'), GetDbViewProps.ButtonEdit.Caption);
  GetDbViewProps.ButtonEdit.Hint := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'ButtonEdit', 'Hint'), GetDbViewProps.ButtonEdit.Hint);
  GetDbViewProps.ButtonDelete.Caption := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'ButtonDelete', 'Caption'), GetDbViewProps.ButtonDelete.Caption);
  GetDbViewProps.ButtonDelete.Hint := Localizer.GetTranslation(FullResourceName(ViewNameSpace, '', 'ButtonDelete', 'Hint'), GetDbViewProps.ButtonDelete.Hint);

  for i := 0 to cxGridDBTableView.ColumnCount - 1 do
  begin
    column := cxGridDBTableView.Columns[i];
    column.Caption := Localizer.GetTranslation(FullResourceName(ViewNameSpace, 'Field', column.DataBinding.FieldName, 'Caption'), column.Caption);
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzDbPivotHelper }

class procedure TzDbPivotHelper.EnumResourceStrings;
var
  pivot: TzDbPivot;
begin
  pivot := TzDbPivot.Create(nil);
  try
    pivot.ActionList.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(pivot);
  end;
end;

function TzDbPivotHelper.PivotNameSpace: string;
begin
  result := ClassNameSpace(ClassType, PivotID);
end;

procedure TzDbPivotHelper.RegisterResources;
var
  i: integer;
  field: TcxPivotGridField;
begin
  if PivotNameSpace.IsEmpty then
    Exit;

  Localizer.Resources.AddResource(PivotNameSpace, '', Titolo.Name, 'Caption', Titolo.Caption, rkProp);

  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
  begin
    field := cxDBPivotGrid.Fields[i];
    Localizer.Resources.AddResource(PivotNameSpace, 'Field', field.Name, 'Caption', field.Caption, rkProp);
  end;
end;

procedure TzDbPivotHelper.Translate;
var
  i: integer;
  field: TcxPivotGridField;
begin
  ActionList.Translate(ClassName);

  if PivotNameSpace.IsEmpty then
    Exit;

  Titolo.Caption := Localizer.GetTranslation(FullResourceName(PivotNameSpace, '', 'Titolo', 'Caption'), Titolo.Caption);

  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
  begin
    field := cxDBPivotGrid.Fields[i];
    field.Caption := Localizer.GetTranslation(FullResourceName(PivotNameSpace, 'Field', field.Name, 'Caption'), field.Caption);
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzDbRecordViewHelper }

class procedure TzDbRecordViewHelper.EnumResourceStrings;
var
  RecordView: TzDbRecordView;
begin
  RecordView := TzDbRecordView.Create(nil);
  try
    RecordView.ActionList.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(RecordView);
  end;
end;

function TzDbRecordViewHelper.RecordViewNameSpace: string;
begin
  result := ClassNameSpace(ClassType, RecordViewID);
end;

procedure TzDbRecordViewHelper.RegisterResources;
var
  i: integer;
  j: integer;
  Row: TcxCustomRow;
  MultiRow: TcxDBMultiEditorRow;
begin
  if RecordViewNameSpace.IsEmpty then
    Exit;

  Localizer.Resources.AddResource(RecordViewNameSpace, '', Titolo.Name, 'Caption', Titolo.Caption, rkProp);

  // righe dei campi per nome del campo, come le colonne di TzDbView; le
  // categorie per nome della riga, che nasce dal nome della voce del dizionario
  for i := 0 to cxDBVerticalGrid.Rows.Count - 1 do
  begin
    Row := cxDBVerticalGrid.Rows[i];

    if Row is TcxDBEditorRow then
      Localizer.Resources.AddResource(RecordViewNameSpace, 'Field', TcxDBEditorRow(Row).Properties.DataBinding.FieldName, 'Caption',
        TcxDBEditorRow(Row).Properties.Caption, rkProp)
    else
      if Row is TcxDBMultiEditorRow then
      begin
        MultiRow := TcxDBMultiEditorRow(Row);
        for j := 0 to MultiRow.Properties.Editors.Count - 1 do
          Localizer.Resources.AddResource(RecordViewNameSpace, 'Field', MultiRow.Properties.Editors[j].DataBinding.FieldName, 'Caption',
            MultiRow.Properties.Editors[j].Caption, rkProp);
      end
      else
        if (Row is TcxCategoryRow) and (Row.Name <> '') then
          Localizer.Resources.AddResource(RecordViewNameSpace, 'Category', Row.Name, 'Caption', TcxCategoryRow(Row).Properties.Caption, rkProp);
  end;
end;

procedure TzDbRecordViewHelper.Translate;
var
  i: integer;
  j: integer;
  Row: TcxCustomRow;
  MultiRow: TcxDBMultiEditorRow;
  EditorRow: TcxDBEditorRow;
  CategoryRow: TcxCategoryRow;
begin
  ActionList.Translate(ClassName);

  if RecordViewNameSpace.IsEmpty then
    Exit;

  Titolo.Caption := Localizer.GetTranslation(FullResourceName(RecordViewNameSpace, '', 'Titolo', 'Caption'), Titolo.Caption);

  for i := 0 to cxDBVerticalGrid.Rows.Count - 1 do
  begin
    Row := cxDBVerticalGrid.Rows[i];

    if Row is TcxDBEditorRow then
    begin
      EditorRow := TcxDBEditorRow(Row);
      EditorRow.Properties.Caption := Localizer.GetTranslation(FullResourceName(RecordViewNameSpace, 'Field', EditorRow.Properties.DataBinding.FieldName, 'Caption'),
        EditorRow.Properties.Caption);
    end
    else
      if Row is TcxDBMultiEditorRow then
      begin
        MultiRow := TcxDBMultiEditorRow(Row);
        for j := 0 to MultiRow.Properties.Editors.Count - 1 do
          MultiRow.Properties.Editors[j].Caption := Localizer.GetTranslation(FullResourceName(RecordViewNameSpace, 'Field',
            MultiRow.Properties.Editors[j].DataBinding.FieldName, 'Caption'), MultiRow.Properties.Editors[j].Caption);
      end
      else
        if (Row is TcxCategoryRow) and (Row.Name <> '') then
        begin
          CategoryRow := TcxCategoryRow(Row);
          CategoryRow.Properties.Caption := Localizer.GetTranslation(FullResourceName(RecordViewNameSpace, 'Category', CategoryRow.Name, 'Caption'),
            CategoryRow.Properties.Caption);
        end;
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzDbTreeHelper }

class procedure TzDbTreeHelper.EnumResourceStrings;
var
  Tree: TzDbTree;
begin
  Tree := TzDbTree.Create(nil);
  try
    Tree.ActionList.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(Tree);
  end;
end;

function TzDbTreeHelper.TreeNameSpace: string;
begin
  result := ClassNameSpace(ClassType, TreeID);
end;

procedure TzDbTreeHelper.RegisterResources;
var
  i: integer;
  column: TcxTreeListColumn;
begin
  if TreeNameSpace.IsEmpty then
    Exit;

  Localizer.Resources.AddResource(TreeNameSpace, '', Titolo.Name, 'Caption', Titolo.Caption, rkProp);

  for i := 0 to cxDBTreeList.ColumnCount - 1 do
  begin
    column := cxDBTreeList.Columns[i];
    if column is TcxDBTreeListColumn then
      Localizer.Resources.AddResource(TreeNameSpace, 'Field', TcxDBTreeListColumn(column).DataBinding.FieldName, 'Caption', column.Caption.Text, rkProp);
  end;
end;

procedure TzDbTreeHelper.Translate;
var
  i: integer;
  column: TcxTreeListColumn;
begin
  ActionList.Translate(ClassName);

  if TreeNameSpace.IsEmpty then
    Exit;

  Titolo.Caption := Localizer.GetTranslation(FullResourceName(TreeNameSpace, '', 'Titolo', 'Caption'), Titolo.Caption);

  for i := 0 to cxDBTreeList.ColumnCount - 1 do
  begin
    column := cxDBTreeList.Columns[i];
    if column is TcxDBTreeListColumn then
      column.Caption.Text := Localizer.GetTranslation(FullResourceName(TreeNameSpace, 'Field', TcxDBTreeListColumn(column).DataBinding.FieldName, 'Caption'),
        column.Caption.Text);
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzDbChartHelper }

class procedure TzDbChartHelper.EnumResourceStrings;
var
  Chart: TzDbChart;
begin
  // le stringhe di DevExpress del grafico ("Total", "Others") non passano di
  // qui: le traduce zTranslate (dxChartControlStrs in zTranslate.Products)
  Chart := TzDbChart.Create(nil);
  try
    Chart.ActionList.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(Chart);
  end;
end;

function TzDbChartHelper.ChartNameSpace: string;
begin
  result := ClassNameSpace(ClassType, ChartID);
end;

procedure TzDbChartHelper.RegisterResources;
begin
  if ChartNameSpace.IsEmpty then
    Exit;

  // stessa chiave del titolo di vista e pivot: e' quella che legge anche
  // TLayoutController.TranslateGroupCaptions per il gruppo del layout
  Localizer.Resources.AddResource(ChartNameSpace, '', 'Titolo', 'Caption', GetTitle, rkProp);
end;

procedure TzDbChartHelper.Translate;
var
  Title: string;
  TranslatedTitle: string;
begin
  ActionList.Translate(ClassName);

  if ChartNameSpace.IsEmpty then
    Exit;

  // Il titolo del dizionario (zDbChartProps.Title) non si tocca: e' una
  // proprieta' che l'amministratore salva, e una traduzione scritta li'
  // finirebbe nel dizionario. Si traduce solo il titolo dato dalla form, che
  // il grafico usa quando il dizionario non ne ha uno. SetTitle solo se la
  // traduzione c'e': senza titolo GetTitle ripiega sul nome del componente, e
  // passarlo a SetTitle mostrerebbe un titolo che oggi il grafico non ha
  if not Trim(zDbChartProps.Title).IsEmpty then
    Exit;

  Title := GetTitle;
  TranslatedTitle := Localizer.GetTranslation(FullResourceName(ChartNameSpace, '', 'Titolo', 'Caption'), Title);

  if TranslatedTitle <> Title then
    SetTitle(TranslatedTitle);
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TzDbSchedulerHelper }

class procedure TzDbSchedulerHelper.EnumResourceStrings;
var
  Scheduler: TzDbScheduler;
begin
  Scheduler := TzDbScheduler.Create(nil);
  try
    Scheduler.BaseActions.RegisterResources(ClassName, rkZZ);
    Scheduler.Actions.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(Scheduler);
  end;
end;

procedure TzDbSchedulerHelper.RegisterResources;
begin
  // le azioni del dizionario esistono solo nell'istanza: stesso spazio dei
  // nomi della classe, AddResource non duplica quelle gia' elencate
  Actions.RegisterResources(ClassName, rkZZ);
end;

procedure TzDbSchedulerHelper.Translate;
begin
  BaseActions.Translate(ClassName);
  Actions.Translate(ClassName);
end;

/// ////////////////////////////////////////////////////////////////////////////
//
// { TzGoogleMapsHelper }
//
// class procedure TzGoogleMapsHelper.EnumResourceStrings;
// begin
// // nulla da tradurre al momento
// end;
//
// procedure TzGoogleMapsHelper.RegisterResources(const NameSpace: string);
// begin
// // nulla da tradurre al momento
// end;
//
// procedure TzGoogleMapsHelper.Translate(const NameSpace: string);
// begin
// // nulla da tradurre al momento
// end;

/// ////////////////////////////////////////////////////////////////////////////
{ TzFileViewerHelper }

class procedure TzFileViewerHelper.EnumResourceStrings;
var
  viewer: TzFileViewer;
begin
  viewer := TzFileViewer.Create(nil);
  try
    viewer.ActionList.RegisterResources(ClassName, rkZZ);
  finally
    FreeAndNil(viewer);
  end;
end;

procedure TzFileViewerHelper.RegisterResources;
begin
  if ViewerNameSpace.IsEmpty then
    Exit;
end;

procedure TzFileViewerHelper.Translate;
begin
  ActionList.Translate(ClassName);

  if ViewerNameSpace.IsEmpty then
    Exit;
end;

function TzFileViewerHelper.ViewerNameSpace: string;
begin
  if ID.IsEmpty then
    result := ''
  else
    result := 'zFileViewer.' + ID;
end;

/// ////////////////////////////////////////////////////////////////////////////
{ TzFormControllerHelper }

function TzFormControllerHelper.DataModuleNameSpace: string;
begin
  if not assigned(zDataModule) then
    result := ''
  else
    result := 'zDataModule.' + zDataModule.Name;
end;

procedure TzFormControllerHelper.RegisterResources(const NameSpace: string);
  procedure enum(diagramDataSets: TzDiagramDataSets);
  var
    diagramDataSet: TzDiagramDataSet;
  begin

    for diagramDataSet in diagramDataSets do
    begin
      if diagramDataSet.Menu.TranslatedCaption.IsEmpty then
        Localizer.Resources.AddResource(DataModuleNameSpace, 'DataSet', diagramDataSet.Name, 'Caption', diagramDataSet.Menu.Caption, rkProp)
      else
        Localizer.Resources.AddResource(DataModuleNameSpace, 'DataSet', diagramDataSet.Name, 'Caption', diagramDataSet.Menu.TranslatedCaption, rkProp);

      if diagramDataSet.Menu.TranslatedGroup.IsEmpty then
        Localizer.Resources.AddResource(DataModuleNameSpace, 'DataSet', diagramDataSet.Name, 'Group', diagramDataSet.Menu.Group, rkProp)
      else
        Localizer.Resources.AddResource(DataModuleNameSpace, 'DataSet', diagramDataSet.Name, 'Group', diagramDataSet.Menu.TranslatedGroup, rkProp);

      if diagramDataSet.DetailDatasets.Count > 0 then
        enum(diagramDataSet.DetailDatasets);
    end;
  end;

begin

  if assigned(zDataModule) then
    enum(zDataModule.DataSets);
end;

procedure TzFormControllerHelper.Translate(const NameSpace: string);

  procedure enum(diagramDataSets: TzDiagramDataSets);
  var
    diagramDataSet: TzDiagramDataSet;
  begin

    for diagramDataSet in diagramDataSets do
    begin
      diagramDataSet.Menu.TranslatedCaption := Localizer.GetTranslation(FullResourceName(DataModuleNameSpace, 'DataSet', diagramDataSet.Name, 'Caption'), diagramDataSet.Menu.TranslatedCaption);
      diagramDataSet.Menu.TranslatedGroup := Localizer.GetTranslation(FullResourceName(DataModuleNameSpace, 'DataSet', diagramDataSet.Name, 'Group'), diagramDataSet.Menu.TranslatedGroup);

      if diagramDataSet.DetailDatasets.Count > 0 then
        enum(diagramDataSet.DetailDatasets);
    end;
  end;

begin
  if assigned(zDataModule) then
    enum(zDataModule.DataSets);

  Self.Translated;
end;

/// ////////////////////////////////////////////////////////////////////////////

class procedure TOkCancelHelper.EnumResourceStrings;
var
  OkCancel: TOkCancel;
begin
  OkCancel := TOkCancel.Create(nil);
  try
    Localizer.Resources.AddResource(ClassName, '', OkCancel.OkBtn.Name, 'Caption', OkCancel.OkBtn.Caption, rkZZ);
    Localizer.Resources.AddResource(ClassName, '', OkCancel.OkBtn.Name, 'Hint', OkCancel.OkBtn.Hint, rkZZ);

    Localizer.Resources.AddResource(ClassName, '', OkCancel.CancelBtn.Name, 'Caption', OkCancel.CancelBtn.Caption, rkZZ);
    Localizer.Resources.AddResource(ClassName, '', OkCancel.CancelBtn.Name, 'Hint', OkCancel.CancelBtn.Hint, rkZZ);

    Localizer.Resources.AddResource(ClassName, '', OkCancel.ApplyBtn.Name, 'Caption', OkCancel.ApplyBtn.Caption, rkZZ);
    Localizer.Resources.AddResource(ClassName, '', OkCancel.ApplyBtn.Name, 'Hint', OkCancel.ApplyBtn.Hint, rkZZ);
  finally
    FreeAndNil(OkCancel);
  end;
end;

procedure TOkCancelHelper.RegisterResources(const NameSpace: string);
begin
  // ci pensa la EnumResourceStrings
end;

procedure TOkCancelHelper.Translate(const NameSpace: string);
begin
  OkBtn.Caption := Localizer.GetTranslation(FullResourceName(ClassName, '', OkBtn.Name, 'Caption'), OkBtn.Caption);
  OkBtn.Hint := Localizer.GetTranslation(FullResourceName(ClassName, '', OkBtn.Name, 'Hint'), OkBtn.Hint);

  CancelBtn.Caption := Localizer.GetTranslation(FullResourceName(ClassName, '', CancelBtn.Name, 'Caption'), CancelBtn.Caption);
  CancelBtn.Hint := Localizer.GetTranslation(FullResourceName(ClassName, '', CancelBtn.Name, 'Hint'), CancelBtn.Hint);

  ApplyBtn.Caption := Localizer.GetTranslation(FullResourceName(ClassName, '', ApplyBtn.Name, 'Caption'), ApplyBtn.Caption);
  ApplyBtn.Hint := Localizer.GetTranslation(FullResourceName(ClassName, '', ApplyBtn.Name, 'Hint'), ApplyBtn.Hint);
end;

/// ////////////////////////////////////////////////////////////////////////////
{ TcxLabelHelper }

procedure TcxLabelHelper.RegisterResources(const NameSpace: string);
begin
  Localizer.Resources.AddResource(NameSpace, ClassName, Name, 'Caption', Caption, rkProp);
end;

procedure TcxLabelHelper.Translate(const NameSpace: string);
begin
  Caption := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, Name, 'Caption'), Caption);
end;

procedure TdxBarHelper.RegisterResources(const NameSpace: string);
begin
  Localizer.Resources.AddResource(NameSpace, ClassName, Name, 'Caption', Caption, rkProp);
end;

procedure TdxBarHelper.Translate(const NameSpace: string);
begin
  Caption := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, Name, 'Caption'), Caption);
end;

procedure TdxRibbonTabHelper.RegisterResources(const NameSpace: string);
var
  i: integer;
begin
  Localizer.Resources.AddResource(NameSpace, ClassName, Name, 'Caption', Caption, rkProp);

  for i := 0 to Groups.Count - 1 do
    if assigned(Groups[i].ToolBar) then
      Groups[i].ToolBar.RegisterResources(NameSpace);
end;

procedure TdxRibbonTabHelper.Translate(const NameSpace: string);
var
  i: integer;
begin
  Caption := Localizer.GetTranslation(FullResourceName(NameSpace, ClassName, Name, 'Caption'), Caption);

  for i := 0 to Groups.Count - 1 do
    if assigned(Groups[i].ToolBar) then
      Groups[i].ToolBar.Translate(NameSpace);
end;

{ TcxFilterControlOperatorHelper }

class function TcxFilterControlOperatorHelper.NameSpace: string;
begin
  result := 'TcxFilterControlOperator';
end;

class procedure TcxFilterControlOperatorHelper.EnumResourceStrings;
var
  cxFilterControlOperator: TcxFilterControlOperator;
begin

  for cxFilterControlOperator := Low(TcxFilterControlOperator) to high(TcxFilterControlOperator) do
    Localizer.Resources.AddResource(NameSpace, TRttiEnumerationType.GetName(cxFilterControlOperator), cxFilterControlOperator.ToString, rkZZ);
end;

function TcxFilterControlOperatorHelper.GetTranslation: string;
var
  ResourceName: string;
begin
  ResourceName := FullResourceName(NameSpace, TRttiEnumerationType.GetName(Self));
  result := Localizer.GetTranslation(ResourceName, Self.ToString);
end;

function TcxFilterControlOperatorHelper.ToString: string;
begin
  result := GetFilterControlOperatorText(Self);
end;

end.
