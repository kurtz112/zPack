unit zOffice.Excel.ImportExport;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Variants,
  Data.DB,
  dxSpreadSheet,
  dxSpreadSheetCore,
  dxSpreadSheetTypes,
  dxSpreadSheetFormatXLSX,
  dxSpreadSheetFormatXLS,
  dxSpreadSheetFormatCSV;

type
  /// <summary>
  /// Tipo del dato atteso per ogni colonna importata
  /// </summary>
  TzExcelFieldType = (eftString, eftInteger, eftFloat, eftDate, eftDateTime, eftBoolean);

  /// <summary>
  /// Modalita' di auto-rilevamento colonne quando ColumnMaps e' vuoto
  /// </summary>
  TzAutoDetectMode = (admGuessTypes, // legge header + campiona N righe per indovinare il tipo
    admAllStrings, // legge header, tutte le colonne come eftString
    admFromDataSet, // mappa per nome header -> FieldName del DataSet destinazione
    admNone // nessun auto-detect, ColumnMaps obbligatorio
    );

  /// <summary>
  /// Mapping singola colonna Excel -> campo logico
  /// </summary>
  TzExcelColumnMap = record
    ExcelColIndex: Integer; // indice colonna nel foglio Excel (0-based)
    FieldName: string; // nome logico del campo destinazione
    FieldType: TzExcelFieldType; // tipo atteso
    Required: Boolean; // se True, riga scartata se cella vuota
    DefaultValue: Variant; // valore di default se cella vuota e non Required
    /// <summary>Crea mappatura con Required e DefaultValue espliciti</summary>
    class function Create(AExcelCol: Integer; const AFieldName: string; AFieldType: TzExcelFieldType; ARequired: Boolean; const ADefaultValue: Variant): TzExcelColumnMap; overload; static;
    /// <summary>Crea mappatura non obbligatoria con DefaultValue = Null</summary>
    class function Create(AExcelCol: Integer; const AFieldName: string; AFieldType: TzExcelFieldType; ARequired: Boolean = False): TzExcelColumnMap; overload; static;
  end;

  /// <summary>
  /// Callback opzionale chiamata dopo il build automatico delle ColumnMaps.
  /// Permette al chiamante di rivedere/modificare/filtrare le mappature
  /// prima che inizi l'import. Puo' modificare l'array in-place.
  /// </summary>
  TzHeaderMapProc = reference to procedure(var AMaps: TArray<TzExcelColumnMap>; const AHeaders: TArray<string>);

  /// <summary>
  /// Dizionario FieldName -> Variant per una riga importata
  /// </summary>
  TzExcelRowValues = TDictionary<string, Variant>;

  /// <summary>
  /// Callback per ogni riga importata.
  /// ARowIndex: indice riga nel foglio (0-based, relativo al foglio, non alla StartRow)
  /// AValues: dizionario campo->valore (il chiamante NON deve distruggerlo)
  /// AErrors: eventuali errori di conversione per questa riga
  /// Result: True per continuare, False per interrompere l'import
  /// </summary>
  TzExcelRowProc = reference to function(ARowIndex: Integer; AValues: TzExcelRowValues; const AErrors: TArray<string>): Boolean;

  /// <summary>
  /// Callback di progresso (opzionale)
  /// </summary>
  TzExcelProgressProc = reference to procedure(ACurrent, ATotal: Integer);

  /// <summary>
  /// Opzioni CSV (usate sia in import che in export)
  /// </summary>
  TzCsvOptions = record
    Separator: Char; // separatore valori, default ';' (italiano)
    QuoteChar: Char; // carattere quote, default '"'
    Encoding: TEncoding; // encoding file, default TEncoding.UTF8
    class function Default: TzCsvOptions; static;
  end;

  /// <summary>
  /// Opzioni di importazione (XLS, XLSX, CSV)
  /// </summary>
  TzExcelImportOptions = record
    FileName: string; // percorso file XLS/XLSX/CSV
    SheetIndex: Integer; // indice foglio (0-based), default 0 (ignorato per CSV)
    StartRow: Integer; // riga di partenza dati (0-based), es. 1 per saltare header
    StartCol: Integer; // colonna di partenza (0-based), usata per auto-detect
    ColumnMaps: TArray<TzExcelColumnMap>; // mappatura colonne (vuoto = auto-detect)
    TrimStrings: Boolean; // trim automatico stringhe
    SkipEmptyRows: Boolean; // salta righe completamente vuote
    MaxRows: Integer; // 0 = tutte le righe
    CsvOptions: TzCsvOptions; // opzioni specifiche CSV (ignorate per XLS/XLSX)
    // --- Auto-detect (usato quando ColumnMaps e' vuoto) ---
    AutoDetect: TzAutoDetectMode; // default admAllStrings
    HeaderRow: Integer; // riga contenente gli header (0-based), default 0
    GuessTypeSampleRows: Integer; // numero righe da campionare per admGuessTypes, default 20
    TargetDataSet: TDataSet; // DataSet destinazione per admFromDataSet (opzionale)
    OnHeaderMapped: TzHeaderMapProc; // callback per rivedere le mappature auto-generate
    OnProgress: TzExcelProgressProc;
  end;

  /// <summary>
  /// Opzioni di esportazione (XLS, XLSX, CSV)
  /// </summary>
  TzExcelExportOptions = record
    FileName: string; // percorso file output (estensione determina formato)
    SheetName: string; // nome foglio, default 'Dati' (ignorato per CSV)
    IncludeHeader: Boolean; // scrive riga intestazione con nomi campo
    FieldNames: TArray<string>; // campi da esportare; vuoto = tutti
    FieldCaptions: TArray<string>; // intestazioni personalizzate (parallelo a FieldNames)
    AutoFitColumns: Boolean; // adatta larghezza colonne (ignorato per CSV)
    HeaderBold: Boolean; // intestazione in grassetto (ignorato per CSV)
    FreezeFirstRow: Boolean; // blocca prima riga (ignorato per CSV)
    DateFormat: string; // formato date, default 'dd/mm/yyyy'
    DateTimeFormat: string; // formato datetime, default 'dd/mm/yyyy hh:nn:ss'
    CsvOptions: TzCsvOptions; // opzioni specifiche CSV (ignorate per XLS/XLSX)
    OnProgress: TzExcelProgressProc;
  end;

  TzExcelHelper = class
  private
    class function GetCellValue(AView: TdxSpreadSheetTableView; ARow, ACol: Integer): Variant;
    class function ConvertValue(const AValue: Variant; AFieldType: TzExcelFieldType; out AError: string): Variant;
    class procedure ApplyHeaderStyle(AView: TdxSpreadSheetTableView; AColCount: Integer; ABold: Boolean);
    class procedure SetCellValueFromField(ACell: TdxSpreadSheetCell; AField: TField; const ADateFmt, ADateTimeFmt: string);
    class function IsCSVFile(const AFileName: string): Boolean;
    class procedure ConfigureCSVSettings(const ACsvOpts: TzCsvOptions);
    // Auto-detect colonne
    class function ReadHeaders(AView: TdxSpreadSheetTableView; AHeaderRow, AStartCol: Integer): TArray<string>;
    class function DetectFieldType(AView: TdxSpreadSheetTableView; ACol, AStartDataRow, ASampleRows: Integer): TzExcelFieldType;
    class function NormalizeHeaderToFieldName(const AHeader: string): string;
    class function BuildColumnMapsAuto(AView: TdxSpreadSheetTableView; const AOptions: TzExcelImportOptions; out AHeaders: TArray<string>): TArray<TzExcelColumnMap>;
    // Export CSV diretto (senza TdxSpreadSheet, piu' performante per grandi dataset)
    class function ExportDataSetToCSVDirect(ADataSet: TDataSet; const AOptions: TzExcelExportOptions): Integer;
    class function FieldToCSVString(AField: TField; const ADateFmt, ADateTimeFmt: string): string;
    class function CSVEscape(const AValue: string; ASeparator, AQuoteChar: Char): string;
  public
    /// <summary>
    /// Importa dati da un file Excel o CSV, chiamando ARowProc per ogni riga.
    /// Formati supportati: XLS, XLSX, CSV.
    /// Ritorna il numero di righe processate.
    /// </summary>
    class function ImportFromExcel(const AOptions: TzExcelImportOptions; ARowProc: TzExcelRowProc): Integer;

    /// <summary>
    /// Esporta il contenuto di un DataSet in un file Excel o CSV.
    /// Il formato e' determinato dall'estensione del FileName.
    /// Per CSV: export diretto ad alte prestazioni senza passare per TdxSpreadSheet.
    /// Per XLS/XLSX: usa TdxSpreadSheet con formattazione completa.
    /// Il DataSet deve essere gia' aperto e posizionato.
    /// Ritorna il numero di righe esportate.
    /// </summary>
    class function ExportDataSetToExcel(ADataSet: TDataSet; const AOptions: TzExcelExportOptions): Integer;
  end;

