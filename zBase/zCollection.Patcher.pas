// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-25
// ---------------------------------------------------------------------------
unit zCollection.Patcher;

// ==============================================================================
// Patch JSON del dizionario LZ: un documento che elenca le correzioni da
// applicare agli item delle collection già caricate in memoria, invece di
// sostituire l'intero archivio.
//
// {
//   "formato": "zCollection.Patch",
//   "versione": 1,
//   "applicazione": "Gesty",
//   "id": "GESTY-162-20260923",
//   "ticket": 162,
//   "data": "2026-09-23",
//   "autore": "...",
//   "descrizione": "...",
//   "operazioni": [
//     { "op": "modifica", "collection": "TzDataSets", "item": "Modulo.Dataset",
//       "atteso": { ... }, "imposta": { ... } },
//     { "op": "aggiungi", "collection": "TzDataModules", "item": "Modulo",
//       "percorso": "DataSets[Master]/DbViews", "valore": { "Name": "...", ... },
//       "dopo": "AltroItem" },
//     { "op": "elimina", "collection": "TzDbViews", "item": "Modulo.Dataset",
//       "atteso": { ... } }
//   ]
// }
//
// Regole:
// - "collection" è il nome di classe della collection, lo stesso del membro
//   dell'archivio LZ (TzDataSets, TzDataModules, TzDbViews, ...): a quale
//   oggetto corrisponde lo decide il risolutore passato dal chiamante;
// - "percorso" scende nelle collection annidate di un item: segmenti separati
//   da "/", ognuno "Proprieta[NomeItem]". Per "aggiungi" l'ultimo segmento è
//   la sola proprietà collection che riceve l'item nuovo, senza parentesi;
// - "imposta" fonde: cambia solo le proprietà nominate. Gli oggetti annidati
//   (es. "Menu") si fondono allo stesso modo, mentre elenchi di stringhe e
//   collection annidate nominati si sostituiscono per intero. "Name" non si
//   cambia: le chiavi LZ sono i nomi e una rinomina lascerebbe orfani i
//   riferimenti degli altri file;
// - "atteso" è la condizione: l'operazione parte solo se l'item ha quei
//   valori. Se l'item ha già i valori di "imposta" (o "valore" per aggiungi,
//   o manca già per elimina) l'operazione risulta "già presente" e si salta:
//   la stessa patch si può importare più volte senza danni;
// - tutto o niente: Verify prova ogni operazione e annulla sempre, Apply
//   annulla tutto se anche una sola operazione va in conflitto o in errore.
// ==============================================================================

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  zCollection;

const
  zCollectionPatchFormat = 'zCollection.Patch';
  zCollectionPatchVersion = 1;

type
  EzCollectionPatchError = class(Exception);

  TzPatchOperationKind = (pokModifica, pokAggiungi, pokElimina);

  // poDaApplicare: verificata, pronta (dopo Verify)
  // poApplicata: eseguita e confermata (dopo Apply)
  // poGiaPresente: il dizionario è già nello stato voluto, niente da fare
  // poConflitto: l'item non è quello atteso, o non esiste
  // poErrore: la patch è scritta male per questo dizionario (proprietà o percorso inesistenti)
  TzPatchOutcome = (poDaApplicare, poApplicata, poGiaPresente, poConflitto, poErrore);

  // Restituisce la collection dato il nome di classe (TzDataSets, ...), nil se sconosciuta.
  TzCollectionResolver = reference to function(const CollectionName: string): TzCustomCollection;

  TzPatchOperation = class
  private
    FNumber: Integer;
    FKind: TzPatchOperationKind;
    FCollectionName: string;
    FItemName: string;
    FPath: string;
    FAfter: string;
    FExpected: TJSONObject; // appartiene al documento della patch
    FValues: TJSONObject; // "imposta" o "valore", appartiene al documento della patch
    FOutcome: TzPatchOutcome;
    FMessage: string;
    FCollection: TzCustomCollection;
  public
    function Title: string;
    function PropertyNames: string;
    property Number: Integer read FNumber;
    property Kind: TzPatchOperationKind read FKind;
    property CollectionName: string read FCollectionName;
    property ItemName: string read FItemName;
    property Path: string read FPath;
    property Outcome: TzPatchOutcome read FOutcome;
    property Message: string read FMessage;
    // Collection di primo livello toccata, valorizzata da Verify/Apply.
    property Collection: TzCustomCollection read FCollection;
  end;

  TzCollectionPatch = class
  private
    FDocument: TJSONObject;
    FId: string;
    FApplication: string;
    FTicket: string;
    FDate: string;
    FAuthor: string;
    FDescription: string;
    FOperations: TObjectList<TzPatchOperation>;
    procedure ParseDocument;
    procedure ParseOperation(Json: TJSONObject; const Number: Integer);
    procedure Execute(const Resolver: TzCollectionResolver; const DryRun: Boolean);
    procedure AddOperationLines(Lines: TStrings; Operation: TzPatchOperation);
    procedure AddProblemLines(Lines: TStrings; const MaxProblems: Integer);
  public
    // Legge e controlla la struttura del documento; EzCollectionPatchError se non è una patch valida.
    constructor Create(const JsonText: string);
    destructor Destroy; override;

    // Prova tutte le operazioni sul dizionario e le annulla: gli esiti restano
    // nelle operazioni. True se nessuna è in conflitto o in errore.
    function Verify(const Resolver: TzCollectionResolver): Boolean;

    // Applica tutte le operazioni. Se una sola va in conflitto o in errore
    // annulla anche quelle già eseguite e solleva EzCollectionPatchError con il resoconto.
    procedure Apply(const Resolver: TzCollectionResolver);

    function HasProblems: Boolean;
    function HasChanges: Boolean;
    function CountOutcome(const Outcome: TzPatchOutcome): Integer;
    function TouchedCollections: TArray<TzCustomCollection>;

    // Conteggio degli esiti in una riga: "3 da applicare, 0 applicate, ...".
    function OutcomeText: string;

    // Le sole operazioni in conflitto o in errore, con il loro messaggio: al
    // massimo MaxProblems, poi una riga che dice quante ne restano.
    function ProblemsSummary(const MaxProblems: Integer = MaxInt): string;

    // Resoconto completo: esito e operazioni da correggere in testa, poi tutte le operazioni.
    function Report: string;

    property Id: string read FId;
    property ApplicationName: string read FApplication;
    property Ticket: string read FTicket;
    property CreationDate: string read FDate;
    property Author: string read FAuthor;
    property Description: string read FDescription;
    property Operations: TObjectList<TzPatchOperation> read FOperations;
  end;

