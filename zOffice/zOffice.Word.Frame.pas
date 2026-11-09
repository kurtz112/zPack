unit zOffice.Word.Frame;

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
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  dxCore,
  dxCoreClasses,
  cxGraphics,
  dxGDIPlusAPI,
  dxGDIPlusClasses,
  dxRichEdit.NativeApi,
  dxRichEdit.Types,
  dxRichEdit.Options,
  dxRichEdit.Control,
  dxRichEdit.Control.SpellChecker,
  dxRichEdit.Dialogs.EventArgs,
  dxBarBuiltInMenu,
  cxControls,
  dxRichEdit.Platform.Win.Control,
  dxRichEdit.Control.Core,
  dxRichEdit.Actions,
  dxActions,
  dxPrinting,
  dxBar,
  dxRibbonGallery,
  cxClasses,
  cxImageList,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxStatusBar,
  dxActivityIndicator,
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
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxRichEdit.Doc,
  dxRichEdit.OpenXML,
  dxRichEdit.Html,
  dxPSRichEditControlLnk,
  dxPSdxPDFViewerLnk,
  dxPSdxSpreadSheetLnk,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  Vcl.StdActns,
  dxFileActions,
  dxPScxEditorLnks,
  zOffice.Types,
  dxUIAClasses;

type
  TzViewerWordFrame = class;
  TImportFileWordEvent = procedure(sender: TzViewerWordFrame; const FileName: string) of object;

  TzViewerWordFrame = class(TFrame, izViewerFrame)
    dxRichEditControl: TdxRichEditControl;
    dxBarManager: TdxBarManager;
    ActionList: TActionList;
    dxRichEditControlNewDocument: TdxRichEditControlNewDocument;
    dxBarManagerBar: TdxBar;
    dxRichEditControlLoadDocument: TdxRichEditControlLoadDocument;
    dxRichEditControlSaveDocument: TdxRichEditControlSaveDocument;
    dxRichEditControlSaveDocumentAs: TdxRichEditControlSaveDocumentAs;
    dxBarButtonSaveAs: TdxBarButton;
    dxRichEditControlPasteSelection: TdxRichEditControlPasteSelection;
    dxBarButtonPaste: TdxBarButton;
    dxRichEditControlCutSelection: TdxRichEditControlCutSelection;
    dxBarButtonCut: TdxBarButton;
    dxRichEditControlCopySelection: TdxRichEditControlCopySelection;
    dxBarButtonCopy: TdxBarButton;
    dxRichEditControlSelectAll: TdxRichEditControlSelectAll;
    dxBarButtonSelectAll: TdxBarButton;
    dxRichEditControlPageMarginsGallery: TdxRichEditControlPageMarginsGallery;
    dxRibbonGalleryItem1: TdxRibbonGalleryItem;
    dxRichEditControlShowPageMarginsSetupForm: TdxRichEditControlShowPageMarginsSetupForm;
    dxBarButtonCustomMargins: TdxBarButton;
    dxRichEditControlSetPortraitPageOrientation: TdxRichEditControlSetPortraitPageOrientation;
    dxBarButtonPortrait: TdxBarButton;
    dxRichEditControlSetLandscapePageOrientation: TdxRichEditControlSetLandscapePageOrientation;
    dxBarButtonLandscape: TdxBarButton;
    dxRichEditControlPaperSizeGallery: TdxRichEditControlPaperSizeGallery;
    dxRibbonGalleryItem2: TdxRibbonGalleryItem;
    dxRichEditControlShowPagePaperSetupForm: TdxRichEditControlShowPagePaperSetupForm;
    dxBarButtonMorePaperSizes: TdxBarButton;
    dxRichEditControlSetSectionOneColumn: TdxRichEditControlSetSectionOneColumn;
    dxBarButtonOne: TdxBarButton;
    dxRichEditControlSetSectionTwoColumns: TdxRichEditControlSetSectionTwoColumns;
    dxBarButtonTwo: TdxBarButton;
    dxRichEditControlSetSectionThreeColumns: TdxRichEditControlSetSectionThreeColumns;
    dxBarButtonThree: TdxBarButton;
    dxRichEditControlShowColumnsSetupForm: TdxRichEditControlShowColumnsSetupForm;
    dxBarButtonMoreColumns: TdxBarButton;
    dxRichEditControlInsertPageBreak: TdxRichEditControlInsertPageBreak;
    dxBarButtonPage: TdxBarButton;
    dxRichEditControlInsertColumnBreak: TdxRichEditControlInsertColumnBreak;
    dxBarButtonColumn: TdxBarButton;
    dxRichEditControlInsertSectionBreakNextPage: TdxRichEditControlInsertSectionBreakNextPage;
    dxBarButtonSectionNextPage: TdxBarButton;
    dxRichEditControlInsertSectionBreakEvenPage: TdxRichEditControlInsertSectionBreakEvenPage;
    dxBarButtonSectionEvenPage: TdxBarButton;
    dxRichEditControlInsertSectionBreakOddPage: TdxRichEditControlInsertSectionBreakOddPage;
    dxBarButtonSectionOddPage: TdxBarButton;
    dxRichEditControlSetSectionLineNumberingNone: TdxRichEditControlSetSectionLineNumberingNone;
    dxBarButtonNone: TdxBarButton;
    dxRichEditControlSetSectionLineNumberingContinuous: TdxRichEditControlSetSectionLineNumberingContinuous;
    dxBarButtonContinuous: TdxBarButton;
    dxRichEditControlSetSectionLineNumberingRestartNewPage: TdxRichEditControlSetSectionLineNumberingRestartNewPage;
    dxBarButtonRestartEachPage: TdxBarButton;
    dxRichEditControlSetSectionLineNumberingRestartNewSection: TdxRichEditControlSetSectionLineNumberingRestartNewSection;
    dxBarButtonRestartEachSection: TdxBarButton;
    dxRichEditControlShowLineNumberingForm: TdxRichEditControlShowLineNumberingForm;
    dxBarButtonLineNumberingOptions: TdxBarButton;
    dxRichEditControlSwitchToSimpleView: TdxRichEditControlSwitchToSimpleView;
    dxBarButtonSimpleView: TdxBarButton;
    dxRichEditControlSwitchToDraftView: TdxRichEditControlSwitchToDraftView;
    dxBarButtonDraftView: TdxBarButton;
    dxRichEditControlSwitchToPrintLayoutView: TdxRichEditControlSwitchToPrintLayoutView;
    dxBarButtonPrintLayout: TdxBarButton;
    dxRichEditControlToggleShowHorizontalRuler: TdxRichEditControlToggleShowHorizontalRuler;
    dxRichEditControlToggleShowVerticalRuler: TdxRichEditControlToggleShowVerticalRuler;
    dxRichEditControlZoomOut: TdxRichEditControlZoomOut;
    dxBarButtonZoomOut: TdxBarButton;
    dxRichEditControlZoomIn: TdxRichEditControlZoomIn;
    dxBarButtonZoomIn: TdxBarButton;
    dxRichEditControlShowPrintForm: TdxRichEditControlShowPrintForm;
    dxBarButtonPrint: TdxBarButton;
    dxRichEditControlShowPrintPreviewForm: TdxRichEditControlShowPrintPreviewForm;
    dxBarButtonPrintPreview: TdxBarButton;
    dxRichEditControlShowPageSetupForm: TdxRichEditControlShowPageSetupForm;
    dxBarButtonPageSetup: TdxBarButton;
    StatusBar: TdxStatusBar;
    Importa: TdxFileOpen;
    dxBarButtonImporta: TdxBarButton;
    Apri: TAction;
    dxBarButton1: TdxBarButton;
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
    FComponentPrinterLink: TdxRichEditControlReportLink;
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
    FFileName: string;
    FOnImportFile: TImportFileWordEvent;
    procedure SetFileName(const Value: string);
  private
    procedure UpdateStatusBar;
  protected
  public // izViewerFrame
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
  public
    constructor Create(aOwner: TComponent); override;

    function GeneraPdf(const DestPath: string): boolean;
  public
    function AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
  published
    property FileName: string read FFileName write SetFileName stored False;
    property OnImportFile: TImportFileWordEvent read FOnImportFile write FOnImportFile;
  end;

