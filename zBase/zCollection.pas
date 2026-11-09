unit zCollection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.JSON.Types,
  System.JSON.Writers,
  System.JSON.Readers,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  AbZipKit,
  cxTL,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl, AbArcTyp, AbUtils;

type
  TzCollectionItem = class;
  TzCollectionItemDynArray = array of TzCollectionItem;
  TJoinOperator = (joIntersect, joComplement, joUnion);
  TNameDuplicates = (ndAllow, ndAutoRename, ndRaiseError);
  TzCollectionLoadErrorEvent = procedure(Sender: TObject; const ErrorMessage: string; var Handled: Boolean; var IgnoreAll: Boolean) of object;
  TzPersistenceFormat = (pfUnknown, pfDFM, pfJSON);

  // Segnalazione di un problema in lettura JSON (proprieta' sconosciuta,
  // valore di tipo inatteso). Handled = True evita l'eccezione anche con
  // StrictJSON attivo.
  TzJsonReadProblemEvent = procedure(Sender: TObject; const Problem: string; var Handled: Boolean) of object;

  // Governa globalmente il formato di persistenza delle TzCustomCollection.
  // Si imposta una sola volta (es. in avvio applicazione); il resto del
  // codice non deve mai passare né scegliere un TzPersistenceFormat per le
  // collection: le API pubbliche di load/save non espongono più il formato.
  TzCollectionPersistenceFlags = record
    DefaultFormat: TzPersistenceFormat; // formato cercato per primo quando esistono sia .dfm che .json
    WriteDFM: Boolean; // se True, il salvataggio produce (anche) il file/stream .dfm
    WriteJSON: Boolean; // se True, il salvataggio produce (anche) il file/stream .json
    StrictJSON: Boolean; // se True, in lettura JSON una proprieta' sconosciuta o un valore non valido sollevano EzJsonReadError (strumenti di verifica)
  end;

  TzCustomCollection = class(TCollection)
  private
    FImageIndex: Integer;
    FLoading: Boolean;
    FMaster: TzCollectionItem;
    FName: string;
    FNameDuplicates: TNameDuplicates;
    FOnChange: TNotifyEvent;
    FOnLoadErrorCallback: TzCollectionLoadErrorEvent;
    FSorted: Boolean;
    procedure SetImageIndex(const Value: Integer);
    procedure SetMaster(const Value: TzCollectionItem);
    procedure SetName(const Value: string);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetSorted(const Value: Boolean);
    procedure JsonReadProblem(Sender: TObject; const Problem: string; var Handled: Boolean);
  protected
    procedure ItemNameChanged(const OldName, NewName: string; const index: Integer); virtual;
  protected
    LoadErrorIgnoreAll: Boolean;
    procedure OnLoadError(Reader: TReader; const Message: string; var Handled: Boolean); virtual;
    procedure DefaultCollectionLoadErrorEvent(Sender: TObject; const ErrorMessage: string; var Handled: Boolean; var IgnoreAll: Boolean);
  protected
    procedure Update(Item: TCollectionItem); override;
    procedure CollectionLoaded; virtual;
    procedure CollectionSaved; virtual;
  protected
    FSorting: Boolean;
    procedure DoSort; virtual;
  public
    constructor Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: Integer; aMaster: TzCollectionItem; const aSorted: Boolean = True); virtual;
    destructor Destroy; override;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    function HasMaster: Boolean;
    function IsEmpty: Boolean;
    function CreateItem: TzCollectionItem; virtual;
    //
    function CanInsert: Boolean; virtual;
    function CanDelete: Boolean; virtual;
    //
    function IndexOf(const Name: string; StartPos: Integer = 0; ExcludeIndex: Integer = -1; UseStartingWith: Boolean = False): Integer; overload; virtual;
    function Join(Detail: TzCustomCollection; JoinOperator: TJoinOperator = joIntersect): TzCollectionItemDynArray;

    procedure FillTreeList(MasterNode: TcxTreeListNode); virtual;
    procedure Sort; virtual;
  private
    procedure LoadFromStreamDFM(Stream: TStream);
    procedure SaveToStreamDFM(Stream: TStream);
    function ResolveWriteFormat: TzPersistenceFormat;
    // Uso interno (TZipper, AsDFM/AsJSON): scrive in UN formato esplicito.
    // Non pubblico: fuori da questa unit il formato non è mai scelto a mano,
    // lo decidono solo i flag di zCollectionPersistence.
    procedure SaveToStreamAs(Stream: TStream; const Format: TzPersistenceFormat);
  public
    procedure LoadFromFile(FileName: string);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(FileName: string);
    procedure SaveToStream(Stream: TStream);
  public
    property Name: string read FName write SetName;
    property Master: TzCollectionItem read FMaster write SetMaster;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property NameDuplicates: TNameDuplicates read FNameDuplicates write FNameDuplicates default ndAllow;
    property Sorted: Boolean read FSorted write SetSorted;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property OnLoadErrorCallback: TzCollectionLoadErrorEvent read FOnLoadErrorCallback write FOnLoadErrorCallback;
  end;

  TzCollectionItem = class(TCollectionItem)
  private
    FName: string;
    FIsEditingProperties: Boolean;
    FIsNew: Boolean;
    procedure SetDetails(const Value: TList<TzCustomCollection>);
  private
    function GetAsDFM: string;
    procedure SetAsDFM(const Value: string);
    procedure OnAncestorNotFound(Reader: TReader; const ComponentName: string; ComponentClass: TPersistentClass; var Component: TComponent);
    procedure OnFindComponentClass(Reader: TReader; const ClassName: string; var ComponentClass: TComponentClass);
    procedure InternalSetName(const Value: string);
    procedure ValidateName(var Value: string);
  protected
    FDetails: TList<TzCustomCollection>;
    procedure SetName(const Value: string); virtual;
    function GetDisplayName: string; override;
    procedure ItemLoaded; virtual;
    procedure ItemSaved; virtual;
    // Agganci per il formato JSON: i valori che nel DFM passano da
    // DefineProperties (invisibili alla RTTI) si scrivono e si leggono qui.
    // WriteJsonExtraProperties: scrive coppie nome/valore aggiuntive nell'oggetto dell'item.
    // ReadJsonExtraProperty: True se ha consumato il valore (il Reader e' sul token del valore;
    // per un valore composto deve consumarlo fino alla chiusura, altrimenti rispondere False).
    // DescribeJsonExtraProperties: scrive nome -> schema nella sezione properties dello schema.
    procedure WriteJsonExtraProperties(Writer: TJsonTextWriter); virtual;
    function ReadJsonExtraProperty(const PropName: string; Reader: TJsonTextReader): Boolean; virtual;
    class procedure DescribeJsonExtraProperties(Schema: TJsonTextWriter); virtual;
    property IsEditingProperties: Boolean read FIsEditingProperties;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    procedure RemoveFromCollection;

    function Inspect: Boolean; // mostra l'editor di proprietà

    function HasChild: Boolean;
    property AsDFM: string read GetAsDFM write SetAsDFM;
    property IsNew: Boolean read FIsNew;
    property Details: TList<TzCustomCollection> read FDetails write SetDetails;
  published
    property Name: string read FName write InternalSetName;
  end;

  TzCollection<T: TzCollectionItem> = class(TzCustomCollection)
  private type
    TCollectionEnumerator = class
    private
      index: Integer;
      Collection: TzCollection<T>;
      function GetCurrent: T;
    public
      constructor Create(ACollection: TzCollection<T>);
      function MoveNext: Boolean;
      property Current: T read GetCurrent;
    end;
  private
    FIndexEnabled: Boolean;
    class function ItemAsGeneric(const Item): T;
    function GetItem(index: Integer): T;
    procedure SetItem(index: Integer; const Value: T);
    procedure CollectionSaved; override;
    procedure SetIndexEnabled(const Value: Boolean);
    function GetAsText: string;
    function GetAsDFM: string;
    function GetAsJSON: string;
    procedure SetAsText(const Value: string);
    procedure SetAsDFM(const Value: string);
    procedure SetAsJSON(const Value: string);
  protected
    indexDict: TDictionary<string, Integer>;
  protected
    procedure DoSort; override;
    function CompareItems(Item1, Item2: TzCollectionItem): Integer; virtual;
  public
    constructor Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: Integer; aMaster: TzCollectionItem; const aSorted: Boolean = True); override;
    destructor Destroy; override;

    function GetEnumerator: TCollectionEnumerator;
  public
    function Add: T;
    function Insert(index: Integer): T;
    function IndexOf(const Name: string; StartPos: Integer = 0; ExcludeIndex: Integer = -1; UseStartingWith: Boolean = False): Integer; overload; override;
    function IndexOf(Item: T): Integer; overload;
    function Exists(const Name: string): Boolean;
    function Get(const Name: string; const CanAppend: Boolean = True): T; overload;
    function Get(const Name: string; StartPos: Integer): T; overload;
    function CreateItem: TzCollectionItem; override;
    function Find(func: TFunc<T, Boolean>): T;

    procedure ForEach(func: TFunc<T, Boolean>);

    property Items[index: Integer]: T read GetItem write SetItem; default;

    procedure ItemNames(Names: TStrings); overload;
    function ItemNames(const Separator: string = ', '): string; overload;

    property AsText: string read GetAsText write SetAsText;
    property AsDFM: string read GetAsDFM write SetAsDFM;
    property AsJSON: string read GetAsJSON write SetAsJSON;
  public
    function GetDuplicates: string;
    procedure DropDuplicates;
  public
    procedure Reindex;
    property IndexEnabled: Boolean read FIndexEnabled write SetIndexEnabled;
  end;

  /// //////////////////////////////////////////////////////////////////////////

  TzPersistent = class(TPersistent)
  public
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  end;

  TzComponentList<T: TComponent> = class(TList<T>)
  private
    FOnChange: TNotifyEvent;
  protected
    procedure Notify(const Item: T; Action: TCollectionNotification); override;
  public
    function IndexOf(const Name: string): Integer;
    function ItemByName(const Name: string): T;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TZipper = class(TObject)
  private
    FZipFileName: string;
    AbZipKit: TAbZipKit;
    procedure ArchiveItemFailure(Sender: TObject; Item: TAbArchiveItem; ProcessType: TAbProcessType; ErrorClass: TAbErrorClass; ErrorCode: Integer);
    function GetPassword: string;
    procedure SetPassword(const Value: string);
    procedure SetZipFileName(const Value: string);
  private
    function GetSaveFileName(Const FileName: string; Const ObjectName: string; const Format: TzPersistenceFormat = pfDFM): string;

    function GetLoadFileName(const FileName: string; Const ObjectName: string; const Format: TzPersistenceFormat = pfUnknown): string;
    function InternalFileExists(Const FileName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    //
    property ZipFileName: string read FZipFileName write SetZipFileName stored False;
    // Password della cifratura zip classica di Abbrevia: i membri aggiunti
    // dopo averla impostata vengono cifrati; in lettura viene usata solo sui
    // membri cifrati, gli altri si estraggono comunque.
    property Password: string read GetPassword write SetPassword;
  public
    function FullFileName(const FileName: string; const Format: TzPersistenceFormat = pfDFM): string;

    function FileExists(Const FileName: string): Boolean;
    procedure GetFileNames(const Folder: string; Files: TStrings; IncludeFilePath: Boolean);
    //
    procedure SaveComponent(Component: TComponent; aFileName: string = '');
    procedure SaveStrings(Strings: TStrings; aFileName: string = '');

    procedure SaveCollection(Collection: TzCustomCollection; aFileName: string = '');

    procedure SavePersistent(Persistent: TzPersistent; aFileName: string = '');
    procedure SaveStream(Stream: TStream; aFileName: string); overload;
    procedure SaveStream(Stream: TStream; aFileName: string; const Format: TzPersistenceFormat); overload;
    procedure RemoveStream(const aFileName: string; const Format: TzPersistenceFormat);
    //
    procedure LoadComponent(Component: TComponent; aFileName: string = '');
    procedure LoadStrings(Strings: TStrings; aFileName: string = '');

    procedure LoadCollection(Collection: TzCustomCollection; aFileName: string = '');
    procedure LoadPersistent(Persistent: TzPersistent; aFileName: string = '');
    procedure LoadStream(Stream: TStream; aFileName: string);

    procedure DeleteFile(const FileName: string);
    // Come DeleteFile, ma col nome esatto del membro (senza cambiare
    // estensione) e solo se esiste: serve per i membri dei vecchi zip
    // salvati senza estensione.
    procedure DeleteMember(const FileName: string);
  end;

var
  // Default: solo DFM, per non alterare il comportamento attuale di chi non
  // configura esplicitamente i flag. Per passare a JSON impostare a startup:
  // zCollectionPersistence := (DefaultFormat: pfJSON; WriteDFM: False; WriteJSON: True);
  zCollectionPersistence: TzCollectionPersistenceFlags = (DefaultFormat: pfDFM; WriteDFM: True; WriteJSON: False; StrictJSON: False);

// Formato con cui scrivere un singolo stream: se sono abilitati entrambi i
// flag decide DefaultFormat; se ne e' abilitato uno solo vince quello;
// nessuno: DFM. Usato da TzCustomCollection e da TzMetadata.
function zResolveWriteFormat: TzPersistenceFormat;

implementation

uses
  AbConst,
  AbBase,
  AbBrowse,
  AbZBrows,
  AbZipper,
  AbZipTyp,
  zCollection.JSON,
  zFrmInspector,

  zMsg;

var
  sizCollection: TSiSession;

const
  StoredExtDFM = '.dfm';
  StoredExtJSON = '.json';

function StoredExtFor(const Format: TzPersistenceFormat): string;
begin
  case Format of
    pfJSON:
      Result := StoredExtJSON;
    pfDFM:
      Result := StoredExtDFM;
    pfUnknown:
      Result := StoredExtDFM;
  else
    Result := StoredExtDFM;
  end;
end;

type
  TProxy = class(TComponent)
  private
    FPersistent: TPersistent;
  published
    property Obj: TPersistent read FPersistent write FPersistent;
  end;

  TzCollectionWrapper = class(TComponent)
  private
    FzCollection: TzCustomCollection;
  published
    property zCollection: TzCustomCollection read FzCollection write FzCollection;
  end;

  TzWrapper = class(TComponent)
  private
    FProps: TzPersistent;
  published
    property Props: TzPersistent read FProps write FProps;
  end;

  /// ////////////////////////////
function TzCollection<T>.Add: T;
var
  Item: TCollectionItem;
begin
  Item := inherited Add;
  Result := ItemAsGeneric(Item);
end;

procedure TzCollection<T>.CollectionSaved;
var
  Item: T;
begin
  inherited;
  for Item in Self do
    Item.ItemSaved;
end;

constructor TzCollection<T>.Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: Integer; aMaster: TzCollectionItem; const aSorted: Boolean);
begin
  inherited;
  indexDict := TDictionary<string, Integer>.Create;
