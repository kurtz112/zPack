unit zOffice;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  dxRichEdit.NativeApi,
  dxRichEdit.Utils.UriStreamService,
  dxRichEdit.Control,
  dxSpreadSheet,
  zOffice.types,
  zOffice.Mail.Utils,
  zOffice.Word.UriStreamProvider;

procedure ViewFile(const FileName: string; const ReadOnly: Boolean = false); overload;
procedure ViewFile(const zFileType: TzFileType; const FileName: string; const ReadOnly: Boolean = false); overload;

// Parametri con cui ViewFileWord(nome, soloLettura) apre un file: il formato e'
// Undefined, cosi' il visualizzatore lo riconosce dal contenuto (.docx, .doc, .rtf).
function NewWordParamsForFile(const FileName: string; const ReadOnly: Boolean): TWordParams;

procedure ViewFileWord(const FileName: string; const ReadOnly: Boolean = false); overload;
procedure ViewFileWord(WordParams: TWordParams); overload;
procedure ViewFileWord(Stream: TStream; WordParams: TWordParams); overload;

procedure ViewFileExcel(const FileName: string; const ReadOnly: Boolean = false); overload;
procedure ViewFileExcel(ExcelParams: TExcelParams); overload;
procedure ViewFileExcel(proc: TProc<TdxSpreadSheet>); overload;

procedure ViewFilePdf(const FileName: string);
procedure ViewFileSynEdit(const FileName: string);
procedure ViewFileImage(const FileName: string; const ReadOnly: Boolean = false);

procedure ViewFileMail(const FileName: String; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>; AllowedForwardingTypes: TMailAllowedForwardingTypes = [afReply, afForward]);

procedure SendMail(Mail: TMail; SMTPServerParams: TSMTPServerParams);
procedure WriteMail(Mail: TMail; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>); overload;
procedure WriteMail(const FileName: String; ForwardType: TMailForwardType; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>); overload;

procedure EditTemplateWord(WordParams: TWordParams);

procedure MailMerge(WordParams: TWordParams);

procedure EditTemplateExcel(ExcelParams: TExcelParams);

procedure BuildSpreadSheetReport(ExcelParams: TExcelParams);

var
  SMTPServerParams: TSMTPServerParams;
  // Apre un file con il programma associato da Windows. Se e' nil si usa
  // ShellExecute; i test la sostituiscono per non lanciare programmi veri.
  SystemOpenProc: TProc<string>;

procedure OpenWithSystemProgram(const FileName: string);

procedure CheckSMTPServerParams;

implementation

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  zOffice.Word.Form,
  zOffice.Word.Editor,
  zOffice.Word.MailMerge,
  zOffice.Excel.Editor,
  zOffice.Excel.Form,
  zOffice.Pdf.Form,
  zOffice.Mail.Form,
  zOffice.Mail.Editor,
  zOffice.Image.Form,
  zOffice.SynEdit.Form;

procedure ViewFile(const zFileType: TzFileType; const FileName: string; const ReadOnly: Boolean = false);
begin

  case zFileType of
    ftNone:
      // tipo non gestito (.zip, .msg, .gif, .htm, .log...): lo apre il programma di sistema
      OpenWithSystemProgram(FileName);
    ftPdf:
      ViewFilePdf(FileName);
    ftWord:
      zOffice.ViewFileWord(FileName, ReadOnly);
    ftExcel:
      zOffice.ViewFileExcel(FileName, ReadOnly);
    ftImage:
      ViewFileImage(FileName);
    ftMail:
      ViewFileMail(FileName, SMTPServerParams, nil);
    ftTXT:
      ViewFileSynEdit(FileName);
    ftXML:
      ViewFileSynEdit(FileName);
    ftJSON:
      ViewFileSynEdit(FileName);
  end;
end;

procedure ViewFile(const FileName: string; const ReadOnly: Boolean = false);
begin
  ViewFile(TzFileType.FromFileName(FileName), FileName, ReadOnly);
end;

procedure OpenWithSystemProgram(const FileName: string);
var
  Esito: HINST;
begin
  if FileName = '' then
    Exit;

  if assigned(SystemOpenProc) then
  begin
    SystemOpenProc(FileName);
    Exit;
  end;

  Esito := ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL);
  // ShellExecute segnala l'errore con un valore minore o uguale a 32
  if Esito <= 32 then
    raise Exception.CreateFmt('Impossibile aprire il file "%s" con il programma di sistema.', [FileName]);
