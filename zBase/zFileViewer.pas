unit zFileViewer;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  DB,
  ExtCtrls,
  Menus,
  ImgList,
  ActnList,
  StdActns,
  contnrs,
  zToolActions,
  StdCtrls,
  ExtDlgs,
  ToolWin,
  ComCtrls,
  cxClasses,
  dxBar,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  System.ImageList,
  System.Actions,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxPDFDocument,
  dxBarBuiltInMenu,
  dxCustomPreview,
  dxPDFViewer,
  dxPDFViewerActions,
  dxPrinting,
  dxActions,
  cxImageList,
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
  cxDrawTextUtils,
  dxPSPrVwStd,
  dxPSPrVwAdv,
  dxPSPrVwRibbon,
  dxPScxPageControlProducer,
  dxPSdxPDFViewerLnk,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxPDFDocumentViewer,
  dxStatusBar,
  dxPDFBase,
  dxPDFText,
  dxPDFTypes,
  dxPDFRecognizedObject,
  dxActivityIndicator,
  dxCore,
  dxPDFCore,
  dxX509Certificate,
  dxPrintUtils,
  dxPDFForm,
  dxPDFFormData,
  dxFileActions,
  dxPSRichEditControlLnk,
  dxPSdxSpreadSheetLnk,
  dxUIAClasses,
  zSystem,
  zFbDataSet,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TFileType = (ftNull, ftImage, ftPdf);

