unit zExceptions;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Controls,
  Vcl.Graphics,
  zExceptions.stack,
  zExceptions.mantis,
  zOffice.types,
  zOffice;

const
  // Didascalia unica del comando che apre il ticket (o, in mancanza di
  // Mantis, prepara la mail): la usano sia il messaggio d'errore sia la form
  // di dettaglio, cosi' l'utente riconosce lo stesso comando nei due punti.
  CaptionRichiestaAssistenza = 'Richiedi assistenza';

type
  TzExceptionManager = class
  private
    FE: Exception;
    // Numero del ticket Mantis aperto per questa eccezione, 0 finche' non ne
    // e' stato aperto nessuno. Serve a non aprire due ticket per lo stesso
    // errore: il comando resta disponibile sia nel messaggio sia nei dettagli.
    FTicketId: integer;
    // Pulsante del messaggio d'errore, da spegnere quando il ticket viene
    // aperto dalla form di dettaglio (che si apre sopra il messaggio).
    FRichiestaButton: TControl;
    FErrorMessage: string;
    FIBErrorCode: integer;
    FIBMessage: string;
    FSQLCode: integer;
    FSQLMessage: string;
    FSQLState: string;
    FStack: TCallStack;
    FCapturedForm: TCustomForm;
    FCapturedControl: TWinControl;
    FCapturedMonitor: TRect;
    FShot: TBitMap;
    FLogFile: string; // path del .log generato dalla prima LogException
    FPngFile: string; // path del .png generato dalla prima LogException
    // Contesto del dataset che ha fallito, prelevato UNA volta nel
    // costruttore. Le variabili di zExceptions.context sono "one-shot" e
    // il log della stessa eccezione viene scritto piu' volte: leggendole a
    // ogni scrittura, solo la prima copia conteneva queste informazioni.
    FFailedDataSetDump: string;
    FFailedDataSetName: string;
    FFailedDataSetDataModuleName: string;
    FFailedDataSetOwnerModuleName: string;
    FFailedDataSetId: string;
  private
    FIsFIBError: boolean;
    Logged: boolean;
    procedure LogToSmartInspect;
  public
    class var MailAddress: string;
    class var LogFolder: string;
    class var SMTPServerParams: TSMTPServerParams;
    class var MantisServerParams: TMantisServerParams;
    // Ticket appena aperto su Mantis (numero e oggetto): l'applicazione si
    // aggancia qui per registrarlo nel proprio database e alimentare la form
    // "Le mie segnalazioni" (zMantis.TicketAssistenza.form). zExceptions non
    // conosce il database: resta l'evento, chi lo gestisce decide dove scrivere.
    class var OnTicketAperto: TProc<Integer, string>;
  public const
    LogExtension = '.log';
    PngExtension = '.png';
    LogRetentionDays = 30; // i log piu' vecchi di tot giorni vengono rimossi
  private
    function LogFileName: string;
    function LogFolderPath: string;
    function PngFileName(const FileName: string): string;

    procedure CaptureShot; // scatta UNA volta in FShot
    procedure SaveShot(const FileName: string); // FShot -> file PNG
    procedure SaveToFile(const FileName: string);
    procedure PurgeOldLogs; // cancella .log/.png vecchi
  private
    procedure DettagliClick(Sender: TObject);
    procedure RichiestaAssistenzaClick(Sender: TObject);
    function AskReportNote(out aNote: string): boolean;
    function ResolveModuleTag: string; // nome form/datamodule, candidato per la categoria Mantis
    // Oggetto del ticket Mantis: modulo, utente applicativo e messaggio.
    function BuildMantisSummary: string;
    // Ritorna True se il ticket e' stato aperto con successo: in tal caso
    // RichiediAssistenza non invia anche la mail (ridondante).
    function InviaMantis(const aNote: string): boolean;
  public
    constructor Create(E: Exception);
    destructor Destroy; override;

    procedure LogException(FileName: string);
    procedure ShowException;
    procedure InviaMail; overload;
    procedure InviaMail(const aNote: string); overload;
    // Apre il ticket Mantis; se Mantis non e' configurato o l'apertura
    // fallisce, ripiega sulla mail. Ritorna True solo se il ticket e' stato
    // aperto: la mail passa dall'editor e l'utente puo' ancora annullarla,
    // quindi non conta come richiesta conclusa.
    function RichiediAssistenza: boolean;
    // True se c'e' almeno un canale configurato (Mantis o SMTP).
    function RichiestaAssistenzaDisponibile: boolean;
  public
    property E: Exception read FE;
    property ErrorMessage: string read FErrorMessage;
    property stack: TCallStack read FStack;
    // fib
    property IsFIBError: boolean read FIsFIBError;
    property IBErrorCode: integer read FIBErrorCode;
    property IBMessage: string read FIBMessage;
    property SQLCode: integer read FSQLCode;
    property SQLState: string read FSQLState;
    property SQLMessage: string read FSQLMessage;
    // Dataset che ha generato l'errore: nome del dataset e classe del
    // datamodule che lo possiede. Vuoti se l'errore non nasce da un dataset.
    property FailedDataSetName: string read FFailedDataSetName;
    property FailedDataSetDataModuleName: string read FFailedDataSetDataModuleName;
    // Identificativo LZ del dataset (NomeDataModule.NomeDataSet): e' la
    // chiave di TzSystem.zDataSets, quindi quello che serve alla form di
    // dettaglio per aprire l'editor dell'SQL del dataset che ha fallito.
    property FailedDataSetId: string read FFailedDataSetId;
    // Numero del ticket gia' aperto per questa eccezione (0 = nessuno).
    property TicketId: integer read FTicketId;
  end;

