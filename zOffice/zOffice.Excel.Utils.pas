unit zOffice.Excel.Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.Variants,
  Data.DB,
  dxSpreadSheet,
  dxSpreadSheetCore,
  dxSpreadSheetGraphics,
  dxSpreadSheetTypes,
  dxSpreadSheetStyles,
  dxSpreadSheetClasses,
  dxSpreadSheetContainers,
  dxSpreadSheetFormulas,
  dxSpreadSheetCoreFormulas,
  dxSpreadSheetCoreFormulasTokens,
  dxSpreadSheetCoreFormulasParser,
  dxSpreadSheetCoreFormulasHelpers,
  dxSpreadSheetFunctions;

type
  TExcelExportDataSetParams = record
  public
    procedure Init;
    procedure Assign(src: TExcelExportDataSetParams);
  public
    Caption: string;
    startRow: integer;
    startCol: integer;

    RecycleSheet1: boolean;
    ClearCellValues: boolean;
    DeleteAllCells: boolean;
    Header: boolean;
    HeaderBorder: boolean;
    CellBorder: boolean;
    ApplyBestFit: boolean;

    // proc per enumerare i campi
    AllowExportFieldProc: TFunc<TField, boolean>;

    // pre/post export
    BeforeExportDataSetProc: TProc<TdxSpreadSheetTableView, TDataSet>;
    AfterExportDataSetProc: TProc<TdxSpreadSheetTableView, TDataSet>;

    // proc pre/post riga
    BeforeExportRecordProc: TProc<TdxSpreadSheetTableView, TDataSet>;
    AfterExportRecordProc: TProc<TdxSpreadSheetTableView, TDataSet>;
  end;

  TdxSpreadSheetHelper = class helper for TdxSpreadSheet
  public
    procedure SetCellBorder(Style: TdxSpreadSheetCellStyle; cellStyle: TdxSpreadSheetCellBorderStyle = sscbsThin);

    procedure SetText(sheet: TdxSpreadSheetTableView; row, col: integer; s: String; const Border: boolean = false); overload;
    procedure SetText(row, col: integer; s: String; const Border: boolean = false); overload;

    procedure SetFieldValue(sheet: TdxSpreadSheetTableView; row, col: integer; Field: TField; const Border: boolean = false); overload;
    procedure SetFieldValue(sheet: TdxSpreadSheetTableView; area: string; Field: TField; const Border: boolean = false); overload;
    procedure SetFieldValue(cell: TdxSpreadSheetCell; Field: TField; const Border: boolean = false); overload;
    procedure SetFieldValue(cell: TdxSpreadSheetCell; value: string; const Border: boolean = false); overload;

    procedure ExportDataSet(Params: TExcelExportDataSetParams; DataSet: TDataSet; FieldList: TStrings = nil);
    procedure ApplyBestFit;
    procedure ClearActiveSheet;
  end;

var
  CurrentGetVariableFunc: TFunc<string, Variant>;

function SpreadSheetCellDataTypeFromFieldType(FieldType: TFieldType): TdxSpreadSheetCellDataType;

procedure RegisterExcelFuncs;

resourcestring
  stringDataMese = 'DATA.MESE';

implementation

uses
  System.UITypes,
  Vcl.Forms,
  Vcl.Controls,
  dxCore,
  dxSpreadSheetCoreStrs,
  cxGeometry;

resourcestring
  strVariable = 'Variable';

procedure fpiVariable(var AParamCount: integer; var AParamKind: TdxSpreadSheetFunctionParamKindInfo);
begin
  AParamCount := 1;
  SetLength(AParamKind, AParamCount);
  AParamKind[0] := fpkValue;
end;

procedure fnVariable(Sender: TdxSpreadSheetFormulaResult; const AParams: TdxSpreadSheetFormulaToken);
var
  VariableName: string;
  value: Variant;
begin
  if Sender.GetParamsCount(AParams) <> 1 then
    Sender.SetError(ecValue)
  else
  begin
    VariableName := Sender.ExtractStringParameter(AParams);

    if assigned(CurrentGetVariableFunc) then
    begin
      value := CurrentGetVariableFunc(VariableName);

      if not VarIsNull(VariableName) then
        Sender.AddValue(value)
      else
        Sender.SetError(ecValue);
    end
    else
      Sender.SetError(ecValue);
  end;
