// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Server
//
// La sonda di collaudo dentro l'applicazione: un thread che ascolta su una
// named pipe e porta i comandi al thread principale.
//
// ACCENSIONE. Solo se il programma riceve --sonda <nome> (confronto esplicito,
// non FindCmdLineSwitch, che con il doppio trattino non riconosce l'opzione).
// Senza, AvviaSonda non fa niente. La unit entra nell'eseguibile solo nelle
// versioni di collaudo: nel .dpr sta sotto {$IFDEF SONDA}.
//
// PERCHE' UN THREAD E UNA PIPE. Il thread di ascolto risponde sempre, anche
// quando il thread principale e' fermo in una query lunga o in un ciclo
// bloccato: in quel caso la risposta e' "tempo scaduto, fermo da N ms", che
// e' gia' una diagnosi. WM_COPYDATA invece aspetterebbe il thread principale
// senza dire niente.
//
// COMANDI SUL THREAD PRINCIPALE. Con TThread.Queue e un evento con tempo
// massimo, mai Synchronize: il thread di ascolto non deve restare appeso.
// La coda gira anche dentro i cicli modali (ShowModal e MessageBox nativi),
// ed e' questo che permette di leggere e chiudere un dialogo mentre l'azione
// che lo ha aperto aspetta.
//
// AZIONI E DIALOGHI. "esegui" accoda l'azione e poi aspetta: se finisce,
// esito completato; se nel frattempo compare un dialogo modale, esito dialogo
// con il suo contenuto, e l'azione resta sospesa nel lavoro indicato;
// "rispondi" chiude il dialogo e riprende l'attesa dello stesso lavoro.
// Le regole di risposta automatica (regole_dialoghi) chiudono da sole i
// dialoghi che contengono un testo dato, e il resoconto lo dice.
//
// ECCEZIONI. Un TApplicationEvents proprio le registra (classe, messaggio,
// form attiva, lavoro in corso). Se nessun altro le mostra (MostraEccezioni),
// la sonda chiama Application.ShowException come farebbe la VCL. Un'eccezione
// dentro un'azione eseguita dalla sonda passa da Application.HandleException,
// cioe' dallo stesso percorso di un clic dell'utente.
//
// CLIC, TASTI E MONITOR. "clic" e "tasti" spediscono messaggi di Windows
// alle finestre del programma: il mouse e la tastiera veri non si toccano, e
// chi lavora sul computer non se ne accorge. Il clic e' sincrono e va, un
// messaggio alla volta, alla finestra che Windows sceglierebbe (la figlia
// sotto il punto, poi quella con la cattura), con i modificatori (ctrl,
// maiusc, alt) premuti per il solo programma; i tasti sono messaggi in coda
// (PostMessage). "menu_contestuale" fa il clic destro senza mostrare il menu
// e ne restituisce le voci, o ne preme una (Sonda.Ispezione). Se dopo il
// comando compare un dialogo la risposta lo riporta nel campo "dialoghi". Con "monitor" in configura le finestre del programma si
// portano su quel monitor (Sonda.Monitor), lasciando libero il principale;
// "stato" elenca i monitor e dice se il programma ha il fuoco di Windows.
//
// BARRE E COMANDI DEL PONTE. "barra" elenca le voci delle barre DevExpress di
// una form o di un frame (Sonda.Ispezione: esegui le preme, imposta scrive le
// caselle di filtro). I comandi che conoscono componenti di zPack o
// dell'applicazione (filtro e colonna attiva delle viste, skin) li registra
// il ponte con RegistraComandoSonda: qui si eseguono come le azioni.
//
// SICUREZZA. La pipe accetta solo l'utente Windows che ha avviato il
// programma e rifiuta i client remoti; FILE_FLAG_FIRST_PIPE_INSTANCE
// impedisce che un altro processo si presenti con lo stesso nome prima della
// sonda. Le azioni vietate (configura) si controllano qui, sul nome e sulla
// didascalia, oppure sull'indirizzo completo se la maschera contiene un
// punto, oltre che in zMCP_App.
//
// ***************************************************************************

unit Sonda.Server;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON;

type
  TFornitoreAzioni = reference to function: TArray<TBasicAction>;

  // Un comando in piu' registrato dal ponte dell'applicazione: riceve gli
  // argomenti della richiesta e restituisce il risultato.
  TComandoSonda = reference to function(Argomenti: TJSONObject): TJSONValue;

var
  // Il ponte dell'applicazione indica le azioni del menu principale; senza,
  // valgono quelle possedute dalla form principale.
  FornitoreMenuSonda: TFornitoreAzioni;

  // Falso quando l'applicazione ha gia' un gestore che mostra le eccezioni
  // (Gesty e WT: TzExceptionManager nel ConfigModule).
  MostraEccezioniSonda: Boolean = True;

// Da chiamare nel .dpr dopo Application.Initialize, prima dei DataModule:
// cosi' la sonda c'e' gia' quando compare la finestra di login.
procedure AvviaSonda;
procedure FermaSonda;
function SondaAttiva: Boolean;

// Registra un comando per i componenti che la sonda non conosce (filtri delle
// viste di zBase, skin): da chiamare nel ponte prima di AvviaSonda. Esegui
// gira sul thread principale come un'azione, con i dialoghi, il tempo massimo
// e le eccezioni dell'applicazione. Esito, se c'e', si legge dopo, quando i
// messaggi accodati da Esegui sono stati elaborati (un filtro riapre il
// dataset con un messaggio differito), e va nella risposta come "dopo".
procedure RegistraComandoSonda(const Nome: string; Esegui: TComandoSonda; Esito: TComandoSonda = nil);

implementation

uses
  System.SyncObjs,
  System.Math,
  System.Masks,
  System.StrUtils,
  System.DateUtils,
  System.Generics.Collections,
  Winapi.Windows,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.Menus,
  Data.DB,
  Sonda.Protocollo,
  Sonda.Ispezione,
  Sonda.Dialoghi,
  Sonda.Monitor;

const
  PIPE_REJECT_REMOTE_CLIENTS = $00000008;
  SDDL_REVISION_1 = 1;
  DimensioneBuffer = 65536;
  AttesaLetturaMs = 10000;
  AttesaPredefinitaAzioneMs = 15000;
  IntervalloControlloDialoghiMs = 250;
  PausaDopoMessaggiMs = 300;
  TempoSondaggioMs = 2000;
  EccezioniMassime = 100;
  RigaMassima = 4 * 1024 * 1024;

function ConvertSidToStringSidW(Sid: PSID; var StringSid: PWideChar): BOOL; stdcall;
  external advapi32 name 'ConvertSidToStringSidW';
function ConvertStringSecurityDescriptorToSecurityDescriptorW(StringSecurityDescriptor: PWideChar;
  StringSDRevision: DWORD; var SecurityDescriptor: PSECURITY_DESCRIPTOR; SecurityDescriptorSize: PULONG): BOOL;
  stdcall; external advapi32 name 'ConvertStringSecurityDescriptorToSecurityDescriptorW';

