unit zDbView;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Diagnostics, // Mantis #183: cronometro del caricamento della griglia
  System.ImageList,
  System.Actions,
  System.IOUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
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
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.DBCtrls,
  Vcl.ExtActns,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  dxBar,
  dxBarExtItems,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  dxSkinscxPCPainter,
  dxBarBuiltInMenu,
  dxDateRanges,
  dxCore,
  dxScrollbarAnnotations,
  dxFileActions,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxClasses,
  cxLabel,
  cxPropertiesStore,
  cxImageList,
  cxCheckGroup,
  cxBarEditItem,
  cxCheckBox,
  cxTextEdit,
  cxStyles,
  cxCustomData,
  cxFilter,
  cxData,
  cxDataStorage,
  cxNavigator,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  cxDBData,
  cxGridLevel,
  cxGridCustomView,
  cxGridCustomTableView,
  cxGridTableView,
  cxGridDBTableView,
  cxGrid,
  cxGridCustomPopupMenu,
  cxGridPopupMenu,
  cxFilterControl,
  cxGridStdPopupMenu,
  cxGridPopupMenuConsts,
  ActionListController,
  zFocusedAction,
  zFbDataSet,
  zBaseLib,
  zSystem,
  zDbCardDlg,
  zToolActions,
  zDataController,
  zBase.Types,
  zDbView.Controller,
  zDbView.Filter,
  QExport4,
  QExport4Xlsx,
  zFrmParams,
  zRestrictions,
  zDescription,
  dxUIAClasses,
  cxGeometry,
  dxFramedControl,
  dxPanel,
  zToolFilter,
  zToolFilterHelper,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TcxGridConditionalFormattingProviderAccess = class(TcxGridConditionalFormattingProvider);

  TzDbViewCommand = (cmd_UpdateActions, cmd_DisplayToolbars, cmd_DisplayFindPanel, cmd_SetTitle, cmd_HyperLink, cmd_FlagsPropertiesChange, cmd_PropertiesChange, cmd_ReadOnlyPropertiesChange, cmd_ColumnPosChanged, cmd_FilterChanged, cmd_CalcFooters, cmd_ColumnSizeChanged, cmd_AdattaLarghezze);

  TzDbView = class;

  // Mantis #183 - 2026-10-08: misura del caricamento della griglia durante la
  // registrazione per l'assistenza (RegistrazioneGrigliaAttiva di
  // zDiagnostica.Log.Perf). In GridMode la griglia carica il suo buffer dentro
  // l'apertura del dataset, quando il DataSource avvisa i suoi collegamenti
  // dati (TcxDBDataLink.ActiveChanged), prima di DoAfterOpen: nel registro
  // quel tratto era vuoto. Il DataSource avvisa i collegamenti DALL'ULTIMO
  // agganciato AL PRIMO, e all'apertura arriva il solo ActiveChanged (niente
  // DataSetChanged): verificato con Data.DB di RAD Studio 13 nel progetto
  // D:\AI\SandBox\Prova183RegistroFine. Quindi la vista aggancia due
  // collegamenti di servizio: "fine" PRIMA di quello della griglia (cosi' e'
  // avvisato dopo di lei e legge il tempo quando ha finito), "inizio" DOPO
  // (cosi' e' avvisato per primo e fa partire il cronometro). Non toccano i
  // dati: tengono il BufferCount predefinito, e il dataset usa il massimo fra
  // i collegamenti, che e' quello della griglia.
  TzDbViewRuoloMisura = (rmInizio, rmFine);

  TzDbViewLinkMisura = class(TDataLink)
  private
    FVista: TzDbView;
    FRuolo: TzDbViewRuoloMisura;
  protected
    procedure ActiveChanged; override;
  public
    constructor Create(AVista: TzDbView; ARuolo: TzDbViewRuoloMisura);
  end;

  TActionEvent = procedure(Sender: TObject; var Continue: Boolean) of object;
  TShowCardEvent = procedure(Sender: TObject; Inserting: Boolean) of object;

  // Le azioni del .dfm sono TzFocusedAction (unit zFocusedAction): con il fuoco
  // nella vista le scorciatoie restano a lei anche quando l'azione e'
  // disabilitata, e non arrivano alle altre viste della form.
  TzDbView = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzShortCutConsumer)
    actDbCancel: TzFocusedAction;
    actDbDelete: TzFocusedAction;
    actDbEdit: TzFocusedAction;
    actDbFirst: TzFocusedAction;
    actDbInsert: TzFocusedAction;
    actDbLast: TzFocusedAction;
    actDbNext: TzFocusedAction;
    actDbPost: TzFocusedAction;
    actDbPrior: TzFocusedAction;
    actDbRefresh: TzFocusedAction;
    actDuplica: TzFocusedAction;
    actEliminaFiltri: TzFocusedAction;
    actFiltriAvanzati: TzFocusedAction;
    ActionList: TActionList;
    actNessuno: TzFocusedAction;
    actPersonalizza: TzFocusedAction;
    actSelezionaTutto: TzFocusedAction;
    actSQL: TzFocusedAction;
    DataSource: TDataSource;
    EditCopy: TEditCopy;
    EditCut: TEditCut;
    EditDelete: TEditDelete;
    EditPaste: TEditPaste;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    actFiltroPerValore: TzFocusedAction;
    NascondiColonna: TzFocusedAction;
    RecordCount: TzFocusedAction;
    SelezionaColonne: TzFocusedAction;
    actStampa: TzFocusedAction;
    Incolonna: TzFocusedAction;
    CopiaColonne: TzFocusedAction;
    IncollaColonne: TzFocusedAction;
    SalvaImpostazioni: TzFocusedAction;
    actVisualizzaFooter: TzFocusedAction;
    Parametri: TzFocusedAction;
    CaricaImpostazioni: TzFocusedAction;
    actCubo: TzFocusedAction;
    dxBarManager: TdxBarManager;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
    Titolo: TcxLabel;
    dxBarButtonIncolonna: TdxBarButton;
    dxBarButtonSalvaImpostazioni: TdxBarButton;
    dxBarButtonCaricaImpostazioni: TdxBarButton;
    dxBarButtonIncollaSelected: TdxBarButton;
    dxBarButtonCopiaSelected: TdxBarButton;
    dxBarButtonNascondiColonna: TdxBarButton;
    dxBarButtonSelezionaColonne: TdxBarButton;
    dxBarButtonactSQL: TdxBarButton;
    dxBarButtonactDbFirst: TdxBarButton;
    dxBarButtonactDbPrior: TdxBarButton;
    dxBarButtonactDbNext: TdxBarButton;
    dxBarButtonactDbLast: TdxBarButton;
    dxBarButtonactDbEdit: TdxBarButton;
    dxBarButtonactDbInsert: TdxBarButton;
    dxBarButtonactDbDelete: TdxBarButton;
    dxBarButtonactPersonalizza: TdxBarButton;
    dxBarButtonactDbRefresh: TdxBarButton;
    dxBarButtonactDbPost: TdxBarButton;
    dxBarButtonactDbCancel: TdxBarButton;
    dxBarButtonactDuplica: TdxBarButton;
    dxBarButtonRecordCount: TdxBarButton;
    dxBarButtonactSelezionaTutto: TdxBarButton;
    dxBarButtonactNessuno: TdxBarButton;
    dxBarButtonactFiltriAvanzati: TdxBarButton;
    dxBarButtonactEliminaFiltri: TdxBarButton;
    dxBarButtonactFiltroPerValore: TdxBarButton;
    dxBarButtonactStampa: TdxBarButton;
    dxBarButtonParametri: TdxBarButton;
    dxBarButtonactCubo: TdxBarButton;
    dxBarButtonEditUndo: TdxBarButton;
    dxBarButtonEditCut: TdxBarButton;
    dxBarButtonEditCopy: TdxBarButton;
    dxBarButtonEditPaste: TdxBarButton;
    dxBarButtonEditDelete: TdxBarButton;
    dxBarButtonEditSelectAll: TdxBarButton;
    dxBarToolbar: TdxBar;
    dxBarToolbarFree: TdxBar;
    popGrid: TdxBarPopupMenu;
    popColumn: TdxBarPopupMenu;
    dxBarControlContainerFiltri: TdxBarControlContainerItem;
    dxBarControlContainerOrderBy: TdxBarControlContainerItem;
    SubmenuFiltriCategoria: TdxBarSubItem;
    actPersonalizzaColonna: TzFocusedAction;
    dxBarButton1: TdxBarButton;
    zDbCardDlg: TzDbCardDlg;
    actResetColonne: TzFocusedAction;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    MostraQueryUtilizzata: TzFocusedAction;
    CopiaQueryUtilizzata: TzFocusedAction;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarEditTitolo: TcxBarEditItem;
    ShowCard: TzFocusedAction;
    dxBarButton9: TdxBarButton;
    CopyName: TzFocusedAction;
    dxBarButton10: TdxBarButton;
    cxBarItemModifyFlags: TcxBarEditItem;
    cxBarItemReadOnly: TcxBarEditItem;
    cxBarItemAutoWidth: TcxBarEditItem;
    cxBarItemBorder: TcxBarEditItem;
    cxBarItemMultiSelect: TcxBarEditItem;
    cxBarItemFooter: TcxBarEditItem;
    cxBarItemCube: TcxBarEditItem;
    cxGrid: TcxGrid;
    cxGridDBTableView: TcxGridDBTableView;
    cxGridLevel: TcxGridLevel;
    dxBarButton4: TdxBarButton;
    cxGridPopupMenu: TcxGridPopupMenu;
    dxBarItemCardInherits: TcxBarEditItem;
    ClearIniSectionAllUsers: TzFocusedAction;
    dxBarButton8: TdxBarButton;
    dxBarButton11: TdxBarButton;
    NomeFileIni: TzFocusedAction;
    CercaColonna: TzFocusedAction;
    dxBarButton12: TdxBarButton;
    actCerca: TzFocusedAction;
    popFilter: TdxBarPopupMenu;
    CaricaFiltri: TdxFileOpen;
    SalvaFiltri: TdxFileSaveAs;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    SalvaDisposizioneColonne: TzFocusedAction;
    dxBarButton15: TdxBarButton;
    Excel: TzFocusedAction;
    EditTools: TzFocusedAction;
    dxBarButton16: TdxBarButton;
    Esporta: TzFocusedAction;
    dxBarButton17: TdxBarButton;
    Permessi: TzFocusedAction;
    dxBarButton18: TdxBarButton;
    popActions: TdxBarPopupMenu;
    actPermessiAzione: TzFocusedAction;
    dxBarButton19: TdxBarButton;
    actProprietaAzione: TzFocusedAction;
    dxBarButton20: TdxBarButton;
    cxGridDBTableViewColumn1: TcxGridDBColumn;
    OverrideCampo: TzFocusedAction;
    dxBarButton21: TdxBarButton;
    dxBarButton22: TdxBarButton;
    actResetCaptionColonne: TzFocusedAction;
    dxBarButton23: TdxBarButton;
    CopiaColonnePerDX: TzFocusedAction;
    dxBarButtonCopiaColonnePerDX: TdxBarButton;
    dxBarButton24: TdxBarButton;
    FormattazioneCondizionale: TzFocusedAction;
    dxBarButton25: TdxBarButton;
    pnlDescrizione: TdxPanel;
    Descrizione: TzFocusedAction;
    dxBarButton26: TdxBarButton;
    dxBarButton27: TdxBarButton;
    procedure actDbDeleteExecute(Sender: TObject);
    procedure actDbEditExecute(Sender: TObject);
    procedure actDbInsertExecute(Sender: TObject);
    procedure actDbRefreshExecute(Sender: TObject);
    procedure actDuplicaExecute(Sender: TObject);
    procedure actEliminaFiltriExecute(Sender: TObject);
    procedure actFiltriAvanzatiExecute(Sender: TObject);
    procedure actNessunoExecute(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure actSelezionaTuttoExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    procedure DataSourceStateChange(Sender: TObject);
    procedure actFiltroPerValoreExecute(Sender: TObject);
    procedure FiltriUpdate(Sender: TObject);
    procedure NascondiColonnaExecute(Sender: TObject);
    procedure RecordCountExecute(Sender: TObject);
    procedure SelezionaColonneExecute(Sender: TObject);
    procedure actStampaExecute(Sender: TObject);
    procedure IncolonnaExecute(Sender: TObject);
    procedure CopiaColonneExecute(Sender: TObject);
    procedure IncollaColonneExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure actVisualizzaFooterExecute(Sender: TObject);
    procedure actCercaExecute(Sender: TObject);
    procedure actCuboExecute(Sender: TObject);
    procedure actDbCancelExecute(Sender: TObject);
    procedure actDbFirstExecute(Sender: TObject);
    procedure actDbLastExecute(Sender: TObject);
    procedure actDbNextExecute(Sender: TObject);
    procedure actDbPostExecute(Sender: TObject);
    procedure actDbPriorExecute(Sender: TObject);
    procedure FormattazioneCondizionaleExecute(Sender: TObject);
    procedure actPermessiAzioneExecute(Sender: TObject);
    procedure EsportaExecute(Sender: TObject);
    procedure actPersonalizzaColonnaExecute(Sender: TObject);
    procedure actPersonalizzaColonnaUpdate(Sender: TObject);
    procedure actProprietaAzioneExecute(Sender: TObject);
    procedure actResetCaptionColonneExecute(Sender: TObject);
    procedure actResetColonneExecute(Sender: TObject);
    procedure actVisualizzaFooterUpdate(Sender: TObject);
    procedure ParametriExecute(Sender: TObject);
    procedure CaricaImpostazioniExecute(Sender: TObject);
    procedure CopiaQueryUtilizzataExecute(Sender: TObject);
    procedure CopyNameExecute(Sender: TObject);
    procedure dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
    procedure PopupGridPopup(Sender: TObject);
    procedure MostraQueryUtilizzataExecute(Sender: TObject);
    procedure PopupOptionsPopup(Sender: TObject);
    procedure ShowCardExecute(Sender: TObject);
    procedure cxBarItemModifyFlagsPropertiesChange(Sender: TObject);
    procedure cxBarItemReadOnlyPropertiesChange(Sender: TObject);
    procedure cxBarItemAutoWidthPropertiesChange(Sender: TObject);
    procedure cxBarItemBorderPropertiesChange(Sender: TObject);
    procedure cxBarItemMultiSelectPropertiesChange(Sender: TObject);
    procedure cxBarItemFooterPropertiesChange(Sender: TObject);
    procedure cxBarItemCubePropertiesChange(Sender: TObject);
    procedure dxBarEditTitoloChange(Sender: TObject);
    procedure CaricaFiltriAccept(Sender: TObject);
    procedure CercaColonnaExecute(Sender: TObject);
    procedure ClearIniSectionAllUsersExecute(Sender: TObject);
    procedure CopiaColonnePerDXExecute(Sender: TObject);
    procedure CopiaColonnePerDXUpdate(Sender: TObject);
    procedure cxGridDBTableViewDataControllerFilterChanged(Sender: TObject);
    procedure cxGridDBTableViewDataControllerSortingChanged(Sender: TObject);
    procedure cxGridDBTableViewDataControllerSummaryAfterSummary(ASender: TcxDataSummary);
    procedure cxGridDBTableViewDblClick(Sender: TObject);
    procedure cxGridDBTableViewFocusedItemChanged(Sender: TcxCustomGridTableView; APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
    procedure cxGridDBTableViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure cxBarEditItemCardInheritsPropertiesChange(Sender: TObject);
    procedure cxGridDBTableViewColumnPosChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
    procedure cxGridDBTableViewColumnSizeChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
    procedure cxGridDBTableViewFilterControlDialogShow(Sender: TObject);
    procedure cxGridDBTableViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cxGridPopupMenuPopup(ASenderMenu: TComponent; AHitTest: TcxCustomGridHitTest; X, Y: Integer; var AllowPopup: Boolean);
    procedure DescrizioneExecute(Sender: TObject);
    procedure dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
    procedure ExcelExecute(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure NomeFileIniExecute(Sender: TObject);
    procedure PermessiExecute(Sender: TObject);
    procedure PermessiUpdate(Sender: TObject);
    procedure popActionsPopup(Sender: TObject);
    procedure SalvaDisposizioneColonneExecute(Sender: TObject);
    procedure SalvaFiltriAccept(Sender: TObject);
    procedure OverrideCampoExecute(Sender: TObject);
    procedure OverrideCampoUpdate(Sender: TObject);
  private
    FOnDataSetDelete: TNotifyEvent;
    FOnDataSetEdit: TNotifyEvent;
    FOnDataSetInsert: TNotifyEvent;
    FOnDelete: TActionEvent;
    FOnEdit: TActionEvent;
    FOnEditPropSQL: TNotifyEvent;
    FOnInsert: TActionEvent;
    FOnShowCard: TShowCardEvent;
    FOnUpdateActions: TNotifyEvent;
    FOnFooterUpdate: TNotifyEvent;
    FSearchFieldName: string;
    FzDataSet: TzFbDataSet;
    FzSystem: TzSystem;
    DetailLevels: TDictionary<TDataSet, TcxGridLevel>;
  private
    // Vero mentre questa vista tiene spento UseSqlLocate del dataset, perche'
    // la griglia non e' in GridMode (vedi AllineaLocate); il valore di prima
    // si rimette quando la griglia ci torna o il dataset cambia.
    FLocateInMemoria: Boolean;
    FUseSqlLocateSalvato: Boolean;
    procedure AllineaLocate;
    procedure RipristinaLocate;
  private
    // Mantis #183 - 2026-10-08: vedi TzDbViewLinkMisura.
    FLinkMisuraInizio: TzDbViewLinkMisura;
    FLinkMisuraFine: TzDbViewLinkMisura;
    FCronometroGriglia: TStopwatch;
    FMisuraGrigliaInCorso: Boolean;
    procedure MisuraGrigliaInizio;
    procedure MisuraGrigliaFase(const AFase: string; AConclude: Boolean);
    procedure cxGridDBTableViewDataControllerGroupingChanged(Sender: TObject);
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
    function ConfigTitle: string;
  private
    procedure SetOnDelete(const Value: TActionEvent);
    procedure SetOnEdit(const Value: TActionEvent);
    procedure SetOnInsert(const Value: TActionEvent);
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: Boolean;
    function IsAdmin: Boolean;
    procedure ClearDependentFields(Field: TField);
    procedure DetailHasChildren(Sender: TcxDBDataController; ARecordIndex, ARelationIndex: Integer; const AMasterDetailKeyFieldNames: string; const AMasterDetailKeyValues: Variant; var HasChildren: Boolean);
  private
    procedure ColorCombo_OnCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var aDone: Boolean);
  private
    InplaceFilterControl: TzFilterControl;

    procedure InplaceFilterControlChanged(Sender: TObject);
    procedure CreateInplaceFilterControl;
    procedure UpdateInplaceFilterControlVisibility;
    procedure InternalFilterChanged;
  private
    ActionListController: TActionListController;
    procedure ToolActionsChanged(Sender: TObject);
    procedure DisplayToolbars;
    procedure UpdateActions;

  private
    FCalculatingFooters: Boolean;
    PostedCommands: array [TzDbViewCommand] of Boolean;
    // Comandi richiesti mentre la view era off-screen (es. pagina di PageControl
    // non attiva): vengono rieseguiti in CMShowingChanged al rientro.
    FPendingCommands: array [TzDbViewCommand] of Boolean;
    procedure FlushPendingCommands;
    procedure PostInternalMessage(const cmd: TzDbViewCommand);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBVIEW;
  private
    // R-020: regole di formattazione condizionale dell'utente, una coppia di
    // file per vista: le regole (flusso DevExpress, aree per indice di
    // colonna) e i nomi dei campi per indice al momento del salvataggio
    function ConditionalFormattingFileName: string;
    function ConditionalFormattingFieldsFileName: string;
    procedure LoadUserConditionalFormatting;
    procedure SaveUserConditionalFormatting;
    procedure RealignConditionalFormatting(SavedFields: TStrings);
  private
    FCardVisible: Boolean;

    FController: TzDbViewController;
    FDataController: TzDataController;

    procedure doSalvaImpostazioni(const Silent: Boolean = False);
  private
    FrameDescription: TFrameDescription;
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private
    procedure FocusFirstVisibleColumn;
  private
    procedure DoFindPanelChanged(Sender: TObject);
    procedure DoShowFindPanel;
  private
    DisableShowRecord: Boolean;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  private
    HyperLinkFieldName: string;
    HyperLinkValue: Variant;
    procedure DoHyperLink(Sender: TObject);
    procedure F2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure FlagsPropertiesChange;
    procedure PropertiesChange;
    procedure ReadOnlyPropertiesChange;
  private
    procedure LoadProperties(const LoadDefaults: Boolean);
    function CustomCard: Boolean;
    function IsViewReadOnly: Boolean;
  private
    procedure CreateActionsFromProps;
    procedure CreateFiltersFromProps;
  private
    FOnAfterCreateControls: TNotifyEvent;
    FOnBeforeCreateControls: TNotifyEvent;
    FOnGridDblClick: TNotifyEvent;
    FOnSelectionChanged: TNotifyEvent;
  private
    ShouldCheckColumnWidths: Boolean;
    // True dall'apertura della vista finche' le colonne non sono state
    // allargate al contenuto (serve almeno una riga da misurare)
    FAdattaLarghezzeInAttesa: Boolean;
    procedure CheckColumnWidths;
    procedure AllargaColonneAlContenuto;
    procedure doCalcFooters;
    procedure CreateColumns;
    procedure DestroyColumns;
    procedure InitView;
  private
    function GetCardID: string;
    function GetFlags: TzDbViewFlags;
    function GetViewID: string;
    procedure OnFlagChange(Sender: TObject);
    procedure SetCardID(const Value: string);
    procedure SetViewID(const Value: string);
  protected
    AlreadyShown: Boolean;
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
  private
    RestrictionManager: TRestrictionManager;
  private
    FIsDestroying: Boolean;
    FOnBeforeExecuteCardDlg: TzOnDbCardDlgEvent;
    FRestrictionReadOnly: Boolean;
    ShouldDisplayFindPanel: Boolean;
    procedure DisplayFindPanel;
    procedure SetOnBeforeExecuteCardDlg(const Value: TzOnDbCardDlgEvent);
    procedure SetRestrictionReadOnly(const Value: Boolean);

    property IsDestroying: Boolean read FIsDestroying;
  private type
    TEnumDirection = (edAscending, edDescending);
  private
    procedure EnumSelectedRows(proc: TProc; Direction: TEnumDirection);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure ActivateDataSet;
    procedure OpenDataSet;
    procedure EliminaFiltri(Activate: Boolean);
    function GetRecordCount: Integer;
    function ShowRecord(doInsert: Boolean): Boolean;
    procedure CloseCard(doPost: Boolean);

    procedure FocusFindPanel;
    procedure FocusGrid;
    function IsActiveControl: Boolean;
    procedure ApplyBestFit;

    procedure dbDelete;
    procedure dbEdit;
    procedure dbInsert;

    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
    procedure InitActions;
    procedure InitToolActions;
    procedure ExecuteToolConfig;
    procedure RealignToolbars;
    function ShowDbCard: Boolean;
    property CardVisible: Boolean read FCardVisible;
  public
    procedure RebuildActions;
    procedure RebuildFilters;
    procedure RebuildToolbar; // IzBaseComponent.RebuildToolbar — filtri poi azioni
  public
    function AreAllRowsSelected: Boolean;
    procedure SelectAll;
    procedure ClearSelection;
    procedure SelectRecord;

    function SelectedCount: Integer;
    procedure SelectRow(const index: Integer);

    procedure ForEach(proc: TProc; Direction: TEnumDirection = edAscending);
    procedure GetSelectedRows(proc: TProc); overload;
    procedure GetSelectedRows(const FieldName: string; IdList: TList<Integer>; func: TFunc<Boolean>; const Distinct: Boolean = False); overload;
    procedure GetSelectedRows(const FieldName: string; IdList: TList<Integer>; const Distinct: Boolean = False); overload;
    procedure GetSelectedRows(const FieldName: string; IdList: TList<string>; const Distinct: Boolean = False); overload;
    procedure GetSelectedRows(const FieldName: string; IdList: TList<Int64>; func: TFunc<Boolean>; const Distinct: Boolean = False); overload;
    procedure GetSelectedRows(const FieldName: string; IdList: TList<Int64>; const Distinct: Boolean = False); overload;

    function ShowParamsForm: Boolean;
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property OnEditPropSQL: TNotifyEvent read FOnEditPropSQL write FOnEditPropSQL;
  public
    procedure AddFilterCondition(FieldName: string; OperatorKind: TcxFilterOperatorKind; Value: Variant; Checked: Boolean = true; Overwrite: Boolean = true);
    function FilterCount: Integer;
    procedure ClearFilter(ActivateDataSet: Boolean);
    procedure ApplyFilter;
    procedure DeleteConditionsForField(FieldName: string);

    procedure BeginUpdateFilter;
    procedure EndUpdateFilter;
  public
    procedure AddDetailDataSet(Master, Detail: TzFbDataSet; const Caption: string);
    //
    function GetTitle: string;
    procedure SetTitle(const Title: string);
    function GetDbViewProps: TzDbViewProps;
    procedure ReloadColumnProps;
    procedure LoadDefaultProps;
  private
    FBeforeShowParamsProc: TBeforeShowParamsProc;
    FOnCardAfterCreateControl: TAfterCreateControlEvent;
    FOnCardBeforeCreateControls: TNotifyEvent;
    FOnCardBeforeCreateControl: TBeforeCreateControlEvent;
    FOnCardAfterCreateControls: TNotifyEvent;
    FOnCardAfterCreateDbControl: TAfterCreateDbControlEvent;
    FOnCardBeforeCreateDbControl: TBeforeCreateDbControlEvent;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    FOnRecordChanged: TNotifyEvent;
    procedure SetOnCardAfterCreateControl(const Value: TAfterCreateControlEvent);
    procedure SetOnCardAfterCreateControls(const Value: TNotifyEvent);
    procedure SetOnCardAfterCreateDbControl(const Value: TAfterCreateDbControlEvent);
    procedure SetOnCardBeforeCreateControl(const Value: TBeforeCreateControlEvent);
    procedure SetOnCardBeforeCreateControls(const Value: TNotifyEvent);
    procedure SetOnCardBeforeCreateDbControl(const Value: TBeforeCreateDbControlEvent);
    property Controller: TzDbViewController read FController;
  private
    function GetFindValue: Variant;
    procedure SetFindValue(const Value: Variant);
    procedure SetOnCustomLoadProps(const Value: TNotifyEvent);
    procedure SetOnCustomSaveProps(const Value: TNotifyEvent);
    procedure StdHeaderMenuPopup(Sender: TObject);
  public
    property DataController: TzDataController read FDataController;
  public
    property CardID: string read GetCardID write SetCardID;
    property ViewID: string read GetViewID write SetViewID;
    property Flags: TzDbViewFlags read GetFlags;
  public // da implementare
    function IsEditing: Boolean;
    function IsDataSetEmpty: Boolean;

    procedure SetColumnEditability(const FieldName: string; Editability: TEditability);

    procedure SetFooterValue(Const FieldName: string; Value: Variant);

    procedure DrawImage(Canvas: TcxCanvas; ViewInfo: TcxGridTableDataCellViewInfo; ImageList: TCustomImagelist; const ImageIndex: TImageIndex);
    function DataCellFieldName(AViewInfo: TcxGridTableDataCellViewInfo): string;
    function DataCellValue(cxCustomGridTableView: TcxCustomGridTableView; ViewInfo: TcxGridTableDataCellViewInfo): Variant;

    function GetValue(const FieldName: string): Variant; overload;
    function GetValue(const FieldName: string; RecordIndex: Integer): Variant; overload;

    function ColumnByName(const FieldName: string): TcxGridDBColumn;
    //
    property RestrictionReadOnly: Boolean read FRestrictionReadOnly write SetRestrictionReadOnly;
  published
    property OnDataSetDelete: TNotifyEvent read FOnDataSetDelete write FOnDataSetDelete;
    property OnDataSetEdit: TNotifyEvent read FOnDataSetEdit write FOnDataSetEdit;
    property OnDataSetInsert: TNotifyEvent read FOnDataSetInsert write FOnDataSetInsert;
    property OnShowCard: TShowCardEvent read FOnShowCard write FOnShowCard;

    property OnBeforeExecuteCardDlg: TzOnDbCardDlgEvent read FOnBeforeExecuteCardDlg write SetOnBeforeExecuteCardDlg;

    property OnUpdateActions: TNotifyEvent read FOnUpdateActions write FOnUpdateActions;
    property OnFooterUpdate: TNotifyEvent read FOnFooterUpdate write FOnFooterUpdate;
    property OnGridDblClick: TNotifyEvent read FOnGridDblClick write FOnGridDblClick;
  published
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write FOnBeforeCreateControls;
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write FOnAfterCreateControls;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
  published
    property OnCardBeforeCreateControls: TNotifyEvent read FOnCardBeforeCreateControls write SetOnCardBeforeCreateControls;
    property OnCardAfterCreateControls: TNotifyEvent read FOnCardAfterCreateControls write SetOnCardAfterCreateControls;
    property OnCardBeforeCreateControl: TBeforeCreateControlEvent read FOnCardBeforeCreateControl write SetOnCardBeforeCreateControl;
    property OnCardAfterCreateControl: TAfterCreateControlEvent read FOnCardAfterCreateControl write SetOnCardAfterCreateControl;
    property OnCardBeforeCreateDbControl: TBeforeCreateDbControlEvent read FOnCardBeforeCreateDbControl write SetOnCardBeforeCreateDbControl;
    property OnCardAfterCreateDbControl: TAfterCreateDbControlEvent read FOnCardAfterCreateDbControl write SetOnCardAfterCreateDbControl;

    property OnRecordChanged: TNotifyEvent read FOnRecordChanged write FOnRecordChanged;
  public
    property BeforeShowParamsProc: TBeforeShowParamsProc read FBeforeShowParamsProc write FBeforeShowParamsProc;
    property FindValue: Variant read GetFindValue write SetFindValue;
  published
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write SetOnCustomSaveProps;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write SetOnCustomLoadProps;
  published
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  protected
    procedure DestroyWnd; override;
  end;

const
CreateToolsForViewProc:
procedure(view: TzDbView; Tools: TStrings) = nil;

const
DevExtremeSaveDbView:
procedure(view: TzDbView) = nil;

implementation

uses
  zDxBarHelper, // ChiudiGruppoDeiFiltri
  zDiagnostica.Log.Perf,
  Winapi.ShellAPI,
  System.Math,
  System.TypInfo,
  System.IniFiles,
  System.Threading,
  Vcl.Clipbrd,
  dxToggleSwitch,
  cxFindPanel,
  cxMemo,
  cxHyperLinkEdit,
  cxGridDBDataDefinitions,
  cxFilterControlDialog,
  dxDPIAwareUtils,
  cxColorComboBox,
  zDX,
  zFrmInspector,
  zDbView.Print,
  zDbView.Export,
  zDbView.Columns.Frm,
  zMsg,
  zMemoDialog,
  zLocalizer,
  zz.base.editor._form,
  zRestrictions.Types,
  System.JSON,
  dxSpreadSheetConditionalFormatting,
  zDxConditionalFormatting,
  zToolConfigDlg,
  zOverrides,
  zToolFilter.Builder;

{$R *.dfm}

var
  siDbView: TSiSession;

type
  TcxGridTableControllerAccess = class(TcxGridTableController);
  TcxGridFindPanelAccess = class(TcxGridFindPanel);
  TcxViewInfoAcess = class(TcxGridTableDataCellViewInfo);
  TcxPainterAccess = class(TcxGridTableDataCellPainter);

function TzDbView.GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
begin
  result := ctView;
end;

function TzDbView.GetToolbar: TdxBar; // IzBaseComponent.GetToolbar — barra unica filtri+azioni
begin
  result := dxBarToolbarFree;
end;

function TzDbView.GetID: string; // IzBaseComponent.GetID
begin
  result := ViewID;
end;

procedure TzDbView.SetID(const Value: string); // IzBaseComponent.SetID
begin
  SetViewID(Value);
end;

function TzDbView.GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
begin
  result := FToolActions;
end;

{ TzDbViewLinkMisura }

constructor TzDbViewLinkMisura.Create(AVista: TzDbView; ARuolo: TzDbViewRuoloMisura);
begin
  inherited Create;
  FVista := AVista;
  FRuolo := ARuolo;
  // BufferCount resta quello predefinito (1): il dataset tiene il massimo fra
  // i collegamenti, e la griglia ne chiede sempre di piu'.
end;

procedure TzDbViewLinkMisura.ActiveChanged;
begin
  inherited;
  if FVista = nil then
    Exit;
  if Active then
  begin
    if FRuolo = rmInizio then
      FVista.MisuraGrigliaInizio
    else
      FVista.MisuraGrigliaFase('caricamento', True);
  end
  else if FRuolo = rmInizio then
    FVista.FMisuraGrigliaInCorso := False;
end;

procedure TzDbView.MisuraGrigliaInizio;
begin
  FMisuraGrigliaInCorso := False;
  if not zDiagnostica.Log.Perf.RegistrazioneGrigliaAttiva then
    Exit;
  FCronometroGriglia := TStopwatch.StartNew;
  FMisuraGrigliaInCorso := True;
end;

// Scrive il tempo trascorso da quando il DataSource ha cominciato ad avvisare
// i collegamenti dell'attivazione: "caricamento" quando il collegamento della
// griglia ha finito il suo ActiveChanged (in GridMode e' li' che carica il
// buffer), "primo evento dati" se la misura e' rimasta aperta fino al primo
// evento sui dati. AConclude a True ferma la misura. Righe = record che la
// griglia ha nel suo buffer in quel momento.
procedure TzDbView.MisuraGrigliaFase(const AFase: string; AConclude: Boolean);
var
  DurataMs: Int64;
  RecordGriglia: Integer;
  Dettaglio: string;
begin
  if not FMisuraGrigliaInCorso then
    Exit;
  DurataMs := FCronometroGriglia.ElapsedMilliseconds;
  if AConclude then
    FMisuraGrigliaInCorso := False;

  RecordGriglia := cxGridDBTableView.DataController.RecordCount;
  Dettaglio := Format('%s | %s | GridMode=%s | record nella griglia %d | colonne %d | %d ms',
    [Name, AFase, BoolToStr(cxGridDBTableView.DataController.IsGridMode, True), RecordGriglia,
    cxGridDBTableView.ColumnCount, DurataMs]);
  siDbView.LogMessage('TzDbView.Griglia ' + Dettaglio);
  zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, 'TzDbView.Griglia ' + AFase, DurataMs, Dettaglio, RecordGriglia);
end;

function TzDbView.GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
begin
  result := FzDataSet;
end;

constructor TzDbView.Create(aOwner: TComponent);
var
  AEdit: TcxFindPanelMRUEdit;
  IRestrictionIntf: IRestriction;
  cmd: TzDbViewCommand;
begin
  siDbView.EnterMethod(Self, 'Create');
  inherited;
  dx.AgganciaImmagini(Self);

  for cmd := Low(TzDbViewCommand) to High(TzDbViewCommand) do
  begin
    PostedCommands[cmd] := False;
    FPendingCommands[cmd] := False;
  end;

  FrameDescription := nil;
  ShouldCheckColumnWidths := true;
  FAdattaLarghezzeInAttesa := False;
  FIsDestroying := False;
  FRestrictionReadOnly := False;
  FCardVisible := False;
  AlreadyShown := False;
  ShouldDisplayFindPanel := False;
  DisableShowRecord := False;
  FOnUpdateActions := nil;
  FOnFooterUpdate := nil;
  HyperLinkFieldName := '';
  HyperLinkValue := null;
  Titolo.Visible := False;

  dxBarToolbar.MultiLine := true; // collegato a resize
  dxBarToolbarFree.MultiLine := true; // collegato a resize

  DetailLevels := TDictionary<TDataSet, TcxGridLevel>.Create;

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;

  FDataController := TzDataController.Create(Self);
  FController := TzDbViewController.Create(DataController, cxGridDBTableView, OnFlagChange);

  //
  FzDataSet := nil;

  FOnCustomSaveProps := nil;
  FOnCustomLoadProps := nil;

  FBeforeShowParamsProc := nil;
  FOnBeforeCreateControls := nil;
  FOnAfterCreateControls := nil;
  FOnSelectionChanged := nil;

  FOnCardBeforeCreateControls := nil;
  FOnCardAfterCreateControls := nil;
  FOnCardBeforeCreateControl := nil;
  FOnCardAfterCreateControl := nil;
  FOnCardBeforeCreateDbControl := nil;
  FOnCardAfterCreateDbControl := nil;

  FOnShowCard := nil;
  FOnEditPropSQL := nil;
  FOnRecordChanged := nil;
  InplaceFilterControl := nil;
  //
  ActionListController := TActionListController.Create;

  dxBarControlContainerTitolo.Visible := dx.Visible(False);
  dxBarControlContainerFiltri.Visible := dx.Visible(False);
  dxBarControlContainerOrderBy.Visible := dx.Visible(False);

  Titolo.PopupMenu := popGrid;

  dx.InitTitle(Titolo);
  dx.InitGrid(cxGridDBTableView);

  cxGridDBTableView.ScrollbarAnnotations.Active := true;

  cxGridDBTableView.OptionsView.GroupByBox := False;
  cxGridDBTableView.OptionsView.FooterMultiSummaries := true;

  cxGridDBTableView.OptionsSelection.MultiSelect := False;
  cxGridDBTableView.OptionsSelection.CheckBoxVisibility := [];
  cxGridDBTableView.OptionsSelection.ShowCheckBoxesDynamically := False;

  cxGridDBTableView.DataController.DataModeController.GridMode := true;
  cxGridDBTableView.DataController.KeyFieldNames := '';
  cxGridDBTableView.DataController.MasterKeyFieldNames := '';
  cxGridDBTableView.DataController.DetailKeyFieldNames := '';
  cxGridDBTableView.DataController.DataModeController.SmartRefresh := true;

  cxGridDBTableView.OptionsView.Indicator := true;
  cxGridDBTableView.OptionsBehavior.BestFitMaxRecordCount := 100;
  cxGridDBTableView.OptionsBehavior.NavigatorHints := true;
  cxGridDBTableView.OptionsSelection.CheckBoxVisibility := [cbvDataRow, cbvColumnHeader];

  // Mantis #183 - 2026-10-08: il collegamento della griglia e' gia' agganciato
  // dal .dfm; si stacca e si riaggancia in mezzo ai due di servizio. Il
  // DataSource avvisa dall'ultimo agganciato al primo (vedi TzDbViewLinkMisura),
  // quindi l'ordine di aggancio fine, griglia, inizio da' l'ordine di avviso
  // inizio, griglia, fine.
  cxGridDBTableView.DataController.DataSource := nil;
  FLinkMisuraFine := TzDbViewLinkMisura.Create(Self, rmFine);
  FLinkMisuraFine.DataSource := DataSource;
  cxGridDBTableView.DataController.DataSource := DataSource;
  FLinkMisuraInizio := TzDbViewLinkMisura.Create(Self, rmInizio);
  FLinkMisuraInizio.DataSource := DataSource;

  cxGridDBTableView.DataController.Filter.OnChanged := cxGridDBTableViewDataControllerFilterChanged;
  cxGridDBTableView.DataController.Summary.OnAfterSummary := cxGridDBTableViewDataControllerSummaryAfterSummary;
  cxGridDBTableView.DataController.OnSortingChanged := cxGridDBTableViewDataControllerSortingChanged;
  cxGridDBTableView.DataController.OnGroupingChanged := cxGridDBTableViewDataControllerGroupingChanged;

  AEdit := TcxGridFindPanelAccess(TcxGridTableControllerAccess(cxGridDBTableView.Controller).FindPanel).Edit;
  AEdit.Properties.OnEditValueChanged := DoFindPanelChanged;

  RestrictionManager := nil;
  if Supports(Owner, IRestriction, IRestrictionIntf) then
    RestrictionManager := IRestrictionIntf.GetRestrictionManager;

  UpdateActions;
  siDbView.LeaveMethod(Self, 'Create');
end;

destructor TzDbView.Destroy;
begin
  FIsDestroying := true;
  // Il dataset sopravvive alla vista: torna con la sua Locate di prima.
  RipristinaLocate;
  // Mantis #183: i collegamenti di misura si staccano dal DataSource da soli.
  FreeAndNil(FLinkMisuraInizio);
  FreeAndNil(FLinkMisuraFine);
  FreeAndNil(FrameDescription);
  FreeAndNil(DetailLevels);
  FreeAndNil(ActionListController);

  FreeAndNil(FController);
  FreeAndNil(FDataController);

  FreeAndNil(FToolActions);
  inherited;
end;

procedure TzDbView.actDbDeleteExecute(Sender: TObject);
begin
  actDbDelete.Enabled := False;
  try
    dbDelete;
  finally
    actDbDelete.Enabled := true;
  end;
end;

procedure TzDbView.actDbEditExecute(Sender: TObject);
begin
  actDbEdit.Enabled := False;
  try
    dbEdit;
  finally
    actDbEdit.Enabled := true;
  end;
end;

procedure TzDbView.actDbInsertExecute(Sender: TObject);
begin
  actDbInsert.Enabled := False;
  try
    dbInsert;
  finally
    actDbInsert.Enabled := true;
  end;
end;

procedure TzDbView.actDbRefreshExecute(Sender: TObject);
begin

  actDbRefresh.Enabled := False;
  try
    // Active = False chiama DestroyFields,
    // che causa chiamate ripetute al layout della griglia
    cxGridDBTableView.DataController.BeginUpdateFields;
    try
      DataController.Refresh;
    finally
      cxGridDBTableView.DataController.EndUpdateFields;
    end;
  finally
    actDbRefresh.Enabled := true;
  end;
end;

procedure TzDbView.actEliminaFiltriExecute(Sender: TObject);
begin
  if DataController.CloseQuery then
    EliminaFiltri(true);
end;

procedure TzDbView.actNessunoExecute(Sender: TObject);
begin
  ClearSelection;
end;

procedure TzDbView.SelectAll;
begin
  StartWait('Attendere...', true);
  try
    cxGridDBTableView.Controller.SelectAllRecords;
  finally
    StopWait;
  end;
end;

procedure TzDbView.actSelezionaTuttoExecute(Sender: TObject);
begin
  if DataController.CloseQuery then
    SelectAll;
end;

procedure TzDbView.actSQLExecute(Sender: TObject);
var
  Item: TzDataSet;
  i: Integer;
  idx: Integer;
  idDataSet: string;
begin

  if Assigned(FOnEditPropSQL) then
  begin
    OnEditPropSQL(Self);
    Exit;
  end;

  if not DataController.DataSetOk then
    Exit;

  /// //////////////
  if zSystem.DataSetEditProps(zDataSet) then
  begin
    DestroyColumns;
    zDbCardDlg.DestroyControls;

    DataController.OpenDataSet;
    InitView;
  end;
end;

procedure TzDbView.ClearDependentFields(Field: TField);
var
  Domain: TzDomain;
  idx: Integer;
  Origin: string;
begin
  siDbView.LogVerbose('ClearDependentFields');

  // se la card � visibile, se ne deve occupare il controller della card
  if Assigned(zDbCardDlg.zDbCardForm) then
    if zDbCardDlg.zDbCardForm.Visible then
      Exit;

  if not Assigned(Field) then
    Exit;

  Origin := DataController.GetFieldOrigin(Field);
  idx := zSystem.zDataDictionary.IndexOf(Origin);

  if idx = -1 then
    Exit
  else
  begin
    Domain := zSystem.zDataDictionary[idx];

    if Domain.FieldsToClear <> '' then
      DataController.ClearFields(Domain.FieldsToClear);
  end;
end;

procedure TzDbView.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  // Mantis #183 - 2026-10-08: rete di sicurezza. Il DataSource chiama questo
  // evento dopo aver avvisato tutti i collegamenti: se la misura e' ancora
  // aperta, il collegamento di fine non e' stato avvisato (collegamenti
  // riordinati da qualcun altro) e si chiude qui, al primo evento sui dati.
  if FMisuraGrigliaInCorso then
    MisuraGrigliaFase('primo evento dati', True);

  if Assigned(Field) then
    ClearDependentFields(Field);

  PostInternalMessage(cmd_UpdateActions);

  if Assigned(OnRecordChanged) then
    OnRecordChanged(Self);
end;

procedure TzDbView.DataSourceStateChange(Sender: TObject);
begin
  // siDbView.LogVerbose('DataSourceStateChange');
  CheckColumnWidths;

  if not DataController.IsActive then
    ClearSelection;

  // la griglia genera da sola le colonne, da rivedere
  // if DataController.DataSetState = dsBrowse then
  // if cxGridDBTableView.ColumnCount = 0 then
  // LoadDefault;
  PostInternalMessage(cmd_UpdateActions);

  // Mantis #269 - 2026-10-21: filtro rinviato da InternalFilterChanged durante la modifica
  if FPendingCommands[cmd_FilterChanged] and Assigned(zDataSet) and (zDataSet.State = dsBrowse) then
  begin
    FPendingCommands[cmd_FilterChanged] := False;
    PostInternalMessage(cmd_FilterChanged);
  end;
end;

function TzDbView.GetRecordCount: Integer;
begin
  StartWait('Attendere...', true);
  try
    result := -1;
    if DataController.DataSetOk then
      result := DataController.GetRecordCount;
  finally
    StopWait;
  end;
end;

procedure TzDbView.Notification(AComponent: TComponent; Operation: TOperation);
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

procedure TzDbView.ReadOnlyPropertiesChange;
var
  s: string;
begin
  if IsDestroying then
    Exit;

  Flags.BeginUpdate;
  try
    Flags.Readonly := cxBarItemReadOnly.CurEditValue = '1';

    if Flags.Readonly then
    begin
      Flags.ButtonInsert := not Flags.Readonly;
      Flags.ButtonUpdate := not Flags.Readonly;
      Flags.ButtonDelete := not Flags.Readonly;
    end;
  finally
    Flags.EndUpdate;
  end;

  s := dx.GetStatesString([Flags.ButtonInsert, Flags.ButtonUpdate, Flags.ButtonDelete]);
  dx.SetValue(cxBarItemModifyFlags, s);

  doSalvaImpostazioni(true);
  LoadProperties(False);
end;

procedure TzDbView.RecordCountExecute(Sender: TObject);
var
  s: string;
  RecCount: Integer;
begin
  if IsAdmin then
    if CtrlKey then
      ClipBoard.AsText := zDataSet.GetRecordCountSQL;

  RecCount := GetRecordCount;
  RecordCount.Caption := RecCount.ToString;
  ConfirmOk('N° records: ' + RecCount.ToString + #13 + #13 + 'Selezionati: ' + cxGridDBTableView.Controller.SelectedRowCount.ToString());
end;

procedure TzDbView.SetOnDelete(const Value: TActionEvent);
begin
  FOnDelete := Value;
end;

procedure TzDbView.SetOnEdit(const Value: TActionEvent);
begin
  FOnEdit := Value;
end;

procedure TzDbView.SetOnInsert(const Value: TActionEvent);
begin
  FOnInsert := Value;
end;

procedure TzDbView.SetzSystem(const Value: TzSystem);
begin

  if Assigned(FzSystem) then // sgancia preesistente
    FzSystem.RemoveFreeNotification(Self);

  FzSystem := Value;

  if Assigned(FzSystem) then // aggancia quello nuovo
    FzSystem.FreeNotification(Self);

  /// //////////////////////////////////////

  InitView;
end;

function TzDbView.ShowRecord(doInsert: Boolean): Boolean;
begin
  result := False;

  if DisableShowRecord then
    Exit;

  DisableShowRecord := true;
  try
    if CustomCard then
    begin
      OnShowCard(Self, doInsert);
      result := true; // sarebbe da passare come parametro
    end
    else
    begin
      if not DataController.DataSetOk then
        Exit;

      if (DataController.IsEmpty) and (doInsert = False) then
        Exit;

      if not Flags.DblClick then
        Exit;

      if doInsert then
        DataController.Insert;

      result := ShowDbCard;

      if result then
        DataController.CheckBrowseMode
      else
        if DataController.IsEditing then
          DataController.Cancel;
    end;
  finally
    DisableShowRecord := False;
  end;
end;

procedure TzDbView.actStampaExecute(Sender: TObject);
begin
  if DataController.CloseQuery then
    Print_zDbView(Self);
end;

function TzDbView.zSystemOk: Boolean;
begin
  result := Assigned(FzSystem);
end;

procedure TzDbView.actFiltriAvanzatiExecute(Sender: TObject);
begin
  if DataController.CloseQuery then
    Controller.OpenFilterDialog;
end;

procedure TzDbView.EliminaFiltri;
begin
  ClearFilter(true);
end;

procedure TzDbView.EndUpdateFilter;
begin
  Controller.EndUpdateFilter;
end;

procedure TzDbView.actFiltroPerValoreExecute(Sender: TObject);
begin
  if DataController.CloseQuery then
    Controller.FilterByValue;
end;

procedure TzDbView.FiltriUpdate(Sender: TObject);
begin
  // F3, F4 e Ctrl+Backspace sono ShortCut delle azioni: la form li smista fra le
  // ActionList di tutti i frame, visibili o no, prima del controllo con il fuoco.
  // Una zDbView nascosta si prendeva cosi' il tasto destinato ad altro: nel
  // modulo LZ Coan_Costi_Ricavi_Per_Progetto la DbView con Visible = False apriva
  // il suo F3 su "Codic Interno" al posto del F3 del pivot. Disabilitata, l'azione
  // lascia passare il tasto alle ActionList successive e al controllo con il fuoco.
  // Dal 2026-09-30 con il fuoco dentro un'altra vista o un pivot le azioni non
  // rispondono comunque (TzFocusedAction); questo resta per il fuoco fuori da
  // ogni vista.
  (Sender as TCustomAction).Enabled := Flags.Filters and Showing;
end;

procedure TzDbView.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

procedure TzDbView.IncolonnaExecute(Sender: TObject);
begin
  ApplyBestFit;
end;

procedure TzDbView.ClearFilter(ActivateDataSet: Boolean);
begin
  // vedere il parametro [se usato]
  Controller.ClearFilters;
end;

function TzDbView.CustomCard: Boolean;
begin
  result := Assigned(FOnShowCard);
end;

function TzDbView.IsAdmin: Boolean;
begin
  result := False;
  if Assigned(zSystem) then
    result := zSystem.IsAdmin;
end;

function TzDbView.IsDataSetEmpty: Boolean;
begin
  result := DataController.IsEmpty;
end;

procedure TzDbView.dbDelete;
var
  Continue: Boolean;
  i: Integer;
  SelCount: Integer;
begin
  if Assigned(FOnDataSetDelete) then
    OnDataSetDelete(Self)
  else
    if DataController.DataSetOk then
      if (DataController.CanDelete and Flags.ButtonDelete) then
      begin

        if cxGridDBTableView.Controller.SelectedRowCount <= 1 then
        begin
          if DataController.ConfirmDelete(False) then
            DataController.Delete;
        end
        else
        begin
          if DataController.ConfirmDelete(true) then
          begin
            EnumSelectedRows(
              procedure
              begin
                DataController.Delete;
              end, edDescending);
            ClearSelection;
          end;
        end;
      end;
end;

procedure TzDbView.dbEdit;
begin
  if Assigned(FOnDataSetEdit) then
    OnDataSetEdit(Self)
  else
    if DataController.DataSetOk then
      if (DataController.CanEdit and Flags.ButtonUpdate) then
      begin
        if not CustomCard then
          DataController.CheckEditMode;
        ShowRecord(False);
      end;
end;

procedure TzDbView.dbInsert;
begin
  if Assigned(FOnDataSetInsert) then
    OnDataSetInsert(Self)
  else
    if DataController.DataSetOk then
      if (DataController.CanInsert and Flags.ButtonInsert) then
        ShowRecord(true);
end;

procedure TzDbView.ToolActionsChanged(Sender: TObject);
begin
  // ZZ 15.01.2025: viene chiamato per ogni aggiunta di un'azione, con continui sfarfallii InitToolActions;
end;

procedure TzDbView.SalvaImpostazioniExecute(Sender: TObject);
begin
  doSalvaImpostazioni;
end;

procedure TzDbView.actCercaExecute(Sender: TObject);
begin
  if not DataController.CloseQuery then
    Exit;

  // occhio: ctrl+f è gestito direttamente dalla griglia
  if not Flags.Search then
    cxGridDBTableView.Controller.HideFindPanel
  else
    if cxGridDBTableView.Controller.IsFindPanelVisible then
      cxGridDBTableView.Controller.HideFindPanel
    else
      DoShowFindPanel;
end;

procedure TzDbView.actCuboExecute(Sender: TObject);
begin
  DataController.DisableControls;
  try
    // ShowCube(zSystem, zDataSet);
    // Implementare du dbPivot partendo da zCubeFrm
  finally
    DataController.EnableControls;
  end;
end;

procedure TzDbView.actDbPostExecute(Sender: TObject);
begin
  DataController.CheckBrowseMode;
end;

procedure TzDbView.actDbCancelExecute(Sender: TObject);
begin
  DataController.Cancel;
end;

procedure TzDbView.ParametriExecute(Sender: TObject);
var
  oldAsyncMode: TFDStanAsyncMode;
begin
  oldAsyncMode := zDataSet.ResourceOptions.CmdExecMode;

  zDataSet.ResourceOptions.CmdExecMode := amCancelDialog;
  try
    ShowParamsForm;
  finally
    zDataSet.ResourceOptions.CmdExecMode := oldAsyncMode;
  end;
end;

procedure TzDbView.CaricaImpostazioniExecute(Sender: TObject);
begin
  if not ConfirmYesNo('Ripristino le impostazioni di default?') then
    Exit;

  LoadDefaultProps;
end;

procedure TzDbView.PopupOptionsPopup(Sender: TObject);
begin
  if Assigned(zSystem) then
    if not zSystem.IsAdmin then
      System.SysUtils.Abort;
end;

function TzDbView.ShowDbCard: Boolean;
begin
  result := False;

  if FCardVisible then // 24.01.2019 Capac riesce ad aprirlo 2 volte
    Exit;

  if not DataController.IsActive then
    Exit;

  if DataController.IsEmpty then
    Exit;

  zDbCardDlg.zSystem := Self.zSystem;
  zDbCardDlg.DataSet := Self.zDataSet;

  FCardVisible := true;
  try
    result := zDbCardDlg.Execute;
  finally
    FCardVisible := False;
  end;
end;

procedure TzDbView.dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
begin

  if Assigned(zSystem) then
    if zSystem.IsAdmin then
      popGrid.PopupFromCursorPos;
end;

procedure TzDbView.dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
begin

  if ABar = dxBarToolbarFree then
    dx.dxBarAssignPopupMenu(ABar, popActions);
end;

function TzDbView.ShowParamsForm: Boolean;
begin
  result := ShowParams(ViewID + '_Params', zDataSet, 'Parametri', true, BeforeShowParamsProc);
end;

procedure TzDbView.ActivateDataSet;
begin

  if DataController.AutoOpen then
    OpenDataSet;
end;

procedure TzDbView.OpenDataSet;
begin
  siDbView.EnterMethod(Self, 'OpenDataSet');

  if DataController.DataSetOk then
    if not DataController.IsActive then
    begin
      siDbView.LogString('zDbView.OpenDataSet', zDataSet.Name);
      DataController.OpenDataSet;
    end;

  siDbView.LeaveMethod(Self, 'OpenDataSet');
end;

procedure TzDbView.actPersonalizzaColonnaUpdate(Sender: TObject);
begin
  ActionVisible(actPersonalizzaColonna, IsAdmin);
end;

procedure TzDbView.DisplayFindPanel;
begin
  // ctrl+f per visalizzarla (direttamente la griglia chiama ShowFindPanel)
  ShouldDisplayFindPanel := False;
  PostInternalMessage(cmd_DisplayFindPanel);
end;

procedure TzDbView.DisplayToolbars;
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

procedure TzDbView.actPersonalizzaColonnaExecute(Sender: TObject);
var
  i: Integer;
  Color: TColor;
  FieldName: string;
  idx: Integer;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
begin
  FieldName := Controller.ActiveFieldName;

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

    StartWait('Attendere...', true);
    try
      Domain.SaveToBase(true);
    finally
      StopWait;
    end;

    CreateColumns; // << --- agire solo sulle props della colonna selezionata?
  end;
end;

procedure TzDbView.GetSelectedRows(proc: TProc);
begin
  EnumSelectedRows(proc, edAscending);
end;

procedure TzDbView.GetSelectedRows(const FieldName: string; IdList: TList<Int64>; func: TFunc<Boolean>; const Distinct: Boolean = False);
var
  Field: TField;
begin
  Assert(Assigned(func));
  Assert(Assigned(IdList));
  Assert(FieldName <> '');

  IdList.Clear;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  GetSelectedRows(
    procedure
    begin
      if not Field.IsNull then
        if not(Distinct and IdList.Contains(Field.AsLargeInt)) then
          if func then
            IdList.Add(Field.AsLargeInt);
    end);
end;

procedure TzDbView.GetSelectedRows(const FieldName: string; IdList: TList<Int64>; const Distinct: Boolean = False);
var
  Field: TField;
begin
  Assert(Assigned(IdList));
  Assert(FieldName <> '');

  IdList.Clear;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  GetSelectedRows(
    procedure
    begin
      if not Field.IsNull then
        if not(Distinct and IdList.Contains(Field.AsLargeInt)) then
          IdList.Add(Field.AsLargeInt);
    end);
end;

procedure TzDbView.GetSelectedRows(const FieldName: string; IdList: TList<Integer>; const Distinct: Boolean = False);
var
  Field: TField;
begin
  Assert(Assigned(IdList));
  Assert(FieldName <> '');

  IdList.Clear;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  GetSelectedRows(
    procedure
    begin
      if not Field.IsNull then
        if not(Distinct and IdList.Contains(Field.AsInteger)) then
          IdList.Add(Field.AsInteger);
    end);
end;

procedure TzDbView.GetSelectedRows(const FieldName: string; IdList: TList<string>; const Distinct: Boolean = False);
var
  Field: TField;
begin
  Assert(Assigned(IdList));
  Assert(FieldName <> '');

  IdList.Clear;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  GetSelectedRows(
    procedure
    begin
      if not Field.IsNull then
        if not(Distinct and IdList.Contains(Field.AsString)) then
          IdList.Add(Field.AsString);
    end);
end;

procedure TzDbView.GetSelectedRows(const FieldName: string; IdList: TList<Integer>; func: TFunc<Boolean>; const Distinct: Boolean = False);
var
  Field: TField;
begin
  Assert(Assigned(IdList));
  Assert(FieldName <> '');

  IdList.Clear;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  GetSelectedRows(
    procedure
    begin
      if not Field.IsNull then
        if not(Distinct and IdList.Contains(Field.AsInteger)) then
          if func then
            IdList.Add(Field.AsInteger);
    end);
end;

procedure TzDbView.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if DataController.DataSetOk then
  begin
    ClipBoard.AsText := DataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbView.MostraQueryUtilizzataExecute(Sender: TObject);
var
  s: String;
begin

  if DataController.DataSetOk then
  begin
    s := DataController.GetDebugInfo;
    zExecuteMemoDialog(s, GetCardID);
  end;
end;

procedure TzDbView.BeginUpdateFilter;
begin
  Controller.BeginUpdateFilter;
end;

procedure TzDbView.CopyNameExecute(Sender: TObject);
begin
  ClipBoard.AsText := ViewID;
  ConfirmOk(ViewID);
end;

procedure TzDbView.InitToolActions;
begin
  ToolActions.CreateButtons(dxBarToolbarFree, popGrid, otView);
  DisplayToolbars;
end;

function TzDbView.IsViewReadOnly: Boolean;
begin
  result := Flags.Readonly or RestrictionReadOnly;
end;

procedure TzDbView.dxBarEditTitoloChange(Sender: TObject);
begin
  GetDbViewProps.Title := dxBarEditTitolo.EditValue;
  doSalvaImpostazioni;
  PostInternalMessage(cmd_SetTitle);
end;

function TzDbView.GetCardID: string;
begin
  result := Controller.Storage.CardID;
end;

function TzDbView.GetViewID: string;
begin
  result := Controller.Storage.ViewID;
end;

procedure TzDbView.SetCardID(const Value: string);
begin
  Controller.Storage.CardID := Value;
end;

procedure TzDbView.SetViewID(const Value: string);
begin
  Controller.Storage.ViewID := Value;
end;

function TzDbView.GetDbViewProps: TzDbViewProps;
begin
  result := Controller.Storage.zDbViewProps;
end;

procedure TzDbView.SetTitle(const Title: string);
begin
  Titolo.Caption := trim(Title);
  Titolo.Visible := (Titolo.Caption <> '') and (Flags.Toolbar = true);
  dxBarControlContainerTitolo.Visible := dx.Visible(Titolo.Visible);

  dxBarEditTitolo.OnChange := Nil;
  try
    dxBarEditTitolo.EditValue := Titolo.Caption;

    if Titolo.Visible then
    begin
      Titolo.autoSize := False;
      Titolo.autoSize := true;
    end;
  finally
    dxBarEditTitolo.OnChange := dxBarEditTitoloChange;
  end;
end;

procedure TzDbView.ShowCardExecute(Sender: TObject);
begin
  zDbCardDlg.zSystem := Self.zSystem;
  zDbCardDlg.DataSet := Self.zDataSet;
  zDbCardDlg.Execute;
end;

procedure TzDbView.cxBarItemAutoWidthPropertiesChange(Sender: TObject);
begin
  if cxBarItemAutoWidth.CurEditValue then
    Flags.AutoWidth := true
  else
    Flags.AutoWidth := False;

  // Salvare le impostazioni?
end;

procedure TzDbView.cxBarItemBorderPropertiesChange(Sender: TObject);
begin
  if cxBarItemBorder.CurEditValue then
    Flags.Border := true
  else
    Flags.Border := False;
end;

procedure TzDbView.cxBarItemCubePropertiesChange(Sender: TObject);
begin
  if cxBarItemCube.CurEditValue then
    Flags.Cube := true
  else
    Flags.Cube := False;

  dxBarSubItemImpostazioni.DropDown();
end;

procedure TzDbView.cxBarItemFooterPropertiesChange(Sender: TObject);
begin
  if cxBarItemFooter.CurEditValue then
    Flags.Footer := true
  else
    Flags.Footer := False;
end;

procedure TzDbView.cxBarItemMultiSelectPropertiesChange(Sender: TObject);
begin
  if cxBarItemMultiSelect.CurEditValue then
    Flags.MultiSelect := true
  else
    Flags.MultiSelect := False;

  dxBarSubItemImpostazioni.DropDown();
end;

procedure TzDbView.CloseCard(doPost: Boolean);
begin
  if zDbCardDlg.zDbCardForm.Visible then
    if doPost then
      zDbCardDlg.zDbCardForm.ModalResult := mrOk
    else
      zDbCardDlg.zDbCardForm.ModalResult := mrCancel;
end;

procedure TzDbView.cxGridDBTableViewDataControllerFilterChanged(Sender: TObject);
begin
  siDbView.EnterMethod(Self, 'cxGridDBTableViewDataControllerFilterChanged');

  PostInternalMessage(cmd_FilterChanged);

  siDbView.LeaveMethod(Self, 'cxGridDBTableViewDataControllerFilterChanged');
end;

procedure TzDbView.InternalFilterChanged;
begin
  siDbView.EnterMethod(Self, 'InternalFilterChanged');

  if not cxGridDBTableView.DataController.DataModeController.GridMode then
    Exit;

  // Mantis #269 - 2026-10-21: il filtro riscrive la WHERE e riapre il dataset
  // (TzFbDataSet.TryChangeSQL), che con un record in modifica o in inserimento
  // scarterebbe le modifiche e lascerebbe la scheda su un altro record. Si
  // rinvia: DataSourceStateChange lo riapplica quando il dataset torna in consultazione.
  if Assigned(zDataSet) and (zDataSet.State in dsEditModes) then
  begin
    FPendingCommands[cmd_FilterChanged] := true;
    Exit;
  end;

  if not Assigned(InplaceFilterControl) then
    CreateInplaceFilterControl;

  InplaceFilterControl.BeginUpdateLinkComponent;
  try
    ApplyFilter;

    UpdateInplaceFilterControlVisibility;
  finally
    InplaceFilterControl.EndUpdateLinkComponent;
  end;

  siDbView.LeaveMethod(Self, 'InternalFilterChanged');
end;

procedure TzDbView.UpdateInplaceFilterControlVisibility;
var
  h: Integer;
  FilterOk: Boolean;
begin
  siDbView.EnterMethod(Self, 'UpdateInplaceFilterControlVisibility');

  FilterOk := (cxGridDBTableView.DataController.Filter.Active) and (not cxGridDBTableView.DataController.Filter.IsEmpty);

  if not FilterOk then
    InplaceFilterControl.Visible := False
  else
    if (not Showing) or (ClientHeight <= 0) then
    begin
      // View off-screen (es. pagina di PageControl non attiva): la geometria
      // (ClientHeight / RequiredHeight) non e' attendibile e calcolerebbe
      // un'altezza <= 50 nascondendo erroneamente il controllo. Si rinvia:
      // il filtro resta attivo e CMShowingChanged ricalcolera' al rientro.
      FPendingCommands[cmd_FilterChanged] := true;
    end
    else
    begin
      InplaceFilterControl.Visible := true;
      InplaceFilterControl.Top := cxGrid.Top - 1;

      InplaceFilterControl.BeginUpdateLinkComponent;
      try
        InplaceFilterControl.LinkComponentChanged;

        h := Min(Trunc(ClientHeight / 3), InplaceFilterControl.RequiredHeight);
        InplaceFilterControl.Height := h;

        if h <= 50 then
          InplaceFilterControl.Visible := False; // non si vedrebbe nulla
      finally
        InplaceFilterControl.EndUpdateLinkComponent;
      end;
    end;

  siDbView.LeaveMethod(Self, 'UpdateInplaceFilterControlVisibility');
end;

procedure TzDbView.DoFindPanelChanged(Sender: TObject);
begin
  Controller.FilterByFindText;
end;

procedure TzDbView.ApplyBestFit;
var
  i: Integer;
begin
  siDbView.EnterMethod(Self, 'ApplyBestFit');

  if not DataController.IsActive then
    Exit;

  // sostituire con un ciclo for su quelle realmente visibili
  StartWait('Attendere...');
  try
    cxGridDBTableView.OptionsBehavior.BestFitMaxRecordCount := cxGridDBTableView.DataController.RowCount;

    if CtrlKey then // completo
    begin
      cxGridDBTableView.ApplyBestFit(nil);
      Exit;
    end;

    // ZZ 16.01.2019:
    if cxGridDBTableView.ViewInfo.HeaderViewInfo.Count = 0 then //
    begin
      // 25.03.2020: list index out of bounds  cxGridDBTableView.ApplyBestFit(nil);
      Exit;
    end;

    // altrimenti solo quelle visibili
    cxGridDBTableView.BeginUpdate;
    try
      cxGridDBTableView.BeginBestFitUpdate;
      try
        for i := 0 to cxGridDBTableView.ViewInfo.HeaderViewInfo.Count - 1 do
          if Assigned(cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[i].Column) then
            if cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[i].Column.ActuallyVisible then
              if (cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[i].Bounds.Left > cxGridDBTableView.ViewInfo.Site.ClientBounds.Left) and
                (cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[i].Bounds.Left < cxGridDBTableView.ViewInfo.Site.ClientBounds.Right) then
              begin
                siDbView.LogString('ApplyBestFit', cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[i].Column.Caption);
                cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[i].Column.ApplyBestFit();
              end;
      finally
        cxGridDBTableView.EndBestFitUpdate;
      end;
    finally
      cxGridDBTableView.EndUpdate;
    end;
  finally
    StopWait;
  end;

  siDbView.LeaveMethod(Self, 'ApplyBestFit');
end;

procedure TzDbView.CreateFiltersFromProps;
//
// Orchestratore. Chiamato da LoadProperties dopo CreateToolsFromProps.
//
// Sorgente unica: GetDbViewProps.ToolFilters. Contiene sia la configurazione
// persistente (admin / zToolConfigDlg) sia i filtri aggiunti da codice dal
// DataModule della form (marcati FromCode e non serializzati).
//
// Nota: la versione precedente iterava DUE volte questa stessa collezione
// (GetDbViewProps.ToolFilters e la proprieta' ToolFilters sono lo stesso
// oggetto, perche' GetToolFilters restituisce la prima), e il dizionario di
// deduplicazione serviva solo a rendere innocuo il secondo giro.
//
begin
  siDbView.EnterMethod(Self, 'CreateFiltersFromProps');
  try
    TzToolFilterBuilder.Build(GetDbViewProps.ToolFilters, Self, dxBarManager, FzDataSet,
      procedure(Testo: string)
      begin
        siDbView.LogWarning('CreateFiltersFromProps: ' + Testo);
      end);
  finally
    siDbView.LeaveMethod(Self, 'CreateFiltersFromProps');
  end;
end;

procedure TzDbView.ApplyFilter;
begin
  // Forza l'applicazione sincrona del filtro, bypassando il PostInternalMessage
  // asincrono (cmd_FilterChanged) e il rinvio "not Showing" di
  // UpdateInplaceFilterControlVisibility. Necessario quando il filtro va
  // materializzato sul dataset PRIMA che il chiamante prosegua (es. SetPK
  // chiamata prima di Show su dataset gia' aperto).
  FPendingCommands[cmd_FilterChanged] := False;
  Controller.ApplyFilter;
end;

procedure TzDbView.SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
begin
  siDbView.EnterMethod(Self, 'SetzDataSet');

  // Prima di sganciarlo: il dataset di prima riprende la sua Locate.
  if FzDataSet <> Value then
    RipristinaLocate;

  if Assigned(FzDataSet) then // sgancia preesistente
    FzDataSet.RemoveFreeNotification(Self);

  // 23.03.2026: per Import Generici
  if Assigned(FzDataSet) and (FzDataSet <> Value) then
  begin
    DestroyColumns;
    zDbCardDlg.DestroyControls;
  end;

  FzDataSet := Value;

  if Assigned(FzDataSet) then // aggancia quello nuovo
    FzDataSet.FreeNotification(Self);

  /// //////////////////////////////////////

  DataController.DataSet := Value;
  DataSource.DataSet := nil;
  cxGridDBTableView.ClearItems; // distrugge le colonne, altrimenti initView non assegna il dataset

  InitView;

  siDbView.LeaveMethod(Self, 'SetzDataSet');
end;

procedure TzDbView.FocusFindPanel;
begin
  TcxGridFindPanelAccess(TcxGridTableControllerAccess(cxGridDBTableView.Controller).FindPanel).Edit.SetFocus;
end;

procedure TzDbView.FocusFirstVisibleColumn;
begin

  // 05.11.2021: altrimenti FindPanel non viene inizializzato
  if cxGridDBTableView.VisibleColumnCount > 0 then
    cxGridDBTableView.VisibleColumns[0].Focused := true;
end;

procedure TzDbView.cxGridDBTableViewDataControllerSortingChanged(Sender: TObject);
begin
  Controller.Sort;
end;

procedure TzDbView.cxGridDBTableViewDataControllerGroupingChanged(Sender: TObject);
begin
  AllineaLocate;
end;

// LA LOCATE DEL DATASET SEGUE IL MODO DELLA GRIGLIA (2026-10-04).
//
// TzFbDataSet.UseSqlLocate vale vero di norma: Locate riapre il dataset con
// la sola condizione sulla chiave cercata (LocateSQL), e il dataset resta con
// quel record solo. In GridMode va bene, perche' la griglia non chiama Locate:
// si muove con i segnalibri, e Locate la chiamano il codice e i lookup.
//
// Ma una griglia RAGGRUPPATA NON E' IN GridMode: DevExpress lo spegne da solo
// appena c'e' un gruppo (IsGridMode falso), carica tutti i record e, a ogni
// riga cliccata, porta il dataset su quel record con DataSet.Locate sulla
// chiave (KeyFieldNames = PrimaryKeyFields, in InitView). Con UseSqlLocate
// quella Locate riapriva il dataset sul solo messaggio cliccato, e la griglia
// ricaricata mostrava una riga sola: e' successo alla posta di Analysir
// appena raggruppata per data dal dizionario. Lo stesso valeva per qualunque
// elenco raggruppato, dal dizionario o trascinando una colonna.
//
// Quindi, finche' la griglia non e' in GridMode, la Locate del dataset resta
// in memoria; quando torna in GridMode, o la vista lascia il dataset, si
// rimette il valore di prima. Come in TzDbTree, che per la stessa ragione la
// tiene spenta per tutta la durata del legame.
//
// Il modo si guarda dalle sue cause, non da IsGridMode: OnGroupingChanged
// puo' arrivare prima che il data controller abbia ricalcolato il modo.
procedure TzDbView.AllineaLocate;
var
  InMemoria: Boolean;
begin
  if not Assigned(FzDataSet) or (csDestroying in FzDataSet.ComponentState) then
    Exit;

  InMemoria := not cxGridDBTableView.DataController.DataModeController.GridMode or
    (cxGridDBTableView.DataController.Groups.GroupingItemCount > 0);

  if InMemoria and not FLocateInMemoria then
  begin
    FUseSqlLocateSalvato := FzDataSet.UseSqlLocate;
    FzDataSet.UseSqlLocate := False;
    FLocateInMemoria := True;
  end
  else
    if not InMemoria and FLocateInMemoria then
      RipristinaLocate;
end;

procedure TzDbView.RipristinaLocate;
begin
  if not FLocateInMemoria then
    Exit;

  FLocateInMemoria := False;

  if Assigned(FzDataSet) and not (csDestroying in FzDataSet.ComponentState) then
    FzDataSet.UseSqlLocate := FUseSqlLocateSalvato;
end;

procedure TzDbView.cxGridDBTableViewDataControllerSummaryAfterSummary(ASender: TcxDataSummary);
begin
  SiMain.EnterMethod(Self, 'cxGridDBTableViewDataControllerSummaryAfterSummary');

  SiMain.LogVerbose(PChar(Format('Summary view=%s visible=%d showing=%d handleAlloc=%d posted=%d', [Name, Ord(Visible), Ord(Showing), Ord(HandleAllocated), Ord(PostedCommands[cmd_CalcFooters])])));

  if Showing then
    PostInternalMessage(cmd_CalcFooters)
  else
    doCalcFooters; // form non ancora visibile: niente post da perdere, calcolo subito

  SiMain.LeaveMethod(Self, 'cxGridDBTableViewDataControllerSummaryAfterSummary');
end;

procedure TzDbView.actPersonalizzaExecute(Sender: TObject);
begin
  if Controller.EditProps then
  begin
    // CreateColumns;
    LoadProperties(False);
    // Il layout personale (.Columns) si scrive a ogni spostamento di colonna
    // e alla riapertura LoadFromIni lo rimette sopra il dizionario: senza
    // riscriverlo qui, visibilita' e ordine appena scelti tornavano quelli
    // di prima alla riapertura della vista
    Controller.SaveLayoutToIni;
  end;
end;

procedure TzDbView.SelezionaColonneExecute(Sender: TObject);
begin
  GetDbViewProps.Columns.AssignFromGridColumns(DataController.idDataSet, cxGridDBTableView, ViewID);

  if EditDbViewColumns(Self) then
    Controller.SaveToIni;
end;

procedure TzDbView.doCalcFooters;
begin
  SiMain.EnterMethod(Self, 'doCalcFooters');

  if FCalculatingFooters then
    Exit;

  PostedCommands[cmd_CalcFooters] := False;

  FCalculatingFooters := true;
  try
    if cxGridDBTableView.OptionsView.Footer then
      if Assigned(Controller) then
        Controller.CalculateFooterValues;
  finally
    FCalculatingFooters := False;
  end;

  SiMain.LeaveMethod(Self, 'doCalcFooters');
end;

procedure TzDbView.actDbFirstExecute(Sender: TObject);
begin
  actDbFirst.Enabled := False;
  try
    DataController.First;
  finally
    actDbFirst.Enabled := true;
  end;
end;

procedure TzDbView.actDbLastExecute(Sender: TObject);
begin
  actDbLast.Enabled := False;
  try
    DataController.Last;
  finally
    actDbLast.Enabled := true;
  end;
end;

procedure TzDbView.actDbNextExecute(Sender: TObject);
begin
  actDbNext.Enabled := False;
  try
    DataController.Next;
  finally
    actDbNext.Enabled := true;
  end;
end;

procedure TzDbView.actDbPriorExecute(Sender: TObject);
begin
  actDbPrior.Enabled := False;
  try
    DataController.Prior;
  finally
    actDbPrior.Enabled := true;
  end;
end;

procedure TzDbView.CreateColumns;
var
  Column: TcxGridDBColumn;
  zColumn: TzColumn;
  UseLabel: Boolean;
  zCtrlType: TzCtrlType;
  Domain: TzDomain;
  Field: TField;
  Origin: string;
  Caption: string;
begin
  siDbView.EnterMethod(Self, 'CreateColumns');

  if not DataController.DataSetOk then
    Exit;

  if Assigned(FOnBeforeCreateControls) then
    OnBeforeCreateControls(Self);

  siDbView.LogVerbose('ClearItems');
  cxGridDBTableView.ClearItems;
  siDbView.LogVerbose('DataController.CreateAllItems');
  cxGridDBTableView.DataController.CreateAllItems;

  // attribuire le proprieta
  siDbView.LogVerbose('Columns.ValidateDataset');
  GetDbViewProps.Columns.ValidateDataset(zDataSet);

  siDbView.LogVerbose('Before ciclo For su GetDbViewProps.Columns');

  for zColumn in GetDbViewProps.Columns do
  begin
    siDbView.LogVerbose('Col: ' + zColumn.Name);
    Column := TcxGridDBColumn(cxGridDBTableView.DataController.GetItemByFieldName(zColumn.Name));

    if Assigned(Column) then
    begin
      if not DataController.TryGetField(zColumn.Name, Field) then
        Continue;

      Origin := DataController.GetFieldOrigin(Field);
      Domain := zSystem.zDataDictionary.Get(Origin, true);

      /// ///////////
      // Gerarchia caption griglia:
      // 1. Override cliente (massima priorità)
      // 2. RawCaption: personalizzazione esplicita salvata sulla view
      // 3. Domain.DisplayLabel (default)
      Caption := Overrides.CaptionGrid(DataController.idDataSet, Field.FieldName);

      if Caption.IsEmpty then
      begin
        if not zColumn.RawCaption.IsEmpty then
          Caption := zColumn.RawCaption
        else
          Caption := Domain.DisplayLabel;
      end;

      Column.Caption := Caption;

      /// ///////////

      zCtrlType := zColumn.zCtrlType;
      if zCtrlType = ctDefault then
        zCtrlType := Domain.zCtrlType;

      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if zCtrlType.IsLookup then
        zCtrlType := ctEdit;
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      Column.PropertiesClass := dx.GetPropertiesClass(zCtrlType);
      dx.InitProperties(zCtrlType, Column.GetProperties, Domain, Field);
      Column.GetProperties.Readonly := zColumn.Readonly;
      // Focusing
      Column.Options.Editing := not zColumn.Readonly;

      Column.Options.Sorting := Flags.Sort;

      Column.Width := zColumn.Width;

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
            TcxCustomHyperLinkEditProperties(Column.Properties).UsePrefix := upNever;
            TcxCustomHyperLinkEditProperties(Column.Properties).Prefix := zColumn.Name;
            TcxCustomHyperLinkEditProperties(Column.Properties).OnStartClick := DoHyperLink;
            TcxCustomHyperLinkEditProperties(Column.Properties).SingleClick := true;
          end;
        ctProgressBar:
          ;
        ctCustomDlg:
          ;
        ctColorCombo:
          begin
            // AV se modifiato da card
            // Column.OnGetDisplayText := ColorCombo_OnGetDisplayText;
            Column.OnCustomDrawCell := ColorCombo_OnCustomDrawCell;
          end;
        ctToggleSwitch:
          begin
            TdxToggleSwitchProperties(Column.Properties).StateIndicator.Kind := sikNone;
          end;
      end;
    end;
  end;

  siDbView.LogVerbose('After ciclo For su GetDbViewProps.Columns');

  FocusFirstVisibleColumn;

  if Assigned(FOnAfterCreateControls) then
    OnAfterCreateControls(Self);

  siDbView.LeaveMethod(Self, 'CreateColumns');
end;

procedure TzDbView.DoHyperLink(Sender: TObject);
var
  Column: TcxGridDBColumn;
  Field: TField;
  FieldName: string;
  Value: Variant;
begin

  // Mantis 906
  if Assigned(InplaceFilterControl) then
    if Sender is TComponent then
      if TComponent(Sender).Owner = InplaceFilterControl then
        Exit;

  // doppio click sulla view con dataset chiuso chiama inutilmente DoHyperLink
  if not DataController.IsActive then
    Exit;

  Column := Controller.ActiveColumn;
  if not Assigned(Column) then
    Exit;

  Field := Controller.ActiveField;

  if Column.Properties is TcxCustomHyperLinkEditProperties then
  begin
    FieldName := TcxCustomHyperLinkEditProperties(Column.Properties).Prefix;

    if Assigned(Field) then
    begin
      HyperLinkFieldName := FieldName;
      HyperLinkValue := Field.Value;
      PostInternalMessage(cmd_HyperLink);
    end;
  end;
end;

procedure TzDbView.actDuplicaExecute(Sender: TObject);
var
  NoCopyFields: string;
begin
  if not DataController.DataSetOk then
    Exit;

  NoCopyFields := '';
  if Assigned(GetDbViewProps.DataSet_Obj) then
    NoCopyFields := GetDbViewProps.DataSet_Obj.NoCopyFields;

  DataController.DuplicateRecord(False, NoCopyFields);

  ShowRecord(False);
end;

procedure TzDbView.actPermessiAzioneExecute(Sender: TObject);
var
  Action: TCustomAction;
begin
  Action := TCustomAction(popActions.Tag);

  if Assigned(Action) then
    RestrictionManager.EditComponentRestrictions(ClassName, ccAction, Action.Name);
end;

procedure TzDbView.actProprietaAzioneExecute(Sender: TObject);
var
  Action: TCustomAction;
begin
  Action := TCustomAction(popActions.Tag);

  if Assigned(Action) then
    ConfirmOk('Recuperare zDiagramDataSet per ' + Action.Name);
end;

procedure TzDbView.actResetCaptionColonneExecute(Sender: TObject);
begin
  if not ConfirmYesNo('Reimpostare le caption delle colonne?', mtWarning) then
    Exit;

  // da ripensare
  GetDbViewProps.Columns.ResetColumnCaptions;
  ReloadColumnProps;
end;

procedure TzDbView.ExcelExecute(Sender: TObject);
begin

  if DataController.CloseQuery then
  begin
    DataSource.DataSet := nil;
    try
      DataController.BeforeExport;
      try
        ExportView2Excel(Self);
      finally
        DataController.AfterExport;
      end;
    finally
      DataSource.DataSet := zDataSet;
    end;
  end;
end;

procedure TzDbView.EsportaExecute(Sender: TObject);
begin

  if DataController.CloseQuery then
  begin
    DataSource.DataSet := nil;
    try
      DataController.BeforeExport;
      try
        ExportView(Self);
      finally
        DataController.AfterExport;
      end;
    finally
      DataSource.DataSet := zDataSet;
    end;
  end;
end;

procedure TzDbView.NascondiColonnaExecute(Sender: TObject);
begin
  if Assigned(cxGridDBTableView.Controller.FocusedColumn) then
    cxGridDBTableView.Controller.FocusedColumn.Visible := False;
  // ha senso?
  // SaveColumnsToProps;
  // SaveToIni;
end;

procedure TzDbView.F2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Column: TcxGridDBColumn;
begin

  if Key <> vk_f2 then
    Exit;

  Column := Controller.ActiveColumn;

  // occorre ridefinire i metodi dei vari dlg per accettare delle properties

  // if (column.Properties is cxLookupComboBoxProperties)  then
  // begin
  //
  // if IdLookup <> '' then
  // begin
  // Controls.DataSet.CheckEditMode;
  // ExecuteLookupDlg;
  // Key := 0;
  // end;
  // end
  // else
  // if column.Properties  is TcxMemoProperties then
  // begin
  // DataController.CheckEditMode;
  // zExecuteMemoDialog(Sender as TcxDbMemo, '');
  // Key := 0;
  // end
  // else
  // if column.Properties  is TcxRichEditProperties then
  // begin
  // Controls.DataSet.CheckEditMode;
  // zExecuteRichEditDialog(Sender as TcxDbRichEdit, '');
  // Key := 0;
  // end
  // else
  // if column.Properties  is TcxImageProperties then
  // begin
  // Controls.DataSet.CheckEditMode;
  // zExecuteImageDialog(Sender as TcxDbImage, '');
  // Key := 0;
  // end;
end;

procedure TzDbView.DestroyColumns;
begin
  siDbView.EnterMethod(Self, 'DestroyColumns');

  cxGridDBTableView.ClearItems;

  siDbView.LeaveMethod(Self, 'DestroyColumns');
end;

procedure TzDbView.cxBarItemModifyFlagsPropertiesChange(Sender: TObject);
begin
  PostInternalMessage(cmd_FlagsPropertiesChange);
end;

procedure TzDbView.FlagsPropertiesChange;
var
  s: string;
begin
  if IsDestroying then
    Exit;

  s := cxBarItemModifyFlags.CurEditValue;
  Flags.BeginUpdate;
  try
    Flags.ButtonInsert := s.Substring(0, 1) = '1';
    Flags.ButtonUpdate := s.Substring(1, 1) = '1';
    Flags.ButtonDelete := s.Substring(2, 1) = '1';
  finally
    Flags.EndUpdate;
  end;

  // aggiornare readonly di conseguenza
  s := dx.GetStatesString(Flags.Readonly);
  dx.SetValue(cxBarItemReadOnly, s);
  //
  doSalvaImpostazioni(true);
  LoadProperties(False);
end;

procedure TzDbView.FlushPendingCommands;
var
  cmd: TzDbViewCommand;
begin
  // Riemette i comandi accumulati mentre la view era off-screen.
  // Si lavora su una copia perché PostInternalMessage potrebbe ri-rinviare
  // (e quindi reimpostare FPendingCommands) se per qualche motivo la view
  // non risultasse ancora showing.
  for cmd := Low(TzDbViewCommand) to High(TzDbViewCommand) do
    if FPendingCommands[cmd] then
    begin
      FPendingCommands[cmd] := False;
      PostInternalMessage(cmd);
    end;
end;

procedure TzDbView.cxBarEditItemCardInheritsPropertiesChange(Sender: TObject);
begin
  PostInternalMessage(cmd_PropertiesChange);
end;

procedure TzDbView.cxBarItemReadOnlyPropertiesChange(Sender: TObject);
begin
  PostInternalMessage(cmd_ReadOnlyPropertiesChange);
end;

procedure TzDbView.PopupGridPopup(Sender: TObject);
var
  Field: TField;
  Value: Variant;
  s: String;
begin
  UpdateActions;
  /// ///////////////////////////////////////////////////
  // visiilit� degli item
  dxBarSubItemImpostazioni.Visible := dx.Visible(IsAdmin);
  dxBarEditTitolo.Visible := dx.Visible(IsAdmin);
  cxBarItemReadOnly.Visible := dx.Visible(IsAdmin);
  cxBarItemModifyFlags.Visible := dx.Visible(IsAdmin);
  dxBarItemCardInherits.Visible := dx.Visible(IsAdmin);
  cxBarItemAutoWidth.Visible := dx.Visible(IsAdmin);
  cxBarItemBorder.Visible := dx.Visible(IsAdmin);
  cxBarItemMultiSelect.Visible := dx.Visible(IsAdmin);
  cxBarItemFooter.Visible := dx.Visible(IsAdmin);
  cxBarItemCube.Visible := dx.Visible(IsAdmin);

  /// ///////////////////////////////////////////////////
  // valori
  s := dx.GetStatesString(Flags.Readonly);
  dx.SetValue(cxBarItemReadOnly, s);

  s := dx.GetStatesString([Flags.ButtonInsert, Flags.ButtonUpdate, Flags.ButtonDelete]);
  dx.SetValue(cxBarItemModifyFlags, s);

  s := dx.GetStatesString(Flags.CardInherits);
  dx.SetValue(dxBarItemCardInherits, s);

  dx.SetValue(cxBarItemAutoWidth, Flags.AutoWidth);
  dx.SetValue(cxBarItemBorder, Flags.Border);
  dx.SetValue(cxBarItemMultiSelect, Flags.MultiSelect);
  dx.SetValue(cxBarItemFooter, Flags.Footer);
  dx.SetValue(cxBarItemCube, Flags.Cube);

  /// ///////////////////////////////////////////////////
  /// Filter
  SubmenuFiltriCategoria.Visible := dx.Visible(Flags.Filters);
  if Flags.Filters then
    if DataController.IsActive then
      if not DataController.IsEmpty then
      begin
        Field := Controller.ActiveField;
        if Assigned(Field) then
          // if not Field.IsBlob then   // zz 04.09.2020: tentativo di funzionare con i memo
          Controller.PrepareFilterMenuForField(Field.FieldName, SubmenuFiltriCategoria);
      end;

  CopyName.Caption := 'Copia ViewID - ' + ViewID;
  Localizer.Translate(Self);
end;

/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////////////

procedure TzDbView.InitView;
var
  Misura: boolean;
  Cronometro: TStopwatch;
begin
  siDbView.EnterMethod(Self, 'InitView');
  // Chiamata da SetDataSet

  if cxGridDBTableView.ColumnCount > 0 then
    Exit;

  // Misura per la sessione di registrazione attivabile dall'utente. Copre
  // LoadProperties, CreateColumns e il caricamento del layout personale.
  Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
  if Misura then
    Cronometro := TStopwatch.StartNew;

  if zSystemOk then
    if DataController.DataSetOk then
    begin
      cxGridDBTableView.BeginUpdate;
      try
        LoadProperties(true);
        // posto all'interno del begin/endupdate
        DataSource.DataSet := zDataSet;

        Controller.InitControllers;

        CreateColumns;

        cxGridDBTableView.DataController.KeyFieldNames := DataController.PrimaryKeyFields;

        // a ogni apertura, dopo il layout personale, le colonne strette si
        // allargano al contenuto (AllargaColonneAlContenuto). Con Ctrl si apre
        // col layout del dizionario cosi' com'e', senza allargamenti
        FAdattaLarghezzeInAttesa := False;
        if not CtrlKey then
        begin
          Controller.LoadFromIni;
          FAdattaLarghezzeInAttesa := True;
          LoadUserConditionalFormatting;
        end;
        //
        CheckColumnWidths;
        //
        FocusFirstVisibleColumn;
        //
      finally
        cxGridDBTableView.EndUpdate;
      end;
      // Dopo il layout: i gruppi del dizionario e quelli salvati dall'utente
      // ci sono solo adesso, e OnGroupingChanged puo' non essere arrivato
      // durante BeginUpdate.
      AllineaLocate;
    end;

  if Misura then
    zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, 'TzDbView.InitView', Cronometro.ElapsedMilliseconds, Name);

  siDbView.LeaveMethod(Self, 'InitView');
end;

procedure TzDbView.OnFlagChange(Sender: TObject);
begin
  UpdateActions;
  DisplayToolbars;
  LoadProperties(False);
end;

procedure TzDbView.UpdateActions;
var
  Visible: Boolean;
  CanInsert, CanEdit, CanDelete: Boolean;
begin
  // siDbView.LogVerbose('UpdateActions');

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

  ActionVisible(actDbEdit, (DataController.CanEdit and Flags.ButtonUpdate) or Assigned(FOnDataSetEdit));
  ActionVisible(actDbInsert, (DataController.CanInsert and Flags.ButtonInsert) or Assigned(FOnDataSetInsert));
  ActionVisible(actDuplica, actDbInsert.Visible); //
  ActionVisible(actDbDelete, (DataController.CanDelete and Flags.ButtonDelete) or Assigned(FOnDataSetDelete));
  ActionVisible(actDbRefresh, DataController.CanRefresh and Flags.ButtonRefresh);
  ActionVisible(actDbPost, DataController.CanPost and Flags.ButtonOkCancel);
  ActionVisible(actDbCancel, DataController.CanCancel and Flags.ButtonOkCancel);
  ActionVisible(Parametri, Flags.Params);

  ActionVisible(actFiltriAvanzati, Flags.Filters);
  ActionVisible(actEliminaFiltri, Flags.Filters);
  ActionVisible(actFiltroPerValore, Flags.Filters);
  ActionVisible(actCerca, Flags.Search);

  ActionVisible(actSelezionaTutto, Flags.MultiSelect);
  ActionVisible(actNessuno, Flags.MultiSelect);
  ActionVisible(actCubo, Flags.Cube);

  ActionVisible(MostraQueryUtilizzata, IsAdmin);
  ActionVisible(CopiaQueryUtilizzata, IsAdmin);
  ActionVisible(SalvaImpostazioni, IsAdmin);
  ActionVisible(CaricaImpostazioni, IsAdmin);
  ActionVisible(CopiaColonne, IsAdmin);
  ActionVisible(IncollaColonne, IsAdmin);
  ActionVisible(actResetColonne, IsAdmin);
  ActionVisible(actSQL, IsAdmin);
  ActionVisible(actPersonalizza, IsAdmin);
  ActionVisible(actPersonalizzaColonna, IsAdmin);
  ActionVisible(ShowCard, IsAdmin);
  ActionVisible(CopyName, IsAdmin);
  ActionVisible(NascondiColonna, IsAdmin);
  ActionVisible(ClearIniSectionAllUsers, IsAdmin);

  if Assigned(FOnUpdateActions) then
    OnUpdateActions(Self);
end;

procedure TzDbView.LoadProperties(const LoadDefaults: Boolean);
var
  Column: TcxGridDBColumn;
  isNew: Boolean;
  i: Integer;
begin
  // chiamato da
  // CaricaImpostazioni
  // TitoloChange <-- eliminabile
  // actPersonalizzaExecute
  // InitView

  if csDesigning in ComponentState then
    Exit;

  DataController.Readonly := IsViewReadOnly; // Flags.Readonly;

  if LoadDefaults then
    if DataController.DataSetOk then
      if zSystemOk then
        // begin
        LoadDefaultProps;

  // if zSystem.zDbViews.Exists(ViewID) then // 28.05.2024: a cosa serve ???
  SetTitle(GetDbViewProps.Title);
  //
  GetDbViewProps.ButtonEdit.Apply(actDbEdit, dxBarButtonactDbEdit);
  GetDbViewProps.ButtonDelete.Apply(actDbDelete, dxBarButtonactDbDelete);
  GetDbViewProps.ButtonInsert.Apply(actDbInsert, dxBarButtonactDbInsert);
  GetDbViewProps.ButtonDuplica.Apply(actDuplica, dxBarButtonactDuplica);
  // end;

  // siDbView.LogBoolean('BorderStyle', Flags.Border);
  // if Flags.Border then
  // cxGrid.BorderStyle := cxcbsDefault
  // else
  // cxGrid.BorderStyle := cxcbsNone;
  cxGrid.BorderStyle := cxcbsDefault;

  cxGridDBTableView.OptionsData.CancelOnExit := Flags.Editing; // altrimenti annulla le modifiche fatte a card collegate
  cxGridDBTableView.OptionsData.Editing := Flags.Editing;
  cxGridDBTableView.OptionsView.ColumnAutoWidth := Flags.AutoWidth;
  cxGridDBTableView.OptionsBehavior.IncSearch := False; // Flags.IncrementalSearch;

  cxGridDBTableView.DateTimeHandling.IgnoreTimeForFiltering := Flags.IgnoreTimeForFiltering;

  cxGridDBTableView.OptionsView.Footer := Flags.Footer;
  cxGridDBTableView.OptionsView.GroupByBox := Flags.GroupBy;
  cxGridDBTableView.OptionsView.GroupFooters := Flags.GroupFooters;

  // Gruppi sempre aperti: serve soprattutto ai raggruppamenti di partenza
  // del dizionario (TzColumn.GroupIndex, DateTimeGrouping), che senza
  // aprirebbero la vista con i soli titoli dei gruppi
  if Flags.GroupsAlwaysExpanded then
    cxGridDBTableView.DataController.Options := cxGridDBTableView.DataController.Options + [dcoGroupsAlwaysExpanded]
  else
    cxGridDBTableView.DataController.Options := cxGridDBTableView.DataController.Options - [dcoGroupsAlwaysExpanded];

  cxGridDBTableView.OptionsSelection.MultiSelect := Flags.MultiSelect;

  cxGridDBTableView.OptionsSelection.InvertSelect := not Flags.RowSelect;
  cxGridDBTableView.OptionsSelection.CellSelect := not Flags.RowSelect;

  cxGridDBTableView.OptionsSelection.HideFocusRectOnExit := Flags.HideFocusRectOnExit;

  if Flags.MultiSelect then
    cxGridDBTableView.OptionsSelection.CheckBoxVisibility := [cbvDataRow, cbvColumnHeader]
  else
    cxGridDBTableView.OptionsSelection.CheckBoxVisibility := [];

  cxGridDBTableView.Preview.Column := cxGridDBTableView.GetColumnByFieldName(GetDbViewProps.PreviewFieldName);
  cxGridDBTableView.Preview.Visible := Assigned(cxGridDBTableView.Preview.Column);

  // Flags.Sort
  for i := 0 to cxGridDBTableView.ColumnCount - 1 do
    cxGridDBTableView.Columns[i].Options.Sorting := Flags.Sort;

  // se non è stato creato o è vuoto evita la creazione
  if GetDbViewProps.SearchFields <> '' then
  begin

    Column := cxGridDBTableView.GetColumnByFieldName(GetDbViewProps.SearchFields);
    if Assigned(Column) then
      Column.Focused := true;

    if Flags.Search then
    begin
      if AlreadyShown then
        DisplayFindPanel
      else
        ShouldDisplayFindPanel := true;
    end;
  end;

  RebuildToolbar; // filtri poi azioni

  if not GetDbViewProps.ConditionalFormatting.IsEmpty then
    zDxConditionalFormattings.SetConditionalFormattings(cxGridDBTableView, GetDbViewProps.ConditionalFormatting);

  LoadDescription();

  UpdateActions;
end;

function TzDbView.GetFlags: TzDbViewFlags;
begin
  result := Controller.Flags;
end;

function TzDbView.ColumnByName(const FieldName: string): TcxGridDBColumn;
begin
  result := cxGridDBTableView.GetColumnByFieldName(FieldName);
end;

procedure TzDbView.CopiaColonneExecute(Sender: TObject);
begin
  GetDbViewProps.Columns.AssignFromGridColumns(DataController.idDataSet, cxGridDBTableView, ViewID);
  ClipBoard.AsText := GetDbViewProps.Columns.AsText;
end;

procedure TzDbView.actResetColonneExecute(Sender: TObject);
begin
  if not ConfirmYesNo('Azzerare posizione e visibilità dei campi?') then
    Exit;

  // da ripensare
  GetDbViewProps.Columns.Reset(zDataSet);
  ReloadColumnProps;
end;

procedure TzDbView.AddDetailDataSet(Master, Detail: TzFbDataSet; const Caption: string);
var
  MasterLevel: TcxGridLevel;
  DetailLevel: TcxGridLevel;
  DataSource: TDataSource;
  view: TcxGridDBTableView;
begin
  // cerca il level master
  if Master = zDataSet then
    MasterLevel := cxGrid.levels[0]
  else
    DetailLevels.TryGetValue(Master, MasterLevel);

  if not Assigned(MasterLevel) then
    raise exception.Create('Livello non trovato per il dataset master ' + Master.Name);

  // aggiunge l'evento al master
  TcxGridDBDataController(MasterLevel.GridView.DataController).OnDetailHasChildren := DetailHasChildren;

  // crea il level detail
  DetailLevel := MasterLevel.Add;
  DetailLevels.Add(Detail, DetailLevel);
  DetailLevel.Name := 'level' + Detail.Name;
  DetailLevel.Caption := Caption;
  DetailLevel.Options.DetailTabsPosition := dtpLeft;

  // crea il detailDataSource
  DataSource := TDataSource.Create(Self);
  DataSource.Name := Detail.Name + 'Src';
  DataSource.DataSet := Detail;
  // crea la view
  view := cxGrid.CreateView(TcxGridDBTableView) as TcxGridDBTableView;
  view.Name := 'view' + Detail.Name;
  view.DataController.DataModeController.GridMode := true;
  view.DataController.DataSource := DataSource;
  view.DataController.CreateAllItems;
  view.OptionsView.GroupByBox := False;
  //
  DetailLevel.GridView := view;
end;

procedure TzDbView.AddFilterCondition(FieldName: string; OperatorKind: TcxFilterOperatorKind; Value: Variant; Checked: Boolean = true; Overwrite: Boolean = true);
begin
  Controller.AddFilterCondition(FieldName, OperatorKind, Value, Checked, Overwrite);
end;

function TzDbView.AreAllRowsSelected: Boolean;
begin
  result := cxGridDBTableView.DataController.AreAllRowsSelected;

  if not result then
    result := (cxGridDBTableView.Controller.SelectedRecordCount > 0) and (cxGridDBTableView.Controller.SelectedRecordCount >= cxGridDBTableView.DataController.RecordCount);
end;

// procedure TzDbView.ColorCombo_OnGetDisplayText(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AText: string);
// var
// v: Variant;
// Column: TcxGridDBColumn;
// cxColorComboBoxProperties: TcxColorComboBoxProperties;
// begin
// inherited;
// if Sender is TcxGridDBColumn then
// begin
// Column := TcxGridDBColumn(Sender);
//
// v := ARecord.Values[Column.index];
// if varIsNull(v) then
// Exit;
//
// if Column.Properties is TcxColorComboBoxProperties then
// begin
// cxColorComboBoxProperties := Column.Properties as TcxColorComboBoxProperties;
//
// if not Assigned(cxColorComboBoxProperties.Items.FindColorItem(v)) then
// if not Assigned(cxColorComboBoxProperties.CustomColors.FindColorItem(v)) then
// cxColorComboBoxProperties.CustomColors.AddColor(v, ''); AV se modificato da card
// end;
// end;
// end;

procedure TzDbView.cxGridDBTableViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
  siDbView.LogVerbose('cxGridDBTableViewSelectionChanged');

  if Assigned(FOnSelectionChanged) then
    OnSelectionChanged(Sender);
end;

procedure TzDbView.DetailHasChildren(Sender: TcxDBDataController; ARecordIndex, ARelationIndex: Integer; const AMasterDetailKeyFieldNames: string; const AMasterDetailKeyValues: Variant; var HasChildren: Boolean);
begin
  HasChildren := Sender.GetDetailDataController(ARecordIndex, ARelationIndex).RecordCount <> 0;
end;

function TzDbView.FilterCount: Integer;
begin
  result := Controller.FilterCount;
end;

procedure TzDbView.FocusGrid;
begin
  cxGridDBTableView.Focused := true;

  if Assigned(cxGridDBTableView.Controller.FocusedRow) then
    cxGridDBTableView.Controller.FocusedRow.Selected := true;
end;

procedure TzDbView.ForEach(proc: TProc; Direction: TEnumDirection = edAscending);
begin
  EnumSelectedRows(proc, Direction);
end;

procedure TzDbView.IncollaColonneExecute(Sender: TObject);
begin
  GetDbViewProps.Columns.AsText := ClipBoard.AsText;
  GetDbViewProps.Columns.ValidateDataset(zDataSet);
  ReloadColumnProps;
end;

function TzDbView.IsActiveControl: Boolean;
begin
  result := dx.IsActiveControl(cxGrid);
end;

function TzDbView.SelectedCount: Integer;
begin
  result := cxGridDBTableView.Controller.SelectedRecordCount;
end;

procedure TzDbView.SelectRecord;
begin
  if Assigned(cxGridDBTableView.Controller.FocusedRecord) then
    cxGridDBTableView.Controller.FocusedRecord.Selected := true;
end;

procedure TzDbView.SelectRow(const index: Integer);
begin
  if index >= 0 then
    if index < cxGridDBTableView.Controller.SelectedRowCount then
      DataController.GotoBookmark(cxGridDBTableView.DataController.GetSelectedBookmark(index));
end;

procedure TzDbView.DeleteConditionsForField(FieldName: string);
begin
  Controller.DeleteConditionsForField(FieldName);
end;

function TzDbView.IsEditing: Boolean;
begin
  result := cxGridDBTableView.Controller.EditingController.IsEditing;
end;

procedure TzDbView.SetColumnEditability(const FieldName: string; Editability: TEditability);
var
  Column: TcxGridDBColumn;
begin
  Column := cxGridDBTableView.GetColumnByFieldName(FieldName);

  if Assigned(Column) then
    dx.SetEditability(Column, Editability);
end;

procedure TzDbView.DrawImage(Canvas: TcxCanvas; ViewInfo: TcxGridTableDataCellViewInfo; ImageList: TCustomImagelist; const ImageIndex: TImageIndex);
var
  Painter: TcxPainterAccess;
begin
  Assert(Assigned(Canvas));
  Assert(Assigned(ViewInfo));
  Assert(Assigned(ImageList));

  TcxCustomTextEditViewInfo(ViewInfo.EditViewInfo).TextRect.Left := TcxCustomTextEditViewInfo(ViewInfo.EditViewInfo).TextRect.Left + ImageList.Width + 1;
  Painter := TcxPainterAccess(TcxViewInfoAcess(ViewInfo).GetPainterClass.Create(Canvas, ViewInfo));
  try
    Painter.DrawContent;
    Painter.DrawBorders;
    ImageList.Draw(Canvas.Canvas, ViewInfo.ClientBounds.Left + 1, ViewInfo.ClientBounds.Top + 1, ImageIndex);
  finally
    Painter.Free;
  end;
end;

function TzDbView.DataCellFieldName(AViewInfo: TcxGridTableDataCellViewInfo): string;
begin
  result := '';

  if Assigned(AViewInfo) then
    if AViewInfo.RecordViewInfo.index <> -1 then
      if AViewInfo.EditViewInfo is TcxCustomTextEditViewInfo then
        if AViewInfo.Item is TcxGridDBColumn then
          result := TcxGridDBColumn(AViewInfo.Item).DataBinding.FieldName;
end;

function TzDbView.DataCellValue(cxCustomGridTableView: TcxCustomGridTableView; ViewInfo: TcxGridTableDataCellViewInfo): Variant;
begin
  result := null;

  if Assigned(cxCustomGridTableView) then
    if Assigned(ViewInfo) then
      result := cxCustomGridTableView.DataController.Values[ViewInfo.GridRecord.RecordIndex, ViewInfo.Item.index];
end;

procedure TzDbView.CheckColumnWidths;
var
  i: Integer;
begin
  siDbView.EnterMethod(Self, 'CheckColumnWidths');

  // allargamento al contenuto dopo l'apertura: si rinvia con un messaggio,
  // perche' qui la griglia puo' non aver ancora caricato le righe del
  // dataset appena aperto (i collegamenti al DataSource si avvisano in un
  // ordine qualunque) e la misura darebbe le sole intestazioni
  if FAdattaLarghezzeInAttesa then
    if DataController.IsActive then
      PostInternalMessage(cmd_AdattaLarghezze);

  //
  // post conversione: verifica se deve chiamare AutoWidth;
  //

  if not AlreadyShown then // non visualizzata, non avrebbe le info sulle colonne
    Exit;

  if not DataController.IsActive then // dataset non ancora attivato
    Exit;

  if cxGridDBTableView.ColumnCount = 0 then // non sono state create le colonne
    Exit;

  if not ShouldCheckColumnWidths then // gi� applicato
    Exit;

  ShouldCheckColumnWidths := False;

  /// ////////////////////////////////////////////

  for i := 0 to cxGridDBTableView.ColumnCount - 1 do
    if cxGridDBTableView.Columns[i].Visible then
      if cxGridDBTableView.Columns[i].Width > 20 then
        Exit;

  ApplyBestFit;
  // ZZ 16 gennaio 2019 doSalvaImpostazioni;
  siDbView.LeaveMethod(Self, 'CheckColumnWidths');
end;

procedure TzDbView.AllargaColonneAlContenuto;
const
  // la misura del testo costa per ogni cella: le prime righe bastano a dare
  // la larghezza tipica, e il tempo resta lo stesso con cento o centomila
  // record. ApplyBestFit (comando dell'utente) misura invece tutte le righe
  RigheMisurate = 200;
  // tetto all'allargamento automatico, a 96 DPI: un testo lungo (note,
  // descrizioni) non deve spingere fuori schermo le colonne successive
  LarghezzaMassima = 400;
var
  i: Integer;
  Colonne: TArray<TcxGridColumn>;
  Larghezze: TArray<Integer>;
  Tetto: Integer;
begin
  siDbView.EnterMethod(Self, 'AllargaColonneAlContenuto');

  if IsDestroying or not FAdattaLarghezzeInAttesa then
    Exit;

  if not DataController.IsActive then
    Exit;

  // con le colonne adattate alla larghezza della griglia (Flags.AutoWidth)
  // le larghezze le decide la griglia: non c'e' niente da adattare
  if cxGridDBTableView.OptionsView.ColumnAutoWidth then
  begin
    FAdattaLarghezzeInAttesa := False;
    Exit;
  end;

  if cxGridDBTableView.VisibleColumnCount = 0 then
    Exit;

  // griglia vuota: si misurerebbero le sole intestazioni. Si riprova al
  // prossimo cambio di stato del dataset (CheckColumnWidths da
  // DataSourceStateChange)
  if cxGridDBTableView.DataController.RowCount = 0 then
    Exit;

  FAdattaLarghezzeInAttesa := False;

  // le colonne si allargano soltanto: la larghezza finale e' la maggiore fra
  // quella del layout (personale o del dizionario) e quella misurata, con il
  // tetto. Una colonna allargata a mano resta com'e'; una stretta di proposito
  // torna larga quanto il contenuto, perche' un dato tagliato non si legge.
  // Le misure di DevExpress comprendono intestazione e immagine delle
  // colonne con icona (TcxImageComboBoxProperties)
  SetLength(Colonne, cxGridDBTableView.VisibleColumnCount);
  SetLength(Larghezze, cxGridDBTableView.VisibleColumnCount);
  for i := 0 to High(Colonne) do
  begin
    Colonne[i] := cxGridDBTableView.VisibleColumns[i];
    Larghezze[i] := Colonne[i].Width;
  end;

  Tetto := MulDiv(LarghezzaMassima, CurrentPPI, 96);

  cxGridDBTableView.OptionsBehavior.BestFitMaxRecordCount := RigheMisurate;

  cxGridDBTableView.BeginUpdate;
  try
    cxGridDBTableView.BeginBestFitUpdate;
    try
      for i := 0 to High(Colonne) do
        Colonne[i].ApplyBestFit();
    finally
      cxGridDBTableView.EndBestFitUpdate;
    end;

    for i := 0 to High(Colonne) do
      if Colonne[i].Width < Larghezze[i] then
        Colonne[i].Width := Larghezze[i]
      else
        if Colonne[i].Width > Tetto then
          Colonne[i].Width := Max(Larghezze[i], Tetto);
  finally
    cxGridDBTableView.EndUpdate;
  end;

  // niente salvataggio: l'allargamento si ripete a ogni apertura, e il layout
  // personale resta quello che l'utente ha deciso

  siDbView.LeaveMethod(Self, 'AllargaColonneAlContenuto');
end;

procedure TzDbView.ClearIniSectionAllUsersExecute(Sender: TObject);
begin
  Controller.Storage.ClearIniSectionAllUsers;
end;

procedure TzDbView.ClearSelection;
begin
  cxGridDBTableView.Controller.ClearSelection;
  RecordCount.Caption := 'N° Records';
end;

procedure TzDbView.SetFooterValue(const FieldName: string; Value: Variant);
var
  idx: Integer;
  Column: TcxGridDBColumn;
begin
  Column := cxGridDBTableView.GetColumnByFieldName(FieldName);

  idx := cxGridDBTableView.DataController.Summary.FooterSummaryItems.IndexOfItemLink(Column);
  if idx <> -1 then
    cxGridDBTableView.DataController.Summary.FooterSummaryValues[idx] := Value;
end;

procedure TzDbView.cxGridDBTableViewDblClick(Sender: TObject);
var
  cxGridSite: TcxGridSite;
  HitTest: TcxCustomGridHitTest;
  Point: TPoint;
  view: TcxGridDBTableView;
  Column: TcxGridDBColumn;
  isHyperLink: Boolean;
begin
  if not(Sender is TcxGridSite) then
    Exit;

  cxGridSite := TcxGridSite(Sender);
  view := cxGridSite.GridView as TcxGridDBTableView;
  // il punto del doppio clic e' quello della pressione, non dove sta il
  // cursore ora: per l'utente coincidono, la sonda di collaudo spedisce i
  // messaggi senza muovere il cursore vero (R-218)
  Point := cxGridSite.MouseDownPos;
  HitTest := view.ViewInfo.GetHitTest(Point);

  // if HitTest.HitTestCode in [htNone, htCell] then
  // togliere htNone e provare
  if HitTest.HitTestCode in [htNone, htCell] then
  begin
    // TcxGridRecordCellHitTest
    // if HitTest is TcxCustomGridColumnHitTest then
    // begin
    // Column := TcxGridDBColumn(TcxCustomGridColumnHitTest(HitTest).Column);
    //
    // if Column.GetProperties is TcxCustomHyperLinkEditProperties then
    // begin
    // DoHyperLink(Self);
    // Exit;
    // end;
    // end;

    Column := Controller.ActiveColumn;
    isHyperLink := Assigned(Column) and (Column.GetProperties is TcxCustomHyperLinkEditProperties) and (HitTest.HitTestCode = htCell { esclude la htNone } );

    if isHyperLink then
      DoHyperLink(Self)
    else
      ShowRecord(False);
  end;
end;

procedure TzDbView.CMShowingChanged(var M: TMessage);
begin
  inherited;

  if not Showing then
    Exit;

  AlreadyShown := true;

  CheckColumnWidths;

  if ShouldDisplayFindPanel then
  begin
    ShouldDisplayFindPanel := False;
    DisplayFindPanel;
  end;

  // Riemette i comandi rinviati mentre la view era su una pagina non attiva
  // (filtro impostato off-screen, azioni non aggiornate, ecc.).
  FlushPendingCommands;

  // Garantisce che lo stato delle azioni (es. visibilita' di actDbInsert)
  // sia ricalcolato ad ogni ritorno in primo piano, anche senza pending.
  PostInternalMessage(cmd_UpdateActions);

  PostInternalMessage(cmd_DisplayToolbars);
end;

procedure TzDbView.cxGridDBTableViewFilterControlDialogShow(Sender: TObject);
var
  Frm: TfmFilterControlDialog;
begin
  Frm := Sender as TfmFilterControlDialog;
  Frm.btOpen.Visible := False;
  Frm.btSave.Visible := False;
  Frm.FilterControl.AlignWithMargins := true;

  Frm.Font.Assign(Self.Font);
  // ZC 30.10.2026: Size convertiva i 10 punti con la PixelsPerInch del carattere (dpi di
  // sistema), non con i dpi della finestra: con due monitor a scala diversa il testo
  // risultava piu' grande o piu' piccolo del dovuto. Height usa i dpi logici della finestra.
  Frm.Font.Height := -MulDiv(10, dxGetFormDPI(Frm), 72);

  Frm.FilterControl.SortItems := true;

  dx.SetFilterControlFonts(Frm.FilterControl);
end;

procedure TzDbView.cxGridDBTableViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  AHitTest: TcxCustomGridHitTest;
begin
  siDbView.LogVerbose('cxGridDBTableViewMouseDown');
  AHitTest := TcxGridSite(Sender).ViewInfo.GetHitTest(X, Y);
  siDbView.LogString('cxGridDBTableViewMouseDown', AHitTest.ClassName);

  if AHitTest is TcxGridIndicatorHeaderHitTest then
  begin
    ApplyBestFit;
    if not CtrlKey then
      Controller.SaveToIni;
  end;
end;

function TzDbView.GetValue(const FieldName: string; RecordIndex: Integer): Variant;
var
  Column: TcxGridDBColumn;
begin
  result := null;

  Column := cxGridDBTableView.GetColumnByFieldName(FieldName);

  if Assigned(Column) then
    result := cxGridDBTableView.DataController.GetValue(RecordIndex, Column.index);
end;

function TzDbView.GetValue(const FieldName: string): Variant;
begin
  result := GetValue(FieldName, cxGridDBTableView.DataController.FocusedRecordIndex);
end;

procedure TzDbView.NomeFileIniExecute(Sender: TObject);
var
  s: string;
begin
  s := Controller.Storage.IniFileName;

  ClipBoard.AsText := s;
  ConfirmOk(s);
end;

procedure TzDbView.SetRestrictionReadOnly(const Value: Boolean);
begin
  FRestrictionReadOnly := Value;
  DataController.Readonly := IsViewReadOnly;
end;

procedure TzDbView.CreateInplaceFilterControl;
begin
  InplaceFilterControl := TzFilterControl.Create(Self);
  InplaceFilterControl.Visible := False;
  InplaceFilterControl.Parent := Self;
  // InplaceFilterControl.AlignWithMargins := true;
  InplaceFilterControl.Align := alTop;
  InplaceFilterControl.Top := 0;
  InplaceFilterControl.Height := 50;
  InplaceFilterControl.LinkComponent := cxGridDBTableView;
  InplaceFilterControl.OnChange := InplaceFilterControlChanged;
  InplaceFilterControl.PopupMenu := popFilter;
  InplaceFilterControl.HotTrackOnUnfocused := False;
  InplaceFilterControl.SortItems := true;
  dx.SetFilterControlFonts(InplaceFilterControl);
end;

procedure TzDbView.SetOnBeforeExecuteCardDlg(const Value: TzOnDbCardDlgEvent);
begin
  FOnBeforeExecuteCardDlg := Value;
  zDbCardDlg.OnBeforeExecute := Value;
end;

procedure TzDbView.SetOnCardBeforeCreateControl(const Value: TBeforeCreateControlEvent);
begin
  FOnCardBeforeCreateControl := Value;
  zDbCardDlg.OnBeforeCreateControl := Value;
end;

procedure TzDbView.SetOnCardBeforeCreateDbControl(const Value: TBeforeCreateDbControlEvent);
begin
  FOnCardBeforeCreateDbControl := Value;
  zDbCardDlg.OnBeforeCreateDbControl := Value;
end;

procedure TzDbView.SetOnCardBeforeCreateControls(const Value: TNotifyEvent);
begin
  FOnCardBeforeCreateControls := Value;
  zDbCardDlg.OnBeforeCreateControls := Value;
end;

procedure TzDbView.SetOnCardAfterCreateControl(const Value: TAfterCreateControlEvent);
begin
  FOnCardAfterCreateControl := Value;
  zDbCardDlg.OnAfterCreateControl := Value;
end;

procedure TzDbView.SetOnCardAfterCreateDbControl(const Value: TAfterCreateDbControlEvent);
begin
  FOnCardAfterCreateDbControl := Value;
  zDbCardDlg.OnAfterCreateDbControl := Value;
end;

procedure TzDbView.SetOnCardAfterCreateControls(const Value: TNotifyEvent);
begin
  FOnCardAfterCreateControls := Value;
  zDbCardDlg.OnAfterCreateControls := Value;
end;

procedure TzDbView.InplaceFilterControlChanged(Sender: TObject);
begin
  siDbView.EnterMethod(Self, 'InplaceFilterControlChanged');

  siDbView.LogColored(clRed, 'ApplyFilter');
  InplaceFilterControl.ApplyFilter;
  UpdateInplaceFilterControlVisibility;

  siDbView.LeaveMethod(Self, 'InplaceFilterControlChanged');
end;

procedure TzDbView.CercaColonnaExecute(Sender: TObject);
var
  cols: TStringList;
  FieldName: string;
  i: Integer;
  X: Integer;
begin
  cols := TStringList.Create;
  try
    for i := 0 to cxGridDBTableView.VisibleColumnCount - 1 do
      cols.AddPair(cxGridDBTableView.VisibleColumns[i].Caption, TcxGridDBColumn(cxGridDBTableView.VisibleColumns[i]).DataBinding.FieldName);

    FieldName := '';
    if InputCombo('Cerca colonna', 'Cerca colonna', FieldName, cols) then
      if not FieldName.IsEmpty then
      begin
        Controller.ActiveFieldName := FieldName;

        X := 0;
        for i := 0 to Controller.ActiveColumn.VisibleIndex - 1 do
          inc(X, cxGridDBTableView.VisibleColumns[i].Width);

        cxGridDBTableView.Controller.LeftPos := X;
        // cxGridDBTableView.Controller.LeftPos := cxGridDBTableView.ViewInfo.HeaderViewInfo.Items[Controller.ActiveColumn.Index].Bounds.Left;
      end;
  finally
    FreeAndNil(cols);
  end;
end;

procedure TzDbView.CaricaFiltriAccept(Sender: TObject);
begin
  if DataController.CloseQuery then
    if Assigned(InplaceFilterControl) then
    begin
      InplaceFilterControl.LoadFromFile(CaricaFiltri.Dialog.FileName);
      InplaceFilterControl.Changed;
    end;
end;

procedure TzDbView.SalvaDisposizioneColonneExecute(Sender: TObject);
begin
  Controller.SaveToIni;
end;

procedure TzDbView.SalvaFiltriAccept(Sender: TObject);
begin
  if Assigned(InplaceFilterControl) then
    InplaceFilterControl.SaveToFile(SalvaFiltri.Dialog.FileName);
end;

procedure TzDbView.ColorCombo_OnCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var aDone: Boolean);
var
  Color: Integer;
  r: trect;
