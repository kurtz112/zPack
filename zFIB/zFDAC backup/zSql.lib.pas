unit zSql.lib;

interface

uses
  SysUtils,
  Classes,
  zMetaData;

type
  TQueryType = (qtSelect, qtRefresh, qtInsert, qtUpdate, qtDelete);

function Get_TableNameFromSQL(MetaData: TzMetaData; Sql: string; var TableName: string; Ask: Boolean = False): Boolean;

function Build_Sql_Select(MetaData: TzMetaData; TableName: string; aFieldNames: TStrings = nil; AddOrderByPk: Boolean = True): string;
function Build_Sql_Insert(MetaData: TzMetaData; TableName: string; aFieldNames: TStrings = nil; const IdentityField: string = ''): string;
function Build_Sql_Update(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string = ''; aFieldNames: TStrings = nil): string;
function Build_Sql_Delete(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string = ''): string;
function Build_Sql_Refresh(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string = ''; aFieldNames: TStrings = nil): string;

function Build_FkRelation(MetaData: TzMetaData; SelectSQL: string; TableName, ForeignTable: string): string;

procedure Get_FieldNames(MetaData: TzMetaData; TableName: string; FieldNames: TStrings);
procedure Get_KeyFields(MetaData: TzMetaData; TableName: string; KeyFields: TStrings);
function Get_KeyFields_Str(MetaData: TzMetaData; TableName: string): string;
function Calc_WhereByKeyFields(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string; const AddWhereKeyword: Boolean = True): string;

function ClearSqlWhere(const Sql: string): string;
function GetCountSQL(SelectSQL: string): string;
function GetWhereSQL(SelectSQL: string): string;
function GetOrderByPK(MetaData: TzMetaData; TableName: string): string;

function IsSqlAllowed(MetaData: TzMetaData; const TableName: string; const QueryType: TQueryType): Boolean;

implementation

uses
  DbCommon,
  SqlTxtRtns,
  zMsg,
  zCollection;

function GetProcedureInputParams(MetaData: TzMetaData; ProcedureName: string): string;
var
  i: integer;
  idx: integer;
begin
  result := '';

  idx := MetaData.Procedures.IndexOf(ProcedureName);
  if idx = -1 then
    Exit;

  if MetaData.Procedures[idx].ParamsInput.Count = 0 then
    Exit;

  result := '(';
  for i := 0 to MetaData.Procedures[idx].ParamsInput.Count - 1 do
  begin
    if i < MetaData.Procedures[idx].ParamsInput.Count - 1 then
      result := result + ':' + MetaData.Procedures[idx].ParamsInput[i].Name + ', '
    else
      result := result + ':' + MetaData.Procedures[idx].ParamsInput[i].Name;
  end;
  result := result + ')';
end;

function ClearSqlWhere(const Sql: string): string;
var
  Parser: TSQLParser;
begin
  result := '';
  Parser := TSQLParser.create;
  try
    Parser.SQLText := Sql;
    result := Parser.SetMainWhereClause('');
  finally
    FreeAndNil(Parser);
  end;
end;

procedure Get_FieldNames(MetaData: TzMetaData; TableName: string; FieldNames: TStrings);
var
  str: TStringList;
  i: integer;
  idx: integer;
begin
  if not Assigned(MetaData) then
    Exit;

  str := TStringList.create;
  try
    FieldNames.Clear;

    // prima con le table
    idx := MetaData.Tables.IndexOf(TableName);
    if idx <> -1 then
    begin
      for i := 0 to MetaData.Tables[idx].Fields.Count - 1 do
        if trim(MetaData.Tables[idx].Fields[i].CalculatedSource) = '' then
          FieldNames.add(MetaData.Tables[idx].Fields[i].Name);
    end
    else
    begin // tenta con le view
      idx := MetaData.Views.IndexOf(TableName);
      if idx <> -1 then
      begin
        for i := 0 to MetaData.Views[idx].Fields.Count - 1 do
          if trim(MetaData.Views[idx].Fields[i].CalculatedSource) = '' then
            FieldNames.add(MetaData.Views[idx].Fields[i].Name);
      end;
    end;

  finally
    FreeAndNil(str);
  end;
