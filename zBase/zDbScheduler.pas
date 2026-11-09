// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-12
// ---------------------------------------------------------------------------
unit zDbScheduler;

// TzDbScheduler: il calendario di Gesty e WinTarif (TFrameScheduler) portato
// in zPack, con la stessa interfaccia pubblica e gli stessi nomi dei
// sottocomponenti, cosi' che una form passi al componente cambiando solo il
// tipo del frame (TFrameScheduler -> TzDbScheduler) e la chiamata a Init.
//
// Cosa cambia rispetto alle due copie di Frame_Scheduler:
// - il tipo di evento e' il codice di SCHEDULER_TIPO_EVENTO (stringa), non
//   l'enumerato dell'applicazione; le operazioni passano dal registro
//   TzSchedulerEvents (zDbScheduler.Types), che l'applicazione riempie con i
//   suoi gestori (Gesty.Scheduler.pas, WT.Scheduler.pas);
// - le azioni "Nuova lezione", "Nuova prenotazione"... non sono piu' nel .dfm:
//   nascono in Init dai tipi che il modulo dati dichiara inseribili;
// - nessuna dipendenza dall'applicazione (zDmImages, Base_Frame): icone
//   proprie, barra propria; le icone delle azioni aggiunte dalla form si
//   impostano con FreeBarImages (Init_Controls lo fa per tutte le form).
//
// Il comportamento e' quello della copia di Gesty, la piu' avanzata: nuovo
// evento dal punto cliccato con il controllo del ticket Mantis 197, rilettura
// anche dopo un annullo, aggiornamento automatico, vista mese con giorno e
// mese su ogni cella. Il confronto delle due copie e' nella Fase 0 dello
// scheduler, sezione 3.
//
// Due modi di lavoro:
// - delegato (Init): gli eventi arrivano da procedure in sola lettura e ogni
//   scrittura passa dal gestore del tipo di evento; e' il modo di Gesty e
//   delle prenotazioni di WinTarif;
// - nativo (InitNativo): lo storage e' legato a una tabella vera e scrive da
//   se', con l'editor di DevExpress (agenda di WinTarif); in sola lettura
//   (home di GeRA) il doppio clic chiama la funzione di apertura della form.
//
// Dal dizionario LZ (TzDbSchedulerProps, collezione zDbSchedulers) il
// calendario nasce in modo nativo: il FormController assegna zSystem,
// SchedulerID e zDataSet, il frame crea il proprio TcxSchedulerDBStorage con
// la mappatura dei campi delle props (o la convenzione INIZIO, FINE,
// OGGETTO...), lo lega al dataset e, se il dataset ha i parametri del periodo
// (DAL_GIORNO, AL_GIORNO), lo riapre quando il periodo visibile esce da
// quello letto. Filtri e azioni del dizionario stanno nella barra libera
// (dxBarManagerBarFree), come negli altri componenti.

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.ImageList,
  System.Actions,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  dxCore,
  dxBar,
  dxBarExtItems,
  dxPSGlbl,
  dxPrnDev,
  dxPrnPg,
  dxPSCore,
  dxPScxSchedulerLnk,
  cxClasses,
  cxControls,
  cxStyles,
  cxGraphics,
  cxEdit,
  cxContainer,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxImageList,
  cxBarEditItem,
  cxScheduler,
  cxSchedulerStorage,
  cxSchedulerCustomControls,
  cxSchedulerCustomResourceView,
  cxSchedulerDayView,
  cxSchedulerDateNavigator,
  cxSchedulerTimeGridView,
  cxSchedulerUtils,
  cxSchedulerWeekView,
  cxSchedulerYearView,
  cxSchedulerGanttView,
  cxSchedulerAgendaView,
  cxSchedulerActions,
  cxSchedulerDBStorage,
  zFbDataSet,
  zSystem,
  zToolActions,
  zFocusedAction,
  zDataController,
  zDbScheduler.Types;