type
  TzFileViewer = class;

  TImportFileEvent = procedure(sender: TzFileViewer; const FileName: string) of object;
  TGenerateFromTemplateEvent = procedure(sender: TzFileViewer) of object;
  TFillFieldProc = reference to procedure(pdf: TdxPDFDocument; AField: TdxPDFCustomField; var Continue: boolean);
  TBeforeSavePdfProc = reference to procedure(pdf: TdxPDFDocument);

  TzFileViewer = class(TFrame, IzBaseComponent, IzBaseDbComponent)
    DataSource: TDataSource;
    Timer: TTimer;
    StatusBar: TdxStatusBar;
    dxPDFViewer: TdxPDFViewer;
    dxBarManager: TdxBarManager;
    dxBarButtonOpen: TdxBarButton;
    dxBarButtonClose: TdxBarButton;
    dxBarButtonPrint: TdxBarButton;
    dxBarButtonSelectTool: TdxBarButton;
    dxBarButtonHandTool: TdxBarButton;
    dxBarButtonSelectAll: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButtonFirstPage: TdxBarButton;
    dxBarButtonPreviousPage: TdxBarButton;
    dxBarButtonNextPage: TdxBarButton;
    dxBarButtonLastPage: TdxBarButton;
    dxBarButtonPreviousView: TdxBarButton;
    dxBarButtonNextView: TdxBarButton;
    dxBarSubItem2: TdxBarSubItem;
    dxBarButtonRotateClockwise: TdxBarButton;
    dxBarButtonRotateCounterclockwise: TdxBarButton;
    dxBarButtonZoomOut: TdxBarButton;
    dxBarButtonZoomIn: TdxBarButton;
    dxBarSubItem3: TdxBarSubItem;
    dxBarButton10: TdxBarButton;
    dxBarButton25: TdxBarButton;
    dxBarButton50: TdxBarButton;
    dxBarButton75: TdxBarButton;
    dxBarButton100: TdxBarButton;
    dxBarButton125: TdxBarButton;
    dxBarButton150: TdxBarButton;
    dxBarButton200: TdxBarButton;
    dxBarButton400: TdxBarButton;
    dxBarButton500: TdxBarButton;
    dxBarButtonActualSize: TdxBarButton;
    dxBarButtonZoomtoPageLevel: TdxBarButton;
    dxBarButtonFitWidth: TdxBarButton;
    ActionList: TActionList;
    dxPDFViewerOpenDocument: TdxPDFViewerOpenDocument;
    dxPDFViewerCloseDocument: TdxPDFViewerCloseDocument;
    dxPDFViewerShowPrintForm: TdxPDFViewerShowPrintForm;
    dxPDFViewerSelectTool: TdxPDFViewerSelectTool;
    dxPDFViewerHandTool: TdxPDFViewerHandTool;
    dxPDFViewerSelectAll: TdxPDFViewerSelectAll;
    dxPDFViewerGoToFirstPage: TdxPDFViewerGoToFirstPage;
    dxPDFViewerGoToPrevPage: TdxPDFViewerGoToPrevPage;
    dxPDFViewerGoToNextPage: TdxPDFViewerGoToNextPage;
    dxPDFViewerGoToLastPage: TdxPDFViewerGoToLastPage;
    dxPDFViewerGoToPrevView: TdxPDFViewerGoToPrevView;
    dxPDFViewerGoToNextView: TdxPDFViewerGoToNextView;
    dxPDFViewerRotateClockwise: TdxPDFViewerRotateClockwise;
    dxPDFViewerRotateCounterClockwise: TdxPDFViewerRotateCounterClockwise;
    dxPDFViewerZoomOut: TdxPDFViewerZoomOut;
    dxPDFViewerZoomIn: TdxPDFViewerZoomIn;
    dxPDFViewerZoom10: TdxPDFViewerZoom10;
    dxPDFViewerZoom25: TdxPDFViewerZoom25;
    dxPDFViewerZoom50: TdxPDFViewerZoom50;
    dxPDFViewerZoom75: TdxPDFViewerZoom75;
    dxPDFViewerZoom100: TdxPDFViewerZoom100;
    dxPDFViewerZoom125: TdxPDFViewerZoom125;
    dxPDFViewerZoom150: TdxPDFViewerZoom150;
    dxPDFViewerZoom200: TdxPDFViewerZoom200;
    dxPDFViewerZoom400: TdxPDFViewerZoom400;
    dxPDFViewerZoom500: TdxPDFViewerZoom500;
    dxPDFViewerZoomActualSize: TdxPDFViewerZoomActualSize;
    dxPDFViewerZoomToPageLevel: TdxPDFViewerZoomToPageLevel;
    dxPDFViewerZoomFitWidth: TdxPDFViewerZoomFitWidth;
    dxBarButton1: TdxBarButton;
    Importa: TdxFileOpen;
    dxBarManagerBar: TdxBar;
    dxPDFViewerFind: TdxPDFViewerFind;
    dxBarButton2: TdxBarButton;
    FileSaveAs: TdxFileSaveAs;
    dxBarButton3: TdxBarButton;
    dxComponentPrinter: TdxComponentPrinter;
    dxComponentPrinterLink: TdxPDFViewerReportLink;
    ApriConAdobe: TAction;
    dxBarButton4: TdxBarButton;
    dxActivityIndicator: TdxActivityIndicator;
    GeneraDaTemplate: TAction;
    dxBarButton5: TdxBarButton;
    EditTools: TAction;
    dxBarButton6: TdxBarButton;
    procedure DataSourceDataChange(sender: TObject; Field: TField);
    procedure TimerTimer(sender: TObject);
    procedure AcroPDFMessage(sender: TObject);
    procedure ApriConAdobeExecute(sender: TObject);
    procedure dxPDFViewerDocumentLoaded(ASender: TdxPDFDocument; const AInfo: TdxPDFDocumentLoadInfo);
    procedure dxPDFViewerSelectedPageChanged(sender: TObject; APageIndex: Integer);
    procedure EditToolsExecute(sender: TObject);
    procedure EditToolsUpdate(sender: TObject);
    procedure FileSaveAsAccept(sender: TObject);
    procedure GeneraDaTemplateExecute(sender: TObject);
    procedure GeneraDaTemplateUpdate(sender: TObject);
    procedure ImportaAccept(sender: TObject);
    procedure ImportaUpdate(sender: TObject);
    procedure SalvaExecute(sender: TObject);
  private // Metodi IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
    FToolActions: TzToolActions;
    function GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
    procedure SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
    function GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
    procedure SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
    function GetID: string; // IzBaseComponent.GetID
    procedure SetID(const Value: string); // IzBaseComponent.SetID
    function GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
    function GetToolbar: TdxBar; // IzBaseComponent.GetToolbar
  private // Metodi IzBaseComponent (config azioni)
    FzFileViewerProps: TzFileViewerProps;
    function EnsureProps: TzFileViewerProps;
    function GetProps: TzBaseComponentProps;
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    procedure RebuildToolbar;
    function ConfigTitle: string;
    function IsAdmin: boolean;
  private
    Initialized: boolean;
    Loading: boolean;
    FDataSet: TDataSet;
    FFieldName_FileName: string;
    FFieldName_ID: string;
    FFieldName: string;
    FFileName: string;
    FFolder: string;
    FLocked: boolean;
    HighlightedRegionsCollection: TCollection;
    procedure SetDataSet(const Value: TDataSet);
    procedure SetFileName(const Value: string);
    procedure SetFolder(const Value: string);
    procedure SetLocked(const Value: boolean);
    procedure UpdateStatusBar;
    function FileExistsAndNotLocked(const FileName: string): boolean;
  private
    FFieldNameOID: string;
    FID: string;
    FOnImportFile: TImportFileEvent;
    FOnGenerateFromTemplate: TGenerateFromTemplateEvent;
  private
    procedure ShowLoading;
    procedure HideLoading;
  protected
    procedure ToolActionsChanged(sender: TObject);
    procedure InitToolActions;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  protected
    OldActiveControl: TWinControl;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure OpenFile;
    procedure dbOpenFile;
    //
    procedure gtPDFViewerViewerChange(sender: TObject);
    procedure Clear;
  public
    FileType: TFileType;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseFile;
    procedure Init;
    procedure Print;
    procedure Reload;
    procedure ExecuteToolConfig;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property FieldNameOID: string read FFieldNameOID write FFieldNameOID;
    property FieldName: string read FFieldName write FFieldName;
    property Folder: string read FFolder write SetFolder;
  public
    // eliminare
    procedure GenerateFromTemplate(DataSet: TDataSet; const TemplateFileName: string; DestFileName: string; const FillFieldProc: TFillFieldProc = nil; const BeforeSavePdfProc: TBeforeSavePdfProc = nil);
  published
    property FileName: string read FFileName write SetFileName stored False;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ID: string read FID write FID;
    property Locked: boolean read FLocked write SetLocked;
    property OnImportFile: TImportFileEvent read FOnImportFile write FOnImportFile;
    property OnGenerateFromTemplate: TGenerateFromTemplateEvent read FOnGenerateFromTemplate write FOnGenerateFromTemplate;
  end;

