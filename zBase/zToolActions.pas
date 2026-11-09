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
    FBeginGroup: Boolean;
    FPosition: integer;
    FPopupProps: TzTBCustomItemProps;
    FToolbarProps: TzTBCustomItemProps;
    FShowCaption: Boolean;
    FSubMenu: string;
    FFromCode: Boolean;
    procedure SetPopupProps(const Value: TzTBCustomItemProps);
    procedure SetToolbarProps(const Value: TzTBCustomItemProps);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    // Metodi fluenti: replicano l'API di TzToolAction (runtime) sui props,
    // così la dichiarazione da codice resta `AddAction(X).HideInCard` invariata.
    function HideInCard: TzToolActionProps;
    function HideInView: TzToolActionProps;
    function HideInPopups: TzToolActionProps;
    function HideInToolbar: TzToolActionProps;
    function SetShowCaption(const Value: Boolean): TzToolActionProps;
    function SetSubMenu(const Value: string): TzToolActionProps;

    // True per le azioni introdotte da codice (AddAction) e non ancora
    // presenti su LZ. NON published: non viene serializzata né copiata da
    // Assign, quindi non "ritorna" mai vera da un caricamento.
    property FromCode: Boolean read FFromCode write FFromCode;
  published
    property BeginGroup: Boolean read FBeginGroup write FBeginGroup default false;
    property Position: integer read FPosition write FPosition default -1;
    property PopupProps: TzTBCustomItemProps read FPopupProps write SetPopupProps;
    property ToolbarProps: TzTBCustomItemProps read FToolbarProps write SetToolbarProps;
    property ShowCaption: Boolean read FShowCaption write FShowCaption;
    // Nome del sottomenu della barra in cui finisce l'azione; vuoto = pulsante
    // diretto sulla barra. Le azioni con lo stesso nome condividono il sottomenu.
    property SubMenu: string read FSubMenu write FSubMenu;
  end;

  TzToolActionsProps = class(TzCollection<TzToolActionProps>)
  protected
  public
    Constructor Create;
    procedure Assign(Source: TPersistent); override;
    function Exists(const Name: string): Boolean;
    function Find(const Name: string): TzToolActionProps;
    function HasFromCode: Boolean;
    procedure ClearFromCode;
    // Aggiunge da Source i SOLI nomi assenti, marcandoli FromCode.
    // LZ (lo stato corrente) vince sempre sui nomi che già esistono.
    // Ritorna True se ha introdotto almeno un nuovo item.
    function MergeFromCode(Source: TzToolActionsProps): Boolean;
  end;

  TzToolAction = class(TzCollectionItem)
  private
    FAction: TCustomAction;
    FPosition: integer;
    FBeginGroup: Boolean;
    FImageList: TCustomImagelist;
    FLargeButton: Boolean;
    FPopupProps: TzTBCustomItemProps;
    FShowCaption: Boolean;
    FSubMenu: string;
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
    property Position: integer read FPosition write FPosition default -1;

    property ImageList: TCustomImagelist read FImageList write SetCustomImagelist;
    property PopupProps: TzTBCustomItemProps read FPopupProps write SetPopupProps;
    property ToolbarProps: TzTBCustomItemProps read FToolbarProps write SetToolbarProps;
    property ShowCaption: Boolean read FShowCaption write FShowCaption;
    property SubMenu: string read FSubMenu write FSubMenu;
  end;

  TzToolActions = class(TzCollection<TzToolAction>)
  private
    FSavedOnChange: TNotifyEvent;
    FRebuilding: Boolean;
    // DIV-TLA-3: livelli di ricostruzione annidati; chiude solo l'ultima EndRebuild
    FRebuildLivelli: Integer;
    FOwner: TComponent;
    Buttons: TList<TdxBarButton>;
    SubItems: TList<TdxBarSubItem>;
    procedure ClearSubItems;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    function Contains(Action: TCustomAction): Boolean;
    class function ActionExistsInBar(Bar: TdxBar; Action: TCustomAction): Boolean; static;

    procedure AssignDefaultImageList(ImageList: TCustomImagelist; LargeImageList: TCustomImagelist);

    function Add(ImageList: TCustomImagelist; const Volatile: Boolean = false): TzToolAction; overload;
    function Add(Action: TCustomAction; ImageList: TCustomImagelist; const Volatile: Boolean = false): TzToolAction; overload;
    procedure RemoveNotification(AComponent: TComponent);
    procedure CreateButtons(Bar: TdxBar; popup: TdxBarPopupMenu; OwnerType: TOwnerType);
    function Exists(const Name: string): Boolean;
    function FindByAction(Action: TCustomAction): TzToolAction;

    procedure DestroyVolatiles;
    procedure BeginRebuild; // sospende OnChange + BeginUpdate
    procedure EndRebuild; // EndUpdate + ripristina OnChange
  end;

  TzActionOwnerResolver = class
  private
    class function HasAnyAction(Comp: TComponent): Boolean; static;
    class function HostDialogOwner(Comp: TComponent): TComponent; static;
  public
    class function ResolveOwner(Component: TComponent; const OverrideName: string): TComponent; static;
    class function CandidateOwners(Component: TComponent): TArray<TComponent>; static;
    class function ActionsOf(Owner: TComponent): TArray<TCustomAction>; static;
    class function FindAction(Owner: TComponent; const ActionName: string): TCustomAction; static;
    // Risale da Owner.ClassType verso gli antenati e restituisce la classe che
    // dichiara per prima un campo pubblicato con questo nome (es. l'azione di
    // un'action list): permette di distinguere le azioni proprie della form
    // concreta da quelle ereditate da una form base (TBaseForm e affini).
    class function DeclaringClass(Owner: TComponent; const FieldName: string): TClass; static;
  end;

  TzActionBuilder = class
  public
    class procedure BuildFromProps(ActionsProps: TzToolActionsProps; RuntimeActions: TzToolActions; ActionOwner: TComponent); static;
  end;

