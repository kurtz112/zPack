// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-20
// ---------------------------------------------------------------------------
unit zDbChart;

// TzDbChart: grafico dati (TdxChartControl, ExpressCharts) su un dataset,
// sesto componente dati del dizionario LZ accanto a TzDbView, TzDbCard,
// TzDbPivot, TzDbRecordView e TzDbTree.
//
// Le serie nascono da TzDbChartProps (collezione LZ zDbCharts): una serie per
// campo numerico, con il campo argomento sull'asse delle categorie. Senza
// configurazione il grafico mostra il primo campo numerico per il primo campo
// di testo o data. Il dataset va aggregato nella query (GROUP BY): il
// controllo legge tutti i record e non aggrega.
//
// Diagramma, serie, immagini e stampa li fa zDbChart.Builder, che non dipende
// da zPack ed e' collaudato da solo (D:\AI\SandBox\zProvaDbChart); questa unit
// lega il motore al dizionario, al dataset e alla barra.
//
// Analisi e prove: OUT\20261001-componentizzazione-controlli-devexpress\
//   Analisi - 20261001 - Componente TzDbChart da grafico DevExpress.md
//   Fase 0 - 20261001 - Prove TzDbChart.md
//   Analisi - 20261001 - Implementazione TzDbChart.md
//
// Scelte che vengono dalle prove della fase 0:
// - oltre una soglia di punti il disegno si blocca (barre: 100.000 punti
//   3,9 s, 200.000 72 s): il grafico legge il dataset tramite una seconda
//   sorgente (ChartSource) che si aggancia solo dopo aver contato i record; a
//   ogni chiusura si spegne (Enabled False, non si sgancia: vedi
//   DataSourceStateChange), cosi' la riapertura successiva viene controllata
//   prima che il controllo legga. Oltre la soglia il grafico resta vuoto e dice
//   perche';
// - il doppio clic su un punto porta il dataset sul record del punto con RecNo,
//   mai con Locate: TzFbDataSet.UseSqlLocate ridurrebbe il dataset al solo record;
// - il grafico si registra in zOffice.Grafici con il suo identificativo e con
//   il nome di stampa: Word, FastReport ed Excel lo trovano come chart://Nome.

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
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
  cxClasses,
  cxTextEdit,
  cxLabel,
  cxImageList,
  cxBarEditItem,
  dxCore,
  dxCoreClasses,
  dxChartCore,
  dxChartControl,
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
  dxPSCore,
  zDbChart.Types,
  zDbChart.Builder,
  zOffice.Grafici;