end;

destructor TzCollection<T>.Destroy;
begin
  FreeAndNil(indexDict);
  inherited;
end;

function TzCollection<T>.CompareItems(Item1, Item2: TzCollectionItem): Integer;
begin
  Result := AnsiCompareStr(Item1.Name, Item2.Name);
end;

procedure TzCollection<T>.DropDuplicates;
var
  Elementi: TList<string>;
  Duplicati: TList<Integer>;
  Item: T;
  i, idx: Integer;
begin
  Duplicati := TList<Integer>.Create;
  try
    Elementi := TList<string>.Create;
    try
      for Item in Self do
      begin
        if Elementi.Contains(Item.Name) then
          Duplicati.Add(Item.index)
        else
          Elementi.Add(Item.Name);
      end;

      for i := Duplicati.count - 1 downto 0 do
      begin
        idx := Duplicati[i];
        Self.Delete(idx);
      end;
    finally
      FreeAndNil(Elementi);
    end;
  finally
    FreeAndNil(Duplicati);
  end;
end;

function TzCollection<T>.CreateItem: TzCollectionItem;
begin
  Result := Add;
end;

procedure TzCollection<T>.DoSort;
var
  Arr: TArray<TzCollectionItem>;
  i: Integer;
begin
  if count < 2 then
    exit;

  if FSorting then
    exit;
  FSorting := True;
  try
    // 1. estrai tutte le referenze in un array
    SetLength(Arr, count);
    for i := 0 to count - 1 do
      Arr[i] := TzCollectionItem(Items[i]);

    // 2. ordina l'array (TArray.Sort usa introsort, O(n log n) garantito)
    TArray.Sort<TzCollectionItem>(Arr, TComparer<TzCollectionItem>.Construct(
      function(const A, B: TzCollectionItem): Integer
      begin
        Result := CompareItems(A, B);
      end));

    // 3. riassegna gli indici una sola volta dentro BeginUpdate/EndUpdate
    BeginUpdate;
    try
      for i := 0 to High(Arr) do
        Arr[i].index := i;
    finally
      EndUpdate;
    end;
  finally
    FSorting := False;
  end;