type
  // Modo nativo: apre l'evento (doppio clic, "Modifica"); True se il
  // calendario va riletto
  TzSchedulerApriEventoFunc = reference to function(Event: TcxSchedulerEvent): Boolean;

  TzDbSchedulerCommand = (scUpdateActions, scSaveZip, scBindStorage);

  TzDbScheduler = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzShortCutConsumer)
    dxBarDockControl: TdxBarDockControl;
    Scheduler: TcxScheduler;
    dxBarManager: TdxBarManager;
    dxBarManagerBar: TdxBar;
    dxBarManagerBarFree: TdxBar;
    BaseActions: TActionList;
    popActions: TdxBarPopupMenu;
    cxStyleRepository: TcxStyleRepository;
    stEvents: TcxStyle;
    stHeaders: TcxStyle;
    stContent: TcxStyle;
    stContentSelection: TcxStyle;
    stResource: TcxStyle;
    imagesScheduler: TcxImageList;
    Actions: TActionList;
    Risorse: TAction;
    Oggi: TAction;
    VaiAlGiorno: TAction;
    Precedente: TAction;
    Successivo: TAction;
    EliminaOra: TAction;
    ModificaOra: TAction;
    TagliaOra: TAction;
    CopiaOra: TAction;
    CopiaGiorno: TAction;
    CopiaSettimana: TAction;
    Incolla: TAction;
    Giorno: TAction;
    Settimana: TAction;
    Mese: TAction;
    ExportXLS: TAction;
    Anteprima: TAction;
    CalendarioScala60Minuti: TdxSchedulerTimeScale60Minutes;
    CalendarioScala30Minuti: TdxSchedulerTimeScale30Minutes;
    CalendarioScala15Minuti: TdxSchedulerTimeScale15Minutes;
    CalendarioScala10Minuti: TdxSchedulerTimeScale10Minutes;
    CalendarioScala06Minuti: TdxSchedulerTimeScale6Minutes;
    CalendarioScala05Minuti: TdxSchedulerTimeScale5Minutes;
    CalendarioSoloOrarioLavorativo: TdxSchedulerWorkTimeOnly;
    dxBarButtonRisorse: TdxBarButton;
    dxBarButtonOggi: TdxBarButton;
    dxBarButtonVaiAlGiorno: TdxBarButton;
    dxBarButtonPrecedente: TdxBarButton;
    dxBarButtonSuccessivo: TdxBarButton;
    dxBarButtonGiorno: TdxBarButton;
    dxBarButtonSettimana: TdxBarButton;
    dxBarButtonMese: TdxBarButton;
    barAggiornamentoAutomatico: TdxBarListItem;
    dxBarButtonExportXLS: TdxBarButton;
    dxBarButtonAnteprima: TdxBarButton;
    dxBarButtonModificaOra: TdxBarButton;
    dxBarButtonEliminaOra: TdxBarButton;
    dxBarButtonTagliaOra: TdxBarButton;
    dxBarButtonCopiaOra: TdxBarButton;
    dxBarButtonIncolla: TdxBarButton;
    dxBarButtonCopiaGiorno: TdxBarButton;
    dxBarButtonCopiaSettimana: TdxBarButton;
    dxBarSubItemScala: TdxBarSubItem;
    dxBarButton60Minutes: TdxBarButton;
    dxBarButton30Minutes: TdxBarButton;
    dxBarButton15Minutes: TdxBarButton;
    dxBarButton10Minutes: TdxBarButton;
    dxBarButton6Minutes: TdxBarButton;
    dxBarButton5Minutes: TdxBarButton;
    dxBarButtonSoloOrarioLavorativo: TdxBarButton;
    popEvent: TdxBarPopupMenu;
    popScheduler: TdxBarPopupMenu;
    dxComponentPrinter: TdxComponentPrinter;
    dxComponentPrinterLinkScheduler: TcxSchedulerReportLink;
    TimerRefresh: TTimer;
    procedure AnteprimaExecute(Sender: TObject);
    procedure barAggiornamentoAutomaticoClick(Sender: TObject);
    procedure SchedulerBeforeEditing(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; AInplace: Boolean; var Allow: Boolean);
    procedure SchedulerBeforeSizingEvent(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; X, Y: Integer; var Allow: Boolean);
    procedure SchedulerCustomDrawEvent(Sender: TObject; ACanvas: TcxCanvas; AViewInfo: TcxSchedulerEventCellViewInfo; var ADone: Boolean);
    procedure SchedulerDblClick(Sender: TObject);
    procedure SchedulerDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SchedulerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure SchedulerInitEventImages(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; AImages: TcxSchedulerEventImages);
    procedure SchedulerBeforeDragEvent(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; X, Y: Integer; var Allow: Boolean);
    procedure SchedulerCustomDrawContent(Sender: TObject; ACanvas: TcxCanvas; AViewInfo: TcxSchedulerContentCellViewInfo; var ADone: Boolean);
    procedure SchedulerGetEventHintText(Sender: TObject; AEvent: TcxSchedulerControlEvent; var AText: string);
    procedure CalendarioResourceNavigatorButtonClick(Sender: TcxSchedulerResourceNavigator; AButton: TcxSchedulerNavigatorButton; var AHandled: Boolean);
    procedure PrecedenteExecute(Sender: TObject);
    procedure SuccessivoExecute(Sender: TObject);
    procedure OggiExecute(Sender: TObject);
    procedure VaiAlGiornoExecute(Sender: TObject);
    procedure GiornoExecute(Sender: TObject);
    procedure SettimanaExecute(Sender: TObject);
    procedure MeseExecute(Sender: TObject);
    procedure ModificaOraExecute(Sender: TObject);
    procedure EliminaOraExecute(Sender: TObject);
    procedure TagliaOraExecute(Sender: TObject);
    procedure TagliaOraUpdate(Sender: TObject);
    procedure CopiaOraExecute(Sender: TObject);
    procedure CopiaOraUpdate(Sender: TObject);
    procedure CopiaGiornoExecute(Sender: TObject);
    procedure CopiaSettimanaExecute(Sender: TObject);
    procedure IncollaExecute(Sender: TObject);
    procedure IncollaUpdate(Sender: TObject);
    procedure RisorseExecute(Sender: TObject);
    procedure RisorseUpdate(Sender: TObject);
    procedure ExportXLSExecute(Sender: TObject);
    procedure popSchedulerPopup(Sender: TObject);
    procedure TimerRefreshTimer(Sender: TObject);
  private
    DisableDelayedRefresh: Boolean;
    DeltaDragY: Integer;
    popSchedulerPopupPoint: TPoint;
    DisabilitaCalendario: Boolean;
    FCurrentViewMode: TcxSchedulerViewMode;
    FSchedulerStorage: IzSchedulerStorage;
    FSchedulerCopyPaste: IzSchedulerCopyPaste;
    FSelectRisorseProc: TProc;
    FShowAutoRefreshCombo: Boolean;
    FAutoRefreshIntervalChanged: TProc<Integer>;
    FMostraDateMese: Boolean;
    FOnInitEventImages: TcxSchedulerInitEventImages;
    CopiaIncolla: TzCopiaIncolla;
    // azioni "Nuovo ..." create in Init dai tipi inseribili, con il loro codice
    FNewActions: TDictionary<TBasicAction, TzSchedulerKind>;
    FNewButtons: TList<TdxBarButton>;
    // riaperture del dataset degli eventi, chiunque le provochi (la form, il
    // modulo dopo un incolla...): la fascia oraria va ricalcolata ogni volta
    FMonitorSource: TDataSource;
    FTimerOrario: TTimer;
    // modo nativo (InitNativo): lo storage scrive da se' sul dataset
    FNativo: Boolean;
    FSolaLettura: Boolean;
    FApriEventoNativo: TzSchedulerApriEventoFunc;
    FRileggiProc: TProc;
  private // dizionario LZ
    FzDataSet: TzFbDataSet;
    FzResourceDataSet: TzFbDataSet;
    FzSystem: TzSystem;
    FDataController: TzDataController;
    FzDbSchedulerProps: TzDbSchedulerProps;
    FToolActions: TzToolActions;
    // storage del frame, legato al dataset del dizionario
    FLzStorage: TcxSchedulerDBStorage;
    // apertura dell'evento chiesta dalla form ospite (vedi ApriEvento)
    FApriEventoLz: TzSchedulerApriEventoFunc;
    FEventSource: TDataSource;
    FResourceSource: TDataSource;
    FLzBuilt: Boolean;
    FStorageBound: Boolean;
    FLoadingProps: Boolean;
    FIsDestroying: Boolean;
    FSaveZipQueued: Boolean;
    FRestrictionReadOnly: Boolean;
    FRuntimeTitle: string;
    // periodo letto dal dataset (parametri DAL_GIORNO, AL_GIORNO)
    FPeriodoDal: TDateTime;
    FPeriodoAl: TDateTime;
    FPeriodoValido: Boolean;
    FTimerPeriodo: TTimer;
    // campi obbligatori mancanti nella mappatura, mostrati sulla barra
    FBarAvviso: TdxBarStatic;
    // azioni del dizionario e dell'amministratore, create da InitLz
    actDbRefresh: TzFocusedAction;
    Elabora: TzFocusedAction;
    actPersonalizza: TzFocusedAction;
    SalvaImpostazioni: TzFocusedAction;
    CaricaImpostazioni: TzFocusedAction;
    actSQL: TzFocusedAction;
    MostraQueryUtilizzata: TzFocusedAction;
    CopiaQueryUtilizzata: TzFocusedAction;
    CopyName: TzFocusedAction;
    EditTools: TzFocusedAction;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    FOnUpdateActions: TNotifyEvent;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
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
  private // dizionario LZ
    function GetSchedulerID: string;
    procedure SetSchedulerID(const Value: string);
    procedure SetzSystem(const Value: TzSystem);
    procedure SetzResourceDataSet(const Value: TzFbDataSet);
    procedure SetRestrictionReadOnly(const Value: Boolean);
    procedure SetApriEventoLz(const Value: TzSchedulerApriEventoFunc);
    function zSystemOk: Boolean;
    function IsAdmin: Boolean;
    function LzReadOnly: Boolean;
    procedure CreateLzActions;
    function NewLzAction(const ActionName, Caption: string; const ImageIndex: Integer; Handler: TNotifyEvent; const ShortCut: TShortCut = 0): TzFocusedAction;
    procedure InitLz;
    procedure BindStorage;
    procedure ApplicaPeriodoLz(const DalGiorno, AlGiorno: TDateTime);
    procedure LoadProperties(const LoadDefaults: Boolean);
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
    procedure doSalvaImpostazioni(const Silent: Boolean = False);
    procedure CreateFiltersFromProps;
    procedure UpdateLzActions;
    procedure OnFlagChange(Sender: TObject);
    procedure ToolActionsChanged(Sender: TObject);
    procedure EventSourceStateChange(Sender: TObject);
    procedure DateNavigatorPeriodChanged(Sender: TObject; const AStart, AFinish: TDateTime);
    procedure TimerPeriodoTimer(Sender: TObject);
    procedure PostInternalMessage(const Command: TzDbSchedulerCommand);
    procedure ExecuteCommand(const Command: TzDbSchedulerCommand);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBSCHEDULER;
    function LayoutFileName: string;
    procedure LoadUserSettings;
    procedure SaveUserSettings;
    procedure actDbRefreshExecute(Sender: TObject);
    procedure ElaboraExecute(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure CaricaImpostazioniExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure MostraQueryUtilizzataExecute(Sender: TObject);
    procedure CopiaQueryUtilizzataExecute(Sender: TObject);
    procedure CopyNameExecute(Sender: TObject);
    procedure EditToolsExecute(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  private
    function GetControlBoxVisible: Boolean;
    procedure SetControlBoxVisible(const Value: Boolean);
    procedure SetCurrentViewMode(const Value: TcxSchedulerViewMode);
    procedure SetShowAutoRefreshCombo(const Value: Boolean);
    function GetAutoRefreshIndex: Integer;
    procedure SetAutoRefreshIndex(const Value: Integer);
    function GetEventImages: TCustomImageList;
    procedure SetEventImages(const Value: TCustomImageList);
    function GetFreeBarImages: TCustomImageList;
    procedure SetFreeBarImages(const Value: TCustomImageList);
    function GetDragView(const Source: TObject): TComponent;
    function GetNearestFreeTime(const Params: TzSchedulerEventParams; Value: TDateTime; Durata: Integer;
      Trascinato: TcxSchedulerEvent; Risorsa: TcxSchedulerStorageResourceItem): TDateTime;
    function StorageResourceFieldName: string;
    function Contains(const Kinds: TzSchedulerKinds; const Kind: TzSchedulerKind): Boolean;
    procedure CreateNewEventActions;
    procedure ClearNewEventActions;
    procedure NewEventActionExecute(Sender: TObject);
    procedure RileggiCalendario;
    procedure CollegaMonitor;
    procedure MonitorStateChange(Sender: TObject);
    procedure MonitorDataChange(Sender: TObject; Field: TField);
    procedure TimerOrarioTimer(Sender: TObject);
    procedure RileggiNativo;
    procedure AggiungiAzioneNuovo(const Caption: string; const ImageIndex: Integer; const Code: TzSchedulerKind; var Position: Integer);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(SchedulerStorage: IzSchedulerStorage; SchedulerCopyPaste: IzSchedulerCopyPaste);
    // Modo nativo: lo storage (TcxSchedulerDBStorage del modulo dati) e'
    // legato a una tabella vera, oppure a una procedura in sola lettura.
    // Scrivibile: nuovo, modifica, trascinamento, ridimensionamento ed
    // eliminazione con l'editor e le operazioni di DevExpress. In sola
    // lettura: nessuna scrittura; ApriEvento, se assegnata, apre l'evento con
    // il doppio clic o con "Modifica"
    procedure InitNativo(Storage: TcxCustomSchedulerStorage; const SolaLettura: Boolean = False; ApriEvento: TzSchedulerApriEventoFunc = nil);

    procedure IncrementaPeriodo(Incrementa: Boolean);
    procedure SelezionaData(const Value: TDate);
    procedure RefreshScheduler;
    procedure DelayedRefresh;
    procedure Preview;
    // Orario di lavoro del modulo dati (OraInizio, OraFine di GetSchedulerParams),
    // allargato agli eventi caricati che ne escono: con ViewDay.WorkTimeOnly
    // nessun evento resta fuori dalla vista. Il frame la chiama dopo ogni
    // rilettura e a ogni riapertura del dataset degli eventi, anche quando la
    // provoca la form o il modulo dati
    procedure ApplicaOrarioLavoro;
  public
    property CurrentViewMode: TcxSchedulerViewMode read FCurrentViewMode write SetCurrentViewMode;
    property SchedulerStorage: IzSchedulerStorage read FSchedulerStorage;
    property SchedulerCopyPaste: IzSchedulerCopyPaste read FSchedulerCopyPaste;
  public
    function AddToolbarButton(Action: TAction; const Position: Integer = 0): TdxBarButton;
    function AddToolbarEditItem(const Name: string; const Width: Integer = 0): TcxBarEditItem;
    function AddToolbarStatic(const Name: string; const Width: Integer = 0): TdxBarStatic;
  public
    procedure SetControlBox(Control: TWinControl; const Visible: Boolean = True);
    property ControlBoxVisible: Boolean read GetControlBoxVisible write SetControlBoxVisible;
    property SelectRisorseProc: TProc read FSelectRisorseProc write FSelectRisorseProc;
    // Modo nativo: rilettura del calendario; senza, il frame riapre il
    // dataset dello storage
    property RileggiProc: TProc read FRileggiProc write FRileggiProc;
    // Dizionario LZ: apre l'evento con il doppio clic o con "Modifica",
    // anche sul calendario in sola lettura (dove altrimenti il doppio clic su
    // un evento non fa niente). E' l'ApriEvento di InitNativo per il caso in
    // cui lo storage lo lega il frame (BindStorage): la form ospite lo assegna
    // dopo BuildGui, quando il FormController ha creato il calendario.
    // True dalla funzione = il calendario va riletto
    property ApriEvento: TzSchedulerApriEventoFunc read FApriEventoLz write SetApriEventoLz;
    property Nativo: Boolean read FNativo;
    property SolaLettura: Boolean read FSolaLettura;
  public // dizionario LZ
    // Apre il dataset degli eventi se non lo e' (come gli altri componenti)
    procedure ActivateDataSet;
    // Rilegge le props dal dizionario e rilega lo storage
    procedure ReloadProps;
    function GetTitle: string;
    procedure SetTitle(const Title: string);
    procedure InitToolActions;
    procedure ExecuteToolConfig;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
    // Nome del dataset delle risorse nelle props (solo il nome, nello stesso
    // modulo dati): lo usa il FormController per assegnare zResourceDataSet
    function ResourceDataSetName: string;
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
    property zResourceDataSet: TzFbDataSet read FzResourceDataSet write SetzResourceDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property SchedulerID: string read GetSchedulerID write SetSchedulerID;
    property RestrictionReadOnly: Boolean read FRestrictionReadOnly write SetRestrictionReadOnly;
    property DataController: TzDataController read FDataController;
    property zDbSchedulerProps: TzDbSchedulerProps read FzDbSchedulerProps;
    // Storage creato dal frame nel caso del dizionario; nil negli altri casi
    property LzStorage: TcxSchedulerDBStorage read FLzStorage;
  public
    function FirstVisibleDate: TDateTime;
    function LastVisibleDate: TDateTime;
    function GoToDate(ADate: TDateTime; AViewMode: TcxSchedulerViewMode): Boolean;
  public
    // Tipo di evento: codice di SCHEDULER_TIPO_EVENTO se registrato, altrimenti ''
    function HitTestTipoEvento(Event: TcxSchedulerControlEvent): TzSchedulerKind;
    function SelectedTipoEvento: TzSchedulerKind;

    function HitTestModificabile(Event: TcxSchedulerControlEvent): Boolean;
    function SelectedModificabile: Boolean;

    function HitTestIdEvento(Event: TcxSchedulerControlEvent): Integer;
    function SelectedIdEvento: Integer;

    function GetEvento(const TipoEvento: TzSchedulerKind; const Id: Integer): TcxSchedulerEvent;
    function NuovoEvento(const TipoEvento: TzSchedulerKind): Boolean;
  public
    procedure ResetRefreshTimer;
    property ShowAutoRefreshCombo: Boolean read FShowAutoRefreshCombo write SetShowAutoRefreshCombo;
    property AutoRefreshIndex: Integer read GetAutoRefreshIndex write SetAutoRefreshIndex;
    property AutoRefreshIntervalChanged: TProc<Integer> read FAutoRefreshIntervalChanged write FAutoRefreshIntervalChanged;
  public
    // Icone degli eventi: per difetto imagesScheduler (icone di Gesty e WT)
    property EventImages: TCustomImageList read GetEventImages write SetEventImages;
    // Icone delle azioni che la form aggiunge con AddToolbarButton
    property FreeBarImages: TCustomImageList read GetFreeBarImages write SetFreeBarImages;
  published
    // Vista mese: giorno e mese su ogni cella, non solo sulla prima e l'ultima
    property MostraDateMese: Boolean read FMostraDateMese write FMostraDateMese default True;
    // Se assegnato sostituisce le icone dei tipi registrati
    property OnInitEventImages: TcxSchedulerInitEventImages read FOnInitEventImages write FOnInitEventImages;
    // Dizionario LZ, come negli altri componenti
    property OnUpdateActions: TNotifyEvent read FOnUpdateActions write FOnUpdateActions;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write FOnCustomLoadProps;
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write FOnCustomSaveProps;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  end;

implementation

uses
  System.DateUtils,
  System.IniFiles,
  Vcl.Clipbrd,
  FireDAC.Stan.Param,
  cxSchedulerDialogs,
  cxExportSchedulerLink,
  cxGridCustomView,
  cxGrid,
  zDX,
  zBaseLib,
  zMsg,
  zFrmParams,
  zToolConfigDlg,
  zToolFilter.Builder;

{$R *.dfm}

const
  SNessunaCella = 'Selezionare una cella del calendario prima di inserire un nuovo evento.';
  SEliminaEvento = 'Si desidera eliminare l''evento selezionato?';
  SSpazioOccupato = 'Nell''orario di destinazione c''e'' gia'' un altro evento: lo spostamento non e'' stato fatto.';
  SOltreMezzanotte = 'Nell''orario di destinazione l''evento finirebbe dopo la mezzanotte: lo spostamento non e'' stato fatto. ' +
    'Spostarlo prima, oppure dividerlo in due eventi.';

type
  TcxSchedulerCustomResourceViewAccess = class(TcxSchedulerCustomResourceView);
  TcxSchedulerContentCellViewInfoAccess = class(TcxSchedulerMonthDayContentCellViewInfo);

{ TzDbScheduler }

constructor TzDbScheduler.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  TimerRefresh.Enabled := False;
  DisableDelayedRefresh := False;
  DisabilitaCalendario := False;
  DeltaDragY := 0;
  FSchedulerStorage := nil;
  FSchedulerCopyPaste := nil;
  FSelectRisorseProc := nil;
  popSchedulerPopupPoint := Point(-1, -1);
  CopiaIncolla.Reset;
  CopiaIncolla.Enabled := False;
  FShowAutoRefreshCombo := False;
  FAutoRefreshIntervalChanged := nil;
  FMostraDateMese := True;
  FOnInitEventImages := nil;
  FNewActions := TDictionary<TBasicAction, TzSchedulerKind>.Create;
  FNewButtons := TList<TdxBarButton>.Create;
  FNativo := False;
  FSolaLettura := False;
  FApriEventoNativo := nil;
  FRileggiProc := nil;

  // Oggetti interni senza proprietario: il frame vive anche come frame inline
  // nelle form aperte nell'IDE, e un componente senza nome posseduto dal
  // frame rischia di essere scritto nel .dfm della form
  FMonitorSource := TDataSource.Create(nil);
  FMonitorSource.OnStateChange := MonitorStateChange;
  FMonitorSource.OnDataChange := MonitorDataChange;

  FTimerOrario := TTimer.Create(nil);
  FTimerOrario.Enabled := False;
  FTimerOrario.Interval := 50;
  FTimerOrario.OnTimer := TimerOrarioTimer;

  barAggiornamentoAutomatico.Visible := ivNever;

  dx.InitBar(dxBarManagerBar);
  dxBarManagerBar.UseRestSpace := False;
  dxBarManagerBar.WholeRow := False;

  dx.InitBar(dxBarManagerBarFree);
  dxBarManagerBarFree.UseRestSpace := True;
  dxBarManagerBarFree.WholeRow := False;

  dx.InitScheduler(Scheduler);
  dx.InitPrinter(dxComponentPrinter);

  Scheduler.OptionsView.ShowEventsWithoutResource := True;
  Scheduler.ViewDay.AllDayAreaScrollBar := adsbDefault;
  Scheduler.ViewDay.HeaderContainer := True;

  // dizionario LZ: tutto pronto ma spento finche' non arrivano zSystem e zDataSet
  FzDataSet := nil;
  FzResourceDataSet := nil;
  FzSystem := nil;
  FLzStorage := nil;
  FLzBuilt := False;
  FStorageBound := False;
  FLoadingProps := False;
  FIsDestroying := False;
  FSaveZipQueued := False;
  FRestrictionReadOnly := False;
  FRuntimeTitle := '';
  FPeriodoValido := False;
  FOnUpdateActions := nil;
  FOnCustomLoadProps := nil;
  FOnCustomSaveProps := nil;

  FzDbSchedulerProps := TzDbSchedulerProps.Create(nil);
  FzDbSchedulerProps.Flags.OnChange := OnFlagChange;

  FDataController := TzDataController.Create(nil);

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;

  FEventSource := TDataSource.Create(nil);
  FEventSource.OnStateChange := EventSourceStateChange;
  FResourceSource := TDataSource.Create(nil);

  FTimerPeriodo := TTimer.Create(nil);
  FTimerPeriodo.Enabled := False;
  FTimerPeriodo.Interval := 150;
  FTimerPeriodo.OnTimer := TimerPeriodoTimer;

  // le azioni del dizionario nascono in InitLz, solo in esecuzione
  actDbRefresh := nil;
  dxBarSubItemImpostazioni := nil;
  FBarAvviso := nil;

  CurrentViewMode := vmWorkWeek;
  Settimana.Checked := True;
end;

destructor TzDbScheduler.Destroy;
begin
  FIsDestroying := True;

  // scrittura dello zip rimasta in coda: il messaggio postato non verra' recapitato
  if FSaveZipQueued then
  begin
    FSaveZipQueued := False;
    if zSystemOk then
      zSystem.SaveZip(csDbSchedulers, 'TzDbScheduler.Destroy');
  end;

  // vista e scala dell'utente, per la prossima apertura
  if FLzBuilt then
    SaveUserSettings;

  FTimerPeriodo.Enabled := False;
  Scheduler.DateNavigator.OnPeriodChanged := nil;

  // lo storage del frame si sgancia prima che il calendario si distrugga
  if Assigned(FLzStorage) and (Scheduler.Storage = FLzStorage) then
    Scheduler.Storage := nil;
  FEventSource.DataSet := nil;
  FResourceSource.DataSet := nil;
  FreeAndNil(FLzStorage);
  FreeAndNil(FTimerPeriodo);
  FreeAndNil(FResourceSource);
  FreeAndNil(FEventSource);
  FreeAndNil(FToolActions);
  FreeAndNil(FDataController);
  FreeAndNil(FzDbSchedulerProps);

  TimerRefresh.Enabled := False;
  FTimerOrario.Enabled := False;
  FMonitorSource.DataSet := nil;
  FreeAndNil(FTimerOrario);
  FreeAndNil(FMonitorSource);
  FSchedulerStorage := nil;
  FSchedulerCopyPaste := nil;
  FApriEventoNativo := nil;
  FRileggiProc := nil;
  FreeAndNil(FNewButtons);
  FreeAndNil(FNewActions);
  inherited;
end;

// ---------------------------------------------------------------------------
// Inizializzazione
// ---------------------------------------------------------------------------

procedure TzDbScheduler.Init(SchedulerStorage: IzSchedulerStorage; SchedulerCopyPaste: IzSchedulerCopyPaste);
begin
  FSchedulerStorage := SchedulerStorage;
  FSchedulerCopyPaste := SchedulerCopyPaste;
  FNativo := False;
  FSolaLettura := False;
  FApriEventoNativo := nil;
  ModificaOra.Visible := True;
  EliminaOra.Visible := True;

  if Assigned(FSchedulerStorage) then
  begin
    Scheduler.Storage := FSchedulerStorage.GetSchedulerParams.Storage;
    CollegaMonitor;

    // Le due copie di Frame_Scheduler impostavano qui AfterRefreshScheduler su
    // una copia del record (GetSchedulerParams restituisce per valore): non
    // arrivava mai al modulo dati, e OraInizio/OraFine restavano inutilizzati.
    // Qui l'orario del modulo lo applica il frame dopo ogni rilettura
    // (ApplicaOrarioLavoro), senza passare dal modulo.
    SelezionaData(FSchedulerStorage.GetSchedulerParams.DalGiorno);
  end;

  CreateNewEventActions;

  CopiaIncolla.Enabled := Assigned(FSchedulerCopyPaste);
  TagliaOra.Visible := CopiaIncolla.Enabled;
  CopiaOra.Visible := CopiaIncolla.Enabled;
  CopiaGiorno.Visible := CopiaIncolla.Enabled;
  CopiaSettimana.Visible := CopiaIncolla.Enabled;
  Incolla.Visible := CopiaIncolla.Enabled;

  if Assigned(FSchedulerCopyPaste) then
    FSchedulerCopyPaste.InitActions(CopiaOra, CopiaGiorno, CopiaSettimana, TagliaOra, Incolla);

  DisableDelayedRefresh := False;
end;

procedure TzDbScheduler.InitNativo(Storage: TcxCustomSchedulerStorage; const SolaLettura: Boolean = False; ApriEvento: TzSchedulerApriEventoFunc = nil);
begin
  FSchedulerStorage := nil;
  FSchedulerCopyPaste := nil;
  FNativo := True;
  FSolaLettura := SolaLettura;
  FApriEventoNativo := ApriEvento;

  // la fascia oraria si ricalcola solo nel modo delegato
  FMonitorSource.DataSet := nil;

  Scheduler.Storage := Storage;

  // Le scritture le fa DevExpress sul dataset dello storage. Il doppio clic
  // resta al frame (SchedulerDblClick): con DialogShowing l'editor si
  // aprirebbe due volte, e in sola lettura deve aprire la form dell'evento
  Scheduler.EventOperations.ReadOnly := SolaLettura;
  Scheduler.EventOperations.DialogEditing := not SolaLettura;
  Scheduler.EventOperations.DialogShowing := False;
  Scheduler.EventOperations.InplaceEditing := not SolaLettura;
  Scheduler.EventOperations.Sizing := not SolaLettura;
  Scheduler.EventOperations.Intersection := True;
  Scheduler.EventOperations.Recurrence := not SolaLettura;

  // nessun orario del modulo dati da allargare agli eventi: con
  // WorkTimeOnly gli eventi fuori dalla fascia della form sparirebbero
  Scheduler.ViewDay.WorkTimeOnly := False;

  // il colore dell'evento e' la sua etichetta (LabelColor): uno stile con il
  // colore assegnato la coprirebbe (TcxSchedulerStyles.GetDefaultViewParams)
  Scheduler.Styles.Event := nil;

  // copia e incolla passano dal modulo dati, che qui non c'e'
  CopiaIncolla.Reset;
  CopiaIncolla.Enabled := False;
  TagliaOra.Visible := False;
  CopiaOra.Visible := False;
  CopiaGiorno.Visible := False;
  CopiaSettimana.Visible := False;
  Incolla.Visible := False;

  ModificaOra.Visible := not SolaLettura or Assigned(FApriEventoNativo);
  EliminaOra.Visible := not SolaLettura;

  CreateNewEventActions;

  SelezionaData(Date);

  DisableDelayedRefresh := False;
end;

function TzDbScheduler.Contains(const Kinds: TzSchedulerKinds; const Kind: TzSchedulerKind): Boolean;
var
  Item: TzSchedulerKind;
begin
  result := False;

  for Item in Kinds do
    if SameText(Item, Kind) then
      Exit(True);
end;

procedure TzDbScheduler.ClearNewEventActions;
var
  Button: TdxBarButton;
  Action: TBasicAction;
begin
  for Button in FNewButtons do
    Button.Free;
  FNewButtons.Clear;

  for Action in FNewActions.Keys.ToArray do
    Action.Free;
  FNewActions.Clear;
end;

procedure TzDbScheduler.AggiungiAzioneNuovo(const Caption: string; const ImageIndex: Integer; const Code: TzSchedulerKind; var Position: Integer);
var
  Action: TAction;
  Button: TdxBarButton;
begin
  Action := TAction.Create(Self);
  Action.ActionList := Actions;
  Action.Caption := Caption;
  Action.ImageIndex := ImageIndex;
  Action.OnExecute := NewEventActionExecute;
  FNewActions.Add(Action, Code);

  Button := TdxBarButton.Create(Self);
  Button.Action := Action;
  FNewButtons.Add(Button);

  // in cima al menu del calendario, prima di copia e incolla
  popScheduler.ItemLinks.Add(Button).Index := Position;
  Inc(Position);
end;

procedure TzDbScheduler.CreateNewEventActions;
const
  // icona di "Nuovo Evento" dell'agenda di Gesty
  ImmagineNuovoEvento = 90;
var
  Kinds: TzSchedulerKinds;
  Kind: TzSchedulerEventKind;
  Caption: string;
  Position: Integer;
begin
  ClearNewEventActions;
  Position := 0;

  if FNativo then
  begin
    // un'azione sola: il tipo lo sceglie l'editor di DevExpress
    if not FSolaLettura then
      AggiungiAzioneNuovo('Nuovo Evento', ImmagineNuovoEvento, '', Position);
  end
  else
    if Assigned(FSchedulerStorage) then
    begin
      Kinds := FSchedulerStorage.TipoEventiPerInserimento;

      // nell'ordine del registro, come le azioni fisse del vecchio .dfm
      for Kind in TzSchedulerEvents.Kinds do
      begin
        if not Contains(Kinds, Kind.Code) then
          Continue;

        Caption := Kind.NewCaption;
        if Caption = '' then
          Caption := 'Nuovo ' + Kind.Description;

        AggiungiAzioneNuovo(Caption, Kind.NewImageIndex, Kind.Code, Position);
      end;
    end;

  if Position > 0 then
    if popScheduler.ItemLinks.Count > Position then
      popScheduler.ItemLinks[Position].BeginGroup := True;
end;

procedure TzDbScheduler.NewEventActionExecute(Sender: TObject);
var
  Code: TzSchedulerKind;
  Kind: TzSchedulerEventKind;
begin
  if not FNewActions.TryGetValue(TBasicAction(Sender), Code) then
    Exit;

  // un tipo puo' inserire un evento di un altro tipo (vedi InsertKind)
  Kind := TzSchedulerEvents.Find(Code);
  if Assigned(Kind) and (Kind.InsertKind <> '') then
    Code := Kind.InsertKind;

  NuovoEvento(Code);
end;

// ---------------------------------------------------------------------------
// Periodo e viste
// ---------------------------------------------------------------------------

procedure TzDbScheduler.IncrementaPeriodo(Incrementa: Boolean);
var
  Data: TDateTime;
  Delta: Integer;
begin
  if Incrementa then
    Delta := 1
  else
    Delta := -1;

  if Assigned(FSchedulerStorage) then
    Data := FSchedulerStorage.GetSchedulerParams.DalGiorno
  else
    Data := Trunc(Scheduler.SelStart);

  case CurrentViewMode of
    vmDay:
      Data := IncDay(Data, Delta);
    vmWorkWeek, vmWeek:
      Data := IncWeek(StartOfTheWeek(Data), Delta);
    vmMonth:
      Data := IncMonth(StartOfTheMonth(Data), Delta);
  end;

  SelezionaData(Data);
end;

procedure TzDbScheduler.SelezionaData(const Value: TDate);
var
  DalGiorno, AlGiorno: TDateTime;
begin
  DisableDelayedRefresh := True;
  try
    DalGiorno := Value;
    AlGiorno := Value;

    case CurrentViewMode of
      vmWeek, vmWorkWeek:
        begin
          DalGiorno := StartOfTheWeek(Value);
          AlGiorno := EndOfTheWeek(Value);
        end;
      vmMonth:
        begin
          DalGiorno := StartOfTheMonth(Value);
          AlGiorno := EndOfTheMonth(Value);
        end;
    end;

    if Assigned(FSchedulerStorage) then
    begin
      FSchedulerStorage.SetPeriodo(DalGiorno, AlGiorno);
      ApplicaOrarioLavoro;
    end
    else
      // dizionario LZ: parametri del periodo del dataset, se ci sono
      if FLzBuilt then
        ApplicaPeriodoLz(DalGiorno, AlGiorno);

    VaiAlGiorno.Caption := DateToStr(DalGiorno);

    Scheduler.GoToDate(DalGiorno);

    if CurrentViewMode = vmMonth then
      Scheduler.SelectDays(DalGiorno, AlGiorno);
  finally
    DisableDelayedRefresh := False;
  end;
end;

procedure TzDbScheduler.SetCurrentViewMode(const Value: TcxSchedulerViewMode);
begin
  FCurrentViewMode := Value;

  // imposta la vista, poi il periodo (che riapre il dataset)
  Scheduler.GoToDate(Trunc(Scheduler.SelStart), CurrentViewMode);
  SelezionaData(Trunc(Scheduler.SelStart));
  Scheduler.LayoutChanged;
end;

function TzDbScheduler.GoToDate(ADate: TDateTime; AViewMode: TcxSchedulerViewMode): Boolean;
begin
  CurrentViewMode := AViewMode;
  SelezionaData(ADate);
  result := True;
end;

function TzDbScheduler.FirstVisibleDate: TDateTime;
begin
  result := Scheduler.CurrentView.FirstVisibleDate;
end;

function TzDbScheduler.LastVisibleDate: TDateTime;
begin
  result := Scheduler.CurrentView.LastVisibleDate;
end;

procedure TzDbScheduler.RefreshScheduler;
begin
  TimerRefresh.Enabled := False;

  if not DisabilitaCalendario then
    if FNativo or Assigned(FSchedulerStorage) then
    begin
      RileggiCalendario;
      ResetRefreshTimer;
    end;
end;

procedure TzDbScheduler.DelayedRefresh;
begin
  TimerRefresh.Enabled := False;
  TimerRefresh.Enabled := True;
end;

procedure TzDbScheduler.CollegaMonitor;
var
  Storage: TcxSchedulerDBStorage;
begin
  FMonitorSource.DataSet := nil;

  if not(Scheduler.Storage is TcxSchedulerDBStorage) then
    Exit;

  Storage := TcxSchedulerDBStorage(Scheduler.Storage);

  if Assigned(Storage.DataSource) then
    FMonitorSource.DataSet := Storage.DataSource.DataSet;
end;

procedure TzDbScheduler.MonitorStateChange(Sender: TObject);
begin
  // la fascia si calcola dopo che lo storage ha letto gli eventi: per questo
  // in differita, quando il dataset e' stato riaperto
  if Assigned(FMonitorSource.DataSet) and FMonitorSource.DataSet.Active then
  begin
    FTimerOrario.Enabled := False;
    FTimerOrario.Enabled := True;
  end;
end;

procedure TzDbScheduler.MonitorDataChange(Sender: TObject; Field: TField);
begin
  // Field = nil: dati riletti o record cambiato, non un campo modificato
  if Field = nil then
    MonitorStateChange(Sender);
end;

procedure TzDbScheduler.TimerOrarioTimer(Sender: TObject);
begin
  FTimerOrario.Enabled := False;
  ApplicaOrarioLavoro;
end;

procedure TzDbScheduler.RileggiCalendario;
begin
  if FNativo then
  begin
    RileggiNativo;
    Exit;
  end;

  if not Assigned(FSchedulerStorage) then
    Exit;

  FSchedulerStorage.RefreshScheduler;
  ApplicaOrarioLavoro;
end;

procedure TzDbScheduler.RileggiNativo;
var
  DataSet: TDataSet;
begin
  if Assigned(FRileggiProc) then
  begin
    FRileggiProc;
    Exit;
  end;

  if not(Scheduler.Storage is TcxSchedulerDBStorage) then
    Exit;

  if not Assigned(TcxSchedulerDBStorage(Scheduler.Storage).DataSource) then
    Exit;

  DataSet := TcxSchedulerDBStorage(Scheduler.Storage).DataSource.DataSet;

  // lo storage rilegge gli eventi da solo quando il dataset si riapre
  if Assigned(DataSet) and DataSet.Active then
  begin
    DataSet.Close;
    DataSet.Open;
  end;
end;

procedure TzDbScheduler.ApplicaOrarioLavoro;
var
  Params: TzSchedulerParams;
  Inizio, Fine: Double;
  Event: TcxSchedulerEvent;
  i: Integer;
begin
  if not Assigned(FSchedulerStorage) then
    Exit;

  Params := FSchedulerStorage.GetSchedulerParams;

  // senza un orario del modulo resta quello del .dfm
  if Params.OraFine <= Params.OraInizio then
    Exit;

  Inizio := Frac(Params.OraInizio);
  Fine := Frac(Params.OraFine);

  // Gli eventi fuori fascia esistono (lezioni e prenotazioni fino alle 23:30
  // nel database di Gesty, 2026-10-01): con WorkTimeOnly sparirebbero dalla
  // vista giorno. La fascia si allarga agli eventi caricati, cioe' a quelli
  // del periodo letto dal modulo dati. Il calcolo sta in TzSchedulerCalcoli
  // (zDbScheduler.Types), collaudato in zPackTests.
  if Assigned(Scheduler.Storage) then
    for i := 0 to Scheduler.Storage.EventCount - 1 do
    begin
      Event := Scheduler.Storage.Events[i];
      TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, Event.Start, Event.Finish, Event.AllDayEvent);
    end;

  // mezz'ore intere, come le celle del calendario
  TzSchedulerCalcoli.ArrotondaFasciaAMezzOre(Inizio, Fine);

  Scheduler.OptionsView.WorkStart := Inizio;
  Scheduler.OptionsView.WorkFinish := Fine;
end;

procedure TzDbScheduler.GiornoExecute(Sender: TObject);
begin
  CurrentViewMode := vmDay;
end;

procedure TzDbScheduler.SettimanaExecute(Sender: TObject);
begin
  CurrentViewMode := vmWorkWeek;
end;

procedure TzDbScheduler.MeseExecute(Sender: TObject);
begin
  CurrentViewMode := vmMonth;
end;

procedure TzDbScheduler.PrecedenteExecute(Sender: TObject);
begin
  IncrementaPeriodo(False);
end;

procedure TzDbScheduler.SuccessivoExecute(Sender: TObject);
begin
  IncrementaPeriodo(True);
end;

procedure TzDbScheduler.OggiExecute(Sender: TObject);
begin
  SelezionaData(Date);
end;

procedure TzDbScheduler.VaiAlGiornoExecute(Sender: TObject);
var
  Data: TDate;
begin
  if Assigned(FSchedulerStorage) then
    Data := FSchedulerStorage.GetSchedulerParams.DalGiorno
  else
    Data := Date;

  if zMsg.InputDate('Seleziona data', 'Seleziona data', Data) then
    SelezionaData(Data);
end;

// ---------------------------------------------------------------------------
// Aggiornamento automatico (solo Gesty fino a oggi)
// ---------------------------------------------------------------------------

procedure TzDbScheduler.TimerRefreshTimer(Sender: TObject);
begin
  TimerRefresh.Enabled := False;

  if not DisableDelayedRefresh then
  begin
    try
      DisableDelayedRefresh := True;
      try
        RefreshScheduler;
      finally
        DisableDelayedRefresh := False;
      end;
    except
      // una rilettura automatica fallita non deve interrompere l'utente:
      // la prossima la ritenta
      on Exception do
        ;
    end;
  end;
end;

procedure TzDbScheduler.ResetRefreshTimer;
begin
  TimerRefresh.Enabled := False;

  if TimerRefresh.Interval > 0 then
    TimerRefresh.Enabled := True;
end;

procedure TzDbScheduler.SetShowAutoRefreshCombo(const Value: Boolean);
begin
  FShowAutoRefreshCombo := Value;

  barAggiornamentoAutomatico.Visible := dx.Visible(FShowAutoRefreshCombo);

  if FShowAutoRefreshCombo then
    ResetRefreshTimer;
end;

procedure TzDbScheduler.barAggiornamentoAutomaticoClick(Sender: TObject);
var
  Secondi: Integer;
begin
  TimerRefresh.Enabled := False;

  barAggiornamentoAutomatico.Caption := barAggiornamentoAutomatico.Items[barAggiornamentoAutomatico.ItemIndex];

  case barAggiornamentoAutomatico.ItemIndex of
    1:
      Secondi := 5;
    2:
      Secondi := 15;
    3:
      Secondi := 30;
    4:
      Secondi := 60;
    5:
      Secondi := 300;
    6:
      Secondi := 600;
    7:
      Secondi := 900;
  else
    Secondi := 0;
  end;

  TimerRefresh.Interval := Secondi * 1000;

  if Assigned(FAutoRefreshIntervalChanged) then
    FAutoRefreshIntervalChanged(barAggiornamentoAutomatico.ItemIndex);

  ResetRefreshTimer;
end;

function TzDbScheduler.GetAutoRefreshIndex: Integer;
begin
  result := barAggiornamentoAutomatico.ItemIndex;
end;

procedure TzDbScheduler.SetAutoRefreshIndex(const Value: Integer);
begin
  barAggiornamentoAutomatico.ItemIndex := Value;
  barAggiornamentoAutomaticoClick(nil);
end;

// ---------------------------------------------------------------------------
// Tipo, chiave e modificabilita' dell'evento
// ---------------------------------------------------------------------------

function TzDbScheduler.HitTestTipoEvento(Event: TcxSchedulerControlEvent): TzSchedulerKind;
var
  Value: Variant;
begin
  result := '';

  if not Assigned(Event) then
    Exit;

  Value := SchedulerEventValue(Event, zSchedulerKindField);

  // come FromString dell'applicazione: un codice sconosciuto vale "nessun tipo"
  if VarIsStr(Value) then
    if Assigned(TzSchedulerEvents.Find(VarToStr(Value))) then
      result := VarToStr(Value);
end;

function TzDbScheduler.SelectedTipoEvento: TzSchedulerKind;
begin
  result := '';

  if Scheduler.SelectedEventCount > 0 then
    result := HitTestTipoEvento(Scheduler.SelectedEvents[0]);
end;

function TzDbScheduler.HitTestModificabile(Event: TcxSchedulerControlEvent): Boolean;
var
  Value: Variant;
begin
  result := False;

  if not Assigned(Event) then
    Exit;

  Value := SchedulerEventValue(Event, zSchedulerEditableField);

  if not VarIsNull(Value) then
    if VarIsOrdinal(Value) then
      result := Value;
end;

function TzDbScheduler.SelectedModificabile: Boolean;
begin
  result := False;

  if Scheduler.SelectedEventCount > 0 then
    result := HitTestModificabile(Scheduler.SelectedEvents[0]);
end;

function TzDbScheduler.HitTestIdEvento(Event: TcxSchedulerControlEvent): Integer;
var
  Kind: TzSchedulerEventKind;
  Value: Variant;
begin
  result := -1;

  Kind := TzSchedulerEvents.Find(HitTestTipoEvento(Event));
  if not Assigned(Kind) or (Kind.IdFieldName = '') then
    Exit;

  Value := SchedulerEventValue(Event, Kind.IdFieldName);

  if not VarIsNull(Value) then
    if VarIsOrdinal(Value) then
      result := Value;
end;

function TzDbScheduler.SelectedIdEvento: Integer;
begin
  result := -1;

  if Scheduler.SelectedEventCount > 0 then
    result := HitTestIdEvento(Scheduler.SelectedEvents[0]);
end;

function TzDbScheduler.GetEvento(const TipoEvento: TzSchedulerKind; const Id: Integer): TcxSchedulerEvent;
var
  i: Integer;
  Event: TcxSchedulerEvent;
  Kind: TzSchedulerEventKind;
  Value: Variant;
begin
  result := nil;

  Kind := TzSchedulerEvents.Find(TipoEvento);
  if not Assigned(Kind) or not Assigned(Scheduler.Storage) then
    Exit;

  for i := 0 to Scheduler.Storage.EventCount - 1 do
  begin
    Event := Scheduler.Storage.Events[i];

    if SameText(TipoEvento, VarToStr(SchedulerEventValue(Event, zSchedulerKindField))) then
    begin
      Value := SchedulerEventValue(Event, Kind.IdFieldName);
      if not VarIsNull(Value) and (Value = Id) then
        Exit(Event);
    end;
  end;
end;

function TzDbScheduler.StorageResourceFieldName: string;
begin
  result := '';

  if Scheduler.Storage is TcxSchedulerDBStorage then
    result := TcxSchedulerDBStorage(Scheduler.Storage).FieldNames.ResourceID;
end;

// ---------------------------------------------------------------------------
// Operazioni sugli eventi: passano dal registro dei tipi
// ---------------------------------------------------------------------------

function TzDbScheduler.NuovoEvento(const TipoEvento: TzSchedulerKind): Boolean;
var
  Params: TzSchedulerEventParams;
  Momento: TDateTime;
  Kind: TzSchedulerEventKind;
begin
  result := False;

  // modo nativo: l'editor di DevExpress sulla cella selezionata (il clic
  // destro la seleziona, OptionsBehavior.SelectOnRightClick)
  if FNativo then
  begin
    if not FSolaLettura then
    begin
      Scheduler.CreateEventUsingDialog;
      result := True;
    end;
    Exit;
  end;

  DisableDelayedRefresh := True;
  try
    Params.Init;

    if popSchedulerPopupPoint.X <> -1 then
      Scheduler.CurrentView.HitTest.HitPoint := popSchedulerPopupPoint
    else
      Scheduler.CurrentView.HitTest.HitPoint := Scheduler.ScreenToClient(GetMouseCursorPos);

    // Mantis #197 - 2026-09-30: fuori dalle celle che portano una data
    // (intestazione della risorsa, angolo sopra il righello, sfondo) HitTest.Time
    // vale NullDate (-700000) e finiva nel campo data del nuovo evento; sul
    // righello porta la sola ora. In quei casi vale la cella selezionata, e
    // senza una cella selezionata non si apre nulla. La scelta sta in
    // TzSchedulerCalcoli.MomentoNuovoEvento, collaudata in zPackTests.
    if not TzSchedulerCalcoli.MomentoNuovoEvento(Scheduler.CurrentView.HitTest.HitAtTime,
      Scheduler.CurrentView.HitTest.Time, Scheduler.SelStart, Momento) then
      ConfirmOk(SNessunaCella)
    else
    begin
      Kind := TzSchedulerEvents.Find(TipoEvento);

      Params.Kind := TipoEvento;
      Params.Id := -1;
      Params.Data := DateOf(Momento);
      Params.OraInizio := TimeOf(Momento);
      if Assigned(Kind) then
        Params.Durata := Kind.DefaultDuration
      else
        Params.Durata := 60;

      // un evento creato tardi finisce alle 23:59, non dopo la mezzanotte: le
      // tabelle di Gesty e WT rifiutano una fine prima dell'inizio. La scheda
      // mostra la fine accorciata, e chi la vuole diversa la cambia li'
      Params.Durata := TzSchedulerCalcoli.DurataEntroLaGiornata(Params.OraInizio, Params.Durata);

      if Assigned(Scheduler.CurrentView.HitTest.Resource) then
      begin
        Params.ResourceID := Scheduler.CurrentView.HitTest.Resource.ResourceID;
        Params.ResourceFieldName := StorageResourceFieldName;
      end;

      result := TzSchedulerEvents.Apri(Params);

      // si rilegge anche dopo un annullo, come in Gesty
      RileggiCalendario;
    end;
  finally
    DisableDelayedRefresh := False;
  end;
end;

procedure TzDbScheduler.ModificaOraExecute(Sender: TObject);
var
  Params: TzSchedulerEventParams;
  Event: TcxSchedulerControlEvent;
begin
  if FNativo then
  begin
    if Scheduler.SelectedEventCount = 0 then
      Exit;

    Event := Scheduler.SelectedEvents[0];

    if Assigned(FApriEventoNativo) then
    begin
      if FApriEventoNativo(Event) then
        RefreshScheduler;
    end
    else
      if not FSolaLettura then
        Scheduler.EditEventUsingDialog(Event);

    Exit;
  end;

  Params.Init;
  Params.Kind := SelectedTipoEvento;

  if Params.Kind = '' then
    Exit;

  Params.Id := SelectedIdEvento;
  if Params.Id = -1 then
    Exit;

  DisableDelayedRefresh := True;
  try
    TzSchedulerEvents.Apri(Params);

    // si rilegge anche dopo un annullo
    RileggiCalendario;
  finally
    DisableDelayedRefresh := False;
  end;
end;

procedure TzDbScheduler.EliminaOraExecute(Sender: TObject);
var
  Params: TzSchedulerEventParams;
begin
  if FNativo then
  begin
    if FSolaLettura or (Scheduler.SelectedEventCount = 0) then
      Exit;

    if not ConfirmYesNo(SEliminaEvento) then
      Exit;

    // DeleteEvent chiede se eliminare l'occorrenza o la serie;
    // DeleteSelectedEvents eliminerebbe la sola occorrenza senza chiedere
    if Scheduler.SelectedEventCount = 1 then
      Scheduler.DeleteEvent(Scheduler.SelectedEvents[0])
    else
      Scheduler.DeleteSelectedEvents;

    Exit;
  end;

  Params.Init;
  Params.Kind := SelectedTipoEvento;

  if Params.Kind = '' then
    Exit;

  Params.Id := SelectedIdEvento;
  if Params.Id = -1 then
    Exit;

  if not ConfirmYesNo(SEliminaEvento) then
    Exit;

  DisableDelayedRefresh := True;
  try
    TzSchedulerEvents.Elimina(Params);
    Scheduler.UnselectEvents;

    RileggiCalendario;
  finally
    DisableDelayedRefresh := False;
  end;
end;

procedure TzDbScheduler.SchedulerDblClick(Sender: TObject);
begin
  // modo nativo: il doppio clic su una cella vuota crea l'evento, come fa
  // DevExpress con DialogShowing (qui spento, vedi InitNativo)
  if FNativo and (Scheduler.SelectedEventCount = 0) then
  begin
    if Scheduler.CurrentView.HitTest.HitAtTime then
      NuovoEvento('');
    Exit;
  end;

  ModificaOra.Execute;
end;

procedure TzDbScheduler.SchedulerBeforeEditing(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; AInplace: Boolean; var Allow: Boolean);
begin
  if FNativo then
    Allow := not FSolaLettura
  else
    Allow := SelectedModificabile;
end;

procedure TzDbScheduler.SchedulerBeforeSizingEvent(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; X, Y: Integer; var Allow: Boolean);
begin
  Allow := FNativo and not FSolaLettura;
end;

// ---------------------------------------------------------------------------
// Trascinamento
// ---------------------------------------------------------------------------

function TzDbScheduler.GetDragView(const Source: TObject): TComponent;
var
  View: TcxCustomGridView;
begin
  // Griglia trascinata sul calendario (TzDbView): il componente restituito e'
  // il frame che contiene la griglia. Non usato dal frame: per le form.
  result := nil;

  if Source is TcxDragControlObject then
    if TcxDragControlObject(Source).Control is TcxGridSite then
    begin
      View := TcxGridSite(TcxDragControlObject(Source).Control).GridView;
      if View.Controller.Site.Container is TcxGrid then
        result := TcxGrid(View.Controller.Site.Container).Parent;
    end;
end;

procedure TzDbScheduler.SchedulerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  // modo nativo: con Ctrl DevExpress copia l'evento invece di spostarlo
  if FNativo then
    Exit;

  Accept := not IsCtrlPressed;
end;

procedure TzDbScheduler.SchedulerBeforeDragEvent(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; X, Y: Integer; var Allow: Boolean);
var
  ViewInfo: TcxSchedulerEventCellViewInfo;
  HitTest: TcxSchedulerViewHitTest;
begin
  DeltaDragY := 0;

  // modo nativo: lo spostamento lo scrive DevExpress sul dataset
  if FNativo then
  begin
    Allow := not FSolaLettura;
    Exit;
  end;

  Allow := HitTestModificabile(AEvent);

  if not Allow then
    Exit;

  // distanza fra il punto preso e il bordo alto dell'evento, per far cadere
  // l'evento dove sta il suo inizio e non dove sta il mouse
  HitTest := Scheduler.CurrentView.HitTest;
  if HitTest.HitAtEvent then
    if TcxSchedulerCustomResourceViewAccess(Scheduler.CurrentView).FindEventViewInfo(AEvent, Trunc(HitTest.Time), HitTest.Resource, ViewInfo) then
      DeltaDragY := Y - ViewInfo.Bounds.Top;
end;

procedure TzDbScheduler.SchedulerDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Event: TcxSchedulerEvent;
  Params: TzSchedulerEventParams;
  Momento: TDateTime;
  Durata: Integer;
  Ok: Boolean;
begin
  // modo nativo: dopo questo gestore TcxCustomScheduler.DragDrop sposta
  // l'evento da se'
  if FNativo then
    Exit;

  DisableDelayedRefresh := True;
  try
    Ok := Source = Scheduler;

    if not Ok then
      if Source is TcxSchedulerDragObject then
        Ok := TcxSchedulerDragObject(Source).Control = Scheduler;

    if not Ok then
      Exit;

    Scheduler.CurrentView.HitTest.HitPoint := Point(X - Scheduler.Bounds.Left, Y - Scheduler.Bounds.Top - DeltaDragY + 3);

    if not Scheduler.CurrentView.HitTest.HitAtEvent then
      Exit;

    if not HitTestModificabile(Scheduler.CurrentView.HitTest.Event) then
      Exit;

    Params.Init;
    Params.Kind := HitTestTipoEvento(Scheduler.CurrentView.HitTest.Event);

    if Params.Kind = '' then
      Exit;

    Params.Id := HitTestIdEvento(Scheduler.CurrentView.HitTest.Event);
    if Params.Id = -1 then
      Exit;

    // con la regola del database: una fine alle 23:59 vale come mezzanotte
    Durata := TzSchedulerCalcoli.DurataEvento(Scheduler.CurrentView.HitTest.Event.Start, Scheduler.CurrentView.HitTest.Event.Finish);

    Momento := GetNearestFreeTime(Params, Scheduler.CurrentView.HitTest.Time, Durata, Scheduler.CurrentView.HitTest.Event,
      Scheduler.CurrentView.HitTest.Resource);
    if Momento = -1 then
    begin
      ConfirmOk(SSpazioOccupato);
      Exit;
    end;

    // spostato oltre la mezzanotte non si salverebbe (vincoli delle tabelle),
    // e accorciarlo senza una scheda cambierebbe l'evento senza avvisare
    if TzSchedulerCalcoli.SuperaLaMezzanotte(TimeOf(Momento), Durata) then
    begin
      ConfirmOk(SOltreMezzanotte);
      Exit;
    end;

    Params.Data := DateOf(Momento);
    Params.OraInizio := TimeOf(Momento);
    // un evento che finirebbe alle 24:00 esatte finisce alle 23:59
    Params.Durata := TzSchedulerCalcoli.DurataEntroLaGiornata(Params.OraInizio, Durata);

    if Assigned(Scheduler.CurrentView.HitTest.Resource) then
      if not VarIsNull(Scheduler.CurrentView.HitTest.Resource.ResourceID) then
      begin
        Params.ResourceID := Scheduler.CurrentView.HitTest.Resource.ResourceID;
        Params.ResourceFieldName := StorageResourceFieldName;
      end;

    if TzSchedulerEvents.Sposta(Params) then
    begin
      RefreshScheduler;
      Event := GetEvento(Params.Kind, Params.Id);
      if Assigned(Event) then
        Scheduler.SelectTime(Event.Start, Event.Finish, Event.GetResourceItem);
    end;
  finally
    DisableDelayedRefresh := False;
  end;
end;

// Orario di destinazione di un evento trascinato: la cella della scala oraria
// su cui cade il suo inizio, oppure -1 se in quell'orario la stessa risorsa ha
// gia' un evento con cui il tipo non puo' sovrapporsi.
//
// Rilascio 022: prima l'evento veniva spostato di mezz'ora o di un'ora (prima e
// dopo) quando l'orario risultava occupato, e risultava occupato anche per gli
// eventi delle altre risorse (le prenotazioni delle altre aule, caricate tutte
// nello storage) e per una durata pari alla scala oraria invece di quella
// dell'evento: l'evento finiva a un orario diverso da quello scelto. Nel vecchio
// Frame_Scheduler gli scarti non avevano effetto (TDateTime.AddMinute restituisce
// il valore senza modificarlo) e l'evento, in quel caso, non si spostava affatto.
function TzDbScheduler.GetNearestFreeTime(const Params: TzSchedulerEventParams; Value: TDateTime; Durata: Integer;
  Trascinato: TcxSchedulerEvent; Risorsa: TcxSchedulerStorageResourceItem): TDateTime;
var
  Kind: TzSchedulerEventKind;
  Origine: TcxSchedulerEvent;

  function RoundTime(Time: TDateTime; Minutes: Integer): TDateTime;
  var
    Frazione: Double;
  begin
    Frazione := (Minutes * 60) / (60 * 60 * 24);
    result := Round(Time / Frazione) * Frazione;
  end;

  function Overlap(From1, To1, From2, To2: TDateTime): Boolean;
  begin
    result := (From1 < To2) and (From2 < To1);
  end;

  function EventoTrascinato(Event: TcxSchedulerEvent): Boolean;
  begin
    result := (Event = Trascinato) or (Assigned(Origine) and (Event = Origine));

    if not result and Assigned(Kind) then
      if SameText(VarToStr(SchedulerEventValue(Event, zSchedulerKindField)), Params.Kind) then
        result := SchedulerEventValue(Event, Kind.IdFieldName) = Params.Id;
  end;

  function Occupato(Momento: TDateTime): Boolean;
  var
    i: Integer;
    Event: TcxSchedulerEvent;
  begin
    result := False;

    for i := 0 to Scheduler.Storage.EventCount - 1 do
    begin
      Event := Scheduler.Storage.Events[i];

      // l'evento che si sta spostando non occupa il suo posto
      if EventoTrascinato(Event) then
        Continue;

      // contano solo gli eventi della risorsa di destinazione (l'aula, il docente...)
      if Assigned(Risorsa) and not Event.IsResourceEvent(Risorsa, True) then
        Continue;

      // tipi che possono sovrapporsi (CanIntersect dell'applicazione)
      if TzSchedulerEvents.CanIntersect(VarToStr(SchedulerEventValue(Event, zSchedulerKindField)), Params.Kind) then
        Continue;

      result := Overlap(Event.Start, Event.Finish, Momento, IncMinute(Momento, Durata));

      if result then
        Break;
    end;
  end;

var
  Scala: Integer;
  Tentativo: TDateTime;
begin
  result := -1;

  if not Assigned(Scheduler.Storage) then
    Exit;

  Kind := TzSchedulerEvents.Find(Params.Kind);

  // l'evento sotto il mouse e' la copia di trascinamento, la cui origine e' a
  // sua volta un evento del calendario: si risale fino all'evento dello storage
  Origine := Trascinato;
  while Origine is TcxSchedulerControlEvent do
    Origine := TcxSchedulerControlEvent(Origine).Source;

  if Durata <= 0 then
    Durata := 1;

  // la cella della scala oraria visualizzata, non la mezz'ora: con la scala a
  // 15 minuti l'evento resta dove l'utente l'ha lasciato
  Scala := Scheduler.ViewDay.TimeScale;
  if Scala <= 0 then
    Scala := 30;

  Tentativo := RoundTime(Value, Scala);
  if not Occupato(Tentativo) then
    result := Tentativo;
end;

// ---------------------------------------------------------------------------
// Copia e incolla
// ---------------------------------------------------------------------------

procedure TzDbScheduler.TagliaOraExecute(Sender: TObject);
begin
  CopiaIncolla.TagliaOra(SelectedIdEvento);
end;

procedure TzDbScheduler.TagliaOraUpdate(Sender: TObject);
begin
  TagliaOra.Enabled := Assigned(FSchedulerCopyPaste) and Contains(FSchedulerCopyPaste.TipoEventiPerInserimento, SelectedTipoEvento);
end;

procedure TzDbScheduler.CopiaOraExecute(Sender: TObject);
begin
  CopiaIncolla.CopiaOra(SelectedIdEvento);
end;

procedure TzDbScheduler.CopiaOraUpdate(Sender: TObject);
begin
  CopiaOra.Enabled := Assigned(FSchedulerCopyPaste) and Contains(FSchedulerCopyPaste.TipoEventiPerInserimento, SelectedTipoEvento);
end;

procedure TzDbScheduler.CopiaGiornoExecute(Sender: TObject);
begin
  CopiaIncolla.CopiaGiorno(DateOf(Scheduler.SelStart));
end;

procedure TzDbScheduler.CopiaSettimanaExecute(Sender: TObject);
begin
  if Assigned(FSchedulerStorage) then
    CopiaIncolla.CopiaSettimana(FSchedulerStorage.GetSchedulerParams.DalGiorno);
end;

procedure TzDbScheduler.IncollaExecute(Sender: TObject);
var
  DataDestinazione: TDate;
  OraDestinazione: TTime;
begin
  if not Assigned(FSchedulerCopyPaste) then
    Exit;

  DisableDelayedRefresh := True;
  try
    DataDestinazione := DateOf(Scheduler.SelStart);
    OraDestinazione := TimeOf(Scheduler.SelStart);

    case CopiaIncolla.Tipo of
      ciTagliaOra:
        FSchedulerCopyPaste.IncollaOra(CopiaIncolla.IdOra, DataDestinazione, OraDestinazione, True);
      ciCopiaOra:
        FSchedulerCopyPaste.IncollaOra(CopiaIncolla.IdOra, DataDestinazione, OraDestinazione, False);
      ciCopiaGiorno:
        FSchedulerCopyPaste.IncollaGiorno(CopiaIncolla.Data, DataDestinazione);
      ciCopiaSettimana:
        FSchedulerCopyPaste.IncollaSettimana(CopiaIncolla.Data, DataDestinazione);
    end;
  finally
    DisableDelayedRefresh := False;
  end;
end;

procedure TzDbScheduler.IncollaUpdate(Sender: TObject);
begin
  Incolla.Enabled := CopiaIncolla.Tipo <> ciNulla;
end;

// ---------------------------------------------------------------------------
// Aspetto degli eventi
// ---------------------------------------------------------------------------

procedure TzDbScheduler.SchedulerInitEventImages(Sender: TcxCustomScheduler; AEvent: TcxSchedulerControlEvent; AImages: TcxSchedulerEventImages);
var
  Kind: TzSchedulerEventKind;
  Icone: TzSchedulerEventImagesProc;
begin
  if Assigned(FOnInitEventImages) then
  begin
    FOnInitEventImages(Sender, AEvent, AImages);
    Exit;
  end;

  // modo nativo: restano le icone di DevExpress (promemoria, ricorrenza)
  if FNativo then
    Exit;

  AImages.Clear;

  Kind := TzSchedulerEvents.Find(HitTestTipoEvento(AEvent));
  if not Assigned(Kind) then
    Exit;

  Icone := Kind.InitEventImages;
  if Assigned(Icone) then
    Icone(AEvent, AImages)
  else
    if Kind.EventImageIndex >= 0 then
      AImages.Add(Kind.EventImageIndex);
end;

procedure TzDbScheduler.SchedulerCustomDrawEvent(Sender: TObject; ACanvas: TcxCanvas; AViewInfo: TcxSchedulerEventCellViewInfo; var ADone: Boolean);
var
  Value: Variant;
  Colore: TColor;
begin
  Value := SchedulerEventValue(AViewInfo.Event, zSchedulerColorField);

  if not VarIsNull(Value) then
  begin
    Colore := Value;
    ACanvas.Brush.Color := Colore;
    ACanvas.Font.Color := GetContrastColor(ACanvas.Brush.Color);
  end
  else
    // modo nativo: il colore e' l'etichetta dell'evento (LabelColor), il
    // testo resta leggibile come nella home di GeRA
    if FNativo then
      ACanvas.Font.Color := GetContrastColor(ACanvas.Brush.Color);
end;

procedure TzDbScheduler.SchedulerCustomDrawContent(Sender: TObject; ACanvas: TcxCanvas; AViewInfo: TcxSchedulerContentCellViewInfo; var ADone: Boolean);
begin
  if not FMostraDateMese then
    Exit;

  // Vista mese: per tutti i giorni mostra gg mmm, di default solo sul primo e sull'ultimo
  if AViewInfo is TcxSchedulerMonthDayContentCellViewInfo then
  begin
    TcxSchedulerContentCellViewInfoAccess(AViewInfo).FTextRect.Left := TcxSchedulerContentCellViewInfoAccess(AViewInfo).Bounds.Left;
    TcxSchedulerContentCellViewInfoAccess(AViewInfo).DisplayText := FormatDateTime('dd mmm', AViewInfo.TimeStart);
  end;
end;

procedure TzDbScheduler.SchedulerGetEventHintText(Sender: TObject; AEvent: TcxSchedulerControlEvent; var AText: string);
begin
  // modo nativo: il suggerimento di DevExpress (orario, oggetto, luogo)
  if FNativo then
    Exit;

  AText := VarToStr(SchedulerEventValue(AEvent, zSchedulerHintField));
end;

function TzDbScheduler.GetEventImages: TCustomImageList;
begin
  result := Scheduler.EventImages;
end;

procedure TzDbScheduler.SetEventImages(const Value: TCustomImageList);
begin
  Scheduler.EventImages := Value;
end;

function TzDbScheduler.GetFreeBarImages: TCustomImageList;
begin
  result := dxBarManagerBarFree.Images;
end;

procedure TzDbScheduler.SetFreeBarImages(const Value: TCustomImageList);
begin
  dxBarManagerBarFree.Images := Value;
end;

// ---------------------------------------------------------------------------
// Risorse, barra, uscite
// ---------------------------------------------------------------------------

procedure TzDbScheduler.CalendarioResourceNavigatorButtonClick(Sender: TcxSchedulerResourceNavigator; AButton: TcxSchedulerNavigatorButton; var AHandled: Boolean);
begin
  if not AButton.IsStandard then
  begin
    AHandled := True;

    if Scheduler.Storage <> nil then
      cxShowResourcesLayoutEditor(Scheduler.Storage, Scheduler.LookAndFeel);
  end;
end;

procedure TzDbScheduler.RisorseExecute(Sender: TObject);
begin
  if Assigned(FSelectRisorseProc) then
    FSelectRisorseProc;
end;

procedure TzDbScheduler.RisorseUpdate(Sender: TObject);
begin
  Risorse.Visible := Assigned(FSelectRisorseProc);
end;

procedure TzDbScheduler.popSchedulerPopup(Sender: TObject);
begin
  popSchedulerPopupPoint := Scheduler.ScreenToClient(GetMouseCursorPos);
end;

function TzDbScheduler.GetControlBoxVisible: Boolean;
begin
  result := Scheduler.ControlBox.Visible;
end;

procedure TzDbScheduler.SetControlBoxVisible(const Value: Boolean);
begin
  Scheduler.ControlBox.Visible := Value;
end;

procedure TzDbScheduler.SetControlBox(Control: TWinControl; const Visible: Boolean = True);
begin
  Scheduler.ControlBox.Control := Control;
  Control.Visible := True;
  Scheduler.ControlBox.Visible := Visible;
end;

function TzDbScheduler.AddToolbarButton(Action: TAction; const Position: Integer = 0): TdxBarButton;
begin
  Assert(Assigned(Action));

  result := TdxBarButton.Create(Self);
  result.Name := CreateUniqueName(Self, Self, result, 'btn' + Action.Name, '');
  result.Action := Action;
  result.PaintStyle := psCaptionGlyph;

  if Action.AutoCheck then
  begin
    result.ButtonStyle := bsChecked;
    result.Down := Action.Checked;
  end;

  dxBarManagerBarFree.ItemLinks.Add(result);
end;

function TzDbScheduler.AddToolbarEditItem(const Name: string; const Width: Integer = 0): TcxBarEditItem;
begin
  result := TcxBarEditItem.Create(Self);
  result.Name := Name;
  result.Width := Width;
  dxBarManagerBarFree.ItemLinks.Add(result);
end;

function TzDbScheduler.AddToolbarStatic(const Name: string; const Width: Integer = 0): TdxBarStatic;
begin
  result := TdxBarStatic.Create(Self);
  result.Name := Name;
  result.ShowCaption := False;
  result.Width := Width;
  dxBarManagerBarFree.ItemLinks.Add(result);
end;

procedure TzDbScheduler.AnteprimaExecute(Sender: TObject);
begin
  Preview;
end;

procedure TzDbScheduler.Preview;
begin
  DisableDelayedRefresh := True;
  try
    dxComponentPrinterLinkScheduler.PrinterPage.Orientation := poLandscape;
    dxComponentPrinterLinkScheduler.PrintStyles.Weekly.DaysLayout := wdlOneColumn;
    dxComponentPrinterLinkScheduler.PrintStyles.Weekly.ResourceCountPerPage := Scheduler.OptionsView.ResourcesPerPage;
    dxComponentPrinterLinkScheduler.PrintStyles.Monthly.ResourceCountPerPage := Scheduler.OptionsView.ResourcesPerPage;

    dxComponentPrinter.Preview(True, dxComponentPrinterLinkScheduler);
  finally
    DisableDelayedRefresh := False;
  end;
end;

procedure TzDbScheduler.ExportXLSExecute(Sender: TObject);
var
  Dialog: TSaveDialog;
begin
  DisableDelayedRefresh := True;
  try
    // Gesty registra la sua esportazione (Excel o CSV per Google e Outlook)
    if Assigned(TzSchedulerEvents.ExportProc) then
    begin
      TzSchedulerEvents.ExportProc(Scheduler);
      Exit;
    end;

    // come WT: Excel degli eventi della vista
    Dialog := TSaveDialog.Create(nil);
    try
      Dialog.DefaultExt := 'xlsx';
      Dialog.Filter := 'Excel|*.xlsx|Excel 97|*.xls';
      Dialog.Options := Dialog.Options + [ofOverwritePrompt];

      if Dialog.Execute then
        if Dialog.FilterIndex = 2 then
          cxExportSchedulerToExcel(ChangeFileExt(Dialog.FileName, '.xls'), Scheduler)
        else
          cxExportSchedulerToXLSX(ChangeFileExt(Dialog.FileName, '.xlsx'), Scheduler);
    finally
      FreeAndNil(Dialog);
    end;
  finally
    DisableDelayedRefresh := False;
  end;
end;

// ---------------------------------------------------------------------------
// Dizionario LZ: azioni create dal frame (il .dfm resta quello del calendario
// condiviso con le form di Gesty e WinTarif). Icone dalla lista standard dei
// componenti zPack, con gli stessi indici di TzDbRecordView
// ---------------------------------------------------------------------------

function TzDbScheduler.NewLzAction(const ActionName, Caption: string; const ImageIndex: Integer; Handler: TNotifyEvent; const ShortCut: TShortCut = 0): TzFocusedAction;
begin
  result := TzFocusedAction.Create(Self);
  result.Name := ActionName;
  result.ActionList := Actions;
  result.Caption := Caption;
  result.Hint := Caption;
  result.ImageIndex := ImageIndex;
  result.ShortCut := ShortCut;
  result.OnExecute := Handler;
  // visibili solo con il dizionario (UpdateLzActions)
  result.Visible := False;
end;

procedure TzDbScheduler.CreateLzActions;

  function Pulsante(Action: TCustomAction): TdxBarButton;
  begin
    result := TdxBarButton.Create(Self);
    // Il gestore delle barre prima dell'azione: un pulsante creato da codice
    // lo riceve solo quando entra in una barra, e le azioni del dizionario
    // nascono invisibili, quindi assegnare l'azione cambia la visibilita' e
    // TdxBarItem.VisibleChanged chiama BarManager.BeginUpdate su nil
    result.BarManager := dxBarManager;
    result.Action := Action;
  end;

var
  Link: TdxBarItemLink;
begin
  actDbRefresh := NewLzAction('actDbRefresh', 'Aggiorna', 14, actDbRefreshExecute, TShortCut(VK_F5));
  Elabora := NewLzAction('Elabora', 'Elabora', 29, ElaboraExecute);
  actPersonalizza := NewLzAction('actPersonalizza', 'Personalizza', 21, actPersonalizzaExecute, TShortCut(VK_F11));
  SalvaImpostazioni := NewLzAction('SalvaImpostazioni', 'Salva Impostazioni', 32, SalvaImpostazioniExecute);
  CaricaImpostazioni := NewLzAction('CaricaImpostazioni', 'Carica Impostazioni', 33, CaricaImpostazioniExecute);
  actSQL := NewLzAction('actSQL', 'SQL', 30, actSQLExecute);
  MostraQueryUtilizzata := NewLzAction('MostraQueryUtilizzata', 'Mostra Query Utilizzata', 78, MostraQueryUtilizzataExecute);
  CopiaQueryUtilizzata := NewLzAction('CopiaQueryUtilizzata', 'Copia Query Utilizzata', 2, CopiaQueryUtilizzataExecute);
  CopyName := NewLzAction('CopyName', 'Copia SchedulerID', 65, CopyNameExecute);
  EditTools := NewLzAction('EditTools', 'Tools...', 88, EditToolsExecute);

  // Aggiorna ed Elabora in coda alla barra del calendario
  Link := dxBarManagerBar.ItemLinks.Add(Pulsante(actDbRefresh));
  Link.BeginGroup := True;
  dxBarManagerBar.ItemLinks.Add(Pulsante(Elabora));

  // Impostazioni dell'amministratore, come negli altri componenti
  dxBarSubItemImpostazioni := TdxBarSubItem.Create(Self);
  dxBarSubItemImpostazioni.BarManager := dxBarManager;
  dxBarSubItemImpostazioni.Caption := 'Impostazioni';
  dxBarSubItemImpostazioni.ImageIndex := dx.IndiceIcona('actions_settings');
  dxBarSubItemImpostazioni.Visible := ivNever;
  dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(actPersonalizza));
  dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(SalvaImpostazioni));
  dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(CaricaImpostazioni));
  Link := dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(actSQL));
  Link.BeginGroup := True;
  dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(MostraQueryUtilizzata));
  dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(CopiaQueryUtilizzata));
  dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(CopyName));
  Link := dxBarSubItemImpostazioni.ItemLinks.Add(Pulsante(EditTools));
  Link.BeginGroup := True;
  dxBarManagerBar.ItemLinks.Add(dxBarSubItemImpostazioni).BeginGroup := True;

  // avviso dei campi obbligatori che mancano nella mappatura
  FBarAvviso := TdxBarStatic.Create(Self);
  FBarAvviso.BarManager := dxBarManager;
  FBarAvviso.Visible := ivNever;
  dxBarManagerBarFree.ItemLinks.Add(FBarAvviso);
