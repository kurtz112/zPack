unit zOffice.Reports.Proprieta;

// Proprieta' di un template di report per l'inspector (zEditProperties).
//
// Il vecchio ProprietaExecute passava all'inspector il TzFile del template:
// inutile, perche' TzFile ha tutte le proprieta' in visibilita' public e
// l'RTTI inspector mostra SOLO le published. Qui il contenuto del JSON
// sidecar diventa un modello TPersistent con proprieta' published editabili;
// se il JSON non esiste ne viene proposto uno vuoto, creato al salvataggio.
//
// L'inspector (TFrameObjectInspector.Add) svuota la griglia quando cambia la
// classe dell'oggetto: NON si possono passare due oggetti di classi diverse.
// Per questo il modello e' UN SOLO oggetto radice (TzReportProprieta) con
// sotto-oggetti published: "Report" espone le proprieta' del TzFile a scopo
// informativo, gli altri nodi sono editabili e vengono riscritti nel JSON.
//
// Le proprieta' informative sono published SENZA setter: l'inspector le
// mostra in grigio e non editabili grazie a ShowReadOnlyProperties di
// TzObjectInspector (zz.Inspector), ponte verso l'opzione NATIVA di cxOI
// OptionsView.ShowReadOnlyProperties (default False, per questo prima non
// comparivano) — nessuna patch a cxOI necessaria.
//
// Il salvataggio modifica SOLO le chiavi gestite qui e preserva tutto il
// resto del file: word.fragments, excel.databinding, variables, datasets e
// ogni chiave sconosciuta restano intatti. Vale anche per un'eventuale
// chiave "azioni" residua: il nodo e' stato RITIRATO (le azioni arrivano
// dal profilo su database, gate 1 del controller) e qui non viene piu'
// ne' letto ne' riscritto.
//
// Classificazione documentale: chiavi "profilo" e "tipologiaDocumentale"
// (riferimento: Documentazione\05_json). Le tendine dei valori le fornisce
// zOffice.Reports.PropertyEditors, che interroga i cataloghi
// OBJ_FILES_PROFILI_DOCUMENTALI / OBJ_FILES_TIPOLOGIE_DOCUMENTALI.
//
// Le tendine si vedono solo se zOffice.Reports.PropertyEditors e' LINKATA
// nell'eseguibile: si registra da sola in initialization, ma una unit che
// nessuno cita non entra nel programma. La cita l'implementation di
// zOffice.Reports.Form.
//
// ORDINE DELLE RIGHE: l'inspector viene aperto con l'ordinamento alfabetico
// spento, quindi le righe seguono l'ordine di dichiarazione delle proprieta'
// published di TzReportProprieta (vedi il commento sull'elenco).

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  zFileSystem;