end;

function TzCollection<T>.Exists(const Name: string): Boolean;
begin
  Result := IndexOf(Name) >= 0;
end;

function TzCollection<T>.Find(func: TFunc<T, Boolean>): T;
begin
  for Result in Self do
    if func(Result) then
      exit;

  // se non trovato restituisce nil
  Result := nil;
end;

procedure TzCollection<T>.ForEach(func: TFunc<T, Boolean>);
var
  Item: T;
begin
  assert(assigned(func));

  for Item in Self do
    if not func(Item) then
      exit;
end;

function TzCollection<T>.Get(const Name: string; const CanAppend: Boolean = True): T;
var
  idx: Integer;
  // dummy: TCollectionItem;
begin
  // dummy := nil;
  Result := T(nil);

  if Name.IsEmpty then
    exit;

  idx := IndexOf(Name);

  if idx <> -1 then
    Result := Items[idx]
  else
    if CanAppend then
    begin
      Result := Add;
      Result.Name := Name;
      Result.FIsNew := True;
    end;
end;

function TzCollection<T>.Get(const Name: string; StartPos: Integer): T;
var
  idx: Integer;
  dummy: TCollectionItem;
begin
  dummy := nil;
  Result := ItemAsGeneric(dummy);

  if Name = '' then
    exit;

  idx := IndexOf(Name, StartPos);
  if idx <> -1 then
    Result := Items[idx];
end;

function TzCollection<T>.GetAsDFM: string;
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create('', TEncoding.UTF8);
  try
    SaveToStreamAs(StringStream, pfDFM);
    Result := StringStream.DataString;
  finally
    StringStream.Free;
  end;
end;

function TzCollection<T>.GetAsJSON: string;
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create('', TEncoding.UTF8);
  try
    SaveToStreamAs(StringStream, pfJSON);
    Result := StringStream.DataString;
  finally
    StringStream.Free;
  end;
end;

function TzCollection<T>.GetAsText: string;
var
  Str: TStringList;
  Stream: TMemoryStream;
begin
  Result := '';

  Str := TStringList.Create;
  try
    Stream := TMemoryStream.Create;
    try
      SaveToStream(Stream);
      Stream.Position := 0;
      Str.LoadFromStream(Stream);
      Result := Str.Text;
    finally
      FreeAndNil(Stream);
    end;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzCollection<T>.SetAsJSON(const Value: string);
var
  StringStream: TStringStream;
begin
  if Value = '' then
  begin
    Clear;
    exit;
  end;

  StringStream := TStringStream.Create(Value, TEncoding.UTF8);
  try
    StringStream.Position := 0;
    LoadFromStream(StringStream); // auto-detect, riconoscera' JSON
  finally
    StringStream.Free;
  end;
end;

procedure TzCollection<T>.SetAsDFM(const Value: string);
var
  StringStream: TStringStream;
begin
  if Value = '' then
  begin
    Clear;
    exit;
  end;

  StringStream := TStringStream.Create(Value, TEncoding.UTF8);
  try
    StringStream.Position := 0;
    LoadFromStream(StringStream); // auto-detect, riconoscera' DFM
  finally
    StringStream.Free;
  end;
end;

function TzCollection<T>.GetDuplicates: string;
var
  Dictionary: TDictionary<string, Integer>;
  Item: T;
  cnt: Integer;
  pair: TPair<string, Integer>;
begin
  Result := '';

  Dictionary := TDictionary<string, Integer>.Create;
  try
    for Item in Self do
      if Dictionary.ContainsKey(Item.Name) then
        Dictionary[Item.Name] := Dictionary[Item.Name] + 1
      else
        Dictionary.Add(Item.Name, 1);

    for pair in Dictionary do
      if pair.Value > 1 then
      begin
        if not Result.IsEmpty then
          Result := Result + sLineBreak;

        if pair.Value > 2 then
          Result := Result + pair.Key + ' (' + pair.Value.ToString + ')'
        else
          Result := Result + pair.Key;
      end;
  finally
    FreeAndNil(Dictionary);
  end;
end;

function TzCollection<T>.GetEnumerator: TCollectionEnumerator;
begin
  Result := TCollectionEnumerator.Create(Self);
end;

function TzCollection<T>.GetItem(index: Integer): T;

var
  Item: TCollectionItem;
begin
  Item := inherited Items[index];
  Result := ItemAsGeneric(Item);
end;

function TzCollection<T>.Insert(index: Integer): T;
var
  Item: TCollectionItem;
begin
  Item := inherited Insert(index);
  Result := ItemAsGeneric(Item);
end;

class function TzCollection<T>.ItemAsGeneric(const Item): T;
begin
  Result := T(Item);
end;

function TzCollection<T>.ItemNames(const Separator: string): string;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to count - 1 do
  begin
    Result := Result + Items[i].Name;

    if i < count - 1 then
      Result := Result + Separator;
  end;
end;

procedure TzCollection<T>.ItemNames(Names: TStrings);
var
  i: Integer;
  Item: T;
begin
  if not assigned(Names) then
    exit;

  Names.Clear;
  for i := 0 to count - 1 do
    Names.Add(Items[i].Name);
end;

procedure TzCollection<T>.SetAsText(const Value: string);
var
  Str: TStringList;
  Stream: TMemoryStream;
