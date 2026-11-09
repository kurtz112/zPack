unit zCollection.Json;

// ==============================================================================
// Serializzatore JSON per TzCustomCollection e per i componenti che espongono
// collection published (TzMetadata).
//
// Lavora via RTTI sulle proprieta' published degli item, in streaming
// (TJsonTextWriter / TJsonTextReader): memoria costante anche su decine di
// migliaia di item.
//
// Regole di scrittura (allineate a TWriter, cosi' il JSON ha lo stesso
// contenuto informativo del DFM):
// - proprieta' con clausola "default" e valore uguale al default: omesse;
// - stringhe vuote, numeri decimali a zero, Int64 a zero: omessi;
// - TStrings e TCollection vuoti: omessi;
// - proprieta' "stored False": omesse;
// - "Name" sempre per primo, le altre in ordine alfabetico (diff stabili e
// lettura nello stesso ordine del DFM, che assegna Name per primo);
// - i valori che nel DFM passano da DefineProperties si scrivono e si leggono
// con gli agganci virtuali di TzCollectionItem (WriteJsonExtraProperties,
// ReadJsonExtraProperty, DescribeJsonExtraProperties).
//
// Regole di lettura:
// - proprieta' sconosciute o valori di tipo inatteso: segnalati con
// OnReadProblem; con StrictMode = True sollevano EzJsonReadError con il nome
// della collection, l'indice e il Name dell'item e la proprieta';
// - null: stringa vuota per le stringhe, zero per gli interi, ignorato altrove.
//
// Schema: WriteSchema / WriteComponentSchema producono un JSON Schema
// (draft-07) ricavato dalla RTTI, con enumerazioni e valori predefiniti, per
// validare un file modificato a mano prima di reimportarlo nell'LZ.
// ==============================================================================

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON.Types,
  System.JSON.Writers,
  System.JSON.Readers,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  System.Generics.Defaults,
  zCollection;

type
  TJsonSerializerOptions = record
    Indented: Boolean; // output indentato a 2 spazi
    SortProperties: Boolean; // alfabetico; Name resta comunque per primo
    SkipDefaults: Boolean; // omette i valori predefiniti (come TWriter)
    DateTimeAsISO: Boolean; // TDateTime come stringa ISO 8601
    StrictMode: Boolean; // in lettura: eccezione su proprieta' sconosciuta o valore non valido
    OnReadProblem: TzJsonReadProblemEvent; // segnalazione dei problemi di lettura (log)
    class function Default: TJsonSerializerOptions; static;
  end;

  EzJsonReadError = class(EReadError);

  // Classe statica con i metodi pubblici. Non istanziabile.
  TzCollectionJson = class
  public
    class procedure SaveToStream(Collection: TzCustomCollection; Stream: TStream); overload;
    class procedure SaveToStream(Collection: TzCustomCollection; Stream: TStream; const Options: TJsonSerializerOptions); overload;

    class procedure LoadFromStream(Collection: TzCustomCollection; Stream: TStream); overload;
    class procedure LoadFromStream(Collection: TzCustomCollection; Stream: TStream; const Options: TJsonSerializerOptions); overload;

    // Componenti con collection published (TzMetadata): un oggetto JSON con
    // una chiave per collection, nell'ordine di dichiarazione.
    class procedure SaveComponentToStream(Component: TComponent; Stream: TStream); overload;
    class procedure SaveComponentToStream(Component: TComponent; Stream: TStream; const Options: TJsonSerializerOptions); overload;
    class procedure LoadComponentFromStream(Component: TComponent; Stream: TStream); overload;
    class procedure LoadComponentFromStream(Component: TComponent; Stream: TStream; const Options: TJsonSerializerOptions); overload;

    // JSON Schema draft-07 ricavato dalla RTTI della classe item. Il primo
    // item della collection, se esiste, fa da prototipo per le collection
    // annidate (serve a conoscere la classe degli item annidati).
    // Un singolo item come oggetto JSON su una riga. Con SkipDefaults = False
    // scrive anche i valori predefiniti: e' la fotografia completa di ogni
    // proprieta', che serve a confrontare e a ripristinare l'item
    // (zCollection.Patcher).
    class function ItemToJson(Item: TPersistent; const SkipDefaults: Boolean = True): string;

    // Applica un oggetto JSON a un item gia' esistente: assegna solo le
    // proprieta' nominate e lascia invariate le altre. Gli oggetti annidati
    // (es. Menu) si fondono allo stesso modo; gli elenchi di stringhe e le
    // collection annidate nominati vengono invece sostituiti per intero.
    class procedure MergeIntoItem(Item: TPersistent; const Json: string; const Options: TJsonSerializerOptions);

    class procedure WriteSchema(Collection: TzCustomCollection; Stream: TStream; const Title: string = '');
    class procedure WriteComponentSchema(Component: TComponent; Stream: TStream; const Title: string = '');

    // Sniffa i primi byte non-whitespace dello stream per capire se
    // e' DFM (inizia con 'object ' / 'item' / TPF0) o JSON (inizia
    // con '[' o '{'). Lo stream torna a Position iniziale.
    class function DetectFormat(Stream: TStream): TzPersistenceFormat;
  end;

implementation

uses
  System.DateUtils,
  System.Variants;

const
  // Valore di PropInfo^.Default quando la proprieta' non ha clausola default.
  cNoDefault = Integer($80000000);

  // Tipi di proprieta' che il serializzatore sa scrivere e leggere.
  cSerializableKinds = [tkInteger, tkChar, tkEnumeration, tkFloat, tkString, tkSet, tkClass, tkWChar, tkLString, tkWString, tkVariant, tkInt64, tkUString];

