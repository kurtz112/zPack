unit zDX;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Generics.Collections,
  System.ImageList,
  Vcl.Forms,
  Vcl.AppEvnts,
  Vcl.ImgList,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  Data.DB,
  dxSkinsForm,
  dxLayoutLookAndFeels,
  dxSkinsCore,
  dxSkinInfo,
  dxScreenTip,
  dxCustomHint,
  dxAlertWindow,
  dxBar,
  dxSkinChooserGallery,
  dxBarExtItems,
  dxGDIPlusClasses,
  zTranslate.Apply,
  dxLayoutCommon,
  dxLayoutControl,
  dxCore,
  dxPSGlbl,
  dxPSUtl,
  dxPSEngn,
  dxPrnPg,
  dxBkgnd,
  dxWrap,
  dxPrnDev,
  dxPSCompsProvider,
  dxPSFillPatterns,
  dxPSEdgePatterns,
  dxPSPDFExportCore,
  dxPSPDFExport,
  dxPSPrVwStd,
  dxPSPrVwAdv,
  dxPSPrVwRibbon,
  dxPScxPageControlProducer,
  dxPScxTLLnk,
  dxPSdxSpreadSheetLnk,
  dxPSRichEditControlLnk,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxSpellCheckerCore,
  dxSpellChecker,
  cxLookAndFeels,
  cxContainer,
  cxEdit,
  cxLabel,
  cxClasses,
  cxHint,
  cxLookAndFeelPainters,
  cxGraphics,
  cxLookupEdit,
  cxDBLookupComboBox,
  cxDBData,
  cxGridLevel,
  cxGridCustomView,
  cxGridCustomTableView,
  cxGridTableView,
  cxGridDBTableView,
  cxGrid,
  cxCheckBox,
  cxBarEditItem,
  cxStyles,
  cxTreeView,
  cxImageComboBox,
  cxButtonEdit,
  cxColorComboBox,
  cxPC,
  cxSplitter,
  cxDBPivotGrid,
  cxTL,
  cxDBTL,
  cxFilterControl,
  cxCalendar,
  cxTimeEdit,
  cxScheduler,
  cxDropDownEdit,
  cxCheckComboBox,
  cxDBCheckComboBox,
  cxImageList,
  cxProgressBar,
  cxDBProgressBar,
  cxDrawTextUtils,
  cxDBExtLookupComboBox,
  dxLayoutContainer,
  dxRatingControl,
  dxDBRatingControl,
  zFbDataSet,
  zBaseLib,
  zSystem,
  QExport4_ITA;

const
  // Icona in Immagini della voce «Tutti» che i filtri aggiungono in testa alle picklist (pallino grigio)
  ImmagineVoceTutti = 554;

type
  // TStyleKind = (skTitle, skGridContent, skGridContentEven, skGridContentOdd);
  TColorKind = (ckControl, ckContent, ckTitle, ckEditorNormal, ckEditorRequired, ckEditorReadOnly, ckEditorDisabled, ckLabel, ckSeparator, ckWizard, ckWizardTitle, ckWizardWaterMark, ckGridContent, ckGridContentEven, ckGridContentOdd, ckGridFooter,
    ckFilterBox, ckTreeView, ckInspector, ckInspectorValues, ckBtnFace);

  TStyleColor = (scBtnFace, scMoneyGreen, scMoneyGreenLight, scCream, scInfoBk, scSkyBlue, scSkyBlueLight, scHeader, scHeaderBackground, scHighlight, scControl, scContent, scContentOdd, scContentEven, scFooter);

  TzLayoutLookAndFeel = class(TdxLayoutSkinLookAndFeel)
  private
    FHideGroupBorder: boolean;
  public
    constructor Create(aOwner: TComponent); override;
    function GetGroupBorderOffset(AContainer: TComponent; ASide, ACaptionSide: TdxLayoutSide): integer; override;
    function GetGroupPainterClass: TClass; override;
    property HideGroupBorder: boolean read FHideGroupBorder write FHideGroupBorder;
  end;

  TCustomStyle = class(TPersistent)
  private
    FAssignedValues: TcxStyleValues;
    FBaseStyle: TcxStyle;
    FStyle: TcxStyle;
  public
    Constructor Create;
    procedure UpdateCustomStyle;

    property Style: TcxStyle read FStyle write FStyle;
    property BaseStyle: TcxStyle read FBaseStyle write FBaseStyle;
    property AssignedValues: TcxStyleValues read FAssignedValues write FAssignedValues;
  end;

  TcxCustomEditHelper = class helper for TcxCustomEdit
  public
    function isEmpty: boolean;
    function asInteger: integer;
    function asString: String;
    function asDateTime: TDateTime;
    function asDouble: double;
  end;

  Tdx = class(TDataModule)
    dxSkinController: TdxSkinController;
    dxLayoutLookAndFeelList: TdxLayoutLookAndFeelList;
    cxLookAndFeelController: TcxLookAndFeelController;
    cxHintStyleController: TcxHintStyleController;
    dxAlertWindowManager: TdxAlertWindowManager;
    cxStyleRepository: TcxStyleRepository;
    cxStyleContentEven: TcxStyle;
    cxStyleContentOdd: TcxStyle;
    cxStyleContent: TcxStyle;
    TitleStyleController: TcxEditStyleController;
    LabelStyleController: TcxEditStyleController;
    SeparatorStyleController: TcxEditStyleController;
    NormalStyleController: TcxEditStyleController;
    ReadOnlyStyleController: TcxEditStyleController;
    RequiredStyleController: TcxEditStyleController;
    BaseStyleController: TcxEditStyleController;
    TreeStyleController: TcxEditStyleController;
    cxStyleFooter: TcxStyle;
    BtnFaceStyleController: TcxEditStyleController;
    cxStyleBtnFace: TcxStyle;
    cxStyleMoneyGreen: TcxStyle;
    cxStyleMoneyGreenLight: TcxStyle;
    cxStyleCream: TcxStyle;
    cxStyleInfoBk: TcxStyle;
    cxStyleSkyBlue: TcxStyle;
    cxStyleSkyBlueLight: TcxStyle;
    cxStyleHeader: TcxStyle;
    cxStyleHeaderBackground: TcxStyle;
    cxStyleHighlight: TcxStyle;
    cxStyleControl: TcxStyle;
    cxStyleFilterBox: TcxStyle;
    dxLayoutSkinLookAndFeelHeader: TdxLayoutSkinLookAndFeel;
    LargeStyleController: TcxEditStyleController;
    MediumStyleController: TcxEditStyleController;
    Glyphs: TcxImageList;
    // lista unica delle icone di zPack (SVG, 16 px; i pulsanti grandi la riusano a 32)
    Immagini: TcxImageList;
    GroupStyleController: TcxEditStyleController;
    PrinterEngine: TdxPSEngineController;
    cxStyleTreeListInactive: TcxStyle;
    cxGridViewRepository: TcxGridViewRepository;
    dxSpellChecker: TdxSpellChecker;
    MicroImages: TcxImageList;
    TaskbarImages: TcxImageList;
    RequiredImages: TcxImageList;
    procedure dxSpellCheckerCheckAsYouTypePopup(ASender: TdxCustomSpellChecker; APopupMenu: TComponent; var AHandled: boolean);
  private
    InternalLayoutLookAndFeelNormal: TzLayoutLookAndFeel;
    InternalLayoutLookAndFeelNoBorder: TzLayoutLookAndFeel;

    FSkinName: string;
    FSkinPaletteName: string;
    function GetSkinActive: boolean;
    procedure SetSkinName(const Value: string);
    procedure SetSkinPaletteName(const Value: string);
    procedure LoadSkin(SkinName: string);
    function SkinFileName: string;
  private
    CustomStyles: TObjectList<TCustomStyle>;
    procedure UpdateStyles;
    procedure UpdateCustomStyles;
  private
    // Esito dell'ultimo InitSpellChecker. Non e' diagnostica per il
    // programmatore: e' la risposta alla domanda "perche' non mi segna gli
    // errori?", che altrimenti non ha nessuna risposta visibile da nessuna
    // parte.
    FCorrettoreAttivo: boolean;
    FCorrettoreMotivo: string;
    FSanificaTesto: boolean;
    procedure ValidateRequired(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
    procedure ValidateNormal(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
    // sanificazione del testo digitato o incollato (TzSanificazione, livello predefinito)
    procedure SanificaDisplayValue(Sender: TObject; var DisplayValue: Variant);
    // regola del dominio del campo legato all'editor: oggi solo e-mail (TzDomain.SanificaEmail)
    procedure ValidaDominio(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
    function DominioDelSender(Sender: TObject): TzDomain;
  public
    // True (predefinito): ogni editor di testo ripulisce il valore all'uscita dal campo.
    // Da impostare dall'applicazione all'avvio in base alla configurazione dell'ente.
    property SanificaTesto: boolean read FSanificaTesto write FSanificaTesto;
  private
    // routine per i lookup
    procedure LookupComboButtonClick(Sender: TObject; AButtonIndex: integer);
    procedure LookupInitPopup(Sender: TObject);
    procedure LookupCloseUp(Sender: TObject);
    procedure LookupFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: boolean);
    procedure LookupApplyBestFit(cxGridDBTableView: TcxGridDBTableView; BestFitMaxRecordCount: integer);

    procedure LookupGridViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure LookupGridViewCanSelectRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: boolean);

    procedure LookupGridViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: boolean);
    procedure LookupGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: boolean);

    // routine per accedere alla TLookupViewProps
    function LookupGridViewAllowSelect(cxCustomGridTableView: TcxCustomGridTableView; DefaultValue: boolean): boolean;
    procedure LookupGridViewSetAllowSelect(cxCustomGridTableView: TcxCustomGridTableView; Value: boolean);
    function LookupGridViewAllowApplyBestFit(cxCustomGridTableView: TcxCustomGridTableView; DefaultValue: boolean): boolean;
    procedure LookupGridViewSetAllowApplyBestFit(cxCustomGridTableView: TcxCustomGridTableView; Value: boolean);

    // Mantis #151 - 2026-09-21: sorveglianza del popup lookup attualmente aperto, per non
    // ridereferenziare un controllo gia' chiuso o distrutto dentro le callback differite
  private
    FLookupPopupComboBox: TcxCustomExtLookupComboBox;
    FLookupPopupGenerazione: integer;
    function LookupPopupRegistra(cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox): integer;
    procedure LookupPopupDimentica;
    function LookupPopupAncoraValido(Generazione: integer): boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    // ignora i DPI con cui l'IDE ha salvato il DFM: vedi l'implementazione
    procedure ReadState(Reader: TReader); override;
  private
    procedure ColorCombo_SelectCustomColor(Sender: TObject; var AColor: TColor; var AColorDescription: string; var AddToList: boolean);
    procedure ColorCombo_EditValueChanged(Sender: TObject);
  private
    procedure ProgressBarEditValueChanged(Sender: TObject);
  private
    procedure InitStyleTreeListInactive;
  private
    // Mantis #269 - 2026-10-21: chiusura dei filtri e delle tendine a ogni finestra modale
    EventiApplicazione: TApplicationEvents;
    procedure ApplicazioneModalBegin(Sender: TObject);
  public
    // Chiude ogni finestra a discesa DevExpress aperta: filtri di colonna di
    // griglie, pivot, tree list e vertical grid, tendine degli editor. Una di
    // queste lasciata aperta sotto un dialogo modale resta cliccabile e puo'
    // cambiare il filtro, quindi riaprire il dataset su cui il dialogo lavora.
    // Chiamata da sola all'inizio di ogni ShowModal (OnModalBegin); da chiamare
    // anche prima di ogni operazione che cambia lo stato del dataset di una vista.
    procedure ChiudiFiltriAperti;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    // skin
    procedure InitSkinChooserGalleryItem(dxSkinChooserGalleryItem: TdxSkinChooserGalleryItem);
    procedure InitRibbonSkinSelector(dxRibbonSkinSelector: TdxRibbonSkinSelector);
    procedure RibbonSkinSelectorApplySkin(const ASkinName: string; var AHandled: boolean);

    procedure GetSkinNames(SkinList: TStrings);
    function GetSkinPainter: TcxCustomLookAndFeelPainter;
    function GetSkinInfo: TdxSkinInfo;

    property SkinName: string read FSkinName write SetSkinName;
    property SkinPaletteName: string read FSkinPaletteName write SetSkinPaletteName;
    property SkinActive: boolean read GetSkinActive;
  public
    // Posizione di un'icona nella lista unica Immagini dal nome del suo file
    // SVG, senza estensione ('expandall'): gli indici scritti nel codice
    // cambiano quando il catalogo si rigenera, il nome no. -1 se non c'e'.
    function IndiceIcona(const Nome: string): integer;

    // Collega Immagini ai componenti di Radice che la usano ma l'hanno persa.
    // Il riferimento "Images = dx.Immagini" nel DFM l'IDE lo scrive solo se
    // il modulo zDX e' aperto: salvando una form o un frame senza averlo
    // aperto il riferimento sparisce in silenzio e le icone con lui. Da
    // chiamare nel costruttore, dopo inherited: tocca solo le proprieta'
    // rimaste vuote, quindi una lista diversa assegnata nel DFM resta com'e'.
    procedure AgganciaImmagini(Radice: TComponent);
  private
    procedure dxLayoutControlGetItemStoredProperties(Sender: TdxCustomLayoutControl; AItem: TdxCustomLayoutItem; AProperties: TStrings);
    procedure dxLayoutControlGetItemStoredPropertyValue(Sender: TdxCustomLayoutControl; AItem: TdxCustomLayoutItem; const AName: string; var AValue: Variant);
    procedure dxLayoutControlSetItemStoredPropertyValue(Sender: TdxCustomLayoutControl; AItem: TdxCustomLayoutItem; const AName: string; const AValue: Variant);
  private
    procedure cxDBCheckComboBoxPropertiesEditValueToStates(Sender: TObject; const AValue: Variant; var ACheckStates: TcxCheckStates);
    procedure cxDBCheckComboBoxPropertiesStatesToEditValue(Sender: TObject; const ACheckStates: TcxCheckStates; out AValue: Variant);
  private
    procedure doDrawBandSeparator(ACanvas: TcxCanvas; r: TRect);
  public
    function BlendColor(AColor1, AColor2: TColor; APercentage: integer): TColor;
    function GetSkinColor(const AColorName: string; ADefault: TColor): TColor;

    function GetColor(ColorKind: TColorKind): TColor; overload;
    function GetColorPippo(ColorKind: TColorKind): TColor;

    function GetFontColor(ColorKind: TColorKind): TColor; overload;

    function GetColor(StyleColor: TStyleColor): TColor; overload;
    function GetFontColor(StyleColor: TStyleColor): TColor; overload;

    function GetBarColor: TColor;
  public
    function GetStyle(StyleColor: TStyleColor): TcxStyle;

    procedure RegisterCustomStyle(Style: TcxStyle; BaseStyle: TcxStyle; AssignedValues: TcxStyleValues);
    procedure UnregisterCustomStyle(Style: TcxStyle);
  public

    // cxCustomEdit
    function GetCustomEditClass(ControlType: TzCtrlType; const dbAware: boolean = true): TcxCustomEditClass;
    function GetPropertiesClass(ControlType: TzCtrlType): TcxCustomEditPropertiesClass;
    procedure InitProperties(ControlType: TzCtrlType; Properties: TcxCustomEditProperties); Overload;
    procedure InitProperties(ControlType: TzCtrlType; Properties: TcxCustomEditProperties; Domain: TzDomain; Field: TField); overload;

  public // LOOKUP
    procedure InitLookup(IdLookup: string; cxLookupComboBox: TcxCustomLookupComboBox; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, ListFields: string; const HyperLink: boolean = false); overload;

    procedure InitLookup(IdLookup: string; cxLookupComboBoxProperties: TcxLookupComboBoxProperties; DataField: string; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, ListFields: string; const HyperLink: boolean = false); overload;

    procedure InitLookupColumns(const IdLookup: string; LookupComboBoxProperties: TcxLookupComboBoxProperties; DataSet: TzFbDataSet); overload;
  public // LOOKUP EXT
    procedure InitLookup(IdLookup: string; cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, DisplayColumns: string; cxGridViewRepository: TcxGridViewRepository = nil;
      const HyperLink: boolean = false; const AddClearButton: boolean = false); overload;

    procedure InitLookup(IdLookup: string; cxExtLookupComboBoxProperties: TcxExtLookupComboBoxProperties; DataField: string; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, DisplayColumns: string;
      aGridViewRepository: TcxGridViewRepository = nil; const HyperLink: boolean = false; const AddClearButton: boolean = false); overload;

    procedure InitLookupColumns(const IdLookup: string; ExtLookupComboBoxProperties: TcxExtLookupComboBoxProperties; DataSet: TzFbDataSet); overload;
  public
    procedure InitPickList(cxImageComboBoxProperties: TcxImageComboBoxProperties; const PickListName: string); overload;
    procedure InitButtonEdit(cxButtonEditProperties: TcxButtonEditProperties; OnButtonClick: TcxEditButtonClickEvent; const Editable: boolean = false);
    procedure InitColorCombo(cxColorComboBoxProperties: TcxColorComboBoxProperties);
    procedure InitDateEdit(cxDateEditProperties: TcxDateEditProperties);
    procedure InitTimeEdit(cxTimeEditProperties: TcxTimeEditProperties);

    procedure InitGrid(cxCustomGridTableView: TcxCustomGridTableView);
    procedure InitTreeList(cxTreeList: TcxTreeList; const ApplyStyles: boolean = true); overload;
    procedure InitTreeList(cxDbTreeList: TcxDbTreeList; const ApplyStyles: boolean = true); overload;
    procedure InitPivot(pivot: TcxDBPivotGrid);

    procedure InitTitle(Title: TcxLabel);
    procedure InitLabel(cxLabel: TcxLabel; const Transparent: boolean = true);
    procedure InitSeparator(Separator: TcxLabel);

    procedure InitLayoutControl(dxLayoutControl: TdxLayoutControl);
    procedure InitPageControl(cxPageControl: TcxPageControl);
    procedure InitSplitter(cxSplitter: TcxSplitter);

    procedure InitScheduler(Scheduler: TcxScheduler);

    procedure InitBar(bar: TdxBar);

    procedure InitPrinter(printer: TdxComponentPrinter);

    procedure SetFilterControlFonts(FilterControl: TcxCustomFilterControl);
    // InitBarManager

    function GetStyleController(Editability: TEditability): TcxEditStyleController;
    function GetTreeStyleController: TcxEditStyleController;

    procedure AssignPickList(Properties: TcxCustomEditProperties; zPickList: TzPickList);
    procedure DataBind(cxCustomEdit: TcxCustomEdit; DataSource: TDataSource; DataField: string);

    // TEditability
    procedure SetEditability(cxCustomEdit: TcxCustomEdit; const Editability: TEditability; const doValidate: boolean = true); overload;
    procedure SetEditability(Column: TcxGridDBColumn; const Editability: TEditability); overload;
    procedure SetEditability(Properties: TcxCustomEditProperties; const Editability: TEditability); overload;
  public
    // bande cxTreeList
    procedure DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListBandHeaderCellViewInfo; var ADone: boolean); overload;
    procedure DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListColumnHeaderCellViewInfo; var ADone: boolean); overload;
    procedure DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: boolean); overload;
    procedure DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListHeaderCellViewInfo; var ADone: boolean); overload;
  public
    // bar
    procedure SetValue(item: TcxBarEditItem; Value: Variant); overload;
    procedure SetValue(item: TdxBarEdit; Value: string); overload;
    procedure SetValue(item: TdxBarSpinEdit; Value: Extended); overload;
    procedure SetValue(item: TcxCheckBox; Value: boolean); overload;

    function GetStatesString(a: array of boolean): string;
  public
    // customEdit
    procedure SetValue(cxCustomEdit: TcxCustomEdit; Value: Variant); overload;
    function GetValue(cxCustomEdit: TcxCustomEdit): Variant;

    //
    function ValueStr(cxCustomEdit: TcxCustomEdit): string;
    function ValueDate(cxCustomEdit: TcxCustomEdit): TDateTime;
    function ValueInt(cxCustomEdit: TcxCustomEdit): integer;
    function ValueDouble(cxCustomEdit: TcxCustomEdit): double;
  public
    // tool
    function IsActiveControl(cxCustomEdit: TcxCustomEdit): boolean; overload;
    function IsActiveControl(cxGrid: TcxGrid): boolean; overload;

    function ActiveControl: TcxCustomEdit;
    function ActiveGrid: TcxGridDBTableView;

    function GridEditable(grid: TcxGridDBTableView): boolean;

    function Alert(const ACaption, AText: string; AImageIndex: TImageIndex = -1): TdxAlertWindow;
    function Visible(const Visible: boolean): TdxBarItemVisible;

    procedure GetBitmap(Glyph: TdxSmartGlyph; ImageList: TCustomImageList; ImageIndex: TImageIndex);

    function FieldSize(Field: TField): integer;
    function FontTextWidth(Font: TFont; const Text: string = '0'): integer;
    function FontTextHeight(Font: TFont; const Text: string = '0'): integer;

    function LayoutLookAndFeelNormal: TdxCustomLayoutLookAndFeel;
    function LayoutLookAndFeelNoGroupBorder: TdxCustomLayoutLookAndFeel;

    function RibbonColorSchemeName: string;
  public
    procedure dxBarAssignPopupMenu(bar: TdxBar; dxBarPopupMenu: TdxBarPopupMenu);
    procedure dxBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);

    function dxBarRequiredWidth(bar: TdxBar): integer;
  public
    function CreateGridDBTableView(cxGridViewRepository: TcxGridViewRepository; DataSource: TDataSource; KeyFieldNames: string): TcxGridDBTableView;
  public
    procedure InitSpellChecker(const UserFolder: string);
    procedure ShowSpellingOptionsDialog;

    // Vero se i dizionari sono stati caricati davvero. Falso con il motivo in
    // CorrettoreMotivo: quasi sempre i due file del dizionario che non ci
    // sono accanto all'eseguibile.
    property CorrettoreAttivo: boolean read FCorrettoreAttivo;
    property CorrettoreMotivo: string read FCorrettoreMotivo;
    procedure PrepareSpellCheckerPopup(point: TPoint; Popup: TPopupMenu);
  public
    function LayoutControlHeigth(LayoutControl: TdxLayoutControl): integer;
  end;

function dx: Tdx;

// Colori che seguono la skin e la palette attive, per il testo disegnato a
// mano (OnCustomDraw di alberi e griglie, etichette di stato): un colore fisso
// scelto su una skin chiara sparisce su una scura, e viceversa. Sono funzioni
// della unit e non metodi di Tdx: leggono RootLookAndFeel, quindi valgono
// anche nei programmi che applicano la skin senza il dxSkinController di Tdx,
// e non creano il modulo (che con i suoi controller cambierebbe l'aspetto).
//
// Vero se il fondo del contenuto (elenchi, alberi, griglie) e' scuro
function SkinScura: boolean;
// Colore della palette attiva della skin dal nome ('Red', 'Green', 'Blue',
// 'Key Paint'...); Predefinito se la skin non c'e' o non ha quel colore. Il
// colore non e' corretto per il contrasto: per il testo, ColoreSuSkin
function ColorePalette(const Nome: string; Predefinito: TColor): TColor;
// Colore schiarito o scurito, tinta compresa, finche' su Sfondo raggiunge il
// contrasto minimo del testo normale delle WCAG (4,5:1). Sfondo clDefault =
// fondo del contenuto della skin attiva
function ColoreLeggibile(Colore: TColor; Sfondo: TColor = clDefault): TColor;
// Le due insieme: il colore della palette, o Predefinito, reso leggibile
function ColoreSuSkin(const NomePalette: string; Predefinito: TColor; Sfondo: TColor = clDefault): TColor;

