unit zz.Vcl;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Rtti,
  System.ImageList,
  Vcl.Controls,
  Data.DB;

type
  TComponentHelper = class helper for TComponent
  public
    function GetComponent<T: TComponent>(const Name: string): T;
    procedure ForEach<T: TComponent>(proc: TProc<T>);
    function CountComponent<T: TComponent>: integer;
  end;

  TWinControlHelper = class helper for TWinControl
  public
    procedure ForEach<T: TComponent>(proc: TProc<T>);
    procedure ForEachControl<T: TControl>(proc: TProc<T>);
    function CountControl<T: TControl>: integer;
  end;

implementation

function TComponentHelper.CountComponent<T>: integer;
var
  comp: TComponent;
begin
  Result := 0;

  for comp in Self do
    if comp is T then
      inc(Result);
end;

{ TComponentHelper }

procedure TComponentHelper.ForEach<T>(proc: TProc<T>);
var
  comp: TComponent;
begin
  assert(Assigned(proc));

  for comp in Self do
    if comp is T then
      proc(T(comp));
end;

function TComponentHelper.GetComponent<T>(const Name: string): T;
var
  comp: TComponent;
begin
  Result := nil;

  comp := FindComponent(name);

  if Assigned(comp) then
    if comp is T then
      Result := T(comp);
end;

function TWinControlHelper.CountControl<T>: integer;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to ControlCount - 1 do
    if Controls[i] is T then
      inc(Result);
end;

{ TControlHelper }

procedure TWinControlHelper.ForEach<T>(proc: TProc<T>);
var
  comp: TComponent;
begin
  assert(Assigned(proc));

  for comp in Self do
    if comp is T then
      proc(T(comp));
end;

procedure TWinControlHelper.ForEachControl<T>(proc: TProc<T>);
var
  i: integer;
begin
  assert(Assigned(proc));

  for i := 0 to ControlCount - 1 do
    if Controls[i] is T then
      proc(T(Controls[i]));
end;

end.
