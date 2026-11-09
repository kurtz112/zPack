unit zz.RTTI;

// - "Summer for Delphi" by Jorge L. Cangas <jorge.cangas@gmail.com> is licensed under CC BY 4.0

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.TypInfo,
  System.RTTI,
  System.Variants,
  zz.Nullable;

type

  TRttiMemberHelper = class helper for TRttiMember
  private
    function GetType: TRttiType;
  public
    function GetValue(Instance: Pointer): TValue; overload;
    function GetValue(const Instance: TValue): TValue; overload;
    procedure SetValue(Instance: Pointer; const AValue: TValue); overload;
    procedure SetValue(const Instance: TValue; const AValue: TValue); overload;
    property MemberType: TRttiType read GetType;
  end;

  TRttiTypeHelper = class helper for TRttiType
    function TryGetMethod(const AName: string; out AMethod: TRttiMethod): Boolean;
    function FindConstructor: TRttiMethod;
  end;

  TValueHelper = record helper for TValue
  private
    function GetRttiType: TRttiType;
  public
    function Equals(const value: TValue): Boolean;
    function CompareValue(const value: TValue): integer;

    function TryGetNullable(var value: TValue): Boolean;
    function GetNullable: TValue;
    procedure SetNullable(const value: TValue);

    function IsNullable: Boolean;
    function IsEnum: Boolean;
    function IsNumber: Boolean;
    function IsInteger: Boolean;
    function IsFloat: Boolean;
    function IsString: Boolean;
    function IsBoolean: Boolean;
    function IsChar: Boolean;
    function IsDate: Boolean;
    function IsTime: Boolean;
    function IsDateTime: Boolean;
    function IsGuid: Boolean;
    function IsInterface: Boolean;
    function IsRecord: Boolean;
    function IsVariant: Boolean;

    function AsDate: TDate;
    function AsTime: TTime;
    function AsDateTime: TDateTime;

    property RttiType: TRttiType read GetRttiType;
  end;

function Variant2TValue(value: variant): TValue;
function IsNullable(typeInfo: PTypeInfo): Boolean;

implementation

uses
  System.StrUtils,
  System.Math;

var
  Context: TRttiContext;

  { TRttiMemberHelper }

function TRttiMemberHelper.GetType: TRttiType;
begin
  Assert(Assigned(Self)); // For those who forget to check first.

  if Self is TRttiProperty then
    result := TRttiProperty(Self).PropertyType
  else
    if Self is TRttiField then
      result := TRttiField(Self).FieldType
    else // if Self is TRttiMethod then
      // result := TRttiMethod(self).  hmmm Don't know how to get to the  TRttiMethodType and I don't need it
      result := nil;
end;

function TRttiMemberHelper.GetValue(Instance: Pointer): TValue;
begin
  Assert(Assigned(Self)); // For those who forget to check first.

  if InheritsFrom(TRttiProperty) then
    result := TRttiProperty(Self).GetValue(Instance)
  else
    if InheritsFrom(TRttiField) then
      result := TRttiField(Self).GetValue(Instance)
    else
      raise Exception.Create('Expecting Property or Field, found: ' + ClassName);
end;

procedure TRttiMemberHelper.SetValue(Instance: Pointer; const AValue: TValue);
begin
  Assert(Assigned(Self)); // For those who forget to check first.

  if InheritsFrom(TRttiProperty) then
    TRttiProperty(Self).SetValue(Instance, AValue)
  else
    if InheritsFrom(TRttiField) then
      TRttiField(Self).SetValue(Instance, AValue)
    else
      raise Exception.Create('Expecting Property or Field');
end;

function TRttiMemberHelper.GetValue(const Instance: TValue): TValue;
begin
  if Instance.isObject then
  begin
    result := GetValue(Instance.AsObject);
  end
  else
  begin
    result := GetValue(Instance.GetReferenceToRawData);
  end;
end;

procedure TRttiMemberHelper.SetValue(const Instance: TValue; const AValue: TValue);
begin
  if Instance.isObject then
  begin
    SetValue(Instance.AsObject, AValue);
  end
  else
  begin
    SetValue(Instance.GetReferenceToRawData, AValue)
  end;
end;

