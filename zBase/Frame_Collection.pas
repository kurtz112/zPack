unit Frame_Collection;

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
  ExtCtrls,
  Frame_ObjectInspector,
  Menus,
  ActnList,
  ImgList,
  ComCtrls,
  zCollection,
  zMsg,
  System.Actions,
  System.ImageList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxSplitter,
  cxContainer,
  cxEdit,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxImageList,
  dxBarBuiltInMenu,
  cxPC,
  cxTextEdit;

type
  TzCollectionActionEvent = procedure(Sender: TObject; var Handled: Boolean) of object;
  TzCollectionNodeCheckedEvent = procedure(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean) of object;

  TFrameCollection = class(TFrame)
    ActionList: TActionList;
    Nuovo: TAction;
    Elimina: TAction;
    Aggiorna: TAction;
    PopupMenu: TPopupMenu;
    Nuovo1: TMenuItem;
    Elimina1: TMenuItem;
    N1: TMenuItem;
    Aggiorna1: TMenuItem;
    Splitter: TcxSplitter;
    TreeList: TcxTreeList;
    Duplica: TAction;
    N2: TMenuItem;
    Duplica1: TMenuItem;
    CheckImages: TcxImageList;
    cxPageControl: TcxPageControl;
    tabInspector: TcxTabSheet;
    tabEditor: TcxTabSheet;
    FrameObjectInspector: TFrameObjectInspector;
    TreeListColumn: TcxTreeListColumn;
    procedure cxPageControlChange(Sender: TObject);
    procedure NuovoExecute(Sender: TObject);
    procedure EliminaExecute(Sender: TObject);
    procedure DuplicaExecute(Sender: TObject);
    procedure TreeListCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
    procedure TreeListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TreeListSelectionChanged(Sender: TObject);
  private
    FAutoUpdateInspector: Boolean;
    FCheckBoxes: Boolean;
    FOnSelectNode: TNotifyEvent;
    FOnBeforeSelectNode: TcxTreeListNodeChangingEvent;
    FOnNodeChecked: TzCollectionNodeCheckedEvent;
    FOnInspectorModified: TNotifyEvent;
    FOnBeforeInsert: TzCollectionActionEvent;
    FOnBeforeDelete: TzCollectionActionEvent;
    FOnPageChange: TNotifyEvent;
    FOnEditorChanged: TNotifyEvent;
    function GetImageList: TCustomImageList;
    procedure SetImageList(const Value: TCustomImageList);
    procedure SetCheckBoxes(const Value: Boolean);
    procedure SetOnInspectorModified(const Value: TNotifyEvent);
    function GetTreeListWidth: Integer;
    procedure SetTreeListWidth(const Value: Integer);
    function GetSelectedNode: TcxTreeListNode;
    procedure SetSelectedNode(const Node: TcxTreeListNode);
  private
    FEditor: TFrame;
    function GetEditorVisible: Boolean;
  public
    constructor Create(aOwner: TComponent); override;

    procedure Clear;
    procedure AddCollection(zCollection: TzCustomCollection);
    procedure AddCollections(zCollectionArray: array of TzCustomCollection);

    procedure UpdateInspector;
    procedure RefreshInspector;
    procedure InspectorUpdateRow;

    procedure SetEditor(Editor: TFrame);
    procedure ClearEditor;

    procedure ShowInspector;
    procedure ShowEditor;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure FullExpand;
    procedure FullCollapse;

    // CRUD
    procedure InsertItem;
    procedure DeleteItem;
    procedure DuplicateItem;

    // Navigazione / tipo nodo
    function IsCollectionNode(Node: TcxTreeListNode): Boolean;
    function IsCollectionItemNode(Node: TcxTreeListNode): Boolean;
    function GetCollectionFromNode(Node: TcxTreeListNode): TzCustomCollection;
    function GetCollectionItem(Node: TcxTreeListNode): TzCollectionItem;
    function GetCollectionNode(Node: TcxTreeListNode): TcxTreeListNode;
    function GetCollection(Node: TcxTreeListNode): TzCustomCollection;
    function FindNode(Item: TzCollectionItem): TcxTreeListNode;
    function FindNodeByInstance(Item: TzCollectionItem): TcxTreeListNode;

    // Selezione
    procedure SelectCollectionItem(Item: TzCollectionItem);
    procedure SelectCollection(zCollection: TzCustomCollection);

    // CheckBox
    function IsChecked(Node: TcxTreeListNode): Boolean;
    procedure SetChecked(Node: TcxTreeListNode; const Checked: Boolean);
    procedure ToggleChecked(Node: TcxTreeListNode);

    // Iterazione
    procedure ForEachItemNode(const Action: TProc<TcxTreeListNode, TzCollectionItem>);
    procedure SyncCheckedState(const GetChecked: TFunc<TzCollectionItem, Boolean>);

    property SelectedNode: TcxTreeListNode read GetSelectedNode write SetSelectedNode;
  published
    property AutoUpdateInspector: Boolean read FAutoUpdateInspector write FAutoUpdateInspector default True;

    property Editor: TFrame read FEditor;
    property EditorVisible: Boolean read GetEditorVisible;

    property ImageList: TCustomImageList read GetImageList write SetImageList;
    property TreeListWidth: Integer read GetTreeListWidth write SetTreeListWidth;
    property CheckBoxes: Boolean read FCheckBoxes write SetCheckBoxes default False;
    property OnSelectNode: TNotifyEvent read FOnSelectNode write FOnSelectNode;
    property OnBeforeSelectNode: TcxTreeListNodeChangingEvent read FOnBeforeSelectNode write FOnBeforeSelectNode;
    property OnNodeChecked: TzCollectionNodeCheckedEvent read FOnNodeChecked write FOnNodeChecked;
    property OnInspectorModified: TNotifyEvent read FOnInspectorModified write SetOnInspectorModified;
    property OnBeforeInsert: TzCollectionActionEvent read FOnBeforeInsert write FOnBeforeInsert;
    property OnBeforeDelete: TzCollectionActionEvent read FOnBeforeDelete write FOnBeforeDelete;
    property OnPageChange: TNotifyEvent read FOnPageChange write FOnPageChange;
    // Notifica ogni cambio dell'istanza di Editor (creazione, sostituzione,
    // distruzione): chi tiene un riferimento tipizzato all'editor deve
    // riallinearlo qui, altrimenti resta un puntatore pendente dopo la Free.
    property OnEditorChanged: TNotifyEvent read FOnEditorChanged write FOnEditorChanged;
  end;

