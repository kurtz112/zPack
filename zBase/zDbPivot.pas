unit zDbPivot;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.ImageList,
  System.Actions,
  System.IOUtils,
  System.Variants,
  System.Classes,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Grids,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.DBActns,
  Vcl.StdActns,
  Vcl.ImgList,
  Generics.Collections,
  ToolWin,
  ComCtrls,
  StdCtrls,
  Mask,
  ExtActns,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  dxBar,
  cxClasses,
  cxLabel,
  dxBarExtItems,
  cxPropertiesStore,
  ActionListController,
  zFocusedAction,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  dxSkinscxPCPainter,
  cxImageList,
  cxCheckGroup,
  cxBarEditItem,
  cxCheckBox,
  cxTextEdit,
  cxStyles,
  cxCustomData,
  cxData,
  cxDataStorage,
  cxDBData,
  zFbDataSet,
  zBaseLib,
  zSystem,
  zToolActions,
  zBase.Types,
  zDataController,
  dxBarBuiltInMenu,
  cxFilter,
  cxFilterControl,
  cxCustomPivotGrid,
  cxDBPivotGrid,
  cxExportPivotGridLink,
  dxCore,
  dxFileActions,
  dxUIAClasses,
  zDescription,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  cxGeometry,
  dxFramedControl,
  dxPanel,
  zToolFilter,
  zToolFilterHelper;

type
  TzDbPivotCommand = (cmd_UpdateActions, cmd_DisplayToolbars, cmd_ApplyBestFit, cmd_SaveZip, cmd_AdattaLarghezze, cmd_ExpandInnerLevels);

  TActionEvent = procedure(Sender: TObject; var Continue: Boolean) of object;
  TShowCardEvent = procedure(Sender: TObject; Inserting: Boolean) of object;

  // Le azioni del .dfm sono TzFocusedAction (unit zFocusedAction): con il fuoco
  // nel pivot le scorciatoie restano al pivot anche quando l'azione e'
  // disabilitata, e le zDbView della stessa form non se le prendono.
  // Doppio clic su una cella dati. Handled = True blocca il drill-down standard
  // (Flags.DrillDown); CrossCell resta valida solo per la durata della chiamata.
  TzPivotCellDblClickEvent = procedure(Sender: TObject; CrossCell: TcxPivotGridCrossCell; var Handled: Boolean) of object;

  // Doppio clic su un'intestazione di gruppo, di riga o di colonna
  // (distinguibili con GroupItem.Field.Area). Handled è riservato a una
  // eventuale azione standard futura: oggi non ce n'è nessuna.
  TzPivotGroupHeaderDblClickEvent = procedure(Sender: TObject; GroupItem: TcxPivotGridGroupItem; var Handled: Boolean) of object;

  TzDbPivotCalcFieldEntry = record
    FieldName: string; // Name dell'item in zDbPivotProps.Fields: va risolto ad ogni uso,
    // mai conservare il riferimento (AssignFromPivotFields ricrea gli item)
    PivotField: TcxDBPivotGridField; // field creato nel pivot
    SourceField: TcxDBPivotGridField; // field sorgente (stSum)
    ColCache: TArray<TcxPivotGridGroupItem>; // cache grouping item colonne
    ColCacheDirty: Boolean;
  end;

  // Campo e valore su cui agiscono i filtri rapidi (F3, Solo questo, Escludi questo).
  // Si conservano campo e valore, mai il TcxPivotGridGroupItem: i group item
  // vengono ricreati a ogni ricalcolo del pivot.
  // HasValue distingue "campo con un valore da proporre" da "solo il campo":
  // F3 su una riga di gruppo (es. la tipologia) filtra il campo piu' interno
  // (es. il progetto) ma non ha un suo valore da proporre. Solo questo ed
  // Escludi questo richiedono un valore.
  TzPivotFilterTarget = record
    Field: TcxDBPivotGridField;
    Value: Variant;
    DisplayText: string;
    HasValue: Boolean;
    function IsValid: Boolean;
  end;

  TzDbPivot = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzShortCutConsumer)
    actDbFirst: TzFocusedAction;
    actDbLast: TzFocusedAction;
    actDbNext: TzFocusedAction;
    actDbPrior: TzFocusedAction;
    actDbRefresh: TDataSetRefresh;
    ActionList: TActionList;
    actPersonalizza: TzFocusedAction;
    actSQL: TzFocusedAction;
    DataSource: TDataSource;
    EditCopy: TEditCopy;
    EditCut: TEditCut;
    EditDelete: TEditDelete;
    EditPaste: TEditPaste;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    SelezionaCampi: TzFocusedAction;
    Incolonna: TzFocusedAction;
    SalvaImpostazioni: TzFocusedAction;
    Elabora: TzFocusedAction;
    CaricaImpostazioni: TzFocusedAction;
    dxBarManager: TdxBarManager;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
    Titolo: TcxLabel;
    dxBarButtonIncolonna: TdxBarButton;
    dxBarButtonSalvaImpostazioni: TdxBarButton;
    dxBarButtonCaricaImpostazioni: TdxBarButton;
    dxBarButtonSelezionaColonne: TdxBarButton;
    dxBarButtonactSQL: TdxBarButton;
    dxBarButtonactDbFirst: TdxBarButton;
    dxBarButtonactDbPrior: TdxBarButton;
    dxBarButtonactDbNext: TdxBarButton;
    dxBarButtonactDbLast: TdxBarButton;
    dxBarButtonactPersonalizza: TdxBarButton;
    dxBarButtonactDbRefresh: TdxBarButton;
    dxBarButtonactExcel: TdxBarButton;
    dxBarButtonParametri: TdxBarButton;
    dxBarButtonEditUndo: TdxBarButton;
    dxBarButtonEditCut: TdxBarButton;
    dxBarButtonEditCopy: TdxBarButton;
    dxBarButtonEditPaste: TdxBarButton;
    dxBarButtonEditDelete: TdxBarButton;
    dxBarButtonEditSelectAll: TdxBarButton;
    dxBarToolbar: TdxBar;
    popPivot: TdxBarPopupMenu;
    popField: TdxBarPopupMenu;
    dxBarToolbarFree: TdxBar;
    actPersonalizzaColonna: TzFocusedAction;
    dxBarButton1: TdxBarButton;
    actResetColonne: TzFocusedAction;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    MostraQueryUtilizzata: TzFocusedAction;
    CopiaQueryUtilizzata: TzFocusedAction;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarEditTitolo: TcxBarEditItem;
    CopyName: TzFocusedAction;
    dxBarButton10: TdxBarButton;
    actExcel: TdxFileSaveAs;
    ClearIniSectionAllUsers: TzFocusedAction;
    dxBarButton8: TdxBarButton;
    dxBarButton11: TdxBarButton;
    NomeFileIni: TzFocusedAction;
    cxDBPivotGrid: TcxDBPivotGrid;
    Espandi: TzFocusedAction;
    Riduci: TzFocusedAction;
    dxBarButton4: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    cxStyleRepository: TcxStyleRepository;
    cxStyleRed: TcxStyle;
    cxStyleBold: TcxStyle;
    pnlDescrizione: TdxPanel;
    Descrizione: TzFocusedAction;
    dxBarButton15: TdxBarButton;
    EditTools: TzFocusedAction;
    dxBarButton16: TdxBarButton;
    actFiltroPerValore: TzFocusedAction;
    actFiltriAvanzati: TzFocusedAction;
    actEliminaFiltri: TzFocusedAction;
    actSoloQuestoValore: TzFocusedAction;
    actEscludiQuestoValore: TzFocusedAction;
    dxBarButtonactFiltroPerValore: TdxBarButton;
    dxBarButtonactFiltriAvanzati: TdxBarButton;
    dxBarButtonactEliminaFiltri: TdxBarButton;
    dxBarButtonactSoloQuestoValore: TdxBarButton;
    dxBarButtonactEscludiQuestoValore: TdxBarButton;
    procedure actDbRefreshExecute(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    procedure DataSourceStateChange(Sender: TObject);
    procedure IncolonnaExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure actDbCancelExecute(Sender: TObject);
    procedure actDbFirstExecute(Sender: TObject);
    procedure actDbLastExecute(Sender: TObject);
    procedure actDbNextExecute(Sender: TObject);
    procedure actDbPostExecute(Sender: TObject);
    procedure actDbPriorExecute(Sender: TObject);
    procedure actPersonalizzaColonnaExecute(Sender: TObject);
    procedure actResetColonneExecute(Sender: TObject);
    procedure CaricaImpostazioniExecute(Sender: TObject);
    procedure CopiaQueryUtilizzataExecute(Sender: TObject);
    procedure CopyNameExecute(Sender: TObject);
    procedure dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
    procedure PopupGridPopup(Sender: TObject);
    procedure MostraQueryUtilizzataExecute(Sender: TObject);
    procedure PopupOptionsPopup(Sender: TObject);
    procedure dxBarEditTitoloChange(Sender: TObject);
    procedure actExcelAccept(Sender: TObject);
    procedure actExcelBeforeExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure ClearIniSectionAllUsersExecute(Sender: TObject);
    procedure cxDBPivotGridClick(Sender: TObject);
    procedure cxDBPivotGridDblClick(Sender: TObject);
    procedure ElaboraExecute(Sender: TObject);
    procedure EspandiExecute(Sender: TObject);
    procedure NomeFileIniExecute(Sender: TObject);
    procedure RiduciExecute(Sender: TObject);
    procedure SelezionaCampiExecute(Sender: TObject);
    procedure cxDBPivotGridStylesGetContentStyle(Sender: TcxCustomPivotGrid; ACell: TcxPivotGridDataCellViewInfo; var AStyle: TcxStyle);
    procedure DescrizioneExecute(Sender: TObject);
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
    procedure actFiltroPerValoreExecute(Sender: TObject);
    procedure actFiltriAvanzatiExecute(Sender: TObject);
    procedure actEliminaFiltriExecute(Sender: TObject);
    procedure actSoloQuestoValoreExecute(Sender: TObject);
    procedure actEscludiQuestoValoreExecute(Sender: TObject);
  private
    UpdatingFilter: Boolean;
    FOnDelete: TActionEvent;
    FOnEdit: TActionEvent;
    FOnInsert: TActionEvent;
    FOnUpdateActions: TNotifyEvent;
    FOnCellDblClick: TzPivotCellDblClickEvent;
    FOnGroupHeaderDblClick: TzPivotGroupHeaderDblClickEvent;
    FSearchFieldName: string;
    FzDataSet: TzFbDataSet;
    FzSystem: TzSystem;
  private // Metodi IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
    FToolActions: TzToolActions;
    function GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
    procedure SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
    function GetToolFilters: TzToolFiltersProps; // IzBaseComponent.GetToolFilters
    procedure SetToolFilters(const Value: TzToolFiltersProps); // IzBaseComponent.SetToolFilters
    function GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
    procedure SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
    function GetID: string; // IzBaseComponent.GetID
    procedure SetID(const Value: string); // IzBaseComponent.SetID
    function GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
    function GetToolbar: TdxBar; // IzBaseComponent.GetToolbar — barra unica filtri+azioni
  private // Metodi IzBaseComponent (config azioni) / IzBaseFilterableComponent (config filtri)
    function GetProps: TzBaseComponentProps;
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    procedure RebuildFilters;
    procedure RebuildToolbar; // IzBaseComponent.RebuildToolbar — filtri poi azioni
    function ConfigTitle: string;
  private
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: Boolean;
    function IsAdmin: Boolean;
  private
    FCalcEntries: TArray<TzDbPivotCalcFieldEntry>;
    procedure CreateCalcFields;
    procedure InvalidateCalcColCaches;
    function ResolvezPivotField(const FieldName: string): TzPivotField;
    function GetCalcColGroupItems(var Entry: TzDbPivotCalcFieldEntry): TArray<TcxPivotGridGroupItem>;
    function SumColumnCells(RowItem: TcxPivotGridGroupItem; const ColumnItems: TArray<TcxPivotGridGroupItem>; Field: TcxPivotGridField; SummaryType: TcxPivotGridSummaryType): Double;
    procedure CalcFieldCustomSummary(Sender: TcxPivotGridField; ASummary: TcxPivotGridCrossCellSummary);
    procedure GrandTotalExcludeSummary(Sender: TcxPivotGridField; ASummary: TcxPivotGridCrossCellSummary);
    procedure PivotLayoutChanged(Sender: TObject);
  private
    procedure CreateFiltersFromProps;
  private // Filtri rapidi in memoria: F3, F4, Ctrl+Backspace, Solo questo, Escludi questo
    FiltroDelMenu: TzPivotFilterTarget; // bersaglio catturato all'apertura del menu contestuale
    procedure PivotKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function CanFilter: Boolean;
    function InnermostRowField: TcxDBPivotGridField;
    function FilterTargetFromRow(RowItem: TcxPivotGridViewDataItem): TzPivotFilterTarget;
    function FilterTargetFromGroupItem(GroupItem: TcxPivotGridGroupItem): TzPivotFilterTarget;
    function FocusedFilterTarget: TzPivotFilterTarget;
    function PopupFilterTarget: TzPivotFilterTarget;
    function InputFilterValue(const Target: TzPivotFilterTarget; out Value: Variant; out OperatorKind: TcxFilterOperatorKind): Boolean;
    procedure FilterByValue(const Target: TzPivotFilterTarget);
    procedure FilterByText(PivotField: TcxDBPivotGridField; const Testo: string; const Contiene: Boolean);
    procedure ShowFilteredValues(PivotField: TcxDBPivotGridField);
    procedure FocusFirstFilteredValue(const FieldName: string);
    procedure SetFilterCondition(PivotField: TcxDBPivotGridField; OperatorKind: TcxFilterOperatorKind; const Value: Variant);
    procedure KeepOnlyValue(const Target: TzPivotFilterTarget);
    procedure ExcludeValue(const Target: TzPivotFilterTarget);
    procedure OpenFilterDialog;
    procedure ClearFilters;
  private
    ActionListController: TActionListController;
    procedure ToolActionsChanged(Sender: TObject);

    procedure DisplayToolbars;
    procedure UpdateActions;
    procedure UpdateExpandCaptions;

    procedure PostInternalMessage(const cmd: TzDbPivotCommand);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBPIVOT;
  private
    FDataController: TzDataController;
    function IniFileName: string;
  private
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  private
    procedure LoadProperties(const LoadDefaults: Boolean);
  private
    FOnAfterCreateControls: TNotifyEvent;
    FOnBeforeCreateControls: TNotifyEvent;
  private
    FzDbPivotProps: TzDbPivotProps;
    maxWidths: TDictionary<TcxDBPivotGridField, integer>;
    procedure InitPivot;

    procedure CreateFields;
    procedure DestroyFields;
    procedure CheckFieldWidths;
  private
    // collegamento al DataSource che avvisa solo per apertura e ricarica dei
    // dati, non per lo scorrimento (OnDataChange non li distingue)
    FDataLinkLarghezze: TDataLink;
    FAdattaLarghezzeInCoda: Boolean;
    // dati arrivati quando il pivot non aveva ancora la finestra (frame non
    // ancora inserito nella form): si adatta alla prima visualizzazione
    FAdattaLarghezzeRinviata: Boolean;
    procedure AdattaLarghezzeCampi;
    procedure AllargaCampiRigaAlTesto;
    procedure AllargaCampiRigaSulleCelle;
    procedure DatiCaricati;
    procedure AdattaLarghezzeDopoCaricamento;
  private
    FrameDescription: TFrameDescription;
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private
    procedure OnFlagChange(Sender: TObject);
    function GetPivotID: string;
    procedure SetPivotID(const Value: string);
  protected
    AlreadyShown: Boolean;
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
  private
    FIsDestroying: Boolean;
    FSaveZipQueued: Boolean;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    function GetFlags: TzDbPivotFlags;
    function GetDataSourceEnabled: Boolean;
    procedure SetDataSourceEnabled(const Value: Boolean);
    property IsDestroying: Boolean read FIsDestroying;
  private
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
    procedure doSalvaImpostazioni(const Silent: Boolean = False);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure ActivateDataSet;
    procedure ApplyBestFit;
    procedure FullExpand;
    procedure FullCollapse;
    procedure ExpandInnerLevels;

    function FieldByName(const FieldName: string): TcxDBPivotGridField;

    // Drill-down: elenco dei record sottostanti una cella dati.
    // Richiamato dal doppio clic quando Flags.DrillDown è attivo e
    // OnCellDblClick non ha gestito; utilizzabile anche da codice.
    procedure ShowDrillDown(CrossCell: TcxPivotGridCrossCell);

    // Valore di un campo di servizio (es. ID nascosto) sul record
    // rappresentativo di un gruppo di riga/colonna.
    function GetGroupItemValue(GroupItem: TcxPivotGridGroupItem; const FieldName: string): Variant;

    // Chiavi primarie (KeyFieldNames) dei record sottostanti una cella dati.
    function GetCrossCellKeys(CrossCell: TcxPivotGridCrossCell): TArray<Variant>;

    // Scrive nelle props la lista dei valori di colonna esclusi dal totale
    // generale del campo e, se i field sono già creati, applica subito.
    procedure SetGrandTotalExclusions(const FieldName: string; const ExcludeValues: array of string);

    procedure InitToolActions;
    procedure ExecuteToolConfig;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
  public
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
  public
    //
    function GetTitle: string;
    procedure SetTitle(const Title: string);
    procedure ReloadColumnProps;
  public
    property DataController: TzDataController read FDataController;
  published
    property OnUpdateActions: TNotifyEvent read FOnUpdateActions write FOnUpdateActions;
  published
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write FOnBeforeCreateControls;
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write FOnAfterCreateControls;
    property OnCellDblClick: TzPivotCellDblClickEvent read FOnCellDblClick write FOnCellDblClick;
    property OnGroupHeaderDblClick: TzPivotGroupHeaderDblClickEvent read FOnGroupHeaderDblClick write FOnGroupHeaderDblClick;
  public
    property PivotID: string read GetPivotID write SetPivotID;
    property Flags: TzDbPivotFlags read GetFlags;
    property zDbPivotProps: TzDbPivotProps read FzDbPivotProps;

    property DataSourceEnabled: Boolean read GetDataSourceEnabled write SetDataSourceEnabled;
  published
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write FOnCustomSaveProps;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write FOnCustomLoadProps;
  published
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  end;

implementation

uses
  Winapi.ShellAPI,
  System.TypInfo,
  System.Threading,
  System.IniFiles,
  System.DateUtils,
  Data.DBConsts,
  Vcl.Clipbrd,
  cxFormats,
  cxGrid,
  cxGridLevel,
  cxGridTableView,
  cxImageComboBox,
  zDX,
  zFrmInspector,
  zMsg,
  zFrmParams,
  zLocalizer,
  zz.base.editor._form,
  zToolConfigDlg,
  zToolFilter.Builder,
  zDbView.Filter;

{$R *.dfm}

var
  siDbPivot: TSiSession;

type
  TcxPivotGridViewDataAccess = class(TcxPivotGridViewData);
  TcxPivotGridAccess = class(TcxDBPivotGrid);
  TcxPivotGridHeaderCellViewInfoAccess = class(TcxPivotGridHeaderCellViewInfo);

  // DataSetChanged arriva per apertura, Refresh e riapertura (anche quella di
  // TzDataController.DoRefresh fra DisableControls ed EnableControls), mentre
  // lo scorrimento passa da DataSetScrolled, che qui non si ridefinisce
  TzDbPivotDataLink = class(TDataLink)
  private
    FPivot: TzDbPivot;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
  public
    constructor Create(aPivot: TzDbPivot);
  end;

constructor TzDbPivotDataLink.Create(aPivot: TzDbPivot);
begin
  inherited Create;
  FPivot := aPivot;
end;

procedure TzDbPivotDataLink.ActiveChanged;
begin
  if Active then
    FPivot.DatiCaricati;
end;

procedure TzDbPivotDataLink.DataSetChanged;
begin
  FPivot.DatiCaricati;
end;

function TzDbPivot.GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
begin
  result := ctPivot;
end;

function TzDbPivot.GetToolbar: TdxBar; // IzBaseComponent.GetToolbar — barra unica filtri+azioni
begin
  result := dxBarToolbarFree;
end;

function TzDbPivot.GetID: string; // IzBaseComponent.GetID
begin
  result := PivotID;
end;

procedure TzDbPivot.SetID(const Value: string); // IzBaseComponent.SetID
begin
  PivotID := Value;
end;

function TzDbPivot.GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
begin
  result := FToolActions;
end;

function TzDbPivot.GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
begin
  result := FzDataSet;
end;

constructor TzDbPivot.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FrameDescription := nil;
  FIsDestroying := False;
  FSaveZipQueued := False;
  UpdatingFilter := False;
  AlreadyShown := False;
  FOnUpdateActions := nil;
  FOnCellDblClick := nil;
  FOnGroupHeaderDblClick := nil;
  Titolo.Visible := False;

  SetLength(FCalcEntries, 0);
  cxDBPivotGrid.OnLayoutChanged := PivotLayoutChanged;

  maxWidths := TDictionary<TcxDBPivotGridField, integer>.Create;
  FzDbPivotProps := TzDbPivotProps.Create(nil);
  FDataController := TzDataController.Create(Self);

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;
  //
  FzDataSet := nil;

  FOnBeforeCreateControls := nil;
  FOnAfterCreateControls := nil;

  FOnCustomSaveProps := nil;
  FOnCustomLoadProps := nil;

  ActionListController := TActionListController.Create;

  dxBarControlContainerTitolo.Visible := dx.Visible(False);

  Titolo.PopupMenu := popPivot;

  dxBarToolbar.MultiLine := true; // collegato a resize
  dxBarToolbarFree.MultiLine := true; // collegato a resize

  dx.InitTitle(Titolo);

  dx.InitPivot(cxDBPivotGrid);

  // Prefiltro senza distinzione di maiuscole, come zDbView: senza l'opzione
  // "inizia per" e "contiene" distinguono ROMA da Roma (default DevExpress = []).
  // fcoShowOperatorDescription: la barra del prefiltro scrive "inizia per", non LIKE.
  cxDBPivotGrid.DataController.Filter.Options := cxDBPivotGrid.DataController.Filter.Options + [fcoCaseInsensitive, fcoShowOperatorDescription];

  // F3, F4 e Ctrl+Backspace si intercettano sulla griglia e non come ShortCut
  // delle azioni: le ActionList dei frame le smista la form, prima del controllo
  // con il fuoco, e un'azione con F3 ruberebbe il tasto alle zDbView della stessa form.
  cxDBPivotGrid.OnKeyDown := PivotKeyDown;
  FiltroDelMenu := Default(TzPivotFilterTarget);

  FAdattaLarghezzeInCoda := False;
  FAdattaLarghezzeRinviata := False;
  FDataLinkLarghezze := TzDbPivotDataLink.Create(Self);
  FDataLinkLarghezze.DataSource := DataSource;

  UpdateActions;
end;

destructor TzDbPivot.Destroy;
begin
  FIsDestroying := true;

  // scrittura zip rimasta in coda: il messaggio postato non verrà più recapitato
  if FSaveZipQueued then
  begin
    FSaveZipQueued := False;
    if zSystemOk then
      zSystem.SaveZip(csDbPivots, 'TzDbPivot.Destroy');
  end;

  // prima dei campi e del DataSource: un avviso arrivato durante la
  // distruzione non deve trovare il pivot a meta'
  FreeAndNil(FDataLinkLarghezze);

  FreeAndNil(FrameDescription);
  FreeAndNil(maxWidths);
  FreeAndNil(ActionListController);

  FreeAndNil(FDataController);

  FreeAndNil(FToolActions);
  FreeAndNil(FzDbPivotProps);
  inherited;
end;

procedure TzDbPivot.actDbRefreshExecute(Sender: TObject);
begin

  actDbRefresh.Enabled := False;
  try
    DataController.Refresh;
  finally
    actDbRefresh.Enabled := true;
  end;
end;

procedure TzDbPivot.actSQLExecute(Sender: TObject);
begin
  if not DataController.DataSetOk then
    Exit;

  /// //////////////
  if zSystem.DataSetEditProps(zDataSet) then
  begin
    DestroyFields;
    DataController.OpenDataSet;
    InitPivot;
  end;
end;

procedure TzDbPivot.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  PostInternalMessage(cmd_UpdateActions);
end;

procedure TzDbPivot.DataSourceStateChange(Sender: TObject);
begin
  PostInternalMessage(cmd_UpdateActions);
end;

procedure TzDbPivot.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FzSystem) then
    zSystem := nil;

  if (Operation = opRemove) and (AComponent = FzDataSet) then
    zDataSet := nil;

  if (Operation = opRemove) then
    if ((AComponent is TAction) or (AComponent is TImageList)) then
      if Assigned(ToolActions) then
        ToolActions.RemoveNotification(AComponent);
