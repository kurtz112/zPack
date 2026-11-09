unit zExcelHelper_Esempio;

{ ============================================================================
  ESEMPI DI UTILIZZO DI TzExcelHelper
  ============================================================================
  Questo file NON e' una unit compilabile, e' solo una raccolta di esempi.
  ============================================================================ }

interface

implementation

uses
  System.SysUtils, System.Variants, Data.DB, FireDAC.Comp.Client,
  Vcl.Dialogs,
  zExcelHelper;

{ ============================================================================
  ESEMPIO 1: IMPORTAZIONE XLSX con mappatura colonne
  ============================================================================
  Scenario: file Excel con colonne:
    A(0): Cognome
    B(1): Nome
    C(2): Data Nascita
    D(3): Codice Fiscale
    E(4): Ore
  Header in riga 0, dati a partire da riga 1.
  ============================================================================ }

procedure EsempioImportXLSX;
var
  LOptions: TzExcelImportOptions;
  LRowsProcessed: Integer;
  LRowsImported: Integer;
  LRowsErrore: Integer;
begin
  LRowsImported := 0;
  LRowsErrore := 0;

  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := 'C:\Dati\Elenco_Allievi.xlsx';
  LOptions.SheetIndex := 0;     // primo foglio
  LOptions.StartRow := 1;       // salta header in riga 0
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;

  // Mappatura: indice colonna Excel -> nome campo logico -> tipo
  LOptions.ColumnMaps := [
    TzExcelColumnMap.Create(0, 'COGNOME',         eftString,   True),
    TzExcelColumnMap.Create(1, 'NOME',            eftString,   True),
    TzExcelColumnMap.Create(2, 'DATA_NASCITA',    eftDate,     False),
    TzExcelColumnMap.Create(3, 'CODICE_FISCALE',  eftString,   True),
    TzExcelColumnMap.Create(4, 'ORE',             eftFloat,    False, 0.0)
  ];

  LOptions.OnProgress := procedure(ACurrent, ATotal: Integer)
  begin
    // ProgressBar1.Position := Round(ACurrent / ATotal * 100);
  end;

  LRowsProcessed := TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    var
      LCognome, LNome, LCF: string;
      LDataNascita: TDateTime;
      LOre: Double;
    begin
      Result := True; // continua con la prossima riga

      if Length(AErrors) > 0 then
      begin
        Inc(LRowsErrore);
        Exit;
      end;

      LCognome := AValues['COGNOME'];
      LNome := AValues['NOME'];
      LCF := AValues['CODICE_FISCALE'];

      if not VarIsNull(AValues['DATA_NASCITA']) then
        LDataNascita := AValues['DATA_NASCITA']
      else
        LDataNascita := 0;

      LOre := AValues['ORE']; // ha DefaultValue = 0.0

      // Qui: insert in DB, validazione, ecc.
      Inc(LRowsImported);
    end
  );

  ShowMessageFmt('Importazione completata.'#13#10 +
    'Righe lette: %d'#13#10 +
    'Righe importate: %d'#13#10 +
    'Righe con errori: %d',
    [LRowsProcessed, LRowsImported, LRowsErrore]);
end;


{ ============================================================================
  ESEMPIO 2: IMPORTAZIONE CSV con separatore punto-e-virgola (italiano)
  ============================================================================
  Scenario: file CSV esportato da software italiano, es:
    COGNOME;NOME;DATA_NASCITA;CF;ORE
    Rossi;Mario;01/01/1990;RSSMRA90A01H501Z;120,5
    Bianchi;Lucia;15/06/1985;BNCLCU85H55A001K;80
  ============================================================================ }

procedure EsempioImportCSV;
var
  LOptions: TzExcelImportOptions;
  LCount: Integer;