end;

procedure Get_KeyFields(MetaData: TzMetaData; TableName: string; KeyFields: TStrings);
var
  i: integer;
  idx: integer;
begin
  if not Assigned(MetaData) then
    Exit;

  KeyFields.Clear;

  idx := MetaData.Tables.IndexOf(TableName);
  if idx <> -1 then
  begin

    if MetaData.Tables[idx].PrimaryKey.Count > 0 then
    begin
      for i := 0 to MetaData.Tables[idx].PrimaryKey.Count - 1 do
        KeyFields.add(TableName + '.' + MetaData.Tables[idx].PrimaryKey[i].Name);
    end
    else
    begin
      // se non ha pk deve esporre tutti i campi
      for i := 0 to MetaData.Tables[idx].Fields.Count - 1 do
        KeyFields.add(TableName + '.' + MetaData.Tables[idx].Fields[i].Name);
    end;
  end
  else
  begin
    // se è una view deve esporre tutti i campi, non potendo sapere quale sia la pk da utilizzare.
    idx := MetaData.Views.IndexOf(TableName);
    if idx <> -1 then
    begin
      for i := 0 to MetaData.Views[idx].Fields.Count - 1 do
        KeyFields.add(TableName + '.' + MetaData.Views[idx].Fields[i].Name);
    end;
  end;
end;

function Get_KeyFields_Str(MetaData: TzMetaData; TableName: string): string;
var
  Chiavi: TStringList;
begin
  result := '';
  Chiavi := TStringList.create;
  try
    Get_KeyFields(MetaData, TableName, Chiavi);
    result := Chiavi.Text;
  finally
    FreeAndNil(Chiavi);
  end;
end;

function Calc_WhereByKeyFields(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string; const AddWhereKeyword: Boolean = True): string;
var
  i: integer;
  Chiavi: TStringList;

  function TruncTableName(Key: string): string;
  begin
    result := Key;
    if Pos('.', result) <> 0 then
      result := System.Copy(result, Pos('.', result) + 1, Length(result));
  end;

begin
  result := '';
  Chiavi := TStringList.create;
  try
    Chiavi.Delimiter := ';';
    Chiavi.StrictDelimiter := True;

    if PrimaryKeyFields = '' then
      Get_KeyFields(MetaData, TableName, Chiavi)
    else
      Chiavi.DelimitedText := PrimaryKeyFields;

    if Chiavi.Count > 0 then
    begin
      if AddWhereKeyword then
        result := 'WHERE' + #13
      else
        result := '';

      for i := 0 to Chiavi.Count - 1 do
        if i <> Chiavi.Count - 1 then
          result := result + ' ' + Chiavi.Strings[i] + '=:OLD_' + TruncTableName(Chiavi.Strings[i]) + ' AND ' + #13
        else
          result := result + ' ' + Chiavi.Strings[i] + '=:OLD_' + TruncTableName(Chiavi.Strings[i]);
    end;
  finally
    FreeAndNil(Chiavi);
  end;
end;

function IsSqlAllowed(MetaData: TzMetaData; const TableName: string; const QueryType: TQueryType): Boolean;
var
  idx: integer;
begin
  result := True;

  if not Assigned(MetaData) then
    raise exception.create('Metadata non assegnati.');

  // verifica se è una view, se si deve esserci il trigger
  idx := MetaData.Views.IndexOf(TableName);
  if idx <> -1 then
  begin
    case QueryType of
      qtSelect:
        result := True;
      qtRefresh:
        result := True;
      qtInsert:
        result := MetaData.Views[idx].HasTriggerInsert;
      qtUpdate:
        result := MetaData.Views[idx].HasTriggerUpdate;
      qtDelete:
        result := MetaData.Views[idx].HasTriggerDelete;
    end;
  end;
