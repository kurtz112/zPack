unit zOffice.MultiViewer;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Data.DB,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxPC,
  dxBarBuiltInMenu,
  dxFileActions,
  dxActivityIndicator,
  dxUIAClasses,
  dxBar,
  zOffice.types,
  zOffice.Word.Frame,
  zOffice.Excel.Frame,
  zOffice.Pdf.Frame,
  zOffice.Image.Frame,
  zOffice.Mail.Frame,
  zOffice.SynEdit.Frame,
  zOffice.Reports.Azioni,
  zOffice.Reports.Controller,
  zOffice.Reports.ActionsBarHelper,
  cxContainer,
  cxEdit,
  dxGDIPlusClasses,
  cxImage,
  cxLabel,
  zToolActions,
  zSystem,
  zFbDataSet,
  System.ImageList,
  Vcl.ImgList,
  cxImageList,
  Vcl.StdActns,
  cxClasses,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzMultiViewer = class;
  TImportFileEvent = procedure(sender: TzMultiViewer; const FileName: string) of object;
  TViewerCreatedEvent = procedure(sender: TzMultiViewer; const zFileType: TzFileType) of object;

  // Azioni documentali sul documento persistito: l'applicazione fornisce la
  // configurazione delle azioni del profilo (letta da
  // OBJ_FILES_PROFILO_AZIONI_GET) nella stessa struttura TzJsonAzioniConfig
  // usata dai template. Il viewer la richiede una volta per documento (cache
  // per ID_OBJECT_FILE).
  TzGetAzioniConfigEvent = procedure(sender: TzMultiViewer; IdObjectFile: Int64; var AzioniConfig: TzJsonAzioniConfig) of object;
  TzMostraVersioniEvent = procedure(sender: TzMultiViewer; IdObjectFile: Int64) of object;

  TzMultiViewer = class(TFrame, IzBaseComponent, IzBaseDbComponent)
    PageControl: TcxPageControl;
    tabExcel: TcxTabSheet;
    tabPdf: TcxTabSheet;
    tabImage: TcxTabSheet;
    tabWord: TcxTabSheet;
    tabNone: TcxTabSheet;
    Timer: TTimer;
    DataSource: TDataSource;
    dxActivityIndicator: TdxActivityIndicator;
    tabMail: TcxTabSheet;
    tabSynEdit: TcxTabSheet;
    labelEmpty: TcxLabel;
    ActionList: TActionList;
    EditTools: TAction;
    dxBarManagerNone: TdxBarManager;
    dxBarManagerNoneBar: TdxBar;
    dxBarDockControlNone: TdxBarDockControl;
    btnImportaNone: TdxBarButton;
    ImportaNone: TdxFileOpen;
    actDocFirma: TAction;
    actDocProtocolla: TAction;
    actDocConserva: TAction;
    actDocInviaPec: TAction;
    actDocInviaMail: TAction;
    actDocAggiornaStato: TAction;
    actDocVersioni: TAction;
    actDocGeneraAllegato: TAction;
    procedure DataSourceDataChange(sender: TObject; Field: TField);
    procedure TimerTimer(sender: TObject);
    procedure EditToolsExecute(sender: TObject);
    procedure EditToolsUpdate(sender: TObject);
    procedure ImportaNoneAccept(sender: TObject);
    procedure ImportaNoneBeforeExecute(sender: TObject);
    procedure ImportaNoneUpdate(sender: TObject);
  private // Metodi IzBaseComponent / IzBaseDbComponent
    FToolActions: TzToolActions;
    FzFileViewerProps: TzFileViewerProps;
    function GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
    procedure SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
    function GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
    procedure SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
    function GetID: string; // IzBaseComponent.GetID
    procedure SetID(const Value: string); // IzBaseComponent.SetID
    function GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
    function GetToolbar: TdxBar; // IzBaseComponent.GetToolbar
  private // Metodi IzBaseComponent (config azioni)
    function EnsureProps: TzFileViewerProps;
    function GetProps: TzBaseComponentProps;
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    procedure RebuildToolbar; // IzBaseComponent.RebuildToolbar - solo azioni (viewer non filtrabile)
    function ConfigTitle: string;
    function IsAdmin: boolean;
  private
    Initialized: boolean;
    Loading: boolean;
    FID: string;
    FDataSet: TDataSet;
    FFieldName_FileName: string;
    FFieldName_ID: string;
    FFieldName: string;
    FFileName: string;
    FFolder: string;
    FLocked: boolean;
    FOnImportFile: TImportFileEvent;
    procedure SetDataSet(const Value: TDataSet);
    procedure SetFileName(const Value: string);
    procedure SetFolder(const Value: string);
    procedure SetLocked(const Value: boolean);
    procedure SetAllowedFileTypes(const Value: TzFileTypes);
    procedure SetOnImportFile(const Value: TImportFileEvent);
  private // Azioni documentali sul documento persistito
    FActionsController: TzDocumentActionsController;
    FActionsHelper: TzDocumentActionsBarHelper;
    FFieldNameIdObjectFile: string;
    FOnGetAzioniConfig: TzGetAzioniConfigEvent;
    FOnMostraVersioni: TzMostraVersioniEvent;
    FAzioniConfigCache: TzJsonAzioniConfig;
    FAzioniConfigCacheId: Int64;
    procedure SetActionsController(const Value: TzDocumentActionsController);
    procedure SetOnMostraVersioni(const Value: TzMostraVersioniEvent);
    procedure WireDocActions;
    procedure CreateActionsHelper;
    function GetActiveViewerFrame: TFrame;
    procedure InitDocActionButtons(ActiveBar: TdxBar);
    function AzioniConfigCorrente: TzJsonAzioniConfig;
    function BuildDocumentoContesto: TzDocumentoContesto;
    procedure DocActionUpdate(sender: TObject);
    procedure DocActionExecute(sender: TObject);
    procedure DocAggiornaStatoUpdate(sender: TObject);
    procedure DocAggiornaStatoExecute(sender: TObject);
    procedure DocVersioniUpdate(sender: TObject);
    procedure DocVersioniExecute(sender: TObject);
    procedure DocGeneraAllegatoUpdate(sender: TObject);
    procedure DocGeneraAllegatoExecute(sender: TObject);
  private
    procedure OpenFile;
    procedure dbOpenFile;
    function FileExistsAndNotLocked(const FileName: string): boolean;
  private
    zViewerWordFrame: TzViewerWordFrame;
    zViewerExcelFrame: TzViewerExcelFrame;
    zViewerPdfFrame: TzViewerPdfFrame;
    zViewerImageFrame: TzViewerImageFrame;
    zViewerMailFrame: TzViewerMailFrame;
    zViewerSynEditFrame: TzViewerSynEditFrame;

    procedure OnImportFileWord(sender: TzViewerWordFrame; const FileName: string);
    procedure OnImportFileExcel(sender: TzViewerExcelFrame; const FileName: string);
    procedure OnImportFilePdf(sender: TzViewerPdfFrame; const FileName: string);
    procedure OnImportFileImage(sender: TzViewerImageFrame; const FileName: string);
    procedure OnImportFileMail(sender: TzViewerMailFrame; const FileName: string);
    procedure OnImportFileSynEdit(sender: TzViewerSynEditFrame; const FileName: string);
    procedure doImportFile(const FileName: string);

    procedure CreateViewerWord;
    procedure CreateViewerExcel;
    procedure CreateViewerPdf;
    procedure CreateViewerImage;
    procedure CreateViewerMail;
    procedure CreateViewerSynEdit;
    procedure CreateViewer(zFileType: TzFileType);
    procedure doViewerCreated(zFileType: TzFileType);
  private
    function GetViewerType(const FileName: string): TzFileType;
    procedure SetActiveViewer(const FileName: string);
    procedure UpdateBarManagersState;

    function GetActiveViewer: izViewerFrame;
    function GetActiveBar: TdxBar;
  private
    FAllowedFileTypes: TzFileTypes;
    FFieldNameOID: string;
    FOnViewerCreated: TViewerCreatedEvent;
    PrevPageIndex: Integer;

    procedure ShowPage(zFileType: TzFileType);
    procedure ShowLoading;
    procedure HideLoading;
  protected
    procedure ToolActionsChanged(sender: TObject);
    procedure InitToolActions;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init;
    procedure Print;
    procedure Reload;
    procedure CloseFile;
  public
    property ActiveViewer: izViewerFrame read GetActiveViewer;
  public
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property FieldName: string read FFieldName write FFieldName;
    property Folder: string read FFolder write SetFolder;
  public // Azioni documentali sul documento persistito
    // ID_OBJECT_FILE della riga corrente (0 = campo assente o dataset vuoto)
    function CurrentIdObjectFile: Int64;
    // OID della riga corrente, dal campo FieldNameOID (0 se non disponibile)
    function CurrentOid: Int64;
    // Il controller applicativo (gemello di quello dell'anteprima report,
    // stessa base TzDocumentActionsControllerBase): iniettato
    // dall'applicazione, mai posseduto dal viewer.
    property ActionsController: TzDocumentActionsController read FActionsController write SetActionsController;
  published
    property AllowedFileTypes: TzFileTypes read FAllowedFileTypes write SetAllowedFileTypes;

    property FileName: string read FFileName write SetFileName stored False;
    property FieldNameOID: string read FFieldNameOID write FFieldNameOID stored False;
    property FieldNameIdObjectFile: string read FFieldNameIdObjectFile write FFieldNameIdObjectFile stored False;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ID: string read FID write FID;
    property Locked: boolean read FLocked write SetLocked;
    property OnImportFile: TImportFileEvent read FOnImportFile write SetOnImportFile;
    property OnViewerCreated: TViewerCreatedEvent read FOnViewerCreated write FOnViewerCreated;
    property OnGetAzioniConfig: TzGetAzioniConfigEvent read FOnGetAzioniConfig write FOnGetAzioniConfig;
    property OnMostraVersioni: TzMostraVersioniEvent read FOnMostraVersioni write SetOnMostraVersioni;
  end;