type
  TcxCustomCheckComboBoxHelper = class helper for TcxCustomCheckComboBox
  public
    procedure FillItem(const Description, ShortDescription: string);
    procedure FillItems(items: TStrings);

    procedure EnableItem(ShortDescription: string; Enabled: boolean);
    procedure EnableItems(items: TStrings);

    procedure EditValueToStates(const AValue: Variant; var ACheckStates: TcxCheckStates);
    procedure StatesToEditValue(const ACheckStates: TcxCheckStates; out AValue: Variant);
  end;

implementation

uses
  System.Variants,
  System.IniFiles,
  System.Math,
  System.DateUtils,
  System.Rtti,
  System.TypInfo,
  Vcl.StdCtrls,
  Vcl.Clipbrd,
  Vcl.Dialogs,
  Vcl.ActnList,
  dxRibbonGallery,
  dxSkinsDefaultPainters,
  dxLayoutPainters,
  dxToggleSwitch,
  dxDBToggleSwitch,
  dxCheckGroupBox,
  dxDBCheckGroupBox,
  dxFormattedLabel,
  dxDBFormattedLabel,
  dxTokenEdit,
  dxDBTokenEdit,
  dxWheelPicker,
  dxNumericWheelPicker,
  dxDateTimeWheelPicker,
  dxDBDateTimeWheelPicker,
  dxSkinsStrs,
  dxSkinsLookAndFeelPainter,
  dxSpellCheckerDialogs,
  dxHunspellDictionary,
  dxSpellCheckerCheckAsYouType,
  cxDBEdit,
  cxDBRichEdit,
  cxTextEdit,
  cxSpinEdit,
  cxRadioGroup,
  cxMemo,
  cxRichEdit,
  cxImage,
  cxHyperLinkEdit,
  cxLookupDBGrid,
  cxMaskEdit,
  cxGridDBDataDefinitions,
  cxDBColorComboBox,
  cxControls,
  cxFormats,
  cxDateUtils,
  cxSchedulerCustomResourceView,
  cxSchedulerUtils,
  cxCustomListBox,
  cxListBox,
  cxGroupBox,
  cxCheckListBox,
  cxDBCheckListBox,
  cxCheckGroup,
  cxDBCheckGroup,
  cxShellComboBox,
  cxDBShellComboBox,
  zDbViewDlg,
  zLocalizer,
  cxOIComponentCollectionEd, // usato, ad es., da zOffice.Excel.Editor
  zDxLayoutCustomizeFrm,
  zz.Vcl,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  zSanificazione,
  zSanificazione.Email;
{$R *.dfm}

var
  _dx: Tdx = nil;
  siDX: TsiSession;

type
  TColors = System.UITypes.TColors;

  TdxBarControlAccess = class(TdxBarControl);
  TcxCustomEditAccess = class(TcxCustomEdit);
  TcxCustomDropDownEditAccess = class(TcxCustomDropDownEdit);
  TdxSpellCheckerAccess = class(TdxSpellChecker);
  TdxSpellCheckerCheckAsYouTypeManagerAccess = class(TdxSpellCheckerCheckAsYouTypeManager);
  TcxCustomEditPopupWindowAccess = class(TcxCustomEditPopupWindow);
  TcxGridAccess = class(TcxGrid);

  TBitmapAccess = class(TBitmap);

function dx: Tdx;
begin
  if not Assigned(_dx) then
  begin
    // Application.CreateForm(Tdx, _dx);
    _dx := Tdx.Create(nil);
    _dx.UpdateStyles;
  end;

  result := _dx;
end;

/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////

{ TcxDBCheckComboBoxHelper }

procedure TcxCustomCheckComboBoxHelper.FillItems(items: TStrings);
var
  I: integer;
  Description, ShortDescription: string;
begin
  Properties.items.Clear;

  for I := 0 to items.Count - 1 do
  begin
    ShortDescription := items.KeyNames[I];
    Description := items.ValueFromIndex[I];

    if Description.isEmpty then
      Description := ShortDescription;

    FillItem(Description, ShortDescription);
  end;
end;

procedure TcxCustomCheckComboBoxHelper.FillItem(const Description, ShortDescription: string);
var
  item: TcxCheckComboBoxItem;
begin
  item := Properties.items.Add;
  item.Description := Description;
  item.ShortDescription := ShortDescription;
end;

procedure TcxCustomCheckComboBoxHelper.EnableItems(items: TStrings);
var
  I: integer;
  item: TcxCheckComboBoxItem;
begin

  for I := 0 to Properties.items.Count - 1 do
  begin
    item := Properties.items[I];
    item.Enabled := items.IndexOf(item.ShortDescription) >= 0;
  end;
end;

procedure TcxCustomCheckComboBoxHelper.EnableItem(ShortDescription: string; Enabled: boolean);
var
  I: integer;
begin

  for I := 0 to Properties.items.Count - 1 do
    if SameText(Properties.items[I].ShortDescription, ShortDescription) then
    begin
      Properties.items[I].Enabled := Enabled;
      Exit;
    end;
end;

procedure TcxCustomCheckComboBoxHelper.EditValueToStates(const AValue: Variant; var ACheckStates: TcxCheckStates);

var
  I: integer;
  Value, s: string;
begin

  for I := 0 to Length(ACheckStates) - 1 do
    ACheckStates[I] := cbsUnchecked;

  if VarIsNull(AValue) then
    Exit;

  Value := AValue;
  Value := Value + Properties.Delimiter;

  for I := 0 to Properties.items.Count - 1 do
  begin
    if Value.Contains(Properties.items[I].ShortDescription) then
      ACheckStates[I] := cbsChecked
    else
      ACheckStates[I] := cbsUnchecked;
  end;
end;

procedure TcxCustomCheckComboBoxHelper.StatesToEditValue(const ACheckStates: TcxCheckStates; out AValue: Variant);
var
  I: integer;
begin
  AValue := '';

  for I := 0 to Length(ACheckStates) - 1 do
    if ACheckStates[I] = cbsChecked then
      AValue := AValue + Properties.items[I].ShortDescription + Properties.Delimiter;

  if AValue = '' then
    AValue := null;
end;

/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////

{ TCustomStyle }
constructor TCustomStyle.Create;
begin
  FAssignedValues := [];
  FBaseStyle := nil;
  FStyle := nil;
end;

procedure TCustomStyle.UpdateCustomStyle;
begin
  if not(svBitmap in AssignedValues) then
    Style.Bitmap.Assign(BaseStyle.Bitmap);

  if not(svColor in AssignedValues) then
    Style.Color := BaseStyle.Color;

  if not(svFont in AssignedValues) then
    Style.Font.Assign(BaseStyle.Font);

  if not(svTextColor in AssignedValues) then
    Style.TextColor := BaseStyle.TextColor;
end;

/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////
type
  TLookupViewProps = class(TComponent)
  private
    FAllowApplyBestFit: boolean;
    FAllowSelect: boolean;
  public
    constructor Create(aOwner: TComponent); override;

    property AllowSelect: boolean read FAllowSelect write FAllowSelect;
    property AllowApplyBestFit: boolean read FAllowApplyBestFit write FAllowApplyBestFit;
  end;

constructor TLookupViewProps.Create(aOwner: TComponent);
begin
  inherited;
  FAllowApplyBestFit := true;
  FAllowSelect := true;
end;

/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////

constructor Tdx.Create(aOwner: TComponent);
  procedure InitStyleControllers;
  begin

    ForEach<TcxEditStyleController>(
      procedure(cxEditStyleController: TcxEditStyleController)
      begin
        cxEditStyleController.Scalable := false;
        cxEditStyleController.Style.Font.Size := 10;
      end);
  end;

var
  Style: TcxStyle;
  I: integer;
begin
  inherited;

  // Traduzione italiana dei testi di DevExpress e Delphi (zTranslate): l'esito
  // va nel registro; una risorsa mancante o un errore non fermano l'avvio
  try
    siDX.LogMessage('zTranslate: ' + zTranslate.Apply.Translate.Summary);
  except
    on E: Exception do
      siDX.LogException(E);
  end;

  CustomStyles := TObjectList<TCustomStyle>.Create(true);
  FSanificaTesto := true;

  FSkinName := '';
  dxSkinController.SkinName := 'UserSkin';

  // Style
  InitStyleControllers;
  // TitleStyleController.Style.Font.Style := [fsUnderline];
  TitleStyleController.Style.Font.Style := [fsBold];
  SeparatorStyleController.Style.Font.Style := [fsBold];
  MediumStyleController.Style.Font.Size := 11;
  LargeStyleController.Style.Font.Size := 14;

  InternalLayoutLookAndFeelNormal := TzLayoutLookAndFeel.Create(dxLayoutLookAndFeelList);
  InternalLayoutLookAndFeelNormal.Name := 'LayoutLookAndFeelNormal';
  InternalLayoutLookAndFeelNormal.LookAndFeel.Kind := lfUltraFlat;

  InternalLayoutLookAndFeelNoBorder := TzLayoutLookAndFeel.Create(dxLayoutLookAndFeelList);
  InternalLayoutLookAndFeelNoBorder.Name := 'LayoutLookAndFeelNoBorder';
  InternalLayoutLookAndFeelNoBorder.HideGroupBorder := true;
  InternalLayoutLookAndFeelNoBorder.LookAndFeel.Kind := lfUltraFlat;

  for I := 0 to cxStyleRepository.Count - 1 do
    if cxStyleRepository.items[I] is TcxStyle then
    begin
      Style := cxStyleRepository.items[I] as TcxStyle;
      Style.Font.Assign(BaseStyleController.Style.Font);
      // Style.Font.Size := 9;
    end;

  dxSpellChecker.AutoLoadDictionaries := false;
  dxSpellChecker.DictionaryItems.Clear;

  // TApplicationEvents e non Application.OnModalBegin: il componente si somma
  // agli altri gestori invece di sostituirli
  EventiApplicazione := TApplicationEvents.Create(Self);
  EventiApplicazione.OnModalBegin := ApplicazioneModalBegin;
end;

procedure Tdx.ApplicazioneModalBegin(Sender: TObject);
begin
  ChiudiFiltriAperti;
end;

procedure Tdx.ChiudiFiltriAperti;
var
  Indice: integer;
  Finestra: TCustomForm;
begin
  // tutte le finestre a discesa DevExpress discendono da TcxPopupWindow
  // (TcxGridFilterPopup, TdxFilterPopupWindow, TcxCustomEditPopupWindow...):
  // CloseUp le nasconde con la stessa procedura di un clic fuori
  for Indice := Screen.CustomFormCount - 1 downto 0 do
  begin
    Finestra := Screen.CustomForms[Indice];
    if (Finestra is TcxPopupWindow) and Finestra.Visible then
      TcxPopupWindow(Finestra).CloseUp;
  end;
end;

procedure Tdx.ColorCombo_EditValueChanged(Sender: TObject);
var
  // cxCustomEdit: TcxCustomEdit;
  cxColorComboBox: TcxColorComboBox;
  cxColorComboBoxProperties: TcxColorComboBoxProperties;
  Value: integer;
begin

  if Sender is TcxColorComboBox then
  begin
    // cxCustomEdit := TcxCustomEdit(Sender);

    // if VarIsNull(cxCustomEdit.EditingValue) then
    // Exit;
    //
    // Value := cxCustomEdit.EditingValue;

    cxColorComboBox := TcxColorComboBox(Sender);
    Value := cxColorComboBox.ColorValue;

    if cxColorComboBox.ActiveProperties is TcxColorComboBoxProperties then
    begin
      cxColorComboBoxProperties := cxColorComboBox.ActiveProperties as TcxColorComboBoxProperties;

      if not Assigned(cxColorComboBoxProperties.items.FindColorItem(Value)) then
        if not Assigned(cxColorComboBoxProperties.CustomColors.FindColorItem(Value)) then
          cxColorComboBoxProperties.CustomColors.AddColor(Value, '');
    end;
  end;
end;

procedure Tdx.ColorCombo_SelectCustomColor(Sender: TObject; var AColor: TColor; var AColorDescription: string; var AddToList: boolean);
begin
  AddToList := true;
  AColorDescription := '';
end;

procedure Tdx.cxDBCheckComboBoxPropertiesEditValueToStates(Sender: TObject; const AValue: Variant; var ACheckStates: TcxCheckStates);
begin

  if Assigned(Sender) then
    TcxDBCheckComboBox(Sender).EditValueToStates(AValue, ACheckStates);
end;

procedure Tdx.cxDBCheckComboBoxPropertiesStatesToEditValue(Sender: TObject; const ACheckStates: TcxCheckStates; out AValue: Variant);
begin
  if Assigned(Sender) then
    TcxDBCheckComboBox(Sender).StatesToEditValue(ACheckStates, AValue);
end;

destructor Tdx.Destroy;
begin
  FreeAndNil(CustomStyles);
  inherited;
end;

procedure Tdx.DataBind(cxCustomEdit: TcxCustomEdit; DataSource: TDataSource; DataField: string);
var
  Binding: TcxDBEditDataBinding;
begin
  Binding := TcxDBEditDataBinding(TcxCustomEditAccess(cxCustomEdit).DataBinding);
  Binding.DataSource := DataSource;
  Binding.DataField := DataField;
end;

function Tdx.SkinFileName: string;
begin
  result := ChangeFileExt(Application.ExeName, '.skinres');
end;

function Tdx.GetTreeStyleController: TcxEditStyleController;
begin
  result := TreeStyleController;
end;

function Tdx.GetValue(cxCustomEdit: TcxCustomEdit): Variant;
begin
  result := null;

  if Assigned(cxCustomEdit) then
  begin
    result := cxCustomEdit.EditValue;

    // se vuoto restituisce 0 invece di null
    if cxCustomEdit is TcxCustomSpinEdit then
      if TcxCustomSpinEdit(cxCustomEdit).Text = '' then
        result := null;
  end;
end;

function Tdx.GridEditable(grid: TcxGridDBTableView): boolean;
begin
  result := false;

  if Assigned(grid) then
    result := grid.OptionsData.Editing;
end;

function Tdx.GetSkinActive: boolean;
begin
  result := dxSkinController.UseSkins;
end;

procedure Tdx.GetSkinNames(SkinList: TStrings);
begin
  if Assigned(SkinList) then
  begin
    SkinList.Clear;
    dxSkinsUserSkinPopulateSkinNames(SkinFileName, SkinList);
  end;
end;

function Tdx.GetSkinPainter: TcxCustomLookAndFeelPainter;
begin
  result := nil;

  if SkinActive then
  begin
    result := RootLookAndFeel.SkinPainter;
    //
    // if not Assigned(result) then
    // result := RootLookAndFeel.Painter;
  end;
end;

// Gli stili predefiniti (nativo e i quattro deprecati) non stanno nel file
// .skinres: InitSkinChooserGalleryItem li aggiunge alla galleria leggendoli dai
// painter registrati, e LoadSkin risale dal nome allo stile con la stessa
// enumerazione, senza nomi cablati.
const
  GruppoStiliPredefiniti = 'Stili predefiniti';
  StiliPredefiniti: TcxLookAndFeelStyles = [lfsNative, lfsStandard, lfsFlat, lfsUltraFlat, lfsOffice11];

function StileLookAndFeelDaNome(const NomeStile: string; out Stile: TcxLookAndFeelStyle): boolean;
var
  Painter: TcxCustomLookAndFeelPainter;
  Dettagli: TdxSkinDetails;
  i: Integer;
begin
  result := false;

  if NomeStile.IsEmpty then
    Exit;

  for i := 0 to cxLookAndFeelPaintersManager.Count - 1 do
  begin
    Painter := cxLookAndFeelPaintersManager[i];

    if not(Painter.LookAndFeelStyle in StiliPredefiniti) then
      Continue;

    if Painter.GetPainterDetails(Dettagli) and SameText(NomeStile, Dettagli.Name) then
    begin
      Stile := Painter.LookAndFeelStyle;
      Exit(true);
    end;
  end;
end;

procedure Tdx.LoadSkin(SkinName: string);
var
  StilePredefinito: TcxLookAndFeelStyle;
begin
  // RootLookAndFeel.RemoveChangeListener(Self);

  dxSkinController.BeginUpdate;
  try

    if FileExists(SkinFileName) and (not SkinName.isEmpty) and dxSkinsUserSkinLoadFromFile(SkinFileName, SkinName) then
    begin
      // Il file .skinres viene sempre caricato come skin 'UserSkin' (invariante
      // fissato nel costruttore): va riaffermato qui, perche' il ramo degli stili
      // predefiniti azzera SkinName e senza questo ripristino lo skin verrebbe
      // caricato ma non piu' applicato.
      dxSkinController.SkinName := 'UserSkin';
      dxSkinController.UseSkins := true;
      dxSkinController.NativeStyle := false;
      dxSkinController.SkinPaletteName := FSkinPaletteName;
    end
    else
      // Uno stile predefinito diverso dal nativo pretende NativeStyle a False,
      // SkinName vuoto e il Kind corrispondente: senza questo ramo finirebbe
      // sul nativo insieme a tutti gli altri casi di ricaduta.
      if StileLookAndFeelDaNome(SkinName, StilePredefinito) and (StilePredefinito <> lfsNative) then
      begin
        dxSkinController.UseSkins := false;
        dxSkinController.NativeStyle := false;
        dxSkinController.SkinName := '';

        case StilePredefinito of
          lfsStandard:
            dxSkinController.Kind := lfStandard;
          lfsFlat:
            dxSkinController.Kind := lfFlat;
          lfsUltraFlat:
            dxSkinController.Kind := lfUltraFlat;
          lfsOffice11:
            dxSkinController.Kind := lfOffice11;
        end;
      end
      else
      begin
        dxSkinController.NativeStyle := true;
        dxSkinController.UseSkins := false;
      end;
  finally
    dxSkinController.EndUpdate
  end;

  UpdateStyles;
  // dxSkinController.Refresh(nil);
end;

procedure Tdx.InitProperties(ControlType: TzCtrlType; Properties: TcxCustomEditProperties);
var
  cxButtonEditProperties: TcxButtonEditProperties;
  cxLookupComboBoxProperties: TcxLookupComboBoxProperties;
  cxExtLookupComboBoxProperties: TcxExtLookupComboBoxProperties;
  cxCheckBoxProperties: TcxCheckBoxProperties;
  cxColorComboBoxProperties: TcxColorComboBoxProperties;
  dxRatingControlProperties: TdxRatingControlProperties;
  cxCustomLabelProperties: TcxCustomLabelProperties;
  cxCustomHyperLinkEditProperties: TcxCustomHyperLinkEditProperties;
  cxDateEditProperties: TcxDateEditProperties;
  cxImageComboBoxProperties: TcxImageComboBoxProperties;
  cxImageProperties: TcxImageProperties;
  cxMaskEditProperties: TcxMaskEditProperties;
  cxTimeEditProperties: TcxTimeEditProperties;
  cxEditButton: TcxEditButton;
  cxCheckComboBoxProperties: TcxCheckComboBoxProperties;
  dxToggleSwitchProperties: TdxToggleSwitchProperties;