implementation

uses
  Winapi.ShellAPI, dxRichEdit.View.PrintLayout, zDX, zBaseLib, zOffice.utils,
  zOffice, System.IOUtils;

{$R *.dfm}

function TzViewerWordFrame.ComponentPrinter: TdxComponentPrinter;
begin
  if not Assigned(FComponentPrinter) then
  begin
    FComponentPrinter := TdxComponentPrinter.Create(Self);
    FComponentPrinter.Name := 'dxComponentPrinter';
    dx.InitPrinter(FComponentPrinter);

    FComponentPrinterLink := FComponentPrinter.AddLink(dxRichEditControl) as TdxRichEditControlReportLink;
    FComponentPrinterLink.Name := 'dxComponentPrinterLink';
    // unico valore che il .dfm assegnava oltre ai predefiniti DevExpress
    FComponentPrinterLink.PrinterPage.GrayShading := True;
  end;

  result := FComponentPrinter;
end;

constructor TzViewerWordFrame.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);

  dx.initBar(dxBarManagerBar);

  Importa.dialog.DefaultExt := '*.docx';
  Importa.dialog.Filter := FilterForFileTypes([ftWord]);

  CreaAzioniDiStampa;
end;

function TzViewerWordFrame.GeneraPdf(const DestPath: string): boolean;
var
  Options: TdxPSPDFReportExportOptions;
begin
  result := False;
  if DestPath = '' then
    Exit;
  try
    ForceDirectories(ExtractFilePath(DestPath));
  except
  end;
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