end;

function SpreadSheetCellDataTypeFromFieldType(FieldType: TFieldType): TdxSpreadSheetCellDataType;
begin
  // cdtBlank, cdtBoolean, cdtError, cdtCurrency, cdtFloat, cdtDateTime, cdtInteger, cdtString, cdtFormula
  result := cdtString;

  case FieldType of
    ftBoolean:
      result := cdtBoolean;
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint:
      result := cdtInteger;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd:
      result := cdtFloat;
    ftDate, ftTime, TFieldType.ftDateTime, ftTimeStamp:
      result := cdtDateTime;
  end;
end;

procedure TExcelExportDataSetParams.Init;
begin
  Caption := '';
  startRow := 0;
  startCol := 0;

  RecycleSheet1 := True;
  ClearCellValues := True;
  DeleteAllCells := false;
  Header := True;
  HeaderBorder := True;
  CellBorder := false;
  ApplyBestFit := True;

  AllowExportFieldProc := nil;
  BeforeExportDataSetProc := nil;
  AfterExportDataSetProc := nil;
  BeforeExportRecordProc := nil;
  AfterExportRecordProc := nil;
end;

procedure TExcelExportDataSetParams.Assign(src: TExcelExportDataSetParams);
begin
  Caption := src.Caption;
  startRow := src.startRow;
  startCol := src.startCol;

  RecycleSheet1 := src.RecycleSheet1;
  ClearCellValues := src.ClearCellValues;
  DeleteAllCells := src.DeleteAllCells;
  Header := src.Header;
  HeaderBorder := src.HeaderBorder;
  CellBorder := src.CellBorder;
  ApplyBestFit := src.ApplyBestFit;

  AllowExportFieldProc := src.AllowExportFieldProc;
  BeforeExportDataSetProc := src.BeforeExportDataSetProc;
  AfterExportDataSetProc := src.AfterExportDataSetProc;
  BeforeExportRecordProc := src.BeforeExportRecordProc;
  AfterExportRecordProc := src.AfterExportRecordProc;
end;

procedure TdxSpreadSheetHelper.ClearActiveSheet;
begin
  if ActiveSheet is TdxSpreadSheetTableView then
    (ActiveSheet as TdxSpreadSheetTableView).DeleteAllCells;
end;

procedure TdxSpreadSheetHelper.SetCellBorder(Style: TdxSpreadSheetCellStyle; cellStyle: TdxSpreadSheetCellBorderStyle);
begin
  assert(assigned(Style));

  // TdxSpreadSheetCellBorderStyle = (sscbsDefault, sscbsHair, sscbsDotted, sscbsDashDotDot, sscbsDashDot, sscbsDashed,
  // sscbsThin, sscbsMediumDashDotDot, sscbsSlantedDashDot, sscbsMediumDashDot, sscbsMediumDashed, sscbsMedium,
  // sscbsThick, sscbsDouble, sscbsNone);

  Style.Borders[bLeft].Style := cellStyle;
  Style.Borders[bTop].Style := cellStyle;
  Style.Borders[bRight].Style := cellStyle;
  Style.Borders[bBottom].Style := cellStyle;

//   Style.Borders[bLeft].Color := TColors.Red;
  // Style.Borders[bTop].Color := TColors.Red;
  // Style.Borders[bRight].Style := cellStyle;
  // Style.Borders[bBottom].Style := cellStyle;
end;

procedure TdxSpreadSheetHelper.SetFieldValue(cell: TdxSpreadSheetCell; value: string; const Border: boolean);
begin
  assert(assigned(cell));

  if value.isEmpty then
    cell.Clear
  else
    cell.AsString := value;

  if Border then
    SetCellBorder(cell.Style, sscbsThin);
end;

procedure TdxSpreadSheetHelper.SetText(row, col: integer; s: String; const Border: boolean = false);
begin
  SetText(ActiveSheetAsTable, row, col, s, Border);
end;

procedure TdxSpreadSheetHelper.SetText(sheet: TdxSpreadSheetTableView; row, col: integer; s: String; const Border: boolean = false);
var
  cell: TdxSpreadSheetCell;
  cellStyle: TdxSpreadSheetCellBorderStyle;