type
  EzReportProprietaErrore = class(Exception);

  // Tipi dedicati per l'aggancio RTTI: cxRegisterPropertyEditor registra per
  // tipo, non per nome proprieta'. L'editor a tendina che interroga i
  // cataloghi (zOffice.Reports.PropertyEditors) si registra su questi due
  // tipi, senza toccare le altre proprieta' string dell'applicazione.
  TzProfiloDocumentaleNome = type string;
  TzTipologiaDocumentaleNome = type string;
  // stesso meccanismo per le due tendine che non interrogano il database ma
  // il manager dei report: i valori arrivano dalle liste esposte in fondo a
  // questa unit, riempite dalla form prima di aprire l'inspector
  TzReportGruppoNome = type string;
  TzReportDatasetNome = type string;

  // ---------------------------------------------------------------------
  // Report: le proprieta' del TzFile e del file su disco, in sola lettura
  // (nessun setter: l'inspector le mostra grigie e non editabili tramite
  // ShowReadOnlyProperties di TzObjectInspector).
  // ---------------------------------------------------------------------
  TzReportProprietaFile = class(TPersistent)
  private
    FNomeFile: string;
    FEstensione: string;
    FCartella: string;
    FPercorsoCompleto: string;
    FCondiviso: Boolean;
    FDimensione: string;
    FUltimaModifica: string;
    FFileJson: string;
  public
    procedure CaricaDa(Report: TzFile; const PercorsoJson: string; JsonEsistente: Boolean);
  published
    property NomeFile: string read FNomeFile;
    property Estensione: string read FEstensione;
    property Cartella: string read FCartella;
    property PercorsoCompleto: string read FPercorsoCompleto;
    property Condiviso: Boolean read FCondiviso;
    property Dimensione: string read FDimensione;
    property UltimaModifica: string read FUltimaModifica;
    property FileJson: string read FFileJson;
  end;

  // ---------------------------------------------------------------------
  // Nodo "pdf" (dentro word ed excel)
  // ---------------------------------------------------------------------
  TzReportPdfMetodo = (pmNonImpostato, pmDialog, pmFileName, pmFieldName, pmTempFile);
  TzReportPdfFontEmbedding = (feNonImpostato, feNone, feFull, feSubset);

  TzReportProprietaPdf = class(TPersistent)
  private
    FPresente: Boolean;
    FMetodo: TzReportPdfMetodo;
    FFileName: string;
    FFieldName: string;
    FFontEmbedding: TzReportPdfFontEmbedding;
    FOpenFileAfterExport: Boolean;
    FShowMessageAfterExport: Boolean;
  public
    procedure Pulisci;
    procedure CaricaDa(PdfNode: TJSONObject);
    function DaScrivere: Boolean;
    function CreaNodo: TJSONObject;
  published
    property Metodo: TzReportPdfMetodo read FMetodo write FMetodo;
    property FileName: string read FFileName write FFileName;
    property FieldName: string read FFieldName write FFieldName;
    property FontEmbedding: TzReportPdfFontEmbedding read FFontEmbedding write FFontEmbedding;
    property OpenFileAfterExport: Boolean read FOpenFileAfterExport write FOpenFileAfterExport;
    property ShowMessageAfterExport: Boolean read FShowMessageAfterExport write FShowMessageAfterExport;
  end;

  // ---------------------------------------------------------------------
  // Nodi "word", "excel", "fastreport"
  // (fragments e databinding NON sono gestiti qui: restano intatti nel file)
  // ---------------------------------------------------------------------
  TzReportProprietaWord = class(TPersistent)
  private
    FPresente: Boolean;
    FReadOnly: Boolean;
    FPdf: TzReportProprietaPdf;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Pulisci;
    procedure CaricaDa(WordNode: TJSONObject);
    function DaScrivere: Boolean;
    procedure ScriviSu(RootObject: TJSONObject);
  published
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property Pdf: TzReportProprietaPdf read FPdf;
  end;

  TzReportProprietaExcel = class(TPersistent)
  private
    FPresente: Boolean;
    FReadOnly: Boolean;
    FAllowBuildReport: Boolean;
    FPdf: TzReportProprietaPdf;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Pulisci;
    procedure CaricaDa(ExcelNode: TJSONObject);
    function DaScrivere: Boolean;
    procedure ScriviSu(RootObject: TJSONObject);
  published
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property AllowBuildReport: Boolean read FAllowBuildReport write FAllowBuildReport;
    property Pdf: TzReportProprietaPdf read FPdf;
  end;

  TzReportProprietaFastReport = class(TPersistent)
  private
    FPresente: Boolean;
    FShowDialog: Boolean;
    FOpenAfterExport: Boolean;
    FEmbeddedFonts: Boolean;
    FOverwritePrompt: Boolean;
  public
    procedure Pulisci;
    procedure CaricaDa(FastReportNode: TJSONObject);
    function DaScrivere: Boolean;
    procedure ScriviSu(RootObject: TJSONObject);
  published
    property ShowDialog: Boolean read FShowDialog write FShowDialog;
    property OpenAfterExport: Boolean read FOpenAfterExport write FOpenAfterExport;
    property EmbeddedFonts: Boolean read FEmbeddedFonts write FEmbeddedFonts;
    property OverwritePrompt: Boolean read FOverwritePrompt write FOverwritePrompt;
  end;

  // ---------------------------------------------------------------------
  // L'oggetto radice passato all'inspector
  // ---------------------------------------------------------------------
  TzReportProprieta = class(TPersistent)
  private
    FReport: TzReportProprietaFile;
    FId: string;
    FGruppo: TzReportGruppoNome;
    FMainDataset: TzReportDatasetNome;
    FProfilo: TzProfiloDocumentaleNome;
    FTipologiaDocumentale: TzTipologiaDocumentaleNome;
    FWord: TzReportProprietaWord;
    FExcel: TzReportProprietaExcel;
    FFastReport: TzReportProprietaFastReport;

    FPercorsoJson: string;
    FJsonEsistente: Boolean;

    class function TrovaPercorsoJson(Report: TzFile; out Esistente: Boolean): string;

    // qualche valore editabile e' stato impostato?
    function DatiDaSalvare: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // Individua il JSON sidecar del template (o ne propone uno nuovo,
    // <nomefile>.<ext>.json) e carica i valori; solleva
    // EzReportProprietaErrore se il file esiste ma non e' JSON valido
    // (salvare sovrascriverebbe un file da correggere a mano).
    procedure CaricaDaFile(Report: TzFile);

    // Riscrive nel JSON solo le chiavi gestite, preservando tutto il resto;
    // crea il file se non esisteva. UTF-8, indentato.
    // Ritorna False (e non scrive nulla) se il JSON non esisteva e l'utente
    // non ha valorizzato niente: l'OK a vuoto non crea file.
    function SalvaSuFile: Boolean;

    property PercorsoJson: string read FPercorsoJson;
  published
    // ORDINE DELLE RIGHE NELL'INSPECTOR: e' questo, perche' zEditReportProprieta
    // apre l'inspector con l'ordinamento alfabetico spento (Sorted = False di
    // cxOI: "properties are displayed in the order they were added"). Le righe
    // nascono da GetPropList senza ordinamento, cioe' nell'ordine in cui le
    // proprieta' published sono dichiarate qui sotto: spostare una riga di
    // questo elenco sposta la riga nella finestra. Prima i campi che si
    // compilano a mano, poi i tre nodi dei motori, in fondo le informazioni
    // sul file, che sono in sola lettura.
    property Id: string read FId write FId;
    property Gruppo: TzReportGruppoNome read FGruppo write FGruppo;
    property MainDataset: TzReportDatasetNome read FMainDataset write FMainDataset;
    // classificazione documentale del template: chiavi JSON "profilo"
    // (lavorazione, catalogo OBJ_FILES_PROFILI_DOCUMENTALI) e
    // "tipologiaDocumentale" (che documento e', catalogo
    // OBJ_FILES_TIPOLOGIE_DOCUMENTALI); tendine da
    // zOffice.Reports.PropertyEditors
    property Profilo: TzProfiloDocumentaleNome read FProfilo write FProfilo;
    property TipologiaDocumentale: TzTipologiaDocumentaleNome read FTipologiaDocumentale write FTipologiaDocumentale;
    property Word: TzReportProprietaWord read FWord;
    property Excel: TzReportProprietaExcel read FExcel;
    property FastReport: TzReportProprietaFastReport read FFastReport;
    property Report: TzReportProprietaFile read FReport;
  end;

  // Valori proposti nelle tendine di Gruppo e MainDataset. Li riempie la form
  // dei report (RaccogliCataloghiProprieta) prima di chiamare
  // zEditReportProprieta; gli editor di zOffice.Reports.PropertyEditors li
  // leggono da qui. Sono liste esposte e non una chiamata all'indietro perche'
  // gli editor li crea cxOI, senza nessun riferimento al manager dei report.
  // Restano vuote finche' nessuno le riempie: in quel caso la tendina non
  // propone niente e il campo resta digitabile, come prima.