begin
  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := 'C:\Dati\Elenco_Allievi.csv';
  LOptions.StartRow := 1;        // salta header
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;

  // Configurazione CSV: separatore italiano, UTF-8
  LOptions.CsvOptions := TzCsvOptions.Default; // ';', '"', UTF8
  // Oppure personalizza:
  // LOptions.CsvOptions.Separator := ',';           // se il CSV usa virgola
  // LOptions.CsvOptions.Encoding := TEncoding.ANSI; // se il file non e' UTF-8

  LOptions.ColumnMaps := [
    TzExcelColumnMap.Create(0, 'COGNOME',         eftString,   True),
    TzExcelColumnMap.Create(1, 'NOME',            eftString,   True),
    TzExcelColumnMap.Create(2, 'DATA_NASCITA',    eftDate,     False),
    TzExcelColumnMap.Create(3, 'CODICE_FISCALE',  eftString,   True),
    TzExcelColumnMap.Create(4, 'ORE',             eftFloat,    False, 0.0)
  ];

  // NOTA: la conversione eftFloat gestisce automaticamente
  // la virgola come separatore decimale (es. "120,5" -> 120.5)

  LCount := TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    begin
      Result := True;
      if Length(AErrors) > 0 then
        Exit;

      // AValues['COGNOME'], AValues['ORE'] ecc. pronti all'uso
      // Insert in Firebird, validazione, ecc.
    end
  );

  ShowMessageFmt('Importate %d righe dal CSV', [LCount]);
end;


{ ============================================================================
  ESEMPIO 3: IMPORTAZIONE CSV con separatore virgola e encoding ANSI
  ============================================================================ }

procedure EsempioImportCSV_Comma;
var
  LOptions: TzExcelImportOptions;
begin
  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := 'C:\Dati\export_gestionale.csv';
  LOptions.StartRow := 1;
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;

  // CSV con virgola e ANSI (tipico export da software vecchi)
  LOptions.CsvOptions.Separator := ',';
  LOptions.CsvOptions.QuoteChar := '"';
  LOptions.CsvOptions.Encoding := TEncoding.ANSI;

  LOptions.ColumnMaps := [
    TzExcelColumnMap.Create(0, 'CODICE',      eftString,  True),
    TzExcelColumnMap.Create(1, 'DESCRIZIONE', eftString,  True),
    TzExcelColumnMap.Create(2, 'IMPORTO',     eftFloat,   True),
    TzExcelColumnMap.Create(3, 'ATTIVO',      eftBoolean, False, True)
    // eftBoolean riconosce: TRUE/FALSE, 1/0, SI/NO, S/N, YES/NO, Y/N, VERO/FALSO
  ];

  TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    begin
      Result := True;
      // ...
    end
  );
end;


{ ============================================================================
  ESEMPIO 4: ESPORTAZIONE DataSet -> XLSX
  ============================================================================ }

procedure EsempioExportXLSX(AQuery: TFDQuery);
var
  LOptions: TzExcelExportOptions;
  LRowCount: Integer;
begin
  LOptions := Default(TzExcelExportOptions);
  LOptions.FileName := 'C:\Output\Elenco_Allievi.xlsx';
  LOptions.SheetName := 'Allievi';
  LOptions.IncludeHeader := True;
  LOptions.HeaderBold := True;
  LOptions.FreezeFirstRow := True;
  LOptions.DateFormat := 'dd/mm/yyyy';

  LOptions.FieldNames := ['COGNOME', 'NOME', 'DATA_NASCITA', 'CF', 'ORE_TOTALI'];
  LOptions.FieldCaptions := ['Cognome', 'Nome', 'Data di Nascita', 'Cod.Fiscale', 'Ore'];

  LRowCount := TzExcelHelper.ExportDataSetToExcel(AQuery, LOptions);
  ShowMessageFmt('Esportate %d righe in %s', [LRowCount, LOptions.FileName]);
end;


{ ============================================================================
  ESEMPIO 5: ESPORTAZIONE DataSet -> CSV
  ============================================================================
  L'export CSV usa TStreamWriter direttamente (NON passa per TdxSpreadSheet),
  quindi e' molto piu' veloce per dataset grandi (10k+ righe).
  ============================================================================ }

procedure EsempioExportCSV(AQuery: TFDQuery);
var
  LOptions: TzExcelExportOptions;
  LRowCount: Integer;
