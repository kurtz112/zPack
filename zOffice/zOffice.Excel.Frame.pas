unit zOffice.Excel.Frame;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.StdActns,
  Data.DB,
  cxDrawTextUtils,
  cxClasses,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
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
  dxPSPrVwStd,
  dxPSPrVwAdv,
  dxPSPrVwRibbon,
  dxPScxPageControlProducer,
  dxPSRichEditControlLnk,
  dxPSdxSpreadSheetLnk,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxStatusBar,
  dxCore,
  dxCoreClasses,
  dxHashUtils,
  dxSpreadSheetCore,
  dxSpreadSheetCoreFormulas,
  dxSpreadSheetCoreHistory,
  dxSpreadSheetCoreStyles,
  dxSpreadSheetCoreStrs,
  dxSpreadSheetConditionalFormatting,
  dxSpreadSheetConditionalFormattingRules,
  dxSpreadSheetClasses,
  dxSpreadSheetContainers,
  dxSpreadSheetFormulas,
  dxSpreadSheetHyperlinks,
  dxSpreadSheetFunctions,
  dxSpreadSheetStyles,
  dxSpreadSheetGraphics,
  dxSpreadSheetPrinting,
  dxSpreadSheetTypes,
  dxSpreadSheetUtils,
  dxSpreadSheetFormattedTextUtils,
  dxBarBuiltInMenu,
  dxSpreadSheet,
  dxActivityIndicator,
  dxPSBaseGridLnk,
  dxPSdxSpreadSheetLnkCore,
  dxSpreadSheetActions,
  dxPrinting,
  dxBar,
  dxActions,
  dxPSdxPDFViewerLnk,
  dxFileActions,
  dxPScxEditorLnks,
  dxUIAClasses,
  zOffice.types,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzViewerExcelFrame = class;
  TImportFileExcelEvent = procedure(sender: TzViewerExcelFrame; const FileName: string) of object;

  TzViewerExcelFrame = class(TFrame, izViewerFrame)
    StatusBar: TdxStatusBar;
    dxSpreadSheet: TdxSpreadSheet;
    dxBarManager: TdxBarManager;
    ActionList: TActionList;
    dxSpreadSheetNewDocument: TdxSpreadSheetNewDocument;
    dxBarManagerBar: TdxBar;
    dxSpreadSheetOpenDocument: TdxSpreadSheetOpenDocument;
    dxSpreadSheetSaveDocumentAs: TdxSpreadSheetSaveDocumentAs;
    dxBarButtonSaveAs: TdxBarButton;
    dxSpreadSheetShowPrintForm: TdxSpreadSheetShowPrintForm;
    dxBarButtonPrint: TdxBarButton;
    dxSpreadSheetShowPrintPreviewForm: TdxSpreadSheetShowPrintPreviewForm;
    dxBarButtonPrintPreview: TdxBarButton;
    dxSpreadSheetShowPageSetupForm: TdxSpreadSheetShowPageSetupForm;
    dxBarButtonPageSetup: TdxBarButton;
    dxSpreadSheetPasteSelection: TdxSpreadSheetPasteSelection;
    dxBarButtonPaste: TdxBarButton;
    dxSpreadSheetCutSelection: TdxSpreadSheetCutSelection;
    dxBarButtonCut: TdxBarButton;
    dxSpreadSheetCopySelection: TdxSpreadSheetCopySelection;
    dxBarButtonCopy: TdxBarButton;
    dxSpreadSheetZoomOut: TdxSpreadSheetZoomOut;
    dxBarButtonZoomOut: TdxBarButton;
    dxSpreadSheetZoomIn: TdxSpreadSheetZoomIn;
    dxBarButtonZoomIn: TdxBarButton;
    dxSpreadSheetZoomDefault: TdxSpreadSheetZoomDefault;
    dxBarButton100: TdxBarButton;
    Importa: TdxFileOpen;
    Apri: TAction;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    procedure ApriExecute(sender: TObject);
    procedure ImportaAccept(sender: TObject);
    procedure ImportaUpdate(sender: TObject);
  private
    // Stampa DevExpress a creazione differita.
    // Il TdxComponentPrinter e il suo collegamento di stampa non stanno piu' nel
    // .dfm: crearli mentre il frame si apre fa leggere subito la stampante
    // predefinita di Windows (TdxPrinterPage chiama GetDefaultPrinter, OpenPrinter
    // e GetPrinter di livello 9), e se la predefinita e' di rete, condivisa o
    // reindirizzata Windows apre la propria finestra di configurazione mentre
    // l'utente sta soltanto aprendo la form. Ora quella lettura avviene solo
    // quando si stampa o si esporta davvero.
    FComponentPrinter: TdxComponentPrinter;
    FComponentPrinterLink: TdxSpreadSheetReportLnk;
  public
    // Creato al primo uso: vedi la nota sui campi privati qui sopra.
    function ComponentPrinter: TdxComponentPrinter;
  private
    // Mantis #156 - 2026-09-22: stampa e anteprima passano da azioni proprie.
    // Le azioni di stampa DevExpress (discendenti di TdxCustomPrintingAction)
    // si disabilitano da sole finche' non esiste un collegamento di stampa
    // registrato per il controllo: TdxCustomPrintingAction.IsEnabled chiama
    // dxPrintingRepository.CanBuildReport, che risponde False finche' nessun
    // TBasedxReportLink si e' registrato. Da quando il TdxComponentPrinter e
    // il suo collegamento sono a creazione differita, quella registrazione non
    // avveniva piu' e i pulsanti restavano grigi (allegati non stampabili).
    // Con azioni proprie i pulsanti restano attivi, il collegamento nasce al
    // clic (la stampante predefinita viene letta solo quando si stampa davvero)
    // e la stampa conserva i margini impostati per il ticket #128.
    FStampa: TAction;
    FAnteprimaDiStampa: TAction;
    procedure CreaAzioniDiStampa;
    procedure StampaExecute(sender: TObject);
    procedure AnteprimaDiStampaExecute(sender: TObject);
    procedure AzioniDiStampaUpdate(sender: TObject);
  private
    Initialized: boolean;
    Loading: boolean;
    FFieldName_FileName: string;
    FFieldName_ID: string;
    FFileName: string;
    FOnImportFile: TImportFileExcelEvent;
    procedure SetFileName(const Value: string);
    // Con uno skin attivo il testo delle celle senza riempimento proprio segue
    // il colore di testo dello skin: vedi l'implementazione.
    procedure SpreadSheetCustomDrawTableViewCell(Sender: TdxSpreadSheetTableView; ACanvas: TcxCanvas;
      AViewInfo: TdxSpreadSheetTableViewCellViewInfo; var AHandled: Boolean);
  private
    procedure UpdateStatusBar;
  public // izViewerFrame
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
  public
    constructor Create(aOwner: TComponent); override;
    function GeneraPdf(const DestPath: string): boolean;
  published
    property FileName: string read FFileName write SetFileName stored False;
    property OnImportFile: TImportFileExcelEvent read FOnImportFile write FOnImportFile;
  end;

