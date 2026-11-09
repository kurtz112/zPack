unit zDocumentale.Conservazione.Factory;

// Factory dei provider di conservazione, con auto-registrazione.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  zDocumentale.Conservazione.Types,
  zDocumentale.Conservazione.Intf,
  zDocumentale.Conservazione.ProviderBase;

type
  TzConservazioneProviderClass = class of TzConservazioneProviderBase;

  TzConservazioneFactory = class
  private
    class var FRegistro: TDictionary<string, TzConservazioneProviderClass>;
    class function Registro: TDictionary<string, TzConservazioneProviderClass>; static;
  public
    class destructor Destroy;
    class procedure Registra(const Nome: string; ProviderClass: TzConservazioneProviderClass);
    class function Crea(const Nome: string): IzConservazioneProvider;
    class procedure ElencoFornitori(Elenco: TStrings);
  end;

const
  CONSERVAZIONE_FORNITORE_NESSUNO = 'NESSUNO';

implementation

{ TzConservazioneFactory }

class function TzConservazioneFactory.Registro: TDictionary<string, TzConservazioneProviderClass>;
begin
  if not assigned(FRegistro) then
    FRegistro := TDictionary<string, TzConservazioneProviderClass>.Create;
  result := FRegistro;
end;

class destructor TzConservazioneFactory.Destroy;
begin
  FreeAndNil(FRegistro);
end;

class procedure TzConservazioneFactory.Registra(const Nome: string;
  ProviderClass: TzConservazioneProviderClass);
begin
  Registro.AddOrSetValue(Nome.ToUpper, ProviderClass);
end;

class function TzConservazioneFactory.Crea(const Nome: string): IzConservazioneProvider;
var
  providerClass: TzConservazioneProviderClass;
  nomeRichiesto: string;
begin
  nomeRichiesto := Nome.Trim.ToUpper;
  if nomeRichiesto.IsEmpty then
    nomeRichiesto := CONSERVAZIONE_FORNITORE_NESSUNO;

  if not Registro.TryGetValue(nomeRichiesto, providerClass) then
    if not Registro.TryGetValue(CONSERVAZIONE_FORNITORE_NESSUNO, providerClass) then
      raise EzConservazioneErrore.CreateFmt(
        'Nessun provider di conservazione registrato per "%s"', [Nome]);

  result := providerClass.Create;
end;

class procedure TzConservazioneFactory.ElencoFornitori(Elenco: TStrings);
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