implementation

uses
  System.DateUtils,
  System.Math,
  System.UITypes;

{ TzCsvOptions }

class function TzCsvOptions.Default: TzCsvOptions;
begin
  Result.Separator := ';'; // standard italiano (Excel IT usa ;)
  Result.QuoteChar := '"';
  Result.Encoding := TEncoding.UTF8;
end;

{ TzExcelColumnMap }

class function TzExcelColumnMap.Create(AExcelCol: Integer; const AFieldName: string; AFieldType: TzExcelFieldType; ARequired: Boolean; const ADefaultValue: Variant): TzExcelColumnMap;
begin
  Result.ExcelColIndex := AExcelCol;
  Result.FieldName := AFieldName;
  Result.FieldType := AFieldType;
  Result.Required := ARequired;
  Result.DefaultValue := ADefaultValue;
end;

class function TzExcelColumnMap.Create(AExcelCol: Integer; const AFieldName: string; AFieldType: TzExcelFieldType; ARequired: Boolean): TzExcelColumnMap;
begin
  Result := TzExcelColumnMap.Create(AExcelCol, AFieldName, AFieldType, ARequired, Null);
end;

{ TzExcelHelper - private }

class function TzExcelHelper.IsCSVFile(const AFileName: string): Boolean;
begin
  Result := SameText(ExtractFileExt(AFileName), '.csv');