var
  zReportGruppiProposti: TStringList;
  zReportDatasetProposti: TStringList;

  // Il punto di ingresso per la form dei report: carica, mostra l'inspector,
  // salva su conferma. Ritorna True se il JSON e' stato salvato (False se
  // l'utente annulla, o conferma senza aver valorizzato nulla su un JSON
  // inesistente).
function zEditReportProprieta(Report: TzFile): Boolean;

implementation

uses
  System.IOUtils,
  zFrmInspector;

const
  METODO_PDF: array [TzReportPdfMetodo] of string = ('', 'dialog', 'filename', 'fieldname', 'tempfile');
  FONT_EMBEDDING_PDF: array [TzReportPdfFontEmbedding] of string = ('', 'none', 'full', 'subset');

function zEditReportProprieta(Report: TzFile): Boolean;
var
  Proprieta: TzReportProprieta;
begin
  result := False;

  if not assigned(Report) then
    exit;

  Proprieta := TzReportProprieta.Create;
  try
    Proprieta.CaricaDaFile(Report);

    // False = niente ordinamento alfabetico: le righe seguono l'ordine di
    // dichiarazione delle proprieta' published di TzReportProprieta
    if zEditProperties([Proprieta], False) then
      result := Proprieta.SalvaSuFile;
  finally
    Proprieta.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Utilita' locali
