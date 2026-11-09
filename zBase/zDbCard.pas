// BUILD MARKER: v21
unit zDbCard;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
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
  cxButtonEdit,
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
  zDbCard.Commands,
  zDbCard.Saver,
  zDbCard.Layout,
  zDbCard.Lookup,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

const
  // ColSpan di un campo a larghezza piena: occupa tutte le colonne della
  // griglia e continua a farlo quando ColCount cambia. Un eseguibile che non
  // lo conosce lo tratta come 0 (colonne calcolate dal Size).
  ColSpanPiena = -1;

type
  // La coda dei comandi differiti vive in zDbCard.Commands; alias di
  // compatibilita' per il codice esistente.
  TzDbCardCommand = zDbCard.Commands.TzDbCardCommand;

  TzDbCardReadOnly = (crUseLoadedProps, crForceReadOnly, crForceWriteable);

  TzControls = class;
  TzDbCard = class;

  // AutoFitHeight con la card in un gruppo a linguette (form del FormController):
  // l'altezza e' del gruppo, non della card, e la dimensiona chi ha costruito il
  // layout. Altezza = altezza voluta dalla card; Mostrata = False quando la card
  // si nasconde (cambio di linguetta, chiusura): il layout torna come prima.
  TzAutoFitHeightEvent = procedure(Sender: TzDbCard; const Altezza: integer; const Mostrata: boolean) of object;

  TzControl = class(TzCollectionItem)
  private
    FColSpan: integer;
    FRowPlacement: TControlRowPlacement;
    FControl: TWinControl;
    FcxCustomEdit: TcxCustomEdit;
    FcxLabel: TcxLabel;
    FHeight: integer;
    FIdLookup: string;
    FLeft: integer;
    FLines: integer;
    FLookupBinding: TzLookupBinding;
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
    FGroupExpandButton: boolean;
    FGroupExpanded: boolean;
    FImageName: string;
    FLookupIgnoreFieldReadOnly: boolean;
    FReadOnly: boolean;
    FRequired: boolean;
    FVisible: boolean;
  public
    // Esito dell'ultimo build (non persistito): colonne occupate davvero e
    // larghezza assegnata in px; 0 = campo non agganciato alla griglia.
    BuiltColSpan: integer;
    BuiltWidthPx: integer;
  private
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
    function CreateDataSet(const IdLookup: string): TzFbDataSet;
    procedure CreateLookupBinding;

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
    function GetlkDataSet: TzFbDataSet;
    function GetlkDataSource: TDataSource;

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
    property LookupBinding: TzLookupBinding read FLookupBinding;
    property lkDataSet: TzFbDataSet read GetlkDataSet;
    property lkDataSource: TDataSource read GetlkDataSource;
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

    // Colonne fisse della griglia (0 = calcolate dal Size): con SnapToGrid
    // prevalgono sul Size, cosi' il campo resta allineato a ogni larghezza.
    property ColSpan: integer read FColSpan write FColSpan;

    property RowPlacement: TControlRowPlacement read FRowPlacement write FRowPlacement;

    property Size: integer read FSize write FSize;
    property Lines: integer read FLines write FLines;
    property Visible: boolean read FVisible write SetVisible;
    property zCtrlType: TzCtrlType read FzCtrlType write FzCtrlType;
    property Group: String read FGroup write FGroup;
    // Solo ctGroupBox/ctCheckGroupBox: bottone di collasso e ultimo stato
    // espanso. Specchiati da/verso TzControlProps (LoadFromProps/SaveToProps).
    property GroupExpandButton: boolean read FGroupExpandButton write FGroupExpandButton;
    property GroupExpanded: boolean read FGroupExpanded write FGroupExpanded;
    // Icona del catalogo dx.Immagini (nome senza estensione), specchiata
    // da/verso TzControlProps come GroupExpandButton.
    property ImageName: string read FImageName write FImageName;
  public
    procedure AddCustomAction(Action: TBasicAction);
    function HasCustomActions: boolean;
    function GetCustomActions: TArray<TBasicAction>;
    property CustomActions[const Name: string]: TBasicAction read GetCustomAction write SetCustomAction;
  end;

  // TzDbCardController
  TzControls = class(TzCollection<TzControl>)
  private
    // campo -> Visible precedente a HideField (R6): la visibilita' forzata da
    // codice non deve diventare una preferenza persistita dell'utente.
    FieldsHiddenByCode: TDictionary<string, boolean>;
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

  // Tipi trasferiti nelle sotto-unit (zDbCard.Layout / zDbCard.Saver);
  // alias di compatibilita' per il codice esistente.
  TzRowModel = zDbCard.Layout.TzRowModel;
  IzCardAliveGuard = zDbCard.Saver.IzCardAliveGuard;
  TzCardAliveGuard = zDbCard.Saver.TzCardAliveGuard;

  TzLayoutMaintenanceOp = (lmoNone, lmoReset, lmoRepair);

  TzDbCard = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzLayoutMaintenance)
    DataSource: TDataSource;
    dxBarManager: TdxBarManager;
    dxBarToolbarFree: TdxBar;
    dxBarToolbar: TdxBar;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
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
    NascondiCampo: TAction;
    NewLine: TAction;
    Separatore: TAction;
    MostraQueryUtilizzata: TAction;
    CopiaQueryUtilizzata: TAction;
    CopiaControlli: TAction;
    IncollaControlli: TAction;
    popCard: TdxBarPopupMenu;
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
    dxBarSpinEditCtrlColSpan: TcxBarEditItem;
    FissaColonne: TAction;
    LiberaColonne: TAction;
    dxBarButtonFissaColonne: TdxBarButton;
    dxBarButtonLiberaColonne: TdxBarButton;
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
    actSanifica: TAction;
    dxBarButton1: TdxBarButton;
    cxBarEditItemGriglia: TcxBarEditItem;
    DistribuisciRiga: TAction;
    LarghezzaPiena: TAction;
    GuideGriglia: TAction;
    dxBarButtonDistribuisciRiga: TdxBarButton;
    dxBarButtonLarghezzaPiena: TdxBarButton;
    dxBarButtonGuideGriglia: TdxBarButton;
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
    procedure dxBarSpinEditCtrlColSpanChange(Sender: TObject);
    procedure FissaColonneExecute(Sender: TObject);
    procedure LiberaColonneExecute(Sender: TObject);
    procedure ColonneUpdate(Sender: TObject);
    procedure cxBarEditItemGrigliaChange(Sender: TObject);
    procedure cxBarEditItemGrigliaPropertiesButtonClick(Sender: TObject; AButtonIndex: integer);
    procedure DistribuisciRigaExecute(Sender: TObject);
    procedure DistribuisciRigaUpdate(Sender: TObject);
    procedure LarghezzaPienaExecute(Sender: TObject);
    procedure LarghezzaPienaUpdate(Sender: TObject);
    procedure GuideGrigliaExecute(Sender: TObject);
    procedure GuideGrigliaUpdate(Sender: TObject);
    procedure actNuovoLookupExecute(Sender: TObject);
    procedure actPersonalizzaPicklistExecute(Sender: TObject);
    procedure actSanificaExecute(Sender: TObject);
    procedure actSanificaUpdate(Sender: TObject);
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
    // R1: si conserva il NOME del campo, non il puntatore al TzControl: il
    // comando e' differito e la collection puo' essere ricostruita nel
    // frattempo; il controllo viene risolto per nome al dispatch.
    TFieldRebuildData = record
      FieldName: string;
      Domain: TzDomain;
      function Valid: boolean;
      procedure Clear;
    end;
  private
    FieldRebuildData: TFieldRebuildData;
    procedure RebuildSingleControl;
  private
    procedure SetPopupControlloOrtografico;
  private
    // azioni personalizzate del memo (es. Importa) ripetute nel menu del tasto
    // destro: pulsanti ricreati a ogni apertura del menu, per il controllo cliccato
    AzioniMenuMemo: TArray<TBasicAction>;
    PulsantiAzioniMenuMemo: TArray<TdxBarButton>;
    procedure AggiornaAzioniMenuMemo;
    procedure AzioneMenuMemoClick(Sender: TObject);
  private
    procedure LabelDblClick;
  private
    FCommandQueue: TzDeferredCommandQueue;
    procedure PostInternalMessage(const cmd: TzDbCardCommand; lparam: NativeUInt = 0);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBCARD;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  private // Salvataggio props differito (cmd_SaveProperties)
    FSaver: TzDeferredSaver;
    FDlgSizeIs96dpi: boolean; // DlgWidth/DlgHeight in unità 96-dpi (post descale)
    procedure DescaleDlgSizeForSave;
    procedure DoDeferredSaveProperties;
    procedure RequestDeferredSave;
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
    FLastBuildMeasured: boolean; // l'ultimo build usava la capacita' REALE (non stimata)
    FRowModelWasMeasured: boolean; // l'ultimo NewRowModel ha usato la capacita' reale
    FInReflow: boolean; // guard anti-rientro CheckReflow -> RebuildLayout -> Resize
    FSettleRebuildPending: boolean; // l'ultimo build ha stimato la capacita' di almeno un gruppo
    FSettleRebuilds: integer; // quanti rebuild di assestamento gia' programmati (limite anti-ciclo)
    procedure CheckReflow;
    procedure NoteGroupCapacityEstimated(const ACount: integer);
  private // Altezza adattata al contenuto (AutoFitHeight)
    FAutoFitHeight: boolean;
    FAutoFitArmato: boolean; // riferimento di FAutoFitAltezzaApplicata gia' preso
    FAutoFitAltezzaApplicata: integer; // SizeOptions.Height dell'elemento dopo l'ultimo adattamento
    FAutoFitSospeso: boolean; // altezza cambiata da fuori (divisore, codice della form): non si adatta piu'
    FAutoFitLarghezza: integer; // larghezza a cui e' stato azzerato il conteggio dei passaggi
    FAutoFitPassaggi: integer; // adattamenti dall'ultimo azzeramento (limite anti-ciclo)
    FAutoFitRitardoAttivo: boolean; // timer dell'adattamento ritardato in corso
    FAutoFitRichiesta: cardinal; // GetTickCount dell'ultima richiesta ritardata
    FOnAutoFitHeight: TzAutoFitHeightEvent;
    procedure ApplyAutoFitHeight(const Ritardato: boolean = false);
    function GetAutoFitHeight: boolean;
    function IsAutoFitHeightStored: boolean;
    procedure ProgrammaAutoFitRitardato;
    procedure FermaAutoFitRitardato;
    function AutoFitPuoSpostare: boolean;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
  private // Griglia delle colonne: comandi rapidi e guide
    class var FGuideGrigliaAttive: boolean; // vale per tutte le card della sessione
  private
    FGrigliaColonne: integer; // colonne della riga root nell'ultimo build (0 = griglia spenta)
    FGrigliaCapacitaPx: integer; // capacita' utile della riga root nell'ultimo build
    FGrigliaGapPx: integer; // gutter fra le colonne nell'ultimo build
    FLayoutWindowProc: TWndMethod; // WindowProc originale di dxLayoutControl
    procedure LayoutWindowProc(var Message: TMessage);
    procedure DisegnaGuideGriglia;
    procedure ImpostaColonneGriglia(const Colonne: integer);
    procedure AggiornaValoreGriglia;
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
    procedure ForceControlsValidation(ChangedField: TField = nil);
    procedure InitCard;
    procedure PersonalizzaCard;
  private
    procedure LoadProperties(const LoadFromBase: boolean = true);
    procedure SaveProperties;
  private
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
  private
    // Item generato dal controller per un campo: prima il TdxLayoutItem
    // (li_*), poi il TdxLayoutGroup (grp_*) per ctGroupBox/ctCheckGroupBox.
    function FindGeneratedItem(const FieldName: string): TdxCustomLayoutItem;
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
  private
    function EditorSanificabile(zControl: TzControl): boolean;
    function SanificaEditor(zControl: TzControl): boolean;
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
    function EnsureLayoutSettled: boolean;
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
    procedure UpdateColors(ChangedField: TField = nil);
    function ValidateRequiredFields(RaiseError: boolean): boolean;
    function ActiveFieldName: string;
    function ActiveCustomEdit: TcxCustomEdit;
    procedure RealignToolbars;

    function FindLayoutGroup(const GroupName: string): TdxLayoutGroup;
    function FindLayoutItem(const FieldName: string): TdxLayoutItem;
    // AutoFitHeight: rifa' l'adattamento al prossimo cmd_Resize (layout
    // ricaricato o riscalato da chi ospita la card)
    procedure RichiediAutoFitHeight;
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
    procedure OnGroupExpandedStateChanged(Sender: TObject);
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
    // Card ospitata in un TdxLayoutControl insieme ad altri elementi (per
    // esempio sopra una griglia): l'elemento che la contiene segue l'altezza
    // del contenuto, senza barra di scorrimento verticale. Vedi ApplyAutoFitHeight.
    // Accesa da codice o dal dizionario LZ (TzDbCardProps.AutoFitHeight).
    property AutoFitHeight: boolean read GetAutoFitHeight write FAutoFitHeight stored IsAutoFitHeightStored;
    // Gruppo a linguette: vedi TzAutoFitHeightEvent
    property OnAutoFitHeight: TzAutoFitHeightEvent read FOnAutoFitHeight write FOnAutoFitHeight;
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

  // Funzioni pure esposte per i test (prima erano interne all'implementation
  // o annidate nei metodi della card).

  // S5: generatore unico dei nomi univoci; il predicato di esistenza e'
  // iniettato, quindi la funzione e' testabile senza componenti.
function MakeUniqueName(const BaseName: string; const StartIndex: integer; const NameExists: TFunc<string, boolean>): string;

// Estratta da GetDialogTitle: deriva una caption leggibile dall'IdDataSet
// togliendo il prefisso fino al punto e spaziando il PascalCase
// ('Anagrafica.SoggettiFisici' -> 'Soggetti Fisici').
function EstraiCaptionDaIdDataSet(const IdDataSet: string): string;

var
  // Hook opzionale assegnato dall'applicazione (export verso DevExtreme).
  // M8: era una "writable typed constant"; una var dichiara l'intento senza
  // dipendere dall'opzione $WRITEABLECONST.
  DevExtremeSaveDbCard: procedure(Card: TzDbCard) = nil;

implementation

uses
  System.Diagnostics,
  System.Character,
  zDiagnostica.Log.Perf,
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
  zToolConfigDlg,
  zToolFilter.Builder,
  zSanificazione;

{$R *.dfm}

// M4: stringhe visibili all'utente centralizzate come resourcestring, cosi'
// partecipano al meccanismo standard di localizzazione.
resourcestring
  SValoreSelezionatoDisabilitato = 'Il valore selezionato è disabilitato.';
  SEliminoIlRecord = 'Elimino il record?';
  SAttendere = 'Attendere...';
  SCampiObbligatori = 'I campi seguenti devono avere un valore:';
  SSqlLookupNonDefinito = 'Sql di lookup non definito: ';
  SLookupNonDefinito = 'Lookup non definito : ';
  SDataSetLookupNonDefinito = 'DataSet di Lookup non definito : ';
  SErroreInitLookup = 'Errore inizializzazione lookup: ';
  SDataSetLookupNonAssegnato = 'Dataset di lookup non assegnato.';
  SRipristinoImpostazioni = 'Ripristino le impostazioni di default?';
  SQueryCopiata = 'Query copiata.';
  SCampiCopiati = 'Campi copiati nella clipboard.';

