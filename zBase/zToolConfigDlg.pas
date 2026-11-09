// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-26
// ---------------------------------------------------------------------------
unit zToolConfigDlg;

{
  TzToolConfigDlgForm — editor runtime (admin) per ToolActions e ToolFilters.
  Versione con controlli Developer Express (cx*).

  Dialoga con IzBaseComponent (azioni) e, se filtrabile, IzBaseFilterableComponent. Lavora su CLONI dei props persistenti
  (FWorkActions / FWorkFilters): le modifiche diventano effettive solo su OK,
  che riassegna i cloni ai props del componente e richiama
  RebuildActions / RebuildFilters (i quali ricostruiscono il runtime e salvano).
  Su Annulla i cloni vengono scartati.

  Le azioni disponibili sono pescate dall'owner risolto via
  TzActionOwnerResolver; il combo Sorgente permette di forzare un owner diverso
  fra quelli candidati (persistito come ActionOwnerName).

  Note sui controlli DX:
  - tlAvailable (TcxTreeList): azioni disponibili. Una colonna testo + checkbox
  nativa (OptionsView.CheckGroups). Node.Data = TCustomAction (non posseduta dal
  treelist). Node.Checked guida l'inclusione (OnNodeCheckChanged).
  - tlSelected (TcxTreeList): azioni incluse. Node.Data = TzToolActionProps clonato.
  OnFocusedNodeChanged carica i flag di dettaglio.

  --------------------------------------------------------------------------
  2026-09-06 — tlFilters diventa a due livelli (classi / istanze)
  --------------------------------------------------------------------------
  Prima, tlFilters mostrava una riga per CLASSE registrata con una casella di
  spunta, e la corrispondenza con la configurazione salvata avveniva per
  TzToolFilterProps.Name. Conseguenze:
  - una view non poteva avere due filtri della stessa classe (due 'PickList');
  - l'etichetta della riga veniva calcolata risolvendo la classe con props
    VUOTE, quindi per i filtri generici usciva un moncone tipo 'Filtro ',
    e la riga risultava di fatto illeggibile;
  - la colonna col nome logico e' nascosta, quindi non c'era modo di capire
    quale riga fosse quale.

  Ora l'albero ha due livelli:
  - livello 1 = CLASSE registrata (Node.Data = nil). La casella indica se
    esiste almeno un'istanza: spuntandola si crea la prima, togliendola si
    rimuovono tutte le istanze di quella classe.
  - livello 2 = ISTANZA configurata (Node.Data = TzToolFilterProps del clone).
    La casella e' sempre spuntata; toglierla rimuove quella singola istanza.

  Per aggiungere una SECONDA istanza della stessa classe si usa il menu di
  scelta rapida ("Aggiungi filtro"), costruito da codice in FormCreate: non
  servono modifiche al DFM.

  L'identita' del prop e' sdoppiata (vedi zToolFilter.pas):
  FilterName = classe registrata, Name = istanza univoca nella view.

  --------------------------------------------------------------------------
  2026-10-26 — tlSelected ad albero per i sottomenu della barra
  --------------------------------------------------------------------------
  tlSelected mostra le azioni nell'ordine della barra (non piu' alfabetico):
  al primo livello quelle dirette, poi un nodo per ogni sottomenu
  (TzToolActionProps.SubMenu, Node.Data = nil) con le sue azioni.
  Selezione multipla e menu di scelta rapida costruito da codice: sposta le
  azioni selezionate in un sottomenu esistente o nuovo, le rimette sulla
  barra, rinomina un sottomenu. Selezionare un nodo sottomenu vale come
  selezionare tutte le sue azioni.
}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  cxCustomListBox,
  dxBarBuiltInMenu,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxPC,
  cxLabel,
  cxButtons,
  cxCheckBox,
  cxTL,
  cxTLData,
  cxTextEdit,
  cxMemo,
  cxDropDownEdit,
  cxSplitter,
  cxGroupBox,
  dxForms,
  cxMaskEdit,
  dxLayoutcxEditAdapters,
  dxLayoutControlAdapters,
  dxLayoutContainer,
  cxClasses,
  dxLayoutControl,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  zToolActions,
  zSystem,
  cxVGrid,
  cxOI,
  dxToggleSwitch,
  Frame_ObjectInspector;

