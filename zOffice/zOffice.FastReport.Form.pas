unit zOffice.FastReport.Form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  frxClass,
  frxPreview,
  System.Actions,
  Vcl.ActnList,
  frDPIAwareControls,
  frxDPIAwareBaseControls,
  frxExportPDF,
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
  cxImageList,
  cxControls,
  dxRichEdit.Platform.Win.Control,
  dxRichEdit.Control.Core,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxRibbonSkins,
  dxRibbonCustomizationForm,
  cxClasses,
  dxRibbon,
  dxBar,
  dxStatusBar,
  dxRibbonStatusBar,
  zOffice.Types, // TzSetupAzioniDocumentoProc
  zOffice.Reports.Controller, // TzAzioneDocumento
  zOffice.Reports.ActionsBarHelper; // TzDocumentActionsBarHelper

type
  TzOfficeFastReportForm = class(TForm)
    frxPreview: TfrxPreview;
    ActionList: TActionList;
    actPrint: TAction;
    actOpen: TAction;
    actSave: TAction;
    actPdf: TAction;
    actEmail: TAction;
    actFind: TAction;
    actZoomPlus: TAction;
    actZoomMinus: TAction;
    actFirst: TAction;
    actPrior: TAction;
    actNext: TAction;
    actLast: TAction;
    actPageSettings: TAction;
    actDesigner: TAction;
    actCancel: TAction;
    actZoomWholePage: TAction;
    actZoomPageWidth: TAction;
    actZoom100: TAction;
    dxBarManager: TdxBarManager;
    dxRibbonTab: TdxRibbonTab;
    dxRibbon: TdxRibbon;
    dxRibbonStatusBar: TdxRibbonStatusBar;
    dxBarManagerBar1: TdxBar;
    dxBarManagerBar2: TdxBar;
    dxBarManagerBar3: TdxBar;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton4: TdxBarLargeButton;
    dxBarLargeButton5: TdxBarLargeButton;
    dxBarLargeButton6: TdxBarLargeButton;
    dxBarLargeButton7: TdxBarLargeButton;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarLargeButton8: TdxBarLargeButton;
    dxBarLargeButton9: TdxBarLargeButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarLargeButton10: TdxBarLargeButton;
    dxBarLargeButton11: TdxBarLargeButton;
    dxBarLargeButton12: TdxBarLargeButton;
    dxBarLargeButton13: TdxBarLargeButton;
    dxBarLargeButton14: TdxBarLargeButton;
    dxBarLargeButton15: TdxBarLargeButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarManagerBar4: TdxBar;
    Chiudi: TAction;
    dxBarLargeButton16: TdxBarLargeButton;
    // Azioni documentali: gruppo "Documento" (bar + bottoni + azioni).
    // Le 5 azioni documentali portano Ord(TzAzioneDocumento) nel Tag.
    barDocumento: TdxBar;
    actDocFirma: TAction;
    actDocProtocolla: TAction;
    actDocConserva: TAction;
    actDocInviaPec: TAction;
    actDocInviaMail: TAction;
    actDocAggiornaStato: TAction;
    actDocVersioni: TAction;
    btnDocFirma: TdxBarLargeButton;
    btnDocProtocolla: TdxBarLargeButton;
    btnDocConserva: TdxBarLargeButton;
    btnDocInviaPec: TdxBarLargeButton;
    btnDocInviaMail: TdxBarLargeButton;
    btnDocAggiornaStato: TdxBarLargeButton;
    btnDocVersioni: TdxBarLargeButton;
    dxBarLargeButton17: TdxBarLargeButton;
    actDocGeneraAllegato: TAction;
    procedure actPrintExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actPdfExecute(Sender: TObject);
    procedure actEmailExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actZoomPlusExecute(Sender: TObject);
    procedure actZoomMinusExecute(Sender: TObject);
    procedure actFirstExecute(Sender: TObject);
    procedure actPriorExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actLastExecute(Sender: TObject);
    procedure actPageSettingsExecute(Sender: TObject);
    procedure actDesignerExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actDocGeneraAllegatoExecute(Sender: TObject);
    procedure actDocGeneraAllegatoUpdate(Sender: TObject);
    procedure actZoomWholePageExecute(Sender: TObject);
    procedure actZoomPageWidthExecute(Sender: TObject);
    procedure actZoom100Execute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure frxPreviewPageChanged(Sender: TfrxPreview; PageNo: Integer);

    // Azioni documentali: handler condivisi dalle TAction del gruppo
    // "Documento" (aggiunte a mano nel DFM). Le cinque azioni documentali
    // usano la coppia AzioneDocumento* e portano Ord(TzAzioneDocumento) nel Tag.
    procedure AzioneDocumentoUpdate(Sender: TObject);
    procedure AzioneDocumentoExecute(Sender: TObject);
    procedure AggiornaStatoDocumentoUpdate(Sender: TObject);
    procedure AggiornaStatoDocumentoExecute(Sender: TObject);
    procedure VersioniDocumentoUpdate(Sender: TObject);
    procedure VersioniDocumentoExecute(Sender: TObject);
  private
    PDFExport: TfrxPDFExport;
    FAzioniDocumento: TzDocumentActionsBarHelper;
  private
    procedure UpdateStatusBar;
  public
    constructor Create(aOwner: TComponent); override;
    procedure ShowPreview(AReport: TfrxReport; APDFExport: TfrxPDFExport = nil; SetupAzioniDocumento: TzSetupAzioniDocumentoProc = nil);
  end;

