unit zDbCard;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Threading,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.Actions,
  System.ImageList,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Clipbrd,
  Vcl.StdActns,
  Vcl.DBActns,
  Vcl.ExtActns,
  Vcl.ActnList,
  Vcl.ImgList,
  Data.DB,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxEdit,
  cxDBEdit,
  cxDBRichEdit,
  cxDBLookupComboBox,
  cxDBExtLookupComboBox,
  cxTextEdit,
  cxCheckBox,
  cxLabel,
  cxHyperLinkEdit,
  cxMaskEdit,
  dxBar,
  cxImageComboBox,
  cxRadioGroup,
  cxLookupDBGrid,
  cxImage,
  cxMemo,
  cxCheckGroup,
  cxDropDownEdit,
  cxContainer,
  cxImageList,
  cxBarEditItem,
  dxBarExtItems,
  cxClasses,
  zSystem,
  zDataController,
  zToolActions,
  zToolFilter,
  zToolFilterHelper,
  zBaseLib,
  zFbDataSet,
  zCollection,
  cxSpinEdit,
  dxCore,
  zTimers,
  cxGroupBox,
  dxCheckGroupBox,
  dxDBCheckGroupBox,
  cxDBCheckComboBox,
  Vcl.Menus,
  cxButtons,
  dxScreenTip,
  dxCustomHint,
  cxHint,
  cxProgressBar,
  cxDBProgressBar,
  cxLookupEdit,
  cxDBLookupEdit,
  dxRatingControl,
  cxGrid,
  dxUIAClasses,
  zDescription,
  cxGeometry,
  dxFramedControl,
  dxPanel,
  dxLayoutControl,
  dxLayoutContainer,
  dxLayoutCommon,
  zLayouts,
  zLayoutMaintenance,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TzDbCardCommand = (cmd_UpdateActions, cmd_DisplayToolbars, cmd_NewLookupDisplayText, cmd_SaveLookupToZip, cmd_SavePickListToZip, cmd_LoadProperties, cmd_PropertiesChange, cmd_ReadOnlyPropertiesChange, cmd_FlagsPropertiesChange,
    cmd_CtrlTypePropertiesChange, cmd_UpdateColors, cmd_Resize, cmd_PersonalizzaCard, cmd_RebuildControls, cmd_RebuildSingleControl, cmd_VerifyLookupsParams, cmd_SaveProperties);

  TzDbCardReadOnly = (crUseLoadedProps, crForceReadOnly, crForceWriteable);

  TzControls = class;
  TzDbCard = class;

  TzControl = class(TzCollectionItem)
  private
    FColSpan: integer;
    FNewLineBefore: boolean;
    FRowPlacement: TControlRowPlacement;
    FControl: TWinControl;
    FcxCustomEdit: TcxCustomEdit;
    FcxLabel: TcxLabel;
    FHeight: integer;
    FIdLookup: string;
    FLeft: integer;
    FLines: integer;
    FlkDataSet: TzFbDataSet;
    FlkDataSource: TDataSource;
    FSize: integer;
    FTop: integer;
    FTotalHeight: integer;
    FWidth: integer;
    FzCtrlType: TzCtrlType;
    FDisplayLabel: string;
  private
    Controls: TzControls;
    FDomain: TzDomain;
    FLookupEnabled: boolean;
    FFieldReadOnly: boolean;
    FFieldRequired: boolean;
    FForcedReadOnly: boolean;
    FGroup: String;
    FLookupIgnoreFieldReadOnly: boolean;
    FReadOnly: boolean;
    FRequired: boolean;
    FVisible: boolean;
  private
    procedure OnDataSetQueryParams(DataSet: TDataSet);
    procedure AssignMasterFieldsParams(DataSet: TzFbDataSet; out ParamsChanged: boolean);
    procedure VerifyLookupParams;
  private
    procedure LabelDblClick(Sender: TObject);
  private
    EditValueChanging: boolean;
    procedure F2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoHyperLink(Sender: TObject);
    procedure OnLookupButtonClick(Sender: TObject; AButtonIndex: integer);

    procedure OnLookupKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnLookupEditValueChanged(Sender: TObject);
    procedure OnLookupNewLookupDisplayText(Sender: TObject; const AText: TCaption);
    procedure OnLookupCloseUp(Sender: TObject);
    procedure OnLookupInitPopup(Sender: TObject);
    procedure EnsureLookupDataSetOpen;
    procedure LookupDatasetAfterOpen(DataSet: TDataSet);

    function ExecuteLookupDlg: boolean;
  private
    procedure InitControlProperties;
    procedure InitLookupProperties;
    procedure InitPopupMenu;
    procedure FillCheckComboBoxItems;
    procedure SetPopupCtrl(Sender: TdxBarPopupMenuLink; var X, Y: integer; ClickedByMouse: boolean; var AllowPopup: boolean);
  private
    function CreateControl(const name: String; ControlType: TzCtrlType): TWinControl;
    function CreateDbControl(const DataField: String; ControlType: TzCtrlType): TcxCustomEdit;
    function CreateLabel(const LabelName: string; const Caption: String; cxCustomEdit: TcxCustomEdit; const Transparent: boolean; const AutoSize: boolean): TcxLabel;
    function CreateDataSource(DataSet: TzFbDataSet): TDataSource;
    function CreateDataSet(const IdLookup: string): TzFbDataSet;
    procedure AssignDataSetProps(const IdLookup: string; DataSet: TzFbDataSet);

    procedure CreateControls;
    procedure DestroyControls;

    procedure SetDisplayLabel(const Value: string);
    procedure SetFieldReadOnly(const Value: boolean);
    procedure SetFieldRequired(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetRequired(const Value: boolean);
    procedure SetVisible(const Value: boolean);
  private
    DomainDisplayLabel: string;
  private
    function GetEditability: TEditability;
    procedure InternalSetEditability;
    procedure SetForcedReadOnly(const Value: boolean);
    procedure SetLookupIgnoreFieldReadOnly(const Value: boolean);
  private
    FCustomActions: TOrderedDictionary<string, TBasicAction>;
    function GetCustomAction(const name: string): TBasicAction;
    procedure SetCustomAction(const name: string; const Value: TBasicAction);
  private
    function GetField: TField;

    procedure ResetLookupDataSet;
    procedure SetLookupEnabled(const Value: boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure AssignControlProps(zControlProps: TzControlProps; zDomain: TzDomain);
    procedure RebuildControls(zControlProps: TzControlProps; zDomain: TzDomain);

    function GetLookup(zSystem: TzSystem): TzLookup;
    procedure ResetPos;
    procedure MakeVisible;
    function IsPicklist: boolean;
    function IsLookup: boolean;

    procedure EditCustomCaption;

    function ControlIsLookup: boolean;

    function LookupControlField: TField;

    function IsEmptyValue: boolean;
    procedure UpdateColor();
    procedure ForceValidation;
    procedure CopyMappingFields(Field2Exclude: string = '');
    function LookupRecordValid: boolean;
    procedure CheckLookupRecordValid;
    procedure SetLookupTransactions(ReadTrans, WriteTrans: TzFbTransaction);
  public
    property Control: TWinControl read FControl;
    property cxLabel: TcxLabel read FcxLabel;
    property cxCustomEdit: TcxCustomEdit read FcxCustomEdit;
    property lkDataSet: TzFbDataSet read FlkDataSet;
    property lkDataSource: TDataSource read FlkDataSource;
  public
    property Left: integer read FLeft write FLeft;
    property Top: integer read FTop write FTop;
    property Width: integer read FWidth write FWidth;
    property Height: integer read FHeight write FHeight;
    property TotalHeight: integer read FTotalHeight write FTotalHeight;
  public
    property IdLookup: string read FIdLookup write FIdLookup;
    property Domain: TzDomain read FDomain write FDomain;
    property DisplayLabel: string read FDisplayLabel write SetDisplayLabel;
    property ReadOnly: boolean read FReadOnly write SetReadOnly;
    property FieldReadOnly: boolean read FFieldReadOnly write SetFieldReadOnly;
    property ForcedReadOnly: boolean read FForcedReadOnly write SetForcedReadOnly;
    property LookupIgnoreFieldReadOnly: boolean read FLookupIgnoreFieldReadOnly write SetLookupIgnoreFieldReadOnly;

    property Required: boolean read FRequired write SetRequired;
    property FieldRequired: boolean read FFieldRequired write SetFieldRequired;

    property LookupEnabled: boolean read FLookupEnabled write SetLookupEnabled;

    property ColSpan: integer read FColSpan write FColSpan;

    property RowPlacement: TControlRowPlacement read FRowPlacement write FRowPlacement;

    property NewLineBefore: boolean read FNewLineBefore write FNewLineBefore; // deprecated 'Usa RowPlacement';

    property Size: integer read FSize write FSize;
    property Lines: integer read FLines write FLines;
    property Visible: boolean read FVisible write SetVisible;
    property zCtrlType: TzCtrlType read FzCtrlType write FzCtrlType;
    property Group: String read FGroup write FGroup;
  public
    procedure AddCustomAction(Action: TBasicAction);
    function HasCustomActions: boolean;
    function GetCustomActions: TArray<TBasicAction>;
    property CustomActions[const Name: string]: TBasicAction read GetCustomAction write SetCustomAction;
  end;

  // TzDbCardController
  TzControls = class(TzCollection<TzControl>)
  private
    FieldsHiddenByCode: TStringList;
    FDataSet: TzFbDataSet;
    FDataSource: TDataSource;
    FDataController: TzDataController;
    FzSystem: TzSystem;
  private
    FPopupMenu: TdxBarPopupMenu;
    FReadTrans: TzFbTransaction;
    FWriteTrans: TzFbTransaction;
    function GetReadTrans: TzFbTransaction;
    function GetWriteTrans: TzFbTransaction;
    property ReadTrans: TzFbTransaction read GetReadTrans;
    property WriteTrans: TzFbTransaction read GetWriteTrans;
  private
    FControlFont: TFont;
    FCard: TzDbCard;
    PopupCtrl: TWinControl;
    PopupPos: TPoint;
    function PopupCtrlIsClass(zCtrlType: TzCtrlType): boolean;
    function PopupCtrlItem: TzControl;
  private
    procedure SetControlFont(const Value: TFont);
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: boolean;
  private
    procedure MigrateLegacyColSpans(zDbCardProps: TzDbCardProps);
    procedure MigrateLegacyGroupedColSpans(zDbCardProps: TzDbCardProps; ColCount, OuterMaxWidth: integer);
  protected
    function CreateLabel(const name: string; Caption: String; FocusControl: TWinControl; const Transparent: boolean; const AutoSize: boolean): TcxLabel;
    function CreateDbControl(const DataField: String; ControlType: TzCtrlType): TcxCustomEdit;
    procedure VerifyLookupsParams(ChangedField: TField = nil; skipControl: TzControl = nil);
  public
    constructor Create;
    destructor Destroy; override;

    function AddControl(const DataField: String; DisplayLabel: string; ControlType: TzCtrlType; Domain: TzDomain; Size: integer; Lines: integer; Group: string): TcxCustomEdit;
    procedure CreateControls;
    procedure DestroyControls;
    procedure MakeControlsVisible;

    function UniqueName(const name: string): string;
    function Find(const FieldName: string): TzControl; overload;
    function Find(cxCustomEdit: TcxCustomEdit): TzControl; overload;
    function Find(Control: TWinControl): TzControl; overload;
    function Find(lkDataSet: TzFbDataSet): TzControl; overload;

    function GetDbControl(const FieldName: String): TcxCustomEdit;
    function GetDataField(cxCustomEdit: TcxCustomEdit): string;

    function Groups: TStringDynArray;
  public
    procedure LoadFromProps(zDbCardProps: TzDbCardProps);
    procedure SaveToProps(zDbCardProps: TzDbCardProps);
  public
    procedure BuildLayoutItems(zDbCardProps: TzDbCardProps);
  public
    property Card: TzDbCard read FCard write FCard;
    property ControlFont: TFont read FControlFont write SetControlFont;
    property PopupMenu: TdxBarPopupMenu read FPopupMenu write FPopupMenu;
    property DataController: TzDataController read FDataController write FDataController;
    property DataSet: TzFbDataSet read FDataSet write FDataSet;
    property DataSource: TDataSource read FDataSource write FDataSource;
    property zSystem: TzSystem read FzSystem write SetzSystem;
  end;

  // ===========================================================================
  // TzRowModel — modello unico di riga
  //
  // Unica fonte di verità per capacità di riga (RowMaxSize), dimensioni
  // effettive dei controlli (EffectiveSize) e criteri di overflow.
  // Usato da BuildLayoutItems, AdjustRowForColSpan e SyncLayoutFromEditor:
  // prima i tre punti calcolavano le righe con regole divergenti (fallback
  // dominio vs 20 fisso vs Max(1, Size); costanti duplicate), producendo
  // decisioni sui LineBreak incoerenti col layout reale.
  // Istanze usa-e-getta: crearle via TzDbCard.NewRowModel e liberarle subito.
  // ===========================================================================
  TzRowModel = class
  public const
    FONT_WIDTH = 7; // px per carattere di fallback (Segoe UI 10pt @ 96dpi)
    DEFAULT_LINE_HEIGHT = 18; // px per riga di memo, fallback
    EDIT_BORDER_PX = 4;
    H_MARGIN = 20;
    VSCROLLBAR_WIDTH = 20;
    GRP_BORDER_MARGIN = 20; // margine interno bordo GroupBox (px)
    DEFAULT_SIZE = 20; // Size quando né props né dominio lo definiscono
    MIN_ROW_SIZE = 20;
    MIN_GROUP_ROW_SIZE = 10;
    FALLBACK_ROW_SIZE = 130; // quando la larghezza non è nota
    MIN_EDIT_CHARS = 4; // larghezza minima leggibile dell'area edit (caratteri)
  private
    FRowMaxSize: integer;
    FCharWidth: integer;
    FLineHeight: integer;
    procedure MeasureFont(AFont: TFont);
  public
    // AFont: se assegnato, CharWidth/LineHeight vengono misurati dal font
    // reale (quindi seguono famiglia, corpo e DPI del frame) invece dei
    // fallback FONT_WIDTH/DEFAULT_LINE_HEIGHT.
    constructor Create(const DlgWidth: integer; AFont: TFont = nil);
    // Size effettivo in caratteri: esplicito → dominio → default, clamp a RowMaxSize
    function EffectiveSize(const Size: integer; Domain: TzDomain): integer; overload;
    function EffectiveSize(ctrl: TzControl): integer; overload;
    // Ingombro in riga: Size effettivo + caption quando questa occupa la
    // colonna a sinistra (clLeft). È la misura da usare per wrap e residui.
    function EffectiveSlot(const Size: integer; Domain: TzDomain; const CaptionLen: integer): integer; overload;
    function EffectiveSlot(ctrl: TzControl; const CaptionAtLeft: boolean): integer; overload;
    // True se aggiungere ASize a AUsed sfora la capacità della riga
    function Overflows(const AUsed, ASize: integer): boolean;
    // Capacità delle righe interne a un gruppo largo AGroupSize caratteri
    function GroupCapacity(const AGroupSize: integer): integer;
    // Larghezza minima in px (area controllo) sotto cui l'item non si comprime;
    // oltre, il reflow lo manda a capo. Tenuta <= SlotChars*CharWidth, così la
    // somma dei minimi di riga resta <= RowMaxSize*CharWidth <= client width:
    // niente scrollbar orizzontale. CaptionAtLeft/CaptionLen previsti per un
    // eventuale minimo comprensivo di caption (oggi i chiamanti passano la sola
    // area controllo, perché ControlOptions.MinWidth non include la caption).
    function MinSlotPx(const SlotChars, CaptionLen: integer; const CaptionAtLeft: boolean): integer;
    property RowMaxSize: integer read FRowMaxSize;
    property CharWidth: integer read FCharWidth;
    property LineHeight: integer read FLineHeight;
  end;

  // Guard condiviso fra la card e le closure asincrone del salvataggio
  // (task + TThread.Queue): le closure catturano l'interfaccia (refcounted,
  // sopravvive alla card) e verificano Alive prima di toccare Self.
  IzCardAliveGuard = interface
    ['{8F4D2A91-3C7B-4E6A-9D15-B82E4F6C1A37}']
    function GetAlive: boolean;
    procedure SetAlive(const Value: boolean);
    property Alive: boolean read GetAlive write SetAlive;
  end;

  TzCardAliveGuard = class(TInterfacedObject, IzCardAliveGuard)
  private
    FAlive: boolean;
    function GetAlive: boolean;
    procedure SetAlive(const Value: boolean);
  public
    constructor Create;
  end;

  TzLayoutMaintenanceOp = (lmoNone, lmoReset, lmoRepair);

  TzDbCard = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzLayoutMaintenance)
    DataSource: TDataSource;
    dxBarManager: TdxBarManager;
    dxBarToolbarFree: TdxBar;
    dxBarToolbar: TdxBar;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
    dxBarButton1: TdxBarButton;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarEditTitolo: TcxBarEditItem;
    dxBarSeparator1: TdxBarSeparator;
    dxBarButton9: TdxBarButton;
    cxBarItemReadOnly: TcxBarEditItem;
    cxBarItemModifyFlags: TcxBarEditItem;
    cxBarItemCtrlType: TcxBarEditItem;
    dxBarButton3: TdxBarButton;
    dxBarButton10: TdxBarButton;
    cxBarEditItemCtrlFlag: TcxBarEditItem;
    dxBarButtonCaricaImpostazioni: TdxBarButton;
    dxBarButtonSalvaImpostazioni: TdxBarButton;
    dxBarButtonactSQL: TdxBarButton;
    dxBarButtonactPersonalizza: TdxBarButton;
    dxBarButtonactPersonalizzaCampo: TdxBarButton;
    dxBarButtonactPersonalizzaLookup: TdxBarButton;
    dxBarButtonactInfoDebugLookup: TdxBarButton;
    dxBarButtonactSelected: TdxBarButton;
    dxBarButtonCopiaSelected: TdxBarButton;
    dxBarButtonIncollaSelected: TdxBarButton;
    dxBarButtonNascondiCampo: TdxBarButton;
    dxBarButtonNewLine: TdxBarButton;
    dxBarButtonSeparatore: TdxBarButton;
    dxBarButtonCtrlSize: TdxBarButton;
    dxBarButtonCtrlLabel: TdxBarButton;
    dxBarButtonactDbFirst: TdxBarButton;
    dxBarButtonactDbPrior: TdxBarButton;
    dxBarButtonactDbNext: TdxBarButton;
    dxBarButtonactDbLast: TdxBarButton;
    dxBarButtonactDbEdit: TdxBarButton;
    dxBarButtonactDbInsert: TdxBarButton;
    dxBarButtonactDbDelete: TdxBarButton;
    dxBarButtonactDbRefresh: TdxBarButton;
    dxBarButtonactDbPost: TdxBarButton;
    dxBarButtonactDbCancel: TdxBarButton;
    dxBarButtonactEdCut: TdxBarButton;
    dxBarButtonactEdCopy: TdxBarButton;
    dxBarButtonactEdPaste: TdxBarButton;
    dxBarButtonactEdSelectAll: TdxBarButton;
    dxBarButtonactEdUndo: TdxBarButton;
    dxBarButtonactEdDelete: TdxBarButton;
    dxBarButtonEditUndo1: TdxBarButton;
    dxBarButtonEditCut1: TdxBarButton;
    dxBarButtonEditCopy1: TdxBarButton;
    dxBarButtonEditPaste1: TdxBarButton;
    dxBarButtonEditDelete1: TdxBarButton;
    dxBarButtonEditSelectAll1: TdxBarButton;
    dxBarButtonOpenPicture1: TdxBarButton;
    dxBarButtonSavePicture1: TdxBarButton;
    dxBarButtonDeletePicture: TdxBarButton;
    dxBarButton2: TdxBarButton;
    ActionList: TActionList;
    CopiaImpostazioni: TAction;
    IncollaImpostazioni: TAction;
    OpenPicture: TAction;
    SavePicture: TAction;
    DeletePicture: TAction;
    PreviewPicture: TAction;
    CaricaImpostazioni: TAction;
    SalvaImpostazioni: TAction;
    actDbFirst: TDataSetFirst;
    actDbPrior: TDataSetPrior;
    actDbNext: TDataSetNext;
    actDbLast: TDataSetLast;
    actDbEdit: TAction;
    actDbInsert: TAction;
    actDbDelete: TAction;
    actDbRefresh: TAction;
    CopyName: TAction;
    actDbPost: TAction;
    actDbCancel: TAction;
    actEdCut: TEditCut;
    actEdCopy: TEditCopy;
    actEdPaste: TEditPaste;
    actEdSelectAll: TEditSelectAll;
    actEdUndo: TEditUndo;
    actEdDelete: TEditDelete;
    actSQL: TAction;
    actPersonalizza: TAction;
    actPersonalizzaCampo: TAction;
    actPersonalizzaLookup: TAction;
    MostraQueryLookup: TAction;
    actSelected: TAction;
    CopiaSelected: TAction;
    IncollaSelected: TAction;
    actResetSelected: TAction;
    NascondiCampo: TAction;
    NewLine: TAction;
    Separatore: TAction;
    MostraQueryUtilizzata: TAction;
    CopiaQueryUtilizzata: TAction;
    CopiaControlli: TAction;
    IncollaControlli: TAction;
    popCard: TdxBarPopupMenu;
    cxImageList: TcxImageList;
    popEdit: TdxBarPopupMenu;
    WebCam: TAction;
    dxBarSpinEditCtrlSize: TcxBarEditItem;
    dxBarEditCtrlCaption: TcxBarEditItem;
    ModificaMemo: TAction;
    ModificaRTF: TAction;
    dxBarButton8: TdxBarButton;
    dxBarButton11: TdxBarButton;
    Titolo: TcxLabel;
    CopiaCampiVisibili: TAction;
    dxBarButton12: TdxBarButton;
    dxBarSpinEditCtrlLines: TcxBarEditItem;
    dxBarButtonactPersonalizzaCard: TdxBarButton;
    cxGridViewRepository: TcxGridViewRepository;
    dxBarSubItemControlloOrtografico: TdxBarSubItem;
    actNuovoLookup: TAction;
    dxBarButtonactNuovoLookup: TdxBarButton;
    OverrideCampo: TAction;
    dxBarButton13: TdxBarButton;
    CopiaImpostazioniPerDX: TAction;
    dxBarButtonCopiaImpostazioniPerDX: TdxBarButton;
    actPersonalizzaPicklist: TAction;
    dxBarButtonactPersonalizzaPickList: TdxBarButton;
    pnlDescrizione: TdxPanel;
    Descrizione: TAction;
    dxBarButton14: TdxBarButton;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    LayoutEditor: TAction;
    dxBarButton15: TdxBarButton;
    EditTools: TAction;
    dxBarButton16: TdxBarButton;
    procedure actDbCancelExecute(Sender: TObject);
    procedure actDbCancelUpdate(Sender: TObject);
    procedure actDbDeleteExecute(Sender: TObject);
    procedure actDbEditExecute(Sender: TObject);
    procedure actDbInsertExecute(Sender: TObject);
    procedure actDbPostExecute(Sender: TObject);
    procedure actDbPostUpdate(Sender: TObject);
    procedure actDbRefreshExecute(Sender: TObject);
    procedure actDbRefreshUpdate(Sender: TObject);
    procedure actEditorImageUpdate(Sender: TObject);
    procedure MostraQueryLookupExecute(Sender: TObject);
    procedure actPersonalizzaCampoExecute(Sender: TObject);
    procedure actPersonalizzaCampoUpdate(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure actPersonalizzaLookupExecute(Sender: TObject);
    procedure actResetSelectedExecute(Sender: TObject);
    procedure actSelectedExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure CaricaImpostazioniExecute(Sender: TObject);
    procedure CopiaCampiVisibiliExecute(Sender: TObject);
    procedure CopiaControlliExecute(Sender: TObject);
    procedure CopiaImpostazioniExecute(Sender: TObject);
    procedure CopiaQueryUtilizzataExecute(Sender: TObject);
    procedure CopiaSelectedExecute(Sender: TObject);
    procedure CopyNameExecute(Sender: TObject);
    procedure cxBarEditItem1PropertiesChange(Sender: TObject);
    procedure cxBarEditItemCtrlFlagPropertiesChange(Sender: TObject);
    procedure cxBarItemCtrlTypePropertiesChange(Sender: TObject);
    procedure cxBarItemModifyFlagsPropertiesChange(Sender: TObject);
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    procedure DataSourceStateChange(Sender: TObject);
    procedure DeletePictureExecute(Sender: TObject);
    procedure dxBarEditCtrlCaptionChange(Sender: TObject);
    procedure dxBarEditTitoloChange(Sender: TObject);
    procedure dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
    procedure dxBarSpinEditCtrlLinesChange(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure IncollaControlliExecute(Sender: TObject);
    procedure IncollaImpostazioniExecute(Sender: TObject);
    procedure IncollaSelectedExecute(Sender: TObject);
    procedure ModificaMemoExecute(Sender: TObject);
    procedure ModificaMemoUpdate(Sender: TObject);
    procedure ModificaRTFExecute(Sender: TObject);
    procedure ModificaRTFUpdate(Sender: TObject);
    procedure MostraQueryUtilizzataExecute(Sender: TObject);
    procedure NascondiCampoExecute(Sender: TObject);
    procedure NascondiCampoUpdate(Sender: TObject);
    procedure NewLineExecute(Sender: TObject);
    procedure actNuovoLookupExecute(Sender: TObject);
    procedure actPersonalizzaPicklistExecute(Sender: TObject);
    procedure CopiaImpostazioniPerDXExecute(Sender: TObject);
    procedure CopiaImpostazioniPerDXUpdate(Sender: TObject);
    procedure DescrizioneExecute(Sender: TObject);
    procedure LayoutEditorExecute(Sender: TObject);
    procedure OpenPictureExecute(Sender: TObject);
    procedure popCardPopup(Sender: TObject);
    procedure popEditPopup(Sender: TObject);
    procedure PreviewPictureExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure SavePictureExecute(Sender: TObject);
    procedure SeparatoreExecute(Sender: TObject);
    procedure OverrideCampoExecute(Sender: TObject);
    procedure OverrideCampoUpdate(Sender: TObject);
    procedure VisibleIfAdmin(Sender: TObject);
    procedure WebCamExecute(Sender: TObject);
    procedure dxBarSpinEditCtrlSizePropertiesEditValueChanged(Sender: TObject);
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
  private type
    TFieldRebuildData = record
      zControl: TzControl;
      Domain: TzDomain;
      function Valid: boolean;
      procedure Clear;
    end;
  private
    FieldRebuildData: TFieldRebuildData;
    procedure RebuildSingleControl;
    procedure AdjustRowForColSpan(item: TzControl);
  private
    procedure SetPopupControlloOrtografico;
  private
    procedure LabelDblClick;
  private
    PostedCommands: array [TzDbCardCommand] of boolean;
    DeferredCommands: array [TzDbCardCommand] of boolean;
    DeferredParams: array [TzDbCardCommand] of NativeUInt;
    procedure PostInternalMessage(const cmd: TzDbCardCommand; lparam: NativeUInt = 0);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBCARD;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  private // Salvataggio props differito (cmd_SaveProperties)
    FSaveThreadRunning: boolean;
    FSaveQueued: boolean;
    FDlgSizeIs96dpi: boolean; // DlgWidth/DlgHeight in unità 96-dpi (post descale)
    FSaveTask: ITask;
    FAliveGuard: IzCardAliveGuard;
    procedure DescaleDlgSizeForSave;
    procedure DoDeferredSaveProperties;
  private // Manutenzione layout (IzLayoutMaintenance)
    FPendingMaintenanceOp: TzLayoutMaintenanceOp;
    procedure DoResetLayout;
    procedure DoRepairLayout;
    procedure RepairLayoutProps(Layout: TzLayoutItems);
    procedure ExecutePendingMaintenance;
  public
    // IzLayoutMaintenance
    function CanMaintainLayout: boolean;
    procedure ResetLayout;
    procedure RepairLayout;
  private
    FUpdatingCheckBoxes: boolean; // guard: set programmatico di Checked
    FLastBuildRowMax: integer; // RowMaxSize dell'ultimo BuildLayoutItems
    FInReflow: boolean; // guard anti-rientro CheckReflow -> RebuildLayout -> Resize
    procedure CheckReflow;
  private
    procedure UpdateSavedLayoutCaption(const FieldName, NewCaption: string);
  private
    procedure ModificaLookupProps;
  private
    FrameDescription: TFrameDescription;
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private
    procedure PropertiesChange;
    procedure FlagsPropertiesChange;
    procedure ReadOnlyPropertiesChange;
    procedure CtrlTypePropertiesChange;
  private
    FLayoutEditorClosing: boolean;
    FDataController: TzDataController;
    FzDataSet: TzFbDataSet;
    FzDbCardProps: TzDbCardProps;
    FzSystem: TzSystem;
  private // Metodi IzBaseComponent / IzBaseDbComponent / IzBaseFilteredComponent
    FToolActions: TzToolActions;
    function GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
    procedure SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
    function GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
    procedure SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
    function GetID: string; // IzBaseComponent.GetID
    procedure SetID(const Value: string); // IzBaseComponent.SetID
    function GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
    function GetToolbar: TdxBar; // IzBaseComponent.GetToolbar — barra unica filtri+azioni
  private // Metodi IzBaseFilterableComponent (filtri toolbar)
    function GetToolFilters: TzToolFiltersProps; // IzBaseFilterableComponent.GetToolFilters
    procedure SetToolFilters(const Value: TzToolFiltersProps); // IzBaseFilterableComponent.SetToolFilters
    procedure RebuildFilters; // IzBaseFilterableComponent.RebuildFilters
    procedure CreateFiltersFromProps;
  private // Metodi IzBaseComponent (config azioni)
    function GetProps: TzBaseComponentProps;
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    procedure RebuildToolbar; // IzBaseComponent.RebuildToolbar — filtri poi azioni
    function ConfigTitle: string;
  private
    procedure SetzDbCardProps(const Value: TzDbCardProps);
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: boolean;
  private
    procedure ResetLookupDataSets;
  private
    procedure CreateCustomControls;
    procedure DestroyCustomControls;
    procedure ForceControlsValidation;
    procedure InitCard;
    procedure PersonalizzaCard;
  private
    procedure LoadProperties(const LoadFromBase: boolean = true);
    procedure SaveProperties;
  private
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
  private
    // sincronizza dxLayoutItem.Visible per ogni TzControl
    procedure RefreshVisibility;

    // Il Layout è cambiato, controlli no
    // Chiama BuildLayoutItems (ricrea TdxLayoutItem, riusa TcxCustomEdit esistenti)
    // Esempi: cambio ColSpan, cambio ColCount, riordino, inserimento LineBreak
    procedure RebuildLayout;
    function NewRowModel: TzRowModel;

    // Modifiche ai controlli sono cambiati
    // Distrugge e ricrea i TcxCustomEdit, poi RebuildLayout
    // Esempi: cambio zCtrlType, cambio Lines, cambio Size, cambio dominio
    procedure RebuildControls;

    // Cambio dele props dall'esterno
    // ricarica zDbCardProps, poi RebuildControls
    // sEsempi: IncollaImpostazioni, LoadProperties, reset completo
    procedure ReloadFromProps(const LoadFromBase: boolean = true);
  private
    procedure ClearLayoutItems;
    procedure OnLayoutCustomizeFormVisibleChanged(Sender: TObject);
    procedure OpenLayoutEditor;
    procedure SyncLayoutFromEditor;
  private
    IsCreatingControls: boolean;
    PendingVerifyLookupsParams: boolean;
    InsideVerifyLookupsParams: boolean;
    FReadOnly: TzDbCardReadOnly;
    FOnDataSetDelete: TNotifyEvent;
    FOnDataSetEdit: TNotifyEvent;
    FOnDataSetInsert: TNotifyEvent;
    FDisableDelete: boolean;
    FDisableEdit: boolean;
    FDisableInsert: boolean;
    FOnAfterCreateControls: TNotifyEvent;
    FOnBeforeCreateControls: TNotifyEvent;
    FRestrictionReadOnly: boolean;
    FzControls: TzControls;
    procedure SetDisableDelete(const Value: boolean);
    procedure SetDisableEdit(const Value: boolean);
    procedure SetDisableInsert(const Value: boolean);

    procedure SetReadOnly(const Value: TzDbCardReadOnly);
    function GetCardID: string;
    procedure SetCardID(const Value: string);
    function GetID_DataSet: string;
  private
    procedure LoadCardFormSize;
    procedure SaveCardFormSize;
    procedure SetCardDlgWidth;

    procedure PersonalizzaCardApply(Sender: TObject);
  private
    function IsAdmin: boolean;
    function IsCardReadOnly: boolean;
    procedure UpdateActions;
    procedure DisplayToolbars;
    procedure ToolActionsChanged(Sender: TObject);
    procedure SetRestrictionReadOnly(const Value: boolean);
  private
    procedure ClearDependentFields(Field: TField);
  public // per test
    property zDbCardProps: TzDbCardProps read FzDbCardProps write SetzDbCardProps;
  protected
    isResizing: boolean;
    procedure Resize; override;
    procedure Resized;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  protected
    procedure ChangeScale(M, D: integer; isDpiChange: boolean); override;
    procedure doBeforeCreateControls;
    procedure doAfterCreateControls;

    procedure doBeforeCreateControl(const name: string; var Control: TWinControl);
    procedure doAfterCreateControl(const name: string; Control: TWinControl);
    procedure doBeforeCreateDbControl(const FieldName: string; var cxCustomEdit: TcxCustomEdit);
    procedure doAfterCreateDbControl(const FieldName: string; cxCustomEdit: TcxCustomEdit);
  private
    Inserting: boolean;
  private
    disableResize: boolean;
    FIsDestroying: boolean;
    property IsDestroying: boolean read FIsDestroying;
  private
    FOnAfterCreateControl: TAfterCreateControlEvent;
    FOnAfterCreateDbControl: TAfterCreateDbControlEvent;
    FOnBeforeCreateControl: TBeforeCreateControlEvent;
    FOnBeforeCreateDbControl: TBeforeCreateDbControlEvent;
  private
    function ActiveMonitor: TMonitor;
  private
    procedure SetOnAfterCreateControls(const Value: TNotifyEvent);
    function UniqueComponentName(const name: string): string;
    procedure ClearInvalidDefaultValues;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure dbDelete;
    procedure dbEdit;
    procedure dbInsert;

    procedure Post;
    procedure Cancel;
  public
    procedure ValidateControls(const ARaiseExceptionOnError: boolean = false);
    procedure ReopenLookupDataSet(const FieldName: string; const doCopyMappingFields: boolean);
    procedure SetLookupTransactions(const FieldName: string; ReadTrans, WriteTrans: TzFbTransaction);
  public
    procedure HideField(const FieldName: string);
  public
    property DataController: TzDataController read FDataController;
    property zControls: TzControls read FzControls;
  public
    property CardID: string read GetCardID write SetCardID;
    property DisableDelete: boolean read FDisableDelete write SetDisableDelete;
    property DisableEdit: boolean read FDisableEdit write SetDisableEdit;
    property DisableInsert: boolean read FDisableInsert write SetDisableInsert;
    property ReadOnly: TzDbCardReadOnly read FReadOnly write SetReadOnly default crUseLoadedProps;
  public
    property RestrictionReadOnly: boolean read FRestrictionReadOnly write SetRestrictionReadOnly;

    property zSystem: TzSystem read FzSystem write SetzSystem;
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
  public
    function GetDialogWidth: integer;
    function CalcDialogHeight(doDisplayControls: boolean = false): integer;
    function CalcSuggestedDialogWidth: integer;
    function GetDialogTitle: string;
    function GetTitle: string;
    procedure SetTitle(const Title: string);
    procedure ForceDisplay;
    procedure RefreshDisplay;
    procedure ForceCopyMappingFields;
    procedure ActivateDataSet;
    procedure InitToolActions;
    procedure ExecuteToolConfig;
    procedure UpdateColors;
    function ValidateRequiredFields(RaiseError: boolean): boolean;
    function ActiveFieldName: string;
    function ActiveCustomEdit: TcxCustomEdit;
    procedure RealignToolbars;

    function FindLayoutGroup(const GroupName: string): TdxLayoutGroup;
    function FindLayoutItem(const FieldName: string): TdxLayoutItem;
  private
    FLookupsEnabled: boolean;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    procedure SetLookupsEnabled(Value: boolean);
  private
    procedure EnableLookups;
    procedure DisableLookups;
  private
    function NameForField(const FieldName: string): string;
    function NameForFiller(const RowIndex, ColUsed: integer): string;
    function NameForGroup(const FieldName: string): string;
    function NameForGroupRow(const GrpName: string; RowIndex: integer): string;
    function NameForGroupFiller(const GrpName: string; RowIndex, ColUsed: integer): string;
    function NameForRow(const RowIndex: integer): string;
    function NameForSep(const RowIndex: integer): string;
    function ExtractFieldNameFromLayoutItem(const ItemName: string): string;
    function ExtractGroupNameFromRowName(const RowName: string): string;
  private
    procedure UpdateCheckGroupBoxes;
    procedure OnCheckGroupBoxStateChanged(Sender: TObject);
    procedure ResetTabsToFirstPage;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
  public
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
  published
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property OnDataSetDelete: TNotifyEvent read FOnDataSetDelete write FOnDataSetDelete;
    property OnDataSetEdit: TNotifyEvent read FOnDataSetEdit write FOnDataSetEdit;
    property OnDataSetInsert: TNotifyEvent read FOnDataSetInsert write FOnDataSetInsert;
  published
    property LookupsEnabled: boolean read FLookupsEnabled write SetLookupsEnabled;
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write FOnBeforeCreateControls;
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write SetOnAfterCreateControls;

    property OnBeforeCreateControl: TBeforeCreateControlEvent read FOnBeforeCreateControl write FOnBeforeCreateControl;
    property OnAfterCreateControl: TAfterCreateControlEvent read FOnAfterCreateControl write FOnAfterCreateControl;
    property OnBeforeCreateDbControl: TBeforeCreateDbControlEvent read FOnBeforeCreateDbControl write FOnBeforeCreateDbControl;
    property OnAfterCreateDbControl: TAfterCreateDbControlEvent read FOnAfterCreateDbControl write FOnAfterCreateDbControl;
  published
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write FOnCustomSaveProps;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write FOnCustomLoadProps;
  end;

const
DevExtremeSaveDbCard:
procedure(Card: TzDbCard) = nil;

implementation

uses
  System.UITypes,
  System.Math,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  dxSkinsCore,
  dxSkinsLookAndFeelPainter,
  cxGridDBTableView,
  zMsg,
  zMemoDialog,
  zRichEditDialog,
  zImageDialog,
  zDbViewDlg,
  zDX,
  zz.base.editor._form,
  zFrmInspector,
  zFrmCollection,
  zDbCardDlg,
  zLocalizer,
  frmNuovaLookup,
  System.JSON,
  zFormEditor_ComboItems,
  zOverrides,
  cxDBData,
  zToolConfigDlg;

{$R *.dfm}

const
  FONT_WIDTH = 7; // px per carattere, Segoe UI 10pt @ 96dpi

var
  SiDbCard: TSiSession;
  siRed: TSiSession;

type
  TcxCustomEditAccess = class(TcxCustomEdit);
  TdxCustomCheckGroupBoxAccess = class(TdxCustomCheckGroupBox);

  TGroupRowState = class
    GrpCtrlName: string; // nome del ctGroupBox nella collection (es. 'grpAzienda')
    ParentGroup: TdxLayoutGroup; // il TdxLayoutGroup del gruppo
    GrpCurrentRow: TdxLayoutGroup;
    GrpSizeUsed: integer;
    GrpRowIndex: integer;
    GrpMaxSize: integer; // capacità delle righe interne (larghezza del gruppo in caratteri)
  end;

  /// ///////////////////////////////////////////////////////////////

procedure TzControl.CheckLookupRecordValid;
begin
  if not LookupRecordValid then
    raise Exception.Create('Il valore selezionato è disabilitato.');
end;

procedure TzControl.CopyMappingFields(Field2Exclude: string = '');
var
  zLookup: TzLookup;
  SrcDataSet, DestDataSet: TzFbDataSet;
begin

  if not ControlIsLookup then
    Exit;

  // 03.02.2020 Mantis 1223
  if IsEmptyValue then
    Exit;

  DestDataSet := Controls.DataSet;

  if Assigned(DestDataSet) then
    if DestDataSet.Active then // alla chiusura del dataset viene chiamato l'evento
    begin
      SrcDataSet := lkDataSet;

      zLookup := GetLookup(Controls.zSystem);

      if Assigned(zLookup) then
        DestDataSet.CopyMappingFields(SrcDataSet, zLookup.Mappings, IsEmptyValue, Field2Exclude);
    end;
end;

constructor TzControl.Create(Collection: TCollection);
begin
  inherited;
  Controls := Collection as TzControls;
  DomainDisplayLabel := '';
  FLookupEnabled := true;
  EditValueChanging := false;
  FzCtrlType := ctDefault;
  FControl := nil;
  FcxCustomEdit := nil;
  FcxLabel := nil;
  FLines := 1;
  FSize := -1;
  FColSpan := 0;
  FDisplayLabel := '';
  FVisible := true;
  FGroup := '';
  FRowPlacement := rpAuto;

  FIdLookup := '';
  FlkDataSource := nil;
  FlkDataSet := nil;

  FForcedReadOnly := false;
  FFieldReadOnly := false;
  FFieldRequired := false;
  FLookupIgnoreFieldReadOnly := true;
  FReadOnly := false;
  FRequired := false;
  FCustomActions := TOrderedDictionary<string, TBasicAction>.Create;
  ResetPos;
end;

destructor TzControl.Destroy;
begin
  FreeAndNil(FCustomActions);
  DestroyControls;
  inherited;
end;

function TzControl.CreateControl(const name: String; ControlType: TzCtrlType): TWinControl;
begin
  result := nil;

  case ControlType of
    ctGroupBox:
      begin
        // Il raggruppamento è gestito da TdxLayoutGroup in BuildLayoutItems.
        // Non serve più un TcxGroupBox VCL.
        result := nil;
      end;
    ctButton:
      begin
        result := TcxButton.Create(Controls.Card);
        result.Visible := false;
        result.name := 'btn' + Name;
        result.Parent := Controls.Card;
      end;
    ctSeparator:
      begin
        result := nil;
      end;
    ctLineBreak:
      begin
        // nulla
      end;
  end;
end;

procedure TzControl.CreateControls;
var
  Caption: string;
begin
  SiDbCard.EnterMethod(Self, 'TzControl.CreateControls');
  SiDbCard.LogVerbose(Name);

  DestroyControls;

  if zCtrlType.IsDataAware then
  begin

    // ctCheckGroupBox: il raggruppamento con checkbox è gestito da
    // TdxLayoutGroup.ButtonOptions.CheckBox in BuildLayoutItems.
    // Non serve un TdxDBCheckGroupBox VCL.
    if zCtrlType = ctCheckGroupBox then
    begin
      SiDbCard.LeaveMethod(Self, 'TzControl.CreateControls');
      Exit;
    end;

    if IsLookup then
    begin
      SiDbCard.LogString('IdLookup', IdLookup);
      FlkDataSet := CreateDataSet(IdLookup);
      FlkDataSet.AfterOpen := LookupDatasetAfterOpen;
      FlkDataSource := CreateDataSource(lkDataSet);
    end;

    Controls.Card.doBeforeCreateDbControl(Name, FcxCustomEdit);

    if not Assigned(FcxCustomEdit) then
      FcxCustomEdit := CreateDbControl(Name, zCtrlType);

    InitControlProperties;

    InternalSetEditability;

    if zCtrlType = ctCheckGroupBox then
    begin
      TdxDBCheckGroupBox(cxCustomEdit).Caption := DisplayLabel;
      TdxDBCheckGroupBox(cxCustomEdit).Style.StyleController := dx.GroupStyleController;
    end;

    UpdateColor;

    Controls.Card.doAfterCreateDbControl(Name, FcxCustomEdit);
  end
  else
  begin
    Controls.Card.doBeforeCreateControl(Name, FControl);

    FControl := CreateControl(Name, zCtrlType);

    InitPopupMenu;

    Controls.Card.doAfterCreateControl(Name, FControl);
  end;

  SiDbCard.LeaveMethod(Self, 'TzControl.CreateControls');
end;

procedure TzControl.DestroyControls;
begin
  try

    if Assigned(FcxCustomEdit) then
      if FcxCustomEdit is TcxCustomDropDownEdit then
      begin
        try
          // manda in crash all'uscita da form contenenti lookup
          TcxCustomDropDownEdit(FcxCustomEdit).DroppedDown := false;
        except
        end;
      end;

    FreeAndNil(FControl);
    FreeAndNil(FcxCustomEdit);
    FreeAndNil(FcxLabel);
    FreeAndNil(FlkDataSource);
    FreeAndNil(FlkDataSet);
  except
    on e: Exception do
    begin
      // ConfirmOk(name);
      // raise
    end;
  end;
end;

function TzControl.CreateDbControl(const DataField: String; ControlType: TzCtrlType): TcxCustomEdit;
begin
  result := Controls.CreateDbControl(DataField, ControlType);
end;

function TzControl.CreateLabel(const LabelName: string; const Caption: String; cxCustomEdit: TcxCustomEdit; const Transparent: boolean; const AutoSize: boolean): TcxLabel;
begin
  result := Controls.CreateLabel(LabelName, Caption, cxCustomEdit, Transparent, AutoSize);
end;

function TzControl.CreateDataSet(const IdLookup: string): TzFbDataSet;
begin
  result := CreateFbDataSet(nil, Controls.zSystem.zFbDatabase, Controls.ReadTrans, Controls.WriteTrans);

  result.name := ValidateComponentName('LK_' + IdLookup);

  AssignDataSetProps(IdLookup, result);
end;

procedure TzControl.AssignDataSetProps(const IdLookup: string; DataSet: TzFbDataSet);
var
  Lookup: TzLookup;
begin
  Lookup := Controls.zSystem.zLookups.Get(IdLookup, false);

  if Assigned(Lookup) then
    DataSet.IdDataSet := Lookup.DataSet;
  // else raise??

  DataSet.AutoCommit := true;
  Controls.zSystem.DataSetLoadProps(DataSet);
  // DataSetLoadProps assegna l'evento standard, occorre forzare il nostro
  DataSet.OnGetQueryParams := OnDataSetQueryParams;
  DataSet.UseSqlLocate := true;
end;

function TzControl.CreateDataSource(DataSet: TzFbDataSet): TDataSource;
begin
  result := TDataSource.Create(nil);
  result.name := DataSet.name + 'Src';
  result.DataSet := DataSet;
end;

procedure TzControl.DoHyperLink(Sender: TObject);
var
  Binding: TcxDBEditDataBinding;
  Field: TField;
  FieldName: string;
  Value: Variant;
begin

  if Sender is TcxCustomHyperLinkEdit then
  begin
    Binding := TcxDBEditDataBinding(TcxCustomEditAccess(Sender).DataBinding);
    Field := Binding.Field;

    if Assigned(Field) then
    begin
      FieldName := Field.FieldName;
      Value := Field.Value;
    end
    else
    begin
      FieldName := TcxCustomHyperLinkEdit(Sender).Properties.Prefix;
      Value := TcxCustomHyperLinkEdit(Sender).EditValue;
    end
  end // \ctHyperLink
  else
    if ControlIsLookup then
    begin

      if Sender is TcxDBLookupComboBox then
        Binding := TcxDBEditDataBinding(TcxDBLookupComboBox(Sender).DataBinding)
      else
        if Sender is TcxDBExtLookupComboBox then
          Binding := TcxDBEditDataBinding(TcxDBExtLookupComboBox(Sender).DataBinding)
        else
          Exit;

      Field := Binding.Field;

      if Assigned(Field) then
      begin
        FieldName := Field.FieldName;
        Value := Field.Value;
      end;
    end; // \ctLookupHyperLink

  if not FieldName.IsEmpty then
    if Assigned(Field) then
      base.HyperLink(Self, FieldName, Field.Value);
end;

procedure TzControl.F2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  procedure CheckEditMode;
  begin

    if Controls.DataSet.CanModify then
      Controls.DataSet.CheckEditMode;
  end;

begin

  if Key <> vk_f2 then
    Exit;

  if ControlIsLookup or (Sender is TcxDBButtonEdit) then
  begin

    if IdLookup <> '' then
    begin
      CheckEditMode;
      ExecuteLookupDlg;
      Key := 0;
    end;
  end
  else
    if Sender is TcxDbMemo then
    begin
      CheckEditMode;
      zExecuteMemoDialog(Sender as TcxDbMemo, '', GetCustomActions);
      Key := 0;
    end
    else
      if Sender is TcxDbRichEdit then
      begin
        CheckEditMode;
        zExecuteRichEditDialog(Sender as TcxDbRichEdit, '');
        Key := 0;
      end
      else
        if Sender is TcxDbImage then
        begin
          CheckEditMode;
          zExecuteImageDialog(Sender as TcxDbImage, '');
          Key := 0;
        end;
end;

procedure TzControl.FillCheckComboBoxItems;
var
  StringList: TStringList;
  DataSet: TzFbDataSet;
  FieldName: string;
  zLookup: TzLookup;
begin
  try
    if IdLookup.IsEmpty then
      Exit;

    zLookup := Controls.zSystem.zLookups.Get(IdLookup);

    if not Assigned(zLookup) then
      Exit;

    if not(cxCustomEdit is TcxDBCheckComboBox) then
      Exit;

    FieldName := zLookup.FirstFieldFK;
    if FieldName.IsEmpty then
      raise Exception.Create('Campo di ricerca non definito per il lookup ' + IdLookup);

    StringList := TStringList.Create;
    try
      DataSet := CreateDataSet(IdLookup);
      try
        DataSet.Active := true;
        while not DataSet.Eof do
        begin
          StringList.Add(DataSet.FieldByName(FieldName).asString);
          DataSet.Next;
        end;
      finally
        FreeAndNil(DataSet);
      end;

      TcxDBCheckComboBox(cxCustomEdit).FillItems(StringList);
    finally
      FreeAndNil(StringList);
    end;
  except
    on e: Exception do
      Application.HandleException(e);
  end;
end;

procedure TzControl.ForceValidation;
begin
  if Assigned(cxCustomEdit) then
    // zz 21.01.2019 a seguito della modifica nell'DataSourceStateChange (thread)
    // arriva l'evento prima del settaggio dei default Expression
    // zz 13.05.2019: tolto a seguito delle correzioni devExpress
    // if not((zCtrlType = ctCheckBox) and VarIsNull(cxCustomEdit.EditValue)) then

    if not cxCustomEdit.EditModified then // 15.01.2020: es. Scheda manutenzione, entrando nella data resetta il valore appena inserito
    begin
      // Se il controllo è un lookup e il suo dataset è chiuso,
      // chiamare ValidateEdit forzerebbe DevExpress ad aprirlo e chiuderlo
      // solo per validare il testo. Saltiamo la validazione per salvare le performance.
      if ControlIsLookup and Assigned(lkDataSet) and (not lkDataSet.Active) then
        SiDbCard.LogString('ForceValidation', 'Skipped ValidateEdit because lkDataSet is closed')
      else
        cxCustomEdit.ValidateEdit(false);
    end;
end;

function TzControl.GetLookup(zSystem: TzSystem): TzLookup;
begin
  if IdLookup = '' then
    result := nil
  else
    result := zSystem.zLookups.Get(IdLookup, false);
end;

function TzControl.IsEmptyValue: boolean;
begin
  SiDbCard.EnterMethod(Self, 'IsEmptyValue');
  result := Assigned(cxCustomEdit) and (VarIsNull(cxCustomEdit.EditValue) or (VarToStr(cxCustomEdit.EditValue) = ''));
  SiDbCard.LogBoolean('IsEmptyValue', result);
  SiDbCard.LeaveMethod(Self, 'IsEmptyValue');
end;

function TzControl.IsLookup: boolean;
begin
  result := zCtrlType.IsLookup;
end;

function TzControl.IsPicklist: boolean;
begin
  result := zCtrlType.IsPicklist;
end;

function TzControl.LookupRecordValid: boolean;
var
  Field: TField;
begin
  result := true;

  if Assigned(lkDataSet) then
  begin
    Field := lkDataSet.FindField('DISABLED');

    if Assigned(Field) then
    begin
      if Field is TBooleanField then
        result := Field.AsBoolean = false
      else
        result := Field.asString = 'N';
    end;
  end;
end;

procedure TzControl.MakeVisible;
var
  dxItem: TdxCustomLayoutItem;
begin
  if Assigned(cxLabel) then
    cxLabel.Visible := true;

  if Assigned(cxCustomEdit) then
    cxCustomEdit.Visible := true;

  if Assigned(Control) then
    Control.Visible := true;

  // Sincronizza visibilità sul TdxLayoutItem (se UseLayoutControl attivo)
  if Assigned(Controls) and Assigned(Controls.Card) then
  begin
    dxItem := Controls.Card.dxLayoutControl.FindItem(Controls.Card.NameForField(Name));
    if not Assigned(dxItem) then
      dxItem := Controls.Card.dxLayoutControl.FindItem(Controls.Card.NameForGroup(Name));
    if Assigned(dxItem) then
      dxItem.Visible := true;
  end;
end;

procedure TzControl.OnDataSetQueryParams(DataSet: TDataSet);
var
  ParamsChanged: boolean;
begin
  if Assigned(DataSet) then
  begin
    AssignMasterFieldsParams(DataSet as TzFbDataSet, ParamsChanged);
    // richiama quello di default
    Controls.zSystem.DataSetQueryParams(DataSet as TzFbDataSet);
  end;
end;

procedure TzControl.OnLookupButtonClick(Sender: TObject; AButtonIndex: integer);
begin
  if ControlIsLookup then
  begin
    case AButtonIndex of
      1:
        ExecuteLookupDlg;
      2:
        DoHyperLink(Sender);
    end;
  end
  else
    if (cxCustomEdit is TcxDBButtonEdit) then // ctComboDlg
      ExecuteLookupDlg;
end;

procedure TzControl.OnLookupEditValueChanged(Sender: TObject);
begin
  SiDbCard.EnterMethod(Self, 'OnLookupEditValueChanged');

  if ControlIsLookup then
  begin
    // Evita falsi trigger di IsEmptyValue quando il dataset viene chiuso temporaneamente da un ReOpen()
    if Assigned(lkDataSet) and not lkDataSet.Active then
    begin
      SiDbCard.LeaveMethod(Self, 'OnLookupEditValueChanged');
      Exit;
    end;

    // ZZ 23-02-2021: aggiunto controllo su EditModified; vedi mail Fede del 17.06.2020
    if IsEmptyValue or (TcxCustomDropDownEdit(Sender).DroppedDown) or TcxCustomEdit(Sender).EditModified then
      if Controls.Card.DataController.IsEditing then
        if not EditValueChanging then // evita ricorsione
        begin
          SiDbCard.LogString('EditValueChanged', Name);

          EditValueChanging := true;
          try
            // in DataSourceDataChange non viene chiamato se in dropDown,
            // per evitare il problema segnalato da mail GD 05.12.2022
            Controls.Card.ClearDependentFields(GetField);

            CheckLookupRecordValid;
            CopyMappingFields(Name);

            // in DataSourceDataChange non viene chiamato se in dropDown,
            // per evitare il problema segnalato da mail GD 05.12.2022
            // Controls.VerifyLookupsParams(GetField, Self); // SOSTITUITO CON DEBOUNCE
            if not Controls.Card.PendingVerifyLookupsParams then
              if not Controls.Card.InsideVerifyLookupsParams then
              begin
                Controls.Card.PendingVerifyLookupsParams := true;
                Controls.Card.PostInternalMessage(cmd_VerifyLookupsParams);
              end;
          finally
            EditValueChanging := false;
          end;

          SiDbCard.LogString('OnLookupEditValueChanged - Done', Name);
        end;
  end;

  SiDbCard.LeaveMethod(Self, 'OnLookupEditValueChanged');
end;

procedure TzControl.EnsureLookupDataSetOpen;
begin
  if not ControlIsLookup then
    Exit;

  if not Assigned(lkDataSet) then
    Exit;

  if lkDataSet.Active then
    Exit;

  if not(Assigned(Controls.DataSet) and Controls.DataSet.Active) then
    Exit;

  if lkDataSet.SelectSQL.Count = 0 then
    Exit;

  SiDbCard.LogString('EnsureLookupDataSetOpen', Name);
  try
    lkDataSet.Active := true;
  except
    on e: Exception do
    begin
      SiDbCard.LogException(e);
      SiDbCard.LogStringList(' Lookup ', lkDataSet.SelectSQL);
      raise;
    end;
  end;
end;

procedure TzControl.OnLookupInitPopup(Sender: TObject);
begin
  EnsureLookupDataSetOpen;
end;

procedure TzControl.OnLookupKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  if ControlIsLookup then
  begin
    if TcxCustomTextEdit(cxCustomEdit).EditingText = '' then
    begin
      SiDbCard.LogString('OnLookupKeyUp (Clear)', Name);
      cxCustomEdit.Clear;
      cxCustomEdit.PostEditValue;

      UpdateColor();
    end
    else
      // l'utente sta digitando per cercare: il lkDataSet è chiuso per
      // performance, va aperto on-demand altrimenti la ricerca incrementale
      // non trova nulla
      EnsureLookupDataSetOpen;
  end;
end;

procedure TzControl.OnLookupNewLookupDisplayText(Sender: TObject; const AText: TCaption);
var
  zLookup: TzLookup;
  Field: TField;
begin
  SiDbCard.EnterMethod(Self, 'OnLookupNewLookupDisplayText');

  zLookup := GetLookup(base);

  if Assigned(zLookup) then
    if not zLookup.OnlyFromLookup then
      Exit;

  Field := LookupControlField;

  if not Assigned(Field) then
    Exit;

  if (not AnsiSameText(Field.asString, AText)) or (AText = '') then
    Controls.Card.PostInternalMessage(cmd_NewLookupDisplayText, NativeUInt(Sender));

  SiDbCard.LeaveMethod(Self, 'OnLookupNewLookupDisplayText');
end;

procedure TzControl.ResetLookupDataSet;
var
  Field: TField;
begin
  Field := GetField;

  if Assigned(lkDataSet) then
    if Assigned(Field) then
      if Field.isNull then
      begin
        SiDbCard.LogString('ResetLookupDataSet', Name);
        lkDataSet.RevertSQL(true);
        UpdateColor();
      end;
end;

procedure TzControl.ResetPos;
begin
  FLeft := -1;
  FTop := -1;
  FWidth := -1;
  FHeight := -1;
  FTotalHeight := -1;
end;

procedure TzControl.AssignMasterFieldsParams(DataSet: TzFbDataSet; out ParamsChanged: boolean);

  function GetSourceField(DataSet: TDataSet; FieldName: string): TField;
  begin
    // zz 09.05.2020: scorre la sequenza master/detail per trovare il parametro
    result := nil;

    if not Assigned(DataSet) then
      Exit;

    result := DataSet.FindField(FieldName);

    if not Assigned(result) then
      // se non lo trova nel dataset stesso prova a cercare nell'eventuale master
      if Assigned(DataSet.DataSource) then
        if Assigned(DataSet.DataSource.DataSet) then
          result := GetSourceField(DataSet.DataSource.DataSet, FieldName);
  end;

var
  s: string;
  i: integer;
  MasterFieldsList: TStringList;
  FieldTokens: TStringList;
  SrcField, DestParam: string;
  dummy: integer;
  Field: TField;
  MasterFields: string;
  zLookup: TzLookup;
begin
  SiDbCard.EnterMethod('zDbCard.TzControl.SetDataSetParams');
  /// /
  /// Il dlg non usa lkDataset ma uno proprio
  assert(Assigned(DataSet));

  ParamsChanged := false;

  zLookup := Controls.zSystem.zLookups.Get(IdLookup);

  if not Assigned(zLookup) then
    Exit;

  if not Assigned(DataSet) then
    Exit;

  if not Assigned(Controls.DataSet) then
    Exit;

  if DataSet.SelectSQL.Text = '' then
    Exit;

  if not DataSet.Active then
    DataSet.Prepare;

  if trim(zLookup.MasterFields) <> '' then
  begin
    SiDbCard.LogString('MasterFields', zLookup.MasterFields);

    MasterFieldsList := TStringList.Create;
    try
      FieldTokens := TStringList.Create;
      try
        MasterFields := zLookup.MasterFields;

        MasterFields := MasterFields.Replace(',', ';');
        MasterFields := MasterFields.Replace('@', '=');
        MasterFields := MasterFields.Replace(' ', '');

        FieldTokens.Delimiter := '=';
        MasterFieldsList.Delimiter := ';';
        MasterFieldsList.DelimitedText := MasterFields;

        for i := 0 to MasterFieldsList.Count - 1 do
        begin
          s := trim(MasterFieldsList[i]);
          FieldTokens.DelimitedText := s;

          SiDbCard.LogString('Assegnamento', s);

          if FieldTokens.Count = 1 then
          begin
            DestParam := s;
            SrcField := s;
          end;
          if FieldTokens.Count = 2 then
          begin
            DestParam := FieldTokens[0];
            SrcField := FieldTokens[1];
          end;

          SiDbCard.LogString('SrcField', SrcField);
          SiDbCard.LogString('DestParam', DestParam);

          // dest è il parametro della tabella lookup
          if DataSet.ParamExists(DestParam) then
          begin
            Field := GetSourceField(Controls.DataSet, SrcField);

            // src è il campo della tabella sul quale verrà applicato l'esito del lookup
            if Assigned(Field) then
            begin
              SiDbCard.LogValue(Field.FieldName, Field.asString);

              if Field.isNull then
              begin
                // Fix: TParam.IsNull può restituire False anche se il Value è Null/Unassigned,
                // oppure la libreria db può inizializzare i parametri stringa a '' o gli interi a '0'.
                // Controlliamo che il parametro abbia effettivamente un valore valido prima di fare Clear.
                if (not DataSet.ParamByName(DestParam).isNull) and (not VarIsNull(DataSet.ParamByName(DestParam).Value)) and (not VarIsEmpty(DataSet.ParamByName(DestParam).Value)) and
                  (trim(VarToStrDef(DataSet.ParamByName(DestParam).Value, '')) <> '') and (trim(VarToStrDef(DataSet.ParamByName(DestParam).Value, '')) <> '0') then
                begin
                  SiDbCard.LogString('AssignParam', 'Field is Null, Param is NOT Null/Empty -> Clearing Param. VarType: ' + IntToStr(VarType(DataSet.ParamByName(DestParam).Value)) + ', AsString: [' + VarToStrDef(DataSet.ParamByName(DestParam).Value,
                    '') + ']');
                  DataSet.ParamByName(DestParam).Clear;
                  ParamsChanged := true;
                end
                else
                  SiDbCard.LogString('AssignParam', 'Field is Null, Param is Null/Empty -> No Change');
              end
              else
              begin
                // Fix: Preveniamo il bug in cui l'assegnazione di '' a un parametro Date
                // lo fa convertire internamente in Null, creando un loop infinito
                // perché Null <> '' restituisce sempre True al giro successivo.
                if (VarIsNull(DataSet.ParamByName(DestParam).Value) or VarIsEmpty(DataSet.ParamByName(DestParam).Value) or (trim(VarToStrDef(DataSet.ParamByName(DestParam).Value, '')) = '0')) and (trim(VarToStrDef(Field.Value, '')) = '') then
                begin
                  SiDbCard.LogString('AssignParam', 'Param is Null/Empty/0, Field is Empty String -> No Change');
                  // I valori sono funzionalmente equivalenti (Null vs stringa vuota)
                end
                else
                  if trim(VarToStrDef(DataSet.ParamByName(DestParam).Value, '')) <> trim(VarToStrDef(Field.Value, '')) then
                  begin
                    SiDbCard.LogString('AssignParam', 'Param Value <> Field Value -> Updating Param');
                    DataSet.ParamByName(DestParam).Value := Field.Value;
                    ParamsChanged := true;
                  end
                  else
                    SiDbCard.LogString('AssignParam', 'Param Value == Field Value -> No Change');
              end;
            end
            else
              SiDbCard.LogVerbose('Campo sorgente non trovato: ' + SrcField);
          end
          else
            SiDbCard.LogVerbose('Parametro destinazione non trovato: ' + DestParam);
        end;
      finally
        FreeAndNil(FieldTokens);
      end;
    finally
      FreeAndNil(MasterFieldsList);
    end;
  end;
  SiDbCard.LeaveMethod('zDbCard.TzControl.SetDataSetParams');
end;

procedure TzControl.InitControlProperties;
var
  Binding: TcxDBEditDataBinding;
  ButtonEdit: TcxDBButtonEdit;
  cxCheckBoxProperties: TcxCheckBoxProperties;
  CheckboxIsBoolean: boolean;
  Field: TField;
begin
  Field := nil;
  if Assigned(Controls.DataSet) then
    Field := Controls.DataSet.FindField(Name);

  dx.InitProperties(zCtrlType, cxCustomEdit.ActiveProperties, Domain, Field);

  Binding := TcxDBEditDataBinding(TcxCustomEditAccess(cxCustomEdit).DataBinding);
  Binding.DataSource := Controls.DataSource;
  Binding.DataField := Name;

  cxCustomEdit.ActiveProperties.ReadOnly := ReadOnly;
  cxCustomEdit.TabStop := not Readonly;

  cxCustomEdit.InternalProperties.ValidateOnEnter := true;
  cxCustomEdit.InternalProperties.ValidationErrorIconAlignment := taRightJustify;
  cxCustomEdit.InternalProperties.ValidationOptions := [evoShowErrorIcon, evoAllowLoseFocus];

  // mantis 958: si mangia il return
  if zCtrlType = ctRTF then
    cxCustomEdit.InternalProperties.ValidateOnEnter := false;

  InitPopupMenu;

  if zCtrlType.IsLookup then
    InitLookupProperties;

  case zCtrlType of
    ctDefault:
      ;
    ctEdit:
      begin
      end;
    ctSpin:
      begin
      end;
    ctDate:
      begin
      end;
    ctTime:
      begin
      end;
    ctDateTime:
      begin
      end;
    ctPickList:
      begin
      end;
    ctPickListImage:
      begin
      end;
    ctRadioGroup:
      begin
        TcxDbRadioGroup(cxCustomEdit).Caption := '';
      end;
    ctComboDlg:
      begin
        ButtonEdit := cxCustomEdit as TcxDBButtonEdit;
        ButtonEdit.Properties.OnButtonClick := OnLookupButtonClick;
        ButtonEdit.OnKeyDown := F2KeyDown;
      end;
    ctLookup:
      begin
      end;
    ctLookupExt:
      begin
      end;
    ctLookupHyperLink:
      begin
      end;
    ctCheckBox:
      begin
        TcxCheckBox(cxCustomEdit).AutoSize := false;
        TcxCheckBox(cxCustomEdit).Transparent := false; // zdx
        TcxCheckBox(cxCustomEdit).Transparent := true; // ZZ 06.12.2021: non ricordo perchè false
        TcxCheckBox(cxCustomEdit).Style.TransparentBorder := true;
      end;

    ctRating:
      begin
        TdxRatingControl(cxCustomEdit).Transparent := true;
      end;

    ctMemo:
      begin
        (cxCustomEdit as TcxDbMemo).OnKeyDown := F2KeyDown;
      end;
    ctRTF:
      begin
        (cxCustomEdit as TcxDbRichEdit).OnKeyDown := F2KeyDown;
      end;
    ctImage:
      begin
        (cxCustomEdit as TcxDbImage).OnKeyDown := F2KeyDown;
      end;
    ctHyperLink:
      begin
        TcxCustomHyperLinkEditProperties(cxCustomEdit.ActiveProperties).Prefix := Name;
        TcxCustomHyperLinkEditProperties(cxCustomEdit.ActiveProperties).OnStartClick := DoHyperLink;
      end;
    ctProgressBar:
      begin
      end;
    ctCustomDlg:
      begin
      end;

    ctCheckComboBox:
      begin
        FillCheckComboBoxItems;
      end;

    ctToggleSwitch:
      ;
    ctDateTimeWheelPicker:
      ;
    ctTokenEdit:
      // LineCount
      ;
    ctFormattedLabel:
      // ShowEndEllipsis;
      // WordWrap;
      ;
    ctCheckGroupBox: // SubControls
      begin
      end;
    ctButtonEdit:
      ;
    ctMaskEdit:
      ;
    ctCheckGroup:
      ;
    ctShellComboBox:
      ;
  end;
end;

procedure TzControl.InitLookupProperties;
var
  column: TcxLookupDBGridColumn;
  DataField: string;
  i: integer;
  idView: string;
  zLookup: TzLookup;
  zDbViewProps: TzDbViewProps;
  TextWidth: integer;
  zColumn: TzColumn;
  Field: TField;

  function OpenLookupDataSet: boolean;
  begin
    result := false;
    try
      if lkDataSet.SelectSQL.Count > 0 then
      begin

        if Assigned(Controls.DataSet) and Controls.DataSet.Active then
          lkDataSet.Active := true;
        result := true;
      end
      else
      begin
        ConfirmOk('Sql di lookup non definito: ' + IdLookup);
        result := false;
      end;
    except
      on e: Exception do
      begin
        SiDbCard.LogException(e);
        SiDbCard.LogStringList(' Lookup ', lkDataSet.SelectSQL);
        raise;
      end;
    end;
  end;

begin
  SiDbCard.EnterMethod(Self, 'InitLookupProperties');

  if not ControlIsLookup then
    Exit;

  if IdLookup = '' then
    Exit;

  if not Controls.zSystemOk then
    Exit;

  zLookup := GetLookup(Controls.zSystem);

  if not Assigned(zLookup) then
  begin
    ConfirmOk('Lookup non definito : ' + IdLookup);
    Exit;
  end;

  if not Assigned(zLookup.DataSet_Obj) then
  begin
    ConfirmOk('DataSet di Lookup non definito : ' + IdLookup);
    Exit;
  end;

  if not OpenLookupDataSet then
    Exit;

  /// //////////////////////////
  try
    if cxCustomEdit is TcxDBLookupComboBox then
      dx.InitLookup(IdLookup, TcxDBLookupComboBox(cxCustomEdit), lkDataSet, lkDataSource, zLookup.FieldNamesFK, zLookup.DisplayColumns, zCtrlType = ctLookupHyperLink)
    else
      if cxCustomEdit is TcxDBExtLookupComboBox then
      begin
        dx.InitLookup(IdLookup, TcxDBExtLookupComboBox(cxCustomEdit), lkDataSet, lkDataSource, zLookup.FieldNamesFK, zLookup.DisplayColumns, Controls.Card.cxGridViewRepository, zCtrlType = ctLookupHyperLink);
      end;

    /// ///
    FLookupIgnoreFieldReadOnly := zLookup.IgnoreFieldReadOnly;
    /// ///

    /// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// ///Eventi

    cxCustomEdit.OnKeyDown := F2KeyDown;
    cxCustomEdit.OnKeyUp := OnLookupKeyUp; // clear

    cxCustomEdit.ActiveProperties.OnButtonClick := OnLookupButtonClick;
    cxCustomEdit.ActiveProperties.OnEditValueChanged := OnLookupEditValueChanged;

    TcxCustomTextEditProperties(cxCustomEdit.ActiveProperties).OnNewLookupDisplayText := nil;
    TcxCustomDropDownEditProperties(cxCustomEdit.ActiveProperties).OnCloseUp := OnLookupCloseUp;
    TcxCustomDropDownEditProperties(cxCustomEdit.ActiveProperties).OnInitPopup := OnLookupInitPopup;

    if TcxCustomComboBoxProperties(cxCustomEdit.ActiveProperties).DropDownListStyle = lsEditFixedList then
    begin
      Field := LookupControlField;

      if Assigned(Field) then
        if not IsStringType(Field.DataType) then
        begin
          TcxCustomComboBoxProperties(cxCustomEdit.ActiveProperties).DropDownListStyle := lsEditList;
          TcxCustomTextEditProperties(cxCustomEdit.ActiveProperties).OnNewLookupDisplayText := OnLookupNewLookupDisplayText;
        end;
    end;
  except
    on e: Exception do
    begin
      ConfirmOk('Errore inizializzazione lookup: ' + IdLookup + sLineBreak + sLineBreak + e.Message);
    end;
  end;

  SiDbCard.LeaveMethod(Self, 'InitLookupProperties');
end;

procedure TzControl.InitPopupMenu;
var
  MenuLink: TdxBarPopupMenuLink;
begin
  MenuLink := Controls.PopupMenu.BarManager.PopupMenuLinks.Add;

  if zCtrlType.IsDataAware then
    MenuLink.Control := cxCustomEdit
  else
    MenuLink.Control := Control;

  MenuLink.PopupMenu := Controls.PopupMenu;
  MenuLink.OnAction := SetPopupCtrl;
end;

procedure TzControl.SetDisplayLabel(const Value: string);
var
  Caption: string;
  dxItem: TdxCustomLayoutItem;
begin
  FDisplayLabel := Value;

  // Gerarchia: override cliente prevale, altrimenti usa il valore passato
  Caption := Overrides.CaptionCard(Controls.Card.zDataSet.IdDataSet, Name);
  if Caption.IsEmpty then
    Caption := FDisplayLabel;

  if Assigned(cxLabel) then
    cxLabel.Caption := Caption;

  case zCtrlType of

    ctCheckGroupBox:
      begin
        if Assigned(cxCustomEdit) then
          if cxCustomEdit is TdxDBCheckGroupBox then
            TdxDBCheckGroupBox(cxCustomEdit).Caption := Caption;
      end;

    ctGroupBox:
      begin
        if Assigned(Control) then
          if Control is TcxGroupBox then
            TcxGroupBox(Control).Caption := Caption;
      end;
  end;

  // Layout control: la caption visibile vive sul TdxLayoutItem/TdxLayoutGroup,
  // non sulla cxLabel. Senza questo il rename dal popup non si vedeva fino
  // al rebuild successivo.
  if Assigned(Controls) and Assigned(Controls.Card) then
  begin
    dxItem := Controls.Card.dxLayoutControl.FindItem(Controls.Card.NameForField(Name));
    if not Assigned(dxItem) then
      dxItem := Controls.Card.dxLayoutControl.FindItem(Controls.Card.NameForGroup(Name));
    if Assigned(dxItem) then
      dxItem.CaptionOptions.Text := Caption;
  end;
end;

procedure TzControl.SetPopupCtrl(Sender: TdxBarPopupMenuLink; var X, Y: integer; ClickedByMouse: boolean; var AllowPopup: boolean);
begin
  Controls.PopupPos := Point(X, Y);

  if zCtrlType.IsDataAware then
    Controls.PopupCtrl := cxCustomEdit
  else
    Controls.PopupCtrl := Control;
end;

procedure TzControl.SetReadOnly(const Value: boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    InternalSetEditability;
  end;
end;

procedure TzControl.SetVisible(const Value: boolean);
var
  dxItem: TdxCustomLayoutItem;
begin
  if FVisible <> Value then
  begin
    FVisible := Value;

    if Assigned(cxLabel) then
      cxLabel.Visible := Value;

    if Assigned(cxCustomEdit) then
      cxCustomEdit.Visible := Value;

    if Assigned(Controls) and Assigned(Controls.Card) then
    begin
      // Nome item generato: 'li_<Field>_<CardName>' (NameForField);
      // per i ctGroupBox/ctCheckGroupBox è 'grp_<Field>_<CardName>'.
      dxItem := Controls.Card.dxLayoutControl.FindItem(Controls.Card.NameForField(Name));
      if not Assigned(dxItem) then
        dxItem := Controls.Card.dxLayoutControl.FindItem(Controls.Card.NameForGroup(Name));
      if Assigned(dxItem) then
        dxItem.Visible := Value;
    end;
  end;
end;

constructor TzControls.Create;
begin
  inherited Create(TzControl, '', -1, nil);
  FieldsHiddenByCode := TStringList.Create;
  FDataController := nil;
  PopupCtrl := nil;
  PopupPos := TPoint.Zero;
  FCard := nil;
  FPopupMenu := nil;
  FDataSet := nil;
  FDataSource := nil;
  FzSystem := nil;

  FReadTrans := nil;
  FWriteTrans := nil;

  FControlFont := TFont.Create;
end;

destructor TzControls.Destroy;
begin
  DestroyControls;
  FreeAndNil(FieldsHiddenByCode);
  FreeAndNil(FReadTrans);
  FreeAndNil(FWriteTrans);
  FreeAndNil(FControlFont);
  inherited;
end;

function TzControls.AddControl(const DataField: String; DisplayLabel: string; ControlType: TzCtrlType; Domain: TzDomain; Size: integer; Lines: integer; Group: string): TcxCustomEdit;
var
  item: TzControl;
begin
  result := nil;
  /// ///////////////
  item := Add;
  item.name := DataField;
  item.zCtrlType := ControlType;
  item.Size := Size;
  item.Lines := Lines;
  item.IdLookup := Domain.Lookup;
  item.Domain := Domain;
  item.DisplayLabel := DisplayLabel;
  item.Group := Group;
end;

function TzControls.CreateDbControl(const DataField: String; ControlType: TzCtrlType): TcxCustomEdit;
begin
  result := dx.GetCustomEditClass(ControlType).Create(Card);
  result.Visible := false;
  result.name := 'ed' + DataField;
  result.Parent := Card;

  result.Style.Font.Assign(ControlFont);
  result.Style.LookAndFeel.NativeStyle := false;
  result.StyleFocused.BorderStyle := ebsThick;
  result.StyleFocused.BorderColor := clHighlight;
end;

procedure TzControls.CreateControls;
var
  item: TzControl;
begin
  TzDbCard(Card).doBeforeCreateControls;

  for item in Self do
    if item.Visible then
      item.CreateControls;

  TzDbCard(Card).doAfterCreateControls;
end;

procedure TzControls.DestroyControls;

  procedure ResetParent;
  var
    item: TzControl;
  begin
    for item in Self do
    begin
      if item.cxCustomEdit <> nil then
        if item.cxCustomEdit.Parent <> Card then
          item.cxCustomEdit.Parent := Card;

      if item.cxLabel <> nil then
        if item.cxLabel.Parent <> Card then
          item.cxLabel.Parent := Card;

      if item.Control <> nil then
        if item.Control.Parent <> Card then
          item.Control.Parent := Card;
    end;
  end;

begin
  ResetParent; // altrimenti AV nel destroy di cxCustomEdit/Label
  Clear;

  if Assigned(PopupMenu) then
    PopupMenu.BarManager.PopupMenuLinks.Clear;
end;

function TzControls.Find(const FieldName: string): TzControl;
var
  item: TzControl;
begin
  result := nil;

  for item in Self do
    if SameText(item.name, FieldName) then
      Exit(item);
end;

function TzControls.Find(cxCustomEdit: TcxCustomEdit): TzControl;
var
  item: TzControl;
begin
  result := nil;

  for item in Self do
    if item.cxCustomEdit = cxCustomEdit then
      Exit(item);
end;

function TzControls.Find(lkDataSet: TzFbDataSet): TzControl;
var
  item: TzControl;
begin
  result := nil;

  for item in Self do
    if item.lkDataSet = lkDataSet then
      Exit(item);
end;

function TzControls.Find(Control: TWinControl): TzControl;
var
  item: TzControl;
begin
  result := nil;

  for item in Self do
    if (item.cxCustomEdit = Control) or (item.Control = Control) then
      Exit(item);
end;

function TzControls.GetDbControl(const FieldName: String): TcxCustomEdit;
var
  item: TzControl;
begin
  result := nil;

  item := Find(FieldName);

  if Assigned(item) then
    result := item.cxCustomEdit;
end;

function TzControls.GetDataField(cxCustomEdit: TcxCustomEdit): string;
begin
  result := '';

  if Assigned(cxCustomEdit) then
    if TcxCustomEditAccess(cxCustomEdit).DataBinding is TcxDBEditDataBinding then
      result := TcxDBEditDataBinding(TcxCustomEditAccess(cxCustomEdit).DataBinding).DataField;
end;

function TzControls.GetReadTrans: TzFbTransaction;
begin

  if not Assigned(FReadTrans) then
  begin

    FReadTrans := TzFbTransaction.Create(nil);
    FReadTrans.Options.Isolation := xiReadCommitted;

    if not Assigned(FReadTrans.Connection) then
      FReadTrans.Connection := zSystem.zFbDatabase;
  end;

  result := FReadTrans;
end;

function TzControls.GetWriteTrans: TzFbTransaction;
begin

  if not Assigned(FWriteTrans) then
  begin
    FWriteTrans := TzFbTransaction.Create(nil);
    FWriteTrans.Options.Isolation := xiReadCommitted;

    if not Assigned(FWriteTrans.Connection) then
      FWriteTrans.Connection := zSystem.zFbDatabase;
  end;
  result := FWriteTrans;
end;

function TzControls.Groups: TStringDynArray;
var
  zControl: TzControl;
  StringList: TStringList;
  Group: string;
begin
  result := nil;

  StringList := TStringList.Create;
  try
    StringList.Duplicates := dupIgnore;
    StringList.CaseSensitive := false;

    for zControl in Self do
      if not zControl.Group.IsEmpty then
        if StringList.IndexOf(zControl.Group) = -1 then
          StringList.Add(zControl.Group);

    for Group in StringList do
    begin
      SetLength(result, Length(result) + 1);
      result[Length(result) - 1] := Group;
    end;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzControls.LoadFromProps(zDbCardProps: TzDbCardProps);
var
  Field: TField;
  CtrlsExists: boolean;
  ctrlProps: TzControlProps;
  item: TzControl;
  Origin: string;

begin
  // Migrazione legacy: converte gli item ctLineBreak in RowPlacement (zSystem)
  zDbCardProps.Controls.MigrateLineBreaksToRowPlacement;

  Self.Clear;

  if not DataController.DataSetOk then
    Exit;

  if not zSystemOk then
    Exit;

  // MigrateLegacyColSpans non serve più: il layout si basa direttamente su Size.

  { TODO : Ricondure a zControl.AssignProps }

  zDbCardProps.Controls.ValidateDataset(DataController.zFbDataSet, false);

  for ctrlProps in zDbCardProps.Controls do
  begin

    if not DataController.TryGetField(ctrlProps.name, Field) then
      if ctrlProps.zCtrlType.IsDataAware then
        Continue; // campo non trovato

    item := Add;
    item.name := ctrlProps.name;
    item.DisplayLabel := ctrlProps.DisplayLabel;
    item.Lines := ctrlProps.Lines;
    item.NewLineBefore := ctrlProps.NewLineBefore;
    item.RowPlacement := ctrlProps.RowPlacement;
    item.ReadOnly := ctrlProps.ReadOnly;
    item.Required := ctrlProps.Required;
    item.Size := ctrlProps.Size;
    item.ColSpan := ctrlProps.ColSpan;
    item.Visible := ctrlProps.Visible;
    item.zCtrlType := ctrlProps.zCtrlType;
    item.Group := ctrlProps.Group;

    if item.zCtrlType.IsDataAware then
    begin
      Origin := DataController.GetFieldOrigin(Field);
      item.Domain := zSystem.zDataDictionary.Get(Origin, true);

      item.FieldReadOnly := Field.ReadOnly;
      item.FieldRequired := Field.Required;

      item.IdLookup := item.Domain.Lookup;

      if item.Size = -1 then
        item.Size := dx.FieldSize(Field);

      item.DomainDisplayLabel := item.Domain.DisplayLabel;

      // Gerarchia caption card:
      // 1. Override cliente (massima priorità)
      // 2. DisplayLabel personalizzato su TzControlProps
      // 3. Domain.DisplayLabel (default)
      item.DisplayLabel := Overrides.CaptionCard(Card.DataController.IdDataSet, ctrlProps.name);

      if item.DisplayLabel.IsEmpty then
      begin
        if ctrlProps.DisplayLabel <> '' then
          item.DisplayLabel := ctrlProps.DisplayLabel
        else
          item.DisplayLabel := item.Domain.DisplayLabel;
      end;

      if item.zCtrlType = ctDefault then
        item.zCtrlType := item.Domain.zCtrlType;
    end;
  end;

  CtrlsExists := Count > 0;

  // aggiungere in coda i field mancanti come nascosti
  for Field in DataController.Fields do
    if not Exists(Field.FieldName) then
    begin
      item := Add;
      item.name := Field.FieldName;

      Origin := DataController.GetFieldOrigin(Field);
      item.Domain := zSystem.zDataDictionary.Get(Origin, true);
      item.DisplayLabel := item.Domain.DisplayLabel;
      item.Required := item.Domain.Required;
      item.zCtrlType := item.Domain.zCtrlType;

      if item.zCtrlType.IsBlob then
        item.Lines := zDbCardProps.BlobLines;

      item.ReadOnly := Field.ReadOnly;
      item.FieldReadOnly := Field.ReadOnly;
      item.Required := Field.Required;
      item.FieldRequired := Field.Required;

      item.Size := item.Domain.GetCtrlSize;
      item.Visible := not CtrlsExists;

      if item.Size = dx.FieldSize(Field) then
        item.Size := -1;

      if item.DisplayLabel = item.Domain.DisplayLabel then
        item.DisplayLabel := '';

      if item.zCtrlType = item.Domain.zCtrlType then
        item.zCtrlType := ctDefault;
    end;

  /// ///////////////////////////////////////////
  CreateControls;

  if Assigned(Card) and Assigned(Card.dxLayoutControl) then
    BuildLayoutItems(zDbCardProps);
end;

procedure TzControls.MakeControlsVisible;
var
  item: TzControl;
begin
  for item in Self do
    if item.Visible then
      item.MakeVisible;
end;

procedure TzControls.MigrateLegacyColSpans(zDbCardProps: TzDbCardProps);
// Replica la logica di wrapping pixel-based del vecchio DisplayControls
// per calcolare quali campi finiscono sulla stessa riga "legacy",
// poi assegna ColSpan proporzionali alla larghezza relativa di ogni campo.
// Chiamata solo quando nessun TzControlProps ha ColSpan > 0.
const
  H_MARGIN = 20; // margine sinistro + destro scrollbox
  VSCROLLBAR_WIDTH = 20;
  H_SPACE = FONT_WIDTH; // HorizontalSpaceBetweenControls = FontWidth
var
  ctrlProps: TzControlProps;
  ColCount: integer;
  MaxWidth: integer; // larghezza utile in pixel (simulata da DlgWidth)

  // --- Calcola la larghezza pixel di un campo (stesso algoritmo legacy) ---
  function FieldPixelWidth(cp: TzControlProps): integer;
  var
    CtrlW, LblW: integer;
    LabelText: string;
  begin
    case cp.zCtrlType of
      ctLineBreak:
        begin
          result := 0;
          Exit;
        end;
      ctSeparator:
        begin
          result := MaxWidth;
          Exit;
        end;
      ctGroupBox, ctCheckGroupBox, ctButton:
        begin
          result := Min(Max(1, cp.Size) * FONT_WIDTH, MaxWidth);
          Exit;
        end;
    end;

    if cp.zCtrlType.IsDataAware then
    begin
      // Blob a tutta larghezza solo se Lines > 0 (multiline esplicito).
      // Con Lines = 0 il campo è un thumbnail/inline (es. ctImage piccola).
      if cp.zCtrlType.IsMultiLine and (cp.Lines > 0) then
      begin
        // I blob non contribuiscono alla larghezza di riga
        result := 0;
        Exit;
      end;
      CtrlW := Max(1, cp.Size) * FONT_WIDTH;
      // Label width: lunghezza testo label * font_width (approssimazione)
      LabelText := cp.DisplayLabel;
      LblW := (Length(LabelText) + 1) * FONT_WIDTH;
      result := Max(CtrlW, LblW);
    end
    else
      result := Max(1, cp.Size) * FONT_WIDTH;
  end;

// --- Dato un gruppo di campi sulla stessa riga, assegna i ColSpan ---
  procedure AssignColSpansForRow(Row: TList<TzControlProps>; RowTotalPx: integer);
  var
    i: integer;
    cp: TzControlProps;
    assigned_: integer;
    cs: integer;
    w: integer;
  begin
    if Row.Count = 0 then
      Exit;
    if RowTotalPx <= 0 then
    begin
      // Larghezza zero (es. riga con solo linebreak): assegna 1 a tutti
      for cp in Row do
        cp.ColSpan := 1;
      Exit;
    end;

    assigned_ := 0;
    for i := 0 to Row.Count - 2 do
    begin
      cp := Row[i];
      w := FieldPixelWidth(cp);
      cs := Max(1, Round(w / RowTotalPx * ColCount));
      // Non consumare tutte le colonne lasciandone zero agli ultimi
      cs := Min(cs, ColCount - assigned_ - (Row.Count - 1 - i));
      cs := Max(1, cs);
      cp.ColSpan := cs;
      Inc(assigned_, cs);
    end;
    // L'ultimo campo prende il residuo
    Row[Row.Count - 1].ColSpan := Max(1, ColCount - assigned_);
  end;

var
  CurrentRow: TList<TzControlProps>;
  CurrentRowPx: integer;
  CurrentX: integer;
  w: integer;
begin
  // Se c'è già un ColSpan esplicito su qualsiasi campo: non migrare
  for ctrlProps in zDbCardProps.Controls do
    if ctrlProps.ColSpan > 0 then
      Exit;

  ColCount := Max(1, zDbCardProps.ColCount);

  // Larghezza utile: DlgWidth salvato meno margini e scrollbar
  // Se DlgWidth non è stato salvato usiamo un default ragionevole
  MaxWidth := zDbCardProps.DlgWidth - H_MARGIN - VSCROLLBAR_WIDTH - H_SPACE;
  if MaxWidth <= 0 then
    MaxWidth := 900; // fallback

  CurrentRow := TList<TzControlProps>.Create;
  try
    CurrentX := 0;
    CurrentRowPx := 0;

    for ctrlProps in zDbCardProps.Controls do
    begin
      // Campi non visibili: saltati (non partecipavano al layout)
      if not ctrlProps.Visible then
        Continue;

      // Campi in un Group: saltati (venivano posizionati dentro il GroupBox)
      if not ctrlProps.Group.IsEmpty then
        Continue;

      w := FieldPixelWidth(ctrlProps);

      // LineBreak: forza a capo
      if ctrlProps.zCtrlType = ctLineBreak then
      begin
        AssignColSpansForRow(CurrentRow, CurrentRowPx);
        CurrentRow.Clear;
        CurrentX := 0;
        CurrentRowPx := 0;
        Continue;
      end;

      // Separator: flush + riga intera per il separatore stesso
      if ctrlProps.zCtrlType = ctSeparator then
      begin
        AssignColSpansForRow(CurrentRow, CurrentRowPx);
        CurrentRow.Clear;
        CurrentX := 0;
        CurrentRowPx := 0;
        // Il separatore non ha ColSpan (è gestito come ctSeparator in BuildLayoutItems)
        Continue;
      end;

      // Campi multiline (blob) con Lines > 0: vanno a capo automaticamente,
      // occupano tutta la larghezza come nel vecchio sistema.
      // Con Lines = 0 sono inline (es. ctImage thumbnail).
      // ctGroupBox/ctCheckGroupBox hanno Lines > 0 (altezza del box) ma non sono blob.
      if ctrlProps.zCtrlType.IsMultiLine and (ctrlProps.Lines > 0) and not(ctrlProps.zCtrlType in [ctGroupBox, ctCheckGroupBox]) then
      begin
        AssignColSpansForRow(CurrentRow, CurrentRowPx);
        CurrentRow.Clear;
        CurrentX := 0;
        CurrentRowPx := 0;
        // Il campo multiline occupa tutta la riga
        ctrlProps.ColSpan := ColCount;
        Continue;
      end;

      // Verifica overflow: stesso test del vecchio DisplayControls
      // (CurrentPos.X + item.Width) > MaxWidth
      if (CurrentX > 0) and (CurrentX + w > MaxWidth) then
      begin
        AssignColSpansForRow(CurrentRow, CurrentRowPx);
        CurrentRow.Clear;
        CurrentX := 0;
        CurrentRowPx := 0;
      end;

      // Aggiunge il campo alla riga corrente
      CurrentRow.Add(ctrlProps);
      if CurrentX = 0 then
        CurrentX := w
      else
      begin
        Inc(CurrentX, H_SPACE + w);
        Inc(CurrentRowPx, H_SPACE);
      end;
      Inc(CurrentRowPx, w);
    end;

    // Flush dell'ultima riga
    AssignColSpansForRow(CurrentRow, CurrentRowPx);

  finally
    FreeAndNil(CurrentRow);
  end;

  // =================================================================
  // SECONDA FASE: migra i campi raggruppati (Group non vuoto).
  // Nel vecchio sistema, i campi dentro un TcxGroupBox si disponevano
  // con la stessa logica di wrapping ma dentro la larghezza del gruppo.
  // =================================================================
  MigrateLegacyGroupedColSpans(zDbCardProps, ColCount, MaxWidth);
end;

procedure TzControls.MigrateLegacyGroupedColSpans(zDbCardProps: TzDbCardProps; ColCount, OuterMaxWidth: integer);
// Calcola i ColSpan per i campi che appartengono a un gruppo,
// usando come MaxWidth la larghezza pixel del gruppo (dal Size del ctGroupBox).
const
  FONT_WIDTH = 7;
  H_SPACE = FONT_WIDTH;
  GRP_BORDER_MARGIN = 20; // margine interno bordo GroupBox
var
  GroupNames: TList<string>;
  GroupName: string;
  grpCtrl: TzControlProps;
  ctrlProps: TzControlProps;
  GrpMaxWidth: integer;

  function GroupFieldPixelWidth(cp: TzControlProps): integer;
  var
    CtrlW, LblW: integer;
    LabelText: string;
  begin
    case cp.zCtrlType of
      ctLineBreak:
        begin
          result := 0;
          Exit;
        end;
    end;

    if cp.zCtrlType.IsDataAware then
    begin

      if cp.zCtrlType.IsMultiLine and (cp.Lines > 0) then
      begin
        result := 0;
        Exit;
      end;
      CtrlW := Max(1, cp.Size) * FONT_WIDTH;
      LabelText := cp.DisplayLabel;
      LblW := (Length(LabelText) + 1) * FONT_WIDTH;
      result := Max(CtrlW, LblW);
    end
    else
      result := Max(1, cp.Size) * FONT_WIDTH;
  end;

  procedure AssignColSpansForRow(Row: TList<TzControlProps>; RowTotalPx: integer);
  var
    i: integer;
    cp: TzControlProps;
    assigned_: integer;
    cs: integer;
    w: integer;
  begin
    if Row.Count = 0 then
      Exit;
    if RowTotalPx <= 0 then
    begin
      for cp in Row do
        cp.ColSpan := 1;
      Exit;
    end;

    assigned_ := 0;
    for i := 0 to Row.Count - 2 do
    begin
      cp := Row[i];
      w := GroupFieldPixelWidth(cp);
      cs := Max(1, Round(w / RowTotalPx * ColCount));
      cs := Min(cs, ColCount - assigned_ - (Row.Count - 1 - i));
      cs := Max(1, cs);
      cp.ColSpan := cs;
      Inc(assigned_, cs);
    end;
    Row[Row.Count - 1].ColSpan := Max(1, ColCount - assigned_);
  end;

var
  CurrentRow: TList<TzControlProps>;
  CurrentRowPx: integer;
  CurrentX: integer;
  w: integer;
begin
  // Raccogli i nomi dei gruppi unici
  GroupNames := TList<string>.Create;
  try
    for ctrlProps in zDbCardProps.Controls do
      if (ctrlProps.zCtrlType in [ctGroupBox, ctCheckGroupBox]) and ctrlProps.Visible then
        GroupNames.Add(ctrlProps.name);

    CurrentRow := TList<TzControlProps>.Create;
    try
      for GroupName in GroupNames do
      begin
        // Trova il TzControlProps del gruppo per ricavarne il Size
        grpCtrl := zDbCardProps.Controls.Find(
          function(cp: TzControlProps): boolean
          begin
            result := SameText(cp.name, GroupName);
          end);

        if Assigned(grpCtrl) then
        begin
          // Se il gruppo è "quasi" a tutta larghezza (>= 90% della form)
          // la larghezza interna è basata su OuterMaxWidth, non su Size.
          // Nel vecchio sistema i groupbox a tutta larghezza si espandevano alla form.
          if Max(1, grpCtrl.Size) * FONT_WIDTH >= (OuterMaxWidth * 9 div 10) then
            GrpMaxWidth := OuterMaxWidth - GRP_BORDER_MARGIN
          else
            GrpMaxWidth := Max(1, grpCtrl.Size) * FONT_WIDTH - GRP_BORDER_MARGIN;
        end
        else
          GrpMaxWidth := OuterMaxWidth - GRP_BORDER_MARGIN;
        if GrpMaxWidth <= 0 then
          GrpMaxWidth := OuterMaxWidth - GRP_BORDER_MARGIN;

        CurrentRow.Clear;
        CurrentX := 0;
        CurrentRowPx := 0;

        for ctrlProps in zDbCardProps.Controls do
        begin
          if not SameText(ctrlProps.Group, GroupName) then
            Continue;
          if not ctrlProps.Visible then
            Continue;
          // Salta se ha già un ColSpan (non dovrebbe succedere, ma per sicurezza)
          if ctrlProps.ColSpan > 0 then
            Continue;

          w := GroupFieldPixelWidth(ctrlProps);

          if ctrlProps.zCtrlType = ctLineBreak then
          begin
            AssignColSpansForRow(CurrentRow, CurrentRowPx);
            CurrentRow.Clear;
            CurrentX := 0;
            CurrentRowPx := 0;
            Continue;
          end;

          if ctrlProps.zCtrlType.IsMultiLine and (ctrlProps.Lines > 0) and not(ctrlProps.zCtrlType in [ctGroupBox, ctCheckGroupBox]) then
          begin
            AssignColSpansForRow(CurrentRow, CurrentRowPx);
            CurrentRow.Clear;
            CurrentX := 0;
            CurrentRowPx := 0;
            ctrlProps.ColSpan := ColCount;
            Continue;
          end;

          if (CurrentX > 0) and (CurrentX + w > GrpMaxWidth) then
          begin
            AssignColSpansForRow(CurrentRow, CurrentRowPx);
            CurrentRow.Clear;
            CurrentX := 0;
            CurrentRowPx := 0;
          end;

          CurrentRow.Add(ctrlProps);
          if CurrentX = 0 then
            CurrentX := w
          else
          begin
            Inc(CurrentX, H_SPACE + w);
            Inc(CurrentRowPx, H_SPACE);
          end;
          Inc(CurrentRowPx, w);
        end;

        // Flush ultima riga del gruppo
        AssignColSpansForRow(CurrentRow, CurrentRowPx);
      end;
    finally
      FreeAndNil(CurrentRow);
    end;
  finally
    FreeAndNil(GroupNames);
  end;
end;

function TzControls.PopupCtrlIsClass(zCtrlType: TzCtrlType): boolean;
var
  item: TzControl;
begin
  result := false;

  item := Find(PopupCtrl);

  if Assigned(item) then
    result := item.zCtrlType = zCtrlType;
end;

function TzControls.PopupCtrlItem: TzControl;
begin
  result := Find(PopupCtrl);
end;

procedure TzControls.SaveToProps(zDbCardProps: TzDbCardProps);
var
  ctrlProps: TzControlProps;
  item: TzControl;
begin
  zDbCardProps.Controls.Clear;

  for item in Self do
  begin
    ctrlProps := zDbCardProps.Controls.Add;

    ctrlProps.name := item.name;

    // Salva DisplayLabel solo se non è gestita da un override (che prevale a runtime)
    // e solo se è diversa dal domain (altrimenti il default è sufficiente)
    if not Overrides.OverrideExists(Card.DataController.IdDataSet, item.name, [ofCaptionCard]) then
      if not SameText(item.DisplayLabel, item.DomainDisplayLabel) then
        ctrlProps.DisplayLabel := item.DisplayLabel;

    ctrlProps.Group := item.Group;
    ctrlProps.Lines := item.Lines;
    ctrlProps.ReadOnly := item.ReadOnly;
    ctrlProps.Required := item.Required;
    ctrlProps.Size := item.Size;
    ctrlProps.ColSpan := item.ColSpan;
    ctrlProps.zCtrlType := item.zCtrlType;

    ctrlProps.Visible := item.Visible;

    if FieldsHiddenByCode.Contains(item.name) then
      ctrlProps.Visible := false;
  end;
end;

procedure TzControls.SetControlFont(const Value: TFont);
begin
  FControlFont.Assign(Value);
end;

procedure TzControls.SetzSystem(

  const Value: TzSystem);
begin
  FzSystem := Value;

  if zSystemOk then
  begin

    if not Assigned(ReadTrans.Connection) then
      ReadTrans.Connection := zSystem.zFbDatabase;

    if not Assigned(WriteTrans.Connection) then
      WriteTrans.Connection := zSystem.zFbDatabase;
  end;
end;

function TzControls.UniqueName(

  const name: string): string;
var
  i: integer;
begin
  result := Name + '_1';

  i := 1;
  while Assigned(Find(result)) do
  begin
    Inc(i);
    result := Name + '_' + i.ToString;
  end;
end;

function TzControls.zSystemOk: boolean;
begin
  result := Assigned(FzSystem);
end;

function TzDbCard.GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
begin
  result := ctCard;
end;

function TzDbCard.GetToolbar: TdxBar; // IzBaseComponent.GetToolbar — barra unica filtri+azioni
begin
  result := dxBarToolbarFree;
end;

function TzDbCard.GetID: string; // IzBaseComponent.GetID
begin
  result := CardID;
end;

procedure TzDbCard.SetID(const Value: string); // IzBaseComponent.SetID
begin
  SetCardID(Value);
end;

function TzDbCard.GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
begin
  result := FToolActions;
end;

function TzDbCard.GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
begin
  result := FzDataSet;
end;

constructor TzDbCard.Create(aOwner: TComponent);
var
  cmd: TzDbCardCommand;
  items: TStrings;
  zCtrlType: TzCtrlType;
begin
  inherited;

  for cmd := Low(TzDbCardCommand) to High(TzDbCardCommand) do
    PostedCommands[cmd] := false;

  for cmd := Low(TzDbCardCommand) to High(TzDbCardCommand) do
  begin
    DeferredCommands[cmd] := false;
    DeferredParams[cmd] := 0;
  end;

  IsCreatingControls := false;
  PendingVerifyLookupsParams := false;
  InsideVerifyLookupsParams := false;
  FLayoutEditorClosing := false;
  FrameDescription := nil;
  FLookupsEnabled := true;
  Inserting := false;
  isResizing := false;
  FIsDestroying := false;
  disableResize := false;
  FSaveThreadRunning := false;
  FSaveQueued := false;
  FDlgSizeIs96dpi := true; // i props caricati da base sono in unità 96-dpi
  FSaveTask := nil;
  FAliveGuard := TzCardAliveGuard.Create;
  FUpdatingCheckBoxes := false;
  FLastBuildRowMax := 0;
  FInReflow := false;
  FPendingMaintenanceOp := lmoNone;
  if Assigned(dxLayoutControl) then
    TzLayoutMaintenanceRegistry.RegisterHandler(dxLayoutControl, Self);

  FReadOnly := crUseLoadedProps;
  FRestrictionReadOnly := false;

  FOnCustomSaveProps := nil;
  FOnCustomLoadProps := nil;

  FOnDataSetDelete := nil;
  FOnDataSetEdit := nil;
  FOnDataSetInsert := nil;
  FDisableDelete := false;
  FDisableEdit := false;
  FDisableInsert := false;

  FOnBeforeCreateControls := nil;
  FOnAfterCreateControls := nil;
  FOnBeforeCreateControl := nil;
  FOnAfterCreateControl := nil;
  FOnBeforeCreateDbControl := nil;
  FOnAfterCreateDbControl := nil;

  FieldRebuildData.Clear;

  Titolo.Visible := false;
  dxBarControlContainerTitolo.Visible := dx.Visible(false);

  actDbFirst.DataSource := DataSource;
  actDbPrior.DataSource := DataSource;
  actDbNext.DataSource := DataSource;
  actDbLast.DataSource := DataSource;

  FzDbCardProps := TzDbCardProps.Create(nil);
  FDataController := TzDataController.Create(Self);
  FzControls := TzControls.Create;
  zControls.Sorted := false;
  zControls.Card := Self;

  zControls.ControlFont := dxLayoutControl.Font;

  zControls.DataController := DataController;
  zControls.DataSource := DataSource;
  zControls.PopupMenu := popEdit;

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;

  TcxComboBoxProperties(cxBarItemCtrlType.Properties).DropDownRows := Ord(High(TzCtrlType));
  items := TcxComboBoxProperties(cxBarItemCtrlType.Properties).items;
  items.Clear;

  for zCtrlType := Low(TzCtrlType) to High(TzCtrlType) do
    items.Add(TEnum<TzCtrlType>.EnumToString(zCtrlType));

  dxBarToolbar.MultiLine := true; // collegato a resize
  dxBarToolbarFree.MultiLine := true; // collegato a resize

  DisplayToolbars;

  dx.InitTitle(Titolo);
  dx.InitLayoutControl(dxLayoutControl);
end;

destructor TzDbCard.Destroy;
begin
  SiDbCard.EnterMethod(Self, 'Destroy');

  TThread.RemoveQueuedEvents(ExecutePendingMaintenance);
  if Assigned(dxLayoutControl) then
    TzLayoutMaintenanceRegistry.UnregisterHandler(dxLayoutControl);

  // Attende un salvataggio in volo PRIMA di liberare zDbCardProps (il task
  // serializza proprio quei props). Timeout difensivo: in caso di blocco
  // del DB meglio un leak che un deadlock alla chiusura.
  if Assigned(FSaveTask) then
  begin
    try
      FSaveTask.Wait(10000);
    except
      // eccezione nel task o timeout: prosegue comunque
    end;
    FSaveTask := nil;
    FSaveThreadRunning := false;
  end;

  // Da qui le closure asincrone residue (TThread.Queue) non toccano più Self
  FAliveGuard.Alive := false;

  // Flush SINCRONO di un salvataggio non ancora processato: il messaggio
  // cmd_SaveProperties andrebbe perso e zDbCardProps sta per essere liberato,
  // quindi niente task qui. Considera anche DeferredCommands (save richiesto
  // a card nascosta o trasferito da DestroyWnd) e FSaveQueued (modifiche
  // arrivate mentre il task appena atteso era in volo).
  if PostedCommands[cmd_SaveProperties] or DeferredCommands[cmd_SaveProperties] or FSaveQueued then
  begin
    FSaveQueued := false;
    DescaleDlgSizeForSave;
    InternalSaveProperties;
  end;

  FIsDestroying := true;
  FreeAndNil(FrameDescription);
  FreeAndNil(FToolActions);
  FreeAndNil(FzDbCardProps);
  FreeAndNil(FzControls);
  FreeAndNil(FDataController);

  inherited;

  SiDbCard.LeaveMethod(Self, 'Destroy');
end;

procedure TzDbCard.DestroyCustomControls;
begin
  SiDbCard.EnterMethod(Self, 'DestroyCustomControls');

  // Sgancia i TdxLayoutItem prima di distruggere i controlli ospitati.
  // ClearLayoutItems imposta Control := nil su ogni item generato dal controller,
  // impedendo che TdxLayoutItem distrugga il TcxCustomEdit.
  if not FIsDestroying then
    ClearLayoutItems;

  zControls.DestroyControls;

  SiDbCard.LeaveMethod(Self, 'DestroyCustomControls');
end;

procedure TzDbCard.CreateWnd;
begin
  inherited;
  if Assigned(zControls) and (zControls.Count > 0) then
    PostInternalMessage(cmd_Resize);
end;

procedure TzDbCard.DestroyWnd;
var
  cmd: TzDbCardCommand;
begin
  // I messaggi già accodati sull'HWND distrutto vanno persi: trasferisce i
  // latch pendenti su DeferredCommands (rilancio in CMShowingChanged) invece
  // di scartarli — altrimenti un cmd_SaveProperties o cmd_LoadProperties
  // postato poco prima di un RecreateWnd sparirebbe in silenzio.
  // DeferredParams[cmd] contiene già l'ultimo lparam postato (vedi
  // PostInternalMessage).
  for cmd := Low(TzDbCardCommand) to High(TzDbCardCommand) do
    if PostedCommands[cmd] then
    begin
      PostedCommands[cmd] := false;
      DeferredCommands[cmd] := true;
    end;
  inherited;
end;

procedure TzDbCard.SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
begin
  if FzDataSet = Value then
    Exit;

  if Assigned(FzDataSet) then
    FzDataSet.RemoveFreeNotification(Self);

  FzDataSet := Value;

  if Assigned(FzDataSet) then
    FzDataSet.FreeNotification(Self);

  /// //////////////////////////////////////

  DataSource.DataSet := Value;
  DataController.DataSet := Value;
  zControls.DataSet := Value;
  zDbCardProps.DataSet := DataController.IdDataSet;
  InitCard;

  if Assigned(FzDataSet) then
    if FzDataSet.State = dsInsert then
      ClearInvalidDefaultValues;
end;

procedure TzDbCard.SetzDbCardProps(

  const Value: TzDbCardProps);
begin
  FzDbCardProps := Value;
end;

procedure TzDbCard.SetzSystem(

  const Value: TzSystem);
begin

  if Assigned(FzSystem) then // sgancia preesistente
    FzSystem.RemoveFreeNotification(Self);

  FzSystem := Value;

  if Assigned(FzSystem) then // aggancia quello nuovo
    FzSystem.FreeNotification(Self);

  /// //////////////////////////////////////

  zControls.zSystem := Value;
  InitCard;
end;

function TzDbCard.zSystemOk: boolean;
begin
  result := Assigned(FzSystem);
end;

procedure TzDbCard.InitCard;
begin
  if not zSystemOk then
    Exit;

  if not DataController.DataSetOk then
    Exit;

  if zControls.Count = 0 then
  begin
    LoadProperties(true); // chiama gia' RebuildToolbar internamente
    Localizer.Translate(Self);
  end;
end;

procedure TzDbCard.actDbCancelExecute(Sender: TObject);
begin
  Cancel;
end;

procedure TzDbCard.actDbPostUpdate(Sender: TObject);
begin
  ActionVisible(actDbPost, DataController.CanPost and zDbCardProps.Flags.ButtonOkCancel);
end;

procedure TzDbCard.actDbCancelUpdate(Sender: TObject);
begin
  ActionVisible(actDbCancel, DataController.CanCancel and zDbCardProps.Flags.ButtonOkCancel);
end;

procedure TzDbCard.actDbRefreshUpdate(Sender: TObject);
begin
  ActionVisible(actDbRefresh, DataController.CanRefresh and zDbCardProps.Flags.ButtonRefresh);
end;

procedure TzDbCard.actDbDeleteExecute(Sender: TObject);
begin
  dbDelete;
end;

procedure TzDbCard.actDbEditExecute(Sender: TObject);
begin
  dbEdit;
end;

procedure TzDbCard.actDbInsertExecute(Sender: TObject);
begin
  dbInsert;
end;

procedure TzDbCard.actDbPostExecute(Sender: TObject);
begin
  Post;
end;

procedure TzDbCard.actDbRefreshExecute(Sender: TObject);
begin
  DataController.Refresh;
end;

procedure TzDbCard.actEditorImageUpdate(Sender: TObject);
begin
  ActionVisible(Sender as TCustomAction, zControls.PopupCtrlIsClass(ctImage));
end;

procedure TzDbCard.MostraQueryLookupExecute(Sender: TObject);
var
  i: integer;
  item: TzControl;
  Param: TFDParam;
  s: string;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  if not Assigned(item.lkDataSet) then
  begin
    ConfirmOk('Dataset di lookup non assegnato.');
    Exit;
  end;

  s := item.lkDataSet.GetDebugInfo;
  zExecuteMemoDialog(s, item.name);
end;

procedure TzDbCard.actPersonalizzaCampoExecute(Sender: TObject);
var
  zControl: TzControl;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
begin
  zControl := zControls.PopupCtrlItem;

  if not Assigned(zControl) then
    Exit;

  if not DataController.TryGetField(zControl.name, Field) then
    Exit;

  Origin := DataController.GetFieldOrigin(Field);
  Domain := zSystem.zDataDictionary.Get(Origin, false);

  if not Assigned(Domain) then
    Exit;

  if Domain.Inspect then
  begin
    StartWait('Attendere...', true);
    try
      Domain.SaveToBase(true);
    finally
      StopWait;
    end;

    // Era: PostInternalMessage(cmd_LoadProperties, integer(false));

    FieldRebuildData.Clear;
    FieldRebuildData.zControl := zControl;
    FieldRebuildData.Domain := Domain;
    PostInternalMessage(cmd_RebuildSingleControl);
  end;
end;

procedure TzDbCard.actPersonalizzaCampoUpdate(Sender: TObject);
begin
  ActionVisible(actPersonalizzaCampo, IsAdmin);
end;

procedure TzDbCard.PersonalizzaCard;
var
  i: integer;
  idx: integer;
  item: TzDbCardProps;
begin
  if zDbCardProps.DataSet = '' then
    zDbCardProps.DataSet := GetID_DataSet;

  LoadCardFormSize;

  zControls.SaveToProps(zDbCardProps);
  //
  if Edit_CollectionItem(zSystem, zDbCardProps, PersonalizzaCardApply) then
  begin

    StartWait('Attendere...', true);
    try
      InternalSaveProperties;
      LoadProperties;
    finally
      StopWait;
    end;
  end;
end;

procedure TzDbCard.PersonalizzaCardApply(Sender: TObject);
begin
  SaveCardFormSize; // assegna la larghezza
  InternalSaveProperties;
  LoadProperties;
end;

procedure TzDbCard.actPersonalizzaExecute(Sender: TObject);
begin
  PostInternalMessage(cmd_PersonalizzaCard);
end;

procedure TzDbCard.actResetSelectedExecute(Sender: TObject);
begin
  // implementare
  // bah...
  // if Message Dlg('Azzerare posizione e visibilità dei campi?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  // ResetSelected;
end;

procedure TzDbCard.actSelectedExecute(Sender: TObject);
var
  s: String;
begin
  s := zDbCardProps.Controls.AsText;
  zExecuteMemoDialog(s, 'Controls: ' + GetCardID);
end;

procedure TzDbCard.actSQLExecute(Sender: TObject);
begin
  if not DataController.DataSetOk then
    Exit;

  /// //////////////
  if zSystem.DataSetEditProps(zDataSet) then
  begin
    // if DataController.IsActive then // se chiuso per sql errato d? errore
    DestroyCustomControls;

    DataController.OpenDataSet;
    // zDataSet := zDataSet; // riassegnazione delle prop
    InitCard;
  end;
end;

procedure TzDbCard.RefreshDisplay;
begin
  SiDbCard.EnterMethod(Self, 'RefreshDisplay');

  RefreshVisibility;

  SiDbCard.LeaveMethod(Self, 'RefreshDisplay');
end;

procedure TzDbCard.CaricaImpostazioniExecute(Sender: TObject);
begin

  if ConfirmOkCancel('Ripristino le impostazioni di default?') then
    ReloadFromProps(true);
end;

procedure TzDbCard.ClearDependentFields(Field: TField);
var
  Domain: TzDomain;
  FieldName: string;
  Origin: string;
  Str: TStringList;
  zControl: TzControl;
begin
  simain.EnterMethod(Self, 'ClearDependentFields');

  if not Assigned(Field) then
    Exit;

  if not Assigned(zSystem) then
    Exit;

  simain.LogString(Name, Field.FieldName);

  Origin := DataController.GetFieldOrigin(Field);
  Domain := zSystem.zDataDictionary.Get(Origin, false);

  if not Assigned(Domain) then
    Exit;

  if Domain.FieldsToClear <> '' then
  begin
    DataController.ClearFields(Domain.FieldsToClear);

    // se il campo master è impostato a null deve resettare i lookup dipendenti
    Str := TStringList.Create;
    try
      Str.Delimiter := ';';
      Str.DelimitedText := Domain.FieldsToClear;

      for FieldName in Str do
      begin
        zControl := zControls.Find(FieldName);

        if Assigned(zControl) then
          if Assigned(zControl.lkDataSet) then
            // 10.11.2022 i combo non chiamano più DataSet.Locate
            if false then
              zControl.lkDataSet.RevertSQL(true); // Vedi commento 10.11.2022
      end;
    finally
      FreeAndNil(Str);
    end;
  end;
  simain.LeaveMethod(Self, 'ClearDependentFields');
end;

procedure TzDbCard.CopiaControlliExecute(Sender: TObject);
var
  Domain: TzDomain;
  Field: TField;
  Origin: string;
  StringList: TStringList;
  s: string;
begin
  StringList := TStringList.Create;
  try

    for Field in DataController.Fields do
    begin
      Origin := DataController.GetFieldOrigin(Field);
      Domain := zSystem.zDataDictionary.Get(Origin, false);

      if not Assigned(Domain) then
        Continue;

      s := Field.FieldName + ';' + TRttiEnumerationType.GetName(Domain.zCtrlType) + ';' + Domain.Lookup + ';' + Domain.PickList;
      StringList.Add(s);
    end;

    Clipboard.AsText := StringList.Text;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzDbCard.CopiaImpostazioniExecute(Sender: TObject);
begin
  LoadCardFormSize;
  Clipboard.AsText := zDbCardProps.AsDFM;
end;

procedure TzDbCard.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if DataController.DataSetOk then
  begin
    Clipboard.AsText := DataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbCard.CopiaSelectedExecute(Sender: TObject);
begin
  Clipboard.AsText := zDbCardProps.Controls.AsText;
end;

procedure TzDbCard.CopyNameExecute(Sender: TObject);
begin
  Clipboard.AsText := CardID;
  ConfirmOk(CardID);
end;

procedure TzDbCard.cxBarEditItem1PropertiesChange(Sender: TObject);
begin
  PostInternalMessage(cmd_ReadOnlyPropertiesChange);
end;

procedure TzDbCard.cxBarItemModifyFlagsPropertiesChange(Sender: TObject);
begin
  PostInternalMessage(cmd_FlagsPropertiesChange);
end;

procedure TzDbCard.cxBarItemCtrlTypePropertiesChange(Sender: TObject);
begin
  PostInternalMessage(cmd_CtrlTypePropertiesChange);
end;

procedure TzDbCard.dbDelete;
begin
  if Assigned(FOnDataSetDelete) then
    OnDataSetDelete(Self)
  else
    if DataController.DataSetOk then
      if (DataController.CanDelete and zDbCardProps.Flags.ButtonDelete and not DisableDelete) then
        if ConfirmYesNo('Elimino il record?') then
          DataController.Delete;
end;

procedure TzDbCard.dbEdit;
begin
  if Assigned(FOnDataSetEdit) then
    OnDataSetEdit(Self)
  else
    if (DataController.CanEdit and zDbCardProps.Flags.ButtonUpdate and not DisableEdit) then
      DataController.CheckEditMode;
end;

procedure TzDbCard.dbInsert;
begin

  Inserting := true; // disabilita parte di DataSourceDataChange
  try

    if Assigned(FOnDataSetInsert) then
      OnDataSetInsert(Self)
    else
      if (DataController.CanInsert and zDbCardProps.Flags.ButtonInsert and not DisableInsert) then
        DataController.Insert;
  finally
    Inserting := false;
  end;
end;

procedure TzDbCard.ClearInvalidDefaultValues;
var
  item: TzControl;
  Field: TField;
begin
  for item in zControls do
    if item.Visible then
      if not item.ReadOnly then
        if item.IsLookup then
        begin
          Field := item.GetField;

          if Assigned(Field) then
            if not Field.isNull then
              if Field.DataType in [ftInteger, ftLargeint, ftSmallint, ftShortint, ftAutoInc, ftWord, ftLongWord] then
                if Field.AsInteger = -1 then
                begin
                  try
                    Field.Clear;
                    item.ForceValidation;
                  except
                  end;
                end;
        end;
end;

procedure TzDbCard.DeletePictureExecute(Sender: TObject);

var
  item: TzControl;
  Field: TField;
begin
  item := zControls.PopupCtrlItem;

  if Assigned(item) then
    if DataController.TryGetField(item.name, Field) then
    begin
      DataController.CheckEditMode;
      Field.Clear;
    end;
end;

procedure TzDbCard.DisplayToolbars;
begin
  dxBarManager.BeginUpdate;
  try
    // ordine inverso di visualizzazione
    dxBarToolbarFree.Visible := (ToolActions.Count > 0) or TzToolFilterHelper.HasFilterItems(dxBarManager);
    dxBarToolbar.Visible := zDbCardProps.Flags.Toolbar;
    dxBarToolbar.UseRestSpace := ToolActions.Count = 0;

    if not zDbCardProps.Flags.Toolbar then
      Titolo.Visible := false;
  finally
    dxBarManager.EndUpdate;
  end;
end;

procedure TzDbCard.dxBarEditCtrlCaptionChange(Sender: TObject);
var
  item: TzControl;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  item.DisplayLabel := dxBarEditCtrlCaption.EditValue;

  // Allinea il layout salvato, altrimenti SaveToLayout ripristinerebbe la
  // vecchia caption al prossimo rebuild.
  UpdateSavedLayoutCaption(item.name, item.DisplayLabel);

  SaveProperties;
  RefreshVisibility;
end;

procedure TzDbCard.dxBarEditTitoloChange(Sender: TObject);
begin
  zDbCardProps.Title := dxBarEditTitolo.EditValue;
  SaveProperties;
  SetTitle(dxBarEditTitolo.EditValue);
end;

procedure TzDbCard.dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
begin
  if Assigned(zSystem) then
    if zSystem.IsAdmin then
      popCard.PopupFromCursorPos;
end;

procedure TzDbCard.dxBarSpinEditCtrlSizePropertiesEditValueChanged(Sender: TObject);
var
  item: TzControl;
  NewSize: integer;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  NewSize := dxBarSpinEditCtrlSize.CurEditValue;
  item.Size := NewSize;

  AdjustRowForColSpan(item);

  // RebuildLayout PRIMA di SaveProperties: SaveProperties riconverte
  // DlgWidth in unità 96-dpi (ScaleToSmallFont), quindi a DPI > 100%
  // un RowMaxSize calcolato dopo risulterebbe sottostimato.
  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

function TzDbCard.GetCardID: string;
begin
  if zDbCardProps.name = '' then
    zDbCardProps.name := GetID_DataSet;

  result := zDbCardProps.name;
end;

function TzDbCard.GetID_DataSet: string;
begin
  result := DataController.IdDataSet;
end;

function TzDbCard.GetTitle: string;
begin
  result := Titolo.Caption;

  if result.IsEmpty then
  begin
    result := zDbCardProps.Title;

    if result.IsEmpty then
    begin
      result := name;

      if result.StartsWith('card') then
        result := result.Replace('card', '', [rfIgnoreCase]);
    end;
  end;
end;

procedure TzDbCard.IncollaControlliExecute(Sender: TObject);
var
  StringList: TStringList;
  dom: TStringList;
  FieldName: string;
  s: string;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
begin
  StringList := TStringList.Create;
  try
    StringList.Text := Clipboard.AsText;

    dom := TStringList.Create;
    try
      dom.Delimiter := ';';
      dom.StrictDelimiter := true;

      for s in StringList do
      begin
        dom.DelimitedText := s;

        FieldName := dom[0];

        Field := DataController.GetField(FieldName);
        if not Assigned(Field) then
          Continue;

        Origin := DataController.GetFieldOrigin(Field);
        Domain := zSystem.zDataDictionary.Get(Origin, false);
        if not Assigned(Domain) then
          Continue;

        Domain.zCtrlType := TRttiEnumerationType.GetValue<TzCtrlType>(dom[1]);
        Domain.Lookup := dom[2];
        Domain.PickList := dom[3];
      end;

    finally
      FreeAndNil(dom);
    end;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzDbCard.IncollaImpostazioniExecute(Sender: TObject);
var
  id, name: string;
  oldTitle, OldCaption: String;
begin
  Screen.Cursor := crHourGlass;
  try
    id := CardID;
    name := zDbCardProps.name;
    // preserva caption/title
    oldTitle := zDbCardProps.Title;
    OldCaption := zDbCardProps.Caption;

    zDbCardProps.AsDFM := Clipboard.AsText;
    zDbCardProps.Layout.Clear;
    zDbCardProps.name := name;
    zDbCardProps.DataSet := GetID_DataSet;
    zDbCardProps.Title := oldTitle;
    zDbCardProps.Caption := OldCaption;

    ReloadFromProps(false);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TzDbCard.IncollaSelectedExecute(Sender: TObject);
begin
  zDbCardProps.Controls.AsText := Clipboard.AsText;
  zDbCardProps.Controls.ValidateDataset(zDataSet, true);
  PostInternalMessage(cmd_RebuildControls);
end;

procedure TzDbCard.InitToolActions;
begin
  disableResize := true;
  try
    TzActionBuilder.BuildFromProps(zDbCardProps.ToolActions, ToolActions, GetActionOwner);
    ToolActions.CreateButtons(dxBarToolbarFree, popCard, otCard);
  finally
    disableResize := false;
  end;
end;

function TzDbCard.GetToolFilters: TzToolFiltersProps; // IzBaseFilterableComponent.GetToolFilters
begin
  // Una sola verita': la property e' alias dei props persistiti (come su View).
  result := zDbCardProps.ToolFilters;
end;

procedure TzDbCard.SetToolFilters(const Value: TzToolFiltersProps); // IzBaseFilterableComponent.SetToolFilters
begin
  zDbCardProps.ToolFilters.Assign(Value);
end;

procedure TzDbCard.CreateFiltersFromProps;
var
  FilterProps: TzToolFilterProps;
  Bar: TdxBar;
begin
  if not DataController.DataSetOk then
    Exit;

  Bar := GetToolbar;
  if not Assigned(Bar) then
    Exit;

  // I TcxBarEditItem dei filtri sono linkati direttamente alla dxBar; la presenza
  // si gestisce distruggendo e ricreando gli item (prefisso toolFilter__), non con
  // un container. Il bar manager si ricava dalla barra. Pulizia prima di ricostruire.
  TzToolFilterHelper.ClearFilterItems(Bar.BarManager);

  // Unica sorgente: i filtri persistiti (zDbCardProps.ToolFilters).
  for FilterProps in zDbCardProps.ToolFilters do
    TzToolFilterRegistry.ApplyFilter(FilterProps, Self, DataController.zFbDataSet);
end;

procedure TzDbCard.RebuildToolbar; // IzBaseComponent.RebuildToolbar — filtri poi azioni
begin
  // Ordine: prima i filtri, poi le azioni, così i filtri precedono le azioni
  // sulla stessa barra (GetToolbar). CreateButtons appende (Position=-1).
  CreateFiltersFromProps;
  InitToolActions;
end;

procedure TzDbCard.RebuildFilters; // IzBaseFilterableComponent.RebuildFilters
begin
  RebuildToolbar;
  InternalSaveProperties; // persiste su LZ
end;

function TzDbCard.IsAdmin: boolean;
begin
  result := false;
  if Assigned(zSystem) then
    result := zSystem.IsAdmin;
end;

function TzDbCard.IsCardReadOnly: boolean;
begin
  case ReadOnly of
    crUseLoadedProps:
      result := zDbCardProps.Flags.ReadOnly or RestrictionReadOnly;
    crForceReadOnly:
      result := true;
    crForceWriteable:
      result := false;
  end;
end;

procedure TzDbCard.MostraQueryUtilizzataExecute(Sender: TObject);
var
  s: String;
begin

  if DataController.DataSetOk then
  begin
    s := DataController.GetDebugInfo;
    zExecuteMemoDialog(s, GetCardID);
  end;
end;

procedure TzDbCard.NascondiCampoExecute(Sender: TObject);
var
  item: TzControl;
  idx: integer;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  item.Visible := false;

  // RebuildLayout ricompatta la riga (l'item nascosto viene rimosso e il
  // filler ricalcolato); RefreshVisibility non basta.
  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.NascondiCampoUpdate(Sender: TObject);
begin
  ActionVisible(Sender as TAction, zSystem.IsAdmin);
end;

procedure TzDbCard.popCardPopup(Sender: TObject);
var
  s: string;
begin
  dxBarSubItemImpostazioni.Visible := dx.Visible(IsAdmin);
  dxBarEditTitolo.Visible := dx.Visible(IsAdmin);

  cxBarItemReadOnly.Visible := dx.Visible(IsAdmin);
  cxBarItemModifyFlags.Visible := dx.Visible(IsAdmin);

  // s := dx.GetStatesString([not(zDbCardProps.ButtonInsert.Visible and zDbCardProps.ButtonEdit.Visible and zDbCardProps.ButtonDelete.Visible)]);
  s := dx.GetStatesString(zDbCardProps.Flags.ReadOnly);
  dx.SetValue(cxBarItemReadOnly, s);

  s := dx.GetStatesString([zDbCardProps.Flags.ButtonInsert, zDbCardProps.Flags.ButtonUpdate, zDbCardProps.Flags.ButtonDelete]);
  dx.SetValue(cxBarItemModifyFlags, s);

  CopyName.Caption := 'Copia CardID - ' + CardID;
end;

procedure TzDbCard.popEditPopup(Sender: TObject);
var
  item: TzControl;
  idx: integer;
  DisplayLabel: string;
  Field: TField;
  Domain: TzDomain;
  ReadOnly: boolean;
  Required: boolean;
  s: string;
  ColSpan: integer;
  Lines: integer;
  zCtrlType: TzCtrlType;
  IsLookup: boolean;
  IsDataAware: boolean;
  IsMultiLine: boolean;
  IsPicklist: boolean;
begin
  item := zControls.PopupCtrlItem;

  if not(Assigned(item) and IsAdmin) then
  begin
    dxBarEditCtrlCaption.Visible := dx.Visible(false);
    dxBarSpinEditCtrlSize.Visible := dx.Visible(false);
    cxBarEditItemCtrlFlag.Visible := dx.Visible(false);
    cxBarItemCtrlType.Visible := dx.Visible(false);
    dxBarButtonactPersonalizzaPickList.Visible := dx.Visible(false);
    dxBarButtonactPersonalizzaLookup.Visible := dx.Visible(false);
    dxBarButtonactNuovoLookup.Visible := dx.Visible(false);
    dxBarButtonactInfoDebugLookup.Visible := dx.Visible(false);
    Exit;
  end;

  Required := item.Required;
  ReadOnly := item.ReadOnly;
  DisplayLabel := item.DisplayLabel;
  zCtrlType := item.zCtrlType;
  ColSpan := item.Size;
  Lines := item.Lines;

  IsDataAware := item.zCtrlType.IsDataAware;
  IsMultiLine := item.zCtrlType.IsMultiLine;
  /// ////////////////////////////////////////////////////////////////////

  dx.SetValue(dxBarEditCtrlCaption, DisplayLabel);
  dx.SetValue(dxBarSpinEditCtrlSize, ColSpan);
  dx.SetValue(dxBarSpinEditCtrlLines, Lines);
  dx.SetValue(cxBarItemCtrlType, TEnum<TzCtrlType>.EnumToString(zCtrlType));

  s := dx.GetStatesString([ReadOnly, Required]);
  dx.SetValue(cxBarEditItemCtrlFlag, s);

  dxBarEditCtrlCaption.Visible := dx.Visible(IsAdmin);
  dxBarSpinEditCtrlSize.Visible := dx.Visible(IsAdmin);
  dxBarSpinEditCtrlLines.Visible := dx.Visible(IsAdmin and IsMultiLine);

  cxBarEditItemCtrlFlag.Visible := dx.Visible(IsAdmin and IsDataAware);
  cxBarItemCtrlType.Visible := dx.Visible(IsAdmin);

  IsPicklist := item.IsPicklist;
  dxBarButtonactPersonalizzaPickList.Visible := dx.Visible(IsPicklist and IsAdmin);

  IsLookup := item.IsLookup or (item.zCtrlType = ctCheckComboBox);
  dxBarButtonactInfoDebugLookup.Visible := dx.Visible(IsLookup and IsAdmin);
  dxBarButtonactPersonalizzaLookup.Visible := dx.Visible(IsLookup and IsAdmin);
  dxBarButtonactNuovoLookup.Visible := dx.Visible(((not IsLookup) and (not IsPicklist)) and IsAdmin);

  dxBarButtonactPersonalizzaCampo.Visible := dx.Visible(IsAdmin and IsDataAware);
  dxBarButtonactPersonalizzaCard.Visible := dx.Visible(IsAdmin and not IsDataAware);

  SetPopupControlloOrtografico;
end;

procedure TzDbCard.PreviewPictureExecute(Sender: TObject);
begin
  if zControls.PopupCtrlIsClass(ctImage) then
    zExecuteImageDialog(zControls.PopupCtrl as TcxDbImage, '', true);
end;

procedure TzDbCard.SalvaImpostazioniExecute(Sender: TObject);
begin
  SaveProperties;
end;

procedure TzDbCard.NewLineExecute(Sender: TObject);
var
  item: TzControl;
  cp: TzControlProps;
  newPlacement: TControlRowPlacement;
begin
  // "Vai a capo" non crea piu' un item ctLineBreak: imposta (toggle)
  // RowPlacement=rpForceNewLine sul controllo del popup, cosi' la rottura di
  // riga e' una proprieta' del controllo. Aggiorna sia il TzControl runtime
  // sia il TzControlProps (persistenza).
  item := zControls.PopupCtrlItem;
  if not Assigned(item) then
    Exit;

  if item.RowPlacement = rpForceNewLine then
    newPlacement := rpAuto // toggle off: torna al flusso
  else
    newPlacement := rpForceNewLine;

  item.RowPlacement := newPlacement;

  cp := zDbCardProps.Controls.Get(item.name);
  if Assigned(cp) then
    cp.RowPlacement := newPlacement; // SetRowPlacement chiama Modified -> salva

  RebuildLayout;
  RefreshVisibility;
end;

procedure TzDbCard.SeparatoreExecute(Sender: TObject);
var
  idx: integer;
  item: TzControl;
  SeparatorCaption: string;
  Group: string;
begin
  item := zControls.PopupCtrlItem;

  if Assigned(item) then
  begin
    idx := item.Index;
    Group := item.Group;
  end
  else
  begin
    idx := 0;
    Group := '';
  end;

  SeparatorCaption := '';
  if not InputQuery('Separatore', 'Etichetta: ', SeparatorCaption) then
    Exit;

  item := zControls.Add;
  item.zCtrlType := ctSeparator;
  item.name := zControls.UniqueName('Separator');
  item.DisplayLabel := SeparatorCaption;
  item.Visible := true;
  item.Group := Group;
  item.Index := idx;
  item.CreateControls;

  SaveProperties;
  RefreshVisibility;
end;

procedure TzDbCard.SetCardID(const Value: string);
begin
  zDbCardProps.name := Value;
end;

procedure TzDbCard.SetDisableDelete(const Value: boolean);
begin
  if FDisableDelete <> Value then
  begin
    FDisableDelete := Value;
    UpdateActions;
  end;
end;

procedure TzDbCard.SetDisableEdit(const Value: boolean);
begin
  if FDisableEdit <> Value then
  begin
    FDisableEdit := Value;
    UpdateActions;
  end;
end;

procedure TzDbCard.SetDisableInsert(const Value: boolean);
begin
  if FDisableInsert <> Value then
  begin
    FDisableInsert := Value;
    UpdateActions;
  end;
end;

procedure TzDbCard.SetReadOnly(const Value: TzDbCardReadOnly);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    DataController.ReadOnly := IsCardReadOnly;
    RebuildControls;
  end;
end;

procedure TzDbCard.SetTitle(const Title: string);
begin
  Titolo.Caption := trim(Title);
  Titolo.Visible := (Titolo.Caption <> '') and zDbCardProps.Flags.Toolbar;
  dxBarControlContainerTitolo.Visible := dx.Visible(Titolo.Visible);

  dxBarEditTitolo.OnChange := Nil;
  try
    dxBarEditTitolo.EditValue := Titolo.Caption;
  finally
    dxBarEditTitolo.OnChange := dxBarEditTitoloChange;
  end;
end;

procedure TzDbCard.UpdateActions;

var
  Visible: boolean;
begin
  ActionVisible(actDbFirst, zDbCardProps.Flags.ButtonArrows);
  ActionVisible(actDbPrior, zDbCardProps.Flags.ButtonArrows);
  ActionVisible(actDbNext, zDbCardProps.Flags.ButtonArrows);
  ActionVisible(actDbLast, zDbCardProps.Flags.ButtonArrows);
  ActionVisible(actDbRefresh, zDbCardProps.Flags.ButtonRefresh);

  ActionVisible(actDbPost, zDbCardProps.Flags.ButtonOkCancel and DataController.IsEditing);
  ActionVisible(actDbCancel, zDbCardProps.Flags.ButtonOkCancel and DataController.IsEditing);

  if not DataController.DataSetOk then
  begin
    ActionVisible(actDbDelete, zDbCardProps.Flags.ButtonDelete and not DisableDelete);
    ActionVisible(actDbEdit, zDbCardProps.Flags.ButtonUpdate and not DisableEdit);
    ActionVisible(actDbInsert, zDbCardProps.Flags.ButtonInsert and not DisableInsert);
  end
  else
  begin
    ActionVisible(actDbInsert, DataController.CanInsert and zDbCardProps.Flags.ButtonInsert and not DisableInsert);
    ActionVisible(actDbEdit, DataController.CanEdit and zDbCardProps.Flags.ButtonUpdate and not DisableEdit);
    ActionVisible(actDbDelete, DataController.CanDelete and zDbCardProps.Flags.ButtonDelete and not DisableDelete);
  end;

  if Assigned(FOnDataSetInsert) then
    ActionVisible(actDbInsert, true);

  if Assigned(FOnDataSetEdit) then
    ActionVisible(actDbEdit, true);

  if Assigned(FOnDataSetDelete) then
    ActionVisible(actDbDelete, true);
end;

procedure TzDbCard.LabelDblClick;
begin

  if actPersonalizzaCampo.Visible then
    if actPersonalizzaCampo.Enabled then
      actPersonalizzaCampo.Execute;
end;

procedure TzDbCard.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FzSystem) then
    zSystem := nil;

  if (Operation = opRemove) and (AComponent = FzDataSet) then
    zDataSet := nil;

  if (Operation = opRemove) then
    if Assigned(ToolActions) then
      ToolActions.RemoveNotification(AComponent);
end;

procedure TzDbCard.OpenPictureExecute(Sender: TObject);
begin
  if zControls.PopupCtrlIsClass(ctImage) then
    TcxDbImage(zControls.PopupCtrl).LoadFromFile;
end;

procedure TzDbCard.ResetLookupDataSets;
var
  zControl: TzControl;
begin

  for zControl in zControls do
    zControl.ResetLookupDataSet;
end;

procedure TzDbCard.Resize;
begin
  inherited;
  PostInternalMessage(cmd_Resize);
end;

procedure TzDbCard.Resized;
begin
  SiDbCard.EnterMethod(Self, 'Resized');

  if not disableResize then
    if not IsCreatingControls then // evita AV se mostra errori di fk in creazione
      if Assigned(zControls) then
        if zControls.Count > 0 then
        begin
          isResizing := true;
          try
            RefreshVisibility; // Messaggio
            CheckReflow;
          finally
            isResizing := false;
          end;
        end;

  SiDbCard.LeaveMethod(Self, 'Resized');
end;

procedure TzDbCard.CheckReflow;
// Reflow al resize reale: se la capacità di riga (in caratteri) è cambiata
// oltre soglia rispetto all'ultimo BuildLayoutItems, ricostruisce il layout
// così le righe si riavvolgono sulla larghezza corrente. Nessun
// SaveProperties: il resize non è una personalizzazione.
const
  // < (H_MARGIN+VSCROLLBAR_WIDTH)/CharWidth (~5 char): il rebuild deve scattare
  // PRIMA che il buffer di margine si esaurisca, altrimenti la riga composta
  // per la larghezza precedente eccede il client e compare la scrollbar.
  REFLOW_THRESHOLD_CHARS = 3;
var
  M: TzRowModel;
begin
  if FLastBuildRowMax <= 0 then
    Exit;
  if IsCreatingControls then
    Exit;
  if not Showing then
    Exit;
  if dxLayoutControl.Customization then
    Exit; // editor visuale aperto: non toccare il layout sotto i piedi

  if FInReflow then
    Exit; // il RebuildLayout sottostante può rigenerare un cmd_Resize

  M := NewRowModel;
  try
    if Abs(M.RowMaxSize - FLastBuildRowMax) >= REFLOW_THRESHOLD_CHARS then
    begin
      FInReflow := true;
      try
        RebuildLayout; // aggiorna FLastBuildRowMax: la soglia chiude il ciclo
      finally
        FInReflow := false;
      end;
    end;
  finally
    M.Free;
  end;
end;

procedure TzDbCard.SavePictureExecute(Sender: TObject);
begin
  if zControls.PopupCtrlIsClass(ctImage) then
    TcxDbImage(zControls.PopupCtrl).SaveToFile;
end;

procedure TzDbCard.SetToolActions(

  const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

procedure TzDbCard.ValidateControls(const ARaiseExceptionOnError: boolean);
begin
  DataController.Validate(ARaiseExceptionOnError);
end;

procedure TzDbCard.VisibleIfAdmin(Sender: TObject);
begin
  ActionVisible(Sender as TAction, IsAdmin);
end;

procedure TzDbCard.WebCamExecute(Sender: TObject);
begin
  // implementare
  if zControls.PopupCtrlIsClass(ctImage) then
    TcxDbImage(zControls.PopupCtrl).LoadFromFile;
end;

procedure TzDbCard.ForceControlsValidation;
var
  item: TzControl;
begin
  SiDbCard.LogVerbose('ForceControlsValidation');

  if not IsDestroying then
    if DataController.DataSetOk then
      if DataController.IsEditing then
        for item in zControls do
          item.ForceValidation;
end;

procedure TzDbCard.ForceDisplay;
begin
  InitCard;
end;

function TzDbCard.GetDialogTitle: string;
  function EstraiCaptionDaDataSet(zFbDataSet: TzFbDataSet): string;

  var
    s: string;
    c: Char;
    PrevWasUpper: boolean;
  begin
    result := '';

    s := zFbDataSet.IdDataSet;
    if Pos('.', s) <> 0 then
      s := System.Copy(s, Pos('.', s) + 1, MaxInt);

    PrevWasUpper := false;
    for c in s do
      if c in ['A' .. 'Z'] then
      begin
        if PrevWasUpper then
          result := result + c
        else
          result := result + ' ' + c;

        PrevWasUpper := true;
      end
      else
      begin
        result := result + c;
        PrevWasUpper := false;
      end;

    result := trim(result);
  end;

begin
  result := zDbCardProps.Caption;

  if SameText(zDefaultCardCaption, zDbCardProps.Caption) then
  begin
    if zDbCardProps.Title <> '' then
      result := zDbCardProps.Title
    else
      result := EstraiCaptionDaDataSet(zDataSet);
  end;
end;

procedure TzDbCard.ActivateDataSet;
begin

  if DataController.DataSetOk then
    if not DataController.IsActive then
      if DataController.AutoOpen then
        DataController.OpenDataSet;
end;

procedure TzDbCard.DataSourceStateChange(Sender: TObject);
begin
  SiDbCard.LogBoolean(Name + '.IsDestroying', IsDestroying);

  if IsDestroying then
    Exit;

  if zDataSet.State = dsInsert then
  begin
    ClearInvalidDefaultValues;

    if not PendingVerifyLookupsParams then
    begin
      PendingVerifyLookupsParams := true;
      PostInternalMessage(cmd_VerifyLookupsParams);
    end;
  end;
  // ResetLookupDataSets;

  UpdateCheckGroupBoxes;

  if DataController.IsEditing then
    ForceControlsValidation; // ZZ 12 maggio 2022

  PostInternalMessage(cmd_UpdateColors);
  PostInternalMessage(cmd_UpdateActions, 0);
end;

procedure TzDbCard.DataSourceDataChange(Sender: TObject; Field: TField);
var
  s: string;
  DroppedDown: boolean;

  function IsDroppedDown: boolean;
  var
    cxCustomEdit: TcxCustomEdit;
  begin
    result := false;

    cxCustomEdit := dx.ActiveControl;

    if Assigned(cxCustomEdit) then
      if (cxCustomEdit is TcxCustomDropDownEdit) then
        if TcxCustomDropDownEdit(cxCustomEdit).DroppedDown then
          result := true;
  end;

begin
  if Assigned(Field) then
    s := Field.FieldName
  else
    s := 'DataSet';

  SiDbCard.LogString('DataSourceDataChange: ' + s, Name);

  DroppedDown := IsDroppedDown;

  if not Inserting then
    if LookupsEnabled then
      if not DroppedDown then // mail GD 05.12.2022
      begin

        if Assigned(Field) then
          ClearDependentFields(Field);

        // zControls.VerifyLookupsParams(Field, nil);

        if not PendingVerifyLookupsParams then
          if not InsideVerifyLookupsParams then
          begin
            PendingVerifyLookupsParams := true;
            PostInternalMessage(cmd_VerifyLookupsParams);
          end;
      end;

  UpdateCheckGroupBoxes;

  ForceControlsValidation; // ZZ 12 maggio 2022

  UpdateColors;
end;

procedure TzDbCard.doBeforeCreateDbControl(const FieldName: string;

var cxCustomEdit: TcxCustomEdit);
begin
  if Assigned(FOnBeforeCreateDbControl) then
    OnBeforeCreateDbControl(Self, FieldName, cxCustomEdit);
end;

procedure TzDbCard.doAfterCreateDbControl(const FieldName: string; cxCustomEdit: TcxCustomEdit);
begin
  if Assigned(FOnAfterCreateDbControl) then
    OnAfterCreateDbControl(Self, FieldName, cxCustomEdit);
end;

procedure TzDbCard.doBeforeCreateControl(const name: string;

var Control: TWinControl);
begin
  if Assigned(FOnBeforeCreateControl) then
    OnBeforeCreateControl(Self, Name, Control);
end;

procedure TzDbCard.doAfterCreateControl(const name: string; Control: TWinControl);
begin
  if Assigned(FOnAfterCreateControl) then
    OnAfterCreateControl(Self, Name, Control);
end;

procedure TzDbCard.doBeforeCreateControls;
begin
  if Assigned(FOnBeforeCreateControls) then
    OnBeforeCreateControls(Self);
end;

procedure TzDbCard.doAfterCreateControls;
begin
  if Assigned(FOnAfterCreateControls) then
    OnAfterCreateControls(Self);
end;

procedure TzDbCard.SetRestrictionReadOnly(const Value: boolean);
begin
  if FRestrictionReadOnly <> Value then
  begin
    FRestrictionReadOnly := Value;
    DataController.ReadOnly := IsCardReadOnly;
    RebuildControls;
  end;
end;

function TzDbCard.ValidateRequiredFields(RaiseError: boolean): boolean;
var
  msg: string;
  ErrorFields: string;
  ErrorCount: integer;
  Field: TField;
  i: integer;
  ctrlProps: TzControlProps;
begin
  result := true;

  if not DataController.IsEditing then
    Exit;

  msg := '';
  ErrorFields := '';
  ErrorCount := 0;

  for ctrlProps in zDbCardProps.Controls do
    if ctrlProps.Visible then
    begin
      if not DataController.TryGetField(ctrlProps.name, Field) then
        Continue;

      if not DataController.RequiredFieldOk(Field) then
      begin
        Inc(ErrorCount);
        ErrorFields := ErrorFields + Field.DisplayLabel + #13;
      end;
    end;

  if ErrorCount > 0 then
  begin
    result := false;
    if RaiseError then
    begin
      msg := 'I campi seguenti devono avere un valore:' + #13 + #13 + ErrorFields;
      ConfirmOk(msg);
      System.SysUtils.Abort;
    end;
  end;
end;

procedure TzDbCard.UpdateColors;
var
  item: TzControl;
  Field: TField;
begin
  if DataController.IsActive then
    for item in zControls do
      if DataController.TryGetField(item.name, Field) then
      begin
        item.FieldReadOnly := Field.ReadOnly;
        item.FieldRequired := Field.Required;
        item.UpdateColor;
      end;
end;

procedure TzControl.EditCustomCaption;
begin
  // non più utilizzata - sostituita da TzDbCard.OverrideCampoExecute
end;

function TzControl.ExecuteLookupDlg: boolean;
var
  zLookup: TzLookup;
  zDbViewDlg: TzDbViewDlg;
  DataSet: TzFbDataSet;
  ParamsChanged: boolean;

  function GetFindValue: Variant;
  var
    Field: TField;
  begin
    result := null;

    Field := GetField;
    if Assigned(Field) then
      zDbViewDlg.FindValue := Field.Value;

    if cxCustomEdit is TcxCustomLookupComboBox then
      result := TcxDBLookupComboBox(cxCustomEdit).Text
    else
      if cxCustomEdit is TcxCustomExtLookupComboBox then
        result := TcxCustomExtLookupComboBox(cxCustomEdit).Text
  end;

begin
  result := false;

  SiDbCard.EnterMethod('ExecuteLookupDlg');

  if IdLookup.IsEmpty then
    Exit;

  zLookup := Controls.zSystem.zLookups.Get(IdLookup);

  if not Assigned(zLookup) then
    Exit;

  SiDbCard.LogString('ExecuteLookupDlg', 'pre creazione dataset');

  DataSet := CreateDataSet(IdLookup);
  try

    if Assigned(lkDataSet) then
    begin
      // qualora siano state variate, esempio da una form in autoCommit
      DataSet.Transaction := lkDataSet.Transaction;
      DataSet.UpdateTransaction := lkDataSet.UpdateTransaction;

      // servono a roger per agganciare params in fase di formLookup
      DataSet.DataSource := lkDataSet.DataSource;
      DataSet.BeforeOpen := lkDataSet.BeforeOpen;
      DataSet.AfterOpen := lkDataSet.AfterOpen; // displayFormat
      DataSet.OnNewRecord := lkDataSet.OnNewRecord
    end;

    SiDbCard.LogString('ExecuteLookupDlg', 'dataset creato');
    AssignMasterFieldsParams(DataSet, ParamsChanged);

    if not DataSet.SelectSQL.Text.IsEmpty then
      DataSet.Active := true;

    SiDbCard.LogString('ExecuteLookupDlg', 'dataset attivato');

    zDbViewDlg := TzDbViewDlg.Create(nil);
    try
      SiDbCard.LogString('ExecuteLookupDlg', 'zDbViewDlg creato');
      zDbViewDlg.name := 'zDbViewDlg';
      zDbViewDlg.zSystem := Controls.zSystem;
      zDbViewDlg.DataSet := DataSet;
      zDbViewDlg.IdLookup := IdLookup;
      zDbViewDlg.FindValue := GetFindValue;

      SiDbCard.LogString('ExecuteLookupDlg', 'pre zDbViewDlg.execute');

      result := zDbViewDlg.Execute;
    finally
      FreeAndNil(zDbViewDlg);
    end;

    if result then
      if not ReadOnly then
      begin
        CheckLookupRecordValid;

        // tmp := zLookup.LokupFields;
        //
        // // Input diretto nel combo NON collegato a una FK;
        // // Tipo: INT_NOME_VIA oppure ORE_RILEVATE.DESCRIZIONE_ATTIVITA
        // if zLookup.LokupFields.IsEmpty then
        // if not zLookup.OnlyFromLookup then
        // tmp := zLookup.SearchFields;

        Controls.DataSet.CopyMappingFields(DataSet, zLookup.Mappings, false);

        if ControlIsLookup then
          TcxCustomTextEdit(cxCustomEdit).SelStart := 0;
      end;

    DataSet.Active := false;
  finally
    FreeAndNil(DataSet);
  end;

  /// ///////////////////////////////
  // Si aggiorna il dataset del combo
  InitLookupProperties;
  AssignDataSetProps(IdLookup, lkDataSet);
  lkDataSet.ReOpen();

  SiDbCard.LeaveMethod('ExecuteLookupDlg');
end;

procedure TzControl.SetFieldReadOnly(

  const Value: boolean);
begin
  if FFieldReadOnly <> Value then
  begin
    FFieldReadOnly := Value;
    InternalSetEditability;
  end;
end;

procedure TzControl.SetFieldRequired(const Value: boolean);
begin
  if FFieldRequired <> Value then
  begin
    FFieldRequired := Value;
    InternalSetEditability;
  end;
end;

procedure TzControl.SetLookupTransactions(ReadTrans, WriteTrans: TzFbTransaction);
var
  wasActive: boolean;
begin
  inherited;

  if Assigned(lkDataSet) then
  begin
    wasActive := lkDataSet.Active;
    lkDataSet.Active := false;
    lkDataSet.Transaction := ReadTrans;
    lkDataSet.UpdateTransaction := WriteTrans;
    lkDataSet.Active := wasActive;
  end;
end;

procedure TzControl.SetRequired(const Value: boolean);
begin
  if FRequired <> Value then
  begin
    FRequired := Value;
    InternalSetEditability;
  end;
end;

function TzControl.GetEditability: TEditability;
var
  LookupEditable: boolean;
begin
  result := edNormal;

  // non funziona con i lookup impostati su campi di join
  LookupEditable := (zCtrlType.IsLookup and LookupIgnoreFieldReadOnly);

  if ReadOnly or ForcedReadOnly or (FieldReadOnly and not LookupEditable) or Controls.Card.IsCardReadOnly then
    result := edReadOnly
  else
    // ZZ 23.11.2018 Domain.Required: non funziona con i campi di Join. Valutare se necessario
    if Required or FieldRequired { or Domain.Required } then
      result := edRequired;
end;

function TzControl.GetField: TField;
begin
  result := nil;

  if Assigned(Controls.DataSet) then
    result := Controls.DataSet.FindField(Name);
end;

procedure TzControl.InternalSetEditability;
var
  Editability: TEditability;
begin
  if not Assigned(cxCustomEdit) then
    Exit;

  if zCtrlType.IsGroup then
    Exit;

  Editability := GetEditability;
  dx.SetEditability(cxCustomEdit, Editability, Controls.Card.DataController.IsEditing);
end;

procedure TzControl.SetForcedReadOnly(

  const Value: boolean);
begin
  if FForcedReadOnly <> Value then
  begin
    FForcedReadOnly := Value;
    InternalSetEditability;
  end;
end;

procedure TzControl.SetLookupIgnoreFieldReadOnly(

  const Value: boolean);
begin
  if FLookupIgnoreFieldReadOnly <> Value then
  begin
    FLookupIgnoreFieldReadOnly := Value;
    InternalSetEditability;
  end;
end;

procedure TzControl.UpdateColor;
var
  Editability: TEditability;
  StyleController: TcxEditStyleController;
  isNull: boolean;
begin
  if not Assigned(cxCustomEdit) then
    Exit;

  if zCtrlType.IsGroup then
    Exit;

  Editability := GetEditability;

  // cambia colore se un campo required risulta valorizzato
  if Editability = edRequired then
    if not IsEmptyValue then
      Editability := edNormal;

  StyleController := dx.GetStyleController(Editability);
  if cxCustomEdit.Style.StyleController <> StyleController then
    cxCustomEdit.Style.StyleController := StyleController;
end;

procedure TzControl.VerifyLookupParams;
var
  ParamsChanged: boolean;
begin

  if Assigned(lkDataSet) then
  begin
    AssignMasterFieldsParams(lkDataSet, ParamsChanged);

    // se parametri modificati oppure se è stato aperto il dataset della card
    if ParamsChanged or ((not lkDataSet.Active) and Assigned(Controls.DataSet) and Controls.DataSet.Active) then
    begin
      SiDbCard.LogString('VerifyLookupParams', 'ParamsChanged per:' + Name);
      lkDataSet.ReOpen();
      SiDbCard.LogColored(clRed, Name);
    end;
  end
  else
    if zCtrlType = ctCheckComboBox then
      Self.FillCheckComboBoxItems;
end;

procedure TzDbCard.CreateCustomControls;
begin
  zControls.LoadFromProps(zDbCardProps); // crea i controlli
end;

procedure TzDbCard.cxBarEditItemCtrlFlagPropertiesChange(Sender: TObject);
var
  s: string;
  ReadOnly: boolean;
  Required: boolean;
  item: TzControl;
  ShouldSave: boolean;
begin
  s := cxBarEditItemCtrlFlag.CurEditValue;

  ReadOnly := s.Substring(0, 1) = '1';
  Required := s.Substring(1, 1) = '1';

  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  ShouldSave := false;

  // selected
  if item.ReadOnly <> ReadOnly then
  begin
    item.ReadOnly := ReadOnly;
    ShouldSave := true;
  end;

  // domains
  if item.Required <> Required then
  begin
    item.Required := Required;
    ShouldSave := true;

    if Assigned(item.Domain) then
      if item.Domain.Required <> Required then
      begin
        item.Domain.Required := Required;
        item.Domain.SaveToBase(true);
      end;
  end;

  if ShouldSave then
    SaveProperties;

  RefreshVisibility;
end;

procedure TzDbCard.FlagsPropertiesChange;
var
  s: string;
begin
  s := cxBarItemModifyFlags.CurEditValue;

  zDbCardProps.Flags.BeginUpdate;
  try
    zDbCardProps.Flags.ButtonInsert := s.Substring(0, 1) = '1';
    zDbCardProps.Flags.ButtonUpdate := s.Substring(1, 1) = '1';
    zDbCardProps.Flags.ButtonDelete := s.Substring(2, 1) = '1';
    // zDbCardProps.Flags.ReadOnly := not(zDbCardProps.Flags.ButtonInsert or zDbCardProps.Flags.ButtonUpdate or zDbCardProps.Flags.ButtonDelete);
  finally
    zDbCardProps.Flags.EndUpdate;
  end;

  s := dx.GetStatesString(zDbCardProps.Flags.ReadOnly);
  dx.SetValue(cxBarItemReadOnly, s);

  UpdateActions;
  SaveProperties;
end;

procedure TzDbCard.ForceCopyMappingFields;
var
  item: TzControl;
begin
  // ZZ 06.02.2019: da view=> insert non vedono i campi calcolati se preinizializzati (es. M/D)

  for item in zControls do
    item.CopyMappingFields();
end;

procedure TzDbCard.ModificaMemoExecute(Sender: TObject);
begin
  if zControls.PopupCtrlIsClass(ctMemo) then
  begin
    zControls.DataSet.CheckEditMode;
    zExecuteMemoDialog(TcxCustomMemo(zControls.PopupCtrl), '');
  end;
end;

procedure TzDbCard.ModificaMemoUpdate(Sender: TObject);
begin
  ActionVisible(Sender as TCustomAction, zControls.PopupCtrlIsClass(ctMemo));
end;

procedure TzDbCard.ModificaRTFExecute(Sender: TObject);
begin
  if zControls.PopupCtrlIsClass(ctRTF) then
  begin
    zControls.DataSet.CheckEditMode;
    // zExecuteMemoDialog(TcxDbRichEdit(zControls.PopupCtrl), '');
    zExecuteRichEditDialog(TcxDbRichEdit(zControls.PopupCtrl), '');
  end;
end;

procedure TzDbCard.ModificaRTFUpdate(Sender: TObject);
begin
  ActionVisible(Sender as TCustomAction, zControls.PopupCtrlIsClass(ctRTF));
end;

procedure TzDbCard.PropertiesChange;
var
  s: string;
  SolaLettura: boolean;
begin
  SolaLettura := cxBarItemReadOnly.CurEditValue = '1';

  zDbCardProps.Flags.BeginUpdate;
  try
    zDbCardProps.Flags.ReadOnly := SolaLettura;
    // zDbCardProps.Flags.ButtonInsert := not SolaLettura;
    // zDbCardProps.Flags.ButtonDelete := not SolaLettura;
    // zDbCardProps.Flags.ButtonUpdate := not SolaLettura;
  finally
    zDbCardProps.Flags.EndUpdate;
  end;

  s := dx.GetStatesString([zDbCardProps.Flags.ButtonInsert, zDbCardProps.Flags.ButtonUpdate, zDbCardProps.Flags.ButtonDelete]);
  dx.SetValue(cxBarItemModifyFlags, s);

  UpdateActions;
  SaveProperties;
end;

procedure TzDbCard.CtrlTypePropertiesChange;
var
  i: integer;
  item: TzControl;
  zCtrlType: TzCtrlType;
  s: string;
begin

  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  s := cxBarItemCtrlType.CurEditValue;
  zCtrlType := TEnum<TzCtrlType>.StringToEnum(s);

  item.zCtrlType := zCtrlType;
  item.DestroyControls;
  item.CreateControls;
  SaveProperties;

  RefreshVisibility;
end;

procedure TzDbCard.Post;
var
  CustomEdit: TcxCustomEdit;
begin
  CustomEdit := ActiveCustomEdit;

  if Assigned(CustomEdit) then
    CustomEdit.PostEditValue;

  DataController.CheckBrowseMode;
end;

procedure TzDbCard.Cancel;
begin
  DataController.Cancel;
end;

procedure TzDbCard.PostInternalMessage(const cmd: TzDbCardCommand; lparam: NativeUInt = 0);
begin
  if PostedCommands[cmd] then
    Exit;

  if (not HandleAllocated) or (not Showing) then
  begin
    // niente HWND o card non ancora a video: non postare e NON latchare
    // PostedCommands, ma ricordare il comando e rilanciarlo in
    // CMShowingChanged (es. wizard: Insert prima di ShowForm).
    // Vale anche per cmd_NewLookupDisplayText: gli edit sopravvivono al
    // RecreateWnd (vengono distrutti solo da RebuildControls) e il handler
    // valida comunque il puntatore via zControls.Find prima di usarlo —
    // scartarlo qui lascerebbe il lookup senza testo alla visualizzazione
    // (lo scenario wizard è proprio un post prima dello Show).
    DeferredCommands[cmd] := true;
    DeferredParams[cmd] := lparam;
    Exit;
  end;

  PostedCommands[cmd] := true;
  DeferredParams[cmd] := lparam; // conservato per un eventuale trasferimento in DestroyWnd
  if not PostMessage(Handle, ZZ_DBCARD, NativeUInt(cmd), lparam) then
    PostedCommands[cmd] := false; // post fallito: rilascia subito
end;

procedure TzDbCard.MessageHandler(var Message: TMessage);
var
  cmd: TzDbCardCommand;
  cxCustomEdit: TcxCustomEdit;
begin
  inherited;

  cmd := TzDbCardCommand(Message.WParam);

  // cmd_Resize: rilascia il latch PRIMA del dispatch. Durante un drag continuo
  // un nuovo Resize puo' arrivare mentre Resized/RebuildLayout e' in corso; col
  // latch ancora alzato verrebbe coalizzato e perso, lasciando le righe
  // composte per una larghezza intermedia (scrollbar che resta). Rilasciandolo
  // prima, quel Resize ri-posta e l'ultima posizione ottiene sempre il rebuild.
  if cmd = cmd_Resize then
    PostedCommands[cmd_Resize] := false;

  try
    Case cmd of
      cmd_UpdateActions:
        UpdateActions;

      cmd_DisplayToolbars:
        DisplayToolbars;

      cmd_NewLookupDisplayText:
        begin
          cxCustomEdit := TcxCustomEdit(Message.lparam);

          // Valida il puntatore: il messaggio può essere stato differito
          // (CMShowingChanged) o trasferito (DestroyWnd) e l'edit nel
          // frattempo distrutto da RebuildControls.
          if Assigned(cxCustomEdit) and Assigned(zControls.Find(cxCustomEdit)) then
          begin
            cxCustomEdit.Clear;

            if cxCustomEdit is TcxCustomLookupComboBox then
              TcxCustomLookupComboBox(cxCustomEdit).Text := ''
            else
              if cxCustomEdit is TcxCustomExtLookupComboBox then
                TcxCustomExtLookupComboBox(cxCustomEdit).Text := '';
          end;
        end;

      cmd_SaveLookupToZip:
        begin
          if not IsDestroying then
          begin
            zSystem.SaveZip(csLookups, 'Personalizzazione Lookup DbCard');
            LoadProperties(boolean(Message.lparam));
          end;
        end;

      cmd_SavePickListToZip:
        begin
          if not IsDestroying then
          begin
            zSystem.SaveZip(csPickLists, 'Personalizzazione Lookup DbCard');
            LoadProperties(boolean(Message.lparam));
          end;
        end;

      cmd_LoadProperties:
        begin
          if not IsDestroying then
            LoadProperties(boolean(Message.lparam));
        end;

      cmd_PropertiesChange:
        PropertiesChange;

      cmd_ReadOnlyPropertiesChange:
        ReadOnlyPropertiesChange;

      cmd_FlagsPropertiesChange:
        FlagsPropertiesChange;

      cmd_CtrlTypePropertiesChange:
        CtrlTypePropertiesChange;

      cmd_RebuildControls:
        RebuildControls;

      cmd_RebuildSingleControl:
        if not IsDestroying then
          RebuildSingleControl;

      cmd_UpdateColors:
        begin
          if not IsDestroying then
            UpdateColors;
        end;

      cmd_Resize:
        Resized;

      cmd_PersonalizzaCard:
        PersonalizzaCard;

      cmd_VerifyLookupsParams:
        begin
          try
            // InsideVerifyLookupsParams è gestito internamente da
            // TzControls.VerifyLookupsParams (set + try/finally):
            // impostarlo anche qui la faceva uscire subito senza fare nulla.
            if Assigned(zDataSet) and zDataSet.Active then
              zControls.VerifyLookupsParams(nil, nil);
          finally
            PendingVerifyLookupsParams := false;
          end;
        end;

      cmd_SaveProperties:
        DoDeferredSaveProperties;
    end;
  finally
    if cmd <> cmd_Resize then
      PostedCommands[cmd] := false;
  end;
end;

procedure TzDbCard.CopiaCampiVisibiliExecute(Sender: TObject);
var
  StringList: TStringList;
  item: TzControl;
begin

  StringList := TStringList.Create;
  try

    for item in zControls do
      if item.Visible then
        StringList.Add(item.name);

    Clipboard.AsText := StringList.Text;
    ConfirmOk('Campi copiati nella clipboard.');
  finally
    FreeAndNil(StringList);
  end;
end;

function TzDbCard.ActiveCustomEdit: TcxCustomEdit;
var
  item: TzControl;
  ActiveControl: TcxCustomEdit;
begin
  result := nil;

  ActiveControl := dx.ActiveControl;

  for item in zControls do
    if item.zCtrlType.IsDataAware then
      if item.Visible then
        if item.cxCustomEdit = ActiveControl then
        begin
          result := item.cxCustomEdit;
          Exit;
        end;
end;

function TzDbCard.ActiveFieldName: string;
var
  item: TzControl;
begin
  result := '';

  for item in zControls do
    if item.zCtrlType.IsDataAware then
      if item.Visible then
        if item.cxCustomEdit.IsFocused then
        begin
          result := item.name;
          Exit;
        end;
end;

function TzControls.CreateLabel(const name: string; Caption: String; FocusControl: TWinControl; const Transparent: boolean; const AutoSize: boolean): TcxLabel;
begin
  result := TcxLabel.Create(Card);
  result.Visible := false;
  result.name := Card.UniqueComponentName('lbl_' + name);
  result.AutoSize := false;
  // prima del parent, altrimenti se su pagecontrol=> AV
  result.Parent := Card;
  result.AutoSize := AutoSize;
  result.Caption := Caption;
  result.Hint := Caption;
  result.FocusControl := FocusControl;

  dx.InitLabel(result, Transparent);
end;

function TzDbCard.UniqueComponentName(const name: string): string;
var
  i: integer;
begin
  result := Name;

  i := 0;
  while Assigned(FindComponent(result)) do
  begin
    Inc(i);
    result := Name + '_' + i.ToString;
  end;
end;

function TzDbCard.ActiveMonitor: TMonitor;
begin
  if Assigned(Application.MainForm) then
    result := Screen.MonitorFromWindow(Application.MainForm.Handle)
  else
    result := Screen.PrimaryMonitor;
end;

procedure TzDbCard.dxBarSpinEditCtrlLinesChange(Sender: TObject);
var
  item: TzControl;
  Lines: integer;
begin

  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  Lines := dxBarSpinEditCtrlLines.EditValue;
  item.Lines := Lines;

  // Lines incide su ResolveHeight, applicato solo in BuildLayoutItems:
  // RefreshVisibility da sola non aggiorna dxItem.Height.
  // RebuildLayout PRIMA di SaveProperties (vedi nota sul DlgWidth descalato).
  RebuildLayout;
  SaveProperties;
end;

procedure TzControls.VerifyLookupsParams(ChangedField: TField = nil; skipControl: TzControl = nil);
var
  zControl: TzControl;
  zLookup: TzLookup;
  DoVerify: boolean;
begin
  if Card.InsideVerifyLookupsParams then
    Exit;

  Card.InsideVerifyLookupsParams := true;
  try

    for zControl in Self do
    begin
      if zControl <> skipControl then
      begin
        if (zControl.zCtrlType.IsLookup) or (zControl.zCtrlType = ctCheckComboBox) then
        begin
          DoVerify := true;

          // Se l'evento è stato scatenato da un singolo campo, verifico che sia un master field
          if Assigned(ChangedField) then
          begin
            zLookup := zSystem.zLookups.Get(zControl.IdLookup);
            if Assigned(zLookup) then
            begin
              // Test case-insensitive per vedere se il nome del campo impatta i MasterFields
              if Pos(UpperCase(ChangedField.FieldName), UpperCase(zLookup.MasterFields)) = 0 then
                DoVerify := false;
            end;
          end;

          if DoVerify then
            zControl.VerifyLookupParams;
        end;
      end;
    end;
  finally
    Card.InsideVerifyLookupsParams := false;
  end;
end;

procedure TzDbCard.ReadOnlyPropertiesChange;
var
  s: string;
begin
  if IsDestroying then
    Exit;

  zDbCardProps.Flags.BeginUpdate;
  try
    zDbCardProps.Flags.ReadOnly := cxBarItemReadOnly.CurEditValue = '1';

    if zDbCardProps.Flags.ReadOnly then
    begin
      zDbCardProps.Flags.ButtonInsert := not zDbCardProps.Flags.ReadOnly;
      zDbCardProps.Flags.ButtonUpdate := not zDbCardProps.Flags.ReadOnly;
      zDbCardProps.Flags.ButtonDelete := not zDbCardProps.Flags.ReadOnly;
    end;
  finally
    zDbCardProps.Flags.EndUpdate;
  end;

  s := dx.GetStatesString([zDbCardProps.Flags.ButtonInsert, zDbCardProps.Flags.ButtonUpdate, zDbCardProps.Flags.ButtonDelete]);
  dx.SetValue(cxBarItemModifyFlags, s);

  SaveProperties;
end;

procedure TzDbCard.ReopenLookupDataSet(const FieldName: string; const doCopyMappingFields: boolean);
var
  item: TzControl;
begin
  item := zControls.Find(FieldName);

  if Assigned(item) then
    if Assigned(item.lkDataSet) then
    begin
      item.lkDataSet.ReOpen();
      item.UpdateColor(); // 10.11

      if doCopyMappingFields then
        item.CopyMappingFields();
    end;
end;

procedure TzDbCard.SetLookupTransactions(const FieldName: string; ReadTrans, WriteTrans: TzFbTransaction);
var
  item: TzControl;
begin
  item := zControls.Find(FieldName);

  if Assigned(item) then
    if Assigned(item.lkDataSet) then
      item.SetLookupTransactions(ReadTrans, WriteTrans);
end;

procedure TzDbCard.SetOnAfterCreateControls(const Value: TNotifyEvent);
begin
  FOnAfterCreateControls := Value;
end;

function TzControl.ControlIsLookup: boolean;
begin
  result := (cxCustomEdit is TcxCustomLookupComboBox) or (cxCustomEdit is TcxCustomExtLookupComboBox);
end;

function TzControl.LookupControlField: TField;
var
  Combo: TcxDBLookupComboBox;
  ComboExt: TcxDBExtLookupComboBox;
begin
  result := nil;

  if cxCustomEdit is TcxDBLookupComboBox then
  begin
    Combo := TcxDBLookupComboBox(cxCustomEdit);

    if Combo.Properties.ListColumns.Count > 0 then
      result := Combo.Properties.ListColumns[0].Field;
  end
  else
    if cxCustomEdit is TcxDBExtLookupComboBox then
    begin
      ComboExt := TcxDBExtLookupComboBox(cxCustomEdit);

      if Assigned(ComboExt.Properties.ListFieldItem) then
        result := TcxGridDBColumn(ComboExt.Properties.ListFieldItem).DataBinding.Field;
    end;
end;

procedure TzControl.LookupDatasetAfterOpen(DataSet: TDataSet);
var
  Field: TField;
  Lookup: TzLookup;

  procedure ProcessField(const FieldName: string);
  var
    Field: TField;
  begin
    Field := DataSet.FindField(FieldName);

    if Assigned(Field) then
      if Field is TNumericField then
        TNumericField(Field).DisplayFormat := '';
  end;

begin
  Lookup := GetLookup(Controls.zSystem);

  try
    ProcessField(Lookup.FirstFieldFK);

    Field := LookupControlField;

    if Assigned(Field) then
      ProcessField(Field.FieldName);
  except
  end;
end;

procedure TzControl.OnLookupCloseUp(Sender: TObject);
begin

  if ControlIsLookup then
    TcxCustomTextEdit(cxCustomEdit).SelStart := 0;
end;

procedure TzControl.SetLookupEnabled(const Value: boolean);
begin
  if FLookupEnabled <> Value then
  begin
    FLookupEnabled := Value;

    if Assigned(cxCustomEdit) then
    begin
      cxCustomEdit.Enabled := LookupEnabled;

      if Assigned(lkDataSet) then
      begin
        if LookupEnabled then
        begin
          if Assigned(Controls.DataSet) and Controls.DataSet.Active then
            lkDataSet.RevertSQL(true);
        end
        else
          lkDataSet.Active := false;
      end;
    end;
  end;
end;

procedure TzDbCard.EnableLookups;
begin
  LookupsEnabled := true;
end;

procedure TzDbCard.DisableLookups;
begin
  LookupsEnabled := false;
end;

procedure TzDbCard.SetLookupsEnabled(Value: boolean);
var
  zControl: TzControl;
begin

  if FLookupsEnabled <> Value then
  begin
    FLookupsEnabled := Value;

    for zControl in zControls do
      zControl.LookupEnabled := Value;
  end
  else
    // Se è già in stato di Enabled verifica i parametri dei lookup
    // Esempio: richieste, passaggio tra una scheda e un'altra
    if Value then
      zControls.VerifyLookupsParams;
end;

procedure TzDbCard.SetPopupControlloOrtografico;
var
  i: integer;
  MenuItem: TdxBarButton;
  pt: TPoint;
  BeginGroup: boolean;
  PopupMenu: TPopupMenu;
begin
  // pt := GetMouseCursorPos;
  // pt := ActiveControl.ScreenToClient(pt);

  pt := zControls.PopupPos;

  PopupMenu := TPopupMenu.Create(nil);
  try
    dx.PrepareSpellCheckerPopup(pt, PopupMenu);

    /// ////////////////

    for i := dxBarSubItemControlloOrtografico.ItemLinks.Count - 1 downto 0 do
    begin
      MenuItem := dxBarSubItemControlloOrtografico.ItemLinks[i].item as TdxBarButton;
      dxBarSubItemControlloOrtografico.ItemLinks.Delete(i);
      FreeAndNil(MenuItem);
    end;

    /// ////////////////

    for i := 0 to PopupMenu.items.Count - 1 do
    begin

      if PopupMenu.items[i].Caption = cLineCaption then
        BeginGroup := true
      else
      begin
        MenuItem := TdxBarButton.Create(dxBarSubItemControlloOrtografico.Owner);
        dxBarSubItemControlloOrtografico.ItemLinks.Add(MenuItem).BeginGroup := BeginGroup;
        BeginGroup := false;

        MenuItem.PaintStyle := psCaptionGlyph;
        MenuItem.Caption := PopupMenu.items[i].Caption;
        MenuItem.OnClick := PopupMenu.items[i].OnClick;
        MenuItem.Tag := PopupMenu.items[i].Tag;
      end;
    end;
  finally
    FreeAndNil(PopupMenu);
  end;

  dxBarSubItemControlloOrtografico.Visible := dx.Visible(dxBarSubItemControlloOrtografico.ItemLinks.Count > 0);
end;

procedure TzDbCard.FrameResize(Sender: TObject);
begin
  RealignToolbars;
end;

procedure TzDbCard.RealignToolbars;
var
  w1, w2: integer;
  Row: integer;
begin
  w1 := dx.dxBarRequiredWidth(dxBarToolbar);
  w2 := dx.dxBarRequiredWidth(dxBarToolbarFree);

  if w1 + w2 > Self.ClientWidth then
    Row := 1
  else
    Row := 0;

  if dxBarToolbarFree.Row <> Row then
    dxBarToolbarFree.Row := Row;
end;

procedure TzControl.AddCustomAction(Action: TBasicAction);
begin
  if Assigned(Action) then
    if not FCustomActions.ContainsKey(Action.name) then
      FCustomActions.Add(Action.name, Action);
end;

procedure TzControl.AssignControlProps(zControlProps: TzControlProps; zDomain: TzDomain);
begin

  // Campi preesistenti, per i quali esistono già le props al momento
  if Assigned(zControlProps) then
  begin
    DisplayLabel := zControlProps.DisplayLabel;
    Lines := zControlProps.Lines;
    ReadOnly := zControlProps.ReadOnly;
    Required := zControlProps.Required;
    ColSpan := zControlProps.ColSpan;
    Size := zControlProps.Size;
    Visible := zControlProps.Visible;
    zCtrlType := zControlProps.zCtrlType;
    Group := zControlProps.Group;

    if Assigned(zDomain) then // potrebbero essere non dataAware
    begin
      IdLookup := zDomain.Lookup;

      if DisplayLabel.IsEmpty then
        DisplayLabel := zDomain.DisplayLabel;

      if zCtrlType = ctDefault then
        zCtrlType := zDomain.zCtrlType;
    end;
  end;
end;

function TzControl.GetCustomAction(const name: string): TBasicAction;
begin
  if not FCustomActions.TryGetValue(Name, result) then
    result := nil;
end;

procedure TzControl.SetCustomAction(const name: string; const Value: TBasicAction);
begin
  if Value = nil then
    FCustomActions.Remove(Name)
  else
    FCustomActions.AddOrSetValue(Name, Value);
end;

function TzControl.GetCustomActions: TArray<TBasicAction>;
begin
  result := FCustomActions.Values.ToArray;
end;

function TzControl.HasCustomActions: boolean;
begin
  result := FCustomActions.Count > 0;
end;

procedure TzControl.LabelDblClick(Sender: TObject);
begin
  if CtrlKey then
    Self.Controls.Card.LabelDblClick;
end;

procedure TzControl.RebuildControls(zControlProps: TzControlProps; zDomain: TzDomain);
begin
  AssignControlProps(zControlProps, zDomain);
  DestroyControls;
  CreateControls;
end;

procedure TzDbCard.actPersonalizzaLookupExecute(Sender: TObject);
begin
  ModificaLookupProps; // entrambi chiamano la stessa proc (Personalizza/Nuovo lookup)
end;

procedure TzDbCard.actNuovoLookupExecute(Sender: TObject);
begin
  ModificaLookupProps; // entrmabi chiamano la stessa proc (Personalizza/Nuovo lookup)
end;

procedure TzDbCard.LoadCardFormSize;
var
  zFormCard: TzDbCardForm;
begin
  if (Owner is TzDbCardForm) then
  begin
    zFormCard := Owner as TzDbCardForm;

    zDbCardProps.DlgWidth := zFormCard.ClientWidth;
    zDbCardProps.DlgHeight := zFormCard.ClientHeight;
    FDlgSizeIs96dpi := false; // valori runtime: andranno descalati al salvataggio
  end;
end;

procedure TzDbCard.SaveCardFormSize;
var
  zFormCard: TzDbCardForm;
begin
  SiDbCard.EnterMethod(Self, 'SaveCardFormSize');

  if (Owner is TzDbCardForm) then
  begin
    zFormCard := Owner as TzDbCardForm;

    if (zDbCardProps.DlgWidth > 0) and (zFormCard.ClientWidth <> zDbCardProps.DlgWidth) then
    begin
      disableResize := true;
      try
        zFormCard.ClientWidth := zDbCardProps.DlgWidth;
        zFormCard.ClientHeight := zDbCardProps.DlgHeight;
        RefreshVisibility;
        // altrimenti UpdateHeight non avrà la larghezza corretta
      finally
        disableResize := false;
      end;
    end;
  end;

  SiDbCard.LeaveMethod(Self, 'SaveCardFormSize');
end;

function TzDbCard.GetDialogWidth: integer;
begin
  result := zDbCardProps.DlgWidth;

  // DlgWidth può trovarsi in unità 96-dpi dopo un salvataggio differito:
  // questo getter deve restituire pixel runtime (è usato per dimensionare
  // la form), quindi riconverte al volo.
  if FDlgSizeIs96dpi and (result > 0) then
    result := MulDiv(result, CurrentPPI, 96);

  if result = -1 then
    result := CalcSuggestedDialogWidth;

  if result = -1 then
  begin

    if zControls.Count = 1 then
      result := 300
    else
      if zControls.Count < 3 then
        result := 400
      else
        if zControls.Count < 10 then
          result := 500
        else
          if zControls.Count < 20 then
            result := 800
          else
            result := 1000;
  end;
end;

procedure TzDbCard.SetCardDlgWidth;
var
  zFormCard: TzDbCardForm;
begin
  if isResizing then
    Exit;

  if (Owner is TzDbCardForm) then
  begin
    zFormCard := Owner as TzDbCardForm;

    if (GetDialogWidth > 0) and (zFormCard.ClientWidth <> GetDialogWidth) then
    begin
      disableResize := true;
      try
        zFormCard.ClientWidth := GetDialogWidth;
      finally
        disableResize := false;
      end;
    end;
  end;
end;

procedure TzDbCard.SaveProperties;
begin
  if csDesigning in ComponentState then
    Exit;

  if zDbCardProps.DataSet = '' then
    zDbCardProps.DataSet := GetID_DataSet;

  // La parte sincrona (allineamento runtime → props) resta immediata,
  // così ogni lettore successivo dei props vede lo stato corrente.
  zControls.SaveToProps(zDbCardProps);
  LoadCardFormSize;

  // La parte costosa (descale DPI + scrittura su base in thread) è differita
  // e coalizzata via latch: una raffica di tick dello spinner produce UN solo
  // salvataggio invece di un thread per tick (con race su zDbCardProps
  // durante SaveToBase). Vedi DoDeferredSaveProperties.
  PostInternalMessage(cmd_SaveProperties);
end;

procedure TzDbCard.DescaleDlgSizeForSave;
begin
  // Converte DlgWidth/DlgHeight in unità 96-dpi UNA volta sola: il flag evita
  // il doppio descale quando LoadCardFormSize non ha potuto riallineare i
  // valori runtime (card embedded, Owner non TzDbCardForm).
  // NB: il layout non legge più questi valori a runtime (NewRowModel usa la
  // larghezza viva del frame), quindi possono restare in unità 96-dpi fino
  // al prossimo LoadProperties.
  if not FDlgSizeIs96dpi then
  begin
    zDbCardProps.DlgWidth := MulDiv(zDbCardProps.DlgWidth, 96, CurrentPPI);
    zDbCardProps.DlgHeight := MulDiv(zDbCardProps.DlgHeight, 96, CurrentPPI);
    FDlgSizeIs96dpi := true;
  end;
end;

procedure TzDbCard.DoDeferredSaveProperties;
var
  guard: IzCardAliveGuard;
begin
  if IsDestroying then
    Exit;

  if FSaveThreadRunning then
  begin
    // Un salvataggio è già in corso: ripeti a fine task (vedi TThread.Queue)
    FSaveQueued := true;
    Exit;
  end;

  DescaleDlgSizeForSave;

  // ITask invece di thread anonimo: il distruttore può attendere (Wait) un
  // salvataggio in volo prima di liberare zDbCardProps. La closure di Queue
  // cattura il guard refcounted e verifica Alive prima di toccare Self:
  // se la card muore tra il completamento del task e il dispatch della
  // Queue, il callback esce senza dereferenziare memoria liberata.
  guard := FAliveGuard;
  FSaveThreadRunning := true;
  FSaveTask := TTask.Run(
    procedure
    begin
      try
        InternalSaveProperties; // i props restano vivi: il distruttore attende il task
      finally
        TThread.Queue(nil,
          procedure
          begin
            if not guard.Alive then
              Exit; // card distrutta: nessun accesso a Self
            FSaveThreadRunning := false;
            if FSaveQueued then
            begin
              FSaveQueued := false;
              PostInternalMessage(cmd_SaveProperties);
            end;
          end);
      end;
    end);
end;

procedure TzDbCard.UpdateSavedLayoutCaption(const FieldName, NewCaption: string);
var
  lz: TzLayoutItem;
begin
  // Allinea la caption serializzata nel layout salvato: SaveToLayout la
  // riapplicherebbe al prossimo rebuild, annullando il rename fatto dal popup.
  lz := zDbCardProps.Layout.Get(NameForField(FieldName));
  if not Assigned(lz) then
    lz := zDbCardProps.Layout.Get(NameForGroup(FieldName));
  if Assigned(lz) then
    lz.Caption := NewCaption;
end;

function TzDbCard.NewRowModel: TzRowModel;
var
  w: integer;
begin
  // Preferisce la larghezza viva del frame: zDbCardProps.DlgWidth resta in
  // unità 96-dpi tra un SaveProperties e il LoadProperties successivo, e
  // comunque non riflette un eventuale resize manuale del dialogo.
  // Prima della visualizzazione (primo Build dentro LoadProperties) il frame
  // non è ancora dimensionato: lì DlgWidth (appena riscalato al monitor) è
  // il valore corretto.
  if Showing and (ClientWidth > 0) then
    w := ClientWidth
  else
    w := zDbCardProps.DlgWidth;
  result := TzRowModel.Create(w, Font);
end;

procedure TzDbCard.InternalSaveProperties;
begin

  if Assigned(FOnCustomSaveProps) then
    OnCustomSaveProps(Self)
  else
    if zSystemOk then
      zDbCardProps.SaveToBase(true);
end;

procedure TzDbCard.LoadProperties(const LoadFromBase: boolean = true);

  function ScaleToMonitorFont(const Value: integer; const maxValue: integer): integer;
  const
    SmallFontsPixelsPerInch = 96;
  var
    PixelsPerInch: integer;
  begin
    result := MulDiv(Value, Self.CurrentPPI, 96);
    result := Min(result, maxValue);
    Exit; { TODO : Eliminare il resto del codice }

    PixelsPerInch := Self.CurrentPPI;
    // 26.01.2024
    // result := MulDiv(Value, PixelsPerInch, SmallFontsPixelsPerInch);
    // 14.03.2024
    result := trunc((Value / SmallFontsPixelsPerInch) * PixelsPerInch);
    result := Min(result, maxValue);
  end;

begin
  if csDesigning in ComponentState then
    Exit;

  DestroyCustomControls;

  { TODO : Testare il flag CustomStore }
  // zSystem
  // evento di card
  //

  if zDbCardProps.DataSet = '' then
    zDbCardProps.DataSet := DataController.IdDataSet;

  if zDbCardProps.name = '' then
    zDbCardProps.name := DataController.IdDataSet;

  if LoadFromBase then
    InternalLoadProperties;

  // zz 14.03.2022
  simain.LogSeparator;
  simain.LogInteger('Pre - zDbCardProps.DlgWidth', zDbCardProps.DlgWidth);
  simain.LogInteger('Pre - zDbCardProps.DlgHeight', zDbCardProps.DlgHeight);

  zDbCardProps.DlgWidth := ScaleToMonitorFont(zDbCardProps.DlgWidth, ActiveMonitor.Width);
  zDbCardProps.DlgHeight := ScaleToMonitorFont(zDbCardProps.DlgHeight, ActiveMonitor.Height);
  FDlgSizeIs96dpi := false; // ora in unità runtime

  simain.LogInteger('Self.CurrentPPI', Self.CurrentPPI);
  simain.LogInteger('PixelsPerInch', PixelsPerInch);
  simain.LogInteger('Post - zDbCardProps.DlgWidth', zDbCardProps.DlgWidth);
  simain.LogInteger('Post - zDbCardProps.DlgHeight', zDbCardProps.DlgHeight);

  DataSource.AutoEdit := zDbCardProps.Flags.AutoEdit;
  SetTitle(zDbCardProps.Title);

  zDbCardProps.ButtonEdit.Apply(actDbEdit, dxBarButtonactDbEdit);
  zDbCardProps.ButtonDelete.Apply(actDbDelete, dxBarButtonactDbDelete);
  zDbCardProps.ButtonInsert.Apply(actDbInsert, dxBarButtonactDbInsert);

  IsCreatingControls := true;
  try
    zControls.LoadFromProps(zDbCardProps); // crea i controlli
  finally
    IsCreatingControls := false;
  end;

  RefreshVisibility;

  // Rigeneriamo la toolbar runtime (filtri poi azioni) dalle props appena ricaricate.
  // DisplayToolbars legge ToolActions.Count per la visibilita' di dxBarToolbarFree,
  // quindi DEVE girare dopo.
  RebuildToolbar;

  DisplayToolbars;

  LoadDescription;

  UpdateActions;

  SaveCardFormSize;
end;

procedure TzDbCard.InternalLoadProperties;
begin

  if Assigned(FOnCustomLoadProps) then
    OnCustomLoadProps(Self)
  else
    if zSystemOk then
      zDbCardProps.LoadFromBase
end;

procedure TzDbCard.OverrideCampoExecute(Sender: TObject);
var
  zControl: TzControl;
  OvItem: TOverrideItem;
  IsNew: boolean;
begin
  zControl := zControls.PopupCtrlItem;

  if not Assigned(zControl) then
    Exit;

  // Recupera l'override esistente o ne crea uno nuovo in memoria
  OvItem := Overrides.FindOverride(DataController.IdDataSet, zControl.name);
  IsNew := OvItem = nil;
  if IsNew then
    OvItem := Overrides.Add(DataController.IdDataSet, zControl.name);

  if zEditProperties([OvItem]) then
  begin
    Overrides.SaveItem(OvItem, zControls.zSystem.zFbDatabase);
    // Riapplica la caption aggiornata al controllo
    zControl.DisplayLabel := Overrides.CaptionCard(DataController.IdDataSet, zControl.name);
    if zControl.DisplayLabel.IsEmpty then
      zControl.DisplayLabel := zControl.DomainDisplayLabel;
  end
  else
    if IsNew then
      // Annullato e mai esistito: rimuove l'item appena aggiunto
      Overrides.Remove(OvItem);
end;

procedure TzDbCard.OverrideCampoUpdate(Sender: TObject);
begin
  OverrideCampo.Visible := IsAdmin;
end;

procedure TzDbCard.CopiaImpostazioniPerDXExecute(Sender: TObject);
begin
  if Assigned(DevExtremeSaveDbCard) then
    DevExtremeSaveDbCard(Self);
end;

procedure TzDbCard.CopiaImpostazioniPerDXUpdate(Sender: TObject);
begin
  CopiaImpostazioniPerDX.Visible := Assigned(DevExtremeSaveDbCard);
end;

function TzDbCard.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
begin
  result := nil;

  if not Assigned(Action) then
    Exit;

  result := zDbCardProps.ToolActions.Find(Action.name);

  if not Assigned(result) then
  begin
    result := zDbCardProps.ToolActions.Add;
    result.name := Action.name;
  end;

  result.FromCode := true;
end;

procedure TzDbCard.HideField(const FieldName: string);
var
  ctrl: TzControl;
begin
  ctrl := zControls.Find(FieldName);

  if Assigned(ctrl) then
  begin
    ctrl.Visible := false;

    if not zControls.FieldsHiddenByCode.Contains(FieldName) then
      zControls.FieldsHiddenByCode.Add(FieldName);
  end;
end;

procedure TzDbCard.ModificaLookupProps;

  function GetLookupFromMetaData(Field: TField): string;
  var
    zFbDataSet: TzFbDataSet;
    TableName: string;
  begin
    result := '';

    if Assigned(Field.DataSet) then
      if Field.DataSet is TzFbDataSet then
      begin
        zFbDataSet := TzFbDataSet(Field.DataSet);

        TableName := zFbDataSet.GetFieldTableName(Field);

        if not TableName.IsEmpty then
          result := zSystem.MetaData.GetLookup(TableName, Field.FieldName);
      end;
  end;

var
  item: TzControl;
  Domain: TzDomain;
  Field: TField;
  Lookup: TzLookup;
  Origin: string;
  s: string;
  tmpLookup: TzLookup;
  zDataSet: TzDataSet;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  if not DataController.TryGetField(item.name, Field) then
    Exit;

  Origin := DataController.GetFieldOrigin(Field);
  Domain := zSystem.zDataDictionary.Get(Origin);

  if not Assigned(Domain) then
    Exit;

  if (Domain.Lookup = '') or (not Assigned(zSystem.zLookups.Get(Domain.Lookup, false))) then
  begin
    s := GetLookupFromMetaData(Field);

    if Assigned(zSystem.zLookups.Get(s, false)) then
      Domain.Lookup := s // è stato trovato da metadata
    else
    begin

      if not GetNewLookupName(s) then
        Exit;

      if Assigned(zSystem.zLookups.Get(s, false)) then // attribuita ad esempio il nome di una FK esistente
        Domain.Lookup := s // è stato trovato da metadata
      else
      begin
        s := ValidateComponentName(s);

        StartWait('Attendere...', true);
        try
          tmpLookup := zSystem.zLookups.Add;
          tmpLookup.name := s;
          tmpLookup.IsForeignKey := false;
          tmpLookup.Exists := true;
          tmpLookup.DataSet := s;
          tmpLookup.DbCard := s;
          tmpLookup.DbView := s;
          tmpLookup.FieldNames := Field.FieldName;
          tmpLookup.FieldNamesFK := Field.FieldName;

          Domain.Lookup := s;
        finally
          StopWait;
        end;
      end;
    end;

    Domain.SaveToBase(true);
  end;

  /// ///////////////////////////////////////////////////////////

  Lookup := zSystem.zLookups.Get(Domain.Lookup);

  if not Assigned(Lookup) then
    Exit;

  /// ///////////////////////////////////////////////////////////

  tmpLookup := TzLookup.Create(nil);
  try
    tmpLookup.Assign(Lookup);

    if not tmpLookup.DataSet.IsEmpty then
      if tmpLookup.DataSet_Obj = nil then
      begin
        zDataSet := zSystem.zDataSets.Add;
        tmpLookup.DataSet_Obj := zDataSet;
        zDataSet.name := zDataSet.name;

        zDataSet.TableName := 'RDB$DATABASE';
        zDataSet.SQL_Select.Text := 'SELECT * FROM RDB$DATABASE';
      end;

    if Edit_CollectionItem(zSystem, tmpLookup) then
    begin
      StartWait('Attendere...', true);
      try
        zSystem.zLookups.SaveLookup(tmpLookup);

        if zSystem.zLookups.Exists(tmpLookup.name) then
        begin
          Domain.Lookup := tmpLookup.name;

          if not Domain.zCtrlType.IsLookup then
            Domain.zCtrlType := ctLookupExt;

          if not item.zCtrlType.IsLookup then
            if item.zCtrlType <> ctDefault then
            begin
              item.zCtrlType := ctLookupExt;
              SaveProperties;
            end;
        end;

        PostInternalMessage(cmd_SaveLookupToZip);
      finally
        StopWait;
      end;
    end;
  finally
    FreeAndNil(tmpLookup);
  end;
end;

procedure TzDbCard.actPersonalizzaPicklistExecute(Sender: TObject);
var
  item: TzControl;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
  i: integer;

  function EditPickList(var Domain: TzDomain): boolean;
  var
    items: TzPickValues;
  begin
    items := TzPickValues.Create(TzPickValue, 'PickValues', -1, nil);
    try
      items.Sorted := false;
      items.Assign(Domain.PickList_Obj.PickValues);
      result := EditComboItems(base, Domain.PickList_Obj.Description.Text, items);

      if result then
        Domain.PickList_Obj.PickValues.Assign(items);
    finally
      FreeAndNil(items);
    end;
  end;

begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  if not DataController.TryGetField(item.name, Field) then
    Exit;

  Origin := DataController.GetFieldOrigin(Field);
  Domain := zSystem.zDataDictionary.Get(Origin);

  if not Assigned(Domain) then
    Exit;

  if Domain.PickList.IsEmpty then
    Exit;

  if not Assigned(Domain.PickList_Obj) then
    Exit;

  if EditPickList(Domain) then
  begin
    StartWait('Attendere...', true);
    try
      zSystem.zPickLists.SavePickList(Domain.PickList_Obj);

      if zSystem.zPickLists.Exists(Domain.PickList) then
      begin

        if not Domain.zCtrlType.IsPicklist then
          if item.zCtrlType <> ctDefault then
          begin
            item.zCtrlType := ctPickListImage;
            SaveProperties;
          end;
      end;

      item.InitControlProperties;

      Application.ProcessMessages;
      PostInternalMessage(cmd_SavePickListToZip);
    finally
      StopWait;
    end;
  end;
end;

procedure TzDbCard.DescrizioneExecute(Sender: TObject);
begin

  if Descrizione.Checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzDbCard.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

procedure TzDbCard.LoadDescription;
begin

  if not Assigned(FrameDescription) then
    CreateDescription;

  zDbCardProps.Description.LoadFromIni(CardID);
  FrameDescription.zDescription := zDbCardProps.Description;
  Descrizione.Checked := zDbCardProps.Description.Visible;
end;

procedure TzDbCard.RebuildSingleControl;
var
  ctrlProps: TzControlProps;
begin

  if not FieldRebuildData.Valid then
    Exit;

  ctrlProps := zDbCardProps.Controls.Get(FieldRebuildData.zControl.name);

  FieldRebuildData.zControl.RebuildControls(ctrlProps, FieldRebuildData.Domain);

  RefreshVisibility;
end;

procedure TzDbCard.SaveDescription;
begin
  zDbCardProps.Description.Assign(FrameDescription.zDescription);
  zDbCardProps.Description.SaveToIni(CardID);
  Descrizione.Checked := zDbCardProps.Description.Visible;
end;

procedure TzDbCard.TFieldRebuildData.Clear;
begin
  zControl := nil;
  Domain := nil;
end;

function TzDbCard.TFieldRebuildData.Valid: boolean;
begin
  result := Assigned(zControl);
end;

procedure TzDbCard.ChangeScale(M, D: integer; isDpiChange: boolean);
begin
  inherited;
  if isDpiChange then
  begin
    // non serve RebuildControls qui: verrà chiamato da Resize
    // ma se la card è già visualizzata:
    if zControls.Count > 0 then
      PostInternalMessage(cmd_Resize);
  end;
end;

function TzDbCard.CalcDialogHeight(doDisplayControls: boolean = false): integer;
const
  TOOLBAR_MARGIN = 15;
var
  ToolbarHeight: integer;
  ContentH: integer;
begin
  if doDisplayControls then
    RefreshVisibility;

  // ContentBounds è public su TdxCustomLayoutControl.
  // Se il layout non è ancora stato calcolato il rect sarà vuoto (Height=0),
  // in quel caso usiamo una stima per numero di righe.
  ContentH := dxLayoutControl.ContentBounds.Height;

  if ContentH = 0 then
  begin
    // Fallback: stima prima del primo rendering
    // DEFAULT_ROW_HEIGHT = 46: caption(20) + controllo(20) + spacing(6)
    ContentH := dxLayoutControl.items.Count * 46;
  end;

  result := ContentH;

  // Altezza toolbar
  ToolbarHeight := 0;
  if Assigned(dxBarToolbar.Control) then
    Inc(ToolbarHeight, dxBarToolbar.Control.Height);
  if dxBarToolbarFree.Visible and (dxBarToolbarFree.Row >= 1) then
    if Assigned(dxBarToolbarFree.Control) then
      Inc(ToolbarHeight, dxBarToolbarFree.Control.Height);

  Inc(result, ToolbarHeight);
  Inc(result, TOOLBAR_MARGIN);
end;

// =============================================================================
// TzDbCard.ClearLayoutItems
// Rimuove dal dxLayoutControl solo gli item generati dal controller
// (GetFlagUserDefined = False). Stacca Control := nil prima del Free.
// =============================================================================
procedure TzDbCard.ClearLayoutItems;
// NB: gli item generati vengono liberati SENZA sganciare i controlli ospitati:
// la distruzione del TdxLayoutItem scollega il Control senza distruggerlo,
// e BuildLayoutItems (chiamato subito dopo, dentro BeginUpdate) lo riaggancia
// ai nuovi item.
var
  i: integer;

  procedure ClearGroup(grp: TdxLayoutGroup);
  var
    i: integer;
    item: TdxCustomLayoutItem;
  begin
    for i := grp.Count - 1 downto 0 do
    begin
      item := grp.items[i];

      if item is TdxLayoutGroup then
        ClearGroup(item as TdxLayoutGroup);

      if IsGeneratedByController(item) then
        item.Free;
    end;
  end;

begin
  if not Assigned(dxLayoutControl) then
    Exit;

  dxLayoutControl.BeginUpdate;
  try
    ClearGroup(dxLayoutControl.items);
  finally
    dxLayoutControl.EndUpdate;
  end;

{$IFDEF DEBUG}
  for i := 0 to dxLayoutControl.AbsoluteItemCount - 1 do
    if IsGeneratedByController(dxLayoutControl.AbsoluteItems[i]) then
    begin
      var
      msg := 'ClearLayoutItems: item ' + dxLayoutControl.AbsoluteItems[i].name + ' (' + dxLayoutControl.AbsoluteItems[i].classname + ') rimasto!';
      raise Exception.Create(msg);
    end;
{$ENDIF}
end;

procedure TzDbCard.LayoutEditorExecute(Sender: TObject);
begin
  OpenLayoutEditor;
end;

// =============================================================================
// TzDbCard.OpenLayoutEditor
// Apre l'editor visuale del TdxLayoutControl.
// =============================================================================
procedure TzDbCard.OpenLayoutEditor;
begin
  if FLayoutEditorClosing then
    Exit;

  dxLayoutControl.OnCustomization := OnLayoutCustomizeFormVisibleChanged;
  TzLayoutMaintenanceRegistry.RegisterHandler(dxLayoutControl, Self);
  dxLayoutControl.Customization := true;
end;

// =============================================================================
// TzDbCard.OnLayoutCustomizeFormVisibleChanged
// Fired sia all'apertura che alla chiusura dell'editor.
// =============================================================================
// TzDbCard - IzLayoutMaintenance
// Contratto di manutenzione layout risolto dalla TzLayoutCustomizeForm via
// TzLayoutMaintenanceRegistry (chiave = dxLayoutControl). Mappatura sui
// primitivi di TzDbCard: RebuildLayout = ricostruzione canonica,
// zDbCardProps.Layout = personalizzazioni salvate, SaveProperties = persistenza.
// =============================================================================
function TzDbCard.CanMaintainLayout: boolean;
begin
  result := (not IsDestroying) and Assigned(dxLayoutControl) and Assigned(zDbCardProps);
end;

procedure TzDbCard.ResetLayout;
begin
  if not CanMaintainLayout then
    Exit;

  if dxLayoutControl.Customization then
    // eseguita alla chiusura del form di customize (OnLayoutCustomizeFormVisibleChanged)
    FPendingMaintenanceOp := lmoReset
  else
    DoResetLayout;
end;

procedure TzDbCard.RepairLayout;
begin
  if not CanMaintainLayout then
    Exit;

  if dxLayoutControl.Customization then
    FPendingMaintenanceOp := lmoRepair
  else
    DoRepairLayout;
end;

procedure TzDbCard.ExecutePendingMaintenance;
var
  Op: TzLayoutMaintenanceOp;
begin
  Op := FPendingMaintenanceOp;
  FPendingMaintenanceOp := lmoNone;

  if not CanMaintainLayout then
    Exit;

  case Op of
    lmoReset:
      DoResetLayout;
    lmoRepair:
      DoRepairLayout;
  end;
end;

procedure TzDbCard.DoRepairLayout;
begin
  SiDbCard.EnterMethod(Self, 'DoRepairLayout');
  Screen.Cursor := crHourGlass;
  try
    // 1) sanifica i record incoerenti rimasti nel Layout salvato
    RepairLayoutProps(zDbCardProps.Layout);
    // 2) ricostruisce: struttura canonica + Layout sanificato
    RebuildLayout;
    // 3) persiste (SyncLayoutFromEditor non gira qui: RebuildLayout non
    // ricattura, quindi salviamo direttamente lo stato riparato)
    DescaleDlgSizeForSave;
    InternalSaveProperties;
  finally
    Screen.Cursor := crDefault;
    SiDbCard.LeaveMethod(Self, 'DoRepairLayout');
  end;
end;

procedure TzDbCard.RepairLayoutProps(Layout: TzLayoutItems);
// Rimuove i record incoerenti dal Layout salvato:
// a) generati dal controller risultati sganciati (ParentName='' / Idx=-1):
// dopo il fix di persistenza non dovrebbero piu' esistere, ma un blob
// legacy puo' ancora averne; eliminandoli torna la posizione canonica.
// b) record con ParentName non risolvibile (ne' tra i record, ne' canonico):
// i nomi canonici sono i generati presenti nel layout VIVO corrente.
var
  CanonicalNames, RecordNames: TDictionary<string, boolean>;
  i: integer;
  item: TzLayoutItem;
  Removed: boolean;

  function ParentResolvable(const ParentName: string): boolean;
  begin
    result := (ParentName = '') or RecordNames.ContainsKey(ParentName) or CanonicalNames.ContainsKey(ParentName);
  end;

begin
  SiDbCard.EnterMethod(Self, 'RepairLayoutProps');
  CanonicalNames := TDictionary<string, boolean>.Create;
  RecordNames := TDictionary<string, boolean>.Create;
  try
    // nomi canonici = item generati nel layout vivo (dopo l'ultimo build)
    for i := 0 to dxLayoutControl.AbsoluteItemCount - 1 do
      if IsGeneratedByController(dxLayoutControl.AbsoluteItems[i]) then
        CanonicalNames.AddOrSetValue(dxLayoutControl.AbsoluteItems[i].name, true);

    for i := 0 to Layout.Count - 1 do
      RecordNames.AddOrSetValue(Layout[i].name, true);

    // iterativo: rimuovere un record puo' invalidare i parent di altri
    repeat
      Removed := false;
      for i := Layout.Count - 1 downto 0 do
      begin
        item := Layout[i];

        if item.GeneratedByController and ((item.ParentName = '') or (item.idx = -1)) then
        begin
          SiDbCard.LogString('RepairLayoutProps.RemoveDetached', item.name);
          RecordNames.Remove(item.name);
          item.Free; // TCollectionItem.Free lo toglie dalla collection
          Removed := true;
          Continue;
        end;

        if not ParentResolvable(item.ParentName) then
        begin
          SiDbCard.LogString('RepairLayoutProps.RemoveUnresolvedParent', item.name + ' -> ' + item.ParentName);
          RecordNames.Remove(item.name);
          item.Free;
          Removed := true;
        end;
      end;
    until not Removed;
  finally
    FreeAndNil(RecordNames);
    FreeAndNil(CanonicalNames);
    SiDbCard.LeaveMethod(Self, 'RepairLayoutProps');
  end;
end;

// Alla chiusura (Customization = False) sincronizza le strutture e salva.
// =============================================================================
procedure TzDbCard.OnLayoutCustomizeFormVisibleChanged(Sender: TObject);
begin
  if dxLayoutControl.Customization then
    Exit; // si sta aprendo — non fare nulla

  if FLayoutEditorClosing then
    Exit; // guard anti-rientranza

  FLayoutEditorClosing := true;
  try
    // Se e' pendente una manutenzione, e' lei a gestire snapshot e persistenza:
    // il sync/salvataggio normale per il reset sarebbe inutile o dannoso.
    if FPendingMaintenanceOp = lmoNone then
      SyncLayoutFromEditor;
  finally
    FLayoutEditorClosing := false;
  end;

  // Op di manutenzione richieste durante la customizzazione: eseguite dopo
  // il rilascio del form di customize.
  if FPendingMaintenanceOp <> lmoNone then
    TThread.ForceQueue(nil, ExecutePendingMaintenance);
end;

// =============================================================================
// TzDbCard.SyncLayoutFromEditor
// Legge il layout attuale e aggiorna TzDbCardProps + salva.
// =============================================================================
// =============================================================================
// TzDbCard.SyncLayoutFromEditor
// Chiusura editor: legge struttura righe dal layout, aggiorna ColSpan e ordine
// dei TzControlProps, ricostruisce i ctLineBreak, salva.
// =============================================================================
procedure TzDbCard.SyncLayoutFromEditor;
var
  i, j: integer;
  rowGroup: TdxCustomLayoutItem;
  leaf: TdxCustomLayoutItem;
  fn: string;
  ctrlProps: TzControlProps;
  NewOrder: TList<TzControlProps>;
  AvailableLB: TList<TzControlProps>;
  IsFirstRow: boolean;
  RowModel: TzRowModel;
  pname: string;
  // Sincronizza Size e DisplayLabel di un campo dal suo TdxLayoutItem.
  // Usata da ProcessRow e dalla passata globale (campi dentro gruppi, tab
  // e gruppi utente che ProcessRow non visita); idempotente.
  procedure SyncLeafProps(ALeaf: TdxLayoutItem; cp: TzControlProps);
  var
    zCtrl: TzControl;
    LeafCaption: string;
    LeafField: string;
    NewSize: integer;
  begin
    LeafField := ExtractFieldNameFromLayoutItem(ALeaf.name);

    // Size dal Width attuale (peso proporzionale); con clLeft il Width
    // include la caption, quindi va sottratta per ottenere il Size puro.
    if zDbCardProps.CaptionLayout = clLeft then
      NewSize := Max(1, ALeaf.Width div RowModel.CharWidth - Length(ALeaf.Caption) - 1)
    else
      NewSize := Max(1, ALeaf.Width div RowModel.CharWidth);

    // Diagnostica drift: se il Size ricavato cambia SENZA che l'utente abbia
    // toccato nulla (apri/chiudi editor), il Width viene riscritto dalla
    // customize form e serve un fix dedicato (vedi note di review).
    if (cp.Size > 0) and (NewSize <> cp.Size) then
      SiDbCard.LogMessage(Format('SyncLeafProps %s: Size %d -> %d (Width=%d, CharWidth=%d)', [LeafField, cp.Size, NewSize, ALeaf.Width, RowModel.CharWidth]));
    cp.Size := NewSize;

    // Caption: baseline = DisplayLabel del DOMINIO (vedi note in ProcessRow);
    // gli override cliente prevalgono a runtime e non vanno toccati.
    LeafCaption := ALeaf.Caption;
    zCtrl := zControls.Find(LeafField);
    if not Overrides.OverrideExists(DataController.IdDataSet, LeafField, [ofCaptionCard]) then
    begin
      if Assigned(zCtrl) and SameText(LeafCaption, zCtrl.DomainDisplayLabel) then
        cp.DisplayLabel := ''
      else
        cp.DisplayLabel := LeafCaption;
    end;
  end;

// Calcola se ci sarebbe overflow naturale senza LineBreak
// (somma degli ingombri effettivi dei campi della riga già in NewOrder)
  function WouldOverflow(cp: TzControlProps): boolean;

    function Eff(p: TzControlProps): integer;
    var
      z: TzControl;
      dom: TzDomain;
      capLen: integer;
    begin
      // Stesse regole di BuildLayoutItems: fallback dominio, e con clLeft
      // l'ingombro include la caption. NB: usa p.Size (appena sincronizzato
      // dai Width dell'editor), non z.Size che è ancora pre-modifica.
      z := zControls.Find(p.name);
      dom := nil;
      if Assigned(z) then
        dom := z.Domain;

      capLen := 0;
      if zDbCardProps.CaptionLayout = clLeft then
      begin
        if p.DisplayLabel <> '' then
          capLen := Length(p.DisplayLabel)
        else
          if Assigned(z) then
            capLen := Length(z.DisplayLabel);
      end;

      result := RowModel.EffectiveSlot(p.Size, dom, capLen);
    end;

  var
    k: integer;
    sumSize: integer;
    p: TzControlProps;
  begin
    sumSize := 0;
    for k := NewOrder.Count - 1 downto 0 do
    begin
      p := NewOrder[k];
      if p.zCtrlType in [ctLineBreak, ctSeparator] then
        Break;
      Inc(sumSize, Eff(p));
    end;
    result := RowModel.Overflows(sumSize, Eff(cp));
  end;

  function GetOrCreateLineBreak: TzControlProps;
  begin
    if AvailableLB.Count > 0 then
    begin
      result := AvailableLB[0];
      AvailableLB.Delete(0);
    end
    else
    begin
      result := zDbCardProps.Controls.Add;
      result.name := zControls.UniqueName('LineBreak');
      result.zCtrlType := ctLineBreak;
      result.Visible := true;
    end;
  end;

  procedure ProcessRow(ARowGroup: TdxCustomLayoutItem; AIsFirstRow: boolean);
  var
    k: integer;
    isFirstInRow: boolean;
    cp: TzControlProps;
    zCtrl: TzControl;
    NewCaption: string;
  begin
    isFirstInRow := true;

    for k := 0 to dxLayoutControl.Container.AbsoluteItemCount - 1 do
    begin
      leaf := dxLayoutControl.Container.AbsoluteItems[k];

      if leaf.Parent <> ARowGroup then
        Continue;

      // GroupBox generati dal controller (grp_<campo>_<card>): sincronizza
      // Size (dal Width), caption e posizione nell'ordine dei props. Prima
      // venivano saltati: finivano accodati in fondo all'ordine e i
      // rename/resize fatti nell'editor andavano persi al rebuild.
      if leaf is TzDxFieldLayoutGroup then
      begin
        fn := ExtractFieldNameFromLayoutItem(leaf.name);
        if not fn.IsEmpty then
        begin
          cp := zDbCardProps.Controls.Get(fn);
          if Assigned(cp) then
          begin
            // Width del gruppo = peso assegnato da Build (Size * CharWidth)
            cp.Size := Max(1, TdxLayoutGroup(leaf).Width div RowModel.CharWidth);

            NewCaption := TdxLayoutGroup(leaf).Caption;
            zCtrl := zControls.Find(fn);
            if not Overrides.OverrideExists(DataController.IdDataSet, fn, [ofCaptionCard]) then
            begin
              if Assigned(zCtrl) and SameText(NewCaption, zCtrl.DomainDisplayLabel) then
                cp.DisplayLabel := ''
              else
                cp.DisplayLabel := NewCaption;
            end;

            // Persiste la disposizione: un gruppo che apre la riga torna ad
            // rpAuto (riga propria, tutta larghezza); uno che segue un altro
            // item resta affiancato (rpSameRow). Un rpForceNewLine esplicito
            // dell'utente che apre la riga non va declassato ad rpAuto.
            if not isFirstInRow then
              cp.RowPlacement := rpSameRow
            else
              // Primo della riga: se la riga non e' la prima e la rottura NON e'
              // spiegata dall'overflow naturale, e' una rottura "dura" ->
              // rpForceNewLine; altrimenti rpAuto. (Rimpiazza l'iniezione di
              // ctLineBreak.)
              if (not AIsFirstRow) and (not WouldOverflow(cp)) then
                cp.RowPlacement := rpForceNewLine
              else
                if cp.RowPlacement <> rpForceNewLine then
                  cp.RowPlacement := rpAuto;

            NewOrder.Add(cp);
            isFirstInRow := false;
          end;
        end;
        Continue;
      end;

      if not(leaf is TdxLayoutItem) then
        Continue;

      if not Assigned(TdxLayoutItem(leaf).Control) then
        Continue;

      fn := ExtractFieldNameFromLayoutItem(leaf.name);
      if fn.IsEmpty then
        Continue;

      cp := zDbCardProps.Controls.Get(fn);
      if not Assigned(cp) then
        Continue;

      // Size + DisplayLabel (baseline dominio, override rispettati):
      // logica condivisa con la passata globale.
      SyncLeafProps(TdxLayoutItem(leaf), cp);

      // Disposizione: il primo item della riga apre la riga; gli altri
      // proseguono (rpSameRow). Non declasso un rpForceNewLine esplicito.
      if not isFirstInRow then
        cp.RowPlacement := rpSameRow
      else
        // Primo della riga: rottura "dura" non spiegata da overflow ->
        // rpForceNewLine; altrimenti rpAuto.
        if (not AIsFirstRow) and (not WouldOverflow(cp)) then
          cp.RowPlacement := rpForceNewLine
        else
          if cp.RowPlacement <> rpForceNewLine then
            cp.RowPlacement := rpAuto;

      NewOrder.Add(cp);
      isFirstInRow := false;
    end;
  end;

begin
  SiDbCard.EnterMethod(Self, 'SyncLayoutFromEditor');
  RowModel := NewRowModel;
  try
    // 1. Salva struttura completa (gruppi, tab, emptyspace utente)
    zDbCardProps.Layout.LoadFromLayout(dxLayoutControl);

    // 2. Aggiorna ordine TzControlProps e ColSpan
    NewOrder := TList<TzControlProps>.Create;
    AvailableLB := TList<TzControlProps>.Create;
    try
      // Raccoglie LineBreak visibili riutilizzabili
      for i := 0 to zDbCardProps.Controls.Count - 1 do
      begin
        ctrlProps := zDbCardProps.Controls[i];
        if (ctrlProps.zCtrlType = ctLineBreak) and ctrlProps.Visible then
          AvailableLB.Add(ctrlProps);
      end;

      IsFirstRow := true;
      for i := 0 to dxLayoutControl.items.Count - 1 do
      begin
        rowGroup := dxLayoutControl.items.items[i];

        if rowGroup is TdxLayoutSeparatorItem then
        begin
          // Inserisce il prossimo ctSeparator disponibile
          for j := 0 to zDbCardProps.Controls.Count - 1 do
          begin
            ctrlProps := zDbCardProps.Controls[j];
            if (ctrlProps.zCtrlType = ctSeparator) and (NewOrder.IndexOf(ctrlProps) < 0) then
            begin
              NewOrder.Add(ctrlProps);
              Break;
            end;
          end;
          IsFirstRow := true;
          Continue;
        end;

        if rowGroup is TdxLayoutGroup then
        begin
          ProcessRow(rowGroup, IsFirstRow);
          IsFirstRow := false;
        end;
      end;

      // Passata globale su TUTTI i campi del layout: ProcessRow visita solo
      // i figli diretti delle righe root, quindi i campi dentro GroupBox,
      // tab e gruppi utente non venivano sincronizzati (Size e caption persi
      // al rebuild). Per i campi già visitati è idempotente.
      for i := 0 to dxLayoutControl.Container.AbsoluteItemCount - 1 do
      begin
        leaf := dxLayoutControl.Container.AbsoluteItems[i];
        if not(leaf is TdxLayoutItem) then
          Continue;
        if not Assigned(TdxLayoutItem(leaf).Control) then
          Continue;
        fn := ExtractFieldNameFromLayoutItem(leaf.name);
        if fn.IsEmpty then
          Continue;
        ctrlProps := zDbCardProps.Controls.Get(fn);
        if not Assigned(ctrlProps) then
          Continue;
        SyncLeafProps(TdxLayoutItem(leaf), ctrlProps);

        // Cattura la membership di gruppo in Controls (prima viveva solo nel
        // parent dx / nel Layout via li_*.ParentName). Rendendo Controls
        // autorevole, BuildLayoutItems ricolloca il campo nel gruppo giusto e
        // il Layout puo' non persistere i li_*.
        // - parent grprow_*_<grp> -> membership <grp>
        // - parent row_* root     -> membership '' (fuori dai gruppi)
        // - parent gruppo/tab UTENTE (non riga generata) -> non tocca cp.Group:
        // quei contenitori vivono nel Layout, non in Controls.
        if Assigned(leaf.Parent) then
        begin
          pname := leaf.Parent.name;
          if pname.StartsWith('grprow_') then
            ctrlProps.Group := ExtractGroupNameFromRowName(pname)
          else
            if pname.StartsWith('row_') then
              ctrlProps.Group := '';
          // altrimenti: contenitore utente, membership lasciata invariata
        end;
      end;

      // Appende campi non nel layout (nascosti) in fondo
      // I LineBreak avanzati vengono scartati
      for j := 0 to zDbCardProps.Controls.Count - 1 do
      begin
        ctrlProps := zDbCardProps.Controls[j];
        if NewOrder.IndexOf(ctrlProps) >= 0 then
          Continue;
        if ctrlProps.zCtrlType = ctLineBreak then
          Continue;
        NewOrder.Add(ctrlProps);
      end;

      // Applica il nuovo ordine
      for j := 0 to NewOrder.Count - 1 do
        NewOrder[j].Index := j;

    finally
      FreeAndNil(NewOrder);
      FreeAndNil(AvailableLB);
    end;

    // 3. Salva su DB (asincrono)
    SaveProperties;

    SiDbCard.LogColored(TColors.Green, 'SyncLayoutFromEditor: salvato');
  finally
    FreeAndNil(RowModel);
    SiDbCard.LeaveMethod(Self, 'SyncLayoutFromEditor');
  end;
end;

function TzDbCard.CalcSuggestedDialogWidth: integer;
// Larghezza ideale del dialogo: la riga ESPLICITA più larga (delimitata da
// LineBreak/Separator) deve starci senza wrap automatico. Prima usava il
// Size massimo del singolo campo, sottostimando le righe multi-campo.
const
  MIN_WIDTH = 400;
  MAX_WIDTH_RATIO = 0.75;
var
  Monitor: TMonitor;
  MaxAvailWidth: integer;
  item: TzControl;
  M: TzRowModel;
  RowSum, MaxRowSum: integer;
  capLen: integer;
begin
  Monitor := ActiveMonitor;
  MaxAvailWidth := Round(Monitor.Width * MAX_WIDTH_RATIO);

  // Modello con capacità = massimo disponibile a schermo: il clamp degli
  // EffectiveSlot scatta solo oltre ciò che comunque non ci starebbe.
  M := TzRowModel.Create(MaxAvailWidth, Font);
  try
    RowSum := 0;
    MaxRowSum := 0;
    for item in zControls do
    begin
      if not item.Visible then
        Continue;

      if item.zCtrlType in [ctLineBreak, ctSeparator] then
      begin
        MaxRowSum := Max(MaxRowSum, RowSum);
        RowSum := 0;
        Continue;
      end;

      if not item.Group.IsEmpty then
        Continue; // vive dentro il suo GroupBox, che ha un proprio Size

      capLen := 0;
      if zDbCardProps.CaptionLayout = clLeft then
        capLen := Length(item.DisplayLabel);

      Inc(RowSum, M.EffectiveSlot(item.Size, item.Domain, capLen));
    end;
    MaxRowSum := Max(MaxRowSum, RowSum);

    if MaxRowSum <= 0 then
      MaxRowSum := TzRowModel.FALLBACK_ROW_SIZE;

    result := MaxRowSum * M.CharWidth + TzRowModel.H_MARGIN + TzRowModel.VSCROLLBAR_WIDTH;
  finally
    M.Free;
  end;

  result := Max(result, MIN_WIDTH);
  result := Min(result, MaxAvailWidth);
  result := (result div 10) * 10;
end;

function TzDbCard.NameForField(const FieldName: string): string;
// TdxLayoutItem per un campo dati → 'li_CAMPO_CardName'
begin
  result := Format('li_%s_%s', [FieldName, Name]);
end;

function TzDbCard.NameForRow(const RowIndex: integer): string;
// Gruppo riga orizzontale → 'row_1_CardName'
begin
  result := Format('row_%d_%s', [RowIndex, Name]);
end;

function TzDbCard.NameForFiller(const RowIndex, ColUsed: integer): string;
// TdxLayoutEmptySpaceItem filler → 'fill_1_8_CardName'
begin
  result := Format('fill_%d_%d_%s', [RowIndex, ColUsed, Name]);
end;

function TzDbCard.NameForSep(const RowIndex: integer): string;
// TdxLayoutSeparatorItem → 'sep_1_CardName'
begin
  result := Format('sep_%d_%s', [RowIndex, Name]);
end;

function TzDbCard.NameForGroup(const FieldName: string): string;
// TdxLayoutGroup per ctGroupBox/ctCheckGroupBox → 'grp_CAMPO_CardName'
begin
  result := Format('grp_%s_%s', [FieldName, Name]);
end;

function TzDbCard.NameForGroupRow(const GrpName: string; RowIndex: integer): string;
// Riga orizzontale interna a un gruppo → 'grprow_1_grpAzienda_CardName'
begin
  result := Format('grprow_%d_%s_%s', [RowIndex, GrpName, Name]);
end;

function TzDbCard.NameForGroupFiller(const GrpName: string; RowIndex, ColUsed: integer): string;
// Filler interno a un gruppo → 'grpfill_1_8_grpAzienda_CardName'
begin
  result := Format('grpfill_%d_%d_%s_%s', [RowIndex, ColUsed, GrpName, Name]);
end;

function TzDbCard.ExtractGroupNameFromRowName(const RowName: string): string;
// Da 'grprow_<idx>_<grpName>_<card>' estrae <grpName>. '' se non è una riga
// interna a un gruppo (es. 'row_N_<card>' = riga root).
var
  s, Suffix, body: string;
  p: integer;
begin
  result := '';
  Suffix := '_' + Name;
  if not RowName.EndsWith(Suffix) then
    Exit;
  if not RowName.StartsWith('grprow_') then
    Exit;
  body := RowName.Substring(7, RowName.Length - 7 - Suffix.Length); // '<idx>_<grpName>'
  p := body.IndexOf('_');
  if p > 0 then
    result := body.Substring(p + 1);
end;

function TzDbCard.ExtractFieldNameFromLayoutItem(const ItemName: string): string;
// Estrae il FieldName da un nome item generato dal controller.
// Ritorna '' se il nome non è riconoscibile o non ha un FieldName
// (row_*, fill_*, sep_* → '').
var
  s, Suffix: string;
begin
  result := '';
  Suffix := '_' + Name;
  if not ItemName.EndsWith(Suffix) then
    Exit;
  s := ItemName.Substring(0, ItemName.Length - Suffix.Length);
  if s.StartsWith('li_') then
    result := s.Substring(3)
  else
    if s.StartsWith('grp_') then
      result := s.Substring(4);
end;

procedure TzDbCard.UpdateCheckGroupBoxes;
var
  item: TzControl;
  grpItem: TdxCustomLayoutItem;
  grp: TdxLayoutGroup;
  Field: TField;
begin
  if not DataController.IsActive then
    Exit;

  // Guard: l'assegnazione programmatica di Checked può scatenare
  // OnCheckBoxStateChanged, che chiamerebbe CheckEditMode mettendo il
  // dataset in edit a ogni scroll di record.
  FUpdatingCheckBoxes := true;
  try
    for item in zControls do
    begin
      if item.zCtrlType <> ctCheckGroupBox then
        Continue;

      grpItem := dxLayoutControl.FindItem(NameForGroup(item.name));
      if not Assigned(grpItem) then
        Continue;
      if not(grpItem is TdxLayoutGroup) then
        Continue;

      grp := TdxLayoutGroup(grpItem);

      if DataController.TryGetField(item.name, Field) then
        grp.ButtonOptions.CheckBox.Checked := Field.AsBoolean
      else
        grp.ButtonOptions.CheckBox.Checked := true; // default: abilitato
    end;
  finally
    FUpdatingCheckBoxes := false;
  end;
end;

procedure TzDbCard.OnCheckGroupBoxStateChanged(Sender: TObject);
var
  grp: TdxLayoutGroup;
  FieldName: string;
  Field: TField;
begin
  // Ignora gli eventi generati dal set programmatico di UpdateCheckGroupBoxes
  if FUpdatingCheckBoxes then
    Exit;

  if not(Sender is TdxLayoutGroup) then
    Exit;
  grp := TdxLayoutGroup(Sender);

  // Recupera il FieldName dal nome del gruppo
  FieldName := ExtractFieldNameFromLayoutItem(grp.name);
  if FieldName.IsEmpty then
    Exit;

  // Ignora se la card è readonly
  if IsCardReadOnly then
  begin
    // Ripristina il valore dal DB (annulla il click visivo)
    UpdateCheckGroupBoxes;
    Exit;
  end;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  DataController.CheckEditMode;
  Field.AsBoolean := grp.ButtonOptions.CheckBox.Checked;
end;

procedure TzDbCard.DoResetLayout;
var
  i: integer;
  ctrlProps: TzControlProps;
  Field: TField;
  item: TzControl;
  NewOrder: TList<TzControlProps>;
begin
  SiDbCard.EnterMethod(Self, 'DoResetLayout');
  try
    // 1. Azzera il layout salvato dall'editor
    zDbCardProps.Layout.Clear;

    // 2. Rimuove ctLineBreak e ctSeparator aggiunti manualmente
    for i := zDbCardProps.Controls.Count - 1 downto 0 do
    begin
      ctrlProps := zDbCardProps.Controls[i];
      if ctrlProps.zCtrlType in [ctLineBreak, ctSeparator] then
      begin
        zDbCardProps.Controls.Delete(i);
        Continue;
      end;
      // Resetta il Size al default del dominio (se disponibile)
      ctrlProps.Size := -1;
      // Resetta la disposizione di riga (rotture/affiancamenti sono
      // personalizzazioni da azzerare)
      ctrlProps.RowPlacement := rpAuto;
    end;

    // 3. Riordina TzControlProps seguendo l'ordine di DataController.Fields
    NewOrder := TList<TzControlProps>.Create;
    try
      for Field in DataController.Fields do
      begin
        ctrlProps := zDbCardProps.Controls.Get(Field.FieldName);
        if Assigned(ctrlProps) then
          NewOrder.Add(ctrlProps);
      end;
      // Appende eventuali campi non nel dataset (non data-aware: GroupBox etc.)
      for i := 0 to zDbCardProps.Controls.Count - 1 do
      begin
        ctrlProps := zDbCardProps.Controls[i];
        if NewOrder.IndexOf(ctrlProps) < 0 then
          NewOrder.Add(ctrlProps);
      end;
      // Applica il nuovo ordine
      for i := 0 to NewOrder.Count - 1 do
        NewOrder[i].Index := i;
    finally
      FreeAndNil(NewOrder);
    end;

    // 4. Riordina anche TzControls seguendo lo stesso ordine
    for i := 0 to zDbCardProps.Controls.Count - 1 do
    begin
      item := zControls.Find(zDbCardProps.Controls[i].name);
      if Assigned(item) then
        item.Index := i;
    end;

    // 5. Ricostruisce il layout da zero (basato su Size)
    ReloadFromProps(false);

    SiDbCard.LogColored(TColors.Green, 'DoResetLayout: completato');
  finally
    SiDbCard.LeaveMethod(Self, 'DoResetLayout');
  end;
end;

function TzDbCard.FindLayoutItem(const FieldName: string): TdxLayoutItem;
// Trova il TdxLayoutItem per un campo dati tramite il suo FieldName.
// Usa la funzione di naming centralizzata.
var
  dxItem: TdxCustomLayoutItem;
begin
  result := nil;
  dxItem := dxLayoutControl.FindItem(NameForField(FieldName));
  if Assigned(dxItem) and (dxItem is TdxLayoutItem) then
    result := TdxLayoutItem(dxItem);
end;

function TzDbCard.FindLayoutGroup(const GroupName: string): TdxLayoutGroup;
// Trova un TdxLayoutGroup per nome campo (ctGroupBox/ctCheckGroupBox).
// GroupName è il FieldName del ctGroupBox, non il nome dell'item layout.
var
  dxItem: TdxCustomLayoutItem;
begin
  result := nil;
  dxItem := dxLayoutControl.FindItem(NameForGroup(GroupName));
  if Assigned(dxItem) and (dxItem is TdxLayoutGroup) then
    result := TdxLayoutGroup(dxItem);
end;

procedure TzDbCard.ResetTabsToFirstPage;
var
  i: integer;
  dxItem: TdxCustomLayoutItem;
  grp: TdxLayoutGroup;
begin
  for i := 0 to dxLayoutControl.Container.AbsoluteItemCount - 1 do
  begin
    dxItem := dxLayoutControl.Container.AbsoluteItems[i];
    if not(dxItem is TdxLayoutGroup) then
      Continue;

    grp := TdxLayoutGroup(dxItem);
    if grp.LayoutDirection = ldTabbed then
      if grp.Count > 0 then
        grp.ItemIndex := 0;
  end;
end;

{ TzRowModel }

constructor TzRowModel.Create(const DlgWidth: integer; AFont: TFont = nil);
begin
  inherited Create;
  FCharWidth := FONT_WIDTH;
  FLineHeight := DEFAULT_LINE_HEIGHT;
  if Assigned(AFont) then
    MeasureFont(AFont);
  if DlgWidth > 0 then
    FRowMaxSize := Max(MIN_ROW_SIZE, (DlgWidth - H_MARGIN - VSCROLLBAR_WIDTH) div FCharWidth)
  else
    FRowMaxSize := FALLBACK_ROW_SIZE;
end;

procedure TzRowModel.MeasureFont(AFont: TFont);
var
  bmp: TBitmap;
begin
  // Larghezza media su una stringa campione (più stabile della singola
  // cifra con font proporzionali) e altezza riga dal font reale: le unità
  // «carattere» seguono così famiglia, corpo e DPI del frame invece della
  // costante 7px tarata su Segoe UI 10pt @ 96dpi.
  try
    bmp := TBitmap.Create;
    try
      bmp.Canvas.Font.Assign(AFont);
      FCharWidth := Max(4, bmp.Canvas.TextWidth('0123456789abcdefghij') div 20);
      FLineHeight := Max(12, bmp.Canvas.TextHeight('Ag') + 1);
    finally
      bmp.Free;
    end;
  except
    // misura fallita (handle/font non disponibili): restano i fallback
  end;
end;

function TzRowModel.EffectiveSize(const Size: integer; Domain: TzDomain): integer;
begin
  result := Size;
  if (result <= 0) and Assigned(Domain) then
    result := Domain.GetCtrlSize;
  if result <= 0 then
    result := DEFAULT_SIZE;
  if result > FRowMaxSize then
    result := FRowMaxSize;
end;

function TzRowModel.EffectiveSize(ctrl: TzControl): integer;
begin
  result := EffectiveSize(ctrl.Size, ctrl.Domain);
end;

function TzRowModel.EffectiveSlot(const Size: integer; Domain: TzDomain; const CaptionLen: integer): integer;
begin
  result := EffectiveSize(Size, Domain);
  if CaptionLen > 0 then
    Inc(result, CaptionLen + 1);
  if result > FRowMaxSize then
    result := FRowMaxSize;
end;

function TzRowModel.EffectiveSlot(ctrl: TzControl; const CaptionAtLeft: boolean): integer;
begin
  if CaptionAtLeft then
    result := EffectiveSlot(ctrl.Size, ctrl.Domain, Length(ctrl.DisplayLabel))
  else
    result := EffectiveSize(ctrl);
end;

function TzRowModel.Overflows(const AUsed, ASize: integer): boolean;
begin
  result := (AUsed + ASize) > FRowMaxSize;
end;

function TzRowModel.GroupCapacity(const AGroupSize: integer): integer;
begin
  result := Max(MIN_GROUP_ROW_SIZE, AGroupSize - (GRP_BORDER_MARGIN div FCharWidth));
end;

function TzRowModel.MinSlotPx(const SlotChars, CaptionLen: integer; const CaptionAtLeft: boolean): integer;
var
  floorChars: integer;
begin
  if CaptionAtLeft then
    floorChars := CaptionLen + MIN_EDIT_CHARS // la caption a sinistra non va tagliata
  else
    floorChars := MIN_EDIT_CHARS;
  // Mai sopra la dimensione naturale (un campo stretto non puo' avere min > slot):
  // questo tiene sum(MinWidth) <= sum(slot) <= RowMaxSize, da cui la garanzia.
  if floorChars > SlotChars then
    floorChars := SlotChars;
  result := Max(1, floorChars) * FCharWidth;
end;

{ TzCardAliveGuard }

constructor TzCardAliveGuard.Create;
begin
  inherited Create;
  FAlive := true;
end;

function TzCardAliveGuard.GetAlive: boolean;
begin
  result := FAlive;
end;

procedure TzCardAliveGuard.SetAlive(const Value: boolean);
begin
  FAlive := Value;
end;

// =============================================================================
// TzControls.BuildLayoutItems
// Costruisce il TdxLayoutControl basato su Size (larghezza in caratteri).
//
// ORDINE DI APPLICAZIONE:
// 1. ClearLayoutItems          → rimuove tutti gli item generati dal controller
// 2. Creazione gruppi          → ctGroupBox/ctCheckGroupBox (prima passata)
// 3. Creazione TdxLayoutItem   → un item per ogni TzControl visibile
// con dxItem.Width = ctrl.Size (peso proporzionale esatto).
// I campi raggruppati vengono disposti in righe orizzontali
// interne al TdxLayoutGroup del gruppo.
// 4. SaveToLayout              → applica struttura utente salvata
// =============================================================================
procedure TzControls.BuildLayoutItems(zDbCardProps: TzDbCardProps);
// Costanti e metriche di layout: TzRowModel (CharWidth/LineHeight misurati dal font del frame).
var
  lc: TdxLayoutControl;
  RowModel: TzRowModel;
  RowMaxSize: integer; // larghezza massima della riga root in unità Size
  PrevWasGroup: boolean; // l'ultimo item piazzato in riga root è un gruppo
  CurrentRowIsGroup: boolean; // la riga root corrente contiene gruppi (no filler)
  CurrentRow: TdxLayoutGroup;
  CurrentSizeUsed: integer; // somma dei Size nella riga corrente
  RowIndex: integer;

  // --- Naming helpers (delegano a Card) ---
  function ItemName(const FieldName: string): string;
  begin
    result := Card.NameForField(FieldName);
  end;

  function RowName: string;
  begin
    result := Card.NameForRow(RowIndex);
  end;

  function FillName: string;
  begin
    result := Card.NameForFiller(RowIndex, CurrentSizeUsed);
  end;

  function SepName: string;
  begin
    result := Card.NameForSep(RowIndex);
  end;

  function GrpName(const FieldName: string): string;
  begin
    result := Card.NameForGroup(FieldName);
  end;

// --- Gestione righe root ---
  procedure FlushRow;
  // Chiude la riga corrente. Una riga di CAMPI riceve un filler per assorbire
  // lo spazio residuo (i campi non devono stirarsi); una riga di GRUPPI no:
  // i gruppi sono ahClient e devono riempire la larghezza al 100% (o dividersi
  // proporzionalmente se affiancati). Il flag CurrentRowIsGroup distingue i due
  // casi, cosi' QUALUNQUE chiusura (finale, da campo o linebreak successivo)
  // rispetta la natura della riga. Questo risolve l'ultimo gruppo che restava
  // stretto perche' il FlushRow finale gli aggiungeva un filler.
  var
    filler: TdxLayoutEmptySpaceItem;
  begin
    if not Assigned(CurrentRow) then
      Exit;
    if (not CurrentRowIsGroup) and (CurrentSizeUsed < RowMaxSize) then
    begin
      filler := lc.CreateItem(TzDxLayoutEmptySpaceItem) as TdxLayoutEmptySpaceItem;
      filler.name := FillName;
      filler.Parent := CurrentRow;
      filler.AlignHorz := ahClient;
      filler.Width := (RowMaxSize - CurrentSizeUsed) * RowModel.CharWidth;
      filler.SetFlagUserDefined(false);
    end;
    CurrentRow := nil;
    CurrentSizeUsed := 0;
    CurrentRowIsGroup := false;
    // NB: nessun Inc(RowIndex) qui — lo fa EnsureRow alla creazione della riga
    // (uno per riga). Il doppio incremento desincronizzava i nomi di righe e
    // filler.
  end;

  function EnsureRow: TdxLayoutGroup;
  begin
    if not Assigned(CurrentRow) then
    begin
      Inc(RowIndex);
      CurrentRowIsGroup := false; // default: riga di campi (il branch gruppo la rimarca)
      CurrentRow := lc.CreateItem(TzDxLayoutGroup) as TdxLayoutGroup;
      CurrentRow.name := RowName;
      CurrentRow.Parent := lc.items;
      CurrentRow.LayoutDirection := ldHorizontal;
      CurrentRow.ShowBorder := false;
      CurrentRow.CaptionOptions.Visible := false;
      CurrentRow.AlignHorz := ahClient;
      CurrentRow.AlignVert := avTop;
      // Disabilita l'allineamento automatico delle caption nella riga:
      // con clLeft + catDefault il motore ignora Width proporzionale.
      // catNone permette a Width di funzionare come peso.
      CurrentRow.ItemControlAreaAlignment := catNone;
      CurrentRow.SetFlagUserDefined(false);
    end;
    result := CurrentRow;
  end;

// --- Stato righe interne ai gruppi ---
var
  GroupStates: TObjectDictionary<string, TGroupRowState>;

  procedure FlushGroupRow(gs: TGroupRowState);
  var
    filler: TdxLayoutEmptySpaceItem;
  begin
    if not Assigned(gs.GrpCurrentRow) then
      Exit;
    if gs.GrpSizeUsed < gs.GrpMaxSize then
    begin
      filler := lc.CreateItem(TzDxLayoutEmptySpaceItem) as TdxLayoutEmptySpaceItem;
      filler.name := Card.NameForGroupFiller(gs.GrpCtrlName, gs.GrpRowIndex, gs.GrpSizeUsed);
      filler.Parent := gs.GrpCurrentRow;
      filler.AlignHorz := ahClient;
      // Peso = capacità residua della riga interna (vedi FlushRow)
      filler.Width := (gs.GrpMaxSize - gs.GrpSizeUsed) * RowModel.CharWidth;
      filler.SetFlagUserDefined(false);
    end;
    gs.GrpCurrentRow := nil;
    gs.GrpSizeUsed := 0;
  end;

  function EnsureGroupRow(gs: TGroupRowState): TdxLayoutGroup;
  begin
    if not Assigned(gs.GrpCurrentRow) then
    begin
      Inc(gs.GrpRowIndex);
      gs.GrpCurrentRow := lc.CreateItem(TzDxLayoutGroup) as TdxLayoutGroup;
      gs.GrpCurrentRow.name := Card.NameForGroupRow(gs.GrpCtrlName, gs.GrpRowIndex);
      gs.GrpCurrentRow.Parent := gs.ParentGroup;
      gs.GrpCurrentRow.LayoutDirection := ldHorizontal;
      gs.GrpCurrentRow.ShowBorder := false;
      gs.GrpCurrentRow.CaptionOptions.Visible := false;
      gs.GrpCurrentRow.AlignHorz := ahClient;
      gs.GrpCurrentRow.AlignVert := avTop;
      gs.GrpCurrentRow.ItemControlAreaAlignment := catNone;
      gs.GrpCurrentRow.SetFlagUserDefined(false);
    end;
    result := gs.GrpCurrentRow;
  end;

  function GetOrCreateGroupState(const GroupName: string): TGroupRowState;
  var
    dxGrpItem: TdxCustomLayoutItem;
    grpCtrl: TzControl;
  begin
    if not GroupStates.TryGetValue(GroupName, result) then
    begin
      result := TGroupRowState.Create;
      result.GrpCtrlName := GroupName;
      dxGrpItem := lc.FindItem(Card.NameForGroup(GroupName));
      if Assigned(dxGrpItem) and (dxGrpItem is TdxLayoutGroup) then
        result.ParentGroup := TdxLayoutGroup(dxGrpItem)
      else
        result.ParentGroup := nil;
      result.GrpCurrentRow := nil;
      result.GrpSizeUsed := 0;
      result.GrpRowIndex := 0;

      // Capacità delle righe interne = larghezza del GroupBox in caratteri,
      // non quella del dialogo: prima i campi nei gruppi stretti non andavano
      // mai a capo e venivano schiacciati dalla distribuzione proporzionale.
      result.GrpMaxSize := RowMaxSize;
      if Assigned(result.ParentGroup) then
      begin
        grpCtrl := Find(GroupName);
        if Assigned(grpCtrl) then
          result.GrpMaxSize := RowModel.GroupCapacity(RowModel.EffectiveSize(grpCtrl));
      end;

      GroupStates.Add(GroupName, result);
    end;
  end;

// --- Size e Height ---
  function ResolveSize(ctrl: TzControl): integer;
  begin
    result := RowModel.EffectiveSize(ctrl);
  end;

  function ResolveHeight(ctrl: TzControl): integer;
  begin
    // LineHeight misurato dal font reale del frame (segue corpo e DPI),
    // non più la costante 18px tarata su 96dpi.
    if ctrl.Lines > 1 then
      result := (ctrl.Lines * RowModel.LineHeight) + TzRowModel.EDIT_BORDER_PX
    else
      result := 0;
  end;

// --- Separatore ---
  procedure AddSeparator;
  var
    sep: TdxLayoutSeparatorItem;
  begin
    FlushRow;
    Inc(RowIndex);
    sep := lc.CreateItem(TzDxLayoutSeparatorItem) as TdxLayoutSeparatorItem;
    sep.name := SepName;
    sep.Parent := lc.items;
    sep.AlignHorz := ahClient;
    sep.SetFlagUserDefined(false);
  end;

// --- Aggiunge un TdxLayoutItem dentro un parent ---
  procedure AddFieldItem(ctrl: TzControl; EffectiveSize: integer; ParentGroup: TdxLayoutGroup);
  var
    dxItem: TdxLayoutItem;
    h: integer;
    isNormalRow: boolean;
    countedInGroup: boolean;
    slotSize: integer;
    gs: TGroupRowState;
  begin
    // Ingombro in riga: con clLeft la caption occupa la colonna a sinistra
    // del controllo, quindi va conteggiata nel wrap e nei residui (il peso
    // dx, vedi sotto, la include già; prima la contabilità no, e le righe
    // risultavano visivamente sovraffollate con caption a sinistra).
    slotSize := EffectiveSize;
    if zDbCardProps.CaptionLayout = clLeft then
      Inc(slotSize, Length(ctrl.DisplayLabel) + 1);
    if slotSize > RowMaxSize then
      slotSize := RowMaxSize;

    // Campo raggruppato: crea righe interne al gruppo
    if not ctrl.Group.IsEmpty then
    begin
      gs := GetOrCreateGroupState(ctrl.Group);
      if Assigned(gs.ParentGroup) then
      begin
        // La capacità è quella del gruppo, non della riga root
        if EffectiveSize > gs.GrpMaxSize then
          EffectiveSize := gs.GrpMaxSize;
        if slotSize > gs.GrpMaxSize then
          slotSize := gs.GrpMaxSize;
        // rpForceNewLine: forza una nuova riga interna al gruppo (rimpiazza il
        // vecchio ctLineBreak con Group). Altrimenti auto-wrap su capacita'.
        if Assigned(gs.GrpCurrentRow) and ((ctrl.RowPlacement = rpForceNewLine) or (gs.GrpSizeUsed + slotSize > gs.GrpMaxSize)) then
          FlushGroupRow(gs);
        ParentGroup := EnsureGroupRow(gs);
      end;
      // Se il gruppo non è stato trovato, ParentGroup resta quello passato (fallback)
    end;

    isNormalRow := not Assigned(ParentGroup);

    if isNormalRow then
    begin
      if Assigned(CurrentRow) and (CurrentSizeUsed + slotSize > RowMaxSize) then
        FlushRow;
      ParentGroup := EnsureRow;
    end;

    dxItem := lc.CreateItem(TzDxFieldLayoutItem) as TdxLayoutItem;
    dxItem.name := ItemName(ctrl.name);
    dxItem.Parent := ParentGroup;
    dxItem.Caption := ctrl.DisplayLabel;
    dxItem.CaptionOptions.Visible := true;
    dxItem.CaptionOptions.Layout := zDbCardProps.CaptionLayout;
    dxItem.AlignHorz := ahClient;

    // Width = peso proporzionale: con clLeft la caption occupa spazio
    // a sinistra del controllo, quindi il peso totale è Size + lunghezza caption.
    // Con clTop la caption sta sopra, il peso è solo il Size.
    if zDbCardProps.CaptionLayout = clLeft then
      dxItem.Width := (EffectiveSize + Length(ctrl.DisplayLabel) + 1) * RowModel.CharWidth
    else
      dxItem.Width := EffectiveSize * RowModel.CharWidth;

    // MinWidth controllato sull'AREA CONTROLLO (ControlOptions.MinWidth, px):
    // è il minimo sotto cui l'item ahClient non si comprime e che determina
    // la comparsa della scrollbar orizzontale. Il default DevExpress è 20px
    // (dxLayoutItemControlDefaultMinWidth): troppo alto e fuori dal nostro
    // controllo, era la causa per cui i campi non si stringevano. Impostandolo
    // dal modello, la somma dei minimi di riga resta <= RowMaxSize*CharWidth
    // <= client e la scrollbar non compare; quando il minimo non basta, il
    // reflow (CheckReflow) manda il campo a capo.
    // NB: ControlOptions.MinWidth è la sola area controllo; con clLeft la
    // caption ha colonna propria, quindi qui NON va inclusa (a differenza del
    // peso Width e dello slot di wrap).
    dxItem.ControlOptions.MinWidth := RowModel.MinSlotPx(EffectiveSize, 0, false);

    dxItem.Visible := ctrl.Visible;
    dxItem.SetFlagUserDefined(false);

    h := ResolveHeight(ctrl);
    if h > 0 then
    begin
      dxItem.AlignVert := avTop;
      dxItem.Height := h;
    end;

    if Assigned(ctrl.cxCustomEdit) then
      dxItem.Control := ctrl.cxCustomEdit
    else
      if Assigned(ctrl.Control) then
        dxItem.Control := ctrl.Control;

    countedInGroup := false;
    if not ctrl.Group.IsEmpty then
    begin
      gs := GetOrCreateGroupState(ctrl.Group);
      if Assigned(gs.ParentGroup) then
      begin
        Inc(gs.GrpSizeUsed, slotSize);
        if gs.GrpSizeUsed >= gs.GrpMaxSize then
          FlushGroupRow(gs);
        countedInGroup := true;
      end;
    end;

    // Comprende il fallback: un campo con Group il cui gruppo non esiste
    // viene collocato nella riga normale e va conteggiato lì, altrimenti
    // la riga non si riempie mai e il wrapping salta.
    if (not countedInGroup) and isNormalRow then
    begin
      Inc(CurrentSizeUsed, slotSize);
      if CurrentSizeUsed >= RowMaxSize then
        FlushRow;
    end;
  end;

// --- PRIMA PASSATA: crea TdxLayoutGroup per ctGroupBox/ctCheckGroupBox ---
  procedure CreateGroupForControl(ctrl: TzControl);
  // Prima passata: crea solo il TdxLayoutGroup parcheggiato sotto lc.Items.
  // Il posizionamento in riga avviene nella seconda passata.
  // TzDxFieldLayoutGroup: il Width (derivato da Size) non viene serializzato
  // né sovrascritto da SaveToLayout (vedi invariante in zLayouts).
  var
    grp: TdxLayoutGroup;
  begin
    grp := lc.CreateItem(TzDxFieldLayoutGroup) as TdxLayoutGroup;
    grp.name := GrpName(ctrl.name);
    grp.Parent := lc.items;
    grp.ShowBorder := true;
    grp.Caption := ctrl.DisplayLabel;
    grp.AlignHorz := ahClient;
    grp.AlignVert := avTop;
    grp.SetFlagUserDefined(false);

    if ctrl.zCtrlType = ctCheckGroupBox then
    begin
      grp.ButtonOptions.CheckBox.Visible := true;
      grp.ButtonOptions.CheckBox.CheckAction := cbaToggleChildrenEnabledState;
      grp.ButtonOptions.CheckBox.Checked := true; // aggiornato da UpdateCheckGroupBoxes
      grp.OnCheckBoxStateChanged := Card.OnCheckGroupBoxStateChanged;
    end;
  end;

  procedure ApplyCaptionLayout;
  var
    i: integer;
    dxItem: TdxCustomLayoutItem;
  begin
    for i := 0 to lc.Container.AbsoluteItemCount - 1 do
    begin
      dxItem := lc.Container.AbsoluteItems[i];
      if dxItem is TzDxLayoutItem then
        TdxLayoutItem(dxItem).CaptionOptions.Layout := zDbCardProps.CaptionLayout;
    end;
  end;

var
  item: TzControl;
  EffectiveSize: integer;
  dxGrp: TdxCustomLayoutItem;
  gs: TGroupRowState;
  gsPair: TPair<string, TGroupRowState>;
begin
  lc := Card.dxLayoutControl;

  // Modello di riga unico (capacità, EffectiveSize, overflow): stesse regole
  // di AdjustRowForColSpan e SyncLayoutFromEditor. Usa la larghezza viva del
  // frame quando disponibile (vedi TzDbCard.NewRowModel).
  RowModel := Card.NewRowModel;
  RowMaxSize := RowModel.RowMaxSize;
  Card.FLastBuildRowMax := RowMaxSize; // riferimento per CheckReflow

  Card.ClearLayoutItems;

  GroupStates := TObjectDictionary<string, TGroupRowState>.Create([doOwnsValues]);
  try
    lc.BeginUpdate;
    try
      CurrentRow := nil;
      CurrentSizeUsed := 0;
      RowIndex := 0;

      // ==============================================================
      // PRIMA PASSATA: crea TdxLayoutGroup per ctGroupBox/ctCheckGroupBox
      // ==============================================================
      for item in Self do
      begin
        if not item.Visible then
          Continue;
        if item.zCtrlType = ctSeparator then
          Continue;
        if item.zCtrlType = ctLineBreak then
          Continue;
        if not item.Group.IsEmpty then
          Continue;

        if item.zCtrlType in [ctGroupBox, ctCheckGroupBox] then
          CreateGroupForControl(item);
      end;

      // Reset contatori per la seconda passata
      FlushRow;
      CurrentRow := nil;
      CurrentSizeUsed := 0;
      RowIndex := 0;
      PrevWasGroup := false;
      CurrentRowIsGroup := false;

      // ==============================================================
      // SECONDA PASSATA: crea TdxLayoutItem per tutti i campi dati
      // ==============================================================
      for item in Self do
      begin
        if item.zCtrlType = ctSeparator then
        begin
          AddSeparator;
          PrevWasGroup := false;
          Continue;
        end;

        if item.zCtrlType = ctLineBreak then
        begin
          if item.Visible then
          begin
            // LineBreak con Group: flush della riga interna al gruppo
            if not item.Group.IsEmpty then
            begin
              if GroupStates.TryGetValue(item.Group, gs) then
                FlushGroupRow(gs);
            end
            else
            begin
              FlushRow;
              PrevWasGroup := false;
            end;
          end;
          Continue;
        end;

        // ctGroupBox/ctCheckGroupBox: posiziona il gruppo (già creato nella prima
        // passata) dentro la riga corrente della seconda passata.
        if item.zCtrlType in [ctGroupBox, ctCheckGroupBox] then
        begin
          if not item.Visible then
            Continue;
          EffectiveSize := ResolveSize(item);
          dxGrp := lc.FindItem(GrpName(item.name));
          if Assigned(dxGrp) and (dxGrp is TdxLayoutGroup) then
          begin
            // Default: un gruppo occupa una riga propria a TUTTA larghezza.
            // Affiancamento all'altro gruppo solo se l'utente l'ha disposto
            // Affianca al precedente (gruppo O campo, es. Foto + gruppi) SOLO se
            // l'utente l'ha disposto cosi' (RowPlacement = rpSameRow). Default
            // rpAuto per un gruppo = riga propria a tutta larghezza.
            if (item.RowPlacement = rpSameRow) and Assigned(CurrentRow) and (CurrentSizeUsed > 0) then
            begin
              // NESSUN vincolo di capacita': il Size del gruppo (130 = "pieno")
              // e' un peso, non una larghezza; i gruppi affiancati si dividono la
              // riga in proporzione ai Width. Niente filler: marca riga di gruppo.
              dxGrp.Parent := CurrentRow;
              TdxLayoutGroup(dxGrp).Width := EffectiveSize * RowModel.CharWidth;
              Inc(CurrentSizeUsed, EffectiveSize);
              CurrentRowIsGroup := true;
            end
            else
            begin
              // Chiudi la riga pendente (FlushRow mette il filler solo se era
              // una riga di campi) e apri una riga dedicata al gruppo.
              FlushRow;
              EnsureRow;
              CurrentRowIsGroup := true; // questa riga non avra' filler
              dxGrp.Parent := CurrentRow;
              // Width = peso: da solo sulla riga ahClient riempie il 100%;
              // serve per dividere proporzionalmente in caso di affiancamento.
              TdxLayoutGroup(dxGrp).Width := EffectiveSize * RowModel.CharWidth;
              CurrentSizeUsed := EffectiveSize;
            end;
            PrevWasGroup := true;
          end;
          Continue;
        end;

        if not item.Visible then
          Continue;
        if (item.cxCustomEdit = nil) and (item.Control = nil) then
          Continue;

        EffectiveSize := ResolveSize(item);

        // Campo con Group: va dentro il suo TdxLayoutGroup (via righe interne)
        if not item.Group.IsEmpty then
        begin
          AddFieldItem(item, EffectiveSize, nil);
          Continue;
        end;

        // Campo normale.
        // - se la riga corrente e' di gruppi, chiudila prima (FlushRow non mette
        // filler perche' CurrentRowIsGroup) cosi' il campo non ci finisce dentro;
        // - RowPlacement = rpForceNewLine forza una nuova riga (equivalente a un
        // LineBreak davanti, ma per-campo);
        // - rpAuto/rpSameRow: i campi FLUISCONO (auto-wrap quando la riga e' piena).
        if CurrentRowIsGroup then
          FlushRow
        else
          if (item.RowPlacement = rpForceNewLine) and Assigned(CurrentRow) and (CurrentSizeUsed > 0) then
            FlushRow;
        AddFieldItem(item, EffectiveSize, nil);
        PrevWasGroup := false;
      end;

      FlushRow;

      // Flush delle righe interne a tutti i gruppi
      for gsPair in GroupStates do
        FlushGroupRow(gsPair.Value);

      // Ripristina struttura salvata dall'editor
      if zDbCardProps.Layout.Count > 0 then
        zDbCardProps.Layout.SaveToLayout(lc);

      // Garantisce l'allineamento automatico delle caption con clLeft.
      // Valore di default True, reso esplicito per chiarezza.

      ApplyCaptionLayout;

      lc.OptionsItem.AutoControlAreaAlignment := true;

      // Belt: nessuno scroll orizzontale a livello root (la garanzia primaria
      // resta il calcolo congruo dei ControlOptions.MinWidth + reflow).
      lc.items.ScrollOptions.Horizontal := smNone;

      SiDbCard.LogMessage(Format('BuildLayoutItems: %d righe root, RowMaxSize=%d, CharWidth=%d, LineHeight=%d', [RowIndex, RowMaxSize, RowModel.CharWidth, RowModel.LineHeight]));

    finally
      lc.EndUpdate;
    end;

    // Sincronizza stato checkbox con valore DB
    Card.UpdateCheckGroupBoxes;

    // Reset tab alla prima pagina
    Card.ResetTabsToFirstPage;

  finally
    FreeAndNil(GroupStates);
    FreeAndNil(RowModel);
  end;
end;

// =============================================================================
// TzDbCard.AdjustRowForColSpan
//
// Dopo una variazione di ColSpan su un controllo, bilancia la riga logica nei
// TzControlProps:
//
// OVERFLOW (sommaRiga > ColCount):
// • se il prop precedente non è già un ctLineBreak, inserisce un
// ctLineBreak immediatamente prima del controllo
// • se il ColSpan da solo supera ColCount, lo clampa a ColCount
//
// RIENTRO (sommaRiga ≤ ColCount):
// • se il prop precedente è un ctLineBreak, verifica se unendo la riga
// precedente con quella corrente si supera ColCount; se non si supera,
// rimuove il LineBreak (le due righe si fondono)
// =============================================================================
procedure TzDbCard.AdjustRowForColSpan(item: TzControl);
// Dopo una modifica di Size su "item", ricalcola se la sua riga logica
// va in overflow (somma Size > RowMaxSize) o se un LineBreak precedente
// è diventato superfluo (rientro).
var
  RowModel: TzRowModel;
  RowMaxSize: integer;
  idx: integer;
  i: integer;
  ctrl: TzControl;
  CurrentSizeUsed: integer;
  rowStart: integer;
  sumSize: integer;
  prevLBIdx: integer;
  prevRowStart: integer;
  prevRowSumSize: integer;

  function SafeSize(ctrl: TzControl): integer;
  begin
    // Stesse regole di BuildLayoutItems (fallback dominio incluso): prima il
    // fallback fisso 20 divergeva da ResolveSize e i LineBreak inseriti qui
    // non corrispondevano alle righe effettivamente costruite.
    result := RowModel.EffectiveSize(ctrl);
  end;

  procedure SetRowPlacementOf(ctrl: TzControl; Value: TControlRowPlacement);
  var
    cp: TzControlProps;
  begin
    if ctrl.RowPlacement = Value then
      Exit;
    ctrl.RowPlacement := Value;
    cp := zDbCardProps.Controls.Get(ctrl.name);
    if Assigned(cp) then
      cp.RowPlacement := Value; // persiste (SetRowPlacement -> Modified)
  end;

begin
  RowModel := NewRowModel;
  try
    RowMaxSize := RowModel.RowMaxSize;

    idx := zControls.IndexOf(item);
    if idx < 0 then
      Exit;

    CurrentSizeUsed := 0;
    rowStart := 0;
    sumSize := 0;
    prevLBIdx := -1;
    prevRowStart := 0;
    prevRowSumSize := 0;

    for i := 0 to idx do
    begin
      ctrl := zControls[i];

      if ctrl.zCtrlType in [ctLineBreak, ctSeparator] then
      begin
        prevRowSumSize := CurrentSizeUsed;
        prevRowStart := rowStart;
        prevLBIdx := i;
        rowStart := i + 1;
        CurrentSizeUsed := 0;
        Continue;
      end;

      if not ctrl.Visible then
        Continue;

      Inc(CurrentSizeUsed, SafeSize(ctrl));

      if (i < idx) and (CurrentSizeUsed >= RowMaxSize) then
      begin
        prevRowSumSize := CurrentSizeUsed;
        prevRowStart := rowStart;
        prevLBIdx := -1;
        rowStart := i + 1;
        CurrentSizeUsed := 0;
      end;
    end;

    sumSize := CurrentSizeUsed;

    if sumSize > RowMaxSize then
    begin
      // La riga va in overflow: il controllo modificato apre una nuova riga.
      // Niente piu' item ctLineBreak: RowPlacement=rpForceNewLine sul controllo.
      SetRowPlacementOf(item, rpForceNewLine);
      // NB: nessun clamp distruttivo di item.Size (EffectiveSize già limita
      // il peso a RowMaxSize): il valore impostato dall'utente sopravvive
      // a un futuro allargamento del dialogo.
    end
    else
      // Rientro: se "item" apriva la riga solo per overflow e ora la riga
      // precedente lo ricontiene, togli la rottura forzata (torna al flusso).
      if (item.RowPlacement = rpForceNewLine) and (prevRowSumSize + sumSize <= RowMaxSize) then
        SetRowPlacementOf(item, rpAuto);
  finally
    RowModel.Free;
  end;
end;

procedure TzDbCard.CMShowingChanged(var Message: TMessage);
var
  cmd: TzDbCardCommand;
begin
  inherited;

  if IsDestroying then
    Exit;

  if Showing and HandleAllocated then
    for cmd := Low(TzDbCardCommand) to High(TzDbCardCommand) do
      if DeferredCommands[cmd] then
      begin
        DeferredCommands[cmd] := false;
        PostInternalMessage(cmd, DeferredParams[cmd]);
      end;
end;

procedure TzDbCard.EditToolsExecute(Sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbCard.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

function TzDbCard.GetActionOwnerName: string;
begin
  result := zDbCardProps.ActionOwnerName;
end;

procedure TzDbCard.SetActionOwnerName(const Value: string);
begin
  zDbCardProps.ActionOwnerName := Value;
end;

function TzDbCard.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, zDbCardProps.ActionOwnerName);
end;

procedure TzDbCard.RebuildActions;
begin
  RebuildToolbar;

  // Persistenza sincrona (il dialog di config si aspetta il dato su base),
  // ma con descale: salvare DlgWidth/DlgHeight in unità runtime li farebbe
  // ri-scalare al prossimo LoadProperties, gonfiando il dialogo a DPI > 100%.
  // Se un salvataggio differito è in volo, accoda invece di scrivere in
  // parallelo sugli stessi props (il thread ripartirà e salverà anche
  // le modifiche alle azioni, già presenti nei props).
  if FSaveThreadRunning then
    FSaveQueued := true
  else
  begin
    DescaleDlgSizeForSave;
    InternalSaveProperties;
  end;
end;

function TzDbCard.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := CardID;
end;

procedure TzDbCard.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;
  TzToolConfigDlgForm.Execute(Self);
end;

function TzDbCard.GetProps: TzBaseComponentProps;
begin
  result := zDbCardProps;
end;

procedure TzDbCard.RefreshVisibility;
begin
  // sincronizza dxLayoutItem.Visible per ogni TzControl
  zControls.MakeControlsVisible;
  ForceControlsValidation;
end;

procedure TzDbCard.RebuildLayout;
begin
  if not Assigned(dxLayoutControl) then
    Exit;

  zControls.BuildLayoutItems(zDbCardProps);
  RefreshVisibility;
end;

procedure TzDbCard.RebuildControls;
begin
  DestroyCustomControls;
  CreateCustomControls; // = zControls.LoadFromProps che già chiama BuildLayoutItems
  RefreshVisibility;
  // NB: LoadFromProps fa già BuildLayoutItems, quindi qui non serve RebuildLayout
end;

procedure TzDbCard.ReloadFromProps(const LoadFromBase: boolean);
begin
  if LoadFromBase then
    InternalLoadProperties;

  RebuildControls;
  DisplayToolbars;
  SaveCardFormSize;
end;

initialization

SiDbCard := Si.AddSession('zDbCard', true);
SiDbCard.Color := clCream;

siRed := Si.AddSession('Temp', true);
siRed.Color := clRed;

finalization

SiDbCard := nil;
siRed := nil;

end.

// zDbCardDlg
// zdbview
// zSystem
// zFbDataSet
// zdbview
// zSystem
// zDx
// zz.base.editor._frame
// zz.base.editor.DbCard
// zz.base.editor.DbView
// zz.base.editor.DataModule

// dxLayoutCustomizeForm
// zDxLayoutCustomizeFrm
// cxGridViewLayoutCustomizationForm

  zSystem zdbpivot zdbview zDX

  TzControls.MigrateLegacyColSpans
(zDbCardProps: TzDbCardProps); zrestrictions

  zsystem_init zSystem

  zdbpivot

  zSystem