// ---------------------------------------------------------------------------

function LeggiStringa(Node: TJSONObject; const Chiave: string): string;
var
  val: TJSONValue;
begin
  result := '';
  val := Node.FindValue(Chiave);
  if assigned(val) then
    result := val.Value;
end;

function LeggiBoolean(Node: TJSONObject; const Chiave: string): Boolean;
var
  val: TJSONValue;
begin
  result := False;
  val := Node.FindValue(Chiave);
  if assigned(val) and (val is TJSONBool) then
    result := (val as TJSONBool).AsBoolean;
end;

function LeggiOggetto(Node: TJSONObject; const Chiave: string): TJSONObject;
var
  val: TJSONValue;
begin
  result := nil;
  if not assigned(Node) then
    exit;
  val := Node.FindValue(Chiave);
  if assigned(val) and (val is TJSONObject) then
    result := val as TJSONObject;
end;

// sostituisce (o rimuove, se Valore vuoto) una coppia stringa
procedure ScriviStringa(Node: TJSONObject; const Chiave, Valore: string);
begin
  Node.RemovePair(Chiave).Free;
  if not Valore.IsEmpty then
    Node.AddPair(Chiave, Valore);
end;

procedure ScriviBoolean(Node: TJSONObject; const Chiave: string; Valore: Boolean);
begin
  Node.RemovePair(Chiave).Free;
  Node.AddPair(Chiave, TJSONBool.Create(Valore));
end;

{ TzReportProprietaFile }

procedure TzReportProprietaFile.CaricaDa(Report: TzFile; const PercorsoJson: string; JsonEsistente: Boolean);
var
  ricerca: TSearchRec;
begin
  FNomeFile := Report.FileName;
  FEstensione := Report.FileExt;
  FCartella := Report.Folder;
  FPercorsoCompleto := Report.FullName;
  FCondiviso := Report.IsShared;

  FDimensione := '';
  FUltimaModifica := '';
  if FindFirst(Report.FullName, faAnyFile, ricerca) = 0 then
  begin
    try
      FDimensione := FormatFloat('#,##0', ricerca.Size) + ' byte';
      FUltimaModifica := FormatDateTime('dd/mm/yyyy hh:nn:ss', ricerca.TimeStamp);
    finally
      System.SysUtils.FindClose(ricerca);
    end;
  end;

  if JsonEsistente then
    FFileJson := PercorsoJson
  else
    FFileJson := PercorsoJson + ' (nuovo)';
end;

{ TzReportProprietaPdf }

procedure TzReportProprietaPdf.Pulisci;
begin
  FPresente := False;
  FMetodo := pmNonImpostato;
  FFileName := '';
  FFieldName := '';
  FFontEmbedding := feNonImpostato;
  FOpenFileAfterExport := False;
  FShowMessageAfterExport := False;
end;

procedure TzReportProprietaPdf.CaricaDa(PdfNode: TJSONObject);
var
  testo: string;
  Metodo: TzReportPdfMetodo;
  embedding: TzReportPdfFontEmbedding;
begin
  Pulisci;

  if not assigned(PdfNode) then
    exit;

  FPresente := True;

  testo := LeggiStringa(PdfNode, 'method');
  for Metodo := Low(TzReportPdfMetodo) to High(TzReportPdfMetodo) do
    if SameText(METODO_PDF[Metodo], testo) and not testo.IsEmpty then
      FMetodo := Metodo;

  testo := LeggiStringa(PdfNode, 'fontEmbedding');
  for embedding := Low(TzReportPdfFontEmbedding) to High(TzReportPdfFontEmbedding) do
    if SameText(FONT_EMBEDDING_PDF[embedding], testo) and not testo.IsEmpty then
      FFontEmbedding := embedding;

  FFileName := LeggiStringa(PdfNode, 'fileName');
  FFieldName := LeggiStringa(PdfNode, 'fieldName');
  FOpenFileAfterExport := LeggiBoolean(PdfNode, 'openFileAfterExport');
  FShowMessageAfterExport := LeggiBoolean(PdfNode, 'showMessageAfterExport');
