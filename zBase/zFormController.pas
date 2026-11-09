unit zFormController;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Messaging,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Generics.Collections,
  Generics.Defaults,
  dxLayoutCommon,
  dxLayoutControl,
  dxLayoutContainer,
  dxLayoutLookAndFeels,
  zSystem,
  zFbDataSet,
  zDbView,
  zDbCard,
  zDbPivot,
  zDbRecordView,
  zDbTree,
  zDbChart,
  zDbScheduler,
  zFileViewer,
  zTreeMenu,
  zOffice.MultiViewer,
  zLayoutMaintenance,
  zLayouts,
  // zGoogleMaps,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzFormController = class;
  TLayoutController = class;

  TzLayoutMaintenanceOp = (lmoNone, lmoReset, lmoRepair);

  TAfterCreateComponentEvent = procedure(zFormController: TzFormController; LayoutController: TLayoutController; const DataSetName: String; Component: TComponent) of object;
  TBeforeDestroyComponentEvent = procedure(zFormController: TzFormController; LayoutController: TLayoutController; Component: TComponent) of object;
  TDatasetAssignedEvent = procedure(zFormController: TzFormController; const DataSetName: String; Component: TComponent) of object;

  TLayoutController = class(TObject, IInterface, IzLayoutMaintenance)
  private
    FdxLayoutControl: TdxLayoutControl;
    Comps: TList<TComponent>;
    dictLayoutItems: TDictionary<TdxLayoutItem, TzDiagramDataSet.TzDiagramCtrl>;
    dictMenu: TDictionary<string, TdxLayoutGroup>;
    dictDataSetGroups: TDictionary<TdxLayoutGroup, TzDiagramDataSet>;

    FIsDestroying: boolean;
    property IsDestroying: boolean read FIsDestroying;
  private
    // IInterface: nessun reference counting, il ciclo di vita e' del TzFormController
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  private
    // Manutenzione layout (IzLayoutMaintenance)
    FPendingMaintenanceOp: TzLayoutMaintenanceOp;
    procedure ExecutePendingMaintenance;
    procedure DoResetLayout;
    procedure DoRepairLayout;
    procedure RepairLayoutProps(zLayout: TzLayout);
    // Riporta al padre canonico i gruppi dei dataset che il layout salvato
    // tiene nel contenitore di un vecchio master; restituisce quanti ne sposta.
    function RepairDataSetGroupParents(zLayout: TzLayout): Integer;
    procedure ReorderDataSetGroups;
    procedure CollectGeneratedItemNames(Names: TDictionary<string, boolean>);
    function DataModuleGroupName: string;
  private
    FImages: TCustomImageList;
    procedure SetImages(const Value: TCustomImageList);
  private
    function GetLayoutProps: TzLayout;
    procedure OnCustomization(Sender: TObject);
    procedure LayoutItemRemoved(CustomLayoutItem: TdxCustomLayoutItem);
    function IsInsidePageControl(CustomItem: TdxCustomLayoutItem): boolean;
  private
    FSkipSelectFirstNode: boolean;
    FTabChangedProc: TProc<TdxLayoutGroup>;
    FTabChangingProc: TFunc<TdxLayoutGroup, Integer, boolean>;
  private
    FTreeMenu: TzTreeMenu;
    procedure CreateTreeMenu;
    // procedure LoadTreeMenu;
    procedure TreeSelected(Sender: TObject);
    procedure TreeWidthChanged(Sender: TObject; const NewWidth: Integer);
  private
    procedure EnableGoogleMapsHooks;
    procedure DisableGoogleMapsHooks;
  private
    procedure doAfterCreateComponent(const DataSetName: String; Component: TComponent);
  private
    function ItemName(const name: string): string;
    function GroupName(const name: string): string;
    function SplitterName(const name: string): string;
    function UniqueItemName(const name: string): string;
    function UniqueGroupName(const name: string): string;
    function UniqueSplitterName(const name: string): string;
    function UniqueLayoutItemName(const name: string): string;
  public
    FormController: TzFormController;
    procedure InitLayoutGroups;

    function CreateLayoutGroup(ParentGroup: TdxLayoutGroup; const aName: string = ''; LayoutDirection: TdxLayoutDirection = ldHorizontal; const Caption: TCaption = ''; Visible: boolean = True; const ShowBorder: boolean = False): TdxLayoutGroup;
    function CreateLayoutItem(Group: TdxLayoutGroup; Control: TControl; const aName: string = ''; const Caption: TCaption = ''; const ShowCaption: boolean = True; const CaptionLayout: TdxCaptionLayout = clLeft; const Visible: boolean = True;
      const AlignHorz: TdxLayoutAlignHorz = ahClient; const AlignVert: TdxLayoutAlignVert = avClient; const ShowBorder: boolean = False): TdxLayoutItem;
    function CreateSplitter(Group: TdxLayoutGroup; const aName: string): TdxLayoutSplitterItem;
  private
    procedure InitControl(Control: TControl);
    function CreateDbView(zFbDataSet: TzFbDataSet; view: TzDiagramDataSet.TDbView): TzDbView;
    function CreateDbCard(zFbDataSet: TzFbDataSet; card: TzDiagramDataSet.TDbCard): TzDbCard;
    function CreateDbPivot(zFbDataSet: TzFbDataSet; pivot: TzDiagramDataSet.TDbPivot): TzDbPivot;
    function CreateDbRecordView(zFbDataSet: TzFbDataSet; RecordView: TzDiagramDataSet.TDbRecordView): TzDbRecordView;
    function CreateDbTree(zFbDataSet: TzFbDataSet; Tree: TzDiagramDataSet.TDbTree): TzDbTree;
    function CreateDbChart(zFbDataSet: TzFbDataSet; DbChart: TzDiagramDataSet.TDbChart): TzDbChart;
    function CreateDbScheduler(zFbDataSet: TzFbDataSet; DbScheduler: TzDiagramDataSet.TDbScheduler): TzDbScheduler;
    function CreateFileViewer(zFbDataSet: TzFbDataSet; pdf: TzDiagramDataSet.TDbFile): TzFileViewer;
    function CreateViewerFrame(zFbDataSet: TzFbDataSet; pdf: TzDiagramDataSet.TDbFile): TzMultiViewer;

    // function CreateTatukMap(zFbDataSet: TzFbDataSet; map: TzDiagramDataSet.TGisMap): TzTatukViewer;
  private
    SkipOpenDataSet: boolean;
    CreatingControls: boolean;

    procedure CreateLayoutControl;
    procedure CreateLayoutStructure;
    procedure CreateItemControls(CustomItem: TdxCustomLayoutItem; ActivateDataSets: boolean = True);

    procedure OpenActiveDataSets(CustomItem: TdxCustomLayoutItem);
    procedure TabChanging(Sender: TObject; ANewTabIndex: Integer; var Allow: boolean);
    procedure TabChanged(Sender: TObject);
  private
    function GetSelectedDataSet: TzDiagramDataSet;
    function GetSelectedDataSetName: string;
    procedure SetSelectedDataSetName(const Value: string);
  private
    procedure InternalLoadFromIni;
    procedure InternalLoadProps;
    procedure ScaleLayoutToMonitor;
    procedure CheckControlDimensions;
    // Mantis #155 - 2026-09-22: distingue un gruppo davvero reso a video da uno
    // mai popolato, la cui dimensione non va ne' salvata ne' riletta.
    function HasRenderedContent(CustomItem: TdxCustomLayoutItem): boolean;
    function IsSizePlausible(CustomItem: TdxCustomLayoutItem; Size: Integer): boolean;
    // Risoluzione per form 2026-09-22: monitor su cui la form si trova ora, e
    // base rispetto a cui scalare le dimensioni lette dall'LZ.
    function CurrentMonitor: TMonitor;
    procedure GetDesignResolution(out BaseWidth, BaseHeight: Integer);
  private // AutoFitHeight delle card: gruppo dei dettagli adattato (vedi CardAutoFitHeight)
    type
      TAutoFitDettagli = record
        Gruppo: TdxLayoutGroup; // gruppo che ha l'altezza: <ds>Details sotto, o <ds>Controls stesso
        Segno: Integer; // +1 = Gruppo e' <ds>Controls (cresce con la card), -1 = <ds>Details (cala)
        AltezzaUtente: Integer; // SizeOptions.Height scelta dall'utente (divisore, .layout)
        AltezzaApplicata: Integer; // SizeOptions.Height dopo l'ultimo adattamento, -1 = da riprendere
        Attivo: boolean; // dettagli all'altezza adattata: la card e' visibile
        Sospeso: boolean; // divisore mosso con la card visibile: non si adatta piu'
      end;
  private
    dictAutoFit: TDictionary<TzDbCard, TAutoFitDettagli>;
    procedure CardAutoFitHeight(Sender: TzDbCard; const Altezza: Integer; const Mostrata: boolean);
    function FindAutoFitGruppo(Card: TzDbCard; out Segno: Integer): TdxLayoutGroup;
    procedure RiarmaAutoFit(const NuovaAltezzaUtente: boolean);
    function AltezzaDaSalvare(CustomItem: TdxCustomLayoutItem): Integer;
  protected
    procedure Translated;
    procedure TranslateGroupCaptions;
  public
    constructor Create(aFormController: TzFormController);
    destructor Destroy; override;
    //
    function AddControl(Control: TControl; Caption: string): TdxLayoutItem;
    //
    function IsControlVisible(Control: TControl): boolean;
    function IsContainerReady: boolean;

    function FindCustomItem(const ItemName: string): TdxCustomLayoutItem;
    function FindItem(const ItemName: string): TdxLayoutItem;
    function FindGroup(const GroupName: string): TdxLayoutGroup;

    procedure MakeVisible(const name: string); overload;
    procedure MakeVisible(Control: TControl); overload;
    //
    procedure Customize;
    procedure CreateControls;
    procedure DestroyControls;
    function GetComponent<T>(const DataSetName: string): T;
    //
    function IniFileName: string;
    procedure LoadFromIni;
    procedure SaveToIni;
    //
    procedure LoadProps;
    procedure SaveProps(const SaveDataModule: boolean = True);

    procedure ClearPersistedLayout;
    procedure ResetLayout;
    procedure RepairLayout;
    function CanMaintainLayout: boolean;
    procedure ResetItemSize;
    procedure Pack;
    property SelectedDataSetName: string read GetSelectedDataSetName write SetSelectedDataSetName;
    property SelectedDataSet: TzDiagramDataSet read GetSelectedDataSet;
  public
    procedure LoadTreeMenu;
  public
    property dxLayoutControl: TdxLayoutControl read FdxLayoutControl;
    property Images: TCustomImageList read FImages write SetImages;
    property TreeMenu: TzTreeMenu read FTreeMenu;
    property SkipSelectFirstNode: boolean read FSkipSelectFirstNode write FSkipSelectFirstNode;
  public
    property TabChangingProc: TFunc<TdxLayoutGroup, Integer, boolean> read FTabChangingProc write FTabChangingProc;
    property TabChangedProc: TProc<TdxLayoutGroup> read FTabChangedProc write FTabChangedProc;
  end;

  TzFormController = class(TComponent)
  private
    FDataModule: IzDataModule;
    FCtrlOwner: TComponent;
    FCtrlParent: TWinControl;
    FzDataModule: TzDataModule;
    FzSystem: TzSystem;
    FLayoutController: TLayoutController;
    FOnSelect: TNotifyEvent;
    FDesignWidth: Integer;
    FDesignHeight: Integer;
  private
    function GetDataSet(zDiagramDataSet: TzDiagramDataSet): TzFbDataSet;
    procedure ActivateDataSet(zDiagramDataSet: TzDiagramDataSet);
  private
    IsDestroying: boolean;
  private
    FImages: TCustomImageList;
    FOnAfterCreateComponent: TAfterCreateComponentEvent;
    FOnDatasetAssigned: TDatasetAssignedEvent;
    FonAfterCreateControls: TNotifyEvent;
    FonAfterLayoutControlLoadProps: TNotifyEvent;
    FOnBeforeDestroyComponent: TBeforeDestroyComponentEvent;
    FOnBeforeDisplayItem: TBeforeDisplayItem;
    FSkipSelectFirstNode: boolean;
    procedure doAfterCreateComponent(LayoutController: TLayoutController; const DataSetName: String; Component: TComponent);
    procedure doDatasetAssigned(const DataSetName: String; Component: TComponent);

    procedure doBeforeDestroyComponent(LayoutController: TLayoutController; Component: TComponent);
    function GetSelectedDataSet: TzDiagramDataSet;
    function GetSelectedDataSetName: string;
    procedure SetSelectedDataSetName(const Value: string);
    procedure doSelect;
    procedure SetOnBeforeDisplayItem(const Value: TBeforeDisplayItem);
    procedure doAfterCreateControls;
    procedure doAfterLayoutControlLoadProps;
    procedure SetImages(const Value: TCustomImageList);
    procedure SetSkipSelectFirstNode(const Value: boolean);
  protected
    procedure Translated;
  private
    TimerCheckControlDimensions: TTimer;
    procedure TimerCheckControlDimensionsTimer(Sender: TObject);

    procedure CheckControlDimensions;
    function IsContainerReady: boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateControls;
    procedure DestroyControls;

    function GetComponent<T: TComponent>(const DataSetName: string): T;
    function GetDbView(const DataSetName: string): TzDbView;
    function GetDbCard(const DataSetName: string): TzDbCard;
    function GetDbRecordView(const DataSetName: string): TzDbRecordView;
    function GetDbTree(const DataSetName: string): TzDbTree;
    function GetDbChart(const DataSetName: string): TzDbChart;
    function GetDbScheduler(const DataSetName: string): TzDbScheduler;
    // function GetDbCube(const DataSetName: string): TzCube;
    // function GetFileViewer(const DataSetName: string): TzFileViewer;
    // function GetTatukMap(const DataSetName: string): TzTatukViewer;
  public
    procedure CustomizeLayout;
    procedure ResetLayout;
    procedure ResetItemSize;
    function DumpItemSize(const ClientWidth, ClientHeight: Integer): String;

    function GetCtrlOwner: TComponent;
    function GetCtrlParent: TWinControl;

    procedure LoadFromIni;
    procedure SaveToIni;
    procedure SaveProps;
    property SelectedDataSetName: string read GetSelectedDataSetName write SetSelectedDataSetName;
    property SelectedDataSet: TzDiagramDataSet read GetSelectedDataSet;
  public
    procedure AfterShow;
    procedure AfterResize;
  public
    property LayoutController: TLayoutController read FLayoutController;
    property DataModule: IzDataModule read FDataModule write FDataModule;
    property zDataModule: TzDataModule read FzDataModule write FzDataModule;
    property zSystem: TzSystem read FzSystem write FzSystem;
    property CtrlOwner: TComponent read FCtrlOwner write FCtrlOwner;
    property CtrlParent: TWinControl read FCtrlParent write FCtrlParent;
    property Images: TCustomImageList read FImages write SetImages;
    property DesignWidth: Integer read FDesignWidth write FDesignWidth default 1920;
    property DesignHeight: Integer read FDesignHeight write FDesignHeight default 1200;
  public
    property SkipSelectFirstNode: boolean read FSkipSelectFirstNode write SetSkipSelectFirstNode;
    property onAfterCreateControls: TNotifyEvent read FonAfterCreateControls write FonAfterCreateControls;
    property OnAfterCreateComponent: TAfterCreateComponentEvent read FOnAfterCreateComponent write FOnAfterCreateComponent;
    property OnAfterLayoutControlLoadProps: TNotifyEvent read FonAfterLayoutControlLoadProps write FonAfterLayoutControlLoadProps;
    property OnDatasetAssigned: TDatasetAssignedEvent read FOnDatasetAssigned write FOnDatasetAssigned;

    property OnBeforeDestroyComponent: TBeforeDestroyComponentEvent read FOnBeforeDestroyComponent write FOnBeforeDestroyComponent;
    property OnBeforeDisplayItem: TBeforeDisplayItem read FOnBeforeDisplayItem write SetOnBeforeDisplayItem;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
  end;

const
  UseMultiViewer: boolean = False;

// Risoluzione per form 2026-09-22 (passo 2): elenco in sola lettura delle
// form dell'LZ e della risoluzione con cui sono state redatte, con evidenza
// di quelle che deviano dal riferimento.
//
// Serve perche' su una postazione multi-monitor il salvataggio puo' avvenire
// da uno schermo qualunque, e dall'LZ non c'e' nessun altro modo di sapere
// quali form ne sono state toccate: l'errore che ne deriva e' silenzioso.
//
// Non modifica niente. Si invoca passando zSystem.zDataModules, per esempio
// da una voce di diagnostica o dal registro:
//   Memo.Text := LayoutDesignResolutionReport(Config.zSystem.zDataModules, 1920, 1200);
function LayoutDesignResolutionReport(zDataModules: TzDataModules; const RefWidth, RefHeight: Integer): string;

implementation

uses
  System.Diagnostics,
  zDiagnostica.Log.Perf,
  System.Threading,
  System.UITypes,
  System.IniFiles,
  System.Math,
  Vcl.Dialogs,
  Vcl.Graphics,
  cxGraphics,
  zDx,
  zDxLayoutCustomizeFrm,
  cxPC,
  zBaseLib,
  zRestrictions.Types,
  zLocalizer,
  zLocalizer.Utils;

{ TLayoutController }

var
  SiFormController: TSiSession;

  // Sotto questa soglia (px logici) una dimensione salvata non e' plausibile:
  // valori come 1 o 2 derivano da un salvataggio eseguito prima del render
  // (ViewInfo non pronto) e mandano in loop il re-layout di DevExpress,
  // bloccando l'applicazione. Vengono quindi ignorati.