type
  // Un comando portato al thread principale. Non si libera finche' non e'
  // completato: una TThread.Queue arrivata in ritardo trova l'oggetto vivo.
  TLavoro = class
  public
    Id: Integer;
    Descrizione: string;
    Inizio: TDateTime;
    Evento: TEvent;
    Avviato: Boolean;
    Completato: Boolean;
    Risultato: TJSONValue;
    Errore: string;
    Eccezione: string;
    DialoghiGestiti: TJSONArray;
    constructor Create(AId: Integer; const ADescrizione: string);
    destructor Destroy; override;
  end;

  TFunzioneSonda = reference to function: TJSONValue;

  TRegolaDialogo = record
    Contiene: string;
    Risposta: string;
  end;

  TComandoRegistrato = record
    Esegui: TComandoSonda;
    Esito: TComandoSonda;
  end;

  TSonda = class(TThread)
  private
    FNomePipe: string;
    FPipe: THandle;
    FUscita: TEvent;
    FBlocco: TCriticalSection;
    FLavori: TObjectList<TLavoro>;
    FProssimoLavoro: Integer;
    FUltimoBattito: Int64;
    FTimerBattito: TTimer;
    FEventiApplicazione: TApplicationEvents;
    FEccezioni: TJSONArray;
    FVietate: TArray<string>;
    FRegole: TArray<TRegolaDialogo>;
    FLavoroCorrente: Integer;
    procedure BattitoTimer(Sender: TObject);
    procedure EccezioneApplicazione(Sender: TObject; E: Exception);
    function CreaPipe: Boolean;
    function AttendiOperazione(var Sovrapposto: TOverlapped; out Trasferiti: DWORD; TempoMs: Cardinal): Boolean;
    function LeggiRiga(out Riga: TBytes): Boolean;
    function ScriviRiga(const Dati: TBytes): Boolean;
    function NuovoLavoro(const Descrizione: string): TLavoro;
    procedure PotaLavori;
    function TrovaLavoro(Id: Integer): TLavoro;
    function LavoroSospeso: TLavoro;
    // sul thread principale, con tempo massimo; nil se scaduto
    function SulPrincipale(const Descrizione: string; Funzione: TFunzioneSonda; TempoMs: Cardinal;
      out Errore: string): TJSONValue;
    procedure AccodaAzione(Lavoro: TLavoro; Funzione: TFunzioneSonda);
    function AttendiLavoro(Lavoro: TLavoro; AttesaMs: Cardinal): TJSONObject;
    function MillisecondiDalBattito: Int64;
    // vero se l'evento scatta; falso a tempo scaduto o se la sonda si ferma
    function AttendiEvento(Evento: TEvent; TempoMs: Cardinal): Boolean;
    function AzioneVietata(Componente: TComponent): string;
    function Elabora(Richiesta: TJSONObject): TJSONObject;
    function ComandoLettura(Id: Int64; const Descrizione: string; Funzione: TFunzioneSonda): TJSONObject;
    function ComandoAzione(Id: Int64; const Descrizione: string; AttesaMs: Cardinal; Funzione: TFunzioneSonda): TJSONObject;
    // Clic e tasti sono messaggi in coda: il comando finisce quando sono
    // spediti, non quando sono elaborati. Dopo una breve pausa si guarda se
    // hanno aperto un dialogo, e lo si aggiunge alla risposta (risponderai con
    // rispondi, come per un'azione).
    procedure AggiungiDialoghiAperti(Risposta: TJSONObject);
    function EseguiRegistrato(Id: Int64; const Nome: string; const Registrato: TComandoRegistrato;
      Argomenti: TJSONObject; AttesaMs: Cardinal): TJSONObject;
  protected
    procedure Execute; override;
  public
    constructor Create(const NomePipe: string);
    destructor Destroy; override;
    procedure Ferma;
  end;

var
  Sonda: TSonda;
  // scritti dal ponte prima di AvviaSonda, poi solo letti dal thread di ascolto
  ComandiRegistrati: TDictionary<string, TComandoRegistrato>;

procedure RegistraComandoSonda(const Nome: string; Esegui: TComandoSonda; Esito: TComandoSonda);
var
  Voce: TComandoRegistrato;
begin
  if ComandiRegistrati = nil then
    ComandiRegistrati := TDictionary<string, TComandoRegistrato>.Create;
  Voce.Esegui := Esegui;
  Voce.Esito := Esito;
  ComandiRegistrati.AddOrSetValue(LowerCase(Nome), Voce);
end;

// ----- TLavoro ---------------------------------------------------------------------

constructor TLavoro.Create(AId: Integer; const ADescrizione: string);
begin
  inherited Create;
  Id := AId;
  Descrizione := ADescrizione;
  Inizio := Now;
  Evento := TEvent.Create(nil, True, False, '');
  DialoghiGestiti := TJSONArray.Create;
end;

destructor TLavoro.Destroy;
begin
  Risultato.Free;
  DialoghiGestiti.Free;
  Evento.Free;
  inherited;
end;

// ----- avvio e arresto -------------------------------------------------------------

function NomeDaRigaDiComando: string;
var
  Indice: Integer;
begin
  Result := '';
  for Indice := 1 to ParamCount - 1 do
    if SameText(ParamStr(Indice), OpzioneSonda) then
      Exit(ParamStr(Indice + 1).Trim);
end;

procedure AvviaSonda;
var
  Nome: string;
begin
  if Sonda <> nil then
    Exit;
  Nome := NomeDaRigaDiComando;
  if Nome = '' then
    Exit;
  Sonda := TSonda.Create(NomePipeSonda(Nome));
end;

procedure FermaSonda;
begin
  if Sonda = nil then
    Exit;
  Sonda.Ferma;
  FreeAndNil(Sonda);
end;

function SondaAttiva: Boolean;
begin
  Result := Sonda <> nil;
end;

constructor TSonda.Create(const NomePipe: string);
begin
  FNomePipe := NomePipe;
  FPipe := INVALID_HANDLE_VALUE;
  FUscita := TEvent.Create(nil, True, False, '');
  FBlocco := TCriticalSection.Create;
  FLavori := TObjectList<TLavoro>.Create(True);
  FEccezioni := TJSONArray.Create;
  FUltimoBattito := GetTickCount64;

  // il battito lo da' il thread principale: se smette, e' fermo
  FTimerBattito := TTimer.Create(nil);
  FTimerBattito.Interval := 200;
  FTimerBattito.OnTimer := BattitoTimer;
  FTimerBattito.Enabled := True;

  FEventiApplicazione := TApplicationEvents.Create(nil);
  FEventiApplicazione.OnException := EccezioneApplicazione;

  // i MessageDlg della VCL diventano form VCL leggibili invece di TaskDialog
  // nativi, di cui non si legge il testo
  UseLatestCommonDialogs := False;

  inherited Create(False);
end;

destructor TSonda.Destroy;
begin
  FTimerBattito.Free;
  FEventiApplicazione.Free;
  FLavori.Free;
  FEccezioni.Free;
  FBlocco.Free;
  FUscita.Free;
  inherited;
end;

procedure TSonda.Ferma;
begin
  Terminate;
  FUscita.SetEvent;
  if FPipe <> INVALID_HANDLE_VALUE then
    CancelIoEx(FPipe, nil);
  WaitFor;