begin
  inherited;

  aDone := true;
  ACanvas.FillRect(AViewInfo.Bounds, ACanvas.Brush.Color);

  if varIsNull(AViewInfo.Value) then
    Exit;

  if not VarIsNumeric(AViewInfo.Value) then
    Exit;

  Color := AViewInfo.Value;
  r := AViewInfo.Bounds;
  r.Inflate(-5, -3);
  ACanvas.FillRect(r, Color);
end;

procedure TzDbView.cxGridDBTableViewColumnPosChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
begin
  PostInternalMessage(cmd_ColumnPosChanged);
end;

procedure TzDbView.cxGridDBTableViewColumnSizeChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
begin
  // prima la larghezza cambiata a mano si perdeva alla chiusura: il layout
  // personale si salvava solo spostando una colonna. Il messaggio raccoglie
  // in una sola scrittura i ridimensionamenti ravvicinati
  PostInternalMessage(cmd_ColumnSizeChanged);
end;

procedure TzDbView.EnumSelectedRows(proc: TProc; Direction: TEnumDirection);
var
  i: Integer;
  FocusedRecord: TcxCustomGridRecord;
  BookmartGetSelectedRows: TBytes;

  procedure BeforeGetSelectedRows;
  begin
    StartWait('Attendere...', true);

    FocusedRecord := nil;
    BookmartGetSelectedRows := nil;

    if cxGridDBTableView.DataController.IsGridMode then
    begin
      DataController.DisableControls;
      BookmartGetSelectedRows := zDataSet.Bookmark;
    end
    else
      FocusedRecord := cxGridDBTableView.Controller.FocusedRecord;
  end;

  procedure AfterGetSelectedRows;
  begin
    try
      if cxGridDBTableView.DataController.IsGridMode then
      begin
        DataController.GotoBookmark(BookmartGetSelectedRows);
        DataController.EnableControls;
      end
      else
        if Assigned(FocusedRecord) then
          FocusedRecord.Focused := true;
    except
      // av vari
    end;

    StopWait;
  end;

