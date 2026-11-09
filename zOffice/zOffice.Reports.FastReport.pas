unit zOffice.Reports.FastReport;

{
  TzFastReportEngine
  ------------------
  Wrapping delle operazioni FastReport: preview, stampa, export PDF,
  apertura designer, modalità batch.

  Dipende dai componenti FastReport già creati nel DataModule
  (TzReportsManager li possiede via DFM): riceve i riferimenti
  nel costruttore e non li possiede.

  Non conosce variabili, pipeline, JSON, Word o Excel.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Vcl.Dialogs,
  frxClass,
  frxDesgn,
  frxExportPDF,
  zOffice.types, // TzSetupAzioniDocumentoProc
  zOffice.Reports.types,
  zOffice.Reports.JsonConfig, // TzJsonFastReportConfig
  zOffice.Reports.Progress, // IzReportProgress
  zFileSystem,
  zSystem;

type
  TzFastReportEngine = class
  private
    FReport: TfrxReport; // riferimento non posseduto
    FPDFExport: TfrxPDFExport; // riferimento non posseduto
    FDesigner: TfrxDesigner; // riferimento non posseduto
    FCurrentUserDisplayName: string;
    FModificaAnteprima: Boolean;
    FzSystem: TzSystem; // riferimento non posseduto
    FOnSetupAzioniDocumento: TzSetupAzioniDocumentoProc; // dal ReportsManager

    // avanzamento + annullamento (ProgressBox del manager); nil = nessun feedback
    FProgress: IzReportProgress;

    procedure InitModificaAnteprima;

    // Immagini dei grafici TzDbChart aperti negli oggetti immagine del report
    // che li richiamano (zOffice.Grafici): TagStr = chart://Nome, oppure nome
    // dell'oggetto chartNome
    procedure CaricaGrafici;

    // handler agganciato a frxReport.OnProgress durante Preview/Print
    procedure DoProgress(Sender: TfrxReport; ProgressType: TfrxProgressType; Progress: Integer);

    // apertura/chiusura del box UNA sola volta (indipendente dal n. di passate)
    procedure BeginProgress;
    procedure EndProgress;
  public
    constructor Create(Report: TfrxReport; PDFExport: TfrxPDFExport; Designer: TfrxDesigner);

    // ------------------------------------------------------------------
    // Operazioni base
    // ------------------------------------------------------------------

    /// Carica il file .fr3 nel report. Mostra un messaggio se non trovato.
    function LoadFromFile(const FileName: string): Boolean;

    /// Esegue PrepareReport. Presuppone che LoadFromFile sia già stato chiamato.
    function PrepareReport: Boolean;

    /// Libera le pagine preparate dalla memoria (chiama PreviewPages.Clear).
    procedure FreePreviewMemory;

    // ------------------------------------------------------------------
    // Preview / Stampa / Export
    // ------------------------------------------------------------------

    /// Mostra il report in anteprima (con gestione ModificaAnteprima).
    procedure Preview;

    // azioni documentali: il manager la assegna, la Preview la inoltra al form
    property OnSetupAzioniDocumento: TzSetupAzioniDocumentoProc read FOnSetupAzioniDocumento write FOnSetupAzioniDocumento;

    /// Stampa il report. ShowDialog controlla se mostrare il dialogo stampante.
    procedure Print(ShowDialog: Boolean = True);

    /// Esporta il report in PDF. FileName può essere vuoto (usa ShowDialog).
    /// Restituisce True se l'export è andato a buon fine.
    function ExportPdf(const FileName: string = ''): Boolean;

    // ------------------------------------------------------------------
    // Designer
    // ------------------------------------------------------------------

    /// Apre il designer FastReport per ReportFile.
    /// Crea automaticamente un backup nella sottocartella _backup\.
    procedure OpenDesigner(const ReportFile: TzFile; const FallbackFolder: string);

    // ------------------------------------------------------------------
    // Configurazione da JSON
    // ------------------------------------------------------------------

    /// Applica i parametri FastReport letti dal JSON sidecar.
    procedure ConfigureFromJson(const Cfg: TzJsonFastReportConfig);

    // ------------------------------------------------------------------
    // Modalità batch
    // ------------------------------------------------------------------

    /// Configura FastReport per la modalità batch (silenzia dialoghi e progress).
    procedure ConfigureBatchMode;

    /// Ripristina le impostazioni interattive dopo una sessione batch.
    procedure RestoreInteractiveMode;

    // ------------------------------------------------------------------
    // Proprietà
    // ------------------------------------------------------------------

    property Report: TfrxReport read FReport;
    property PDFExport: TfrxPDFExport read FPDFExport;

    property ModificaAnteprima: Boolean read FModificaAnteprima;

    property CurrentUserDisplayName: string read FCurrentUserDisplayName write FCurrentUserDisplayName;

    property zSystem: TzSystem read FzSystem write FzSystem;

    // assegnato dal ReportsManager: barra + Annulla durante PrepareReport
    property Progress: IzReportProgress read FProgress write FProgress;
  end;

implementation

uses
  System.DateUtils,
  Vcl.Imaging.pngimage,
  zz.PercorsiLunghi, // Mantis #131 - 2026-09-16: backup oltre i 260 caratteri di MAX_PATH
  frxExportPDFHelpers,
  zOffice.Grafici,
  zBaseLib,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  zMsg,
  zOffice.FastReport.Form;

{ TzFastReportEngine }

constructor TzFastReportEngine.Create(Report: TfrxReport; PDFExport: TfrxPDFExport; Designer: TfrxDesigner);
begin
  inherited Create;
  Assert(assigned(Report));
  Assert(assigned(PDFExport));
  Assert(assigned(Designer));
  FReport := Report;
  FPDFExport := PDFExport;
  FDesigner := Designer;
  FModificaAnteprima := False;
  FzSystem := nil;
  FCurrentUserDisplayName := '';
  FProgress := nil;
end;

// ------------------------------------------------------------------
// Progress + Annulla (delegato al ProgressBox del manager)
// ------------------------------------------------------------------

// NB: la firma TfrxProgressEvent (Sender: TfrxReport; ProgressType:
// TfrxProgressType; Progress: Integer) e' quella standard di FastReport VCL.

procedure TzFastReportEngine.DoProgress(Sender: TfrxReport; ProgressType: TfrxProgressType; Progress: Integer);
begin
  if not assigned(FProgress) then
    exit;

  // aggiorna: elabora i messaggi (fa animare il marquee e reagire il pulsante)
  // e ritorna False se l'utente ha premuto Annulla -> termina la preparazione.
  // Info vuoto: la didascalia resta quella impostata in BeginProgress (con la
  // marquee la posizione non conta, e cosi' non "salta" tra le due passate).
  if not FProgress.Step(Progress, '') then
    Sender.Terminated := True;
end;

procedure TzFastReportEngine.BeginProgress;
begin
  // Il box viene aperto UNA volta qui e chiuso UNA volta in EndProgress: cosi'
  // un report a due passate (TwoPass) - che fa scattare OnProgressStart/Stop
  // due volte in sequenza - non apre/chiude il box due volte. Gli eventi di
  // FastReport servono solo ad aggiornare la barra, non a gestirne il ciclo di
  // vita: per questo si aggancia il solo OnProgress.
  FReport.ShowProgress := False; // progress nativo off: si usa il ProgressBox
  FReport.OnProgress := DoProgress;

  if assigned(FProgress) then
    // Max = 0: FastReport non conosce il totale a priori -> barra marquee
    FProgress.Start('Preparazione anteprima in corso...', 0);
end;

procedure TzFastReportEngine.EndProgress;
begin
  FReport.OnProgress := nil;

  if assigned(FProgress) then
    FProgress.Done;
end;

// ------------------------------------------------------------------
// Operazioni base
// ------------------------------------------------------------------

function TzFastReportEngine.LoadFromFile(const FileName: string): Boolean;
begin
  result := False;

  if not TFile.Exists(FileName) then
  begin
    ConfirmOk('File Report non trovato: ' + FileName, mtWarning);
    exit;
  end;

  FReport.LoadFromFile(FileName);
  CaricaGrafici;
  result := True;
end;

type
  // TagStr e' protetta in alcune versioni di FastReport
  TfrxViewAccesso = class(TfrxView);

procedure TzFastReportEngine.CaricaGrafici;
const
  // misura dell'oggetto in pixel a 96 punti per pollice; l'immagine a 300
  PuntiPerPollice = 300;
var
  Indice: Integer;
  Vista: TfrxPictureView;
  Riferimento: TzRiferimentoGrafico;
  Larghezza, Altezza: Integer;
  Flusso: TStream;
  Immagine: TPngImage;
begin
  for Indice := 0 to FReport.AllObjects.Count - 1 do
  begin
    if not (TObject(FReport.AllObjects[Indice]) is TfrxPictureView) then
      Continue;

    Vista := TfrxPictureView(FReport.AllObjects[Indice]);

    if not TzRiferimentoGrafico.Prova(TfrxViewAccesso(Vista).TagStr, Riferimento) then
      // Name e' un TComponentName, non una string: l'helper di stringa (E2671)
      // vale solo dopo il cast.
      if string(Vista.Name).StartsWith('chart', True) and (Length(Vista.Name) > Length('chart')) then
        TzRiferimentoGrafico.Prova(TzRegistroGrafici.Schema + string(Vista.Name).Substring(Length('chart')), Riferimento)
      else
        Continue;

    Larghezza := Riferimento.Larghezza;
    Altezza := Riferimento.Altezza;

    if Larghezza = 0 then
    begin
      Larghezza := Round(Vista.Width * PuntiPerPollice / 96);
      Altezza := Round(Vista.Height * PuntiPerPollice / 96);
    end;

    try
      // FastReport disegna il PNG senza moduli aggiuntivi: niente SVG qui
      Flusso := TzRegistroGrafici.Immagine(Riferimento.Nome, fgPng, Larghezza, Altezza);

      // grafico non aperto: resta l'immagine del modello
      if not assigned(Flusso) then
        Continue;

      try
        Immagine := TPngImage.Create;
        try
          Immagine.LoadFromStream(Flusso);
          Vista.Picture.Assign(Immagine);
          // l'immagine e' piu' grande dell'oggetto: va adattata, non ritagliata
          Vista.Stretched := True;
        finally
          Immagine.Free;
        end;
      finally
        Flusso.Free;
      end;
    except
      // un grafico che non si disegna non deve impedire la stampa
      on E: Exception do
      begin
        SiMain.LogWarning('CaricaGrafici: grafico non disegnato: ' + Riferimento.Nome);
        SiMain.LogException(E);
      end;
    end;
  end;
end;

function TzFastReportEngine.PrepareReport: Boolean;
begin
  result := FReport.PrepareReport(True);
end;

procedure TzFastReportEngine.FreePreviewMemory;
begin
  if assigned(FReport.PreviewPages) then
    FReport.PreviewPages.Clear;
end;

// ------------------------------------------------------------------
// Preview / Stampa / Export
// ------------------------------------------------------------------

procedure TzFastReportEngine.InitModificaAnteprima;
begin
  if assigned(FzSystem) then
    FModificaAnteprima := FzSystem.Authorizhed(REPORT_PREVIEW_EDITING_PERMISSION)
  else
    FModificaAnteprima := False;

  FReport.PreviewOptions.AllowPreviewEdit := FModificaAnteprima;

  if FModificaAnteprima then
    FReport.PreviewOptions.Buttons := FReport.PreviewOptions.Buttons + [pbInplaceEdit]
  else
    FReport.PreviewOptions.Buttons := FReport.PreviewOptions.Buttons - [pbInplaceEdit];
end;

procedure TzFastReportEngine.Preview;
var
  PreviewForm: TzOfficeFastReportForm;
begin
  InitModificaAnteprima;

  // Anteprima interattiva: barra + Annulla tramite il ProgressBox del manager
  // (coerente con Word/Excel). Se l'utente annulla, DoProgress imposta
  // FReport.Terminated, PrepareReport ritorna False e il viewer non si apre.
  BeginProgress;
  try
    if PrepareReport then
    begin
      // mostra la nuova form personalizzata
      PreviewForm := TzOfficeFastReportForm.Create(nil);
      try
        PreviewForm.ShowPreview(FReport, FPDFExport, FOnSetupAzioniDocumento);
      finally
        PreviewForm.Free;
      end;
    end;
  finally
    EndProgress;
  end;
end;

procedure TzFastReportEngine.Print(ShowDialog: Boolean);
begin
  // Stessa logica dell'anteprima: barra + Annulla durante la preparazione.
  // Se l'utente annulla, PrepareReport ritorna False e non si stampa nulla.
  BeginProgress;
  try
    if PrepareReport then
    begin
      if CtrlKey or ShowDialog then
        FReport.ShowReport(False)
      else
        FReport.Print;
    end;
  finally
    EndProgress;
  end;
end;

function TzFastReportEngine.ExportPdf(const FileName: string): Boolean;
begin
  result := False;

  FPDFExport.FileName := FileName;
  FPDFExport.Author := FCurrentUserDisplayName;
  FPDFExport.Creator := FCurrentUserDisplayName;

  if PrepareReport then
    result := FReport.Export(FPDFExport);
end;

// ------------------------------------------------------------------
// Designer
// ------------------------------------------------------------------

procedure TzFastReportEngine.OpenDesigner(const ReportFile: TzFile; const FallbackFolder: string);
var
  FileName: string;
  Folder: string;
  backupFolder: string;
  backupFile: string;
begin
  FReport.Clear;
  FReport.FileName := '';

  if assigned(ReportFile) then
  begin
    FileName := ReportFile.FullName;
    Folder := ReportFile.Folder;

    // Mantis #131 - 2026-09-16: stessa causa del salvataggio del template Word, il
    // backup falliva oltre i 260 caratteri di MAX_PATH. Vedi TzPercorsiLunghi.
    backupFolder := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(FileName)) + '__backup\';
    TzPercorsiLunghi.ForzaCartelle(backupFolder);
    backupFile := backupFolder + FormatDateTime('yyyymmddhhnnss', Now) + '_' + TPath.GetFileName(FileName);
    TzPercorsiLunghi.CopiaFile(FileName, backupFile);

    FReport.LoadFromFile(FileName);
  end
  else
    Folder := FallbackFolder;

  FDesigner.OpenDir := Folder;
  FDesigner.SaveDir := Folder;
  FDesigner.TemplateDir := Folder;

  StartWait;
  try
    FReport.DesignReport;
    StopWait;
  except
    StopWait;
    raise;
  end;