end;

class procedure TzExcelHelper.ConfigureCSVSettings(const ACsvOpts: TzCsvOptions);
var
  LSettings: TdxSpreadSheetCSVFormatSettings;
begin
  LSettings := dxSpreadSheetCSVFormatSettings;
  LSettings.ValueSeparator := ACsvOpts.Separator;
  LSettings.Quote := ACsvOpts.QuoteChar;
  if ACsvOpts.Encoding <> nil then
    LSettings.Encoding := ACsvOpts.Encoding;
end;

{ --- Auto-detect helpers --- }

class function TzExcelHelper.NormalizeHeaderToFieldName(const AHeader: string): string;
var
  I: Integer;
  C: Char;
begin
  // Converte un header Excel in un nome campo valido:
  // "Data di Nascita" -> "DATA_DI_NASCITA"
  // "Cod.Fiscale"     -> "COD_FISCALE"
  // "  Ore (totali) " -> "ORE__TOTALI_"
  Result := UpperCase(Trim(AHeader));
  for I := 1 to Length(Result) do
  begin
    C := Result[I];
    if not CharInSet(C, ['A' .. 'Z', '0' .. '9', '_']) then
      Result[I] := '_';
  end;
  // Rimuove underscore multipli consecutivi
  while Pos('__', Result) > 0 do
    Result := StringReplace(Result, '__', '_', [rfReplaceAll]);
  // Rimuove underscore iniziali e finali
  Result := Trim(Result);
  while (Result <> '') and (Result[1] = '_') do
    Delete(Result, 1, 1);
  while (Result <> '') and (Result[Length(Result)] = '_') do
    Delete(Result, Length(Result), 1);
end;

class function TzExcelHelper.ReadHeaders(AView: TdxSpreadSheetTableView; AHeaderRow, AStartCol: Integer): TArray<string>;
var
  LCol, LLastCol: Integer;
  LCell: TdxSpreadSheetCell;
  LHeaders: TList<string>;
  LValue: string;
begin
  LHeaders := TList<string>.Create;
  try
    if AView.Dimensions.IsEmpty then
      Exit(nil);

    LLastCol := AView.Dimensions.Left + AView.Dimensions.Width;
    LCol := AStartCol;
    while LCol <= LLastCol do
    begin
      LCell := AView.Cells[AHeaderRow, LCol];
      if (LCell = nil) or LCell.IsEmpty then
      begin
        // Colonna vuota nell'header: interrompe la scansione
        // (evita di prendere colonne spurie a destra)
        Break;
      end;
      LValue := Trim(VarToStr(LCell.AsVariant));
      if LValue = '' then
        Break;
      LHeaders.Add(LValue);
      Inc(LCol);
    end;
    Result := LHeaders.ToArray;
  finally
    LHeaders.Free;
  end;
end;

class function TzExcelHelper.DetectFieldType(AView: TdxSpreadSheetTableView; ACol, AStartDataRow, ASampleRows: Integer): TzExcelFieldType;
var
  LRow, LLastRow, LSampled: Integer;
  LCell: TdxSpreadSheetCell;
  LValue: Variant;
  LStr: string;
  LHasInt, LHasFloat, LHasDate, LHasBool, LHasString: Boolean;
  LIntVal: Int64;
  LFloatVal: Double;
  LDateVal: TDateTime;
begin
  // Campiona fino a ASampleRows righe non vuote per dedurre il tipo
  LHasInt := False;
  LHasFloat := False;
  LHasDate := False;
  LHasBool := False;
  LHasString := False;
  LSampled := 0;

  LLastRow := AView.Dimensions.Top + AView.Dimensions.Height;

  LRow := AStartDataRow;
  while (LRow <= LLastRow) and (LSampled < ASampleRows) do
  begin
    LCell := AView.Cells[LRow, ACol];
    if (LCell <> nil) and (not LCell.IsEmpty) then
    begin
      LValue := LCell.AsVariant;
      if not(VarIsNull(LValue) or VarIsEmpty(LValue)) then
      begin
        Inc(LSampled);

        // Controlla tipo nativo del Variant (XLS/XLSX mantengono i tipi)
        if VarIsType(LValue, varDate) then
          LHasDate := True
        else
          if VarIsType(LValue, [varSmallint, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64]) then
            LHasInt := True
          else
            if VarIsType(LValue, [varSingle, varDouble, varCurrency]) then
              LHasFloat := True
            else
              if VarIsType(LValue, varBoolean) then
                LHasBool := True
              else
              begin
                // E' una stringa: prova a riconoscere il tipo dal contenuto
                LStr := Trim(VarToStr(LValue));
                if LStr = '' then
                  // skip
                else
                  if SameText(LStr, 'TRUE') or SameText(LStr, 'FALSE') or SameText(LStr, 'SI') or SameText(LStr, 'NO') or SameText(LStr, 'VERO') or SameText(LStr, 'FALSO') then
                    LHasBool := True
                  else
                    if TryStrToInt64(LStr, LIntVal) then
                      LHasInt := True
                    else
                      if TryStrToFloat(LStr, LFloatVal) or TryStrToFloat(StringReplace(LStr, ',', '.', []), LFloatVal) then
                        LHasFloat := True
                      else
                        if TryStrToDate(LStr, LDateVal) then
                          LHasDate := True
                        else
                          if TryStrToDateTime(LStr, LDateVal) then
                            LHasDate := True
                          else
                            LHasString := True;
              end;
      end;
    end;
    Inc(LRow);
  end;

  // Logica di decisione (dalla piu' specifica alla piu' generica):
  // Se c'e' anche una sola stringa non riconosciuta -> tutto stringa
  if LHasString then
    Result := eftString
  else
    if LHasBool and not LHasInt and not LHasFloat and not LHasDate then
      Result := eftBoolean
    else
      if LHasDate and not LHasInt and not LHasFloat then
        Result := eftDate
      else
        if LHasFloat or (LHasInt and LHasFloat) then
          Result := eftFloat
        else
          if LHasInt then
            Result := eftInteger
          else
            Result := eftString; // nessun campione o tutto vuoto