end;

// ---------------------------------------------------------------------------
// IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
// ---------------------------------------------------------------------------

function TzDbScheduler.GetComponentType: TzComponentType;
begin
  result := ctScheduler;
end;

function TzDbScheduler.GetID: string;
begin
  result := SchedulerID;
end;

procedure TzDbScheduler.SetID(const Value: string);
begin
  SchedulerID := Value;
end;

function TzDbScheduler.GetToolActions: TzToolActions;
begin
  result := FToolActions;
end;

procedure TzDbScheduler.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

function TzDbScheduler.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, FzDbSchedulerProps.ActionOwnerName);
end;

function TzDbScheduler.GetActionOwnerName: string;
begin
  result := FzDbSchedulerProps.ActionOwnerName;
end;

procedure TzDbScheduler.SetActionOwnerName(const Value: string);
begin
  FzDbSchedulerProps.ActionOwnerName := Value;
end;

procedure TzDbScheduler.RebuildActions;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

procedure TzDbScheduler.RebuildFilters;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

function TzDbScheduler.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := SchedulerID;
end;

procedure TzDbScheduler.RebuildToolbar;
begin
  // Prima i filtri, poi le azioni: i filtri precedono le azioni sulla barra
  CreateFiltersFromProps;
  InitToolActions;
