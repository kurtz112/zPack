unit zOffice.Mail.Form;

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
  dxTokenEdit,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl, dxPScxSchedulerLnk, dxUIAClasses;

type
  TzViewerMailForm = class(TdxRibbonForm)
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    edFrom: TcxTextEdit;
    edOggetto: TcxTextEdit;
    dxLayoutItemFrom: TdxLayoutItem;
    dxLayoutItemOggetto: TdxLayoutItem;
    dxLayoutGroupIntestazione: TdxLayoutGroup;
    dxLayoutGroupMain: TdxLayoutGroup;
    dxLayoutSplitterItemInspector: TdxLayoutSplitterItem;
    dxRichEditControl: TdxRichEditControl;
    dxLayoutItemBody: TdxLayoutItem;
    dxLayoutSplitterItem2: TdxLayoutSplitterItem;
    edData: TcxTextEdit;
    dxLayoutItemRicezione: TdxLayoutItem;
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
    Rispondi: TAction;
    dxBarLargeButton4: TdxBarLargeButton;
    Inoltra: TAction;
    dxBarLargeButton5: TdxBarLargeButton;
    edCC: TdxTokenEdit;
    edCCN: TdxTokenEdit;
    dxLayoutItemCC: TdxLayoutItem;
    dxLayoutItemCCN: TdxLayoutItem;
    edTO: TdxTokenEdit;
    dxLayoutItemTO: TdxLayoutItem;

    procedure actExportPDFExecute(Sender: TObject);
    procedure actShellExecuteExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure dxRichEditControlActiveViewChanged(Sender: TObject);
    procedure dxRichEditControlZoomChanged(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure InoltraExecute(Sender: TObject);
    procedure InoltraUpdate(Sender: TObject);
    procedure listAllegatiDblClick(Sender: TObject);
    procedure RispondiExecute(Sender: TObject);
    procedure RispondiUpdate(Sender: TObject);
    procedure tbZoomPropertiesChange(Sender: TObject);
  private
    FAllowedForwardingTypes: TMailAllowedForwardingTypes;
    FFileName: string;
    FGetIndirizziProc: TProc<TStringList>;
    FPdfFontEmbedding: TzPdfFontEmbedding;
    FSMTPServerParams: TSMTPServerParams;
    MailReader: TzOfficeMailReader;
  private
    procedure FillAttachmentsList;
    procedure AssignBody(const Body: string; const isHtml: boolean);
    procedure UpdateZoom;

    function ViewMail(const FileName: String; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>; AllowedForwardingTypes: TMailAllowedForwardingTypes;
      const ReadOnly: boolean = false): boolean;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function ShowModal: Integer; override;

    procedure ExportPDF(const FileNamePdf: String);

    property FileName: string read FFileName;
    property PdfFontEmbedding: TzPdfFontEmbedding read FPdfFontEmbedding;

    property AllowedForwardingTypes: TMailAllowedForwardingTypes read FAllowedForwardingTypes write FAllowedForwardingTypes;

    property SMTPServerParams: TSMTPServerParams read FSMTPServerParams;
    property GetIndirizziProc: TProc<TStringList> read FGetIndirizziProc write FGetIndirizziProc;
  end;

function ViewFileMail(const FileName: String; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>; AllowedForwardingTypes: TMailAllowedForwardingTypes = [afReply, afForward]
  ): boolean;

implementation

uses
  Winapi.ShellAPI,
  System.IOUtils,
  System.DateUtils,
  IdText,
  IdAttachmentFile,
  dxRichEdit.Html,
  dxRichEdit.Utils.UriStreamService,
  zOffice.Word.UriStreamProvider,
  zDX,
  zBaseLib,
  zMsg,
  zOffice,
  zz.Folders;

{$R *.dfm}

function ViewFileMail(const FileName: String; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>; AllowedForwardingTypes: TMailAllowedForwardingTypes = [afReply, afForward]
  ): boolean;
var
  zViewerMailForm: TzViewerMailForm;
begin
  Application.CreateForm(TzViewerMailForm, zViewerMailForm);
  try
    result := zViewerMailForm.ViewMail(FileName, SMTPServerParams, GetIndirizziProc, AllowedForwardingTypes);
  finally
    FreeAndNil(zViewerMailForm);
  end;
end;

constructor TzViewerMailForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  si.Enabled := True;

  FAllowedForwardingTypes := [afReply, afForward];
  FGetIndirizziProc := nil;
  SMTPServerParams.Init;

  FFileName := '';
  FPdfFontEmbedding := zfeSubset;
  edFrom.Clear;
  edCC.Clear;
  edCCN.Clear;
  edOggetto.Clear;
  edData.Clear;
  listAllegati.Clear;

  MailReader := TzOfficeMailReader.Create;

  dx.InitLayoutControl(dxLayoutControl);
  dx.InitPrinter(Printer);

  dxRichEditControl.ReadOnly := True;
end;

destructor TzViewerMailForm.Destroy;
begin
  inherited;
  FreeAndNil(MailReader);
end;

procedure TzViewerMailForm.actExportPDFExecute(Sender: TObject);
begin
  ExportPDF('');
end;

procedure TzViewerMailForm.actShellExecuteExecute(Sender: TObject);
begin

  if not FileName.IsEmpty then
    if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
    begin
      dxRichEditControl.SaveDocument;
      dxRichEditControl.DocumentModelModified := false;
      ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
    end;
end;

procedure TzViewerMailForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MailReader.ClearFolder;
end;

function TzViewerMailForm.ViewMail(const FileName: String; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>; AllowedForwardingTypes: TMailAllowedForwardingTypes;
  const ReadOnly: boolean = false): boolean;
var
  i: Integer;
  Body: string;
begin
  FAllowedForwardingTypes := AllowedForwardingTypes;
  FSMTPServerParams.Assign(SMTPServerParams);
  FGetIndirizziProc := GetIndirizziProc;

  edFrom.Clear;
  edCC.Clear;
  edCCN.Clear;
  edOggetto.Clear;
  edData.Clear;

  MailReader.LoadFileEML(FileName, dxRichEditControl);

  edFrom.EditValue := MailReader.MessageFrom;

  edTO.EditValue := MailReader.MessageTO;

  edCC.EditValue := MailReader.MessageCC;
  dxLayoutItemCC.Visible := not MailReader.MessageCC.IsEmpty;

  edCCN.EditValue := MailReader.MessageCCN;
  dxLayoutItemCCN.Visible := not MailReader.MessageCCN.IsEmpty;

  edOggetto.EditValue := MailReader.MessageSubject;
  edData.EditValue := MailReader.MessageDate.ToString;

  AssignBody(MailReader.MessageBody, MailReader.MessageBodyIsHTML);

  FillAttachmentsList;

  FFileName := FileName;
  Caption := FileName;

  result := ShowModal = mrOk;
end;

procedure TzViewerMailForm.AssignBody(const Body: string; const isHtml: boolean);
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

procedure TzViewerMailForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerMailForm.FillAttachmentsList;
var
  item: TListItem;
  AttachmentFile: TIdAttachmentFile;
  s: String;
begin
  listAllegati.Clear;

  for AttachmentFile in MailReader.Attachments do
  begin
    item := listAllegati.Items.Add;
    item.Caption := AttachmentFile.FileName;
    item.Data := AttachmentFile;
    item.ImageIndex := AttachmentFile.ImageIndex;
  end;
end;

procedure TzViewerMailForm.FormShow(Sender: TObject);
begin
  if dx.SkinActive then
    dxRibbon.ColorSchemeName := 'UserSkin'
  else
    dxRibbon.ColorSchemeName := 'White';
end;

procedure TzViewerMailForm.UpdateZoom;
begin
  if dxRichEditControl.ActiveView.ZoomFactor > 5 then
    dxRichEditControl.ActiveView.ZoomFactor := 5;
  tbZoom.Position := Round(dxRichEditControl.ActiveView.ZoomFactor * 100);
end;

procedure TzViewerMailForm.tbZoomPropertiesChange(Sender: TObject);
begin
  bsZoom.Caption := Format('%3d %%', [tbZoom.Position]);
  dxRichEditControl.ActiveView.ZoomFactor := tbZoom.Position / 100;
end;

procedure TzViewerMailForm.dxRichEditControlActiveViewChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerMailForm.dxRichEditControlZoomChanged(Sender: TObject);
begin
  UpdateZoom;
end;

procedure TzViewerMailForm.ExportPDF(const FileNamePdf: String);
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
    Options.OpenDocumentAfterExport := false; //
    // Options.SecurityOptions
    // Options.SignatureOptions

    Options.EmbedFonts := PdfFontEmbedding in [zfeFull, zfeSubset];
    Options.UseCIDFonts := PdfFontEmbedding = zfeSubset;
    Options.UseJPEGCompression := True;

    StartWait('Attendere...', True);
    try
      Printer.ExportToPDF(PdfFileName, false, Options);
    finally
      StopWait;
    end;
  finally
    FreeAndNil(Options);
  end;

  if ConfirmYesNo('Si desidera aprire il file ' + PdfFileName + '?', mtWarning) then
    ShellExecute(0, PCHAR('open'), PCHAR(PdfFileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerMailForm.listAllegatiDblClick(Sender: TObject);
var
  item: TListItem;
  AttachmentFile: TIdAttachmentFile;
begin
  item := listAllegati.Selected;

  if not assigned(item) then
    exit;

  AttachmentFile := TIdAttachmentFile(item.Data);

  AttachmentFile.ShowAttachmentFile;
end;

procedure TzViewerMailForm.RispondiExecute(Sender: TObject);
begin
  WriteMail(FileName, mfReply, SMTPServerParams, GetIndirizziProc);
end;

procedure TzViewerMailForm.RispondiUpdate(Sender: TObject);
begin
  Rispondi.Visible := afReply in AllowedForwardingTypes;
end;

procedure TzViewerMailForm.InoltraExecute(Sender: TObject);
begin
  WriteMail(FileName, mfForward, SMTPServerParams, GetIndirizziProc);
end;

procedure TzViewerMailForm.InoltraUpdate(Sender: TObject);
begin
  Inoltra.Visible := afForward in AllowedForwardingTypes;
end;

function TzViewerMailForm.ShowModal: Integer;
begin
  dxRibbon.ActiveTab := dxRibbonTabFile;
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  result := inherited ShowModal;
end;

end.