begin
  Assert(Assigned(Properties));

  case ControlType of
    ctDefault:
      ;

    ctEdit:
      ;

    ctSpin:
      ;

    ctDate:
      begin
        cxDateEditProperties := TcxDateEditProperties(Properties);
        cxDateEditProperties.DateButtons := cxDateEditProperties.DateButtons + [btnToday];
        cxDateEditProperties.Kind := ckDate;
        cxDateEditProperties.SaveTime := false;
        cxDateEditProperties.ShowTime := false;
        cxDateEditProperties.ShowToday := true;
      end;

    ctTime:
      begin
        cxTimeEditProperties := TcxTimeEditProperties(Properties);
        cxTimeEditProperties.TimeFormat := tfHourMin;
        cxTimeEditProperties.SpinButtons.Position := sbpHorzRight;
      end;

    ctDateTime:
      ;

    ctComboBox:
      ;

    ctPickList:
      begin
        cxImageComboBoxProperties := TcxImageComboBoxProperties(Properties);
        cxImageComboBoxProperties.Images := nil; // altrimenti sposta a dx il testo Base.ImageList16;
        cxImageComboBoxProperties.ImmediatePost := true;
      end;

    ctPickListImage:
      begin
        cxImageComboBoxProperties := TcxImageComboBoxProperties(Properties);
        cxImageComboBoxProperties.Images := Immagini;
        cxImageComboBoxProperties.ImmediatePost := true;
      end;

    ctRadioGroup:
      ;

    ctComboDlg:
      begin
        cxButtonEditProperties := TcxButtonEditProperties(Properties);
        cxButtonEditProperties.ClearKey := VK_DELETE;
        cxButtonEditProperties.Readonly := true;
      end;

    // ctLookup, ctLookupHyperLink: { TODO : ExtLookup }
    ctLookup: { TODO : ExtLookup }
      begin
        cxLookupComboBoxProperties := TcxLookupComboBoxProperties(Properties);
        cxLookupComboBoxProperties.DropDownAutoSize := true;
        cxLookupComboBoxProperties.DropDownSizeable := true;
        cxLookupComboBoxProperties.DropDownListStyle := lsEditList;
        cxLookupComboBoxProperties.DropDownRows := 10;
        cxLookupComboBoxProperties.DropDownSizeable := true;
        cxLookupComboBoxProperties.IncrementalFiltering := false;
        cxLookupComboBoxProperties.Revertable := true;

        // per gli interi e i float
        cxLookupComboBoxProperties.ValidChars := cxLookupComboBoxProperties.ValidChars + ['.', ','];

        if cxLookupComboBoxProperties.Buttons.Count = 1 then
        begin
          cxLookupComboBoxProperties.Buttons.Add.Kind := bkEllipsis;

          if ControlType = ctLookupHyperLink then { TODO : ExtLookup }
          begin
            cxEditButton := cxLookupComboBoxProperties.Buttons.Add;
            cxEditButton.Kind := bkGlyph;
            GetBitmap(cxEditButton.Glyph, Glyphs, 0);
          end;
        end;

        cxLookupComboBoxProperties.ImmediatePost := true;
        cxLookupComboBoxProperties.ListOptions.ColumnSorting := false;
        cxLookupComboBoxProperties.ListOptions.SyncMode := true;
        cxLookupComboBoxProperties.PostPopupValueOnTab := false; // Mail GD 05.12.2022

        // 10.11.2022: dopo l'aggiornamento non chiama più DataSet.Locate
        cxLookupComboBoxProperties.GridMode := false;
      end;

    ctLookupExt, ctLookupHyperLink: { TODO : ExtLookup }
      begin
        cxExtLookupComboBoxProperties := TcxExtLookupComboBoxProperties(Properties);
        cxExtLookupComboBoxProperties.DropDownAutoSize := true;
        cxExtLookupComboBoxProperties.DropDownSizeable := true;
        cxExtLookupComboBoxProperties.DropDownListStyle := lsEditList;
        cxExtLookupComboBoxProperties.DropDownRows := 10;
        cxExtLookupComboBoxProperties.DropDownSizeable := true;
        cxExtLookupComboBoxProperties.IncrementalFiltering := false;
        cxExtLookupComboBoxProperties.Revertable := true;
        cxExtLookupComboBoxProperties.ImmediatePost := true;
        cxExtLookupComboBoxProperties.PostPopupValueOnTab := false; // Mail GD 05.12.2022
        cxExtLookupComboBoxProperties.GridMode := true; // altrimenti carica tutto il datset
        cxExtLookupComboBoxProperties.ValidChars := cxExtLookupComboBoxProperties.ValidChars + ['.', ',']; // per gli interi e i float

        cxExtLookupComboBoxProperties.UseMouseWheel := false; // non funziona

        if cxExtLookupComboBoxProperties.Buttons.Count = 1 then
        begin
          cxExtLookupComboBoxProperties.Buttons.Add.Kind := bkEllipsis;

          if ControlType = ctLookupHyperLink then
          begin
            cxEditButton := cxExtLookupComboBoxProperties.Buttons.Add;
            cxEditButton.Kind := bkGlyph;
            GetBitmap(cxEditButton.Glyph, Glyphs, 0);
          end;
        end;
      end;

    ctCheckBox:
      begin
        cxCheckBoxProperties := TcxCheckBoxProperties(Properties);
        cxCheckBoxProperties.AllowGrayed := false;
        cxCheckBoxProperties.Caption := '';
        // cxCheckBoxProperties.TrasparentBorder := True;
      end;

    ctMemo:
      ;

    ctRTF:
      ;

    ctImage:
      begin
        cxImageProperties := TcxImageProperties(Properties);
        cxImageProperties.FitMode := ifmProportionalStretch;
        cxImageProperties.GraphicClassName := 'TdxSmartImage';
        cxImageProperties.PopupMenuLayout.MenuItems := [];
      end;

    ctHyperLink:
      begin
        cxCustomHyperLinkEditProperties := TcxCustomHyperLinkEditProperties(Properties);
        cxCustomHyperLinkEditProperties.UsePrefix := upNever;
        cxCustomHyperLinkEditProperties.SingleClick := true;
      end;

    ctProgressBar:
      begin
        Properties.OnEditValueChanged := ProgressBarEditValueChanged;
      end;

    ctRating:
      begin
        dxRatingControlProperties := TdxRatingControlProperties(Properties);
        dxRatingControlProperties.ItemCount := 10;
        dxRatingControlProperties.ImmediatePost := true;
      end;

    ctColorCombo:
      begin
        cxColorComboBoxProperties := TcxColorComboBoxProperties(Properties);

        cxColorComboBoxProperties.AllowSelectColor := true;
        cxColorComboBoxProperties.ColorComboStyle := cxccsComboList;
        cxColorComboBoxProperties.ColorDialogShowFull := true;
        cxColorComboBoxProperties.DropDownRows := 12;
        cxColorComboBoxProperties.DropDownSizeable := true;
        cxColorComboBoxProperties.NamingConvention := cxncX11;
        cxColorComboBoxProperties.PrepareList := cxplX11;
        cxColorComboBoxProperties.ShowDescriptions := false;
        cxColorComboBoxProperties.ColorValueFormat := cxcvInteger;
        cxColorComboBoxProperties.OnSelectCustomColor := ColorCombo_SelectCustomColor;
        cxColorComboBoxProperties.OnEditValueChanged := ColorCombo_EditValueChanged;
      end;

    ctCustomDlg:
      ;

    ctCheckComboBox:
      begin
        cxCheckComboBoxProperties := TcxCheckComboBoxProperties(Properties);

        cxCheckComboBoxProperties.ShowEmptyText := false;
        cxCheckComboBoxProperties.DropDownRows := 12;
        cxCheckComboBoxProperties.DropDownSizeable := true;
        cxCheckComboBoxProperties.EditValueFormat := cvfIndices;
        cxCheckComboBoxProperties.ImmediatePost := true;
        cxCheckComboBoxProperties.Delimiter := '; ';

        cxCheckComboBoxProperties.onEditValueToStates := cxDBCheckComboBoxPropertiesEditValueToStates;
        cxCheckComboBoxProperties.onStatesToEditValue := cxDBCheckComboBoxPropertiesStatesToEditValue;
      end;

    ctToggleSwitch:
      begin
        dxToggleSwitchProperties := TdxToggleSwitchProperties(Properties);
        dxToggleSwitchProperties.Caption := '';
        dxToggleSwitchProperties.StateIndicator.Kind := sikText;
        dxToggleSwitchProperties.StateIndicator.OffText := 'No';
        dxToggleSwitchProperties.StateIndicator.OnText := 'Si';
        dxToggleSwitchProperties.StateIndicator.Position := sipInside;
      end;

    ctDateTimeWheelPicker:
      ;
    ctTokenEdit:
      ;
    ctFormattedLabel:
      ;
    ctCheckGroupBox:
      ;
    ctButtonEdit:
      ;
    ctMaskEdit:
      ;
    ctCheckGroup:
      ;
    ctShellComboBox:
      ;
  end;
  /// /////////////////////////////////////////////////////////////////
end;

procedure Tdx.InitProperties(ControlType: TzCtrlType; Properties: TcxCustomEditProperties; Domain: TzDomain; Field: TField);
var
  cxCustomTextEditProperties: TcxCustomTextEditProperties;
  cxSpinEditProperties: TcxSpinEditProperties;
  cxCheckBoxProperties: TcxCheckBoxProperties;
  CheckBoxIsString: boolean;
begin
  InitProperties(ControlType, Properties);

  if (Properties is TcxCustomTextEditProperties) then
  begin
    cxCustomTextEditProperties := TcxCustomTextEditProperties(Properties);
    cxCustomTextEditProperties.Alignment.Horz := Domain.Alignment; // aggiungere il vert
    cxCustomTextEditProperties.CharCase := Domain.CharCase;
    // e-mail sempre in minuscolo: vince sull'ecUpperCase del dizionario (WT/LZ/TzDomains.dfm)
    if Domain.SanificaEmail then
      cxCustomTextEditProperties.CharCase := ecLowerCase;
    cxCustomTextEditProperties.DisplayFormat := Domain.DisplayFormat;
    cxCustomTextEditProperties.EditFormat := Domain.EditFormat;

    if not Domain.PasswordChar.isEmpty then
      if Domain.PasswordChar <> #0 then
      begin
        cxCustomTextEditProperties.PasswordChar := Domain.PasswordChar.Chars[0];
        cxCustomTextEditProperties.ShowPasswordRevealButton := true;
        cxCustomTextEditProperties.EchoMode := eemPassword;
      end;

    cxCustomTextEditProperties.Readonly := Domain.Readonly;
  end;

  if (Properties is TcxSpinEditProperties) then
  begin
    cxSpinEditProperties := TcxSpinEditProperties(Properties);
    cxSpinEditProperties.MinValue := Domain.MinValue;
    cxSpinEditProperties.MaxValue := Domain.MaxValue;
  end;

  if (Properties is TcxCheckBoxProperties) then
  begin
    cxCheckBoxProperties := TcxCheckBoxProperties(Properties);
    cxCheckBoxProperties.Caption := '';
    // cxCheckBoxProperties.TrasparentBorder := True;

    if Assigned(Field) then
      CheckBoxIsString := Field is TStringField
    else
      CheckBoxIsString := Domain.Domain = 'SI_NO';

    if CheckBoxIsString then
    begin
      cxCheckBoxProperties.ValueChecked := 'S';
      cxCheckBoxProperties.ValueUnchecked := 'N';
    end
    else
    begin
      cxCheckBoxProperties.ValueChecked := true;
      cxCheckBoxProperties.ValueUnchecked := false;
    end;
  end;

  // property EditMask: string read FEditMask write SetEditMask;
  // property ReadOnly: boolean read FReadOnly write SetReadOnly default False;
  // property Required: boolean read FRequired write SetRequired default False;
  // COLORE
  // property Size: integer read FSize write SetSize default 0;

  if not Domain.PickList.isEmpty then
    if Assigned(Domain.PickList_Obj) then
      AssignPickList(Properties, Domain.PickList_Obj);
end;

procedure Tdx.SetEditability(Properties: TcxCustomEditProperties; const Editability: TEditability);
var
  RequiredIcon: TdxSmartImage;
begin
  Assert(Assigned(Properties));

  Properties.ValidateOnEnter := true;
  Properties.ValidationErrorIconAlignment := taRightJustify;
  // Properties.ValidationErrorIconAlignment := taLeftJustify;
  Properties.ValidationOptions := [evoShowErrorIcon, evoAllowLoseFocus];

  if Editability = edRequired then
  begin

    RequiredIcon := TdxSmartImage.Create;
    try
      RequiredImages.GetImage(0, RequiredIcon);
      Properties.ErrorIcon := RequiredIcon;
    finally
      FreeAndNil(RequiredIcon);
    end;

    Properties.OnValidate := ValidateRequired
  end
  else
    Properties.OnValidate := ValidateNormal;

  Properties.Readonly := Editability = edReadOnly;

  // mantis 958: si mangia il return
  if Properties is TcxRichEditProperties then
    Properties.ValidateOnEnter := false;
end;

procedure Tdx.SetEditability(Column: TcxGridDBColumn; const Editability: TEditability);
begin
  Assert(Assigned(Column));
  SetEditability(Column.Properties, Editability);
end;

procedure Tdx.SetEditability(cxCustomEdit: TcxCustomEdit; const Editability: TEditability; const doValidate: boolean = true);
var
  styleController: TcxEditStyleController;
begin
  Assert(Assigned(cxCustomEdit));
  SetEditability(cxCustomEdit.ActiveProperties, Editability);

  //
  // if Editability = edRequired then
  if doValidate then // ZZ 07.06.2019 se la card � in stato di browse non metterla in editing
    cxCustomEdit.ValidateEdit(false); // vedere se occorre temporizzare o altro
  // else
  // cxCustomEdit.ViewInfo.ErrorData.ErrorType := eetNone;

  cxCustomEdit.TabStop := Editability <> edReadOnly;

  // colore
  styleController := dx.GetStyleController(Editability);
  if cxCustomEdit.Style.styleController <> styleController then
    cxCustomEdit.Style.styleController := styleController;
end;

procedure Tdx.SetSkinName(const Value: string);
begin
  FSkinName := Value;
  LoadSkin(SkinName);
end;

procedure Tdx.SetValue(cxCustomEdit: TcxCustomEdit; Value: Variant);
begin

  if Assigned(cxCustomEdit) then
  begin
    if VarIsNull(Value) or VarIsEmpty(Value) then
      cxCustomEdit.Clear
    else
      cxCustomEdit.EditValue := Value;
  end
end;

procedure Tdx.InitLookup(IdLookup: string; cxLookupComboBox: TcxCustomLookupComboBox; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, ListFields: string; const HyperLink: boolean = false);
var
  DataField: string;
begin
  Assert(Assigned(cxLookupComboBox));

  DataField := '';

  if cxLookupComboBox is TcxDBLookupComboBox then
    DataField := TcxDBLookupComboBox(cxLookupComboBox).DataBinding.DataField;

  InitLookup(IdLookup, cxLookupComboBox.Properties, DataField, DataSet, DataSource, KeyField, ListFields, HyperLink);
end;

procedure Tdx.InitLookup(IdLookup: string; cxLookupComboBoxProperties: TcxLookupComboBoxProperties; DataField: string; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, ListFields: string; const HyperLink: boolean = false);
var
  FieldName: string;
  zLookup: TzLookup;
begin
  Assert(Assigned(cxLookupComboBoxProperties));
  Assert(Assigned(DataSet));
  Assert(Assigned(DataSource));

  zLookup := Base.GetLookup(IdLookup, DataSet, KeyField, ListFields);

  if HyperLink then
    InitProperties(ctLookupHyperLink, cxLookupComboBoxProperties) { TODO : ExtLookup }
  else
    InitProperties(ctLookup, cxLookupComboBoxProperties);

  if zLookup.OnlyFromLookup then
  begin
    cxLookupComboBoxProperties.DropDownListStyle := lsEditFixedList;
    cxLookupComboBoxProperties.ClearKey := VK_DELETE;
  end
  else
  begin
    cxLookupComboBoxProperties.DropDownListStyle := lsEditList;
    cxLookupComboBoxProperties.ClearKey := 0;
  end;

  cxLookupComboBoxProperties.OnButtonClick := LookupComboButtonClick;

  /// //////////////////////////////////////////////////////////
  cxLookupComboBoxProperties.KeyFieldNames := zLookup.GetKeyFieldForCombo(DataField);
  cxLookupComboBoxProperties.ListSource := DataSource;

  InitLookupColumns(zLookup.Name, cxLookupComboBoxProperties, DataSet);
end;

procedure Tdx.InitLookup(IdLookup: string; cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, DisplayColumns: string; cxGridViewRepository: TcxGridViewRepository = nil;
const HyperLink: boolean = false; const AddClearButton: boolean = false);
var
  DataField: string;
begin
  Assert(Assigned(cxCustomExtLookupComboBox));

  DataField := '';

  if cxCustomExtLookupComboBox is TcxDBExtLookupComboBox then
    DataField := TcxDBExtLookupComboBox(cxCustomExtLookupComboBox).DataBinding.DataField;

  InitLookup(IdLookup, cxCustomExtLookupComboBox.Properties, DataField, DataSet, DataSource, KeyField, DisplayColumns, cxGridViewRepository, HyperLink, AddClearButton);
end;

procedure Tdx.InitLookup(IdLookup: string; cxExtLookupComboBoxProperties: TcxExtLookupComboBoxProperties; DataField: string; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, DisplayColumns: string;
aGridViewRepository: TcxGridViewRepository = nil; const HyperLink: boolean = false; const AddClearButton: boolean = false);

  function GetListFieldItem(): TcxCustomGridTableItem;
  var
    I: integer;
    FieldName: string;
  begin
    result := nil;

    // Prima si prova per il la prima colonna della tendina
    if cxExtLookupComboBoxProperties.ListFieldNames.Contains(';') then
      FieldName := cxExtLookupComboBoxProperties.ListFieldNames.Substring(0, cxExtLookupComboBoxProperties.ListFieldNames.IndexOf(';'))
    else
      FieldName := cxExtLookupComboBoxProperties.ListFieldNames;

    for I := 0 to cxExtLookupComboBoxProperties.View.VisibleItemCount - 1 do
    begin
      if cxExtLookupComboBoxProperties.View.VisibleItems[I] is TcxGridDBColumn then
        if SameText(TcxGridDBColumn(cxExtLookupComboBoxProperties.View.VisibleItems[I]).DataBinding.FieldName, FieldName) then
        begin
          result := TcxGridDBColumn(cxExtLookupComboBoxProperties.View.VisibleItems[I]);
          Exit;
        end;
    end;

    if result = nil then
    begin
      FieldName := cxExtLookupComboBoxProperties.KeyFieldNames;

      for I := 0 to cxExtLookupComboBoxProperties.View.VisibleItemCount - 1 do
      begin
        if cxExtLookupComboBoxProperties.View.VisibleItems[I] is TcxGridDBColumn then
          if SameText(TcxGridDBColumn(cxExtLookupComboBoxProperties.View.VisibleItems[I]).DataBinding.FieldName, FieldName) then
          begin
            result := TcxGridDBColumn(cxExtLookupComboBoxProperties.View.VisibleItems[I]);
            Exit;
          end;
      end;
    end;

    if result = nil then
      if cxExtLookupComboBoxProperties.View.VisibleItemCount > 0 then
        cxExtLookupComboBoxProperties.ListFieldItem := cxExtLookupComboBoxProperties.View.VisibleItems[0];
  end;

var
  ListFieldNames: string;
  zLookup: TzLookup;
begin
  Assert(Assigned(cxExtLookupComboBoxProperties));
  Assert(Assigned(DataSet));
  Assert(Assigned(DataSource));

  cxExtLookupComboBoxProperties.BeginUpdate;
  try
    zLookup := Base.GetLookup(IdLookup, DataSet, KeyField, DisplayColumns);

    // AddClearButton da gestire. Per definire il tipo di bottone usare Tag

    if HyperLink then
      InitProperties(ctLookupHyperLink, cxExtLookupComboBoxProperties)
    else
      InitProperties(ctLookupExt, cxExtLookupComboBoxProperties);

    if zLookup.OnlyFromLookup then
    begin
      cxExtLookupComboBoxProperties.DropDownListStyle := lsEditFixedList;
      cxExtLookupComboBoxProperties.ClearKey := VK_DELETE;
    end
    else
    begin
      cxExtLookupComboBoxProperties.DropDownListStyle := lsEditList;
      cxExtLookupComboBoxProperties.ClearKey := 0;
    end;

    cxExtLookupComboBoxProperties.DropDownAutoSize := false;
    cxExtLookupComboBoxProperties.OnButtonClick := LookupComboButtonClick;
    cxExtLookupComboBoxProperties.OnPopup := LookupInitPopup;
    cxExtLookupComboBoxProperties.OnCloseUp := LookupCloseUp;

    /// //////////////////////////////////////////////
    if Assigned(cxExtLookupComboBoxProperties.View) then
    begin
      cxExtLookupComboBoxProperties.View.Free;
      cxExtLookupComboBoxProperties.View := nil;
    end;

    if Assigned(aGridViewRepository) then
      cxExtLookupComboBoxProperties.View := CreateGridDBTableView(aGridViewRepository, DataSource, zLookup.FieldNamesFK)
    else
      cxExtLookupComboBoxProperties.View := CreateGridDBTableView(self.cxGridViewRepository, DataSource, zLookup.FieldNamesFK);

    cxExtLookupComboBoxProperties.View.ClearItems;
    TcxGridDBTableView(cxExtLookupComboBoxProperties.View).DataController.CreateAllItems;

    // assegnare dopo la creazione delle colonne della view
    cxExtLookupComboBoxProperties.KeyFieldNames := zLookup.GetKeyFieldForCombo(DataField);
    cxExtLookupComboBoxProperties.ListFieldNames := zLookup.GetListFieldNamesForCombo(DataField);

    dx.InitLookupColumns(zLookup.Name, cxExtLookupComboBoxProperties, DataSet);

    cxExtLookupComboBoxProperties.ListFieldItem := GetListFieldItem;
  finally
    cxExtLookupComboBoxProperties.EndUpdate;
  end;
end;

function Tdx.CreateGridDBTableView(cxGridViewRepository: TcxGridViewRepository; DataSource: TDataSource; KeyFieldNames: string): TcxGridDBTableView;
begin
  result := cxGridViewRepository.CreateItem(TcxGridDBTableView) as TcxGridDBTableView;
  result.Tag := NativeInt(TLookupViewProps.Create(result)); // verr� distrutto dal OnDestroy della view
  result.DataController.DataModeController.GridMode := true; //
  // Mantis #303 - 2026-10-30: con GridModeBufferCount a 0 la griglia caricava solo i record visibili
  // nel popup; quando il mouse arrivava sull'ultimo, la finestra scorreva di un record perche' la
  // griglia non sa che non ce ne sono altri, e la tendina con 2 corsi ne mostrava uno solo. Con un
  // blocco fisso di 100 i lookup piccoli stanno tutti in memoria, quelli grandi restano a blocchi
  result.DataController.DataModeController.GridModeBufferCount := 100;
  result.DataController.DataSource := DataSource;
  result.DataController.KeyFieldNames := KeyFieldNames;
  result.OptionsView.GroupByBox := false;
  result.OptionsView.ColumnAutoWidth := false; // altrimenti non funziona  ApplyBestFit();
  result.OptionsSelection.CellSelect := false;
  result.OnCanFocusRecord := LookupGridViewCanFocusRecord;
  result.OnCellClick := LookupGridViewCellClick;

  // se scrollano dopo aver fatto click sull'elenco cambia record corrente
  // del dataset prima che arrivi all'onEditValueChanged
  // result.OnSelectionChanged := LookupGridViewSelectionChanged;
  // result.OnCanSelectRecord := LookupGridViewCanSelectRecord;
end;

procedure Tdx.InitLookupColumns(const IdLookup: string; ExtLookupComboBoxProperties: TcxExtLookupComboBoxProperties; DataSet: TzFbDataSet);
var
  I: integer;
  zDbViewProps: TzDbViewProps;
  cxGridDBTableView: TcxGridDBTableView;
  ListFieldNames: string;
  zLookup: TzLookup;
begin
  Assert(Assigned(ExtLookupComboBoxProperties));

  cxGridDBTableView := ExtLookupComboBoxProperties.View as TcxGridDBTableView;

  if not Assigned(cxGridDBTableView) then
    Exit;

  for I := 0 to cxGridDBTableView.ColumnCount - 1 do
    cxGridDBTableView.Columns[I].Caption := CapFirst(cxGridDBTableView.Columns[I].Caption);

  if Base <> nil then //
  begin
    zLookup := Base.zLookups.Get(IdLookup, false);

    if Assigned(zLookup) then
    begin
      zDbViewProps := TzDbViewProps.Create(nil);
      try
        zDbViewProps.Name := zLookup.DbView;

        if zDbViewProps.LoadFromBase then
          ListFieldNames := zDbViewProps.Columns.ComboColumns(DataSet, 10)
        else
          ListFieldNames := zLookup.DisplayColumns;

        // else lascia quello impostato nel lookup
        if not ListFieldNames.isEmpty then
          ExtLookupComboBoxProperties.ListFieldNames := ListFieldNames;

        zDbViewProps.Columns.AssignToGridColumns(DataSet.IdDataSet, cxGridDBTableView, IdLookup);

        // Mantis #303 - 2026-10-30: le larghezze salvate nella vista del lookup (F2, Salva impostazioni)
        // venivano scritte qui ma poi LookupApplyBestFit, a ogni apertura della tendina, le ricalcolava sul
        // contenuto: una descrizione lunga allargava la colonna oltre lo schermo e la larghezza scelta
        // dall'utente non contava. Ora la larghezza salvata e' il tetto del ricalcolo (BestFitMaxWidth);
        // le colonne senza larghezza salvata (-1) restano libere
        for var Item in zDbViewProps.Columns do
        begin
          var
            Colonna: TcxGridDBColumn := cxGridDBTableView.GetColumnByFieldName(Item.Name) as TcxGridDBColumn;

          if not Assigned(Colonna) then
            Continue;

          if Item.Width > 0 then
            Colonna.BestFitMaxWidth := Item.Width
          else
            Colonna.BestFitMaxWidth := 0;
        end;
      finally
        FreeAndNil(zDbViewProps);
      end;
    end;
  end;

  // //////////////////////////////////////////////////////////
  // //////////////////////////////////////////////////////////
  // //////////////////////////////////////////////////////////

  // GetColumnByFieldName
  // if ExtLookupComboBoxProperties.View.VisibleItemCount > 0 then
  // ExtLookupComboBoxProperties.ListFieldItem := ExtLookupComboBoxProperties.View.VisibleItems[0];
end;

