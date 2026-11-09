unit zz.Nullable;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti;

type
  {$RTTI EXPLICIT FIELDS([vcPrivate]) METHODS([vcPrivate])}
  Nullable<T> = packed record
  private
    FValue: T;
    FHasValue: Boolean;
    function GetValue: T;
    function GetHasValue: Boolean;
    function GetIsNull: Boolean;
    function GetIsEmpty: Boolean;
    function GetValueType: PTypeInfo;
    procedure SetValue(const AValue: T);
    class function VarIsNullOrEmpty(const Value: Variant; trimWhiteSpace: Boolean = False): Boolean; static;
  public
    constructor Create(const Value: T); overload;
    constructor Create(const Value: Variant); overload;

    procedure Clear;

    function GetValueOrDefault: T; overload;
    function GetValueOrDefault(const defaultValue: T): T; overload;

    property HasValue: Boolean read GetHasValue;
    property IsNull: Boolean read GetIsNull;
    property IsEmpty: Boolean read GetIsEmpty;
    property Value: T read GetValue;

    class operator Initialize(out Dest: Nullable<T>);

    class operator Implicit(const Value: Nullable<T>): T; //
    class operator Implicit(const Value: T): Nullable<T>;
    class operator Implicit(const Value: Nullable<T>): Variant; //
    class operator Implicit(Value: Pointer): Nullable<T>;

    class operator Explicit(const Value: Variant): Nullable<T>;
    class operator Explicit(const Value: Nullable<T>): T;

    class operator Equal(ALeft, ARight: Nullable<T>): Boolean;
    class operator NotEqual(ALeft, ARight: Nullable<T>): Boolean;
  end;

  TNullableString = Nullable<string>;
  TNullableWideString = Nullable<WideString>;
  TNullableInteger = Nullable<Integer>;
  TNullableInt64 = Nullable<Int64>;
  TNullableNativeInt = Nullable<NativeInt>;
  TNullableDateTime = Nullable<TDateTime>;
  TNullableDate = Nullable<TDate>;
  TNullableTime = Nullable<TTime>;
  TNullableCurrency = Nullable<Currency>;
  TNullableDouble = Nullable<Double>;
  TNullableBoolean = Nullable<Boolean>;
  TNullableGuid = Nullable<TGUID>;

function IsNullable(typeInfo: PTypeInfo): Boolean;

implementation

uses
  System.Generics.Defaults,
  System.Variants,
  System.StrUtils;

function IsNullable(typeInfo: PTypeInfo): Boolean;
begin
  result := Assigned(typeInfo) and (typeInfo.Kind in [tkRecord, tkMRecord]);

  if result then
    result := StartsText('Nullable<', typeInfo.Name) or StartsText('TNullable', typeInfo.Name);
end;

constructor Nullable<T>.Create(const Value: T);
begin
  FValue := Value;
  FHasValue := True;
end;

constructor Nullable<T>.Create(const Value: Variant);
var
  v: TValue;
begin
  if not VarIsNullOrEmpty(Value) then
  begin
    v := TValue.FromVariant(Value);
    FValue := v.AsType<T>;
    FHasValue := True;
  end
  else
  begin
    Clear;
  end;
end;

procedure Nullable<T>.Clear;
begin
  FHasValue := False;
  FValue := Default (T);
end;

class function Nullable<T>.VarIsNullOrEmpty(const Value: Variant; trimWhiteSpace: Boolean): Boolean;
var
  s: string;
begin
  result := VarIsNull(Value) or VarIsEmpty(Value);
  if not result and trimWhiteSpace and VarIsStr(Value) then
  begin
    s := VarToStrDef(Value, '');
    s := Trim(s);
    result := (s = '');
  end;
end;

function Nullable<T>.GetHasValue: Boolean;
begin
  result := FHasValue;
end;

function Nullable<T>.GetIsEmpty: Boolean;
begin
  result := not HasValue;
end;

function Nullable<T>.GetIsNull: Boolean;
begin
  result := not HasValue;
end;

function Nullable<T>.GetValue: T;
begin
  result := GetValueOrDefault;
end;

function Nullable<T>.GetValueOrDefault: T;
begin
  if HasValue then
    result := FValue
  else
    result := Default (T);
end;

class operator Nullable<T>.Initialize(out Dest: Nullable<T>);
begin
  Dest.FHasValue := False;
end;

function Nullable<T>.GetValueOrDefault(const defaultValue: T): T;
begin
  if HasValue then
    result := Value
  else
    result := defaultValue;
end;

function Nullable<T>.GetValueType: PTypeInfo;
begin
  result := typeInfo(T);
end;

procedure Nullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class operator Nullable<T>.Equal(ALeft, ARight: Nullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if not ALeft.IsNull and not ARight.IsNull then
  begin
    Comparer := TEqualityComparer<T>.Default;
    result := Comparer.Equals(ALeft.Value, ARight.Value);
  end
  else
    result := ALeft.IsNull = ARight.IsNull;
end;

class operator Nullable<T>.Implicit(const Value: T): Nullable<T>;
begin
  result := Nullable<T>.Create(Value);
end;

class operator Nullable<T>.Implicit(const Value: Nullable<T>): T;
begin
  result := Value.Value;
end;

//
class operator Nullable<T>.Implicit(const Value: Nullable<T>): Variant;

var
  v: TValue;
begin
  if Value.HasValue then
  begin
    v := TValue.From<T>(Value.Value);
    result := v.AsVariant;
  end
  else
  begin
    result := Null;
  end;
end;

class operator Nullable<T>.Implicit(Value: Pointer): Nullable<T>;
begin
  if Value = nil then
  begin
    result.Clear;
  end
  else
  begin
    raise EInvalidOperation.Create('Cannot assigned non-null pointer to nullable type.');
  end;
end;

class operator Nullable<T>.Explicit(const Value: Nullable<T>): T;
begin
  result := Value.Value;
end;

class operator Nullable<T>.Explicit(const Value: Variant): Nullable<T>;
var
  v: TValue;
begin
  if not VarIsNullOrEmpty(Value) then
  begin
    v := TValue.FromVariant(Value);
    result.FValue := v.AsType<T>;
    result.FHasValue := True;
  end
  else
    result := Default (Nullable<T>);
end;

class operator Nullable<T>.NotEqual(ALeft, ARight: Nullable<T>): Boolean;
begin
  result := not(ALeft = ARight);
end;

end.
