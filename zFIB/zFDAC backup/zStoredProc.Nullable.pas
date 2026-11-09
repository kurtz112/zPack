{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (C) 2009-2011 DevJET                                  }
{                                                                           }
{           http://www.DevJET.net                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
// estratto da spring
unit zStoredProc.Nullable;

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

    /// <summary>
    /// Determines whether a variant value is null or empty.
    /// </summary>
    class function VarIsNullOrEmpty(const value: Variant; trimWhiteSpace: Boolean = False): Boolean; static;
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
SmartInspect,
  siAuto;

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
  fValue := Default(T);
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

function TNullable<T>.GetHasValue: Boolean;
begin
  Result := Length(fHasValue) > 0;
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
  SiMain.EnterMethod(lvDebug, 'TNullable');
  if HasValue then
    Result := fValue
  else
    Result := Default(T);
  SiMain.LeaveMethod(lvDebug, 'TNullable');
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

end.