implementation

uses
  Winapi.ShellAPI, zDX, zBaseLib, zOffice.utils, zOffice, System.IOUtils;

{$R *.dfm}

function TzViewerExcelFrame.ComponentPrinter: TdxComponentPrinter;
begin
  if not Assigned(FComponentPrinter) then
  begin
    FComponentPrinter := TdxComponentPrinter.Create(Self);
    FComponentPrinter.Name := 'dxComponentPrinter';
    dx.InitPrinter(FComponentPrinter);

    FComponentPrinterLink := FComponentPrinter.AddLink(dxSpreadSheet) as TdxSpreadSheetReportLnk;
    FComponentPrinterLink.Name := 'dxComponentPrinterLink';
    // unico valore che il .dfm assegnava oltre ai predefiniti DevExpress
    FComponentPrinterLink.PrinterPage.GrayShading := True;
  end;

  result := FComponentPrinter;
end;

constructor TzViewerExcelFrame.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);

  dx.initBar(dxBarManagerBar);

  Importa.Dialog.DefaultExt := '*.xlsx';
  Importa.Dialog.Filter := FilterForFileTypes([ftExcel]);

  CreaAzioniDiStampa;

  dxSpreadSheet.OnCustomDrawTableViewCell := SpreadSheetCustomDrawTableViewCell;
end;

procedure TzViewerExcelFrame.SpreadSheetCustomDrawTableViewCell(Sender: TdxSpreadSheetTableView;
  ACanvas: TcxCanvas; AViewInfo: TdxSpreadSheetTableViewCellViewInfo; var AHandled: Boolean);
var
  Painter: TcxCustomLookAndFeelPainter;
begin
  // Il file xlsx assegna al testo un colore esplicito (di solito il nero del tema):
  // lo skin scurisce lo sfondo ma non quel colore, che resterebbe nero su scuro.
  // Si corregge solo il disegno, il documento non cambia (SaveAs resta fedele).
  // Le celle con riempimento proprio o con un colore di testo scelto nel file restano com'e'.
  AHandled := False;

  Painter := dx.GetSkinPainter;
  if (Painter = nil) or (AViewInfo.Cell = nil) then
    Exit;

  if not AViewInfo.Cell.Style.Brush.IsDefault then
    Exit;

  case AViewInfo.Cell.Style.Font.Color of
    clDefault, clNone, clBlack, clWindowText:
      AViewInfo.TextColor := Painter.DefaultContentTextColor;
  end;
end;

