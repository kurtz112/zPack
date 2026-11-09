unit zDocumentale.Protocollo.Nessuno;

// Provider 'NESSUNO': non e' un no-op. Usa la numerazione di protocollo
// INTERNA dell'applicazione (in WT: GEDO_REGISTRI_PROTOCOLLO /
// GEDO_GET_NUMERO_PROTOCOLLO / GEDO_PROTOCOLLO) tramite una callback
// iniettata dal ponte applicativo (dmProtocollo), che e' l'unico a
// conoscere il database.
// Se la callback non e' assegnata (nessun registro configurato),
// Funzionalita = [] e la protocollazione non compare in UI.

interface

uses
  System.SysUtils,
  zDocumentale.Protocollo.Types,
  zDocumentale.Protocollo.Intf,
  zDocumentale.Protocollo.ProviderBase,
  zDocumentale.Protocollo.Factory;

type
  TzProtocolloNumerazioneInternaFunc = reference to function(
    const Documento: TzProtocolloDocumento): TzProtocolloEsito;

  TzProtocolloNessunoProvider = class(TzProtocolloProviderBase)
  private
    FNumerazioneInterna: TzProtocolloNumerazioneInternaFunc;
  public
    function Nome: string; override;
    function Funzionalita: TzProtocolloFunzionalitaSet; override;
    procedure TestConnessione; override;
    function Protocolla(const Documento: TzProtocolloDocumento): TzProtocolloEsito; override;

    // il ponte applicativo la assegna subito dopo TzProtocolloFactory.Crea
    // (il cast a TzProtocolloNessunoProvider e' legittimo solo li')
    property NumerazioneInterna: TzProtocolloNumerazioneInternaFunc
      read FNumerazioneInterna write FNumerazioneInterna;
  end;

implementation

{ TzProtocolloNessunoProvider }

function TzProtocolloNessunoProvider.Nome: string;
begin
  result := PROTOCOLLO_FORNITORE_NESSUNO;
end;

function TzProtocolloNessunoProvider.Funzionalita: TzProtocolloFunzionalitaSet;
begin
  if assigned(FNumerazioneInterna) then
    result := [pfProtocollaUscita]
  else
    result := [];
end;

procedure TzProtocolloNessunoProvider.TestConnessione;
begin
  // nessun servizio esterno: la configurazione e' valida se la numerazione
  // interna e' disponibile
  if not assigned(FNumerazioneInterna) then
    raise EzProtocolloErrore.Create(
      'Nessun registro di protocollo interno configurato');
end;

function TzProtocolloNessunoProvider.Protocolla(
  const Documento: TzProtocolloDocumento): TzProtocolloEsito;
begin
  result.Clear;
  if not assigned(FNumerazioneInterna) then
    NonSupportato('Protocolla');
  result := FNumerazioneInterna(Documento);
end;

initialization

TzProtocolloFactory.Registra(PROTOCOLLO_FORNITORE_NESSUNO, TzProtocolloNessunoProvider);

end.