implementation


uses
  zDX;
{$R *.dfm}

const
  imgUnchecked = 1;
  imgChecked = 2;

  { TFrameCollection }

constructor TFrameCollection.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FAutoUpdateInspector := True;
  FCheckBoxes := False;
  FEditor := nil;
  FOnSelectNode := nil;
  FOnBeforeSelectNode := nil;
  FOnNodeChecked := nil;
  FOnInspectorModified := nil;
  FOnBeforeInsert := nil;
  FOnBeforeDelete := nil;
  FOnPageChange := nil;
  FOnEditorChanged := nil;
end;

// ---------------------------------------------------------------------------
// Aggiornamento inspector
// ---------------------------------------------------------------------------

procedure TFrameCollection.UpdateInspector;
var
  i: Integer;
  Persistent: TPersistent;
  Node: TcxTreeListNode;
begin
  FrameObjectInspector.Clear;

  for i := 0 to TreeList.SelectionCount - 1 do
  begin
    Node := TreeList.Selections[i];

    if not IsCollectionItemNode(Node) then
      Continue;

    Persistent := TPersistent(Node.Data);
    if Assigned(Persistent) then
      FrameObjectInspector.Add(Persistent);
  end;
end;

// ---------------------------------------------------------------------------
// Handler eventi TcxTreeList
// ---------------------------------------------------------------------------

procedure TFrameCollection.TreeListSelectionChanged(Sender: TObject);
begin

  if AutoUpdateInspector then
    UpdateInspector;

  if Assigned(FOnSelectNode) then
    FOnSelectNode(Sender);
end;

procedure TFrameCollection.TreeListCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
begin
  if Assigned(FOnBeforeSelectNode) then
    FOnBeforeSelectNode(Sender, ANode, Allow);
end;

procedure TFrameCollection.TreeListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FCheckBoxes and (Key = VK_SPACE) then
    ToggleChecked(SelectedNode);
end;

procedure TFrameCollection.TreeListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // Clic sul pallino (immagine di stato) a sinistra del nodo: inverte lo stato come la barra spaziatrice,
  // come faceva TFrameTreeView con htOnStateIcon prima del passaggio a TcxTreeList
  if not FCheckBoxes or (Button <> mbLeft) or (Shift * [ssShift, ssCtrl, ssDouble] <> []) then
    Exit;

  TreeList.HitTest.HitPoint := Point(X, Y);
  if TreeList.HitTest.HitAtStateImage and Assigned(TreeList.HitTest.HitNode) then
    ToggleChecked(TreeList.HitTest.HitNode);
