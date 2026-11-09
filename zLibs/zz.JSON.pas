unit zz.JSON;

interface

uses
  System.JSON,
  System.SysUtils;

type
  TJSONArrayHelper = class helper for System.JSON.TJsonArray
  public
    procedure Clear;
    function Replace(const Index: Integer; const Val: TJSONValue): TJsonArray;
  end;

  TJSONObjectHelper = class Helper for System.JSON.TJSONObject
  private
    procedure SetBoolean(const Key: string; const Value: Boolean);
    procedure SetFloat(const Key: string; const Value: Double);
    procedure SetInt64(const Key: string; const Value: Int64);
    procedure SetJsonObject(const Key: string; const Value: TJSONObject);
    procedure SetString(const Key, Value: string);
    procedure SetJsonArray(const Key: string; const Value: TJsonArray);
    procedure SetDateTime(const Key: string; const Value: TDateTime);
  public
    procedure Parse(const Value: string); overload;

    function Exist(const Key: string): Boolean;
    function Replace(const Str: string; const Val: TJSONValue): TJSONObject;

    procedure Add(const Key: string; const Value: string; const DefaultValue: string = ''); overload;
    procedure Add(const Key: string; const Value: Boolean; const DefaultValue: Boolean = False); overload;
    procedure Add(const Key: string; const Value: Int64; const DefaultValue: Int64 = 0); overload;
    procedure Add(const Key: string; const Value: Double; const DefaultValue: Double = 0); overload;

    procedure AddDateTime(const Key: string; const Value: TDateTime; const DefaultValue: TDateTime = 0); overload;

    function AddArray(const Key: string): TJsonArray; overload;
    function AddObject(const Key: string): TJSONObject; overload;

    function GetBoolean(const Key: string): Boolean;
    function GetFloat(const Key: string): Double;
    function GetInt64(const Key: string): Int64;
    function GetString(const Key: string): string;
    function GetDateTime(const Key: string): TDateTime;
    function GetJsonArray(const Key: string): TJsonArray;
    function GetJsonObject(const Key: string): TJSONObject;

    function TryGetBoolean(const Key: string; var Value: Boolean): Boolean;
    function TryGetFloat(const Key: string; var Value: Double): Boolean; overload;
    function TryGetFloat(const Key: string; var Value: Single): Boolean; overload;
    function TryGetInt(const Key: string; var Value: Integer): Boolean; overload;
    function TryGetInt(const Key: string; var Value: Int64): Boolean; overload;
    // function TryGetInt(const Key: string; var Value: NativeInt): Boolean; overload;
    function TryGetInt(const Key: string; var Value: Cardinal): Boolean; overload;
    function TryGetString(const Key: string; var Value: string): Boolean;
    function TryGetDateTime(const Key: string; var Value: TDateTime): Boolean;

    property S[const Key: string]: string read GetString write SetString;
    property I[const Key: string]: Int64 read GetInt64 write SetInt64;
    property F[const Key: string]: Double read GetFloat write SetFloat;
    property B[const Key: string]: Boolean read GetBoolean write SetBoolean;
    property D[const Key: string]: TDateTime read GetDateTime write SetDateTime;
    property O[const Key: string]: TJSONObject read GetJsonObject write SetJsonObject;
    property A[const Key: string]: TJsonArray read GetJsonArray write SetJsonArray;
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections;

// DIV-JSN-6: AddDateTime scrive "aaaa-mm-gg hh:nn:ss" (con lo spazio) e la
// proprieta' D scrive il numero della data; la lettura standard accetta solo
// l'ISO 8601 con la T: con lo spazio si normalizza prima, il numero si legge diretto.
function LeggiDataOra(const Valore: TJSONValue): TDateTime;
var
  Testo: string;
  Formato: TFormatSettings;
begin
  if Valore is TJSONNumber then
  begin
    Result := TJSONNumber(Valore).AsDouble;
    Exit;
  end;
  if Valore is TJSONString then
  begin
    Testo := TJSONString(Valore).Value;
    if (Length(Testo) > 10) and (Testo[11] = ' ') then
    begin
      // formato fisso, indipendente dalle impostazioni della macchina; l'ora
      // resta quella scritta (TryISO8601ToDate la convertirebbe da UTC)
      Formato := TFormatSettings.Invariant;
      Formato.DateSeparator := '-';
      Formato.TimeSeparator := ':';
      Formato.ShortDateFormat := 'yyyy-mm-dd';
      Formato.LongTimeFormat := 'hh:nn:ss';
      if TryStrToDateTime(Testo, Result, Formato) then
        Exit;
    end;
  end;
  Result := Valore.GetValue<TDateTime>();
