unit zOffice.Pdf.Form;

interface

uses
  Winapi.Windows,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Actions,
  Vcl.ImgList,
  Vcl.Controls,
  Vcl.ActnList,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  dxSkinsdxRibbonPainter,
  dxSkinsCore,
  dxSkinsForm,
  dxSkinsdxBarPainter,
  dxSkinscxPCPainter,
  dxPDFViewer,
  dxRibbonCustomizationForm,
  dxRibbonSkins,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxTextEdit,
  cxSpinEdit,
  dxPDFViewerActions,
  dxActions,
  cxShellBrowserDialog,
  dxBar,
  dxRibbonGallery,
  dxSkinChooserGallery,
  cxBarEditItem,
  dxCustomPreview,
  cxClasses,
  dxRibbon,
  dxRibbonForm,
  dxStatusBar,
  dxRibbonStatusBar,
  cxLabel,
  cxContainer,
  cxEdit,
  cxTrackBar,
  dxZoomTrackBar,
  dxBarExtItems,
  dxCore,
  dxCoreClasses,
  dxHashUtils,
  dxGDIPlusClasses,
  cxImage,
  dxPSActions,
  dxPSdxPDFViewerLnk,
  dxBarBuiltInMenu,
  dxPrinting,
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
  cxImageList,
  cxProgressBar,
  dxPDFDocument,
  dxLayoutcxEditAdapters,
  dxLayoutContainer,
  dxLayoutControl,
  cxButtons,
  dxPDFText,
  dxPDFRecognizedObject,
  dxPDFDocumentViewer,
  dxPDFBase,
  dxPDFCore,
  cxListView,
  dxScreenTip,
  dxCustomHint,
  cxHint,
  dxX509Certificate,
  dxPrintUtils,
  dxShellDialogs,
  dxPDFForm,
  dxPDFFormData,
  dxPDFTypes,
  zProgressBox,
  dxPSdxSpreadSheetLnk,
  dxPSRichEditControlLnk,
  dxPScxEditorLnks, dxUIAClasses;