function PatchOutcomeText(const Outcome: TzPatchOutcome): string;
function PatchOperationKindText(const Kind: TzPatchOperationKind): string;

implementation

uses
  System.TypInfo,
  System.Math,
  System.StrUtils,
  zCollection.Json;

type
  TUndoKind = (ukRestore, ukRemoveAdded, ukReattach);

  // Una voce del registro di annullamento: cosa è stato fatto e come tornare indietro.
  TUndoEntry = class
  public
    Kind: TUndoKind;
    Item: TCollectionItem;
    Snapshot: string; // ukRestore: valori precedenti delle sole proprietà toccate
    Owner: TCollection; // ukReattach: collection da cui l'item è stato staccato
    Position: Integer; // ukReattach: posizione originale
  end;

  // Una esecuzione della patch: esegue le operazioni tenendo il registro per annullarle.
  TPatchRun = class
  private
    FResolver: TzCollectionResolver;
    FJournal: TObjectList<TUndoEntry>;
    procedure AddUndo(const Kind: TUndoKind; Item: TCollectionItem; const Snapshot: string; Owner: TCollection; const Position: Integer);
    function ResolveCollection(Operation: TzPatchOperation): TzCustomCollection;
    function FindTarget(Operation: TzPatchOperation; out Target: TCollectionItem; out Missing: string): Boolean;
    procedure RunModify(Operation: TzPatchOperation);
    procedure RunAdd(Operation: TzPatchOperation);
    procedure RunDelete(Operation: TzPatchOperation);
  public
    constructor Create(const Resolver: TzCollectionResolver);
    destructor Destroy; override;
    procedure Run(Operation: TzPatchOperation);
    procedure Undo(const FirstEntry: Integer);
    procedure Commit;
  end;

  // ---------------------------------------------------------------------------
  // Funzioni di appoggio sul JSON
  // ---------------------------------------------------------------------------

function FindValue(Json: TJSONObject; const Key: string): TJSONValue;
var
  Pair: TJSONPair;
begin
  Result := nil;

  if not Assigned(Json) then
    Exit;

  for Pair in Json do
    if SameText(Pair.JsonString.Value, Key) then
      Exit(Pair.JsonValue);
end;

function StringValue(Json: TJSONObject; const Key: string): string;
var
  Value: TJSONValue;
begin
  Value := FindValue(Json, Key);

  if (Value = nil) or (Value is TJSONNull) then
    Exit('');

  // numeri ("versione": 1, "ticket": 162) e testi valgono entrambi: TJSONNumber
  // si nomina a parte perché non in tutte le versioni di Delphi discende da TJSONString
  if (Value is TJSONString) or (Value is TJSONNumber) or (Value is TJSONBool) then
    Exit(Trim(Value.Value));

  raise EzCollectionPatchError.CreateFmt('La chiave "%s" deve contenere un testo.', [Key]);
end;

function ObjectValue(Json: TJSONObject; const Key: string; const Context: string): TJSONObject;
var
  Value: TJSONValue;
begin
  Value := FindValue(Json, Key);

  if (Value = nil) or (Value is TJSONNull) then
    Exit(nil);

  if not (Value is TJSONObject) then
    raise EzCollectionPatchError.CreateFmt('%s: la chiave "%s" deve contenere un oggetto JSON.', [Context, Key]);

  Result := TJSONObject(Value);
end;

// Valore "vuoto" per il serializzatore: le proprietà a valore predefinito possono
// mancare nella fotografia dell'item, e allora equivalgono a questi.
function IsEmptyJson(Value: TJSONValue): Boolean;
begin
  if (Value = nil) or (Value is TJSONNull) then
    Exit(True);

  if Value is TJSONNumber then
    Exit(TJSONNumber(Value).AsDouble = 0);

  if Value is TJSONString then
    Exit(TJSONString(Value).Value = '');

  if Value is TJSONBool then
    Exit(not TJSONBool(Value).AsBoolean);

  if Value is TJSONArray then
    Exit(TJSONArray(Value).Count = 0);

  if Value is TJSONObject then
    Exit(TJSONObject(Value).Count = 0);

  Result := False;
end;

function SameScalar(Expected, Current: TJSONValue): Boolean;
begin
  if IsEmptyJson(Expected) and IsEmptyJson(Current) then
    Exit(True);

  if (Expected = nil) or (Current = nil) then
    Exit(False);

  if (Expected is TJSONNumber) and (Current is TJSONNumber) then
    Exit(SameValue(TJSONNumber(Expected).AsDouble, TJSONNumber(Current).AsDouble, 1E-9));

  if (Expected is TJSONBool) and (Current is TJSONBool) then
    Exit(TJSONBool(Expected).AsBoolean = TJSONBool(Current).AsBoolean);

  // testi (maiuscole comprese) e casi misti: confronto sul testo del valore
  Result := Expected.Value = Current.Value;