procedure DumpActions(const Caption: string; ToolActions: TzToolActions);

implementation

uses
  System.SysUtils,
  System.Rtti,
  Vcl.Dialogs,
  zMsg,
  zSystem,
  zDxBarHelper,
  zDbViewDlg,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

procedure DumpActions(const Caption: string; ToolActions: TzToolActions);
var
  s: string;
  i: integer;
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
  FPosition := -1;
  FLargeButton := false;
  FImageList := nil;
  FShowCaption := True;
  FPopupProps := TzTBCustomItemProps.Create;
  FToolbarProps := TzTBCustomItemProps.Create;
  FVolatile := false;
end;

function TzToolActions.Contains(Action: TCustomAction): Boolean;
var
  Item: TzToolAction;
begin
  for Item in Self do
    if Item.Action = Action then
      Exit(True);
  Result := false;
end;

constructor TzToolActions.Create(AOwner: TComponent);
begin
  inherited Create(TzToolAction, 'ToolActions', -1, nil);
  FOwner := AOwner;
  FRebuilding := false;
  FSavedOnChange := nil;
  Sorted := false;
  Buttons := TList<TdxBarButton>.Create;
  SubItems := TList<TdxBarSubItem>.Create;
end;

destructor TzToolActions.Destroy;
begin
  FreeAndNil(SubItems);
  FreeAndNil(Buttons);
  inherited;
end;

procedure TzToolActions.ClearSubItems;
var
  i: integer;
  SubItem: TdxBarSubItem;
begin
  // Come ClearButtons: i sottomenu appartengono a FOwner, ma vanno liberati a
  // ogni ricostruzione, altrimenti si accumulano sulla barra.
  for i := SubItems.Count - 1 downto 0 do
  begin
    SubItem := SubItems[i];
    SubItems.Delete(i);
    FreeAndNil(SubItem);
  end;
end;

class function TzToolActions.ActionExistsInBar(Bar: TdxBar; Action: TCustomAction): Boolean;
var
  i: integer;
  Item: TdxBarItem;
begin
  for i := 0 to Bar.ItemLinks.Count - 1 do
  begin
    Item := Bar.ItemLinks[i].Item;
    if Assigned(Item) and (Item is TdxBarButton) then
      if TdxBarButton(Item).Action = Action then
        Exit(True);
  end;
  Result := false;
end;

procedure TzToolActions.DestroyVolatiles;
var
  i: integer;
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
  // Se l'azione è già presente, restituisce l'esistente senza duplicare
  if Assigned(Action) then
  begin
    Result := FindByAction(Action);
    if Assigned(Result) then
      Exit;
  end;

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
    for Item in Self do
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

