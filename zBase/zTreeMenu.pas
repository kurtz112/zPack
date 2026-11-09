unit zTreeMenu;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  Vcl.ExtCtrls,
  cxTextEdit,
  cxMaskEdit,
  cxButtonEdit,
  Vcl.ComCtrls,
  zSystem,
  Vcl.ImgList,
  dxSkinsCore,
  Vcl.ActnList,
  dxBar,
  dxSkinsdxBarPainter,
  System.Actions,
  cxClasses,
  System.ImageList,
  cxTreeView,
  zWaitFrm,
  cxImageList,
  zTimers,
  dxActivityIndicator,
  dxCore,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  Vcl.Menus,
  Vcl.StdCtrls,
  cxButtons,
  cxDropDownEdit,
  cxBarEditItem,
  cxFilter,
  dxUIAClasses;

const
  MSG_Width_Changed = WM_USER + 893;

type
  TWidthChanged = procedure(Sender: TObject; const NewWidth: integer) of object;
  TBeforeDisplayItem = procedure(Sender: TObject; item: TzDiagramDataSet; var Allow: boolean) of object;

  TzTreeMenu = class(TFrame)
    PopupMenu: TdxBarPopupMenu;
    dxBarManager: TdxBarManager;
    ActionList: TActionList;
    actRename: TAction;
    dxBarButton1: TdxBarButton;
    Espandi: TAction;
    Comprimi: TAction;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    actGroup: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    actSalva: TAction;
    dxBarButton8: TdxBarButton;
    TreeImages: TcxImageList;
    EspandiAutomaticamente: TAction;
    dxBarButton9: TdxBarButton;
    tree: TcxTreeList;
    treeColumn: TcxTreeListColumn;
    Proprieta: TAction;
    dxBarButton10: TdxBarButton;
    CopiaTitoli: TAction;
    dxBarButton11: TdxBarButton;
    Markdown: TAction;
    dxBarButton12: TdxBarButton;
    procedure actGroupExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure ComprimiExecute(Sender: TObject);
    procedure EspandiExecute(Sender: TObject);
    procedure actRenameExecute(Sender: TObject);
    procedure actSalvaExecute(Sender: TObject);
    procedure CopiaTitoliExecute(Sender: TObject);
    procedure treeCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: boolean);
    procedure treeClick(Sender: TObject);
    procedure treeDblClick(Sender: TObject);
    procedure treeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EspandiAutomaticamenteExecute(Sender: TObject);
    procedure EspandiAutomaticamenteUpdate(Sender: TObject);
    procedure MarkdownExecute(Sender: TObject);
    procedure ProprietaExecute(Sender: TObject);
    procedure treeMouseEnter(Sender: TObject);
    procedure treeMouseLeave(Sender: TObject);
    procedure VisibleIfAdmin(Sender: TObject);
  private
    busy: boolean;
    FAutoWidth: boolean;
    FOnBeforeDisplayItem: TBeforeDisplayItem;
    FOnWidthChanged: TWidthChanged;
    FOnDblClick: TNotifyEvent;
    FOnSelect: TNotifyEvent;
    FSelected: string;
    FzDataModule: TzDataModule;
    FzSystem: TzSystem;
    function IsAdmin: boolean;
    procedure doSelect(const aSelected: string);
    procedure doDblClick(const aSelected: string);
    function doBeforeDisplayItem(item: TzDiagramDataSet): boolean;
    procedure doLoadMenu;
  private
    LastExpandedNode: TcxTreeListNode;
    FAutoExpand: boolean;
    IsDestroying: boolean;
    IsSelecting: boolean;
    Timers: TTimers;
    procedure NodeSelected(const SelectFirstChild: boolean);
    function IsDataSetNode(Node: TcxTreeListNode): boolean;
    function GetDataSet(Node: TcxTreeListNode): TzDiagramDataSet;
    function GetSelectedDataSet: TzDiagramDataSet;
    function GetSelectedDataSetName: string;
    procedure SetSelectedDataSetName(const Value: string);
  private
    procedure doCalculateWidth(var Message: TMessage); message MSG_Width_Changed;
  private
    procedure SetAutoExpand(const Value: boolean);
  protected
  public
    constructor Create(aOWner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadMenu;
    function GetMenuItems: string;
    procedure Translated;
    procedure CalculateWidth;
    function GetDatasetNameAt(const X, Y: integer): String;
    procedure SelectDataSet(const aDataSetName: string; const doCallEvent: boolean);
    property Selected: string read FSelected;
    property SelectedDataSet: TzDiagramDataSet read GetSelectedDataSet;

    property AutoWidth: boolean read FAutoWidth write FAutoWidth default true;
    property AutoExpand: boolean read FAutoExpand write SetAutoExpand default false;

    property SelectedDataSetName: string read GetSelectedDataSetName write SetSelectedDataSetName;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnWidthChanged: TWidthChanged read FOnWidthChanged write FOnWidthChanged;
    property OnBeforeDisplayItem: TBeforeDisplayItem read FOnBeforeDisplayItem write FOnBeforeDisplayItem;
    property zDataModule: TzDataModule read FzDataModule write FzDataModule;
    property zSystem: TzSystem read FzSystem write FzSystem;
  end;

implementation

uses
  System.Math,
  cxFindPanel,
  zFrmInspector,
  zRestrictions.Types,
  zdx,
  zLocalizer,
  Vcl.Clipbrd,
  System.StrUtils,
  zMsg;

{$R *.dfm}

Type
  TcxTreeListAccess = class(TcxTreeList);

constructor TzTreeMenu.Create(aOWner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  busy := false;
  IsDestroying := false;
  IsSelecting := false;
  FSelected := '';
  FOnSelect := nil;
  FOnDblClick := nil;
  FOnBeforeDisplayItem := nil;
  FOnWidthChanged := nil;
  FAutoWidth := true;
  FAutoExpand := false;
  LastExpandedNode := nil;

  FzDataModule := nil;
  FzSystem := nil;

  Timers := TTimers.Create(Self);

  { TODO : AutoExpand }
  // Tree.AutoExpand := AutoExpand;

  dx.InitTreeList(tree, true);
  tree.Styles.Background := dx.cxStyleContent;
  tree.Styles.Content := dx.cxStyleContent;
  // tree.Styles.ContentEven := dx.cxStyleContentEven;
  // tree.Styles.ContentOdd := dx.cxStyleContentOdd;
  tree.Styles.FilterBox := dx.cxStyleFilterBox;

  tree.FindPanel.DisplayMode := fpdmNever;
end;

destructor TzTreeMenu.Destroy;
begin
  // RootLookAndFeel.RemoveChangeListener(Self);
  IsDestroying := true;
  FreeAndNil(Timers);
  inherited;
end;

procedure TzTreeMenu.Clear;
begin
  busy := true;
  try
    tree.Clear;
  finally
    busy := false;
  end;
end;

function TzTreeMenu.GetDataSet(Node: TcxTreeListNode): TzDiagramDataSet;
begin
  Result := nil;

  if IsDataSetNode(Node) then
    Result := TzDiagramDataSet(Node.Data);
end;

function TzTreeMenu.GetSelectedDataSet: TzDiagramDataSet;
begin
  Result := nil;

  if tree.SelectionCount > 0 then
    Result := GetDataSet(tree.Selections[0]);
end;

procedure TzTreeMenu.doDblClick(const aSelected: string);
begin
  FSelected := aSelected;

  if Assigned(FOnDblClick) then
    OnDblClick(Self);
end;

procedure TzTreeMenu.LoadMenu;
begin
  if Assigned(zDataModule) then
  begin

    if zDataModule.ControllerOptions.TreeMenuSearchVisible then
      tree.FindPanel.DisplayMode := fpdmAlways
    else
      tree.FindPanel.DisplayMode := fpdmManual;

    AutoExpand := zDataModule.ControllerOptions.TreeMenuAutoExpand;
  end;

  doLoadMenu;
  CalculateWidth;
  // lo perde durante il caricamento
  tree.OnClick := treeClick;
end;

procedure TzTreeMenu.VisibleIfAdmin(Sender: TObject);
begin
  TAction(Sender).Visible := IsAdmin;
end;

procedure TzTreeMenu.EspandiExecute(Sender: TObject);
begin
  tree.FullExpand;
  CalculateWidth;
end;

procedure TzTreeMenu.ComprimiExecute(Sender: TObject);
begin
  tree.FullCollapse;
  CalculateWidth;
end;

procedure TzTreeMenu.actRenameExecute(Sender: TObject);
var
  zDataSet: TzDiagramDataSet;
  Caption: string;
  i: integer;
begin

  if tree.SelectionCount = 0 then
    exit;

  Caption := tree.Selections[0].texts[0];

  if not InputQuery('Caption', 'Caption', Caption) then
    exit;

  zDataSet := GetSelectedDataSet;
  if Assigned(zDataSet) then
  begin
    // Dataset, si cambia il Caption
    zDataSet.menu.Caption := Caption;
    tree.Selections[0].texts[0] := Caption;
  end
  else
  begin
    // nodo, si cambia il group agli eventuali dataset
    tree.Selections[0].texts[0] := Caption;

    for i := 0 to tree.SelectionCount - 1 do
    begin
      zDataSet := GetDataSet(tree.Selections[0]);
      if Assigned(zDataSet) then
        zDataSet.menu.Group := Caption;
    end;
  end;
end;

procedure TzTreeMenu.actGroupExecute(Sender: TObject);
var
  zDataSet: TzDiagramDataSet;
  gruppo: string;
begin
  zDataSet := GetSelectedDataSet;
  if Assigned(zDataSet) then
    if InputQuery('Gruppo', 'Gruppo', gruppo) then
    begin
      zDataSet.menu.Group := gruppo;
      LoadMenu;
    end;
end;

procedure TzTreeMenu.actSalvaExecute(Sender: TObject);
begin
  StartWait('Attendere...', true);
  try
    zDataModule.SaveToBase(true);
  finally
    StopWait;
  end;
end;

procedure TzTreeMenu.treeCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: boolean);
var
  zDataSet: TzDiagramDataSet;
begin
  if IsSelecting then
  begin
    Allow := false;
    exit;
  end;
  /// ///////////////////////////////////////////////////
  exit; // 07.03.2019: implementazione selectFirstChild
  /// ///////////////////////////////////////////////////
  zDataSet := GetDataSet(ANode);

  if Assigned(zDataSet) then
    Allow := zDataSet.IsMenuLeaf;
end;

procedure TzTreeMenu.treeClick(Sender: TObject);
begin
  NodeSelected(true);
end;

procedure TzTreeMenu.treeDblClick(Sender: TObject);
var
  zDataSet: TzDiagramDataSet;
begin
  zDataSet := GetSelectedDataSet;

  if Assigned(zDataSet) then
    if zDataSet.IsMenuLeaf then
      doDblClick(zDataSet.Name);
end;

procedure TzTreeMenu.treeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SiMain.EnterMethod(Self, 'TreeKeyUp');

  if Key >= 32 then
  begin
    SiMain.LogInteger('TreeKeyUp', Key);
    NodeSelected(false);
  end;

  SiMain.LeaveMethod(Self, 'TreeKeyUp');
end;

function TzTreeMenu.doBeforeDisplayItem(item: TzDiagramDataSet): boolean;
begin
  Result := true;
  if Assigned(FOnBeforeDisplayItem) then
    OnBeforeDisplayItem(Self, item, Result);
end;

procedure TzTreeMenu.CalculateWidth;
begin
  PostMessage(Self.Handle, MSG_Width_Changed, 0, 0);
end;

procedure TzTreeMenu.doCalculateWidth(var Message: TMessage);
const
  MinWidth = 50;
var
  info: ScrollInfo;
  oldWidth: integer;
  i: integer;
  w: integer;
begin
  if not AutoWidth then
    exit;

  tree.OptionsView.ColumnAutoWidth := false; // se per errore è stato impostato

  tree.ApplyBestFit;
  treeColumn.ApplyBestFit;

  w := 7 + treeColumn.Width;

  // if TcxTreeListAccess(tree).VScrollBarVisible then
  w := w + TcxTreeListAccess(tree).VScrollBar.Width;

  w := Max(w, MinWidth);

  if Self.Width <> w then
    Self.Width := w;

  if Assigned(FOnWidthChanged) then
    OnWidthChanged(Self, w);
end;

function TzTreeMenu.GetSelectedDataSetName: string;
var
  DataSet: TzDiagramDataSet;
begin
  Result := '';

  DataSet := GetSelectedDataSet;

  if Assigned(DataSet) then
    Result := DataSet.Name;
end;

function TzTreeMenu.IsAdmin: boolean;
begin
  Result := false;

  if Assigned(FzSystem) then
    Result := zSystem.IsAdmin;
end;

function TzTreeMenu.IsDataSetNode(Node: TcxTreeListNode): boolean;
begin
  Result := false;
  if Assigned(Node) then
    if Assigned(Node.Data) then
      if (TObject(Node.Data) is TzDiagramDataSet) then
        Result := true;
end;

procedure TzTreeMenu.SelectDataSet(const aDataSetName: string; const doCallEvent: boolean);

  procedure SelectNode(Node: TcxTreeListNode; const DataSetName: string; const doCallEvent: boolean);
  begin
    tree.clearSelection;
    Node.MakeVisible;
    Node.Selected := true;
    FSelected := DataSetName;

    if doCallEvent then
      NodeSelected(true);
  end;

var
  Node, first: TcxTreeListNode;
  DataSet: TzDiagramDataSet;
  DataSetName: string;
  i: integer;
begin
  DataSetName := aDataSetName;

  // se il datasetName non è una leaf lo sostituisce con la prima del dataset
  DataSet := zDataModule.DataSets.Get(DataSetName, false);
  if Assigned(DataSet) then
    if not DataSet.IsMenuLeaf then
      if DataSet.HasDetailDataSets then
        DataSetName := DataSet.DetailDatasets[0].Name;
  /// /// \leaf

  first := nil;

  for i := 0 to tree.AbsoluteCount - 1 do
  begin
    Node := tree.AbsoluteItems[i];
    DataSet := GetDataSet(Node);

    if Assigned(DataSet) then
      if DataSet.IsMenuLeaf then
      begin
        if not Assigned(first) then
          first := Node;

        if SameText(DataSetName, DataSet.Name) then
        begin
          SelectNode(Node, DataSetName, doCallEvent);
          exit;
        end;
      end;
  end;

  // se non ha trovato nulla lo sposta al primo
  if Assigned(first) then
    SelectNode(first, DataSetName, doCallEvent);
end;

procedure TzTreeMenu.SetSelectedDataSetName(const Value: string);
begin
  SelectDataSet(Value, true);
end;

function TzTreeMenu.GetDatasetNameAt(const X, Y: integer): String;
var
  DataSet: TzDiagramDataSet;
  Node: TcxTreeListNode;
begin
  Result := '';

  Node := tree.GetNodeAt(X, Y);

  while Assigned(Node) do
  begin
    DataSet := GetDataSet(Node);

    if Assigned(DataSet) then
    begin
      Result := DataSet.Name;
      exit;
    end
    else
      Node := Node.Parent;
  end;
end;

procedure TzTreeMenu.doLoadMenu;
var
  first: TcxTreeListNode;

  function GetParentNode(ParentNode: TcxTreeListNode; Group: string): TcxTreeListNode;
  var
    i: integer;
  begin
    Result := nil;

    if Group = '' then
      Result := ParentNode
    else
    begin
      if Assigned(ParentNode) then
      begin
        for i := 0 to ParentNode.Count - 1 do
          if SameText(ParentNode[i].texts[0], Group) then
            exit(ParentNode[i]);
      end
      else
      begin
        for i := 0 to tree.AbsoluteCount - 1 do
          if SameText(tree.AbsoluteItems[i].texts[0], Group) then
            exit(tree.AbsoluteItems[i]);
      end;
    end;
  end;

  procedure Enum(ParentNode: TcxTreeListNode; menu: TzDiagramDataSets; MenuFilter: string);
  var
    i: integer;
    item: TzDiagramDataSet;
    Node: TcxTreeListNode;
    RealParentNode: TcxTreeListNode;
  begin

    for i := 0 to menu.Count - 1 do
    begin
      item := menu.Items[i];

      if item.menu.Visible then
        if item.ActualAccessLevel <> TAccessLevel.alNone then
          if item.MenuFilterOk(MenuFilter) then
            if doBeforeDisplayItem(item) then
            begin
              RealParentNode := GetParentNode(ParentNode, item.menu.GetGroup);

              // se non esiste lo crea
              if not Assigned(RealParentNode) then
                if not item.menu.GetGroup.IsEmpty then
                begin
                  RealParentNode := tree.AddChild(ParentNode, nil);
                  RealParentNode.texts[0] := item.menu.GetGroup;
                  RealParentNode.ImageIndex := 0;
                  RealParentNode.SelectedIndex := 0;
                end;

              Node := tree.AddChild(RealParentNode, item);
              Node.texts[0] := item.menu.GetCaption;

              /// //////////////////////////////////////////////////////////////////////////

              Node.SelectedIndex := 3;
              Node.ImageIndex := 2; // default
              // se non è foglia finale, cioè se ha details
              if not item.IsMenuLeaf then
              begin
                Node.ImageIndex := 1;
                Node.SelectedIndex := 1;
                Enum(Node, item.DetailDatasets, MenuFilter);
              end;

              /// //////////////////////////////////////////////////////////////////////////
              if not Assigned(first) then
              begin
                first := Node;
                FSelected := item.Name;
              end;
            end;
    end;
  end;

begin
  tree.BeginUpdate;
  try
    Clear;

    first := nil;

    Enum(nil, zDataModule.DataSets, '');

    if AutoExpand then
      tree.FullCollapse
    else
      tree.FullExpand;

    if tree.Count > 0 then
      tree.Items[0].MakeVisible;

    if Assigned(first) then
      first.Selected := true;
  finally
    tree.EndUpdate;
  end;
end;

procedure TzTreeMenu.EspandiAutomaticamenteExecute(Sender: TObject);
begin
  AutoExpand := not AutoExpand;
end;

procedure TzTreeMenu.EspandiAutomaticamenteUpdate(Sender: TObject);
begin
  EspandiAutomaticamente.Checked := AutoExpand;
end;

procedure TzTreeMenu.SetAutoExpand(const Value: boolean);
begin
  FAutoExpand := Value;

  { TODO : AutoExpand }
  // tree.AutoExpand := AutoExpand;

  if AutoExpand then
    tree.FullCollapse
  else
    tree.FullExpand;
end;

procedure TzTreeMenu.NodeSelected(const SelectFirstChild: boolean);

  procedure ToggleExpand;
  var
    current: TcxTreeListNode;
  begin

    if AutoExpand then
      if tree.SelectionCount > 0 then
      begin
        current := tree.Selections[0];

        if Assigned(LastExpandedNode) and (current = LastExpandedNode) and current.Expanded then
          current.Collapse(false) // click su un gruppo
        else
        begin
          if Assigned(LastExpandedNode) then
            if not current.HasAsParent(LastExpandedNode) then // non è child di LastExpandedNode
              LastExpandedNode.Collapse(false);

          current.Selected := true;

          if current.Expanded then
            current.Collapse(false)
          else
            current.Expand(false);

          LastExpandedNode := current;
        end;

        CalculateWidth;
      end;
  end;

  function GetFirstLeaf(owner: TcxTreeListNode): TcxTreeListNode;
  var
    i: integer;
  begin
    Result := nil;

    for i := 0 to owner.Count - 1 do
      if owner.Items[i].Visible then
      begin
        if owner.Items[i].Count = 0 then
          Result := owner.Items[i]
        else
          Result := GetFirstLeaf(owner.Items[i]);

        if Assigned(Result) then
          exit;
      end;
  end;

  procedure doIt(const SelectFirstChild: boolean);
  var
    i: integer;
    zDataSet: TzDiagramDataSet;
    Node: TcxTreeListNode;
  begin
    if busy then
      exit;

    zDataSet := GetSelectedDataSet;

    if Assigned(zDataSet) and zDataSet.IsMenuLeaf then
      doSelect(zDataSet.Name)
    else
      if SelectFirstChild then
      begin
        ToggleExpand;

        if tree.SelectionCount > 0 then
        begin
          Node := nil;
          busy := true;
          try
            Node := GetFirstLeaf(tree.Selections[0]);

            if not Assigned(Node) then
              if IsDataSetNode(tree.Selections[0]) then
                Node := tree.Selections[0];

            if Assigned(Node) then
              Node.Selected := true;
          finally
            busy := false;
          end;

          if Assigned(Node) then //
          begin
            zDataSet := GetDataSet(Node);

            if Assigned(zDataSet) then
              doSelect(zDataSet.Name)
          end;
        end;
      end
      else
        ToggleExpand;
  end;

begin
  if (csDestroying in ComponentState) then
    exit;

  if IsDestroying then
    exit;

  if IsSelecting then
    exit;

  IsSelecting := true;
  try
    doIt(SelectFirstChild);
  finally
    IsSelecting := false;
  end;
end;

procedure TzTreeMenu.doSelect(const aSelected: string);
begin
  if (csDestroying in ComponentState) then
    exit;

  if IsDestroying then
    exit;

  FSelected := aSelected;

  if Assigned(FOnSelect) then
    OnSelect(Self);
end;

procedure TzTreeMenu.Translated;
var
  DataSetName: string;
begin
  DataSetName := SelectedDataSetName;
  try
    LoadMenu;
  finally
    SelectDataSet(DataSetName, false);
  end;
end;

procedure TzTreeMenu.actMoveUpExecute(Sender: TObject);
var
  zDataSet: TzDiagramDataSet;
  PrevSibling: TcxTreeListNode;
begin
  zDataSet := GetSelectedDataSet;
  if Assigned(zDataSet) then
  begin
    PrevSibling := tree.Selections[0].GetPrevSibling;
    if Assigned(PrevSibling) then
    begin
      tree.Selections[0].MoveTo(PrevSibling, tlamInsert);
      zDataSet.Index := zDataSet.Index - 1;
    end;
  end;
end;

procedure TzTreeMenu.actMoveDownExecute(Sender: TObject);
var
  zDataSet: TzDiagramDataSet;
  NextSibling: TcxTreeListNode;
begin
  zDataSet := GetSelectedDataSet;
  if Assigned(zDataSet) then
  begin
    NextSibling := tree.Selections[0].getNextSibling;
    if Assigned(NextSibling) then
    begin
      tree.Selections[0].MoveTo(NextSibling, tlamInsert);
      zDataSet.Index := zDataSet.Index + 1;
    end;
  end;
end;

procedure TzTreeMenu.ProprietaExecute(Sender: TObject);
var
  zDataSet: TzDiagramDataSet;
  shouldSave: boolean;
begin
  CalculateWidth;
  exit;
  zDataSet := GetSelectedDataSet;

  if not Assigned(zDataSet) then
    exit;

  shouldSave := zDataSet.Inspect;

  StartWait('Attendere...', true);
  try
    if shouldSave then
      zDataModule.SaveToBase(true)
    else
      zDataModule.LoadFromBase;
  finally
    StopWait;
  end;

  LoadMenu;
end;

procedure TzTreeMenu.treeMouseEnter(Sender: TObject);
begin

  // if tree.Bounds.Contains(ScreenToClient(Mouse.CursorPos)) then
  // CalculateWidth;
end;

procedure TzTreeMenu.treeMouseLeave(Sender: TObject);
begin

  // if not tree.Bounds.Contains(ScreenToClient(Mouse.CursorPos)) then
  // begin
  // Self.Width := 20;
  //
  // if Assigned(FOnWidthChanged) then
  // OnWidthChanged(Self, 20);
  // end;
end;

procedure TzTreeMenu.CopiaTitoliExecute(Sender: TObject);
begin
  Clipboard.AsText := GetMenuItems;
  ConfirmOk('Titoli copiati nella clipboard');
end;

function TzTreeMenu.GetMenuItems: string;
var
  Node: TcxTreeListNode;
begin
  Result := '';

  Node := tree.Root;
  while Node <> nil do
  begin
    Result := Result + ''.PadLeft(Node.Level * 3, ' ') + Node.texts[0] + sLineBreak;
    Node := Node.GetNext;
  end;
end;

procedure TzTreeMenu.MarkdownExecute(Sender: TObject);

  function GetCaption: string;
  begin
    Result := '';
    if Assigned(zDataModule) then
      Result := zDataModule.FormOptions.Caption;
  end;

  function GetNodePath(Node: TcxTreeListNode; Delimiter: string): string;
  var
    curr: TcxTreeListNode;
  begin
    Result := '';

    curr := Node;
    while Assigned(curr) do
    begin

      if Result.IsEmpty then
        Result := curr.texts[0]
      else
        Result := curr.texts[0] + Delimiter + Result;

      curr := curr.Parent;
    end;
  end;

var
  Node: TcxTreeListNode;
  HeaderLevel: integer;
  HeaderPrefix, NodeText: string;
  Markdown: TStringList;
  needReload: boolean;
begin
  needReload := base.IsAdmin;

  base.IsAdminDisabled := true;
  try
    if needReload then
      LoadMenu;

    Markdown := TStringList.Create;
    try
      Markdown.Add('# ' + GetCaption);

      Node := tree.Root.GetNext;

      while Assigned(Node) do
      begin
        // Determina il livello del titolo Markdown in base al livello del nodo
        // Livello 0 -> # (Titolo principale), Livello 1 -> ##, ecc.
        // Si usano al massimo 6 livelli di titolo in Markdown, ma TTreeView può averne di più.
        // Limitiamo qui fino a 6 per convenzione Markdown.

        HeaderLevel := Node.Level + 2;
        if HeaderLevel > 6 then
          HeaderLevel := 6;

        HeaderPrefix := StringOfChar('#', HeaderLevel);
        NodeText := Trim(Node.texts[0]);

        Markdown.Add('');
        Markdown.Add(HeaderPrefix + ' ' + NodeText);
        Markdown.Add('');

        Markdown.Add('**Azione:** [Descrivere l''azione attivata da questo nodo]');
        Markdown.Add('**Percorso nel Menu:** ' + GetNodePath(Node, ' -> '));
        // Markdown.Add('---'); // Separatore per chiarezza
        // Markdown.Add(''); // Linea vuota

        Node := Node.GetNext;
      end;

      Clipboard.AsText := Markdown.Text;;
      ConfirmOk('Markdwn copiato nella clipboard');
    finally
      FreeAndNil(Markdown);
    end;

  finally
    base.IsAdminDisabled := false;

    if needReload then
      LoadMenu;
  end;
end;

end.