function GetErrorMessage(E: Exception): string;

var
  OnBeforeException: TProc = nil;
  OnAfterException: TProc = nil;

implementation

uses
  System.IOUtils,
  System.Rtti,
  System.WideStrUtils,
  Vcl.Imaging.pngimage,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.IBCli,
  dxMessageDialog,
  zExceptions.form,
  zExceptions.fib,
  zExceptions.utils,
  zExceptions.hook,
  zExceptions.context,
  zMemoDialog,
  zBaseLib,
  zMsg,
  SmartInspect.Vcl.SiAuto;

type
  TdxMessageDialogFormHach = class(TdxMessageDialogForm);

  // var
  // __zExceptionManager: TzExceptionManager = nil;
  //
  // function zExceptionManager: TzExceptionManager;
  // begin
  // result := __zExceptionManager;
  // end;

  { TzExceptionManager }

function GetErrorMessage(E: Exception): string;
var
  zExceptionManager: TzExceptionManager;
begin
  result := '';

  zExceptionManager := TzExceptionManager.Create(E);
  try
    result := zExceptionManager.ErrorMessage;
  finally
    FreeAndNil(zExceptionManager);
  end;

  // qualora restutuisca null...
  if result.IsEmpty then
    result := E.Message;
end;

constructor TzExceptionManager.Create(E: Exception);
var
  IBNativeException: EIBNativeException;