type
  TPDFViewerExportFunc = function(AScale: Double): string of object;

  TzViewerPdfForm = class(TdxRibbonForm)
    dxBarManager: TdxBarManager;
    dxRibbon: TdxRibbon;
    dxBarManager1Bar2: TdxBar;
    cxBarEditItem1: TcxBarEditItem;
    dxPDFViewer: TdxPDFViewer;
    sbdSelectFolderDialog: TcxShellBrowserDialog;
    ActionList: TActionList;
    dxPDFViewerOpenDocumentAction: TdxPDFViewerOpenDocument;
    dxRibbonTabHome: TdxRibbonTab;
    dxBarFile: TdxBar;
    dxPDFViewerGoToPrevPageAction: TdxPDFViewerGoToPrevPage;
    dxBarLargeButtonPreviousPage: TdxBarLargeButton;
    dxPDFViewerGoToNextPageAction: TdxPDFViewerGoToNextPage;
    dxBarLargeButtonNextPage: TdxBarLargeButton;
    dxBarSubItem1: TdxBarSubItem;
    dxPDFViewerGoToFirstPageAction: TdxPDFViewerGoToFirstPage;
    dxBarLargeButtonFirstPage: TdxBarLargeButton;
    dxPDFViewerGoToLastPageAction: TdxPDFViewerGoToLastPage;
    dxBarLargeButtonLastPage: TdxBarLargeButton;
    dxPDFViewerZoomOutAction: TdxPDFViewerZoomOut;
    dxBarZoom: TdxBar;
    dxBarLargeButtonZoomOut: TdxBarLargeButton;
    dxPDFViewerZoomInAction: TdxPDFViewerZoomIn;
    dxBarLargeButtonZoomIn: TdxBarLargeButton;
    lbtnZoomGroup: TdxBarSubItem;
    dxPDFViewerZoom10Action: TdxPDFViewerZoom10;
    dxBarLargeButton10: TdxBarLargeButton;
    dxPDFViewerZoom25Action: TdxPDFViewerZoom25;
    dxBarLargeButton25: TdxBarLargeButton;
    dxPDFViewerZoom50Action: TdxPDFViewerZoom50;
    dxBarLargeButton50: TdxBarLargeButton;
    dxPDFViewerZoom75Action: TdxPDFViewerZoom75;
    dxBarLargeButton75: TdxBarLargeButton;
    dxPDFViewerZoom100Action: TdxPDFViewerZoom100;
    dxBarLargeButton100: TdxBarLargeButton;
    dxPDFViewerZoom125Action: TdxPDFViewerZoom125;
    dxBarLargeButton125: TdxBarLargeButton;
    dxPDFViewerZoom150Action: TdxPDFViewerZoom150;
    dxBarLargeButton150: TdxBarLargeButton;
    dxPDFViewerZoom200Action: TdxPDFViewerZoom200;
    dxBarLargeButton200: TdxBarLargeButton;
    dxPDFViewerZoom400Action: TdxPDFViewerZoom400;
    dxBarLargeButton400: TdxBarLargeButton;
    dxPDFViewerZoom500Action: TdxPDFViewerZoom500;
    dxBarLargeButton500: TdxBarLargeButton;
    dxPDFViewerZoomActualSizeAction: TdxPDFViewerZoomActualSize;
    dxBarLargeButtonActualSize: TdxBarLargeButton;
    dxPDFViewerZoomToPageLevelAction: TdxPDFViewerZoomToPageLevel;
    dxBarLargeButtonZoomtoPageLevel: TdxBarLargeButton;
    dxPDFViewerZoomFitWidthAction: TdxPDFViewerZoomFitWidth;
    dxBarLargeButtonFitWidth: TdxBarLargeButton;
    dxSkinChooserGalleryItem1: TdxSkinChooserGalleryItem;
    btnAbout: TdxBarLargeButton;
    lbExportToTIFF: TdxBarLargeButton;
    lbExportToPNG: TdxBarLargeButton;
    dxBarExit1: TdxBarLargeButton;
    dxBarButtonAbout: TdxBarLargeButton;
    bmiNavigation: TdxBar;
    dxRibbonStatusBar: TdxRibbonStatusBar;
    biStatusBarZoom: TdxBar;
    cxBarEditItem2: TcxBarEditItem;
    bilPageCount: TcxBarEditItem;
    dxRibbonStatusBar1Container5: TdxStatusBarContainerControl;
    tbZoom: TdxZoomTrackBar;
    biStatusBarCurrentZoom: TdxBarStatic;
    dxBarSubItem3: TdxBarSubItem;
    cxBarEditItem3: TcxBarEditItem;
    dxBarSeparator1: TdxBarSeparator;
    bteActualZoom: TcxBarEditItem;
    dxRibbonNavigationGroup: TdxBar;
    lbtnNavigation: TdxBarSubItem;
    bseActivePage: TcxBarEditItem;
    dxRibbonStatusBarActivePage: TdxBarSpinEdit;
    sseActivePage: TcxBarEditItem;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarStatic1: TdxBarStatic;
    sbPageCount: TdxBarStatic;
    dxPDFViewerShowPrintForm: TdxPDFViewerShowPrintForm;
    dxBarLargeButtonPrint: TdxBarLargeButton;
    dxPDFViewerSelectTool: TdxPDFViewerSelectTool;
    dxBarTools: TdxBar;
    dxBarLargeButtonSelectTool: TdxBarLargeButton;
    dxPDFViewerHandTool: TdxPDFViewerHandTool;
    dxBarLargeButtonHandTool: TdxBarLargeButton;
    dxPDFViewerSelectAll: TdxPDFViewerSelectAll;
    dxBarLargeButtonSelectAll: TdxBarLargeButton;
    dxPDFViewerGoToPrevView: TdxPDFViewerGoToPrevView;
    dxBarLargeButtonPreviousView: TdxBarLargeButton;
    dxPDFViewerGoToNextView: TdxPDFViewerGoToNextView;
    dxBarLargeButtonNextView: TdxBarLargeButton;
    lbtnRotateView: TdxBarSubItem;
    dxPDFViewerRotateClockwise: TdxPDFViewerRotateClockwise;
    dxBarLargeButtonRotateClockwise: TdxBarLargeButton;
    dxPDFViewerRotateCounterClockwise: TdxPDFViewerRotateCounterClockwise;
    dxBarLargeButtonRotateCounterclockwise: TdxBarLargeButton;
    dxComponentPrinter: TdxComponentPrinter;
    dxComponentPrinterLink1: TdxPDFViewerReportLink;
    dxBarLargeButtonFind: TdxBarLargeButton;
    dxTextSearchStatusBar: TdxBar;
    dxBarProgressItem1: TdxBarProgressItem;
    cxBarEditItem4: TcxBarEditItem;
    cxBarEditItem5: TcxBarEditItem;
    bbAbortTextSearch: TdxBarButton;
    dxPDFViewerFind: TdxPDFViewerFind;
    dxBarFind: TdxBar;
    dxBarLargeButtonFind1: TdxBarLargeButton;
    dxBarButton1: TdxBarButton;
    dxRibbonStatusBar1Container6: TdxStatusBarContainerControl;
    acSinglePageContinuous: TAction;
    lbtnSinglePageMode: TdxBarLargeButton;
    dxBarSubItem6: TdxBarSubItem;
    barExport: TdxBar;
    dxBarSubItem7: TdxBarSubItem;
    lbtnExportGroup: TdxBarSubItem;
    acSaveAs: TAction;
    SaveDialog: TdxSaveFileDialog;
    dxBarLargeButton5: TdxBarLargeButton;
    acSave: TAction;
    dxRibbon1Tab2: TdxRibbonTab;
    dxBarManager1Bar1: TdxBar;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    acFormDataImport: TAction;
    acFormDataExport: TAction;
    ofdOpenFormDataDialog: TdxOpenFileDialog;
    dxBarLargeButton4: TdxBarLargeButton;
    acFormDataReset: TAction;
    dxBarManager1Bar3: TdxBar;
    dxBarLargeButton7: TdxBarLargeButton;
    acAllowEdit: TAction;
    dxBarLargeButton8: TdxBarLargeButton;
    ProgressBox: TProgressBox;
    dxBarManagerBar1: TdxBar;
    Chiudi: TAction;
    dxBarLargeButton9: TdxBarLargeButton;
    dxBarLargeButton6: TdxBarLargeButton;
    actShellExecute: TAction;
    dxBarLargeButton11: TdxBarLargeButton;
    procedure bseActivePageChange(Sender: TObject);
    procedure dxPDFViewerZoomFactorChanged(Sender: TObject);
    procedure bteActualZoomChange(Sender: TObject);
    procedure dxPDFViewerDocumentLoaded(ASender: TdxPDFDocument; const AInfo: TdxPDFDocumentLoadInfo);
    procedure dxBarButtonExportToPNGClick(Sender: TObject);
    procedure dxBarButtonExportToTIFFClick(Sender: TObject);
    procedure dxPDFViewerSelectedPageChanged(Sender: TObject; APageIndex: Integer);
    procedure tbZoomPropertiesChange(Sender: TObject);
    procedure sseActivePageChange(Sender: TObject);
    procedure dxPDFViewerDocumentUnloaded(Sender: TObject);
    procedure dxPDFViewerShowFindPanel(Sender: TObject);
    procedure dxPDFViewerHideFindPanel(Sender: TObject);
    procedure dxPDFViewerSearchProgress(Sender: TdxPDFDocument; APageIndex, APercent: Integer);
    procedure bbAbortTextSearchClick(Sender: TObject);
    procedure dxPDFViewerShowPrintFormExecute(Sender: TObject);
    procedure dxPDFViewerHyperlinkClick(Sender: TdxPDFCustomViewer; const AURI: string; var AHandled: Boolean);
    procedure dxPDFViewerCustomDrawPreRenderPage(Sender: TObject; ACanvas: TcxCanvas; const APageInfo: TdxPDFPreRenderPageInfo; var ADone: Boolean);
    procedure dxPDFViewerCustomDrawPreRenderPageThumbnail(Sender: TObject; ACanvas: TcxCanvas; const APageInfo: TdxPDFPreRenderPageInfo; var ADone: Boolean);
    procedure dxPDFViewerAttachmentOpen(Sender: TdxPDFCustomViewer; AAttachment: TdxPDFFileAttachment; var AHandled: Boolean);
    procedure dxPDFViewerAttachmentSave(Sender: TdxPDFCustomViewer; AAttachment: TdxPDFFileAttachment; var AHandled: Boolean);
    procedure acSinglePageContinuousExecute(Sender: TObject);
    procedure acSaveAsUpdate(Sender: TObject);
    procedure acSaveAsExecute(Sender: TObject);
    procedure acSaveUpdate(Sender: TObject);
    procedure acSaveExecute(Sender: TObject);
    procedure dxPDFViewerCloseDocumentExecute(Sender: TObject);
    procedure acFormDataImportExecute(Sender: TObject);
    procedure acFormDataExportExecute(Sender: TObject);
    procedure acFormDataResetExecute(Sender: TObject);
    procedure acAllowEditExecute(Sender: TObject);
    procedure acAllowEditUpdate(Sender: TObject);
    procedure acFormDataResetUpdate(Sender: TObject);
    procedure acFormDataExportUpdate(Sender: TObject);
    procedure acFormDataImportUpdate(Sender: TObject);
    procedure actShellExecuteExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FAbortTextSearch: Boolean;
    FFileName: string;
    FLockCount: Integer;
    FPrevZoomFactor: Integer;
    FPreRenderPageImage: TdxSmartImage;

    function GetFormDataDialogFilter: string;
    function ExportToBitmaps: string;
    function ExportToTIFF: string;
    function ShowSaveAsDialog(const AFilter, AFileExtension: string; var AFileName: string): Boolean;
    procedure ExecuteLongOperation(AProc: TProc; ACaption, ATitle: string);

    function AllowFormDataOperation: Boolean;
    function IsLocked: Boolean;
    procedure BeginUpdate;
    procedure CancelUpdate;

    procedure AfterExport;
    procedure BeforeExport;
    procedure DrawPreRenderPage(ACanvas: TcxCanvas; const APageInfo: TdxPDFPreRenderPageInfo; AFontSizeFactor: Integer; var ADone: Boolean);
    procedure UpdateActivePageEditor(ASpinEdit: TcxBarEditItem);
    procedure UpdateControls;

    procedure OnDocumentSaveProgressHandler(Sender: TdxPDFDocument; Percent: Integer);
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure ShowFile(const FileName: string);

    procedure LoadFile(const FileName: string);
    function ShowModal: Integer; override;
    property FileName: string read FFileName;
  end;