begin
  LOptions := Default(TzExcelExportOptions);
  LOptions.FileName := 'C:\Output\Elenco_Allievi.csv'; // <-- .csv!
  LOptions.IncludeHeader := True;
  LOptions.DateFormat := 'dd/mm/yyyy';

  // Configurazione CSV
  LOptions.CsvOptions := TzCsvOptions.Default; // ';', '"', UTF8

  // Campi specifici con intestazioni personalizzate
  LOptions.FieldNames := ['COGNOME', 'NOME', 'DATA_NASCITA', 'CF', 'ORE_TOTALI'];
  LOptions.FieldCaptions := ['Cognome', 'Nome', 'Data di Nascita', 'Cod.Fiscale', 'Ore'];

  LOptions.OnProgress := procedure(ACurrent, ATotal: Integer)
  begin
    // StatusBar1.SimpleText := Format('Esportazione CSV: %d righe...', [ACurrent]);
    // Application.ProcessMessages;
  end;

  LRowCount := TzExcelHelper.ExportDataSetToExcel(AQuery, LOptions);
  ShowMessageFmt('Esportate %d righe in CSV', [LRowCount]);
end;


{ ============================================================================
  ESEMPIO 6: ESPORTAZIONE CSV con virgola (formato internazionale)
  ============================================================================ }

procedure EsempioExportCSV_Internazionale(AQuery: TFDQuery);
var
  LOptions: TzExcelExportOptions;
begin
  LOptions := Default(TzExcelExportOptions);
  LOptions.FileName := 'C:\Output\Export_International.csv';
  LOptions.IncludeHeader := True;

  // CSV internazionale: virgola, UTF-8 con BOM
  LOptions.CsvOptions.Separator := ',';
  LOptions.CsvOptions.QuoteChar := '"';
  LOptions.CsvOptions.Encoding := TEncoding.UTF8;

  // Tutti i campi (FieldNames vuoto)
  TzExcelHelper.ExportDataSetToExcel(AQuery, LOptions);
end;


{ ============================================================================
  ESEMPIO 7: ESPORTAZIONE rapida tutti i campi -> tutti i formati
  ============================================================================
  Il formato e' determinato solo dall'estensione!
  ============================================================================ }

procedure EsempioExportMultiFormato(AQuery: TFDQuery);
var
  LOptions: TzExcelExportOptions;
begin
  LOptions := Default(TzExcelExportOptions);
  LOptions.IncludeHeader := True;
  LOptions.HeaderBold := True;       // ignorato per CSV
  LOptions.FreezeFirstRow := True;   // ignorato per CSV
  LOptions.CsvOptions := TzCsvOptions.Default;

  // Stesso dataset, 3 formati diversi:
  LOptions.FileName := 'C:\Output\Report.xlsx';
  TzExcelHelper.ExportDataSetToExcel(AQuery, LOptions);

  LOptions.FileName := 'C:\Output\Report.xls';
  TzExcelHelper.ExportDataSetToExcel(AQuery, LOptions);

  LOptions.FileName := 'C:\Output\Report.csv';
  TzExcelHelper.ExportDataSetToExcel(AQuery, LOptions);
end;


{ ============================================================================
  ESEMPIO 8: IMPORTAZIONE "universale" - stesso codice per XLS/XLSX/CSV
  ============================================================================
  ImportFromExcel accetta qualsiasi formato. Il chiamante non deve
  distinguere: basta passare il FileName con l'estensione corretta.
  ============================================================================ }

procedure EsempioImportUniversale(const AFileName: string);
var
  LOptions: TzExcelImportOptions;
begin
  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := AFileName;    // puo' essere .xls, .xlsx, o .csv
  LOptions.StartRow := 1;
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;
  LOptions.CsvOptions := TzCsvOptions.Default;  // usato solo se .csv

  LOptions.ColumnMaps := [
    TzExcelColumnMap.Create(0, 'CAMPO_A', eftString,  True),
    TzExcelColumnMap.Create(1, 'CAMPO_B', eftFloat,   False, 0.0),
    TzExcelColumnMap.Create(2, 'CAMPO_C', eftDate,    False)
  ];

  TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    begin
      Result := True;
      // La logica e' identica indipendentemente dal formato sorgente
    end
  );