end;

// ------------------------------------------------------------------
// Configurazione da JSON
// ------------------------------------------------------------------

procedure TzFastReportEngine.ConfigureFromJson(const Cfg: TzJsonFastReportConfig);
begin
  if not Cfg.IsPresent then
    exit;

  FPDFExport.ShowDialog := Cfg.ShowDialog;
  FPDFExport.OpenAfterExport := Cfg.OpenAfterExport;
  FPDFExport.EmbeddedFonts := Cfg.EmbeddedFonts;
  FPDFExport.OverwritePrompt := Cfg.OverwritePrompt;
end;

// ------------------------------------------------------------------
// Modalità batch
// ------------------------------------------------------------------

procedure TzFastReportEngine.ConfigureBatchMode;
begin
  FReport.DatasetName := '';
  FReport.ReportOptions.Name := '';
  FReport.PrintOptions.ShowDialog := False;
  FReport.ShowProgress := False;

  FPDFExport.OpenAfterExport := False;
  FPDFExport.ShowDialog := False;
  FPDFExport.OverwritePrompt := False;
  FPDFExport.Compressed := True;
  FPDFExport.EmbeddedFonts := True;
  FPDFExport.PDFStandard := psPDFA_1a;
end;

procedure TzFastReportEngine.RestoreInteractiveMode;
begin
  FReport.PrintOptions.ShowDialog := True;
  FReport.ShowProgress := True;
  FPDFExport.FileName := '';
end;

end.