procedure ViewFilePdf(const FileName: string);

implementation

{$R *.dfm}

uses
  ShellAPI,
  Types,
  Math,
  IOUtils,
  Graphics,
  dxTypeHelpers,
  dxCoreGraphics,
  cxGeometry,
  dxPDFCommandInterpreter,
  dxPDFUtils,
  zdx,
  zMsg,
  zz.Folders;

procedure ViewFilePdf(const FileName: string);
var
  zViewerPdfForm: TzViewerPdfForm;
begin
  Application.CreateForm(TzViewerPdfForm, zViewerPdfForm);
  try
    zViewerPdfForm.ShowFile(FileName);
  finally
    FreeAndNil(zViewerPdfForm);
  end;
end;

type
  TdxPDFViewerAccess = class(TdxPDFViewer);

function DropPercentChar(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] = '%') do
    Dec(I);
  Result := Copy(S, 1, I);
end;

{ TfrmPDFViewer }

procedure TzViewerPdfForm.bseActivePageChange(Sender: TObject);
begin
  if not IsLocked then
    dxPDFViewer.CurrentPageIndex := bseActivePage.EditValue - 1;
end;

procedure TzViewerPdfForm.bteActualZoomChange(Sender: TObject);
var
  V: Variant;
begin
  try
    V := StrToInt(DropPercentChar(bteActualZoom.EditValue));
  except
    try
      V := Round(StrToFloat(DropPercentChar(bteActualZoom.EditValue)));
    except
      V := FPrevZoomFactor;
    end;
  end;
  dxPDFViewer.OptionsZoom.ZoomFactor := V;
  FPrevZoomFactor := dxPDFViewer.OptionsZoom.ZoomFactor;
  bteActualZoom.EditValue := IntToStr(dxPDFViewer.OptionsZoom.ZoomFactor) + '%';