end;

function NewWordParamsForFile(const FileName: string; const ReadOnly: Boolean): TWordParams;
begin
  Result.Init;
  Result.FileName := FileName;
  Result.ReadOnly := ReadOnly;
  Result.DocumentFormat := TdxRichEditDocumentFormat.Undefined;
end;

procedure ViewFileWord(const FileName: string; const ReadOnly: Boolean = false);
begin
  zOffice.Word.Form.ViewFileWord(NewWordParamsForFile(FileName, ReadOnly));
end;

procedure ViewFileWord(WordParams: TWordParams);
begin
  zOffice.Word.Form.ViewFileWord(WordParams);
end;

procedure ViewFileWord(Stream: TStream; WordParams: TWordParams);
begin
  zOffice.Word.Form.ViewFileWord(Stream, WordParams);
end;

procedure ViewFileExcel(const FileName: string; const ReadOnly: Boolean = false);
begin
  zOffice.Excel.Form.ViewFileExcel(FileName, ReadOnly);
end;

procedure ViewFileExcel(ExcelParams: TExcelParams);
begin
  zOffice.Excel.Form.ViewFileExcel(ExcelParams);
end;

procedure ViewFileExcel(proc: TProc<TdxSpreadSheet>); overload;
begin
  zOffice.Excel.Form.ViewFileExcel(proc);
end;

procedure ViewFilePdf(const FileName: string);
begin
  zOffice.Pdf.Form.ViewFilePdf(FileName);
end;

procedure ViewFileImage(const FileName: string; const ReadOnly: Boolean = false);
begin
  zOffice.Image.Form.ViewFileImage(FileName, ReadOnly);
end;

procedure ViewFileMail(const FileName: String; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>; AllowedForwardingTypes: TMailAllowedForwardingTypes = [afReply, afForward]);
begin
  zOffice.Mail.Form.ViewFileMail(FileName, SMTPServerParams, GetIndirizziProc, AllowedForwardingTypes);
end;

procedure WriteMail(Mail: TMail; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
begin
  zOffice.Mail.Editor.WriteFileMail(Mail, SMTPServerParams, GetIndirizziProc);
end;

procedure WriteMail(const FileName: String; ForwardType: TMailForwardType; SMTPServerParams: TSMTPServerParams; GetIndirizziProc: TProc<TStringList>);
begin
  zOffice.Mail.Editor.WriteFileMail(FileName, ForwardType, SMTPServerParams, GetIndirizziProc);
end;

procedure EditTemplateWord(WordParams: TWordParams);
begin
  zOffice.Word.Editor.EditTemplateWord(WordParams);
end;

procedure MailMerge(WordParams: TWordParams);
var
  Stream: TStream;
begin
  Stream := zOffice.Word.MailMerge.MailMerge(WordParams);
  try
    // Stream = nil quando l'utente ha annullato la generazione: niente viewer.
    if assigned(Stream) then
      zOffice.ViewFileWord(Stream, WordParams);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure EditTemplateExcel(ExcelParams: TExcelParams);
begin
  zOffice.Excel.Editor.EditTemplateExcel(ExcelParams);
end;

procedure BuildSpreadSheetReport(ExcelParams: TExcelParams);
begin
  zOffice.Excel.Editor.BuildSpreadSheetReport(ExcelParams);
end;

procedure CheckSMTPServerParams;
begin

  if not SMTPServerParams.IsValid then
    raise Exception.Create('Parametri SMTP non configurati.');
end;

procedure SendMail(Mail: TMail; SMTPServerParams: TSMTPServerParams);
var
  zViewerMailWriter: TzOfficeMailWriter;
begin
  zViewerMailWriter := TzOfficeMailWriter.Create(nil);
  try
    zViewerMailWriter.SendMail(Mail, SMTPServerParams);
  finally
    FreeAndNil(zViewerMailWriter);
  end;
end;

procedure ViewFileSynEdit(const FileName: string);
begin
  zOffice.SynEdit.Form.ViewFileSynEdit(FileName);
end;

initialization

SMTPServerParams.Init;

end.