end;

{ TJSONObjectHelper }

procedure TJSONObjectHelper.Add(const Key: string; const Value: Double; const DefaultValue: Double);
begin
  if Value = DefaultValue then
    Exit;
  Self.AddPair(Key, TJSONNumber.Create(Value));
end;

procedure TJSONObjectHelper.Add(const Key: string; const Value: Int64; const DefaultValue: Int64);
begin
  if Value = DefaultValue then
    Exit;
  Self.AddPair(Key, TJSONNumber.Create(Value));
end;

procedure TJSONObjectHelper.Add(const Key, Value, DefaultValue: string);
begin
  if Value = DefaultValue then
    Exit;
  Self.AddPair(Key, Value);
end;

procedure TJSONObjectHelper.Add(const Key: string; const Value, DefaultValue: Boolean);
begin
  if Value = DefaultValue then
    Exit;
  Self.AddPair(Key, TJSONBool.Create(Value));
end;

procedure TJSONObjectHelper.AddDateTime(const Key: string; const Value, DefaultValue: TDateTime);
begin
  if Value = DefaultValue then
    Exit;
  // i due punti fra virgolette: sempre ':' e non il separatore della macchina
  Self.AddPair(Key, FormatDateTime('yyyy-mm-dd hh":"nn":"ss', Value));
end;

function TJSONObjectHelper.AddArray(const Key: string): TJsonArray;
begin
  Result := TJsonArray.Create;
  Self.AddPair(Key, Result);
end;

function TJSONObjectHelper.AddObject(const Key: string): TJSONObject;
begin
  Result := TJSONObject.Create;
  Self.AddPair(Key, Result);
end;

function TJSONObjectHelper.Exist(const Key: string): Boolean;
begin
  Result := Assigned(GetValue(Key));
end;

function TJSONObjectHelper.GetBoolean(const Key: string): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
    Result := V.GetValue<Boolean>()
  else
    Result := False;
end;

function TJSONObjectHelper.GetDateTime(const Key: string): TDateTime;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
    Result := LeggiDataOra(V)
  else
    Result := 0;
end;

function TJSONObjectHelper.GetFloat(const Key: string): Double;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
    Result := V.GetValue<Double>()
  else
    Result := 0;
end;

function TJSONObjectHelper.GetInt64(const Key: string): Int64;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
    Result := V.GetValue<Int64>()
  else
    Result := 0;
end;

function TJSONObjectHelper.GetJsonArray(const Key: string): TJsonArray;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    if V is TJsonArray then
      Result := V as TJsonArray
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TJSONObjectHelper.GetJsonObject(const Key: string): TJSONObject;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) and (V is TJSONObject) then
    Result := V as TJSONObject
  else
    Result := nil;
end;

function TJSONObjectHelper.GetString(const Key: string): string;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
    Result := V.GetValue<string>()
  else
    Result := '';
end;

procedure TJSONObjectHelper.Parse(const Value: string);
var
  V: TArray<Byte>;
begin
  V := TEncoding.Default.GetBytes(Value);
  Self.Parse(V, 0);
end;

function TJSONObjectHelper.Replace(const Str: string; const Val: TJSONValue): TJSONObject;
var
  I: Integer;
  List: TList<TJSONPair>;
  pair: TJSONPair;
  pairValue: TJSONValue;
  found: Boolean;
  CoppieSostituite: TList<TJSONPair>;
begin

  if Count = 0 then
    Result := AddPair(Str, Val)
  else
  begin
    List := TList<TJSONPair>.Create;
    // DIV-JSN-4 e DIV-JSN-7: le coppie sostituite si liberano dopo SetPairs
    CoppieSostituite := TList<TJSONPair>.Create;
    try
      try
        found := False;
        for I := 0 to Count - 1 do
        begin
          pair := Pairs[I];

          if SameText(pair.JsonString.Value, Str) then
          begin
            // un solo valore per chiave: le altre coppie che corrispondono si tolgono
            if not found then
            begin
              found := True;
              List.Add(TJSONPair.Create(Str, Val));
            end;
            CoppieSostituite.Add(pair);
          end
          else
            List.Add(pair);
        end;

        if not found then
          List.Add(TJSONPair.Create(Str, Val));

        SetPairs(List);
        // DIV-JSN-9: Result era assegnato solo con l'oggetto vuoto
        Result := Self;
      except
        on e: exception do
        begin
          // non utilizzare freeAndNil. Viene distrutta dall'oggetto stesso, in condizioni normali
          FreeAndNil(List);
          raise;
        end;
      end;

      for pair in CoppieSostituite do
        pair.Free;
    finally
      CoppieSostituite.Free;
    end;
  end;
