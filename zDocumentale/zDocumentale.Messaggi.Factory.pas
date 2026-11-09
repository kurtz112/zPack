unit zDocumentale.Messaggi.Factory;

// Factory dei provider PEC, con auto-registrazione.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  zDocumentale.Messaggi.Types,
  zDocumentale.Messaggi.Intf,
  zDocumentale.Messaggi.ProviderBase;

type
  TzMessaggioProviderClass = class of TzMessaggioProviderBase;

  TzMessaggioFactory = class
  private
    class var FRegistro: TDictionary<string, TzMessaggioProviderClass>;
    class function Registro: TDictionary<string, TzMessaggioProviderClass>; static;
  public
    class destructor Destroy;
    class procedure Registra(const Nome: string; ProviderClass: TzMessaggioProviderClass);
    class function Crea(const Nome: string): IzMessaggioProvider;
    class procedure ElencoFornitori(Elenco: TStrings);
  end;

const
  MESSAGGIO_FORNITORE_NESSUNO = 'NESSUNO';
  // il primo provider concreto previsto: casella PEC standard
  // (invio SMTP/S del gestore, lettura ricevute via IMAP) — fase successiva
  MESSAGGIO_FORNITORE_SMTP = 'SMTP';

implementation

{ TzMessaggioFactory }

class function TzMessaggioFactory.Registro: TDictionary<string, TzMessaggioProviderClass>;
begin
  if not assigned(FRegistro) then
    FRegistro := TDictionary<string, TzMessaggioProviderClass>.Create;
  result := FRegistro;
end;

class destructor TzMessaggioFactory.Destroy;
begin
  FreeAndNil(FRegistro);
end;

class procedure TzMessaggioFactory.Registra(const Nome: string;
  ProviderClass: TzMessaggioProviderClass);
begin
  Registro.AddOrSetValue(Nome.ToUpper, ProviderClass);
end;

class function TzMessaggioFactory.Crea(const Nome: string): IzMessaggioProvider;
var
  providerClass: TzMessaggioProviderClass;
  nomeRichiesto: string;
begin
  nomeRichiesto := Nome.Trim.ToUpper;
  if nomeRichiesto.IsEmpty then
    nomeRichiesto := MESSAGGIO_FORNITORE_NESSUNO;

  if not Registro.TryGetValue(nomeRichiesto, providerClass) then
    if not Registro.TryGetValue(MESSAGGIO_FORNITORE_NESSUNO, providerClass) then
      raise EzMessaggioErrore.CreateFmt(
        'Nessun provider PEC registrato per "%s"', [Nome]);

  result := providerClass.Create;
end;

class procedure TzMessaggioFactory.ElencoFornitori(Elenco: TStrings);
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
