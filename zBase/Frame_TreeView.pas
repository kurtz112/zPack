unit Frame_TreeView;

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
  System.ImageList,
  cxGraphics,
  Vcl.StdCtrls,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxTreeView,
  cxImageList,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TFrameTreeView = class(TFrame)
    TreeView: TcxTreeView;
    CheckImages: TcxImageList;
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeViewChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure TreeViewClick(Sender: TObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCheckBoxes: Boolean;
    FImageList: TImageList;
    FOnSelectNode: TTVChangedEvent;
    FOnBeforeSelectNode: TTVChangingEvent;
    FOnNodeChecked: TTVChangedEvent;
    procedure SetImageList(const Value: TImageList);
    procedure SetOnSelectNode(const Value: TTVChangedEvent);
    function GetSelectedNode: TTreeNode;
    procedure SetCheckBoxes(const Value: Boolean);
    procedure SetSelectedNode(const Value: TTreeNode);
    procedure SetOnBeforeSelectNode(const Value: TTVChangingEvent);
    procedure SetOnNodeChecked(const Value: TTVChangedEvent);
  public
    constructor Create(aOwner: TComponent); override;
    // collection
    function IsCollectionNode(Node: TTreeNode): Boolean;
    function GetCollectionFromNode(Node: TTreeNode): TzCustomCollection;
    function GetCollectionNode(Node: TTreeNode): TTreeNode;
    function GetCollection(Node: TTreeNode): TzCustomCollection;

    // item
    function IsCollectionItemNode(Node: TTreeNode): Boolean;
    function GetCollectionItem(Node: TTreeNode): TzCollectionItem;

    function FindNode(Item: TzCollectionItem): TTreeNode;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure Clear;
    procedure InsertItem;
    procedure DeleteItem;
    procedure DuplicateItem;

    function IsChecked(Node: TTreeNode): Boolean;
    procedure SetChecked(Node: TTreeNode; const Checked: Boolean);
    procedure ToggleChecked(Node: TTreeNode);

    procedure SelectCollectionItem(Item: TzCollectionItem);
    procedure SelectCollection(zCollection: TzCustomCollection);
    procedure AddCollection(zCollection: TzCustomCollection);

    property SelectedNode: TTreeNode read GetSelectedNode write SetSelectedNode;
  published
    property CheckBoxes: Boolean read FCheckBoxes write SetCheckBoxes;
    property ImageList: TImageList read FImageList write SetImageList;
    property OnSelectNode: TTVChangedEvent read FOnSelectNode write SetOnSelectNode;
    property OnBeforeSelectNode: TTVChangingEvent read FOnBeforeSelectNode write SetOnBeforeSelectNode;
    property OnNodeChecked: TTVChangedEvent read FOnNodeChecked write SetOnNodeChecked;
  end;

implementation

uses
  Winapi.CommCtrl;

{$R *.dfm}
{ TFrameTreeView }

const
  imgUnchecked = 1;
  imgChecked = 2;

constructor TFrameTreeView.Create(aOwner: TComponent);
begin
  inherited;
  FCheckBoxes := False;
  FImageList := nil;
  FOnSelectNode := nil;
  FOnBeforeSelectNode := nil;
  FOnNodeChecked := nil;
end;

procedure TFrameTreeView.AddCollection(zCollection: TzCustomCollection);
begin
  SiMain.EnterMethod(Self, 'AddCollection');
  if not Assigned(zCollection) then
    exit;

  SiMain.LogString(zCollection.ClassName, zCollection.Name);

// KILL  zCollection.FillTreeView(TreeView.Items);
  SiMain.LeaveMethod(Self, 'AddCollection');
end;

procedure TFrameTreeView.BeginUpdate;
begin
  TreeView.Items.BeginUpdate;
end;

procedure TFrameTreeView.EndUpdate;
begin
  TreeView.Items.EndUpdate;
end;

function TFrameTreeView.FindNode(Item: TzCollectionItem): TTreeNode;
var
  i: Integer;
begin
  Result := nil;
  if not Assigned(Item) then
    exit;
  for i := 0 to TreeView.Items.Count - 1 do
    if IsCollectionItemNode(TreeView.Items[i]) then
      if GetCollectionItem(TreeView.Items[i]).ID = Item.ID then
      begin
        Result := TreeView.Items[i];
        Break;
      end;
end;

procedure TFrameTreeView.Clear;
begin
  TreeView.Items.BeginUpdate;
  try
    TreeView.OnChanging := nil;
    TreeView.OnChange := nil;
    try
      TreeView.Items.Clear;
    finally
      TreeView.OnChanging := TreeViewChanging;
      TreeView.OnChange := TreeViewChange;
    end;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TFrameTreeView.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
  TreeView.Images := Value;
end;

procedure TFrameTreeView.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  SiMain.EnterMethod(Self, 'TreeViewChange');

  if Assigned(FOnSelectNode) then
    OnSelectNode(Sender, Node);

  SiMain.LeaveMethod(Self, 'TreeViewChange');
end;

procedure TFrameTreeView.TreeViewChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
  SiMain.EnterMethod(Self, 'TreeViewChanging');

  if Assigned(FOnBeforeSelectNode) then
    OnBeforeSelectNode(Sender, Node, AllowChange);

  SiMain.LeaveMethod(Self, 'TreeViewChanging');
end;

procedure TFrameTreeView.SetOnSelectNode(const Value: TTVChangedEvent);
begin
  FOnSelectNode := Value;
end;

procedure TFrameTreeView.TreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetNode, SourceNode: TTreeNode;
begin
  if (Y < 15) then
  begin
    SendMessage(TreeView.Handle, WM_VSCROLL, SB_LINEUP, 0);
    Application.ProcessMessages;
  end
  else
    if (TreeView.Height - Y < 15) then
    begin
      SendMessage(TreeView.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
      Application.ProcessMessages;
    end;

  Accept := False;

  if Sender <> TreeView then
    exit;

  TargetNode := TreeView.GetNodeAt(X, Y); // Get target node
  SourceNode := TreeView.Selected; // le opzioni non consentono l di fuori del nodo

  if not Assigned(SourceNode) then
    exit;

  if not Assigned(TargetNode) then
    exit;

  if not IsCollectionItemNode(SourceNode) then
    exit;

  if GetCollectionFromNode(TargetNode) = GetCollectionFromNode(SourceNode) then
    Accept := true;
end;

procedure TFrameTreeView.TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Collection: TzCustomCollection;
  DestIndex: Integer;
  TargetNode, SourceNode: TTreeNode;
  i: Integer;
  list: TList;
  Node: TTreeNode;
  SrcIndex: Integer;

begin
  TargetNode := TreeView.GetNodeAt(X, Y); // Get target node

  if (TargetNode = nil) then
  begin
    TreeView.EndDrag(False);
    exit;
  end;

  Collection := GetCollection(TargetNode);
  if not Assigned(Collection) then
    exit;

  list := TList.Create;
  try
    for i := 0 to TreeView.Items.Count - 1 do
      if TreeView.Items[i].Selected then
        list.Add(TreeView.Items[i]);

    TreeView.Items.BeginUpdate;
    try
      for i := 0 to list.Count - 1 do
      begin
        Node := TTreeNode(list[i]);

        SrcIndex := Node.Index;
        Node.MoveTo(TargetNode, naInsert);
        DestIndex := Node.Index;

        Collection.Move(SrcIndex, DestIndex);
        Node.MakeVisible;

        if CheckBoxes then
        begin
          ToggleChecked(Node);
          ToggleChecked(Node);
        end;
      end;
    finally
      TreeView.Items.EndUpdate;
    end;
  finally
    FreeAndNil(list);
  end;
end;

function TFrameTreeView.GetCollectionFromNode(Node: TTreeNode): TzCustomCollection;

var
  Persistent: TPersistent;
begin
  Result := nil;
  if not Assigned(Node) then
    exit;

  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCustomCollection then
    begin
      Result := TzCustomCollection(Persistent);
    end;
end;

function TFrameTreeView.GetCollection(Node: TTreeNode): TzCustomCollection;

var
  tmp: TTreeNode;
  Item: TzCollectionItem;
begin
  Result := nil;

  if not Assigned(tmp) then
    exit;

  tmp := Node;
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
    Item := GetCollectionItem(Node);
    if Assigned(Item) then
      if Item.Collection is TzCustomCollection then
        Result := TzCustomCollection(Item.Collection);
  end;
end;

function TFrameTreeView.GetCollectionItem(Node: TTreeNode): TzCollectionItem;

var
  Persistent: TPersistent;
begin
  Result := nil;

  if not Assigned(Node) then
    exit;

  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCollectionItem then
      Result := Persistent as TzCollectionItem;
end;

function TFrameTreeView.IsCollectionNode(Node: TTreeNode): Boolean;

var
  Persistent: TPersistent;
begin
  Result := False;
  if not Assigned(Node) then
    exit;

  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCustomCollection then
      Result := true;
end;

function TFrameTreeView.IsCollectionItemNode(Node: TTreeNode): Boolean;

var
  Persistent: TPersistent;
begin
  Result := False;
  if not Assigned(Node) then
    exit;

  Persistent := TPersistent(Node.Data);
  if Assigned(Persistent) then
    if Persistent is TzCollectionItem then
      Result := true;
end;

function TFrameTreeView.GetCollectionNode(Node: TTreeNode): TTreeNode;
begin
  Result := nil;

  if not Assigned(Node) then
    exit;

  while not IsCollectionNode(Node) do
  begin
    Node := Node.Parent;
    if not Assigned(Node) then
      Break;
  end;

  Result := Node;
end;

function TFrameTreeView.GetSelectedNode: TTreeNode;
begin
  Result := TreeView.Selected;
end;

procedure TFrameTreeView.SetSelectedNode(const Value: TTreeNode);
begin
  TreeView.Selected := Value;
end;

procedure TFrameTreeView.DeleteItem;

var
  i: Integer;
  Collection: TzCustomCollection;
  Item: TzCollectionItem;
  idx: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    exit;

  for i := TreeView.SelectionCount - 1 downto 0 do
    if IsCollectionItemNode(TreeView.Selections[i]) then
    begin
      Item := GetCollectionItem(TreeView.Selections[i]);
      idx := Collection.FindItemID(Item.ID).Index;
      Collection.Delete(idx);
      TreeView.Selections[i].Delete;
    end;
end;

procedure TFrameTreeView.InsertItem;

var
  Collection: TzCustomCollection;
  Item: TzCollectionItem;
  Node: TTreeNode;
  ImageIndex: Integer;
begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    exit;

  Node := GetCollectionNode(SelectedNode);
  if not Assigned(Node) then
    exit;

  ImageIndex := Node.ImageIndex;
  Item := Collection.CreateItem;

  if Item.Name = '' then
    Item.Name := 'Nuovo';

  Node := TreeView.Items.AddChildObject(Node, Item.Name, Item);

  Node.ImageIndex := ImageIndex;
  Node.SelectedIndex := ImageIndex;
  Node.Selected := true;
  Node.MakeVisible;
end;

procedure TFrameTreeView.SelectCollection(zCollection: TzCustomCollection);

var
  i: Integer;
begin
  if not Assigned(zCollection) then
    exit;

  TreeView.SetFocus;

  for i := 0 to TreeView.Items.Count - 1 do
    if IsCollectionNode(TreeView.Items[i]) then
      if GetCollection(TreeView.Items[i]) = zCollection then
      begin
        TreeView.Items[i].MakeVisible;
        TreeView.Items[i].Selected := true;
        TreeView.Items[i].Focused := true;
        TreeView.Items[i].Expand(true);
        Break;
      end;
end;

procedure TFrameTreeView.SelectCollectionItem(Item: TzCollectionItem);

var
  i: Integer;
begin
  if not Assigned(Item) then
    exit;

  TreeView.SetFocus;

  for i := 0 to TreeView.Items.Count - 1 do
    if IsCollectionItemNode(TreeView.Items[i]) then
      if GetCollectionItem(TreeView.Items[i]).ID = Item.ID then
      begin
        TreeView.Items[i].MakeVisible;
        TreeView.Items[i].Selected := true;
        TreeView.Items[i].Focused := true;
        Break;
      end;
end;

procedure TFrameTreeView.DuplicateItem;

var
  Collection: TzCustomCollection;
  ItemToCopy, Item: TzCollectionItem;
  Node: TTreeNode;
  s: string;
  ImageIndex: Integer;

begin
  Collection := GetCollection(SelectedNode);
  if not Assigned(Collection) then
    exit;

  Node := GetCollectionNode(SelectedNode);
  if not Assigned(Node) then
    exit;

  ItemToCopy := GetCollectionItem(SelectedNode);
  if not Assigned(ItemToCopy) then
    exit;

  ImageIndex := Node.ImageIndex;
  s := 'Nuovo...';
  Item := Collection.CreateItem;
  Item.Assign(ItemToCopy);
  Item.Name := s;
  Node := TreeView.Items.AddChildObject(Node, s, Item);

  Node.ImageIndex := ImageIndex;
  Node.SelectedIndex := ImageIndex;
  Node.Selected := true;
  Node.MakeVisible;
end;

procedure TFrameTreeView.SetCheckBoxes(const Value: Boolean);
begin
  if FCheckBoxes <> Value then
  begin
    FCheckBoxes := Value;
    if Value then
    begin
      // potrebbe essere riassegnata
      // if not Assigned(TreeView.Images) then
      // TreeView.Images := CheckImages;

      if not Assigned(TreeView.StateImages) then
        TreeView.StateImages := CheckImages;
    end
    else
    begin
      // potrebbe essere riassegnata
      // if TreeView.Images = CheckImages then
      // TreeView.Images := nil;

      if TreeView.StateImages = CheckImages then
        TreeView.StateImages := nil;
    end;
  end;
end;

procedure TFrameTreeView.SetOnBeforeSelectNode(const Value: TTVChangingEvent);
begin
  FOnBeforeSelectNode := Value;
end;

procedure TFrameTreeView.TreeViewClick(Sender: TObject);

var
  P: TPoint;
begin
  if CheckBoxes then
  begin
    GetCursorPos(P);
    P := TreeView.ScreenToClient(P);
    if (htOnStateIcon in TreeView.GetHitTestInfoAt(P.X, P.Y)) then
      ToggleChecked(TreeView.Selected);
  end;
end;

procedure TFrameTreeView.ToggleChecked(Node: TTreeNode);

var
  tmp: TTreeNode;
begin
  if CheckBoxes then
    if Assigned(Node) then
    begin
      SetChecked(Node, not IsChecked(Node));

      if Assigned(FOnNodeChecked) then
        OnNodeChecked(Self, Node);
    end;
end;

function TFrameTreeView.IsChecked(Node: TTreeNode): Boolean;
begin
  Result := False;
  if Assigned(Node) then
    Result := Node.StateIndex = imgChecked;
end;

procedure TFrameTreeView.SetChecked(Node: TTreeNode; const Checked: Boolean);
begin
  if not Assigned(Node) then
    exit;

  if Checked then
    Node.StateIndex := imgChecked
  else
    Node.StateIndex := imgUnchecked;
end;

procedure TFrameTreeView.TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if CheckBoxes then
    if (Key = VK_SPACE) and Assigned(TreeView.Selected) then
      ToggleChecked(TreeView.Selected);
end;

procedure TFrameTreeView.SetOnNodeChecked(const Value: TTVChangedEvent);
begin
  FOnNodeChecked := Value;
end;

end.