end;

function TzDbScheduler.GetProps: TzBaseComponentProps;
begin
  result := FzDbSchedulerProps;
end;

function TzDbScheduler.GetToolbar: TdxBar;
begin
  result := dxBarManagerBarFree;
end;

function TzDbScheduler.GetzDataSet: TzFbDataSet;
begin
  result := FzDataSet;
end;

procedure TzDbScheduler.SetzDataSet(const Value: TzFbDataSet);
begin
  if FzDataSet = Value then
    Exit;

  if Assigned(FzDataSet) then
    FzDataSet.RemoveFreeNotification(Self);

  FzDataSet := Value;

  if Assigned(FzDataSet) then
    FzDataSet.FreeNotification(Self);

  FDataController.DataSet := Value;

  // dataset diverso: storage e props da capo
  if Assigned(FLzStorage) then
    FLzStorage.DataSource := nil;
  FEventSource.DataSet := nil;
  FStorageBound := False;
  FPeriodoValido := False;
  FLzBuilt := False;

  InitLz;
end;

function TzDbScheduler.GetToolFilters: TzToolFiltersProps;
begin
  result := FzDbSchedulerProps.ToolFilters;
end;

procedure TzDbScheduler.SetToolFilters(const Value: TzToolFiltersProps);
begin
  FzDbSchedulerProps.ToolFilters.Assign(Value);
