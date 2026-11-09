unit zDbView.Footer;

interface

uses
  SysUtils,
  Windows,
  db,
  cxGridDBTableView,
  cxFilter,
  cxDBData,
  zDataController,
  zFbDataSet,
  zSystem;

type
  TzDbViewFooterController = class(TObject)
  private
    FDataController: TzDataController;
    FView: TcxGridDBTableView;
  private
    busy: boolean;
    function CreateDataset(const sql: string): TzFbDataSet;
    function GetSQL(Columns: TzColumns): string;
  public
    constructor Create(aDataController: TzDataController; aView: TcxGridDBTableView);
    property DataController: TzDataController read FDataController;
    property View: TcxGridDBTableView read FView;
  public
    // Logica pura estratta da GetSQL: compone la query aggregata di footer
    // a partire dal testo SQL della view. ResolveOrigin mappa il nome
    // colonna sull'espressione da aggregare ('' = colonna da saltare) ed e'
    // il seam che consente il test senza DataController ne' database.
    class function BuildFooterSQL(const BaseSql: string; Columns: TzColumns;
      ResolveOrigin: TFunc<string, string>): string; static;

    procedure CalculateFooterValues(Columns: TzColumns);
  end;

implementation

uses
  Classes,
  StrUtils,
  Controls,
  Forms,
  cxCustomData,
  Variants,
  zSql.SqlTxtRtns,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

{ TzDbViewFooterController }

constructor TzDbViewFooterController.Create(aDataController: TzDataController; aView: TcxGridDBTableView);
begin
  inherited Create;
  Assert(Assigned(aDataController));
  Assert(Assigned(aView));

  busy := false;
  FDataController := aDataController;
  FView := aView;
end;

procedure TzDbViewFooterController.CalculateFooterValues(Columns: TzColumns);
var
  Column: TzColumn;
  DataSet: TzFbDataSet;
  Field: TField;
  sql: string;
begin
  if busy then
    exit;

  busy := true;
  try
    Columns.ClearFooterValues;

    if not DataController.IsActive then
      exit;

    if not DataController.IsSQL then
      exit;

    sql := GetSQL(Columns);

    if sql = '' then
      exit;

    siMain.EnterMethod(self, 'TzDbViewFooterController.CalculateFooterValues');

    DataSet := CreateDataset(sql);
    try
      try
        DataSet.Active := true;
      except
        exit;
        // on e: exception do
        // Application.HandleException(e);
      end;

      // assegnazione
      for Field in DataSet.Fields do
      begin
        Column := Columns.Get(Field.FieldName, false);

        if Assigned(Column) then
          Column.FooterValue := Field.Value;
      end;

      DataSet.Active := false;
    finally
      FreeAndNil(DataSet);
    end;

    siMain.LeaveMethod(self, 'TzDbViewFooterController.CalculateFooterValues');
  finally
    busy := false;
  end;
end;

function TzDbViewFooterController.CreateDataset(const sql: string): TzFbDataSet;
var
  i: Integer;
  ViewDataSet: TzFbDataSet;
begin

  if not DataController.IsSQL then
    exit(nil);

  ViewDataSet := DataController.DataSet as TzFbDataSet;

  Result := CreateFbDataSet(nil, ViewDataSet.Database as TzFbDataBase, ViewDataSet.Transaction, nil);
  Result.Name := ViewDataSet.Name + '__FOOTER';
  Result.SelectSQL.Text := sql;
  siMain.LogStringList(ViewDataSet.Name + '.CalcFooters', Result.SelectSQL);

  try
    Result.Prepare;
  except
    exit;
  end;

  // parametri
  for i := 0 to Result.ParamCount - 1 do
    if ViewDataSet.ParamExists(Result.Params[i].Name) then
    begin
      siMain.LogValue(Result.Params[i].Name, ViewDataSet.ParamByName(Result.Params[i].Name).AsString);
      Result.Params[i].Value := ViewDataSet.ParamByName(Result.Params[i].Name).Value;
    end;
end;

function TzDbViewFooterController.GetSQL(Columns: TzColumns): string;
begin
  Result := '';

  if not DataController.DataSetOk then
    exit;

  // La composizione vera e propria e' in BuildFooterSQL (pura); qui restano
  // solo le guardie e l'adattatore che risolve l'origine dei campi tramite
  // il DataController.
  Result := BuildFooterSQL(DataController.sql, Columns,
    function(ColumnName: string): string
    var
      Field: TField;
    begin
      Result := '';

      if not DataController.TryGetField(ColumnName, Field) then
        exit;

      Result := DataController.GetFieldOrigin(Field);

      if Result = '' then
        Result := Field.FieldName;
    end);
end;

class function TzDbViewFooterController.BuildFooterSQL(const BaseSql: string; Columns: TzColumns;
  ResolveOrigin: TFunc<string, string>): string;
var
  Column: TzColumn;
  i: Integer;
  SqlFrom: string;
  s: string;
  Str: TStringList;
  sql: string;
  Origin: string;
begin
  Result := '';

  if trim(BaseSql) = '' then
    exit;

  SqlFrom := CountSelect(BaseSql);
  SqlFrom := StringReplace(SqlFrom, 'Select Count(*)', ' ', [rfIgnoreCase]);

  Str := TStringList.Create;
  try
    for Column in Columns do
      if Column.FooterKind <> skNone then
      begin
        case Column.FooterKind of
          skNone:
            Continue;
          skSUM:
            s := 'SUM';
          skAverage:
            s := 'AVG';
          skCOUNT:
            s := 'COUNT';
          skMIN:
            s := 'MIN';
          skMAX:
            s := 'MAX';
        end;

        //
        Origin := ResolveOrigin(Column.Name);

        if Origin = '' then
          Continue;

        Str.Add(s + '(' + Origin + ') ' + Column.Name);
      end;

    if Str.count = 0 then
      exit;

    sql := 'SELECT' + #13;
    for i := 0 to Str.count - 1 do
    begin
      sql := sql + Str[i];
      if i = Str.count - 1 then
        sql := sql + #13 + SqlFrom
      else
        sql := sql + ',' + #13;
    end;

  finally
    FreeAndNil(Str);
  end;
  Result := sql;
end;

end.