end;

procedure TFrameCollection.TreeListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetNode, SourceNode: TcxTreeListNode;
begin
  if Y < 15 then
  begin
    SendMessage(TreeList.Handle, WM_VSCROLL, SB_LINEUP, 0);
    Application.ProcessMessages;
  end
  else
    if TreeList.Height - Y < 15 then
    begin
      SendMessage(TreeList.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
      Application.ProcessMessages;
    end;

  Accept := False;

  if Sender <> TreeList then
    Exit;

  TargetNode := TreeList.GetNodeAt(X, Y);
  SourceNode := SelectedNode;

  if not Assigned(SourceNode) then
    Exit;
  if not Assigned(TargetNode) then
    Exit;
  if not IsCollectionItemNode(SourceNode) then
    Exit;

  if GetCollectionFromNode(TargetNode) = GetCollectionFromNode(SourceNode) then
    Accept := True;
end;

procedure TFrameCollection.TreeListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Collection: TzCustomCollection;
  DestIndex, SrcIndex, i: Integer;
  TargetNode: TcxTreeListNode;
  Node: TcxTreeListNode;
  List: TList;
begin
  TargetNode := TreeList.GetNodeAt(X, Y);

  if not Assigned(TargetNode) then
  begin
    TreeList.EndDrag(False);
    Exit;
  end;

  Collection := GetCollection(TargetNode);
  if not Assigned(Collection) then
    Exit;

  List := TList.Create;
  try
    for i := 0 to TreeList.SelectionCount - 1 do
      List.Add(TreeList.Selections[i]);

    TreeList.BeginUpdate;
    try
      for i := 0 to List.Count - 1 do
      begin
        Node := TcxTreeListNode(List[i]);

        SrcIndex := Node.Index;
        Node.MoveTo(TargetNode, tlamInsert);
        DestIndex := Node.Index;

        Collection.Move(SrcIndex, DestIndex);
        Node.MakeVisible;

        if FCheckBoxes then
        begin
          ToggleChecked(Node);
          ToggleChecked(Node);
        end;
      end;
    finally
      TreeList.EndUpdate;
    end;
  finally
    FreeAndNil(List);
  end;
end;

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

procedure TFrameCollection.NuovoExecute(Sender: TObject);
var
  Handled: Boolean;
begin
  Handled := False;
  if Assigned(FOnBeforeInsert) then
    FOnBeforeInsert(Self, Handled);
  if not Handled then
    InsertItem;
end;

procedure TFrameCollection.RefreshInspector;
begin
  // FrameObjectInspector.zPropertyInspector.UpdateItems;
end;

procedure TFrameCollection.EliminaExecute(Sender: TObject);
var
  Handled: Boolean;
begin
  Handled := False;
  if Assigned(FOnBeforeDelete) then
    FOnBeforeDelete(Self, Handled);
  if not Handled then
    if ConfirmOkCancel('Eliminare gli elementi selezionati?') then
    begin
      FrameObjectInspector.Clear;
      DeleteItem;
    end;
end;

procedure TFrameCollection.DuplicaExecute(Sender: TObject);
begin
  DuplicateItem;
end;

// ---------------------------------------------------------------------------
// Popolamento
// ---------------------------------------------------------------------------

procedure TFrameCollection.AddCollection(zCollection: TzCustomCollection);
begin
  if not Assigned(zCollection) then
    Exit;
  zCollection.FillTreeList(TreeList.Root);
end;

procedure TFrameCollection.AddCollections(zCollectionArray: array of TzCustomCollection);
var
  i: Integer;
begin
  TreeList.BeginUpdate;
  try
    Clear;
    for i := Low(zCollectionArray) to High(zCollectionArray) do
      AddCollection(zCollectionArray[i]);
  finally
    TreeList.EndUpdate;
  end;
end;

procedure TFrameCollection.Clear;
begin
  FrameObjectInspector.Clear;
  TreeList.Clear;
end;

procedure TFrameCollection.BeginUpdate;
begin
  TreeList.BeginUpdate;
end;

procedure TFrameCollection.cxPageControlChange(Sender: TObject);
begin

  if Assigned(FOnPageChange) then
    FOnPageChange(Self);
end;

procedure TFrameCollection.EndUpdate;
begin
  TreeList.EndUpdate;
end;

procedure TFrameCollection.FullExpand;
begin
  TreeList.FullExpand;
end;

procedure TFrameCollection.FullCollapse;
begin
  TreeList.FullCollapse;
end;

// ---------------------------------------------------------------------------
// CRUD
// ---------------------------------------------------------------------------

procedure TFrameCollection.InsertItem;
var
  Collection: TzCustomCollection;
  Item: TzCollectionItem;
  Node: TcxTreeListNode;
  ImageIndex: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    Exit;

  Node := GetCollectionNode(SelectedNode);
  if not Assigned(Node) then
    Exit;

  ImageIndex := Node.ImageIndex;
  Item := Collection.CreateItem;

  if Item.Name = '' then
    Item.Name := 'Nuovo';

  Node := Node.AddChild;
  Node.Texts[0] := Item.Name;
  Node.Data := Item;
  Node.ImageIndex := ImageIndex;
  Node.SelectedIndex := ImageIndex;
  Node.Selected := True;
  Node.MakeVisible;
end;

procedure TFrameCollection.InspectorUpdateRow;
begin
  FrameObjectInspector.UpdateRow;
end;

procedure TFrameCollection.DeleteItem;
var
  i: Integer;
  Collection: TzCustomCollection;
  Item: TzCollectionItem;
  idx: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    Exit;

  // L'editor puo' puntare all'item che sta per essere distrutto: va staccato
  // PRIMA della Collection.Delete, perche' l'EndUpdate del tree rifocalizza un
  // altro nodo e OnCanSelectNode innesca l'Apply dell'editor, che altrimenti
  // scriverebbe su memoria gia' liberata (AV).
  ClearEditor;

  TreeList.BeginUpdate;
  try
    FrameObjectInspector.Clear;

    for i := TreeList.SelectionCount - 1 downto 0 do
      if IsCollectionItemNode(TreeList.Selections[i]) then
      begin
        Item := GetCollectionItem(TreeList.Selections[i]);
        idx := Collection.FindItemID(Item.ID).Index;
        Collection.Delete(idx);
        // TreeList.Selections[i].Delete;
      end;

    TreeList.DeleteSelection;
  finally
    TreeList.EndUpdate;
  end;
end;

procedure TFrameCollection.DuplicateItem;
var
  Collection: TzCustomCollection;
  ItemToCopy, Item: TzCollectionItem;
  Node: TcxTreeListNode;
  ImageIndex: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    Exit;

  Node := GetCollectionNode(SelectedNode);
  if not Assigned(Node) then
    Exit;

  ItemToCopy := GetCollectionItem(SelectedNode);
  if not Assigned(ItemToCopy) then
    Exit;

  ImageIndex := Node.ImageIndex;
  Item := Collection.CreateItem;
  Item.Assign(ItemToCopy);
  Item.Name := 'Nuovo...';

  Node := Node.AddChild;
  Node.Texts[0] := Item.Name;
  Node.Data := Item;
  Node.ImageIndex := ImageIndex;
  Node.SelectedIndex := ImageIndex;
  Node.Selected := True;
  Node.MakeVisible;
end;

// ---------------------------------------------------------------------------
// Navigazione / tipo nodo
// ---------------------------------------------------------------------------

function TFrameCollection.GetSelectedNode: TcxTreeListNode;
begin
  Result := nil;
  if TreeList.SelectionCount > 0 then
    Result := TreeList.Selections[0];
end;

procedure TFrameCollection.SetSelectedNode(const Node: TcxTreeListNode);
begin
  if Assigned(Node) then
    Node.Selected := True;
end;

function TFrameCollection.IsCollectionNode(Node: TcxTreeListNode): Boolean;
var
  Persistent: TPersistent;
begin
  Result := False;
  if not Assigned(Node) then
    Exit;
  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) then
    Result := Persistent is TzCustomCollection;