procedure Tdx.LookupComboButtonClick(Sender: TObject; AButtonIndex: integer);
var
  comboDataSet: TzFbDataSet;
  comboDataSource: TDataSource;
  FieldName: string;
  KeyFieldNames: string;
  ListFieldNames: string;

  DataSet: TzFbDataSet;
  result: boolean;
  zDbViewDlg: TzDbViewDlg;
  Value: Variant;

  function GetParams(Sender: TObject; out FieldName: string; out DataSet: TzFbDataSet; out DataSource: TDataSource; out KeyFieldNames: string; out ListFieldNames: string): boolean;
  var
    cxLookupComboBoxProperties: TcxLookupComboBoxProperties;
    cxExtLookupComboBoxProperties: TcxExtLookupComboBoxProperties;
  begin
    result := false;
    DataSet := nil;
    DataSource := nil;
    KeyFieldNames := '';
    ListFieldNames := '';

    if (Sender is TcxCustomLookupComboBox) then
    begin
      FieldName := '';

      if Sender is TcxDBLookupComboBox then
        FieldName := TcxDBLookupComboBox(Sender).DataBinding.DataField;

      cxLookupComboBoxProperties := TcxCustomLookupComboBox(Sender).ActiveProperties;
      DataSource := cxLookupComboBoxProperties.ListSource;
      KeyFieldNames := cxLookupComboBoxProperties.KeyFieldNames;
      ListFieldNames := cxLookupComboBoxProperties.ListFieldNames;
    end
    else
      if (Sender is TcxCustomExtLookupComboBox) then
      begin
        FieldName := '';

        if Sender is TcxDBExtLookupComboBox then
          FieldName := TcxDBExtLookupComboBox(Sender).DataBinding.DataField;

        cxExtLookupComboBoxProperties := TcxCustomExtLookupComboBox(Sender).ActiveProperties;

        if Assigned(cxExtLookupComboBoxProperties.View) then
          DataSource := TcxGridDBTableView(cxExtLookupComboBoxProperties.View).DataController.DataSource;

        KeyFieldNames := cxExtLookupComboBoxProperties.KeyFieldNames;
        ListFieldNames := cxExtLookupComboBoxProperties.ListFieldNames;
      end;

    if not Assigned(DataSource) then
      Exit;

    if DataSource.DataSet is TzFbDataSet then
      DataSet := TzFbDataSet(DataSource.DataSet);

    result := Assigned(DataSet); // il resto di conseguenza
  end;

  procedure SetValue(Sender: TObject; Value: Variant; FieldName: string; DataSet: TzFbDataSet; DataSource: TDataSource; const KeyField, ListFields: string); overload;
  var
    cxLookupComboBox: TcxCustomLookupComboBox;
    cxExtLookupComboBox: TcxCustomExtLookupComboBox;
    cxGridViewRepository: TcxGridViewRepository;
    HyperLink: boolean;
  begin
    if (Sender is TcxCustomLookupComboBox) then
    begin
      cxLookupComboBox := TcxCustomLookupComboBox(Sender);
      HyperLink := cxLookupComboBox.ActiveProperties.Buttons.Count > 2;
      InitLookup('', cxLookupComboBox, DataSet, DataSource, KeyFieldNames, ListFieldNames, HyperLink);
      cxLookupComboBox.EditValue := Value;
      cxLookupComboBox.PostEditValue;
    end
    else
      if (Sender is TcxCustomExtLookupComboBox) then
      begin
        cxExtLookupComboBox := TcxCustomExtLookupComboBox(Sender);
        HyperLink := cxExtLookupComboBox.ActiveProperties.Buttons.Count > 2;

        if Assigned(cxExtLookupComboBox.ActiveProperties.View) then
          if cxExtLookupComboBox.ActiveProperties.View.Repository is TcxGridViewRepository then
          begin
            cxGridViewRepository := cxExtLookupComboBox.ActiveProperties.View.Repository as TcxGridViewRepository;
            InitLookup('', cxExtLookupComboBox, DataSet, DataSource, KeyFieldNames, ListFieldNames, cxGridViewRepository, HyperLink);
          end;

        cxExtLookupComboBox.EditValue := Value;
        cxExtLookupComboBox.PostEditValue;
      end;
  end;

  function CloneDataSet(comboDataSet: TzFbDataSet): TzFbDataSet;
  begin
    result := CreateFbDataSet(nil, Base.zFbDatabase, comboDataSet.Transaction, comboDataSet.UpdateTransaction);
    result.Name := ValidateComponentName('LK_' + comboDataSet.Name);
    result.IdDataSet := comboDataSet.IdDataSet;
    result.AutoCommit := true;
    Base.DataSetLoadProps(result);

    // qualora il zDataSetItem non fosse stato ancora salvato sull'lz
    // Nota: dar� problemi se riaperto con un valore poich� il defaultSql non � settato
    if result.SelectSQL.Text.isEmpty then
      result.SelectSQL.Text := comboDataSet.SelectSQL.Text;

    result.UseSqlLocate := true;
    // il campo di scelta non deve ritrovarsi il primo record dell'elenco se non c'e' corrispondenza
    result.MantieniElencoSeNonTrova := true;
    result.CopyParams(comboDataSet);
  end;

begin

  if AButtonIndex = 0 then
  begin

    if (Sender is TcxCustomExtLookupComboBox) then
      if not TcxCustomExtLookupComboBox(Sender).DroppedDown then
        TcxCustomExtLookupComboBox(Sender).DroppedDown := true;
  end
  else
    if AButtonIndex = 1 then // else per hyperLink?
    begin

      if not GetParams(Sender, FieldName, comboDataSet, comboDataSource, KeyFieldNames, ListFieldNames) then
        Exit;

      DataSet := CloneDataSet(comboDataSet);
      try
        DataSet.DataSource := comboDataSet.DataSource;
        DataSet.BeforeOpen := comboDataSet.BeforeOpen;
        DataSet.OnNewRecord := comboDataSet.OnNewRecord;

        if not DataSet.SelectSQL.Text.isEmpty then
          DataSet.Active := true;

        /// /////////////////////////////////////////////
        zDbViewDlg := TzDbViewDlg.Create(nil);
        try
          zDbViewDlg.Name := 'zDbViewDlg';
          zDbViewDlg.zSystem := Base;
          zDbViewDlg.DataSet := DataSet;
          zDbViewDlg.IdLookup := comboDataSet.IdDataSet;
          result := zDbViewDlg.Execute;
        finally
          FreeAndNil(zDbViewDlg);
        end;

        // Mantis #303 - 2026-10-30: la vista della tendina si costruiva solo in InitLookup, e le colonne
        // sistemate nella finestra (ordine, visibilita', larghezze salvate) entravano solo riaprendo la
        // form. Ora si rileggono subito, anche se la finestra si chiude con Annulla
        if Sender is TcxCustomExtLookupComboBox then
          InitLookupColumns(comboDataSet.IdDataSet, TcxCustomExtLookupComboBox(Sender).ActiveProperties, comboDataSet);

        if result then
        begin
          Value := DataSet.FieldByName(KeyFieldNames).Value; // combo.ActiveProperties.DataController.GetKeyFieldsValues;
          SetValue(Sender, Value, FieldName, comboDataSet, comboDataSource, KeyFieldNames, ListFieldNames);
        end;

        DataSet.Active := false;
      finally
        FreeAndNil(DataSet);
      end;
    end;
  /// /////////////////////////////////////////////
end;

procedure Tdx.InitSkinChooserGalleryItem(dxSkinChooserGalleryItem: TdxSkinChooserGalleryItem);
var
  Painter: TcxCustomLookAndFeelPainter;
  Dettagli: TdxSkinDetails;
  Voce: TdxSkinChooserGalleryGroupItem;
  i: Integer;
begin
  if FileExists(SkinFileName) then
  begin
    dxSkinChooserGalleryItem.Visible := ivAlways;
    dxSkinChooserGalleryItem.GalleryGroups.Clear;
    dxSkinChooserGalleryItem.AddSkinsFromFile(SkinFileName);

    // Popolando la galleria a mano, DevExpress non esegue il proprio
    // popolamento automatico e VisibleLookAndFeelStyles resta senza effetto:
    // il gruppo degli stili predefiniti va costruito qui. Nome, didascalia e
    // icone arrivano dai painter registrati, la stessa fonte che DevExpress usa
    // in InternalPopulateSkinsGallery: AddSkin(nome, gruppo) da sola imposta
    // solo SkinName e lascia la voce senza testo e senza icona.
    for i := 0 to cxLookAndFeelPaintersManager.Count - 1 do
    begin
      Painter := cxLookAndFeelPaintersManager[i];

      if not(Painter.LookAndFeelStyle in StiliPredefiniti) then
        Continue;

      if Painter.IsInternalPainter then
        Continue;

      if not Painter.GetPainterDetails(Dettagli) then
        Continue;

      Voce := dxSkinChooserGalleryItem.AddSkin(Dettagli.Name, GruppoStiliPredefiniti);
      Voce.LookAndFeelStyle := Painter.LookAndFeelStyle;
      Voce.Caption := Dettagli.DisplayName;
      Voce.Glyph.Assign(Dettagli.Icons[dxSkinChooserGalleryItem.SkinIconSize]);
      Voce.GlyphInDropDown.Assign(Dettagli.Icons[dxSkinChooserGalleryItem.SkinIconSizeInDropDown]);
    end;
  end
  else
    dxSkinChooserGalleryItem.Visible := ivNever;
end;

procedure Tdx.InitSplitter(cxSplitter: TcxSplitter);
begin
  Assert(Assigned(cxSplitter));

  // cxSplitter.HotZoneStyleClass := TcxMediaPlayer8Style;
  cxSplitter.HotZoneStyleClass := TcxMediaPlayer9Style;
  case cxSplitter.AlignSplitter of
    salTop, salBottom:
      cxSplitter.Height := 7;
    salLeft, salRight:
      cxSplitter.Width := 7;
  end;
end;

function Tdx.GetColor(ColorKind: TColorKind): TColor;
var
  Painter: TcxCustomLookAndFeelPainter;
begin
  result := TColors.SysNone;

  Painter := GetSkinPainter;

  if Assigned(Painter) then
  begin
    case ColorKind of
      ckControl:
        result := Painter.DefaultControlColor;
      ckContent:
        result := Painter.DefaultContentColor;
      ckTitle:
        result := Painter.DefaultControlColor;
      ckEditorNormal:
        result := Painter.DefaultEditorBackgroundColorEx(esckNormal);
      ckEditorRequired:
        result := Painter.DefaultEditorBackgroundColorEx(esckNormal);
      ckEditorReadOnly:
        result := Painter.DefaultEditorBackgroundColorEx(esckReadOnly);
      ckEditorDisabled:
        result := Painter.DefaultEditorBackgroundColorEx(esckDisabled);
      ckLabel:
        result := Painter.DefaultControlColor;
      ckSeparator:
        result := Painter.DefaultHeaderBackgroundColor;
      ckWizard:
        result := Painter.DefaultControlColor;
      ckWizardTitle:
        result := Painter.DefaultHeaderColor;
      ckWizardWaterMark:
        result := Painter.DefaultHeaderColor;
      ckGridContent:
        result := Painter.DefaultContentColor;
      ckGridContentEven:
        result := Painter.DefaultContentEvenColor;
      ckGridContentOdd:
        result := Painter.DefaultContentOddColor;
      ckGridFooter:
        result := Painter.DefaultFooterColor;
      ckFilterBox:
        result := Painter.DefaultControlColor;
      ckTreeView:
        result := Painter.DefaultControlColor;
      ckInspector:
        result := Painter.DefaultControlColor;
      ckInspectorValues:
        result := Painter.DefaultControlColor;
      ckBtnFace:
        result := Painter.DefaultControlColor;
    end;
  end
  else
  begin
    case ColorKind of
      ckControl:
        result := TColors.SysBtnFace;
      ckContent:
        result := TColors.SysInfoBk;
      ckTitle:
        result := TColors.SysInfoBk;
      ckEditorNormal:
        result := TColors.MoneyGreen;
      ckEditorRequired:
        result := 10930928; // clCream;
      ckEditorReadOnly:
        result := TColors.SysInfoBk;
      ckEditorDisabled:
        result := TColors.SysBtnFace;
      ckLabel:
        result := TColors.SysBtnFace;
      ckSeparator:
        result := TColors.SysBtnShadow;
      ckWizard:
        result := TColors.SysBtnFace;
      ckWizardTitle:
        result := TColors.SysWindow;
      ckWizardWaterMark:
        result := clActiveCaption;
      ckGridContent:
        result := TColors.MoneyGreen;
      ckGridContentEven:
        result := $00DDECDD;
      ckGridContentOdd:
        result := TColors.MoneyGreen;
      ckGridFooter:
        result := clBtnFace;
      ckFilterBox:
        result := clBtnShadow;
      ckTreeView:
        result := TColors.MoneyGreen;
      ckInspector:
        result := clBtnFace;
      ckInspectorValues:
        result := clBtnFace;
      ckBtnFace:
        result := clBtnFace;
    end;
  end;
end;

function Tdx.GetFontColor(ColorKind: TColorKind): TColor;
var
  Painter: TcxCustomLookAndFeelPainter;
begin
  result := TColors.Black;

  Painter := GetSkinPainter;

  if Assigned(Painter) then
  begin

    case ColorKind of
      ckControl:
        result := Painter.DefaultControlTextColor;
      ckContent:
        result := Painter.DefaultContentTextColor;
      ckTitle:
        result := Painter.DefaultControlTextColor;
      ckEditorNormal:
        result := Painter.DefaultEditorTextColorEx(esckNormal);
      ckEditorRequired:
        result := Painter.DefaultEditorTextColorEx(esckNormal);
      ckEditorReadOnly:
        result := Painter.DefaultEditorTextColorEx(esckReadOnly);
      ckEditorDisabled:
        result := Painter.DefaultEditorTextColorEx(esckDisabled);
      ckLabel:
        result := Painter.DefaultControlTextColor;
      ckSeparator:
        result := Painter.DefaultHeaderBackgroundTextColor;
      ckWizard:
        result := Painter.DefaultControlTextColor;
      ckWizardTitle:
        result := Painter.DefaultControlTextColor;
      ckWizardWaterMark:
        result := Painter.DefaultControlTextColor;
      ckGridContent:
        result := Painter.DefaultContentTextColor;
      ckGridContentEven:
        result := Painter.DefaultContentTextColor;
      ckGridContentOdd:
        result := Painter.DefaultContentTextColor;
      ckGridFooter:
        result := Painter.DefaultFooterTextColor;
      ckFilterBox:
        result := Painter.DefaultControlTextColor;
      ckTreeView:
        result := Painter.DefaultControlTextColor;
      ckInspector:
        result := Painter.DefaultControlTextColor;
      ckInspectorValues:
        result := Painter.DefaultControlTextColor;
      ckBtnFace:
        result := Painter.DefaultControlTextColor;
    end;
  end
  else
  begin
    case ColorKind of
      ckControl:
        result := TColors.Black;
      ckContent:
        result := TColors.Black;
      ckTitle:
        result := TColors.Black;
      ckEditorNormal:
        result := TColors.Black;
      ckEditorRequired:
        result := TColors.Black;
      ckEditorReadOnly:
        result := TColors.Black;
      ckEditorDisabled:
        result := TColors.SysGrayText;
      ckLabel:
        result := TColors.Black;
      ckSeparator:
        result := TColors.SysBtnHighlight;
      ckWizard:
        result := TColors.Black;
      ckWizardTitle:
        result := TColors.Black;
      ckWizardWaterMark:
        result := TColors.Black;
      ckGridContent:
        result := TColors.Black;
      ckGridContentEven:
        result := TColors.Black;
      ckGridContentOdd:
        result := TColors.Black;
      ckGridFooter:
        result := TColors.Black;
      ckFilterBox:
        result := TColors.Black;
      ckTreeView:
        result := TColors.Black;
      ckInspector:
        result := TColors.Black;
      ckInspectorValues:
        result := TColors.Navy;
      ckBtnFace:
        result := TColors.Black;
    end;
  end;
end;

function Tdx.GetColor(StyleColor: TStyleColor): TColor;
var
  Painter: TcxCustomLookAndFeelPainter;
begin
  result := TColors.Black;

  Painter := GetSkinPainter;

  if Assigned(Painter) then
  begin
    case StyleColor of
      scBtnFace:
        result := Painter.DefaultControlColor;
      scMoneyGreen:
        result := Painter.DefaultContentColor;
      scMoneyGreenLight:
        result := Painter.DefaultContentEvenColor;
      scCream:
        result := Painter.DefaultContentOddColor;
      scInfoBk:
        result := Painter.DefaultInactiveColor;
      scSkyBlue:
        result := Painter.DefaultSelectionColor;
      scSkyBlueLight:
        result := Painter.DefaultHeaderBackgroundColor;
      scHeader:
        result := Painter.DefaultHeaderColor;
      scHeaderBackground:
        result := Painter.DefaultHeaderBackgroundColor;
      scHighlight:
        result := Painter.DefaultSelectionColor;
    end;
  end
  else
  begin
    case StyleColor of
      scBtnFace:
        result := clBtnFace;
      scMoneyGreen:
        result := TColors.MoneyGreen;
      scMoneyGreenLight:
        // result := $00DDECDD;
        result := $00E7F1E7;
      scCream:
        result := 10930928; // TColors.Cream;
      scInfoBk:
        result := TColors.SysInfoBk;
      scSkyBlue:
        result := TColors.Skyblue;
      scSkyBlueLight:
        result := $00FAF1E4;
      scHeader:
        result := clBtnFace;
      scHeaderBackground:
        result := clBtnShadow;
      scHighlight:
        result := clHighlight;
    end;
  end;
end;

function Tdx.GetFontColor(StyleColor: TStyleColor): TColor;
var
  Painter: TcxCustomLookAndFeelPainter;
begin
  result := TColors.Black;

  Painter := GetSkinPainter;

  if Assigned(Painter) then
  begin
    case StyleColor of
      scBtnFace:
        result := Painter.DefaultControlTextColor;
      scMoneyGreen:
        result := Painter.DefaultControlTextColor;
      scMoneyGreenLight:
        result := Painter.DefaultControlTextColor;
      scCream:
        result := Painter.DefaultControlTextColor;
      scInfoBk:
        result := Painter.DefaultControlTextColor;
      scSkyBlue:
        result := Painter.DefaultControlTextColor;
      scSkyBlueLight:
        result := Painter.DefaultControlTextColor;
      scHeader:
        result := Painter.DefaultHeaderTextColor;
      scHeaderBackground:
        result := Painter.DefaultHeaderBackgroundTextColor;
      scHighlight:
        result := Painter.DefaultSelectionTextColor;
    end;
  end
  else
  begin
    case StyleColor of
      scBtnFace:
        result := TColors.Black;
      scMoneyGreen:
        result := TColors.Black;
      scMoneyGreenLight:
        result := TColors.Black;
      scCream:
        result := TColors.Black;
      scInfoBk:
        result := TColors.SysInfoText;
      scSkyBlue:
        result := TColors.Black;
      scSkyBlueLight:
        result := TColors.Black;
      scHeader:
        result := clBtnText;
      scHeaderBackground:
        result := clBtnFace;
      scHighlight:
        result := TColors.Black;
    end;
  end;
end;

function Tdx.GetStyle(StyleColor: TStyleColor): TcxStyle;
begin
  result := nil;

  case StyleColor of
    scBtnFace:
      result := cxStyleBtnFace;
    scMoneyGreen:
      result := cxStyleMoneyGreen;
    scMoneyGreenLight:
      result := cxStyleMoneyGreenLight;
    scCream:
      result := cxStyleCream;
    scInfoBk:
      result := cxStyleInfoBk;
    scSkyBlue:
      result := cxStyleSkyBlue;
    scSkyBlueLight:
      result := cxStyleSkyBlueLight;
    scHeader:
      result := cxStyleHeader;
    scHeaderBackground:
      result := cxStyleHeaderBackground;
    scHighlight:
      result := cxStyleHighlight;
    scControl:
      result := cxStyleControl;
    scContent:
      result := cxStyleContent;
    scContentOdd:
      result := cxStyleContentOdd;
    scContentEven:
      result := cxStyleContentEven;
    scFooter:
      result := cxStyleFooter;
  end;
end;

function Tdx.GetCustomEditClass(ControlType: TzCtrlType; const dbAware: boolean = true): TcxCustomEditClass;
begin
  result := nil;

  if dbAware then
  begin
    case ControlType of
      ctDefault:
        result := TcxDBTextEdit;
      ctEdit:
        result := TcxDBTextEdit;
      ctSpin:
        result := TcxDBSpinEdit;
      ctDate:
        result := TcxDBDateEdit;
      ctTime:
        result := TcxDBTimeEdit;
      ctDateTime:
        result := TcxDBDateEdit;
      ctComboBox:
        result := TcxDbComboBox;
      ctPickList:
        result := TcxDbImageComboBox;
      ctPickListImage:
        result := TcxDbImageComboBox;
      ctRadioGroup:
        result := TcxDbRadioGroup;
      ctComboDlg:
        result := TcxDBButtonEdit;
      ctLookup:
        result := TcxDBLookupComboBox;
      ctLookupExt:
        result := TcxDBExtLookupComboBox; { TODO : ExtLookup }
      ctLookupHyperLink:
        result := TcxDBExtLookupComboBox;
      ctCheckBox:
        result := TcxDbCheckBox;
      ctMemo:
        result := TcxDBMemo;
      ctRTF:
        result := TcxDbRichEdit;
      ctImage:
        result := TcxDbImage;
      ctHyperLink:
        result := TcxDbHyperLinkEdit;
      ctProgressBar:
        result := TcxDbProgressBar;
      ctRating:
        result := TdxDBRatingControl;
      ctColorCombo:
        result := TcxDBColorComboBox;
      ctCustomDlg:
        result := TcxDBButtonEdit;
      ctCheckComboBox:
        result := TcxDBCheckComboBox;
      ctToggleSwitch:
        result := TdxDBToggleSwitch;
      ctDateTimeWheelPicker:
        result := TdxDBDateTimeWheelPicker;
      ctTokenEdit:
        result := TdxDBTokenEdit;
      ctFormattedLabel:
        result := TdxDBFormattedLabel;
      ctCheckGroupBox:
        result := TdxDBCheckGroupBox;
      ctButtonEdit:
        result := TcxDBButtonEdit;
      ctMaskEdit:
        result := TcxDBMaskEdit;
      ctCheckGroup:
        result := TcxDBCheckGroup;
      ctShellComboBox:
        result := TcxDBShellComboBox;
    end;
  end
  else
  begin
    case ControlType of
      ctDefault:
        result := TcxTextEdit;
      ctEdit:
        result := TcxTextEdit;
      ctSpin:
        result := TcxSpinEdit;
      ctDate:
        result := TcxDateEdit;
      ctTime:
        result := TcxTimeEdit;
      ctDateTime:
        result := TcxDateEdit;
      ctComboBox:
        result := TcxComboBox;
      ctPickList:
        result := TcxImageComboBox;
      ctPickListImage:
        result := TcxImageComboBox;
      ctRadioGroup:
        result := TcxRadioGroup;
      ctComboDlg:
        result := TcxButtonEdit;
      ctLookup:
        result := TcxLookupComboBox;
      ctLookupExt:
        result := TcxExtLookupComboBox;
      ctLookupHyperLink: { TODO : ExtLookup }
        result := TcxExtLookupComboBox;
      ctCheckBox:
        result := TcxCheckBox;
      ctMemo:
        result := TcxMemo;
      ctRTF:
        result := TcxRichEdit;
      ctImage:
        result := TcxImage;
      ctHyperLink:
        result := TcxHyperLinkEdit;
      ctProgressBar:
        result := TcxProgressBar;
      ctRating:
        result := TdxRatingControl;
      ctColorCombo:
        result := TcxColorComboBox;
      ctCustomDlg:
        result := TcxButtonEdit;
      ctCheckComboBox:
        result := TcxDBCheckComboBox;
      ctToggleSwitch:
        result := TdxDBToggleSwitch;
      ctDateTimeWheelPicker:
        result := TdxDBDateTimeWheelPicker;
      ctTokenEdit:
        result := TdxDBTokenEdit;
      ctFormattedLabel:
        result := TdxDBFormattedLabel;
      ctCheckGroupBox:
        result := TdxDBCheckGroupBox;
      ctButtonEdit:
        result := TcxDBButtonEdit;
      ctMaskEdit:
        result := TcxDBMaskEdit;
      ctCheckGroup:
        result := TcxDBCheckGroup;
      ctShellComboBox:
        result := TcxDBShellComboBox;
    end;
  end;