end;


{ ============================================================================
  ESEMPIO 9: IMPORT AUTO-DETECT - tutte le colonne come stringhe
  ============================================================================
  Scenario: non conosci la struttura del file Excel/CSV.
  Basta indicare che la riga 0 contiene gli header.
  Ogni colonna trovata diventa un FieldName derivato dall'header:
    "Cognome"        -> COGNOME
    "Data di Nascita" -> DATA_DI_NASCITA
    "Cod.Fiscale"    -> COD_FISCALE
  Tutti i valori arrivano come stringa (eftString).
  ============================================================================ }

procedure EsempioImportAutoStrings;
var
  LOptions: TzExcelImportOptions;
begin
  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := 'C:\Dati\FileIgnoto.xlsx';
  LOptions.HeaderRow := 0;       // riga con le intestazioni
  LOptions.StartRow := 1;        // dati dalla riga 1
  LOptions.StartCol := 0;        // colonna di partenza
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;

  // NESSUN ColumnMaps! -> auto-detect
  LOptions.AutoDetect := admAllStrings;

  TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    var
      LPair: TPair<string, Variant>;
    begin
      Result := True;

      // Itera su tutti i campi trovati dinamicamente
      for LPair in AValues do
      begin
        // LPair.Key   = nome campo derivato dall'header (es. 'COGNOME')
        // LPair.Value = valore come stringa
        // Logga, inserisci in DB, ecc.
      end;

      // Oppure accedi per nome se conosci almeno alcuni header:
      // if AValues.ContainsKey('COGNOME') then
      //   ShowMessage(AValues['COGNOME']);
    end
  );
end;


{ ============================================================================
  ESEMPIO 10: IMPORT AUTO-DETECT con riconoscimento tipi
  ============================================================================
  admGuessTypes campiona le prime N righe e deduce il tipo:
    - colonna con "Rossi", "Bianchi" -> eftString
    - colonna con 120, 85, 200       -> eftInteger
    - colonna con 120.5, 85.3        -> eftFloat
    - colonna con 01/01/1990         -> eftDate
    - colonna con TRUE/FALSE/SI/NO   -> eftBoolean
  ============================================================================ }

procedure EsempioImportAutoGuessTypes;
var
  LOptions: TzExcelImportOptions;
begin
  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := 'C:\Dati\Report_Sconosciuto.csv';
  LOptions.HeaderRow := 0;
  LOptions.StartRow := 1;
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;
  LOptions.CsvOptions := TzCsvOptions.Default;

  LOptions.AutoDetect := admGuessTypes;
  LOptions.GuessTypeSampleRows := 30;  // campiona 30 righe (default 20)

  // Callback opzionale: ispeziona/modifica le mappature auto-generate
  LOptions.OnHeaderMapped :=
    procedure(var AMaps: TArray<TzExcelColumnMap>; const AHeaders: TArray<string>)
    var
      I: Integer;
    begin
      // Esempio: log delle mappature trovate
      for I := 0 to High(AMaps) do
      begin
        // SiMain.LogMessage('Colonna %d: header="%s" -> campo=%s tipo=%d',
        //   [AMaps[I].ExcelColIndex, AHeaders[I], AMaps[I].FieldName, Ord(AMaps[I].FieldType)]);
      end;

      // Esempio: forza un campo specifico se riconosciuto
      for I := 0 to High(AMaps) do
      begin
        if AMaps[I].FieldName = 'CODICE_FISCALE' then
          AMaps[I].Required := True;  // rendilo obbligatorio
      end;
    end;

  TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    begin
      Result := True;
      if Length(AErrors) > 0 then
        Exit;
      // I valori arrivano gia' convertiti nel tipo dedotto:
      // AValues['ORE'] sara' un Variant di tipo Integer o Float, non stringa
    end
  );
end;