type
  TzDbChartCommand = (gcUpdateActions, gcDisplayToolbars, gcSaveZip, gcApplyTitle, gcAfterOpen);

  // Le azioni del .dfm sono TzFocusedAction: con il fuoco nel grafico le
  // scorciatoie restano al grafico e non passano agli altri componenti della form
  TzDbChart = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzShortCutConsumer)
    ActionList: TActionList;
    DataSource: TDataSource;
    ChartSource: TDataSource;
    Chart: TdxChartControl;
    pnlDescrizione: TdxPanel;
    dxBarManager: TdxBarManager;
    dxBarToolbar: TdxBar;
    dxBarToolbarFree: TdxBar;
    popChart: TdxBarPopupMenu;
    // titolo a sinistra dei pulsanti, come in TzDbView e TzDbCard
    Titolo: TcxLabel;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
    dxBarEditTitolo: TcxBarEditItem;
    dxBarSubItemTipo: TdxBarSubItem;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    // Dati
    actDbRefresh: TzFocusedAction;
    Elabora: TzFocusedAction;
    // Tipo di grafico: Tag = ordinale di TzChartKind
    actTipoBarre: TzFocusedAction;
    actTipoBarreImpilate: TzFocusedAction;
    actTipoBarrePercentuali: TzFocusedAction;
    actTipoLinee: TzFocusedAction;
    actTipoLineeImpilate: TzFocusedAction;
    actTipoAree: TzFocusedAction;
    actTipoAreeImpilate: TzFocusedAction;
    actTipoTorta: TzFocusedAction;
    actTipoCiambella: TzFocusedAction;
    actTipoPredefinito: TzFocusedAction;
    // Vista
    actLegenda: TzFocusedAction;
    actEtichette: TzFocusedAction;
    actRipristinaZoom: TzFocusedAction;
    Descrizione: TzFocusedAction;
    RipristinaLayout: TzFocusedAction;
    // Uscite
    actEsporta: TdxFileSaveAs;
    actCopiaImmagine: TzFocusedAction;
    actStampa: TzFocusedAction;
    // Amministrazione
    actPersonalizza: TzFocusedAction;
    actResetSerie: TzFocusedAction;
    SalvaImpostazioni: TzFocusedAction;
    CaricaImpostazioni: TzFocusedAction;
    actSQL: TzFocusedAction;
    MostraQueryUtilizzata: TzFocusedAction;
    CopiaQueryUtilizzata: TzFocusedAction;
    CopyName: TzFocusedAction;
    NomeFileIni: TzFocusedAction;
    EditTools: TzFocusedAction;
    // Pulsanti della barra e dei menu
    dxBarButtonactDbRefresh: TdxBarButton;
    dxBarButtonElabora: TdxBarButton;
    dxBarButtonactTipoBarre: TdxBarButton;
    dxBarButtonactTipoBarreImpilate: TdxBarButton;
    dxBarButtonactTipoBarrePercentuali: TdxBarButton;
    dxBarButtonactTipoLinee: TdxBarButton;
    dxBarButtonactTipoLineeImpilate: TdxBarButton;
    dxBarButtonactTipoAree: TdxBarButton;
    dxBarButtonactTipoAreeImpilate: TdxBarButton;
    dxBarButtonactTipoTorta: TdxBarButton;
    dxBarButtonactTipoCiambella: TdxBarButton;
    dxBarButtonactTipoPredefinito: TdxBarButton;
    dxBarButtonactLegenda: TdxBarButton;
    dxBarButtonactEtichette: TdxBarButton;
    dxBarButtonactRipristinaZoom: TdxBarButton;
    dxBarButtonDescrizione: TdxBarButton;
    dxBarButtonRipristinaLayout: TdxBarButton;
    dxBarButtonactEsporta: TdxBarButton;
    dxBarButtonactCopiaImmagine: TdxBarButton;
    dxBarButtonactStampa: TdxBarButton;
    dxBarButtonactPersonalizza: TdxBarButton;
    dxBarButtonactResetSerie: TdxBarButton;
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
    procedure actDbRefreshExecute(Sender: TObject);
    procedure ElaboraExecute(Sender: TObject);
    procedure actTipoExecute(Sender: TObject);
    procedure actTipoPredefinitoExecute(Sender: TObject);
    procedure actLegendaExecute(Sender: TObject);
    procedure actEtichetteExecute(Sender: TObject);
    procedure actRipristinaZoomExecute(Sender: TObject);
    procedure DescrizioneExecute(Sender: TObject);
    procedure RipristinaLayoutExecute(Sender: TObject);
    procedure actEsportaBeforeExecute(Sender: TObject);
    procedure actEsportaAccept(Sender: TObject);
    procedure actCopiaImmagineExecute(Sender: TObject);
    procedure actStampaExecute(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure actResetSerieExecute(Sender: TObject);
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
    procedure PopupChartPopup(Sender: TObject);
  private
    FzDataSet: TzFbDataSet;
    FzSystem: TzSystem;
    FDataController: TzDataController;
    FzDbChartProps: TzDbChartProps;
    FToolActions: TzToolActions;
    FBuilder: TzChartBuilder;
    ActionListController: TActionListController;
    FrameDescription: TFrameDescription;
    FBuilt: Boolean;
    FLoadingProps: Boolean;
    FIsDestroying: Boolean;
    FSaveZipQueued: Boolean;
    // campo argomento effettivo (props oppure convenzione)
    FArgumentField: string;
    // scelte dell'utente, ricordate nel suo file .chart; gkChart = nessuna scelta
    FUserKind: TzChartKind;
    FShowLegend: Boolean;
    FShowLabels: Boolean;
    // titolo assegnato dalla form o dal FormController, usato se le props non ne hanno
    FRuntimeTitle: string;
    FPointCount: Integer;
    FOverLimit: Boolean;
    FLastState: TDataSetState;
    AlreadyShown: Boolean;
  private
    FOnUpdateActions: TNotifyEvent;
    FOnBeforeCreateControls: TNotifyEvent;
    FOnAfterCreateControls: TNotifyEvent;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    FOnPointDblClick: TzChartPointEvent;
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
    function GetChartID: string;
    procedure SetChartID(const Value: string);
    function GetFlags: TzDbChartFlags;
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: Boolean;
    function IsAdmin: Boolean;
    function EffectiveTitle: string;
    function CurrentKind: TzChartKind;
  private
    procedure InitChart;
    procedure ResolveArgumentField;
    function BuildSpec: TzChartSpec;
    procedure RebuildChart;
    procedure ApplyData;
    procedure RegisterForReports;
    procedure LoadProperties(const LoadDefaults: Boolean);
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
    procedure doSalvaImpostazioni(const Silent: Boolean = False);
    procedure CreateFiltersFromProps;
    procedure DisplayToolbars;
    procedure DisplayTitle;
    procedure UpdateActions;
    procedure OnFlagChange(Sender: TObject);
    procedure ToolActionsChanged(Sender: TObject);
    procedure ChartDblClick(Sender: TObject);
    procedure InitPrinter(Printer: TdxComponentPrinter);
  private // impostazioni personali
    function LayoutFileName: string;
    procedure LoadUserSettings;
    procedure SaveUserSettings;
  private // descrizione
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private
    procedure PostInternalMessage(const Command: TzDbChartCommand);
    procedure ExecuteCommand(const Command: TzDbChartCommand);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBCHART;
  protected
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateDataSet;
    // Rilegge le props dal dizionario e ricostruisce il grafico
    procedure ReloadProps;
    // Ricostruisce diagramma e serie dalle props correnti
    procedure Rebuild;

    // Tipo di tutte le serie scelto dall'utente; gkChart torna ai tipi delle props
    procedure SetKind(const Kind: TzChartKind);
    procedure ResetZoom;

    // Uscite. Width e Height 0 = misura a video
    procedure ExportToFile(const FileName: string; const Width: Integer = 0; const Height: Integer = 0);
    // Immagine in un flusso nuovo, che il chiamante libera
    function GetImageStream(const Format: TzFormatoGrafico; const Width: Integer = 0; const Height: Integer = 0): TStream;
    procedure CopyToClipboard;
    procedure Preview;

    // Punto sotto il mouse, in coordinate del grafico
    function PointAt(const X, Y: Integer; out Point: TzChartPoint): Boolean;

    function GetTitle: string;
    procedure SetTitle(const Title: string);

    procedure InitToolActions;
    procedure ExecuteToolConfig;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
  public
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property DataController: TzDataController read FDataController;
    property Builder: TzChartBuilder read FBuilder;
    property ChartID: string read GetChartID write SetChartID;
    property Flags: TzDbChartFlags read GetFlags;
    property zDbChartProps: TzDbChartProps read FzDbChartProps;
    // Campo dell'asse delle categorie effettivamente usato
    property ArgumentField: string read FArgumentField;
    // Record del dataset e superamento della soglia di punti
    property PointCount: Integer read FPointCount;
    property OverLimit: Boolean read FOverLimit;
  published
    property OnUpdateActions: TNotifyEvent read FOnUpdateActions write FOnUpdateActions;
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write FOnBeforeCreateControls;
    // A grafico ricostruito: personalizzazioni dell'aspetto da codice (Builder.Chart)
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write FOnAfterCreateControls;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write FOnCustomLoadProps;
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write FOnCustomSaveProps;
    // Doppio clic su un punto: Handled := True evita lo spostamento del dataset
    property OnPointDblClick: TzChartPointEvent read FOnPointDblClick write FOnPointDblClick;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  end;

implementation

uses
  System.IniFiles,
  Winapi.ShellAPI,
  Vcl.Clipbrd,
  zDX,
  zMsg,
  zFrmParams,
  zToolConfigDlg,
  zToolFilter.Builder;

{$R *.dfm}

const
  // oltre questa soglia le linee perdono i segni sui punti: con tanti punti
  // pesano nel disegno e il doppio clic su un singolo punto non serve piu'
  MaxPuntiConSegni = 1000;
  SSezioneGrafico = 'Grafico';
  STroppiPunti = 'Troppi punti per questo tipo di grafico: %d record su un massimo di %d.' + sLineBreak +
    'Restringere i filtri, aggregare la query o scegliere le linee.';
  SNessunaSerie = 'Nessuna serie da mostrare: indicare i campi numerici in Personalizza.';

{ TzDbChart }

constructor TzDbChart.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FzDataSet := nil;
  FzSystem := nil;
  FrameDescription := nil;
  FBuilt := False;
  FLoadingProps := False;
  FIsDestroying := False;
  FSaveZipQueued := False;
  FArgumentField := '';
  FUserKind := gkChart;
  FShowLegend := True;
  FShowLabels := False;
  FRuntimeTitle := '';
  FPointCount := 0;
  FOverLimit := False;
  FLastState := dsInactive;
  AlreadyShown := False;

  FzDbChartProps := TzDbChartProps.Create(nil);
  FzDbChartProps.Flags.OnChange := OnFlagChange;

  FDataController := TzDataController.Create(Self);
  FBuilder := TzChartBuilder.Create(Chart);
  // a video il titolo sta nella barra; il motore lo disegna nel grafico solo
  // per immagini e stampe
  FBuilder.TitleOnScreen := False;

  Titolo.Visible := False;
  dxBarControlContainerTitolo.Visible := dx.Visible(False);
  Titolo.PopupMenu := popChart;
  dx.InitTitle(Titolo);

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;

  ActionListController := TActionListController.Create;

  dxBarToolbar.MultiLine := True;
  dxBarToolbarFree.MultiLine := True;

  // Tag delle azioni del tipo: l'ordinale del tipo, un solo gestore
  actTipoBarre.Tag := Ord(gkBar);
  actTipoBarreImpilate.Tag := Ord(gkStackedBar);
  actTipoBarrePercentuali.Tag := Ord(gkFullStackedBar);
  actTipoLinee.Tag := Ord(gkLine);
  actTipoLineeImpilate.Tag := Ord(gkStackedLine);
  actTipoAree.Tag := Ord(gkArea);
  actTipoAreeImpilate.Tag := Ord(gkStackedArea);
  actTipoTorta.Tag := Ord(gkPie);
  actTipoCiambella.Tag := Ord(gkDoughnut);

  Chart.OnDblClick := ChartDblClick;

  UpdateActions;
end;

destructor TzDbChart.Destroy;
begin
  FIsDestroying := True;

  // le stampe non devono piu' trovare questo grafico
  TzRegistroGrafici.Togli(Self);

  // scrittura dello zip rimasta in coda: il messaggio postato non verra' recapitato
  if FSaveZipQueued then
  begin
    FSaveZipQueued := False;
    if zSystemOk then
      zSystem.SaveZip(csDbCharts, 'TzDbChart.Destroy');
  end;

  // Mantis #200 - 2026-10-02: ChartSource e' nil se il costruttore e' fallito
  // durante la lettura del .dfm; senza il controllo questa riga copriva l'errore vero
  if Assigned(ChartSource) then
    ChartSource.DataSet := nil;

  FreeAndNil(FrameDescription);
  FreeAndNil(ActionListController);
  FreeAndNil(FToolActions);
  FreeAndNil(FBuilder);
  FreeAndNil(FDataController);
  FreeAndNil(FzDbChartProps);
  inherited;
end;

procedure TzDbChart.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation <> opRemove then
    Exit;

  if AComponent = FzSystem then
    FzSystem := nil;

  if AComponent = FzDataSet then
  begin
    FzDataSet := nil;
    if Assigned(ChartSource) then
      ChartSource.DataSet := nil;
    if Assigned(FDataController) then
      FDataController.DataSet := nil;
  end;

  if (AComponent is TAction) or (AComponent is TImageList) then
    if Assigned(FToolActions) then
      FToolActions.RemoveNotification(AComponent);
end;

procedure TzDbChart.CMShowingChanged(var M: TMessage);
begin
  inherited;
  AlreadyShown := True;
  PostInternalMessage(gcDisplayToolbars);
end;

procedure TzDbChart.PostInternalMessage(const Command: TzDbChartCommand);
begin
  if FIsDestroying or (csDestroying in ComponentState) then
    Exit;

  // Handle crea la finestra, e un frame senza genitore (creato dal
  // FormController e non ancora messo nel layout) solleverebbe "Control has
  // no parent window": in quel caso il comando si esegue subito
  if HandleAllocated or Assigned(Parent) then
    PostMessage(Self.Handle, ZZ_DBCHART, NativeUInt(Command), 0)
  else
    ExecuteCommand(Command);
end;

procedure TzDbChart.MessageHandler(var Message: TMessage);
begin
  ExecuteCommand(TzDbChartCommand(Message.WParam));
end;

procedure TzDbChart.ExecuteCommand(const Command: TzDbChartCommand);
begin
  if FIsDestroying then
    Exit;

  case Command of
    gcUpdateActions:
      UpdateActions;
    gcDisplayToolbars:
      DisplayToolbars;
    gcApplyTitle:
      begin
        DisplayTitle;
        if FBuilt then
          FBuilder.SetTitle(EffectiveTitle);
      end;
    gcAfterOpen:
      ApplyData;
    gcSaveZip:
      begin
        FSaveZipQueued := False;
        if zSystemOk then
          zSystem.SaveZip(csDbCharts, 'TzDbChart.SalvaImpostazioni');
      end;
  end;
end;

// ---------------------------------------------------------------------------
// IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
// ---------------------------------------------------------------------------

function TzDbChart.GetComponentType: TzComponentType;
begin
  result := ctChart;
end;

function TzDbChart.GetID: string;
begin
  result := ChartID;
end;

procedure TzDbChart.SetID(const Value: string);
begin
  ChartID := Value;
end;

function TzDbChart.GetToolActions: TzToolActions;
begin
  result := FToolActions;
end;

procedure TzDbChart.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

function TzDbChart.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, FzDbChartProps.ActionOwnerName);
end;