begin
  inherited Create;

  // Cattura SUBITO i riferimenti al contesto visivo, prima che dialog o
  // detail-form rubino il focus. Lo SCATTO vero avviene piu' tardi
  // (LogException/ShowException), fuori dallo stack dell'eccezione, dove
  // GetDC/BitBlt sono affidabili. Qui congeliamo solo cosa fotografare.
  FCapturedForm := Screen.ActiveCustomForm;
  if FCapturedForm = nil then
    FCapturedForm := Screen.ActiveForm;
  if FCapturedForm = nil then
    FCapturedForm := Application.MainForm;
  FCapturedControl := Screen.ActiveControl;
  FCapturedMonitor := ActiveMonitorBounds(FCapturedForm);

  // Scatto ORA, prima che LogException/ShowException aprano qualunque
  // dialog: e' l'unico istante in cui lo schermo mostra solo la UI
  // applicativa. Lo riuso poi per file e mail senza ri-scattare.
  FShot := nil;
  try
    CaptureShot;
  except
  end;

  // Contesto del dataset che ha fallito: va prelevato ORA, mentre e' ancora
  // riferito a QUESTA eccezione. zExceptions.firedac.CaptureFailedDataSet lo
  // ha valorizzato nell'OnError della connessione, che scatta prima che
  // l'eccezione arrivi ad Application.OnException.
  FFailedDataSetDump := zExceptions.context.TakeLastFailedDataSetDump;
  FFailedDataSetName := zExceptions.context.TakeLastFailedDataSetName;
  FFailedDataSetDataModuleName := zExceptions.context.TakeLastFailedDataSetDataModuleName;
  FFailedDataSetOwnerModuleName := zExceptions.context.TakeLastFailedDataSetOwnerModuleName;
  FFailedDataSetId := zExceptions.context.TakeLastFailedDataSetId;

  Logged := false;
  FTicketId := 0;
  FRichiestaButton := nil;
  FE := E;

  FIsFIBError := E is EIBNativeException;

  if IsFIBError then
  begin
    IBNativeException := EIBNativeException(E);
    FErrorMessage := TranslateFIBError(IBNativeException);
    FIBErrorCode := IBNativeException.ErrorCode; // IBErrorCode;
    FIBMessage := IBNativeException.Message; // IBMessage;
    FSQLCode := IBNativeException.errors[0].SQLCode; // SQLCode;
    FSQLMessage := IBNativeException.Message; // SQLMessage;
    FSQLState := IBNativeException.errors[0].SQLState;
  end
  else
  begin
    FErrorMessage := E.Message;

    if isUTF8String(FErrorMessage) then
      FErrorMessage := UTF8ToString(FErrorMessage);

    FIBErrorCode := -1;
    FIBMessage := '';
    FSQLCode := -1;
    FSQLMessage := '';
    FSQLState := '';
  end;

  FStack := TCallStack.Create(E);
end;

destructor TzExceptionManager.Destroy;
begin
  FreeAndNil(FShot);
  FreeAndNil(FStack);
  inherited;
end;

procedure TzExceptionManager.LogException(FileName: string);
var
  destLog, destPng: string;
begin
  LogToSmartInspect;

  if FileName.IsEmpty then
  begin
    // PRIMA generazione (chiamata da ShowException): crea i file con nome
    // auto-calcolato e registra i path, cosi' il Salva potra' riusarli.
    FLogFile := LogFileName;
    FPngFile := PngFileName(FLogFile);

    SaveToFile(FLogFile);

    // Salva lo screenshot GIA' catturato nel costruttore (nessun dialog a
    // video). Non si ri-scatta: l'immagine resta pulita.
    try
      SaveShot(FPngFile);
    except
      on Ex: Exception do
      begin
        FPngFile := '';
        try
          TFile.AppendAllText(FLogFile, sLineBreak + 'SCREENSHOT FALLITO: ' + Ex.ClassName + ' - ' + Ex.Message + sLineBreak);
        except
        end;
      end;
    end;

    // Pulizia file vecchi: subito dopo aver scritto i nuovi.
    try
      PurgeOldLogs;
    except
    end;
  end
  else
  begin
    // SALVA: non rigenerare nulla, copia i file gia' creati verso la
    // destinazione scelta dall'utente.
    if (FLogFile = '') or not TFile.Exists(FLogFile) then
      Exit;

    destLog := TPath.ChangeExtension(FileName, LogExtension);
    TFile.Copy(FLogFile, destLog, True);

    if (FPngFile <> '') and TFile.Exists(FPngFile) then
    begin
      destPng := PngFileName(destLog);
      TFile.Copy(FPngFile, destPng, True);
    end;
  end;
end;

