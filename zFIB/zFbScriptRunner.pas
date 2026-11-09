unit zFbScriptRunner;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions, System.StrUtils,
  System.Diagnostics,
  FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands, FireDAC.Stan.Intf,
  FireDAC.Comp.Client;

type
  /// Azione da intraprendere dopo un errore su un singolo comando
  TzScriptErrorAction = (eaAbort, eaSkip, eaRetry);

  /// Chi controlla la transazione durante l'esecuzione dello script
  ///   tmAutoCommit      : commit dopo ogni comando
  ///   tmScriptControlled: COMMIT/ROLLBACK nello script pilotano la transazione
  ///                       (commit finale implicito)
  ///   tmExternal        : il runner non tocca mai la transazione; i COMMIT
  ///                       incontrati vengono solo notificati
  TzScriptTxMode = (tmAutoCommit, tmScriptControlled, tmExternal);

  /// Categorie di messaggi emesse su OnMessage
  TzScriptMessageKind = (mkEcho, mkFeedback, mkSkipped, mkTiming, mkError);
  TzScriptMessages = set of TzScriptMessageKind;

  TzScriptMessageEvent = procedure(Sender: TObject;
    Kind: TzScriptMessageKind; const Text: string) of object;

  TzScriptErrorEvent = procedure(Sender: TObject; const Command: string;
    E: Exception; var Action: TzScriptErrorAction) of object;

  TzScriptProgressEvent = procedure(Sender: TObject; Index, Total: Integer;
    const Command: string) of object;

  /// Consente all'applicazione di intercettare direttive non SQL
  /// (SET SQL DIALECT, CONNECT, INPUT, comandi proprietari...).
  /// Handled=True significa "l'ho gestita io, non passarla a FireDAC".
  TzScriptCustomCommandEvent = procedure(Sender: TObject;
    const Command: string; var Handled: Boolean) of object;

  /// Esito complessivo di una esecuzione
  TzScriptResult = record
    Total: Integer;
    Executed: Integer;
    Skipped: Integer;
    Failed: Integer;
    Aborted: Boolean;
    ElapsedMs: Int64;
    LastError: string;
    function Succeeded: Boolean;
  end;

  /// Preprocessore + esecutore di script generati da IBExpert / FlameRobin:
  /// gestisce SET TERM, COMMIT/ROLLBACK inline, direttive isql non supportate,
  /// commenti -- e nidificati /* */ con rispetto dei letterali.
  /// Ogni comando gia' isolato viene eseguito atomicamente con una TFDQuery
  /// interna a preprocessing spento: TFDScript non va usato perche' rispezza
  /// il testo al primo ';' interno ai corpi PSQL.
  TzFbScriptRunner = class(TComponent)
  private
    FScript: TFDScript;
    FExecuteQuery: TFDQuery;
    FConnection: TFDConnection;
    FTransaction: TFDTransaction;
    FOwnTransaction: TFDTransaction;
    FDefaultTerminator: string;
    FCurrentTerminator: string;
    FTxMode: TzScriptTxMode;
    FStopOnError: Boolean;
    FSkipUnsupportedDirectives: Boolean;
    FMessages: TzScriptMessages;
    FCommands: TStringList;
    FAborted: Boolean;
    FRunning: Boolean;
    FResult: TzScriptResult;
    FOnMessage: TzScriptMessageEvent;
    FOnError: TzScriptErrorEvent;
    FOnProgress: TzScriptProgressEvent;
    FOnCustomCommand: TzScriptCustomCommandEvent;
    FOnBeforeExecute: TNotifyEvent;
    FOnAfterExecute: TNotifyEvent;
    procedure Say(Kind: TzScriptMessageKind; const Text: string);
    function StripComments(const Text: string): string;
    function IsUnsupportedDirective(const Command: string): Boolean;
    procedure SplitIntoCommands(const Text: string);
    function ActiveTransaction: TFDTransaction;
    procedure PrepareExecution;
    function ExecuteSingle(const Command: string): Boolean;
    function GetCurrentTerminator: string;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ExecuteText(const Text: string): TzScriptResult;
    /// Encoding nil = UTF-8
    function ExecuteFile(const FileName: string; const Encoding: TEncoding = nil): TzScriptResult;
    /// Solo preprocessing: utile per anteprima/diagnostica senza toccare il DB
    procedure ParseOnly(const Text: string; ADest: TStrings);
    procedure Abort;

    property Aborted: Boolean read FAborted;
    property Running: Boolean read FRunning;
    property CurrentTerminator: string read GetCurrentTerminator;
    property LastResult: TzScriptResult read FResult;
  published
    /// Facoltativa: usata solo come ripiego per ricavare la Connection
    property Script: TFDScript read FScript write FScript;
    property Connection: TFDConnection read FConnection write FConnection;
    /// Se assegnata viene usata questa, altrimenti quella della Connection
    property Transaction: TFDTransaction read FTransaction write FTransaction;
    property DefaultTerminator: string read FDefaultTerminator write FDefaultTerminator;
    property TransactionMode: TzScriptTxMode read FTxMode write FTxMode
      default tmScriptControlled;
    property StopOnError: Boolean read FStopOnError write FStopOnError default True;
    property SkipUnsupportedDirectives: Boolean read FSkipUnsupportedDirectives
      write FSkipUnsupportedDirectives default True;
    property Messages: TzScriptMessages read FMessages write FMessages;

    property OnMessage: TzScriptMessageEvent read FOnMessage write FOnMessage;
    property OnError: TzScriptErrorEvent read FOnError write FOnError;
    property OnProgress: TzScriptProgressEvent read FOnProgress write FOnProgress;
    property OnCustomCommand: TzScriptCustomCommandEvent read FOnCustomCommand
      write FOnCustomCommand;
    property OnBeforeExecute: TNotifyEvent read FOnBeforeExecute write FOnBeforeExecute;
    property OnAfterExecute: TNotifyEvent read FOnAfterExecute write FOnAfterExecute;
  end;

