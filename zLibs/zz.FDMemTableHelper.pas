unit zz.FDMemTableHelper;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TFDMemTableHelper = class Helper for TFDMemTable
  protected
    //
    function InternalSumField(const FieldName: string): double;
  public
    procedure CheckEditMode;
    procedure DeleteAll;
    //
    function SumCurrencyField(const FieldName: string): Currency;
    function SumFloatField(const FieldName: string): Currency;
    function SumIntegerField(const FieldName: string): Currency;
  end;

implementation

{ TFDMemTableHelper }
procedure TFDMemTableHelper.CheckEditMode;
begin
  if Active then
    if not(State in dsEditModes) then
      Edit;
end;

procedure TFDMemTableHelper.DeleteAll;
begin
  Cancel;

  if RecordCount = 0 then
    Exit;

  Last;
  while not BOF do
    Delete;
end;

function TFDMemTableHelper.InternalSumField(const FieldName: string): double;
var
  Clone: TFDMemTable;
  Field: TField;
  i: Integer;
  WasEditing: Boolean;
begin
  result := 0;

  if not Active then
    Exit;

  Field := findfield(FieldName);
  if not Assigned(Field) then
    Exit;

  if not(Field is TNumericField) then
    raise Exception.Create('Il campo ' + FieldName + ' non è di tipo numerico.');

  if (State in dsEditModes) then
  begin
    try
      UpdateRecord;
    except
    end;
    WasEditing := True;
  end
  else
    WasEditing := False;

  // if (RecordCount = 1) and (State = dsInsert) then
  if RecordCount = 1 then
    result := fieldbyname(FieldName).asFloat
  else
  begin
    Clone := TFDMemTable.Create(nil);
    try
      Clone.CloneCursor(Self, False);

      Clone.First;
      while not Clone.EOF do
      begin
        i := Clone.RecNo;

        if (RecNo = Clone.RecNo) and (RecordCount = Clone.RecordCount) then // se in inserimento/modifica non vede il dato corretto
          result := result + Self.fieldbyname(FieldName).asFloat
        else
          result := result + Clone.fieldbyname(FieldName).asFloat;

        Clone.Next;
      end;

      // in certi casi cloneCursor salta il record corrente
      if RecordCount = Clone.RecordCount + 1 then
        result := result + Self.fieldbyname(FieldName).asFloat;

      Clone.Active := False;
    finally
      FreeAndNil(Clone);
    end;
  end;

  if WasEditing then
    CheckEditMode;
end;

function TFDMemTableHelper.SumCurrencyField(const FieldName: string): Currency;
begin
  result := InternalSumField(FieldName);
end;

function TFDMemTableHelper.SumFloatField(const FieldName: string): Currency;
begin
  result := InternalSumField(FieldName);
end;

function TFDMemTableHelper.SumIntegerField(const FieldName: string): Currency;
begin
  result := Trunc(InternalSumField(FieldName));
end;

end.