end;

procedure TzDbPivot.ReloadColumnProps;
begin
  // DIV-PVT-2: applica alla griglia i campi appena azzerati
  FzDbPivotProps.Fields.AssignToPivotFields(cxDBPivotGrid);
end;

procedure TzDbPivot.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
  InitPivot;
end;

function TzDbPivot.zSystemOk: Boolean;
begin
  result := Assigned(FzSystem);
end;

procedure TzDbPivot.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

procedure TzDbPivot.IncolonnaExecute(Sender: TObject);
begin
  ApplyBestFit;
end;

function TzDbPivot.IsAdmin: Boolean;
begin
  result := False;
  if Assigned(zSystem) then
    result := zSystem.IsAdmin;
end;

function TzDbPivot.FieldByName(const FieldName: string): TcxDBPivotGridField;
var
  i: integer;
  Field: TcxDBPivotGridField;
begin
  result := nil;

  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
  begin
    Field := TcxDBPivotGridField(cxDBPivotGrid.Fields[i]);

    if AnsiCompareText(Field.DataBinding.FieldName, FieldName) = 0 then
    begin
      result := Field;
      Break;
    end;
  end;
end;

procedure TzDbPivot.FullCollapse;
var
  i: integer;
begin
  // Con i flag ExpandRows ed ExpandColumns la griglia DevExpress considera
  // aperto ogni gruppo con figli, qualunque sia il suo stato
  // (TcxPivotGridGroupItem.GetExpanded): senza spegnerli CollapseAll non
  // cambia niente a video. Chi chiede Riduci vuole i gruppi chiusi, quindi i
  // flag si spengono; Espandi li rimette come li vuole la pivot. Una pivot che
  // non deve mai ridursi nasconde i pulsanti con Flags.ButtonExpand.
  TcxPivotGridViewDataAccess(cxDBPivotGrid.ViewData).ExpandRows := False;
  TcxPivotGridViewDataAccess(cxDBPivotGrid.ViewData).ExpandColumns := False;

  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    cxDBPivotGrid.Fields[i].CollapseAll;

  ApplyBestFit;
