unit zOffice.Pdf.Frame;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Contnrs,
  System.ImageList,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.ActnList,
  Vcl.StdActns,
  Vcl.StdCtrls,
  Vcl.ExtDlgs,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Data.DB,
  cxClasses,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxImageList,
  cxDrawTextUtils,
  dxBar,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  dxPDFDocument,
  dxBarBuiltInMenu,
  dxCustomPreview,
  dxPDFViewer,
  dxPDFViewerActions,
  dxPrinting,
  dxActions,
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
  dxPScxEditorLnks,
  zOffice.types,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  dxUIAClasses;

type
  TzViewerPdfFrame = class;

  TImportFilePdfEvent = procedure(sender: TzViewerPdfFrame; const FileName: string) of object;
  // template
  TFillFieldProc = reference to procedure(Pdf: TdxPDFDocument; AField: TdxPDFCustomField; var Continue: boolean);
  TBeforeSavePdfProc = reference to procedure(Pdf: TdxPDFDocument);

  TzViewerPdfFrame = class(TFrame, izViewerFrame)
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
    Apri: TAction;
    dxBarButton4: TdxBarButton;
    procedure ApriExecute(sender: TObject);
    procedure dxPDFViewerDocumentLoaded(ASender: TdxPDFDocument; const AInfo: TdxPDFDocumentLoadInfo);
    procedure dxPDFViewerSelectedPageChanged(sender: TObject; APageIndex: Integer);
    procedure FileSaveAsAccept(sender: TObject);
    procedure ImportaAccept(sender: TObject);
    procedure ImportaUpdate(sender: TObject);
    procedure SalvaExecute(sender: TObject);
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
    FComponentPrinterLink: TdxPDFViewerReportLink;
  public
    // Creato al primo uso: vedi la nota sui campi privati qui sopra.
    function ComponentPrinter: TdxComponentPrinter;
  private
    // Mantis #156 - 2026-09-22: la stampa passa da un'azione propria.
    // Le azioni di stampa DevExpress (discendenti di TdxCustomPrintingAction)
    // si disabilitano da sole finche' non esiste un collegamento di stampa
    // registrato per il controllo: TdxCustomPrintingAction.IsEnabled chiama
    // dxPrintingRepository.CanBuildReport, che risponde False finche' nessun
    // TBasedxReportLink si e' registrato. Da quando il TdxComponentPrinter e
    // il suo collegamento sono a creazione differita, quella registrazione non
    // avveniva piu' e il pulsante restava grigio (allegato non stampabile).
    // Con un'azione propria il pulsante resta attivo, il collegamento nasce al
    // clic (la stampante predefinita viene letta solo quando si stampa davvero)
    // e la stampa conserva i margini impostati per il ticket #128.
    FStampa: TAction;
    procedure CreaAzioniDiStampa;
    procedure StampaExecute(sender: TObject);
    procedure AzioniDiStampaUpdate(sender: TObject);
  private
    FFileName: string;
    FOnImportFile: TImportFilePdfEvent;
    procedure SetFileName(const Value: string);
  private
    procedure UpdateStatusBar;
  private
    procedure GenerateFromTemplate(DataSet: TDataSet; const TemplateFileName: string; DestFileName: string; const FillFieldProc: TFillFieldProc = nil;
      const BeforeSavePdfProc: TBeforeSavePdfProc = nil);
  protected
  public // izViewerFrame
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
  public
    constructor Create(aOwner: TComponent); override;
  public
    function AddToolbarButton(Action: TAction; const Position: Integer = 0): TdxBarButton;
  published
    property FileName: string read FFileName write SetFileName stored False;
    property OnImportFile: TImportFilePdfEvent read FOnImportFile write FOnImportFile;
  end;

var
  FrameViewer: TzViewerPdfFrame;

function CreateFileViewer(Owner: TComponent; Parent: TWinControl; const Name: string = 'zFileViewer'; Align: TAlign = alClient): TzViewerPdfFrame;

implementation

uses
  Winapi.ActiveX,
  Winapi.ShellAPI,
  System.IOUtils,
  System.Math,
  zBaseLib,
  zLocalizer,
  zdx,
  zOffice.utils,
  zOffice.Pdf.Utils,
  zMsg,
  zOffice;

const
  ZoomIncrement = 25;

const
  idxImage090 = 10;
  idxImage180 = 11;
  idxImage270 = 12;
  idxImage360 = 13;
{$R *.dfm}

function CreateFileViewer(Owner: TComponent; Parent: TWinControl; const Name: string = 'zFileViewer'; Align: TAlign = alClient): TzViewerPdfFrame;
begin
  result := TzViewerPdfFrame.Create(Owner);
  result.Name := Name;
  result.Parent := Parent;
  result.Align := Align;
end;