function TzExceptionManager.LogFolderPath: string;
begin
  result := LogFolder;
  if result.IsEmpty then
    result := IncludeTrailingPathDelimiter(ExtractFilePath(System.SysUtils.GetModuleName(HInstance))) + 'log';
  result := IncludeTrailingPathDelimiter(result);
  ForceDirectories(result);
end;

function TzExceptionManager.LogFileName: string;
begin
  result := '';
  DateTimeToString(result, 'yyyymmdd hhmmss', now);
  result := result + ' - ' + UserName;
  result := LogFolderPath + TPath.ChangeExtension(result, LogExtension);
end;

procedure TzExceptionManager.PurgeOldLogs;
var
  folder, f, png: string;
  limit: TDateTime;
begin
  if LogRetentionDays <= 0 then
    Exit;

  folder := LogFolderPath;
  limit := now - LogRetentionDays;

  for f in TDirectory.GetFiles(folder, '*' + LogExtension) do
  begin
    if TFile.GetLastWriteTime(f) < limit then
    begin
      // Cancella il .log e il .png con lo stesso nome.
      png := PngFileName(f);
      try
        TFile.Delete(f);
      except
      end;
      if TFile.Exists(png) then
        try
          TFile.Delete(png);
        except
        end;
    end;
  end;
end;

procedure TzExceptionManager.LogToSmartInspect;
begin
  if Logged then
    Exit;

  try
    siMain.LogException(E);
    siMain.LogException(E.StackTrace);
  except
  end;
  Logged := True;
end;

function TzExceptionManager.PngFileName(const FileName: string): string;
begin
  result := ChangeFileExt(FileName, PngExtension);
end;

procedure TzExceptionManager.SaveToFile(const FileName: string);

  // Coppia nome/valore incolonnata. AddPair scrive "Nome=Valore" senza
  // allineamento: con nomi di lunghezza diversa l'occhio non trova piu' la
  // colonna dei valori.
  procedure AddValore(SL: TStringList; const ANome, AValore: string);
  begin
    SL.Add(Format('%-16s = %s', [ANome, AValore]));
  end;

  // Testo multi-riga (messaggio d'errore, messaggio Firebird) indentato
  // sotto la propria sezione, senza righe vuote di coda.
  procedure AddTesto(SL: TStringList; const ATesto: string);
  begin
    if ATesto.Trim.IsEmpty then
      SL.Add('    (non disponibile)')
    else
      SL.Add('    ' + StringReplace(ATesto.TrimRight, sLineBreak, sLineBreak + '    ', [rfReplaceAll]));
  end;

var
  StringList: TStringList;
  item: TCallStackItem;
begin
  if FileName.IsEmpty then
    Exit;

  try
    StringList := TStringList.Create;
    try
      AppendSezione(StringList, 'SEGNALAZIONE');
      AddValore(StringList, 'DB', DbName);
      AddValore(StringList, 'Data', DateTimeToStr(now));
      AddValore(StringList, 'Utente', UserName);
      AddValore(StringList, 'Modulo', ModuleName);
      AddValore(StringList, 'Eseguibile', ModulePath);
      AddValore(StringList, 'Versione', VersionInfo);
      AddValore(StringList, 'ComputerName', ComputerName);
      AddValore(StringList, 'DPI', Screen.PrimaryMonitor.PixelsPerInch.ToString);

      AppendSezione(StringList, 'ERRORE');
      AddTesto(StringList, ErrorMessage);

      // Il dettaglio Firebird si scrive solo quando l'errore viene davvero
      // dal database: sulle eccezioni applicative erano sei righe di
      // segnaposto (-1, vuoto) che facevano solo rumore.
      if IsFIBError then
      begin
        AppendSezione(StringList, 'DETTAGLIO FIREBIRD');
        AddValore(StringList, 'IBErrorCode', IBErrorCode.ToString);
        AddValore(StringList, 'SQLCode', SQLCode.ToString);
        AddValore(StringList, 'SQLState', SQLState);
        StringList.Add('');
        StringList.Add('IBMessage:');
        AddTesto(StringList, IBMessage);
        if not SameText(SQLMessage.Trim, IBMessage.Trim) then
        begin
          StringList.Add('');
          StringList.Add('SQLMessage:');
          AddTesto(StringList, SQLMessage);
        end;
      end
      else
      begin
        AppendSezione(StringList, 'DETTAGLIO FIREBIRD');
        StringList.Add('    (non e'' un errore del database)');
      end;

      AppendSezione(StringList, 'STACK DI CHIAMATA');
      StringList.Add(item.Titles);
      for item in stack do
        if not item.SymbolName.IsEmpty then
          StringList.Add(item.ToString);

      StringList.Add(CollectRuntimeContext(FCapturedForm, FCapturedControl, FFailedDataSetDump));

      StringList.SaveToFile(FileName);
    finally
      FreeAndNil(StringList);
    end;
  except
  end;