implementation

uses
  System.IOUtils,
  zMsg,
  zDX;

{$R *.dfm}

procedure TzOfficeFastReportForm.UpdateStatusBar;
begin

  if dxRibbonStatusBar.Panels.Count >= 2 then
  begin
    dxRibbonStatusBar.Panels[0].Text := Format('Pagina %d di %d', [frxPreview.PageNo, frxPreview.PageCount]);
    dxRibbonStatusBar.Panels[1].Text := Format('Zoom: %d%%', [Round(frxPreview.Zoom * 100)]);
  end;
end;

procedure TzOfficeFastReportForm.ShowPreview(AReport: TfrxReport; APDFExport: TfrxPDFExport = nil; SetupAzioniDocumento: TzSetupAzioniDocumentoProc = nil);
begin
  AReport.Preview := frxPreview;
  AReport.ShowPreparedReport;
  PDFExport := APDFExport;

  // azioni documentali: il gruppo "Documento" e' nel DFM (TdxBar + bottoni +
  // TAction); qui riceviamo l'helper da agganciare all'OnUpdate/OnExecute di
  // quelle azioni. nil = azioni non configurate -> nascondi il gruppo.
  FAzioniDocumento := nil;
  if assigned(SetupAzioniDocumento) then
    FAzioniDocumento := SetupAzioniDocumento(Self,
      function: string
      var
        salvaShowDialog: Boolean;
        salvaOpenAfterExport: Boolean;
        salvaFileName: string;
      begin
        if not assigned(PDFExport) then
          raise Exception.Create('Export PDF non disponibile in questa anteprima');

        result := TPath.ChangeExtension(TPath.GetTempFileName, '.pdf');

        salvaShowDialog := PDFExport.ShowDialog;
        salvaOpenAfterExport := PDFExport.OpenAfterExport;
        salvaFileName := PDFExport.FileName;
        try
          PDFExport.ShowDialog := False;
          PDFExport.OpenAfterExport := False;
          PDFExport.FileName := result;
          frxPreview.Export(PDFExport);
        finally
          PDFExport.ShowDialog := salvaShowDialog;
          PDFExport.OpenAfterExport := salvaOpenAfterExport;
          PDFExport.FileName := salvaFileName;
        end;
      end);

  // il Tag e la caption iniziale delle azioni li imposta l'helper, per nome,
  // sull'ActionList: nessun Tag "magico" nel DFM
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.InizializzaAzioniDocumento(ActionList);

  barDocumento.Visible := assigned(FAzioniDocumento);

  ShowModal;
end;

// ---------------------------------------------------------------------------
// Azioni documentali: handler condivisi dalle TAction del gruppo "Documento"
// ---------------------------------------------------------------------------

