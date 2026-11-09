// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-02
// ---------------------------------------------------------------------------
unit zDbTree;

// TzDbTree: albero dati (TcxDBTreeList) su un dataset autoreferenziato, cioe'
// con una chiave e un campo che punta al record padre. Quinto componente dati
// del dizionario LZ accanto a TzDbView, TzDbCard, TzDbPivot e TzDbRecordView.
//
// Le colonne nascono da TzDbTreeProps (collezione LZ zDbTrees), che
// ValidateDataset allinea ai campi del dataset: senza configurazione l'albero
// mostra tutti i campi visibili tranne quelli di servizio, la chiave e il padre.
//
// Analisi e prove: OUT\20261001-componentizzazione-controlli-devexpress\
//   Analisi - 20261001 - Componente TzDbTree da TcxDBTreeList.md
//   Fase 0 - 20261001 - Prove TzDbTree.md
//
// Scelte che vengono dalle prove della fase 0:
// - finche' il dataset e' legato all'albero, TzFbDataSet.UseSqlLocate resta
//   spento e si rimette com'era quando il legame cade. Il Locate via SQL
//   riscrive la WHERE e lascia nel dataset il solo record cercato: con
//   SyncMode (P12) e con il trascinamento (P35) l'albero si svuotava, e lo
//   stesso succederebbe al Locate di qualunque altro componente sullo stesso
//   dataset. Un albero ha comunque bisogno di tutti i record in memoria;
// - SmartLoad sempre spento: con il dataset non ordinato per padre le radici
//   successive alla prima si perdono (P15);
// - chiave o padre inesistenti danno un albero vuoto senza errori (P04, P05):
//   i due campi si verificano all'apertura e l'amministratore viene avvisato;
// - l'esportazione completa richiede AExpand, che apre i nodi a video (P50):
//   l'espansione si salva prima e si rimette dopo;
// - chiusura e riapertura del dataset (filtri, Aggiorna) azzerano l'espansione
//   (P20): i rami aperti si tengono in un elenco di chiavi aggiornato dagli
//   eventi di espansione e si riaprono a dati ricaricati;
// - i cicli nel trascinamento li scarta gia' il controllo (P31); OnNodeMove
//   permette alla form di vietare uno spostamento prima di ogni scrittura (P34);
// - il layout su file ini di DevExpress ripristina le colonne solo se hanno un
//   nome (P25, P26): ogni colonna si chiama col<campo>.
//
// Come in TzDbView: larghezze adattate al contenuto (azione, clic
// sull'angolo dell'indicatore, colonne tutte strette all'apertura), menu di
// DevExpress sulle intestazioni senza le voci governate dalle props (pie' di
// pagina = Flags.Footer), colonne di tipo collegamento (ctHyperLink) che
// aprono la form registrata per il campo con zSystem.HyperLink.

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  System.Generics.Collections,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.ImgList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxStyles,
  cxClasses,
  cxLabel,
  cxTextEdit,
  cxImageList,
  cxBarEditItem,
  cxCustomData,
  cxInplaceContainer,
  cxTL,
  cxTLData,
  cxDBTL,
  dxCore,
  dxBar,
  dxBarExtItems,
  dxFileActions,
  dxFramedControl,
  dxPanel,
  ActionListController,
  zFocusedAction,
  zFbDataSet,
  zBaseLib,
  zBase.Types,
  zSystem,
  zToolActions,
  zToolFilter,
  zToolFilterHelper,
  zDataController,
  zDescription,
  zDbCardDlg,
  zDbLookupEditors, cxFilter, dxScrollbarAnnotations, cxTLdxBarBuiltInMenu,
  cxGeometry, Vcl.StdActns;

