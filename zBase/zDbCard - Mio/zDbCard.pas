unit zDbCard;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
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
  cxScrollBox,
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
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TzDbCardCommand = (cmd_UpdateActions, cmd_DisplayToolbars, cmd_NewLookupDisplayText, cmd_SaveLookupToZip, cmd_SavePickListToZip, cmd_LoadProperties, cmd_PropertiesChange, cmd_ReadOnlyPropertiesChange, cmd_FlagsPropertiesChange,
    cmd_CtrlTypePropertiesChange, cmd_UpdateColors, cmd_Resize, cmd_PersonalizzaCard, cmd_RebuildControls, cmd_RebuildSingleControl, cmd_VerifyLookupsParams);

  TzDbCardReadOnly = (crUseLoadedProps, crForceReadOnly, crForceWriteable);

  TzControls = class;
  TzDbCard = class;

  TzControl = class(TzCollectionItem)
  private
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

    procedure CalculateSize(const MaxWidth: integer);
    function BlobHeight: integer;
    procedure SetPosition(const Position: TPoint);
    procedure SetParent(Parent: TWinControl);

    procedure SetDisplayLabel(const Value: string);
    procedure SetFieldReadOnly(const Value: boolean);
    procedure SetFieldRequired(const Value: boolean);
    procedure SetReadOnly(const Value: boolean);
    procedure SetRequired(const Value: boolean);
    procedure SetVisible(const Value: boolean);
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
    function IsCreated: boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure AssignControlProps(zControlProps: TzControlProps; zDomain: TzDomain);
    procedure RebuildControls(zControlProps: TzControlProps; zDomain: TzDomain);

    function GetLookup(zSystem: TzSystem): TzLookup;
    procedure OpenLookupDataSet;
    function ControlIsLookup: boolean;
    function LookupControlField: TField;

    procedure ResetPos;
    procedure MakeVisible;
    function IsPicklist: boolean;
    function IsLookup: boolean;

    procedure EditCustomCaption;

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
    procedure AssignGroupParent;
    procedure CalculateSize(MaxWidth: integer);
    procedure DisplayControls(Parent: TWinControl; Group: string; MaxWidth: integer);
    procedure DisplayGroupsControls(Parent: TcxControl);
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
    property Card: TzDbCard read FCard write FCard;
    property ControlFont: TFont read FControlFont write SetControlFont;
    property PopupMenu: TdxBarPopupMenu read FPopupMenu write FPopupMenu;
    property DataController: TzDataController read FDataController write FDataController;
    property DataSet: TzFbDataSet read FDataSet write FDataSet;
    property DataSource: TDataSource read FDataSource write FDataSource;
    property zSystem: TzSystem read FzSystem write SetzSystem;
  end;

  TCardInfo = class
  private
    FHorizontalSpaceBetweenControls: integer;
    FVerticalSpaceBetweenControls: integer;
    FVerticalSpaceBetweenLabelAndControl: integer;
  private
    FFontWidth: integer;
    FLabelHeight: integer;
    FCustomEditHeight: integer;
    function GetFontWidth: integer;
    function GetLabelHeight: integer;
    function GetCustomEditHeight: integer;
  private
    zControls: TzControls;
  public
    constructor Create(azControls: TzControls);
    procedure Reset;

    function BlobHeight(const Lines: integer; const HasLabel: boolean): integer;
    function LabelWidth(const DisplayLabel: string): integer;
    function RowHeight: integer;
  public
    property FontWidth: integer read GetFontWidth;
    property HorizontalSpaceBetweenControls: integer read FHorizontalSpaceBetweenControls;
    property VerticalSpaceBetweenControls: integer read FVerticalSpaceBetweenControls;

    property LabelHeight: integer read GetLabelHeight;

    property VerticalSpaceBetweenLabelAndControl: integer read FVerticalSpaceBetweenLabelAndControl;

    property CustomEditHeight: integer read GetCustomEditHeight;
  end;

  TzDbCard = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent)
    cxScrollBox: TcxScrollBox;
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
    TitoloCampo: TAction;
    dxBarButton13: TdxBarButton;
    CopiaImpostazioniPerDX: TAction;
    dxBarButtonCopiaImpostazioniPerDX: TdxBarButton;
    actPersonalizzaPicklist: TAction;
    dxBarButtonactPersonalizzaPickList: TdxBarButton;
    pnlDescrizione: TdxPanel;
    Descrizione: TAction;
    dxBarButton14: TdxBarButton;
    EditTools: TAction;
    dxBarButton15: TdxBarButton;
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
    procedure dxBarSpinEditCtrlSizeChange(Sender: TObject);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
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
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
    procedure OpenPictureExecute(Sender: TObject);
    procedure popCardPopup(Sender: TObject);
    procedure popEditPopup(Sender: TObject);
    procedure PreviewPictureExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure SavePictureExecute(Sender: TObject);
    procedure SeparatoreExecute(Sender: TObject);
    procedure TitoloCampoExecute(Sender: TObject);
    procedure TitoloCampoUpdate(Sender: TObject);
    procedure VisibleIfAdmin(Sender: TObject);
    procedure WebCamExecute(Sender: TObject);
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
    FDataController: TzDataController;
    FzDataSet: TzFbDataSet;
    FzDbCardProps: TzDbCardProps;
    FzSystem: TzSystem;
  private // Metodi IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
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
    procedure DisplayControls;
    procedure ForceControlsValidation;
    procedure InitCard;
    procedure PersonalizzaCard;
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
  private
    CardInfo: TCardInfo;
  private
    procedure LoadProperties(const LoadFromBase: boolean = true);
    procedure SaveProperties;

    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
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
    function CalcSuggestedDialogWidth: integer;
    function CalcDialogHeight(doDisplayControls: boolean = false): integer;
    procedure UpdateHeight;
    function GetDialogTitle: string;
    function GetTitle: string;
    procedure SetTitle(const Title: string);
    procedure ForceDisplay;
    procedure RefreshDisplay;
    procedure RebuildControls;
    procedure ForceCopyMappingFields;
    procedure ActivateDataSet;
    procedure InitToolActions;
    procedure ExecuteToolConfig;
    procedure UpdateColors;
    function ValidateRequiredFields(RaiseError: boolean): boolean;
    function ActiveFieldName: string;
    function ActiveCustomEdit: TcxCustomEdit;
    procedure RealignToolbars;
  private
    FLookupsEnabled: boolean;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    procedure SetLookupsEnabled(Value: boolean);
  private
    procedure EnableLookups;
    procedure DisableLookups;
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
  cxDBData,
  zToolConfigDlg;

