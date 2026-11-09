unit jsonHelper;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.DateUtils;

type
  TJSONObjectHelper = class helper for TJSONObject
  public
    function AsString(const APath: string; const ADefault: string = ''): string;
    function AsInt(const APath: string; ADefault: Int64 = 0): Int64;
    function AsFloat(const APath: string; ADefault: Double = 0.0): Double;
    function AsBoolean(const APath: string; ADefault: Boolean = False): Boolean;
    function AsDateTime(const APath: string; ADefault: TDateTime = 0): TDateTime;
    function AsDate(const APath: string; ADefault: TDateTime = 0): TDate;
    function AsTime(const APath: string; ADefault: TDateTime = 0): TTime;
    function AsJSONArray(const APath: string): TJSONArray;
    function AsJSONObject(const APath: string): TJSONObject;
  public
    // function TryGetValue<T>(out AValue: T): Boolean; overload;
    function TryGetAsString(const APath: string; out AValue: string): Boolean;
    function TryGetAsInt(const APath: string; out AValue: Integer): Boolean; overload;
    function TryGetAsInt(const APath: string; out AValue: Int64): Boolean; overload;
    function TryGetAsFloat(const APath: string; out AValue: Double): Boolean;
    function TryGetAsBool(const APath: string; out AValue: Boolean): Boolean;
    function TryGetAsDateTime(const APath: string; out AValue: TDateTime): Boolean;
    function TryGetAsDate(const APath: string; out AValue: TDate): Boolean;
    function TryGetAsTime(const APath: string; out AValue: TTime): Boolean;
    function TryGetAsJSONArray(const APath: string; out AValue: TJSONArray): Boolean;
    function TryGetAsJSONObject(const APath: string; out AValue: TJSONObject): Boolean;
  public
    function Replace(const APath: string; const AValue: TJSONValue): TJSONObject; overload;
    function Replace(const APath: string; const AValue: string): TJSONObject; overload;
    function Replace(const APath: string; AValue: Int64): TJSONObject; overload;
    function Replace(const APath: string; AValue: Double): TJSONObject; overload;
    function Replace(const APath: string; AValue: Boolean): TJSONObject; overload;
    function Replace(const APath: string; AValue: TDateTime): TJSONObject; overload;
    function Replace(const APath: string; AValue: TDate): TJSONObject; overload;
    function Replace(const APath: string; AValue: TTime): TJSONObject; overload;
    function Replace(const APath: string; AValue: TJSONArray): TJSONObject; overload;
    function Replace(const APath: string; AValue: TJSONObject): TJSONObject; overload;
  public
    function AddJSONArray(const Key: string): TJSONArray;
    function AddJSONObject(const Key: string): TJSONObject;
  public
    // Metodi utility
    function Exists(const APath: string): Boolean;
    function Parse(const Data: string; const Pos: Integer = 0; UseBool: Boolean = False): Integer; overload;
    function Clone: TJSONObject;
  end;

  TJSONArrayHelper = class helper for TJSONArray
  public
    function AsString(AIndex: Integer; const ADefault: string = ''): string;
    function AsInt(AIndex: Integer; ADefault: Int64 = 0): Int64;
    function AsFloat(AIndex: Integer; ADefault: Double = 0.0): Double;
    function AsBoolean(AIndex: Integer; ADefault: Boolean = False): Boolean;
    function AsDateTime(AIndex: Integer; ADefault: TDateTime = 0): TDateTime;
    function AsDate(AIndex: Integer; ADefault: TDateTime = 0): TDate;
    function AsTime(AIndex: Integer; ADefault: TDateTime = 0): TTime;
    function AsJSONArray(AIndex: Integer): TJSONArray;
    function AsJSONObject(AIndex: Integer): TJSONObject;
  public
    function Replace(const AIndex: Integer; const AValue: TJSONValue): TJSONArray; overload;
    function Replace(const AIndex: Integer; const AValue: string): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: Int64): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: Double): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: Boolean): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: TDateTime): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: TDate): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: TTime): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: TJSONArray): TJSONArray; overload;
    function Replace(const AIndex: Integer; AValue: TJSONObject): TJSONArray; overload;
  public
    procedure Clear;
    function Clone: TJSONArray;
    function IsEmpty: Boolean;
  end;