var
  SiDbCard: TSiSession;

  // S5: generatore unico dei nomi univoci (prima duplicato in
  // TzControls.UniqueName e TzDbCard.UniqueComponentName con logiche gemelle).
  // StartIndex = 0: parte dal nome nudo; StartIndex >= 1: parte da <nome>_<N>.
function MakeUniqueName(const BaseName: string; const StartIndex: integer; const NameExists: TFunc<string, boolean>): string;
var
  Counter: integer;
begin
  if StartIndex <= 0 then
    result := BaseName
  else
    result := BaseName + '_' + StartIndex.ToString;

  Counter := StartIndex;
  while NameExists(result) do
  begin
    Inc(Counter);
    result := BaseName + '_' + Counter.ToString;
  end;
end;

function EstraiCaptionDaIdDataSet(const IdDataSet: string): string;
var
  s: string;
  c: Char;
  PrevWasUpper: boolean;
begin
  result := '';

  // Si tiene solo l'ultimo segmento: 'Anagrafica.Soggetti.Altro' -> 'Altro'
  s := IdDataSet;
  if LastDelimiter('.', s) <> 0 then
    s := System.Copy(s, LastDelimiter('.', s) + 1, MaxInt);

  PrevWasUpper := false;
  for c in s do
    if c.IsUpper then
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

type
  // AutoSize (protected in TcxCustomEdit, default True): per i memo/rtf
  // fa ignorare QUALUNQUE Height esplicito — sia quello assegnato dal
  // nostro codice, sia quello impostato a mano dall'editor di layout —
  // perché il controllo si ridimensiona sul contenuto a ogni resize/paint.
  // È la vera causa dell'altezza sbagliata dei memo (vedi InitControlProperties).
  TcxCustomEditAccess = class(TcxCustomEdit);

  /// ///////////////////////////////////////////////////////////////

procedure TzControl.CheckLookupRecordValid;
begin
  if not LookupRecordValid then
    raise Exception.Create(SValoreSelezionatoDisabilitato);
end;

procedure TzControl.CopyMappingFields(Field2Exclude: string = '');
var
  zLookup: TzLookup;
  SrcDataSet, DestDataSet: TzFbDataSet;

  // Mantis #312 - 2026-11-02: i campi mappati si copiano dal record corrente di lkDataSet, ma
  // quel record e' quello su cui sta il cursore, non necessariamente quello che corrisponde al
  // valore del controllo. Se l'utente digita in un lookup con OnlyFromLookup = False un valore
  // che non e' nell'elenco (un codice fiscale nuovo), il cursore resta sulla prima riga e la
  // scheda si riempiva con i dati di un'altra persona. Per le chiavi di tipo testo si copia
  // solo se la chiave del record corrente coincide con il valore del controllo.
  //
  // Mantis #312 - 2026-11-02 (secondo intervento): lo stesso vale per le chiavi numeriche. Una
  // duplicazione in Sia_Interventi riceveva l'id dell'intervento di partenza: il lookup
  // FK_SIA_INTERVENTI_OBJECTS (ID_INTERVENTO_SIA=OID) ricopiava nella riga nuova l'OID del record
  // corrente del lookup (quello di partenza) al posto dell'id provvisorio negativo, e il
  // successivo Ok violava PK_SIA_INTERVENTI. Ora si copia solo se la chiave del record corrente
  // e' uguale al valore del controllo.
  //
  // Mantis #312 - 2026-11-02: il confronto e' stato estratto in TzCorrispondenzaChiaveLookup
  // (zDbCard.Lookup) per coprirlo con test; il comportamento non cambia.
  function RecordCorrenteCorrispondeAlValore(zLookupControllo: TzLookup): boolean;
  var
    CampoChiave: TField;
  begin
    result := true;

    if not Assigned(lkDataSet) or not lkDataSet.Active then
      Exit;

    if VarIsArray(cxCustomEdit.EditValue) then
      Exit;

    CampoChiave := lkDataSet.FindField(zLookupControllo.GetKeyFieldForCombo(Name));

    if not Assigned(CampoChiave) then
      Exit;

    // il confronto vero e proprio sta in TzCorrispondenzaChiaveLookup (zDbCard.Lookup), coperto da test
    result := TzCorrispondenzaChiaveLookup.Corrisponde(CampoChiave.DataType, CampoChiave.AsVariant, cxCustomEdit.EditValue);
  end;

begin

  if not ControlIsLookup then
    Exit;

  // Con valore vuoto non c'e' nulla da mappare (Mantis 1223)
  if IsEmptyValue then
    Exit;

  DestDataSet := Controls.DataSet;

  if Assigned(DestDataSet) then
    if DestDataSet.Active then // alla chiusura del dataset viene chiamato l'evento
    begin
      SrcDataSet := lkDataSet;

      zLookup := GetLookup(Controls.zSystem);

      if Assigned(zLookup) then
        if RecordCorrenteCorrispondeAlValore(zLookup) then
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
  FGroupExpandButton := false;
  FGroupExpanded := true;
  FImageName := '';
  FRowPlacement := rpAuto;

  FIdLookup := '';
  FLookupBinding := nil;

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

    // Il binding esiste per QUALSIASI campo con IdLookup (anche ctComboDlg e
    // ctCheckComboBox, che usano solo dataset ausiliari); il dataset
    // principale viene creato solo per i veri lookup.
    if IdLookup <> '' then
      CreateLookupBinding;

    if IsLookup and Assigned(FLookupBinding) then
    begin
      SiDbCard.LogString('IdLookup', IdLookup);
      FLookupBinding.CreateMainDataSet;
      FLookupBinding.DataSet.AfterOpen := LookupDatasetAfterOpen;
    end;

    Controls.Card.doBeforeCreateDbControl(Name, FcxCustomEdit);

    if not Assigned(FcxCustomEdit) then
      FcxCustomEdit := CreateDbControl(Name, zCtrlType);

    InitControlProperties;

    InternalSetEditability;

    // B8: il ramo ctCheckGroupBox che impostava caption/StyleController sul
    // TdxDBCheckGroupBox era irraggiungibile (Exit piu' sopra) ed e' stato
    // rimosso: il check-group vive come TdxLayoutGroup in BuildLayoutItems.

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
    FreeAndNil(FLookupBinding);
  except
    on e: Exception do
      // R4: la distruzione non deve propagare, ma l'errore non va perso
      SiDbCard.LogException(e);
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

function TzControl.GetlkDataSet: TzFbDataSet;
begin
  result := nil;
  if Assigned(FLookupBinding) then
    result := FLookupBinding.DataSet;
end;

function TzControl.GetlkDataSource: TDataSource;
begin
  result := nil;
  if Assigned(FLookupBinding) then
    result := FLookupBinding.DataSource;
end;

procedure TzControl.CreateLookupBinding;
begin
  if Assigned(FLookupBinding) then
    Exit;

  // Provider come closure: il binding legge zSystem/dataset/transazioni della
  // collection al momento dell'uso, senza riferimenti incrociati alla card.
  FLookupBinding := TzLookupBinding.Create(Name, IdLookup,
    function: TzSystem
    begin
      result := Controls.zSystem;
    end,
    function: TzFbDataSet
    begin
      result := Controls.DataSet;
    end,
    function: TzFbTransaction
    begin
      result := Controls.ReadTrans;
    end,
    function: TzFbTransaction
    begin
      result := Controls.WriteTrans;
    end);
end;

function TzControl.CreateDataSet(const IdLookup: string): TzFbDataSet;
begin
  // Dataset ausiliario (dialog di lookup, riempimento check-combo) con la
  // stessa configurazione del dataset principale. Il parametro coincide
  // sempre con Self.IdLookup (mantenuto per compatibilita' di firma).
  CreateLookupBinding;
  result := FLookupBinding.CreateAuxiliaryDataSet;
end;

procedure TzControl.DoHyperLink(Sender: TObject);
var
  Binding: TcxDBEditDataBinding;
  Field: TField;
  FieldName: string;
  Value: Variant;
begin
  // B5: inizializzazioni esplicite — i riferimenti locali a oggetti NON sono
  // azzerati dal compilatore e alcuni rami uscivano senza assegnare Field.
  Field := nil;
  FieldName := '';
  Value := Null;

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

  // B5: si naviga anche nel ramo hyperlink senza binding (Field = nil, Value
  // dall'EditValue), che prima veniva escluso dal test Assigned(Field); e si
  // usa la variabile Value gia' estratta invece di rileggere Field.Value.
  if not FieldName.IsEmpty then
    base.HyperLink(Self, FieldName, Value);
end;

procedure TzControl.F2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  procedure CheckEditMode;
  begin

    if Controls.DataSet.CanModify then
      Controls.DataSet.CheckEditMode;
  end;

  // Mantis #123 - 2026-09-15: un codice fiscale (o altro valore) incollato con Ctrl+V
  // (o Shift+Ins) imposta il testo del combo in blocco, senza passare dai singoli tasti premuti che
  // alimentano la ricerca incrementale nativa del componente (AutoSearchOnPopup): il
  // valore non si risolve mai in un record, CopyMappingFields non scatta e i campi
  // mappati (cognome, residenza, ecc.) restano vuoti pur avendo gia' quel beneficiario
  // in anagrafica. Se il testo incollato corrisponde esattamente a un record del
  // dataset di ricerca, lo risolviamo qui riusando lo stesso meccanismo gia' impiegato
  // dal dialogo di ricerca (ExecuteLookupDlg): posizionare lkDataSet sul record e
  // chiamare CopyMappingFields, che scrive anche il campo chiave.
  //
  // Stesso principio gia' usato da zSanificazione.Clipboard.pas (TzFiltroClipboard):
  // WM_PASTE e' un messaggio inviato e non intercettabile da un filtro globale, la
  // sequenza di tasti Ctrl+V invece si'. Quel filtro intercetta a livello di
  // Application.OnShortCut (prima ancora del dispatch al controllo) e sanifica il
  // testo negli appunti senza mai consumare il tasto: gira quindi PRIMA di questo
  // OnKeyDown, e il testo che leggiamo qui e' gia' quello ripulito. Le due cose sono
  // indipendenti: quel filtro sanifica il testo, questo risolve il valore del lookup.
  function TryResolvePastedLookupValue: boolean;
  var
    zLookup: TzLookup;
    ClipboardText, ListFieldName: string;
  begin
    result := false;

    if not ControlIsLookup then
      Exit;

    if not Assigned(lkDataSet) then
      Exit;

    if not Clipboard.HasFormat(CF_TEXT) then
      Exit;

    ClipboardText := Trim(Clipboard.AsText);
    if ClipboardText = '' then
      Exit;

    zLookup := GetLookup(Controls.zSystem);
    if not Assigned(zLookup) then
      Exit;

    // Il primo campo di DisplayColumns e' per convenzione quello mostrato/cercato
    // dal combo (vedi Tdx.InitLookup.GetListFieldItem in zDX.pas).
    ListFieldName := Trim(zLookup.DisplayColumns.Split([';'])[0]);
    if ListFieldName = '' then
      Exit;

    EnsureLookupDataSetOpen;

    if not(Assigned(lkDataSet) and lkDataSet.Active) then
      Exit;

    if not Assigned(lkDataSet.FindField(ListFieldName)) then
      Exit;

    if not lkDataSet.Locate(ListFieldName, ClipboardText, [loCaseInsensitive]) then
      Exit;

    CheckEditMode;
    CheckLookupRecordValid;
    Controls.DataSet.CopyMappingFields(lkDataSet, zLookup.Mappings, false);

    result := true;
  end;

begin

  // Stessa combinazione riconosciuta da TzFiltroClipboard.IncollaDaTastiera
  // (zSanificazione.Clipboard.pas): Ctrl+V oppure Shift+Ins, mai insieme.
  if (((Key = Ord('V')) and (Shift = [ssCtrl])) or ((Key = VK_INSERT) and (Shift = [ssShift]))) then
  begin
    if ControlIsLookup then
      if TryResolvePastedLookupValue then
        Key := 0; // valore gia' risolto dal mapping: non serve incollare anche il testo grezzo
    Exit;
  end;

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
        // M3: scansione senza notifiche ai controlli collegati
        DataSet.DisableControls;
        try
          while not DataSet.Eof do
          begin
            StringList.Add(DataSet.FieldByName(FieldName).asString);
            DataSet.Next;
          end;
        finally
          DataSet.EnableControls;
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
    // Un edit con modifiche pendenti non va rivalidato: la validazione
    // resetterebbe il valore appena digitato (caso storico: campo data della
    // scheda manutenzione).
    if not cxCustomEdit.EditModified then
    begin
      // Se il controllo è un lookup e il suo dataset è chiuso,
      // chiamare ValidateEdit forzerebbe DevExpress ad aprirlo e chiuderlo
      // solo per validare il testo. Saltiamo la validazione per salvare le performance.
      if ControlIsLookup and Assigned(lkDataSet) and (not lkDataSet.Active) and not((GetEditability = edRequired) and IsEmptyValue) then
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
  // P2: niente tracing qui — viene chiamata per ogni controllo a ogni
  // DataSourceDataChange (cioe' a ogni battuta in edit).
  result := Assigned(cxCustomEdit) and (VarIsNull(cxCustomEdit.EditValue) or (VarToStr(cxCustomEdit.EditValue) = ''));
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
        result := Field.asString <> 'S';
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
    dxItem := Controls.Card.FindGeneratedItem(Name);
    if Assigned(dxItem) then
      dxItem.Visible := true;
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

    // EditModified incluso nel test: l'evento arriva anche per riallineamenti
    // programmatici che non devono innescare la cascata dei campi dipendenti
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
  if Assigned(FLookupBinding) then
    FLookupBinding.EnsureOpen;
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

  // R5: si usa lo zSystem della card, non il singleton globale
  zLookup := GetLookup(Controls.zSystem);

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
        // AutoWidth=True fa ricalcolare al combo la propria larghezza sul
        // contenuto (voci + pulsante dropdown), sforando l'area dell'item.
        // Disattivandolo, l'ahClient dell'item lo stira esatto all'area e resta
        // reattivo al resize (a differenza di FixedSize, deprecato).
        // Si spegne SOLO AutoWidth: AutoSize := false azzera insieme AutoWidth
        // e AutoHeight (TcxCustomEdit.SetEditAutoSize), e senza AutoHeight il
        // combo resta all'altezza di creazione, piu' basso degli edit vicini.
        TcxCustomEditAccess(cxCustomEdit).AutoWidth := false;
      end;
    ctPickListImage:
      begin
        // Stesso motivo del ramo ctPickList sopra.
        TcxCustomEditAccess(cxCustomEdit).AutoWidth := false;
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
        // AutoSize=True (default) fa ridimensionare il memo sul contenuto a
        // ogni resize/paint, ignorando qualunque Height esplicito — sia
        // quello impostato dal nostro layout, sia quello impostato a mano
        // dall'editor visuale. Va disattivato perché l'altezza a riga
        // singola (ResolveHeight/SingleLineHeight) abbia effetto.
        TcxCustomEditAccess(cxCustomEdit).AutoSize := false;
      end;
    ctRTF:
      begin
        (cxCustomEdit as TcxDbRichEdit).OnKeyDown := F2KeyDown;
        // Stesso motivo del ramo ctMemo sopra.
        TcxCustomEditAccess(cxCustomEdit).AutoSize := false;
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
  zLookup: TzLookup;
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
        ConfirmOk(SSqlLookupNonDefinito + IdLookup);
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
    ConfirmOk(SLookupNonDefinito + IdLookup);
    Exit;
  end;

  if not Assigned(zLookup.DataSet_Obj) then
  begin
    ConfirmOk(SDataSetLookupNonDefinito + IdLookup);
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
      ConfirmOk(SErroreInitLookup + IdLookup + sLineBreak + sLineBreak + e.Message);
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
    dxItem := Controls.Card.FindGeneratedItem(Name);
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
      dxItem := Controls.Card.FindGeneratedItem(Name);
      if Assigned(dxItem) then
        dxItem.Visible := Value;
    end;
  end;