end;

procedure TzExceptionManager.CaptureShot;
var
  c: TCanvas;
  src, dst: TRect;
  w, h: integer;
begin
  // Determina il rettangolo da catturare (monitor della form che ha
  // generato l'errore). Se degenere, ripiega sul monitor primario.
  src := FCapturedMonitor;
  if (src.Right - src.Left <= 0) or (src.Bottom - src.Top <= 0) then
    src := Screen.PrimaryMonitor.BoundsRect;
  w := src.Right - src.Left;
  h := src.Bottom - src.Top;
  if (w <= 0) or (h <= 0) then
    Exit;

  c := TCanvas.Create;
  try
    c.Handle := GetDC(0); // DC dell'intero virtual screen (multi-monitor)
    try
      dst := Rect(0, 0, w, h);
      FreeAndNil(FShot);
      FShot := TBitMap.Create;
      FShot.Width := w;
      FShot.Height := h;
      // CopyRect(dest, sourceCanvas, sourceRect): sorgente in coord. schermo
      FShot.Canvas.CopyRect(dst, c, src);
    finally
      ReleaseDC(0, c.Handle);
    end;
  finally
    c.Free;
  end;
end;

procedure TzExceptionManager.SaveShot(const FileName: string);
var
  png: TPNGImage;
begin
  if FShot = nil then
    raise Exception.Create('Screenshot non disponibile (cattura fallita).');

  png := TPNGImage.Create;
  try
    png.Assign(FShot);
    png.SaveToFile(FileName);
  finally
    FreeAndNil(png);
  end;
end;

procedure TzExceptionManager.ShowException;

  procedure doBeforeException;
  begin
    if assigned(OnBeforeException) then
      OnBeforeException;
  end;
  procedure doAfterException;
  begin
    if assigned(OnAfterException) then
      OnAfterException;
  end;

var
  dlg: TdxMessageDialogForm;
  RichiestaEnabled: boolean;
  Buttons: TMsgDlgButtons;