type
  // Accesso ai membri protected degli item (agganci JSON).
  TzCollectionItemAccess = class(TzCollectionItem);
  TzCollectionItemAccessClass = class of TzCollectionItemAccess;

  // UTF-8 senza BOM: i file dentro l'LZ devono essere leggibili da qualunque
  // strumento (jq, Python json.load) senza preamboli.
  TUTF8NoBomEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

  TPropertyCacheEntry = TArray<TRttiProperty>;
  TPropertyByName = TDictionary<string, TRttiProperty>;

  // Cache RTTI per classe: elenco ordinato (Name per primo, poi alfabetico),
  // elenco in ordine di dichiarazione e dizionario nome minuscolo -> proprieta'.
  // Globale, protetta da TMonitor.
  TPropertyCache = class
  private
    FCtx: TRttiContext;
    FByClassSorted: TDictionary<TClass, TPropertyCacheEntry>;
    FByClassUnsorted: TDictionary<TClass, TPropertyCacheEntry>;
    FByName: TObjectDictionary<TClass, TPropertyByName>;
    function BuildList(AClass: TClass; Sorted: Boolean): TPropertyCacheEntry;
  public
    constructor Create;
    destructor Destroy; override;
    function GetProperties(AClass: TClass; Sorted: Boolean): TPropertyCacheEntry;
    function GetPropertyByName(AClass: TClass): TPropertyByName;
  end;

  // Worker di serializzazione: istanziato per ogni Save/Load/Schema.
  TJsonCollectionSerializer = class
  private
    FOptions: TJsonSerializerOptions;
    FCache: TPropertyCache;
    // contesto per i messaggi di errore
    FContextCollection: string;
    FItemIndex: Integer;
    FItemName: string;
    procedure Problem(const Msg: string);
    function TokenName(Reader: TJsonTextReader): string;

    // scrittura
    function ShouldWrite(const Instance: TObject; const Prop: TRttiProperty; out Value: TValue): Boolean;
    procedure WriteCollection(const Coll: TzCustomCollection; Writer: TJsonTextWriter);
    procedure WriteItem(Item: TPersistent; Writer: TJsonTextWriter);
    procedure WriteValue(const Value: TValue; Writer: TJsonTextWriter);
    procedure WriteSet(const Value: TValue; Writer: TJsonTextWriter);
    procedure WriteStrings(Strings: TStrings; Writer: TJsonTextWriter);
    procedure WriteNestedCollection(Collection: TCollection; Writer: TJsonTextWriter);
    procedure WriteComponentCollections(Component: TComponent; Writer: TJsonTextWriter);

    // lettura
    procedure ReadCollection(const Coll: TzCustomCollection; Reader: TJsonTextReader);
    procedure ReadItem(Item: TPersistent; Reader: TJsonTextReader);
    procedure ReadPropertyValue(const Instance: TObject; const Prop: TRttiProperty; Reader: TJsonTextReader);
    procedure ReadSet(const Instance: TObject; const Prop: TRttiProperty; Reader: TJsonTextReader);
    procedure ReadStrings(Strings: TStrings; Reader: TJsonTextReader);
    procedure ReadNestedCollection(Collection: TCollection; Reader: TJsonTextReader);
    procedure ReadComponentCollections(Component: TComponent; Reader: TJsonTextReader);
    procedure SkipValue(Reader: TJsonTextReader);

    // schema
    procedure WriteItemSchema(ItemClass: TClass; Prototype: TObject; Writer: TJsonTextWriter; Depth: Integer);
    procedure WritePropertySchema(const Prop: TRttiProperty; Prototype: TObject; Writer: TJsonTextWriter; Depth: Integer);
    procedure WriteEnumNames(EnumTypeInfo: PTypeInfo; Writer: TJsonTextWriter);
    procedure WriteSchemaHeader(const Title, Description: string; Writer: TJsonTextWriter);
  public
    constructor Create(const Options: TJsonSerializerOptions; Cache: TPropertyCache);
  end;

var
  GlobalPropertyCache: TPropertyCache;
  GlobalUtf8NoBom: TEncoding; // unica istanza: TStreamWriter non libera l'encoding ricevuto

  // ---------------------------------------------------------------------------
  // Funzioni di appoggio
  // ---------------------------------------------------------------------------

  // Legge un set (al massimo 32 bit) in un Integer. False se il set e' piu'
  // grande: in quel caso non viene serializzato.
function SetToInteger(const Value: TValue; out SetInt: Integer): Boolean;
begin
  Result := Value.DataSize <= SizeOf(Integer);
  SetInt := 0;
  if Result then
    Value.ExtractRawData(@SetInt);
end;

// Primo bit memorizzato di un set: i set Delphi partono dal byte che
// contiene MinValue dell'enumerazione sottostante.
function SetBitBase(EnumTypeInfo: PTypeInfo): Integer;
begin
  Result := (GetTypeData(EnumTypeInfo)^.MinValue div 8) * 8;
end;

// True se la proprieta' ha "stored False" costante (non una funzione).
function IsConstantlyNotStored(PropInfo: PPropInfo): Boolean;
var
  Raw: NativeUInt;
begin
  Raw := NativeUInt(PropInfo^.StoredProc);
  Result := ((Raw and not NativeUInt($FF)) = 0) and ((Raw and $FF) = 0);
end;

function IsDateTimeType(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = TypeInfo(TDateTime)) or (ATypeInfo = TypeInfo(TDate)) or (ATypeInfo = TypeInfo(TTime));
end;

function PropDefault(const Prop: TRttiProperty): Integer;
begin
  if Prop is TRttiInstanceProperty then
    Result := TRttiInstanceProperty(Prop).Default
  else
    Result := cNoDefault;
end;

{ TUTF8NoBomEncoding }

function TUTF8NoBomEncoding.GetPreamble: TBytes;
begin
  Result := nil;
end;

{ TJsonSerializerOptions }

class function TJsonSerializerOptions.Default: TJsonSerializerOptions;
begin
  Result.Indented := True;
  Result.SortProperties := True;
  Result.SkipDefaults := True;
  Result.DateTimeAsISO := True;
  Result.StrictMode := False;
  Result.OnReadProblem := nil;
end;

{ TPropertyCache }

constructor TPropertyCache.Create;
begin
  inherited Create;
  FCtx := TRttiContext.Create;
  FByClassSorted := TDictionary<TClass, TPropertyCacheEntry>.Create;
  FByClassUnsorted := TDictionary<TClass, TPropertyCacheEntry>.Create;
  FByName := TObjectDictionary<TClass, TPropertyByName>.Create([doOwnsValues]);
end;

destructor TPropertyCache.Destroy;
begin
  FByName.Free;
  FByClassSorted.Free;
  FByClassUnsorted.Free;
  FCtx.Free;
  inherited;
end;

function TPropertyCache.BuildList(AClass: TClass; Sorted: Boolean): TPropertyCacheEntry;
var
  RttiType: TRttiType;
  Prop: TRttiProperty;
  List: TList<TRttiProperty>;
  i: Integer;
begin
  List := TList<TRttiProperty>.Create;
  try
    RttiType := FCtx.GetType(AClass);
    for Prop in RttiType.GetProperties do
    begin
      if Prop.Visibility <> mvPublished then
        Continue;
      // Come TWriter: solo proprieta' leggibili E scrivibili. Le published in
      // sola lettura (es. TzLastMdf.UserName) non finiscono nel DFM e non
      // devono finire nemmeno nel JSON.
      if not (Prop.IsReadable and Prop.IsWritable) then
        Continue;
      if not (Prop.PropertyType.TypeKind in cSerializableKinds) then
        Continue;
      List.Add(Prop);
    end;

    if Sorted then
    begin
      List.Sort(TComparer<TRttiProperty>.Construct(
        function(const Left, Right: TRttiProperty): Integer
        begin
          Result := CompareText(Left.Name, Right.Name);
        end));

      // Name sempre per primo: TReader lo assegna per primo e i setter
      // degli item possono dipendere dal nome.
      for i := 0 to List.Count - 1 do
        if SameText(List[i].Name, 'Name') then
        begin
          List.Move(i, 0);
          Break;
        end;
    end;

    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

function TPropertyCache.GetProperties(AClass: TClass; Sorted: Boolean): TPropertyCacheEntry;
var
  Dict: TDictionary<TClass, TPropertyCacheEntry>;