end;

constructor TzControls.Create;
begin
  inherited Create(TzControl, '', -1, nil);
  FieldsHiddenByCode := TDictionary<string, boolean>.Create(TIStringComparer.Ordinal);
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
  item := Add;
  item.name := DataField;
  item.zCtrlType := ControlType;
  item.Size := Size;
  item.Lines := Lines;
  item.IdLookup := Domain.Lookup;
  item.Domain := Domain;
  item.DisplayLabel := DisplayLabel;
  item.Group := Group;

  // B6: la funzione dichiarava di restituire l'edit ma ritornava sempre nil
  // e non creava i controlli.
  item.CreateControls;
  result := item.cxCustomEdit;
end;

function TzControls.CreateDbControl(const DataField: String; ControlType: TzCtrlType): TcxCustomEdit;
begin
  result := dx.GetCustomEditClass(ControlType).Create(Card);
  result.Visible := false;
  result.name := 'ed' + DataField;
  result.Parent := Card;

  // Carattere letto dal layout vivo, non dalla copia ControlFont: quella viene
  // presa nel costruttore della card, prima che la frame sia scalata sul DPI
  // del monitor. A DPI diversi da 96 (desktop remoto, monitor al 150%) i campi
  // creati dopo la scalatura nascevano col carattere a 96 DPI, piccoli e bassi
  // (AutoHeight segue il carattere), mentre le etichette erano gia' ingrandite.
  if Assigned(Card) then
    result.Style.Font.Assign(Card.dxLayoutControl.Font)
  else
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
    // La transazione appena creata non ha mai una Connection: si assegna se lo
    // zSystem e' gia' noto, altrimenti provvede SetzSystem.
    if zSystemOk then
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
    if zSystemOk then
      FWriteTrans.Connection := zSystem.zFbDatabase;
  end;

  result := FWriteTrans;
end;

function TzControls.Groups: TStringDynArray;
var
  zControl: TzControl;
  StringList: TStringList;
  i: integer;
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

    SetLength(result, StringList.Count);
    for i := 0 to StringList.Count - 1 do
      result[i] := StringList[i];
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzControls.LoadFromProps(zDbCardProps: TzDbCardProps);
const
  // Righe di un memo quando il dizionario non le dice (Lines -1 o 0)
  MEMO_LINES_DEFAULT = 2;
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
    item.RowPlacement := ctrlProps.RowPlacement;
    item.ReadOnly := ctrlProps.ReadOnly;
    item.Required := ctrlProps.Required;
    item.Size := ctrlProps.Size;
    item.ColSpan := ctrlProps.ColSpan;
    item.Visible := ctrlProps.Visible;
    item.zCtrlType := ctrlProps.zCtrlType;
    item.Group := ctrlProps.Group;
    item.GroupExpandButton := ctrlProps.GroupExpandButton;
    item.GroupExpanded := ctrlProps.GroupExpanded;
    item.ImageName := ctrlProps.ImageName;

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

      // Le card senza Controls nel dizionario ricevono i controlli da
      // ValidateDataset con Lines = -1: senza questo il memo resterebbe a
      // una riga (ResolveHeight). Un Lines = 1 esplicito resta voluto.
      if item.zCtrlType.IsMemo and (item.Lines <= 0) then
        item.Lines := MEMO_LINES_DEFAULT;
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
  i: integer;
  CanReuse: boolean;
  OriginalVisible: boolean;
begin
  // P4: se numero e ordine dei nomi coincidono gia', si aggiorna in place
  // invece di distruggere e ricreare l'intera collection a ogni SaveProperties
  // (che arriva anche per il singolo tick di uno spinner).
  CanReuse := zDbCardProps.Controls.Count = Count;
  if CanReuse then
    for i := 0 to Count - 1 do
      if not SameText(zDbCardProps.Controls[i].name, items[i].name) then
      begin
        CanReuse := false;
        Break;
      end;

  if not CanReuse then
    zDbCardProps.Controls.Clear;

  for i := 0 to Count - 1 do
  begin
    item := items[i];

    if CanReuse then
      ctrlProps := zDbCardProps.Controls[i]
    else
    begin
      ctrlProps := zDbCardProps.Controls.Add;
      ctrlProps.name := item.name;
    end;

    // Salva DisplayLabel solo se non è gestita da un override (che prevale a
    // runtime) e solo se è diversa dal domain (altrimenti il default basta);
    // l'else azzera l'eventuale valore precedente in caso di riuso in place.
    if (not Overrides.OverrideExists(Card.DataController.IdDataSet, item.name, [ofCaptionCard])) and (not SameText(item.DisplayLabel, item.DomainDisplayLabel)) then
      ctrlProps.DisplayLabel := item.DisplayLabel
    else
      ctrlProps.DisplayLabel := '';

    ctrlProps.Group := item.Group;
    ctrlProps.GroupExpandButton := item.GroupExpandButton;
    ctrlProps.GroupExpanded := item.GroupExpanded;
    ctrlProps.ImageName := item.ImageName;
    // RowPlacement: senza questa copia ogni SaveProperties riporterebbe a
    // rpAuto le rotture e gli affiancamenti di riga decisi dall'utente.
    ctrlProps.RowPlacement := item.RowPlacement;
    ctrlProps.Lines := item.Lines;
    ctrlProps.ReadOnly := item.ReadOnly;
    ctrlProps.Required := item.Required;
    ctrlProps.Size := item.Size;
    ctrlProps.ColSpan := item.ColSpan;
    ctrlProps.zCtrlType := item.zCtrlType;

    ctrlProps.Visible := item.Visible;

    // R6: un campo nascosto DA CODICE (HideField) non persiste la visibilità
    // di runtime: si salva lo stato precedente all'HideField, così la scelta
    // temporanea dell'applicazione non diventa una preferenza permanente.
    if FieldsHiddenByCode.TryGetValue(item.name, OriginalVisible) then
      ctrlProps.Visible := OriginalVisible;
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

function TzControls.UniqueName(const name: string): string;
begin
  // Parte sempre dal suffisso _1 (comportamento storico: i nomi generati
  // come 'LineBreak_1', 'Separator_1' sono attesi cosi').
  result := MakeUniqueName(Name, 1,
    function(CandidateName: string): boolean
    begin
      result := Assigned(Find(CandidateName));
    end);
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
  items: TStrings;
  zCtrlType: TzCtrlType;
begin
  inherited;
  dx.AgganciaImmagini(Self);

  FCommandQueue := TzDeferredCommandQueue.Create(Self, ZZ_DBCARD);

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
  FDlgSizeIs96dpi := true; // i props caricati da base sono in unità 96-dpi

  FSaver := TzDeferredSaver.Create;
  FSaver.OnPrepare := DescaleDlgSizeForSave;
  FSaver.OnExecuteSave := InternalSaveProperties;
  FSaver.OnRepostRequest := RequestDeferredSave;

  FUpdatingCheckBoxes := false;
  FLastBuildRowMax := 0;
  FInReflow := false;
  FSettleRebuildPending := false;
  FSettleRebuilds := 0;
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

  // M7: acquisizione da webcam non implementata; l'azione resta nel DFM ma
  // non viene proposta all'utente finche' non esiste una vera implementazione.
  WebCam.Visible := false;

  dx.InitTitle(Titolo);
  dx.InitLayoutControl(dxLayoutControl);

  // Guide della griglia: si disegnano dopo il paint del layout control
  FGrigliaColonne := 0;
  FGrigliaCapacitaPx := 0;
  FGrigliaGapPx := 0;
  FLayoutWindowProc := dxLayoutControl.WindowProc;
  dxLayoutControl.WindowProc := LayoutWindowProc;
end;

destructor TzDbCard.Destroy;
begin
  SiDbCard.EnterMethod(Self, 'Destroy');

  TThread.RemoveQueuedEvents(ExecutePendingMaintenance);
  if Assigned(dxLayoutControl) then
    TzLayoutMaintenanceRegistry.UnregisterHandler(dxLayoutControl);

  // Restituisce al layout control la sua WindowProc prima che venga distrutto
  if Assigned(dxLayoutControl) and Assigned(FLayoutWindowProc) then
    dxLayoutControl.WindowProc := FLayoutWindowProc;

  // Attende un salvataggio in volo PRIMA di liberare zDbCardProps (il task
  // serializza proprio quei props) e disattiva le closure asincrone residue.
  // Timeout difensivo: in caso di blocco del DB meglio un leak che un
  // deadlock alla chiusura.
  FSaver.Shutdown(10000);

  // Flush SINCRONO di un salvataggio non ancora processato: il messaggio
  // cmd_SaveProperties andrebbe perso e zDbCardProps sta per essere liberato,
  // quindi niente task qui. Considera anche i comandi deferred (save richiesto
  // a card nascosta o trasferito da DestroyWnd) e la richiesta accodata nel
  // saver (modifiche arrivate mentre il task appena atteso era in volo).
  if FCommandQueue.IsPending(cmd_SaveProperties) or FSaver.HasQueuedRequest then
  begin
    FSaver.ClearQueuedRequest;
    DescaleDlgSizeForSave;
    InternalSaveProperties;
  end;

  FIsDestroying := true;
  FreeAndNil(FrameDescription);
  FreeAndNil(FToolActions);
  FreeAndNil(FzDbCardProps);
  FreeAndNil(FzControls);
  FreeAndNil(FDataController);
  FreeAndNil(FSaver);
  // La coda viene liberata prima di inherited: DestroyWnd e CMShowingChanged
  // (che girano durante inherited) la usano con guardia Assigned.
  FreeAndNil(FCommandQueue);

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
begin
  // I messaggi già accodati sull'HWND distrutto vanno persi: la coda
  // trasferisce i latch pendenti su deferred (rilancio in CMShowingChanged)
  // invece di scartarli — altrimenti un cmd_SaveProperties o
  // cmd_LoadProperties postato poco prima di un RecreateWnd sparirebbe in
  // silenzio. Guardia Assigned: questo metodo gira anche durante inherited
  // Destroy, a coda già liberata.
  if Assigned(FCommandQueue) then
    FCommandQueue.MovePostedToDeferred;
  FermaAutoFitRitardato; // il timer e' legato all'HWND che sta per sparire
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

procedure TzDbCard.SetzDbCardProps(const Value: TzDbCardProps);
begin
  // R3: la card possiede i propri props (creati nel costruttore, liberati nel
  // distruttore). L'assegnazione esterna (usata dai test) copia il contenuto
  // invece di scambiare il puntatore: niente leak ne' double free.
  if Assigned(Value) and (Value <> FzDbCardProps) then
    FzDbCardProps.Assign(Value);
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
var
  Misura: boolean;
  Cronometro: TStopwatch;
begin
  if not zSystemOk then
    Exit;

  if not DataController.DataSetOk then
    Exit;

  if zControls.Count = 0 then
  begin
    // Misura per la sessione di registrazione attivabile dall'utente.
    Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
    if Misura then
      Cronometro := TStopwatch.StartNew;

    LoadProperties(true); // chiama gia' RebuildToolbar internamente
    Localizer.Translate(Self);

    if Misura then
      zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, 'TzDbCard.InitCard', Cronometro.ElapsedMilliseconds, Name);
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
  item: TzControl;
  s: string;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  if not Assigned(item.lkDataSet) then
  begin
    ConfirmOk(SDataSetLookupNonAssegnato);
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
    StartWait(SAttendere, true);
    try
      Domain.SaveToBase(true);
    finally
      StopWait;
    end;

    // R1: si conserva il nome, non il puntatore (vedi TFieldRebuildData)
    FieldRebuildData.Clear;
    FieldRebuildData.FieldName := zControl.name;
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

    StartWait(SAttendere, true);
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

  if ConfirmOkCancel(SRipristinoImpostazioni) then
    ReloadFromProps(true);
end;

procedure TzDbCard.ClearDependentFields(Field: TField);
var
  Domain: TzDomain;
  Origin: string;
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
    // NB: il reset dei lookup dipendenti (RevertSQL sui campi azzerati) e'
    // stato disattivato il 10.11.2022 — i combo non chiamano piu'
    // DataSet.Locate; qui restava solo un ciclo morto (if false), rimosso.
    DataController.ClearFields(Domain.FieldsToClear);

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
    ConfirmOk(SQueryCopiata);
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
        if ConfirmYesNo(SEliminoIlRecord) then
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
                    // R4: il reset del default invalido e' best-effort,
                    // ma l'errore non va perso
                    on e: Exception do
                      SiDbCard.LogException(e);
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
    dxBarToolbar.UseRestSpace := not dxBarToolbarFree.Visible;

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

  // Nessuna rottura di riga automatica: il motore manda gia' a capo da solo
  // il campo che non entra. La vecchia simulazione (AdjustRowForColSpan)
  // contava i caratteri invece delle colonne e salvava rpForceNewLine su
  // campi che nella card vera stavano gia' su una riga capiente.

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

      // Solo il prefisso: 'cardCreditCard' diventa 'CreditCard', non 'Credit'
      if result.StartsWith('card') then
        result := result.Substring(Length('card'));
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
  else
    // M1: ramo difensivo per eventuali nuovi valori dell'enum (e W1035)
    result := false;
  end;
end;

procedure TzDbCard.CreateFiltersFromProps;
// - una classe di filtro non registrata non solleva piu' l'eccezione che
// bloccava il caricamento della card: viene segnalata e saltata
// (TzToolFilterRegistry.ApplyFilter faceva Resolve, che solleva);
// - deduplicazione per istanza, prima assente;
// - una sola riapertura del dataset alla fine, prima nessuna.

var
  Bar: TdxBar;