function Variant2TValue(value: variant): TValue;
begin
  result := TValue.Empty;

  if varIsNull(value) or VarIsEmpty(value) then
    Exit
  else
  begin
    case VarType(value) of
      varDate:
        result := TValue.From<TDateTime>(value);
      varCurrency:
        result := TValue.From<Currency>(value);
      varString:
        result := TValue.From<String>(value);
      varUString:
        result := TValue.From<String>(value);
      varInteger:
        result := TValue.From<integer>(value);
      varDouble:
        result := TValue.From<extended>(value);
      varBoolean:
        result := TValue.From<Boolean>(value);
    else
      result := TValue.From<variant>(value);
    end;
  end;
end;

function TValueHelper.AsDate: TDate;
begin
  result := AsType<TDate>;
end;

function TValueHelper.AsTime: TTime;
begin
  result := AsType<TTime>;
end;

function TValueHelper.Equals(const value: TValue): Boolean;
begin
  if Self.IsGuid and value.IsGuid then
    result := IsEqualGuid(Self.AsType<TGUID>, value.AsType<TGUID>)
  else
    result := CompareValue(value) = 0;
end;

function TValueHelper.CompareValue(const value: TValue): integer;

  function CompareValue_Array(const Left, Right: TValue): integer;
  var
    LMethod: TRttiMethod;
    i: integer;
  begin
    result := Left.GetArrayLength - Right.GetArrayLength;

    if result = 0 then
    begin
      for i := 0 to Left.GetArrayLength - 1 do
      begin
        result := CompareValue(Right.GetArrayElement(i));
        if result <> 0 then
          Exit;
      end;
    end;
  end;

  function CompareValue_Record(const Left, Right: TValue): integer;
  var
    LMethod: TRttiMethod;
  begin
    if Left.RttiType.TryGetMethod('&op_Equality', LMethod) then
    begin
      if LMethod.Invoke(nil, [Left, Right]).AsBoolean then
        result := 0
      else
        result := -1;
    end
    else
      result := 0;
  end;

var
  leftIsEmpty, rightIsEmpty: Boolean;
begin
  // leftIsEmpty := Self.IsEmpty;
  // rightIsEmpty := Value.IsEmpty;
  // if leftIsEmpty or rightIsEmpty then
  // result := EmptyResults[leftIsEmpty, rightIsEmpty]
  // else
  if Self.IsOrdinal and value.IsOrdinal then
    result := System.Math.CompareValue(Self.AsOrdinal, value.AsOrdinal)
  else
    if Self.IsFloat and value.IsFloat then
      result := System.Math.CompareValue(Self.AsExtended, value.AsExtended)
    else
      if Self.IsString and value.IsString then
        result := System.SysUtils.AnsiCompareStr(Self.AsString, value.AsString)
      else
        if Self.isObject and value.isObject then
          result := NativeInt(Self.AsObject) - NativeInt(value.AsObject) // TODO: instance comparer
        else
          if Self.IsInterface and value.IsInterface then
            result := NativeInt(Self.AsInterface) - NativeInt(value.AsInterface) // TODO: instance comparer
          else
            if Self.IsRecord and value.IsRecord then
              result := CompareValue_Record(Self, value)
            else
              if Self.IsArray and value.IsArray then
                result := CompareValue_Array(Self, value)
              else
                if Self.IsVariant and value.IsVariant then
                begin
                  case VarCompareValue(Self.AsVariant, value.AsVariant) of
                    vrEqual:
                      result := 0;
                    vrLessThan:
                      result := -1;
                    vrGreaterThan:
                      result := 1;
                    vrNotEqual:
                      result := -1;
                  else
                    result := 0;
                  end;
                end
                else
                  result := 0;
end;

function TValueHelper.AsDateTime: TDateTime;
begin
  result := AsType<TDateTime>;
end;

function TValueHelper.IsString: Boolean;
begin
  result := Kind in [TkString, TkLString, TkWString, TkUString];
end;

function TValueHelper.IsChar: Boolean;
begin
  result := Kind in [TkChar, TkWChar];
end;

function TValueHelper.IsTime: Boolean;
begin
  result := (typeInfo = System.typeInfo(TTime));
end;

function TValueHelper.IsVariant: Boolean;
begin
  result := typeInfo = System.typeInfo(variant);
end;

function TValueHelper.IsDate: Boolean;
begin
  result := (typeInfo = System.typeInfo(TDate));
end;