{$R *.dfm}

var
  SiDbCard: TSiSession;
  siRed: TSiSession;

type
  TcxCustomEditAccess = class(TcxCustomEdit);
  TdxCustomCheckGroupBoxAccess = class(TdxCustomCheckGroupBox);

  /// ///////////////////////////////////////////////////////////////

  { TCardInfo }

constructor TCardInfo.Create(azControls: TzControls);
begin
  inherited Create;
  zControls := azControls;
  Reset;
end;

function TCardInfo.BlobHeight(const Lines: integer; const HasLabel: boolean): integer;
var
  v: integer;
  NumLines: integer;
begin
  result := 0;

  NumLines := Lines;

  if NumLines <= 0 then
    NumLines := 3;

  result := CustomEditHeight * NumLines;

  v := LabelHeight + VerticalSpaceBetweenControls + VerticalSpaceBetweenLabelAndControl;

  result := result + (v * (NumLines - 1));

  if not HasLabel then
    result := result + LabelHeight + 1;
end;

procedure TCardInfo.Reset;
begin
  FVerticalSpaceBetweenLabelAndControl := 1;
  FVerticalSpaceBetweenControls := 5;
  FFontWidth := 0;
  FLabelHeight := 0;
  FCustomEditHeight := 0;
  FHorizontalSpaceBetweenControls := FontWidth; // assegna anche FFontWidth
end;

function TCardInfo.RowHeight: integer;
begin
  result := CustomEditHeight + LabelHeight + VerticalSpaceBetweenLabelAndControl;
end;

function TCardInfo.GetCustomEditHeight: integer;
var
  tmpCustomEdit: TcxCustomEdit;
begin
  if FCustomEditHeight <= 0 then
  begin
    tmpCustomEdit := zControls.CreateDbControl('__temp', ctEdit);
    try
      FCustomEditHeight := (tmpCustomEdit.Height);
    finally
      FreeAndNil(tmpCustomEdit);
    end;
  end;

  result := FCustomEditHeight;
end;

function TCardInfo.GetLabelHeight: integer;
var
  tmpLabel: TcxLabel;
begin
  if FLabelHeight <= 0 then
  begin
    tmpLabel := zControls.CreateLabel('__tempLabel', 'test', nil, true, true);
    try
      FLabelHeight := (tmpLabel.Height)
    finally
      FreeAndNil(tmpLabel);
    end;
  end;

  result := FLabelHeight;
end;

function TCardInfo.LabelWidth(const DisplayLabel: string): integer;
begin
  result := dx.FontTextWidth(zControls.ControlFont, DisplayLabel + ' ');
  // result := NormalizeWidth(result, FontWidth);
end;

function TCardInfo.GetFontWidth: integer;
begin
  if FFontWidth <= 0 then
    FFontWidth := dx.FontTextWidth(zControls.ControlFont);

  result := FFontWidth;
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
  FLookupEnabled := true;
  EditValueChanging := false;
  FzCtrlType := ctDefault;
  FControl := nil;
  FcxCustomEdit := nil;
  FcxLabel := nil;
  FLines := 1;
  FSize := -1;
  FDisplayLabel := '';
  FVisible := true;
  FGroup := '';

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

procedure TzControl.CalculateSize(const MaxWidth: integer);
var
  ControlWidth: integer;
  LabelWidth: integer;
  i: integer;

  function NormalizeWidth(const Width: integer): integer;
  begin
    // 19.04.2026: era: result := Min(Width, MaxWidth);

    result := MulDiv(Width, Controls.Card.CurrentPPI, 96);
    result := Min(result, MaxWidth);
  end;

  function NormalizeHeight(const Height: integer): integer;
  begin
    // 19.04.2026: era:     result := Height;
    result := MulDiv(Height, Controls.Card.CurrentPPI, 96);
  end;

begin
  FWidth := -1;
  FHeight := -1;
  FTotalHeight := -1;

  if zCtrlType.IsDataAware then
  begin

    if not Assigned(cxCustomEdit) then
      Exit;

    // altrimenti sbaglia il calcolo del textwidth
    if (cxCustomEdit.Canvas.Font.name <> cxCustomEdit.Style.Font.name) or (cxCustomEdit.Canvas.Font.Size <> cxCustomEdit.Style.Font.Size) or (cxCustomEdit.Canvas.Font.Style <> cxCustomEdit.Style.Font.Style) then
      cxCustomEdit.Canvas.Font.Assign(cxCustomEdit.Style.Font);

    LabelWidth := Controls.Card.CardInfo.LabelWidth(DisplayLabel);

    if (zCtrlType = ctCheckBox) and (not TcxCheckBox(cxCustomEdit).AutoSize) then
      FHeight := cxCustomEdit.Height // non c'è autosize
    else
    begin
      // FHeight := Controls.Card.CardInfo.CustomEditHeight; // @TextHeight;
      // FHeight := NormalizeHeight(FHeight);
      Height := cxCustomEdit.Height;
    end;

    ControlWidth := Max(1, Size) * Controls.Card.CardInfo.FontWidth; // @TextWidth;
    FWidth := Max(ControlWidth, LabelWidth);
    FWidth := NormalizeWidth(FWidth);

    cxCustomEdit.Width := Width;
    cxCustomEdit.Height := Height;

    // riprende quelli reali
    FWidth := cxCustomEdit.Width;
    FHeight := cxCustomEdit.Height;

    if Assigned(cxLabel) then
      cxLabel.Width := Width;

    if zCtrlType.IsMultiLine then
    begin
      FHeight := Controls.Card.CardInfo.BlobHeight(Lines, Assigned(cxLabel)); // @BlobHeight;
      FHeight := NormalizeHeight(FHeight);
      cxCustomEdit.Height := FHeight;
      FHeight := cxCustomEdit.Height; // riprende il reale
    end;

    /// //////////////////////////////////////////////////////////////////
    FTotalHeight := cxCustomEdit.Height + Controls.Card.CardInfo.VerticalSpaceBetweenLabelAndControl;

    if Assigned(cxLabel) then
      FTotalHeight := FTotalHeight + cxLabel.Height;

    /// ////////////////
    if false then
      if Assigned(cxLabel) then
        cxLabel.Caption := FTotalHeight.ToString + '-Ctrl-' + cxCustomEdit.Height.ToString + '-Label-' + cxLabel.Height.ToString;
  end
  else
  begin

    if Assigned(Control) then
    begin
      FWidth := Control.Width;
      FHeight := Control.Height;
      FTotalHeight := Control.Height;
    end;

    // funzione per calcolare l'altezza di default
    case zCtrlType of
      ctGroupBox:
        begin
          FWidth := Max(1, Size) * Controls.Card.CardInfo.FontWidth;
          FWidth := NormalizeWidth(FWidth);

          FHeight := Controls.Card.CardInfo.BlobHeight(Lines, false);
          FHeight := NormalizeHeight(FHeight);
          FTotalHeight := FHeight;

          Control.Width := FWidth;
          Control.Height := FHeight;
        end;
      ctButton:
        begin
          FWidth := Max(1, Size) * Controls.Card.CardInfo.FontWidth;
          FWidth := NormalizeWidth(FWidth);
          Control.Width := FWidth;

          FHeight := Control.Height; // quello del bottone
          FTotalHeight := Controls.Card.CardInfo.RowHeight; // il default
        end;
      ctSeparator:
        begin
          FWidth := MaxWidth;
          Control.Width := FWidth; // - Controls.Card.CardInfo.HorizontalSpaceBetweenControls; // toglie il margine destro

          FHeight := Control.Height; // quello del bottone
          FTotalHeight := Control.Height; // Controls.Card.CardInfo.RowHeight; // il default
        end;
      ctLineBreak:
        begin
          FWidth := 0;
          FHeight := 0;
          FTotalHeight := 0;
        end;
    end;
  end;