begin
  if not DataController.DataSetOk then
    Exit;

  Bar := GetToolbar;
  if not Assigned(Bar) then
    Exit;

  // I TcxBarEditItem dei filtri sono linkati direttamente alla dxBar; la presenza
  // si gestisce distruggendo e ricreando gli item (prefisso toolFilter__), non con
  // un container. La pulizia la fa il builder.
  TzToolFilterBuilder.Build(zDbCardProps.ToolFilters, Self, Bar.BarManager, DataController.zFbDataSet,
    procedure(Testo: string)
    begin
      SiDbCard.LogWarning('CreateFiltersFromProps: ' + Testo);
    end);
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

  AggiornaValoreGriglia;
end;

procedure TzDbCard.popEditPopup(Sender: TObject);
var
  item: TzControl;
  DisplayLabel: string;
  ReadOnly: boolean;
  Required: boolean;
  s: string;
  SizeValue: integer;
  ColSpanValue: integer;
  Lines: integer;
  zCtrlType: TzCtrlType;
  IsLookup: boolean;
  IsDataAware: boolean;
  IsMultiLine: boolean;
  IsPicklist: boolean;
begin
  AggiornaAzioniMenuMemo;

  item := zControls.PopupCtrlItem;

  if not(Assigned(item) and IsAdmin) then
  begin
    dxBarEditCtrlCaption.Visible := dx.Visible(false);
    dxBarSpinEditCtrlSize.Visible := dx.Visible(false);
    dxBarSpinEditCtrlColSpan.Visible := dx.Visible(false);
    cxBarEditItemGriglia.Visible := dx.Visible(false);
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
  SizeValue := item.Size;
  Lines := item.Lines;

  IsDataAware := item.zCtrlType.IsDataAware;
  IsMultiLine := item.zCtrlType.IsMultiLine;
  /// ////////////////////////////////////////////////////////////////////

  dx.SetValue(dxBarEditCtrlCaption, DisplayLabel);
  dx.SetValue(dxBarSpinEditCtrlSize, SizeValue);
  dx.SetValue(dxBarSpinEditCtrlLines, Lines);
  dx.SetValue(cxBarItemCtrlType, TEnum<TzCtrlType>.EnumToString(zCtrlType));

  // Colonne: le fisse se ci sono, altrimenti quelle calcolate dal Size
  // nell'ultimo build, cosi' si leggono a colpo d'occhio sui campi vicini.
  if item.ColSpan = ColSpanPiena then
  begin
    ColSpanValue := Max(1, zDbCardProps.ColCount);
    dxBarSpinEditCtrlColSpan.Caption := 'Colonne (piena):';
  end
  else
  if item.ColSpan > 0 then
  begin
    ColSpanValue := item.ColSpan;
    dxBarSpinEditCtrlColSpan.Caption := 'Colonne:   ';
  end
  else
  begin
    ColSpanValue := item.BuiltColSpan;
    dxBarSpinEditCtrlColSpan.Caption := 'Colonne (auto):';
  end;
  dx.SetValue(dxBarSpinEditCtrlColSpan, ColSpanValue);

  s := dx.GetStatesString([ReadOnly, Required]);
  dx.SetValue(cxBarEditItemCtrlFlag, s);

  dxBarEditCtrlCaption.Visible := dx.Visible(IsAdmin);
  dxBarSpinEditCtrlSize.Visible := dx.Visible(IsAdmin);
  // Sempre visibile con la griglia attiva, salvo i booleani che non occupano
  // colonne: prima spariva sui campi senza colonne fisse ne' calcolate.
  dxBarSpinEditCtrlColSpan.Visible := dx.Visible(IsAdmin and zDbCardProps.SnapToGrid and not item.zCtrlType.IsBoolean);
  AggiornaValoreGriglia;
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

procedure TzDbCard.dxBarSpinEditCtrlColSpanChange(Sender: TObject);
var
  item: TzControl;
  NewColSpan: integer;
begin
  // Colonne fisse del campo del popup: 0 = torna al calcolo dal Size. Con la
  // griglia attiva prevalgono sul Size e valgono a ogni larghezza della card.
  item := zControls.PopupCtrlItem;
  if not Assigned(item) then
    Exit;

  NewColSpan := dxBarSpinEditCtrlColSpan.EditValue;
  NewColSpan := EnsureRange(NewColSpan, 0, Max(1, zDbCardProps.ColCount));
  if item.ColSpan = NewColSpan then
    Exit;

  item.ColSpan := NewColSpan;

  // RebuildLayout PRIMA di SaveProperties (vedi nota sul DlgWidth descalato).
  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.FissaColonneExecute(Sender: TObject);
var
  item: TzControl;
begin
  // Fissa su ogni campo le colonne che occupa adesso: la disposizione
  // corrente diventa indipendente dalla larghezza della card. I campi non
  // agganciati alla griglia (booleani, gruppi, nascosti) restano automatici.
  // I campi a larghezza piena restano tali: fissarli al numero di colonne
  // attuale li staccherebbe dal bordo destro al prossimo cambio di griglia.
  for item in zControls do
    if item.Visible and (item.BuiltColSpan > 0) and (item.ColSpan <> ColSpanPiena) then
      item.ColSpan := item.BuiltColSpan;

  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.LiberaColonneExecute(Sender: TObject);
var
  item: TzControl;
begin
  // Riporta tutti i campi al calcolo delle colonne dal Size.
  for item in zControls do
    item.ColSpan := 0;

  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.ColonneUpdate(Sender: TObject);
begin
  // Le colonne contano solo con la griglia attiva.
  ActionVisible(Sender as TAction, IsAdmin and zDbCardProps.SnapToGrid);
end;

procedure TzDbCard.AggiornaValoreGriglia;
begin
  // Selettore "Griglia" dei due menu: colonne correnti, solo con la griglia
  // attiva e per l'amministratore.
  cxBarEditItemGriglia.Visible := dx.Visible(IsAdmin and zDbCardProps.SnapToGrid);
  dx.SetValue(cxBarEditItemGriglia, IntToStr(Max(1, zDbCardProps.ColCount)));
end;

procedure TzDbCard.ImpostaColonneGriglia(const Colonne: integer);
var
  NuoveColonne: integer;
begin
  // Cambia le colonne della griglia della card. I campi con colonne fisse
  // piu' larghe della griglia nuova vengono limitati dal builder, quelli a
  // larghezza piena la seguono.
  NuoveColonne := EnsureRange(Colonne, 1, 99);
  if NuoveColonne <> zDbCardProps.ColCount then
  begin
    zDbCardProps.ColCount := NuoveColonne;
    // RebuildLayout PRIMA di SaveProperties (vedi nota sul DlgWidth descalato).
    RebuildLayout;
    SaveProperties;
  end;
  AggiornaValoreGriglia;
end;

procedure TzDbCard.cxBarEditItemGrigliaChange(Sender: TObject);
var
  Colonne: integer;
begin
  // Valore digitato nel selettore: un testo non numerico rimette il valore
  // corrente.
  Colonne := StrToIntDef(Trim(VarToStr(cxBarEditItemGriglia.EditValue)), 0);
  if Colonne > 0 then
    ImpostaColonneGriglia(Colonne)
  else
    AggiornaValoreGriglia;
end;

procedure TzDbCard.cxBarEditItemGrigliaPropertiesButtonClick(Sender: TObject; AButtonIndex: integer);
begin
  // Pulsanti del selettore, nell'ordine del DFM: meno, piu', Fissa, Libera.
  case AButtonIndex of
    0:
      ImpostaColonneGriglia(zDbCardProps.ColCount - 1);
    1:
      ImpostaColonneGriglia(zDbCardProps.ColCount + 1);
    2:
      FissaColonneExecute(FissaColonne);
    3:
      LiberaColonneExecute(LiberaColonne);
  end;
  // Il valore mostrato e' quello dell'editor aperto nel menu
  if Sender is TcxCustomEdit then
    TcxCustomEdit(Sender).EditValue := IntToStr(Max(1, zDbCardProps.ColCount));
end;

procedure TzDbCard.DistribuisciRigaExecute(Sender: TObject);
var
  item: TzControl;
  Candidato: TzControl;
  dxItem: TdxLayoutItem;
  Riga: TdxCustomLayoutGroup;
  CampiRiga: TList<TzControl>;
  Colonne: integer;
begin
  // Stessa larghezza a tutti i campi della riga del campo cliccato, e
  // griglia ridotta al multiplo esatto: la riga la riempie senza colonne
  // vuote (5 campi su 24 colonne -> 4 colonne ciascuno, griglia di 20).
  // I booleani non occupano colonne e restano fuori.
  item := zControls.PopupCtrlItem;
  if not Assigned(item) then
    Exit;

  dxItem := FindLayoutItem(item.name);
  if not Assigned(dxItem) or not Assigned(dxItem.Parent) then
    Exit;
  Riga := dxItem.Parent;

  CampiRiga := TList<TzControl>.Create;
  try
    for Candidato in zControls do
    begin
      if not Candidato.Visible or Candidato.zCtrlType.IsBoolean then
        Continue;
      dxItem := FindLayoutItem(Candidato.name);
      if Assigned(dxItem) and (dxItem.Parent = Riga) then
        CampiRiga.Add(Candidato);
    end;

    if CampiRiga.Count = 0 then
      Exit;

    Colonne := Max(1, Max(1, zDbCardProps.ColCount) div CampiRiga.Count);
    for Candidato in CampiRiga do
      Candidato.ColSpan := Colonne;
    zDbCardProps.ColCount := Colonne * CampiRiga.Count;
  finally
    FreeAndNil(CampiRiga);
  end;

  // RebuildLayout PRIMA di SaveProperties (vedi nota sul DlgWidth descalato).
  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.DistribuisciRigaUpdate(Sender: TObject);
var
  item: TzControl;
begin
  item := zControls.PopupCtrlItem;
  ActionVisible(Sender as TAction, IsAdmin and zDbCardProps.SnapToGrid and Assigned(item) and not item.zCtrlType.IsBoolean);
end;

procedure TzDbCard.LarghezzaPienaExecute(Sender: TObject);
var
  item: TzControl;
begin
  // Interruttore: larghezza piena <-> colonne calcolate dal Size
  item := zControls.PopupCtrlItem;
  if not Assigned(item) then
    Exit;

  if item.ColSpan = ColSpanPiena then
    item.ColSpan := 0
  else
    item.ColSpan := ColSpanPiena;

  // RebuildLayout PRIMA di SaveProperties (vedi nota sul DlgWidth descalato).
  RebuildLayout;
  SaveProperties;
end;

procedure TzDbCard.LarghezzaPienaUpdate(Sender: TObject);
var
  item: TzControl;
  Azione: TAction;
begin
  Azione := Sender as TAction;
  item := zControls.PopupCtrlItem;
  ActionVisible(Azione, IsAdmin and zDbCardProps.SnapToGrid and Assigned(item) and not item.zCtrlType.IsBoolean);
  Azione.Checked := Assigned(item) and (item.ColSpan = ColSpanPiena);
end;

procedure TzDbCard.GuideGrigliaExecute(Sender: TObject);
begin
  // Vale per tutte le card aperte: si allineano piu' schede di seguito
  FGuideGrigliaAttive := not FGuideGrigliaAttive;
  dxLayoutControl.Invalidate;
end;

procedure TzDbCard.GuideGrigliaUpdate(Sender: TObject);
var
  Azione: TAction;
begin
  Azione := Sender as TAction;
  ActionVisible(Azione, IsAdmin and zDbCardProps.SnapToGrid);
  Azione.Checked := FGuideGrigliaAttive;
end;

procedure TzDbCard.LayoutWindowProc(var Message: TMessage);
begin
  FLayoutWindowProc(Message);
  if (Message.Msg = WM_PAINT) and FGuideGrigliaAttive then
    DisegnaGuideGriglia;
end;

procedure TzDbCard.DisegnaGuideGriglia;
const
  ColoreGuida = TColor($00E0A060); // azzurro, leggibile sugli skin chiari e scuri
var
  DC: HDC;
  Tela: TCanvas;
  Origine: integer;
  Colonna: integer;
  x: integer;
  Altezza: integer;
  Riga: TdxCustomLayoutGroup;
  dxItem: TdxLayoutItem;
  item: TzControl;
  Etichetta: string;
begin
  if FIsDestroying or not IsAdmin then
    Exit;
  if not zDbCardProps.SnapToGrid or (FGrigliaColonne <= 1) or (FGrigliaCapacitaPx <= 0) then
    Exit;
  if not dxLayoutControl.HandleAllocated then
    Exit;

  // Origine: bordo sinistro dell'area item di una riga root (le righe dei
  // gruppi hanno una griglia propria, sulla capacita' del gruppo).
  Origine := -1;
  for item in zControls do
  begin
    if not item.Visible or not item.Group.IsEmpty then
      Continue;
    dxItem := FindLayoutItem(item.name);
    if not Assigned(dxItem) or not Assigned(dxItem.Parent) then
      Continue;
    Riga := dxItem.Parent;
    if (Riga.Parent = dxLayoutControl.Items) and Assigned(Riga.ViewInfo) and (Riga.ViewInfo is TdxLayoutGroupViewInfo) then
    begin
      Origine := TdxLayoutGroupViewInfo(Riga.ViewInfo).ItemsAreaBounds.Left;
      Break;
    end;
  end;
  if Origine < 0 then
    Exit;

  DC := GetDC(dxLayoutControl.Handle);
  if DC = 0 then
    Exit;
  Tela := TCanvas.Create;
  try
    Tela.Handle := DC;
    Altezza := dxLayoutControl.ClientHeight;
    Tela.Pen.Color := ColoreGuida;
    Tela.Pen.Style := psDot;
    Tela.Pen.Width := 1;
    Tela.Brush.Style := bsClear;
    Tela.Font.Assign(dxLayoutControl.Font);
    Tela.Font.Size := Max(6, dxLayoutControl.Font.Size - 2);
    Tela.Font.Color := ColoreGuida;

    // Ogni colonna ha due bordi: l'inizio e la fine prima del gutter. Un
    // campo allineato cade esattamente su queste linee.
    for Colonna := 0 to FGrigliaColonne - 1 do
    begin
      x := Origine + TzLayoutMetrics.GridColumnEdge(FGrigliaCapacitaPx, Colonna, FGrigliaColonne, FGrigliaGapPx);
      Tela.MoveTo(x, 0);
      Tela.LineTo(x, Altezza);

      Etichetta := IntToStr(Colonna + 1);
      Tela.TextOut(x + 2, 0, Etichetta);

      x := Origine + TzLayoutMetrics.GridColumnEdge(FGrigliaCapacitaPx, Colonna + 1, FGrigliaColonne, FGrigliaGapPx) - FGrigliaGapPx - 1;
      Tela.MoveTo(x, 0);
      Tela.LineTo(x, Altezza);
    end;
  finally
    Tela.Handle := 0;
    FreeAndNil(Tela);
    ReleaseDC(dxLayoutControl.Handle, DC);
  end;
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

  // B3: il TdxLayoutSeparatorItem nasce solo in BuildLayoutItems — senza
  // rebuild il separatore non compariva fino al successivo reload della card.
  RebuildLayout;
  SaveProperties;
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
            // Dopo il reflow: le righe sono quelle definitive per questa larghezza
            ApplyAutoFitHeight;
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
  // Reflow quasi-continuo durante il drag: il layout viene ricostruito a ogni
  // ~1 carattere (~CharWidth px) di variazione della capacita', cosi' le righe
  // seguono la finestra mentre la si ridimensiona invece di restare alla
  // larghezza vecchia (che, tra un rebuild e l altro, faceva comparire e
  // sparire lo scroll orizzontale: il comportamento irregolare). Valore piu
  // alto = rebuild piu radi (meno CPU nel resize continuo) ma scroll transitorio
  // piu marcato. 1 = massima fluidita.
  REFLOW_THRESHOLD_CHARS = 1;
