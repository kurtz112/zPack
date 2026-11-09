unit zOffice.Mail.Editor;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.StdActns,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.ComCtrls,
  IdBaseComponent,
  IdMessage,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxStyles,
  cxFilter,
  cxEdit,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  cxContainer,
  cxTextEdit,
  cxClasses,
  cxMemo,
  cxImageList,
  cxButtons,
  cxListView,
  cxDrawTextUtils,
  cxTrackBar,
  dxScrollbarAnnotations,
  dxLayoutcxEditAdapters,
  dxLayoutContainer,
  dxLayoutControl,
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
  dxFileActions,
  dxStatusBar,
  dxRibbonSkins,
  dxRibbonCustomizationForm,
  dxRibbonStatusBar,
  dxRichEdit.Actions,
  dxActions,
  dxPrinting,
  dxBar,
  dxRibbon,
  dxRibbonForm,
  dxSkinsCore,
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
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxPSdxSpreadSheetLnk,
  dxPSdxPDFViewerLnk,
  dxZoomTrackBar,
  dxBarExtItems,
  dxPScxEditorLnks,
  dxLayoutControlAdapters,
  zOffice.Types,
  zOffice.Mail.Utils,
  zOffice.MultiViewer,
  dxShellDialogs,
  dxSpellCheckerCore,
  dxSpellChecker,
  dxTokenEdit,
  zProgressBox,
  dxRichEdit.Html,
  cxFontNameComboBox,
  cxDropDownEdit,
  dxRibbonColorGallery,
  cxBarEditItem,
  ExplorerDrop,
  dxPScxSchedulerLnk,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl, dxUIAClasses;

