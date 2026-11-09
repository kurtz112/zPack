unit zDocumentale.Messaggi.ProviderBase;

// Classe base dei provider PEC: default che sollevano EzMessaggioNonSupportato,
// log via callback iniettate dal ponte (dmPec).

interface

uses
  System.SysUtils,
  zDocumentale.Messaggi.Types,
  zDocumentale.Messaggi.Intf;

type
  TzMessaggioProviderBase = class(TInterfacedObject, IzMessaggioProvider)
  private
    FOnLogRequest: TzMessaggioLogRequestFunc;
    FOnLogResponse: TzMessaggioLogResponseProc;
  protected
    FConfigurazione: TzMessaggioConfigurazione;

    procedure NonSupportato(const Operazione: string);
    function LogRequest(const Operazione, Endpoint, Richiesta: string): Int64;
    procedure LogResponse(IdLogRequest: Int64; HttpStatus: Integer;
      const Risposta, Errore: string);
  public
    constructor Create; virtual;

    // IzMessaggioProvider
    function Nome: string; virtual; abstract;
    function Funzionalita: TzMessaggioFunzionalitaSet; virtual;

    procedure Configura(const Configurazione: TzMessaggioConfigurazione); virtual;
    procedure TestConnessione; virtual;

    function Invia(const Messaggio: TzMessaggio): TzMessaggioEsito; virtual;
    function LeggiRicevute(const MessageIds: TArray<string>): TArray<TzMessaggioRicevuta>; virtual;

    property OnLogRequest: TzMessaggioLogRequestFunc read FOnLogRequest write FOnLogRequest;
    property OnLogResponse: TzMessaggioLogResponseProc read FOnLogResponse write FOnLogResponse;
  end;

implementation

{ TzMessaggioProviderBase }

constructor TzMessaggioProviderBase.Create;
begin
  inherited Create;
end;

procedure TzMessaggioProviderBase.NonSupportato(const Operazione: string);
begin
  raise EzMessaggioNonSupportato.CreateFmt(
    'Il fornitore PEC "%s" non supporta l''operazione %s', [Nome, Operazione]);
end;

function TzMessaggioProviderBase.LogRequest(const Operazione, Endpoint,
  Richiesta: string): Int64;
begin
  result := 0;
  if assigned(FOnLogRequest) then
    result := FOnLogRequest(Operazione, Endpoint, Richiesta);
end;

procedure TzMessaggioProviderBase.LogResponse(IdLogRequest: Int64; HttpStatus: Integer;
  const Risposta, Errore: string);
begin
  if assigned(FOnLogResponse) then
    FOnLogResponse(IdLogRequest, HttpStatus, Risposta, Errore);
end;

function TzMessaggioProviderBase.Funzionalita: TzMessaggioFunzionalitaSet;
begin
  result := [];
end;

procedure TzMessaggioProviderBase.Configura(const Configurazione: TzMessaggioConfigurazione);
begin
  FConfigurazione := Configurazione;
end;

procedure TzMessaggioProviderBase.TestConnessione;
begin
  NonSupportato('TestConnessione');
end;

function TzMessaggioProviderBase.Invia(const Messaggio: TzMessaggio): TzMessaggioEsito;
begin
  result.Clear;
  NonSupportato('Invia');
end;

function TzMessaggioProviderBase.LeggiRicevute(const MessageIds: TArray<string>): TArray<TzMessaggioRicevuta>;
begin
  result := nil;
  NonSupportato('LeggiRicevute');
end;

end.