end;

procedure TSonda.BattitoTimer(Sender: TObject);
begin
  TInterlocked.Exchange(FUltimoBattito, Int64(GetTickCount64));
  // con il monitor scelto, porta li' le finestre che il gancio non ha preso
  try
    SpostaFinestreSulMonitor;
  except
    // il battito non deve mai fermarsi per uno spostamento riuscito male
  end;
end;

function TSonda.MillisecondiDalBattito: Int64;
begin
  Result := Int64(GetTickCount64) - TInterlocked.Read(FUltimoBattito);
end;

function TSonda.AttendiEvento(Evento: TEvent; TempoMs: Cardinal): Boolean;
var
  Eventi: array [0 .. 1] of THandle;
begin
  Eventi[0] := Evento.Handle;
  Eventi[1] := FUscita.Handle;
  Result := WaitForMultipleObjects(2, @Eventi, False, TempoMs) = WAIT_OBJECT_0;
end;

procedure TSonda.EccezioneApplicazione(Sender: TObject; E: Exception);
var
  Voce: TJSONObject;
begin
  Voce := TJSONObject.Create;
  Voce.AddPair('ora', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now));
  Voce.AddPair('classe', E.ClassName);
  Voce.AddPair('messaggio', E.Message);
  if Screen.ActiveCustomForm <> nil then
    Voce.AddPair('form_attiva', IndirizzoDi(Screen.ActiveCustomForm));
  if FLavoroCorrente <> 0 then
    Voce.AddPair('lavoro', TJSONNumber.Create(FLavoroCorrente));
  if Sender is TComponent then
    Voce.AddPair('origine', IndirizzoDi(TComponent(Sender)));
  FBlocco.Enter;
  try
    FEccezioni.AddElement(Voce);
    while FEccezioni.Count > EccezioniMassime do
      FEccezioni.Remove(0).Free;
  finally
    FBlocco.Leave;
  end;
  if MostraEccezioniSonda then
    Application.ShowException(E);
end;

// ----- pipe -------------------------------------------------------------------------

function DescrittoreSoloUtente(out Descrittore: PSECURITY_DESCRIPTOR): Boolean;
var
  Token: THandle;
  Dimensione: DWORD;
  Utente: PTokenUser;
  TestoSid: PWideChar;
  Sddl: string;
begin
  Result := False;
  Descrittore := nil;
  if not OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, Token) then
    Exit;
  try
    Dimensione := 0;
    GetTokenInformation(Token, TokenUser, nil, 0, Dimensione);
    GetMem(Utente, Dimensione);
    try
      if not GetTokenInformation(Token, TokenUser, Utente, Dimensione, Dimensione) then
        Exit;
      if not ConvertSidToStringSidW(Utente.User.Sid, TestoSid) then
        Exit;
      try
        // solo l'utente che ha avviato il programma, niente ereditarieta'
        Sddl := 'D:P(A;;GA;;;' + TestoSid + ')';
      finally
        LocalFree(HLOCAL(TestoSid));
      end;
    finally
      FreeMem(Utente);
    end;
  finally
    CloseHandle(Token);
  end;
  Result := ConvertStringSecurityDescriptorToSecurityDescriptorW(PWideChar(Sddl), SDDL_REVISION_1, Descrittore, nil);
end;

function TSonda.CreaPipe: Boolean;
var
  Sicurezza: TSecurityAttributes;
  Descrittore: PSECURITY_DESCRIPTOR;
begin
  if not DescrittoreSoloUtente(Descrittore) then
    Exit(False);
  try
    Sicurezza.nLength := SizeOf(Sicurezza);
    Sicurezza.lpSecurityDescriptor := Descrittore;
    Sicurezza.bInheritHandle := False;
    FPipe := CreateNamedPipe(PChar(FNomePipe), PIPE_ACCESS_DUPLEX or FILE_FLAG_OVERLAPPED or
      FILE_FLAG_FIRST_PIPE_INSTANCE, PIPE_TYPE_BYTE or PIPE_READMODE_BYTE or PIPE_WAIT or PIPE_REJECT_REMOTE_CLIENTS,
      1, DimensioneBuffer, DimensioneBuffer, 0, @Sicurezza);
    Result := FPipe <> INVALID_HANDLE_VALUE;
  finally
    LocalFree(HLOCAL(Descrittore));
  end;
end;

function TSonda.AttendiOperazione(var Sovrapposto: TOverlapped; out Trasferiti: DWORD; TempoMs: Cardinal): Boolean;
var
  Eventi: array [0 .. 1] of THandle;
begin
  Trasferiti := 0;
  Eventi[0] := Sovrapposto.hEvent;
  Eventi[1] := FUscita.Handle;
  case WaitForMultipleObjects(2, @Eventi, False, TempoMs) of
    WAIT_OBJECT_0:
      Result := GetOverlappedResult(FPipe, Sovrapposto, Trasferiti, False);
  else
    CancelIoEx(FPipe, @Sovrapposto);
    GetOverlappedResult(FPipe, Sovrapposto, Trasferiti, True);
    Result := False;
  end;
end;

function TSonda.LeggiRiga(out Riga: TBytes): Boolean;
var
  Buffer: TBytes;
  Accumulo: TBytesStream;
  Sovrapposto: TOverlapped;
  Letti: DWORD;
  Posizione: Integer;
begin
  Result := False;
  SetLength(Buffer, DimensioneBuffer);
  Accumulo := TBytesStream.Create;
  FillChar(Sovrapposto, SizeOf(Sovrapposto), 0);
  Sovrapposto.hEvent := CreateEvent(nil, True, False, nil);
  try
    while not Terminated do
    begin
      ResetEvent(Sovrapposto.hEvent);
      if not ReadFile(FPipe, Buffer[0], Length(Buffer), Letti, @Sovrapposto) then
      begin
        if GetLastError <> ERROR_IO_PENDING then
          Exit;
        // senza limite di tempo: fra un comando e l'altro il client puo'
        // restare fermo quanto vuole; la lettura si interrompe solo con Ferma
        if not AttendiOperazione(Sovrapposto, Letti, INFINITE) then
          Exit;
      end;
      if Letti = 0 then
        Continue;
      for Posizione := 0 to Integer(Letti) - 1 do
        if Buffer[Posizione] = 10 then
        begin
          Accumulo.WriteBuffer(Buffer[0], Posizione);
          Riga := Copy(Accumulo.Bytes, 0, Accumulo.Size);
          // il protocollo e' una richiesta per volta: dopo LF non arriva altro
          Exit(True);
        end;
      Accumulo.WriteBuffer(Buffer[0], Letti);
      if Accumulo.Size > RigaMassima then
        Exit;
    end;
  finally
    CloseHandle(Sovrapposto.hEvent);
    Accumulo.Free;
  end;
end;

function TSonda.ScriviRiga(const Dati: TBytes): Boolean;
var
  Sovrapposto: TOverlapped;
  Scritti: DWORD;
  Inviati: Integer;
