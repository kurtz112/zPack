unit zRestrictions.Structs;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  Generics.Collections,
  zCollection,
  zz.GenericCollection,
  zRestrictions.Types,
  cxTL,
  zSystem;

type
  TComponentDefault = class(TCollectionItem)
  private
    FAccessLevel: TAccessLevel;
    FComponentGroup: string;
    FComponentName: string;
  public
    constructor Create(Collection: TCollection); override;
    property ComponentName: string read FComponentName write FComponentName;
    property ComponentGroup: string read FComponentGroup write FComponentGroup;
    property AccessLevel: TAccessLevel read FAccessLevel write FAccessLevel;
  end;

  TComponentDefaults = class(TzGenericCollection<TComponentDefault>)
  public
    function IndexOf(const ComponentName: string): integer;
    procedure AddDefault(const ComponentName: string; const ComponentGroup: string; const AccessLevel: TAccessLevel);
    function TryGetAccessLevel(const ComponentName: string; out AccessLevel: TAccessLevel): boolean;
    function TryGetComponentGroup(const ComponentName: string; out ComponentGroup: string): boolean;
  end;

  TComponentSelection = class(TCollectionItem)
  public
    node: TcxTreeListNode;
    col: TcxTreeListColumn;
  end;

  TComponentSelections = class(TzGenericCollection<TComponentSelection>)
  public
    function Find(node: TcxTreeListNode; col: TcxTreeListColumn): TComponentSelection;
    function AddSelection(node: TcxTreeListNode; col: TcxTreeListColumn): TComponentSelection;
  end;

  TComponentInfo = class(TCollectionItem)
  private
    FComponent: TObject;
    FComponentClass: TzComponentClass;
    FComponentGroup: String;
    FComponentGroupNode: TcxTreeListNode;
    FComponentName: string;
    FComponentNode: TcxTreeListNode;
    FIsDataSet: boolean;
  public
    constructor Create(Collection: TCollection); override;

    property IsDataSet: boolean read FIsDataSet write FIsDataSet;
    property Component: TObject read FComponent write FComponent;
    property ComponentName: string read FComponentName write FComponentName;
    property ComponentGroup: String read FComponentGroup write FComponentGroup;
    property ComponentNode: TcxTreeListNode read FComponentNode write FComponentNode;
    property ComponentGroupNode: TcxTreeListNode read FComponentGroupNode write FComponentGroupNode;
    property ComponentClass: TzComponentClass read FComponentClass write FComponentClass;
  end;

  TComponentInfos = class(TzGenericCollection<TComponentInfo>)
  private
    tree: TcxTreeList;
    GroupNodes: TDictionary<string, TcxTreeListNode>;
    function GetGroupNode(const GroupNode: string; ComponentClass: TzComponentClass): TcxTreeListNode;
  private
    function GetImageIndex(ComponentClass: TzComponentClass): integer;
  public
    constructor Create(aTree: TcxTreeList);
    destructor Destroy; override;

    procedure Clear;
    procedure PackTree;

    function Add: TComponentInfo;

    function AddComponent(comp: TComponent; ComponentClass: TzComponentClass; ComponentGroup: string): TComponentInfo;
    function AddDataSet(DataSet: TzDiagramDataSet): TComponentInfo;

    function GetComponentNode(Const ComponentName: string): TcxTreeListNode;
  end;

  TPolicy = class(TCollectionItem)
  private
    FDefaultActionAccessLevel: TAccessLevel;
    FDefaultDataSetAccessLevel: TAccessLevel;
    FPolicy: string;
  public
    constructor Create(Collection: TCollection); override;
    property Policy: string read FPolicy;
    property DefaultActionAccessLevel: TAccessLevel read FDefaultActionAccessLevel;
    property DefaultDataSetAccessLevel: TAccessLevel read FDefaultDataSetAccessLevel;
  end;

  TPolicies = class(TzGenericCollection<TPolicy>)
  public
    function IndexOf(const Policy: string): integer;
    function Find(const Policy: string): TPolicy;
    function AddPolicy(const Policy: string; DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel): TPolicy;
  end;

implementation

uses
  System.Rtti,
  System.TypInfo,
  System.Actions,
  Vcl.ComCtrls,
  Winapi.CommCtrl,
  zBaseLib,
  zDbView,
  zDbCard,
  zFileViewer;

function FormatCaption(const Caption, Description: string): string;
begin
  if Description <> '' then
    result := Caption + ' (' + Trim(Description) + ')'
  else
    result := Caption;