end;

function Tdx.ValueStr(cxCustomEdit: TcxCustomEdit): string;
begin
  result := '';

  if Assigned(cxCustomEdit) then
    if not VarIsNull(cxCustomEdit.EditValue) then
      result := cxCustomEdit.EditValue;
end;

function Tdx.ValueDate(cxCustomEdit: TcxCustomEdit): TDateTime;
begin
  result := NullDate;

  if Assigned(cxCustomEdit) then
    if not VarIsNull(cxCustomEdit.EditValue) then
      result := cxCustomEdit.EditValue;
end;

function Tdx.ValueDouble(cxCustomEdit: TcxCustomEdit): double;
begin
  result := -1;

  if Assigned(cxCustomEdit) then
    if not VarIsNull(cxCustomEdit.EditValue) then
      result := cxCustomEdit.EditValue;
end;

function Tdx.ValueInt(cxCustomEdit: TcxCustomEdit): integer;
begin
  result := -1;

  if Assigned(cxCustomEdit) then
    if not VarIsNull(cxCustomEdit.EditValue) then
      result := cxCustomEdit.EditValue;
end;

function Tdx.GetPropertiesClass(ControlType: TzCtrlType): TcxCustomEditPropertiesClass;
begin
  result := nil;

  case ControlType of
    ctDefault:
      result := TcxTextEditProperties;
    ctEdit:
      result := TcxTextEditProperties;
    ctSpin:
      result := TcxSpinEditProperties;
    ctDate:
      result := TcxDateEditProperties;
    ctTime:
      result := TcxTimeEditProperties;
    ctDateTime:
      result := TcxDateEditProperties;
    ctComboBox:
      result := TcxComboBoxProperties;
    ctPickList:
      result := TcxImageComboBoxProperties;
    ctPickListImage:
      result := TcxImageComboBoxProperties;
    ctRadioGroup:
      result := TcxRadioGroupProperties;
    ctComboDlg:
      result := TcxButtonEditProperties;
    ctLookup:
      result := TcxLookupComboBoxProperties;
    ctLookupExt:
      result := TcxExtLookupComboBoxProperties;
    ctLookupHyperLink:
      result := TcxExtLookupComboBoxProperties; { TODO : ExtLookup }
    ctCheckBox:
      result := TcxCheckBoxProperties;
    ctMemo:
      result := TcxMemoProperties;
    ctRTF:
      result := TcxRichEditProperties;
    ctImage:
      result := TcxImageProperties;
    ctHyperLink:
      result := TcxHyperLinkEditProperties;
    ctProgressBar:
      result := TcxProgressBarProperties;
    ctRating:
      result := TdxRatingControlProperties;
    ctColorCombo:
      result := TcxColorComboBoxProperties;
    ctCustomDlg:
      result := TcxButtonEditProperties;
    ctCheckComboBox:
      result := TcxCheckComboBoxProperties;
    ctToggleSwitch:
      result := TdxToggleSwitchProperties;
    ctDateTimeWheelPicker:
      result := TdxDateTimeWheelPickerProperties;
    ctTokenEdit:
      result := TdxTokenEditProperties;
    ctFormattedLabel:
      result := TdxFormattedLabelProperties;
    ctCheckGroupBox:
      result := TdxCheckGroupBoxProperties;
    ctButtonEdit:
      result := TcxButtonEditProperties;
    ctMaskEdit:
      result := TcxMaskEditProperties;
    ctCheckGroup:
      result := TcxCheckGroupProperties;
    ctShellComboBox:
      result := TcxShellComboBoxProperties;
  end;
end;

function Tdx.ActiveGrid: TcxGridDBTableView;
var
  current: TControl;
begin

  result := nil;

  current := ActiveControl;

  while Assigned(current) do
  begin
    if current is TcxGridSite then
    begin
      result := TcxGridDBTableView((current as TcxGridSite).GridView);
      Exit;
    end;

    current := current.Parent;
  end;
end;

function Tdx.Alert(const ACaption, AText: string; AImageIndex: TImageIndex = -1): TdxAlertWindow;
begin
  result := dxAlertWindowManager.Show(ACaption, AText, AImageIndex);
end;

function Tdx.ActiveControl: TcxCustomEdit;
var
  AControl: TWinControl;
begin
  result := nil;

  AControl := Screen.ActiveControl;

  if Supports(AControl, IcxInnerEditHelper) or Supports(AControl, IcxContainerInnerControl) then
    result := TcxCustomEdit(AControl.Owner)
  else
    if AControl is TcxCustomEdit then
      result := TcxCustomEdit(AControl);
end;

procedure Tdx.AssignPickList(Properties: TcxCustomEditProperties; zPickList: TzPickList);
var
  Value: TzPickValue;
  ImageItems: TcxImageComboBoxItems;
  ImageItem: TcxImageComboBoxItem;
  RadioGroupItems: TcxRadioGroupItems;
  RadioGroupItem: TcxRadioGroupItem;
begin
  if not Assigned(Properties) then
    Exit;

  if not Assigned(zPickList) then
    Exit;

  if Properties is TcxImageComboBoxProperties then
  begin
    ImageItems := TcxImageComboBoxProperties(Properties).items;
    ImageItems.Clear;

    for Value in zPickList.PickValues do
    begin
      ImageItem := ImageItems.Add;
      ImageItem.Description := Value.Name;
      ImageItem.Value := Value.Value;
      ImageItem.ImageIndex := Value.ImageIndex;
    end;
  end
  else
    if Properties is TcxRadioGroupProperties then
    begin
      RadioGroupItems := TcxRadioGroupProperties(Properties).items;
      RadioGroupItems.Clear;

      for Value in zPickList.PickValues do
      begin
        RadioGroupItem := RadioGroupItems.Add;
        RadioGroupItem.Caption := Value.Name;
        RadioGroupItem.Value := Value.Value;
      end;
    end
    else
      if Properties is TcxCustomTextEditProperties then
        TcxCustomTextEditProperties(Properties).LookupItems.Text := zPickList.AsText;
end;

function Tdx.Visible(const Visible: boolean): TdxBarItemVisible;
begin
  if Visible then
    result := ivAlways
  else
    result := ivNever;
end;

procedure Tdx.GetBitmap(Glyph: TdxSmartGlyph; ImageList: TCustomImageList; ImageIndex: TImageIndex);
var
  bmp: TBitmap;
begin
  Assert(Assigned(Glyph));
  Assert(Assigned(ImageList));

  bmp := TBitmap.Create;
  try
    bmp.Width := ImageList.Width;
    bmp.Height := ImageList.Height;
    bmp.PixelFormat := pf24bit;
    bmp.Canvas.FillRect(Rect(0, 0, bmp.Width, bmp.Height));
    ImageList.GetBitmap(ImageIndex, bmp);
    TBitmapAccess(Glyph).Changed(nil);
    Glyph.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

function Tdx.FontTextHeight(Font: TFont; const Text: string = '0'): integer;
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.Canvas.Font.Assign(Font);
    result := bmp.Canvas.TextHeight(Text);
  finally
    FreeAndNil(bmp);
  end;
end;

function Tdx.FontTextWidth(Font: TFont; const Text: string = '0'): integer;
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.Canvas.Font.Assign(Font);
    result := bmp.Canvas.TextWidth(Text);
  finally
    FreeAndNil(bmp);
  end;
end;

procedure Tdx.InitGrid(cxCustomGridTableView: TcxCustomGridTableView);
begin
  Assert(Assigned(cxCustomGridTableView));

  cxCustomGridTableView.OptionsBehavior.BestFitMaxRecordCount := 50;
  cxCustomGridTableView.DataController.Filter.DateTimeFormat := 'dd.mm.yyyy';
  cxCustomGridTableView.OptionsSelection.CellSelect := true;

  if cxCustomGridTableView.DataController is TcxGridDBDataController then
    TcxGridDBDataController(cxCustomGridTableView.DataController).DataModeController.GridMode := true;

  cxCustomGridTableView.Styles.Background := cxStyleContent;
  cxCustomGridTableView.Styles.Content := cxStyleContent;
  cxCustomGridTableView.Styles.ContentEven := cxStyleContentEven;
  cxCustomGridTableView.Styles.ContentOdd := cxStyleContentOdd;
  cxCustomGridTableView.Styles.FilterBox := cxStyleFilterBox;

  if cxCustomGridTableView is TcxGridDBTableView then
  begin
    TcxGridDBTableView(cxCustomGridTableView).Styles.Header := cxStyleHeader;
    TcxGridDBTableView(cxCustomGridTableView).Styles.Footer := cxStyleFooter;
    //
    TcxGridDBTableView(cxCustomGridTableView).OptionsSelection.HideSelection := false;
  end;
end;

// Dominio (dizionario dati) del campo legato all'editor, nil se non determinabile.
// TcxDBEditDataBinding.Field.Origin e' "TABELLA.CAMPO": la stessa chiave con cui TzDbCard
// risale al TzDomain. Per gli editor in linea delle griglie il binding non e' DB: nil.
function Tdx.DominioDelSender(Sender: TObject): TzDomain;
var
  Binding: TcxDBEditDataBinding;
begin
  result := nil;

  if not (Sender is TcxCustomEdit) then
    Exit;
  if not (TcxCustomEditAccess(Sender).DataBinding is TcxDBEditDataBinding) then
    Exit;

  Binding := TcxDBEditDataBinding(TcxCustomEditAccess(Sender).DataBinding);
  if not Assigned(Binding.Field) or (Binding.Field.Origin = '') then
    Exit;
  if not Assigned(Base) then
    Exit;

  result := Base.zDataDictionary.Get(Binding.Field.Origin, False);
end;

// Sanificazione generale del testo: livello predefinito di TzSanificazione (caratteri
// invisibili, spazi Unicode, simboli di font, punteggiatura tipografica, legature, bordi),
// multiriga per i memo. Esclusi RTF, password, editor a tendina (combo, lookup, picklist:
// il testo e' una chiave o una voce di elenco) e contenuti che sembrano marcatura.
procedure Tdx.SanificaDisplayValue(Sender: TObject; var DisplayValue: Variant);
var
  Properties: TcxCustomEditProperties;
  Testo: string;
  Ripulito: string;
  Multiriga: boolean;
begin
  if not FSanificaTesto then
    Exit;
  if VarIsNull(DisplayValue) or VarIsEmpty(DisplayValue) or not VarIsStr(DisplayValue) then
    Exit;
  if not (Sender is TcxCustomEdit) then
    Exit;

  Properties := TcxCustomEdit(Sender).ActiveProperties;
  if not (Properties is TcxCustomTextEditProperties) then
    Exit;
  if Properties is TcxRichEditProperties then
    Exit;
  if Properties is TcxCustomDropDownEditProperties then
    Exit;
  if TcxCustomTextEditProperties(Properties).EchoMode = eemPassword then
    Exit;

  Testo := VarToStr(DisplayValue);
  if (Testo = '') or TzSanificazione.SembraMarcatura(Testo) then
    Exit;

  Multiriga := Properties is TcxCustomMemoProperties;
  Ripulito := TzSanificazione.Sanifica(Testo, Multiriga, TzSanificazione.OpzioniPredefinite);
  if Ripulito <> Testo then
    DisplayValue := Ripulito;
end;