begin
  Result := False;
  Inviati := 0;
  FillChar(Sovrapposto, SizeOf(Sovrapposto), 0);
  Sovrapposto.hEvent := CreateEvent(nil, True, False, nil);
  try
    while Inviati < Length(Dati) do
    begin
      ResetEvent(Sovrapposto.hEvent);
      if not WriteFile(FPipe, Dati[Inviati], Length(Dati) - Inviati, Scritti, @Sovrapposto) then
      begin
        if GetLastError <> ERROR_IO_PENDING then
          Exit;
        if not AttendiOperazione(Sovrapposto, Scritti, AttesaLetturaMs) then
          Exit;
      end;
      Inc(Inviati, Scritti);
    end;
    Result := True;
  finally
    CloseHandle(Sovrapposto.hEvent);
  end;
end;

procedure TSonda.Execute;
var
  Sovrapposto: TOverlapped;
  Trasferiti: DWORD;
  Riga, Uscita: TBytes;
  Richiesta, Risposta: TJSONObject;
  Collegato: Boolean;
begin
  NameThreadForDebugging('zSonda');
  if not CreaPipe then
    Exit;
  try
    while not Terminated do
    begin
      FillChar(Sovrapposto, SizeOf(Sovrapposto), 0);
      Sovrapposto.hEvent := CreateEvent(nil, True, False, nil);
      try
        Collegato := ConnectNamedPipe(FPipe, @Sovrapposto);
        if not Collegato then
          case GetLastError of
            ERROR_PIPE_CONNECTED:
              Collegato := True;
            ERROR_IO_PENDING:
              Collegato := AttendiOperazione(Sovrapposto, Trasferiti, INFINITE);
          end;
      finally
        CloseHandle(Sovrapposto.hEvent);
      end;
      if Terminated then
        Break;
      if not Collegato then
        Continue;

      while not Terminated and LeggiRiga(Riga) do
      begin
        Richiesta := JsonDaRiga(Riga);
        try
          if Richiesta = nil then
            Risposta := NuovaRisposta(0, EsitoErrore, 'Richiesta non valida: serve un oggetto JSON su una riga.')
          else
            try
              Risposta := Elabora(Richiesta);
            except
              on E: Exception do
                Risposta := NuovaRisposta(Richiesta.GetValue<Int64>('id', 0), EsitoErrore,
                  E.ClassName + ': ' + E.Message);
            end;
        finally
          Richiesta.Free;
        end;
        try
          Uscita := RigaDaJson(Risposta);
        finally
          Risposta.Free;
        end;
        if not ScriviRiga(Uscita) then
          Break;
      end;
      DisconnectNamedPipe(FPipe);
    end;
  finally
    CloseHandle(FPipe);
    FPipe := INVALID_HANDLE_VALUE;
  end;
end;

// ----- lavori sul thread principale ----------------------------------------------

function TSonda.NuovoLavoro(const Descrizione: string): TLavoro;
begin
  FBlocco.Enter;
  try
    PotaLavori;
    Inc(FProssimoLavoro);
    Result := TLavoro.Create(FProssimoLavoro, Descrizione);
    FLavori.Add(Result);
  finally
    FBlocco.Leave;
  end;
end;

procedure TSonda.PotaLavori;
var
  Indice: Integer;
begin
  // dentro FBlocco: solo i completati da piu' di un minuto, mai uno che una
  // TThread.Queue potrebbe ancora toccare
  for Indice := FLavori.Count - 1 downto 0 do
    if FLavori[Indice].Completato and (SecondsBetween(Now, FLavori[Indice].Inizio) > 60) then
      FLavori.Delete(Indice);
end;

function TSonda.TrovaLavoro(Id: Integer): TLavoro;
var
  Lavoro: TLavoro;
begin
  Result := nil;
  FBlocco.Enter;
  try
    for Lavoro in FLavori do
      if Lavoro.Id = Id then
        Exit(Lavoro);
  finally
    FBlocco.Leave;
  end;
end;

function TSonda.LavoroSospeso: TLavoro;
var
  Indice: Integer;
begin
  // il piu' recente fra le azioni avviate e non finite: e' quello che il
  // dialogo appena chiuso teneva fermo
  Result := nil;
  FBlocco.Enter;
  try
    for Indice := FLavori.Count - 1 downto 0 do
      if FLavori[Indice].Avviato and not FLavori[Indice].Completato and
        not FLavori[Indice].Descrizione.StartsWith('lettura:') then
        Exit(FLavori[Indice]);
  finally
    FBlocco.Leave;
  end;
end;

function TSonda.SulPrincipale(const Descrizione: string; Funzione: TFunzioneSonda; TempoMs: Cardinal;
  out Errore: string): TJSONValue;
var
  Lavoro: TLavoro;
begin
  Result := nil;
  Errore := '';
  Lavoro := NuovoLavoro('lettura: ' + Descrizione);
  TThread.Queue(nil,
    procedure
    begin
      Lavoro.Avviato := True;
      try
        Lavoro.Risultato := Funzione();
      except
        // una lettura che fallisce si racconta a chi l'ha chiesta, non
        // all'utente: l'applicazione non deve vedere errori della sonda
        on E: Exception do
          Lavoro.Errore := E.Message;
      end;
      Lavoro.Completato := True;
      Lavoro.Evento.SetEvent;
    end);
  if not AttendiEvento(Lavoro.Evento, TempoMs) then
  begin
    Errore := Format('il thread principale non ha risposto in %d ms (fermo da %d ms)', [TempoMs, MillisecondiDalBattito]);
    Exit;
  end;
  Errore := Lavoro.Errore;
  // il risultato passa a chi chiama: il lavoro non lo libera piu'
  Result := Lavoro.Risultato;
  Lavoro.Risultato := nil;
end;

procedure TSonda.AccodaAzione(Lavoro: TLavoro; Funzione: TFunzioneSonda);
begin
  TThread.Queue(nil,
    procedure
    var
      LavoroPrecedente: Integer;
    begin
      Lavoro.Avviato := True;
      LavoroPrecedente := FLavoroCorrente;
      FLavoroCorrente := Lavoro.Id;
      try
        try
          Lavoro.Risultato := Funzione();
        except
          on E: ESonda do
            Lavoro.Errore := E.Message;
          on E: Exception do
          begin
            // stesso percorso di un clic dell'utente: i gestori
            // dell'applicazione mostrano e registrano l'eccezione
            Lavoro.Eccezione := E.ClassName + ': ' + E.Message;
            Application.HandleException(Lavoro);
          end;
        end;
      finally
        FLavoroCorrente := LavoroPrecedente;
        Lavoro.Completato := True;
        Lavoro.Evento.SetEvent;
      end;
    end);
end;

function TSonda.AttendiLavoro(Lavoro: TLavoro; AttesaMs: Cardinal): TJSONObject;
var
  Scadenza: UInt64;
  Dialoghi: TJSONValue;
  Errore, TestoDialogo, Risposta: string;
  Finestra: HWND;
  Regola: TRegolaDialogo;
  RegolaApplicata: Boolean;
  Gestito: TJSONObject;