var
  FrameViewer: TzFileViewer;

function CreateFileViewer(Owner: TComponent; Parent: TWinControl; const Name: string = 'zFileViewer'; Align: TAlign = alClient): TzFileViewer;

implementation

uses
  Winapi.ActiveX,
  Winapi.ShellAPI,
  System.IOUtils,
  System.Math,
  zBaseLib,
  zLocalizer,
  zMsg,
  zdx,
  zToolConfigDlg;

const
  ZoomIncrement = 25;

const
  idxImage090 = 10;
  idxImage180 = 11;
  idxImage270 = 12;
  idxImage360 = 13;
{$R *.dfm}

function CreateFileViewer(Owner: TComponent; Parent: TWinControl; const Name: string = 'zFileViewer'; Align: TAlign = alClient): TzFileViewer;
begin
  result := TzFileViewer.Create(Owner);
  result.Name := Name;
  result.Parent := Parent;
  result.Align := Align;
end;

function TzFileViewer.GetComponentType: TzComponentType; // IzBaseComponent.GetComponentType
begin
  result := ctFile;
end;

function TzFileViewer.GetID: string; // IzBaseComponent.GetID
begin
  result := ID;
end;

procedure TzFileViewer.SetID(const Value: string); // IzBaseComponent.SetID
begin
  ID := Value;
end;

function TzFileViewer.GetToolActions: TzToolActions; // IzBaseComponent.GetToolActions
begin
  result := FToolActions;
end;

function TzFileViewer.GetToolbar: TdxBar;
begin
  result := dxBarManagerBar;
end;

function TzFileViewer.GetzDataSet: TzFbDataSet; // IzBaseDbComponent.GetzDataSet
begin
  result := FDataSet as TzFbDataSet;
end;

procedure TzFileViewer.SetzDataSet(const Value: TzFbDataSet); // IzBaseDbComponent.SetzDataSet
begin
  SetDataSet(Value);