const
  MIN_VALID_SIZE = 20;

  // Mantis #155 - 2026-09-22: soglia di plausibilita' per i GRUPPI. Un gruppo
  // che ospita una griglia o un pannello di dettaglio non e' mai largo o alto
  // meno di questo: sotto, e' la dimensione della sola intestazione, salvata
  // dal distruttore quando il dettaglio non era mai stato aperto.
  // Il valore separa con ampio margine le due popolazioni misurate sui file
  // del cliente: da 20 a 28 i gruppi degeneri, da 92 a 696 quelli sani.
  // Coincide col minimo di best fit gia' usato da TzTreeMenu.
  MIN_VALID_GROUP_SIZE = 50;

  // Risoluzione per form 2026-09-22: sotto queste soglie un valore registrato
  // non descrive nessun monitor reale, quindi si ignora e si ricade sulle
  // costanti DesignWidth/DesignHeight. Protegge dal riscalamento abnorme che
  // nascerebbe da un rapporto calcolato su una base senza senso.
  MIN_VALID_MONITOR_WIDTH = 640;
  MIN_VALID_MONITOR_HEIGHT = 480;

type
  TdxCustomLayoutItemAccess = class(TdxCustomLayoutItem);
  TdxLayoutControlAccess = class(TdxLayoutControl);

  THackDxLayoutTabbedOptions = class(TdxLayoutTabbedOptions);

constructor TLayoutController.Create(aFormController: TzFormController);
begin
  SiFormController.EnterMethod(Self, 'Create');
  inherited Create;

  assert(assigned(aFormController));
  FormController := aFormController;
  FIsDestroying := False;
  SkipOpenDataSet := False;
  CreatingControls := False;
  FdxLayoutControl := nil;
  FTreeMenu := nil;
  FSkipSelectFirstNode := False;
  FTabChangedProc := nil;
  FTabChangingProc := nil;
  FPendingMaintenanceOp := lmoNone;

  Comps := TList<TComponent>.Create;
  dictLayoutItems := TDictionary<TdxLayoutItem, TzDiagramDataSet.TzDiagramCtrl>.Create;
  dictMenu := TDictionary<string, TdxLayoutGroup>.Create;
  dictDataSetGroups := TDictionary<TdxLayoutGroup, TzDiagramDataSet>.Create;
  dictAutoFit := TDictionary<TzDbCard, TAutoFitDettagli>.Create;

  SiFormController.LeaveMethod(Self, 'Create');
end;

destructor TLayoutController.Destroy;
begin
  SiFormController.EnterMethod('TLayoutController.Destroy');
  FIsDestroying := True;

  TThread.RemoveQueuedEvents(ExecutePendingMaintenance);
  if assigned(FdxLayoutControl) then
    TzLayoutMaintenanceRegistry.UnregisterHandler(FdxLayoutControl);

  FreeAndNil(FTreeMenu);
  FreeAndNil(Comps);
  FreeAndNil(dictLayoutItems);
  FreeAndNil(dictMenu);
  FreeAndNil(dictDataSetGroups);
  // Le card che si nascondono mentre il layout si libera chiamano ancora
  // CardAutoFitHeight: esce per IsDestroying prima di toccare il dizionario
  FreeAndNil(dictAutoFit);
  FreeAndNil(FdxLayoutControl);
  inherited;
  SiFormController.LeaveMethod('TLayoutController.Destroy');
end;

function TLayoutController.AddControl(Control: TControl; Caption: string): TdxLayoutItem;
begin
  result := nil;

  if not assigned(dxLayoutControl) then
    Exit;

  if not assigned(Control) then
    Exit;

  result := dxLayoutControl.FindItem(ItemName(Control.name)) as TdxLayoutItem;
  if not assigned(result) then
  begin
    // result := dxLayoutControl.CreateItemForControl(Control);
    // result := TdxLayoutItem(dxLayoutControl.CreateItem(TzDxLayoutItem, nil));
    // ZZ 28.07.2017: se TzDxLayoutItem imposter GeneratedByController a true ==> non verr salvato nell'lz
    result := TdxLayoutItem(dxLayoutControl.CreateItem(TdxLayoutItem, nil));
    result.Control := Control;
    result.name := UniqueItemName(Control.name);
    result.Caption := Control.name;
    result.CaptionOptions.Text := Caption;
    result.CaptionOptions.Visible := Caption <> '';
    result.AlignHorz := ahClient;
    result.AlignVert := avTop;
    result.ControlOptions.ShowBorder := False;
  end
  else
    result.Control := Control;
end;

procedure TLayoutController.InitControl(Control: TControl);
const
  w = 400;
  h = 200;
begin
  assert(assigned(Control));

  Control.Visible := False;
  Control.align := TAlign.alNone;
  Control.Width := w;
  Control.height := h;
  // dimensioni w:h
  // posizione => fuori dallo schermo per evitare lo sfarfallio
  Control.SetBounds(-w, -h, +w, +h);
  // Control.Parent := FormController.GetCtrlParent;
end;

function TLayoutController.CreateDbView(zFbDataSet: TzFbDataSet; view: TzDiagramDataSet.TDbView): TzDbView;
var
  i: Integer;
  zDbViewProps: TzDbViewProps;