end;

class function TzExcelHelper.BuildColumnMapsAuto(AView: TdxSpreadSheetTableView; const AOptions: TzExcelImportOptions; out AHeaders: TArray<string>): TArray<TzExcelColumnMap>;
var
  I: Integer;
  LFieldName: string;
  LFieldType: TzExcelFieldType;
  LMaps: TList<TzExcelColumnMap>;
  LSampleRows: Integer;
  LField: TField;
begin
  Result := nil;
  AHeaders := ReadHeaders(AView, AOptions.HeaderRow, AOptions.StartCol);

  if Length(AHeaders) = 0 then
    raise Exception.Create('Nessuna intestazione trovata nella riga header');

  LSampleRows := AOptions.GuessTypeSampleRows;
  if LSampleRows <= 0 then
    LSampleRows := 20;

  LMaps := TList<TzExcelColumnMap>.Create;
  try
    for I := 0 to High(AHeaders) do
    begin
      LFieldName := NormalizeHeaderToFieldName(AHeaders[I]);
      if LFieldName = '' then
        Continue;

      case AOptions.AutoDetect of
        admAllStrings:
          LFieldType := eftString;

        admGuessTypes:
          LFieldType := DetectFieldType(AView, AOptions.StartCol + I, AOptions.StartRow, LSampleRows);

        admFromDataSet:
          begin
            if AOptions.TargetDataSet = nil then
              raise Exception.Create('admFromDataSet richiede TargetDataSet assegnato');
            // Cerca il campo nel DataSet per nome normalizzato
            LField := AOptions.TargetDataSet.FindField(LFieldName);
            if LField = nil then
            begin
              // Prova anche con il nome header originale
              LField := AOptions.TargetDataSet.FindField(AHeaders[I]);
            end;
            if LField = nil then
            begin
              // Campo non trovato nel DataSet: includi come stringa
              LFieldType := eftString;
            end
            else
            begin
              // Mappa DataType -> TzExcelFieldType
              case LField.DataType of
                ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftShortint, ftByte:
                  LFieldType := eftInteger;
                ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
                  LFieldType := eftFloat;
                ftDate:
                  LFieldType := eftDate;
                ftDateTime, ftTimeStamp, ftTime:
                  LFieldType := eftDateTime;
                ftBoolean:
                  LFieldType := eftBoolean;
              else
                LFieldType := eftString;
              end;
              // Usa il FieldName del dataset (potrebbe differire dalla normalizzazione)
              LFieldName := LField.FieldName;
            end;
          end;
      else
        LFieldType := eftString;
      end;

      LMaps.Add(TzExcelColumnMap.Create(AOptions.StartCol + I, LFieldName, LFieldType));
    end;
    Result := LMaps.ToArray;
  finally
    LMaps.Free;
  end;
end;

class function TzExcelHelper.GetCellValue(AView: TdxSpreadSheetTableView; ARow, ACol: Integer): Variant;
var
  LCell: TdxSpreadSheetCell;
begin
  Result := Null;
  LCell := AView.Cells[ARow, ACol];
  if LCell = nil then
    Exit;

  if LCell.IsEmpty then
    Exit;

  // Prova a restituire il valore tipizzato
  if LCell.AsVariant <> Null then
    Result := LCell.AsVariant;
end;