end;

constructor TzFileViewer.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);

  Initialized := False;
  FID := '';
  FLocked := False;
  Loading := False;
  FFieldName := 'FULL_FILE_NAME';
  FFieldNameOID := '';
  FFolder := '';
  FDataSet := nil;
  FOnImportFile := nil;
  FOnGenerateFromTemplate := nil;
  Timer.Enabled := False;

  // senza la clessidra globale di ExpressPrinting, come gli altri visualizzatori:
  // vedi Tdx.InitPrinter
  dx.InitPrinter(dxComponentPrinter);

  Clear;
  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;
  FzFileViewerProps := nil;
end;

procedure TzFileViewer.DataSourceDataChange(sender: TObject; Field: TField);
begin
  inherited;
  // DIV-FVW-2: la modifica di un campo diverso da quello del file non ricarica il PDF
  if (not Assigned(Field)) or SameText(Field.FieldName, FieldName) then
    Reload;
end;

procedure TzFileViewer.dbOpenFile;
var
  Field: TField;
  s: string;
begin
  SiMain.EnterMethod(Self, 'dbOpenFile');
  if not Assigned(DataSet) then
    Exit;

  if DataSet.IsEmpty then
  begin
    SiMain.LogVerbose('dbOpenFile: dataset vuoto');

    if FileName <> '' then
      Clear;

    Exit;
  end;

  Field := DataSet.FindField(FieldName);

  if not Assigned(Field) then
  begin
    SiMain.LogVerbose('dbOpenFile: field "' + FieldName + '" non trovato ');
    Exit;
  end;

  s := Field.AsString;
  SiMain.LogString('Filename', s);

  if s <> '' then
    FileName := Folder + s
  else
    Clear;

  SiMain.LeaveMethod(Self, 'dbOpenFile');
end;

destructor TzFileViewer.Destroy;
begin
  FreeAndNil(FToolActions);
  FreeAndNil(HighlightedRegionsCollection);
  inherited;
end;

procedure TzFileViewer.ToolActionsChanged(sender: TObject);
begin
  InitToolActions;
end;

procedure TzFileViewer.gtPDFViewerViewerChange(sender: TObject);
begin
  // Continue := True;
  UpdateStatusBar;
end;

procedure TzFileViewer.Init;
begin
  if Initialized then
    Exit;

  Initialized := True;
  InitToolActions;

  // DIV-FVW-1: un nome assegnato prima di Init non era stato caricato
  if FileName <> '' then
    OpenFile;
end;

procedure TzFileViewer.InitToolActions;
begin
  if GetProps = nil then
    Exit;

  TzActionBuilder.BuildFromProps(GetProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(dxBarManagerBar, nil, otOther);
end;

function TzFileViewer.EnsureProps: TzFileViewerProps;
begin
  if not Assigned(FzFileViewerProps) then
    if Assigned(Base) and (ID <> '') then
      FzFileViewerProps := Base.zFiles.get(ID, True);
  result := FzFileViewerProps;
end;

function TzFileViewer.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
var
  Props: TzToolActionsProps;
begin
  // Scrive sui props persistiti (sorgente unica); il runtime ToolActions viene
  // rigenerato da InitToolActions/BuildFromProps. FromCode protegge l'azione da
  // codice dall'Assign della LZ. ImageList ignorata (non persistibile; fallback).
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

  result.FromCode := True;
end;

function TzFileViewer.GetActionOwnerName: string;
begin
  if EnsureProps <> nil then
    result := FzFileViewerProps.ActionOwnerName
  else
    result := '';
end;

procedure TzFileViewer.SetActionOwnerName(const Value: string);
begin
  if EnsureProps <> nil then
    FzFileViewerProps.ActionOwnerName := Value;
end;

function TzFileViewer.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, GetActionOwnerName);
end;

procedure TzFileViewer.RebuildActions;
begin
  InitToolActions;
  if Assigned(FzFileViewerProps) then
    FzFileViewerProps.SaveToBase(True);
end;

function TzFileViewer.ConfigTitle: string;
begin
  result := ID;
end;

function TzFileViewer.IsAdmin: boolean;
begin
  result := Assigned(Base) and Base.IsAdmin;