begin
  try
    StopWait;
    LogToSmartInspect;

    doBeforeException;
    try
      RichiestaEnabled := RichiestaAssistenzaDisponibile;

      // Genera log + screenshot e registra i path PRIMA di mostrare il
      // dialog (immagine senza dialog sopra). Il Salva riusa questi file.
      LogException('');

      if RichiestaEnabled then
        Buttons := mbYesNoCancel
      else
        Buttons := mbYesNo;

      dlg := dxCreateMessageDialog(ErrorMessage, mtCustom, Buttons);
      try
        TdxMessageDialogFormHach(dlg).InitializeIcon(mtError);
        dlg.lcIcon.Visible := True;

        // Dettagli e Richiedi assistenza sostituiscono l'OnClick standard del
        // dialogo (TdxMessageDialogForm.ButtonClick, che imposta ModalResult):
        // il messaggio quindi resta aperto e l'utente puo' usarli entrambi.
        dlg.FindButton(mbYes).Caption := 'Dettagli';
        dlg.FindButton(mbYes).OnClick := DettagliClick;

        if RichiestaEnabled then
        begin
          FRichiestaButton := dlg.FindButton(mbNo);
          dlg.FindButton(mbNo).Caption := CaptionRichiestaAssistenza;
          dlg.FindButton(mbNo).OnClick := RichiestaAssistenzaClick;
        end;

        if RichiestaEnabled then
          dlg.FindButton(mbCancel).Caption := 'Chiudi'
        else
          dlg.FindButton(mbNo).Caption := 'Chiudi';

        dlg.AlignButtons; // Recalculates the button layout
        dlg.ShowModal; // Invokes the form as a modal dialog
      finally
        // Il pulsante muore con il dialogo: la form di dettaglio non deve
        // piu' poterlo toccare.
        FRichiestaButton := nil;
        dlg.Free; // Releases the message box when a user closes it
      end;
    finally
      doAfterException;
    end;
  except
  end;
end;

procedure TzExceptionManager.DettagliClick(Sender: TObject);
begin
  ShowExceptionDetails(Self);
end;

procedure TzExceptionManager.RichiestaAssistenzaClick(Sender: TObject);
begin
  RichiediAssistenza;
end;

function TzExceptionManager.RichiestaAssistenzaDisponibile: boolean;
begin
  result := TzExceptionManager.SMTPServerParams.IsValid or TzExceptionManager.MantisServerParams.IsValid;
end;

function TzExceptionManager.RichiediAssistenza: boolean;
var
  note: string;
begin
  result := False;

  // Ticket gia' aperto per questo stesso errore (dal messaggio o dalla form
  // di dettaglio): un secondo ticket sarebbe un doppione per l'assistenza.
  if FTicketId > 0 then
  begin
    ConfirmOk(Format('Per questo errore e'' gia'' stata aperta la richiesta di assistenza n. %d.', [FTicketId]));
    Exit(True);
  end;

  if not AskReportNote(note) then
    Exit;

  if TzExceptionManager.MantisServerParams.IsValid then
    result := InviaMantis(note);

  // Se la richiesta e' gia' arrivata su Mantis, la mail sarebbe
  // ridondante: si invia solo come ripiego (Mantis non configurato o
  // apertura ticket fallita).
  if TzExceptionManager.SMTPServerParams.IsValid and not result then
    InviaMail(note);

  if result and Assigned(FRichiestaButton) then
    FRichiestaButton.Enabled := False;
end;

function TzExceptionManager.AskReportNote(out aNote: string): boolean;
var
  sl: TStringList;
begin
  aNote := '';
  sl := TStringList.Create;
  try
    // Il titolo della finestra e' l'unica indicazione che l'utente riceve su
    // cosa scrivere: una nota che dice cosa si stava facendo vale piu' dello
    // stack. Breve, perche' la barra del titolo non lo tronchi.
    result := zExecuteMemoDialog(sl, CaptionRichiestaAssistenza + ' - cosa stavi facendo?');
    if result then
      aNote := sl.Text;
  finally
    FreeAndNil(sl);
  end;
end;

function TzExceptionManager.ResolveModuleTag: string;
begin
  // 1) form attiva, se discende da TBaseForm (caso tipico: errore durante
  // un'azione utente). "TFormRisorse" -> "Risorse".
  result := '';
  if FCapturedForm <> nil then
    result := zExceptions.context.ModuleNameFromClass(FCapturedForm.ClassType,
      zExceptions.context.BaseFormClassName);

  // 2) fallback: datamodule proprietario del dataset/comando che ha
  // generato l'errore (caso tipico: operazione di sfondo/schedulata senza
  // una form applicativa in primo piano). Valorizzato da
  // zExceptions.firedac.CaptureFailedDataSet, PRIMA che questo oggetto
  // venga costruito (l'OnError della connessione scatta prima che
  // l'eccezione arrivi ad Application.OnException).
  if result = '' then
    result := FFailedDataSetOwnerModuleName;

  // Altrimenti (nessuna form/datamodule applicativo riconoscibile): nessun
  // tag, il ticket resta con la sola categoria di default (General).
