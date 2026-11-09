unit zDocumentale.Firma.Nessuno;

// Provider 'NESSUNO' per la firma: NON esiste una "firma interna"
// equivalente alla numerazione interna del protocollo — la firma richiede
// sempre un fornitore esterno (l'alternativa, un certificato locale sul
// client, e' un caso d'uso diverso e fuori perimetro).
// Funzionalita = []: senza fornitore configurato il comando non compare in UI.

interface

uses
  zDocumentale.Firma.Types,
  zDocumentale.Firma.ProviderBase,
  zDocumentale.Firma.Factory;

type
  TzFirmaNessunoProvider = class(TzFirmaProviderBase)
  public
    function Nome: string; override;
    function Funzionalita: TzFirmaFunzionalitaSet; override;
  end;

implementation

{ TzFirmaNessunoProvider }

function TzFirmaNessunoProvider.Nome: string;
begin
  result := FIRMA_FORNITORE_NESSUNO;
end;

function TzFirmaNessunoProvider.Funzionalita: TzFirmaFunzionalitaSet;
begin
  result := [];
end;

initialization

TzFirmaFactory.Registra(FIRMA_FORNITORE_NESSUNO, TzFirmaNessunoProvider);

end.
