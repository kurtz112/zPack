unit zDocumentale.Messaggi.Nessuno;

// Provider 'NESSUNO' per la PEC: come la firma, la PEC non ha un
// equivalente "interno" — richiede sempre una casella/fornitore.
// Funzionalita = []: senza configurazione il comando non compare in UI.

interface

uses
  zDocumentale.Messaggi.Types,
  zDocumentale.Messaggi.ProviderBase,
  zDocumentale.Messaggi.Factory;

type
  TzMessaggioNessunoProvider = class(TzMessaggioProviderBase)
  public
    function Nome: string; override;
    function Funzionalita: TzMessaggioFunzionalitaSet; override;
  end;

implementation

{ TzMessaggioNessunoProvider }

function TzMessaggioNessunoProvider.Nome: string;
begin
  result := MESSAGGIO_FORNITORE_NESSUNO;
end;

function TzMessaggioNessunoProvider.Funzionalita: TzMessaggioFunzionalitaSet;
begin
  result := [];
end;

initialization

TzMessaggioFactory.Registra(MESSAGGIO_FORNITORE_NESSUNO, TzMessaggioNessunoProvider);

end.