end;

function TzControl.BlobHeight: integer;
var
  tmpCustomEdit: TcxCustomEdit;
  tmpLabel: TcxLabel;
  LabelHeight: integer;
  v: integer;
  NumLines: integer;
begin
  result := Controls.Card.CardInfo.BlobHeight(Lines, Assigned(cxLabel));
  // Exit;
  //
  // NumLines := Lines;
  //
  // if NumLines <= 0 then
  // NumLines := 3;
  //
  // if zCtrlType.IsMultiLine then
  // begin
  // tmpCustomEdit := CreateDbControl('__tempBlob__', ctEdit);
  // try
  // result := (tmpCustomEdit.Height) * NumLines;
  // finally
  // FreeAndNil(tmpCustomEdit);
  // end;
  //
  // // spazio vertivale tra i controlli
  // if Assigned(cxLabel) then
  // v := cxLabel.Height + Controls.Card.CardInfo.VerticalSpaceBetweenControls + Controls.Card.CardInfo.VerticalSpaceBetweenLabelAndControl
  // else
  // begin
  // tmpLabel := CreateLabel(DisplayLabel, cxCustomEdit, true, true);
  // try
  // LabelHeight := (tmpLabel.Height)
  // finally
  // FreeAndNil(tmpLabel);
  // end;
  //
  // v := LabelHeight + Controls.Card.CardInfo.VerticalSpaceBetweenControls + Controls.Card.CardInfo.VerticalSpaceBetweenLabelAndControl;
  // end;
  //
  // result := result + (v * (NumLines - 1));
  // end;
  //
  // // se non ha label incrementare
  // if not Assigned(cxLabel) then
  // result := result + LabelHeight + 1;
end;

procedure TzControl.SetPosition(const Position: TPoint);
begin
  FTop := Position.Y;
  FLeft := Position.X;

  if zCtrlType.IsDataAware then
  begin

    if Assigned(cxLabel) then
    begin
      cxLabel.Left := Left;
      cxLabel.Top := Top;
    end;

    if Assigned(cxCustomEdit) then
    begin
      cxCustomEdit.Left := Left;

      if Assigned(cxLabel) then
        cxCustomEdit.Top := cxLabel.Top + cxLabel.Height + Controls.Card.CardInfo.VerticalSpaceBetweenLabelAndControl
      else
        cxCustomEdit.Top := Top;
    end;
  end
  else
  begin

    if Assigned(Control) then
    begin
      case zCtrlType of
        ctGroupBox:
          begin
            Control.Left := Left;
            Control.Top := Top;
          end;
        ctButton:
          begin
            Control.Left := Left;
            Control.Top := Top + TotalHeight - Height;
          end;
        ctSeparator:
          begin
            Control.Left := Left;
            Control.Top := Top;
          end;
        ctLineBreak:
          begin
            // niente da fare
          end;
      end;
    end;
  end;
end;

function TzControl.CreateControl(const name: String; ControlType: TzCtrlType): TWinControl;
begin
  result := nil;

  case ControlType of
    ctGroupBox:
      begin
        result := TcxGroupBox.Create(Controls.Card);
        result.Visible := false;
        result.name := 'group' + Name;
        result.Parent := Controls.Card.cxScrollBox;
        TcxGroupBox(result).Caption := DisplayLabel;
        TcxGroupBox(result).Style.StyleController := dx.GroupStyleController;
      end;
    ctButton:
      begin
        result := TcxButton.Create(Controls.Card);
        result.Visible := false;
        result.name := 'btn' + Name;
        result.Parent := Controls.Card.cxScrollBox;
      end;
    ctSeparator:
      begin
        result := CreateLabel(Name, DisplayLabel, nil, false, false);
        dx.InitSeparator(TcxLabel(result));
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

    if zCtrlType <> ctCheckGroupBox then
    begin
      Caption := base.CustomerPreferences.GetControlCaption(Controls.Card.CardID, Name, DisplayLabel);
      FcxLabel := CreateLabel(Name, Caption, cxCustomEdit, true, true);
      FcxLabel.OnDblClick := LabelDblClick;
    end
    else
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
      zExecuteMemoDialog(Sender as TcxDbMemo, '', GetCustomActions, base.ImageList16);
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
  SiDbCard.EnterMethod(Self, 'ForceValidation: ' + Name);

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

  SiDbCard.LeaveMethod(Self, 'ForceValidation: ' + Name);
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
begin
  if Assigned(cxLabel) then
    cxLabel.Visible := true;

  if Assigned(cxCustomEdit) then
    cxCustomEdit.Visible := true;

  if Assigned(Control) then
    Control.Visible := true;
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
    OpenLookupDataSet;
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

  function doOpenLookupDataSet: boolean;
  begin
    result := false;
    try
      if lkDataSet.SelectSQL.Count > 0 then
      begin

        if Assigned(Controls.DataSet) and Controls.DataSet.Active then
          OpenLookupDataSet;

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

  if not doOpenLookupDataSet then
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
begin
  FDisplayLabel := Value;

  Caption := base.CustomerPreferences.GetControlCaption(Controls.Card.CardID, Name, DisplayLabel);

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
end;