implementation

uses
  Winapi.ShellAPI,
  zDX,
  zBaseLib,
  zToolConfigDlg,
  zMsg,
  zOffice.utils;

{$R *.dfm}

constructor TzMultiViewer.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FAllowedFileTypes := zAllFileTypes;
  FFieldName := '';
  FFieldNameOID := '';
  FFieldNameIdObjectFile := '';
  FID := '';

  PageControl.Properties.HideTabs := True;
  PageControl.ActivePageIndex := 0;

  zViewerWordFrame := nil;
  zViewerExcelFrame := nil;
  zViewerPdfFrame := nil;
  zViewerImageFrame := nil;
  zViewerMailFrame := nil;
  zViewerSynEditFrame := nil;

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;
  FzFileViewerProps := nil;

  FActionsController := nil;
  FAzioniConfigCache.Clear;
  FAzioniConfigCacheId := -1;
  WireDocActions;
  CreateActionsHelper;
end;

destructor TzMultiViewer.Destroy;
begin
  FreeAndNil(FToolActions);
  inherited;
end;

procedure TzMultiViewer.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');

  FFileName := '';

  if assigned(ActiveViewer) then
    ActiveViewer.CloseFile;

  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzMultiViewer.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
    if not(csDesigning in ComponentState) then
    begin
      try
        Init;
        Reload;
      except
        Application.HandleException(Self);
      end;
    end