end;

procedure TzDbPivot.FullExpand;
var
  i: integer;
begin
  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    cxDBPivotGrid.Fields[i].ExpandAll;

  // Dopo un Riduci i flag sono spenti: si rimettono come da proprieta' della
  // pivot, cosi' i gruppi restano aperti anche dopo un ricaricamento dei dati
  TcxPivotGridViewDataAccess(cxDBPivotGrid.ViewData).ExpandRows := FzDbPivotProps.Flags.ExpandRows;
  TcxPivotGridViewDataAccess(cxDBPivotGrid.ViewData).ExpandColumns := FzDbPivotProps.Flags.ExpandColumns;

  ApplyBestFit;
end;

procedure TzDbPivot.ExpandInnerLevels;
var
  i: integer;
  Field: TcxPivotGridField;
begin
  // Solo il primo livello delle righe si apre e si chiude a mano: i livelli
  // sotto di lui (per esempio riga, voce e descrizione, che hanno un solo valore
  // per ciascun valore del livello sopra) restano sempre aperti, cosi' una
  // sezione aperta mostra subito tutto il suo dettaglio.
  cxDBPivotGrid.BeginUpdate;
  try
    for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    begin
      Field := cxDBPivotGrid.Fields[i];

      if (Field.Area = faRow) and Field.Visible and (Field.AreaIndex > 0) then
        Field.ExpandAll;
    end;
  finally
    cxDBPivotGrid.EndUpdate;
  end;

  if FzDbPivotProps.BestFitAfterExpand then
    ApplyBestFit;
end;

procedure TzDbPivot.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

procedure TzDbPivot.SalvaImpostazioniExecute(Sender: TObject);
begin
  doSalvaImpostazioni;
end;

procedure TzDbPivot.actDbPostExecute(Sender: TObject);
begin
  DataController.CheckBrowseMode;
end;

procedure TzDbPivot.actDbCancelExecute(Sender: TObject);
begin
  DataController.Cancel;
end;

procedure TzDbPivot.CaricaImpostazioniExecute(Sender: TObject);
begin

  if ConfirmYesNo('Ricarico le impostazioni salvate?') then
    InternalLoadProperties;
end;

procedure TzDbPivot.PopupOptionsPopup(Sender: TObject);
begin
  if Assigned(zSystem) then
    if not zSystem.IsAdmin then
      System.SysUtils.Abort;
end;

procedure TzDbPivot.dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
begin
  if Assigned(zSystem) then
    if zSystem.IsAdmin then
      popPivot.PopupFromCursorPos;
end;

procedure TzDbPivot.ActivateDataSet;
begin
  if not DataController.DataSetOk then
    Exit;

  if DataController.IsActive then
    Exit;

  if DataController.AutoOpen then
  begin
    siDbPivot.LogString('zDbPivot.ActivateDataSet', zDataSet.Name);
    DataController.OpenDataSet;
  end;
end;

procedure TzDbPivot.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if DataController.DataSetOk then
  begin
    Clipboard.AsText := DataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbPivot.MostraQueryUtilizzataExecute(Sender: TObject);
begin
  if DataController.DataSetOk then
    ConfirmOk(DataController.GetDebugInfo);
end;

procedure TzDbPivot.CopyNameExecute(Sender: TObject);
begin
  Clipboard.AsText := PivotID;
  ConfirmOk(PivotID);
end;

function TzDbPivot.IniFileName: string;
begin
  result := base.PersonalFolder + ChangeFileExt(PivotID, '.pivot');
end;

procedure TzDbPivot.InitToolActions;
begin
  TzActionBuilder.BuildFromProps(zDbPivotProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(dxBarToolbarFree, popPivot, otView);
  DisplayToolbars;
end;

function TzDbPivot.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
var
  zDbPivotProps: TzToolActionsProps;
begin
  // Scrive sui props persistiti (sorgente unica); il runtime ToolActions viene
  // rigenerato da InitToolActions/BuildFromProps. FromCode protegge l'azione da
  // codice dall'Assign della LZ. ImageList ignorata (non persistibile; fallback).
  result := nil;
  if not Assigned(Action) then
    Exit;

  if GetProps = nil then
    Exit;

  result := GetProps.ToolActions.Find(Action.Name);
  if not Assigned(result) then
  begin
    result := GetProps.ToolActions.Add;
    result.Name := Action.Name;
  end;

  result.FromCode := true;
end;

function TzDbPivot.GetActionOwnerName: string;
begin
  result := zDbPivotProps.ActionOwnerName;
end;

procedure TzDbPivot.SetActionOwnerName(const Value: string);
begin
  zDbPivotProps.ActionOwnerName := Value;
end;

function TzDbPivot.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, zDbPivotProps.ActionOwnerName);
end;

procedure TzDbPivot.RebuildToolbar; // IzBaseComponent.RebuildToolbar — filtri poi azioni
begin
  // Prima i filtri, poi le azioni: i filtri precedono le azioni sulla barra.
  CreateFiltersFromProps;
  InitToolActions;
end;

procedure TzDbPivot.RebuildActions;
begin
  RebuildToolbar;
  doSalvaImpostazioni(true);
end;

procedure TzDbPivot.RebuildFilters;
begin
  RebuildToolbar;
  doSalvaImpostazioni(true);
end;

function TzDbPivot.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := PivotID;
end;

procedure TzDbPivot.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbPivot.dxBarEditTitoloChange(Sender: TObject);
begin
  FzDbPivotProps.Title := dxBarEditTitolo.EditValue;
  doSalvaImpostazioni;

  TThread.ForceQueue(nil,
    procedure
    begin
      if not IsDestroying then
        SetTitle(FzDbPivotProps.Title);
    end);
end;

function TzDbPivot.GetPivotID: string;
begin
  if FzDbPivotProps.Name = '' then
    FzDbPivotProps.Name := DataController.IdDataSet;

  result := FzDbPivotProps.Name;
end;

procedure TzDbPivot.SetPivotID(const Value: string);
begin
  FzDbPivotProps.Name := Value;
end;

procedure TzDbPivot.SetTitle(const Title: string);
begin
  Titolo.Caption := trim(Title);
  Titolo.Visible := Titolo.Caption <> '';
  dxBarControlContainerTitolo.Visible := dx.Visible(Titolo.Visible);

  dxBarEditTitolo.OnChange := Nil;
  try
    dxBarEditTitolo.EditValue := Titolo.Caption;
  finally
    dxBarEditTitolo.OnChange := dxBarEditTitoloChange;
  end;
end;

procedure TzDbPivot.ApplyBestFit;
begin

  if not DataController.IsActive then
    Exit;

  // sostituire con un ciclo for su quelle realmente visibili
  StartWait('Attendere...');
  try
    AdattaLarghezzeCampi;
  finally
    StopWait;
  end;
end;

procedure TzDbPivot.AdattaLarghezzeCampi;
var
  pair: TPair<TcxDBPivotGridField, integer>;

  procedure SetMaxWidth(Field: TcxDBPivotGridField; MaxWidth: integer);
  begin
    if MaxWidth > 0 then
      if Field.Width > MaxWidth then
        Field.Width := MaxWidth;
  end;

begin
  // corpo di ApplyBestFit senza la finestra di attesa, che per l'adattamento
  // automatico dopo ogni ricarica lampeggerebbe a vuoto
  cxDBPivotGrid.ApplyBestFit;
  AllargaCampiRigaAlTesto;
  AllargaCampiRigaSulleCelle;

  for pair in maxWidths do
    SetMaxWidth(pair.Key, pair.Value);
end;

procedure TzDbPivot.AllargaCampiRigaAlTesto;
const
  // spazio fra immagine e testo di TcxImageComboBox, a 96 DPI
  SpazioImmagine = 6;
  // cxTextOffset di DevExpress: distanza fra l'area del pulsante e il testo
  DistanzaTesto = 2;
  // bordi della cella (ExcludeBorders) e margini dell'editor in place
  // (ContentOffset 1,1,1,1) per le picklist
  Bordi = 2;
  MarginiEditor = 2;
var
  Larghezze: TDictionary<TcxPivotGridField, Integer>;
  Coppia: TPair<TcxPivotGridField, Integer>;
  Larghezza: Integer;
  Margini: TRect;
  SpazioPulsante: Integer;
  SpazioImmagineScalato: Integer;

  procedure Misura(Item: TcxPivotGridViewDataItem);
  var
    i: Integer;
    LarghezzaItem: Integer;
    Proprieta: TcxImageComboBoxProperties;
    Testo: string;
    Carattere: TFont;
  begin
    if Assigned(Item.Field) and (Item.Field.Area = faRow) and not Item.IsTotal and not Item.IsDataField and
      Assigned(Item.GroupItem) then
    begin
      Carattere := cxDBPivotGrid.Styles.GetRowHeaderParams(Item).Font;
      if not Assigned(Carattere) then
        Carattere := cxDBPivotGrid.Font;

      LarghezzaItem := Margini.Left + Margini.Right + Bordi;

      if Item.Field.Properties is TcxImageComboBoxProperties then
      begin
        Proprieta := TcxImageComboBoxProperties(Item.Field.Properties);
        Inc(LarghezzaItem, MarginiEditor);
        if Proprieta.ShowDescriptions then
          Testo := Proprieta.GetDisplayText(Item.GroupItem.Value)
        else
          Testo := '';
        if Assigned(Proprieta.Images) then
          Inc(LarghezzaItem, Proprieta.Images.Width + SpazioImmagineScalato);
      end
      else
        Testo := Item.Value;

      Inc(LarghezzaItem, cxTextWidth(Carattere, Testo));

      if Item.HasButton then
        Inc(LarghezzaItem, SpazioPulsante);

      if not Larghezze.TryGetValue(Item.Field, Larghezza) or (LarghezzaItem > Larghezza) then
        Larghezze.AddOrSetValue(Item.Field, LarghezzaItem);
    end;

    for i := 0 to Item.ItemCount - 1 do
      Misura(Item.Items[i]);
  end;

begin
  // ApplyBestFit misura le intestazioni di riga in modo diverso da come le
  // disegna, e il testo resta tagliato:
  // - usa il valore grezzo del gruppo (VarToStr), mentre la cella si disegna
  //   con le Properties del campo: con una picklist il codice 'F' diventa
  //   'Parte fissa';
  // - per le righe con pulsante di espansione conta RowLevelIndentWidth
  //   (pulsante + 8 pixel), mentre il testo comincia dopo l'area del pulsante
  //   (TcxPivotGridHeaderCellViewInfo.Calculate: FButtonAreaRect.Right +
  //   cxTextOffset + 2), che con le skin e' piu' larga del pulsante.
  // Qui ogni campo di riga si allarga (mai si stringe) fino a contenere il
  // testo come viene disegnato
  if cxDBPivotGrid.ViewData.RowCount = 0 then
    Exit;

  // nel layout compatto i campi di riga stanno in una colonna sola, larga
  // quanto decide la griglia
  if cxDBPivotGrid.OptionsView.RowTotalsLocation = rtlTree then
    Exit;

  // tipo dedotto: TdxScaleFactor senza aggiungere la sua unit alle uses
  var Scala := TcxPivotGridAccess(cxDBPivotGrid).ScaleFactor;
  Margini := cxDBPivotGrid.LookAndFeelPainter.HeaderContentOffsets(Scala);
  SpazioImmagineScalato := Scala.Apply(SpazioImmagine);
  // il pulsante parte dal margine sinistro e l'area e' centrata sul pulsante:
  // il testo comincia a meta' pulsante piu' meta' area
  SpazioPulsante :=
    (cxDBPivotGrid.LookAndFeelPainter.ScaledExpandButtonSize(Scala) +
     cxDBPivotGrid.LookAndFeelPainter.ScaledExpandButtonAreaSize(Scala) + 1) div 2 +
    Scala.Apply(DistanzaTesto) + 2;

  Larghezze := TDictionary<TcxPivotGridField, Integer>.Create;
  try
    Misura(cxDBPivotGrid.ViewData.Rows[0].Root);

    for Coppia in Larghezze do
      if Coppia.Value > Coppia.Key.Width then
        Coppia.Key.Width := Coppia.Value;
  finally
    Larghezze.Free;
  end;
end;

procedure TzDbPivot.AllargaCampiRigaSulleCelle;
const
  // spazio fra immagine e testo di TcxImageComboBox, a 96 DPI
  SpazioImmagine = 6;
  // cxTextOffset: con le Properties il testo si disegna in TextBounds
  // allargato di cxTextOffset per lato, meno ContentOffset 1 per lato
  DistanzaTesto = 2;
  MarginiEditor = 2;
var
  i: Integer;
  ViewInfo: TcxPivotGridViewInfo;
  Cella: TcxPivotGridHeaderCellViewInfo;
  Item: TcxPivotGridViewDataItem;
  Proprieta: TcxImageComboBoxProperties;
  Carattere: TFont;
  Testo: string;
  Disponibile: Integer;
  Necessario: Integer;
  Mancante: Integer;
  MancanteRegistrato: Integer;
  Mancanti: TDictionary<TcxPivotGridField, Integer>;
  Coppia: TPair<TcxPivotGridField, Integer>;