end;

procedure TzFileViewer.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzFileViewer.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataSet) then
    DataSet := nil;

  if Assigned(ToolActions) then
    ToolActions.RemoveNotification(AComponent);
end;

procedure TzFileViewer.OpenFile;
begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if Initialized then
    if FileName <> '' then
      if SameText(ExtractFileExt(FileName), '.pdf') then
        if FileExistsAndNotLocked(FileName) then
        begin
          if not Locked then
          begin
            SiMain.LogVerbose('OpenFile: loading ' + FileName);

            Loading := True;
            Timer.Enabled := False;
            OldActiveControl := Screen.ActiveControl;
            OldActiveControl := nil;

            Application.ProcessMessages;
            Screen.Cursor := crHourGlass;
            try
              SiMain.LogString('TzFileViewer.OpenFile', FileName);

              ShowLoading;
              try
                SiMain.LogVerbose('OpenFile: dxPDFViewer.LoadFromFile(FileName) ' + FileName);
                dxPDFViewer.LoadFromFile(FileName);
              except
                HideLoading;
                raise;
              end;
            finally
              Screen.Cursor := crDefault;
            end;

            Application.ProcessMessages;

            if Assigned(OldActiveControl) then
              try
                OldActiveControl.SetFocus;
              except
              end;
          end;
        end
        else // not fileExists
          Clear;
  SiMain.LeaveMethod(Self, 'OpenFile');
end;

procedure TzFileViewer.SetDataSet(const Value: TDataSet);
begin
  if FDataSet <> Value then
  begin
    FDataSet := Value;
    // DIV-FVW-6: chiede l'avviso di distruzione anche se il proprietario e' un altro
    if Assigned(Value) then
      Value.FreeNotification(Self);
    DataSource.DataSet := Value;
  end;
end;

procedure TzFileViewer.TimerTimer(sender: TObject);
begin
  inherited;
  Timer.Enabled := False;
  dbOpenFile;
end;

procedure TzFileViewer.AcroPDFMessage(sender: TObject);
begin
  inherited;
  Application.ProcessMessages;
end;

procedure TzFileViewer.Clear;
begin
  SiMain.EnterMethod(Self, 'Clear');
  CloseFile;
  SiMain.LeaveMethod(Self, 'Clear');
end;

procedure TzFileViewer.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');

  FFileName := '';

  if dxPDFViewer.IsDocumentLoaded then
    dxPDFViewer.Clear;

  UpdateStatusBar;

  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzFileViewer.CMShowingChanged(var Message: TMessage);
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

procedure TzFileViewer.Print;
begin
  dxPDFViewerShowPrintForm.Execute;
end;

procedure TzFileViewer.Reload;
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TzFileViewer.SalvaExecute(sender: TObject);
begin
  // if SaveDialog.Execute then
  // 06.03.2013:richiesta di Canetti, il file prodotto � diverso dall'originale e viene contestato da poste online
  // gtPDFDocument.SaveToFile(SaveDialog.FileName);
  // Win95Copy(Application.Handle, FileName, SaveDialog.FileName);
end;

procedure TzFileViewer.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');
  FFileName := Value;

  if not FileExistsAndNotLocked(FileName) or (not SameText(ExtractFileExt(FileName), '.pdf')) then
  begin
    SiMain.LogVerbose('SetFileName: file bloccato/estensione errata: ' + FileName);
    Clear
  end
  else
    OpenFile;

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzFileViewer.SetFolder(const Value: string);
begin
  FFolder := Trim(Value);

  if FFolder <> '' then
    FFolder := calcPath(FFolder);
end;

procedure TzFileViewer.SetToolActions(const Value: TzToolActions); // IzBaseComponent.SetToolActions
begin
  FToolActions.Assign(Value);
end;

procedure TzFileViewer.SetLocked(const Value: boolean);
begin
  if FLocked <> Value then
  begin
    FLocked := Value;
    if not Locked then
      Reload;
  end;
end;