var
  M: TzRowModel;
  Settle: boolean;
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
    // Rebuild anche quando il build precedente girava su capacita' STIMATA
    // (pre-visualizzazione) e ora c'e' quella reale: la differenza puo' stare
    // sotto soglia, ma vanno applicate le larghezze misurate dei gruppi.
    // Stesso motivo per FSettleRebuildPending, ma a livello di GRUPPO: vedi
    // NoteGroupCapacityEstimated.
    Settle := FSettleRebuildPending;
    if (Abs(M.RowMaxSize - FLastBuildRowMax) >= REFLOW_THRESHOLD_CHARS) or (FRowModelWasMeasured and not FLastBuildMeasured) or Settle then
    begin
      FSettleRebuildPending := false;
      FInReflow := true;
      try
        RebuildLayout; // aggiorna FLastBuildRowMax: la soglia chiude il ciclo
      finally
        FInReflow := false;
      end;

      // Solo per l'assestamento (non per un resize dell'utente, dove
      // riallineare la larghezza combatterebbe col trascinamento): il rebuild
      // puo' aver cambiato il numero di righe, quindi in dialogo l'altezza va
      // ricalcolata.
      if Settle and (Owner is TzDbCardForm) then
        TzDbCardForm(Owner).UpdateHeight;
    end;
  finally
    M.Free;
  end;
end;

procedure TzDbCard.ApplyAutoFitHeight(const Ritardato: boolean = false);
// AutoFitHeight: porta l'elemento di layout che ospita la card all'altezza del
// contenuto (CalcDialogHeight), cosi' la card sopra una griglia non mostra la
// barra di scorrimento verticale e non lascia spazio vuoto. Si adatta anche
// quando la finestra cambia larghezza e le righe si riavvolgono.
//
// Lavora solo se la card e' l'unico controllo del suo elemento in un
// TdxLayoutControl e l'elemento non riempie gia' lo spazio verticale (avClient).
// In un gruppo a linguette (form costruite dal dizionario LZ,
// dxLayoutGroup<ds>Controls) l'altezza e' del gruppo e non della card: la card
// passa l'altezza voluta a OnAutoFitHeight e la dimensiona il FormController.
// Il dialogo di modifica (TzDbCardForm) ha gia' UpdateHeight.
//
// Ritardato: chiamata dal timer dopo un cambio di record (ProgrammaAutoFitRitardato).
// Un adattamento per record non e' un ciclo: il conteggio anti-ciclo riparte.
//
// Senza sfarfallio: gira dal messaggio cmd_Resize, che Windows consegna prima
// del WM_PAINT, solo a disposizione definitiva (larghezza misurata, nessuna
// ricostruzione in coda), e il cambio di altezza sta in un solo
// BeginUpdate/EndUpdate del layout che la ospita: un ricalcolo e un ridisegno.
//
// Divisore: se SizeOptions.Height dell'elemento non e' piu' quella lasciata
// dall'ultimo adattamento, l'ha cambiata qualcun altro (l'utente col divisore,
// il codice della form): da li' la card non si adatta piu', per tutta la vita
// della form, invece di annullare la scelta al resize successivo.
const
  SOGLIA_PX = 3; // differenze minori non valgono un ridisegno
  MAX_PASSAGGI = 3; // limite anti-ciclo fra un azzeramento e l'altro
  AZZERA_LARGHEZZA_96 = 40; // oltre la larghezza di una barra di scorrimento
  MIN_RESTO_96 = 100; // spazio minimo lasciato agli altri elementi del gruppo
var
  Host: TdxLayoutControl;
  Item: TdxLayoutItem;
  Altezza: integer;
  Disponibile: integer;
  Resto: integer;
begin
  if not AutoFitHeight or FAutoFitSospeso then
    Exit;
  if IsDestroying or not Showing or IsCreatingControls then
    Exit;
  if Owner is TzDbCardForm then
    Exit;
  if not(Parent is TdxLayoutControl) then
    Exit;
  if dxLayoutControl.Customization then
    Exit; // editor visuale aperto: non toccare il layout sotto i piedi

  // Disposizione definitiva: la prima, stimata, darebbe un'altezza sbagliata e
  // un salto visibile al build successivo
  if not FLastBuildMeasured or FSettleRebuildPending then
    Exit;
  if Assigned(FCommandQueue) then
    if FCommandQueue.IsPending(cmd_LoadProperties) or FCommandQueue.IsPending(cmd_RebuildControls) then
      Exit;

  Host := TdxLayoutControl(Parent);
  Item := Host.FindItem(Self);
  if not Assigned(Item) or not Assigned(Item.Parent) then
    Exit;
  if Ritardato then
    FAutoFitPassaggi := 0;

  // Gruppo a linguette: dimensiona il gruppo del dataset chi ha costruito il
  // layout. Il riferimento per la sospensione (divisore) lo tiene lui.
  if Item.Parent.LayoutDirection = ldTabbed then
  begin
    if not Assigned(FOnAutoFitHeight) then
      Exit;
    if Abs(Width - FAutoFitLarghezza) > MulDiv(AZZERA_LARGHEZZA_96, CurrentPPI, 96) then
    begin
      FAutoFitLarghezza := Width;
      FAutoFitPassaggi := 0;
    end;
    Altezza := CalcDialogHeight;
    // Anche ad altezza gia' giusta si avvisa: il FormController prende il
    // riferimento che gli serve per riconoscere il divisore mosso dall'utente
    if Abs(Altezza - Height) > SOGLIA_PX then
    begin
      if FAutoFitPassaggi >= MAX_PASSAGGI then
        Exit;
      Inc(FAutoFitPassaggi);
    end;
    FOnAutoFitHeight(Self, Altezza, true);
    Exit;
  end;

  if Item.AlignVert = avClient then
    Exit;

  if not FAutoFitArmato then
  begin
    FAutoFitAltezzaApplicata := Item.SizeOptions.Height;
    FAutoFitArmato := true;
  end
  else
    if Item.SizeOptions.Height <> FAutoFitAltezzaApplicata then
    begin
      FAutoFitSospeso := true;
      Exit;
    end;

  // Il conteggio si azzera solo per variazioni di larghezza vere: la comparsa
  // di una barra di scorrimento esterna non deve riaprire il ciclo
  if Abs(Width - FAutoFitLarghezza) > MulDiv(AZZERA_LARGHEZZA_96, CurrentPPI, 96) then
  begin
    FAutoFitLarghezza := Width;
    FAutoFitPassaggi := 0;
  end;
  if FAutoFitPassaggi >= MAX_PASSAGGI then
    Exit;

  Altezza := CalcDialogHeight;

  // Tetto: gli altri elementi del gruppo (la griglia sotto) non scendono sotto
  // MIN_RESTO_96; oltre resta la barra di scorrimento della card
  if Assigned(Item.Parent.ViewInfo) then
  begin
    Disponibile := Item.Parent.ViewInfo.ItemsAreaBounds.Height;
    Resto := 0;
    if Item.Parent.VisibleCount > 1 then
      Resto := MulDiv(MIN_RESTO_96, CurrentPPI, 96);
    if Disponibile - Resto > 0 then
      Altezza := Min(Altezza, Disponibile - Resto);
  end;

  if Abs(Altezza - Height) <= SOGLIA_PX then
    Exit;

  Inc(FAutoFitPassaggi);
  Host.BeginUpdate;
  try
    Item.SizeOptions.Height := Altezza;
  finally
    Host.EndUpdate;
  end;
  FAutoFitAltezzaApplicata := Item.SizeOptions.Height;
end;

const
  AUTOFIT_TIMER_ID = $5A46; // WM_TIMER della card per l'adattamento ritardato
  AUTOFIT_CONTROLLO_MS = 500; // ogni quanto si ricontrollano le condizioni
  AUTOFIT_ATTESA_MS = 1500; // inattivita' dell'utente prima di adattare

function TzDbCard.GetAutoFitHeight: boolean;
begin
  result := FAutoFitHeight or (Assigned(FzDbCardProps) and FzDbCardProps.AutoFitHeight);
end;

function TzDbCard.IsAutoFitHeightStored: boolean;
begin
  // Nel DFM solo il valore impostato sul componente, non quello del dizionario
  result := FAutoFitHeight;
end;

procedure TzDbCard.ProgrammaAutoFitRitardato;
// Cambio di record (o di un valore) con AutoFitHeight: i campi visibili possono
// cambiare, e con loro l'altezza della card. Non si adatta subito, perche' chi
// scorre i record velocemente vedrebbe saltare il divisore a ogni riga: il timer
// riparte a ogni richiesta e l'adattamento arriva quando l'utente si ferma
// (AutoFitPuoSpostare). Indipendente dal focus: conta che la card sia visibile.
begin
  if not AutoFitHeight or FAutoFitSospeso then
    Exit;
  if IsDestroying or not Showing or not HandleAllocated then
    Exit;
  if Owner is TzDbCardForm then
    Exit;

  FAutoFitRichiesta := GetTickCount;
  // SetTimer con lo stesso identificativo sostituisce il timer gia' attivo
  if SetTimer(Handle, AUTOFIT_TIMER_ID, AUTOFIT_CONTROLLO_MS, nil) <> 0 then
    FAutoFitRitardoAttivo := true;
end;

procedure TzDbCard.FermaAutoFitRitardato;
begin
  if FAutoFitRitardoAttivo and HandleAllocated then
    KillTimer(Handle, AUTOFIT_TIMER_ID);
  FAutoFitRitardoAttivo := false;
end;

function TzDbCard.AutoFitPuoSpostare: boolean;
// Si adatta solo quando l'utente non sta facendo niente da AUTOFIT_ATTESA_MS
// (tastiera, mouse, rotellina: GetLastInputInfo) e il puntatore non e' sopra
// cio' che si sposterebbe, cioe' tutto quello che sta sotto la card nello stesso
// layout (divisore e dettagli, o la griglia): una riga scelta col mouse non deve
// muoversi un attimo prima del clic.
var
  UltimoInput: TLastInputInfo;
  Adesso: cardinal;
  Puntatore: TPoint;
  Zona: TRect;
  Host: TWinControl;
begin
  result := false;
  Adesso := GetTickCount;

  if Adesso - FAutoFitRichiesta < AUTOFIT_ATTESA_MS then
    Exit;

  UltimoInput.cbSize := SizeOf(UltimoInput);
  if GetLastInputInfo(UltimoInput) then
    if Adesso - UltimoInput.dwTime < AUTOFIT_ATTESA_MS then
      Exit;

  // Tasto premuto: trascinamento del divisore o selezione in corso
  if (GetAsyncKeyState(VK_LBUTTON) < 0) or (GetAsyncKeyState(VK_RBUTTON) < 0) then
    Exit;

  if GetCursorPos(Puntatore) then
  begin
    Host := Parent;
    if Assigned(Host) and Host.HandleAllocated then
    begin
      Zona := Rect(Left, BoundsRect.Bottom - MulDiv(4, CurrentPPI, 96), Left + Width, Host.ClientHeight);
      Zona.TopLeft := Host.ClientToScreen(Zona.TopLeft);
      Zona.BottomRight := Host.ClientToScreen(Zona.BottomRight);
      if Zona.Contains(Puntatore) then
        Exit;
    end;
  end;

  result := true;
end;

procedure TzDbCard.RichiediAutoFitHeight;
begin
  if not AutoFitHeight or IsDestroying then
    Exit;
  FAutoFitPassaggi := 0;
  PostInternalMessage(cmd_Resize);
end;

procedure TzDbCard.WMTimer(var Message: TWMTimer);
begin
  if Message.TimerID <> AUTOFIT_TIMER_ID then
  begin
    inherited;
    Exit;
  end;

  if IsDestroying or not Showing then
  begin
    FermaAutoFitRitardato;
    Exit;
  end;

  if not AutoFitPuoSpostare then
    Exit; // si riprova al prossimo giro

  FermaAutoFitRitardato;
  ApplyAutoFitHeight(true);
end;

procedure TzDbCard.NoteGroupCapacityEstimated(const ACount: integer);
// Chiamata al termine di ogni BuildLayoutItems con il numero di gruppi la cui
// capacita' interna e' stata STIMATA invece che misurata (vedi
// TzCardLayoutBuilder.EstimatedGroups).
//
// Perche' serve: i campi dentro un gruppo vengono dimensionati sulla capacita'
// del gruppo. Al PRIMO build quella capacita' non e' misurabile (il ViewInfo
// non e' ancora calcolato) e viene stimata dal Size nominale o dalla larghezza
// di riga. Se la stima eccede l'area vera, gli item a larghezza fissa non si
// comprimono - dxLayoutControl assegna comunque la larghezza dichiarata agli
// item non-client - e l'eccesso resta come scroll orizzontale permanente.
// Si programma percio' UN rebuild differito sulla stessa coda del reflow da
// resize: quando viene eseguito il layout e' calcolato e le larghezze reali
// sono leggibili. Nei dialoghi, che di norma non ricevono mai un resize, e'
// l'unica occasione di correggere la stima.
const
  MAX_SETTLE_REBUILDS = 2; // limite anti-ciclo: oltre si tiene il layout stimato
begin
  if ACount <= 0 then
  begin
    // tutte le capacita' vengono da misure reali: ciclo chiuso
    FSettleRebuilds := 0;
    FSettleRebuildPending := false;
    Exit;
  end;

  if not Showing then
    Exit; // senza ViewInfo valido il rebuild rifarebbe la stessa stima

  if FSettleRebuilds >= MAX_SETTLE_REBUILDS then
    Exit;

  Inc(FSettleRebuilds);
  FSettleRebuildPending := true;
  PostInternalMessage(cmd_Resize);
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
  // M7: acquisizione da webcam non ancora implementata; l'azione e' nascosta
  // in Create (prima ripiegava in silenzio sul file dialog, fuorviante).
end;

procedure TzDbCard.ForceControlsValidation(ChangedField: TField);
var
  item: TzControl;
begin
  SiDbCard.LogVerbose('ForceControlsValidation');

  if not IsDestroying then
    if DataController.DataSetOk then
      if DataController.IsEditing then
        for item in zControls do
          if (ChangedField = nil) or SameText(item.name, ChangedField.FieldName) then
            item.ForceValidation;
end;

procedure TzDbCard.ForceDisplay;
begin
  InitCard;