begin
  if Value = '' then
  begin
    Clear;
    exit;
  end;

  Str := TStringList.Create;
  try
    Stream := TMemoryStream.Create;
    try
      Str.Text := Value;
      Str.SaveToStream(Stream);
      Stream.Position := 0;
      LoadFromStream(Stream);
    finally
      FreeAndNil(Stream);
    end;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzCollection<T>.SetItem(index: Integer; const Value: T);
begin
  Items[index].Assign(Value);
end;

function TzCollection<T>.IndexOf(const Name: string; StartPos: Integer = 0; ExcludeIndex: Integer = -1; UseStartingWith: Boolean = False): Integer;
var
  found: Boolean;
  i: Integer;
begin
  // inherited;
  // sizCollection.LogString('IndexOf', ClassName);

  Result := -1;

  if Name = '' then
    exit;

  if IndexEnabled then
  begin

    if not indexDict.TryGetValue(Name, Result) then
      Result := -1;
  end
  else
  begin
    for i := StartPos to count - 1 do
    begin

      if UseStartingWith then
        found := Items[i].Name.StartsWith(Name, True)
      else
        // found := SameText(Items[i].Name, Name); ottimizzazione
        found := AnsiCompareText(Items[i].Name, Name) = 0;

      if found then
        if i <> ExcludeIndex then
        begin
          Result := i;
          Break;
        end;
    end;
  end;
end;

function TzCollection<T>.IndexOf(Item: T): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to count - 1 do
    if Items[i] = Item then
      exit(i);
end;

procedure TzCollection<T>.Reindex;
var
  Item: T;
begin
  indexDict.Clear;

  for Item in Self do
    if not indexDict.ContainsKey(Item.Name) then
      indexDict.Add(Item.Name, Item.index);
end;

procedure TzCollection<T>.SetIndexEnabled(const Value: Boolean);
begin
  FIndexEnabled := Value;

  if IndexEnabled then
    Reindex
  else
    indexDict.Clear;
end;

{ TzCollection<T>.TCollectionEnumerator }

constructor TzCollection<T>.TCollectionEnumerator.Create(ACollection: TzCollection<T>);
begin
  inherited Create;
  index := -1;
  Collection := ACollection;
end;

function TzCollection<T>.TCollectionEnumerator.GetCurrent: T;
begin
  Result := Collection.Items[index];
end;

function TzCollection<T>.TCollectionEnumerator.MoveNext: Boolean;
begin
  Result := index < Collection.count - 1;
  if Result then
    Inc(index);
end;

procedure TzCollectionItem.Assign(Source: TPersistent);
begin
  if Source is ClassType then
  begin
    Self.Name := TzCollectionItem(Source).Name;
    Self.FIsNew := TzCollectionItem(Source).IsNew;
  end
  else
    inherited Assign(Source);
end;

constructor TzCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  FIsEditingProperties := False;
  FName := '';
  FIsNew := False;
  FDetails := TList<TzCustomCollection>.Create;
end;

destructor TzCollectionItem.Destroy;
var
  Detail: TzCustomCollection;
begin

  if assigned(FDetails) then
  begin
    for Detail in FDetails do
      if Detail.FMaster = Self then
        Detail.FMaster := nil;
    FreeAndNil(FDetails);
  end;

  inherited;
end;

function TzCollectionItem.GetAsDFM: string;
var
  Proxy: TProxy;
  StringStream: TStringStream;
  TempStream: TMemoryStream;
begin
  Result := '';

  Proxy := TProxy.Create(nil);
  try
    Proxy.Obj := Self;

    StringStream := TStringStream.Create;
    try
      TempStream := TMemoryStream.Create;
      try
        TempStream.WriteComponent(Proxy);
        TempStream.Seek(0, SoFromBeginning);
        ObjectBinaryToText(TempStream, StringStream);
        StringStream.Seek(0, SoFromBeginning);
        Result := StringStream.DataString;
      finally
        TempStream.Free;
      end;
    finally
      StringStream.Free;
    end;
  finally
    FreeAndNil(Proxy);
  end;
end;

function TzCollectionItem.GetDisplayName: string;
begin
  Result := Name;
end;

function TzCollectionItem.HasChild: Boolean;
begin
  Result := False;
  if assigned(FDetails) then
    Result := Details.count > 0;
end;

function TzCollectionItem.Inspect: Boolean;
begin
  FIsEditingProperties := True;
  try
    Result := zEditProperties([Self]);
  finally
    FIsEditingProperties := False;
  end;
end;

procedure TzCollectionItem.SetDetails(const Value: TList<TzCustomCollection>);
var
  SubCollection: TzCustomCollection;
begin
  FDetails.Clear;
  if assigned(Value) then

    for SubCollection in Value do
      Details.Add(SubCollection)
end;

procedure TzCollectionItem.SetName(const Value: string);
var
  OldName: string;
begin
  if FName <> Value then
  begin
    OldName := FName;
    FName := Value;

    if assigned(Collection) then
      if Collection is TzCustomCollection then
        TzCustomCollection(Collection).ItemNameChanged(OldName, FName, index);
  end;
end;

procedure TzCollectionItem.InternalSetName(const Value: string);
var
  NewName: string;
begin
  NewName := Value;
  ValidateName(NewName);
  SetName(NewName);
end;

procedure TzCollectionItem.ItemLoaded;
begin
  FIsNew := False;
end;

procedure TzCollectionItem.ItemSaved;
begin
  FIsNew := False;
end;

procedure TzCollectionItem.WriteJsonExtraProperties(Writer: TJsonTextWriter);
begin
  // nessun valore aggiuntivo nella classe base
end;

function TzCollectionItem.ReadJsonExtraProperty(const PropName: string; Reader: TJsonTextReader): Boolean;
begin
  Result := False;
end;

class procedure TzCollectionItem.DescribeJsonExtraProperties(Schema: TJsonTextWriter);
begin
  // nessun valore aggiuntivo nella classe base
end;

procedure TzCollectionItem.OnAncestorNotFound(Reader: TReader; const ComponentName: string; ComponentClass: TPersistentClass; var Component: TComponent);
begin
  Component := nil;
end;

procedure TzCollectionItem.OnFindComponentClass(Reader: TReader; const ClassName: string; var ComponentClass: TComponentClass);
begin
  // Per i TCollectionItem, Delphi cerca le classi registrate
  // Ma in questo contesto non funziona, quindi non facciamo nulla
  // Il reader userà la classe definita nella TCollection.ItemClass
  ComponentClass := nil;
end;

procedure TzCollectionItem.RemoveFromCollection;
var
  idx: Integer;
begin
  // 14.05.2026: Era solamente Self.Free;

  if Collection <> nil then
  begin
    idx := Self.index;
    // Delete passa per Notify ed eventi della collection, e libera
    // l'item correttamente. Niente Self.Free diretto.
    Collection.Delete(idx);
  end
  else
    Self.Free; // item orfano: nessuna collection, libera direttamente
end;

procedure TzCollectionItem.SetAsDFM(const Value: string);
var
  Proxy: TProxy;
  StringStream: TStringStream;
  BinStream: TMemoryStream;
  Reader: TReader;