function TzViewerPdfFrame.ComponentPrinter: TdxComponentPrinter;
begin
  if not Assigned(FComponentPrinter) then
  begin
    FComponentPrinter := TdxComponentPrinter.Create(Self);
    FComponentPrinter.Name := 'dxComponentPrinter';
    // senza la clessidra globale di ExpressPrinting, come gli altri visualizzatori:
    // vedi Tdx.InitPrinter
    dx.InitPrinter(FComponentPrinter);
    FComponentPrinter.PreviewOptions.Caption := 'Anteprima';
    // Mantis #128 - 2026-09-17: niente OnBeforePreview: il gestore riportava
    // ScaleMode a smAdjust a ogni apertura della finestra di stampa.

    FComponentPrinterLink := FComponentPrinter.AddLink(dxPDFViewer) as TdxPDFViewerReportLink;
    FComponentPrinterLink.Name := 'dxComponentPrinterLink';
    FComponentPrinterLink.DesignerCaption := 'Modifica Report';
    FComponentPrinterLink.ReportDocument.Caption := 'Report';
    FComponentPrinterLink.ShrinkToPageWidth := True;

    // valori della pagina di stampa: millesimi di millimetro
    // Mantis #128 - 2026-09-17: margini da 80640 (80,64 mm per lato, allegato
    // stampato in miniatura) a 10000 (1 cm); intestazione e pie' di pagina a zero.
    FComponentPrinterLink.PrinterPage.CenterOnPageH := True;
    FComponentPrinterLink.PrinterPage.CenterOnPageV := True;
    FComponentPrinterLink.PrinterPage.DMPaper := 9; // A4
    FComponentPrinterLink.PrinterPage.Header := 0;
    FComponentPrinterLink.PrinterPage.Footer := 0;
    FComponentPrinterLink.PrinterPage.Margins.Left := 10000;
    FComponentPrinterLink.PrinterPage.Margins.Top := 10000;
    FComponentPrinterLink.PrinterPage.Margins.Right := 10000;
    FComponentPrinterLink.PrinterPage.Margins.Bottom := 10000;
    FComponentPrinterLink.PrinterPage.PageSize.X := 210820;
    FComponentPrinterLink.PrinterPage.PageSize.Y := 297180;
    FComponentPrinterLink.PrinterPage.Orientation := dxPrintUtils.poAuto;
    FComponentPrinterLink.PrinterPage.ScaleMode := smFit;
  end;

  result := FComponentPrinter;
end;

constructor TzViewerPdfFrame.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);

  FOnImportFile := nil;

  CloseFile;

  dx.initBar(dxBarManagerBar);

  Importa.Dialog.DefaultExt := '*.pdf';
  Importa.Dialog.Filter := FilterForFileTypes([ftPdf]);

  CreaAzioniDiStampa;
end;

function TzViewerPdfFrame.AddToolbarButton(Action: TAction; const Position: Integer = 0): TdxBarButton;
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

procedure TzViewerPdfFrame.OpenFile(const FileName: string);
var
  PageIndex: Integer;
  WidthIn, HeightIn: Double;
begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if FileName.IsEmpty then
    CloseFile
  else
  begin
    SiMain.LogString('TzViewerImageFrame.OpenFile', FileName);

    // Protezione contro PDF con pagine dalle dimensioni fisiche anomale (es. MediaBox impostato
    // 1:1 con i pixel di un'immagine incorporata ad alta risoluzione): caricarli nel PDF Viewer
    // puo' far fallire GdipCreateBitmap per esaurimento risorse GDI+ (vedi Mantis Gesty #26).
    // Meglio avvisare l'utente e annullare il caricamento piuttosto che rischiare il crash.
    try
      if FindOversizedPdfPage(FileName, PageIndex, WidthIn, HeightIn) then
      begin
        SiMain.LogString('OpenFile', Format('Pagina %d con dimensioni anomale (%.0f x %.0f pollici): caricamento annullato',
          [PageIndex + 1, WidthIn, HeightIn]));

        ConfirmOk(Format('Impossibile visualizzare l''anteprima di "%s".' + sLineBreak + sLineBreak +
          'La pagina %d ha dimensioni anomale (%.0f x %.0f pollici), probabilmente per un errore nella generazione ' +
          'del PDF (risoluzione non corretta di un''immagine incorporata). Il caricamento e'' stato annullato per ' +
          'evitare un errore di memoria del visualizzatore.', [ExtractFileName(FileName), PageIndex + 1, WidthIn, HeightIn]), mtWarning);

        CloseFile;
        Exit;
      end;
    except
      on e: Exception do
      begin
        SiMain.LogException(e);

        ConfirmOk(Format('Impossibile analizzare il file "%s" prima di caricarlo (%s).' + sLineBreak +
          'Il caricamento e'' stato annullato.', [ExtractFileName(FileName), e.Message]), mtWarning);

        CloseFile;
        Exit;
      end;
    end;

    dxPDFViewer.LoadFromFile(FileName);
    FFileName := FileName;
  end;

  SiMain.LeaveMethod(Self, 'OpenFile');
end;

procedure TzViewerPdfFrame.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');

  FFileName := '';

  if dxPDFViewer.IsDocumentLoaded then
    dxPDFViewer.Clear;

  UpdateStatusBar;

  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzViewerPdfFrame.CreaAzioniDiStampa;
