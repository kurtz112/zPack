unit zDocumentale.Conservazione.ProviderBase;

// Classe base dei provider di conservazione: default che sollevano
// EzConservazioneNonSupportato, log via callback iniettate dal ponte.

interface

uses
  System.SysUtils,
  zDocumentale.Conservazione.Types,
  zDocumentale.Conservazione.Intf;

type
  TzConservazioneProviderBase = class(TInterfacedObject, IzConservazioneProvider)
  private
    FOnLogRequest: TzConservazioneLogRequestFunc;
    FOnLogResponse: TzConservazioneLogResponseProc;
  protected
    FConfigurazione: TzConservazioneConfigurazione;

    procedure NonSupportato(const Operazione: string);
    function LogRequest(const Operazione, Endpoint, Richiesta: string): Int64;
    procedure LogResponse(IdLogRequest: Int64; HttpStatus: Integer;
      const Risposta, Errore: string);
  public
    constructor Create; virtual;

    // IzConservazioneProvider
    function Nome: string; virtual; abstract;
    function Funzionalita: TzConservazioneFunzionalitaSet; virtual;

    procedure Configura(const Configurazione: TzConservazioneConfigurazione); virtual;
    procedure TestConnessione; virtual;

    function Versa(const Pacchetto: TzConservazionePacchetto): TzConservazioneEsito; virtual;
    function VerificaEsito(const IdPacchettoEsterno: string): TzConservazioneEsito; virtual;
    function ScaricaRapportoDiVersamento(const IdPacchettoEsterno,
      CartellaDestinazione: string): string; virtual;
    function Esibisci(const IdDocumentoEsterno, CartellaDestinazione: string): string; virtual;
    function Annulla(const IdPacchettoEsterno, Motivo: string): Boolean; virtual;

    property OnLogRequest: TzConservazioneLogRequestFunc read FOnLogRequest write FOnLogRequest;
    property OnLogResponse: TzConservazioneLogResponseProc read FOnLogResponse write FOnLogResponse;
  end;

implementation

{ TzConservazioneProviderBase }

constructor TzConservazioneProviderBase.Create;
begin
  inherited Create;
end;

procedure TzConservazioneProviderBase.NonSupportato(const Operazione: string);
begin
  raise EzConservazioneNonSupportato.CreateFmt(
    'Il conservatore "%s" non supporta l''operazione %s', [Nome, Operazione]);
end;

function TzConservazioneProviderBase.LogRequest(const Operazione, Endpoint,
  Richiesta: string): Int64;
begin
  result := 0;
  if assigned(FOnLogRequest) then
    result := FOnLogRequest(Operazione, Endpoint, Richiesta);
end;

procedure TzConservazioneProviderBase.LogResponse(IdLogRequest: Int64;
  HttpStatus: Integer; const Risposta, Errore: string);
begin
  if assigned(FOnLogResponse) then
    FOnLogResponse(IdLogRequest, HttpStatus, Risposta, Errore);
end;

function TzConservazioneProviderBase.Funzionalita: TzConservazioneFunzionalitaSet;
begin
  result := [];
end;

procedure TzConservazioneProviderBase.Configura(
  const Configurazione: TzConservazioneConfigurazione);
begin
  FConfigurazione := Configurazione;
end;

procedure TzConservazioneProviderBase.TestConnessione;
begin
  NonSupportato('TestConnessione');
end;

function TzConservazioneProviderBase.Versa(
  const Pacchetto: TzConservazionePacchetto): TzConservazioneEsito;
begin
  result.Clear;
  NonSupportato('Versa');
end;

function TzConservazioneProviderBase.VerificaEsito(
  const IdPacchettoEsterno: string): TzConservazioneEsito;
begin
  result.Clear;
  NonSupportato('VerificaEsito');
end;

function TzConservazioneProviderBase.ScaricaRapportoDiVersamento(
  const IdPacchettoEsterno, CartellaDestinazione: string): string;
begin
  result := '';
  NonSupportato('ScaricaRapportoDiVersamento');
end;

function TzConservazioneProviderBase.Esibisci(const IdDocumentoEsterno,
  CartellaDestinazione: string): string;
begin
  result := '';
  NonSupportato('Esibisci');
end;

function TzConservazioneProviderBase.Annulla(const IdPacchettoEsterno,
  Motivo: string): Boolean;
begin
  result := False;
  NonSupportato('Annulla');
end;

end.