begin
  if Sorted then
    Dict := FByClassSorted
  else
    Dict := FByClassUnsorted;

  MonitorEnter(Self);
  try
    if Dict.TryGetValue(AClass, Result) then
      Exit;

    Result := BuildList(AClass, Sorted);
    Dict.Add(AClass, Result);
  finally
    MonitorExit(Self);
  end;
end;

function TPropertyCache.GetPropertyByName(AClass: TClass): TPropertyByName;
var
  Prop: TRttiProperty;
begin
  MonitorEnter(Self);
  try
    if FByName.TryGetValue(AClass, Result) then
      Exit;

    Result := TPropertyByName.Create;
    for Prop in GetProperties(AClass, False) do
      Result.AddOrSetValue(LowerCase(Prop.Name), Prop);
    FByName.Add(AClass, Result);
  finally
    MonitorExit(Self);
  end;
end;

{ TJsonCollectionSerializer }

constructor TJsonCollectionSerializer.Create(const Options: TJsonSerializerOptions; Cache: TPropertyCache);
begin
  inherited Create;
  FOptions := Options;
  FCache := Cache;
  FItemIndex := -1;
end;

procedure TJsonCollectionSerializer.Problem(const Msg: string);
var
  Handled: Boolean;
  Full: string;
begin
  if FItemIndex >= 0 then
    Full := Format('%s, item %d "%s": %s', [FContextCollection, FItemIndex, FItemName, Msg])
  else
    Full := Format('%s: %s', [FContextCollection, Msg]);

  Handled := False;
  if Assigned(FOptions.OnReadProblem) then
    FOptions.OnReadProblem(Self, Full, Handled);

  if FOptions.StrictMode and not Handled then
    raise EzJsonReadError.Create(Full);
end;

function TJsonCollectionSerializer.TokenName(Reader: TJsonTextReader): string;
begin
  Result := GetEnumName(TypeInfo(TJsonToken), Ord(Reader.TokenType));
end;

// -------------------------- WRITE ----------------------------------------

function TJsonCollectionSerializer.ShouldWrite(const Instance: TObject; const Prop: TRttiProperty; out Value: TValue): Boolean;
var
  Def: Integer;
  SetInt: Integer;
  Obj: TObject;
  V: Variant;
begin
  Result := False;

  if not (Prop is TRttiInstanceProperty) then
    Exit;

  if not IsStoredProp(Instance, TRttiInstanceProperty(Prop).PropInfo) then
    Exit;

  Value := Prop.GetValue(Instance);

  if not FOptions.SkipDefaults then
    Exit(True);

  case Value.Kind of
    tkInteger, tkChar, tkWChar, tkEnumeration:
      begin
        Def := PropDefault(Prop);
        Result := (Def = cNoDefault) or (Value.AsOrdinal <> Def);
      end;

    tkSet:
      begin
        Def := PropDefault(Prop);
        if Def = cNoDefault then
          Result := True
        else
          Result := (not SetToInteger(Value, SetInt)) or (SetInt <> Def);
      end;

    tkInt64:
      Result := Value.AsInt64 <> 0;

    tkFloat:
      Result := Value.AsExtended <> 0;

    tkString, tkLString, tkWString, tkUString:
      Result := Value.AsString <> '';

    tkVariant:
      begin
        V := Value.AsVariant;
        Result := not (VarIsEmpty(V) or VarIsNull(V));
      end;

    tkClass:
      begin
        Obj := Value.AsObject;
        if Obj = nil then
          Result := False
        else
          if Obj is TStrings then
            Result := TStrings(Obj).Count > 0
          else
            if Obj is TCollection then
              Result := TCollection(Obj).Count > 0
            else
              Result := True;
      end;
  else
    Result := True;
  end;
end;

procedure TJsonCollectionSerializer.WriteCollection(const Coll: TzCustomCollection; Writer: TJsonTextWriter);
var
  i: Integer;
begin
  Writer.WriteStartArray;
  for i := 0 to Coll.Count - 1 do
    WriteItem(TPersistent(Coll.Items[i]), Writer);
  Writer.WriteEndArray;
end;

procedure TJsonCollectionSerializer.WriteItem(Item: TPersistent; Writer: TJsonTextWriter);
var
  Props: TPropertyCacheEntry;
  Prop: TRttiProperty;
  Value: TValue;
begin
  Writer.WriteStartObject;

  Props := FCache.GetProperties(Item.ClassType, FOptions.SortProperties);
  for Prop in Props do
    if ShouldWrite(Item, Prop, Value) then
    begin
      Writer.WritePropertyName(Prop.Name);
      WriteValue(Value, Writer);
    end;

  // valori che nel DFM passano da DefineProperties
  if Item is TzCollectionItem then
    TzCollectionItemAccess(Item).WriteJsonExtraProperties(Writer);

  Writer.WriteEndObject;
end;

procedure TJsonCollectionSerializer.WriteValue(const Value: TValue; Writer: TJsonTextWriter);
var
  Obj: TObject;
begin
  case Value.Kind of
    tkInteger:
      Writer.WriteValue(Value.AsInteger);

    tkInt64:
      Writer.WriteValue(Value.AsInt64);

    tkFloat:
      begin
        if IsDateTimeType(Value.TypeInfo) and FOptions.DateTimeAsISO then
          Writer.WriteValue(DateToISO8601(Value.AsExtended, False))
        else
          Writer.WriteValue(Value.AsExtended);
      end;

    tkString, tkLString, tkUString, tkWString, tkChar, tkWChar:
      Writer.WriteValue(Value.AsString);

    tkEnumeration:
      begin
        if Value.TypeInfo = TypeInfo(Boolean) then
          Writer.WriteValue(Value.AsBoolean)
        else
          Writer.WriteValue(GetEnumName(Value.TypeInfo, Value.AsOrdinal));
      end;

    tkSet:
      WriteSet(Value, Writer);

    tkVariant:
      Writer.WriteValue(VarToStr(Value.AsVariant));

    tkClass:
      begin
        Obj := Value.AsObject;
        if Obj = nil then
          Writer.WriteNull
        else
          if Obj is TStrings then
            WriteStrings(TStrings(Obj), Writer)
          else
            if Obj is TCollection then
              WriteNestedCollection(TCollection(Obj), Writer)
            else
              if Obj is TPersistent then
                WriteItem(TPersistent(Obj), Writer)
              else
                Writer.WriteNull;
      end;
  else
    Writer.WriteNull;
  end;
end;

procedure TJsonCollectionSerializer.WriteSet(const Value: TValue; Writer: TJsonTextWriter);
var
  EnumTypeInfo: PTypeInfo;
  SetInt: Integer;
  Base: Integer;
  i: Integer;