type
  TzToolConfigDlgForm = class(TdxForm)
    cbOwner: TcxComboBox;
    btnDefaultOwner: TcxButton;
    tlAvailable: TcxTreeList;
    tlSelected: TcxTreeList;
    tlFilters: TcxTreeList;
    tlAvailableColName: TcxTreeListColumn;
    tlSelectedColName: TcxTreeListColumn;
    tlFiltersColCaption: TcxTreeListColumn;
    tlFiltersColName: TcxTreeListColumn;
    memParams: TcxMemo;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutGroupMain: TdxLayoutGroup;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayoutGroup4: TdxLayoutGroup;
    dxLayoutGroup5: TdxLayoutGroup;
    dxLayoutGroup6: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayoutItem2: TdxLayoutItem;
    dxLayoutGroup7: TdxLayoutGroup;
    dxLayoutGroup8: TdxLayoutGroup;
    dxLayoutGroup9: TdxLayoutGroup;
    dxLayoutItem3: TdxLayoutItem;
    dxLayoutSplitterItem1: TdxLayoutSplitterItem;
    dxLayoutGroup10: TdxLayoutGroup;
    dxLayoutGroup11: TdxLayoutGroup;
    dxLayoutItem4: TdxLayoutItem;
    dxLayoutGroupFilters: TdxLayoutGroup;
    dxLayoutGroup16: TdxLayoutGroup;
    dxLayoutItem10: TdxLayoutItem;
    dxLayoutSplitterItem2: TdxLayoutSplitterItem;
    dxLayoutGroup17: TdxLayoutGroup;
    dxLayoutItem12: TdxLayoutItem;
    dxLayoutGroup20: TdxLayoutGroup;
    dxLayoutGroup21: TdxLayoutGroup;
    dxLayoutGroup22: TdxLayoutGroup;
    dxLayoutItem13: TdxLayoutItem;
    dxLayoutItem14: TdxLayoutItem;
    inspActions: TFrameObjectInspector;
    dxLayoutItemInspActions: TdxLayoutItem;
    dxLayoutSplitterItem3: TdxLayoutSplitterItem;
    inspFilters: TFrameObjectInspector;
    dxLayoutItemInspFilters: TdxLayoutItem;
    dxLayoutGroupFilterDetails: TdxLayoutGroup;
    dxLayoutSplitterItem4: TdxLayoutSplitterItem;
    tlAvailableColSelected: TcxTreeListColumn;
    tlFiltersColSelected: TcxTreeListColumn;
    tlAvailableColOrigin: TcxTreeListColumn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbOwnerPropertiesChange(Sender: TObject);
    procedure btnDefaultOwnerClick(Sender: TObject);
    procedure memParamsExit(Sender: TObject);
    procedure tlFiltersSelectionChanged(Sender: TObject);
    procedure tlSelectedSelectionChanged(Sender: TObject);
    procedure tlAvailableEditValueChanged(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
    procedure tlFiltersEditValueChanged(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
  private
    FConfig: IzBaseComponent;
    FFilterable: IzBaseFilterableComponent;
    FComponent: TComponent;

    FWorkActions: TzToolActionsProps;
    FWorkFilters: TzToolFiltersProps;
    FWorkOwnerName: string;

    FCandidates: TArray<TComponent>;
    FUpdating: Boolean;

    // Menu di scelta rapida di tlFilters, costruito da codice (nessuna
    // modifica al DFM): e' l'unico modo per aggiungere una SECONDA istanza
    // della stessa classe di filtro.
    FFiltersMenu: TPopupMenu;
    FMenuAddFilter: TMenuItem;
    FMenuDeleteFilter: TMenuItem;

    // Menu di scelta rapida di tlSelected per i sottomenu della barra.
    // FSubMenuNames tiene i nomi offerti in "Sposta nel sottomenu": la voce
    // ne porta l'indice in Tag, perche' Caption riceve le scorciatoie '&'.
    FSelectedMenu: TPopupMenu;
    FMenuMoveToSubMenu: TMenuItem;
    FMenuMoveToBar: TMenuItem;
    FMenuRenameSubMenu: TMenuItem;
    FSubMenuNames: TStringList;
    FRefreshTimer: TTimer;
    FPendingFocus: TzToolActionProps;

    procedure InitFromConfig;
    procedure PopulateOwners;
    function CurrentOwner: TComponent;
    procedure PopulateAvailableActions;
    procedure PopulateSelectedActions;
    function FindActionProps(const Name: string): TzToolActionProps;
    function SelectedActionProps: TzToolActionProps;
    procedure BindActionInspector(Props: TzToolActionProps);

    // ── Sottomenu delle azioni ────────────────────────────────────────────
    procedure CreateSelectedMenu;
    procedure SelectedMenuPopup(Sender: TObject);
    procedure SelectedMenuMoveToClick(Sender: TObject);
    procedure SelectedMenuNewSubMenuClick(Sender: TObject);
    procedure SelectedMenuMoveToBarClick(Sender: TObject);
    procedure SelectedMenuRenameClick(Sender: TObject);
    procedure ActionInspectorModified(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    function FocusedSubMenuName: string;
    function SelectedActionsProps: TArray<TzToolActionProps>;
    procedure AssignSubMenu(const Actions: TArray<TzToolActionProps>; const SubMenuName: string);
    procedure FocusActionProps(Props: TzToolActionProps);

    // ── Filtri ────────────────────────────────────────────────────────────
    procedure CreateFiltersMenu;
    procedure FiltersMenuPopup(Sender: TObject);
    procedure FiltersMenuAddClick(Sender: TObject);
    procedure FiltersMenuDeleteClick(Sender: TObject);

    procedure PopulateFilters;
    function InstanceCaption(Props: TzToolFilterProps): string;
    // Nome della classe a cui si riferisce il nodo attivo, sia esso il nodo
    // classe o un nodo istanza.
    function FocusedFilterName: string;
    function SelectedFilterProps: TzToolFilterProps;
    procedure BindFilterInspector(Props: TzToolFilterProps);

    function AddFilterInstance(const AFilterName: string): TzToolFilterProps;
    procedure RemoveFilterInstance(Props: TzToolFilterProps);
    procedure RemoveAllFilterInstances(const AFilterName: string);
    procedure SelectFilterInstance(Props: TzToolFilterProps);

    procedure Commit;
  public
    class procedure Execute(const Config: IzBaseComponent); static;
  end;

implementation

{$R *.dfm}

uses
  zToolFilter,
  dxCore,
  Vcl.Dialogs,
  System.Variants;

{ TzToolConfigDlgForm }

class procedure TzToolConfigDlgForm.Execute(const Config: IzBaseComponent);
var
  Dlg: TzToolConfigDlgForm;
begin
  if not Assigned(Config) then
    Exit;

  Dlg := TzToolConfigDlgForm.Create(Application);
  try
    Dlg.FConfig := Config;
    Dlg.FComponent := Config as TComponent;
    // I filtri sono opzionali: disponibili solo se il componente è filtrabile.
    if not Supports(Config, IzBaseFilterableComponent, Dlg.FFilterable) then
      Dlg.FFilterable := nil;
    Dlg.InitFromConfig;
    if Dlg.ShowModal = mrOk then
      Dlg.Commit;
  finally
    Dlg.FFilterable := nil;
    Dlg.FConfig := nil;
    Dlg.Free;
  end;
end;

procedure TzToolConfigDlgForm.FormCreate(Sender: TObject);

  procedure InitTreeList(tree: TcxTreeList; FilterColumn: TcxTreeListColumn; images: TCustomImageList);
  begin
    tree.Root.CheckGroupType := ncgNone;
    tree.images := images;
    tree.OptionsView.Headers := True;
    tree.OptionsView.ColumnAutoWidth := True;
    tree.OptionsCustomizing.ColumnFiltering := bTrue;

    FilterColumn.Options.Filtering := True;
  end;

begin
  FWorkActions := TzToolActionsProps.Create;
  FWorkFilters := TzToolFiltersProps.Create(TzToolFilterProps, 'ToolFilters', -1, nil, False);

  dxLayoutGroupMain.ItemIndex := 0;

  InitTreeList(tlAvailable, tlAvailableColName, Base.ImageList16);
  InitTreeList(tlSelected, tlSelectedColName, Base.ImageList16);
  InitTreeList(tlFilters, tlFiltersColName, nil);

  // tlFilters ora e' gerarchico: classi al primo livello, istanze al secondo
  tlFilters.OptionsView.ShowRoot := True;
  tlFilters.OptionsBehavior.ExpandOnDblClick := True;

  CreateFiltersMenu;

  // tlSelected ad albero, nell'ordine della barra: niente ordinamento alfabetico
  FSubMenuNames := TStringList.Create;
  tlSelectedColName.SortOrder := soNone;
  tlSelected.OptionsView.ShowRoot := True;
  tlSelected.OptionsSelection.MultiSelect := True;
  CreateSelectedMenu;
  inspActions.OnModified := ActionInspectorModified;
  FRefreshTimer := TTimer.Create(Self);
  FRefreshTimer.Enabled := False;
  FRefreshTimer.Interval := 1;
  FRefreshTimer.OnTimer := RefreshTimerTimer;

  inspActions.ObjectInspector.OptionsView.RowHeaderWidth := 171;
  inspFilters.ObjectInspector.OptionsView.RowHeaderWidth := 134;
end;

procedure TzToolConfigDlgForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FWorkActions);
  FreeAndNil(FWorkFilters);
  FreeAndNil(FSubMenuNames);
end;

procedure TzToolConfigDlgForm.InitFromConfig;
begin
  Caption := 'Configurazione - ' + FConfig.ConfigTitle;

  FWorkActions.Assign(FConfig.Props.ToolActions);
  FWorkOwnerName := FConfig.GetActionOwnerName;

  dxLayoutGroupFilters.Visible := Assigned(FFilterable);
  if Assigned(FFilterable) then
    FWorkFilters.Assign(FFilterable.ToolFilters);

  PopulateOwners;
  PopulateAvailableActions;
  PopulateSelectedActions;

  if Assigned(FFilterable) then
    PopulateFilters;

  dxLayoutGroupMain.ItemIndex := 0;
end;

procedure TzToolConfigDlgForm.PopulateOwners;
var
  I: Integer;
  Comp: TComponent;
  Idx: Integer;
  DefaultOwner: TComponent;
begin
  FCandidates := TzActionOwnerResolver.CandidateOwners(FComponent);

  // Default quando non c'è un owner salvato: la form applicativa ospitante
  // (stesso criterio usato a runtime da BuildFromProps), non il primo candidato.
  DefaultOwner := nil;
  if FWorkOwnerName = '' then
    DefaultOwner := TzActionOwnerResolver.ResolveOwner(FComponent, '');

  cbOwner.Properties.Items.BeginUpdate;
  try
    cbOwner.Properties.Items.Clear;
    Idx := 0;
    for I := 0 to High(FCandidates) do
    begin
      Comp := FCandidates[I];
      cbOwner.Properties.Items.AddObject(Comp.Name + '  (' + Comp.ClassName + ')', Comp);
      if FWorkOwnerName <> '' then
      begin
        if SameText(Comp.Name, FWorkOwnerName) then
          Idx := I;
      end
      else
        if (DefaultOwner <> nil) and (Comp = DefaultOwner) then
          Idx := I;
    end;
  finally
    cbOwner.Properties.Items.EndUpdate;
  end;

  if cbOwner.Properties.Items.Count > 0 then
    cbOwner.ItemIndex := Idx;
end;

function TzToolConfigDlgForm.CurrentOwner: TComponent;
begin
  if (cbOwner.ItemIndex >= 0) and (cbOwner.ItemIndex < Length(FCandidates)) then
    Result := FCandidates[cbOwner.ItemIndex]
  else
    Result := TzActionOwnerResolver.ResolveOwner(FComponent, FWorkOwnerName);
end;

procedure TzToolConfigDlgForm.cbOwnerPropertiesChange(Sender: TObject);
var
  Owner: TComponent;
begin
  if FUpdating then
    Exit;
  Owner := CurrentOwner;
  if Assigned(Owner) then
    FWorkOwnerName := Owner.Name;
  PopulateAvailableActions;
end;

procedure TzToolConfigDlgForm.btnDefaultOwnerClick(Sender: TObject);
begin
  FWorkOwnerName := '';
  PopulateOwners;
  PopulateAvailableActions;
end;

procedure TzToolConfigDlgForm.PopulateAvailableActions;
var
  Actions: TArray<TCustomAction>;
  Action: TCustomAction;
  Cap: string;
  Node: TcxTreeListNode;
  Owner: TComponent;
  DeclClass: TClass;
begin
  FUpdating := True;

  tlAvailable.BeginUpdate;
  try
    tlAvailable.Clear;

    Owner := CurrentOwner;
    Actions := TzActionOwnerResolver.ActionsOf(Owner);

    for Action in Actions do
    begin
      Cap := Action.Name;
      if Action.Caption <> '' then
        Cap := Cap + ' - ' + Action.Caption;
      Node := tlAvailable.Add;
      Node.Texts[tlAvailableColName.ItemIndex] := Cap;
      Node.Values[tlAvailableColSelected.ItemIndex] := FWorkActions.Exists(Action.Name);
      Node.Data := Action;
      Node.ImageIndex := Action.ImageIndex;

      // Origine dell'azione: dichiarata sulla form derivata (Owner.ClassType)
      // oppure ereditata da una classe antenata (es. TBaseForm).
      DeclClass := TzActionOwnerResolver.DeclaringClass(Owner, Action.Name);
      if Assigned(DeclClass) and Assigned(Owner) and (DeclClass <> Owner.ClassType) then
        Node.Texts[tlAvailableColOrigin.ItemIndex] := 'Ereditata (' + DeclClass.ClassName + ')'
      else
        Node.Texts[tlAvailableColOrigin.ItemIndex] := 'Propria';
    end;
  finally
    tlAvailable.EndUpdate;
    FUpdating := False;
  end;
end;

procedure TzToolConfigDlgForm.PopulateSelectedActions;
var
  AProps: TzToolActionProps;
  Node, GroupNode: TcxTreeListNode;
  Groups: TDictionary<string, TcxTreeListNode>;
  SubMenuName: string;
  Actions: TArray<TCustomAction>;
  Action, Found: TCustomAction;
begin
  Actions := TzActionOwnerResolver.ActionsOf(CurrentOwner);

  Groups := TDictionary<string, TcxTreeListNode>.Create;
  tlSelected.BeginUpdate;
  try
    tlSelected.Clear;
    for AProps in FWorkActions do
    begin
      // Stesso criterio di TzToolActions.CreateButtons: un sottomenu per nome,
      // senza distinzione fra maiuscole e minuscole, dove compare la prima volta
      SubMenuName := Trim(AProps.SubMenu);
      if SubMenuName = '' then
        Node := tlSelected.Add
      else
      begin
        if not Groups.TryGetValue(AnsiLowerCase(SubMenuName), GroupNode) then
        begin
          GroupNode := tlSelected.Add;
          GroupNode.Texts[tlSelectedColName.ItemIndex] := 'Sottomenu: ' + SubMenuName;
          GroupNode.Data := nil;
          GroupNode.ImageIndex := -1;
          Groups.Add(AnsiLowerCase(SubMenuName), GroupNode);
        end;
        Node := GroupNode.AddChild;
      end;

      Node.Texts[tlSelectedColName.ItemIndex] := AProps.Name;
      Node.Data := AProps;

      Found := nil;
      for Action in Actions do
        if SameText(Action.Name, AProps.Name) then
        begin
          Found := Action;
          Break;
        end;
      if Assigned(Found) then
        Node.ImageIndex := Found.ImageIndex
      else
        Node.ImageIndex := -1;
    end;
    tlSelected.FullExpand;
  finally
    tlSelected.EndUpdate;
    Groups.Free;
  end;

  BindActionInspector(nil);
end;

function TzToolConfigDlgForm.FindActionProps(const Name: string): TzToolActionProps;
var
  AProps: TzToolActionProps;
begin
  Result := nil;
  for AProps in FWorkActions do
    if SameText(AProps.Name, Name) then
      Exit(AProps);
end;

function TzToolConfigDlgForm.SelectedActionProps: TzToolActionProps;
begin
  Result := nil;
  if Assigned(tlSelected.FocusedNode) then
    Result := TzToolActionProps(tlSelected.FocusedNode.Data);
end;

procedure TzToolConfigDlgForm.BindActionInspector(Props: TzToolActionProps);
begin
  FUpdating := True;
  try
    inspActions.Enabled := Assigned(Props);
    inspActions.InspectedObject := Props; // nil azzera l'editor
  finally
    FUpdating := False;
  end;
end;

// ── Azioni: sottomenu della barra ─────────────────────────────────────────────

procedure TzToolConfigDlgForm.CreateSelectedMenu;
begin
  FSelectedMenu := TPopupMenu.Create(Self);
  FSelectedMenu.OnPopup := SelectedMenuPopup;

  FMenuMoveToSubMenu := TMenuItem.Create(FSelectedMenu);
  FMenuMoveToSubMenu.Caption := 'Sposta nel sottomenu';
  FSelectedMenu.Items.Add(FMenuMoveToSubMenu);

  FMenuMoveToBar := TMenuItem.Create(FSelectedMenu);
  FMenuMoveToBar.Caption := 'Rimetti sulla barra';
  FMenuMoveToBar.OnClick := SelectedMenuMoveToBarClick;
  FSelectedMenu.Items.Add(FMenuMoveToBar);

  FMenuRenameSubMenu := TMenuItem.Create(FSelectedMenu);
  FMenuRenameSubMenu.Caption := 'Rinomina sottomenu...';
  FMenuRenameSubMenu.OnClick := SelectedMenuRenameClick;
  FSelectedMenu.Items.Add(FMenuRenameSubMenu);

  tlSelected.PopupMenu := FSelectedMenu;
end;

procedure TzToolConfigDlgForm.SelectedMenuPopup(Sender: TObject);
var
  AProps: TzToolActionProps;
  SubMenuName: string;
  I: Integer;
  MenuItem: TMenuItem;
  HasSelection: Boolean;
begin
  // Le voci "Sposta nel sottomenu" si rifanno a ogni apertura: i nomi
  // cambiano mentre si lavora
  FMenuMoveToSubMenu.Clear;
  FSubMenuNames.Clear;
  for AProps in FWorkActions do
  begin
    SubMenuName := Trim(AProps.SubMenu);
    if (SubMenuName <> '') and (FSubMenuNames.IndexOf(SubMenuName) < 0) then
      FSubMenuNames.Add(SubMenuName);
  end;

  for I := 0 to FSubMenuNames.Count - 1 do
  begin
    MenuItem := TMenuItem.Create(FMenuMoveToSubMenu);
    MenuItem.Caption := FSubMenuNames[I].Replace('&', '&&');
    MenuItem.Tag := I;
    MenuItem.OnClick := SelectedMenuMoveToClick;
    FMenuMoveToSubMenu.Add(MenuItem);
  end;

  if FSubMenuNames.Count > 0 then
  begin
    MenuItem := TMenuItem.Create(FMenuMoveToSubMenu);
    MenuItem.Caption := cLineCaption;
    FMenuMoveToSubMenu.Add(MenuItem);
  end;

  MenuItem := TMenuItem.Create(FMenuMoveToSubMenu);
  MenuItem.Caption := 'Nuovo sottomenu...';
  MenuItem.OnClick := SelectedMenuNewSubMenuClick;
  FMenuMoveToSubMenu.Add(MenuItem);

  HasSelection := Length(SelectedActionsProps) > 0;
  FMenuMoveToSubMenu.Enabled := HasSelection;
  FMenuMoveToBar.Enabled := HasSelection;
  FMenuRenameSubMenu.Enabled := FocusedSubMenuName <> '';
end;

function TzToolConfigDlgForm.FocusedSubMenuName: string;
var
  Node: TcxTreeListNode;
  AProps: TzToolActionProps;
begin
  // Il sottomenu del nodo attivo: il nodo sottomenu stesso o una sua azione
  Result := '';
  Node := tlSelected.FocusedNode;
  if not Assigned(Node) then
    Exit;

  if not Assigned(Node.Data) and (Node.Count > 0) then
    Node := Node.Items[0];

  AProps := TzToolActionProps(Node.Data);
  if Assigned(AProps) then
    Result := Trim(AProps.SubMenu);
end;

function TzToolConfigDlgForm.SelectedActionsProps: TArray<TzToolActionProps>;
var
  Found: TList<TzToolActionProps>;
  I, J: Integer;
  Node: TcxTreeListNode;

  procedure AddProps(N: TcxTreeListNode);
  begin
    if Assigned(N.Data) and not Found.Contains(TzToolActionProps(N.Data)) then
      Found.Add(TzToolActionProps(N.Data));
  end;

begin
  // Un nodo sottomenu selezionato vale come tutte le sue azioni
  Found := TList<TzToolActionProps>.Create;
  try
    for I := 0 to tlSelected.SelectionCount - 1 do
    begin
      Node := tlSelected.Selections[I];
      if Assigned(Node.Data) then
        AddProps(Node)
      else
        for J := 0 to Node.Count - 1 do
          AddProps(Node.Items[J]);
    end;
    Result := Found.ToArray;
  finally
    Found.Free;
  end;
end;

procedure TzToolConfigDlgForm.AssignSubMenu(const Actions: TArray<TzToolActionProps>; const SubMenuName: string);
var
  AProps: TzToolActionProps;
begin
  if Length(Actions) = 0 then
    Exit;

  for AProps in Actions do
    AProps.SubMenu := SubMenuName;

  PopulateSelectedActions;
  FocusActionProps(Actions[0]);
end;

procedure TzToolConfigDlgForm.FocusActionProps(Props: TzToolActionProps);
var
  I: Integer;
  Node: TcxTreeListNode;
begin
  for I := 0 to tlSelected.AbsoluteCount - 1 do
  begin
    Node := tlSelected.AbsoluteItems[I];
    if Node.Data = Props then
    begin
      Node.MakeVisible;
      Node.Focused := True;
      Node.Selected := True;
      Exit;
    end;
  end;
end;

procedure TzToolConfigDlgForm.SelectedMenuMoveToClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := TMenuItem(Sender).Tag;
  if (Index >= 0) and (Index < FSubMenuNames.Count) then
    AssignSubMenu(SelectedActionsProps, FSubMenuNames[Index]);
end;

procedure TzToolConfigDlgForm.SelectedMenuNewSubMenuClick(Sender: TObject);
var
  Actions: TArray<TzToolActionProps>;
  SubMenuName: string;
begin
  // La selezione si legge prima della finestra di richiesta
  Actions := SelectedActionsProps;
  if Length(Actions) = 0 then
    Exit;

  SubMenuName := '';
  if not InputQuery('Nuovo sottomenu', 'Nome del sottomenu:', SubMenuName) then
    Exit;

  SubMenuName := Trim(SubMenuName);
  if SubMenuName <> '' then
    AssignSubMenu(Actions, SubMenuName);
end;

procedure TzToolConfigDlgForm.SelectedMenuMoveToBarClick(Sender: TObject);
begin
  AssignSubMenu(SelectedActionsProps, '');
end;

procedure TzToolConfigDlgForm.SelectedMenuRenameClick(Sender: TObject);
var
  OldName, NewName: string;
  AProps, First: TzToolActionProps;
begin
  OldName := FocusedSubMenuName;
  if OldName = '' then
    Exit;

  NewName := OldName;
  if not InputQuery('Rinomina sottomenu', 'Nome del sottomenu:', NewName) then
    Exit;

  NewName := Trim(NewName);
  if (NewName = '') or (NewName = OldName) then
    Exit;

  First := nil;
  for AProps in FWorkActions do
    if SameText(Trim(AProps.SubMenu), OldName) then
    begin
      AProps.SubMenu := NewName;
      if not Assigned(First) then
        First := AProps;
    end;

  PopulateSelectedActions;
  if Assigned(First) then
    FocusActionProps(First);
end;

procedure TzToolConfigDlgForm.ActionInspectorModified(Sender: TObject);
var
  AProps: TzToolActionProps;
  Node: TcxTreeListNode;
  ShownSubMenu: string;
begin
  if FUpdating then
    Exit;

  AProps := SelectedActionProps;
  Node := tlSelected.FocusedNode;
  if not Assigned(AProps) or not Assigned(Node) then
    Exit;

  // Si rifa' l'albero solo se e' cambiato il sottomenu
  ShownSubMenu := '';
  if Node.Level > 0 then
    ShownSubMenu := TzToolActionProps(Node.Parent.Items[0].Data).SubMenu;
  if SameText(Trim(ShownSubMenu), Trim(AProps.SubMenu)) then
    Exit;

  // Dopo l'evento, non dentro: PopulateSelectedActions ricollega l'ispettore
  // che sta ancora notificando la modifica. Il timer appartiene alla form,
  // quindi non scatta piu' se la form si chiude prima.
  FPendingFocus := AProps;
  FRefreshTimer.Enabled := True;
end;

procedure TzToolConfigDlgForm.RefreshTimerTimer(Sender: TObject);
var
  AProps: TzToolActionProps;
begin
  FRefreshTimer.Enabled := False;

  PopulateSelectedActions;
  for AProps in FWorkActions do
    if AProps = FPendingFocus then
    begin
      FocusActionProps(AProps);
      Break;
    end;
  FPendingFocus := nil;
end;

// ── Filtri: menu di scelta rapida ─────────────────────────────────────────────

procedure TzToolConfigDlgForm.CreateFiltersMenu;
begin
  FFiltersMenu := TPopupMenu.Create(Self);
  FFiltersMenu.OnPopup := FiltersMenuPopup;

  FMenuAddFilter := TMenuItem.Create(FFiltersMenu);
  FMenuAddFilter.Caption := 'Aggiungi filtro';
  FMenuAddFilter.OnClick := FiltersMenuAddClick;
  FFiltersMenu.Items.Add(FMenuAddFilter);

  FMenuDeleteFilter := TMenuItem.Create(FFiltersMenu);
  FMenuDeleteFilter.Caption := 'Rimuovi filtro';
  FMenuDeleteFilter.OnClick := FiltersMenuDeleteClick;
  FFiltersMenu.Items.Add(FMenuDeleteFilter);

  tlFilters.PopupMenu := FFiltersMenu;
end;

procedure TzToolConfigDlgForm.FiltersMenuPopup(Sender: TObject);
begin
  FMenuAddFilter.Enabled := not FocusedFilterName.IsEmpty;
  FMenuDeleteFilter.Enabled := (SelectedFilterProps <> nil);
end;

procedure TzToolConfigDlgForm.FiltersMenuAddClick(Sender: TObject);
var
  FilterName: string;
begin
  FilterName := FocusedFilterName;
  if FilterName.IsEmpty then
    Exit;

  AddFilterInstance(FilterName);
end;

procedure TzToolConfigDlgForm.FiltersMenuDeleteClick(Sender: TObject);
var
  Props: TzToolFilterProps;
begin
  Props := SelectedFilterProps;
  if not Assigned(Props) then
    Exit;

  RemoveFilterInstance(Props);
end;

// ── Filtri: popolamento ───────────────────────────────────────────────────────

procedure TzToolConfigDlgForm.PopulateFilters;
var
  Names: TArray<string>;
  FilterName: string;
  Desc: string;
  ClassNode, InstNode: TcxTreeListNode;
  FProps: TzToolFilterProps;
  Instances: TArray<TzToolFilterProps>;
begin
  FUpdating := True;
  tlFilters.BeginUpdate;
  try
    tlFilters.Clear;

    Names := TzToolFilterRegistry.RegisteredNames;
    TArray.Sort<string>(Names, TStringComparer.Ordinal);

    for FilterName in Names do
    begin
      // ── livello 1: la classe registrata ─────────────────────────────────
      ClassNode := tlFilters.Add;
      ClassNode.Data := nil; // nodo classe: nessuna istanza associata

      // Descrizione dalla classe. I filtri generici (PickList, Boolean) non
      // sanno dire nulla a props vuote: DescribeClass restituisce '' e resta
      // il solo nome, che e' comunque leggibile (prima usciva 'Filtro ').
      Desc := TzToolFilterRegistry.DescribeClass(FilterName);
      if Desc.IsEmpty then
        ClassNode.Texts[tlFiltersColCaption.ItemIndex] := FilterName
      else
        ClassNode.Texts[tlFiltersColCaption.ItemIndex] := FilterName + '  -  ' + Desc;

      ClassNode.Texts[tlFiltersColName.ItemIndex] := FilterName;

      Instances := FWorkFilters.InstancesOf(FilterName);
      ClassNode.Values[tlFiltersColSelected.ItemIndex] := Length(Instances) > 0;

      // ── livello 2: le istanze configurate su questa view ────────────────
      for FProps in Instances do
      begin
        InstNode := ClassNode.AddChild;
        InstNode.Data := FProps;
        InstNode.Texts[tlFiltersColCaption.ItemIndex] := InstanceCaption(FProps);
        InstNode.Texts[tlFiltersColName.ItemIndex] := FProps.Name;
        InstNode.Values[tlFiltersColSelected.ItemIndex] := True;
      end;

      if Length(Instances) > 0 then
        ClassNode.Expand(False);
    end;
  finally
    tlFilters.EndUpdate;
    FUpdating := False;
  end;

  BindFilterInspector(SelectedFilterProps);
end;

function TzToolConfigDlgForm.InstanceCaption(Props: TzToolFilterProps): string;
var
  Campo: string;
begin
  if not Assigned(Props) then
    Exit('');

  Result := Props.EffectiveCaption;
  if Result.IsEmpty then
    Result := Props.EffectivePickListName;
  if Result.IsEmpty then
    Result := Props.Name;

  Campo := Props.EffectiveFieldName;
  if not Campo.IsEmpty then
    Result := Result + '   [' + Campo + ']'
  else
    Result := Result + '   [campo non impostato]';
end;

function TzToolConfigDlgForm.FocusedFilterName: string;
var
  Node: TcxTreeListNode;
begin
  Result := '';

  Node := tlFilters.FocusedNode;
  if not Assigned(Node) then
    Exit;

  if Assigned(Node.Data) then
    Result := TzToolFilterProps(Node.Data).EffectiveFilterName
  else
    Result := Node.Texts[tlFiltersColName.ItemIndex];
end;

function TzToolConfigDlgForm.SelectedFilterProps: TzToolFilterProps;
var
  Node: TcxTreeListNode;
begin
  Result := nil;

  Node := tlFilters.FocusedNode;
  if not Assigned(Node) then
    Exit;

  // Solo i nodi di livello 2 portano un prop: sul nodo classe non c'e' nulla
  // da ispezionare.
  if Assigned(Node.Data) then
    Result := TzToolFilterProps(Node.Data);
end;

procedure TzToolConfigDlgForm.BindFilterInspector(Props: TzToolFilterProps);
begin
  FUpdating := True;
  try
    inspFilters.Enabled := Assigned(Props);
    inspFilters.InspectedObject := Props;

    memParams.Enabled := Assigned(Props);
    if Assigned(Props) then
      memParams.Lines.Assign(Props.Params)
    else
      memParams.Lines.Clear;
  finally
    FUpdating := False;
  end;
end;

// ── Filtri: aggiunta e rimozione istanze ──────────────────────────────────────

function TzToolConfigDlgForm.AddFilterInstance(const AFilterName: string): TzToolFilterProps;
begin
  Result := FWorkFilters.AddInstance(AFilterName);
  PopulateFilters;
  SelectFilterInstance(Result);
end;

procedure TzToolConfigDlgForm.RemoveFilterInstance(Props: TzToolFilterProps);
begin
  if not Assigned(Props) then
    Exit;

  // L'ispettore punta al prop che stiamo per distruggere: va sganciato prima.
  BindFilterInspector(nil);

  Props.Free; // TCollectionItem.Free rimuove l'elemento dalla collezione

  PopulateFilters;
end;

procedure TzToolConfigDlgForm.RemoveAllFilterInstances(const AFilterName: string);
var
  Instances: TArray<TzToolFilterProps>;
  I: Integer;
begin
  Instances := FWorkFilters.InstancesOf(AFilterName);
  if Length(Instances) = 0 then
    Exit;

  BindFilterInspector(nil);

  for I := High(Instances) downto 0 do
    Instances[I].Free;

  PopulateFilters;
end;

procedure TzToolConfigDlgForm.SelectFilterInstance(Props: TzToolFilterProps);
var
  I: Integer;
  Node: TcxTreeListNode;
begin
  if not Assigned(Props) then
    Exit;

  for I := 0 to tlFilters.AbsoluteCount - 1 do
  begin
    Node := tlFilters.AbsoluteItems[I];
    if Node.Data = Pointer(Props) then
    begin
      Node.MakeVisible;
      Node.Focused := True;
      Node.Selected := True;
      Break;
    end;
  end;

  BindFilterInspector(SelectedFilterProps);
end;

// ── Filtri: eventi ────────────────────────────────────────────────────────────

procedure TzToolConfigDlgForm.tlFiltersSelectionChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;

  BindFilterInspector(SelectedFilterProps);
end;

procedure TzToolConfigDlgForm.tlFiltersEditValueChanged(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
var
  Node: TcxTreeListNode;
  FilterName: string;
  IsSel: Boolean;
  Props: TzToolFilterProps;
begin
  if FUpdating then
    Exit;

  if AColumn <> tlFiltersColSelected then
    Exit;

  Node := tlFilters.FocusedNode;
  if not Assigned(Node) then
    Exit;

  if VarIsNull(AColumn.EditValue) then
    IsSel := False
  else
    IsSel := AColumn.EditValue;

  // La colonna ha ImmediatePost = True: questo evento arriva mentre l'editor
  // in linea della casella e' ancora aperto sul nodo. Ricostruire l'albero
  // qui (PopulateFilters -> Clear) distruggerebbe il nodo in modifica sotto
  // i piedi dell'editor. Si raccoglie l'intenzione e si esegue al giro
  // successivo del ciclo messaggi, quando l'editor e' chiuso.
  Props := TzToolFilterProps(Node.Data);
  FilterName := Node.Texts[tlFiltersColName.ItemIndex];

  TThread.ForceQueue(nil,
    procedure
    begin
      if csDestroying in ComponentState then
        Exit;

      tlFilters.HideEdit;

      if Assigned(Props) then
      begin
        // nodo ISTANZA: la casella tolta rimuove questa sola istanza
        if not IsSel then
          RemoveFilterInstance(Props);
        Exit;
      end;

      // nodo CLASSE
      if FilterName.IsEmpty then
        Exit;

      if IsSel then
      begin
        // Spuntando la classe si crea la PRIMA istanza. Le successive si
        // aggiungono dal menu di scelta rapida.
        if Length(FWorkFilters.InstancesOf(FilterName)) = 0 then
          AddFilterInstance(FilterName)
        else
          PopulateFilters; // gia' configurata: si riallinea e basta
      end
      else
        RemoveAllFilterInstances(FilterName);
    end);
end;

procedure TzToolConfigDlgForm.memParamsExit(Sender: TObject);
var
  Props: TzToolFilterProps;
begin
  if FUpdating then
    Exit;

  Props := SelectedFilterProps;
  if not Assigned(Props) then
    Exit;

  Props.Params.Assign(memParams.Lines);
end;

// ── Azioni: eventi ────────────────────────────────────────────────────────────

procedure TzToolConfigDlgForm.tlSelectedSelectionChanged(Sender: TObject);
var
  AProps: TzToolActionProps;
  I: Integer;
  Node, Target: TcxTreeListNode;
  Action: TCustomAction;
begin
  BindActionInspector(SelectedActionProps);

  // Con piu' righe selezionate non si sposta il fuoco su tlAvailable:
  // interromperebbe la selezione multipla
  if FUpdating or (tlSelected.SelectionCount > 1) then
    Exit;

  AProps := SelectedActionProps;
  if not Assigned(AProps) then
    Exit;

  Target := nil;
  for I := 0 to tlAvailable.AbsoluteCount - 1 do
  begin
    Node := tlAvailable.AbsoluteItems[I];
    if Assigned(Node.Data) then
    begin
      Action := TCustomAction(Node.Data);
      if SameText(Action.Name, AProps.Name) then
      begin
        Target := Node;
        Break;
      end;
    end;
  end;

  if not Assigned(Target) then
    Exit;

  FUpdating := True;
  try
    Target.MakeVisible; // espande i genitori se necessario
    Target.Focused := True;
    Target.Selected := True;
    tlAvailable.SetFocus; // opzionale: porta il focus al treelist
  finally
    FUpdating := False;
  end;
end;

procedure TzToolConfigDlgForm.tlAvailableEditValueChanged(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
var
  Node: TcxTreeListNode;
  Action: TCustomAction;
  AProps: TzToolActionProps;
  IsSel: Boolean;
begin
  if FUpdating then
    Exit;

  if AColumn <> tlAvailableColSelected then
    Exit;

  Node := tlAvailable.FocusedNode;
  if not Assigned(Node) or not Assigned(Node.Data) then
    Exit;

  Action := TCustomAction(Node.Data);

  if VarIsNull(AColumn.EditValue) then
    IsSel := False
  else
    IsSel := AColumn.EditValue;

  if IsSel then
  begin
    if not FWorkActions.Exists(Action.Name) then
      FWorkActions.Add.Name := Action.Name;
  end
  else
  begin
    AProps := FindActionProps(Action.Name);
    if Assigned(AProps) then
      AProps.Free;
  end;

  PopulateSelectedActions;
end;

// ── Commit ────────────────────────────────────────────────────────────────────

procedure TzToolConfigDlgForm.Commit;
begin

  if Assigned(FConfig.Props) then
  begin
    FConfig.Props.ToolActions.ClearFromCode;
    FConfig.Props.ToolActions.Assign(FWorkActions);
  end;

  FConfig.SetActionOwnerName(FWorkOwnerName);
  FConfig.RebuildActions;

  if Assigned(FFilterable) then
  begin
    FFilterable.ToolFilters.ClearFromCode;
    FFilterable.ToolFilters.Assign(FWorkFilters);
    FFilterable.RebuildFilters;
  end;
end;

end.
