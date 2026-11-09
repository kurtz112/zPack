unit zVariables;

interface

uses
  SysUtils,
  Classes,
  Forms,
  Variants,
  zCollection;

type
  TzVariableItem = class(TzCollectionItem)
  private
    FDescription: string;
    FValue: Variant;
    procedure SetDescription(const Value: string);
    procedure SetValue(const Value: Variant);
  protected
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Description: string read FDescription write SetDescription;
    property Value: Variant read FValue write SetValue;
    { TODO : 
asString
asBoolean
etc }
  end;

  TzVariables = class(TzCollection)
  private
    function GetItem(Index: Integer): TzVariableItem;
    procedure SetItem(Index: Integer; const Value: TzVariableItem);
  protected
  public
    function Add: TzVariableItem;
    function Insert(Index: Integer): TzVariableItem;
    property Items[Index: Integer]: TzVariableItem read GetItem write SetItem; default;
  end;

implementation

{ TzVariables }

{ TzVariableItem }

procedure TzVariableItem.Assign(Source: TPersistent);
begin
  if Source is TzVariableItem then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzVariableItem(Source).Name;
      Description := TzVariableItem(Source).Description;
      Value := TzVariableItem(Source).Value;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

constructor TzVariableItem.Create(Collection: TCollection);
begin
  inherited;
  fDescription := '';
  fValue:=Null;
end;

procedure TzVariableItem.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TzVariableItem.SetValue(const Value: Variant);
begin
  FValue := Value;
end;

{ TzVariables }

function TzVariables.Add: TzVariableItem;
begin
  Result := TzVariableItem(inherited Add);
end;

function TzVariables.Insert(Index: Integer): TzVariableItem;
begin
  Result := TzVariableItem(inherited Insert(Index));
end;

function TzVariables.GetItem(Index: Integer): TzVariableItem;
begin
  Result := TzVariableItem(inherited Items[Index]);
end;

procedure TzVariables.SetItem(Index: Integer; const Value: TzVariableItem);
begin
  Items[Index].Assign(Value);
end;

end.