begin
  if not SetToInteger(Value, SetInt) then
  begin
    // set oltre i 32 elementi: non gestito, meglio null che un valore troncato
    Writer.WriteNull;
    Exit;
  end;

  EnumTypeInfo := GetTypeData(Value.TypeInfo)^.CompType^;
  Base := SetBitBase(EnumTypeInfo);

  Writer.WriteStartArray;
  with GetTypeData(EnumTypeInfo)^ do
    for i := MinValue to MaxValue do
      if (SetInt and (1 shl (i - Base))) <> 0 then
        Writer.WriteValue(GetEnumName(EnumTypeInfo, i));
  Writer.WriteEndArray;
end;

procedure TJsonCollectionSerializer.WriteStrings(Strings: TStrings; Writer: TJsonTextWriter);
var
  i: Integer;
begin
  Writer.WriteStartArray;
  for i := 0 to Strings.Count - 1 do
    Writer.WriteValue(Strings[i]);
  Writer.WriteEndArray;
end;

procedure TJsonCollectionSerializer.WriteNestedCollection(Collection: TCollection; Writer: TJsonTextWriter);
var
  i: Integer;
begin
  Writer.WriteStartArray;
  for i := 0 to Collection.Count - 1 do
    WriteItem(Collection.Items[i], Writer);
  Writer.WriteEndArray;
end;

procedure TJsonCollectionSerializer.WriteComponentCollections(Component: TComponent; Writer: TJsonTextWriter);
var
  Props: TPropertyCacheEntry;
  Prop: TRttiProperty;
  Obj: TObject;
begin
  Writer.WriteStartObject;

  // ordine di dichiarazione, come il DFM
  Props := FCache.GetProperties(Component.ClassType, False);
  for Prop in Props do
  begin
    if Prop.PropertyType.TypeKind <> tkClass then
      Continue;

    Obj := Prop.GetValue(Component).AsObject;
    if not (Obj is TzCustomCollection) then
      Continue;

    FContextCollection := Prop.Name;
    Writer.WritePropertyName(Prop.Name);
    WriteCollection(TzCustomCollection(Obj), Writer);
  end;

  Writer.WriteEndObject;
end;

// -------------------------- READ -----------------------------------------

procedure TJsonCollectionSerializer.ReadCollection(const Coll: TzCustomCollection; Reader: TJsonTextReader);
var
  NewItem: TCollectionItem;
begin
  if Coll.Name <> '' then
    FContextCollection := Coll.Name
  else
    FContextCollection := Coll.ClassName;

  // Ci aspettiamo di trovare l'apertura di un array
  if Reader.TokenType <> TJsonToken.StartArray then
    if not Reader.Read or (Reader.TokenType <> TJsonToken.StartArray) then
      raise EzJsonReadError.Create(FContextCollection + ': atteso array JSON come radice della collection');

  Coll.Clear;

  while Reader.Read and (Reader.TokenType <> TJsonToken.EndArray) do
  begin
    if Reader.TokenType <> TJsonToken.StartObject then
      raise EzJsonReadError.CreateFmt('%s: atteso oggetto JSON come item della collection, trovato %s', [FContextCollection, TokenName(Reader)]);

    FItemIndex := Coll.Count;
    FItemName := '';
    NewItem := Coll.Add;
    ReadItem(NewItem, Reader);
  end;

  FItemIndex := -1;
  FItemName := '';
end;

procedure TJsonCollectionSerializer.ReadItem(Item: TPersistent; Reader: TJsonTextReader);
var
  ByName: TPropertyByName;
  Prop: TRttiProperty;
  PropName: string;
begin
  ByName := FCache.GetPropertyByName(Item.ClassType);

  while Reader.Read and (Reader.TokenType <> TJsonToken.EndObject) do
  begin
    if Reader.TokenType <> TJsonToken.PropertyName then
      raise EzJsonReadError.CreateFmt('%s, item %d: atteso nome di proprieta'', trovato %s', [FContextCollection, FItemIndex, TokenName(Reader)]);

    PropName := Reader.Value.AsString;

    if not Reader.Read then
      raise EzJsonReadError.CreateFmt('%s, item %d: valore mancante per la proprieta'' %s', [FContextCollection, FItemIndex, PropName]);

    if ByName.TryGetValue(LowerCase(PropName), Prop) then
    begin
      ReadPropertyValue(Item, Prop, Reader);

      if (Item is TzCollectionItem) and SameText(Prop.Name, 'Name') then
        FItemName := TzCollectionItem(Item).Name;
    end
    else
      if (Item is TzCollectionItem) and TzCollectionItemAccess(Item).ReadJsonExtraProperty(PropName, Reader) then
        // consumato dall'aggancio dell'item (valori da DefineProperties)
      else
      begin
        Problem(Format('proprieta'' "%s" sconosciuta per la classe %s', [PropName, Item.ClassName]));
        SkipValue(Reader);
      end;
  end;
end;

procedure TJsonCollectionSerializer.ReadPropertyValue(const Instance: TObject; const Prop: TRttiProperty; Reader: TJsonTextReader);
var
  V: TValue;
  Obj: TObject;
  S: string;
  i: Integer;
  Vr: Variant;

  procedure BadValue;
  begin
    Problem(Format('valore di tipo %s non valido per la proprieta'' %s (%s)', [TokenName(Reader), Prop.Name, Prop.PropertyType.Name]));
    SkipValue(Reader);
  end;