procedure TzFileViewer.UpdateStatusBar;
begin
  if not Assigned(dxPDFViewer) then
    Exit;

  if Assigned(dxPDFViewer.Document) then
    StatusBar.Panels[0].Visible := dxPDFViewer.Document.SignatureOptions.IsDocumentSigned
  else
    StatusBar.Panels[0].Visible := False;

  if Locked then
  begin
    StatusBar.Panels[1].Visible := True;
    StatusBar.Panels[1].Text := '!';
  end
  else
  begin
    StatusBar.Panels[1].Visible := False;
    StatusBar.Panels[1].Text := '';
  end;

  if not dxPDFViewer.IsDocumentLoaded then
    StatusBar.Panels[2].Text := ''
  else
    StatusBar.Panels[2].Text := Format('Pagina %d di %d', [dxPDFViewer.CurrentPageIndex, dxPDFViewer.PageCount]);
end;

procedure TzFileViewer.ApriConAdobeExecute(sender: TObject);
begin
  if FileExists(FileName) then
    ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
end;

// Mantis #128 - 2026-09-17: rimosso il gestore OnBeforePreview che riportava
// PrinterPage.ScaleMode a smAdjust (100% della dimensione nominale del PDF) a ogni
// apertura della finestra di stampa: l'allegato usciva in miniatura. Vale il
// ScaleMode = smFit del .dfm, con i margini ridotti a 1 cm.

function TzFileViewer.FileExistsAndNotLocked(const FileName: string): boolean;
begin
  SiMain.LogString('FileExistsAndNotLocked', FileName);
  result := False;

  ShowLoading;
  try

    if not Locked then
      result := FileExists(FileName)
    else
      SiMain.LogVerbose('FileExistsAndNotLocked: Locked = true');
  finally
    HideLoading;
  end;
end;

procedure TzFileViewer.dxPDFViewerDocumentLoaded(ASender: TdxPDFDocument; const AInfo: TdxPDFDocumentLoadInfo);
begin
  HideLoading;
  UpdateStatusBar;
  //
end;

procedure TzFileViewer.dxPDFViewerSelectedPageChanged(sender: TObject; APageIndex: Integer);
begin
  UpdateStatusBar;
end;

procedure TzFileViewer.FileSaveAsAccept(sender: TObject);
var
  Folder: string;
begin
  // DIV-FVW-7: niente copia senza file di origine; la destinazione esistente si sovrascrive
  if (FileName = '') or not TFile.Exists(FileName) then
    Exit;
  TFile.Copy(FileName, FileSaveAs.Dialog.FileName, True);
  Folder := ExtractFilePath(FileSaveAs.Dialog.FileName);
  ShellExecute(0, PCHAR('open'), PCHAR(Folder), nil, nil, SW_RESTORE);
end;

procedure TzFileViewer.GeneraDaTemplateExecute(sender: TObject);
begin
  if Assigned(FOnGenerateFromTemplate) then
    OnGenerateFromTemplate(Self);
end;

procedure TzFileViewer.GeneraDaTemplateUpdate(sender: TObject);
begin
  GeneraDaTemplate.Visible := Assigned(FOnGenerateFromTemplate);
end;

procedure TzFileViewer.GenerateFromTemplate(DataSet: TDataSet; const TemplateFileName: string; DestFileName: string; const FillFieldProc: TFillFieldProc = nil; const BeforeSavePdfProc: TBeforeSavePdfProc = nil);
var
  pdf: TdxPDFDocument;
  i: Integer;
  s: String;
  FieldName: string;
  AskValue: boolean;