begin
  result := FormController.GetCtrlOwner.FindComponent(view.ComponentName) as TzDbView;
  if assigned(result) then
    Exit;

  result := TzDbView.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  InitControl(result);
  result.name := view.ComponentName;
  //
  result.zSystem := FormController.zSystem;
  result.zDataSet := zFbDataSet;
  result.CardID := view.GetCardID;
  result.ViewID := view.GetViewID;
  /// ////
  zDbViewProps := result.GetDbViewProps;
  zDbViewProps.Flags.Border := FormController.zDataModule.ControllerOptions.UsePageControl;
  zDbViewProps.Columns.Reset(zFbDataSet);
  result.ReloadColumnProps;
  // ///
  result.RestrictionReadOnly := view.zDiagramDataSet.ActualAccessLevel <> alFull;
  result.SetTitle(view.Caption); // !!
  doAfterCreateComponent(view.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateDbCard(zFbDataSet: TzFbDataSet; card: TzDiagramDataSet.TDbCard): TzDbCard;
begin
  result := FormController.GetCtrlOwner.FindComponent(card.ComponentName) as TzDbCard;
  if assigned(result) then
    Exit;

  result := TzDbCard.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := card.ComponentName;
  InitControl(result);
  result.zSystem := FormController.zSystem;
  result.zDataSet := zFbDataSet;
  result.CardID := card.GetCardID;
  result.SetTitle(card.Caption);
  result.RestrictionReadOnly := card.zDiagramDataSet.ActualAccessLevel <> alFull;
  // AutoFitHeight (dal dizionario LZ o dalla form): la card sta nel gruppo a
  // linguette del dataset e l'altezza la decide il gruppo dei dettagli
  result.OnAutoFitHeight := CardAutoFitHeight;
  doAfterCreateComponent(card.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateDbPivot(zFbDataSet: TzFbDataSet; pivot: TzDiagramDataSet.TDbPivot): TzDbPivot;
begin
  result := FormController.GetCtrlOwner.FindComponent(pivot.ComponentName) as TzDbPivot;
  if assigned(result) then
    Exit;

  result := TzDbPivot.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := pivot.ComponentName;
  InitControl(result);
  result.zSystem := FormController.zSystem;
  result.zDataSet := zFbDataSet;
  result.PivotID := pivot.GetPivotID;
  result.dxBarControlContainerTitolo.Visible := dx.Visible(True);
  result.Titolo.Caption := pivot.Caption; // !!
  result.Titolo.Visible := True;
  result.dxBarControlContainerTitolo.Visible := dx.Visible(True);
  doAfterCreateComponent(pivot.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateDbRecordView(zFbDataSet: TzFbDataSet; RecordView: TzDiagramDataSet.TDbRecordView): TzDbRecordView;
begin
  result := FormController.GetCtrlOwner.FindComponent(RecordView.ComponentName) as TzDbRecordView;
  if assigned(result) then
    Exit;

  result := TzDbRecordView.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := RecordView.ComponentName;
  InitControl(result);
  result.zSystem := FormController.zSystem;
  // L'identificativo va assegnato prima del dataset: SetzDataSet carica le props
  result.RecordViewID := RecordView.GetRecordViewID;
  result.zDataSet := zFbDataSet;
  result.RestrictionReadOnly := RecordView.zDiagramDataSet.ActualAccessLevel <> alFull;
  result.SetTitle(RecordView.Caption);
  doAfterCreateComponent(RecordView.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateDbTree(zFbDataSet: TzFbDataSet; Tree: TzDiagramDataSet.TDbTree): TzDbTree;
begin
  result := FormController.GetCtrlOwner.FindComponent(Tree.ComponentName) as TzDbTree;
  if assigned(result) then
    Exit;

  result := TzDbTree.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := Tree.ComponentName;
  InitControl(result);
  result.zSystem := FormController.zSystem;
  // L'identificativo va assegnato prima del dataset: SetzDataSet carica le props
  result.TreeID := Tree.GetTreeID;
  result.zDataSet := zFbDataSet;
  result.RestrictionReadOnly := Tree.zDiagramDataSet.ActualAccessLevel <> alFull;
  result.SetTitle(Tree.Caption);
  doAfterCreateComponent(Tree.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateDbChart(zFbDataSet: TzFbDataSet; DbChart: TzDiagramDataSet.TDbChart): TzDbChart;
begin
  result := FormController.GetCtrlOwner.FindComponent(DbChart.ComponentName) as TzDbChart;
  if assigned(result) then
    Exit;

  result := TzDbChart.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := DbChart.ComponentName;
  InitControl(result);
  result.zSystem := FormController.zSystem;
  // L'identificativo va assegnato prima del dataset: SetzDataSet carica le props
  result.ChartID := DbChart.GetChartID;
  result.zDataSet := zFbDataSet;
  // titolo del grafico quando le props non ne hanno uno
  result.SetTitle(DbChart.Caption);
  doAfterCreateComponent(DbChart.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateDbScheduler(zFbDataSet: TzFbDataSet; DbScheduler: TzDiagramDataSet.TDbScheduler): TzDbScheduler;
var
  Props: TzDbSchedulerProps;
  ResourceDataSet: string;
begin
  result := FormController.GetCtrlOwner.FindComponent(DbScheduler.ComponentName) as TzDbScheduler;
  if assigned(result) then
    Exit;

  result := TzDbScheduler.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := DbScheduler.ComponentName;
  InitControl(result);
  result.zSystem := FormController.zSystem;
  // L'identificativo va assegnato prima del dataset: SetzDataSet carica le props
  result.SchedulerID := DbScheduler.GetSchedulerID;
  result.zDataSet := zFbDataSet;
  result.RestrictionReadOnly := DbScheduler.zDiagramDataSet.ActualAccessLevel <> alFull;
  result.SetTitle(DbScheduler.Caption);

  // Risorse: un altro dataset dello stesso modulo dati, che il componente non
  // sa raggiungere da solo. Il nome si legge dalle props: qui il dataset degli
  // eventi di solito non e' ancora assegnato (lo assegna OpenActiveDataSets)
  ResourceDataSet := '';
  Props := DbScheduler.zDbSchedulerProps(False);
  if assigned(Props) then
    ResourceDataSet := Trim(Props.ResourceDataSet);
  if (ResourceDataSet <> '') and assigned(FormController.DataModule) then
  begin
    FormController.DataModule.ActivateDataSet(ResourceDataSet);
    result.zResourceDataSet := FormController.DataModule.GetDataSet(ResourceDataSet);
  end;

  doAfterCreateComponent(DbScheduler.zDiagramDataSet.name, result);
end;

function TLayoutController.CreateFileViewer(zFbDataSet: TzFbDataSet; pdf: TzDiagramDataSet.TDbFile): TzFileViewer;
begin
  result := FormController.GetCtrlOwner.FindComponent(pdf.ComponentName) as TzFileViewer;
  if assigned(result) then
    Exit;

  result := TzFileViewer.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := pdf.ComponentName;
  result.ID := pdf.GetID;
  InitControl(result);
  result.DataSet := zFbDataSet;
  result.FieldName := pdf.FieldName;
  result.FieldNameOID := pdf.FieldNameOID;
  doAfterCreateComponent(pdf.zDiagramDataSet.name, result);
end;

// function TLayoutController.CreateTatukMap(zFbDataSet: TzFbDataSet; map: TzDiagramDataSet.TGisMap): TzTatukViewer;
// begin
// result := FormController.GetCtrlOwner.FindComponent(map.ComponentName) as TzTatukViewer;
// if assigned(result) then
// Exit;
//
// result := TzTatukViewer.Create(FormController.GetCtrlOwner);
// Comps.Add(result);
// result.name := map.ComponentName;
// InitControl(result);
// result.MasterDataSet := zFbDataSet;
// doAfterCreateComponent(map.zDiagramDataSet.name, result);
// end;

procedure TLayoutController.CreateTreeMenu;
var
  grpTree: TdxLayoutGroup;
  item: TdxLayoutItem;
begin
  FreeAndNil(FTreeMenu);

  if not FormController.zDataModule.ControllerOptions.TreeMenuVisible then
    Exit;

  if not assigned(TreeMenu) then
  begin
    FTreeMenu := TzTreeMenu.Create(FormController.GetCtrlOwner);
    TreeMenu.name := 'TreeMenu';
    TreeMenu.Visible := False;
    TreeMenu.Parent := FormController.GetCtrlParent;
    TreeMenu.OnBeforeDisplayItem := FormController.OnBeforeDisplayItem;

    grpTree := CreateLayoutGroup(dxLayoutControl.Items, 'TreeMenu');
    grpTree.Caption := 'TreeMenu';
    grpTree.CaptionOptions.Visible := False;
    grpTree.ShowBorder := False; // True;
    grpTree.AlignHorz := ahLeft;
    CreateSplitter(dxLayoutControl.Items, 'TreeMenu').AlignHorz := ahLeft;

    item := CreateLayoutItem(grpTree, TreeMenu, 'TreeMenu');
    item.Caption := 'TreeMenu';
    item.CaptionOptions.Visible := False;
    item.ControlOptions.ShowBorder := False;
  end;

  TreeMenu.OnSelect := TreeSelected;
  TreeMenu.OnWidthChanged := TreeWidthChanged;
  TreeMenu.zDataModule := FormController.zDataModule;
  TreeMenu.zSystem := FormController.zSystem;
end;

function TLayoutController.CreateViewerFrame(zFbDataSet: TzFbDataSet; pdf: TzDiagramDataSet.TDbFile): TzMultiViewer;
begin
  result := FormController.GetCtrlOwner.FindComponent(pdf.ComponentName) as TzMultiViewer;
  if assigned(result) then
    Exit;

  result := TzMultiViewer.Create(FormController.GetCtrlOwner);
  Comps.Add(result);
  result.name := pdf.ComponentName;
  result.ID := pdf.GetID;
  InitControl(result);
  result.DataSet := zFbDataSet;
  result.FieldName := pdf.FieldName;
  result.FieldNameOID := pdf.FieldNameOID;
  result.AllowedFileTypes := pdf.FileTypes;
  doAfterCreateComponent(pdf.zDiagramDataSet.name, result);
end;

procedure TLayoutController.doAfterCreateComponent(const DataSetName: String; Component: TComponent);
begin
  FormController.doAfterCreateComponent(Self, DataSetName, Component);
end;

procedure TLayoutController.DisableGoogleMapsHooks;
var
  i: Integer;
  item: TdxLayoutItem;
begin
  // Passare ai nuovi componenti ?
  // for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
  // if dxLayoutControl.AbsoluteItems[i] is TdxLayoutItem then
  // begin
  // item := TdxLayoutItem(dxLayoutControl.AbsoluteItems[i]);
  //
  // if assigned(item.Control) then
  // if item.Control is TzGoogleMaps then
  // TzGoogleMaps(item.Control).DisableHook;
  // end;
end;

procedure TLayoutController.EnableGoogleMapsHooks;
var
  i: Integer;
  item: TdxLayoutItem;
begin
  // Passare ai nuovi componenti ?
  // for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
  // if dxLayoutControl.AbsoluteItems[i] is TdxLayoutItem then
  // begin
  // item := TdxLayoutItem(dxLayoutControl.AbsoluteItems[i]);
  //
  // if assigned(item.Control) then
  // if item.Control is TzGoogleMaps then
  // TzGoogleMaps(item.Control).EnableHook;
  // end;
end;

function TLayoutController.CreateLayoutGroup(ParentGroup: TdxLayoutGroup; const aName: string = ''; LayoutDirection: TdxLayoutDirection = ldHorizontal; const Caption: TCaption = ''; Visible: boolean = True; const ShowBorder: boolean = False)
  : TdxLayoutGroup;
begin
  // result := dxLayoutControl.CreateGroup(TdxLayoutGroup, nil) as TdxLayoutGroup;
  // classe variata per zSystem
  result := dxLayoutControl.CreateGroup(TzDxLayoutGroup, nil) as TdxLayoutGroup;
  if aName <> '' then
    result.name := UniqueGroupName(aName);

  // result.IsUserDefined := False;
  result.Parent := ParentGroup;
  result.Caption := Caption;
  result.CaptionOptions.Visible := False;
  result.Visible := Visible;
  result.LayoutDirection := LayoutDirection;
  result.AlignHorz := ahClient;
  result.AlignVert := avClient;
  result.TabbedOptions.Options := result.TabbedOptions.Options - [pcoRedrawOnResize, pcoAlwaysShowGoDialogButton] + [pcoGoDialog];

  // No, meglio l'effetto di default
  // THackDxLayoutTabbedOptions(result.TabbedOptions).Style := 9;
  // THackDxLayoutTabbedOptions(result.TabbedOptions).TabSlants.Kind := skCutCorner;
  // THackDxLayoutTabbedOptions(result.TabbedOptions).TabSlants.Positions := [spRight];

  if result.name <> GroupName('TreeMenu') then
  begin
    result.ShowBorder := (result.LayoutDirection = ldTabbed) and FormController.zDataModule.ControllerOptions.UsePageControl;

    if result.ShowBorder then
    begin
      result.TabbedOptions.HideTabs := False;
      result.TabbedOptions.ShowFrame := True;

      result.LayoutLookAndFeel := nil; // default
    end
    else
    begin
      result.TabbedOptions.HideTabs := True;
      result.TabbedOptions.ShowFrame := False;

      result.LayoutLookAndFeel := dx.LayoutLookAndFeelNoGroupBorder;
    end;
  end;
end;

function TLayoutController.CreateLayoutItem(Group: TdxLayoutGroup; Control: TControl; const aName: string = ''; const Caption: TCaption = ''; const ShowCaption: boolean = True; const CaptionLayout: TdxCaptionLayout = clLeft;
  const Visible: boolean = True; const AlignHorz: TdxLayoutAlignHorz = ahClient; const AlignVert: TdxLayoutAlignVert = avClient; const ShowBorder: boolean = False): TdxLayoutItem;
begin
  // result := TdxLayoutItem(dxLayoutControl.CreateItem(TdxLayoutItem, Group));
  // classe variata per zSystem
  result := TdxLayoutItem(dxLayoutControl.CreateItem(TzDxLayoutItem, Group));

  if aName <> '' then
    result.name := UniqueItemName(aName);

  // Result.IsUserDefined := False;
  result.Control := Control;
  result.Parent := Group;
  result.CaptionOptions.Layout := CaptionLayout;
  result.ShowCaption := ShowCaption;
  result.Caption := Caption;
  result.AlignHorz := AlignHorz;
  result.AlignVert := AlignVert;
  result.CaptionOptions.Visible := False;
  result.ControlOptions.AutoColor := True;
  result.ControlOptions.ShowBorder := ShowBorder;
  { TODO : Vedere }  // result.OnCaptionClick := EditEditorProps;
end;

function TLayoutController.CreateSplitter(Group: TdxLayoutGroup; const aName: string): TdxLayoutSplitterItem;
begin
  // result := Group.CreateItem(TdxLayoutSplitterItem) as TdxLayoutSplitterItem;
  // classe variata per zSystem
  result := Group.CreateItem(TzDxLayoutSplitterItem) as TdxLayoutSplitterItem;
  if aName <> '' then
    result.name := UniqueSplitterName(aName);

  result.Caption := result.name;
  result.CaptionOptions.Visible := False;
  result.Parent := Group;

  // Entrambi gli assi sempre espliciti: lungo la direzione del gruppo lo
  // splitter non deve mai essere "client" (prenderebbe lo spazio libero come
  // un item qualunque), sull'altro asse deve riempire il gruppo.
  // I chiamanti che vogliono ahRight/avBottom lo impostano dopo la creazione.
  if Group.LayoutDirection = ldHorizontal then
  begin
    result.AlignHorz := ahLeft;
    result.AlignVert := avClient;
  end
  else
  begin
    result.AlignHorz := ahClient;
    result.AlignVert := avTop;
  end;

  // Spessore fisso deciso dal look and feel: nessuna dimensione propria e
  // nessun ridimensionamento dall'editor di personalizzazione
  // (stessa impostazione usata a mano in frmRisorse.dfm per dxLayoutSplitterItemCP1).
  result.SizeOptions.AssignedValues := [sovSizableHorz, sovSizableVert];
  result.SizeOptions.SizableHorz := False;
  result.SizeOptions.SizableVert := False;
  result.SizeOptions.Width := 0;
  result.SizeOptions.Height := 0;

  result.Offsets.Top := 3;
  result.Offsets.Bottom := 3;
  result.Offsets.Left := 3;
  result.Offsets.Right := 3;
end;

procedure TLayoutController.Customize;
begin
  if assigned(dxLayoutControl) then
  begin
    DisableGoogleMapsHooks;
    dxLayoutControl.CustomizeFormClass := TzLayoutCustomizeForm;
    dxLayoutControl.Customization := True;
  end;
end;

procedure TLayoutController.DestroyControls;
var
  i: Integer;
  comp: TComponent;
begin
  SiFormController.EnterMethod(Self, 'DestroyControls');

  if not assigned(dxLayoutControl) then
    Exit;

  SkipOpenDataSet := True;
  try
    dictLayoutItems.Clear;
    dictMenu.Clear;
    dictDataSetGroups.Clear;
    dictAutoFit.Clear; // prima di liberare card e gruppi: le card nascoste non trovano piu' niente da ripristinare

    dxLayoutControl.BeginUpdate;
    try
      if assigned(TreeMenu) then
        TreeMenu.OnSelect := nil;

      FreeAndNil(FTreeMenu);

      // componenti creati dinamicamente
      if assigned(Comps) then
        for i := Comps.Count - 1 downto 0 do
        begin
          comp := Comps[i];
          FormController.doBeforeDestroyComponent(Self, comp);
          Comps.Delete(i);
          FreeAndNil(comp);
        end;

      while dxLayoutControl.AbsoluteItemCount <> 0 do
        dxLayoutControl.AbsoluteItems[0].Free;
    finally
      dxLayoutControl.EndUpdate;
    end;
  finally
    SkipOpenDataSet := False;
  end;
  SiFormController.LeaveMethod(Self, 'DestroyControls');
end;

function TLayoutController.UniqueLayoutItemName(const name: string): string;
var
  i: Integer;
begin
  result := name.Replace(' ', '', [rfReplaceAll]);

  i := 0;
  while assigned(dxLayoutControl.FindItem(result)) do
  begin
    Inc(i);
    result := name + '_' + inttostr(i);
  end;
end;

function TLayoutController.ItemName(const name: string): string;
begin
  result := dxLayoutControl.name + 'Item' + Name;
end;

function TLayoutController.GroupName(const name: string): string;
begin
  result := dxLayoutControl.name + 'Group' + Name;
end;

function TLayoutController.SplitterName(const name: string): string;
begin
  result := dxLayoutControl.name + 'Splitter' + Name;
end;

function TLayoutController.UniqueGroupName(const name: string): string;
begin
  result := UniqueLayoutItemName(GroupName(Name));
end;

function TLayoutController.UniqueSplitterName(const name: string): string;
begin
  result := UniqueLayoutItemName(SplitterName(Name));
end;

function TLayoutController.UniqueItemName(const name: string): string;
begin
  result := UniqueLayoutItemName(ItemName(Name));
end;

procedure TLayoutController.InitLayoutGroups;
var
  grp: TdxLayoutGroup;
  Antenato: TdxCustomLayoutItem;
  i: Integer;
begin
  dxLayoutControl.BeginUpdate;
  try
    for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
      if dxLayoutControl.AbsoluteItems[i] is TdxLayoutGroup then
      begin
        grp := TdxLayoutGroup(dxLayoutControl.AbsoluteItems[i]);

        if grp.LayoutDirection = ldTabbed then
        begin
          if grp.Count > 0 then
            grp.ItemIndex := 0;

          if grp.LayoutDirection = ldTabbed then
          begin
            grp.ItemIndex := 0;
            // 2026-11-08: il layout caricato dal dizionario porta HotTrack falso (GroupTabbedHotTrack
            // vale False per default). Con DevExpress 26.1 il clic su una linguetta agisce sulla
            // linguetta "calda": senza hot track il clic funziona solo dopo aver fatto muovere
            // il mouse sulla linguetta, e a volte nemmeno.
            grp.TabbedOptions.HotTrack := True;
            grp.OnTabChanging := TabChanging;
            grp.OnTabChanged := TabChanged;
            // if grp.Count <= 1 then
            // grp.LayoutDirection := ldHorizontal;
          end;
        end;
      end;

    // 2026-11-08: con DevExpress 26.1 i gruppi a schede con linguette visibili e i loro
    // genitori non reagiscono al clic se hanno il bordo azzerato del look and feel "senza
    // bordo". Quei gruppi tornano al look and feel normale; tutti gli altri (anche quelli
    // dentro le pagine) restano senza bordo, cosi' non si perde spazio verticale fra le viste.
    for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
      if dxLayoutControl.AbsoluteItems[i] is TdxLayoutGroup then
      begin
        grp := TdxLayoutGroup(dxLayoutControl.AbsoluteItems[i]);

        if (grp.LayoutDirection = ldTabbed) and (not grp.TabbedOptions.HideTabs) then
        begin
          Antenato := grp;

          while Antenato <> nil do
          begin
            if Antenato.LayoutLookAndFeel = dx.LayoutLookAndFeelNoGroupBorder then
              Antenato.LayoutLookAndFeel := dx.LayoutLookAndFeelNormal;

            Antenato := Antenato.Parent;
          end;
        end;
      end;
  finally
    dxLayoutControl.EndUpdate;
  end;
end;

function TLayoutController.IsContainerReady: boolean;
begin
  result := False;

  if assigned(dxLayoutControl) then
    result := TdxLayoutControlAccess(dxLayoutControl).IsContainerReady;
end;

function TLayoutController.IsControlVisible(Control: TControl): boolean;
var
  item: TdxLayoutItem;
begin
  result := False;

  if not assigned(Control) then
    Exit;

  item := dxLayoutControl.FindItem(Control);

  if assigned(item) then
    result := item.ActuallyVisible;
end;

function TLayoutController.FindGroup(const GroupName: string): TdxLayoutGroup;
var
  item: TdxCustomLayoutItem;
begin
  result := nil;

  if not assigned(dxLayoutControl) then
    Exit;

  item := dxLayoutControl.FindItem(GroupName);

  if assigned(item) then
    if item is TdxLayoutGroup then
      result := TdxLayoutGroup(item);
end;

function TLayoutController.FindItem(const ItemName: string): TdxLayoutItem;
var
  item: TdxCustomLayoutItem;
begin
  result := nil;

  if not assigned(dxLayoutControl) then
    Exit;

  item := FindCustomItem(ItemName);

  if assigned(item) then
    if item is TdxLayoutItem then
      result := TdxLayoutItem(item);
end;

function TLayoutController.FindCustomItem(const ItemName: string): TdxCustomLayoutItem;
begin
  result := nil;

  if not assigned(dxLayoutControl) then
    Exit;

  result := dxLayoutControl.FindItem(ItemName);
end;

procedure TLayoutController.Pack;

  procedure RemoveEmptyItems;
  var
    i: Integer;
    item: TdxLayoutItem;
    dummy: TzDiagramDataSet.TzDiagramCtrl;
  begin
    for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
      if dxLayoutControl.AbsoluteItems[i] is TdxLayoutItem then
      begin
        item := TdxLayoutItem(dxLayoutControl.AbsoluteItems[i]);

        // if item.Control = nil then // ZZ 16.11.2016: deve togliere gli item per i dataset eliminati dal diagramma
        // item.Parent := nil
        // else
        if dictLayoutItems.ContainsKey(item) then
        begin
          if not dictLayoutItems.TryGetValue(item, dummy) then
            item.Parent := nil;
        end
        else // dataset eliminati: non sono presenti nel dictLayoutItems ma vengono letti dallo zip
        begin
          if not assigned(item.Control) then
          begin
            item.Parent := nil;
            item.Free;
          end;
        end;
      end;
  end;

  procedure RemoveEmptyGroups;

    function IsStructurallyEmpty(grp: TdxLayoutGroup): boolean;
    var
      j: Integer;
    begin
      result := True;
      for j := 0 to grp.Count - 1 do
        if not(grp.Items[j] is TdxLayoutSplitterItem) then
          Exit(False);
    end;

  var
    i: Integer;
    changed: boolean;
  begin
    // a CASCATA: svuotando un gruppo figlio il padre puo' diventare vuoto a
    // sua volta, quindi si ripete finche' non si rimuove piu' nulla.
    repeat
      changed := False;
      for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
        // 20.11.2017 - commentato, altrimenti non toglie i gruppi dei dataset eliminati
        // if not dxLayoutControl.AbsoluteItems[i].GetFlagUserDefined then
        if dxLayoutControl.AbsoluteItems[i] is TdxLayoutGroup then
          if IsStructurallyEmpty(TdxLayoutGroup(dxLayoutControl.AbsoluteItems[i])) then
          begin
            dxLayoutControl.AbsoluteItems[i].Free; // libera anche gli splitter residui
            changed := True;
          end;
    until not changed;
  end;

  procedure HideTreeItems;
    procedure Hide(name: string);
    var
      CustomItem: TdxCustomLayoutItem;
    begin
      CustomItem := dxLayoutControl.FindItem(name);
      if assigned(CustomItem) then
      begin
        CustomItem.Parent := Nil;
        CustomItem.Free;
      end;
    end;

  begin
    if not assigned(TreeMenu) then
    begin
      Hide(SplitterName('TreeMenu'));
      Hide(ItemName('TreeMenu'));
      Hide(GroupName('TreeMenu'));
    end;
  end;

  procedure ForceTreePosition;
  var
    CustomItem: TdxCustomLayoutItem;
    SplitterTree: TdxCustomLayoutItem;
    Indice: Integer;
  begin
    if assigned(TreeMenu) then
    begin

      CustomItem := dxLayoutControl.FindItem(GroupName('TreeMenu'));
      if assigned(CustomItem) then
        CustomItem.Index := 0;

      SplitterTree := dxLayoutControl.FindItem(SplitterName('TreeMenu'));
      if assigned(SplitterTree) then
        SplitterTree.Index := 1;

      // Alla radice e' ammesso un solo splitter, quello del tree. Un secondo
      // splitter consecutivo (aggiunto dall'editor di personalizzazione) non
      // ridimensiona il tree ma lo splitter che lo precede: DevExpress
      // (TdxLayoutSplitterItem.GetNearItem) prende l'item visibile
      // immediatamente precedente, splitter inclusi, e quello diventa una
      // fascia larga con la maniglia al centro (caso FormStudenti 2026-09-07).
      for Indice := dxLayoutControl.Items.Count - 1 downto 0 do
      begin
        CustomItem := dxLayoutControl.Items[Indice];

        if (CustomItem is TdxLayoutSplitterItem) and (CustomItem <> SplitterTree) then
        begin
          SiFormController.LogString('Pack.RemoveRootSplitter', CustomItem.name);
          CustomItem.Parent := nil;
          CustomItem.Free;
        end;
      end;
    end;
  end;

begin
  dxLayoutControl.BeginUpdate;
  try
    RemoveEmptyItems;
    RemoveEmptyGroups;
    HideTreeItems;
    ForceTreePosition;
  finally
    dxLayoutControl.EndUpdate;
  end;
end;

{ TLayoutController - IInterface (senza reference counting) }

function TLayoutController.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    result := S_OK
  else
    result := E_NOINTERFACE;
end;

function TLayoutController._AddRef: Integer;
begin
  result := -1; // ciclo di vita gestito da TzFormController
end;

function TLayoutController._Release: Integer;
begin
  result := -1;
end;

{ TLayoutController - IzLayoutMaintenance }

function TLayoutController.CanMaintainLayout: boolean;
begin
  result := (not IsDestroying) and assigned(dxLayoutControl) and assigned(FormController) and assigned(FormController.zDataModule);
end;

function TLayoutController.DataModuleGroupName: string;
begin
  result := GroupName('DataModule_' + FormController.zDataModule.name).Replace(' ', '', [rfReplaceAll]);
end;

procedure TLayoutController.ResetLayout;
begin
  if not CanMaintainLayout then
    Exit;

  if dxLayoutControl.Customization then
    // eseguita in OnCustomization, dopo la chiusura del form di customize
    FPendingMaintenanceOp := lmoReset
  else
    DoResetLayout;
end;

procedure TLayoutController.RepairLayout;
begin
  if not CanMaintainLayout then
    Exit;

  if dxLayoutControl.Customization then
    FPendingMaintenanceOp := lmoRepair
  else
    DoRepairLayout;
end;

procedure TLayoutController.ExecutePendingMaintenance;
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

procedure TLayoutController.DoResetLayout;
var
  zLayout: TzLayout;
begin
  SiFormController.EnterMethod(Self, 'DoResetLayout');
  Screen.Cursor := crHourGlass;
  try
    // 1) svuota le personalizzazioni salvate
    zLayout := GetLayoutProps;
    if assigned(zLayout) then
      zLayout.DefaultProps;

    // 2) ricostruisce: con LZ vuoto resta la struttura canonica "ex novo"
    CreateControls;

    // 3) persiste lo stato pulito
    FormController.zDataModule.SaveToBase(True);
  finally
    Screen.Cursor := crDefault;
    SiFormController.LeaveMethod(Self, 'DoResetLayout');
  end;
end;

procedure TLayoutController.DoRepairLayout;
var
  zLayout: TzLayout;
begin
  SiFormController.EnterMethod(Self, 'DoRepairLayout');
  Screen.Cursor := crHourGlass;
  try
    // 1) fotografa lo stato corrente nell'LZ (senza persistere)
    SaveProps(False);

    // 2) sanifica i record incoerenti
    zLayout := GetLayoutProps;
    if assigned(zLayout) then
      RepairLayoutProps(zLayout);

    // 3) ricostruisce: struttura canonica + LZ sanificato
    CreateControls;

    // 4) ripristina l'ordine logico dei dataset sul layout vivo
    ReorderDataSetGroups;

    // 5) persiste il risultato riparato (LoadFromLayout ricattura lo stato
    // vivo, quindi gli eventuali record stale spariscono da soli)
    SaveProps(True);
  finally
    Screen.Cursor := crDefault;
    SiFormController.LeaveMethod(Self, 'DoRepairLayout');
  end;
end;

procedure TLayoutController.CollectGeneratedItemNames(Names: TDictionary<string, boolean>);

  function Stripped(const s: string): string;
  begin
    // UniqueLayoutItemName toglie gli spazi: i nomi canonici devono combaciare
    result := s.Replace(' ', '', [rfReplaceAll]);
  end;

  procedure enum(zDiagramDataSets: TzDiagramDataSets);
  var
    ds: TzDiagramDataSet;
  begin
    for ds in zDiagramDataSets do
      if (not ds.IsLookupDataSet) and (ds.ActualAccessLevel <> alNone) then
      begin
        Names.AddOrSetValue(Stripped(GroupName(ds.name)), True);
        Names.AddOrSetValue(Stripped(GroupName(ds.name + 'Controls')), True);

        if ds.HasDetailDataSets then
        begin
          Names.AddOrSetValue(Stripped(SplitterName(ds.name + 'Details')), True);
          Names.AddOrSetValue(Stripped(GroupName(ds.name + 'Details')), True);
          enum(ds.DetailDatasets);
        end;
      end;
  end;

begin
  Names.AddOrSetValue(Stripped(GroupName('TreeMenu')), True);
  Names.AddOrSetValue(Stripped(ItemName('TreeMenu')), True);
  Names.AddOrSetValue(Stripped(SplitterName('TreeMenu')), True);
  Names.AddOrSetValue(DataModuleGroupName, True);

  enum(FormController.zDataModule.DataSets);
end;

procedure TLayoutController.RepairLayoutProps(zLayout: TzLayout);
var
  CanonicalNames: TDictionary<string, boolean>;
  RecordNames: TDictionary<string, boolean>;
  i: Integer;
  item: TzLayoutItem;
  Removed: boolean;

  function ParentResolvable(const ParentName: string): boolean;
  begin
    result := (ParentName = '') or RecordNames.ContainsKey(ParentName) or CanonicalNames.ContainsKey(ParentName);
  end;

  // Vero se nello stesso padre esiste un altro record di splitter con indice
  // contiguo: due splitter consecutivi fanno agire il secondo sul primo.
  function HasAdjacentSplitter(Splitter: TzLayoutItem): boolean;
  var
    Indice: Integer;
    Altro: TzLayoutItem;
  begin
    result := False;

    for Indice := 0 to zLayout.Layout.Count - 1 do
    begin
      Altro := zLayout.Layout[Indice];

      if (Altro <> Splitter) and (Altro.ItemClassKind = ickLayoutSplitterItem) then
        if SameText(Altro.ParentName, Splitter.ParentName) and (Abs(Altro.Idx - Splitter.Idx) = 1) then
          Exit(True);
    end;
  end;

begin
  SiFormController.EnterMethod(Self, 'RepairLayoutProps');

  CanonicalNames := TDictionary<string, boolean>.Create;
  RecordNames := TDictionary<string, boolean>.Create;
  try
    CollectGeneratedItemNames(CanonicalNames);

    for i := 0 to zLayout.Layout.Count - 1 do
      RecordNames.AddOrSetValue(zLayout.Layout[i].name, True);

    // iterativo: la rimozione di un record puo' invalidare i parent di altri
    repeat
      Removed := False;

      for i := zLayout.Layout.Count - 1 downto 0 do
      begin
        item := zLayout.Layout[i];

        // a) record di elementi generati dal controller risultati "sganciati"
        // (ParentName='' / Idx=-1): sono i record che ad ogni load staccano
        // i gruppi dalla posizione canonica (gruppi orfani/invisibili).
        // Eliminandoli, torna a valere la posizione di CreateLayoutStructure.
        if item.GeneratedByController and ((item.ParentName = '') or (item.Idx = -1)) then
        begin
          SiFormController.LogString('RepairLayoutProps.RemoveDetached', item.name);
          RecordNames.Remove(item.name);
          item.Free; // TCollectionItem.Free lo rimuove dalla collection
          Removed := True;
          Continue;
        end;

        // b) record con parent irrisolvibile (ne' tra i record, ne' canonico)
        if not ParentResolvable(item.ParentName) then
        begin
          SiFormController.LogString('RepairLayoutProps.RemoveUnresolvedParent', item.name + ' -> ' + item.ParentName);
          RecordNames.Remove(item.name);
          item.Free;
          Removed := True;
          Continue;
        end;

        // d) record di splitter non generati dal controller con padre la radice,
        // oppure adiacenti a un altro splitter nello stesso padre: il trascinamento
        // del secondo ridimensiona il primo (GetNearItem di DevExpress non salta
        // gli splitter) e lo trasforma in una fascia larga. Caso reale: modulo
        // Studenti, 'dxLayoutSplitterItem5' (Divisore) con Idx = 2 alla radice.
        if (item.ItemClassKind = ickLayoutSplitterItem) and (not item.GeneratedByController) then
          if SameText(item.ParentName, dxLayoutControl.Items.name) or HasAdjacentSplitter(item) then
          begin
            SiFormController.LogString('RepairLayoutProps.RemoveStraySplitter', item.name);
            RecordNames.Remove(item.name);
            item.Free;
            Removed := True;
            Continue;
          end;

        // c) record di splitter con allineamento "client" o con dimensioni
        // proprie: riapplicati dal LZ trasformano lo splitter in una fascia
        // larga quanto lo spazio libero del gruppo. Si normalizzano (non si
        // eliminano) per conservare posizione e stato di chiusura.
        if item.ItemClassKind = ickLayoutSplitterItem then
          if (item.AlignHorz = ahClient) or (item.AlignVert = avClient) or (item.Width > 0) or (item.Height > 0) then
          begin
            SiFormController.LogString('RepairLayoutProps.NormalizeSplitter', item.name);
            item.AlignHorz := ahParentManaged;
            item.AlignVert := avParentManaged;
            item.Width := 0;
            item.Height := 0;
          end;
      end;
    until not Removed;

    // e) gruppi dei dataset rimasti nel contenitore di un vecchio master. Va
    // dopo il ciclo: la correzione porta Idx a -1 e la regola a) cancellerebbe
    // il record, perdendo didascalia e dimensioni scelte dall'amministratore.
    RepairDataSetGroupParents(zLayout);
  finally
    FreeAndNil(RecordNames);
    FreeAndNil(CanonicalNames);
  end;

  SiFormController.LeaveMethod(Self, 'RepairLayoutProps');
end;

// Non e' chiamata in apertura della form ma solo da "Ripara layout": nei
// dizionari di Gesty e WT ci sono gruppi messi di proposito fra le linguette di
// un dataset fratello, che mostrano comunque dati corretti; spostarli in
// automatico cambierebbe la form a tutti gli utenti senza che nessuno lo chieda.
function TLayoutController.RepairDataSetGroupParents(zLayout: TzLayout): Integer;
var
  CanonicalParents: TDictionary<string, string>;
  AncestorContainers: TDictionary<string, string>;
  i: Integer;
  item: TzLayoutItem;
  CanonicalParent, Ancestors: string;

  function Stripped(const s: string): string;
  begin
    // UniqueLayoutItemName toglie gli spazi: i nomi canonici devono combaciare
    result := s.Replace(' ', '', [rfReplaceAll]);
  end;

  // Contenitori in cui il controller dispone i gruppi dei dataset: il gruppo del
  // modulo e i gruppi "...Details" (stessa regola di ReorderDataSetGroups).
  // Un gruppo che l'utente ha messo in un contenitore proprio non e' toccato.
  function IsControllerContainer(const Name: string): boolean;
  begin
    result := SameText(Name, DataModuleGroupName) or (Name.StartsWith(dxLayoutControl.name + 'Group') and Name.EndsWith('Details'));
  end;

  // ParentGroupName: padre canonico dei gruppi di zDiagramDataSets.
  // Chain: contenitori della linea degli antenati, padre canonico compreso,
  // nella forma '|NOME1|NOME2|' (maiuscolo) per la ricerca con Pos.
  procedure enum(zDiagramDataSets: TzDiagramDataSets; const ParentGroupName, Chain: string);
  var
    ds: TzDiagramDataSet;
    DetailsGroupName: string;
  begin
    // stesse condizioni di CreateLayoutStructure: solo i gruppi che esistono
    for ds in zDiagramDataSets do
      if (not ds.IsLookupDataSet) and (ds.ActualAccessLevel <> alNone) then
      begin
        CanonicalParents.AddOrSetValue(Stripped(GroupName(ds.name)), ParentGroupName);
        AncestorContainers.AddOrSetValue(Stripped(GroupName(ds.name)), Chain);

        if ds.HasDetailDataSets then
        begin
          DetailsGroupName := Stripped(GroupName(ds.name + 'Details'));
          enum(ds.DetailDatasets, DetailsGroupName, Chain + UpperCase(DetailsGroupName) + '|');
        end;
      end;
  end;

begin
  result := 0;

  if not assigned(zLayout) then
    Exit;

  SiFormController.EnterMethod(Self, 'RepairDataSetGroupParents');

  CanonicalParents := TDictionary<string, string>.Create;
  AncestorContainers := TDictionary<string, string>.Create;
  try
    enum(FormController.zDataModule.DataSets, DataModuleGroupName, '|' + UpperCase(DataModuleGroupName) + '|');

    for i := 0 to zLayout.Layout.Count - 1 do
    begin
      item := zLayout.Layout[i];

      if not CanonicalParents.TryGetValue(item.name, CanonicalParent) then
        Continue;

      // record staccato (ParentName vuoto): competenza della regola a) di RepairLayoutProps
      if (item.ParentName = '') or SameText(item.ParentName, CanonicalParent) then
        Continue;

      // Gruppo portato fra le linguette di un antenato o al livello del modulo:
      // e' un modo voluto di appiattire i dettagli (WT, Catasto), si rispetta.
      if not AncestorContainers.TryGetValue(item.name, Ancestors) then
        Ancestors := '';
      if Pos('|' + UpperCase(item.ParentName) + '|', Ancestors) > 0 then
        Continue;

      // Il gruppo sta nel contenitore di un dataset che non e' suo antenato:
      // di solito il vecchio master, dopo un cambio di master nel dizionario.
      // Se quel contenitore esiste ancora, SaveToLayout ci riporta il gruppo a
      // ogni apertura e il dettaglio compare accanto a dati a cui non e' piu'
      // legato. Caso reale: zTicser, TicserConfigurazione, GraficoVoci passato
      // da PianoVoci a Piani. Idx = -1: la posizione nel vecchio padre non vale
      // nel nuovo, il gruppo resta dove lo mette CreateLayoutStructure.
      if IsControllerContainer(item.ParentName) then
      begin
        SiFormController.LogString('RepairDataSetGroupParents', item.name + ': ' + item.ParentName + ' -> ' + CanonicalParent);
        item.ParentName := CanonicalParent;
        item.Idx := -1;
        Inc(result);
      end;
    end;
  finally
    FreeAndNil(AncestorContainers);
    FreeAndNil(CanonicalParents);
  end;

  SiFormController.LeaveMethod(Self, 'RepairDataSetGroupParents');
end;

procedure TLayoutController.ReorderDataSetGroups;
var
  NextPos: TDictionary<TdxCustomLayoutItem, Integer>;

  function IsControllerManagedParent(Parent: TdxCustomLayoutItem): boolean;
  var
    ParentName: String;
  begin
    result := False;

    if not(Parent is TdxLayoutGroup) then
      Exit;

    // il gruppo DataModule e i gruppi "...Details" sono i contenitori in cui
    // il controller dispone i gruppi-dataset: solo li' l'ordine logico vince
    if SameText(Parent.name, DataModuleGroupName) then
      Exit(True);

    ParentName := Parent.name;
    result := ParentName.StartsWith(dxLayoutControl.name + 'Group') and ParentName.EndsWith('Details');
  end;

  procedure PlaceGroup(grp: TdxLayoutGroup);
  var
    pos: Integer;
  begin
    if not assigned(grp.Parent) then
      Exit;

    // se l'utente ha spostato il gruppo in un contenitore proprio,
    // la sua scelta viene rispettata
    if not IsControllerManagedParent(grp.Parent) then
      Exit;

    if not NextPos.TryGetValue(grp.Parent, pos) then
      pos := 0;

    if (grp.Index <> pos) and (pos < grp.Parent.Count) then
      grp.Index := pos;

    NextPos.AddOrSetValue(grp.Parent, grp.Index + 1);
  end;

  procedure enum(zDiagramDataSets: TzDiagramDataSets);
  var
    ds: TzDiagramDataSet;
    grp: TdxLayoutGroup;
  begin
    for ds in zDiagramDataSets do
      if (not ds.IsLookupDataSet) and (ds.ActualAccessLevel <> alNone) then
      begin
        grp := FindGroup(GroupName(ds.name).Replace(' ', '', [rfReplaceAll]));
        if assigned(grp) then
          PlaceGroup(grp);

        if ds.HasDetailDataSets then
          enum(ds.DetailDatasets);
      end;
  end;

begin
  if not CanMaintainLayout then
    Exit;

  SiFormController.EnterMethod(Self, 'ReorderDataSetGroups');

  NextPos := TDictionary<TdxCustomLayoutItem, Integer>.Create;
  try
    dxLayoutControl.BeginUpdate;
    try
      enum(FormController.zDataModule.DataSets);
    finally
      dxLayoutControl.EndUpdate;
    end;
  finally
    FreeAndNil(NextPos);
  end;

  SiFormController.LeaveMethod(Self, 'ReorderDataSetGroups');
end;

procedure TzFormController.CheckControlDimensions;
begin
  LayoutController.CheckControlDimensions;
end;

constructor TzFormController.Create(AOwner: TComponent);
begin
  SiFormController.EnterMethod(Self, 'Create');
  inherited;
  IsDestroying := False;
  FDesignWidth := 1920;
  FDesignHeight := 1200;
  FDataModule := nil;
  FzDataModule := nil;
  FImages := nil;
  FzSystem := nil;
  FCtrlOwner := nil;
  FCtrlParent := nil;
  FonAfterCreateControls := nil;
  FOnAfterCreateComponent := nil;
  FonAfterLayoutControlLoadProps := nil;
  FOnDatasetAssigned := nil;
  FOnBeforeDestroyComponent := nil;
  FOnBeforeDisplayItem := nil;
  FOnSelect := nil;
  FSkipSelectFirstNode := False;
  FLayoutController := TLayoutController.Create(Self);

  TimerCheckControlDimensions := TTimer.Create(Self);
  TimerCheckControlDimensions.Enabled := False;
  TimerCheckControlDimensions.Interval := 300;
  TimerCheckControlDimensions.OnTimer := TimerCheckControlDimensionsTimer;

  SiFormController.LeaveMethod(Self, 'Create');
end;

destructor TzFormController.Destroy;
begin
  SiFormController.EnterMethod('TzFormController.Destroy');
  IsDestroying := True;
  DestroyControls;
  FreeAndNil(FLayoutController);
  FreeAndNil(TimerCheckControlDimensions);
  inherited;
  SiFormController.LeaveMethod('TzFormController.Destroy');
end;

procedure TzFormController.CreateControls;
var
  Misura: boolean;
  Cronometro: TStopwatch;
  NomeModulo: string;
  ModuloPrecedente: string;
begin
  SiFormController.EnterMethod(Self, 'CreateControls');
  // DestroyControls;

  if LayoutController.FormController.zDataModule.BuildGUI = False then
    Exit;

  // Il modulo a cui attribuire le misure. Durante la costruzione la form
  // nuova non e' ancora quella attiva, quindi Screen.OnActiveFormChange
  // attribuirebbe tutto alla form precedente: qui lo si dichiara esplicito
  // e si ripristina alla fine.
  NomeModulo := '';
  if assigned(FCtrlOwner) then
    NomeModulo := FCtrlOwner.ClassName
  else if assigned(FzDataModule) then
    NomeModulo := FzDataModule.Name;

  ModuloPrecedente := '';
  Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
  if Misura then
  begin
    ModuloPrecedente := TzRaccoltaPrestazioni.Istanza.ModuloCorrente;
    if NomeModulo <> '' then
      TzRaccoltaPrestazioni.Istanza.ModuloCorrente := NomeModulo;
    Cronometro := TStopwatch.StartNew;
  end;

  try
    LayoutController.DestroyControls;
    LayoutController.CreateControls;
  finally
    if Misura then
    begin
      // Nome con il marcatore perche' questa voce COMPRENDE le altre della
      // categoria: nel riepilogo non va sommata a InitView, InitCard,
      // DataSetLoadProps e TzMap.SetParent, che avvengono dentro di lei.
      zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, '(totale) costruzione form', Cronometro.ElapsedMilliseconds, NomeModulo);
      TzRaccoltaPrestazioni.Istanza.ModuloCorrente := ModuloPrecedente;
    end;
  end;

  SiFormController.LeaveMethod(Self, 'CreateControls');
end;

procedure TzFormController.CustomizeLayout;
begin
  SiFormController.EnterMethod(Self, 'CustomizeLayout');
  LayoutController.Customize;
  SiFormController.LeaveMethod(Self, 'CustomizeLayout');
end;

function TzFormController.GetCtrlOwner: TComponent;
begin
  result := CtrlOwner;
  if not assigned(result) then
    result := Owner;
end;

function TzFormController.GetCtrlParent: TWinControl;
begin
  result := CtrlParent;
  if not assigned(result) then
    if Owner is TWinControl then
      result := TWinControl(Owner);
end;

function TzFormController.GetDataSet(zDiagramDataSet: TzDiagramDataSet): TzFbDataSet;
begin
  SiFormController.EnterMethod(Self, 'GetDataSet');
  result := nil;

  if assigned(zDiagramDataSet) then
    if assigned(DataModule) then
      result := DataModule.GetDataSet(zDiagramDataSet.name);
  SiFormController.LeaveMethod(Self, 'GetDataSet');
end;

procedure TzFormController.ActivateDataSet(zDiagramDataSet: TzDiagramDataSet);
begin
  SiFormController.EnterMethod(Self, 'ActivateDataSet');

  if not IsDestroying then
    if assigned(zDiagramDataSet) then
      if assigned(DataModule) then
        DataModule.ActivateDataSet(zDiagramDataSet.name);
  SiFormController.LeaveMethod(Self, 'ActivateDataSet');
end;

procedure TzFormController.DestroyControls;
begin
  SiFormController.EnterMethod(Self, 'DestroyControls');
  LayoutController.DestroyControls;
  SiFormController.LeaveMethod(Self, 'DestroyControls');
end;

function TzFormController.DumpItemSize(const ClientWidth, ClientHeight: Integer): String;
var
  StringList: TStringList;
  item: TdxCustomLayoutItem;
  s: String;
  i: Integer;
begin
  result := '';

  StringList := TStringList.Create;
  try

    if assigned(LayoutController.dxLayoutControl) then
    begin
      StringList.Add('ClientWidth: ' + ClientWidth.ToString + ' - ClientHeight: ' + ClientHeight.ToString);
      StringList.Add('OccupiedClientWidth: ' + LayoutController.dxLayoutControl.OccupiedClientWidth.ToString + ' - OccupiedClientHeight: ' + LayoutController.dxLayoutControl.OccupiedClientHeight.ToString);

      for i := 0 to LayoutController.dxLayoutControl.AbsoluteItemCount - 1 do
      begin
        item := LayoutController.dxLayoutControl.AbsoluteItems[i];
        s := item.name;
        s := s + ' -  UsualWidth:' + item.ViewInfo.UsualWidth.ToString;
        s := s + ' (Width:' + item.ViewInfo.UsualWidth.ToString + ')';
        s := s + ' -  UsualHeight:' + item.ViewInfo.UsualHeight.ToString;
        s := s + ' (Height:' + item.ViewInfo.UsualHeight.ToString + ')';

        if (item.ViewInfo.UsualWidth >= ClientWidth) or (item.ViewInfo.UsualHeight >= ClientHeight) then
          s := '!!! ' + s;

        StringList.Add(s);
      end;
    end;

    result := StringList.Text;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzFormController.ResetItemSize;
begin

  if assigned(LayoutController) then
    LayoutController.ResetItemSize;
end;

procedure TzFormController.ResetLayout;
begin
  // l'intera operazione (clear LZ + ricostruzione + persistenza)
  // e' gestita dal LayoutController
  LayoutController.ResetLayout;
end;

procedure TzFormController.LoadFromIni;
begin
  LayoutController.LoadFromIni;
end;

procedure TzFormController.SaveToIni;
begin
  LayoutController.SaveToIni;
end;

function TLayoutController.GetLayoutProps: TzLayout;
var
  Idx: Integer;
begin
  result := nil;

  if not assigned(FormController) then
    Exit;

  if not assigned(FormController.zDataModule) then
    Exit;

  if not assigned(dxLayoutControl) then
    Exit;

  // vedere per quello automatico
  Idx := FormController.zDataModule.Layouts.IndexOf(dxLayoutControl.name);
  if Idx <> -1 then
    result := FormController.zDataModule.Layouts[Idx]
  else
  begin
    result := FormController.zDataModule.Layouts.Add;
    result.name := dxLayoutControl.name;
  end;
end;

procedure TLayoutController.LoadProps;
begin
  SiFormController.EnterMethod(Self, 'LoadProps');
  if ctrlKey then
    Exit;

  dxLayoutControl.BeginUpdate;
  try
    InternalLoadProps;
    Pack;
    InitLayoutGroups;
    //
  finally
    dxLayoutControl.EndUpdate;
  end;
  SiFormController.LeaveMethod(Self, 'LoadProps');
end;

procedure TLayoutController.SaveProps(const SaveDataModule: boolean = True);

var
  zLayout: TzLayout;
  Monitor: TMonitor; // Risoluzione per form 2026-09-22
begin
  SiFormController.EnterMethod(Self, 'SaveProps');
  Pack;
  zLayout := GetLayoutProps;

  // SkipGenerated = False: qui gli item generati dal controller sono i
  // gruppi strutturali dei dataset creati da CreateLayoutStructure
  // (grpDataSet, ...Controls, ...Details) e gli item dei controlli. Sono
  // esattamente cio' che l'amministratore personalizza nell'editor visuale:
  // scartandoli, ogni modifica (LayoutDirection, posizione, dimensioni)
  // andava persa alla riapertura, quando CreateLayoutStructure li ricreava
  // con i valori canonici.
  zLayout.Layout.LoadFromLayout(dxLayoutControl, False);

  // Risoluzione per form 2026-09-22: registro il monitor su cui questa form
  // e' stata effettivamente redatta. Su una postazione multi-monitor il
  // salvataggio puo' avvenire da uno schermo qualunque, e senza questo dato
  // chi rilegge assume sempre 1920x1200 e scala rispetto a una base che non
  // e' la sua. Scrivo solo valori plausibili: una risoluzione assurda e'
  // peggio di nessuna risoluzione, perche' sostituirebbe un valore sbagliato
  // a un valore predefinito ragionevole.
  Monitor := CurrentMonitor;

  if assigned(Monitor) and (Monitor.Width >= MIN_VALID_MONITOR_WIDTH) and (Monitor.height >= MIN_VALID_MONITOR_HEIGHT) then
  begin
    zLayout.DesignWidth := Monitor.Width;
    zLayout.DesignHeight := Monitor.height;

    if (Monitor.Width <> FormController.DesignWidth) or (Monitor.height <> FormController.DesignHeight) then
      SiFormController.LogWarning('SaveProps: layout "%s" redatto a %dx%d, diverso dal riferimento %dx%d.',
        [zLayout.name, Monitor.Width, Monitor.height, FormController.DesignWidth, FormController.DesignHeight]);
  end;

  if SaveDataModule then
    FormController.zDataModule.SaveToBase(True);

  SiFormController.LeaveMethod(Self, 'SaveProps');
end;

procedure TzFormController.doAfterCreateComponent(LayoutController: TLayoutController; const DataSetName: String; Component: TComponent);
begin
  if assigned(FOnAfterCreateComponent) then
    OnAfterCreateComponent(Self, LayoutController, DataSetName, Component);
end;

procedure TzFormController.doAfterCreateControls;
begin
  if assigned(FonAfterCreateControls) then
    FonAfterCreateControls(Self);
end;

procedure TzFormController.doBeforeDestroyComponent(LayoutController: TLayoutController; Component: TComponent);
begin
  if assigned(FOnBeforeDestroyComponent) then
    OnBeforeDestroyComponent(Self, LayoutController, Component);
end;

procedure TzFormController.doDatasetAssigned(const DataSetName: String; Component: TComponent);
begin
  if assigned(FOnDatasetAssigned) then
    OnDatasetAssigned(Self, DataSetName, Component);
end;

procedure TzFormController.doSelect;
begin
  if assigned(FOnSelect) then
    OnSelect(Self);
end;

function TzFormController.GetComponent<T>(const DataSetName: string): T;
var
  lComparer: IEqualityComparer<T>;
begin
  result := default (T);
  lComparer := TEqualityComparer<T>.Default;

  result := LayoutController.GetComponent<T>(DataSetName);

  if not lComparer.Equals(result, Default (T)) then
    Exit(result);
end;

function TzFormController.GetDbCard(const DataSetName: string): TzDbCard;
var
  i: Integer;
  diagramDataSet: TzDiagramDataSet;
  card: TzDiagramDataSet.TDbCard;
begin
  result := nil;

  diagramDataSet := zDataModule.FindDataSet(DataSetName);
  if not assigned(diagramDataSet) then
    Exit;

  for i := 0 to diagramDataSet.DbCards.Count - 1 do
  begin
    card := diagramDataSet.DbCards[i];
    if card.Visible then
    begin

      result := GetCtrlOwner.FindComponent(card.ComponentName) as TzDbCard;

      if assigned(result) then
        Exit(result);
    end;
  end;
end;

function TzFormController.GetDbRecordView(const DataSetName: string): TzDbRecordView;
var
  i: Integer;
  diagramDataSet: TzDiagramDataSet;
  RecordView: TzDiagramDataSet.TDbRecordView;
begin
  result := nil;

  diagramDataSet := zDataModule.FindDataSet(DataSetName);
  if not assigned(diagramDataSet) then
    Exit;

  for i := 0 to diagramDataSet.DbRecordViews.Count - 1 do
  begin
    RecordView := diagramDataSet.DbRecordViews[i];
    if RecordView.Visible then
    begin
      result := GetCtrlOwner.FindComponent(RecordView.ComponentName) as TzDbRecordView;

      if assigned(result) then
        Exit(result);
    end;
  end;
end;

function TzFormController.GetDbTree(const DataSetName: string): TzDbTree;
var
  i: Integer;
  diagramDataSet: TzDiagramDataSet;
  Tree: TzDiagramDataSet.TDbTree;
begin
  result := nil;

  diagramDataSet := zDataModule.FindDataSet(DataSetName);
  if not assigned(diagramDataSet) then
    Exit;

  for i := 0 to diagramDataSet.DbTrees.Count - 1 do
  begin
    Tree := diagramDataSet.DbTrees[i];
    if Tree.Visible then
    begin
      result := GetCtrlOwner.FindComponent(Tree.ComponentName) as TzDbTree;

      if assigned(result) then
        Exit(result);
    end;
  end;
end;

function TzFormController.GetDbChart(const DataSetName: string): TzDbChart;
var
  i: Integer;
  diagramDataSet: TzDiagramDataSet;
  DbChart: TzDiagramDataSet.TDbChart;
begin
  result := nil;

  diagramDataSet := zDataModule.FindDataSet(DataSetName);
  if not assigned(diagramDataSet) then
    Exit;

  for i := 0 to diagramDataSet.DbCharts.Count - 1 do
  begin
    DbChart := diagramDataSet.DbCharts[i];
    if DbChart.Visible then
    begin
      result := GetCtrlOwner.FindComponent(DbChart.ComponentName) as TzDbChart;

      if assigned(result) then
        Exit(result);
    end;
  end;
end;

function TzFormController.GetDbScheduler(const DataSetName: string): TzDbScheduler;
var
  i: Integer;
  diagramDataSet: TzDiagramDataSet;
  DbScheduler: TzDiagramDataSet.TDbScheduler;
begin
  result := nil;

  diagramDataSet := zDataModule.FindDataSet(DataSetName);
  if not assigned(diagramDataSet) then
    Exit;

  for i := 0 to diagramDataSet.DbSchedulers.Count - 1 do
  begin
    DbScheduler := diagramDataSet.DbSchedulers[i];
    if DbScheduler.Visible then
    begin
      result := GetCtrlOwner.FindComponent(DbScheduler.ComponentName) as TzDbScheduler;

      if assigned(result) then
        Exit(result);
    end;
  end;
end;

function TzFormController.GetDbView(const DataSetName: string): TzDbView;
var
  i: Integer;
  diagramDataSet: TzDiagramDataSet;
  view: TzDiagramDataSet.TDbView;
begin
  result := nil;

  diagramDataSet := zDataModule.FindDataSet(DataSetName);
  if not assigned(diagramDataSet) then
    Exit;

  for i := 0 to diagramDataSet.DbViews.Count - 1 do
  begin
    view := diagramDataSet.DbViews[i];
    if view.Visible then
    begin
      result := GetCtrlOwner.FindComponent(view.ComponentName) as TzDbView;

      if assigned(result) then
        Exit(result);
    end;
  end;
end;

function TzFormController.GetSelectedDataSet: TzDiagramDataSet;
begin
  result := LayoutController.SelectedDataSet;
end;

function TzFormController.GetSelectedDataSetName: string;
begin
  result := LayoutController.SelectedDataSetName;
end;

function TzFormController.IsContainerReady: boolean;
begin
  result := False;

  if assigned(LayoutController) then
    result := LayoutController.IsContainerReady;
end;

//
procedure TzFormController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if not IsDestroying then
    if Operation = opRemove then
    begin

      // if AComponent = FDataModule then
      // DataModule := nil
      // else
      if AComponent = zSystem then
        zSystem := nil
      else
        if AComponent = CtrlOwner then
          CtrlOwner := nil
        else
          if AComponent = CtrlParent then
            CtrlParent := nil
          else
            if AComponent is TdxCustomLayoutItem then
            begin
              if assigned(LayoutController) then
                LayoutController.LayoutItemRemoved(AComponent as TdxCustomLayoutItem);
            end
            else
              if AComponent is TdxLayoutControl then
              begin
                // for LayoutController in LayoutControllers do
                // if LayoutController.dxLayoutControl = AComponent then
                // LayoutController.dxLayoutControl := nil;
              end;
    end;
end;

procedure TzFormController.SaveProps;
begin
  LayoutController.SaveProps(False);
  zDataModule.SaveToBase(True);
end;

procedure TzFormController.SetImages(const Value: TCustomImageList);
begin
  FImages := Value;
  LayoutController.Images := Images;
end;

procedure TzFormController.SetOnBeforeDisplayItem(const Value: TBeforeDisplayItem);
begin
  FOnBeforeDisplayItem := Value;

  if LayoutController.TreeMenu <> nil then
    LayoutController.TreeMenu.OnBeforeDisplayItem := Value;
end;

procedure TzFormController.SetSelectedDataSetName(const Value: string);
begin
  LayoutController.SelectedDataSetName := Value;
end;

procedure TzFormController.SetSkipSelectFirstNode(const Value: boolean);
begin
  FSkipSelectFirstNode := Value;
  if assigned(LayoutController) then
    LayoutController.SkipSelectFirstNode := SkipSelectFirstNode;
end;

procedure TzFormController.Translated;
begin
  LayoutController.Translated;
end;

procedure TLayoutController.CreateLayoutStructure;

  procedure AddDbCtrls(Group: TdxLayoutGroup; DbCtrls: TzDiagramDataSet.TzDiagramCtrls);
  var
    i: Integer;
    DbCtrl: TzDiagramDataSet.TzDiagramCtrl;
    item: TdxLayoutItem;
  begin
    for i := 0 to DbCtrls.Count - 1 do
    begin
      DbCtrl := TzDiagramDataSet.TzDiagramCtrl(DbCtrls[i]);
      if DbCtrl.Visible then
      begin
        item := CreateLayoutItem(Group, nil, DbCtrl.ComponentName, DbCtrl.Caption, True);
        dictLayoutItems.Add(item, DbCtrl);
      end;
    end;
  end;

  procedure enum(ParentGroup: TdxLayoutGroup; zDiagramDataSets: TzDiagramDataSets);
  var
    idxDataSet: Integer;
    idxCtrl: Integer;
    zDiagramDataSet: TzDiagramDataSet;
    grpDataSet, grpDataSetControls, grpDataSetDetails: TdxLayoutGroup;
    Splitter: TdxLayoutSplitterItem;
  begin
    for idxDataSet := 0 to zDiagramDataSets.Count - 1 do
    begin
      zDiagramDataSet := zDiagramDataSets[idxDataSet];

      if (not zDiagramDataSet.IsLookupDataSet) { and (zDiagramDataSet.VisibleCount > 0) } and (zDiagramDataSet.ActualAccessLevel <> alNone) then
      begin
        if zDiagramDataSet.HasMasterDataSet then
          grpDataSet := CreateLayoutGroup(ParentGroup, zDiagramDataSet.name, ldHorizontal, zDiagramDataSet.Menu.GetCaption)
        else
          grpDataSet := CreateLayoutGroup(ParentGroup, zDiagramDataSet.name, ldVertical, zDiagramDataSet.Menu.GetCaption);

        dictDataSetGroups.Add(grpDataSet, zDiagramDataSet);
        dictMenu.Add(zDiagramDataSet.name, grpDataSet);

        /// ///
        /// Controlli
        grpDataSetControls := CreateLayoutGroup(grpDataSet, zDiagramDataSet.name + 'Controls', ldTabbed, zDiagramDataSet.Menu.GetCaption);
        dictDataSetGroups.Add(grpDataSetControls, zDiagramDataSet);
        // grpDataSetControls.CaptionOptions.Visible := False;
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbViews);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbCards);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbPivots);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbRecordViews);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbTrees);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbCharts);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbSchedulers);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.DbFiles);
        AddDbCtrls(grpDataSetControls, zDiagramDataSet.GisMaps);
        /// ////////////////////////
        /// ///////////////////////
        // Dettagli
        if zDiagramDataSet.HasDetailDataSets then
        begin
          Splitter := CreateSplitter(grpDataSet, zDiagramDataSet.name + 'Details');
          grpDataSetDetails := CreateLayoutGroup(grpDataSet, zDiagramDataSet.name + 'Details', ldTabbed, zDiagramDataSet.Menu.GetCaption);
          dictDataSetGroups.Add(grpDataSetDetails, zDiagramDataSet);

          if zDiagramDataSet.HasMasterDataSet then
          begin
            grpDataSetDetails.AlignHorz := ahRight;
            Splitter.AlignHorz := ahRight;
          end
          else
          begin
            grpDataSetDetails.AlignVert := avBottom;
            Splitter.AlignVert := avBottom;
          end;

          enum(grpDataSetDetails, zDiagramDataSet.DetailDatasets);
        end;
      end;
    end;
  end;

  procedure FixMissing(zDiagramDataSets: TzDiagramDataSets; grpDataModule: TdxLayoutGroup);
  var
    ds: TzDiagramDataSet;
  begin

    for ds in zDiagramDataSets do
    begin
      // stesse condizioni del TreeMenu: visibile e accessibile
      if (not ds.IsLookupDataSet) and ds.Menu.Visible and (ds.ActualAccessLevel <> alNone) and (not dictMenu.ContainsKey(ds.name)) then
        dictMenu.Add(ds.name, grpDataModule);

      if ds.HasDetailDataSets then
        FixMissing(ds.DetailDatasets, grpDataModule);
    end;
  end;