function TzViewerWordFrame.AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
begin
  assert(Assigned(Action));

  result := TdxBarButton.Create(Self);
  result.Name := CreateUniqueName(Self, Self, result, 'btn' + Action.Name, '');
  result.Action := Action;
  result.PaintStyle := psCaptionGlyph;

  if Action.AutoCheck then
  begin
    result.ButtonStyle := bsChecked;
    result.Down := Action.Checked;
  end;

  dxBarManagerBar.ItemLinks.Add(result); // .VisibleIndex := Position;
end;

procedure TzViewerWordFrame.ApriExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ViewFile(FileName);
end;

procedure TzViewerWordFrame.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');

  FFileName := '';

  if not dxRichEditControl.Document.IsEmpty then
  begin
    dxRichEditControl.Document.CreateNewDocument;
    dxRichEditControl.DocumentModelModified := False;
  end;

  UpdateStatusBar;

  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzViewerWordFrame.ImportaAccept(sender: TObject);
begin
  if Assigned(FOnImportFile) then
    OnImportFile(Self, Importa.dialog.FileName);
end;

procedure TzViewerWordFrame.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := Assigned(FOnImportFile);
end;

procedure TzViewerWordFrame.OpenFile(const FileName: string);
begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if FileName.IsEmpty then
    CloseFile
  else
  begin
    SiMain.LogString('TzViewerImageFrame.OpenFile', FileName);
    dxRichEditControl.Document.LoadDocument(FileName, TdxRichEditDocumentFormat.Undefined);
    FFileName := FileName;
  end;
end;

procedure TzViewerWordFrame.CreaAzioniDiStampa;
begin
  // Mantis #156 - 2026-09-22: i pulsanti Stampa e Anteprima vengono
  // riagganciati ad azioni proprie; vedi la nota sui campi privati.
  FStampa := TAction.Create(Self);
  FStampa.Name := 'StampaDocumento';
  FStampa.ActionList := Self.ActionList;
  FStampa.Caption := dxRichEditControlShowPrintForm.Caption;
  FStampa.Hint := dxRichEditControlShowPrintForm.Hint;
  FStampa.ImageIndex := dxRichEditControlShowPrintForm.ImageIndex;
  FStampa.OnExecute := StampaExecute;
  FStampa.OnUpdate := AzioniDiStampaUpdate;

  FAnteprimaDiStampa := TAction.Create(Self);
  FAnteprimaDiStampa.Name := 'AnteprimaDiStampaDocumento';
  FAnteprimaDiStampa.ActionList := Self.ActionList;
  FAnteprimaDiStampa.Caption := dxRichEditControlShowPrintPreviewForm.Caption;
  FAnteprimaDiStampa.Hint := dxRichEditControlShowPrintPreviewForm.Hint;
  FAnteprimaDiStampa.ImageIndex := dxRichEditControlShowPrintPreviewForm.ImageIndex;
  FAnteprimaDiStampa.OnExecute := AnteprimaDiStampaExecute;
  FAnteprimaDiStampa.OnUpdate := AzioniDiStampaUpdate;

  dxBarButtonPrint.Action := FStampa;
  dxBarButtonPrintPreview.Action := FAnteprimaDiStampa;
end;

procedure TzViewerWordFrame.AzioniDiStampaUpdate(sender: TObject);
begin
  FStampa.Enabled := FFileName <> '';
  FAnteprimaDiStampa.Enabled := FStampa.Enabled;
end;

procedure TzViewerWordFrame.StampaExecute(sender: TObject);
begin
  if FFileName = '' then
    Exit;

  // la prima chiamata crea il TdxComponentPrinter e il collegamento di stampa
  ComponentPrinter;
  FComponentPrinterLink.Print(True);
end;

procedure TzViewerWordFrame.AnteprimaDiStampaExecute(sender: TObject);
begin
  if FFileName = '' then
    Exit;

  ComponentPrinter;
  FComponentPrinterLink.Preview(True);
end;

procedure TzViewerWordFrame.Print;
begin
  StampaExecute(nil);
end;

procedure TzViewerWordFrame.SetAllowedImportFileTypes(FileTypes: TzFileTypes);
begin
  // se impostato da zOffice.MultiViewer
  Importa.dialog.Filter := FilterForFileTypes(FileTypes);
end;

procedure TzViewerWordFrame.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');

  if not FileExists(Value) then
    CloseFile
  else
    OpenFile(Value);

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzViewerWordFrame.UpdateStatusBar;
var
  PageCount, PageIndex: integer;
begin
  if not Assigned(dxRichEditControl) then
    Exit;

  if not dxRichEditControl.Document.IsEmpty then
    StatusBar.Panels[0].Text := ''
  else
  begin
    PageCount := TdxPrintLayoutView(dxRichEditControl.ActiveView).PageCount;
    PageIndex := TdxPrintLayoutView(dxRichEditControl.ActiveView).CurrentPageIndex;

    StatusBar.Panels[0].Text := Format('Pagina %d di %d', [PageIndex, PageCount]);
  end;
end;

end.
// apriConWord