begin
  // AllargaCampiRigaAlTesto ricostruisce la misura dal sorgente DevExpress, e
  // con la skin non basta (zTicser, Componente e voce: 'DETRAZI...' sulla riga
  // aperta). Qui si legge lo spazio che la cella ha davvero per il testo
  // (TextBounds, dopo CheckVisibleInfo) e il campo si allarga della differenza.
  // Si misurano solo le righe a schermo: le altre celle non esistono.
  // Un passaggio solo: la cella si allarga quanto il campo, quindi la
  // differenza misurata basta, e una seconda misura potrebbe leggere celle
  // non ancora ricalcolate (pivot bloccato) e allargare due volte
  if cxDBPivotGrid.ViewData.RowCount = 0 then
    Exit;

  if cxDBPivotGrid.OptionsView.RowTotalsLocation = rtlTree then
    Exit;

  Mancanti := TDictionary<TcxPivotGridField, Integer>.Create;
  try
    ViewInfo := TcxPivotGridAccess(cxDBPivotGrid).ViewInfo;
    siDbPivot.LogMessage(Format('AllargaCampiRigaSulleCelle: %d celle di riga', [ViewInfo.RowHeaders.Count]));

    for i := 0 to ViewInfo.RowHeaders.Count - 1 do
    begin
      if not (ViewInfo.RowHeaders[i] is TcxPivotGridHeaderCellViewInfo) then
        Continue;

      Cella := TcxPivotGridHeaderCellViewInfo(ViewInfo.RowHeaders[i]);
      if not Cella.Visible then
        Continue;

      if not (TcxPivotGridHeaderCellViewInfoAccess(Cella).Data is TcxPivotGridViewDataItem) then
        Continue;

      Item := TcxPivotGridViewDataItem(TcxPivotGridHeaderCellViewInfoAccess(Cella).Data);
      if not Assigned(Item.Field) or (Item.Field.Area <> faRow) or Item.IsTotal or Item.IsDataField or
        not Assigned(Item.GroupItem) then
        Continue;

      // TextBounds si calcola solo al disegno
      Cella.CheckVisibleInfo;

      Carattere := Cella.Font;
      if not Assigned(Carattere) then
        Carattere := cxDBPivotGrid.Font;

      Disponibile := Cella.TextBounds.Right - Cella.TextBounds.Left;

      if Cella.Properties is TcxImageComboBoxProperties then
      begin
        Proprieta := TcxImageComboBoxProperties(Cella.Properties);
        if Proprieta.ShowDescriptions then
          Testo := Proprieta.GetDisplayText(Item.GroupItem.Value)
        else
          Testo := '';
        Inc(Disponibile, 2 * Cella.ScaleFactor.Apply(DistanzaTesto) - MarginiEditor);
        if Assigned(Proprieta.Images) then
          Dec(Disponibile, Proprieta.Images.Width + Cella.ScaleFactor.Apply(SpazioImmagine));
      end
      else
        Testo := Cella.DisplayText;

      // un pixel in piu': a testo largo esattamente quanto lo spazio
      // cxDrawText puo' gia' mettere i puntini
      Necessario := cxTextWidth(Carattere, Testo) + 1;
      Mancante := Necessario - Disponibile;

      siDbPivot.LogMessage(Format('AllargaCampiRigaSulleCelle: %s "%s" larghezza campo %d, spazio %d, testo %d, mancano %d',
        [Item.Field.Caption, Testo, Item.Field.Width, Disponibile, Necessario, Mancante]));

      if Mancante > 0 then
        if not Mancanti.TryGetValue(Item.Field, MancanteRegistrato) or (Mancante > MancanteRegistrato) then
          Mancanti.AddOrSetValue(Item.Field, Mancante);
    end;

    for Coppia in Mancanti do
      Coppia.Key.Width := Coppia.Key.Width + Coppia.Value;
  finally
    Mancanti.Free;
  end;
end;

procedure TzDbPivot.DatiCaricati;
begin
  // chiamato dal collegamento ai dati a ogni apertura o ricarica: la misura si
  // rinvia con un messaggio, quando il pivot ha gia' ricalcolato le celle. Un
  // solo messaggio in coda alla volta: Refresh e riapertura ne mandano piu' d'uno
  if IsDestroying or (csDestroying in ComponentState) or (csDesigning in ComponentState) then
    Exit;

  if FAdattaLarghezzeInCoda then
    Exit;

  // PostInternalMessage usa Handle, che su un frame senza genitore
  // solleverebbe un'eccezione: si rinvia a CMShowingChanged
  if not HandleAllocated then
  begin
    FAdattaLarghezzeRinviata := True;
    Exit;
  end;

  FAdattaLarghezzeRinviata := False;
  FAdattaLarghezzeInCoda := True;
  PostInternalMessage(cmd_AdattaLarghezze);
end;

procedure TzDbPivot.AdattaLarghezzeDopoCaricamento;
const
  // oltre questo numero di celle (righe x colonne del pivot espanso) la misura
  // si sentirebbe a ogni ricarica: si lascia il comando Incolonna all'utente.
  // Il costo dipende dalle celle aggregate, non dai record del dataset
  SogliaCelle = 5000;
var
  Celle: Int64;
begin
  FAdattaLarghezzeInCoda := False;

  if IsDestroying or (csDestroying in ComponentState) then
    Exit;

  if not DataController.IsActive then
    Exit;

  if cxDBPivotGrid.FieldCount = 0 then
    Exit;

  // le larghezze di un pivot dipendono dai valori del momento: si ricalcolano
  // a ogni caricamento, e i ritocchi a mano valgono fino alla ricarica dopo
  Celle := Int64(cxDBPivotGrid.ViewData.RowCount) * cxDBPivotGrid.ViewData.ColumnCount;

  if Celle > SogliaCelle then
  begin
    siDbPivot.LogVerbose(Format('AdattaLarghezzeDopoCaricamento: %d celle, oltre la soglia di %d', [Celle, SogliaCelle]));
    Exit;
  end;

  AdattaLarghezzeCampi;
end;

procedure TzDbPivot.SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
begin
  FzDataSet := Value;

  DataController.DataSet := Value;
  DataSource.DataSet := nil;
  InitPivot;
end;

procedure TzDbPivot.actPersonalizzaExecute(Sender: TObject);
begin
  FzDbPivotProps.Fields.AssignFromPivotFields(cxDBPivotGrid);

  if Edit_CollectionItem(base, FzDbPivotProps) then
  begin
    // doSalvaImpostazioni riprende le impostazioni dei campi della pivot
    FzDbPivotProps.Fields.AssignToPivotFields(cxDBPivotGrid);

    // impostare il resto
    LoadProperties(False);

    doSalvaImpostazioni(False);
  end;
end;

procedure TzDbPivot.actDbFirstExecute(Sender: TObject);
begin
  actDbFirst.Enabled := False;
  try
    DataController.First;
  finally
    actDbFirst.Enabled := true;
  end;
end;

procedure TzDbPivot.actDbLastExecute(Sender: TObject);
begin
  actDbLast.Enabled := False;
  try
    DataController.Last;
  finally
    actDbLast.Enabled := true;
  end;
end;

procedure TzDbPivot.actDbNextExecute(Sender: TObject);
begin
  actDbNext.Enabled := False;
  try
    DataController.Next;
  finally
    actDbNext.Enabled := true;
  end;
end;

procedure TzDbPivot.actDbPriorExecute(Sender: TObject);
begin
  actDbPrior.Enabled := False;
  try
    DataController.Prior;
  finally
    actDbPrior.Enabled := true;
  end;
end;

procedure TzDbPivot.DestroyFields;
begin
  SetLength(FCalcEntries, 0);
  cxDBPivotGrid.DeleteAllFields;
end;

procedure TzDbPivot.PopupGridPopup(Sender: TObject);
begin
  /// ///////////////////////////////////////////////////
  // visiilità degli item
  dxBarSubItemImpostazioni.Visible := dx.Visible(IsAdmin);
  dxBarEditTitolo.Visible := dx.Visible(IsAdmin);

  CopyName.Caption := 'Copia PivotID - ' + PivotID;

  // Filtri rapidi: il bersaglio si cattura adesso, dove l'utente ha cliccato,
  // perche' alla scelta della voce il mouse si trova ormai sul menu.
  FiltroDelMenu := PopupFilterTarget;

  actFiltroPerValore.Enabled := CanFilter and FiltroDelMenu.IsValid;
  actFiltriAvanzati.Enabled := CanFilter;
  actEliminaFiltri.Enabled := CanFilter;

  ActionVisible(actSoloQuestoValore, CanFilter and FiltroDelMenu.HasValue);
  ActionVisible(actEscludiQuestoValore, CanFilter and FiltroDelMenu.HasValue);

  if FiltroDelMenu.HasValue then
  begin
    actSoloQuestoValore.Caption := Format('Solo "%s"', [FiltroDelMenu.DisplayText]);
    actEscludiQuestoValore.Caption := Format('Escludi "%s"', [FiltroDelMenu.DisplayText]);
  end;
end;

/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////

procedure TzDbPivot.InitPivot;
begin
  // Chiamata da SetDataSet

  if cxDBPivotGrid.FieldCount > 0 then
    Exit;

  if zSystemOk then
    if DataController.DataSetOk then
    begin
      cxDBPivotGrid.BeginUpdate;
      try
        // posto all'interno del begin/endupdate
        DataSource.DataSet := zDataSet;

        LoadProperties(true);

        CreateFields;

        cxDBPivotGrid.DataController.KeyFieldNames := DataController.PrimaryKeyFields;

        // if not CtrlKey then
        // Controller.Storage.LoadFromIni;
        //
        CheckFieldWidths;
        //
      finally
        cxDBPivotGrid.EndUpdate;
      end;
    end;
end;

procedure TzDbPivot.OnFlagChange(Sender: TObject);
begin
  UpdateActions;
  DisplayToolbars;
  LoadProperties(False);
end;

procedure TzDbPivot.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin

  // UpdateActions;
end;

procedure TzDbPivot.UpdateActions;
var
  Visible: Boolean;
  CanInsert, CanEdit, CanDelete: Boolean;
begin
  siDbPivot.LogVerbose('UpdateActions');

  if csDestroying in ComponentState then
    Exit;

  // gestire anche i pulsanti di cxGridPopupMenu.BuiltInPopupMenus
  // ActionVisible(actDbFirst, DataController.CanFirst and Flags.ButtonArrows);
  // ActionVisible(actDbPrior, DataController.CanPrior and Flags.ButtonArrows);
  // ActionVisible(actDbNext, DataController.CanNext and Flags.ButtonArrows);
  // ActionVisible(actDbLast, DataController.CanLast and Flags.ButtonArrows);

  ActionVisible(actDbFirst, Flags.ButtonArrows);
  ActionVisible(actDbPrior, Flags.ButtonArrows);
  ActionVisible(actDbNext, Flags.ButtonArrows);
  ActionVisible(actDbLast, Flags.ButtonArrows);

  actDbFirst.Enabled := DataController.CanFirst;
  actDbPrior.Enabled := DataController.CanPrior;
  actDbNext.Enabled := DataController.CanNext;
  actDbLast.Enabled := DataController.CanLast;

  ActionVisible(Elabora, Flags.Params);

  ActionVisible(Espandi, FzDbPivotProps.Flags.ButtonExpand);
  ActionVisible(Riduci, FzDbPivotProps.Flags.ButtonExpand);
  UpdateExpandCaptions;

  ActionVisible(actDbRefresh, DataController.CanRefresh and Flags.ButtonRefresh);

  ActionVisible(MostraQueryUtilizzata, IsAdmin);
  ActionVisible(CopiaQueryUtilizzata, IsAdmin);
  ActionVisible(SalvaImpostazioni, IsAdmin);
  ActionVisible(CaricaImpostazioni, IsAdmin);
  ActionVisible(actResetColonne, IsAdmin);
  ActionVisible(actSQL, IsAdmin);
  ActionVisible(actPersonalizza, IsAdmin);
  ActionVisible(actPersonalizzaColonna, IsAdmin);
  ActionVisible(CopyName, IsAdmin);
  ActionVisible(ClearIniSectionAllUsers, IsAdmin);

  if Assigned(FOnUpdateActions) then
    OnUpdateActions(Self);
end;

procedure TzDbPivot.UpdateExpandCaptions;
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

  for Pulsante in TArray<TdxBarItem>.Create(dxBarButton4, dxBarButton7, dxBarButton12, dxBarButton13) do
    for Indice := 0 to Pulsante.LinkCount - 1 do
      if (udPaintStyle in Pulsante.Links[Indice].UserDefine) and (Pulsante.Links[Indice].UserPaintStyle <> Stile) then
        Pulsante.Links[Indice].UserPaintStyle := Stile;
end;

procedure TzDbPivot.actResetColonneExecute(Sender: TObject);
begin
  if not ConfirmYesNo('Azzerare posizione e visibilità dei campi?', mtWarning) then
    Exit;

  FzDbPivotProps.Fields.Reset(zDataSet);
  ReloadColumnProps;

  // DIV-PVT-2: senza salvataggio il reset andrebbe perso alla chiusura
  doSalvaImpostazioni(False);
end;

procedure TzDbPivot.CheckFieldWidths;
const
  DefaultFieldWidth = 50; // larghezza assegnata da CreateAllFields ai field appena creati
var
  i: integer;