implementation

uses
  System.Generics.Collections;

function TJSONObjectHelper.AddJSONArray(const Key: string): TJSONArray;
begin
  Result := TJSONArray.Create;
  Self.AddPair(Key, Result);
end;

function TJSONObjectHelper.AddJSONObject(const Key: string): TJSONObject;
begin
  Result := TJSONObject.Create;
  Self.AddPair(Key, Result);
end;

{ TJSONObjectHelper }

function TJSONObjectHelper.AsString(const APath: string; const ADefault: string): string;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Assigned(Value) and not(Value is TJSONNull) then
    Result := Value.Value
  else
    Result := ADefault;
end;

function TJSONObjectHelper.AsInt(const APath: string; ADefault: Int64): Int64;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Assigned(Value) and (Value is TJSONNumber) then
    Result := TJSONNumber(Value).AsInt64
  else
    Result := ADefault;
end;

function TJSONObjectHelper.AsFloat(const APath: string; ADefault: Double): Double;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Assigned(Value) and (Value is TJSONNumber) then
    Result := TJSONNumber(Value).AsDouble
  else
    Result := ADefault;
end;

function TJSONObjectHelper.AsBoolean(const APath: string; ADefault: Boolean): Boolean;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Assigned(Value) and (Value is TJSONBool) then
    Result := TJSONBool(Value).AsBoolean
  else
    Result := ADefault;
end;

function TJSONObjectHelper.AsDateTime(const APath: string; ADefault: TDateTime): TDateTime;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Assigned(Value) then
  begin
    if Value is TJSONString then
      Result := ISO8601ToDate(TJSONString(Value).Value)
    else
      if Value is TJSONNumber then
        Result := TJSONNumber(Value).AsDouble
      else
        Result := ADefault;
  end
  else
    Result := ADefault;
end;

function TJSONObjectHelper.AsDate(const APath: string; ADefault: TDateTime): TDate;
begin
  Result := DateOf(AsDateTime(APath, ADefault));
end;

function TJSONObjectHelper.AsTime(const APath: string; ADefault: TDateTime): TTime;
begin
  Result := TimeOf(AsDateTime(APath, ADefault));
end;

function TJSONObjectHelper.AsJSONArray(const APath: string): TJSONArray;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Value is TJSONArray then
    Result := TJSONArray(Value)
  else
    Result := nil;
end;

function TJSONObjectHelper.AsJSONObject(const APath: string): TJSONObject;
var
  Value: TJSONValue;
begin
  Value := GetValue(APath);
  if Value is TJSONObject then
    Result := TJSONObject(Value)
  else
    Result := nil;
end;

function TJSONObjectHelper.Replace(const APath: string; const AValue: TJSONValue): TJSONObject;
var
  I: Integer;
  List: TList<TJSONPair>;
  Pair: TJSONPair;
  Found: Boolean;
begin
  Result := Self;

  if Count = 0 then
  begin
    AddPair(APath, AValue);
    Exit;
  end;

  List := TList<TJSONPair>.Create;
  try
    Found := False;
    for I := 0 to Count - 1 do
    begin
      Pair := Pairs[I];
      if SameText(Pair.JsonString.Value, APath) then
      begin
        Found := True;
        List.Add(TJSONPair.Create(APath, AValue));
      end
      else
        List.Add(Pair);
    end;

    if not Found then
      List.Add(TJSONPair.Create(APath, AValue));

    // SetPairs prende ownership della lista, quindi NON fare Free
    SetPairs(List);
  except
    // In caso di errore, SetPairs non è stata chiamata
    // quindi dobbiamo liberare la lista
    List.Free;
    raise;
  end;
end;

function TJSONObjectHelper.Replace(const APath: string; const AValue: string): TJSONObject;
begin
  Result := Replace(APath, TJSONString.Create(AValue));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: Int64): TJSONObject;
begin
  Result := Replace(APath, TJSONNumber.Create(AValue));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: Double): TJSONObject;
begin
  Result := Replace(APath, TJSONNumber.Create(AValue));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: Boolean): TJSONObject;
begin
  Result := Replace(APath, TJSONBool.Create(AValue));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: TDateTime): TJSONObject;