end;

// ---------------------------------------------------------------------------
// Dizionario LZ: proprieta'
// ---------------------------------------------------------------------------

function TzDbScheduler.GetSchedulerID: string;
begin
  if (FzDbSchedulerProps.Name = '') and FDataController.DataSetOk then
    FzDbSchedulerProps.Name := FDataController.IdDataSet;

  result := FzDbSchedulerProps.Name;
end;

procedure TzDbScheduler.SetSchedulerID(const Value: string);
begin
  FzDbSchedulerProps.Name := Value;
end;

procedure TzDbScheduler.SetzSystem(const Value: TzSystem);
begin
  if FzSystem = Value then
    Exit;

  FzSystem := Value;

  if Assigned(FzSystem) then
    FzSystem.FreeNotification(Self);

  InitLz;
end;

procedure TzDbScheduler.SetzResourceDataSet(const Value: TzFbDataSet);
begin
  if FzResourceDataSet = Value then
    Exit;

  if Assigned(FzResourceDataSet) then
    FzResourceDataSet.RemoveFreeNotification(Self);

  FzResourceDataSet := Value;

  if Assigned(FzResourceDataSet) then
    FzResourceDataSet.FreeNotification(Self);

  if FStorageBound then
    BindStorage;
end;

// Assegnata a calendario gia' legato (il caso normale: la form la assegna dopo
// BuildGui) vale subito, senza rilegare lo storage; assegnata prima, la passa
// BindStorage a InitNativo. In tutti e due i casi "Modifica" si vede anche in
// sola lettura, come per l'ApriEvento di InitNativo.
procedure TzDbScheduler.SetApriEventoLz(const Value: TzSchedulerApriEventoFunc);
begin
  FApriEventoLz := Value;

  if FStorageBound and FNativo then
  begin
    FApriEventoNativo := Value;
    ModificaOra.Visible := not FSolaLettura or Assigned(FApriEventoNativo);
  end;