procedure TzToolActions.CreateButtons(Bar: TdxBar; popup: TdxBarPopupMenu; OwnerType: TOwnerType);
var
  ToolAction: TzToolAction;
  btn: TdxBarButton;
  ItemLink: TdxBarItemLink;
  AddToolbar: Boolean;
  AddPopup: Boolean;
  BarManager: TdxBarManager;
  SubMenuName: string;
  SubItem: TdxBarSubItem;
  SubItemsByName: TDictionary<string, TdxBarSubItem>;
begin
  // siMain.logVerbose(FOwner.Name + '.CreateButtons');

  // ZZ 29.12.2019 AV al caricamento delle form
  if Assigned(FOwner) then
    if csDesigning in FOwner.ComponentState then
      Exit;

  ClearSubItems;
  TzDxBarHelper.ClearButtons(Buttons);

  /// //////////////////////////////////////////
  ///
  BarManager := nil;

  if Assigned(Bar) then
    BarManager := Bar.BarManager;

  if not Assigned(BarManager) then
    if Assigned(popup) then
      BarManager := popup.BarManager;

  ///
  /// //////////////////////////////////////////

  // Un sottomenu per nome (senza distinzione fra maiuscole e minuscole), creato
  // alla prima azione che lo usa e messo sulla barra al posto di quell'azione.
  SubItemsByName := TDictionary<string, TdxBarSubItem>.Create;
  try
    for ToolAction In Self do
      if Assigned(ToolAction.Action) then
      begin
        btn := TzDxBarHelper.CreateBarButton(FOwner, BarManager, ToolAction.Action, ToolAction.GetImageList, ToolAction.ShowCaption);
        Buttons.Add(btn);

        /// //////////////////////////////////////////////////////////////////////////
        AddToolbar := Assigned(Bar);

        case OwnerType of
          otView:
            AddToolbar := AddToolbar and ToolAction.ToolbarProps.VisibleInView;
          otCard:
            AddToolbar := AddToolbar and ToolAction.ToolbarProps.VisibleInCard;
        end;

        if AddToolbar then
        begin
          SubMenuName := Trim(ToolAction.SubMenu);

          // Senza BarManager il sottomenu non si puo' creare: l'azione resta sulla barra
          if (SubMenuName = '') or not Assigned(BarManager) then
            TzDxBarHelper.AddItemLink(Bar, btn, ToolAction.Position, ToolAction.BeginGroup)
          else
          begin
            if not SubItemsByName.TryGetValue(AnsiLowerCase(SubMenuName), SubItem) then
            begin
              SubItem := TdxBarSubItem.Create(FOwner);
              SubItem.BarManager := BarManager;
              SubItem.Caption := SubMenuName;
              SubItems.Add(SubItem);
              SubItemsByName.Add(AnsiLowerCase(SubMenuName), SubItem);
              TzDxBarHelper.AddItemLink(Bar, SubItem, ToolAction.Position, ToolAction.BeginGroup);
            end;

            ItemLink := SubItem.ItemLinks.Add;
            ItemLink.Item := btn;
            ItemLink.BeginGroup := ToolAction.BeginGroup;
          end;
        end;

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

        /// //////////////////////////////////////////////////////////////////////////
      end;
  finally
    SubItemsByName.Free;
  end;
end;

function TzToolActions.Exists(const Name: string): Boolean;
var
  Item: TzToolAction;
begin
  for Item in Self do
    if SameText(Item.Name, Name) then
      Exit(True);
  Result := false;
end;

function TzToolActions.FindByAction(Action: TCustomAction): TzToolAction;
var
  Item: TzToolAction;
begin
  for Item in Self do
    if Item.Action = Action then
      Exit(Item);
  Result := nil;
end;