var
  grpDataModule: TdxLayoutGroup;
begin
  SiFormController.EnterMethod(Self, 'CreateLayoutStructure');

  SkipOpenDataSet := True;
  try
    dxLayoutControl.BeginUpdate;
    try
      DestroyControls;
      CreateTreeMenu;
      grpDataModule := CreateLayoutGroup(dxLayoutControl.Items, 'DataModule_' + FormController.zDataModule.name, ldTabbed, 'DM ' + FormController.zDataModule.name);
      enum(grpDataModule, FormController.zDataModule.DataSets);

      // === CONTROLLO DI FIX (ricorsivo) ===
      //
      FixMissing(FormController.zDataModule.DataSets, grpDataModule);
      //
      // ===========================

      FormController.doAfterCreateControls;
      InternalLoadProps;
      Pack;
      InitLayoutGroups;
      FormController.doAfterLayoutControlLoadProps;
    finally
      dxLayoutControl.EndUpdate;
    end;
  finally
    SkipOpenDataSet := False;
  end;
  SiFormController.LeaveMethod(Self, 'CreateLayoutStructure');
end;

procedure TLayoutController.CreateItemControls(CustomItem: TdxCustomLayoutItem; ActivateDataSets: boolean = True);

  function CreateCtrl(item: TdxLayoutItem): TControl;
  var
    DbCtrl: TzDiagramDataSet.TzDiagramCtrl;
  begin
    result := nil;

    if IsDestroying then
      Exit;

    if not dictLayoutItems.TryGetValue(item, DbCtrl) then
      Exit;

    if DbCtrl.zDiagramDataSet.ActualAccessLevel = alNone then
      Exit;

    if DbCtrl.zDiagramDataSet.IsLookupDataSet then
      Exit;

    case DbCtrl.zComponentType of
      ctNull:
        Exit;
      ctView:
        result := CreateDbView(nil, DbCtrl as TzDiagramDataSet.TDbView);
      ctCard:
        result := CreateDbCard(nil, DbCtrl as TzDiagramDataSet.TDbCard);
      ctPivot:
        result := CreateDbPivot(nil, DbCtrl as TzDiagramDataSet.TDbPivot);
      ctRecordView:
        result := CreateDbRecordView(nil, DbCtrl as TzDiagramDataSet.TDbRecordView);
      ctTree:
        result := CreateDbTree(nil, DbCtrl as TzDiagramDataSet.TDbTree);
      ctChart:
        result := CreateDbChart(nil, DbCtrl as TzDiagramDataSet.TDbChart);
      ctScheduler:
        result := CreateDbScheduler(nil, DbCtrl as TzDiagramDataSet.TDbScheduler);
      ctFile:
        begin
          if UseMultiViewer then
            result := CreateViewerFrame(nil, DbCtrl as TzDiagramDataSet.TDbFile)
          else
            result := CreateFileViewer(nil, DbCtrl as TzDiagramDataSet.TDbFile);
        end;
      // ctMap:
      // result := CreateTatukMap(nil, DbCtrl as TzDiagramDataSet.TGisMap);
    end;
  end;

  procedure enumCreateNeededControls(CustomItem: TdxCustomLayoutItem);
  var
    i: Integer;
    Group: TdxLayoutGroup;
    item: TdxLayoutItem;
  begin
    if CustomItem is TdxLayoutItem then
    begin
      item := TdxLayoutItem(CustomItem);

      if item.Control = nil then
      begin
        item.Control := CreateCtrl(item);
        // item.ControlOptions.ShowBorder := True;
      end;
    end
    else
      if CustomItem is TdxLayoutGroup then
      begin
        Group := TdxLayoutGroup(CustomItem);

        if Group.LayoutDirection = ldTabbed then
        begin
          if Group.Count > 0 then
          begin
            if Group.ItemIndex >= 0 then
              enumCreateNeededControls(Group.Items[Group.ItemIndex])
            else
              enumCreateNeededControls(Group.Items[0]);
          end;
        end
        else
        begin
          for i := 0 to Group.Count - 1 do
            enumCreateNeededControls(Group.Items[i]);
        end;
      end;
  end;