end;

function TzViewerPdfForm.GetFormDataDialogFilter: string;
var
  AFormat: TdxPDFFormDataFormat;
  AFormatExtension: string;
begin
  Result := '';
  for AFormat := Low(TdxPDFFormDataFormat) to High(TdxPDFFormDataFormat) do
  begin
    AFormatExtension := dxPDFFormDataFormatFileExtension(AFormat);
    Result := Result + UpperCase(AFormatExtension) + ' Files (*.' + AFormatExtension + ')|*.' + AFormatExtension;
    if AFormat <> High(TdxPDFFormDataFormat) then
      Result := Result + '|';
  end;
end;

function TzViewerPdfForm.ExportToBitmaps: string;
begin
  if sbdSelectFolderDialog.Execute then
  begin
    BeforeExport;
    try
      Result := sbdSelectFolderDialog.Path;

      dxPDFDocumentExportToPNG(dxPDFViewer.Document, Result, '.bmp', 1, ProgressBox.ProgressDlg, dxPDFViewer.RotationAngle);
    finally
      AfterExport;
    end;
  end;
end;

function TzViewerPdfForm.ExportToTIFF: string;
begin
  if ShowSaveAsDialog('TIFF - Tag Image File Format (*.tiff)|*.tiff', 'tiff', Result) then
  begin
    BeforeExport;
    try
      dxPDFDocumentExportToTIFF(dxPDFViewer.Document, Result, 1, ProgressBox.ProgressDlg, dxPDFViewer.RotationAngle);
    finally
      AfterExport;
    end;
  end;
end;

function TzViewerPdfForm.ShowSaveAsDialog(const AFilter, AFileExtension: string; var AFileName: string): Boolean;
var
  ASaveDialog: TdxSaveFileDialog;