begin
  // post conversione: verifica se deve chiamare AutoWidth;

  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    if cxDBPivotGrid.Fields[i].Width <> DefaultFieldWidth then
      Exit;

  ApplyBestFit;
  doSalvaImpostazioni;
end;

procedure TzDbPivot.CMShowingChanged(var M: TMessage);
begin
  inherited;
  AlreadyShown := true;
  PostInternalMessage(cmd_DisplayToolbars);

  if Showing and FAdattaLarghezzeRinviata then
    DatiCaricati;
end;

function TzDbPivot.GetFlags: TzDbPivotFlags;
begin
  result := FzDbPivotProps.Flags;
end;

procedure TzDbPivot.NomeFileIniExecute(Sender: TObject);
var
  s: string;
begin
  s := IniFileName;

  Clipboard.AsText := s;
  ConfirmOk(s);
end;

procedure TzDbPivot.actPersonalizzaColonnaExecute(Sender: TObject);
var
  i: integer;
  Color: TColor;
  FieldName: string;
  idx: integer;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
  Cella: TPoint;
  CampoDati: TObject;
begin
  // DIV-PVT-5: senza cella con il fuoco FocusedCell puo' valere -1
  Cella := cxDBPivotGrid.ViewData.FocusedCell;
  if (Cella.X < 0) or (Cella.Y < 0) or (Cella.X >= cxDBPivotGrid.ViewData.ColumnCount) or (Cella.Y >= cxDBPivotGrid.ViewData.RowCount) then
    Exit;

  CampoDati := cxDBPivotGrid.ViewData.Cells[Cella.Y, Cella.X].DataField;
  if not (CampoDati is TcxDBPivotGridField) then
    Exit;

  FieldName := TcxDBPivotGridField(CampoDati).DataBinding.FieldName;

  if FieldName = '' then
    Exit;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  Origin := DataController.GetFieldOrigin(Field);

  idx := zSystem.zDataDictionary.IndexOf(Origin);
  if idx = -1 then
    Exit
  else
    Domain := zSystem.zDataDictionary[idx];

  if Domain.Inspect then
  begin
    zSystem.zDataDictionary[idx].Assign(Domain);
    zSystem.SaveZip(csFieldProps, 'Personalizzazione Campo DbPivot');

    CreateFields; // << --- agire solo sulle props della colonna selezionata?
  end;
end;

procedure TzDbPivot.actExcelBeforeExecute(Sender: TObject);
begin
  if actExcel.Dialog.InitialDir = '' then
    actExcel.Dialog.InitialDir := zSystem.PersonalFolder;
end;

procedure TzDbPivot.actExcelAccept(Sender: TObject);
var
  FileName: string;
begin
  FileName := actExcel.Dialog.FileName;

  case actExcel.Dialog.FilterIndex - 1 of
    0:
      cxExportPivotGridToXLSX(FileName, cxDBPivotGrid);
    1:
      cxExportPivotGridDataToExcel(FileName, cxDBPivotGrid);
    2:
      cxExportPivotGridToExcel(FileName, cxDBPivotGrid);
    3:
      cxExportPivotGridDataToExcel(FileName, cxDBPivotGrid);
  end;

  ShellExecute(0, Pchar('open'), Pchar(ExtractFilePath(FileName)), nil, nil, SW_RESTORE);
end;

procedure TzDbPivot.CreateFields;
var
  UseLabel: Boolean;
  zCtrlType: TzCtrlType;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
  zPivotFld: TzPivotField;
  PivotField: TcxDBPivotGridField;
  i: integer;
begin
  if not DataController.DataSetOk then
    Exit;

  if Assigned(FOnBeforeCreateControls) then
    OnBeforeCreateControls(Self);

  // azzera entries prima di ricreare
  SetLength(FCalcEntries, 0);

  maxWidths.Clear;

  cxDBPivotGrid.DeleteAllFields;
  cxDBPivotGrid.CreateAllFields;

  // attribuire le proprieta
  FzDbPivotProps.Fields.ValidateDataset(zDataSet);
  FzDbPivotProps.Fields.AssignToPivotFields(cxDBPivotGrid);

  for zPivotFld in FzDbPivotProps.Fields do
  begin
    PivotField := FieldByName(zPivotFld.Name);

    if Assigned(PivotField) then
    begin
      if not DataController.TryGetField(zPivotFld.Name, Field) then
        Continue;

      Origin := DataController.GetFieldOrigin(Field);
      Domain := zSystem.zDataDictionary.Get(Origin, true);

      if not zPivotFld.Caption.IsEmpty then
        PivotField.Caption := zPivotFld.Caption
      else
        PivotField.Caption := Domain.DisplayLabel;

      zCtrlType := zPivotFld.zCtrlType;
      if zCtrlType = ctDefault then
        zCtrlType := Domain.zCtrlType;

      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if zCtrlType.IsLookup then
        zCtrlType := ctEdit;
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      PivotField.PropertiesClass := dx.GetPropertiesClass(zCtrlType);
      dx.InitProperties(zCtrlType, PivotField.Properties, Domain, Field);
      PivotField.Width := zPivotFld.Width;

      case zCtrlType of
        ctEdit:
          ;
        ctSpin:
          ;
        ctDate:
          ;
        ctTime:
          ;
        ctDateTime:
          ;
        ctPickList:
          ;
        ctPickListImage:
          ;
        ctRadioGroup:
          ;
        ctComboDlg:
          ;
        ctLookup:
          ;
        ctLookupExt:
          ;
        ctCheckBox:
          ;
        ctMemo:
          ;
        ctRTF:
          ;
        ctImage:
          ;
        ctHyperLink:
          begin
          end;
        ctCustomDlg:
          ;
      end;

      PivotField.Area := zPivotFld.Area;
      PivotField.AreaIndex := zPivotFld.AreaIndex;
      PivotField.DataVisibility := zPivotFld.DataVisibility;
      PivotField.DisplayFormat := zPivotFld.DisplayFormat;
      PivotField.GroupIndex := zPivotFld.GroupIndex;
      PivotField.Hidden := zPivotFld.Hidden;
      PivotField.MinWidth := zPivotFld.MinWidth;
      PivotField.SummaryType := zPivotFld.SummaryType;
      PivotField.SortOrder := zPivotFld.SortOrder;
      PivotField.SummaryVariation := zPivotFld.SummaryVariation;
      PivotField.TotalsVisibility := zPivotFld.TotalsVisibility;
      PivotField.TopValueCount := zPivotFld.TopValueCount;
      PivotField.TopValueShowOthers := zPivotFld.TopValueShowOthers;
      PivotField.Options.Sizing := zPivotFld.Sizeable;

      // Totale generale di colonna con esclusioni: gestore condiviso.
      // A lista vuota, uno stCustom orfano (senza gestore) torna stSum,
      // altrimenti la colonna resterebbe vuota.
      if zPivotFld.GrandTotalExcludeValues.Count > 0 then
      begin
        PivotField.SummaryType := stCustom;
        PivotField.OnCalculateCustomSummary := GrandTotalExcludeSummary;
      end
      else
        if (PivotField.SummaryType = stCustom) and not Assigned(PivotField.OnCalculateCustomSummary) then
          PivotField.SummaryType := stSum;

      maxWidths.Add(PivotField, zPivotFld.MaxWidth);
    end;
  end;

  // Casella di ricerca nella tendina dei filtri di ogni campo: con centinaia di
  // valori da spuntare la lista non si usa. Non esiste un'opzione a livello di
  // griglia, va impostata campo per campo.
  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    cxDBPivotGrid.Fields[i].Options.FilteringPopupIncrementalFiltering := true;

  if Assigned(FOnAfterCreateControls) then
    OnAfterCreateControls(Self);

  CreateCalcFields;
end;

procedure TzDbPivot.CreateFiltersFromProps;
//
// Orchestratore. Chiamato da LoadProperties dopo CreateToolsFromProps.
//
// Sorgente unica: GetDbViewProps.ToolFilters. Contiene sia la configurazione
// persistente (admin / zToolConfigDlg) sia i filtri aggiunti da codice dal
// DataModule della form (marcati FromCode e non serializzati).
//
// Nota: la versione precedente iterava DUE volte questa stessa collezione
// (Props.ToolFilters e la proprieta' ToolFilters sono lo stesso
// oggetto, perche' GetToolFilters restituisce la prima), e il dizionario di
// deduplicazione serviva solo a rendere innocuo il secondo giro.begin
begin
  siDbPivot.EnterMethod(Self, 'CreateFiltersFromProps');
  try
    TzToolFilterBuilder.Build(zDbPivotProps.ToolFilters, Self, dxBarManager, FzDataSet,
      procedure(Testo: string)
      begin
        siDbPivot.LogWarning('CreateFiltersFromProps: ' + Testo);
      end);
  finally
    siDbPivot.LeaveMethod(Self, 'CreateFiltersFromProps');
  end;
end;

procedure TzDbPivot.ClearIniSectionAllUsersExecute(Sender: TObject);
begin
  // Controller.Storage.ClearIniSectionAllUsers;
end;

procedure TzDbPivot.ElaboraExecute(Sender: TObject);
begin
  ShowParams(PivotID + '_Params', zDataSet, 'Parametri', true);
end;

procedure TzDbPivot.EspandiExecute(Sender: TObject);
begin
  FullExpand;
end;

procedure TzDbPivot.RiduciExecute(Sender: TObject);
begin
  FullCollapse;
end;

procedure TzDbPivot.LoadProperties(const LoadDefaults: Boolean);
begin
  if csDesigning in ComponentState then
    Exit;

  if LoadDefaults then
    InternalLoadProperties;

  if zSystem.zDbPivots.Exists(PivotID) then
    SetTitle(FzDbPivotProps.Title);

  TcxPivotGridViewDataAccess(cxDBPivotGrid.ViewData).ExpandRows := FzDbPivotProps.Flags.ExpandRows;
  TcxPivotGridViewDataAccess(cxDBPivotGrid.ViewData).ExpandColumns := FzDbPivotProps.Flags.ExpandColumns;

  TcxPivotGridAccess(cxDBPivotGrid).ViewInfo.DrawExpandButtons := FzDbPivotProps.Flags.DrawExpandButtons;

  cxDBPivotGrid.OptionsView.ColumnFields := not FzDbPivotProps.Flags.HideColumnFields;
  cxDBPivotGrid.OptionsView.DataFields := not FzDbPivotProps.Flags.HideDataFields;
  cxDBPivotGrid.OptionsView.FilterFields := not FzDbPivotProps.Flags.HideFilterFields;
  cxDBPivotGrid.OptionsView.RowFields := not FzDbPivotProps.Flags.HideRowFields;

  // Filter
  if FzDbPivotProps.Flags.Filter then
    cxDBPivotGrid.OptionsPrefilter.Visible := pfvAlways
  else
    cxDBPivotGrid.OptionsPrefilter.Visible := pfvNonEmpty;

  // OptionsView
  // cxDBPivotGrid.OptionsView.ColumnFields := zDbPivotProps.Flags.ColumnFields;
  cxDBPivotGrid.OptionsView.ColumnGrandTotals := FzDbPivotProps.Flags.ColumnGrandTotals;
  cxDBPivotGrid.OptionsView.ColumnGrandTotalText := FzDbPivotProps.Flags.ColumnGrandTotalText;
  cxDBPivotGrid.OptionsView.ColumnTotals := FzDbPivotProps.Flags.ColumnTotals;
  // cxDBPivotGrid.OptionsView.DataFields := zDbPivotProps.Flags.DataFields;
  // cxDBPivotGrid.OptionsView.FilterFields := zDbPivotProps.Flags.FilterFields;
  cxDBPivotGrid.OptionsView.FilterSeparator := FzDbPivotProps.Flags.FilterSeparator;
  cxDBPivotGrid.OptionsView.GrandTotalsForSingleValues := FzDbPivotProps.Flags.GrandTotalsForSingleValues;
  cxDBPivotGrid.OptionsView.MarkNarrowCells := FzDbPivotProps.Flags.MarkNarrowCells;
  // cxDBPivotGrid.OptionsView.RowFields := zDbPivotProps.Flags.RowFields;
  cxDBPivotGrid.OptionsView.RowGrandTotals := FzDbPivotProps.Flags.RowGrandTotals;
  cxDBPivotGrid.OptionsView.RowGrandTotalText := FzDbPivotProps.Flags.RowGrandTotalText;
  cxDBPivotGrid.OptionsView.RowTotals := FzDbPivotProps.Flags.RowTotals;

  // Con RowTreeLayout i campi riga stanno in una sola colonna ad albero; a flag
  // spento non si tocca il valore predefinito di DevExpress (rtlFar)
  if FzDbPivotProps.Flags.RowTreeLayout then
    cxDBPivotGrid.OptionsView.RowTotalsLocation := rtlTree
  else
    cxDBPivotGrid.OptionsView.RowTotalsLocation := rtlFar;
  cxDBPivotGrid.OptionsView.TotalsForSingleValues := FzDbPivotProps.Flags.TotalsForSingleValues;
  //

  LoadDescription;
  RebuildToolbar; // filtri poi azioni
  UpdateActions;
end;

procedure TzDbPivot.SelezionaCampiExecute(Sender: TObject);
begin
  // cxDBPivotGrid.ShowPrefilterDialog
  cxDBPivotGrid.Customization.FormStyle := cfsAdvanced;
  cxDBPivotGrid.Customization.Visible := true;
end;

