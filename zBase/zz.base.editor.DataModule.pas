unit zz.base.editor.DataModule;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  cxGraphics,
  cxControls,
  cxButtons,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  zFbDataSet,
  ComCtrls,
  cxStyles,
  cxEdit,
  dxBar,
  ActnList,
  ImgList,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  cxContainer,
  cxTreeView,
  cxSplitter,
  ExtCtrls,
  cxTextEdit,
  cxMaskEdit,
  cxButtonEdit,
  zSystem,
  cxClasses,
  StdActns,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  Frame_ObjectInspector,
  Frame_Collection,
  System.Actions,
  System.ImageList,
  cxImageList,
  dxBarBuiltInMenu,
  cxPC,
  cxCustomData,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  cxCheckBox,
  cxMemo,
  cxBlobEdit,
  zTreeMenu,
  dxScrollbarAnnotations,
  dxFileActions,
  Vcl.Menus,
  Vcl.StdCtrls,
  cxDropDownEdit,
  cxBarEditItem,
  zz.base.editor._frame,
  cxFilter,
  dxCoreGraphics,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  zProgressBox;

const // messaggi
  msgSincronizzaDataSet = WM_USER + 1;

type
  TFrameEditor_DataModule = class(TzFrameEditorCollectionItem)
    cxSplitterInspector: TcxSplitter;
    MetaTree: TcxTreeView;
    cxSplitterMetadata: TcxSplitter;
    ActionList: TActionList;
    ModificaDataSet: TAction;
    NuovoDataSet: TAction;
    EliminaDataSet: TAction;
    imagesTreeView: TImageList;
    dxBarManager: TdxBarManager;
    Apri1: TdxBarButton;
    Add1: TdxBarButton;
    SubMenuFK: TdxBarSubItem;
    Delete1: TdxBarButton;
    Copia1: TdxBarButton;
    Incolla1: TdxBarButton;
    PopupMenu: TdxBarPopupMenu;
    pnlMetadata: TPanel;
    edSearch: TcxButtonEdit;
    MetaTimer: TTimer;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    Metadata: TAction;
    dxBarButton10: TdxBarButton;
    DiagramImages24: TImageList;
    DiagramImages16: TImageList;
    DFM_CaricaDaFile: TdxFileOpen;
    DFM_SalvaSuFile: TdxFileSaveAs;
    dxBarButton17: TdxBarButton;
    CopiaNomiDataSet: TAction;
    CaricaDaClipboard: TAction;
    CompletionImageList: TImageList;
    FrameObjectInspector: TFrameObjectInspector;
    CollectionImageList: TImageList;
    pnlLeft: TPanel;
    cxSplitter: TcxSplitter;
    ApplicaCaption: TAction;
    ApplicaBorderStyle: TAction;
    BuildGUI: TAction;
    Ripulisci: TAction;
    tree: TcxTreeList;
    colCaption: TcxTreeListColumn;
    colGroup: TcxTreeListColumn;
    colVisible: TcxTreeListColumn;
    colReportGroup: TcxTreeListColumn;
    colPipeName: TcxTreeListColumn;
    colSharedReports: TcxTreeListColumn;
    colViews: TcxTreeListColumn;
    colCards: TcxTreeListColumn;
    colCubes: TcxTreeListColumn;
    colFileViewers: TcxTreeListColumn;
    colGoogleMaps: TcxTreeListColumn;
    colRecordViews: TcxTreeListColumn;
    colTrees: TcxTreeListColumn;
    colCharts: TcxTreeListColumn;
    colSchedulers: TcxTreeListColumn;
    colName: TcxTreeListColumn;
    treeImages16: TcxImageList;
    pnlTreeMenu: TPanel;
    treeImages24: TcxImageList;
    colLookup: TcxTreeListColumn;
    dxBarManagerBar: TdxBar;
    SolaLettura: TAction;
    Modificabile: TAction;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton1: TdxBarButton;
    dxBarButton4: TdxBarButton;
    SpostaInAlto: TAction;
    SpostaInBasso: TAction;
    MuoviAllaRadice: TAction;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    Sposta: TAction;
    pnlSposta: TPanel;
    cxButton1: TcxButton;
    treeSposta: TcxTreeView;
    cxBarEditItemSposta: TcxBarEditItem;
    Proprieta: TAction;
    dxBarButton8: TdxBarButton;
    Copia: TAction;
    dxBarButton9: TdxBarButton;
    Incolla: TAction;
    dxBarButton11: TdxBarButton;
    dxBarSubItem2: TdxBarSubItem;
    CaricaDaFile: TdxFileOpen;
    SalvaSuFile: TdxFileSaveAs;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    ResetLayout: TAction;
    dxBarButton14: TdxBarButton;
    dxBarButton15: TdxBarButton;
    VerificaSQL: TAction;
    qryTest: TFDQuery;
    dxBarButton16: TdxBarButton;
    ProgressBox: TProgressBox;
    procedure ApplicaBorderStyleExecute(Sender: TObject);
    procedure ApplicaCaptionExecute(Sender: TObject);
    procedure BuildGUIExecute(Sender: TObject);
    procedure CaricaDaClipboardExecute(Sender: TObject);
    procedure CaricaDaFileAccept(Sender: TObject);
    procedure CopiaNomiDataSetExecute(Sender: TObject);
    procedure ModificaDataSetExecute(Sender: TObject);
    procedure DFM_CaricaDaFileAccept(Sender: TObject);
    procedure DFM_SalvaSuFileAccept(Sender: TObject);
    procedure EliminaDataSetExecute(Sender: TObject);
    procedure NuovoDataSetExecute(Sender: TObject);
    procedure MetaTimerTimer(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure MetaTreeDblClick(Sender: TObject);
    procedure MetaTreeKeyPress(Sender: TObject; var Key: Char);
    procedure edSearchPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure edSearchPropertiesChange(Sender: TObject);
    procedure MetadataExecute(Sender: TObject);
    procedure RipulisciExecute(Sender: TObject);
    procedure treeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure treeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure treeEdited(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
    procedure treeGetDragDropText(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var AText: string);
    procedure colPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure treeDblClick(Sender: TObject);
    procedure treeEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure treeGetNodeImageIndex(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; AIndexType: TcxTreeListImageIndexType; var AIndex: TImageIndex);
    procedure treeFocusedNodeChanged(Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    procedure colVisiblePropertiesEditValueChanged(Sender: TObject);
    procedure ModificabileExecute(Sender: TObject);
    procedure MuoviAllaRadiceExecute(Sender: TObject);
    procedure SolaLetturaExecute(Sender: TObject);
    procedure SpostaInAltoExecute(Sender: TObject);
    procedure SpostaInBassoExecute(Sender: TObject);
    procedure cxBarEditItemSpostaPropertiesInitPopup(Sender: TObject);
    procedure pnlSpostaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlSpostaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlSpostaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ProprietaExecute(Sender: TObject);
    procedure SpostaExecute(Sender: TObject);
    procedure treeSpostaDblClick(Sender: TObject);
    procedure colNamePropertiesEditValueChanged(Sender: TObject);
    procedure CopiaExecute(Sender: TObject);
    procedure IncollaExecute(Sender: TObject);
    procedure ResetLayoutExecute(Sender: TObject);
    procedure SalvaSuFileAccept(Sender: TObject);
    procedure VerificaSQLExecute(Sender: TObject);
  private
    DeletingDataSet: Boolean;
    Internal_DataModule: TzDataModule;

    function MenuCaption(const TableName: string): string;
    function CreateDataSet(MasterNode: TcxTreeListNode; const TableName: string): TzDiagramDataSet;
    procedure FillMetadata(ShowSystem: Boolean);
    function GetFkForTable: string;
    procedure SubMenuFKClick(Sender: TObject);
    procedure SetDataSetCaption(zDiagramDataSet: TzDiagramDataSet; const Caption: string);
  private
    procedure enum(zDiagramDataSet: TzDiagramDataSet; proc: TzDiagramDataSets.TEnumProc; const Msg: string);
  private const
    TextHeader = 'DataSetName;TableName;MenuCaption;MenuGroup;MenuVisible';
    function GetAsText: string;
    procedure SetAsText(const Value: string);
    property AsText: string read GetAsText write SetAsText;
  private
    TreeMenu: TzTreeMenu;
    procedure TreeMenuWidthChanged(Sender: TObject; const NewWidth: Integer);
    procedure TreeMenuDblClick(Sender: TObject);
    procedure TreeMenuSelect(Sender: TObject);
    procedure TreeMenuDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeMenuDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  private
    procedure FillTree;
    procedure LoadTreeMenu;

    procedure Dataset2Node(Node: TcxTreeListNode; zDiagramDataSet: TzDiagramDataSet);
    procedure Node2DataSet(Node: TcxTreeListNode; zDiagramDataSet: TzDiagramDataSet);

    function GetDataSet(Node: TcxTreeListNode): TzDiagramDataSet;
    function GetSelectedTableName: string;
    function GetDataSetNode(Const DatasetName: String): TcxTreeListNode;
    function DataSetExists(Const DatasetName: String): Boolean;
    function FocusDataSetNode(Const DatasetName: String): Boolean;
    function ComponentName(const Name: string): string;

    procedure EnumReadonly(const ReadOnly: Boolean);
  private
    procedure doSincronizzaDataSets;
    procedure SincronizzaDataSets;
    procedure MessageHandler(var Message: TMessage); message msgSincronizzaDataSet;
  private
    ResizingPnlSposta: Boolean;
    oldPos: TPoint;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init; override;
    procedure Apply; override;
    function GetEditorCaption: string; override;
    function WindowState: TWindowState; override;
  end;

implementation

uses
  System.Math,
  System.StrUtils,
  Vcl.Clipbrd,
  zBaseLib,
  zSqlLib,
  zMetadata,
  zdx,
  zFrmCollection,
  zz.base.editor._form,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  zFrmInspector,
  zMsg,
  System.JSON,
  System.IOUtils;

{$R *.dfm}

Type
  TcxTreeListAccess = class(TcxTreeList);

constructor TFrameEditor_DataModule.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  ResizingPnlSposta := false;
  oldPos := Point(0, 0);

  DeletingDataSet := false;
  Internal_DataModule := TzDataModule.Create(nil);

  Metadata.Checked := false;
  BuildGUI.Checked := false;

  pnlMetadata.Visible := false;
  pnlMetadata.width := 300;
  cxSplitterMetadata.Visible := false;

  dx.InitBar(dxBarManagerBar);
  /// /////////////////////////////////////////////
  /// TreeMenu
  TreeMenu := TzTreeMenu.Create(Self);
  TreeMenu.Parent := pnlTreeMenu;
  TreeMenu.Align := alClient;
  TreeMenu.zDataModule := Internal_DataModule;
  TreeMenu.zSystem := zSystem;
  TreeMenu.OnSelect := TreeMenuSelect;
  TreeMenu.OnDblClick := TreeMenuDblClick;
  // TreeMenu.OnWidthChanged := TreeMenuWidthChanged;
  TreeMenu.AutoWidth := false;
  TreeMenu.tree.OptionsView.ColumnAutoWidth := True;
  // TreeMenu.tree.ShowRoot := True;
  TreeMenu.tree.DragMode := dmAutomatic;
  TreeMenu.tree.OnDragDrop := TreeMenuDragDrop;
  TreeMenu.tree.OnDragOver := TreeMenuDragOver;

  /// /////////////////////////////////////////////
  /// TreeList
  dx.InitTreeList(tree);
  tree.Styles.Background := dx.GetStyle(scContent);
  tree.Styles.Content := dx.GetStyle(scContent);
  tree.Styles.ContentEven := dx.GetStyle(scContentEven);
  tree.Styles.ContentOdd := dx.GetStyle(scContentOdd);
  tree.Styles.Inactive := dx.GetStyle(scContent);
  tree.Styles.Footer := dx.GetStyle(scFooter);

  tree.Font.Size := 11;
  // colori colonne

  /// /////////////////////////////////////////////
  /// Varie

  DFM_CaricaDaFile.Dialog.InitialDir := path;
  DFM_SalvaSuFile.Dialog.InitialDir := path;
end;

destructor TFrameEditor_DataModule.Destroy;
begin
  // 1. l'interfaccia va staccata dal modello PRIMA che il modello muoia:
  // l'inspector lo ispeziona, TreeMenu.zDataModule lo referenzia e ogni
  // nodo di tree ha in Data un TzDiagramDataSet interno a Internal_DataModule.
  // tree.Clear va prima di FreeAndNil(TreeMenu): svuotare l'albero fa
  // scattare treeFocusedNodeChanged, che con TreeMenu gia' nil chiamerebbe
  // SelectDataSet su un'istanza inesistente
  try
    FrameObjectInspector.Clear;
    tree.Clear;
    FreeAndNil(TreeMenu);
  except
    on e: exception do
      siMain.LogException(e);
  end;

  // 2. adesso il modello non e' piu' referenziato da nessuno
  try
    FreeAndNil(Internal_DataModule);
  except
    on e: exception do
      siMain.LogException(e);
  end;

  inherited;
end;

procedure TFrameEditor_DataModule.edSearchPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  edSearch.Clear;
end;

procedure TFrameEditor_DataModule.edSearchPropertiesChange(Sender: TObject);
begin
  MetaTimer.Enabled := false;
  MetaTimer.Enabled := True;
end;

function TFrameEditor_DataModule.GetFkForTable: string;
var
  SelectedTable: TzmdTable;
  fk: TStringList;
  I: Integer;
  k: Integer;
  TableName: string;
begin
  result := '';

  if not Assigned(zSystem) then
    Exit;

  TableName := GetSelectedTableName;
  if TableName = '' then
    Exit;

  I := zSystem.Metadata.Tables.IndexOf(TableName);
  if I = -1 then
    Exit
  else
    SelectedTable := zSystem.Metadata.Tables[I];

  fk := TStringList.Create;
  try

    for I := 0 to SelectedTable.ForeignKeys.count - 1 do
      if fk.IndexOf(SelectedTable.ForeignKeys[I].FkTable) = -1 then
        fk.Add(SelectedTable.ForeignKeys[I].FkTable);

    for I := 0 to zSystem.Metadata.Tables.count - 1 do
      if zSystem.Metadata.Tables[I] <> SelectedTable then
        for k := 0 to zSystem.Metadata.Tables[I].ForeignKeys.count - 1 do
          if SameText(TableName, zSystem.Metadata.Tables[I].ForeignKeys[k].FkTable) then
            if fk.IndexOf(zSystem.Metadata.Tables[I].Name) = -1 then
              fk.Add(zSystem.Metadata.Tables[I].Name);

    fk.Sort;
    result := fk.Text;
  finally
    FreeAndNil(fk);
  end;
end;

function TFrameEditor_DataModule.GetSelectedTableName: string;
var
  DataSet: TzDiagramDataSet;
  zDataSet: TzDataSet;
begin
  result := '';

  DataSet := GetDataSet(tree.FocusedNode);
  if Assigned(DataSet) then
  begin
    zDataSet := DataSet.zDataSet;
    if Assigned(zDataSet) then
      result := zDataSet.TableName;
  end;
end;

procedure TFrameEditor_DataModule.PopupMenuPopup(Sender: TObject);
var
  fk: TStringList;
  MenuItem: TdxBarButton;
  I: Integer;
  pt: TPoint;
  Node: TcxTreeListNode;
begin
  SubMenuFK.ItemLinks.DestroyBarItems;

  pt := Mouse.CursorPos;
  pt := tree.ScreenToClient(pt);
  Node := tree.GetNodeAt(pt.X, pt.Y);

  if Assigned(Node) then
  begin
    Node.Focused := True;

    fk := TStringList.Create;
    try
      fk.Text := GetFkForTable;

      for I := 0 to fk.count - 1 do
      begin
        MenuItem := TdxBarButton.Create(Self);
        SubMenuFK.ItemLinks.Add(MenuItem);
        MenuItem.Caption := fk[I];
        MenuItem.Tag := I;
        MenuItem.OnClick := SubMenuFKClick;
        MenuItem.PaintStyle := psCaptionGlyph;
      end;

    finally
      FreeAndNil(fk);
    end;
  end;
end;

procedure TFrameEditor_DataModule.FillMetadata(ShowSystem: Boolean);

  function AddNode(Parent: TTreeNode; const ObjName: string; const ItemImage: Integer): TTreeNode;
  begin
    result := MetaTree.Items.AddChild(Parent, ObjName);
    result.ImageIndex := ItemImage;
    result.SelectedIndex := ItemImage;
  end;

  function FilterOk(const MetaName, Filter: String): Boolean;
  begin
    result := (Filter = '') or (Ansipos(UpperCase(Filter), UpperCase(MetaName)) > 0);
  end;

  procedure FillTreeView;
  const
    cTableImage = 0;
    cViewImage = 1;
    cProcImage = 2;
  var
    Filter: string;
    TablesNode, ViewsNode, ProcsNode: TTreeNode;
    I: Integer;
  begin
    Filter := edSearch.Text;

    MetaTree.Items.BeginUpdate;
    try
      MetaTree.Items.Clear;
      TablesNode := AddNode(nil, 'Tables', cTableImage);
      ViewsNode := AddNode(nil, 'Views', cViewImage);
      ProcsNode := AddNode(nil, 'Procedures', cProcImage);

      if not Assigned(zSystem) then
        Exit;

      for I := 0 to zSystem.Metadata.Tables.count - 1 do
        if FilterOk(zSystem.Metadata.Tables[I].Name, Filter) then
          AddNode(TablesNode, zSystem.Metadata.Tables[I].Name, cTableImage);

      for I := 0 to zSystem.Metadata.Views.count - 1 do
        if FilterOk(zSystem.Metadata.Views[I].Name, Filter) then
          AddNode(ViewsNode, zSystem.Metadata.Views[I].Name, cViewImage);

      for I := 0 to zSystem.Metadata.Procedures.count - 1 do
        if zSystem.Metadata.Procedures[I].ParamsOutput.count > 0 then
          if FilterOk(zSystem.Metadata.Procedures[I].Name, Filter) then
            AddNode(ProcsNode, zSystem.Metadata.Procedures[I].Name, cProcImage);

      TablesNode.Text := Format('Tables(%d)', [TablesNode.count]);
      ViewsNode.Text := Format('Views(%d)', [ViewsNode.count]);
      ProcsNode.Text := Format('Procedures(%d)', [ProcsNode.count]);

      TablesNode.Expanded := True;
      ViewsNode.Expanded := Filter <> '';
      ProcsNode.Expanded := Filter <> '';
    finally
      MetaTree.Items.EndUpdate;
    end;
  end;

begin
  FillTreeView;
end;

procedure TFrameEditor_DataModule.SubMenuFKClick(Sender: TObject);
begin
  CreateDataSet(tree.FocusedNode, (Sender as TdxBarButton).Caption);
end;

procedure TFrameEditor_DataModule.MetaTreeDblClick(Sender: TObject);
begin
  treeDragDrop(Self, Sender, 0, 0);
end;

procedure TFrameEditor_DataModule.MetaTreeKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    treeDragDrop(Self, Sender, 0, 0);
end;

procedure TFrameEditor_DataModule.MetaTimerTimer(Sender: TObject);
begin
  MetaTimer.Enabled := false;
  FillMetadata(false);
  try
    MetaTree.SetFocus;
  except
  end;
end;

function TFrameEditor_DataModule.GetDataSet(Node: TcxTreeListNode): TzDiagramDataSet;
begin
  result := nil;
  if Assigned(Node) then
    if Assigned(Node.Data) then
      if TObject(Node.Data) is TzDiagramDataSet then
        result := TzDiagramDataSet(Node.Data);
end;

function TFrameEditor_DataModule.GetDataSetNode(const DatasetName: String): TcxTreeListNode;
var
  I: Integer;
begin
  result := nil;

  for I := 0 to tree.AbsoluteCount - 1 do
    if SameText(tree.AbsoluteItems[I].Texts[0], DatasetName) then
      Exit(tree.AbsoluteItems[I]);
end;

function TFrameEditor_DataModule.CreateDataSet(MasterNode: TcxTreeListNode; const TableName: string): TzDiagramDataSet;
var
  MasterDataSet: TzDiagramDataSet;
  MasterTableName: string;
  zDataSet: TzDataSet;
  Node: TcxTreeListNode;
begin
  MasterDataSet := nil;

  if Assigned(MasterNode) then
    if Assigned(MasterNode.Data) then
      MasterDataSet := TzDiagramDataSet(MasterNode.Data);

  if Assigned(MasterDataSet) then
  begin
    result := MasterDataSet.DetailDataSets.Add;
    MasterTableName := MasterDataSet.zDataSet.TableName;
  end
  else
  begin
    result := Internal_DataModule.DataSets.Add;
    MasterTableName := '';
  end;

  result.Name := ComponentName(TableName);
  SetDataSetCaption(result, MenuCaption(TableName));

  zDataSet := result.zDataSet(True); // crea se non esiste
  zDataSet.TableName := UpperCase(TableName);

  if Assigned(zSystem) then
  begin
    zDataSet.SQL_Select.Text := Build_Sql_Select(zSystem.Metadata, zDataSet.TableName, nil);

    if MasterTableName <> '' then
      zDataSet.SQL_Select.Text := Build_FkRelation(zSystem.Metadata, zDataSet.SQL_Select.Text, zDataSet.TableName, MasterTableName);
  end;
  /// ////////////////////////////////////////////
  if not Assigned(MasterNode) then
    MasterNode := tree.Root;

  Node := tree.AddChild(MasterNode, result);
  Dataset2Node(Node, result);

  MasterNode.Expand(True);
  Node.Selected := True;

  LoadTreeMenu;
end;

procedure TFrameEditor_DataModule.MetadataExecute(Sender: TObject);

begin
  pnlMetadata.Visible := Metadata.Checked;
  cxSplitterMetadata.Visible := Metadata.Checked;

  cxSplitterMetadata.Left := pnlMetadata.Left - 1;

  try
    if pnlMetadata.Visible then
    begin
      // se non � stato ancora caricato
      if MetaTree.Items.count = 0 then
        FillMetadata(false);

      if edSearch.CanFocus and edSearch.HandleAllocated then
        edSearch.SetFocus
    end
    else
      tree.SetFocus;
  except
  end;
end;

procedure TFrameEditor_DataModule.DFM_CaricaDaFileAccept(Sender: TObject);
begin
  // ComponentFromDFM(Internal_DataModule, DFM_CaricaDaFile.Dialog.FileName, nil);
  // BuildDiagram;
end;

procedure TFrameEditor_DataModule.DFM_SalvaSuFileAccept(Sender: TObject);
begin
  // ComponentToDFM(Internal_DataModule, DFM_SalvaSuFile.Dialog.FileName, nil);
end;

function TFrameEditor_DataModule.GetEditorCaption: string;
begin
  if Assigned(Item) then
    result := 'DM: ' + Item.Name
  else
    result := Inherited GetEditorCaption;
end;

procedure TFrameEditor_DataModule.Apply;
begin
  inherited;
  if not Assigned(Item) then
    Exit;

  Item.Assign(Internal_DataModule);
end;

procedure TFrameEditor_DataModule.Init;
begin
  inherited;

  if not Assigned(Item) then
    Exit;

  Clear;
  Internal_DataModule.Assign(Item);

  FrameObjectInspector.Clear;
  FrameObjectInspector.Add(Internal_DataModule);

  FillTree;

  if Internal_DataModule.DataSets.count = 0 then
  begin
    TThread.ForceQueue(nil,
      procedure
      begin
        Metadata.Execute;
      end);
  end;
end;

procedure TFrameEditor_DataModule.LoadTreeMenu;
begin
  TreeMenu.LoadMenu;
end;

function TFrameEditor_DataModule.WindowState: TWindowState;
begin
  result := wsMaximized;
end;

procedure TFrameEditor_DataModule.CopiaNomiDataSetExecute(Sender: TObject);
begin
  inherited;
  Clipboard.AsText := AsText;
  ConfirmOk('Nomi dataset copiati nella clipboard.');
end;

procedure TFrameEditor_DataModule.CaricaDaClipboardExecute(Sender: TObject);
begin
  inherited;
  if ConfirmYesNo('Creare i dataset dal contenuto della clipboard?') then
    AsText := Clipboard.AsText;
end;

function TFrameEditor_DataModule.GetAsText: string;
var
  str: TStringList;
  procedure doIt(DataSets: TzDiagramDataSets; Level: Integer);
  var
    I: Integer;
    s: string;
  begin
    s := DupeString(' ', Level);

    for I := 0 to DataSets.count - 1 do
    begin
      str.Add(s + DataSets[I].Name + ';' + DataSets[I].zDataSet.TableName + ';' + DataSets[I].Menu.Caption + ';' + DataSets[I].Menu.Group + ';' + BoolToStr(DataSets[I].Menu.Visible, True) + ';');

      doIt(DataSets[I].DetailDataSets, Level + 1);
    end;
  end;

begin
  result := '';

  str := TStringList.Create;
  try
    str.Add(TextHeader);
    doIt(Internal_DataModule.DataSets, 0);
    result := str.Text;
  finally
    FreeAndNil(str);
  end;
end;

procedure TFrameEditor_DataModule.SetAsText(const Value: string);
  function GetLevel(const s: string): Integer;
  var
    c: Char;
  begin
    result := 0;
    for c in s do
      if c = ' ' then
        inc(result)
      else
        Exit(result);
  end;

  procedure SplitSourceLine(const src: string; out DatasetName, TableName, MenuCaption, MenuGroup: string; out MenuVisible: Boolean);
  var
    idx: Integer;
    s: string;
    str: TStringList;
  begin
    TableName := '';
    MenuCaption := '';
    DatasetName := '';
    MenuGroup := '';
    MenuVisible := True;

    str := TStringList.Create;
    try
      str.Delimiter := ';';
      str.StrictDelimiter := True;
      str.DelimitedText := trim(src);

      /// ///////////////////////////////
      if str.count = 1 then
      begin
        DatasetName := str[0];
        DatasetName := ValidateComponentName(DatasetName);
        if not IsValidIdent(DatasetName) then
          raise exception.Create('Nome componente non valido: ' + DatasetName);

        TableName := UpperCase(str[0]);
        MenuCaption := DatasetName;
        MenuGroup := '';
        MenuVisible := True;
        Exit;
      end;
      /// ///////////////////////////////
      if str.count > 0 then
        DatasetName := str[0];

      DatasetName := ValidateComponentName(DatasetName);
      if not IsValidIdent(DatasetName) then
        raise exception.Create('Nome componente non valido: ' + DatasetName);
      /// ///////////////////////////////
      TableName := '';
      if str.count > 1 then
        TableName := str[1];

      /// ///////////////////////////////
      MenuCaption := '';
      if str.count > 2 then
        MenuCaption := str[2];

      if (MenuCaption = '') or (MenuCaption = TableName) then
        MenuCaption := zzCapFirst(TableName, True);
      /// ///////////////////////////////
      if str.count > 3 then
        MenuGroup := str[3];
      /// ///////////////////////////////

      if str.count > 4 then
        tryStrToBool(str[4], MenuVisible)
      else
        MenuVisible := True;
      /// ///////////////////////////////
    finally
      FreeAndNil(str);
    end;
  end;

var
  str: TStringList;
  s: string;
  LastLevel, CurrentLevel: Integer;
  Collection: TzDiagramDataSets;
  zDiagramDataSet: TzDiagramDataSet;
  I: Integer;
  idx: Integer;
  MasterTableName: string;
  zDataSet: TzDataSet;
  TableName, MenuCaption, DatasetName, MenuGroup: string;
  MenuVisible: Boolean;
begin
  LastLevel := -1;
  Internal_DataModule.DataSets.Clear;
  Collection := Internal_DataModule.DataSets;

  str := TStringList.Create;
  try
    str.Text := Value;

    for s in str do
      if trim(s) <> '' then
        if trim(s) <> TextHeader then

        begin
          SplitSourceLine(s, DatasetName, TableName, MenuCaption, MenuGroup, MenuVisible);

          CurrentLevel := GetLevel(s);
          if LastLevel = -1 then
            LastLevel := CurrentLevel;

          if CurrentLevel = 0 then
            Collection := Internal_DataModule.DataSets
          else
            if CurrentLevel = LastLevel then // sono allo stesso livello
            begin
            end
            else
              if CurrentLevel > LastLevel then // � un detail
              begin
                Collection := zDiagramDataSet.DetailDataSets;
              end
              else
                if CurrentLevel < LastLevel then // si cerca il master appropriato (pu� essere un salto di pi� livelli
                begin
                  for I := 0 to (LastLevel - CurrentLevel) do
                  begin
                    if Assigned(zDiagramDataSet) then
                      zDiagramDataSet := zDiagramDataSet.MasterDataSet;

                    if Assigned(zDiagramDataSet) then
                      Collection := zDiagramDataSet.DetailDataSets
                    else
                    begin
                      Collection := Internal_DataModule.DataSets;
                      Break;
                    end;
                  end;
                end;

          LastLevel := CurrentLevel;

          idx := Collection.IndexOf(DatasetName);
          if idx = -1 then
          begin
            zDiagramDataSet := Collection.Add;

            if zDiagramDataSet.DbViews.count = 1 then
            begin
              zDiagramDataSet.DbViews[0].Caption := MenuCaption;
              zDiagramDataSet.DbViews[0].zDbViewProps(True).Title := MenuCaption;
            end;
          end
          else
            zDiagramDataSet := Collection[idx];

          zDiagramDataSet.Name := DatasetName;

          siMain.LogColored(clred, DatasetName);

          SetDataSetCaption(zDiagramDataSet, MenuCaption);
          zDiagramDataSet.Menu.Group := MenuGroup;
          zDiagramDataSet.Menu.Visible := MenuVisible;
          zDataSet := zDiagramDataSet.zDataSet(True);
          // crea se non esiste
          zDataSet.TableName := TableName;
          zDataSet.SQL_Select.Text := Build_Sql_Select(zSystem.Metadata, zDataSet.TableName, nil);

          MasterTableName := '';
          if Collection.HasMaster then
            MasterTableName := Collection.MasterDataSet.zDataSet.TableName;

          if MasterTableName <> '' then
            zDataSet.SQL_Select.Text := Build_FkRelation(zSystem.Metadata, zDataSet.SQL_Select.Text, zDataSet.TableName, MasterTableName);
        end;
  finally
    FreeAndNil(str);
  end;
  //
  FillTree;
end;

procedure TFrameEditor_DataModule.ApplicaBorderStyleExecute(Sender: TObject);
var
  p: TzDiagramDataSets.TEnumProc;
begin
  inherited;

  p := procedure(zDiagramDataSet: TzDiagramDataSet)
    var
      I: Integer;
      zDbViewProps: TzDbViewProps;
    begin
      if not Assigned(zSystem) then
        Exit;

      // view
      for I := 0 to zDiagramDataSet.DbViews.count - 1 do
        zDiagramDataSet.DbViews[I].zDbViewProps(True).Flags.Border := Internal_DataModule.ControllerOptions.UsePageControl;
      // card
      // cube
      // Pdf
      // gis
    end;

  enum(nil, p, 'Sovrascrivere il BorderStyle di tutti i controlli?');
end;

procedure TFrameEditor_DataModule.enum(zDiagramDataSet: TzDiagramDataSet; proc: TzDiagramDataSets.TEnumProc; const Msg: string);
begin

  if ConfirmYesNo(Msg) then
  begin
    StartWait('Attendere...', True);
    try

      if Assigned(zDiagramDataSet) then
      begin
        proc(zDiagramDataSet);
        if zDiagramDataSet.HasDetailDataSets then
          zDiagramDataSet.DetailDataSets.enum(proc);
      end
      else
        Internal_DataModule.DataSets.enum(proc);

      zSystem.SaveZip(csAll, 'TFrameEditor_DataModule.Enum');
    finally
      StopWait;
    end;
  end;
end;

function TFrameEditor_DataModule.MenuCaption(const TableName: string): string;
begin
  result := TableName;

  if result.StartsWith('ZZ_') then
    result := result.Replace('ZZ_', '');

  // Package
  result := result.Replace('.', ' ', [rfReplaceAll]);

  result := zzCapFirst(result, True);
end;

procedure TFrameEditor_DataModule.SetDataSetCaption(zDiagramDataSet: TzDiagramDataSet; const Caption: string);
var
  I: Integer;
begin
  zDiagramDataSet.Menu.Caption := Caption;

  for I := 0 to zDiagramDataSet.DbViews.count - 1 do
  begin
    zDiagramDataSet.DbViews[I].Caption := Caption;
    zDiagramDataSet.DbViews[I].zDbViewProps(True).Title := Caption;
  end; // \view
  /// //////////////////////
  // card
  for I := 0 to zDiagramDataSet.DbCards.count - 1 do
  begin
    zDiagramDataSet.DbCards[I].Caption := Caption;
    zDiagramDataSet.DbCards[I].zDbCardProps(True).Caption := Caption;
    zDiagramDataSet.DbCards[I].zDbCardProps(True).Title := Caption;
  end; // \card
  /// //////////////////////
  // vista record
  for I := 0 to zDiagramDataSet.DbRecordViews.count - 1 do
  begin
    zDiagramDataSet.DbRecordViews[I].Caption := Caption;
    zDiagramDataSet.DbRecordViews[I].zDbRecordViewProps(True).Caption := Caption;
    zDiagramDataSet.DbRecordViews[I].zDbRecordViewProps(True).Title := Caption;
  end; // \vista record
  /// //////////////////////
  // albero
  for I := 0 to zDiagramDataSet.DbTrees.count - 1 do
  begin
    zDiagramDataSet.DbTrees[I].Caption := Caption;
    zDiagramDataSet.DbTrees[I].zDbTreeProps(True).Caption := Caption;
    zDiagramDataSet.DbTrees[I].zDbTreeProps(True).Title := Caption;
  end; // \albero
  /// //////////////////////
  // grafico
  for I := 0 to zDiagramDataSet.DbCharts.count - 1 do
  begin
    zDiagramDataSet.DbCharts[I].Caption := Caption;
    zDiagramDataSet.DbCharts[I].zDbChartProps(True).Caption := Caption;
    zDiagramDataSet.DbCharts[I].zDbChartProps(True).Title := Caption;
  end; // \grafico
  /// //////////////////////
  // calendario
  for I := 0 to zDiagramDataSet.DbSchedulers.count - 1 do
  begin
    zDiagramDataSet.DbSchedulers[I].Caption := Caption;
    zDiagramDataSet.DbSchedulers[I].zDbSchedulerProps(True).Caption := Caption;
    zDiagramDataSet.DbSchedulers[I].zDbSchedulerProps(True).Title := Caption;
  end; // \calendario
end;

procedure TFrameEditor_DataModule.BuildGUIExecute(Sender: TObject);
begin
  inherited;
  Internal_DataModule.BuildGUI := BuildGUI.Checked;
end;

procedure TFrameEditor_DataModule.ApplicaCaptionExecute(Sender: TObject);
var
  p: TzDiagramDataSets.TEnumProc;
begin
  inherited;

  p := procedure(zDiagramDataSet: TzDiagramDataSet)
    var
      I: Integer;
      idx: Integer;
      zDbViewProps: TzDbViewProps;
    begin
      if not Assigned(zSystem) then
        Exit;
      /// //////////////////////
      // view
      for I := 0 to zDiagramDataSet.DbViews.count - 1 do
      begin
        if zDiagramDataSet.DbViews[I].Caption = zDiagramDataSet.DbViews[I].Name then
          zDiagramDataSet.DbViews[I].Caption := zDiagramDataSet.DbViews[I].zDiagramDataSet.Menu.Caption;

        zDiagramDataSet.DbViews[I].zDbViewProps(True).Title := zDiagramDataSet.DbViews[I].Caption;
      end; // \view
      /// //////////////////////
      // card
      for I := 0 to zDiagramDataSet.DbCards.count - 1 do
      begin
        if zDiagramDataSet.DbCards[I].Caption = zDiagramDataSet.DbCards[I].Name then
          zDiagramDataSet.DbCards[I].Caption := zDiagramDataSet.DbCards[I].zDiagramDataSet.Menu.Caption;

        zDiagramDataSet.DbCards[I].zDbCardProps(True).Caption := zDiagramDataSet.DbCards[I].Caption;
        zDiagramDataSet.DbCards[I].zDbCardProps(True).Title := zDiagramDataSet.DbCards[I].Caption;
      end; // \card
      /// //////////////////////
      // vista record
      for I := 0 to zDiagramDataSet.DbRecordViews.count - 1 do
      begin
        if zDiagramDataSet.DbRecordViews[I].Caption = zDiagramDataSet.DbRecordViews[I].Name then
          zDiagramDataSet.DbRecordViews[I].Caption := zDiagramDataSet.DbRecordViews[I].zDiagramDataSet.Menu.Caption;

        zDiagramDataSet.DbRecordViews[I].zDbRecordViewProps(True).Caption := zDiagramDataSet.DbRecordViews[I].Caption;
        zDiagramDataSet.DbRecordViews[I].zDbRecordViewProps(True).Title := zDiagramDataSet.DbRecordViews[I].Caption;
      end; // \vista record
      /// //////////////////////
      // albero
      for I := 0 to zDiagramDataSet.DbTrees.count - 1 do
      begin
        if zDiagramDataSet.DbTrees[I].Caption = zDiagramDataSet.DbTrees[I].Name then
          zDiagramDataSet.DbTrees[I].Caption := zDiagramDataSet.DbTrees[I].zDiagramDataSet.Menu.Caption;

        zDiagramDataSet.DbTrees[I].zDbTreeProps(True).Caption := zDiagramDataSet.DbTrees[I].Caption;
        zDiagramDataSet.DbTrees[I].zDbTreeProps(True).Title := zDiagramDataSet.DbTrees[I].Caption;
      end; // \albero
      /// //////////////////////
      // grafico
      for I := 0 to zDiagramDataSet.DbCharts.count - 1 do
      begin
        if zDiagramDataSet.DbCharts[I].Caption = zDiagramDataSet.DbCharts[I].Name then
          zDiagramDataSet.DbCharts[I].Caption := zDiagramDataSet.DbCharts[I].zDiagramDataSet.Menu.Caption;

        zDiagramDataSet.DbCharts[I].zDbChartProps(True).Caption := zDiagramDataSet.DbCharts[I].Caption;
        zDiagramDataSet.DbCharts[I].zDbChartProps(True).Title := zDiagramDataSet.DbCharts[I].Caption;
      end; // \grafico
      /// //////////////////////
      // calendario
      for I := 0 to zDiagramDataSet.DbSchedulers.count - 1 do
      begin
        if zDiagramDataSet.DbSchedulers[I].Caption = zDiagramDataSet.DbSchedulers[I].Name then
          zDiagramDataSet.DbSchedulers[I].Caption := zDiagramDataSet.DbSchedulers[I].zDiagramDataSet.Menu.Caption;

        zDiagramDataSet.DbSchedulers[I].zDbSchedulerProps(True).Caption := zDiagramDataSet.DbSchedulers[I].Caption;
        zDiagramDataSet.DbSchedulers[I].zDbSchedulerProps(True).Title := zDiagramDataSet.DbSchedulers[I].Caption;
      end; // \calendario

      /// //////////////////////
      // cube
      /// //////////////////////
      // Pdf
      /// //////////////////////
      // gis
      /// //////////////////////
      /// //////////////////////
    end;

  enum(nil, p, 'Sovrascrivere il titolo di tutti i controlli?');
end;

procedure TFrameEditor_DataModule.RipulisciExecute(Sender: TObject);
  function ExtractDataSetName(const Name: string): string;
  begin
    result := Name;

    if pos('.', result) > 0 then
      result := System.Copy(result, pos('.', result) + 1);
  end;

  function DataSetExists(const DatasetName: string): Boolean;
  begin
    result := Internal_DataModule.DataSets.DataSetExists(DatasetName);
  end;

var
  DataModuleName: string;
  DatasetName: string;
  I: Integer;
  stringList: TStringList;

begin
  inherited;

  if not ConfirmYesNo('Eliminare Dataset, View, Card, Record, Alberi, Grafici e Calendari non più presenti nel Datamodule?', mtWarning) then
    Exit;

  DataModuleName := Internal_DataModule.Name + '.';

  stringList := TStringList.Create;
  try
    /// ////////////////////////////////////////////////////
    /// ////////////////////////////////////////////////////
    /// ////////////////////////////////////////////////////
    // DataSet
    for I := zSystem.zDataSets.count - 1 downto 0 do
      if StartingWith(zSystem.zDataSets[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDataSets[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('DataSet: ' + zSystem.zDataSets[I].Name);
          zSystem.zDataSets.Delete(I);
        end;
      end;
    /// ////////////////////////////////////////////////////
    // View
    for I := zSystem.zDbViews.count - 1 downto 0 do
      if StartingWith(zSystem.zDbViews[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDbViews[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('dbView: ' + zSystem.zDbViews[I].Name);
          zSystem.zDbViews.Delete(I);
        end;
      end;
    /// ////////////////////////////////////////////////////
    // Card
    for I := zSystem.zDbCards.count - 1 downto 0 do
      if StartingWith(zSystem.zDbCards[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDbCards[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('dbCard: ' + zSystem.zDbCards[I].Name);
          zSystem.zDbCards.Delete(I);
        end;
      end;
    /// ////////////////////////////////////////////////////
    // Vista record
    for I := zSystem.zDbRecordViews.count - 1 downto 0 do
      if StartingWith(zSystem.zDbRecordViews[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDbRecordViews[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('dbRecordView: ' + zSystem.zDbRecordViews[I].Name);
          zSystem.zDbRecordViews.Delete(I);
        end;
      end;
    /// ////////////////////////////////////////////////////
    // Albero
    for I := zSystem.zDbTrees.count - 1 downto 0 do
      if StartingWith(zSystem.zDbTrees[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDbTrees[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('dbTree: ' + zSystem.zDbTrees[I].Name);
          zSystem.zDbTrees.Delete(I);
        end;
      end;
    /// ////////////////////////////////////////////////////
    // Grafico
    for I := zSystem.zDbCharts.count - 1 downto 0 do
      if StartingWith(zSystem.zDbCharts[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDbCharts[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('dbChart: ' + zSystem.zDbCharts[I].Name);
          zSystem.zDbCharts.Delete(I);
        end;
      end;
    /// ////////////////////////////////////////////////////
    // Calendario
    for I := zSystem.zDbSchedulers.count - 1 downto 0 do
      if StartingWith(zSystem.zDbSchedulers[I].Name, DataModuleName) then
      begin
        DatasetName := ExtractDataSetName(zSystem.zDbSchedulers[I].Name);

        if not DataSetExists(DatasetName) then
        begin
          stringList.Add('dbScheduler: ' + zSystem.zDbSchedulers[I].Name);
          zSystem.zDbSchedulers.Delete(I);
        end;
      end;

    /// ////////////////////////////////////////////////////
    /// ////////////////////////////////////////////////////
    /// ////////////////////////////////////////////////////
    if stringList.count = 0 then
      ConfirmOk('Nessun elemento eliminato.')
    else
    begin
      Clipboard.AsText := stringList.Text;
      ConfirmOk('Eliminati: ' + #13#10 + stringList.Text);
      ConfirmOk('Per rispristinarli chiudere la form senza salvare.');
    end;
  finally
    FreeAndNil(stringList);
  end;
end;

procedure TFrameEditor_DataModule.Node2DataSet(Node: TcxTreeListNode; zDiagramDataSet: TzDiagramDataSet);
var
  zDataSet: TzDataSet;
begin
  Assert(Assigned(Node));
  Assert(Assigned(zDiagramDataSet));

  // colCaption
  // colGroup
  // colVisible
  // colReportGroup
  // colPipeName
  // colSharedReports
  // colViews
  // colCards
  // colCubes
  // colFileViewers
  // colGoogleMaps

  zDiagramDataSet.Name := VarToStr(Node.Values[colName.VisibleIndex]);
  zDiagramDataSet.Menu.Caption := VarToStr(Node.Values[colCaption.VisibleIndex]);
  zDiagramDataSet.Menu.Group := VarToStr(Node.Values[colGroup.VisibleIndex]);
  zDiagramDataSet.Menu.Visible := Node.Values[colVisible.VisibleIndex];
  zDiagramDataSet.IsLookupDataSet := Node.Values[colLookup.VisibleIndex];
  zDiagramDataSet.ReportProps.ReportGroup := VarToStr(Node.Values[colReportGroup.VisibleIndex]);
  zDiagramDataSet.ReportProps.PipeName := VarToStr(Node.Values[colPipeName.VisibleIndex]);
  zDiagramDataSet.ReportProps.SharedReports.Text := VarToStr(Node.Values[colSharedReports.VisibleIndex]);

  // forza le caption di view/card
  SetDataSetCaption(zDiagramDataSet, zDiagramDataSet.Menu.Caption);

  //
  zDataSet := zDiagramDataSet.zDataSet();
  if Assigned(zDataSet) then
    zDataSet.ReportPipe := zDiagramDataSet.ReportProps.PipeName;
end;

procedure TFrameEditor_DataModule.Dataset2Node(Node: TcxTreeListNode; zDiagramDataSet: TzDiagramDataSet);
begin
  Assert(Assigned(Node));
  Assert(Assigned(zDiagramDataSet));

  tree.HideEdit;

  // SetupDataSetNode(Node, zDiagramDataSet);
  // colName
  // colCaption
  // colGroup
  // colVisible
  // colReportGroup
  // colPipeName
  // colSharedReports
  // colViews
  // colCards
  // colCubes
  // colFileViewers
  // colGoogleMaps
  Node.Values[colName.VisibleIndex] := zDiagramDataSet.Name;
  Node.Values[colCaption.VisibleIndex] := zDiagramDataSet.Menu.Caption;
  Node.Values[colGroup.VisibleIndex] := zDiagramDataSet.Menu.Group;
  Node.Values[colVisible.VisibleIndex] := zDiagramDataSet.Menu.Visible;
  Node.Values[colLookup.VisibleIndex] := zDiagramDataSet.IsLookupDataSet;
  Node.Values[colReportGroup.VisibleIndex] := zDiagramDataSet.ReportProps.ReportGroup;
  Node.Values[colPipeName.VisibleIndex] := zDiagramDataSet.ReportProps.PipeName;
  Node.Values[colSharedReports.VisibleIndex] := zDiagramDataSet.ReportProps.SharedReports.Text;
  Node.Values[colViews.VisibleIndex] := zDiagramDataSet.DbViews.count.ToString;
  Node.Values[colCards.VisibleIndex] := zDiagramDataSet.DbCards.count.ToString;
  Node.Values[colCubes.VisibleIndex] := zDiagramDataSet.DbPivots.count.ToString;
  Node.Values[colFileViewers.VisibleIndex] := zDiagramDataSet.DbFiles.count.ToString;
  Node.Values[colGoogleMaps.VisibleIndex] := zDiagramDataSet.GisMaps.count.ToString;
  Node.Values[colRecordViews.VisibleIndex] := zDiagramDataSet.DbRecordViews.count.ToString;
  Node.Values[colTrees.VisibleIndex] := zDiagramDataSet.DbTrees.count.ToString;
  Node.Values[colCharts.VisibleIndex] := zDiagramDataSet.DbCharts.count.ToString;
  Node.Values[colSchedulers.VisibleIndex] := zDiagramDataSet.DbSchedulers.count.ToString;
  Node.Data := zDiagramDataSet;
end;

function TFrameEditor_DataModule.DataSetExists(Const DatasetName: String): Boolean;
begin
  result := Assigned(GetDataSetNode(DatasetName));
end;

procedure TFrameEditor_DataModule.FillTree;
var
  I: Integer;
  sub: string;

  procedure AddItem(MasterNode: TcxTreeListNode; zDiagramDataSet: TzDiagramDataSet);
  var
    I: Integer;
    Node: TcxTreeListNode;
  begin
    Node := tree.AddChild(MasterNode, zDiagramDataSet);

    Dataset2Node(Node, zDiagramDataSet);

    for I := 0 to zDiagramDataSet.DetailDataSets.count - 1 do
      AddItem(Node, zDiagramDataSet.DetailDataSets[I]);
  end;

begin
  tree.BeginUpdate;
  try
    tree.Clear;

    for I := 0 to Internal_DataModule.DataSets.count - 1 do
      if Internal_DataModule.DataSets[I].HasChild then
        AddItem(tree.Root, Internal_DataModule.DataSets[I]);

    for I := 0 to Internal_DataModule.DataSets.count - 1 do
      if not Internal_DataModule.DataSets[I].HasChild then
        AddItem(tree.Root, Internal_DataModule.DataSets[I]);

    tree.Root.Focused := True;
    tree.OptionsView.ShowRoot := True;

    tree.FullExpand;
  finally
    tree.EndUpdate;
  end;

  tree.ApplyBestFit;

  LoadTreeMenu;
end;

function TFrameEditor_DataModule.FocusDataSetNode(const DatasetName: String): Boolean;
var
  Node: TcxTreeListNode;
begin
  result := false;

  Node := GetDataSetNode(DatasetName);

  if Assigned(Node) then
  begin
    Node.Focused := True;
    Node.MakeVisible;
    result := True;
  end;
end;

procedure TFrameEditor_DataModule.treeDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  I: Integer;
  TreeNode: TTreeNode;
  Node: TcxTreeListNode;
  TableName: string;
begin
  // if (Source is TcxDragControlObject) and ((Source as TcxDragControlObject).Control = TreeView) then
  if (Source is TcxTreeView) or ((Source is TDragControlObject) and (TDragControlObject(Source).Control = MetaTree)) then
  begin
    Node := tree.GetNodeAt(X, Y);

    if not Assigned(Node) then
      // Exit;
      Node := tree.Root;

    for I := 0 to MetaTree.SelectionCount - 1 do
    begin
      TreeNode := MetaTree.Selections[I];
      if not((TreeNode = nil) or (TreeNode.Level <> 1)) then
        CreateDataSet(Node, TreeNode.Text);
    end;
  end
  else
    if Source = tree then
    begin
      tree.OnDragDrop := nil;
      tree.DragDrop(tree, X, Y);
      tree.OnDragDrop := treeDragDrop;
      CancelDrag;
      Abort;
    end;
end;

procedure TFrameEditor_DataModule.treeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited;
  Accept := (Source = tree) or (Source = MetaTree);

  if not Accept then
    if Source is TDragControlObject then
      Accept := TDragControlObject(Source).Control = MetaTree;
end;

procedure TFrameEditor_DataModule.treeEdited(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
var
  Node: TcxTreeListNode;
  zDiagramDataSet: TzDiagramDataSet;
begin
  inherited;

  Node := tree.FocusedNode;

  if Assigned(Node) then
  begin
    zDiagramDataSet := GetDataSet(Node);
    Node2DataSet(Node, zDiagramDataSet);
    LoadTreeMenu;
  end;
end;

procedure TFrameEditor_DataModule.treeGetDragDropText(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var AText: string);
begin
  inherited;
  if Assigned(ANode) then
    AText := ANode.Texts[0];
end;

procedure TFrameEditor_DataModule.colNamePropertiesEditValueChanged(Sender: TObject);
var
  Node: TcxTreeListNode;
  DatasetName: string;
begin
  inherited;
  Node := tree.FocusedNode;
  DatasetName := VarToStr(Node.Values[colName.VisibleIndex]);
  DatasetName := ComponentName(DatasetName);
  Node.Values[colName.VisibleIndex] := DatasetName;
end;

procedure TFrameEditor_DataModule.colPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  zDiagramDataSet: TzDiagramDataSet;
begin
  inherited;

  zDiagramDataSet := GetDataSet(tree.FocusedNode);

  if Assigned(zDiagramDataSet) then
    if Edit_zCollections([zDiagramDataSet.DbViews, zDiagramDataSet.DbCards, zDiagramDataSet.DbPivots, zDiagramDataSet.DbRecordViews, zDiagramDataSet.DbTrees, zDiagramDataSet.DbCharts, zDiagramDataSet.DbSchedulers, zDiagramDataSet.DbFiles,
      zDiagramDataSet.GisMaps],
      procedure(form: TzFormCollection)
      begin
        form.FrameCollection.FullExpand;
        form.FrameCollection.ImageList := CollectionImageList;
        form.FrameCollection.TreeListWidth := 150;
      end) then
      Dataset2Node(tree.FocusedNode, zDiagramDataSet);
end;

procedure TFrameEditor_DataModule.treeEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  SincronizzaDataSets;
end;

procedure TFrameEditor_DataModule.doSincronizzaDataSets;

  procedure applyMD(Node: TcxTreeListNode);
  var
    I: Integer;
    CurrentDataSet, NewDataSet, CurrentMaster, NewMaster: TzDiagramDataSet;
    DatasetName: string;
  begin

    CurrentDataSet := GetDataSet(Node);

    if Assigned(CurrentDataSet) then
    begin
      CurrentMaster := CurrentDataSet.MasterDataSet;

      if CurrentDataSet.Name <> '' then
      begin
        NewMaster := GetDataSet(Node.Parent);

        if CurrentMaster <> NewMaster then
        begin
          if Assigned(NewMaster) then
            CurrentDataSet.Collection := NewMaster.DetailDataSets
          else
            CurrentDataSet.Collection := Internal_DataModule.DataSets;
        end;
      end;
    end;

    for I := Node.count - 1 downto 0 do
      applyMD(Node.Items[I]);
  end;

  procedure applyIndex(Node: TcxTreeListNode);
  var
    I: Integer;
    zDiagramDataSet: TzDiagramDataSet;
  begin

    zDiagramDataSet := GetDataSet(Node);

    if Assigned(zDiagramDataSet) then
      zDiagramDataSet.index := Node.index;

    for I := Node.count - 1 downto 0 do
      applyIndex(Node.Items[I]);
  end;

var
  I: Integer;
begin
  // M/D
  for I := tree.Root.count - 1 downto 0 do
    applyMD(tree.Root.Items[I]);
  // Index
  for I := tree.Root.count - 1 downto 0 do
    applyIndex(tree.Root.Items[I]);

  LoadTreeMenu;
end;

procedure TFrameEditor_DataModule.MessageHandler(var Message: TMessage);
begin
  inherited;
  doSincronizzaDataSets;
end;

procedure TFrameEditor_DataModule.SincronizzaDataSets;
begin
  PostMessage(Self.Handle, msgSincronizzaDataSet, 0, 0);
end;

procedure TFrameEditor_DataModule.treeDblClick(Sender: TObject);
begin
  inherited;

  if CtrlKey then
    ModificaDataSet.Execute;
end;

procedure TFrameEditor_DataModule.treeGetNodeImageIndex(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; AIndexType: TcxTreeListImageIndexType; var AIndex: TImageIndex);
var
  DataSet: TzDiagramDataSet;
begin
  inherited;

  DataSet := GetDataSet(ANode);

  if not Assigned(DataSet) then
    Exit;

  if DataSet.HasDetailDataSets then
    AIndex := 0
  else
    if DataSet.IsLookupDataSet then
      AIndex := 1
    else
      if not DataSet.Menu.Visible then
        AIndex := 2
      else
        AIndex := 3; // normale
end;

procedure TFrameEditor_DataModule.TreeMenuDblClick(Sender: TObject);
begin

  if FocusDataSetNode(TreeMenu.Selected) then
    ModificaDataSet.Execute;
end;

procedure TFrameEditor_DataModule.TreeMenuSelect(Sender: TObject);
begin
  FocusDataSetNode(TreeMenu.Selected);
end;

procedure TFrameEditor_DataModule.TreeMenuWidthChanged(Sender: TObject; const NewWidth: Integer);
begin
  // na palla...
  // pnlLeft.ClientWidth := min(NewWidth + 1, 150);
end;

procedure TFrameEditor_DataModule.ModificaDataSetExecute(Sender: TObject);
var
  zDiagramDataSet: TzDiagramDataSet;
  zDataSet: TzDataSet;
  subDataModuleName: String;
  subDataModule: TzDataModule;
begin

  zDiagramDataSet := GetDataSet(tree.FocusedNode);
  if Assigned(zDiagramDataSet) then
  begin
    zDataSet := zDiagramDataSet.zDataSet;

    if Assigned(zDataSet) then
      Edit_CollectionItem(zSystem, zDataSet);
  end;
end;

procedure TFrameEditor_DataModule.EliminaDataSetExecute(Sender: TObject);
var
  zDiagramDataSet: TzDiagramDataSet;
begin

  if Assigned(tree.FocusedNode) then
    if ConfirmYesNo('Eliminare il dataset ' + tree.FocusedNode.Texts[0] + '?') then
    begin
      DeletingDataSet := True;
      try
        zDiagramDataSet := GetDataSet(tree.FocusedNode);

        tree.FocusedNode.Delete;

        if Assigned(zDiagramDataSet) then
          zDiagramDataSet.Free;
      finally
        DeletingDataSet := false;
      end;
      LoadTreeMenu;
    end;
end;

procedure TFrameEditor_DataModule.NuovoDataSetExecute(Sender: TObject);
var
  TableName: string;
begin
  if InputQuery('Dataset', 'Nome', TableName) then
    CreateDataSet(tree.FocusedNode, TableName);
end;

procedure TFrameEditor_DataModule.treeFocusedNodeChanged(Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
var
  zDiagramDataSet: TzDiagramDataSet;
begin
  inherited;

  if DeletingDataSet then
    Exit;

  zDiagramDataSet := GetDataSet(AFocusedNode);
  if Assigned(zDiagramDataSet) then
  begin
    TreeMenu.SelectDataSet(zDiagramDataSet.Name, false);
  end;
end;

procedure TFrameEditor_DataModule.colVisiblePropertiesEditValueChanged(Sender: TObject);
begin
  inherited;
  treeEdited(nil, nil);
end;

function TFrameEditor_DataModule.ComponentName(const Name: string): string;

  function ValidateComponentName(Name: string): string;
  const
    Alpha = ['A' .. 'Z', 'a' .. 'z', '_'];
    AlphaNumeric = Alpha + ['0' .. '9'];
  var
    I: Integer;
  begin
    result := Name;
    for I := 1 to length(result) do
      if not(result[I] in AlphaNumeric) then
        result[I] := '_';
  end;

  function UniqueDataSetName(const Name: string): string;
  var
    BaseName: string;
    I: Integer;
  begin
    result := zzCapFirst(name, false);

    I := 0;
    while DataSetExists(result) do
    begin
      inc(I);
      result := BaseName + '_' + inttostr(I);
    end;
  end;

begin
  result := UniqueDataSetName(ValidateComponentName(zzCapFirst(Name, false)));
end;

procedure TFrameEditor_DataModule.TreeMenuDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = tree) or (Source = MetaTree);

  if not Accept then
    if Source is TDragControlObject then
      Accept := TDragControlObject(Source).Control = MetaTree;
end;

procedure TFrameEditor_DataModule.TreeMenuDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  I: Integer;
  TreeNode: TTreeNode;
  SrcNode, DestNode: TcxTreeListNode;
  TableName: string;
  DatasetName: string;
begin
  // if (Source is TcxDragControlObject) and ((Source as TcxDragControlObject).Control = TreeView) then
  if (Source is TcxTreeView) or ((Source is TDragControlObject) and (TDragControlObject(Source).Control = MetaTree)) then
  begin
    // cercare il nodo corrispondente
    DatasetName := TreeMenu.GetDatasetNameAt(X, Y);

    if DatasetName = '' then
      DestNode := nil
    else
      DestNode := GetDataSetNode(DatasetName);

    for I := 0 to MetaTree.SelectionCount - 1 do
    begin
      TreeNode := MetaTree.Selections[I];
      if not((TreeNode = nil) or (TreeNode.Level <> 1)) then
        CreateDataSet(DestNode, TreeNode.Text);
    end;
  end
  else
    if Source = tree then
    begin
      DatasetName := TreeMenu.GetDatasetNameAt(X, Y);

      if DatasetName = '' then
        Exit;

      DestNode := GetDataSetNode(DatasetName);

      SrcNode := tree.FocusedNode;

      if Assigned(SrcNode) then
        if Assigned(DestNode) then
          if SrcNode <> DestNode then
            SrcNode.MoveTo(DestNode, tlamAddChild);

      // Node := GetDataSetNode(DatasetName);
      //
      // if not Assigned(Node) then
      // Exit;
      //
      // for I := 0 to MetaTree.SelectionCount - 1 do
      // begin
      // TreeNode := MetaTree.Selections[I];
      // if not((TreeNode = nil) or (TreeNode.Level <> 1)) then
      // CreateDataSet(Node, TreeNode.Text);
    end;
end;

procedure TFrameEditor_DataModule.ModificabileExecute(Sender: TObject);
begin
  inherited;

  if ConfirmYesNo('Si desidera rendere modificabili tutti i dataset?') then
    EnumReadonly(false);
end;

procedure TFrameEditor_DataModule.SolaLetturaExecute(Sender: TObject);
begin
  inherited;

  if ConfirmYesNo('Si desidera rendere di sola lettura tutti i dataset?') then
    EnumReadonly(True);
end;

procedure TFrameEditor_DataModule.EnumReadonly(const ReadOnly: Boolean);

  procedure SetReadOnly(zDiagramDataSet: TzDiagramDataSet; const ReadOnly: Boolean);
  var
    DetailDataSet: TzDiagramDataSet;
    dbCtrl: TzDiagramDataSet.TzDiagramCtrl;
  begin
    for dbCtrl in zDiagramDataSet.DbViews do
      dbCtrl.SetReadOnly(ReadOnly);

    for dbCtrl in zDiagramDataSet.DbCards do
      dbCtrl.SetReadOnly(ReadOnly);

    for dbCtrl in zDiagramDataSet.DbRecordViews do
      dbCtrl.SetReadOnly(ReadOnly);

    for dbCtrl in zDiagramDataSet.DbTrees do
      dbCtrl.SetReadOnly(ReadOnly);

    for dbCtrl in zDiagramDataSet.DbCharts do
      dbCtrl.SetReadOnly(ReadOnly);

    for dbCtrl in zDiagramDataSet.DbSchedulers do
      dbCtrl.SetReadOnly(ReadOnly);

    for DetailDataSet in zDiagramDataSet.DetailDataSets do
      SetReadOnly(DetailDataSet, ReadOnly);
  end;

var
  zDiagramDataSet: TzDiagramDataSet;
begin

  StartWait('Attendere...');
  try
    for zDiagramDataSet in Internal_DataModule.DataSets do
      SetReadOnly(zDiagramDataSet, ReadOnly);
  finally
    StopWait;
  end;
end;

procedure TFrameEditor_DataModule.MuoviAllaRadiceExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
begin
  inherited;

  Node := tree.FocusedNode;

  if Assigned(Node) then
  begin
    Node.MoveTo(tree.Items[0], tlamAdd);
    SincronizzaDataSets;
  end;
end;

procedure TFrameEditor_DataModule.SpostaInAltoExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
  Prev: TcxTreeListNode;
begin
  inherited;

  Node := tree.FocusedNode;

  if Assigned(Node) then
  begin
    Prev := Node.GetPrevSiblingVisible;

    if Assigned(Prev) then
    begin
      Node.MoveTo(Prev, tlamInsert);
      SincronizzaDataSets;
    end;
  end;
end;

procedure TFrameEditor_DataModule.SpostaInBassoExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
  Next: TcxTreeListNode;
begin
  inherited;

  Node := tree.FocusedNode;

  if Assigned(Node) then
  begin
    Next := Node.GetNextSiblingVisible;

    if Assigned(Next) then
    begin
      Node.MoveTo(Next, tlamAdd);
      SincronizzaDataSets;
    end;
  end;
end;

procedure TFrameEditor_DataModule.pnlSpostaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ResizingPnlSposta := True;
  SetCapture(pnlSposta.Handle);
  GetCursorPos(oldPos);
end;

procedure TFrameEditor_DataModule.pnlSpostaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
const
  MinWidth = 20;
  minHeight = 20;
var
  newPos: TPoint;
  frmPoint: TPoint;
begin
  if ResizingPnlSposta then
  begin
    GetCursorPos(newPos);
    if ssShift in Shift then
    begin // resize
      Screen.Cursor := crSizeNWSE;
      frmPoint := ScreenToClient(Mouse.CursorPos);
      if frmPoint.X > MinWidth then
        width := frmPoint.X;
      if frmPoint.Y > minHeight then
        Height := frmPoint.Y;
    end
    else // move
    begin
      Screen.Cursor := crSize;
      Left := Left - oldPos.X + newPos.X;
      Top := Top - oldPos.Y + newPos.Y;
      oldPos := newPos;
    end;
  end;
end;

procedure TFrameEditor_DataModule.pnlSpostaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ResizingPnlSposta then
  begin
    Screen.Cursor := crDefault;
    ReleaseCapture;
    ResizingPnlSposta := false;
  end;
end;

procedure TFrameEditor_DataModule.treeSpostaDblClick(Sender: TObject);
begin
  Sposta.Execute;
end;

procedure TFrameEditor_DataModule.cxBarEditItemSpostaPropertiesInitPopup(Sender: TObject);
  function GetParentNode(ParentNode: TTreeNode; Group: string): TTreeNode;
  var
    I: Integer;
  begin
    result := nil;

    if Group = '' then
      result := ParentNode
    else
    begin
      if Assigned(ParentNode) then
      begin
        for I := 0 to ParentNode.count - 1 do
          if SameText(ParentNode[I].Text, Group) then
            Exit(ParentNode[I]);
      end
      else
      begin
        for I := 0 to treeSposta.Items.count - 1 do
          if SameText(treeSposta.Items[I].Text, Group) then
            Exit(treeSposta.Items[I]);
      end;
    end;
  end;

  procedure enum(ParentNode: TTreeNode; zDiagramDataSets: TzDiagramDataSets);
  var
    I: Integer;
    Item: TzDiagramDataSet;
    Node: TTreeNode;
    RealParentNode: TTreeNode;
  begin

    for I := 0 to zDiagramDataSets.count - 1 do
    begin
      Item := zDiagramDataSets.Items[I];

      if Item.Menu.Visible then
      begin
        RealParentNode := GetParentNode(ParentNode, Item.Menu.GetGroup);

        // se non esiste lo crea
        if not Assigned(RealParentNode) then
          if not Item.Menu.GetGroup.IsEmpty then
          begin
            RealParentNode := treeSposta.Items.AddChild(ParentNode, Item.Menu.GetGroup);
            RealParentNode.ImageIndex := 0;
            RealParentNode.SelectedIndex := 0;
          end;

        Node := treeSposta.Items.AddChildObject(RealParentNode, Item.Menu.GetCaption, Item);

        /// //////////////////////////////////////////////////////////////////////////

        Node.SelectedIndex := 3;
        Node.ImageIndex := 2; // default
        // se non è foglia finale, cioè se ha details
        if not Item.IsMenuLeaf then
        begin
          Node.ImageIndex := 1;
          Node.SelectedIndex := 1;
          enum(Node, Item.DetailDataSets);
        end;
      end;
    end;
  end;

begin;
  treeSposta.Items.BeginUpdate;
  try
    treeSposta.Items.Clear;

    enum(nil, Internal_DataModule.DataSets);
    treeSposta.FullExpand;

    if treeSposta.Items.count > 0 then
    begin
      treeSposta.Items[0].MakeVisible;
      treeSposta.Items[0].Focused := True;
      treeSposta.Items[0].Selected := True;
    end;

  finally
    treeSposta.Items.EndUpdate;
  end;
end;

procedure TFrameEditor_DataModule.ProprietaExecute(Sender: TObject);
var
  zDiagramDataSet: TzDiagramDataSet;

begin
  inherited;

  zDiagramDataSet := GetDataSet(tree.FocusedNode);
  if Assigned(zDiagramDataSet) then
    zDiagramDataSet.Inspect;
end;

procedure TFrameEditor_DataModule.SpostaExecute(Sender: TObject);

  function FindNode(Item: TzDiagramDataSet): TcxTreeListNode;
  var
    I: Integer;
  begin
    result := nil;
    for I := 0 to tree.AbsoluteCount - 1 do
      if TzDiagramDataSet(tree.AbsoluteItems[I].Data) = Item then
      begin
        result := tree.AbsoluteItems[I];
        Break;
      end;
  end;

var
  DestNode: TcxTreeListNode;
  Item: TzDiagramDataSet;
  Items: TzDiagramDataSets;
  I: Integer;
begin
  if not Assigned(treeSposta.Selected) then
    Exit;

  Item := TzDiagramDataSet(treeSposta.Selected.Data);
  Items := Item.DetailDataSets;

  DestNode := FindNode(Item);
  if Assigned(DestNode) then
  begin

    // ciclo for
    for I := tree.SelectionCount - 1 downto 0 do
    begin
      Item := TzDiagramDataSet(tree.Selections[I].Data);
      Item.Collection := Items;
    end;
  end;

  FillTree;

  DestNode := FindNode(Item); // cerca nuovamente dopo il caricamento
  if Assigned(DestNode) then
  begin
    DestNode.Focused := True;
    DestNode.MakeVisible;
  end;

  dxBarManager.HideAll;
end;

procedure TFrameEditor_DataModule.CopiaExecute(Sender: TObject);
begin
  inherited;

  if ConfirmOkCancel('Copiare il datamodule nella clipboard?') then
    Clipboard.AsText := Internal_DataModule.Payload;
end;

procedure TFrameEditor_DataModule.IncollaExecute(Sender: TObject);
begin
  inherited;

  if not ConfirmOkCancel('Sovrascrivere il datamodule?') then
    Exit;

  Internal_DataModule.Payload := Clipboard.AsText;

  /// ///////////////////////////////////////////////////

  FrameObjectInspector.Clear;
  FrameObjectInspector.Add(Internal_DataModule);

  FillTree;
end;

procedure TFrameEditor_DataModule.SalvaSuFileAccept(Sender: TObject);
begin
  inherited;
  TFile.WriteAllText(SalvaSuFile.Dialog.FileName, Internal_DataModule.Payload, TEncoding.UTF8)
end;

procedure TFrameEditor_DataModule.CaricaDaFileAccept(Sender: TObject);
begin
  inherited;

  StartWait('Attendere...', True);
  try
    Internal_DataModule.Payload := TFile.ReadAllText(CaricaDaFile.Dialog.FileName, TEncoding.UTF8);

    FrameObjectInspector.Clear;
    FrameObjectInspector.Add(Internal_DataModule);

    FillTree;
  finally
    StopWait;
  end;
end;

procedure TFrameEditor_DataModule.ResetLayoutExecute(Sender: TObject);
begin
  inherited;

  if ConfirmOkCancel('Resettare il dxLayout della form?') then
    Internal_DataModule.Layouts.Clear;
end;

procedure TFrameEditor_DataModule.VerificaSQLExecute(Sender: TObject);
var
  I: Integer;
  Node: TcxTreeListNode;
  zDiagramDataSet: TzDiagramDataSet;
  zDataSet: TzDataSet;
  Errore: string;
  Verificati: Integer;
  ConErrori: Integer;
  Interrotto: Boolean;

  // Un singolo script: solo Prepare, mai Open. Aprire i dataset di un intero
  // datamodule significherebbe leggere tutte le righe di tutte le tabelle.
  // Restituisce il messaggio del motore, stringa vuota se lo script e' valido
  // oppure non c'e'.
  function ErroreScript(const Tipo, SQL: string): string;
  begin
    result := '';

    if SQL.Trim.IsEmpty then
      Exit;

    ProgressBox.SecondLabel := Tipo;

    qryTest.SQL.Text := SQL;
    try
      qryTest.Prepare;
    except
      on e: Exception do
        result := Tipo + ': ' + e.Message;
    end;
  end;

  // Tutti gli script del dataset, nell'ordine in cui li usa l'applicazione.
  // Si ferma al primo che non si prepara: gli altri si rileggono al giro
  // successivo, dopo la correzione, perche' spesso hanno lo stesso difetto.
  function ErroreDataSet(DataSet: TzDataSet): string;
  begin
    result := ErroreScript('SQL_Select', DataSet.SQL_Select.Text);
    if result = '' then
      result := ErroreScript('SQL_Insert', DataSet.SQL_Insert.Text);
    if result = '' then
      result := ErroreScript('SQL_Update', DataSet.SQL_Update.Text);
    if result = '' then
      result := ErroreScript('SQL_Delete', DataSet.SQL_Delete.Text);
    if result = '' then
      result := ErroreScript('SQL_Refresh', DataSet.SQL_Refresh.Text);
  end;

  // Il dialogo di avanzamento disabilita le altre finestre: va chiuso prima
  // di qualunque messaggio o editor e riaperto dopo, riportando la barra al
  // punto in cui era arrivata.
  procedure RiapriProgress(const Posizione: Integer);
  begin
    ProgressBox.Show(tree.AbsoluteCount, 'Verifica SQL', 'Attendere...', '');
    ProgressBox.Progress := Posizione;
  end;

begin
  inherited;

  qryTest.Connection := base.zFbDatabase;
  qryTest.Transaction := base.zFbTransaction;

  Verificati := 0;
  ConErrori := 0;
  Interrotto := False;

  // AbsoluteItems e non Items: i dataset di dettaglio sono nodi figli, e con
  // Items la verifica vedeva solo quelli di primo livello. L'ordine di
  // AbsoluteItems e' quello a schermo, dal primo in alto scendendo in basso.
  ProgressBox.Show(tree.AbsoluteCount, 'Verifica SQL', 'Attendere...', '');
  try
    I := 0;
    while I < tree.AbsoluteCount do
    begin
      Node := tree.AbsoluteItems[I];
      Inc(I);

      ProgressBox.IncProgress;
      if ProgressBox.Cancelled then
      begin
        Interrotto := True;
        Break;
      end;

      zDiagramDataSet := GetDataSet(Node);

      // Nodo che non porta un dataset. Prima qui c'era un Exit e la verifica
      // finiva in silenzio al primo nodo di questo tipo, facendo credere che
      // fosse andato tutto bene fino in fondo.
      if not Assigned(zDiagramDataSet) then
        Continue;

      ProgressBox.FirstLabel := zDiagramDataSet.Name;

      tree.FocusedNode := Node;
      Node.MakeVisible;

      zDataSet := zDiagramDataSet.zDataSet(false);

      // Dataset presente nel diagramma ma senza la voce corrispondente
      // nell'LZ: non c'e' nessuno script da verificare ed e' un difetto a se',
      // da segnalare invece di saltarlo in silenzio.
      if not Assigned(zDataSet) then
      begin
        Inc(ConErrori);

        ProgressBox.Close;
        try
          Interrotto := not ConfirmYesNo(Format('DataSet %s' + sLineBreak + sLineBreak +
            'E'' nel diagramma del datamodule ma non ha una voce nell''LZ: non c''e'' nessun SQL da verificare.' + sLineBreak + sLineBreak +
            'Proseguire con i dataset successivi?', [zDiagramDataSet.Name]));
        finally
          if not Interrotto then
            RiapriProgress(I);
        end;

        if Interrotto then
          Break;

        Continue;
      end;

      Inc(Verificati);

      Errore := ErroreDataSet(zDataSet);
      if Errore = '' then
        Continue;

      // Errore: si sospende l'avanzamento, si mostra il problema e si offre
      // l'editor del dataset. Dopo ogni passaggio nell'editor lo stesso
      // dataset viene rivalutato, cosi' la correzione si verifica subito e
      // non serve rilanciare la verifica dall'inizio.
      ProgressBox.Close;
      try
        while Errore <> '' do
        begin
          if not ConfirmYesNo(Format('DataSet %s' + sLineBreak + sLineBreak + '%s' + sLineBreak + sLineBreak +
            'Aprire l''editor del dataset per correggerlo?', [zDataSet.Name, Errore])) then
            Break;

          Edit_CollectionItem(zSystem, zDataSet);

          Errore := ErroreDataSet(zDataSet);
        end;

        if Errore <> '' then
        begin
          Inc(ConErrori);
          Interrotto := not ConfirmYesNo('Il dataset ha ancora un errore.' + sLineBreak + sLineBreak + 'Proseguire con i dataset successivi?');
        end;
      finally
        if not Interrotto then
          RiapriProgress(I);
      end;

      if Interrotto then
        Break;
    end;
  finally
    ProgressBox.Close;
  end;

  if Interrotto then
    ConfirmOk(Format('Verifica interrotta.' + sLineBreak + sLineBreak + 'Dataset controllati: %d' + sLineBreak + 'Con errori: %d', [Verificati, ConErrori]))
  else
    if ConErrori = 0 then
      ConfirmOk(Format('Verifica completata.' + sLineBreak + sLineBreak + 'Dataset controllati: %d' + sLineBreak + 'Nessun errore.', [Verificati]))
    else
      ConfirmOk(Format('Verifica completata.' + sLineBreak + sLineBreak + 'Dataset controllati: %d' + sLineBreak + 'Con errori: %d', [Verificati, ConErrori]));
end;

end.
