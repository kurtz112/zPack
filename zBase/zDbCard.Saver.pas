unit zDbCard.Saver;

// =============================================================================
// Salvataggio differito e coalizzato su thread (estratto da TzDbCard).
//
// Una raffica di richieste (es. i tick di uno spinner) produce UN solo
// salvataggio; le richieste arrivate mentre un task e' in volo vengono
// accodate e rilanciate a fine task tramite OnRepostRequest.
//
// Il guard refcounted (IzCardAliveGuard) sopravvive al proprietario: le
// closure asincrone (TThread.Queue) lo catturano e verificano Alive prima di
// toccare lo stato, cosi' una card distrutta tra il completamento del task e
// il dispatch della Queue non produce accessi a memoria liberata.
// =============================================================================

interface

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  IzCardAliveGuard = interface
    ['{8F4D2A91-3C7B-4E6A-9D15-B82E4F6C1A37}']
    function GetAlive: boolean;
    procedure SetAlive(const Value: boolean);
    property Alive: boolean read GetAlive write SetAlive;
  end;

  TzCardAliveGuard = class(TInterfacedObject, IzCardAliveGuard)
  private
    FAlive: boolean;
    function GetAlive: boolean;
    procedure SetAlive(const Value: boolean);
  public
    constructor Create;
  end;

  TzDeferredSaver = class
  private
    FRunning: boolean;
    FQueuedRequest: boolean;
    FTask: ITask;
    FGuard: IzCardAliveGuard;
    FOnPrepare: TProc;
    FOnExecuteSave: TProc;
    FOnRepostRequest: TProc;
    FOnSaveError: TProc<string>;
  public
    constructor Create;
    destructor Destroy; override;

    // Avvia un salvataggio in background (OnPrepare sul thread UI, poi
    // OnExecuteSave nel task); se uno e' gia' in corso accoda la richiesta.
    procedure RequestSave;

    // True se un salvataggio era in corso: la richiesta e' stata accodata e
    // chi voleva salvare in sincrono deve rinunciare (il task in volo
    // ripartira' e salvera' anche le modifiche correnti).
    function DeferIfRunning: boolean;

    // Attende il task in volo (timeout difensivo: in caso di blocco del DB
    // meglio un leak che un deadlock alla chiusura) e disattiva le closure
    // residue: da qui in poi nessun callback tocca piu' il proprietario.
    procedure Shutdown(const TimeoutMs: cardinal);

    function HasQueuedRequest: boolean;
    procedure ClearQueuedRequest;

    // Thread UI, prima di avviare il task (es. descale DPI dei props)
    property OnPrepare: TProc read FOnPrepare write FOnPrepare;
    // Thread di background: la scrittura vera e propria
    property OnExecuteSave: TProc read FOnExecuteSave write FOnExecuteSave;
    // Thread UI, a fine task: rilancio della richiesta accodata
    property OnRepostRequest: TProc read FOnRepostRequest write FOnRepostRequest;
    // Thread UI, a fine task: l'errore della scrittura (classe e messaggio). L'errore e'
    // comunque scritto nel registro diagnostico anche senza gestore
    property OnSaveError: TProc<string> read FOnSaveError write FOnSaveError;
  end;

implementation

var
  SiSaver: TSiSession;

{ TzCardAliveGuard }

constructor TzCardAliveGuard.Create;
begin
  inherited Create;
  FAlive := true;
end;

function TzCardAliveGuard.GetAlive: boolean;
begin
  result := FAlive;
end;

procedure TzCardAliveGuard.SetAlive(const Value: boolean);
begin
  FAlive := Value;
end;

{ TzDeferredSaver }

constructor TzDeferredSaver.Create;
begin
  inherited Create;
  FGuard := TzCardAliveGuard.Create;
end;

destructor TzDeferredSaver.Destroy;
begin
  // Il proprietario deve aver gia' chiamato Shutdown; in difesa si disattivano
  // comunque le closure residue.
  FGuard.Alive := false;
  inherited;
end;

procedure TzDeferredSaver.RequestSave;
var
  guard: IzCardAliveGuard;
  saveProc: TProc;
  ErrorText: string;
begin
  if FRunning then
  begin
    // Un salvataggio e' gia' in corso: ripeti a fine task (vedi TThread.Queue)
    FQueuedRequest := true;
    Exit;
  end;

  if Assigned(FOnPrepare) then
    FOnPrepare();

  // ITask invece di thread anonimo: il proprietario puo' attendere (Shutdown)
  // un salvataggio in volo prima di liberare i dati serializzati. saveProc e'
  // catturato per valore: il task non rilegge lo stato del saver.
  guard := FGuard;
  saveProc := FOnExecuteSave;
  FRunning := true;
  FTask := TTask.Run(
    procedure
    begin
      ErrorText := '';
      try
        try
          if Assigned(saveProc) then
            saveProc();
        except
          // DIV-CMD-4: l'errore del task non va perso (database irraggiungibile, errore
          // di scrittura): il task lo conservava e nessuno lo leggeva
          on E: Exception do
          begin
            ErrorText := E.ClassName + ': ' + E.Message;
            if Assigned(SiSaver) then
              SiSaver.LogError('Salvataggio impostazioni card: ' + ErrorText);
          end;
        end;
      finally
        TThread.Queue(nil,
          procedure
          begin
            if not guard.Alive then
              Exit; // proprietario distrutto: nessun accesso a Self
            FRunning := false;
            if (ErrorText <> '') and Assigned(FOnSaveError) then
              FOnSaveError(ErrorText);
            if FQueuedRequest then
            begin
              FQueuedRequest := false;
              if Assigned(FOnRepostRequest) then
                FOnRepostRequest();
            end;
          end);
      end;
    end);
end;

function TzDeferredSaver.DeferIfRunning: boolean;
begin
  result := FRunning;
  if result then
    FQueuedRequest := true;
end;

procedure TzDeferredSaver.Shutdown(const TimeoutMs: cardinal);
begin
  if Assigned(FTask) then
  begin
    try
      FTask.Wait(TimeoutMs);
    except
      // eccezione nel task o timeout: prosegue comunque
    end;
    FTask := nil;
    FRunning := false;
  end;

  // Da qui le closure asincrone residue (TThread.Queue) non toccano piu' Self
  FGuard.Alive := false;
end;

function TzDeferredSaver.HasQueuedRequest: boolean;
begin
  result := FQueuedRequest;
end;

procedure TzDeferredSaver.ClearQueuedRequest;
begin
  FQueuedRequest := false;
end;

initialization
  SiSaver := Si.AddSession('zDbCard.Saver', true);

finalization
  SiSaver := nil;

end.