begin
  ASaveDialog := TdxSaveFileDialog.Create(nil);
  ASaveDialog.Options := ASaveDialog.Options + [ofOverwritePrompt];
  ASaveDialog.Filter := AFilter;
  ASaveDialog.DefaultExt := AFileExtension;
  ASaveDialog.InitialDir := TFolders.UserDocumentsFolder;
  try
    Result := ASaveDialog.Execute;
    if Result then
      AFileName := ASaveDialog.FileName
    else
      AFileName := '';
  finally
    ASaveDialog.Free;
  end;
end;

procedure TzViewerPdfForm.ExecuteLongOperation(AProc: TProc; ACaption, ATitle: string);
begin
  BeforeExport;
  try
    AProc;
  finally
    AfterExport;
  end;
end;

procedure TzViewerPdfForm.sseActivePageChange(Sender: TObject);
begin
  if not IsLocked then
    dxPDFViewer.CurrentPageIndex := sseActivePage.EditValue - 1;
end;

procedure TzViewerPdfForm.tbZoomPropertiesChange(Sender: TObject);
begin
  biStatusBarCurrentZoom.Caption := IntToStr(tbZoom.Position) + '%';
  dxPDFViewer.OptionsZoom.ZoomFactor := tbZoom.Position;
end;

function TzViewerPdfForm.AllowFormDataOperation: Boolean;
var
  AFieldCount: Integer;
begin
  AFieldCount := 0;
  dxPDFViewer.Document.Form.ForEach(
    procedure(AField: TdxPDFCustomField)
    begin
      if AField.FieldType <> ftSignature then
        Inc(AFieldCount);
    end);
  Result := AFieldCount > 0;
end;

function TzViewerPdfForm.IsLocked: Boolean;
begin
  Result := FLockCount <> 0;
end;

procedure TzViewerPdfForm.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TzViewerPdfForm.CancelUpdate;
begin
  Dec(FLockCount);
end;

procedure TzViewerPdfForm.dxBarButtonExportToPNGClick(Sender: TObject);
begin
  ExportToBitmaps;
end;

procedure TzViewerPdfForm.dxBarButtonExportToTIFFClick(Sender: TObject);
begin
  ExportToTIFF;
end;

procedure TzViewerPdfForm.dxPDFViewerAttachmentOpen(Sender: TdxPDFCustomViewer; AAttachment: TdxPDFFileAttachment; var AHandled: Boolean);
var
  // ADocumentEditorClass: TDocumentEditorClass;
  AMessage: string;
  AStream: TBytesStream;
  // AInfo: TEditorInfo;
begin
  AHandled := false;
  // AHandled := True;
  // AMessage := 'The file ' + QuotedStr(AAttachment.FileName) + ' may contain programs, macros, or viruses that could ' + 'potentially harm your computer. Do you want to open it?';
  // if Application.MessageBox(PChar(AMessage), PChar(SecurityWarningCaption), MB_YESNO + MB_ICONWARNING) = ID_YES then
  // begin
  // AHandled := DocumentEditorFactory.TryGetEditor(TPath.GetExtension(AAttachment.FileName), ADocumentEditorClass);
  // if AHandled then
  // begin
  // AStream := TBytesStream.Create(AAttachment.Data);
  // try
  // AInfo.FileName := AAttachment.FileName;
  // AInfo.Stream := AStream;
  // AInfo.WindowState := wsMaximized;
  // ADocumentEditorClass.CreateEx(Self, AInfo);
  // finally
  // AStream.Free;
  // end;
  // end;
  // end;
end;

procedure TzViewerPdfForm.dxPDFViewerCustomDrawPreRenderPage(Sender: TObject; ACanvas: TcxCanvas; const APageInfo: TdxPDFPreRenderPageInfo; var ADone: Boolean);
begin
  DrawPreRenderPage(ACanvas, APageInfo, 4, ADone);
end;

procedure TzViewerPdfForm.dxPDFViewerCustomDrawPreRenderPageThumbnail(Sender: TObject; ACanvas: TcxCanvas; const APageInfo: TdxPDFPreRenderPageInfo; var ADone: Boolean);
begin
  DrawPreRenderPage(ACanvas, APageInfo, 1, ADone);
end;

procedure TzViewerPdfForm.dxPDFViewerDocumentLoaded(ASender: TdxPDFDocument; const AInfo: TdxPDFDocumentLoadInfo);
begin
  dxPDFViewer.BeginUpdate;
  try
    dxPDFViewer.OptionsZoom.ZoomFactor := 100;
    dxPDFViewer.ClearViewStateHistory;
    dxPDFViewer.Document.OnSaveProgress := OnDocumentSaveProgressHandler;
  finally
    dxPDFViewer.EndUpdate;
  end;
  UpdateControls;