end;

function TzDbCard.GetDialogTitle: string;
begin
  result := zDbCardProps.Caption;

  if SameText(zDefaultCardCaption, zDbCardProps.Caption) then
  begin
    if zDbCardProps.Title <> '' then
      result := zDbCardProps.Title
    else
      result := EstraiCaptionDaIdDataSet(zDataSet.IdDataSet);
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
    ForceControlsValidation;

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

  // Mantis #298 - 2026-10-29: i -1 dei lookup si azzerano anche dopo OnNewRecord.
  // DataSourceStateChange chiama ClearInvalidDefaultValues quando lo stato passa
  // a dsInsert, ma TDataSet.EndInsertAppend cambia lo stato PRIMA di OnNewRecord,
  // e TzFbDataSet.DoOnNewRecord riapplica subito dopo le DefaultExpression: il -1
  // del dominio FOREIGN_KEY tornava nel campo. Il combo cercava -1 con LocateSQL,
  // il lookup si riapriva con "AND <chiave> = -1" e la tendina restava vuota
  // (Rettifica incarico, pagina Corsi: ID_CORSO di INCARICHI_CORSI).
  // Il rilascio 001 lo correggeva in dbInsert, solo per il pulsante della scheda;
  // qui vale per ogni inserimento, anche da codice: l'avviso sull'intera riga
  // (Field = nil) arriva dopo OnNewRecord, da EndInsertAppend o da EnableControls.
  if not Assigned(Field) then
    if not IsDestroying then
      if Assigned(zDataSet) and (zDataSet.State = dsInsert) then
        ClearInvalidDefaultValues;

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

  // P3: alla modifica di un singolo campo si validano e ricolorano solo i
  // controlli interessati; il giro completo resta per i cambi di record/stato
  // (Field = nil).
  ForceControlsValidation(Field);
  UpdateColors(Field);

  // Record o valore cambiato: i campi visibili, e quindi l'altezza, possono
  // essere diversi. Adattamento ritardato, vedi ProgrammaAutoFitRitardato.
  ProgrammaAutoFitRitardato;
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
  ctrlProps: TzControlProps;
begin
  result := true;

  if not DataController.IsEditing then
    Exit;

  msg := '';
  ErrorFields := '';
  ErrorCount := 0;

  for ctrlProps in zDbCardProps.Controls do
    // DIV-CTL-1: un campo nascosto da codice con HideField conserva Visible vero nelle
    // impostazioni (si salva la visibilita' precedente): l'utente non lo vede, quindi
    // non si pretende che lo compili
    if ctrlProps.Visible and not zControls.FieldsHiddenByCode.ContainsKey(ctrlProps.name) then
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
      msg := SCampiObbligatori + #13 + #13 + ErrorFields;
      ConfirmOk(msg);
      System.SysUtils.Abort;
    end;
  end;
end;

procedure TzDbCard.UpdateColors(ChangedField: TField);
var
  item: TzControl;
  Field: TField;
begin
  if DataController.IsActive then
    for item in zControls do
    begin
      // P3: con un campo specifico si aggiorna solo il suo controllo
      if (ChangedField <> nil) and not SameText(item.name, ChangedField.FieldName) then
        Continue;

      if DataController.TryGetField(item.name, Field) then
      begin
        item.FieldReadOnly := Field.ReadOnly;
        item.FieldRequired := Field.Required;
        item.UpdateColor;
      end;
    end;
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
    result := Null;

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
    FLookupBinding.AssignMasterParams(DataSet, ParamsChanged);

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
  // Si aggiorna il dataset del combo (solo per i veri lookup: un ctComboDlg
  // non ha il dataset principale e qui andava in AV con lkDataSet = nil)
  if Assigned(lkDataSet) then
  begin
    InitLookupProperties;
    FLookupBinding.ReapplyDataSetProps;
    lkDataSet.ReOpen();
  end;

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
  // M10: rimosso l'inherited fantasma (nessun metodo omonimo nell'ancestor)

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
begin
  if Assigned(lkDataSet) then
    FLookupBinding.VerifyParams
  else
    if zCtrlType = ctCheckComboBox then
      FillCheckComboBoxItems;
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
  // Da view -> insert i campi calcolati preinizializzati (es. master/detail)
  // non risultano visibili senza una copia esplicita dei mapping

  for item in zControls do
    item.CopyMappingFields();
end;

procedure TzDbCard.ModificaMemoExecute(Sender: TObject);
begin
  if zControls.PopupCtrlIsClass(ctMemo) then
  begin
    zControls.DataSet.CheckEditMode;
    // stesse azioni personalizzate di F2 (TzControl.KeyDown), prima mancavano
    zExecuteMemoDialog(TcxCustomMemo(zControls.PopupCtrl), '', zControls.PopupCtrlItem.GetCustomActions);
  end;
end;

procedure TzDbCard.AggiornaAzioniMenuMemo;
var
  item: TzControl;
  Pulsante: TdxBarButton;
  Collegamento: TdxBarItemLink;
  Posizione: Integer;
  Indice: Integer;
begin
  for Pulsante in PulsantiAzioniMenuMemo do
    Pulsante.Free;
  PulsantiAzioniMenuMemo := nil;
  AzioniMenuMemo := nil;

  // stessa regola del pulsante nel dialogo del memo: solo i memo con azioni
  // personalizzate, ognuna visibile e abilitata come la sua TAction
  item := zControls.PopupCtrlItem;
  if not Assigned(item) or (item.zCtrlType <> ctMemo) or not item.HasCustomActions then
    Exit;

  AzioniMenuMemo := item.GetCustomActions;

  Posizione := 0;
  for Indice := 0 to popEdit.ItemLinks.Count - 1 do
    if popEdit.ItemLinks[Indice].Item = dxBarButton8 then
      Posizione := Indice + 1;

  for Indice := 0 to High(AzioniMenuMemo) do
  begin
    AzioniMenuMemo[Indice].Update;

    Pulsante := TdxBarButton.Create(dxBarManager);
    Pulsante.Tag := Indice;
    Pulsante.OnClick := AzioneMenuMemoClick;

    if AzioniMenuMemo[Indice] is TCustomAction then
    begin
      Pulsante.Caption := TCustomAction(AzioniMenuMemo[Indice]).Caption;
      Pulsante.Hint := TCustomAction(AzioniMenuMemo[Indice]).Hint;
      Pulsante.Enabled := TCustomAction(AzioniMenuMemo[Indice]).Enabled;
      Pulsante.Visible := dx.Visible(TCustomAction(AzioniMenuMemo[Indice]).Visible);
    end
    else
      Pulsante.Caption := AzioniMenuMemo[Indice].Name;

    Collegamento := popEdit.ItemLinks.Add(Pulsante);
    Collegamento.Index := Posizione + Indice;

    PulsantiAzioniMenuMemo := PulsantiAzioniMenuMemo + [Pulsante];
  end;
end;

procedure TzDbCard.AzioneMenuMemoClick(Sender: TObject);
var
  Indice: Integer;
begin
  if not zControls.PopupCtrlIsClass(ctMemo) then
    Exit;

  Indice := (Sender as TdxBarButton).Tag;
  if (Indice < 0) or (Indice > High(AzioniMenuMemo)) then
    Exit;

  // l'azione lavora sul memo del dialogo (Tag impostato da InitCustomActions):
  // si apre il dialogo come con Modifica e l'azione parte appena e' visibile
  zControls.DataSet.CheckEditMode;
  zExecuteMemoDialog(TcxCustomMemo(zControls.PopupCtrl), '', zControls.PopupCtrlItem.GetCustomActions, nil, False, AzioniMenuMemo[Indice]);
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

  // B2: il nuovo TcxCustomEdit va riagganciato al TdxLayoutItem del campo;
  // RefreshVisibility da sola lasciava il controllo orfano del layout.
  // RebuildLayout PRIMA di SaveProperties (vedi nota sul DlgWidth descalato).
  RebuildLayout;
  SaveProperties;
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
  // Coalescenza, differimento a card nascosta e trasferimento su RecreateWnd:
  // vedi TzDeferredCommandQueue (zDbCard.Commands).
  if Assigned(FCommandQueue) then
    FCommandQueue.Post(cmd, lparam);
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
    if Assigned(FCommandQueue) then
      FCommandQueue.ReleaseLatch(cmd_Resize);

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
      if Assigned(FCommandQueue) then
        FCommandQueue.ReleaseLatch(cmd);
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
    ConfirmOk(SCampiCopiati);
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
begin
  // Parte dal nome nudo (senza suffisso) e aggiunge _N solo in collisione.
  result := MakeUniqueName(Name, 0,
    function(CandidateName: string): boolean
    begin
      result := Assigned(FindComponent(CandidateName));
    end);
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
    // R4: la formattazione del display e' cosmetica e non deve propagare,
    // ma l'errore non va perso
    on e: Exception do
      SiDbCard.LogException(e);
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

  // BeginGroup era letta non inizializzata alla prima voce del menu
  BeginGroup := false;

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
    GroupExpandButton := zControlProps.GroupExpandButton;
    GroupExpanded := zControlProps.GroupExpanded;
    ImageName := zControlProps.ImageName;

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

  // B4: <= 0 e non = -1 — a DPI diversi da 96 il sentinella scalato non
  // valeva piu' esattamente -1 e i fallback non scattavano.
  if result <= 0 then
    result := CalcSuggestedDialogWidth;
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
begin
  if IsDestroying then
    Exit;

  // Coalescenza e scrittura in thread: vedi TzDeferredSaver (zDbCard.Saver).
  // OnPrepare = DescaleDlgSizeForSave (thread UI), OnExecuteSave =
  // InternalSaveProperties (background), OnRepostRequest = nuova richiesta
  // per le modifiche arrivate mentre il task era in volo.
  FSaver.RequestSave;
end;

procedure TzDbCard.RequestDeferredSave;
begin
  PostInternalMessage(cmd_SaveProperties);
end;

procedure TzDbCard.UpdateSavedLayoutCaption(const FieldName, NewCaption: string);
var
  lz: TzLayoutItem;
begin
  // Allinea la caption serializzata nel layout salvato: SaveToLayout la
  // riapplicherebbe al prossimo rebuild, annullando il rename fatto dal popup.
  // Get senza aggiunta: se la voce non e' nel layout salvato non c'e' niente
  // da allineare. Con l'aggiunta predefinita nasceva una voce senza padre e con
  // Idx 0, che SaveToLayout spostava in cima alla radice a tutta larghezza.
  lz := zDbCardProps.Layout.Get(NameForField(FieldName), false);
  if not Assigned(lz) then
    lz := zDbCardProps.Layout.Get(NameForGroup(FieldName), false);
  if Assigned(lz) then
    lz.Caption := NewCaption;
end;

function TzDbCard.NewRowModel: TzRowModel;
var
  w: integer;
  areaWidth: integer;
  ParentForm: TCustomForm;
begin
  // Capacità della radice CALCOLATA dai valori reali del motore (client width
  // del layout control − offset radice − riserva scrollbar): tiene build e
  // SyncLayoutFromEditor sulla stessa larghezza.
  // NB: mai misurarla dal contenuto (ItemsAreaBounds/ContentBounds): un
  // overflow si auto-alimenterebbe a ogni rebuild.
  // Mantis #306 - 2026-10-30: misura anche prima della comparsa, quando la
  // card ha gia' l'handle e la larghezza del suo contenitore. Prima si misurava
  // solo con Showing: la card di una form non ancora mostrata (wizard,
  // FormController) veniva costruita con la stima di DlgWidth (-1 = 650 px
  // fissi) anche se il layout control era gia' largo 1004 px, e alla comparsa
  // CheckReflow la ricostruiva con le righe vere: l'utente vedeva i campi
  // riallinearsi un istante dopo l'apertura. Il dialogo TzDbCardForm resta
  // sulla stima di GetDialogWidth: la sua larghezza la imposta LoadProps dopo
  // il primo build, e il salto lo nasconde gia' EnsureLayoutSettled.
  // ZC 30.10.2026 - Mantis #306: la condizione HandleAllocated non scattava mai.
  // Prima della comparsa la VCL ha creato la finestra della form ma non quelle
  // dei controlli figli: la card arrivava qui senza handle e restava sulla stima
  // (provato sul banco: cardIncarico del wizard costruita a 650 px, poi
  // ricostruita 450 ms dopo OnShow). La finestra del layout control nasceva
  // comunque pochi istanti dopo, dentro il build. Ora, se la form ha gia' la sua
  // finestra, la si crea qui con HandleNeeded e si misura il valore vero, lo
  // stesso che il build vedra'. Senza finestra della form (catena dei Parent non
  // ancora completa, form non ancora creata) si resta sulla stima: HandleNeeded
  // creerebbe la form fuori tempo o solleverebbe "Control has no parent window".
  areaWidth := 0;
  if not Showing and not (Owner is TzDbCardForm) and Assigned(dxLayoutControl) and not dxLayoutControl.HandleAllocated then
  begin
    ParentForm := GetParentForm(dxLayoutControl);
    if Assigned(ParentForm) and ParentForm.HandleAllocated then
      dxLayoutControl.HandleNeeded;
  end;
  if Showing or (Assigned(dxLayoutControl) and dxLayoutControl.HandleAllocated and not (Owner is TzDbCardForm)) then
    areaWidth := TzLayoutMetrics.RootCapacityWidth(dxLayoutControl);

  FRowModelWasMeasured := areaWidth > 0;

  if areaWidth > 0 then
    Exit(TzRowModel.CreateFromAreaWidth(areaWidth, Font));

  // Fallback (primo Build dentro LoadProperties, layout mai calcolato):
  // stima con i margini storici. Preferisce la larghezza viva del frame:
  // zDbCardProps.DlgWidth resta in unità 96-dpi tra un SaveProperties e il
  // LoadProperties successivo, e non riflette un resize manuale del dialogo.
  // Nel dialogo la card occupa tutta la larghezza della form, che LoadProps
  // imposta a GetDialogWidth: stimare dallo stesso valore (gia' riconvertito
  // in pixel reali) avvicina la prima disposizione a quella misurata dopo la
  // comparsa. DlgWidth grezzo puo' essere in unita' 96-dpi e a 125-150% dava
  // righe piu' corte del vero, quindi una disposizione diversa.
  if Showing and (ClientWidth > 0) then
    w := ClientWidth
  else
    if Owner is TzDbCardForm then
      w := GetDialogWidth
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
  begin
    // B4: i sentinella (<= 0 = "mai salvato") non vanno scalati, altrimenti a
    // DPI > 100% -1 diventa -2 e i fallback su "non impostato" non scattano.
    if Value <= 0 then
      Exit(Value);

    result := Min(MulDiv(Value, Self.CurrentPPI, 96), maxValue);
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
    // R6: si memorizza la visibilita' PRECEDENTE, che e' quella che verra'
    // persistita da SaveToProps (la scelta di codice resta solo di runtime).
    if not zControls.FieldsHiddenByCode.ContainsKey(FieldName) then
      zControls.FieldsHiddenByCode.Add(FieldName, ctrl.Visible);

    ctrl.Visible := false;
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

        StartWait(SAttendere, true);
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
      StartWait(SAttendere, true);
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
    StartWait(SAttendere, true);
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
  zControl: TzControl;
  Domain: TzDomain;
