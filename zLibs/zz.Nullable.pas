{ *************************************************************************** }
{ }
{ Spring Framework for Delphi }
{ }
{ Copyright (C) 2009-2011 DevJET }
{ }
{ http://www.DevJET.net }
{ }
{ *************************************************************************** }
{ }
{ Licensed under the Apache License, Version 2.0 (the "License"); }
{ you may not use this file except in compliance with the License. }
{ You may obtain a copy of the License at }
{ }
{ http://www.apache.org/licenses/LICENSE-2.0 }
{ }
{ Unless required by applicable law or agreed to in writing, software }
{ distributed under the License is distributed on an "AS IS" BASIS, }
{ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{ See the License for the specific language governing permissions and }
{ limitations under the License. }
{ }
{ *************************************************************************** }
// estratto da spring
// -----------------------------------------------------------------------------
// Versione estesa con operatori di confronto (Equal / NotEqual).
// Semantica scelta: null = valore di default del tipo (0, False, '', ...),
// coerente con il comportamento di .Value / GetValueOrDefault.
// Cos� ora compilano direttamente:
// if id <> 0 then        (id: TNullableInt64)
// if id = 0 then
// if bool = True then    (bool: TNullable<Boolean>)
// Nota: "if bool then" senza .Value NON � risolvibile dal compilatore su un
// record generico; usare "if bool.Value then" oppure "if bool = True then".
// -----------------------------------------------------------------------------
unit zz.Nullable;

interface

const
  HasValueFlag = '@'; // DO NOT LOCALIZE

type
  /// <summary>
  /// Represents an "object" whose underlying type is a value type that can
  /// also be assigned nil like a reference type.
  /// </summary>
  /// <typeparam name="T">
  /// The underlying value type of the <see cref="TNullable`1" /> generic
  /// type.
  /// </typeparam>
  /// <remarks>
  /// The <typeparamref name="T" /> must be a value type such as string, Integer.
  /// </remarks>
  TNullable<T> = packed record
  strict private
    fValue: T;
    fHasValue: string;
    function GetValue: T;
    function GetHasValue: Boolean;
    function GetIsNull: Boolean;
  private

    function GetIsEmpty: Boolean;
    /// <summary>
    /// Determines whether a variant value is null or empty.
    /// </summary>
    class function VarIsNullOrEmpty(const value: Variant; trimWhiteSpace: Boolean = False): Boolean; static;

    // Confronto interno fra due valori di tipo T, indipendente dal tipo.
    class function ValuesEqual(const left, right: T): Boolean; static;
    // Confronto d'ordine fra due valori di tipo T (<0, 0, >0), indipendente dal tipo.
    class function ValuesCompare(const left, right: T): Integer; static;
  public
    /// <summary>
    /// Initializes a new instance of the <c>TNullable{T}</c> structure to
    /// the specified value.
    /// </summary>
    constructor Create(const value: T); overload;

    /// <summary>
    /// Initializes a new instance of the <c>TNullable{T}</c> structure to
    /// the specified value.
    /// </summary>
    constructor Create(const value: Variant); overload;

    /// <summary>
    /// Retrieves the value of the current <c>TNullable{T}</c> object, or the
    /// object's default value.
    /// </summary>
    function GetValueOrDefault: T; overload;
    /// <summary>
    /// Internal use. Marks the current instance as null.
    /// </summary>
    procedure Clear;

    /// <summary>
    /// Retrieves the value of the current <c>TNullable{T}</c> object, or the
    /// specified default value.
    /// </summary>
    /// <param name="defaultValue">
    /// A value to return if the <see cref="HasValue" /> property is
    /// <c>false</c>.
    /// </param>
    /// <returns>
    /// The value of the <see cref="Value" /> property if the
    /// <see cref="HasValue" /> property is true; otherwise, the
    /// <paramref name="defaultValue" /> parameter.
    /// </returns>
    /// <remarks>
    /// The <see cref="GetValueOrDefault" /> method returns a value even if
    /// the <see cref="HasValue" /> property is false (unlike the
    /// <see cref="Value" /> property, which throws an exception).
    /// </remarks>
    function GetValueOrDefault(const defaultValue: T): T; overload;

    /// <summary>
    /// Gets a value indicating whether the current <c>TNullable{T}</c>
    /// structure has a value.
    /// </summary>
    property HasValue: Boolean read GetHasValue;
    property IsNull: Boolean read GetIsNull;

    /// <summary>
    /// Alias of <see cref="IsNull" />.
    /// </summary>
    property IsEmpty: Boolean read GetIsEmpty;

    /// <summary>
    /// Gets the value of the current <c>TNullable&lt;T&gt;</c> value.
    /// </summary>
    /// <exception cref="Spring|EInvalidOperation">
    /// Raised if the value is null.
    /// </exception>
    property value: T read GetValue;

    { Operator Overloads }
    class operator Implicit(const value: TNullable<T>): T;
    class operator Implicit(const value: T): TNullable<T>;
    class operator Implicit(const value: TNullable<T>): Variant;
    // class operator Implicit(const value: Variant): TNullable<T>;
    class operator Implicit(value: Pointer): TNullable<T>;
    class operator Explicit(const value: TNullable<T>): T;

    // Operatori di confronto aggiunti.
    // Permettono test diretti come "id <> 0" senza dover scrivere ".Value".
    // Il confronto usa il valore di default quando il nullable � null
    // (null = 0 / False / '' ...), come da scelta di progetto.
    class operator Equal(const left: TNullable<T>; const right: T): Boolean;
    class operator Equal(const left: T; const right: TNullable<T>): Boolean;
    class operator Equal(const left, right: TNullable<T>): Boolean;
    class operator NotEqual(const left: TNullable<T>; const right: T): Boolean;
    class operator NotEqual(const left: T; const right: TNullable<T>): Boolean;
    class operator NotEqual(const left, right: TNullable<T>): Boolean;

    // Operatori d'ordine. Utili soprattutto per numeri, valute e date.
    // Anche qui null = valore di default del tipo.
    class operator LessThan(const left: TNullable<T>; const right: T): Boolean;
    class operator LessThan(const left: T; const right: TNullable<T>): Boolean;
    class operator LessThan(const left, right: TNullable<T>): Boolean;
    class operator GreaterThan(const left: TNullable<T>; const right: T): Boolean;
    class operator GreaterThan(const left: T; const right: TNullable<T>): Boolean;
    class operator GreaterThan(const left, right: TNullable<T>): Boolean;
    class operator LessThanOrEqual(const left: TNullable<T>; const right: T): Boolean;
    class operator LessThanOrEqual(const left: T; const right: TNullable<T>): Boolean;
    class operator LessThanOrEqual(const left, right: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(const left: TNullable<T>; const right: T): Boolean;
    class operator GreaterThanOrEqual(const left: T; const right: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(const left, right: TNullable<T>): Boolean;
  end;

  TNullableString = TNullable<string>;
  TNullableAnsiString = TNullable<AnsiString>;
  TNullableWideString = TNullable<WideString>;
  TNullableInteger = TNullable<Integer>;
  TNullableInt64 = TNullable<Int64>;
  TNullableNativeInt = TNullable<NativeInt>;
  TNullableDateTime = TNullable<TDateTime>;
  TNullableDate = TNullable<TDate>;
  TNullableTime = TNullable<TTime>;
  TNullableCurrency = TNullable<Currency>;
  TNullableDouble = TNullable<Double>;
  TNullableBoolean = TNullable<Boolean>;
  TNullableGuid = TNullable<TGUID>;

implementation

uses
  SysUtils,
  Classes,
  Rtti,
  Variants,
  Generics.Defaults,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

constructor TNullable<T>.Create(const value: T);
begin
  fValue := value;
  fHasValue := HasValueFlag;
end;

constructor TNullable<T>.Create(const value: Variant);
var
  v: TValue;
begin
  if not VarIsNullOrEmpty(value) then
  begin
    v := TValue.FromVariant(value);
    fValue := v.AsType<T>;
    fHasValue := HasValueFlag;
  end
  else
  begin
    Clear;
  end;
end;

procedure TNullable<T>.Clear;
begin
  fHasValue := '';
  fValue := Default (T);
end;

class function TNullable<T>.VarIsNullOrEmpty(const value: Variant; trimWhiteSpace: Boolean): Boolean;
var
  s: string;
begin
  Result := VarIsNull(value) or VarIsEmpty(value);
  if not Result and trimWhiteSpace and VarIsStr(value) then
  begin
    s := VarToStrDef(value, '');
    s := Trim(s);
    Result := (s = '');
  end;
end;

class function TNullable<T>.ValuesEqual(const left, right: T): Boolean;
begin
  // Confronto generico valido per qualunque T (interi, stringhe, boolean,
  // date, GUID, ...): usa il comparatore di uguaglianza di default del RTL.
  Result := TEqualityComparer<T>.Default.Equals(left, right);
end;

class function TNullable<T>.ValuesCompare(const left, right: T): Integer;
begin
  // Ordinamento generico valido per qualunque T: <0 se left minore,
  // 0 se uguali, >0 se left maggiore.
  Result := TComparer<T>.Default.Compare(left, right);
end;

function TNullable<T>.GetHasValue: Boolean;
begin
  Result := Length(fHasValue) > 0;
end;

function TNullable<T>.GetIsEmpty: Boolean;
begin
  Result := not HasValue;
end;

function TNullable<T>.GetIsNull: Boolean;
begin
  Result := not HasValue;
end;

function TNullable<T>.GetValue: T;
begin
  Result := GetValueOrDefault;
end;

function TNullable<T>.GetValueOrDefault: T;
begin
  // DIV-NUL-3: nessuna voce di registro (EnterMethod/LeaveMethod) a ogni lettura:
  // e' il metodo piu' chiamato dei wrapper delle procedure memorizzate
  if HasValue then
    Result := fValue
  else
    Result := Default (T);
end;

function TNullable<T>.GetValueOrDefault(const defaultValue: T): T;
begin
  if HasValue then
    Result := value
  else
    Result := defaultValue;
end;

class operator TNullable<T>.Implicit(const value: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(value);
end;

class operator TNullable<T>.Implicit(const value: TNullable<T>): T;
begin
  Result := value.value;
end;

//
class operator TNullable<T>.Implicit(const value: TNullable<T>): Variant;

var
  v: TValue;
begin
  if value.HasValue then
  begin
    v := TValue.From<T>(value.value);
    Result := v.AsVariant;
  end
  else
  begin
    Result := Null;
  end;
end;

// class operator TNullable<T>.Implicit(const value: Variant): TNullable<T>;
//
// var
// v: TValue;
// begin
// if not VarIsNullOrEmpty(value) then
// begin
// v := TValue.FromVariant(value);
// Result := TNullable<T>.Create(v.AsType<T>);
// end
// else
// begin
// Result.Clear;
// end;
// end;

class operator TNullable<T>.Implicit(value: Pointer): TNullable<T>;
begin
  if value = nil then
  begin
    Result.Clear;
  end
  else
  begin
    raise EInvalidOperation.Create('Cannot assigned non-null pointer to nullable type.');
  end;
end;

class operator TNullable<T>.Explicit(const value: TNullable<T>): T;
begin
  Result := value.value;
end;

// -----------------------------------------------------------------------------
// Operatori di confronto.
// Semantica: null equivale al valore di default del tipo (GetValueOrDefault),
// quindi un TNullableInt64 null � considerato = 0, un TNullable<Boolean> null
// � considerato = False, ecc.
// -----------------------------------------------------------------------------

class operator TNullable<T>.Equal(const left: TNullable<T>; const right: T): Boolean;
begin
  Result := ValuesEqual(left.GetValueOrDefault, right);
end;

class operator TNullable<T>.Equal(const left: T; const right: TNullable<T>): Boolean;
begin
  Result := ValuesEqual(left, right.GetValueOrDefault);
end;

class operator TNullable<T>.Equal(const left, right: TNullable<T>): Boolean;
begin
  Result := ValuesEqual(left.GetValueOrDefault, right.GetValueOrDefault);
end;

class operator TNullable<T>.NotEqual(const left: TNullable<T>; const right: T): Boolean;
begin
  Result := not ValuesEqual(left.GetValueOrDefault, right);
end;

class operator TNullable<T>.NotEqual(const left: T; const right: TNullable<T>): Boolean;
begin
  Result := not ValuesEqual(left, right.GetValueOrDefault);
end;

class operator TNullable<T>.NotEqual(const left, right: TNullable<T>): Boolean;
begin
  Result := not ValuesEqual(left.GetValueOrDefault, right.GetValueOrDefault);
end;

// -----------------------------------------------------------------------------
// Operatori d'ordine.
// -----------------------------------------------------------------------------

class operator TNullable<T>.LessThan(const left: TNullable<T>; const right: T): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right) < 0;
end;

class operator TNullable<T>.LessThan(const left: T; const right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left, right.GetValueOrDefault) < 0;
end;

class operator TNullable<T>.LessThan(const left, right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right.GetValueOrDefault) < 0;
end;

class operator TNullable<T>.GreaterThan(const left: TNullable<T>; const right: T): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right) > 0;
end;

class operator TNullable<T>.GreaterThan(const left: T; const right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left, right.GetValueOrDefault) > 0;
end;

class operator TNullable<T>.GreaterThan(const left, right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right.GetValueOrDefault) > 0;
end;

class operator TNullable<T>.LessThanOrEqual(const left: TNullable<T>; const right: T): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right) <= 0;
end;

class operator TNullable<T>.LessThanOrEqual(const left: T; const right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left, right.GetValueOrDefault) <= 0;
end;

class operator TNullable<T>.LessThanOrEqual(const left, right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right.GetValueOrDefault) <= 0;
end;

class operator TNullable<T>.GreaterThanOrEqual(const left: TNullable<T>; const right: T): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right) >= 0;
end;

class operator TNullable<T>.GreaterThanOrEqual(const left: T; const right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left, right.GetValueOrDefault) >= 0;
end;

class operator TNullable<T>.GreaterThanOrEqual(const left, right: TNullable<T>): Boolean;
begin
  Result := ValuesCompare(left.GetValueOrDefault, right.GetValueOrDefault) >= 0;
end;

end.