end;

function GetComponentCaption(Component: TComponent): string;
var
  Caption, Description: string;
  PropInfo: PPropInfo;
begin
  result := '';

  if not Assigned(Component) then
    Exit;

  Caption := '';
  Description := Component.Name;

  if Component is TContainedAction then
    Caption := (Component as TContainedAction).Caption
  else
    if Component is TzDbView then
      Caption := (Component as TzDbView).Titolo.Caption
    else
      if Component is TzDbCard then
        Caption := (Component as TzDbCard).Titolo.Caption
      else
        if Component is TTabSheet then
          Caption := (Component as TTabSheet).Caption;

  if Caption = '' then
  begin
    PropInfo := System.TypInfo.GetPropInfo(Component.ClassInfo, 'Caption');
    if PropInfo <> nil then
      Caption := GetStrProp(Component, 'Caption')
    else
      Caption := Component.ClassName;
  end;

  result := FormatCaption(Caption, Description);
end;

function TComponentSelections.AddSelection(node: TcxTreeListNode; col: TcxTreeListColumn): TComponentSelection;
begin
  result := Add;
  result.node := node;
  result.col := col;
end;

function TComponentSelections.Find(node: TcxTreeListNode; col: TcxTreeListColumn): TComponentSelection;
begin

  for result in self do
    if result.node = node then
      if result.col = col then
        Exit;

  result := nil;
end;

constructor TComponentInfo.Create(Collection: TCollection);
begin
  inherited;
  FComponent := nil;
  FComponentClass := ccUnknown;
  FComponentGroup := '';
  FComponentGroupNode := nil;
  FComponentName := '';
  FComponentNode := nil;;
  FIsDataSet := false;
end;

constructor TComponentInfos.Create(aTree: TcxTreeList);
begin
  inherited Create(TComponentInfo);
  tree := aTree;
  GroupNodes := TDictionary<string, TcxTreeListNode>.Create;
end;

destructor TComponentInfos.Destroy;
begin
  FreeAndNil(GroupNodes);
  inherited;
end;

function TComponentInfos.Add: TComponentInfo;
begin
  result := TComponentInfo(inherited Add);
end;

procedure TComponentInfos.Clear;
begin
  inherited Clear;
  GroupNodes.Clear;
end;

function TComponentInfos.GetGroupNode(const GroupNode: string; ComponentClass: TzComponentClass): TcxTreeListNode;
var
  ImageIndex: integer;
begin
  result := nil;

  if GroupNodes.ContainsKey(GroupNode) then
    GroupNodes.TryGetValue(GroupNode, result)
  else
  begin
    result := tree.Root.AddChild;
    GroupNodes.Add(GroupNode, result);
    result.Values[0] := GroupNode;
    ImageIndex := GetImageIndex(ComponentClass);
    result.SelectedIndex := ImageIndex;
    result.ImageIndex := ImageIndex;
  end;
end;

procedure TComponentInfos.PackTree;
var
  node: TcxTreeListNode;
  Pair: TPair<string, TcxTreeListNode>;
begin
  tree.FullCollapse;

  if GroupNodes.TryGetValue(ccFormController.Description, node) then
    node.Expand(True)
  else
    if GroupNodes.TryGetValue(ccAction.Description, node) then
      node.Expand(True);

  for Pair in GroupNodes do
    if Pair.Value.count = 0 then
      Pair.Value.Free;

  GroupNodes.Clear;
end;

function TComponentInfos.AddComponent(comp: TComponent; ComponentClass: TzComponentClass; ComponentGroup: string): TComponentInfo;
var
  node: TcxTreeListNode;
  parentNode: TcxTreeListNode;
begin
  parentNode := GetGroupNode(ComponentGroup, ComponentClass);

  node := parentNode.AddChild;
  node.Values[1] := GetComponentCaption(comp);
  node.Data := comp;

  if ComponentClass = ccAction then
    node.ImageIndex := TContainedAction(comp).ImageIndex
  else
    node.ImageIndex := parentNode.ImageIndex;

  result := Add;
  result.IsDataSet := false;
  result.Component := comp;
  result.ComponentName := comp.Name;
  result.ComponentGroup := ComponentGroup;
  result.ComponentNode := node;
  result.ComponentGroupNode := parentNode;
  result.ComponentClass := ComponentClass;
end;

