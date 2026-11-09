unit zTimers;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.ExtCtrls;

type
  TTimers = class;

  TTimerItem = class(TCollectionItem)
  private
    FCallback: TProc;
    FId: string;
    FTimer: TTimer;
    Timers: TTimers;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Init(const Id: string; interval: integer; Callback: TProc);
  public
    property Id: string read FId;
    property Callback: TProc read FCallback;
    property Timer: TTimer read FTimer;
  end;

  TTimers = class(TCollection)
  private
    Owner: TComponent;
    function GetOwnerName: String;
  protected
    destroying: boolean;
    property OwnerName: String read GetOwnerName;
  public
    constructor Create(aOwner: TComponent);
    destructor Destroy; override;
    procedure Add(const Id: string; interval: integer; Callback: TProc);
  end;

implementation

uses
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

var
  siTimers: TSiSession;

  { TTimerItem }

constructor TTimerItem.Create(Collection: TCollection);
begin
  inherited;
  Timers := Collection as TTimers;
  FId := '';;
  FCallback := nil;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;
end;

destructor TTimerItem.Destroy;
begin
  FTimer.Enabled := False;
  FTimer.OnTimer := nil;
  FreeAndNil(FTimer);

  inherited;
end;

procedure TTimerItem.Init(const Id: string; interval: integer; Callback: TProc);
begin
  siTimers.LogString('Init', Timers.OwnerName + '.' + Id);
  FTimer.Enabled := False;
  FTimer.interval := interval;
  FId := Id;
  FCallback := Callback;
  FTimer.Enabled := True;
end;

procedure TTimerItem.OnTimer(Sender: TObject);
begin
  try
    siTimers.LogString('After', Timers.OwnerName + '.' + Id);

    if Timers.destroying then
      Exit;

    FTimer.Enabled := False;

    if Assigned(FCallback) then
      Callback;

  finally
    Self.Free; // tenere d'occhio
  end;
end;

{ TTimers }

constructor TTimers.Create(aOwner: TComponent);
begin
  inherited Create(TTimerItem);
  destroying := False;
  Owner := aOwner;
end;

destructor TTimers.Destroy;
begin
  // siTimers.EnterMethod(Self, 'Destroy: ' + OwnerName);

  destroying := True;
  inherited;

  // siTimers.LeaveMethod(Self, 'Destroy: ' + OwnerName);
end;

procedure TTimers.Add(const Id: string; interval: integer; Callback: TProc);
var
  i: integer;
  item: TTimerItem;
begin
  siTimers.EnterMethod(Self, 'Add: ' + OwnerName);

  if destroying then
    Exit;

  item := nil;

  if not Id.IsEmpty then
    for i := 0 to Count - 1 do
    begin
      item := TTimerItem(Items[i]);

      if SameText(item.Id, Id) then
        Break;
    end;

  if not Assigned(item) then
    item := TTimerItem(inherited Add);

  item.Init(Id, interval, Callback);

  siTimers.LeaveMethod(Self, 'Add: ' + OwnerName);
end;

function TTimers.GetOwnerName: String;
  function GetFullComponentName(Component: TComponent): string;
  var
    aOwner: TComponent;
  begin
    Result := Component.Name;
    aOwner := Component.Owner;
    while Assigned(aOwner) do
    begin
      Result := aOwner.Name + '.' + Result;
      aOwner := aOwner.Owner;
    end;
  end;

begin
  Result := GetFullComponentName(Owner);
end;

initialization

siTimers := Si.AddSession('Timers', True);

finalization

siTimers := nil;

end.