end;

// True se Current contiene Expected: per gli oggetti contano solo le chiavi di
// Expected, gli elenchi devono avere la stessa lunghezza e contenere elemento
// per elemento, gli scalari devono essere uguali.
function JsonContains(Expected, Current: TJSONValue): Boolean;
var
  Pair: TJSONPair;
  i: Integer;
begin
  if Expected is TJSONObject then
  begin
    if not (Current is TJSONObject) then
      Exit(IsEmptyJson(Expected) and IsEmptyJson(Current));

    for Pair in TJSONObject(Expected) do
      if not JsonContains(Pair.JsonValue, FindValue(TJSONObject(Current), Pair.JsonString.Value)) then
        Exit(False);

    Exit(True);
  end;

  if Expected is TJSONArray then
  begin
    if not (Current is TJSONArray) then
      Exit(IsEmptyJson(Expected) and IsEmptyJson(Current));

    if TJSONArray(Expected).Count <> TJSONArray(Current).Count then
      Exit(False);

    for i := 0 to TJSONArray(Expected).Count - 1 do
      if not JsonContains(TJSONArray(Expected).Items[i], TJSONArray(Current).Items[i]) then
        Exit(False);

    Exit(True);
  end;

  Result := SameScalar(Expected, Current);
end;

function ValueText(Value: TJSONValue): string;
begin
  if Value = nil then
    Result := '(assente)'
  else
    if (Value is TJSONString) and not (Value is TJSONNumber) then
      Result := '"' + Value.Value + '"'
    else
      Result := Value.ToJSON;

  if Length(Result) > 120 then
    Result := Copy(Result, 1, 117) + '...';
end;

// Elenco leggibile delle chiavi di Expected che Current non rispetta.
function DescribeDifferences(Expected, Current: TJSONObject; const Prefix: string = ''): string;
var
  Pair: TJSONPair;
  CurrentValue: TJSONValue;
  Differences: TStringList;
begin
  Differences := TStringList.Create;
  try
    for Pair in Expected do
    begin
      CurrentValue := FindValue(Current, Pair.JsonString.Value);
      if JsonContains(Pair.JsonValue, CurrentValue) then
        Continue;

      if (Pair.JsonValue is TJSONObject) and (CurrentValue is TJSONObject) then
        Differences.Add(DescribeDifferences(TJSONObject(Pair.JsonValue), TJSONObject(CurrentValue), Prefix + Pair.JsonString.Value + '.'))
      else
        Differences.Add(Format('%s%s: atteso %s, trovato %s', [Prefix, Pair.JsonString.Value, ValueText(Pair.JsonValue), ValueText(CurrentValue)]));
    end;

    Result := string.Join('; ', Differences.ToStringArray);
  finally
    Differences.Free;
  end;
end;

// Chiavi di Values che l'item non ha: la fotografia completa elenca tutte le
// proprietà persistite, quindi una chiave assente è un nome sbagliato. Senza
// questo controllo una chiave errata con valore vuoto risulterebbe "già presente".
function UnknownKeys(Values, Current: TJSONObject; const Prefix: string = ''): string;
var
  Pair: TJSONPair;
  CurrentValue: TJSONValue;
  Nested: string;
begin
  Result := '';

  for Pair in Values do
  begin
    CurrentValue := FindValue(Current, Pair.JsonString.Value);

    if CurrentValue = nil then
      Nested := Prefix + Pair.JsonString.Value
    else
      if (Pair.JsonValue is TJSONObject) and (CurrentValue is TJSONObject) then
        Nested := UnknownKeys(TJSONObject(Pair.JsonValue), TJSONObject(CurrentValue), Prefix + Pair.JsonString.Value + '.')
      else
        Nested := '';

    if Nested <> '' then
    begin
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + Nested;
    end;
  end;
end;

procedure CheckKnownKeys(Values, Current: TJSONObject; const Key: string; Item: TCollectionItem);
var
  Unknown: string;
begin
  if not Assigned(Values) then
    Exit;

  Unknown := UnknownKeys(Values, Current);
  if Unknown <> '' then
    raise EzCollectionPatchError.CreateFmt('"%s": proprietà sconosciute per la classe %s: %s.', [Key, Item.ClassName, Unknown]);
end;

// Lo stesso oggetto con "Name" per primo: il lettore assegna le proprietà
// nell'ordine del testo e i setter degli item possono dipendere dal nome.
function NameFirst(Values: TJSONObject): string;
var
  Ordered: TJSONObject;
  Pair: TJSONPair;
begin
  Ordered := TJSONObject.Create;
  try
    for Pair in Values do
      if SameText(Pair.JsonString.Value, 'Name') then
        Ordered.AddPair(Pair.JsonString.Value, TJSONValue(Pair.JsonValue.Clone));

    for Pair in Values do
      if not SameText(Pair.JsonString.Value, 'Name') then
        Ordered.AddPair(Pair.JsonString.Value, TJSONValue(Pair.JsonValue.Clone));

    Result := Ordered.ToJSON;
  finally
    Ordered.Free;
  end;
end;

// Fotografia completa dell'item, valori predefiniti compresi.
function ItemSnapshot(Item: TCollectionItem): TJSONObject;
var
  Value: TJSONValue;
begin
  Value := TJSONObject.ParseJSONValue(TzCollectionJson.ItemToJson(Item, False), True, True);

  if not (Value is TJSONObject) then
  begin
    Value.Free;
    raise EzCollectionPatchError.CreateFmt('Impossibile leggere le proprietà dell''item di classe %s.', [Item.ClassName]);
  end;

  Result := TJSONObject(Value);
end;