// Regola del dominio: se il dizionario dati marca il campo con SanificaEmail, il valore
// viene normalizzato (minuscolo, mailto:, "Nome <indirizzo>") e validato con la regex di
// riferimento (TzSanificazioneEmail). L'errore mostra l'icona sull'editor; il blocco
// definitivo resta ai trigger del database.
procedure Tdx.ValidaDominio(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
var
  Domain: TzDomain;
  Esito: TEsitoSanificazioneEmail;
begin
  if Error then
    Exit; // c'e' gia' un errore (valore richiesto): non lo si sovrascrive
  if VarIsNull(DisplayValue) or VarIsEmpty(DisplayValue) then
    Exit;

  Domain := DominioDelSender(Sender);
  if not Assigned(Domain) or not Domain.SanificaEmail then
    Exit;

  Esito := TzSanificazioneEmail.Sanifica(VarToStr(DisplayValue));
  case Esito.Esito of
    eeVuota:
      DisplayValue := Null;
    eeValida:
      DisplayValue := Esito.Normalizzato;
    eeNonValida:
      begin
        Error := true;
        ErrorText := 'Indirizzo e-mail non valido: ' + Esito.Motivo;
      end;
  end;
end;

// L'ordine conta: prima la sanificazione (puo' svuotare un valore fatto solo di caratteri
// invisibili), poi l'obbligatorieta', poi la regola del dominio.
procedure Tdx.ValidateRequired(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
begin
  SanificaDisplayValue(Sender, DisplayValue);
  Error := VarIsNull(DisplayValue) or (VarToStr(DisplayValue).Trim = '');
  if Error then
    ErrorText := 'Valore richiesto'
  else
    ErrorText := '';
  ValidaDominio(Sender, DisplayValue, ErrorText, Error);
end;

procedure Tdx.ValidateNormal(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
begin
  SanificaDisplayValue(Sender, DisplayValue);
  Error := false;
  ErrorText := '';
  ValidaDominio(Sender, DisplayValue, ErrorText, Error);
end;

procedure Tdx.SetValue(item: TcxBarEditItem; Value: Variant);
var
  OnChange: TNotifyEvent;
begin
  Assert(Assigned(item));

  OnChange := item.OnChange;
  item.OnChange := Nil;
  try
    item.EditValue := Value;
  finally
    item.OnChange := OnChange;
  end;
end;

procedure Tdx.SetValue(item: TdxBarEdit; Value: string);
var
  OnChange: TNotifyEvent;
begin
  Assert(Assigned(item));

  OnChange := item.OnChange;
  item.OnChange := Nil;
  try
    item.Text := Value;
  finally
    item.OnChange := OnChange;
  end;
end;

procedure Tdx.SetValue(item: TdxBarSpinEdit; Value: Extended);
var
  OnChange: TNotifyEvent;
begin
  Assert(Assigned(item));

  OnChange := item.OnChange;
  item.OnChange := Nil;
  try
    item.Value := Value;
  finally
    item.OnChange := OnChange;
  end;
end;

function Tdx.GetStatesString(a: array of boolean): string;
var
  v: boolean;
begin
  result := '';
  for v in a do
    if v then
      result := result + '1'
    else
      result := result + '0';
end;

procedure Tdx.SetValue(item: TcxCheckBox; Value: boolean);
var
  OnChange: TNotifyEvent;
begin
  Assert(Assigned(item));

  OnChange := item.Properties.OnEditValueChanged;
  item.Properties.OnEditValueChanged := Nil;
  try
    item.Checked := Value;
  finally
    item.Properties.OnEditValueChanged := OnChange;
  end;
end;

procedure Tdx.InitTitle(Title: TcxLabel);
begin
  InitLabel(Title, false);
  Title.Style.styleController := TitleStyleController;
end;

procedure Tdx.InitTreeList(cxDbTreeList: TcxDbTreeList; const ApplyStyles: boolean);
begin
  Assert(Assigned(cxDbTreeList));

  cxDbTreeList.BorderStyle := cxcbsNone;
  cxDbTreeList.LookAndFeel.Kind := lfFlat;
  cxDbTreeList.OptionsSelection.HideFocusRect := false;

  if ApplyStyles then
  begin
    cxDbTreeList.Styles.Background := GetStyle(scControl);
    cxDbTreeList.Styles.Content := GetStyle(scControl);
    cxDbTreeList.Styles.Inactive := GetStyle(scControl);
    cxDbTreeList.Styles.Footer := GetStyle(scFooter);
  end;
end;

procedure Tdx.InitTreeList(cxTreeList: TcxTreeList; const ApplyStyles: boolean = true);
begin
  Assert(Assigned(cxTreeList));

  cxTreeList.BorderStyle := cxcbsNone;
  cxTreeList.LookAndFeel.Kind := lfUltraFlat; // era lfFlat
  cxTreeList.OptionsSelection.HideFocusRect := false;

  if ApplyStyles then
  begin
    cxTreeList.Styles.Background := GetStyle(scControl);
    cxTreeList.Styles.Content := GetStyle(scControl);
    cxTreeList.Styles.Footer := GetStyle(scFooter);

    // cxTreeList.Styles.Inactive := GetStyle(scControl);
    cxTreeList.Styles.Inactive := cxStyleTreeListInactive;
  end;
end;

function Tdx.IsActiveControl(cxGrid: TcxGrid): boolean;
var
  ctrl: TWinControl;
begin
  result := false;

  ctrl := ActiveControl;
  while Assigned(ctrl) do
  begin
    if ctrl = cxGrid then
      Exit(true)
    else
      ctrl := ctrl.Parent;
  end;
end;

function Tdx.IsActiveControl(cxCustomEdit: TcxCustomEdit): boolean;
begin
  result := self.ActiveControl = cxCustomEdit;
end;

procedure Tdx.InitLabel(cxLabel: TcxLabel; const Transparent: boolean = true);
begin
  Assert(Assigned(cxLabel));
  cxLabel.ParentFont := false;
  cxLabel.ParentColor := false;
  cxLabel.Style.styleController := LabelStyleController;

  cxLabel.Properties.ShowEndEllipsis := not cxLabel.AutoSize;
  cxLabel.Transparent := Transparent;
end;

procedure Tdx.InitLayoutControl(dxLayoutControl: TdxLayoutControl);
begin
  Assert(Assigned(dxLayoutControl));

  dxLayoutControl.CustomizeFormClass := TzLayoutCustomizeForm;
  dxLayoutControl.CustomizeFormTabbedView := false;
  dxLayoutControl.OptionsStoring.StoreToIniFile := false;
  dxLayoutControl.OptionsItem.AutoControlAreaAlignment := true;
  dxLayoutControl.OptionsItem.AutoControlTabOrders := true;
  dxLayoutControl.OptionsItem.FocusControlOnItemCaptionClick := true;
  dxLayoutControl.OptionsItem.SizableHorz := true;
  dxLayoutControl.OptionsItem.SizableVert := true;
  dxLayoutControl.BevelInner := bvNone;
  dxLayoutControl.BevelOuter := bvNone;
  dxLayoutControl.LookAndFeel := LayoutLookAndFeelNormal;
  dxLayoutControl.LayoutLookAndFeel := LayoutLookAndFeelNormal;

  // Le icone dei gruppi definiti nel dizionario LZ sono indici di Immagini;
  // una lista assegnata nel DFM della form resta quella della form
  if not Assigned(dxLayoutControl.OptionsImage.Images) then
    dxLayoutControl.OptionsImage.Images := Immagini;

  dxLayoutControl.OnGetItemStoredProperties := dxLayoutControlGetItemStoredProperties;
  dxLayoutControl.OnGetItemStoredPropertyValue := dxLayoutControlGetItemStoredPropertyValue;
  dxLayoutControl.OnSetItemStoredPropertyValue := dxLayoutControlSetItemStoredPropertyValue;

  // no, deve rispettare il preesistente LayoutControl.Items.LayoutDirection := ldHorizontal;
  // LayoutControl.Items.AlignHorz := ahClient;
  // LayoutControl.Items.AlignVert := avClient;
end;

procedure Tdx.InitSeparator(Separator: TcxLabel);
begin
  InitLabel(Separator, false);
  Separator.Style.styleController := SeparatorStyleController;
  // !!!!!!!!!!!!!!!
end;

procedure Tdx.UpdateStyles;
  procedure UpdateStyleController(styleController: TcxEditStyleController; Const Color, FontColor: TColor);
  begin
    styleController.Style.Color := Color;
    styleController.Style.Font.Color := FontColor;
  end;
  // Per le label con fondo proprio (titolo, separatore): sotto skin il TcxLabel
  // ignora Font.Color e, se TextColor non e' assegnato, scrive col colore delle
  // label dello skin (bianco negli skin scuri) sopra il fondo chiaro dato qui.
  // TextColor esplicito tiene testo e fondo della stessa coppia del painter.
  procedure UpdateOpaqueStyleController(styleController: TcxEditStyleController; Const Color, FontColor: TColor);
  begin
    UpdateStyleController(styleController, Color, FontColor);
    styleController.Style.TextColor := FontColor;
  end;
  procedure UpdateStyle(Style: TcxStyle; Const Color, FontColor: TColor);
  begin
    Style.Color := Color;
    Style.Font.Color := FontColor;
  end;

begin
  /// ///////////////////
  // editor

  UpdateOpaqueStyleController(TitleStyleController, dx.GetColor(ckTitle), dx.GetFontColor(ckTitle));
  UpdateStyleController(LabelStyleController, dx.GetColor(ckLabel), dx.GetFontColor(ckLabel));
  UpdateOpaqueStyleController(SeparatorStyleController, dx.GetColor(ckSeparator), dx.GetFontColor(ckSeparator));
  UpdateStyleController(NormalStyleController, dx.GetColor(ckEditorNormal), dx.GetFontColor(ckEditorNormal));
  UpdateStyleController(ReadOnlyStyleController, dx.GetColor(ckEditorReadOnly), dx.GetFontColor(ckEditorReadOnly));
  UpdateStyleController(RequiredStyleController, dx.GetColor(ckEditorRequired), dx.GetFontColor(ckEditorRequired));
  UpdateStyleController(BtnFaceStyleController, dx.GetColor(ckBtnFace), dx.GetFontColor(ckBtnFace));

  // grid
  UpdateStyle(cxStyleContent, dx.GetColor(ckGridContent), dx.GetFontColor(ckGridContent));
  UpdateStyle(cxStyleContentEven, dx.GetColor(ckGridContentEven), dx.GetFontColor(ckGridContentEven));
  UpdateStyle(cxStyleContentOdd, dx.GetColor(ckGridContentOdd), dx.GetFontColor(ckGridContentOdd));
  UpdateStyle(cxStyleFooter, dx.GetColor(ckGridFooter), dx.GetFontColor(ckGridFooter));
  UpdateStyle(cxStyleFilterBox, dx.GetColor(ckFilterBox), dx.GetFontColor(ckFilterBox));

  // tree
  UpdateStyleController(TreeStyleController, dx.GetColor(ckTreeView), dx.GetFontColor(ckTreeView));

  // altro
  UpdateStyle(cxStyleControl, dx.GetColor(ckControl), dx.GetFontColor(ckControl));
  /// ///////////////////
  /// Colori
  UpdateStyle(cxStyleBtnFace, dx.GetColor(scBtnFace), dx.GetFontColor(scBtnFace));
  UpdateStyle(cxStyleMoneyGreen, dx.GetColor(scMoneyGreen), dx.GetFontColor(scMoneyGreen));
  UpdateStyle(cxStyleMoneyGreenLight, dx.GetColor(scMoneyGreenLight), dx.GetFontColor(scMoneyGreenLight));
  UpdateStyle(cxStyleCream, dx.GetColor(scCream), dx.GetFontColor(scCream));
  UpdateStyle(cxStyleInfoBk, dx.GetColor(scInfoBk), dx.GetFontColor(scInfoBk));
  UpdateStyle(cxStyleSkyBlue, dx.GetColor(scSkyBlue), dx.GetFontColor(scSkyBlue));
  UpdateStyle(cxStyleSkyBlueLight, dx.GetColor(scSkyBlueLight), dx.GetFontColor(scSkyBlueLight));
  UpdateStyle(cxStyleHeader, dx.GetColor(scHeader), dx.GetFontColor(scHeader));
  UpdateStyle(cxStyleHeaderBackground, dx.GetColor(scHeaderBackground), dx.GetFontColor(scHeaderBackground));
  UpdateStyle(cxStyleHighlight, dx.GetColor(scHighlight), dx.GetFontColor(scHighlight));
  /// ///////////////////

  UpdateCustomStyles;
  /// ///////////////////
  ///
  InitStyleTreeListInactive;
end;

function Tdx.GetStyleController(Editability: TEditability): TcxEditStyleController;
begin
  result := nil;

  case Editability of
    edNormal:
      result := NormalStyleController;
    edRequired:
      result := RequiredStyleController;
    edReadOnly:
      result := ReadOnlyStyleController;
  end;
end;

procedure Tdx.InitPageControl(cxPageControl: TcxPageControl);
var
  PageChanging: TcxPageChangingEvent;
begin
  Assert(Assigned(cxPageControl));
  cxPageControl.LookAndFeel.AssignedValues := []; // reset
  cxPageControl.TabStop := false;
  cxPageControl.HotTrack := true;
  // cxPageControl.ShowFrame := true;
  cxPageControl.ShowFrame := false;
  cxPageControl.Properties.RaggedRight := true;

  if cxPageControl.TabPosition = tpTop then
    cxPageControl.MultiLine := false;

  if cxPageControl.PageCount > 0 then
  begin
    PageChanging := cxPageControl.OnPageChanging;
    cxPageControl.OnPageChanging := nil;
    try
      cxPageControl.ActivePageIndex := 0;
    finally
      cxPageControl.OnPageChanging := PageChanging;
    end;
  end;
  // 14.12.11 Roger!!!
  // cxPageControl.Style := 9;
  // cxPageControl.TabSlants.Kind := skCutCorner;
  // cxPageControl.TabSlants.Positions := [spRight];
end;

procedure Tdx.InitPickList(cxImageComboBoxProperties: TcxImageComboBoxProperties; const PickListName: string);
var
  PickList: TzPickList;
begin
  Assert(Assigned(cxImageComboBoxProperties));

  PickList := Base.zPickLists.Get(PickListName, false);

  if Assigned(PickList) then
    PickList.AssignToProps(cxImageComboBoxProperties);

  // Le icone delle picklist sono indici di Immagini: un controllo che aveva gia'
  // una lista (le vecchie ImageList16/24 delle applicazioni, assegnate nel DFM
  // o prima di questa chiamata) passa a Immagini. Senza lista resta senza icone,
  // come vuole ctPickList. La lista grande non serve: Immagini e' vettoriale.
  if Assigned(cxImageComboBoxProperties.Images) then
    cxImageComboBoxProperties.Images := Immagini;
  if Assigned(cxImageComboBoxProperties.LargeImages) then
    cxImageComboBoxProperties.LargeImages := nil;
end;

procedure Tdx.InitButtonEdit(cxButtonEditProperties: TcxButtonEditProperties; OnButtonClick: TcxEditButtonClickEvent; const Editable: boolean = false);
begin
  Assert(Assigned(cxButtonEditProperties));

  cxButtonEditProperties.OnButtonClick := OnButtonClick;

  if cxButtonEditProperties.Buttons.Count = 0 then
    cxButtonEditProperties.Buttons.Add;

  cxButtonEditProperties.Buttons[0].Kind := bkEllipsis;

  cxButtonEditProperties.Readonly := not Editable;

  if Editable then
    cxButtonEditProperties.ViewStyle := vsNormal
  else
    cxButtonEditProperties.ViewStyle := vsHideCursor;
end;

procedure Tdx.InitColorCombo(cxColorComboBoxProperties: TcxColorComboBoxProperties);
begin
  Assert(Assigned(cxColorComboBoxProperties));

  cxColorComboBoxProperties.AllowSelectColor := true;
  cxColorComboBoxProperties.ColorComboStyle := cxccsComboList;
  cxColorComboBoxProperties.ColorDialogShowFull := true;
  cxColorComboBoxProperties.DropDownRows := 12;
  cxColorComboBoxProperties.DropDownSizeable := true;
  cxColorComboBoxProperties.NamingConvention := cxncX11;
  cxColorComboBoxProperties.PrepareList := cxplX11;
  cxColorComboBoxProperties.ShowDescriptions := false;
  cxColorComboBoxProperties.ColorValueFormat := cxcvInteger;
  cxColorComboBoxProperties.OnSelectCustomColor := ColorCombo_SelectCustomColor;
  cxColorComboBoxProperties.OnEditValueChanged := ColorCombo_EditValueChanged;
end;

function Tdx.LayoutControlHeigth(LayoutControl: TdxLayoutControl): integer;
var
  I: integer;
  item: TdxCustomLayoutItem;
  MaxBottom: integer;
begin
  result := 0;
  MaxBottom := 0;

  // Scorre tutti gli item del layout
  for I := 0 to LayoutControl.items.Count - 1 do
  begin
    item := LayoutControl.items[I];

    // Considera solo gli item visibili
    if item.Visible then
    begin
      // Calcola il punto più basso dell'item (Top + Height)
      if item.ViewInfo <> nil then
        MaxBottom := Max(MaxBottom, item.ViewInfo.Bounds.Bottom);
    end;
  end;

  // Aggiungi i margini del container
  if LayoutControl.Container.ViewInfo <> nil then
  begin
    result := MaxBottom + LayoutControl.Container.ViewInfo.ContentBounds.Top + LayoutControl.Padding.Bottom;
  end
  else
    result := MaxBottom;
end;

function Tdx.LayoutLookAndFeelNoGroupBorder: TdxCustomLayoutLookAndFeel;
begin
  result := InternalLayoutLookAndFeelNoBorder;
end;

function Tdx.LayoutLookAndFeelNormal: TdxCustomLayoutLookAndFeel;
begin
  result := InternalLayoutLookAndFeelNormal;
end;

constructor TzLayoutLookAndFeel.Create(aOwner: TComponent);
begin
  inherited;
  FHideGroupBorder := false;
  LookAndFeel.NativeStyle := false;
  Offsets.RootItemsAreaOffsetHorz := 3;
  Offsets.RootItemsAreaOffsetVert := 3;
end;

function TzLayoutLookAndFeel.GetGroupBorderOffset(AContainer: TComponent; ASide, ACaptionSide: TdxLayoutSide): integer;
begin
  // 2026-11-08: con DevExpress 26.1 il bordo azzerato anche in alto e in basso rende le
  // linguette dei gruppi a schede insensibili al clic (la pagina non cambia, nessun gestore
  // viene chiamato). Il bordo si toglie quindi solo a sinistra e a destra, dove si recupera
  // la larghezza; in alto e in basso resta il valore di DevExpress.
  // Prove in D:\AI\OUT\20261107-modulo-progettazione-bandi-codebri\Stato.md.
  // 2026-11-08 (sera): anche con il bordo azzerato solo a sinistra e a destra, col mouse vero le
  // linguette rispondono solo vicino al centro (l'area sensibile e' piu' piccola di quella
  // disegnata). Si usa quindi il valore di DevExpress su tutti i lati.
  // 2026-11-08 (sera, prova): col valore di DevExpress su tutti i lati si perdono circa 12 px
  // verticali per ogni gruppo annidato (spazi vuoti fra le viste di Risorse e altre form).
  // Ora che il painter non e' piu' forzato (rilascio 006) si ripristina l'azzeramento originale.
  if HideGroupBorder then
    result := 0
  else
    result := inherited GetGroupBorderOffset(AContainer, ASide, ACaptionSide);
end;

function TzLayoutLookAndFeel.GetGroupPainterClass: TClass;
begin
  // 2026-11-08 (sera, prova): il painter "Standard" forzato disegna le linguette con una
  // geometria diversa da quella con cui DevExpress 26.1 calcola l'area sensibile, per cui
  // l'hot track (e quindi il clic) non scatta ai bordi della linguetta, soprattutto entrando da
  // sinistra. Si usa quello scelto da DevExpress per lo stile. Se in modalita' UltraFlat
  // ricompare il bordo blu (motivo del vecchio override), ripristinare la riga seguente:
  // result := TdxLayoutGroupStandardPainter;
  result := inherited GetGroupPainterClass;
end;

function Tdx.FieldSize(Field: TField): integer;
const
  DefaultW = 20;
  MinW = 5;
begin
  result := DefaultW;

  if Assigned(Field) then
    case Field.DataType of
      ftString, ftFixedChar, ftWideString:
        begin

          if Field.Size in [0 .. 20] then
            result := 20
          else
            if Field.Size in [21 .. 50] then
              result := 50
            else
              result := 100;
        end;
      ftBoolean:
        result := MinW;
      ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
        result := DefaultW;
      ftFloat, ftCurrency, ftBCD, ftFMTBcd:
        result := DefaultW;
      ftDate, ftTime, ftDateTime, ftTimeStamp:
        result := DefaultW;
      ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftTypedBinary:
        result := 999;
    end;
end;

procedure Tdx.InitLookupColumns(const IdLookup: string; LookupComboBoxProperties: TcxLookupComboBoxProperties; DataSet: TzFbDataSet);
var
  I: integer;
  zDbViewProps: TzDbViewProps;
  Column: TcxLookupDBGridColumn;
  Field: TField;
  zColumn: TzColumn;
  TextWidth: integer;
  WasUseSqlLocate: boolean;
  ListFieldNames: string;
begin
  Assert(Assigned(LookupComboBoxProperties));
  Assert(Assigned(DataSet));

  TextWidth := 7;
  if Assigned(LookupComboBoxProperties.grid) then
    TextWidth := Max(TextWidth, FontTextWidth(LookupComboBoxProperties.grid.Font));

  zDbViewProps := TzDbViewProps.Create(nil);
  try
    zDbViewProps.Name := IdLookup;
    try
      if zDbViewProps.LoadFromBase then
        ListFieldNames := zDbViewProps.Columns.ComboColumns(DataSet, 10);

      if not ListFieldNames.isEmpty then
        LookupComboBoxProperties.ListFieldNames := ListFieldNames;
    except
      on e: exception do
      begin
        // record index out of range su MetodoDeterminazioneRicavi di Progetti
        siDX.LogString('Errore attribuzione ListFieldNames', ListFieldNames);
        siDX.LogException(e);
      end;
    end;

    for I := 0 to LookupComboBoxProperties.ListColumns.Count - 1 do
    begin
      Column := LookupComboBoxProperties.ListColumns[I];
      zColumn := zDbViewProps.Columns.Get(Column.FieldName, false);

      if Assigned(zColumn) then
      begin
        if zColumn.Caption <> '' then
          Column.Caption := zColumn.Caption;

        if zColumn.Width <> -1 then
          Column.Width := zColumn.Width
        else
        begin
          if Assigned(Column.Field) then
            Column.Width := dx.FieldSize(Column.Field) * TextWidth
          else
            Column.Width := 50;
        end;
      end
    end;
  finally
    FreeAndNil(zDbViewProps);
  end;

  //
  // if false then
  if LookupComboBoxProperties.ListColumns.Count = 0 then
    for Field in DataSet.Fields do
      if LookupComboBoxProperties.ListColumns.Count < 3 then
      begin
        Column := LookupComboBoxProperties.ListColumns.Add;
        Column.FieldName := Field.Name;
        Column.Caption := Field.DisplayLabel;
        Column.Width := dx.FieldSize(Field) * TextWidth;
      end;
end;

procedure Tdx.InitPivot(pivot: TcxDBPivotGrid);
begin
  Assert(Assigned(pivot));

  pivot.BorderStyle := cxcbsNone;
  pivot.LookAndFeel.Kind := lfUltraFlat; // era lfFlat
  pivot.LookAndFeel.NativeStyle := false;

  pivot.Styles.Content := cxStyleContent;
  pivot.Styles.Background := cxStyleContent;

  pivot.Styles.FieldHeader := cxStyleHeader;
  pivot.Styles.ColumnHeader := cxStyleHeader;
  pivot.Styles.RowHeader := cxStyleHeader;
  pivot.Styles.DataHeaderArea := cxStyleHeader;
  pivot.Styles.HeaderBackground := cxStyleHeaderBackground;

  pivot.Styles.Selected := cxStyleHighlight;

  // pivot.Styles.Inactive = styleIndaco
  // pivot.Styles.Prefilter = styleIndaco
end;

procedure Tdx.RegisterCustomStyle(Style: TcxStyle; BaseStyle: TcxStyle; AssignedValues: TcxStyleValues);
var
  CustomStyle: TCustomStyle;
begin
  CustomStyle := TCustomStyle.Create;
  CustomStyles.Add(CustomStyle);

  CustomStyle.Style := Style;
  CustomStyle.BaseStyle := BaseStyle;
  CustomStyle.AssignedValues := AssignedValues;
  CustomStyle.UpdateCustomStyle;
end;

procedure Tdx.UnregisterCustomStyle(Style: TcxStyle);
var
  CustomStyle: TCustomStyle;
  I: integer;
begin
  for I := 0 to CustomStyles.Count - 1 do
  begin
    CustomStyle := CustomStyles[I];

    if CustomStyle.Style = Style then
    begin
      CustomStyles.Delete(I);
      Break;
    end;
  end;
end;

procedure Tdx.UpdateCustomStyles;
var
  CustomStyle: TCustomStyle;
begin
  for CustomStyle in CustomStyles do
    CustomStyle.UpdateCustomStyle;
end;

procedure Tdx.doDrawBandSeparator(ACanvas: TcxCanvas; r: TRect);
var
  Color: TColor;
begin
  Color := GetColor(ckSeparator);
  ACanvas.DrawComplexFrame(r, Color, Color, [bRight], 2);
end;

procedure Tdx.DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListBandHeaderCellViewInfo; var ADone: boolean);
// var
// Band: TcxTreeListBand;
// Column: TcxTreeListColumn;
// r: TRect;
begin
  // SEPARATORE DI BAND HEADER

  if Assigned(AViewInfo.ViewParams.Font) then
    cxApplyViewParams(ACanvas, AViewInfo.ViewParams);

  ACanvas.FillRect(AViewInfo.BoundsRect);

  if not VarIsNull(AViewInfo.Text) then // to prevent runtime-errors
    ACanvas.DrawText(AViewInfo.Text, AViewInfo.TextBounds, AViewInfo.Band.Caption.AlignHorz, AViewInfo.Band.Caption.AlignVert, not AViewInfo.Band.Caption.ShowEndEllipsis, AViewInfo.Band.Caption.ShowEndEllipsis);

  doDrawBandSeparator(ACanvas, AViewInfo.BoundsRect);
  ADone := true;
end;

procedure Tdx.DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListColumnHeaderCellViewInfo; var ADone: boolean);
var
  Band: TcxTreeListBand;
  Color: TColor;
  Column: TcxTreeListColumn;
begin
  /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Column := TcxTreeListColumnHeaderCellViewInfo(AViewInfo).Column;
  Band := Column.Position.Band;

  if Assigned(AViewInfo.ViewParams.Font) then
    cxApplyViewParams(ACanvas, AViewInfo.ViewParams);

  ACanvas.FillRect(AViewInfo.BoundsRect);

  if not VarIsNull(AViewInfo.Text) then // to prevent runtime-errors
    ACanvas.DrawText(AViewInfo.Text, AViewInfo.TextBounds, Column.Caption.AlignHorz, Column.Caption.AlignVert, not Column.Caption.ShowEndEllipsis, Column.Caption.ShowEndEllipsis);

  if (Band.Columns[Band.ColumnCount - 1] = Column) and (Column.ItemIndex <> tree.ColumnCount - 1) then
  begin
    doDrawBandSeparator(ACanvas, AViewInfo.BoundsRect);
    ADone := true;
  end;
end;

procedure Tdx.DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: boolean);
var
  Band: TcxTreeListBand;
  canvasColor: TColor;
  Column: TcxTreeListColumn;
begin
  /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Column := AViewInfo.Column;
  Band := Column.Position.Band;

  if (Band.Columns[Band.ColumnCount - 1] = Column) and (Column.ItemIndex <> tree.ColumnCount - 1) then
  begin
    // AViewInfo.ViewParams pu� sovrascrivere alla cavolo il colore del canvas
    // canvasColor := ACanvas.Brush.Color;
    //
    // if Assigned(AViewInfo.ViewParams.Font) then
    // cxApplyViewParams(ACanvas, AViewInfo.ViewParams);
    //
    // ACanvas.FillRect(AViewInfo.BoundsRect, canvasColor);
    //
    // if not varIsNull(AViewInfo.DisplayValue) then // to prevent runtime-errors
    // ACanvas.DrawText(AViewInfo.DisplayValue, AViewInfo.BoundsRect, 0, True);

    doDrawBandSeparator(ACanvas, AViewInfo.BoundsRect);
    ADone := true;
  end;
end;

procedure Tdx.DrawBandSeparator(tree: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListHeaderCellViewInfo; var ADone: boolean);
begin
  /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  if AViewInfo is TcxTreeListColumnHeaderCellViewInfo then
    DrawBandSeparator(tree, ACanvas, AViewInfo as TcxTreeListColumnHeaderCellViewInfo, ADone)
  else
    if AViewInfo is TcxTreeListBandHeaderCellViewInfo then
      DrawBandSeparator(tree, ACanvas, AViewInfo as TcxTreeListBandHeaderCellViewInfo, ADone);
end;

procedure Tdx.SetFilterControlFonts(FilterControl: TcxCustomFilterControl);
  procedure SetFont(Font: TFont);
  begin
    Font.Name := MediumStyleController.Style.Font.Name;
    Font.Size := MediumStyleController.Style.Font.Size;
  end;

begin
  if Assigned(FilterControl) then
  begin
    if FilterControl is TcxFilterControl then
      SetFont(TcxFilterControl(FilterControl).Font);

    SetFont(FilterControl.FontBoolOperator);
    SetFont(FilterControl.FontCondition);
    SetFont(FilterControl.FontItem);
    SetFont(FilterControl.FontValue);
  end;
end;

procedure Tdx.InitScheduler(Scheduler: TcxScheduler);
begin
  Assert(Assigned(Scheduler));

  Scheduler.OptionsView.Style := svsClassic;
  Scheduler.ViewDay.DayHeaderModernStyleDisplayMode := hdmDayAndDate;
  Scheduler.ViewDay.HeaderContainer := false;
  Scheduler.ViewDay.TimeRulerMinutes := true;

  Scheduler.Styles.Content := cxStyleContent;
  Scheduler.Styles.Event := cxStyleInfoBk;
  Scheduler.Styles.DayHeader := cxStyleBtnFace;
  Scheduler.Styles.Selection := cxStyleHighlight;
end;

procedure Tdx.InitBar(bar: TdxBar);
begin
  Assert(Assigned(bar));
  bar.AllowClose := false;
  bar.AllowCustomizing := false;
  bar.AllowQuickCustomizing := false;
  bar.AllowReset := false;
  bar.BorderStyle := bbsNone;
  bar.OneOnRow := true;
  bar.ShowMark := false;
  bar.UseRestSpace := true;
  bar.WholeRow := true;
end;

procedure Tdx.dxBarAssignPopupMenu(bar: TdxBar; dxBarPopupMenu: TdxBarPopupMenu);
begin
  Assert(Assigned(bar));
  Assert(Assigned(dxBarPopupMenu));

  if Assigned(bar.Control) then
  begin
    TdxBarControlAccess(bar.Control).Tag := NativeInt(dxBarPopupMenu);
    TdxBarControlAccess(bar.Control).OnMouseDown := dxBarMouseDown;
  end;
end;

procedure Tdx.dxBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  bar: TdxBarControlAccess;
  item: TdxBarItemControl;
  barItem: TdxBarItem;
  APoint: TPoint;
  dxBarPopupMenu: TdxBarPopupMenu;
begin
  bar := TdxBarControlAccess(Sender);
  item := bar.ItemAtPos(point(X, Y));

  if Assigned(item) then
  begin
    barItem := item.item;

    if (Button = mbRight) and Assigned(barItem) and ((barItem is TdxBarButton) or (barItem is TdxBarLargeButton)) then
    begin
      APoint := bar.ClientToScreen(point(X, Y));
      dxBarPopupMenu := TdxBarPopupMenu(bar.Tag);
      dxBarPopupMenu.Tag := NativeInt(barItem.Action);
      dxBarPopupMenu.Popup(APoint.X, APoint.Y);
      Abort;
    end;
  end;
end;

procedure Tdx.InitDateEdit(cxDateEditProperties: TcxDateEditProperties);
begin
  Assert(Assigned(cxDateEditProperties));

  cxDateEditProperties.DateButtons := cxDateEditProperties.DateButtons + [btnToday];
  cxDateEditProperties.Kind := ckDate;
  cxDateEditProperties.SaveTime := false;
  cxDateEditProperties.ShowTime := false;
  cxDateEditProperties.ShowToday := true;

  // procedure TForm1.cxDateEdit1PropertiesValidate(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: Boolean);
  // begin
  // if DisplayValue = 'TEST' then
  // begin
  // DisplayValue := '01/01/2004';
  // Error := False;
  // end;
  // end;
end;

procedure Tdx.InitPrinter(printer: TdxComponentPrinter);
begin
  // Niente clessidra gestita da ExpressPrinting: dxPSStartWait e dxPSStopWait (dxPSCore)
  // usano un contatore e un cursore salvato globali, condivisi da tutti i printer del
  // processo. Se una sola operazione lunga non si chiude, il contatore non torna a zero
  // e la clessidra resta su tutta l'applicazione fino alla chiusura (stampa del
  // contratto da Progetti, 2026-09-29). Il cursore lo gestisce chi chiama la stampa.
  printer.Options := printer.Options - [cpoShowHourGlass];

  printer.PreviewOptions.SaveZoomPosition := false;
  printer.PreviewOptions.Caption := 'Anteprima';
  printer.PreviewOptions.WindowState := wsMaximized;
  printer.PreviewOptions.Width := 800;
  printer.PreviewOptions.Width := 800;
  printer.PreviewOptions.Left := 0;
  printer.PreviewOptions.Top := 0;
end;

