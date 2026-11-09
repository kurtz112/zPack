unit zToolActions;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.ActnList,
  Vcl.Controls,
  Vcl.ImgList,
  zCollection,
  dxBar;

type
  TOwnerType = (otView, otCard, otOther);

  TzTBCustomItemProps = class(TPersistent)
  private
    // FDisplayMode: TTBItemDisplayMode;
    FVisibleInCard: Boolean;
    FVisibleInView: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    // property DisplayMode: TTBItemDisplayMode read FDisplayMode write FDisplayMode stored false default nbdmImageAndText;
    property VisibleInCard: Boolean read FVisibleInCard write FVisibleInCard default True;
    property VisibleInView: Boolean read FVisibleInView write FVisibleInView default True;
  end;

  TzToolActionProps = class(TzCollectionItem)
  private
    FPopupProps: TzTBCustomItemProps;
    FToolbarProps: TzTBCustomItemProps;
    FShowCaption: Boolean;
    procedure SetPopupProps(const Value: TzTBCustomItemProps);
    procedure SetToolbarProps(const Value: TzTBCustomItemProps);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property PopupProps: TzTBCustomItemProps read FPopupProps write SetPopupProps;
    property ToolbarProps: TzTBCustomItemProps read FToolbarProps write SetToolbarProps;
    property ShowCaption: Boolean read FShowCaption write FShowCaption;
  end;

  TzToolActionsProps = class(TzCollection<TzToolActionProps>)
  protected
  public
    Constructor Create;
  end;

  TzToolAction = class(TzCollectionItem)
  private
    FAction: TCustomAction;
    FBeginGroup: Boolean;
    FImageList: TCustomImagelist;
    FLargeButton: Boolean;
    FPopupProps: TzTBCustomItemProps;
    FShowCaption: Boolean;
    FToolbarProps: TzTBCustomItemProps;
    FVolatile: Boolean;
    procedure SetAction(const Value: TCustomAction);
    procedure SetCustomImagelist(const Value: TCustomImagelist);
    procedure SetPopupProps(const Value: TzTBCustomItemProps);
    procedure SetToolbarProps(const Value: TzTBCustomItemProps);
  protected
    function GetImageList: TCustomImagelist;
  public
    constructor Create(Collection: TCollection); overload; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  public
    // per AI
    function Description: string;
  public
    procedure HideInPopups;
    procedure HideInToolbar;
    procedure HideInCard;
    procedure HideInView;
  public
    property Volatile: Boolean read FVolatile;
  published
    property Action: TCustomAction read FAction write SetAction;
    property BeginGroup: Boolean read FBeginGroup write FBeginGroup default false;
    property LargeButton: Boolean read FLargeButton write FLargeButton default false;

    property ImageList: TCustomImagelist read FImageList write SetCustomImagelist;
    property PopupProps: TzTBCustomItemProps read FPopupProps write SetPopupProps;
    property ToolbarProps: TzTBCustomItemProps read FToolbarProps write SetToolbarProps;
    property ShowCaption: Boolean read FShowCaption write FShowCaption;
  end;

  TzToolActions = class(TzCollection<TzToolAction>)
  private
    FOwner: TComponent;
    Buttons: TList<TdxBarButton>;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    procedure AssignDefaultImageList(ImageList: TCustomImagelist; LargeImageList: TCustomImagelist);

    function Add(ImageList: TCustomImagelist; const Volatile: Boolean = false): TzToolAction; overload;
    function Add(Action: TCustomAction; ImageList: TCustomImagelist; const Volatile: Boolean = false): TzToolAction; overload;
    procedure RemoveNotification(AComponent: TComponent);
    procedure CreateButtons(bar: TdxBar; popup: TdxBarPopupMenu; OwnerType: TOwnerType);

    procedure DestroyVolatiles;
  end;

procedure DumpActions(const Caption: string; ToolActions: TzToolActions);

implementation

uses
  SysUtils,
  Dialogs,
  zMsg,
  zSystem,
  zDxBarHelper,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

procedure DumpActions(const Caption: string; ToolActions: TzToolActions);
var
  s: string;
  i: Integer;
begin
  s := Caption + #13#13;
  for i := 0 to ToolActions.Count - 1 do
  begin
    s := s + ToolActions[i].Name + #13;
  end;
  ConfirmOk(s);
end;

constructor TzToolAction.Create(Collection: TCollection);
begin
  inherited;
  FAction := nil;
  FBeginGroup := false;
  FLargeButton := false;
  FImageList := nil;
  FShowCaption := True;
  FPopupProps := TzTBCustomItemProps.Create;
  FToolbarProps := TzTBCustomItemProps.Create;
  FVolatile := false;
end;