end;

function TFrameCollection.IsCollectionItemNode(Node: TcxTreeListNode): Boolean;
var
  Persistent: TPersistent;
begin
  Result := False;
  if not Assigned(Node) then
    Exit;
  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) then
    Result := Persistent is TzCollectionItem;
end;

function TFrameCollection.GetCollectionFromNode(Node: TcxTreeListNode): TzCustomCollection;
var
  Persistent: TPersistent;
begin
  Result := nil;
  if not Assigned(Node) then
    Exit;
  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) and (Persistent is TzCustomCollection) then
    Result := TzCustomCollection(Persistent);
end;

function TFrameCollection.GetCollectionItem(Node: TcxTreeListNode): TzCollectionItem;
var
  Persistent: TPersistent;
begin
  Result := nil;
  if not Assigned(Node) then
    Exit;
  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) and (Persistent is TzCollectionItem) then
    Result := Persistent as TzCollectionItem;
end;

function TFrameCollection.GetCollectionNode(Node: TcxTreeListNode): TcxTreeListNode;
begin
  Result := nil;
  if not Assigned(Node) then
    Exit;
  while not IsCollectionNode(Node) do
  begin
    Node := Node.Parent;
    if not Assigned(Node) then
      Break;
  end;
  Result := Node;
end;

function TFrameCollection.GetCollection(Node: TcxTreeListNode): TzCustomCollection;
var
  tmp: TcxTreeListNode;
  Item: TzCollectionItem;