begin
  Assert(Assigned(proc));

  if not DataController.DataSetOk then
    Exit;

  if DataController.IsEmpty then
    Exit;

  BeforeGetSelectedRows;
  try
    if cxGridDBTableView.Controller.SelectedRowCount = 0 then
      proc
    else
      if AreAllRowsSelected then
      begin
        if Direction = edAscending then
        begin
          DataController.DataSet.First;
          while not DataController.DataSet.Eof do
          begin
            proc;
            DataController.DataSet.Next;
          end;
        end
        else
        begin
          DataController.DataSet.Last;

          while not DataController.DataSet.Bof do
          begin
            proc;
            DataController.DataSet.Prior;
          end;

          // prior/bof
          if not DataController.IsEmpty then
            proc;
        end;
      end
      else
        // gridMode, direttamente tramite bookmark
        if cxGridDBTableView.DataController.IsGridMode then
        begin

          if Direction = edAscending then
          begin
            for i := 0 to cxGridDBTableView.Controller.SelectedRowCount - 1 do
            begin
              DataController.GotoBookmark(cxGridDBTableView.DataController.GetSelectedBookmark(i));
              proc;
            end;
          end
          else
          begin
            for i := cxGridDBTableView.Controller.SelectedRowCount - 1 downto 0 do
            begin
              DataController.GotoBookmark(cxGridDBTableView.DataController.GetSelectedBookmark(i));
              proc;
            end;
          end;
        end
        else
          // � in LoadAllRecs
          if not cxGridDBTableView.DataController.IsGridMode then
          begin

            if Direction = edAscending then
            begin

              for i := 0 to cxGridDBTableView.Controller.SelectedRecordCount - 1 do
              begin
                cxGridDBTableView.Controller.SelectedRecords[i].Focused := true;
                DataController.GotoBookmark(cxGridDBTableView.DataController.DataSet.GetBookmark);
                proc;
              end;
            end
            else
            begin

              for i := cxGridDBTableView.Controller.SelectedRecordCount - 1 downto 0 do
              begin
                cxGridDBTableView.Controller.SelectedRecords[i].Focused := true;
                DataController.GotoBookmark(cxGridDBTableView.DataController.DataSet.GetBookmark);
                proc;
              end;
            end;
          end;
  finally
    AfterGetSelectedRows;
  end;