function TzToolActions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TzToolActions.RemoveNotification(AComponent: TComponent);
var
  i: integer;
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

    // DIV-TLA-2 (nome copiato; flag volatile non copiato, vedi sotto): il setter chiede FreeNotification per l'azione e ne ricava il
    // nome; senza collezione non c'e' proprietario a cui chiederla
    if Assigned(Collection) then
      Action := Item.Action
    else
      FAction := Item.Action;
    Name := Item.Name;
    // Mantis #319 - 2026-11-03: il flag volatile non si copia. Una voce copiata
    // da un altro elenco (azioni della vista nella scheda) non nasce dalle
    // impostazioni di questo componente: se fosse volatile, BuildFromProps la
    // eliminerebbe alla ricostruzione della barra.
    FBeginGroup := Item.BeginGroup;
    FLargeButton := Item.LargeButton;
    FImageList := Item.ImageList;
    FShowCaption := Item.ShowCaption;
    FPopupProps.Assign(Item.PopupProps);
    FToolbarProps.Assign(Item.ToolbarProps);
    FPosition := Item.Position;
    FSubMenu := Item.SubMenu;
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
    FBeginGroup := Item.BeginGroup;
    FPosition := Item.Position;
    FShowCaption := Item.ShowCaption;
    FSubMenu := Item.SubMenu;
    FPopupProps.Assign(Item.PopupProps);
    FToolbarProps.Assign(Item.ToolbarProps);
  end
  else
    inherited Assign(Source);
end;

constructor TzToolActionProps.Create(Collection: TCollection);
begin
  inherited;
  FBeginGroup := false;
  FPosition := -1;
  FShowCaption := True;
  FPopupProps := TzTBCustomItemProps.Create;
  FToolbarProps := TzTBCustomItemProps.Create;
end;

// DIV-TLA-1: i due oggetti creati dal costruttore si liberano qui
destructor TzToolActionProps.Destroy;
begin
  FreeAndNil(FPopupProps);
  FreeAndNil(FToolbarProps);
  inherited;
end;

// DIV-TLA-1: si copia il contenuto, come fa TzToolAction, invece del puntatore
procedure TzToolActionProps.SetPopupProps(const Value: TzTBCustomItemProps);
begin
  FPopupProps.Assign(Value);
end;

procedure TzToolActionProps.SetToolbarProps(const Value: TzTBCustomItemProps);
begin
  FToolbarProps.Assign(Value);
end;

function TzToolActionProps.HideInCard: TzToolActionProps;
begin
  FPopupProps.VisibleInCard := false;
  FToolbarProps.VisibleInCard := false;
  Result := Self;
end;

function TzToolActionProps.HideInView: TzToolActionProps;
begin
  FPopupProps.VisibleInView := false;
  FToolbarProps.VisibleInView := false;
  Result := Self;
end;

function TzToolActionProps.HideInPopups: TzToolActionProps;
begin
  FPopupProps.VisibleInCard := false;
  FPopupProps.VisibleInView := false;
  Result := Self;
end;

function TzToolActionProps.HideInToolbar: TzToolActionProps;
begin
  FToolbarProps.VisibleInCard := false;
  FToolbarProps.VisibleInView := false;
  Result := Self;
end;

function TzToolActionProps.SetShowCaption(const Value: Boolean): TzToolActionProps;
begin
  FShowCaption := Value;
  Result := Self;
end;

function TzToolActionProps.SetSubMenu(const Value: string): TzToolActionProps;
begin
  FSubMenu := Value;
  Result := Self;
end;

{ TzToolActionsProps }

constructor TzToolActionsProps.Create;
begin
  inherited Create(TzToolActionProps, '', -1, nil, false);
end;

procedure TzToolActionsProps.Assign(Source: TPersistent);
var
  Saved: TArray<TzToolActionProps>;
  Item, NewItem: TzToolActionProps;
  i, n: integer;
begin
  // Snapshot degli item dichiarati da codice (FromCode) PRIMA di sovrascrivere:
  // l'Assign base ricarica da LZ (Source) e cancellerebbe le azioni di codice
  // non ancora persistite. Li ri-aggiungiamo dopo, solo se LZ non li contiene.
  n := 0;
  SetLength(Saved, Count);
  for Item in Self do
    if Item.FromCode then
    begin
      Saved[n] := TzToolActionProps.Create(nil);
      Saved[n].Assign(Item); // copia stato (Name/flags); FromCode non è copiato da Assign
      Saved[n].FromCode := True; // ...quindi lo reimpostiamo qui
      Inc(n);
    end;
  SetLength(Saved, n);

  try
    inherited Assign(Source); // ricarica da LZ (può azzerare tutto)

    for i := 0 to High(Saved) do
      if not Exists(Saved[i].Name) then
      begin
        NewItem := Add;
        NewItem.Assign(Saved[i]);
        NewItem.FromCode := True;
      end;
  finally
    for i := 0 to High(Saved) do
      Saved[i].Free;
  end;