function TzDbChart.GetActionOwnerName: string;
begin
  result := FzDbChartProps.ActionOwnerName;
end;

procedure TzDbChart.SetActionOwnerName(const Value: string);
begin
  FzDbChartProps.ActionOwnerName := Value;
end;

procedure TzDbChart.RebuildActions;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

procedure TzDbChart.RebuildFilters;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

function TzDbChart.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := ChartID;
end;

procedure TzDbChart.RebuildToolbar;
begin
  // Prima i filtri, poi le azioni: i filtri precedono le azioni sulla barra
  CreateFiltersFromProps;
  InitToolActions;
end;

function TzDbChart.GetProps: TzBaseComponentProps;
begin
  result := FzDbChartProps;
end;

function TzDbChart.GetToolbar: TdxBar;
begin
  result := dxBarToolbarFree;
end;

function TzDbChart.GetzDataSet: TzFbDataSet;
begin
  result := FzDataSet;
end;

procedure TzDbChart.SetzDataSet(const Value: TzFbDataSet);
begin
  if FzDataSet = Value then
    Exit;

  if Assigned(FzDataSet) then
    FzDataSet.RemoveFreeNotification(Self);

  FzDataSet := Value;

  if Assigned(FzDataSet) then
    FzDataSet.FreeNotification(Self);

  FDataController.DataSet := Value;
  ChartSource.DataSet := nil;
  DataSource.DataSet := nil;

  // dataset diverso: il grafico va ricostruito da capo
  FBuilt := False;
  InitChart;