end;

procedure TzExceptionManager.InviaMail;
var
  note: string;
begin
  if not AskReportNote(note) then
    Exit;
  InviaMail(note);
end;

procedure TzExceptionManager.InviaMail(const aNote: string);
var
  Mail: TMail;
  tmpFileName: String;
  Corpo: TStringList;
begin
  Mail.Init;
  try
    tmpFileName := TPath.GetTempFileName;
    try
      if TFile.Exists(tmpFileName) then
        TFile.Delete(tmpFileName);

      tmpFileName := TPath.ChangeExtension(tmpFileName, LogExtension);

      SaveToFile(tmpFileName);
      try
        SaveShot(PngFileName(tmpFileName));
      except
      end;

      Mail.A := MailAddress;
      Mail.Oggetto := 'Segnalazione da ' + UserName;

      Corpo := TStringList.Create;
      try
        Corpo.Text := aNote;
        Corpo.Add('');
        Corpo.Add(''.PadLeft(80, '_'));
        Corpo.Add('');
        Corpo.AddPair('DB', DbName);
        Corpo.AddPair('UserName', UserName);
        Corpo.AddPair('User Email', UserEmail);
        Corpo.Add('');
        Corpo.AddPair('Data', DateTimeToStr(now));
        Corpo.AddPair('Utente Sistema', SysUserName);
        Corpo.AddPair('Modulo', ModuleName);
        Corpo.AddPair('Versione', VersionInfo);
        Corpo.AddPair('ComputerName', ComputerName);
        Corpo.AddPair('DPI', Screen.PrimaryMonitor.PixelsPerInch.ToString);
        Corpo.Add('');
        Corpo.Add(''.PadLeft(80, '_'));
        Corpo.Add('');
        Corpo.Add(ErrorMessage);
        Mail.CorpoTxt := Corpo.Text;
      finally
        FreeAndNil(Corpo);
      end;

      Mail.Allegati := tmpFileName + ';' + PngFileName(tmpFileName);

      WriteMail(Mail, TzExceptionManager.SMTPServerParams,
        procedure(StringList: TStringList)
        begin
          StringList.AddPair(MailAddress, 'Assistenza');
        end);
    finally
      TFile.Delete(tmpFileName);
    end;
  except
  end;
end;

function TzExceptionManager.BuildMantisSummary: string;
const
  // MantisBT tronca il campo summary: si resta sotto il limite standard.
  MaxSummaryLength = 120;
var
  Prefisso: string;
  Messaggio: string;