end;

procedure TzDbScheduler.SetRestrictionReadOnly(const Value: Boolean);
begin
  if FRestrictionReadOnly = Value then
    Exit;

  FRestrictionReadOnly := Value;

  if FStorageBound then
    BindStorage;
end;

function TzDbScheduler.zSystemOk: Boolean;
begin
  result := Assigned(FzSystem);
end;

function TzDbScheduler.IsAdmin: Boolean;
begin
  result := zSystemOk and FzSystem.IsAdmin;
end;

function TzDbScheduler.LzReadOnly: Boolean;
begin
  result := FRestrictionReadOnly or FzDbSchedulerProps.Flags.ReadOnly;
end;

function TzDbScheduler.ResourceDataSetName: string;
begin
  result := Trim(FzDbSchedulerProps.ResourceDataSet);
end;

procedure TzDbScheduler.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation <> opRemove then
    Exit;

  if AComponent = FzSystem then
    FzSystem := nil;

  if AComponent = FzDataSet then
  begin
    FzDataSet := nil;
    if Assigned(FEventSource) then
      FEventSource.DataSet := nil;
    if Assigned(FDataController) then
      FDataController.DataSet := nil;
  end;

  if AComponent = FzResourceDataSet then
  begin
    FzResourceDataSet := nil;
    if Assigned(FResourceSource) then
      FResourceSource.DataSet := nil;
  end;

  if (AComponent is TAction) or (AComponent is TImageList) then
    if Assigned(FToolActions) then
      FToolActions.RemoveNotification(AComponent);
