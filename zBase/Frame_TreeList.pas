unit Frame_TreeList;

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
  zCollection,
  ComCtrls,
  ImgList,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  System.ImageList,
  cxGraphics,
  Vcl.StdCtrls,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxImageList,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer;

type
  TFrameTreeList = class(TFrame)
    TreeList: TcxTreeList;
    CheckImages: TcxImageList;
    procedure TreeListCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
    procedure TreeListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeListSelectionChanged(Sender: TObject);
  private
    // DOPO
  private
    FCheckBoxes: Boolean;
    FImageList: TImageList;
    FOnSelectNode: TNotifyEvent;
    FOnBeforeSelectNode: TcxTreeListNodeChangingEvent;
    FOnNodeChecked: TcxTreeListNodeChangingEvent;
    procedure SetImageList(const Value: TImageList);
    procedure SetCheckBoxes(const Value: Boolean);
    function GetSelectedNode: TcxTreeListNode;
    procedure SetSelectedNode(const node: TcxTreeListNode);
  private
  public
    constructor Create(aOwner: TComponent); override;
    // collection
    function IsCollectionNode(node: TcxTreeListNode): Boolean;
    function GetCollectionFromNode(node: TcxTreeListNode): TzCustomCollection;
    function GetCollectionNode(node: TcxTreeListNode): TcxTreeListNode;
    function GetCollection(node: TcxTreeListNode): TzCustomCollection;
    // item
    function IsCollectionItemNode(node: TcxTreeListNode): Boolean;
    function GetCollectionItem(node: TcxTreeListNode): TzCollectionItem;

    function FindNode(Item: TzCollectionItem): TcxTreeListNode;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure FullExpand;
    procedure FullCollapse;

    procedure Clear;
    procedure InsertItem;
    procedure DeleteItem;
    procedure DuplicateItem;

    function IsChecked(node: TcxTreeListNode): Boolean;
    procedure SetChecked(node: TcxTreeListNode; const Checked: Boolean);
    procedure ToggleChecked(node: TcxTreeListNode);

    procedure SelectCollectionItem(Item: TzCollectionItem);
    procedure SelectCollection(zCollection: TzCustomCollection);
    procedure AddCollection(zCollection: TzCustomCollection);

    property SelectedNode: TcxTreeListNode read GetSelectedNode write SetSelectedNode;
  published
    property CheckBoxes: Boolean read FCheckBoxes write SetCheckBoxes;
    property ImageList: TImageList read FImageList write SetImageList;
    property OnSelectNode: TNotifyEvent read FOnSelectNode write FOnSelectNode;
    property OnBeforeSelectNode: TcxTreeListNodeChangingEvent read FOnBeforeSelectNode write FOnBeforeSelectNode;
    property OnNodeChecked: TcxTreeListNodeChangingEvent read FOnNodeChecked write FOnNodeChecked;
  end;

  // DA COMPLETARE

  // AutoExpand = True
  // ChangeDelay = 50
  // HideSelection = False
  // HotTrack = True
  // MultiSelect = True
  // MultiSelectStyle = [msControlSelect, msShiftSelect, msSiblingOnly]
  // ReadOnly = True
  // OnChange = TreeListChange
  // OnChanging = TreeListChanging

implementation

{$R *.dfm}
{ TFrameTreeList }

const
  imgUnchecked = 1;
  imgChecked = 2;

constructor TFrameTreeList.Create(aOwner: TComponent);
begin
  inherited;
  FCheckBoxes := False;
  FImageList := nil;
  FOnSelectNode := nil;
  FOnBeforeSelectNode := nil;
  FOnNodeChecked := nil;
end;

procedure TFrameTreeList.BeginUpdate;
begin
  TreeList.BeginUpdate;
end;

procedure TFrameTreeList.EndUpdate;
begin
  TreeList.EndUpdate;
end;

procedure TFrameTreeList.Clear;
begin
  TreeList.Clear;