end;

procedure TzMultiViewer.DataSourceDataChange(sender: TObject; Field: TField);
begin
  Reload;
end;

procedure TzMultiViewer.dbOpenFile;
var
  Field: TField;
  s: string;
begin
  SiMain.EnterMethod(Self, 'dbOpenFile');
  if not assigned(DataSet) then
    Exit;

  if DataSet.IsEmpty then
  begin
    if FileName <> '' then
      CloseFile;

    Exit;
  end;

  Field := DataSet.FindField(FieldName);

  if not assigned(Field) then
    Exit;

  s := Field.AsString;
  SiMain.LogString('Filename', s);

  if s <> '' then
    FileName := Folder + s
  else
    CloseFile;

  SiMain.LeaveMethod(Self, 'dbOpenFile');
end;

function TzMultiViewer.FileExistsAndNotLocked(const FileName: string): boolean;
begin
  SiMain.LogString('FileExistsAndNotLocked', FileName);
  result := False;

  ShowLoading;
  try

    if not Locked then
      result := FileExists(FileName);
  finally
    HideLoading;
  end;
end;

procedure TzMultiViewer.Init;
begin
  if Initialized then
    Exit;

  Initialized := True;
  InitToolActions;
end;

procedure TzMultiViewer.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FDataSet) then
    DataSet := nil;

  if (Operation = opRemove) and (AComponent = FActionsController) then
    FActionsController := nil;

  if assigned(ToolActions) then
    ToolActions.RemoveNotification(AComponent);
end;

procedure TzMultiViewer.OpenFile;
begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if Initialized then
    if FileName <> '' then
      if FileExistsAndNotLocked(FileName) then
      begin
        if not Locked then
        begin
          SetActiveViewer(FileName);

          if not assigned(ActiveViewer) then
            Exit;

          ShowLoading;
          try
            ActiveViewer.OpenFile(FileName);
          finally
            HideLoading;
          end;
        end;
      end
      else // not fileExists
        CloseFile;

  SiMain.LeaveMethod(Self, 'OpenFile');
end;

procedure TzMultiViewer.Print;
begin
  if assigned(ActiveViewer) then
    ActiveViewer.Print;
end;

procedure TzMultiViewer.Reload;
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TzMultiViewer.SetDataSet(const Value: TDataSet);
begin
  if FDataSet <> Value then
  begin
    FDataSet := Value;
    DataSource.DataSet := Value;
  end;
end;

procedure TzMultiViewer.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');
  FFileName := Value;

  if not FileExistsAndNotLocked(FileName) then
  begin
    CloseFile;
    ShowPage(ftNone);
  end
  else
    OpenFile;

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzMultiViewer.SetFolder(const Value: string);
begin
  FFolder := Trim(Value);

  if FFolder <> '' then
    FFolder := calcPath(FFolder);
end;

procedure TzMultiViewer.SetLocked(const Value: boolean);
begin
  if FLocked <> Value then
  begin
    FLocked := Value;
    if not Locked then
      Reload;
  end;
end;

procedure TzMultiViewer.TimerTimer(sender: TObject);
begin
  Timer.Enabled := False;
  dbOpenFile;
end;

/// ////////////////////////////////////////////////////////////

procedure TzMultiViewer.ShowLoading;
begin
  dxActivityIndicator.Active := True;
  dxActivityIndicator.BringToFront;
  Screen.Cursor := crHourGlass;
end;

procedure TzMultiViewer.HideLoading;
begin
  Screen.Cursor := crDefault;
  dxActivityIndicator.Active := False;
  dxActivityIndicator.SendToBack;
end;

procedure TzMultiViewer.ShowPage(zFileType: TzFileType);
begin
  case zFileType of
    ftNone:
      PageControl.ActivePage := tabNone;
    ftWord:
      PageControl.ActivePage := tabWord;
    ftExcel:
      PageControl.ActivePage := tabExcel;
    ftPdf:
      PageControl.ActivePage := tabPdf;
    ftImage:
      PageControl.ActivePage := tabImage;
    ftMail:
      PageControl.ActivePage := tabMail;
    ftTXT:
      PageControl.ActivePage := tabSynEdit;
    ftXML:
      PageControl.ActivePage := tabSynEdit;
    ftJSON:
      PageControl.ActivePage := tabSynEdit;
  end;

  UpdateBarManagersState;
  dxBarManagerNoneBar.Visible := assigned(FOnImportFile) and (PageControl.ActivePage = tabNone);
