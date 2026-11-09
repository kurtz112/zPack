unit zz.GenericCollection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  TJSONCollection = class(TCollection)
  private
    FJSON: string;
  public
    procedure Decode(const JSONObject: TJSONObject; const PropertyName: string); overload; virtual; abstract;
    procedure Decode(const JSONArray: TJSONArray); overload; virtual; abstract;
    function Encode: TJSONArray; virtual; abstract;

    // utilizzato dalle discendenti
    property JSON: string read FJSON write FJSON;
  end;

  TzGenericCollection<T: TCollectionItem> = class(TJSONCollection)
  private type
    TCollectionEnumerator = class
    private
      index: Integer;
      Collection: TzGenericCollection<T>;
    public
      constructor Create(ACollection: TzGenericCollection<T>);
      function GetCurrent: T;
      function MoveNext: Boolean;
      property Current: T read GetCurrent;
    end;
  private
    function GetAsText: string;
    function GetItem(index: Integer): T;
    procedure SetAsText(const Value: string);
    procedure SetItem(index: Integer; const Value: T);
  protected
    class function ItemAsGeneric(const Item): T;
  protected
    function Compare(Item1, Item2: T): Integer; virtual;
  public
    function Add: T;
    function GetEnumerator: TCollectionEnumerator;
    function IndexOf(func: TFunc<T, Boolean>): Integer;
    function Get(func: TFunc<T, Boolean>; CanAppend: Boolean = False): T;

    procedure ForEach(func: TFunc<T, Boolean>);

    function Insert(index: Integer): T;
    procedure LoadFromFile(FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure Remove(Item: T);
    procedure SaveToFile(FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure Sort;
    property AsText: string read GetAsText write SetAsText;
    property Items[index: Integer]: T read GetItem write SetItem; default;
  published
  end;

  TProxy = class(TComponent)
  private
    FPersistent: TPersistent;
  published
    property Obj: TPersistent read FPersistent write FPersistent;
  end;

  THackCollection = class(TPersistent)
  private
    FItemClass: TCollectionItemClass;
    FItems: TList<TCollectionItem>;
  end;

implementation

/// ////////////////////////////
function TzGenericCollection<T>.Add: T;
var
  Item: TCollectionItem;
begin
  Item := inherited Add;
  Result := ItemAsGeneric(Item);
end;

function TzGenericCollection<T>.Compare(Item1, Item2: T): Integer;
begin
  (*

    Descendant classes would override this method and cast Item1 and Item2 to the
    decendant class's collection item type perform the field comparisions

    if item1.MyField < item2.MyField
    return -1
    else if item1.MyField > item2.MyField
    return 1
    else return 0

  *)
  Result := 0;
end;

procedure TzGenericCollection<T>.ForEach(func: TFunc<T, Boolean>);
var
  Item: T;
begin
  assert(assigned(func));

  for Item in Self do
    if not func(Item) then
      Exit;
end;

function TzGenericCollection<T>.GetAsText: string;
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

function TzGenericCollection<T>.GetEnumerator: TCollectionEnumerator;
begin
  Result := TCollectionEnumerator.Create(Self);
end;

function TzGenericCollection<T>.GetItem(index: Integer): T;

var
  Item: TCollectionItem;
begin
  Item := inherited Items[index];
  Result := ItemAsGeneric(Item);
end;

function TzGenericCollection<T>.IndexOf(func: TFunc<T, Boolean>): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Count - 1 do
    if func(Items[i]) then
    begin
      Result := i;
      Exit;
    end;
end;

function TzGenericCollection<T>.Get(func: TFunc<T, Boolean>; CanAppend: Boolean): T;
var
  Idx: Integer;
  dummy: TCollectionItem;
begin
  dummy := nil;

  Result := ItemAsGeneric(dummy);

  Idx := IndexOf(func);

  if Idx <> -1 then
    Result := Items[Idx]
  else
    if CanAppend then
      Result := Add;
end;



// TODO: IndexOf
// function TzCollection<T>.IndexOf(name: string): Integer;
//
// var
// I: Integer;
// begin
// Result := -1;
//
// if name <> '' then
// for I := 0 to Count - 1 do
// if SameText(name, Items[I].name) then
// begin
// Result := I;
// Break;
// end;
// end;

function TzGenericCollection<T>.Insert(index: Integer): T;

var
  Item: TCollectionItem;
begin
  Item := inherited Insert(index);
  Result := ItemAsGeneric(Item);
end;

class function TzGenericCollection<T>.ItemAsGeneric(const Item): T;
begin
  Result := T(Item);
end;

procedure TzGenericCollection<T>.LoadFromFile(FileName: string);
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

{ TzGenericCollection }

procedure TzGenericCollection<T>.LoadFromStream(Stream: TStream);

var
  Proxy: TProxy;
  MemStream: TMemoryStream;
  Reader: TReader;
begin
  if not assigned(Stream) then
    Exit;

  MemStream := TMemoryStream.Create;
  try
    Proxy := TProxy.Create(nil);
    try
      ObjectTextToBinary(Stream, MemStream);
      MemStream.Seek(0, SoFromBeginning);
      Proxy.Obj := Self;
      //
      Reader := TReader.Create(MemStream, 4096);
      try
        Reader.ReadRootComponent(Proxy);
      finally
        Reader.Free;
      end;
      //
    finally
      Proxy.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

procedure TzGenericCollection<T>.Remove(Item: T);
begin
  Delete(Item.index);
end;

// procedure TzGenericCollection<T>.QuickSort(L, R: Integer);
// var
// i, J, p: Integer;
// Save: TCollectionItem;
// SortList: TList<TCollectionItem>;
// begin
//
// SortList := THackCollection(Self).FItems;
//
// repeat
// i := L;
// J := R;
// p := (L + R) shr 1;
// repeat
// while Compare(Items[i], Items[p]) < 0 do
// Inc(i);
// while Compare(Items[J], Items[p]) > 0 do
// Dec(J);
// if i <= J then
// begin
// Save := SortList.Items[i];
// SortList.Items[i] := SortList.Items[J];
// SortList.Items[J] := Save;
// if p = i then
// p := J
// else
// if p = J then
// p := i;
// Inc(i);
// Dec(J);
// end;
// until i > J;
// if L < J then
// QuickSort(L, J);
// L := i;
// until i >= R;
// end;

procedure TzGenericCollection<T>.SaveToFile(FileName: string);
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

procedure TzGenericCollection<T>.SaveToStream(Stream: TStream);

var
  Proxy: TProxy;
  MemStream: TMemoryStream;
  // X: IXMLDocument;
begin
  if not assigned(Stream) then
    Exit;

  MemStream := TMemoryStream.Create;
  try
    Proxy := TProxy.Create(nil);
    try
      Proxy.Obj := Self;
      MemStream.WriteComponent(Proxy);
      MemStream.Seek(0, SoFromBeginning);
      ObjectBinaryToText(MemStream, Stream);
    finally
      Proxy.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

procedure TzGenericCollection<T>.SetAsText(const Value: string);
var
  Str: TStringList;
  Stream: TMemoryStream;
begin
  if Value = '' then
  begin
    Clear;
    Exit;
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

procedure TzGenericCollection<T>.SetItem(index: Integer;

  const Value: T);
begin
  Items[index].Assign(Value);
end;

//
procedure TzGenericCollection<T>.Sort;
var
  Comparer: IComparer<TCollectionItem>;
begin

  Comparer := TComparer<TCollectionItem>.Construct(
    function(const Item1, Item2: TCollectionItem): Integer
    begin
      Result := Compare(ItemAsGeneric(Item1), ItemAsGeneric(Item2));
    end);

  inherited Sort(Comparer);
end;

// begin
// if Count > 1 then
// begin
// BeginUpdate;
// try
// QuickSort(0, Count - 1);
// finally
// EndUpdate;
// end;
// end;
// end;

{ TzCollection<T>.TCollectionEnumerator }

constructor TzGenericCollection<T>.TCollectionEnumerator.Create(ACollection: TzGenericCollection<T>);
begin
  inherited Create;
  index := -1;
  Collection := ACollection;
end;

function TzGenericCollection<T>.TCollectionEnumerator.GetCurrent: T;
begin
  Result := Collection.Items[index];
end;

function TzGenericCollection<T>.TCollectionEnumerator.MoveNext: Boolean;
begin
  Result := index < Collection.Count - 1;
  if Result then
    Inc(index);
end;

end.
zcollection