function StrictOptions: TJsonSerializerOptions;
begin
  // in applicazione ogni proprietà sconosciuta o valore di tipo sbagliato è un errore
  Result := TJsonSerializerOptions.Default;
  Result.StrictMode := True;
end;

// ---------------------------------------------------------------------------
// Funzioni di appoggio sulle collection
// ---------------------------------------------------------------------------

function ItemName(Item: TCollectionItem): string;
begin
  if Item is TzCollectionItem then
    Exit(TzCollectionItem(Item).Name);

  if IsPublishedProp(Item, 'Name') and (PropType(Item, 'Name') in [tkString, tkLString, tkWString, tkUString]) then
    Exit(GetStrProp(Item, 'Name'));

  Result := '';
end;

function FindItemByName(Collection: TCollection; const Name: string): TCollectionItem;
var
  i: Integer;
begin
  Result := nil;

  if Name = '' then
    Exit;

  // stesso criterio di TzCollection<T>.IndexOf
  for i := 0 to Collection.Count - 1 do
    if AnsiCompareText(ItemName(Collection.Items[i]), Name) = 0 then
      Exit(Collection.Items[i]);
end;

function NestedCollection(Instance: TPersistent; const PropertyName: string): TCollection;
var
  Nested: TObject;
begin
  if not IsPublishedProp(Instance, PropertyName) then
    raise EzCollectionPatchError.CreateFmt('La classe %s non ha la proprietà "%s".', [Instance.ClassName, PropertyName]);

  if PropType(Instance, PropertyName) <> tkClass then
    raise EzCollectionPatchError.CreateFmt('La proprietà %s.%s non è una collection.', [Instance.ClassName, PropertyName]);

  Nested := GetObjectProp(Instance, PropertyName);
  if not (Nested is TCollection) then
    raise EzCollectionPatchError.CreateFmt('La proprietà %s.%s non è una collection.', [Instance.ClassName, PropertyName]);

  Result := TCollection(Nested);
end;

function SplitPath(const Path: string): TArray<string>;
var
  i: Integer;
begin
  Result := Path.Split(['/'], TStringSplitOptions.ExcludeEmpty);
  for i := 0 to High(Result) do
    Result[i] := Trim(Result[i]);
end;

// "DataSets[Master]" -> PropertyName = DataSets, ChildName = Master; "DbViews" -> ChildName vuoto
procedure ParseSegment(const Segment: string; out PropertyName, ChildName: string);
var
  OpenPosition: Integer;
begin
  OpenPosition := Pos('[', Segment);

  if OpenPosition = 0 then
  begin
    PropertyName := Trim(Segment);
    ChildName := '';
  end
  else
  begin
    if not Segment.EndsWith(']') then
      raise EzCollectionPatchError.CreateFmt('Segmento di percorso "%s" non valido: manca la "]" finale.', [Segment]);

    PropertyName := Trim(Copy(Segment, 1, OpenPosition - 1));
    ChildName := Trim(Copy(Segment, OpenPosition + 1, Length(Segment) - OpenPosition - 1));

    if ChildName = '' then
      raise EzCollectionPatchError.CreateFmt('Segmento di percorso "%s" non valido: nome dell''item vuoto.', [Segment]);
  end;

  if PropertyName = '' then
    raise EzCollectionPatchError.CreateFmt('Segmento di percorso "%s" non valido: manca il nome della proprietà.', [Segment]);
end;

procedure RemoveItem(Item: TCollectionItem);
begin
  if Item is TzCollectionItem then
    TzCollectionItem(Item).RemoveFromCollection
  else
    if Assigned(Item.Collection) then
      Item.Collection.Delete(Item.Index)
    else
      Item.Free;
end;

procedure Conflict(Operation: TzPatchOperation; const Message: string);
begin
  Operation.FOutcome := poConflitto;
  Operation.FMessage := Message;
end;

function PatchOutcomeText(const Outcome: TzPatchOutcome): string;
begin
  case Outcome of
    poDaApplicare:
      Result := 'DA APPLICARE';
    poApplicata:
      Result := 'APPLICATA';
    poGiaPresente:
      Result := 'GIÀ PRESENTE';
    poConflitto:
      Result := 'CONFLITTO';
    poErrore:
      Result := 'ERRORE';
  else
    Result := '?';
  end;
end;

function PatchOperationKindText(const Kind: TzPatchOperationKind): string;
begin
  case Kind of
    pokModifica:
      Result := 'modifica';
    pokAggiungi:
      Result := 'aggiungi';
    pokElimina:
      Result := 'elimina';
  else
    Result := '?';
  end;
end;

{ TzPatchOperation }

function TzPatchOperation.Title: string;
begin
  Result := PatchOperationKindText(FKind) + ' ' + FCollectionName;

  if FItemName <> '' then
    Result := Result + ' > ' + FItemName;

  if FPath <> '' then
    Result := Result + ' > ' + FPath;

  if (FKind = pokAggiungi) and Assigned(FValues) then
    Result := Result + ' > ' + StringValue(FValues, 'Name');
end;

function TzPatchOperation.PropertyNames: string;
var
  Pair: TJSONPair;
begin
  Result := '';

  if not Assigned(FValues) then
    Exit;

  for Pair in FValues do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + Pair.JsonString.Value;
  end;
end;

{ TPatchRun }

constructor TPatchRun.Create(const Resolver: TzCollectionResolver);
begin
  inherited Create;
  FResolver := Resolver;
  FJournal := TObjectList<TUndoEntry>.Create(True);
end;

destructor TPatchRun.Destroy;
begin
  FJournal.Free;
  inherited;
end;

procedure TPatchRun.AddUndo(const Kind: TUndoKind; Item: TCollectionItem; const Snapshot: string; Owner: TCollection; const Position: Integer);
var
  Entry: TUndoEntry;