end;

procedure TzMultiViewer.CreateViewer(zFileType: TzFileType);
begin
  case zFileType of
    ftNone:
      ;
    ftWord:
      CreateViewerWord;
    ftExcel:
      CreateViewerExcel;
    ftPdf:
      CreateViewerPdf;
    ftImage:
      CreateViewerImage;
    ftMail:
      CreateViewerMail;
    ftTXT:
      CreateViewerSynEdit;
    ftXML:
      CreateViewerSynEdit;
    ftJSON:
      CreateViewerSynEdit;
  end;
end;

procedure TzMultiViewer.CreateViewerWord;
begin

  if not assigned(zViewerWordFrame) then
  begin
    zViewerWordFrame := TzViewerWordFrame.Create(Self);
    zViewerWordFrame.Parent := tabWord;
    zViewerWordFrame.Align := alClient;

    if assigned(FOnImportFile) then
      zViewerWordFrame.OnImportFile := OnImportFileWord;
    doViewerCreated(ftWord);
  end;
end;

procedure TzMultiViewer.CreateViewerExcel;
begin

  if not assigned(zViewerExcelFrame) then
  begin
    zViewerExcelFrame := TzViewerExcelFrame.Create(Self);
    zViewerExcelFrame.Parent := tabExcel;
    zViewerExcelFrame.Align := alClient;

    if assigned(FOnImportFile) then
      zViewerExcelFrame.OnImportFile := OnImportFileExcel;
    doViewerCreated(ftExcel);
  end;
end;

procedure TzMultiViewer.CreateViewerPdf;
begin

  if not assigned(zViewerPdfFrame) then
  begin
    zViewerPdfFrame := TzViewerPdfFrame.Create(Self);
    zViewerPdfFrame.Parent := tabPdf;
    zViewerPdfFrame.Align := alClient;

    if assigned(FOnImportFile) then
      zViewerPdfFrame.OnImportFile := OnImportFilePdf;
    doViewerCreated(ftPdf);
  end;
end;

procedure TzMultiViewer.CreateViewerImage;
begin

  if not assigned(zViewerImageFrame) then
  begin
    zViewerImageFrame := TzViewerImageFrame.Create(Self);
    zViewerImageFrame.Parent := tabImage;
    zViewerImageFrame.Align := alClient;

    if assigned(FOnImportFile) then
      zViewerImageFrame.OnImportFile := OnImportFileImage;
    doViewerCreated(ftImage);
  end;
end;

procedure TzMultiViewer.CreateViewerMail;
begin

  if not assigned(zViewerMailFrame) then
  begin
    zViewerMailFrame := TzViewerMailFrame.Create(Self);
    zViewerMailFrame.Parent := tabMail;
    zViewerMailFrame.Align := alClient;

    if assigned(FOnImportFile) then
      zViewerMailFrame.OnImportFile := OnImportFileMail;
    doViewerCreated(ftMail);
  end;
end;

procedure TzMultiViewer.CreateViewerSynEdit;
begin
  if not assigned(zViewerSynEditFrame) then
  begin
    zViewerSynEditFrame := TzViewerSynEditFrame.Create(Self);
    zViewerSynEditFrame.Parent := tabSynEdit;
    zViewerSynEditFrame.Align := alClient;

    if assigned(FOnImportFile) then
      zViewerSynEditFrame.OnImportFile := OnImportFileSynEdit;
    doViewerCreated(ftTXT);
  end;
end;

procedure TzMultiViewer.doImportFile(const FileName: string);
begin

  if assigned(FOnImportFile) then
    OnImportFile(Self, FileName);
end;

procedure TzMultiViewer.ImportaNoneAccept(sender: TObject);
begin
  doImportFile(ImportaNone.Dialog.FileName);
end;

procedure TzMultiViewer.ImportaNoneUpdate(sender: TObject);
begin
  ImportaNone.Visible := assigned(FOnImportFile);
  dxBarManagerNoneBar.Visible := assigned(FOnImportFile) and (PageControl.ActivePage = tabNone);
end;

procedure TzMultiViewer.SetOnImportFile(const Value: TImportFileEvent);
begin
  FOnImportFile := Value;
  dxBarManagerNoneBar.Visible := assigned(FOnImportFile) and (PageControl.ActivePage = tabNone);
end;

procedure TzMultiViewer.doViewerCreated(zFileType: TzFileType);
begin

  if assigned(FOnViewerCreated) then
    OnViewerCreated(Self, zFileType);
end;

procedure TzMultiViewer.SetActiveViewer(const FileName: string);
var
  zFileType: TzFileType;
begin
  zFileType := GetViewerType(FileName);
  CreateViewer(zFileType);
  ShowPage(zFileType);

  if assigned(ActiveViewer) then
    ActiveViewer.SetAllowedImportFileTypes(AllowedFileTypes);

  InitToolActions;
end;