end;

function TzReportProprietaPdf.DaScrivere: Boolean;
begin
  result := FPresente or (FMetodo <> pmNonImpostato) or (FFontEmbedding <> feNonImpostato) or not FFileName.Trim.IsEmpty or not FFieldName.Trim.IsEmpty or FOpenFileAfterExport or FShowMessageAfterExport;
end;

function TzReportProprietaPdf.CreaNodo: TJSONObject;
begin
  result := TJSONObject.Create;

  if FMetodo <> pmNonImpostato then
    result.AddPair('method', METODO_PDF[FMetodo]);
  if not FFileName.Trim.IsEmpty then
    result.AddPair('fileName', FFileName.Trim);
  if not FFieldName.Trim.IsEmpty then
    result.AddPair('fieldName', FFieldName.Trim);
  if FFontEmbedding <> feNonImpostato then
    result.AddPair('fontEmbedding', FONT_EMBEDDING_PDF[FFontEmbedding]);

  result.AddPair('openFileAfterExport', TJSONBool.Create(FOpenFileAfterExport));
  result.AddPair('showMessageAfterExport', TJSONBool.Create(FShowMessageAfterExport));
end;

{ TzReportProprietaWord }

constructor TzReportProprietaWord.Create;
begin
  inherited Create;
  FPdf := TzReportProprietaPdf.Create;
end;

destructor TzReportProprietaWord.Destroy;
begin
  FreeAndNil(FPdf);
  inherited;
end;

procedure TzReportProprietaWord.Pulisci;
begin
  FPresente := False;
  FReadOnly := False;
  FPdf.Pulisci;
end;

procedure TzReportProprietaWord.CaricaDa(WordNode: TJSONObject);
begin
  Pulisci;

  if not assigned(WordNode) then
    exit;

  FPresente := True;
  FReadOnly := LeggiBoolean(WordNode, 'readOnly');
  FPdf.CaricaDa(LeggiOggetto(WordNode, 'pdf'));
end;

function TzReportProprietaWord.DaScrivere: Boolean;
begin
  result := FPresente or FReadOnly or FPdf.DaScrivere;
end;

procedure TzReportProprietaWord.ScriviSu(RootObject: TJSONObject);
var
  WordNode: TJSONObject;
begin
  // il nodo "word" NON si ricostruisce: contiene fragments e le chiavi
  // deprecate firma/inviaMail, che devono restare intatte
  WordNode := LeggiOggetto(RootObject, 'word');

  if not assigned(WordNode) then
  begin
    if not DaScrivere then
      exit;
    WordNode := TJSONObject.Create;
    RootObject.AddPair('word', WordNode);
  end;

  ScriviBoolean(WordNode, 'readOnly', FReadOnly);

  WordNode.RemovePair('pdf').Free;
  if FPdf.DaScrivere then
    WordNode.AddPair('pdf', FPdf.CreaNodo);
end;

{ TzReportProprietaExcel }

constructor TzReportProprietaExcel.Create;
begin
  inherited Create;
  FPdf := TzReportProprietaPdf.Create;
end;

destructor TzReportProprietaExcel.Destroy;
begin
  FreeAndNil(FPdf);
  inherited;
end;

procedure TzReportProprietaExcel.Pulisci;
begin
  FPresente := False;
  FReadOnly := False;
  FAllowBuildReport := False;
  FPdf.Pulisci;
end;

procedure TzReportProprietaExcel.CaricaDa(ExcelNode: TJSONObject);
begin
  Pulisci;

  if not assigned(ExcelNode) then
    exit;

  FPresente := True;
  FReadOnly := LeggiBoolean(ExcelNode, 'readOnly');
  FAllowBuildReport := LeggiBoolean(ExcelNode, 'allowBuildReport');
  FPdf.CaricaDa(LeggiOggetto(ExcelNode, 'pdf'));
end;