begin
  Risposta := '';
  Scadenza := GetTickCount64 + AttesaMs;
  while (GetTickCount64 < Scadenza) and not Terminated do
  begin
    if AttendiEvento(Lavoro.Evento, IntervalloControlloDialoghiMs) then
    begin
      if Lavoro.Errore <> '' then
        Result := NuovaRisposta(0, EsitoErrore, Lavoro.Errore)
      else
        Result := NuovaRisposta(0, EsitoCompletato);
      if Lavoro.Risultato <> nil then
      begin
        Result.AddPair('risultato', Lavoro.Risultato);
        Lavoro.Risultato := nil;
      end;
      if Lavoro.Eccezione <> '' then
        Result.AddPair('eccezione', Lavoro.Eccezione);
      if Lavoro.DialoghiGestiti.Count > 0 then
        Result.AddPair('dialoghi_gestiti', TJSONArray(Lavoro.DialoghiGestiti.Clone));
      Result.AddPair('lavoro', TJSONNumber.Create(Lavoro.Id));
      Exit;
    end;
    if not Lavoro.Avviato then
      Continue;

    // l'azione e' partita e non e' finita: o lavora, o aspetta un dialogo
    TestoDialogo := '';
    Dialoghi := SulPrincipale('dialoghi',
      function: TJSONValue
      var
        Testo: string;
      begin
        Testo := TestoDialogoPiuRecente(Finestra);
        if Testo = '' then
          Exit(TJSONNull.Create);
        Result := ElencoDialoghi;
      end, TempoSondaggioMs, Errore);
    try
      if (Dialoghi = nil) or (Dialoghi is TJSONNull) then
        Continue;

      // regole di risposta automatica, sul dialogo in primo piano
      TestoDialogo := TJSONArray(Dialoghi).Items[0].GetValue<string>('titolo', '') + sLineBreak +
        TJSONArray(Dialoghi).Items[0].GetValue<string>('testo', '');
      RegolaApplicata := False;
      FBlocco.Enter;
      try
        for Regola in FRegole do
          if ContainsText(TestoDialogo, Regola.Contiene) then
          begin
            RegolaApplicata := True;
            Risposta := Regola.Risposta;
            Break;
          end;
      finally
        FBlocco.Leave;
      end;
      if RegolaApplicata then
      begin
        SulPrincipale('risposta automatica',
          function: TJSONValue
          begin
            Result := TJSONString.Create(RispondiDialogo(Risposta, '', 0));
          end, TempoSondaggioMs, Errore).Free;
        Gestito := TJSONObject.Create;
        Gestito.AddPair('testo', TestoDialogo.Trim);
        Gestito.AddPair('risposta', Risposta);
        if Errore <> '' then
          Gestito.AddPair('errore', Errore);
        Lavoro.DialoghiGestiti.AddElement(Gestito);
        if Errore = '' then
          Continue;
      end;

      Result := NuovaRisposta(0, EsitoDialogo,
        'L''azione aspetta la risposta a un dialogo: rispondi, oppure leggilo con dialoghi.');
      Result.AddPair('lavoro', TJSONNumber.Create(Lavoro.Id));
      Result.AddPair('dialoghi', Dialoghi);
      Dialoghi := nil;
      if Lavoro.DialoghiGestiti.Count > 0 then
        Result.AddPair('dialoghi_gestiti', TJSONArray(Lavoro.DialoghiGestiti.Clone));
      Exit;
    finally
      Dialoghi.Free;
    end;
  end;

  Result := NuovaRisposta(0, EsitoTempoScaduto, Format('L''azione non e'' finita in %d ms; ' +
    'il thread principale non da'' segni di vita da %d ms. Usa attendi per continuare ad aspettare.',
    [AttesaMs, MillisecondiDalBattito]));
  Result.AddPair('lavoro', TJSONNumber.Create(Lavoro.Id));
  Result.AddPair('battito_ms', TJSONNumber.Create(MillisecondiDalBattito));
  Result.AddPair('avviato', TJSONBool.Create(Lavoro.Avviato));
end;

// ----- comandi ---------------------------------------------------------------------

// Una maschera con il punto (FormANPR.Cerca, FormPalmari*.Esporta) si
// confronta con l'indirizzo completo, cosi' un'azione dal nome generico si
// vieta in una form sola; senza punto, con il nome e con la didascalia.
function TSonda.AzioneVietata(Componente: TComponent): string;
var
  Maschera, Nome, Didascalia, Indirizzo: string;
begin
  Result := '';
  Nome := Componente.Name;
  Didascalia := StripHotkey(DidascaliaDi(Componente));
  Indirizzo := IndirizzoDi(Componente);
  FBlocco.Enter;
  try
    for Maschera in FVietate do
      if Maschera.Contains('.') then
      begin
        if MatchesMask(Indirizzo, Maschera) then
          Exit(Format('%s ("%s") e'' fra le azioni vietate (%s) nella configurazione del banco.',
            [Indirizzo, Didascalia, Maschera]));
      end
      else if MatchesMask(Nome, Maschera) or ((Didascalia <> '') and MatchesMask(Didascalia, Maschera)) then
        Exit(Format('%s ("%s") e'' fra le azioni vietate (%s) nella configurazione del banco.',
          [IndirizzoDi(Componente), Didascalia, Maschera]));
  finally
    FBlocco.Leave;
  end;
end;

function TSonda.ComandoLettura(Id: Int64; const Descrizione: string; Funzione: TFunzioneSonda): TJSONObject;
var
  Valore: TJSONValue;
  Errore: string;
begin
  Valore := SulPrincipale(Descrizione, Funzione, AttesaLetturaMs, Errore);
  if Errore <> '' then
  begin
    Valore.Free;
    Exit(NuovaRisposta(Id, EsitoErrore, Errore));
  end;
  Result := NuovaRisposta(Id, EsitoCompletato);
  if Valore <> nil then
    Result.AddPair('risultato', Valore);
end;

function TSonda.ComandoAzione(Id: Int64; const Descrizione: string; AttesaMs: Cardinal;
  Funzione: TFunzioneSonda): TJSONObject;
var
  Lavoro: TLavoro;
begin
  Lavoro := NuovoLavoro(Descrizione);
  AccodaAzione(Lavoro, Funzione);
  Result := AttendiLavoro(Lavoro, AttesaMs);
  Result.RemovePair('id').Free;
  Result.AddPair('id', TJSONNumber.Create(Id));
end;

procedure TSonda.AggiungiDialoghiAperti(Risposta: TJSONObject);
var
  Dialoghi: TJSONValue;
  Errore: string;
begin
  if Risposta.GetValue<string>('esito', '') <> EsitoCompletato then
    Exit;
  // il tempo che i messaggi spediti arrivino al programma e producano un
  // dialogo (un clic che apre una scheda, un Invio che chiede conferma)
  Sleep(PausaDopoMessaggiMs);
  Dialoghi := SulPrincipale('dialoghi dopo i messaggi',
    function: TJSONValue
    begin
      if CiSonoDialoghi then
        Result := ElencoDialoghi
      else
        Result := TJSONNull.Create;
    end, TempoSondaggioMs, Errore);
  if (Dialoghi is TJSONArray) and (TJSONArray(Dialoghi).Count > 0) then
    Risposta.AddPair('dialoghi', Dialoghi)
  else
    Dialoghi.Free;
end;