end;

procedure TzDbView.PropertiesChange;
var
  s: string;
begin
  if IsDestroying then
    Exit;

  Flags.BeginUpdate;
  try
    Flags.CardInherits := dxBarItemCardInherits.CurEditValue = '1';
  finally
    Flags.EndUpdate;
  end;

  doSalvaImpostazioni(true);
  LoadProperties(False);
end;

procedure TzDbView.PostInternalMessage(const cmd: TzDbViewCommand);
begin

  if PostedCommands[cmd] then
  begin
    siDbView.LogVerbose(PChar(Format('POST-SKIP (already posted) cmd=%d', [Ord(cmd)])));
    Exit;
  end;

  if not HandleAllocated then
  begin
    siDbView.LogVerbose(PChar(Format('POST-DEFER (no handle) cmd=%d', [Ord(cmd)])));
    FPendingCommands[cmd] := true;
    Exit;
  end;

  if not Showing then
  begin
    siDbView.LogVerbose(PChar(Format('POST-DEFER (no showing) cmd=%d', [Ord(cmd)])));
    FPendingCommands[cmd] := true;
    Exit;
  end;

  PostedCommands[cmd] := true;
  if not PostMessage(Self.Handle, ZZ_DBVIEW, NativeUInt(cmd), 0) then
    PostedCommands[cmd] := False; // post fallito: rilascia subito

  siDbView.LogVerbose(PChar(Format('POST cmd=%d hwnd=%d posted=%d', [Ord(cmd), Self.Handle, Ord(PostedCommands[cmd])])));