end;

function TFrameTreeList.FindNode(Item: TzCollectionItem): TcxTreeListNode;
var
  i: Integer;
begin
  Result := nil;
  if not Assigned(Item) then
    exit;
  for i := 0 to TreeList.AbsoluteCount - 1 do
    if IsCollectionItemNode(TreeList.AbsoluteItems[i]) then
      if GetCollectionItem(TreeList.AbsoluteItems[i]).ID = Item.ID then
      begin
        Result := TreeList.AbsoluteItems[i];
        Break;
      end;
end;

procedure TFrameTreeList.FullCollapse;
begin
  TreeList.FullCollapse;
end;

procedure TFrameTreeList.FullExpand;
begin
  TreeList.FullExpand;
end;

procedure TFrameTreeList.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
  TreeList.Images := Value;
end;

function TFrameTreeList.GetCollectionFromNode(node: TcxTreeListNode): TzCustomCollection;

var
  Persistent: TPersistent;
begin
  Result := nil;
  if not Assigned(node) then
    exit;

  Persistent := TPersistent(node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCustomCollection then
    begin
      Result := TzCustomCollection(Persistent);
    end;
end;

function TFrameTreeList.GetCollection(node: TcxTreeListNode): TzCustomCollection;

var
  tmp: TcxTreeListNode;
  Item: TzCollectionItem;
begin
  Result := nil;

  if not Assigned(tmp) then
    exit;

  tmp := node;
  while Assigned(tmp) do
  begin
    Result := GetCollectionFromNode(tmp);
    if Assigned(Result) then
      Break
    else
      tmp := tmp.Parent;
  end;

  // caso dbview/dbcard: non hanno root
  if not Assigned(Result) then
  begin
    Item := GetCollectionItem(node);
    if Assigned(Item) then
      if Item.Collection is TzCustomCollection then
        Result := TzCustomCollection(Item.Collection);
  end;
end;

function TFrameTreeList.GetCollectionItem(node: TcxTreeListNode): TzCollectionItem;

var
  Persistent: TPersistent;
begin
  Result := nil;

  if not Assigned(node) then
    exit;

  Persistent := TPersistent(node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCollectionItem then
      Result := Persistent as TzCollectionItem;
end;

function TFrameTreeList.IsCollectionNode(node: TcxTreeListNode): Boolean;

var
  Persistent: TPersistent;
begin
  Result := False;
  if not Assigned(node) then
    exit;

  Persistent := TPersistent(node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCustomCollection then
      Result := true;
end;

function TFrameTreeList.IsCollectionItemNode(node: TcxTreeListNode): Boolean;

var
  Persistent: TPersistent;
begin
  Result := False;
  if not Assigned(node) then
    exit;

  Persistent := TPersistent(node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCollectionItem then
      Result := true;
end;

function TFrameTreeList.GetCollectionNode(node: TcxTreeListNode): TcxTreeListNode;
begin
  Result := nil;

  if not Assigned(node) then
    exit;

  while not IsCollectionNode(node) do
  begin
    node := node.Parent;
    if not Assigned(node) then
      Break;
  end;

  Result := node;
end;

function TFrameTreeList.GetSelectedNode: TcxTreeListNode;
begin
  Result := nil;

  if TreeList.SelectionCount > 0 then
    Result := TreeList.Selections[0];
end;

procedure TFrameTreeList.SetSelectedNode(const node: TcxTreeListNode);
begin

  if Assigned(node) then
    node.Selected := true;
end;

procedure TFrameTreeList.DeleteItem;

var
  i: Integer;
  Collection: TzCustomCollection;
  Item: TzCollectionItem;
  idx: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    exit;

  for i := TreeList.SelectionCount - 1 downto 0 do
    if IsCollectionItemNode(TreeList.Selections[i]) then
    begin
      Item := GetCollectionItem(TreeList.Selections[i]);
      idx := Collection.FindItemID(Item.ID).Index;
      Collection.Delete(idx);
      TreeList.Selections[i].Delete;
    end;
end;

procedure TFrameTreeList.InsertItem;
var
  Collection: TzCustomCollection;
  Item: TzCollectionItem;
  node: TcxTreeListNode;
  ImageIndex: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    exit;

  node := GetCollectionNode(SelectedNode);
  if not Assigned(node) then
    exit;

  ImageIndex := node.ImageIndex;
  Item := Collection.CreateItem;

  if Item.Name = '' then
    Item.Name := 'Nuovo';

  node := node.AddChild;

  node.texts[0] := Item.Name;
  node.Data := Item;
  node.ImageIndex := ImageIndex;
  node.SelectedIndex := ImageIndex;
  node.Selected := true;
  node.MakeVisible;
end;

procedure TFrameTreeList.SelectCollection(zCollection: TzCustomCollection);

var
  i: Integer;
begin
  if not Assigned(zCollection) then
    exit;

  TreeList.SetFocus;

  for i := 0 to TreeList.AbsoluteCount - 1 do
    if IsCollectionNode(TreeList.AbsoluteItems[i]) then
      if GetCollection(TreeList.AbsoluteItems[i]) = zCollection then
      begin
        TreeList.Items[i].MakeVisible;
        TreeList.Items[i].Selected := true;
        TreeList.Items[i].Focused := true;
        TreeList.Items[i].Expand(true);
        Break;
      end;
end;

procedure TFrameTreeList.SelectCollectionItem(Item: TzCollectionItem);

var
  i: Integer;
begin
  if not Assigned(Item) then
    exit;

  TreeList.SetFocus;

  for i := 0 to TreeList.AbsoluteCount - 1 do
    if IsCollectionItemNode(TreeList.AbsoluteItems[i]) then
      if GetCollectionItem(TreeList.AbsoluteItems[i]).ID = Item.ID then
      begin
        TreeList.Items[i].MakeVisible;
        TreeList.Items[i].Selected := true;
        TreeList.Items[i].Focused := true;
        Break;
      end;
end;

procedure TFrameTreeList.DuplicateItem;
var
  Collection: TzCustomCollection;
  ItemToCopy, Item: TzCollectionItem;
  node: TcxTreeListNode;
  s: string;
  ImageIndex: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    exit;

  node := GetCollectionNode(SelectedNode);
  if not Assigned(node) then
    exit;

  ItemToCopy := GetCollectionItem(SelectedNode);
  if not Assigned(ItemToCopy) then
    exit;

  ImageIndex := node.ImageIndex;
  s := 'Nuovo...';
  Item := Collection.CreateItem;
  Item.Assign(ItemToCopy);
  Item.Name := s;

  node := node.AddChild;
  node.texts[0] := s;
  node.Data := Item;
  node.ImageIndex := ImageIndex;
  node.SelectedIndex := ImageIndex;
  node.Selected := true;
  node.MakeVisible;
end;

procedure TFrameTreeList.SetCheckBoxes(const Value: Boolean);
begin
  if FCheckBoxes <> Value then
  begin
    FCheckBoxes := Value;
    if Value then
    begin
      // potrebbe essere riassegnata
      // if not Assigned(TreeList.Images) then
      // TreeList.Images := CheckImages;

      if not Assigned(TreeList.StateImages) then
        TreeList.StateImages := CheckImages;
    end
    else
    begin
      // potrebbe essere riassegnata
      // if TreeList.Images = CheckImages then
      // TreeList.Images := nil;

      if TreeList.StateImages = CheckImages then
        TreeList.StateImages := nil;
    end;
  end;
end;

procedure TFrameTreeList.ToggleChecked(node: TcxTreeListNode);
var
  Allow: Boolean;
begin
  if CheckBoxes then
    if Assigned(node) then
    begin
      SetChecked(node, not IsChecked(node));

      if Assigned(FOnNodeChecked) then
      begin
        Allow := true;
        FOnNodeChecked(TreeList, node, Allow);
      end;
    end;
end;

function TFrameTreeList.IsChecked(node: TcxTreeListNode): Boolean;
begin
  Result := False;
  if Assigned(node) then
    Result := node.StateIndex = imgChecked;
end;

procedure TFrameTreeList.SetChecked(node: TcxTreeListNode; const Checked: Boolean);
begin
  if not Assigned(node) then
    exit;

  if Checked then
    node.StateIndex := imgChecked
  else
    node.StateIndex := imgUnchecked;
end;

procedure TFrameTreeList.TreeListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  node: TcxTreeListNode;
begin

  if CheckBoxes then
    if (Key = VK_SPACE) then
    begin
      node := SelectedNode;

      if Assigned(node) then
        ToggleChecked(node);
    end;
end;

procedure TFrameTreeList.TreeListCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
begin

  if Assigned(FOnBeforeSelectNode) then
    OnBeforeSelectNode(Sender, ANode, Allow);
end;

procedure TFrameTreeList.TreeListSelectionChanged(Sender: TObject);
begin
  if Assigned(FOnSelectNode) then
    OnSelectNode(Sender);
end;

procedure TFrameTreeList.TreeListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetNode, SourceNode: TcxTreeListNode;
begin
  if (Y < 15) then
  begin
    SendMessage(TreeList.Handle, WM_VSCROLL, SB_LINEUP, 0);
    Application.ProcessMessages;
  end
  else
    if (TreeList.Height - Y < 15) then
    begin
      SendMessage(TreeList.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
      Application.ProcessMessages;
    end;

  Accept := False;

  if Sender <> TreeList then
    exit;

  TargetNode := TreeList.GetNodeAt(X, Y); // Get target node
  SourceNode := SelectedNode; // le opzioni non consentono l di fuori del nodo

  if not Assigned(SourceNode) then
    exit;

  if not Assigned(TargetNode) then
    exit;

  if not IsCollectionItemNode(SourceNode) then
    exit;

  if GetCollectionFromNode(TargetNode) = GetCollectionFromNode(SourceNode) then
    Accept := true;
end;

procedure TFrameTreeList.TreeListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Collection: TzCustomCollection;
  DestIndex: Integer;
  TargetNode, SourceNode: TcxTreeListNode;
  i: Integer;
  list: TList;
  node: TcxTreeListNode;
  SrcIndex: Integer;
begin
  TargetNode := TreeList.GetNodeAt(X, Y); // Get target node

  if (TargetNode = nil) then
  begin
    TreeList.EndDrag(False);
    exit;
  end;

  Collection := GetCollection(TargetNode);
  if not Assigned(Collection) then
    exit;

  list := TList.Create;
  try
    for i := 0 to TreeList.SelectionCount - 1 do
      list.Add(TreeList.Selections[i]);

    TreeList.BeginUpdate;
    try
      for i := 0 to list.count - 1 do
      begin
        node := TcxTreeListNode(list[i]);

        SrcIndex := node.Index;
        node.MoveTo(TargetNode, tlamInsert);
        DestIndex := node.Index;

        Collection.Move(SrcIndex, DestIndex);
        node.MakeVisible;

        if CheckBoxes then
        begin
          ToggleChecked(node);
          ToggleChecked(node);
        end;
      end;
    finally
      TreeList.EndUpdate;
    end;
  finally
    FreeAndNil(list);
  end;
end;

procedure TFrameTreeList.AddCollection(zCollection: TzCustomCollection);
begin
  SiMain.EnterMethod(Self, 'AddCollection');
  try
    if not Assigned(zCollection) then
      exit;

    SiMain.LogString(zCollection.ClassName, zCollection.Name);
    zCollection.FillTreeList(TreeList.Root);
  finally
    SiMain.LeaveMethod(Self, 'AddCollection');
  end;
end;

end.