begin

  Proxy := TProxy.Create(nil);
  try
    Proxy.Obj := Self;

    StringStream := TStringStream.Create(Value);
    try
      BinStream := TMemoryStream.Create;
      try
        ObjectTextToBinary(StringStream, BinStream);
        BinStream.Position := 0;

        Reader := TReader.Create(BinStream, 4096);
        try
          Reader.Root := Proxy;
          // Reader.OnAncestorNotFound := OnAncestorNotFound;
          // Reader.OnFindComponentClass := OnFindComponentClass;
          // LoadErrorIgnoreAll := False;
          // Reader.OnError := OnLoadError;
          // reader.OnFindComponentClass(Reader, ClassName, ...);
          // OnAncestorNotFound

          Reader.ReadRootComponent(Proxy);
        finally
          Reader.Free;
        end;
      finally
        BinStream.Free;
      end;
    finally
      StringStream.Free;
    end;
  finally
    FreeAndNil(Proxy);
  end;
end;

procedure TzCollectionItem.ValidateName(var Value: string);
var
  i: Integer;
  zCollection: TzCollection<TzCollectionItem>;
begin
  // zCollection := TzCollection<TzCollectionItem>(Collection);
  //
  // if not Assigned(zCollection) then
  // Exit;
  //
  // case zCollection.NameDuplicates of
  // ndAllow:
  // Exit;
  // ndAutoRename:
  // begin
  // // se esiste un altro con lo stesso nome
  // if zCollection.IndexOf(Value, Index) = -1 then
  // Exit;
  //
  // i := 1;
  //
  // while zCollection.IndexOf(Value + '_' + IntToStr(i)) <> -1 do
  // Inc(i);
  //
  // Value := Value + '_' + IntToStr(i);
  // // ciclo for sino a quando si trova un nome non esistente => nuovo nome
  //
  // end;
  // ndRaiseError:
  // begin
  // // verificare se esiste un altro item con lo stesso nome, se si => eccezione
  // if zCollection.IndexOf(Value, Index) = -1 then
  // raise exception.Create('Nome duplicato: ' + Value);
  // end;
  // end;
end;

constructor TzCustomCollection.Create(ItemClass: TCollectionItemClass; const aName: string; aImageIndex: Integer; aMaster: TzCollectionItem; const aSorted: Boolean = True);
begin
  inherited Create(ItemClass);
  // FSorted := False; //ZZ 29.04.2017
  FLoading := False;
  FSorted := aSorted; // ZZ 09.05.2017 da fare solo sui domini
  FSorting := False;
  FNameDuplicates := ndAllow;
  LoadErrorIgnoreAll := False;
  Name := aName;
  ImageIndex := aImageIndex;
  FOnLoadErrorCallback := DefaultCollectionLoadErrorEvent;

  Master := aMaster; // assegna a detail
end;

destructor TzCustomCollection.Destroy;
begin
  // Se ha un master, rimuove dalla sua lista Details
  if assigned(FMaster) and assigned(FMaster.FDetails) then
    FMaster.FDetails.Remove(Self);

  inherited;
end;

function TzCustomCollection.CanDelete: Boolean;
begin
  Result := True;
end;

function TzCustomCollection.CanInsert: Boolean;
begin
  Result := True;
end;

procedure TzCustomCollection.CollectionLoaded;
begin
end;

procedure TzCustomCollection.JsonReadProblem(Sender: TObject; const Problem: string; var Handled: Boolean);
begin
  // Registra il problema; con StrictJSON attivo il serializzatore solleva
  // comunque l'eccezione (Handled resta False).
  sizCollection.LogWarning('JSON ' + Problem);
  Handled := False;
end;

procedure TzCustomCollection.CollectionSaved;
begin;
end;

function TzCustomCollection.CreateItem: TzCollectionItem;
begin
  Result := nil;
end;

procedure TzCustomCollection.DefaultCollectionLoadErrorEvent(Sender: TObject; const ErrorMessage: string; var Handled: Boolean; var IgnoreAll: Boolean);
begin
  case Confirm('Errore leggendo la collezione: ' + Name + #13 + ErrorMessage, [mbCancel, mbIgnore, mbAll], mtWarning) of
    mrIgnore:
      Handled := True;
    mrAll:
      begin
        Handled := True;
        IgnoreAll := True;
      end;
    mrCancel:
      Handled := False;
  end;
end;

procedure TzCustomCollection.DoSort;
begin
  // ridefinita in TzCollection
end;

procedure TzCustomCollection.FillTreeList(MasterNode: TcxTreeListNode);

  procedure Add(MasterNode: TcxTreeListNode; zCollection: TzCustomCollection);
  var
    i, x: Integer;
    ImageIndex: Integer;
    Node, Child: TcxTreeListNode;
    Item: TzCollectionItem;
  begin
    Node := MasterNode.AddChild;
    Node.Values[0] := zCollection.Name;
    Node.Data := zCollection;
    ImageIndex := zCollection.ImageIndex;
    Node.ImageIndex := ImageIndex;
    Node.SelectedIndex := ImageIndex;

    for i := 0 to zCollection.count - 1 do
    begin
      Item := TzCollectionItem(zCollection.Items[i]);
      Child := Node.AddChild;
      Child.Values[0] := Item.Name;
      Child.Data := Item;
      Child.ImageIndex := ImageIndex;
      Child.SelectedIndex := ImageIndex;

      for x := 0 to Item.Details.count - 1 do
        Add(Child, Item.Details[x]);
    end;
  end;

begin
  MasterNode.TreeList.BeginUpdate;
  try
    Add(MasterNode, Self);
  finally
    MasterNode.TreeList.EndUpdate;
  end;
end;

function TzCustomCollection.Join(Detail: TzCustomCollection; JoinOperator: TJoinOperator = joIntersect): TzCollectionItemDynArray;
var
  i: Integer;
  Item: TzCollectionItem;
  resultArray: TzCollectionItemDynArray;
  ok: Boolean;
begin
  SetLength(resultArray, 0);

  for i := 0 to count - 1 do
  begin
    ok := False;

    Item := TzCollectionItem(Items[i]);

    case JoinOperator of
      joIntersect:
        ok := Detail.IndexOf(Item.Name) <> -1;
      joComplement:
        ok := Detail.IndexOf(Item.Name) = -1;
      joUnion:
        ok := True;
    end;

    if ok then
    begin
      SetLength(resultArray, Length(resultArray) + 1);
      resultArray[Length(resultArray) - 1] := Item;
    end;
  end;
  /// //////////////////////////////////

  if JoinOperator = joUnion then
    for i := 0 to Detail.count - 1 do
    begin
      SetLength(resultArray, Length(resultArray) + 1);
      resultArray[Length(resultArray) - 1] := TzCollectionItem(Detail.Items[i])
    end;

  /// //////////////////////////////////
  Result := resultArray;
end;

function TzCustomCollection.HasMaster: Boolean;
begin
  Result := assigned(FMaster);
end;

function TzCustomCollection.IndexOf(const Name: string; StartPos: Integer = 0; ExcludeIndex: Integer = -1; UseStartingWith: Boolean = False): Integer;
begin
  Result := -1;
end;

function TzCustomCollection.IsEmpty: Boolean;
begin
  Result := count = 0;
end;

procedure TzCustomCollection.ItemNameChanged(const OldName, NewName: string; const index: Integer);
begin
  // usata nei discendenti
end;

procedure TzCustomCollection.LoadFromFile(FileName: string);
var
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, FmOpenRead);
  try
    LoadFromStream(s);
  finally
    s.Free;
  end;
end;

{ TzCustomCollection }

procedure TzCustomCollection.LoadFromStream(Stream: TStream);
var
  Format: TzPersistenceFormat;
  Options: TJsonSerializerOptions;