end;

procedure TzDbView.MessageHandler(var Message: TMessage);
var
  cmd: TzDbViewCommand;
begin
  siDbView.LogVerbose(PChar(Format('HANDLE cmd=%d hwnd=%d', [Ord(TzDbViewCommand(Message.WParam)), Self.Handle])));

  inherited;

  siDbView.LogVerbose(PChar(Format('HANDLE post-inherited Msg=%d WParam=%d Result=%d', [Message.Msg, Message.WParam, Message.result])));

  cmd := TzDbViewCommand(Message.WParam);
  try
    Case cmd of
      cmd_UpdateActions:
        UpdateActions;

      cmd_DisplayToolbars:
        DisplayToolbars;

      cmd_DisplayFindPanel:
        DoShowFindPanel;
      cmd_SetTitle:
        begin
          if not IsDestroying then
            SetTitle(GetDbViewProps.Title);
        end;
      cmd_HyperLink:
        begin
          if not IsDestroying then
            zSystem.HyperLink(Self, HyperLinkFieldName, HyperLinkValue);
        end;
      cmd_FlagsPropertiesChange:
        FlagsPropertiesChange;
      cmd_PropertiesChange:
        PropertiesChange;
      cmd_ReadOnlyPropertiesChange:
        ReadOnlyPropertiesChange;
      cmd_ColumnPosChanged:
        begin
          if not IsDestroying then
            Controller.SaveToIni;
        end;
      cmd_FilterChanged:
        InternalFilterChanged;
      cmd_CalcFooters:
        doCalcFooters;
      cmd_ColumnSizeChanged:
        begin
          // solo il layout personale, anche per l'amministratore: salvare
          // nel dizionario LZ a ogni trascinamento mostrerebbe ogni volta la
          // finestra di attesa. Per il dizionario resta Salva impostazioni
          if not IsDestroying then
            Controller.SaveLayoutToIni;
        end;
      cmd_AdattaLarghezze:
        AllargaColonneAlContenuto;
    end;

  finally
    PostedCommands[cmd] := False;
  end;