begin
  // Mantis #156 - 2026-09-22: il pulsante Stampa viene riagganciato a
  // un'azione propria; vedi la nota sui campi privati.
  FStampa := TAction.Create(Self);
  FStampa.Name := 'StampaDocumento';
  FStampa.ActionList := Self.ActionList;
  FStampa.Caption := dxPDFViewerShowPrintForm.Caption;
  FStampa.Hint := dxBarButtonPrint.Hint;
  FStampa.ImageIndex := dxPDFViewerShowPrintForm.ImageIndex;
  FStampa.OnExecute := StampaExecute;
  FStampa.OnUpdate := AzioniDiStampaUpdate;

  dxBarButtonPrint.Action := FStampa;
end;

procedure TzViewerPdfFrame.AzioniDiStampaUpdate(sender: TObject);
begin
  FStampa.Enabled := dxPDFViewer.IsDocumentLoaded;
end;

procedure TzViewerPdfFrame.StampaExecute(sender: TObject);
begin
  if not dxPDFViewer.IsDocumentLoaded then
    Exit;

  // la prima chiamata crea il TdxComponentPrinter e il collegamento di stampa
  ComponentPrinter;
  FComponentPrinterLink.Print(True);
end;

procedure TzViewerPdfFrame.Print;
begin
  StampaExecute(nil);
end;

procedure TzViewerPdfFrame.SalvaExecute(sender: TObject);
begin
  // if SaveDialog.Execute then
  // 06.03.2013:richiesta di Canetti, il file prodotto � diverso dall'originale e viene contestato da poste online
  // gtPDFDocument.SaveToFile(SaveDialog.FileName);
  // Win95Copy(Application.Handle, FileName, SaveDialog.FileName);
end;

procedure TzViewerPdfFrame.SetAllowedImportFileTypes(FileTypes: TzFileTypes);
begin
  // se impostato da zOffice.MultiViewer
  Importa.Dialog.Filter := FilterForFileTypes(FileTypes);
end;

procedure TzViewerPdfFrame.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');

  if not FileExists(Value) then
    CloseFile
  else
    OpenFile(Value);

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzViewerPdfFrame.UpdateStatusBar;
begin

  if not Assigned(dxPDFViewer) then
    Exit;

  if Assigned(dxPDFViewer.Document) then
    StatusBar.Panels[0].Visible := dxPDFViewer.Document.SignatureOptions.IsDocumentSigned
  else
    StatusBar.Panels[0].Visible := False;

  if not dxPDFViewer.IsDocumentLoaded then
    StatusBar.Panels[1].Text := ''
  else
    StatusBar.Panels[1].Text := Format('Pagina %d di %d', [dxPDFViewer.CurrentPageIndex, dxPDFViewer.PageCount]);
end;

procedure TzViewerPdfFrame.ApriExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ViewFile(FileName);
end;

procedure TzViewerPdfFrame.dxPDFViewerDocumentLoaded(ASender: TdxPDFDocument; const AInfo: TdxPDFDocumentLoadInfo);
begin
  UpdateStatusBar;
end;

procedure TzViewerPdfFrame.dxPDFViewerSelectedPageChanged(sender: TObject; APageIndex: Integer);
begin
  UpdateStatusBar;
end;

procedure TzViewerPdfFrame.FileSaveAsAccept(sender: TObject);
var
  Folder: string;
begin
  TFile.Copy(FileName, FileSaveAs.Dialog.FileName);
  Folder := ExtractFilePath(FileSaveAs.Dialog.FileName);
  ShellExecute(0, PCHAR('open'), PCHAR(Folder), nil, nil, SW_RESTORE);
end;

procedure TzViewerPdfFrame.GenerateFromTemplate(DataSet: TDataSet; const TemplateFileName: string; DestFileName: string; const FillFieldProc: TFillFieldProc = nil;
  const BeforeSavePdfProc: TBeforeSavePdfProc = nil);
var
  Pdf: TdxPDFDocument;
  i: Integer;
  s: String;
  FieldName: string;
  AskValue: boolean;
begin
  SiMain.EnterMethod(Self, 'GenerateFromTemplate');

  Pdf := TdxPDFDocument.Create;
  try
    Pdf.LoadFromFile(TemplateFileName);

    Pdf.form.ForEach(
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

          FillFieldProc(Pdf, AField, Continue);
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

                case ConfirmYesNoCancel('Valore per il campo ' + FieldName + '?', mtConfirmation) of
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
                // case ConfirmYesNoCancel('Valore per il campo ' + FieldName + '?', mtConfirmation) of
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
      BeforeSavePdfProc(Pdf);

    Pdf.SaveToFile(DestFileName);
  finally
    FreeAndNil(Pdf);
  end;

  SiMain.LeaveMethod(Self, 'GenerateFromTemplate');
end;

procedure TzViewerPdfFrame.ImportaAccept(sender: TObject);
begin
  if Assigned(FOnImportFile) then
    OnImportFile(Self, Importa.Dialog.FileName);
end;

procedure TzViewerPdfFrame.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := Assigned(FOnImportFile);
end;

end.


files.lib