procedure TzControl.SetParent(Parent: TWinControl);
begin
  if Assigned(cxCustomEdit) then
    cxCustomEdit.Parent := Parent;

  if Assigned(cxLabel) then
    cxLabel.Parent := Parent;
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
begin
  if FVisible <> Value then
  begin
    FVisible := Value;

    if Assigned(cxLabel) then
      cxLabel.Visible := Value;

    if Assigned(cxCustomEdit) then
      cxCustomEdit.Visible := Value;
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

procedure TzControls.CalculateSize(MaxWidth: integer);

var
  item: TzControl;
begin
  for item in Self do
    item.CalculateSize(MaxWidth);
end;

function TzControls.CreateDbControl(const DataField: String; ControlType: TzCtrlType): TcxCustomEdit;
begin
  result := dx.GetCustomEditClass(ControlType).Create(Card);
  result.Visible := false;
  result.name := 'ed' + DataField;
  result.Parent := Card.cxScrollBox;

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

  AssignGroupParent;

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
        if item.cxCustomEdit.Parent <> Card.cxScrollBox then
          item.cxCustomEdit.Parent := Card.cxScrollBox;

      if item.cxLabel <> nil then
        if item.cxLabel.Parent <> Card.cxScrollBox then
          item.cxLabel.Parent := Card.cxScrollBox;

      if item.Control <> nil then
        if item.Control.Parent <> Card.cxScrollBox then
          item.Control.Parent := Card.cxScrollBox;
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
  Self.Clear;

  if not DataController.DataSetOk then
    Exit;

  if not zSystemOk then
    Exit;

  zDbCardProps.Controls.ValidateDataset(DataController.zFbDataSet, false);

  { TODO : Ricondure a zControl.AssignProps }

  for ctrlProps in zDbCardProps.Controls do
  begin

    if not DataController.TryGetField(ctrlProps.name, Field) then
      if ctrlProps.zCtrlType.IsDataAware then
        Continue; // campo non trovato

    item := Add;
    item.name := ctrlProps.name;
    item.DisplayLabel := ctrlProps.DisplayLabel;
    item.Lines := ctrlProps.Lines;
    item.ReadOnly := ctrlProps.ReadOnly;
    item.Required := ctrlProps.Required;
    item.Size := ctrlProps.Size;
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

      if item.DisplayLabel = '' then
        item.DisplayLabel := item.Domain.DisplayLabel;

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
begin

  zDbCardProps.Controls.Clear;
  for item in Self do
  begin
    ctrlProps := zDbCardProps.Controls.Add;

    ctrlProps.name := item.name;
    ctrlProps.DisplayLabel := item.DisplayLabel;
    ctrlProps.Group := item.Group;
    ctrlProps.Lines := item.Lines;
    ctrlProps.ReadOnly := item.ReadOnly;
    ctrlProps.Required := item.Required;
    ctrlProps.Size := item.Size;
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
    inc(i);
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
  FrameDescription := nil;
  FLookupsEnabled := true;
  Inserting := false;
  isResizing := false;
  FIsDestroying := false;
  disableResize := false;

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

  // si dpi <>96 va in palla
  cxScrollBox.Font := dx.NormalStyleController.Style.Font;

  FzDbCardProps := TzDbCardProps.Create(nil);
  FDataController := TzDataController.Create(Self);
  FzControls := TzControls.Create;
  zControls.Sorted := false;
  zControls.Card := Self;
  zControls.ControlFont := cxScrollBox.Font;
  zControls.DataController := DataController;
  zControls.DataSource := DataSource;
  zControls.PopupMenu := popEdit;
  CardInfo := TCardInfo.Create(zControls);
  // dopo zControls

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
end;

destructor TzDbCard.Destroy;
begin
  SiDbCard.EnterMethod(Self, 'Destroy');
  FIsDestroying := true;
  FreeAndNil(FrameDescription);
  FreeAndNil(FToolActions);
  FreeAndNil(FzDbCardProps);
  FreeAndNil(CardInfo);
  FreeAndNil(FzControls);
  FreeAndNil(FDataController);

  inherited;

  SiDbCard.LeaveMethod(Self, 'Destroy');
end;

procedure TzDbCard.DestroyCustomControls;
var
  i: integer;
  lbl: TcxLabel;
begin
  SiDbCard.EnterMethod(Self, 'DestroyCustomControls');

  if Visible and cxScrollBox.CanFocusEx then
    cxScrollBox.SetFocus;

  zControls.DestroyControls;

  SiDbCard.LeaveMethod(Self, 'DestroyCustomControls');
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
    LoadProperties(true); // chiama gia' InitToolActions internamente
    Localizer.Translate(Self);
  end;
end;

procedure TzDbCard.DisplayControls;
const
  VScrollbarWidth = 20;
begin
  SiDbCard.EnterMethod(Self, 'DisplayControls');
  cxScrollBox.VertScrollBar.Position := 0;
  cxScrollBox.VertScrollBar.Visible := ClientHeight > 100;

  SetCardDlgWidth;

  SiDbCard.LogColored(TColors.Red, 'DisplayControls');
  SiDbCard.LogInteger('cxScrollBox', cxScrollBox.ClientWidth);
  SiDbCard.LogBoolean('VertScrollBar', cxScrollBox.VertScrollBar.Visible);

  cxScrollBox.DisableAlign;
  try
    zControls.DisplayControls(cxScrollBox, '', cxScrollBox.ClientWidth - VScrollbarWidth);
    zControls.DisplayGroupsControls(cxScrollBox);
    zControls.MakeControlsVisible;

    ForceControlsValidation; // ZZ 12 maggio 2022
  finally
    cxScrollBox.EnableAlign;
  end;

  SiDbCard.LeaveMethod(Self, 'DisplayControls');
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
    // if DataController.IsActive then // se chiuso per sql errato d� errore
    DestroyCustomControls;

    DataController.OpenDataSet;
    // zDataSet := zDataSet; // riassegnazione delle prop
    InitCard;
  end;
end;

procedure TzDbCard.RebuildControls;
begin
  SiDbCard.EnterMethod(Self, 'RebuildControls');

  DestroyCustomControls;
  CreateCustomControls;
  DisplayControls;

  SiDbCard.LeaveMethod(Self, 'RebuildControls');
end;

procedure TzDbCard.RefreshDisplay;
begin
  SiDbCard.EnterMethod(Self, 'RefreshDisplay');

  DisplayControls;

  SiDbCard.LeaveMethod(Self, 'RefreshDisplay');
end;