begin
  // Le proprieta' oggetto si leggono nell'istanza esistente anche senza
  // setter (come fa TReader); le altre richiedono il setter.
  if (Prop.PropertyType.TypeKind <> tkClass) and (not Prop.IsWritable) then
  begin
    Problem(Format('proprieta'' %s in sola lettura', [Prop.Name]));
    SkipValue(Reader);
    Exit;
  end;

  case Prop.PropertyType.TypeKind of
    tkInteger:
      case Reader.TokenType of
        TJsonToken.Integer:
          Prop.SetValue(Instance, TValue.From<Integer>(Reader.Value.AsInteger));
        TJsonToken.Null:
          Prop.SetValue(Instance, TValue.From<Integer>(0));
      else
        BadValue;
      end;

    tkInt64:
      case Reader.TokenType of
        TJsonToken.Integer:
          Prop.SetValue(Instance, TValue.From<Int64>(Reader.Value.AsInt64));
        TJsonToken.Null:
          Prop.SetValue(Instance, TValue.From<Int64>(0));
      else
        BadValue;
      end;

    tkFloat:
      case Reader.TokenType of
        TJsonToken.String:
          if IsDateTimeType(Prop.PropertyType.Handle) then
          begin
            S := Reader.Value.AsString;
            Prop.SetValue(Instance, TValue.From<TDateTime>(ISO8601ToDate(S, False)));
          end
          else
            BadValue;
        TJsonToken.Float:
          Prop.SetValue(Instance, TValue.From<Double>(Reader.Value.AsExtended));
        TJsonToken.Integer:
          Prop.SetValue(Instance, TValue.From<Double>(Reader.Value.AsInteger));
        TJsonToken.Null:
          ;
      else
        BadValue;
      end;

    tkString, tkLString, tkUString, tkWString, tkChar, tkWChar:
      case Reader.TokenType of
        TJsonToken.String:
          Prop.SetValue(Instance, TValue.From<string>(Reader.Value.AsString));
        TJsonToken.Null:
          Prop.SetValue(Instance, TValue.From<string>(''));
        TJsonToken.Integer, TJsonToken.Float, TJsonToken.Boolean:
          // tollerato: il valore scalare viene convertito in stringa
          Prop.SetValue(Instance, TValue.From<string>(Reader.Value.ToString));
      else
        BadValue;
      end;

    tkEnumeration:
      begin
        if Prop.PropertyType.Handle = TypeInfo(Boolean) then
        begin
          if Reader.TokenType = TJsonToken.Boolean then
            Prop.SetValue(Instance, TValue.From<Boolean>(Reader.Value.AsBoolean))
          else
            if Reader.TokenType <> TJsonToken.Null then
              BadValue;
        end
        else
        begin
          if Reader.TokenType = TJsonToken.String then
          begin
            S := Reader.Value.AsString;
            i := GetEnumValue(Prop.PropertyType.Handle, S);
            if i >= 0 then
            begin
              TValue.Make(@i, Prop.PropertyType.Handle, V);
              Prop.SetValue(Instance, V);
            end
            else
              Problem(Format('valore "%s" non previsto per la proprieta'' %s (%s)', [S, Prop.Name, Prop.PropertyType.Name]));
          end
          else
            if Reader.TokenType <> TJsonToken.Null then
              BadValue;
        end;
      end;

    tkSet:
      ReadSet(Instance, Prop, Reader);

    tkVariant:
      begin
        case Reader.TokenType of
          TJsonToken.String:
            Vr := Reader.Value.AsString;
          TJsonToken.Integer:
            Vr := Reader.Value.AsInt64;
          TJsonToken.Float:
            Vr := Reader.Value.AsExtended;
          TJsonToken.Boolean:
            Vr := Reader.Value.AsBoolean;
          TJsonToken.Null:
            Vr := Null;
        else
          begin
            BadValue;
            Exit;
          end;
        end;
        Prop.SetValue(Instance, TValue.From<Variant>(Vr));
      end;

    tkClass:
      begin
        Obj := Prop.GetValue(Instance).AsObject;
        if Obj = nil then
        begin
          // l'istanza non c'e': non si puo' creare in modo generico
          if Reader.TokenType <> TJsonToken.Null then
            Problem(Format('proprieta'' %s senza istanza: valore ignorato', [Prop.Name]));
          SkipValue(Reader);
          Exit;
        end;

        if Reader.TokenType = TJsonToken.Null then
          Exit;

        if Obj is TStrings then
          ReadStrings(TStrings(Obj), Reader)
        else
          if Obj is TCollection then
            ReadNestedCollection(TCollection(Obj), Reader)
          else
            if Obj is TPersistent then
            begin
              if Reader.TokenType = TJsonToken.StartObject then
                ReadItem(TPersistent(Obj), Reader)
              else
                BadValue;
            end
            else
              SkipValue(Reader);
      end;
  else
    SkipValue(Reader);
  end;
end;

procedure TJsonCollectionSerializer.ReadSet(const Instance: TObject; const Prop: TRttiProperty; Reader: TJsonTextReader);
var
  EnumTypeInfo: PTypeInfo;
  SetInt: Integer;
  Base: Integer;
  EnumName: string;
  EnumOrd: Integer;
  V: TValue;
begin
  if Reader.TokenType = TJsonToken.Null then
    Exit;

  if Reader.TokenType <> TJsonToken.StartArray then
  begin
    Problem(Format('valore di tipo %s non valido per il set %s', [TokenName(Reader), Prop.Name]));
    SkipValue(Reader);
    Exit;
  end;

  if Prop.GetValue(Instance).DataSize > SizeOf(Integer) then
  begin
    Problem(Format('set %s oltre i 32 elementi: non gestito', [Prop.Name]));
    SkipValue(Reader);
    Exit;
  end;

  EnumTypeInfo := GetTypeData(Prop.PropertyType.Handle)^.CompType^;
  Base := SetBitBase(EnumTypeInfo);
  SetInt := 0;

  while Reader.Read and (Reader.TokenType <> TJsonToken.EndArray) do
  begin
    if Reader.TokenType = TJsonToken.String then
    begin
      EnumName := Reader.Value.AsString;
      EnumOrd := GetEnumValue(EnumTypeInfo, EnumName);
      if EnumOrd >= 0 then
        SetInt := SetInt or (1 shl (EnumOrd - Base))
      else
        Problem(Format('valore "%s" non previsto nel set %s', [EnumName, Prop.Name]));
    end
    else
      Problem(Format('elemento di tipo %s non valido nel set %s', [TokenName(Reader), Prop.Name]));
  end;

  TValue.Make(@SetInt, Prop.PropertyType.Handle, V);
  Prop.SetValue(Instance, V);
end;

procedure TJsonCollectionSerializer.ReadStrings(Strings: TStrings; Reader: TJsonTextReader);
begin
  if Reader.TokenType <> TJsonToken.StartArray then
  begin
    Problem(Format('valore di tipo %s non valido per un elenco di stringhe', [TokenName(Reader)]));
    SkipValue(Reader);
    Exit;
  end;

  Strings.BeginUpdate;
  try
    Strings.Clear;
    while Reader.Read and (Reader.TokenType <> TJsonToken.EndArray) do
    begin
      case Reader.TokenType of
        TJsonToken.String:
          Strings.Add(Reader.Value.AsString);
        TJsonToken.Null:
          Strings.Add('');
        TJsonToken.Integer, TJsonToken.Float, TJsonToken.Boolean:
          Strings.Add(Reader.Value.ToString);
      else
        begin
          Problem(Format('elemento di tipo %s non valido in un elenco di stringhe', [TokenName(Reader)]));
          SkipValue(Reader);
        end;
      end;
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure TJsonCollectionSerializer.ReadNestedCollection(Collection: TCollection; Reader: TJsonTextReader);
var
  NewItem: TCollectionItem;
  SavedIndex: Integer;
  SavedName: string;
begin
  if Reader.TokenType <> TJsonToken.StartArray then
  begin
    Problem(Format('valore di tipo %s non valido per una collection annidata', [TokenName(Reader)]));
    SkipValue(Reader);
    Exit;
  end;

  // il contesto (indice e nome) resta quello dell'item esterno
  SavedIndex := FItemIndex;
  SavedName := FItemName;

  Collection.BeginUpdate;
  try
    Collection.Clear;
    while Reader.Read and (Reader.TokenType <> TJsonToken.EndArray) do
    begin
      if Reader.TokenType <> TJsonToken.StartObject then
      begin
        Problem(Format('elemento di tipo %s non valido in una collection annidata', [TokenName(Reader)]));
        SkipValue(Reader);
        Continue;
      end;
      NewItem := Collection.Add;
      ReadItem(NewItem, Reader);
      FItemIndex := SavedIndex;
      FItemName := SavedName;
    end;
  finally
    Collection.EndUpdate;
  end;
end;

