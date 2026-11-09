unit zMap;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  System.Generics.Collections,
  System.Math,
  System.Actions,
  Vcl.ActnList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  Data.DB,

  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxStatusBar,
  cxContainer,
  cxEdit,
  cxProgressBar,
  dxSkinsdxStatusBarPainter,
  dxBar,
  cxClasses,
  cxImageList,
  dxCore,
  dxUIAClasses,
  zCoordinateGeografiche,
  zDx,
  zToolActions,
  zFbDataSet,

  Vcl.TMSFNCTypes,
  Vcl.TMSFNCUtils,
  Vcl.TMSFNCGraphics,
  Vcl.TMSFNCGraphicsTypes,
  Vcl.TMSFNCMapsCommonTypes,
  Vcl.TMSFNCCustomControl,
  Vcl.TMSFNCWebBrowser,
  Vcl.TMSFNCMaps,
  Vcl.TMSFNCCustomComponent,
  Vcl.TMSFNCCloudBase,
  Vcl.TMSFNCGeocoding,
  Vcl.TMSFNCWebBrowser.Win,

  cxGeometry,
  dxFramedControl,
  dxPanel,
  zSystem,
  zDescription,

  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TzMapType = (zmtDefault, zmtSatellite, zmtHybrid, zmtTerrain, zmtStreetView); // eliminare

  TMarkerIconColor = (icNone, icBlue, icGreen, icRed, icPurple);
  TGeocodeResult = (grNone, grFound, grNotFound, grBusy);

  TServiceApi = record
    MapAPI: string;
    GeocodingApi: string;

    procedure init;
  end;

  TGeocodingResultStruct = record
    Result: TGeocodeResult;
    ResultString: string;
    Latitude: Double;
    Longitude: Double;
    procedure Clear;
    procedure SetCoordinates(rec: TTMSFNCMapsCoordinateRec);
  end;

  TzMap = class(TFrame, IzBaseComponent)
    dxStatusBar: TdxStatusBar;
    Timer: TTimer;
    dxStatusBarContainer3: TdxStatusBarContainerControl;
    cxProgressBar: TcxProgressBar;
    dxBarManager: TdxBarManager;
    dxBar: TdxBar;
    Map: TTMSFNCMaps;
    Geocoding: TTMSFNCGeocoding;
    popMenu: TdxBarPopupMenu;
    ActionList: TActionList;
    actPersonalizza: TAction;
    dxBarButton1: TdxBarButton;
    actConsole: TAction;
    dxBarButton2: TdxBarButton;
    TimerVisible: TTimer;
    pnlDescrizione: TdxPanel;
    Descrizione: TAction;
    dxBarButton3: TdxBarButton;
    EditTools: TAction;
    dxBarButton4: TdxBarButton;
    procedure actConsoleExecute(Sender: TObject);
    procedure actConsoleUpdate(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure DescrizioneExecute(Sender: TObject);
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
    procedure MapGetBounds(Sender: TObject; ABounds: TTMSFNCMapsBoundsRec);
    procedure MapGetCenterCoordinate(Sender: TObject; ACoordinate: TTMSFNCMapsCoordinateRec);
    procedure MapGetZoomLevel(Sender: TObject; AZoomLevel: Double);
    procedure MapMapClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapMapInitialized(Sender: TObject);
    procedure MapMapMouseMove(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapMapMoveEnd(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapMapMoveStart(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapMapTypeChanged(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapMarkerClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapPolyElementClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure MapZoomChanged(Sender: TObject; AEventData: TTMSFNCMapsEventData);
    procedure popMenuPopup(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TimerVisibleTimer(Sender: TObject);
  private // Metodi IzBaseComponent
    FToolActions: TzToolActions;
    function GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
    procedure SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
    function GetID: string; // IzBaseComponent.GetID
    procedure SetID(const Value: string); // IzBaseComponent.SetID
    function GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
    function GetToolbar: TdxBar; // IzBaseComponent.GetToolbar
  private // Metodi IzBaseComponent (config azioni)
    function GetProps: TzBaseComponentProps;
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    procedure RebuildToolbar; // IzBaseComponent.RebuildToolbar — solo azioni (mappa non filtrabile)
    function ConfigTitle: string;
  private
    FBusy: Boolean;
    FReady: Boolean;
    InMapChanged: Boolean;
    FOnMapInitialized: TNotifyEvent;
    FOnMapChanged: TNotifyEvent;
    FOnMapClick: TTMSFNCMapsBaseEvent;
    FOnMarkerClick: TTMSFNCMapsBaseEvent;
    FOnPolyElementClick: TTMSFNCMapsBaseEvent;
  private
    StringListCache: TObjectList<TStringList>;
    procedure ClearStringListCache;
    function CacheStringList(src: TStrings): TStringList;
  private
    FCurrentLocation: TTMSFNCMapsCoordinateRec;
    function GetCurrentLocation: TTMSFNCMapsCoordinateRec;
    procedure SetCurrentLocation(const Value: TTMSFNCMapsCoordinateRec);
  private
    FZoomLevel: integer;
    procedure SetZoomLevel(const Value: integer);
    procedure ZoomToBounds(ACoordinates: TTMSFNCMapsCoordinateRecArrayArray);
  private
    procedure InitToolActions;
    procedure ToolActionsChanged(Sender: TObject);
  private
    FrameDescription: TFrameDescription;
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private
    FVisibleBounds: TTMSFNCMapsBoundsRec;
    FMapChangedInterval: integer;
    procedure SetMapChangedInterval(const Value: integer);
    function GetConsole: Boolean;
    procedure SetConsole(const Value: Boolean);
    procedure SetBusy(const Value: Boolean);
  private
    FGeocodingService: TTMSFNCGeocodingService;
    FMapId: string;
    FMapService: TTMSFNCMapsService;
    GeocodingResult: TGeocodingResultStruct;
    procedure Geocode(const Address: string; callBack: TProc; Service: TTMSFNCGeocodingService = gsOpenStreetMap);
    function IsAdmin: Boolean;
  private
    function OpenGisLayer(DataBase: TzFbDataBase; const LayerName: string; const Scope: string): TDataSet;
    function GisLayerCoordinates(DataSet: TDataSet; OnlyExternalParts: Boolean): TArray<TTMSFNCMapsCoordinateRecArray>;
    procedure GetGisLayerProperties(DataSet: TDataSet; PropertyFields: TStrings; PropertyValues: TStrings);
  private
    procedure SetGeocodingService(const Value: TTMSFNCGeocodingService);
    procedure SetMapService(const Value: TTMSFNCMapsService);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
  protected
    zMapProps: TzMapProps;
    function GetMapId: string;
    procedure LoadFromBase;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteToolConfig;
  public
    procedure InitMap;
    procedure WaitForReady;

    procedure LoadAPI;
    procedure MapChanged;

    procedure GotoAddress(const Address: string; callBack: TProc = nil; IconColor: TMarkerIconColor = icNone; Const ZoomLevel: integer = 15);
    function GotoAddressSync(const Address: string; const IconColor: TMarkerIconColor = icNone; Const ZoomLevel: integer = 15): Boolean;
    function GetAddressCoordinates(const Address: string): TTMSFNCMapsCoordinateRec;

    function VisibleExtent: TEstensioneUtm;
  public
    procedure GetProperties(DataSet: TDataSet; const PropertyNames: String; Properties: TStrings);
    function IconUrl(IconColor: TMarkerIconColor): string;

    function AddMarker(const ID: integer; const Latitude, Longitude: Double; const Title: String; Properties: TStrings; IconColor: TMarkerIconColor; const SourceName: string = ''): TTMSFNCMapsMarker;
    function AddCircle(const ID: integer; const Latitude, Longitude: Double; const Radius: Double; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsCircle;
    function AddRectangle(const ID: integer; ABounds: TTMSFNCMapsBoundsRec; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsRectangle;
    function AddPolygon(const ID: integer; ACoordinates: TTMSFNCMapsCoordinateRecArray; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsPolygon;
    function AddPolyline(const ID: integer; ACoordinates: TTMSFNCMapsCoordinateRecArray; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsPolyline;

    procedure AddMarkers(DataSet: TDataSet; const PKField, TitleField, Properties: string; FillMarker: TProc<TDataSet> = nil; GetColor: TFunc<TDataSet, TMarkerIconColor> = nil; const ClearCache: Boolean = true); overload;

    // Strati GIS salvati su Firebird nel formato OpenGIS: tabella <LayerName> con GID, XMIN, YMIN, XMAX, YMAX
    // e WKB_GEOMETRY in coordinate UTM 32N, tabella <LayerName>_FEA con GID e attributi. Scope e' un filtro
    // SQL sui campi di <LayerName>_FEA; GetColor riceve la riga corrente, con tutti i campi di <LayerName>_FEA
    procedure AddMarkers(DataBase: TzFbDataBase; Const LayerName: String; const Properties: string; Const Scope: String; GetColor: TFunc<TDataSet, TMarkerIconColor> = nil; const ClearCache: Boolean = true); overload;

    procedure AddPolygons(DataBase: TzFbDataBase; Const LayerName: String; const Properties: string; Const Scope: String; GetColor: TFunc<TDataSet, TColor> = nil; const ClearCache: Boolean = true); overload;

    procedure AddPolygons(DataSet: TDataSet; const PKFieldName: string; const Properties: string; FillPolygon: TProc<TTMSFNCMapsCoordinates, TDataSet>; const ClearCache: Boolean = true); overload;

    // Clear
    procedure Clear;
    procedure ClearMarkers(const DataString: string = '');
    procedure ClearPolygons(const DataString: string = '');
    procedure ClearCircles(const DataString: string = '');
    procedure ClearRectangles(const DataString: string = '');
    procedure ClearPolylines(const DataString: string = ''); overload;
    procedure ClearPolylines(Elements: TTMSFNCMapsPolyElements; const DataString: string = ''); overload;

    procedure ZoomToMarkers;
    procedure ZoomToPolygons;
    procedure ZoomToCircles;
    procedure ZoomToRectangles;
    procedure ZoomToPolylines;
  public
    property Busy: Boolean read FBusy write SetBusy;
    property Ready: Boolean read FReady;
    property CurrentLocation: TTMSFNCMapsCoordinateRec read GetCurrentLocation write SetCurrentLocation;
    property VisibleBounds: TTMSFNCMapsBoundsRec read FVisibleBounds;
    property ZoomLevel: integer read FZoomLevel write SetZoomLevel;
  published
    property Console: Boolean read GetConsole write SetConsole;
    property MapId: string read FMapId write FMapId;

    property GeocodingService: TTMSFNCGeocodingService read FGeocodingService write SetGeocodingService default gsOpenStreetMap;
    property MapService: TTMSFNCMapsService read FMapService write SetMapService default msOpenLayers;

    property MapChangedInterval: integer read FMapChangedInterval write SetMapChangedInterval default 300;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
    property ToolActions: TzToolActions read FToolActions write SetToolActions;

    property OnMapInitialized: TNotifyEvent read FOnMapInitialized write FOnMapInitialized;
    property OnMapChanged: TNotifyEvent read FOnMapChanged write FOnMapChanged;
    property OnMapClick: TTMSFNCMapsBaseEvent read FOnMapClick write FOnMapClick;
    property OnMarkerClick: TTMSFNCMapsBaseEvent read FOnMarkerClick write FOnMarkerClick;
    property OnPolyElementClick: TTMSFNCMapsBaseEvent read FOnPolyElementClick write FOnPolyElementClick;
  end;

procedure SetGoogleAPI(const API: string);

var
  ServiceApi: TServiceApi;

implementation

uses
  System.UITypes,
  FireDAC.Comp.Client,
  zGeometriaWkb,
  zFrmInspector,
  zLocalizer,
  zBaseLib,
  System.IniFiles,
  zToolConfigDlg,
  System.Diagnostics,
  zDiagnostica.Log.Perf;

{$R *.dfm}

{ TGeocodingResultStruct }
procedure TGeocodingResultStruct.Clear;
begin
  Result := grNone;
  Latitude := 0;
  Longitude := 0;
  ResultString := '';
end;

procedure TGeocodingResultStruct.SetCoordinates(rec: TTMSFNCMapsCoordinateRec);
begin
  Clear;
  Latitude := rec.Latitude;
  Longitude := rec.Longitude;

  if (Latitude = 0) and (Longitude = 0) then
    Result := grNotFound
  else
    Result := grFound;
end;

{ TzMap }
function TzMap.GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
begin
  Result := ctMap;
end;

function TzMap.GetToolbar: TdxBar; // IzBaseComponent.GetToolbar
begin
  Result := dxBar; // la mappa non e' filtrabile; barra delle sole azioni
end;

function TzMap.GetID: string; // IzBaseComponent.GetID
begin
  Result := FMapId;
end;

procedure TzMap.SetID(const Value: string); // IzBaseComponent.SetID
begin
  FMapId := Value;
end;

function TzMap.GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
begin
  Result := FToolActions;
end;

constructor TzMap.Create(aOwner: TComponent);
begin
  SiMain.EnterMethod(Self, 'Create');

  inherited;
  dx.AgganciaImmagini(Self);
  zMapProps := nil;
  FrameDescription := nil;
  Map.Visible := false; // Problema in visualizzazione. Es: FormQta_RFID

  FMapId := '';

  FGeocodingService := gsOpenStreetMap;
  FMapService := msOpenLayers;
  GeocodingResult.Clear;

  Timer.Enabled := false;
  FBusy := false;
  FReady := false;
  InMapChanged := false;
  FOnMapInitialized := nil;
  FOnMapChanged := nil;
  FOnMapClick := Nil;
  FOnMarkerClick := nil;
  FOnPolyElementClick := nil;

  FMapChangedInterval := 300;
  FZoomLevel := trunc(Map.Options.DefaultZoomLevel);

  StringListCache := TObjectList<TStringList>.Create(true);

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;
  dxBar.Visible := false;

  LoadAPI; // prima dell'assegnazione dei provider
  LoadFromBase;

  SiMain.LeaveMethod(Self, 'Create');
end;

procedure TzMap.CMShowingChanged(var M: TMessage);
begin
  SiMain.EnterMethod(Self, 'CMShowingChanged');

  inherited;
  InitMap;

  SiMain.LeaveMethod(Self, 'CMShowingChanged');
end;

procedure TzMap.TimerVisibleTimer(Sender: TObject);
begin
  SiMain.EnterMethod(Self, 'TimerVisibleTimer');

  // Problema in visualizzazione. Es: FormQta_RFID
  TimerVisible.Enabled := false;
  Map.Visible := true;

  SiMain.LeaveMethod(Self, 'TimerVisibleTimer');
end;

destructor TzMap.Destroy;
begin
  SiMain.EnterMethod('TzMap.Destroy');

  FreeAndNil(FrameDescription);
  FreeAndNil(StringListCache);
  FreeAndNil(FToolActions);
  inherited;

  SiMain.LeaveMethod('TzMap.Destroy');
end;

procedure TzMap.SetBusy(const Value: Boolean);
begin
  FBusy := Value;
  cxProgressBar.Properties.Marquee := Busy;
end;

function TzMap.CacheStringList(src: TStrings): TStringList;
begin
  Result := nil;

  if assigned(src) then
    if src.Count > 0 then
    begin
      Result := TStringList.Create;
      StringListCache.Add(Result);
      Result.Assign(src);
    end;
end;

procedure TzMap.Clear;
begin
  Map.Clear;
  ClearStringListCache;
end;

procedure TzMap.ClearMarkers(const DataString: string = '');
var
  i: integer;
begin
  if DataString.IsEmpty then
    Map.ClearMarkers
  else
  begin
    Map.BeginUpdate;
    try
      for i := Map.Markers.Count - 1 downto 0 do
        // if SameText(Map.Markers[i].DataString, DataString) then
        if Map.Markers[i].DataString = DataString then
          Map.Markers.Delete(i);
    finally
      Map.EndUpdate;
    end;
  end;
end;

procedure TzMap.ClearPolylines(Elements: TTMSFNCMapsPolyElements; const DataString: string);
var
  i: integer;
begin
  if DataString.IsEmpty then
    Elements.Clear
  else
  begin
    Map.BeginUpdate;
    try
      for i := Elements.Count - 1 downto 0 do
        // if SameText(Elements[i].DataString, DataString) then
        if Elements[i].DataString = DataString then
          Elements.Delete(i);
    finally
      Map.EndUpdate;
    end;
  end;
end;

procedure TzMap.ClearPolygons(const DataString: string = '');
begin
  ClearPolylines(Map.Polygons, DataString);
end;

procedure TzMap.ClearCircles(const DataString: string = '');
begin
  ClearPolylines(Map.Circles, DataString);
end;

procedure TzMap.ClearRectangles(const DataString: string = '');
begin
  ClearPolylines(Map.Rectangles, DataString);
end;

procedure TzMap.ClearPolylines(const DataString: string = '');
begin
  ClearPolylines(Map.Polylines, DataString);
end;

procedure TzMap.ClearStringListCache;
begin
  StringListCache.Clear;
end;

procedure TzMap.SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
begin
  FToolActions.Assign(Value);
end;

procedure TzMap.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

procedure TzMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if assigned(ToolActions) then
    ToolActions.RemoveNotification(AComponent);
end;

procedure TzMap.InitToolActions;
var
  i: integer;
  NeedLargeIcons: Boolean;
begin

  if GetProps = nil then
    exit;

  TzActionBuilder.BuildFromProps(GetProps.ToolActions, ToolActions, GetActionOwner);

  NeedLargeIcons := false;
  for i := 0 to ToolActions.Count - 1 do
    if ToolActions[i].LargeButton then
    begin
      NeedLargeIcons := true;
      Break;
    end;

  dxBarManager.ImageOptions.LargeIcons := NeedLargeIcons;
  /// //////////////////////////////////////////
  ToolActions.CreateButtons(dxBar, nil, otOther);
  /// //////////////////////////////////////////
  dxBar.Visible := ToolActions.Count > 0;
end;

function TzMap.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
var
  Props: TzToolActionsProps;
begin
  // Scrive sui props persistiti (sorgente unica); il runtime ToolActions viene
  // rigenerato da InitToolActions/BuildFromProps. FromCode protegge l'azione da
  // codice dall'Assign della LZ. ImageList ignorata (non persistibile; fallback).
  Result := nil;
  if not assigned(Action) then
    exit;

  if GetProps = nil then
    exit;

  Result := GetProps.ToolActions.Find(Action.Name);
  if not assigned(Result) then
  begin
    Result := GetProps.ToolActions.Add;
    Result.Name := Action.Name;
  end;

  Result.FromCode := true;
end;

function TzMap.GetActionOwnerName: string;
begin
  if not assigned(zMapProps) then
    LoadFromBase;
  if assigned(zMapProps) then
    Result := zMapProps.ActionOwnerName
  else
    Result := '';
end;

procedure TzMap.SetActionOwnerName(const Value: string);
begin
  if not assigned(zMapProps) then
    LoadFromBase;
  if assigned(zMapProps) then
    zMapProps.ActionOwnerName := Value;
end;

function TzMap.GetActionOwner: TComponent;
begin
  Result := TzActionOwnerResolver.ResolveOwner(Self, GetActionOwnerName);
end;

procedure TzMap.RebuildToolbar; // IzBaseComponent.RebuildToolbar — solo azioni (mappa non filtrabile)
begin
  InitToolActions;
end;

procedure TzMap.RebuildActions;
begin
  RebuildToolbar;
  if assigned(zMapProps) then
    zMapProps.SaveToBase(true);
end;

function TzMap.ConfigTitle: string;
begin
  Result := GetMapId;
end;

procedure TzMap.ExecuteToolConfig;
begin
  if not IsAdmin then
    exit;
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzMap.InitMap;
begin
  SiMain.EnterMethod(Self, 'InitMap');

  // Problema in visualizzazione. Es: FormQta_RFID
  TimerVisible.Enabled := false;
  TimerVisible.Enabled := true;

  SiMain.LeaveMethod(Self, 'InitMap');
end;

procedure TzMap.MapChanged;
begin
  SiMain.EnterMethod(Self, 'MapChanged');

  Timer.Enabled := false;
  if assigned(FOnMapChanged) then
    Timer.Enabled := true;

  SiMain.LeaveMethod(Self, 'MapChanged');
end;

procedure TzMap.SetMapChangedInterval(const Value: integer);
begin
  FMapChangedInterval := Value;
  Timer.Interval := MapChangedInterval;
end;

procedure TzMap.TimerTimer(Sender: TObject);
begin
  SiMain.EnterMethod(Self, 'TimerTimer');

  Timer.Enabled := false;

  if InMapChanged then
    exit;

  if Busy then
    exit;

  if assigned(FOnMapChanged) then
  begin
    InMapChanged := true;
    try
      OnMapChanged(Self);
    finally
      InMapChanged := false;
    end;
  end;

  SiMain.LeaveMethod(Self, 'TimerTimer');
end;

procedure TzMap.GotoAddress(const Address: string; callBack: TProc = nil; IconColor: TMarkerIconColor = icNone; Const ZoomLevel: integer = 15);
var
  start: integer;
begin
  if Address = '' then
    exit;

  Geocode(Address,
    procedure
    begin

      if not Ready then
        WaitForReady;

      if Ready then
      begin
        Map.SetCenterCoordinate(GeocodingResult.Latitude, GeocodingResult.Longitude);

        if IconColor <> icNone then
          AddMarker(-1, GeocodingResult.Latitude, GeocodingResult.Longitude, Address, nil, IconColor);

        if assigned(callBack) then
          callBack;
      end;
    end);
end;

function TzMap.GotoAddressSync(const Address: string; const IconColor: TMarkerIconColor = icNone; Const ZoomLevel: integer = 15): Boolean;
var
  rec: TTMSFNCMapsCoordinateRec;
begin
  Result := false;

  if Address = '' then
    exit;

  GeocodingResult.Clear;
  GeocodingResult.Result := grBusy;

  rec := GetAddressCoordinates(Address);
  GeocodingResult.SetCoordinates(rec);
  Result := GeocodingResult.Result = grFound;

  if Result then
  begin

    if IconColor <> icNone then
      AddMarker(-1, GeocodingResult.Latitude, GeocodingResult.Longitude, Address, nil, IconColor);

    Map.SetCenterCoordinate(GeocodingResult.Latitude, GeocodingResult.Longitude);
  end;
end;

function TzMap.GetAddressCoordinates(const Address: string): TTMSFNCMapsCoordinateRec;
begin
  Result := Geocoding.GetGeocodingSync(Address);
end;

procedure TzMap.Geocode(const Address: string; callBack: TProc; Service: TTMSFNCGeocodingService = gsOpenStreetMap);
begin
  GeocodingResult.Clear;
  GeocodingResult.Result := grBusy;

  Geocoding.GetGeocoding(Address,
    procedure(const ARequest: TTMSFNCGeocodingRequest; const ARequestResult: TTMSFNCCloudBaseRequestResult)
    var
      i: integer;
    begin
      GeocodingResult.ResultString := ARequestResult.ResultString;

      if ARequest.Items.Count > 0 then
      begin
        GeocodingResult.Result := grFound;
        GeocodingResult.Latitude := ARequest.Items[0].Coordinate.Latitude;
        GeocodingResult.Longitude := ARequest.Items[0].Coordinate.Longitude;
      end
      else
        GeocodingResult.Result := grNotFound;

      if assigned(callBack) then
        callBack;
    end);
end;

procedure TzMap.MapGetBounds(Sender: TObject; ABounds: TTMSFNCMapsBoundsRec);
begin
  SiMain.EnterMethod(Self, 'MapGetBounds');

  FVisibleBounds := ABounds;

  SiMain.LeaveMethod(Self, 'MapGetBounds');
end;

procedure TzMap.MapZoomChanged(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  SiMain.EnterMethod(Self, 'MapZoomChanged');

  Map.GetZoomLevel;
  Map.GetBounds;
  Map.GetCenterCoordinate;
  MapChanged;

  SiMain.LeaveMethod(Self, 'MapZoomChanged');
end;

procedure TzMap.MapGetZoomLevel(Sender: TObject; AZoomLevel: Double);
begin
  SiMain.EnterMethod(Self, 'MapGetZoomLevel');

  FZoomLevel := trunc(AZoomLevel);
  dxStatusBar.Panels[1].Text := 'Zoom: ' + ZoomLevel.ToString;

  SiMain.LeaveMethod(Self, 'MapGetZoomLevel');
end;

procedure TzMap.MapMapClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin

  if assigned(OnMapClick) then
    OnMapClick(Sender, AEventData);
end;

procedure TzMap.MapMapMouseMove(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  dxStatusBar.Panels[2].Text := 'Lat: : ' + AEventData.Coordinate.Latitude.ToString + ' - ' + 'Long: ' + AEventData.Coordinate.Longitude.ToString;
end;

procedure TzMap.MapMapMoveEnd(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  Map.GetBounds;
  Map.GetCenterCoordinate;
  MapChanged;
end;

procedure TzMap.MapMapMoveStart(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  Timer.Enabled := false;
end;

procedure TzMap.MapMapTypeChanged(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  SiMain.EnterMethod(Self, 'MapMapTypeChanged');

  Timer.Enabled := false;

  SiMain.LeaveMethod(Self, 'MapMapTypeChanged');
end;

procedure TzMap.SetZoomLevel(const Value: integer);
begin
  Map.SetZoomLevel(Value);
end;

procedure TzMap.MapMapInitialized(Sender: TObject);
begin
  SiMain.EnterMethod(Self, 'MapMapInitialized');

  FReady := true;
  Map.GetZoomLevel;
  Map.GetBounds;
  Map.GetCenterCoordinate;

  if assigned(FOnMapInitialized) then
    OnMapInitialized(Self);

  SiMain.LeaveMethod(Self, 'MapMapInitialized');
end;

procedure TzMap.MapMarkerClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  if assigned(FOnMarkerClick) then
    OnMarkerClick(Sender, AEventData);
end;

procedure TzMap.MapPolyElementClick(Sender: TObject; AEventData: TTMSFNCMapsEventData);
begin
  if assigned(FOnPolyElementClick) then
    OnPolyElementClick(Sender, AEventData);
end;

function TzMap.GetCurrentLocation: TTMSFNCMapsCoordinateRec;
begin
  Result := FCurrentLocation;
end;

procedure TzMap.SetCurrentLocation(const Value: TTMSFNCMapsCoordinateRec);
begin
  Map.SetCenterCoordinate(Value);
  FCurrentLocation := Value;
end;

function TzMap.VisibleExtent: TEstensioneUtm;
var
  ptNE, ptSW: TCoordinataUtm;
begin
  Result.EstMinimo := 0;
  Result.NordMinimo := 0;
  Result.EstMassimo := 0;
  Result.NordMassimo := 0;

  if not Ready then
    WaitForReady;

  if Ready then
  begin
    ptNE := UtmDaGeografica(VisibleBounds.NorthEast.Latitude, VisibleBounds.NorthEast.Longitude);
    ptSW := UtmDaGeografica(VisibleBounds.SouthWest.Latitude, VisibleBounds.SouthWest.Longitude);

    Result.EstMinimo := MinValue([ptNE.Est, ptSW.Est]);
    Result.NordMinimo := MinValue([ptNE.Nord, ptSW.Nord]);
    Result.EstMassimo := MaxValue([ptNE.Est, ptSW.Est]);
    Result.NordMassimo := MaxValue([ptNE.Nord, ptSW.Nord]);
  end;
end;

function TzMap.OpenGisLayer(DataBase: TzFbDataBase; const LayerName: string; const Scope: string): TDataSet;
var
  Query: TFDQuery;
  Extent: TEstensioneUtm;
  FeatureTable: string;
  Sql: string;
begin
  // Al posto di TGis_LayerSqlOgisFDAC di TatukGIS: stessa tabella delle geometrie, stessa tabella
  // degli attributi e stesso filtro sull'area visibile, letti con una query sola
  Extent := VisibleExtent;
  FeatureTable := LayerName + '_FEA';

  Sql :=
    'SELECT ' + FeatureTable + '.*, ' + LayerName + '.WKB_GEOMETRY AS ZMAP_WKB_GEOMETRY' + sLineBreak +
    'FROM ' + LayerName + sLineBreak +
    'JOIN ' + FeatureTable + ' ON ' + FeatureTable + '.GID = ' + LayerName + '.GID' + sLineBreak +
    'WHERE ' + LayerName + '.XMIN <= :EST_MASSIMO AND ' + LayerName + '.XMAX >= :EST_MINIMO AND' + sLineBreak +
    '      ' + LayerName + '.YMIN <= :NORD_MASSIMO AND ' + LayerName + '.YMAX >= :NORD_MINIMO';

  if not Scope.Trim.IsEmpty then
    Sql := Sql + sLineBreak + '  AND (' + Scope + ')';

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DataBase;
    // Lo Scope arriva gia' scritto in SQL: niente macro ne' sequenze di escape di FireDAC al suo interno
    Query.ResourceOptions.MacroCreate := false;
    Query.ResourceOptions.MacroExpand := false;
    Query.ResourceOptions.EscapeExpand := false;
    Query.SQL.Text := Sql;
    Query.ParamByName('EST_MINIMO').AsFloat := Extent.EstMinimo;
    Query.ParamByName('EST_MASSIMO').AsFloat := Extent.EstMassimo;
    Query.ParamByName('NORD_MINIMO').AsFloat := Extent.NordMinimo;
    Query.ParamByName('NORD_MASSIMO').AsFloat := Extent.NordMassimo;
    Query.Open;
  except
    FreeAndNil(Query);
    raise;
  end;

  Result := Query;
end;

function TzMap.GisLayerCoordinates(DataSet: TDataSet; OnlyExternalParts: Boolean): TArray<TTMSFNCMapsCoordinateRecArray>;
var
  Geometry: TGeometriaWkb;
  Part: TParteWkb;
  Point: TPuntoWkb;
  Coordinates: TTMSFNCMapsCoordinateRecArray;
  LatLong: TCoordinataGeografica;
  i: integer;
begin
  Result := nil;

  Geometry := LeggiGeometriaWkb(DataSet.FieldByName('ZMAP_WKB_GEOMETRY').AsBytes);

  for Part in Geometry.Parti do
  begin
    // I buchi dei poligoni non si disegnano: la mappa ha solo poligoni pieni
    if OnlyExternalParts and not Part.Esterna then
      Continue;

    SetLength(Coordinates, Length(Part.Punti));
    for i := 0 to High(Part.Punti) do
    begin
      Point := Part.Punti[i];
      LatLong := GeograficaDaUtm(Point.X, Point.Y);
      Coordinates[i].Latitude := LatLong.Latitudine;
      Coordinates[i].Longitude := LatLong.Longitudine;
    end;

    if Length(Coordinates) > 0 then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := Copy(Coordinates);
    end;
  end;
end;

procedure TzMap.GetGisLayerProperties(DataSet: TDataSet; PropertyFields: TStrings; PropertyValues: TStrings);
var
  FieldName: string;
  Field: TField;
begin
  PropertyValues.Clear;
  for FieldName in PropertyFields do
  begin
    Field := DataSet.FindField(FieldName);
    if assigned(Field) then
      PropertyValues.Add(FieldName + '=' + VarToStr(Field.Value))
    else
      PropertyValues.Add(FieldName + '=');
  end;
end;

procedure TzMap.WaitForReady;
var
  i: integer;
  loop: Boolean;
  start: integer;
begin
  SiMain.EnterMethod(Self, 'WaitForReady');

  if Ready then
    exit;

  start := GetTickCount;

  loop := true;

  while loop do
  begin

    if Ready then
      loop := false
    else
      if not Visible then
        loop := false
      else
        if csDestroying in ComponentState then
          loop := false
        else
          if Application.Terminated then
            loop := false
          else
          begin
            i := GetTickCount;
            if (i - start) > 3000 then
              loop := false;
          end;

    if loop then
      Application.ProcessMessages;
  end;

  if loop then
  begin
    Application.ProcessMessages;
  end;

  SiMain.LeaveMethod(Self, 'WaitForReady');
end;

procedure TzMap.ZoomToBounds(ACoordinates: TTMSFNCMapsCoordinateRecArrayArray);

  function InflateBound(bounds: TTMSFNCMapsBoundsRec): TTMSFNCMapsBoundsRec;
  const
    k: Double = 0.005;
  begin
    Result.NorthEast.Latitude := bounds.NorthEast.Latitude + (k);
    Result.NorthEast.Longitude := bounds.NorthEast.Longitude + (k);
    Result.SouthWest.Latitude := bounds.SouthWest.Latitude - (k);
    Result.SouthWest.Longitude := bounds.SouthWest.Longitude - (k);
  end;

var
  bounds: TTMSFNCMapsBoundsRec;
begin
  { TODO : Allargare leggermente lo zoom, altriment arriva proprio al filo }
  bounds := CreateBounds(ACoordinates);
  bounds := InflateBound(bounds);
  Map.ZoomToBounds(bounds);
  // Map.ZoomToBounds(ACoordinates);
end;

procedure TzMap.ZoomToMarkers;
begin
  if Map.Markers.Count > 1 then
    ZoomToBounds(Map.Markers.ToCoordinateArray);
end;

procedure TzMap.ZoomToPolygons;
begin
  if Map.Polygons.Count > 1 then
    ZoomToBounds(Map.Polygons.ToCoordinateArray);
end;

procedure TzMap.ZoomToCircles;
begin
  if Map.Circles.Count > 1 then
    ZoomToBounds(Map.Circles.ToCoordinateArray);
end;

procedure TzMap.ZoomToRectangles;
begin
  if Map.Rectangles.Count > 1 then
    ZoomToBounds(Map.Rectangles.ToCoordinateArray);
end;

procedure TzMap.ZoomToPolylines;
begin
  if Map.Polylines.Count > 1 then
    ZoomToBounds(Map.Polylines.ToCoordinateArray);
end;

procedure TzMap.MapGetCenterCoordinate(Sender: TObject; ACoordinate: TTMSFNCMapsCoordinateRec);
begin
  SiMain.EnterMethod(Self, 'MapGetCenterCoordinate');

  FCurrentLocation := ACoordinate;

  SiMain.LeaveMethod(Self, 'MapGetCenterCoordinate');
end;

function TzMap.AddMarker(const ID: integer; const Latitude, Longitude: Double; const Title: String; Properties: TStrings; IconColor: TMarkerIconColor; const SourceName: string = ''): TTMSFNCMapsMarker;
begin
  Result := Map.AddMarker(Latitude, Longitude, Title, IconUrl(IconColor));

  Result.DataInteger := ID;
  Result.DataString := SourceName;
  Result.DataObject := CacheStringList(Properties);
end;

function TzMap.AddCircle(const ID: integer; const Latitude, Longitude, Radius: Double; Properties: TStrings; const SourceName: string): TTMSFNCMapsCircle;
begin
  Result := Map.AddCircle(CreateCoordinate(Latitude, Longitude), Radius);

  Result.DataInteger := ID;
  Result.DataString := SourceName;
  Result.DataObject := CacheStringList(Properties);
end;

function TzMap.AddRectangle(const ID: integer; ABounds: TTMSFNCMapsBoundsRec; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsRectangle;
begin
  Result := Map.AddRectangle(ABounds);

  Result.DataInteger := ID;
  Result.DataString := SourceName;
  Result.DataObject := CacheStringList(Properties);
end;

function TzMap.AddPolygon(const ID: integer; ACoordinates: TTMSFNCMapsCoordinateRecArray; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsPolygon;
begin
  Result := Map.AddPolygon(ACoordinates);

  Result.DataInteger := ID;
  Result.DataString := SourceName;
  Result.DataObject := CacheStringList(Properties);
end;

function TzMap.AddPolyline(const ID: integer; ACoordinates: TTMSFNCMapsCoordinateRecArray; Properties: TStrings; const SourceName: string = ''): TTMSFNCMapsPolyline;
begin
  Result := Map.AddPolyline(ACoordinates);

  Result.DataInteger := ID;
  Result.DataString := SourceName;
  Result.DataObject := CacheStringList(Properties);
end;

procedure TzMap.AddMarkers(DataSet: TDataSet; const PKField, TitleField, Properties: string; FillMarker: TProc<TDataSet> = nil; GetColor: TFunc<TDataSet, TMarkerIconColor> = nil; const ClearCache: Boolean = true);
var
  Marker: TTMSFNCMapsMarker;
  lat0, latX, long0, longX: integer;
  IconColor: TMarkerIconColor;
  IconName: string;
  ID: integer;
  Latitude: Double;
  Longitude: Double;
  Title: string;
  skip: Boolean;
  PropertyValues: TStrings;
begin
  SiMain.EnterMethod(Self, 'AddMarkers');

  Busy := true;
  Map.BeginUpdate;
  try
    ClearMarkers(DataSet.Name);

    if ClearCache then
      ClearStringListCache;

    PropertyValues := TStringList.Create;
    try
      DataSet.First;

      while not DataSet.Eof do
      begin
        SiMain.LogInteger('Marker n�', Map.Markers.Count);

        // if Map.Markers.Count >= 100 then
        // Exit;

        if assigned(FillMarker) then
          FillMarker(DataSet)
        else
        begin
          IconColor := TMarkerIconColor.icRed;

          if assigned(GetColor) then
            IconColor := GetColor(DataSet);

          Latitude := DataSet.FieldByName('LATITUDINE').AsFloat;
          Longitude := DataSet.FieldByName('LONGITUDINE').AsFloat;

          ID := -1;
          if PKField <> '' then
            ID := DataSet.FieldByName(PKField).AsInteger;

          Title := '';
          if TitleField <> '' then
            Title := DataSet.FieldByName(TitleField).AsString;

          GetProperties(DataSet, Properties, PropertyValues);

          AddMarker(ID, Latitude, Longitude, Title, PropertyValues, IconColor, DataSet.Name);
        end;

        DataSet.Next;
      end;
    finally
      FreeAndNil(PropertyValues);
    end;
  finally
    Map.EndUpdate;
    ZoomToMarkers;
    Busy := false;
  end;
  SiMain.LeaveMethod(Self, 'AddMarkers');
end;

procedure TzMap.AddPolygons(DataBase: TzFbDataBase; Const LayerName: String; const Properties: string; Const Scope: String; GetColor: TFunc<TDataSet, TColor> = nil; const ClearCache: Boolean = true);
var
  Circle: TTMSFNCMapsCircle;
  BackgroundColor: TColor;
  layer: TDataSet;
  PropertyFields: TStrings;
  PropertyValues: TStrings;
  Parts: TArray<TTMSFNCMapsCoordinateRecArray>;
  Coordinates: TTMSFNCMapsCoordinateRecArray;
  ID: integer;
  Polygon: TTMSFNCMapsPolygon;
  i: integer;
begin
  SiMain.EnterMethod(Self, 'AddPolygons');

  i := 0;

  Busy := true;
  Map.BeginUpdate;
  try
    ClearPolygons(LayerName);

    if ClearCache then
      ClearStringListCache;

    PropertyValues := TStringList.Create;
    PropertyFields := TStringList.Create;
    layer := nil;
    try
      PropertyFields.StrictDelimiter := true;
      PropertyFields.Delimiter := ';';
      PropertyFields.DelimitedText := StringReplace(Properties, ',', ';', [rfReplaceAll]);

      layer := OpenGisLayer(DataBase, LayerName, Scope);

      while not layer.Eof do
      begin
        inc(i);

        SiMain.LogInteger('Polygon', i);

        ID := layer.FieldByName('GID').AsInteger;

        GetGisLayerProperties(layer, PropertyFields, PropertyValues);

        BackgroundColor := TColors.Null;
        if assigned(GetColor) then
          BackgroundColor := GetColor(layer);

        Parts := GisLayerCoordinates(layer, true);

        for Coordinates in Parts do
          if Length(Coordinates) = 1 then
          begin
            Circle := AddCircle(ID, Coordinates[0].Latitude, Coordinates[0].Longitude, 1, PropertyValues, LayerName);

            if BackgroundColor <> TColors.Null then
              Circle.StrokeColor := BackgroundColor;
          end
          else
          begin
            Polygon := AddPolygon(ID, Coordinates, PropertyValues, LayerName);

            if BackgroundColor <> TColors.Null then
              Polygon.StrokeColor := BackgroundColor;
          end;

        layer.Next;
      end;
    finally
      FreeAndNil(layer);
      FreeAndNil(PropertyFields);
      FreeAndNil(PropertyValues);
    end;
  finally
    Map.EndUpdate;
    ZoomToPolygons;
    Busy := false;
  end;
  SiMain.LeaveMethod(Self, 'AddPolygons');
end;

procedure TzMap.AddPolygons(DataSet: TDataSet; const PKFieldName: string; const Properties: string; FillPolygon: TProc<TTMSFNCMapsCoordinates, TDataSet>; const ClearCache: Boolean = true);
var
  PropertyValues: TStrings;
  Coordinates: TTMSFNCMapsCoordinates;
  Coordinate: TTMSFNCMapsCoordinateItem;
  PKField: TField;
  ID: integer;
  i: integer;
begin
  SiMain.EnterMethod(Self, 'AddPolygons');

  i := 0;

  Busy := true;
  Map.BeginUpdate;
  try
    ClearPolygons(DataSet.Name);

    if ClearCache then
      ClearStringListCache;

    PropertyValues := TStringList.Create;
    Coordinates := TTMSFNCMapsCoordinates.Create(nil);
    try
      PKField := DataSet.FindField(PKFieldName);

      DataSet.First;
      while not DataSet.Eof do
      begin
        inc(i);
        // if I > 300 then
        // Exit;

        SiMain.LogInteger('Polygon', i);

        FillPolygon(Coordinates, DataSet);

        ID := -1;
        if assigned(PKField) then
          ID := PKField.AsInteger;

        GetProperties(DataSet, Properties, PropertyValues);

        AddPolygon(ID, Coordinates.ToArray, PropertyValues, DataSet.Name);

        DataSet.Next;
      end;
    finally
      FreeAndNil(Coordinates);
      FreeAndNil(PropertyValues);
    end;
  finally
    Map.EndUpdate;
    ZoomToPolygons;
    Busy := false;
  end;
  SiMain.LeaveMethod(Self, 'AddPolygons');
end;

function TzMap.GetConsole: Boolean;
begin
  Result := Map.Options.Console;
end;

procedure TzMap.SetConsole(const Value: Boolean);
begin
  if Map.Options.Console <> Value then
  begin
    Map.Options.Console := Value;
    Map.ReInitialize;
  end;
end;

procedure TzMap.Loaded;
begin
  Map.DeInitialize;
  inherited;
  Map.Initialize;
  Map.OnPolyElementClick := MapPolyElementClick;
end;

function TzMap.IconUrl(IconColor: TMarkerIconColor): string;
begin
  Result := '';
  case IconColor of
    icNone:
      Result := '';
    icBlue:
      Result := 'http://mt.google.com/vt/icon?color=ff004C13&name=icons/spotlight/spotlight-waypoint-blue.png';
    icRed:
      Result := 'http://mt.googleapis.com/vt/icon/name=icons/spotlight/spotlight-poi.png&scale=1';
    icPurple:
      Result := 'http://mt.google.com/vt/icon/name=icons/spotlight/spotlight-ad.png';
    icGreen:
      Result := 'http://mt.google.com/vt/icon?psize=30&font=fonts/arialuni_t.ttf&color=ff304C13&name=icons/spotlight/spotlight-waypoint-a.png&ax=43&ay=48&text=%E2%80%A2';
  end;
end;

{ TServiceApi }

procedure TServiceApi.init;
begin
  MapAPI := '';
  GeocodingApi := '';
end;

procedure SetGoogleAPI(const API: string);
begin
  ServiceApi.init;

  if not API.IsEmpty then
  begin
    ServiceApi.MapAPI := API;
    ServiceApi.GeocodingApi := API;
  end;
end;

procedure TzMap.AddMarkers(DataBase: TzFbDataBase; Const LayerName: String; const Properties: string; Const Scope: String; GetColor: TFunc<TDataSet, TMarkerIconColor> = nil; const ClearCache: Boolean = true);
var
  IconColor: TMarkerIconColor;
  layer: TDataSet;
  PropertyFields: TStrings;
  PropertyValues: TStrings;
  Parts: TArray<TTMSFNCMapsCoordinateRecArray>;
  ID: integer;
  i: integer;
begin
  SiMain.EnterMethod(Self, 'AddMarkers');

  i := 0;

  Busy := true;
  Map.BeginUpdate;
  try
    ClearMarkers(LayerName);

    if ClearCache then
      ClearStringListCache;

    PropertyValues := TStringList.Create;
    PropertyFields := TStringList.Create;
    layer := nil;
    try
      PropertyFields.StrictDelimiter := true;
      PropertyFields.Delimiter := ';';
      PropertyFields.DelimitedText := StringReplace(Properties, ',', ';', [rfReplaceAll]);

      layer := OpenGisLayer(DataBase, LayerName, Scope);

      while not layer.Eof do
      begin
        inc(i);
        SiMain.LogInteger('Marker', i);

        ID := layer.FieldByName('GID').AsInteger;

        GetGisLayerProperties(layer, PropertyFields, PropertyValues);

        // Prima GetColor era obbligatorio (veniva chiamato senza controllo): ora senza si usa il blu
        IconColor := icBlue;
        if assigned(GetColor) then
          IconColor := GetColor(layer);

        // Il marcatore va sul primo punto della geometria, come prima
        Parts := GisLayerCoordinates(layer, false);
        if Length(Parts) > 0 then
          AddMarker(ID, Parts[0][0].Latitude, Parts[0][0].Longitude, '', PropertyValues, IconColor, LayerName);

        layer.Next;
      end;
    finally
      FreeAndNil(layer);
      FreeAndNil(PropertyFields);
      FreeAndNil(PropertyValues);
    end;
  finally
    Map.EndUpdate;
    ZoomToMarkers;
    Busy := false;
  end;
  SiMain.LeaveMethod(Self, 'AddPolygons');
end;

procedure TzMap.GetProperties(DataSet: TDataSet; const PropertyNames: String; Properties: TStrings);
var
  FieldName: string;
  Field: TField;
begin
  Properties.Clear;

  for FieldName in PropertyNames.Replace(',', ';', [rfReplaceAll]).Split([';']) do
  begin

    if FieldName <> '' then
    begin
      Field := DataSet.FindField(FieldName);

      if assigned(Field) then
        Properties.AddPair(FieldName, Field.AsString)
      else
        Properties.AddPair(FieldName, '');
    end;
  end;
end;

function TzMap.IsAdmin: Boolean;
begin
  Result := false;
  if assigned(Base) then
    Result := Base.IsAdmin;
end;

procedure TzMap.popMenuPopup(Sender: TObject);
begin
  if not IsAdmin then
    Abort;
end;

function TzMap.GetMapId: string;
begin
  Result := MapId;

  if Result.IsEmpty then
    Result := Owner.ClassName + '.' + Name;
end;

procedure TzMap.LoadAPI;
begin
  Map.ApiKey := ServiceApi.MapAPI;
  Geocoding.ApiKey := ServiceApi.GeocodingApi;
end;

procedure TzMap.LoadFromBase;
begin
  if not assigned(Base) then
    exit;

  zMapProps := Base.zMaps.get(GetMapId, true);

  if zMapProps.isNew then
  begin
    zMapProps.GeocodingService := GeocodingService;
    zMapProps.MapChangedInterval := MapChangedInterval;
    zMapProps.MapService := MapService;
    zMapProps.ZoomLevel := ZoomLevel;
    zMapProps.SaveToBase(true);
  end
  else
  begin
    GeocodingService := zMapProps.GeocodingService;
    MapChangedInterval := zMapProps.MapChangedInterval;
    MapService := zMapProps.MapService;
    ZoomLevel := zMapProps.ZoomLevel;
  end;

  LoadDescription;
end;

procedure TzMap.actPersonalizzaExecute(Sender: TObject);
var
  item: TzMapProps;
begin
  if not assigned(Base) then
    exit;

  item := Base.zMaps.get(GetMapId, true);

  if item.Inspect then
  begin
    item.SaveToBase(true);
    LoadFromBase;
  end;
end;

procedure TzMap.SetGeocodingService(const Value: TTMSFNCGeocodingService);
begin
  if FGeocodingService <> Value then
  begin
    if (Value = gsOpenStreetMap) or (Geocoding.ApiKey.IsEmpty) then
      FGeocodingService := gsOpenStreetMap
    else
      FGeocodingService := Value;

    Geocoding.Service := GeocodingService;
  end;
end;

procedure TzMap.SetMapService(const Value: TTMSFNCMapsService);
begin
  if FMapService <> Value then
  begin
    if (Value = msOpenLayers) or (Map.ApiKey.IsEmpty) then
      FMapService := msOpenLayers
    else
      FMapService := Value;

    Map.Service := MapService;
  end;
end;

procedure TzMap.actConsoleExecute(Sender: TObject);
begin
  Console := actConsole.checked;
end;

procedure TzMap.actConsoleUpdate(Sender: TObject);
begin
  actConsole.checked := Console;
end;

procedure InitEdge;
var
  ExePath: string;
  IniFileName: string;
  EdgeFolder: string;
  IniFile: TIniFile;

  procedure SetEdgeFolder(const EdgeFolder: string);
  begin
    if not EdgeFolder.IsEmpty then
      if DirectoryExists(EdgeFolder) then
        EdgeCustomPath := EdgeFolder;
  end;

  function cmdLineParamExists(const paramName: string): Boolean;
  var
    i: integer;
  begin
    Result := false;

    for i := 1 to ParamCount do
      if sameText(paramName, paramstr(i)) then
      begin
        Result := true;
        exit;
      end;
  end;

begin
  EdgeSilentErrors := true;

  if cmdLineParamExists('-noedge') then
    exit;

  IniFileName := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'WebView2Loader_x86.ini';

  if FileExists(IniFileName) then
  begin

    IniFile := TIniFile.Create(IniFileName);
    try
      EdgeFolder := IniFile.ReadString('Application', 'WebView2_Folder', '');
      SetEdgeFolder(EdgeFolder);
    finally
      FreeAndNil(IniFile);
    end;
  end;
end;

procedure TzMap.DescrizioneExecute(Sender: TObject);
begin

  if Descrizione.checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzMap.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

procedure TzMap.LoadDescription;
begin

  if not assigned(FrameDescription) then
    CreateDescription;

  zMapProps.Description.LoadFromIni(GetMapId);
  FrameDescription.zDescription := zMapProps.Description;

  Descrizione.checked := FrameDescription.zDescription.Visible;
end;

procedure TzMap.SaveDescription;
begin
  zMapProps.Description.Assign(FrameDescription.zDescription);
  zMapProps.Description.SaveToIni(GetMapId);
  Descrizione.checked := zMapProps.Description.Visible;
end;

procedure TzMap.SetParent(AParent: TWinControl);
var
  Misura: boolean;
  Cronometro: TStopwatch;
begin
  SiMain.EnterMethod(Self, 'TzMap.SetParent');

  // Misura per la sessione di registrazione attivabile dall'utente. A
  // registrazione spenta il costo e' la lettura di un booleano.
  Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
  if Misura then
    Cronometro := TStopwatch.StartNew;

  inherited;

  if Misura then
    zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, 'TzMap.SetParent', Cronometro.ElapsedMilliseconds, Name);

  SiMain.LeaveMethod(Self, 'TzMap.SetParent');
end;

procedure TzMap.EditToolsExecute(Sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzMap.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

function TzMap.GetProps: TzBaseComponentProps;
begin
  if not assigned(zMapProps) then
    LoadFromBase;

  if assigned(zMapProps) then
    Result := zMapProps
  else
    Result := nil;
end;

initialization

ServiceApi.init;

InitEdge;

end.

// Marker.Title := ''; // Evita il popup


// function ShowPopup(ACoordinate: TTMSFNCMapsCoordinateRec; AText: string; AOffsetX: Double = 0; AOffsetY: Double = 0): string; overload; virtual;
// function ShowPopup(ALatitude: Double; ALongitude: Double; AText: string; AOffsetX: Double = 0; AOffsetY: Double = 0): string; overload; virtual;
// procedure ClosePopup(AID: string); virtual;
// procedure CloseAllPopups; virtual;

  zdbview zdbcard