begin
  assert(assigned(sheet));

  cell := sheet.Cells[row, col];

  if not assigned(cell) then
    cell := sheet.CreateCell(row, col);

  // cell.SetText(s);
  cell.AsString := s;

  // cell.Style.Brush.BackgroundColor := TColors.red;

  if Border then
    SetCellBorder(cell.Style, sscbsThin);
end;

procedure TdxSpreadSheetHelper.SetFieldValue(sheet: TdxSpreadSheetTableView; row, col: integer; Field: TField; const Border: boolean = false);
var
  cell: TdxSpreadSheetCell;
  cellStyle: TdxSpreadSheetCellBorderStyle;
begin
  assert(assigned(sheet));
  assert(assigned(Field));

  cell := sheet.Cells[row, col];

  if not assigned(cell) then
    cell := sheet.CreateCell(row, col);

  SetFieldValue(cell, Field, Border);
end;

procedure TdxSpreadSheetHelper.SetFieldValue(sheet: TdxSpreadSheetTableView; area: string; Field: TField; const Border: boolean);
var
  cell: TdxSpreadSheetCell;
  cellStyle: TdxSpreadSheetCellBorderStyle;
begin
  assert(assigned(sheet));
  assert(assigned(Field));

  // cell := sheet.Cells[row, col];
  //
  // if not assigned(cell) then
  // cell := sheet.CreateCell(row, col);
  //
  // SetFieldValue(cell, Field, Border);
end;

procedure TdxSpreadSheetHelper.SetFieldValue(cell: TdxSpreadSheetCell; Field: TField; const Border: boolean);
begin
  assert(assigned(cell));
  assert(assigned(Field));

  if Field.IsNull then
    cell.Clear
  else
  begin

    case SpreadSheetCellDataTypeFromFieldType(Field.dataType) of
      cdtBlank:
        ;
      cdtBoolean:
        cell.AsBoolean := Field.AsBoolean;
      cdtError:
        ;
      cdtCurrency:
        cell.AsCurrency := Field.AsCurrency;
      cdtFloat:
        cell.AsFloat := Field.AsFloat;
      cdtDateTime:
        cell.AsDateTime := Field.AsDateTime;
      cdtInteger:
        cell.AsInteger := Field.AsInteger;
      cdtString:
        if Field.IsBlob then
          cell.AsString := Field.AsString
        else
          cell.AsString := Field.DisplayText;
      cdtFormula:
        ;
    end;
  end;

  // cell.Style.Brush.BackgroundColor := TColor($0000FF);

  if Border then
    SetCellBorder(cell.Style, sscbsThin);
end;

procedure TdxSpreadSheetHelper.ExportDataSet(Params: TExcelExportDataSetParams; DataSet: TDataSet; FieldList: TStrings = nil);
var
  sheet: TdxSpreadSheetTableView;
  oldCursor: TCursor;
  Field: TField;
  row: integer;
  idx: integer;

  function GetSheet: TdxSpreadSheetTableView;
  var
    sheetName: string;
  begin
    result := nil;

    sheetName := Params.Caption;
    if sheetName.isEmpty then
      sheetName := DataSet.Name;

    result := GetSheetByName(sheetName) as TdxSpreadSheetTableView;

    // ricicla un eventuale sheet aggiunto dal builder
    if not assigned(result) then
      if Params.RecycleSheet1 then
        if ActiveSheet <> nil then
          if ActiveSheet.Caption = Format(cxGetResourceString(@sdxDefaultSheetCaption), [1]) then
            result := ActiveSheet as TdxSpreadSheetTableView;

    if not assigned(result) then
      result := AddSheet(sheetName, TdxSpreadSheetTableView) as TdxSpreadSheetTableView;
  end;

  procedure ApplyBestFit;
  var
    i: integer;
  begin

    for i := 0 to sheet.Columns.Count - 1 do
      if sheet.Columns[i] <> nil then
      begin
        try
          sheet.Columns[i].ApplyBestFit;
        except
        end;
      end;
  end;

  function FieldAllowed(Field: TField): boolean;
  begin
    result := True;

    if assigned(FieldList) then
      result := FieldList.IndexOf(Field.FieldName) <> -1;

    if assigned(Params.AllowExportFieldProc) then
      result := Params.AllowExportFieldProc(Field);
  end;

  function FieldIndex(Field: TField): integer;
  begin
    result := Field.Index;

    // se viene passato un sottoinsieme dei campi
    // l'indice sarà quello dell'elenco
    if assigned(FieldList) then
      result := FieldList.IndexOf(Field.FieldName);
  end;