constructor TzToolActions.Create(AOwner: TComponent);
begin
  inherited Create(TzToolAction, 'ToolActions', -1, nil);
  FOwner := AOwner;
  Sorted := false;
  Buttons := TList<TdxBarButton>.Create;
end;

destructor TzToolActions.Destroy;
begin
  FreeAndNil(Buttons);
  inherited;
end;

procedure TzToolActions.DestroyVolatiles;
var
  i: Integer;
begin

  for i := Count - 1 downTo 0 do
    if Items[i].Volatile then
      Delete(i);
end;

function TzToolActions.Add(ImageList: TCustomImagelist; const Volatile: Boolean = false): TzToolAction;
begin
  Result := Add;
  Result.ImageList := ImageList;
  Result.FVolatile := Volatile;
end;

function TzToolActions.Add(Action: TCustomAction; ImageList: TCustomImagelist; const Volatile: Boolean = false): TzToolAction;
begin
  Result := Add(ImageList, Volatile);
  Result.Action := Action;
end;

procedure TzToolActions.AssignDefaultImageList(ImageList: TCustomImagelist; LargeImageList: TCustomImagelist);
var
  Item: TzToolAction;
begin

  Exit; // da eliminare

  siMain.logVerbose(FOwner.Name + '.AssignDefaultImageList');
  BeginUpdate;
  try
    for Item in self do
      if not Assigned(Item.ImageList) then
      begin
        if Item.LargeButton then
          Item.ImageList := ImageList
        else
          Item.ImageList := LargeImageList;
      end;
  finally
    EndUpdate;
  end;
end;

procedure TzToolActions.CreateButtons(bar: TdxBar; popup: TdxBarPopupMenu; OwnerType: TOwnerType);
var
  i: Integer;
  ToolAction: TzToolAction;
  idx: Integer;
  btn: TdxBarButton;
  ItemLink: TdxBarItemLink;
  AddToolbar: Boolean;
  AddPopup: Boolean;
begin
  // siMain.logVerbose(FOwner.Name + '.CreateButtons');

  // ZZ 29.12.2019 AV al caricamento delle form
  if Assigned(FOwner) then
    if csDesigning in FOwner.ComponentState then
      Exit;

  TzDxBarHelper.ClearButtons(Buttons);

  /// //////////////////////////////////////////

  for ToolAction In self do
    if Assigned(ToolAction.Action) then
    begin
      btn := TzDxBarHelper.CreateBarButton(FOwner, ToolAction.Action, ToolAction.GetImageList, ToolAction.ShowCaption);
      Buttons.Add(btn);

      /// //////////////////////////////////////////////////////////////////////////
      AddToolbar := Assigned(bar);

      case OwnerType of
        otView:
          AddToolbar := AddToolbar and ToolAction.ToolbarProps.VisibleInView;
        otCard:
          AddToolbar := AddToolbar and ToolAction.ToolbarProps.VisibleInCard;
      end;

      if AddToolbar then
        TzDxBarHelper.AddButtonLink(bar, btn);

      /// //////////////////////////////////////////////////////////////////////////
      AddPopup := Assigned(popup);

      case OwnerType of
        otView:
          AddPopup := AddPopup and ToolAction.PopupProps.VisibleInView;
        otCard:
          AddPopup := AddPopup and ToolAction.PopupProps.VisibleInCard;
      end;

      if AddPopup then
        TzDxBarHelper.AddPopupLink(popup, btn);

      btn.Action := ToolAction.Action;
      /// //////////////////////////////////////////////////////////////////////////
    end;
end;

function TzToolActions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TzToolActions.RemoveNotification(AComponent: TComponent);
var
  i: Integer;
begin
  if AComponent is TCustomAction then
  begin
    for i := 0 to Count - 1 do
      if Items[i].Action = AComponent then
        Items[i].Action := nil;
  end
  else
    if AComponent is TCustomImagelist then
    begin
      for i := 0 to Count - 1 do
        if Items[i].ImageList = AComponent then
          Items[i].ImageList := nil;
    end;
end;

destructor TzToolAction.Destroy;
begin
  FreeAndNil(FPopupProps);
  FreeAndNil(FToolbarProps);
  inherited;
end;

procedure TzToolAction.Assign(Source: TPersistent);
var
  Item: TzToolAction;
begin
  if Source is TzToolAction then
  begin
    Item := Source as TzToolAction;

    FAction := Item.Action;
    FBeginGroup := Item.BeginGroup;
    FLargeButton := Item.LargeButton;
    FImageList := Item.ImageList;
    FShowCaption := Item.ShowCaption;
    FPopupProps.Assign(Item.PopupProps);
    FToolbarProps.Assign(Item.ToolbarProps);
  end
  else
    inherited Assign(Source);
end;

// ── Implementazione ───────────────────────────────────────────────────────────