procedure TzDbCard.CaricaImpostazioniExecute(Sender: TObject);
begin
  if not ConfirmOkCancel('Ripristino le impostazioni di default?') then
    Exit;

  zSystem.LoadZip;
  LoadProperties;
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
  simain.EnterMethod(Self, 'DisplayToolbars');

  dxBarManager.BeginUpdate;
  try
    // ordine inverso di visualizzazione
    dxBarToolbarFree.Visible :=  (ToolActions.Count > 0) or TzToolFilterHelper.HasFilterItems(dxBarManager);
    dxBarToolbar.Visible := zDbCardProps.Flags.Toolbar;
    dxBarToolbar.UseRestSpace := dxBarToolbarFree.Visible;

    if not zDbCardProps.Flags.Toolbar then
      Titolo.Visible := false;
  finally
    dxBarManager.EndUpdate;
  end;

  simain.LeaveMethod(Self, 'DisplayToolbars');
end;

procedure TzDbCard.dxBarEditCtrlCaptionChange(Sender: TObject);

var
  item: TzControl;
begin
  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  item.DisplayLabel := dxBarEditCtrlCaption.EditValue;
  SaveProperties;
  DisplayControls;
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

procedure TzDbCard.dxBarSpinEditCtrlSizeChange(Sender: TObject);

var
  item: TzControl;
  Size: integer;
begin

  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  Size := dxBarSpinEditCtrlSize.EditValue;
  item.Size := Size;

  SaveProperties;
  DisplayControls;
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
  id := CardID;
  name := zDbCardProps.name;
  // preserva caption/title
  oldTitle := zDbCardProps.Title;
  OldCaption := zDbCardProps.Caption;

  zDbCardProps.AsDFM := Clipboard.AsText;
  zDbCardProps.name := name;
  zDbCardProps.DataSet := GetID_DataSet;
  zDbCardProps.Title := oldTitle;
  zDbCardProps.Caption := OldCaption;

  DestroyCustomControls;
  LoadProperties(false);
  DisplayToolbars;
  // applica la larghezza/altezza incollate
  SaveCardFormSize; // verificare per l'altezza
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
    ToolActions.CreateButtons(GetToolbar, popCard, otCard);
  finally
    disableResize := false;
  end;
end;

function TzDbCard.GetToolFilters: TzToolFiltersProps; // IzBaseFilterableComponent.GetToolFilters
begin
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
  // un container. Pulizia prima della ricostruzione.
  TzToolFilterHelper.ClearFilterItems(Bar.BarManager);

  // Unica sorgente: i filtri persistiti (zDbCardProps.ToolFilters).
  for FilterProps in zDbCardProps.ToolFilters do
    TzToolFilterRegistry.ApplyFilter(FilterProps, Self, DataController.zFbDataSet);

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
  InternalSaveProperties;
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
  SaveProperties;
  DisplayControls;
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
  Size: integer;
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
  Size := item.Size;
  Lines := item.Lines;

  IsDataAware := item.zCtrlType.IsDataAware;
  IsMultiLine := item.zCtrlType.IsMultiLine;
  /// ////////////////////////////////////////////////////////////////////

  dx.SetValue(dxBarEditCtrlCaption, DisplayLabel);
  dx.SetValue(dxBarSpinEditCtrlSize, Size);
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
  idx: integer;
  item: TzControl;
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

  item := zControls.Add;
  item.zCtrlType := ctLineBreak;
  item.name := zControls.UniqueName('LineBreak');
  item.Visible := true;
  item.Group := Group;
  item.Index := idx;

  SaveProperties;
  DisplayControls;
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
  DisplayControls;
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
  simain.EnterMethod(Self, 'UpdateActions');

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

  simain.LeaveMethod(Self, 'UpdateActions');
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
            DisplayControls; // Messaggio
          finally
            isResizing := false;
          end;
        end;

  SiDbCard.LeaveMethod(Self, 'Resized');
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
  SiDbCard.EnterMethod(Self, 'ForceControlsValidation');

  if not IsDestroying then
    if DataController.DataSetOk then
      if DataController.IsEditing then
      begin
        LockWindowUpdate(Handle); // per memo &co
        try

          for item in zControls do
            item.ForceValidation;
        finally
          LockWindowUpdate(0);
        end;
      end;

  SiDbCard.LeaveMethod(Self, 'ForceControlsValidation');
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

procedure TzDbCard.FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
begin
  cxScrollBox.VertScrollBar.Position := cxScrollBox.VertScrollBar.Position - WheelDelta;
  Handled := true;
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
        inc(ErrorCount);
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
  simain.EnterMethod(Self, 'UpdateColors');

  if DataController.IsActive then
    for item in zControls do
      if DataController.TryGetField(item.name, Field) then
      begin
        item.FieldReadOnly := Field.ReadOnly;
        item.FieldRequired := Field.Required;
        item.UpdateColor;
      end;

  simain.LeaveMethod(Self, 'UpdateColors');
end;

procedure TzControl.EditCustomCaption;
  function GetCustomCaption: string;
  var
    Caption: string;
  begin
    result := DisplayLabel;

    if Assigned(cxLabel) then
      result := cxLabel.Caption;

    case zCtrlType of

      ctCheckGroupBox:
        begin
          if Assigned(cxCustomEdit) then
            if cxCustomEdit is TdxDBCheckGroupBox then
              result := TdxDBCheckGroupBox(cxCustomEdit).Caption;
        end;

      ctGroupBox:
        begin
          if Assigned(Control) then
            if Control is TcxGroupBox then
              result := TcxGroupBox(Control).Caption;
        end;
    end;
  end;

var
  Caption: string;
begin
  Caption := GetCustomCaption;

  if base.CustomerPreferences.EditControlCaption(Controls.Card.CardID, Name, Caption) then
    DisplayLabel := Caption;
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
  OpenLookupDataSet;

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

    if wasActive then
      OpenLookupDataSet;
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
      simain.LogString('ParamsChanged', Name);
      SiDbCard.LogString('VerifyLookupParams', 'ParamsChanged is TRUE for ' + Name);
      OpenLookupDataSet;
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

  DisplayControls;
end;

procedure TzDbCard.FlagsPropertiesChange;

var
  s: string;
begin
  simain.EnterMethod(Self, 'FlagsPropertiesChange');

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

  simain.LeaveMethod(Self, 'FlagsPropertiesChange');
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

procedure TzDbCard.UpdateHeight;
var
  h: integer;
begin
  h := CalcDialogHeight;

  if Self.ClientHeight <> h then
    Self.ClientHeight := h
end;

procedure TzDbCard.PropertiesChange;
var
  s: string;
  SolaLettura: boolean;