end;

function Build_Sql_Select(MetaData: TzMetaData; TableName: string; aFieldNames: TStrings = nil; AddOrderByPk: Boolean = True): string;
var
  i: integer;
  s: string;
  str: TStringList;
  FieldName: string;
  FieldNames: TStringList;
begin
  result := '';

  if not IsSqlAllowed(MetaData, TableName, qtSelect) then
    Exit;

  FieldNames := TStringList.create;
  try
    if Assigned(aFieldNames) then
      FieldNames.Assign(aFieldNames);
    // else
    // Get_FieldNames(MetaData, TableName, FieldNames);

    str := TStringList.create;
    try
      str.Clear;

      if FieldNames.Count = 0 then
        str.add('SELECT *')
      else
      begin
        str.add('SELECT');
        for i := 0 to FieldNames.Count - 1 do
        begin
          FieldName := FieldNames[i];
          if i <> FieldNames.Count - 1 then
            str.add(' ' + TableName + '.' + FieldName + ',')
          else
            str.add(' ' + TableName + '.' + FieldName); // toglie la virgola dall'ultimo campo
        end;
      end;

      if MetaData.Procedures.IndexOf(TableName) = -1 then
      begin
        str.add('FROM ' + TableName);
        if AddOrderByPk then
          str.add(GetOrderByPK(MetaData, TableName));
      end
      else
        str.add('FROM ' + TableName + GetProcedureInputParams(MetaData, TableName));

      result := str.Text;
    finally
      FreeAndNil(str);
    end;
  finally
    FreeAndNil(FieldNames);
  end;
end;

function Build_Sql_Refresh(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string = ''; aFieldNames: TStrings = nil): string;
var
  i: integer;
  s: string;
  str: TStringList;
  FieldName: string;
  FieldNames: TStringList;
  WhereStr: string;
begin
  result := '';

  if not IsSqlAllowed(MetaData, TableName, qtRefresh) then
    Exit;

  FieldNames := TStringList.create;
  try
    if Assigned(aFieldNames) then
      FieldNames.Assign(aFieldNames);
    // else
    // Get_FieldNames(MetaData, TableName, FieldNames);

    str := TStringList.create;
    try
      str.Clear;

      if FieldNames.Count = 0 then
        str.add('SELECT *')
      else
      begin
        str.add('SELECT');
        for i := 0 to FieldNames.Count - 1 do
        begin
          FieldName := FieldNames[i];
          if i <> FieldNames.Count - 1 then
            str.add(' ' + TableName + '.' + FieldName + ',')
          else
            str.add(' ' + TableName + '.' + FieldName); // toglie la virgola dall'ultimo campo
        end;
      end;

      if MetaData.Procedures.IndexOf(TableName) = -1 then
      begin
        str.add('FROM ' + TableName);
      end
      else
        str.add('FROM ' + TableName + GetProcedureInputParams(MetaData, TableName));

      WhereStr := Calc_WhereByKeyFields(MetaData, TableName, PrimaryKeyFields);
      if trim(WhereStr) <> '' then
        str.add(WhereStr);

      result := str.Text;
    finally
      FreeAndNil(str);
    end;
  finally
    FreeAndNil(FieldNames);
  end;
end;

function Build_Sql_Insert(MetaData: TzMetaData; TableName: string; aFieldNames: TStrings = nil; const IdentityField: string = ''): string;
var
  i: integer;
  s: string;
  str: TStringList;
  FieldNames: TStringList;