begin
  Entry := TUndoEntry.Create;
  Entry.Kind := Kind;
  Entry.Item := Item;
  Entry.Snapshot := Snapshot;
  Entry.Owner := Owner;
  Entry.Position := Position;
  FJournal.Add(Entry);
end;

function TPatchRun.ResolveCollection(Operation: TzPatchOperation): TzCustomCollection;
begin
  Result := FResolver(Operation.FCollectionName);

  if not Assigned(Result) then
    raise EzCollectionPatchError.CreateFmt('Collection "%s" sconosciuta.', [Operation.FCollectionName]);

  Operation.FCollection := Result;
end;

function TPatchRun.FindTarget(Operation: TzPatchOperation; out Target: TCollectionItem; out Missing: string): Boolean;
var
  Current: TCollectionItem;
  Segment: string;
  PropertyName: string;
  ChildName: string;
begin
  Target := nil;
  Missing := '';

  Current := FindItemByName(ResolveCollection(Operation), Operation.FItemName);
  if Current = nil then
  begin
    Missing := Format('item "%s" non trovato in %s', [Operation.FItemName, Operation.FCollectionName]);
    Exit(False);
  end;

  for Segment in SplitPath(Operation.FPath) do
  begin
    ParseSegment(Segment, PropertyName, ChildName);

    if ChildName = '' then
      raise EzCollectionPatchError.CreateFmt('Percorso "%s": il segmento "%s" deve indicare l''item fra parentesi quadre.', [Operation.FPath, Segment]);

    Current := FindItemByName(NestedCollection(Current, PropertyName), ChildName);
    if Current = nil then
    begin
      Missing := Format('item "%s" non trovato in %s', [ChildName, PropertyName]);
      Exit(False);
    end;
  end;

  Target := Current;
  Result := True;
end;

procedure TPatchRun.RunModify(Operation: TzPatchOperation);
var
  Target: TCollectionItem;
  Missing: string;
  Current: TJSONObject;
  Previous: TJSONObject;
  Pair: TJSONPair;
  CurrentValue: TJSONValue;
begin
  if not FindTarget(Operation, Target, Missing) then
  begin
    Conflict(Operation, Missing);
    Exit;
  end;

  Current := ItemSnapshot(Target);
  try
    CheckKnownKeys(Operation.FExpected, Current, 'atteso', Target);
    CheckKnownKeys(Operation.FValues, Current, 'imposta', Target);

    if JsonContains(Operation.FValues, Current) then
    begin
      Operation.FOutcome := poGiaPresente;
      Exit;
    end;

    if Assigned(Operation.FExpected) and not JsonContains(Operation.FExpected, Current) then
    begin
      Conflict(Operation, DescribeDifferences(Operation.FExpected, Current));
      Exit;
    end;

    // valori precedenti delle sole proprietà che cambiano: ripristinarli non
    // ricrea gli item delle collection annidate che la patch non tocca
    Previous := TJSONObject.Create;
    try
      for Pair in Operation.FValues do
      begin
        CurrentValue := FindValue(Current, Pair.JsonString.Value);
        if Assigned(CurrentValue) then
          Previous.AddPair(Pair.JsonString.Value, TJSONValue(CurrentValue.Clone));
      end;
      AddUndo(ukRestore, Target, Previous.ToJSON, nil, -1);
    finally
      Previous.Free;
    end;
  finally
    Current.Free;
  end;

  TzCollectionJson.MergeIntoItem(Target, Operation.FValues.ToJSON, StrictOptions);
end;

procedure TPatchRun.RunAdd(Operation: TzPatchOperation);
var
  TargetCollection: TCollection;
  Owner: TCollectionItem;
  Existing: TCollectionItem;
  AfterItem: TCollectionItem;
  NewItem: TCollectionItem;
  NewName: string;
  Current: TJSONObject;
  Segments: TArray<string>;
  PropertyName: string;
  ChildName: string;
  i: Integer;
begin
  TargetCollection := ResolveCollection(Operation);

  if Operation.FPath <> '' then
  begin
    Owner := FindItemByName(TargetCollection, Operation.FItemName);
    if Owner = nil then
    begin
      Conflict(Operation, Format('item "%s" non trovato in %s', [Operation.FItemName, Operation.FCollectionName]));
      Exit;
    end;

    Segments := SplitPath(Operation.FPath);
    for i := 0 to High(Segments) do
    begin
      ParseSegment(Segments[i], PropertyName, ChildName);

      if i < High(Segments) then
      begin
        if ChildName = '' then
          raise EzCollectionPatchError.CreateFmt('Percorso "%s": il segmento "%s" deve indicare l''item fra parentesi quadre.', [Operation.FPath, Segments[i]]);

        Owner := FindItemByName(NestedCollection(Owner, PropertyName), ChildName);
        if Owner = nil then
        begin
          Conflict(Operation, Format('item "%s" non trovato in %s', [ChildName, PropertyName]));
          Exit;
        end;
      end
      else
      begin
        if ChildName <> '' then
          raise EzCollectionPatchError.CreateFmt('Percorso "%s": per "aggiungi" l''ultimo segmento è la collection che riceve l''item, senza parentesi quadre.', [Operation.FPath]);

        TargetCollection := NestedCollection(Owner, PropertyName);
      end;
    end;
  end;

  NewName := StringValue(Operation.FValues, 'Name');

  Existing := FindItemByName(TargetCollection, NewName);
  if Assigned(Existing) then
  begin
    Current := ItemSnapshot(Existing);
    try
      CheckKnownKeys(Operation.FValues, Current, 'valore', Existing);

      if JsonContains(Operation.FValues, Current) then
        Operation.FOutcome := poGiaPresente
      else
        Conflict(Operation, Format('esiste già un item "%s" con valori diversi: %s', [NewName, DescribeDifferences(Operation.FValues, Current)]));
    finally
      Current.Free;
    end;
    Exit;
  end;

  AfterItem := nil;
  if Operation.FAfter <> '' then
  begin
    AfterItem := FindItemByName(TargetCollection, Operation.FAfter);
    if AfterItem = nil then
    begin
      Conflict(Operation, Format('item "%s" indicato in "dopo" non trovato', [Operation.FAfter]));
      Exit;
    end;
  end;

  NewItem := TargetCollection.Add;
  AddUndo(ukRemoveAdded, NewItem, '', nil, -1);
  TzCollectionJson.MergeIntoItem(NewItem, NameFirst(Operation.FValues), StrictOptions);

  // le collection di primo livello ordinate si riordinano da sole
  if Assigned(AfterItem) then
    if not ((TargetCollection is TzCustomCollection) and TzCustomCollection(TargetCollection).Sorted) then
      NewItem.Index := AfterItem.Index + 1;