end;

procedure TzDbView.DoShowFindPanel;
begin

  try
    if not IsDestroying then
      cxGridDBTableView.Controller.ShowFindPanel;

    if cxGridDBTableView.Controller.IsFindPanelVisible then
      if Assigned(cxGridDBTableView.Controller.FocusedColumn) then
        cxGridDBTableView.FindPanel.InfoText := cxGridDBTableView.Controller.FocusedColumn.Caption
  except
  end;
end;

procedure TzDbView.cxGridDBTableViewFocusedItemChanged(Sender: TcxCustomGridTableView; APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
// var
// AEdit: TcxFindPanelMRUEdit;
begin
  // siDbView.LogVerbose('cxGridDBTableViewFocusedItemChanged');

  if cxGridDBTableView.Controller.IsFindPanelVisible then
    if Assigned(cxGridDBTableView.Controller.FocusedColumn) then
      cxGridDBTableView.FindPanel.InfoText := cxGridDBTableView.Controller.FocusedColumn.Caption
      // sarebbero da riempire se provengono da picklist/boolean (occhio:maplist?)
      // MRUItems

      // AEdit := TcxGridFindPanelAccess(TcxGridTableControllerAccess(cxGridDBTableView.Controller).FindPanel).Edit;
end;

procedure TzDbView.CreateActionsFromProps;
begin
  TzActionBuilder.BuildFromProps(GetDbViewProps.ToolActions, ToolActions, GetActionOwner);
  InitToolActions;
end;

function TzDbView.GetActionOwnerName: string;
begin
  result := GetDbViewProps.ActionOwnerName;
end;

procedure TzDbView.SetActionOwnerName(const Value: string);
begin
  GetDbViewProps.ActionOwnerName := Value;
end;

function TzDbView.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, GetDbViewProps.ActionOwnerName);
end;