end;

function TzDbChart.GetToolFilters: TzToolFiltersProps;
begin
  result := FzDbChartProps.ToolFilters;
end;

procedure TzDbChart.SetToolFilters(const Value: TzToolFiltersProps);
begin
  FzDbChartProps.ToolFilters.Assign(Value);
end;

// ---------------------------------------------------------------------------
// Proprieta'
// ---------------------------------------------------------------------------

function TzDbChart.GetChartID: string;
begin
  if (FzDbChartProps.Name = '') and FDataController.DataSetOk then
    FzDbChartProps.Name := FDataController.IdDataSet;

  result := FzDbChartProps.Name;
end;

procedure TzDbChart.SetChartID(const Value: string);
begin
  FzDbChartProps.Name := Value;

  if FBuilt then
    RegisterForReports;
end;

function TzDbChart.GetFlags: TzDbChartFlags;
begin
  result := FzDbChartProps.Flags;
end;

procedure TzDbChart.SetzSystem(const Value: TzSystem);
begin
  if FzSystem = Value then
    Exit;

  FzSystem := Value;

  if Assigned(FzSystem) then
    FzSystem.FreeNotification(Self);

  InitChart;
end;

function TzDbChart.zSystemOk: Boolean;
begin
  result := Assigned(FzSystem);
end;

function TzDbChart.IsAdmin: Boolean;
begin
  result := zSystemOk and FzSystem.IsAdmin;
end;

function TzDbChart.EffectiveTitle: string;
begin
  result := Trim(FzDbChartProps.Title);

  if result = '' then
    result := Trim(FRuntimeTitle);
end;

function TzDbChart.CurrentKind: TzChartKind;
begin
  if FUserKind <> gkChart then
    result := FUserKind
  else
    result := FzDbChartProps.Kind.Resolve(gkBar);
end;

// ---------------------------------------------------------------------------
// Costruzione
// ---------------------------------------------------------------------------

procedure TzDbChart.InitChart;
begin
  if FBuilt then
    Exit;

  if csDesigning in ComponentState then
    Exit;

  if not zSystemOk then
    Exit;

  if not FDataController.DataSetOk then
    Exit;

  LoadProperties(True);
  ResolveArgumentField;
  LoadUserSettings;

  FBuilt := True;
  RebuildChart;
  RegisterForReports;

  // il grafico legge da ChartSource, che si aggancia solo dopo il conteggio
  DataSource.DataSet := FzDataSet;
  FLastState := DataSource.State;

  if FDataController.IsActive then
    PostInternalMessage(gcAfterOpen);
end;

procedure TzDbChart.ResolveArgumentField;
var
  Field: TField;
  i: Integer;
begin
  FArgumentField := Trim(FzDbChartProps.ArgumentField);

  if (FArgumentField <> '') and Assigned(FDataController.GetField(FArgumentField)) then
    Exit;

  // Convenzione: il primo campo visibile che non e' un valore (testo, data),
  // escluse le colonne di servizio; altrimenti il primo campo
  FArgumentField := '';

  for i := 0 to FDataController.Fields.Count - 1 do
  begin
    Field := FDataController.Fields[i];

    if Field.Visible and not TzChartSeriesItems.IsValueField(Field) and not TzChartSeriesItems.IsServiceField(Field.FieldName) then
    begin
      FArgumentField := Field.FieldName;
      Break;
    end;
  end;

  if (FArgumentField = '') and (FDataController.Fields.Count > 0) then
    FArgumentField := FDataController.Fields[0].FieldName;
end;

function TzDbChart.BuildSpec: TzChartSpec;
var
  Item: TzChartSeriesItem;
  Field: TField;
  ChartKind: TzChartKind;
  Kind: TzChartKind;
begin
  result.Init;
  result.Title := EffectiveTitle;
  result.ArgumentField := FArgumentField;
  result.AxisTitleX := FzDbChartProps.AxisTitleX;
  result.AxisTitleY := FzDbChartProps.AxisTitleY;
  result.Sort := FzDbChartProps.Sort;
  result.TopN := FzDbChartProps.TopN;
  result.TopNOthers := FzDbChartProps.TopNOthers;
  result.ShowLegend := FShowLegend;
  result.ShowLabels := FShowLabels;
  result.Crosshair := FzDbChartProps.Flags.Crosshair;
  result.AllowZoom := FzDbChartProps.Flags.AllowZoom;
  result.Markers := FPointCount <= MaxPuntiConSegni;

  ChartKind := FzDbChartProps.Kind.Resolve(gkBar);

  for Item in FzDbChartProps.Series do
  begin
    if not Item.Visible then
      Continue;

    if not FDataController.TryGetField(Item.Name, Field) then
      Continue;

    if FUserKind <> gkChart then
      Kind := FUserKind
    else
      Kind := Item.Kind.Resolve(ChartKind);

    result.AddSeries(Item.Name, Item.Caption, Kind);
  end;