begin
  Result := nil;

  if not Assigned(Node) then
    Exit;

  tmp := Node;
  while Assigned(tmp) do
  begin
    Result := GetCollectionFromNode(tmp);
    if Assigned(Result) then
      Break
    else
      tmp := tmp.Parent;
  end;

  // caso dbview/dbcard: nodi senza root collection
  if not Assigned(Result) then
  begin
    Item := GetCollectionItem(Node);
    if Assigned(Item) and (Item.Collection is TzCustomCollection) then
      Result := TzCustomCollection(Item.Collection);
  end;
end;

function TFrameCollection.FindNode(Item: TzCollectionItem): TcxTreeListNode;
var
  i: Integer;
begin
  Result := nil;
  if not Assigned(Item) then
    Exit;
  for i := 0 to TreeList.AbsoluteCount - 1 do
    if IsCollectionItemNode(TreeList.AbsoluteItems[i]) then
      if GetCollectionItem(TreeList.AbsoluteItems[i]).ID = Item.ID then
      begin
        Result := TreeList.AbsoluteItems[i];
        Break;
      end;
end;

// Confronto per istanza (puntatore), non per ID come FindNode: l'ID e'
// univoco solo dentro la singola collection e due collection diverse possono
// riusare lo stesso valore.
function TFrameCollection.FindNodeByInstance(Item: TzCollectionItem): TcxTreeListNode;
var
  i: Integer;
begin
  Result := nil;
  if not Assigned(Item) then
    Exit;
  for i := 0 to TreeList.AbsoluteCount - 1 do
    if TreeList.AbsoluteItems[i].Data = Item then
    begin
      Result := TreeList.AbsoluteItems[i];
      Break;
    end;
end;

// ---------------------------------------------------------------------------
// Selezione
// ---------------------------------------------------------------------------

procedure TFrameCollection.SelectCollectionItem(Item: TzCollectionItem);
var
  i: Integer;
begin
  if not Assigned(Item) then
    Exit;

  TreeList.SetFocus;
  for i := 0 to TreeList.AbsoluteCount - 1 do
    if IsCollectionItemNode(TreeList.AbsoluteItems[i]) then
      if GetCollectionItem(TreeList.AbsoluteItems[i]).ID = Item.ID then
      begin
        TreeList.AbsoluteItems[i].MakeVisible;
        TreeList.AbsoluteItems[i].Selected := True;
        TreeList.AbsoluteItems[i].Focused := True;
        Break;
      end;
end;

procedure TFrameCollection.SelectCollection(zCollection: TzCustomCollection);
var
  i: Integer;
begin
  if not Assigned(zCollection) then
    Exit;
  TreeList.SetFocus;
  for i := 0 to TreeList.AbsoluteCount - 1 do
    if IsCollectionNode(TreeList.AbsoluteItems[i]) then
      if GetCollection(TreeList.AbsoluteItems[i]) = zCollection then
      begin
        // Stesso indice della ricerca: Items[] conta solo i nodi di primo
        // livello, AbsoluteItems[] tutti. Con Items[i] la seconda collezione
        // in poi finiva fuori indice o su un nodo sbagliato.
        TreeList.AbsoluteItems[i].MakeVisible;
        TreeList.AbsoluteItems[i].Selected := True;
        TreeList.AbsoluteItems[i].Focused := True;
        TreeList.AbsoluteItems[i].Expand(True);
        Break;
      end;
end;

// ---------------------------------------------------------------------------
// CheckBox
// ---------------------------------------------------------------------------