procedure TzDbPivot.PostInternalMessage(const cmd: TzDbPivotCommand);
begin
  PostMessage(Self.Handle, ZZ_DBPIVOT, NativeUInt(cmd), 0);
end;

procedure TzDbPivot.MessageHandler(var Message: TMessage);
begin

  Case TzDbPivotCommand(Message.WParam) of
    cmd_UpdateActions:
      UpdateActions;
    cmd_DisplayToolbars:
      DisplayToolbars;
    cmd_ApplyBestFit:
      ApplyBestFit;
    cmd_AdattaLarghezze:
      AdattaLarghezzeDopoCaricamento;
    cmd_ExpandInnerLevels:
      ExpandInnerLevels;
    cmd_SaveZip:
      begin
        FSaveZipQueued := False;
        if zSystemOk then
          zSystem.SaveZip(csDbPivots, 'TzDbPivot.SalvaImpostazioni');
      end;
  end;
end;

procedure TzDbPivot.SetDataSourceEnabled(const Value: Boolean);
begin
  DataSource.Enabled := Value;
end;

function TzDbPivot.GetDataSourceEnabled: Boolean;
begin
  result := DataSource.Enabled;
end;

procedure TzDbPivot.cxDBPivotGridClick(Sender: TObject);
begin

  if FzDbPivotProps.Flags.ExpandInnerLevels then
  begin
    if cxDBPivotGrid.HitTest.HitAtButton then
      PostInternalMessage(cmd_ExpandInnerLevels);
  end
  else
    if FzDbPivotProps.BestFitAfterExpand then
      if cxDBPivotGrid.HitTest.HitAtButton then
        PostInternalMessage(cmd_ApplyBestFit);
end;

procedure TzDbPivot.cxDBPivotGridDblClick(Sender: TObject);
var
  CellInfo: TcxPivotGridDataCellViewInfo;
  Handled: Boolean;
begin
  cxDBPivotGrid.HitTest.Recalculate;
  Handled := False;

  if cxDBPivotGrid.HitTest.HitAtDataCell then
  begin
    CellInfo := TcxPivotGridDataCellViewInfo(cxDBPivotGrid.HitTest.HitObject);

    siDbPivot.LogString('DblClick', Format('cella %d,%d - record %d', [CellInfo.RowIndex, CellInfo.ColumnIndex, CellInfo.CrossCell.Records.Count]));

    if Assigned(FOnCellDblClick) then
      FOnCellDblClick(Self, CellInfo.CrossCell, Handled);

    if Handled then
      Exit;

    if Flags.DrillDown then
      ShowDrillDown(CellInfo.CrossCell);
  end
  else
    if cxDBPivotGrid.HitTest.HitAtGroupHeader then
      if Assigned(FOnGroupHeaderDblClick) then
        FOnGroupHeaderDblClick(Self, cxDBPivotGrid.HitTest.GroupItem, Handled);
end;

procedure TzDbPivot.ShowDrillDown(CrossCell: TcxPivotGridCrossCell);
var
  DrillDownSource: TcxCustomDataSource;
  DetailForm: TForm;
  Grid: TcxGrid;
  GridView: TcxGridTableView;
  i: integer;
  PivotField: TcxPivotGridField;
  Column: TcxGridColumn;
begin
  if CrossCell = nil then
    Exit;

  DrillDownSource := CrossCell.CreateDrillDownDataSource;
  try
    DetailForm := TForm.Create(nil);
    try
      DetailForm.Caption := Format('%s - Dettaglio (%d record)', [GetTitle, CrossCell.Records.Count]);
      DetailForm.Position := poScreenCenter;
      DetailForm.Width := 900;
      DetailForm.Height := 500;

      Grid := TcxGrid.Create(DetailForm);
      Grid.Parent := DetailForm;
      Grid.Align := alClient;

      GridView := Grid.CreateView(TcxGridTableView) as TcxGridTableView;
      Grid.Levels.Add.GridView := GridView;

      GridView.OptionsData.Editing := False;
      GridView.OptionsView.GroupByBox := False;

      // una colonna per OGNI field del pivot, nello stesso ordine:
      // il collegamento colonna→field del drill-down datasource è posizionale
      for i := 0 to cxDBPivotGrid.FieldCount - 1 do
      begin
        PivotField := cxDBPivotGrid.Fields[i];

        Column := GridView.CreateColumn;
        Column.Caption := PivotField.Caption;
        Column.Visible := PivotField.Visible;
        Column.Hidden := PivotField.Hidden;
      end;

      GridView.DataController.CustomDataSource := DrillDownSource;
      GridView.ApplyBestFit;

      DetailForm.ShowModal;

      GridView.DataController.CustomDataSource := nil;
    finally
      DetailForm.Free;
    end;
  finally
    DrillDownSource.Free;
  end;
end;

function TzDbPivot.GetGroupItemValue(GroupItem: TcxPivotGridGroupItem; const FieldName: string): Variant;
var
  Field: TcxDBPivotGridField;
begin
  result := Null;

  if not Assigned(GroupItem) then
    Exit;

  Field := FieldByName(FieldName);
  if Assigned(Field) then
    result := cxDBPivotGrid.DataController.Values[GroupItem.RecordIndex, Field.Index];
end;

function TzDbPivot.GetCrossCellKeys(CrossCell: TcxPivotGridCrossCell): TArray<Variant>;
var
  i: integer;
begin
  SetLength(result, 0);

  if CrossCell = nil then
    Exit;

  // KeyFieldNames impostato in InitPivot con le chiavi primarie del dataset
  SetLength(result, CrossCell.Records.Count);
  for i := 0 to CrossCell.Records.Count - 1 do
    result[i] := cxDBPivotGrid.DataController.GetRecordId(CrossCell.Records[i]);
end;

procedure TzDbPivot.SetGrandTotalExclusions(const FieldName: string; const ExcludeValues: array of string);
var
  Item: TzPivotField;
  PivotField: TcxDBPivotGridField;
  Value: string;
begin
  Item := ResolvezPivotField(FieldName);
  if Item = nil then
  begin
    siDbPivot.LogWarning(Format('SetGrandTotalExclusions: campo "%s" non presente nelle props', [FieldName]));
    Exit;
  end;

  Item.GrandTotalExcludeValues.Clear;
  for Value in ExcludeValues do
    Item.GrandTotalExcludeValues.Add(Value);

  // se i field sono già stati creati applica subito, senza attendere CreateFields
  PivotField := FieldByName(FieldName);
  if Assigned(PivotField) then
    if Item.GrandTotalExcludeValues.Count > 0 then
    begin
      PivotField.SummaryType := stCustom;
      PivotField.OnCalculateCustomSummary := GrandTotalExcludeSummary;
    end
    else
    begin
      PivotField.OnCalculateCustomSummary := nil;
      PivotField.SummaryType := stSum;
    end;
end;

procedure TzDbPivot.doSalvaImpostazioni(const Silent: Boolean = False);
begin
  if csDesigning in ComponentState then
    Exit;

  if not Silent then
    StartWait('Attendere...', true);
  try
    if FzDbPivotProps.Name = '' then
      FzDbPivotProps.Name := PivotID;

    if FzDbPivotProps.DataSet = '' then
      FzDbPivotProps.DataSet := DataController.IdDataSet;

    FzDbPivotProps.Fields.AssignFromPivotFields(cxDBPivotGrid);

    InternalSaveProperties;
  finally
    if not Silent then
      StopWait;
  end;
end;

procedure TzDbPivot.InternalLoadProperties;
begin

  if not DataController.DataSetOk then
    Exit;

  if FzDbPivotProps.Name = '' then
    FzDbPivotProps.Name := PivotID;

  if FzDbPivotProps.DataSet = '' then
    FzDbPivotProps.DataSet := DataController.IdDataSet;

  if Assigned(FOnCustomLoadProps) then
    OnCustomLoadProps(Self)
  else
    if zSystemOk then
      FzDbPivotProps.LoadFromBase;

  FzDbPivotProps.Fields.ValidateDataset(DataController.zFbDataSet);
  FzDbPivotProps.Fields.AssignToPivotFields(cxDBPivotGrid);
end;

procedure TzDbPivot.InternalSaveProperties;
begin

  if Assigned(FOnCustomSaveProps) then
    OnCustomSaveProps(Self)
  else
    if zSystemOk then
    begin
      // Aggiornamento in memoria sincrono: niente thread, niente letture
      // concorrenti sulle props (il vecchio salvataggio su thread anonimo
      // poteva sovrapporsi a un secondo salvataggio o alla distruzione del frame).
      FzDbPivotProps.SaveToBase(False);

      // La scrittura dello zip resta sul main thread ma differita e coalescente:
      // più salvataggi ravvicinati (es. digitazione del titolo) producono
      // una sola scrittura su disco.
      if not FSaveZipQueued then
      begin
        FSaveZipQueued := true;
        PostInternalMessage(cmd_SaveZip);
      end;
    end;
end;

procedure TzDbPivot.DisplayToolbars;
begin
  dxBarManager.BeginUpdate;
  try
    // ordine inverso di visualizzazione
    dxBarToolbarFree.Visible := Flags.Toolbar;
    dxBarToolbar.Visible := Flags.Toolbar;
    dxBarToolbar.UseRestSpace := not dxBarToolbarFree.Visible;
    Titolo.Visible := Flags.Toolbar;
  finally
    dxBarManager.EndUpdate;
  end;
end;

procedure TzDbPivot.cxDBPivotGridStylesGetContentStyle(Sender: TcxCustomPivotGrid; ACell: TcxPivotGridDataCellViewInfo; var AStyle: TcxStyle);
begin
  if (not VarIsNull(ACell.Value)) and VarIsNumeric(ACell.Value) then
  begin
    if ACell.Value < 0 then
      AStyle := cxStyleRed;
  end;
end;

procedure TzDbPivot.DescrizioneExecute(Sender: TObject);
begin

  if Descrizione.Checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzDbPivot.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

function TzDbPivot.GetTitle: string;
begin
  result := Titolo.Caption;

  if result.IsEmpty then
  begin
    result := FzDbPivotProps.Title;

    if result.IsEmpty then
    begin
      result := name;

      if result.StartsWith('pivot') then
        result := result.Replace('pivot', '', [rfIgnoreCase]);
    end;
  end;
end;

procedure TzDbPivot.LoadDescription;
begin

  if not Assigned(FrameDescription) then
    CreateDescription;

  FzDbPivotProps.Description.LoadFromIni(PivotID);
  FrameDescription.zDescription := FzDbPivotProps.Description;

  Descrizione.Checked := FrameDescription.zDescription.Visible;
end;

procedure TzDbPivot.SaveDescription;
begin
  FzDbPivotProps.Description.Assign(FrameDescription.zDescription);
  FzDbPivotProps.Description.SaveToIni(PivotID);
  Descrizione.Checked := FzDbPivotProps.Description.Visible;
end;

function TzDbPivot.ResolvezPivotField(const FieldName: string): TzPivotField;
begin
  // Risoluzione per nome ad ogni uso: gli item di zDbPivotProps.Fields vengono
  // ricreati da AssignFromPivotFields (Clear + Add) e ogni riferimento
  // conservato diventerebbe pendente al primo salvataggio.
  result := nil;
  if FieldName <> '' then
    result := FzDbPivotProps.Fields.Get(FieldName, False);
end;

procedure TzDbPivot.CreateCalcFields;
var
  zFld: TzPivotField;
  NewField: TcxDBPivotGridField;
  SrcField: TcxDBPivotGridField;
  Entry: TzDbPivotCalcFieldEntry;
  i: integer;
begin
  for zFld in FzDbPivotProps.Fields do
  begin
    if zFld.Kind <> fkCalc then
      Continue;

    if zFld.SourceFieldName.IsEmpty or zFld.ColumnFieldName.IsEmpty then
      Continue;

    if zFld.Name.IsEmpty then
      Continue;

    // Il field sorgente deve esistere già nel pivot con stSum
    SrcField := FieldByName(zFld.SourceFieldName);
    if SrcField = nil then
      Continue;

    NewField := TcxDBPivotGridField.Create(Self);
    NewField.PivotGrid := cxDBPivotGrid;
    NewField.DataBinding.FieldName := zFld.SourceFieldName;
    NewField.Caption := zFld.Caption;
    NewField.Area := faData;
    NewField.AreaIndex := zFld.AreaIndex;
    NewField.SummaryType := stCustom;
    NewField.OnCalculateCustomSummary := CalcFieldCustomSummary;
    // *** Tag per identificare i field calcolati in AssignFromPivotFields
    NewField.Tag := zCalcFieldTag;

    if not zFld.DisplayFormat.IsEmpty then
      NewField.DisplayFormat := zFld.DisplayFormat
    else
      NewField.DisplayFormat := SrcField.DisplayFormat;

    Entry.FieldName := zFld.Name;
    Entry.PivotField := NewField;
    Entry.SourceField := SrcField;
    Entry.ColCache := nil;
    Entry.ColCacheDirty := true;

    i := Length(FCalcEntries);
    SetLength(FCalcEntries, i + 1);
    FCalcEntries[i] := Entry;
  end;
end;

function TzDbPivot.GetCalcColGroupItems(var Entry: TzDbPivotCalcFieldEntry): TArray<TcxPivotGridGroupItem>;
var
  zFld: TzPivotField;
  ColField: TcxDBPivotGridField;
  ColItem: TcxPivotGridViewDataItem;
  GroupItem: TcxPivotGridGroupItem;
  i: integer;
