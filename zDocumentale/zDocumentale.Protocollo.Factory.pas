unit zDocumentale.Protocollo.Factory;

// Factory dei provider di protocollazione, con auto-registrazione:
// ogni provider concreto si registra nella propria sezione initialization.
// Aggiungere un fornitore = una unit nuova + una riga nel .dpr. Zero case.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  zDocumentale.Protocollo.Types,
  zDocumentale.Protocollo.Intf,
  zDocumentale.Protocollo.ProviderBase;

type
  TzProtocolloProviderClass = class of TzProtocolloProviderBase;

  TzProtocolloFactory = class
  private
    class var FRegistro: TDictionary<string, TzProtocolloProviderClass>;
    class function Registro: TDictionary<string, TzProtocolloProviderClass>; static;
  public
    class destructor Destroy;
    class procedure Registra(const Nome: string; ProviderClass: TzProtocolloProviderClass);
    // nome vuoto o sconosciuto: ricade sul provider 'NESSUNO'
    class function Crea(const Nome: string): IzProtocolloProvider;
    class procedure ElencoFornitori(Elenco: TStrings);
  end;

const
  PROTOCOLLO_FORNITORE_NESSUNO = 'NESSUNO';

implementation

{ TzProtocolloFactory }

class function TzProtocolloFactory.Registro: TDictionary<string, TzProtocolloProviderClass>;
begin
  if not assigned(FRegistro) then
    FRegistro := TDictionary<string, TzProtocolloProviderClass>.Create;
  result := FRegistro;
end;

class destructor TzProtocolloFactory.Destroy;
begin
  FreeAndNil(FRegistro);
end;

class procedure TzProtocolloFactory.Registra(const Nome: string;
  ProviderClass: TzProtocolloProviderClass);
begin
  Registro.AddOrSetValue(Nome.ToUpper, ProviderClass);
end;

class function TzProtocolloFactory.Crea(const Nome: string): IzProtocolloProvider;
var
  providerClass: TzProtocolloProviderClass;
  nomeRichiesto: string;
begin
  nomeRichiesto := Nome.Trim.ToUpper;
  if nomeRichiesto.IsEmpty then
    nomeRichiesto := PROTOCOLLO_FORNITORE_NESSUNO;

  if not Registro.TryGetValue(nomeRichiesto, providerClass) then
    if not Registro.TryGetValue(PROTOCOLLO_FORNITORE_NESSUNO, providerClass) then
      raise EzProtocolloErrore.CreateFmt(
        'Nessun provider di protocollo registrato per "%s"', [Nome]);

  result := providerClass.Create;
end;

class procedure TzProtocolloFactory.ElencoFornitori(Elenco: TStrings);
var
  nomeFornitore: string;
begin
  Assert(assigned(Elenco));
  Elenco.BeginUpdate;
  try
    Elenco.Clear;
    for nomeFornitore in Registro.Keys do
      Elenco.Add(nomeFornitore);
  finally
    Elenco.EndUpdate;
  end;
end;

end.