procedure TzMultiViewer.UpdateBarManagersState;
var
  ActivePage: TcxTabSheet;

  procedure SetBarActive(Frame: TFrame; Bar: TdxBar; ActiveTab: TcxTabSheet);
  begin
    if not assigned(Frame) or not assigned(Bar) then
      Exit;
    // La barra del viewer non attivo viene resa non visibile cosi' i suoi
    // item link escono dal traversal di UpdateActions/InitiateAction. Questo
    // evita l'AV su azioni dello spreadsheet (paste/copy/cut) che interrogano
    // selection/view non pronte dei frame non visibili.
    Bar.Visible := (ActivePage = ActiveTab);
  end;

begin
  ActivePage := PageControl.ActivePage as TcxTabSheet;

  if assigned(zViewerWordFrame) then
    SetBarActive(zViewerWordFrame, zViewerWordFrame.dxBarManagerBar, tabWord);
  if assigned(zViewerExcelFrame) then
    SetBarActive(zViewerExcelFrame, zViewerExcelFrame.dxBarManagerBar, tabExcel);
  if assigned(zViewerPdfFrame) then
    SetBarActive(zViewerPdfFrame, zViewerPdfFrame.dxBarManagerBar, tabPdf);
  if assigned(zViewerImageFrame) then
    SetBarActive(zViewerImageFrame, zViewerImageFrame.dxBarManagerBar, tabImage);
  if assigned(zViewerMailFrame) then
    SetBarActive(zViewerMailFrame, zViewerMailFrame.dxBarManagerBar, tabMail);
  if assigned(zViewerSynEditFrame) then
    SetBarActive(zViewerSynEditFrame, zViewerSynEditFrame.dxBarManagerBar, tabSynEdit);
end;

function TzMultiViewer.GetViewerType(const FileName: string): TzFileType;
begin
  result := TzFileType.FromFileName(FileName);
end;

function TzMultiViewer.GetActiveViewer: izViewerFrame;
begin
  result := nil;

  if PageControl.ActivePage = tabNone then
    result := nil
  else
    if PageControl.ActivePage = tabWord then
      result := zViewerWordFrame
    else
      if PageControl.ActivePage = tabExcel then
        result := zViewerExcelFrame
      else
        if PageControl.ActivePage = tabPdf then
          result := zViewerPdfFrame
        else
          if PageControl.ActivePage = tabImage then
            result := zViewerImageFrame
          else
            if PageControl.ActivePage = tabMail then
              result := zViewerMailFrame
            else
              if PageControl.ActivePage = tabSynEdit then
                result := zViewerSynEditFrame;
end;

function TzMultiViewer.GetActiveBar: TdxBar;
begin
  result := nil;
  if PageControl.ActivePage = tabWord then
  begin
    if assigned(zViewerWordFrame) then
      result := zViewerWordFrame.dxBarManagerBar;
  end
  else
    if PageControl.ActivePage = tabExcel then
    begin
      if assigned(zViewerExcelFrame) then
        result := zViewerExcelFrame.dxBarManagerBar;
    end
    else
      if PageControl.ActivePage = tabPdf then
      begin
        if assigned(zViewerPdfFrame) then
          result := zViewerPdfFrame.dxBarManagerBar;
      end
      else
        if PageControl.ActivePage = tabImage then
        begin
          if assigned(zViewerImageFrame) then
            result := zViewerImageFrame.dxBarManagerBar;
        end
        else
          if PageControl.ActivePage = tabMail then
          begin
            if assigned(zViewerMailFrame) then
              result := zViewerMailFrame.dxBarManagerBar;
          end
          else
            if PageControl.ActivePage = tabSynEdit then
            begin
              if assigned(zViewerSynEditFrame) then
                result := zViewerSynEditFrame.dxBarManagerBar;
            end;
end;

procedure TzMultiViewer.OnImportFileExcel(sender: TzViewerExcelFrame; const FileName: string);
begin
  doImportFile(FileName);
end;

procedure TzMultiViewer.OnImportFileImage(sender: TzViewerImageFrame; const FileName: string);
begin
  doImportFile(FileName);
end;

procedure TzMultiViewer.OnImportFileMail(sender: TzViewerMailFrame; const FileName: string);
begin
  doImportFile(FileName);
end;

procedure TzMultiViewer.OnImportFilePdf(sender: TzViewerPdfFrame; const FileName: string);
begin
  doImportFile(FileName);
end;

procedure TzMultiViewer.OnImportFileSynEdit(sender: TzViewerSynEditFrame; const FileName: string);
begin
  doImportFile(FileName);
end;

procedure TzMultiViewer.OnImportFileWord(sender: TzViewerWordFrame; const FileName: string);
begin
  doImportFile(FileName);
end;

procedure TzMultiViewer.SetAllowedFileTypes(const Value: TzFileTypes);
begin
  FAllowedFileTypes := Value;

  if assigned(ActiveViewer) then
    ActiveViewer.SetAllowedImportFileTypes(Value);
end;

{ Azioni documentali sul documento persistito }

function TzMultiViewer.CurrentIdObjectFile: Int64;
var
  Field: TField;
begin
  result := 0;

  if not assigned(DataSet) or (FFieldNameIdObjectFile = '') then
    Exit;

  if DataSet.IsEmpty then
    Exit;

  Field := DataSet.FindField(FFieldNameIdObjectFile);
  if assigned(Field) and not Field.IsNull then
    result := Field.AsLargeInt;
