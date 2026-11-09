unit zz.csv;

interface

uses
  SysUtils,
  Classes,
  TypInfo,
  Generics.Defaults;

type
  /// /////////////////////////////////////////////////////
  /// Collection
  /// /////////////////////////////////////////////////////
  TzCollection<T: TCollectionItem> = class(TCollection)
  private type
    TCollectionEnumerator = class
    private
      index: Integer;
      Collection: TzCollection<T>;
    public
      constructor Create(ACollection: TzCollection<T>);
      function GetCurrent: T;
      function MoveNext: Boolean;
      property Current: T read GetCurrent;
    end;
  private
    function GetItem(index: Integer): T;
    class function ItemAsGeneric(const Item): T;
    procedure SetItem(index: Integer; const Value: T);
    function ItemClassName: string;
  protected
  public
    function Add: T;
    function GetEnumerator: TCollectionEnumerator;
    function Insert(index: Integer): T;
    property Items[index: Integer]: T read GetItem write SetItem; default;
  end;

  TRecordItem = class(TCollectionItem)
  private
    FValues: TStrings;
    FRecNo: Integer;
    procedure SetRecNo(const Value: Integer);
    procedure SetValues(const Value: TStrings);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property RecNo: Integer read FRecNo write SetRecNo;
    property Values: TStrings read FValues write SetValues;
  end;

  TImportCSV = class
  private
    FFieldNames: TStrings;
    FRecords: TzCollection<TRecordItem>;
    procedure SetFieldNames(const Value: TStrings);
    procedure SetRecords(const Value: TzCollection<TRecordItem>);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);

    function Count: Integer;
    function GetValue(Const FieldName: string; const RecNo: Integer): string;
    function FieldExists(Const FieldName: string): Boolean;
  published
    property FieldNames: TStrings read FFieldNames write SetFieldNames;
    property Records: TzCollection<TRecordItem> read FRecords write SetRecords;
  end;


  // TExportCSV
  // dataset
  // filename
  // varie proprieta

implementation

uses
  Vcl.Clipbrd;

function TzCollection<T>.Add: T;
var
  Item: TCollectionItem;
begin
  Item := inherited Add;
  Result := ItemAsGeneric(Item);
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

function TzCollection<T>.ItemClassName: string;
begin
  Result := GetTypeName(TypeInfo(T));
end;

procedure TzCollection<T>.SetItem(index: Integer;

  const Value: T);
begin
  Items[index].Assign(Value);
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
  Result := index < Collection.Count - 1;
  if Result then
    Inc(index);
end;

{ TImportCSV }

constructor TImportCSV.Create;
begin
  inherited;
  FFieldNames := TStringList.Create;
  FRecords := TzCollection<TRecordItem>.Create(TRecordItem);
end;

destructor TImportCSV.Destroy;
begin
  FreeAndNil(FFieldNames);
  FreeAndNil(FRecords);
  inherited;
end;

{ TRecordItem }

constructor TRecordItem.Create(Collection: TCollection);
begin
  inherited;
  FValues := TStringList.Create;
  FRecNo := 0;
end;

destructor TRecordItem.Destroy;
begin
  FreeAndNil(FValues);
  inherited;
end;

procedure TRecordItem.SetRecNo(const Value: Integer);
begin
  FRecNo := Value;
end;

procedure TRecordItem.SetValues(const Value: TStrings);
begin
  FValues.Assign(Value);
end;

procedure TImportCSV.SetFieldNames(const Value: TStrings);
begin
  FFieldNames.Assign(Value);
end;

procedure TImportCSV.SetRecords(const Value: TzCollection<TRecordItem>);
begin
  FRecords := Value;
end;

function TImportCSV.Count: Integer;
begin
  Result := Records.Count;
end;

function TImportCSV.FieldExists(Const FieldName: string): Boolean;
var
  s: string;
begin
  Result := false;

  for s in FieldNames do
    if SameText(s, FieldName) then
      exit(true);
end;

function TImportCSV.GetValue(const FieldName: string; const RecNo: Integer): string;
var
  idx: Integer;
  s: string;
begin
  for idx := 0 to FieldNames.Count - 1 do
    if SameText(FieldNames[idx], FieldName) then
    begin
      Result := Records[RecNo].Values[idx];
      exit;
    end;

  // se non fa trovato il campo
  raise Exception.Create('Campo non trovato: ' + FieldName);
end;

procedure TImportCSV.LoadFromFile(const FileName: string);
var
  i: Integer;
  msg: string;
  s: string;
  strFile, strRow: TStringList;
  rec: TRecordItem;
begin
  FieldNames.Clear;
  FRecords.Clear;

  strFile := TStringList.Create;
  try
    strRow := TStringList.Create;
    try
      strRow.Delimiter := ';';
      strRow.StrictDelimiter := true;
      strRow.QuoteChar := #0; // casi tipo ...;"THE ONE" DI CARACCIOLO ROSANNA GIUSEPPINA fanno saltare tutto

      /// ///////////////
      /// Lettura file
      strFile.LoadFromFile(FileName);

      /// ///////////////
      /// Campi
      strRow.DelimitedText := strFile[0];
      for s in strRow do
        FieldNames.Add(s);
      /// ///////////////

      for i := 1 to strFile.Count - 1 do
        if not strFile[i].Trim.IsEmpty then
        begin
          strRow.DelimitedText := strFile[i];

          rec := Records.Add;
          rec.RecNo := i - 1;

          for s in strRow do
            rec.Values.Add(AnsiDequotedStr(s, '"'));

          if rec.Values.Count <> FieldNames.Count then
          begin
            msg := 'Riga ' + i.ToString + '. Campi del record non validi: attesi ' + FieldNames.Count.ToString + ' trovati ' + rec.Values.Count.ToString + '.' + #13#13 +
              strFile[i];

            Clipboard.AsText := msg;
            raise Exception.Create(msg);
          end;
        end;

    finally
      FreeAndNil(strRow);
    end;
  finally
    FreeAndNil(strFile);
  end;
end;

end.