end;

function TzToolActionsProps.Exists(const Name: string): Boolean;
begin
  Result := Assigned(Find(Name));
end;

function TzToolActionsProps.Find(const Name: string): TzToolActionProps;
var
  Item: TzToolActionProps;
begin
  Result := nil;
  for Item in Self do
    if SameText(Item.Name, Name) then
      Exit(Item);
end;

function TzToolActionsProps.HasFromCode: Boolean;
var
  Item: TzToolActionProps;
begin
  Result := false;
  for Item in Self do
    if Item.FromCode then
      Exit(True);
end;

procedure TzToolActionsProps.ClearFromCode;
var
  Item: TzToolActionProps;
begin
  for Item in Self do
    Item.FromCode := false;
end;

function TzToolActionsProps.MergeFromCode(Source: TzToolActionsProps): Boolean;
var
  Item, NewItem: TzToolActionProps;
begin
  Result := false;
  if not Assigned(Source) then
    Exit;
  for Item in Source do
    if not Exists(Item.Name) then
    begin
      NewItem := Add;
      NewItem.Assign(Item);
      NewItem.FromCode := True;
      Result := True;
    end;
end;

procedure TzToolActions.BeginRebuild;
begin
  Inc(FRebuildLivelli);
  if FRebuilding then
    Exit; // ricostruzione gia' in corso: non re-sospendere
  FRebuilding := True;
  FSavedOnChange := OnChange;
  OnChange := nil;
  BeginUpdate;
end;

procedure TzToolActions.EndRebuild;
begin
  if not FRebuilding then
    Exit;
  Dec(FRebuildLivelli);
  if FRebuildLivelli > 0 then
    Exit; // c'e' ancora una ricostruzione esterna aperta
  try
    EndUpdate; // emette Changed, ma OnChange e' nil -> niente rientro
  finally
    OnChange := FSavedOnChange; // ripristino DOPO EndUpdate
    FSavedOnChange := nil;
    FRebuilding := false;
  end;
end;

{ TzActionOwnerResolver }

class function TzActionOwnerResolver.HasAnyAction(Comp: TComponent): Boolean;
var
  i: integer;
begin
  Result := false;
  if not Assigned(Comp) then
    Exit;
  for i := 0 to Comp.ComponentCount - 1 do
    if Comp.Components[i] is TCustomAction then
      Exit(True);
end;

class function TzActionOwnerResolver.HostDialogOwner(Comp: TComponent): TComponent;
//
// Se Comp e' (direttamente o indirettamente) ospitato in un TzDbViewDlg,
// restituisce l'Owner del dialog — cioe' il form applicativo che possiede
// le action di dominio. Altrimenti nil.
//
var
  Cur: TComponent;
begin
  Result := nil;
  Cur := Comp;
  while Assigned(Cur) do
  begin
    if Cur is TzDbViewDlg then
    begin
      Result := Cur.Owner;
      Exit;
    end;
    Cur := Cur.Owner;
  end;
end;

class function TzActionOwnerResolver.ResolveOwner(Component: TComponent; const OverrideName: string): TComponent;
//
// Regola di risoluzione (in ordine di priorita'):
// 1) OverrideName esplicito, se non vuoto e risolvibile lungo la catena
// 2) Owner del TzDbViewDlg ospitante, se presente
// 3) Owner diretto del componente
//
var
  Cur: TComponent;
  Host: TComponent;
begin
  Result := nil;
  if not Assigned(Component) then
    Exit;

  if OverrideName <> '' then
  begin
    Cur := Component;
    while Assigned(Cur) do
    begin
      if SameText(Cur.Name, OverrideName) then
        Exit(Cur);
      if Assigned(Cur.Owner) and SameText(Cur.Owner.Name, OverrideName) then
        Exit(Cur.Owner);
      if Assigned(Cur.Owner) then
      begin
        Result := Cur.Owner.FindComponent(OverrideName);
        if Assigned(Result) then
          Exit;
      end;
      Cur := Cur.Owner;
    end;
  end;

  Host := HostDialogOwner(Component);
  if Assigned(Host) then
    Exit(Host);

  Result := Component.Owner;
end;