end;

procedure TzDbChart.RebuildChart;
begin
  if not FBuilt then
    Exit;

  if Assigned(FOnBeforeCreateControls) then
    FOnBeforeCreateControls(Self);

  // sganciato durante la ricostruzione: il conteggio di ApplyData decide se
  // il nuovo tipo regge i punti prima che il controllo li legga
  ChartSource.DataSet := nil;
  FBuilder.Build(BuildSpec, ChartSource);
  DisplayTitle;

  if Assigned(FOnAfterCreateControls) then
    FOnAfterCreateControls(Self);

  ApplyData;
end;

procedure TzDbChart.ApplyData;
var
  Limite: Integer;
  Avviso: string;
begin
  if not FBuilt or FIsDestroying then
    Exit;

  Avviso := '';

  if not FDataController.IsActive then
  begin
    FPointCount := 0;
    FOverLimit := False;
    ChartSource.DataSet := nil;
  end
  else
  begin
    FPointCount := FzDataSet.RecordCount;
    Limite := FBuilder.Spec.MaxPoints(FzDbChartProps.MaxPoints);
    FOverLimit := FPointCount > Limite;

    if FOverLimit then
    begin
      ChartSource.DataSet := nil;
      Avviso := Format(STroppiPunti, [FPointCount, Limite]);
    end
    else
    begin
      FBuilder.SetMarkersVisible(FPointCount <= MaxPuntiConSegni);
      ChartSource.DataSet := FzDataSet;
      // Mantis #7245 - 2026-10-19: riaccende la sorgente spenta alla chiusura
      ChartSource.Enabled := True;
    end;
  end;

  if Length(FBuilder.Spec.Series) = 0 then
    Avviso := SNessunaSerie;

  FBuilder.SetMessage(Avviso);
  UpdateActions;
end;

procedure TzDbChart.RegisterForReports;
var
  Sorgente: TzSorgenteGrafico;
begin
  TzRegistroGrafici.Togli(Self);

  Sorgente := function(Formato: TzFormatoGrafico; Larghezza, Altezza: Integer): TStream
    begin
      result := nil;
      if FBuilt and not FIsDestroying then
        result := FBuilder.ImageStream(Formato, Larghezza, Altezza);
    end;

  TzRegistroGrafici.Registra(ChartID, Self, Sorgente);

  if Trim(FzDbChartProps.ReportName) <> '' then
    TzRegistroGrafici.Registra(FzDbChartProps.ReportName, Self, Sorgente);
end;

procedure TzDbChart.Rebuild;
begin
  RebuildChart;
end;

procedure TzDbChart.ReloadProps;
begin
  if not FBuilt then
    Exit;

  LoadProperties(True);
  ResolveArgumentField;
  RebuildChart;
  RegisterForReports;
end;

procedure TzDbChart.LoadProperties(const LoadDefaults: Boolean);
begin
  if csDesigning in ComponentState then
    Exit;

  FLoadingProps := True;
  try
    if LoadDefaults then
      InternalLoadProperties;

    LoadDescription;
    RebuildToolbar;
  finally
    FLoadingProps := False;
  end;

  UpdateActions;
end;

procedure TzDbChart.InternalLoadProperties;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzDbChartProps.Name = '' then
    FzDbChartProps.Name := ChartID;

  if FzDbChartProps.DataSet = '' then
    FzDbChartProps.DataSet := FDataController.IdDataSet;

  if Assigned(FOnCustomLoadProps) then
    FOnCustomLoadProps(Self)
  else
    if zSystemOk then
      FzDbChartProps.LoadFromBase;

  FzDbChartProps.Series.ValidateDataset(FDataController.zFbDataSet);
end;

procedure TzDbChart.InternalSaveProperties;
begin
  if Assigned(FOnCustomSaveProps) then
    FOnCustomSaveProps(Self)
  else
    if zSystemOk then
    begin
      // aggiornamento in memoria sincrono, scrittura dello zip differita e
      // coalescente come negli altri componenti
      FzDbChartProps.SaveToBase(False);

      if not FSaveZipQueued then
      begin
        FSaveZipQueued := True;
        PostInternalMessage(gcSaveZip);
      end;
    end;
end;

procedure TzDbChart.doSalvaImpostazioni(const Silent: Boolean = False);
begin
  if csDesigning in ComponentState then
    Exit;

  if not Silent then
    StartWait('Attendere...', True);
  try
    if FzDbChartProps.Name = '' then
      FzDbChartProps.Name := ChartID;

    if FzDbChartProps.DataSet = '' then
      FzDbChartProps.DataSet := FDataController.IdDataSet;

    InternalSaveProperties;
  finally
    if not Silent then
      StopWait;
  end;
end;

procedure TzDbChart.CreateFiltersFromProps;
begin
  TzToolFilterBuilder.Build(FzDbChartProps.ToolFilters, Self, dxBarManager, FzDataSet);
end;