end;

procedure TzViewerPdfForm.dxPDFViewerDocumentUnloaded(Sender: TObject);
begin
  UpdateControls;
end;

procedure TzViewerPdfForm.dxPDFViewerHideFindPanel(Sender: TObject);
begin
  dxTextSearchStatusBar.Visible := false;
end;

procedure TzViewerPdfForm.dxPDFViewerHyperlinkClick(Sender: TdxPDFCustomViewer; const AURI: string; var AHandled: Boolean);
begin

  if ConfirmYesNo('Si desidera aprire il link selezionato?', mtWarning) then
    dxShellExecute(AURI, SW_SHOWMAXIMIZED);

  AHandled := True;
end;

procedure TzViewerPdfForm.dxPDFViewerSearchProgress(Sender: TdxPDFDocument; APageIndex, APercent: Integer);
begin
  cxBarEditItem4.EditValue := APercent;
  Application.ProcessMessages;
  if FAbortTextSearch then
  begin
    FAbortTextSearch := false;
    bbAbortTextSearch.Enabled := false;
    Abort;
  end
  else
    bbAbortTextSearch.Enabled := APercent < 100;
end;

procedure TzViewerPdfForm.dxPDFViewerSelectedPageChanged(Sender: TObject; APageIndex: Integer);
begin
  BeginUpdate;
  try
    bseActivePage.EditValue := dxPDFViewer.CurrentPageIndex + 1;
    sseActivePage.EditValue := Min(Max(bseActivePage.EditValue, 1), dxPDFViewer.PageCount);
    sbPageCount.Caption := ' di ' + IntToStr(dxPDFViewer.PageCount);
  finally
    CancelUpdate;
  end;
end;

procedure TzViewerPdfForm.dxPDFViewerShowFindPanel(Sender: TObject);
begin
  dxTextSearchStatusBar.Visible := True;
end;

procedure TzViewerPdfForm.dxPDFViewerZoomFactorChanged(Sender: TObject);
begin
  bteActualZoom.EditValue := dxPDFViewer.OptionsZoom.ZoomFactor;
  tbZoom.Position := dxPDFViewer.OptionsZoom.ZoomFactor;
end;

procedure TzViewerPdfForm.dxPDFViewerCloseDocumentExecute(Sender: TObject);
var
  AMessage: string;
begin
  if dxPDFViewer.Document.Modified then
  begin
    AMessage := Format('Il documento %s e'' stato modificato. Salvare le modifiche prima di chiuderlo?', [TPath.GetFileNameWithoutExtension(dxPDFViewer.Document.Information.FileName)]);
    // prima: Application.MessageBox con MB_YESNOCANCEL e ramo ID_OK, che con quei
    // pulsanti non viene mai restituito (Si' rende ID_YES): il salvataggio non partiva
    case ConfirmYesNoCancel(AMessage, mtInformation) of
      mrYes:
        acSave.Execute;
      mrNo:
        dxPDFViewer.Clear;
    else
      Exit;
    end;
  end
  else
    dxPDFViewer.Clear;
end;

procedure TzViewerPdfForm.dxPDFViewerShowPrintFormExecute(Sender: TObject);
begin
  dxComponentPrinter.Preview;
end;

procedure TzViewerPdfForm.UpdateControls;
begin
  if dxPDFViewer.IsDocumentLoaded and (dxPDFViewer.Document.Information.FileName <> '') then
    Caption := TPath.GetFullPath(dxPDFViewer.Document.Information.FileName)
  else
    Caption := 'Pdf';

  lbExportToTIFF.Enabled := dxPDFViewer.IsDocumentLoaded;
  lbExportToPNG.Enabled := dxPDFViewer.IsDocumentLoaded;
  lbtnSinglePageMode.Enabled := dxPDFViewer.IsDocumentLoaded;
  lbtnExportGroup.Enabled := dxPDFViewer.IsDocumentLoaded;
  lbtnZoomGroup.Enabled := dxPDFViewer.IsDocumentLoaded;
  lbtnRotateView.Enabled := dxPDFViewer.IsDocumentLoaded;
  lbtnNavigation.Enabled := dxPDFViewer.IsDocumentLoaded;

  dxRibbonStatusBar.Visible := dxPDFViewer.IsDocumentLoaded;
  UpdateActivePageEditor(bseActivePage);
  UpdateActivePageEditor(sseActivePage);
  sbPageCount.Caption := ' di ' + IntToStr(dxPDFViewer.PageCount);
