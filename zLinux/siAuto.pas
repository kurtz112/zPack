unit SiAuto;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TsiSession = record
  public
    procedure LogString(const title, value: string);
    procedure LogSeparator;
    procedure LogException(E: exception);
  end;

var
  siMain: TsiSession;

implementation

{ TsiSession }

procedure TsiSession.LogException(E: exception);
begin

end;

procedure TsiSession.LogSeparator;
begin

end;

procedure TsiSession.LogString(const title, value: string);
begin

end;

end.
