unit ActionListController;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  ActnList,
  Actions,
  StdActns;

type
  TActionListController = class(TObject)
  private
    FBusy: Boolean;
    List: TDictionary<TCustomAction, TNotifyEvent>;
    procedure ExecuteAction(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure InitActions(ActionOwner: TComponent);

    procedure register(Action: TCustomAction); overload;
    procedure register(ActionList: TActionList); overload;
    property Busy: Boolean read FBusy write FBusy;
  end;

implementation

{ TActionListController }

constructor TActionListController.Create;
begin
  inherited Create;
  FBusy := False;
  List := TDictionary<TCustomAction, TNotifyEvent>.Create;
end;

destructor TActionListController.Destroy;
begin
  FreeAndNil(List);
  inherited;
end;

procedure TActionListController.ExecuteAction(Sender: TObject);
var
  Action: TCustomAction;
  Pair: TPair<TAction, TNotifyEvent>;
  Event: TNotifyEvent;
begin
  if Busy then
    Exit;

  Action := Sender as TCustomAction;

  Event := List.Items[Action];

  if not Assigned(Event) then
    Exit;

  Action.Enabled := False;
  try
    Event(Action);
  finally
    Action.Enabled := True;
  end;
end;

procedure TActionListController.InitActions(ActionOwner: TComponent);
var
  Comp: TComponent;
begin
  if Assigned(ActionOwner) then
    for Comp in ActionOwner do
      if Comp is TAction then
        register(Comp as TAction);
end;

procedure TActionListController.register(ActionList: TActionList);
var
  Action: TContainedAction;
begin
  for Action in ActionList do
    if Action is TCustomAction then
      Register(Action as TCustomAction);
end;

procedure TActionListController.register(Action: TCustomAction);
begin
  // ZZ 14.06.2012 Esistono azioni, tipo le TWindowAction che vengono bloccate se gestite in questo modo.
  if (not Assigned(Action.OnExecute)) then
    Exit;

  List.Add(Action, Action.OnExecute);
  Action.OnExecute := ExecuteAction;
end;

end.



