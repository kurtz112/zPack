unit zSystem;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Variants,
  System.Generics.Collections,
  System.Actions,
  System.JSON.Types,
  System.JSON.Writers,
  System.JSON.Readers,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.ActnList,
  Vcl.TMSFNCMaps,
  Vcl.TMSFNCGeocoding,
  data.db,

  FireDAC.Comp.Client,
  FireDAC.Stan.Option,
  FireDAC.DApt,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.FB,
  FireDAC.Comp.DataSet,

  dxLayoutContainer,
  dxLayoutControl,
  dxLayoutCommon,
  cxEdit,
  cxDBEdit,
  cxDBRichEdit,
  cxTextEdit,
  cxCheckBox,
  cxLabel,
  cxHyperLinkEdit,
  cxMaskEdit,
  cxImageComboBox,
  cxRadioGroup,
  cxDBLookupComboBox,
  cxDropDownEdit,
  cxSpinEdit,
  cxCalendar,
  cxCustomData,
  // TcxGridDateTimeGrouping: raggruppamento delle colonne data (TzColumn)
  cxGridCustomTableView,
  cxGridTableView,
  cxGridDBTableView,
  cxCustomPivotGrid,
  cxDBPivotGrid,
  dxBar,
  dxCore,
  cxPC,
  cxTL,
  zRestrictions.Types,
  zCollection,
  zBaseLib,
  zz.Inspector,
  zFbDataSet,
  zMetaData,
  zToolActions,
  zTypes,
  zOffice.Types,
  zLayouts,
  zProgressBox,
  zAI.Types,
  zDbChart.Types,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

// Editmask per time ore/minuti= !99:99;0;0

const // messaggi
  ZZ_BASE = WM_USER + 1971;
  ZZ_BASEFORM = ZZ_BASE + 1;
  ZZ_DBPIVOT = ZZ_BASE + 2;
  ZZ_DBVIEW = ZZ_BASE + 3;
  ZZ_DBCARD = ZZ_BASE + 4;
  ZZ_DBCARDDLG = ZZ_BASE + 5;
  ZZ_DBRECORDVIEW = ZZ_BASE + 6;
  ZZ_DBTREE = ZZ_BASE + 7;
  ZZ_DBCHART = ZZ_BASE + 8;
  ZZ_DBSCHEDULER = ZZ_BASE + 9;

const
  zExtension_System = '.LZ';
  zExtension_LastUserAndConnections = '.login';
  strCheckBox = 'CheckBox';
  strCustomEdit = 'CustomEdit';
  strImageIndex = 'ImageIndex';
  idView_Null = 'Nulla';
  idDataSet_Null = 'NULL';
  zDefaultCardCaption = '@';
  strNewLine = '<New Line>';
  strSeparator = '<Separator>';
  strEmptyCaption = '<empty>';
  strSelectedCheckBox = 'SELECTED;CheckBox;True;False';

  zCalcFieldTag = 999;
  DefaultColCount = 24;

type
  TBeforeCreateControlEvent = procedure(Sender: TObject; const Name: string; var Control: TWinControl) of object;
  TAfterCreateControlEvent = procedure(Sender: TObject; const Name: string; Control: TWinControl) of object;
  //
  TBeforeCreateDbControlEvent = procedure(Sender: TObject; const FieldName: string; var cxCustomEdit: TcxCustomEdit) of object;
  TAfterCreateDbControlEvent = procedure(Sender: TObject; const FieldName: string; cxCustomEdit: TcxCustomEdit) of object;

  TAssignDataSetEvent = procedure(DataSet: TzFbDataSet; DataSetEventKind: TDataSetEventKind; const EventName: string) of object;
  TAssignFieldOnChangeEvent = procedure(Field: TField; const EventName: string) of object;

  // TBeforeCreateControlEvent = procedure(Sender: TObject; const FieldName: string; var cxCustomEdit: TcxCustomEdit) of object;
  // TAfterCreateControlEvent = procedure(Sender: TObject; const FieldName: string; cxCustomEdit: TcxCustomEdit) of object;

  TzLastMdf = class;

  TzStoredCollectionItem = class;

  TzSecurity = class;
  TzSystem = class;

  TzAction = class;
  TzActions = class;
  TzToolFilterProps = class;
  TzToolFiltersProps = class;
  TzConnection = class;
  TzConnections = class;
  TzDataSet = class;
  TzDataSets = class;
  TzDiagramDataSet = class;
  TzDiagramDataSets = class;
  TzDataModule = class;
  TzDataModules = class;
  TzBaseComponentProps = class;
  TzControlProps = class;
  TzControls = class;
  TzDbCardFlags = class;
  TzDbCardProps = class;
  TzDbCards = class;
  TzColumn = class;
  TzColumns = class;
  TzDbViewFlags = class;
  TzBaseFilterableComponentProps = class;
  TzDbViewProps = class;
  TzDbViews = class;
  TzPivotField = class;
  TzPivotFields = class;
  TzDbPivotFlags = class;
  TzDbPivotProps = class;
  TzDbPivots = class;
  TzDbRecordViewFlags = class;
  TzRecordViewRow = class;
  TzRecordViewRows = class;
  TzDbRecordViewProps = class;
  TzDbRecordViews = class;
  TzDbTreeFlags = class;
  TzTreeColumn = class;
  TzTreeColumns = class;
  TzDbTreeProps = class;
  TzDbTrees = class;
  TzDbChartFlags = class;
  TzChartSeriesItem = class;
  TzChartSeriesItems = class;
  TzDbChartProps = class;
  TzDbCharts = class;
  TzDbSchedulerFlags = class;
  TzSchedulerMapping = class;
  TzDbSchedulerProps = class;
  TzDbSchedulers = class;
  TzDomain = class;
  TzDomains = class;
  TzForm = class;
  TzForms = class;
  TzGenerator = class;
  TzGenerators = class;
  TzLookup = class;
  TzLookups = class;
  TzPickList = class;
  TzPickLists = class;
  TzPickValue = class;
  TzPickValues = class;
  TzQueryParams = class;
  TzTableRect = class;
  TzTableRects = class;
  TzStoredProc = class;
  TzStoredProcs = class;
  TzWizardPages = class;
  TzWizard = class;
  TzWizards = class;
  TzWizardPage = class;
  TzButtonProps = class;
  TzCubes = class;
  TzSchemes = class;
  TzCubeProps = class;
  TzScheme = class;
  TzMapProps = class;
  TzMaps = class;
  TzTatukMap = class;
  TzTatukMaps = class;

  TzTip = class;
  TzTips = class;

  TEditability = (edNormal, edRequired, edReadOnly);
  TzProtocol = (zpLocal, zpNetBEUI, zpTCP_IP, zpNovell);
  TSqlFunc = (sfNone, sfSUM, sfAVG, sfCOUNT, sfMIN, sfMAX, sfByCode);
  TSqlFuncs = set of TSqlFunc;
  TDomainOrder = (doByDomain, doByTable, doByCtrlType);
  TRestrictionType = (rtNone, rtDisable, rtHide, rtReadOnly, rtCustom);
  TFilterInitialValue = (ivNull, ivDefault, ivCustom);
  TBooleanOverride = (boNull, boTrue, boFalse);

  TItemClassKind = (ickLayoutItem, ickLayoutGroup, ickLayoutEmptySpaceItem, ickLayoutSeparatorItem, ickLayoutSplitterItem, ickLayoutLabeledItem);

  TzPivotFieldKind = (fkField, // campo legato a una colonna del dataset (comportamento attuale)
    fkCalc // campo calcolato = somma di N valori del campo colonna
    );

  // Definisce il comportamento del campo calcolato nei totali
  TzPivotCalcTotalMode = (ctmNull, // cella di totale mostra vuoto (default)
    ctmZero, // cella di totale mostra 0
    ctmCalc // cella di totale partecipa normalmente al calcolo
    );

  TzLastMdf = class(TPersistent)
  private
    FUserName: string;
    FDateTime: TDateTime;
  private
    function IsUserNameStored: boolean;
    function IsDateTimeStored: boolean;
  public
    constructor Create;

    procedure Clear;
    procedure Modified;
  published
    property UserName: string read FUserName stored IsUserNameStored;
    property DateTime: TDateTime read FDateTime stored IsDateTimeStored;
  end;

  TzStoredCollectionItem = class(TzCollectionItem)
  private
    FLastMdf: TzLastMdf;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure SaveToBase(SaveToLZ: boolean = False); virtual;
    procedure Modified;
  published
    property LastMdf: TzLastMdf read FLastMdf;
  end;

  TzDescription = class(TPersistent)
  private
    FAlign: TAlign;
    FVisible: boolean;
    FDescription: TStringList;
    FSize: integer;
    procedure SetDescription(const Value: TStringList);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  public
    function IniFileName: string;
    procedure LoadFromIni(const IniSection: string);
    procedure SaveToIni(const IniSection: string);
  published
    property Description: TStringList read FDescription write SetDescription;
    property Align: TAlign read FAlign write FAlign default alRight;
    property Size: integer read FSize write FSize default 150;
    property Visible: boolean read FVisible write FVisible default False;
  end;

  // Aggiungere sempre in coda: l'ordinale non va spostato
  TzComponentType = (ctNull, ctView, ctCard, ctPivot, ctFile, ctMap, ctRecordView, ctTree, ctChart, ctScheduler);

  // Scheda propria della form al posto di TzDbCardDlg, come OnShowCard di
  // TzDbView (stessa firma: lo stesso gestore va bene per tutti i componenti)
  TzShowCardEvent = procedure(Sender: TObject; Inserting: boolean) of object;

  IzBaseComponent = interface
    ['{A4C71D3E-82F0-4B9A-9C56-1E3D07F2A8B5}']

    function GetComponentType: TzComponentType;
    function GetID: string;
    procedure SetID(const Value: string);
    function GetToolActions: TzToolActions;
    procedure SetToolActions(const Value: TzToolActions);

    // Aggiunta dichiarativa di un'azione da codice: scrive sui props persistenti
    // (con FromCode), il runtime viene rigenerato da RebuildActions/BuildFromProps.
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;

    // Contratto di configurazione lato editor (ex IzToolConfigurable, parte azioni).
    // Implementato da tutti i componenti: ogni componente espone azioni configurabili.
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    function ConfigTitle: string;

    // Rigenera l'INTERA toolbar runtime dai props: prima i filtri, poi le azioni,
    // così i filtri precedono sempre le azioni sulla barra (GetToolbar). Punto unico
    // di ricostruzione: RebuildActions/RebuildFilters delegano qui e poi persistono.
    // Non salva: il salvataggio e' responsabilita' del chiamante.
    procedure RebuildToolbar;

    // Accesso al props dichiarativo del componente. Sempre assegnato: il
    // componente crea il props se manca (come zXxxProps(CreateIfNotExists)).
    // Sola lettura per scelta: il props e' posseduto dal componente e legato
    // al suo lifecycle; le sue proprieta' interne si scrivono, l'oggetto no.
    // Rende ActionsProps ridondante (= Props.ToolActions): deprecato a favore
    // di Props, da rimuovere in una pulizia successiva.
    function GetProps: TzBaseComponentProps;
    function GetToolbar: TdxBar;

    property ComponentType: TzComponentType read GetComponentType;
    property ID: string read GetID write SetID;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ActionOwner: TComponent read GetActionOwner;
    property ActionOwnerName: string read GetActionOwnerName write SetActionOwnerName;
    property Props: TzBaseComponentProps read GetProps;
    property Toolbar: TdxBar read GetToolbar;
  end;

  IzBaseDbComponent = interface(IzBaseComponent)
    ['{B7E29F4A-C163-4D0B-AE47-2F5819C3D6E1}']

    function GetzDataSet: TzFbDataSet;
    procedure SetzDataSet(const Value: TzFbDataSet);

    property zDataSet: TzFbDataSet read GetzDataSet write SetzDataSet;
  end;

  IzBaseFilterableComponent = interface(IzBaseDbComponent)
    ['{C8F9D5E1-72A4-4A8E-BF36-E9D1F3B2A90C}']
    function GetToolFilters: TzToolFiltersProps;
    procedure SetToolFilters(const Value: TzToolFiltersProps);

    // Contratto di configurazione lato editor (ex IzToolConfigurable, parte filtri).
    // Solo i componenti filtrabili (View, Pivot) lo implementano. FiltersProps
    // collassa su ToolFilters: i due puntavano allo stesso TzToolFiltersProps.
    procedure RebuildFilters;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  end;

  TzBaseComponentProps = class(TzStoredCollectionItem)
  private
    FToolActions: TzToolActionsProps;
    FActionOwnerName: string;
    procedure SetToolActions(const Value: TzToolActionsProps);
  private
    FDescription: TzDescription;
    procedure SetDescription(const Value: TzDescription);
  protected
    function isDescriptionStored: boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; virtual;

    // Testo della descrizione dichiarativa, gia' normalizzato (Trim).
    // Stringa vuota se non valorizzata. Incapsula la catena
    // Description.Description.Text, il cui triplo nome e' ambiguo da leggere.
    function DescriptionText: string;
  published
    property ActionOwnerName: string read FActionOwnerName write FActionOwnerName;
    property Description: TzDescription read FDescription write SetDescription stored isDescriptionStored;
    property ToolActions: TzToolActionsProps read FToolActions write SetToolActions;
  end;

  TzBaseFilterableComponentProps = class(TzBaseComponentProps)
  private
    FToolFilters: TzToolFiltersProps;
    procedure SetToolFilters(const Value: TzToolFiltersProps);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ToolFilters: TzToolFiltersProps read FToolFilters write SetToolFilters;
  end;

  IzDataModule = interface
    procedure ActivateDataSet(const DataSetName: string);
    function GetDataSet(const DataSetName: string): TzFbDataSet;
    function GetDataSource(zFbDataSet: TzFbDataSet): TDataSource;
  end;

  TzLayoutItem = class(TzCollectionItem)
  private
    // --- base (tutti gli item) ---
    FAlignHorz: TdxLayoutAlignHorz;
    FAlignVert: TdxLayoutAlignVert;
    FCaption: string;
    FCaptionAlignHorz: TAlignment;
    FCaptionAlignVert: TdxAlignmentVert;
    FCaptionVisible: boolean;
    FEnabled: boolean;
    FGeneratedByController: boolean;
    FHeight: integer;
    FIdx: integer;
    FIsUserDefined: boolean;
    FItemClassKind: TItemClassKind;
    FOffsetBottom: integer;
    FOffsetLeft: integer;
    FOffsetRight: integer;
    FOffsetTop: integer;
    FPaddingBottom: integer;
    FPaddingLeft: integer;
    FPaddingRight: integer;
    FPaddingTop: integer;
    FParentName: string;
    FVisible: boolean;
    FWidth: integer;
    // --- CaptionOptions comuni ---
    FImageIndex: integer;
    FVisibleElements: TdxLayoutItemCaptionVisibleElements;
    // --- TdxLayoutItem specifico ---
    FItemCaptionLayout: TdxCaptionLayout;
    FItemCaptionWidth: integer;
    // --- TdxLayoutGroup specifico ---
    FGroupButtonOptionsAlignment: TdxLayoutGroupButtonsAlignment;
    FGroupButtonOptionsVisible: boolean;
    FGroupExpanded: boolean;
    FGroupHidden: boolean;
    FGroupHideTabs: boolean;
    FGroupItemControlAreaAlignment: TdxLayoutItemControlAreaAlignment;
    FGroupItemIndex: integer;
    FGroupLayoutDirection: TdxLayoutDirection;
    FGroupLayoutLookAndFeelException: boolean;
    FGroupLocked: boolean;
    FGroupShowBorder: boolean;
    FGroupShowExpandButton: boolean;
    FGroupShowTabFrame: boolean;
    FGroupTabbedHotTrack: boolean;
    FGroupTabbedMultiLine: boolean;
    FGroupTabbedRotate: boolean;
    FGroupTabbedTabHeight: integer;
    FGroupTabbedTabPosition: TcxTabPosition;
    FGroupTabbedTabWidth: integer;
    FGroupUseIndent: boolean;
    FScrollOptionsHorizontal: TdxLayoutGroupScrollMode;
    FScrollOptionsVertical: TdxLayoutGroupScrollMode;
    // --- TdxLayoutSplitterItem specifico ---
    FSplitterAllowCloseOnClick: boolean;
    FSplitterIsClosed: boolean;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    // base
    property AlignHorz: TdxLayoutAlignHorz read FAlignHorz write FAlignHorz default ahParentManaged;
    property AlignVert: TdxLayoutAlignVert read FAlignVert write FAlignVert default avParentManaged;
    property Caption: string read FCaption write FCaption;
    property CaptionAlignHorz: TAlignment read FCaptionAlignHorz write FCaptionAlignHorz default taLeftJustify;
    property CaptionAlignVert: TdxAlignmentVert read FCaptionAlignVert write FCaptionAlignVert default TdxAlignmentVert.tavCenter;
    property CaptionVisible: boolean read FCaptionVisible write FCaptionVisible default true;
    property Enabled: boolean read FEnabled write FEnabled default true;
    // default False (non true): il costruttore inizializza il campo a False,
    // quindi con 'default true' i record con valore True non venivano scritti
    // nello stream DFM e rientravano a False. Sono proprio i gruppi strutturali
    // del controller, che tornavano a essere trattati come item utente.
    property GeneratedByController: boolean read FGeneratedByController write FGeneratedByController default False;
    property Height: integer read FHeight write FHeight default 0;
    property Idx: integer read FIdx write FIdx default 0;
    property IsUserDefined: boolean read FIsUserDefined write FIsUserDefined default False;
    property ItemClassKind: TItemClassKind read FItemClassKind write FItemClassKind default ickLayoutItem;
    property OffsetBottom: integer read FOffsetBottom write FOffsetBottom default 0;
    property OffsetLeft: integer read FOffsetLeft write FOffsetLeft default 0;
    property OffsetRight: integer read FOffsetRight write FOffsetRight default 0;
    property OffsetTop: integer read FOffsetTop write FOffsetTop default 0;
    property PaddingBottom: integer read FPaddingBottom write FPaddingBottom default 0;
    property PaddingLeft: integer read FPaddingLeft write FPaddingLeft default 0;
    property PaddingRight: integer read FPaddingRight write FPaddingRight default 0;
    property PaddingTop: integer read FPaddingTop write FPaddingTop default 0;
    property ParentName: string read FParentName write FParentName;
    property Visible: boolean read FVisible write FVisible default true;
    property Width: integer read FWidth write FWidth default 0;
    // CaptionOptions comuni
    property ImageIndex: integer read FImageIndex write FImageIndex default -1;
    property VisibleElements: TdxLayoutItemCaptionVisibleElements read FVisibleElements write FVisibleElements default [cveImage, cveText];
    // TdxLayoutItem specifico
    property ItemCaptionLayout: TdxCaptionLayout read FItemCaptionLayout write FItemCaptionLayout default clTop;
    property ItemCaptionWidth: integer read FItemCaptionWidth write FItemCaptionWidth default 0;
    // TdxLayoutGroup specifico
    property GroupButtonOptionsAlignment: TdxLayoutGroupButtonsAlignment read FGroupButtonOptionsAlignment write FGroupButtonOptionsAlignment default gbaRight;
    property GroupButtonOptionsVisible: boolean read FGroupButtonOptionsVisible write FGroupButtonOptionsVisible default true;
    property GroupExpanded: boolean read FGroupExpanded write FGroupExpanded default true;
    property GroupHidden: boolean read FGroupHidden write FGroupHidden default False;
    property GroupHideTabs: boolean read FGroupHideTabs write FGroupHideTabs default true;
    property GroupItemControlAreaAlignment: TdxLayoutItemControlAreaAlignment read FGroupItemControlAreaAlignment write FGroupItemControlAreaAlignment default catDefault;
    property GroupItemIndex: integer read FGroupItemIndex write FGroupItemIndex default 0;
    property GroupLayoutDirection: TdxLayoutDirection read FGroupLayoutDirection write FGroupLayoutDirection default ldVertical;
    property GroupLayoutLookAndFeelException: boolean read FGroupLayoutLookAndFeelException write FGroupLayoutLookAndFeelException default False;
    property GroupLocked: boolean read FGroupLocked write FGroupLocked default False;
    property GroupShowBorder: boolean read FGroupShowBorder write FGroupShowBorder default False;
    property GroupShowExpandButton: boolean read FGroupShowExpandButton write FGroupShowExpandButton default False;
    property GroupShowTabFrame: boolean read FGroupShowTabFrame write FGroupShowTabFrame default False;
    property GroupTabbedHotTrack: boolean read FGroupTabbedHotTrack write FGroupTabbedHotTrack default False;
    property GroupTabbedMultiLine: boolean read FGroupTabbedMultiLine write FGroupTabbedMultiLine default False;
    property GroupTabbedRotate: boolean read FGroupTabbedRotate write FGroupTabbedRotate default False;
    property GroupTabbedTabHeight: integer read FGroupTabbedTabHeight write FGroupTabbedTabHeight default 0;
    property GroupTabbedTabPosition: TcxTabPosition read FGroupTabbedTabPosition write FGroupTabbedTabPosition default tpTop;
    property GroupTabbedTabWidth: integer read FGroupTabbedTabWidth write FGroupTabbedTabWidth default 0;
    property GroupUseIndent: boolean read FGroupUseIndent write FGroupUseIndent default true;
    property ScrollOptionsHorizontal: TdxLayoutGroupScrollMode read FScrollOptionsHorizontal write FScrollOptionsHorizontal default smNone;
    property ScrollOptionsVertical: TdxLayoutGroupScrollMode read FScrollOptionsVertical write FScrollOptionsVertical default smNone;
    // TdxLayoutSplitterItem specifico
    property SplitterAllowCloseOnClick: boolean read FSplitterAllowCloseOnClick write FSplitterAllowCloseOnClick default False;
    property SplitterIsClosed: boolean read FSplitterIsClosed write FSplitterIsClosed default False;
  end;

  TzGenerator = class(TzCollectionItem)
  private
    FAutoFieldName: boolean;
    FExists: boolean;
    FFieldName: TzFieldName;
    FGeneratorName: string;
    FTableName: TzTableName;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function AsText: string;
  published
    property AutoFieldName: boolean read FAutoFieldName write FAutoFieldName default true;
    property Exists: boolean read FExists write FExists default true;
    property FieldName: TzFieldName read FFieldName write FFieldName;
    property GeneratorName: string read FGeneratorName write FGeneratorName;
    property TableName: TzTableName read FTableName write FTableName;
  end;

  TzGenerators = class(TzCollection<TzGenerator>)
  public
    function FindItemByGeneratorName(GeneratorName: string): integer;
    function FindItemByTableName(TableName: string): integer;
  end;

  TzDomain = class(TzStoredCollectionItem)
  private
    FAlignment: TAlignment;
    FBlobType: TBlobType;
    FCalculated: boolean;
    FCharCase: TEditCharCase;
    FColSpan: integer;
    FCurrency: boolean;
    FDataType: TFieldType;
    FDefaultExpression: string;
    FDisplayFormat: string;
    FDisplayLabel: string;
    FDomain: string;
    FEditFormat: string;
    FEditMask: string;
    FExists: boolean;
    FFieldName: TzFieldName;
    FFieldsToClear: string;
    FHasSensitivity: boolean;
    FIdentity: boolean;
    FLookup: string;
    FMaxValue: Longint;
    FMinValue: Longint;
    FOnChange: string;
    FPasswordChar: string;
    FPickList: string;
    FSanificaEmail: boolean;
    FPrecision: integer;
    FReadOnly: boolean;
    FReadOnlyField: boolean;
    FReadOnlyOverride: TBooleanOverride;
    FRequired: boolean;
    FRequiredField: boolean;
    FRequiredOverride: TBooleanOverride;
    FSensitivity: TAISensitivity;
    FSize: integer;
    FTableName: TzTableName;
    FzCtrlType: TzCtrlType;
    function GetLookup_Obj: TzLookup;
    function GetPickList_Obj: TzPickList;
    function GetReadOnly: boolean;
    function GetRequired: boolean;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetBlobType(const Value: TBlobType);
    procedure SetCalculated(const Value: boolean);
    procedure SetCurrency(const Value: boolean);
    procedure SetDataType(const Value: TFieldType);
    procedure SetDefaultExpression(const Value: string);
    procedure SetDisplayFormat(const Value: string);
    procedure SetDisplayLabel(const Value: string);
    procedure SetDomain(const Value: string);
    procedure SetEditCharCase(const Value: TEditCharCase);
    procedure SetEditFormat(const Value: string);
    procedure SetEditMask(const Value: string);
    procedure SetExists(const Value: boolean);
    procedure SetFieldName(const Value: TzFieldName);
    procedure SetFieldsToClear(const Value: string);
    procedure SetLookup(const Value: string);
    procedure SetLookup_Obj(const Value: TzLookup);
    procedure SetMaxValue(const Value: Longint);
    procedure SetMinValue(const Value: Longint);
    procedure SetPasswordChar(const Value: string);
    procedure SetPickList(const Value: string);
    procedure SetPickList_Obj(const Value: TzPickList);
    procedure SetPrecision(const Value: integer);
    procedure SetSize(const Value: integer);
    procedure SetTableName(const Value: TzTableName);
    procedure SetzCtrlType(const Value: TzCtrlType);
  private
    procedure ReadReadOnlyFieldProperty(Reader: TReader);
    procedure WriteReadOnlyFieldProperty(Writer: TWriter);

    procedure ReadRequiredFieldProperty(Reader: TReader);
    procedure SetReadOnly(const Value: boolean);
    procedure SetRequired(const Value: boolean);
    procedure WriteRequiredFieldProperty(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    // formato JSON: __ReadOnlyField e __RequiredField, con gli stessi nomi del DFM
    procedure WriteJsonExtraProperties(Writer: TJsonTextWriter); override;
    function ReadJsonExtraProperty(const PropName: string; Reader: TJsonTextReader): boolean; override;
    class procedure DescribeJsonExtraProperties(Schema: TJsonTextWriter); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;

    function GetCtrlSize: integer;
    function DefaultColSpan(ColCount: integer = DefaultColCount): integer;
    procedure SetFieldFlagsFromMetadata(const ReadOnly, Required: boolean);

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;

    property HasSensitivity: boolean read FHasSensitivity write FHasSensitivity;
    property Sensitivity: TAISensitivity read FSensitivity write FSensitivity;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property BlobType: TBlobType read FBlobType write SetBlobType default ftblob;
    property Calculated: boolean read FCalculated write SetCalculated default False;
    property CharCase: TEditCharCase read FCharCase write SetEditCharCase; // deve salvare sempre-- default ecUpperCase;
    property Currency: boolean read FCurrency write SetCurrency default False;
    property DataType: TFieldType read FDataType write SetDataType default ftString;
    property DefaultExpression: string read FDefaultExpression write SetDefaultExpression;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property DisplayLabel: string read FDisplayLabel write SetDisplayLabel;
    property Domain: string read FDomain write SetDomain;
    property EditFormat: string read FEditFormat write SetEditFormat;
    property EditMask: string read FEditMask write SetEditMask;
    property Exists: boolean read FExists write SetExists default true;
    property FieldName: TzFieldName read FFieldName write SetFieldName;
    property FieldsToClear: string read FFieldsToClear write SetFieldsToClear;
    property Identity: boolean read FIdentity write FIdentity default False;
    property Lookup: string read FLookup write SetLookup;
    property Lookup_Obj: TzLookup read GetLookup_Obj write SetLookup_Obj stored False;
    property MaxValue: Longint read FMaxValue write SetMaxValue default 0;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
    property PasswordChar: string read FPasswordChar write SetPasswordChar;
    // True: il campo e' un indirizzo e-mail; gli editor lo normalizzano (TzSanificazioneEmail) e
    // segnalano il formato non valido. Da impostare nel dizionario dati sui domini E_MAIL,
    // OBJ_FILES_MAIL_E_MESSAGGI_INDIRIZZO, OBJ_FILES_FIRMA_EMAIL.
    property SanificaEmail: boolean read FSanificaEmail write FSanificaEmail default False;
    property PickList: string read FPickList write SetPickList;
    property PickList_Obj: TzPickList read GetPickList_Obj write SetPickList_Obj stored False;
    property Precision: integer read FPrecision write SetPrecision default 0;

    property Size: integer read FSize write SetSize default 0;
    property ColSpan: integer read FColSpan write FColSpan default 0;
    property TableName: TzTableName read FTableName write SetTableName;
    property zCtrlType: TzCtrlType read FzCtrlType write SetzCtrlType default ctDefault;

    property OnChange: string read FOnChange write FOnChange;
  published
    property ReadOnlyField: boolean read FReadOnlyField write FReadOnlyField stored False;
    property ReadOnlyOverride: TBooleanOverride read FReadOnlyOverride write FReadOnlyOverride default boNull;
    property ReadOnly: boolean read GetReadOnly write SetReadOnly stored False;
    // TODO: drop del field   property ReadOnly: boolean read FReadOnly write FReadOnly  stored False default False;

    property RequiredField: boolean read FRequiredField write FRequiredField stored False;
    property RequiredOverride: TBooleanOverride read FRequiredOverride write FRequiredOverride default boNull;
    property Required: boolean read GetRequired write SetRequired stored False;
    // property Required: boolean read FRequired write FRequired stored False default False ;
  end;

  TzDomains = class(TzCollection<TzDomain>)
  private
    class var FGeneration: Int64;
  private
    // Indice per nome (chiave AnsiUpperCase -> posizione) usato da IndexOf
    // quando IndexEnabled e' spento, cioe' sempre fuori dall'inizializzazione
    FNameIndex: TDictionary<string, integer>;
    FNameIndexGeneration: Int64;
    FNameIndexLock: TObject;
    procedure RebuildNameIndex;
    function NameIndexAligned: boolean;
  protected
    procedure Notify(Item: TCollectionItem; Action: System.Classes.TCollectionNotification); override;
    procedure ItemNameChanged(const OldName, NewName: string; const index: integer); override;
  public
    constructor Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: integer; aMaster: TzCollectionItem; const aSorted: boolean = True); override;
    destructor Destroy; override;
    function IndexOf(const Name: string; StartPos: integer = 0; ExcludeIndex: integer = -1; UseStartingWith: boolean = False): integer; overload; override;
    // Cresce a ogni aggiunta, rimozione o rinomina di un dominio, in qualunque
    // dizionario (Clear compreso): chi conserva un TzDomain trovato per nome la
    // confronta per sapere se il puntatore e' ancora valido
    class property Generation: Int64 read FGeneration;
    procedure AddNodesToTreeList(MainNode: TcxTreeListNode; DomainOrder: TDomainOrder);
    procedure FillTreeList(MasterNode: TcxTreeListNode); override;
    procedure QuickSortDomains(DomainOrder: TDomainOrder; L, R: integer);
    procedure Sort; override;
  end;

  TzLookup = class(TzCollectionItem)
  private
    FDataSet: string;
    FDbCard: string;
    FDbView: string;
    FExists: boolean;
    FIgnoreFieldReadOnly: boolean;
    FIsForeignKey: boolean;
    FKeyField: string;
    FMappings: TStringList;
    FMasterFields: string;
    FOnlyFromLookup: boolean;
    FDisplayColumns: string;
    FFieldNames: string;
    FFieldNamesFK: string;
    FTableName: string;
    FTableNameFK: string;
    function GetDataSet_Obj: TzDataSet;
    function GetDbCard_Obj: TzDbCardProps;
    function GetDbView_Obj: TzDbViewProps;
    procedure SetDataSet(const Value: string);
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetDbCard_Obj(const Value: TzDbCardProps);
    procedure SetDbView_Obj(const Value: TzDbViewProps);
    procedure SetExists(const Value: boolean);
    procedure SetIsForeignKey(const Value: boolean);
    procedure SetKeyField(const Value: string);
    procedure SetMappings(const Value: TStringList);
    procedure SetMasterFields(const Value: string);
    procedure SetDisplayColumns(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function IsMultiField: boolean;

    function GetKeyFieldForCombo(DataField: string): string;
    function GetListFieldNamesForCombo(DataField: string): string;

    procedure UpdateDisplayColumnsFromView(const Save2Zip: boolean = False);

    function FirstFieldFK: string;
  published
    property DataSet: string read FDataSet write SetDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property DbCard: string read FDbCard write FDbCard;
    property DbCard_Obj: TzDbCardProps read GetDbCard_Obj write SetDbCard_Obj stored False;

    property DbView: string read FDbView write FDbView;
    property DbView_Obj: TzDbViewProps read GetDbView_Obj write SetDbView_Obj stored False;
  published
    property TableName: string read FTableName write FTableName;
    property FieldNames: string read FFieldNames write FFieldNames;
    property TableNameFK: string read FTableNameFK write FTableNameFK;
    property FieldNamesFK: string read FFieldNamesFK write FFieldNamesFK;
  published
    property KeyField: string read FKeyField write SetKeyField;
    property DisplayColumns: string read FDisplayColumns write SetDisplayColumns;
    property MasterFields: string read FMasterFields write SetMasterFields;
    property Mappings: TStringList read FMappings write SetMappings;
  published
    property Exists: boolean read FExists write SetExists default true;
    property IsForeignKey: boolean read FIsForeignKey write SetIsForeignKey default true;
    property OnlyFromLookup: boolean read FOnlyFromLookup write FOnlyFromLookup default true;
    property IgnoreFieldReadOnly: boolean read FIgnoreFieldReadOnly write FIgnoreFieldReadOnly default true;
  end;

  TzLookups = class(TzCollection<TzLookup>)
  protected
    procedure CollectionSaved; override;
  public
    procedure SaveLookup(zLookup: TzLookup);
  end;

  TzTableRect = class(TzCollectionItem)
  private
    FHeight: integer;
    FLeft: integer;
    FTop: integer;
    FWidth: integer;
    procedure SetHeight(const Value: integer);
    procedure SetLeft(const Value: integer);
    procedure SetTop(const Value: integer);
    procedure SetWidth(const Value: integer);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Height: integer read FHeight write SetHeight default 0;
    property Left: integer read FLeft write SetLeft default 0;
    property Top: integer read FTop write SetTop default 0;
    property Width: integer read FWidth write SetWidth default 0;
  end;

  TzTableRects = class(TzCollection<TzTableRect>)
  end;

  TzDataSet = class(TzCollectionItem)
  private
    FActivationMode: TActivationMode;
    FAutoIncFields: string;
    FAutoSQL_Delete: boolean;
    FAutoSQL_Insert: boolean;
    FAutoSQL_Refresh: boolean;
    FAutoSQL_Update: boolean;
    FCountUpdatedRecords: boolean;
    FDataModule: string;
    FDefaultValues: TStrings;
    FDetailFields: string;
    FFetchGeneratorsPoint: TFDFetchGeneratorsPoint;
    FFetchRecsMax: integer;
    FFetchRowsetSize: integer;
    FExtendedFetchOptions: TzFetchOptions;
    FGenerator: string;
    FIdentityField: string;
    FFieldNameOID: string;
    FLazyCreate: boolean;
    FMasterDataSet: string;
    FMasterFields: string;
    FNewRecordOptions: TNewRecordOptions;
    FNoCopyFields: string;
    FPrimaryKeyFields: string;
    FReopenAfterPost: boolean;
    FUpdateChangedFields: boolean; // Mantis #257 - 2026-10-29
    FReportPipe: string;
    FSanification: boolean;
    FSQL_Delete: TzSQLScript;
    FSQL_Insert: TzSQLScript;
    FSQL_Refresh: TzSQLScript;
    FSQL_Select: TzSQLScript;
    FSQL_Update: TzSQLScript;
    FStrsTrim: boolean;
    FStrsTrim2Len: boolean;
    FTableName: TzTableName;
    FTableRects: TzTableRects;
    function GetGenerator_Obj: TzGenerator;
    procedure SetActivationMode(const Value: TActivationMode);
    procedure SetAutoIncFields(const Value: string);
    procedure SetDataModule(const Value: string);
    procedure SetDefaultValues(const Value: TStrings);
    procedure SetGenerator(const Value: string);
    procedure SetGenerator_Obj(const Value: TzGenerator);
    procedure SetIdentityField(const Value: string);
    procedure SetMasterDataSet(const Value: string);
    procedure SetNewRecordOptions(const Value: TNewRecordOptions);
    procedure SetNoCopyFields(const Value: string);
    procedure SetPrimaryKeyFields(const Value: string);
    procedure SetSQL_Delete(const Value: TzSQLScript);
    procedure SetSQL_Insert(const Value: TzSQLScript);
    procedure SetSQL_Refresh(const Value: TzSQLScript);
    procedure SetSQL_Select(const Value: TzSQLScript);
    procedure SetSQL_Update(const Value: TzSQLScript);
    procedure SetTableName(const Value: TzTableName);
    procedure SetTableRects(const Value: TzTableRects);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildSQL(MetaData: TzMetaData);
  published
    property ActivationMode: TActivationMode read FActivationMode write SetActivationMode default amAutomatic;
    property AutoSQL_Delete: boolean read FAutoSQL_Delete write FAutoSQL_Delete default true;
    property AutoSQL_Insert: boolean read FAutoSQL_Insert write FAutoSQL_Insert default true;
    property AutoSQL_Refresh: boolean read FAutoSQL_Refresh write FAutoSQL_Refresh default true;
    property AutoSQL_Update: boolean read FAutoSQL_Update write FAutoSQL_Update default true;
    property DataModule: string read FDataModule write SetDataModule;

    property DefaultValues: TStrings read FDefaultValues write SetDefaultValues;

    property FetchRecsMax: integer read FFetchRecsMax write FFetchRecsMax default -1; // ZZ 26.08.2022 era default =1000
    property FetchRowsetSize: integer read FFetchRowsetSize write FFetchRowsetSize default 100;
    // Mantis #183 - 2026-10-08: opzioni di lettura di zPack, passate a
    // TzFbDataSet.ExtendedFetchOptions da DataSetLoadProps (significato dei
    // valori in TzFetchOption, unit zFbDataSet). Scritte nel dizionario solo se
    // diverse dal predefinito. Attenzione a togliere zfoBlobsWithRow: su
    // INCARICHI_ELENCO 300 righe arrivano in 4,6 s invece di 6,8, ma leggerne
    // poi tutti i BLOB (una stampa) costa 27-33 s, una query per riga. Mai sui
    // dataset usati per le stampe (ReportPipe) ne' su quelli senza chiave primaria.
    property ExtendedFetchOptions: TzFetchOptions read FExtendedFetchOptions write FExtendedFetchOptions default DefaultExtendedFetchOptions;

    property FetchGeneratorsPoint: TFDFetchGeneratorsPoint read FFetchGeneratorsPoint write FFetchGeneratorsPoint default gpNone;
    property Generator: string read FGenerator write SetGenerator;
    property Generator_Obj: TzGenerator read GetGenerator_Obj write SetGenerator_Obj stored False;

    property IdentityField: string read FIdentityField write SetIdentityField;
    property FieldNameOID: string read FFieldNameOID write FFieldNameOID;

    property LazyCreate: boolean read FLazyCreate write FLazyCreate default true;
    property MasterDataSet: string read FMasterDataSet write SetMasterDataSet;
    property NewRecordOptions: TNewRecordOptions read FNewRecordOptions write SetNewRecordOptions;

    property NoCopyFields: string read FNoCopyFields write SetNoCopyFields;
    property PrimaryKeyFields: string read FPrimaryKeyFields write SetPrimaryKeyFields;
    property AutoIncFields: string read FAutoIncFields write SetAutoIncFields;

    property MasterFields: string read FMasterFields write FMasterFields;
    property DetailFields: string read FDetailFields write FDetailFields;

    property CountUpdatedRecords: boolean read FCountUpdatedRecords write FCountUpdatedRecords default true;

    property ReopenAfterPost: boolean read FReopenAfterPost write FReopenAfterPost default False;
    // Mantis #257 - 2026-10-29: True = con l'UPDATE automatico (AutoSQL_Update)
    // il salvataggio scrive solo le colonne cambiate rispetto al record letto, e
    // una scheda con dati vecchi non riscrive piu' i campi che non ha toccato
    // (TzFbDataSet.UpdateChangedFields). Predefinito False = UPDATE completo di
    // sempre: si accende dataset per dataset.
    // ATTENZIONE: accesa su un dataset, la proprieta' si scrive nel dizionario,
    // e un eseguibile precedente al Mantis #257 la segnala all'avvio come
    // errore di caricamento: accenderla solo dopo aver aggiornato tutte le
    // postazioni.
    property UpdateChangedFields: boolean read FUpdateChangedFields write FUpdateChangedFields default False;
    property ReportPipe: string read FReportPipe write FReportPipe;
    // True: al Post i campi stringa e memo modificati passano da TzSanificazione (livello sicuro).
    // False sui dataset di appoggio degli import, che devono conservare il dato grezzo.
    property Sanification: boolean read FSanification write FSanification default true;
    property SQL_Delete: TzSQLScript read FSQL_Delete write SetSQL_Delete;
    property SQL_Insert: TzSQLScript read FSQL_Insert write SetSQL_Insert;
    property SQL_Refresh: TzSQLScript read FSQL_Refresh write SetSQL_Refresh;
    property SQL_Select: TzSQLScript read FSQL_Select write SetSQL_Select;
    property SQL_Update: TzSQLScript read FSQL_Update write SetSQL_Update;
    property TableName: TzTableName read FTableName write SetTableName;
    property TableRects: TzTableRects read FTableRects write SetTableRects;

    property StrsTrim: boolean read FStrsTrim write FStrsTrim default true;
    property StrsTrim2Len: boolean read FStrsTrim2Len write FStrsTrim2Len default true;
  end;

  TzDataSets = class(TzCollection<TzDataSet>)
  public
    procedure FillTreeList(MasterNode: TcxTreeListNode); override;
  end;

  TzAction = class(TzCollectionItem)
  private
    FCaption: string;
    FHint: string;
    FHelpContext: integer;
    FHelpKeyword: string;
    FHelpType: THelpType;
    FImageIndex: TImageIndex;
    FImageName: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write FCaption;
    property Hint: string read FHint write FHint;
    property HelpContext: integer read FHelpContext write FHelpContext default 0;
    property HelpKeyword: string read FHelpKeyword write FHelpKeyword;
    property HelpType: THelpType read FHelpType write FHelpType default htKeyword;
    property ImageIndex: TImageIndex read FImageIndex write FImageIndex default -1;
    property ImageName: string read FImageName write FImageName;
  end;

  TzActions = class(TzCollection<TzAction>)
  private
  public
    // procedure InitRights(AComponent: TComponent);
    procedure LoadFromActionList(ActionList: TActionList);
    procedure InitActionList(ActionList: TActionList);
  end;

  TzDataModule = class(TzStoredCollectionItem)
  public type
    TControllerOptions = class(TPersistent)
    private
      FCreateDefaultLayout: boolean;
      FTreeMenuAutoExpand: boolean;
      FTreeMenuSearchVisible: boolean;
      FTreeMenuVisible: boolean;
      FUsePageControl: boolean;
    public
      constructor Create;
      procedure Assign(Source: TPersistent); override;
    published
      property CreateDefaultLayout: boolean read FCreateDefaultLayout write FCreateDefaultLayout default true;
      property TreeMenuVisible: boolean read FTreeMenuVisible write FTreeMenuVisible default true;
      property TreeMenuSearchVisible: boolean read FTreeMenuSearchVisible write FTreeMenuSearchVisible default False;
      property TreeMenuAutoExpand: boolean read FTreeMenuAutoExpand write FTreeMenuAutoExpand default False;

      property UsePageControl: boolean read FUsePageControl write FUsePageControl default False;
    end;

    TFormOptions = class(TPersistent)
    private
      FAIDefaultSensitivity: TAISensitivity;
      FCaption: string;
      FHelpType: THelpType;
      FHelpContext: THelpContext;
      FHelpFileName: String;
      FHelpKeyword: string;
      FReportGroup: string;
      function GetHelpFileName: String;
    public
      constructor Create;
      procedure Assign(Source: TPersistent); override;
    published
      property AIDefaultSensitivity: TAISensitivity read FAIDefaultSensitivity write FAIDefaultSensitivity default slNone;
      property Caption: string read FCaption write FCaption;
      property HelpType: THelpType read FHelpType write FHelpType;
      property HelpContext: THelpContext read FHelpContext write FHelpContext;
      property HelpKeyword: string read FHelpKeyword write FHelpKeyword;
      property HelpFileName: String read GetHelpFileName write FHelpFileName;
      property ReportGroup: string read FReportGroup write FReportGroup;
    end;

  private
    FActions: TzActions;
    FBuildGUI: boolean;
    FControllerOptions: TControllerOptions;
    FDataSets: TzDiagramDataSets;
    FFormOptions: TFormOptions;
    FLayouts: TzLayouts;
    FMainDataModule: string;
    FSubDataModules: TStringList;
    FTranslatedFormCaption: string;

    procedure SetActions(const Value: TzActions);
    procedure SetDataSets(const Value: TzDiagramDataSets);
    procedure SetLayouts(const Value: TzLayouts);
    procedure SetSubDataModules(const Value: TStringList);
  private
    procedure DestroyLinkedObjects;

    function GetPayload: String;
    procedure SetPayload(const Value: String);
  protected
    procedure SetName(const Value: string); override;

    function UniqueDataSetName(zDiagramDataSet: TzDiagramDataSet; const NewDataSetName: string): string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  public
    function FindDataSet(const DataSetName: string; ExcludedItem: TzDiagramDataSet = nil): TzDiagramDataSet;
    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;

    function LoadFromDataModule(DataModule: TDataModule): boolean;
    function IsSubDataModule: boolean;
    procedure AddSubDM(const SubDataModuleName: string);
    property SubDataModules: TStringList read FSubDataModules write SetSubDataModules;
  published
    property Actions: TzActions read FActions write SetActions;
    property BuildGUI: boolean read FBuildGUI write FBuildGUI;
    property ControllerOptions: TControllerOptions read FControllerOptions write FControllerOptions;
    property FormOptions: TFormOptions read FFormOptions write FFormOptions;
  published
    property MainDataModule: string read FMainDataModule write FMainDataModule;
    property DataSets: TzDiagramDataSets read FDataSets write SetDataSets;
    property Layouts: TzLayouts read FLayouts write SetLayouts;
    // Salva/carica l'intera struttura del datamodule
  public
    property Payload: String read GetPayload write SetPayload;
  end;

  TzDataModules = class(TzCollection<TzDataModule>)
  end;

  TzDiagramDataSet = class(TzCollectionItem)
  public type
    TMenu = class(TPersistent)
    private
      FCaption: string;
      FGroup: string;
      FTranslatedCaption: string;
      FTranslatedGroup: string;
      FVisible: boolean;
    public
      constructor Create;
      procedure Assign(Source: TPersistent); override;

      function GetCaption: string;
      function GetGroup: string;
      property TranslatedCaption: string read FTranslatedCaption write FTranslatedCaption stored False;
      property TranslatedGroup: string read FTranslatedGroup write FTranslatedGroup stored False;
    published
      property Caption: string read FCaption write FCaption;
      property Group: string read FGroup write FGroup;
      property Visible: boolean read FVisible write FVisible default true;
    end;

    TReportProps = class(TPersistent)
      constructor Create;
      destructor Destroy; override;
      procedure Assign(Source: TPersistent); override;
    private
      FPipeName: string;
      FReportGroup: string;
      FSharedReports: TStrings;
      procedure SetSharedReports(const Value: TStrings);
    published
      property ReportGroup: string read FReportGroup write FReportGroup;
      property PipeName: string read FPipeName write FPipeName;
      property SharedReports: TStrings read FSharedReports write SetSharedReports;
    end;

    // Metadati che pilotano la generazione del descrittore AI/help per questo
    // dataset. Dichiarativi e persistenti (come TMenu). Indipendenti dai
    // singoli componenti: valgono per il dataset nel suo insieme.
    TDescriptor = class(TPersistent)
    private
      FInclude: boolean;
      FNote: string;
    public
      constructor Create;
      procedure Assign(Source: TPersistent); override;
    published
      // Se False, il dataset (e i suoi componenti) viene escluso dalla
      // documentazione e dal contesto AI. I dataset con IsLookupDataSet = True
      // sono comunque sempre esclusi, a prescindere da questo flag.
      property Include: boolean read FInclude write FInclude default true;
      // Descrizione redazionale d'insieme del dataset, scritta a mano: spiega
      // a cosa serve l'entita', cosa che azioni e filtri non esprimono.
      property Note: string read FNote write FNote;
    end;

  public type
    TzDiagramCtrl = class(TzCollectionItem)
    private
      FCaption: String;
      FVisible: boolean;
      function GetCaption: String;
    protected
      procedure NameChanged(const NewName, OldName: string); virtual;
    protected
      function GetDataSetID: string;
      function isCaptionStored: boolean;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
    public
      function zDiagramDataSet: TzDiagramDataSet;
      function zComponentType: TzComponentType; virtual;
      function ComponentName: string;
      function TabSheetName: string;
      procedure SetReadOnly(const ReadOnly: boolean); virtual; abstract;
    published
      property Caption: String read GetCaption write FCaption stored isCaptionStored;
      property Visible: boolean read FVisible write FVisible default true;
    end;

    TzDiagramCtrls = class(TzCollection<TzDiagramCtrl>)
    private
      FzDiagramDataSet: TzDiagramDataSet;
      procedure NameChanged(const NewName, OldName: string); virtual;
    public
      constructor Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: integer; const azDiagramDataSet: TzDiagramDataSet); virtual;
      function VisibleCount: integer;
      property zDiagramDataSet: TzDiagramDataSet read FzDiagramDataSet;
    end;

    TDbView = class(TzDiagramCtrl)
    private
      FCardID: string;
      FViewID: string;
    protected
      procedure NameChanged(const NewName, OldName: string); override;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;
      function zDbViewProps(const CreateIfNotExists: boolean = False): TzDbViewProps;
      function GetCardID: string;
      function GetViewID: string;
    public
      procedure SetReadOnly(const ReadOnly: boolean); override;
    published
      property CardID: string read FCardID write FCardID;
      property ViewID: string read FViewID write FViewID;
    end;

    TDbViews = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbView;
      procedure SetItem(Index: integer; const Value: TDbView);
    public
      function Add: TDbView;
      function Insert(Index: integer): TDbView;
      property Items[Index: integer]: TDbView read GetItem write SetItem; default;
    end;

    TDbCard = class(TzDiagramCtrl)
    private
      FCardID: string;
    protected
      procedure NameChanged(const NewName, OldName: string); override;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;
      function zDbCardProps(const CreateIfNotExists: boolean = False): TzDbCardProps;
      function GetCardID: string;
    public
      procedure SetReadOnly(const ReadOnly: boolean); override;
    published
      property CardID: string read FCardID write FCardID;
    end;

    TDbCards = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbCard;
      procedure SetItem(Index: integer; const Value: TDbCard);
    public
      function Add: TDbCard;
      function Insert(Index: integer): TDbCard;
      property Items[Index: integer]: TDbCard read GetItem write SetItem; default;
    end;

    TDbPivot = class(TzDiagramCtrl)
    private
      FPivotID: string;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;

      function zDbPivotProps(const CreateIfNotExists: boolean = False): TzDbPivotProps;
      function GetPivotID: string;
    published
      // Vuoto = identificativo del dataset (GetDataSetID), come ViewID e CardID
      property PivotID: string read FPivotID write FPivotID;
    end;

    TDbPivots = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbPivot;
      procedure SetItem(Index: integer; const Value: TDbPivot);
    public
      function Add: TDbPivot;
      function Insert(Index: integer): TDbPivot;
      property Items[Index: integer]: TDbPivot read GetItem write SetItem; default;
    end;

    // Vista di un record (TzDbRecordView): stesso schema di TDbPivot, con un
    // identificativo esplicito fin dall'inizio
    TDbRecordView = class(TzDiagramCtrl)
    private
      FRecordViewID: string;
    protected
      procedure NameChanged(const NewName, OldName: string); override;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;

      function zDbRecordViewProps(const CreateIfNotExists: boolean = False): TzDbRecordViewProps;
      function GetRecordViewID: string;
    public
      procedure SetReadOnly(const ReadOnly: boolean); override;
    published
      // Vuoto = identificativo del dataset (GetDataSetID), come ViewID e CardID
      property RecordViewID: string read FRecordViewID write FRecordViewID;
    end;

    TDbRecordViews = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbRecordView;
      procedure SetItem(Index: integer; const Value: TDbRecordView);
    public
      function Add: TDbRecordView;
      function Insert(Index: integer): TDbRecordView;
      property Items[Index: integer]: TDbRecordView read GetItem write SetItem; default;
    end;

    // Albero dati (TzDbTree) su dataset autoreferenziato
    TDbTree = class(TzDiagramCtrl)
    private
      FTreeID: string;
    protected
      procedure NameChanged(const NewName, OldName: string); override;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;

      function zDbTreeProps(const CreateIfNotExists: boolean = False): TzDbTreeProps;
      function GetTreeID: string;
    public
      procedure SetReadOnly(const ReadOnly: boolean); override;
    published
      // Vuoto = identificativo del dataset (GetDataSetID), come ViewID e CardID
      property TreeID: string read FTreeID write FTreeID;
    end;

    TDbTrees = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbTree;
      procedure SetItem(Index: integer; const Value: TDbTree);
    public
      function Add: TDbTree;
      function Insert(Index: integer): TDbTree;
      property Items[Index: integer]: TDbTree read GetItem write SetItem; default;
    end;

    // Grafico dati (TzDbChart): sola lettura per natura, nessuna modifica dei record
    TDbChart = class(TzDiagramCtrl)
    private
      FChartID: string;
    protected
      procedure NameChanged(const NewName, OldName: string); override;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;

      function zDbChartProps(const CreateIfNotExists: boolean = False): TzDbChartProps;
      function GetChartID: string;
    public
      procedure SetReadOnly(const ReadOnly: boolean); override;
    published
      // Vuoto = identificativo del dataset (GetDataSetID), come ViewID e CardID
      property ChartID: string read FChartID write FChartID;
    end;

    TDbCharts = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbChart;
      procedure SetItem(Index: integer; const Value: TDbChart);
    public
      function Add: TDbChart;
      function Insert(Index: integer): TDbChart;
      property Items[Index: integer]: TDbChart read GetItem write SetItem; default;
    end;

    // Calendario (TzDbScheduler) su un dataset di eventi
    TDbScheduler = class(TzDiagramCtrl)
    private
      FSchedulerID: string;
    protected
      procedure NameChanged(const NewName, OldName: string); override;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;

      function zDbSchedulerProps(const CreateIfNotExists: boolean = False): TzDbSchedulerProps;
      function GetSchedulerID: string;
    public
      procedure SetReadOnly(const ReadOnly: boolean); override;
    published
      // Vuoto = identificativo del dataset (GetDataSetID), come ViewID e CardID
      property SchedulerID: string read FSchedulerID write FSchedulerID;
    end;

    TDbSchedulers = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbScheduler;
      procedure SetItem(Index: integer; const Value: TDbScheduler);
    public
      function Add: TDbScheduler;
      function Insert(Index: integer): TDbScheduler;
      property Items[Index: integer]: TDbScheduler read GetItem write SetItem; default;
    end;

    TDbFile = class(TzDiagramCtrl)
    private
      FFieldName: string;
      FFieldNameOID: String;
      FFileTypes: TzFileTypes;
      FID: string;
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;
      function GetID: string;
    published
      property FieldName: string read FFieldName write FFieldName;
      property FieldNameOID: String read FFieldNameOID write FFieldNameOID;
      property ID: string read FID write FID;
      property FileTypes: TzFileTypes read FFileTypes write FFileTypes default [ftPdf, ftWord, ftExcel, ftImage, ftMail, ftTXT, ftXML, ftJSON];
    end;

    TDbFiles = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TDbFile;
      procedure SetItem(Index: integer; const Value: TDbFile);
    public
      function Add: TDbFile;
      function Insert(Index: integer): TDbFile;
      property Items[Index: integer]: TDbFile read GetItem write SetItem; default;
    end;

    TGisMap = class(TzDiagramCtrl)
    public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;
      function zComponentType: TzComponentType; override;
    end;

    TGisMaps = class(TzDiagramCtrls)
    private
      function GetItem(Index: integer): TGisMap;
      procedure SetItem(Index: integer; const Value: TGisMap);
    public
      function Add: TGisMap;
      function Insert(Index: integer): TGisMap;
      property Items[Index: integer]: TGisMap read GetItem write SetItem; default;
    end;
    /// ////////////////////////////////////////////
  private
    FMenu: TMenu;
    FDbViews: TDbViews;
    FDbCards: TDbCards;
    FDbPivots: TDbPivots;
    FDbRecordViews: TDbRecordViews;
    FDbTrees: TDbTrees;
    FDbCharts: TDbCharts;
    FDbSchedulers: TDbSchedulers;
    FDbFiles: TDbFiles;
    FGisMaps: TGisMaps;
    procedure SetMenu(const Value: TMenu);
    procedure SetDbCards(const Value: TDbCards);
    procedure SetDbPivots(const Value: TDbPivots);
    procedure SetDbRecordViews(const Value: TDbRecordViews);
    // Collezione nuova: si scrive solo se usata, cosi' i dataset che non ne
    // hanno restano identici nel .LZ e un eseguibile precedente li legge ancora
    function IsDbRecordViewsStored: boolean;
    procedure SetDbTrees(const Value: TDbTrees);
    // come DbRecordViews: scritta solo se usata
    function IsDbTreesStored: boolean;
    procedure SetDbCharts(const Value: TDbCharts);
    // come DbRecordViews: scritta solo se usata
    function IsDbChartsStored: boolean;
    procedure SetDbSchedulers(const Value: TDbSchedulers);
    // come DbRecordViews: scritta solo se usata
    function IsDbSchedulersStored: boolean;
    procedure SetDbViews(const Value: TDbViews);
    procedure SetDbFiles(const Value: TDbFiles);
    procedure SeTGisMaps(const Value: TGisMaps);
  private
    FActualAccessLevel: TAccessLevel;
    FDefaultAccessLevel: TAccessLevel;
    FDetailDatasets: TzDiagramDataSets;
    FReportProps: TReportProps;
    FDescriptor: TDescriptor;
    FIsConcrete: boolean;
    FIsLookupDataSet: boolean;
    function GetActualAccessLevel: TAccessLevel;
    procedure SetDefaultAccessLevel(const Value: TAccessLevel);
    procedure SetDetailDatasets(const Value: TzDiagramDataSets);
    procedure SetDescriptor(const Value: TDescriptor);
  protected
    procedure SetName(const Value: string); override;
  public
    function MenuFilterOk(const Filter: string): boolean;
    function IsMenuLeaf: boolean;
    function IsMenuVisible: boolean;
  public
    function DataModule: TzDataModule;
    function HasDetailDataSets: boolean;
    function HasMasterDataSet: boolean;
    function MasterDataSet: TzDiagramDataSet;
    function idDataSet: string;
    function zDataSet(const CreateIfNotExists: boolean = False): TzDataSet;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function VisibleCount: integer;
  public
    property ActualAccessLevel: TAccessLevel read GetActualAccessLevel write FActualAccessLevel default alFull;
    property IsConcrete: boolean read FIsConcrete;
  published
    property IsLookupDataSet: boolean read FIsLookupDataSet write FIsLookupDataSet default False;
    property Menu: TMenu read FMenu write SetMenu;
    property ReportProps: TReportProps read FReportProps write FReportProps;
    property Descriptor: TDescriptor read FDescriptor write SetDescriptor;
    property DetailDatasets: TzDiagramDataSets read FDetailDatasets write SetDetailDatasets;
    property DefaultAccessLevel: TAccessLevel read FDefaultAccessLevel write SetDefaultAccessLevel default alFull;
    property DbViews: TDbViews read FDbViews write SetDbViews;
    property DbCards: TDbCards read FDbCards write SetDbCards;
    property DbPivots: TDbPivots read FDbPivots write SetDbPivots;
    property DbRecordViews: TDbRecordViews read FDbRecordViews write SetDbRecordViews stored IsDbRecordViewsStored;
    property DbTrees: TDbTrees read FDbTrees write SetDbTrees stored IsDbTreesStored;
    property DbCharts: TDbCharts read FDbCharts write SetDbCharts stored IsDbChartsStored;
    property DbSchedulers: TDbSchedulers read FDbSchedulers write SetDbSchedulers stored IsDbSchedulersStored;
    property DbFiles: TDbFiles read FDbFiles write SetDbFiles;
    property GisMaps: TGisMaps read FGisMaps write SeTGisMaps;
  end;

  TzDiagramDataSets = class(TzCollection<TzDiagramDataSet>)
  private
    _DataModule: TzDataModule;
  public
    function DataModule: TzDataModule;
    function HasMasterDataSet: boolean;
    function MasterDataSet: TzDiagramDataSet;
    function FindDataSet(const DataSetName: string; ExcludedItem: TzDiagramDataSet = nil): TzDiagramDataSet;
    function DataSetExists(const DataSetName: string): boolean;
  public type
    TEnumProc = reference to procedure(zDiagramDataSet: TzDiagramDataSet);
  public
    procedure enum(proc: TEnumProc);
  public
    constructor Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: integer; aMaster: TzCollectionItem; const aSorted: boolean = true); override;
  end;

  TzDbViewFlags = class(TPersistent)
  private
    FAutoEdit: boolean;
    FAutoWidth: boolean;
    FBorder: boolean;
    FButtonArrows: boolean;
    FButtonDelete: boolean;
    FButtonFooters: boolean;
    FButtonInsert: boolean;
    FButtonOkCancel: boolean;
    FButtonRefresh: boolean;
    FButtonUpdate: boolean;
    FCardInherits: boolean;
    FCube: boolean;
    FDblClick: boolean;
    FEditing: boolean;
    FFilters: boolean;
    FFooter: boolean;
    FGridMode: boolean;
    FGroupBy: boolean;
    FGroupFooters: TcxGridGroupFootersMode;
    FGroupsAlwaysExpanded: boolean;
    FHideFocusRectOnExit: boolean;
    FIgnoreTimeForFiltering: boolean;
    FIncrementalSearch: boolean;
    FLookups: boolean;
    FMultiselect: boolean;
    FOnChange: TNotifyEvent;
    FParams: boolean;
    FReadOnly: boolean;
    FRowSelect: boolean;
    FSearch: boolean;
    FSort: boolean;
    FToolbar: boolean;
    FUpdateCnt: integer;
    function IsUpdating: boolean;
    procedure SetAutoEdit(const Value: boolean);
    procedure SetAutoWidth(const Value: boolean);
    procedure SetBorder(const Value: boolean);
    procedure SetButtonArrows(const Value: boolean);
    procedure SetButtonDelete(const Value: boolean);
    procedure SetButtonFooters(const Value: boolean);
    procedure SetButtonInsert(const Value: boolean);
    procedure SetButtonOkCancel(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetButtonUpdate(const Value: boolean);
    procedure SetCardInherits(const Value: boolean);
    procedure SetCube(const Value: boolean);
    procedure SetDblClick(const Value: boolean);
    procedure SetEditing(const Value: boolean);
    procedure SetFilters(const Value: boolean);
    procedure SetFooter(const Value: boolean);
    procedure SetGridMode(const Value: boolean);
    procedure SetGroupBy(const Value: boolean);
    procedure SetGroupFooters(const Value: TcxGridGroupFootersMode);
    procedure SetGroupsAlwaysExpanded(const Value: boolean);
    procedure SetHideFocusRectOnExit(const Value: boolean);
    procedure SetIgnoreTimeForFiltering(const Value: boolean);
    procedure SetIncrementalSearch(const Value: boolean);
    procedure SetLookups(const Value: boolean);
    procedure SetMultiselect(const Value: boolean);
    procedure SetParams(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetRowSelect(const Value: boolean);
    procedure SetSearch(const Value: boolean);
    procedure SetSort(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property AutoEdit: boolean read FAutoEdit write SetAutoEdit default true;
    property AutoWidth: boolean read FAutoWidth write SetAutoWidth default False;
    property Border: boolean read FBorder write SetBorder default False;
    property ButtonArrows: boolean read FButtonArrows write SetButtonArrows default true;
    property ButtonDelete: boolean read FButtonDelete write SetButtonDelete default true;
    property ButtonInsert: boolean read FButtonInsert write SetButtonInsert default true;
    property ButtonOkCancel: boolean read FButtonOkCancel write SetButtonOkCancel default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    property ButtonUpdate: boolean read FButtonUpdate write SetButtonUpdate default true;
    property ButtonFooters: boolean read FButtonFooters write SetButtonFooters default true;
    property CardInherits: boolean read FCardInherits write SetCardInherits default true;

    property Cube: boolean read FCube write SetCube default False;
    property DblClick: boolean read FDblClick write SetDblClick default true;
    property Editing: boolean read FEditing write SetEditing default False;
    property Filters: boolean read FFilters write SetFilters default true;
    property Footer: boolean read FFooter write SetFooter default False;
    property GridMode: boolean read FGridMode write SetGridMode default true;
    property GroupBy: boolean read FGroupBy write SetGroupBy default False;
    property GroupFooters: TcxGridGroupFootersMode read FGroupFooters write SetGroupFooters default gfInvisible;
    // Gruppi sempre aperti (dcoGroupsAlwaysExpanded): un elenco raggruppato
    // per data che si apre con i gruppi chiusi mostra "Oggi", "Ieri"... e
    // nessuna riga, e la griglia li richiude a ogni rilettura
    property GroupsAlwaysExpanded: boolean read FGroupsAlwaysExpanded write SetGroupsAlwaysExpanded default False;
    property IgnoreTimeForFiltering: boolean read FIgnoreTimeForFiltering write SetIgnoreTimeForFiltering default true;
    property IncrementalSearch: boolean read FIncrementalSearch write SetIncrementalSearch default true;
    property Lookups: boolean read FLookups write SetLookups default False;
    property Multiselect: boolean read FMultiselect write SetMultiselect default true;
    property Params: boolean read FParams write SetParams default False;
    property Readonly: boolean read FReadOnly write SetReadOnly default False;
    property RowSelect: boolean read FRowSelect write SetRowSelect default False;
    property HideFocusRectOnExit: boolean read FHideFocusRectOnExit write SetHideFocusRectOnExit default true;
    property Search: boolean read FSearch write SetSearch default False;
    property Sort: boolean read FSort write SetSort default true;
    property Toolbar: boolean read FToolbar write SetToolbar default true;
  end;

  TzDbViewProps = class(TzBaseFilterableComponentProps)
  private
    FButtonDelete: TzButtonProps;
    FButtonEdit: TzButtonProps;
    FButtonInsert: TzButtonProps;
    FButtonDuplica: TzButtonProps;
    FColumns: TzColumns;
    FConditionalFormatting: string;
    FDataSet: string;
    FDlgHeight: integer;
    FDlgWidth: integer;
    FFlags: TzDbViewFlags;
    FPreviewFieldName: string;
    FSearchFields: string;
    FTitle: string;
    function GetDataSet_Obj: TzDataSet;
    procedure SetButtonDelete(const Value: TzButtonProps);
    procedure SetButtonEdit(const Value: TzButtonProps);
    procedure SetButtonInsert(const Value: TzButtonProps);
    procedure SetButtonDuplica(const Value: TzButtonProps);
    procedure SetColumns(const Value: TzColumns);
    procedure SetDataSet(const Value: string);
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetSearchFields(const Value: string);
    procedure SetTitle(const Value: string);
  protected
    function IsBtn_DeleteStored: boolean;
    function IsBtn_EditStored: boolean;
    function IsBtn_InsertStored: boolean;
    function IsBtn_DuplicaStored: boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    function LoadFromBase: boolean;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property ButtonDelete: TzButtonProps read FButtonDelete write SetButtonDelete stored IsBtn_DeleteStored;
    property ButtonEdit: TzButtonProps read FButtonEdit write SetButtonEdit stored IsBtn_EditStored;
    property ButtonInsert: TzButtonProps read FButtonInsert write SetButtonInsert stored IsBtn_InsertStored;
    property ButtonDuplica: TzButtonProps read FButtonDuplica write SetButtonDuplica stored IsBtn_DuplicaStored;
    property Columns: TzColumns read FColumns write SetColumns;
    property ConditionalFormatting: string read FConditionalFormatting write FConditionalFormatting;
    property DataSet: string read FDataSet write SetDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property DlgHeight: integer read FDlgHeight write FDlgHeight default 450;
    property DlgWidth: integer read FDlgWidth write FDlgWidth default 500;

    property Flags: TzDbViewFlags read FFlags write FFlags;
    property PreviewFieldName: string read FPreviewFieldName write FPreviewFieldName;
    property SearchFields: string read FSearchFields write SetSearchFields;
    property Title: string read FTitle write SetTitle;
  end;

  TzDbCardProps = class(TzBaseFilterableComponentProps)
  private
    FBlobLines: integer;
    FButtonDelete: TzButtonProps;
    FButtonEdit: TzButtonProps;
    FButtonInsert: TzButtonProps;
    FButtonDuplica: TzButtonProps;
    FCaption: string;
    FControls: TzControls;
    FLayout: TzLayoutItems;
    FDataSet: string;
    FDlgHeight: integer;
    FDlgWidth: integer;
    FEditCalculated: boolean;
    FFlags: TzDbCardFlags;
    FTitle: string;
    FColCount: integer;
    FSnapToGrid: boolean;
    FCaptionLayout: TdxCaptionLayout;
    FAutoFitHeight: boolean;
    function GetDataSet_Obj: TzDataSet;
    procedure SetButtonDelete(const Value: TzButtonProps);
    procedure SetButtonEdit(const Value: TzButtonProps);
    procedure SetButtonInsert(const Value: TzButtonProps);
    procedure SetButtonDuplica(const Value: TzButtonProps);
    procedure SetCaption(const Value: string);
    procedure SetControls(const Value: TzControls);
    procedure SetDataSet(const Value: string);
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetDlgWidth(const Value: integer);
    procedure SetLayout(const Value: TzLayoutItems);
    procedure SetTitle(const Value: string);
  protected
    function IsBtn_DeleteStored: boolean;
    function IsBtn_EditStored: boolean;
    function IsBtn_InsertStored: boolean;
    function IsBtn_DuplicaStored: boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property BlobLines: integer read FBlobLines write FBlobLines default 5;
    property ButtonDelete: TzButtonProps read FButtonDelete write SetButtonDelete stored IsBtn_DeleteStored;
    property ButtonEdit: TzButtonProps read FButtonEdit write SetButtonEdit stored IsBtn_EditStored;
    property ButtonInsert: TzButtonProps read FButtonInsert write SetButtonInsert stored IsBtn_InsertStored;
    property ButtonDuplica: TzButtonProps read FButtonDuplica write SetButtonDuplica stored IsBtn_DuplicaStored;
    property Caption: string read FCaption write SetCaption;

    property CaptionLayout: TdxCaptionLayout read FCaptionLayout write FCaptionLayout default clTop;
    property ColCount: integer read FColCount write FColCount default DefaultColCount;
    // Allineamento verticale: aggancia le larghezze dei controlli a una
    // griglia di ColCount colonne per riga (vedi TzControls.BuildLayoutItems).
    // Ogni slot viene allargato al multiplo di colonna successivo, così i
    // bordi coincidono tra righe diverse.
    property SnapToGrid: boolean read FSnapToGrid write FSnapToGrid default true;
    // Altezza adattata al contenuto: la card sopra una griglia prende l'altezza
    // delle sue righe, senza barra di scorrimento. Nelle form del FormController
    // si adatta il gruppo dei dettagli (vedi TzDbCard.ApplyAutoFitHeight).
    property AutoFitHeight: boolean read FAutoFitHeight write FAutoFitHeight default False;
    property Controls: TzControls read FControls write SetControls;
    property Layout: TzLayoutItems read FLayout write SetLayout;
    property DataSet: string read FDataSet write SetDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property DlgHeight: integer read FDlgHeight write FDlgHeight default -1; // 450;
    property DlgWidth: integer read FDlgWidth write SetDlgWidth default -1; // 500;
    property EditCalculated: boolean read FEditCalculated write FEditCalculated stored False default False;
    property Flags: TzDbCardFlags read FFlags write FFlags;
    property Title: string read FTitle write SetTitle;
  end;

  TzDbPivotFlags = class(TPersistent)
  private
    FButtonArrows: boolean;
    FButtonExpand: boolean;
    FButtonExpandCaption: boolean;
    FButtonRefresh: boolean;
    FColumnFields: boolean;
    FColumnGrandTotals: boolean;
    FColumnGrandTotalText: string;
    FColumnTotals: boolean;
    FDataFields: boolean;
    FDrawExpandButtons: boolean;
    FDrillDown: boolean;
    FExpandColumns: boolean;
    FExpandInnerLevels: boolean;
    FExpandRows: boolean;
    FFilter: boolean;
    FFilterFields: boolean;
    FFilterSeparator: boolean;
    FGrandTotalsForSingleValues: boolean;
    FHideColumnFields: boolean;
    FHideDataFields: boolean;
    FHideFilterFields: boolean;
    FHideRowFields: boolean;
    FMarkNarrowCells: boolean;
    FOnChange: TNotifyEvent;
    FParams: boolean;
    FRowFields: boolean;
    FRowGrandTotals: boolean;
    FRowGrandTotalText: string;
    FRowTotals: boolean;
    FRowTreeLayout: boolean;
    FToolbar: boolean;
    FTotalsForSingleValues: boolean;
    FUpdateCnt: integer;
    function IsUpdating: boolean;
    procedure SetButtonArrows(const Value: boolean);
    procedure SetButtonExpand(const Value: boolean);
    procedure SetButtonExpandCaption(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetColumnFields(const Value: boolean);
    procedure SetColumnGrandTotals(const Value: boolean);
    procedure SetColumnGrandTotalText(const Value: string);
    procedure SetColumnTotals(const Value: boolean);
    procedure SetDataFields(const Value: boolean);
    procedure SetDrawExpandButtons(const Value: boolean);
    procedure SetDrillDown(const Value: boolean);
    procedure SetExpandColumns(const Value: boolean);
    procedure SetExpandInnerLevels(const Value: boolean);
    procedure SetExpandRows(const Value: boolean);
    procedure SetFilter(const Value: boolean);
    procedure SetFilterFields(const Value: boolean);
    procedure SetFilterSeparator(const Value: boolean);
    procedure SetGrandTotalsForSingleValues(const Value: boolean);
    procedure SetHideColumnFields(const Value: boolean);
    procedure SetHideDataFields(const Value: boolean);
    procedure SetHideFilterFields(const Value: boolean);
    procedure SetHideRowFields(const Value: boolean);
    procedure SetMarkNarrowCells(const Value: boolean);
    procedure SetParams(const Value: boolean);
    procedure SetRowFields(const Value: boolean);
    procedure SetRowGrandTotals(const Value: boolean);
    procedure SetRowGrandTotalText(const Value: string);
    procedure SetRowTotals(const Value: boolean);
    procedure SetRowTreeLayout(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
    procedure SetTotalsForSingleValues(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property ButtonArrows: boolean read FButtonArrows write SetButtonArrows default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    property ButtonExpand: boolean read FButtonExpand write SetButtonExpand default true;
    // Scritta accanto all'icona dei pulsanti Espandi e Riduci nella barra
    property ButtonExpandCaption: boolean read FButtonExpandCaption write SetButtonExpandCaption default False;

    property Params: boolean read FParams write SetParams default False;

    property Toolbar: boolean read FToolbar write SetToolbar default true;
    property Filter: boolean read FFilter write SetFilter default False;

    property DrawExpandButtons: boolean read FDrawExpandButtons write SetDrawExpandButtons default true;
    property DrillDown: boolean read FDrillDown write SetDrillDown default False;
    property ExpandRows: boolean read FExpandRows write SetExpandRows default False;
    property ExpandColumns: boolean read FExpandColumns write SetExpandColumns default False;
    // Aprendo una riga del primo livello si aprono da soli tutti i livelli sotto di lei
    property ExpandInnerLevels: boolean read FExpandInnerLevels write SetExpandInnerLevels default False;

    property HideColumnFields: boolean read FHideColumnFields write SetHideColumnFields default False;
    property HideDataFields: boolean read FHideDataFields write SetHideDataFields default False;
    property HideFilterFields: boolean read FHideFilterFields write SetHideFilterFields default False;
    property HideRowFields: boolean read FHideRowFields write SetHideRowFields default False;

    // OptionsView

    // property ColumnFields: boolean read FColumnFields write SetColumnFields default true;
    property ColumnGrandTotals: boolean read FColumnGrandTotals write SetColumnGrandTotals default true;
    property ColumnGrandTotalText: string read FColumnGrandTotalText write SetColumnGrandTotalText;
    property ColumnTotals: boolean read FColumnTotals write SetColumnTotals default true;
    // property DataFields: boolean read FDataFields write SetDataFields default true;
    // property FilterFields: boolean read FFilterFields write SetFilterFields default true;
    property FilterSeparator: boolean read FFilterSeparator write SetFilterSeparator default true;
    property GrandTotalsForSingleValues: boolean read FGrandTotalsForSingleValues write SetGrandTotalsForSingleValues default False;
    property MarkNarrowCells: boolean read FMarkNarrowCells write SetMarkNarrowCells default False;
    // property RowFields: boolean read FRowFields write SetRowFields default true;
    property RowGrandTotals: boolean read FRowGrandTotals write SetRowGrandTotals default true;
    property RowGrandTotalText: string read FRowGrandTotalText write SetRowGrandTotalText;
    property RowTotals: boolean read FRowTotals write SetRowTotals default true;
    // Tutti i campi riga in una sola colonna ad albero (RowTotalsLocation = rtlTree)
    property RowTreeLayout: boolean read FRowTreeLayout write SetRowTreeLayout default False;
    property TotalsForSingleValues: boolean read FTotalsForSingleValues write SetTotalsForSingleValues default False;
  end;

  TzDbPivotProps = class(TzBaseFilterableComponentProps)
  private
    FBestFitAfterExpand: boolean;
    FCaption: string;
    FFields: TzPivotFields;
    FDataSet: string;
    FFlags: TzDbPivotFlags;
    FTitle: string;
    function GetDataSet_Obj: TzDataSet;
    procedure SetCaption(const Value: string);
    procedure SetFields(const Value: TzPivotFields);
    procedure SetDataSet(const Value: string);
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetTitle(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property BestFitAfterExpand: boolean read FBestFitAfterExpand write FBestFitAfterExpand default true;
    property Caption: string read FCaption write SetCaption;
    property Fields: TzPivotFields read FFields write SetFields;
    property DataSet: string read FDataSet write SetDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property Flags: TzDbPivotFlags read FFlags write FFlags;
    property Title: string read FTitle write SetTitle;
  end;

  TzFileViewerProps = class(TzBaseComponentProps)
  private
    FDataSet: string;
    FFieldName: string;
    FFieldNameOID: string;
    FFolder: string;
    FLocked: boolean;
    function GetDataSet_Obj: TzDataSet;
    procedure SetDataSet(const Value: string);
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetFieldName(const Value: string);
    procedure SetFieldNameOID(const Value: string);
    procedure SetFolder(const Value: string);
    procedure SetLocked(const Value: boolean);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property DataSet: string read FDataSet write SetDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property FieldName: string read FFieldName write SetFieldName;
    property FieldNameOID: string read FFieldNameOID write SetFieldNameOID;
    property Folder: string read FFolder write SetFolder;
    property Locked: boolean read FLocked write SetLocked default False;
  end;

  TzFileViewersProps = class(TzCollection<TzFileViewerProps>)
  end;

  TzDbViews = class(TzCollection<TzDbViewProps>)
  public
    procedure FillTreeList(MasterNode: TcxTreeListNode); override;
  end;

  TzDbCards = class(TzCollection<TzDbCardProps>)
  public
    procedure FillTreeList(MasterNode: TcxTreeListNode); override;
  end;

  TzDbPivots = class(TzCollection<TzDbPivotProps>)
  public
    // procedure FillTreePivot(Nodes: TTreeNodes); override;
  end;

  TCollection2Save = (csAll, csMetadata, csFieldProps, csDataDictionary, csDataModules, csLookups, csSqlCommands, csStoredProcs, csGenerators, csDataSets, csDbViews, csDbCards, csDbPivots, csPickLists, csForms, csWizards, csPolicies, csCubes, csMaps,
    csFiles, csTips, csDbRecordViews, csDbTrees, csDbCharts, csDbSchedulers);

  TzSystem = class(TComponent)
  private
    FAppName: string;
    FFileName: string;
    FImageList16: TCustomImagelist;
    FImageList24: TCustomImagelist;
    FMetaData: TzMetaData;
    FOnCustomDialog: TzCustomDialogEvent;
    FOnHyperLink: TzHyperLinkEvent;
    FOnAssignDataSetEvent: TAssignDataSetEvent;
    FParams: TStringList;
    FQueryParams: TzQueryParams;
    FModified: boolean;
    FzCubes: TzCubes;
    FzDataDictionary: TzDomains;
    FzDataModules: TzDataModules;
    FzDataSets: TzDataSets;
    FzDbCards: TzDbCards;
    FzDbViews: TzDbViews;
    FzDbPivots: TzDbPivots;
    FzDbRecordViews: TzDbRecordViews;
    FzDbTrees: TzDbTrees;
    FzDbCharts: TzDbCharts;
    FzDbSchedulers: TzDbSchedulers;
    FzFiles: TzFileViewersProps;
    FzFbDatabase: TzFbDatabase;
    FzFbTransaction: TzFbTransaction;
    FzForms: TzForms;
    FzGenerators: TzGenerators;
    FzLoaded: boolean;
    FzLookups: TzLookups;
    FzPickLists: TzPickLists;
    FzSecurity: TzSecurity;
    FzStoredProcs: TzStoredProcs;
    FzWizards: TzWizards;
    FzTatukMaps: TzTatukMaps;
    FzMaps: TzMaps;
    function GetFileName: string;
    procedure InitPropertyEditors;
    procedure SetFileName(const Value: string);
    procedure SeTCustomImagelist16(const Value: TCustomImagelist);
    procedure SeTCustomImagelist24(const Value: TCustomImagelist);
    procedure SetParams(const Value: TStringList);
    procedure SetQueryParams(const Value: TzQueryParams);
    procedure SetzCubes(const Value: TzCubes);
    procedure SetzDataDictionary(const Value: TzDomains);
    procedure SetzDataModules(const Value: TzDataModules);
    procedure SetzDataSets(const Value: TzDataSets);
    procedure SetzDbCards(const Value: TzDbCards);
    procedure SetzDbViews(const Value: TzDbViews);
    procedure SetzFiles(const Value: TzFileViewersProps);
    procedure SetzFbDatabase(const Value: TzFbDatabase);
    procedure SetzFbTransaction(const Value: TzFbTransaction);
    procedure SetzForms(const Value: TzForms);
    procedure SetzGenerators(const Value: TzGenerators);
    procedure SetzLookups(const Value: TzLookups);
    procedure SetzPickLists(const Value: TzPickLists);
    procedure SetzSecurity(const Value: TzSecurity);
    procedure SetzStoredProcs(const Value: TzStoredProcs);
    procedure SetzWizards(const Value: TzWizards);
    procedure zPropertyInspectorGetEditorClass(Sender: TObject; AInstance: TPersistent; APropInfo: PPropInfo; var AEditorClass: TzPropEditorClass);
    procedure SetzMaps(const Value: TzMaps);
    procedure SetzTatukMaps(const Value: TzTatukMaps);
  protected

    procedure InitParams;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property zLoaded: boolean read FzLoaded write FzLoaded;
  private
    DisableHyperLink: boolean;
    FZipBusy: boolean;

    function GetIsAdmin: boolean;
    procedure SetModified(const Value: boolean);
    procedure SetzDbPivots(const Value: TzDbPivots);
    procedure SetzDbRecordViews(const Value: TzDbRecordViews);
    procedure SetzDbTrees(const Value: TzDbTrees);
    procedure SetzDbCharts(const Value: TzDbCharts);
    procedure SetzDbSchedulers(const Value: TzDbSchedulers);
    procedure UpdateStructure;
    // Il corpo comune di SaveZip e SaveZipUnattended, dopo i controlli.
    procedure WriteZip(Collection2Save: TCollection2Save; const Msg2Log, UserName, BackupFolder: string);
    // Copia di sicurezza dell'archivio nella cartella indicata (una per minuto).
    procedure BackupZipIn(const BackupFolder: string);
    //
    procedure DataSetRecordLimitReached(Sender: TObject);
  private
    FFDPhysFBDriverLink: TFDPhysFBDriverLink;
    FIsAdminDisabled: boolean;
    FOnAssignFieldOnChangeEvent: TAssignFieldOnChangeEvent;
    FzTips: TzTips;
  private
    FolderCache: TDictionary<string, string>;

    // Mantis #106 - 2026-09-10: mappa Origin (TABELLA.CAMPO) -> valore di DEFAULT
    // letto dai MetaData, con dentro solo i campi che un default ce l'hanno.
    // Serve a InitFields e vale per tutta la sessione: vedi MetaDataDefault.
    MetaDefaults: TDictionary<string, string>;
    MetaDefaultsCount: integer;

    function MetaDataDefault(const FieldOrigin: string): string;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddQueryParam(ParamName: string; Value: Variant);
  public
    procedure Login(const AllowParams: boolean; const ShowWaitForm: boolean = true; callback: TProc = nil);

    procedure CheckAdmin;
    procedure ResetAdmin;
    procedure ForceAdmin(const Admin: boolean);
  public

    procedure CustomDialog(Sender: TObject; Field: TField; TagString: string; var Value: Variant);
    //
    procedure DataSetLoadProps(DataSet: TzFbDataSet);
    function DataSetEditProps(DataSet: TzFbDataSet): boolean;

    procedure DataSetQueryParams(DataSet: TDataSet);
    procedure InitFields(DataSet: TDataSet);
    procedure AssignFieldOnChangeEvent(Field: TField; const EventName: string);
    //
    function GetDomain(Field: TField): TzDomain;
    //
    function GetHelpContext(Ctrl: TWinControl): integer;
    //
  public
    //
    procedure HyperLink(Sender: TObject; FieldName: string; Value: Variant);

    procedure InitializeFromDB();
    // Come InitializeFromDB, senza finestre e senza salvare: rilegge il
    // MetaData dal database indicato e riallinea il dizionario (Init_zSystem).
    // Per chi lavora senza interfaccia (zMCP_LZ chiamato da zBuilder); il
    // salvataggio si chiede poi con SaveZipUnattended.
    procedure UpdateFromDB(Database: TzFbDatabase; Transaction: TzFbTransaction; CallBack: TProc<string>);

    procedure LoadZip(const ShowWaitForm: boolean = true);
    procedure SaveZip(Collection2Save: TCollection2Save; Msg2Log: string);
    // Salvataggio senza utente collegato, per i programmi senza interfaccia:
    // SaveZip esce se nessuno ha fatto il login da amministratore, qui la
    // decisione di salvare l'ha gia' presa chi chiama. UserName va nel
    // Log.txt dell'archivio; la copia di sicurezza va nella cartella BackupLZ
    // accanto all'archivio (SaveZip la mette accanto all'eseguibile, che per
    // l'applicazione e' la stessa cartella). Solleva se il dizionario non e'
    // caricato o se un altro salvataggio e' in corso.
    procedure SaveZipUnattended(Collection2Save: TCollection2Save; const Msg2Log, UserName: string);
    procedure SaveChanges;
    procedure BackupZip;
    //
    function Get_IdDataSet(DataSet: TzFbDataSet): string;

    function GetSqlDomainFromMetaData(RelationName, FieldName: string): string;
  private
    function CurrentUser: string;
    function GetCanCreateUser: boolean;
    function GetCanEditRestrictions: boolean;

    function GetConfigs(const Name: string): string;
    function GetFolders(const Name: string): string;
    function GetSettings(const Name: string): string;
    function GetSkinName: string;
    function GetSkinPaletteName: string;
    procedure SetConfigs(const Name: string; const Value: string);
    procedure SetFolders(const Name: string; const Value: string);
    procedure SetSettings(const Name: string; const Value: string);
    procedure SetSkinName(const Value: string);
    procedure SetSkinPaletteName(const Value: string);
    procedure SetzTips(const Value: TzTips);
  public
    function SettingExists(const Name: string; const TrueIfAdmin: boolean = true): boolean;
    function Setting(const Name: string; default: string): string;
    property Settings[const Name: string]: string read GetSettings write SetSettings;
  public
    function ConfigExists(const Name: string; const TrueIdAdmin: boolean = true): boolean;
    function Config(const Name: string; default: string): string;
    property Configs[const Name: string]: string read GetConfigs write SetConfigs;
  public
    function Folder(const Name: string; defaultFolder: string): string;
    property Folders[const Name: string]: string read GetFolders write SetFolders;
  public
    function PersonalFolder: string;
    function ConfigFolder: string;
    function ConfigFileName(Ext: string): string;

    function RootFolder(const FolderName, defaultFolder: string): string;
    function Root_Config: string;
    function Root_PersonalData: string;
    function Root_Files: string;
  public
    function Authorizhed(const Authorization: string; const TrueIdAdmin: boolean = true): boolean;
    procedure Autorun(Actions: TActionList);
  public
    function GetLookup(const IdLookup: string; DataSet: TzFbDataSet; const KeyField: String = ''; const ListFields: string = ''): TzLookup;
    function ShowSystemForm: boolean;
    procedure SwitchLookupCtrlType(FromCtrlType, ToCtrlType: TzCtrlType);
    procedure UpdateGenerators;
    property Params: TStringList read FParams write SetParams;
    property QueryParams: TzQueryParams read FQueryParams write SetQueryParams;
    property ImageList16: TCustomImagelist read FImageList16 write SeTCustomImagelist16;
    property ImageList24: TCustomImagelist read FImageList24 write SeTCustomImagelist24;
    property Modified: boolean read FModified write SetModified;

    property IsAdmin: boolean read GetIsAdmin;
    property IsAdminDisabled: boolean read FIsAdminDisabled write FIsAdminDisabled;
    //
    property CanCreateUser: boolean read GetCanCreateUser;
    property CanEditRestrictions: boolean read GetCanEditRestrictions;
    //
    property MetaData: TzMetaData read FMetaData;

    property SkinName: string read GetSkinName write SetSkinName;
    property SkinPaletteName: string read GetSkinPaletteName write SetSkinPaletteName;

    property ZipBusy: boolean read FZipBusy;
  published
    property AppName: string read FAppName write FAppName;
    property FileName: string read GetFileName write SetFileName;

    property zCubes: TzCubes read FzCubes write SetzCubes stored False;
    property zDataDictionary: TzDomains read FzDataDictionary write SetzDataDictionary stored False;
    property zDataModules: TzDataModules read FzDataModules write SetzDataModules stored False;
    property zDataSets: TzDataSets read FzDataSets write SetzDataSets stored False;
    property zDbCards: TzDbCards read FzDbCards write SetzDbCards stored False;
    property zDbViews: TzDbViews read FzDbViews write SetzDbViews;
    property zDbPivots: TzDbPivots read FzDbPivots write SetzDbPivots;
    property zDbRecordViews: TzDbRecordViews read FzDbRecordViews write SetzDbRecordViews;
    property zDbTrees: TzDbTrees read FzDbTrees write SetzDbTrees;
    property zDbCharts: TzDbCharts read FzDbCharts write SetzDbCharts;
    property zDbSchedulers: TzDbSchedulers read FzDbSchedulers write SetzDbSchedulers;
    property zFiles: TzFileViewersProps read FzFiles write SetzFiles;
    property zForms: TzForms read FzForms write SetzForms;
    property zGenerators: TzGenerators read FzGenerators write SetzGenerators stored False;
    property zLookups: TzLookups read FzLookups write SetzLookups;
    property zPickLists: TzPickLists read FzPickLists write SetzPickLists stored False;
    property zSecurity: TzSecurity read FzSecurity write SetzSecurity stored False;
    property zStoredProcs: TzStoredProcs read FzStoredProcs write SetzStoredProcs stored False;
    property zTips: TzTips read FzTips write SetzTips stored False;
    property zWizards: TzWizards read FzWizards write SetzWizards;

    property zMaps: TzMaps read FzMaps write SetzMaps;
    property zTatukMaps: TzTatukMaps read FzTatukMaps write SetzTatukMaps;

    property OnCustomDialog: TzCustomDialogEvent read FOnCustomDialog write FOnCustomDialog;
    property OnHyperLink: TzHyperLinkEvent read FOnHyperLink write FOnHyperLink;
    // Mantis #183 - 2026-10-08: non piu' chiamato. Lo innescava solo
    // TzDataSet.DefaultEvents, tolto perche' nessun dizionario lo valorizzava
    // (i gestori di Gesty, zTicser e Analysir si limitavano a registrare il
    // nome). Resta finche' ConfigModule.dfm di quelle tre applicazioni lo
    // assegna: toglierlo prima bloccherebbe la lettura del .dfm all'avvio.
    property OnAssignDataSetEvent: TAssignDataSetEvent read FOnAssignDataSetEvent write FOnAssignDataSetEvent;
    property OnAssignFieldOnChangeEvent: TAssignFieldOnChangeEvent read FOnAssignFieldOnChangeEvent write FOnAssignFieldOnChangeEvent;

    property zFbDatabase: TzFbDatabase read FzFbDatabase write SetzFbDatabase;
    property zFbTransaction: TzFbTransaction read FzFbTransaction write SetzFbTransaction;
    property FDPhysFBDriverLink: TFDPhysFBDriverLink read FFDPhysFBDriverLink write FFDPhysFBDriverLink;
  public
    procedure DropCollectionDuplicates;
  end;

  TzQueryParam = class(TzCollectionItem)
  private
    FValue: Variant;
    procedure SetValue(const Value: Variant);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Value: Variant read FValue write SetValue;
  end;

  TzQueryParams = class(TzCollection<TzQueryParam>)
  public
    procedure SetDataSetParams(DataSet: TzFbDataSet);
  end;

  TzPickValue = class(TzCollectionItem)
  private
    FImageIndex: TImageIndex;
    FIndent: integer;
    FValue: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property ImageIndex: TImageIndex read FImageIndex write FImageIndex default -1;
    property Indent: integer read FIndent write FIndent default -1;
    property Value: string read FValue write FValue;
  end;

  TzPickValues = class(TzCollection<TzPickValue>)
  public
    function PickList: TzPickList;
    function GetPickListDescription: string;
  end;

  TzPickList = class(TzCollectionItem)
  private
    FDescription: TStringList;
    FPickValues: TzPickValues;
    procedure SetPickValues(const Value: TzPickValues);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignToProps(Props: TcxImageComboBoxProperties); overload;
    procedure AssignToStrings(strings: TStrings);
    procedure AssignDescriptonToItems;
    function ItemsMatchDescription(Source: TStrings): Boolean;
    function UpdateDescription(Source: TStrings): Boolean;
    function AsText: string;
  published
    property Description: TStringList read FDescription write FDescription;
    property PickValues: TzPickValues read FPickValues write SetPickValues;
  end;

  TzPickLists = class(TzCollection<TzPickList>)
  public
    procedure SavePickList(PickList: TzPickList);
  end;

  TzForm = class(TzCollectionItem)
  private
    FCaption: string;
    FDataModule: string;
    FHelpKeyword: string;
    FReportGroup: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write FCaption;
    property DataModule: string read FDataModule write FDataModule;
    property HelpKeyword: string read FHelpKeyword write FHelpKeyword;
    property ReportGroup: string read FReportGroup write FReportGroup;
  end;

  TzForms = class(TzCollection<TzForm>)
  end;

  TzTip = class(TzCollectionItem)
  private
    FDescription: string;
    FFormName: string;
    FHeaderText: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FormName: string read FFormName write FFormName;
    property HeaderText: string read FHeaderText write FHeaderText;
    property Description: string read FDescription write FDescription;

    // property Glyph: TdxSmartGlyph read FGlyph write SetGlyph;
    // property GlyphFixedWidth: Boolean read FGlyphFixedWidth write SetGlyphFixedWidth default True;
    // property PlainText: Boolean read FPlainText write SetPlainText default True;
    // property Text: string read FText write SetText;
    // property TextAlign: TdxScreenTipBandTextAlign read FTextAlign write SetTextAlign default stbtaRight;

    // tip.HeaderText
    // tip.HeaderGlyph ?
    // tip.Description
    // tip.DescriptionGlyph
    // tip.Footer
    // tip.FooterGlyph
    // tip.UseHintAsHeader := true;
    // tip.UseStandardFooter := true;
  end;

  TzTips = class(TzCollection<TzTip>)
  public
    procedure LoadFromActionList(const FormName: string; ActionList: TActionList);
  end;

  TzConnection = class(TzCollectionItem)
  private
    FCharacterSet: string;
    FClientLibrary: string;
    FDataBase: string;
    FdbPassword: string;
    FdbUser: string;
    FParams: TStringList;
    FProtocol: TzProtocol;
    FServerName: string;
    FSqlRole: string;
    function GetdbPassword: string;
    procedure SetCharacterSet(const Value: string);
    procedure SetClientLibrary(const Value: string);
    procedure SetDataBase(const Value: string);
    procedure SetdbPassword(const Value: string);
    procedure SetdbUser(const Value: string);
    procedure SetParams(const Value: TStringList);
    procedure SetProtocol(const Value: TzProtocol);
    procedure SetServerName(const Value: string);
    procedure SetSqlRole(const Value: string);
  private
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    procedure InitDataBase(db: TzFbDatabase; FDPhysFBDriverLink: TFDPhysFBDriverLink; UserName, Password: string);

    procedure GetUserAndPassword(UserName: String; out dbUsername, dbPassword: string);
  published
    // Ordine di dichiarazione = ordine nell'ispettore della form sicurezza,
    // che non ordina piu' per nome: prima dove sta il database, poi con chi
    // ci si presenta, poi i dettagli del client.
    property ServerName: string read FServerName write SetServerName;
    property Protocol: TzProtocol read FProtocol write SetProtocol;
    property DataBase: string read FDataBase write SetDataBase;
    property dbUser: string read FdbUser write SetdbUser;
    property dbPassword: string read GetdbPassword write SetdbPassword;
    property SqlRole: string read FSqlRole write SetSqlRole;
    property CharacterSet: string read FCharacterSet write SetCharacterSet;
    property ClientLibrary: string read FClientLibrary write SetClientLibrary;
    property Params: TStringList read FParams write SetParams;
  end;

  TzConnections = class(TzCollection<TzConnection>)
  end;

  TLoginParams = class
  private
    FAuthorizations: TStrings;
    FAutorunActions: TStrings;
    FConnectionName: string;
    FHyperlinks: TStrings;
    FLoggedIn: boolean;
    FPasswordExpired: boolean;
    FPasswordExpireDate: TDateTime;
    FSecondiAllaVerificaAccesso: integer;
    FSessionID: integer;
    FUserCanCreateUser: boolean;
    FUserCanEditRestrictions: boolean;
    FUserCanEditHelp: boolean;
    FUserDisplayName: string;
    FUserFolder: string;
    FUserID: integer;
    FUserIsAdmin: boolean;
    FUserName: string;
    FUserPassword: string;
    FUserRole: string;
    zSecurity: TzSecurity;
    procedure SetUserIsAdmin(const Value: boolean);
  public
    constructor Create(aSecurity: TzSecurity);
    destructor Destroy; override;
    function Authorizhed(const Authorization: string): boolean;
    procedure Autorun(Actions: TActionList);
    procedure Clear;
    procedure PasswordChanged(const NewPassword: string);
    procedure SetParams(const aConnectionName, aUserName: String); overload;
    procedure SetParams(const aConnectionName, aUserName, aUserPassword: String; const aSessionId, aUserId: integer; aUserDisplayName: String; aPasswordExpireDate: TDateTime;
      IsAdmin, CanCreateUser, CanEditRestrictions, CanEditHelp: boolean); overload;
    // Fasce orarie 2026-09-18: va chiamata dopo SetParams, che azzera tutto.
    procedure SetVerificaAccesso(const Secondi: integer);
    // Sessione valida dopo il secondo fattore 2026-10-17: va chiamata dopo
    // SetParams, che azzera tutto.
    procedure SetPermessiSistema(const CanCreateUser, CanEditRestrictions, CanEditHelp: boolean);
    property Authorizations: TStrings read FAuthorizations;
    property AutorunActions: TStrings read FAutorunActions;
    property Hyperlinks: TStrings read FHyperlinks;
    property ConnectionName: string read FConnectionName;
    property LoggedIn: boolean read FLoggedIn;
    property PasswordExpired: boolean read FPasswordExpired;
    property PasswordExpireDate: TDateTime read FPasswordExpireDate;
    // Fasce orarie 2026-09-18: secondi che mancano al prossimo cambio di
    // verdetto sull'accesso. Zero = nessun limite, oppure database che non
    // conosce ancora le fasce.
    property SecondiAllaVerificaAccesso: integer read FSecondiAllaVerificaAccesso;
    property SessionID: integer read FSessionID;
    property UserDisplayName: string read FUserDisplayName;
    property UserFolder: string read FUserFolder;
    property UserID: integer read FUserID;
    property UserIsAdmin: boolean read FUserIsAdmin write SetUserIsAdmin;
    property UserName: string read FUserName;
    property UserPassword: string read FUserPassword;
    property UserRole: string read FUserRole;
    property UserCanCreateUser: boolean read FUserCanCreateUser;
    property UserCanEditRestrictions: boolean read FUserCanEditRestrictions;
    property UserCanEditHelp: boolean read FUserCanEditHelp;
  end;

  TzSecurity = class(TzPersistent)
  private
    FAfterLogin: TNotifyEvent;
    FBeforeLogin: TNotifyEvent;
    // FEurekaProps: TzEurekaProps;
    FFileName: string;
    FLocked: boolean;
    FLoginParams: TLoginParams;
    FSaveOnRestore: TNotifyEvent;
    FUnlockDlgShowing: boolean;
    FzConnections: TzConnections;
    function GetFileName: string;
    function GetIsAdmin: boolean;
    procedure ConnectionsLoadError(Sender: TObject; const ErrorMessage: string; var Handled: boolean; var IgnoreAll: boolean);
    procedure BackupZip;
    procedure LoadAuthorizations;
    procedure LoadAutoruns;
    procedure LoadHyperLinks;
    // procedure SetEurekaProps(const Value: TzEurekaProps);
    procedure SetFileName(const Value: string);
    procedure SetIsAdmin(const Value: boolean);
    procedure SeTzConnections(const Value: TzConnections);
    function UnlockHook(var Message: TMessage): boolean;
  private
    FExecuteLoginSP: boolean;
    OTP_Required: boolean;
    OTP_Ok: boolean;
    // Secondo fattore con app di autenticazione (TOTP) 2026-10-16. Lo stato
    // vale per il database collegato: 0 = non ancora controllato, 1 = l'app
    // si puo' usare, 2 = no (database senza USR_TOTP_DISPONIBILE o
    // senza chiave di cifratura).
    FTotpDisponibile: integer;
    FTotpCodiceRecuperoUsato: boolean;
    FTotpCodiciRecuperoRestanti: integer;
    procedure OTP_SendMail2User(const idSessione: integer);
    function OTP_Query(out token: string): boolean;
    function OTP_Validate(const idSessione: integer; const token: string): boolean;

    procedure EseguiStoredProcTotp(sp: TFDStoredProc);
    function TotpAttivo: boolean;
    function TotpAttiva(const Codice: string; out MessaggioErrore: string): boolean;
    function TOTP_Validate(const idSessione: integer; const Codice: string; out MessaggioErrore: string): boolean;
    function TotpRegistraInterno(const TestoAnnulla: string): boolean;
    procedure TotpImpostaCodiciRecupero;
    procedure TotpProponiRegistrazione;
    procedure TotpAvvisoCodiceRecupero;
    function OTP_QueryMail: boolean;
    function SecondoFattoreVerifica: boolean;
    procedure LeggiPermessiSistema;
  protected
    zSystem: TzSystem;
    procedure DoAfterLogin; dynamic;
    procedure DoBeforeLogin; dynamic;
    function doChangePassword(const OldPassword, NewPassword: string): boolean;
    function doLogin(const ConnectionName, UserName, Password: string): boolean;
    function DoUnlockDialog: boolean; virtual;
    procedure LoadLastUserAndConnection(out UserName, Connection: string);
    procedure SaveLastUserAndConnection(const UserName, Connection: string);
  public
    constructor Create(aSystem: TzSystem);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    // Applica a dx lo skin e la tavolozza memorizzati nel file .login accanto
    // all'eseguibile. E' una class procedure perche' serve anche prima che
    // TzSecurity esista: la schermata di avvio di DevExpress compare gia' in
    // Application.Initialize, molto prima della finestra di accesso, e senza
    // questa chiamata resterebbe con i colori predefiniti.
    class procedure LoadSkinFromIni;
    // Mantis #286 - 2026-10-26: scrive una voce del file .login senza mai
    // sollevare. Il file serve solo a ricordare utente, connessione e skin:
    // se non e' scrivibile si perde il ricordo, non l'accesso. False se la
    // scrittura non e' riuscita (il motivo va nel registro)
    class function ScriviFileLogin(const Chiave, Valore: string): boolean;
    function ChangePassword: boolean;
    procedure LoadZip;
    //
    procedure Lock;
    function LoggedIn: boolean;
    function Login(const AllowParams: boolean): boolean;
    procedure SaveZip;
    //
    procedure ShowSecurityForm;
    procedure TerminateApplication;
    //
    // App di autenticazione dell'utente collegato, da offrire nel menu
    // dell'applicazione. TotpDisponibile dice se il database la prevede.
    function TotpDisponibile: boolean;
    function TotpRegistra: boolean;
    function TotpRigeneraCodiciRecupero: boolean;
    // Solo per l'amministratore: l'utente registrera' una nuova app
    procedure TotpAzzera(const UserID: integer);
    property IsAdmin: boolean read GetIsAdmin write SetIsAdmin;
    property LoginParams: TLoginParams read FLoginParams; // write FLoginParams;
  published
    // property EurekaProps: TzEurekaProps read FEurekaProps write SetEurekaProps stored False;
    property FileName: string read GetFileName write SetFileName;
    property zConnections: TzConnections read FzConnections write SeTzConnections stored False;
    property AfterLogin: TNotifyEvent read FAfterLogin write FAfterLogin;
    property BeforeLogin: TNotifyEvent read FBeforeLogin write FBeforeLogin;
    property ExecuteLoginSP: boolean read FExecuteLoginSP write FExecuteLoginSP;
  end;

  TzStoredProc = class(TzCollectionItem)
  private
    FSQL: TStringList;
    FStoredProc: string;
    procedure SetSQL(const Value: TStringList);
    procedure SetStoredProc(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property SQL: TStringList read FSQL write SetSQL;
    property StoredProc: string read FStoredProc write SetStoredProc;
  end;

  TzStoredProcs = class(TzCollection<TzStoredProc>)
  end;

  TzWizardPage = class(TzCollectionItem)
  private
    FHeader: string;
    FSubtitle: TStringList;
    procedure SetHeader(const Value: string);
    procedure SetSubtitle(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Header: string read FHeader write SetHeader;
    property Subtitle: TStringList read FSubtitle write SetSubtitle;
  end;

  TzWizardPages = class(TzCollection<TzWizardPage>)
  end;

  TzWizard = class(TzCollectionItem)
  private
    FPages: TzWizardPages;
    procedure SetPages(const Value: TzWizardPages);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Pages: TzWizardPages read FPages write SetPages;
  end;

  TzWizards = class(TzCollection<TzWizard>)
  end;

  TzButtonProps = class(TPersistent)
  private
    FCaption: string;
    FDisplayCaptionInToolbar: boolean;
    FHint: string;
    FImageIndex: integer;
    FVisible: boolean;
    procedure SetCaption(const Value: string);
    procedure SetDisplayCaptionInToolbar(const Value: boolean);
    procedure SetHint(const Value: string);
    procedure SetImageIndex(const Value: integer);
    procedure SetVisible(const Value: boolean);
  protected
    function isCaptionStored: boolean;
    function IsHintStored: boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function IsStored: boolean;

    procedure Apply(Action: TContainedAction; btn: TdxBarButton);
  published
    property Caption: string read FCaption write SetCaption stored isCaptionStored;
    property DisplayCaptionInToolbar: boolean read FDisplayCaptionInToolbar write SetDisplayCaptionInToolbar default False;
    property Hint: string read FHint write SetHint stored IsHintStored;
    property ImageIndex: integer read FImageIndex write SetImageIndex default -1;
    // Eliminare
    property Visible: boolean read FVisible write SetVisible stored False default true;
  end;

  TzScheme = class(TzCollectionItem)
  private
    FChart: TStringList;
    FScheme: TStringList;
    procedure SetChart(const Value: TStringList);
    procedure SetScheme(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Chart: TStringList read FChart write SetChart;
    property Scheme: TStringList read FScheme write SetScheme;
  end;

  TzSchemes = class(TzCollection<TzScheme>)
  end;

  TzCubeProps = class(TzCollectionItem)
  private
    FAutoOpen: boolean;
    FFields: TStringList;
    FSchemes: TzSchemes;
    procedure SetAutoOpen(const Value: boolean);
    procedure SetFields(const Value: TStringList);
    procedure SetSchemes(const Value: TzSchemes);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoOpen: boolean read FAutoOpen write SetAutoOpen default true;
    property Fields: TStringList read FFields write SetFields;
    property Schemes: TzSchemes read FSchemes write SetSchemes;
  end;

  TzCubes = class(TzCollection<TzCubeProps>)
  end;

  TzTatukMap = class(TzCollectionItem)
  private
    FDetailField: string;
    FDetailLayer: string;
    FMasterField: string;
    FMiniMapLayer: string;
    FMultiRecord: boolean;
    FProject: TStringList;
    FScopes: TStringList;
    procedure SetProject(const Value: TStringList);
    procedure SetScopes(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property DetailField: string read FDetailField write FDetailField;
    property DetailLayer: string read FDetailLayer write FDetailLayer;
    property MasterField: string read FMasterField write FMasterField;
    property MiniMapLayer: string read FMiniMapLayer write FMiniMapLayer;
    property MultiRecord: boolean read FMultiRecord write FMultiRecord;
    property Project: TStringList read FProject write SetProject;
    property Scopes: TStringList read FScopes write SetScopes;
  end;

  TzTatukMaps = class(TzCollection<TzTatukMap>)
  end;

  TzMapProps = class(TzBaseComponentProps)
  private
    FGeocodingService: TTMSFNCGeocodingService;
    FMapChangedInterval: integer;
    FMapService: TTMSFNCMapsService;
    FZoomLevel: integer;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property GeocodingService: TTMSFNCGeocodingService read FGeocodingService write FGeocodingService default gsOpenStreetMap;
    property MapService: TTMSFNCMapsService read FMapService write FMapService default msOpenLayers;
    property MapChangedInterval: integer read FMapChangedInterval write FMapChangedInterval default 300;
    property ZoomLevel: integer read FZoomLevel write FZoomLevel default 12;
  end;

  TzMaps = class(TzCollection<TzMapProps>)
  end;

  TzColumn = class(TzCollectionItem)
  private
    FCaption: string;
    // Nome del dominio, non il puntatore: zDataDictionary viene svuotato a ogni
    // LoadZip (Aggiorna cache) e un puntatore conservato dalle colonne resterebbe
    // appeso a un TzDomain liberato
    FDomainName: string;
    // Ultimo dominio trovato per FDomainName, con il dizionario e la sua
    // generazione: GetDomain lo riusa finche' il dizionario non cambia, perche'
    // la ricerca per nome in zDataDictionary e' lineare (circa 29.000 domini in
    // Gesty) e le griglie con i totali leggono Domain piu' volte per colonna a
    // ogni cambio di record
    FDomainCache: TzDomain;
    FDomainCacheDictionary: TzDomains;
    FDomainCacheGeneration: Int64;
    FDomainCacheValid: boolean;
    FFieldOrigin: string;
    FDateTimeGrouping: TcxGridDateTimeGrouping;
    FFooterKind: TcxSummaryKind;
    FGroupFooterKind: TcxSummaryKind;
    FGroupIndex: integer;
    FReadOnly: boolean;
    FSortOrder: TcxDataSortOrder;
    FVisible: boolean;
    FWidth: integer;
    FzCtrlType: TzCtrlType;
    function GetCaption: string;
    function GetDomain: TzDomain;
    function GetzCtrlType: TzCtrlType;
    function isCaptionStored: boolean;
    function IsCtrlTypeStored: boolean;
    procedure SetDomain(const Value: TzDomain);
    // Copia nome e dominio gia' risolto da un'altra colonna, senza cercarlo
    procedure CopyDomainFrom(Source: TzColumn);
  public
    FooterValue: Variant;
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure ClearFooterValue;
    property Domain: TzDomain read GetDomain write SetDomain;
    // FCaption senza fallback al domain: usato per distinguere "personalizzato" da "default"
    property RawCaption: string read FCaption write FCaption;
  published
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    property Caption: string read GetCaption write FCaption;
    property FooterKind: TcxSummaryKind read FFooterKind write FFooterKind default skNone;
    property GroupIndex: integer read FGroupIndex write FGroupIndex default -1;
    // Come si raggruppa una colonna data: dtgRelativeToToday da' i gruppi
    // Oggi, Ieri, Settimana scorsa..., come nei programmi di posta. Vale solo
    // quando la colonna e' raggruppata (GroupIndex >= 0)
    property DateTimeGrouping: TcxGridDateTimeGrouping read FDateTimeGrouping write FDateTimeGrouping default dtgDefault;
    // Ordine di partenza della colonna, e dei suoi gruppi se raggruppata:
    // soDescending mette in cima i piu' recenti. soNone = lascia quello
    // della griglia (ordine della query, o scelto dall'utente)
    property SortOrder: TcxDataSortOrder read FSortOrder write FSortOrder default soNone;
    property GroupFooterKind: TcxSummaryKind read FGroupFooterKind write FGroupFooterKind default skNone;

    property ReadOnly: boolean read FReadOnly write FReadOnly default true;
    property Visible: boolean read FVisible write FVisible default true;
    property Width: integer read FWidth write FWidth default -1;
    property zCtrlType: TzCtrlType read GetzCtrlType write FzCtrlType stored IsCtrlTypeStored default ctDefault;
  end;

  TzColumns = class(TzCollection<TzColumn>)
  private
    zDbViewProps: TzDbViewProps;
    function GetVisibleFields: string;
    procedure SetVisibleFields(const Value: string);
  private
    // eliminare
    function GetSelected: string;
  private
    procedure CheckEmptyCaptions;
  public
    constructor Create(azDbViewProps: TzDbViewProps);
    //
    procedure ResetColumnCaptions;
    // imposta/legge da grid
    procedure AssignFromGridColumns(const idDataSet: string; View: TcxGridDBTableView; const ViewID: string);
    procedure AssignToGridColumns(const idDataSet: string; View: TcxGridDBTableView; const ViewID: string);
    procedure ClearFooterValues;
    function ComboColumns(DataSet: TzFbDataSet; const MaxColumns: integer): string;
    procedure FillTreeList(MasterNode: TcxTreeListNode); override;

    function HasFooter: boolean;
    // verifica l apresenza dei campi, aggiunge quelli nuovi
    procedure Reset(DataSet: TzFbDataSet);
    procedure ValidateDataset(DataSet: TzFbDataSet);
    property VisibleFields: string read GetVisibleFields write SetVisibleFields;
  end;

  TControlRowPlacement = (rpAuto, rpForceNewLine, rpSameRow);

  TzControlProps = class(TzCollectionItem)
  private
    FDisplayLabel: string;
    FDomain: TzDomain;
    FDummy: integer;
    FFieldOrigin: string;
    FGroup: string;
    FGroupExpandButton: boolean;
    FGroupExpanded: boolean;
    FImageName: string;
    FLines: integer;
    FNewLineBefore: boolean;
    FReadOnly: boolean;
    FRequired: boolean;
    FSeparator: boolean;
    FSeparatorCaption: string;
    FSize: integer;
    FVisible: boolean;
    FzCtrlType: TzCtrlType;
    FColSpan: integer;
    FRowPlacement: TControlRowPlacement;
    function GetzCtrlType: TzCtrlType;
    function IsCtrlTypeStored: boolean;
    function IsDisplayLabelStored: boolean;
    procedure SetDisplayLabel(const Value: string);
    procedure SetGroup(const Value: string);
    procedure SetNewLineBefore(const Value: boolean);
    procedure SetRowPlacement(const Value: TControlRowPlacement);
    procedure SetzCtrlType(const Value: TzCtrlType);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;

    function IsDataAware: boolean;

    function GetEffectiveDisplayLabel: string;
    property Domain: TzDomain read FDomain write FDomain;
  published
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    property DisplayLabel: string read FDisplayLabel write SetDisplayLabel stored IsDisplayLabelStored;
    property Lines: integer read FLines write FLines default -1;

    property RowPlacement: TControlRowPlacement read FRowPlacement write SetRowPlacement default rpAuto;
    property NewLineBefore: boolean read FNewLineBefore write SetNewLineBefore default False; // deprecated 'Usa RowPlacement';

    property ReadOnly: boolean read FReadOnly write FReadOnly default False;
    property Required: boolean read FRequired write FRequired default False;

    property Separator: boolean read FSeparator write FSeparator default False; // deve andare su zCtrlType=ctSeparator
    property SeparatorCaption: string read FSeparatorCaption write FSeparatorCaption; // deve andare su zCtrlType=ctSeparator

    property Group: string read FGroup write SetGroup;
    // Solo per zCtrlType=ctGroupBox/ctCheckGroupBox: bottone di collasso
    // nella caption del gruppo e ultimo stato espanso/collassato.
    // Persistiti qui (non nel Layout) perché gli item generati dal
    // controller non vengono serializzati (vedi zLayouts.LoadFromLayout).
    property GroupExpandButton: boolean read FGroupExpandButton write FGroupExpandButton default False;
    property GroupExpanded: boolean read FGroupExpanded write FGroupExpanded default true;
    // Icona accanto all'etichetta (campi), nel titolo (gruppi, separatori) o
    // sul pulsante: nome del file SVG del catalogo dx.Immagini senza
    // estensione, tradotto in indice con dx.IndiceIcona a ogni costruzione.
    // Nome assente dal catalogo = nessuna icona.
    property ImageName: string read FImageName write FImageName;
    property ColSpan: integer read FColSpan write FColSpan default 0;
    property Size: integer read FSize write FSize default -1;
    property Visible: boolean read FVisible write FVisible default true;
    property Width: integer read FDummy write FDummy stored False;
    property zCtrlType: TzCtrlType read GetzCtrlType write SetzCtrlType stored IsCtrlTypeStored default ctDefault;
  end;

  TzControls = class(TzCollection<TzControlProps>)
  private
  public
    constructor Create;
    procedure ValidateDataset(DataSet: TzFbDataSet; const Reset: boolean);
    // Converte gli item legacy ctLineBreak in RowPlacement=rpForceNewLine sul
    // controllo successivo (stesso gruppo), poi li rimuove. ctLineBreak resta
    // nell'enum per il load di dati vecchi ma non e' piu' prodotto/interpretato.
    procedure MigrateLineBreaksToRowPlacement;

    procedure FillTreeList(MasterNode: TcxTreeListNode); override;
  end;

  TzDbCardFlags = class(TPersistent)
  private
    FAutoEdit: boolean;
    FBorder: boolean;
    FButtonArrows: boolean;
    FButtonDelete: boolean;
    FButtonInsert: boolean;
    FButtonOkCancel: boolean;
    FButtonRefresh: boolean;
    FButtonUpdate: boolean;
    FOnChange: TNotifyEvent;
    FReadOnly: boolean;
    FToolbar: boolean;
    FUpdateCnt: integer;
    function IsUpdating: boolean;
    procedure SetAutoEdit(const Value: boolean);
    procedure SetBorder(const Value: boolean);
    procedure SetButtonArrows(const Value: boolean);
    procedure SetButtonDelete(const Value: boolean);
    procedure SetButtonInsert(const Value: boolean);
    procedure SetButtonOkCancel(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetButtonUpdate(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property AutoEdit: boolean read FAutoEdit write SetAutoEdit default true;
    property Border: boolean read FBorder write SetBorder default False;
    property ButtonArrows: boolean read FButtonArrows write SetButtonArrows default true;
    property ButtonDelete: boolean read FButtonDelete write SetButtonDelete default true;
    property ButtonInsert: boolean read FButtonInsert write SetButtonInsert default true;
    property ButtonOkCancel: boolean read FButtonOkCancel write SetButtonOkCancel default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    property ButtonUpdate: boolean read FButtonUpdate write SetButtonUpdate default true;

    property Readonly: boolean read FReadOnly write SetReadOnly default False;
    property Toolbar: boolean read FToolbar write SetToolbar default true;
  end;

  TzPivotField = class(TzCollectionItem)
  private
    FArea: TcxPivotGridFieldArea;
    FAreaIndex: integer;
    FCaption: string;
    FDataVisibility: TcxPivotGridFieldDataVisibility;
    FDisplayFormat: string;
    FDomain: TzDomain;
    FFieldOrigin: string;
    FGroupIndex: integer;
    FHidden: boolean;
    FMaxWidth: integer;
    FMinWidth: integer;
    FSizeable: boolean;
    FSortOrder: TcxDataSortOrder;
    FSummaryType: TcxPivotGridSummaryType;
    FSummaryVariation: TcxPivotGridSummaryVariation;
    FTopValueCount: integer;
    FTopValueShowOthers: boolean;
    FTotalsVisibility: TcxPivotGridTotalsVisibility;
    FVisible: boolean;
    FWidth: integer;
    FzCtrlType: TzCtrlType;
    FKind: TzPivotFieldKind;
    FColumnFieldName: string;
    FColumnValues: TStrings;
    FGrandTotalExcludeValues: TStrings;
    FSourceFieldName: string;
    FTotalMode: TzPivotCalcTotalMode;
    function GetCaption: string;
    function GetzCtrlType: TzCtrlType;
    function isCaptionStored: boolean;
    function IsCtrlTypeStored: boolean;
    procedure SetColumnValues(const Value: TStrings);
    procedure SetGrandTotalExcludeValues(const Value: TStrings);
  private
    procedure ReadKind(Reader: TReader);
    procedure WriteKind(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    // formato JSON: Kind, con lo stesso nome del DFM
    procedure WriteJsonExtraProperties(Writer: TJsonTextWriter); override;
    function ReadJsonExtraProperty(const PropName: string; Reader: TJsonTextReader): boolean; override;
    class procedure DescribeJsonExtraProperties(Schema: TJsonTextWriter); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Domain: TzDomain read FDomain write FDomain;
    property Kind: TzPivotFieldKind read FKind write FKind default fkField;
  published
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    property Area: TcxPivotGridFieldArea read FArea write FArea default faFilter;
    property AreaIndex: integer read FAreaIndex write FAreaIndex default -1;
    property DataVisibility: TcxPivotGridFieldDataVisibility read FDataVisibility write FDataVisibility default dvAllCells;
    property DisplayFormat: string read FDisplayFormat write FDisplayFormat;
    property GroupIndex: integer read FGroupIndex write FGroupIndex default -1;
    property Hidden: boolean read FHidden write FHidden default False;
    property MinWidth: integer read FMinWidth write FMinWidth default cxPivotGridDefaultFieldMinWidth;
    property SummaryType: TcxPivotGridSummaryType read FSummaryType write FSummaryType default stSum;
    property SortOrder: TcxDataSortOrder read FSortOrder write FSortOrder default soNone;
    property SummaryVariation: TcxPivotGridSummaryVariation read FSummaryVariation write FSummaryVariation default svNone;
    property TotalsVisibility: TcxPivotGridTotalsVisibility read FTotalsVisibility write FTotalsVisibility default tvAutomatic;
    property TopValueCount: integer read FTopValueCount write FTopValueCount default 0;
    property TopValueShowOthers: boolean read FTopValueShowOthers write FTopValueShowOthers default False;

    property Caption: string read GetCaption write FCaption;
    property Sizeable: boolean read FSizeable write FSizeable default true;
    property Visible: boolean read FVisible write FVisible default true;
    property MaxWidth: integer read FMaxWidth write FMaxWidth default 0;
    property Width: integer read FWidth write FWidth default -1;
    property zCtrlType: TzCtrlType read GetzCtrlType write FzCtrlType stored IsCtrlTypeStored default ctDefault;
    // Per Calculated
    property SourceFieldName: string read FSourceFieldName write FSourceFieldName;
    property ColumnFieldName: string read FColumnFieldName write FColumnFieldName;
    property ColumnValues: TStrings read FColumnValues write SetColumnValues;
    property TotalMode: TzPivotCalcTotalMode read FTotalMode write FTotalMode default ctmNull;
    // Valori del gruppo di colonna esclusi dal totale generale di riga
    // (es. una colonna che è già un totale derivato e non va contata due volte).
    // Lista non vuota => il campo passa a stCustom col gestore condiviso
    // TzDbPivot.GrandTotalExcludeSummary. ATTENZIONE: il confronto avviene sul
    // valore VISUALIZZATO della colonna, una rinomina della voce rompe l'esclusione.
    property GrandTotalExcludeValues: TStrings read FGrandTotalExcludeValues write SetGrandTotalExcludeValues;
  end;

  TzPivotFields = class(TzCollection<TzPivotField>)
  private
    zDbPivotProps: TzDbPivotProps;
  public
    constructor Create(azDbPivotProps: TzDbPivotProps);
    procedure AssignFromPivotFields(cxDBPivotGrid: TcxDBPivotGrid);
    procedure AssignToPivotFields(cxDBPivotGrid: TcxDBPivotGrid);
    procedure FillTreeList(MasterNode: TcxTreeListNode); override;
    procedure Reset(DataSet: TzFbDataSet);
    procedure ValidateDataset(DataSet: TzFbDataSet);
  end;

  // ---------------------------------------------------------------------------
  // Vista di un record (componente TzDbRecordView, griglia verticale)
  // ---------------------------------------------------------------------------

  // Impaginazione: corrisponde a TcxvgLayoutStyle, senza legare zSystem a cxVGrid
  TzRecordViewLayout = (rlSingleRecord, rlMultiRecord, rlBands);

  // Una riga e' un campo, una categoria (intestazione che raccoglie le righe
  // figlie) oppure una riga con piu' campi affiancati (Members)
  TzRecordViewRowKind = (rkField, rkCategory, rkMultiField);

  TzDbRecordViewFlags = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FUpdateCount: integer;
    FButtonArrows: boolean;
    FButtonDelete: boolean;
    FButtonExpand: boolean;
    FButtonInsert: boolean;
    FButtonOkCancel: boolean;
    FButtonRefresh: boolean;
    FButtonUpdate: boolean;
    FEditInCard: boolean;
    FGridMode: boolean;
    FInplaceEditing: boolean;
    FHideEmptyRows: boolean;
    FHighlightDifferences: boolean;
    FLayout: TzRecordViewLayout;
    FMarkRequired: boolean;
    FParams: boolean;
    FReadOnly: boolean;
    FToolbar: boolean;
    procedure SetButtonArrows(const Value: boolean);
    procedure SetButtonDelete(const Value: boolean);
    procedure SetButtonExpand(const Value: boolean);
    procedure SetButtonInsert(const Value: boolean);
    procedure SetButtonOkCancel(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetButtonUpdate(const Value: boolean);
    procedure SetEditInCard(const Value: boolean);
    procedure SetGridMode(const Value: boolean);
    procedure SetInplaceEditing(const Value: boolean);
    procedure SetHideEmptyRows(const Value: boolean);
    procedure SetHighlightDifferences(const Value: boolean);
    procedure SetLayout(const Value: TzRecordViewLayout);
    procedure SetMarkRequired(const Value: boolean);
    procedure SetParams(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property ButtonArrows: boolean read FButtonArrows write SetButtonArrows default true;
    property ButtonDelete: boolean read FButtonDelete write SetButtonDelete default true;
    property ButtonExpand: boolean read FButtonExpand write SetButtonExpand default true;
    property ButtonInsert: boolean read FButtonInsert write SetButtonInsert default true;
    property ButtonOkCancel: boolean read FButtonOkCancel write SetButtonOkCancel default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    property ButtonUpdate: boolean read FButtonUpdate write SetButtonUpdate default true;
    // Inserimento e modifica nella scheda (TzDbCardDlg); il doppio clic apre
    // la scheda del record, salvo sulle celle modificabili
    property EditInCard: boolean read FEditInCard write SetEditInCard default False;
    // Modifica nelle celle, con gli editor del dominio (lookup compresi);
    // indipendente da EditInCard: possono valere tutte e due
    property InplaceEditing: boolean read FInplaceEditing write SetInplaceEditing default true;
    // Con GridMode il controllo legge solo i record visibili; senza, li carica
    // tutti in memoria (serve al confronto di piu' record affiancati)
    property GridMode: boolean read FGridMode write SetGridMode default true;
    // Nasconde le righe dei campi vuoti nel record corrente (rivalutato a ogni record)
    property HideEmptyRows: boolean read FHideEmptyRows write SetHideEmptyRows default False;
    // Con piu' record affiancati evidenzia i valori diversi dal primo record
    property HighlightDifferences: boolean read FHighlightDifferences write SetHighlightDifferences default true;
    property Layout: TzRecordViewLayout read FLayout write SetLayout default rlSingleRecord;
    // Segna in grassetto l'etichetta dei campi obbligatori
    property MarkRequired: boolean read FMarkRequired write SetMarkRequired default true;
    property Params: boolean read FParams write SetParams default False;
    property ReadOnly: boolean read FReadOnly write SetReadOnly default False;
    property Toolbar: boolean read FToolbar write SetToolbar default true;
  end;

  TzRecordViewRow = class(TzCollectionItem)
  private
    FCaption: string;
    FDomain: TzDomain;
    FExpanded: boolean;
    FFieldOrigin: string;
    FHeight: integer;
    FHint: string;
    FMembers: TStrings;
    FParentName: string;
    FReadOnly: boolean;
    FRowKind: TzRecordViewRowKind;
    FVisible: boolean;
    FzCtrlType: TzCtrlType;
    function GetCaption: string;
    function GetzCtrlType: TzCtrlType;
    function isCaptionStored: boolean;
    function IsCtrlTypeStored: boolean;
    procedure SetMembers(const Value: TStrings);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    // Riga legata a un solo campo del dataset: Name e' il nome del campo
    function IsField: boolean;
    // Puntatore al dominio risolto in esecuzione da ValidateDataset: non persistito
    property Domain: TzDomain read FDomain write FDomain;
  published
    property RowKind: TzRecordViewRowKind read FRowKind write FRowKind default rkField;
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    property Caption: string read GetCaption write FCaption stored isCaptionStored;
    property Hint: string read FHint write FHint;
    // Name della categoria che contiene la riga; vuoto = riga di primo livello
    property ParentName: string read FParentName write FParentName;
    property Visible: boolean read FVisible write FVisible default true;
    property ReadOnly: boolean read FReadOnly write FReadOnly default False;
    property Expanded: boolean read FExpanded write FExpanded default true;
    // -1 = altezza automatica
    property Height: integer read FHeight write FHeight default -1;
    // Solo per rkMultiField: nomi dei campi affiancati, uno per riga
    property Members: TStrings read FMembers write SetMembers;
    property zCtrlType: TzCtrlType read GetzCtrlType write FzCtrlType stored IsCtrlTypeStored default ctDefault;
  end;

  TzRecordViewRows = class(TzCollection<TzRecordViewRow>)
  private
    zDbRecordViewProps: TzDbRecordViewProps;
  public
    constructor Create(azDbRecordViewProps: TzDbRecordViewProps);
    // Riga del campo (rkField) con quel nome, nil se assente
    function FieldRow(const FieldName: string): TzRecordViewRow;
    function AddCategory(const CategoryName, CategoryCaption: string): TzRecordViewRow;
    // Porta una riga sotto una categoria (vuoto = primo livello)
    procedure MoveToCategory(const RowName, CategoryName: string);
    procedure Reset(DataSet: TzFbDataSet);
    // Allinea le righe ai campi del dataset: toglie quelle dei campi scomparsi,
    // aggiunge in coda i campi nuovi, aggiorna FieldOrigin e risolve Domain
    procedure ValidateDataset(DataSet: TzFbDataSet);
  end;

  TzDbRecordViewProps = class(TzBaseFilterableComponentProps)
  private
    FCaption: string;
    FDataSet: string;
    FFlags: TzDbRecordViewFlags;
    FHeaderWidth: integer;
    FRows: TzRecordViewRows;
    FTitle: string;
    FValueWidth: integer;
    function GetDataSet_Obj: TzDataSet;
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetFlags(const Value: TzDbRecordViewFlags);
    procedure SetRows(const Value: TzRecordViewRows);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property Caption: string read FCaption write FCaption;
    property DataSet: string read FDataSet write FDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property Flags: TzDbRecordViewFlags read FFlags write SetFlags;
    // Larghezza della colonna delle etichette; 0 = adattata alle etichette
    property HeaderWidth: integer read FHeaderWidth write FHeaderWidth default 0;
    property Rows: TzRecordViewRows read FRows write SetRows;
    property Title: string read FTitle write FTitle;
    // Larghezza di ogni record nell'impaginazione a piu' record; 0 = predefinita
    property ValueWidth: integer read FValueWidth write FValueWidth default 0;
  end;

  TzDbRecordViews = class(TzCollection<TzDbRecordViewProps>)
  end;

  // ---------------------------------------------------------------------------
  // Albero dati (componente TzDbTree, TcxDBTreeList)
  // ---------------------------------------------------------------------------

  // Espansione all'apertura: nessuna, solo le radici, fino a un livello, tutto,
  // oppure lo stato lasciato dall'utente l'ultima volta
  TzTreeExpandMode = (temNone, temRoots, temLevel, temAll, temRestore);

  TzDbTreeFlags = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FUpdateCount: integer;
    FButtonArrows: boolean;
    FButtonDelete: boolean;
    FButtonExpand: boolean;
    FButtonExpandCaption: boolean;
    FButtonInsert: boolean;
    FButtonOkCancel: boolean;
    FButtonRefresh: boolean;
    FButtonUpdate: boolean;
    FDragDrop: boolean;
    FEditInCard: boolean;
    FInplaceEditing: boolean;
    FExpandLevel: integer;
    FExpandMode: TzTreeExpandMode;
    FFooter: boolean;
    FIndicator: boolean;
    FMultiSelect: boolean;
    FParams: boolean;
    FReadOnly: boolean;
    FShowRoot: boolean;
    FSyncDataSet: boolean;
    FToolbar: boolean;
    procedure SetButtonArrows(const Value: boolean);
    procedure SetButtonDelete(const Value: boolean);
    procedure SetButtonExpand(const Value: boolean);
    procedure SetButtonExpandCaption(const Value: boolean);
    procedure SetButtonInsert(const Value: boolean);
    procedure SetButtonOkCancel(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetButtonUpdate(const Value: boolean);
    procedure SetDragDrop(const Value: boolean);
    procedure SetEditInCard(const Value: boolean);
    procedure SetInplaceEditing(const Value: boolean);
    procedure SetExpandLevel(const Value: integer);
    procedure SetExpandMode(const Value: TzTreeExpandMode);
    procedure SetFooter(const Value: boolean);
    procedure SetIndicator(const Value: boolean);
    procedure SetMultiSelect(const Value: boolean);
    procedure SetParams(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetShowRoot(const Value: boolean);
    procedure SetSyncDataSet(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property ButtonArrows: boolean read FButtonArrows write SetButtonArrows default true;
    property ButtonDelete: boolean read FButtonDelete write SetButtonDelete default true;
    property ButtonExpand: boolean read FButtonExpand write SetButtonExpand default true;
    // Scritta accanto all'icona dei pulsanti Espandi e Riduci nella barra
    property ButtonExpandCaption: boolean read FButtonExpandCaption write SetButtonExpandCaption default False;
    property ButtonInsert: boolean read FButtonInsert write SetButtonInsert default true;
    property ButtonOkCancel: boolean read FButtonOkCancel write SetButtonOkCancel default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    property ButtonUpdate: boolean read FButtonUpdate write SetButtonUpdate default true;
    // Trascinando un nodo si cambia il padre del record
    property DragDrop: boolean read FDragDrop write SetDragDrop default False;
    // Inserimento e modifica nella scheda (TzDbCardDlg); il doppio clic su un
    // nodo apre la scheda invece di aprire o chiudere il ramo, salvo sulle
    // celle modificabili
    property EditInCard: boolean read FEditInCard write SetEditInCard default False;
    // Modifica nelle celle, con gli editor del dominio (lookup compresi);
    // indipendente da EditInCard: possono valere tutte e due
    property InplaceEditing: boolean read FInplaceEditing write SetInplaceEditing default true;
    property ExpandLevel: integer read FExpandLevel write SetExpandLevel default 1;
    property ExpandMode: TzTreeExpandMode read FExpandMode write SetExpandMode default temRoots;
    property Footer: boolean read FFooter write SetFooter default False;
    property Indicator: boolean read FIndicator write SetIndicator default False;
    property MultiSelect: boolean read FMultiSelect write SetMultiSelect default False;
    property Params: boolean read FParams write SetParams default False;
    property ReadOnly: boolean read FReadOnly write SetReadOnly default False;
    property ShowRoot: boolean read FShowRoot write SetShowRoot default true;
    // Il record corrente del dataset segue il nodo con il fuoco (Locate in
    // memoria, mai il Locate via SQL di TzFbDataSet): serve ai dettagli e alle schede
    property SyncDataSet: boolean read FSyncDataSet write SetSyncDataSet default true;
    property Toolbar: boolean read FToolbar write SetToolbar default true;
  end;

  TzTreeColumn = class(TzCollectionItem)
  private
    FCaption: string;
    FDomain: TzDomain;
    FFieldOrigin: string;
    FReadOnly: boolean;
    FVisible: boolean;
    FWidth: integer;
    FzCtrlType: TzCtrlType;
    function GetCaption: string;
    function GetzCtrlType: TzCtrlType;
    function isCaptionStored: boolean;
    function IsCtrlTypeStored: boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    // Puntatore al dominio risolto in esecuzione da ValidateDataset: non persistito
    property Domain: TzDomain read FDomain write FDomain;
  published
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    property Caption: string read GetCaption write FCaption stored isCaptionStored;
    property Visible: boolean read FVisible write FVisible default true;
    property ReadOnly: boolean read FReadOnly write FReadOnly default False;
    // -1 = larghezza predefinita
    property Width: integer read FWidth write FWidth default -1;
    property zCtrlType: TzCtrlType read GetzCtrlType write FzCtrlType stored IsCtrlTypeStored default ctDefault;
  end;

  TzTreeColumns = class(TzCollection<TzTreeColumn>)
  private
    zDbTreeProps: TzDbTreeProps;
  public
    constructor Create(azDbTreeProps: TzDbTreeProps);
    procedure Reset(DataSet: TzFbDataSet);
    // Allinea le colonne ai campi del dataset: toglie quelle dei campi scomparsi,
    // aggiunge in coda i campi nuovi, aggiorna FieldOrigin e risolve Domain
    procedure ValidateDataset(DataSet: TzFbDataSet);
  end;

  TzDbTreeProps = class(TzBaseFilterableComponentProps)
  private
    FCaption: string;
    FColumns: TzTreeColumns;
    FDataSet: string;
    FFlags: TzDbTreeFlags;
    FImageIndexFieldName: string;
    FKeyFieldName: string;
    FParentFieldName: string;
    FPreviewFieldName: string;
    FTitle: string;
    function GetDataSet_Obj: TzDataSet;
    procedure SetColumns(const Value: TzTreeColumns);
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetFlags(const Value: TzDbTreeFlags);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property Caption: string read FCaption write FCaption;
    property Columns: TzTreeColumns read FColumns write SetColumns;
    property DataSet: string read FDataSet write FDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property Flags: TzDbTreeFlags read FFlags write SetFlags;
    // Campo intero con l'indice dell'icona del nodo (facoltativo)
    property ImageIndexFieldName: string read FImageIndexFieldName write FImageIndexFieldName;
    // Vuoti = la chiave primaria del dataset e il campo che finisce in _PADRE
    property KeyFieldName: string read FKeyFieldName write FKeyFieldName;
    property ParentFieldName: string read FParentFieldName write FParentFieldName;
    // Campo mostrato sotto il nodo come anteprima (facoltativo)
    property PreviewFieldName: string read FPreviewFieldName write FPreviewFieldName;
    property Title: string read FTitle write FTitle;
  end;

  TzDbTrees = class(TzCollection<TzDbTreeProps>)
  end;

  // ---------------------------------------------------------------------------
  // Grafico dati (componente TzDbChart, TdxChartControl)
  // I tipi TzChartKind e TzChartSort stanno in zDbChart.Types, senza DevExpress
  // ---------------------------------------------------------------------------

  TzDbChartFlags = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FUpdateCount: integer;
    FAllowZoom: boolean;
    FButtonExport: boolean;
    FButtonKind: boolean;
    FButtonLabels: boolean;
    FButtonLegend: boolean;
    FButtonPrint: boolean;
    FButtonRefresh: boolean;
    FButtonZoom: boolean;
    FCrosshair: boolean;
    FParams: boolean;
    FShowLabels: boolean;
    FShowLegend: boolean;
    FSyncDataSet: boolean;
    FToolbar: boolean;
    procedure SetAllowZoom(const Value: boolean);
    procedure SetButtonExport(const Value: boolean);
    procedure SetButtonKind(const Value: boolean);
    procedure SetButtonLabels(const Value: boolean);
    procedure SetButtonLegend(const Value: boolean);
    procedure SetButtonPrint(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetButtonZoom(const Value: boolean);
    procedure SetCrosshair(const Value: boolean);
    procedure SetParams(const Value: boolean);
    procedure SetShowLabels(const Value: boolean);
    procedure SetShowLegend(const Value: boolean);
    procedure SetSyncDataSet(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    // zoom e scorrimento con la rotellina e il trascinamento (solo diagramma XY)
    property AllowZoom: boolean read FAllowZoom write SetAllowZoom default true;
    property ButtonExport: boolean read FButtonExport write SetButtonExport default true;
    // sottomenu del tipo di grafico: la scelta dell'utente si ricorda per utente
    property ButtonKind: boolean read FButtonKind write SetButtonKind default true;
    property ButtonLabels: boolean read FButtonLabels write SetButtonLabels default true;
    property ButtonLegend: boolean read FButtonLegend write SetButtonLegend default true;
    property ButtonPrint: boolean read FButtonPrint write SetButtonPrint default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    property ButtonZoom: boolean read FButtonZoom write SetButtonZoom default true;
    // mirino sul diagramma XY; spento = suggerimento semplice sul punto
    property Crosshair: boolean read FCrosshair write SetCrosshair default true;
    property Params: boolean read FParams write SetParams default False;
    // valori iniziali; l'utente li cambia dalla barra
    property ShowLabels: boolean read FShowLabels write SetShowLabels default False;
    property ShowLegend: boolean read FShowLegend write SetShowLegend default true;
    // il doppio clic su un punto porta il dataset sul record del punto
    property SyncDataSet: boolean read FSyncDataSet write SetSyncDataSet default true;
    property Toolbar: boolean read FToolbar write SetToolbar default true;
  end;

  // Una serie: un campo valore del dataset (Name = nome del campo)
  TzChartSeriesItem = class(TzCollectionItem)
  private
    FCaption: string;
    FDomain: TzDomain;
    FFieldOrigin: string;
    FKind: TzChartKind;
    FVisible: boolean;
    function GetCaption: string;
    function isCaptionStored: boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    // Puntatore al dominio risolto in esecuzione da ValidateDataset: non persistito
    property Domain: TzDomain read FDomain write FDomain;
  published
    property Caption: string read GetCaption write FCaption stored isCaptionStored;
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    // gkChart = il tipo del grafico (TzDbChartProps.Kind)
    property Kind: TzChartKind read FKind write FKind default gkChart;
    property Visible: boolean read FVisible write FVisible default true;
  end;

  TzChartSeriesItems = class(TzCollection<TzChartSeriesItem>)
  private
    zDbChartProps: TzDbChartProps;
  public
    constructor Create(azDbChartProps: TzDbChartProps);
    procedure Reset(DataSet: TzFbDataSet);
    // Allinea le serie ai campi numerici del dataset: toglie quelle dei campi
    // scomparsi, aggiunge in coda i campi nuovi (nascosti, salvo il primo
    // quando la lista e' vuota), aggiorna FieldOrigin e risolve Domain
    procedure ValidateDataset(DataSet: TzFbDataSet);
    // Campo che puo' fare da serie: numerico
    class function IsValueField(Field: TField): boolean; static;
    // Colonne di controllo scritte dai trigger: mai serie ne' argomento
    class function IsServiceField(const FieldName: string): boolean; static;
  end;

  TzDbChartProps = class(TzBaseFilterableComponentProps)
  private
    FArgumentField: string;
    FAxisTitleX: string;
    FAxisTitleY: string;
    FCaption: string;
    FDataSet: string;
    FFlags: TzDbChartFlags;
    FKind: TzChartKind;
    FMaxPoints: integer;
    FReportName: string;
    FSeries: TzChartSeriesItems;
    FSort: TzChartSort;
    FTitle: string;
    FTopN: integer;
    FTopNOthers: boolean;
    function GetDataSet_Obj: TzDataSet;
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetFlags(const Value: TzDbChartFlags);
    procedure SetSeries(const Value: TzChartSeriesItems);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    // Campo dell'asse delle categorie; vuoto = il primo campo di testo o data
    property ArgumentField: string read FArgumentField write FArgumentField;
    property AxisTitleX: string read FAxisTitleX write FAxisTitleX;
    property AxisTitleY: string read FAxisTitleY write FAxisTitleY;
    property Caption: string read FCaption write FCaption;
    property DataSet: string read FDataSet write FDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property Flags: TzDbChartFlags read FFlags write SetFlags;
    // Tipo del grafico e delle serie con Kind = gkChart
    property Kind: TzChartKind read FKind write FKind default gkBar;
    // Soglia di punti oltre la quale il grafico non si disegna; 0 = per tipo
    // (5.000 barre, aree, torta; 100.000 linee: misure della fase 0)
    property MaxPoints: integer read FMaxPoints write FMaxPoints default 0;
    // Nome con cui i modelli di stampa lo richiamano (chart://Nome); vuoto =
    // l'identificativo Modulo.DataSet
    property ReportName: string read FReportName write FReportName;
    property Series: TzChartSeriesItems read FSeries write SetSeries;
    property Sort: TzChartSort read FSort write FSort default gsNone;
    property Title: string read FTitle write FTitle;
    // Prime N categorie, solo torta e ciambella; 0 = tutte
    property TopN: integer read FTopN write FTopN default 0;
    property TopNOthers: boolean read FTopNOthers write FTopNOthers default true;
  end;

  TzDbCharts = class(TzCollection<TzDbChartProps>)
  end;

  // ---------------------------------------------------------------------------
  // Calendario (componente TzDbScheduler, TcxScheduler in modo nativo)
  // ---------------------------------------------------------------------------

  // Vista con cui il calendario si apre
  TzSchedulerViewMode = (svmDay, svmWorkWeek, svmMonth);

  // Campi dello storage di DevExpress (TcxSchedulerDBStorageFieldNames), nello
  // stesso ordine delle proprieta' di TzSchedulerMapping
  TzSchedulerField = (sfID, sfStart, sfFinish, sfCaption, sfMessage, sfLocation, sfLabelColor, sfEventType, sfOptions, sfParentID, sfRecurrenceIndex,
    sfRecurrenceInfo, sfResourceID, sfState, sfActualStart, sfActualFinish, sfReminderDate, sfReminderMinutesBeforeStart, sfReminderResourcesData,
    sfTaskComplete, sfTaskIndex, sfTaskLinks, sfTaskStatus);

  TzDbSchedulerFlags = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FUpdateCount: integer;
    FAutoCustomFields: boolean;
    FButtonRefresh: boolean;
    FDateNavigator: boolean;
    FParams: boolean;
    FReadOnly: boolean;
    FRecurrence: boolean;
    FToolbar: boolean;
    FWorkTimeOnly: boolean;
    procedure SetAutoCustomFields(const Value: boolean);
    procedure SetButtonRefresh(const Value: boolean);
    procedure SetDateNavigator(const Value: boolean);
    procedure SetParams(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetRecurrence(const Value: boolean);
    procedure SetToolbar(const Value: boolean);
    procedure SetWorkTimeOnly(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Changed;
    procedure EndUpdate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    // i campi del dataset non mappati diventano campi personalizzati
    // dell'evento: li leggono i suggerimenti, le icone e le form di dominio
    property AutoCustomFields: boolean read FAutoCustomFields write SetAutoCustomFields default true;
    property ButtonRefresh: boolean read FButtonRefresh write SetButtonRefresh default true;
    // calendarietto laterale
    property DateNavigator: boolean read FDateNavigator write SetDateNavigator default False;
    property Params: boolean read FParams write SetParams default False;
    // nessuna scrittura: nuovo, modifica, trascinamento ed eliminazione spenti
    property ReadOnly: boolean read FReadOnly write SetReadOnly default False;
    // eventi ricorrenti nell'editor; servono RecurrenceIndex e RecurrenceInfo
    property Recurrence: boolean read FRecurrence write SetRecurrence default true;
    property Toolbar: boolean read FToolbar write SetToolbar default true;
    // vista giorno ridotta all'orario di lavoro (WorkStart, WorkFinish)
    property WorkTimeOnly: boolean read FWorkTimeOnly write SetWorkTimeOnly default False;
  end;

  // Nomi dei campi del dataset per lo storage di DevExpress. Vuoto = la
  // convenzione (INIZIO, FINE, OGGETTO, TIPO_EVENTO, OPZIONI... come la tabella
  // USR_UTENTI_AGENDA e le procedure dei calendari), se il campo c'e'.
  // Obbligatori per DevExpress: ID, Start, Finish, EventType, Options; senza
  // uno di loro lo storage non carica nessun evento e non lo dice.
  TzSchedulerMapping = class(TPersistent)
  private
    FNames: array [TzSchedulerField] of string;
    function GetName(Index: integer): string;
    procedure SetName(Index: integer; const Value: string);
  public
    procedure Assign(Source: TPersistent); override;
    // Nome configurato
    function Configured(const Field: TzSchedulerField): string;
    procedure SetConfigured(const Field: TzSchedulerField; const Value: string);
    // Campo effettivo nel dataset: quello configurato se c'e', altrimenti
    // (solo se non configurato) il primo della convenzione presente; '' se nessuno
    function Resolve(const Field: TzSchedulerField; DataSet: TDataSet): string;
    // Campi obbligatori che non si risolvono nel dataset, separati da virgola
    function MissingRequired(DataSet: TDataSet): string;
    class function IsRequired(const Field: TzSchedulerField): boolean; static;
    class function FieldCaption(const Field: TzSchedulerField): string; static;
  published
    property ID: string index Ord(sfID) read GetName write SetName;
    property Start: string index Ord(sfStart) read GetName write SetName;
    property Finish: string index Ord(sfFinish) read GetName write SetName;
    property Caption: string index Ord(sfCaption) read GetName write SetName;
    property Message: string index Ord(sfMessage) read GetName write SetName;
    property Location: string index Ord(sfLocation) read GetName write SetName;
    property LabelColor: string index Ord(sfLabelColor) read GetName write SetName;
    property EventType: string index Ord(sfEventType) read GetName write SetName;
    property Options: string index Ord(sfOptions) read GetName write SetName;
    property ParentID: string index Ord(sfParentID) read GetName write SetName;
    property RecurrenceIndex: string index Ord(sfRecurrenceIndex) read GetName write SetName;
    property RecurrenceInfo: string index Ord(sfRecurrenceInfo) read GetName write SetName;
    property ResourceID: string index Ord(sfResourceID) read GetName write SetName;
    property State: string index Ord(sfState) read GetName write SetName;
    property ActualStart: string index Ord(sfActualStart) read GetName write SetName;
    property ActualFinish: string index Ord(sfActualFinish) read GetName write SetName;
    property ReminderDate: string index Ord(sfReminderDate) read GetName write SetName;
    property ReminderMinutesBeforeStart: string index Ord(sfReminderMinutesBeforeStart) read GetName write SetName;
    property ReminderResourcesData: string index Ord(sfReminderResourcesData) read GetName write SetName;
    property TaskComplete: string index Ord(sfTaskComplete) read GetName write SetName;
    property TaskIndex: string index Ord(sfTaskIndex) read GetName write SetName;
    property TaskLinks: string index Ord(sfTaskLinks) read GetName write SetName;
    property TaskStatus: string index Ord(sfTaskStatus) read GetName write SetName;
  end;

  TzDbSchedulerProps = class(TzBaseFilterableComponentProps)
  private
    FCaption: string;
    FDataSet: string;
    FFlags: TzDbSchedulerFlags;
    FMapping: TzSchedulerMapping;
    FPeriodFromParam: string;
    FPeriodToParam: string;
    FResourceColorField: string;
    FResourceDataSet: string;
    FResourceIdField: string;
    FResourceNameField: string;
    FTitle: string;
    FViewMode: TzSchedulerViewMode;
    FWorkFinish: integer;
    FWorkStart: integer;
    function GetDataSet_Obj: TzDataSet;
    procedure SetDataSet_Obj(const Value: TzDataSet);
    procedure SetFlags(const Value: TzDbSchedulerFlags);
    procedure SetMapping(const Value: TzSchedulerMapping);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function zComponentType: TzComponentType; override;

    // Parametri del periodo effettivi: quelli configurati o DAL_GIORNO/AL_GIORNO
    function PeriodFromParamName: string;
    function PeriodToParamName: string;

    procedure LoadFromBase;
    procedure SaveToBase(SaveToLZ: boolean = False); override;
  published
    property Caption: string read FCaption write FCaption;
    property DataSet: string read FDataSet write FDataSet;
    property DataSet_Obj: TzDataSet read GetDataSet_Obj write SetDataSet_Obj stored False;
    property Flags: TzDbSchedulerFlags read FFlags write SetFlags;
    property Mapping: TzSchedulerMapping read FMapping write SetMapping;
    // Parametri del dataset con il periodo visibile; vuoti = DAL_GIORNO e
    // AL_GIORNO. Se il dataset non li ha il calendario legge tutti i record
    property PeriodFromParam: string read FPeriodFromParam write FPeriodFromParam;
    property PeriodToParam: string read FPeriodToParam write FPeriodToParam;
    // Risorse: un altro dataset dello stesso modulo dati (solo il nome, es.
    // Utenti), con chiave, descrizione e colore; il legame con l'evento e'
    // Mapping.ResourceID
    property ResourceDataSet: string read FResourceDataSet write FResourceDataSet;
    property ResourceIdField: string read FResourceIdField write FResourceIdField;
    property ResourceNameField: string read FResourceNameField write FResourceNameField;
    property ResourceColorField: string read FResourceColorField write FResourceColorField;
    property Title: string read FTitle write FTitle;
    property ViewMode: TzSchedulerViewMode read FViewMode write FViewMode default svmWorkWeek;
    // Orario di lavoro in minuti dalla mezzanotte (480 = 8:00)
    property WorkStart: integer read FWorkStart write FWorkStart default 480;
    property WorkFinish: integer read FWorkFinish write FWorkFinish default 1200;
  end;

  TzDbSchedulers = class(TzCollection<TzDbSchedulerProps>)
  end;

  TzToolFilterProps = class(TzCollectionItem)
  private
    FInitialValue: TFilterInitialValue;
    FParams: TStrings;
    FFromCode: boolean;
    FCustomValue: string;
    FPosition: integer;
    FVisible: boolean;
    FCaption: string;
    FHint: string;
    FWidth: integer;
    FFieldName: string;
    FPickListName: string;
    FAllowNull: boolean;
    FCaptionAll: string;
    FFilterName: string;
    procedure SetParams(const Value: TStrings);
    function GetPickList: TzPickList;
    procedure SetPickList(const Value: TzPickList);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    // Descrizione testuale del filtro, composta da Name e InitialValue.
    // Non richiede la classe concreta TzFilterDef -  solo stringa.
    // Usata per logging e per il contesto chat.
    function Description: string;
    // Classe di filtro da risolvere nel registro. Ricade su Name per le
    // configurazioni LZ scritte prima dell'introduzione di FilterName.
    function EffectiveFilterName: string;
    // Letture effettive con fallback sui parametri legacy in Params
    function EffectiveFieldName: string;
    function EffectiveCaption: string;
    function EffectiveHint: string;
    function EffectiveWidth(const default: integer): integer;
    function EffectivePickListName: string;
    function EffectiveAllowNull: boolean;
    function EffectiveCaptionAll: string;
    function EffectiveInitialValue: TFilterInitialValue;
    // True per i filtri introdotti da codice (es. dmTools.AddFiltro*) e non
    // ancora presenti su LZ. NON published: non viene serializzata n copiata
    // da Assign, quindi non "ritorna" mai vera da un caricamento.
    property FromCode: boolean read FFromCode write FFromCode;
  published
    // Classe registrata da istanziare. Vuota = si usa Name (retrocompatibilita').
    property FilterName: string read FFilterName write FFilterName;
    property InitialValue: TFilterInitialValue read FInitialValue write FInitialValue default ivDefault;
    property CustomValue: string read FCustomValue write FCustomValue;
    property Position: integer read FPosition write FPosition default -1;
    property Visible: boolean read FVisible write FVisible default true;
    property Caption: string read FCaption write FCaption;
    property Hint: string read FHint write FHint;
    property Width: integer read FWidth write FWidth default 0;
    property FieldName: string read FFieldName write FFieldName;
    property PickList: TzPickList read GetPickList write SetPickList stored False;
    property PickListName: string read FPickListName write FPickListName;
    property AllowNull: boolean read FAllowNull write FAllowNull default true;
    property CaptionAll: string read FCaptionAll write FCaptionAll;
    property Params: TStrings read FParams write SetParams;
  end;

  TzToolFiltersProps = class(TzCollection<TzToolFilterProps>)
  public
    procedure Assign(Source: TPersistent); override;
    function Exists(const Name: string): boolean;
    function Find(const Name: string): TzToolFilterProps;
    function HasFromCode: boolean;
    procedure ClearFromCode;
    // Aggiunge da Source i SOLI nomi assenti, marcandoli FromCode.
    // LZ (lo stato corrente) vince sempre sui nomi che già esistono.
    // Ritorna True se ha introdotto almeno un nuovo item.
    function MergeFromCode(Source: TzToolFiltersProps): boolean;
    // Restituisce le descrizioni di tutti i filtri come array di stringhe.
    // Usato per la serializzazione del contesto chat.
    function Descriptions: TArray<string>;

    // ── Istanze multiple della stessa classe di filtro ────────────────────
    // Tutti gli elementi che risolvono sulla classe AFilterName, nell'ordine
    // in cui compaiono nella collezione.
    function InstancesOf(const AFilterName: string): TArray<TzToolFilterProps>;
    // Nome di istanza libero e univoco dentro questa collezione.
    function NewInstanceName(const AFilterName, AFieldName: string): string;
    // Crea una nuova istanza della classe AFilterName con Name univoco.
    function AddInstance(const AFilterName: string): TzToolFilterProps;
  end;

function AdminPasswordOk(const Password: string): boolean;

function ComputerName: string;

function CapFirst(Value: string): string;

function GetCtrlType(DataType: TFieldType; Domain: string): TzCtrlType;

// Mantis #5307 - 2026-11-03: vero per i segnaposto <procedure>, <view>, <table>
// e <???> che InitFields scrive in Domain quando non trova il dominio del campo.
function IsDomainPlaceholder(Domain: string): Boolean;

function MemberShipName(UserName, GroupName: string): string;

function SqlFunc2Str(Value: TSqlFunc): string;

function SqlFuncsForDataType(DataType: TFieldType): TSqlFuncs;

function Str2SqlFunc(Value: string): TSqlFunc;

function TerminalServer: boolean;

// function _zSystem: TzSystem;
function CreateStoredProc(const StoredProcName: string): TFDStoredProc;

function IsGeneratedByController(dxLayoutItem: TdxCustomLayoutItem): boolean;

const
  DefaultCharCase: TEditCharCase = ecUpperCase;

var
  Base: TzSystem;
  AdminPwd: integer = 10299;

implementation

uses
  System.Diagnostics,
  zDiagnostica.Log.Perf,
  System.IniFiles,
  System.IOUtils,
  System.StrUtils,
  data.DBCommon,
  Vcl.ExtCtrls,
  zSqlLib,
  zSecurityLoginFrm,
  zSecurityPasswordFrm,
  zFrmCollection,
  zSystemPropertyEditors,
  Frame_ObjectInspector,
  zSystem_Init,
  zz.strings,
  zSystemFrm,
  zSql.SqlTxtRtns,
  zSecurityFrm,
  zMsg,
  zExceptions.fib,
  zTotp,
  zTotp.Dialogs,
  cxLookupEdit,
  cxImage,
  cxGraphics,
  cxButtonEdit,
  zdx,
  cxTimeEdit,
  cxLookupDBGrid,
  zDbViewDlg,
  cxRichEdit,
  cxMemo,
  zz.Base.editor._form,
  zz.ActiveDirectory,
  zMetaData.Loader,
  zOffice,
  System.Rtti,
  System.JSON,
  Vcl.Clipbrd,
  zOverrides,
  FireDAC.Stan.Intf;

var
  sizSystem: TSiSession;

const
  // stored proc usate
  spUSR_LOGIN = 'USR_LOGIN';
  spUSR_CAMBIA_PASSWORD = 'USR_CAMBIA_PASSWORD';
  spUSR_GENERA_TOKEN_OTP = 'USR_GENERA_TOKEN_OTP';
  spUSR_VERIFICA_TOKEN_OTP = 'USR_VERIFICA_TOKEN_OTP';
  spUSR_TOTP_REGISTRA = 'USR_TOTP_REGISTRA';
  spUSR_TOTP_ATTIVA = 'USR_TOTP_ATTIVA';
  spUSR_TOTP_CODICI_RECUPERO_IMPOSTA = 'USR_TOTP_CODICI_RECUPERO_IMPOSTA';
  spUSR_TOTP_VERIFICA = 'USR_TOTP_VERIFICA';
  spUSR_TOTP_AZZERA = 'USR_TOTP_AZZERA';

  spUSR_FOLDERS_GET_VALUE = 'USR_FOLDERS_GET_VALUE';
  spUSR_FOLDERS_SET_VALUE = 'USR_FOLDERS_SET_VALUE';

  spUSR_CONFIG_SETTINGS_EXISTS = 'USR_CONFIG_SETTINGS_EXISTS';
  spUSR_CONFIG_SETTINGS_GET_VALUE = 'USR_CONFIG_SETTINGS_GET_VALUE';
  spUSR_CONFIG_SETTINGS_SET_VALUE = 'USR_CONFIG_SETTINGS_SET_VALUE';

  spUSR_UTENTI_SETTINGS_EXISTS = 'USR_UTENTI_SETTINGS_EXISTS';
  spUSR_UTENTI_SETTINGS_GET_VALUE = 'USR_UTENTI_SETTINGS_GET_VALUE';
  spUSR_UTENTI_SETTINGS_SET_VALUE = 'USR_UTENTI_SETTINGS_SET_VALUE';

  zExtension_Security = '.Sec';

  // Password con cui vengono cifrati i membri del file .Sec (cifratura zip
  // classica di Abbrevia). Unica per tutte le installazioni: serve a non
  // lasciare le credenziali leggibili con un editor di testo, non a
  // difenderle da chi ha i sorgenti. In lettura viene usata solo sui membri
  // cifrati, quindi i file scritti prima si aprono ancora.
  zSecurityZipPassword = 'zPack.Sec!2026.Onnipotente';

  // Valore del parametro FireDAC "Protocol" per ogni TzProtocol, con i nomi
  // previsti dal driver Firebird (Local, NetBEUI, SPX, TCPIP).
  zProtocolFireDAC: array [TzProtocol] of string = ('Local', 'NetBEUI', 'TCPIP', 'SPX');
  SLASTUSER = 'LAST_USER';
  SLASTCONNECTION = 'LAST_CONNECTION';
  //
  imgDataDictionary = 0;
  imgLookups = 1;
  imgDomains = 2;
  imgSqlCommands = 3;
  imgDataSetViews = 4;
  imgGenerators = 6;
  imgDataSets = 7;
  imgDbViews = 8;
  imgCards = 9;
  imgDataModules = 10;
  imgPickLists = 12;
  imgForms = 13;
  imgStoredProcs = 14;
  imgWizards = 15;
  imgCubes = 16;
  imgPivots = 16;
  imgMaps = 17;
  imgInspectors = 18;
  imgPdf = 20;
  imgTips = 21;
  imgRecordViews = imgInspectors;
  imgTrees = imgDataModules;
  imgCharts = imgPivots;
  imgSchedulers = imgForms;

  idxGridView = 0;
  idxRecView = 1;
  img_SecurityPolicies = 16;
  img_SecurityConnections = 0; // prima icona di CollectionImageList in zSecurityFrm
  img_SecurityModules = -1;
  img_SecurityUsers = -1;
  img_SecuritySetting = -1;
  img_SecurityGroups = -1;
  img_SecurityMemberships = -1;
  img_SecurityRoles = -1;
  img_SecurityUserRoles = -1;
  img_SecurityGroupRoles = -1;

  strShrinkToFit = 'Shrink To Fit';
  Tab = #9;
  Sep = ';';

type
  TcxCustomEditAccess = class(TcxCustomEdit);

function IsGeneratedByController(dxLayoutItem: TdxCustomLayoutItem): boolean;
begin
  Assert(assigned(dxLayoutItem));

  result := (dxLayoutItem is TzDxLayoutItem) or (dxLayoutItem is TzDxLayoutGroup) or (dxLayoutItem is TzDxLayoutSplitterItem) or (dxLayoutItem is TzDxLayoutEmptySpaceItem) or (dxLayoutItem is TzDxLayoutSeparatorItem);
end;

function CreateStoredProc(const StoredProcName: string): TFDStoredProc;
begin
  result := TFDStoredProc.Create(nil);
  result.Connection := Base.zFbDatabase;
  result.Transaction := Base.zFbTransaction;
  // result.Options := [qoAutoCommit, qoStartTransaction];
  result.StoredProcName := StoredProcName;
end;

function ItemName(Item: TzCollectionItem): string;
begin
  if assigned(Item) then
    result := Item.Name
  else
    result := '';
end;

function CapFirst(Value: string): string;
var
  i: integer;
  s: string;
begin
  result := '';
  if trim(Value) = '' then
    Exit;
  s := uppercase(Value[1]);
  for i := 2 to length(Value) do
  begin
    if (ord(Value[i - 1]) < 33) then
      s := s + uppercase(Value[i])
    else
      s := s + lowercase(Value[i]);
  end;
  result := s;
end;

function ComputerName: string;
var
  cresult: string;
  pw: Pchar;
  pwSize: cardinal;
begin
  GetMem(pw, 300);
  pwSize := 300;
  try
    if GetComputerName(Pchar(pw), pwSize) then
    begin
      cresult := StrPas(pw);
    end;
  finally
    FreeMem(pw, 300);
  end;
  result := uppercase(cresult);
end;

function ComputerUserName(): String;
var
  UserName: String;
  Size: DWORD;
begin
  Size := 255;
  SetLength(UserName, Size);
  if GetUserName(Pchar(UserName), Size) then
    result := Copy(UserName, 1, Size - 1)
  else
    result := '';
end;

function CompareDomainNodesByText(AItem1, AItem2: TcxTreeListNode): integer;
begin
  // CustomSort: valore > 0 significa "AItem1 viene prima di AItem2" — quindi
  // l'ordine dei parametri va invertito rispetto a una AnsiCompareText normale.
  result := AnsiCompareText(AItem1.Values[0], AItem2.Values[0]);
end;

procedure GetCtrlParams(const ControlType, ControlName: string; var Param1, Param2: string);
begin
  Param1 := '';
  Param2 := '';
  if uppercase(trim(ControlType)) = uppercase(strCheckBox) then
  begin
    Param1 := 'S';
    Param2 := 'N';
  end;

  if uppercase(trim(ControlType)) = uppercase(strCustomEdit) then
  begin
    Param1 := ControlName;
    Param2 := 'N';
  end;

  if uppercase(trim(ControlType)) = uppercase(strImageIndex) then
  begin
    Param1 := strShrinkToFit;
    Param2 := '';
  end;
end;

function GetCtrlType(DataType: TFieldType; Domain: string): TzCtrlType;
begin
  result := ctDefault;

  case DataType of
    ftUnknown:
      Exit;
    ftString, ftFixedChar, ftWideString:
      result := ctEdit;
    ftSmallint, ftInteger, TFieldType.ftWord, ftAutoInc, ftLargeint:
      result := ctEdit;
    ftBoolean:
      result := ctCheckBox;
    ftFloat, ftCurrency, ftBCD:
      result := ctEdit;
    ftDate:
      result := ctDate;
    ftTime:
      result := ctTime;
    ftDateTime, ftTimeStamp:
      result := ctDateTime;
    ftMemo, ftFmtMemo:
      result := ctMemo;
    ftGraphic:
      result := ctImage;
    // ftBytes, ftVarBytes, ftBlob,  ftParadoxOle, ftDBaseOle, ftTypedBinary,
    // ftCursor, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob,
    // ftVariant, ftInterface, ftIDispatch, ftGuid, ftFMTBcd);
  end;
  if (SameText(Domain, 'SI_NO')) or (SameText(Domain, 'SI_NO')) then
  begin
    result := ctCheckBox;
  end
  else
    if (SameText(Domain, 'BOOLEAN')) or (SameText(Domain, 'BOOLEAN')) then
    begin
      result := ctCheckBox;
    end
    else
      if SameText(Domain, 'DATA') then
      begin
        result := ctDate;
      end
      else
        if SameText(Domain, 'DATA_ORA') then
        begin
          result := ctDateTime;
        end
        else
          if SameText(Domain, 'ORA') then
          begin
            result := ctTime;
          end
          else
            if SameText(Domain, 'NOTE') then
            begin
              result := ctMemo;
            end
            else
              if SameText(Domain, 'MEMO') then
              begin
                result := ctMemo;
              end
              else
                if SameText(Domain, 'IMMAGINE') then
                begin
                  result := ctImage;
                end;
end;

function IsDomainPlaceholder(Domain: string): Boolean;
begin
  Result := (Length(Domain) > 1) and (Domain[1] = '<') and (Domain[Length(Domain)] = '>');
end;

function MemberShipName(UserName, GroupName: string): string;
begin
  result := GroupName + '.' + UserName;
end;

function MySelf: string;
begin
  // da togliere dopo il debug...
  result := '';
end;

function Path: string;
begin
  result := extractfilePath(application.exename);
  if result[length(result)] <> '\' then
    result := result + '\';
end;

function SqlFunc2Str(Value: TSqlFunc): string;
begin
  result := '';
  case Value of
    sfNone:
      result := '';
    sfSUM:
      result := 'SUM';
    sfAVG:
      result := 'AVG';
    sfCOUNT:
      result := 'COUNT';
    sfMIN:
      result := 'MIN';
    sfMAX:
      result := 'MAX';
  end;
end;

function SqlFuncsForDataType(DataType: TFieldType): TSqlFuncs;
begin
  result := [sfNone];
  case DataType of
    ftUnknown:
      result := [sfNone];

    ftString, ftFixedChar, ftWideString:
      result := [sfNone, sfCOUNT, sfMIN, sfMAX];

    ftSmallint, ftInteger, TFieldType.ftWord, ftFloat, ftCurrency, ftBCD, ftAutoInc, ftLargeint, ftFMTBcd:
      result := [sfNone, sfSUM, sfAVG, sfCOUNT, sfMIN, sfMAX];

    ftBoolean:
      result := [sfNone, sfCOUNT, sfMIN, sfMAX];

    ftDate, ftTime, ftDateTime, ftTimeStamp:
      result := [sfNone, sfCOUNT, sfMIN, sfMAX];

    ftBytes, ftVarBytes, ftblob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface, ftIDispatch, ftGuid:
      result := [sfNone, sfCOUNT];
  end;
end;

function Str2SqlFunc(Value: string): TSqlFunc;
begin
  result := sfNone;
  if SameText(Value, 'SUM') then
    result := sfSUM
  else
    if SameText(Value, 'AVG') then
      result := sfAVG
    else
      if SameText(Value, 'COUNT') then
        result := sfCOUNT
      else
        if SameText(Value, 'MIN') then
          result := sfMIN
        else
          if SameText(Value, 'MAX') then
            result := sfMAX;
end;

function TerminalServer: boolean;
const
  sm_RemoteSession = $1000; { from WinUser.h }
  sm_RemoteControl = $2001; { from WinUser.h }
begin
  result := (GetSystemMetrics(sm_RemoteSession) <> 0) or (GetSystemMetrics(sm_RemoteControl) <> 0);
end;

function WindowClassName(Wnd: HWnd): string;
var
  Buffer: array [0 .. 255] of Char;
begin
  SetString(result, Buffer, GetClassName(Wnd, Buffer, SizeOf(Buffer) - 1));
end;

function zBoolToStr(Value: boolean): string;
begin
  if Value then
    result := 'T'
  else
    result := 'F';
end;

function GetRestrictionType(Value: String): TRestrictionType;
begin
  result := rtNone;

  case StrToChar(Value) of
    'N':
      result := rtNone;
    'E':
      result := rtDisable;
    'V':
      result := rtHide;
    'R':
      result := rtReadOnly;
    'C':
      result := rtCustom;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

constructor TzGenerator.Create(Collection: TCollection);
begin
  inherited;
  FTableName := '';
  FAutoFieldName := true;
  FFieldName := '';
  FGeneratorName := '';
  FExists := true;
end;

{ TzGenerator }

procedure TzGenerator.Assign(Source: TPersistent);
begin
  if Source is TzGenerator then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzGenerator(Source).Name;
      TableName := TzGenerator(Source).TableName;
      AutoFieldName := TzGenerator(Source).AutoFieldName;
      FieldName := TzGenerator(Source).FieldName;
      GeneratorName := TzGenerator(Source).GeneratorName;
      Exists := TzGenerator(Source).Exists;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzGenerator.AsText: string;
begin
  if trim(TableName) = '' then
    result := FieldName + '=' + GeneratorName
  else
    result := TableName + '.' + FieldName + '=' + GeneratorName;
end;

function TzGenerators.FindItemByGeneratorName(GeneratorName: string): integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to count - 1 do
    if SameText(GeneratorName, Items[i].GeneratorName) then
    begin
      result := i;
      Break;
    end;
end;

function TzGenerators.FindItemByTableName(TableName: string): integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to count - 1 do
    if SameText(TableName, Items[i].TableName) then
    begin
      result := i;
      Break;
    end;
end;

constructor TzDomain.Create(Collection: TCollection);
begin
  inherited;
  FExists := true;
  FIdentity := False;
  FCalculated := False;
  FRequired := False;
  FReadOnly := False;
  FReadOnlyField := False;
  FReadOnlyOverride := boNull;
  FRequiredField := False;
  FRequiredOverride := boNull;
  FSize := 0;
  FColSpan := 0;
  FDataType := ftString;
  FDomain := '';
  FLookup := '';
  FDefaultExpression := '';
  FFieldName := '';
  FEditMask := '';
  FDisplayLabel := '';
  FDisplayFormat := '';
  FTableName := '';
  FAlignment := taLeftJustify;
  FCharCase := DefaultCharCase;
  zCtrlType := ctDefault;
  FEditFormat := '';
  FCurrency := False;
  FPrecision := 0;
  FMinValue := 0;
  FMaxValue := 0;
  FBlobType := ftblob;
  FFieldsToClear := '';
  FPasswordChar := '';
  FSanificaEmail := False;
  FHasSensitivity := False;
  FSensitivity := slNone;
end;

procedure TzDomain.Assign(Source: TPersistent);
var
  tmpComboItems: TzPickValues;
  srcDomain: TzDomain;
begin
  if Source is TzDomain then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      srcDomain := TzDomain(Source);
      Name := srcDomain.Name;
      Identity := srcDomain.Identity;

      FReadOnly := srcDomain.FReadOnly;
      FReadOnlyField := srcDomain.ReadOnlyField;
      FReadOnlyOverride := srcDomain.ReadOnlyOverride;
      FRequired := srcDomain.FRequired;
      FRequiredField := srcDomain.RequiredField;
      FRequiredOverride := srcDomain.RequiredOverride;

      Exists := srcDomain.Exists;
      Calculated := srcDomain.Calculated;

      Size := srcDomain.Size;
      ColSpan := srcDomain.ColSpan;
      Domain := srcDomain.Domain;
      Lookup := srcDomain.Lookup;
      PickList := srcDomain.PickList;

      DefaultExpression := srcDomain.DefaultExpression;
      FieldName := srcDomain.FieldName;
      EditMask := srcDomain.EditMask;
      DisplayLabel := srcDomain.DisplayLabel;
      DisplayFormat := srcDomain.DisplayFormat;
      TableName := srcDomain.TableName;
      Alignment := srcDomain.Alignment;
      CharCase := srcDomain.CharCase;
      zCtrlType := srcDomain.zCtrlType;

      EditFormat := srcDomain.EditFormat;
      Currency := srcDomain.Currency;
      Precision := srcDomain.Precision;
      MinValue := srcDomain.MinValue;
      MaxValue := srcDomain.MaxValue;
      BlobType := srcDomain.BlobType;
      PasswordChar := srcDomain.PasswordChar;
      SanificaEmail := srcDomain.SanificaEmail;
      FieldsToClear := srcDomain.FieldsToClear;

      HasSensitivity := srcDomain.HasSensitivity;
      Sensitivity := srcDomain.Sensitivity;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzDomain.GetCtrlSize: integer;
var
  i: integer;
  Len: integer;
begin
  result := Size + 1;

  case DataType of
    ftString, ftFixedChar, ftWideString:
      begin
        result := Size + 1;
        if result < 5 then // ZZ 5
          result := 5;
      end;
    ftBoolean:
      result := 10; // ZZ 3 (per label)
    ftSmallint, ftInteger, TFieldType.ftWord, ftAutoInc, ftLargeint:
      result := 14; // ZZ 10
    ftFloat, ftCurrency, ftBCD, ftFMTBcd:
      result := 14; // ZZ 10
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      result := 14; // ZZ 10
    ftMemo:
      result := 100;
  end;

  case zCtrlType of
    ctComboDlg, ctLookup, ctLookupExt, ctCustomDlg:
      begin
        Inc(result, 7); // ZZ 5
      end;
    ctLookupHyperLink:
      begin
        Inc(result, 10); // ZZ 5
      end;
    ctPickList:
      begin
        if assigned(PickList_Obj) then
          if PickList_Obj.PickValues.count > 0 then
          begin
            for i := 0 to PickList_Obj.PickValues.count - 1 do
            begin

              Len := PickList_Obj.PickValues[i].Name.length;
              if Len > result then
                result := Len;
            end;
            result := result + 5; // ZZ 3
          end;
      end;
    ctRadioGroup:
      begin
        if assigned(PickList_Obj) then
          if PickList_Obj.PickValues.count > 0 then
          begin
            for i := 0 to PickList_Obj.PickValues.count - 1 do
            begin

              Len := PickList_Obj.PickValues[i].Name.length;
              if Len > result then
                result := Len;
            end;
            result := result + 3;
          end;
      end;
    ctPickListImage:
      begin
        if assigned(PickList_Obj) then
          if PickList_Obj.PickValues.count > 0 then
          begin
            for i := 0 to PickList_Obj.PickValues.count - 1 do
            begin
              Len := length(PickList_Obj.PickValues[i].Name);
              if Len > result then
                result := Len;
            end;
            result := result + 3 + 7; // ZZ 5
          end;
      end;

    ctMemo, ctRTF:
      result := 100;

    ctDate: // ZZ
      result := result + 4;
  end; // case
end;

function TzDomain.GetLookup_Obj: TzLookup;
begin
  result := Base.zLookups.get(Lookup, False);
end;

function TzDomain.GetPickList_Obj: TzPickList;
begin
  result := Base.zPickLists.get(PickList, False);
end;

function TzDomain.GetReadOnly: boolean;
begin

  case ReadOnlyOverride of
    boNull:
      result := ReadOnlyField;
    boTrue:
      result := true;
    boFalse:
      result := False;
  end;
end;

procedure TzDomain.SetReadOnly(const Value: boolean);
begin
  // TODO Eliminare la variabile FReadOnly := Value;

  if Value = ReadOnlyField then
    FReadOnlyOverride := boNull
  else
    if Value then
      FReadOnlyOverride := boTrue
    else
      FReadOnlyOverride := boFalse;
end;

function TzDomain.GetRequired: boolean;
begin
  case RequiredOverride of
    boNull:
      result := RequiredField;
    boTrue:
      result := true;
    boFalse:
      result := False;
  end;
end;

procedure TzDomain.SetRequired(const Value: boolean);
begin
  // TODO Eliminare la variabile FRequired := Value;

  if Value = RequiredField then
    FRequiredOverride := boNull
  else
    if Value then
      FRequiredOverride := boTrue
    else
      FRequiredOverride := boFalse;
end;

procedure TzDomain.LoadFromBase;
var
  Item: TzDomain;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDataDictionary.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDomain.SetFieldFlagsFromMetadata(const ReadOnly, Required: boolean);
begin
  FReadOnlyField := ReadOnly;
  FRequiredField := Required;
end;

function TzDomain.DefaultColSpan(ColCount: integer = DefaultColCount): integer;

  function SizeToColSpan(RawSize: integer): integer;
  begin
    // Breakpoint ricalibrati: solo i campi memo/testo libero vanno full-width.
    // Stringhe fino a 50 char occupano al massimo metà riga (6/12).
    if RawSize <= 5 then
      result := 2 // codici corti, boolean-like
    else
      if RawSize <= 10 then
        result := 3 // ~25%
      else
        if RawSize <= 20 then
          result := 4 // ~33%
        else
          if RawSize <= 50 then
            result := 6 // ~50%  ← era 40→6, ora 50→6
          else
            if RawSize <= 100 then
              result := 9 // ~75%  ← era 70→9
            else
              result := 12; // 100% solo per testi molto lunghi
  end;

var
  i, Len, RawSize: integer;
begin
  // --- Fase 1: calcola RawSize (stessa logica di prima) ---
  RawSize := Size + 1;

  case DataType of
    ftString, ftFixedChar, ftWideString:
      begin
        RawSize := Size + 1;
        if RawSize < 5 then
          RawSize := 5;
      end;
    ftBoolean:
      RawSize := 10;
    ftSmallint, ftInteger, TFieldType.ftWord, ftAutoInc, ftLargeint:
      RawSize := 14;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd:
      RawSize := 14;
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      RawSize := 14;
    ftMemo:
      RawSize := 100;
  end;

  case zCtrlType of
    ctComboDlg, ctLookup, ctLookupExt, ctCustomDlg:
      Inc(RawSize, 7);
    ctLookupHyperLink:
      Inc(RawSize, 10);
    ctPickList, ctPickListImage:
      begin
        if assigned(PickList_Obj) and (PickList_Obj.PickValues.count > 0) then
        begin
          for i := 0 to PickList_Obj.PickValues.count - 1 do
          begin
            Len := PickList_Obj.PickValues[i].Name.length;
            if Len > RawSize then
              RawSize := Len;
          end;
          if zCtrlType = ctPickListImage then
            Inc(RawSize, 10) // +3+7
          else
            Inc(RawSize, 5); // +5
        end;
      end;
    ctRadioGroup:
      begin
        if assigned(PickList_Obj) and (PickList_Obj.PickValues.count > 0) then
        begin
          for i := 0 to PickList_Obj.PickValues.count - 1 do
          begin
            Len := PickList_Obj.PickValues[i].Name.length;
            if Len > RawSize then
              RawSize := Len;
          end;
          Inc(RawSize, 3);
        end;
      end;
    ctMemo, ctRTF:
      RawSize := 100;
    ctDate:
      Inc(RawSize, 4);
  end;

  // --- Fase 2: converti RawSize → ColSpan ---

  // Override diretti per tipi che hanno ColSpan semantico fisso
  case DataType of
    ftBoolean:
      begin
        result := 2;
        Exit;
      end; // checkbox: sempre compatto
    ftMemo:
      begin
        result := ColCount;
        Exit;
      end;
  end;

  case zCtrlType of
    ctMemo, ctRTF:
      begin
        result := ColCount;
        Exit;
      end; // sempre full-width
    ctRadioGroup:
      begin
        result := ColCount;
        Exit;
      end; // RadioGroup: sempre full-width
    ctCheckBox:
      begin
        result := 2;
        Exit;
      end;
  end;

  // Caso generale: mappa RawSize → ColSpan
  result := SizeToColSpan(RawSize);

  // Clamp su ColCount reale (per sicurezza se ColCount < 12)
  if result > ColCount then
    result := ColCount;
end;

procedure TzDomain.DefineProperties(Filer: TFiler);
begin
  inherited;

  Filer.DefineProperty('__ReadOnlyField', ReadReadOnlyFieldProperty, WriteReadOnlyFieldProperty, FReadOnlyField <> False);
  Filer.DefineProperty('__RequiredField', ReadRequiredFieldProperty, WriteRequiredFieldProperty, FRequiredField <> False);
end;

procedure TzDomain.ReadReadOnlyFieldProperty(Reader: TReader);
begin
  FReadOnlyField := Reader.ReadBoolean;
end;

procedure TzDomain.WriteReadOnlyFieldProperty(Writer: TWriter);
begin
  Writer.WriteBoolean(FReadOnlyField);
end;

procedure TzDomain.ReadRequiredFieldProperty(Reader: TReader);
begin
  FRequiredField := Reader.ReadBoolean;
end;

procedure TzDomain.WriteRequiredFieldProperty(Writer: TWriter);
begin
  Writer.WriteBoolean(FRequiredField);
end;

procedure TzDomain.WriteJsonExtraProperties(Writer: TJsonTextWriter);
begin
  inherited;

  if FReadOnlyField then
  begin
    Writer.WritePropertyName('__ReadOnlyField');
    Writer.WriteValue(true);
  end;

  if FRequiredField then
  begin
    Writer.WritePropertyName('__RequiredField');
    Writer.WriteValue(true);
  end;
end;

function TzDomain.ReadJsonExtraProperty(const PropName: string; Reader: TJsonTextReader): boolean;
begin
  // un valore composto non e' previsto: lo lascia al serializzatore, che lo
  // salta e lo segnala
  if Reader.TokenType in [TJsonToken.StartObject, TJsonToken.StartArray] then
    Exit(False);

  result := true;

  if SameText(PropName, '__ReadOnlyField') then
    FReadOnlyField := (Reader.TokenType = TJsonToken.Boolean) and Reader.Value.AsBoolean
  else
    if SameText(PropName, '__RequiredField') then
      FRequiredField := (Reader.TokenType = TJsonToken.Boolean) and Reader.Value.AsBoolean
    else
      result := inherited ReadJsonExtraProperty(PropName, Reader);
end;

class procedure TzDomain.DescribeJsonExtraProperties(Schema: TJsonTextWriter);

  procedure BooleanProperty(const PropName: string);
  begin
    Schema.WritePropertyName(PropName);
    Schema.WriteStartObject;
    Schema.WritePropertyName('type');
    Schema.WriteValue('boolean');
    Schema.WritePropertyName('default');
    Schema.WriteValue(False);
    Schema.WriteEndObject;
  end;

begin
  inherited;
  BooleanProperty('__ReadOnlyField');
  BooleanProperty('__RequiredField');
end;

procedure TzDomain.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDomain;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDataDictionary.get(Name, true);
  Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDataDictionary, 'TzDomain.SaveToBase');
end;

procedure TzDomain.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
end;

procedure TzDomain.SetBlobType(const Value: TBlobType);
begin
  FBlobType := Value;
end;

procedure TzDomain.SetCalculated(const Value: boolean);
begin
  FCalculated := Value;
end;

procedure TzDomain.SetCurrency(const Value: boolean);
begin
  FCurrency := Value;
end;

procedure TzDomain.SetDataType(const Value: TFieldType);
begin
  FDataType := Value;
end;

procedure TzDomain.SetDefaultExpression(const Value: string);
begin
  FDefaultExpression := Value;
end;

procedure TzDomain.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
end;

procedure TzDomain.SetDisplayLabel(const Value: string);
begin
  FDisplayLabel := Value;
end;

procedure TzDomain.SetDomain(const Value: string);
begin
  FDomain := Value;
end;

procedure TzDomain.SetEditCharCase(const Value: TEditCharCase);
begin
  FCharCase := Value;
end;

procedure TzDomain.SetEditFormat(const Value: string);
begin
  FEditFormat := Value;
end;

procedure TzDomain.SetEditMask(const Value: string);
begin
  FEditMask := Value;
end;

procedure TzDomain.SetExists(const Value: boolean);
begin
  FExists := Value;
end;

procedure TzDomain.SetFieldName(const Value: TzFieldName);
begin
  FFieldName := Value;
end;

procedure TzDomain.SetFieldsToClear(const Value: string);
begin
  FFieldsToClear := StringReplace(Value, ',', ';', [rfReplaceAll]);
end;

procedure TzDomain.SetLookup(const Value: string);
begin
  if FLookup <> Value then
  begin
    FLookup := Value;
    if Value = '' then
      FLookup := FLookup;

    if not Lookup.IsEmpty then
      if IsEditingProperties then
        if not zCtrlType.IsLookup then
          zCtrlType := zCtrlType.DefaultLookupCtrlType;
  end;
end;

procedure TzDomain.SetLookup_Obj(const Value: TzLookup);
begin
  FLookup := ItemName(Value);
end;

procedure TzDomain.SetMaxValue(const Value: Longint);
begin
  FMaxValue := Value;
end;

procedure TzDomain.SetMinValue(const Value: Longint);
begin
  FMinValue := Value;
end;

procedure TzDomain.SetPasswordChar(const Value: string);
begin
  FPasswordChar := Value;
end;

procedure TzDomain.SetPickList(const Value: string);
begin
  if FPickList <> Value then
  begin
    FPickList := Value;
    if Value = '' then
      FPickList := FPickList;

    if not PickList.IsEmpty then
      if IsEditingProperties then
        if not zCtrlType.IsPickList then
          zCtrlType := ctPickList;
  end;
end;

procedure TzDomain.SetPickList_Obj(const Value: TzPickList);
begin
  FPickList := ItemName(Value);
end;

procedure TzDomain.SetPrecision(const Value: integer);
begin
  FPrecision := Value;
end;

procedure TzDomain.SetSize(const Value: integer);
begin
  FSize := Value;
end;

procedure TzDomain.SetTableName(const Value: TzTableName);
begin
  FTableName := Value;
end;

procedure TzDomain.SetzCtrlType(const Value: TzCtrlType);
begin
  FzCtrlType := Value;
end;

procedure TzDomains.AddNodesToTreeList(MainNode: TcxTreeListNode; DomainOrder: TDomainOrder);
var
  i: integer;
  Master, Child: TcxTreeListNode;
  Text: string;
  Item: TzDomain;
  MasterNodes: TDictionary<string, TcxTreeListNode>;

  function GetText(Item: TzDomain; DomainOrder: TDomainOrder): string;
  begin
    result := '';
    case DomainOrder of
      doByDomain:
        result := Item.Domain;
      doByTable:
        result := Item.TableName;
      doByCtrlType:
        result := Item.zCtrlType.AsString;
    end;
  end;

  function GetMasterNode(Item: TzDomain; DomainOrder: TDomainOrder): TcxTreeListNode;
  var
    NodeText: string;
  begin
    result := nil;
    NodeText := GetText(Item, DomainOrder);
    MasterNodes.TryGetValue(NodeText, result);
    if not assigned(result) then
    begin
      result := MainNode.AddChild;
      result.Values[0] := NodeText;
      result.ImageIndex := self.ImageIndex;
      result.SelectedIndex := self.ImageIndex;
      MasterNodes.Add(NodeText, result);
    end;
  end;

begin
  Assert(assigned(MainNode));

  MainNode.ImageIndex := self.ImageIndex;
  MainNode.SelectedIndex := self.ImageIndex;
  MainNode.DeleteChildren;

  MasterNodes := TDictionary<string, TcxTreeListNode>.Create;
  try
    for i := 0 to count - 1 do
    begin
      Item := Items[i];
      Text := GetText(Item, DomainOrder);
      if trim(Text) = '' then
        Continue;

      Master := GetMasterNode(Item, DomainOrder);

      Child := Master.AddChild;
      Child.Values[0] := Item.Name;
      Child.data := Item;
      Child.ImageIndex := self.ImageIndex;
      Child.SelectedIndex := self.ImageIndex;
    end;
  finally
    FreeAndNil(MasterNodes);
  end;

  // MainNode.CustomSort(nil, true);

  MainNode.CustomSort(CompareDomainNodesByText, true);
end;

procedure TzDomains.FillTreeList(MasterNode: TcxTreeListNode);
var
  Node: TcxTreeListNode;
  ByDomain, ByTable, ByCtrlType: TcxTreeListNode;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');
  MasterNode.TreeList.BeginUpdate;
  try
    Node := MasterNode.AddChild;
    Node.Values[0] := self.Name;
    Node.data := self;
    Node.ImageIndex := self.ImageIndex;
    Node.SelectedIndex := self.ImageIndex;

    sizSystem.LogMessage('By Domain');
    ByDomain := Node.AddChild;
    ByDomain.Values[0] := 'By Domain';
    AddNodesToTreeList(ByDomain, doByDomain);

    sizSystem.LogMessage('By Table');
    ByTable := Node.AddChild;
    ByTable.Values[0] := 'By Table';
    AddNodesToTreeList(ByTable, doByTable);

    sizSystem.LogMessage('By CtrlType');
    ByCtrlType := Node.AddChild;
    ByCtrlType.Values[0] := 'By CtrlType';
    AddNodesToTreeList(ByCtrlType, doByCtrlType);

  finally
    MasterNode.TreeList.EndUpdate;
  end;
  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

procedure TzDomains.QuickSortDomains(DomainOrder: TDomainOrder; L, R: integer);
var
  i, J: integer;
  P, P1, P2: TzDomain;
  token: string;
begin
  repeat
    i := L;
    J := R;
    P := Items[(L + R) shr 1];
    repeat

      case DomainOrder of
        doByDomain:
          begin
            token := P.Domain;
            while AnsiCompareStr(Items[i].Domain, token) < 0 do
              Inc(i);
            while AnsiCompareStr(Items[J].Domain, token) > 0 do
              Dec(J);
          end;
        doByTable:
          begin
            token := P.TableName;
            while AnsiCompareStr(Items[i].TableName, token) < 0 do
              Inc(i);
            while AnsiCompareStr(Items[J].TableName, token) > 0 do
              Dec(J);
          end;
        doByCtrlType:
          begin
            token := P.zCtrlType.AsString;
            while AnsiCompareStr(Items[i].zCtrlType.AsString, token) < 0 do
              Inc(i);
            while AnsiCompareStr(Items[J].zCtrlType.AsString, token) > 0 do
              Dec(J);
          end;
      end;
      if i <= J then
      begin
        P1 := Items[i];
        P2 := Items[J];
        P1.Index := J;
        P2.Index := i;
        Inc(i);
        Dec(J);
      end;
    until i > J;
    if L < J then
      QuickSortDomains(DomainOrder, L, J);
    L := i;
  until i >= R;
end;

procedure TzDomains.Sort;
begin
  inherited;
  sizSystem.LogString('sort', 'sort');
end;

constructor TzDomains.Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: integer; aMaster: TzCollectionItem; const aSorted: boolean);
begin
  // prima di inherited: la creazione della collezione puo' gia' notificare
  FNameIndexLock := TObject.Create;
  FNameIndex := TDictionary<string, integer>.Create;
  FNameIndexGeneration := -1;
  inherited;
end;

destructor TzDomains.Destroy;
begin
  inherited;
  FreeAndNil(FNameIndex);
  FreeAndNil(FNameIndexLock);
end;

// L'indice per nome e' allineato se nessun dominio e' cambiato, in nessun
// dizionario, dall'ultima volta che e' stato costruito o aggiornato
function TzDomains.NameIndexAligned: boolean;
begin
  result := assigned(FNameIndexLock) and (FNameIndexGeneration = FGeneration);
end;

procedure TzDomains.Notify(Item: TCollectionItem; Action: System.Classes.TCollectionNotification);
var
  Aligned: boolean;
begin
  if not assigned(FNameIndexLock) then
  begin
    inherited;
    Inc(FGeneration);
    Exit;
  end;

  System.TMonitor.Enter(FNameIndexLock);
  try
    Aligned := NameIndexAligned;

    inherited;
    Inc(FGeneration);

    // Un dominio aggiunto in coda e ancora senza nome non sposta gli altri e
    // non ha una chiave: l'indice resta valido. E' il caso di Get con
    // CanAppend, che aggiunge e poi assegna il nome (vedi ItemNameChanged).
    // Ogni altro caso (eliminazione, Clear) lo fa ricostruire alla prossima ricerca.
    if Aligned then
      if Action = cnAdded then
        if Item.index = count - 1 then
          if TzDomain(Item).Name.IsEmpty then
            FNameIndexGeneration := FGeneration;
  finally
    System.TMonitor.Exit(FNameIndexLock);
  end;
end;

procedure TzDomains.ItemNameChanged(const OldName, NewName: string; const index: integer);
var
  Aligned: boolean;
  Key: string;
  Existing: integer;
begin
  if not assigned(FNameIndexLock) then
  begin
    inherited;
    Inc(FGeneration);
    Exit;
  end;

  System.TMonitor.Enter(FNameIndexLock);
  try
    Aligned := NameIndexAligned;

    inherited;
    Inc(FGeneration);

    // Il primo nome di un dominio appena aggiunto si inserisce nell'indice
    // senza ricostruirlo. Una vera rinomina lo lascia disallineato: la
    // ricostruzione completa e' l'unico modo di non perdere altri domini con
    // lo stesso nome vecchio.
    if Aligned then
      if OldName.IsEmpty then
        if (index >= 0) and not NewName.IsEmpty then
        begin
          Key := AnsiUpperCase(NewName);

          // come la ricerca lineare, a parita' di nome vale la posizione piu' bassa
          if not FNameIndex.TryGetValue(Key, Existing) or (Existing > index) then
            FNameIndex.AddOrSetValue(Key, index);

          FNameIndexGeneration := FGeneration;
        end;
  finally
    System.TMonitor.Exit(FNameIndexLock);
  end;
end;

procedure TzDomains.RebuildNameIndex;
var
  i: integer;
  Key: string;
begin
  FNameIndex.Clear;

  for i := 0 to count - 1 do
  begin
    Key := AnsiUpperCase(Items[i].Name);

    if not Key.IsEmpty then
      if not FNameIndex.ContainsKey(Key) then
        FNameIndex.Add(Key, i);
  end;

  FNameIndexGeneration := FGeneration;

  sizSystem.LogVerbose(Format('TzDomains.RebuildNameIndex: %s, %d domini', [Name, count]));
end;

// Fuori dall'inizializzazione IndexEnabled e' spento (indexDict non segue
// eliminazioni e rinomine, e distingue le maiuscole), e la ricerca ereditata
// scorre tutti i domini, circa ventimila, con AnsiCompareText: 10-25 ms per
// ricerca, ripetuti per ogni colonna di ogni griglia aperta (TFormRichieste di
// WT: 21 s su 27 all'apertura). Qui la ricerca per nome esatto passa da un
// dizionario con la chiave in maiuscolo, ricostruito quando TzDomains.Generation
// cambia, con lo stesso risultato della scansione: primo dominio con quel
// nome, senza distinzione di maiuscole.
function TzDomains.IndexOf(const Name: string; StartPos: integer; ExcludeIndex: integer; UseStartingWith: boolean): integer;
var
  Key: string;
begin
  if IndexEnabled or UseStartingWith or (StartPos <> 0) or (ExcludeIndex <> -1) or not assigned(FNameIndexLock) then
    Exit(inherited IndexOf(Name, StartPos, ExcludeIndex, UseStartingWith));

  result := -1;

  if Name.IsEmpty then
    Exit;

  Key := AnsiUpperCase(Name);

  System.TMonitor.Enter(FNameIndexLock);
  try
    if not NameIndexAligned then
      RebuildNameIndex;

    if not FNameIndex.TryGetValue(Key, result) then
      Exit(-1);

    // Le posizioni possono cambiare senza notifica (Sort, spostamento di un
    // dominio): se alla posizione ricordata c'e' un altro nome si ricostruisce
    if (result >= count) or (AnsiCompareText(Items[result].Name, Name) <> 0) then
    begin
      RebuildNameIndex;

      if not FNameIndex.TryGetValue(Key, result) then
        result := -1;
    end;
  finally
    System.TMonitor.Exit(FNameIndexLock);
  end;
end;

procedure TzLookups.CollectionSaved;
var
  Item: TzLookup;
begin
  inherited;

  for Item in self do
  begin

    if Item.DbCard.IsEmpty then
      Item.DbCard := Item.DataSet;

    if Item.DbView.IsEmpty then
      Item.DbView := Item.DataSet;
  end;
end;

procedure TzLookups.SaveLookup(zLookup: TzLookup);
var
  Idx: integer;
begin
  if not assigned(zLookup) then
    Exit;

  if zLookup.Name = '' then
    Exit;

  Idx := IndexOf(zLookup.Name);

  if Idx = -1 then
    Add.Assign(zLookup)
  else
    Items[Idx].Assign(zLookup);
end;

constructor TzLookup.Create(Collection: TCollection);
begin
  inherited;
  DataSet := '';
  DbCard := '';
  DbView := '';
  FDisplayColumns := '';
  FKeyField := '';
  FIgnoreFieldReadOnly := true;
  FIsForeignKey := true;
  FExists := true;
  FMasterFields := '';
  FOnlyFromLookup := true;

  FFieldNames := '';
  FTableName := '';
  FFieldNamesFK := '';
  FTableNameFK := '';

  FMappings := TStringList.Create;
end;

destructor TzLookup.Destroy;
begin
  FreeAndNil(FMappings);
  inherited;
end;

function TzLookup.FirstFieldFK: string;
begin
  result := FieldNamesFK;

  if result.Contains(';') then
    result := result.Substring(0, result.IndexOf(';'));
end;

{ TzLookup }

procedure TzLookup.Assign(Source: TPersistent);
var
  zLookup: TzLookup;
begin
  if Source is TzLookup then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      zLookup := TzLookup(Source);
      Name := zLookup.Name;
      KeyField := zLookup.KeyField;
      DisplayColumns := zLookup.DisplayColumns;
      IgnoreFieldReadOnly := zLookup.IgnoreFieldReadOnly;
      IsForeignKey := zLookup.IsForeignKey;
      OnlyFromLookup := zLookup.OnlyFromLookup;
      Exists := zLookup.Exists;
      MasterFields := zLookup.MasterFields;

      FieldNames := zLookup.FieldNames;
      FTableName := zLookup.TableName;
      FieldNamesFK := zLookup.FieldNamesFK;
      FTableNameFK := zLookup.TableNameFK;

      Mappings.Assign(zLookup.Mappings);

      DataSet := zLookup.DataSet;
      DbCard := zLookup.DbCard;
      DbView := zLookup.DbView;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzLookup.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

function TzLookup.GetDbCard_Obj: TzDbCardProps;
begin
  result := Base.zDbCards.get(DbCard, False);
end;

function TzLookup.GetDbView_Obj: TzDbViewProps;
begin
  result := Base.zDbViews.get(DbView, False);
end;

function TzLookup.GetKeyFieldForCombo(DataField: string): string;
var
  SourceField, DestField: string;
  s, link: string;
  i: integer;
  Str: TStringList;
  tmp: string;
begin
  result := KeyField;

  // recupera da mappings
  if not DataField.IsEmpty then
  begin

    tmp := Mappings.Values[DataField];
    if not tmp.IsEmpty then
      result := tmp;
  end;

  /// Se multi campo prende il primo
  result := result.Replace(',', ';');

  if result.Contains(';') then
    result := result.Substring(0, result.IndexOf(';'));
end;

function TzLookup.GetListFieldNamesForCombo(DataField: string): string;
begin
  result := DisplayColumns;

  if result.IsEmpty then
    if not DbView.IsEmpty then
    begin
      if not assigned(DbView_Obj) then
        DbView_Obj := Base.zDbViews.get(DbView);

      if assigned(DbView_Obj) then
        result := DbView_Obj.Columns.VisibleFields;
    end;

  if result.IsEmpty then
    result := GetKeyFieldForCombo(DataField);
end;

function TzLookup.IsMultiField: boolean;
var
  Str: TStringList;
begin
  result := False;

  if FieldNamesFK <> '' then
  begin
    Str := TStringList.Create;
    try
      zSplitStr(FieldNamesFK, ';', Str, true);
      result := Str.count > 1;
    finally
      FreeAndNil(Str);
    end;
  end;
end;

procedure TzLookup.SetDataSet(const Value: string);
begin
  FDataSet := Value;
end;

procedure TzLookup.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzLookup.SetDbCard_Obj(const Value: TzDbCardProps);
begin
  FDbCard := ItemName(Value);
end;

procedure TzLookup.SetDbView_Obj(const Value: TzDbViewProps);
begin
  FDbView := ItemName(Value);
end;

procedure TzLookup.SetDisplayColumns(const Value: string);
begin
  FDisplayColumns := Value.Replace(',', ';', [rfReplaceAll]);
end;

procedure TzLookup.SetExists(const Value: boolean);
begin
  FExists := Value;
end;

procedure TzLookup.SetIsForeignKey(const Value: boolean);
begin
  FIsForeignKey := Value;
end;

procedure TzLookup.SetKeyField(const Value: string);
begin
  FKeyField := StringReplace(Value, ',', ';', [rfReplaceAll]);
end;

procedure TzLookup.SetMappings(const Value: TStringList);
begin
  FMappings.Assign(Value);
end;

procedure TzLookup.SetMasterFields(const Value: string);
begin
  FMasterFields := StringReplace(Value, ',', ';', [rfReplaceAll]);
end;

procedure TzLookup.UpdateDisplayColumnsFromView(const Save2Zip: boolean);
var
  VisibleFields: string;
begin

  if DbView.IsEmpty then
    Exit;

  if not assigned(DbView_Obj) then
    DbView_Obj := Base.zDbViews.get(DbView);

  if not assigned(DbView_Obj) then
    Exit;

  VisibleFields := DbView_Obj.Columns.VisibleFields;

  if DisplayColumns <> VisibleFields then
  begin
    DisplayColumns := VisibleFields;
    Base.SaveZip(csLookups, 'UpdateDisplayColumnsFromView');
  end;
end;

constructor TzTableRect.Create(Collection: TCollection);
begin
  inherited;
  FTop := 0;
  FHeight := 0;
  FLeft := 0;
  FWidth := 0;
end;

procedure TzTableRect.Assign(Source: TPersistent);
begin
  if Source is TzTableRect then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzTableRect(Source).Name;
      Top := TzTableRect(Source).Top;
      Height := TzTableRect(Source).Height;
      Left := TzTableRect(Source).Left;
      Width := TzTableRect(Source).Width;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzTableRect.SetHeight(const Value: integer);
begin
  FHeight := Value;
end;

procedure TzTableRect.SetLeft(const Value: integer);
begin
  FLeft := Value;
end;

procedure TzTableRect.SetTop(const Value: integer);
begin
  FTop := Value;
end;

procedure TzTableRect.SetWidth(const Value: integer);
begin
  FWidth := Value;
end;

constructor TzDataSet.Create(Collection: TCollection);
begin
  inherited;
  FActivationMode := amAutomatic;
  FLazyCreate := true;
  FDataModule := '';
  FMasterDataSet := '';
  FFetchRecsMax := -1; // ZZ 26.08.2022 era default =1000
  FFetchRowsetSize := 100;
  FExtendedFetchOptions := DefaultExtendedFetchOptions; // Mantis #183 - 2026-10-08
  FAutoSQL_Delete := true;
  FAutoSQL_Insert := true;
  FAutoSQL_Update := true;
  FAutoSQL_Refresh := true;
  FReopenAfterPost := False;
  FUpdateChangedFields := False; // Mantis #257 - 2026-10-29
  FReportPipe := '';
  FSanification := true;
  FTableName := '';
  FNoCopyFields := '';
  FPrimaryKeyFields := '';
  FAutoIncFields := '';
  FMasterFields := '';
  FDetailFields := '';
  FCountUpdatedRecords := true;
  FDefaultValues := TStringList.Create;
  FNewRecordOptions := TNewRecordOptions.Create;
  FSQL_Select := TzSQLScript.Create;
  FSQL_Insert := TzSQLScript.Create;
  FSQL_Update := TzSQLScript.Create;
  FSQL_Delete := TzSQLScript.Create;
  FSQL_Refresh := TzSQLScript.Create;
  FFetchGeneratorsPoint := gpNone;
  FGenerator := '';
  FIdentityField := '';
  FFieldNameOID := '';
  FTableRects := TzTableRects.Create(TzTableRect, 'TableRects', -1, nil);
  FTableRects.Sorted := False;
  FStrsTrim := true;
  FStrsTrim2Len := true;
end;

destructor TzDataSet.Destroy;
begin
  FreeAndNil(FSQL_Select);
  FreeAndNil(FSQL_Insert);
  FreeAndNil(FSQL_Update);
  FreeAndNil(FSQL_Delete);
  FreeAndNil(FSQL_Refresh);
  FreeAndNil(FTableRects);
  FreeAndNil(FDefaultValues);
  FreeAndNil(FNewRecordOptions);

  inherited;
end;

{ TzDataSet }

procedure TzDataSet.Assign(Source: TPersistent);
var
  Item: TzDataSet;
begin
  if Source is TzDataSet then
    if Source <> self then
    begin
      Item := TzDataSet(Source);

      Name := Item.Name;

      DataModule := Item.DataModule;
      MasterDataSet := Item.MasterDataSet;
      TableName := Item.TableName;
      ActivationMode := Item.ActivationMode;
      LazyCreate := Item.LazyCreate;
      ReportPipe := Item.ReportPipe;
      Sanification := Item.Sanification;
      AutoSQL_Refresh := Item.AutoSQL_Refresh;
      AutoSQL_Delete := Item.AutoSQL_Delete;
      AutoSQL_Insert := Item.AutoSQL_Insert;
      AutoSQL_Update := Item.AutoSQL_Update;
      FetchRecsMax := Item.FetchRecsMax;
      FetchRowsetSize := Item.FetchRowsetSize;
      ExtendedFetchOptions := Item.ExtendedFetchOptions; // Mantis #183 - 2026-10-08
      PrimaryKeyFields := Item.PrimaryKeyFields;
      AutoIncFields := Item.AutoIncFields;
      MasterFields := Item.MasterFields;
      DetailFields := Item.DetailFields;
      CountUpdatedRecords := Item.CountUpdatedRecords;
      SQL_Select.Text := Item.SQL_Select.Text;
      SQL_Insert.Text := Item.SQL_Insert.Text;
      SQL_Update.Text := Item.SQL_Update.Text;
      SQL_Delete.Text := Item.SQL_Delete.Text;
      SQL_Refresh.Text := Item.SQL_Refresh.Text;
      FetchGeneratorsPoint := Item.FetchGeneratorsPoint;
      Generator := Item.Generator;
      NoCopyFields := Item.NoCopyFields;
      ReopenAfterPost := Item.ReopenAfterPost;
      UpdateChangedFields := Item.UpdateChangedFields; // Mantis #257 - 2026-10-29
      TableRects.Assign(Item.TableRects);
      // il field, non la propriet� per non richiamare il metodo di Set (e non far toccare PrimaryKeyFields)
      FIdentityField := Item.IdentityField;
      FFieldNameOID := Item.FieldNameOID;

      DefaultValues := Item.DefaultValues;
      NewRecordOptions := Item.NewRecordOptions;
      StrsTrim := Item.StrsTrim;
      StrsTrim2Len := Item.StrsTrim2Len;
    end
    else
      inherited;
end;

procedure TzDataSet.BuildSQL(MetaData: TzMetaData);
var
  Keys: TStringList;
  i: integer;
begin
  if TableName = '' then
    Exit;

  SQL_Select.Text := Build_Sql_Select(MetaData, TableName, nil);

  if not AutoSQL_Refresh then
    SQL_Refresh.Text := Build_Sql_Refresh(MetaData, TableName, PrimaryKeyFields);

  if not AutoSQL_Insert then
    SQL_Insert.Text := Build_Sql_Insert(MetaData, TableName, nil);

  if not AutoSQL_Update then
    SQL_Update.Text := Build_Sql_Update(MetaData, TableName, PrimaryKeyFields, nil);

  if not AutoSQL_Delete then
    SQL_Delete.Text := Build_Sql_Delete(MetaData, TableName, PrimaryKeyFields);
end;

function TzDataSet.GetGenerator_Obj: TzGenerator;
begin
  result := Base.zGenerators.get(Generator, False);
end;

procedure TzDataSet.SetActivationMode(const Value: TActivationMode);
begin
  FActivationMode := Value;
end;

procedure TzDataSet.SetAutoIncFields(const Value: string);
begin
  if FAutoIncFields <> Value then
  begin
    FAutoIncFields := Value;
    FAutoIncFields := StringReplace(FAutoIncFields, ' ', '', [rfReplaceAll]);
    FAutoIncFields := StringReplace(FAutoIncFields, ',', ';', [rfReplaceAll]);
  end;
end;

procedure TzDataSet.SetDataModule(const Value: string);
begin
  FDataModule := Value;
end;

procedure TzDataSet.SetDefaultValues(const Value: TStrings);
begin
  FDefaultValues.Assign(Value);
end;

procedure TzDataSet.SetGenerator(const Value: string);
begin
  FGenerator := Value;
end;

procedure TzDataSet.SetGenerator_Obj(const Value: TzGenerator);
begin
  FGenerator := ItemName(Value);
end;

procedure TzDataSet.SetIdentityField(const Value: string);
begin
  // se PK è vuoto oppure = vecchio valore lo imposta al nuovo
  if ((PrimaryKeyFields = IdentityField) or (PrimaryKeyFields = '')) then
    PrimaryKeyFields := Value;

  if ((AutoIncFields = IdentityField) or (AutoIncFields = '')) then
    AutoIncFields := Value;

  FIdentityField := Value;
end;

procedure TzDataSet.SetMasterDataSet(const Value: string);
begin
  FMasterDataSet := Value;
end;

procedure TzDataSet.SetNewRecordOptions(const Value: TNewRecordOptions);
begin
  FNewRecordOptions.Assign(Value);
end;

procedure TzDataSet.SetNoCopyFields(const Value: string);
begin
  FNoCopyFields := Value;
end;

procedure TzDataSet.SetPrimaryKeyFields(const Value: string);
begin
  if FPrimaryKeyFields <> Value then
  begin
    FPrimaryKeyFields := Value;
    FPrimaryKeyFields := StringReplace(FPrimaryKeyFields, ' ', '', [rfReplaceAll]);
    FPrimaryKeyFields := StringReplace(FPrimaryKeyFields, ',', ';', [rfReplaceAll]);
  end;
end;

procedure TzDataSet.SetSQL_Delete(const Value: TzSQLScript);
begin
  FSQL_Delete := Value;
end;

procedure TzDataSet.SetSQL_Insert(const Value: TzSQLScript);
begin
  FSQL_Insert := Value;
end;

procedure TzDataSet.SetSQL_Refresh(const Value: TzSQLScript);
begin
  FSQL_Refresh := Value;
end;

procedure TzDataSet.SetSQL_Select(const Value: TzSQLScript);
begin
  FSQL_Select := Value;
end;

procedure TzDataSet.SetSQL_Update(const Value: TzSQLScript);
begin
  FSQL_Update := Value;
end;

procedure TzDataSet.SetTableName(const Value: TzTableName);
begin
  FTableName := Value;
end;

procedure TzDataSet.SetTableRects(const Value: TzTableRects);
begin
  FTableRects := Value;
end;

procedure TzDataSets.FillTreeList(MasterNode: TcxTreeListNode);

  procedure Add(MasterNode: TcxTreeListNode; zCollection: TzCustomCollection);
  var
    i: integer;
    ImageIndex: integer;
    Item: TzCollectionItem;
    Child, LastNode: TcxTreeListNode;
    Text: string;
    LastText: string;
  begin
    application.ProcessMessages;
    ImageIndex := zCollection.ImageIndex;
    MasterNode.ImageIndex := ImageIndex;
    MasterNode.SelectedIndex := ImageIndex;
    LastNode := nil;
    LastText := '';

    for i := 0 to zCollection.count - 1 do
    begin
      application.ProcessMessages;
      Item := TzCollectionItem(zCollection.Items[i]);
      Text := Item.Name;

      if StartingWith(Text, '__lk_') or StartingWith(Text, '_lk_') then
        Text := '_Lookups'
      else
        if Pos('.', Text) <> 0 then
          Text := System.Copy(Text, 1, Pos('.', Text) - 1)
        else
          Text := '__Empty';

      if trim(Text) <> '' then
      begin
        if not SameText(LastText, Text) then
        begin
          LastText := Text;
          if assigned(LastNode) then
            LastNode.AlphaSort(False);
          LastNode := MasterNode.AddChild;
          LastNode.Values[0] := Text;
          LastNode.ImageIndex := ImageIndex;
          LastNode.SelectedIndex := ImageIndex;
        end;

        Child := LastNode.AddChild;
        Child.Values[0] := Item.Name;
        Child.data := Item;
        Child.ImageIndex := ImageIndex;
        Child.SelectedIndex := ImageIndex;
      end;
    end;

    if assigned(LastNode) then
      LastNode.AlphaSort(False);
  end;

var
  Node: TcxTreeListNode;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');
  MasterNode.TreeList.BeginUpdate;
  try
    Node := MasterNode.AddChild;
    Node.Values[0] := self.Name;
    Node.data := self;
    Node.ImageIndex := self.ImageIndex;
    Node.SelectedIndex := self.ImageIndex;
    Add(Node, self);
  finally
    MasterNode.TreeList.EndUpdate;
  end;
  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

constructor TzDbViewProps.Create(Collection: TCollection);
begin
  inherited;
  FConditionalFormatting := '';
  FDataSet := '';
  FSearchFields := '';
  FTitle := '';
  FButtonDelete := TzButtonProps.Create;
  FButtonEdit := TzButtonProps.Create;
  FButtonInsert := TzButtonProps.Create;
  FButtonDuplica := TzButtonProps.Create;
  FDlgWidth := 500;
  FDlgHeight := 450;

  FPreviewFieldName := '';
  //
  FFlags := TzDbViewFlags.Create;
  FColumns := TzColumns.Create(self);
end;

function TzDbViewProps.zComponentType: TzComponentType;
begin
  inherited;
  result := ctView;
end;

destructor TzDbViewProps.Destroy;
begin
  FreeAndNil(FButtonDelete);
  FreeAndNil(FButtonEdit);
  FreeAndNil(FButtonInsert);
  FreeAndNil(FButtonDuplica);
  FreeAndNil(FFlags);
  FreeAndNil(FColumns);
  inherited;
end;

procedure TzDbViewProps.Assign(Source: TPersistent);
var
  Item: TzDbViewProps;
begin
  inherited Assign(Source); // per Description, ToolActions & ToolFilters

  if Source is TzDbViewProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbViewProps(Source);
      Name := Item.Name;
      DataSet := Item.DataSet;
      DlgWidth := Item.DlgWidth;
      DlgHeight := Item.DlgHeight;
      SearchFields := Item.SearchFields;

      ButtonDelete.Assign(Item.ButtonDelete);
      ButtonEdit.Assign(Item.ButtonEdit);
      ButtonInsert.Assign(Item.ButtonInsert);
      ButtonDuplica.Assign(Item.ButtonDuplica);

      Title := Item.Title;
      ConditionalFormatting := Item.ConditionalFormatting;
      PreviewFieldName := Item.PreviewFieldName;
      FFlags.Assign(Item.Flags);
      Columns.Assign(Item.Columns);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzDbViewProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

function TzDbViewProps.IsBtn_DeleteStored: boolean;
begin
  result := FButtonDelete.IsStored;
end;

function TzDbViewProps.IsBtn_DuplicaStored: boolean;
begin
  result := FButtonDuplica.IsStored;
end;

function TzDbViewProps.IsBtn_EditStored: boolean;
begin
  result := FButtonEdit.IsStored;
end;

function TzDbViewProps.IsBtn_InsertStored: boolean;
begin
  result := FButtonInsert.IsStored;
end;

function TzDbViewProps.LoadFromBase: boolean;
var
  Item: TzDbViewProps;
begin
  result := False;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbViews.get(Name, False);

  result := assigned(Item);

  if result then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDbViewProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDbViewProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbViews.get(Name, true);
  Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbViews, 'TzDbViewProps.SaveToBase');
end;

procedure TzDbViewProps.SetButtonDelete(const Value: TzButtonProps);
begin
  FButtonDelete := Value;
end;

procedure TzDbViewProps.SetButtonDuplica(const Value: TzButtonProps);
begin
  FButtonDuplica := Value;
end;

procedure TzDbViewProps.SetButtonEdit(const Value: TzButtonProps);
begin
  FButtonEdit := Value;
end;

procedure TzDbViewProps.SetButtonInsert(const Value: TzButtonProps);
begin
  FButtonInsert := Value;
end;

procedure TzDbViewProps.SetColumns(const Value: TzColumns);
begin
  FColumns.Assign(Value);
end;

procedure TzDbViewProps.SetDataSet(const Value: string);
begin
  FDataSet := Value;
end;

procedure TzDbViewProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbViewProps.SetSearchFields(const Value: string);
begin
  FSearchFields := Value;
end;

procedure TzDbViewProps.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

{ TzDbView }

constructor TzDbCardProps.Create(Collection: TCollection);
begin
  inherited;
  FCaption := zDefaultCardCaption;
  FCaptionLayout := clTop;
  FButtonDelete := TzButtonProps.Create;
  FButtonEdit := TzButtonProps.Create;
  FButtonInsert := TzButtonProps.Create;
  FButtonDuplica := TzButtonProps.Create;
  FEditCalculated := False;
  FDataSet := '';
  FDlgWidth := -1; // 500;
  FDlgHeight := -1; // 450;
  FBlobLines := 5;
  FTitle := '';
  FColCount := DefaultColCount;
  FSnapToGrid := true;
  FAutoFitHeight := False;
  FControls := TzControls.Create;
  FLayout := TzLayoutItems.Create(TzLayoutItem, 'Layout', -1, nil);
  FFlags := TzDbCardFlags.Create;
end;

function TzDbCardProps.zComponentType: TzComponentType;
begin
  inherited;
  result := ctCard;
end;

destructor TzDbCardProps.Destroy;
begin
  FreeAndNil(FButtonDelete);
  FreeAndNil(FButtonEdit);
  FreeAndNil(FButtonInsert);
  FreeAndNil(FButtonDuplica);
  FreeAndNil(FControls);
  FreeAndNil(FLayout);
  FreeAndNil(FFlags);
  inherited;
end;

procedure TzDbCardProps.Assign(Source: TPersistent);
var
  Item: TzDbCardProps;
begin
  inherited Assign(Source); // per Description, ToolActions & ToolFilters

  if Source is TzDbCardProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbCardProps(Source);
      Name := Item.Name;
      BlobLines := Item.BlobLines;
      Caption := Item.Caption;
      CaptionLayout := Item.CaptionLayout;
      ButtonDelete.Assign(Item.ButtonDelete);
      ButtonEdit.Assign(Item.ButtonEdit);
      ButtonInsert.Assign(Item.ButtonInsert);
      ButtonDuplica.Assign(Item.ButtonDuplica);
      EditCalculated := Item.EditCalculated;
      DlgWidth := Item.DlgWidth;
      DlgHeight := Item.DlgHeight;
      DataSet := Item.DataSet;
      Title := Item.Title;
      ColCount := Item.ColCount;
      SnapToGrid := Item.SnapToGrid;
      AutoFitHeight := Item.AutoFitHeight;

      Flags.Assign(Item.Flags);
      Controls.Assign(Item.Controls);
      Layout.Assign(Item.Layout);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

procedure TzDbCardProps.SetLayout(const Value: TzLayoutItems);
begin
  FLayout.Assign(Value);
end;

function TzDbCardProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

function TzDbCardProps.IsBtn_DeleteStored: boolean;
begin
  result := FButtonDelete.IsStored;
end;

function TzDbCardProps.IsBtn_DuplicaStored: boolean;
begin
  result := FButtonDuplica.IsStored;
end;

function TzDbCardProps.IsBtn_EditStored: boolean;
begin
  result := FButtonEdit.IsStored;
end;

function TzDbCardProps.IsBtn_InsertStored: boolean;
begin
  result := FButtonInsert.IsStored;
end;

procedure TzDbCardProps.LoadFromBase;
var
  Item: TzDbCardProps;
begin

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbCards.get(Name, False);
  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False)
end;

procedure TzDbCardProps.SaveToBase(SaveToLZ: boolean);
var
  Idx: integer;
  Item: TzDbCardProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbCards.get(Name, true);
  Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbCards, 'DbCardSaveProps');
end;

procedure TzDbCardProps.SetButtonDelete(const Value: TzButtonProps);
begin
  FButtonDelete := Value;
end;

procedure TzDbCardProps.SetButtonDuplica(const Value: TzButtonProps);
begin
  FButtonDuplica := Value;
end;

procedure TzDbCardProps.SetButtonEdit(const Value: TzButtonProps);
begin
  FButtonEdit := Value;
end;

procedure TzDbCardProps.SetButtonInsert(const Value: TzButtonProps);
begin
  FButtonInsert := Value;
end;

procedure TzDbCardProps.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TzDbCardProps.SetControls(const Value: TzControls);
begin
  FControls.Assign(Value);
end;

procedure TzDbCardProps.SetDataSet(const Value: string);
begin
  FDataSet := Value;
end;

procedure TzDbCardProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbCardProps.SetDlgWidth(const Value: integer);
begin
  FDlgWidth := Value;
end;

procedure TzDbCardProps.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TzDbViews.FillTreeList(MasterNode: TcxTreeListNode);

  procedure Add(MasterNode: TcxTreeListNode; zCollection: TzCustomCollection);
  var
    i: integer;
    ImageIndex: integer;
    Item: TzCollectionItem;
    Child, LastNode: TcxTreeListNode;
    Text: string;
    LastText: string;
  begin
    application.ProcessMessages;
    ImageIndex := zCollection.ImageIndex;
    MasterNode.ImageIndex := ImageIndex;
    MasterNode.SelectedIndex := ImageIndex;
    LastNode := nil;
    LastText := '';

    for i := 0 to zCollection.count - 1 do
    begin
      application.ProcessMessages;
      Item := TzCollectionItem(zCollection.Items[i]);
      Text := Item.Name;

      if StartingWith(Text, '__lk_') or StartingWith(Text, '_lk_') then
        Text := '_Lookups'
      else
        if Pos('.', Text) <> 0 then
          Text := System.Copy(Text, 1, Pos('.', Text) - 1)
        else
          Text := '__Empty';

      if trim(Text) <> '' then
      begin
        if not SameText(LastText, Text) then
        begin
          LastText := Text;
          if assigned(LastNode) then
            LastNode.AlphaSort(False);
          LastNode := MasterNode.AddChild;
          LastNode.Values[0] := Text;
          LastNode.ImageIndex := ImageIndex;
          LastNode.SelectedIndex := ImageIndex;
        end;

        Child := LastNode.AddChild;
        Child.Values[0] := Item.Name;
        Child.data := Item;
        Child.ImageIndex := ImageIndex;
        Child.SelectedIndex := ImageIndex;
      end;
    end;

    if assigned(LastNode) then
      LastNode.AlphaSort(False);
  end;

var
  Node: TcxTreeListNode;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');
  MasterNode.TreeList.BeginUpdate;
  try
    Node := MasterNode.AddChild;
    Node.Values[0] := self.Name;
    Node.data := self;
    Node.ImageIndex := self.ImageIndex;
    Node.SelectedIndex := self.ImageIndex;
    Add(Node, self);
  finally
    MasterNode.TreeList.EndUpdate;
  end;
  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

procedure TzDbCards.FillTreeList(MasterNode: TcxTreeListNode);

  procedure Add(MasterNode: TcxTreeListNode; zCollection: TzCustomCollection);
  var
    i: integer;
    ImageIndex: integer;
    Item: TzCollectionItem;
    Child, LastNode: TcxTreeListNode;
    Text: string;
    LastText: string;
  begin
    application.ProcessMessages;
    ImageIndex := zCollection.ImageIndex;
    MasterNode.ImageIndex := ImageIndex;
    MasterNode.SelectedIndex := ImageIndex;
    LastNode := nil;
    LastText := '';

    for i := 0 to zCollection.count - 1 do
    begin
      application.ProcessMessages;
      Item := TzCollectionItem(zCollection.Items[i]);
      Text := Item.Name;

      if StartingWith(Text, '__lk_') or StartingWith(Text, '_lk_') then
        Text := '_Lookups'
      else
        if Pos('.', Text) <> 0 then
          Text := System.Copy(Text, 1, Pos('.', Text) - 1)
        else
          Text := '__Empty';

      if trim(Text) <> '' then
      begin
        if not SameText(LastText, Text) then
        begin
          LastText := Text;
          if assigned(LastNode) then
            LastNode.AlphaSort(False);
          LastNode := MasterNode.AddChild;
          LastNode.Values[0] := Text;
          LastNode.ImageIndex := ImageIndex;
          LastNode.SelectedIndex := ImageIndex;
        end;

        Child := LastNode.AddChild;
        Child.Values[0] := Item.Name;
        Child.data := Item;
        Child.ImageIndex := ImageIndex;
        Child.SelectedIndex := ImageIndex;
      end;
    end;

    if assigned(LastNode) then
      LastNode.AlphaSort(False);
  end;

var
  Node: TcxTreeListNode;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');
  MasterNode.TreeList.BeginUpdate;
  try
    Node := MasterNode.AddChild;
    Node.Values[0] := self.Name;
    Node.data := self;
    Node.ImageIndex := self.ImageIndex;
    Node.SelectedIndex := self.ImageIndex;
    Add(Node, self);
  finally
    MasterNode.TreeList.EndUpdate;
  end;
  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

constructor TzSystem.Create(aOwner: TComponent);
begin
  inherited;

  if assigned(Base) then
    if not(csDesigning in ComponentState) then
      raise Exception.Create('TzSystem Singleton');
  Base := self;

  FIsAdminDisabled := False;
  FAppName := '';
  FZipBusy := False;
  FImageList16 := nil;
  FImageList24 := nil;
  FOnHyperLink := nil;
  FOnAssignDataSetEvent := nil;
  FOnAssignFieldOnChangeEvent := nil;
  FOnCustomDialog := nil;
  DisableHyperLink := False;
  FFDPhysFBDriverLink := nil;
  FParams := TStringList.Create;
  FQueryParams := TzQueryParams.Create(TzQueryParam, 'QueryParams', -1, nil);
  InitParams;
  FzLoaded := False;
  FolderCache := TDictionary<string, string>.Create;

  // Mantis #106 - 2026-09-10: -1 e non 0, cosi' la mappa viene costruita anche
  // la prima volta che i MetaData risultano vuoti.
  MetaDefaults := TDictionary<string, string>.Create;
  MetaDefaultsCount := -1;
  FMetaData := TzMetaData.Create(self);
  FMetaData.Name := 'MetaData';
  FzDataDictionary := TzDomains.Create(TzDomain, 'DataDictionary', imgDataDictionary, nil, False);
  FzDataModules := TzDataModules.Create(TzDataModule, 'DataModules', imgDataModules, nil);
  FzLookups := TzLookups.Create(TzLookup, 'Lookups', imgLookups, nil);
  FzStoredProcs := TzStoredProcs.Create(TzStoredProc, 'zStoredProcs', imgStoredProcs, nil);
  FzGenerators := TzGenerators.Create(TzGenerator, 'Generators', imgGenerators, nil);
  FzDataSets := TzDataSets.Create(TzDataSet, 'DataSets', imgDataSets, nil);
  FzDbCards := TzDbCards.Create(TzDbCardProps, 'Cards', imgCards, nil);
  FzDbViews := TzDbViews.Create(TzDbViewProps, 'DbViews', imgDbViews, nil);
  FzDbPivots := TzDbPivots.Create(TzDbPivotProps, 'Pivots', imgPivots, nil);
  FzDbRecordViews := TzDbRecordViews.Create(TzDbRecordViewProps, 'RecordViews', imgRecordViews, nil);
  FzDbTrees := TzDbTrees.Create(TzDbTreeProps, 'Trees', imgTrees, nil);
  FzDbCharts := TzDbCharts.Create(TzDbChartProps, 'Charts', imgCharts, nil);
  FzDbSchedulers := TzDbSchedulers.Create(TzDbSchedulerProps, 'Schedulers', imgSchedulers, nil);

  FzFiles := TzFileViewersProps.Create(TzFileViewerProps, 'Files', imgPdf, nil);
  FzPickLists := TzPickLists.Create(TzPickList, 'PickLists', imgPickLists, nil);
  FzForms := TzForms.Create(TzForm, 'Forms', imgForms, nil);
  FzWizards := TzWizards.Create(TzWizard, 'Wizards', imgWizards, nil);
  FzCubes := TzCubes.Create(TzCubeProps, 'Cubes', imgCubes, nil);
  FzTips := TzTips.Create(TzTip, 'Tips', imgTips, nil);

  FzMaps := TzMaps.Create(TzMapProps, 'Maps', imgMaps, nil);
  FzTatukMaps := TzTatukMaps.Create(TzTatukMap, 'TatukMaps', imgMaps, nil);

  FzSecurity := TzSecurity.Create(self);

  InitPropertyEditors;
end;

destructor TzSystem.Destroy;
begin
  FreeAndNil(FParams);
  FreeAndNil(FQueryParams);
  FreeAndNil(FolderCache);
  FreeAndNil(MetaDefaults); // Mantis #106 - 2026-09-10
  FreeAndNil(FMetaData);
  FreeAndNil(FzDataDictionary);
  FreeAndNil(FzDataModules);
  FreeAndNil(FzLookups);
  FreeAndNil(FzStoredProcs);
  FreeAndNil(FzGenerators);
  FreeAndNil(FzDataSets);
  FreeAndNil(FzDbCards);
  FreeAndNil(FzDbViews);
  FreeAndNil(FzDbPivots);
  FreeAndNil(FzDbRecordViews);
  FreeAndNil(FzDbTrees);
  FreeAndNil(FzDbCharts);
  FreeAndNil(FzDbSchedulers);
  FreeAndNil(FzFiles);
  FreeAndNil(FzPickLists);
  FreeAndNil(FzForms);
  FreeAndNil(FzWizards);
  FreeAndNil(FzCubes);
  FreeAndNil(FzTips);
  FreeAndNil(FzMaps);
  FreeAndNil(FzTatukMaps);
  FreeAndNil(FzSecurity);
  inherited;
  Base := nil;
end;

procedure TzSystem.DropCollectionDuplicates;
begin
  zCubes.DropDuplicates;
  zDataDictionary.DropDuplicates;
  zDataModules.DropDuplicates;
  zDataSets.DropDuplicates;
  zDbCards.DropDuplicates;
  zDbViews.DropDuplicates;
  zDbPivots.DropDuplicates;
  zDbRecordViews.DropDuplicates;
  zDbTrees.DropDuplicates;
  zDbCharts.DropDuplicates;
  zDbSchedulers.DropDuplicates;
  zFiles.DropDuplicates;
  zForms.DropDuplicates;
  zGenerators.DropDuplicates;
  zLookups.DropDuplicates;
  zPickLists.DropDuplicates;
  zStoredProcs.DropDuplicates;
  zTips.DropDuplicates;
  zWizards.DropDuplicates;

  zMaps.DropDuplicates;
  zTatukMaps.DropDuplicates;
end;

procedure TzSystem.AddQueryParam(ParamName: string; Value: Variant);
var
  Idx: integer;
  Item: TzQueryParam;
begin
  Idx := QueryParams.IndexOf(ParamName);

  if Idx = -1 then
    Item := QueryParams.Add
  else
    Item := QueryParams[Idx];

  Item.Name := ParamName;
  Item.Value := Value;
end;

procedure TzSystem.BackupZip;
begin
  BackupZipIn(Path + 'BackupLZ\');
end;

procedure TzSystem.BackupZipIn(const BackupFolder: string);
var
  BackupFileName: string;
begin
  ForceDirectories(BackupFolder);
  BackupFileName := IncludeTrailingPathDelimiter(BackupFolder) + FileNameNoExt(FileName) + ' - ' + NomeFileFromDate(Now) + EXtractFileExt(FileName);
  siMain.LogString('Backup LZ', BackupFileName);

  if TFile.Exists(FileName) then
    if not TFile.Exists(BackupFileName) then
      TFile.Copy(FileName, BackupFileName);
end;

procedure TzSystem.Login(const AllowParams: boolean; const ShowWaitForm: boolean = true; callback: TProc = nil);
begin
  if not assigned(zFbDatabase) then
    raise Exception.Create('Database non assegnato');

  zSecurity.Login(AllowParams);

  if not zSecurity.LoggedIn then
    zSecurity.TerminateApplication
  else
  begin
    begin
      FolderCache.Clear;
      Overrides.LoadFromDB(zFbDatabase);
    end;

    if assigned(callback) then
      callback;

    LoadZip(ShowWaitForm);
  end;
end;

procedure TzSystem.CustomDialog(Sender: TObject; Field: TField; TagString: string;

  var Value: Variant);
begin
  if assigned(FOnCustomDialog) then
    OnCustomDialog(Sender, Field, TagString, Value);
end;

function TzSystem.DataSetEditProps(DataSet: TzFbDataSet): boolean;
var
  Item: TzDataSet;
  i: integer;
  Idx: integer;
  idDataSet: string;
begin
  result := False;

  if not assigned(DataSet) then
    Exit;

  idDataSet := Get_IdDataSet(DataSet);
  if trim(idDataSet) = '' then
    Exit;

  Idx := zDataSets.IndexOf(idDataSet);
  if Idx = -1 then
    Exit;

  Item := zDataSets[Idx];

  result := Edit_CollectionItem(self, Item);

  if result then
  begin
    // 18.07.2016: vanno in palla le Reference zDataSets[idx].Assign := Item;
    SaveZip(csDataSets, 'DataSetEditProps');
    DataSetLoadProps(DataSet);
  end;
end;

// Mantis #257 - 2026-10-29: UpdateSQL automatico del dataset e le sue parti,
// con cui TzFbDataSet.ComponiUpdateSQL riscrive al salvataggio il SET con le
// sole colonne cambiate. Le parti sono le stesse che Build_Sql_Update usa per
// il testo completo, che resta in UpdateSQL per l'editor e per chi lo legge.
// AutoUpdate si accende per ultimo: fotografa il testo appena scritto.
procedure ImpostaUpdateAutomatico(DataSet: TzFbDataSet; MetaData: TzMetaData; const TableName, PrimaryKeyFields: string);
var
  Colonne: TStringList;
begin
  DataSet.AutoUpdate := false;
  DataSet.UpdateSQL.Text := Build_Sql_Update(MetaData, TableName, PrimaryKeyFields, nil);

  Colonne := TStringList.Create;
  try
    Get_FieldNames(MetaData, TableName, Colonne, false);
    DataSet.AutoUpdateColumns := Colonne;

    // le stesse chiavi di Calc_WhereByKeyFields
    if PrimaryKeyFields = '' then
      Get_KeyFields(MetaData, TableName, Colonne)
    else
    begin
      Colonne.Delimiter := ';';
      Colonne.StrictDelimiter := true;
      Colonne.DelimitedText := PrimaryKeyFields;
    end;
    DataSet.AutoUpdateKeyFields := Colonne;

    Get_FieldNames(MetaData, TableName, Colonne, true);
    DataSet.AutoUpdateReturning := Colonne;
  finally
    FreeAndNil(Colonne);
  end;

  DataSet.AutoUpdateWhere := Calc_WhereByKeyFields(MetaData, TableName, PrimaryKeyFields);

  // UPDATE non ammesso (vista senza trigger di UPDATE): niente da comporre
  DataSet.AutoUpdate := Trim(DataSet.UpdateSQL.Text) <> '';
end;

procedure TzSystem.DataSetLoadProps(DataSet: TzFbDataSet);
var
  idDataSet: string;
  zFbDataSet: TzFbDataSet;
  i: integer;
  Idx: integer;
  idx_field: integer;
  DataModuleName: string;
  Item: TzDataSet;
  Keys: TStringList;
  idxGenerator: integer;
  Misura: boolean;
  Cronometro: TStopwatch;
begin
  if not assigned(DataSet) then
    Exit;

  // Misura per la sessione di registrazione attivabile dall'utente. A
  // registrazione spenta il costo e' la lettura di un booleano.
  Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
  if Misura then
    Cronometro := TStopwatch.StartNew;

  DataSet.OnGetQueryParams := DataSetQueryParams;
  DataSet.OnInitFields := InitFields;

  if DataSet.idDataSet = '' then
    DataSet.idDataSet := Get_IdDataSet(DataSet);
  idDataSet := DataSet.idDataSet;

  if idDataSet = idDataSet_Null then
    Exit;

  Idx := zDataSets.IndexOf(idDataSet);

  if Idx <> -1 then // trovato
  begin
    Item := zDataSets[Idx];

    DataSet.Active := False;
    DataSet.FieldDefs.Clear;
    DataSet.Fields.Clear;
    DataSet.Unprepare;
    DataSet.TableName := Item.TableName;
    DataSet.ActivationMode := Item.ActivationMode;
    DataSet.ReopenAfterPost := Item.ReopenAfterPost;
    DataSet.ReportPipe := Item.ReportPipe;
    DataSet.Sanification := Item.Sanification;

    DataSet.DefaultSQL.Text := trim(Item.SQL_Select.Text);
    DataSet.SelectSQL.Text := trim(Item.SQL_Select.Text);
    DataSet.IdentityField := Item.IdentityField;
    DataSet.FieldNameOID := Item.FieldNameOID;

    DataSet.DefaultValues := Item.DefaultValues;
    DataSet.NewRecordOptions := Item.NewRecordOptions;

    DataSet.FetchOptions.RecsMax := Item.FetchRecsMax;
    DataSet.FetchOptions.RowsetSize := Item.FetchRowsetSize;
    // Mantis #183 - 2026-10-08: qui il dataset e' chiuso e spreparato (sopra),
    // quindi le due opzioni valgono gia' per il BuildFields e l'apertura che seguono.
    DataSet.ExtendedFetchOptions := Item.ExtendedFetchOptions;
    DataSet.PrimaryKeyFields := Item.PrimaryKeyFields; // nel caso di view firedac non può calcolarla
    DataSet.AutoIncFields := Item.AutoIncFields;

    DataSet.MasterFields := Item.MasterFields;
    DataSet.DetailFields := Item.DetailFields;

    { TODO : Passaggio a FDAC: Verificare }
    // if Item.IdentityField <> '' then
    // DataSet.AutoUpdateOptions.UseReturningFields := [rfKeyFields];

    { TODO : FDAC: le query le genera in automatico }
    if Item.AutoSQL_Refresh then
      DataSet.RefreshSQL.Text := Build_Sql_Refresh(MetaData, Item.TableName, Item.PrimaryKeyFields, nil)
    else
      DataSet.RefreshSQL.Text := trim(Item.SQL_Refresh.Text);

    if Item.AutoSQL_Insert then
      DataSet.InsertSQL.Text := Build_Sql_Insert(MetaData, Item.TableName, nil, Item.IdentityField)
    else
      DataSet.InsertSQL.Text := trim(Item.SQL_Insert.Text);

    // Mantis #257 - 2026-10-29: con l'UPDATE automatico il dataset riceve anche
    // le parti per comporre al salvataggio il SET con le sole colonne cambiate
    // (ImpostaUpdateAutomatico), usate solo se UpdateChangedFields e' accesa;
    // quello scritto a mano resta com'e'.
    DataSet.UpdateChangedFields := Item.UpdateChangedFields;
    if Item.AutoSQL_Update then
      ImpostaUpdateAutomatico(DataSet, MetaData, Item.TableName, Item.PrimaryKeyFields)
    else
    begin
      DataSet.AutoUpdate := false;
      DataSet.UpdateSQL.Text := trim(Item.SQL_Update.Text);
    end;

    if Item.AutoSQL_Delete then
      DataSet.DeleteSQL.Text := Build_Sql_Delete(MetaData, Item.TableName, Item.PrimaryKeyFields)
    else
      DataSet.DeleteSQL.Text := trim(Item.SQL_Delete.Text);

    DataSet.UpdateOptions.FetchGeneratorsPoint := Item.FetchGeneratorsPoint;
    DataSet.UpdateOptions.CountUpdatedRecords := Item.CountUpdatedRecords;

    if trim(Item.Generator) <> '' then
    begin
      idxGenerator := zGenerators.IndexOf(Item.Generator);
      if idxGenerator <> -1 then
      begin
        if zGenerators[idxGenerator].Exists then
        // ZZ 24.07.2014: se viene assegnato un generatore inesistente infopower scoppia
        begin
          DataSet.PrimaryKeyFields := zGenerators[idxGenerator].FieldName;
          DataSet.AutoIncFields := zGenerators[idxGenerator].FieldName;
          DataSet.GeneratorName := Item.Generator; //
        end;
      end;
    end;
    //
    InitFields(DataSet);
  end // \trovato
  else
  begin // non ha trovato id_dataset
    Item := zDataSets.Add;
    Item.Name := idDataSet;

    // Se vuota determina Tablename da Select
    if trim(DataSet.TableName) = '' then
      if trim(DataSet.SelectSQL.Text) <> '' then
        DataSet.TableName := GetTableNameFromSQL(DataSet.SelectSQL.Text);

    if trim(DataSet.TableName) <> '' then
    begin
      Item.IdentityField := MetaData.GetIdentity(Item.TableName);
      DataSet.IdentityField := Item.IdentityField;

      if trim(DataSet.SelectSQL.Text) = '' then
        DataSet.SelectSQL.Text := Build_Sql_Select(MetaData, DataSet.TableName, nil);

      DataSet.DefaultSQL.Text := DataSet.SelectSQL.Text;

      DataSet.RefreshSQL.Text := Build_Sql_Refresh(MetaData, DataSet.TableName, '', nil);
      DataSet.InsertSQL.Text := Build_Sql_Insert(MetaData, DataSet.TableName, nil, Item.IdentityField);
      // Mantis #257 - 2026-10-29: UPDATE automatico con le parti per il SET
      // ridotto, come per i dataset del dizionario; UpdateChangedFields resta
      // quello del dataset (predefinito False)
      ImpostaUpdateAutomatico(DataSet, MetaData, DataSet.TableName, '');
      DataSet.DeleteSQL.Text := Build_Sql_Delete(MetaData, DataSet.TableName, '');

      // cercare il generatore
      idxGenerator := zGenerators.FindItemByTableName(DataSet.TableName);
      if idxGenerator <> -1 then
      begin
        DataSet.PrimaryKeyFields := zGenerators[idxGenerator].FieldName;
        DataSet.AutoIncFields := zGenerators[idxGenerator].FieldName;
        DataSet.GeneratorName := zGenerators[idxGenerator].GeneratorName;
      end;

      if assigned(DataSet.DataSource) then
        if assigned(DataSet.DataSource.DataSet) then
          if DataSet.DataSource.DataSet is TzFbDataSet then
          begin
            DataSet.SelectSQL.Text := zSqlLib.Build_FkRelation(MetaData, DataSet.SelectSQL.Text, DataSet.TableName, (DataSet.DataSource.DataSet as TzFbDataSet).TableName);
            Modified := true;
          end;
    end;
    // fine init da tablename

    Item.TableName := DataSet.TableName;
    Item.ActivationMode := DataSet.ActivationMode;
    Item.ReportPipe := DataSet.ReportPipe;
    Item.Sanification := DataSet.Sanification;

    Item.DefaultValues := DataSet.DefaultValues;
    Item.NewRecordOptions := DataSet.NewRecordOptions;
    Item.ExtendedFetchOptions := DataSet.ExtendedFetchOptions; // Mantis #183 - 2026-10-08

    Item.MasterFields := DataSet.MasterFields;
    Item.DetailFields := DataSet.DetailFields;

    Item.SQL_Select.Text := DataSet.SelectSQL.Text;
    Item.StrsTrim := DataSet.FormatOptions.StrsTrim;
    Item.StrsTrim2Len := DataSet.FormatOptions.StrsTrim2Len;
    // AutoXXX
    // Item.SQL_Refresh.Text := DataSet.RefreshSQL.Text;
    // item.SQL_Update.Text := DataSet.UpdateSQL.Text;
    // item.SQL_Insert.Text := DataSet.InsertSQL.Text;
    // item.SQL_Delete.Text := DataSet.DeleteSQL.Text;
    // Item.Generator := DataSet.GeneratorName;

    Modified := true;
  end; // \nuovo
  //

  /// /////////////////////////////////////////////
  //
  //
  //
  // esempio: master/detail su detail documenti,
  // insert sul master causa il download dell'intero datset
  DataSet.FetchOptions.AutoFetchAll := afTruncate;
  DataSet.OnRecordLimitReached := DataSetRecordLimitReached;

  DataSet.FormatOptions.StrsTrim := Item.StrsTrim;
  DataSet.FormatOptions.StrsTrim2Len := Item.StrsTrim2Len;

  if assigned(DataSet.DataBase) then
    if DataSet.DataBase.Connected then
      if not DataSet.SelectSQL.Text.IsEmpty then
        DataSet.BuildFields;
  //

  if Misura then
    zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, 'DataSetLoadProps', Cronometro.ElapsedMilliseconds, DataSet.Name);
end;

procedure TzSystem.DataSetQueryParams(DataSet: TDataSet);
begin
  if DataSet is TzFbDataSet then
    QueryParams.SetDataSetParams(DataSet as TzFbDataSet);
end;

procedure TzSystem.DataSetRecordLimitReached(Sender: TObject);
var
  DataSet: TzFbDataSet;
begin

  if not(Sender is TzFbDataSet) then
    Exit;

  DataSet := (Sender as TzFbDataSet);

  ConfirmOk('Raggiunto il limite di ' + DataSet.FetchOptions.RecsMax.ToString + ' record scaricati dal server.' + slinebreak + 'Utilizzare i filtri per ridurre il numero dei dati selezionati.');
  Exit;

  // da studiare meglio. Resettare il tutto durante un'estrazione o altro non è il massimo
  if ConfirmYesNo('Raggiunto il limite di ' + DataSet.FetchOptions.RecsMax.ToString + ' record scaricati dal server.' + slinebreak + 'Si desidera provare a scaricare ulteriori dati?', mtWarning) then
  begin
    DataSet.FetchOptions.RecsMax := -1;
    DataSet.ReOpen();
  end;
end;

function TzSystem.GetDomain(Field: TField): TzDomain;
var
  Idx: integer;
  Origin: string;
  DataSet: TzFbDataSet;
begin
  result := nil;

  if not assigned(Field) then
    Exit;

  Origin := Field.Origin;

  if assigned(Field.DataSet) then
    if Field.DataSet is TzFbDataSet then
      Origin := TzFbDataSet(Field.DataSet).FieldOrigin(Field);

  Idx := zDataDictionary.IndexOf(Origin);
  if Idx = -1 then
    Exit;

  result := zDataDictionary.Items[Idx];
end;

function TzSystem.GetFileName: string;
begin
  if csDesigning in ComponentState then
    result := FFileName
  else
  begin
    if trim(FFileName) = '' then
      result := ChangeFileExt(application.exename, zExtension_System)
    else
      result := FFileName;
  end;
end;

function TzSystem.GetHelpContext(Ctrl: TWinControl): integer;
begin
  result := 1;
end;

function TzSystem.GetSqlDomainFromMetaData(RelationName, FieldName: string): string;
var
  idxRel, idxFld: integer;
begin
  result := '';

  idxRel := MetaData.Tables.IndexOf(RelationName);
  if idxRel <> -1 then
  begin

    idxFld := MetaData.Tables[idxRel].Fields.IndexOf(FieldName);
    if idxFld = -1 then
      Exit;

    result := MetaData.Tables[idxRel].Fields[idxFld].Domain;
  end
  else
  begin
    idxRel := MetaData.Views.IndexOf(RelationName);
    if idxRel <> -1 then
    begin
      idxFld := MetaData.Views[idxRel].Fields.IndexOf(FieldName);
      if idxFld = -1 then
        Exit;

      result := MetaData.Views[idxRel].Fields[idxFld].Domain;
    end
    else
    begin
      idxRel := MetaData.Procedures.IndexOf(RelationName);
      if idxRel <> -1 then
      begin
        idxFld := MetaData.Procedures[idxRel].ParamsOutput.IndexOf(FieldName);
        if idxFld = -1 then
          Exit;

        result := MetaData.Procedures[idxRel].ParamsOutput[idxFld].Domain;
      end;
    end;
  end;
end;

function TzSystem.Setting(const Name: string; default: string): string;
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_UTENTI_SETTINGS_GET_VALUE);
  try
    sp.Prepare;
    sp.ParamByName('USER_ID').Clear; // user corrente
    sp.ParamByName('SETTING').AsString := Name;
    sp.ParamByName('DEFAULT_VALUE').AsString := default;
    sp.ExecProc;
    result := sp.ParamByName('VALORE').AsString;
  finally
    FreeAndNil(sp);
  end;
end;

function TzSystem.Get_IdDataSet(DataSet: TzFbDataSet): string;
begin
  result := idDataSet_Null;

  if not assigned(DataSet) then
    Exit;

  // guarda se � assegnato al componente
  result := DataSet.idDataSet;

  // altrimenti lo cerca per datamodule/dataset
  if trim(result) = '' then
    if assigned(DataSet.Owner) then
      result := DataSet.Owner.Name + '.' + DataSet.Name
    else // da dove beep arriva?
      result := idDataSet_Null;
end;

procedure TzSystem.HyperLink(Sender: TObject; FieldName: string; Value: Variant);
begin
  if DisableHyperLink then
    Exit;

  if varIsNull(Value) then
    Exit;

  DisableHyperLink := true;
  try
    if assigned(FOnHyperLink) then
      OnHyperLink(Sender, FieldName, Value);
  finally
    DisableHyperLink := False;
  end;
end;

// Mantis #106 - 2026-09-10: restituisce il valore di DEFAULT che i MetaData
// riportano per una colonna, gia' risolto dalla vista alla tabella di origine
// (OriginRelationName/OriginRelationField). E' la stessa fonte da cui
// InitializeFromDB popola i domini del dizionario.
//
// La mappa si costruisce una volta sola perche' MetaData.DataDictionary non ha
// indice (IndexEnabled resta False fuori dall'inizializzazione): una Get diretta
// e' una scansione lineare su circa ventimila voci, e ripeterla per ogni campo
// di ogni dataset aperto costerebbe minuti di CPU per sessione.
// Si ricostruisce quando cambia il numero di voci, cioe' dopo una rilettura dei
// metadati dal database.
function TzSystem.MetaDataDefault(const FieldOrigin: string): string;
var
  MetaDict: TzmdDataDictionaryItem;
begin
  result := '';

  if not assigned(MetaDefaults) then
    Exit;

  if MetaDefaultsCount <> MetaData.DataDictionary.count then
  begin
    MetaDefaults.Clear;

    for MetaDict in MetaData.DataDictionary do
      if not MetaDict.DefaultValue.IsEmpty then
        MetaDefaults.AddOrSetValue(uppercase(MetaDict.Name), MetaDict.DefaultValue);

    MetaDefaultsCount := MetaData.DataDictionary.count;

    sizSystem.LogMessage(Format('MetaDataDefault: mappa dei default ricostruita, %d campi con DEFAULT su %d voci di metadati', [MetaDefaults.count, MetaDefaultsCount]));
  end;

  MetaDefaults.TryGetValue(uppercase(FieldOrigin), result);
end;

procedure TzSystem.InitFields(DataSet: TDataSet);
var
  idDataSet: string;
  zFbDataSet: TzFbDataSet;
  i: integer;
  Idx: integer;
  idx_field: integer;
  SalvaFileSLTutto: boolean;
  DataModuleName: string;
  zDataSet: TzDataSet;
  Keys: TStringList;
  Field: TField;
  Domain: TzDomain;
  FloatField: TFloatField;
  Origin: string;
begin
  if not assigned(DataSet) then
    Exit;

  zFbDataSet := TzFbDataSet(DataSet);

  if zFbDataSet.SelectSQL.Text = '' then
    Exit;

  idDataSet := Get_IdDataSet(zFbDataSet);

  if idDataSet = idDataSet_Null then
  begin
    // Mantis #106 - 2026-09-10: senza id il dataset non ha voce nel dizionario e
    // nessuno dei suoi campi ricevera' il proprio default. Finora l'uscita era
    // muta, e la perdita si vedeva solo come violazione NOT NULL in POST.
    sizSystem.LogVerbose('InitFields: dataset senza id, nessun default applicato (' + zFbDataSet.Name + ')');
    Exit;
  end;

  zDataSet := zDataSets.get(idDataSet, False);

  if not assigned(zDataSet) then
  begin
    // Mantis #106 - 2026-09-10: stesso effetto, con l'id noto: il dizionario LZ
    // non contiene questo dataset.
    sizSystem.LogVerbose('InitFields: dataset non presente nel dizionario, nessun default applicato (' + idDataSet + ')');
    Exit;
  end;

  /// //////////////////////////////////////////////////

  for i := 0 to zFbDataSet.Fields.count - 1 do
  begin
    Field := zFbDataSet.Fields[i];

    Origin := zFbDataSet.FieldOrigin(Field); // per calculated
    if Origin = '' then
      Origin := trim(zFbDataSet.TableName) + '.' + Field.FieldName;

    Idx := zDataDictionary.IndexOf(Origin);
    /// //////////////////////////////////////////////////////////////////////////////////////////////////
    if Idx <> -1 then
      Domain := zDataDictionary[Idx] // trovato
    else
    begin // inserimento
      Modified := true;
      Domain := zDataDictionary.Add;
      Domain.Name := Origin;
      Domain.Alignment := Field.Alignment;

      if Field is TBlobField then
        Domain.BlobType := (Field as TBlobField).BlobType;

      Domain.Calculated := Field.Calculated;

      if Field is TFloatField then
        Domain.Currency := (Field as TFloatField).Currency;

      Domain.DataType := Field.DataType;
      Domain.DefaultExpression := Field.DefaultExpression;

      // Mantis #106 - 2026-09-10: per una colonna di vista Field.DefaultExpression
      // e' sempre vuota, perche' il DEFAULT sta sulla tabella di origine e non
      // arriva nel TField. La voce appena creata nascerebbe quindi senza il
      // default che il campo ha davvero: si legge dai MetaData.
      if Domain.DefaultExpression.IsEmpty then
        Domain.DefaultExpression := MetaDataDefault(Origin);

      if SameText(Field.FieldName, Field.DisplayLabel) then
        Domain.DisplayLabel := FormatDisplayLabel(Field.FieldName)
      else
        Domain.DisplayLabel := Field.DisplayLabel;

      /// //////////////////////////////////////////////////////////////////////////////////////
      // sull'origine
      Domain.TableName := System.Copy(Origin, 1, Pos('.', Origin) - 1);
      if Domain.TableName = '' then
        Domain.TableName := zFbDataSet.TableName;

      Domain.FieldName := System.Copy(Origin, Pos('.', Origin) + 1, length(Origin));
      if Domain.FieldName = '' then
        Domain.FieldName := Field.FieldName;
      /// //////////////////////////////////////////////////////////////////////////////////////

      if Field.Calculated then
        Domain.Domain := 'Calculated'
        // DataSet.TableName + '.' + Field.FieldName;
      else
      begin
        Domain.Domain := GetSqlDomainFromMetaData(Domain.TableName, Domain.FieldName); // dai Metadata

        // da ricedere con il 2.1 cosa restituisce
        if Domain.Domain = '' then
        begin
          Domain.Domain := '<???>';
          if MetaData.Procedures.IndexOf(Domain.TableName) <> -1 then
            Domain.Domain := '<procedure>'
          else
            if MetaData.Views.IndexOf(Domain.TableName) <> -1 then
              Domain.Domain := '<view>'
            else
              if MetaData.Tables.IndexOf(Domain.TableName) <> -1 then
                Domain.Domain := '<table>'
              else
              begin
                // cache..
                Domain.Domain := '';
                Domain.Calculated := False;
              end;
        end;
      end;

      Domain.EditMask := Field.EditMask;
      Domain.Exists := true;

      if Field is TFloatField then
        Domain.Precision := (Field as TFloatField).Precision;

      if isNumeric(Field.DataType) then
      begin
        if isInteger(Field.DataType) then
          Domain.DisplayFormat := '###,##0'
        else
          Domain.DisplayFormat := '###,##0.00';
      end;

      if SameText(Domain.FieldName, 'SELECTED') then
        Domain.ReadOnly := False
      else
        if Domain.Calculated then
          Domain.ReadOnly := true
        else
          Domain.ReadOnly := Field.ReadOnly;

      Domain.Required := Field.Required;
      Domain.Size := dx.FieldSize(Field);
      Domain.zCtrlType := GetCtrlType(Field.DataType, Domain.Domain);

      Domain.Lookup := MetaData.GetLookup(Domain.TableName, Domain.FieldName);
      if Domain.Lookup <> '' then
      begin
        Domain.zCtrlType := TzCtrlType.DefaultLookupCtrlType;
        Idx := zLookups.IndexOf(Domain.Lookup);
        if Idx <> -1 then
          if zLookups[Idx].IsMultiField then
            Domain.zCtrlType := ctComboDlg;
      end
      else
        // Mantis #5307 - 2026-11-03: un segnaposto (<procedure>, <view>, ...) non e'
        // un dominio: se nel dizionario c'e' una picklist con quel nome, il campo
        // diventava un elenco a immagini e il suo valore non si vedeva.
        if (not IsDomainPlaceholder(Domain.Domain)) and (zPickLists.IndexOf(Domain.Domain) <> -1) then
        begin
          Domain.zCtrlType := ctPickListImage;
          Domain.PickList := Domain.Domain;
        end;
      // Mantis #106 - 2026-09-10: una voce creata in esecuzione significa che il
      // dizionario distribuito (il file .LZ accanto all'eseguibile) non copre
      // questo campo. Finora accadeva in silenzio, e la perdita del default
      // restava invisibile fino all'errore in POST.
      sizSystem.LogMessage(Format('InitFields: voce di dizionario mancante per "%s" (dataset %s), creata in esecuzione con DefaultExpression="%s"', [Origin, idDataSet, Domain.DefaultExpression]));
    end;
    // fine inserimento //////////////////////////////////////////////////
    /// //////////////////////////////////////////////////////////////////////////////////////////////////
    /// //////////////////////////////////////////////////////////////////////////////////////////////////
    /// //////////////////////////////////////////////////////////////////////////////////////////////////

    if Domain.Identity then
    begin
      Field.AutoGenerateValue := arAutoInc;
      Field.ReadOnly := true;
    end;

    Field.Alignment := Domain.Alignment;
    Field.DisplayLabel := Domain.DisplayLabel;
    Field.EditMask := Domain.EditMask;

    // Mantis #106 - 2026-09-10: una voce di dizionario senza default puo' venire
    // da un .LZ non allineato: creata quando il campo non aveva ancora il
    // DEFAULT, o sintetizzata da una versione precedente di questo metodo, che
    // copiava la DefaultExpression vuota del TField. I MetaData sono la fonte
    // piu' attendibile e il ripiego vale per la sola sessione in corso: il
    // dizionario non viene toccato, quindi non finisce salvato nel .LZ.
    // La soppressione voluta di un default passa da OVERRIDES/ofSuppressDefault,
    // applicata in fondo a questo metodo, e resta prioritaria.
    if Domain.DefaultExpression.IsEmpty then
      Field.DefaultExpression := MetaDataDefault(Origin)
    else
      Field.DefaultExpression := Domain.DefaultExpression;

    // if SameText(Field.FieldName, 'SELECTED') then
    // Field.ReadOnly := False
    // else
    // ZZ 16.01.2026: ripristinato (variazioni.superficie_tassabile)
    Field.ReadOnly := Domain.ReadOnly;

    // ZZ 23.11.2018: lookup su campi di join
    if Field.ReadOnly then
      if Domain.zCtrlType.IsLookup then
        if zFbDataSet.IsJoinedField(Field.FieldName) or zFbDataSet.IsServerCalcField(Field.FieldName) then
          Field.ReadOnly := False;

    Field.Required := Domain.Required;
    if Field.Required then
      if zFbDataSet.IsJoinedField(Field.FieldName) or zFbDataSet.IsServerCalcField(Field.FieldName) then
        Field.Required := False;

    if Field is TNumericField then
    begin
      TNumericField(Field).DisplayFormat := Domain.DisplayFormat;
      TNumericField(Field).EditFormat := Domain.EditFormat;
    end
    else
      if Field is TFloatField then
      begin
        FloatField := TFloatField(Field);
        FloatField.Currency := Domain.Currency;
        FloatField.Precision := Domain.Precision;
        FloatField.MinValue := Domain.MinValue;
        FloatField.MaxValue := Domain.MaxValue;
      end
      else
        if Field is TBlobField then
        begin
          TBlobField(Field).BlobType := Domain.BlobType;
        end;

    //
    if not Domain.OnChange.IsEmpty then
      AssignFieldOnChangeEvent(Field, Domain.OnChange);

    // Mantis #161 - 2026-09-29: fin qui il ciclo non lascia traccia sul
    // percorso normale (nessuna voce mancante, nessun errore): il difetto delle
    // didascalie di colonna raw e delle maschere numeriche non applicate, visto
    // solo su alcune postazioni, non e' mai stato visibile in un registro. Una
    // riga per campo col valore realmente rimesso su
    // DisplayLabel/DisplayFormat/DefaultExpression chiude la domanda al primo
    // confronto fra una postazione che funziona e una che non funziona.
    if Field is TNumericField then
      sizSystem.LogVerbose(Format('InitFields: %s DisplayLabel="%s" DisplayFormat="%s" DefaultExpression="%s"', [Origin, Field.DisplayLabel, TNumericField(Field).DisplayFormat, Field.DefaultExpression]))
    else
      sizSystem.LogVerbose(Format('InitFields: %s DisplayLabel="%s" DefaultExpression="%s"', [Origin, Field.DisplayLabel, Field.DefaultExpression]));
  end;

  /// /////////////
  ///

  if Overrides.OverrideExists(idDataSet, [ofSuppressDefault]) then
    for Field in DataSet.Fields do
      if Overrides.OverrideExists(idDataSet, Field.FieldName, [ofSuppressDefault]) then
      begin
        var
          OverrideItem: TOverrideItem := Overrides.FindOverride(idDataSet, Field.FieldName);

        if OverrideItem.SuppressDefault then
          Field.DefaultExpression := '';
      end;
end;

procedure TzSystem.InitializeFromDB;
var
  ProgressBox: TProgressBox;
begin
  if not assigned(zFbDatabase) then
    Exit;

  ProgressBox := TProgressBox.Create(nil);
  try
    ProgressBox.CancelEnabled := False;

    ProgressBox.Show(FirebirdMetadataCallBackSteps + 9, 'Aggiornamento Metadata', 'Attendere...', 'Attendere...');
    try
      FillFireBirdMetadata(MetaData, zFbDatabase, zFbTransaction, False,
        procedure(msg: string)
        begin
          ProgressBox.IncProgress(msg);
        end);

      ProgressBox.IncProgress('Salvataggio medatada');
      // why??? zSecurity.SaveZip;

      Init_zSystem(self, MetaData,
        procedure(msg: string)
        begin
          ProgressBox.IncProgress(msg);
        end);

      zLoaded := true;

      ProgressBox.IncProgress('Salvataggio file LZ');
      SaveZip(csAll, 'InitFromDB');
      ProgressBox.IncProgress('Aggiornamento terminato');
    finally
      ProgressBox.Close;
    end;
  finally
    FreeAndNil(ProgressBox);
  end;
end;

procedure TzSystem.UpdateFromDB(Database: TzFbDatabase; Transaction: TzFbTransaction; CallBack: TProc<string>);
begin
  if not assigned(Database) then
    raise Exception.Create('UpdateFromDB: database non assegnato');
  if not assigned(Transaction) then
    raise Exception.Create('UpdateFromDB: transazione non assegnata');

  // Gli stessi due passi di InitializeFromDB, con la stessa LoadSource = False
  FillFireBirdMetadata(MetaData, Database, Transaction, False, CallBack);
  Init_zSystem(self, MetaData, CallBack);
  zLoaded := true;
end;

procedure TzSystem.InitParams;
var
  s: string;
  Str: TStringList;
  LastUser: string;
  LastConnection: string;
  i: integer;
begin
  Params.Clear;
  s := '';

  // for i := 1 to ParamCount do
  // s := s + AnsiDequotedStr(ParamStr(i), '"') + ' ';
  //
  // s := StringReplace(trim(s), '-', #13, [rfReplaceAll]);
  //
  // Params.Text := s;
  //
  //
  // for i := 0 to Params.count - 1 do
  // Params[i] := trim(Params[i]);

  for i := 1 to ParamCount do
  begin
    s := trim(AnsiDequotedStr(ParamStr(i), '"'));
    s := s.Replace('-', '').Replace('/', '').Replace('\', '');
    Params.Add(s);
  end;
end;

procedure TzSystem.InitPropertyEditors;
begin
  zSystemPropertyEditors.SetGlobalzSystem(self);
  zSystemPropertyEditors.InitPropertyEditors;
end;

procedure TzSystem.LoadZip(const ShowWaitForm: boolean = true);
var
  Zipper: TZipper;
  DataDizionario: TDateTime;

  procedure LoadMetaData;
  var
    Stream: TMemoryStream;
  begin
    sizSystem.EnterMethod('LoadMetaData');

    // if not Zipper.FileExists(MetaData.Name) then
    // Exit;

    Stream := TMemoryStream.Create;
    try
      Zipper.LoadStream(Stream, MetaData.Name);
      Stream.Position := 0;
      MetaData.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    sizSystem.LeaveMethod('LoadMetaData');
  end;

  procedure ClearCollections;
  begin
    zDataDictionary.Clear;
    zDataModules.Clear;
    zLookups.Clear;
    zStoredProcs.Clear;
    zDataSets.Clear;
    zGenerators.Clear;
    zDbCards.Clear;
    zDbViews.Clear;
    zDbPivots.Clear;
    zDbRecordViews.Clear;
    zDbTrees.Clear;
    zDbCharts.Clear;
    zDbSchedulers.Clear;
    zFiles.Clear;
    zPickLists.Clear;
    zForms.Clear;
    zWizards.Clear;
    zCubes.Clear;
    FzTips.Clear;
    zMaps.Clear;
    zTatukMaps.Clear;
  end;

  procedure doStartWait;
  begin
    if ShowWaitForm then
      StartWait('System...');
  end;

  procedure doStopWait;
  begin
    if ShowWaitForm then
      StopWait;
  end;

begin
  sizSystem.EnterMethod(self, 'LoadZip');

  // Quale dizionario si carica e di quando: presso i clienti l'eseguibile e
  // l'LZ stanno spesso su cartelle di rete, e senza queste due voci un
  // registro non dice se la postazione ha letto l'archivio atteso o una
  // copia vecchia.
  if FileExists(FileName) then
  begin
    sizSystem.LogString('LoadZip: dizionario', FileName);
    if FileAge(FileName, DataDizionario) then
      sizSystem.LogString('LoadZip: data dizionario', FormatDateTime('yyyy-mm-dd hh:nn:ss', DataDizionario));
  end
  else
    sizSystem.LogString('LoadZip: dizionario assente', FileName);

  doStartWait;
  try

    if FileExists(FileName) then
    begin

      if ZipBusy then
        Exit;

      FZipBusy := true;
      try
        zLoaded := true;
        Zipper := TZipper.Create;
        try
          Zipper.ZipFileName := FileName;
          LoadMetaData;
          ClearCollections;

          Zipper.LoadCollection(zDataDictionary);
          Zipper.LoadCollection(zDataModules);
          Zipper.LoadCollection(zLookups);
          Zipper.LoadCollection(zStoredProcs);
          Zipper.LoadCollection(zDataSets);
          Zipper.LoadCollection(zGenerators);
          Zipper.LoadCollection(zDbViews);
          Zipper.LoadCollection(zDbCards);
          Zipper.LoadCollection(zDbPivots);
          Zipper.LoadCollection(zDbRecordViews);
          Zipper.LoadCollection(zDbTrees);
          Zipper.LoadCollection(zDbCharts);
          Zipper.LoadCollection(zDbSchedulers);
          Zipper.LoadCollection(zFiles);
          Zipper.LoadCollection(zPickLists);
          Zipper.LoadCollection(zForms);
          Zipper.LoadCollection(zWizards);
          Zipper.LoadCollection(zCubes);
          Zipper.LoadCollection(zMaps);
          Zipper.LoadCollection(zTatukMaps);
          Zipper.LoadCollection(zTips);
        finally
          FreeAndNil(Zipper);
        end;
      finally
        FZipBusy := False;
      end;

      UpdateStructure;
    end
    else
    begin
      if not ConfirmOkCancel('Il file ' + FileName + ' non esiste.' + #13 + #10 + 'Inizializzo dal DataBase?') then
        Exit;

      InitializeFromDB;
    end;
  finally
    doStopWait;
  end;
  sizSystem.LeaveMethod(self, 'LoadZip');
end;

procedure TzSystem.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then
  begin
    if AComponent = FzFbDatabase then
      FzFbDatabase := nil
    else
      if AComponent = FzFbTransaction then
        FzFbTransaction := nil
      else
        if AComponent = FImageList16 then
          FImageList16 := nil
        else
          if AComponent = FImageList24 then
            FImageList24 := nil;
  end;
end;

procedure TzSystem.SaveChanges;
begin
  if Modified then
    SaveZip(csAll, 'SaveChanges');
end;

procedure TzSystem.SaveZip(Collection2Save: TCollection2Save; Msg2Log: string);
begin
  sizSystem.EnterMethod(self, 'SaveZip');
  // ==============================================================================
  // ZZ marted� 21 giugno 2005
  // ==============================================================================
  // In GDA entrando senza utente spazza il file
  // ==============================================================================

  Modified := False;

  if not zSecurity.LoggedIn then
    Exit;

  if not zLoaded then
    Exit;

  // ZZ 18.03.2016: dovrebbe evitare la rottura dell'lz.
  // Solamente noi con ctrl+F12 possiamo far salvare l'lz.
  // Il test sul fileexists � per la creazione del file da db
  if (not IsAdmin) and (FileExists(FileName)) then
    Exit;

  WriteZip(Collection2Save, Msg2Log, zSecurity.LoginParams.UserName, Path + 'BackupLZ\');
  sizSystem.LeaveMethod(self, 'SaveZip');
end;

procedure TzSystem.SaveZipUnattended(Collection2Save: TCollection2Save; const Msg2Log, UserName: string);
begin
  sizSystem.EnterMethod(self, 'SaveZipUnattended');
  Modified := False;

  if not zLoaded then
    raise Exception.Create('SaveZipUnattended: dizionario non caricato, l''archivio non si salva');
  if ZipBusy then
    raise Exception.Create('SaveZipUnattended: un altro salvataggio dell''archivio e'' in corso');
  if FileName = '' then
    raise Exception.Create('SaveZipUnattended: nome dell''archivio non impostato');

  WriteZip(Collection2Save, Msg2Log, UserName, IncludeTrailingPathDelimiter(ExtractFilePath(ExpandFileName(FileName))) + 'BackupLZ\');
  sizSystem.LeaveMethod(self, 'SaveZipUnattended');
end;

procedure TzSystem.WriteZip(Collection2Save: TCollection2Save; const Msg2Log, UserName, BackupFolder: string);
var
  Zipper: TZipper;
  Log: TStringList;

  procedure SaveLog;
  begin
    Log := TStringList.Create;
    try
      Zipper.LoadStrings(Log, 'Log.txt');
      Log.Add(DateTimeToStr(Now) + ' User: ' + UserName + ' @ ' + Msg2Log + ' @ - Cards:' + IntToStr(zDbCards.count));
      Zipper.SaveStrings(Log, 'Log.txt');
    finally
      FreeAndNil(Log);
    end;
  end;

  procedure SaveMetaData;

  // Scrive (o rimuove) la voce di UN formato secondo i flag globali di
  // zCollectionPersistence, come fa TZipper.SaveCollection per le collection.
    procedure SyncOneFormat(const aFormat: TzPersistenceFormat; const Enabled: boolean);
    var
      Stream: TMemoryStream;
    begin
      if not Enabled then
      begin
        Zipper.RemoveStream(MetaData.Name, aFormat);
        Exit;
      end;

      Stream := TMemoryStream.Create;
      try
        MetaData.SaveToStreamAs(Stream, aFormat);
        Zipper.SaveStream(Stream, MetaData.Name, aFormat);
      finally
        FreeAndNil(Stream);
      end;
    end;

  begin
    sizSystem.EnterMethod('SaveMetaData');
    SyncOneFormat(pfJSON, zCollectionPersistence.WriteJSON);
    SyncOneFormat(pfDFM, zCollectionPersistence.WriteDFM);
    sizSystem.LeaveMethod('SaveMetaData');
  end;

  procedure SaveCollection(Collection: TzCustomCollection; Save: boolean);
  begin
    if Save then
    begin
      sizSystem.LogVerbose('SaveCollection: ' + Collection.Name);
      Zipper.SaveCollection(Collection, '');
    end;
  end;

begin
  if ZipBusy then
    Exit;

  FZipBusy := true;
  try
    BackupZipIn(BackupFolder); // ZZ 14.01.2019 ad ogni salvataggio verrà creato il backup

    Zipper := TZipper.Create;
    try
      Zipper.ZipFileName := FileName;

      SaveLog;

      if Collection2Save in [csAll, csMetadata] then
        SaveMetaData;

      SaveCollection(zDataDictionary, Collection2Save in [csAll, csFieldProps, csDataDictionary]);
      SaveCollection(zDataModules, Collection2Save in [csAll, csDataModules]);
      SaveCollection(zLookups, Collection2Save in [csAll, csFieldProps, csDataDictionary, csLookups]);
      SaveCollection(zStoredProcs, Collection2Save in [csAll, csStoredProcs]);
      SaveCollection(zGenerators, Collection2Save in [csAll, csGenerators]);
      SaveCollection(zDataSets, Collection2Save in [csAll, csFieldProps, csDataSets, csDataModules]);
      SaveCollection(zDbViews, Collection2Save in [csAll, csDbViews, csDataModules]);
      SaveCollection(zDbCards, Collection2Save in [csAll, csDbCards, csDataModules]);
      SaveCollection(zDbPivots, Collection2Save in [csAll, csDbPivots, csDataModules]);
      SaveCollection(zDbRecordViews, Collection2Save in [csAll, csDbRecordViews, csDataModules]);
      SaveCollection(zDbTrees, Collection2Save in [csAll, csDbTrees, csDataModules]);
      SaveCollection(zDbCharts, Collection2Save in [csAll, csDbCharts, csDataModules]);
      SaveCollection(zDbSchedulers, Collection2Save in [csAll, csDbSchedulers, csDataModules]);
      SaveCollection(zFiles, Collection2Save in [csAll, csFiles, csDataModules]);
      SaveCollection(zPickLists, Collection2Save in [csAll, csFieldProps, csDataDictionary, csPickLists]);
      SaveCollection(zForms, Collection2Save in [csAll, csForms]);
      SaveCollection(zWizards, Collection2Save in [csAll, csWizards]);
      SaveCollection(zCubes, Collection2Save in [csAll, csCubes, csDataModules]);
      SaveCollection(zMaps, Collection2Save in [csAll, csMaps, csDataModules]);
      SaveCollection(zTatukMaps, Collection2Save in [csAll, csMaps, csDataModules]);
      SaveCollection(zTips, Collection2Save in [csAll, csTips]);
    finally
      FreeAndNil(Zipper);
    end;
  finally
    FZipBusy := False;
  end;
end;

procedure TzSystem.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

procedure TzSystem.SeTCustomImagelist16(const Value: TCustomImagelist);
begin
  FImageList16 := Value;
end;

procedure TzSystem.SetParams(const Value: TStringList);
begin
  FParams.Assign(Value);
end;

procedure TzSystem.SetQueryParams(const Value: TzQueryParams);
begin
  FQueryParams.Assign(Value);
end;

procedure TzSystem.SeTCustomImagelist24(const Value: TCustomImagelist);
begin
  FImageList24 := Value;
end;

procedure TzSystem.SetzCubes(const Value: TzCubes);
begin
  FzCubes := Value;
end;

procedure TzSystem.SetzDataDictionary(const Value: TzDomains);
begin
  FzDataDictionary := Value;
end;

procedure TzSystem.SetzDataModules(const Value: TzDataModules);
begin
  FzDataModules := Value;
end;

procedure TzSystem.SetzDataSets(const Value: TzDataSets);
begin
  FzDataSets := Value;
end;

procedure TzSystem.SetzDbCards(const Value: TzDbCards);
begin
  FzDbCards := Value;
end;

procedure TzSystem.SetzDbViews(const Value: TzDbViews);
begin
  FzDbViews := Value;
end;

procedure TzSystem.SetzFiles(const Value: TzFileViewersProps);
begin
  FzFiles := Value;
end;

procedure TzSystem.SetzFbDatabase(const Value: TzFbDatabase);
begin
  FzFbDatabase := Value;
end;

procedure TzSystem.SetzFbTransaction(const Value: TzFbTransaction);
begin
  FzFbTransaction := Value;
end;

procedure TzSystem.SetzForms(const Value: TzForms);
begin
  FzForms.Assign(Value);
end;

procedure TzSystem.SetzGenerators(const Value: TzGenerators);
begin
  FzGenerators := Value;
end;

procedure TzSystem.SetzLookups(const Value: TzLookups);
begin
  FzLookups := Value;
end;

procedure TzSystem.SetzTatukMaps(const Value: TzTatukMaps);
begin
  FzTatukMaps.Assign(Value);
end;

procedure TzSystem.SetzPickLists(const Value: TzPickLists);
begin
  FzPickLists := Value;
end;

procedure TzSystem.SetzSecurity(const Value: TzSecurity);
begin
  if FzSecurity <> Value then
  begin
    FzSecurity.Assign(Value);
  end;
end;

procedure TzSystem.SetzStoredProcs(const Value: TzStoredProcs);
begin
  FzStoredProcs.Assign(Value);
end;

procedure TzSystem.SetzWizards(const Value: TzWizards);
begin
  FzWizards.Assign(Value);
end;

function TzSystem.ShowSystemForm: boolean;
begin
  result := zSystemFrm.ShowSystemForm(self);
end;

procedure TzSystem.UpdateGenerators;

  procedure Update(Query: TFDQuery; TableName, FieldName, GeneratorName: string);
  var
    Max: Int64;
  begin
    if trim(TableName) = '' then
      Exit;

    if trim(FieldName) = '' then
      Exit;

    if trim(GeneratorName) = '' then
      Exit;

    Query.Close;
    Query.SQL.Text := 'SELECT MAX(' + FieldName + ') FROM ' + TableName;
    try
      Query.ExecSQL;
      try
        if Query.Fields[0].IsNull then
          Max := 0
        else
          Max := Query.Fields[0].Value;
      finally
        Query.Close;
      end;

      Query.SQL.Text := 'SET GENERATOR ' + GeneratorName + ' TO ' + Max.ToString + ';';
      Query.ExecSQL;
      Query.Close;
    except
    end;
  end;

var
  i: integer;
  s, TableName, FieldName, GeneratorName: string;
  Query: TFDQuery;
  ProgressBox: TProgressBox;
begin
  Query := TFDQuery.Create(self);
  try
    Query.Name := 'UpdateGenerators';
    Query.Connection := zFbDatabase;
    Query.Transaction := zFbTransaction;
    Query.UpdateOptions.AutoCommitUpdates := true;

    ProgressBox := TProgressBox.Create(self);
    try
      ProgressBox.CancelEnabled := true;
      ProgressBox.Show(zGenerators.count, 'Progressivi', '', 'Attendere...');
      try
        for i := 0 to zGenerators.count - 1 do
        begin
          ///

          if SameText(zGenerators[i].TableName, 'PAGOPA_FLUSSI_USCITA_PENDENZE') then
            siMain.LogString('TableName', zGenerators[i].TableName);

          if zGenerators[i].Exists = true then
          begin
            TableName := zGenerators[i].TableName;
            FieldName := zGenerators[i].FieldName;
            GeneratorName := trim(zGenerators[i].GeneratorName);

            siMain.LogString('TableName', TableName);
            siMain.LogString('FieldName', FieldName);
            siMain.LogString('GeneratorName', GeneratorName);

            ProgressBox.IncProgress(TableName);
            if ProgressBox.Cancelled then
              Exit;

            Update(Query, TableName, FieldName, GeneratorName);
          end;
        end;
        ///
      finally
        ProgressBox.Close;
      end;
    finally
      FreeAndNil(ProgressBox);
    end;
  finally
    FreeAndNil(Query);
  end;
end;

procedure TzSystem.UpdateStructure;
var
  dm: TzDataModule;
  frm: TzForm;
  s: string;
begin
  Exit;

  for dm in zDataModules do
  begin

    // s := dm.Name;
    // s := StringReplace(s, 'TForm', '', [RfIgnoreCase]);
    // s := StringReplace(s, 'Form', '', [RfIgnoreCase]);
    // s := StringReplace(s, 'TWiz', '', [RfIgnoreCase]);
    //
    /// /    dm.ControllerOptions := dm.FormControllerOptions;
    //
    // dm.BuildGUI := dm.ControllerOptions.BuildGUI;
    // dm.FormOptions.HelpType := htKeyword;
    // dm.FormOptions.HelpContext := 0;
    //
    frm := zForms.get(dm.Name, False);
    if not assigned(frm) then
      frm := zForms.get('T' + dm.Name, False);
    if not assigned(frm) then
      frm := zForms.get('TForm' + dm.Name, False);
    if not assigned(frm) then
      frm := zForms.get('Form' + dm.Name, False);
    if not assigned(frm) then
      frm := zForms.get('TWiz' + dm.Name, False);
    if not assigned(frm) then
      frm := zForms.get('T' + dm.Name.Replace('DM', '') + 'Form', False);

    // TWizGeneraAccertamentoForm

    if assigned(frm) then
    begin
      dm.FormOptions.Caption := frm.Caption;
      dm.FormOptions.ReportGroup := frm.ReportGroup;
      dm.FormOptions.HelpKeyword := frm.HelpKeyword;
    end
    else
      ConfirmOk(dm.Name);
    //
    // if dm.FormOptions.Caption.IsEmpty then
    // dm.FormOptions.Caption := s;
    //
    // if dm.FormOptions.HelpKeyword.IsEmpty then
    // dm.FormOptions.HelpKeyword := s;
    //
    // if dm.FormOptions.ReportGroup.IsEmpty then
    // dm.FormOptions.ReportGroup := s;
  end;

  SaveZip(csAll, '');
end;

function TzSystem.ConfigFolder: string;
begin
  result := '';

  if not zSecurity.LoggedIn then
    Exit;

  result := Root_Config;
  result := IncludeTrailingPathDelimiter(result + zSecurity.LoginParams.UserFolder);
  ForceDirectories(result);
end;

function TzSystem.RootFolder(const FolderName, defaultFolder: string): string;
var
  DefaultValue: string;
begin
  result := '';

  if not zSecurity.LoggedIn then
    Exit;

  DefaultValue := Path + defaultFolder;

  result := Folder(FolderName, DefaultValue);

  if not result.IsEmpty then
  begin
    result := IncludeTrailingPathDelimiter(result);

    // siMain.LogString('RootFolder: ' + FolderName, result);
    ForceDirectories(result);
  end;
end;

function TzSystem.Root_Config: string;
begin
  result := RootFolder('ROOT_CONFIG', 'CartellaConfigurazioneUtenti');
end;

function TzSystem.Root_PersonalData: string;
begin
  result := RootFolder('ROOT_PERSONAL_DATA', 'CartellaDatiPersonaliUtenti');
end;

function TzSystem.Root_Files: string;
begin
  result := RootFolder('ROOT_APP_FILES', ''); // root dell'exe
end;

function TzSystem.SettingExists(const Name: string; const TrueIfAdmin: boolean = true): boolean;
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_UTENTI_SETTINGS_EXISTS);
  try
    sp.Prepare;
    sp.ParamByName('USER_ID').Clear; // usa CURRENT_USER_ID
    sp.ParamByName('SETTING').AsString := Name;
    sp.ExecProc;
    result := sp.ParamByName('SETTING_EXISTS').AsBoolean;
  finally
    FreeAndNil(sp);
  end;

  if not result then
    if TrueIfAdmin then
      result := IsAdmin;
end;

procedure TzSystem.zPropertyInspectorGetEditorClass(Sender: TObject; AInstance: TPersistent; APropInfo: PPropInfo; var AEditorClass: TzPropEditorClass);
var
  LTypeInfo: PTypeInfo;
begin
  LTypeInfo := APropInfo.PropType^;
  if LTypeInfo.Kind = tkClass then
  begin
    if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzDomain) then
      AEditorClass := TzFieldPropsPropertyEditor
    else
      if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzLookup) then
        AEditorClass := TzLookupPropertyEditor
      else
        if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzDataSet) then
          AEditorClass := TzDataSetPropertyEditor
        else
          if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzDbViewProps) then
            AEditorClass := TzDbViewPropPropertyEditor
          else
            if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzGenerator) then
              AEditorClass := TzGeneratorsPropertyEditor
            else
              if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzDbCardProps) then
                AEditorClass := TzDbCardsPropertyEditor
              else
                if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzDbViewProps) then
                  AEditorClass := TzDbViewsPropertyEditor
                else
                  if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzPickList) then
                    AEditorClass := TzPickListPropertyEditor
                  else
                    if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzPickValues) then
                      AEditorClass := TzPickValuesPropertyEditor
                    else
                      if GetTypeData(LTypeInfo).ClassType.InheritsFrom(TzCustomCollection) then
                        AEditorClass := TzCustomCollectionPropertyEditor;
  end;
end;

constructor TzQueryParam.Create(Collection: TCollection);
begin
  inherited;
  FValue := Null;
end;

procedure TzQueryParam.Assign(Source: TPersistent);
begin
  if Source is TzQueryParam then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzQueryParam(Source).Name;
      Value := TzQueryParam(Source).Value;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzQueryParam.SetValue(const Value: Variant);
begin
  FValue := Value;
end;

procedure TzQueryParams.SetDataSetParams(DataSet: TzFbDataSet);
var
  i: integer;
  Idx: integer;
begin
  if not assigned(DataSet) then
    Exit;

  for i := 0 to DataSet.ParamCount - 1 do
  begin

    Idx := IndexOf(DataSet.Params[i].Name);

    if Idx = -1 then
      Continue
    else
    begin
      if IsNull(Items[Idx].Value) then
        DataSet.Params[i].Clear
      else
        DataSet.Params[i].Value := Items[Idx].Value;
    end;
  end;
end;

constructor TzPickValue.Create(Collection: TCollection);
begin
  inherited;
  FImageIndex := -1;
  FIndent := -1;
  FValue := '';
end;

procedure TzPickValue.Assign(Source: TPersistent);
begin
  if Source is TzPickValue then
  begin
    Name := TzPickValue(Source).Name;
    FImageIndex := TzPickValue(Source).ImageIndex;
    FIndent := TzPickValue(Source).Indent;
    FValue := TzPickValue(Source).Value;
  end
  else
    inherited Assign(Source);
end;

constructor TzPickList.Create(Collection: TCollection);
begin
  inherited;
  FDescription := TStringList.Create;
  FPickValues := TzPickValues.Create(TzPickValue, 'PickValues', -1, self);
  FPickValues.Sorted := False;
end;

destructor TzPickList.Destroy;
begin
  FreeAndNil(FDescription);
  FreeAndNil(FPickValues);
  inherited;
end;

procedure TzPickList.Assign(Source: TPersistent);
begin
  if Source is TzPickList then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzPickList(Source).Name;
      Description.Assign(TzPickList(Source).Description);
      PickValues.Assign(TzPickList(Source).PickValues);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzPickList.AssignDescriptonToItems;
var
  i: integer;
  zPickValue: TzPickValue;
begin
  PickValues.Clear;

  for i := 0 to Description.count - 1 do
    if trim(Description[i]) <> '' then
    begin
      zPickValue := PickValues.Add;
      zPickValue.Name := trim(Description.Names[i]);
      zPickValue.Value := trim(Description.ValueFromIndex[i]);
    end;
end;

// Vero se le voci sono esattamente quelle che AssignDescriptonToItems ricaverebbe
// da Source: stesse descrizioni, stessi codici, stesso ordine. Vuol dire che la
// lista non è stata personalizzata a mano. Immagini e rientri non contano,
// perché nel commento del dominio non ci sono.
function TzPickList.ItemsMatchDescription(Source: TStrings): Boolean;
var
  i: integer;
  ItemIndex: integer;
begin
  Result := False;
  ItemIndex := 0;

  for i := 0 to Source.Count - 1 do
    if trim(Source[i]) <> '' then
    begin
      if ItemIndex >= PickValues.Count then
        Exit;

      if (PickValues[ItemIndex].Name <> trim(Source.Names[i])) or (PickValues[ItemIndex].Value <> trim(Source.ValueFromIndex[i])) then
        Exit;

      inc(ItemIndex);
    end;

  Result := ItemIndex = PickValues.Count;
end;

// Aggiorna la descrizione con il commento del dominio e rigenera le voci, ma solo
// se erano ancora quelle generate dalla descrizione precedente: una lista
// personalizzata a mano (etichette accorciate o corrette, voci tolte o aggiunte,
// ordine diverso) resta com'è. Nel rigenerare, immagini e rientri passano alle
// nuove voci per codice, così una descrizione rinominata non perde l'icona.
// Una lista nuova ha descrizione e voci vuote, quindi viene generata per intero.
// Restituisce False quando la descrizione è cambiata ma le voci, personalizzate,
// non sono state toccate e possono non corrispondere più al commento.
function TzPickList.UpdateDescription(Source: TStrings): Boolean;
var
  ItemsGenerated: Boolean;
  PreviousItems: TzPickValues;
  Item: TzPickValue;
  PreviousItem: TzPickValue;
begin
  Result := True;

  if Description.Text = Source.Text then
    Exit;

  ItemsGenerated := ItemsMatchDescription(Description);
  Description.Text := Source.Text;

  if not ItemsGenerated then
  begin
    Result := False;
    Exit;
  end;

  PreviousItems := TzPickValues.Create(TzPickValue, 'PickValues', -1, nil);
  try
    PreviousItems.Sorted := False;
    PreviousItems.Assign(PickValues);

    AssignDescriptonToItems;

    for Item in PickValues do
      if Item.Value <> '' then
        for PreviousItem in PreviousItems do
          if PreviousItem.Value = Item.Value then
          begin
            Item.ImageIndex := PreviousItem.ImageIndex;
            Item.Indent := PreviousItem.Indent;
            Break;
          end;
  finally
    FreeAndNil(PreviousItems);
  end;
end;

procedure TzPickList.AssignToProps(Props: TcxImageComboBoxProperties);
var
  PickValue: TzPickValue;
  Item: TcxImageComboBoxItem;
begin
  Assert(assigned(Props));

  Props.Items.Clear;

  for PickValue in PickValues do
  begin
    Item := Props.Items.Add;
    Item.Description := PickValue.Name;
    Item.Value := PickValue.Value;
    Item.ImageIndex := PickValue.ImageIndex;
  end;
end;

procedure TzPickList.AssignToStrings(strings: TStrings);
var
  PickValue: TzPickValue;
begin
  Assert(assigned(strings));

  strings.Clear;

  for PickValue in PickValues do
    strings.addPair(PickValue.Name, PickValue.Value);
end;

function TzPickList.AsText: string;
var
  Value: TzPickValue;
begin
  result := '';

  for Value in PickValues do
    result := result + Value.Value + #13;
end;

procedure TzPickList.SetPickValues(const Value: TzPickValues);
begin
  FPickValues := Value;
end;

constructor TzForm.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FHelpKeyword := '';
  FReportGroup := '';
  FDataModule := '';
end;

procedure TzForm.Assign(Source: TPersistent);
begin
  if Source is TzForm then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzForm(Source).Name;
      Caption := TzForm(Source).Caption;
      DataModule := TzForm(Source).DataModule;
      HelpKeyword := TzForm(Source).HelpKeyword;
      ReportGroup := TzForm(Source).ReportGroup;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

constructor TzAction.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FHint := '';
  FHelpContext := 0;
  FHelpKeyword := '';
  FHelpType := htKeyword;
  FImageIndex := -1;
  FImageName := '';
end;

procedure TzAction.Assign(Source: TPersistent);
var
  Item: TzAction;
begin
  if Source is TzAction then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzAction(Source);
      Name := Item.Name;
      Caption := Item.Caption;
      Hint := Item.Hint;
      HelpContext := Item.HelpContext;
      HelpKeyword := Item.HelpKeyword;
      HelpType := Item.HelpType;
      ImageIndex := Item.ImageIndex;
      ImageName := Item.ImageName;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

constructor TzConnection.Create(Collection: TCollection);
begin
  inherited;
  FdbUser := 'SYSDBA';
  FDataBase := '';
  FServerName := '';
  FdbPassword := 'masterkey';
  FProtocol := zpTCP_IP;
  FSqlRole := '';
  FCharacterSet := 'UTF8';
  FClientLibrary := 'fbclient.dll';
  FParams := TStringList.Create;
end;

destructor TzConnection.Destroy;
begin
  FreeAndNil(FParams);
  inherited;
end;

procedure TzConnection.Assign(Source: TPersistent);
begin
  if Source is TzConnection then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzConnection(Source).Name;
      ServerName := TzConnection(Source).ServerName;
      DataBase := TzConnection(Source).DataBase;
      dbUser := TzConnection(Source).dbUser;
      dbPassword := TzConnection(Source).dbPassword;
      Protocol := TzConnection(Source).Protocol;
      SqlRole := TzConnection(Source).SqlRole;
      CharacterSet := TzConnection(Source).CharacterSet;
      Params.Text := TzConnection(Source).Params.Text;
      ClientLibrary := TzConnection(Source).ClientLibrary;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzConnection.GetdbPassword: string;
begin
  { TODO : Criptare }
  result := FdbPassword;
end;

procedure TzConnection.InitDataBase(db: TzFbDatabase; FDPhysFBDriverLink: TFDPhysFBDriverLink; UserName, Password: string);
var
  MonitorBy: TFDMonitorBy;
  ParametriRegistro: TStringList;
  i: integer;
begin
  if not assigned(db) then
    Exit;

  MonitorBy := db.Params.MonitorBy;

  db.Connected := False;

  db.Params.Clear;
  db.Params.AddStrings(Params);
  db.Params.Add('DriverID=FB');
  db.Params.Add('Server=' + ServerName);
  // Fino al 2026-09-25 Protocol era salvato ma mai passato a FireDAC, che
  // quindi usava sempre TCP/IP.
  db.Params.Add('Protocol=' + zProtocolFireDAC[Protocol]);
  db.Params.Add('Database=' + DataBase);
  db.Params.Add('User_Name=' + UserName);
  db.Params.Add('Password=' + Password);
  // Fino al 2026-10-18 SqlRole era salvato e modificabile nella form di
  // sicurezza ma mai passato a FireDAC: la connessione entrava senza ruolo.
  // Vuoto = nessun ruolo, come prima.
  if SqlRole.Trim <> '' then
    db.Params.Add('RoleName=' + SqlRole.Trim);
  db.Params.Add('CharacterSet=' + CharacterSet);
  db.Params.Add('Pooled=False');
  db.Params.Add('ExtendedMetadata=True');

  db.Params.MonitorBy := MonitorBy;

  // Nel registro va una copia dei parametri con le password coperte: il
  // registro della registrazione per l'assistenza viene allegato a un ticket
  // Mantis, e prima ci finiva in chiaro la password del database. Si coprono
  // tutte le voci il cui nome contiene "password", anche quelle arrivate da
  // Params, non solo la Password aggiunta qui sopra.
  ParametriRegistro := TStringList.Create;
  try
    ParametriRegistro.Assign(db.Params);
    for i := 0 to ParametriRegistro.Count - 1 do
      if ParametriRegistro.Names[i].ToLower.Contains('password') then
        ParametriRegistro.ValueFromIndex[i] := '***';
    sizSystem.LogStringList('dbParams', ParametriRegistro);
  finally
    FreeAndNil(ParametriRegistro);
  end;
  // Server e database anche come voci a se': il registro di testo conserva
  // solo il titolo delle voci, e il contenuto di dbParams li' non compare.
  sizSystem.LogString('dbServer', ServerName);
  sizSystem.LogString('dbDatabase', DataBase);

  FDPhysFBDriverLink.VendorLib := ClientLibrary;
end;

procedure TzConnection.SetCharacterSet(const Value: string);
begin
  FCharacterSet := Value;
end;

procedure TzConnection.SetClientLibrary(const Value: string);
begin
  FClientLibrary := Value;
end;

procedure TzConnection.SetDataBase(const Value: string);
begin
  FDataBase := Value;
end;

procedure TzConnection.SetdbPassword(const Value: string);
begin
  { TODO : Criptare }
  FdbPassword := Value;
end;

procedure TzConnection.SetdbUser(const Value: string);
begin
  FdbUser := Value;
end;

procedure TzConnection.SetParams(const Value: TStringList);
begin
  FParams.Assign(Value);
end;

procedure TzConnection.SetProtocol(const Value: TzProtocol);
begin
  FProtocol := Value;
end;

procedure TzConnection.SetServerName(const Value: string);
begin
  FServerName := Value;
end;

procedure TzConnection.SetSqlRole(const Value: string);
begin
  FSqlRole := Value;
end;

// procedure TzActions.InitRights(AComponent: TComponent);
// var
// Idx: integer;
// aName: string;
// i: integer;
// begin
// if not assigned(AComponent) then
// Exit;
//
// if AComponent is TCustomAction then
// begin
// aName := FullComponentName(AComponent);
// Idx := IndexOf(aName);
// if Idx <> -1 then
// begin
// (AComponent as TCustomAction).Enabled := False;
// (AComponent as TCustomAction).Visible := False;
// end;
//
// end;
//
// for i := 0 to AComponent.ComponentCount - 1 do
// InitRights(AComponent.Components[i]);
// end;

procedure TzActions.InitActionList(ActionList: TActionList);
var
  i: integer;
  zAction: TzAction;
  containedAction: TContainedAction;
begin

  for i := 0 to ActionList.ActionCount - 1 do
  begin
    containedAction := ActionList.Actions[i];
    zAction := get(containedAction.Name, False);

    if assigned(zAction) then
    begin
      containedAction.Caption := zAction.Caption;
      containedAction.Hint := zAction.Hint;
      containedAction.HelpContext := zAction.HelpContext;
      containedAction.HelpKeyword := zAction.HelpKeyword;
      containedAction.HelpType := zAction.HelpType;
      containedAction.ImageIndex := zAction.ImageIndex;

      if containedAction is TCustomAction then
        TCustomAction(containedAction).ImageName := zAction.ImageName;
    end;
  end;
end;

procedure TzActions.LoadFromActionList(ActionList: TActionList);
var
  i: integer;
  zAction: TzAction;
  containedAction: TContainedAction;
begin

  for i := 0 to ActionList.ActionCount - 1 do
  begin
    containedAction := ActionList.Actions[i];
    zAction := get(containedAction.Name, true);
    zAction.Name := containedAction.Name;
    zAction.Caption := containedAction.Caption;
    zAction.Hint := containedAction.Hint;
    zAction.HelpContext := containedAction.HelpContext;
    zAction.HelpKeyword := containedAction.HelpKeyword;
    zAction.HelpType := containedAction.HelpType;
    zAction.ImageIndex := containedAction.ImageIndex;

    if containedAction is TCustomAction then
      zAction.ImageName := TCustomAction(containedAction).ImageName
    else
      zAction.ImageName := '';
  end;
end;

constructor TzSecurity.Create(aSystem: TzSystem);
begin
  inherited Create;

  zSystem := aSystem;
  FFileName := '';
  FLoginParams := TLoginParams.Create(self);

  // FEurekaProps := TzEurekaProps.Create;
  FzConnections := TzConnections.Create(TzConnection, 'Connections', img_SecurityConnections, nil);
  FzConnections.OnLoadErrorCallback := ConnectionsLoadError;
  FExecuteLoginSP := true;
end;

destructor TzSecurity.Destroy;
begin
  // FreeAndNil(FEurekaProps);
  FreeAndNil(FLoginParams);
  FreeAndNil(FzConnections);

  if FLocked then
  begin
    application.UnhookMainWindow(UnlockHook);
    FLocked := False;
  end;

  inherited;
end;

procedure TzSecurity.Assign(Source: TPersistent);
begin
  if Source is TzSecurity then
  begin
    FileName := TzSecurity(Source).FileName;
    zConnections.Assign(TzSecurity(Source).zConnections);
    AfterLogin := TzSecurity(Source).AfterLogin;
    BeforeLogin := TzSecurity(Source).BeforeLogin;
  end
  else
    inherited Assign(Source);
end;

function TzSecurity.ChangePassword: boolean;
var
  Idx: integer;
  OldPassword: string;
  NewPassword: string;
  PasswordChangedFunc: TPasswordChangedFunc;
begin
  result := False;

  if not LoggedIn then
    Exit;

  NewPassword := '';
  OldPassword := LoginParams.UserPassword;

  if OldPassword = '' then // Metodo verifica = dominio/nessuno
  begin
    result := true;
    Exit;
  end;

  PasswordChangedFunc := function(OldPassword, NewPassword: string): boolean
    begin
      result := doChangePassword(OldPassword, NewPassword);
    end;

  result := zSecurityPasswordChange(OldPassword, PasswordChangedFunc);
end;

procedure TzSecurity.DoAfterLogin;
begin
  if assigned(FAfterLogin) then
    FAfterLogin(self);
end;

procedure TzSecurity.DoBeforeLogin;
begin
  if assigned(FBeforeLogin) then
    FBeforeLogin(self);
end;

function TzSecurity.doChangePassword(const OldPassword, NewPassword: string): boolean;
var
  sp: TFDStoredProc;
begin
  result := False;

  sp := CreateStoredProc(spUSR_CAMBIA_PASSWORD);
  try
    sp.Prepare;
    sp.ParamByName('USER_ID').Value := LoginParams.UserID;
    sp.ParamByName('OLD_PASSWORD').Value := OldPassword;
    sp.ParamByName('NEW_PASSWORD').Value := NewPassword;

    sp.ExecProc;
    result := true;
  finally
    FreeAndNil(sp);
  end;

  if result then
    LoginParams.PasswordChanged(NewPassword);
end;

function TzSecurity.doLogin(const ConnectionName, UserName, Password: string): boolean;

  procedure ExecuteStoredProcLogin(dbUsername: string; dbPassword: string);
  var
    IsAdmin: boolean;
    PasswordExpireDate: TDateTime;
    SessionID: integer;
    sp: TFDStoredProc;
    UserDisplayName: String;
    UserID: integer;
    SecondiAllaVerificaAccesso: integer;
  begin
    sizSystem.LogVerbose('Login USR_LOGIN');

    SecondiAllaVerificaAccesso := 0;

    if ExecuteLoginSP then
    begin
      sp := CreateStoredProc(spUSR_LOGIN);
      try
        sp.FetchOptions.AutoClose := False;
        sp.Prepare;

        sp.ParamByName('APP').AsString := zSystem.AppName;
        sp.ParamByName('USER_NAME').AsString := dbUsername;
        sp.ParamByName('PASSWORD_').AsString := dbPassword;

        if sp.ParamExists('COMPUTER_NAME') then
          sp.ParamByName('COMPUTER_NAME').AsString := ComputerName;

        if sp.ParamExists('COMPUTER_USER_NAME') then
          sp.ParamByName('COMPUTER_USER_NAME').AsString := ComputerUserName;

        sp.Transaction.StartTransaction;
        try
          sp.ExecProc;

          SessionID := sp.ParamByName('ID_SESSIONE').Value;
          UserID := sp.ParamByName('USER_ID').Value;
          UserDisplayName := sp.ParamByName('NOMINATIVO').Value;
          PasswordExpireDate := sp.ParamByName('DATA_SCADENZA_PASSWORD').AsDate;
          IsAdmin := sp.ParamByName('ADMIN_USER').AsBoolean;

          if sp.ParamExists('OTP') then { TODO : Rimuovere dopo conversione db }
            OTP_Required := sp.ParamByName('OTP').AsBoolean;

          // Fasce orarie 2026-09-18: fra quanti secondi il verdetto
          // sull'accesso puo' cambiare. Il parametro non esiste in tutti i
          // database e dove manca il controllo resta spento, come gia'
          // accade per HOST_LDAP e COMPUTER_NAME.
          if sp.ParamExists('SECONDI_ALLA_PROSSIMA_VERIFICA') then
            SecondiAllaVerificaAccesso := sp.ParamByName('SECONDI_ALLA_PROSSIMA_VERIFICA').AsInteger;

          if sp.ParamExists('HOST_LDAP') then
            if not sp.ParamByName('HOST_LDAP').AsString.IsEmpty then
            // user e password sono quelli di login
            begin
              if Password.IsEmpty then
                raise zException.Create('Password non valida. (AD)');

              if not ActiveDirectoryAuthenticate(sp.ParamByName('HOST_LDAP').AsString, UserName, Password) then
                raise zException.Create('Utente/Password non validi. (AD)');
            end;

          sp.Transaction.Commit;
        except
          on e: Exception do
          begin
            if sp.Transaction.Active then
              sp.Transaction.Rollback;

            raise;
          end
        end;

      finally
        FreeAndNil(sp);
      end;

      // Secondo fattore 2026-10-16: la mail con il codice non parte piu' qui
      // ma in SecondoFattoreVerifica, solo per chi non usa l'app di
      // autenticazione o la chiede come riserva.
      sizSystem.LogSeparator;
      sizSystem.LogColored(clRed, 'ExecuteStoredProcLogin');
      sizSystem.LogInteger('UserID', UserID);
      sizSystem.LogBoolean('IsAdmin', IsAdmin);
    end
    else
    begin
      SessionID := 1;
      UserID := 1;
      UserDisplayName := UserName;
      PasswordExpireDate := EncodeDate(9999, 12, 31);
      IsAdmin := true;
    end;

    LoginParams.SetParams(ConnectionName, UserName, Password, SessionID, UserID, UserDisplayName, PasswordExpireDate, IsAdmin, False, False, False);
    LoginParams.SetVerificaAccesso(SecondiAllaVerificaAccesso);

    // Sessione valida dopo il secondo fattore 2026-10-17: con il secondo
    // fattore la sessione resta in attesa e il contesto del database non ha
    // ancora l'utente, quindi le funzioni USR_CAN_* risponderebbero per
    // l'utente sbagliato. In quel caso i permessi si leggono in Login, dopo
    // il codice.
    if ExecuteLoginSP and not OTP_Required then
      LeggiPermessiSistema;
  end;

var
  Connection: TzConnection;
  dbUser, dbPwd: string;
begin
  result := False;

  LoginParams.Clear;

  Connection := zConnections.get(ConnectionName, False);

  if not assigned(Connection) then
    raise zException.Create('Connessione non definita.');

  Connection.GetUserAndPassword(UserName, dbUser, dbPwd);

  Connection.InitDataBase(zSystem.zFbDatabase, zSystem.FDPhysFBDriverLink, dbUser, dbPwd);
  try
    LoginParams.FUserName := UserName; // serve nel DatabaseAfterConnect per shutdown & co

    zSystem.zFbDatabase.Connected := true;

    ExecuteStoredProcLogin(UserName, Password);

    SaveLastUserAndConnection(UserName, Connection.Name);

    result := true;
  except
    on e: Exception do
    begin
      zSystem.zFbDatabase.Connected := False;
      // ApplicationShowException(e);
      raise;
    end;
  end;
  /// ///////////////////////////////////////////////////////////////////
end;

procedure TzSecurity.LeggiPermessiSistema;
begin
  LoginParams.SetPermessiSistema(zSystem.zFbDatabase.ExecSQLScalar('SELECT USR_CAN_CREATE_SYSTEM_USER() FROM RDB$DATABASE'),
    zSystem.zFbDatabase.ExecSQLScalar('SELECT USR_CAN_EDIT_RESTRICTIONS() FROM RDB$DATABASE'),
    zSystem.zFbDatabase.ExecSQLScalar('SELECT USR_CAN_EDIT_HELP() FROM RDB$DATABASE'));
end;

function TzSecurity.DoUnlockDialog: boolean;
begin
  result := zSecurityDoUnlock(self);
end;

procedure TzSecurity.BackupZip;
var
  BackupFileName: string;
begin
  // Stessa cartella e stesso nome delle copie dei file LZ (TzSystem.BackupZip):
  // dal 2026-10-01 il salvataggio cifra il file e un eseguibile precedente
  // non lo rilegge piu', quindi la copia di prima serve a tornare indietro.
  if not TFile.Exists(FileName) then
    Exit;

  ForceDirectories(Path + 'BackupLZ');
  BackupFileName := Path + 'BackupLZ\' + FileNameNoExt(FileName) + ' - ' + NomeFileFromDate(Now) + ExtractFileExt(FileName);
  siMain.LogString('Backup Sec', BackupFileName);

  if not TFile.Exists(BackupFileName) then
    TFile.Copy(FileName, BackupFileName);
end;

procedure TzSecurity.ConnectionsLoadError(Sender: TObject; const ErrorMessage: string; var Handled: boolean; var IgnoreAll: boolean);
begin
  // 2026-09-25: TzConnection non ha piu' le proprieta' ActiveDirectory (con
  // le sue sottoproprieta') e Db_Path_UNC. Un file .Sec scritto prima puo'
  // contenerle ancora: il TReader le segnala come sconosciute e qui vengono
  // saltate in silenzio, cosi' il caricamento prosegue con le connessioni
  // successive. Il primo SaveZip riscrive il membro Connections senza di
  // esse. Ogni altro errore resta non gestito e arriva a
  // TZipper.LoadCollection, che lo mostra come sempre.
  IgnoreAll := False;
  Handled := (Pos('ActiveDirectory', ErrorMessage) > 0) or (Pos('Db_Path_UNC', ErrorMessage) > 0);

  if Handled then
    sizSystem.LogWarning('File .Sec: proprieta'' non piu'' esistente ignorata (' + ErrorMessage + ')');
end;

function TzSecurity.GetFileName: string;
begin
  if trim(FFileName) = '' then
    result := ChangeFileExt(application.exename, zExtension_Security)
  else
    result := FFileName;
end;

function TzSecurity.GetIsAdmin: boolean;
begin
  result := LoginParams.UserIsAdmin;
end;

procedure TzSecurity.LoadAuthorizations;
var
  DataSet: TzFbDataSet;
begin
  LoginParams.Authorizations.Clear;

  DataSet := CreateFbDataSet(nil, zSystem.zFbDatabase, zSystem.zFbTransaction, zSystem.zFbTransaction, true);
  try
    DataSet.FetchOptions.UniDirectional := true;
    DataSet.SelectSQL.Text := 'SELECT * FROM USR_UTENTI_AUTHORIZATIONS_GET';
    DataSet.Active := true;

    while not DataSet.Eof do
    begin
      LoginParams.Authorizations.Add(DataSet.FieldByName('AUTHORIZATION').AsString);
      DataSet.Next;
    end;

  finally
    FreeAndNil(DataSet);
  end;
end;

procedure TzSecurity.LoadAutoruns;
var
  DataSet: TzFbDataSet;
begin
  LoginParams.AutorunActions.Clear;

  DataSet := CreateFbDataSet(nil, zSystem.zFbDatabase, zSystem.zFbTransaction, zSystem.zFbTransaction, true);
  try
    DataSet.FetchOptions.UniDirectional := true;
    DataSet.SelectSQL.Text := 'SELECT * FROM USR_UTENTI_AUTORUN_GET';
    DataSet.Active := true;

    while not DataSet.Eof do
    begin
      // verr� cercato come uppercase
      LoginParams.FAutorunActions.Add(DataSet.FieldByName('ACTION_CAPTION').AsString.ToUpper);
      DataSet.Next;
    end;
  finally
    FreeAndNil(DataSet);
  end;
end;

procedure TzSecurity.LoadHyperLinks;
var
  DataSet: TzFbDataSet;
begin
  LoginParams.Hyperlinks.Clear;

  DataSet := CreateFbDataSet(nil, zSystem.zFbDatabase, zSystem.zFbTransaction, zSystem.zFbTransaction, true);
  try
    DataSet.FetchOptions.UniDirectional := true;
    DataSet.SelectSQL.Text := 'SELECT * FROM USR_GET_USER_HYPERLINKS';
    DataSet.Active := true;

    while not DataSet.Eof do
    begin
      LoginParams.FHyperlinks.Add(DataSet.FieldByName('HYPERLINK').AsString.ToUpper);
      DataSet.Next;
    end;
  finally
    FreeAndNil(DataSet);
  end;
end;

procedure TzSecurity.LoadZip;
  procedure ClearCollections;
  begin
    zConnections.Clear;
  end;

  procedure LoadEureka(Zipper: TZipper);
  var
    Stream: TMemoryStream;
    Name: string;
  begin
    // Name := EurekaProps.ClassName;
    //
    // if Zipper.AbZipKit.FindFile(Name) = -1 then
    // Exit;
    //
    // Stream := TMemoryStream.Create;
    // try
    // Zipper.AbZipKit.ExtractToStream(Name, Stream);
    //
    // if Stream.Size = 0 then
    // Exit;
    //
    // Stream.Position := 0;
    // try
    // EurekaProps.LoadFromStream(Stream);
    // except
    // on e: exception do
    // ApplicationShowException(e);
    // end;
    // finally
    // Stream.Free;
    // end;
  end;

var
  Zipper: TZipper;
begin

  if FileExists(FileName) then
  begin
    Zipper := TZipper.Create;
    try
      // La password serve solo per i membri cifrati: un file scritto prima
      // della cifratura si apre lo stesso, e viene cifrato al primo SaveZip.
      Zipper.Password := zSecurityZipPassword;
      Zipper.ZipFileName := FileName;

      ClearCollections;

      Zipper.LoadCollection(zConnections);
    finally
      FreeAndNil(Zipper);
    end;
  end;
end;

procedure TzSecurity.Lock;
begin
  FSaveOnRestore := application.OnRestore;
  application.Minimize;
  application.HookMainWindow(UnlockHook);
  FLocked := true;
end;

function TzSecurity.LoggedIn: boolean;
begin
  result := LoginParams.LoggedIn;
end;

function TzSecurity.Login(const AllowParams: boolean): boolean;
var
  UserName: string;
  Password: string;
  Connection: string;
  Idx: integer;
  CheckUserFunc: TCheckUserFunc;
begin
  // 2026-11-01 (DIV-ACC-9): prima il risultato non veniva mai assegnato.
  result := False;
  UserName := '';
  Connection := '';
  LoadZip;

  LoginParams.Clear;
  DoBeforeLogin;

  OTP_Required := False;
  OTP_Ok := true;
  FTotpDisponibile := 0;

  // parametri da riga di comando: Terminal Server
  if AllowParams then
  begin
    // tenta la connessione con parametri da riga di comando
    UserName := zSystem.Params.Values['User'];
    Connection := zSystem.Params.Values['Db'];
    Password := zSystem.Params.Values['Password'];

    // 2026-11-01 (DIV-ACC-6): con parametri sbagliati l'eccezione di doLogin
    // usciva da Login e bloccava l'avvio; ora finisce nel registro e si
    // ripiega sulla finestra di accesso, come dice ZBASE-ACC-004.
    if (UserName <> '') and (Connection <> '') then
      try
        doLogin(Connection, UserName, Password);
      except
        on e: Exception do
        begin
          siMain.LogWarning('Accesso con i parametri della riga di comando non riuscito: si apre la finestra di accesso');
          siMain.LogException(e);
        end;
      end;
  end;

  if not LoggedIn then // se non loggato tramite parametri
  begin

    CheckUserFunc := function(Connection, UserName, Password: string): boolean
      begin
        result := doLogin(Connection, UserName, Password);
      end;

    LoadLastUserAndConnection(UserName, Connection);
    //
    // repeat
    if not zSecurityDoLogin(self, UserName, Connection, CheckUserFunc) then
    begin
      TerminateApplication;
      Exit;
    end;
    // until zSystem.zFbDatabase.Connected or application.Terminated;
    //
  end;

  /// /

  // 2026-11-01 (DIV-ACC-5, DIV-TOT-1): TerminateApplication chiede la
  // chiusura ma non interrompe questo metodo. Prima, dopo un secondo fattore
  // fallito, LoggedIn restava vero e si caricavano autorizzazioni e azioni
  // automatiche, scattava AfterLogin e TzSystem.Login eseguiva la richiamata
  // dell'applicazione, per un utente non verificato. Ora a ogni rifiuto
  // l'accesso si annulla (LoginParams.Clear) e si esce subito.

  // Il codice giusto rende valida la sessione nel database: solo da li' il
  // contesto ha l'utente e i permessi si possono leggere
  if OTP_Required then
    if SecondoFattoreVerifica then
      LeggiPermessiSistema
    else
    begin
      LoginParams.Clear;
      TerminateApplication;
      Exit;
    end;

  /// //
  if LoggedIn then
  begin
    LoadAuthorizations;
    LoadAutoruns;
    LoadHyperLinks;
    DoAfterLogin;
  end
  else
  begin
    TerminateApplication;
    Exit;
  end;

  if LoginParams.PasswordExpired then
    if not ChangePassword then
    begin
      LoginParams.Clear;
      TerminateApplication;
      Exit;
    end;

  result := LoggedIn;
end;

procedure TzSecurity.SaveLastUserAndConnection(const UserName, Connection: string);
begin
  // Mantis #286 - 2026-10-26: prima il try/except proteggeva UpdateFile, che
  // non solleva mai, e lasciava scoperto WriteString: un .login non scrivibile
  // annullava un accesso gia' riuscito. Ora l'errore finisce solo nel registro
  if ScriviFileLogin('UserName', UserName) then
    ScriviFileLogin('Connection', Connection);
end;

class function TzSecurity.ScriviFileLogin(const Chiave, Valore: string): boolean;
var
  NomeFile: string;
  Ini: TIniFile;
begin
  result := False;
  NomeFile := ChangeFileExt(application.exename, zExtension_LastUserAndConnections);
  try
    Ini := TIniFile.Create(NomeFile);
    try
      Ini.WriteString(ComputerName, Chiave, Valore);
      result := true;
    finally
      FreeAndNil(Ini);
    end;
  except
    on e: Exception do
    begin
      siMain.LogWarning('File .login non scrivibile (' + NomeFile + '), voce ' + Chiave + ' non salvata');
      siMain.LogException(e);
    end;
  end;
end;

class procedure TzSecurity.LoadSkinFromIni;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ChangeFileExt(application.exename, zExtension_LastUserAndConnections));
  try
    dx.SkinName := Ini.ReadString(ComputerName, 'Skin', '');
    dx.SkinPaletteName := Ini.ReadString(ComputerName, 'SkinPalette', '');
  finally
    FreeAndNil(Ini);
  end;
end;

procedure TzSecurity.LoadLastUserAndConnection(out UserName, Connection: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ChangeFileExt(application.exename, zExtension_LastUserAndConnections));
  try
    UserName := Ini.ReadString(ComputerName, 'UserName', '');
    Connection := Ini.ReadString(ComputerName, 'Connection', '');
  finally
    FreeAndNil(Ini);
  end;

  // Lo skin serve alla finestra di accesso. Se la schermata di avvio l'ha gia'
  // caricato, questa e' una riapplicazione senza effetti.
  LoadSkinFromIni;
end;

procedure TzSecurity.SaveZip;

  procedure SaveEureka(Zipper: TZipper);
  var
    Stream: TMemoryStream;
    Name: string;
  begin
    // Name := EurekaProps.ClassName;
    //
    // Zipper.AbZipKit.DeleteFiles(Name);
    // Stream := TMemoryStream.Create;
    // try
    // EurekaProps.SaveToStream(Stream);
    // Zipper.AbZipKit.AddFromStream(Name, Stream);
    // finally
    // FreeAndNil(Stream);
    // end;
  end;

var
  Zipper: TZipper;
begin
  BackupZip;

  Zipper := TZipper.Create;
  try
    Zipper.Password := zSecurityZipPassword;
    Zipper.ZipFileName := FileName;
    Zipper.SaveCollection(zConnections);

    // 2026-09-25: il membro TzFtpSettings non viene piu' letto ne' scritto.
    // Se un file vecchio lo contiene ancora (con o senza estensione, DFM o
    // JSON), sparisce al primo salvataggio.
    Zipper.RemoveStream('TzFtpSettings', pfDFM);
    Zipper.RemoveStream('TzFtpSettings', pfJSON);
    Zipper.DeleteMember('TzFtpSettings');
  finally
    FreeAndNil(Zipper);
  end;
end;

procedure TzSecurity.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

procedure TzSecurity.SetIsAdmin(const Value: boolean);
begin
  LoginParams.UserIsAdmin := Value;
end;

procedure TzSecurity.SeTzConnections(const Value: TzConnections);
begin
  // Copia il contenuto invece di sostituire il puntatore: la collezione
  // e' di proprieta' di TzSecurity e viene liberata nel distruttore.
  FzConnections.Assign(Value);
end;

procedure TzSecurity.ShowSecurityForm;
begin
  if zSecurityFrm.ShowSecurityForm(self) then
    SaveZip
  else
    LoadZip;
end;

procedure TzSecurity.TerminateApplication;
begin
  with application do
  begin
    ShowMainForm := False;
    if Handle <> 0 then
      ShowOwnedPopups(Handle, False);
    Terminate;
  end;
  CallTerminateProcs;
end;

function TzSecurity.UnlockHook(var Message: TMessage): boolean;

  function DoUnlock: boolean;
  var
    Popup: HWnd;
  begin
    with application do
      if IsWindowVisible(Handle) and IsWindowEnabled(Handle) then
        SetForegroundWindow(Handle);
    if FUnlockDlgShowing then
    begin
      Popup := GetLastActivePopup(application.Handle);
      if (Popup <> 0) and IsWindowVisible(Popup) and (WindowClassName(Popup) = TzSecurityLoginForm.ClassName) then
      begin
        SetForegroundWindow(Popup);
      end;
      result := False;
      Exit;
    end;
    FUnlockDlgShowing := true;
    try
      result := DoUnlockDialog;
    finally
      FUnlockDlgShowing := False;
    end;
    if result then
    begin
      application.UnhookMainWindow(UnlockHook);
      FLocked := False;
    end;
  end;

begin
  result := False;
  if not FLocked then
    Exit;
  with Message do
  begin
    case msg of
      WM_QUERYOPEN:
        begin
          UnlockHook := not DoUnlock;
        end;
      WM_SHOWWINDOW:
        if Bool(WParam) then
        begin
          UnlockHook := not DoUnlock;
        end;
      WM_SYSCOMMAND:
        if (WParam and $FFF0 = SC_RESTORE) or (WParam and $FFF0 = SC_ZOOM) then
        begin
          UnlockHook := not DoUnlock;
        end;
    end;
  end;
end;

constructor TzStoredProc.Create(Collection: TCollection);
begin
  inherited;
  FSQL := TStringList.Create;
end;

destructor TzStoredProc.Destroy;
begin
  FreeAndNil(FSQL);
  inherited;
end;

procedure TzStoredProc.Assign(Source: TPersistent);
begin
  if Source is TzStoredProc then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzStoredProc(Source).Name;
      StoredProc := TzStoredProc(Source).StoredProc;
      SQL.Assign(TzStoredProc(Source).SQL);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzStoredProc.SetSQL(const Value: TStringList);
begin
  FSQL.Assign(Value);
end;

procedure TzStoredProc.SetStoredProc(const Value: string);
begin
  FStoredProc := Value;
end;

constructor TzWizardPage.Create(Collection: TCollection);
begin
  inherited;
  FSubtitle := TStringList.Create;
end;

destructor TzWizardPage.Destroy;
begin
  FreeAndNil(FSubtitle);
  inherited;
end;

procedure TzWizardPage.Assign(Source: TPersistent);
begin
  if Source is TzWizardPage then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzWizardPage(Source).Name;
      Header := TzWizardPage(Source).Header;
      Subtitle.Assign(TzWizardPage(Source).Subtitle);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzWizardPage.SetHeader(const Value: string);
begin
  FHeader := Value;
end;

procedure TzWizardPage.SetSubtitle(const Value: TStringList);
begin
  FSubtitle.Assign(Value);
end;

constructor TzWizard.Create(Collection: TCollection);
begin
  inherited;
  FPages := TzWizardPages.Create(TzWizardPage, 'Pages', -1, self);
end;

destructor TzWizard.Destroy;
begin
  FreeAndNil(FPages);
  inherited;
end;

procedure TzWizard.Assign(Source: TPersistent);
begin
  if Source is TzWizard then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzWizard(Source).Name;
      Pages.Assign(TzWizard(Source).Pages);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzWizard.SetPages(const Value: TzWizardPages);
begin
  FPages.Assign(Value);
end;

constructor TzButtonProps.Create;
begin
  inherited;
  FCaption := '';
  FHint := '';
  FImageIndex := -1;
  FDisplayCaptionInToolbar := False;
  FVisible := true;
end;

{ TzTBCustomItemProps }

procedure TzButtonProps.Apply(Action: TContainedAction; btn: TdxBarButton);
begin
  if DisplayCaptionInToolbar then
    btn.PaintStyle := psCaptionGlyph
  else
    btn.PaintStyle := psStandard;

  if Caption <> '' then
    Action.Caption := Caption;

  if Hint <> '' then
    Action.Hint := Hint;

  if ImageIndex <> -1 then
    Action.ImageIndex := ImageIndex;
end;

procedure TzButtonProps.Assign(Source: TPersistent);
begin
  if Source is TzButtonProps then
  begin
    Caption := TzButtonProps(Source).Caption;
    Hint := TzButtonProps(Source).Hint;
    ImageIndex := TzButtonProps(Source).ImageIndex;
    Visible := TzButtonProps(Source).Visible;
    DisplayCaptionInToolbar := TzButtonProps(Source).DisplayCaptionInToolbar;
  end
  else
    inherited Assign(Source);
end;

function TzButtonProps.isCaptionStored: boolean;
begin
  result := Caption <> '';
end;

function TzButtonProps.IsHintStored: boolean;
begin
  result := Hint <> '';
end;

function TzButtonProps.IsStored: boolean;
begin
  result := isCaptionStored or IsHintStored or DisplayCaptionInToolbar or (ImageIndex <> -1) or (not Visible);
end;

procedure TzButtonProps.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TzButtonProps.SetDisplayCaptionInToolbar(const Value: boolean);
begin
  FDisplayCaptionInToolbar := Value;
end;

procedure TzButtonProps.SetHint(const Value: string);
begin
  FHint := Value;
end;

procedure TzButtonProps.SetImageIndex(const Value: integer);
begin
  FImageIndex := Value;
end;

procedure TzButtonProps.SetVisible(const Value: boolean);
begin
  FVisible := Value;
end;

constructor TzScheme.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FScheme := TStringList.Create;
  FChart := TStringList.Create;
end;

destructor TzScheme.Destroy;
begin
  FreeAndNil(FScheme);
  FreeAndNil(FChart);
  inherited;
end;

procedure TzScheme.Assign(Source: TPersistent);
begin
  if Source is TzScheme then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzScheme(Source).Name;
      Scheme.Text := TzScheme(Source).Scheme.Text;
      Chart.Text := TzScheme(Source).Chart.Text;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzScheme.SetChart(const Value: TStringList);
begin
  FChart := Value;
end;

procedure TzScheme.SetScheme(const Value: TStringList);
begin
  FScheme := Value;
end;

constructor TzCubeProps.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FAutoOpen := true;
  FFields := TStringList.Create;
  FSchemes := TzSchemes.Create(TzScheme, 'Schemes', -1, self);

end;

destructor TzCubeProps.Destroy;
begin
  FreeAndNil(FFields);
  FreeAndNil(FSchemes);
  inherited;
end;

procedure TzCubeProps.Assign(Source: TPersistent);
begin
  if Source is TzCubeProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzCubeProps(Source).Name;
      AutoOpen := TzCubeProps(Source).AutoOpen;
      Fields.Assign(TzCubeProps(Source).Fields);
      Schemes.Assign(TzCubeProps(Source).Schemes);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzCubeProps.SetAutoOpen(const Value: boolean);
begin
  FAutoOpen := Value;
end;

procedure TzCubeProps.SetFields(const Value: TStringList);
begin
  FFields.Assign(Value);
end;

procedure TzCubeProps.SetSchemes(const Value: TzSchemes);
begin
  FSchemes.Assign(Value);
end;

constructor TzTatukMap.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDetailLayer := '';
  FDetailField := 'GID';
  FMasterField := 'MAP_ID';
  FMiniMapLayer := '';
  FMultiRecord := False;

  FProject := TStringList.Create;
  FScopes := TStringList.Create;
end;

destructor TzTatukMap.Destroy;
begin
  FreeAndNil(FProject);
  FreeAndNil(FScopes);
  inherited;
end;

procedure TzTatukMap.Assign(Source: TPersistent);
var
  Item: TzTatukMap;
begin
  if Source is TzTatukMap then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := Source as TzTatukMap;
      Name := Item.Name;

      DetailLayer := Item.DetailLayer;
      DetailField := Item.DetailField;
      MasterField := Item.MasterField;
      MiniMapLayer := Item.MiniMapLayer;
      MultiRecord := Item.MultiRecord;
      Project.Assign(Item.Project);
      Scopes.Assign(Item.Scopes);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzTatukMap.SetProject(const Value: TStringList);
begin
  FProject.Assign(Value);
end;

procedure TzTatukMap.SetScopes(const Value: TStringList);
begin
  FScopes.Assign(Value);
end;

function AdminPasswordOk(const Password: string): boolean;
begin
  result := SameText(Password, IntToStr(AdminPwd));
end;

constructor TzDiagramDataSet.Create(Collection: TCollection);
var
  View: TDbView;
  Card: TDbCard;
begin
  inherited;
  FIsConcrete := False;
  FIsLookupDataSet := False;
  FDefaultAccessLevel := alFull;
  FActualAccessLevel := alFull;

  FDetailDatasets := TzDiagramDataSets.Create(TzDiagramDataSet, 'DetailDatasets', -1, self);
  FDetailDatasets._DataModule := nil;
  FDetailDatasets.Sorted := False;
  //
  FMenu := TMenu.Create;
  FReportProps := TReportProps.Create;
  FDescriptor := TDescriptor.Create;
  FDbViews := TDbViews.Create(TDbView, 'Views', imgDbViews, self);
  FDbCards := TDbCards.Create(TDbCard, 'Cards', imgCards, self);
  FDbPivots := TDbPivots.Create(TDbPivot, 'Pivots', imgPivots, self);
  FDbRecordViews := TDbRecordViews.Create(TDbRecordView, 'RecordViews', imgRecordViews, self);
  FDbTrees := TDbTrees.Create(TDbTree, 'Trees', imgTrees, self);
  FDbCharts := TDbCharts.Create(TDbChart, 'Charts', imgCharts, self);
  FDbSchedulers := TDbSchedulers.Create(TDbScheduler, 'Schedulers', imgSchedulers, self);
  FDbFiles := TDbFiles.Create(TDbFile, 'Files', imgPdf, self);
  FGisMaps := TGisMaps.Create(TGisMap, 'GisMaps', imgMaps, self);
  // <=======================>
  View := DbViews.Add;
  View.Name := Name;

  Card := DbCards.Add;
  Card.Name := Name;
  Card.Visible := False;
end;

destructor TzDiagramDataSet.Destroy;
begin
  FreeAndNil(FDetailDatasets);
  FreeAndNil(FMenu);
  FreeAndNil(FReportProps);
  FreeAndNil(FDescriptor);
  FreeAndNil(FDbViews);
  FreeAndNil(FDbCards);
  FreeAndNil(FDbPivots);
  FreeAndNil(FDbRecordViews);
  FreeAndNil(FDbTrees);
  FreeAndNil(FDbCharts);
  FreeAndNil(FDbSchedulers);
  FreeAndNil(FDbFiles);
  FreeAndNil(FGisMaps);
  inherited;
end;

procedure TzDiagramDataSet.Assign(Source: TPersistent);
var
  src: TzDiagramDataSet;
begin
  if Source is TzDiagramDataSet then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      // inherited Assign(Source);
      src := TzDiagramDataSet(Source);
      self.Name := src.Name;
      self.FIsConcrete := src.IsConcrete;
      self.FIsLookupDataSet := src.IsLookupDataSet;
      self.DetailDatasets.Assign(src.DetailDatasets);
      self.Menu.Assign(src.Menu);
      self.ReportProps.Assign(src.ReportProps);
      self.Descriptor.Assign(src.Descriptor);
      self.DbViews.Assign(src.DbViews);
      self.DbCards.Assign(src.DbCards);
      self.DbPivots.Assign(src.DbPivots);
      self.DbRecordViews.Assign(src.DbRecordViews);
      self.DbTrees.Assign(src.DbTrees);
      self.DbCharts.Assign(src.DbCharts);
      self.DbSchedulers.Assign(src.DbSchedulers);
      self.DbFiles.Assign(src.DbFiles);
      self.GisMaps.Assign(src.GisMaps);

      self.DefaultAccessLevel := src.DefaultAccessLevel;
      self.ActualAccessLevel := src.ActualAccessLevel;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzDiagramDataSet.MenuFilterOk(const Filter: string): boolean;
  function enum(Items: TzDiagramDataSets; const Filter: string): boolean;
  var
    i: integer;
  begin
    result := False;
    for i := 0 to Items.count - 1 do
      if Items[i].MenuFilterOk(Filter) then
        Exit(true);
  end;

begin
  result := (Filter = '') or (Ansipos(uppercase(Filter), uppercase(Menu.GetCaption)) > 0);

  if not result then
    if HasDetailDataSets then
      result := enum(DetailDatasets, Filter);
end;

function TzDiagramDataSet.HasDetailDataSets: boolean;
begin
  result := DetailDatasets.count > 0;
end;

function TzDiagramDataSet.HasMasterDataSet: boolean;
begin
  if assigned(Collection) then
    result := TzDiagramDataSets(Collection).HasMasterDataSet
  else
    result := False;
end;

function TzDiagramDataSet.MasterDataSet: TzDiagramDataSet;
begin
  result := nil;
  if HasMasterDataSet then
    result := TzDiagramDataSets(Collection).MasterDataSet;
end;

procedure TzDiagramDataSet.SetDetailDatasets(const Value: TzDiagramDataSets);
begin
  FDetailDatasets.Assign(Value);
end;

function TzDiagramDataSet.IsMenuLeaf: boolean;
  function enum(Items: TzDiagramDataSets): boolean;
  var
    i: integer;
  begin
    result := true;
    for i := 0 to Items.count - 1 do
    begin
      if Items[i].Menu.Visible then
        Exit(False)
      else
        if not enum(Items[i].DetailDatasets) then
          Exit(False);
    end;
  end;

begin
  result := Menu.Visible;

  if result then
    if HasDetailDataSets then
      result := enum(DetailDatasets);
end;

function TzDiagramDataSet.IsMenuVisible: boolean;

  function IsVisible(DataSet: TzDiagramDataSet): boolean;
  var
    i: integer;
  begin
    result := False;

    if DataSet.Menu.Visible then // da variare poi con IsMenuVisible di card/view
      Exit(true);

    for i := 0 to DataSet.DetailDatasets.count - 1 do
    begin
      result := IsVisible(DataSet.DetailDatasets[i]);

      if not result then
        Exit(False);
    end;
  end;

begin
  result := IsVisible(self);
end;

procedure TzDiagramDataSet.SetName(const Value: string);
var
  OldName, NewName: string;
  zDataSet: TzDataSet;
begin

  OldName := self.Name;

  if OldName = '' then // se in fase di loading
  begin
    NewName := DataModule.UniqueDataSetName(self, Value);
    inherited SetName(NewName);
  end
  else
  begin
    zDataSet := self.zDataSet;

    NewName := DataModule.UniqueDataSetName(self, Value);

    inherited SetName(NewName);

    if (Menu.Caption = '') or (Menu.Caption = OldName) then
      Menu.Caption := Name;

    /// //////////////////////////////////////

    if assigned(zDataSet) then
      zDataSet.Name := idDataSet;

    /// //////////////////////////////////////
    DbViews.NameChanged(Name, OldName);
    DbCards.NameChanged(Name, OldName);
    DbPivots.NameChanged(Name, OldName);
    DbRecordViews.NameChanged(Name, OldName);
    DbTrees.NameChanged(Name, OldName);
    DbCharts.NameChanged(Name, OldName);
    DbSchedulers.NameChanged(Name, OldName);
    DbFiles.NameChanged(Name, OldName);
    GisMaps.NameChanged(Name, OldName);
  end;
end;

constructor TzDiagramDataSets.Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: integer; aMaster: TzCollectionItem; const aSorted: boolean = true);
begin
  inherited;
  _DataModule := nil;
end;

function TzDiagramDataSets.DataModule: TzDataModule;
begin
  if HasMaster then
    result := MasterDataSet.DataModule
  else
    result := _DataModule;
end;

function TzDiagramDataSets.DataSetExists(const DataSetName: string): boolean;
begin
  result := assigned(FindDataSet(DataSetName, nil));
end;

procedure TzDiagramDataSets.enum(proc: TEnumProc);
var
  i: integer;
  zDiagramDataSet: TzDiagramDataSet;
begin
  for i := 0 to count - 1 do
  begin
    zDiagramDataSet := Items[i];

    proc(zDiagramDataSet);

    if zDiagramDataSet.HasDetailDataSets then
      zDiagramDataSet.DetailDatasets.enum(proc);
  end;
end;

function TzDiagramDataSets.FindDataSet(const DataSetName: string; ExcludedItem: TzDiagramDataSet = nil): TzDiagramDataSet;

  function Find(DataSets: TzDiagramDataSets; ExcludedItem: TzDiagramDataSet = nil): TzDiagramDataSet;
  var
    i: integer;
    DataSet: TzDiagramDataSet;
  begin
    result := nil;

    for i := 0 to DataSets.count - 1 do
    begin
      DataSet := DataSets[i];
      if SameText(DataSet.Name, DataSetName) then
        if DataSet <> ExcludedItem then
          Exit(DataSet);

      if DataSet.HasDetailDataSets then
        result := Find(DataSet.DetailDatasets, ExcludedItem);

      if assigned(result) then
        Exit;
    end;
  end;

begin
  result := Find(self, ExcludedItem);
end;

function TzDiagramDataSets.HasMasterDataSet: boolean;
begin
  result := HasMaster;
end;

function TzDiagramDataSets.MasterDataSet: TzDiagramDataSet;
begin
  result := nil;

  if HasMasterDataSet then
    result := TzDiagramDataSet(Master);
end;

constructor TzDataModule.Create(Collection: TCollection);
begin
  inherited;
  FBuildGUI := False;
  FMainDataModule := '';
  FActions := TzActions.Create(TzAction, 'Actions', -1, nil);
  FFormOptions := TFormOptions.Create;
  FControllerOptions := TControllerOptions.Create;
  FDataSets := TzDiagramDataSets.Create(TzDiagramDataSet, 'DataSets', -1, nil);
  FDataSets._DataModule := self;
  FDataSets.Sorted := False;
  // FLayouts := TzLayouts.Create(TzLayout, 'Layouts', -1, nil);
  FLayouts := TzLayouts.Create(TzLayout, 'Layouts', -1, nil, False);
  FSubDataModules := TStringList.Create;
end;

destructor TzDataModule.Destroy;
begin
  FreeAndNil(FActions);
  FreeAndNil(FFormOptions);
  FreeAndNil(FControllerOptions);
  FreeAndNil(FDataSets);
  FreeAndNil(FLayouts);
  FreeAndNil(FSubDataModules);
  inherited;
end;

procedure TzDataModule.AddSubDM(const SubDataModuleName: string);
begin
  if SubDataModules.IndexOf(SubDataModuleName) = -1 then
    SubDataModules.Add(SubDataModuleName);
end;

procedure TzDataModule.Assign(Source: TPersistent);
var
  src: TzDataModule;
begin
  if Source is TzDataModule then
  begin
    src := TzDataModule(Source);
    self.Name := src.Name;
    self.BuildGUI := src.BuildGUI;
    self.Actions.Assign(src.Actions);
    self.ControllerOptions.Assign(src.ControllerOptions);
    self.FormOptions.Assign(src.FormOptions);
    self.MainDataModule := src.MainDataModule;
    self.DataSets.Assign(src.DataSets);
    self.Layouts.Assign(src.Layouts);
    self.SubDataModules.Assign(src.SubDataModules);
  end
  else
    inherited Assign(Source);
end;

function TzDataModule.FindDataSet(const DataSetName: string; ExcludedItem: TzDiagramDataSet = nil): TzDiagramDataSet;
begin
  result := DataSets.FindDataSet(DataSetName, ExcludedItem);
end;

procedure TzDataModule.DestroyLinkedObjects;

  procedure DestroyDataSets(zDiagramDataSets: TzDiagramDataSets);
  var
    i: integer;
    zDiagramDataSet: TzDiagramDataSet;
    zDataSet: TzDataSet;
    zDbViewProps: TzDbViewProps;
    zDbCardProps: TzDbCardProps;
    zDbPivotProps: TzDbPivotProps;
    zDbRecordViewProps: TzDbRecordViewProps;
    zDbTreeProps: TzDbTreeProps;
    zDbChartProps: TzDbChartProps;
    zDbSchedulerProps: TzDbSchedulerProps;
  begin
    for zDiagramDataSet in zDiagramDataSets do
    begin
      zDataSet := zDiagramDataSet.zDataSet(False);

      if assigned(zDataSet) then
        zDataSet.RemoveFromCollection;

      // View
      for i := 0 to zDiagramDataSet.DbViews.count - 1 do
      begin
        zDbViewProps := zDiagramDataSet.DbViews[i].zDbViewProps(False);

        if assigned(zDbViewProps) then
          zDbViewProps.RemoveFromCollection;
      end;

      // Card
      for i := 0 to zDiagramDataSet.DbCards.count - 1 do
      begin
        zDbCardProps := zDiagramDataSet.DbCards[i].zDbCardProps(False);

        if assigned(zDbCardProps) then
          zDbCardProps.RemoveFromCollection;
      end;

      // Pivot
      for i := 0 to zDiagramDataSet.DbPivots.count - 1 do
      begin
        zDbPivotProps := zDiagramDataSet.DbPivots[i].zDbPivotProps(False);

        if assigned(zDbPivotProps) then
          zDbPivotProps.RemoveFromCollection;
      end;

      // Vista record
      for i := 0 to zDiagramDataSet.DbRecordViews.count - 1 do
      begin
        zDbRecordViewProps := zDiagramDataSet.DbRecordViews[i].zDbRecordViewProps(False);

        if assigned(zDbRecordViewProps) then
          zDbRecordViewProps.RemoveFromCollection;
      end;

      // Albero
      for i := 0 to zDiagramDataSet.DbTrees.count - 1 do
      begin
        zDbTreeProps := zDiagramDataSet.DbTrees[i].zDbTreeProps(False);

        if assigned(zDbTreeProps) then
          zDbTreeProps.RemoveFromCollection;
      end;

      // Grafico
      for i := 0 to zDiagramDataSet.DbCharts.count - 1 do
      begin
        zDbChartProps := zDiagramDataSet.DbCharts[i].zDbChartProps(False);

        if assigned(zDbChartProps) then
          zDbChartProps.RemoveFromCollection;
      end;

      // Calendario
      for i := 0 to zDiagramDataSet.DbSchedulers.count - 1 do
      begin
        zDbSchedulerProps := zDiagramDataSet.DbSchedulers[i].zDbSchedulerProps(False);

        if assigned(zDbSchedulerProps) then
          zDbSchedulerProps.RemoveFromCollection;
      end;

      DestroyDataSets(zDiagramDataSet.DetailDatasets);
    end;
  end;

begin
  DestroyDataSets(DataSets);
end;

function TzDataModule.GetPayload: String;

  procedure AddDataSets(jDataSets, Views, cards, pivots, RecordViews, Trees, Charts, Schedulers: TJSONObject; zDiagramDataSets: TzDiagramDataSets);
  var
    i: integer;
    zDiagramDataSet: TzDiagramDataSet;
    zDataSet: TzDataSet;
    zDbViewProps: TzDbViewProps;
    zDbCardProps: TzDbCardProps;
    zDbPivotProps: TzDbPivotProps;
    zDbRecordViewProps: TzDbRecordViewProps;
    zDbTreeProps: TzDbTreeProps;
    zDbChartProps: TzDbChartProps;
    zDbSchedulerProps: TzDbSchedulerProps;
  begin

    for zDiagramDataSet in zDiagramDataSets do
    begin
      zDataSet := zDiagramDataSet.zDataSet(true);

      jDataSets.addPair(zDataSet.Name, zDataSet.AsDFM);

      // View
      for i := 0 to zDiagramDataSet.DbViews.count - 1 do
      begin
        zDbViewProps := zDiagramDataSet.DbViews[i].zDbViewProps(False);

        if assigned(zDbViewProps) then
          Views.addPair(zDbViewProps.Name, zDbViewProps.AsDFM);
      end;

      // Card
      for i := 0 to zDiagramDataSet.DbCards.count - 1 do
      begin
        zDbCardProps := zDiagramDataSet.DbCards[i].zDbCardProps(False);

        if assigned(zDbCardProps) then
          cards.addPair(zDbCardProps.Name, zDbCardProps.AsDFM);
      end;

      // Pivot
      for i := 0 to zDiagramDataSet.DbPivots.count - 1 do
      begin
        zDbPivotProps := zDiagramDataSet.DbPivots[i].zDbPivotProps(False);

        if assigned(zDbPivotProps) then
          pivots.addPair(zDbPivotProps.Name, zDbPivotProps.AsDFM);
      end;

      // Vista record
      for i := 0 to zDiagramDataSet.DbRecordViews.count - 1 do
      begin
        zDbRecordViewProps := zDiagramDataSet.DbRecordViews[i].zDbRecordViewProps(False);

        if assigned(zDbRecordViewProps) then
          RecordViews.addPair(zDbRecordViewProps.Name, zDbRecordViewProps.AsDFM);
      end;

      // Albero
      for i := 0 to zDiagramDataSet.DbTrees.count - 1 do
      begin
        zDbTreeProps := zDiagramDataSet.DbTrees[i].zDbTreeProps(False);

        if assigned(zDbTreeProps) then
          Trees.addPair(zDbTreeProps.Name, zDbTreeProps.AsDFM);
      end;

      // Grafico
      for i := 0 to zDiagramDataSet.DbCharts.count - 1 do
      begin
        zDbChartProps := zDiagramDataSet.DbCharts[i].zDbChartProps(False);

        if assigned(zDbChartProps) then
          Charts.addPair(zDbChartProps.Name, zDbChartProps.AsDFM);
      end;

      // Calendario
      for i := 0 to zDiagramDataSet.DbSchedulers.count - 1 do
      begin
        zDbSchedulerProps := zDiagramDataSet.DbSchedulers[i].zDbSchedulerProps(False);

        if assigned(zDbSchedulerProps) then
          Schedulers.addPair(zDbSchedulerProps.Name, zDbSchedulerProps.AsDFM);
      end;

      AddDataSets(jDataSets, Views, cards, pivots, RecordViews, Trees, Charts, Schedulers, zDiagramDataSet.DetailDatasets);
    end;
  end;

var
  J, jDataSets, Views, cards, pivots, RecordViews, Trees, Charts, Schedulers: TJSONObject;
begin
  inherited;

  J := TJSONObject.Create;
  try
    J.addPair(ClassName, AsDFM);

    jDataSets := TJSONObject.Create;
    J.addPair('datasets', jDataSets);

    Views := TJSONObject.Create;
    J.addPair('views', Views);

    cards := TJSONObject.Create;
    J.addPair('cards', cards);

    pivots := TJSONObject.Create;
    J.addPair('pivots', pivots);

    Trees := nil;
    Charts := nil;
    Schedulers := nil;
    RecordViews := TJSONObject.Create;
    try
      Trees := TJSONObject.Create;
      Charts := TJSONObject.Create;
      Schedulers := TJSONObject.Create;

      AddDataSets(jDataSets, Views, cards, pivots, RecordViews, Trees, Charts, Schedulers, DataSets);

      // Le voci nuove compaiono solo se servono: un modulo senza viste record
      // ne' alberi resta copiabile verso un eseguibile che conosce soltanto le
      // prime cinque
      if RecordViews.count > 0 then
      begin
        J.addPair('recordviews', RecordViews);
        RecordViews := nil;
      end;

      if Trees.count > 0 then
      begin
        J.addPair('trees', Trees);
        Trees := nil;
      end;

      if Charts.count > 0 then
      begin
        J.addPair('charts', Charts);
        Charts := nil;
      end;

      if Schedulers.count > 0 then
      begin
        J.addPair('schedulers', Schedulers);
        Schedulers := nil;
      end;
    finally
      FreeAndNil(Schedulers);
      FreeAndNil(Charts);
      FreeAndNil(Trees);
      FreeAndNil(RecordViews);
    end;

    result := J.Format(4);
  finally
    FreeAndNil(J);
  end;
end;

procedure TzDataModule.SetPayload(const Value: String);
var
  J, jDataSets, Views, cards, pivots, RecordViews, Trees, Charts, Schedulers: TJSONObject;
  i: integer;
  zDataSet: TzDataSet;
  zDbViewProps: TzDbViewProps;
  zDbCardProps: TzDbCardProps;
  zDbPivotProps: TzDbPivotProps;
  zDbRecordViewProps: TzDbRecordViewProps;
  zDbTreeProps: TzDbTreeProps;
  zDbChartProps: TzDbChartProps;
  zDbSchedulerProps: TzDbSchedulerProps;
begin
  inherited;
  J := TJSONObject.ParseJSONValue(Value) as TJSONObject;
  try
    if not assigned(J) then
      Exit;

    // 5 voci: formato precedente; fino a 9 con viste record, alberi, grafici
    // e calendari
    if (J.count < 5) or (J.count > 9) then
      Exit;

    if not SameText(J.Pairs[0].JsonString.Value, ClassName) then
    begin
      ConfirmOk('Formato clipboard non valido.');
      Exit;
    end;

    // eliminare tutti i precedenti dataset
    DestroyLinkedObjects;

    AsDFM := J.Pairs[0].JsonValue.Value;
    jDataSets := J.GetValue<TJSONObject>('datasets');
    Views := J.GetValue<TJSONObject>('views');
    cards := J.GetValue<TJSONObject>('cards');
    pivots := J.GetValue<TJSONObject>('pivots');

    // datasets
    for i := 0 to jDataSets.count - 1 do
    begin
      zDataSet := Base.zDataSets.get(jDataSets.Pairs[i].JsonString.Value, true);
      zDataSet.AsDFM := jDataSets.Pairs[i].JsonValue.Value;
    end;

    // Views
    for i := 0 to Views.count - 1 do
    begin
      zDbViewProps := Base.zDbViews.get(Views.Pairs[i].JsonString.Value, true);
      zDbViewProps.AsDFM := Views.Pairs[i].JsonValue.Value;
    end;

    // Cards
    for i := 0 to cards.count - 1 do
    begin
      zDbCardProps := Base.zDbCards.get(cards.Pairs[i].JsonString.Value, true);
      zDbCardProps.AsDFM := cards.Pairs[i].JsonValue.Value;
    end;

    // Pivots
    for i := 0 to pivots.count - 1 do
    begin
      zDbPivotProps := Base.zDbPivots.get(pivots.Pairs[i].JsonString.Value, true);
      zDbPivotProps.AsDFM := pivots.Pairs[i].JsonValue.Value;
    end;

    // Viste record (voce facoltativa)
    RecordViews := J.GetValue('recordviews') as TJSONObject;
    if assigned(RecordViews) then
      for i := 0 to RecordViews.count - 1 do
      begin
        zDbRecordViewProps := Base.zDbRecordViews.get(RecordViews.Pairs[i].JsonString.Value, true);
        zDbRecordViewProps.AsDFM := RecordViews.Pairs[i].JsonValue.Value;
      end;

    // Alberi (voce facoltativa)
    Trees := J.GetValue('trees') as TJSONObject;
    if assigned(Trees) then
      for i := 0 to Trees.count - 1 do
      begin
        zDbTreeProps := Base.zDbTrees.get(Trees.Pairs[i].JsonString.Value, true);
        zDbTreeProps.AsDFM := Trees.Pairs[i].JsonValue.Value;
      end;

    // Grafici (voce facoltativa)
    Charts := J.GetValue('charts') as TJSONObject;
    if assigned(Charts) then
      for i := 0 to Charts.count - 1 do
      begin
        zDbChartProps := Base.zDbCharts.get(Charts.Pairs[i].JsonString.Value, true);
        zDbChartProps.AsDFM := Charts.Pairs[i].JsonValue.Value;
      end;

    // Calendari (voce facoltativa)
    Schedulers := J.GetValue('schedulers') as TJSONObject;
    if assigned(Schedulers) then
      for i := 0 to Schedulers.count - 1 do
      begin
        zDbSchedulerProps := Base.zDbSchedulers.get(Schedulers.Pairs[i].JsonString.Value, true);
        zDbSchedulerProps.AsDFM := Schedulers.Pairs[i].JsonValue.Value;
      end;
  finally
    FreeAndNil(J);
  end;
end;

function TzDataModule.UniqueDataSetName(zDiagramDataSet: TzDiagramDataSet;

const NewDataSetName: string): string;
var
  i: integer;
begin
  result := NewDataSetName;

  i := 0;
  while assigned(FindDataSet(result, zDiagramDataSet)) do
  begin
    Inc(i);
    result := NewDataSetName + '_' + IntToStr(i);
  end;
end;

function TzDataModule.IsSubDataModule: boolean;
begin
  result := FMainDataModule <> ''
end;

function TzDataModule.LoadFromDataModule(DataModule: TDataModule): boolean;
var
  dict: TDictionary<TzFbDataSet, TzDiagramDataSet>;
  DataSet: TzFbDataSet;
  i: integer;
  ShouldSave: boolean;
  function AddDataSet(DataSet: TzFbDataSet): TzDiagramDataSet;
    function GetMaster(DataSet: TzFbDataSet): TzDiagramDataSet;
    var
      MasterDataSet: TzFbDataSet;
    begin
      result := nil;

      if assigned(DataSet.DataSource) then
        if assigned(DataSet.DataSource.DataSet) then
        begin
          MasterDataSet := TzFbDataSet(DataSet.DataSource.DataSet);
          result := AddDataSet(MasterDataSet);
        end;
    end;

  var
    Master: TzDiagramDataSet;
  begin
    result := nil;

    if dict.ContainsKey(DataSet) then
    begin
      dict.TryGetValue(DataSet, result);
      Exit;
    end;

    result := FindDataSet(DataSet.Name);

    if not assigned(result) then
    begin
      Master := GetMaster(DataSet);
      if assigned(Master) then
        result := Master.DetailDatasets.Add
      else
        result := DataSets.Add;

      result.Name := DataSet.Name;
      result.Menu.Caption := DataSet.Name;
      result.FIsConcrete := true;
      ShouldSave := true;
    end;
    // Dovrebbero essere gi� nello store, verrebbero altrimenti sovrascritte
    // Result.TableName := DataSet.TableName;
    // Result.SQL_Select.Text := DataSet.SelectSQL.Text;
    dict.Add(DataSet, result);
  end;

begin

  result := False;
  ShouldSave := False;

  if not assigned(DataModule) then
    Exit;

  dict := TDictionary<TzFbDataSet, TzDiagramDataSet>.Create;
  try
    for i := 0 to DataModule.ComponentCount - 1 do
      if DataModule.Components[i] is TzFbDataSet then
      begin
        DataSet := TzFbDataSet(DataModule.Components[i]);
        AddDataSet(DataSet);
      end;
  finally
    FreeAndNil(dict);
  end;
  ///
  result := ShouldSave;
end;

procedure TzDataModule.LoadFromBase;
var
  Item: TzDataModule;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDataModules.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDataModule.SaveToBase(SaveToLZ: boolean = False);
var
  Item: TzDataModule;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDataModules.get(Name, true);
  Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDataModules, 'TzDataModule.SaveToBase');
end;

procedure TzDataModule.SetActions(const Value: TzActions);
begin
  FActions.Assign(Value);
end;

procedure TzDataModule.SetDataSets(const Value: TzDiagramDataSets);
begin
  FDataSets.Assign(Value);
end;

procedure TzDataModule.SetLayouts(const Value: TzLayouts);
begin
  FLayouts.Assign(Value);
end;

procedure TzDataModule.SetName(const Value: string);
var
  OldName: string;
begin
  OldName := self.Name;
  inherited;
  if (FormOptions.Caption = '') or (FormOptions.Caption = OldName) then
    FormOptions.Caption := Value;

  if (FormOptions.ReportGroup = '') or (FormOptions.ReportGroup = OldName) then
    FormOptions.ReportGroup := Value;

  // if FormOptions.HelpType = htKeyword then
  if (FormOptions.HelpKeyword = '') or (FormOptions.HelpKeyword = OldName) then
    FormOptions.HelpKeyword := Value;
end;

procedure TzDataModule.SetSubDataModules(const Value: TStringList);
begin
  FSubDataModules.Assign(Value);
end;

function TzDiagramDataSet.DataModule: TzDataModule;
begin
  result := TzDiagramDataSets(Collection).DataModule;
end;

function TzDiagramDataSet.zDataSet(const CreateIfNotExists: boolean = False): TzDataSet;
var
  Idx: integer;
begin
  Assert(DataModule <> nil);

  result := nil;

  Idx := Base.zDataSets.IndexOf(idDataSet);

  if Idx <> -1 then
    result := Base.zDataSets[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDataSets.Add;
      result.Name := idDataSet;
    end;
end;

constructor TzDiagramDataSet.TMenu.Create;
begin
  inherited;
  FCaption := '';
  FGroup := '';
  FTranslatedCaption := '';
  FTranslatedGroup := '';

  FVisible := true;
end;

function TzDiagramDataSet.TMenu.GetCaption: string;
begin
  if TranslatedCaption.IsEmpty then
    result := Caption
  else
    result := TranslatedCaption;
end;

function TzDiagramDataSet.TMenu.GetGroup: string;
begin
  if TranslatedGroup.IsEmpty then
    result := Group
  else
    result := TranslatedGroup;
end;

procedure TzDiagramDataSet.TMenu.Assign(Source: TPersistent);
var
  src: TMenu;
begin
  if Source is TMenu then
  begin
    src := TMenu(Source);
    Caption := src.Caption;
    Group := src.Group;
    FTranslatedCaption := src.TranslatedCaption;
    FTranslatedGroup := src.TranslatedGroup;
    Visible := src.Visible;
  end
  else
    inherited;
end;

constructor TzDiagramDataSet.TDescriptor.Create;
begin
  inherited Create;
  FInclude := true;
end;

procedure TzDiagramDataSet.TDescriptor.Assign(Source: TPersistent);
var
  src: TDescriptor;
begin
  if Source is TDescriptor then
  begin
    src := TDescriptor(Source);
    FInclude := src.Include;
    FNote := src.Note;
  end
  else
    inherited;
end;

function TzDiagramDataSet.GetActualAccessLevel: TAccessLevel;
begin
  result := FActualAccessLevel;

  if result = alNone then
    if Base.IsAdmin then
      result := alFull;
end;

function TzDiagramDataSet.idDataSet: string;
begin
  result := DataModule.Name + '.' + self.Name;
end;

function TzDiagramDataSet.VisibleCount: integer;
begin
  result := DbViews.VisibleCount + DbCards.VisibleCount + DbPivots.VisibleCount + DbRecordViews.VisibleCount + DbTrees.VisibleCount + DbCharts.VisibleCount + DbSchedulers.VisibleCount + DbFiles.VisibleCount + GisMaps.VisibleCount;
end;

procedure TzDiagramDataSet.SetDbTrees(const Value: TDbTrees);
begin
  FDbTrees.Assign(Value);
end;

function TzDiagramDataSet.IsDbTreesStored: boolean;
begin
  result := FDbTrees.count > 0;
end;

procedure TzDiagramDataSet.SetDbCharts(const Value: TDbCharts);
begin
  FDbCharts.Assign(Value);
end;

function TzDiagramDataSet.IsDbChartsStored: boolean;
begin
  result := FDbCharts.count > 0;
end;

procedure TzDiagramDataSet.SetDbSchedulers(const Value: TDbSchedulers);
begin
  FDbSchedulers.Assign(Value);
end;

function TzDiagramDataSet.IsDbSchedulersStored: boolean;
begin
  result := FDbSchedulers.count > 0;
end;

procedure TzDiagramDataSet.SetDbRecordViews(const Value: TDbRecordViews);
begin
  FDbRecordViews.Assign(Value);
end;

function TzDiagramDataSet.IsDbRecordViewsStored: boolean;
begin
  result := FDbRecordViews.count > 0;
end;

procedure TzDiagramDataSet.SetDbCards(const Value: TDbCards);
begin
  FDbCards.Assign(Value);
end;

procedure TzDiagramDataSet.SetDbPivots(const Value: TDbPivots);
begin
  FDbPivots.Assign(Value);
end;

procedure TzDiagramDataSet.SeTGisMaps(const Value: TGisMaps);
begin
  FGisMaps.Assign(Value);
end;

procedure TzDiagramDataSet.SetDbViews(const Value: TDbViews);
begin
  FDbViews.Assign(Value);
end;

procedure TzDiagramDataSet.SetMenu(const Value: TMenu);
begin
  FMenu.Assign(Value);
end;

procedure TzDiagramDataSet.SetDescriptor(const Value: TDescriptor);
begin
  FDescriptor.Assign(Value);
end;

procedure TzDiagramDataSet.SetDbFiles(const Value: TDbFiles);
begin
  FDbFiles.Assign(Value);
end;

procedure TzDiagramDataSet.SetDefaultAccessLevel(const Value: TAccessLevel);
begin
  FDefaultAccessLevel := Value;
  FActualAccessLevel := DefaultAccessLevel;
end;

constructor TzDiagramDataSet.TzDiagramCtrl.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FVisible := true;

  if zDiagramDataSet <> nil then
  begin
    Name := zDiagramDataSet.Name;
    FCaption := zDiagramDataSet.Menu.Caption;
  end;
end;

procedure TzDiagramDataSet.TzDiagramCtrl.Assign(Source: TPersistent);
var
  src: TzDiagramCtrl;
begin
  if Source is TzDiagramCtrl then
  begin
    src := TzDiagramCtrl(Source);
    Name := src.Name;
    Caption := src.Caption;
    Visible := src.Visible;
  end
  else
    inherited;
end;

function TzDiagramDataSet.TzDiagramCtrl.ComponentName: string;
var
  ComponentPrefix: string;
begin
  case zComponentType of
    ctNull:
      ComponentPrefix := '';
    ctView:
      ComponentPrefix := 'view';
    ctCard:
      ComponentPrefix := 'card';
    ctPivot:
      ComponentPrefix := 'pivot';
    ctFile:
      ComponentPrefix := 'Pdf';
    ctMap:
      ComponentPrefix := 'tatuk';
    ctRecordView:
      ComponentPrefix := 'recview';
    ctTree:
      ComponentPrefix := 'tree';
    ctChart:
      ComponentPrefix := 'chart';
    ctScheduler:
      ComponentPrefix := 'scheduler';
  end;

  result := ValidateComponentName(ComponentPrefix + zDiagramDataSet.Name + '_' + self.Name);
end;

function TzDiagramDataSet.TzDiagramCtrl.zComponentType: TzComponentType;
begin
  result := ctNull;
end;

function TzDiagramDataSet.TzDiagramCtrl.GetCaption: String;
begin
  result := FCaption;

  if result = '' then
    result := zDiagramDataSet.Menu.Caption;
end;

function TzDiagramDataSet.TzDiagramCtrl.GetDataSetID: string;
begin
  result := '';

  if Name = zDiagramDataSet.Name then
    result := zDiagramDataSet.idDataSet
  else
    result := ComponentName;
end;

function TzDiagramDataSet.TzDiagramCtrl.isCaptionStored: boolean;
begin
  result := FCaption <> '';
end;

function TzDiagramDataSet.TzDiagramCtrl.TabSheetName: string;
begin
  result := 'tab' + uppercase(Copy(ComponentName, 1, 1)) + Copy(ComponentName, 2);
end;

procedure TzDiagramDataSet.TzDiagramCtrl.NameChanged(const NewName, OldName: string);
begin
  inherited;

  if NewName <> '' then
    if OldName <> '' then // loading
      if (Name = OldName) or (Name = '') then
      begin
        Name := NewName;

        if (Caption = OldName) or (OldName = '') then
          Caption := NewName;
      end;
end;

function TzDiagramDataSet.TzDiagramCtrl.zDiagramDataSet: TzDiagramDataSet;
begin
  result := nil;

  if Collection is TzDiagramCtrls then
    result := TzDiagramCtrls(Collection).zDiagramDataSet;
end;

constructor TzDiagramDataSet.TDbView.Create(Collection: TCollection);
begin
  inherited;
  FCardID := '';
  FViewID := '';
end;

procedure TzDiagramDataSet.TDbView.Assign(Source: TPersistent);
var
  src: TDbView;
begin
  inherited; // setta  ereditate

  if Source is TDbView then
  begin
    src := TDbView(Source);
    CardID := src.CardID;
    ViewID := src.ViewID;
  end;
end;

function TzDiagramDataSet.TDbView.zComponentType: TzComponentType;
begin
  result := ctView;
end;

function TzDiagramDataSet.TDbView.GetCardID: string;
begin
  result := CardID;

  if result = '' then
    result := GetViewID;
end;

function TzDiagramDataSet.TDbView.GetViewID: string;
begin
  result := ViewID;

  if result = '' then
    result := GetDataSetID;
end;

procedure TzDiagramDataSet.TDbView.NameChanged(const NewName, OldName: string);
var
  Props: TzDbViewProps;
begin
  inherited;

  if self.Name <> OldName then
    Exit;

  Props := zDbViewProps(False);

  if assigned(Props) then
  begin
    Props.Name := GetViewID;
    Props.DataSet := GetDataSetID;
  end;
end;

procedure TzDiagramDataSet.TDbView.SetReadOnly(const ReadOnly: boolean);
var
  Props: TzDbViewProps;
begin
  inherited;
  Props := zDbViewProps(true);

  Props.Flags.ReadOnly := ReadOnly;
  Props.Flags.ButtonInsert := not ReadOnly;
  Props.Flags.ButtonUpdate := not ReadOnly;
  Props.Flags.ButtonDelete := not ReadOnly;
end;

function TzDiagramDataSet.TDbView.zDbViewProps(const CreateIfNotExists: boolean = False): TzDbViewProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  Idx := Base.zDbViews.IndexOf(GetViewID);

  if Idx <> -1 then
    result := Base.zDbViews[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbViews.Add;
      result.Name := GetViewID;
    end;
end;

constructor TzDiagramDataSet.TDbCard.Create(Collection: TCollection);
begin
  inherited;
  FCardID := '';
end;

procedure TzDiagramDataSet.TDbCard.Assign(Source: TPersistent);
var
  src: TDbCard;
begin
  inherited; // setta  ereditate

  if Source is TDbCard then
  begin
    src := TDbCard(Source);
    CardID := src.CardID;
  end;
end;

function TzDiagramDataSet.TDbCard.zComponentType: TzComponentType;
begin
  result := ctCard;
end;

function TzDiagramDataSet.TDbCard.GetCardID: string;
begin
  result := CardID;

  if result = '' then
    result := GetDataSetID;
end;

procedure TzDiagramDataSet.TDbCard.NameChanged(const NewName, OldName: string);
var
  Props: TzDbCardProps;
begin
  inherited;

  if self.Name <> OldName then
    Exit;

  Props := zDbCardProps(False);

  if assigned(Props) then
  begin
    Props.Name := GetCardID;
    Props.DataSet := GetDataSetID;
  end;
end;

procedure TzDiagramDataSet.TDbCard.SetReadOnly(const ReadOnly: boolean);
var
  Props: TzDbCardProps;
begin
  inherited;
  Props := zDbCardProps(true);

  Props.Flags.ButtonInsert := not ReadOnly;
  Props.Flags.ButtonUpdate := not ReadOnly;
  Props.Flags.ButtonDelete := not ReadOnly;
end;

function TzDiagramDataSet.TDbCard.zDbCardProps(const CreateIfNotExists: boolean = False): TzDbCardProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  Idx := Base.zDbCards.IndexOf(GetCardID);

  if Idx <> -1 then
    result := Base.zDbCards[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbCards.Add;
      result.Name := GetCardID;
    end;
end;

constructor TzDiagramDataSet.TDbPivot.Create(Collection: TCollection);
begin
  inherited;
  FPivotID := '';
end;

procedure TzDiagramDataSet.TDbPivot.Assign(Source: TPersistent);
var
  src: TDbPivot;
begin
  inherited; // setta  ereditate

  if Source is TDbPivot then
  begin
    src := TDbPivot(Source);
    PivotID := src.PivotID;
  end;
end;

function TzDiagramDataSet.TDbPivot.zComponentType: TzComponentType;
begin
  result := ctPivot;
end;

function TzDiagramDataSet.TDbPivot.GetPivotID: string;
begin
  result := PivotID;

  if result = '' then
    result := GetDataSetID;
end;

function TzDiagramDataSet.TDbPivot.zDbPivotProps(const CreateIfNotExists: boolean = False): TzDbPivotProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  // Le props del pivot si chiamano come l'identificativo che il componente
  // TzDbPivot usa (PivotID, per difetto Modulo.DataSet), non come la voce
  // del diagramma: con Name la ricerca non le trovava mai.
  Idx := Base.zDbPivots.IndexOf(GetPivotID);

  if Idx <> -1 then
    result := Base.zDbPivots[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbPivots.Add;
      result.Name := GetPivotID;
    end;
end;

{ TzDiagramDataSet.TDbRecordView }

constructor TzDiagramDataSet.TDbRecordView.Create(Collection: TCollection);
begin
  inherited;
  FRecordViewID := '';
end;

procedure TzDiagramDataSet.TDbRecordView.Assign(Source: TPersistent);
var
  src: TDbRecordView;
begin
  inherited; // setta le ereditate

  if Source is TDbRecordView then
  begin
    src := TDbRecordView(Source);
    RecordViewID := src.RecordViewID;
  end;
end;

function TzDiagramDataSet.TDbRecordView.zComponentType: TzComponentType;
begin
  result := ctRecordView;
end;

function TzDiagramDataSet.TDbRecordView.GetRecordViewID: string;
begin
  result := RecordViewID;

  if result = '' then
    result := GetDataSetID;
end;

procedure TzDiagramDataSet.TDbRecordView.NameChanged(const NewName, OldName: string);
var
  Props: TzDbRecordViewProps;
  OldID: string;
begin
  inherited;

  // Con RecordViewID esplicito la chiave non dipende dal nome del dataset
  if RecordViewID <> '' then
    Exit;

  if not assigned(Base) then
    Exit;

  // Le props sono ancora sotto l'identificativo calcolato con il nome vecchio
  // del dataset: stessa regola di GetDataSetID
  if Name = zDiagramDataSet.Name then
    OldID := zDiagramDataSet.DataModule.Name + '.' + OldName
  else
    OldID := ValidateComponentName('recview' + OldName + '_' + Name);

  if SameText(OldID, GetRecordViewID) then
    Exit;

  Props := Base.zDbRecordViews.get(OldID, False);

  if assigned(Props) then
  begin
    Props.Name := GetRecordViewID;
    Props.DataSet := GetDataSetID;
  end;
end;

procedure TzDiagramDataSet.TDbRecordView.SetReadOnly(const ReadOnly: boolean);
var
  Props: TzDbRecordViewProps;
begin
  Props := zDbRecordViewProps(true);

  if assigned(Props) then
    Props.Flags.ReadOnly := ReadOnly;
end;

function TzDiagramDataSet.TDbRecordView.zDbRecordViewProps(const CreateIfNotExists: boolean = False): TzDbRecordViewProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  // Le props si chiamano come l'identificativo usato dal componente
  // (RecordViewID, per difetto Modulo.DataSet), non come la voce del diagramma
  Idx := Base.zDbRecordViews.IndexOf(GetRecordViewID);

  if Idx <> -1 then
    result := Base.zDbRecordViews[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbRecordViews.Add;
      result.Name := GetRecordViewID;
      result.DataSet := GetDataSetID;
    end;
end;

{ TzDiagramDataSet.TDbRecordViews }

function TzDiagramDataSet.TDbRecordViews.Add: TDbRecordView;
begin
  result := TDbRecordView(inherited Add);
end;

function TzDiagramDataSet.TDbRecordViews.GetItem(Index: integer): TDbRecordView;
begin
  result := TDbRecordView(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbRecordViews.Insert(Index: integer): TDbRecordView;
begin
  result := TDbRecordView(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbRecordViews.SetItem(Index: integer; const Value: TDbRecordView);
begin
  Items[Index].Assign(Value);
end;

{ TzDiagramDataSet.TDbTree }

constructor TzDiagramDataSet.TDbTree.Create(Collection: TCollection);
begin
  inherited;
  FTreeID := '';
end;

procedure TzDiagramDataSet.TDbTree.Assign(Source: TPersistent);
var
  src: TDbTree;
begin
  inherited; // setta le ereditate

  if Source is TDbTree then
  begin
    src := TDbTree(Source);
    TreeID := src.TreeID;
  end;
end;

function TzDiagramDataSet.TDbTree.zComponentType: TzComponentType;
begin
  result := ctTree;
end;

function TzDiagramDataSet.TDbTree.GetTreeID: string;
begin
  result := TreeID;

  if result = '' then
    result := GetDataSetID;
end;

procedure TzDiagramDataSet.TDbTree.NameChanged(const NewName, OldName: string);
var
  Props: TzDbTreeProps;
  OldID: string;
begin
  inherited;

  // Con TreeID esplicito la chiave non dipende dal nome del dataset
  if TreeID <> '' then
    Exit;

  if not assigned(Base) then
    Exit;

  // Le props sono ancora sotto l'identificativo calcolato con il nome vecchio
  // del dataset: stessa regola di GetDataSetID
  if Name = zDiagramDataSet.Name then
    OldID := zDiagramDataSet.DataModule.Name + '.' + OldName
  else
    OldID := ValidateComponentName('tree' + OldName + '_' + Name);

  if SameText(OldID, GetTreeID) then
    Exit;

  Props := Base.zDbTrees.get(OldID, False);

  if assigned(Props) then
  begin
    Props.Name := GetTreeID;
    Props.DataSet := GetDataSetID;
  end;
end;

procedure TzDiagramDataSet.TDbTree.SetReadOnly(const ReadOnly: boolean);
var
  Props: TzDbTreeProps;
begin
  Props := zDbTreeProps(true);

  if assigned(Props) then
    Props.Flags.ReadOnly := ReadOnly;
end;

function TzDiagramDataSet.TDbTree.zDbTreeProps(const CreateIfNotExists: boolean = False): TzDbTreeProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  // Le props si chiamano come l'identificativo usato dal componente
  // (TreeID, per difetto Modulo.DataSet), non come la voce del diagramma
  Idx := Base.zDbTrees.IndexOf(GetTreeID);

  if Idx <> -1 then
    result := Base.zDbTrees[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbTrees.Add;
      result.Name := GetTreeID;
      result.DataSet := GetDataSetID;
    end;
end;

{ TzDiagramDataSet.TDbTrees }

function TzDiagramDataSet.TDbTrees.Add: TDbTree;
begin
  result := TDbTree(inherited Add);
end;

function TzDiagramDataSet.TDbTrees.GetItem(Index: integer): TDbTree;
begin
  result := TDbTree(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbTrees.Insert(Index: integer): TDbTree;
begin
  result := TDbTree(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbTrees.SetItem(Index: integer; const Value: TDbTree);
begin
  Items[Index].Assign(Value);
end;

{ TzDiagramDataSet.TDbChart }

constructor TzDiagramDataSet.TDbChart.Create(Collection: TCollection);
begin
  inherited;
  FChartID := '';
end;

procedure TzDiagramDataSet.TDbChart.Assign(Source: TPersistent);
var
  src: TDbChart;
begin
  inherited; // setta le ereditate

  if Source is TDbChart then
  begin
    src := TDbChart(Source);
    ChartID := src.ChartID;
  end;
end;

function TzDiagramDataSet.TDbChart.zComponentType: TzComponentType;
begin
  result := ctChart;
end;

function TzDiagramDataSet.TDbChart.GetChartID: string;
begin
  result := ChartID;

  if result = '' then
    result := GetDataSetID;
end;

procedure TzDiagramDataSet.TDbChart.NameChanged(const NewName, OldName: string);
var
  Props: TzDbChartProps;
  OldID: string;
begin
  inherited;

  // Con ChartID esplicito la chiave non dipende dal nome del dataset
  if ChartID <> '' then
    Exit;

  if not assigned(Base) then
    Exit;

  // Le props sono ancora sotto l'identificativo calcolato con il nome vecchio
  // del dataset: stessa regola di GetDataSetID
  if Name = zDiagramDataSet.Name then
    OldID := zDiagramDataSet.DataModule.Name + '.' + OldName
  else
    OldID := ValidateComponentName('chart' + OldName + '_' + Name);

  if SameText(OldID, GetChartID) then
    Exit;

  Props := Base.zDbCharts.get(OldID, False);

  if assigned(Props) then
  begin
    Props.Name := GetChartID;
    Props.DataSet := GetDataSetID;
  end;
end;

procedure TzDiagramDataSet.TDbChart.SetReadOnly(const ReadOnly: boolean);
begin
  // il grafico non modifica i record: non c'e' niente da impostare
end;

function TzDiagramDataSet.TDbChart.zDbChartProps(const CreateIfNotExists: boolean = False): TzDbChartProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  // Le props si chiamano come l'identificativo usato dal componente
  // (ChartID, per difetto Modulo.DataSet), non come la voce del diagramma
  Idx := Base.zDbCharts.IndexOf(GetChartID);

  if Idx <> -1 then
    result := Base.zDbCharts[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbCharts.Add;
      result.Name := GetChartID;
      result.DataSet := GetDataSetID;
    end;
end;

{ TzDiagramDataSet.TDbCharts }

function TzDiagramDataSet.TDbCharts.Add: TDbChart;
begin
  result := TDbChart(inherited Add);
end;

function TzDiagramDataSet.TDbCharts.GetItem(Index: integer): TDbChart;
begin
  result := TDbChart(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbCharts.Insert(Index: integer): TDbChart;
begin
  result := TDbChart(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbCharts.SetItem(Index: integer; const Value: TDbChart);
begin
  Items[Index].Assign(Value);
end;

{ TzDiagramDataSet.TDbScheduler }

constructor TzDiagramDataSet.TDbScheduler.Create(Collection: TCollection);
begin
  inherited;
  FSchedulerID := '';
end;

procedure TzDiagramDataSet.TDbScheduler.Assign(Source: TPersistent);
var
  src: TDbScheduler;
begin
  inherited; // setta le ereditate

  if Source is TDbScheduler then
  begin
    src := TDbScheduler(Source);
    SchedulerID := src.SchedulerID;
  end;
end;

function TzDiagramDataSet.TDbScheduler.zComponentType: TzComponentType;
begin
  result := ctScheduler;
end;

function TzDiagramDataSet.TDbScheduler.GetSchedulerID: string;
begin
  result := SchedulerID;

  if result = '' then
    result := GetDataSetID;
end;

procedure TzDiagramDataSet.TDbScheduler.NameChanged(const NewName, OldName: string);
var
  Props: TzDbSchedulerProps;
  OldID: string;
begin
  inherited;

  // Con SchedulerID esplicito la chiave non dipende dal nome del dataset
  if SchedulerID <> '' then
    Exit;

  if not assigned(Base) then
    Exit;

  // Le props sono ancora sotto l'identificativo calcolato con il nome vecchio
  // del dataset: stessa regola di GetDataSetID
  if Name = zDiagramDataSet.Name then
    OldID := zDiagramDataSet.DataModule.Name + '.' + OldName
  else
    OldID := ValidateComponentName('scheduler' + OldName + '_' + Name);

  if SameText(OldID, GetSchedulerID) then
    Exit;

  Props := Base.zDbSchedulers.get(OldID, False);

  if assigned(Props) then
  begin
    Props.Name := GetSchedulerID;
    Props.DataSet := GetDataSetID;
  end;
end;

procedure TzDiagramDataSet.TDbScheduler.SetReadOnly(const ReadOnly: boolean);
var
  Props: TzDbSchedulerProps;
begin
  Props := zDbSchedulerProps(true);

  if assigned(Props) then
    Props.Flags.ReadOnly := ReadOnly;
end;

function TzDiagramDataSet.TDbScheduler.zDbSchedulerProps(const CreateIfNotExists: boolean = False): TzDbSchedulerProps;
var
  Idx: integer;
begin
  result := nil;

  if not assigned(Base) then
    Exit;

  // Le props si chiamano come l'identificativo usato dal componente
  // (SchedulerID, per difetto Modulo.DataSet), non come la voce del diagramma
  Idx := Base.zDbSchedulers.IndexOf(GetSchedulerID);

  if Idx <> -1 then
    result := Base.zDbSchedulers[Idx]
  else
    if CreateIfNotExists then
    begin
      result := Base.zDbSchedulers.Add;
      result.Name := GetSchedulerID;
      result.DataSet := GetDataSetID;
    end;
end;

{ TzDiagramDataSet.TDbSchedulers }

function TzDiagramDataSet.TDbSchedulers.Add: TDbScheduler;
begin
  result := TDbScheduler(inherited Add);
end;

function TzDiagramDataSet.TDbSchedulers.GetItem(Index: integer): TDbScheduler;
begin
  result := TDbScheduler(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbSchedulers.Insert(Index: integer): TDbScheduler;
begin
  result := TDbScheduler(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbSchedulers.SetItem(Index: integer; const Value: TDbScheduler);
begin
  Items[Index].Assign(Value);
end;

constructor TzDiagramDataSet.TGisMap.Create(Collection: TCollection);
begin
  inherited;
end;

procedure TzDiagramDataSet.TGisMap.Assign(Source: TPersistent);
var
  src: TGisMap;
begin
  inherited; // setta  ereditate

  if Source is TGisMap then
  begin
    src := TGisMap(Source);
  end;
end;

function TzDiagramDataSet.TGisMap.zComponentType: TzComponentType;
begin
  result := ctMap;
end;

constructor TzDiagramDataSet.TDbFile.Create(Collection: TCollection);
begin
  inherited;
  FID := '';
  FFieldName := 'FULL_FILE_NAME';
  FFieldNameOID := '';
  FFileTypes := zAllFileTypes;
end;

procedure TzDiagramDataSet.TDbFile.Assign(Source: TPersistent);
var
  src: TDbFile;

begin
  inherited; // setta  ereditate

  if Source is TDbFile then
  begin
    src := TDbFile(Source);
    self.FieldName := src.FieldName;
    self.FieldNameOID := src.FieldNameOID;
    self.FileTypes := src.FileTypes;
  end;
end;

function TzDiagramDataSet.TDbFile.zComponentType: TzComponentType;
begin
  result := ctFile;
end;

function TzDiagramDataSet.TDbFile.GetID: string;
begin
  result := ID;

  if result = '' then
    result := GetDataSetID;
end;

constructor TzDiagramDataSet.TzDiagramCtrls.Create(ItemClass: TCollectionItemClass;

const aName: string; aImageIndex: integer;

const azDiagramDataSet: TzDiagramDataSet);
begin
  inherited Create(ItemClass, aName, aImageIndex, nil);
  FzDiagramDataSet := azDiagramDataSet;
  Sorted := False;
end;

procedure TzDiagramDataSet.TzDiagramCtrls.NameChanged(const NewName, OldName: string);
var
  i: integer;
begin

  if NewName <> '' then
    for i := 0 to count - 1 do
      TzDiagramCtrl(Items[i]).NameChanged(NewName, OldName);
end;

function TzDiagramDataSet.TzDiagramCtrls.VisibleCount: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to count - 1 do
    if TzDiagramCtrl(Items[i]).Visible then
      Inc(result);
end;

function TzDiagramDataSet.TDbViews.Add: TDbView;
begin
  result := TDbView(inherited Add);
end;

function TzDiagramDataSet.TDbViews.GetItem(Index: integer): TDbView;
begin
  result := TDbView(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbViews.Insert(Index: integer): TDbView;
begin
  result := TDbView(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbViews.SetItem(Index: integer;

const Value: TDbView);
begin
  Items[Index].Assign(Value);
end;

function TzDiagramDataSet.TDbCards.Add: TDbCard;
begin
  result := TDbCard(inherited Add);
end;

function TzDiagramDataSet.TDbCards.GetItem(Index: integer): TDbCard;
begin
  result := TDbCard(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbCards.Insert(Index: integer): TDbCard;
begin
  result := TDbCard(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbCards.SetItem(Index: integer;

const Value: TDbCard);
begin
  Items[Index].Assign(Value);
end;

function TzDiagramDataSet.TDbPivots.Add: TDbPivot;
begin
  result := TDbPivot(inherited Add);
end;

function TzDiagramDataSet.TDbPivots.GetItem(Index: integer): TDbPivot;
begin
  result := TDbPivot(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbPivots.Insert(Index: integer): TDbPivot;
begin
  result := TDbPivot(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbPivots.SetItem(Index: integer; const Value: TDbPivot);
begin
  Items[Index].Assign(Value);
end;

function TzDiagramDataSet.TDbFiles.Add: TDbFile;
begin
  result := TDbFile(inherited Add);
end;

function TzDiagramDataSet.TDbFiles.GetItem(Index: integer): TDbFile;
begin
  result := TDbFile(inherited Items[Index]);
end;

function TzDiagramDataSet.TDbFiles.Insert(Index: integer): TDbFile;
begin
  result := TDbFile(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TDbFiles.SetItem(Index: integer;

const Value: TDbFile);
begin
  Items[Index].Assign(Value);
end;

function TzDiagramDataSet.TGisMaps.Add: TGisMap;
begin
  result := TGisMap(inherited Add);
end;

function TzDiagramDataSet.TGisMaps.GetItem(Index: integer): TGisMap;
begin
  result := TGisMap(inherited Items[Index]);
end;

function TzDiagramDataSet.TGisMaps.Insert(Index: integer): TGisMap;
begin
  result := TGisMap(inherited Insert(Index));
end;

procedure TzDiagramDataSet.TGisMaps.SetItem(Index: integer;

const Value: TGisMap);
begin
  Items[Index].Assign(Value);
end;

constructor TzLayoutItem.Create(Collection: TCollection);
begin
  inherited;
  // base
  FGeneratedByController := False;
  FItemClassKind := ickLayoutItem;
  FIsUserDefined := False;
  FIdx := 0;
  FAlignHorz := ahParentManaged;
  FAlignVert := avParentManaged;
  FWidth := 0;
  FHeight := 0;
  FCaption := '';
  FCaptionVisible := true;
  FCaptionAlignHorz := taLeftJustify;
  FCaptionAlignVert := TdxAlignmentVert.tavCenter;
  FEnabled := true;
  FVisible := true;
  FOffsetLeft := 0;
  FOffsetTop := 0;
  FOffsetRight := 0;
  FOffsetBottom := 0;
  FPaddingLeft := 0;
  FPaddingTop := 0;
  FPaddingRight := 0;
  FPaddingBottom := 0;
  FParentName := '';
  // CaptionOptions comuni
  FImageIndex := -1;
  FVisibleElements := [cveImage, cveText];
  // TdxLayoutItem specifico
  FItemCaptionLayout := clTop;
  FItemCaptionWidth := 0;
  // TdxLayoutGroup specifico
  FGroupHidden := False;
  FGroupLayoutDirection := ldVertical;
  FGroupExpanded := true;
  FGroupShowBorder := False;
  FGroupHideTabs := true;
  FGroupShowTabFrame := False;
  FGroupShowExpandButton := False;
  FGroupButtonOptionsAlignment := gbaRight;
  FGroupButtonOptionsVisible := true;
  FGroupItemIndex := 0;
  FGroupUseIndent := true;
  FGroupLocked := False;
  FGroupLayoutLookAndFeelException := False;
  FGroupItemControlAreaAlignment := catDefault;
  FGroupTabbedTabPosition := tpTop;
  FGroupTabbedMultiLine := False;
  FGroupTabbedRotate := False;
  FGroupTabbedTabHeight := 0;
  FGroupTabbedTabWidth := 0;
  FGroupTabbedHotTrack := False;
  FScrollOptionsHorizontal := smNone;
  FScrollOptionsVertical := smNone;
  // TdxLayoutSplitterItem specifico
  FSplitterAllowCloseOnClick := False;
  FSplitterIsClosed := False;
end;

procedure TzLayoutItem.Assign(Source: TPersistent);
var
  ItemProps: TzLayoutItem;
begin
  if Source is TzLayoutItem then
  begin
    ItemProps := TzLayoutItem(Source);
    // base
    Name := ItemProps.Name;
    ItemClassKind := ItemProps.ItemClassKind;
    IsUserDefined := ItemProps.IsUserDefined;
    Idx := ItemProps.Idx;
    AlignHorz := ItemProps.AlignHorz;
    AlignVert := ItemProps.AlignVert;
    Width := ItemProps.Width;
    Height := ItemProps.Height;
    Caption := ItemProps.Caption;
    CaptionVisible := ItemProps.CaptionVisible;
    CaptionAlignHorz := ItemProps.CaptionAlignHorz;
    CaptionAlignVert := ItemProps.CaptionAlignVert;
    Enabled := ItemProps.Enabled;
    Visible := ItemProps.Visible;
    OffsetLeft := ItemProps.OffsetLeft;
    OffsetTop := ItemProps.OffsetTop;
    OffsetRight := ItemProps.OffsetRight;
    OffsetBottom := ItemProps.OffsetBottom;
    PaddingLeft := ItemProps.PaddingLeft;
    PaddingTop := ItemProps.PaddingTop;
    PaddingRight := ItemProps.PaddingRight;
    PaddingBottom := ItemProps.PaddingBottom;
    ParentName := ItemProps.ParentName;
    GeneratedByController := ItemProps.GeneratedByController;
    // CaptionOptions comuni
    ImageIndex := ItemProps.ImageIndex;
    VisibleElements := ItemProps.VisibleElements;
    // TdxLayoutItem specifico
    ItemCaptionLayout := ItemProps.ItemCaptionLayout;
    ItemCaptionWidth := ItemProps.ItemCaptionWidth;
    // TdxLayoutGroup specifico
    GroupHidden := ItemProps.GroupHidden;
    GroupLayoutDirection := ItemProps.GroupLayoutDirection;
    GroupExpanded := ItemProps.GroupExpanded;
    GroupShowBorder := ItemProps.GroupShowBorder;
    GroupHideTabs := ItemProps.GroupHideTabs;
    GroupShowTabFrame := ItemProps.GroupShowTabFrame;
    GroupShowExpandButton := ItemProps.GroupShowExpandButton;
    GroupButtonOptionsAlignment := ItemProps.GroupButtonOptionsAlignment;
    GroupButtonOptionsVisible := ItemProps.GroupButtonOptionsVisible;
    GroupItemIndex := ItemProps.GroupItemIndex;
    GroupUseIndent := ItemProps.GroupUseIndent;
    GroupLocked := ItemProps.GroupLocked;
    GroupLayoutLookAndFeelException := ItemProps.GroupLayoutLookAndFeelException;
    GroupItemControlAreaAlignment := ItemProps.GroupItemControlAreaAlignment;
    GroupTabbedTabPosition := ItemProps.GroupTabbedTabPosition;
    GroupTabbedMultiLine := ItemProps.GroupTabbedMultiLine;
    GroupTabbedRotate := ItemProps.GroupTabbedRotate;
    GroupTabbedTabHeight := ItemProps.GroupTabbedTabHeight;
    GroupTabbedTabWidth := ItemProps.GroupTabbedTabWidth;
    GroupTabbedHotTrack := ItemProps.GroupTabbedHotTrack;
    ScrollOptionsHorizontal := ItemProps.ScrollOptionsHorizontal;
    ScrollOptionsVertical := ItemProps.ScrollOptionsVertical;
    // TdxLayoutSplitterItem specifico
    SplitterAllowCloseOnClick := ItemProps.SplitterAllowCloseOnClick;
    SplitterIsClosed := ItemProps.SplitterIsClosed;
  end
  else
    inherited;
end;

function TzLayoutItem.GetDisplayName: string;
begin
  result := Name;
end;

constructor TzDataModule.TControllerOptions.Create;
begin
  inherited;
  FCreateDefaultLayout := true;
  FTreeMenuVisible := true;
  FTreeMenuSearchVisible := False;
  FTreeMenuAutoExpand := False;
  FUsePageControl := False;
end;

procedure TzDataModule.TControllerOptions.Assign(Source: TPersistent);
var
  src: TzDataModule.TControllerOptions;
begin
  if Source is TzDataModule.TControllerOptions then
  begin
    src := TzDataModule.TControllerOptions(Source);
    self.CreateDefaultLayout := src.CreateDefaultLayout;
    self.TreeMenuVisible := src.TreeMenuVisible;
    self.TreeMenuSearchVisible := src.TreeMenuSearchVisible;
    self.TreeMenuAutoExpand := src.TreeMenuAutoExpand;
    self.UsePageControl := src.UsePageControl;
  end;
end;

{ TzDataModule.TFormOptions }

constructor TzDataModule.TFormOptions.Create;
begin
  FCaption := '';
  FHelpType := htContext;
  FHelpContext := 0;
  FHelpKeyword := '';
  FHelpFileName := '';
  FReportGroup := '';
  FAIDefaultSensitivity := slNone;
end;

procedure TzDataModule.TFormOptions.Assign(Source: TPersistent);
var
  src: TzDataModule.TFormOptions;
begin
  if Source is TzDataModule.TFormOptions then
  begin
    src := TzDataModule.TFormOptions(Source);
    self.Caption := src.Caption;
    self.HelpType := src.HelpType;
    self.HelpContext := src.HelpContext;
    self.HelpKeyword := src.HelpKeyword;
    self.HelpFileName := src.HelpFileName;
    self.ReportGroup := src.ReportGroup;
    self.AIDefaultSensitivity := src.AIDefaultSensitivity;
  end;
end;

function TzDataModule.TFormOptions.GetHelpFileName: String;
begin
  result := FHelpFileName;

  if result.IsEmpty then
    result := Caption;
end;

constructor TLoginParams.Create(aSecurity: TzSecurity);
begin
  inherited Create;
  Assert(assigned(aSecurity));
  zSecurity := aSecurity;
  FAuthorizations := TStringList.Create;
  FAutorunActions := TStringList.Create;
  FHyperlinks := TStringList.Create;
  Clear;
end;

destructor TLoginParams.Destroy;
begin
  FreeAndNil(FAuthorizations);
  FreeAndNil(FAutorunActions);
  FreeAndNil(FHyperlinks);
  inherited;
end;

function TLoginParams.Authorizhed(const Authorization: string): boolean;
begin
  result := Authorizations.IndexOf(Authorization) <> -1;
end;

procedure TLoginParams.Autorun(Actions: TActionList);
var
  Action: TContainedAction;
begin
  Assert(assigned(Actions));

  for Action in Actions do
    if Action.Visible then
      if Action.Enabled then
        if AutorunActions.IndexOf(Action.Caption.ToUpper) <> -1 then
          Action.Execute;
end;

procedure TLoginParams.Clear;
begin
  FConnectionName := '';
  FLoggedIn := False;
  FPasswordExpired := False;
  FSecondiAllaVerificaAccesso := 0;
  FSessionID := -1;
  FUserDisplayName := '';
  FUserID := -1;
  FUserName := '';
  FUserPassword := '';
  FUserRole := '';
  FUserCanCreateUser := False;
  FUserCanEditRestrictions := False;
  FUserCanEditHelp := False;
  FUserIsAdmin := False;
  FAuthorizations.Clear;
  FAutorunActions.Clear;
  FHyperlinks.Clear;
end;

procedure TLoginParams.PasswordChanged(const NewPassword: string);
begin
  FPasswordExpired := False;
  FUserPassword := NewPassword;
end;

procedure TLoginParams.SetParams(const aConnectionName, aUserName: String);
begin
  Clear;
  FLoggedIn := true;
  FConnectionName := aConnectionName;
  FUserName := aUserName;
end;

procedure TLoginParams.SetParams(const aConnectionName, aUserName, aUserPassword: String; const aSessionId, aUserId: integer; aUserDisplayName: String; aPasswordExpireDate: TDateTime;
IsAdmin, CanCreateUser, CanEditRestrictions, CanEditHelp: boolean);
begin
  Clear;

  FLoggedIn := true;
  FConnectionName := aConnectionName;
  FSessionID := aSessionId;
  FUserName := aUserName;
  FUserID := aUserId;
  FUserDisplayName := aUserDisplayName;
  FUserFolder := aUserName;
  // folder
  FUserRole := '';
  FUserPassword := aUserPassword;
  FPasswordExpireDate := aPasswordExpireDate;
  FPasswordExpired := PasswordExpireDate <= date;
  FUserIsAdmin := IsAdmin;
  FUserCanCreateUser := CanCreateUser;
  FUserCanEditRestrictions := CanEditRestrictions;
  FUserCanEditHelp := CanEditHelp;
end;

procedure TLoginParams.SetVerificaAccesso(const Secondi: integer);
begin
  FSecondiAllaVerificaAccesso := Secondi;
end;

procedure TLoginParams.SetPermessiSistema(const CanCreateUser, CanEditRestrictions, CanEditHelp: boolean);
begin
  FUserCanCreateUser := CanCreateUser;
  FUserCanEditRestrictions := CanEditRestrictions;
  FUserCanEditHelp := CanEditHelp;
end;

procedure TLoginParams.SetUserIsAdmin(const Value: boolean);
begin
  FUserIsAdmin := Value;
end;

function TzSystem.Authorizhed(const Authorization: string; const TrueIdAdmin: boolean = true): boolean;
begin
  result := zSecurity.LoginParams.Authorizhed(Authorization);

  if not result then
    if TrueIdAdmin then
      result := IsAdmin;
end;

procedure TzSystem.Autorun(Actions: TActionList);
begin
  zSecurity.LoginParams.Autorun(Actions);
end;

procedure TzSystem.CheckAdmin;
var
  Pwd: string;
begin
  if IsAdmin then
    Exit;

  Pwd := '';
  if zMsg.InputPassword('IsAdmin', 'Password', Pwd) then
    if AdminPasswordOk(Pwd) then
      zSecurity.IsAdmin := true;
end;

function TzSystem.Config(const Name: string; default: string): string;
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_CONFIG_SETTINGS_GET_VALUE);
  try
    sp.Prepare;
    sp.ParamByName('SETTING').AsString := Name;
    sp.ParamByName('DEFAULT_VALUE').AsString := default;
    sp.ExecProc;
    result := sp.ParamByName('VALORE').AsString;
  finally
    FreeAndNil(sp);
  end;
end;

function TzSystem.ConfigExists(const Name: string; const TrueIdAdmin: boolean = true): boolean;
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_CONFIG_SETTINGS_EXISTS);
  try
    sp.Prepare;
    sp.ParamByName('SETTING').AsString := Name;
    sp.ExecProc;
    result := sp.ParamByName('SETTING_EXISTS').AsBoolean;
  finally
    FreeAndNil(sp);
  end;

  if not result then
    if TrueIdAdmin then
      result := IsAdmin;
end;

function TzSystem.GetIsAdmin: boolean;
begin
  result := zSecurity.IsAdmin and (not IsAdminDisabled);
end;

procedure TzSystem.ResetAdmin;
begin
  zSecurity.IsAdmin := False;
end;

procedure TzSystem.SetModified(const Value: boolean);
begin
  FModified := Value;
end;

procedure TzSystem.SetzDbPivots(const Value: TzDbPivots);
begin
  FzDbPivots.Assign(Value);
end;

procedure TzSystem.SetzDbRecordViews(const Value: TzDbRecordViews);
begin
  FzDbRecordViews.Assign(Value);
end;

procedure TzSystem.SetzDbTrees(const Value: TzDbTrees);
begin
  FzDbTrees.Assign(Value);
end;

procedure TzSystem.SetzDbCharts(const Value: TzDbCharts);
begin
  FzDbCharts.Assign(Value);
end;

procedure TzSystem.SetzDbSchedulers(const Value: TzDbSchedulers);
begin
  FzDbSchedulers.Assign(Value);
end;

function TzSystem.ConfigFileName(Ext: string): string;
begin
  result := '';

  if zSecurity.LoggedIn then
    result := ConfigFolder + ChangeFileExt(ExtractFileName(application.exename), Ext);
end;

function TzSystem.CurrentUser: string;
begin
  result := zSecurity.LoginParams.UserName;
end;

function TzSystem.Folder(const Name: string; defaultFolder: string): string;
var
  sp: TFDStoredProc;
begin
  result := defaultFolder;

  if not FolderCache.TryGetValue(Name, result) then
  begin

    try
      sp := CreateStoredProc(spUSR_FOLDERS_GET_VALUE);
      try
        sp.Prepare;
        sp.ParamByName('SETTING').AsString := Name;
        sp.ParamByName('COMPUTER_NAME').AsString := ComputerName;
        sp.ParamByName('DEFAULT_FOLDER').AsString := defaultFolder;
        sp.ExecProc;
        result := sp.ParamByName('FOLDER').AsString;
      finally
        FreeAndNil(sp);
      end;
    except
      result := defaultFolder; // già assegnato, ma esplicito
    end;

    // Cache sempre, anche in caso di errore o risultato vuoto
    FolderCache.Add(Name, result);
  end;

  if result.IsEmpty then
    result := defaultFolder;
end;

procedure TzSystem.ForceAdmin(const Admin: boolean);
begin
  zSecurity.IsAdmin := Admin;
end;

function TzSystem.GetCanCreateUser: boolean;
begin
  result := zSecurity.LoginParams.UserCanCreateUser or zSecurity.IsAdmin;
end;

function TzSystem.GetCanEditRestrictions: boolean;
begin
  result := zSecurity.LoginParams.UserCanEditRestrictions or zSecurity.IsAdmin;
end;

function TzSystem.GetConfigs(const Name: string): string;
begin
  result := Config(Name, '');
  siMain.LogString('TzSystem.GetConfigs: ' + Name, result);
end;

function TzSystem.GetFolders(const Name: string): string;
begin
  result := Folder(Name, '');
  siMain.LogString('TzSystem.GetFolders: ' + Name, result);
end;

function TzSystem.GetLookup(const IdLookup: string; DataSet: TzFbDataSet; const KeyField: String = ''; const ListFields: string = ''): TzLookup;
begin
  Assert(assigned(DataSet));

  if not IdLookup.IsEmpty then
    result := zLookups.get(IdLookup, true)
  else
    result := zLookups.get(DataSet.idDataSet, true);

  if result.IsNew then
  begin

    if not IdLookup.IsEmpty then
      result.Name := IdLookup
    else
      result.Name := DataSet.idDataSet;

    result.DataSet := DataSet.idDataSet;
    result.DbView := DataSet.idDataSet;

    if KeyField.IsEmpty then
      result.KeyField := DataSet.PrimaryKeyFields
    else
      result.KeyField := KeyField;

    if ListFields.IsEmpty then
      result.DisplayColumns := result.KeyField
    else
      result.DisplayColumns := ListFields;

    result.IsForeignKey := False; // altrimenti viene eliminato da aggiorna cache

    // ZZ 21.01.2019
    Base.Modified := true;
  end
  else
  begin
    if result.KeyField.IsEmpty then
    begin
      if KeyField.IsEmpty then
        result.KeyField := DataSet.PrimaryKeyFields
      else
        result.KeyField := KeyField;
    end;

    if result.DisplayColumns.IsEmpty then
    begin
      if ListFields.IsEmpty then
        result.DisplayColumns := result.KeyField
      else
        result.DisplayColumns := ListFields;
    end;
  end;
end;

function TzSystem.GetSettings(const Name: string): string;
begin
  result := Setting(Name, '');
  siMain.LogString('TzSystem.GetSettings: ' + Name, result);
end;

function TzSystem.PersonalFolder: string;
begin
  result := '';
  // usato da FormController, main.ConfigurazioneLog

  if not zSecurity.LoggedIn then
    Exit;

  result := Root_PersonalData;
  result := IncludeTrailingPathDelimiter(result + zSecurity.LoginParams.UserFolder);

  try
    ForceDirectories(result);
  except
    on e: Exception do
      application.HandleException(e);
  end;
end;

procedure TzSystem.SetConfigs(const Name: string; const Value: string);
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_CONFIG_SETTINGS_SET_VALUE);
  try
    sp.Prepare;
    sp.ParamByName('SETTING').AsString := Name;
    sp.ParamByName('VALORE').AsString := Value;
    sp.ExecProc;
  finally
    FreeAndNil(sp);
  end;
end;

procedure TzSystem.SetFolders(const Name: string; const Value: string);
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_FOLDERS_SET_VALUE);
  try
    sp.Prepare;
    sp.ParamByName('SETTING').AsString := Name;
    sp.ParamByName('COMPUTER_NAME').Clear;
    // user corrente
    sp.ParamByName('FOLDER').AsString := Value;
    sp.ExecProc;
  finally
    FreeAndNil(sp);
  end;
end;

procedure TzSystem.SetSettings(const Name: string; const Value: string);
var
  sp: TFDStoredProc;
begin
  // Mantis #142 - 2026-09-21: scrive solo se il valore cambia davvero, per non
  // riscrivere ad ogni avvio la riga globale USR_SETTINGS e provocare il conflitto
  // di aggiornamento concorrente fra utenti che avviano l'applicazione insieme
  if Setting(Name, '') = Value then
    Exit;

  sp := CreateStoredProc(spUSR_UTENTI_SETTINGS_SET_VALUE);
  try
    sp.Prepare;
    sp.ParamByName('USER_ID').Clear; // user corrente
    sp.ParamByName('SETTING').AsString := Name;
    sp.ParamByName('VALORE').AsString := Value;
    sp.ExecProc;
  finally
    FreeAndNil(sp);
  end;
end;

procedure TzSystem.SetSkinName(const Value: string);
begin
  Settings['Skin'] := Value;

  // Mantis #286 - 2026-10-26: un .login non scrivibile non deve dare errore
  TzSecurity.ScriviFileLogin('Skin', Value);
end;

function TzSystem.GetSkinName: string;
begin
  result := Settings['Skin'];
end;

procedure TzSystem.SetzMaps(const Value: TzMaps);
begin
  FzMaps.Assign(Value);
end;

constructor TzDiagramDataSet.TReportProps.Create;
begin
  inherited;
  FPipeName := '';
  FReportGroup := '';
  FSharedReports := TStringList.Create;
end;

destructor TzDiagramDataSet.TReportProps.Destroy;
begin
  FreeAndNil(FSharedReports);
  inherited;
end;

procedure TzDiagramDataSet.TReportProps.Assign(Source: TPersistent);
var
  src: TReportProps;
begin
  if Source is TReportProps then
  begin
    src := TReportProps(Source);
    FReportGroup := src.ReportGroup;
    FPipeName := src.PipeName;
    FSharedReports.Assign(src.SharedReports);
  end
  else
    inherited;
end;

procedure TzDiagramDataSet.TReportProps.SetSharedReports(const Value: TStrings);
begin
  FSharedReports.Assign(Value);
end;

constructor TzColumn.Create(Collection: TCollection);
begin
  inherited;
  FFieldOrigin := '';
  FooterValue := Null;
  FDomainName := '';
  FGroupIndex := -1;
  FDateTimeGrouping := dtgDefault;
  FSortOrder := soNone;
  FCaption := '';
  FReadOnly := true;
  FWidth := -1;
  FVisible := true;
  FFooterKind := skNone;
  FGroupFooterKind := skNone;
  zCtrlType := ctDefault;
end;

procedure TzColumn.Assign(Source: TPersistent);
var
  Item: TzColumn;
begin
  inherited;
  if Source is TzColumn then
  begin
    Item := Source as TzColumn;
    Name := Item.Name;
    FieldOrigin := Item.FieldOrigin;
    CopyDomainFrom(Item);
    Caption := Item.FCaption; // campo, non prop
    FooterKind := Item.FooterKind;
    GroupIndex := Item.GroupIndex;
    DateTimeGrouping := Item.DateTimeGrouping;
    SortOrder := Item.SortOrder;
    GroupFooterKind := Item.GroupFooterKind;
    ReadOnly := Item.ReadOnly;
    Width := Item.Width;
    Visible := Item.Visible;
    zCtrlType := Item.FzCtrlType; // campo, non prop
  end;
end;

procedure TzColumn.ClearFooterValue;
begin
  FooterValue := Null;
end;

function TzColumn.GetDomain: TzDomain;
begin
  result := nil;

  if FDomainName.IsEmpty then
    Exit;

  if not assigned(Base) then
    Exit;

  // Riusato finche' il dizionario non cambia; dopo un ricaricamento (o una
  // qualunque aggiunta, rimozione o rinomina di domini) si cerca di nuovo per
  // nome e si ottiene il dominio nuovo con lo stesso nome, o nil se non esiste piu'
  if FDomainCacheValid
    and (FDomainCacheDictionary = Base.zDataDictionary)
    and (FDomainCacheGeneration = TzDomains.Generation) then
    Exit(FDomainCache);

  result := Base.zDataDictionary.Get(FDomainName, False);

  FDomainCache := result;
  FDomainCacheDictionary := Base.zDataDictionary;
  FDomainCacheGeneration := TzDomains.Generation;
  FDomainCacheValid := true;
end;

procedure TzColumn.SetDomain(const Value: TzDomain);
begin
  if assigned(Value) then
    FDomainName := Value.Name
  else
    FDomainName := '';

  FDomainCacheValid := False;
end;

procedure TzColumn.CopyDomainFrom(Source: TzColumn);
begin
  FDomainName := Source.FDomainName;
  FDomainCache := Source.FDomainCache;
  FDomainCacheDictionary := Source.FDomainCacheDictionary;
  FDomainCacheGeneration := Source.FDomainCacheGeneration;
  FDomainCacheValid := Source.FDomainCacheValid;
end;

function TzColumn.GetCaption: string;
begin
  result := FCaption;

  if result = '' then
    if assigned(Domain) then
      result := Domain.DisplayLabel;
end;

function TzColumn.GetzCtrlType: TzCtrlType;
begin
  result := FzCtrlType;

  if result = ctDefault then
    if assigned(Domain) then
      result := Domain.zCtrlType;
end;

function TzColumn.isCaptionStored: boolean;
begin
  result := FCaption <> '';
end;

function TzColumn.IsCtrlTypeStored: boolean;
begin
  result := FzCtrlType <> ctDefault;
end;

{ TzColumns }

constructor TzColumns.Create(azDbViewProps: TzDbViewProps);
begin
  inherited Create(TzColumn, 'Columns', -1, nil);
  zDbViewProps := azDbViewProps;
  Sorted := False;
end;

procedure TzColumns.AssignFromGridColumns(const idDataSet: string; View: TcxGridDBTableView; const ViewID: string);
var
  i: integer;
  column: TcxGridDBColumn;
  backup: TzColumns;
  Item: TzColumn;
  bkItem: TzColumn;
  GridCaption: string;
  OverrideCaption: string;
  DomainCaption: string;
  BackupDomain: TzDomain;
begin
  backup := TzColumns.Create(nil);
  try
    CheckEmptyCaptions; // 10.09.2024

    backup.Assign(self);

    Clear;

    for i := 0 to View.ColumnCount - 1 do
    begin
      column := TcxGridDBColumn(View.Columns[i]);
      Item := Add;
      Item.Name := column.DataBinding.FieldName;
      // Caption dalla griglia: sarà filtrata sotto
      Item.Caption := View.Columns[i].Caption;
      Item.FooterKind := View.Columns[i].Summary.FooterKind;
      Item.GroupIndex := View.Columns[i].GroupIndex;
      Item.DateTimeGrouping := View.Columns[i].DateTimeGrouping;
      Item.GroupFooterKind := View.Columns[i].Summary.GroupFooterKind;
      Item.Index := View.Columns[i].Index;
      Item.Width := View.Columns[i].Width;
      Item.Visible := View.Columns[i].Visible;
    end;

    CheckEmptyCaptions; // 10.09.2024

    // riassegna readonly e zCtrlType; filtra caption
    for bkItem in backup do
    begin
      Item := get(bkItem.Name, False);

      if assigned(Item) then
      begin
        Item.ReadOnly := bkItem.ReadOnly;
        // Mantis #161 - 2026-09-30: campo, non proprieta', come in
        // TzColumn.Assign. Ora che il Domain resta agganciato, la proprieta'
        // restituirebbe il tipo di controllo del dominio e lo fisserebbe sulla
        // colonna come se fosse una scelta fatta sulla vista.
        Item.zCtrlType := bkItem.FzCtrlType;
        // Le colonne vengono ricreate dalla griglia: senza questa riga
        // ripartono senza Domain e il primo AssignToGridColumns successivo
        // (EditProps) ricadrebbe su CapFirst(Name). Si copia anche il dominio
        // gia' risolto, per non cercarlo di nuovo nel dizionario.
        Item.CopyDomainFrom(bkItem);
        // L'ordine resta quello del dizionario, non quello della griglia:
        // un clic sull'intestazione per riordinare e' una consultazione, e
        // non deve diventare l'ordine di partenza per tutti quando un
        // amministratore salva la vista.
        Item.SortOrder := bkItem.SortOrder;

        GridCaption := Item.Caption;
        OverrideCaption := Overrides.CaptionGrid(idDataSet, Item.Name);

        if not OverrideCaption.IsEmpty then
          // La caption in griglia corrisponde all'override: non salvare nulla (l'override prevale)
          Item.Caption := ''
        else
        begin
          // Determina la caption del domain per confronto
          DomainCaption := '';
          BackupDomain := bkItem.Domain;
          if assigned(BackupDomain) then
            DomainCaption := BackupDomain.DisplayLabel;

          if SameText(GridCaption, DomainCaption) then
            // Uguale al domain: non salvare (il domain è già il default)
            Item.Caption := ''
          else
            // Personalizzazione reale: mantieni quella del backup se non cambiata.
            // Mantis #161 - 2026-09-30: campo, non proprieta': con il Domain
            // agganciato la proprieta' restituirebbe l'etichetta del dominio e
            // la salverebbe sulla vista come personalizzazione.
            Item.Caption := bkItem.FCaption;
        end;
      end;
    end;
  finally
    FreeAndNil(backup);
  end;
end;

procedure TzColumns.AssignToGridColumns(const idDataSet: string; View: TcxGridDBTableView; const ViewID: string);
var
  Caption: string;
  i: integer;
  column: TcxGridDBColumn;
  Item: TzColumn;
begin
  if count = 0 then
    Exit;

  CheckEmptyCaptions;

  View.BeginUpdate;
  try
    for Item in self do
    begin
      column := View.GetColumnByFieldName(Item.Name) as TcxGridDBColumn;

      if not assigned(column) then
        Continue;

      // Priorità 1: override cliente
      Caption := Overrides.CaptionGrid(idDataSet, Item.Name);

      if Caption.IsEmpty then
      begin
        // Priorità 2: personalizzazione salvata sulla view (FCaption != '')
        if not Item.FCaption.IsEmpty then
          Caption := Item.FCaption
        else
        begin
          // Priorità 3: domain display label
          if assigned(Item.Domain) then
            Caption := Item.Domain.DisplayLabel;

          // Ultimo fallback
          if Caption.IsEmpty then
            Caption := CapFirst(Item.Name);
        end;
      end;

      column.Caption := Caption;

      //
      column.Visible := Item.Visible;
      column.Index := Item.Index;
      column.Summary.FooterKind := Item.FooterKind;
      // prima di GroupIndex: la griglia raggruppa con l'intervallo gia' giusto
      column.DateTimeGrouping := Item.DateTimeGrouping;
      // solo se dichiarato: soNone lascia l'ordine della query o dell'utente
      if Item.SortOrder <> soNone then
        column.SortOrder := Item.SortOrder;
      column.GroupIndex := Item.GroupIndex;
      column.Summary.GroupFooterKind := Item.GroupFooterKind;

      if Item.Width = -1 then
        column.Width := 100
      else
        column.Width := Item.Width;
    end;
  finally
    View.EndUpdate;
  end;
end;

procedure TzColumns.CheckEmptyCaptions;
var
  col: TzColumn;
begin

  // for col in Self do
  // if not col.Caption.IsEmpty then
  // Exit;

  for col in self do
    if col.Caption.IsEmpty then
      col.Caption := CapFirst(col.Name);
end;

procedure TzColumns.ClearFooterValues;
var
  col: TzColumn;
begin
  for col in self do
    col.ClearFooterValue;
end;

function TzColumns.ComboColumns(DataSet: TzFbDataSet; const MaxColumns: integer): string;
var
  i: integer;
  column: TzColumn;
  Str: TStringList;
begin
  result := '';

  if not assigned(DataSet) then
    Exit;

  ValidateDataset(DataSet);

  Str := TStringList.Create;
  try
    for column in self do
      if Str.count < MaxColumns then
        if column.Visible then
          if assigned(DataSet.FindField(column.Name)) then
            Str.Add(column.Name);

    Str.Delimiter := ';';
    result := Str.DelimitedText;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzColumns.FillTreeList(MasterNode: TcxTreeListNode);
var
  Child: TcxTreeListNode;
  Item: TzColumn;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');
  MasterNode.TreeList.BeginUpdate;
  try
    for Item in self do
    begin
      Child := MasterNode.AddChild;
      Child.Values[0] := Item.DisplayName;
      Child.data := Item;
      Child.ImageIndex := -1;
      Child.SelectedIndex := -1;
    end;
  finally
    MasterNode.TreeList.EndUpdate;
  end;
  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

function TzColumns.GetSelected: string;
var
  Str: TStringList;
  column: TzColumn;
begin
  result := '';

  Str := TStringList.Create;
  try
    for column in self do
      if column.Visible then
      begin
        Str.Add(column.Name + Tab + IntToStr(trunc(column.Width / 10)) + Tab + column.Caption + Tab + zBoolToStr(true) + Tab);
      end;

    result := Str.Text;
  finally
    FreeAndNil(Str);
  end;
end;

function TzColumns.GetVisibleFields: string;
var
  col: TzColumn;
begin
  result := '';
  for col in self do
    if col.Visible then
      result := result + col.Name + ';';
end;

function TzColumns.HasFooter: boolean;
var
  col: TzColumn;
begin
  for col in self do
    if col.FooterKind <> skNone then
      Exit(true);

  result := False;
end;

procedure TzColumns.Reset(DataSet: TzFbDataSet);
begin
  Clear;
  ValidateDataset(DataSet);
end;

procedure TzColumns.ResetColumnCaptions;
var
  col: TzColumn;
begin

  for col in self do
    col.Caption := CapFirst(col.Name);
end;

procedure TzColumns.SetVisibleFields(const Value: string);
var
  Str: TStringList;
  Item: TzColumn;
  i: integer;
  FieldName: string;
begin
  Str := TStringList.Create;
  try
    zSplitStr(Value, ';', Str, true);

    for i := 0 to count - 1 do
      Items[i].Visible := False;

    for i := 0 to Str.count - 1 do
    begin
      FieldName := Str[i];
      Item := get(FieldName);
      if Item.IsNew then
        Item.Name := FieldName;

      Item.Visible := true;
    end;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzColumns.ValidateDataset(DataSet: TzFbDataSet);
var
  Field: TField;
  column: TzColumn;
  i: integer;
  ListEmpty: boolean;
  NewFieldVisible: boolean;
  NewFieldReadOnly: boolean;
begin
  if not assigned(DataSet) then
    Exit;

  BeginUpdate;
  try
    // eliminare i campi non pi� appartenenti al dataset
    for i := count - 1 downto 0 do
    begin
      Items[i].Domain := nil;
      Field := DataSet.FindField(Items[i].Name);

      if not assigned(Field) then
        self.Delete(i)
      else
      begin
        // Mantis #161 - 2026-09-30: il Domain delle colonne che restano va
        // riagganciato, non solo azzerato. TzDbView.InitView chiama questo
        // metodo due volte (Storage.Load, poi CreateColumns): alla seconda le
        // colonne create dalla prima perdevano il Domain, e il successivo
        // LoadFromIni -> AssignToGridColumns, senza didascalia salvata e senza
        // Domain, ripiegava su CapFirst(Name) ("Stato_copertura") coprendo
        // quella giusta appena messa da CreateColumns. Senza creazione: una
        // voce mancante la crea InitFields, qui resta nil e vale il ripiego.
        Items[i].Domain := Base.zDataDictionary.get(DataSet.FieldOrigin(Field), False);

        // Mantis #161 - 2026-09-30: una didascalia salvata uguale a
        // CapFirst(Name) su un nome composto ("Anno_formativo") non e' una
        // personalizzazione: e' lo stesso ripiego, scritto da
        // CheckEmptyCaptions quando il Domain mancava e finito nel dizionario
        // al salvataggio della vista. Si toglie, cosi' torna a valere
        // l'etichetta del dominio. Solo sui nomi composti: su un nome di una
        // parola sola ("Nome") il ripiego e' indistinguibile da una scelta.
        if assigned(Items[i].Domain) then
          if not Items[i].Domain.DisplayLabel.IsEmpty then
            if Pos('_', Items[i].Name) > 0 then
              if SameStr(Items[i].FCaption, CapFirst(Items[i].Name)) then
                Items[i].FCaption := '';
      end;
    end;

    ListEmpty := count = 0;

    // aggiunge i nuovi
    for i := 0 to DataSet.FieldCount - 1 do
      if not self.Exists(DataSet.Fields[i].FieldName) then
      begin
        Field := DataSet.Fields[i];
        column := Add;
        column.Name := Field.FieldName;
        column.FieldOrigin := DataSet.FieldOrigin(Field);
        column.Domain := Base.zDataDictionary.get(column.FieldOrigin, true);

        NewFieldVisible := Field.Visible and ListEmpty;
        NewFieldReadOnly := False;

        if NewFieldVisible then
        begin

          if DataSet.IsDetailParamField(column.Name) then
            NewFieldVisible := False
          else
            // if IndexText(column.Name, ['USER_INS', 'DATA_INS', 'USER_MDF', 'DATA_MDF', 'SYSDBA_DATA_MDF']) <> -1 then
            // begin
            // NewFieldVisible := False;
            // NewFieldReadOnly := true;
            // end
            // else
            if IndexText(column.Name, ['USR_USER_INS', 'USR_DATA_INS', 'USR_USER_MDF', 'USR_DATA_MDF', 'USR_DATA_DBA']) <> -1 then
            begin
              NewFieldVisible := False;
              NewFieldReadOnly := true;
            end
        end;

        column.Caption := CapFirst(Field.DisplayLabel);
        if column.Caption.IsEmpty then
          column.Caption := CapFirst(Field.FieldName);

        // Non salvare la caption se coincide con il domain (verrà ricostruita a runtime)
        // o se è gestita da un override
        if assigned(column.Domain) then
          if SameText(column.Caption, column.Domain.DisplayLabel) then
            column.Caption := '';

        if Overrides.OverrideExists(zDbViewProps.DataSet, column.Name, [ofCaptionGrid]) then
          column.Caption := '';

        column.ReadOnly := Field.ReadOnly or (Field.FieldKind = fkCalculated) or NewFieldReadOnly;
        column.Width := -1;
        column.Visible := NewFieldVisible;
      end;
  finally
    EndUpdate;
  end;
end;

{ TzDbViewPersistence }

constructor TzDbViewFlags.Create;
begin
  inherited;;
  FUpdateCnt := 0;
  FOnChange := nil;

  FAutoEdit := true;
  FAutoWidth := False;
  FBorder := False;
  FButtonArrows := true;
  FButtonDelete := true;
  FButtonInsert := true;
  FButtonOkCancel := true;
  FButtonRefresh := true;
  FButtonUpdate := true;
  FButtonFooters := true;
  FCube := False;
  FCardInherits := true;
  FDblClick := true;
  FFilters := true;
  FFooter := False;
  FGridMode := true;
  FGroupBy := False;
  FGroupFooters := gfInvisible;
  FGroupsAlwaysExpanded := False;
  FIgnoreTimeForFiltering := true;
  FIncrementalSearch := true;
  FLookups := False;
  FMultiselect := true;
  FParams := False;
  FRowSelect := False;
  FReadOnly := False;
  FSearch := False;
  FSort := true;
  FToolbar := true;
  FHideFocusRectOnExit := true;
end;

procedure TzDbViewFlags.Assign(Source: TPersistent);
var
  src: TzDbViewFlags;
begin

  if Source is TzDbViewFlags then
  begin
    src := Source as TzDbViewFlags;

    FAutoEdit := src.AutoEdit;
    FAutoWidth := src.AutoWidth;
    FBorder := src.Border;
    FButtonArrows := src.ButtonArrows;
    FButtonDelete := src.ButtonDelete;
    FButtonInsert := src.ButtonInsert;
    FButtonOkCancel := src.ButtonOkCancel;
    FButtonRefresh := src.ButtonRefresh;
    FButtonUpdate := src.ButtonUpdate;
    FButtonFooters := src.ButtonFooters;
    FCube := src.Cube;
    FDblClick := src.DblClick;
    FEditing := src.Editing;
    FFilters := src.Filters;
    FFooter := src.Footer;
    FGridMode := src.GridMode;
    FGroupBy := src.GroupBy;
    FGroupFooters := src.GroupFooters;
    FGroupsAlwaysExpanded := src.GroupsAlwaysExpanded;
    FIncrementalSearch := src.IncrementalSearch;
    FIgnoreTimeForFiltering := src.IgnoreTimeForFiltering;
    FLookups := src.Lookups;
    FMultiselect := src.Multiselect;
    FParams := src.Params;
    FRowSelect := src.RowSelect;
    FReadOnly := src.ReadOnly;
    FSearch := src.Search;
    FSort := src.Sort;
    FToolbar := src.Toolbar;
    FHideFocusRectOnExit := src.HideFocusRectOnExit;
  end
  else
    inherited;
end;

procedure TzDbViewFlags.BeginUpdate;
begin
  Inc(FUpdateCnt);
end;

procedure TzDbViewFlags.Changed;
begin
  if not IsUpdating then
    if assigned(FOnChange) then
      OnChange(self);
end;

procedure TzDbViewFlags.EndUpdate;
begin
  Dec(FUpdateCnt);
end;

function TzDbViewFlags.IsUpdating: boolean;
begin
  result := FUpdateCnt > 0;
end;

procedure TzDbViewFlags.SetAutoEdit(const Value: boolean);
begin
  FAutoEdit := Value;
  Changed;
end;

procedure TzDbViewFlags.SetAutoWidth(const Value: boolean);
begin
  FAutoWidth := Value;
  Changed;
end;

procedure TzDbViewFlags.SetBorder(const Value: boolean);
begin
  FBorder := Value;
  Changed;
end;

procedure TzDbViewFlags.SetButtonArrows(const Value: boolean);
begin
  FButtonArrows := Value;
  Changed;
end;

procedure TzDbViewFlags.SetButtonDelete(const Value: boolean);
begin
  if FButtonDelete <> Value then
  begin
    FButtonDelete := Value;
    Changed;
  end;
end;

procedure TzDbViewFlags.SetButtonFooters(const Value: boolean);
begin
  if FButtonFooters <> Value then
  begin
    FButtonFooters := Value;
    Changed;
  end;
end;

procedure TzDbViewFlags.SetButtonInsert(const Value: boolean);
begin
  if FButtonInsert <> Value then
  begin
    FButtonInsert := Value;
    Changed;
  end;
end;

procedure TzDbViewFlags.SetButtonOkCancel(const Value: boolean);
begin
  FButtonOkCancel := Value;
  Changed;
end;

procedure TzDbViewFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbViewFlags.SetButtonUpdate(const Value: boolean);
begin
  if FButtonUpdate <> Value then
  begin
    FButtonUpdate := Value;
    Changed;
  end;
end;

procedure TzDbViewFlags.SetCardInherits(const Value: boolean);
begin
  FCardInherits := Value;
  Changed;
end;

procedure TzDbViewFlags.SetCube(const Value: boolean);
begin
  FCube := Value;
  Changed;
end;

procedure TzDbViewFlags.SetDblClick(const Value: boolean);
begin
  FDblClick := Value;
  Changed;
end;

procedure TzDbViewFlags.SetEditing(const Value: boolean);
begin
  FEditing := Value;
  Changed;
end;

procedure TzDbViewFlags.SetFilters(const Value: boolean);
begin
  FFilters := Value;
  Changed;
end;

procedure TzDbViewFlags.SetFooter(const Value: boolean);
begin
  FFooter := Value;
  Changed;
end;

procedure TzDbViewFlags.SetGridMode(const Value: boolean);
begin
  FGridMode := Value;
  Changed;
end;

procedure TzDbViewFlags.SetGroupBy(const Value: boolean);
begin
  FGroupBy := Value;
  Changed;
end;

procedure TzDbViewFlags.SetGroupsAlwaysExpanded(const Value: boolean);
begin
  FGroupsAlwaysExpanded := Value;
  Changed;
end;

procedure TzDbViewFlags.SetGroupFooters(const Value: TcxGridGroupFootersMode);
begin
  FGroupFooters := Value;
  Changed;
end;

procedure TzDbViewFlags.SetHideFocusRectOnExit(const Value: boolean);
begin
  FHideFocusRectOnExit := Value;
  Changed;
end;

procedure TzDbViewFlags.SetIgnoreTimeForFiltering(const Value: boolean);
begin
  FIgnoreTimeForFiltering := Value;
  Changed;
end;

procedure TzDbViewFlags.SetIncrementalSearch(const Value: boolean);
begin
  FIncrementalSearch := Value;
  Changed;
end;

procedure TzDbViewFlags.SetLookups(const Value: boolean);
begin
  FLookups := Value;
  Changed;
end;

procedure TzDbViewFlags.SetMultiselect(const Value: boolean);
begin
  FMultiselect := Value;
  Changed;
end;

procedure TzDbViewFlags.SetParams(const Value: boolean);
begin
  FParams := Value;
  Changed;
end;

procedure TzDbViewFlags.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;
  Changed;
end;

procedure TzDbViewFlags.SetRowSelect(const Value: boolean);
begin
  FRowSelect := Value;
  Changed;
end;

procedure TzDbViewFlags.SetSearch(const Value: boolean);
begin
  FSearch := Value;
  Changed;
end;

procedure TzDbViewFlags.SetSort(const Value: boolean);
begin
  FSort := Value;
  Changed;
end;

procedure TzDbViewFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

constructor TzControlProps.Create(Collection: TCollection);
begin
  inherited;
  FRowPlacement := rpAuto;
  FFieldOrigin := '';
  FDisplayLabel := '';
  FDomain := nil;
  FLines := -1;
  FNewLineBefore := False;
  FReadOnly := False;
  FRequired := False;
  FSeparator := False;
  FSeparatorCaption := '';
  FSize := -1;
  FVisible := true;
  FzCtrlType := ctDefault;
  FGroup := '';
  FGroupExpandButton := False;
  FGroupExpanded := true;
  FImageName := '';
  FColSpan := 0;
end;

procedure TzControlProps.Assign(Source: TPersistent);
var
  src: TzControlProps;
begin
  inherited;

  if Source is TzControlProps then
  begin
    src := Source as TzControlProps;

    Name := src.Name;
    FFieldOrigin := src.FieldOrigin;
    FDisplayLabel := src.FDisplayLabel; // campo, non prop
    FDomain := src.Domain;
    FLines := src.Lines;
    FNewLineBefore := src.NewLineBefore;
    FReadOnly := src.ReadOnly;
    FRequired := src.Required;
    FSeparator := src.Separator;
    FSeparatorCaption := src.SeparatorCaption;
    FSize := src.Size;
    FVisible := src.Visible;
    FzCtrlType := src.FzCtrlType; // campo, non prop
    Group := src.Group;
    GroupExpandButton := src.GroupExpandButton;
    GroupExpanded := src.GroupExpanded;
    ImageName := src.ImageName;
    ColSpan := src.ColSpan;
    RowPlacement := src.RowPlacement;
  end;
end;

function TzControlProps.GetEffectiveDisplayLabel: string;
begin
  result := DisplayLabel;

  if result.IsEmpty then
    if assigned(FDomain) then
      result := FDomain.DisplayLabel
    else
      result := CapFirst(Name);
end;

function TzControlProps.GetzCtrlType: TzCtrlType;
begin
  result := FzCtrlType;

  if result = ctDefault then
    if assigned(Domain) then
      result := Domain.zCtrlType;
end;

procedure TzControlProps.SetzCtrlType(const Value: TzCtrlType);
begin
  FzCtrlType := Value;
end;

function TzControlProps.IsCtrlTypeStored: boolean;
begin
  result := FzCtrlType <> ctDefault;
end;

function TzControlProps.IsDataAware: boolean;
begin
  result := zCtrlType.IsDataAware;
end;

function TzControlProps.IsDisplayLabelStored: boolean;
begin
  result := FDisplayLabel <> '';
end;

procedure TzControlProps.SetDisplayLabel(const Value: string);
begin
  FDisplayLabel := Value;
end;

procedure TzControlProps.SetGroup(const Value: string);
begin
  FGroup := Value;
end;

procedure TzControlProps.SetNewLineBefore(const Value: boolean);
begin
  // Se il file memorizzato conteneva NewLineBefore = True, forziamo il nuovo enumerato
  if Value then
    FRowPlacement := rpForceNewLine
  else
    FRowPlacement := rpAuto;
end;

procedure TzControlProps.SetRowPlacement(const Value: TControlRowPlacement);
begin
  FRowPlacement := Value;
end;

{ TzControls }

constructor TzControls.Create;
begin
  inherited Create(TzControlProps, 'Controls', -1, nil);
  Sorted := False;
end;

procedure TzControls.FillTreeList(MasterNode: TcxTreeListNode);
var
  Child: TcxTreeListNode;
  Item: TzControlProps;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');
  MasterNode.TreeList.BeginUpdate;
  try
    for Item in self do
    begin
      Child := MasterNode.AddChild;
      Child.Values[0] := Item.DisplayName;
      Child.data := Item;
      Child.ImageIndex := -1;
      Child.SelectedIndex := -1;
    end;
  finally
    MasterNode.TreeList.EndUpdate;
  end;
  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

procedure TzControls.MigrateLineBreaksToRowPlacement;
// Converte gli item legacy ctLineBreak in RowPlacement=rpForceNewLine sul primo
// controllo successivo nello stesso gruppo, poi li rimuove. ctSeparator NON
// viene toccato (elemento visibile, non una rottura di riga).
var
  i, J: integer;
  lb, target: TzControlProps;
begin
  BeginUpdate;
  try
    for i := count - 1 downto 0 do
    begin
      lb := Items[i];
      if lb.zCtrlType <> ctLineBreak then
        Continue;

      // primo controllo dati successivo nello stesso gruppo
      target := nil;
      for J := i + 1 to count - 1 do
      begin
        if Items[J].zCtrlType in [ctLineBreak, ctSeparator] then
          Continue;
        if Items[J].Group = lb.Group then
        begin
          target := Items[J];
          Break;
        end;
      end;

      // Sposta la semantica "apre nuova riga" sul controllo successivo.
      if assigned(target) then
        target.RowPlacement := rpForceNewLine;

      self.Delete(i); // rimuove l'item ctLineBreak (reindicizza)
    end;
  finally
    EndUpdate;
  end;
end;

procedure TzControls.ValidateDataset(DataSet: TzFbDataSet; const Reset: boolean);
var
  Field: TField;
  Control: TzControlProps;
  i: integer;
  ListEmpty: boolean;
  NewFieldVisible: boolean;
  NewFieldReadOnly: boolean;
begin
  if not assigned(DataSet) then
    Exit;

  BeginUpdate;
  try

    if Reset then
      Clear
    else
      for i := count - 1 downto 0 do // eliminare i campi non più appartenenti al dataset
      begin
        Items[i].Domain := nil;
        if Items[i].zCtrlType.IsDataAware then
          if not assigned(DataSet.FindField(Items[i].Name)) then
            self.Delete(i);
      end;

    ListEmpty := count = 0;

    // aggiunge i nuovi
    for i := 0 to DataSet.FieldCount - 1 do
      if not self.Exists(DataSet.Fields[i].FieldName) then
      begin
        Field := DataSet.Fields[i];
        Control := Add;
        Control.Name := Field.FieldName;
        Control.FieldOrigin := DataSet.FieldOrigin(Field);
        Control.Domain := Base.zDataDictionary.get(Control.FieldOrigin, true);

        NewFieldVisible := Field.Visible and ListEmpty;
        NewFieldReadOnly := False;

        if NewFieldVisible then
        begin

          if DataSet.IsDetailParamField(Control.Name) then
            NewFieldVisible := False
          else
            // if IndexText(Control.Name, ['USER_INS', 'DATA_INS', 'USER_MDF', 'DATA_MDF', 'SYSDBA_DATA_MDF']) <> -1 then
            // begin
            // NewFieldVisible := False;
            // NewFieldReadOnly := true;
            // end
            // else
            if IndexText(Control.Name, ['USR_USER_INS', 'USR_DATA_INS', 'USR_USER_MDF', 'USR_DATA_MDF', 'USR_DATA_DBA']) <> -1 then
            begin
              NewFieldVisible := False;
              NewFieldReadOnly := true;
            end
        end;

        Control.DisplayLabel := '';
        Control.ReadOnly := Field.ReadOnly or (Field.FieldKind = fkCalculated) or NewFieldReadOnly;
        Control.Size := dx.FieldSize(Field);
        Control.Visible := NewFieldVisible;
      end;
  finally
    EndUpdate;
  end;

  // assegnamento del domain
  for i := 0 to count - 1 do
    if Items[i].zCtrlType.IsDataAware then
    begin
      Field := DataSet.FindField(Items[i].Name);
      Items[i].FieldOrigin := DataSet.FieldOrigin(Field);
      Items[i].Domain := Base.zDataDictionary.get(Items[i].FieldOrigin, true);
    end;
end;

{ TzDbViewPersistence }

constructor TzDbCardFlags.Create;
begin
  inherited;;
  FUpdateCnt := 0;
  FOnChange := nil;

  FAutoEdit := true;
  FBorder := False;
  FButtonArrows := true;
  FButtonDelete := true;
  FButtonInsert := true;
  FButtonOkCancel := true;
  FButtonRefresh := true;
  FButtonUpdate := true;
  FReadOnly := False;
  FToolbar := true;
end;

procedure TzDbCardFlags.Assign(Source: TPersistent);
var
  src: TzDbCardFlags;
begin

  if Source is TzDbCardFlags then
  begin
    src := Source as TzDbCardFlags;

    FAutoEdit := src.AutoEdit;
    FBorder := src.Border;
    FButtonArrows := src.ButtonArrows;
    FButtonDelete := src.ButtonDelete;
    FButtonInsert := src.ButtonInsert;
    FButtonOkCancel := src.ButtonOkCancel;
    FButtonRefresh := src.ButtonRefresh;
    FButtonUpdate := src.ButtonUpdate;
    FReadOnly := src.ReadOnly;
    FToolbar := src.Toolbar;
  end
  else
    inherited;
end;

procedure TzDbCardFlags.BeginUpdate;
begin
  Inc(FUpdateCnt);
end;

procedure TzDbCardFlags.Changed;
begin
  if not IsUpdating then
    if assigned(FOnChange) then
      OnChange(self);
end;

procedure TzDbCardFlags.EndUpdate;
begin
  Dec(FUpdateCnt);
end;

function TzDbCardFlags.IsUpdating: boolean;
begin
  result := FUpdateCnt > 0;
end;

procedure TzDbCardFlags.SetAutoEdit(const Value: boolean);
begin
  FAutoEdit := Value;
  Changed;
end;

procedure TzDbCardFlags.SetBorder(const Value: boolean);
begin
  FBorder := Value;
  Changed;
end;

procedure TzDbCardFlags.SetButtonArrows(const Value: boolean);
begin
  FButtonArrows := Value;
  Changed;
end;

procedure TzDbCardFlags.SetButtonDelete(const Value: boolean);
begin
  if FButtonDelete <> Value then
  begin
    FButtonDelete := Value;
    Changed;
  end;
end;

procedure TzDbCardFlags.SetButtonInsert(const Value: boolean);
begin
  if FButtonInsert <> Value then
  begin
    FButtonInsert := Value;
    Changed;
  end;
end;

procedure TzDbCardFlags.SetButtonOkCancel(const Value: boolean);
begin
  FButtonOkCancel := Value;
  Changed;
end;

procedure TzDbCardFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbCardFlags.SetButtonUpdate(const Value: boolean);
begin
  if FButtonUpdate <> Value then
  begin
    FButtonUpdate := Value;
    Changed;
  end;
end;

procedure TzDbCardFlags.SetReadOnly(const Value: boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    Changed;
  end;
end;

procedure TzDbCardFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

procedure TzConnection.GetUserAndPassword(UserName: String; out dbUsername, dbPassword: string);
begin
  // L'autenticazione Active Directory passa dal parametro HOST_LDAP della
  // procedura di login (vedi ExecuteStoredProcLogin), non dalla connessione:
  // le credenziali verso Firebird sono sempre quelle della connessione.
  dbUsername := self.dbUser;
  dbPassword := self.dbPassword;
end;

{ TzDbViewPersistence }

constructor TzDbPivotFlags.Create;
begin
  inherited;;
  FUpdateCnt := 0;
  FOnChange := nil;

  FButtonArrows := true;
  FButtonRefresh := true;
  FButtonExpand := true;
  FButtonExpandCaption := False;
  FParams := False;
  FFilter := False;
  FToolbar := true;

  FDrawExpandButtons := true;
  FDrillDown := False;
  FExpandRows := False;
  FExpandColumns := False;
  FExpandInnerLevels := False;

  FHideColumnFields := False;
  FHideDataFields := False;
  FHideFilterFields := False;
  FHideRowFields := False;

  FColumnFields := true;
  FColumnGrandTotals := true;
  FColumnGrandTotalText := '';
  FColumnTotals := true;
  FDataFields := true;
  FFilterFields := true;
  FFilterSeparator := true;
  FGrandTotalsForSingleValues := False;
  FMarkNarrowCells := False;
  FRowFields := true;
  FRowGrandTotals := true;
  FRowGrandTotalText := '';
  FRowTotals := true;
  FRowTreeLayout := False;
  FTotalsForSingleValues := False;
end;

procedure TzDbPivotFlags.Assign(Source: TPersistent);
var
  src: TzDbPivotFlags;
begin

  if Source is TzDbPivotFlags then
  begin
    src := Source as TzDbPivotFlags;

    FButtonArrows := src.ButtonArrows;
    FButtonRefresh := src.ButtonRefresh;
    FButtonExpand := src.ButtonExpand;
    FButtonExpandCaption := src.ButtonExpandCaption;
    FParams := src.Params;
    FFilter := src.Filter;
    FToolbar := src.Toolbar;

    // DIV-PVT-1: DrillDown non veniva copiato
    FDrillDown := src.DrillDown;
    FDrawExpandButtons := src.DrawExpandButtons;
    FExpandRows := src.ExpandRows;
    FExpandColumns := src.ExpandColumns;
    FExpandInnerLevels := src.ExpandInnerLevels;

    FHideColumnFields := src.HideColumnFields;
    FHideDataFields := src.HideDataFields;
    FHideFilterFields := src.HideFilterFields;
    FHideRowFields := src.HideRowFields;

    // FColumnFields := src.ColumnFields;
    FColumnGrandTotals := src.ColumnGrandTotals;
    FColumnGrandTotalText := src.ColumnGrandTotalText;
    FColumnTotals := src.ColumnTotals;
    // FDataFields := src.DataFields;
    // FFilterFields := src.FilterFields;
    FFilterSeparator := src.FilterSeparator;
    FGrandTotalsForSingleValues := src.GrandTotalsForSingleValues;
    FMarkNarrowCells := src.MarkNarrowCells;
    // FRowFields := src.RowFields;
    FRowGrandTotals := src.RowGrandTotals;
    FRowGrandTotalText := src.RowGrandTotalText;
    FRowTotals := src.RowTotals;
    FRowTreeLayout := src.RowTreeLayout;
    FTotalsForSingleValues := src.TotalsForSingleValues;
  end
  else
    inherited;
end;

procedure TzDbPivotFlags.BeginUpdate;
begin
  Inc(FUpdateCnt);
end;

procedure TzDbPivotFlags.Changed;
begin
  if not IsUpdating then
    if assigned(FOnChange) then
      OnChange(self);
end;

procedure TzDbPivotFlags.EndUpdate;
begin
  Dec(FUpdateCnt);
end;

function TzDbPivotFlags.IsUpdating: boolean;
begin
  result := FUpdateCnt > 0;
end;

procedure TzDbPivotFlags.SetButtonArrows(const Value: boolean);
begin
  FButtonArrows := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetButtonExpand(const Value: boolean);
begin
  FButtonExpand := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetButtonExpandCaption(const Value: boolean);
begin
  FButtonExpandCaption := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetColumnFields(const Value: boolean);
begin
  FColumnFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetColumnGrandTotals(const Value: boolean);
begin
  FColumnGrandTotals := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetColumnGrandTotalText(const Value: string);
begin
  FColumnGrandTotalText := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetColumnTotals(const Value: boolean);
begin
  FColumnTotals := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetDataFields(const Value: boolean);
begin
  FDataFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetDrawExpandButtons(const Value: boolean);
begin
  FDrawExpandButtons := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetDrillDown(const Value: boolean);
begin
  FDrillDown := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetExpandColumns(const Value: boolean);
begin
  FExpandColumns := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetExpandInnerLevels(const Value: boolean);
begin
  FExpandInnerLevels := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetExpandRows(const Value: boolean);
begin
  FExpandRows := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetFilter(const Value: boolean);
begin
  FFilter := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetFilterFields(const Value: boolean);
begin
  FFilterFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetFilterSeparator(const Value: boolean);
begin
  FFilterSeparator := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetGrandTotalsForSingleValues(const Value: boolean);
begin
  FGrandTotalsForSingleValues := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetHideColumnFields(const Value: boolean);
begin
  FHideColumnFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetHideDataFields(const Value: boolean);
begin
  FHideDataFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetHideFilterFields(const Value: boolean);
begin
  FHideFilterFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetHideRowFields(const Value: boolean);
begin
  FHideRowFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetMarkNarrowCells(const Value: boolean);
begin
  FMarkNarrowCells := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetParams(const Value: boolean);
begin
  FParams := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetRowFields(const Value: boolean);
begin
  FRowFields := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetRowGrandTotals(const Value: boolean);
begin
  FRowGrandTotals := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetRowGrandTotalText(const Value: string);
begin
  FRowGrandTotalText := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetRowTreeLayout(const Value: boolean);
begin
  FRowTreeLayout := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetRowTotals(const Value: boolean);
begin
  FRowTotals := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

procedure TzDbPivotFlags.SetTotalsForSingleValues(const Value: boolean);
begin
  FTotalsForSingleValues := Value;
  Changed;
end;

{ TzDbView }

constructor TzDbPivotProps.Create(Collection: TCollection);
begin
  inherited;
  FBestFitAfterExpand := true;
  FCaption := zDefaultCardCaption;
  FDataSet := '';
  FTitle := '';
  FToolFilters := TzToolFiltersProps.Create(TzToolFilterProps, 'zFilters', -1, nil, False);
  FFields := TzPivotFields.Create(self);
  FFlags := TzDbPivotFlags.Create;
end;

destructor TzDbPivotProps.Destroy;
begin
  FreeAndNil(FToolFilters);
  FreeAndNil(FFields);
  FreeAndNil(FFlags);
  inherited;
end;

procedure TzDbPivotProps.Assign(Source: TPersistent);
var
  Item: TzDbPivotProps;
begin
  inherited Assign(Source); // per Description&ToolActions

  if Source is TzDbPivotProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbPivotProps(Source);
      Name := Item.Name;

      BestFitAfterExpand := Item.BestFitAfterExpand;
      Caption := Item.Caption;
      DataSet := Item.DataSet;
      Title := Item.Title;

      ToolFilters.Assign(Item.ToolFilters);
      Flags.Assign(Item.Flags);
      Fields.Assign(Item.Fields);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzDbPivotProps.zComponentType: TzComponentType;
begin
  inherited;
  result := ctPivot;
end;

function TzDbPivotProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

procedure TzDbPivotProps.LoadFromBase;
var
  Item: TzDbPivotProps;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDbPivots.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDbPivotProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDbPivotProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbPivots.get(Name, true);
  Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbPivots, 'TzDbPivots.SaveToBase');
end;

procedure TzDbPivotProps.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TzDbPivotProps.SetFields(const Value: TzPivotFields);
begin
  FFields.Assign(Value);
end;

procedure TzDbPivotProps.SetDataSet(const Value: string);
begin
  FDataSet := Value;
end;

procedure TzDbPivotProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbPivotProps.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

{ TzDbRecordViewFlags }

constructor TzDbRecordViewFlags.Create;
begin
  inherited;
  FUpdateCount := 0;
  FButtonArrows := true;
  FButtonDelete := true;
  FButtonExpand := true;
  FButtonInsert := true;
  FButtonOkCancel := true;
  FButtonRefresh := true;
  FButtonUpdate := true;
  FEditInCard := False;
  FGridMode := true;
  FInplaceEditing := true;
  FHideEmptyRows := False;
  FHighlightDifferences := true;
  FLayout := rlSingleRecord;
  FMarkRequired := true;
  FParams := False;
  FReadOnly := False;
  FToolbar := true;
end;

procedure TzDbRecordViewFlags.Assign(Source: TPersistent);
var
  src: TzDbRecordViewFlags;
begin
  if Source is TzDbRecordViewFlags then
  begin
    src := TzDbRecordViewFlags(Source);
    BeginUpdate;
    try
      FButtonArrows := src.ButtonArrows;
      FButtonDelete := src.ButtonDelete;
      FButtonExpand := src.ButtonExpand;
      FButtonInsert := src.ButtonInsert;
      FButtonOkCancel := src.ButtonOkCancel;
      FButtonRefresh := src.ButtonRefresh;
      FButtonUpdate := src.ButtonUpdate;
      FEditInCard := src.EditInCard;
      FGridMode := src.GridMode;
      FInplaceEditing := src.InplaceEditing;
      FHideEmptyRows := src.HideEmptyRows;
      FHighlightDifferences := src.HighlightDifferences;
      FLayout := src.Layout;
      FMarkRequired := src.MarkRequired;
      FParams := src.Params;
      FReadOnly := src.ReadOnly;
      FToolbar := src.Toolbar;
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

procedure TzDbRecordViewFlags.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TzDbRecordViewFlags.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if FUpdateCount = 0 then
    Changed;
end;

procedure TzDbRecordViewFlags.Changed;
begin
  if (FUpdateCount = 0) and assigned(FOnChange) then
    FOnChange(self);
end;

procedure TzDbRecordViewFlags.SetButtonArrows(const Value: boolean);
begin
  FButtonArrows := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetButtonDelete(const Value: boolean);
begin
  FButtonDelete := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetButtonExpand(const Value: boolean);
begin
  FButtonExpand := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetButtonInsert(const Value: boolean);
begin
  FButtonInsert := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetButtonOkCancel(const Value: boolean);
begin
  FButtonOkCancel := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetButtonUpdate(const Value: boolean);
begin
  FButtonUpdate := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetEditInCard(const Value: boolean);
begin
  FEditInCard := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetInplaceEditing(const Value: boolean);
begin
  FInplaceEditing := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetGridMode(const Value: boolean);
begin
  FGridMode := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetHideEmptyRows(const Value: boolean);
begin
  FHideEmptyRows := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetHighlightDifferences(const Value: boolean);
begin
  FHighlightDifferences := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetLayout(const Value: TzRecordViewLayout);
begin
  FLayout := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetMarkRequired(const Value: boolean);
begin
  FMarkRequired := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetParams(const Value: boolean);
begin
  FParams := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;
  Changed;
end;

procedure TzDbRecordViewFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

{ TzRecordViewRow }

constructor TzRecordViewRow.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FDomain := nil;
  FExpanded := true;
  FFieldOrigin := '';
  FHeight := -1;
  FHint := '';
  FMembers := TStringList.Create;
  FParentName := '';
  FReadOnly := False;
  FRowKind := rkField;
  FVisible := true;
  FzCtrlType := ctDefault;
end;

destructor TzRecordViewRow.Destroy;
begin
  FreeAndNil(FMembers);
  inherited;
end;

procedure TzRecordViewRow.Assign(Source: TPersistent);
var
  Item: TzRecordViewRow;
begin
  inherited;

  if Source is TzRecordViewRow then
  begin
    Item := TzRecordViewRow(Source);
    Name := Item.Name;
    FRowKind := Item.FRowKind;
    FFieldOrigin := Item.FFieldOrigin;
    FDomain := Item.FDomain;
    FCaption := Item.FCaption; // campo, non proprieta': non copia il ripiego sul dominio
    FHint := Item.FHint;
    FParentName := Item.FParentName;
    FVisible := Item.FVisible;
    FReadOnly := Item.FReadOnly;
    FExpanded := Item.FExpanded;
    FHeight := Item.FHeight;
    FMembers.Assign(Item.FMembers);
    FzCtrlType := Item.FzCtrlType; // campo, non proprieta'
  end;
end;

function TzRecordViewRow.IsField: boolean;
begin
  result := FRowKind = rkField;
end;

function TzRecordViewRow.GetCaption: string;
begin
  result := FCaption;

  if result = '' then
    if assigned(Domain) then
      result := Domain.DisplayLabel;

  if result = '' then
    result := Name;
end;

function TzRecordViewRow.GetzCtrlType: TzCtrlType;
begin
  result := FzCtrlType;

  if result = ctDefault then
    if assigned(Domain) then
      result := Domain.zCtrlType;
end;

function TzRecordViewRow.isCaptionStored: boolean;
begin
  result := FCaption <> '';
end;

function TzRecordViewRow.IsCtrlTypeStored: boolean;
begin
  result := FzCtrlType <> ctDefault;
end;

procedure TzRecordViewRow.SetMembers(const Value: TStrings);
begin
  FMembers.Assign(Value);
end;

{ TzRecordViewRows }

constructor TzRecordViewRows.Create(azDbRecordViewProps: TzDbRecordViewProps);
begin
  inherited Create(TzRecordViewRow, 'Rows', -1, nil);
  zDbRecordViewProps := azDbRecordViewProps;
  // l'ordine della collezione e' l'ordine delle righe a video
  Sorted := False;
end;

function TzRecordViewRows.FieldRow(const FieldName: string): TzRecordViewRow;
var
  i: integer;
begin
  result := nil;

  for i := 0 to count - 1 do
    if Items[i].IsField and SameText(Items[i].Name, FieldName) then
      Exit(Items[i]);
end;

function TzRecordViewRows.AddCategory(const CategoryName, CategoryCaption: string): TzRecordViewRow;
begin
  result := get(CategoryName, False);

  if not assigned(result) then
  begin
    result := Add;
    result.Name := CategoryName;
  end;

  result.RowKind := rkCategory;
  result.Caption := CategoryCaption;
end;

procedure TzRecordViewRows.MoveToCategory(const RowName, CategoryName: string);
var
  Row: TzRecordViewRow;
begin
  Row := get(RowName, False);

  if assigned(Row) then
    Row.ParentName := CategoryName;
end;

procedure TzRecordViewRows.Reset(DataSet: TzFbDataSet);
begin
  Clear;
  ValidateDataset(DataSet);
end;

procedure TzRecordViewRows.ValidateDataset(DataSet: TzFbDataSet);
var
  Field: TField;
  Row: TzRecordViewRow;
  i, j: integer;
  NewFieldVisible: boolean;
  ListEmpty: boolean;
begin
  if not assigned(DataSet) then
    Exit;

  BeginUpdate;
  try
    // elimina le righe dei campi non piu' presenti nel dataset
    for i := count - 1 downto 0 do
    begin
      Row := Items[i];
      Row.Domain := nil;

      case Row.RowKind of
        rkField:
          if not assigned(DataSet.FindField(Row.Name)) then
            self.Delete(i);
        rkMultiField:
          for j := Row.Members.count - 1 downto 0 do
            if not assigned(DataSet.FindField(Trim(Row.Members[j]))) then
              Row.Members.Delete(j);
      end;
    end;

    ListEmpty := not assigned(Find(
      function(Item: TzRecordViewRow): boolean
      begin
        result := Item.IsField;
      end));

    // aggiunge in coda i campi nuovi; con la lista vuota mostra tutti i campi
    // visibili tranne quelli di servizio, altrimenti i nuovi nascono nascosti
    for i := 0 to DataSet.FieldCount - 1 do
    begin
      Field := DataSet.Fields[i];

      if assigned(FieldRow(Field.FieldName)) then
        Continue;

      Row := Add;
      Row.Name := Field.FieldName;
      Row.RowKind := rkField;

      NewFieldVisible := Field.Visible and ListEmpty;

      if NewFieldVisible then
        if DataSet.IsDetailParamField(Field.FieldName) then
          NewFieldVisible := False
        else
          if IndexText(Field.FieldName, ['USER_INS', 'DATA_INS', 'USER_MDF', 'DATA_MDF', 'SYSDBA_DATA_MDF', 'USR_USER_INS', 'USR_DATA_INS', 'USR_USER_MDF',
            'USR_DATA_MDF', 'USR_DATA_DBA']) <> -1 then
            NewFieldVisible := False;

      Row.Visible := NewFieldVisible;
    end;

    // origine e dominio di ogni riga di campo
    for Row in self do
      if Row.IsField then
      begin
        Field := DataSet.FindField(Row.Name);

        if assigned(Field) then
        begin
          Row.FieldOrigin := DataSet.FieldOrigin(Field);

          if assigned(Base) then
            Row.Domain := Base.zDataDictionary.get(Row.FieldOrigin, true);
        end;
      end;
  finally
    EndUpdate;
  end;
end;

{ TzDbRecordViewProps }

constructor TzDbRecordViewProps.Create(Collection: TCollection);
begin
  inherited;
  FCaption := zDefaultCardCaption;
  FDataSet := '';
  FTitle := '';
  FHeaderWidth := 0;
  FValueWidth := 0;
  // ToolFilters e' gia' creato da TzBaseFilterableComponentProps
  FFlags := TzDbRecordViewFlags.Create;
  FRows := TzRecordViewRows.Create(self);
end;

destructor TzDbRecordViewProps.Destroy;
begin
  FreeAndNil(FRows);
  FreeAndNil(FFlags);
  inherited;
end;

procedure TzDbRecordViewProps.Assign(Source: TPersistent);
var
  Item: TzDbRecordViewProps;
begin
  inherited Assign(Source); // Description, ToolActions e ToolFilters

  if Source is TzDbRecordViewProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbRecordViewProps(Source);
      Name := Item.Name;

      Caption := Item.Caption;
      DataSet := Item.DataSet;
      HeaderWidth := Item.HeaderWidth;
      Title := Item.Title;
      ValueWidth := Item.ValueWidth;

      Flags.Assign(Item.Flags);
      Rows.Assign(Item.Rows);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzDbRecordViewProps.zComponentType: TzComponentType;
begin
  result := ctRecordView;
end;

function TzDbRecordViewProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

procedure TzDbRecordViewProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbRecordViewProps.SetFlags(const Value: TzDbRecordViewFlags);
begin
  FFlags.Assign(Value);
end;

procedure TzDbRecordViewProps.SetRows(const Value: TzRecordViewRows);
begin
  FRows.Assign(Value);
end;

procedure TzDbRecordViewProps.LoadFromBase;
var
  Item: TzDbRecordViewProps;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDbRecordViews.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDbRecordViewProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDbRecordViewProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbRecordViews.get(Name, true);

  if Item <> self then
    Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbRecordViews, 'TzDbRecordViewProps.SaveToBase');
end;

{ TzDbTreeFlags }

constructor TzDbTreeFlags.Create;
begin
  inherited;
  FUpdateCount := 0;
  FButtonArrows := true;
  FButtonDelete := true;
  FButtonExpand := true;
  FButtonExpandCaption := False;
  FButtonInsert := true;
  FButtonOkCancel := true;
  FButtonRefresh := true;
  FButtonUpdate := true;
  FDragDrop := False;
  FEditInCard := False;
  FInplaceEditing := true;
  FExpandLevel := 1;
  FExpandMode := temRoots;
  FFooter := False;
  FIndicator := False;
  FMultiSelect := False;
  FParams := False;
  FReadOnly := False;
  FShowRoot := true;
  FSyncDataSet := true;
  FToolbar := true;
end;

procedure TzDbTreeFlags.Assign(Source: TPersistent);
var
  src: TzDbTreeFlags;
begin
  if Source is TzDbTreeFlags then
  begin
    src := TzDbTreeFlags(Source);
    BeginUpdate;
    try
      FButtonArrows := src.ButtonArrows;
      FButtonDelete := src.ButtonDelete;
      FButtonExpand := src.ButtonExpand;
      FButtonExpandCaption := src.ButtonExpandCaption;
      FButtonInsert := src.ButtonInsert;
      FButtonOkCancel := src.ButtonOkCancel;
      FButtonRefresh := src.ButtonRefresh;
      FButtonUpdate := src.ButtonUpdate;
      FDragDrop := src.DragDrop;
      FEditInCard := src.EditInCard;
      FInplaceEditing := src.InplaceEditing;
      FExpandLevel := src.ExpandLevel;
      FExpandMode := src.ExpandMode;
      FFooter := src.Footer;
      FIndicator := src.Indicator;
      FMultiSelect := src.MultiSelect;
      FParams := src.Params;
      FReadOnly := src.ReadOnly;
      FShowRoot := src.ShowRoot;
      FSyncDataSet := src.SyncDataSet;
      FToolbar := src.Toolbar;
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

procedure TzDbTreeFlags.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TzDbTreeFlags.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if FUpdateCount = 0 then
    Changed;
end;

procedure TzDbTreeFlags.Changed;
begin
  if (FUpdateCount = 0) and assigned(FOnChange) then
    FOnChange(self);
end;

procedure TzDbTreeFlags.SetButtonArrows(const Value: boolean);
begin
  FButtonArrows := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonDelete(const Value: boolean);
begin
  FButtonDelete := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonExpand(const Value: boolean);
begin
  FButtonExpand := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonExpandCaption(const Value: boolean);
begin
  FButtonExpandCaption := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonInsert(const Value: boolean);
begin
  FButtonInsert := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonOkCancel(const Value: boolean);
begin
  FButtonOkCancel := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetButtonUpdate(const Value: boolean);
begin
  FButtonUpdate := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetInplaceEditing(const Value: boolean);
begin
  FInplaceEditing := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetEditInCard(const Value: boolean);
begin
  FEditInCard := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetDragDrop(const Value: boolean);
begin
  FDragDrop := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetExpandLevel(const Value: integer);
begin
  // il livello 0 sono le radici: sotto non ha senso
  if Value < 0 then
    FExpandLevel := 0
  else
    FExpandLevel := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetExpandMode(const Value: TzTreeExpandMode);
begin
  FExpandMode := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetFooter(const Value: boolean);
begin
  FFooter := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetIndicator(const Value: boolean);
begin
  FIndicator := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetMultiSelect(const Value: boolean);
begin
  FMultiSelect := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetParams(const Value: boolean);
begin
  FParams := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetShowRoot(const Value: boolean);
begin
  FShowRoot := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetSyncDataSet(const Value: boolean);
begin
  FSyncDataSet := Value;
  Changed;
end;

procedure TzDbTreeFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

{ TzTreeColumn }

constructor TzTreeColumn.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FDomain := nil;
  FFieldOrigin := '';
  FReadOnly := False;
  FVisible := true;
  FWidth := -1;
  FzCtrlType := ctDefault;
end;

procedure TzTreeColumn.Assign(Source: TPersistent);
var
  Item: TzTreeColumn;
begin
  inherited;

  if Source is TzTreeColumn then
  begin
    Item := TzTreeColumn(Source);
    Name := Item.Name;
    FFieldOrigin := Item.FFieldOrigin;
    FDomain := Item.FDomain;
    FCaption := Item.FCaption; // campo, non proprieta': non copia il ripiego sul dominio
    FVisible := Item.FVisible;
    FReadOnly := Item.FReadOnly;
    FWidth := Item.FWidth;
    FzCtrlType := Item.FzCtrlType; // campo, non proprieta'
  end;
end;

function TzTreeColumn.GetCaption: string;
begin
  result := FCaption;

  if result = '' then
    if assigned(Domain) then
      result := Domain.DisplayLabel;

  if result = '' then
    result := Name;
end;

function TzTreeColumn.GetzCtrlType: TzCtrlType;
begin
  result := FzCtrlType;

  if result = ctDefault then
    if assigned(Domain) then
      result := Domain.zCtrlType;
end;

function TzTreeColumn.isCaptionStored: boolean;
begin
  result := FCaption <> '';
end;

function TzTreeColumn.IsCtrlTypeStored: boolean;
begin
  result := FzCtrlType <> ctDefault;
end;

{ TzTreeColumns }

constructor TzTreeColumns.Create(azDbTreeProps: TzDbTreeProps);
begin
  inherited Create(TzTreeColumn, 'Columns', -1, nil);
  zDbTreeProps := azDbTreeProps;
  // l'ordine della collezione e' l'ordine delle colonne a video
  Sorted := False;
end;

procedure TzTreeColumns.Reset(DataSet: TzFbDataSet);
begin
  Clear;
  ValidateDataset(DataSet);
end;

procedure TzTreeColumns.ValidateDataset(DataSet: TzFbDataSet);
var
  Field: TField;
  Column: TzTreeColumn;
  i: integer;
  NewFieldVisible: boolean;
  ListEmpty: boolean;
begin
  if not assigned(DataSet) then
    Exit;

  BeginUpdate;
  try
    // elimina le colonne dei campi non piu' presenti nel dataset
    for i := count - 1 downto 0 do
    begin
      Items[i].Domain := nil;

      if not assigned(DataSet.FindField(Items[i].Name)) then
        self.Delete(i);
    end;

    ListEmpty := count = 0;

    // aggiunge in coda i campi nuovi; con la lista vuota mostra tutti i campi
    // visibili tranne quelli di servizio e i due campi della gerarchia,
    // altrimenti i nuovi nascono nascosti
    for i := 0 to DataSet.FieldCount - 1 do
    begin
      Field := DataSet.Fields[i];

      if assigned(get(Field.FieldName, False)) then
        Continue;

      Column := Add;
      Column.Name := Field.FieldName;

      NewFieldVisible := Field.Visible and ListEmpty;

      if NewFieldVisible then
        if DataSet.IsDetailParamField(Field.FieldName) then
          NewFieldVisible := False
        else
          if IndexText(Field.FieldName, ['USER_INS', 'DATA_INS', 'USER_MDF', 'DATA_MDF', 'SYSDBA_DATA_MDF', 'USR_USER_INS', 'USR_DATA_INS', 'USR_USER_MDF',
            'USR_DATA_MDF', 'USR_DATA_DBA']) <> -1 then
            NewFieldVisible := False
          else
            if assigned(zDbTreeProps) and (SameText(Field.FieldName, zDbTreeProps.KeyFieldName) or SameText(Field.FieldName, zDbTreeProps.ParentFieldName)) then
              NewFieldVisible := False;

      Column.Visible := NewFieldVisible;
    end;

    // origine e dominio di ogni colonna
    for Column in self do
    begin
      Field := DataSet.FindField(Column.Name);

      if assigned(Field) then
      begin
        Column.FieldOrigin := DataSet.FieldOrigin(Field);

        if assigned(Base) then
          Column.Domain := Base.zDataDictionary.get(Column.FieldOrigin, true);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

{ TzDbTreeProps }

constructor TzDbTreeProps.Create(Collection: TCollection);
begin
  inherited;
  FCaption := zDefaultCardCaption;
  FDataSet := '';
  FTitle := '';
  FImageIndexFieldName := '';
  FKeyFieldName := '';
  FParentFieldName := '';
  FPreviewFieldName := '';
  // ToolFilters e' gia' creato da TzBaseFilterableComponentProps
  FFlags := TzDbTreeFlags.Create;
  FColumns := TzTreeColumns.Create(self);
end;

destructor TzDbTreeProps.Destroy;
begin
  FreeAndNil(FColumns);
  FreeAndNil(FFlags);
  inherited;
end;

procedure TzDbTreeProps.Assign(Source: TPersistent);
var
  Item: TzDbTreeProps;
begin
  inherited Assign(Source); // Description, ToolActions e ToolFilters

  if Source is TzDbTreeProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbTreeProps(Source);
      Name := Item.Name;

      Caption := Item.Caption;
      DataSet := Item.DataSet;
      ImageIndexFieldName := Item.ImageIndexFieldName;
      KeyFieldName := Item.KeyFieldName;
      ParentFieldName := Item.ParentFieldName;
      PreviewFieldName := Item.PreviewFieldName;
      Title := Item.Title;

      Flags.Assign(Item.Flags);
      Columns.Assign(Item.Columns);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzDbTreeProps.zComponentType: TzComponentType;
begin
  result := ctTree;
end;

function TzDbTreeProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

procedure TzDbTreeProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbTreeProps.SetColumns(const Value: TzTreeColumns);
begin
  FColumns.Assign(Value);
end;

procedure TzDbTreeProps.SetFlags(const Value: TzDbTreeFlags);
begin
  FFlags.Assign(Value);
end;

procedure TzDbTreeProps.LoadFromBase;
var
  Item: TzDbTreeProps;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDbTrees.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDbTreeProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDbTreeProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbTrees.get(Name, true);

  if Item <> self then
    Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbTrees, 'TzDbTreeProps.SaveToBase');
end;

{ TzDbChartFlags }

constructor TzDbChartFlags.Create;
begin
  inherited;
  FUpdateCount := 0;
  FAllowZoom := true;
  FButtonExport := true;
  FButtonKind := true;
  FButtonLabels := true;
  FButtonLegend := true;
  FButtonPrint := true;
  FButtonRefresh := true;
  FButtonZoom := true;
  FCrosshair := true;
  FParams := False;
  FShowLabels := False;
  FShowLegend := true;
  FSyncDataSet := true;
  FToolbar := true;
end;

procedure TzDbChartFlags.Assign(Source: TPersistent);
var
  src: TzDbChartFlags;
begin
  if Source is TzDbChartFlags then
  begin
    src := TzDbChartFlags(Source);
    BeginUpdate;
    try
      FAllowZoom := src.AllowZoom;
      FButtonExport := src.ButtonExport;
      FButtonKind := src.ButtonKind;
      FButtonLabels := src.ButtonLabels;
      FButtonLegend := src.ButtonLegend;
      FButtonPrint := src.ButtonPrint;
      FButtonRefresh := src.ButtonRefresh;
      FButtonZoom := src.ButtonZoom;
      FCrosshair := src.Crosshair;
      FParams := src.Params;
      FShowLabels := src.ShowLabels;
      FShowLegend := src.ShowLegend;
      FSyncDataSet := src.SyncDataSet;
      FToolbar := src.Toolbar;
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

procedure TzDbChartFlags.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TzDbChartFlags.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if FUpdateCount = 0 then
    Changed;
end;

procedure TzDbChartFlags.Changed;
begin
  if (FUpdateCount = 0) and assigned(FOnChange) then
    FOnChange(self);
end;

procedure TzDbChartFlags.SetAllowZoom(const Value: boolean);
begin
  FAllowZoom := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonExport(const Value: boolean);
begin
  FButtonExport := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonKind(const Value: boolean);
begin
  FButtonKind := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonLabels(const Value: boolean);
begin
  FButtonLabels := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonLegend(const Value: boolean);
begin
  FButtonLegend := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonPrint(const Value: boolean);
begin
  FButtonPrint := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbChartFlags.SetButtonZoom(const Value: boolean);
begin
  FButtonZoom := Value;
  Changed;
end;

procedure TzDbChartFlags.SetCrosshair(const Value: boolean);
begin
  FCrosshair := Value;
  Changed;
end;

procedure TzDbChartFlags.SetParams(const Value: boolean);
begin
  FParams := Value;
  Changed;
end;

procedure TzDbChartFlags.SetShowLabels(const Value: boolean);
begin
  FShowLabels := Value;
  Changed;
end;

procedure TzDbChartFlags.SetShowLegend(const Value: boolean);
begin
  FShowLegend := Value;
  Changed;
end;

procedure TzDbChartFlags.SetSyncDataSet(const Value: boolean);
begin
  FSyncDataSet := Value;
  Changed;
end;

procedure TzDbChartFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

{ TzChartSeriesItem }

constructor TzChartSeriesItem.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FDomain := nil;
  FFieldOrigin := '';
  FKind := gkChart;
  FVisible := true;
end;

procedure TzChartSeriesItem.Assign(Source: TPersistent);
var
  Item: TzChartSeriesItem;
begin
  inherited;

  if Source is TzChartSeriesItem then
  begin
    Item := TzChartSeriesItem(Source);
    Name := Item.Name;
    FCaption := Item.FCaption; // campo, non proprieta': non copia il ripiego sul dominio
    FDomain := Item.FDomain;
    FFieldOrigin := Item.FFieldOrigin;
    FKind := Item.FKind;
    FVisible := Item.FVisible;
  end;
end;

function TzChartSeriesItem.GetCaption: string;
begin
  result := FCaption;

  if result = '' then
    if assigned(Domain) then
      result := Domain.DisplayLabel;

  if result = '' then
    result := Name;
end;

function TzChartSeriesItem.isCaptionStored: boolean;
begin
  result := FCaption <> '';
end;

{ TzChartSeriesItems }

constructor TzChartSeriesItems.Create(azDbChartProps: TzDbChartProps);
begin
  inherited Create(TzChartSeriesItem, 'Series', -1, nil);
  zDbChartProps := azDbChartProps;
  // l'ordine della collezione e' l'ordine delle serie nel grafico
  Sorted := False;
end;

class function TzChartSeriesItems.IsValueField(Field: TField): boolean;
begin
  result := assigned(Field) and (Field.FieldKind in [fkData, fkCalculated, fkInternalCalc, fkAggregate]) and
    // ftWord va qualificato: zOffice.Types ha un suo ftWord (TzFileType) e, essendo
    // dopo Data.DB nella uses, vince sull'omonimo di TFieldType (errore E2010).
    (Field.DataType in [ftSmallint, ftInteger, TFieldType.ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint, ftFMTBcd, ftLongWord, ftShortint, ftByte, ftExtended, ftSingle]);
end;

class function TzChartSeriesItems.IsServiceField(const FieldName: string): boolean;
begin
  result := IndexText(FieldName, ['USER_INS', 'DATA_INS', 'USER_MDF', 'DATA_MDF', 'SYSDBA_DATA_MDF', 'USR_USER_INS', 'USR_DATA_INS', 'USR_USER_MDF',
    'USR_DATA_MDF', 'USR_DATA_DBA']) <> -1;
end;

procedure TzChartSeriesItems.Reset(DataSet: TzFbDataSet);
begin
  Clear;
  ValidateDataset(DataSet);
end;

procedure TzChartSeriesItems.ValidateDataset(DataSet: TzFbDataSet);
var
  Field: TField;
  Item: TzChartSeriesItem;
  i: integer;
  FirstVisible: boolean;
  ArgumentField: string;
begin
  if not assigned(DataSet) then
    Exit;

  ArgumentField := '';
  if assigned(zDbChartProps) then
    ArgumentField := zDbChartProps.ArgumentField;

  BeginUpdate;
  try
    // elimina le serie dei campi non piu' presenti o non piu' numerici
    for i := count - 1 downto 0 do
    begin
      Items[i].Domain := nil;
      Field := DataSet.FindField(Items[i].Name);

      if not IsValueField(Field) then
        self.Delete(i);
    end;

    // con la lista vuota si mostra il primo campo numerico, gli altri nascono
    // nascosti: dieci serie insieme non si leggono, l'amministratore sceglie
    FirstVisible := count = 0;

    for i := 0 to DataSet.FieldCount - 1 do
    begin
      Field := DataSet.Fields[i];

      if not IsValueField(Field) or IsServiceField(Field.FieldName) then
        Continue;

      if DataSet.IsDetailParamField(Field.FieldName) then
        Continue;

      if assigned(get(Field.FieldName, False)) then
        Continue;

      Item := Add;
      Item.Name := Field.FieldName;

      // le chiavi sono numeri ma non valori da disegnare
      Item.Visible := FirstVisible and Field.Visible and not SameText(Field.FieldName, ArgumentField) and
        not SameText(Field.FieldName, 'ID') and not Field.FieldName.StartsWith('ID_', true);

      if Item.Visible then
        FirstVisible := False;
    end;

    // origine e dominio di ogni serie
    for Item in self do
    begin
      Field := DataSet.FindField(Item.Name);

      if assigned(Field) then
      begin
        Item.FieldOrigin := DataSet.FieldOrigin(Field);

        if assigned(Base) then
          Item.Domain := Base.zDataDictionary.get(Item.FieldOrigin, true);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

{ TzDbChartProps }

constructor TzDbChartProps.Create(Collection: TCollection);
begin
  inherited;
  FArgumentField := '';
  FAxisTitleX := '';
  FAxisTitleY := '';
  FCaption := zDefaultCardCaption;
  FDataSet := '';
  FKind := gkBar;
  FMaxPoints := 0;
  FReportName := '';
  FSort := gsNone;
  FTitle := '';
  FTopN := 0;
  FTopNOthers := true;
  // ToolFilters e' gia' creato da TzBaseFilterableComponentProps
  FFlags := TzDbChartFlags.Create;
  FSeries := TzChartSeriesItems.Create(self);
end;

destructor TzDbChartProps.Destroy;
begin
  FreeAndNil(FSeries);
  FreeAndNil(FFlags);
  inherited;
end;

procedure TzDbChartProps.Assign(Source: TPersistent);
var
  Item: TzDbChartProps;
begin
  inherited Assign(Source); // Description, ToolActions e ToolFilters

  if Source is TzDbChartProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbChartProps(Source);
      Name := Item.Name;

      ArgumentField := Item.ArgumentField;
      AxisTitleX := Item.AxisTitleX;
      AxisTitleY := Item.AxisTitleY;
      Caption := Item.Caption;
      DataSet := Item.DataSet;
      Kind := Item.Kind;
      MaxPoints := Item.MaxPoints;
      ReportName := Item.ReportName;
      Sort := Item.Sort;
      Title := Item.Title;
      TopN := Item.TopN;
      TopNOthers := Item.TopNOthers;

      Flags.Assign(Item.Flags);
      Series.Assign(Item.Series);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzDbChartProps.zComponentType: TzComponentType;
begin
  result := ctChart;
end;

function TzDbChartProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

procedure TzDbChartProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbChartProps.SetFlags(const Value: TzDbChartFlags);
begin
  FFlags.Assign(Value);
end;

procedure TzDbChartProps.SetSeries(const Value: TzChartSeriesItems);
begin
  FSeries.Assign(Value);
end;

procedure TzDbChartProps.LoadFromBase;
var
  Item: TzDbChartProps;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDbCharts.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDbChartProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDbChartProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbCharts.get(Name, true);

  if Item <> self then
    Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbCharts, 'TzDbChartProps.SaveToBase');
end;

{ TzDbSchedulerFlags }

constructor TzDbSchedulerFlags.Create;
begin
  inherited;
  FUpdateCount := 0;
  FAutoCustomFields := true;
  FButtonRefresh := true;
  FDateNavigator := False;
  FParams := False;
  FReadOnly := False;
  FRecurrence := true;
  FToolbar := true;
  FWorkTimeOnly := False;
end;

procedure TzDbSchedulerFlags.Assign(Source: TPersistent);
var
  src: TzDbSchedulerFlags;
begin
  if Source is TzDbSchedulerFlags then
  begin
    src := TzDbSchedulerFlags(Source);
    BeginUpdate;
    try
      FAutoCustomFields := src.AutoCustomFields;
      FButtonRefresh := src.ButtonRefresh;
      FDateNavigator := src.DateNavigator;
      FParams := src.Params;
      FReadOnly := src.ReadOnly;
      FRecurrence := src.Recurrence;
      FToolbar := src.Toolbar;
      FWorkTimeOnly := src.WorkTimeOnly;
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

procedure TzDbSchedulerFlags.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TzDbSchedulerFlags.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if FUpdateCount = 0 then
    Changed;
end;

procedure TzDbSchedulerFlags.Changed;
begin
  if (FUpdateCount = 0) and assigned(FOnChange) then
    FOnChange(self);
end;

procedure TzDbSchedulerFlags.SetAutoCustomFields(const Value: boolean);
begin
  FAutoCustomFields := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetButtonRefresh(const Value: boolean);
begin
  FButtonRefresh := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetDateNavigator(const Value: boolean);
begin
  FDateNavigator := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetParams(const Value: boolean);
begin
  FParams := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetReadOnly(const Value: boolean);
begin
  FReadOnly := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetRecurrence(const Value: boolean);
begin
  FRecurrence := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetToolbar(const Value: boolean);
begin
  FToolbar := Value;
  Changed;
end;

procedure TzDbSchedulerFlags.SetWorkTimeOnly(const Value: boolean);
begin
  FWorkTimeOnly := Value;
  Changed;
end;

{ TzSchedulerMapping }

const
  // Convenzione dei nomi: la tabella USR_UTENTI_AGENDA e le procedure dei
  // calendari (CALENDARIO_*, PRENOTAZIONI_SCHEDULER). Piu' nomi separati da
  // punto e virgola: vale il primo presente nel dataset. State e ResourceID
  // non hanno convenzione: STATO e i campi delle risorse cambiano significato
  // da una tabella all'altra
  zSchedulerFieldConvention: array [TzSchedulerField] of string = ('ID;ID_AGENDA;ID_EVENTO', 'INIZIO;DATA_INIZIO', 'FINE;DATA_FINE',
    'OGGETTO;TITOLO_EVENTO;TITOLO;DESCRIZIONE', 'MESSAGGIO;CORPO_EVENTO;NOTE', 'LUOGO', 'COLORE', 'TIPO_EVENTO', 'OPZIONI', 'PARENT_ID', 'RICORRENZA',
    'RICORRENZA_INFO', '', '', 'ACTUAL_INIZIO', 'ACTUAL_FINE', 'PROMEMORIA_DATA', 'PROMEMORIA_MINUTI_PREAVVISO', 'PROMEMORIA_RESOURCES_DATA',
    'ATTIVITA_COMPLETATA', 'ATTIVITA_INDICE', 'ATTIVITA_LINKS', 'ATTIVITA_STATUS');

  zSchedulerFieldCaption: array [TzSchedulerField] of string = ('ID', 'Start', 'Finish', 'Caption', 'Message', 'Location', 'LabelColor', 'EventType',
    'Options', 'ParentID', 'RecurrenceIndex', 'RecurrenceInfo', 'ResourceID', 'State', 'ActualStart', 'ActualFinish', 'ReminderDate',
    'ReminderMinutesBeforeStart', 'ReminderResourcesData', 'TaskComplete', 'TaskIndex', 'TaskLinks', 'TaskStatus');

function TzSchedulerMapping.GetName(Index: integer): string;
begin
  result := FNames[TzSchedulerField(Index)];
end;

procedure TzSchedulerMapping.SetName(Index: integer; const Value: string);
begin
  FNames[TzSchedulerField(Index)] := Trim(Value);
end;

procedure TzSchedulerMapping.Assign(Source: TPersistent);
var
  Field: TzSchedulerField;
begin
  if Source is TzSchedulerMapping then
  begin
    for Field := Low(TzSchedulerField) to High(TzSchedulerField) do
      FNames[Field] := TzSchedulerMapping(Source).FNames[Field];
  end
  else
    inherited;
end;

function TzSchedulerMapping.Configured(const Field: TzSchedulerField): string;
begin
  result := FNames[Field];
end;

procedure TzSchedulerMapping.SetConfigured(const Field: TzSchedulerField; const Value: string);
begin
  FNames[Field] := Trim(Value);
end;

function TzSchedulerMapping.Resolve(const Field: TzSchedulerField; DataSet: TDataSet): string;
var
  Candidate: string;
begin
  result := '';

  if not assigned(DataSet) then
    Exit;

  // configurato: vale solo se il campo c'e', senza ripiegare sulla convenzione
  if FNames[Field] <> '' then
  begin
    if assigned(DataSet.FindField(FNames[Field])) then
      result := FNames[Field];
    Exit;
  end;

  for Candidate in zSchedulerFieldConvention[Field].Split([';']) do
    if (Candidate <> '') and assigned(DataSet.FindField(Candidate)) then
      Exit(Candidate);
end;

function TzSchedulerMapping.MissingRequired(DataSet: TDataSet): string;
var
  Field: TzSchedulerField;
begin
  result := '';

  for Field := Low(TzSchedulerField) to High(TzSchedulerField) do
    if IsRequired(Field) and (Resolve(Field, DataSet) = '') then
    begin
      if result <> '' then
        result := result + ', ';
      result := result + FieldCaption(Field);
    end;
end;

class function TzSchedulerMapping.IsRequired(const Field: TzSchedulerField): boolean;
begin
  // TcxSchedulerDBStorage.IsDataSettingsValid
  result := Field in [sfID, sfStart, sfFinish, sfEventType, sfOptions];
end;

class function TzSchedulerMapping.FieldCaption(const Field: TzSchedulerField): string;
begin
  result := zSchedulerFieldCaption[Field];
end;

{ TzDbSchedulerProps }

constructor TzDbSchedulerProps.Create(Collection: TCollection);
begin
  inherited;
  FCaption := zDefaultCardCaption;
  FDataSet := '';
  FPeriodFromParam := '';
  FPeriodToParam := '';
  FResourceColorField := '';
  FResourceDataSet := '';
  FResourceIdField := '';
  FResourceNameField := '';
  FTitle := '';
  FViewMode := svmWorkWeek;
  FWorkStart := 480;
  FWorkFinish := 1200;
  // ToolFilters e' gia' creato da TzBaseFilterableComponentProps
  FFlags := TzDbSchedulerFlags.Create;
  FMapping := TzSchedulerMapping.Create;
end;

destructor TzDbSchedulerProps.Destroy;
begin
  FreeAndNil(FMapping);
  FreeAndNil(FFlags);
  inherited;
end;

procedure TzDbSchedulerProps.Assign(Source: TPersistent);
var
  Item: TzDbSchedulerProps;
begin
  inherited Assign(Source); // Description, ToolActions e ToolFilters

  if Source is TzDbSchedulerProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzDbSchedulerProps(Source);
      Name := Item.Name;

      Caption := Item.Caption;
      DataSet := Item.DataSet;
      PeriodFromParam := Item.PeriodFromParam;
      PeriodToParam := Item.PeriodToParam;
      ResourceColorField := Item.ResourceColorField;
      ResourceDataSet := Item.ResourceDataSet;
      ResourceIdField := Item.ResourceIdField;
      ResourceNameField := Item.ResourceNameField;
      Title := Item.Title;
      ViewMode := Item.ViewMode;
      WorkStart := Item.WorkStart;
      WorkFinish := Item.WorkFinish;

      Flags.Assign(Item.Flags);
      Mapping.Assign(Item.Mapping);
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzDbSchedulerProps.zComponentType: TzComponentType;
begin
  result := ctScheduler;
end;

function TzDbSchedulerProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

procedure TzDbSchedulerProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzDbSchedulerProps.SetFlags(const Value: TzDbSchedulerFlags);
begin
  FFlags.Assign(Value);
end;

procedure TzDbSchedulerProps.SetMapping(const Value: TzSchedulerMapping);
begin
  FMapping.Assign(Value);
end;

function TzDbSchedulerProps.PeriodFromParamName: string;
begin
  result := Trim(FPeriodFromParam);

  if result = '' then
    result := 'DAL_GIORNO';
end;

function TzDbSchedulerProps.PeriodToParamName: string;
begin
  result := Trim(FPeriodToParam);

  if result = '' then
    result := 'AL_GIORNO';
end;

procedure TzDbSchedulerProps.LoadFromBase;
var
  Item: TzDbSchedulerProps;
begin
  if Name.IsEmpty then
    Exit;

  Item := Base.zDbSchedulers.get(Name, False);

  if assigned(Item) then
    Assign(Item)
  else
    SaveToBase(False);
end;

procedure TzDbSchedulerProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzDbSchedulerProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zDbSchedulers.get(Name, true);

  if Item <> self then
    Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csDbSchedulers, 'TzDbSchedulerProps.SaveToBase');
end;

{ TzFile }

constructor TzFileViewerProps.Create(Collection: TCollection);
begin
  inherited;
  FDataSet := '';
  FFieldName := '';
  FFieldNameOID := '';
  FFolder := '';
  FLocked := False;
end;

procedure TzFileViewerProps.Assign(Source: TPersistent);
var
  src: TzFileViewerProps;
begin
  inherited Assign(Source); // per Description&ToolActions

  if Source is TzFileViewerProps then
  begin
    src := TzFileViewerProps(Source);
    FDataSet := src.DataSet;
    FFieldName := src.FieldName;
    FFieldNameOID := src.FieldNameOID;
    FFolder := src.Folder;
    FLocked := src.Locked;
  end;
end;

function TzFileViewerProps.zComponentType: TzComponentType;
begin
  result := ctFile;
end;

procedure TzFileViewerProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzFileViewerProps;
begin
  inherited;
  if Name.IsEmpty then
    Exit;
  Item := Base.zFiles.get(Name, true);
  Item.Assign(self);
  if SaveToLZ then
    Base.SaveZip(csFiles, 'TzFile.SaveToBase');
end;

function TzFileViewerProps.GetDataSet_Obj: TzDataSet;
begin
  result := Base.zDataSets.get(DataSet, False);
end;

procedure TzFileViewerProps.SetDataSet(const Value: string);
begin
  FDataSet := Value;
end;

procedure TzFileViewerProps.SetDataSet_Obj(const Value: TzDataSet);
begin
  FDataSet := ItemName(Value);
end;

procedure TzFileViewerProps.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TzFileViewerProps.SetFieldNameOID(const Value: string);
begin
  FFieldNameOID := Value;
end;

procedure TzFileViewerProps.SetFolder(const Value: string);
begin
  FFolder := Value;
end;

procedure TzFileViewerProps.SetLocked(const Value: boolean);
begin
  FLocked := Value;
end;

procedure TzPivotField.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('Kind', ReadKind, WriteKind, FKind <> fkField);
end;

procedure TzPivotField.ReadKind(Reader: TReader);
begin
  FKind := TzPivotFieldKind(GetEnumValue(TypeInfo(TzPivotFieldKind), Reader.ReadIdent));
end;

procedure TzPivotField.WriteKind(Writer: TWriter);
begin
  Writer.WriteIdent(GetEnumName(TypeInfo(TzPivotFieldKind), ord(FKind)));
end;

procedure TzPivotField.WriteJsonExtraProperties(Writer: TJsonTextWriter);
begin
  inherited;

  if FKind <> fkField then
  begin
    Writer.WritePropertyName('Kind');
    Writer.WriteValue(GetEnumName(TypeInfo(TzPivotFieldKind), ord(FKind)));
  end;
end;

function TzPivotField.ReadJsonExtraProperty(const PropName: string; Reader: TJsonTextReader): boolean;
var
  EnumOrd: integer;
begin
  if Reader.TokenType in [TJsonToken.StartObject, TJsonToken.StartArray] then
    Exit(False);

  result := SameText(PropName, 'Kind');

  if result then
  begin
    if Reader.TokenType = TJsonToken.String then
    begin
      EnumOrd := GetEnumValue(TypeInfo(TzPivotFieldKind), Reader.Value.AsString);
      if EnumOrd >= 0 then
        FKind := TzPivotFieldKind(EnumOrd);
    end;
  end
  else
    result := inherited ReadJsonExtraProperty(PropName, Reader);
end;

class procedure TzPivotField.DescribeJsonExtraProperties(Schema: TJsonTextWriter);
var
  i: integer;
begin
  inherited;
  Schema.WritePropertyName('Kind');
  Schema.WriteStartObject;
  Schema.WritePropertyName('type');
  Schema.WriteValue('string');
  Schema.WritePropertyName('enum');
  Schema.WriteStartArray;
  for i := ord(Low(TzPivotFieldKind)) to ord(High(TzPivotFieldKind)) do
    Schema.WriteValue(GetEnumName(TypeInfo(TzPivotFieldKind), i));
  Schema.WriteEndArray;
  Schema.WritePropertyName('default');
  Schema.WriteValue(GetEnumName(TypeInfo(TzPivotFieldKind), ord(fkField)));
  Schema.WriteEndObject;
end;

constructor TzPivotField.Create(Collection: TCollection);
begin
  inherited;
  FFieldOrigin := '';
  FDomain := nil;
  FCaption := '';
  FSizeable := true;
  FMaxWidth := 0;
  FWidth := -1;
  FVisible := true;
  zCtrlType := ctDefault;

  FArea := faFilter;
  FAreaIndex := -1;
  FDataVisibility := dvAllCells;
  FDisplayFormat := '';
  FGroupIndex := -1;
  FHidden := False;
  FMinWidth := cxPivotGridDefaultFieldMinWidth;
  FSummaryType := stSum;
  FSortOrder := soNone;
  FSummaryVariation := svNone;
  FTotalsVisibility := tvAutomatic;
  FTopValueCount := 0;
  FTopValueShowOthers := False;

  FKind := fkField;
  FColumnFieldName := '';
  FSourceFieldName := '';
  FTotalMode := ctmNull;
  FColumnValues := TStringList.Create;
  FGrandTotalExcludeValues := TStringList.Create;
end;

destructor TzPivotField.Destroy;
begin
  FreeAndNil(FColumnValues);
  FreeAndNil(FGrandTotalExcludeValues);
  inherited;
end;

procedure TzPivotField.Assign(Source: TPersistent);
var
  Item: TzPivotField;
begin
  inherited;
  if Source is TzPivotField then
  begin
    Item := Source as TzPivotField;
    Name := Item.Name;
    FFieldOrigin := Item.FieldOrigin;
    Domain := Item.Domain;
    Caption := Item.FCaption; // campo, non prop
    Width := Item.Width;
    MaxWidth := Item.MaxWidth;
    Sizeable := Item.Sizeable;
    Visible := Item.Visible;
    zCtrlType := Item.FzCtrlType; // campo, non prop

    Area := Item.Area;
    AreaIndex := Item.AreaIndex;
    DataVisibility := Item.DataVisibility;
    DisplayFormat := Item.DisplayFormat;
    GroupIndex := Item.GroupIndex;
    Hidden := Item.Hidden;
    MinWidth := Item.MinWidth;
    SummaryType := Item.SummaryType;
    SortOrder := Item.SortOrder;
    SummaryVariation := Item.SummaryVariation;
    TotalsVisibility := Item.TotalsVisibility;
    TopValueCount := Item.TopValueCount;
    TopValueShowOthers := Item.TopValueShowOthers;

    FKind := Item.FKind;
    FColumnFieldName := Item.FColumnFieldName;
    FSourceFieldName := Item.FSourceFieldName;
    FColumnValues.Assign(Item.FColumnValues);
    FGrandTotalExcludeValues.Assign(Item.FGrandTotalExcludeValues);
    FTotalMode := Item.FTotalMode;
  end;
end;

procedure TzPivotField.SetColumnValues(const Value: TStrings);
begin
  FColumnValues.Assign(Value);
end;

procedure TzPivotField.SetGrandTotalExcludeValues(const Value: TStrings);
begin
  FGrandTotalExcludeValues.Assign(Value);
end;

function TzPivotField.GetCaption: string;
begin
  result := FCaption;

  if result = '' then
    if assigned(Domain) then
      result := Domain.DisplayLabel;
end;

function TzPivotField.GetzCtrlType: TzCtrlType;
begin
  result := FzCtrlType;

  if result = ctDefault then
    if assigned(Domain) then
      result := Domain.zCtrlType;
end;

function TzPivotField.isCaptionStored: boolean;
begin
  result := FCaption <> '';
end;

function TzPivotField.IsCtrlTypeStored: boolean;
begin
  result := FzCtrlType <> ctDefault;
end;

{ TzPivotFields }

constructor TzPivotFields.Create(azDbPivotProps: TzDbPivotProps);
begin
  inherited Create(TzPivotField, 'Fields', -1, nil);
  zDbPivotProps := azDbPivotProps;
  Sorted := False;
end;

procedure TzPivotFields.AssignFromPivotFields(cxDBPivotGrid: TcxDBPivotGrid);
var
  i: integer;
  Field: TcxDbPivotGridField;

  backup: TzPivotFields;
  Item: TzPivotField;
  bkItem: TzPivotField;
begin
  backup := TzPivotFields.Create(nil);
  try
    backup.Assign(self);

    Clear;

    for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    begin
      Field := TcxDbPivotGridField(cxDBPivotGrid.Fields[i]);

      if Field.Tag = zCalcFieldTag then
        Continue;

      Item := Add;
      Item.Name := Field.DataBinding.FieldName;
      Item.Caption := Field.Caption;
      Item.Index := Field.Index;
      Item.Width := Field.Width;
      Item.Visible := Field.Visible;

      Item.Area := Field.Area;
      Item.AreaIndex := Field.AreaIndex;
      Item.DataVisibility := Field.DataVisibility;
      Item.DisplayFormat := Field.DisplayFormat;
      Item.GroupIndex := Field.GroupIndex;
      Item.Hidden := Field.Hidden;
      Item.MinWidth := Field.MinWidth;
      Item.SummaryType := Field.SummaryType;
      Item.SortOrder := Field.SortOrder;
      Item.SummaryVariation := Field.SummaryVariation;
      Item.TotalsVisibility := Field.TotalsVisibility;
      Item.TopValueCount := Field.TopValueCount;
      Item.TopValueShowOthers := Field.TopValueShowOthers;
    end;

    // riassegna readonly e zCtrlType
    for bkItem in backup do
    begin
      Item := get(bkItem.Name, False);

      if assigned(Item) then
      begin
        Item.MaxWidth := bkItem.MaxWidth;
        Item.Sizeable := bkItem.Sizeable;
        Item.zCtrlType := bkItem.zCtrlType;
        Item.GrandTotalExcludeValues := bkItem.GrandTotalExcludeValues;

        // DIV-PVT-3: una didascalia uguale a quella del dominio resta ereditata
        // e non diventa esplicita, cosi' un cambio nel dizionario dei dati arriva ai pivot gia' salvati
        Item.Domain := bkItem.Domain;
        if assigned(Item.Domain) and SameText(Item.Caption, Item.Domain.DisplayLabel) then
          Item.Caption := '';
      end;
    end;

    // reinnesta i field calcolati dal backup, con AreaIndex già
    // aggiornato da PivotLayoutChanged prima della chiamata a questo metodo
    for bkItem in backup do
    begin
      if bkItem.Kind = fkCalc then
      begin
        Item := Add;
        Item.Assign(bkItem);
      end;
    end;

  finally
    FreeAndNil(backup);
  end;
end;

procedure TzPivotFields.AssignToPivotFields(cxDBPivotGrid: TcxDBPivotGrid);

  function GetFieldByName(const FieldName: string): TcxDbPivotGridField;
  var
    i: integer;
    Field: TcxDbPivotGridField;
  begin
    result := nil;

    for i := 0 to cxDBPivotGrid.FieldCount - 1 do
    begin
      Field := TcxDbPivotGridField(cxDBPivotGrid.Fields[i]);

      if AnsiCompareText(Field.DataBinding.FieldName, FieldName) = 0 then
      begin
        result := Field;
        Break;
      end;
    end;
  end;

var
  i: integer;
  FieldName: string;
  Field: TField;
  pivotFld: TcxDbPivotGridField;
  Item: TzPivotField;
begin
  if count = 0 then
    Exit;

  cxDBPivotGrid.BeginUpdate;
  try
    for Item in self do
    begin

      if Item.Kind = fkCalc then
        Continue;

      pivotFld := GetFieldByName(Item.Name);

      if not assigned(pivotFld) then
        Continue;

      // manca il dominio per valutare correttamente il displayLabel
      if not Item.Caption.IsEmpty then
        pivotFld.Caption := Item.Caption;

      pivotFld.Visible := Item.Visible;
      pivotFld.Index := Item.Index;

      if Item.Width = -1 then
        pivotFld.Width := 100
      else
        pivotFld.Width := Item.Width;

      pivotFld.Area := Item.Area;
      pivotFld.AreaIndex := Item.AreaIndex;
      pivotFld.DataVisibility := Item.DataVisibility;
      pivotFld.DisplayFormat := Item.DisplayFormat;
      pivotFld.GroupIndex := Item.GroupIndex;
      pivotFld.Hidden := Item.Hidden;
      pivotFld.MinWidth := Item.MinWidth;
      pivotFld.SummaryType := Item.SummaryType;
      pivotFld.SortOrder := Item.SortOrder;
      pivotFld.SummaryVariation := Item.SummaryVariation;
      pivotFld.TotalsVisibility := Item.TotalsVisibility;
      pivotFld.TopValueCount := Item.TopValueCount;
      pivotFld.TopValueShowOthers := Item.TopValueShowOthers;

      if pivotFld.Properties is TcxSpinEditProperties then
        TcxSpinEditProperties(pivotFld.Properties).DisplayFormat := Item.DisplayFormat;
    end;
  finally
    cxDBPivotGrid.EndUpdate;
  end;
end;

procedure TzPivotFields.FillTreeList(MasterNode: TcxTreeListNode);
var
  Child: TcxTreeListNode;
  Item: TzPivotField;
begin
  sizSystem.EnterMethod(self, 'FillTreeList');

  MasterNode.TreeList.BeginUpdate;
  try
    for Item in self do
    begin
      Child := MasterNode.AddChild;
      Child.Values[0] := Item.DisplayName;
      Child.data := Item;
      Child.ImageIndex := -1;
      Child.SelectedIndex := -1;
    end;
  finally
    MasterNode.TreeList.EndUpdate;
  end;

  sizSystem.LeaveMethod(self, 'FillTreeList');
end;

procedure TzPivotFields.Reset(DataSet: TzFbDataSet);
var
  i: integer;
begin
  // DIV-PVT-2: i campi calcolati non vengono dal dataset, quindi restano
  for i := count - 1 downto 0 do
    if Items[i].Kind <> fkCalc then
      Delete(i);

  ValidateDataset(DataSet);
end;

procedure TzPivotFields.ValidateDataset(DataSet: TzFbDataSet);
var
  Field: TField;
  pivotFld: TzPivotField;
  i: integer;
  ListEmpty: boolean;
  NewFieldVisible: boolean;
begin
  if not assigned(DataSet) then
    Exit;

  BeginUpdate;
  try
    // eliminare i campi non pi� appartenenti al dataset
    for i := count - 1 downto 0 do
    begin
      Items[i].Domain := nil;

      if Items[i].Kind = fkCalc then
        Continue;

      if not assigned(DataSet.FindField(Items[i].Name)) then
        self.Delete(i);
    end;

    // ListEmpty := count = 0;
    ListEmpty := (count = 0) or
    // considera vuota se ci sono solo calcolati
      not(self.Find(
      function(f: TzPivotField): boolean
      begin
        result := f.Kind = fkField
      end) <> nil);

    // aggiunge i nuovi
    for i := 0 to DataSet.FieldCount - 1 do
      if not self.Exists(DataSet.Fields[i].FieldName) then
      begin
        Field := DataSet.Fields[i];
        pivotFld := Add;
        pivotFld.Name := Field.FieldName;
        pivotFld.FieldOrigin := DataSet.FieldOrigin(Field);
        pivotFld.Domain := Base.zDataDictionary.get(pivotFld.FieldOrigin, true);

        NewFieldVisible := Field.Visible and ListEmpty;

        if NewFieldVisible then
        begin

          if DataSet.IsDetailParamField(pivotFld.Name) then
            NewFieldVisible := False
          else
            if IndexText(pivotFld.Name, ['USER_INS', 'DATA_INS', 'USER_MDF', 'DATA_MDF', 'SYSDBA_DATA_MDF']) <> -1 then
              NewFieldVisible := False
            else
              if IndexText(pivotFld.Name, ['USR_USER_INS', 'USR_DATA_INS', 'USR_USER_MDF', 'USR_DATA_MDF', 'USR_DATA_DBA']) <> -1 then
                NewFieldVisible := False;
        end;

        pivotFld.Caption := '';
        pivotFld.Width := -1;
        pivotFld.Visible := NewFieldVisible;
      end;
  finally
    EndUpdate;
  end;
end;

{ TzLastMdf }

constructor TzLastMdf.Create;
begin
  inherited;
  Clear;
end;

procedure TzLastMdf.Clear;
begin
  FUserName := '';
  FDateTime := 0;
end;

function TzLastMdf.IsUserNameStored: boolean;
begin
  result := not UserName.IsEmpty;
end;

function TzLastMdf.IsDateTimeStored: boolean;
begin
  result := DateTime <> 0;
end;

procedure TzLastMdf.Modified;
begin
  FUserName := Base.CurrentUser;
  FDateTime := Now;
end;

{ TzStoredCollectionItem }

constructor TzStoredCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  FLastMdf := TzLastMdf.Create;
end;

destructor TzStoredCollectionItem.Destroy;
begin
  FreeAndNil(FLastMdf);
  inherited;
end;

procedure TzStoredCollectionItem.Modified;
begin
  LastMdf.Modified;
end;

procedure TzStoredCollectionItem.SaveToBase(SaveToLZ: boolean);
begin
  Modified;
end;

constructor TzMapProps.Create(Collection: TCollection);
begin
  inherited;
  FGeocodingService := gsOpenStreetMap;
  FMapService := msOpenLayers;
  FMapChangedInterval := 300;
  FZoomLevel := 12;
end;

procedure TzMapProps.SaveToBase(SaveToLZ: boolean);
var
  Item: TzMapProps;
begin
  inherited;

  if Name.IsEmpty then
    Exit;

  Item := Base.zMaps.get(Name, true);
  Item.Assign(self);

  if SaveToLZ then
    Base.SaveZip(csMaps, 'TzMapProps.SaveToBase');
end;

procedure TzMapProps.Assign(Source: TPersistent);
var
  Item: TzMapProps;
begin
  inherited Assign(Source); // per Description&ToolActions

  if Source is TzMapProps then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := Source as TzMapProps;
      Name := Item.Name;

      GeocodingService := Item.GeocodingService;
      MapChangedInterval := Item.MapChangedInterval;
      MapService := Item.MapService;
      ZoomLevel := Item.ZoomLevel;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end;
end;

function TzMapProps.zComponentType: TzComponentType;
begin
  inherited;
  result := ctMap;
end;

procedure TzSystem.SwitchLookupCtrlType(FromCtrlType, ToCtrlType: TzCtrlType);
var
  zDomain: TzDomain;
  zDbViewProps: TzDbViewProps;
  zColumn: TzColumn;
  zDbCardProps: TzDbCardProps;
  zControlProps: TzControlProps;
  zDbPivotProps: TzDbPivotProps;
  zPivotField: TzPivotField;
  zDbRecordViewProps: TzDbRecordViewProps;
  zRecordViewRow: TzRecordViewRow;
  zDbTreeProps: TzDbTreeProps;
  zTreeColumn: TzTreeColumn;
begin
  /// DataDictionary
  for zDomain in zDataDictionary do
    if zDomain.zCtrlType = FromCtrlType then
      zDomain.zCtrlType := ToCtrlType;

  /// Card
  for zDbCardProps in zDbCards do
    for zControlProps in zDbCardProps.Controls do
      if zControlProps.zCtrlType = FromCtrlType then
        zControlProps.zCtrlType := ToCtrlType;

  /// View
  for zDbViewProps in zDbViews do
    for zColumn in zDbViewProps.Columns do
      if zColumn.zCtrlType = FromCtrlType then
        zColumn.zCtrlType := ToCtrlType;

  /// Pivot
  for zDbPivotProps in zDbPivots do
    for zPivotField in zDbPivotProps.Fields do
      if zPivotField.zCtrlType = FromCtrlType then
        zPivotField.zCtrlType := ToCtrlType;

  /// Vista record: solo il tipo scritto sulla riga, non quello ereditato dal dominio
  for zDbRecordViewProps in zDbRecordViews do
    for zRecordViewRow in zDbRecordViewProps.Rows do
      if zRecordViewRow.FzCtrlType = FromCtrlType then
        zRecordViewRow.zCtrlType := ToCtrlType;

  /// Albero: solo il tipo scritto sulla colonna, non quello ereditato dal dominio
  for zDbTreeProps in zDbTrees do
    for zTreeColumn in zDbTreeProps.Columns do
      if zTreeColumn.FzCtrlType = FromCtrlType then
        zTreeColumn.zCtrlType := ToCtrlType;

  //
  SaveZip(csAll, '');
end;

procedure TzSystem.AssignFieldOnChangeEvent(Field: TField; const EventName: string);
begin
  if assigned(FOnAssignFieldOnChangeEvent) then
    OnAssignFieldOnChangeEvent(Field, EventName);
end;

procedure TzSecurity.OTP_SendMail2User(const idSessione: integer);
var
  Mail: TMail;
  SMTPServerParams: TSMTPServerParams;
  sp: TFDStoredProc;
begin
  siMain.EnterMethod(self, 'OTP_SendMail2User');

  /// /////////////////////////////////////////////

  sp := CreateStoredProc(spUSR_GENERA_TOKEN_OTP);
  try
    sp.Prepare;
    sp.ParamByName('ID_SESSIONE').Value := idSessione;
    sp.ExecProc;

    SMTPServerParams.Init;
    SMTPServerParams.From := sp.ParamByName('EMAIL_INVIO_OTP').AsString;
    SMTPServerParams.FromAddress := sp.ParamByName('EMAIL_INVIO_OTP').AsString;
    SMTPServerParams.ReplyTo := sp.ParamByName('EMAIL_INVIO_OTP').AsString;
    SMTPServerParams.Host := sp.ParamByName('SMTP_HOST').AsString;
    SMTPServerParams.Port := sp.ParamByName('SMTP_PORT').AsInteger;
    SMTPServerParams.UserName := sp.ParamByName('SMTP_USERNAME').AsString;
    SMTPServerParams.Password := sp.ParamByName('SMTP_PASSWORD').AsString;
    SMTPServerParams.AuthenticationType := sp.ParamByName('AUTHENTICATION_TYPE').AsString;
    SMTPServerParams.ssl := sp.ParamByName('SSL').AsString;
    SMTPServerParams.ssl_ver := sp.ParamByName('SSL_VER').AsString;

    Mail.Init;
    Mail.A := sp.ParamByName('MAIL_UTENTE').AsString;
    Mail.Oggetto := sp.ParamByName('MAIL_INVIO_OTP_OGGETTO').AsString;
    Mail.CorpoTxt := sp.ParamByName('MAIL_INVIO_OTP_CORPO').AsString;
    Mail.CorpoHtml := sp.ParamByName('MAIL_INVIO_OTP_CORPO_HTML').AsString;
  finally
    FreeAndNil(sp);
  end;

  /// /////////////////////////////////////////////

  StartWait('Invio mail', true);
  try
    SendMail(Mail, SMTPServerParams);
  finally
    StopWait;
  end;

  /// /////////////////////////////////////////////

  siMain.LeaveMethod(self, 'OTP_SendMail2User');
end;

function TzSecurity.OTP_Query(out token: string): boolean;
begin
  result := False;
  token := '';

  while InputQuery('Verifica Token OTP', 'Token:', token) and not application.Terminated do
  begin
    // Secondo fattore 2026-10-16: un codice sbagliato non esce piu' da Login
    // come eccezione (la sessione era gia' aperta), si mostra e si riprova
    try
      result := OTP_Validate(LoginParams.SessionID, token);
    except
      on e: Exception do
        ConfirmOk(e.Message, mtWarning);
    end;

    if result then
      Exit;
  end;
end;

function TzSecurity.OTP_Validate(const idSessione: integer; const token: string): boolean;
var
  sp: TFDStoredProc;
  error: string;
begin
  result := False;

  sp := CreateStoredProc(spUSR_VERIFICA_TOKEN_OTP);
  try
    sp.Prepare;
    sp.ParamByName('ID_SESSIONE').Value := idSessione;
    sp.ParamByName('TOKEN_OTP').AsString := token;
    sp.ParamByName('REMOTE_ADDRESS').AsString := '';
    sp.ParamByName('RAISE_ERROR').AsBoolean := False;
    sp.ExecProc;
    result := sp.ParamByName('OK').AsBoolean;
    error := sp.ParamByName('ERROR_MESSAGE').AsString;
  finally
    FreeAndNil(sp);
  end;

  if not result then
    if not error.IsEmpty then
      raise Exception.Create(error);
end;

// ---------------------------------------------------------------------------
// Secondo fattore con app di autenticazione (TOTP) 2026-10-16
//
// Codice, segreto e codici di recupero li controlla il database (USR_TOTP_*,
// rilascio OUT/20261016-secondo-fattore-totp-wt/001): qui si generano solo il
// segreto e i codici con la sorgente casuale di Windows, che Firebird non ha,
// e si mostrano le finestre. La mail resta la riserva e il metodo di chi non
// ha ancora registrato l'app.
// ---------------------------------------------------------------------------

function MessaggioErroreDatabase(e: Exception): string;
begin
  if e is EIBNativeException then
    result := Trim(TranslateFIBError(EIBNativeException(e)))
  else
    result := e.Message;
end;

procedure TzSecurity.EseguiStoredProcTotp(sp: TFDStoredProc);
var
  TransazioneAvviata: boolean;
begin
  // Ogni passo va confermato subito: se l'utente chiude il programma fra la
  // registrazione e l'attivazione, il database deve gia' avere il segreto.
  // Una transazione gia' aperta da chi chiama resta sua.
  TransazioneAvviata := not sp.Transaction.Active;

  if TransazioneAvviata then
    sp.Transaction.StartTransaction;
  try
    sp.ExecProc;

    if TransazioneAvviata then
      sp.Transaction.Commit;
  except
    if TransazioneAvviata and sp.Transaction.Active then
      sp.Transaction.Rollback;

    raise;
  end;
end;

function TzSecurity.TotpDisponibile: boolean;
var
  Valore: Variant;
begin
  if FTotpDisponibile = 0 then
  begin
    FTotpDisponibile := 2;

    // zPack e' comune a programmi e database che il secondo fattore con app
    // non lo hanno: prima di chiamare la funzione si controlla che esista
    if zSystem.zFbDatabase.ExecSQLScalar('SELECT COUNT(*) FROM RDB$FUNCTIONS WHERE RDB$FUNCTIONS.RDB$FUNCTION_NAME = ''USR_TOTP_DISPONIBILE'' AND RDB$FUNCTIONS.RDB$PACKAGE_NAME IS NULL') > 0 then
    begin
      Valore := zSystem.zFbDatabase.ExecSQLScalar('SELECT USR_TOTP_DISPONIBILE() FROM RDB$DATABASE');

      if (not VarIsNull(Valore)) and Valore then
        FTotpDisponibile := 1;
    end;

    sizSystem.LogBoolean('TotpDisponibile', FTotpDisponibile = 1);
  end;

  result := FTotpDisponibile = 1;
end;

function TzSecurity.TotpAttivo: boolean;
var
  Valore: Variant;
begin
  result := False;

  if not TotpDisponibile then
    Exit;

  Valore := zSystem.zFbDatabase.ExecSQLScalar('SELECT USR_TOTP_STATO.ATTIVO FROM USR_TOTP_STATO');
  result := (not VarIsNull(Valore)) and Valore;
end;

function TzSecurity.TOTP_Validate(const idSessione: integer; const Codice: string; out MessaggioErrore: string): boolean;
var
  sp: TFDStoredProc;
begin
  result := False;
  MessaggioErrore := '';

  sp := CreateStoredProc(spUSR_TOTP_VERIFICA);
  try
    sp.Prepare;
    sp.ParamByName('ID_SESSIONE').Value := idSessione;
    sp.ParamByName('CODICE').AsString := Codice;
    // Con FALSE gli errori tornano come messaggio e la sessione resta valida
    // per un altro tentativo; il registro li conta comunque per il blocco
    sp.ParamByName('RAISE_ERROR').AsBoolean := False;
    EseguiStoredProcTotp(sp);

    result := sp.ParamByName('OK').AsBoolean;
    MessaggioErrore := sp.ParamByName('ERROR_MESSAGE').AsString;

    if result then
    begin
      FTotpCodiceRecuperoUsato := sp.ParamByName('CODICE_RECUPERO_USATO').AsBoolean;
      FTotpCodiciRecuperoRestanti := sp.ParamByName('CODICI_RECUPERO_RESTANTI').AsInteger;
    end;
  finally
    FreeAndNil(sp);
  end;
end;

function TzSecurity.TotpAttiva(const Codice: string; out MessaggioErrore: string): boolean;
var
  sp: TFDStoredProc;
begin
  result := False;
  MessaggioErrore := '';

  sp := CreateStoredProc(spUSR_TOTP_ATTIVA);
  try
    // USR_TOTP_ATTIVA risponde solo con eccezioni: il messaggio va nella
    // finestra, che resta aperta per il codice successivo
    try
      sp.Prepare;
      sp.ParamByName('CODICE').AsString := Codice;
      EseguiStoredProcTotp(sp);
      result := True;
    except
      on e: Exception do
        MessaggioErrore := MessaggioErroreDatabase(e);
    end;
  finally
    FreeAndNil(sp);
  end;
end;

function TzSecurity.TotpRegistraInterno(const TestoAnnulla: string): boolean;
var
  Segreto: string;
  IndirizzoOtpauth: string;
  sp: TFDStoredProc;
begin
  Segreto := GeneraSegretoTotp;

  sp := CreateStoredProc(spUSR_TOTP_REGISTRA);
  try
    sp.Prepare;
    sp.ParamByName('SEGRETO_BASE32').AsString := Segreto;
    // EMITTENTE resta NULL: il database usa "WT <nome del database>"
    EseguiStoredProcTotp(sp);
    IndirizzoOtpauth := sp.ParamByName('INDIRIZZO_OTPAUTH').AsString;
  finally
    FreeAndNil(sp);
  end;

  result := TotpRegistraApp(IndirizzoOtpauth, SegretoAGruppi(Segreto), TestoAnnulla,
    function(const Codice: string; out MessaggioErrore: string): boolean
    begin
      result := TotpAttiva(Codice, MessaggioErrore);
    end);

  Segreto := '';
  IndirizzoOtpauth := '';

  // Registrata ma non attivata: il database la tiene in sospeso e la
  // registrazione successiva la sostituisce
  if result then
    TotpImpostaCodiciRecupero;
end;

procedure TzSecurity.TotpImpostaCodiciRecupero;
var
  Codici: TArray<string>;
  sp: TFDStoredProc;
begin
  Codici := GeneraCodiciRecupero;

  sp := CreateStoredProc(spUSR_TOTP_CODICI_RECUPERO_IMPOSTA);
  try
    sp.Prepare;
    sp.ParamByName('CODICI').AsString := string.Join(sLineBreak, Codici);
    EseguiStoredProcTotp(sp);
  finally
    FreeAndNil(sp);
  end;

  // Solo dopo il salvataggio: un codice mostrato e non salvato non varrebbe
  TotpMostraCodiciRecupero(Codici);
end;

procedure TzSecurity.TotpProponiRegistrazione;
begin
  // Chi non ha ancora l'app ha appena confermato il codice via mail: e' il
  // momento in cui registrarla e' sicuro, perche' chi ha rubato la sola
  // password non arriva fin qui.
  if not ConfirmYesNo('Su questo database puoi usare un''app di autenticazione sul telefono al posto del codice via mail: ' +
    'il codice si legge sul telefono, anche senza rete e senza attendere la posta.' + sLineBreak + sLineBreak +
    'Vuoi attivarla adesso? Servono un paio di minuti.', mtConfirmation) then
    Exit;

  try
    TotpRegistraInterno('Piu'' tardi');
  except
    on e: Exception do
      ConfirmOk('L''app di autenticazione non e'' stata attivata: ' + MessaggioErroreDatabase(e) + sLineBreak +
        'L''accesso prosegue con il codice via mail.', mtWarning);
  end;
end;

procedure TzSecurity.TotpAvvisoCodiceRecupero;
begin
  if FTotpCodiciRecuperoRestanti >= 3 then
  begin
    ConfirmOk(Format('Hai usato un codice di recupero: ne restano %d.' + sLineBreak +
      'Se hai perso il telefono chiedi all''amministratore di azzerare l''app e registrane una nuova.', [FTotpCodiciRecuperoRestanti]), mtInformation);
    Exit;
  end;

  if not ConfirmYesNo(Format('Hai usato un codice di recupero: ne restano %d.' + sLineBreak +
    'Vuoi generarne di nuovi adesso? Quelli rimasti non varranno piu''.', [FTotpCodiciRecuperoRestanti]), mtWarning) then
    Exit;

  try
    TotpImpostaCodiciRecupero;
  except
    on e: Exception do
      ConfirmOk('I codici di recupero non sono stati rigenerati: ' + MessaggioErroreDatabase(e), mtWarning);
  end;
end;

function TzSecurity.OTP_QueryMail: boolean;
var
  Token: string;
begin
  OTP_SendMail2User(LoginParams.SessionID);
  result := OTP_Query(Token);
end;

function TzSecurity.SecondoFattoreVerifica: boolean;
var
  IdSessione: integer;
  Esito: TTotpEsitoCodice;
begin
  result := False;

  // Qualunque errore qui (mail non spedita, database) chiude l'accesso: la
  // sessione e' gia' aperta e un'eccezione che uscisse da Login lascerebbe
  // il programma avviato senza secondo fattore
  try
    // Senza app attiva: codice via mail come sempre, poi la proposta dell'app
    if not TotpAttivo then
    begin
      result := OTP_QueryMail;

      if result and TotpDisponibile then
        TotpProponiRegistrazione;

      Exit;
    end;

    FTotpCodiceRecuperoUsato := False;
    FTotpCodiciRecuperoRestanti := 0;
    IdSessione := LoginParams.SessionID;

    Esito := TotpChiediCodice(LoginParams.UserName,
      function(const Codice: string; out MessaggioErrore: string): boolean
      begin
        result := TOTP_Validate(IdSessione, Codice, MessaggioErrore);
      end, True);

    case Esito of
      tecVerificato:
        begin
          result := True;

          if FTotpCodiceRecuperoUsato then
            TotpAvvisoCodiceRecupero;
        end;
      tecRiservaMail:
        result := OTP_QueryMail;
    end;
  except
    on e: Exception do
    begin
      result := False;
      ConfirmOk('Verifica in due passaggi non riuscita: ' + MessaggioErroreDatabase(e), mtError);
    end;
  end;
end;

function TzSecurity.TotpRegistra: boolean;
begin
  if not TotpDisponibile then
    raise zException.Create('L''app di autenticazione non e'' prevista su questo database.');

  if TotpAttivo then
    raise zException.Create('L''app di autenticazione e'' gia'' attiva. Per sostituirla, per esempio con un telefono nuovo, va prima azzerata dall''amministratore.');

  result := TotpRegistraInterno('Annulla');
end;

function TzSecurity.TotpRigeneraCodiciRecupero: boolean;
begin
  result := False;

  if not TotpAttivo then
    raise zException.Create('I codici di recupero si generano solo con l''app di autenticazione attiva.');

  if not ConfirmYesNo('Vuoi generare nuovi codici di recupero? Quelli di prima non varranno piu''.', mtConfirmation) then
    Exit;

  TotpImpostaCodiciRecupero;
  result := True;
end;

procedure TzSecurity.TotpAzzera(const UserID: integer);
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc(spUSR_TOTP_AZZERA);
  try
    sp.Prepare;
    sp.ParamByName('USER_ID').Value := UserID;
    EseguiStoredProcTotp(sp);
  finally
    FreeAndNil(sp);
  end;
end;

function TzSystem.GetSkinPaletteName: string;
begin
  result := Settings['SkinPalette'];
end;

procedure TzSystem.SetSkinPaletteName(const Value: string);
begin
  Settings['SkinPalette'] := Value;

  // Mantis #286 - 2026-10-26: un .login non scrivibile non deve dare errore
  TzSecurity.ScriviFileLogin('SkinPalette', Value);
end;

procedure TzSystem.SetzTips(const Value: TzTips);
begin
  FzTips.Assign(Value);
end;

{ TzPickValues }

function TzPickValues.PickList: TzPickList;
begin
  result := nil;

  if assigned(Master) then
    if Master is TzPickList then
      result := Master as TzPickList;
end;

function TzPickValues.GetPickListDescription: string;
begin
  result := '';

  if assigned(Master) then
    if Master is TzPickList then
      result := TzPickList(Master).Description.Text;
end;

{ TzPickLists }

procedure TzPickLists.SavePickList(PickList: TzPickList);
var
  Idx: integer;
begin
  if not assigned(PickList) then
    Exit;

  if PickList.Name = '' then
    Exit;

  Idx := IndexOf(PickList.Name);

  if Idx = -1 then
    Add.Assign(PickList)
  else
    if Items[Idx] <> PickList then // se idem azzera i pickValues
      Items[Idx].Assign(PickList);
end;

constructor TzTip.Create(Collection: TCollection);
begin
  inherited;
  FFormName := '';
  FHeaderText := '';
  FDescription := '';
end;

destructor TzTip.Destroy;
begin
  inherited;
end;

procedure TzTip.Assign(Source: TPersistent);
var
  src: TzTip;
begin
  if Source is TzTip then
  begin
    if assigned(Collection) then
      Collection.BeginUpdate;
    try
      src := TzTip(Source);
      Name := src.Name;
      FormName := src.FormName;
      HeaderText := src.HeaderText;
      Description := src.Description;
    finally
      if assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

{ TzTips }

procedure TzTips.LoadFromActionList(const FormName: string; ActionList: TActionList);
var
  Action: TContainedAction;
  tip: TzTip;
  Hint, Caption: string;
begin
  Assert(assigned(ActionList));

  for Action in ActionList do
  begin
    tip := get(Action.Name, true);

    if tip.IsNew then
    begin

      Caption := Action.Caption;
      if Caption.IsEmpty then
        Caption := Action.Name;

      Hint := Action.Hint;
      if Hint.IsEmpty then
        Hint := Caption;

      tip.FormName := FormName;
      tip.HeaderText := Caption;
      tip.Description := Hint;

      // property Glyph: TdxSmartGlyph read FGlyph write SetGlyph;
      // property GlyphFixedWidth: Boolean read FGlyphFixedWidth write SetGlyphFixedWidth default True;
      // property PlainText: Boolean read FPlainText write SetPlainText default True;
      // property Text: string read FText write SetText;
      // property TextAlign: TdxScreenTipBandTextAlign read FTextAlign write SetTextAlign default stbtaRight;

      // tip.HeaderText
      // tip.HeaderGlyph ?
      // tip.Description
      // tip.DescriptionGlyph
      // tip.Footer
      // tip.FooterGlyph
      // tip.UseHintAsHeader := true;
      // tip.UseStandardFooter := true;
    end;
  end;
end;

{ TDescription }

constructor TzDescription.Create;
begin
  inherited;
  FAlign := alRight;
  FSize := 150;
  FVisible := False;
  FDescription := TStringList.Create;
end;

destructor TzDescription.Destroy;
begin
  FreeAndNil(FDescription);
  inherited;
end;

procedure TzDescription.Assign(Source: TPersistent);
var
  src: TzDescription;
begin

  if Source is TzDescription then
  begin
    src := Source as TzDescription;
    Description := src.Description;
    Align := src.Align;
    Size := src.Size;
    Visible := src.Visible;
  end
  else
    inherited;
end;

function TzDescription.IniFileName: string;
begin
  result := Base.ConfigFileName('.descriptions');
end;

procedure TzDescription.LoadFromIni(const IniSection: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(IniFileName);
  try
    Align := TRttiEnumerationType.GetValue<TAlign>(Ini.ReadString(IniSection, 'Align', TRttiEnumerationType.GetName<TAlign>(Align)));
    Size := Ini.ReadInteger(IniSection, 'Size', Size);
    Visible := Ini.ReadBool(IniSection, 'Visible', Visible);
  finally
    FreeAndNil(Ini);
  end;
end;

procedure TzDescription.SaveToIni(const IniSection: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteString(IniSection, 'Align', TRttiEnumerationType.GetName<TAlign>(Align));
    Ini.WriteInteger(IniSection, 'Size', Size);
    Ini.WriteBool(IniSection, 'Visible', Visible);
  finally
    FreeAndNil(Ini);
  end;
end;

procedure TzDescription.SetDescription(const Value: TStringList);
begin
  FDescription.Assign(Value);
end;

constructor TzBaseComponentProps.Create(Collection: TCollection);
begin
  inherited;
  FToolActions := TzToolActionsProps.Create;
  FDescription := TzDescription.Create;
end;

destructor TzBaseComponentProps.Destroy;
begin
  inherited;
  FreeAndNil(FToolActions);
  FreeAndNil(FDescription);
end;

procedure TzBaseComponentProps.Assign(Source: TPersistent);
begin

  if Source is TzBaseComponentProps then
  begin
    Description.Assign(TzBaseComponentProps(Source).Description);
    ToolActions.Assign(TzBaseComponentProps(Source).ToolActions);
    // Mantis #252 - 2026-10-27: senza il proprietario la card non trova le proprie azioni
    ActionOwnerName := TzBaseComponentProps(Source).ActionOwnerName;
  end
  else
    inherited;
end;

function TzBaseComponentProps.zComponentType: TzComponentType;
begin
  result := ctNull;
end;

function TzBaseComponentProps.isDescriptionStored: boolean;
begin
  result := not FDescription.Description.Text.IsEmpty;
end;

function TzBaseComponentProps.DescriptionText: string;
begin
  if assigned(FDescription) and assigned(FDescription.Description) then
    result := FDescription.Description.Text.trim
  else
    result := '';
end;

procedure TzBaseComponentProps.SetDescription(const Value: TzDescription);
begin
  FDescription.Assign(Value);
end;

procedure TzBaseComponentProps.SetToolActions(const Value: TzToolActionsProps);
begin
  FToolActions.Assign(Value);
end;

{ TzBaseFilteredComponentProps }

constructor TzBaseFilterableComponentProps.Create(Collection: TCollection);
begin
  inherited;
  FToolFilters := TzToolFiltersProps.Create(TzToolFilterProps, 'zFilters', -1, nil, False);
end;

destructor TzBaseFilterableComponentProps.Destroy;
begin
  FreeAndNil(FToolFilters);
  inherited;
end;

procedure TzBaseFilterableComponentProps.Assign(Source: TPersistent);
begin
  inherited Assign(Source); // per Description & ToolActions

  if Source is TzBaseFilterableComponentProps then
    ToolFilters.Assign(TzBaseFilterableComponentProps(Source).ToolFilters);
end;

procedure TzBaseFilterableComponentProps.SetToolFilters(const Value: TzToolFiltersProps);
begin
  FToolFilters.Assign(Value);
end;

{ TzToolFilterProps }

constructor TzToolFilterProps.Create(Collection: TCollection);
begin
  inherited;
  FInitialValue := ivDefault;
  FPosition := -1;
  FVisible := true;
  FWidth := 0;
  FAllowNull := true;
  FParams := TStringList.Create;
end;

destructor TzToolFilterProps.Destroy;
begin
  FreeAndNil(FParams);
  inherited;
end;

procedure TzToolFilterProps.Assign(Source: TPersistent);
var
  src: TzToolFilterProps;
begin

  if Source is TzToolFilterProps then
  begin
    src := TzToolFilterProps(Source);
    // Copia di TUTTI i membri pubblicati. La versione originale copiava solo
    // Name/InitialValue/Params: poiche' Assign e' sul percorso di clone/commit
    // di zToolConfigDlg e di SaveToBase/LoadFromBase, ogni altra proprieta'
    // impostata (PickListName, FieldName, Caption, ...) veniva persa al primo
    // Assign. FromCode resta non copiato per scelta (vedi TzToolFiltersProps.Assign).
    Name := src.Name;
    FilterName := src.FilterName;
    InitialValue := src.InitialValue;
    CustomValue := src.CustomValue;
    Position := src.Position;
    Visible := src.Visible;
    Caption := src.Caption;
    Hint := src.Hint;
    Width := src.Width;
    FieldName := src.FieldName;
    PickListName := src.PickListName;
    AllowNull := src.AllowNull;
    CaptionAll := src.CaptionAll;
    Params := src.Params;
  end
  else
    inherited;
end;

function TzToolFilterProps.Description: string;
var
  IV: string;
  Testo: string;
begin
  case FInitialValue of
    ivDefault:
      IV := 'default';
    ivNull:
      IV := 'nessun filtro';
    ivCustom:
      IV := 'personalizzato';
  else
    IV := 'default';
  end;

  // Etichetta piu' parlante disponibile, in ordine di utilita' per chi legge.
  // Si passa dagli accessor Effective* cosi' funziona sia con le proprieta'
  // tipizzate sia con le vecchie configurazioni scritte dentro Params.
  Testo := EffectiveCaption;

  if Testo.IsEmpty then
    Testo := EffectiveFieldName;

  if Testo.IsEmpty then
    Testo := EffectivePickListName;

  if Testo.IsEmpty then
    Testo := Name;

  if Testo.IsEmpty then
    Testo := EffectiveFilterName;

  if Testo.IsEmpty then
    Testo := '(non configurato)';

  result := 'Filtro ' + Testo + ' (iniziale: ' + IV + ')';
end;

function TzToolFilterProps.GetDisplayName: string;
begin
  result := Name;

  if result.IsEmpty then
    result := EffectiveFilterName;

  if result.IsEmpty then
    result := '(filtro senza nome)';
end;

procedure TzToolFilterProps.SetParams(const Value: TStrings);
begin
  FParams.Assign(Value);
end;

function TzToolFilterProps.GetPickList: TzPickList;
begin
  result := Base.zPickLists.get(FPickListName, False);
end;

procedure TzToolFilterProps.SetPickList(const Value: TzPickList);
begin
  FPickListName := ItemName(Value);
end;

function TzToolFilterProps.EffectiveFilterName: string;
begin
  result := FFilterName;

  if result.IsEmpty then
    result := FParams.Values['FilterName'];

  // Retrocompatibilita': prima dell'introduzione di FilterName la classe
  // registrata veniva memorizzata in Name.
  if result.IsEmpty then
    result := Name;
end;

function TzToolFilterProps.EffectiveFieldName: string;
begin
  result := FFieldName;
  if result.IsEmpty then
    result := FParams.Values['FieldName'];
end;

function TzToolFilterProps.EffectiveCaption: string;
begin
  result := FCaption;
  if result.IsEmpty then
    result := FParams.Values['Caption'];
end;

function TzToolFilterProps.EffectiveHint: string;
begin
  result := FHint;
  if result.IsEmpty then
    result := FParams.Values['Hint'];
end;

function TzToolFilterProps.EffectiveWidth(const default: integer): integer;
begin
  if FWidth > 0 then
    result := FWidth
  else
    result := StrToIntDef(FParams.Values['Width'], Default);
end;

function TzToolFilterProps.EffectivePickListName: string;
begin
  result := FPickListName;
  if result.IsEmpty then
    result := FParams.Values['PickListName'];
  if result.IsEmpty then
    result := FParams.Values['PickList'];
end;

function TzToolFilterProps.EffectiveAllowNull: boolean;
begin
  result := FAllowNull and not SameText(FParams.Values['AllowNull'], 'False');
end;

function TzToolFilterProps.EffectiveCaptionAll: string;
begin
  result := FCaptionAll;
  if result.IsEmpty then
    result := FParams.Values['CaptionAll'];
  if result.IsEmpty then
    result := 'Tutti';
end;

function TzToolFilterProps.EffectiveInitialValue: TFilterInitialValue;
begin
  result := FInitialValue;
  if (result = ivNull) and not EffectiveAllowNull then
    result := ivDefault;
end;

{ TzToolFiltersProps }

function TzToolFiltersProps.Descriptions: TArray<string>;
var
  i: integer;
begin
  SetLength(result, count);
  for i := 0 to count - 1 do
    result[i] := Items[i].Description;
end;

procedure TzToolFiltersProps.Assign(Source: TPersistent);
var
  Saved: TArray<TzToolFilterProps>;
  Item, NewItem: TzToolFilterProps;
  i, n: integer;
begin
  // Snapshot dei filtri dichiarati da codice (FromCode) PRIMA di sovrascrivere:
  // l'Assign base ricarica da LZ (Source) e cancellerebbe i filtri di codice
  // non ancora persistiti. Li ri-aggiungiamo dopo, solo se LZ non li contiene.
  n := 0;
  SetLength(Saved, count);
  for Item in self do
    if Item.FromCode then
    begin
      Saved[n] := TzToolFilterProps.Create(nil);
      Saved[n].Assign(Item); // copia stato (Name/InitialValue/Params); FromCode non è copiato
      Saved[n].FromCode := true; // ...quindi lo reimpostiamo qui
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
        NewItem.FromCode := true;
      end;
  finally
    for i := 0 to High(Saved) do
      Saved[i].Free;
  end;
end;

function TzToolFiltersProps.Exists(const Name: string): boolean;
begin
  result := assigned(Find(Name));
end;

function TzToolFiltersProps.Find(const Name: string): TzToolFilterProps;
var
  Item: TzToolFilterProps;
begin
  result := nil;
  for Item in self do
    if SameText(Item.Name, Name) then
      Exit(Item);
end;

function TzToolFiltersProps.HasFromCode: boolean;
var
  Item: TzToolFilterProps;
begin
  result := False;
  for Item in self do
    if Item.FromCode then
      Exit(true);
end;

procedure TzToolFiltersProps.ClearFromCode;
var
  Item: TzToolFilterProps;
begin
  for Item in self do
    Item.FromCode := False;
end;

function TzToolFiltersProps.MergeFromCode(Source: TzToolFiltersProps): boolean;
var
  Item, NewItem: TzToolFilterProps;
begin
  result := False;
  if not assigned(Source) then
    Exit;
  for Item in Source do
    if not Exists(Item.Name) then
    begin
      NewItem := Add;
      NewItem.Assign(Item);
      NewItem.FromCode := true;
      result := true;
    end;
end;

function TzToolFiltersProps.InstancesOf(const AFilterName: string): TArray<TzToolFilterProps>;
var
  Item: TzToolFilterProps;
  n: integer;
begin
  SetLength(result, count);
  n := 0;

  for Item in self do
    if SameText(Item.EffectiveFilterName, AFilterName) then
    begin
      result[n] := Item;
      Inc(n);
    end;

  SetLength(result, n);
end;

function TzToolFiltersProps.NewInstanceName(const AFilterName, AFieldName: string): string;
var
  Radice: string;
  i: integer;
begin
  // Il nome dell'istanza e' libero: serve solo a essere univoco dentro la
  // collezione della view. Si parte dalla classe, eventualmente qualificata
  // col campo, e si aggiunge un progressivo finche' non e' libero.
  Radice := AFilterName;

  if not AFieldName.IsEmpty then
    Radice := Radice + '_' + AFieldName;

  result := Radice;
  i := 1;

  while Exists(result) do
  begin
    Inc(i);
    result := Radice + '_' + i.ToString;
  end;
end;

function TzToolFiltersProps.AddInstance(const AFilterName: string): TzToolFilterProps;
begin
  result := Add;
  result.FilterName := AFilterName;
  result.Name := NewInstanceName(AFilterName, '');
  result.InitialValue := ivDefault;
end;

initialization

Base := nil;

RegisterClasses([TzDxLayoutGroup, TzDxLayoutItem, TzDxLayoutSplitterItem, TzDxLayoutEmptySpaceItem, TzDxLayoutSeparatorItem]);

sizSystem := Si.AddSession('zSystem', true);

finalization

sizSystem := nil;

end.

  zdbview

  Frame_Collection
