unit zDocumentale.Conservazione.Nessuno;

// Provider 'NESSUNO' per la conservazione: a differenza del protocollo
// (che ha la numerazione interna) NON esiste una "conservazione interna" —
// la conservazione a norma e' un servizio che solo un conservatore
// accreditato eroga. Funzionalita = []: senza fornitore configurato il
// comando non compare in UI.

interface

uses
  zDocumentale.Conservazione.Types,
  zDocumentale.Conservazione.ProviderBase,
  zDocumentale.Conservazione.Factory;

type
  TzConservazioneNessunoProvider = class(TzConservazioneProviderBase)
  public
    function Nome: string; override;
    function Funzionalita: TzConservazioneFunzionalitaSet; override;
  end;

implementation

{ TzConservazioneNessunoProvider }

function TzConservazioneNessunoProvider.Nome: string;
begin
  result := CONSERVAZIONE_FORNITORE_NESSUNO;
end;

function TzConservazioneNessunoProvider.Funzionalita: TzConservazioneFunzionalitaSet;
begin
  result := [];
end;

initialization

TzConservazioneFactory.Registra(CONSERVAZIONE_FORNITORE_NESSUNO, TzConservazioneNessunoProvider);

end.