procedure TzOfficeFastReportForm.AzioneDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaAzioneDocumento(TzAzioneDocumento(TComponent(Sender).Tag), TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := False;
end;

procedure TzOfficeFastReportForm.AzioneDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiAzioneDocumento(TzAzioneDocumento(TComponent(Sender).Tag));
end;

procedure TzOfficeFastReportForm.AggiornaStatoDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoAggiornaStato(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := False;
end;

procedure TzOfficeFastReportForm.AggiornaStatoDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoAggiornaStato;
end;

procedure TzOfficeFastReportForm.VersioniDocumentoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoVersioni(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := False;
end;

procedure TzOfficeFastReportForm.VersioniDocumentoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoVersioni;
end;

procedure TzOfficeFastReportForm.actPrintExecute(Sender: TObject);
begin
  frxPreview.Print;
end;

procedure TzOfficeFastReportForm.actOpenExecute(Sender: TObject);
begin
  frxPreview.LoadFromFile;
end;

procedure TzOfficeFastReportForm.actSaveExecute(Sender: TObject);
begin
  frxPreview.SaveToFile;
end;

procedure TzOfficeFastReportForm.actPdfExecute(Sender: TObject);
begin
  // se il documento puo' diventare un allegato, si chiede all'operatore.
  // Quando la funzione non c'e' o e' gia' stata usata, il comportamento
  // resta quello di sempre.
  if assigned(FAzioniDocumento) and FAzioniDocumento.GeneraAllegatoDisponibile then
    case ConfirmYesNoCancel('Generare anche l''allegato al documento?' + sLineBreak + '(No = solo il file PDF, nessun allegato)', mtConfirmation) of
      mrYes:
        begin
          FAzioniDocumento.EseguiComandoGeneraAllegato;
          exit;
        end;
      mrCancel:
        exit;
      // mrNo: prosegue con l'esportazione normale
    end;

  if assigned(PDFExport) then
  begin
    PDFExport.ShowDialog := True;
    frxPreview.Export(PDFExport);
  end;
end;

procedure TzOfficeFastReportForm.actEmailExecute(Sender: TObject);
begin
  // frxPreview.Export(FiltroEmail);
end;

procedure TzOfficeFastReportForm.actFindExecute(Sender: TObject);
begin
  frxPreview.Find;
end;

procedure TzOfficeFastReportForm.actZoomPlusExecute(Sender: TObject);
begin
  frxPreview.Zoom := frxPreview.Zoom + 0.25;
end;

procedure TzOfficeFastReportForm.actZoomMinusExecute(Sender: TObject);
begin
  frxPreview.Zoom := frxPreview.Zoom - 0.25;
end;

procedure TzOfficeFastReportForm.actZoomWholePageExecute(Sender: TObject);
begin
  frxPreview.ZoomMode := zmWholePage;
end;

constructor TzOfficeFastReportForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  PDFExport := nil;
end;

procedure TzOfficeFastReportForm.actZoomPageWidthExecute(Sender: TObject);
begin
  frxPreview.ZoomMode := zmPageWidth;
end;

procedure TzOfficeFastReportForm.actZoom100Execute(Sender: TObject);
begin
  frxPreview.Zoom := 1.0;
end;

procedure TzOfficeFastReportForm.actFirstExecute(Sender: TObject);
begin
  frxPreview.First;
end;

procedure TzOfficeFastReportForm.actPriorExecute(Sender: TObject);
begin
  frxPreview.Prior;
end;

procedure TzOfficeFastReportForm.actNextExecute(Sender: TObject);
begin
  frxPreview.Next;
end;

procedure TzOfficeFastReportForm.actLastExecute(Sender: TObject);
begin
  frxPreview.Last;
end;

procedure TzOfficeFastReportForm.actPageSettingsExecute(Sender: TObject);
begin
  frxPreview.PageSetupDlg;
end;

procedure TzOfficeFastReportForm.actDesignerExecute(Sender: TObject);
begin
  frxPreview.Edit;
end;

procedure TzOfficeFastReportForm.actCancelExecute(Sender: TObject);
begin
  Close;
end;

procedure TzOfficeFastReportForm.actDocGeneraAllegatoExecute(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.EseguiComandoGeneraAllegato;
end;

procedure TzOfficeFastReportForm.actDocGeneraAllegatoUpdate(Sender: TObject);
begin
  if assigned(FAzioniDocumento) then
    FAzioniDocumento.AggiornaComandoGeneraAllegato(TCustomAction(Sender))
  else
    TCustomAction(Sender).Visible := False;
end;

procedure TzOfficeFastReportForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzOfficeFastReportForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  frxPreview.MouseWheelScroll(WheelDelta, Shift, MousePos, False);
  Handled := True;
end;

procedure TzOfficeFastReportForm.frxPreviewPageChanged(Sender: TfrxPreview; PageNo: Integer);
begin
  UpdateStatusBar;
end;

end.