begin
  if not FieldRebuildData.Valid then
    Exit;

  // R1: il comando e' differito e la collection puo' essere stata ricostruita
  // nel frattempo — il controllo si risolve per nome al momento del dispatch.
  zControl := zControls.Find(FieldRebuildData.FieldName);
  Domain := FieldRebuildData.Domain;
  FieldRebuildData.Clear;

  if not Assigned(zControl) then
    Exit;

  ctrlProps := zDbCardProps.Controls.Get(zControl.name);

  zControl.RebuildControls(ctrlProps, Domain);

  // B2: il nuovo TcxCustomEdit va riagganciato al TdxLayoutItem del campo;
  // RefreshVisibility da sola lasciava il controllo orfano del layout.
  RebuildLayout;
end;

procedure TzDbCard.SaveDescription;
begin
  zDbCardProps.Description.Assign(FrameDescription.zDescription);
  zDbCardProps.Description.SaveToIni(CardID);
  Descrizione.Checked := zDbCardProps.Description.Visible;
end;

procedure TzDbCard.TFieldRebuildData.Clear;
begin
  FieldName := '';
  Domain := nil;
end;

function TzDbCard.TFieldRebuildData.Valid: boolean;
begin
  result := FieldName <> '';
end;

procedure TzDbCard.ChangeScale(M, D: integer; isDpiChange: boolean);
begin
  inherited;
  if isDpiChange then
  begin
    // La scalatura riscrive SizeOptions.Height dell'elemento: non e' un
    // divisore spostato, il riferimento si riprende al prossimo adattamento.
    FAutoFitArmato := false;
    // non serve RebuildControls qui: verrà chiamato da Resize
    // ma se la card è già visualizzata:
    if zControls.Count > 0 then
      PostInternalMessage(cmd_Resize);
  end;
end;

function TzDbCard.CalcDialogHeight(doDisplayControls: boolean = false): integer;
const
  TOOLBAR_MARGIN = 15;
  DEFAULT_ROW_HEIGHT = 46; // caption(20) + controllo(20) + spacing(6)
var
  ToolbarHeight: integer;
  ContentH: integer;
  LayoutPronto: boolean;
begin
  if doDisplayControls then
    RefreshVisibility;

  // Il layout e' calcolabile solo quando il controllo ha un handle e una larghezza
  // reale. Durante l'apertura della form (OpenDataSets/ApplyPK) la card non e'
  // ancora mostrata: forzare qui il calcolo del contenuto dereferenzia ViewInfo
  // di item non ancora costruiti -> Access Violation in dxLayoutContainer.
  LayoutPronto := dxLayoutControl.HandleAllocated and (dxLayoutControl.Width > 0);

  ContentH := 0;

  if LayoutPronto then
    try
      // OccupiedClientHeight restituisce l'altezza INTRINSECA richiesta dal
      // contenuto del layout (RootViewInfo.CalculateHeight con il flag
      // FIsOccupiedSizeCalculating attivo), quindi IGNORA lo stretch verticale.
      // NON usare ContentBounds: quello riflette gli item GIA' disposti e, con la
      // card Align=alClient piu' alta del contenuto, gli item avTop/avClient si
      // stirano per riempire l'area -> ContentBounds.Height finisce per valere
      // quasi tutta la client area e sotto l'ultimo controllo resta uno spazio
      // vuoto che si auto-alimenta ad ogni riapertura del dialogo.
      // Doc DevExpress: per l'altezza occupata dal contenuto usare
      // OccupiedClientHeight, non ContentBounds.
      ContentH := dxLayoutControl.OccupiedClientHeight;
    except
      // Layout in stato inconsistente (ViewInfo parziale in fase di costruzione):
      // non far salire l'eccezione, si usa il fallback qui sotto.
      ContentH := 0;
    end;

  if ContentH <= 0 then
    // Fallback: layout non pronto o non ancora calcolato (ViewInfo -> -1).
    ContentH := dxLayoutControl.items.Count * DEFAULT_ROW_HEIGHT;

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

function TzDbCard.EnsureLayoutSettled: boolean;
// True quando la disposizione dei campi e' definitiva: nessun rebuild in coda
// e l'ultimo BuildLayoutItems ha usato la larghezza reale, non quella stimata.
// La usa TzDbCardForm per tenere il dialogo trasparente finche' la card si
// assesta, cosi' l'utente non vede la prima disposizione stimata e poi il
// salto a quella definitiva.
// Se l'ultimo build e' stimato e non c'e' niente in coda che lo corregga (per
// esempio una riapertura senza variazioni di dimensione), posta un cmd_Resize:
// CheckReflow vede FRowModelWasMeasured and not FLastBuildMeasured e ricostruisce.
begin
  // card nascosta o in distruzione: i comandi restano deferred, aspettarli
  // terrebbe il dialogo invisibile senza motivo
  if IsDestroying or not Showing or not Assigned(FCommandQueue) then
    Exit(true);

  if FCommandQueue.IsPending(cmd_LoadProperties) or FCommandQueue.IsPending(cmd_RebuildControls) or FCommandQueue.IsPending(cmd_Resize) or FSettleRebuildPending then
    Exit(false);

  if Assigned(zControls) and (zControls.Count > 0) and (FLastBuildRowMax > 0) and not FLastBuildMeasured then
  begin
    PostInternalMessage(cmd_Resize);
    Exit(false);
  end;

  result := true;
end;

// =============================================================================
// TzDbCard.ClearLayoutItems
// Rimuove dal dxLayoutControl solo gli item generati dal controller
// (GetFlagUserDefined = False). Stacca Control := nil prima del Free.
// =============================================================================
procedure TzDbCard.ClearLayoutItems;
begin
  // Delegato al builder (zDbCard.Layout): rimuove gli item generati dal
  // controller senza distruggere i controlli ospitati.
  TzCardLayoutBuilder.ClearGeneratedItems(dxLayoutControl);
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
  IsFirstRow: boolean;
  RowModel: TzRowModel;
  pname: string;
  runtimeCtrl: TzControl;
  runtimeIdx: integer;
  // P1: indici locali nome -> oggetto, costruiti una volta a inizio sync.
  // Prima ogni campo passava da zControls.Find / Controls.Get lineari, e con
  // i cicli su AbsoluteItemCount la chiusura dell'editor era O(n^2)-O(n^3).
  CtrlIndex: TDictionary<string, TzControl>;
  PropsIndex: TDictionary<string, TzControlProps>;

  function FindCtrl(const AFieldName: string): TzControl;
  begin
    if not CtrlIndex.TryGetValue(AFieldName, result) then
      result := nil;
  end;

  function FindProps(const AFieldName: string): TzControlProps;
  begin
    if not PropsIndex.TryGetValue(AFieldName, result) then
      result := nil;
  end;

// Sincronizza Size e DisplayLabel di un campo dal suo TdxLayoutItem.
// Usata da ProcessRow e dalla passata globale (campi dentro gruppi, tab
// e gruppi utente che ProcessRow non visita); idempotente.
  procedure SyncLeafProps(ALeaf: TdxLayoutItem; cp: TzControlProps);
  var
    zCtrl: TzControl;
    LeafCaption: string;
    LeafField: string;
    NewSize: integer;
    NewColSpan: integer;
    GapPx: integer;
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

    // Colonne fisse: con ColSpan il Size non decide piu' la larghezza, quindi
    // un ridimensionamento fatto nell'editor andrebbe perso al rebuild. Se la
    // larghezza e' cambiata rispetto al build, ricava le colonne nuove dalla
    // geometria di quel build: un item di s colonne e' largo
    // s*colonna + (s-1)*gap, quindi (larghezza + gap) e' proporzionale a s.
    // L'arrotondamento assorbe gli scarti di pochi pixel dell'editor.
    zCtrl := FindCtrl(LeafField);
    if Assigned(zCtrl) and (zCtrl.ColSpan > 0) and (zCtrl.BuiltColSpan > 0) and (zCtrl.BuiltWidthPx > 0) and (Abs(ALeaf.Width - zCtrl.BuiltWidthPx) > 1) then
    begin
      GapPx := TzLayoutMetrics.ItemGap(dxLayoutControl);
      NewColSpan := Round(zCtrl.BuiltColSpan * (ALeaf.Width + GapPx) / (zCtrl.BuiltWidthPx + GapPx));
      NewColSpan := EnsureRange(NewColSpan, 1, Max(1, zDbCardProps.ColCount));
      if NewColSpan <> zCtrl.ColSpan then
        SiDbCard.LogMessage(Format('SyncLeafProps %s: ColSpan %d -> %d (Width=%d, BuiltWidth=%d)', [LeafField, zCtrl.ColSpan, NewColSpan, ALeaf.Width, zCtrl.BuiltWidthPx]));
      zCtrl.ColSpan := NewColSpan;
      cp.ColSpan := NewColSpan;
    end;

    // Caption: baseline = DisplayLabel del DOMINIO (vedi note in ProcessRow);
    // gli override cliente prevalgono a runtime e non vanno toccati.
    LeafCaption := ALeaf.Caption;
    zCtrl := FindCtrl(LeafField);

    // Specchia il Size anche sul RUNTIME: SaveProperties (SaveToProps)
    // ricostruisce i props iterando il runtime, quindi un valore scritto
    // solo nei props verrebbe riportato allo stato pre-editor dal primo
    // salvataggio successivo.
    if Assigned(zCtrl) then
      zCtrl.Size := NewSize;

    if not Overrides.OverrideExists(DataController.IdDataSet, LeafField, [ofCaptionCard]) then
    begin
      if Assigned(zCtrl) and SameText(LeafCaption, zCtrl.DomainDisplayLabel) then
        cp.DisplayLabel := ''
      else
        cp.DisplayLabel := LeafCaption;

      // Caption effettiva sul runtime: SaveToProps decide da item.DisplayLabel
      // se persistere l'etichetta o lasciare il default di dominio.
      if Assigned(zCtrl) then
        if not SameText(zCtrl.DisplayLabel, LeafCaption) then
          zCtrl.DisplayLabel := LeafCaption;
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
      z := FindCtrl(p.name);
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
      // Con la griglia attiva l'ingombro reale in riga e' lo slot
      // quantizzato (stesse regole di BuildLayoutItems.AddFieldItem)
      if zDbCardProps.SnapToGrid then
        result := RowModel.SnapSlot(result, RowModel.RowMaxSize, Max(1, zDbCardProps.ColCount));
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

  procedure ProcessRow(ARowGroup: TdxLayoutGroup; AIsFirstRow: boolean);
  var
    k: integer;
    isFirstInRow: boolean;
    cp: TzControlProps;
    zCtrl: TzControl;
    NewCaption: string;
  begin
    isFirstInRow := true;

    // P1: si iterano i FIGLI DIRETTI della riga invece di scandire tutti gli
    // AbsoluteItems filtrando per Parent (era O(righe x item)).
    for k := 0 to ARowGroup.Count - 1 do
    begin
      leaf := ARowGroup.items[k];

      // GroupBox generati dal controller (grp_<campo>_<card>): sincronizza
      // Size (dal Width), caption e posizione nell'ordine dei props. Prima
      // venivano saltati: finivano accodati in fondo all'ordine e i
      // rename/resize fatti nell'editor andavano persi al rebuild.
      if leaf is TzDxFieldLayoutGroup then
      begin
        fn := ExtractFieldNameFromLayoutItem(leaf.name);
        if not fn.IsEmpty then
        begin
          cp := FindProps(fn);
          if Assigned(cp) then
          begin
            // Width del gruppo = peso assegnato da Build (Size * CharWidth)
            cp.Size := Max(1, TdxLayoutGroup(leaf).Width div RowModel.CharWidth);

            // Bottone di collasso e stato espanso impostati nell'editor:
            // senza questa cattura andrebbero persi, perche' gli item
            // generati dal controller non sono serializzati nel Layout
            // (vedi zLayouts.LoadFromLayout).
            cp.GroupExpandButton := TdxLayoutGroup(leaf).ButtonOptions.ShowExpandButton;
            cp.GroupExpanded := TdxLayoutGroup(leaf).Expanded;

            NewCaption := TdxLayoutGroup(leaf).Caption;
            zCtrl := FindCtrl(fn);

            // Specchia sul runtime (vedi nota in SyncLeafProps): SaveToProps
            // ricostruisce i props dal runtime al prossimo salvataggio.
            if Assigned(zCtrl) then
            begin
              zCtrl.Size := cp.Size;
              zCtrl.GroupExpandButton := cp.GroupExpandButton;
              zCtrl.GroupExpanded := cp.GroupExpanded;
            end;

            if not Overrides.OverrideExists(DataController.IdDataSet, fn, [ofCaptionCard]) then
            begin
              if Assigned(zCtrl) and SameText(NewCaption, zCtrl.DomainDisplayLabel) then
                cp.DisplayLabel := ''
              else
                cp.DisplayLabel := NewCaption;

              if Assigned(zCtrl) then
                if not SameText(zCtrl.DisplayLabel, NewCaption) then
                  zCtrl.DisplayLabel := NewCaption;
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

            // Disposizione anche sul runtime (fonte di SaveToProps)
            if Assigned(zCtrl) then
              zCtrl.RowPlacement := cp.RowPlacement;

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

      cp := FindProps(fn);
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

      // Disposizione anche sul runtime (fonte di SaveToProps)
      zCtrl := FindCtrl(fn);
      if Assigned(zCtrl) then
        zCtrl.RowPlacement := cp.RowPlacement;

      NewOrder.Add(cp);
      isFirstInRow := false;
    end;
  end;