end;

procedure TzViewerPdfForm.OnDocumentSaveProgressHandler(Sender: TdxPDFDocument; Percent: Integer);
begin
  ProgressBox.Progress := Percent;
end;

procedure TzViewerPdfForm.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited AlignControls(AControl, Rect);
end;

procedure TzViewerPdfForm.UpdateActivePageEditor(ASpinEdit: TcxBarEditItem);
begin
  ASpinEdit.Enabled := dxPDFViewer.IsDocumentLoaded;
  (ASpinEdit.Properties as TcxSpinEditProperties).MaxValue := dxPDFViewer.PageCount;
  (ASpinEdit.Properties as TcxSpinEditProperties).MinValue := 1;
  ASpinEdit.EditValue := Max(dxPDFViewer.CurrentPageIndex, 1);
end;

procedure TzViewerPdfForm.acAllowEditExecute(Sender: TObject);
begin
  dxPDFViewer.OptionsForm.AllowEdit := not dxPDFViewer.OptionsForm.AllowEdit;
end;

procedure TzViewerPdfForm.acAllowEditUpdate(Sender: TObject);
begin
  acAllowEdit.Checked := dxPDFViewer.IsDocumentLoaded and not dxPDFViewer.OptionsForm.AllowEdit;
end;

procedure TzViewerPdfForm.acFormDataExportExecute(Sender: TObject);
var
  AFileName: string;
begin
  if ShowSaveAsDialog(GetFormDataDialogFilter, 'fdf', AFileName) then
    dxPDFViewer.Document.Form.SaveDataToFile(AFileName);
end;

procedure TzViewerPdfForm.acFormDataExportUpdate(Sender: TObject);
begin
  acFormDataExport.Enabled := AllowFormDataOperation;
end;

procedure TzViewerPdfForm.acFormDataImportExecute(Sender: TObject);
begin
  if ofdOpenFormDataDialog.Execute(Handle) then
    dxPDFViewer.Document.Form.LoadDataFromFile(ofdOpenFormDataDialog.FileName);
end;

procedure TzViewerPdfForm.acFormDataImportUpdate(Sender: TObject);
begin
  acFormDataImport.Enabled := AllowFormDataOperation;
end;

procedure TzViewerPdfForm.acFormDataResetExecute(Sender: TObject);
begin
  dxPDFViewer.Document.Form.Reset;
end;

procedure TzViewerPdfForm.acFormDataResetUpdate(Sender: TObject);
begin
  acFormDataReset.Enabled := AllowFormDataOperation;
end;

procedure TzViewerPdfForm.acSaveAsExecute(Sender: TObject);
var
  AFileName: string;
begin
  SaveDialog.InitialDir := TFolders.UserDocumentsFolder;

  if SaveDialog.Execute(Handle) then

    dxPDFViewer.Document.SaveToFile(SaveDialog.FileName);

  // if TfrmSaveDialogForm.Execute(dxPDFViewer.Document) and SaveDialog.Execute(Handle) then
  // begin
  // dxPDFViewer.Document.Information.Producer := ApplicationCaption;
  // ExecuteLongOperation(
  // procedure
  // begin
  // AFileName := SaveDialog1.FileName;
  // if TPath.GetExtension(AFileName) = '' then
  // AFileName := AFileName + '.pdf';
  // dxPDFViewer.Document.SaveToFile(AFileName, false);
  // end, 'Saving...', 'Please wait while the document is saved.');
  // end;
end;

procedure TzViewerPdfForm.acSaveAsUpdate(Sender: TObject);
begin
  acSaveAs.Enabled := dxPDFViewer.IsDocumentLoaded;
end;

procedure TzViewerPdfForm.acSaveExecute(Sender: TObject);
begin
  ExecuteLongOperation(
    procedure
    begin
      dxPDFViewer.Document.SaveToFile(dxPDFViewer.Document.Information.FileName, false, True);
    end, '', '');
end;

procedure TzViewerPdfForm.acSaveUpdate(Sender: TObject);
begin
  acSave.Enabled := dxPDFViewer.Document.Modified and dxPDFViewer.IsDocumentLoaded;
end;

procedure TzViewerPdfForm.acSinglePageContinuousExecute(Sender: TObject);
const
  LayoutMap: array [Boolean] of TdxPDFViewerPageLayout = (plDefault, plSinglePageContinuous);
begin
  dxPDFViewer.OptionsView.PageLayout := LayoutMap[acSinglePageContinuous.Checked];
end;

procedure TzViewerPdfForm.AfterExport;
begin
  dxPDFViewer.Enabled := True;
  ProgressBox.Close;