end;

procedure TPatchRun.RunDelete(Operation: TzPatchOperation);
var
  Target: TCollectionItem;
  Missing: string;
  Current: TJSONObject;
begin
  if not FindTarget(Operation, Target, Missing) then
  begin
    Operation.FOutcome := poGiaPresente;
    Operation.FMessage := Missing + ': già assente';
    Exit;
  end;

  if Assigned(Operation.FExpected) then
  begin
    Current := ItemSnapshot(Target);
    try
      CheckKnownKeys(Operation.FExpected, Current, 'atteso', Target);

      if not JsonContains(Operation.FExpected, Current) then
      begin
        Conflict(Operation, DescribeDifferences(Operation.FExpected, Current));
        Exit;
      end;
    finally
      Current.Free;
    end;
  end;

  // l'item si stacca soltanto: si libera alla conferma, così l'annullamento lo rimette dov'era
  AddUndo(ukReattach, Target, '', Target.Collection, Target.Index);
  Target.Collection := nil;
end;

procedure TPatchRun.Run(Operation: TzPatchOperation);
var
  Mark: Integer;
begin
  Operation.FOutcome := poDaApplicare;
  Operation.FMessage := '';
  Operation.FCollection := nil;

  Mark := FJournal.Count;
  try
    case Operation.FKind of
      pokModifica:
        RunModify(Operation);
      pokAggiungi:
        RunAdd(Operation);
      pokElimina:
        RunDelete(Operation);
    end;
  except
    on E: Exception do
    begin
      // l'operazione può essersi fermata a metà: si annulla quello che ha fatto
      Undo(Mark);
      Operation.FOutcome := poErrore;
      Operation.FMessage := E.Message;
    end;
  end;
end;

procedure TPatchRun.Undo(const FirstEntry: Integer);
var
  i: Integer;
  Entry: TUndoEntry;
  Failures: string;
begin
  Failures := '';

  for i := FJournal.Count - 1 downto FirstEntry do
  begin
    Entry := FJournal[i];
    try
      case Entry.Kind of
        ukRestore:
          TzCollectionJson.MergeIntoItem(Entry.Item, Entry.Snapshot, TJsonSerializerOptions.Default);
        ukRemoveAdded:
          RemoveItem(Entry.Item);
        ukReattach:
          begin
            Entry.Item.Collection := Entry.Owner;
            if Entry.Position < Entry.Owner.Count then
              Entry.Item.Index := Entry.Position;
          end;
      end;
    except
      on E: Exception do
        Failures := Failures + sLineBreak + E.Message;
    end;
    FJournal.Delete(i);
  end;

  if Failures <> '' then
    raise EzCollectionPatchError.Create('Annullamento incompleto: il dizionario in memoria non è affidabile. ' + 'Non salvare e ricaricare le impostazioni.' + Failures);
end;

procedure TPatchRun.Commit;
var
  Entry: TUndoEntry;
begin
  for Entry in FJournal do
    if Entry.Kind = ukReattach then
      Entry.Item.Free;

  FJournal.Clear;
end;

{ TzCollectionPatch }

constructor TzCollectionPatch.Create(const JsonText: string);
var
  Text: string;
  Value: TJSONValue;