end;

function TzMultiViewer.CurrentOid: Int64;
var
  Field: TField;
begin
  result := 0;

  if not assigned(DataSet) or (FFieldNameOID = '') then
    Exit;

  if DataSet.IsEmpty then
    Exit;

  Field := DataSet.FindField(FFieldNameOID);
  if assigned(Field) and not Field.IsNull then
    result := Field.AsLargeInt;
end;

function TzMultiViewer.AzioniConfigCorrente: TzJsonAzioniConfig;
var
  IdObjectFile: Int64;
begin
  // Cache per documento: la config del profilo e' congelata sulla riga,
  // ricaricarla ad ogni OnUpdate delle action sarebbe una query per idle.
  IdObjectFile := CurrentIdObjectFile;

  if IdObjectFile <> FAzioniConfigCacheId then
  begin
    FAzioniConfigCache.Clear;

    if IdObjectFile <> 0 then
      // di norma le azioni le fornisce il controller (profilo della radice
      // della catena); l'evento resta per i casi in cui l'applicazione
      // voglia deciderle da se'
      if assigned(FOnGetAzioniConfig) then
        FOnGetAzioniConfig(Self, IdObjectFile, FAzioniConfigCache)
      else
        if assigned(FActionsController) then
          FAzioniConfigCache := FActionsController.AzioniDelDocumento(IdObjectFile);

    FAzioniConfigCacheId := IdObjectFile;
  end;

  result := FAzioniConfigCache;
end;

function TzMultiViewer.BuildDocumentoContesto: TzDocumentoContesto;
begin
  // Costruito ad ogni chiamata, mai memorizzato (stesso patto del manager
  // dei report: il controller e' senza stato).
  result.Clear;
  result.IdObjectFile := CurrentIdObjectFile;
  result.Oid := CurrentOid;
  result.ReportName := '';
  result.AzioniConfig := AzioniConfigCorrente;
end;

procedure TzMultiViewer.WireDocActions;
begin
  // Le TAction stanno nel DFM (nomi convenzionali dell'helper, immagini
  // della cxImageList); qui si agganciano solo i gestori. Il Tag delle 5
  // documentali lo imposta InizializzaAzioniDocumento.
  actDocFirma.OnUpdate := DocActionUpdate;
  actDocFirma.OnExecute := DocActionExecute;
  actDocProtocolla.OnUpdate := DocActionUpdate;
  actDocProtocolla.OnExecute := DocActionExecute;
  actDocConserva.OnUpdate := DocActionUpdate;
  actDocConserva.OnExecute := DocActionExecute;
  actDocInviaPec.OnUpdate := DocActionUpdate;
  actDocInviaPec.OnExecute := DocActionExecute;
  actDocInviaMail.OnUpdate := DocActionUpdate;
  actDocInviaMail.OnExecute := DocActionExecute;

  actDocAggiornaStato.OnUpdate := DocAggiornaStatoUpdate;
  actDocAggiornaStato.OnExecute := DocAggiornaStatoExecute;

  actDocVersioni.OnUpdate := DocVersioniUpdate;
  actDocVersioni.OnExecute := DocVersioniExecute;

  // Nel multiviewer il "Genera allegato" non ha pulsante (provvede Importa):
  // senza OnGeneraAllegato l'helper lo tiene nascosto per costruzione.
  actDocGeneraAllegato.OnUpdate := DocGeneraAllegatoUpdate;
  actDocGeneraAllegato.OnExecute := DocGeneraAllegatoExecute;
end;

procedure TzMultiViewer.CreateActionsHelper;
begin
  FActionsHelper := TzDocumentActionsBarHelper.Create(Self,
    function(Azione: TzAzioneDocumento): TzAzioneDocumentoStato
    begin
      if assigned(FActionsController) then
        result := FActionsController.Stato(Azione, BuildDocumentoContesto)
      else
        result := adsNonDisponibile;
    end,

    function(Azione: TzAzioneDocumento): string
    begin
      if assigned(FActionsController) then
        result := FActionsController.MotivoBlocco(Azione, BuildDocumentoContesto)
      else
        result := '';
    end,

    function(Azione: TzAzioneDocumento): string
    begin
      if assigned(FActionsController) then
        result := FActionsController.Estremi(Azione, BuildDocumentoContesto)
      else
        result := '';
    end,

    function: boolean
    begin
      // nel multiviewer il documento e' persistito per definizione
      result := CurrentIdObjectFile <> 0;
    end);

  FActionsHelper.OnEsegui := procedure(Azione: TzAzioneDocumento)
    begin
      if assigned(FActionsController) then
        FActionsController.Esegui(Azione, BuildDocumentoContesto);
    end;

  FActionsHelper.OnVediEstremi := procedure(Azione: TzAzioneDocumento)
    begin
      if assigned(FActionsController) then
        ConfirmOk(DescrizioneAzioneDocumento(Azione) + ': ' + FActionsController.Estremi(Azione, BuildDocumentoContesto), mtInformation);
    end;

  FActionsHelper.OnAggiornaStato := procedure(Azione: TzAzioneDocumento)
    begin
      if assigned(FActionsController) then
        FActionsController.AggiornaStato(Azione, BuildDocumentoContesto);
    end;

  // OnVediVersioni dell'helper viene agganciato/sganciato da
  // SetOnMostraVersioni: il comando compare solo quando il gestore esiste.

  FActionsHelper.InizializzaAzioniDocumento(ActionList);