end;

procedure TzViewerPdfForm.bbAbortTextSearchClick(Sender: TObject);
begin
  FAbortTextSearch := True;
  bbAbortTextSearch.Enabled := false;
end;

procedure TzViewerPdfForm.BeforeExport;
begin
  dxPDFViewer.Enabled := false;
  ProgressBox.Show(100, 'Esportazione', 'Esportazione in corso', 'Attendere...');
end;

procedure TzViewerPdfForm.DrawPreRenderPage(ACanvas: TcxCanvas; const APageInfo: TdxPDFPreRenderPageInfo; AFontSizeFactor: Integer; var ADone: Boolean);
var
  ARect: TRect;
  AThumbnailSize: TSize;
begin
  ADone := APageInfo.Thumbnail = nil;
  if ADone then
  begin
    ACanvas.Brush.Color := clWhite;
    ACanvas.FillRect(APageInfo.Bounds);

    AThumbnailSize := cxSize(APageInfo.Bounds.Width div 3, APageInfo.Bounds.Height div 3);
    ARect := cxRect(APageInfo.Bounds.CenterPoint, APageInfo.Bounds.CenterPoint);
    ARect.Inflate(AThumbnailSize.cx, AThumbnailSize.cy);
    ACanvas.StretchDraw(cxGetImageRect(ARect, FPreRenderPageImage.Size, ifmProportionalStretch), FPreRenderPageImage);
  end;
end;

constructor TzViewerPdfForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FFileName := '';
  DisableAero := True;

  // senza la clessidra globale di ExpressPrinting, come gli altri visualizzatori:
  // vedi Tdx.InitPrinter
  dx.InitPrinter(dxComponentPrinter);

  acSinglePageContinuous.Checked := True;
  acSinglePageContinuousExecute(Self);
  dxTextSearchStatusBar.Visible := false;

  ofdOpenFormDataDialog.Filter := GetFormDataDialogFilter;

  FPreRenderPageImage := TdxSmartImage.Create;
  // FPreRenderPageImage.LoadFromFile('Data\PreRenderPageImage.svg');

  dxPDFViewer.BeginUpdate;
  try
    dxPDFViewer.OptionsForm.AllowEdit := True;
    dxPDFViewer.OptionsZoom.ZoomStep := 8;
    dxPDFViewer.OptionsLockedStateImage.ShowText := True;
    dxPDFViewer.OptionsLockedStateImage.Effect := lsieLight;
    dxPDFViewer.OptionsFindPanel.HighlightSearchResults := True;
  finally
    dxPDFViewer.EndUpdate;
  end;

  dxPDFViewerZoomFactorChanged(nil);

  dxRibbonTabHome.Active := True;
  UpdateControls;

  WindowState := wsMaximized;
end;

destructor TzViewerPdfForm.Destroy;
begin
  inherited;
  FreeAndNil(FPreRenderPageImage);
end;

procedure TzViewerPdfForm.actShellExecuteExecute(Sender: TObject);
begin

  if not FileName.IsEmpty then
    if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
      ShellExecute(0, PChar('open'), PChar(FileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerPdfForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerPdfForm.dxPDFViewerAttachmentSave(Sender: TdxPDFCustomViewer; AAttachment: TdxPDFFileAttachment; var AHandled: Boolean);
var
  ASaveDialog: TdxSaveFileDialog;
  AFileName: string;
begin
  AHandled := True;
  ASaveDialog := TdxSaveFileDialog.Create(Application);
  try
    ASaveDialog.Filter := '*.*';
    ASaveDialog.InitialDir := TFolders.UserDocumentsFolder;
    ASaveDialog.FileName := ExtractFileName(AAttachment.FileName);
    if ASaveDialog.Execute(Handle) then
    begin
      AFileName := TPath.GetDirectoryName(ASaveDialog.FileName) + '\' + TPath.GetFileName(ASaveDialog.FileName);
      TdxPDFUtils.SaveToFile(AFileName, AAttachment.Data);
    end;
  finally
    ASaveDialog.Free;
  end;
end;

procedure TzViewerPdfForm.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

procedure TzViewerPdfForm.LoadFile(const FileName: string);
begin

  if FileExists(FileName) then
  begin
    dxPDFViewer.LoadFromFile(FileName);
    FFileName := FileName;
  end;
end;

procedure TzViewerPdfForm.ShowFile(const FileName: string);
begin
  LoadFile(FileName);

  ShowModal;
end;

function TzViewerPdfForm.ShowModal: Integer;
begin
  dxRibbon.ActiveTab := dxRibbonTabHome;
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  Result := inherited ShowModal;
end;

end.