begin
  inherited Create;
  FOperations := TObjectList<TzPatchOperation>.Create(True);

  Text := Trim(JsonText);
  if Text.StartsWith(#$FEFF) then
    Delete(Text, 1, 1);

  if Text = '' then
    raise EzCollectionPatchError.Create('Il testo della patch è vuoto.');

  try
    Value := TJSONObject.ParseJSONValue(Text, True, True);
  except
    on E: Exception do
      raise EzCollectionPatchError.Create('Il testo non è un JSON valido: ' + E.Message);
  end;

  if not (Value is TJSONObject) then
  begin
    Value.Free;
    raise EzCollectionPatchError.Create('La patch deve essere un oggetto JSON.');
  end;

  FDocument := TJSONObject(Value);
  ParseDocument;
end;

destructor TzCollectionPatch.Destroy;
begin
  // le operazioni puntano dentro il documento: si liberano prima
  FOperations.Free;
  FDocument.Free;
  inherited;
end;

procedure TzCollectionPatch.ParseDocument;
var
  PatchFormat: string;
  Version: string;
  OperationsValue: TJSONValue;
  i: Integer;
begin
  PatchFormat := StringValue(FDocument, 'formato');
  if not SameText(PatchFormat, zCollectionPatchFormat) then
    raise EzCollectionPatchError.CreateFmt('Formato "%s" non riconosciuto: atteso "%s".', [PatchFormat, zCollectionPatchFormat]);

  Version := StringValue(FDocument, 'versione');
  if Version <> IntToStr(zCollectionPatchVersion) then
    raise EzCollectionPatchError.CreateFmt('Versione "%s" non gestita: atteso %d.', [Version, zCollectionPatchVersion]);

  FApplication := StringValue(FDocument, 'applicazione');
  if FApplication = '' then
    raise EzCollectionPatchError.Create('Manca "applicazione": serve a non applicare a Gesty una patch scritta per un altro programma.');

  FId := StringValue(FDocument, 'id');
  if FId = '' then
    raise EzCollectionPatchError.Create('Manca "id": serve a riconoscere la patch nel registro dell''archivio LZ.');

  FTicket := StringValue(FDocument, 'ticket');
  FDate := StringValue(FDocument, 'data');
  FAuthor := StringValue(FDocument, 'autore');
  FDescription := StringValue(FDocument, 'descrizione');

  OperationsValue := FindValue(FDocument, 'operazioni');
  if not (OperationsValue is TJSONArray) or (TJSONArray(OperationsValue).Count = 0) then
    raise EzCollectionPatchError.Create('"operazioni" deve essere un elenco con almeno un''operazione.');

  for i := 0 to TJSONArray(OperationsValue).Count - 1 do
  begin
    if not (TJSONArray(OperationsValue).Items[i] is TJSONObject) then
      raise EzCollectionPatchError.CreateFmt('Operazione %d: deve essere un oggetto JSON.', [i + 1]);

    ParseOperation(TJSONObject(TJSONArray(OperationsValue).Items[i]), i + 1);
  end;
end;

procedure TzCollectionPatch.ParseOperation(Json: TJSONObject; const Number: Integer);
const
  AllowedKeys: array [0 .. 8] of string = ('op', 'collection', 'item', 'percorso', 'atteso', 'imposta', 'valore', 'dopo', 'nota');
var
  Operation: TzPatchOperation;
  Context: string;
  Pair: TJSONPair;
  KindText: string;
begin
  Context := Format('Operazione %d', [Number]);

  for Pair in Json do
    if IndexText(Pair.JsonString.Value, AllowedKeys) < 0 then
      raise EzCollectionPatchError.CreateFmt('%s: chiave "%s" sconosciuta.', [Context, Pair.JsonString.Value]);

  Operation := TzPatchOperation.Create;
  FOperations.Add(Operation);
  Operation.FNumber := Number;

  KindText := StringValue(Json, 'op');
  if SameText(KindText, 'modifica') then
    Operation.FKind := pokModifica
  else
    if SameText(KindText, 'aggiungi') then
      Operation.FKind := pokAggiungi
    else
      if SameText(KindText, 'elimina') then
        Operation.FKind := pokElimina
      else
        raise EzCollectionPatchError.CreateFmt('%s: "op" deve valere modifica, aggiungi o elimina (trovato "%s").', [Context, KindText]);

  Operation.FCollectionName := StringValue(Json, 'collection');
  if Operation.FCollectionName = '' then
    raise EzCollectionPatchError.CreateFmt('%s: manca "collection".', [Context]);

  Operation.FItemName := StringValue(Json, 'item');
  Operation.FPath := StringValue(Json, 'percorso');
  Operation.FAfter := StringValue(Json, 'dopo');
  Operation.FExpected := ObjectValue(Json, 'atteso', Context);

  if (Operation.FAfter <> '') and (Operation.FKind <> pokAggiungi) then
    raise EzCollectionPatchError.CreateFmt('%s: "dopo" vale solo per aggiungi.', [Context]);

  case Operation.FKind of
    pokModifica:
      begin
        if Operation.FItemName = '' then
          raise EzCollectionPatchError.CreateFmt('%s: manca "item".', [Context]);
        if Assigned(FindValue(Json, 'valore')) then
          raise EzCollectionPatchError.CreateFmt('%s: per modifica si usa "imposta", non "valore".', [Context]);

        Operation.FValues := ObjectValue(Json, 'imposta', Context);
        if not Assigned(Operation.FValues) or (Operation.FValues.Count = 0) then
          raise EzCollectionPatchError.CreateFmt('%s: "imposta" deve elencare almeno una proprietà.', [Context]);
        if Assigned(FindValue(Operation.FValues, 'Name')) then
          raise EzCollectionPatchError.CreateFmt('%s: "Name" non si modifica, le chiavi LZ sono i nomi e i riferimenti resterebbero orfani.', [Context]);
      end;

    pokAggiungi:
      begin
        if Assigned(Operation.FExpected) or Assigned(FindValue(Json, 'imposta')) then
          raise EzCollectionPatchError.CreateFmt('%s: per aggiungi si usa solo "valore".', [Context]);
        if (Operation.FPath = '') and (Operation.FItemName <> '') then
          raise EzCollectionPatchError.CreateFmt('%s: per aggiungere al primo livello non si indica "item"; per una collection annidata serve anche "percorso".', [Context]);
        if (Operation.FPath <> '') and (Operation.FItemName = '') then
          raise EzCollectionPatchError.CreateFmt('%s: con "percorso" serve anche "item", l''item di primo livello da cui partire.', [Context]);

        Operation.FValues := ObjectValue(Json, 'valore', Context);
        if not Assigned(Operation.FValues) or (StringValue(Operation.FValues, 'Name') = '') then
          raise EzCollectionPatchError.CreateFmt('%s: "valore" deve essere un oggetto con "Name".', [Context]);
      end;

    pokElimina:
      begin
        if Operation.FItemName = '' then
          raise EzCollectionPatchError.CreateFmt('%s: manca "item".', [Context]);
        if Assigned(FindValue(Json, 'imposta')) or Assigned(FindValue(Json, 'valore')) then
          raise EzCollectionPatchError.CreateFmt('%s: per elimina non si indicano valori, solo "atteso".', [Context]);
      end;
  end;
end;

procedure TzCollectionPatch.Execute(const Resolver: TzCollectionResolver; const DryRun: Boolean);
var
  PatchRun: TPatchRun;
  Operation: TzPatchOperation;
begin
  PatchRun := TPatchRun.Create(Resolver);
  try
    try
      for Operation in FOperations do
        PatchRun.Run(Operation);
    except
      // errore imprevisto fuori da una singola operazione: si torna indietro
      PatchRun.Undo(0);
      raise;
    end;

    if DryRun or HasProblems then
      PatchRun.Undo(0)
    else
    begin
      PatchRun.Commit;
      for Operation in FOperations do
        if Operation.FOutcome = poDaApplicare then
          Operation.FOutcome := poApplicata;
    end;
  finally
    PatchRun.Free;
  end;
end;

function TzCollectionPatch.Verify(const Resolver: TzCollectionResolver): Boolean;
begin
  Execute(Resolver, True);
  Result := not HasProblems;
end;

procedure TzCollectionPatch.Apply(const Resolver: TzCollectionResolver);
begin
  Execute(Resolver, False);

  if HasProblems then
    raise EzCollectionPatchError.Create('Patch non applicata: nessuna modifica è rimasta nel dizionario.' + sLineBreak + sLineBreak + ProblemsSummary(10));
end;

function TzCollectionPatch.CountOutcome(const Outcome: TzPatchOutcome): Integer;
var
  Operation: TzPatchOperation;
begin
  Result := 0;
  for Operation in FOperations do
    if Operation.FOutcome = Outcome then
      Inc(Result);
end;

function TzCollectionPatch.HasProblems: Boolean;
begin
  Result := (CountOutcome(poConflitto) + CountOutcome(poErrore)) > 0;
end;

function TzCollectionPatch.HasChanges: Boolean;
begin
  Result := (CountOutcome(poDaApplicare) + CountOutcome(poApplicata)) > 0;
end;

function TzCollectionPatch.TouchedCollections: TArray<TzCustomCollection>;
var
  Collections: TList<TzCustomCollection>;
  Operation: TzPatchOperation;
begin
  Collections := TList<TzCustomCollection>.Create;
  try
    for Operation in FOperations do
      if (Operation.FOutcome in [poDaApplicare, poApplicata]) and Assigned(Operation.FCollection) then
        if not Collections.Contains(Operation.FCollection) then
          Collections.Add(Operation.FCollection);

    Result := Collections.ToArray;
  finally
    Collections.Free;
  end;
end;

function TzCollectionPatch.OutcomeText: string;
begin
  Result := Format('%d da applicare, %d applicate, %d già presenti, %d conflitti, %d errori', [CountOutcome(poDaApplicare), CountOutcome(poApplicata), CountOutcome(poGiaPresente), CountOutcome(poConflitto), CountOutcome(poErrore)]);
end;

procedure TzCollectionPatch.AddOperationLines(Lines: TStrings; Operation: TzPatchOperation);
begin
  Lines.Add(Format('%2d. [%s] %s', [Operation.Number, PatchOutcomeText(Operation.Outcome), Operation.Title]));

  if (Operation.Kind = pokModifica) and (Operation.Outcome in [poDaApplicare, poApplicata]) then
    Lines.Add('      proprietà: ' + Operation.PropertyNames);

  if Operation.Message <> '' then
    Lines.Add('      ' + Operation.Message);
end;

procedure TzCollectionPatch.AddProblemLines(Lines: TStrings; const MaxProblems: Integer);
var
  Operation: TzPatchOperation;
  Shown: Integer;
begin
  Shown := 0;

  for Operation in FOperations do
    if Operation.Outcome in [poConflitto, poErrore] then
    begin
      if Shown = MaxProblems then
      begin
        Lines.Add(Format('... e altre %d: vedere il resoconto completo.', [CountOutcome(poConflitto) + CountOutcome(poErrore) - Shown]));
        Exit;
      end;

      AddOperationLines(Lines, Operation);
      Inc(Shown);
    end;
end;

function TzCollectionPatch.ProblemsSummary(const MaxProblems: Integer): string;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddProblemLines(Lines, MaxProblems);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function TzCollectionPatch.Report: string;
var
  Lines: TStringList;
  Operation: TzPatchOperation;
  Heading: string;
begin
  Lines := TStringList.Create;
  try
    Heading := 'Patch ' + FId;
    if FTicket <> '' then
      Heading := Heading + ' - ticket ' + FTicket;
    Lines.Add(Heading);

    if FDescription <> '' then
      Lines.Add(FDescription);

    Lines.Add(Format('Applicazione: %s   Data: %s   Autore: %s', [FApplication, System.StrUtils.IfThen(FDate = '', '-', FDate), System.StrUtils.IfThen(FAuthor = '', '-', FAuthor)]));
    Lines.Add('');

    // l'esito sta in testa: chi apre il resoconto non deve scorrerlo fino in fondo
    // per scoprire che la patch non si applica
    if HasProblems then
    begin
      Lines.Add('ESITO: NON APPLICABILE (' + OutcomeText + ')');
      Lines.Add('');
      Lines.Add('Da correggere:');
      AddProblemLines(Lines, MaxInt);
      Lines.Add('');
      Lines.Add('Tutte le operazioni:');
    end
    else
    begin
      Lines.Add('Esito: ' + OutcomeText + '.');
      Lines.Add('');
    end;

    for Operation in FOperations do
      AddOperationLines(Lines, Operation);

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

end.