function TValueHelper.IsDateTime: Boolean;
begin
  result := (typeInfo = System.typeInfo(TDateTime));
end;

function TValueHelper.IsEnum: Boolean;
begin
  result := Kind in [TkEnumeration];
end;

function TValueHelper.IsNullable: Boolean;
begin
  result := zz.RTTI.IsNullable(typeInfo);
end;

procedure TValueHelper.SetNullable(const value: TValue);
var
  Context: TRttiContext;
  RType: TRttiType;
  FieldHasValue: TRttiField;
  FieldValue: TRttiField;
  Instance: Pointer;
begin
  if not IsNullable then
    raise Exception.Create('Type is not Nullable');

  Instance := GetReferenceToRawData;

  RType := Context.GetType(typeInfo);

  FieldHasValue := RType.GetField('FHasValue');
  if not Assigned(FieldHasValue) then
    raise Exception.Create('FHasValue field not found in TNullable');

  FieldValue := RType.GetField('FValue');
  if not Assigned(FieldValue) then
    raise Exception.Create('FValue field not found in TNullable');

  if value.IsEmpty then
    FieldHasValue.SetValue(Instance, False)
  else
  begin
    FieldValue.SetValue(Instance, value);
    FieldHasValue.SetValue(Instance, True);
  end;
end;

function TValueHelper.TryGetNullable(var value: TValue): Boolean;
var
  Context: TRttiContext;
  RType: TRttiType;
  FieldHasValue: TRttiField;
  FieldValue: TRttiField;
  Instance: Pointer;
  HasValue: TValue;
begin
  result := IsNullable;

  if not result then
  begin
    value := Self;
    Exit;
  end;

  if Self.IsEmpty then
    value := TValue.Empty
  else
  begin
    Instance := GetReferenceToRawData;
    RType := Context.GetType(typeInfo);

    FieldHasValue := RType.GetField('FHasValue');
    if not Assigned(FieldHasValue) then
      raise Exception.Create('FHasValue field not found in TNullable');

    FieldValue := RType.GetField('FValue');
    if not Assigned(FieldValue) then
      raise Exception.Create('FValue field not found in TNullable');

    HasValue := FieldHasValue.GetValue(Instance);

    if HasValue.AsBoolean then
      value := FieldValue.GetValue(Instance)
    else
      value := TValue.Empty;
  end;
end;

function TValueHelper.GetNullable: TValue;
begin
  TryGetNullable(result);
end;

function TValueHelper.GetRttiType: TRttiType;
begin
  result := Context.GetType(typeInfo);
end;

function TValueHelper.IsNumber: Boolean;
begin
  result := Kind in [TkInteger, TkFloat, TkInt64];
end;

function TValueHelper.IsRecord: Boolean;
begin
  result := RttiType.IsRecord;
end;

function TValueHelper.IsInteger: Boolean;
begin
  result := Kind in [TkInteger, TkInt64];
end;

function TValueHelper.IsInterface: Boolean;
begin
  result := Kind = tkInterface;
end;

function TValueHelper.IsFloat: Boolean;
begin
  result := Kind in [TkFloat];
end;

function TValueHelper.IsGuid: Boolean;
begin
  result := typeInfo = System.typeInfo(TGUID);
end;

function TValueHelper.IsBoolean: Boolean;
begin
  result := (typeInfo = System.typeInfo(Boolean));
end;

{ TRttiTypeHelper }

{ TRttiTypeHelper }

function TRttiTypeHelper.FindConstructor: TRttiMethod;
var
  candidateCtor: TRttiMethod;
begin
  result := nil;
  for candidateCtor in GetMethods('Create') do
  begin
    if Length(candidateCtor.GetParameters) = 0 then
    begin
      result := candidateCtor;
      Break;
    end;
  end;
end;

function TRttiTypeHelper.TryGetMethod(const AName: string; out AMethod: TRttiMethod): Boolean;
begin
  AMethod := GetMethod(AName);
  result := Assigned(AMethod);
end;

function IsNullable(typeInfo: PTypeInfo): Boolean;
begin
  result := Assigned(typeInfo) and (typeInfo.Kind in [tkRecord, tkMRecord]);

  if result then
    result := StartsText('Nullable<', typeInfo.Name) or StartsText('TNullable', typeInfo.Name);
end;

end.

  zz.Nullable