end;

// ---------------------------------------------------------------------------
// Dizionario LZ: costruzione
// ---------------------------------------------------------------------------

procedure TzDbScheduler.InitLz;
begin
  if FLzBuilt then
    Exit;

  if csDesigning in ComponentState then
    Exit;

  if not zSystemOk then
    Exit;

  if not FDataController.DataSetOk then
    Exit;

  if not Assigned(actDbRefresh) then
    CreateLzActions;

  LoadProperties(True);
  FLzBuilt := True;

  // vista dell'utente o delle props; il setter scrive i parametri del periodo
  // prima che il FormController apra il dataset
  LoadUserSettings;

  // scorrimento con il calendarietto o con le viste di DevExpress
  Scheduler.DateNavigator.OnPeriodChanged := DateNavigatorPeriodChanged;

  BindStorage;
  UpdateLzActions;
end;

procedure TzDbScheduler.BindStorage;

  procedure ImpostaCampo(const Campo: TzSchedulerField; const Nome: string);
  begin
    case Campo of
      sfID:
        FLzStorage.FieldNames.ID := Nome;
      sfStart:
        FLzStorage.FieldNames.Start := Nome;
      sfFinish:
        FLzStorage.FieldNames.Finish := Nome;
      sfCaption:
        FLzStorage.FieldNames.Caption := Nome;
      sfMessage:
        FLzStorage.FieldNames.Message := Nome;
      sfLocation:
        FLzStorage.FieldNames.Location := Nome;
      sfLabelColor:
        FLzStorage.FieldNames.LabelColor := Nome;
      sfEventType:
        FLzStorage.FieldNames.EventType := Nome;
      sfOptions:
        FLzStorage.FieldNames.Options := Nome;
      sfParentID:
        FLzStorage.FieldNames.ParentID := Nome;
      sfRecurrenceIndex:
        FLzStorage.FieldNames.RecurrenceIndex := Nome;
      sfRecurrenceInfo:
        FLzStorage.FieldNames.RecurrenceInfo := Nome;
      sfResourceID:
        FLzStorage.FieldNames.ResourceID := Nome;
      sfState:
        FLzStorage.FieldNames.State := Nome;
      sfActualStart:
        FLzStorage.FieldNames.ActualStart := Nome;
      sfActualFinish:
        FLzStorage.FieldNames.ActualFinish := Nome;
      sfReminderDate:
        FLzStorage.FieldNames.ReminderDate := Nome;
      sfReminderMinutesBeforeStart:
        FLzStorage.FieldNames.ReminderMinutesBeforeStart := Nome;
      sfReminderResourcesData:
        FLzStorage.FieldNames.ReminderResourcesData := Nome;
      sfTaskComplete:
        FLzStorage.FieldNames.TaskCompleteField := Nome;
      sfTaskIndex:
        FLzStorage.FieldNames.TaskIndexField := Nome;
      sfTaskLinks:
        FLzStorage.FieldNames.TaskLinksField := Nome;
      sfTaskStatus:
        FLzStorage.FieldNames.TaskStatusField := Nome;
    end;
  end;

const
  MinutiGiorno = 24 * 60;
var
  Props: TzDbSchedulerProps;
  Mapping: TzSchedulerMapping;
  Campo: TzSchedulerField;
  Nome: string;
  Mappati: TStringList;
  Field: TField;
  Mancanti: string;
begin
  if not FLzBuilt or FIsDestroying then
    Exit;

  if not Assigned(FzDataSet) then
    Exit;

  Props := FzDbSchedulerProps;
  Mapping := Props.Mapping;

  // Senza campi (dataset mai aperto) la mappatura non si risolve: lo storage
  // si lega quando il dataset si apre (EventSourceStateChange)
  if FzDataSet.FieldCount = 0 then
  begin
    FEventSource.DataSet := FzDataSet;
    Exit;
  end;

  if not Assigned(FLzStorage) then
    FLzStorage := TcxSchedulerDBStorage.Create(Self);

  Mappati := TStringList.Create;
  try
    Mappati.CaseSensitive := False;

    FLzStorage.BeginUpdate;
    try
      FLzStorage.DataSource := nil;
      FLzStorage.Resources.DataSource := nil;
      FLzStorage.CustomFields.Clear;

      for Campo := Low(TzSchedulerField) to High(TzSchedulerField) do
      begin
        Nome := Mapping.Resolve(Campo, FzDataSet);
        ImpostaCampo(Campo, Nome);
        if Nome <> '' then
          Mappati.Add(Nome);
      end;

      // gli altri campi diventano campi personalizzati: li leggono
      // SchedulerEventValue, i suggerimenti, le icone e le form di dominio
      if Props.Flags.AutoCustomFields then
        for Field in FzDataSet.Fields do
          if Mappati.IndexOf(Field.FieldName) = -1 then
            FLzStorage.CustomFields.Add.FieldName := Field.FieldName;

      if Assigned(FzResourceDataSet) and (Trim(Props.ResourceIdField) <> '') then
      begin
        FResourceSource.DataSet := FzResourceDataSet;
        FLzStorage.Resources.ResourceID := Trim(Props.ResourceIdField);
        FLzStorage.Resources.ResourceName := Trim(Props.ResourceNameField);
        FLzStorage.Resources.ResourceColor := Trim(Props.ResourceColorField);
        FLzStorage.Resources.DataSource := FResourceSource;
      end;

      FEventSource.DataSet := FzDataSet;
      FLzStorage.DataSource := FEventSource;
    finally
      FLzStorage.EndUpdate;
    end;
  finally
    FreeAndNil(Mappati);
  end;

  FStorageBound := True;

  // modo nativo: le scritture le fa lo storage sul dataset del dizionario;
  // l'apertura dell'evento e' quella chiesta dalla form ospite (ApriEvento),
  // senza la quale in sola lettura il doppio clic su un evento non farebbe
  // niente
  InitNativo(FLzStorage, LzReadOnly, FApriEventoLz);

  // dopo InitNativo, che spegne WorkTimeOnly e accende le ricorrenze
  Scheduler.EventOperations.Recurrence := not LzReadOnly and Props.Flags.Recurrence and (Mapping.Resolve(sfRecurrenceIndex, FzDataSet) <> '') and
    (Mapping.Resolve(sfRecurrenceInfo, FzDataSet) <> '');

  if (Props.WorkStart >= 0) and (Props.WorkFinish > Props.WorkStart) and (Props.WorkFinish <= MinutiGiorno) then
  begin
    Scheduler.OptionsView.WorkStart := Props.WorkStart / MinutiGiorno;
    Scheduler.OptionsView.WorkFinish := Props.WorkFinish / MinutiGiorno;
  end;
  Scheduler.ViewDay.WorkTimeOnly := Props.Flags.WorkTimeOnly;
  Scheduler.DateNavigator.Visible := Props.Flags.DateNavigator;

  // DevExpress senza un campo obbligatorio non carica nulla e non lo dice
  Mancanti := Mapping.MissingRequired(FzDataSet);
  if Mancanti <> '' then
  begin
    FBarAvviso.Caption := 'Calendario senza i campi obbligatori: ' + Mancanti;
    FBarAvviso.Visible := ivAlways;
  end
  else
    FBarAvviso.Visible := ivNever;

  UpdateLzActions;
end;

procedure TzDbScheduler.ApplicaPeriodoLz(const DalGiorno, AlGiorno: TDateTime);

  procedure Imposta(Param: TFDParam; const Valore: TDateTime);
  begin
    // un parametro DATE riceve la sola data
    if Param.DataType = ftDate then
      Param.AsDate := DateOf(Valore)
    else
      Param.AsDateTime := Valore;
  end;

var
  ParamDal, ParamAl: TFDParam;
  Dal, Al: TDateTime;