procedure TzDbView.RebuildToolbar; // IzBaseComponent.RebuildToolbar — filtri poi azioni
begin
  // Prima i filtri, poi le azioni: i filtri precedono le azioni sulla barra.
  CreateFiltersFromProps;
  CreateActionsFromProps;
  DisplayToolbars;
end;

procedure TzDbView.RebuildActions;
begin
  RebuildToolbar;
  doSalvaImpostazioni(true);
end;

procedure TzDbView.RebuildFilters;
begin
  RebuildToolbar;
  doSalvaImpostazioni(true);
end;

function TzDbView.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := ViewID;
end;

procedure TzDbView.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbView.PermessiExecute(Sender: TObject);
begin

  if Assigned(RestrictionManager) then
    RestrictionManager.EditComponentRestrictions(Owner.ClassName, ccView, ViewID);
end;

procedure TzDbView.PermessiUpdate(Sender: TObject);
begin
  Permessi.Visible := Assigned(zSystem) and zSystem.CanEditRestrictions; // and Assigned(RestrictionManager)
end;

procedure TzDbView.popActionsPopup(Sender: TObject);
begin

  if Assigned(zSystem) then
    if not zSystem.CanEditRestrictions then
      System.SysUtils.Abort;
end;

procedure TzDbView.FrameResize(Sender: TObject);
begin
  RealignToolbars;
