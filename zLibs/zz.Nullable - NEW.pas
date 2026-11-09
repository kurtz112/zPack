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
// -----------------------------------------------------------------------------
// Base: zz.Nullable_old, con le aggiunte della versione estesa.
//
// Il record si chiama TNullable<T>. Non esiste alcun alias Nullable<T>: il
// codice chiamante va aggiornato al nome nuovo, compresi i wrapper generati
// TSP_* di Wt3_StoredProcs e Gesty_StoredProcs.
//
// Aggiunte rispetto alla base:
//   - operatori di uguaglianza nelle forme mista nullable/valore
//     (nullable = T, T = nullable) oltre a quella nullable = nullable;
//   - operatori d'ordine <, >, <=, >= nelle tre forme;
//   - metodi interni ValuesEqual / ValuesCompare, che centralizzano il
//     confronto fra due valori di tipo T qualunque sia T;
//   - il record TNullableComparer, con i due comparatori espliciti da passare
//     alle collezioni (vedi la nota qui sotto);
//   - alias TNullableAnsiString;
//   - commenti di documentazione XMLDoc;
//   - parametri degli operatori passati come const.
//
// Semantica del confronto con null (quella della base, cioè quella di
// Nullable<T> del C# e di Spring4D):
//   - uguaglianza: due nullable sono uguali se hanno entrambi un valore e i
//     valori coincidono, oppure se sono entrambi null. Un nullable null non è
//     mai uguale a un valore, quindi id = 0 su un id null restituisce False e
//     id <> 0 restituisce True;
//   - ordine: se uno dei due operandi è null il risultato è sempre False,
//     compreso null <= null. Di conseguenza not (a < b) non equivale a a >= b.
//
// Il controllo "ha un valore utilizzabile" non va scritto con gli operatori:
// si usa id.HasValue, id.IsNull oppure id.GetValueOrDefault(0) <> 0.
//
// Comparatori per le collezioni.
// TComparer<...>.Default e TEqualityComparer<...>.Default NON guardano gli
// operatori sovraccaricati: su un record ricadono sul confronto della memoria,
// che sulle stringhe confronta i puntatori invece del testo. Quindi un nullable
// usato come chiave di TDictionary, cercato con TList.IndexOf o ordinato con
// TList.Sort non passa dalla semantica definita qui. Per quegli usi vanno
// passati TNullableComparer.DefaultEquality<T> e TNullableComparer.Default<T>.
// I due comparatori non possono stare dentro TNullable<T>: un tipo generico non
// puo' comparire come argomento di un altro tipo generico dentro la propria
// dichiarazione, e IComparer<TNullable<T>> fra i membri del record fa scattare
// l'errore E2086. Da qui la necessita' di indicare il tipo per esteso, cioe'
// TNullableComparer.Default<Int64> invece di TNullableInt64.DefaultComparer.
// Attenzione a una divergenza voluta: il comparatore d'ordine mette i null per
// primi,
// come fa Firebird in ordinamento crescente, perche' un ordinamento richiede
// un ordine totale. L'operatore < invece restituisce False su qualunque null.
// I due non coincidono, e non possono coincidere.
// -----------------------------------------------------------------------------
unit zz.Nullable;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,
  System.Generics.Defaults;

const
  // Impronta convenzionale di un nullable senza valore.
  NullHashCode = 0;

