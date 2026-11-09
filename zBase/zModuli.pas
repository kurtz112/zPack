unit zModuli;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.Actions,
  Data.DB,
  Vcl.ActnList,
  zz.GenericCollection;

type
  TStatoAttivazione = (saUnknown, saAttivo, saNonAttivo, saValutazione, saSviluppo);

  TStatoAttivazioneHelper = record helper for TStatoAttivazione
  public
    function ToString: string;
    class function FromString(const s: String): TStatoAttivazione; static;
  end;

  TModulo = class(TCollectionItem)
  private
    FModulo: string;
    FStatoAttivazione: TStatoAttivazione;
    FTitolo: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Modulo: string read FModulo write FModulo;
    property Titolo: string read FTitolo write FTitolo;
    property StatoAttivazione: TStatoAttivazione read FStatoAttivazione write FStatoAttivazione;
  end;

  TModuli = class(TzGenericCollection<TModulo>)
  private
    function AddModulo(const Modulo, Titolo: string; const StatoAttivazione: TStatoAttivazione): TModulo;
  public
    procedure AddActionList(Actions: TActionList; saveProc: TProc<TModulo>);
    procedure LoadModuli(dataset: TDataSet);

    function GetModulo(const Modulo: string): TModulo;
    function GetStatoAttivazione(const Modulo: string): TStatoAttivazione;
  end;

implementation

{ TStatoAttivazioneHelper }

class function TStatoAttivazioneHelper.FromString(const s: String): TStatoAttivazione;
begin
  // Attivo      = A
  // Non Attivo  = N
  // Valutazione = V

  Result := saUnknown;

  if s.IsEmpty then
    Result := saUnknown
  else
    if s = 'A' then
      Result := saAttivo
    else
      if s = 'N' then
        Result := saNonAttivo
      else
        if s = 'V' then
          Result := saValutazione
        else
          if s = 'S' then
            Result := saSviluppo;
end;

function TStatoAttivazioneHelper.ToString: string;
begin
  // Attivo      = A
  // Non Attivo  = N
  // Valutazione = V

  case Self of
    saUnknown:
      Result := '';
    saAttivo:
      Result := 'A';
    saNonAttivo:
      Result := 'N';
    saValutazione:
      Result := 'V';
    saSviluppo:
      Result := 'S';
  end;
end;

{ TModulo }

constructor TModulo.Create(Collection: TCollection);
begin
  inherited;
  FModulo := '';
  FTitolo := '';
  FStatoAttivazione := saAttivo;
end;

procedure TModulo.Assign(Source: TPersistent);
var
  src: TModulo;
begin
  if Source is TModulo then
  begin
    src := TModulo(Source);
    FModulo := src.Modulo;
    FTitolo := src.Titolo;
    FStatoAttivazione := src.StatoAttivazione;
  end
  else
    inherited;
end;

function TModuli.AddModulo(const Modulo, Titolo: string; const StatoAttivazione: TStatoAttivazione): TModulo;
begin
  Result := GetModulo(Modulo);

  if not assigned(Result) then
  begin
    Result := Add;
    Result.Modulo := Modulo;
    Result.Titolo := Titolo;
    Result.StatoAttivazione := StatoAttivazione;
  end;
end;

procedure TModuli.AddActionList(Actions: TActionList; saveProc: TProc<TModulo>);
var
  Action: TContainedAction;
  Modulo: TModulo;
  StatoAttivazione: TStatoAttivazione;
begin

  if count = 0 then
    StatoAttivazione := saAttivo
  else
    StatoAttivazione := saValutazione;

  for Action in Actions do
  begin
    Modulo := GetModulo(Action.name);

    if not assigned(Modulo) then
    begin
      Modulo := AddModulo(Action.name, Action.Caption, StatoAttivazione);
      saveProc(Modulo);
    end;
  end;
end;

function TModuli.GetModulo(const Modulo: string): TModulo;
begin

  for Result in Self do
    if Result.Modulo.Equals(Modulo) then
      Exit;

  Result := nil;
end;

function TModuli.GetStatoAttivazione(const Modulo: string): TStatoAttivazione;
var
  item: TModulo;
begin
  Result := saUnknown;

  item := GetModulo(Modulo);

  if assigned(item) then
    Result := item.StatoAttivazione;
end;

procedure TModuli.LoadModuli(dataset: TDataSet);
var
  Modulo, Titolo: string;
  StatoAttivazione: string;
begin
  assert(assigned(dataset));

  dataset.Active := True;
  dataset.First;

  while not dataset.Eof do
  begin
    Modulo := dataset.FieldByName('MODULO').AsString;
    Titolo := dataset.FieldByName('TITOLO').AsString;
    StatoAttivazione := dataset.FieldByName('STATO_ATTIVAZIONE').AsString;
    AddModulo(Modulo, Titolo, TStatoAttivazione.FromString(StatoAttivazione));
    dataset.Next;
  end;
end;

end.