procedure Tdx.InitTimeEdit(cxTimeEditProperties: TcxTimeEditProperties);
begin
  Assert(Assigned(cxTimeEditProperties));

  cxTimeEditProperties.TimeFormat := tfHourMin;
  cxTimeEditProperties.SpinButtons.Position := sbpHorzRight;
end;

{ TcxCustomEditHelper }

function TcxCustomEditHelper.isEmpty: boolean;
begin
  result := VarIsNull(EditValue);
end;

function TcxCustomEditHelper.asDateTime: TDateTime;
begin
  result := 0;

  if not isEmpty then
    result := EditValue;
end;

function TcxCustomEditHelper.asDouble: double;
begin
  result := 0;

  if not isEmpty then
    result := EditValue;
end;

function TcxCustomEditHelper.asInteger: integer;
begin
  result := -1;

  if not isEmpty then
    result := EditValue;
end;

function TcxCustomEditHelper.asString: String;
begin
  result := '';

  if not isEmpty then
    result := EditValue;
end;

function zzSmartTextToDateFunc(const AText: string; var ADate: TDateTime): boolean;
var
  FormatSettings: TFormatSettings;
begin

  if AText.ToUpper = 'D' then
  begin
    ADate := Date;
    result := true;
  end
  else
    if AText.ToUpper = 'L' then
    begin
      ADate := StartOfTheWeek(Date);
      result := true;
    end
    else
    begin
      FormatSettings := TFormatSettings.Create;
      FormatSettings.DateSeparator := '.';
      result := TryStrToDateTime(AText, ADate, FormatSettings);
    end;
end;

procedure InitRegExprDateEditMask;
var
  mask: string;
  items: string;
const
  eom = '|''eom''';
begin
  items := '|' + '''D''' + '|' + '''l''';

  mask := cxFormatController.RegExprDateEditMask;
  Insert(items, mask, mask.IndexOf(eom) + eom.Length + 1);
  cxFormatController.RegExprDateEditMask := mask;
end;

function Tdx.IndiceIcona(const Nome: string): integer;
var
  Posizione: integer;
begin
  for Posizione := 0 to Immagini.Count - 1 do
    if SameText(ChangeFileExt(Immagini.GetSourceFileName(Posizione), ''), Nome) then
      Exit(Posizione);
  result := -1;
end;

// Vero se almeno una voce del menu, a qualunque livello, mostra un'icona:
// un TPopupMenu senza icone non va collegato, perche' la lista aggiunge a
// ogni voce lo spazio vuoto dell'immagine.
function MenuUsaImmagini(Voce: TMenuItem): boolean;
var
  I: integer;
begin
  for I := 0 to Voce.Count - 1 do
  begin
    if Voce.Items[I].ImageIndex >= 0 then
      Exit(true);

    if Assigned(Voce.Items[I].Action) and (Voce.Items[I].Action is TCustomAction) then
      if TCustomAction(Voce.Items[I].Action).ImageIndex >= 0 then
        Exit(true);

    if MenuUsaImmagini(Voce.Items[I]) then
      Exit(true);
  end;
  result := false;
end;

function BarManagerUsaImmaginiGrandi(BarManager: TdxBarManager): boolean;
var
  I: integer;
begin
  for I := 0 to BarManager.ItemCount - 1 do
    if BarManager.Items[I] is TdxBarLargeButton then
      if TdxBarLargeButton(BarManager.Items[I]).LargeImageIndex >= 0 then
        Exit(true);
  result := false;
end;

procedure Tdx.AgganciaImmagini(Radice: TComponent);
var
  I: integer;
  Componente: TComponent;
  BarManager: TdxBarManager;
begin
  if not Assigned(Radice) then
    Exit;

  // nel designer il riferimento lo gestisce l'IDE: assegnarlo qui lo
  // scriverebbe nel DFM al primo salvataggio, con zDX aperto o no
  if csDesigning in Radice.ComponentState then
    Exit;

  for I := 0 to Radice.ComponentCount - 1 do
  begin
    Componente := Radice.Components[I];

    if Componente is TCustomActionList then
    begin
      if not Assigned(TCustomActionList(Componente).Images) then
        TCustomActionList(Componente).Images := Immagini;
    end
    else if Componente is TdxBarManager then
    begin
      BarManager := TdxBarManager(Componente);

      if not Assigned(BarManager.ImageOptions.Images) then
        BarManager.ImageOptions.Images := Immagini;

      // LargeImages solo se qualche pulsante grande ha un LargeImageIndex: con
      // la lista assegnata il pulsante grande legge LargeImageIndex al posto di
      // ImageIndex, e senza indice resterebbe senza icona
      if not Assigned(BarManager.ImageOptions.LargeImages) then
        if BarManagerUsaImmaginiGrandi(BarManager) then
          BarManager.ImageOptions.LargeImages := Immagini;
    end
    else if Componente is TdxBarPopupMenu then
    begin
      if not Assigned(TdxBarPopupMenu(Componente).Images) then
        TdxBarPopupMenu(Componente).Images := Immagini;
    end
    else if Componente is TdxRibbonGalleryGroup then
    begin
      if not Assigned(TdxRibbonGalleryGroup(Componente).Options.Images) then
        TdxRibbonGalleryGroup(Componente).Options.Images := Immagini;
    end
    else if Componente is TPopupMenu then
    begin
      if not Assigned(TPopupMenu(Componente).Images) then
        if MenuUsaImmagini(TPopupMenu(Componente).Items) then
          TPopupMenu(Componente).Images := Immagini;
    end;
  end;
end;

function Tdx.BlendColor(AColor1, AColor2: TColor; APercentage: integer): TColor;
var
  R1, G1, B1, R2, G2, B2: Byte;
begin
  if APercentage < 0 then
    APercentage := 0;
  if APercentage > 100 then
    APercentage := 100;

  AColor1 := ColorToRGB(AColor1);
  AColor2 := ColorToRGB(AColor2);

  R1 := GetRValue(AColor1);
  G1 := GetGValue(AColor1);
  B1 := GetBValue(AColor1);
  R2 := GetRValue(AColor2);
  G2 := GetGValue(AColor2);
  B2 := GetBValue(AColor2);

  result := RGB(R1 + MulDiv(R2 - R1, APercentage, 100), G1 + MulDiv(G2 - G1, APercentage, 100), B1 + MulDiv(B2 - B1, APercentage, 100));
end;

// Luminanza relativa delle WCAG 2.x, da 0 (nero) a 1 (bianco): pesa i canali
// come li percepisce l'occhio, dopo aver tolto la correzione gamma di sRGB
function LuminanzaRelativa(Colore: TColor): double;

  function Canale(Valore: byte): double;
  begin
    result := Valore / 255;

    if result <= 0.03928 then
      result := result / 12.92
    else
      result := Power((result + 0.055) / 1.055, 2.4);
  end;

begin
  Colore := ColorToRGB(Colore);
  result := 0.2126 * Canale(GetRValue(Colore)) + 0.7152 * Canale(GetGValue(Colore)) + 0.0722 * Canale(GetBValue(Colore));
end;

// Rapporto di contrasto delle WCAG, da 1 (uguali) a 21 (nero su bianco)
function RapportoContrasto(Colore1, Colore2: TColor): double;
var
  Chiaro, Scuro: double;
begin
  Chiaro := LuminanzaRelativa(Colore1);
  Scuro := LuminanzaRelativa(Colore2);

  if Chiaro < Scuro then
    result := (Scuro + 0.05) / (Chiaro + 0.05)
  else
    result := (Chiaro + 0.05) / (Scuro + 0.05);
end;

const
  ContrastoMinimoTesto = 4.5;

function SfondoContenuto(Sfondo: TColor): TColor;
begin
  if Sfondo = clDefault then
    result := RootLookAndFeel.Painter.DefaultContentColor
  else
    result := Sfondo;
end;

function SkinScura: boolean;
var
  Sfondo: TColor;
begin
  // scuro = il bianco ci si legge sopra meglio del nero
  Sfondo := SfondoContenuto(clDefault);
  result := RapportoContrasto(Sfondo, clWhite) > RapportoContrasto(Sfondo, clBlack);
end;

function ColorePalette(const Nome: string; Predefinito: TColor): TColor;
var
  Painter: TcxCustomLookAndFeelPainter;
  SkinInfo: TdxSkinInfo;
  Voce: TdxSkinColor;
begin
  result := Predefinito;

  Painter := RootLookAndFeel.SkinPainter;

  if Assigned(Painter) and Painter.GetPainterData(SkinInfo) and Assigned(SkinInfo.Skin) and Assigned(SkinInfo.Skin.ActiveColorPalette) then
    if SkinInfo.Skin.ActiveColorPalette.Find(Nome, Voce) and (Voce.Value <> clNone) and (Voce.Value <> clDefault) then
      result := Voce.Value;
end;

function ColoreLeggibile(Colore: TColor; Sfondo: TColor): TColor;
var
  Verso: TColor;
  Percentuale: integer;

  // come Tdx.BlendColor, che pero' chiede il modulo creato
  function Mescola(Colore1, Colore2: TColor; Quota: integer): TColor;
  begin
    Colore1 := ColorToRGB(Colore1);
    Colore2 := ColorToRGB(Colore2);
    result := RGB(
      GetRValue(Colore1) + MulDiv(GetRValue(Colore2) - GetRValue(Colore1), Quota, 100),
      GetGValue(Colore1) + MulDiv(GetGValue(Colore2) - GetGValue(Colore1), Quota, 100),
      GetBValue(Colore1) + MulDiv(GetBValue(Colore2) - GetBValue(Colore1), Quota, 100));
  end;

begin
  Sfondo := SfondoContenuto(Sfondo);
  result := ColorToRGB(Colore);

  if RapportoContrasto(result, Sfondo) >= ContrastoMinimoTesto then
    Exit;

  // verso il bianco su fondo scuro, verso il nero su fondo chiaro: a passi del
  // 10% la tinta resta riconoscibile e ci si ferma al primo passo leggibile
  if RapportoContrasto(Sfondo, clWhite) > RapportoContrasto(Sfondo, clBlack) then
    Verso := clWhite
  else
    Verso := clBlack;

  for Percentuale := 1 to 10 do
  begin
    result := Mescola(Colore, Verso, Percentuale * 10);

    if RapportoContrasto(result, Sfondo) >= ContrastoMinimoTesto then
      Exit;
  end;
end;

function ColoreSuSkin(const NomePalette: string; Predefinito: TColor; Sfondo: TColor): TColor;
begin
  result := ColoreLeggibile(ColorePalette(NomePalette, Predefinito), Sfondo);
end;

function Tdx.dxBarRequiredWidth(bar: TdxBar): integer;
var
  I: integer;
begin
  result := 0;

  try
    if Assigned(bar) then
      if Assigned(bar.Control) then
      begin

        // in caso di controlli non ancora creati
        for I := 0 to bar.ItemLinks.VisibleItemCount - 1 do
          if bar.ItemLinks.VisibleItems[I].Control = nil then
          begin
            result := bar.Control.Width;
            Exit;
          end;

        result := TdxBarControlAccess(bar.Control).GetMaxWidth(dsTop);
      end;
  except
  end;
end;

procedure Tdx.dxSpellCheckerCheckAsYouTypePopup(ASender: TdxCustomSpellChecker; APopupMenu: TComponent; var AHandled: boolean);
begin
  simain.LogVerbose(APopupMenu.ClassName);
  // dxSpellChecker.CheckAsYouTypeManager.CreateItems(
end;

procedure Tdx.InitStyleTreeListInactive;
var
  Painter: TcxCustomLookAndFeelPainter;
begin
  Painter := RootLookAndFeel.Painter;

  if SkinActive then
    Painter := RootLookAndFeel.SkinPainter;

  if Assigned(Painter) then
  begin
    cxStyleTreeListInactive.Color := Painter.DefaultSelectionColor;
    cxStyleTreeListInactive.TextColor := Painter.DefaultSelectionTextColor;
  end;
end;

procedure Tdx.LookupGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: boolean);
begin
  AAllow := LookupGridViewAllowSelect(Sender, true);
end;

procedure Tdx.LookupGridViewCanSelectRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: boolean);
begin
  AAllow := LookupGridViewAllowSelect(Sender, true);
end;

procedure Tdx.LookupGridViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: boolean);
begin
  LookupGridViewSetAllowSelect(Sender, false);
end;

procedure Tdx.LookupGridViewSelectionChanged(Sender: TcxCustomGridTableView);
begin

  if Sender.Controller.SelectedRecordCount > 0 then
    LookupGridViewSetAllowSelect(Sender, false)
  else
    LookupGridViewSetAllowSelect(Sender, true);
end;

function Tdx.LookupGridViewAllowSelect(cxCustomGridTableView: TcxCustomGridTableView; DefaultValue: boolean): boolean;
begin
  result := DefaultValue;

  if TObject(cxCustomGridTableView.Tag) is TLookupViewProps then
    result := TLookupViewProps(cxCustomGridTableView.Tag).AllowSelect;
end;

procedure Tdx.LookupGridViewSetAllowSelect(cxCustomGridTableView: TcxCustomGridTableView; Value: boolean);
begin

  if TObject(cxCustomGridTableView.Tag) is TLookupViewProps then
    TLookupViewProps(cxCustomGridTableView.Tag).AllowSelect := Value;
end;

function Tdx.LookupGridViewAllowApplyBestFit(cxCustomGridTableView: TcxCustomGridTableView; DefaultValue: boolean): boolean;
begin
  result := DefaultValue;

  try
    if TObject(cxCustomGridTableView.Tag) is TLookupViewProps then
      result := TLookupViewProps(cxCustomGridTableView.Tag).AllowApplyBestFit;
  except
  end;
end;

procedure Tdx.LookupGridViewSetAllowApplyBestFit(cxCustomGridTableView: TcxCustomGridTableView; Value: boolean);
begin

  if TObject(cxCustomGridTableView.Tag) is TLookupViewProps then
    TLookupViewProps(cxCustomGridTableView.Tag).AllowApplyBestFit := Value;
end;

// procedure Tdx.LookupInitPopup(Sender: TObject);
// var
// cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox;
// begin
// // Chiama ApplyBestFit
// if Sender is TcxCustomExtLookupComboBox then
// begin
// cxCustomExtLookupComboBox := TcxCustomExtLookupComboBox(Sender);
//
// if cxCustomExtLookupComboBox.ActiveProperties.View <> nil then
// begin
// cxCustomExtLookupComboBox.ActiveProperties.View.Tag := 0; // per canSelect
//
// TThread.ForceQueue(nil,
// procedure
// var
// I: integer;
// cxGridDBTableView: TcxGridDBTableView;
// Column: TcxGridDBColumn;
// begin
//
// cxGridDBTableView := TcxGridDBTableView(cxCustomExtLookupComboBox.ActiveProperties.View);
// cxGridDBTableView.OptionsBehavior.BestFitMaxRecordCount := cxCustomExtLookupComboBox.ActiveProperties.DropDownRows;
//
// if VarIsNull(cxCustomExtLookupComboBox.EditValue) then
// cxGridDBTableView.OptionsBehavior.BestFitMaxRecordCount := 1;
//
// cxGridDBTableView.ApplyBestFit();
//
// for I := 0 to cxGridDBTableView.ColumnCount - 1 do
// begin
// Column := cxGridDBTableView.Columns[I];
// Column.MinWidth := System.Math.Max(Column.MinWidth, Column.Width);
// end;
//
// cxGridDBTableView.ApplyBestFit();
// TcxCustomDropDownEditAccess(cxCustomExtLookupComboBox).UpdatePopupWindow;
// end, 10);
// end;
// end;
// end;

// Mantis #151 - 2026-09-21: registra il popup appena aperto e restituisce il numero di
// generazione da confrontare nelle callback differite. Ogni nuova apertura, ogni chiusura e la
// distruzione del controllo incrementano il contatore, cosi' le callback gia' accodate per il
// popup precedente si riconoscono come scadute e non fanno nulla.
function Tdx.LookupPopupRegistra(cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox): integer;
begin
  if Assigned(FLookupPopupComboBox) and (FLookupPopupComboBox <> cxCustomExtLookupComboBox) then
    FLookupPopupComboBox.RemoveFreeNotification(Self);

  Inc(FLookupPopupGenerazione);
  FLookupPopupComboBox := cxCustomExtLookupComboBox;

  // se il controllo viene distrutto prima che scada il rinvio, Notification azzera il riferimento
  FLookupPopupComboBox.FreeNotification(Self);

  result := FLookupPopupGenerazione;
end;

// Mantis #151 - 2026-09-21: invalida le callback differite ancora pendenti
procedure Tdx.LookupPopupDimentica;
begin
  Inc(FLookupPopupGenerazione);

  if Assigned(FLookupPopupComboBox) then
  begin
    FLookupPopupComboBox.RemoveFreeNotification(Self);
    FLookupPopupComboBox := nil;
  end;
end;

// Mantis #151 - 2026-09-21: vero solo se il popup registrato con quella generazione e' ancora
// quello aperto, il controllo esiste e la sua view e' valida
function Tdx.LookupPopupAncoraValido(Generazione: integer): boolean;
begin
  result := false;

  if Generazione <> FLookupPopupGenerazione then
    Exit;

  if not Assigned(FLookupPopupComboBox) then
    Exit;

  if not FLookupPopupComboBox.DroppedDown then
    Exit;

  result := Assigned(FLookupPopupComboBox.ActiveProperties.View);
end;

// Se RAD Studio salva zDX.dfm con lo schermo a una scala diversa dal 100% (succede anche
// lavorando da desktop remoto) scrive nel modulo dati PixelsPerInch = 192 o simili.
// TcxScalableComponent.Loaded, che la RTL chiama subito dopo ReadState e quindi prima del
// corpo di Create, prende quel valore come scala di cxStyleRepository, degli StyleController
// e delle liste di aspetto; TcxStyles.GetActualFont divide poi i font di griglie, pivot e
// alberi per quella scala, e le scritte escono dimezzate (2026-10-14).
// Azzerato qui, DevExpress usa i DPI di sistema, come quando il DFM non ha la riga.
procedure Tdx.ReadState(Reader: TReader);
begin
  inherited;
  if (PixelsPerInch <> 0) and not(csDesigning in ComponentState) then
  begin
    siDX.LogWarning('zDX.dfm salvato con PixelsPerInch = %d: ignorato, si usano i DPI di sistema', [PixelsPerInch]);
    PixelsPerInch := 0;
  end;
end;

// Mantis #151 - 2026-09-21: la form dei parametri puo' essere chiusa mentre il rinvio di 100 ms e'
// ancora pendente (conferma di "Elabora" con il popup lookup aperto); senza questo aggancio la
// callback ridereferenziava un controllo gia' distrutto
procedure Tdx.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FLookupPopupComboBox) then
  begin
    FLookupPopupComboBox := nil;
    Inc(FLookupPopupGenerazione);
  end;
end;

// Agganciato a OnPopup, non a OnInitPopup: OnInitPopup scatta prima che la view venga messa nella
// griglia del popup (TcxCustomDropDownEdit.DoInitPopup chiama ILookupData.DropDown dopo l'evento),
// quindi li' non c'e' niente da misurare. OnPopup scatta in PopupWindowShowed, dopo
// PositionPopupWindowChildren: la view e' agganciata, la griglia ha le sue misure e la finestra non
// ha ancora ricevuto il primo WM_PAINT.
procedure Tdx.LookupInitPopup(Sender: TObject);
var
  cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox;
  cxGridDBTableView: TcxGridDBTableView;
  BestFitMaxRecordCount: integer;
  I: integer;
begin
  if not(Sender is TcxCustomExtLookupComboBox) then
    Exit;

  cxCustomExtLookupComboBox := TcxCustomExtLookupComboBox(Sender);

  if cxCustomExtLookupComboBox.ActiveProperties.View = nil then
    Exit;

  cxGridDBTableView := TcxGridDBTableView(cxCustomExtLookupComboBox.ActiveProperties.View);

  LookupGridViewSetAllowSelect(cxGridDBTableView, true);
  LookupGridViewSetAllowApplyBestFit(cxGridDBTableView, true);

  // la registrazione serve ancora alle callback differite di LookupFocusedRecordChanged e a LookupCloseUp
  LookupPopupRegistra(cxCustomExtLookupComboBox);

  // 2026-10-05: larghezze e posizione si calcolano subito, non piu' con un rinvio di 100 ms.
  // Il rinvio era nato quando il gestore stava su OnInitPopup; su OnPopup faceva solo disegnare il
  // popup a sinistra e alla larghezza del combo, per poi spostarlo e allargarlo un istante dopo.
  cxGridDBTableView.OnFocusedRecordChanged := LookupFocusedRecordChanged;

  BestFitMaxRecordCount := cxCustomExtLookupComboBox.ActiveProperties.DropDownRows;

  if VarIsNull(cxCustomExtLookupComboBox.EditValue) then
    BestFitMaxRecordCount := 1;

  for I := 0 to cxGridDBTableView.ColumnCount - 1 do
    cxGridDBTableView.Columns[I].MinWidth := 20;

  LookupApplyBestFit(cxGridDBTableView, BestFitMaxRecordCount);
end;

procedure Tdx.LookupCloseUp(Sender: TObject);
var
  cxCustomExtLookupComboBox: TcxCustomExtLookupComboBox;
  cxGridDBTableView: TcxGridDBTableView;
begin
  // rimuove l'evento OnFocusedRecordChanged dalla view legata al Lookup
  // Mantis #151 - 2026-09-21: la view puo' essere gia' nil, e la chiusura del popup deve
  // invalidare le callback differite ancora pendenti
  if not(Sender is TcxCustomExtLookupComboBox) then
    Exit;

  cxCustomExtLookupComboBox := TcxCustomExtLookupComboBox(Sender);

  cxGridDBTableView := TcxGridDBTableView(cxCustomExtLookupComboBox.ActiveProperties.View);

  if Assigned(cxGridDBTableView) then
    cxGridDBTableView.OnFocusedRecordChanged := nil;

  if FLookupPopupComboBox = cxCustomExtLookupComboBox then
    LookupPopupDimentica;
end;

procedure Tdx.LookupFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: boolean);
var
  Generazione: integer;
begin

  if LookupGridViewAllowApplyBestFit(Sender, false) then
  begin
    simain.LogVerbose('cxGridViewRepositoryDBTableView1FocusedRecordChanged');

    // Mantis #151 - 2026-09-21: stesso difetto della callback di LookupInitPopup, la view veniva
    // ridereferenziata anche dopo la chiusura del popup o la distruzione della form che la possiede
    Generazione := FLookupPopupGenerazione;

    TThread.ForceQueue(nil,
      procedure
      begin
        if not LookupPopupAncoraValido(Generazione) then
          Exit;

        if TObject(FLookupPopupComboBox.ActiveProperties.View) <> TObject(Sender) then
          Exit;

        LookupApplyBestFit(TcxGridDBTableView(Sender), -1);
      end, 30);
  end;
end;

procedure Tdx.LookupApplyBestFit(cxGridDBTableView: TcxGridDBTableView; BestFitMaxRecordCount: integer);
var
  I: integer;
  Column: TcxGridDBColumn;
  l: integer;
  oldShowHourglassCursor: boolean;
  Popup: TcxCustomEditPopupWindowAccess;
  w: integer;
  h: integer;
  t: integer;