type
  {$RTTI EXPLICIT FIELDS([vcPrivate]) METHODS([vcPrivate])}
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
  private
    FValue: T;
    FHasValue: Boolean;
    function GetValue: T;
    function GetHasValue: Boolean;
    function GetIsNull: Boolean;
    function GetIsEmpty: Boolean;
    function GetValueType: PTypeInfo;
    procedure SetValue(const AValue: T);

    /// <summary>
    /// Determines whether a variant value is null or empty.
    /// </summary>
    class function VarIsNullOrEmpty(const Value: Variant; trimWhiteSpace: Boolean = False): Boolean; static;

    // Confronto interno di uguaglianza fra due valori di tipo T,
    // indipendente dal tipo.
    class function ValuesEqual(const ALeft, ARight: T): Boolean; static;
    // Confronto interno d'ordine fra due valori di tipo T (<0, 0, >0),
    // indipendente dal tipo.
    class function ValuesCompare(const ALeft, ARight: T): Integer; static;
  public
    /// <summary>
    /// Initializes a new instance of the <c>TNullable{T}</c> structure to
    /// the specified value.
    /// </summary>
    constructor Create(const Value: T); overload;

    /// <summary>
    /// Initializes a new instance of the <c>TNullable{T}</c> structure to
    /// the specified value.
    /// </summary>
    constructor Create(const Value: Variant); overload;

    /// <summary>
    /// Internal use. Marks the current instance as null.
    /// </summary>
    procedure Clear;

    /// <summary>
    /// Retrieves the value of the current <c>TNullable{T}</c> object, or the
    /// object's default value.
    /// </summary>
    function GetValueOrDefault: T; overload;

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
    function GetValueOrDefault(const defaultValue: T): T; overload;

    /// <summary>
    /// Gets a value indicating whether the current <c>TNullable{T}</c>
    /// structure has a value.
    /// </summary>
    property HasValue: Boolean read GetHasValue;

    /// <summary>
    /// Gets a value indicating whether the current <c>TNullable{T}</c> is
    /// null.
    /// </summary>
    property IsNull: Boolean read GetIsNull;

    /// <summary>
    /// Alias of <see cref="IsNull" />.
    /// </summary>
    property IsEmpty: Boolean read GetIsEmpty;

    /// <summary>
    /// Gets the value of the current <c>TNullable&lt;T&gt;</c> value.
    /// </summary>
    /// <remarks>
    /// Attenzione: su un nullable senza valore non solleva eccezioni, ma
    /// restituisce il valore di default del tipo (0, False, '', ...). Gli
    /// operatori di confronto qui sotto NON seguono questa convenzione: per
    /// loro un nullable senza valore non e' uguale a nessun valore. Quindi
    /// su un id null, id.Value = 0 restituisce True mentre id = 0 restituisce
    /// False. Per sapere se il valore c'e' si usa HasValue o IsNull.
    /// </remarks>
    property Value: T read GetValue;

    { Operator Overloads }
    class operator Initialize(out Dest: TNullable<T>);

    class operator Implicit(const Value: TNullable<T>): T; //
    class operator Implicit(const Value: T): TNullable<T>;
    class operator Implicit(const Value: TNullable<T>): Variant; //
    class operator Implicit(Value: Pointer): TNullable<T>;

    class operator Explicit(const Value: Variant): TNullable<T>;
    class operator Explicit(const Value: TNullable<T>): T;

    // Uguaglianza. Null è uguale soltanto a null: un nullable senza valore
    // non è mai uguale a un valore concreto.
    class operator Equal(const ALeft, ARight: TNullable<T>): Boolean;
    class operator Equal(const ALeft: TNullable<T>; const ARight: T): Boolean;
    class operator Equal(const ALeft: T; const ARight: TNullable<T>): Boolean;
    class operator NotEqual(const ALeft, ARight: TNullable<T>): Boolean;
    class operator NotEqual(const ALeft: TNullable<T>; const ARight: T): Boolean;
    class operator NotEqual(const ALeft: T; const ARight: TNullable<T>): Boolean;

    // Ordine. Utile soprattutto per numeri, valute e date. Se uno dei due
    // operandi è null il risultato è False, come in C#.
    class operator LessThan(const ALeft, ARight: TNullable<T>): Boolean;
    class operator LessThan(const ALeft: TNullable<T>; const ARight: T): Boolean;
    class operator LessThan(const ALeft: T; const ARight: TNullable<T>): Boolean;
    class operator GreaterThan(const ALeft, ARight: TNullable<T>): Boolean;
    class operator GreaterThan(const ALeft: TNullable<T>; const ARight: T): Boolean;
    class operator GreaterThan(const ALeft: T; const ARight: TNullable<T>): Boolean;
    class operator LessThanOrEqual(const ALeft, ARight: TNullable<T>): Boolean;
    class operator LessThanOrEqual(const ALeft: TNullable<T>; const ARight: T): Boolean;
    class operator LessThanOrEqual(const ALeft: T; const ARight: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(const ALeft, ARight: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(const ALeft: TNullable<T>; const ARight: T): Boolean;
    class operator GreaterThanOrEqual(const ALeft: T; const ARight: TNullable<T>): Boolean;
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

  /// <summary>
  /// Implementazione del comparatore d'ordine. Non va richiamata direttamente:
  /// si usa <see cref="TNullableComparer.Default`1" />.
  /// </summary>
  /// <remarks>
  /// Sta nell'interface e non nell'implementation perche' il corpo di un metodo
  /// di un tipo generico dichiarato nell'interface non puo' riferirsi a un tipo
  /// locale della implementation: sarebbe l'errore E2506. I null vengono per
  /// primi, come in Firebird con ordinamento crescente, perche' un ordinamento
  /// richiede un ordine totale, che gli operatori < e > non forniscono.
  /// </remarks>
  TNullableOrderComparer<T> = class(TComparer<TNullable<T>>)
  public
    function Compare(const ALeft, ARight: TNullable<T>): Integer; override;
  end;

  /// <summary>
  /// Implementazione del comparatore di uguaglianza. Non va richiamata
  /// direttamente: si usa <see cref="TNullableComparer.DefaultEquality`1" />.
  /// </summary>
  /// <remarks>
  /// Segue la stessa semantica degli operatori: null e' uguale soltanto a null.
  /// L'impronta viene calcolata sul valore di T e non sui byte del record,
  /// cosi' due nullable con la stessa stringa finiscono nello stesso
  /// contenitore. Vale anche qui la nota sull'errore E2506.
  /// </remarks>
  TNullableEqualityComparer<T> = class(TEqualityComparer<TNullable<T>>)
  public
    function Equals(const ALeft, ARight: TNullable<T>): Boolean; overload; override;
    function GetHashCode(const AValue: TNullable<T>): Integer; overload; override;
  end;

  /// <summary>
  /// Comparatori da passare alle collezioni e agli ordinamenti, che non usano
  /// gli operatori sovraccaricati di <c>TNullable{T}</c>.
  /// </summary>
  /// <remarks>
  /// Stanno qui e non dentro TNullable&lt;T&gt; perche' un tipo generico non
  /// puo' comparire come argomento di un altro tipo generico dentro la propria
  /// dichiarazione: IComparer&lt;TNullable&lt;T&gt;&gt; scritto fra i membri
  /// del record produce l'errore E2086, "type is not yet completely defined".
  /// Il parametro di tipo va indicato per esteso, quindi si scrive
  /// TNullableComparer.Default&lt;Int64&gt; e non TNullableInt64.something.
  /// Conserva l'interfaccia restituita in una variabile: ogni chiamata crea un
  /// oggetto nuovo.
  /// </remarks>
  TNullableComparer = record
  public
    /// <summary>
    /// Comparatore d'ordine. Mette i null per primi, come Firebird in
    /// ordinamento crescente.
    /// </summary>
    /// <remarks>
    /// Divergenza voluta rispetto all'operatore &lt;, che su un null
    /// restituisce sempre False: un ordinamento richiede un ordine totale, e
    /// la semantica degli operatori non lo e'.
    /// </remarks>
    class function Default<T>: IComparer<TNullable<T>>; static;

    /// <summary>
    /// Comparatore di uguaglianza, per esempio come comparatore di
    /// TDictionary quando la chiave e' un nullable.
    /// </summary>
    /// <remarks>
    /// Segue la stessa semantica dell'operatore =: null e' uguale soltanto a
    /// null. Calcola l'impronta sul valore di T e non sui byte del record,
    /// quindi funziona anche su TNullableString, dove il comparatore di default
    /// del RTL confronterebbe i puntatori delle stringhe.
    /// </remarks>
    class function DefaultEquality<T>: IEqualityComparer<TNullable<T>>; static;
  end;

/// <summary>
/// Determines whether the type described by <paramref name="typeInfo" /> is a
/// nullable type, i.e. a <c>TNullable{T}</c> / <c>Nullable{T}</c> record.
/// </summary>
function IsNullable(typeInfo: PTypeInfo): Boolean;

implementation

uses
  System.Variants,
  System.StrUtils;

function TNullableOrderComparer<T>.Compare(const ALeft, ARight: TNullable<T>): Integer;
begin
  if ALeft.HasValue and ARight.HasValue then
    result := TNullable<T>.ValuesCompare(ALeft.FValue, ARight.FValue)
  else if ALeft.HasValue then
    result := 1
  else if ARight.HasValue then
    result := -1
  else
    result := 0;
end;

function TNullableEqualityComparer<T>.Equals(const ALeft, ARight: TNullable<T>): Boolean;
begin
  if ALeft.HasValue and ARight.HasValue then
    result := TNullable<T>.ValuesEqual(ALeft.FValue, ARight.FValue)
  else
    result := ALeft.HasValue = ARight.HasValue;
end;

function TNullableEqualityComparer<T>.GetHashCode(const AValue: TNullable<T>): Integer;
begin
  if AValue.HasValue then
    result := TEqualityComparer<T>.Default.GetHashCode(AValue.FValue)
  else
    result := NullHashCode;
end;

class function TNullableComparer.Default<T>: IComparer<TNullable<T>>;
begin
  result := TNullableOrderComparer<T>.Create;
end;

class function TNullableComparer.DefaultEquality<T>: IEqualityComparer<TNullable<T>>;
begin
  result := TNullableEqualityComparer<T>.Create;
end;

function IsNullable(typeInfo: PTypeInfo): Boolean;
begin
  result := Assigned(typeInfo) and (typeInfo.Kind in [tkRecord, tkMRecord]);

  if result then
    result := StartsText('Nullable<', typeInfo.Name) or StartsText('TNullable', typeInfo.Name);
end;

constructor TNullable<T>.Create(const Value: T);
begin
  FValue := Value;
  FHasValue := True;
end;

constructor TNullable<T>.Create(const Value: Variant);
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

procedure TNullable<T>.Clear;
begin
  FHasValue := False;
  FValue := Default (T);
end;

class function TNullable<T>.VarIsNullOrEmpty(const Value: Variant; trimWhiteSpace: Boolean): Boolean;
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

class function TNullable<T>.ValuesEqual(const ALeft, ARight: T): Boolean;
begin
  // Confronto generico valido per qualunque T (interi, stringhe, boolean,
  // date, GUID, ...): usa il comparatore di uguaglianza di default del RTL.
  result := TEqualityComparer<T>.Default.Equals(ALeft, ARight);
end;

class function TNullable<T>.ValuesCompare(const ALeft, ARight: T): Integer;
begin
  // Ordinamento generico valido per qualunque T: <0 se ALeft minore,
  // 0 se uguali, >0 se ALeft maggiore.
  result := TComparer<T>.Default.Compare(ALeft, ARight);
end;

function TNullable<T>.GetHasValue: Boolean;
begin
  result := FHasValue;
end;

function TNullable<T>.GetIsEmpty: Boolean;
begin
  result := not HasValue;
end;

function TNullable<T>.GetIsNull: Boolean;
begin
  result := not HasValue;
end;

function TNullable<T>.GetValue: T;
begin
  result := GetValueOrDefault;
end;

function TNullable<T>.GetValueOrDefault: T;
begin
  if HasValue then
    result := FValue
  else
    result := Default (T);
end;

function TNullable<T>.GetValueOrDefault(const defaultValue: T): T;
begin
  if HasValue then
    result := Value
  else
    result := defaultValue;
end;

function TNullable<T>.GetValueType: PTypeInfo;
begin
  result := typeInfo(T);
end;

procedure TNullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class operator TNullable<T>.Initialize(out Dest: TNullable<T>);
begin
  Dest.FHasValue := False;
end;

class operator TNullable<T>.Implicit(const Value: T): TNullable<T>;
begin
  result := TNullable<T>.Create(Value);
end;

class operator TNullable<T>.Implicit(const Value: TNullable<T>): T;
begin
  result := Value.Value;
end;

//
class operator TNullable<T>.Implicit(const Value: TNullable<T>): Variant;

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

class operator TNullable<T>.Implicit(Value: Pointer): TNullable<T>;
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

class operator TNullable<T>.Explicit(const Value: TNullable<T>): T;
begin
  result := Value.Value;
end;

class operator TNullable<T>.Explicit(const Value: Variant): TNullable<T>;
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
    result := Default (TNullable<T>);
end;

// -----------------------------------------------------------------------------
// Uguaglianza.
// Null è uguale soltanto a null. Il valore del campo interno viene letto solo
// dopo aver verificato HasValue, quindi il valore di default di un nullable
// vuoto non entra mai nel confronto.
// -----------------------------------------------------------------------------

class operator TNullable<T>.Equal(const ALeft, ARight: TNullable<T>): Boolean;
begin
  if ALeft.HasValue and ARight.HasValue then
    result := ValuesEqual(ALeft.FValue, ARight.FValue)
  else
    result := ALeft.HasValue = ARight.HasValue;
end;

class operator TNullable<T>.Equal(const ALeft: TNullable<T>; const ARight: T): Boolean;
begin
  result := ALeft.HasValue and ValuesEqual(ALeft.FValue, ARight);
end;

class operator TNullable<T>.Equal(const ALeft: T; const ARight: TNullable<T>): Boolean;
begin
  result := ARight.HasValue and ValuesEqual(ALeft, ARight.FValue);
end;

class operator TNullable<T>.NotEqual(const ALeft, ARight: TNullable<T>): Boolean;
begin
  result := not (ALeft = ARight);
end;

class operator TNullable<T>.NotEqual(const ALeft: TNullable<T>; const ARight: T): Boolean;
begin
  result := not (ALeft = ARight);
end;

class operator TNullable<T>.NotEqual(const ALeft: T; const ARight: TNullable<T>): Boolean;
begin
  result := not (ALeft = ARight);
end;

// -----------------------------------------------------------------------------
// Ordine.
// Se uno dei due operandi è null il risultato è False, compreso il confronto
// fra due null. È la regola degli operatori sollevati del C#: attenzione al
// fatto che not (a < b) non equivale a a >= b.
// -----------------------------------------------------------------------------

class operator TNullable<T>.LessThan(const ALeft, ARight: TNullable<T>): Boolean;
begin
  result := ALeft.HasValue and ARight.HasValue and (ValuesCompare(ALeft.FValue, ARight.FValue) < 0);
end;

class operator TNullable<T>.LessThan(const ALeft: TNullable<T>; const ARight: T): Boolean;
begin
  result := ALeft.HasValue and (ValuesCompare(ALeft.FValue, ARight) < 0);
end;

class operator TNullable<T>.LessThan(const ALeft: T; const ARight: TNullable<T>): Boolean;
begin
  result := ARight.HasValue and (ValuesCompare(ALeft, ARight.FValue) < 0);
end;

class operator TNullable<T>.GreaterThan(const ALeft, ARight: TNullable<T>): Boolean;
begin
  result := ALeft.HasValue and ARight.HasValue and (ValuesCompare(ALeft.FValue, ARight.FValue) > 0);
end;

class operator TNullable<T>.GreaterThan(const ALeft: TNullable<T>; const ARight: T): Boolean;
begin
  result := ALeft.HasValue and (ValuesCompare(ALeft.FValue, ARight) > 0);
end;

class operator TNullable<T>.GreaterThan(const ALeft: T; const ARight: TNullable<T>): Boolean;
begin
  result := ARight.HasValue and (ValuesCompare(ALeft, ARight.FValue) > 0);
end;

class operator TNullable<T>.LessThanOrEqual(const ALeft, ARight: TNullable<T>): Boolean;
begin
  result := ALeft.HasValue and ARight.HasValue and (ValuesCompare(ALeft.FValue, ARight.FValue) <= 0);
end;

class operator TNullable<T>.LessThanOrEqual(const ALeft: TNullable<T>; const ARight: T): Boolean;
begin
  result := ALeft.HasValue and (ValuesCompare(ALeft.FValue, ARight) <= 0);
end;

class operator TNullable<T>.LessThanOrEqual(const ALeft: T; const ARight: TNullable<T>): Boolean;
begin
  result := ARight.HasValue and (ValuesCompare(ALeft, ARight.FValue) <= 0);
end;

class operator TNullable<T>.GreaterThanOrEqual(const ALeft, ARight: TNullable<T>): Boolean;
begin
  result := ALeft.HasValue and ARight.HasValue and (ValuesCompare(ALeft.FValue, ARight.FValue) >= 0);
end;

class operator TNullable<T>.GreaterThanOrEqual(const ALeft: TNullable<T>; const ARight: T): Boolean;
begin
  result := ALeft.HasValue and (ValuesCompare(ALeft.FValue, ARight) >= 0);
end;

class operator TNullable<T>.GreaterThanOrEqual(const ALeft: T; const ARight: TNullable<T>): Boolean;
begin
  result := ARight.HasValue and (ValuesCompare(ALeft, ARight.FValue) >= 0);
end;

end.