function TzReportProprietaExcel.DaScrivere: Boolean;
begin
  result := FPresente or FReadOnly or FAllowBuildReport or FPdf.DaScrivere;
end;

procedure TzReportProprietaExcel.ScriviSu(RootObject: TJSONObject);
var
  ExcelNode: TJSONObject;
begin
  // il nodo "excel" NON si ricostruisce: contiene databinding, che il
  // programma scrive per conto suo e deve restare intatto
  ExcelNode := LeggiOggetto(RootObject, 'excel');

  if not assigned(ExcelNode) then
  begin
    if not DaScrivere then
      exit;
    ExcelNode := TJSONObject.Create;
    RootObject.AddPair('excel', ExcelNode);
  end;

  ScriviBoolean(ExcelNode, 'readOnly', FReadOnly);
  ScriviBoolean(ExcelNode, 'allowBuildReport', FAllowBuildReport);

  ExcelNode.RemovePair('pdf').Free;
  if FPdf.DaScrivere then
    ExcelNode.AddPair('pdf', FPdf.CreaNodo);
end;

{ TzReportProprietaFastReport }

procedure TzReportProprietaFastReport.Pulisci;
begin
  FPresente := False;
  FShowDialog := False;
  FOpenAfterExport := False;
  FEmbeddedFonts := False;
  FOverwritePrompt := False;
end;

procedure TzReportProprietaFastReport.CaricaDa(FastReportNode: TJSONObject);
begin
  Pulisci;

  if not assigned(FastReportNode) then
    exit;

  FPresente := True;
  FShowDialog := LeggiBoolean(FastReportNode, 'showDialog');
  FOpenAfterExport := LeggiBoolean(FastReportNode, 'openAfterExport');
  FEmbeddedFonts := LeggiBoolean(FastReportNode, 'embeddedFonts');
  FOverwritePrompt := LeggiBoolean(FastReportNode, 'overwritePrompt');
end;

function TzReportProprietaFastReport.DaScrivere: Boolean;
begin
  result := FPresente or FShowDialog or FOpenAfterExport or FEmbeddedFonts or FOverwritePrompt;
end;

procedure TzReportProprietaFastReport.ScriviSu(RootObject: TJSONObject);
var
  frNode: TJSONObject;
begin
  frNode := LeggiOggetto(RootObject, 'fastreport');

  if not assigned(frNode) then
  begin
    if not DaScrivere then
      exit;
    frNode := TJSONObject.Create;
    RootObject.AddPair('fastreport', frNode);
  end;

  ScriviBoolean(frNode, 'showDialog', FShowDialog);
  ScriviBoolean(frNode, 'openAfterExport', FOpenAfterExport);
  ScriviBoolean(frNode, 'embeddedFonts', FEmbeddedFonts);
  ScriviBoolean(frNode, 'overwritePrompt', FOverwritePrompt);
end;

{ TzReportProprieta }

constructor TzReportProprieta.Create;
begin
  inherited Create;
  FReport := TzReportProprietaFile.Create;
  FWord := TzReportProprietaWord.Create;
  FExcel := TzReportProprietaExcel.Create;
  FFastReport := TzReportProprietaFastReport.Create;
end;

destructor TzReportProprieta.Destroy;
begin
  FreeAndNil(FReport);
  FreeAndNil(FWord);
  FreeAndNil(FExcel);
  FreeAndNil(FFastReport);
  inherited;
end;

class function TzReportProprieta.TrovaPercorsoJson(Report: TzFile; out Esistente: Boolean): string;
begin
  // stesse posizioni di TzReportJsonLoader.FindJsonPath
  Esistente := True;

  result := Report.FullName + '.json';
  if TFile.Exists(result) then
    exit;

  result := TPath.ChangeExtension(Report.FullName, '.json');
  if TFile.Exists(result) then
    exit;

  // nessun JSON: se ne propone uno nuovo nella forma consigliata
  Esistente := False;
  result := Report.FullName + '.json';
end;

procedure TzReportProprieta.CaricaDaFile(Report: TzFile);
var
  jsonValue: TJSONValue;
  RootObject: TJSONObject;