{ ============================================================================
  ESEMPIO 11: IMPORT AUTO-DETECT da DataSet (admFromDataSet)
  ============================================================================
  Scenario: hai una tabella Firebird ALLIEVI con campi:
    COGNOME (VARCHAR), NOME (VARCHAR), DATA_NASCITA (DATE),
    CF (VARCHAR), ORE_TOTALI (NUMERIC)
  Il file Excel ha header "Cognome", "Nome", "Data di Nascita", "CF", "Ore Totali".
  admFromDataSet mappa automaticamente per nome:
    "Cognome"         -> normalizzato "COGNOME"        -> trova ALLIEVI.COGNOME (String)
    "Data di Nascita" -> normalizzato "DATA_DI_NASCITA" -> non trovato -> prova header
                         originale "Data di Nascita" -> non trovato -> eftString
    "CF"              -> normalizzato "CF"             -> trova ALLIEVI.CF (String)
    "Ore Totali"      -> normalizzato "ORE_TOTALI"     -> trova ALLIEVI.ORE_TOTALI (Float)
  Per il campo "Data di Nascita" che non matcha, usi OnHeaderMapped per sistemarlo.
  ============================================================================ }

procedure EsempioImportFromDataSet(ATargetQuery: TFDQuery);
var
  LOptions: TzExcelImportOptions;
begin
  // ATargetQuery deve essere aperto (o almeno avere i FieldDefs preparati)
  // ATargetQuery.SQL.Text := 'SELECT * FROM ALLIEVI WHERE 1=0';
  // ATargetQuery.Open;

  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := 'C:\Dati\Import_Allievi.xlsx';
  LOptions.HeaderRow := 0;
  LOptions.StartRow := 1;
  LOptions.TrimStrings := True;
  LOptions.SkipEmptyRows := True;

  LOptions.AutoDetect := admFromDataSet;
  LOptions.TargetDataSet := ATargetQuery;

  // Aggiusta le mappature che non matchano per nome
  LOptions.OnHeaderMapped :=
    procedure(var AMaps: TArray<TzExcelColumnMap>; const AHeaders: TArray<string>)
    var
      I: Integer;
    begin
      for I := 0 to High(AMaps) do
      begin
        // Rinomina "DATA_DI_NASCITA" -> "DATA_NASCITA" per matchare il campo DB
        if AMaps[I].FieldName = 'DATA_DI_NASCITA' then
        begin
          AMaps[I].FieldName := 'DATA_NASCITA';
          AMaps[I].FieldType := eftDate;
        end;
      end;
    end;

  TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    begin
      Result := True;
      if Length(AErrors) > 0 then
        Exit;

      // I FieldName e i tipi sono gia' allineati al DataSet:
      // AValues['COGNOME']    -> string
      // AValues['ORE_TOTALI'] -> float (tipo dedotto dal campo Firebird)
      // AValues['DATA_NASCITA'] -> date (corretto via OnHeaderMapped)

      // Insert diretto:
      // ATargetQuery.Append;
      // for LPair in AValues do
      //   ATargetQuery.FieldByName(LPair.Key).Value := LPair.Value;
      // ATargetQuery.Post;
    end
  );
end;


{ ============================================================================
  ESEMPIO 12: IMPORT zero-config (minimo assoluto)
  ============================================================================
  Per quando vuoi solo leggere cosa c'e' dentro un file senza sapere nulla.
  Due righe di setup, tutto automatico.
  ============================================================================ }

procedure EsempioImportZeroConfig(const AFileName: string);
var
  LOptions: TzExcelImportOptions;
begin
  LOptions := Default(TzExcelImportOptions);
  LOptions.FileName := AFileName;
  LOptions.StartRow := 1;
  LOptions.AutoDetect := admAllStrings;
  LOptions.CsvOptions := TzCsvOptions.Default;

  TzExcelHelper.ImportFromExcel(LOptions,
    function(ARowIndex: Integer; AValues: TzExcelRowValues;
      const AErrors: TArray<string>): Boolean
    var
      LPair: TPair<string, Variant>;
    begin
      Result := True;
      for LPair in AValues do
        WriteLn(Format('  %s = %s', [LPair.Key, VarToStr(LPair.Value)]));
    end
  );
end;

end.