begin
  SiFormController.EnterMethod(Self, 'CreateItemControls');
  SiFormController.LogColored(TColors.Fuchsia, 'CreateItemControls');

  // dxLayoutControl.BeginUpdate;
  // try
  CreatingControls := True;
  try
    SkipOpenDataSet := True;
    try
      enumCreateNeededControls(CustomItem);
    finally
      SkipOpenDataSet := False;
    end;
  finally
    CreatingControls := False;
  end;

  Application.ProcessMessages;

  if ActivateDataSets then
    OpenActiveDataSets(CustomItem);
  // finally
  // dxLayoutControl.EndUpdate;
  // end;

  SiFormController.LeaveMethod(Self, 'CreateItemControls');
end;

procedure TLayoutController.CreateControls;
begin
  SiFormController.EnterMethod(Self, 'CreateControls');

  CreateLayoutControl;

  dxLayoutControl.BeginUpdate;
  try
    CreateLayoutStructure;
    CreateItemControls(dxLayoutControl.Items);
  finally
    dxLayoutControl.EndUpdate;
  end;

  LoadTreeMenu;

  SiFormController.LeaveMethod(Self, 'CreateControls');
end;

procedure TLayoutController.CreateLayoutControl;
begin
  SiFormController.EnterMethod(Self, 'CreateLayoutControl');

  if assigned(FdxLayoutControl) then
    Exit;

  FdxLayoutControl := TdxLayoutControl.Create(FormController.GetCtrlOwner);
  dxLayoutControl.name := 'dxLayout';
  dxLayoutControl.Parent := FormController.GetCtrlParent;
  dxLayoutControl.align := alClient;

  dx.InitLayoutControl(dxLayoutControl);

  // Settati da InitLayoutControl
  // dxLayoutControl.CustomizeFormClass := TzLayoutCustomizeForm;
  // dxLayoutControl.CustomizeFormTabbedView := False;
  // dxLayoutControl.OptionsStoring.StoreToIniFile := False;
  // dxLayoutControl.OptionsItem.AutoControlAreaAlignment := True;
  // dxLayoutControl.OptionsItem.AutoControlTabOrders := True;
  // dxLayoutControl.OptionsItem.FocusControlOnItemCaptionClick := True;
  // dxLayoutControl.OptionsItem.SizableHorz := True;
  // dxLayoutControl.OptionsItem.SizableVert := True;
  // dxLayoutControl.BevelInner := bvNone;
  // dxLayoutControl.BevelOuter := bvNone;
  // dxLayoutControl.LayoutLookAndFeel := dx.LayoutLookAndFeelNormal;
  // dxLayoutControl.LookAndFeel := dx.LayoutLookAndFeelNormal;

  dxLayoutControl.OnCustomization := OnCustomization;
  TzLayoutMaintenanceRegistry.RegisterHandler(dxLayoutControl, Self);
  dxLayoutControl.Items.LayoutDirection := ldHorizontal;
  dxLayoutControl.Items.AlignHorz := ahClient;
  dxLayoutControl.Items.AlignVert := avClient;

  // RegisterLayout(Layout);
  SiFormController.LeaveMethod(Self, 'CreateLayoutControl');