begin
  simain.EnterMethod(Self, 'PropertiesChange');

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

  simain.LeaveMethod(Self, 'PropertiesChange');
end;

procedure TzDbCard.CtrlTypePropertiesChange;
var
  i: integer;
  item: TzControl;
  zCtrlType: TzCtrlType;
  s: string;
begin
  simain.EnterMethod(Self, 'CtrlTypePropertiesChange');

  item := zControls.PopupCtrlItem;

  if not Assigned(item) then
    Exit;

  s := cxBarItemCtrlType.CurEditValue;
  zCtrlType := TEnum<TzCtrlType>.StringToEnum(s);

  item.zCtrlType := zCtrlType;
  item.DestroyControls;
  item.CreateControls;
  SaveProperties;

  DisplayControls;

  simain.LeaveMethod(Self, 'CtrlTypePropertiesChange');
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
    // cmd_NewLookupDisplayText escluso: lparam è un puntatore a un edit.
    if cmd <> cmd_NewLookupDisplayText then
    begin
      DeferredCommands[cmd] := true;
      DeferredParams[cmd] := lparam;
    end;
    Exit;
  end;

  PostedCommands[cmd] := true;
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
  try
    Case cmd of
      cmd_UpdateActions:
        UpdateActions;

      cmd_DisplayToolbars:
        DisplayToolbars;

      cmd_NewLookupDisplayText:
        begin
          cxCustomEdit := TcxCustomEdit(Message.lparam);

          if Assigned(cxCustomEdit) then
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
    end;
  finally
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

procedure TzControls.DisplayGroupsControls(Parent: TcxControl);
var
  Group: string;
  groupCtrl: TWinControl;
  groupItem: TzControl;
  item: TzControl;
begin

  for Group in Groups do
  begin
    groupCtrl := nil;
    groupItem := Find(Group);

    if Assigned(groupItem) then
    begin
      if groupItem.zCtrlType.IsDataAware then
        groupCtrl := groupItem.cxCustomEdit
      else
        groupCtrl := groupItem.Control;
    end;

    if Assigned(groupCtrl) then
      DisplayControls(groupCtrl, Group, groupCtrl.ClientWidth);
  end;
end;

procedure TzControls.AssignGroupParent;
var
  Group: string;
  groupCtrl: TWinControl;
  groupItem: TzControl;
  item: TzControl;
begin

  for Group in Groups do
  begin
    groupCtrl := nil;
    groupItem := Find(Group);

    if Assigned(groupItem) then
    begin
      if groupItem.zCtrlType.IsDataAware then
        groupCtrl := groupItem.cxCustomEdit
      else
        groupCtrl := groupItem.Control;
    end;

    if Assigned(groupCtrl) then
    begin
      for item in Self do
        if SameText(item.Group, Group) then
          item.SetParent(groupCtrl);

      // inizializza lo stato del TdxDBCheckGroupBox, essendo stati aggiunti in un secondo tempo i controlli
      if groupCtrl is TdxDBCheckGroupBox then
        TdxCustomCheckGroupBoxAccess(groupCtrl).EnableChildControls(groupCtrl, false);
    end;
  end;
end;

function TzControls.CreateLabel(const name: string; Caption: String; FocusControl: TWinControl; const Transparent: boolean; const AutoSize: boolean): TcxLabel;
begin
  result := TcxLabel.Create(Card);
  result.Visible := false;
  result.name := Card.UniqueComponentName('lbl_' + name);
  result.AutoSize := false;
  // prima del parent, altrimenti se su pagecontrol=> AV
  result.Parent := Card.cxScrollBox;
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
    inc(i);
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

  SaveProperties;

  DisplayControls;
end;

procedure TzControls.DisplayControls(Parent: TWinControl; Group: string; MaxWidth: integer);
var
  item: TzControl;
  blobs: TStack<TRect>;
  CurrentBlob: TRect;
  CurrentPos: TPoint;
  MaxRowHeight: integer;
  p: TPoint;

  function GetPosition(item: TzControl): TPoint;
    function OverflowX: boolean;
    begin
      result := (CurrentPos.X + item.Width) > MaxWidth;
    end;

    function OverflowY: boolean;
    begin
      result := CurrentPos.Y + MaxRowHeight + Card.CardInfo.VerticalSpaceBetweenControls >= CurrentBlob.Bottom;
    end;

  var
    ShouldBreak: boolean;
    ResetMaxRowHeight: boolean;
  begin

    if item.zCtrlType.IsLineBreak then
      CurrentPos.X := MaxWidth + 1; // forza oltre fine riga

    // verifica se saltare la riga
    while OverflowX or Application.Terminated do
    begin

      while OverflowY or Application.Terminated do
      begin
        if blobs.Count > 0 then
          CurrentBlob := blobs.Pop
        else
        begin
          CurrentBlob := TRect.Empty;
          Break;
        end;
      end;

      // ha raggiunto il margine dx, calcolare il salto
      CurrentPos.X := CurrentBlob.Left;

      // altrimenti bloccherebbe il while
      ShouldBreak := item.Width >= MaxWidth;
      ResetMaxRowHeight := true;

      if (item.zCtrlType.IsLineBreak) and (MaxRowHeight = 0) and (not CurrentBlob.IsEmpty) then // line break sulla prima riga dopo un blob
      begin
        CurrentPos.X := MaxWidth + 1; // deve forzare il calcolo corretto della X
        CurrentPos.Y := CurrentBlob.Bottom + Card.CardInfo.VerticalSpaceBetweenControls;
      end
      else
      begin
        if MaxRowHeight <> 0 then
        begin
          CurrentPos.Y := CurrentPos.Y + MaxRowHeight + Card.CardInfo.VerticalSpaceBetweenControls;
          ResetMaxRowHeight := not OverflowX;
          // altrimenti al ciclo successivo incrementa del valore di CurrentBlob.Height
        end
        else
        begin
          // Esempio: un campo Note dopo un GroupBox
          CurrentPos.Y := CurrentPos.Y + CurrentBlob.Height + Card.CardInfo.VerticalSpaceBetweenControls;
          ShouldBreak := false; // deve ricalcolare la X
        end;
      end;

      if ResetMaxRowHeight then
        MaxRowHeight := 0; // dopo il salto va resettata

      //
      if ShouldBreak then
        Break;
    end; // Overflow X

    // finito l'overflow deve spostare a dx
    if not item.zCtrlType.IsLineBreak then // altrimenti sposta a dx la riga seguente
      CurrentPos.X := CurrentPos.X + Card.CardInfo.HorizontalSpaceBetweenControls;

    result := CurrentPos;

    // Salva/incrementa i puntatori per il prossimo item
    CurrentPos.X := CurrentPos.X + item.Width;

    if not item.zCtrlType.IsMultiLine then
      MaxRowHeight := Max(MaxRowHeight, item.TotalHeight);

    // push del blobInfo
    if item.zCtrlType.IsMultiLine then
    begin

      if not CurrentBlob.IsEmpty then
        blobs.Push(TRect.Create(CurrentBlob));

      CurrentBlob := TRect.Create(CurrentPos, item.Width, item.TotalHeight);
    end;
  end;

