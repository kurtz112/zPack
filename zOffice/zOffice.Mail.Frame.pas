unit zOffice.Mail.Frame;

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
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.StdActns,
  Vcl.ComCtrls,
  Data.DB,
  cxGraphics,
  cxControls,
  cxClasses,
  cxImageList,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxDrawTextUtils,
  cxContainer,
  cxEdit,
  cxListView,
  cxTextEdit,
  dxCore,
  dxCoreClasses,
  dxGDIPlusAPI,
  dxGDIPlusClasses,
  dxRichEdit.NativeApi,
  dxRichEdit.Types,
  dxRichEdit.Options,
  dxRichEdit.Control,
  dxRichEdit.Control.SpellChecker,
  dxRichEdit.Dialogs.EventArgs,
  dxBarBuiltInMenu,
  dxRichEdit.Platform.Win.Control,
  dxRichEdit.Control.Core,
  dxRichEdit.Actions,
  dxActions,
  dxPrinting,
  dxBar,
  dxRibbonGallery,
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
  dxFileActions,
  dxPScxEditorLnks,
  dxBarExtItems,
  dxLayoutcxEditAdapters,
  dxLayoutContainer,
  dxLayoutControl,
  zOffice.Types,
  zOffice.Mail.Utils,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  dxUIAClasses;

type
  TzViewerMailFrame = class;
  TImportFileEmailEvent = procedure(sender: TzViewerMailFrame; const FileName: string) of object;

  TzViewerMailFrame = class(TFrame, izViewerFrame)
    StatusBar: TdxStatusBar;
    dxBarManager: TdxBarManager;
    dxBarLargeButton1: TdxBarLargeButton;
    bsZoom: TdxBarStatic;
    bccZoom: TdxBarControlContainerItem;
    dxBarButton1: TdxBarButton;
    dxBarLargeButtonSaveAs: TdxBarLargeButton;
    dxBarLargeButtonPaste: TdxBarLargeButton;
    dxBarButtonCut: TdxBarButton;
    dxBarButtonCopy: TdxBarButton;
    dxBarButtonSelectAll: TdxBarButton;
    dxBarLargeButtonPage: TdxBarLargeButton;
    dxBarLargeButtonZoomOut: TdxBarLargeButton;
    dxBarLargeButtonZoomIn: TdxBarLargeButton;
    dxBarLargeButtonPrint: TdxBarLargeButton;
    dxBarLargeButtonPrintPreview: TdxBarLargeButton;
    dxBarLargeButtonPageSetup: TdxBarLargeButton;
    ActionList: TActionList;
    Importa: TdxFileOpen;
    dxRichEditControlNewDocument: TdxRichEditControlNewDocument;
    dxRichEditControlLoadDocument: TdxRichEditControlLoadDocument;
    dxRichEditControlSaveDocument: TdxRichEditControlSaveDocument;
    dxRichEditControlSaveDocumentAs: TdxRichEditControlSaveDocumentAs;
    dxRichEditControlPasteSelection: TdxRichEditControlPasteSelection;
    dxRichEditControlCutSelection: TdxRichEditControlCutSelection;
    dxRichEditControlCopySelection: TdxRichEditControlCopySelection;
    dxRichEditControlSelectAll: TdxRichEditControlSelectAll;
    dxRichEditControlInsertPageBreak: TdxRichEditControlInsertPageBreak;
    dxRichEditControlSwitchToSimpleView: TdxRichEditControlSwitchToSimpleView;
    dxRichEditControlSwitchToDraftView: TdxRichEditControlSwitchToDraftView;
    dxRichEditControlSwitchToPrintLayoutView: TdxRichEditControlSwitchToPrintLayoutView;
    dxRichEditControlToggleShowHorizontalRuler: TdxRichEditControlToggleShowHorizontalRuler;
    dxRichEditControlToggleShowVerticalRuler: TdxRichEditControlToggleShowVerticalRuler;
    dxRichEditControlZoomOut: TdxRichEditControlZoomOut;
    dxRichEditControlZoomIn: TdxRichEditControlZoomIn;
    dxRichEditControlShowPrintForm: TdxRichEditControlShowPrintForm;
    dxRichEditControlShowPrintPreviewForm: TdxRichEditControlShowPrintPreviewForm;
    dxRichEditControlShowPageSetupForm: TdxRichEditControlShowPageSetupForm;
    imageAllegati: TcxImageList;
    dxBarManagerBar: TdxBar;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxBarButton11: TdxBarButton;
    dxLayoutControl: TdxLayoutControl;
    edFrom: TcxTextEdit;
    edOggetto: TcxTextEdit;
    dxRichEditControl: TdxRichEditControl;
    edData: TcxTextEdit;
    listAllegati: TcxListView;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutItemFrom: TdxLayoutItem;
    dxLayoutItemOggetto: TdxLayoutItem;
    dxLayoutGroupIntestazione: TdxLayoutGroup;
    dxLayoutGroupMain: TdxLayoutGroup;
    dxLayoutSplitterItemInspector: TdxLayoutSplitterItem;
    dxLayoutItemBody: TdxLayoutItem;
    dxLayoutSplitterItem2: TdxLayoutSplitterItem;
    dxLayoutItemRicezione: TdxLayoutItem;
    dxLayoutGroupFrom: TdxLayoutGroup;
    dxLayoutItemAllegati: TdxLayoutItem;
    dxLayoutGroupAllegati: TdxLayoutGroup;
    dxBarButton12: TdxBarButton;
    Apri: TAction;
    dxBarButton13: TdxBarButton;
    procedure ApriConWordExecute(sender: TObject);
    procedure ApriExecute(sender: TObject);
    procedure ImportaAccept(sender: TObject);
    procedure ImportaUpdate(sender: TObject);
    procedure listAllegatiDblClick(sender: TObject);
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
    FOnImportFile: TImportFileEmailEvent;
    FFileName: string;
    procedure SetFileName(const Value: string);
    procedure UpdateStatusBar;
  private
    MailReader: TzOfficeMailReader;
    procedure FillAttachmentsList;
    procedure AssignBody(const Body: string; const isHtml: boolean);
  public // izViewerFrame
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    function AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
  published
    property FileName: string read FFileName write SetFileName stored False;
    property OnImportFile: TImportFileEmailEvent read FOnImportFile write FOnImportFile;
  end;