end;

function TLayoutController.GetComponent<T>(const DataSetName: string): T;
var
  comp: TComponent;
begin
  result := default (T);
  // implementare
end;

function TLayoutController.GetSelectedDataSet: TzDiagramDataSet;
begin
  result := nil;
  if assigned(TreeMenu) then
    result := TreeMenu.SelectedDataSet;
end;

function TLayoutController.GetSelectedDataSetName: string;
begin
  result := '';
  if assigned(TreeMenu) then
    result := TreeMenu.SelectedDataSetName;
end;

function TLayoutController.IniFileName: string;
var
  Folder: string;
begin
  result := '';

  Folder := FormController.zSystem.ConfigFolder;

  if Folder.IsEmpty then
    Folder := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  if assigned(FormController.zSystem) then
    if assigned(FormController.zDataModule) then
      result := Folder + FormController.zDataModule.name + '.' + dxLayoutControl.name + '.layout';
end;

procedure TLayoutController.InternalLoadProps;
var
  zLayout: TzLayout;
begin
  if ctrlKey then
    Exit;

  zLayout := GetLayoutProps;

  if not assigned(zLayout) then
    Exit;

  dxLayoutControl.BeginUpdate;
  try
    // ApplyToGenerated = True: padre e posizione salvati vanno riapplicati
    // anche ai gruppi strutturali, altrimenti l'ordine deciso
    // dall'amministratore verrebbe ignorato (vedi SaveProps).
    zLayout.Layout.SaveToLayout(dxLayoutControl, True);
    ScaleLayoutToMonitor;
    RiarmaAutoFit(True); // altezze dal dizionario LZ, riscalate: sono quelle di partenza
  finally
    dxLayoutControl.EndUpdate;
  end;

  TranslateGroupCaptions;
end;

function TLayoutController.IsInsidePageControl(CustomItem: TdxCustomLayoutItem): boolean;
var
  p: TdxCustomLayoutItem;
begin
  result := False;

  if CustomItem is TdxLayoutGroup then
    if (TdxLayoutGroup(CustomItem).LayoutDirection = ldTabbed) and (not TdxLayoutGroup(CustomItem).TabbedOptions.HideTabs) then
      Exit(True);

  if CustomItem.Parent <> nil then
    if IsInsidePageControl(CustomItem.Parent) then
      Exit(True);
end;

procedure TLayoutController.LoadFromIni;
begin
  InternalLoadFromIni;
  Pack;
  InitLayoutGroups;
  CreateItemControls(dxLayoutControl.Items);
end;

procedure TLayoutController.OnCustomization(Sender: TObject);
begin
  if not ctrlKey then // se  esploso durante il design non rovina l'lz
    if Sender is TdxLayoutControl then
      if not TdxLayoutControl(Sender).Customization then
      begin
        Screen.Cursor := crHourGlass;
        try
          // se c'e' un'operazione di manutenzione pendente, e' lei a gestire
          // snapshot e persistenza (per il reset salvare ora sarebbe inutile/dannoso)
          if FPendingMaintenanceOp = lmoNone then
            SaveProps;
          // CreateItemControls(dxLayoutControl.Items);

          // CreateControls;
          // dxLayoutControl.BeginUpdate;
          // try
          // CreateLayoutStructure;
          // CreateItemControls(dxLayoutControl.Items);
          // finally
          // dxLayoutControl.EndUpdate;
          // end;

          EnableGoogleMapsHooks;
        finally
          Screen.Cursor := crDefault;
        end;

        // operazioni di manutenzione richieste durante la customizzazione:
        // vengono eseguite dopo il rilascio del form di customize
        if FPendingMaintenanceOp <> lmoNone then
          TThread.ForceQueue(nil, ExecutePendingMaintenance);
      end;
end;

procedure TLayoutController.OpenActiveDataSets(CustomItem: TdxCustomLayoutItem);
  procedure AssignDataSet(item: TdxLayoutItem);
  var
    DbCtrl: TzDiagramDataSet.TzDiagramCtrl;
    zFbDataSet: TzFbDataSet;
    DataSetName: string;
    DbComp: IzBaseDbComponent;
  begin
    SiFormController.LogString('AssignDataSet', item.name);

    if IsDestroying then
      Exit;

    if not assigned(item.Control) then
      Exit;

    if not dictLayoutItems.TryGetValue(item, DbCtrl) then
      Exit;

    zFbDataSet := FormController.GetDataSet(DbCtrl.zDiagramDataSet);
    DataSetName := DbCtrl.zDiagramDataSet.name;

    // Prima il componente, poi l'apertura. Il componente costruisce colonne e
    // filtri sui TField gia' creati da BuildFields in DataSetLoadProps, e i
    // filtri scrivono i valori predefiniti nei parametri: l'apertura che segue
    // e' gia' filtrata, e il costruttore dei filtri, trovando il dataset
    // chiuso, non lo riapre. Con l'ordine precedente (prima ActivateDataSet,
    // poi l'assegnazione) ogni dataset con filtri si apriva due volte, la
    // prima senza condizioni: misurato su Progetti, 20 secondi buttati.
    if Supports(item.Control, IzBaseDbComponent, DbComp) then
    begin
      if DbComp.zDataSet <> zFbDataSet then
      begin
        // Caso residuo: dataset fuori dall'LZ, per cui DataSetLoadProps non ha
        // costruito i TField. Senza campi la griglia non creerebbe colonne.
        if assigned(zFbDataSet) then
          if (zFbDataSet.FieldCount = 0) and not zFbDataSet.Active then
            if assigned(zFbDataSet.DataBase) and zFbDataSet.DataBase.Connected then
              if not zFbDataSet.SelectSQL.Text.Trim.IsEmpty then
                zFbDataSet.BuildFields;

        DbComp.zDataSet := zFbDataSet;
        FormController.doDatasetAssigned(DataSetName, item.Control);
      end;
    end;

    // qualora sia intervenuto dopo il primo test
    if IsDestroying then
      Exit;

    FormController.ActivateDataSet(DbCtrl.zDiagramDataSet);
  end;

  procedure enum(CustomItem: TdxCustomLayoutItem);
  var
    i: Integer;
    Group: TdxLayoutGroup;
    item: TdxLayoutItem;
  begin

    if CustomItem is TdxLayoutItem then
    begin
      item := TdxLayoutItem(CustomItem);
      AssignDataSet(item);
    end
    else
      if CustomItem is TdxLayoutGroup then
      begin
        Group := TdxLayoutGroup(CustomItem);

        if Group.LayoutDirection = ldTabbed then
        begin
          if Group.Count > 0 then
          begin
            if Group.ItemIndex >= 0 then
              enum(Group.Items[Group.ItemIndex])
            else
              enum(Group.Items[0]);
          end;
        end
        else
        begin
          for i := 0 to Group.Count - 1 do
            enum(Group.Items[i]);
        end;
      end;
  end;

begin
  SiFormController.EnterMethod(Self, 'OpenActiveDataSets');

  if not SkipOpenDataSet then
    if not IsDestroying then
      enum(CustomItem);

  SiFormController.LeaveMethod(Self, 'OpenActiveDataSets');
end;

procedure TLayoutController.LayoutItemRemoved(CustomLayoutItem: TdxCustomLayoutItem);
var
  Group: TdxLayoutGroup;
  item: TdxLayoutItem;
  pair: TPair<string, TdxLayoutGroup>;
  key: string;
begin
  // se un elemento viene eliminato dalle varie procedure (pack, assignFromLayout, etc
  // si devono sincronizzare le liste relative

  if IsDestroying then
    Exit;

  if CustomLayoutItem is TdxLayoutGroup then
  begin
    Group := TdxLayoutGroup(CustomLayoutItem);

    key := '';
    for pair in dictMenu do
      if pair.Value = Group then
      begin
        key := pair.key;
        break;
      end;

    if key <> '' then
      dictMenu.Remove(key);

    dictDataSetGroups.Remove(Group);
  end
  else
    if CustomLayoutItem is TdxLayoutItem then
    begin
      item := TdxLayoutItem(CustomLayoutItem);

      if dictLayoutItems.ContainsKey(item) then
        dictLayoutItems.Remove(item);
    end;
end;

procedure TLayoutController.SetImages(const Value: TCustomImageList);
begin
  FImages := Value;
  dxLayoutControl.OptionsImage.Images := Images;
end;

procedure TLayoutController.SetSelectedDataSetName(const Value: string);
begin
  if assigned(TreeMenu) then
    TreeMenu.SelectedDataSetName := Value;
end;

procedure TLayoutController.TabChanging(Sender: TObject; ANewTabIndex: Integer; var Allow: boolean);
var
  Group: TdxLayoutGroup;
begin
  SiFormController.EnterMethod(Self, 'TabChanging');;

  if Sender is TdxLayoutGroup then
  begin
    Group := TdxLayoutGroup(Sender);

    if Group.LayoutDirection = ldTabbed then
      if not Group.TabbedOptions.HideTabs then
      begin
        SiFormController.LogColored(TColors.Bisque, 'TabChanging');

        if not CreatingControls then
          CreateItemControls(Group.Items[ANewTabIndex]);

        if assigned(FTabChangingProc) then
          Allow := TabChangingProc(Group, ANewTabIndex);
      end;
  end;

  SiFormController.LeaveMethod(Self, 'TabChanging');
end;

procedure TLayoutController.TabChanged(Sender: TObject);
var
  Group: TdxLayoutGroup;