begin
  Assert(assigned(Report));

  FPercorsoJson := TrovaPercorsoJson(Report, FJsonEsistente);
  FReport.CaricaDa(Report, FPercorsoJson, FJsonEsistente);

  FId := '';
  FGruppo := '';
  FMainDataset := '';
  FProfilo := '';
  FTipologiaDocumentale := '';
  FWord.Pulisci;
  FExcel.Pulisci;
  FFastReport.Pulisci;

  if not FJsonEsistente then
    exit;

  jsonValue := TJSONObject.ParseJSONValue(TFile.ReadAllText(FPercorsoJson, TEncoding.UTF8));

  if not(jsonValue is TJSONObject) then
  begin
    jsonValue.Free;
    // niente proposta di JSON vuoto qui: salvare distruggerebbe un file
    // esistente da correggere a mano
    raise EzReportProprietaErrore.CreateFmt('Il file "%s" esiste ma non contiene JSON valido: correggerlo prima di modificare le proprieta''', [FPercorsoJson]);
  end;

  RootObject := jsonValue as TJSONObject;
  try
    FId := LeggiStringa(RootObject, 'id');
    FGruppo := LeggiStringa(RootObject, 'group');
    FMainDataset := LeggiStringa(RootObject, 'mainDataset');
    FProfilo := LeggiStringa(RootObject, 'profilo').Trim.ToUpper;
    FTipologiaDocumentale := LeggiStringa(RootObject, 'tipologiaDocumentale').Trim.ToUpper;

    FWord.CaricaDa(LeggiOggetto(RootObject, 'word'));
    FExcel.CaricaDa(LeggiOggetto(RootObject, 'excel'));
    FFastReport.CaricaDa(LeggiOggetto(RootObject, 'fastreport'));
  finally
    RootObject.Free;
  end;
end;

function TzReportProprieta.DatiDaSalvare: Boolean;
begin
  // Trim come funzione e non come metodo: Gruppo, MainDataset, Profilo e
  // TipologiaDocumentale sono tipi distinti (type string) e un tipo distinto
  // non eredita il record helper di string
  result := not FId.Trim.IsEmpty or not Trim(FGruppo).IsEmpty or not Trim(FMainDataset).IsEmpty or not Trim(FProfilo).IsEmpty or not Trim(FTipologiaDocumentale).IsEmpty or FWord.DaScrivere or FExcel.DaScrivere or FFastReport.DaScrivere;
end;

function TzReportProprieta.SalvaSuFile: Boolean;
var
  jsonValue: TJSONValue;
  RootObject: TJSONObject;
begin
  result := False;

  // OK senza aver valorizzato nulla su un JSON che non esiste:
  // non si crea un file vuoto
  if not FJsonEsistente and not DatiDaSalvare then
    exit;

  // si riparte dal file su disco, cosi' variables, datasets, fragments,
  // databinding e ogni chiave sconosciuta restano intatti
  RootObject := nil;

  if TFile.Exists(FPercorsoJson) then
  begin
    jsonValue := TJSONObject.ParseJSONValue(TFile.ReadAllText(FPercorsoJson, TEncoding.UTF8));
    if jsonValue is TJSONObject then
      RootObject := jsonValue as TJSONObject
    else
      jsonValue.Free;
  end;

  if not assigned(RootObject) then
    RootObject := TJSONObject.Create;

  try
    ScriviStringa(RootObject, 'id', FId.Trim);
    ScriviStringa(RootObject, 'group', Trim(FGruppo));
    ScriviStringa(RootObject, 'mainDataset', Trim(FMainDataset));
    ScriviStringa(RootObject, 'profilo', Trim(FProfilo).ToUpper);
    ScriviStringa(RootObject, 'tipologiaDocumentale', Trim(FTipologiaDocumentale).ToUpper);

    FWord.ScriviSu(RootObject);
    FExcel.ScriviSu(RootObject);
    FFastReport.ScriviSu(RootObject);

    TFile.WriteAllText(FPercorsoJson, RootObject.Format(2), TEncoding.UTF8);
    FJsonEsistente := True;
    result := True;
  finally
    RootObject.Free;
  end;
end;

initialization

zReportGruppiProposti := TStringList.Create;
zReportDatasetProposti := TStringList.Create;

finalization

FreeAndNil(zReportGruppiProposti);
FreeAndNil(zReportDatasetProposti);

end.