implementation

uses
  Winapi.ShellAPI,
  System.DateUtils,
  System.IOUtils,
  IdAttachmentFile,
  dxRichEdit.View.PrintLayout,
  zdx,
  zBaseLib,
  zOffice.Utils,
  zOffice;

{$R *.dfm}

function TzViewerMailFrame.ComponentPrinter: TdxComponentPrinter;
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

constructor TzViewerMailFrame.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  MailReader := TzOfficeMailReader.Create;

  dx.initBar(dxBarManagerBar);

  edFrom.Clear;
  edOggetto.Clear;
  edData.Clear;
  listAllegati.Clear;

  Importa.Dialog.DefaultExt := '*.eml';
  Importa.Dialog.Filter := FilterForFileTypes([ftMail]);

  CreaAzioniDiStampa;
end;

destructor TzViewerMailFrame.Destroy;
begin
  inherited;
  FreeAndNil(MailReader);
end;

function TzViewerMailFrame.AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
begin
  assert(Assigned(Action));

  Result := TdxBarButton.Create(Self);
  Result.Name := CreateUniqueName(Self, Self, Result, 'btn' + Action.Name, '');
  Result.Action := Action;
  Result.PaintStyle := psCaptionGlyph;

  if Action.AutoCheck then
  begin
    Result.ButtonStyle := bsChecked;
    Result.Down := Action.Checked;
  end;

  dxBarManagerBar.ItemLinks.Add(Result); // .VisibleIndex := Position;
end;

procedure TzViewerMailFrame.ApriConWordExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerMailFrame.ApriExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ViewFile(FileName);
end;