begin
  SiFormController.EnterMethod(Self, 'TabChanged');;

  // se chiamato da codice non chiama Changing
  if Sender is TdxLayoutGroup then
  begin
    Group := TdxLayoutGroup(Sender);

    if Group.LayoutDirection = ldTabbed then
      if not Group.TabbedOptions.HideTabs then
      begin
        SiFormController.LogColored(TColors.Bisque, 'TabChanged');

        if not CreatingControls then
          CreateItemControls(Group.Items[Group.ItemIndex]);

        if assigned(FTabChangedProc) then
          TabChangedProc(Group);
      end;
  end;

  SiFormController.LeaveMethod(Self, 'TabChanged');
end;

procedure TLayoutController.TreeWidthChanged(Sender: TObject; const NewWidth: Integer);
var
  item: TdxLayoutItem;
begin
  item := dxLayoutControl.FindItem(TreeMenu) as TdxLayoutItem;

  if assigned(item) then
    if assigned(item.Parent) then
      item.Parent.SizeOptions.Width := NewWidth; // + 20; // Calcolarlo
end;

procedure TLayoutController.Translated;
var
  oldSkipSelectFirstNode: boolean;
begin
  if assigned(TreeMenu) then
  begin
    SiFormController.LogVerbose('Translated');

    oldSkipSelectFirstNode := FSkipSelectFirstNode;
    FSkipSelectFirstNode := False;
    try
      TreeMenu.Translated;
    finally
      FSkipSelectFirstNode := oldSkipSelectFirstNode;
    end;
  end;

  TranslateGroupCaptions;
end;

procedure TLayoutController.MakeVisible(const name: string);
var
  Group: TdxLayoutGroup;
begin
  SiFormController.EnterMethod(Self, 'MakeVisible - 1');
  SiFormController.LogColored(TColors.Blueviolet, 'MakeVisible(const name: string)');

  Group := Nil;
  if dictMenu.TryGetValue(Name, Group) then
  begin
    if Group is TdxLayoutGroup then // 16.11.2016 arriva roba del cavolo...
      if Group.Container <> nil then
        if assigned(Group.ViewInfo) then
          if assigned(Group.ViewInfo.ParentViewInfo) then
          // if assigned(Group.ViewInfo.ParentViewInfo.ViewData) then
          begin
            try
              Group.MakeVisible;
              TdxLayoutControlAccess(dxLayoutControl).LeftPos := 0;
            except
              // da av, al momento nascondo il messaggio
              on e: exception do
              begin
                siMain.logException(e);
                siMain.LogString('Stack', e.StackTrace);
              end;
            end;
          end;

    CreateItemControls(dxLayoutControl.Items);
  end;
  SiFormController.LeaveMethod(Self, 'MakeVisible - 1');
end;

procedure TLayoutController.MakeVisible(Control: TControl);
  procedure Expand(AItem: TdxLayoutItem);
  var
    AParent: TdxCustomLayoutGroup;
  begin
    AParent := AItem.Parent;
    while (AParent <> nil) do
    begin
      AParent.Expanded := True;
      AParent := AParent.Parent;
    end;
  end;

var
  dxLayoutItem: TdxLayoutItem;
begin
  SiFormController.EnterMethod(Self, 'MakeVisible - 2');
  SiFormController.LogColored(TColors.Blueviolet, 'MakeVisible(Control: TControl)');

  dxLayoutItem := dxLayoutControl.FindItem(Control);

  if assigned(dxLayoutItem) then
  begin
    try
      Expand(dxLayoutItem);
      dxLayoutItem.MakeVisible;
      TdxLayoutControlAccess(dxLayoutControl).LeftPos := 0;
      CreateItemControls(dxLayoutItem);
    except
      // da av, al momento nascondo il messaggio
      on e: exception do
      begin
        siMain.logException(e);
        siMain.LogString('Stack', e.StackTrace);
      end;
    end;
  end;

  SiFormController.LeaveMethod(Self, 'MakeVisible - 2');
end;

procedure TLayoutController.TreeSelected(Sender: TObject);
begin
  if not IsDestroying then
  begin
    SiFormController.LogVerbose('TreeSelected: ' + TreeMenu.Selected);

    MakeVisible(TreeMenu.Selected);
    FormController.doSelect;
  end;
end;

procedure TLayoutController.LoadTreeMenu;
begin
  if assigned(TreeMenu) then
  begin
    SiFormController.LogVerbose('LoadTreeMenu');

    TreeMenu.LoadMenu;

    if not SkipSelectFirstNode then
      TreeSelected(nil);
  end;
end;

procedure TLayoutController.ResetItemSize;
var
  i: Integer;
  item: TdxCustomLayoutItem;
begin

  if assigned(dxLayoutControl) then
    for i := 0 to dxLayoutControl.AbsoluteItemCount - 1 do
    begin
      item := dxLayoutControl.AbsoluteItems[i];

      item.SizeOptions.Width := 0;
      item.SizeOptions.height := 0;
    end;
end;

procedure TLayoutController.TranslateGroupCaptions;
var
  Caption: string;
  pairGroup: TPair<TdxLayoutGroup, TzDiagramDataSet>;
  pairItem: TPair<TdxLayoutItem, TzDiagramDataSet.TzDiagramCtrl>;
  NameSpace: String;
  ResourceName: string;
begin
  SiFormController.EnterMethod(Self, 'TranslateGroupCaptions');

  if not assigned(dxLayoutControl) then
    Exit;

  dxLayoutControl.BeginUpdate;
  try
    for pairGroup in dictDataSetGroups do
    begin
      // pairGroup.key.Caption := pairGroup.Value.Menu.GetCaption;
      NameSpace := ClassNameSpace(pairGroup.Value.ClassType, pairGroup.Value.name);
      ResourceName := FullResourceName(NameSpace, '', 'Titolo', 'Caption');
      Caption := Localizer.GetTranslation(ResourceName, pairGroup.key.Caption);
      pairGroup.key.Caption := Caption;
    end;

    for pairItem in dictLayoutItems do
    begin
      NameSpace := ClassNameSpace(pairItem.Value.ClassType, pairItem.Value.name);
      ResourceName := FullResourceName(NameSpace, '', 'Titolo', 'Caption');
      Caption := Localizer.GetTranslation(ResourceName, pairItem.key.Caption);
      pairItem.key.Caption := Caption;
    end;
  finally
    dxLayoutControl.EndUpdate;
  end;

  SiFormController.LeaveMethod(Self, 'TranslateGroupCaptions');
end;

// Mantis #155 - 2026-09-22: un gruppo e' stato reso a video solo se almeno uno
// dei suoi discendenti visibili ospita davvero un controllo. I controlli
// nascono a richiesta (CreateItemControls -> enumCreateNeededControls) e per un
// gruppo a schede viene popolata la sola scheda attiva: tutte le altre restano
// con Control = nil e hanno come dimensione naturale quella della sola
// intestazione, dai 20 ai 28 pixel. Salvare quel numero vincola il pannello a
// restare schiacciato a ogni riapertura successiva.
function TLayoutController.HasRenderedContent(CustomItem: TdxCustomLayoutItem): boolean;
var
  i: Integer;
  Group: TdxCustomLayoutGroup;
begin
  result := False;

  if not assigned(CustomItem) then
    Exit;

  if CustomItem is TdxLayoutItem then
    Exit(assigned(TdxLayoutItem(CustomItem).Control));

  if CustomItem is TdxCustomLayoutGroup then
  begin
    Group := TdxCustomLayoutGroup(CustomItem);

    for i := 0 to Group.VisibleCount - 1 do
      if HasRenderedContent(Group.VisibleItems[i]) then
        Exit(True);
  end;
end;

// Mantis #155 - 2026-09-22: soglia di plausibilita' dipendente dal tipo di
// elemento. Un elemento semplice puo' legittimamente essere stretto (una
// casella di spunta, un campo breve); un gruppo che contiene una griglia o un
// pannello di dettaglio no.
function TLayoutController.IsSizePlausible(CustomItem: TdxCustomLayoutItem; Size: Integer): boolean;
begin
  if CustomItem is TdxCustomLayoutGroup then
    result := Size >= MIN_VALID_GROUP_SIZE
  else
    result := Size >= MIN_VALID_SIZE;
end;

// Risoluzione per form 2026-09-22: stessa sequenza gia' ripetuta in SaveToIni,
// InternalLoadFromIni e ScaleLayoutToMonitor. Qui in un posto solo, per non
// aggiungere una quarta copia.
function TLayoutController.CurrentMonitor: TMonitor;
begin
  if assigned(dxLayoutControl) and dxLayoutControl.HandleAllocated then
    result := Screen.MonitorFromWindow(dxLayoutControl.Handle)
  else
    if assigned(Application.MainForm) then
      result := Screen.MonitorFromWindow(Application.MainForm.Handle)
    else
      result := Screen.PrimaryMonitor;
end;

// Risoluzione per form 2026-09-22: la base rispetto a cui scalare le
// dimensioni lette dall'LZ. Si preferisce la risoluzione registrata su QUESTA
// form al momento in cui e' stata redatta; se manca — LZ prodotto prima di
// questa modifica — si ricade sulle costanti, cioe' sul comportamento
// precedente.
procedure TLayoutController.GetDesignResolution(out BaseWidth, BaseHeight: Integer);
var
  zLayout: TzLayout;
begin
  BaseWidth := FormController.DesignWidth;
  BaseHeight := FormController.DesignHeight;

  zLayout := GetLayoutProps;

  if not assigned(zLayout) then
    Exit;

  // Entrambe le dimensioni devono essere plausibili: una coppia a meta' non
  // descrive nessun monitor e non e' una base valida.
  if (zLayout.DesignWidth >= MIN_VALID_MONITOR_WIDTH) and (zLayout.DesignHeight >= MIN_VALID_MONITOR_HEIGHT) then
  begin
    BaseWidth := zLayout.DesignWidth;
    BaseHeight := zLayout.DesignHeight;
  end;
end;

procedure TLayoutController.SaveToIni;
var
  ini: TIniFile;
  item: TdxCustomLayoutItem;
  i: Integer;
  Monitor: TMonitor;
  RevertedVal: Integer;
begin
  ini := TIniFile.Create(IniFileName);
  try
    try
      if dxLayoutControl.HandleAllocated then
        Monitor := Screen.MonitorFromWindow(dxLayoutControl.Handle)
      else
        if assigned(Application.MainForm) then
          Monitor := Screen.MonitorFromWindow(Application.MainForm.Handle)
        else
          Monitor := Screen.PrimaryMonitor;

      if assigned(Monitor) then
      begin
        ini.WriteInteger('_System_', 'SavedMonitorWidth', Monitor.Width);
        ini.WriteInteger('_System_', 'SavedMonitorHeight', Monitor.height);
      end;

      // Mantis #310 - 2026-10-30: i valori sotto sono "ripristinati" a 96 PPI, mentre
      // SavedMonitorWidth/Height sono pixel fisici del monitor. Alla lettura serve il
      // PPI in cui si lavorava per ricostruire i pixel fisici di allora
      ini.WriteInteger('_System_', 'SavedPPI', dxLayoutControl.CurrentPPI);

      for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
      begin
        item := dxLayoutControl.AbsoluteItems[i];

        // Mantis #155 - 2026-09-22: un gruppo mai popolato non ha una
        // dimensione da salvare. Non si scrive niente e il valore gia'
        // presente nel file resta dov'e': TIniFile sovrascrive le sole chiavi
        // che le vengono passate, quindi saltare la scrittura equivale a
        // conservare la personalizzazione precedente dell'utente.
        if not(item is TdxLayoutSplitterItem) and HasRenderedContent(item) then
        begin
          if item.SizeOptions.Width >= MIN_VALID_SIZE then
            if not(item.AlignHorz in [ahClient, ahParentManaged]) then
            begin
              RevertedVal := TdxCustomLayoutItemAccess(item).ScaleFactor.Revert(item.SizeOptions.Width);
              // Mantis #155 - 2026-09-22: soglia per tipo di elemento.
              if IsSizePlausible(item, RevertedVal) then
                ini.WriteInteger(item.name, 'Width', RevertedVal);
            end;

          // AltezzaDaSalvare: i dettagli adattati a una card si salvano
          // all'altezza scelta dall'utente, non a quella della card
          if AltezzaDaSalvare(item) >= MIN_VALID_SIZE then
            if not(item.AlignVert in [avClient, avParentManaged]) then
            begin
              RevertedVal := TdxCustomLayoutItemAccess(item).ScaleFactor.Revert(AltezzaDaSalvare(item));
              if IsSizePlausible(item, RevertedVal) then
                ini.WriteInteger(item.name, 'Height', RevertedVal);
            end;
        end;
      end;
    except
    end;
  finally
    FreeAndNil(ini);
  end;
end;

procedure TLayoutController.InternalLoadFromIni;
var
  ini: TIniFile;
  sections: TStringList;
  section: string;
  item: TdxCustomLayoutItem;
  Value: Integer;
  invalidCount: Integer;
  ScaledVal: Integer;

  // Nuove variabili per lo scaling multimonitor
  Monitor: TMonitor;
  SavedMonitorWidth, SavedMonitorHeight: Integer;
  SavedPPI: Integer;
  ScaleX, ScaleY: Double;

  procedure MigrateLegacyIniFileName;
  var
    newName, oldName: string;
  begin
    newName := IniFileName;
    // vecchio nome con lo spazio errato prima dell'estensione
    oldName := ChangeFileExt(newName, '') + ' .layout';

    if (oldName <> newName) and System.SysUtils.FileExists(oldName) then
    begin
      if System.SysUtils.FileExists(newName) then
        System.SysUtils.DeleteFile(oldName) // il nuovo esiste gia': scarto il vecchio
      else
        System.SysUtils.RenameFile(oldName, newName);
    end;
  end;

begin
  if not assigned(dxLayoutControl) then
    Exit;

  MigrateLegacyIniFileName; // rimuovi questa riga se non usi la Patch 1b

  invalidCount := 0;

  if dxLayoutControl.HandleAllocated then
    Monitor := Screen.MonitorFromWindow(dxLayoutControl.Handle)
  else
    if assigned(Application.MainForm) then
      Monitor := Screen.MonitorFromWindow(Application.MainForm.Handle)
    else
      Monitor := Screen.PrimaryMonitor;

  dxLayoutControl.BeginUpdate;
  try
    ini := TIniFile.Create(IniFileName);
    try
      SavedMonitorWidth := ini.ReadInteger('_System_', 'SavedMonitorWidth', FormController.DesignWidth);
      SavedMonitorHeight := ini.ReadInteger('_System_', 'SavedMonitorHeight', FormController.DesignHeight);

      if assigned(Monitor) and (Monitor.Width > 0) and (Monitor.height > 0) and (SavedMonitorWidth > 0) and (SavedMonitorHeight > 0) then
      begin
        ScaleX := Monitor.Width / SavedMonitorWidth;
        ScaleY := Monitor.height / SavedMonitorHeight;
      end
      else
      begin
        ScaleX := 1.0;
        ScaleY := 1.0;
      end;

      // Mantis #310 - 2026-10-30: i valori del file sono a 96 PPI (SaveToIni li
      // ripristina con ScaleFactor.Revert), SizeOptions.Width/Height invece sono
      // pixel fisici e il rapporto fra monitor e' fra pixel fisici. Salvato a 192
      // PPI (portatile a 2880x1920 al 200% in desktop remoto) un valore salvato di
      // 300 corrisponde a 600 pixel fisici: riletto come 300 il pannello si
      // dimezzava a ogni apertura. Si moltiplica per PPI salvato / 96 per tornare
      // ai pixel fisici di allora prima di applicare il rapporto fra monitor. Un file
      // scritto prima non ha SavedPPI e vale 96, cioe' il comportamento di prima.
      SavedPPI := ini.ReadInteger('_System_', 'SavedPPI', 96);
      if SavedPPI > 0 then
      begin
        ScaleX := ScaleX * SavedPPI / 96;
        ScaleY := ScaleY * SavedPPI / 96;
      end;

      sections := TStringList.Create;
      try
        ini.ReadSections(sections);

        for section in sections do
        begin
          if section = '_System_' then
            Continue;

          item := dxLayoutControl.FindItem(section);

          if assigned(item) then
            if not(item is TdxLayoutSplitterItem) then
            begin
              // Width: stessa condizione di SaveToIni. Un item "client" non ha
              // una larghezza propria: una sezione vecchia gli imporrebbe un
              // limite e lo spazio residuo finirebbe agli altri item del gruppo.
              if not(item.AlignHorz in [ahClient, ahParentManaged]) then
              begin
                Value := ini.ReadInteger(section, 'Width', 0);

                // Mantis #155 - 2026-09-22: la soglia dipende dal tipo di
                // elemento. Prima era MIN_VALID_SIZE per tutti, e i gruppi di
                // dettaglio salvati a 20-28 px la superavano di un soffio:
                // il file non veniva mai dichiarato degenere e la form restava
                // inutilizzabile a ogni apertura.
                if IsSizePlausible(item, Value) then
                begin
                  ScaledVal := Round(Value * ScaleX);

                  // Il gruppo del tree non scende sotto la larghezza calcolata da
                  // TzTreeMenu (best fit, minimo 50): un valore piccolo salvato nel
                  // file personale riduceva il tree alla sola colonna delle icone.
                  if assigned(TreeMenu) and SameText(section, GroupName('TreeMenu')) then
                    ScaledVal := Max(ScaledVal, TreeMenu.Width);

                  if IsSizePlausible(item, ScaledVal) then
                    item.SizeOptions.Width := ScaledVal;
                end
                else
                  if Value > 0 then
                    Inc(invalidCount); // Mantis #155: sotto la soglia del suo tipo, scartato
              end;

              /// ////////////////////////
              // Height
              if not(item.AlignVert in [avClient, avParentManaged]) then
              begin
                Value := ini.ReadInteger(section, 'Height', 0);

                // Mantis #155 - 2026-09-22: stessa soglia per tipo applicata
                // all'altezza.
                if IsSizePlausible(item, Value) then
                begin
                  ScaledVal := Round(Value * ScaleY);
                  if IsSizePlausible(item, ScaledVal) then
                    item.SizeOptions.height := ScaledVal;
                end
                else
                  if Value > 0 then
                    Inc(invalidCount);
              end;
            end;
        end;
      finally
        FreeAndNil(sections);
      end;
    finally
      FreeAndNil(ini);
    end;
  finally
    dxLayoutControl.EndUpdate;
  end;

  // File degenere: lo elimino cosi' non ricapita al prossimo avvio e il
  // layout riparte dalle dimensioni di default.
  if invalidCount > 0 then
  begin
    SiFormController.LogWarning('InternalLoadFromIni: %d dimensioni non valide ignorate nel file "%s". File rimosso.', [invalidCount, IniFileName]);
    System.SysUtils.DeleteFile(IniFileName);
  end;

  // Le altezze appena lette sono quelle dell'utente: non e' il divisore
  RiarmaAutoFit(True);