begin
  sizCollection.EnterMethod(Self, 'TzCustomCollection.LoadFromStream');

  if not assigned(Stream) then
    exit;

  if Stream.Size = 0 then
    exit;

  Format := TzCollectionJson.DetectFormat(Stream);

  if Format = pfJSON then
  begin
    Options := TJsonSerializerOptions.Default;
    Options.StrictMode := zCollectionPersistence.StrictJSON;
    Options.OnReadProblem := JsonReadProblem;
    TzCollectionJson.LoadFromStream(Self, Stream, Options);
  end
  else
    // tutto il body originale (DFM via TReader/Wrapper)
    LoadFromStreamDFM(Stream);

  CollectionLoaded;

  sizCollection.LeaveMethod(Self, 'TzCustomCollection.LoadFromStream');
end;

procedure TzCustomCollection.LoadFromStreamDFM(Stream: TStream);
var
  Wrapper: TzCollectionWrapper;
  MemStream: TMemoryStream;
  Reader: TReader;
begin

  if not assigned(Stream) then
    exit;

  if Stream.Size = 0 then
    exit;

  sizCollection.EnterMethod(Self, 'TzCustomCollection.LoadFromStreamDFM');

  BeginUpdate; // per sort
  try
    MemStream := TMemoryStream.Create;
    try
      Wrapper := TzCollectionWrapper.Create(nil);
      try
        ObjectTextToBinary(Stream, MemStream);
        MemStream.Seek(0, SoFromBeginning);
        Wrapper.zCollection := Self;
        //
        Reader := TReader.Create(MemStream, 4096);
        try
          LoadErrorIgnoreAll := False;
          Reader.OnError := OnLoadError;
          Reader.ReadRootComponent(Wrapper);
        finally
          Reader.Free;
        end;
      finally
        Wrapper.Free;
      end;
    finally
      MemStream.Free;
    end;
  finally
    EndUpdate;
  end;

  sizCollection.LeaveMethod(Self, 'TzCustomCollection.LoadFromStreamDFM');
end;

procedure TzCustomCollection.Move(CurIndex, NewIndex: Integer);
begin
  Items[CurIndex].index := NewIndex;
end;

procedure TzCustomCollection.OnLoadError(Reader: TReader; const Message: string; var Handled: Boolean);
var
  IgnoreAll: Boolean;
begin

  if LoadErrorIgnoreAll then
  begin
    Handled := True;
    exit;
  end;

  if assigned(FOnLoadErrorCallback) then
  begin
    IgnoreAll := False;
    FOnLoadErrorCallback(Self, Message, Handled, IgnoreAll);

    if IgnoreAll then
      LoadErrorIgnoreAll := True;
  end
  else
  begin
    // Comportamento di default: non gestito, lascia propagare.
    // E' il chiamante (TZipper o UI) a decidere se mostrare dialog.
    Handled := False;
  end;
end;

procedure TzCustomCollection.SaveToFile(FileName: string);
var
  s: TStream;
begin
  s := TFileStream.Create(FileName, FmCreate);
  try
    SaveToStream(s);
  finally
    s.Free;
  end;
end;

function zResolveWriteFormat: TzPersistenceFormat;
begin
  if zCollectionPersistence.WriteJSON and zCollectionPersistence.WriteDFM then
  begin
    if zCollectionPersistence.DefaultFormat = pfJSON then
      Result := pfJSON
    else
      Result := pfDFM;
  end
  else
    if zCollectionPersistence.WriteJSON then
      Result := pfJSON
    else
      Result := pfDFM;
end;

function TzCustomCollection.ResolveWriteFormat: TzPersistenceFormat;
begin
  Result := zResolveWriteFormat;
end;

procedure TzCustomCollection.SaveToStreamAs(Stream: TStream; const Format: TzPersistenceFormat);
begin
  if not assigned(Stream) then
    exit;

  case Format of
    pfJSON:
      TzCollectionJson.SaveToStream(Self, Stream);
  else
    SaveToStreamDFM(Stream);
  end;
end;

procedure TzCustomCollection.SaveToStream(Stream: TStream);
begin
  sizCollection.EnterMethod(Self, 'TzCustomCollection.SaveToStream');

  if assigned(Stream) then
  begin
    SaveToStreamAs(Stream, ResolveWriteFormat);
    CollectionSaved;
  end;

  sizCollection.LeaveMethod(Self, 'TzCustomCollection.SaveToStream');
end;

procedure TzCustomCollection.SaveToStreamDFM(Stream: TStream);
var
  Wrapper: TzCollectionWrapper;
  MemStream: TMemoryStream;
begin
  if not assigned(Stream) then
    exit;

  sizCollection.EnterMethod(Self, 'TzCustomCollection.SaveToStreamDFM');

  MemStream := TMemoryStream.Create;
  try
    Wrapper := TzCollectionWrapper.Create(nil);
    try
      Wrapper.zCollection := Self;
      MemStream.WriteComponent(Wrapper);
      MemStream.Seek(0, SoFromBeginning);
      ObjectBinaryToText(MemStream, Stream);
    finally
      Wrapper.Free;
    end;
  finally
    MemStream.Free;
  end;

  sizCollection.LeaveMethod(Self, 'TzCustomCollection.SaveToStreamDFM');
end;

procedure TzCustomCollection.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
end;

procedure TzCustomCollection.SetMaster(const Value: TzCollectionItem);
begin
  if FMaster = Value then
    exit;

  // Rimuovi dal vecchio Master
  if assigned(FMaster) and assigned(FMaster.FDetails) then
    FMaster.FDetails.Remove(Self);

  FMaster := Value;

  // Aggiungi al nuovo Master
  if assigned(FMaster) then
    FMaster.FDetails.Add(Self);
end;

procedure TzCustomCollection.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TzCustomCollection.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TzCustomCollection.SetSorted(const Value: Boolean);
begin
  FSorted := Value;

  if Sorted then
    Sort;
end;

procedure TzCustomCollection.Sort;
begin

  if Sorted then
    DoSort;
end;

procedure TzCustomCollection.Update(Item: TCollectionItem);
begin
  inherited;

  if Sorted and not FSorting then
    Sort;

  if assigned(FOnChange) then
    OnChange(Self);
end;

{ TzPersistent }

procedure TzPersistent.SaveToStream(Stream: TStream);
var
  Wrapper: TzWrapper;
  MemStream: TMemoryStream;
begin
  // ==============================================================================
  // BASEX
  // ==============================================================================
  // EXIT;

  if not assigned(Stream) then
    exit;

  MemStream := TMemoryStream.Create;
  try
    Wrapper := TzWrapper.Create(nil);
    try
      Wrapper.Props := Self;
      MemStream.WriteComponent(Wrapper);
      MemStream.Seek(0, SoFromBeginning);
      ObjectBinaryToText(MemStream, Stream);
    finally
      Wrapper.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

procedure TzPersistent.LoadFromStream(Stream: TStream);
var
  Wrapper: TzWrapper;
  MemStream: TMemoryStream;
begin
  // ==============================================================================
  // BASEX
  // ==============================================================================
  // EXIT;

  if not assigned(Stream) then
    exit;

  MemStream := TMemoryStream.Create;
  try
    Wrapper := TzWrapper.Create(nil);
    try
      ObjectTextToBinary(Stream, MemStream);
      MemStream.Seek(0, SoFromBeginning);
      Wrapper.Props := Self;
      MemStream.ReadComponent(Wrapper);
    finally
      Wrapper.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