end;

procedure TzMultiViewer.SetActionsController(const Value: TzDocumentActionsController);
begin
  if FActionsController <> Value then
  begin
    if assigned(FActionsController) then
      FActionsController.RemoveFreeNotification(Self);

    FActionsController := Value;

    if assigned(FActionsController) then
      FActionsController.FreeNotification(Self);

    FAzioniConfigCacheId := -1;
    InitToolActions;
  end;
end;

procedure TzMultiViewer.SetOnMostraVersioni(const Value: TzMostraVersioniEvent);
begin
  FOnMostraVersioni := Value;

  if assigned(Value) then
    FActionsHelper.OnVediVersioni :=
    procedure begin
  if assigned(FOnMostraVersioni) then
    FOnMostraVersioni(Self, CurrentIdObjectFile);
end
else
  FActionsHelper.OnVediVersioni := nil;
end;

function TzMultiViewer.GetActiveViewerFrame: TFrame;
begin
  result := nil;

  if PageControl.ActivePage = tabWord then
    result := zViewerWordFrame
  else
    if PageControl.ActivePage = tabExcel then
      result := zViewerExcelFrame
    else
      if PageControl.ActivePage = tabPdf then
        result := zViewerPdfFrame
      else
        if PageControl.ActivePage = tabImage then
          result := zViewerImageFrame
        else
          if PageControl.ActivePage = tabMail then
            result := zViewerMailFrame
          else
            if PageControl.ActivePage = tabSynEdit then
              result := zViewerSynEditFrame;
end;

procedure TzMultiViewer.InitDocActionButtons(ActiveBar: TdxBar);
var
  ViewerFrame: TFrame;

  // Pulsante messo A DISEGNO nel DFM del frame (nome convenzionale
  // btnDoc*): qui riceve solo l'Action. L'icona resta quella scelta a
  // disegno sull'imagelist del frame: l'ImageIndex dell'azione punta
  // all'imagelist del multiviewer e non avrebbe senso sul BarManager del
  // frame, per questo viene ripristinato dopo l'aggancio.
  function WireDesignButton(const NomeBottone: string; Action: TAction): boolean;
  var
    Componente: TComponent;
    Bottone: TdxBarButton;
    ImageIndexDisegno: Integer;
  begin
    result := False;

    if not assigned(ViewerFrame) then
      Exit;

    Componente := ViewerFrame.FindComponent(NomeBottone);
    if not(Componente is TdxBarButton) then
      Exit;

    Bottone := TdxBarButton(Componente);
    if Bottone.Action <> Action then
    begin
      ImageIndexDisegno := Bottone.ImageIndex;
      Bottone.Action := Action;
      Bottone.ImageIndex := ImageIndexDisegno;
    end;

    result := True;
  end;

  procedure AddButton(const NomeBottone: string; Action: TAction);
  var
    btn: TdxBarButton;
  begin
    // prima scelta: il pulsante disegnato nel DFM del frame attivo
    if WireDesignButton(NomeBottone, Action) then
      Exit;

    // ripiego: creazione dinamica, solo col controller iniettato (i frame
    // senza pulsanti a disegno si comportano come prima)
    if not assigned(FActionsController) then
      Exit;

    if TzToolActions.ActionExistsInBar(ActiveBar, Action) then
      Exit;

    btn := ActiveBar.BarManager.AddItem(TdxBarButton) as TdxBarButton;
    btn.Action := Action;
    btn.PaintStyle := psCaptionGlyph;
    ActiveBar.ItemLinks.Add(btn);
  end;

begin
  ViewerFrame := GetActiveViewerFrame;

  // L'aggancio ai pulsanti di disegno avviene SEMPRE, anche senza
  // controller: cosi' l'OnUpdate delle azioni (adsNonDisponibile) li
  // nasconde a runtime invece di lasciarli inerti sulla barra.
  AddButton('btnDocFirma', actDocFirma);
  AddButton('btnDocProtocolla', actDocProtocolla);
  AddButton('btnDocConserva', actDocConserva);
  AddButton('btnDocInviaPec', actDocInviaPec);
  AddButton('btnDocInviaMail', actDocInviaMail);
  AddButton('btnDocAggiornaStato', actDocAggiornaStato);
  AddButton('btnDocVersioni', actDocVersioni);
  // actDocGeneraAllegato: nessun pulsante, nel multiviewer provvede Importa
end;

procedure TzMultiViewer.DocActionUpdate(sender: TObject);
begin
  FActionsHelper.AggiornaAzioneDocumento(TzAzioneDocumento((sender as TAction).Tag), sender as TAction);
end;

procedure TzMultiViewer.DocActionExecute(sender: TObject);
begin
  FActionsHelper.EseguiAzioneDocumento(TzAzioneDocumento((sender as TAction).Tag));
end;