begin
  result := '';

  if not IsSqlAllowed(MetaData, TableName, qtInsert) then
    Exit;

  FieldNames := TStringList.create;
  try
    if Assigned(aFieldNames) then
      FieldNames.Assign(aFieldNames)
    else
      Get_FieldNames(MetaData, TableName, FieldNames);

    if FieldNames.Count = 0 then
      Exit;

    str := TStringList.create;
    try
      str.Clear;
      str.add('INSERT INTO ' + TableName + ' (');
      for i := 0 to FieldNames.Count - 1 do
        if not SameText(FieldNames[i], IdentityField) then
        begin
          s := '  ' + FieldNames[i];
          if i <> FieldNames.Count - 1 then
            s := s + ','
          else
            s := s + ')';
          str.add(s);
        end;

      str.add('VALUES (');
      for i := 0 to FieldNames.Count - 1 do
        if not SameText(FieldNames[i], IdentityField) then
        begin
          s := '  ' + ':' + FieldNames[i];
          if i <> FieldNames.Count - 1 then
            s := s + ','
          else
            s := s + ')';
          str.add(s);
        end;

      if IdentityField <> '' then
        str.add('RETURNING ' + IdentityField);

      result := str.Text;
    finally
      FreeAndNil(str);
    end;
  finally
    FreeAndNil(FieldNames);
  end;
end;

function Build_Sql_Update(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string = ''; aFieldNames: TStrings = nil): string;
var
  i: integer;
  s: string;
  str: TStringList;
  FieldName: string;
  WhereStr: string;
  FieldNames: TStringList;
begin
  result := '';

  if not IsSqlAllowed(MetaData, TableName, qtUpdate) then
    Exit;

  FieldNames := TStringList.create;
  try
    if Assigned(aFieldNames) then
      FieldNames.Assign(aFieldNames)
    else
      Get_FieldNames(MetaData, TableName, FieldNames);

    if FieldNames.Count = 0 then
      Exit;

    str := TStringList.create;
    try
      str.Clear;
      str.add('UPDATE ' + TableName);
      str.add('SET');

      for i := 0 to FieldNames.Count - 1 do
      begin
        FieldName := FieldNames[i];
        if i <> FieldNames.Count - 1 then
          str.add(' ' + FieldName + '=:' + FieldName + ',')
        else
          str.add(' ' + FieldName + '=:' + FieldName);
      end;

      WhereStr := Calc_WhereByKeyFields(MetaData, TableName, PrimaryKeyFields);
      if trim(WhereStr) <> '' then
        str.add(WhereStr);

      result := str.Text;
    finally
      FreeAndNil(str);
    end;
  finally
    FreeAndNil(FieldNames);
  end;
end;

function Build_Sql_Delete(MetaData: TzMetaData; TableName: string; PrimaryKeyFields: string = ''): string;
var
  i: integer;
  s: string;
  str: TStringList;
  WhereStr: string;
  idx: integer;
begin
  result := '';

  if not IsSqlAllowed(MetaData, TableName, qtDelete) then
    Exit;

  // verifica sia una Table e non proc o view
  idx := MetaData.Tables.IndexOf(TableName);
  if idx = -1 then
  begin
    // considerare le view con trigger
    idx := MetaData.Views.IndexOf(TableName);
    if idx = -1 then
      Exit
    else
      if not MetaData.Views[idx].HasTriggerDelete then
        Exit;
  end;

  str := TStringList.create;
  try
    str.Clear;
    str.add('DELETE FROM ' + TableName);

    WhereStr := Calc_WhereByKeyFields(MetaData, TableName, PrimaryKeyFields);
    if trim(WhereStr) <> '' then
      str.add(WhereStr);

    result := str.Text;
  finally
    FreeAndNil(str);
  end;

end;

function Get_TableNameFromSQL(MetaData: TzMetaData; Sql: string; var TableName: string; Ask: Boolean = False): Boolean;
var
  TableNames: TStringList;
  i: integer;
begin
  result := False;
  TableName := '';

  if trim(Sql) = '' then
    Exit;

  // if not IsMultiTableQuery(UpperCase(Trim(SQL))) then
  TableName := GetTableNameFromSQL(UpperCase(trim(Sql)));

  if trim(TableName) = '' then
    if Ask then
      if Assigned(MetaData) then
      begin
        TableNames := TStringList.create;
        try
          for i := 0 to MetaData.Tables.Count - 1 do
            TableNames.add(MetaData.Tables[i].Name);
          if not InputCombo('TableName', 'TableName: ', TableName, TableNames) then
            // if not InputCombo('TableName', 'TableName: ', TableNames, TableName, false) then
            Exit;
        finally
          FreeAndNil(TableNames);
        end;
      end;

  TableName := UpperCase(trim(TableName));
  result := TableName <> '';
