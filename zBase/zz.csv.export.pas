unit zz.csv.export;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Data.DB;

type
  TCSVExportOptions = record
    Separator: Char;
    QuoteChar: Char;
    AlwaysQuote: Boolean;
    DateFormat: string;
    DateTimeFormat: string;
    TrimCharFields: Boolean;
    procedure Init;
  end;

  // Ritorna True per continuare, False per interrompere.
  // Riceve solo il numero di record effettivamente elaborati fino a quel momento.
  TProgressCallback = TProc<Int64 { ProcessedRecords } >;

procedure ExportDataSetToCSV(DataSet: TDataSet; const FileName: string; const Options: TCSVExportOptions; const ProcessFieldFunc: TFunc<string, string> = nil; const OnProgress: TProgressCallback = nil; const ProgressStep: Integer = 5000);

implementation

procedure ExportDataSetToCSV(DataSet: TDataSet; const FileName: string; const Options: TCSVExportOptions; const ProcessFieldFunc: TFunc<string, string> = nil; const OnProgress: TProgressCallback = nil; const ProgressStep: Integer = 5000);
const
  BUFFER_SIZE = 1024 * 1024; // 1 MB
var
  StreamWriter: TStreamWriter;
  Folder: string;
  RecordCounter: Int64;
  i, cIdx: Integer;
  Field: TField;
  FieldValue: string;
  RowBuilder: TStringBuilder;
  NeedsQuoting: Boolean;
  C: Char;
begin
  if not Assigned(DataSet) or DataSet.IsEmpty then
    Exit;

  Folder := ExtractFilePath(FileName);
  if Folder <> '' then
    ForceDirectories(Folder);

  RowBuilder := TStringBuilder.Create(65536); // Allocazione iniziale per evitare resize a runtime
  StreamWriter := TStreamWriter.Create(FileName, False, TEncoding.UTF8, BUFFER_SIZE);
  try
    StreamWriter.NewLine := #13#10; // Standard Windows CRLF
    RecordCounter := 0;
    DataSet.First;

    DataSet.DisableControls;
    try
      while not DataSet.Eof do
      begin
        Inc(RecordCounter);

        // Chiamata alla callback ESCLUSIVAMENTE ogni ProgressStep
        if Assigned(OnProgress) and ((RecordCounter mod ProgressStep) = 0) then
          OnProgress(RecordCounter);

        RowBuilder.Clear;

        for i := 0 to DataSet.FieldCount - 1 do
        begin
          if i > 0 then
            RowBuilder.Append(Options.Separator);

          Field := DataSet.Fields[i];
          FieldValue := '';

          if not Field.IsNull then
          begin
            case Field.DataType of
              ftDate:
                if Options.DateFormat <> '' then
                  FieldValue := FormatDateTime(Options.DateFormat, Field.AsDateTime)
                else
                  FieldValue := Field.AsString;

              ftDateTime, ftTimeStamp:
                if Options.DateTimeFormat <> '' then
                  FieldValue := FormatDateTime(Options.DateTimeFormat, Field.AsDateTime)
                else
                  FieldValue := Field.AsString;
            else
              FieldValue := Field.AsString;
            end;

            if Options.TrimCharFields and (Field.DataType in [ftString, ftWideString, ftFixedChar, ftFixedWideChar]) then
              FieldValue := Trim(FieldValue);
          end;

          if Assigned(ProcessFieldFunc) then
            FieldValue := ProcessFieldFunc(FieldValue);

          // Verifica se la stringa necessita di quoting
          NeedsQuoting := Options.AlwaysQuote or (Field.DataType in [ftString, ftWideString, ftMemo, ftWideMemo]);

          if not NeedsQuoting and (FieldValue <> '') then
          begin
            for cIdx := 1 to Length(FieldValue) do
            begin
              C := FieldValue[cIdx];
              if (C = Options.Separator) or (C = Options.QuoteChar) or (C = #10) or (C = #13) then
              begin
                NeedsQuoting := True;
                Break;
              end;
            end;
          end;

          // Gestione dell'escaping del carattere di Quote senza StringReplace
          if NeedsQuoting then
          begin
            RowBuilder.Append(Options.QuoteChar);
            for cIdx := 1 to Length(FieldValue) do
            begin
              C := FieldValue[cIdx];
              RowBuilder.Append(C);
              if C = Options.QuoteChar then
                RowBuilder.Append(Options.QuoteChar);
            end;
            RowBuilder.Append(Options.QuoteChar);
          end
          else
          begin
            RowBuilder.Append(FieldValue);
          end;
        end;

        StreamWriter.WriteLine(RowBuilder.ToString);
        DataSet.Next;
      end;
    finally
      DataSet.EnableControls;
    end;
  finally
    StreamWriter.Free;
    RowBuilder.Free;
  end;
end;

{ TCSVExportOptions }

procedure TCSVExportOptions.Init;
begin
  Separator := ';';
  QuoteChar := '"';
  AlwaysQuote := False;
  DateFormat := '';
  DateTimeFormat := '';
  TrimCharFields := False;
end;

end.
