unit zOffice.Reports.JsonConfig;

// PROPOSTA - Mantis #90 - 2026-09-05: versione modificata per la preanalisi.
// Base: zPack\zOffice\zOffice.Reports.JsonConfig.pas
// Non sostituisce il file sorgente (di sola lettura): va confrontata e
// riportata a mano nel repository dopo revisione in RAD Studio.
//
// Modifica: TzReportJsonConfigContext guadagna TipoDocumento/TipoAllegato,
// lette dalle nuove chiavi JSON "tipoDocumento"/"tipoAllegato" con lo stesso
// trattamento di "profilo"/"tipologiaDocumentale". Nessuna dipendenza
// applicativa aggiunta: sono stringhe neutre, non interpretate qui.

{
  TzReportJsonLoader
  ------------------
  Parsing del file JSON sidecar associato a un report.

  TzReportJsonConfigContext contiene SOLO tipi primitivi e record propri
  (nessun riferimento a TWordParams, TExcelParams, TzFastReportParams).
  È il manager che legge il context e lo applica ai suoi params.

  Posizioni cercate (in ordine):
  <reportname>.<ext>.json     es. Stampa.fr3.json
  <reportname>.json           es. Stampa.json
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  zOffice.Reports.types,
  zOffice.Reports.JSON, // TzJsonReportParams, TzWordFragment
  zFileSystem;

type
  // ------------------------------------------------------------------
  // Record neutrali per i dati PDF, Word, Excel, FastReport estratti
  // dal JSON. Non dipendono da TWordParams/TExcelParams/ecc.
  // ------------------------------------------------------------------

  TzJsonPdfConfig = record
    MethodStr: string; // 'dialog' | 'filename' | 'fieldname' | 'tempfile'
    FileName: string;
    FieldName: string;
    FontEmbeddingStr: string; // 'none' | 'full' | 'subset'
    OpenFileAfterExport: Boolean;
    ShowMessageAfterExport: Boolean;
    IsPresent: Boolean; // True se il blocco pdf era nel JSON
  end;

  /// Dataset dichiarato dal JSON nel nodo "datasets": aperto prima della stampa e,
  /// se Close = True, chiuso dopo. E' un record e non la classe TzReportDataset di
  /// zOffice.Reports.json: Default(classe) e' nil e assegnarne i campi e' un access violation.
  TzJsonDatasetConfig = record
    Name: string;
    Close: Boolean;
  end;

  TzJsonWordFragment = record
    VariableName: string;
    TemplateFileName: string;
    DatasetName: string;
  end;

  TzJsonWordConfig = record
    ReadOnly: Boolean;
    FirmaEnabled: Boolean;
    InviaMailEnabled: Boolean;
    Fragments: TArray<TzJsonWordFragment>;
    Pdf: TzJsonPdfConfig;
    IsPresent: Boolean;
  end;

  TzJsonExcelConfig = record
    ReadOnly: Boolean;
    AllowBuildReport: Boolean;
    DataBindingJson: string; // contenuto grezzo del nodo databinding
    Pdf: TzJsonPdfConfig;
    IsPresent: Boolean;
  end;

  TzJsonFastReportConfig = record
    ShowDialog: Boolean;
    OpenAfterExport: Boolean;
    EmbeddedFonts: Boolean;
    OverwritePrompt: Boolean;
    IsPresent: Boolean;
  end;

  /// Output completo del parsing JSON — solo tipi primitivi/record.
  /// Il manager legge questo record e lo applica ai propri WordParams/ExcelParams.
  TzReportJsonConfigContext = record
    ReportId: string;
    ReportGroup: string;
    MainDataset: string;
    DataSets: TArray<TzJsonDatasetConfig>;
    Variables: TArray<TPair<string, string>>;
    Word: TzJsonWordConfig;
    Excel: TzJsonExcelConfig;
    FastReport: TzJsonFastReportConfig;
    // classificazione documentale dichiarata dal template: "profilo"
    // (lavorazione, catalogo OBJ_FILES_PROFILI_DOCUMENTALI) e
    // "tipologiaDocumentale" (che documento e', catalogo
    // OBJ_FILES_TIPOLOGIE_DOCUMENTALI)
    ProfiloDocumentale: string;
    TipologiaDocumentale: string;
    // TIPO_DOCUMENTO/TIPO_ALLEGATO per la registrazione di firma e per
    // l'etichetta del documento persistito: il controller applicativo li usa
    // al posto del proprio default quando il template li dichiara. Utile
    // quando lo stesso controller (e lo stesso ReportsManager) e' condiviso
    // da piu' tipi di documento, es. Contratti e Incarichi di Massima in
    // dmRisorse. Vuoti = il controller usa il proprio default fisso.
    TipoDocumento: string;
    TipoAllegato: string;
  end;

  TzReportJsonLoader = class
  private
    function FindJsonPath(const ReportFile: TzFile): string;
    procedure ParsePdfNode(JsonObj: TJSONObject; const NodeName: string; out Cfg: TzJsonPdfConfig);
  public
    /// Cerca e carica il JSON sidecar per ReportFile.
    /// Restituisce False se non trovato o non parsabile.
    function Load(const ReportFile: TzFile; out JsonPath: string; out Context: TzReportJsonConfigContext): Boolean;

    /// Aggiunge un frammento Word al JSON sidecar.
    /// Restituisce il nome file suggerito per il template del frammento, '' in caso di errore.
    function SaveWordFragment(const JsonPath, TemplateFileName, DatasetName: string): string;

    /// Toglie dal JSON sidecar tutte le voci word.fragments con quella variabile.
    /// Restituisce False se il JSON manca o non si riesce a riscriverlo.
    function RemoveWordFragment(const JsonPath, VariableName: string): Boolean;

    /// Salva il data binding Excel nel JSON sidecar.
    function SaveExcelDataBinding(const JsonPath, JsonStr: string): Boolean;
  end;

implementation

uses
  System.IOUtils,
  zOffice.types,
  zOffice.Word.Utils;

{ TzReportJsonLoader }

function TzReportJsonLoader.FindJsonPath(const ReportFile: TzFile): string;
begin
  result := ReportFile.FullName + '.json';
  if TFile.Exists(result) then
    exit;

  result := TPath.ChangeExtension(ReportFile.FullName, '.json');
  if TFile.Exists(result) then
    exit;

  result := '';
end;

procedure TzReportJsonLoader.ParsePdfNode(JsonObj: TJSONObject; const NodeName: string; out Cfg: TzJsonPdfConfig);
var
  pdfNode: TJSONObject;
  val: TJSONValue;
begin
  Cfg := Default (TzJsonPdfConfig);

  val := JsonObj.FindValue(NodeName);
  if not assigned(val) or not(val is TJSONObject) then
    exit;

  pdfNode := val as TJSONObject;
  Cfg.IsPresent := True;

  val := pdfNode.FindValue('method');
  if assigned(val) then
    Cfg.MethodStr := val.Value;

  val := pdfNode.FindValue('fileName');
  if assigned(val) then
    Cfg.FileName := val.Value;

  val := pdfNode.FindValue('fieldName');
  if assigned(val) then
    Cfg.FieldName := val.Value;

  val := pdfNode.FindValue('fontEmbedding');
  if assigned(val) then
    Cfg.FontEmbeddingStr := val.Value;

  val := pdfNode.FindValue('openFileAfterExport');
  if assigned(val) and (val is TJSONBool) then
    Cfg.OpenFileAfterExport := (val as TJSONBool).AsBoolean;

  val := pdfNode.FindValue('showMessageAfterExport');
  if assigned(val) and (val is TJSONBool) then
    Cfg.ShowMessageAfterExport := (val as TJSONBool).AsBoolean;
end;

function TzReportJsonLoader.Load(const ReportFile: TzFile; out JsonPath: string; out Context: TzReportJsonConfigContext): Boolean;
var
  JsonStr: string;
  JsonValue: TJSONValue;
  JsonObj: TJSONObject;
  JsonParams: TzJsonReportParams;
  pair: TJSONPair;
  val: TJSONValue;
  i: Integer;
  wordNode, excelNode, frNode: TJSONObject;
  fragNode: TJSONObject;
  fragsArr: TJSONArray;
  dsArr: TJSONArray;
  dsNode: TJSONObject;
  dsItem: TzJsonDatasetConfig;
begin
  result := False;
  JsonPath := '';
  Context := Default (TzReportJsonConfigContext);

  if not assigned(ReportFile) then
    exit;

  JsonPath := FindJsonPath(ReportFile);
  if JsonPath.IsEmpty then
    exit;

  try
    JsonStr := TFile.ReadAllText(JsonPath, TEncoding.UTF8);
    JsonValue := TJSONObject.ParseJSONValue(JsonStr);
    if not assigned(JsonValue) then
      exit;

    if not(JsonValue is TJSONObject) then
    begin
      JsonValue.Free;
      exit;
    end;

    JsonObj := JsonValue as TJSONObject;
    try
      // Classificazione documentale del template
      val := JsonObj.FindValue('profilo');
      if assigned(val) then
        Context.ProfiloDocumentale := val.Value.Trim.ToUpper;

      val := JsonObj.FindValue('tipologiaDocumentale');
      if assigned(val) then
        Context.TipologiaDocumentale := val.Value.Trim.ToUpper;

      // TIPO_DOCUMENTO/TIPO_ALLEGATO per la registrazione di firma e per
      // l'etichetta del documento persistito (vedi TzReportJsonConfigContext)
      val := JsonObj.FindValue('tipoDocumento');
      if assigned(val) then
        Context.TipoDocumento := val.Value.Trim.ToUpper;

      val := JsonObj.FindValue('tipoAllegato');
      if assigned(val) then
        Context.TipoAllegato := val.Value.Trim;

      // Metadati base
      val := JsonObj.FindValue('id');
      if assigned(val) then
        Context.ReportId := val.Value;

      val := JsonObj.FindValue('group');
      if assigned(val) then
        Context.ReportGroup := val.Value;

      val := JsonObj.FindValue('mainDataset');
      if assigned(val) then
        Context.MainDataset := val.Value;

      // Dataset aggiuntivi
      val := JsonObj.FindValue('datasets');
      if assigned(val) and (val is TJSONArray) then
      begin
        dsArr := val as TJSONArray;
        SetLength(Context.DataSets, dsArr.Count);
        for i := 0 to dsArr.Count - 1 do
        begin
          dsItem := Default (TzJsonDatasetConfig);
          if dsArr.Items[i] is TJSONObject then
          begin
            dsNode := dsArr.Items[i] as TJSONObject;
            val := dsNode.FindValue('name');
            if assigned(val) then
              dsItem.Name := val.Value;
            val := dsNode.FindValue('close');
            if assigned(val) and (val is TJSONBool) then
              dsItem.Close := (val as TJSONBool).AsBoolean;
          end;
          Context.DataSets[i] := dsItem;
        end;
      end;

      // Variabili statiche
      val := JsonObj.FindValue('variables');
      if assigned(val) and (val is TJSONObject) then
      begin
        SetLength(Context.Variables, (val as TJSONObject).Count);
        i := 0;
        for pair in (val as TJSONObject) do
        begin
          Context.Variables[i] := TPair<string, string>.Create(pair.JsonString.Value, pair.JsonValue.Value);
          Inc(i);
        end;
      end;

      // Word
      val := JsonObj.FindValue('word');
      if assigned(val) and (val is TJSONObject) then
      begin
        wordNode := val as TJSONObject;
        Context.Word.IsPresent := True;

        val := wordNode.FindValue('readOnly');
        if assigned(val) and (val is TJSONBool) then
          Context.Word.ReadOnly := (val as TJSONBool).AsBoolean;

        val := wordNode.FindValue('firma');
        if assigned(val) and (val is TJSONBool) then
          Context.Word.FirmaEnabled := (val as TJSONBool).AsBoolean;

        val := wordNode.FindValue('inviaMail');
        if assigned(val) and (val is TJSONBool) then
          Context.Word.InviaMailEnabled := (val as TJSONBool).AsBoolean;

        // Frammenti
        val := wordNode.FindValue('fragments');
        if assigned(val) and (val is TJSONArray) then
        begin
          fragsArr := val as TJSONArray;
          SetLength(Context.Word.Fragments, fragsArr.Count);
          for i := 0 to fragsArr.Count - 1 do
          begin
            if fragsArr.Items[i] is TJSONObject then
            begin
              fragNode := fragsArr.Items[i] as TJSONObject;
              val := fragNode.FindValue('variable');
              if assigned(val) then
                Context.Word.Fragments[i].VariableName := val.Value;
              val := fragNode.FindValue('template');
              if assigned(val) then
                Context.Word.Fragments[i].TemplateFileName := val.Value;
              val := fragNode.FindValue('dataset');
              if assigned(val) then
                Context.Word.Fragments[i].DatasetName := val.Value;
            end;
          end;
        end;

        ParsePdfNode(wordNode, 'pdf', Context.Word.Pdf);
      end;

      // Excel
      val := JsonObj.FindValue('excel');
      if assigned(val) and (val is TJSONObject) then
      begin
        excelNode := val as TJSONObject;
        Context.Excel.IsPresent := True;

        val := excelNode.FindValue('readOnly');
        if assigned(val) and (val is TJSONBool) then
          Context.Excel.ReadOnly := (val as TJSONBool).AsBoolean;

        val := excelNode.FindValue('allowBuildReport');
        if assigned(val) and (val is TJSONBool) then
          Context.Excel.AllowBuildReport := (val as TJSONBool).AsBoolean;

        val := excelNode.FindValue('databinding');
        if assigned(val) then
          Context.Excel.DataBindingJson := val.ToString;

        ParsePdfNode(excelNode, 'pdf', Context.Excel.Pdf);
      end;

      // FastReport
      val := JsonObj.FindValue('fastreport');
      if assigned(val) and (val is TJSONObject) then
      begin
        frNode := val as TJSONObject;
        Context.FastReport.IsPresent := True;

        val := frNode.FindValue('showDialog');
        if assigned(val) and (val is TJSONBool) then
          Context.FastReport.ShowDialog := (val as TJSONBool).AsBoolean;

        val := frNode.FindValue('openAfterExport');
        if assigned(val) and (val is TJSONBool) then
          Context.FastReport.OpenAfterExport := (val as TJSONBool).AsBoolean;

        val := frNode.FindValue('embeddedFonts');
        if assigned(val) and (val is TJSONBool) then
          Context.FastReport.EmbeddedFonts := (val as TJSONBool).AsBoolean;

        val := frNode.FindValue('overwritePrompt');
        if assigned(val) and (val is TJSONBool) then
          Context.FastReport.OverwritePrompt := (val as TJSONBool).AsBoolean;
      end;

      result := True;

    finally
      JsonObj.Free;
    end;
  except
    on E: Exception do
    begin
      result := False;
      JsonPath := '';
    end;
  end;
end;

function TzReportJsonLoader.SaveWordFragment(const JsonPath, TemplateFileName, DatasetName: string): string;
var
  Params: TzJsonReportParams;
  Frag: TzWordFragment;
  Esistente: TzWordFragment;
begin
  result := '';
  if JsonPath.IsEmpty then
    exit;
  try
    Params := nil;
    if TFile.Exists(JsonPath) then
      Params := TzJsonReportParams.FromJSON(TFile.ReadAllText(JsonPath, TEncoding.UTF8));
    if not assigned(Params) then
      Params := TzJsonReportParams.Create;
    try
      if not assigned(Params.Word) then
        Params.Word := TzWordParams.Create;

      // USA TFragmentHelper invece di calcolare il nome a mano
      result := ExtractFileName(TFragmentHelper.FileName(TemplateFileName, DatasetName));

      // una voce con la stessa variabile si aggiorna, non si duplica
      Frag := nil;
      for Esistente in Params.Word.Fragments do
        if SameText(Esistente.variable, DatasetName) then
        begin
          Frag := Esistente;
          Break;
        end;

      if not assigned(Frag) then
      begin
        Frag := TzWordFragment.Create;
        Frag.variable := DatasetName;
        Params.Word.Fragments.Add(Frag);
      end;

      Frag.template := result;
      Frag.DataSet := DatasetName;

      TFile.WriteAllText(JsonPath, Params.ToJSONString, TEncoding.UTF8);
    finally
      Params.Free;
    end;
  except
    result := '';
  end;
end;

function TzReportJsonLoader.RemoveWordFragment(const JsonPath, VariableName: string): Boolean;
var
  Params: TzJsonReportParams;
  I: Integer;
begin
  result := False;

  if JsonPath.IsEmpty or (not TFile.Exists(JsonPath)) then
    exit;

  try
    Params := TzJsonReportParams.FromJSON(TFile.ReadAllText(JsonPath, TEncoding.UTF8));

    if not assigned(Params) then
      exit;

    try
      if not assigned(Params.Word) then
        exit(True); // niente da togliere

      for I := Params.Word.Fragments.Count - 1 downto 0 do
        if SameText(Params.Word.Fragments[I].variable, VariableName) then
        begin
          Params.Word.Fragments[I].Free;
          Params.Word.Fragments.Delete(I);
        end;

      TFile.WriteAllText(JsonPath, Params.ToJSONString, TEncoding.UTF8);
      result := True;
    finally
      Params.Free;
    end;
  except
    result := False;
  end;
end;

function TzReportJsonLoader.SaveExcelDataBinding(const JsonPath, JsonStr: string): Boolean;
var
  Params: TzJsonReportParams;
begin
  result := False;
  if JsonPath.IsEmpty then
    exit;
  try
    Params := nil;
    if TFile.Exists(JsonPath) then
      Params := TzJsonReportParams.FromJSON(TFile.ReadAllText(JsonPath, TEncoding.UTF8));
    if not assigned(Params) then
      Params := TzJsonReportParams.Create;
    try
      if not assigned(Params.Excel) then
        Params.Excel := TzExcelParams.Create;

      if assigned(Params.Excel.databinding) then
        FreeAndNil(Params.Excel.databinding);

      if not JsonStr.IsEmpty then
        Params.Excel.databinding := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;

      TFile.WriteAllText(JsonPath, Params.ToJSONString, TEncoding.UTF8);
      result := True;
    finally
      Params.Free;
    end;
  except
    result := False;
  end;
end;

end.