procedure TFrameCollection.SetCheckBoxes(const Value: Boolean);
begin
  if FCheckBoxes = Value then
    Exit;
  FCheckBoxes := Value;
  if Value then
  begin
    if not Assigned(TreeList.StateImages) then
      TreeList.StateImages := CheckImages;
  end
  else
  begin
    if TreeList.StateImages = CheckImages then
      TreeList.StateImages := nil;
  end;
end;

function TFrameCollection.IsChecked(Node: TcxTreeListNode): Boolean;
begin
  Result := Assigned(Node) and (Node.StateIndex = imgChecked);
end;

procedure TFrameCollection.SetChecked(Node: TcxTreeListNode; const Checked: Boolean);
begin
  if not Assigned(Node) then
    Exit;
  if Checked then
    Node.StateIndex := imgChecked
  else
    Node.StateIndex := imgUnchecked;
end;

procedure TFrameCollection.ToggleChecked(Node: TcxTreeListNode);
var
  Allow: Boolean;
begin
  if not FCheckBoxes then
    Exit;
  if not Assigned(Node) then
    Exit;

  SetChecked(Node, not IsChecked(Node));

  if Assigned(FOnNodeChecked) then
  begin
    Allow := True;
    FOnNodeChecked(TreeList, Node, Allow);
  end;
end;

// ---------------------------------------------------------------------------
// Iterazione
// ---------------------------------------------------------------------------

procedure TFrameCollection.ForEachItemNode(const Action: TProc<TcxTreeListNode, TzCollectionItem>);
var
  i: Integer;
  Node: TcxTreeListNode;
  Item: TzCollectionItem;
begin
  for i := 0 to TreeList.AbsoluteCount - 1 do
  begin
    Node := TreeList.AbsoluteItems[i];
    if IsCollectionItemNode(Node) then
    begin
      Item := GetCollectionItem(Node);
      Action(Node, Item);
    end;
  end;
end;

function TFrameCollection.GetImageList: TCustomImageList;
begin
  Result := TreeList.Images;
end;

procedure TFrameCollection.SyncCheckedState(const GetChecked: TFunc<TzCollectionItem, Boolean>);
var
  i: Integer;
  Node: TcxTreeListNode;
  Item: TzCollectionItem;
begin
  for i := 0 to TreeList.AbsoluteCount - 1 do
  begin
    Node := TreeList.AbsoluteItems[i];
    if IsCollectionItemNode(Node) then
    begin
      Item := GetCollectionItem(Node);
      SetChecked(Node, GetChecked(Item));
    end;
  end;
end;

// ---------------------------------------------------------------------------
// Property getter / setter
// ---------------------------------------------------------------------------

procedure TFrameCollection.SetImageList(const Value: TCustomImageList);
begin
  TreeList.Images := Value;
end;

function TFrameCollection.GetTreeListWidth: Integer;
begin
  Result := TreeList.Width;
end;

procedure TFrameCollection.SetTreeListWidth(const Value: Integer);
begin
  TreeList.Width := Value;
end;

procedure TFrameCollection.SetOnInspectorModified(const Value: TNotifyEvent);
begin
  FOnInspectorModified := Value;
  FrameObjectInspector.OnModified := Value;
end;

procedure TFrameCollection.SetEditor(Editor: TFrame);
begin
  cxPageControl.OnChange := nil;
  try
    // distrugge il precedente se presente e diverso
    if Assigned(FEditor) and (FEditor <> Editor) then
    begin
      FEditor.Parent := nil;
      FreeAndNil(FEditor);
    end;

    FEditor := Editor;

    if Assigned(FEditor) then
    begin
      FEditor.Parent := tabEditor;
      FEditor.Align := alClient;
      tabEditor.TabVisible := True;
    end
    else
      tabEditor.TabVisible := False;
  finally
    cxPageControl.OnChange := cxPageControlChange;
  end;

  if Assigned(FOnEditorChanged) then
    FOnEditorChanged(Self);
end;

procedure TFrameCollection.ClearEditor;
begin
  SetEditor(nil); // SetEditor(nil) gestisce gi� tutto
  ShowInspector; // torna all'inspector (vedi punto 4)
end;

procedure TFrameCollection.ShowInspector;
begin
  cxPageControl.ActivePage := tabInspector;
end;

procedure TFrameCollection.ShowEditor;
begin
  if tabEditor.TabVisible then
    cxPageControl.ActivePage := tabEditor;
end;

function TFrameCollection.GetEditorVisible: Boolean;
begin
  Result := cxPageControl.ActivePage = tabEditor;
end;

end.

  cxPageControl
