unit zOffice.Reports.Batch;

{
  TzReportBatchRunner
  -------------------
  Esecuzione batch di stampa ed export PDF per i tre motori
  (FastReport, Word, Excel).

  Livello basso  — sessione manuale (Init/Print/ExportPdf/Done):
    Il chiamante gestisce il ciclo e chiama un metodo per documento.

  Livello alto   — ciclo guidato da TzBatchController (RunPrint /
    RunExportPdf): itera automaticamente, mostra la ProgressBox,
    supporta la cancellazione.

  Non possiede nulla: riceve tutto via costruttore come callback/riferimenti.
  Nessun puntatore.

  Per Word ed Excel il manager passa due callback:
    OnWordExecute(TemplateFileName)   — esegue MailMerge con i propri params
    OnExcelExecute(TemplateFileName)  — esegue BuildSpreadSheetReport con i propri params
    OnWordExportPdf(TemplateFileName, PdfFileName)  — export PDF Word
    OnExcelExportPdf(TemplateFileName, PdfFileName) — export PDF Excel
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Vcl.Dialogs,
  Vcl.FileCtrl,
  zOffice.Reports.types,
  zOffice.Reports.FastReport,
  zOffice.Reports.BatchController,
  zFileSystem,
  zMsg,
  zProgressBox;

type
  TzBatchBeforePrintProc = TFunc<string, Boolean>;

  TzReportBatchRunner = class
  private
    FEngine: TzFastReportEngine;    // riferimento non posseduto
    FProgressBox: TProgressBox;     // riferimento non posseduto
    FBatchActive: Boolean;

    // Callbacks Word / Excel fornite dal manager come closure
    FOnWordExecute: TProc<string>;              // param: TemplateFileName
    FOnExcelExecute: TProc<string>;             // param: TemplateFileName
    FOnWordExportPdf: TProc<string, string>;    // params: TemplateFileName, PdfFileName
    FOnExcelExportPdf: TProc<string, string>;   // params: TemplateFileName, PdfFileName

    // Callbacks ciclo
    FBeforePrint: TzBatchBeforePrintProc;
    FAfterPrint: TProc<string>;

    function ResolveReport(const ReportName: string;
      Reports: TzFolder; out Report: TzFile): Boolean;
  public
    constructor Create(
      Engine: TzFastReportEngine;
      ProgressBox: TProgressBox);

    // ------------------------------------------------------------------
    // Callbacks Word / Excel (impostate dal manager nel constructor)
    // ------------------------------------------------------------------

    property OnWordExecute: TProc<string>
      read FOnWordExecute write FOnWordExecute;
    property OnExcelExecute: TProc<string>
      read FOnExcelExecute write FOnExcelExecute;
    property OnWordExportPdf: TProc<string, string>
      read FOnWordExportPdf write FOnWordExportPdf;
    property OnExcelExportPdf: TProc<string, string>
      read FOnExcelExportPdf write FOnExcelExportPdf;

    // ------------------------------------------------------------------
    // Livello basso — sessione manuale
    // ------------------------------------------------------------------

    procedure Init;
    procedure Print(const DocumentLabel: string;
      ShowPrinterDialog: Boolean = False);
    function ExportPdf(const FileName: string): Boolean;
    procedure Done;

    // ------------------------------------------------------------------
    // Livello alto — ciclo guidato da TzBatchController
    // ------------------------------------------------------------------

    procedure RunPrint(
      const ReportName: string;
      Reports: TzFolder;
      Controller: TzBatchController;
      const ProgressCaption: string = 'Stampa in corso');

    function RunExportPdf(
      const ReportName: string;
      Reports: TzFolder;
      Controller: TzBatchController;
      OutputFolder: string = '';
      const ProgressCaption: string = 'Generazione PDF'): Integer;

    // ------------------------------------------------------------------
    // Callbacks ciclo
    // ------------------------------------------------------------------

    property BeforePrint: TzBatchBeforePrintProc
      read FBeforePrint write FBeforePrint;
    property AfterPrint: TProc<string>
      read FAfterPrint write FAfterPrint;
  end;

implementation

{ TzReportBatchRunner }

constructor TzReportBatchRunner.Create(
  Engine: TzFastReportEngine;
  ProgressBox: TProgressBox);
begin
  inherited Create;
  Assert(assigned(Engine));
  Assert(assigned(ProgressBox));
  FEngine := Engine;
  FProgressBox := ProgressBox;
  FBatchActive := False;
end;

function TzReportBatchRunner.ResolveReport(const ReportName: string;
  Reports: TzFolder; out Report: TzFile): Boolean;
begin
  result := False;
  Report := nil;

  if not assigned(Reports) then
    exit;

  Report := Reports.FileByName(ReportName);
  if not assigned(Report) then
  begin
    ConfirmOk('Report non trovato: ' + ReportName, mtWarning);
    exit;
  end;

  result := True;
end;

// ------------------------------------------------------------------
// Livello basso
// ------------------------------------------------------------------

procedure TzReportBatchRunner.Init;
begin
  FBatchActive := False;
  FEngine.ConfigureBatchMode;
  FBatchActive := True;
end;

procedure TzReportBatchRunner.Print(const DocumentLabel: string;
  ShowPrinterDialog: Boolean);
begin
  if not FBatchActive then
    exit;

  FEngine.Report.ReportOptions.Name := DocumentLabel;
  FEngine.Report.PrintOptions.ShowDialog := ShowPrinterDialog;

  if FEngine.Report.PrepareReport(True) then
    FEngine.Report.Print;

  FEngine.FreePreviewMemory;
end;

function TzReportBatchRunner.ExportPdf(const FileName: string): Boolean;
begin
  result := False;

  if not FBatchActive then
    exit;

  if FileName.IsEmpty then
    raise EArgumentException.Create('ExportPdf: FileName non specificato.');

  ForceDirectories(TPath.GetDirectoryName(FileName));

  if not FEngine.Report.PrepareReport(True) then
    exit;

  FEngine.PDFExport.FileName := ChangeFileExt(FileName, '.pdf');
  result := FEngine.Report.Export(FEngine.PDFExport);
  FEngine.PDFExport.FileName := '';

  FEngine.FreePreviewMemory;
end;

procedure TzReportBatchRunner.Done;
begin
  FBatchActive := False;
  FEngine.Report.OnBeforePrint := nil;
  FEngine.RestoreInteractiveMode;

  if assigned(FAfterPrint) then
    FAfterPrint('');
end;

// ------------------------------------------------------------------
// Livello alto
// ------------------------------------------------------------------

procedure TzReportBatchRunner.RunPrint(
  const ReportName: string;
  Reports: TzFolder;
  Controller: TzBatchController;
  const ProgressCaption: string);
var
  Report: TzFile;
  Kind: TReportKind;
  i: Integer;
  PrimoGiro: Boolean;
  ok: Boolean;
begin
  if not assigned(Controller) then
    raise EArgumentNilException.Create(
      'RunPrint: Controller non assegnato.');

  if not ResolveReport(ReportName, Reports, Report) then
    exit;

  Kind := TReportKind.FromString(Report.FileExt);

  Controller.AvvisaSeSuperamentoMax;
  Controller.Init;

  FProgressBox.Show(Controller.Count, ProgressCaption,
    ProgressCaption, 'Attendere...');
  try
    PrimoGiro := True;

    for i := 0 to Controller.Count - 1 do
    begin
      FProgressBox.IncProgress(
        Format('%d / %d', [i + 1, Controller.Count]));
      if FProgressBox.Cancelled then
        exit;

      ok := True;
      if assigned(FBeforePrint) then
        ok := FBeforePrint(ReportName);

      if not ok then
      begin
        Controller.Next;
        Continue;
      end;

      try
        case Kind of
          rkFastReport:
            begin
              FEngine.Report.PrintOptions.ShowDialog := PrimoGiro;
              if FEngine.Report.PrepareReport(True) then
              begin
                FEngine.Report.Print;
                FEngine.FreePreviewMemory;
              end;
            end;

          rkWord:
            if assigned(FOnWordExecute) then
              FOnWordExecute(Report.FullName);

          rkExcel:
            if assigned(FOnExcelExecute) then
              FOnExcelExecute(Report.FullName);
        end;

        PrimoGiro := False;
      finally
        if assigned(FAfterPrint) then
          FAfterPrint(ReportName);
      end;

      Controller.Next;
    end;

  finally
    FProgressBox.Close;
    FEngine.Report.PrintOptions.ShowDialog := True;
    FEngine.Report.ShowProgress := True;
  end;
end;

function TzReportBatchRunner.RunExportPdf(
  const ReportName: string;
  Reports: TzFolder;
  Controller: TzBatchController;
  OutputFolder: string;
  const ProgressCaption: string): Integer;
var
  Report: TzFile;
  Kind: TReportKind;
  i: Integer;
  FileName: string;
  ok: Boolean;
begin
  result := 0;

  if not assigned(Controller) then
    raise EArgumentNilException.Create(
      'RunExportPdf: Controller non assegnato.');

  if not ResolveReport(ReportName, Reports, Report) then
    exit;

  Kind := TReportKind.FromString(Report.FileExt);

  if OutputFolder.IsEmpty then
    if not SelectDirectory(
      'Seleziona la cartella di destinazione PDF', '', OutputFolder) then
      exit;

  OutputFolder := IncludeTrailingPathDelimiter(OutputFolder);
  ForceDirectories(OutputFolder);

  if Kind = rkFastReport then
    FEngine.ConfigureBatchMode;

  Controller.Init;

  FProgressBox.Show(Controller.Count, ProgressCaption,
    ProgressCaption, 'Attendere...');
  try
    for i := 0 to Controller.Count - 1 do
    begin
      FProgressBox.IncProgress(
        Format('%d / %d', [i + 1, Controller.Count]),
        Controller.FileNamePdf);
      if FProgressBox.Cancelled then
        exit;

      FileName := Controller.FileNamePdf;
      if FileName.IsEmpty then
        FileName := FormatDateTime('yyyymmdd_hhnnss', Now) +
          '_' + IntToStr(i);
      FileName := OutputFolder + ChangeFileExt(FileName, '.pdf');

      ok := True;
      if assigned(FBeforePrint) then
        ok := FBeforePrint(ReportName);

      if not ok then
      begin
        Controller.Next;
        Continue;
      end;

      try
        case Kind of
          rkFastReport:
            begin
              if FEngine.Report.PrepareReport(True) then
              begin
                ForceDirectories(TPath.GetDirectoryName(FileName));
                FEngine.PDFExport.FileName := FileName;
                if FEngine.Report.Export(FEngine.PDFExport) then
                  Inc(result);
                FEngine.PDFExport.FileName := '';
                FEngine.FreePreviewMemory;
              end;
            end;

          rkWord:
            if assigned(FOnWordExportPdf) then
            begin
              FOnWordExportPdf(Report.FullName, FileName);
              Inc(result);
            end;

          rkExcel:
            if assigned(FOnExcelExportPdf) then
            begin
              FOnExcelExportPdf(Report.FullName, FileName);
              Inc(result);
            end;
        end;
      finally
        if assigned(FAfterPrint) then
          FAfterPrint(ReportName);
      end;

      Controller.Next;
    end;

  finally
    FProgressBox.Close;
    if Kind = rkFastReport then
      FEngine.RestoreInteractiveMode;
  end;
end;

end.