function TzComponentList<T>.IndexOf(const Name: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to count - 1 do
    if AnsiCompareText(Items[i].Name, Name) = 0 then
      // if SameText(Items[i].Name, Name) then ottimizzazione
      exit(i);
end;

procedure TzComponentList<T>.Notify(const Item: T; Action: TCollectionNotification);
begin
  inherited;
  if assigned(FOnChange) then
    FOnChange(Self);
end;

function TzComponentList<T>.ItemByName(const Name: string): T;
var
  idx: Integer;
begin
  idx := IndexOf(Name);
  if idx <> -1 then
    Result := Items[idx];
end;

constructor TZipper.Create;
begin
  inherited Create;
  FZipFileName := '';
  AbZipKit := TAbZipKit.Create(nil);
  AbZipKit.Name := 'AbZipKit';
  AbZipKit.AutoSave := False;
  // AbZipKit.DeflationOption := doSuperFast;
  AbZipKit.DeflationOption := doNormal;
  AbZipKit.DOSMode := False;
  AbZipKit.ExtractOptions := [];
  AbZipKit.ForceType := True;
  AbZipKit.ArchiveType := atZip;
  // Senza questo gestore Abbrevia ingoia l'errore di estrazione (password
  // mancante o sbagliata, membro corrotto) e restituisce uno stream vuoto:
  // la collezione resta vuota senza che nessuno se ne accorga. Verificato
  // il 2026-10-01 in SandBox\zProvaCifraturaSec.
  AbZipKit.OnProcessItemFailure := ArchiveItemFailure;
end;

procedure TZipper.DeleteFile(const FileName: string);
begin
  AbZipKit.DeleteFiles(FileName);
end;

procedure TZipper.ArchiveItemFailure(Sender: TObject; Item: TAbArchiveItem; ProcessType: TAbProcessType; ErrorClass: TAbErrorClass; ErrorCode: Integer);
var
  Operazione: string;
  Dettaglio: string;
begin
  case ProcessType of
    ptAdd:
      Operazione := 'Scrittura';
    ptExtract:
      Operazione := 'Lettura';
  else
    Operazione := 'Elaborazione';
  end;

  if ErrorClass = ecAbbrevia then
    Dettaglio := AbStrRes(ErrorCode)
  else
    Dettaglio := Format('classe di errore %d, codice %d', [Ord(ErrorClass), ErrorCode]);

  raise Exception.CreateFmt('%s di %s in %s fallita: %s', [Operazione, Item.FileName, ExtractFileName(ZipFileName), Dettaglio]);
end;

procedure TZipper.DeleteMember(const FileName: string);
begin
  if InternalFileExists(FileName) then
    AbZipKit.DeleteFiles(FileName);
end;

function TZipper.GetPassword: string;
begin
  Result := AbZipKit.Password;
end;

procedure TZipper.SetPassword(const Value: string);
begin
  // TAbZipKit la passa all'archivio sia se e' gia' aperto sia quando lo
  // apre dopo (InitArchive), quindi l'ordine rispetto a ZipFileName non conta.
  AbZipKit.Password := Value;
end;

destructor TZipper.Destroy;
begin
  AbZipKit.CloseArchive;
  AbZipKit.FileName := '';
  FreeAndNil(AbZipKit);
  inherited;
end;

function TZipper.FullFileName(const FileName: string; const Format: TzPersistenceFormat): string;
begin
  Result := ChangeFileExt(FileName, StoredExtFor(Format));
end;

procedure TZipper.GetFileNames(const Folder: string; Files: TStrings; IncludeFilePath: Boolean);
var
  i: Integer;
  Item: TAbArchiveItem;
  StoredPath: string;
begin
  assert(assigned(Files));

  Files.Clear;

  StoredPath := Folder;
  if StoredPath <> '' then
    StoredPath := IncludeTrailingBackslash(StoredPath);

  Files.BeginUpdate;
  try
    for i := 0 to AbZipKit.count - 1 do
      if AbZipKit.Items[i].MatchesStoredName(StoredPath + '*' + StoredExtDFM) or AbZipKit.Items[i].MatchesStoredName(StoredPath + '*' + StoredExtJSON) then
        if not AbZipKit.Items[i].IsDirectory then
        begin
          Item := AbZipKit.Items[i];

          if IncludeFilePath then
            Files.Add(Item.FileName)
          else
            Files.Add(ChangeFileExt(ExtractFileName(StringReplace(Item.FileName, '/', '\', [RfReplaceAll])), ''));
        end;
  finally
    Files.EndUpdate;
  end;
end;

function TZipper.GetLoadFileName(const FileName: string; Const ObjectName: string; const Format: TzPersistenceFormat = pfUnknown): string;
var
  Base: string;
  Candidate: string;
begin
  if FileName.IsEmpty then
    Base := ObjectName
  else
    Base := FileName;

  case Format of
    pfJSON:
      begin
        // Forza JSON: cerca SOLO il .json
        Candidate := ChangeFileExt(Base, StoredExtJSON);
        if InternalFileExists(Candidate) then
          exit(Candidate);
        exit('');
      end;

    pfDFM:
      begin
        // Forza DFM: cerca .dfm, poi senza estensione (compat vecchi zip)
        Candidate := ChangeFileExt(Base, StoredExtDFM);
        if InternalFileExists(Candidate) then
          exit(Candidate);

        Candidate := ChangeFileExt(Base, '');
        if InternalFileExists(Candidate) then
          exit(Candidate);

        exit('');
      end;

    pfUnknown:
      begin
        // Scelta automatica quando esistono sia .dfm che .json: l'ordine di
        // ricerca segue zCollectionPersistence.DefaultFormat (unica fonte
        // di verità globale), poi fallback sull'altro formato, poi sul file
        // senza estensione (compat vecchi zip).
        if zCollectionPersistence.DefaultFormat = pfDFM then
        begin
          Candidate := ChangeFileExt(Base, StoredExtDFM);
          if InternalFileExists(Candidate) then
            exit(Candidate);

          Candidate := ChangeFileExt(Base, StoredExtJSON);
          if InternalFileExists(Candidate) then
            exit(Candidate);
        end
        else
        begin
          Candidate := ChangeFileExt(Base, StoredExtJSON);
          if InternalFileExists(Candidate) then
            exit(Candidate);

          Candidate := ChangeFileExt(Base, StoredExtDFM);
          if InternalFileExists(Candidate) then
            exit(Candidate);
        end;

        Candidate := ChangeFileExt(Base, '');
        if InternalFileExists(Candidate) then
          exit(Candidate);

        Result := '';
      end;
  end;
end;

function TZipper.GetSaveFileName(Const FileName: string; Const ObjectName: string; const Format: TzPersistenceFormat = pfDFM): string;
begin
  if FileName.IsEmpty then
    Result := ObjectName
  else
    Result := FileName;

  Result := FullFileName(Result, Format);
end;

function TZipper.InternalFileExists(const FileName: string): Boolean;
begin
  Result := (AbZipKit.count > 0) and (AbZipKit.FindFile(FileName) > -1);
end;

function TZipper.FileExists(Const FileName: string): Boolean;
begin
  Result := InternalFileExists(FullFileName(FileName));
end;

procedure TZipper.LoadCollection(Collection: TzCustomCollection; aFileName: string = '');
var
  Stream: TMemoryStream;
  FileName: string;
begin
  try
    // Nessun formato scelto dal chiamante: GetLoadFileName usa pfUnknown,
    // che a sua volta segue zCollectionPersistence.DefaultFormat.
    FileName := GetLoadFileName(aFileName, Collection.ClassName);

    if not InternalFileExists(FileName) then
      exit;

    Stream := TMemoryStream.Create;
    try
      AbZipKit.ExtractToStream(FileName, Stream);
      Stream.Position := 0;
      try
        Collection.LoadFromStream(Stream);
      except
        on e: exception do
          ApplicationShowException(e);
      end;
    finally
      Stream.Free;
    end;

  except
    on e: exception do
    begin
      ConfirmOk(e.Message);
      raise;
    end;
  end;
end;

procedure TZipper.LoadComponent(Component: TComponent; aFileName: string = '');
var
  Stream: TMemoryStream;
  TempStream: TMemoryStream;
  FileName: string;
begin
  FileName := GetLoadFileName(aFileName, Component.ClassName);

  if not InternalFileExists(FileName) then
    exit;

  Stream := TMemoryStream.Create;
  try
    AbZipKit.ExtractToStream(FileName, Stream);
    Stream.Position := 0;
    try

      TempStream := TMemoryStream.Create;
      try
        ObjectTextToBinary(Stream, TempStream);
        TempStream.Seek(0, SoFromBeginning);
        TempStream.ReadComponent(Component);
      finally
        TempStream.Free;
      end;

    except
      on e: exception do
        ApplicationShowException(e);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TZipper.LoadPersistent(Persistent: TzPersistent; aFileName: string = '');
var
  Stream: TMemoryStream;
  FileName: string;
begin
  FileName := GetLoadFileName(aFileName, Persistent.ClassName);

  if not InternalFileExists(FileName) then
    exit;

  Stream := TMemoryStream.Create;
  try
    AbZipKit.ExtractToStream(FileName, Stream);
    Stream.Position := 0;
    try
      Persistent.LoadFromStream(Stream);
    except
      on e: exception do
        ApplicationShowException(e);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TZipper.LoadStream(Stream: TStream; aFileName: string);
var
  FileName: String;
begin
  FileName := GetLoadFileName(aFileName, Stream.ClassName);

  if assigned(Stream) then
    if not FileName.IsEmpty then
      if InternalFileExists(FileName) then
      begin
        AbZipKit.ExtractToStream(FileName, Stream);
        Stream.Position := 0;
      end;
end;

procedure TZipper.LoadStrings(Strings: TStrings; aFileName: string = '');
var
  Stream: TMemoryStream;
  FileName: string;
begin
  FileName := GetLoadFileName(aFileName, Strings.ClassName);

  if not InternalFileExists(FileName) then
    exit;

  Stream := TMemoryStream.Create;
  try
    AbZipKit.ExtractToStream(FileName, Stream);
    Stream.Position := 0;
    try
      Strings.LoadFromStream(Stream);
    except
      on e: exception do
        ApplicationShowException(e);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TZipper.SaveCollection(Collection: TzCustomCollection; aFileName: string = '');

// Scrive (o ripulisce) l'entry di UN formato, in base al relativo flag.
// Nessun parametro Format esposto al chiamante di SaveCollection: qui
// dentro si consultano solo i flag globali di zCollectionPersistence.
  procedure SyncOneFormat(const Format: TzPersistenceFormat; const Enabled: Boolean);
  var
    Stream: TMemoryStream;
    FileName: string;
  begin
    FileName := GetSaveFileName(aFileName, Collection.ClassName, Format);

    if InternalFileExists(FileName) then
      AbZipKit.DeleteFiles(FileName);

    if not Enabled then
      exit; // formato disattivato: l'entry resta rimossa (cleanup migrazione)

    Stream := TMemoryStream.Create;
    try
      Collection.SaveToStreamAs(Stream, Format);
      AbZipKit.AddFromStream(FileName, Stream);
    finally
      FreeAndNil(Stream);
    end;
  end;

begin
  try
    // ZZ 23.02.2016 Tentativo di evitare la rottura dell'lz
    if Collection.count = 0 then
      exit;

    SyncOneFormat(pfJSON, zCollectionPersistence.WriteJSON);
    SyncOneFormat(pfDFM, zCollectionPersistence.WriteDFM);

    Collection.CollectionSaved;
  except
    on e: exception do
    begin
      ConfirmOk(e.Message);
      raise;
    end;
  end;
end;

procedure TZipper.SaveComponent(Component: TComponent; aFileName: string = '');
var
  Stream: TMemoryStream;
  TempStream: TMemoryStream;
  FileName: string;
begin
  FileName := GetSaveFileName(aFileName, Component.ClassName);

  AbZipKit.DeleteFiles(FileName);
  Stream := TMemoryStream.Create;
  try

    TempStream := TMemoryStream.Create;
    try
      TempStream.WriteDescendent(Component, nil);
      TempStream.Seek(0, SoFromBeginning);
      ObjectBinaryToText(TempStream, Stream);
    finally
      TempStream.Free;
    end;

    AbZipKit.AddFromStream(FileName, Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TZipper.SavePersistent(Persistent: TzPersistent; aFileName: string = '');
var
  Stream: TMemoryStream;
  FileName: string;
begin
  FileName := GetSaveFileName(aFileName, Persistent.ClassName);

  AbZipKit.DeleteFiles(FileName);
  Stream := TMemoryStream.Create;
  try
    Persistent.SaveToStream(Stream);
    AbZipKit.AddFromStream(FileName, Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TZipper.SaveStream(Stream: TStream; aFileName: string);
var
  FileName: string;
begin
  assert(not aFileName.IsEmpty);
  assert(assigned(Stream));

  FileName := FullFileName(aFileName);

  AbZipKit.DeleteFiles(FileName);

  Stream.Position := 0;
  AbZipKit.AddFromStream(FileName, Stream);
end;

procedure TZipper.SaveStream(Stream: TStream; aFileName: string; const Format: TzPersistenceFormat);
var
  FileName: string;
begin
  assert(not aFileName.IsEmpty);
  assert(assigned(Stream));

  FileName := FullFileName(aFileName, Format);

  if InternalFileExists(FileName) then
    AbZipKit.DeleteFiles(FileName);

  Stream.Position := 0;
  AbZipKit.AddFromStream(FileName, Stream);
end;

procedure TZipper.RemoveStream(const aFileName: string; const Format: TzPersistenceFormat);
var
  FileName: string;
begin
  FileName := FullFileName(aFileName, Format);

  if InternalFileExists(FileName) then
    AbZipKit.DeleteFiles(FileName);
end;

procedure TZipper.SaveStrings(Strings: TStrings; aFileName: string = '');
var
  Stream: TMemoryStream;
  FileName: string;
begin
  FileName := GetSaveFileName(aFileName, Strings.ClassName);

  AbZipKit.DeleteFiles(FileName);
  Stream := TMemoryStream.Create;
  try
    Strings.SaveToStream(Stream);
    AbZipKit.AddFromStream(FileName, Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TZipper.SetZipFileName(const Value: string);
begin
  if FZipFileName <> Value then
  begin
    FZipFileName := Value;

    try
      AbZipKit.FileName := ZipFileName;
    except
      on e: exception do
      begin
        ConfirmOk('Impossibile aprire il file ' + ZipFileName);
        raise;
      end;
    end;
  end;
end;

initialization

sizCollection := Si.AddSession('zCollection', True);

finalization

sizCollection := nil;

end.

  zmetadata

  zsystemfrm

  zsystem

  - user = luca - db = Gesty zsystem