begin
  assert(assigned(DataSet));

  oldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    sheet := GetSheet;

    sheet.BeginUpdate;
    try
      sheet.Caption := Params.Caption;

      if Params.DeleteAllCells then
        sheet.DeleteAllCells
      else
        if Params.ClearCellValues then
        begin
          sheet.Selection.SelectColumns(0, DataSet.Fields.Count);
          sheet.ClearCellValues;
          sheet.Selection.Clear;
        end;

      /// //////////////////////////////////////////////

      DataSet.DisableControls; // vedere, potrebbe influire suli master/detail
      try
        if assigned(Params.BeforeExportDataSetProc) then
          Params.BeforeExportDataSetProc(sheet, DataSet);

        row := Params.startRow;

        if Params.Header then
          for Field in DataSet.Fields do // !
            if FieldAllowed(Field) then
            begin
              idx := FieldIndex(Field);
              SetText(sheet, row, Params.startCol + idx, Field.DisplayLabel, Params.HeaderBorder);
            end;

        DataSet.First;
        while not DataSet.Eof do
        begin
          inc(row);

          if assigned(Params.BeforeExportRecordProc) then
            Params.BeforeExportRecordProc(sheet, DataSet);

          for Field in DataSet.Fields do
            if FieldAllowed(Field) then
            begin
              idx := FieldIndex(Field);
              SetFieldValue(sheet, row, Params.startCol + idx, Field, Params.CellBorder);
            end;

          if assigned(Params.AfterExportRecordProc) then
            Params.AfterExportRecordProc(sheet, DataSet);

          DataSet.Next;
        end;

        if assigned(Params.AfterExportDataSetProc) then
          Params.AfterExportDataSetProc(sheet, DataSet);
      finally
        DataSet.EnableControls;
      end;

      //
      if Params.ApplyBestFit then
        ApplyBestFit;
    finally
      sheet.EndUpdate;
    end;
  finally
    Screen.Cursor := oldCursor;
  end;
end;

procedure TdxSpreadSheetHelper.ApplyBestFit;
var
  i: integer;
begin

  for i := 0 to ActiveSheetAsTable.Columns.Count - 1 do
    ActiveSheetAsTable.Columns[i].ApplyBestFit;
end;

procedure functionDataMese(Sender: TdxSpreadSheetFormulaResult; const AParams: TdxSpreadSheetFormulaToken);
var
  P1, P2: Variant;
  Data: TDateTime;
  mesi: integer;
  i: integer;
  AParameter: Variant;
  s: string;
begin

  if (Sender.GetParamsCount(AParams) <> 2) then
    Sender.SetError(ecValue)
  else
    if (Sender.ExtractDateTimeParameter(P1, AParams) and Sender.ExtractNumericParameter(P2, AParams, 1)) then
    begin
      Data := P1;
      mesi := P2;
      Data.AddMonth(mesi);
      Sender.AddValue(Data.ToString);
    end;
end;

procedure parametersDataMese(var AParamCount: integer; var AParamKind: TdxSpreadSheetFunctionParamKindInfo);
begin
  dxSpreadSheetInitializeParamInfo(2, AParamCount, AParamKind);

  AParamKind[0] := fpkNonRequiredValue;
  AParamKind[1] := fpkNonRequiredValue;
end;

procedure RegisterExcelFuncs;
begin
  // vedere se può essere chiamata da initialization.
  // proviene da X:\Excel_2_AAA\_src\Excel_2_AAA.dproj
  dxSpreadSheetFunctionsRepository.Add(@stringDataMese, functionDataMese, parametersDataMese, frkValue, 2050, ftDateTime);
end;

initialization

CurrentGetVariableFunc := nil;
dxSpreadSheetFunctionsRepository.Add(@strVariable, fnVariable, fpiVariable, frkValue, 2048, ftCommon);

end.

  zOffice.Excel.form