class function TzExcelHelper.ConvertValue(const AValue: Variant; AFieldType: TzExcelFieldType; out AError: string): Variant;
begin
  AError := '';
  Result := AValue;

  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Exit;

  try
    case AFieldType of
      eftString:
        Result := VarToStr(AValue);
      eftInteger:
        begin
          if VarIsStr(AValue) then
            Result := StrToInt(Trim(VarToStr(AValue)))
          else
            Result := Integer(AValue);
        end;
      eftFloat:
        begin
          if VarIsStr(AValue) then
          begin
            // Gestione separatore decimale (CSV italiano usa virgola)
            var
            S := Trim(VarToStr(AValue));
            S := StringReplace(S, ',', FormatSettings.DecimalSeparator, []);
            Result := StrToFloat(S);
          end
          else
            Result := Double(AValue);
        end;
      eftDate:
        begin
          if VarIsType(AValue, varDate) then
            Result := VarToDateTime(AValue)
          else
            if VarIsStr(AValue) then
              Result := StrToDate(VarToStr(AValue))
            else
              Result := VarToDateTime(AValue);
        end;
      eftDateTime:
        begin
          if VarIsType(AValue, varDate) then
            Result := VarToDateTime(AValue)
          else
            if VarIsStr(AValue) then
              Result := StrToDateTime(VarToStr(AValue))
            else
              Result := VarToDateTime(AValue);
        end;
      eftBoolean:
        begin
          if VarIsStr(AValue) then
          begin
            var
            S := UpperCase(Trim(VarToStr(AValue)));
            Result := (S = 'TRUE') or (S = '1') or (S = 'SI') or (S = 'S') or (S = 'YES') or (S = 'Y') or (S = 'VERO');
          end
          else
            Result := Boolean(AValue);
        end;
    end;
  except
    on E: Exception do
    begin
      AError := E.Message;
      Result := Null;
    end;
  end;
end;

class procedure TzExcelHelper.ApplyHeaderStyle(AView: TdxSpreadSheetTableView; AColCount: Integer; ABold: Boolean);
var
  I: Integer;
  LCell: TdxSpreadSheetCell;
begin
  if not ABold then
    Exit;
  for I := 0 to AColCount - 1 do
  begin
    LCell := AView.Cells[0, I];
    if LCell <> nil then
      LCell.Style.Font.Style := [System.UITypes.TFontStyle.fsBold];
  end;
end;

class procedure TzExcelHelper.SetCellValueFromField(ACell: TdxSpreadSheetCell; AField: TField; const ADateFmt, ADateTimeFmt: string);
begin
  if AField.IsNull then
    Exit;

  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftShortint, ftByte:
      ACell.AsInteger := AField.AsInteger;

    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
      ACell.AsFloat := AField.AsFloat;

    ftDate:
      begin
        ACell.AsDateTime := AField.AsDateTime;
        ACell.Style.DataFormat.FormatCode := ADateFmt;
      end;

    ftDateTime, ftTimeStamp:
      begin
        ACell.AsDateTime := AField.AsDateTime;
        ACell.Style.DataFormat.FormatCode := ADateTimeFmt;
      end;

    ftTime:
      begin
        ACell.AsDateTime := AField.AsDateTime;
        ACell.Style.DataFormat.FormatCode := 'hh:nn:ss';
      end;

    ftBoolean:
      ACell.AsBoolean := AField.AsBoolean;

    ftMemo, ftWideMemo:
      ACell.AsString := AField.AsString;
  else
    // ftString, ftWideString, e tutti gli altri
    ACell.AsString := AField.AsString;
  end;
end;

{ ===== CSV Export helpers ===== }

class function TzExcelHelper.CSVEscape(const AValue: string; ASeparator, AQuoteChar: Char): string;
var
  LNeedsQuote: Boolean;