procedure TJsonCollectionSerializer.ReadComponentCollections(Component: TComponent; Reader: TJsonTextReader);
var
  ByName: TPropertyByName;
  Prop: TRttiProperty;
  PropName: string;
  Obj: TObject;
begin
  FContextCollection := Component.Name;
  if FContextCollection = '' then
    FContextCollection := Component.ClassName;

  if Reader.TokenType <> TJsonToken.StartObject then
    if not Reader.Read or (Reader.TokenType <> TJsonToken.StartObject) then
      raise EzJsonReadError.Create(FContextCollection + ': atteso oggetto JSON come radice del componente');

  ByName := FCache.GetPropertyByName(Component.ClassType);

  while Reader.Read and (Reader.TokenType <> TJsonToken.EndObject) do
  begin
    if Reader.TokenType <> TJsonToken.PropertyName then
      raise EzJsonReadError.CreateFmt('%s: atteso nome di sezione, trovato %s', [FContextCollection, TokenName(Reader)]);

    PropName := Reader.Value.AsString;

    if not Reader.Read then
      raise EzJsonReadError.CreateFmt('%s: valore mancante per la sezione %s', [FContextCollection, PropName]);

    Obj := nil;
    if ByName.TryGetValue(LowerCase(PropName), Prop) and (Prop.PropertyType.TypeKind = tkClass) then
      Obj := Prop.GetValue(Component).AsObject;

    if Obj is TzCustomCollection then
    begin
      TzCustomCollection(Obj).BeginUpdate;
      try
        ReadCollection(TzCustomCollection(Obj), Reader);
      finally
        TzCustomCollection(Obj).EndUpdate;
      end;
      FContextCollection := Component.Name;
    end
    else
    begin
      FItemIndex := -1;
      Problem(Format('sezione "%s" sconosciuta per la classe %s', [PropName, Component.ClassName]));
      SkipValue(Reader);
    end;
  end;
end;

procedure TJsonCollectionSerializer.SkipValue(Reader: TJsonTextReader);
var
  Depth: Integer;
begin
  // Reader posizionato sul token da saltare. Se e' un valore scalare basta
  // cosi'; se e' StartArray/StartObject si consuma fino alla chiusura.
  case Reader.TokenType of
    TJsonToken.StartArray, TJsonToken.StartObject:
      begin
        Depth := 1;
        while (Depth > 0) and Reader.Read do
        begin
          case Reader.TokenType of
            TJsonToken.StartArray, TJsonToken.StartObject:
              Inc(Depth);
            TJsonToken.EndArray, TJsonToken.EndObject:
              Dec(Depth);
          end;
        end;
      end;
  end;
end;

// -------------------------- SCHEMA ---------------------------------------

procedure TJsonCollectionSerializer.WriteSchemaHeader(const Title, Description: string; Writer: TJsonTextWriter);
begin
  Writer.WritePropertyName('$schema');
  Writer.WriteValue('http://json-schema.org/draft-07/schema#');
  Writer.WritePropertyName('title');
  Writer.WriteValue(Title);
  Writer.WritePropertyName('description');
  Writer.WriteValue(Description);
end;

procedure TJsonCollectionSerializer.WriteEnumNames(EnumTypeInfo: PTypeInfo; Writer: TJsonTextWriter);
var
  i: Integer;
begin
  Writer.WriteStartArray;
  with GetTypeData(EnumTypeInfo)^ do
    for i := MinValue to MaxValue do
      Writer.WriteValue(GetEnumName(EnumTypeInfo, i));
  Writer.WriteEndArray;
end;

procedure TJsonCollectionSerializer.WritePropertySchema(const Prop: TRttiProperty; Prototype: TObject; Writer: TJsonTextWriter; Depth: Integer);
var
  Def: Integer;
  Cls: TClass;
  Obj: TObject;
  SubProto: TObject;
  Handle: PTypeInfo;

  procedure WriteType(const TypeName: string);
  begin
    Writer.WritePropertyName('type');
    Writer.WriteValue(TypeName);
  end;

begin
  Handle := Prop.PropertyType.Handle;
  Def := PropDefault(Prop);

  Writer.WriteStartObject;

  case Prop.PropertyType.TypeKind of
    tkInteger, tkInt64:
      begin
        WriteType('integer');
        if (Prop.PropertyType.TypeKind = tkInteger) and (Def <> cNoDefault) then
        begin
          Writer.WritePropertyName('default');
          Writer.WriteValue(Def);
        end;
      end;

    tkChar, tkWChar:
      begin
        WriteType('string');
        Writer.WritePropertyName('maxLength');
        Writer.WriteValue(1);
      end;

    tkFloat:
      begin
        if IsDateTimeType(Handle) then
        begin
          WriteType('string');
          Writer.WritePropertyName('format');
          Writer.WriteValue('date-time');
        end
        else
          WriteType('number');
      end;

    tkString, tkLString, tkWString, tkUString:
      WriteType('string');

    tkEnumeration:
      begin
        if Handle = TypeInfo(Boolean) then
        begin
          WriteType('boolean');
          if Def <> cNoDefault then
          begin
            Writer.WritePropertyName('default');
            Writer.WriteValue(Def <> 0);
          end;
        end
        else
        begin
          WriteType('string');
          Writer.WritePropertyName('enum');
          WriteEnumNames(Handle, Writer);
          if Def <> cNoDefault then
          begin
            Writer.WritePropertyName('default');
            Writer.WriteValue(GetEnumName(Handle, Def));
          end;
        end;
      end;

    tkSet:
      begin
        WriteType('array');
        Writer.WritePropertyName('uniqueItems');
        Writer.WriteValue(True);
        Writer.WritePropertyName('items');
        Writer.WriteStartObject;
        WriteType('string');
        Writer.WritePropertyName('enum');
        WriteEnumNames(GetTypeData(Handle)^.CompType^, Writer);
        Writer.WriteEndObject;
      end;

    tkVariant:
      begin
        Writer.WritePropertyName('description');
        Writer.WriteValue('Variant: stringa, numero, booleano o null');
      end;

    tkClass:
      begin
        Cls := TRttiInstanceType(Prop.PropertyType).MetaclassType;

        Obj := nil;
        if Prototype <> nil then
          Obj := Prop.GetValue(Prototype).AsObject;

        if Cls.InheritsFrom(TStrings) then
        begin
          WriteType('array');
          Writer.WritePropertyName('items');
          Writer.WriteStartObject;
          WriteType('string');
          Writer.WriteEndObject;
        end
        else
          if Cls.InheritsFrom(TCollection) then
          begin
            WriteType('array');
            Writer.WritePropertyName('items');
            if (Obj is TCollection) and (Depth < 8) then
            begin
              SubProto := nil;
              if TCollection(Obj).Count > 0 then
                SubProto := TCollection(Obj).Items[0];
              WriteItemSchema(TCollection(Obj).ItemClass, SubProto, Writer, Depth + 1);
            end
            else
            begin
              // senza un'istanza prototipo la classe degli item non e' nota
              Writer.WriteStartObject;
              WriteType('object');
              Writer.WriteEndObject;
            end;
          end
          else
            if Depth < 8 then
              WriteItemSchema(Cls, Obj, Writer, Depth + 1)
            else
              WriteType('object');
      end;
  else
    Writer.WritePropertyName('description');
    Writer.WriteValue('tipo non serializzato');
  end;

  Writer.WriteEndObject;