end;

procedure TJSONObjectHelper.SetBoolean(const Key: string; const Value: Boolean);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  Add(Key, Value);
end;

procedure TJSONObjectHelper.SetDateTime(const Key: string; const Value: TDateTime);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  Add(Key, Value);
end;

procedure TJSONObjectHelper.SetFloat(const Key: string; const Value: Double);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  Add(Key, Value);
end;

procedure TJSONObjectHelper.SetInt64(const Key: string; const Value: Int64);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  Add(Key, Value);
end;

procedure TJSONObjectHelper.SetJsonArray(const Key: string; const Value: TJsonArray);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  AddPair(Key, Value);
end;

procedure TJSONObjectHelper.SetJsonObject(const Key: string; const Value: TJSONObject);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  AddPair(Key, Value);
end;

procedure TJSONObjectHelper.SetString(const Key, Value: string);
begin
  // DIV-JSN-4: RemovePair estrae la coppia senza liberarla
  RemovePair(Key).Free;
  Add(Key, Value);
end;

function TJSONObjectHelper.TryGetBoolean(const Key: string; var Value: Boolean): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    // DIV-JSN-8: valore non convertibile = falso, parametro invariato
    try
      Value := V.GetValue<Boolean>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TJSONObjectHelper.TryGetDateTime(const Key: string; var Value: TDateTime): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := LeggiDataOra(V);
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TJSONObjectHelper.TryGetFloat(const Key: string; var Value: Double): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := V.GetValue<Double>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TJSONObjectHelper.TryGetFloat(const Key: string; var Value: Single): Boolean;
var
  V: TJSONValue;
begin

  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := V.GetValue<Single>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

// function TJSONObjectHelper.TryGetInt(const Key: string; var Value: NativeInt): Boolean;
// var
// V: TJSONValue;
// begin
// V := GetValue(Key);
// if Assigned(V) then
// begin
// Result := True;
// Value := V.GetValue<NativeInt>()
// end
// else
// Result := False;
// end;

function TJSONObjectHelper.TryGetInt(const Key: string; var Value: Int64): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := V.GetValue<Int64>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TJSONObjectHelper.TryGetInt(const Key: string; var Value: Integer): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := V.GetValue<Integer>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TJSONObjectHelper.TryGetInt(const Key: string; var Value: Cardinal): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := V.GetValue<Cardinal>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

function TJSONObjectHelper.TryGetString(const Key: string; var Value: string): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Key);
  if Assigned(V) then
  begin
    try
      Value := V.GetValue<string>();
      Result := True;
    except
      on EJSONException do
        Result := False;
    end;
  end
  else
    Result := False;
end;

{ TJSONArrayHelper }

procedure TJSONArrayHelper.Clear;
var
  I: Integer;
begin

  // DIV-JSN-5: Remove estrae l'elemento senza liberarlo
  for I := Count - 1 downto 0 do
    Remove(I).Free;
end;

function TJSONArrayHelper.Replace(const Index: Integer; const Val: TJSONValue): TJsonArray;
var
  I: Integer;
  List: TList<TJSONValue>;
  Sostituito: TJSONValue;
begin
  Assert(index >= 0);
  Assert(index <= Count);

  Result := Self;

  List := TList<TJSONValue>.Create;
  try
    for I := 0 to index - 1 do
      List.Add(Items[I]);

    List.Add(Val);

    for I := index + 1 to Count - 1 do
      List.Add(Items[I]);

    // DIV-JSN-5: l'elemento sostituito si libera dopo SetElements
    if index < Count then
      Sostituito := Items[index]
    else
      Sostituito := nil;

    SetElements(List);
    Sostituito.Free;
  except
    on e: exception do
    begin
      FreeAndNil(List);
      raise;
    end;
  end;
end;

end.