begin
  // Il valore va quotato se contiene: separatore, quote, CR, LF
  LNeedsQuote := (Pos(ASeparator, AValue) > 0) or (Pos(AQuoteChar, AValue) > 0) or (Pos(#13, AValue) > 0) or (Pos(#10, AValue) > 0);

  if LNeedsQuote then
  begin
    // Raddoppia i quote interni
    Result := AQuoteChar + StringReplace(AValue, AQuoteChar, AQuoteChar + AQuoteChar, [rfReplaceAll]) + AQuoteChar;
  end
  else
    Result := AValue;
end;

class function TzExcelHelper.FieldToCSVString(AField: TField; const ADateFmt, ADateTimeFmt: string): string;
begin
  if AField.IsNull then
  begin
    Result := '';
    Exit;
  end;

  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftShortint, ftByte:
      Result := IntToStr(AField.AsInteger);

    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
      // Usa il punto come separatore decimale per massima compatibilita'
      Result := FloatToStr(AField.AsFloat);

    ftDate:
      Result := FormatDateTime(ADateFmt, AField.AsDateTime);

    ftDateTime, ftTimeStamp:
      Result := FormatDateTime(ADateTimeFmt, AField.AsDateTime);

    ftTime:
      Result := FormatDateTime('hh:nn:ss', AField.AsDateTime);

    ftBoolean:
      if AField.AsBoolean then
        Result := 'TRUE'
      else
        Result := 'FALSE';
  else
    Result := AField.AsString;
  end;
end;

{ ===== IMPORT ===== }

class function TzExcelHelper.ImportFromExcel(const AOptions: TzExcelImportOptions; ARowProc: TzExcelRowProc): Integer;
var
  LSpreadSheet: TdxSpreadSheet;
  LView: TdxSpreadSheetTableView;
  LValues: TzExcelRowValues;
  LRowIndex, LLastRow, LTotalRows: Integer;
  LColMap: TzExcelColumnMap;
  LRawValue, LConvertedValue: Variant;
  LErrors: TList<string>;
  LError: string;
  LAllEmpty, LHasRequiredMissing: Boolean;
  LContinue: Boolean;
  LEffectiveMaps: TArray<TzExcelColumnMap>;
  LAutoHeaders: TArray<string>;
begin
  Result := 0;

  if not FileExists(AOptions.FileName) then
    raise Exception.CreateFmt('File non trovato: %s', [AOptions.FileName]);

  // Per CSV: configura separatore/encoding prima del load
  if IsCSVFile(AOptions.FileName) then
    ConfigureCSVSettings(AOptions.CsvOptions);

  LSpreadSheet := TdxSpreadSheet.Create(nil);
  try
    LSpreadSheet.LoadFromFile(AOptions.FileName);

    // Per CSV c'e' sempre un solo foglio (SheetIndex ignorato)
    // Per XLS/XLSX: verifica foglio richiesto
    if not IsCSVFile(AOptions.FileName) then
    begin
      if AOptions.SheetIndex >= LSpreadSheet.SheetCount then
        raise Exception.CreateFmt('Foglio indice %d non trovato (il file contiene %d fogli)', [AOptions.SheetIndex, LSpreadSheet.SheetCount]);
    end;

    var
    LSheetIdx := AOptions.SheetIndex;
    if IsCSVFile(AOptions.FileName) then
      LSheetIdx := 0;

    if not(LSpreadSheet.Sheets[LSheetIdx] is TdxSpreadSheetTableView) then
      raise Exception.Create('Il foglio selezionato non e'' una TableView');

    LView := LSpreadSheet.Sheets[LSheetIdx] as TdxSpreadSheetTableView;

    if LView.Dimensions.IsEmpty then
      Exit(0);

    // === Risolvi ColumnMaps: esplicite o auto-detect ===
    if Length(AOptions.ColumnMaps) > 0 then
    begin
      // Mappatura esplicita fornita dal chiamante
      LEffectiveMaps := AOptions.ColumnMaps;
    end
    else
    begin
      // Auto-detect: ColumnMaps vuoto
      if AOptions.AutoDetect = admNone then
        raise Exception.Create('ColumnMaps vuoto e AutoDetect = admNone. ' + 'Definire le mappature oppure impostare AutoDetect a ' + 'admAllStrings, admGuessTypes o admFromDataSet.');

      LEffectiveMaps := BuildColumnMapsAuto(LView, AOptions, LAutoHeaders);

      if Length(LEffectiveMaps) = 0 then
        raise Exception.Create('Auto-detect: nessuna colonna trovata nell''header');

      // Callback opzionale per consentire al chiamante di rivedere le mappature
      if Assigned(AOptions.OnHeaderMapped) then
        AOptions.OnHeaderMapped(LEffectiveMaps, LAutoHeaders);

      // Dopo il callback potrebbe essere vuoto (l'utente ha rimosso tutto)
      if Length(LEffectiveMaps) = 0 then
        raise Exception.Create('Auto-detect: nessuna colonna rimasta dopo OnHeaderMapped');
    end;

    if LView.Dimensions.IsEmpty then
      Exit(0);

    // Determina ultima riga con dati
    LLastRow := LView.Dimensions.Top + LView.Dimensions.Height;
    if (AOptions.MaxRows > 0) then
      LLastRow := Min(LLastRow, AOptions.StartRow + AOptions.MaxRows - 1);

    LTotalRows := LLastRow - AOptions.StartRow + 1;

    LValues := TzExcelRowValues.Create;
    LErrors := TList<string>.Create;
    try
      LRowIndex := AOptions.StartRow;
      while LRowIndex <= LLastRow do
      begin
        LValues.Clear;
        LErrors.Clear;
        LAllEmpty := True;
        LHasRequiredMissing := False;

        // Legge ogni colonna mappata
        for LColMap in LEffectiveMaps do
        begin
          LRawValue := GetCellValue(LView, LRowIndex, LColMap.ExcelColIndex);

          // Trim stringhe se richiesto
          if AOptions.TrimStrings and VarIsStr(LRawValue) then
            LRawValue := Trim(VarToStr(LRawValue));

          // Gestione celle vuote
          if VarIsNull(LRawValue) or VarIsEmpty(LRawValue) or (VarIsStr(LRawValue) and (VarToStr(LRawValue) = '')) then
          begin
            if LColMap.Required then
            begin
              LHasRequiredMissing := True;
              LErrors.Add(Format('Campo obbligatorio "%s" vuoto (colonna %d)', [LColMap.FieldName, LColMap.ExcelColIndex]));
              LValues.AddOrSetValue(LColMap.FieldName, Null);
            end
            else
              LValues.AddOrSetValue(LColMap.FieldName, LColMap.DefaultValue);
          end
          else
          begin
            LAllEmpty := False;
            // Conversione tipo
            LConvertedValue := ConvertValue(LRawValue, LColMap.FieldType, LError);
            if LError <> '' then
              LErrors.Add(Format('Campo "%s" (col %d): %s', [LColMap.FieldName, LColMap.ExcelColIndex, LError]));
            LValues.AddOrSetValue(LColMap.FieldName, LConvertedValue);
          end;
        end;

        // Salta righe vuote se richiesto
        if AOptions.SkipEmptyRows and LAllEmpty then
        begin
          Inc(LRowIndex);
          Continue;
        end;

        // Callback progresso
        if Assigned(AOptions.OnProgress) then
          AOptions.OnProgress(Result + 1, LTotalRows);

        // Chiama il metodo anonimo con i dati della riga
        LContinue := ARowProc(LRowIndex, LValues, LErrors.ToArray);
        Inc(Result);

        if not LContinue then
          Break;

        Inc(LRowIndex);
      end;
    finally
      LErrors.Free;
      LValues.Free;
    end;
  finally
    LSpreadSheet.Free;
  end;
end;

{ ===== EXPORT ===== }

class function TzExcelHelper.ExportDataSetToExcel(ADataSet: TDataSet; const AOptions: TzExcelExportOptions): Integer;
var
  SpreadSheet: TdxSpreadSheet;
  View: TdxSpreadSheetTableView;
  Fields: TArray<TField>;
  Captions: TArray<string>;
  Cell: TdxSpreadSheetCell;
  Row, Col, I: Integer;
  SheetName: string;
  DateFmt, DateTimeFmt: string;
begin
  Result := 0;

  if ADataSet = nil then
    raise Exception.Create('DataSet non assegnato');

  if not ADataSet.Active then
    raise Exception.Create('DataSet non attivo');

  if AOptions.FileName = '' then
    raise Exception.Create('FileName non specificato');

  // ====================================================================
  // CSV: export diretto ad alte prestazioni (TStreamWriter, no TdxSpreadSheet)
  // ====================================================================
  if IsCSVFile(AOptions.FileName) then
    Exit(ExportDataSetToCSVDirect(ADataSet, AOptions));

  // ====================================================================
  // XLS / XLSX: export via TdxSpreadSheet con formattazione
  // ====================================================================
  DateFmt := AOptions.DateFormat;

  if DateFmt = '' then
    DateFmt := 'dd/mm/yyyy';

  DateTimeFmt := AOptions.DateTimeFormat;

  if DateTimeFmt = '' then
    DateTimeFmt := 'dd/mm/yyyy hh:nn:ss';

  // Determina i campi da esportare
  if Length(AOptions.FieldNames) > 0 then
  begin
    SetLength(Fields, Length(AOptions.FieldNames));
    SetLength(Captions, Length(AOptions.FieldNames));

    for I := 0 to High(AOptions.FieldNames) do
    begin
      Fields[I] := ADataSet.FieldByName(AOptions.FieldNames[I]);

      if (Length(AOptions.FieldCaptions) > I) and (AOptions.FieldCaptions[I] <> '') then
        Captions[I] := AOptions.FieldCaptions[I]
      else
        if Fields[I].DisplayLabel <> '' then
          Captions[I] := Fields[I].DisplayLabel
        else
          Captions[I] := Fields[I].FieldName;
    end;
  end
  else
  begin
    // Tutti i campi (esclusi blob binari)
    SetLength(Fields, 0);
    SetLength(Captions, 0);

    for I := 0 to ADataSet.FieldCount - 1 do
    begin
      if ADataSet.Fields[I].DataType in [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob, ftOraClob] then
        Continue;

      SetLength(Fields, Length(Fields) + 1);
      SetLength(Captions, Length(Captions) + 1);
      Fields[High(Fields)] := ADataSet.Fields[I];

      if ADataSet.Fields[I].DisplayLabel <> '' then
        Captions[High(Captions)] := ADataSet.Fields[I].DisplayLabel
      else
        Captions[High(Captions)] := ADataSet.Fields[I].FieldName;
    end;
  end;

  if Length(Fields) = 0 then
    raise Exception.Create('Nessun campo da esportare');

  SheetName := AOptions.SheetName;
  if SheetName = '' then
    SheetName := 'Dati';

  SpreadSheet := TdxSpreadSheet.Create(nil);
  try
    SpreadSheet.BeginUpdate;
    try
      // Il foglio di default viene creato automaticamente, rinominiamolo
      if SpreadSheet.SheetCount > 0 then
        SpreadSheet.Sheets[0].Caption := SheetName
      else
        SpreadSheet.AddSheet(SheetName);

      View := SpreadSheet.Sheets[0] as TdxSpreadSheetTableView;
      View.BeginUpdate;
      try
        Row := 0;

        // === Intestazione ===
        if AOptions.IncludeHeader then
        begin
          for Col := 0 to High(Fields) do
          begin
            Cell := View.CreateCell(Row, Col);
            Cell.AsString := Captions[Col];
          end;
          // Stile intestazione
          ApplyHeaderStyle(View, Length(Fields), AOptions.HeaderBold);
          Inc(Row);
        end;

        // === Dati ===
        ADataSet.DisableControls;
        try
          ADataSet.First;
          while not ADataSet.Eof do
          begin
            for Col := 0 to High(Fields) do
            begin
              Cell := View.CreateCell(Row, Col);
              SetCellValueFromField(Cell, Fields[Col], DateFmt, DateTimeFmt);
            end;

            Inc(Result);
            Inc(Row);

            // Callback progresso (ogni 100 righe per non rallentare troppo)
            if Assigned(AOptions.OnProgress) and ((Result mod 100) = 0) then
              AOptions.OnProgress(Result, 0); // Total sconosciuto a priori

            ADataSet.Next;
          end;
        finally
          ADataSet.EnableControls;
        end;

        // === Freeze prima riga ===
        if AOptions.FreezeFirstRow and AOptions.IncludeHeader then
        begin
          View.FrozenRow := 0;
        end;

      finally
        View.EndUpdate;
      end;
    finally
      SpreadSheet.EndUpdate;
    end;

    // Salva nel formato determinato dall'estensione
    SpreadSheet.SaveToFile(AOptions.FileName);

  finally
    SpreadSheet.Free;
  end;
end;

{ ===== CSV Export diretto ===== }

class function TzExcelHelper.ExportDataSetToCSVDirect(ADataSet: TDataSet; const AOptions: TzExcelExportOptions): Integer;
var
  LWriter: TStreamWriter;
  LFields: TArray<TField>;
  LCaptions: TArray<string>;
  LSeparator: Char;
  LQuoteChar: Char;
  LEncoding: TEncoding;
  LDateFmt, LDateTimeFmt: string;
  LLine: TStringBuilder;
  I: Integer;
begin
  Result := 0;

  LSeparator := AOptions.CsvOptions.Separator;
  if LSeparator = #0 then
    LSeparator := ';';
  LQuoteChar := AOptions.CsvOptions.QuoteChar;
  if LQuoteChar = #0 then
    LQuoteChar := '"';
  LEncoding := AOptions.CsvOptions.Encoding;
  if LEncoding = nil then
    LEncoding := TEncoding.UTF8;

  LDateFmt := AOptions.DateFormat;
  if LDateFmt = '' then
    LDateFmt := 'dd/mm/yyyy';
  LDateTimeFmt := AOptions.DateTimeFormat;
  if LDateTimeFmt = '' then
    LDateTimeFmt := 'dd/mm/yyyy hh:nn:ss';

  // Determina campi
  if Length(AOptions.FieldNames) > 0 then
  begin
    SetLength(LFields, Length(AOptions.FieldNames));
    SetLength(LCaptions, Length(AOptions.FieldNames));
    for I := 0 to High(AOptions.FieldNames) do
    begin
      LFields[I] := ADataSet.FieldByName(AOptions.FieldNames[I]);
      if (Length(AOptions.FieldCaptions) > I) and (AOptions.FieldCaptions[I] <> '') then
        LCaptions[I] := AOptions.FieldCaptions[I]
      else
        if LFields[I].DisplayLabel <> '' then
          LCaptions[I] := LFields[I].DisplayLabel
        else
          LCaptions[I] := LFields[I].FieldName;
    end;
  end
  else
  begin
    SetLength(LFields, 0);
    SetLength(LCaptions, 0);
    for I := 0 to ADataSet.FieldCount - 1 do
    begin
      if ADataSet.Fields[I].DataType in [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob, ftOraClob] then
        Continue;
      SetLength(LFields, Length(LFields) + 1);
      SetLength(LCaptions, Length(LCaptions) + 1);
      LFields[High(LFields)] := ADataSet.Fields[I];
      if ADataSet.Fields[I].DisplayLabel <> '' then
        LCaptions[High(LCaptions)] := ADataSet.Fields[I].DisplayLabel
      else
        LCaptions[High(LCaptions)] := ADataSet.Fields[I].FieldName;
    end;
  end;

  if Length(LFields) = 0 then
    raise Exception.Create('Nessun campo da esportare');

  LWriter := TStreamWriter.Create(AOptions.FileName, False, LEncoding);
  try
    LLine := TStringBuilder.Create(4096);
    try
      // === Header ===
      if AOptions.IncludeHeader then
      begin
        LLine.Clear;
        for I := 0 to High(LCaptions) do
        begin
          if I > 0 then
            LLine.Append(LSeparator);
          LLine.Append(CSVEscape(LCaptions[I], LSeparator, LQuoteChar));
        end;
        LWriter.WriteLine(LLine.ToString);
      end;

      // === Dati ===
      ADataSet.DisableControls;
      try
        ADataSet.First;
        while not ADataSet.Eof do
        begin
          LLine.Clear;
          for I := 0 to High(LFields) do
          begin
            if I > 0 then
              LLine.Append(LSeparator);
            LLine.Append(CSVEscape(FieldToCSVString(LFields[I], LDateFmt, LDateTimeFmt), LSeparator, LQuoteChar));
          end;
          LWriter.WriteLine(LLine.ToString);

          Inc(Result);

          // Callback progresso (ogni 500 righe per CSV)
          if Assigned(AOptions.OnProgress) and ((Result mod 500) = 0) then
            AOptions.OnProgress(Result, 0);

          ADataSet.Next;
        end;
      finally
        ADataSet.EnableControls;
      end;
    finally
      LLine.Free;
    end;
  finally
    LWriter.Free;
  end;
end;

end.