begin
  // Oggetto del ticket = "[<eseguibile> - <utente>] <messaggio d'errore>".
  //
  // Il nome del cliente/database NON va ripetuto qui: MantisBT antepone gia'
  // da solo il nome del progetto nell'oggetto della mail di notifica, e il
  // progetto e' proprio il cliente/database (vedi InviaMantis: ProjectName =
  // ClientName, con fallback su DbName). L'oggetto che arriva in casella e'
  // quindi gia' completo:
  //
  //   [CAPAC 0000123]: [Gesty.exe - MRossi] Access violation at address ...
  //
  // Se l'utente applicativo non e' ancora noto (eccezione prima del login)
  // resta il solo nome dell'eseguibile, come prima.
  Prefisso := '[' + ModuleName;
  if UserName.Trim <> '' then
    Prefisso := Prefisso + ' - ' + UserName.Trim;
  Prefisso := Prefisso + '] ';

  Messaggio := ErrorMessage.Replace(#13, ' ').Replace(#10, ' ').Trim;

  // Si tronca il totale, non il solo messaggio: il prefisso e' corto e deve
  // sopravvivere comunque.
  result := Copy(Prefisso + Messaggio, 1, MaxSummaryLength);
end;

function TzExceptionManager.InviaMantis(const aNote: string): boolean;
var
  report: TMantisReport;
  desc: TStringList;
  proj: string;
  atts: TArray<string>;
  issueId: integer;
  moduleTag: string;
begin
  result := False;

  // Messaggi rivolti all'utente finale: "Mantis" per lui non significa nulla.
  StartWait('Invio della richiesta di assistenza...');
  try
    try
      // Progetto = cliente/ente; fallback su DbName.
      proj := ClientName;
      if proj.Trim = '' then
        proj := DbName;

      desc := TStringList.Create;
      try
        if aNote.Trim <> '' then
        begin
          desc.Add(aNote);
          desc.Add('');
          desc.Add(''.PadLeft(60, '_'));
          desc.Add('');
        end;
        desc.AddPair('DB', DbName);
        desc.AddPair('Utente', UserName);
        desc.AddPair('Email utente', UserEmail);
        desc.AddPair('Utente sistema', SysUserName);
        desc.AddPair('Computer', ComputerName);
        desc.AddPair('Modulo', ModuleName);
        desc.AddPair('Versione', VersionInfo);
        desc.AddPair('Data', DateTimeToStr(now));
        desc.AddPair('DPI', Screen.PrimaryMonitor.PixelsPerInch.ToString);
        desc.Add('');
        desc.Add(''.PadLeft(60, '_'));
        desc.Add('');
        desc.Add('Errore:');
        desc.Add(ErrorMessage);
        if IsFIBError then
        begin
          desc.Add('');
          desc.AddPair('IBErrorCode', IBErrorCode.ToString);
          desc.AddPair('SQLCode', SQLCode.ToString);
          desc.AddPair('SQLState', SQLState);
          desc.AddPair('IBMessage', IBMessage);
        end;
        report.Description := desc.Text;
      finally
        FreeAndNil(desc);
      end;

      report.ProjectName := proj;
      report.ReporterUser := UserName;
      report.ReporterEmail := UserEmail;
      report.ReporterRealName := UserName;
      report.Summary := BuildMantisSummary;

      // Categoria = nome del form/datamodule applicativo coinvolto (es.
      // "Risorse"), se riconoscibile (vedi ResolveModuleTag per l'ordine di
      // risoluzione: form TBaseForm, poi datamodule TBaseDataModule). Non
      // viene MAI creata una nuova categoria: SegnalaSuMantis la usa solo se
      // esiste gia' nel progetto Mantis, altrimenti ripiega sulla categoria
      // di default (General). Nessun tag viene piu' applicato al ticket.
      moduleTag := ResolveModuleTag;
      report.Category := moduleTag;

      // Allegati: i file gia' generati da ShowException (LogException('')).
      atts := [];
      if (FLogFile <> '') and TFile.Exists(FLogFile) then
        atts := atts + [FLogFile];
      if (FPngFile <> '') and TFile.Exists(FPngFile) then
        atts := atts + [FPngFile];
      report.Attachments := atts;

      issueId := SegnalaSuMantis(TzExceptionManager.MantisServerParams, report);
      FTicketId := issueId;

      // Registrazione locale del ticket: un errore qui non deve annullare
      // una richiesta di assistenza gia' arrivata su Mantis.
      if Assigned(TzExceptionManager.OnTicketAperto) then
        try
          TzExceptionManager.OnTicketAperto(issueId, report.Summary);
        except
          on ExRegistrazione: Exception do
            siMain.LogException(ExRegistrazione);
        end;

      result := True;
    except
      on Ex: Exception do
        ConfirmOk('Invio della richiesta di assistenza non riuscito:'#13#10 + Ex.Message, mtError);
    end;
  finally
    StopWait;
  end;

  if result then
    ConfirmOk(Format('Richiesta di assistenza registrata.'#13#10'Numero: %d', [issueId]));
end;

end.