class function TzActionOwnerResolver.CandidateOwners(Component: TComponent): TArray<TComponent>;
//
// Risale la catena Owner raccogliendo i contenitori (form / datamodule)
// che dichiarano almeno una TCustomAction. Aggiunge anche l'Owner del
// TzDbViewDlg ospitante se non gia' incluso. Deduplica preservando l'ordine.
//
var
  List: TList<TComponent>;
  Cur: TComponent;
  Host: TComponent;

  procedure AddIfRelevant(Comp: TComponent);
  begin
    if Assigned(Comp) and HasAnyAction(Comp) and (List.IndexOf(Comp) < 0) then
      List.Add(Comp);
  end;

begin
  List := TList<TComponent>.Create;
  try
    Cur := Component;
    while Assigned(Cur) do
    begin
      AddIfRelevant(Cur);
      Cur := Cur.Owner;
    end;

    Host := HostDialogOwner(Component);
    AddIfRelevant(Host);

    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

class function TzActionOwnerResolver.DeclaringClass(Owner: TComponent; const FieldName: string): TClass;
//
// GetDeclaredFields restituisce solo i campi dichiarati direttamente sulla
// classe interrogata (non quelli ereditati): risalendo ClassParent troviamo
// quindi il primo livello della gerarchia che pubblica FieldName.
//
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Field: TRttiField;
  CurrentClass: TClass;
begin
  Result := nil;
  if not Assigned(Owner) then
    Exit;

  CurrentClass := Owner.ClassType;
  while Assigned(CurrentClass) do
  begin
    RttiType := Context.GetType(CurrentClass);
    if Assigned(RttiType) and (RttiType is TRttiInstanceType) then
      for Field in TRttiInstanceType(RttiType).GetDeclaredFields do
        if SameText(Field.Name, FieldName) then
          Exit(CurrentClass);
    CurrentClass := CurrentClass.ClassParent;
  end;
end;

class function TzActionOwnerResolver.ActionsOf(Owner: TComponent): TArray<TCustomAction>;
var
  List: TList<TCustomAction>;
  i: integer;
begin
  List := TList<TCustomAction>.Create;
  try
    if Assigned(Owner) then
      for i := 0 to Owner.ComponentCount - 1 do
        if Owner.Components[i] is TCustomAction then
          List.Add(TCustomAction(Owner.Components[i]));
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

class function TzActionOwnerResolver.FindAction(Owner: TComponent; const ActionName: string): TCustomAction;
var
  Comp: TComponent;
begin
  Result := nil;
  if not Assigned(Owner) then
    Exit;
  Comp := Owner.FindComponent(ActionName);
  if Comp is TCustomAction then
    Result := TCustomAction(Comp);
end;

{ TzActionBuilder }

class procedure TzActionBuilder.BuildFromProps(ActionsProps: TzToolActionsProps; RuntimeActions: TzToolActions; ActionOwner: TComponent);
//
// Popola RuntimeActions a partire dalle ActionsProps persistenti, risolvendo
// ogni nome sull'ActionOwner fornito (gia' risolto dal chiamante via
// TzActionOwnerResolver). Comportamento identico all'originale
// TzDbView.CreateActionsFromProps, ma parametrico sull'owner: distrugge i
// volatili, ricostruisce, copia i flag. La chiamata a InitToolActions
// (CreateButtons) resta responsabilita' del componente.
//
var
  ActionProps: TzToolActionProps;
  Action: TCustomAction;
  ToolAction: TzToolAction;
begin
  if not Assigned(ActionsProps) or not Assigned(RuntimeActions) then
    Exit;

  RuntimeActions.BeginRebuild;
  try
    RuntimeActions.DestroyVolatiles;

    for ActionProps in ActionsProps do
    begin
      Action := TzActionOwnerResolver.FindAction(ActionOwner, ActionProps.Name);
      if Assigned(Action) then
      begin
        ToolAction := RuntimeActions.Add(Action, nil, True);
        ToolAction.BeginGroup := ActionProps.BeginGroup;
        ToolAction.Position := ActionProps.Position;
        ToolAction.PopupProps := ActionProps.PopupProps;
        ToolAction.ToolbarProps := ActionProps.ToolbarProps;
        ToolAction.ShowCaption := ActionProps.ShowCaption;
        ToolAction.SubMenu := ActionProps.SubMenu;
      end;
    end;
  finally
    RuntimeActions.EndRebuild;
  end;
end;

end.