end;

procedure TzDbView.RealignToolbars;
var
  w1, w2: Integer;
  row: Integer;
begin
  // Prima di misurare: i filtri devono formare un gruppo per conto loro,
  // altrimenti l'ultimo di essi scende a capo insieme ai pulsanti delle
  // azioni. Sta qui, e non dove i filtri vengono creati, perche' filtri e
  // azioni arrivano sulla barra in momenti diversi e nessuno dei due sa se
  // l'altro c'e' gia'. Qui invece la barra e' completa, e la chiamata si
  // ripete a ogni ridimensionamento senza costare niente: scrive solo la
  // prima volta.
  TzDxBarHelper.ChiudiGruppoDeiFiltri(dxBarToolbarFree);

  w1 := dx.dxBarRequiredWidth(dxBarToolbar);
  w2 := dx.dxBarRequiredWidth(dxBarToolbarFree);

  if w1 + w2 > Self.ClientWidth then
    row := 1
  else
    row := 0;

  if dxBarToolbarFree.row <> row then
    dxBarToolbarFree.row := row;
end;

function TzDbView.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
var
  Props: TzToolActionsProps;
begin
  // Scrive sull'unica sorgente autorevole (i props persistiti), non sul runtime:
  // il runtime ToolActions viene rigenerato da CreateActionsFromProps/BuildFromProps.
  // FromCode protegge l'azione dichiarata da codice dall'Assign della LZ (vedi
  // TzToolActionsProps.Assign) e ne consente la persistenza al primo salvataggio.
  // ImageList e' ignorata di proposito: non e' persistibile e il fallback GetImageList
  // di BuildFromProps risolve l'image list corretta.
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

procedure TzDbView.InitActions;
begin
  CreateActionsFromProps
end;

procedure TzDbView.cxGridPopupMenuPopup(ASenderMenu: TComponent; AHitTest: TcxCustomGridHitTest; X, Y: Integer; var AllowPopup: Boolean);
begin
  if ASenderMenu is TcxGridStdHeaderMenu then
    TcxGridStdHeaderMenu(ASenderMenu).OnPopup := StdHeaderMenuPopup;
end;

procedure TzDbView.StdHeaderMenuPopup(Sender: TObject);
var
  i: Integer;
  cxGridStdHeaderMenu: TcxGridStdHeaderMenu;
  menuItem: TMenuItem;
begin
  cxGridStdHeaderMenu := TcxGridStdHeaderMenu(Sender);

  for i := 0 to cxGridStdHeaderMenu.Items.Count - 1 do
  begin
    menuItem := cxGridStdHeaderMenu.Items[i];

    if menuItem.Caption = cxGetResourceString(@cxSGridShowFooter) then
      menuItem.Visible := False
    else
      if menuItem.Caption = cxGetResourceString(@cxSGridShowGroupFooter) then
        menuItem.Visible := False
      else
        if menuItem.Caption = cxGetResourceString(@cxSGridShowFindPanel) then
          menuItem.Visible := False;
  end;
end;

procedure TzDbView.SetFindValue(const Value: Variant);
var
  AEdit: TcxFindPanelMRUEdit;
begin

  if not varIsNull(Value) then
  begin
    DoShowFindPanel;

    TcxGridFindPanelAccess(TcxGridTableControllerAccess(cxGridDBTableView.Controller).FindPanel).Text := Value;

    // AEdit := TcxGridFindPanelAccess(TcxGridTableControllerAccess(cxGridDBTableView.Controller).FindPanel).Edit;
    //
    // if Assigned(AEdit) then
    // AEdit.EditValue := Value;
  end;
end;

function TzDbView.GetFindValue: Variant;
var
  AEdit: TcxFindPanelMRUEdit;
begin
  result := null;

  AEdit := TcxGridFindPanelAccess(TcxGridTableControllerAccess(cxGridDBTableView.Controller).FindPanel).Edit;

  if Assigned(AEdit) then
    result := AEdit.EditingValue;
end;

procedure TzDbView.LoadDefaultProps;
begin

  { TODO : Testare il flag CustomStore }
  // zSystem
  // evento di card
  //

  Controller.LoadDefaultProps
end;

procedure TzDbView.doSalvaImpostazioni(const Silent: Boolean = False);
begin
  Controller.SaveToLZ(Silent);
end;

procedure TzDbView.SetOnCustomLoadProps(const Value: TNotifyEvent);
begin
  FOnCustomLoadProps := Value;

  if Assigned(Value) then
  begin
    Controller.CustomLoadCallback := procedure
      begin
        OnCustomLoadProps(Self);
      end;
  end
  else
    Controller.CustomLoadCallback := nil;
end;

procedure TzDbView.SetOnCustomSaveProps(const Value: TNotifyEvent);
begin
  FOnCustomSaveProps := Value;

  if Assigned(Value) then
  begin
    Controller.CustomSaveCallback := procedure
      begin
        OnCustomSaveProps(Self);
      end;
  end
  else
    Controller.CustomSaveCallback := nil;
end;

procedure TzDbView.OverrideCampoExecute(Sender: TObject);
var
  col: TcxGridDBColumn;
  OvItem: TOverrideItem;
  isNew: Boolean;
begin
  col := TcxGridDBColumn(cxGridDBTableView.Controller.FocusedColumn);

  if not Assigned(col) then
    Exit;

  // Recupera l'override esistente o ne crea uno nuovo in memoria
  OvItem := Overrides.FindOverride(DataController.idDataSet, col.DataBinding.FieldName);
  isNew := OvItem = nil;
  if isNew then
    OvItem := Overrides.Add(DataController.idDataSet, col.DataBinding.FieldName);

  if zEditProperties([OvItem]) then
  begin
    Overrides.SaveItem(OvItem, zSystem.zFbDatabase);
    // Riapplica la caption aggiornata alla colonna
    col.Caption := Overrides.CaptionGrid(DataController.idDataSet, col.DataBinding.FieldName);
    if col.Caption.IsEmpty then
      col.Caption := col.DataBinding.FieldName;
  end
  else
    if isNew then
      // Annullato e mai esistito: rimuove l'item appena aggiunto
      Overrides.Remove(OvItem);
end;

procedure TzDbView.OverrideCampoUpdate(Sender: TObject);
begin
  OverrideCampo.Visible := IsAdmin;
end;

procedure TzDbView.ReloadColumnProps;
begin
  GetDbViewProps.Columns.AssignToGridColumns(DataController.idDataSet, cxGridDBTableView, ViewID);
end;

procedure TzDbView.CopiaColonnePerDXExecute(Sender: TObject);
begin
  if Assigned(DevExtremeSaveDbView) then
    DevExtremeSaveDbView(Self);
end;

procedure TzDbView.CopiaColonnePerDXUpdate(Sender: TObject);
begin
  CopiaColonnePerDX.Visible := Assigned(DevExtremeSaveDbView);
end;

procedure TzDbView.actVisualizzaFooterExecute(Sender: TObject);
begin
  cxGridDBTableView.OptionsView.Footer := not cxGridDBTableView.OptionsView.Footer;

  if cxGridDBTableView.OptionsView.Footer then
    doCalcFooters;
end;

procedure TzDbView.actVisualizzaFooterUpdate(Sender: TObject);
begin
  actVisualizzaFooter.Visible := Flags.ButtonFooters;
  actVisualizzaFooter.Checked := cxGridDBTableView.OptionsView.Footer;
end;

procedure TzDbView.FormattazioneCondizionaleExecute(Sender: TObject);
begin
  cxGridDBTableView.ConditionalFormatting.ShowRulesManagerDialog;
  GetDbViewProps.ConditionalFormatting := zDxConditionalFormattings.GetConditionalFormattings(cxGridDBTableView);
  SaveUserConditionalFormatting;
end;

function TzDbView.ConditionalFormattingFileName: string;
var
  Identificativo: string;
  Carattere: Char;
begin
  // R-020: prima era ChangeFileExt(IniFileName, '.conditionalFormatting'),
  // cioe' un file solo per utente ed eseguibile, letto e riscritto da tutte
  // le viste: le regole di una vista finivano sulle colonne di un'altra, e
  // una vista senza regole che salvava cancellava il file di tutte. Ora il
  // nome porta l'identificativo della vista. Il file vecchio non si legge
  // piu': non si sa quale vista l'abbia scritto per ultima
  Identificativo := ViewID;
  for Carattere in TPath.GetInvalidFileNameChars do
    Identificativo := Identificativo.Replace(Carattere, '_');

  result := ChangeFileExt(Controller.Storage.IniFileName, '') + '.' + Identificativo + '.conditionalFormatting';
end;

function TzDbView.ConditionalFormattingFieldsFileName: string;
begin
  result := ConditionalFormattingFileName + '.fields';
end;

procedure TzDbView.LoadUserConditionalFormatting;
var
  SavedFields: TStringList;
begin
  if ViewID.IsEmpty or not TFile.Exists(ConditionalFormattingFileName) then
    Exit;

  zDxConditionalFormattings.LoadConditionalFormattingsFromFile(cxGridDBTableView, ConditionalFormattingFileName);

  if not TFile.Exists(ConditionalFormattingFieldsFileName) then
    Exit;

  SavedFields := TStringList.Create;
  try
    SavedFields.LoadFromFile(ConditionalFormattingFieldsFileName, TEncoding.UTF8);
    RealignConditionalFormatting(SavedFields);
  finally
    SavedFields.Free;
  end;
end;

procedure TzDbView.SaveUserConditionalFormatting;
var
  Fields: TStringList;
  i: Integer;
begin
  if ViewID.IsEmpty then
    Exit;

  // Senza regole si cancellano i file di questa vista e basta. Il controllo
  // va fatto sul numero di regole: il flusso DevExpress non e' mai vuoto
  // (numero di regole e versione), quindi SaveConditionalFormattingsToFile
  // scriverebbe comunque un file. Era cosi' che una vista senza regole
  // svuotava il file comune a tutte
  if cxGridDBTableView.ConditionalFormatting.RuleCount = 0 then
  begin
    if TFile.Exists(ConditionalFormattingFileName) then
      TFile.Delete(ConditionalFormattingFileName);
    if TFile.Exists(ConditionalFormattingFieldsFileName) then
      TFile.Delete(ConditionalFormattingFieldsFileName);
    Exit;
  end;

  zDxConditionalFormattings.SaveConditionalFormattingsToFile(cxGridDBTableView, ConditionalFormattingFileName);

  // le aree delle regole sono indici di item del data controller: accanto
  // si salva a quale campo corrispondeva ogni indice, per riallinearle alla
  // rilettura se il dizionario aggiunge, toglie o riordina le colonne
  Fields := TStringList.Create;
  try
    for i := 0 to cxGridDBTableView.ItemCount - 1 do
      Fields.Add(TcxGridDBColumn(cxGridDBTableView.Items[i]).DataBinding.FieldName);
    Fields.SaveToFile(ConditionalFormattingFieldsFileName, TEncoding.UTF8);
  finally
    Fields.Free;
  end;
end;

procedure TzDbView.RealignConditionalFormatting(SavedFields: TStrings);

  function CurrentIndex(const OldIndex: Integer): Integer;
  var
    Column: TcxGridDBColumn;
  begin
    result := -1;
    if (OldIndex < 0) or (OldIndex >= SavedFields.Count) then
      Exit;

    Column := cxGridDBTableView.GetColumnByFieldName(SavedFields[OldIndex]);
    if Assigned(Column) then
      result := Column.Index;
  end;

var
  i: Integer;
  Rule: TdxSpreadSheetCustomConditionalFormattingRule;
  Area: TRect;
  NewLeft: Integer;
  NewRight: Integer;
begin
  // Regola per regola: l'area torna sul campo per cui era stata scritta; se
  // il campo non c'e' piu' la regola si scarta, invece di colorare la colonna
  // che oggi occupa quel posto. Le aree "tutte le colonne" (larghezza MaxInt)
  // non dipendono dai campi e restano come sono, come fa DevExpress quando
  // una colonna cambia posto (FieldIndexChangedHandler).
  // Limite: i riferimenti per indice dentro le formule delle regole a
  // espressione non si riallineano; quelli scritti come {CAMPO} si risolvono
  // gia' per nome
  cxGridDBTableView.ConditionalFormatting.BeginUpdate;
  try
    for i := cxGridDBTableView.ConditionalFormatting.RuleCount - 1 downto 0 do
    begin
      Rule := cxGridDBTableView.ConditionalFormatting.Rules[i];
      Area := Rule.Area;

      if Area.Width = MaxInt then
        Continue;

      NewLeft := CurrentIndex(Area.Left);
      NewRight := CurrentIndex(Area.Right);

      if (NewLeft < 0) or (NewRight < 0) then
      begin
        cxGridDBTableView.ConditionalFormatting.Remove(Rule);
        Continue;
      end;

      if (NewLeft <> Area.Left) or (NewRight <> Area.Right) then
      begin
        Area.Left := Min(NewLeft, NewRight);
        Area.Right := Max(NewLeft, NewRight);
        Rule.Area := Area;
      end;
    end;
  finally
    cxGridDBTableView.ConditionalFormatting.EndUpdate;
  end;
end;

procedure TzDbView.DescrizioneExecute(Sender: TObject);
begin

  if Descrizione.Checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzDbView.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

function TzDbView.GetTitle: string;
begin
  result := Titolo.Caption;

  if result.IsEmpty then
  begin
    result := GetDbViewProps.Title;

    if result.IsEmpty then
    begin
      result := name;

      if result.StartsWith('view') then
        result := result.Replace('view', '', [rfIgnoreCase]);
    end;
  end;
end;

function TzDbView.GetToolFilters: TzToolFiltersProps;
begin
  result := GetDbViewProps.ToolFilters;
end;

procedure TzDbView.LoadDescription();
begin

  if not Assigned(FrameDescription) then
    CreateDescription;

  GetDbViewProps.Description.LoadFromIni(Controller.Storage.ViewID);
  FrameDescription.zDescription := GetDbViewProps.Description;
  Descrizione.Checked := GetDbViewProps.Description.Visible;
end;

procedure TzDbView.SaveDescription();
begin
  GetDbViewProps.Description.Assign(FrameDescription.zDescription);
  GetDbViewProps.Description.SaveToIni(Controller.Storage.ViewID);

  Descrizione.Checked := GetDbViewProps.Description.Visible;
end;

procedure TzDbView.SetToolFilters(const Value: TzToolFiltersProps);
begin
  GetDbViewProps.ToolFilters.Assign(Value);
end;

procedure TzDbView.EditToolsExecute(Sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbView.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

procedure TzDbView.DestroyWnd;
var
  cmd: TzDbViewCommand;
begin
  siDbView.LogVerbose(PChar(Format('DestroyWnd hwnd=%d', [Self.Handle])));
  for cmd := Low(TzDbViewCommand) to High(TzDbViewCommand) do
    PostedCommands[cmd] := False;
  inherited;
end;

function TzDbView.GetProps: TzBaseComponentProps;
begin
  result := GetDbViewProps;
end;

initialization

siDbView := Si.AddSession('zDbView', true);
siDbView.Color := clSkyBlue;

finalization

siDbView := nil;

end.