procedure TzMultiViewer.DocAggiornaStatoUpdate(sender: TObject);
begin
  FActionsHelper.AggiornaComandoAggiornaStato(sender as TAction);
end;

procedure TzMultiViewer.DocAggiornaStatoExecute(sender: TObject);
begin
  FActionsHelper.EseguiComandoAggiornaStato;
end;

procedure TzMultiViewer.DocVersioniUpdate(sender: TObject);
begin
  FActionsHelper.AggiornaComandoVersioni(sender as TAction);
end;

procedure TzMultiViewer.DocVersioniExecute(sender: TObject);
begin
  FActionsHelper.EseguiComandoVersioni;
end;

procedure TzMultiViewer.DocGeneraAllegatoUpdate(sender: TObject);
begin
  FActionsHelper.AggiornaComandoGeneraAllegato(sender as TAction);
end;

procedure TzMultiViewer.DocGeneraAllegatoExecute(sender: TObject);
begin
  FActionsHelper.EseguiComandoGeneraAllegato;
end;

{ Metodi IzBaseComponent / IzBaseDbComponent }

function TzMultiViewer.GetComponentType: TzComponentType;
begin
  result := ctFile;
end;

function TzMultiViewer.GetToolbar: TdxBar; // IzBaseComponent.GetToolbar
begin
  result := GetActiveBar; // barra del viewer attivo (puo' essere nil se nessun viewer attivo)
end;

function TzMultiViewer.GetID: string;
begin
  result := ID;
end;

procedure TzMultiViewer.SetID(const Value: string);
begin
  ID := Value;
end;

function TzMultiViewer.GetToolActions: TzToolActions;
begin
  result := FToolActions;
end;

procedure TzMultiViewer.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

function TzMultiViewer.GetzDataSet: TzFbDataSet;
begin
  result := FDataSet as TzFbDataSet;
end;

procedure TzMultiViewer.SetzDataSet(const Value: TzFbDataSet);
begin
  SetDataSet(Value);
end;

function TzMultiViewer.EnsureProps: TzFileViewerProps;
begin
  if not assigned(FzFileViewerProps) then
    if assigned(Base) and (ID <> '') then
      FzFileViewerProps := Base.zFiles.get(ID, True);
  result := FzFileViewerProps;
end;

function TzMultiViewer.GetActionOwnerName: string;
begin
  if EnsureProps <> nil then
    result := FzFileViewerProps.ActionOwnerName
  else
    result := '';
end;

procedure TzMultiViewer.SetActionOwnerName(const Value: string);
begin
  if EnsureProps <> nil then
    FzFileViewerProps.ActionOwnerName := Value;
end;

function TzMultiViewer.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, GetActionOwnerName);
end;

procedure TzMultiViewer.RebuildToolbar; // IzBaseComponent.RebuildToolbar - solo azioni (viewer non filtrabile)
begin
  InitToolActions;
end;

procedure TzMultiViewer.RebuildActions;
begin
  RebuildToolbar;
  if assigned(FzFileViewerProps) then
    FzFileViewerProps.SaveToBase(True);
end;

function TzMultiViewer.ConfigTitle: string;
begin
  result := ID;
end;

function TzMultiViewer.IsAdmin: boolean;
begin
  result := assigned(Base) and Base.IsAdmin;
end;

procedure TzMultiViewer.ToolActionsChanged(sender: TObject);
begin
  InitToolActions;
end;

procedure TzMultiViewer.InitToolActions;
var
  ActiveBar: TdxBar;
  btn: TdxBarButton;
begin
  if GetProps = nil then
    Exit;

  ActiveBar := GetActiveBar;

  if not assigned(ActiveBar) then
    Exit;

  TzActionBuilder.BuildFromProps(GetProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(ActiveBar, nil, otOther);

  // gruppo "Documento": le azioni documentali sul documento persistito,
  // presenti solo quando l'applicazione ha iniettato il controller
  InitDocActionButtons(ActiveBar);

  if IsAdmin then
  begin
    if not TzToolActions.ActionExistsInBar(ActiveBar, EditTools) then
    begin
      btn := ActiveBar.BarManager.AddItem(TdxBarButton) as TdxBarButton;
      btn.Action := EditTools;
      btn.PaintStyle := psCaptionGlyph;
      ActiveBar.ItemLinks.Add(btn);
    end;
  end;
end;

function TzMultiViewer.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
begin
  result := nil;

  if not assigned(Action) then
    Exit;

  if GetProps = nil then
    Exit;

  result := GetProps.ToolActions.Find(Action.Name);
  if not assigned(result) then
  begin
    result := GetProps.ToolActions.Add;
    result.Name := Action.Name;
    result.FromCode := True;
  end;
end;

procedure TzMultiViewer.EditToolsExecute(sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzMultiViewer.EditToolsUpdate(sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

function TzMultiViewer.GetProps: TzBaseComponentProps;
begin
  if EnsureProps <> nil then
    result := FzFileViewerProps
  else
    result := nil;
end;

procedure TzMultiViewer.ImportaNoneBeforeExecute(sender: TObject);
begin
  ImportaNone.Dialog.DefaultExt := DefaultExtForFileTypes(AllowedFileTypes);
  ImportaNone.Dialog.Filter := FilterForFileTypes(AllowedFileTypes);
end;

end.

