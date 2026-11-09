unit SQLParser;

{
  TSQLSelect -> SQL Select statement parser
  By: Kevin Lange
  Created: July 5, 1999
  Current Version: 1.0a

  Version History
  1.0 (July 5, 1999)
  - Created parser
  1.0a (July 13, 1999)
  - Fixed a small alignment bug in the WHERE Clause parser
}

interface

uses
  classes;

type
  TSQLParser = class(TComponent)
  private const
    cSelect = 'SELECT ';
    cFrom = 'FROM ';
    cWhere = 'WHERE ';
    cGroupBy = 'GROUP BY ';
    cHaving = 'HAVING ';
    cOrderBy = 'ORDER BY ';
    cRows = 'ROWS ';
  private
    FSELECT, FFROM, FWHERE, FGROUPBY, FHAVING, FORDERBY, FROWS: string;

    function FindSELECT(SQL: string; var Clause: string): Integer;
    function FindFROM(SQL: string; var Clause: string): Integer;
    function FindWHERE(SQL: string; var Clause: string): Integer;
    function FindGROUPBY(SQL: string; var Clause: string): Integer;
    function FindHAVING(SQL: string; var Clause: string): Integer;
    function FindORDERBY(SQL: string; var Clause: string): Integer;
    function FindROWS(SQL: string; var Clause: string): Integer;
    function BuildSQL: string;
    procedure ParseSQL(SQL: string);
    procedure SetGROUPBY(const Value: string);
    procedure SetHAVING(const Value: string);
    procedure SetORDERBY(const Value: string);
    function TokenValue(Const TokenName: string; const Value: string): string;
    procedure SetWHERE(const Value: string);
  public
    procedure Clear;
    procedure AddWhereCondition(const Condition: string);
  published
    property SQL: string read BuildSQL write ParseSQL;
    property SELECT: string read FSELECT write FSELECT;
    property FROM: string read FFROM write FFROM;
    property WHERE: string read FWHERE write SetWHERE;
    property GROUPBY: string read FGROUPBY write SetGROUPBY;
    property HAVING: string read FHAVING write SetHAVING;
    property ORDERBY: string read FORDERBY write SetORDERBY;
    property ROWS: string read FROWS write FROWS;
  end;

implementation

uses
  Sysutils;

function TSQLParser.BuildSQL;
begin
  Result := Trim(FSELECT) + #13 + Trim(FFROM);
  if Trim(FWHERE) <> '' then
    Result := Result + #13 + Trim(FWHERE);
  if Trim(FGROUPBY) <> '' then
    Result := Result + #13 + Trim(FGROUPBY);
  if Trim(FHAVING) <> '' then
    Result := Result + #13 + Trim(FHAVING);
  if Trim(FORDERBY) <> '' then
    Result := Result + #13 + Trim(FORDERBY);
  if Trim(FROWS) <> '' then
    Result := Result + #13 + Trim(FROWS);
end;

procedure TSQLParser.ParseSQL;
var
  Index: Integer;