implementation

const
  DEFAULT_TERMINATOR = ';';

{ TzScriptResult }

function TzScriptResult.Succeeded: Boolean;
begin
  Result := (Failed = 0) and (not Aborted);
end;

{ TzFbScriptRunner }

constructor TzFbScriptRunner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommands := TStringList.Create;
  FDefaultTerminator := DEFAULT_TERMINATOR;
  FCurrentTerminator := DEFAULT_TERMINATOR;
  FTxMode := tmScriptControlled;
  FStopOnError := True;
  FSkipUnsupportedDirectives := True;
  FMessages := [mkFeedback, mkSkipped, mkError];
end;

destructor TzFbScriptRunner.Destroy;
begin
  FCommands.Free;
  inherited;
end;

procedure TzFbScriptRunner.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FScript then FScript := nil;
    if AComponent = FConnection then FConnection := nil;
    if AComponent = FTransaction then FTransaction := nil;
  end;
end;

function TzFbScriptRunner.GetCurrentTerminator: string;
begin
  Result := FCurrentTerminator;
end;

procedure TzFbScriptRunner.Say(Kind: TzScriptMessageKind; const Text: string);
begin
  if Assigned(FOnMessage) and (Kind in FMessages) then
    FOnMessage(Self, Kind, Text);
end;

procedure TzFbScriptRunner.Abort;
begin
  FAborted := True;
end;

// --- preprocessing ----------------------------------------------------------

/// Rimuove commenti di riga (--) e di blocco (/* */, nidificati come in FB 4+)
/// senza toccare il contenuto dei letterali stringa e degli identificatori
/// delimitati da doppi apici.
function TzFbScriptRunner.StripComments(const Text: string): string;
var
  I, Len, Depth: Integer;
  InString, InQuoted, InLineComment: Boolean;
  Buffer: TStringBuilder;
  C, Nxt: Char;