end;

procedure TJsonCollectionSerializer.WriteItemSchema(ItemClass: TClass; Prototype: TObject; Writer: TJsonTextWriter; Depth: Integer);
var
  Props: TPropertyCacheEntry;
  Prop: TRttiProperty;
begin
  Writer.WriteStartObject;

  Writer.WritePropertyName('type');
  Writer.WriteValue('object');
  Writer.WritePropertyName('description');
  Writer.WriteValue(ItemClass.ClassName);
  Writer.WritePropertyName('additionalProperties');
  Writer.WriteValue(False);

  Writer.WritePropertyName('properties');
  Writer.WriteStartObject;

  Props := FCache.GetProperties(ItemClass, True);
  for Prop in Props do
  begin
    if not (Prop is TRttiInstanceProperty) then
      Continue;
    // "stored False" costante: mai nel file, quindi mai nello schema
    if IsConstantlyNotStored(TRttiInstanceProperty(Prop).PropInfo) then
      Continue;

    Writer.WritePropertyName(Prop.Name);
    WritePropertySchema(Prop, Prototype, Writer, Depth);
  end;

  if ItemClass.InheritsFrom(TzCollectionItem) then
    TzCollectionItemAccessClass(ItemClass).DescribeJsonExtraProperties(Writer);

  Writer.WriteEndObject; // properties
  Writer.WriteEndObject;
end;

// -------------------------- TzCollectionJson -----------------------------

function CreateWriter(Stream: TStream; const Options: TJsonSerializerOptions; out StreamWriter: TStreamWriter): TJsonTextWriter;
begin
  StreamWriter := TStreamWriter.Create(Stream, GlobalUtf8NoBom);
  Result := TJsonTextWriter.Create(StreamWriter);
  if Options.Indented then
  begin
    Result.Formatting := TJsonFormatting.Indented;
    Result.IndentChar := ' ';
    Result.Indentation := 2;
  end
  else
    Result.Formatting := TJsonFormatting.None;
end;

class procedure TzCollectionJson.SaveToStream(Collection: TzCustomCollection; Stream: TStream);
begin
  SaveToStream(Collection, Stream, TJsonSerializerOptions.Default);
end;

class procedure TzCollectionJson.SaveToStream(Collection: TzCustomCollection; Stream: TStream; const Options: TJsonSerializerOptions);
var
  StreamWriter: TStreamWriter;
  Writer: TJsonTextWriter;
  Worker: TJsonCollectionSerializer;
begin
  if not Assigned(Collection) then
    Exit;

  if not Assigned(Stream) then
    Exit;

  Writer := CreateWriter(Stream, Options, StreamWriter);
  try
    Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
    try
      Worker.WriteCollection(Collection, Writer);
    finally
      Worker.Free;
    end;
  finally
    Writer.Free;
    StreamWriter.Free;
  end;
end;

class procedure TzCollectionJson.LoadFromStream(Collection: TzCustomCollection; Stream: TStream);
begin
  LoadFromStream(Collection, Stream, TJsonSerializerOptions.Default);
end;

class procedure TzCollectionJson.LoadFromStream(Collection: TzCustomCollection; Stream: TStream; const Options: TJsonSerializerOptions);
var
  StreamReader: TStreamReader;
  Reader: TJsonTextReader;
  Worker: TJsonCollectionSerializer;
begin
  if not Assigned(Collection) then
    Exit;

  if not Assigned(Stream) then
    Exit;

  if Stream.Size = 0 then
    Exit;

  Collection.BeginUpdate;
  try
    StreamReader := TStreamReader.Create(Stream, TEncoding.UTF8, True);
    try
      Reader := TJsonTextReader.Create(StreamReader);
      try
        Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
        try
          Worker.ReadCollection(Collection, Reader);
        finally
          Worker.Free;
        end;
      finally
        Reader.Free;
      end;
    finally
      StreamReader.Free;
    end;
  finally
    Collection.EndUpdate;
  end;
end;

class procedure TzCollectionJson.SaveComponentToStream(Component: TComponent; Stream: TStream);
begin
  SaveComponentToStream(Component, Stream, TJsonSerializerOptions.Default);
end;

class procedure TzCollectionJson.SaveComponentToStream(Component: TComponent; Stream: TStream; const Options: TJsonSerializerOptions);
var
  StreamWriter: TStreamWriter;
  Writer: TJsonTextWriter;
  Worker: TJsonCollectionSerializer;
begin
  if not Assigned(Component) then
    Exit;

  if not Assigned(Stream) then
    Exit;

  Writer := CreateWriter(Stream, Options, StreamWriter);
  try
    Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
    try
      Worker.WriteComponentCollections(Component, Writer);
    finally
      Worker.Free;
    end;
  finally
    Writer.Free;
    StreamWriter.Free;
  end;
end;

class procedure TzCollectionJson.LoadComponentFromStream(Component: TComponent; Stream: TStream);
begin
  LoadComponentFromStream(Component, Stream, TJsonSerializerOptions.Default);
end;

class procedure TzCollectionJson.LoadComponentFromStream(Component: TComponent; Stream: TStream; const Options: TJsonSerializerOptions);
var
  StreamReader: TStreamReader;
  Reader: TJsonTextReader;
  Worker: TJsonCollectionSerializer;
begin
  if not Assigned(Component) then
    Exit;

  if not Assigned(Stream) then
    Exit;

  if Stream.Size = 0 then
    Exit;

  StreamReader := TStreamReader.Create(Stream, TEncoding.UTF8, True);
  try
    Reader := TJsonTextReader.Create(StreamReader);
    try
      Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
      try
        Worker.ReadComponentCollections(Component, Reader);
      finally
        Worker.Free;
      end;
    finally
      Reader.Free;
    end;
  finally
    StreamReader.Free;
  end;
end;

class function TzCollectionJson.ItemToJson(Item: TPersistent; const SkipDefaults: Boolean): string;
var
  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
  Worker: TJsonCollectionSerializer;
  Options: TJsonSerializerOptions;
begin
  Result := '';

  if not Assigned(Item) then
    Exit;

  Options := TJsonSerializerOptions.Default;
  Options.Indented := False;
  Options.SkipDefaults := SkipDefaults;

  StringWriter := TStringWriter.Create;
  try
    Writer := TJsonTextWriter.Create(StringWriter);
    try
      Writer.Formatting := TJsonFormatting.None;
      Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
      try
        Worker.WriteItem(Item, Writer);
      finally
        Worker.Free;
      end;
    finally
      Writer.Free;
    end;
    Result := StringWriter.ToString;
  finally
    StringWriter.Free;
  end;
end;