function TComponentInfos.AddDataSet(DataSet: TzDiagramDataSet): TComponentInfo;
var
  node: TcxTreeListNode;
  parentNode: TcxTreeListNode;
  detail: TzDiagramDataSet;
  ComponentClass: TzComponentClass;
  ComponentGroup: string;
  DataSetName: string;
begin
  ComponentClass := ccFormController;
  ComponentGroup := ccFormController.Description;
  DataSetName := DataSet.DataModule.Name + '.' + DataSet.Name;

  parentNode := GetGroupNode(ComponentGroup, ComponentClass);

  node := parentNode.AddChild;
  node.Values[1] := FormatCaption(DataSet.Menu.Caption, DataSet.Name);
  node.Data := DataSet;
  node.ImageIndex := parentNode.ImageIndex;

  result := Add;
  result.IsDataSet := True;
  result.Component := DataSet;
  result.ComponentName := DataSetName;
  result.ComponentGroup := ComponentGroup;
  result.ComponentNode := node;
  result.ComponentGroupNode := parentNode;
  result.ComponentClass := ComponentClass;

  for detail in DataSet.DetailDatasets do
    AddDataSet(detail);
end;

function TComponentInfos.GetComponentNode(Const ComponentName: string): TcxTreeListNode;
var
  item: TComponentInfo;
begin
  result := nil;
  for item in self do
    if SameText(item.ComponentName, ComponentName) then
      Exit(item.ComponentNode);
end;

function TComponentInfos.GetImageIndex(ComponentClass: TzComponentClass): integer;
begin
  result := -1;

  case ComponentClass of
    ccUnknown:
      result := 461;
    ccTabSheet:
      result := 462;
    ccAction:
      result := 467;
    ccFormController:
      result := 456;
    ccView:
      result := 464;
    ccCard:
      result := 465;
    ccCube:
      result := 463;
    ccFilePdf:
      result := 84;
    ccGisMap:
      result := 213;
  end;
end;

constructor TComponentDefault.Create(Collection: TCollection);
begin
  inherited;
  FAccessLevel := alNone;
  FComponentGroup := '';
  FComponentName := '';
end;

procedure TComponentDefaults.AddDefault(const ComponentName: string; const ComponentGroup: string; const AccessLevel: TAccessLevel);
var
  item: TComponentDefault;
  idx: integer;
begin

  idx := IndexOf(ComponentName);
  if idx = -1 then
    item := Add
  else
    item := Items[idx];

  item.ComponentName := ComponentName;
  item.ComponentGroup := ComponentGroup;
  item.AccessLevel := AccessLevel;
end;

function TComponentDefaults.IndexOf(const ComponentName: string): integer;
var
  I: integer;
begin
  result := -1;

  if ComponentName <> '' then
    for I := 0 to count - 1 do
      if SameText(ComponentName, Items[I].ComponentName) then
      begin
        result := I;
        Break;
      end;
end;

function TComponentDefaults.TryGetAccessLevel(const ComponentName: string; out AccessLevel: TAccessLevel): boolean;
var
  idx: integer;
begin
  result := false;

  idx := IndexOf(ComponentName);
  if idx = -1 then
    Exit;

  result := True;
  AccessLevel := Items[idx].AccessLevel;
end;

function TComponentDefaults.TryGetComponentGroup(const ComponentName: string; out ComponentGroup: string): boolean;
var
  idx: integer;
begin
  result := false;

  idx := IndexOf(ComponentName);
  if idx = -1 then
    Exit;

  result := True;
  ComponentGroup := Items[idx].ComponentGroup;
end;

constructor TPolicy.Create(Collection: TCollection);
begin
  inherited;
  FPolicy := '';
  FDefaultActionAccessLevel := alNone;
  FDefaultDataSetAccessLevel := alNone;
end;

function TPolicies.AddPolicy(const Policy: string; DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel): TPolicy;
begin
  result := Add;

  result.FPolicy := Policy;
  result.FDefaultActionAccessLevel := DefaultActionAccessLevel;
  result.FDefaultDataSetAccessLevel := DefaultDataSetAccessLevel;
end;

function TPolicies.Find(const Policy: string): TPolicy;
var
  idx: integer;
begin
  result := nil;

  idx := IndexOf(Policy);

  if idx <> -1 then
    result := Items[idx];
end;

function TPolicies.IndexOf(const Policy: string): integer;
var
  I: integer;
begin
  result := -1;

  if Policy <> '' then
    for I := 0 to count - 1 do
      if SameText(Policy, Items[I].Policy) then
      begin
        result := I;
        Break;
      end;
end;

end.