begin
  Buffer := TStringBuilder.Create;
  try
    InString := False;
    InQuoted := False;
    InLineComment := False;
    Depth := 0;
    Len := Length(Text);
    I := 1;
    while I <= Len do
    begin
      C := Text[I];
      if I < Len then Nxt := Text[I + 1] else Nxt := #0;

      if InLineComment then
      begin
        if CharInSet(C, [#10, #13]) then
        begin
          InLineComment := False;
          Buffer.Append(C);
        end;
      end
      else if Depth > 0 then
      begin
        if (C = '/') and (Nxt = '*') then
        begin
          Inc(Depth);
          Inc(I);
        end
        else if (C = '*') and (Nxt = '/') then
        begin
          Dec(Depth);
          Inc(I);
        end
        else if CharInSet(C, [#10, #13]) then
          // conserva i fine riga: i numeri di riga restano allineati
          Buffer.Append(C);
      end
      else if InString then
      begin
        Buffer.Append(C);
        if C = '''' then
          if Nxt = '''' then
          begin
            Buffer.Append(Nxt);
            Inc(I);
          end
          else
            InString := False;
      end
      else if InQuoted then
      begin
        Buffer.Append(C);
        if C = '"' then InQuoted := False;
      end
      else
      begin
        if C = '''' then
        begin
          InString := True;
          Buffer.Append(C);
        end
        else if C = '"' then
        begin
          InQuoted := True;
          Buffer.Append(C);
        end
        else if (C = '-') and (Nxt = '-') then
        begin
          InLineComment := True;
          Inc(I);
        end
        else if (C = '/') and (Nxt = '*') then
        begin
          Depth := 1;
          Inc(I);
          // DIV-SCR-3: al posto del commento resta uno spazio, cosi' le parole accanto non si incollano
          Buffer.Append(' ');
        end
        else
          Buffer.Append(C);
      end;
      Inc(I);
    end;
    Result := Buffer.ToString;
  finally
    Buffer.Free;
  end;
end;

function TzFbScriptRunner.IsUnsupportedDirective(const Command: string): Boolean;
var
  Head: string;
begin
  Head := UpperCase(TrimLeft(Command));
  Result :=
    StartsText('SET SQL DIALECT', Head) or
    StartsText('SET AUTODDL', Head) or
    StartsText('SET NAMES', Head) or
    StartsText('SET CLIENTLIB', Head) or
    StartsText('SET STATS', Head) or
    // SET STATISTICS INDEX e' un comando reale del server, il resto e' isql
    (StartsText('SET STATISTICS', Head) and (not StartsText('SET STATISTICS INDEX', Head))) or
    StartsText('SET COUNT', Head) or
    StartsText('SET ECHO', Head) or
    StartsText('SET PLAN', Head) or
    StartsText('SET LIST', Head) or
    StartsText('SET BLOBDISPLAY', Head) or
    StartsText('SET HEADING', Head) or
    StartsText('SET BAIL', Head) or
    // SET TIME ZONE e' un comando reale di Firebird 4 e successivi (DIV-SCR-2)
    (StartsText('SET TIME', Head) and (not StartsText('SET TIME ZONE', Head))) or
    StartsText('CONNECT ', Head) or
    StartsText('CREATE DATABASE', Head) or
    StartsText('DROP DATABASE', Head) or
    StartsText('SHOW ', Head) or
    StartsText('INPUT ', Head) or
    StartsText('OUTPUT ', Head) or
    StartsText('QUIT', Head) or
    StartsText('EXIT', Head) or
    StartsText('HELP', Head);
end;

/// Spezza il testo nei singoli comandi rispettando il terminatore corrente,
/// che SET TERM puo' cambiare a runtime. I letterali stringa e gli
/// identificatori tra doppi apici sono opachi rispetto al terminatore.
procedure TzFbScriptRunner.SplitIntoCommands(const Text: string);
var
  I, Len, TermLen: Integer;
  InString, InQuoted: Boolean;
  // DIV-SCR-6: vero se il comando in costruzione contiene almeno un carattere
  // non vuoto; evita di ricostruire e potare il testo accumulato a ogni carattere
  HaContenuto: Boolean;
  Buffer: TStringBuilder;
  NewTerm, Rest: string;
  Match: TMatch;

  procedure Flush;
  var
    S: string;
  begin
    S := Trim(Buffer.ToString);
    Buffer.Clear;
    HaContenuto := False;
    if S <> '' then FCommands.Add(S);
  end;

begin
  FCommands.Clear;
  FCurrentTerminator := FDefaultTerminator;
  if FCurrentTerminator = '' then FCurrentTerminator := DEFAULT_TERMINATOR;

  Buffer := TStringBuilder.Create;
  try
    InString := False;
    InQuoted := False;
    HaContenuto := False;
    Len := Length(Text);
    I := 1;
    while I <= Len do
    begin
      // SET TERM riconosciuto solo a inizio comando e fuori da letterali:
      // cosi' la stringa 'SET TERM ^' dentro un INSERT non altera lo split
      if (not InString) and (not InQuoted) and (not HaContenuto) then
      begin
        Rest := Copy(Text, I, 128);
        Match := TRegEx.Match(Rest, '^\s*SET\s+TERM\s+(\S+)\s*', [roIgnoreCase]);
        if Match.Success then
        begin
          NewTerm := Match.Groups[1].Value;
          Inc(I, Match.Length);
          // il vecchio terminatore chiude la direttiva: "SET TERM ^ ;"
          if StartsStr(FCurrentTerminator, Copy(Text, I, Length(FCurrentTerminator))) then
            Inc(I, Length(FCurrentTerminator))
          else if EndsStr(FCurrentTerminator, NewTerm) and
                  (Length(NewTerm) > Length(FCurrentTerminator)) then
            // forma compatta "SET TERM ^;"
            SetLength(NewTerm, Length(NewTerm) - Length(FCurrentTerminator));
          if NewTerm <> '' then FCurrentTerminator := NewTerm;
          Buffer.Clear;
          HaContenuto := False;
          Continue;
        end;
      end;

      if InString then
      begin
        Buffer.Append(Text[I]);
        if Text[I] = '''' then
        begin
          if (I < Len) and (Text[I + 1] = '''') then
          begin
            Buffer.Append(Text[I + 1]);
            Inc(I);
          end
          else
            InString := False;
        end;
        Inc(I);
        Continue;
      end;

      if InQuoted then
      begin
        Buffer.Append(Text[I]);
        if Text[I] = '"' then InQuoted := False;
        Inc(I);
        Continue;
      end;

      if Text[I] = '''' then
      begin
        InString := True;
        HaContenuto := True;
        Buffer.Append(Text[I]);
        Inc(I);
        Continue;
      end;

      if Text[I] = '"' then
      begin
        InQuoted := True;
        HaContenuto := True;
        Buffer.Append(Text[I]);
        Inc(I);
        Continue;
      end;

      TermLen := Length(FCurrentTerminator);
      if (TermLen > 0) and SameText(Copy(Text, I, TermLen), FCurrentTerminator) then
      begin
        Flush;
        Inc(I, TermLen);
        Continue;
      end;

      // stessa soglia di Trim: i caratteri fino allo spazio non fanno contenuto
      if Text[I] > ' ' then
        HaContenuto := True;
      Buffer.Append(Text[I]);
      Inc(I);
    end;
    Flush;
  finally
    Buffer.Free;
  end;
end;

procedure TzFbScriptRunner.ParseOnly(const Text: string; ADest: TStrings);
begin
  SplitIntoCommands(StripComments(Text));
  ADest.Assign(FCommands);
end;

// --- esecuzione -------------------------------------------------------------

function TzFbScriptRunner.ActiveTransaction: TFDTransaction;
begin
  if Assigned(FTransaction) then
    Result := FTransaction
  else if Assigned(FConnection) then
  begin
    Result := FConnection.Transaction as TFDTransaction;
    // DIV-SCR-8: senza nessuna transazione il runner ne usa una sua, cosi' COMMIT, ROLLBACK
    // e il rollback dopo un errore funzionano
    if not Assigned(Result) then
    begin
      if not Assigned(FOwnTransaction) then
        FOwnTransaction := TFDTransaction.Create(Self);
      FOwnTransaction.Connection := FConnection;
      Result := FOwnTransaction;
    end;
  end
  else
    Result := nil;
end;

procedure TzFbScriptRunner.PrepareExecution;
begin
  if not Assigned(FConnection) and Assigned(FScript) and Assigned(FScript.Connection) then
    FConnection := FScript.Connection as TFDConnection;
  if not Assigned(FConnection) then
    raise Exception.Create('Proprieta'' Connection non assegnata');
  if not FConnection.Connected then FConnection.Open;

  if not Assigned(FExecuteQuery) then
  begin
    FExecuteQuery := TFDQuery.Create(Self);
    // il comando va eseguito cosi' com'e': i corpi PSQL contengono ':variabile'
    // e ';' che il preprocessing FireDAC interpreterebbe come parametri o
    // separatori di comando
    FExecuteQuery.ResourceOptions.ParamCreate := False;
    FExecuteQuery.ResourceOptions.MacroCreate := False;
    FExecuteQuery.ResourceOptions.PreprocessCmdText := False;
  end;
  FExecuteQuery.Connection := FConnection;
end;

/// Esegue un singolo comando tramite la TFDQuery interna (DIV-SCR-7: non passa
/// da TFDScript, che non si usa qui). Ritorna False se il chiamante
/// deve interrompere (StopOnError senza handler, oppure eaAbort dall'evento).
function TzFbScriptRunner.ExecuteSingle(const Command: string): Boolean;
var
  Action: TzScriptErrorAction;
  Watch: TStopwatch;
begin
  Result := True;
  repeat
    Action := eaAbort;
    try
      Watch := TStopwatch.StartNew;
      // esecuzione atomica del singolo comando: nessun nuovo split sui ';'
      FExecuteQuery.Transaction := ActiveTransaction;
      FExecuteQuery.SQL.Text := Command;
      FExecuteQuery.ExecSQL;
      Watch.Stop;
      Inc(FResult.Executed);
      Say(mkFeedback, 'OK: ' + Copy(Command, 1, 120));
      Say(mkTiming, Format('%d ms', [Watch.ElapsedMilliseconds]));
      Exit(True);
    except
      on E: Exception do
      begin
        FResult.LastError := E.Message;
        Say(mkError, E.Message + ' -- ' + Copy(Command, 1, 200));
        if Assigned(FOnError) then
        begin
          if FStopOnError then Action := eaAbort else Action := eaSkip;
          FOnError(Self, Command, E, Action);
        end
        else if FStopOnError then
          Action := eaAbort
        else
          Action := eaSkip;

        // DIV-SCR-4: Failed conta i comandi falliti, non i tentativi: un comando
        // che riesce al secondo tentativo non entra nel conteggio
        if Action <> eaRetry then
          Inc(FResult.Failed);

        case Action of
          eaAbort: begin FAborted := True; Exit(False); end;
          eaSkip:  Exit(True);
          eaRetry: ; // ciclo
        end;
      end;
    end;
  until False;
end;

function TzFbScriptRunner.ExecuteText(const Text: string): TzScriptResult;
var
  I: Integer;
  Command, Head: string;
  Tx: TFDTransaction;
  Handled: Boolean;
  Watch: TStopwatch;
begin
  PrepareExecution;

  FAborted := False;
  FRunning := True;
  FillChar(FResult, SizeOf(FResult), 0);
  FResult.LastError := '';
  Watch := TStopwatch.StartNew;
  try
    if Assigned(FOnBeforeExecute) then FOnBeforeExecute(Self);

    SplitIntoCommands(StripComments(Text));
    FResult.Total := FCommands.Count;
    Tx := ActiveTransaction;

    if (FTxMode <> tmExternal) and Assigned(Tx) and (not Tx.Active) then
      Tx.StartTransaction;

    for I := 0 to FCommands.Count - 1 do
    begin
      if FAborted then Break;
      Command := FCommands[I];
      Head := UpperCase(TrimLeft(Command));

      if Assigned(FOnProgress) then
        FOnProgress(Self, I + 1, FCommands.Count, Command);
      Say(mkEcho, Command);

      // 1. hook applicativo: puo' assorbire qualunque comando
      Handled := False;
      if Assigned(FOnCustomCommand) then
        FOnCustomCommand(Self, Command, Handled);
      if Handled then
      begin
        Inc(FResult.Skipped);
        Continue;
      end;

      // 2. direttive isql che il server non riconosce
      if IsUnsupportedDirective(Command) then
      begin
        if FSkipUnsupportedDirectives then
        begin
          Inc(FResult.Skipped);
          Say(mkSkipped, 'Direttiva ignorata: ' + Copy(Command, 1, 120));
          Continue;
        end;
        // altrimenti cade nel ramo di esecuzione e fallira' esplicitamente
      end;

      // 3. COMMIT e ROLLBACK dentro lo script, gestiti dal runner sulla propria transazione
      if StartsText('COMMIT', Head) then
      begin
        if FTxMode = tmExternal then
          Say(mkSkipped, 'COMMIT ignorato (transazione esterna)')
        else
        begin
          Tx := ActiveTransaction;
          if Assigned(Tx) and Tx.Active then Tx.Commit;
          if Assigned(Tx) and (not Tx.Active) then Tx.StartTransaction;
          Say(mkFeedback, 'COMMIT');
        end;
        Inc(FResult.Skipped);
        Continue;
      end;

      // DIV-SCR-1: ROLLBACK TO SAVEPOINT e' un comando del server, non l'annullamento intero
      if StartsText('ROLLBACK', Head) and not StartsText('ROLLBACK TO', Head) and not StartsText('ROLLBACK WORK TO', Head) then
      begin
        if FTxMode = tmExternal then
          Say(mkSkipped, 'ROLLBACK ignorato (transazione esterna)')
        else
        begin
          Tx := ActiveTransaction;
          if Assigned(Tx) and Tx.Active then Tx.Rollback;
          if Assigned(Tx) and (not Tx.Active) then Tx.StartTransaction;
          Say(mkFeedback, 'ROLLBACK');
        end;
        Inc(FResult.Skipped);
        Continue;
      end;

      // 4. esecuzione vera
      if not ExecuteSingle(Command) then Break;

      if FTxMode = tmAutoCommit then
      begin
        Tx := ActiveTransaction;
        if Assigned(Tx) and Tx.Active then
        begin
          Tx.Commit;
          Tx.StartTransaction;
        end;
      end;
    end;

    // chiusura: commit se tutto ok, rollback se abortito
    if FTxMode <> tmExternal then
    begin
      Tx := ActiveTransaction;
      if Assigned(Tx) and Tx.Active then
        if FAborted then Tx.Rollback else Tx.Commit;
    end;

    if Assigned(FOnAfterExecute) then FOnAfterExecute(Self);
  finally
    Watch.Stop;
    FResult.ElapsedMs := Watch.ElapsedMilliseconds;
    FResult.Aborted := FAborted;
    FRunning := False;
  end;
  Result := FResult;
end;

function TzFbScriptRunner.ExecuteFile(const FileName: string; const Encoding: TEncoding): TzScriptResult;
var
  Reader: TStringList;
begin
  Reader := TStringList.Create;
  try
    // DIV-SCR-5: codifica facoltativa, UTF-8 se non indicata (un BOM nel file
    // ha comunque la precedenza). Esempio: TEncoding.GetEncoding(1252)
    if Assigned(Encoding) then
      Reader.LoadFromFile(FileName, Encoding)
    else
      Reader.LoadFromFile(FileName, TEncoding.UTF8);
    Result := ExecuteText(Reader.Text);
  finally
    Reader.Free;
  end;
end;

end.
