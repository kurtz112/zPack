unit zDbView.Sort;

interface

uses
  SysUtils,
  cxGridDBTableView,
  zDataController;

type
  // Voce di ordinamento indipendente dalla grid: espressione SQL (origine
  // del campo o indice posizionale) + direzione. E' il modello su cui
  // lavorano BuildOrderBy/ParseOrderBy, testabili senza grid ne' database.
  TzSortItem = record
    Espressione: string;
    Discendente: boolean;
  end;

  TzSortItems = TArray<TzSortItem>;

  TzDbViewSortController = class(TObject)
  private
    DisableSorting: Boolean;
    FDataController: TzDataController;
    FSortingEnabled: Boolean;
    FView: TcxGridDBTableView;
    function CanSort: Boolean;
  public
    constructor Create(aDataController: TzDataController; aView: TcxGridDBTableView);
    procedure Sort;
    procedure InitColumns;

    // Logica pura estratta da Sort/InitColumns: costruzione e parsing della
    // clausola ORDER BY come round-trip simmetrico.
    class function BuildOrderBy(const Items: TzSortItems): string; static;
    class function ParseOrderBy(const OrderBy: string): TzSortItems; static;

    property SortingEnabled: Boolean read FSortingEnabled write FSortingEnabled;
    property DataController: TzDataController read FDataController write FDataController;
    property View: TcxGridDBTableView read FView write FView;
  end;

implementation

uses
  Classes,
  StrUtils,
  Controls,
  Forms,
  cxCustomData,
  dxCore,
  Data.DB,
  zSystem;

{ TzDbViewSortController }

constructor TzDbViewSortController.Create(aDataController: TzDataController; aView: TcxGridDBTableView);
begin
  inherited Create;

  Assert(Assigned(aDataController));
  Assert(Assigned(aView));
  DisableSorting := false;
  FSortingEnabled := True;
  FDataController := aDataController;
  FView := aView;
end;

function TzDbViewSortController.CanSort: Boolean;
begin
  Result := DataController.DataSetOk and SortingEnabled and (not DisableSorting);
end;

class function TzDbViewSortController.BuildOrderBy(const Items: TzSortItems): string;
var
  item: TzSortItem;
begin
  result := '';

  for item in Items do
  begin
    if item.Espressione = '' then
      Continue;

    if result <> '' then
      result := result + ', ';

    result := result + item.Espressione;

    if item.Discendente then
      result := result + ' DESC';
  end;
end;

class function TzDbViewSortController.ParseOrderBy(const OrderBy: string): TzSortItems;
var
  i: Integer;
  s: string;
  Str: TStringList;
  item: TzSortItem;
begin
  result := nil;

  Str := TStringList.Create;
  try
    Str.StrictDelimiter := True;
    Str.Delimiter := ',';
    Str.DelimitedText := OrderBy;

    for i := 0 to Str.Count - 1 do
    begin
      s := Trim(Str[i]);

      if s = '' then
        Continue;

      // ' DESC' viene riconosciuto solo come suffisso: il vecchio ContainsStr
      // dava falso positivo su espressioni che contenevano la sequenza al
      // proprio interno.
      item.Discendente := EndsText(' DESC', s);
      if item.Discendente then
        s := Trim(System.Copy(s, 1, Length(s) - Length(' DESC')));

      item.Espressione := s;
      result := result + [item];
    end;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzDbViewSortController.Sort;
  function FieldExistsInMetadata(Field: TField): Boolean;
  var
    fieldName, TableName: String;
  begin
    Assert(Assigned(Field));

    fieldName := Field.fieldName;
    TableName := DataController.zFbDataSet.GetFieldTableName(Field);
    Result := Base.MetaData.FieldOrParamExists(TableName, fieldName);
  end;

var
  Field: TField;
  i: Integer;
  Items: TzSortItems;
  item: TzSortItem;
begin
  if not CanSort then
    exit;

  Items := nil;

  for i := 0 to View.SortedItemCount - 1 do
    if Assigned(TcxGridDBColumn(View.SortedItems[i]).DataBinding.Field) then
    begin
      Field := TcxGridDBColumn(View.SortedItems[i]).DataBinding.Field;

      if not FieldExistsInMetadata(Field) then
      begin
        item.Espressione := (Field.Index + 1).ToString;
      end
      else
      begin
        item.Espressione := DataController.GetFieldOrigin(Field);

        if item.Espressione = '' then
          item.Espressione := Field.fieldName;
      end;

      item.Discendente := View.SortedItems[i].SortOrder = soDescending;
      Items := Items + [item];
    end;

  DataController.SQL_OrderBy := BuildOrderBy(Items);
end;

procedure TzDbViewSortController.InitColumns;
var
  fieldName: string;
  i: Integer;
  Items: TzSortItems;
  SortOrder: TcxDataSortOrder;
  column: TcxGridDBColumn;
begin
  if not CanSort then
  begin
  end
  else
  begin
    DisableSorting := True;
    try
      View.DataController.ClearSorting(false);

      Items := ParseOrderBy(DataController.SQL_OrderBy);

      for i := 0 to High(Items) do
      begin
        SortOrder := soAscending;
        if Items[i].Discendente then
          SortOrder := soDescending;

        fieldName := DataController.GetFieldNameByOrigin(Items[i].Espressione);

        if fieldName <> '' then
        begin
          column := View.GetColumnByFieldName(fieldName) as TcxGridDBColumn;

          if Assigned(column) then
          begin
            column.SortOrder := SortOrder;
            column.SortIndex := i;
          end;
        end;
      end;
    finally
      DisableSorting := false;
    end;
  end;
end;

end.