begin
  assert(Assigned(Parent));

  if MaxWidth < 0 then // se hanno collassato la card tramite splitter
    Exit;

  blobs := TStack<TRect>.Create;
  try
    CurrentBlob := TRect.Empty;

    Parent.DisableAlign;
    try
      AssignGroupParent;

      for item in Self do
        item.ResetPos;

      CurrentPos.X := 0;
      CurrentPos.Y := Card.CardInfo.VerticalSpaceBetweenControls;

      if Parent is TcxCustomGroupBox then
        // CurrentPos.Y := CurrentPos.Y + 20; // Parametrizzare?
        CurrentPos.Y := CurrentPos.Y + MulDiv(20, Card.CurrentPPI, 96);

      MaxRowHeight := 0;

      for item in Self do
        if item.Visible then
          if item.IsCreated then
            if SameText(Group, item.Group) then
            begin
              item.CalculateSize(MaxWidth);

              p := GetPosition(item);

              item.SetPosition(p);

              // if item.cxLabel <> nil then
              // item.cxLabel.Caption := p.Y.ToString + ':' + p.X.ToString + ' - ' + item.DisplayLabel;
            end;
    finally
      Parent.EnableAlign;
    end;
  finally
    FreeAndNil(blobs);
  end;
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
  simain.EnterMethod(Self, 'ReadOnlyPropertiesChange');

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

  simain.LeaveMethod(Self, 'ReadOnlyPropertiesChange');
end;

procedure TzDbCard.ReopenLookupDataSet(const FieldName: string; const doCopyMappingFields: boolean);
var
  item: TzControl;
begin
  item := zControls.Find(FieldName);

  if Assigned(item) then
    if Assigned(item.lkDataSet) then
    begin
      item.OpenLookupDataSet;
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
  row: integer;
begin
  w1 := dx.dxBarRequiredWidth(dxBarToolbar);
  w2 := dx.dxBarRequiredWidth(dxBarToolbarFree);

  if w1 + w2 > Self.ClientWidth then
    row := 1
  else
    row := 0;

  if dxBarToolbarFree.row <> row then
    dxBarToolbarFree.row := row;
end;

procedure TzControl.AddCustomAction(Action: TBasicAction);
begin
  if Assigned(Action) then
    if not FCustomActions.ContainsKey(Action.name) then
      FCustomActions.Add(Action.name, Action);
end;

function TzControl.GetCustomActions: TArray<TBasicAction>;
begin
  result := FCustomActions.Values.ToArray;
end;

function TzControl.HasCustomActions: boolean;
begin
  result := FCustomActions.Count > 0;
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

function TzControl.IsCreated: boolean;
begin
  result := Assigned(FcxCustomEdit) or Assigned(FControl) or (zCtrlType = ctLineBreak);
end;

procedure TzControl.SetCustomAction(const name: string; const Value: TBasicAction);
begin
  if Value = nil then
    FCustomActions.Remove(Name)
  else
    FCustomActions.AddOrSetValue(Name, Value);
end;

procedure TzControl.LabelDblClick(Sender: TObject);
begin
  if CtrlKey then
    Self.Controls.Card.LabelDblClick;
end;

procedure TzControl.OpenLookupDataSet;
begin

  if lkDataSet.SQL_Select.Text.trim.IsEmpty then
  begin
    SiDbCard.LogColored(clRed, 'SQL lookup non specificato: ' + Name);
    raise Exception.Create('SQL lookup non specificato: ' + Name);
  end
  else
    lkDataSet.ReOpen();
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
        DisplayControls; // altrimenti UpdateHeight non avrà la larghezza corretta
      finally
        disableResize := false;
      end;
    end;

    zFormCard.UpdateHeight;
  end;

  SiDbCard.LeaveMethod(Self, 'SaveCardFormSize');
end;

function TzDbCard.GetDialogWidth: integer;
begin
  result := zDbCardProps.DlgWidth;

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

function TzDbCard.CalcDialogHeight(doDisplayControls: boolean = false): integer;
var
  i: integer;
  item: TzControl;
begin
  SiDbCard.EnterMethod(Self, 'CalcDialogHeight');
  SiDbCard.LogBoolean('doDisplayControls', doDisplayControls);

  result := -1;

  if zControls.Count = 0 then
    Exit;

  if doDisplayControls then
    DisplayControls;

  for item in zControls do
    if Assigned(item.cxCustomEdit) then
      if item.Visible then
        result := Max(result, item.cxCustomEdit.Top + item.cxCustomEdit.Height);

  if Assigned(dxBarToolbar.Control) then
    result := result + dxBarToolbar.Control.Height
  else
    result := result + Titolo.Height + 5;

  if dxBarToolbarFree.Visible then
    if dxBarToolbarFree.row >= 1 then
      if Assigned(dxBarToolbarFree.Control) then
        result := result + dxBarToolbarFree.Control.Height;

  inc(result, 15);

  SiDbCard.LeaveMethod(Self, 'CalcDialogHeight');
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

  function ScaleToSmallFont(const X: integer): integer;
  const
    SmallFontsPixelsPerInch = 96;
  var
    PixelsPerInch: integer;
  begin
    result := MulDiv(X, 96, Self.CurrentPPI);
    Exit; { TODO : Eliminare il resto del codice }

    PixelsPerInch := Self.CurrentPPI;
    // 26.01.2024
    // result := MulDiv(X, SmallFontsPixelsPerInch, PixelsPerInch);
    // 14.03.2024
    result := trunc((X / PixelsPerInch) * SmallFontsPixelsPerInch);
  end;