procedure TzViewerMailFrame.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');

  FFileName := '';

  if not dxRichEditControl.Document.IsEmpty then
  begin
    edFrom.Clear;
    edData.Clear;
    edOggetto.Clear;
    listAllegati.Clear;
    dxRichEditControl.Document.CreateNewDocument;
    dxRichEditControl.DocumentModelModified := False;
  end;

  UpdateStatusBar;

  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzViewerMailFrame.ImportaAccept(sender: TObject);
begin
  if Assigned(FOnImportFile) then
    OnImportFile(Self, Importa.Dialog.FileName);
end;

procedure TzViewerMailFrame.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := Assigned(FOnImportFile);
end;

procedure TzViewerMailFrame.OpenFile(const FileName: string);
  procedure DoOpen;
  begin
    edFrom.Clear;
    edOggetto.Clear;
    edData.Clear;

    MailReader.LoadFileEML(FileName, dxRichEditControl);

    edFrom.EditValue := MailReader.MessageFrom;
    edOggetto.EditValue := MailReader.MessageSubject;
    edData.EditValue := MailReader.MessageDate.ToString;

    AssignBody(MailReader.MessageBody, MailReader.MessageBodyIsHTML);

    FillAttachmentsList;
  end;

begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if FileName.IsEmpty then
    CloseFile
  else
  begin
    SiMain.LogString('TzViewerImageFrame.OpenFile', FileName);

    DoOpen;

    FFileName := FileName;
  end;
end;

procedure TzViewerMailFrame.CreaAzioniDiStampa;
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

  dxBarButton3.Action := FStampa;
  dxBarButton4.Action := FAnteprimaDiStampa;
end;

procedure TzViewerMailFrame.AzioniDiStampaUpdate(sender: TObject);
begin
  FStampa.Enabled := FFileName <> '';
  FAnteprimaDiStampa.Enabled := FStampa.Enabled;
end;

procedure TzViewerMailFrame.StampaExecute(sender: TObject);
begin
  if FFileName = '' then
    Exit;

  // la prima chiamata crea il TdxComponentPrinter e il collegamento di stampa
  ComponentPrinter;
  FComponentPrinterLink.Print(True);
end;

procedure TzViewerMailFrame.AnteprimaDiStampaExecute(sender: TObject);
begin
  if FFileName = '' then
    Exit;

  ComponentPrinter;
  FComponentPrinterLink.Preview(True);
end;

procedure TzViewerMailFrame.Print;
begin
  StampaExecute(nil);
end;

procedure TzViewerMailFrame.SetAllowedImportFileTypes(FileTypes: TzFileTypes);
begin
  // se impostato da zOffice.MultiViewer
  Importa.dialog.Filter := FilterForFileTypes(FileTypes);
end;

procedure TzViewerMailFrame.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');

  if not FileExists(Value) then
    CloseFile
  else
    OpenFile(Value);

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzViewerMailFrame.UpdateStatusBar;
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

procedure TzViewerMailFrame.AssignBody(const Body: string; const isHtml: boolean);
var
  Stream: TStringStream;
begin

  if not isHtml then
    dxRichEditControl.Document.Text := Body
  else
  begin
    Stream := TStringStream.Create(Body);
    try
      dxRichEditControl.LoadDocument(Stream, TdxRichEditDocumentFormat.Html);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TzViewerMailFrame.FillAttachmentsList;
var
  AttachmentFile: TIdAttachmentFile;
  item: TListItem;
begin
  listAllegati.Clear;

  for AttachmentFile in MailReader.Attachments do
  begin
    item := listAllegati.Items.Add;
    item.caption := AttachmentFile.FileName;
    item.Data := AttachmentFile;
    item.ImageIndex := AttachmentFile.ImageIndex;
  end;
end;

procedure TzViewerMailFrame.listAllegatiDblClick(sender: TObject);
var
  item: TListItem;
  AttachmentFile: TIdAttachmentFile;
begin
  item := listAllegati.Selected;

  if not Assigned(item) then
    Exit;

  AttachmentFile := TIdAttachmentFile(item.Data);

  AttachmentFile.ShowAttachmentFile;
end;

end.