begin
  Result := Replace(APath, TJSONString.Create(DateToISO8601(AValue)));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: TDate): TJSONObject;
begin
  Result := Replace(APath, TJSONString.Create(DateToISO8601(AValue)));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: TTime): TJSONObject;
begin
  Result := Replace(APath, TJSONString.Create(DateToISO8601(AValue)));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: TJSONArray): TJSONObject;
begin
  // Cast esplicito a TJSONValue per chiamare l'overload corretto
  Result := Replace(APath, TJSONValue(AValue));
end;

function TJSONObjectHelper.Replace(const APath: string; AValue: TJSONObject): TJSONObject;
begin
  // Cast esplicito a TJSONValue per chiamare l'overload corretto
  Result := Replace(APath, TJSONValue(AValue));
end;

function TJSONObjectHelper.TryGetAsBool(const APath: string; out AValue: Boolean): Boolean;
begin
  Result := TryGetValue<Boolean>(APath, AValue);
end;

function TJSONObjectHelper.TryGetAsDateTime(const APath: string; out AValue: TDateTime): Boolean;
var
  tmp: string;
begin
  Result := TryGetValue<string>(tmp);

  if Result then
    AValue := ISO8601ToDate(tmp);
end;

function TJSONObjectHelper.TryGetAsDate(const APath: string; out AValue: TDate): Boolean;
var
  tmp: TDateTime;
begin
  Result := TryGetAsDateTime(APath, tmp);

  if Result then
    AValue := DateOf(tmp);
end;

function TJSONObjectHelper.TryGetAsTime(const APath: string; out AValue: TTime): Boolean;
var
  tmp: TDateTime;
begin
  Result := TryGetAsDateTime(APath, tmp);

  if Result then
    AValue := TimeOf(tmp);
end;

function TJSONObjectHelper.TryGetAsFloat(const APath: string; out AValue: Double): Boolean;
begin
  Result := TryGetValue<Double>(APath, AValue);
end;

function TJSONObjectHelper.TryGetAsInt(const APath: string; out AValue: Integer): Boolean;
begin
  Result := TryGetValue<Integer>(APath, AValue);
end;

function TJSONObjectHelper.TryGetAsJSONArray(const APath: string; out AValue: TJSONArray): Boolean;
begin
  Result := TryGetValue<TJSONArray>(APath, AValue);
end;

function TJSONObjectHelper.TryGetAsJSONObject(const APath: string; out AValue: TJSONObject): Boolean;
begin
  Result := TryGetValue<TJSONObject>(APath, AValue);
end;

function TJSONObjectHelper.TryGetAsString(const APath: string; out AValue: string): Boolean;
begin
  Result := TryGetValue<string>(APath, AValue);
end;

function TJSONObjectHelper.Exists(const APath: string): Boolean;
begin
  Result := Assigned(GetValue(APath));
end;

function TJSONObjectHelper.Clone: TJSONObject;
begin
  Result := TJSONObject.ParseJSONValue(ToJSON) as TJSONObject;
end;

function TJSONObjectHelper.Parse(const Data: string; const Pos: Integer; UseBool: Boolean): Integer;
var
  Bytes: TBytes;
begin
  Bytes := TEncoding.UTF8.GetBytes(Data);
  Result := inherited Parse(Bytes, Pos, UseBool);
end;

function TJSONObjectHelper.TryGetAsInt(const APath: string; out AValue: Int64): Boolean;
begin
  Result := TryGetValue<Int64>(APath, AValue);
end;

{ TJSONArrayHelper }

function TJSONArrayHelper.AsString(AIndex: Integer; const ADefault: string): string;
var
  Value: TJSONValue;
begin
  if (AIndex >= 0) and (AIndex < Count) then
  begin
    Value := Items[AIndex];
    if Assigned(Value) and not(Value is TJSONNull) then
      Result := Value.Value
    else
      Result := ADefault;
  end
  else
    Result := ADefault;
end;

function TJSONArrayHelper.AsInt(AIndex: Integer; ADefault: Int64): Int64;
begin
  if (AIndex >= 0) and (AIndex < Count) and (Items[AIndex] is TJSONNumber) then
    Result := TJSONNumber(Items[AIndex]).AsInt64
  else
    Result := ADefault;
end;

