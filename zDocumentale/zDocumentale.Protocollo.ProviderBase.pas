unit zDocumentale.Protocollo.ProviderBase;

// Classe base dei provider di protocollazione. Implementa l'intero contratto
// con default che sollevano EzProtocolloNonSupportato: ogni provider concreto
// sovrascrive solo cio' che il fornitore sa fare, e lo dichiara in Funzionalita.
// Il log tecnico passa dalle callback OnLogRequest/OnLogResponse, che il ponte
// applicativo aggancia alle SP OBJ_FILES_PROTOCOLLO_LOG_REQUEST_ADD/_RESPONSE_ADD.

interface

uses
  System.SysUtils,
  zDocumentale.Protocollo.Types,
  zDocumentale.Protocollo.Intf;

type
  TzProtocolloProviderBase = class(TInterfacedObject, IzProtocolloProvider)
  private
    FOnLogRequest: TzProtocolloLogRequestFunc;
    FOnLogResponse: TzProtocolloLogResponseProc;
  protected
    FConfigurazione: TzProtocolloConfigurazione;
    FConnessoFlag: Boolean;

    // solleva EzProtocolloNonSupportato citando fornitore e operazione
    procedure NonSupportato(const Operazione: string);

    // log tecnico: sicuri anche a callback non assegnate (ritorna 0 / no-op)
    function LogRequest(const Operazione, Endpoint, Richiesta: string): Int64;
    procedure LogResponse(IdLogRequest: Int64; HttpStatus: Integer;
      const Risposta, Errore: string);
  public
    constructor Create; virtual;

    // IzProtocolloProvider
    function Nome: string; virtual; abstract;
    function Funzionalita: TzProtocolloFunzionalitaSet; virtual;

    procedure Configura(const Configurazione: TzProtocolloConfigurazione); virtual;
    procedure Connetti; virtual;
    procedure Disconnetti; virtual;
    function Connesso: Boolean; virtual;
    procedure TestConnessione; virtual;

    function Protocolla(const Documento: TzProtocolloDocumento): TzProtocolloEsito; virtual;
    function PrenotaNumero(const Documento: TzProtocolloDocumento): TzProtocolloEsito; virtual;
    function AggiungiAllegato(const IdDocumentoEsterno: string;
      const Allegato: TzProtocolloAllegato): Boolean; virtual;
    function AggiornaEstremi(const IdDocumentoEsterno: string): TzProtocolloEsito; virtual;
    function Annulla(const IdDocumentoEsterno, Motivo: string): Boolean; virtual;

    function RicercaPerSoggetto(const ChiaveRicerca: string): TArray<TzProtocolloDocumentoTrovato>; virtual;
    function RicercaPerPeriodo(const DalGiorno, AlGiorno: TDate): TArray<TzProtocolloDocumentoTrovato>; virtual;
    function ScaricaAllegati(const IdDocumentoEsterno,
      CartellaDestinazione: string): TArray<TzProtocolloAllegato>; virtual;

    property OnLogRequest: TzProtocolloLogRequestFunc read FOnLogRequest write FOnLogRequest;
    property OnLogResponse: TzProtocolloLogResponseProc read FOnLogResponse write FOnLogResponse;
  end;

implementation

{ TzProtocolloProviderBase }

constructor TzProtocolloProviderBase.Create;
begin
  inherited Create;
  FConnessoFlag := False;
end;

procedure TzProtocolloProviderBase.NonSupportato(const Operazione: string);
begin
  raise EzProtocolloNonSupportato.CreateFmt(
    'Il fornitore di protocollo "%s" non supporta l''operazione %s', [Nome, Operazione]);
end;

function TzProtocolloProviderBase.LogRequest(const Operazione, Endpoint,
  Richiesta: string): Int64;
begin
  result := 0;
  if assigned(FOnLogRequest) then
    result := FOnLogRequest(Operazione, Endpoint, Richiesta);
end;

procedure TzProtocolloProviderBase.LogResponse(IdLogRequest: Int64;
  HttpStatus: Integer; const Risposta, Errore: string);
begin
  if assigned(FOnLogResponse) then
    FOnLogResponse(IdLogRequest, HttpStatus, Risposta, Errore);
end;

function TzProtocolloProviderBase.Funzionalita: TzProtocolloFunzionalitaSet;
begin
  result := [];
end;

procedure TzProtocolloProviderBase.Configura(const Configurazione: TzProtocolloConfigurazione);
begin
  FConfigurazione := Configurazione;
end;

procedure TzProtocolloProviderBase.Connetti;
begin
  FConnessoFlag := True;
end;

procedure TzProtocolloProviderBase.Disconnetti;
begin
  FConnessoFlag := False;
end;

function TzProtocolloProviderBase.Connesso: Boolean;
begin
  result := FConnessoFlag;
end;

procedure TzProtocolloProviderBase.TestConnessione;
begin
  NonSupportato('TestConnessione');
end;

function TzProtocolloProviderBase.Protocolla(const Documento: TzProtocolloDocumento): TzProtocolloEsito;
begin
  result.Clear;
  NonSupportato('Protocolla');
end;

function TzProtocolloProviderBase.PrenotaNumero(const Documento: TzProtocolloDocumento): TzProtocolloEsito;
begin
  result.Clear;
  NonSupportato('PrenotaNumero');
end;

function TzProtocolloProviderBase.AggiungiAllegato(const IdDocumentoEsterno: string;
  const Allegato: TzProtocolloAllegato): Boolean;
begin
  result := False;
  NonSupportato('AggiungiAllegato');
end;

function TzProtocolloProviderBase.AggiornaEstremi(const IdDocumentoEsterno: string): TzProtocolloEsito;
begin
  result.Clear;
  NonSupportato('AggiornaEstremi');
end;

function TzProtocolloProviderBase.Annulla(const IdDocumentoEsterno, Motivo: string): Boolean;
begin
  result := False;
  NonSupportato('Annulla');
end;

function TzProtocolloProviderBase.RicercaPerSoggetto(const ChiaveRicerca: string): TArray<TzProtocolloDocumentoTrovato>;
begin
  result := nil;
  NonSupportato('RicercaPerSoggetto');
end;

function TzProtocolloProviderBase.RicercaPerPeriodo(const DalGiorno, AlGiorno: TDate): TArray<TzProtocolloDocumentoTrovato>;
begin
  result := nil;
  NonSupportato('RicercaPerPeriodo');
end;

function TzProtocolloProviderBase.ScaricaAllegati(const IdDocumentoEsterno,
  CartellaDestinazione: string): TArray<TzProtocolloAllegato>;
begin
  result := nil;
  NonSupportato('ScaricaAllegati');
end;

end.