function TzToolAction.Description: string;
begin
  if not Assigned(Action) then
    Exit('(azione non assegnata)');

  Result := Action.Caption;

  if Action.Hint <> '' then
    Result := Result + ' — ' + Action.Hint;

  // Suffisso di visibilità: presente solo se il filtro esclude uno dei due contesti
  if not ToolbarProps.VisibleInView then
    Result := Result + ' [solo card]'
  else
    if not ToolbarProps.VisibleInCard then
      Result := Result + ' [solo view]';
  // Se visible in entrambi (caso normale): nessun suffisso
end;

procedure TzToolAction.HideInCard;
begin
  PopupProps.VisibleInCard := false;
  ToolbarProps.VisibleInCard := false;
end;

procedure TzToolAction.HideInView;
begin
  PopupProps.VisibleInView := false;
  ToolbarProps.VisibleInView := false;
end;

procedure TzToolAction.HideInPopups;
begin
  PopupProps.VisibleInCard := false;
  PopupProps.VisibleInView := false;
end;

procedure TzToolAction.HideInToolbar;
begin
  ToolbarProps.VisibleInCard := false;
  ToolbarProps.VisibleInView := false;
end;

procedure TzToolAction.SetAction(const Value: TCustomAction);
var
  Comp: TComponent;
begin
  if FAction <> Value then
  begin
    Comp := TComponent(Collection.Owner);

    if (FAction <> nil) and (Comp <> nil) then
      FAction.RemoveFreeNotification(Comp);

    FAction := Value;
    if (FAction <> nil) and (Comp <> nil) then
      FAction.FreeNotification(Comp);

    if Assigned(Action) then
      Name := Action.Name;

    Changed(false);
  end;
end;

procedure TzToolAction.SetCustomImagelist(const Value: TCustomImagelist);
var
  Comp: TComponent;
begin
  if FImageList <> Value then
  begin
    if not Assigned(Value) then
      siMain.logVerbose('SetCustomImagelist=nil');

    Comp := TComponent(Collection.Owner);

    if (FImageList <> nil) and (Comp <> nil) then
      FImageList.RemoveFreeNotification(Comp);

    FImageList := Value;
    if (FImageList <> nil) and (Comp <> nil) then
      FImageList.FreeNotification(Comp);

    Changed(false);
  end;
end;

function TzToolAction.GetImageList: TCustomImagelist;
begin
  if Assigned(ImageList) then
    Result := ImageList
  else
    if LargeButton then
      Result := Base.ImageList24
    else
      Result := Base.ImageList16;
end;

procedure TzToolAction.SetPopupProps(const Value: TzTBCustomItemProps);
begin
  FPopupProps.Assign(Value);
  Changed(false);
end;

procedure TzToolAction.SetToolbarProps(const Value: TzTBCustomItemProps);
begin
  FToolbarProps.Assign(Value);
  Changed(false);
end;

{ TzTBCustomItemProps }

procedure TzTBCustomItemProps.Assign(Source: TPersistent);
begin
  if Source is TzTBCustomItemProps then
  begin
    // DisplayMode := TzTBCustomItemProps(Source).DisplayMode;
    VisibleInView := TzTBCustomItemProps(Source).VisibleInView;
    VisibleInCard := TzTBCustomItemProps(Source).VisibleInCard;
  end
  else
    inherited Assign(Source);
end;

constructor TzTBCustomItemProps.Create;
begin
  inherited;
  // FDisplayMode := nbdmImageAndText;
  FVisibleInView := True;
  FVisibleInCard := True;
end;

{ TzToolActionProps }

procedure TzToolActionProps.Assign(Source: TPersistent);
var
  Item: TzToolActionProps;
begin
  if Source is TzToolActionProps then
  begin
    Item := Source as TzToolActionProps;

    Name := Item.Name;
    FShowCaption := Item.ShowCaption;
    FPopupProps.Assign(Item.PopupProps);
    FToolbarProps.Assign(Item.ToolbarProps);
  end
  else
    inherited Assign(Source);
end;

constructor TzToolActionProps.Create(Collection: TCollection);
begin
  inherited;
  FShowCaption := True;
  FPopupProps := TzTBCustomItemProps.Create;
  FToolbarProps := TzTBCustomItemProps.Create;
end;

procedure TzToolActionProps.SetPopupProps(const Value: TzTBCustomItemProps);
begin
  FPopupProps := Value;
end;

procedure TzToolActionProps.SetToolbarProps(const Value: TzTBCustomItemProps);
begin
  FToolbarProps := Value;
end;

{ TzToolActionsProps }

constructor TzToolActionsProps.Create;
begin
  inherited Create(TzToolActionProps, '', -1, nil, false);
end;

end.

  dbmaster zfbdataset