begin
  if not Assigned(FzDataSet) then
    Exit;

  ParamDal := FzDataSet.Params.FindParam(FzDbSchedulerProps.PeriodFromParamName);
  ParamAl := FzDataSet.Params.FindParam(FzDbSchedulerProps.PeriodToParamName);

  // senza i parametri il dataset ha gia' tutti gli eventi
  if not Assigned(ParamDal) or not Assigned(ParamAl) then
    Exit;

  // una settimana di margine per parte: lo scorrimento vicino non rilegge
  // (TzSchedulerCalcoli.PeriodoDaLeggere, collaudata in zPackTests)
  if not TzSchedulerCalcoli.PeriodoDaLeggere(DalGiorno, AlGiorno, FPeriodoValido, FzDataSet.Active, FPeriodoDal,
    FPeriodoAl, Dal, Al) then
    Exit;

  Imposta(ParamDal, Dal);
  Imposta(ParamAl, Al);

  FPeriodoDal := Dal;
  FPeriodoAl := Al;
  FPeriodoValido := True;

  if FzDataSet.Active then
  begin
    FzDataSet.Close;
    FzDataSet.Open;
  end;
end;

procedure TzDbScheduler.DateNavigatorPeriodChanged(Sender: TObject; const AStart, AFinish: TDateTime);
begin
  // il periodo si legge dalla vista a scorrimento finito: qui DevExpress sta
  // ancora ridisegnando
  if FLzBuilt and not FIsDestroying then
  begin
    FTimerPeriodo.Enabled := False;
    FTimerPeriodo.Enabled := True;
  end;
end;

procedure TzDbScheduler.TimerPeriodoTimer(Sender: TObject);
begin
  FTimerPeriodo.Enabled := False;

  if FLzBuilt and not FIsDestroying and Assigned(Scheduler.CurrentView) then
    ApplicaPeriodoLz(Scheduler.CurrentView.FirstVisibleDate, Scheduler.CurrentView.LastVisibleDate);
end;

procedure TzDbScheduler.EventSourceStateChange(Sender: TObject);
begin
  if FIsDestroying then
    Exit;

  // primo aperto: ora i campi ci sono e lo storage si puo' legare
  if FLzBuilt and not FStorageBound and Assigned(FzDataSet) and FzDataSet.Active then
    PostInternalMessage(scBindStorage);

  PostInternalMessage(scUpdateActions);
end;

procedure TzDbScheduler.PostInternalMessage(const Command: TzDbSchedulerCommand);
begin
  if FIsDestroying or (csDestroying in ComponentState) then
    Exit;

  // Handle crea la finestra, e un frame senza genitore (creato dal
  // FormController e non ancora messo nel layout) solleverebbe "Control has
  // no parent window": in quel caso il comando si esegue subito
  if HandleAllocated or Assigned(Parent) then
    PostMessage(Self.Handle, ZZ_DBSCHEDULER, NativeUInt(Command), 0)
  else
    ExecuteCommand(Command);
end;

procedure TzDbScheduler.MessageHandler(var Message: TMessage);
begin
  ExecuteCommand(TzDbSchedulerCommand(Message.WParam));
end;

procedure TzDbScheduler.ExecuteCommand(const Command: TzDbSchedulerCommand);
begin
  if FIsDestroying then
    Exit;

  case Command of
    scUpdateActions:
      UpdateLzActions;
    scBindStorage:
      if not FStorageBound then
        BindStorage;
    scSaveZip:
      begin
        FSaveZipQueued := False;
        if zSystemOk then
          zSystem.SaveZip(csDbSchedulers, 'TzDbScheduler.SalvaImpostazioni');
      end;
  end;
end;

procedure TzDbScheduler.ReloadProps;
begin
  if not FLzBuilt then
    Exit;

  LoadProperties(True);
  BindStorage;
end;

procedure TzDbScheduler.LoadProperties(const LoadDefaults: Boolean);
begin
  if csDesigning in ComponentState then
    Exit;

  FLoadingProps := True;
  try
    if LoadDefaults then
      InternalLoadProperties;

    RebuildToolbar;
  finally
    FLoadingProps := False;
  end;

  UpdateLzActions;
end;

procedure TzDbScheduler.InternalLoadProperties;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzDbSchedulerProps.Name = '' then
    FzDbSchedulerProps.Name := SchedulerID;

  if FzDbSchedulerProps.DataSet = '' then
    FzDbSchedulerProps.DataSet := FDataController.IdDataSet;

  if Assigned(FOnCustomLoadProps) then
    FOnCustomLoadProps(Self)
  else
    if zSystemOk then
      FzDbSchedulerProps.LoadFromBase;
end;

procedure TzDbScheduler.InternalSaveProperties;
begin
  if Assigned(FOnCustomSaveProps) then
    FOnCustomSaveProps(Self)
  else
    if zSystemOk then
    begin
      // aggiornamento in memoria sincrono, scrittura dello zip differita e
      // coalescente come negli altri componenti
      FzDbSchedulerProps.SaveToBase(False);

      if not FSaveZipQueued then
      begin
        FSaveZipQueued := True;
        PostInternalMessage(scSaveZip);
      end;
    end;
end;

procedure TzDbScheduler.doSalvaImpostazioni(const Silent: Boolean = False);
begin
  if csDesigning in ComponentState then
    Exit;

  if not Silent then
    StartWait('Attendere...', True);
  try
    if FzDbSchedulerProps.Name = '' then
      FzDbSchedulerProps.Name := SchedulerID;

    if FzDbSchedulerProps.DataSet = '' then
      FzDbSchedulerProps.DataSet := FDataController.IdDataSet;

    InternalSaveProperties;
  finally
    if not Silent then
      StopWait;
  end;
end;

procedure TzDbScheduler.CreateFiltersFromProps;
begin
  TzToolFilterBuilder.Build(FzDbSchedulerProps.ToolFilters, Self, dxBarManager, FzDataSet);
end;

procedure TzDbScheduler.InitToolActions;
begin
  // azioni di dominio sulla barra libera e nel menu dell'evento
  TzActionBuilder.BuildFromProps(FzDbSchedulerProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(dxBarManagerBarFree, popEvent, otView);
end;

function TzDbScheduler.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
begin
  // Scrive sui props persistiti, come gli altri componenti: il runtime
  // ToolActions e' rigenerato da InitToolActions. FromCode protegge l'azione
  // da codice dall'Assign del dizionario. ImageList non e' persistibile.
  result := nil;

  if not Assigned(Action) then
    Exit;

  result := FzDbSchedulerProps.ToolActions.Find(Action.Name);
  if not Assigned(result) then
  begin
    result := FzDbSchedulerProps.ToolActions.Add;
    result.Name := Action.Name;
  end;

  result.FromCode := True;
end;

procedure TzDbScheduler.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;

  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbScheduler.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

procedure TzDbScheduler.OnFlagChange(Sender: TObject);
begin
  // durante il caricamento delle props l'Assign dei flag scatta piu' volte
  if FLoadingProps or FIsDestroying then
    Exit;

  UpdateLzActions;
end;

procedure TzDbScheduler.UpdateLzActions;
var
  Amministratore: Boolean;
begin
  if (csDestroying in ComponentState) or FIsDestroying then
    Exit;

  // senza dizionario il frame resta quello delle form di Gesty e WinTarif
  if not FLzBuilt then
    Exit;

  dxBarManager.BeginUpdate;
  try
    dxBarManagerBar.Visible := FzDbSchedulerProps.Flags.Toolbar;
    dxBarManagerBarFree.Visible := FzDbSchedulerProps.Flags.Toolbar;
  finally
    dxBarManager.EndUpdate;
  end;

  ActionVisible(actDbRefresh, FzDbSchedulerProps.Flags.ButtonRefresh and FDataController.DataSetOk);
  ActionVisible(Elabora, FzDbSchedulerProps.Flags.Params);

  Amministratore := IsAdmin;
  dxBarSubItemImpostazioni.Visible := dx.Visible(Amministratore);
  ActionVisible(actPersonalizza, Amministratore);
  ActionVisible(SalvaImpostazioni, Amministratore);
  ActionVisible(CaricaImpostazioni, Amministratore);
  ActionVisible(actSQL, Amministratore);
  ActionVisible(MostraQueryUtilizzata, Amministratore);
  ActionVisible(CopiaQueryUtilizzata, Amministratore);
  ActionVisible(CopyName, Amministratore);
  ActionVisible(EditTools, Amministratore);
  CopyName.Caption := 'Copia SchedulerID - ' + SchedulerID;

  if Assigned(FOnUpdateActions) then
    FOnUpdateActions(Self);
end;

procedure TzDbScheduler.ActivateDataSet;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FDataController.IsActive then
    Exit;

  if FDataController.AutoOpen then
    FDataController.OpenDataSet;
end;

// ---------------------------------------------------------------------------
// Dizionario LZ: titolo e impostazioni personali (vista e scala)
// ---------------------------------------------------------------------------

function TzDbScheduler.GetTitle: string;
begin
  result := Trim(FzDbSchedulerProps.Title);

  if result = '' then
    result := FRuntimeTitle;

  if result.IsEmpty then
  begin
    result := Name;
    if result.StartsWith('scheduler') then
      result := result.Replace('scheduler', '', [rfIgnoreCase]);
  end;
end;

procedure TzDbScheduler.SetTitle(const Title: string);
begin
  // il calendario non ha un titolo a video: serve alla configurazione e
  // all'elemento del layout
  FRuntimeTitle := Trim(Title);
end;

function TzDbScheduler.LayoutFileName: string;
var
  SafeID: string;
  Carattere: Char;
begin
  result := '';

  if not zSystemOk or (SchedulerID = '') then
    Exit;

  // L'identificativo e' del tipo Modulo.DataSet: il punto resta nel nome
  // (ChangeFileExt lo scambierebbe per l'estensione); si tolgono solo i
  // caratteri non ammessi
  SafeID := '';
  for Carattere in SchedulerID do
    if CharInSet(Carattere, ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then
      SafeID := SafeID + '_'
    else
      SafeID := SafeID + Carattere;

  result := IncludeTrailingPathDelimiter(FzSystem.PersonalFolder) + SafeID + '.scheduler';
end;

procedure TzDbScheduler.LoadUserSettings;
const
  SezioneCalendario = 'Calendario';
var
  FileName: string;
  Ini: TMemIniFile;
  Vista: Integer;
  Scala: Integer;
begin
  case FzDbSchedulerProps.ViewMode of
    svmDay:
      Vista := 0;
    svmMonth:
      Vista := 2;
  else
    Vista := 1;
  end;
  Scala := 0;

  FileName := LayoutFileName;

  if (FileName <> '') and FileExists(FileName) then
    try
      Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
      try
        Vista := Ini.ReadInteger(SezioneCalendario, 'Vista', Vista);
        Scala := Ini.ReadInteger(SezioneCalendario, 'Scala', 0);
      finally
        FreeAndNil(Ini);
      end;
    except
      // TEncoding.UTF8 solleva su byte non validi: valgono le impostazioni del dizionario
      on Exception do
        Scala := 0;
    end;

  if Scala in [5, 6, 10, 15, 30, 60] then
    Scheduler.ViewDay.TimeScale := Scala;

  case Vista of
    0:
      Giorno.Checked := True;
    2:
      Mese.Checked := True;
  else
    Settimana.Checked := True;
  end;

  case Vista of
    0:
      CurrentViewMode := vmDay;
    2:
      CurrentViewMode := vmMonth;
  else
    CurrentViewMode := vmWorkWeek;
  end;
end;

procedure TzDbScheduler.SaveUserSettings;
const
  SezioneCalendario = 'Calendario';
var
  FileName: string;
  Ini: TMemIniFile;
  Vista: Integer;
begin
  FileName := LayoutFileName;

  if FileName = '' then
    Exit;

  case CurrentViewMode of
    vmDay:
      Vista := 0;
    vmMonth:
      Vista := 2;
  else
    Vista := 1;
  end;

  try
    ForceDirectories(ExtractFilePath(FileName));

    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      Ini.WriteInteger(SezioneCalendario, 'Vista', Vista);
      Ini.WriteInteger(SezioneCalendario, 'Scala', Scheduler.ViewDay.TimeScale);
      Ini.UpdateFile;
    finally
      FreeAndNil(Ini);
    end;
  except
    // le impostazioni personali non devono bloccare il calendario
    on Exception do
      ;
  end;
end;

// ---------------------------------------------------------------------------
// Dizionario LZ: azioni
// ---------------------------------------------------------------------------

procedure TzDbScheduler.actDbRefreshExecute(Sender: TObject);
begin
  RefreshScheduler;
end;

procedure TzDbScheduler.ElaboraExecute(Sender: TObject);
begin
  ShowParams(SchedulerID + '_Params', zDataSet, 'Parametri', True);
end;

procedure TzDbScheduler.actPersonalizzaExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  if FzDbSchedulerProps.Inspect then
  begin
    LoadProperties(False);
    BindStorage;
    doSalvaImpostazioni(False);
  end;
end;

procedure TzDbScheduler.SalvaImpostazioniExecute(Sender: TObject);
begin
  doSalvaImpostazioni;
end;

procedure TzDbScheduler.CaricaImpostazioniExecute(Sender: TObject);
begin
  if ConfirmYesNo('Ricarico le impostazioni salvate?') then
    ReloadProps;
end;

procedure TzDbScheduler.actSQLExecute(Sender: TObject);
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzSystem.DataSetEditProps(zDataSet) then
  begin
    FDataController.OpenDataSet;
    BindStorage;
  end;
end;

procedure TzDbScheduler.MostraQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
    ConfirmOk(FDataController.GetDebugInfo);
end;

procedure TzDbScheduler.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
  begin
    Clipboard.AsText := FDataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbScheduler.CopyNameExecute(Sender: TObject);
begin
  Clipboard.AsText := SchedulerID;
  ConfirmOk(SchedulerID);
end;

procedure TzDbScheduler.EditToolsExecute(Sender: TObject);
begin
  ExecuteToolConfig;
end;

end.
