unit zz.db;

interface

uses
  Data.DB,
  FireDAC.Stan.Param;

procedure ReOpen(DataSet: TDataSet);
procedure Sync(DataSet: TDataSet; const RecNo: integer);

procedure SetFieldValue(Field: TField; const Value: string); overload;
procedure SetFieldValue(Field: TField; const Value: integer); overload;
procedure SetFieldValue(Field: TField; const Value: double); overload;

procedure SetParamValue(Param: TFDParam; const Value: string); overload;
procedure SetParamValue(Param: TFDParam; const Value: integer); overload;
procedure SetParamValue(Param: TFDParam; const Value: double); overload;

implementation

procedure ReOpen(DataSet: TDataSet);
var
  RecNo: integer;
begin
  Assert(Assigned(DataSet));

  if DataSet.Active then
    RecNo := DataSet.RecNo
  else
    RecNo := -1;

  DataSet.Active := False;
  DataSet.Active := True;

  if RecNo <> -1 then
    Sync(DataSet, RecNo);
end;

procedure Sync(DataSet: TDataSet; const RecNo: integer);
begin
  Assert(Assigned(DataSet));

  if RecNo > 0 then
    if DataSet.Active then
      if DataSet.RecNo <> RecNo then
        DataSet.RecNo := RecNo;
end;

procedure SetFieldValue(Field: TField; const Value: string); overload;
begin
  Assert(Assigned(Field));

  if Value = '' then
    Field.Clear
  else
    Field.Value := Value;
end;

procedure SetFieldValue(Field: TField; const Value: integer); overload;
begin
  Assert(Assigned(Field));

  if Value = 0 then
    Field.Clear
  else
    Field.Value := Value;
end;

procedure SetFieldValue(Field: TField; const Value: double); overload;
begin
  Assert(Assigned(Field));

  if Value = 0 then
    Field.Clear
  else
    Field.Value := Value;
end;

procedure SetParamValue(Param: TFDParam; const Value: string); overload;
begin
  Assert(Assigned(Param));

  if Value = '' then
    Param.Clear
  else
    Param.Value := Value;
end;

procedure SetParamValue(Param: TFDParam; const Value: integer); overload;
begin
  Assert(Assigned(Param));

  if Value = 0 then
    Param.Clear
  else
    Param.Value := Value;
end;

procedure SetParamValue(Param: TFDParam; const Value: double); overload;
begin
  Assert(Assigned(Param));

  if Value = 0 then
    Param.Clear
  else
    Param.Value := Value;
end;

end.