function TJSONArrayHelper.AsFloat(AIndex: Integer; ADefault: Double): Double;
begin
  if (AIndex >= 0) and (AIndex < Count) and (Items[AIndex] is TJSONNumber) then
    Result := TJSONNumber(Items[AIndex]).AsDouble
  else
    Result := ADefault;
end;

function TJSONArrayHelper.AsBoolean(AIndex: Integer; ADefault: Boolean): Boolean;
begin
  if (AIndex >= 0) and (AIndex < Count) and (Items[AIndex] is TJSONBool) then
    Result := TJSONBool(Items[AIndex]).AsBoolean
  else
    Result := ADefault;
end;

function TJSONArrayHelper.AsDateTime(AIndex: Integer; ADefault: TDateTime): TDateTime;
begin
  if (AIndex >= 0) and (AIndex < Count) then
  begin
    if Items[AIndex] is TJSONString then
      Result := ISO8601ToDate(TJSONString(Items[AIndex]).Value)
    else
      if Items[AIndex] is TJSONNumber then
        Result := TJSONNumber(Items[AIndex]).AsDouble
      else
        Result := ADefault;
  end
  else
    Result := ADefault;
end;

function TJSONArrayHelper.AsDate(AIndex: Integer; ADefault: TDateTime): TDate;
begin
  Result := DateOf(AsDateTime(AIndex, ADefault));
end;

function TJSONArrayHelper.AsTime(AIndex: Integer; ADefault: TDateTime): TTime;
begin
  Result := TimeOf(AsDateTime(AIndex, ADefault));
end;

function TJSONArrayHelper.AsJSONObject(AIndex: Integer): TJSONObject;
begin
  if (AIndex >= 0) and (AIndex < Count) and (Items[AIndex] is TJSONObject) then
    Result := TJSONObject(Items[AIndex])
  else
    Result := nil;
end;

function TJSONArrayHelper.AsJSONArray(AIndex: Integer): TJSONArray;
begin
  if (AIndex >= 0) and (AIndex < Count) and (Items[AIndex] is TJSONArray) then
    Result := TJSONArray(Items[AIndex])
  else
    Result := nil;
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; const AValue: TJSONValue): TJSONArray;
var
  I: Integer;
  List: TList<TJSONValue>;
begin
  Assert(AIndex >= 0, 'Index must be >= 0');
  Assert(AIndex < Count, 'Index out of bounds');

  Result := Self;

  List := TList<TJSONValue>.Create;
  try
    // Copia elementi precedenti
    for I := 0 to AIndex - 1 do
      List.Add(Items[I]);

    // Aggiungi nuovo valore
    List.Add(AValue);

    // Copia elementi successivi
    for I := AIndex + 1 to Count - 1 do
      List.Add(Items[I]);

    // SetElements prende ownership della lista
    SetElements(List);
  except
    // In caso di errore, SetElements non è stata chiamata
    List.Free;
    raise;
  end;
end;

procedure TJSONArrayHelper.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    Remove(I);
end;

function TJSONArrayHelper.Clone: TJSONArray;
begin
  Result := TJSONObject.ParseJSONValue(ToJSON) as TJSONArray;
end;

function TJSONArrayHelper.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; const AValue: string): TJSONArray;
begin
  Result := Replace(AIndex, AValue);
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: Int64): TJSONArray;
begin
  Result := Replace(AIndex, AValue);
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: TDateTime): TJSONArray;
begin
  Result := Replace(AIndex, TJSONString.Create(DateToISO8601(AValue)));
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: TTime): TJSONArray;
begin
  Result := Replace(AIndex, TJSONString.Create(DateToISO8601(AValue)));
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: TDate): TJSONArray;
begin
  Result := Replace(AIndex, TJSONString.Create(DateToISO8601(AValue)));
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: Boolean): TJSONArray;
begin
  Result := Replace(AIndex, AValue);
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: Double): TJSONArray;
begin
  Result := Replace(AIndex, AValue);
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: TJSONArray): TJSONArray;
begin
  Result := Replace(AIndex, AValue);
end;

function TJSONArrayHelper.Replace(const AIndex: Integer; AValue: TJSONObject): TJSONArray;
begin
  Result := Replace(AIndex, AValue);
end;

end.