begin

  if not LookupGridViewAllowApplyBestFit(cxGridDBTableView, false) then
    Exit;

  if Assigned(cxGridDBTableView.Site) then
    if Assigned(GetParentForm(cxGridDBTableView.Site)) then
    begin
      Popup := TcxCustomEditPopupWindowAccess(GetParentForm(cxGridDBTableView.Site));

      LookupGridViewSetAllowApplyBestFit(cxGridDBTableView, false);
      try
        cxGridDBTableView.OptionsBehavior.BestFitMaxRecordCount := Max(BestFitMaxRecordCount, cxGridDBTableView.ViewInfo.VisibleRecordCount);

        oldShowHourglassCursor := cxGridDBTableView.OptionsBehavior.ShowHourglassCursor;
        cxGridDBTableView.OptionsBehavior.ShowHourglassCursor := false;
        try
          cxGridDBTableView.ApplyBestFit();
        finally
          cxGridDBTableView.OptionsBehavior.ShowHourglassCursor := oldShowHourglassCursor;
        end;

        // evita che possa diminuire la larghezza della form
        for I := 0 to cxGridDBTableView.ColumnCount - 1 do
        begin
          Column := cxGridDBTableView.Columns[I];
          Column.MinWidth := System.Math.Max(Column.MinWidth, Column.Width);
        end;

        // calcolo larghezza necessaria
        w := cxGridDBTableView.ViewInfo.HeaderViewInfo.Width + TcxGridAccess(cxGridDBTableView.Site).VScrollBar.Width + 3;

        // nei wizard viene sparato tutto a sx
        l := Popup.Left;

        // 2026-10-05: diagnostica della sinistra a 0. DevExpress porta la X a 0 lasciando giusta la Y
        // solo in CorrectBoundsWithMonitorWorkArea, quando la sinistra del combo sullo schermo e' <= 0
        // oppure quando il popup e' largo almeno quanto il monitor: queste righe dicono quale dei due
        begin
          var
            SinistraCombo: TPoint;
          var
            AreaLavoro: TRect;

          SinistraCombo := Popup.Edit.Parent.ClientToScreen(point(Popup.Edit.Left, Popup.Edit.Top));
          AreaLavoro := Screen.MonitorFromRect(Popup.BoundsRect).WorkareaRect;

          simain.LogVerbose(Format('LookupApplyBestFit posizione: Popup=(%d,%d %dx%d) Combo=(%d,%d) AreaLavoro=(%d,%d,%d,%d) LarghezzaCalcolata=%d',
            [Popup.Left, Popup.Top, Popup.Width, Popup.Height, SinistraCombo.X, SinistraCombo.Y,
            AreaLavoro.Left, AreaLavoro.Top, AreaLavoro.Right, AreaLavoro.Bottom, w]));
        end;

        if l = 0 then
        begin
          var
            pt: TPoint;

          pt := Popup.Edit.Parent.ClientToScreen(point(Popup.Edit.Left, Popup.Edit.Top));
          l := pt.X;
        end;

        w := Max(w, Popup.Edit.Width); // evita che sia pi� stretto del combo. Ad esempio ResgistroStudenti.IdProgetto

        // Mantis #303 - 2026-10-30: prima l'altezza restava quella del popup, e CanResize di DevExpress,
        // al cambio di larghezza, la riportava a un valore vicino che poteva tagliare l'ultima riga
        // (2 corsi in 93 px, il secondo visibile a meta'). Quando il mouse evidenziava la riga tagliata
        // la griglia la portava in vista e la prima usciva dall'alto. Ora l'altezza si calcola su righe
        // intere, min(record, DropDownRows), e LockCheckSize impedisce a CanResize di arrotondarla
        h := Popup.Height;
        t := Popup.Top;
        if Popup.Edit is TcxCustomExtLookupComboBox then
        begin
          var
            Righe: integer;
          var
            AltoCombo: integer;

          Righe := Min(cxGridDBTableView.DataController.RecordCount, TcxCustomExtLookupComboBox(Popup.Edit).ActiveProperties.DropDownRows);
          Righe := Max(Righe, 1);

          // GetPopupHeight e' l'altezza della griglia; la differenza col popup sono bordi e maniglia
          h := cxGridDBTableView.ViewInfo.GetPopupHeight(Righe) + (Popup.Height - cxGridDBTableView.Control.Height);

          if TcxGridAccess(cxGridDBTableView.Site).HScrollBar.Visible then
            h := h + TcxGridAccess(cxGridDBTableView.Site).HScrollBar.Height;

          simain.LogVerbose(Format('LookupApplyBestFit altezza: Righe=%d AltezzaPopup=%d AltezzaGriglia=%d AltezzaCalcolata=%d',
            [Righe, Popup.Height, cxGridDBTableView.Control.Height, h]));

          // se il popup si apre sopra il combo, il bordo inferiore resta attaccato al combo
          AltoCombo := Popup.Edit.Parent.ClientToScreen(point(Popup.Edit.Left, Popup.Edit.Top)).Y;
          if Popup.Top < AltoCombo then
            t := Popup.Top + Popup.Height - h;
        end;

        Popup.LockCheckSize;
        try
          Popup.ResizePopupWindow(l, t, w, h);
        finally
          Popup.UnLockCheckSize;
        end;
      finally
        LookupGridViewSetAllowApplyBestFit(cxGridDBTableView, true);
      end;
    end;
end;

function Tdx.RibbonColorSchemeName: string;
begin
  result := '';

  if SkinActive then
    result := 'UserSkin'
  else
    result := 'White';
end;

// Carica il dizionario italiano, se c'e'.
//
// I DUE FILE NON SONO NEL PROGRAMMA. Sono il dizionario Hunspell italiano --
// it_IT.aff (le regole di formazione delle parole) e it_IT.dic (le parole) --
// e vanno copiati accanto all'eseguibile. Senza, il correttore resta spento:
// non e' un guasto, e' materiale che manca.
//
// Fino al 2026-09-24 l'assenza non si vedeva in nessun modo. Ora resta
// scritta in CorrettoreAttivo e CorrettoreMotivo, perche' "non mi segna gli
// errori di ortografia" e' una domanda che si fa a voce e a cui nessuno
// sapeva rispondere senza andare a leggere questo codice.
procedure Tdx.InitSpellChecker(const UserFolder: string);
var
  item: TdxSpellCheckerDictionaryItem;
  AppFolder: string;
  GrammarPath, DictionaryPath: string;
begin
  dxSpellChecker.AutoLoadDictionaries := false;
  dxSpellChecker.DictionaryItems.Clear;

  FCorrettoreAttivo := false;
  FCorrettoreMotivo := '';

  // DevExpress T1337558 - 2026-11-06: DISATTIVAZIONE TEMPORANEA DEL CORRETTORE.
  // Con DevExpress 26.1.5 e 26.1.6 il TdxRichEditControl si blocca o va in
  // access violation (TdxAlgorithms1<TdxUncheckedInterval>.BinarySearch, nel
  // thread di impaginazione) quando c'e' un TdxSpellChecker con il controllo
  // mentre si scrive: il RichEdit si aggancia da solo al correttore attraverso
  // l'adattatore registrato da dxRichEdit.Control.SpellChecker.
  // Corretto da DevExpress nella 26.1.7: dopo l'aggiornamento togliere questo
  // blocco fino alla riga "FINE T1337558" e rimettere
  // CheckAsYouTypeOptions.Active a True (e' il valore di zDX.dfm).
  dxSpellChecker.CheckAsYouTypeOptions.Active := false;
  FCorrettoreMotivo := 'Correttore ortografico spento temporaneamente per un ' +
    'difetto di DevExpress 26.1.6 (T1337558): torna attivo con la 26.1.7.';
  Exit;
  // FINE T1337558

  AppFolder := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
  GrammarPath := AppFolder + 'it_IT.aff';
  DictionaryPath := AppFolder + 'it_IT.dic';

  if not FileExists(GrammarPath) then
    FCorrettoreMotivo := 'Manca il file delle regole ' + GrammarPath
  else if not FileExists(DictionaryPath) then
    FCorrettoreMotivo := 'Manca il file delle parole ' + DictionaryPath;

  if FCorrettoreMotivo <> '' then
  begin
    FCorrettoreMotivo := FCorrettoreMotivo + '. Il correttore ortografico ' +
      'resta spento: i due file del dizionario italiano vanno copiati ' +
      'accanto all''eseguibile.';
    Exit;
  end;

  // IT
  if FileExists(GrammarPath) then
    if FileExists(DictionaryPath) then
    begin
      item := dxSpellChecker.DictionaryItems.Add;
      item.DictionaryTypeClass := TdxHunspellDictionary;
      TdxHunspellDictionary(item.DictionaryType).GrammarPath := AppFolder + 'it_IT.aff';
      TdxHunspellDictionary(item.DictionaryType).DictionaryPath := AppFolder + 'it_IT.dic';
      item.DictionaryType.Language := 1040;
      item.DictionaryType.Load(dlmDirectLoad);

      // User dict
      item := dxSpellChecker.DictionaryItems.Add;
      item.DictionaryTypeClass := TdxUserSpellCheckerDictionary;

      if UserFolder.isEmpty then
        TdxUserSpellCheckerDictionary(item.DictionaryType).DictionaryPath := AppFolder + 'User.dic'
      else
        TdxUserSpellCheckerDictionary(item.DictionaryType).DictionaryPath := IncludeTrailingBackslash(UserFolder) + 'User.dic';
      item.DictionaryType.Load(dlmDirectLoad);

      //
      dxSpellChecker.AutoLoadDictionaries := true;
      dxSpellChecker.LoadDictionaries();

      FCorrettoreAttivo := true;
    end;
end;

procedure Tdx.ShowSpellingOptionsDialog;
begin
  dxShowSpellingOptionsDialog(dxSpellChecker, dxSpellChecker.DialogLookAndFeel);
end;

procedure Tdx.PrepareSpellCheckerPopup(point: TPoint; Popup: TPopupMenu);
var
  CheckAsYouTypeManager: TdxSpellCheckerCheckAsYouTypeManager;
begin
  Assert(Assigned(Popup));

  CheckAsYouTypeManager := TdxSpellCheckerCheckAsYouTypeManager(TdxSpellCheckerAccess(dxSpellChecker).CheckAsYouTypeManager);

  if TdxSpellCheckerCheckAsYouTypeManagerAccess(CheckAsYouTypeManager).CanPopup(point) then
    TdxSpellCheckerCheckAsYouTypeManagerAccess(CheckAsYouTypeManager).CreateItems(Popup, Popup);
end;

procedure Tdx.ProgressBarEditValueChanged(Sender: TObject);
var
  ProgressBar: TcxCustomProgressBar;
  s: string;
begin
  // Di default forza la percentuale visualizzata a Min(Value, 100)
  // In questo modo visualizza il reale valore [es. per i budget

  ProgressBar := Sender as TcxCustomProgressBar;

  if VarIsNull(ProgressBar.EditValue) then
    s := '0'
  else
    s := ProgressBar.EditValue;

  s := s + '%';

  ProgressBar.Properties.Text := s + '%';
end;

function Tdx.GetBarColor: TColor;
var
  dxSkinInfo: TdxSkinInfo;
begin
  result := clDefault;

  dxSkinInfo := GetSkinInfo;

  if Assigned(dxSkinInfo) then
    result := dxSkinInfo.Dock.Color
  else
    result := clWindow;
end;

procedure Tdx.dxLayoutControlGetItemStoredProperties(Sender: TdxCustomLayoutControl; AItem: TdxCustomLayoutItem; AProperties: TStrings);
begin

  if AItem is TdxLayoutItem then
  begin
    AProperties.Add('ImageIndex');
    AProperties.Add('VisibleElements');
  end
  else
    if AItem is TdxLayoutLabeledItem then
    begin
      AProperties.Add('ImageIndex');
      AProperties.Add('VisibleElements');
    end
    else
      if AItem is TdxLayoutGroup then
      begin
        AProperties.Add('LookAndFeel');
        AProperties.Add('LayoutLookAndFeel');
        AProperties.Add('HideTabs');
        AProperties.Add('ImageIndex');
        AProperties.Add('VisibleElements');
        AProperties.Add('ScrollOptionsHorizontal');
        AProperties.Add('ScrollOptionsVertical');
      end;
end;

procedure Tdx.dxLayoutControlGetItemStoredPropertyValue(Sender: TdxCustomLayoutControl; AItem: TdxCustomLayoutItem; const AName: string; var AValue: Variant);

  function VisibleElementsToString(VisibleElements: TdxLayoutItemCaptionVisibleElements): string;
  var
    b: Byte;
  begin
    b := Byte(VisibleElements);
    result := SetToString(PTypeInfo(TypeInfo(TdxLayoutItemCaptionVisibleElements)), b);
  end;

var
  group: TdxLayoutGroup;
begin

  if AItem is TdxLayoutItem then
  begin
    if AName = 'ImageIndex' then
      AValue := TdxLayoutItem(AItem).CaptionOptions.ImageIndex
    else
      if AName = 'VisibleElements' then
        AValue := VisibleElementsToString(TdxLayoutItem(AItem).CaptionOptions.VisibleElements)
  end
  else
    if AItem is TdxLayoutLabeledItem then
    begin

      if AName = 'ImageIndex' then
        AValue := TdxLayoutLabeledItem(AItem).CaptionOptions.ImageIndex
      else
        if AName = 'VisibleElements' then
          AValue := VisibleElementsToString(TdxLayoutLabeledItem(AItem).CaptionOptions.VisibleElements)
    end
    else
      if AItem is TdxLayoutGroup then
      begin
        group := TdxLayoutGroup(AItem);

        if AName = 'LookAndFeel' then
        begin
          AValue := '';
          if Assigned(group.LookAndFeel) then
            AValue := group.LookAndFeel.Name;
        end
        else
          if AName = 'LayoutLookAndFeel' then
          begin
            AValue := '';
            if Assigned(group.LayoutLookAndFeel) then
              AValue := group.LayoutLookAndFeel.Name;
          end
          else
            if AName = 'HideTabs' then
              AValue := group.TabbedOptions.HideTabs
            else
              if AName = 'ImageIndex' then
                AValue := group.CaptionOptions.ImageIndex
              else
                if AName = 'VisibleElements' then
                  AValue := VisibleElementsToString(group.CaptionOptions.VisibleElements)
                else
                  if AName = 'ScrollOptionsHorizontal' then
                    AValue := integer(group.ScrollOptions.Horizontal)
                  else
                    if AName = 'ScrollOptionsVertical' then
                      AValue := integer(group.ScrollOptions.Vertical);
      end;
end;

procedure Tdx.dxLayoutControlSetItemStoredPropertyValue(Sender: TdxCustomLayoutControl; AItem: TdxCustomLayoutItem; const AName: string; const AValue: Variant);
  function VarToString(v: Variant): string;
  begin
    result := '';

    if not VarIsNull(v) then
      result := VarToStr(v);
  end;

  function StringToVisibleElements(v: Variant): TdxLayoutItemCaptionVisibleElements;
  var
    s: string;
    b: Byte;
  begin
    s := VarToString(v);
    b := StringToSet(PTypeInfo(TypeInfo(TdxLayoutItemCaptionVisibleElements)), s);
    result := TdxLayoutItemCaptionVisibleElements(b);
  end;

var
  group: TdxLayoutGroup;
  comp: TComponent;
  s: string;
begin

  if AItem is TdxLayoutItem then
  begin
    if AName = 'ImageIndex' then
      TdxLayoutItem(AItem).CaptionOptions.ImageIndex := AValue
    else
      if AName = 'VisibleElements' then
        TdxLayoutItem(AItem).CaptionOptions.VisibleElements := StringToVisibleElements(AValue);
  end
  else
    if AItem is TdxLayoutLabeledItem then
    begin

      if AName = 'ImageIndex' then
        TdxLayoutLabeledItem(AItem).CaptionOptions.ImageIndex := AValue
      else
        if AName = 'VisibleElements' then
          TdxLayoutLabeledItem(AItem).CaptionOptions.VisibleElements := StringToVisibleElements(AValue);
    end
    else
      if AItem is TdxLayoutGroup then
      begin
        group := TdxLayoutGroup(AItem);

        if AName = 'LookAndFeel' then
        begin
          s := VarToString(AValue);

          if not s.isEmpty then
          begin
            comp := dxLayoutLookAndFeelList.FindComponent(s);

            if Assigned(comp) then
              if comp is TdxCustomLayoutLookAndFeel then
                group.LookAndFeel := TdxCustomLayoutLookAndFeel(comp);
          end;
        end
        else
          if AName = 'LayoutLookAndFeel' then
          begin
            s := VarToString(AValue);

            if not s.isEmpty then
            begin
              comp := dxLayoutLookAndFeelList.FindComponent(s);

              if Assigned(comp) then
                if comp is TdxCustomLayoutLookAndFeel then
                  group.LayoutLookAndFeel := TdxCustomLayoutLookAndFeel(comp);
            end;
          end
          else
            if AName = 'HideTabs' then
              group.TabbedOptions.HideTabs := AValue
            else
              if AName = 'ImageIndex' then
                group.CaptionOptions.ImageIndex := AValue
              else
                if AName = 'VisibleElements' then
                  group.CaptionOptions.VisibleElements := StringToVisibleElements(AValue)
                else
                  if AName = 'ScrollOptionsHorizontal' then
                    group.ScrollOptions.Horizontal := TdxLayoutGroupScrollMode(AValue)
                  else
                    if AName = 'ScrollOptionsVertical' then
                      group.ScrollOptions.Vertical := TdxLayoutGroupScrollMode(AValue);
      end;
end;

function Tdx.GetSkinColor(const AColorName: string; ADefault: TColor): TColor;
var
  SkinInfo: TdxSkinInfo;
  SkinColor: TdxSkinColor;
begin
  result := ADefault;

  SkinInfo := GetSkinInfo;

  if Assigned(SkinInfo) then
  begin
    SkinColor := SkinInfo.Skin.GetColorByName(AColorName);
    if Assigned(SkinColor) then
      result := SkinColor.Value;
  end;
end;

function Tdx.GetSkinInfo: TdxSkinInfo;
var
  Painter: TcxCustomLookAndFeelPainter;
  SkinInfo: TdxSkinInfo;
begin
  result := nil;
  Painter := GetSkinPainter;

  if Assigned(Painter) then
    if Painter.GetPainterData(SkinInfo) then
      result := SkinInfo;
end;

function Tdx.GetColorPippo(ColorKind: TColorKind): TColor;
var
  LSkinInfo: TdxSkinInfo;
begin

  // DA GUARDARE

  // // Prova dallo skin
  // if SkinActive then
  // begin
  // LSkinInfo := GetSkinInfo;
  // if (LSkinInfo <> nil) and (LSkinInfo.Skin <> nil) then
  // begin
  // case ColorKind of
  // ckControl, ckContent, ckEditorNormal, ckGridContent, ckGridContentEven,
  // ckTreeView, ckInspector, ckInspectorValues, ckWizard:
  // Result := GetSkinColor('ContentColor', clBtnFace);
  //
  // ckTitle, ckWizardTitle:
  // Result := GetSkinColor('SelectionColor', clBtnFace);
  //
  // ckEditorRequired:
  // // I campi required mantengono il colore custom giallo
  // Result := FDefaultColors[AColorKind];
  //
  // ckEditorReadOnly:
  // begin
  // Result := GetSkinColor('ContentColor', FDefaultColors[AColorKind]);
  // Result := BlendColor(Result, clGray, 10);
  // end;
  //
  // ckEditorDisabled:
  // Result := GetSkinColor('DisabledContentColor', FDefaultColors[AColorKind]);
  //
  // ckLabel:
  // Result := GetSkinColor('ContentColor', FDefaultColors[AColorKind]);
  //
  // ckSeparator:
  // Result := GetSkinColor('SeparatorColor', FDefaultColors[AColorKind]);
  //
  // ckGridContentOdd:
  // begin
  // Result := GetSkinColor('ContentColor', FDefaultColors[AColorKind]);
  // Result := BlendColor(Result, clGray, 5);
  // end;
  //
  // ckGridFooter:
  // Result := GetSkinColor('HeaderColor', FDefaultColors[AColorKind]);
  //
  // ckFilterBox:
  // Result := GetSkinColor('FilterBoxColor', FDefaultColors[AColorKind]);
  //
  // ckBtnFace:
  // Result := GetSkinColor('ButtonColor', FDefaultColors[AColorKind]);
  // else
  // Result := FDefaultColors[AColorKind];
  // end;
  // Exit;
  // end;
  // end;
  //
  // // Fallback
  // Result := FDefaultColors[AColorKind];
end;

procedure Tdx.InitRibbonSkinSelector(dxRibbonSkinSelector: TdxRibbonSkinSelector);
var
  IndiceColori: integer;
  GlifoColori: TdxSmartGlyph;
begin
  // Il selettore non ha ImageIndex: con la galleria delle tavolozze chiusa nel
  // ribbon DevExpress disegna un cerchio a spicchi colorati, uguale a prima
  // vista ad action_chooseskin di "Seleziona Aspetto". CollapsedGlyph e'
  // l'unico glifo che si puo' sostituire; si passa dal setter perche' il
  // selettore si ridisegni.
  IndiceColori := IndiceIcona('editcolors');
  if IndiceColori >= 0 then
  begin
    GlifoColori := TdxSmartGlyph.Create;
    try
      Immagini.GetImage(IndiceColori, GlifoColori);
      dxRibbonSkinSelector.PaletteChooserOptions.InRibbon.CollapsedGlyph := GlifoColori;
    finally
      GlifoColori.Free;
    end;
  end;

  if FileExists(SkinFileName) then
  begin
    dxRibbonSkinSelector.Visible := ivAlways;
    dxRibbonSkinSelector.LoadFromFile(SkinFileName);
  end
  else
    dxRibbonSkinSelector.Visible := ivNever;
end;

procedure Tdx.RibbonSkinSelectorApplySkin(const ASkinName: string; var AHandled: boolean);
begin
  // Il file .skinres viene sempre caricato internamente come skin 'UserSkin'
  // (invariante usato in tutta l'app: vedi Tdx.RibbonColorSchemeName e i vari
  // LookAndFeel.SkinName = 'UserSkin' nei frame/dfm). TdxRibbonSkinSelector, se
  // non intercettato, applicherebbe invece ASkinName direttamente al
  // dxSkinController: qui lo rimpiazziamo con lo stesso meccanismo di
  // SkinName/LoadSkin gia' usato da WT e (finora) da Gesty.
  SkinName := ASkinName;
  AHandled := true;
end;

procedure Tdx.SetSkinPaletteName(const Value: string);
begin
  FSkinPaletteName := Value;

  if SkinActive then
  begin
    dxSkinController.SkinPaletteName := Value;
    UpdateStyles;
  end;
end;

initialization

siDX := Si.AddSession('zDX', true);

InitRegExprDateEditMask;
cxDateUtils.SmartTextToDateFunc := zzSmartTextToDateFunc;

finalization

FreeAndNil(_dx);

siDX := nil;

end.

// RootLookAndFeel.RemoveChangeListener(Self);
  QExport4_ITA in 'X:\Druido\LIB\dxItalian\QExport4_ITA.pas', zformcontroller

  zdbcard zdbview

  cxEditInfoIcon zdbview zdbcard