procedure TzDbChart.InitToolActions;
begin
  TzActionBuilder.BuildFromProps(FzDbChartProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(dxBarToolbarFree, popChart, otOther);
  DisplayToolbars;
end;

function TzDbChart.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
begin
  // Scrive sui props persistiti, come gli altri componenti: il runtime
  // ToolActions e' rigenerato da InitToolActions. FromCode protegge l'azione
  // da codice dall'Assign del dizionario. ImageList non e' persistibile.
  result := nil;

  if not Assigned(Action) then
    Exit;

  result := FzDbChartProps.ToolActions.Find(Action.Name);
  if not Assigned(result) then
  begin
    result := FzDbChartProps.ToolActions.Add;
    result.Name := Action.Name;
  end;

  result.FromCode := True;
end;

procedure TzDbChart.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;

  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbChart.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

procedure TzDbChart.OnFlagChange(Sender: TObject);
begin
  // durante il caricamento delle props l'Assign dei flag scatta piu' volte
  if FLoadingProps or FIsDestroying then
    Exit;

  DisplayToolbars;
  UpdateActions;
end;

procedure TzDbChart.DisplayToolbars;
begin
  dxBarManager.BeginUpdate;
  try
    // ordine inverso di visualizzazione
    dxBarToolbarFree.Visible := Flags.Toolbar;
    dxBarToolbar.Visible := Flags.Toolbar;
    dxBarToolbar.UseRestSpace := not dxBarToolbarFree.Visible;
    DisplayTitle;
  finally
    dxBarManager.EndUpdate;
  end;
end;

procedure TzDbChart.DisplayTitle;
begin
  Titolo.Caption := EffectiveTitle;
  Titolo.Visible := (Titolo.Caption <> '') and Flags.Toolbar;
  dxBarControlContainerTitolo.Visible := dx.Visible(Titolo.Visible);

  if Titolo.Visible then
  begin
    Titolo.AutoSize := False;
    Titolo.AutoSize := True;
  end;
end;

procedure TzDbChart.UpdateActions;
var
  Tipo: TzChartKind;
  HasData: Boolean;
begin
  if (csDestroying in ComponentState) or FIsDestroying then
    Exit;

  Tipo := CurrentKind;
  HasData := FBuilt and FDataController.IsActive and not FOverLimit;

  ActionVisible(actDbRefresh, Flags.ButtonRefresh and FDataController.CanRefresh);
  ActionVisible(Elabora, Flags.Params);

  dxBarSubItemTipo.Visible := dx.Visible(Flags.ButtonKind);
  actTipoBarre.Checked := Tipo = gkBar;
  actTipoBarreImpilate.Checked := Tipo = gkStackedBar;
  actTipoBarrePercentuali.Checked := Tipo = gkFullStackedBar;
  actTipoLinee.Checked := Tipo = gkLine;
  actTipoLineeImpilate.Checked := Tipo = gkStackedLine;
  actTipoAree.Checked := Tipo = gkArea;
  actTipoAreeImpilate.Checked := Tipo = gkStackedArea;
  actTipoTorta.Checked := Tipo = gkPie;
  actTipoCiambella.Checked := Tipo = gkDoughnut;
  actTipoPredefinito.Enabled := FUserKind <> gkChart;

  ActionVisible(actLegenda, Flags.ButtonLegend);
  actLegenda.Checked := FShowLegend;
  ActionVisible(actEtichette, Flags.ButtonLabels);
  actEtichette.Checked := FShowLabels;
  ActionVisible(actRipristinaZoom, Flags.ButtonZoom and Flags.AllowZoom and (FBuilder.Family = gfXY));

  ActionVisible(actEsporta, Flags.ButtonExport);
  ActionVisible(actCopiaImmagine, Flags.ButtonExport);
  ActionVisible(actStampa, Flags.ButtonPrint);
  actEsporta.Enabled := HasData;
  actCopiaImmagine.Enabled := HasData;
  actStampa.Enabled := HasData;

  ActionVisible(actPersonalizza, IsAdmin);
  ActionVisible(actResetSerie, IsAdmin);
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

// ---------------------------------------------------------------------------
// Tipo, vista, punti
// ---------------------------------------------------------------------------

procedure TzDbChart.SetKind(const Kind: TzChartKind);
begin
  FUserKind := Kind;
  SaveUserSettings;

  // il cambio di tipo ricostruisce il diagramma: un tipo dell'altra famiglia
  // assegnato al volo chiude l'applicazione (fase 0, P14)
  RebuildChart;
end;

procedure TzDbChart.ResetZoom;
begin
  FBuilder.ResetZoom;
end;

function TzDbChart.PointAt(const X, Y: Integer; out Point: TzChartPoint): Boolean;
begin
  result := FBuilt and FBuilder.HitTest(X, Y, Point);
end;

procedure TzDbChart.ChartDblClick(Sender: TObject);
var
  Posizione: TPoint;
  Punto: TzChartPoint;
  Handled: Boolean;
begin
  Posizione := Chart.ScreenToClient(Mouse.CursorPos);

  if not PointAt(Posizione.X, Posizione.Y, Punto) then
    Exit;

  Handled := False;

  if Assigned(FOnPointDblClick) then
    FOnPointDblClick(Self, Punto, Handled);

  if Handled then
    Exit;

  // RecNo e non Locate: vedi l'intestazione della unit. La fetta "Altri"
  // delle prime N non ha un record dietro
  if FzDbChartProps.Flags.SyncDataSet and Punto.IsRecord and FDataController.IsActive then
    if Punto.RecordIndex < FzDataSet.RecordCount then
      FzDataSet.RecNo := Punto.RecordIndex + 1;
end;

// ---------------------------------------------------------------------------
// Uscite
// ---------------------------------------------------------------------------

procedure TzDbChart.InitPrinter(Printer: TdxComponentPrinter);
begin
  // spegne la clessidra di ExpressPrinting, come nelle altre stampe di zPack
  dx.InitPrinter(Printer);
end;

procedure TzDbChart.ExportToFile(const FileName: string; const Width, Height: Integer);
begin
  if SameText(ExtractFileExt(FileName), '.pdf') then
    FBuilder.ExportToPdf(FileName, InitPrinter)
  else
    FBuilder.ExportToFile(FileName, Width, Height);
end;

function TzDbChart.GetImageStream(const Format: TzFormatoGrafico; const Width, Height: Integer): TStream;
begin
  result := FBuilder.ImageStream(Format, Width, Height);
end;

procedure TzDbChart.CopyToClipboard;
begin
  FBuilder.CopyToClipboard;
end;

procedure TzDbChart.Preview;
begin
  FBuilder.Preview(InitPrinter);
end;

// ---------------------------------------------------------------------------
// Impostazioni personali: tipo scelto, legenda, etichette
// ---------------------------------------------------------------------------

function TzDbChart.LayoutFileName: string;
var
  SafeID: string;
  Carattere: Char;
begin
  result := '';

  if not zSystemOk or (ChartID = '') then
    Exit;

  // L'identificativo e' del tipo Modulo.DataSet: il punto resta nel nome
  // (ChangeFileExt lo scambierebbe per l'estensione); si tolgono solo i
  // caratteri non ammessi
  SafeID := '';
  for Carattere in ChartID do
    if CharInSet(Carattere, ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then
      SafeID := SafeID + '_'
    else
      SafeID := SafeID + Carattere;

  result := IncludeTrailingPathDelimiter(FzSystem.PersonalFolder) + SafeID + '.chart';
end;

procedure TzDbChart.LoadUserSettings;
var
  FileName: string;
  Ini: TMemIniFile;
begin
  FUserKind := gkChart;
  FShowLegend := FzDbChartProps.Flags.ShowLegend;
  FShowLabels := FzDbChartProps.Flags.ShowLabels;

  FileName := LayoutFileName;

  if (FileName = '') or not FileExists(FileName) then
    Exit;

  try
    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      FUserKind := TzChartKind.FromName(Ini.ReadString(SSezioneGrafico, 'Tipo', ''), gkChart);
      FShowLegend := Ini.ReadBool(SSezioneGrafico, 'Legenda', FShowLegend);
      FShowLabels := Ini.ReadBool(SSezioneGrafico, 'Etichette', FShowLabels);
    finally
      FreeAndNil(Ini);
    end;
  except
    // TEncoding.UTF8 solleva su byte non validi: valgono le impostazioni del dizionario
    on Exception do
      FUserKind := gkChart;
  end;
end;

procedure TzDbChart.SaveUserSettings;
var
  FileName: string;
  Ini: TMemIniFile;
begin
  FileName := LayoutFileName;

  if FileName = '' then
    Exit;

  try
    ForceDirectories(ExtractFilePath(FileName));

    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      Ini.EraseSection(SSezioneGrafico);
      if FUserKind <> gkChart then
        Ini.WriteString(SSezioneGrafico, 'Tipo', FUserKind.Name);
      Ini.WriteBool(SSezioneGrafico, 'Legenda', FShowLegend);
      Ini.WriteBool(SSezioneGrafico, 'Etichette', FShowLabels);
      Ini.UpdateFile;
    finally
      FreeAndNil(Ini);
    end;
  except
    // le impostazioni personali non devono bloccare il grafico
    on Exception do
      ;
  end;
end;

// ---------------------------------------------------------------------------
// Descrizione
// ---------------------------------------------------------------------------

procedure TzDbChart.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

procedure TzDbChart.LoadDescription;
begin
  if not Assigned(FrameDescription) then
    CreateDescription;

  FzDbChartProps.Description.LoadFromIni(ChartID);
  FrameDescription.zDescription := FzDbChartProps.Description;

  Descrizione.Checked := FrameDescription.zDescription.Visible;
end;

procedure TzDbChart.SaveDescription;
begin
  FzDbChartProps.Description.Assign(FrameDescription.zDescription);
  FzDbChartProps.Description.SaveToIni(ChartID);
  Descrizione.Checked := FzDbChartProps.Description.Visible;
end;

// ---------------------------------------------------------------------------
// Titolo
// ---------------------------------------------------------------------------

function TzDbChart.GetTitle: string;
begin
  result := EffectiveTitle;

  if result.IsEmpty then
  begin
    result := Name;
    if result.StartsWith('chart') then
      result := result.Replace('chart', '', [rfIgnoreCase]);
  end;
end;

procedure TzDbChart.SetTitle(const Title: string);
begin
  // A video il titolo sta nella barra; il motore lo disegna dentro il grafico
  // nelle immagini e nelle stampe. Quello delle props, se c'e', ha la precedenza
  FRuntimeTitle := Trim(Title);
  DisplayTitle;

  if FBuilt then
    FBuilder.SetTitle(EffectiveTitle);
end;

procedure TzDbChart.dxBarEditTitoloChange(Sender: TObject);
begin
  FzDbChartProps.Title := VarToStr(dxBarEditTitolo.EditValue);
  doSalvaImpostazioni;

  // il titolo si aggiorna dopo: durante OnChange la casella di testo della
  // barra e' ancora in modifica
  PostInternalMessage(gcApplyTitle);
end;

// ---------------------------------------------------------------------------
// Eventi del dataset
// ---------------------------------------------------------------------------

procedure TzDbChart.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  if FIsDestroying then
    Exit;

  PostInternalMessage(gcUpdateActions);
end;

procedure TzDbChart.DataSourceStateChange(Sender: TObject);
var
  NewState: TDataSetState;
begin
  if FIsDestroying then
    Exit;

  NewState := DataSource.State;

  // chiuso: il grafico si spegne, cosi' alla riapertura (filtri, Aggiorna)
  // non legge niente prima del conteggio; aperto: conteggio e aggancio in differita
  // Mantis #7245 - 2026-10-19: spenta, non sganciata. Questo gestore gira dentro
  // TDataSet.DataEvent, che scorre le sorgenti del dataset con il conteggio letto
  // all'inizio: togliere ChartSource dalla lista accorciava l'elenco sotto il ciclo
  // ("Indice dell'elenco non compreso nell'intervallo" alla chiusura del dataset)
  if NewState = dsInactive then
    ChartSource.Enabled := False
  else
    if FLastState = dsInactive then
      PostInternalMessage(gcAfterOpen);

  FLastState := NewState;
  PostInternalMessage(gcUpdateActions);
end;

procedure TzDbChart.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  // aggiornamento affidato a UpdateActions, chiamato dagli eventi
end;

// ---------------------------------------------------------------------------
// Azioni
// ---------------------------------------------------------------------------

procedure TzDbChart.ActivateDataSet;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FDataController.IsActive then
    Exit;

  if FDataController.AutoOpen then
    FDataController.OpenDataSet;
end;

procedure TzDbChart.actDbRefreshExecute(Sender: TObject);
begin
  actDbRefresh.Enabled := False;
  try
    FDataController.Refresh;
    // un aggiornamento senza riapertura puo' cambiare il numero dei record
    ApplyData;
  finally
    actDbRefresh.Enabled := True;
  end;
end;

procedure TzDbChart.ElaboraExecute(Sender: TObject);
begin
  ShowParams(ChartID + '_Params', zDataSet, 'Parametri', True);
end;

procedure TzDbChart.actTipoExecute(Sender: TObject);
begin
  if Sender is TComponent then
    SetKind(TzChartKind(TComponent(Sender).Tag));
end;

procedure TzDbChart.actTipoPredefinitoExecute(Sender: TObject);
begin
  SetKind(gkChart);
end;

procedure TzDbChart.actLegendaExecute(Sender: TObject);
begin
  FShowLegend := not FShowLegend;
  FBuilder.SetLegendVisible(FShowLegend);
  SaveUserSettings;
  UpdateActions;
end;

procedure TzDbChart.actEtichetteExecute(Sender: TObject);
begin
  FShowLabels := not FShowLabels;
  FBuilder.SetLabelsVisible(FShowLabels);
  SaveUserSettings;
  UpdateActions;
end;

procedure TzDbChart.actRipristinaZoomExecute(Sender: TObject);
begin
  ResetZoom;
end;

procedure TzDbChart.DescrizioneExecute(Sender: TObject);
begin
  if Descrizione.Checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzDbChart.RipristinaLayoutExecute(Sender: TObject);
var
  FileName: string;
begin
  if not ConfirmYesNo('Ripristinare tipo, legenda ed etichette predefiniti del grafico?') then
    Exit;

  FileName := LayoutFileName;
  if (FileName <> '') and FileExists(FileName) then
    System.SysUtils.DeleteFile(FileName);

  LoadUserSettings;
  RebuildChart;
end;

procedure TzDbChart.actEsportaBeforeExecute(Sender: TObject);
begin
  if (actEsporta.Dialog.InitialDir = '') and zSystemOk then
    actEsporta.Dialog.InitialDir := FzSystem.PersonalFolder;

  if actEsporta.Dialog.FileName = '' then
    actEsporta.Dialog.FileName := ChartID.Replace('.', '_');
end;

procedure TzDbChart.actEsportaAccept(Sender: TObject);
const
  Estensioni: array [1 .. 7] of string = ('.png', '.svg', '.pdf', '.xlsx', '.docx', '.emf', '.jpg');
var
  FileName: string;
  Indice: Integer;
begin
  FileName := actEsporta.Dialog.FileName;
  Indice := actEsporta.Dialog.FilterIndex;

  if (Indice < Low(Estensioni)) or (Indice > High(Estensioni)) then
    Indice := Low(Estensioni);

  FileName := ChangeFileExt(FileName, Estensioni[Indice]);

  // le immagini al doppio della misura a video restano nitide anche ingrandite
  if Indice in [1, 7] then
    ExportToFile(FileName, Chart.Width * 2, Chart.Height * 2)
  else
    ExportToFile(FileName);

  ShellExecute(0, PChar('open'), PChar(ExtractFilePath(FileName)), nil, nil, SW_RESTORE);
end;

procedure TzDbChart.actCopiaImmagineExecute(Sender: TObject);
begin
  CopyToClipboard;
end;

procedure TzDbChart.actStampaExecute(Sender: TObject);
begin
  Preview;
end;

procedure TzDbChart.actPersonalizzaExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  if FzDbChartProps.Inspect then
  begin
    LoadProperties(False);
    FzDbChartProps.Series.ValidateDataset(FDataController.zFbDataSet);
    ResolveArgumentField;
    RebuildChart;
    RegisterForReports;
    doSalvaImpostazioni(False);
  end;
end;

procedure TzDbChart.actResetSerieExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  if not ConfirmYesNo('Rigenerare le serie dai campi numerici del dataset?', mtWarning) then
    Exit;

  FzDbChartProps.Series.Reset(FDataController.zFbDataSet);
  RebuildChart;
end;

procedure TzDbChart.SalvaImpostazioniExecute(Sender: TObject);
begin
  doSalvaImpostazioni;
end;

procedure TzDbChart.CaricaImpostazioniExecute(Sender: TObject);
begin
  if ConfirmYesNo('Ricarico le impostazioni salvate?') then
    ReloadProps;
end;

procedure TzDbChart.actSQLExecute(Sender: TObject);
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzSystem.DataSetEditProps(zDataSet) then
  begin
    FDataController.OpenDataSet;
    FzDbChartProps.Series.ValidateDataset(FDataController.zFbDataSet);
    ResolveArgumentField;
    RebuildChart;
  end;
end;

procedure TzDbChart.MostraQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
    ConfirmOk(FDataController.GetDebugInfo);
end;

procedure TzDbChart.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
  begin
    Clipboard.AsText := FDataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbChart.CopyNameExecute(Sender: TObject);
begin
  Clipboard.AsText := ChartID;
  ConfirmOk(ChartID);
end;

procedure TzDbChart.NomeFileIniExecute(Sender: TObject);
begin
  Clipboard.AsText := LayoutFileName;
  ConfirmOk(LayoutFileName);
end;

procedure TzDbChart.EditToolsExecute(Sender: TObject);
begin
  ExecuteToolConfig;
end;

procedure TzDbChart.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

procedure TzDbChart.dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
begin
  if IsAdmin then
    popChart.PopupFromCursorPos;
end;

procedure TzDbChart.PopupChartPopup(Sender: TObject);
var
  Nomi: string;
begin
  dxBarSubItemImpostazioni.Visible := dx.Visible(IsAdmin);
  dxBarEditTitolo.Visible := dx.Visible(IsAdmin);
  CopyName.Caption := 'Copia ChartID - ' + ChartID;

  // nei modelli di stampa il grafico si richiama con questo riferimento
  Nomi := TzRegistroGrafici.Schema + ChartID;
  if Trim(FzDbChartProps.ReportName) <> '' then
    Nomi := TzRegistroGrafici.Schema + Trim(FzDbChartProps.ReportName);
  NomeFileIni.Hint := 'Nei modelli di stampa: ' + Nomi;

  dxBarEditTitolo.OnChange := nil;
  try
    dxBarEditTitolo.EditValue := FzDbChartProps.Title;
  finally
    dxBarEditTitolo.OnChange := dxBarEditTitoloChange;
  end;
end;

end.