end;

procedure TLayoutController.ScaleLayoutToMonitor;
var
  i: Integer;
  item: TdxCustomLayoutItem;
  Monitor: TMonitor;
  ScaleX, ScaleY: Double;
  BaseWidth, BaseHeight: Integer; // Risoluzione per form 2026-09-22
begin
  if not assigned(dxLayoutControl) then
    Exit;

  Monitor := CurrentMonitor;

  if not assigned(Monitor) then
    Exit;

  // Risoluzione per form 2026-09-22: la base non e' piu' la costante
  // 1920x1200, ma la risoluzione con cui QUESTA form e' stata redatta, se
  // registrata nell'LZ. Con un LZ prodotto prima di questa modifica
  // GetDesignResolution restituisce le costanti e il comportamento resta
  // identico a prima.
  GetDesignResolution(BaseWidth, BaseHeight);

  if (BaseWidth <= 0) or (BaseHeight <= 0) then
    Exit;

  ScaleX := Monitor.Width / BaseWidth;
  ScaleY := Monitor.height / BaseHeight;

  if (ScaleX = 1.0) and (ScaleY = 1.0) then
    Exit;

  dxLayoutControl.BeginUpdate;
  try
    for i := 0 to dxLayoutControl.AbsoluteItemCount - 1 do
    begin
      item := dxLayoutControl.AbsoluteItems[i];
      if not(item is TdxLayoutSplitterItem) then
      begin
        if item.SizeOptions.Width >= MIN_VALID_SIZE then
          item.SizeOptions.Width := Max(MIN_VALID_SIZE, Round(item.SizeOptions.Width * ScaleX));

        if item.SizeOptions.height >= MIN_VALID_SIZE then
          item.SizeOptions.height := Max(MIN_VALID_SIZE, Round(item.SizeOptions.height * ScaleY));
      end;
    end;
  finally
    dxLayoutControl.EndUpdate;
  end;
end;

procedure TLayoutController.CheckControlDimensions;
var
  i: Integer;
  item: TdxCustomLayoutItem;
  h, w: Integer;
begin

  if not IsContainerReady then
    Exit;

  dxLayoutControl.BeginUpdate;
  try
    for i := dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
    begin
      item := dxLayoutControl.AbsoluteItems[i];

      // gli splitter non hanno dimensioni proprie: esclusi come in
      // SaveToIni, InternalLoadFromIni e ScaleLayoutToMonitor
      if item is TdxLayoutSplitterItem then
        Continue;

      if assigned(item.Parent) then
      begin

        if item.SizeOptions.Width > 0 then
        begin
          w := 150;
          // Gruppo padre senza ViewInfo (non ancora disposto): come per l'altezza
          // si salta, altrimenti violazione di accesso all'apertura (R-016)
          if assigned(item.Parent.ViewInfo) then
            if item.Parent.ViewInfo.ItemsAreaBounds.Width - item.SizeOptions.Width < w then
              item.SizeOptions.Width := Max(MIN_VALID_SIZE, item.Parent.ViewInfo.ItemsAreaBounds.Width - w);
        end;

        if item.SizeOptions.height > 0 then
        begin
          // SiFormController.LogVerbose('CheckControlDimensions: ' + i.ToString);
          h := 150;

          if assigned(item.Parent.ViewInfo) then
            if item.Parent.ViewInfo.ItemsAreaBounds.height - item.SizeOptions.height < h then
              item.SizeOptions.height := Max(MIN_VALID_SIZE, item.Parent.ViewInfo.ItemsAreaBounds.height - h);
        end;
      end;
    end;
  finally
    dxLayoutControl.EndUpdate;
  end;

  // Una correzione di questo controllo non e' il divisore mosso dall'utente
  RiarmaAutoFit(False);
end;

function TLayoutController.FindAutoFitGruppo(Card: TzDbCard; out Segno: Integer): TdxLayoutGroup;
// Gruppo che decide l'altezza della card. La card e' un elemento del gruppo a
// linguette <ds>Controls, che con il divisore e <ds>Details sta nel gruppo
// verticale del dataset (CreateLayoutStructure). Uno dei due ha un'altezza
// propria, l'altro prende il resto:
// - disposizione generata: Controls avClient, Details avBottom con l'altezza:
//   si cambia Details in senso opposto alla card (Segno -1);
// - disposizione personalizzata nel dizionario (es. PersonaleScheda): Controls
//   in alto con l'altezza e Details avClient: si cambia Controls (Segno +1).
// Dataset di dettaglio (gruppo orizzontale, dettagli a destra), card accanto
// alla vista (Controls orizzontale) o nessun gruppo con un'altezza: nil.
var
  item: TdxLayoutItem;
  grpControls, grpDataSet: TdxCustomLayoutGroup;
  Fratello: TdxCustomLayoutItem;
  i: Integer;
begin
  result := nil;
  Segno := 0;

  item := dxLayoutControl.FindItem(Card);
  if not assigned(item) then
    Exit;

  grpControls := item.Parent;
  if not(grpControls is TdxLayoutGroup) or (grpControls.LayoutDirection <> ldTabbed) then
    Exit;
  if not dictDataSetGroups.ContainsKey(TdxLayoutGroup(grpControls)) then
    Exit;

  grpDataSet := grpControls.Parent;
  if not assigned(grpDataSet) or (grpDataSet.LayoutDirection <> ldVertical) then
    Exit;

  if grpControls.AlignVert <> avClient then
  begin
    Segno := +1;
    Exit(TdxLayoutGroup(grpControls));
  end;

  for i := 0 to grpDataSet.Count - 1 do
  begin
    Fratello := grpDataSet.Items[i];
    if (Fratello <> grpControls) and (Fratello is TdxLayoutGroup) and Fratello.Visible and (Fratello.AlignVert = avBottom) then
      if dictDataSetGroups.ContainsKey(TdxLayoutGroup(Fratello)) then
      begin
        Segno := -1;
        Exit(TdxLayoutGroup(Fratello));
      end;
  end;
end;

procedure TLayoutController.CardAutoFitHeight(Sender: TzDbCard; const Altezza: Integer; const Mostrata: boolean);
// AutoFitHeight di una card del FormController (TzDbCard.ApplyAutoFitHeight).
// Si cambia l'altezza del gruppo che la decide (FindAutoFitGruppo) della
// differenza fra l'altezza voluta e quella che la card ha ora: in piu' se il
// gruppo e' <ds>Controls, in meno se sono i dettagli sotto. Lavorare sulla
// differenza comprende anche l'intestazione delle linguette, se visibili.
//
// L'altezza scelta dall'utente (divisore, file .layout) resta
// sua: si ricorda quando la card compare, si rimette quando la card si nasconde
// (ritorno alla vista) e SaveToIni salva quella (AltezzaDaSalvare). Se l'utente
// sposta il divisore con la card visibile, per quel dataset l'adattamento si
// sospende fino alla chiusura della form, come nel rilascio 002 per il
// TdxLayoutControl semplice.
const
  MIN_GRUPPO = 100; // altezza minima del gruppo adattato
  MIN_ALTRI = 150; // spazio minimo lasciato all'altro gruppo: lo stesso di CheckControlDimensions
  SOGLIA_PX = 3; // differenze minori non valgono un ridisegno
var
  Stato: TAutoFitDettagli;
  Coppia: TPair<TzDbCard, TAutoFitDettagli>;
  Gruppo: TdxLayoutGroup;
  Segno: Integer;
  Base, Area, Nuova: Integer;
begin
  if IsDestroying or not assigned(dictAutoFit) or not assigned(dxLayoutControl) then
    Exit;
  if csDestroying in dxLayoutControl.ComponentState then
    Exit;

  if not Mostrata then
  begin
    if dictAutoFit.TryGetValue(Sender, Stato) and Stato.Attivo then
    begin
      if not Stato.Sospeso then
      begin
        dxLayoutControl.BeginUpdate;
        try
          Stato.Gruppo.SizeOptions.height := Stato.AltezzaUtente;
        finally
          dxLayoutControl.EndUpdate;
        end;
      end;
      Stato.Attivo := False;
      Stato.AltezzaApplicata := -1;
      dictAutoFit[Sender] := Stato;
    end;
    Exit;
  end;

  if dxLayoutControl.Customization then
    Exit; // editor visuale aperto: non toccare il layout sotto i piedi

  if not dictAutoFit.TryGetValue(Sender, Stato) then
  begin
    Gruppo := FindAutoFitGruppo(Sender, Segno);
    if not assigned(Gruppo) then
      Exit;
    Stato.Gruppo := Gruppo;
    Stato.Segno := Segno;
    Stato.AltezzaUtente := Gruppo.SizeOptions.height;
    Stato.AltezzaApplicata := -1;
    Stato.Attivo := False;
    Stato.Sospeso := False;
  end;

  if Stato.Sospeso then
    Exit;

  if not Stato.Attivo then
  begin
    // La card compare: l'altezza attuale del gruppo e' quella dell'utente,
    // salvo che un'altra card dello stesso dataset non lo tenga ancora adattato
    Stato.AltezzaUtente := Stato.Gruppo.SizeOptions.height;
    for Coppia in dictAutoFit do
      if (Coppia.Key <> Sender) and Coppia.Value.Attivo and (Coppia.Value.Gruppo = Stato.Gruppo) then
        Stato.AltezzaUtente := Coppia.Value.AltezzaUtente;
    Stato.AltezzaApplicata := -1;
  end
  else
    if (Stato.AltezzaApplicata >= 0) and (Stato.Gruppo.SizeOptions.height <> Stato.AltezzaApplicata) then
    begin
      // Altezza cambiata da fuori con la card visibile: il divisore
      Stato.Sospeso := True;
      Stato.AltezzaUtente := Stato.Gruppo.SizeOptions.height;
      dictAutoFit.AddOrSetValue(Sender, Stato);
      Exit;
    end;

  if not assigned(Stato.Gruppo.ViewInfo) or not assigned(Stato.Gruppo.Parent) or not assigned(Stato.Gruppo.Parent.ViewInfo) then
  begin
    dictAutoFit.AddOrSetValue(Sender, Stato);
    Exit; // gruppo non ancora disposto: si riprova al prossimo cmd_Resize della card
  end;

  Base := Stato.Gruppo.SizeOptions.height;
  if Base <= 0 then
    Base := Stato.Gruppo.ViewInfo.Bounds.height; // gruppo alla sua altezza naturale
  Area := Stato.Gruppo.Parent.ViewInfo.ItemsAreaBounds.height;

  Nuova := Base + Stato.Segno * (Altezza - Sender.height);
  Nuova := Min(Nuova, Area - MIN_ALTRI);
  Nuova := Max(Nuova, MIN_GRUPPO);

  if Abs(Nuova - Stato.Gruppo.SizeOptions.height) > SOGLIA_PX then
  begin
    dxLayoutControl.BeginUpdate;
    try
      Stato.Gruppo.SizeOptions.height := Nuova;
    finally
      dxLayoutControl.EndUpdate;
    end;
  end;

  Stato.AltezzaApplicata := Stato.Gruppo.SizeOptions.height;
  Stato.Attivo := True;
  dictAutoFit.AddOrSetValue(Sender, Stato);
end;

procedure TLayoutController.RiarmaAutoFit(const NuovaAltezzaUtente: boolean);
// Altezze dei gruppi cambiate dal FormController (file .layout, dizionario LZ,
// CheckControlDimensions) con una card adattata visibile: non e' il divisore e
// non deve sospendere. Si riprende il riferimento e si rifa' l'adattamento.
var
  Cards: TArray<TzDbCard>;
  Card: TzDbCard;
  Stato: TAutoFitDettagli;
begin
  if IsDestroying or not assigned(dictAutoFit) then
    Exit;

  Cards := dictAutoFit.Keys.ToArray;
  for Card in Cards do
  begin
    Stato := dictAutoFit[Card];
    if Stato.Attivo and not Stato.Sospeso then
    begin
      if NuovaAltezzaUtente then
        Stato.AltezzaUtente := Stato.Gruppo.SizeOptions.height;
      Stato.AltezzaApplicata := -1;
      dictAutoFit[Card] := Stato;
      Card.RichiediAutoFitHeight;
    end;
  end;
end;

function TLayoutController.AltezzaDaSalvare(CustomItem: TdxCustomLayoutItem): Integer;
// SizeOptions.Height da salvare nel file .layout: per il gruppo adattato a una
// card visibile e' l'altezza scelta dall'utente, non quella della card
var
  Stato: TAutoFitDettagli;
begin
  result := CustomItem.SizeOptions.height;

  if assigned(dictAutoFit) then
    for Stato in dictAutoFit.Values do
      if Stato.Attivo and not Stato.Sospeso and (Stato.Gruppo = CustomItem) then
        Exit(Stato.AltezzaUtente);
end;

procedure TLayoutController.ClearPersistedLayout;
var
  zLayout: TzLayout;
begin
  zLayout := GetLayoutProps;
  if assigned(zLayout) then
    zLayout.DefaultProps; // svuota l'LZ: niente overlay al prossimo CreateControls
end;

procedure TzFormController.AfterResize;
begin
  TimerCheckControlDimensions.Enabled := False;

  if False then // AV <====================================
    if LayoutController.FormController.zDataModule.BuildGUI then
      TimerCheckControlDimensions.Enabled := True;
end;

procedure TzFormController.AfterShow;
begin
  SiFormController.EnterMethod(Self, 'AfterShow');

  TimerCheckControlDimensions.Enabled := False;

  LayoutController.InternalLoadFromIni;

  if LayoutController.FormController.zDataModule.BuildGUI then
    TimerCheckControlDimensions.Enabled := True;

  SiFormController.LeaveMethod(Self, 'AfterShow');
end;

procedure TzFormController.doAfterLayoutControlLoadProps;
begin
  if assigned(FonAfterLayoutControlLoadProps) then
    FonAfterLayoutControlLoadProps(Self);
end;

procedure TzFormController.TimerCheckControlDimensionsTimer(Sender: TObject);
begin
  TimerCheckControlDimensions.Enabled := False;
  LayoutController.CheckControlDimensions;
end;

function LayoutDesignResolutionReport(zDataModules: TzDataModules; const RefWidth, RefHeight: Integer): string;
var
  i, j: Integer;
  zDataModule: TzDataModule;
  zLayout: TzLayout;
  Righe: TStringList;
  Deviate, NonRegistrate, Totale: Integer;
begin
  Righe := TStringList.Create;
  try
    Deviate := 0;
    NonRegistrate := 0;
    Totale := 0;

    if assigned(zDataModules) then
      for i := 0 to zDataModules.Count - 1 do
      begin
        zDataModule := zDataModules[i];

        if not assigned(zDataModule) then
          Continue;

        for j := 0 to zDataModule.Layouts.Count - 1 do
        begin
          zLayout := zDataModule.Layouts[j];

          if not assigned(zLayout) then
            Continue;

          Inc(Totale);

          // Un layout senza voci non descrive niente: non vale la pena
          // segnalarlo, non e' mai stato personalizzato.
          if zLayout.Layout.Count = 0 then
            Continue;

          if (zLayout.DesignWidth <= 0) or (zLayout.DesignHeight <= 0) then
          begin
            Inc(NonRegistrate);
            Righe.Add(Format('  %-40s  non registrata (redatta prima della modifica del 2026-09-22)', [zDataModule.name + '.' + zLayout.name]));
          end
          else
            if (zLayout.DesignWidth <> RefWidth) or (zLayout.DesignHeight <> RefHeight) then
            begin
              Inc(Deviate);
              Righe.Add(Format('  %-40s  %dx%d  DIVERSA dal riferimento %dx%d', [zDataModule.name + '.' + zLayout.name, zLayout.DesignWidth, zLayout.DesignHeight, RefWidth,
                RefHeight]));
            end;
        end;
      end;

    result := Format('Risoluzione di redazione dei layout — riferimento %dx%d'#13#10, [RefWidth, RefHeight]) +
      Format('%d layout esaminati: %d in linea, %d diversi, %d senza risoluzione registrata.'#13#10#13#10,
      [Totale, Totale - Deviate - NonRegistrate, Deviate, NonRegistrate]);

    if Righe.Count = 0 then
      result := result + '  Nessuna segnalazione.'
    else
      result := result + Righe.Text;
  finally
    FreeAndNil(Righe);
  end;
end;

initialization

SiFormController := Si.AddSession('FormController', True);

finalization

SiFormController := nil;

end.

  InternalLoadFromIni; zRestrictions.form zSystem zSystem zDbView zDbCard


  zdx