begin
  if not Entry.ColCacheDirty then
  begin
    result := Entry.ColCache;
    Exit;
  end;

  SetLength(Entry.ColCache, 0);

  zFld := ResolvezPivotField(Entry.FieldName);
  if zFld = nil then
  begin
    Entry.ColCacheDirty := False;
    result := Entry.ColCache;
    Exit;
  end;

  ColField := FieldByName(zFld.ColumnFieldName);
  if ColField = nil then
  begin
    Entry.ColCacheDirty := False;
    result := Entry.ColCache;
    Exit;
  end;

  for i := 0 to cxDBPivotGrid.ViewData.ColumnCount - 1 do
  begin
    ColItem := cxDBPivotGrid.ViewData.Columns[i];
    GroupItem := ColItem.GroupItem; // questo è il TcxPivotGridGroupItem

    if (GroupItem <> nil) and (GroupItem.Field = ColField) and (zFld.ColumnValues.IndexOf(VarToStr(GroupItem.Value)) >= 0) then
    begin
      SetLength(Entry.ColCache, Length(Entry.ColCache) + 1);
      Entry.ColCache[High(Entry.ColCache)] := GroupItem;
    end;
  end;

  Entry.ColCacheDirty := False;
  result := Entry.ColCache;
end;

function TzDbPivot.SumColumnCells(RowItem: TcxPivotGridGroupItem; const ColumnItems: TArray<TcxPivotGridGroupItem>; Field: TcxPivotGridField; SummaryType: TcxPivotGridSummaryType): Double;
var
  ColItem: TcxPivotGridGroupItem;
  Cell: TcxPivotGridCrossCell;
  CellValue: Variant;
begin
  result := 0;

  for ColItem in ColumnItems do
  begin
    if ColItem = nil then
      Continue;

    Cell := RowItem.GetCellByCrossItem(ColItem);
    if Cell = nil then
      Continue;

    // GetSummaryByField restituisce Variant, non TcxPivotGridCrossCellSummary
    CellValue := Cell.GetSummaryByField(Field, SummaryType);

    if not VarIsNull(CellValue) and not VarIsEmpty(CellValue) then
      result := result + CellValue;
  end;
end;

procedure TzDbPivot.CalcFieldCustomSummary(Sender: TcxPivotGridField; ASummary: TcxPivotGridCrossCellSummary);
var
  i: integer;
  CrossCell: TcxPivotGridCrossCell;
  RowItem: TcxPivotGridViewDataItem;
  zFld: TzPivotField;
  ColItems: TArray<TcxPivotGridGroupItem>;
  IsTotal: Boolean;
  j: integer;
begin
  for i := 0 to High(FCalcEntries) do
  begin
    if FCalcEntries[i].PivotField <> Sender then
      Continue;

    zFld := ResolvezPivotField(FCalcEntries[i].FieldName);
    if zFld = nil then
      Exit;

    CrossCell := ASummary.Owner;

    // Trova il TcxPivotGridViewDataItem corrispondente alla riga corrente
    RowItem := nil;
    for j := 0 to cxDBPivotGrid.ViewData.RowCount - 1 do
    begin
      if cxDBPivotGrid.ViewData.Rows[j].GroupItem = CrossCell.Row then
      begin
        RowItem := cxDBPivotGrid.ViewData.Rows[j];
        Break;
      end;
    end;

    IsTotal := (RowItem <> nil) and RowItem.IsTotalItem;

    if IsTotal then
    begin
      case zFld.TotalMode of
        ctmNull:
          begin
            ASummary.Custom := Null;
            Exit;
          end;
        ctmZero:
          begin
            ASummary.Custom := 0;
            Exit;
          end;
        ctmCalc:
          ; // cade nel calcolo normale
      end;
    end;

    // Calcolo normale: somma i valori delle colonne D, M, ecc.
    ColItems := GetCalcColGroupItems(FCalcEntries[i]);
    ASummary.Custom := SumColumnCells(CrossCell.Row, ColItems, FCalcEntries[i].SourceField, stSum);
    Exit;
  end;
end;

procedure TzDbPivot.GrandTotalExcludeSummary(Sender: TcxPivotGridField; ASummary: TcxPivotGridCrossCellSummary);
var
  CrossCell: TcxPivotGridCrossCell;
  zFld: TzPivotField;
  ColumnItems: TArray<TcxPivotGridGroupItem>;
  Child: TcxPivotGridGroupItem;
  j: integer;
begin
  CrossCell := ASummary.Owner;

  // cella normale (o totale generale di riga): equivale a stSum
  if (CrossCell.Column = nil) or (CrossCell.Column.Field <> nil) then
  begin
    ASummary.Custom := ASummary.Sum;
    Exit;
  end;

  zFld := ResolvezPivotField(TcxDBPivotGridField(Sender).DataBinding.FieldName);
  if (zFld = nil) or (zFld.GrandTotalExcludeValues.Count = 0) then
  begin
    ASummary.Custom := ASummary.Sum;
    Exit;
  end;

  // Totale generale di colonna: somma i Custom (già calcolati per le celle
  // normali) delle sole colonne il cui valore non è nella lista di esclusione
  SetLength(ColumnItems, 0);
  for j := 0 to CrossCell.Column.ItemCount - 1 do
  begin
    Child := CrossCell.Column.Items[j];
    if Child = nil then
      Continue;

    if zFld.GrandTotalExcludeValues.IndexOf(VarToStr(Child.Value)) >= 0 then
      Continue;

    SetLength(ColumnItems, Length(ColumnItems) + 1);
    ColumnItems[High(ColumnItems)] := Child;
  end;

  ASummary.Custom := SumColumnCells(CrossCell.Row, ColumnItems, Sender, stCustom);
end;

function TzDbPivot.GetToolFilters: TzToolFiltersProps;
begin
  result := zDbPivotProps.ToolFilters;
end;

procedure TzDbPivot.InvalidateCalcColCaches;
var
  i: integer;
begin
  for i := 0 to High(FCalcEntries) do
    FCalcEntries[i].ColCacheDirty := true;
end;

procedure TzDbPivot.PivotLayoutChanged(Sender: TObject);
var
  i: integer;
  zFld: TzPivotField;
begin
  // 1. Invalida le cache dei grouping item di colonna
  InvalidateCalcColCaches;

  // 2. Persiste l'AreaIndex corrente dei field calcolati nella collection
  // (l'utente può averli spostati tramite drag-and-drop)
  for i := 0 to High(FCalcEntries) do
    if Assigned(FCalcEntries[i].PivotField) then
    begin
      zFld := ResolvezPivotField(FCalcEntries[i].FieldName);
      if Assigned(zFld) then
        zFld.AreaIndex := FCalcEntries[i].PivotField.AreaIndex;
    end;
end;

procedure TzDbPivot.SetToolFilters(const Value: TzToolFiltersProps);
begin
  zDbPivotProps.ToolFilters.Assign(Value);
end;

procedure TzDbPivot.EditToolsExecute(Sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbPivot.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

/// /////////////////////////////////////////////////////////////////////////
// Filtri rapidi in memoria
//
// Agiscono sui dati gia' caricati: non rileggono il database e non toccano i
// filtri della barra (ToolFilters), che restano filtri SQL.
// - F3 / Filtro per valore: una condizione nel prefiltro (DataController.Filter)
//   sul campo della riga, con la finestra e la regola dell'asterisco del F3 di
//   zDbView: testo = "inizia per", testo* = "contiene", vuoto = togli;
// - Solo questo / Escludi questo: le spunte della tendina del campo (Field.Filter);
// - F4 apre il prefiltro, Ctrl+Backspace toglie prefiltro e spunte.
/// /////////////////////////////////////////////////////////////////////////

function TzPivotFilterTarget.IsValid: Boolean;
begin
  result := Assigned(Field);
end;

procedure TzDbPivot.PivotKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F3) and (Shift = []) then
  begin
    Key := 0;
    if CanFilter then
      FilterByValue(FocusedFilterTarget);
  end
  else
    if (Key = VK_F4) and (Shift = []) then
    begin
      Key := 0;
      OpenFilterDialog;
    end
    else
      if (Key = VK_BACK) and (Shift = [ssCtrl]) then
      begin
        Key := 0;
        ClearFilters;
      end;
end;

function TzDbPivot.CanFilter: Boolean;
begin
  result := DataController.DataSetOk and DataController.IsActive and (cxDBPivotGrid.FieldCount > 0);
end;

function TzDbPivot.FilterTargetFromGroupItem(GroupItem: TcxPivotGridGroupItem): TzPivotFilterTarget;
begin
  result := Default(TzPivotFilterTarget);

  if not Assigned(GroupItem) then
    Exit;

  // il totale generale e' la radice dei group item e non ha campo: niente da filtrare
  if not(GroupItem.Field is TcxDBPivotGridField) then
    Exit;

  result.Field := TcxDBPivotGridField(GroupItem.Field);
  result.Value := GroupItem.Value;
  result.DisplayText := GroupItem.DisplayText;
  result.HasValue := true;
end;

function TzDbPivot.InnermostRowField: TcxDBPivotGridField;
var
  i: integer;
  Field: TcxPivotGridField;
begin
  // Ultimo campo dell'area righe (AreaIndex piu' alto fra i visibili): per esempio
  // il progetto, mentre la tipologia che lo contiene e' un campo piu' esterno.
  result := nil;

  for i := 0 to cxDBPivotGrid.FieldCount - 1 do
  begin
    Field := cxDBPivotGrid.Fields[i];

    if (Field.Area <> faRow) or (not Field.Visible) then
      Continue;

    if not(Field is TcxDBPivotGridField) then
      Continue;

    if (result = nil) or (Field.AreaIndex > result.AreaIndex) then
      result := TcxDBPivotGridField(Field);
  end;
end;

function TzDbPivot.FilterTargetFromRow(RowItem: TcxPivotGridViewDataItem): TzPivotFilterTarget;
var
  DataField: TcxPivotGridField;
  GroupItem: TcxPivotGridGroupItem;
begin
  // F3 filtra sempre il campo di riga piu' interno, qualunque sia la riga:
  // il cliente cerca "3" per vedere i progetti delle terze di tutte le
  // tipologie, anche con il fuoco su una riga di tipologia o sul totale generale.
  // Il valore da proporre c'e' solo se la riga e' proprio di quel campo.
  result := Default(TzPivotFilterTarget);
  result.Value := Null;

  result.Field := InnermostRowField;
  if not Assigned(result.Field) then
    Exit;

  if not Assigned(RowItem) then
    Exit;

  if RowItem.IsGrandTotal then
    Exit;

  // GetGroupItem salta le voci dei campi dati, che stanno fra le righe quando
  // i campi dati sono disposti in verticale (OptionsDataField.Area = dfaRow)
  DataField := nil;
  GroupItem := RowItem.GetGroupItem(DataField);

  if Assigned(GroupItem) and (GroupItem.Field = result.Field) then
    result := FilterTargetFromGroupItem(GroupItem);
end;

function TzDbPivot.FocusedFilterTarget: TzPivotFilterTarget;
var
  RowIndex: integer;
begin
  // FocusedCell: X = colonna, Y = riga
  RowIndex := cxDBPivotGrid.ViewData.FocusedCell.Y;

  if (RowIndex >= 0) and (RowIndex < cxDBPivotGrid.ViewData.RowCount) then
    result := FilterTargetFromRow(cxDBPivotGrid.ViewData.Rows[RowIndex])
  else
    result := FilterTargetFromRow(nil);
end;

function TzDbPivot.PopupFilterTarget: TzPivotFilterTarget;
var
  MousePoint: TPoint;
  HitObject: TObject;
begin
  result := Default(TzPivotFilterTarget);

  if not CanFilter then
    Exit;

  // menu aperto dal titolo o dalla barra: sotto il mouse non c'e' il pivot,
  // vale la cella con il fuoco
  MousePoint := cxDBPivotGrid.ScreenToClient(Mouse.CursorPos);
  if not PtInRect(cxDBPivotGrid.ClientRect, MousePoint) then
    Exit(FocusedFilterTarget);

  cxDBPivotGrid.HitTest.Recalculate;

  if cxDBPivotGrid.HitTest.HitAtGroupHeader then
    // intestazione di riga o di colonna: il suo campo e il suo valore
    result := FilterTargetFromGroupItem(cxDBPivotGrid.HitTest.GroupItem)
  else
    if cxDBPivotGrid.HitTest.HitAtDataCell then
    begin
      // cella dati: la riga piu' interna, come F3 da tastiera
      HitObject := cxDBPivotGrid.HitTest.HitObject;
      if HitObject is TcxPivotGridDataCellViewInfo then
        result := FilterTargetFromRow(TcxPivotGridDataCellViewInfo(HitObject).Row);
    end
    else
      result := FocusedFilterTarget;
end;

function TzDbPivot.InputFilterValue(const Target: TzPivotFilterTarget; out Value: Variant; out OperatorKind: TcxFilterOperatorKind): Boolean;
var
  Field: TField;