function TSonda.EseguiRegistrato(Id: Int64; const Nome: string; const Registrato: TComandoRegistrato;
  Argomenti: TJSONObject; AttesaMs: Cardinal): TJSONObject;
var
  Esegui, Esito: TComandoSonda;
  CopiaAzione, CopiaEsito: TJSONObject;
  Dopo: TJSONValue;
  Errore: string;
begin
  // ogni funzione ha la sua copia degli argomenti e la libera lei: la
  // richiesta sparisce appena risposto, mentre l'azione puo' restare sospesa
  // su un dialogo e la lettura finale arrivare dopo il tempo massimo
  Esegui := Registrato.Esegui;
  Esito := Registrato.Esito;
  if Argomenti <> nil then
    CopiaAzione := TJSONObject(Argomenti.Clone)
  else
    CopiaAzione := TJSONObject.Create;
  Result := ComandoAzione(Id, Nome + ' ' + CopiaAzione.GetValue<string>('indirizzo', ''), AttesaMs,
    function: TJSONValue
    begin
      try
        Result := Esegui(CopiaAzione);
      finally
        CopiaAzione.Free;
      end;
    end);

  if Assigned(Esito) and (Result.GetValue<string>('esito', '') = EsitoCompletato) then
  begin
    if Argomenti <> nil then
      CopiaEsito := TJSONObject(Argomenti.Clone)
    else
      CopiaEsito := TJSONObject.Create;
    // il tempo che i messaggi accodati dall'azione arrivino: la lettura passa
    // da TThread.Queue, quindi parte comunque dopo di loro
    Sleep(PausaDopoMessaggiMs);
    Dopo := SulPrincipale(Nome + ' dopo',
      function: TJSONValue
      begin
        try
          Result := Esito(CopiaEsito);
        finally
          CopiaEsito.Free;
        end;
      end, AttesaLetturaMs, Errore);
    if Dopo <> nil then
      Result.AddPair('dopo', Dopo)
    else if Errore <> '' then
      Result.AddPair('dopo_errore', Errore);
  end;
  AggiungiDialoghiAperti(Result);
end;

function TSonda.Elabora(Richiesta: TJSONObject): TJSONObject;
var
  Id: Int64;
  Comando, Indirizzo, Campo, Valore, Pulsante, Testo, TestoDigitato, Tasti, NomeVoce: string;
  Argomenti: TJSONObject;
  Profondita, Righe, NumeroLavoro, NumeroMonitor, ClicX, ClicY: Integer;
  CampiDataset: TArray<string>;
  SpostamentoX, SpostamentoY, Dimensione: Integer;
  Doppio, Tutte: Boolean;
  Modificatori: TModificatoriClic;
  Registrato: TComandoRegistrato;
  AttesaMs: Cardinal;
  Finestra: HWND;
  Lavoro: TLavoro;
  Elenco: TJSONArray;
  Voce: TJSONValue;
  Regole: TList<TRegolaDialogo>;
  Regola: TRegolaDialogo;
  Stato: TJSONObject;
  Errore: string;
  Rilevato: TJSONValue;