end;

function Build_FkRelation(MetaData: TzMetaData; SelectSQL: string; TableName, ForeignTable: string): string;
var
  i, idx: integer;
  str: TStringList;
  TableItem: TzmdTable;
  FkItem: TzmdForeignKey;
  OldWhere, NewWhere: string;
  dummy: integer;
  s: string;
  WhereList: TStringList;

  function GetFK(const TableName, ForeignTable: string): TzmdForeignKey;
  var
    i: integer;
    idx: integer;
  begin
    result := nil;

    idx := MetaData.Tables.IndexOf(TableName);
    if idx = -1 then
      Exit;

    TableItem := MetaData.Tables[idx];
    if not Assigned(TableItem) then
      Exit;

    for i := 0 to TableItem.ForeignKeys.Count - 1 do
      if SameText(TableItem.ForeignKeys[i].FkTable, ForeignTable) then
      begin
        result := TableItem.ForeignKeys[i];
        Exit;
      end;
  end;

begin
  result := SelectSQL;

  if not Assigned(MetaData) then
    Exit;

  idx := MetaData.Tables.IndexOf(TableName);
  if idx = -1 then
    Exit;

  FkItem := GetFK(TableName, ForeignTable);

  if not Assigned(FkItem) then
    FkItem := GetFK(ForeignTable, TableName);

  if not Assigned(FkItem) then
    Exit;

  /// /////////////////////////////////////////////////

  str := TStringList.create;
  try
    WhereList := TStringList.create;
    try
      for i := 0 to WhereCount(SelectSQL) do
        WhereList.add(GetWhereClause(SelectSQL, i, dummy, dummy));

      for i := 0 to FkItem.Fields.Count - 1 do
      begin
        s := TableName + '.' + FkItem.Fields[i].Name + ' = :' + FkItem.FkFields[i].Name;
        if WhereList.IndexOf(s) = -1 then
          str.add(s);
      end;
    finally
      FreeAndNil(WhereList);
    end;

    // salvo vecchia where
    OldWhere := trim(MainWhereClause(result));
    // ripulisco
    result := trim(ClearSqlWhere(result));

    // calcolo nuovo pezzo
    for i := 0 to str.Count - 1 do
      result := AddToWhereClause(result, str[i], True);

    if not SameText(OldWhere, MainWhereClause(result)) then
    begin
      // se tutti e due settati ==> newline
      if (str.Count > 0) and (trim(OldWhere) <> '') then
        OldWhere := #13#10 + OldWhere;

      if trim(OldWhere) <> '' then
        result := AddToWhereClause(result, OldWhere, True);

      result := StringReplace(result, #13#10#13#10, #13#10, [rfReplaceAll]);
    end;
  finally
    FreeAndNil(str);
  end;
end;

function GetCountSQL(SelectSQL: string): string;
begin
  result := SqlTxtRtns.CountSelect(SelectSQL);
end;

function GetWhereSQL(SelectSQL: string): string;
begin
  result := SqlTxtRtns.MainWhereClause(SelectSQL);
end;

function GetOrderByPK(MetaData: TzMetaData; TableName: string): string;
var
  str: TStringList;
  i: integer;
begin
  result := '';

  str := TStringList.create;
  try
    Get_KeyFields(MetaData, TableName, str);

    if str.Count = 0 then
      Exit;

    result := 'ORDER BY ';
    for i := 0 to str.Count - 1 do
    begin
      if i <> str.Count - 1 then
        result := result + ' ' + str[i] + ','
      else
        result := result + ' ' + str[i];
    end;

  finally
    FreeAndNil(str);
  end;
end;

end.