begin
  // La finestra del F3 e' quella di zDbView (TzDbViewFilterController.
  // ChiediFiltroPerValore), con due differenze: il valore proposto e' quello
  // della riga del pivot, non del record corrente, e i numeri si cercano come
  // testo. Nelle righe di un pivot un numero e' un'etichetta (codice, anno,
  // classe), non una quantita': "3" deve trovare anche 30 e 3/S.
  // Value = Null: l'utente ha svuotato il valore e la condizione va tolta.
  result := False;
  Value := Null;
  OperatorKind := foEqual;

  if not DataController.TryGetField(Target.Field.DataBinding.FieldName, Field) then
    Exit;

  result := TzDbViewFilterController.ChiediFiltroPerValore(Field, DataController.GetFieldOrigin(Field),
    Target.Field.Caption, Target.Value, True, Value, OperatorKind);
end;

procedure TzDbPivot.FilterByValue(const Target: TzPivotFilterTarget);
var
  Value: Variant;
  OperatorKind: TcxFilterOperatorKind;
begin
  if not Target.IsValid then
  begin
    ConfirmOk('Il pivot non ha campi nell''area delle righe: non c''e'' niente da filtrare.');
    Exit;
  end;

  if not InputFilterValue(Target, Value, OperatorKind) then
    Exit;

  // "inizia per" e "contiene" si risolvono qui, in spunte sulla tendina del campo;
  // uguaglianze (date, elenchi di scelta) e rimozione restano sul prefiltro
  if (OperatorKind in [foBeginsWith, foContains]) and not VarIsNull(Value) then
    FilterByText(Target.Field, VarToStr(Value), OperatorKind = foContains)
  else
    SetFilterCondition(Target.Field, OperatorKind, Value);
end;

procedure TzDbPivot.FilterByText(PivotField: TcxDBPivotGridField; const Testo: string; const Contiene: Boolean);
var
  Controller: TcxDBPivotGridDataController;
  Chiave: string;
  Candidato: string;
  Valore: Variant;
  Riga: integer;
  Visti: TDictionary<string, Boolean>;
  Trovati: TList<Variant>;
  Operazione: string;
begin
  // La ricerca testuale non passa dal prefiltro DevExpress: sul pivot di Gesty
  // Analisi Costi Ricavi "ludo" non trovava LUDOPATIA (prova del 2026-09-29), e
  // l'esito dipende da operatore, opzioni del filtro e adattatore del dataset
  // (TzFbDataSetFilterOperatorAdapter), che qui non si possono verificare.
  // Si scorrono invece i valori distinti del campo, si confrontano senza
  // distinzione di maiuscole e si spuntano nella tendina del campo quelli che
  // corrispondono: un confronto nostro, identico per ogni pivot e ogni tipo di campo.
  Controller := cxDBPivotGrid.DataController;
  Chiave := AnsiUpperCase(Testo);

  if Contiene then
    Operazione := 'contiene'
  else
    Operazione := 'inizia per';

  Visti := TDictionary<string, Boolean>.Create;
  Trovati := TList<Variant>.Create;
  try
    for Riga := 0 to Controller.RecordCount - 1 do
    begin
      Valore := Controller.Values[Riga, PivotField.Index];
      if VarIsNull(Valore) or VarIsEmpty(Valore) then
        Continue;

      // valori distinti: la chiave e' il testo originale, il confronto e' in maiuscolo
      Candidato := VarToStr(Valore);
      if Visti.ContainsKey(Candidato) then
        Continue;
      Visti.Add(Candidato, true);

      Candidato := AnsiUpperCase(Candidato);
      if (Contiene and Candidato.Contains(Chiave)) or ((not Contiene) and Candidato.StartsWith(Chiave)) then
        Trovati.Add(Valore);
    end;

    // un elenco vuoto di valori inclusi per DevExpress vuol dire "nessun filtro":
    // applicarlo mostrerebbe tutto, quindi si avvisa e non si cambia niente
    if Trovati.Count = 0 then
    begin
      ConfirmOk(Format('Nessun valore di %s %s "%s".', [PivotField.Caption, Operazione, Testo]));
      Exit;
    end;

    cxDBPivotGrid.BeginUpdate;
    try
      // una condizione sullo stesso campo nel prefiltro si toglie: restando, si
      // sommerebbe in AND alle spunte
      cxDBPivotGrid.DataController.Filter.RemoveItemByItemLink(PivotField);

      PivotField.Filter.FilterType := ftIncluded;

      PivotField.Filter.Values.BeginUpdate;
      try
        PivotField.Filter.Values.Clear;
        for Valore in Trovati do
          PivotField.Filter.Values.Add(Valore);
      finally
        PivotField.Filter.Values.EndUpdate;
      end;
    finally
      cxDBPivotGrid.EndUpdate;
    end;
  finally
    FreeAndNil(Trovati);
    FreeAndNil(Visti);
  end;

  ShowFilteredValues(PivotField);
end;

procedure TzDbPivot.ShowFilteredValues(PivotField: TcxDBPivotGridField);
var
  i: integer;
  Field: TcxPivotGridField;
  FieldName: string;
begin
  // Dopo un filtro i valori trovati devono vedersi: se i livelli piu' esterni
  // dello stesso asse sono chiusi (es. l'area formativa che contiene il progetto),
  // il pivot mostra solo i totali e il risultato sembra non esserci.
  // Si aprono solo i livelli esterni al campo filtrato: dopo il filtro contengono
  // soltanto i valori trovati, quindi non si apre niente di superfluo.
  if not(PivotField.Area in [faRow, faColumn]) then
    Exit;

  cxDBPivotGrid.BeginUpdate;
  try
    for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    begin
      Field := cxDBPivotGrid.Fields[i];

      if (Field <> PivotField) and (Field.Area = PivotField.Area) and Field.Visible and (Field.AreaIndex < PivotField.AreaIndex) then
        Field.ExpandAll;
    end;
  finally
    cxDBPivotGrid.EndUpdate;
  end;

  // Righe e colonne del pivot si ricostruiscono dopo EndUpdate: il fuoco si
  // sposta in coda ai messaggi. Si passa il nome del campo e non il campo, che
  // nel frattempo potrebbe essere stato ricreato (CreateFields).
  FieldName := PivotField.DataBinding.FieldName;
  TThread.ForceQueue(nil,
    procedure
    begin
      if not IsDestroying then
        FocusFirstFilteredValue(FieldName);
    end);
end;

procedure TzDbPivot.FocusFirstFilteredValue(const FieldName: string);
var
  PivotField: TcxDBPivotGridField;
  ViewData: TcxPivotGridViewData;
  Cella: TPoint;
  Posizione: integer;
  Trovato: Boolean;
begin
  // Fuoco sul primo valore rimasto del campo filtrato e scorrimento fino a
  // mostrarlo: FocusedCell + MakeSelectionVisible, le stesse chiamate che il
  // pivot usa per la navigazione da tastiera (TcxCustomPivotGrid.DoAction).
  PivotField := FieldByName(FieldName);
  if not Assigned(PivotField) then
    Exit;

  ViewData := cxDBPivotGrid.ViewData;
  Cella := ViewData.FocusedCell;
  Trovato := False;

  if PivotField.Area = faRow then
  begin
    for Posizione := 0 to ViewData.RowCount - 1 do
      if (not ViewData.Rows[Posizione].IsTotalItem) and Assigned(ViewData.Rows[Posizione].GroupItem) and (ViewData.Rows[Posizione].GroupItem.Field = PivotField) then
      begin
        Cella.Y := Posizione;
        Trovato := true;
        Break;
      end;
  end
  else
    if PivotField.Area = faColumn then
      for Posizione := 0 to ViewData.ColumnCount - 1 do
        if (not ViewData.Columns[Posizione].IsTotalItem) and Assigned(ViewData.Columns[Posizione].GroupItem) and (ViewData.Columns[Posizione].GroupItem.Field = PivotField) then
        begin
          Cella.X := Posizione;
          Trovato := true;
          Break;
        end;

  if not Trovato then
    Exit;

  // senza colonne o righe con il fuoco FocusedCell puo' valere -1
  if Cella.X < 0 then
    Cella.X := 0;
  if Cella.Y < 0 then
    Cella.Y := 0;

  ViewData.FocusedCell := Cella;
  ViewData.MakeSelectionVisible;

  if cxDBPivotGrid.CanFocus then
    cxDBPivotGrid.SetFocus;
end;

procedure TzDbPivot.SetFilterCondition(PivotField: TcxDBPivotGridField; OperatorKind: TcxFilterOperatorKind; const Value: Variant);
var
  Filter: TcxDataFilterCriteria;
begin
  Filter := cxDBPivotGrid.DataController.Filter;

  cxDBPivotGrid.BeginUpdate;
  try
    // le spunte della tendina dello stesso campo si tolgono: restando, si
    // sommerebbero in AND alla condizione e il risultato non sarebbe quello chiesto
    PivotField.Filter.Clear;

    Filter.BeginUpdate;
    try
      // un secondo F3 sullo stesso campo sostituisce la condizione, come in zDbView
      Filter.RemoveItemByItemLink(PivotField);

      if not VarIsNull(Value) then
        Filter.Root.AddItem(PivotField, OperatorKind, Value, VarToStr(Value));

      // se l'utente aveva spento il prefiltro dalla sua barra la condizione non agirebbe
      Filter.Active := true;
    finally
      Filter.EndUpdate;
    end;
  finally
    cxDBPivotGrid.EndUpdate;
  end;

  if not VarIsNull(Value) then
    ShowFilteredValues(PivotField);
end;

procedure TzDbPivot.KeepOnlyValue(const Target: TzPivotFilterTarget);
begin
  if not Target.HasValue then
    Exit;

  cxDBPivotGrid.BeginUpdate;
  try
    // una condizione F3 sullo stesso campo si toglie, per lo stesso motivo di SetFilterCondition
    cxDBPivotGrid.DataController.Filter.RemoveItemByItemLink(Target.Field);

    Target.Field.Filter.FilterType := ftIncluded;

    Target.Field.Filter.Values.BeginUpdate;
    try
      Target.Field.Filter.Values.Clear;
      Target.Field.Filter.Values.Add(Target.Value);
    finally
      Target.Field.Filter.Values.EndUpdate;
    end;
  finally
    cxDBPivotGrid.EndUpdate;
  end;

  ShowFilteredValues(Target.Field);
end;

procedure TzDbPivot.ExcludeValue(const Target: TzPivotFilterTarget);
var
  FieldFilter: TcxPivotGridFieldFilter;
begin
  if not Target.HasValue then
    Exit;

  FieldFilter := Target.Field.Filter;

  // spunte gia' nella forma "solo questi valori": il valore si toglie dall'elenco.
  // Se e' l'ultimo, l'elenco vuoto vorrebbe dire "nessun filtro" e ricomparirebbe tutto.
  if FieldFilter.HasFilter and (FieldFilter.FilterType = ftIncluded) then
  begin
    if FieldFilter.Values.Count <= 1 then
    begin
      ConfirmOk(Format('"%s" è l''unico valore rimasto del campo %s: per rivedere gli altri usare Elimina filtri.', [Target.DisplayText, Target.Field.Caption]));
      Exit;
    end;

    FieldFilter.Values.Remove(Target.Value);
    Exit;
  end;

  // nessuna spunta, oppure gia' nella forma "tutti tranne": si aggiunge il valore agli esclusi
  FieldFilter.FilterType := ftExcluded;
  if FieldFilter.Values.IndexOf(Target.Value) < 0 then
    FieldFilter.Values.Add(Target.Value);
end;

procedure TzDbPivot.OpenFilterDialog;
begin
  if CanFilter then
    cxDBPivotGrid.ShowPrefilterDialog;
end;

procedure TzDbPivot.ClearFilters;
var
  i: integer;
begin
  if not CanFilter then
    Exit;

  cxDBPivotGrid.BeginUpdate;
  try
    cxDBPivotGrid.DataController.Filter.Clear;

    for i := 0 to cxDBPivotGrid.FieldCount - 1 do
      if cxDBPivotGrid.Fields[i].Filter.HasFilter then
        cxDBPivotGrid.Fields[i].Filter.Clear;
  finally
    cxDBPivotGrid.EndUpdate;
  end;
end;

procedure TzDbPivot.actFiltroPerValoreExecute(Sender: TObject);
begin
  FilterByValue(FiltroDelMenu);
end;

procedure TzDbPivot.actFiltriAvanzatiExecute(Sender: TObject);
begin
  OpenFilterDialog;
end;

procedure TzDbPivot.actEliminaFiltriExecute(Sender: TObject);
begin
  ClearFilters;
end;

procedure TzDbPivot.actSoloQuestoValoreExecute(Sender: TObject);
begin
  KeepOnlyValue(FiltroDelMenu);
end;

procedure TzDbPivot.actEscludiQuestoValoreExecute(Sender: TObject);
begin
  ExcludeValue(FiltroDelMenu);
end;

function TzDbPivot.GetProps: TzBaseComponentProps;
begin
  result := zDbPivotProps;
end;

initialization

siDbPivot := Si.AddSession('zDbPivot', true);

// Per visualizzare correttamente i float/int impostare zCtrlTType a SpinEdit
cxPivotGridDefaultFieldFloatFormat := '###,##0.00';
cxPivotGridDefaultFieldIntFormat := '###,##0';

finalization

siDbPivot := nil;

end.

// flag can_show_pippo
// action pippo
// action.update can_show_pippo

  zdbview

// https://supportcenter.devexpress.com/ticket/details/q343243/byo-pivot-filtering
// https://supportcenter.devexpress.com/ticket/details/t1137335/how-to-get-the-field-value-of-cxdbpivotgrid
// https://supportcenter.devexpress.com/ticket/details/t1137335/how-to-get-the-field-value-of-cxdbpivotgrid
