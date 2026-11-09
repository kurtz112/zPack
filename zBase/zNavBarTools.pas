unit zNavBarTools;

interface

uses
  SysUtils,
  Classes,
  cxPC,
  dxNavBar,
  dxNavBarBase,
  dxNavBarCollns,
  ActnList,
  zCollection,
  system.Actions,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type

  TActionTabLink = class(TCollectionItem)
  private
    FAction: TContainedAction;
    FTabSheet: TcxTabSheet;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure ActivateTab;
  published
    property Action: TContainedAction read FAction write FAction;
    property TabSheet: TcxTabSheet read FTabSheet write FTabSheet;
  end;

  TActionTabLinks = class(TCollection)
  private
    function GetItem(Index: Integer): TActionTabLink;
    procedure SetItem(Index: Integer; const Value: TActionTabLink);
  public
    function Add: TActionTabLink;
    function AddLink(Action: TContainedAction; TabSheet: TcxTabSheet): TActionTabLink;
    function Insert(Index: Integer): TActionTabLink;
    property Items[Index: Integer]: TActionTabLink read GetItem write SetItem; default;
  end;

  TzNavBarTools = class(TComponent)
  private
    FActionList: TActionList;
    FdxNavBar: TdxNavBar;
    FTryNavBar: Boolean;
    Links: TActionTabLinks;
    procedure ChangeActivePage(Sender: TObject);
    procedure SetActionList(const Value: TActionList);
    procedure SetdxNavBar(const Value: TdxNavBar);
    procedure SetTryNavBar(const Value: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure BuildSideBar(aNavBar: TdxNavBar; aActionList: TActionList); overload;
    procedure BuildSideBar; overload;
    procedure AddLink(Action: TContainedAction; tab: TcxTabSheet); overload;
    procedure AddLink(Action: TContainedAction; tabs: array of TcxTabSheet); overload;
  published
    property ActionList: TActionList read FActionList write SetActionList;
    property dxNavBar: TdxNavBar read FdxNavBar write SetdxNavBar;
    property TryNavBar: Boolean read FTryNavBar write SetTryNavBar stored false;
  end;

implementation

uses
  Vcl.Dialogs, zMsg;

constructor TzNavBarTools.Create(aOwner: TComponent);
begin
  inherited;
  FTryNavBar := false;
  FActionList := nil;
  FdxNavBar := nil;
  Links := TActionTabLinks.Create(TActionTabLink);
end;

destructor TzNavBarTools.Destroy;
begin
  FreeAndNil(Links);
  inherited;
end;

procedure TzNavBarTools.AddLink(Action: TContainedAction; tab: TcxTabSheet);
begin
  Assert(Assigned(Action));
  Assert(Assigned(tab));

  Links.AddLink(Action, tab);

  if not Assigned(Action.onExecute) then
    Action.onExecute := ChangeActivePage;
end;

procedure TzNavBarTools.AddLink(Action: TContainedAction; tabs: array of TcxTabSheet);
var
  tab: TcxTabSheet;
begin
  for tab in tabs do
    AddLink(Action, tab);
end;

procedure TzNavBarTools.BuildSideBar(aNavBar: TdxNavBar; aActionList: TActionList);
begin
  ActionList := aActionList;
  dxNavBar := aNavBar;
  BuildSideBar;
end;

procedure TzNavBarTools.BuildSideBar;
var
  group: TdxNavBarGroup;
  item: TdxNavBarItem;
  Action: TContainedAction;

  function GetGroup(const Category: string): TdxNavBarGroup;
  begin
    result := dxNavBar.groups.ItemByCaption(Category) as TdxNavBarGroup;

    if not Assigned(result) then
    begin
      result := dxNavBar.groups.Add;
      result.Caption := Category;
      result.LinksUseSmallImages := false;
    end;
  end;

  procedure ClearGroups;
  var
    i, i2: Integer;
    item: TdxNavBarItem;
  begin
    for i := dxNavBar.groups.Count - 1 downto 0 do
      if not dxNavBar.groups[i].OptionsGroupControl.UseControl then
      begin
        for i2 := dxNavBar.groups[i].LinkCount - 1 downto 0 do
        begin
          item := dxNavBar.groups[i].Links[i2].item;
          item.RemoveAllLinks;

          dxNavBar.Items.Remove(item);
        end;

        dxNavBar.groups.Delete(i);
      end;
  end;

begin
  Assert(Assigned(dxNavBar));
  Assert(Assigned(ActionList));

  dxNavBar.BeginUpdate;
  try
    dxNavBar.Items.BeginUpdate;
    try
      ClearGroups;

      for Action in ActionList do
      begin
        // DIV-NVB-4: un'azione nascosta non ha voce nella barra
        if not Action.Visible then
          Continue;

        item := dxNavBar.Items.Add;
        item.Action := Action;
        item.Visible := True;
        group := GetGroup(Action.Category);
        group.CreateLink(item);
      end;

      // DIV-NVB-4: senza gruppi non c'e' un indice 0 da attivare
      if dxNavBar.groups.Count > 0 then
        dxNavBar.ActiveGroupIndex := 0;
    finally
      dxNavBar.Items.EndUpdate;
    end;
  finally
    dxNavBar.EndUpdate;
  end;
end;

procedure TzNavBarTools.ChangeActivePage(Sender: TObject);
var
  Action: TContainedAction;
  tab: TcxTabSheet;
  i: Integer;
begin
  if not(Sender is TContainedAction) then
    Exit;

  Action := Sender as TContainedAction;

  for i := 0 to Links.Count - 1 do
    if Links[i].Action = Action then
      Links[i].ActivateTab;
end;

procedure TzNavBarTools.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;

  if AComponent = FActionList then
    FActionList := nil
  else
    if AComponent = FdxNavBar then
      FdxNavBar := nil;
end;

procedure TzNavBarTools.SetActionList(const Value: TActionList);
begin
  // DIV-NVB-1: Value puo' essere nil; si restituisce l'avviso al vecchio componente
  if Assigned(FActionList) and (FActionList <> Value) then
    FActionList.RemoveFreeNotification(Self);
  FActionList := Value;
  if Assigned(Value) then
    Value.FreeNotification(Self);
end;

procedure TzNavBarTools.SetdxNavBar(const Value: TdxNavBar);
begin
  if Assigned(FdxNavBar) and (FdxNavBar <> Value) then
    FdxNavBar.RemoveFreeNotification(Self);
  FdxNavBar := Value;
  if Assigned(Value) then
    Value.FreeNotification(Self);
end;

procedure TzNavBarTools.SetTryNavBar(const Value: Boolean);
begin
  // FTryNavBar := Value;

  if Value then
  begin
    if not Assigned(ActionList) then
    begin
      ConfirmOk('ActionList non assegnata');
      Exit;
    end;
    if not Assigned(dxNavBar) then
    begin
      ConfirmOk('NavBar non assegnata');
      Exit;
    end;

    BuildSideBar;
  end;
end;

constructor TActionTabLink.Create(Collection: TCollection);
begin
  inherited;
  FAction := nil;
  FTabSheet := nil;
end;

procedure TActionTabLink.ActivateTab;
begin
  if Assigned(FTabSheet) then
    TabSheet.PageControl.ActivePage := TabSheet;
end;

procedure TActionTabLink.Assign(Source: TPersistent);
begin
  if Source is TActionTabLink then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      FAction := TActionTabLink(Source).Action;
      FTabSheet := TActionTabLink(Source).TabSheet;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TActionTabLinks.Add: TActionTabLink;
begin
  result := TActionTabLink(inherited Add);
end;

function TActionTabLinks.AddLink(Action: TContainedAction; TabSheet: TcxTabSheet): TActionTabLink;
begin
  result := Add;
  result.Action := Action;
  result.TabSheet := TabSheet;
end;

function TActionTabLinks.GetItem(Index: Integer): TActionTabLink;
begin
  result := TActionTabLink(inherited Items[Index]);
end;

function TActionTabLinks.Insert(Index: Integer): TActionTabLink;
begin
  result := TActionTabLink(inherited Insert(Index));
end;

procedure TActionTabLinks.SetItem(Index: Integer; const Value: TActionTabLink);
begin
  Items[Index].Assign(Value);
end;

end.