begin
  SiDbCard.EnterMethod(Self, 'SyncLayoutFromEditor');
  RowModel := NewRowModel;
  CtrlIndex := TDictionary<string, TzControl>.Create(TIStringComparer.Ordinal);
  PropsIndex := TDictionary<string, TzControlProps>.Create(TIStringComparer.Ordinal);
  try
    // P1: indici nome -> oggetto costruiti una sola volta
    for i := 0 to zControls.Count - 1 do
      CtrlIndex.AddOrSetValue(zControls[i].name, zControls[i]);
    for i := 0 to zDbCardProps.Controls.Count - 1 do
      PropsIndex.AddOrSetValue(zDbCardProps.Controls[i].name, zDbCardProps.Controls[i]);

    // 1. Salva struttura completa (gruppi, tab, emptyspace utente)
    zDbCardProps.Layout.LoadFromLayout(dxLayoutControl);

    // 2. Aggiorna ordine TzControlProps e ColSpan
    // NB: l'iniezione di ctLineBreak (GetOrCreateLineBreak/AvailableLB) e'
    // stata rimossa: le rotture di riga sono espresse da RowPlacement e i
    // ctLineBreak residui vengono scartati in coda (vedi sotto).
    NewOrder := TList<TzControlProps>.Create;
    try
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
          ProcessRow(TdxLayoutGroup(rowGroup), IsFirstRow);
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
        ctrlProps := FindProps(fn);
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

          // Membership anche sul runtime (fonte di SaveToProps)
          runtimeCtrl := FindCtrl(fn);
          if Assigned(runtimeCtrl) then
            runtimeCtrl.Group := ctrlProps.Group;
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

      // Riallinea anche l'ORDINE del runtime: SaveProperties (SaveToProps)
      // ricostruisce i props iterando il runtime con Clear+Add, quindi senza
      // questo passaggio il riordino fatto nell'editor verrebbe annullato
      // dal primo salvataggio successivo. Gli item runtime assenti da
      // NewOrder (es. campi solo runtime) scivolano in coda, come gia'
      // avviene per i campi nascosti.
      runtimeIdx := 0;
      for j := 0 to NewOrder.Count - 1 do
      begin
        runtimeCtrl := FindCtrl(NewOrder[j].name);
        if Assigned(runtimeCtrl) then
        begin
          if runtimeCtrl.Index <> runtimeIdx then
            runtimeCtrl.Index := runtimeIdx;
          Inc(runtimeIdx);
        end;
      end;

    finally
      FreeAndNil(NewOrder);
    end;

    // 3. Salva su DB (asincrono)
    SaveProperties;

    SiDbCard.LogColored(TColors.Green, 'SyncLayoutFromEditor: salvato');
  finally
    FreeAndNil(PropsIndex);
    FreeAndNil(CtrlIndex);
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
  Slots: TArray<integer>;
  capLen: integer;
begin
  Monitor := ActiveMonitor;
  MaxAvailWidth := Round(Monitor.Width * MAX_WIDTH_RATIO);

  // Modello con capacità = massimo disponibile a schermo: il clamp degli
  // EffectiveSlot scatta solo oltre ciò che comunque non ci starebbe.
  // La somma per riga e il calcolo finale sono in TzDialogWidthModel
  // (zDbCard.Layout), puri e testabili: qui resta solo la raccolta degli
  // slot dai controlli visibili.
  M := TzRowModel.Create(MaxAvailWidth, Font);
  try
    Slots := nil;
    for item in zControls do
    begin
      if not item.Visible then
        Continue;

      if item.zCtrlType in [ctLineBreak, ctSeparator] then
      begin
        Slots := Slots + [TzDialogWidthModel.ROW_BREAK];
        Continue;
      end;

      if not item.Group.IsEmpty then
        Continue; // vive dentro il suo GroupBox, che ha un proprio Size

      capLen := 0;
      if zDbCardProps.CaptionLayout = clLeft then
        capLen := Length(item.DisplayLabel);

      Slots := Slots + [M.EffectiveSlot(item.Size, item.Domain, capLen)];
    end;

    result := TzDialogWidthModel.SuggestedWidth(TzDialogWidthModel.MaxRowSum(Slots), M.CharWidth, MIN_WIDTH, MaxAvailWidth);
  finally
    M.Free;
  end;
end;

// Naming degli item generati: regole centralizzate in TzCardLayoutNames
// (zDbCard.Layout); qui restano i delegati per compatibilita' e comodita'.

function TzDbCard.NameForField(const FieldName: string): string;
begin
  result := TzCardLayoutNames.FieldItem(Name, FieldName);
end;

function TzDbCard.NameForRow(const RowIndex: integer): string;
begin
  result := TzCardLayoutNames.Row(Name, RowIndex);
end;

function TzDbCard.NameForFiller(const RowIndex, ColUsed: integer): string;
begin
  result := TzCardLayoutNames.Filler(Name, RowIndex, ColUsed);
end;

function TzDbCard.NameForSep(const RowIndex: integer): string;
begin
  result := TzCardLayoutNames.Separator(Name, RowIndex);
end;

function TzDbCard.NameForGroup(const FieldName: string): string;
begin
  result := TzCardLayoutNames.Group(Name, FieldName);
end;

function TzDbCard.NameForGroupRow(const GrpName: string; RowIndex: integer): string;
begin
  result := TzCardLayoutNames.GroupRow(Name, GrpName, RowIndex);
end;

function TzDbCard.NameForGroupFiller(const GrpName: string; RowIndex, ColUsed: integer): string;
begin
  result := TzCardLayoutNames.GroupFiller(Name, GrpName, RowIndex, ColUsed);
end;

function TzDbCard.ExtractGroupNameFromRowName(const RowName: string): string;
begin
  result := TzCardLayoutNames.ExtractGroupNameFromRowName(Name, RowName);
end;

function TzDbCard.ExtractFieldNameFromLayoutItem(const ItemName: string): string;
begin
  result := TzCardLayoutNames.ExtractFieldName(Name, ItemName);
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

procedure TzDbCard.OnGroupExpandedStateChanged(Sender: TObject);
var
  grp: TdxLayoutGroup;
  FieldName: string;
  ctrl: TzControl;
  cp: TzControlProps;
begin
  // Persiste lo stato espanso/collassato dei ctGroupBox al click utente.
  // I set programmatici di BuildLayoutItems avvengono PRIMA dell'hook degli
  // eventi (vedi CreateGroupForControl) e non passano di qui; durante la
  // customizzazione la cattura spetta a SyncLayoutFromEditor.
  if IsCreatingControls then
    Exit;
  if dxLayoutControl.Customization then
    Exit;
  if not(Sender is TdxLayoutGroup) then
    Exit;
  grp := TdxLayoutGroup(Sender);

  FieldName := ExtractFieldNameFromLayoutItem(grp.name);
  if FieldName.IsEmpty then
    Exit;

  ctrl := zControls.Find(FieldName);
  if not Assigned(ctrl) then
    Exit;
  if ctrl.GroupExpanded = grp.Expanded then
    Exit;

  ctrl.GroupExpanded := grp.Expanded;
  cp := zDbCardProps.Controls.Get(FieldName, false);
  if Assigned(cp) then
    cp.GroupExpanded := grp.Expanded;

  SaveProperties; // deferito e coalizzato, vedi DoDeferredSaveProperties
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

function TzDbCard.FindGeneratedItem(const FieldName: string): TdxCustomLayoutItem;
begin
  // M5: ricerca unica dell'item generato per un campo — prima il
  // TdxLayoutItem (li_*), poi il TdxLayoutGroup (grp_*) dei group box.
  result := dxLayoutControl.FindItem(NameForField(FieldName));
  if not Assigned(result) then
    result := dxLayoutControl.FindItem(NameForGroup(FieldName));
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

// =============================================================================
// TzControls.BuildLayoutItems
// Il motore vero e proprio vive in TzCardLayoutBuilder (zDbCard.Layout):
// qui si costruiscono i descrittori piatti dei campi (snapshot dei TzControl)
// e si invoca il builder con il TzRowModel condiviso.
// =============================================================================
procedure TzControls.BuildLayoutItems(zDbCardProps: TzDbCardProps);
var
  Builder: TzCardLayoutBuilder;
  Fields: TObjectList<TzLayoutFieldInfo>;
  FieldInfo: TzLayoutFieldInfo;
  item: TzControl;
  RowModel: TzRowModel;
  EstimatedGroups: integer;
  i: integer;
begin
  EstimatedGroups := 0;
  RowModel := Card.NewRowModel;
  try
    Fields := TObjectList<TzLayoutFieldInfo>.Create(true);
    try
      for item in Self do
      begin
        FieldInfo := TzLayoutFieldInfo.Create;
        FieldInfo.FieldName := item.name;
        FieldInfo.DisplayLabel := item.DisplayLabel;
        FieldInfo.CtrlType := item.zCtrlType;
        FieldInfo.Size := item.Size;
        FieldInfo.ColSpan := item.ColSpan;
        // Larghezza piena: tutte le colonne della griglia corrente
        if item.ColSpan = ColSpanPiena then
          FieldInfo.ColSpan := Max(1, zDbCardProps.ColCount);
        FieldInfo.Lines := item.Lines;
        FieldInfo.Group := item.Group;
        FieldInfo.RowPlacement := item.RowPlacement;
        FieldInfo.Visible := item.Visible;
        FieldInfo.GroupExpandButton := item.GroupExpandButton;
        FieldInfo.GroupExpanded := item.GroupExpanded;
        // Indice ricalcolato a ogni build dal nome: il catalogo si rigenera
        FieldInfo.ImageName := item.ImageName;
        if item.ImageName.IsEmpty then
          FieldInfo.ImageIndex := -1
        else
          FieldInfo.ImageIndex := dx.IndiceIcona(item.ImageName);
        FieldInfo.Images := dx.Immagini;
        FieldInfo.Domain := item.Domain;
        FieldInfo.EditControl := item.cxCustomEdit;
        FieldInfo.FallbackControl := item.Control;
        Fields.Add(FieldInfo);
      end;

      Builder := TzCardLayoutBuilder.Create;
      try
        Builder.OnCheckGroupBoxStateChanged := Card.OnCheckGroupBoxStateChanged;
        Builder.OnGroupExpandedStateChanged := Card.OnGroupExpandedStateChanged;
        Builder.Build(Card.dxLayoutControl, Card.name, Fields, zDbCardProps, RowModel);
        EstimatedGroups := Builder.EstimatedGroups;
        // Geometria per le guide della griglia
        Card.FGrigliaColonne := Builder.BuiltGridCols;
        Card.FGrigliaCapacitaPx := Builder.BuiltRowCapacityPx;
        Card.FGrigliaGapPx := Builder.BuiltItemGapPx;
      finally
        FreeAndNil(Builder);
      end;

      // Riporta sui controlli le colonne e la larghezza assegnate dal build:
      // i descrittori sono nello stesso ordine della collezione.
      for i := 0 to Fields.Count - 1 do
      begin
        Self[i].BuiltColSpan := Fields[i].BuiltColSpan;
        Self[i].BuiltWidthPx := Fields[i].BuiltWidthPx;
      end;

      Card.FLastBuildRowMax := RowModel.RowMaxSize; // riferimento per CheckReflow
      Card.FLastBuildMeasured := Card.FRowModelWasMeasured;
      // Capacita' dei gruppi stimata: programma l'assestamento sulle misure reali
      Card.NoteGroupCapacityEstimated(EstimatedGroups);
      // Build fuori dal reflow (caricamento, personalizzazione): l'altezza va
      // riadattata. Dentro CheckReflow ci pensa gia' Resized subito dopo.
      if Card.AutoFitHeight and not Card.FInReflow then
        Card.PostInternalMessage(cmd_Resize);
    finally
      FreeAndNil(Fields);
    end;

    // Sincronizza lo stato dei check-group col valore DB e riporta i tab
    // alla prima pagina (prima erano in coda al vecchio BuildLayoutItems).
    Card.UpdateCheckGroupBoxes;
    Card.ResetTabsToFirstPage;
  finally
    FreeAndNil(RowModel);
  end;
end;

procedure TzDbCard.CMShowingChanged(var Message: TMessage);
begin
  inherited;

  if IsDestroying then
    Exit;

  if Showing and HandleAllocated then
    if Assigned(FCommandQueue) then
      FCommandQueue.RepostDeferred;

  // AutoFitHeight nel gruppo a linguette: mostrata (passaggio dalla vista alla
  // card) si adatta subito, dal cmd_Resize; nascosta restituisce al
  // FormController l'altezza dei dettagli scelta dall'utente.
  if AutoFitHeight then
    if Showing then
    begin
      FAutoFitPassaggi := 0;
      PostInternalMessage(cmd_Resize);
    end
    else
    begin
      FermaAutoFitRitardato;
      if Assigned(FOnAutoFitHeight) then
        FOnAutoFitHeight(Self, 0, false);
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
  if not FSaver.DeferIfRunning then
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
  FSettleRebuilds := 0; // nuovo ciclo di controlli: le stime vanno riconvalidate
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

function TzDbCard.SanificaEditor(zControl: TzControl): boolean;
var
  Testo: string;
  Ripulito: string;
  Multiriga: boolean;
begin
  result := false;

  if not EditorSanificabile(zControl) then
    Exit;

  Testo := VarToStr(zControl.cxCustomEdit.EditValue);
  if (Testo = '') or TzSanificazione.SembraMarcatura(Testo) then
    Exit;

  Multiriga := zControl.zCtrlType = ctMemo;
  Ripulito := TzSanificazione.Sanifica(Testo, Multiriga, TzSanificazione.OpzioniPredefinite);

  if Ripulito = Testo then
    Exit;

  zControls.DataSet.CheckEditMode;
  zControl.cxCustomEdit.EditValue := Ripulito;
  zControl.cxCustomEdit.PostEditValue;
  result := true;
end;

function TzDbCard.EditorSanificabile(zControl: TzControl): boolean;
var
  Properties: TcxCustomEditProperties;
begin
  result := false;

  if not Assigned(zControl) or not Assigned(zControl.cxCustomEdit) then
    Exit;

  if not(zControl.zCtrlType in [ctEdit, ctMemo]) then
    Exit;

  if zControl.ReadOnly or zControl.IsLookup or zControl.IsPicklist then
    Exit;

  Properties := zControl.cxCustomEdit.ActiveProperties;
  if not(Properties is TcxCustomTextEditProperties) then
    Exit;

  if TcxCustomTextEditProperties(Properties).EchoMode = eemPassword then
    Exit;

  result := true;
end;

procedure TzDbCard.actSanificaExecute(Sender: TObject);
begin
  SanificaEditor(zControls.PopupCtrlItem);
end;

procedure TzDbCard.actSanificaUpdate(Sender: TObject);
var
  Azione: TCustomAction;
  zControl: TzControl;
  Testo: string;
  Anomalie: string;
  Multiriga: boolean;
begin
  Azione := Sender as TCustomAction;
  zControl := zControls.PopupCtrlItem;

  ActionVisible(Azione, EditorSanificabile(zControl));
  if not Azione.Visible then
    Exit;

  Testo := VarToStr(zControl.cxCustomEdit.EditValue);
  Multiriga := zControl.zCtrlType = ctMemo;

  if (Testo = '') or TzSanificazione.SembraMarcatura(Testo) then
    Anomalie := ''
  else
    Anomalie := TzSanificazione.DescriviAnomalie(Testo, Multiriga);

  // DescriviAnomalie non copre la sola compressione degli spazi e il trim:
  // ContieneAnomalie e' il criterio di abilitazione, la descrizione e' un aiuto
  Azione.Enabled := (Testo <> '') and (not TzSanificazione.SembraMarcatura(Testo)) and TzSanificazione.ContieneAnomalie(Testo, Multiriga, TzSanificazione.OpzioniPredefinite);

  if Anomalie <> '' then
    Azione.Caption := 'Sanifica testo (' + Anomalie + ')'
  else
    if Azione.Enabled then
      Azione.Caption := 'Sanifica testo (spazi ripetuti o ai bordi)'
    else
      Azione.Caption := 'Sanifica testo';
end;

initialization

SiDbCard := Si.AddSession('zDbCard', true);
SiDbCard.Color := clCream;

finalization

SiDbCard := nil;

end.

  zFbDataSet

  zdx