type
  TzDbTreeCommand = (tcUpdateActions, tcDisplayToolbars, tcSaveZip, tcApplyTitle, tcAfterOpen, tcWarnHierarchy, tcHyperLink);

  // Come TzDbRecordViewReadOnly: le props decidono, il codice della form puo' forzare
  TzDbTreeReadOnly = (troUseLoadedProps, troForceReadOnly, troForceWriteable);

  // Prima dello spostamento di un nodo trascinato: Allow := False lo annulla
  // senza nessuna scrittura sul dataset. NewParentKey e' Null per la radice
  TzTreeNodeMoveEvent = procedure(Sender: TObject; const NodeKey, NewParentKey: Variant; var Allow: Boolean) of object;

  // Per ogni colonna creata, a costruzione completa: editor particolari, riepiloghi
  TzTreeColumnCreatedEvent = procedure(Sender: TObject; Column: TcxDBTreeListColumn; Item: TzTreeColumn; Field: TField) of object;

  // Le azioni del .dfm sono TzFocusedAction: con il fuoco nell'albero le
  // scorciatoie restano all'albero e non passano alle altre della stessa form
  TzDbTree = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzShortCutConsumer)
    ActionList: TActionList;
    DataSource: TDataSource;
    Titolo: TcxLabel;
    cxDBTreeList: TcxDBTreeList;
    pnlDescrizione: TdxPanel;
    dxBarManager: TdxBarManager;
    dxBarToolbar: TdxBar;
    dxBarToolbarFree: TdxBar;
    popTree: TdxBarPopupMenu;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
    dxBarEditTitolo: TcxBarEditItem;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    // Navigazione fra i nodi
    actDbFirst: TzFocusedAction;
    actDbPrior: TzFocusedAction;
    actDbNext: TzFocusedAction;
    actDbLast: TzFocusedAction;
    actVaiAlPadre: TzFocusedAction;
    actDbRefresh: TzFocusedAction;
    // Modifica dei record
    actDbInsert: TzFocusedAction;
    actInserisciFiglio: TzFocusedAction;
    actInserisciRadice: TzFocusedAction;
    actDbEdit: TzFocusedAction;
    actDbDelete: TzFocusedAction;
    actDbPost: TzFocusedAction;
    actDbCancel: TzFocusedAction;
    // Vista
    actTrova: TzFocusedAction;
    Espandi: TzFocusedAction;
    Riduci: TzFocusedAction;
    actEspandiRamo: TzFocusedAction;
    actRiduciRamo: TzFocusedAction;
    AdattaLarghezze: TzFocusedAction;
    Elabora: TzFocusedAction;
    actExcel: TdxFileSaveAs;
    actStampa: TzFocusedAction;
    Descrizione: TzFocusedAction;
    RipristinaLayout: TzFocusedAction;
    // Amministrazione
    actPersonalizza: TzFocusedAction;
    actPersonalizzaColonne: TzFocusedAction;
    actPersonalizzaCampo: TzFocusedAction;
    actResetColonne: TzFocusedAction;
    SalvaImpostazioni: TzFocusedAction;
    CaricaImpostazioni: TzFocusedAction;
    actSQL: TzFocusedAction;
    MostraQueryUtilizzata: TzFocusedAction;
    CopiaQueryUtilizzata: TzFocusedAction;
    CopyName: TzFocusedAction;
    NomeFileIni: TzFocusedAction;
    EditTools: TzFocusedAction;
    // Pulsanti della barra e dei menu
    dxBarButtonactDbFirst: TdxBarButton;
    dxBarButtonactDbPrior: TdxBarButton;
    dxBarButtonactDbNext: TdxBarButton;
    dxBarButtonactDbLast: TdxBarButton;
    dxBarButtonactVaiAlPadre: TdxBarButton;
    dxBarButtonactDbRefresh: TdxBarButton;
    dxBarButtonactDbInsert: TdxBarButton;
    dxBarButtonactInserisciFiglio: TdxBarButton;
    dxBarButtonactInserisciRadice: TdxBarButton;
    dxBarButtonactDbEdit: TdxBarButton;
    dxBarButtonactDbDelete: TdxBarButton;
    dxBarButtonactDbPost: TdxBarButton;
    dxBarButtonactDbCancel: TdxBarButton;
    dxBarButtonactTrova: TdxBarButton;
    dxBarButtonEspandi: TdxBarButton;
    dxBarButtonRiduci: TdxBarButton;
    dxBarButtonactEspandiRamo: TdxBarButton;
    dxBarButtonactRiduciRamo: TdxBarButton;
    dxBarButtonAdattaLarghezze: TdxBarButton;
    dxBarButtonElabora: TdxBarButton;
    dxBarButtonactExcel: TdxBarButton;
    dxBarButtonactStampa: TdxBarButton;
    dxBarButtonDescrizione: TdxBarButton;
    dxBarButtonRipristinaLayout: TdxBarButton;
    dxBarButtonactPersonalizza: TdxBarButton;
    dxBarButtonactPersonalizzaColonne: TdxBarButton;
    dxBarButtonactPersonalizzaCampo: TdxBarButton;
    dxBarButtonactResetColonne: TdxBarButton;
    dxBarButtonSalvaImpostazioni: TdxBarButton;
    dxBarButtonCaricaImpostazioni: TdxBarButton;
    dxBarButtonactSQL: TdxBarButton;
    dxBarButtonMostraQueryUtilizzata: TdxBarButton;
    dxBarButtonCopiaQueryUtilizzata: TdxBarButton;
    dxBarButtonCopyName: TdxBarButton;
    dxBarButtonNomeFileIni: TdxBarButton;
    dxBarButtonEditTools: TdxBarButton;
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    procedure DataSourceStateChange(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actDbFirstExecute(Sender: TObject);
    procedure actDbPriorExecute(Sender: TObject);
    procedure actDbNextExecute(Sender: TObject);
    procedure actDbLastExecute(Sender: TObject);
    procedure actVaiAlPadreExecute(Sender: TObject);
    procedure actDbRefreshExecute(Sender: TObject);
    procedure actDbInsertExecute(Sender: TObject);
    procedure actInserisciFiglioExecute(Sender: TObject);
    procedure actInserisciRadiceExecute(Sender: TObject);
    procedure actDbEditExecute(Sender: TObject);
    procedure actDbDeleteExecute(Sender: TObject);
    procedure actDbPostExecute(Sender: TObject);
    procedure actDbCancelExecute(Sender: TObject);
    procedure actTrovaExecute(Sender: TObject);
    procedure EspandiExecute(Sender: TObject);
    procedure RiduciExecute(Sender: TObject);
    procedure actEspandiRamoExecute(Sender: TObject);
    procedure actRiduciRamoExecute(Sender: TObject);
    procedure AdattaLarghezzeExecute(Sender: TObject);
    procedure ElaboraExecute(Sender: TObject);
    procedure actExcelBeforeExecute(Sender: TObject);
    procedure actExcelAccept(Sender: TObject);
    procedure actStampaExecute(Sender: TObject);
    procedure DescrizioneExecute(Sender: TObject);
    procedure RipristinaLayoutExecute(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure actPersonalizzaColonneExecute(Sender: TObject);
    procedure actPersonalizzaCampoExecute(Sender: TObject);
    procedure actResetColonneExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure CaricaImpostazioniExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure MostraQueryUtilizzataExecute(Sender: TObject);
    procedure CopiaQueryUtilizzataExecute(Sender: TObject);
    procedure CopyNameExecute(Sender: TObject);
    procedure NomeFileIniExecute(Sender: TObject);
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
    procedure dxBarEditTitoloChange(Sender: TObject);
    procedure dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
    procedure PopupTreePopup(Sender: TObject);
  private
    FzDataSet: TzFbDataSet;
    FzSystem: TzSystem;
    FDataController: TzDataController;
    FzDbTreeProps: TzDbTreeProps;
    FToolActions: TzToolActions;
    ActionListController: TActionListController;
    FrameDescription: TFrameDescription;
    FReadOnly: TzDbTreeReadOnly;
    FRestrictionReadOnly: Boolean;
    FBuilt: Boolean;
    FLoadingProps: Boolean;
    FIsDestroying: Boolean;
    FSaveZipQueued: Boolean;
    // UseSqlLocate del dataset prima del legame, da rimettere quando cade
    FSqlLocateTaken: Boolean;
    FSavedUseSqlLocate: Boolean;
    // campi effettivi della gerarchia (props oppure convenzione)
    FKeyFieldName: string;
    FParentFieldName: string;
    FHierarchyOk: Boolean;
    FHierarchyWarned: Boolean;
    // rami aperti (chiave come testo) e nodo con il fuoco, per riaprire
    // l'albero dopo una chiusura del dataset
    // la chiave resta un Variant: FindNodeByKeyValue confronta con il tipo del campo
    FExpandedKeys: TDictionary<string, Variant>;
    FFocusedKey: Variant;
    FTrackExpansion: Boolean;
    FLastState: TDataSetState;
    FStateRestored: Boolean;
    AlreadyShown: Boolean;
    // True da LoadUserLayout finche' le colonne non sono state allargate al
    // contenuto (serve almeno un nodo da misurare)
    FAdattaLarghezzeInAttesa: Boolean;
    // collegamento cliccato, aperto in differita come in TzDbView
    FHyperLinkFieldName: string;
    FHyperLinkValue: Variant;
    FOnShowCard: TzShowCardEvent;
    // scheda di inserimento e modifica, creata al primo uso (solo in esecuzione)
    FCardDlg: TzDbCardDlg;
    FCardID: string;
    FShowingCard: Boolean;
    // padre del nodo da inserire, per la scheda della form (OnShowCard)
    FInsertParentKey: Variant;
    // lookup del dizionario negli editor delle celle
    FLookupEditors: TzLookupEditors;
  private
    FOnUpdateActions: TNotifyEvent;
    FOnBeforeCreateControls: TNotifyEvent;
    FOnAfterCreateControls: TNotifyEvent;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    FOnDataSetInsert: TNotifyEvent;
    FOnDataSetEdit: TNotifyEvent;
    FOnDataSetDelete: TNotifyEvent;
    FOnNodeChanged: TNotifyEvent;
    FOnNodeMove: TzTreeNodeMoveEvent;
    FOnColumnCreated: TzTreeColumnCreatedEvent;
  private // IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
    function GetComponentType: TzComponentType;
    function GetID: string;
    procedure SetID(const Value: string);
    function GetToolActions: TzToolActions;
    procedure SetToolActions(const Value: TzToolActions);
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    function ConfigTitle: string;
    procedure RebuildToolbar;
    function GetProps: TzBaseComponentProps;
    function GetToolbar: TdxBar;
    function GetzDataSet: TzFbDataSet;
    procedure SetzDataSet(const Value: TzFbDataSet);
    function GetToolFilters: TzToolFiltersProps;
    procedure SetToolFilters(const Value: TzToolFiltersProps);
    procedure RebuildFilters;
  private
    function GetTreeID: string;
    procedure SetTreeID(const Value: string);
    function GetFlags: TzDbTreeFlags;
    function GetNodeImages: TCustomImageList;
    procedure SetNodeImages(const Value: TCustomImageList);
    procedure SetReadOnly(const Value: TzDbTreeReadOnly);
    procedure SetRestrictionReadOnly(const Value: Boolean);
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: Boolean;
    function IsAdmin: Boolean;
    function DbNode(Node: TcxTreeListNode): TcxDBTreeListNode;
    function NodeKeyText(Node: TcxTreeListNode): string;
    function KeyFromText(const Text: string): Variant;
  private
    procedure TakeSqlLocate;
    procedure ReleaseSqlLocate;
    procedure ResolveHierarchyFields;
    procedure InitTree;
    procedure LoadProperties(const LoadDefaults: Boolean);
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
    procedure doSalvaImpostazioni(const Silent: Boolean = False);
    procedure ApplyTreeOptions;
    procedure CreateFiltersFromProps;
    procedure DisplayToolbars;
    procedure UpdateActions;
    procedure UpdateExpandCaptions;
    procedure OnFlagChange(Sender: TObject);
    procedure ToolActionsChanged(Sender: TObject);
    procedure AssignColumnsToProps;
    procedure AfterOpen;
    procedure ApplyExpandMode;
    procedure ApplyExpandedKeys;
    procedure InsertWithParent(const ParentKey: Variant);
    function ColumnComponentName(const FieldName: string): string;
  private // layout personale
    function LayoutFileName: string;
    function StateFileName: string;
    procedure LoadUserLayout;
    procedure SaveUserLayout;
    procedure LoadExpansionState;
    procedure SaveExpansionState;
  private // descrizione
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private // eventi dell'albero, assegnati nel costruttore
    procedure TreeFocusedNodeChanged(Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    procedure TreeExpanded(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
    procedure TreeCollapsed(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
    procedure TreeMoveTo(Sender: TcxCustomTreeList; AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode; Nodes: TList;
      var IsCopy, Done: Boolean);
    procedure TreeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TreeDblClick(Sender: TObject);
    procedure HeaderMenuClick(Sender: TcxCustomTreeList; AItem: TObject; var AHandled: Boolean);
    procedure DoHyperLink(Sender: TObject);
    procedure OpenHyperLink(Column: TcxTreeListColumn; Node: TcxTreeListNode);
    procedure CheckColumnWidths;
  private // scheda (TzDbCardDlg o OnShowCard), come in TzDbView
    function UsesCard: Boolean;
    function GetCardDlg: TzDbCardDlg;
    function EffectiveCardID: string;
    function ShowCard(const Inserting: Boolean): Boolean;
    function LocateFocusedNode: Boolean;
    procedure InsertNode(const ParentKey: Variant);
    procedure SetOnShowCard(const Value: TzShowCardEvent);
  private
    procedure PostInternalMessage(const Command: TzDbTreeCommand);
    procedure ExecuteCommand(const Command: TzDbTreeCommand);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBTREE;
  protected
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateDataSet;
    // Riallinea le props al dataset e ricrea le colonne
    procedure RebuildColumns;
    // Rilegge le props dal dizionario e ricrea l'albero
    procedure ReloadProps;

    // Espansione
    procedure ExpandAll;
    procedure CollapseAll;
    // Apre i nodi fino al livello indicato (0 = solo le radici visibili)
    procedure ExpandToLevel(const Level: Integer);
    procedure ExpandBranch;
    procedure CollapseBranch;
    // Rami aperti e nodo con il fuoco, per chi ricarica il dataset da codice
    procedure CaptureExpansion;
    procedure RestoreExpansion;

    // Nodi e chiavi
    function FocusedKey: Variant;
    function FocusedParentKey: Variant;
    function FocusKey(const Key: Variant): Boolean;
    function GetSelectedKeys: TArray<Variant>;
    function NodeByKey(const Key: Variant): TcxDBTreeListNode;
    function ChildCount(const Key: Variant): Integer;

    // Colonne
    // Larghezza delle colonne visibili adattata al contenuto dei nodi aperti
    procedure ApplyBestFit;
    function ColumnByField(const FieldName: string): TcxDBTreeListColumn;
    procedure ShowField(const FieldName: string);
    procedure HideField(const FieldName: string);

    // Modifica dei record
    function IsTreeReadOnly: Boolean;
    procedure InsertChild(const ParentKey: Variant);
    procedure InsertRoot;
    procedure InsertSibling;
    procedure Post;
    procedure Cancel;
    // Scheda del record (OnShowCard o TzDbCardDlg); doInsert inserisce prima un
    // nodo allo stesso livello di quello con il fuoco, come TzDbView.ShowRecord
    function ShowRecord(const doInsert: Boolean): Boolean;

    // Uscite
    procedure ExportToFile(const FileName: string);
    procedure Preview;

    function GetTitle: string;
    procedure SetTitle(const Title: string);

    procedure InitToolActions;
    procedure ExecuteToolConfig;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
  public
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property DataController: TzDataController read FDataController;
    property Tree: TcxDBTreeList read cxDBTreeList;
    property TreeID: string read GetTreeID write SetTreeID;
    property Flags: TzDbTreeFlags read GetFlags;
    property zDbTreeProps: TzDbTreeProps read FzDbTreeProps;
    property ReadOnly: TzDbTreeReadOnly read FReadOnly write SetReadOnly;
    // Sola lettura imposta dai permessi sul dataset (livello di accesso)
    property RestrictionReadOnly: Boolean read FRestrictionReadOnly write SetRestrictionReadOnly;
    // Campi della gerarchia effettivamente usati (props o convenzione)
    property KeyFieldName: string read FKeyFieldName;
    property ParentFieldName: string read FParentFieldName;
    // Immagini dei nodi, indicizzate da ImageIndexFieldName delle props
    property NodeImages: TCustomImageList read GetNodeImages write SetNodeImages;
    // Scheda usata da TzDbCardDlg; vuoto = quella del dataset (Modulo.DataSet)
    property CardID: string read FCardID write FCardID;
    // Dialogo della scheda, per agganciarne gli eventi da codice
    property CardDlg: TzDbCardDlg read GetCardDlg;
    // Padre del nodo nuovo quando la scheda e' della form (OnShowCard con
    // Inserting): Null per la radice
    property InsertParentKey: Variant read FInsertParentKey;
  published
    property OnUpdateActions: TNotifyEvent read FOnUpdateActions write FOnUpdateActions;
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write FOnBeforeCreateControls;
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write FOnAfterCreateControls;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write FOnCustomLoadProps;
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write FOnCustomSaveProps;
    // Se assegnati sostituiscono il comportamento predefinito (come in TzDbCard)
    property OnDataSetInsert: TNotifyEvent read FOnDataSetInsert write FOnDataSetInsert;
    property OnDataSetEdit: TNotifyEvent read FOnDataSetEdit write FOnDataSetEdit;
    property OnDataSetDelete: TNotifyEvent read FOnDataSetDelete write FOnDataSetDelete;
    // Se assegnato la scheda la apre la form, al posto di TzDbCardDlg
    property OnShowCard: TzShowCardEvent read FOnShowCard write SetOnShowCard;
    // Al cambio del nodo con il fuoco
    property OnNodeChanged: TNotifyEvent read FOnNodeChanged write FOnNodeChanged;
    property OnNodeMove: TzTreeNodeMoveEvent read FOnNodeMove write FOnNodeMove;
    property OnColumnCreated: TzTreeColumnCreatedEvent read FOnColumnCreated write FOnColumnCreated;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  end;

implementation

uses
  System.IniFiles,
  System.Math,
  System.Generics.Defaults,
  Winapi.ShellAPI,
  Vcl.Clipbrd,
  cxTLExportLink,
  dxPSCore,
  dxPScxTLLnk,
  cxHyperLinkEdit,
  zDX,
  zMsg,
  zFrmParams,
  zToolConfigDlg,
  zToolFilter.Builder;

{$R *.dfm}

const
  SEliminoIlRecord = 'Elimino il record?';
  SEliminoConFigli = 'Il nodo ha %d sottonodi: eliminandolo saliranno alla radice.' + sLineBreak + 'Elimino il record?';
  SSezioneStato = 'Stato';

{ TzDbTree }

constructor TzDbTree.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FzDataSet := nil;
  FzSystem := nil;
  FrameDescription := nil;
  FReadOnly := troUseLoadedProps;
  FRestrictionReadOnly := False;
  FBuilt := False;
  FLoadingProps := False;
  FIsDestroying := False;
  FAdattaLarghezzeInAttesa := False;
  FSaveZipQueued := False;
  FSqlLocateTaken := False;
  FSavedUseSqlLocate := True;
  FKeyFieldName := '';
  FParentFieldName := '';
  FHierarchyOk := False;
  FHierarchyWarned := False;
  FExpandedKeys := TDictionary<string, Variant>.Create;
  FFocusedKey := Null;
  FTrackExpansion := True;
  FLastState := dsInactive;
  FStateRestored := False;
  AlreadyShown := False;
  FHyperLinkFieldName := '';
  FHyperLinkValue := Null;

  FzDbTreeProps := TzDbTreeProps.Create(nil);
  FzDbTreeProps.Flags.OnChange := OnFlagChange;

  FDataController := TzDataController.Create(Self);

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;

  ActionListController := TActionListController.Create;

  Titolo.Visible := False;
  Titolo.PopupMenu := popTree;
  dxBarControlContainerTitolo.Visible := dx.Visible(False);
  dxBarToolbar.MultiLine := True;
  dxBarToolbarFree.MultiLine := True;
  dx.InitTitle(Titolo);
  dx.InitTreeList(cxDBTreeList);

  // Vedi l'intestazione della unit
  cxDBTreeList.OptionsData.SmartLoad := False;
  cxDBTreeList.OptionsData.Inserting := False;
  cxDBTreeList.OptionsData.Deleting := False;
  cxDBTreeList.OptionsData.CancelOnExit := False;

  cxDBTreeList.OnFocusedNodeChanged := TreeFocusedNodeChanged;
  cxDBTreeList.OnExpanded := TreeExpanded;
  cxDBTreeList.OnCollapsed := TreeCollapsed;
  cxDBTreeList.OnMoveTo := TreeMoveTo;
  cxDBTreeList.OnDragOver := TreeDragOver;
  cxDBTreeList.OnKeyDown := TreeKeyDown;
  cxDBTreeList.OnMouseDown := TreeMouseDown;
  cxDBTreeList.OnDblClick := TreeDblClick;

  FOnShowCard := nil;
  FCardDlg := nil;
  FCardID := '';
  FShowingCard := False;
  FInsertParentKey := Null;

  // oggetto semplice, non un componente: nessun rischio di finire nel .dfm
  FLookupEditors := TzLookupEditors.Create(
    function: TzSystem
    begin
      result := FzSystem;
    end,
    function: TzFbDataSet
    begin
      result := FzDataSet;
    end,
    function: string
    begin
      result := '';
      if cxDBTreeList.FocusedColumn is TcxDBTreeListColumn then
        result := TcxDBTreeListColumn(cxDBTreeList.FocusedColumn).DataBinding.FieldName;
    end);

  // Menu delle intestazioni di DevExpress, come TcxGridStdHeaderMenu in
  // TzDbView: tolte le voci del pie' di pagina, che decide Flags.Footer
  cxDBTreeList.PopupMenus.ColumnHeaderMenu.UseBuiltInMenu := True;
  cxDBTreeList.PopupMenus.ColumnHeaderMenu.Items := [tlchmiSortAscending, tlchmiSortDescending, tlchmiClearSorting, tlchmiRemoveThisColumn,
    tlchmiFieldChooser, tlchmiHorzAlignment, tlchmiVertAlignment, tlchmiBestFit, tlchmiBestFitAllColumns];
  cxDBTreeList.PopupMenus.ColumnHeaderMenu.OnClick := HeaderMenuClick;

  UpdateActions;
end;

destructor TzDbTree.Destroy;
begin
  FIsDestroying := True;

  if FBuilt and not(csDesigning in ComponentState) then
  begin
    SaveUserLayout;

    // a dataset chiuso l'albero e' vuoto: lo stato e' gia' quello raccolto
    // dagli eventi di espansione
    if FzDbTreeProps.Flags.ExpandMode = temRestore then
      SaveExpansionState;
  end;

  // scrittura dello zip rimasta in coda: il messaggio postato non verra' recapitato
  if FSaveZipQueued then
  begin
    FSaveZipQueued := False;
    if zSystemOk then
      zSystem.SaveZip(csDbTrees, 'TzDbTree.Destroy');
  end;

  ReleaseSqlLocate;

  // gli editor dei lookup si sganciano finche' le colonne esistono ancora
  if Assigned(FLookupEditors) then
    FLookupEditors.Clear;
  FreeAndNil(FLookupEditors);

  FreeAndNil(FrameDescription);
  FreeAndNil(ActionListController);
  FreeAndNil(FToolActions);
  FreeAndNil(FExpandedKeys);
  FreeAndNil(FDataController);
  FreeAndNil(FzDbTreeProps);
  inherited;
end;

procedure TzDbTree.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation <> opRemove then
    Exit;

  if AComponent = FzSystem then
    FzSystem := nil;

  if AComponent = FzDataSet then
  begin
    // il dataset se ne va: non c'e' piu' niente da rimettere
    FSqlLocateTaken := False;
    FzDataSet := nil;
    if Assigned(FDataController) then
      FDataController.DataSet := nil;
  end;

  if (AComponent is TAction) or (AComponent is TImageList) then
    if Assigned(FToolActions) then
      FToolActions.RemoveNotification(AComponent);
end;

procedure TzDbTree.CMShowingChanged(var M: TMessage);
begin
  inherited;
  AlreadyShown := True;

  if Showing then
    CheckColumnWidths;

  PostInternalMessage(tcDisplayToolbars);
end;

procedure TzDbTree.PostInternalMessage(const Command: TzDbTreeCommand);
begin
  if FIsDestroying or (csDestroying in ComponentState) then
    Exit;

  // Handle crea la finestra, e un frame senza genitore (creato dal
  // FormController e non ancora messo nel layout) solleverebbe "Control has
  // no parent window": in quel caso il comando si esegue subito
  if HandleAllocated or Assigned(Parent) then
    PostMessage(Self.Handle, ZZ_DBTREE, NativeUInt(Command), 0)
  else
    ExecuteCommand(Command);
end;

procedure TzDbTree.MessageHandler(var Message: TMessage);
begin
  ExecuteCommand(TzDbTreeCommand(Message.WParam));
end;

procedure TzDbTree.ExecuteCommand(const Command: TzDbTreeCommand);
begin
  if FIsDestroying then
    Exit;

  case Command of
    tcUpdateActions:
      UpdateActions;
    tcDisplayToolbars:
      DisplayToolbars;
    tcApplyTitle:
      SetTitle(FzDbTreeProps.Title);
    tcAfterOpen:
      AfterOpen;
    tcHyperLink:
      if zSystemOk then
        zSystem.HyperLink(Self, FHyperLinkFieldName, FHyperLinkValue);
    tcWarnHierarchy:
      if IsAdmin and not FHierarchyWarned then
      begin
        FHierarchyWarned := True;
        ConfirmOk(Format('Albero %s: chiave "%s" o padre "%s" assenti nel dataset.' + sLineBreak +
          'L''albero resta vuoto: indicare KeyFieldName e ParentFieldName in Personalizza.', [TreeID, FKeyFieldName, FParentFieldName]));
      end;
    tcSaveZip:
      begin
        FSaveZipQueued := False;
        if zSystemOk then
          zSystem.SaveZip(csDbTrees, 'TzDbTree.SalvaImpostazioni');
      end;
  end;
end;

// ---------------------------------------------------------------------------
// IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
// ---------------------------------------------------------------------------

function TzDbTree.GetComponentType: TzComponentType;
begin
  result := ctTree;
end;

function TzDbTree.GetID: string;
begin
  result := TreeID;
end;

procedure TzDbTree.SetID(const Value: string);
begin
  TreeID := Value;
end;

function TzDbTree.GetToolActions: TzToolActions;
begin
  result := FToolActions;
end;

procedure TzDbTree.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

function TzDbTree.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, FzDbTreeProps.ActionOwnerName);
end;

function TzDbTree.GetActionOwnerName: string;
begin
  result := FzDbTreeProps.ActionOwnerName;
end;

procedure TzDbTree.SetActionOwnerName(const Value: string);
begin
  FzDbTreeProps.ActionOwnerName := Value;
end;

procedure TzDbTree.RebuildActions;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

procedure TzDbTree.RebuildFilters;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

function TzDbTree.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := TreeID;
end;

procedure TzDbTree.RebuildToolbar;
begin
  // Prima i filtri, poi le azioni: i filtri precedono le azioni sulla barra
  CreateFiltersFromProps;
  InitToolActions;
end;

function TzDbTree.GetProps: TzBaseComponentProps;
begin
  result := FzDbTreeProps;
end;

function TzDbTree.GetToolbar: TdxBar;
begin
  result := dxBarToolbarFree;
end;

function TzDbTree.GetzDataSet: TzFbDataSet;
begin
  result := FzDataSet;
end;

procedure TzDbTree.SetzDataSet(const Value: TzFbDataSet);
begin
  if FzDataSet = Value then
    Exit;

  ReleaseSqlLocate;

  if Assigned(FzDataSet) then
    FzDataSet.RemoveFreeNotification(Self);

  FzDataSet := Value;

  if Assigned(FzDataSet) then
    FzDataSet.FreeNotification(Self);

  FDataController.DataSet := Value;
  DataSource.DataSet := nil;
  FExpandedKeys.Clear;
  FFocusedKey := Null;
  FStateRestored := False;

  // dataset diverso: l'albero va ricostruito da capo
  FBuilt := False;
  InitTree;
end;

function TzDbTree.GetToolFilters: TzToolFiltersProps;
begin
  result := FzDbTreeProps.ToolFilters;
end;

procedure TzDbTree.SetToolFilters(const Value: TzToolFiltersProps);
begin
  FzDbTreeProps.ToolFilters.Assign(Value);
end;

// ---------------------------------------------------------------------------
// Proprieta'
// ---------------------------------------------------------------------------

function TzDbTree.GetTreeID: string;
begin
  if (FzDbTreeProps.Name = '') and FDataController.DataSetOk then
    FzDbTreeProps.Name := FDataController.IdDataSet;

  result := FzDbTreeProps.Name;
end;

procedure TzDbTree.SetTreeID(const Value: string);
begin
  FzDbTreeProps.Name := Value;
end;

function TzDbTree.GetFlags: TzDbTreeFlags;
begin
  result := FzDbTreeProps.Flags;
end;

function TzDbTree.GetNodeImages: TCustomImageList;
begin
  result := cxDBTreeList.Images;
end;

procedure TzDbTree.SetNodeImages(const Value: TCustomImageList);
begin
  cxDBTreeList.Images := Value;
end;

procedure TzDbTree.SetReadOnly(const Value: TzDbTreeReadOnly);
begin
  if FReadOnly = Value then
    Exit;

  FReadOnly := Value;
  FDataController.ReadOnly := IsTreeReadOnly;

  if FBuilt then
  begin
    ApplyTreeOptions;
    RebuildColumns;
  end;

  UpdateActions;
end;

procedure TzDbTree.SetRestrictionReadOnly(const Value: Boolean);
begin
  if FRestrictionReadOnly = Value then
    Exit;

  FRestrictionReadOnly := Value;
  FDataController.ReadOnly := IsTreeReadOnly;

  if FBuilt then
  begin
    ApplyTreeOptions;
    RebuildColumns;
  end;

  UpdateActions;
end;

procedure TzDbTree.SetzSystem(const Value: TzSystem);
begin
  if FzSystem = Value then
    Exit;

  FzSystem := Value;

  if Assigned(FzSystem) then
    FzSystem.FreeNotification(Self);

  InitTree;
end;

function TzDbTree.zSystemOk: Boolean;
begin
  result := Assigned(FzSystem);
end;

function TzDbTree.IsAdmin: Boolean;
begin
  result := zSystemOk and FzSystem.IsAdmin;
end;

function TzDbTree.IsTreeReadOnly: Boolean;
begin
  case FReadOnly of
    troForceReadOnly:
      result := True;
    troForceWriteable:
      result := False;
  else
    result := FzDbTreeProps.Flags.ReadOnly or FRestrictionReadOnly;
  end;
end;

function TzDbTree.DbNode(Node: TcxTreeListNode): TcxDBTreeListNode;
begin
  result := nil;

  if Node is TcxDBTreeListNode then
    result := TcxDBTreeListNode(Node);
end;

function TzDbTree.KeyFromText(const Text: string): Variant;
var
  Field: TField;
begin
  // dal file dello stato arriva testo: la chiave torna del tipo del campo
  result := Text;

  if not FDataController.TryGetField(FKeyFieldName, Field) then
    Exit;

  case Field.DataType of
    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftShortint, ftByte, ftLongWord:
      result := StrToInt64Def(Text, 0);
  end;
end;

function TzDbTree.NodeKeyText(Node: TcxTreeListNode): string;
var
  Item: TcxDBTreeListNode;
begin
  result := '';
  Item := DbNode(Node);

  if Assigned(Item) then
    result := VarToStr(Item.KeyValue);
end;

// ---------------------------------------------------------------------------
// Dataset e gerarchia
// ---------------------------------------------------------------------------

procedure TzDbTree.TakeSqlLocate;
begin
  if FSqlLocateTaken or not Assigned(FzDataSet) then
    Exit;

  FSavedUseSqlLocate := FzDataSet.UseSqlLocate;
  FzDataSet.UseSqlLocate := False;
  FSqlLocateTaken := True;
end;

procedure TzDbTree.ReleaseSqlLocate;
begin
  if not FSqlLocateTaken then
    Exit;

  FSqlLocateTaken := False;

  if Assigned(FzDataSet) then
    FzDataSet.UseSqlLocate := FSavedUseSqlLocate;
end;

procedure TzDbTree.ResolveHierarchyFields;
var
  Field: TField;
  i: Integer;
begin
  FKeyFieldName := Trim(FzDbTreeProps.KeyFieldName);
  FParentFieldName := Trim(FzDbTreeProps.ParentFieldName);

  // Convenzione: la chiave primaria del dataset, se di un solo campo
  if FKeyFieldName = '' then
  begin
    FKeyFieldName := Trim(FDataController.PrimaryKeyFields);
    if Pos(';', FKeyFieldName) > 0 then
      FKeyFieldName := '';
  end;

  // Convenzione: il primo campo che finisce in _PADRE
  if FParentFieldName = '' then
    for i := 0 to FDataController.Fields.Count - 1 do
    begin
      Field := FDataController.Fields[i];
      if UpperCase(Field.FieldName).EndsWith('_PADRE') then
      begin
        FParentFieldName := Field.FieldName;
        Break;
      end;
    end;

  // Il controllo con un campo inesistente resta vuoto senza errori (P04, P05)
  FHierarchyOk := (FKeyFieldName <> '') and (FParentFieldName <> '') and Assigned(FDataController.GetField(FKeyFieldName)) and
    Assigned(FDataController.GetField(FParentFieldName));
end;

// ---------------------------------------------------------------------------
// Costruzione
// ---------------------------------------------------------------------------

procedure TzDbTree.InitTree;
begin
  if FBuilt then
    Exit;

  if csDesigning in ComponentState then
    Exit;

  if not zSystemOk then
    Exit;

  if not FDataController.DataSetOk then
    Exit;

  cxDBTreeList.BeginUpdate;
  try
    LoadProperties(True);

    ResolveHierarchyFields;
    TakeSqlLocate;

    if FHierarchyOk then
    begin
      cxDBTreeList.DataController.KeyField := FKeyFieldName;
      cxDBTreeList.DataController.ParentField := FParentFieldName;
    end
    else
      PostInternalMessage(tcWarnHierarchy);

    if (FzDbTreeProps.ImageIndexFieldName <> '') and Assigned(FDataController.GetField(FzDbTreeProps.ImageIndexFieldName)) then
      cxDBTreeList.DataController.ImageIndexField := FzDbTreeProps.ImageIndexFieldName;

    FBuilt := True;
    RebuildColumns;
    LoadUserLayout;

    if FzDbTreeProps.Flags.ExpandMode = temRestore then
      LoadExpansionState;

    // la gerarchia si imposta prima di collegare i dati, come nelle prove
    DataSource.DataSet := FzDataSet;
    FLastState := DataSource.State;
  finally
    cxDBTreeList.EndUpdate;
  end;

  if FDataController.IsActive then
    PostInternalMessage(tcAfterOpen);
end;

procedure TzDbTree.LoadProperties(const LoadDefaults: Boolean);
begin
  if csDesigning in ComponentState then
    Exit;

  FLoadingProps := True;
  try
    if LoadDefaults then
      InternalLoadProperties;

    if zSystemOk and FzSystem.zDbTrees.Exists(TreeID) then
      SetTitle(FzDbTreeProps.Title);

    FDataController.ReadOnly := IsTreeReadOnly;

    ApplyTreeOptions;
    LoadDescription;
    RebuildToolbar;
  finally
    FLoadingProps := False;
  end;

  UpdateActions;
end;

procedure TzDbTree.InternalLoadProperties;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzDbTreeProps.Name = '' then
    FzDbTreeProps.Name := TreeID;

  if FzDbTreeProps.DataSet = '' then
    FzDbTreeProps.DataSet := FDataController.IdDataSet;

  if Assigned(FOnCustomLoadProps) then
    FOnCustomLoadProps(Self)
  else
    if zSystemOk then
      FzDbTreeProps.LoadFromBase;

  FzDbTreeProps.Columns.ValidateDataset(FDataController.zFbDataSet);
end;

procedure TzDbTree.InternalSaveProperties;
begin
  if Assigned(FOnCustomSaveProps) then
    FOnCustomSaveProps(Self)
  else
    if zSystemOk then
    begin
      // aggiornamento in memoria sincrono, scrittura dello zip differita e
      // coalescente come in TzDbPivot e TzDbRecordView
      FzDbTreeProps.SaveToBase(False);

      if not FSaveZipQueued then
      begin
        FSaveZipQueued := True;
        PostInternalMessage(tcSaveZip);
      end;
    end;
end;

procedure TzDbTree.doSalvaImpostazioni(const Silent: Boolean = False);
begin
  if csDesigning in ComponentState then
    Exit;

  if not Silent then
    StartWait('Attendere...', True);
  try
    if FzDbTreeProps.Name = '' then
      FzDbTreeProps.Name := TreeID;

    if FzDbTreeProps.DataSet = '' then
      FzDbTreeProps.DataSet := FDataController.IdDataSet;

    if FBuilt then
      AssignColumnsToProps;

    InternalSaveProperties;
  finally
    if not Silent then
      StopWait;
  end;
end;

procedure TzDbTree.ApplyTreeOptions;
var
  CanDrag: Boolean;
begin
  cxDBTreeList.BeginUpdate;
  try
    // sempre spenti: vedi l'intestazione della unit
    cxDBTreeList.OptionsData.SmartLoad := False;
    cxDBTreeList.OptionsData.Inserting := False;
    cxDBTreeList.OptionsData.Deleting := False;
    cxDBTreeList.OptionsData.CancelOnExit := False;

    // con UseSqlLocate spento il Locate del controllo resta in memoria (P10)
    cxDBTreeList.OptionsData.SyncMode := FzDbTreeProps.Flags.SyncDataSet;
    // celle e scheda sono indipendenti: InplaceEditing decide le celle; con la
    // scheda il doppio clic non apre e chiude i rami
    cxDBTreeList.OptionsData.Editing := not IsTreeReadOnly and FzDbTreeProps.Flags.InplaceEditing;
    cxDBTreeList.OptionsBehavior.ExpandOnDblClick := not UsesCard;

    cxDBTreeList.OptionsView.ShowRoot := FzDbTreeProps.Flags.ShowRoot;
    cxDBTreeList.OptionsView.Footer := FzDbTreeProps.Flags.Footer;
    cxDBTreeList.OptionsView.Indicator := FzDbTreeProps.Flags.Indicator;
    cxDBTreeList.OptionsSelection.MultiSelect := FzDbTreeProps.Flags.MultiSelect;

    // il trascinamento scrive il padre del record: solo se si puo' modificare
    CanDrag := FzDbTreeProps.Flags.DragDrop and not IsTreeReadOnly;
    if CanDrag then
      cxDBTreeList.DragMode := dmAutomatic
    else
      cxDBTreeList.DragMode := dmManual;
  finally
    cxDBTreeList.EndUpdate;
  end;
end;

function TzDbTree.ColumnComponentName(const FieldName: string): string;
var
  Carattere: Char;
begin
  // nome stabile per campo: serve a StoreToIniFile/RestoreFromIniFile (P26)
  result := 'col';
  for Carattere in FieldName do
    if CharInSet(Carattere, ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_']) then
      result := result + Carattere
    else
      result := result + '_';
end;

procedure TzDbTree.RebuildColumns;
var
  Item: TzTreeColumn;
  Field: TField;
  Column: TcxDBTreeListColumn;
  CtrlType: TzCtrlType;
  PropertiesClass: TcxCustomEditPropertiesClass;
  PreviewColumn: TcxDBTreeListColumn;
  ColumnReadOnly: Boolean;
  LookupReady: Boolean;
begin
  if not FBuilt then
    Exit;

  if Assigned(FOnBeforeCreateControls) then
    FOnBeforeCreateControls(Self);

  FzDbTreeProps.Columns.ValidateDataset(FDataController.zFbDataSet);

  cxDBTreeList.BeginUpdate;
  try
    cxDBTreeList.Preview.Column := nil;
    cxDBTreeList.Preview.Visible := False;

    // gli editor dei lookup si sganciano finche' le colonne esistono ancora
    FLookupEditors.Clear;

    while cxDBTreeList.ColumnCount > 0 do
      cxDBTreeList.Columns[0].Free;

    PreviewColumn := nil;

    for Item in FzDbTreeProps.Columns do
    begin
      if not FDataController.TryGetField(Item.Name, Field) then
        Continue;

      Column := cxDBTreeList.CreateColumn as TcxDBTreeListColumn;
      Column.Name := ColumnComponentName(Item.Name);
      Column.DataBinding.FieldName := Item.Name;
      Column.Caption.Text := Item.Caption;
      Column.Visible := Item.Visible;

      if Item.Width > 0 then
        Column.Width := Item.Width;

      // I campi di lookup del dataset hanno gia' l'editor giusto: non si tocca
      if Field.FieldKind <> fkLookup then
      begin
        CtrlType := Item.zCtrlType;

        // Il lookup del dizionario ha bisogno del dataset di appoggio, che
        // prepara TzLookupEditors (zDbLookupEditors); se non si puo' la cella
        // resta una casella di testo, come in TzDbView
        LookupReady := False;

        if CtrlType.IsLookup then
        begin
          if Assigned(Item.Domain) and (Trim(Item.Domain.Lookup) <> '') then
          begin
            PropertiesClass := dx.GetPropertiesClass(CtrlType);

            if Assigned(PropertiesClass) then
            begin
              Column.PropertiesClass := PropertiesClass;
              LookupReady := FLookupEditors.Configure(Column.Properties, Item.Name, Item.Domain.Lookup, CtrlType = ctLookupHyperLink);
            end;
          end;

          if not LookupReady then
            CtrlType := ctEdit;
        end;

        PropertiesClass := nil;
        if not LookupReady then
          PropertiesClass := dx.GetPropertiesClass(CtrlType);

        if Assigned(PropertiesClass) then
        begin
          Column.PropertiesClass := PropertiesClass;
          dx.InitProperties(CtrlType, Column.Properties, Item.Domain, Field);

          // Come in TzDbView: il clic apre la form registrata per il campo
          // (zSystem.HyperLink), non il valore come indirizzo
          if Column.Properties is TcxCustomHyperLinkEditProperties then
          begin
            TcxCustomHyperLinkEditProperties(Column.Properties).UsePrefix := upNever;
            TcxCustomHyperLinkEditProperties(Column.Properties).Prefix := Item.Name;
            TcxCustomHyperLinkEditProperties(Column.Properties).SingleClick := True;
            TcxCustomHyperLinkEditProperties(Column.Properties).OnStartClick := DoHyperLink;
          end;
        end;
      end;

      ColumnReadOnly := IsTreeReadOnly or Item.ReadOnly or Field.ReadOnly or (Assigned(Item.Domain) and Item.Domain.ReadOnly);
      Column.Options.Editing := not ColumnReadOnly;

      if SameText(Item.Name, FzDbTreeProps.PreviewFieldName) then
        PreviewColumn := Column;

      if Assigned(FOnColumnCreated) then
        FOnColumnCreated(Self, Column, Item, Field);
    end;

    if Assigned(PreviewColumn) then
    begin
      PreviewColumn.Visible := False;
      cxDBTreeList.Preview.Column := PreviewColumn;
      cxDBTreeList.Preview.Visible := True;
    end;
  finally
    cxDBTreeList.EndUpdate;
  end;

  if Assigned(FOnAfterCreateControls) then
    FOnAfterCreateControls(Self);

  UpdateActions;
end;

procedure TzDbTree.AssignColumnsToProps;
var
  Ordered: TList<TcxDBTreeListColumn>;
  Items: TList<TzTreeColumn>;
  Column: TcxDBTreeListColumn;
  Item: TzTreeColumn;
  i: Integer;
begin
  // ordine a video: prima le colonne visibili nell'ordine delle intestazioni,
  // poi le nascoste nell'ordine in cui erano
  Ordered := TList<TcxDBTreeListColumn>.Create;
  try
    for i := 0 to cxDBTreeList.ColumnCount - 1 do
      Ordered.Add(cxDBTreeList.Columns[i] as TcxDBTreeListColumn);

    Ordered.Sort(TComparer<TcxDBTreeListColumn>.Construct(
      function(const Left, Right: TcxDBTreeListColumn): Integer
      begin
        if Left.Visible <> Right.Visible then
        begin
          if Left.Visible then
            Exit(-1);
          Exit(1);
        end;

        result := Left.Position.BandIndex - Right.Position.BandIndex;
        if result = 0 then
          result := Left.Position.ColIndex - Right.Position.ColIndex;
      end));

    // voci risolte tutte prima di spostarne una: dopo il primo spostamento
    // le posizioni della collezione cambiano
    Items := TList<TzTreeColumn>.Create;
    try
      for i := 0 to Ordered.Count - 1 do
        Items.Add(FzDbTreeProps.Columns.get(Ordered[i].DataBinding.FieldName, False));

      FzDbTreeProps.Columns.BeginUpdate;
      try
        for i := 0 to Ordered.Count - 1 do
        begin
          Column := Ordered[i];
          Item := Items[i];

          if not Assigned(Item) then
            Continue;

          // la colonna dell'anteprima e' nascosta dal componente, non dall'amministratore
          if Column <> cxDBTreeList.Preview.Column then
            Item.Visible := Column.Visible;

          Item.Width := Column.Width;
          Item.Index := i;
        end;
      finally
        FzDbTreeProps.Columns.EndUpdate;
      end;
    finally
      FreeAndNil(Items);
    end;
  finally
    FreeAndNil(Ordered);
  end;
end;

procedure TzDbTree.ReloadProps;
begin
  if not FBuilt then
    Exit;

  CaptureExpansion;

  cxDBTreeList.BeginUpdate;
  try
    LoadProperties(True);
    ResolveHierarchyFields;

    if FHierarchyOk then
    begin
      cxDBTreeList.DataController.KeyField := FKeyFieldName;
      cxDBTreeList.DataController.ParentField := FParentFieldName;
    end;

    RebuildColumns;
    LoadUserLayout;
  finally
    cxDBTreeList.EndUpdate;
  end;

  RestoreExpansion;
end;

procedure TzDbTree.CreateFiltersFromProps;
begin
  TzToolFilterBuilder.Build(FzDbTreeProps.ToolFilters, Self, dxBarManager, FzDataSet);
end;

procedure TzDbTree.InitToolActions;
begin
  TzActionBuilder.BuildFromProps(FzDbTreeProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(dxBarToolbarFree, popTree, otView);
  DisplayToolbars;
end;

function TzDbTree.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
begin
  // Scrive sui props persistiti, come TzDbView e TzDbPivot: il runtime
  // ToolActions e' rigenerato da InitToolActions. FromCode protegge l'azione
  // da codice dall'Assign del dizionario. ImageList non e' persistibile.
  result := nil;

  if not Assigned(Action) then
    Exit;

  result := FzDbTreeProps.ToolActions.Find(Action.Name);
  if not Assigned(result) then
  begin
    result := FzDbTreeProps.ToolActions.Add;
    result.Name := Action.Name;
  end;

  result.FromCode := True;
end;

procedure TzDbTree.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;

  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbTree.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

procedure TzDbTree.OnFlagChange(Sender: TObject);
begin
  // durante il caricamento delle props l'Assign dei flag scatta piu' volte:
  // LoadProperties applica tutto alla fine
  if FLoadingProps or FIsDestroying then
    Exit;

  FDataController.ReadOnly := IsTreeReadOnly;
  ApplyTreeOptions;

  if FBuilt then
    RebuildColumns;

  DisplayToolbars;
  UpdateActions;
end;

procedure TzDbTree.DisplayToolbars;
begin
  dxBarManager.BeginUpdate;
  try
    // ordine inverso di visualizzazione
    dxBarToolbarFree.Visible := Flags.Toolbar;
    dxBarToolbar.Visible := Flags.Toolbar;
    dxBarToolbar.UseRestSpace := not dxBarToolbarFree.Visible;
    Titolo.Visible := Flags.Toolbar and (Titolo.Caption <> '');
  finally
    dxBarManager.EndUpdate;
  end;
end;

procedure TzDbTree.UpdateActions;
var
  Editing: Boolean;
  CanModify: Boolean;
  HasFocusedNode: Boolean;
begin
  if (csDestroying in ComponentState) or FIsDestroying then
    Exit;

  Editing := FDataController.IsEditing;
  CanModify := not IsTreeReadOnly;
  HasFocusedNode := Assigned(cxDBTreeList.FocusedNode);

  ActionVisible(actDbFirst, Flags.ButtonArrows);
  ActionVisible(actDbPrior, Flags.ButtonArrows);
  ActionVisible(actDbNext, Flags.ButtonArrows);
  ActionVisible(actDbLast, Flags.ButtonArrows);
  ActionVisible(actVaiAlPadre, Flags.ButtonArrows);

  actDbFirst.Enabled := (not Editing) and (cxDBTreeList.Count > 0);
  actDbLast.Enabled := (not Editing) and (cxDBTreeList.Count > 0);
  actDbPrior.Enabled := (not Editing) and HasFocusedNode;
  actDbNext.Enabled := (not Editing) and HasFocusedNode;
  actVaiAlPadre.Enabled := (not Editing) and HasFocusedNode and (cxDBTreeList.FocusedNode.Level > 0);

  ActionVisible(actDbRefresh, Flags.ButtonRefresh and FDataController.CanRefresh);

  // come TzDbView: un gestore della form mostra l'azione anche in sola lettura
  ActionVisible(actDbInsert, (CanModify and Flags.ButtonInsert) or Assigned(FOnDataSetInsert));
  ActionVisible(actInserisciFiglio, (CanModify and Flags.ButtonInsert) or Assigned(FOnDataSetInsert));
  ActionVisible(actInserisciRadice, (CanModify and Flags.ButtonInsert) or Assigned(FOnDataSetInsert));
  ActionVisible(actDbEdit, (CanModify and Flags.ButtonUpdate) or Assigned(FOnDataSetEdit));
  ActionVisible(actDbDelete, (CanModify and Flags.ButtonDelete) or Assigned(FOnDataSetDelete));
  actDbInsert.Enabled := (not Editing) and FDataController.CanInsert and FHierarchyOk;
  actInserisciFiglio.Enabled := (not Editing) and FDataController.CanInsert and FHierarchyOk and HasFocusedNode;
  actInserisciRadice.Enabled := (not Editing) and FDataController.CanInsert and FHierarchyOk;
  actDbEdit.Enabled := (not Editing) and FDataController.CanEdit;
  actDbDelete.Enabled := (not Editing) and FDataController.CanDelete and HasFocusedNode;

  ActionVisible(actDbPost, Flags.ButtonOkCancel and Editing);
  ActionVisible(actDbCancel, Flags.ButtonOkCancel and Editing);
  actDbPost.Enabled := FDataController.CanPost;
  actDbCancel.Enabled := FDataController.CanCancel;

  ActionVisible(Espandi, Flags.ButtonExpand);
  ActionVisible(Riduci, Flags.ButtonExpand);
  ActionVisible(actEspandiRamo, Flags.ButtonExpand);
  ActionVisible(actRiduciRamo, Flags.ButtonExpand);
  actEspandiRamo.Enabled := HasFocusedNode;
  actRiduciRamo.Enabled := HasFocusedNode;
  UpdateExpandCaptions;

  ActionVisible(Elabora, Flags.Params);

  ActionVisible(actPersonalizza, IsAdmin);
  ActionVisible(actPersonalizzaColonne, IsAdmin);
  ActionVisible(actPersonalizzaCampo, IsAdmin);
  ActionVisible(actResetColonne, IsAdmin);
  ActionVisible(SalvaImpostazioni, IsAdmin);
  ActionVisible(CaricaImpostazioni, IsAdmin);
  ActionVisible(actSQL, IsAdmin);
  ActionVisible(MostraQueryUtilizzata, IsAdmin);
  ActionVisible(CopiaQueryUtilizzata, IsAdmin);
  ActionVisible(CopyName, IsAdmin);
  ActionVisible(NomeFileIni, IsAdmin);

  if Assigned(FOnUpdateActions) then
    FOnUpdateActions(Self);
end;

procedure TzDbTree.UpdateExpandCaptions;
var
  Stile: TdxBarPaintStyle;
  Pulsante: TdxBarItem;
  Indice: Integer;
begin
  // Solo i collegamenti della barra hanno lo stile definito nel DFM
  // (udPaintStyle): quelli dei menu mostrano comunque la scritta
  if Flags.ButtonExpandCaption then
    Stile := psCaptionGlyph
  else
    Stile := psStandard;

  for Pulsante in TArray<TdxBarItem>.Create(dxBarButtonEspandi, dxBarButtonRiduci) do
    for Indice := 0 to Pulsante.LinkCount - 1 do
      if (udPaintStyle in Pulsante.Links[Indice].UserDefine) and (Pulsante.Links[Indice].UserPaintStyle <> Stile) then
        Pulsante.Links[Indice].UserPaintStyle := Stile;
end;

// ---------------------------------------------------------------------------
// Apertura ed espansione
// ---------------------------------------------------------------------------

procedure TzDbTree.AfterOpen;
begin
  if not FBuilt then
    Exit;

  if not FDataController.IsActive then
    Exit;

  // Prima apertura: la regola delle props (o lo stato salvato con temRestore);
  // riaperture successive: i rami che l'utente aveva aperto
  if not FStateRestored then
  begin
    FStateRestored := True;

    if (FzDbTreeProps.Flags.ExpandMode = temRestore) and (FExpandedKeys.Count > 0) then
      ApplyExpandedKeys
    else
      ApplyExpandMode;
  end
  else
    ApplyExpandedKeys;

  // i lookup delle celle servono anche solo a mostrare la descrizione
  FLookupEditors.EnsureOpen;

  if AlreadyShown and Showing then
    CheckColumnWidths;

  UpdateActions;
end;

procedure TzDbTree.ApplyExpandMode;
begin
  case FzDbTreeProps.Flags.ExpandMode of
    temNone, temRoots:
      // le radici sono sempre visibili: entrambe lasciano l'albero chiuso
      CollapseAll;
    temLevel:
      ExpandToLevel(FzDbTreeProps.Flags.ExpandLevel);
    temAll:
      ExpandAll;
    temRestore:
      // nessuno stato salvato: si parte chiusi
      CollapseAll;
  end;
end;

procedure TzDbTree.ApplyExpandedKeys;
var
  Keys: TArray<string>;
  Key: string;
  Node: TcxDBTreeListNode;
begin
  Keys := FExpandedKeys.Keys.ToArray;

  FTrackExpansion := False;
  cxDBTreeList.BeginUpdate;
  try
    for Key in Keys do
    begin
      Node := NodeByKey(FExpandedKeys[Key]);

      // nodo scomparso o nascosto dal filtro (P40): si dimentica
      if Assigned(Node) then
        Node.Expanded := True
      else
        FExpandedKeys.Remove(Key);
    end;
  finally
    cxDBTreeList.EndUpdate;
    FTrackExpansion := True;
  end;

  if not VarIsNull(FFocusedKey) then
    FocusKey(FFocusedKey);
end;

procedure TzDbTree.CaptureExpansion;
var
  Node: TcxTreeListNode;
begin
  // Gli eventi tengono gia' aggiornato l'elenco: qui lo si rifa' da capo,
  // per chi chiama prima di ricaricare il dataset da codice
  if cxDBTreeList.Count = 0 then
    Exit;

  FExpandedKeys.Clear;
  Node := cxDBTreeList.Items[0];

  while Assigned(Node) do
  begin
    if Node.Expanded and (Node.Count > 0) and Assigned(DbNode(Node)) then
      FExpandedKeys.AddOrSetValue(NodeKeyText(Node), DbNode(Node).KeyValue);
    Node := Node.GetNext;
  end;

  if Assigned(cxDBTreeList.FocusedNode) then
    FFocusedKey := FocusedKey;
end;

procedure TzDbTree.RestoreExpansion;
begin
  if FDataController.IsActive then
    ApplyExpandedKeys;
end;

procedure TzDbTree.ExpandAll;
begin
  cxDBTreeList.FullExpand;
end;

procedure TzDbTree.CollapseAll;
begin
  cxDBTreeList.FullCollapse;
end;

procedure TzDbTree.ExpandToLevel(const Level: Integer);
var
  Node: TcxTreeListNode;
begin
  cxDBTreeList.BeginUpdate;
  try
    cxDBTreeList.FullCollapse;

    if cxDBTreeList.Count = 0 then
      Exit;

    // GetNext scorre tutti i nodi in ordine, aperti o chiusi
    Node := cxDBTreeList.Items[0];
    while Assigned(Node) do
    begin
      if (Node.Level < Level) and (Node.Count > 0) then
        Node.Expanded := True;
      Node := Node.GetNext;
    end;
  finally
    cxDBTreeList.EndUpdate;
  end;
end;

procedure TzDbTree.ExpandBranch;
begin
  if Assigned(cxDBTreeList.FocusedNode) then
    cxDBTreeList.FocusedNode.Expand(True);
end;

procedure TzDbTree.CollapseBranch;
begin
  if Assigned(cxDBTreeList.FocusedNode) then
    cxDBTreeList.FocusedNode.Collapse(True);
end;

// ---------------------------------------------------------------------------
// Nodi e chiavi
// ---------------------------------------------------------------------------

function TzDbTree.FocusedKey: Variant;
var
  Node: TcxDBTreeListNode;
begin
  result := Null;
  Node := DbNode(cxDBTreeList.FocusedNode);

  if Assigned(Node) then
    result := Node.KeyValue;
end;

function TzDbTree.FocusedParentKey: Variant;
var
  Node: TcxDBTreeListNode;
begin
  result := Null;
  Node := DbNode(cxDBTreeList.FocusedNode);

  // i nodi di primo livello hanno come Parent la radice interna: padre Null
  if Assigned(Node) and (Node.Level > 0) then
    result := Node.ParentKeyValue;
end;

function TzDbTree.NodeByKey(const Key: Variant): TcxDBTreeListNode;
begin
  result := nil;

  if VarIsNull(Key) or VarIsEmpty(Key) then
    Exit;

  result := cxDBTreeList.FindNodeByKeyValue(Key);
end;

function TzDbTree.FocusKey(const Key: Variant): Boolean;
var
  Node: TcxDBTreeListNode;
begin
  // un nodo nascosto dal filtro non si trova (P40)
  Node := NodeByKey(Key);
  result := Assigned(Node);

  if result then
  begin
    Node.MakeVisible;
    Node.Focused := True;
  end;
end;

function TzDbTree.GetSelectedKeys: TArray<Variant>;
var
  i: Integer;
  Node: TcxDBTreeListNode;
begin
  result := nil;

  for i := 0 to cxDBTreeList.SelectionCount - 1 do
  begin
    Node := DbNode(cxDBTreeList.Selections[i]);
    if Assigned(Node) then
      result := result + [Node.KeyValue];
  end;

  // senza selezione multipla conta il nodo con il fuoco
  if (Length(result) = 0) and Assigned(cxDBTreeList.FocusedNode) then
    result := [FocusedKey];
end;

function TzDbTree.ChildCount(const Key: Variant): Integer;
var
  Node: TcxDBTreeListNode;
begin
  result := 0;
  Node := NodeByKey(Key);

  if Assigned(Node) then
    result := Node.Count;
end;

// ---------------------------------------------------------------------------
// Colonne
// ---------------------------------------------------------------------------

function TzDbTree.ColumnByField(const FieldName: string): TcxDBTreeListColumn;
begin
  result := cxDBTreeList.GetColumnByFieldName(FieldName);
end;

procedure TzDbTree.ShowField(const FieldName: string);
var
  Column: TcxDBTreeListColumn;
begin
  Column := ColumnByField(FieldName);
  if Assigned(Column) then
    Column.Visible := True;
end;

procedure TzDbTree.HideField(const FieldName: string);
var
  Column: TcxDBTreeListColumn;
begin
  Column := ColumnByField(FieldName);
  if Assigned(Column) then
    Column.Visible := False;
end;

// ---------------------------------------------------------------------------
// Eventi del dataset e dell'albero
// ---------------------------------------------------------------------------

procedure TzDbTree.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  if FIsDestroying then
    Exit;

  PostInternalMessage(tcUpdateActions);
end;

procedure TzDbTree.DataSourceStateChange(Sender: TObject);
var
  NewState: TDataSetState;
begin
  if FIsDestroying then
    Exit;

  NewState := DataSource.State;

  // dati appena (ri)caricati: espansione da rifare dopo che l'albero ha
  // costruito i nodi, quindi in differita
  if (FLastState = dsInactive) and (NewState <> dsInactive) then
    PostInternalMessage(tcAfterOpen);

  FLastState := NewState;
  PostInternalMessage(tcUpdateActions);
end;

procedure TzDbTree.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  // aggiornamento affidato a UpdateActions, chiamato dagli eventi
end;

procedure TzDbTree.TreeFocusedNodeChanged(Sender: TcxCustomTreeList; APrevFocusedNode, AFocusedNode: TcxTreeListNode);
begin
  if FIsDestroying then
    Exit;

  if FTrackExpansion and Assigned(AFocusedNode) then
    FFocusedKey := FocusedKey;

  UpdateActions;

  if Assigned(FOnNodeChanged) then
    FOnNodeChanged(Self);
end;

procedure TzDbTree.TreeExpanded(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
begin
  // durante la chiusura del dataset i nodi si distruggono: lo stato resta
  if not FTrackExpansion or FIsDestroying or ANode.Deleting or not FDataController.IsActive then
    Exit;

  if Assigned(DbNode(ANode)) then
    FExpandedKeys.AddOrSetValue(NodeKeyText(ANode), DbNode(ANode).KeyValue);
end;

procedure TzDbTree.TreeCollapsed(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
begin
  if not FTrackExpansion or FIsDestroying or ANode.Deleting or not FDataController.IsActive then
    Exit;

  FExpandedKeys.Remove(NodeKeyText(ANode));
end;

procedure TzDbTree.TreeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  // senza un gestore il controllo non accetta il trascinamento dei nodi:
  // la scelta dei bersagli validi resta a lui (cicli compresi, P31)
  Accept := Accept and FzDbTreeProps.Flags.DragDrop and not IsTreeReadOnly and not FDataController.IsEditing;
end;

procedure TzDbTree.TreeMoveTo(Sender: TcxCustomTreeList; AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode; Nodes: TList;
  var IsCopy, Done: Boolean);
var
  NewParentKey: Variant;
  ParentNode: TcxTreeListNode;
  Node: TcxDBTreeListNode;
  Allow: Boolean;
  i: Integer;
begin
  // il trascinamento sposta, non copia
  IsCopy := False;

  if IsTreeReadOnly or not FzDbTreeProps.Flags.DragDrop then
  begin
    Done := True;
    Exit;
  end;

  if not Assigned(FOnNodeMove) then
    Exit;

  // nuovo padre: il nodo bersaglio per i figli, il padre del bersaglio per i fratelli
  if AttachMode in [tlamAddChild, tlamAddChildFirst] then
    ParentNode := AttachNode
  else
    if Assigned(AttachNode) and (AttachNode.Level > 0) then
      ParentNode := AttachNode.Parent
    else
      ParentNode := nil;

  NewParentKey := Null;
  if Assigned(DbNode(ParentNode)) then
    NewParentKey := DbNode(ParentNode).KeyValue;

  for i := 0 to Nodes.Count - 1 do
  begin
    Node := DbNode(TcxTreeListNode(Nodes[i]));
    if not Assigned(Node) then
      Continue;

    Allow := True;
    FOnNodeMove(Self, Node.KeyValue, NewParentKey, Allow);

    // un rifiuto annulla tutto lo spostamento prima di ogni scrittura (P34)
    if not Allow then
    begin
      Done := True;
      Exit;
    end;
  end;
end;

procedure TzDbTree.TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Esc fuori dall'editor: l'annullamento passa da DataController, come le azioni
  if (Key = VK_ESCAPE) and (Shift = []) and not cxDBTreeList.IsEditing then
    if FDataController.IsEditing then
    begin
      Key := 0;
      Cancel;
      Exit;
    end;

  // Ctrl+F: pannello di ricerca
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    Key := 0;
    actTrova.Execute;
  end;
end;

// ---------------------------------------------------------------------------
// Modifica dei record
// ---------------------------------------------------------------------------

procedure TzDbTree.InsertWithParent(const ParentKey: Variant);
var
  Field: TField;
begin
  if IsTreeReadOnly or not FHierarchyOk then
    Exit;

  if not FDataController.CanInsert then
    Exit;

  FDataController.Insert;

  if FDataController.TryGetField(FParentFieldName, Field) then
    Field.Value := ParentKey;
end;

procedure TzDbTree.InsertChild(const ParentKey: Variant);
begin
  InsertWithParent(ParentKey);
end;

procedure TzDbTree.InsertRoot;
begin
  InsertWithParent(Null);
end;

procedure TzDbTree.InsertSibling;
begin
  InsertWithParent(FocusedParentKey);
end;

procedure TzDbTree.Post;
begin
  // il valore battuto nell'editor ancora aperto va prima nel campo
  cxDBTreeList.DataController.PostEditingData;
  FDataController.CheckBrowseMode;
end;

procedure TzDbTree.Cancel;
begin
  cxDBTreeList.CancelEdit;
  FDataController.Cancel;
end;

// ---------------------------------------------------------------------------
// Layout personale
// ---------------------------------------------------------------------------

function TzDbTree.LayoutFileName: string;
var
  SafeID: string;
  Carattere: Char;
begin
  result := '';

  if not zSystemOk or (TreeID = '') then
    Exit;

  // L'identificativo e' del tipo Modulo.DataSet: il punto resta nel nome
  // (ChangeFileExt lo scambierebbe per l'estensione e fonderebbe gli alberi
  // dello stesso modulo dati); si tolgono solo i caratteri non ammessi.
  SafeID := '';
  for Carattere in TreeID do
    if CharInSet(Carattere, ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then
      SafeID := SafeID + '_'
    else
      SafeID := SafeID + Carattere;

  result := IncludeTrailingPathDelimiter(FzSystem.PersonalFolder) + SafeID + '.tree';
end;

function TzDbTree.StateFileName: string;
begin
  result := LayoutFileName;

  if result <> '' then
    result := result + 'state';
end;

procedure TzDbTree.LoadUserLayout;
var
  FileName: string;
begin
  FileName := LayoutFileName;

  // a ogni caricamento del layout CheckColumnWidths allarga al contenuto le
  // colonne rimaste strette, appena l'albero ha dei nodi
  FAdattaLarghezzeInAttesa := True;

  if (FileName = '') or not FileExists(FileName) then
    Exit;

  // solo colonne (larghezza, posizione, visibilita'): i nodi li gestisce
  // l'elenco dei rami aperti. Le colonne che non ci sono piu' si ignorano
  try
    cxDBTreeList.RestoreFromIniFile(FileName, False, False, '', []);
  except
    // un file rovinato non deve impedire l'apertura dell'albero
    on Exception do
      ;
  end;
end;

procedure TzDbTree.SaveUserLayout;
var
  FileName: string;
begin
  FileName := LayoutFileName;

  if FileName = '' then
    Exit;

  try
    ForceDirectories(ExtractFilePath(FileName));
    cxDBTreeList.StoreToIniFile(FileName, True, '', []);
  except
    // il layout personale non deve impedire la chiusura della form
    on Exception do
      ;
  end;
end;

procedure TzDbTree.LoadExpansionState;
var
  FileName: string;
  Ini: TMemIniFile;
  Elenco: string;
  Key: string;
begin
  FileName := StateFileName;

  if (FileName = '') or not FileExists(FileName) then
    Exit;

  try
    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      FExpandedKeys.Clear;

      Elenco := Ini.ReadString(SSezioneStato, 'Expanded', '');
      for Key in Elenco.Split([';'], TStringSplitOptions.ExcludeEmpty) do
        FExpandedKeys.AddOrSetValue(Key, KeyFromText(Key));

      Key := Ini.ReadString(SSezioneStato, 'Focused', '');
      if Key <> '' then
        FFocusedKey := KeyFromText(Key);
    finally
      FreeAndNil(Ini);
    end;
  except
    // TEncoding.UTF8 solleva su byte non validi: si riparte chiusi
    on Exception do
      FExpandedKeys.Clear;
  end;
end;

procedure TzDbTree.SaveExpansionState;
var
  FileName: string;
  Ini: TMemIniFile;
begin
  FileName := StateFileName;

  if FileName = '' then
    Exit;

  try
    ForceDirectories(ExtractFilePath(FileName));

    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      Ini.EraseSection(SSezioneStato);
      Ini.WriteString(SSezioneStato, 'Expanded', string.Join(';', FExpandedKeys.Keys.ToArray));
      Ini.WriteString(SSezioneStato, 'Focused', VarToStr(FFocusedKey));
      Ini.UpdateFile;
    finally
      FreeAndNil(Ini);
    end;
  except
    on Exception do
      ;
  end;
end;

// ---------------------------------------------------------------------------
// Descrizione
// ---------------------------------------------------------------------------

procedure TzDbTree.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

procedure TzDbTree.LoadDescription;
begin
  if not Assigned(FrameDescription) then
    CreateDescription;

  FzDbTreeProps.Description.LoadFromIni(TreeID);
  FrameDescription.zDescription := FzDbTreeProps.Description;

  Descrizione.Checked := FrameDescription.zDescription.Visible;
end;

procedure TzDbTree.SaveDescription;
begin
  FzDbTreeProps.Description.Assign(FrameDescription.zDescription);
  FzDbTreeProps.Description.SaveToIni(TreeID);
  Descrizione.Checked := FzDbTreeProps.Description.Visible;
end;

// ---------------------------------------------------------------------------
// Titolo
// ---------------------------------------------------------------------------

function TzDbTree.GetTitle: string;
begin
  result := Titolo.Caption;

  if result.IsEmpty then
    result := FzDbTreeProps.Title;

  if result.IsEmpty then
  begin
    result := Name;
    if result.StartsWith('tree') then
      result := result.Replace('tree', '', [rfIgnoreCase]);
  end;
end;

procedure TzDbTree.SetTitle(const Title: string);
begin
  Titolo.Caption := Trim(Title);
  Titolo.Visible := Titolo.Caption <> '';
  dxBarControlContainerTitolo.Visible := dx.Visible(Titolo.Visible);

  dxBarEditTitolo.OnChange := nil;
  try
    dxBarEditTitolo.EditValue := Titolo.Caption;
  finally
    dxBarEditTitolo.OnChange := dxBarEditTitoloChange;
  end;
end;

procedure TzDbTree.dxBarEditTitoloChange(Sender: TObject);
begin
  FzDbTreeProps.Title := VarToStr(dxBarEditTitolo.EditValue);
  doSalvaImpostazioni;

  // il titolo a video si aggiorna dopo: durante OnChange la casella di testo
  // della barra e' ancora in modifica e SetTitle ne riscrive il valore
  PostInternalMessage(tcApplyTitle);
end;

// ---------------------------------------------------------------------------
// Uscite
// ---------------------------------------------------------------------------

procedure TzDbTree.ExportToFile(const FileName: string);
var
  Extension: string;
begin
  Extension := LowerCase(ExtractFileExt(FileName));

  // AExpand apre i nodi a video (P50): stato raccolto prima e rimesso dopo,
  // senza registrare le aperture fatte dall'esportazione
  CaptureExpansion;
  FTrackExpansion := False;
  try
    if Extension = '.csv' then
      cxExportTLToCSV(FileName, cxDBTreeList, True, True)
    else
      if Extension = '.xls' then
        cxExportTLToExcel(FileName, cxDBTreeList, True, True)
      else
        cxExportTLToXLSX(FileName, cxDBTreeList, True, True);
  finally
    cxDBTreeList.BeginUpdate;
    try
      cxDBTreeList.FullCollapse;
    finally
      cxDBTreeList.EndUpdate;
      FTrackExpansion := True;
    end;
    ApplyExpandedKeys;
  end;
end;

procedure TzDbTree.Preview;
var
  Printer: TdxComponentPrinter;
  Link: TBasedxReportLink;
begin
  // printer creato al momento e liberato subito: niente stato condiviso fra
  // stampe successive. dx.InitPrinter spegne la clessidra di ExpressPrinting.
  // La stampa apre i nodi nel rapporto, non a video (P51)
  Printer := TdxComponentPrinter.Create(nil);
  try
    dx.InitPrinter(Printer);
    Link := Printer.AddLink(cxDBTreeList);

    if Link is TcxTreeListCustomReportLink then
      TcxTreeListCustomReportLink(Link).OptionsExpanding.AutoExpandNodes := True;

    Printer.Preview(True, nil);
  finally
    FreeAndNil(Printer);
  end;
end;

// ---------------------------------------------------------------------------
// Azioni
// ---------------------------------------------------------------------------

procedure TzDbTree.ActivateDataSet;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FDataController.IsActive then
    Exit;

  if FDataController.AutoOpen then
    FDataController.OpenDataSet;
end;

procedure TzDbTree.actDbFirstExecute(Sender: TObject);
begin
  if cxDBTreeList.Count > 0 then
    cxDBTreeList.Items[0].Focused := True;
end;

procedure TzDbTree.actDbPriorExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
begin
  if not Assigned(cxDBTreeList.FocusedNode) then
    Exit;

  Node := cxDBTreeList.FocusedNode.GetPrevVisible;
  if Assigned(Node) then
    Node.Focused := True;
end;

procedure TzDbTree.actDbNextExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
begin
  if not Assigned(cxDBTreeList.FocusedNode) then
    Exit;

  Node := cxDBTreeList.FocusedNode.GetNextVisible;
  if Assigned(Node) then
    Node.Focused := True;
end;

procedure TzDbTree.actDbLastExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
begin
  if cxDBTreeList.Count = 0 then
    Exit;

  // l'ultimo nodo visibile: l'ultima radice, poi giu' negli ultimi figli aperti
  Node := cxDBTreeList.Items[cxDBTreeList.Count - 1];
  while Node.Expanded and (Node.Count > 0) do
    Node := Node.GetLastChild;

  Node.Focused := True;
end;

procedure TzDbTree.actVaiAlPadreExecute(Sender: TObject);
var
  Node: TcxTreeListNode;
begin
  Node := cxDBTreeList.FocusedNode;

  if Assigned(Node) and (Node.Level > 0) then
  begin
    Node.Parent.MakeVisible;
    Node.Parent.Focused := True;
  end;
end;

procedure TzDbTree.actDbRefreshExecute(Sender: TObject);
begin
  actDbRefresh.Enabled := False;
  try
    CaptureExpansion;
    FDataController.Refresh;
    // con un aggiornamento senza riapertura lo stato non cambia: rimetterlo
    // non costa niente; con una riapertura ci pensa tcAfterOpen
    RestoreExpansion;
  finally
    actDbRefresh.Enabled := True;
  end;
end;

procedure TzDbTree.actDbInsertExecute(Sender: TObject);
begin
  if Assigned(FOnDataSetInsert) then
    FOnDataSetInsert(Self)
  else
    if Flags.ButtonInsert then
      InsertNode(FocusedParentKey);
end;

procedure TzDbTree.actInserisciFiglioExecute(Sender: TObject);
begin
  if not Assigned(cxDBTreeList.FocusedNode) then
    Exit;

  // il padre si apre subito, cosi' il nodo nuovo si vede
  cxDBTreeList.FocusedNode.Expanded := True;

  if Assigned(FOnDataSetInsert) then
    FOnDataSetInsert(Self)
  else
    if Flags.ButtonInsert then
      InsertNode(FocusedKey);
end;

procedure TzDbTree.actInserisciRadiceExecute(Sender: TObject);
begin
  if Assigned(FOnDataSetInsert) then
    FOnDataSetInsert(Self)
  else
    if Flags.ButtonInsert then
      InsertNode(Null);
end;

procedure TzDbTree.actDbEditExecute(Sender: TObject);
begin
  if Assigned(FOnDataSetEdit) then
    FOnDataSetEdit(Self)
  else
    if FDataController.CanEdit and Flags.ButtonUpdate and not IsTreeReadOnly then
    begin
      if UsesCard then
      begin
        // come TzDbView.dbEdit: la scheda della form decide da se'
        if not Assigned(FOnShowCard) then
        begin
          if not LocateFocusedNode then
            Exit;
          FDataController.CheckEditMode;
        end;
        ShowCard(False);
      end
      else
        FDataController.CheckEditMode;
    end;
end;

procedure TzDbTree.actDbDeleteExecute(Sender: TObject);
var
  Figli: Integer;
  Domanda: string;
begin
  if Assigned(FOnDataSetDelete) then
  begin
    FOnDataSetDelete(Self);
    Exit;
  end;

  if not(FDataController.CanDelete and Flags.ButtonDelete and not IsTreeReadOnly) then
    Exit;

  if not Assigned(cxDBTreeList.FocusedNode) then
    Exit;

  // con SyncMode spento il record corrente puo' non essere quello del nodo
  if not FzDbTreeProps.Flags.SyncDataSet then
    if not FzDataSet.Locate(FKeyFieldName, FocusedKey, []) then
      Exit;

  // i figli di un nodo eliminato salgono alla radice (P23): va detto prima
  Figli := cxDBTreeList.FocusedNode.Count;
  if Figli > 0 then
    Domanda := Format(SEliminoConFigli, [Figli])
  else
    Domanda := SEliminoIlRecord;

  if ConfirmYesNo(Domanda) then
    FDataController.Delete;
end;

procedure TzDbTree.actDbPostExecute(Sender: TObject);
begin
  Post;
end;

procedure TzDbTree.actDbCancelExecute(Sender: TObject);
begin
  Cancel;
end;

procedure TzDbTree.actTrovaExecute(Sender: TObject);
begin
  // il pannello cerca nei valori e filtra i nodi tenendo gli antenati (P40)
  cxDBTreeList.ShowFindPanel;
end;

procedure TzDbTree.EspandiExecute(Sender: TObject);
begin
  ExpandAll;
end;

procedure TzDbTree.RiduciExecute(Sender: TObject);
begin
  CollapseAll;
end;

procedure TzDbTree.actEspandiRamoExecute(Sender: TObject);
begin
  ExpandBranch;
end;

procedure TzDbTree.actRiduciRamoExecute(Sender: TObject);
begin
  CollapseBranch;
end;

procedure TzDbTree.AdattaLarghezzeExecute(Sender: TObject);
begin
  ApplyBestFit;
end;

procedure TzDbTree.ElaboraExecute(Sender: TObject);
begin
  ShowParams(TreeID + '_Params', zDataSet, 'Parametri', True);
end;

procedure TzDbTree.actExcelBeforeExecute(Sender: TObject);
begin
  if (actExcel.Dialog.InitialDir = '') and zSystemOk then
    actExcel.Dialog.InitialDir := FzSystem.PersonalFolder;
end;

procedure TzDbTree.actExcelAccept(Sender: TObject);
var
  FileName: string;
begin
  FileName := actExcel.Dialog.FileName;

  case actExcel.Dialog.FilterIndex of
    2:
      FileName := ChangeFileExt(FileName, '.xls');
    3:
      FileName := ChangeFileExt(FileName, '.csv');
  else
    FileName := ChangeFileExt(FileName, '.xlsx');
  end;

  ExportToFile(FileName);

  ShellExecute(0, PChar('open'), PChar(ExtractFilePath(FileName)), nil, nil, SW_RESTORE);
end;

procedure TzDbTree.actStampaExecute(Sender: TObject);
begin
  Preview;
end;

procedure TzDbTree.DescrizioneExecute(Sender: TObject);
begin
  if Descrizione.Checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzDbTree.RipristinaLayoutExecute(Sender: TObject);
var
  FileName: string;
begin
  if not ConfirmYesNo('Ripristinare il layout predefinito dell''albero?') then
    Exit;

  FileName := LayoutFileName;
  if (FileName <> '') and FileExists(FileName) then
    System.SysUtils.DeleteFile(FileName);

  FileName := StateFileName;
  if (FileName <> '') and FileExists(FileName) then
    System.SysUtils.DeleteFile(FileName);

  ApplyTreeOptions;
  RebuildColumns;
  ApplyExpandMode;
end;

procedure TzDbTree.actPersonalizzaExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  // le props riflettono prima l'albero, poi l'amministratore le modifica
  AssignColumnsToProps;

  if FzDbTreeProps.Inspect then
  begin
    CaptureExpansion;
    LoadProperties(False);
    ResolveHierarchyFields;

    if FHierarchyOk then
    begin
      cxDBTreeList.DataController.KeyField := FKeyFieldName;
      cxDBTreeList.DataController.ParentField := FParentFieldName;
    end
    else
      PostInternalMessage(tcWarnHierarchy);

    RebuildColumns;
    doSalvaImpostazioni(False);
    RestoreExpansion;
  end;
end;

procedure TzDbTree.actPersonalizzaColonneExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  // il modulo dell'albero permette di nascondere e spostare le colonne;
  // Salva impostazioni le porta nel dizionario
  cxDBTreeList.Customizing.Visible := True;
end;

procedure TzDbTree.actPersonalizzaCampoExecute(Sender: TObject);
var
  FieldName: string;
  Field: TField;
  Origin: string;
  Idx: Integer;
  Domain: TzDomain;
begin
  if not IsAdmin then
    Exit;

  if not(cxDBTreeList.FocusedColumn is TcxDBTreeListColumn) then
    Exit;

  FieldName := TcxDBTreeListColumn(cxDBTreeList.FocusedColumn).DataBinding.FieldName;
  if FieldName = '' then
    Exit;

  if not FDataController.TryGetField(FieldName, Field) then
    Exit;

  Origin := FDataController.GetFieldOrigin(Field);

  Idx := FzSystem.zDataDictionary.IndexOf(Origin);
  if Idx = -1 then
    Exit;

  Domain := FzSystem.zDataDictionary[Idx];

  if Domain.Inspect then
  begin
    FzSystem.SaveZip(csFieldProps, 'Personalizzazione Campo DbTree');
    RebuildColumns;
  end;
end;

procedure TzDbTree.actResetColonneExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  if not ConfirmYesNo('Azzerare ordine, larghezza e visibilita'' delle colonne?', mtWarning) then
    Exit;

  FzDbTreeProps.Columns.Reset(FDataController.zFbDataSet);
  RebuildColumns;
end;

procedure TzDbTree.SalvaImpostazioniExecute(Sender: TObject);
begin
  doSalvaImpostazioni;
end;

procedure TzDbTree.CaricaImpostazioniExecute(Sender: TObject);
begin
  if ConfirmYesNo('Ricarico le impostazioni salvate?') then
    ReloadProps;
end;

procedure TzDbTree.actSQLExecute(Sender: TObject);
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzSystem.DataSetEditProps(zDataSet) then
  begin
    CaptureExpansion;
    FDataController.OpenDataSet;
    ResolveHierarchyFields;
    RebuildColumns;
  end;
end;

procedure TzDbTree.MostraQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
    ConfirmOk(FDataController.GetDebugInfo);
end;

procedure TzDbTree.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
  begin
    Clipboard.AsText := FDataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbTree.CopyNameExecute(Sender: TObject);
begin
  Clipboard.AsText := TreeID;
  ConfirmOk(TreeID);
end;

procedure TzDbTree.NomeFileIniExecute(Sender: TObject);
begin
  Clipboard.AsText := LayoutFileName;
  ConfirmOk(LayoutFileName);
end;

procedure TzDbTree.EditToolsExecute(Sender: TObject);
begin
  ExecuteToolConfig;
end;

procedure TzDbTree.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

procedure TzDbTree.dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
begin
  if IsAdmin then
    popTree.PopupFromCursorPos;
end;

procedure TzDbTree.PopupTreePopup(Sender: TObject);
begin
  dxBarSubItemImpostazioni.Visible := dx.Visible(IsAdmin);
  dxBarEditTitolo.Visible := dx.Visible(IsAdmin);
  CopyName.Caption := 'Copia TreeID - ' + TreeID;
end;

// ---------------------------------------------------------------------------
// Larghezze, menu delle intestazioni e collegamenti (come in TzDbView)
// ---------------------------------------------------------------------------

procedure TzDbTree.ApplyBestFit;
var
  i: Integer;
begin
  if not FDataController.IsActive then
    Exit;

  // TzDbView misura solo le colonne a video e con Ctrl tutte: le intestazioni
  // dell'albero non sono raggiungibili senza le parti protette di DevExpress,
  // e un albero ha poche colonne. Si misurano tutte quelle visibili, sui nodi
  // aperti (i figli chiusi non si vedono e non contano)
  StartWait('Attendere...');
  try
    cxDBTreeList.BeginUpdate;
    try
      for i := 0 to cxDBTreeList.VisibleColumnCount - 1 do
        cxDBTreeList.VisibleColumns[i].ApplyBestFit;
    finally
      cxDBTreeList.EndUpdate;
    end;
  finally
    StopWait;
  end;
end;

procedure TzDbTree.CheckColumnWidths;
const
  // tetto all'allargamento automatico a 96 DPI, come in TzDbView
  LarghezzaMassima = 400;
var
  i: Integer;
  Colonne: TArray<TcxTreeListColumn>;
  Larghezze: TArray<Integer>;
  Tetto: Integer;
begin
  // come TzDbView.CheckColumnWidths: colonne tutte strette (layout perso o
  // creato a dataset chiuso) = si adattano al contenuto
  if not FBuilt or not FDataController.IsActive then
    Exit;

  if cxDBTreeList.VisibleColumnCount = 0 then
    Exit;

  // a ogni apertura, dopo il layout personale, le colonne si allargano
  // soltanto: la maggiore fra la larghezza del layout e quella misurata sui
  // nodi aperti, con il tetto (stessa regola di TzDbView). Albero vuoto = si
  // misurerebbero le sole intestazioni: si aspetta il prossimo caricamento
  if FAdattaLarghezzeInAttesa then
  begin
    if cxDBTreeList.OptionsView.ColumnAutoWidth then
    begin
      FAdattaLarghezzeInAttesa := False;
      Exit;
    end;

    if cxDBTreeList.Count = 0 then
      Exit;

    FAdattaLarghezzeInAttesa := False;

    SetLength(Colonne, cxDBTreeList.VisibleColumnCount);
    SetLength(Larghezze, cxDBTreeList.VisibleColumnCount);
    for i := 0 to High(Colonne) do
    begin
      Colonne[i] := cxDBTreeList.VisibleColumns[i];
      Larghezze[i] := Colonne[i].Width;
    end;

    Tetto := MulDiv(LarghezzaMassima, CurrentPPI, 96);

    cxDBTreeList.BeginUpdate;
    try
      for i := 0 to High(Colonne) do
      begin
        Colonne[i].ApplyBestFit;

        if Colonne[i].Width < Larghezze[i] then
          Colonne[i].Width := Larghezze[i]
        else
          if Colonne[i].Width > Tetto then
            Colonne[i].Width := Max(Larghezze[i], Tetto);
      end;
    finally
      cxDBTreeList.EndUpdate;
    end;

    // niente salvataggio: si ripete a ogni apertura, e il layout personale
    // lo scrive Destroy con le larghezze che l'utente lascia
    Exit;
  end;

  for i := 0 to cxDBTreeList.VisibleColumnCount - 1 do
    if cxDBTreeList.VisibleColumns[i].Width > 20 then
      Exit;

  ApplyBestFit;
end;

procedure TzDbTree.TreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitTest: TcxTreeListHitTest;
begin
  if Button <> mbLeft then
    Exit;

  HitTest := cxDBTreeList.HitTest;
  HitTest.HitPoint := Point(X, Y);

  // angolo dell'indicatore sopra i nodi: come in TzDbView, larghezze adattate
  // e layout personale salvato (con Ctrl solo adattate)
  if HitTest.HitAtIndicator and not HitTest.HitAtFooter and not Assigned(HitTest.HitNode) then
  begin
    ApplyBestFit;
    if not CtrlKey then
      SaveUserLayout;
  end;
end;

procedure TzDbTree.HeaderMenuClick(Sender: TcxCustomTreeList; AItem: TObject; var AHandled: Boolean);
begin
  // "Adatta tutte le colonne": la stessa procedura dell'azione
  if (AItem is TComponent) and (TComponent(AItem).Tag = tlcmBestFitAllColumns) then
  begin
    ApplyBestFit;
    AHandled := True;
  end;
end;

procedure TzDbTree.DoHyperLink(Sender: TObject);
begin
  if not FDataController.IsActive then
    Exit;

  OpenHyperLink(cxDBTreeList.FocusedColumn, cxDBTreeList.FocusedNode);
end;

procedure TzDbTree.TreeDblClick(Sender: TObject);
var
  HitTest: TcxTreeListHitTest;
begin
  // Colonna in sola lettura: il controllo non attiva l'editor e il clic sul
  // collegamento non arriva; come in TzDbView vale il doppio clic
  if not FDataController.IsActive then
    Exit;

  HitTest := cxDBTreeList.HitTest;
  HitTest.HitPoint := cxDBTreeList.ScreenToClient(Mouse.CursorPos);

  if not HitTest.HitAtColumn or not Assigned(HitTest.HitNode) or not Assigned(HitTest.HitColumn) then
    Exit;

  if HitTest.HitColumn.Properties is TcxCustomHyperLinkEditProperties then
  begin
    // colonna modificabile: il clic singolo ha gia' aperto il collegamento
    if cxDBTreeList.OptionsData.Editing and HitTest.HitColumn.Options.Editing then
      Exit;

    OpenHyperLink(HitTest.HitColumn, HitTest.HitNode);
    Exit;
  end;

  // con la scheda il doppio clic apre il record, come in TzDbView; su una
  // cella modificabile resta alla cella
  if not UsesCard then
    Exit;

  if cxDBTreeList.OptionsData.Editing and HitTest.HitColumn.Options.Editing then
    Exit;

  if LocateFocusedNode then
    ShowCard(False);
end;

procedure TzDbTree.OpenHyperLink(Column: TcxTreeListColumn; Node: TcxTreeListNode);
var
  Value: Variant;
begin
  if not Assigned(Column) or not Assigned(Node) then
    Exit;

  if not(Column.Properties is TcxCustomHyperLinkEditProperties) then
    Exit;

  // il valore dal nodo, non dal record corrente: senza SyncDataSet il dataset
  // puo' stare su un altro record
  Value := Column.Values[Node];

  if VarIsNull(Value) or VarIsEmpty(Value) then
    Exit;

  FHyperLinkFieldName := TcxCustomHyperLinkEditProperties(Column.Properties).Prefix;
  FHyperLinkValue := Value;

  // in differita: la form che si apre non deve nascere dentro il clic
  PostInternalMessage(tcHyperLink);
end;

// ---------------------------------------------------------------------------
// Scheda del record (come in TzDbView)
// ---------------------------------------------------------------------------

function TzDbTree.UsesCard: Boolean;
begin
  result := Assigned(FOnShowCard) or FzDbTreeProps.Flags.EditInCard;
end;

procedure TzDbTree.SetOnShowCard(const Value: TzShowCardEvent);
begin
  FOnShowCard := Value;

  // la form lo assegna di solito dopo le props: il doppio clic va riallineato
  cxDBTreeList.OptionsBehavior.ExpandOnDblClick := not UsesCard;
end;

function TzDbTree.GetCardDlg: TzDbCardDlg;
begin
  // al primo uso: il frame vive anche nel .dfm delle form, e un componente
  // creato nel costruttore finirebbe scritto nel .dfm
  if not Assigned(FCardDlg) then
    FCardDlg := TzDbCardDlg.Create(Self);

  result := FCardDlg;
end;

function TzDbTree.EffectiveCardID: string;
begin
  result := Trim(FCardID);

  if result = '' then
    result := FDataController.IdDataSet;
end;

function TzDbTree.LocateFocusedNode: Boolean;
begin
  result := Assigned(cxDBTreeList.FocusedNode);

  if not result then
    Exit;

  // con SyncMode spento il record corrente puo' non essere quello del nodo:
  // Locate in memoria, UseSqlLocate e' spento finche' l'albero e' legato
  if not FzDbTreeProps.Flags.SyncDataSet then
    result := FzDataSet.Locate(FKeyFieldName, FocusedKey, []);
end;

procedure TzDbTree.InsertNode(const ParentKey: Variant);
begin
  if not UsesCard then
  begin
    InsertWithParent(ParentKey);
    Exit;
  end;

  // scheda della form: inserimento e padre li gestisce lei
  if Assigned(FOnShowCard) then
  begin
    FInsertParentKey := ParentKey;
    ShowCard(True);
    Exit;
  end;

  InsertWithParent(ParentKey);

  if FDataController.DataSetState = dsInsert then
    ShowCard(True);
end;

function TzDbTree.ShowCard(const Inserting: Boolean): Boolean;
begin
  result := False;

  // il doppio clic e l'azione possono arrivare insieme
  if FShowingCard then
    Exit;

  FShowingCard := True;
  try
    if Assigned(FOnShowCard) then
    begin
      FOnShowCard(Self, Inserting);
      result := True;
      Exit;
    end;

    if not FDataController.IsActive then
      Exit;

    if FDataController.IsEmpty and not Inserting then
      Exit;

    CardDlg.zSystem := zSystem;
    CardDlg.DataSet := zDataSet;
    CardDlg.CardID := EffectiveCardID;
    CardDlg.ReadOnly := IsTreeReadOnly;

    result := CardDlg.Execute;

    // come TzDbView.ShowRecord: confermata si scrive, annullata si scarta
    if result then
      FDataController.CheckBrowseMode
    else
      if FDataController.IsEditing then
        FDataController.Cancel;
  finally
    FShowingCard := False;
  end;
end;

function TzDbTree.ShowRecord(const doInsert: Boolean): Boolean;
begin
  result := False;

  if doInsert then
  begin
    if Assigned(FOnShowCard) then
      FInsertParentKey := FocusedParentKey
    else
    begin
      InsertSibling;
      if FDataController.DataSetState <> dsInsert then
        Exit;
    end;
  end
  else
    if not Assigned(FOnShowCard) and not LocateFocusedNode then
      Exit;

  result := ShowCard(doInsert);
end;
end.