begin
  if csDesigning in ComponentState then
    Exit;

  if zDbCardProps.DataSet = '' then
    zDbCardProps.DataSet := GetID_DataSet;

  zControls.SaveToProps(zDbCardProps);
  LoadCardFormSize;

  // zz 14.03.2022
  zDbCardProps.DlgWidth := ScaleToSmallFont(zDbCardProps.DlgWidth);
  zDbCardProps.DlgHeight := ScaleToSmallFont(zDbCardProps.DlgHeight);

  TThread.CreateAnonymousThread(
    procedure
    begin
      InternalSaveProperties;
    end).Start;
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

  DisplayControls;

  // Rigeneriamo la toolbar runtime (filtri poi azioni) dalle props appena ricaricate
  // da LoadFromBase. DisplayToolbars legge ToolActions.Count per la visibilita' di
  // dxBarToolbarFree, quindi DEVE girare dopo.
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

procedure TzDbCard.TitoloCampoExecute(Sender: TObject);
var
  item: TzControl;
begin
  item := zControls.PopupCtrlItem;

  if Assigned(item) then
    item.EditCustomCaption;
end;

procedure TzDbCard.TitoloCampoUpdate(Sender: TObject);
begin
  TitoloCampo.Visible := base.CustomerPreferences.CanEditCaptions;
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
  simain.EnterMethod(Self, 'RebuildSingleControl');

  if not FieldRebuildData.Valid then
    Exit;

  ctrlProps := zDbCardProps.Controls.Get(FieldRebuildData.zControl.name);

  FieldRebuildData.zControl.RebuildControls(ctrlProps, FieldRebuildData.Domain);

  DisplayControls;

  simain.LeaveMethod(Self, 'RebuildSingleControl');
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
    CardInfo.Reset; // invalida le misure cachate
    // non serve RebuildControls qui: verrà chiamato da Resize
    // ma se la card è già visualizzata:
    if zControls.Count > 0 then
      PostInternalMessage(cmd_Resize);
  end;
end;

function TzDbCard.CalcSuggestedDialogWidth: integer;
const
  MIN_WIDTH = 300;
  MAX_WIDTH_RATIO = 0.7; // max 70% del monitor
  H_MARGIN = 20; // margine sx+dx scrollbox
  VSCROLLBAR_WIDTH = 20;

  // peso per tipo di controllo: moltiplicatore sulla Size base
  WEIGHT_SEPARATOR = 0.0; // un separatore occupa tutta la riga => forza newline
  WEIGHT_LINEBREAK = 0.0; // idem

var
  Monitor: TMonitor;
  MaxAvailWidth: integer;
  FontWidth: integer;

  // --- calcola la larghezza "logica" di un singolo controllo ---
  function ControlLogicalWidth(item: TzControl): integer;
  var
    LblW, CtrlW: integer;
  begin
    if not item.Visible then
    begin
      result := 0;
      Exit;
    end;

    case item.zCtrlType of
      ctLineBreak:
        result := 0;
      ctSeparator:
        result := MaxAvailWidth; // forza cambio riga
      ctGroupBox:
        begin
          result := Max(1, item.Size) * FontWidth;
          result := Min(result, MaxAvailWidth);
        end;
      ctButton:
        begin
          result := Max(1, item.Size) * FontWidth;
          result := Min(result, MaxAvailWidth);
        end;
    else
      // controlli data-aware
      if item.zCtrlType.IsDataAware then
      begin
        if item.zCtrlType.IsMultiLine then
        begin
          result := 0;
          Exit;
        end;

        LblW := CardInfo.LabelWidth(item.DisplayLabel);
        CtrlW := Max(1, item.Size) * FontWidth;
        result := Max(LblW, CtrlW);
      end
      else
        result := Max(1, item.Size) * FontWidth;
    end;
  end;

// --- simula il layout su una data larghezza, restituisce altezza totale ---
// (non usata per la larghezza, ma utile come validazione futura)

// --- calcola la larghezza ideale della riga più lunga SENZA andare
// a capo forzato, tenendo conto di linebreak/separator               ---
  function CalcNaturalRowWidths: TArray<integer>;
  var
    item: TzControl;
    CurrentRowWidth: integer;
    RowWidths: TList<integer>;
    HSpace: integer;
    w: integer;
  begin
    HSpace := CardInfo.HorizontalSpaceBetweenControls;
    RowWidths := TList<integer>.Create;
    try
      CurrentRowWidth := 0;

      for item in zControls do
      begin
        if not item.Visible then
          Continue;
        if not SameText(item.Group, '') then
          Continue; // i gruppi hanno la loro larghezza interna

        case item.zCtrlType of
          ctLineBreak:
            begin
              RowWidths.Add(CurrentRowWidth);
              CurrentRowWidth := 0;
            end;
          ctSeparator:
            begin
              // Il separatore occupa tutta la riga disponibile:
              // chiude la riga corrente e ne apre una dedicata
              if CurrentRowWidth > 0 then
                RowWidths.Add(CurrentRowWidth);
              RowWidths.Add(0); // riga separatore: larghezza = MaxAvail, non conta
              CurrentRowWidth := 0;
            end;
        else
          w := ControlLogicalWidth(item);
          if w > 0 then
          begin
            if CurrentRowWidth = 0 then
              CurrentRowWidth := w
            else
              CurrentRowWidth := CurrentRowWidth + HSpace + w;
          end;
        end;
      end;

      if CurrentRowWidth > 0 then
        RowWidths.Add(CurrentRowWidth);

      result := RowWidths.ToArray;
    finally
      FreeAndNil(RowWidths);
    end;
  end;

var
  RowWidths: TArray<integer>;
  MaxRowWidth: integer;
  w: integer;
begin
  Monitor := ActiveMonitor;
  MaxAvailWidth := Round(Monitor.Width * MAX_WIDTH_RATIO);
  FontWidth := CardInfo.FontWidth;

  RowWidths := CalcNaturalRowWidths;
  MaxRowWidth := 0;

  for w in RowWidths do
    MaxRowWidth := Max(MaxRowWidth, w);

  // aggiungi margini + scrollbar
  result := MaxRowWidth + H_MARGIN + VSCROLLBAR_WIDTH + CardInfo.HorizontalSpaceBetweenControls; // margine destro

  // clamp
  result := Max(result, MIN_WIDTH);
  result := Min(result, MaxAvailWidth);

  // porta a multiplo di 10 per avere un valore "pulito"
  result := (result div 10) * 10;
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
  for cmd := Low(TzDbCardCommand) to High(TzDbCardCommand) do
    PostedCommands[cmd] := false;
  inherited;
end;

procedure TzDbCard.EditToolsExecute(Sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbCard.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

function TzDbCard.GetProps: TzBaseComponentProps;
begin
  result := zDbCardProps;
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

  zSystem zdbpivot zdbview

  zDX zdbview zDX zFbDataSet zmap