type
  TzViewerMailEditorForm = class(TdxRibbonForm)
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    edFrom: TcxTextEdit;
    edOggetto: TcxTextEdit;
    dxLayoutItemFrom: TdxLayoutItem;
    dxLayoutItemOggetto: TdxLayoutItem;
    dxLayoutGroupIntestazione: TdxLayoutGroup;
    dxLayoutGroupMain: TdxLayoutGroup;
    dxRichEditControl: TdxRichEditControl;
    dxLayoutItemBody: TdxLayoutItem;
    dxLayoutSplitterItemAllegati: TdxLayoutSplitterItem;
    dxLayoutGroupFrom: TdxLayoutGroup;
    listAllegati: TcxListView;
    dxLayoutItemAllegati: TdxLayoutItem;
    imageAllegati: TcxImageList;
    dxRibbon: TdxRibbon;
    dxBarManager: TdxBarManager;
    ActionList: TActionList;
    dxRibbonTabFile: TdxRibbonTab;
    dxBarCommon: TdxBar;
    dxRichEditControlSaveDocumentAs: TdxRichEditControlSaveDocumentAs;
    dxBarLargeButtonSaveAs: TdxBarLargeButton;
    dxRichEditControlPasteSelection: TdxRichEditControlPasteSelection;
    dxBarClipboard: TdxBar;
    dxBarLargeButtonPaste: TdxBarLargeButton;
    dxRichEditControlCutSelection: TdxRichEditControlCutSelection;
    dxBarButtonCut: TdxBarButton;
    dxRichEditControlCopySelection: TdxRichEditControlCopySelection;
    dxBarButtonCopy: TdxBarButton;
    dxRichEditControlSelectAll: TdxRichEditControlSelectAll;
    dxBarButtonSelectAll: TdxBarButton;
    dxBarLargeButtonPage: TdxBarLargeButton;
    dxRichEditControlZoomOut: TdxRichEditControlZoomOut;
    dxBarZoom: TdxBar;
    dxBarLargeButtonZoomOut: TdxBarLargeButton;
    dxRichEditControlZoomIn: TdxRichEditControlZoomIn;
    dxBarLargeButtonZoomIn: TdxBarLargeButton;
    dxRichEditControlShowPrintForm: TdxRichEditControlShowPrintForm;
    dxBarPrint: TdxBar;
    dxBarLargeButtonPrint: TdxBarLargeButton;
    dxRichEditControlShowPrintPreviewForm: TdxRichEditControlShowPrintPreviewForm;
    dxBarLargeButtonPrintPreview: TdxBarLargeButton;
    dxRichEditControlShowPageSetupForm: TdxRichEditControlShowPageSetupForm;
    dxBarLargeButtonPageSetup: TdxBarLargeButton;
    Printer: TdxComponentPrinter;
    RichEditPrinterLink: TdxRichEditControlReportLink;
    Chiudi: TAction;
    dxBarManagerBar1: TdxBar;
    dxBarLargeButton1: TdxBarLargeButton;
    dxLayoutGroupAllegati: TdxLayoutGroup;
    dxStatusBarToolbar1: TdxBar;
    dxStatusBarToolbar2: TdxBar;
    dxStatusBarToolbar3: TdxBar;
    tbZoom: TdxZoomTrackBar;
    StatusBar: TdxRibbonStatusBar;
    bsZoom: TdxBarStatic;
    bccZoom: TdxBarControlContainerItem;
    dxBarButton1: TdxBarButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    actShellExecute: TAction;
    actExportPDF: TAction;
    dxSaveFileDialog: TdxSaveFileDialog;
    edA: TdxTokenEdit;
    dxLayoutItemA: TdxLayoutItem;
    edCC: TdxTokenEdit;
    dxLayoutItemCC: TdxLayoutItem;
    edCCN: TdxTokenEdit;
    dxLayoutItemCCN: TdxLayoutItem;
    Invia: TAction;
    dxBarLargeButton4: TdxBarLargeButton;
    imageToken: TcxImageList;
    ProgressBox: TProgressBox;
    dxRibbonTabHome: TdxRibbonTab;
    dxBarCustom1: TdxBar;
    dxRichEditControlChangeFontName: TdxRichEditControlChangeFontName;
    dxBarFont: TdxBar;
    cxBarEditItemFont: TcxBarEditItem;
    dxRichEditControlChangeFontSize: TdxRichEditControlChangeFontSize;
    cxBarEditItemFontSize: TcxBarEditItem;
    dxRichEditControlIncreaseFontSize: TdxRichEditControlIncreaseFontSize;
    dxBarButtonGrowFont: TdxBarButton;
    dxRichEditControlDecreaseFontSize: TdxRichEditControlDecreaseFontSize;
    dxBarButtonShrinkFont: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxRichEditControlTextUpperCase: TdxRichEditControlTextUpperCase;
    dxBarLargeButtonUPPERCASE: TdxBarLargeButton;
    dxRichEditControlTextLowerCase: TdxRichEditControlTextLowerCase;
    dxBarLargeButtonlowercase: TdxBarLargeButton;
    dxRichEditControlToggleTextCase: TdxRichEditControlToggleTextCase;
    dxBarLargeButtontOGGLEcASE: TdxBarLargeButton;
    dxRichEditControlToggleFontBold: TdxRichEditControlToggleFontBold;
    dxBarButtonBold: TdxBarButton;
    dxRichEditControlToggleFontItalic: TdxRichEditControlToggleFontItalic;
    dxBarButtonItalic: TdxBarButton;
    dxRichEditControlToggleFontUnderline: TdxRichEditControlToggleFontUnderline;
    dxBarButtonUnderline: TdxBarButton;
    dxRichEditControlToggleFontDoubleUnderline: TdxRichEditControlToggleFontDoubleUnderline;
    dxBarButtonDoubleUnderline: TdxBarButton;
    dxRichEditControlToggleFontStrikeout: TdxRichEditControlToggleFontStrikeout;
    dxBarButtonStrikethrough: TdxBarButton;
    dxRichEditControlToggleFontDoubleStrikeout: TdxRichEditControlToggleFontDoubleStrikeout;
    dxBarButtonDoubleStrikethrough: TdxBarButton;
    dxRichEditControlToggleFontSubscript: TdxRichEditControlToggleFontSubscript;
    dxBarButtonSubscript: TdxBarButton;
    dxRichEditControlToggleFontSuperscript: TdxRichEditControlToggleFontSuperscript;
    dxBarButtonSuperscript: TdxBarButton;
    dxRichEditControlTextHighlight: TdxRichEditControlTextHighlight;
    dxRibbonColorGalleryItemTextHighlightColor: TdxRibbonColorGalleryItem;
    dxRichEditControlChangeFontColor: TdxRichEditControlChangeFontColor;
    dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem;
    dxRichEditControlToggleBulletedList: TdxRichEditControlToggleBulletedList;
    dxBarParagraph: TdxBar;
    dxBarButtonBullets: TdxBarButton;
    dxRichEditControlToggleSimpleNumberingList: TdxRichEditControlToggleSimpleNumberingList;
    dxBarButtonNumbering: TdxBarButton;
    dxRichEditControlToggleMultiLevelList: TdxRichEditControlToggleMultiLevelList;
    dxBarButtonMultilevellist: TdxBarButton;
    dxRichEditControlDecrementIndent: TdxRichEditControlDecrementIndent;
    dxBarButtonDecreaseIndent: TdxBarButton;
    dxRichEditControlIncrementIndent: TdxRichEditControlIncrementIndent;
    dxBarButtonIncreaseIndent: TdxBarButton;
    dxRichEditControlToggleShowWhitespace: TdxRichEditControlToggleShowWhitespace;
    dxBarButtonShowHide: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentLeft: TdxRichEditControlToggleParagraphAlignmentLeft;
    dxBarButtonAlignTextLeft: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentCenter: TdxRichEditControlToggleParagraphAlignmentCenter;
    dxBarButtonCenter: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentRight: TdxRichEditControlToggleParagraphAlignmentRight;
    dxBarButtonAlignTextRight: TdxBarButton;
    dxRichEditControlToggleParagraphAlignmentJustify: TdxRichEditControlToggleParagraphAlignmentJustify;
    dxBarButtonJustify: TdxBarButton;
    dxBarSubItem2: TdxBarSubItem;
    dxRichEditControlSetSingleParagraphSpacing: TdxRichEditControlSetSingleParagraphSpacing;
    dxBarLargeButton10: TdxBarLargeButton;
    dxRichEditControlSetSesquialteralParagraphSpacing: TdxRichEditControlSetSesquialteralParagraphSpacing;
    dxBarLargeButton15: TdxBarLargeButton;
    dxRichEditControlSetDoubleParagraphSpacing: TdxRichEditControlSetDoubleParagraphSpacing;
    dxBarLargeButton20: TdxBarLargeButton;
    dxRichEditControlShowParagraphForm: TdxRichEditControlShowParagraphForm;
    dxBarLargeButtonParagraph: TdxBarLargeButton;
    dxRichEditControlSearchFind: TdxRichEditControlSearchFind;
    dxBarEditing: TdxBar;
    dxBarButtonFind: TdxBarButton;
    dxRichEditControlSearchReplace: TdxRichEditControlSearchReplace;
    dxBarButtonReplace: TdxBarButton;
    dxRichEditControlUndo: TdxRichEditControlUndo;
    dxBarLargeButtonUndo: TdxBarLargeButton;
    dxRichEditControlRedo: TdxRichEditControlRedo;
    dxBarLargeButtonRedo: TdxBarLargeButton;
    dxRichEditControlInsertPicture: TdxRichEditControlInsertPicture;
    dxRibbonTabInsert: TdxRibbonTab;
    dxBarIllustrations: TdxBar;
    dxBarLargeButtonInlinePicture: TdxBarLargeButton;
    dxRichEditControlInsertFloatingObjectPicture: TdxRichEditControlInsertFloatingObjectPicture;
    dxBarLargeButtonPicture: TdxBarLargeButton;
    dxRichEditControlInsertTextBox: TdxRichEditControlInsertTextBox;
    dxBarText: TdxBar;
    dxBarLargeButtonTextBox: TdxBarLargeButton;
    dxRichEditControlShowSymbolForm: TdxRichEditControlShowSymbolForm;
    dxBarSymbols: TdxBar;
    dxBarLargeButtonSymbol: TdxBarLargeButton;
    actAllegati: TAction;
    actCC: TAction;
    actCCN: TAction;
    dxBarManagerBar2: TdxBar;
    dxBarLargeButton5: TdxBarLargeButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    ExplorerDrop: TExplorerDrop;
    actAggiungiAllegato: TdxFileOpen;
    actEliminaAllegato: TAction;
    popAllegati: TdxBarPopupMenu;
    actScaricaAllegato: TdxFileSaveAs;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;

    procedure actAggiungiAllegatoAccept(Sender: TObject);
    procedure actAllegatiExecute(Sender: TObject);
    procedure actCCExecute(Sender: TObject);
    procedure actCCNExecute(Sender: TObject);
    procedure actEliminaAllegatoExecute(Sender: TObject);
    procedure actExportPDFExecute(Sender: TObject);
    procedure actScaricaAllegatoAccept(Sender: TObject);
    procedure actShellExecuteExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure dxRichEditControlActiveViewChanged(Sender: TObject);
    procedure dxRichEditControlZoomChanged(Sender: TObject);
    procedure ExplorerDropDropped(Sender: TObject; Files: TStrings; FileCount, x, y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure InviaExecute(Sender: TObject);
    procedure listAllegatiDblClick(Sender: TObject);
    procedure tbZoomPropertiesChange(Sender: TObject);
    procedure TokenAdd(Sender: TObject; const ATokenText: string; AToken: TdxTokenEditToken; var AAllow: Boolean);
  private
    FFileName: string;
    FGetIndirizziProc: TProc<TStringList>;
    FSMTPServerParams: TSMTPServerParams;
    FPdfFontEmbedding: TzPdfFontEmbedding;
    MailReader: TzOfficeMailReader;
  private
    procedure AddAllegato(const FileName: string);
    procedure UpdateZoom;
  private
    procedure AssignBody(Mail: TMail);
    procedure FillIndirizzi;
  private
    procedure BeforeShow(SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
    procedure ShowForm;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function ShowModal: Integer; override;

    procedure WriteMail(Mail: TMail; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>); overload;
    procedure WriteMail(const FileName: string; ForwardType: TMailForwardType; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>); overload;

    procedure ExportPDF(const FileNamePdf: String);

    property FileName: string read FFileName;
    property PdfFontEmbedding: TzPdfFontEmbedding read FPdfFontEmbedding;

    property SMTPServerParams: TSMTPServerParams read FSMTPServerParams;
    property GetIndirizziProc: TProc<TStringList> read FGetIndirizziProc write FGetIndirizziProc;
  end;

procedure WriteFileMail(Mail: TMail; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>); overload;
procedure WriteFileMail(Const FileName: string; ForwardType: TMailForwardType; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>); overload;

implementation

uses
  Winapi.ShellAPI,
  System.IOUtils,
  System.DateUtils,
  IdText,
  IdAttachmentFile,
  dxRichEdit.Utils.UriStreamService,
  zdx,
  zBaseLib,
  zOffice.Word.UriStreamProvider,
  zMsg,
  zOffice,
  zz.Folders;

{$R *.dfm}

procedure WriteFileMail(Mail: TMail; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
var
  zViewerMailEditorForm: TzViewerMailEditorForm;
begin
  Application.CreateForm(TzViewerMailEditorForm, zViewerMailEditorForm);
  try
    zViewerMailEditorForm.WriteMail(Mail, SMTPServerParams, GetIndirizziProc);
  finally
    FreeAndNil(zViewerMailEditorForm);
  end;
end;

procedure WriteFileMail(Const FileName: string; ForwardType: TMailForwardType; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
var
  zViewerMailEditorForm: TzViewerMailEditorForm;
begin
  Application.CreateForm(TzViewerMailEditorForm, zViewerMailEditorForm);
  try
    zViewerMailEditorForm.WriteMail(FileName, ForwardType, SMTPServerParams, GetIndirizziProc);
  finally
    FreeAndNil(zViewerMailEditorForm);
  end;
end;

constructor TzViewerMailEditorForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  si.Enabled := True;

  FFileName := '';
  FGetIndirizziProc := nil;
  SMTPServerParams.Init;

  FPdfFontEmbedding := zfeSubset;
  edFrom.Clear;
  edA.Clear;
  edCC.Clear;
  edCCN.Clear;
  edOggetto.Clear;

  listAllegati.Clear;

  dxLayoutGroupAllegati.Visible := False;
  dxLayoutSplitterItemAllegati.Visible := False;
  dxLayoutItemCC.Visible := False;
  dxLayoutItemCCN.Visible := False;

  MailReader := TzOfficeMailReader.Create;

  dx.InitLayoutControl(dxLayoutControl);
  dx.InitPrinter(Printer);
end;

destructor TzViewerMailEditorForm.Destroy;
begin
  inherited;
  FreeAndNil(MailReader);
end;

procedure TzViewerMailEditorForm.actExportPDFExecute(Sender: TObject);
begin
  ExportPDF('');
end;

procedure TzViewerMailEditorForm.actShellExecuteExecute(Sender: TObject);
begin

  if not FileName.IsEmpty then
    if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
    begin
      dxRichEditControl.SaveDocument;
      dxRichEditControl.DocumentModelModified := False;
      ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
    end;
end;

procedure TzViewerMailEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MailReader.ClearFolder;
end;

procedure TzViewerMailEditorForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerMailEditorForm.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

procedure TzViewerMailEditorForm.UpdateZoom;
begin
  if dxRichEditControl.ActiveView.ZoomFactor > 5 then
    dxRichEditControl.ActiveView.ZoomFactor := 5;
  tbZoom.Position := Round(dxRichEditControl.ActiveView.ZoomFactor * 100);
end;

procedure TzViewerMailEditorForm.tbZoomPropertiesChange(Sender: TObject);
begin
  bsZoom.Caption := Format('%3d %%', [tbZoom.Position]);
  dxRichEditControl.ActiveView.ZoomFactor := tbZoom.Position / 100;
end;

procedure TzViewerMailEditorForm.dxRichEditControlActiveViewChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerMailEditorForm.dxRichEditControlZoomChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerMailEditorForm.ExportPDF(const FileNamePdf: String);
var
  Options: TdxPSPDFReportExportOptions;
  PdfFileName: string;
begin
  dxSaveFileDialog.FilterIndex := Ord(PdfFontEmbedding) + 1; //

  // nome senza percorso: con un percorso Windows ignorerebbe InitialDir e proporrebbe
  // la cartella del messaggio, spesso quella dei temporanei
  dxSaveFileDialog.InitialDir := TFolders.UserDocumentsFolder;
  if FileNamePdf.IsEmpty then
    dxSaveFileDialog.FileName := ExtractFileName(ChangeFileExt(FileName, '.pdf'))
  else
    dxSaveFileDialog.FileName := FileNamePdf;

  if not dxSaveFileDialog.Execute(Self.Handle) then
    exit;

  PdfFileName := dxSaveFileDialog.FileName;
  try
    ForceDirectories(ExtractFilePath(PdfFileName));
  except
  end;

  case dxSaveFileDialog.FilterIndex of
    1:
      FPdfFontEmbedding := zfeNone;
    2:
      FPdfFontEmbedding := zfeFull;
    3:
      FPdfFontEmbedding := zfeSubset;
    4:
      FPdfFontEmbedding := zfeSubset;
  else
    FPdfFontEmbedding := zfeSubset;
  end;

  Options := TdxPSPDFReportExportOptions.Create;
  try
    Options.Author := '';
    Options.Creator := '';
    Options.Keywords := '';
    Options.Subject := '';
    Options.Title := '';
    //
    Options.CompressStreams := True;
    Options.DefaultFileName := PdfFileName;
    Options.OpenDocumentAfterExport := False; //
    // Options.SecurityOptions
    // Options.SignatureOptions

    Options.EmbedFonts := PdfFontEmbedding in [zfeFull, zfeSubset];
    Options.UseCIDFonts := PdfFontEmbedding = zfeSubset;
    Options.UseJPEGCompression := True;

    StartWait('Attendere...', True);
    try
      Printer.ExportToPDF(PdfFileName, False, Options);
    finally
      StopWait;
    end;
  finally
    FreeAndNil(Options);
  end;

  if ConfirmYesNo('Si desidera aprire il file ' + PdfFileName + '?', mtWarning) then
    ShellExecute(0, PCHAR('open'), PCHAR(PdfFileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerMailEditorForm.BeforeShow(SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
begin
  FSMTPServerParams.Assign(SMTPServerParams);
  FGetIndirizziProc := GetIndirizziProc;
  FillIndirizzi;
  edFrom.Text := SMTPServerParams.From;
end;

procedure TzViewerMailEditorForm.ShowForm;
begin

  if edCC.Text <> '' then
    actCC.Execute;

  if edCCN.Text <> '' then
    actCCN.Execute;

  if listAllegati.Items.Count > 0 then
    actAllegati.Execute;

  ActiveControl := edA;

  ShowModal;
end;

procedure TzViewerMailEditorForm.WriteMail(Mail: TMail; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
var
  Allegato: string;
  Stream: TStringStream;
begin
  BeforeShow(SMTPServerParams, GetIndirizziProc);

  edA.Text := Mail.A;
  edCC.Text := Mail.CC;
  edCCN.Text := Mail.CCN;
  edOggetto.Text := Mail.Oggetto;

  dxRichEditControl.Document.Text := Mail.CorpoTxt;

  if not Mail.CorpoHtml.IsEmpty then
  begin
    Stream := TStringStream.Create(Mail.CorpoHtml);
    try
      dxRichEditControl.LoadDocument(Stream, TdxRichEditDocumentFormat.Html);
    finally
      Stream.Free;
    end;
  end;

  for Allegato in Mail.Allegati.Split([';']) do
    AddAllegato(Allegato);

  ShowForm;
end;

procedure TzViewerMailEditorForm.WriteMail(const FileName: string; ForwardType: TMailForwardType; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
var
  MailReader: TzOfficeMailReader;
  AttachmentFile: TIdAttachmentFile;
  Stream: TStringStream;
begin
  BeforeShow(SMTPServerParams, GetIndirizziProc);

  MailReader := TzOfficeMailReader.Create;
  try
    MailReader.LoadFileEML(FileName, dxRichEditControl);

    edA.Text := MailReader.MessageFrom;
    edOggetto.EditValue := MailReader.MessageSubject;

    case ForwardType of
      mfNone:
        ;
      mfReply:
        edOggetto.EditValue := 'Re: ' + edOggetto.EditValue;
      mfForward:
        edOggetto.EditValue := 'Fwd: ' + edOggetto.EditValue;
    end;

    if not MailReader.MessageBodyIsHTML then
      dxRichEditControl.Document.Text := MailReader.MessageBody
    else
    begin
      Stream := TStringStream.Create(MailReader.MessageBody);
      try
        dxRichEditControl.LoadDocument(Stream, TdxRichEditDocumentFormat.Html);
      finally
        Stream.Free;
      end;
    end;

    for AttachmentFile in MailReader.Attachments do
      AddAllegato(AttachmentFile.FileName);
  finally
    FreeAndNil(MailReader);
  end;

  ShowForm;
end;

procedure TzViewerMailEditorForm.FillIndirizzi;
var
  i: Integer;
  item: TdxTokenEditToken;
  StringList: TStringList;
begin
  edA.Properties.Tokens.Clear;
  edCC.Properties.Tokens.Clear;
  edCCN.Properties.Tokens.Clear;

  if not assigned(FGetIndirizziProc) then
    exit;

  StringList := TStringList.Create;
  try
    GetIndirizziProc(StringList);

    edA.Properties.Tokens.BeginUpdate;
    try
      for i := 0 to StringList.Count - 1 do
      begin
        item := edA.Properties.Tokens.Add;
        item.Text := StringList.Names[i];
        item.DisplayText := StringList.ValueFromIndex[i];

        if item.DisplayText.IsEmpty then
          item.DisplayText := item.Text;

        item.ImageIndex := random(3);
      end;
    finally
      edA.Properties.Tokens.EndUpdate;
    end;
  finally
    FreeAndNil(StringList);
  end;

  edCC.Properties.Tokens.Assign(edA.Properties.Tokens);
  edCCN.Properties.Tokens.Assign(edA.Properties.Tokens);
end;

procedure TzViewerMailEditorForm.InviaExecute(Sender: TObject);
var
  Mail: TMail;
  i: Integer;
  image: IdxRichEditDocumentImage;
  StringList: TStringList;
  StringStream: TStringStream;
  zViewerMailWriter: TzOfficeMailWriter;
  item: TListItem;

  function IsEmpty(dxTokenEdit: TdxTokenEdit): Boolean;
  begin
    result := dxTokenEdit.Text = '';
  end;

begin
  Mail.Init;

  if IsEmpty(edA) and IsEmpty(edCC) and IsEmpty(edCCN) then
  begin
    ConfirmOk('Indirizzo non specificato.', mtWarning);
    exit;
  end;

  if edOggetto.Text = '' then
    if not ConfirmYesNo('Oggetto non specificato. ' + #13#10 + 'Si desidera inviare il messaggio?', mtWarning) then
      exit;

  if dxRichEditControl.Document.Text = '' then
    if not ConfirmYesNo('Corpo messaggio non specificato. ' + #13#10 + 'Si desidera inviare il messaggio?', mtWarning) then
      exit;

  /// ///////////////////////////////

  Mail.A := edA.Text;
  Mail.CC := edCC.Text;
  Mail.CCN := edCCN.Text;
  Mail.Oggetto := edOggetto.Text;

  StringStream := TStringStream.Create;
  try
    dxRichEditControl.Document.SaveDocument(StringStream, TdxRichEditDocumentFormat.Html);

    Mail.CorpoHtml := StringStream.DataString;

    // Tfile.WriteAllText('C:\Users\Luca\Desktop\mail.html', Mail.CorpoHtml);
    // CorpoHtml := dxRichEditControl.Document.RtfText;
  finally
    FreeAndNil(StringStream);
  end;

  Mail.CorpoTxt := dxRichEditControl.Document.Text;

  /// ///////////////////////////////////////////////////
  /// Allegati

  Mail.Allegati := '';

  for item in listAllegati.Items do
    Mail.Allegati := Mail.Allegati + item.Caption + ';';

  /// ///////////////////////////////////////////////////

  ProgressBox.CancelEnabled := False;
  ProgressBox.Show(4, 'Invio messaggio', 'Invio messaggio', 'Attendere...');
  try
    Application.ProcessMessages;
    zViewerMailWriter := TzOfficeMailWriter.Create(Self);
    try
      Application.ProcessMessages;
      zViewerMailWriter.SendMail(Mail, SMTPServerParams);
      Close;
    finally
      FreeAndNil(zViewerMailWriter);
    end;
  finally
    ProgressBox.Close;
  end;
end;

procedure TzViewerMailEditorForm.actAllegatiExecute(Sender: TObject);
begin
  dxLayoutGroupAllegati.Visible := actAllegati.Checked;
  dxLayoutSplitterItemAllegati.Visible := actAllegati.Checked;
end;

procedure TzViewerMailEditorForm.actCCExecute(Sender: TObject);
begin
  dxLayoutItemCC.Visible := actCC.Checked;
end;

procedure TzViewerMailEditorForm.actCCNExecute(Sender: TObject);
begin
  dxLayoutItemCCN.Visible := actCCN.Checked;
end;

procedure TzViewerMailEditorForm.listAllegatiDblClick(Sender: TObject);
begin

  if listAllegati.Selected <> nil then
    ViewFile(listAllegati.Selected.Caption);
end;

procedure TzViewerMailEditorForm.actAggiungiAllegatoAccept(Sender: TObject);
begin
  AddAllegato(actAggiungiAllegato.Dialog.FileName);
end;

procedure TzViewerMailEditorForm.actEliminaAllegatoExecute(Sender: TObject);
begin

  if listAllegati.Selected <> nil then
    if ConfirmYesNo('Si desidera eliminare l''allegato selezionato?', mtConfirmation) then
      listAllegati.DeleteSelected
end;

procedure TzViewerMailEditorForm.actScaricaAllegatoAccept(Sender: TObject);
begin

  if listAllegati.Selected <> nil then
    if not sameText(listAllegati.Selected.Caption, actScaricaAllegato.Dialog.FileName) then
      Tfile.Copy(listAllegati.Selected.Caption, actScaricaAllegato.Dialog.FileName);
end;

procedure TzViewerMailEditorForm.ExplorerDropDropped(Sender: TObject; Files: TStrings; FileCount, x, y: Integer);
var
  FileName: String;
begin
  for FileName in Files do
    AddAllegato(FileName);
end;

procedure TzViewerMailEditorForm.AddAllegato(const FileName: string);
var
  item: TListItem;
begin
  item := listAllegati.Items.Add;
  item.Caption := FileName;
  // item.Data := AttachmentFile;
  item.ImageIndex := TzFileType.FromFileName(FileName).ImageIndex;
end;

procedure TzViewerMailEditorForm.AssignBody(Mail: TMail);
var
  Stream: TStringStream;
begin
  dxRichEditControl.Document.Text := Mail.CorpoTxt;

  Stream := TStringStream.Create(Mail.CorpoHtml);
  try
    dxRichEditControl.LoadDocument(Stream, TdxRichEditDocumentFormat.Html);
  finally
    Stream.Free;
  end;
end;

function TzViewerMailEditorForm.ShowModal: Integer;
begin
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  result := inherited ShowModal;
end;

procedure TzViewerMailEditorForm.TokenAdd(Sender: TObject; const ATokenText: string; AToken: TdxTokenEditToken; var AAllow: Boolean);
begin
  AAllow := True;
end;

end.