begin
  Clear;
  SQL := StringReplace(SQL, #13, ' ', [rfReplaceAll]);
  SQL := StringReplace(SQL, #10, ' ', [rfReplaceAll]);

  Index := FindSELECT(SQL, FSELECT);
  if Index > 0 then
    Delete(SQL, Index, Length(FSELECT));

  Index := FindFROM(SQL, FFROM);
  if Index > 0 then
    Delete(SQL, Index, Length(FFROM));

  Index := FindWHERE(SQL, FWHERE);
  if Index > 0 then
    Delete(SQL, Index, Length(FWHERE));

  Index := FindGROUPBY(SQL, FGROUPBY);
  if Index > 0 then
    Delete(SQL, Index, Length(FGROUPBY));

  Index := FindHAVING(SQL, FHAVING);
  if Index > 0 then
    Delete(SQL, Index, Length(FHAVING));

  Index := FindORDERBY(SQL, FORDERBY);
  if Index > 0 then
    Delete(SQL, Index, Length(FORDERBY));

  Index := FindROWS(SQL, FROWS);
  if Index > 0 then
    Delete(SQL, Index, Length(FROWS));
end;

function TSQLParser.FindSELECT;
var
  Index: Integer;
begin
  Clause := '';
  Result := Pos(cSelect, uppercase(SQL));
  if Result > 0 then
  begin
    // We can cheat a little here, a SELECT is always followed by a FROM
    Index := Pos(cFrom, uppercase(SQL));
    if Index > 0 then
      Clause := Trim(Copy(SQL, Result, Index - Result))
    else
      Clause := Trim(Copy(SQL, Result, Length(SQL) - Result));
  end;
end;

function TSQLParser.FindFROM;
var
  Index: Integer;
begin
  Clause := '';
  Result := Pos(cFrom, uppercase(SQL));
  if Result > 0 then
  begin
    // The FROM can be optionally followed by WHERE, GROUP BY, HAVING, ORDER BY, ROWS
    Index := Pos(cWhere, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cGroupBy, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cHaving, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cOrderBy, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cRows, uppercase(SQL));

    if Index > 0 then
      Clause := Trim(Copy(SQL, Result, Index - Result))
    else
      Clause := Trim(Copy(SQL, Result, Length(SQL) - Result + 1));
  end;
end;

function TSQLParser.FindWHERE;
var
  Index: Integer;
  Difference: Integer;
  Temp: string;

  BracketCount: Integer;
  Counter: Integer;

begin
  Clause := '';
  Result := Pos(cWhere, uppercase(SQL));
  if Result > 0 then
  begin
    // The WHERE can be optionally followed by GROUP BY, HAVING, ORDER BY, ROWS
    // The WHERE can also contain sub-queries

    // Check to see if any sub-queries are present
    Temp := Copy(SQL, Result, Length(SQL) - Result);
    Index := Pos(cSelect, uppercase(Temp));
    Difference := 0;
    if Index > 0 then
    begin
      while Index > 0 do
      begin
        // Match out the brackets
        Delete(Temp, 1, Pos('(', Temp) - 1);
        BracketCount := 0;
        for Counter := 1 to Length(Temp) do
        begin
          if Temp[Counter] = '(' then
            inc(BracketCount);
          if Temp[Counter] = ')' then
            dec(BracketCount);

          if BracketCount = 0 then
            Break;
        end;
        if Counter < Length(Temp) then
          Delete(Temp, 1, Counter);

        // Check to see if any more sub-queries are present
        Index := Pos(cSelect, uppercase(Temp));
      end;

      Difference := Length(SQL) - Length(Temp);
    end;

    Index := Pos(cGroupBy, uppercase(Temp));
    if Index = 0 then
      Index := Pos(cHaving, uppercase(Temp));
    if Index = 0 then
      Index := Pos(cOrderBy, uppercase(Temp));
    if Index = 0 then
      Index := Pos(cRows, uppercase(Temp));

    if Index > 0 then
    begin
      if Difference = 0 then
        Clause := Trim(Copy(SQL, Result, Index - 1))
      else
        Clause := Trim(Copy(SQL, Result, (Index + Difference - 1) - Result));
    end
    else
      Clause := Trim(Copy(SQL, Result, Length(SQL) - Result + 1));
  end;
end;

function TSQLParser.FindGROUPBY;
var
  Index: Integer;
begin
  Clause := '';
  Result := Pos(cGroupBy, uppercase(SQL));
  if Result > 0 then
  begin
    // The GROUP BY can be optionally followed by HAVING, ORDER BY, ROWS

    Index := Pos(cHaving, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cOrderBy, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cRows, uppercase(SQL));

    if Index > 0 then
      Clause := Trim(Copy(SQL, Result, Index - Result))
    else
      Clause := Trim(Copy(SQL, Result, Length(SQL) - Result));
  end;
end;

function TSQLParser.FindHAVING;
var
  Index: Integer;
begin
  Clause := '';
  Result := Pos(cHaving, uppercase(SQL));
  if Result > 0 then
  begin
    // The HAVING can be optionally followed by ORDER BY, ROWS

    Index := Pos(cOrderBy, uppercase(SQL));
    if Index = 0 then
      Index := Pos(cRows, uppercase(SQL));

    if Index > 0 then
      Clause := Trim(Copy(SQL, Result, Index - Result))
    else
      Clause := Trim(Copy(SQL, Result, Length(SQL) - Result));
  end;
end;

function TSQLParser.FindORDERBY;
var
  Index: Integer;
begin
  Clause := '';
  Result := Pos(cOrderBy, uppercase(SQL));
  if Result > 0 then
  begin
    // The ORDER BY can be optionally followed by ROWS

    Index := Pos(cRows, uppercase(SQL));

    if Index > 0 then
      Clause := Trim(Copy(SQL, Result, Index - Result + 1))
    else
      Clause := Trim(Copy(SQL, Result, Length(SQL) - Result + 1));
  end;
end;

function TSQLParser.FindROWS;
begin
  Clause := '';
  Result := Pos(cRows, uppercase(SQL));
  if Result > 0 then
  begin
    // ROWS is always the last statement
    Clause := Trim(Copy(SQL, Result, Length(SQL) - Result + 1));
  end;
end;

procedure TSQLParser.Clear;
begin
  FSELECT := '';
  FFROM := '';
  FWHERE := '';
  FGROUPBY := '';
  FHAVING := '';
  FORDERBY := '';
  FROWS := '';
end;

function TSQLParser.TokenValue(Const TokenName: string; const Value: string): string;
begin
  Result := '';

  if Value.Trim.StartsWith(TokenName) then
    Result := Value
  else
    if Value <> '' then
      Result := TokenName + Value;
end;

procedure TSQLParser.AddWhereCondition(const Condition: string);
begin
  if WHERE = '' then
    FWHERE := TokenValue(cWhere, Condition)
  else
    WHERE := WHERE + ' AND' + #13 + Condition;
end;

procedure TSQLParser.SetWHERE(const Value: string);
begin
  FWHERE := TokenValue(cWhere, Value);
end;

procedure TSQLParser.SetGROUPBY(const Value: string);
begin
  FGROUPBY := TokenValue(cGroupBy, Value);
end;

procedure TSQLParser.SetHAVING(const Value: string);
begin
  FHAVING := TokenValue(cHaving, Value);
end;

procedure TSQLParser.SetORDERBY(const Value: string);
begin
  FORDERBY := TokenValue(cOrderBy, Value);
end;

end.