class procedure TzCollectionJson.MergeIntoItem(Item: TPersistent; const Json: string; const Options: TJsonSerializerOptions);
var
  StringReader: TStringReader;
  Reader: TJsonTextReader;
  Worker: TJsonCollectionSerializer;
begin
  if not Assigned(Item) then
    Exit;

  StringReader := TStringReader.Create(Json);
  try
    Reader := TJsonTextReader.Create(StringReader);
    try
      if not Reader.Read or (Reader.TokenType <> TJsonToken.StartObject) then
        raise EzJsonReadError.Create(Item.ClassName + ': atteso un oggetto JSON');

      Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
      try
        // contesto per i messaggi: collection, posizione e nome dell'item
        Worker.FContextCollection := Item.ClassName;
        if Item is TCollectionItem then
        begin
          Worker.FItemIndex := TCollectionItem(Item).Index;
          if TCollectionItem(Item).Collection is TzCustomCollection then
            if TzCustomCollection(TCollectionItem(Item).Collection).Name <> '' then
              Worker.FContextCollection := TzCustomCollection(TCollectionItem(Item).Collection).Name;
        end;
        if Item is TzCollectionItem then
          Worker.FItemName := TzCollectionItem(Item).Name;

        Worker.ReadItem(Item, Reader);
      finally
        Worker.Free;
      end;
    finally
      Reader.Free;
    end;
  finally
    StringReader.Free;
  end;
end;

class procedure TzCollectionJson.WriteSchema(Collection: TzCustomCollection; Stream: TStream; const Title: string);
var
  StreamWriter: TStreamWriter;
  Writer: TJsonTextWriter;
  Worker: TJsonCollectionSerializer;
  Options: TJsonSerializerOptions;
  Prototype: TObject;
  SchemaTitle: string;
begin
  if not Assigned(Collection) then
    Exit;

  if not Assigned(Stream) then
    Exit;

  SchemaTitle := Title;
  if SchemaTitle = '' then
    SchemaTitle := Collection.ClassName;

  Prototype := nil;
  if Collection.Count > 0 then
    Prototype := Collection.Items[0];

  Options := TJsonSerializerOptions.Default;
  Writer := CreateWriter(Stream, Options, StreamWriter);
  try
    Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
    try
      Writer.WriteStartObject;
      Worker.WriteSchemaHeader(SchemaTitle, Format('Collection %s, item di classe %s. Generato dalla RTTI il %s.', [Collection.ClassName, Collection.ItemClass.ClassName, DateToStr(Date)]), Writer);
      Writer.WritePropertyName('type');
      Writer.WriteValue('array');
      Writer.WritePropertyName('items');
      Worker.WriteItemSchema(Collection.ItemClass, Prototype, Writer, 0);
      Writer.WriteEndObject;
    finally
      Worker.Free;
    end;
  finally
    Writer.Free;
    StreamWriter.Free;
  end;
end;

class procedure TzCollectionJson.WriteComponentSchema(Component: TComponent; Stream: TStream; const Title: string);
var
  StreamWriter: TStreamWriter;
  Writer: TJsonTextWriter;
  Worker: TJsonCollectionSerializer;
  Options: TJsonSerializerOptions;
  Props: TPropertyCacheEntry;
  Prop: TRttiProperty;
  Obj: TObject;
  Prototype: TObject;
  SchemaTitle: string;
begin
  if not Assigned(Component) then
    Exit;

  if not Assigned(Stream) then
    Exit;

  SchemaTitle := Title;
  if SchemaTitle = '' then
    SchemaTitle := Component.ClassName;

  Options := TJsonSerializerOptions.Default;
  Writer := CreateWriter(Stream, Options, StreamWriter);
  try
    Worker := TJsonCollectionSerializer.Create(Options, GlobalPropertyCache);
    try
      Writer.WriteStartObject;
      Worker.WriteSchemaHeader(SchemaTitle, Format('Componente %s: una sezione per collection. Generato dalla RTTI il %s.', [Component.ClassName, DateToStr(Date)]), Writer);
      Writer.WritePropertyName('type');
      Writer.WriteValue('object');
      Writer.WritePropertyName('additionalProperties');
      Writer.WriteValue(False);
      Writer.WritePropertyName('properties');
      Writer.WriteStartObject;

      Props := GlobalPropertyCache.GetProperties(Component.ClassType, False);
      for Prop in Props do
      begin
        if Prop.PropertyType.TypeKind <> tkClass then
          Continue;
        Obj := Prop.GetValue(Component).AsObject;
        if not (Obj is TzCustomCollection) then
          Continue;

        Prototype := nil;
        if TzCustomCollection(Obj).Count > 0 then
          Prototype := TzCustomCollection(Obj).Items[0];

        Writer.WritePropertyName(Prop.Name);
        Writer.WriteStartObject;
        Writer.WritePropertyName('type');
        Writer.WriteValue('array');
        Writer.WritePropertyName('items');
        Worker.WriteItemSchema(TzCustomCollection(Obj).ItemClass, Prototype, Writer, 0);
        Writer.WriteEndObject;
      end;

      Writer.WriteEndObject; // properties
      Writer.WriteEndObject;
    finally
      Worker.Free;
    end;
  finally
    Writer.Free;
    StreamWriter.Free;
  end;
end;

class function TzCollectionJson.DetectFormat(Stream: TStream): TzPersistenceFormat;
var
  StartPos: Int64;
  B: Byte;
  i: Integer;
const
  WhiteSpace = [9, 10, 13, 32];
begin
  Result := pfUnknown;

  if not Assigned(Stream) then
    Exit;

  if Stream.Size = 0 then
    Exit;

  StartPos := Stream.Position;
  try
    // Salta il BOM UTF-8 se presente (EF BB BF)
    Stream.Position := 0;
    if Stream.Size >= 3 then
    begin
      Stream.Read(B, 1);
      if B = $EF then
      begin
        Stream.Read(B, 1);
        if B = $BB then
        begin
          Stream.Read(B, 1);
          if B <> $BF then
            Stream.Position := 0;
        end
        else
          Stream.Position := 0;
      end
      else
        Stream.Position := 0;
    end;

    // Primo byte non-whitespace
    for i := 1 to 64 do
    begin
      if Stream.Read(B, 1) < 1 then
        Break;
      if B in WhiteSpace then
        Continue;

      case B of
        Ord('['), Ord('{'):
          Result := pfJSON;
        Ord('o'), Ord('i'):
          // 'object ' o 'item' (DFM testuale)
          Result := pfDFM;
        $FF, $00 .. $08:
          // possibile DFM binario
          Result := pfDFM;
        Ord('T'):
          // 'TPF0' = DFM binario
          Result := pfDFM;
      end;
      Break;
    end;
  finally
    Stream.Position := StartPos;
  end;
end;

initialization

GlobalPropertyCache := TPropertyCache.Create;
GlobalUtf8NoBom := TUTF8NoBomEncoding.Create;

finalization

GlobalUtf8NoBom.Free;
GlobalPropertyCache.Free;

end.
