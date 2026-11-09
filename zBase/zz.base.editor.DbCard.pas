unit zz.base.editor.DbCard;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  System.Actions,
  System.Generics.Collections,
  System.JSON,
  System.Types,
  Vcl.ImgList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Edge,
  Data.DB,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTextEdit,
  cxCheckBox,
  cxImageComboBox,
  cxSpinEdit,
  cxTLdxBarBuiltInMenu,
  cxFilter,
  cxData,
  cxDataStorage,
  cxEdit,
  cxNavigator,
  dxDateRanges,
  cxDBData,
  dxLayoutContainer,
  cxInplaceContainer,
  dxLayoutControl,
  cxScrollBox,
  cxClasses,
  cxVGrid,
  cxOI,
  cxImageList,
  dxBar,
  cxDropDownEdit,
  cxBarEditItem,
  dxBarExtItems,
  cxContainer,
  cxTreeView,
  cxButtons,
  cxCalc,
  zSystem,
  zBaseLib,
  Frame_ObjectInspector,
  zz.base.editor._frame,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

const
  msg_AfterDragDrop = WM_USER + 1236;

type
  TzFrameEditor_DbCard = class(TzFrameEditorCollectionItem)
    layout: TdxLayoutControl;
    layoutGroup_Root: TdxLayoutGroup;
    dxLayoutItemTree: TdxLayoutItem;
    dxLayoutGroupMain: TdxLayoutGroup;
    dxLayoutSplitterItem6: TdxLayoutSplitterItem;
    tree: TcxTreeList;
    ItemImages: TcxImageList;
    ActionList: TActionList;
    dxBarManager: TdxBarManager;
    popTree: TdxBarPopupMenu;
    actAggiungiItem: TAction;
    actRimuoviItem: TAction;
    AggiungiGroup: TAction;
    AggiungiButton: TAction;
    dxBarButton7: TdxBarButton;
    MostraCampi: TAction;
    NascondiCampi: TAction;
    dxBarButton3: TdxBarButton;
    dxBarButton13: TdxBarButton;
    treeName: TcxTreeListColumn;
    treeCtrlType: TcxTreeListColumn;
    treeDisplayLabel: TcxTreeListColumn;
    treeRequired: TcxTreeListColumn;
    treeReadOnly: TcxTreeListColumn;
    treeVisible: TcxTreeListColumn;
    pnlSposta: TPanel;
    cxButton1: TcxButton;
    SpostaCampi: TAction;
    treeSposta: TcxTreeView;
    cxBarEditItemSposta: TcxBarEditItem;
    Raggruppa: TAction;
    dxBarButton14: TdxBarButton;
    treeSize: TcxTreeListColumn;
    treeLines: TcxTreeListColumn;
    Inspector: TFrameObjectInspector;
    dxLayoutItemInspector: TdxLayoutItem;
    imageCtrlType: TcxImageList;
    dxBarManagerBar1: TdxBar;
    ProperitaCard: TAction;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    AggiungiLineBreak: TAction;
    AggiungiSeparatore: TAction;
    dxBarButton4: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarButton8: TdxBarButton;
    CheckImages: TcxImageList;
    dxBarButton5: TdxBarButton;
    Adatta: TAction;
    dxBarButton10: TdxBarButton;
    ResetOrdineCampi: TAction;
    dxBarButton11: TdxBarButton;
    EditCampi: TAction;
    dxBarButton12: TdxBarButton;
    dxBarButton15: TdxBarButton;
    Separa: TAction;
    dxBarButton16: TdxBarButton;
    dxBarButton17: TdxBarButton;
    RipristinaEtichette: TAction;
    dxBarButton18: TdxBarButton;
    procedure actAggiungiItemExecute(Sender: TObject);
    procedure actRimuoviItemExecute(Sender: TObject);
    procedure AdattaExecute(Sender: TObject);
    procedure AggiungiGroupExecute(Sender: TObject);
    procedure AggiungiLineBreakExecute(Sender: TObject);
    procedure AggiungiSeparatoreExecute(Sender: TObject);
    procedure MostraCampiExecute(Sender: TObject);
    procedure NascondiCampiExecute(Sender: TObject);
    procedure pnlSpostaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlSpostaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlSpostaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure treeSelectionChanged(Sender: TObject);
    procedure treeEditValueChanged(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
    procedure cxBarEditItemSpostaPropertiesInitPopup(Sender: TObject);
    procedure EditCampiExecute(Sender: TObject);
    procedure ProperitaCardExecute(Sender: TObject);
    procedure RaggruppaExecute(Sender: TObject);
    procedure ResetOrdineCampiExecute(Sender: TObject);
    procedure RipristinaEtichetteExecute(Sender: TObject);
    procedure SeparaExecute(Sender: TObject);
    procedure SpostaCampiExecute(Sender: TObject);
    procedure treeCustomDrawDataCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
    procedure treeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure treeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure treeEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure treeGetDragDropText(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var AText: string);
    procedure treeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure treeMoveTo(Sender: TcxCustomTreeList; AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode; Nodes: TList; var IsCopy, Done: Boolean);
    procedure treeSpostaDblClick(Sender: TObject);
  private
    TargetNode: TcxTreeListNode;
    FzDbCardProps: TzDbCardProps;
    ResizingPnlSposta: Boolean;
    oldPos: TPoint;
    LastDragY: Integer;
    // Domini corretti in memoria da RipristinaEtichette e non ancora scritti
    // nell'LZ: la scrittura avviene in Apply, cosi' l'annullamento dell'editor
    // non lascia salvataggi parziali.
    DominiDaSalvare: Integer;
  private
    procedure SelectItems;
    procedure LoadItems;
    function Groups: TStringDynArray;
    procedure EnumCtrlType;
    procedure ImpostaVisibilitaCampi(Visible: Boolean);
    procedure AfterDragDrop(var Message: TMessage); message msg_AfterDragDrop;
  private
    function GetFormItem(const FieldName: string): TzControlProps;
    function FocusedFormItem: TzControlProps;
    // Dominio del controllo senza aprire il dataset: riferimento gia' assegnato,
    // poi FieldOrigin persistito, poi TableName del dataset + nome campo.
    function RisolviDominio(ControlProps: TzControlProps): TzDomain;
    // Etichetta calcolata dal nome del campo con la stessa regola usata alla
    // creazione del dominio nel dizionario (FormatDisplayLabel).
    function EtichettaPredefinita(ControlProps: TzControlProps; Domain: TzDomain): string;
    function Dizionario: TzDomains;
    function FindNode(item: TzControlProps): TcxTreeListNode;
    procedure DisplayItem(item: TzControlProps; node: TcxTreeListNode);

    function ImageIndex(item: TzControlProps): Integer;
    function AggiungiItem(zCtrlType: TzCtrlType): TzControlProps;
    function CreateItem(Name: String; zCtrlType: TzCtrlType; doLoadItems: Boolean = true): TzControlProps;
    procedure Inspect(item: TzControlProps);
    procedure SetzDbCardProps(const Value: TzDbCardProps);
    procedure InspectorModified(Sender: TObject);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure Init; override;
    procedure Apply; override;
    procedure Clear; override;
    function GetDialogWidth: Integer; override;
    function GetDialogHeight: Integer; override;

    function WindowState: TWindowState; override;
  public
    property zDbCardProps: TzDbCardProps read FzDbCardProps write SetzDbCardProps;
  end;

implementation

uses
  System.Rtti,
  System.IOUtils,
  System.Math,
  cxGeometry,
  zdx,
  zMsg,
  zMemoDialog;

{$R *.dfm}

type
  TcxTreeListNodeAccess = class(TcxTreeListNode);

constructor TzFrameEditor_DbCard.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  TargetNode := nil;
  LastDragY := -1;
  FzDbCardProps := TzDbCardProps.Create(nil);

  ResizingPnlSposta := false;
  oldPos := Point(0, 0);

  dx.InitLayoutControl(layout);
  dx.InitTreeList(tree, false);

  // dxLayoutGroupControl.ItemIndex := 0;
  EnumCtrlType;

  Inspector.OnModified := InspectorModified;
end;

procedure TzFrameEditor_DbCard.InspectorModified(Sender: TObject);
begin
  LoadItems; // aggiorna il tree
end;

procedure TzFrameEditor_DbCard.actRimuoviItemExecute(Sender: TObject);
var
  i: Integer;
  item: TzControlProps;
  node: TcxTreeListNode;
  SelectedList: TList<TcxTreeListNode>;
begin
  if tree.SelectionCount > 0 then
    if ConfirmYesNo('Eliminare gli elementi selezionati?') then
    begin
      SelectedList := TList<TcxTreeListNode>.Create;
      try

        for i := 0 to tree.SelectionCount - 1 do
          SelectedList.Add(tree.Selections[i]);

        for node in SelectedList do
        begin

          item := TzControlProps(node.Data);
          if Assigned(item) then
            item.Free;

          if Assigned(node) then
            node.Free;
        end;
      finally
        FreeAndNil(SelectedList);
      end;
    end;
end;

procedure TzFrameEditor_DbCard.ImpostaVisibilitaCampi(Visible: Boolean);
var
  i: Integer;
  node: TcxTreeListNode;
begin

  for i := 0 to tree.SelectionCount - 1 do
  begin
    node := tree.Selections[i];

    if TObject(node.Data) is TzControlProps then
      TzControlProps(node.Data).Visible := Visible;
  end;

  LoadItems;
end;

procedure TzFrameEditor_DbCard.MostraCampiExecute(Sender: TObject);
begin
  ImpostaVisibilitaCampi(true);
end;

procedure TzFrameEditor_DbCard.NascondiCampiExecute(Sender: TObject);
begin
  ImpostaVisibilitaCampi(false);
end;

destructor TzFrameEditor_DbCard.Destroy;
begin
  FreeAndNil(FzDbCardProps);
  inherited;
end;

procedure TzFrameEditor_DbCard.DisplayItem(item: TzControlProps; node: TcxTreeListNode);
begin
  node.Data := item;
  node.ImageIndex := ImageIndex(item);
  node.Texts[treeName.VisibleIndex] := item.Name;
  node.Values[treeVisible.VisibleIndex] := item.Visible;
  node.Values[treeName.VisibleIndex] := item.Name;
  node.Values[treeDisplayLabel.VisibleIndex] := item.DisplayLabel;
  node.Values[treeSize.VisibleIndex] := item.Size;
  node.Values[treeLines.VisibleIndex] := item.Lines;
  node.Values[treeRequired.VisibleIndex] := item.Required;
  node.Values[treeReadOnly.VisibleIndex] := item.ReadOnly;
  node.Values[treeCtrlType.VisibleIndex] := item.zCtrlType;
end;

procedure TzFrameEditor_DbCard.treeEditValueChanged(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
var
  node: TcxTreeListNode;
  item: TzControlProps;
  EditingValue: TcxEditValue;
begin
  node := tree.FocusedNode;

  if not Assigned(tree.InplaceEditor) then
    Exit;

  EditingValue := tree.InplaceEditor.EditingValue;

  if Assigned(node) then
  begin
    item := TzControlProps(node.Data);

    if Assigned(item) then
    begin

      if AColumn = treeVisible then
        item.Visible := EditingValue
      else
        if AColumn = treeCtrlType then
          item.zCtrlType := EditingValue
        else
          if AColumn = treeName then
            item.Name := EditingValue
          else
            if AColumn = treeDisplayLabel then
              item.DisplayLabel := EditingValue
            else
              if AColumn = treeRequired then
                item.Required := EditingValue
              else
                if AColumn = treeReadOnly then
                  item.ReadOnly := EditingValue
                else
                  if AColumn = treeSize then
                    item.Size := EditingValue
                  else
                    if AColumn = treeLines then
                      item.Lines := EditingValue;
    end; // \assigned(item)

    Inspect(item);
  end;
end;

function TzFrameEditor_DbCard.Groups: TStringDynArray;
var
  zControlProps: TzControlProps;
  StringList: TStringList;
  Group: string;
begin
  result := nil;

  StringList := TStringList.Create;
  try
    StringList.Duplicates := dupIgnore;
    StringList.CaseSensitive := false;

    for zControlProps in zDbCardProps.Controls do
      if not zControlProps.Group.IsEmpty then
        if StringList.IndexOf(zControlProps.Group) = -1 then
          StringList.Add(zControlProps.Group);

    for Group in StringList do
    begin
      SetLength(result, Length(result) + 1);
      result[Length(result) - 1] := Group;
    end;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzFrameEditor_DbCard.LoadItems;

  function findGroupNode(const Group: string): TcxTreeListNode;
  begin
    result := FindNode(GetFormItem(Group));
  end;

  procedure LoadSub(const Group: string; master: TcxTreeListNode; items: TzControls);
  var
    node, sub: TcxTreeListNode;
    item: TzControlProps;
  begin

    for item in items do
      if sameText(item.Group, Group) then
      begin
        node := tree.AddChild(master);
        DisplayItem(item, node);
      end;
  end;

var
  Group: string;
  Selected: Integer;
  grpNode: TcxTreeListNode;
begin

  if tree.SelectionCount > 0 then
    Selected := tree.Selections[0].AbsoluteIndex
  else
    Selected := -1;

  tree.OnSelectionChanged := nil;
  try
    tree.BeginUpdate;
    try
      tree.Clear;

      LoadSub('', nil, zDbCardProps.Controls);

      for Group in Groups do
      begin

        grpNode := findGroupNode(Group);

        LoadSub(Group, grpNode, zDbCardProps.Controls);
      end;

      tree.FullExpand;
      tree.ApplyBestFit;

      if Selected <> -1 then
        if Selected < tree.AbsoluteCount then
        begin
          tree.AbsoluteItems[Selected].Selected := true;
          tree.AbsoluteItems[Selected].Focused := true;
        end;
    finally
      tree.EndUpdate;
    end;
  finally
    tree.OnSelectionChanged := treeSelectionChanged;
  end;
end;

procedure TzFrameEditor_DbCard.treeSelectionChanged(Sender: TObject);
var
  i: Integer;
begin
  SelectItems;

  // for i := tree.SelectionCount - 1 downto 1 do
  // if tree.Selections[0].Parent <> tree.Selections[i].Parent then
  // tree.Selections[i].Selected := false;
end;

procedure TzFrameEditor_DbCard.pnlSpostaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ResizingPnlSposta := true;
  SetCapture(pnlSposta.Handle);
  GetCursorPos(oldPos);
end;

procedure TzFrameEditor_DbCard.pnlSpostaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
const
  minWidth = 20;
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
      if frmPoint.X > minWidth then
        Width := frmPoint.X;
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

procedure TzFrameEditor_DbCard.pnlSpostaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ResizingPnlSposta then
  begin
    Screen.Cursor := crDefault;
    ReleaseCapture;
    ResizingPnlSposta := false;
  end;
end;

procedure TzFrameEditor_DbCard.cxBarEditItemSpostaPropertiesInitPopup(Sender: TObject);

  procedure LoadSub(master: TTreeNode; items: TzControls);
  var
    item: TzControlProps;
    node, sub: TTreeNode;
  begin

    for item in items do
    begin
      node := treeSposta.items.AddChild(master, item.Name);

      node.ImageIndex := ImageIndex(item);
      node.Data := item;
      node.Text := item.Name;
    end;
  end;

var
  item: TzControlProps;
  idx: Integer;
  node: TTreeNode;
begin;
  treeSposta.items.BeginUpdate;
  try
    treeSposta.items.Clear;

    LoadSub(nil, zDbCardProps.Controls);
    treeSposta.FullExpand;

    if treeSposta.items.Count > 0 then
      treeSposta.items[0].Focused := true;
  finally
    treeSposta.items.EndUpdate;
  end;
end;

procedure TzFrameEditor_DbCard.treeSpostaDblClick(Sender: TObject);
begin
  SpostaCampi.Execute;
end;

function TzFrameEditor_DbCard.FindNode(item: TzControlProps): TcxTreeListNode;
var
  i: Integer;
begin
  result := nil;

  for i := 0 to tree.AbsoluteCount - 1 do
    if TzControlProps(tree.AbsoluteItems[i].Data) = item then
    begin
      result := tree.AbsoluteItems[i];
      break;
    end;
end;

function TzFrameEditor_DbCard.FocusedFormItem: TzControlProps;
var
  node: TcxTreeListNode;
begin
  result := nil;

  if Assigned(tree.FocusedNode) then
    if Assigned(tree.FocusedNode.Data) then
      result := TzControlProps(tree.FocusedNode.Data);
end;

// Misure dell'editor: 1200x800, ridotte al 90% dell'area utile del monitor
// quando non ci stanno. Prima, sui monitor piu' piccoli, restituivano 0 e la
// finestra si apriva larga quanto il minimo di Windows (circa 135 pixel).
function TzFrameEditor_DbCard.GetDialogHeight: Integer;
const
  H = 800;
var
  AreaUtile: TRect;
begin
  AreaUtile := Screen.MonitorFromWindow(Handle).WorkareaRect;
  result := Min(H, AreaUtile.Height * 9 div 10);
end;

function TzFrameEditor_DbCard.GetDialogWidth: Integer;
const
  W = 1200;
var
  AreaUtile: TRect;
begin
  AreaUtile := Screen.MonitorFromWindow(Handle).WorkareaRect;
  result := Min(W, AreaUtile.Width * 9 div 10);
end;

function TzFrameEditor_DbCard.GetFormItem(const FieldName: string): TzControlProps;
begin
  result := zDbCardProps.Controls.get(FieldName);
end;

function TzFrameEditor_DbCard.AggiungiItem(zCtrlType: TzCtrlType): TzControlProps;

// function FindContainer(out master: TcxTreeListNode; out owner: TzControls): Boolean;
// var
// node: TcxTreeListNode;
// begin
// result := false;
//
// node := tree.FocusedNode;
// while Assigned(node) do
// begin
//
// if node.Data = TdxTab then
// begin
// master := node;
// owner := TdxTab(node.Data).items;
// result := True;
// Exit;
// end
// else
// if node.Data = TdxGroupFormItem then
// begin
// master := node;
// owner := TdxGroupFormItem(node.Data).items;
// result := True;
// Exit;
// end
// else
// node := node.Parent;
// end;
//
// // root
// master := nil;
// owner := SelectedCard.FormItems;
// result := True;
// end;
//
// function CreateItem(owner: TzControls; out item: TzControlProps): Boolean;
// begin
// result := false;
//
// case FormItemKind of
// fikSimpleFormItem:
// begin
// item := owner.AddSimpleFormItem('NewSimpleItem', '', 'NewSimpleItem');
// end;
// fikButtonFormItem:
// begin
// item := owner.AddButtonItem('NewButton');
// end;
// fikEmptyFormItem:
// begin
// item := owner.AddEmptyItem();
// end;
// fikGroupFormItem:
// begin
// item := owner.AddGroupItem('NewGroup', 'NewGroup');
// end;
// fikTabbedFormItem:
// begin
// item := owner.AddTabbedFormItem('NewTabbed');
// end;
// fikTabItem:
// begin
// // item := owner.AddButtonItem();
// end;
// end;
//
// result := True;
// end;

var
  node, master: TcxTreeListNode;
  owner: TzControls;
begin
  result := nil;

  // if FindContainer(master, owner) then
  // if CreateItem(owner, result) then
  // begin
  // if Assigned(tree.FocusedNode) then
  // node := tree.Insert(tree.FocusedNode.getNextSibling)
  // else
  // node := tree.AddChild(master);
  //
  // result.Index := node.Index;
  // DisplayItem(result, node);
  // node.Focused := True;
  // end;
end;

procedure TzFrameEditor_DbCard.SelectItems;
var
  i: Integer;
  node: TcxTreeListNode;
  item: TzControlProps;
begin
  item := nil;
  Inspector.Clear;

  for i := 0 to tree.SelectionCount - 1 do
  begin
    node := tree.Selections[i];

    if node.Data <> nil then
    begin
      item := TzControlProps(node.Data);
      Inspector.Add(item);
    end;
  end;
end;

function TzFrameEditor_DbCard.ImageIndex(item: TzControlProps): Integer;
begin
  result := -1;
end;

procedure TzFrameEditor_DbCard.EnumCtrlType;
var
  zCtrlType: TzCtrlType;
  item: TcxImageComboBoxItem;
  ImageComboBoxProperties: TcxImageComboBoxProperties;
begin
  ImageComboBoxProperties := TcxImageComboBoxProperties(treeCtrlType.Properties);

  ImageComboBoxProperties.items.Clear;
  for zCtrlType := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    item := ImageComboBoxProperties.items.Add;
    item.Description := zCtrlType.AsString;
    item.Value := ord(zCtrlType);

    item.ImageIndex := 0;

    if zCtrlType.IsLookup then
      item.ImageIndex := 1
    else
      if zCtrlType = ctSeparator then
        item.ImageIndex := 2
      else
        if zCtrlType = ctLineBreak then
          item.ImageIndex := 3
        else
          if zCtrlType = ctButton then
            item.ImageIndex := 4
          else
            if zCtrlType.IsGroup then
              item.ImageIndex := 5
            else
              if zCtrlType.IsBoolean then
                item.ImageIndex := 6
              else
                if zCtrlType.IsBlob then
                  item.ImageIndex := 7;
  end;
end;

procedure TzFrameEditor_DbCard.SetzDbCardProps(const Value: TzDbCardProps);
begin
  FzDbCardProps.Assign(Value);
end;

procedure TzFrameEditor_DbCard.ProperitaCardExecute(Sender: TObject);
begin
  Inspector.Clear;
  Inspector.Add(zDbCardProps);
end;

procedure TzFrameEditor_DbCard.treeCustomDrawDataCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
var
  zControlProps: TzControlProps;
begin
  ACanvas.Font.Color := dx.GetFontColor(ckEditorNormal);

  if Assigned(AViewInfo.node) then
    if Assigned(AViewInfo.node.Data) then
      if (TObject(AViewInfo.node.Data) is TzControlProps) then
      begin
        zControlProps := TzControlProps(AViewInfo.node.Data);

        if Assigned(zControlProps) then
        begin
          if zControlProps.Visible = false then
            ACanvas.Font.Color := dx.GetFontColor(ckEditorDisabled)
          else
            if zControlProps.zCtrlType.IsGroup then
              ACanvas.Font.Style := ACanvas.Font.Style + [fsItalic];
        end;
      end;

  //
  if AViewInfo.node = TargetNode then
    ACanvas.Brush.Color := clHighlight;
end;

procedure TzFrameEditor_DbCard.treeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  AState: TcxNodeDragInfoState;
  node: TcxTreeListNode;
  IsGroup: Boolean;
begin
  Accept := true;

  // deve aggiungere come child solo per i gruppi
  if Sender = tree then
  begin
    tree.HitTest.HitPoint := Point(X, Y);
    node := tree.HitTest.HitNode;

    if not Assigned(node) then
    begin
      Accept := false;
      Exit;
    end;

    IsGroup := false;
    if Assigned(node.Data) then
      IsGroup := TzControlProps(node.Data).zCtrlType.IsGroup;

    AState := ndiInsertBefore;

    if (tree.HitTest.HitAtNodePreview or tree.HitTest.HitAtColumn) and IsGroup then
      AState := ndiAddChild
    else
      if Y < cxRectCenter(TcxTreeListNodeAccess(node).ViewData.GetRealBounds).Y then
        AState := ndiInsertBefore
      else
        AState := ndiInsertAfter;
  end;

  /// //////////////////////////////////////////
  // precedente
  if Assigned(TargetNode) then
    TargetNode.Repaint(false);

  // attuale
  TargetNode := TcxTreeList(Sender).GetNodeAt(X, Y);
  if Assigned(TargetNode) then
    TargetNode.Repaint(false);
end;

procedure TzFrameEditor_DbCard.treeDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  LastDragY := Y;
  // PostMessage(Self.Handle, msg_AfterDragDrop, 0, 0);
end;

procedure TzFrameEditor_DbCard.AfterDragDrop(var Message: TMessage);
  procedure enum(owner: TzControls; node: TcxTreeListNode);
  var
    i: Integer;
    item: TzControlProps;
    master: TzControls;
  begin
    item := TzControlProps(node.Data);

    // if Assigned(item) then
    // begin
    // if item.Collection <> owner then
    // item.Collection := owner;
    //
    // simain.LogString('dragDrop', item.Name);
    // simain.LogInteger('item.Index', item.Index);
    // simain.LogInteger('node.Index', node.Index);
    //
    // item.Index := node.Index;
    // end
    // else
    // begin
    //
    // for i := 0 to node.Count - 1 do
    // enum(owner, node.items[i]);
    // end;

    // spostare in endDrag

    if Assigned(item) then
    begin
      if item.Collection <> owner then
        item.Collection := owner;

      simain.LogString('dragDrop', item.Name);
      simain.LogInteger('item.Index', item.Index);
      simain.LogInteger('node.Index', node.Index);

      item.Index := node.Index;
    end;

    for i := node.Count - 1 downto 0 do
      enum(owner, node.items[i]);
  end;

begin

  simain.EnterMethod(Self, 'AfterDragDrop');
  enum(zDbCardProps.Controls, tree.Root);
  simain.LeaveMethod(Self, 'AfterDragDrop');
end;

procedure TzFrameEditor_DbCard.SpostaCampiExecute(Sender: TObject);
var
  destNode: TcxTreeListNode;
  item: TzControlProps;
  Selected: TzControlProps;
  IsGroup: Boolean;
  items: TzControls;
  i: Integer;
begin
  if not Assigned(treeSposta.Selected) then
    Exit;

  item := TzControlProps(treeSposta.Selected.Data);
  destNode := FindNode(item);

  if Assigned(destNode) then
  begin

    Selected := TzControlProps(destNode.Data);
    IsGroup := Selected.zCtrlType.IsGroup;

    for i := tree.SelectionCount - 1 downto 0 do
    begin
      item := TzControlProps(tree.Selections[i].Data);
      item.Index := destNode.Index; // posizione

      if IsGroup then
        item.Group := Selected.Name;
    end;

    LoadItems;

    destNode := FindNode(item); // cerca nuovamente dopo il caricamento
    if Assigned(destNode) then
    begin
      destNode.Focused := true;
      destNode.MakeVisible;
    end;
  end;

  dxBarManager.HideAll;
end;

procedure TzFrameEditor_DbCard.actAggiungiItemExecute(Sender: TObject);
var
  item: TzControlProps;
  Name: String;
begin
  Name := '';

  if InputString('Name', 'Name', Name) then
  begin
    item := CreateItem(Name, ctEdit);
    Inspect(item);
  end;
end;

procedure TzFrameEditor_DbCard.AggiungiGroupExecute(Sender: TObject);
var
  item: TzControlProps;
  Name: String;
begin
  Name := '';

  if InputString('Name', 'Name', Name) then
  begin
    item := CreateItem(Name, ctGroupBox);
    item.Size := 130;
    Inspect(item);
  end;
end;

procedure TzFrameEditor_DbCard.AggiungiLineBreakExecute(Sender: TObject);
var
  item: TzControlProps;
  Name: String;
begin
  Name := 'LineBreak'; // unique

  item := CreateItem(Name, ctLineBreak);
  Inspect(item);
end;

procedure TzFrameEditor_DbCard.AggiungiSeparatoreExecute(Sender: TObject);
var
  item: TzControlProps;
  Name: String;
begin
  Name := 'Separator'; // unique

  item := CreateItem(Name, ctSeparator);
  item.DisplayLabel := '';

  Inspect(item);
end;

function TzFrameEditor_DbCard.CreateItem(Name: String; zCtrlType: TzCtrlType; doLoadItems: Boolean = true): TzControlProps;

  function FirstSelectedIndex: Integer;
  var
    i: Integer;
  begin
    result := tree.Count - 1; // max

    for i := 0 to tree.SelectionCount - 1 do
      result := min(result, tree.Selections[i].AbsoluteIndex);
  end;

var
  Group: string;
  idx: Integer;
begin

  if tree.SelectionCount > 0 then
  begin
    idx := FirstSelectedIndex; // tree.Selections[0].AbsoluteIndex; // Lower
    Group := TzControlProps(tree.Selections[0].Data).Group;
  end
  else
  begin
    idx := 0;
    Group := '';
  end;

  result := zDbCardProps.Controls.Add;
  result.zCtrlType := zCtrlType;
  result.Name := Name;
  result.DisplayLabel := Name;

  if not zCtrlType.IsGroup then
    result.Group := Group;

  result.Visible := true;
  result.Index := idx;

  if zCtrlType.IsGroup then
  begin
    result.Lines := 3;
    result.Size := 100;
  end
  else
    if zCtrlType.IsMultiLine then
    begin
      result.Lines := 3;
      result.Size := 50;
    end
    else
    begin
      result.Lines := 1;
      result.Size := 10;
    end;

  if doLoadItems then
    LoadItems;
end;

procedure TzFrameEditor_DbCard.Inspect(item: TzControlProps);
begin
  Inspector.Clear;
  Inspector.Add(item);
end;

procedure TzFrameEditor_DbCard.Init;
begin
  inherited;

  if not Assigned(item) then
    Exit;

  Clear; // tutti i riferimenti precedenti, evita AV a iosa
  DominiDaSalvare := 0;
  Caption := 'Card: ' + item.Name;

  zDbCardProps.Assign(item);
  Inspector.Clear;
  LoadItems;
end;

procedure TzFrameEditor_DbCard.Apply;
begin
  inherited;
  if not Assigned(item) then
    Exit;

  item.Assign(zDbCardProps);

  // Domini ricalcolati da RipristinaEtichette: persistenza nell'LZ solo alla
  // conferma dell'editor (stesso canale di zSystemFrm: SaveZip(csDataDictionary)).
  if DominiDaSalvare > 0 then
  begin
    if Assigned(zSystem) then
      zSystem.SaveZip(csDataDictionary, Format('Ripristino etichette card %s: %d domini', [zDbCardProps.Name, DominiDaSalvare]))
    else
      Base.SaveZip(csDataDictionary, Format('Ripristino etichette card %s: %d domini', [zDbCardProps.Name, DominiDaSalvare]));
    DominiDaSalvare := 0;
  end;
end;

procedure TzFrameEditor_DbCard.Clear;
begin
  inherited;
  Inspector.Clear;
  tree.Clear;
end;

function TzFrameEditor_DbCard.WindowState: TWindowState;
begin
  inherited;
  result := wsNormal;
end;

procedure TzFrameEditor_DbCard.AdattaExecute(Sender: TObject);

  function CalcSize(item: TzControlProps): Integer;
  begin
    result := item.Size;

    if item.zCtrlType.IsBlob then
      result := 100
    else
      if item.zCtrlType.IsBoolean then
        result := 5
      else
        if item.Size in [0 .. 20] then
          result := 20
        else
          if item.Size in [21 .. 50] then
            result := 50
          else
            result := 100;
  end;

  function CalcDlgWidth: Integer;
  begin
    result := 800;
  end;

var
  item: TzControlProps;
begin
  inherited;

  if not ConfirmYesNo('Si desidera adattare le dimensioni dei controlli e della card?') then
    Exit;

  for item in zDbCardProps.Controls do
    item.Size := CalcSize(item);

  // ipotesi w
  zDbCardProps.DlgWidth := CalcDlgWidth;

  LoadItems;
end;

procedure TzFrameEditor_DbCard.treeGetDragDropText(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var AText: string);
var
  item: TzControlProps;
begin
  inherited;

  AText := ANode.Texts[0];

  if Assigned(ANode.Data) then
  begin
    item := TzControlProps(ANode.Data);

    AText := item.DisplayLabel;

    if AText.IsEmpty then
      AText := item.Name;

    if AText.IsEmpty then
      AText := item.zCtrlType.AsString;
  end;
end;

procedure TzFrameEditor_DbCard.treeMoveTo(Sender: TcxCustomTreeList; AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode; Nodes: TList; var IsCopy, Done: Boolean);
var
  i: Integer;
  IsGroup: Boolean;
  node: TcxTreeListNode;
  destNode: TcxTreeListNode;
  groupName: string;
  IsPrev: Boolean;

  function CompareByAbsoluteIndex(Item1, Item2: Pointer): Integer;
  begin
    result := TcxTreeListNode(Item1).AbsoluteIndex - TcxTreeListNode(Item2).AbsoluteIndex;
  end;

begin
  inherited;

  Done := true;

  destNode := tree.FocusedNode;

  IsGroup := false;
  if Assigned(destNode.Data) then
  begin
    IsGroup := TzControlProps(destNode.Data).zCtrlType.IsGroup;

    if IsGroup then
      groupName := TzControlProps(destNode.Data).Name
    else
      groupName := TzControlProps(destNode.Data).Group;
  end;

  /// ///////////////////////////////////

  Nodes.Sort(@CompareByAbsoluteIndex); // altrimenti se multiselected sbaglia l'ordine

  /// ///////////////////////////////////

  // for i := Nodes.Count - 1 downto 0 do
  for i := 0 to Nodes.Count - 1 do
  begin
    node := TcxTreeListNode(Nodes[i]);

    if Assigned(node.Data) then
      TzControlProps(node.Data).Group := groupName;

    if IsGroup and (node.parent <> destNode) then
      node.MoveTo(destNode, tlamAddChild)
    else
      if destNode.IsLast then
        node.MoveTo(destNode, tlamAdd)
      else
      begin
        IsPrev := LastDragY < cxRectCenter(TcxTreeListNodeAccess(destNode).ViewData.GetRealBounds).Y;

        if IsPrev then
          node.MoveTo(destNode, tlamInsert)
        else
          node.MoveTo(destNode.GetNext, tlamInsert); // successivo, quindi con GetNext
      end
  end;

  /// ///////////////////////////////////
end;

function TzFrameEditor_DbCard.Dizionario: TzDomains;
begin
  // zSystem e' la proprieta' del frame assegnata dal contenitore; Base e'
  // il riferimento globale usato dal resto della libreria.
  if Assigned(zSystem) then
    result := zSystem.zDataDictionary
  else
    result := Base.zDataDictionary;
end;

function TzFrameEditor_DbCard.RisolviDominio(ControlProps: TzControlProps): TzDomain;
var
  DataSetProps: TzDataSet;
  Candidato: TzDomain;
begin
  // 1. Riferimento gia' assegnato (card aperta in questa sessione, ValidateDataset)
  result := ControlProps.Domain;
  if Assigned(result) then
    Exit;

  // 2. FieldOrigin persistito ('TABELLA.CAMPO'): e' la chiave del dizionario
  if ControlProps.FieldOrigin <> '' then
    result := Dizionario.Get(ControlProps.FieldOrigin, False);
  if Assigned(result) then
    Exit;

  // 3. TableName del dataset della card + nome del campo
  DataSetProps := zDbCardProps.DataSet_Obj;
  if Assigned(DataSetProps) and (DataSetProps.TableName <> '') then
    result := Dizionario.Get(DataSetProps.TableName + '.' + ControlProps.Name, False);
  if Assigned(result) then
    Exit;

  // 4. Unico dominio del dizionario con quel nome campo; se e' ambiguo rinuncio
  for Candidato in Dizionario do
    if SameText(Candidato.FieldName, ControlProps.Name) then
    begin
      if Assigned(result) then
        Exit(nil);
      result := Candidato;
    end;
end;

function TzFrameEditor_DbCard.EtichettaPredefinita(ControlProps: TzControlProps; Domain: TzDomain): string;
var
  NomeCampo: string;
begin
  NomeCampo := '';

  if Assigned(Domain) then
  begin
    NomeCampo := Domain.FieldName;
    // Dominio creato "vuoto" da Get(..., True): ha solo il Name 'TABELLA.CAMPO'
    if (NomeCampo = '') and (Pos('.', Domain.Name) > 0) then
      NomeCampo := Copy(Domain.Name, Pos('.', Domain.Name) + 1, MaxInt);
  end;

  if NomeCampo = '' then
    NomeCampo := ControlProps.Name;

  // Stessa regola dell'inserimento nel dizionario (TzSystem: SameText(FieldName, DisplayLabel))
  result := FormatDisplayLabel(NomeCampo);
end;

procedure TzFrameEditor_DbCard.RipristinaEtichetteExecute(Sender: TObject);
var
  ControlProps: TzControlProps;
  Domain: TzDomain;
  Etichetta: string;
  ControlliRipristinati: Integer;
  DominiRicalcolati: Integer;
  SenzaDominio: Integer;
begin
  inherited;

  if not ConfirmYesNo('Ripristinare le etichette vuote dei controlli della card?' + sLineBreak +
    'I domini senza etichetta vengono ricalcolati dal nome del campo e salvati nel dizionario alla conferma dell''editor.', mtConfirmation) then
    Exit;

  ControlliRipristinati := 0;
  DominiRicalcolati := 0;
  SenzaDominio := 0;

  for ControlProps in zDbCardProps.Controls do
  begin
    // Gruppi, separatori, interruzioni di riga e pulsanti non derivano dal dominio
    if not ControlProps.zCtrlType.IsDataAware then
      Continue;

    Domain := RisolviDominio(ControlProps);

    if not Assigned(Domain) then
      Inc(SenzaDominio)
    else
      // Dominio senza etichetta: e' il caso che azzera la caption a runtime
      // (LoadFromProps usa Domain.DisplayLabel quando il controllo non ne ha una)
      if Domain.DisplayLabel = '' then
      begin
        Domain.DisplayLabel := EtichettaPredefinita(ControlProps, Domain);
        Domain.Modified;
        Inc(DominiRicalcolati);
        SiMain.LogMessage(Format('RipristinaEtichette %s: dominio %s -> "%s"', [zDbCardProps.Name, Domain.Name, Domain.DisplayLabel]));
      end;

    // Controllo senza etichetta: la riporto esplicita sul TzControlProps.
    // NB: a runtime SaveToProps la riazzera se coincide con quella del dominio;
    // e' il comportamento previsto e a quel punto il dominio la fornisce.
    if ControlProps.DisplayLabel = '' then
    begin
      if Assigned(Domain) then
        Etichetta := Domain.DisplayLabel
      else
        Etichetta := EtichettaPredefinita(ControlProps, nil);

      ControlProps.DisplayLabel := Etichetta;
      Inc(ControlliRipristinati);
      SiMain.LogMessage(Format('RipristinaEtichette %s: %s -> "%s"', [zDbCardProps.Name, ControlProps.Name, Etichetta]));
    end;
  end;

  Inc(DominiDaSalvare, DominiRicalcolati);

  Inspector.Clear;
  LoadItems;

  ConfirmOk(Format('Etichette ripristinate: %d' + sLineBreak + 'Domini ricalcolati: %d' + sLineBreak +
    'Controlli senza dominio (etichetta dal nome del campo): %d', [ControlliRipristinati, DominiRicalcolati, SenzaDominio]), mtInformation);
end;

procedure TzFrameEditor_DbCard.ResetOrdineCampiExecute(Sender: TObject);
begin
  inherited;

  if not ConfirmYesNo('Si desidera resettare l''ordine dei campi?', mtWarning) then
    Exit;

  ConfirmOk('Implementare');

  // manca il dataset
  // zDbCardProps.Controls.rese

  // zDbCardProps.Assign();
  Inspector.Clear;
  LoadItems;
end;

procedure TzFrameEditor_DbCard.EditCampiExecute(Sender: TObject);
var
  i: Integer;
  fields: TStringList;
  FieldName: string;
  ctrl: TzControlProps;
begin
  inherited;

  fields := TStringList.Create;
  try
    for ctrl in zDbCardProps.Controls do
    begin
      if ctrl.Visible then
        fields.Add(ctrl.Name)
      else
        fields.Add('-' + ctrl.Name);
    end;

    if zExecuteMemoDialog(fields, 'Campi') then
    begin
      // eliminazione righe vuote, farebero sballare l'index
      for i := fields.Count - 1 downto 0 do
        if trim(fields[i]).IsEmpty then
          fields.Delete(i);

      // assegnazione nuovo index
      for i := 0 to fields.Count - 1 do
      begin
        FieldName := fields[i];

        ctrl := zDbCardProps.Controls.get(FieldName.Replace('-', ''), false);

        if Assigned(ctrl) then
        begin
          ctrl.Index := i;

          ctrl.Visible := not FieldName.StartsWith('-');
        end;
      end;

      //
      item.Assign(zDbCardProps);
      Init; // vedere
    end;
  finally
    FreeAndNil(fields);
  end;
end;

procedure TzFrameEditor_DbCard.RaggruppaExecute(Sender: TObject);
var
  groupName: string;
  i: Integer;
  item: TzControlProps;
  node: TcxTreeListNode;
begin
  groupName := '';

  if not InputQuery('Nome Gruppo', 'Nome Gruppo: ', groupName) then
    Exit;

  for i := 0 to tree.SelectionCount - 1 do
    TzControlProps(tree.Selections[i].Data).Group := groupName;

  item := CreateItem(groupName, ctGroupBox);
  item.Size := 130;
  item.Group := '';

  LoadItems;

  node := FindNode(item);
  node.Selected := true;
  node.Focused := true;

  Inspect(item);
end;

procedure TzFrameEditor_DbCard.SeparaExecute(Sender: TObject);
var
  i: Integer;
  node: TcxTreeListNode;
  item: TzControlProps;
  groupName: string;
begin
  inherited;

  if tree.SelectionCount <> 1 then
    Exit;

  item := FocusedFormItem;

  if item.zCtrlType <> ctGroupBox then
    Exit;

  Inspector.Clear;

  groupName := item.Name;

  for i := 0 to tree.AbsoluteCount - 1 do
    if TzControlProps(tree.AbsoluteItems[i].Data).Group = groupName then
      TzControlProps(tree.AbsoluteItems[i].Data).Group := '';

  item.Free;
  LoadItems;
end;

procedure TzFrameEditor_DbCard.treeEndDrag(Sender, Target: TObject; X, Y: Integer);
var
  m: TMessage;
begin
  inherited;
  simain.LogVerbose('enddrag');
  AfterDragDrop(m);
end;

procedure TzFrameEditor_DbCard.treeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
  node: TcxTreeListNode;
begin
  inherited;

  if Key = vk_space then
  begin
    for i := 0 to tree.SelectionCount - 1 do
    begin
      node := tree.Selections[i];

      if TObject(node.Data) is TzControlProps then
        TzControlProps(node.Data).Visible := not TzControlProps(node.Data).Visible;
    end;

    LoadItems;
  end;
end;

end.
// inserimento nuovi item
// pnlSposta

  end