begin
  Id := Richiesta.GetValue<Int64>('id', 0);
  Comando := Richiesta.GetValue<string>('comando', '');
  if not Richiesta.TryGetValue<TJSONObject>('argomenti', Argomenti) then
    Argomenti := nil;

  // argomenti comuni, letti una volta
  Indirizzo := '';
  AttesaMs := AttesaPredefinitaAzioneMs;
  if Argomenti <> nil then
  begin
    Indirizzo := Argomenti.GetValue<string>('indirizzo', '');
    AttesaMs := Max(1, Argomenti.GetValue<Integer>('attesa_secondi', AttesaPredefinitaAzioneMs div 1000)) * 1000;
  end;

  if Comando = ComandoAggancio then
  begin
    Result := NuovaRisposta(Id, EsitoCompletato);
    Stato := TJSONObject.Create;
    Stato.AddPair('protocollo', TJSONNumber.Create(VersioneProtocolloSonda));
    Stato.AddPair('marca', MarcaSondaNelEseguibile);
    Stato.AddPair('processo', TJSONNumber.Create(GetCurrentProcessId));
    Stato.AddPair('eseguibile', ParamStr(0));
    Result.AddPair('risultato', Stato);
  end

  else if Comando = ComandoStato then
  begin
    Stato := TJSONObject.Create;
    Stato.AddPair('battito_ms', TJSONNumber.Create(MillisecondiDalBattito));
    Rilevato := SulPrincipale('stato',
      function: TJSONValue
      var
        Interno: TJSONObject;
      begin
        Interno := TJSONObject.Create;
        if Application.MainForm <> nil then
        begin
          Interno.AddPair('form_principale', IndirizzoDi(Application.MainForm));
          Interno.AddPair('principale_visibile', TJSONBool.Create(Application.MainForm.Visible));
        end;
        if Screen.ActiveCustomForm <> nil then
          Interno.AddPair('form_attiva', IndirizzoDi(Screen.ActiveCustomForm));
        Interno.AddPair('dialoghi', ElencoDialoghi);
        // monitor collegati (quello scelto con Monitor= in zMCP_App.ini e'
        // segnato) e se il programma ha il fuoco di Windows: serve a chi
        // lavora sul computer mentre la sonda opera
        Interno.AddPair('monitor', ElencoMonitor);
        Interno.AddPair('in_primo_piano', TJSONBool.Create(ProgrammaInPrimoPiano));
        Result := Interno;
      end, TempoSondaggioMs, Errore);
    if Rilevato <> nil then
    begin
      Stato.AddPair('interfaccia', Rilevato);
      Stato.AddPair('occupato', TJSONBool.Create(False));
    end
    else
    begin
      Stato.AddPair('occupato', TJSONBool.Create(True));
      Stato.AddPair('nota', Errore);
    end;
    Elenco := TJSONArray.Create;
    FBlocco.Enter;
    try
      for Lavoro in FLavori do
        if not Lavoro.Completato and not Lavoro.Descrizione.StartsWith('lettura:') then
          Elenco.Add(Format('%d: %s (da %d s)', [Lavoro.Id, Lavoro.Descrizione, SecondsBetween(Now, Lavoro.Inizio)]));
      Stato.AddPair('eccezioni', TJSONNumber.Create(FEccezioni.Count));
    finally
      FBlocco.Leave;
    end;
    Stato.AddPair('lavori_in_corso', Elenco);
    Result := NuovaRisposta(Id, EsitoCompletato);
    Result.AddPair('risultato', Stato);
  end

  else if Comando = ComandoConfigura then
  begin
    FBlocco.Enter;
    try
      if (Argomenti <> nil) and Argomenti.TryGetValue<TJSONArray>('vietate', Elenco) then
      begin
        SetLength(FVietate, 0);
        for Voce in Elenco do
          FVietate := FVietate + [Voce.Value];
      end;
      if Argomenti <> nil then
        MostraEccezioniSonda := Argomenti.GetValue<Boolean>('mostra_eccezioni', MostraEccezioniSonda);
    finally
      FBlocco.Leave;
    end;
    Result := NuovaRisposta(Id, EsitoCompletato, Format('%d azioni vietate', [Length(FVietate)]));
    // il monitor su cui tenere le finestre: il gancio e le finestre sono del
    // thread principale, quindi si imposta li'
    if (Argomenti <> nil) and Argomenti.TryGetValue<Integer>('monitor', NumeroMonitor) then
    begin
      SulPrincipale('monitor',
        function: TJSONValue
        begin
          ImpostaMonitorSonda(NumeroMonitor);
          Result := TJSONString.Create(Format('monitor %d', [NumeroMonitor]));
        end, AttesaLetturaMs, Errore).Free;
      if Errore <> '' then
      begin
        Result.Free;
        Result := NuovaRisposta(Id, EsitoErrore, Errore);
      end;
    end;
  end

  else if Comando = ComandoForm then
    Result := ComandoLettura(Id, 'form',
      function: TJSONValue
      begin
        Result := ElencoForm;
      end)

  else if Comando = ComandoComponenti then
  begin
    Profondita := 2;
    if Argomenti <> nil then
      Profondita := Argomenti.GetValue<Integer>('profondita', 2);
    Result := ComandoLettura(Id, 'componenti',
      function: TJSONValue
      begin
        Result := AlberoComponenti(TrovaComponente(Indirizzo), Profondita);
      end);
  end

  else if Comando = ComandoAzioni then
    Result := ComandoLettura(Id, 'azioni',
      function: TJSONValue
      begin
        Result := ElencoAzioni(TrovaComponente(Indirizzo));
      end)

  else if Comando = ComandoMenu then
    Result := ComandoLettura(Id, 'menu',
      function: TJSONValue
      begin
        if Assigned(FornitoreMenuSonda) then
          Result := ElencoAzioniDa(FornitoreMenuSonda())
        else if Application.MainForm <> nil then
          Result := ElencoAzioni(Application.MainForm)
        else
          raise ESonda.Create('La form principale non c''e'' ancora (login in corso?).');
      end)

  else if Comando = ComandoEsegui then
    Result := ComandoAzione(Id, 'esegui ' + Indirizzo, AttesaMs,
      function: TJSONValue
      var
        Componente: TComponent;
        Divieto: string;
      begin
        Componente := TrovaComponente(Indirizzo);
        Divieto := AzioneVietata(Componente);
        if Divieto <> '' then
          raise ESonda.Create(Divieto);
        Result := TJSONString.Create(EseguiComponente(Componente));
      end)

  else if Comando = ComandoImposta then
  begin
    if Argomenti = nil then
      Exit(NuovaRisposta(Id, EsitoErrore, 'imposta: servono indirizzo, valore ed eventualmente campo.'));
    Campo := Argomenti.GetValue<string>('campo', '');
    Valore := Argomenti.GetValue<string>('valore', '');
    Result := ComandoAzione(Id, 'imposta ' + Indirizzo, AttesaMs,
      function: TJSONValue
      begin
        Result := TJSONString.Create(ImpostaValore(TrovaComponente(Indirizzo), Campo, Valore));
      end);
  end

  else if Comando = ComandoClic then
  begin
    ClicX := -1;
    ClicY := -1;
    Doppio := False;
    Modificatori := [];
    if Argomenti <> nil then
    begin
      ClicX := Argomenti.GetValue<Integer>('x', -1);
      ClicY := Argomenti.GetValue<Integer>('y', -1);
      Doppio := Argomenti.GetValue<Boolean>('doppio', False);
      try
        Modificatori := ModificatoriDaTesto(Argomenti.GetValue<string>('modificatori', ''));
      except
        on E: ESonda do
          Exit(NuovaRisposta(Id, EsitoErrore, E.Message));
      end;
    end;
    Result := ComandoAzione(Id, 'clic ' + Indirizzo, AttesaMs,
      function: TJSONValue
      var
        Componente: TComponent;
        Divieto: string;
      begin
        Componente := TrovaComponente(Indirizzo);
        Divieto := AzioneVietata(Componente);
        if Divieto <> '' then
          raise ESonda.Create(Divieto);
        Result := TJSONString.Create(ClicSuComponente(Componente, ClicX, ClicY, Doppio, Modificatori));
      end);
    AggiungiDialoghiAperti(Result);
  end

  else if Comando = ComandoMenuContestuale then
  begin
    ClicX := -1;
    ClicY := -1;
    NomeVoce := '';
    if Argomenti <> nil then
    begin
      ClicX := Argomenti.GetValue<Integer>('x', -1);
      ClicY := Argomenti.GetValue<Integer>('y', -1);
      NomeVoce := Argomenti.GetValue<string>('voce', '');
    end;
    Result := ComandoAzione(Id, 'menu contestuale ' + Indirizzo, AttesaMs,
      function: TJSONValue
      var
        Componente: TComponent;
        Divieto: string;
      begin
        Componente := TrovaComponente(Indirizzo);
        Divieto := AzioneVietata(Componente);
        if Divieto <> '' then
          raise ESonda.Create(Divieto);
        Result := MenuContestuale(Componente, ClicX, ClicY, NomeVoce, AzioneVietata);
      end);
    AggiungiDialoghiAperti(Result);
  end

  else if Comando = ComandoTrascina then
  begin
    ClicX := -1;
    ClicY := -1;
    SpostamentoX := 0;
    SpostamentoY := 0;
    Dimensione := -1;
    if Argomenti <> nil then
    begin
      ClicX := Argomenti.GetValue<Integer>('x', -1);
      ClicY := Argomenti.GetValue<Integer>('y', -1);
      SpostamentoX := Argomenti.GetValue<Integer>('dx', 0);
      SpostamentoY := Argomenti.GetValue<Integer>('dy', 0);
      Dimensione := Argomenti.GetValue<Integer>('dimensione', -1);
    end;
    Result := ComandoAzione(Id, 'trascina ' + Indirizzo, AttesaMs,
      function: TJSONValue
      var
        Componente: TComponent;
        Divieto: string;
      begin
        Componente := TrovaComponente(Indirizzo);
        Divieto := AzioneVietata(Componente);
        if Divieto <> '' then
          raise ESonda.Create(Divieto);
        Result := TrascinaSuComponente(Componente, ClicX, ClicY, SpostamentoX, SpostamentoY, Dimensione);
      end);
    AggiungiDialoghiAperti(Result);
  end

  else if Comando = ComandoTasti then
  begin
    TestoDigitato := '';
    Tasti := '';
    if Argomenti <> nil then
    begin
      TestoDigitato := Argomenti.GetValue<string>('testo', '');
      Tasti := Argomenti.GetValue<string>('tasti', '');
    end;
    Result := ComandoAzione(Id, 'tasti ' + Indirizzo, AttesaMs,
      function: TJSONValue
      var
        Componente, Predefinito: TComponent;
        Divieto: string;
      begin
        Componente := BersaglioTastiera(Indirizzo);
        Divieto := AzioneVietata(Componente);
        if Divieto <> '' then
          raise ESonda.Create(Divieto);
        // Invio preme anche il pulsante predefinito della form, qualunque sia
        // il controllo che riceve il tasto: le maschere vietate valgono per lui
        if ContainsText(Tasti, 'invio') or ContainsText(Tasti, 'enter') or (Pos(#13, TestoDigitato) > 0) then
        begin
          Predefinito := PulsantePredefinito(Componente);
          if Predefinito <> nil then
          begin
            Divieto := AzioneVietata(Predefinito);
            if Divieto <> '' then
              raise ESonda.Create('Invio premerebbe il pulsante predefinito della form. ' + Divieto);
          end;
        end;
        Result := TJSONString.Create(TastiSuComponente(Componente, TestoDigitato, Tasti));
      end);
    AggiungiDialoghiAperti(Result);
  end

  else if Comando = ComandoAttendi then
  begin
    NumeroLavoro := 0;
    if Argomenti <> nil then
      NumeroLavoro := Argomenti.GetValue<Integer>('lavoro', 0);
    Lavoro := TrovaLavoro(NumeroLavoro);
    if Lavoro = nil then
      Lavoro := LavoroSospeso;
    if Lavoro = nil then
      Exit(NuovaRisposta(Id, EsitoErrore, 'Nessun lavoro in corso da aspettare.'));
    Result := AttendiLavoro(Lavoro, AttesaMs);
    Result.RemovePair('id').Free;
    Result.AddPair('id', TJSONNumber.Create(Id));
  end

  else if Comando = ComandoDialoghi then
    Result := ComandoLettura(Id, 'dialoghi',
      function: TJSONValue
      begin
        Result := ElencoDialoghi;
      end)

  else if Comando = ComandoRispondi then
  begin
    if Argomenti = nil then
      Exit(NuovaRisposta(Id, EsitoErrore, 'rispondi: serve il pulsante (OK, Sì, No, Annulla o la didascalia).'));
    Pulsante := Argomenti.GetValue<string>('pulsante', '');
    // le maschere vietate valgono anche per i pulsanti dei dialoghi: il
    // dialogo delle eccezioni propone di aprire un ticket o mandare una mail
    FBlocco.Enter;
    try
      for Testo in FVietate do
        if MatchesMask(StripHotkey(Pulsante), Testo) then
          Exit(NuovaRisposta(Id, EsitoErrore, Format('Il pulsante "%s" e'' fra quelli vietati (%s) ' +
            'nella configurazione del banco.', [Pulsante, Testo])));
    finally
      FBlocco.Leave;
    end;
    Testo := Argomenti.GetValue<string>('testo', '');
    Finestra := HWND(Argomenti.GetValue<Int64>('finestra', 0));
    Lavoro := LavoroSospeso;
    Result := ComandoLettura(Id, 'rispondi',
      function: TJSONValue
      begin
        Result := TJSONString.Create(RispondiDialogo(Pulsante, Testo, Finestra));
      end);
    // il dialogo e' chiuso: l'azione che teneva fermo riprende, e la
    // risposta dice come va a finire (o il dialogo successivo)
    if (Result.GetValue<string>('esito', '') = EsitoCompletato) and (Lavoro <> nil) then
    begin
      Testo := Result.GetValue<string>('risultato', '');
      Result.Free;
      Result := AttendiLavoro(Lavoro, AttesaMs);
      Result.AddPair('risposta', Testo);
      Result.RemovePair('id').Free;
      Result.AddPair('id', TJSONNumber.Create(Id));
    end;
  end

  else if Comando = ComandoRegoleDialoghi then
  begin
    Regole := TList<TRegolaDialogo>.Create;
    try
      if (Argomenti <> nil) and Argomenti.TryGetValue<TJSONArray>('regole', Elenco) then
        for Voce in Elenco do
          if Voce is TJSONObject then
          begin
            Regola.Contiene := TJSONObject(Voce).GetValue<string>('contiene', '');
            Regola.Risposta := TJSONObject(Voce).GetValue<string>('risposta', '');
            if (Regola.Contiene <> '') and (Regola.Risposta <> '') then
              Regole.Add(Regola);
          end;
      FBlocco.Enter;
      try
        FRegole := Regole.ToArray;
      finally
        FBlocco.Leave;
      end;
      Result := NuovaRisposta(Id, EsitoCompletato, Format('%d regole di risposta attive', [Regole.Count]));
    finally
      Regole.Free;
    end;
  end

  else if Comando = ComandoDataset then
  begin
    Righe := 0;
    CampiDataset := nil;
    if Argomenti <> nil then
    begin
      Righe := Argomenti.GetValue<Integer>('righe', 0);
      CampiDataset := Argomenti.GetValue<string>('campi', '').Split([',', ';', ' '],
        TStringSplitOptions.ExcludeEmpty);
    end;
    // anche una vista, una scheda o una sorgente dati: il dataset che mostra
    Result := ComandoLettura(Id, 'dataset',
      function: TJSONValue
      begin
        Result := DescriviDataset(DatasetDi(TrovaComponente(Indirizzo)), Righe, CampiDataset);
      end);
  end

  else if Comando = ComandoEccezioni then
  begin
    Result := NuovaRisposta(Id, EsitoCompletato);
    FBlocco.Enter;
    try
      Result.AddPair('risultato', TJSONArray(FEccezioni.Clone));
      if (Argomenti <> nil) and Argomenti.GetValue<Boolean>('svuota', False) then
      begin
        FEccezioni.Free;
        FEccezioni := TJSONArray.Create;
      end;
    finally
      FBlocco.Leave;
    end;
  end

  else if Comando = ComandoImmagine then
    Result := ComandoLettura(Id, 'immagine',
      function: TJSONValue
      var
        Componente: TComponent;
      begin
        if Indirizzo = '' then
          Componente := Screen.ActiveCustomForm
        else
          Componente := TrovaComponente(Indirizzo);
        if not (Componente is TCustomForm) then
          raise ESonda.Create('L''immagine si fa di una form: indica il nome di una form aperta.');
        Result := TJSONString.Create(ImmagineForm(TCustomForm(Componente)));
      end)

  else if Comando = ComandoChiudi then
    Result := ComandoAzione(Id, 'chiudi', AttesaMs,
      function: TJSONValue
      begin
        if Application.MainForm = nil then
          Application.Terminate
        else
          Application.MainForm.Close;
        Result := TJSONString.Create('chiusura richiesta');
      end)

  else if Comando = ComandoBarra then
  begin
    Tutte := (Argomenti <> nil) and Argomenti.GetValue<Boolean>('tutte', False);
    Testo := '';
    if Argomenti <> nil then
      Testo := Argomenti.GetValue<string>('cerca', '');
    Result := ComandoLettura(Id, 'barra',
      function: TJSONValue
      begin
        Result := ElencoVociBarra(TrovaComponente(Indirizzo), Tutte, Testo);
      end);
  end

  // comandi del ponte dell'applicazione (filtri delle viste, skin)
  else if (ComandiRegistrati <> nil) and ComandiRegistrati.TryGetValue(LowerCase(Comando), Registrato) then
    Result := EseguiRegistrato(Id, Comando, Registrato, Argomenti, AttesaMs)

  else
    Result := NuovaRisposta(Id, EsitoErrore, Format('Comando sconosciuto: "%s".', [Comando]));
end;

initialization

finalization

FermaSonda;
FreeAndNil(ComandiRegistrati);

end.