begin
  SiMain.EnterMethod(Self, 'GenerateFromTemplate');

  pdf := TdxPDFDocument.Create;
  try
    pdf.LoadFromFile(TemplateFileName);

    pdf.form.ForEach(
      procedure(AField: TdxPDFCustomField)
      var
        Field: TField;
        dxPDFCheckBoxField: TdxPDFCheckBoxField;
        Continue: boolean;
      begin
        SiMain.LogVerbose(AField.FullName);

        if Assigned(FillFieldProc) then
        begin
          Continue := False;

          FillFieldProc(pdf, AField, Continue);
          if not Continue then
            Exit;
        end;

        // if AField.ReadOnly then
        // Exit;
        AField.ReadOnly := False;

        FieldName := AField.FullName.Replace('@', '');
        AskValue := AField.FullName.StartsWith('@');

        if AskValue then
        begin
          case AField.FieldType of
            ftUnknown:
              ;
            ftNode:
              ;
            ftPushButton:
              ;
            ftCheckBox:
              begin
                dxPDFCheckBoxField := TdxPDFCheckBoxField(AField);

                case ConfirmYesNoCancel('Valore per il campo ' + FieldName + '?') of
                  mrYes:
                    dxPDFCheckBoxField.Checked := True;
                  mrNo:
                    dxPDFCheckBoxField.Checked := False;
                  mrCancel:
                    Exit;
                end;

                AField.ReadOnly := True;
              end;
            ftRadioGroup:
              begin
                // recuperare i valori per una combo dall'oggetto
                // case Message Dlg('Valore per il campo ' + FieldName + '?', mtConfirmation, mbYesNoCancel, 0) of
                // AField.ReadOnly := True;
              end;
            ftListBox:
              begin
                // TdxPDFListBoxField;
              end;
            ftComboBox:
              begin
                // TdxPDFComboBoxField
              end;
            ftText:
              begin
                s := TdxPDFTextField(AField).Text;
                if InputQuery(FieldName, 'Valore: ', s) then
                  TdxPDFTextField(AField).Text := s
                else
                  Exit;

                AField.ReadOnly := True;
              end;
            ftSignature:
              ;
          end;
        end
        else
        begin
          Field := DataSet.FindField(FieldName);

          if Assigned(Field) then
          begin
            case AField.FieldType of
              ftUnknown:
                ;
              ftNode:
                ;
              ftPushButton:
                ;
              ftCheckBox:
                begin
                  dxPDFCheckBoxField := TdxPDFCheckBoxField(AField);

                  if Field is TBooleanField then
                    dxPDFCheckBoxField.Checked := Field.Value
                  else
                    if Field is TStringField then
                      dxPDFCheckBoxField.Checked := Field.AsString = 'S'
                    else
                      raise Exception.Create('Conversione non valida per il campo ' + FieldName);

                  AField.ReadOnly := True;
                end;
              ftRadioGroup:
                begin
                  if Field is TNumericField then
                    TdxPDFRadioGroupField(AField).ItemIndex := Field.AsInteger
                  else
                    raise Exception.Create('Conversione non valida per il campo ' + FieldName);

                  AField.ReadOnly := True;
                end;
              ftListBox:
                begin
                  // TdxPDFListBoxField;
                end;
              ftComboBox:
                begin
                  // TdxPDFComboBoxField
                end;
              ftText:
                begin
                  TdxPDFTextField(AField).Text := Field.AsString;
                  AField.ReadOnly := True;
                end;
              ftSignature:
                ;
            end;
          end
          else
            if AField.FieldType = ftText then
            begin
              TdxPDFTextField(AField).Text := 'Campo ' + FieldName + ' non trovato.';
              AField.ReadOnly := True;
            end;
        end;
      end);

    if Assigned(BeforeSavePdfProc) then
      BeforeSavePdfProc(pdf);

    pdf.SaveToFile(DestFileName);
  finally
    FreeAndNil(pdf);
  end;

  SiMain.LeaveMethod(Self, 'GenerateFromTemplate');
end;

procedure TzFileViewer.ImportaAccept(sender: TObject);
begin
  if Assigned(FOnImportFile) then
    OnImportFile(Self, Importa.Dialog.FileName);
end;

procedure TzFileViewer.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := Assigned(FOnImportFile);
end;

procedure TzFileViewer.ShowLoading;
begin
  dxActivityIndicator.Active := True;
  dxActivityIndicator.BringToFront;
end;

procedure TzFileViewer.HideLoading;
begin
  dxActivityIndicator.Active := False;
  dxActivityIndicator.SendToBack;
end;

procedure TzFileViewer.EditToolsExecute(sender: TObject);
begin
  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzFileViewer.EditToolsUpdate(sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

function TzFileViewer.GetProps: TzBaseComponentProps;
begin
  if EnsureProps <> nil then
    result := FzFileViewerProps
  else
    result := nil;
end;

procedure TzFileViewer.RebuildToolbar;
begin
  InitToolActions;
end;

end.

  zmap zdbcard zdbview zdbpivot ztoolfilter