function TzViewerExcelFrame.GeneraPdf(const DestPath: string): boolean;
var
  Options: TdxPSPDFReportExportOptions;
begin
  result := False;
  if DestPath = '' then Exit;
  try ForceDirectories(ExtractFilePath(DestPath)); except end;
  Options := TdxPSPDFReportExportOptions.Create;
  try
    Options.CompressStreams := True;
    Options.DefaultFileName := DestPath;
    Options.OpenDocumentAfterExport := False;
    Options.EmbedFonts := True;
    Options.UseJPEGCompression := True;
    ComponentPrinter.ExportToPDF(DestPath, False, Options);
    result := TFile.Exists(DestPath);
  finally
    FreeAndNil(Options);
  end;
end;

procedure TzViewerExcelFrame.ApriExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ViewFile(FileName);
end;

procedure TzViewerExcelFrame.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');
  FFileName := '';
  dxSpreadSheet.BeginUpdate;
  try
    dxSpreadSheet.ClearAll;
    dxSpreadSheet.AddSheet(''); // sheet vuoto: la view/selection torna valida
  finally
    dxSpreadSheet.EndUpdate;
  end;
  UpdateStatusBar;
  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzViewerExcelFrame.ImportaAccept(sender: TObject);
begin

  if Assigned(FOnImportFile) then
    OnImportFile(Self, Importa.Dialog.FileName);
end;

procedure TzViewerExcelFrame.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := Assigned(FOnImportFile);
end;

procedure TzViewerExcelFrame.OpenFile;
begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if FileName.IsEmpty then
    CloseFile
  else
  begin
    SiMain.LogString('TzViewerImageFrame.OpenFile', FileName);
    dxSpreadSheet.LoadFromFile(FileName);
    FFileName := FileName;
  end;
end;

procedure TzViewerExcelFrame.CreaAzioniDiStampa;
begin
  // Mantis #156 - 2026-09-22: i pulsanti Stampa e Anteprima vengono
  // riagganciati ad azioni proprie; vedi la nota sui campi privati.
  FStampa := TAction.Create(Self);
  FStampa.Name := 'StampaDocumento';
  FStampa.ActionList := Self.ActionList;
  FStampa.Caption := dxSpreadSheetShowPrintForm.Caption;
  FStampa.Hint := dxSpreadSheetShowPrintForm.Hint;
  FStampa.ImageIndex := dxSpreadSheetShowPrintForm.ImageIndex;
  FStampa.OnExecute := StampaExecute;
  FStampa.OnUpdate := AzioniDiStampaUpdate;

  FAnteprimaDiStampa := TAction.Create(Self);
  FAnteprimaDiStampa.Name := 'AnteprimaDiStampaDocumento';
  FAnteprimaDiStampa.ActionList := Self.ActionList;
  FAnteprimaDiStampa.Caption := dxSpreadSheetShowPrintPreviewForm.Caption;
  FAnteprimaDiStampa.Hint := dxSpreadSheetShowPrintPreviewForm.Hint;
  FAnteprimaDiStampa.ImageIndex := dxSpreadSheetShowPrintPreviewForm.ImageIndex;
  FAnteprimaDiStampa.OnExecute := AnteprimaDiStampaExecute;
  FAnteprimaDiStampa.OnUpdate := AzioniDiStampaUpdate;

  dxBarButtonPrint.Action := FStampa;
  dxBarButtonPrintPreview.Action := FAnteprimaDiStampa;
end;

procedure TzViewerExcelFrame.AzioniDiStampaUpdate(sender: TObject);
begin
  FStampa.Enabled := FFileName <> '';
  FAnteprimaDiStampa.Enabled := FStampa.Enabled;
end;

procedure TzViewerExcelFrame.StampaExecute(sender: TObject);
begin
  if FFileName = '' then
    Exit;

  // la prima chiamata crea il TdxComponentPrinter e il collegamento di stampa
  ComponentPrinter;
  FComponentPrinterLink.Print(True);
end;

procedure TzViewerExcelFrame.AnteprimaDiStampaExecute(sender: TObject);
begin
  if FFileName = '' then
    Exit;

  ComponentPrinter;
  FComponentPrinterLink.Preview(True);
end;

procedure TzViewerExcelFrame.Print;
begin
  StampaExecute(nil);
end;

procedure TzViewerExcelFrame.SetAllowedImportFileTypes(FileTypes: TzFileTypes);
begin
  // se impostato da zOffice.MultiViewer
  Importa.Dialog.Filter := FilterForFileTypes(FileTypes);
end;

procedure TzViewerExcelFrame.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');

  if not FileExists(Value) then
    CloseFile
  else
    OpenFile(Value);

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzViewerExcelFrame.UpdateStatusBar;
begin
  if not Assigned(dxSpreadSheet) then
    Exit;

end;

end.

BaseFrm
