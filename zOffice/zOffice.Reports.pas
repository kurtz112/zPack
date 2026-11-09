unit zOffice.Reports;

// PROPOSTA - Mantis #90 - 2026-09-05: versione modificata per la preanalisi.
// Base: zPack\zOffice\zOffice.Reports.pas (copia integrale, sola lettura).
// Non sostituisce il file sorgente: va confrontata e riportata a mano nel
// repository dopo revisione in RAD Studio.
//
// Modifica: FTipoDocumento/FTipoAllegato (nuovi campi) trasportano
// Context.TipoDocumento/Context.TipoAllegato (zOffice.Reports.JsonConfig.pas)
// fino a ContestoCorrente, con lo stesso trattamento gia' riservato a
// FProfiloDocumentale/FTipologiaDocumentale: dichiarazione campi, due reset,
// assegnazione dal Context parsato, esposizione in ContestoCorrente. Vedi
// 90 - ANALISI.md, sezione "Codice proposto — versione 2026-09-05" e
// "PATCH - zPack (TipoDocumento su TzDocumentoContesto).md".

{
  TzReportsManager
  ----------------
  Punto di ingresso unico per la stampa/preview/export/design di report
  nei formati FastReport (.fr3), Word (.docx) ed Excel (.xlsx).

  Dopo il refactoring coordina cinque collaboratori:
  TzReportVariables       — dizionario variabili + risoluzione (OnGetVariable)
  TzReportPipelineManager — pipe TfrxDBDataSet ↔ TzFBDataSet
  TzReportJsonLoader      — parsing/salvataggio JSON sidecar
  TzFastReportEngine      — preview/print/export/designer FastReport
  TzReportBatchRunner     — cicli batch (RunBatchPrint / RunBatchExportPdf)

  La fluent API pubblica (SetVar, WithDataSet, OnBeforePrint, ecc.),
  le property di configurazione e i metodi Preview/Print/Design/NewReport
  rimangono tutti qui e delegano ai collaboratori.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  System.ImageList,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.Controls,
  VclTee.Chart,
  VclTee.TeeProcs,
  VclTee.Teengine,
  VclTee.DBChart,
  VclTee.Series,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  fs_iextctrlsrtti,
  fs_idialogsrtti,
  fs_idbrtti,
  fs_idbctrlsrtti,
  fs_iclassesrtti,
  fs_ichartrtti,
  fs_iformsrtti,
  fs_igraphicsrtti,
  fs_iinirtti,
  fs_imenusrtti,
  fs_ipascal,
  frxClass,
  frxDBSet,
  frxDesgn,
  frxExportBaseDialog,
  frxExportPDF,
  frxCrypt,
  frxGZip,
  frxDCtrl,
  frxDMPExport,
  frxGradient,
  frxChBox,
  frxCellularTextObject,
  frxMap,
  frxTableObject,
  frxGaugeView,
  frxCross,
  frxRich,
  frxOLE,
  frxBarcode,
  frxChart,
  frxFDComponents,
  frxExportDOCX,
  frxExportODF,
  frxExportRTF,
  frCoreClasses,
  cxImageList,
  cxGraphics,
  dxRichEdit.Control,
  dxSpreadSheetReportDesigner,
  frxExportBaseImageSettingsDialog,
  dxSpreadSheet,
  zFbDataSet,
  zOffice,
  zOffice.types,
  zOffice.Reports.types,
  zOffice.Reports.Variables,
  zOffice.Reports.Pipeline,
  zOffice.Reports.JsonConfig,
  zOffice.Reports.Azioni,
  zOffice.Reports.Controller,
  zOffice.Reports.ActionsBarHelper,
  zOffice.Reports.FastReport,
  zOffice.Reports.Batch,
  zFileSystem,
  zSystem,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  frLocalization,
  frLanguageItalian,
  Vcl.Dialogs,
  zProgressBox,
  zOffice.Reports.Progress,
  zOffice.Reports.BatchController;

type
  TzReportsManager = class(TDataModule)
    frxDesigner: TfrxDesigner;
    frxReport: TfrxReport;
    frxPDFExport: TfrxPDFExport;
    frxDOCXExport: TfrxDOCXExport;
    frxRTFExport: TfrxRTFExport;
    frxODTExport: TfrxODTExport;
    images: TcxImageList;
    frLocalizationController: TfrLocalizationController;
    ProgressBox: TProgressBox;
    function frxDesignerLoadReport(Report: TfrxReport): Boolean;
    procedure frxDesignerShow(Sender: TObject);
    procedure frxReportBeginDoc(Sender: TObject);
    procedure frxReportPreview(Sender: TObject);
    function frxReportUserFunction(const MethodName: string; var Params: Variant): Variant;
  private
    // Collaboratori
    FVariables: TzReportVariables;
    FPipeline: TzReportPipelineManager;
    FJsonLoader: TzReportJsonLoader;
    FFastReport: TzFastReportEngine;
    FBatchRunner: TzReportBatchRunner;

    // Stato interno
    FFolder: string;
    FExcludeFolders: TExcludeFolders;
    FSharedReports: TStringList;
    FReports: TzFolder;
    // Mantis #139 - 2026-09-19: avvisi di ricaricamento dell'albero dei report
    FOnReportsReloading: TNotifyEvent;
    FOnReportsReloaded: TNotifyEvent;
    FDataSets: TList<TzFBDataSet>;
    FVisibleDataSets: TStrings;
    FMailMergeDataSet: TzFBDataSet;
    frxFDComponents: TfrxFDComponents;
    FReportDataSets: TObjectDictionary<string, TStringList>;
    FOpenedDataSets: TList<TzFBDataSet>;
    FReportId: string;
    FReportGroup: string;
    FDataSetsToClose: TStringList;
    FDefaultDatabase: TFDConnection;
    FCurrentUserDisplayName: string;
    FJsonPath: string;
    FzSystem: TzSystem;
    FBatchActive: Boolean;
    ModificaAnteprima: Boolean;

    // avanzamento + annullamento della preparazione anteprime (Word/Excel)
    FProgress: IzReportProgress;

    // Azioni documentali: stato della SESSIONE di visualizzazione corrente
    // (lo stato sta nel manager, che in Gesty e' uno per DataModule di
    // feature; il controller resta condivisibile perche' riceve tutto
    // nel contesto). Si azzera a ogni BeforePrint.
    FAzioniConfig: TzJsonAzioniConfig; // azioni del profilo del template corrente
    FProfiloDocumentale: string; // chiave JSON "profilo"
    FTipologiaDocumentale: string; // chiave JSON "tipologiaDocumentale"
    FTipoDocumento: string; // chiave JSON "tipoDocumento"
    FTipoAllegato: string; // chiave JSON "tipoAllegato"
    FDocumentoCorrente: Int64; // ID_OBJECT_FILE (0 = non persistito)
    FOidCorrente: Int64; // entita' proprietaria (WithOid)
    FReportCorrente: string;
    FActionsController: TzDocumentActionsController;
    FOnEsportaDocumentoPdf: TFunc<string>; // assegnata dai viewer: PDF del documento generato
    // risoluzione PIGRA dell'OID quando WithOid non e' stato chiamato:
    // interrogata alla costruzione del contesto (es. dal dataset selezionato
    // al momento dell'azione, come nel meccanismo storico dei contratti)
    FOnGetOid: TFunc<Int64>;

    WordParams: TWordParams;
    ExcelParams: TExcelParams;

    // Callbacks
    FBeforePrintProc: TFunc<string, Boolean>;
    FAfterPrintProc: TProc<string>;
    FAddVariablesProc: TProc<TzReportsManager>;
    FReportLoadedProc: TProc<string>;
  private
    procedure SetDefaultDatabase(const Value: TFDConnection);
    procedure SetSharedReports(const Value: TStringList);
    procedure SetExcludeFolders(const Value: TExcludeFolders);
    function ParsedSharedReports: TStrings;

    function GetDataSet(const DatasetName: string): TzFBDataSet;
    function GetDataSetNames: string;
    function GetDataSetPipeName(const DatasetName: string): string;

    function LoadReport(ReportName: string): Boolean;
    // Mantis #6949 - 2026-11-02: versioni che lavorano sul file scelto, non sul nome
    function LoadReportFile(Report: TzFile): Boolean;
    procedure ShowPreview(Report: TzFile);
    procedure ShowDesigner(Report: TzFile);
    function BeforePrint(const ReportName: string): Boolean;
    procedure AfterPrint(const ReportName: string);
    function PrepareReport(Report: string): Boolean;
    procedure AddVariables;

    procedure InitWordCallbacks;
    procedure InitExcelCallbacks;
    procedure ApplyJsonContext(const ReportName: string; const Context: TzReportJsonConfigContext);
    procedure SetActionsController(const Value: TzDocumentActionsController);

    // hook TzSetupAzioniDocumentoProc, assegnato a WordParams/ExcelParams e
    // al motore FastReport: crea e aggancia l'helper (presenter) delle azioni
    // al controller applicativo e lo restituisce al viewer, che lo collega
    // all'OnUpdate/OnExecute delle proprie TAction. Ritorna nil se le azioni
    // non sono configurate (il viewer nasconde il gruppo "Documento").
    function ConfiguraAzioniDocumento(AOwner: TComponent; EsportaPdfTemporaneo: TFunc<string>): TzDocumentActionsBarHelper;
  private
    // Getter/Setter wrappers per Word/Excel params
    function GetWordBeforeShow: TProc<string, TdxRichEditControl>;
    procedure SetWordBeforeShow(Value: TProc<string, TdxRichEditControl>);
    function GetExcelBeforeShow: TProc<string, TdxSpreadSheet>;
    procedure SetExcelBeforeShow(Value: TProc<string, TdxSpreadSheet>);
    function GetExcelAfterBuild: TProc<string, TdxSpreadSheet>;
    procedure SetExcelAfterBuild(Value: TProc<string, TdxSpreadSheet>);
    function GetExcelBeforeBuild: TProc<string, TdxSpreadSheet>;
    procedure SetExcelBeforeBuild(Value: TProc<string, TdxSpreadSheet>);
    function GetExcelAllowBuildReport: TFunc<string, Boolean>;
    procedure SetExcelAllowBuildReport(Value: TFunc<string, Boolean>);
    function GetExcelOnGetDataSource: TFunc<string, TDataSource>;
    procedure SetExcelOnGetDataSource(Value: TFunc<string, TDataSource>);
    function GetOnGetVariable: TFunc<string, Variant>;
    procedure SetOnGetVariable(Value: TFunc<string, Variant>);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadReports;

    // ------------------------------------------------------------------
    // Variabili
    // ------------------------------------------------------------------

    procedure AddVariable(const Name: string; const Value: string); overload;
    procedure AddVariable(const Name: string; const Value: Variant); overload;
    procedure AddVariable(const DatasetName: string; Params: TFDParams); overload;
    procedure AddVariable(Query: TFDQuery); overload;
    procedure AddVariable(StoredProc: TFDStoredProc); overload;

    procedure EnumVariableNames(Names: TStrings);
    function VariableExists(Name: string): Boolean;
    function GetVariable(Name: string): Variant;

    // ------------------------------------------------------------------
    // Dataset
    // ------------------------------------------------------------------

    procedure ClearDataSets;
    procedure AddDataSet(DataSet: TzFBDataSet);
    procedure SetFastReportDataSet(const DataSet: TDataSet);

    // ------------------------------------------------------------------
    // Azioni report
    // ------------------------------------------------------------------

    procedure ShowReportForm(aSelectedDataSet: TzFBDataSet);
    function GetFolder(const Folder: string): string;
    function GetReport(const ReportName: string): TzFile;

    procedure Preview(const ReportName: string; DataSet: TzFBDataSet = nil);
    // Mantis #6949 - 2026-11-02: anteprima e modifica del file scelto nell'albero.
    // Per nome si apre il primo omonimo trovato, anche in una cartella di archivio.
    procedure PreviewFile(Report: TzFile; DataSet: TzFBDataSet = nil);
    procedure Print(const ReportName: string);
    procedure Design(ReportName: string);
    procedure DesignFile(Report: TzFile);
    procedure NewReport;

    // ------------------------------------------------------------------
    // Batch — livello basso
    // ------------------------------------------------------------------

    procedure BatchInit(const ReportName: string);
    procedure BatchPrint(const DocumentLabel: string; ShowPrinterDialog: Boolean = False);
    function BatchExportPdf(const FileName: string): Boolean;
    procedure BatchDone;

    // ------------------------------------------------------------------
    // Batch — livello alto
    // ------------------------------------------------------------------

    procedure RunBatchPrint(const ReportName: string; Controller: TzBatchController; const ProgressCaption: string = 'Stampa in corso');

    function RunBatchExportPdf(const ReportName: string; Controller: TzBatchController; OutputFolder: string = ''; const ProgressCaption: string = 'Generazione PDF'): Integer;

    // ------------------------------------------------------------------
    // Azioni documentali (Firma/Protocolla/Conserva/InviaPec/InviaMail)
    // Gate 1 (template) qui; gate 2-4 nel controller applicativo.
    // ------------------------------------------------------------------

    // il contesto della richiesta, costruito a ogni chiamata (il controller
    // e' senza stato di template)
    function ContestoCorrente: TzDocumentoContesto;

    function StatoAzione(Azione: TzAzioneDocumento): TzAzioneDocumentoStato;
    function MotivoBloccoAzione(Azione: TzAzioneDocumento): string;
    function EstremiAzione(Azione: TzAzioneDocumento): string;

    // persistenza pigra al primo utilizzo (versione ORI via controller),
    // poi delega Esegui: unico punto di passaggio per viewer e batch
    procedure EseguiAzione(Azione: TzAzioneDocumento);
    procedure AggiornaStatoAzione(Azione: TzAzioneDocumento);

    // materializza il documento visualizzato come riga OBJ_FILES (versione ORI)
    // + OBJ_FILES_GENERAZIONI. Idempotente: se il documento e' gia' persistito
    // nella sessione corrente non rifa' nulla e ritorna l'id esistente.
    function PersistiDocumentoCorrente: Int64;
    // vero quando il comando "Genera allegato" ha senso: azioni configurate,
    // viewer in grado di produrre il PDF, documento non ancora persistito
    function PuoGenerareAllegato: Boolean;

    // ------------------------------------------------------------------
    // Fluent API — variabili
    // ------------------------------------------------------------------

    function SetVar(const Name: string; const Value: Variant): TzReportsManager; overload;
    function SetVar(const Name: string; const Value: string): TzReportsManager; overload;
    function ClearVars: TzReportsManager;

    // ------------------------------------------------------------------
    // Fluent API — callbacks
    // ------------------------------------------------------------------

    function OnBeforePrint(AProc: TFunc<string, Boolean>): TzReportsManager;
    function OnAfterPrint(AProc: TProc<string>): TzReportsManager;

    function OnWordBeforeShow(AProc: TProc<string, TdxRichEditControl>): TzReportsManager;

    function OnExcelBeforeBuild(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
    function OnExcelAfterBuild(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
    function OnExcelBeforeShow(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
    function OnExcelGetDataSource(AFunc: TFunc<string, TDataSource>): TzReportsManager;
    function OnExcelAllowBuild(AFunc: TFunc<string, Boolean>): TzReportsManager;

    // ------------------------------------------------------------------
    // Fluent API — dataset
    // ------------------------------------------------------------------

    function WithDataSet(DataSet: TzFBDataSet): TzReportsManager; overload;
    function WithDataSet(const DatasetName: string): TzReportsManager; overload;
    function WithMainDataSet(DataSet: TzFBDataSet): TzReportsManager; overload;
    function WithMainDataSet(const DatasetName: string): TzReportsManager; overload;
    function RegisterReportDataSets(const ReportName: string; const DataSetNames: array of string): TzReportsManager;

    // entita' proprietaria del documento che sta per essere generato
    // (finisce in OBJ_FILES.OID alla persistenza); resta valido finche'
    // non viene reimpostato
    function WithOid(const Oid: Int64): TzReportsManager;

    // ------------------------------------------------------------------
    // Proprietà
    // ------------------------------------------------------------------

    property SelectedDataSet: TzFBDataSet read FMailMergeDataSet write FMailMergeDataSet;
    property ReportId: string read FReportId write FReportId;
    property ReportGroup: string read FReportGroup write FReportGroup;
    property DataSets: TList<TzFBDataSet> read FDataSets;
    property DataSetNames: string read GetDataSetNames;
    property Folder: string read FFolder write FFolder;
    property ExcludeFolders: TExcludeFolders read FExcludeFolders write SetExcludeFolders;
    property SharedReports: TStringList read FSharedReports write SetSharedReports;
    property Reports: TzFolder read FReports;

    // Mantis #139 - 2026-09-19: chi conserva riferimenti agli oggetti di
    // Reports (la finestra dei report li mette in Node.Data) deve poterli
    // lasciare andare prima che Reports.Clear li distrugga, e riprenderli
    // dopo il ricaricamento. Senza questi due avvisi l'albero resta pieno di
    // puntatori a oggetti liberati e il primo aggiornamento delle azioni va
    // in access violation.
    property OnReportsReloading: TNotifyEvent read FOnReportsReloading write FOnReportsReloading;
    property OnReportsReloaded: TNotifyEvent read FOnReportsReloaded write FOnReportsReloaded;
    property DefaultDatabase: TFDConnection read FDefaultDatabase write SetDefaultDatabase;
    property CurrentUserDisplayName: string read FCurrentUserDisplayName write FCurrentUserDisplayName;
    property zSystem: TzSystem read FzSystem write FzSystem;

    // Azioni documentali: un solo aggancio per applicazione
    // (ReportsManager.ActionsController := <controller applicativo>)
    property ActionsController: TzDocumentActionsController read FActionsController write SetActionsController;
    property OidCorrente: Int64 read FOidCorrente write FOidCorrente;
    property OnGetOid: TFunc<Int64> read FOnGetOid write FOnGetOid;
    property DocumentoCorrente: Int64 read FDocumentoCorrente;
    property AzioniConfig: TzJsonAzioniConfig read FAzioniConfig;
    // assegnata dai viewer: esporta il documento correntemente visualizzato
    // in un PDF temporaneo e ne ritorna il path (per la persistenza pigra)
    property OnEsportaDocumentoPdf: TFunc<string> read FOnEsportaDocumentoPdf write FOnEsportaDocumentoPdf;

    property ReportLoadedProc: TProc<string> read FReportLoadedProc write FReportLoadedProc;
    property BeforePrintProc: TFunc<string, Boolean> read FBeforePrintProc write FBeforePrintProc;
    property AfterPrintProc: TProc<string> read FAfterPrintProc write FAfterPrintProc;
    property AddVariablesProc: TProc<TzReportsManager> read FAddVariablesProc write FAddVariablesProc;

    /// Unico hook per variabili dinamiche — vale per tutti e tre i motori.
    property OnGetVariable: TFunc<string, Variant> read GetOnGetVariable write SetOnGetVariable;

    // Easy-access wrappers Word
    property WordBeforeShow: TProc<string, TdxRichEditControl> read GetWordBeforeShow write SetWordBeforeShow;

    // Easy-access wrappers Excel
    property ExcelBeforeShow: TProc<string, TdxSpreadSheet> read GetExcelBeforeShow write SetExcelBeforeShow;
    property ExcelBeforeBuild: TProc<string, TdxSpreadSheet> read GetExcelBeforeBuild write SetExcelBeforeBuild;
    property ExcelAfterBuild: TProc<string, TdxSpreadSheet> read GetExcelAfterBuild write SetExcelAfterBuild;
    property ExcelAllowBuildReport: TFunc<string, Boolean> read GetExcelAllowBuildReport write SetExcelAllowBuildReport;
    property ExcelOnGetDataSource: TFunc<string, TDataSource> read GetExcelOnGetDataSource write SetExcelOnGetDataSource;
  end;

implementation

uses
  System.JSON,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  Vcl.FileCtrl,
  cxImageComboBox,
  cxProgressBar,
  frxExportPDFHelpers,
  zOffice.Word.UriStreamProvider,
  zOffice.Reports.Form,
  zMsg,
  zBaseLib,
  zOffice.Reports.JSON,
  zz.Folders;

{$R *.DFM}

type
  // Adatta il TProgressBox del DataModule al contratto IzReportProgress usato
  // da tutti e tre i motori (FastReport / Word / Excel).
  TzProgressBoxAdapter = class(TInterfacedObject, IzReportProgress)
  private
    FBox: TProgressBox; // riferimento non posseduto (vive nel DataModule)
  public
    constructor Create(ABox: TProgressBox);
    procedure Start(const Caption: string; Max: Integer);
    function Step(Position: Integer; const Info: string): Boolean;
    procedure Done;
  end;

constructor TzProgressBoxAdapter.Create(ABox: TProgressBox);
begin
  inherited Create;
  FBox := ABox;
end;

procedure TzProgressBoxAdapter.Start(const Caption: string; Max: Integer);
begin
  if not assigned(FBox) then
    exit;

  if Max < 0 then
    Max := 0;

  FBox.Show(Max, Caption, '');

  // Max <= 0 = totale non noto (FastReport/Excel): barra marquee (animata)
  // invece della percentuale. Con Max > 0 (Word) barra determinata.
  // NB: il marquee anima solo mentre il thread elabora messaggi: per Word e
  // FastReport avviene (Step chiama ProcessMessages); per Excel il Build e'
  // bloccante, quindi durante quello la barra resta ferma.
  if assigned(FBox.ProgressDlg) and assigned(FBox.ProgressDlg.ProgressBar) then
    FBox.ProgressDlg.ProgressBar.Properties.Marquee := (Max <= 0);
end;

function TzProgressBoxAdapter.Step(Position: Integer; const Info: string): Boolean;
begin
  result := True;

  if not assigned(FBox) then
    exit;

  FBox.Progress := Position;
  if not Info.IsEmpty then
    FBox.FirstLabel := Info;

  // indispensabile perche' il pulsante Annulla possa essere premuto
  Application.ProcessMessages;

  result := not FBox.Cancelled;
end;

procedure TzProgressBoxAdapter.Done;
begin
  if assigned(FBox) and FBox.Visible then
    FBox.Close;
end;

{ TzReportsManager }

constructor TzReportsManager.Create(AOwner: TComponent);
begin
  inherited;

  if assigned(Owner) then
    Name := 'ReportsManager_' + Owner.Name;

  // Stato
  FFolder := '';
  FExcludeFolders := [];
  FReportId := '';
  FReportGroup := '';
  FJsonPath := '';
  FBatchActive := False;
  ModificaAnteprima := False;
  FMailMergeDataSet := nil;
  FDefaultDatabase := nil;
  FCurrentUserDisplayName := '';
  FzSystem := nil;
  FReportLoadedProc := nil;
  FBeforePrintProc := nil;
  FAfterPrintProc := nil;
  FAddVariablesProc := nil;

  // Azioni documentali
  FAzioniConfig.Clear;
  FProfiloDocumentale := '';
  FTipologiaDocumentale := '';
  FTipoDocumento := '';
  FTipoAllegato := '';
  FDocumentoCorrente := 0;
  FOidCorrente := 0;
  FReportCorrente := '';
  FActionsController := nil;
  FOnEsportaDocumentoPdf := nil;
  FOnGetOid := nil;

  // Collezioni
  FDataSets := TList<TzFBDataSet>.Create;
  FReports := TzFolder.Create(nil);
  FSharedReports := TStringList.Create;
  FSharedReports.Duplicates := dupIgnore;
  FReportDataSets := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);
  FOpenedDataSets := TList<TzFBDataSet>.Create;
  FDataSetsToClose := TStringList.Create;

  // Componente FastReport non-DFM
  frxFDComponents := TfrxFDComponents.Create(Self);
  frxFDComponents.DefaultDatabase := nil;

  // FastReport default export settings
  frxPDFExport.OpenAfterExport := False;
  frxPDFExport.ShowDialog := True;
  frxPDFExport.OverwritePrompt := False;
  frxPDFExport.EmbeddedFonts := True;

  // Collaboratori
  FVariables := TzReportVariables.Create;

  FPipeline := TzReportPipelineManager.Create(Self, FDataSets);

  FJsonLoader := TzReportJsonLoader.Create;

  FFastReport := TzFastReportEngine.Create(frxReport, frxPDFExport, frxDesigner);
  FFastReport.OnSetupAzioniDocumento := ConfiguraAzioniDocumento;

  // Params
  WordParams.Init;
  ExcelParams.Init;

  // Wiring callbacks variabili verso i tre motori
  FVariables.OnGetVariable := nil; // valorizzato dal chiamante via OnGetVariable

  InitWordCallbacks;
  InitExcelCallbacks;

  FBatchRunner := TzReportBatchRunner.Create(FFastReport, ProgressBox);

  FBatchRunner.BeforePrint := function(ReportName: string): Boolean
    begin
      result := BeforePrint(ReportName);
    end;
  FBatchRunner.AfterPrint := procedure(ReportName: string)
    begin
      AfterPrint(ReportName);
    end;

  // Word: il manager esegue con i propri WordParams (closure).
  // Nel batch il progress/annulla e' gestito dal runner sullo stesso
  // ProgressBox: si disattiva quello per-documento, altrimenti il merge del
  // singolo documento re-mostrerebbe e chiuderebbe il box del batch a meta'.
  FBatchRunner.OnWordExecute := procedure(TemplateFileName: string)
    var
      savedProgress: IzReportProgress;
    begin
      savedProgress := WordParams.Progress;
      WordParams.Progress := nil;
      WordParams.TemplateFileName := TemplateFileName;
      try
        zOffice.MailMerge(WordParams);
      finally
        WordParams.Progress := savedProgress;
      end;
    end;

  FBatchRunner.OnWordExportPdf := procedure(TemplateFileName, PdfFileName: string)
    var
      saved: TPdfParams;
      wp: TPdfParams;
      savedProgress: IzReportProgress;
    begin
      saved := WordParams.pdf;
      wp := saved;
      wp.method := mgfFileName;
      wp.FileName := PdfFileName;
      wp.OpenFileAfterExport := False;
      wp.ShowMessageAfterExport := False;
      WordParams.pdf := wp;
      savedProgress := WordParams.Progress;
      WordParams.Progress := nil;
      WordParams.TemplateFileName := TemplateFileName;
      try
        zOffice.MailMerge(WordParams);
      finally
        WordParams.pdf := saved;
        WordParams.Progress := savedProgress;
      end;
    end;

  // Excel: il manager esegue con i propri ExcelParams (closure)
  FBatchRunner.OnExcelExecute := procedure(TemplateFileName: string)
    var
      savedProgress: IzReportProgress;
    begin
      savedProgress := ExcelParams.Progress;
      ExcelParams.Progress := nil;
      ExcelParams.TemplateFileName := TemplateFileName;
      try
        zOffice.BuildSpreadSheetReport(ExcelParams);
      finally
        ExcelParams.Progress := savedProgress;
      end;
    end;

  FBatchRunner.OnExcelExportPdf := procedure(TemplateFileName, PdfFileName: string)
    var
      saved: TPdfParams;
      ep: TPdfParams;
      savedProgress: IzReportProgress;
    begin
      saved := ExcelParams.pdf;
      ep := saved;
      ep.method := mgfFileName;
      ep.FileName := PdfFileName;
      ep.OpenFileAfterExport := False;
      ep.ShowMessageAfterExport := False;
      ExcelParams.pdf := ep;
      savedProgress := ExcelParams.Progress;
      ExcelParams.Progress := nil;
      ExcelParams.TemplateFileName := TemplateFileName;
      try
        zOffice.BuildSpreadSheetReport(ExcelParams);
      finally
        ExcelParams.pdf := saved;
        ExcelParams.Progress := savedProgress;
      end;
    end;

  // avanzamento + annullamento condiviso: lo stesso ProgressBox serve tutti e
  // tre i motori (FastReport via eventi OnProgress, Word/Excel via i params)
  FProgress := TzProgressBoxAdapter.Create(ProgressBox);
  FFastReport.Progress := FProgress;
  WordParams.Progress := FProgress;
  ExcelParams.Progress := FProgress;
end;

destructor TzReportsManager.Destroy;
begin
  FreeAndNil(FBatchRunner);
  FreeAndNil(FFastReport);
  FreeAndNil(FJsonLoader);
  FreeAndNil(FPipeline);
  FreeAndNil(FVariables);
  FreeAndNil(FDataSetsToClose);
  FreeAndNil(FReportDataSets);
  FreeAndNil(FOpenedDataSets);
  FreeAndNil(FSharedReports);
  FreeAndNil(FReports);
  FreeAndNil(FDataSets);
  inherited;
end;

// ------------------------------------------------------------------
// Wiring interno callbacks Word / Excel
// ------------------------------------------------------------------

procedure TzReportsManager.InitWordCallbacks;
begin
  WordParams.OnGetVariable := function(variableName: string): Variant
    begin
      result := FVariables.Resolve(variableName);
    end;

  WordParams.OnGetDataSet := function(DatasetName: string): TDataSet
    begin
      if DatasetName.IsEmpty then
        result := SelectedDataSet
      else
        result := GetDataSet(DatasetName);
    end;

  WordParams.OnGetDataSetName := function(DatasetName: string): string
    begin
      result := GetDataSetPipeName(DatasetName);
    end;

  WordParams.OnGetDataSetList := procedure(DataSetNames: TStrings)
    begin
      Assert(assigned(DataSetNames));
      DataSetNames.Text := Self.DataSetNames;
    end;

  WordParams.OnGetImages := procedure(TemplateFileName: string; DataSet: TDataSet; provider: TImageUriStreamProvider)
    begin
      provider.ClearImages;

      if assigned(DataSet) then
      begin
        provider.AddImages(DataSet);
        provider.AddImage('Header', DataSet, 'CARTA_INTESTATA_LOGO_INTESTAZ');
        provider.AddImage('Logo', DataSet, 'CARTA_INTESTATA_TIMBRO');
        provider.AddImage('Footer', DataSet, 'CARTA_INTESTATA_LOGO_FOOTER');
        provider.AddImage('FirmaDirettore', DataSet, 'CARTA_INTESTATA_IMM_FIRMA_DIRET');
        provider.AddImage('FirmaLegaleRappresentante', DataSet, 'CARTA_INTESTATA_IMM_FIRMA_LEG_R');
        provider.AddImage('FIRMA_RESPONSABILE', DataSet, 'FIRMA_RESPONSABILE');
        provider.AddImage('FIRMA_COORDINATORE_CORSO', DataSet, 'FIRMA_COORDINATORE_CORSO');
        provider.AddImage('FIRMA_REFERENTE_SEGRETERIA', DataSet, 'FIRMA_REFERENTE_SEGRETERIA');
        provider.AddImage('LOGO_INTESTAZIONE', DataSet, 'LOGO_INTESTAZIONE');
        provider.AddImage('LOGO_FOOTER', DataSet, 'LOGO_FOOTER');
      end;
    end;

  WordParams.OnAddFragment := function(DatasetName: string): string
    begin
      result := FJsonLoader.SaveWordFragment(FJsonPath, WordParams.TemplateFileName, DatasetName);
    end;

  WordParams.OnRemoveFragment := function(NomeVariabile: string): Boolean
    begin
      result := FJsonLoader.RemoveWordFragment(FJsonPath, NomeVariabile);
    end;

  WordParams.OnSetupAzioniDocumento := ConfiguraAzioniDocumento;
end;

procedure TzReportsManager.InitExcelCallbacks;
begin
  ExcelParams.OnGetVariable := function(variableName: string): Variant
    begin
      result := FVariables.Resolve(variableName);
    end;

  ExcelParams.OnGetDataSet := function(DatasetName: string): TDataSet
    begin
      if DatasetName.IsEmpty then
        result := SelectedDataSet
      else
        result := GetDataSet(DatasetName);
    end;

  ExcelParams.OnGetDataSource := function(DataSourceName: string): TDataSource
    var
      DataSet: TzFBDataSet;
      OwnerComp: TComponent;
      comp: TComponent;
    begin
      result := nil;

      if assigned(Owner) then
      begin
        comp := Owner.FindComponent(DataSourceName);
        if assigned(comp) and (comp is TDataSource) then
        begin
          result := comp as TDataSource;
          exit;
        end;
      end;

      for DataSet in FDataSets do
      begin
        OwnerComp := DataSet.Owner;
        if assigned(OwnerComp) then
        begin
          comp := OwnerComp.FindComponent(DataSourceName);
          if assigned(comp) and (comp is TDataSource) then
          begin
            result := comp as TDataSource;
            exit;
          end;
        end;
      end;
    end;

  ExcelParams.OnLoadDataBinding := function: string
    begin
      // Il JSON path è già valorizzato da BeforePrint
      result := '';
    end;

  ExcelParams.OnSaveDataBinding := function(jsonStr: string): Boolean
    begin
      result := FJsonLoader.SaveExcelDataBinding(FJsonPath, jsonStr);
    end;

  ExcelParams.OnSetupAzioniDocumento := ConfiguraAzioniDocumento;
end;

// ------------------------------------------------------------------
// BeforePrint / AfterPrint
// ------------------------------------------------------------------

function TzReportsManager.BeforePrint(const ReportName: string): Boolean;
var
  dsNames: TStringList;
  dsName: string;
  ds: TzFBDataSet;
  DataSet: TzFBDataSet;
  Context: TzReportJsonConfigContext;
  Report: TzFile;
begin
  result := True;

  LoadReports;

  // Nuova generazione = nuovo documento: azzera la sessione delle azioni
  // (la persistenza e' pigra: la versione ORI nasce al primo click su
  // un'azione, non a ogni anteprima). L'export PDF si azzera perche' la
  // closure catturava il viewer della sessione precedente, ormai distrutto.
  FDocumentoCorrente := 0;
  FReportCorrente := ReportName;
  FAzioniConfig.Clear;
  FProfiloDocumentale := '';
  FTipologiaDocumentale := '';
  FTipoDocumento := '';
  FTipoAllegato := '';
  FOnEsportaDocumentoPdf := nil;

  // cartella proposta dall'esportazione PDF dell'anteprima: senza, la finestra
  // si apriva nella cartella corrente, cioe' quella dell'eseguibile
  frxPDFExport.DefaultPath := TFolders.UserDocumentsFolder;

  // Parsing JSON sidecar
  Report := GetReport(ReportName);
  if assigned(Report) then
  begin
    if FJsonLoader.Load(Report, FJsonPath, Context) then
      ApplyJsonContext(ReportName, Context)
    else
      FJsonPath := '';
  end
  else
    FJsonPath := '';

  // Auto-open dataset registrati per questo report
  if FReportDataSets.TryGetValue(ReportName.ToLower, dsNames) then
    for dsName in dsNames do
    begin
      ds := GetDataSet(dsName);
      if assigned(ds) and not ds.Active then
      begin
        ds.Active := True;
        FOpenedDataSets.Add(ds);
      end;
    end;

  FPipeline.CreateAll;

  AddVariables;

  // Prepara i dataset per la scansione da codice (generazione report):
  // DisableControlsExt = dsBlockRead (congela lo scroll delle griglie) +
  // DetailDelay:=0 (dettaglio immediato), mantenendo vivo il master/detail.
  // Salva i valori precedenti; ripristinati in AfterPrint.
  // NB: MAI DataSet.DisableControls: sul master disattiva il m/d FireDAC
  // (doc ufficiale) -> dettaglio congelato, report errati.
  for DataSet in FDataSets do
    DataSet.DisableControlsExt;
  if assigned(SelectedDataSet) and not FDataSets.Contains(SelectedDataSet) then
    SelectedDataSet.DisableControlsExt;

  if not ReportName.IsEmpty and assigned(FBeforePrintProc) then
    result := FBeforePrintProc(ReportName);
end;

procedure TzReportsManager.AfterPrint(const ReportName: string);
var
  DataSet: TzFBDataSet;
  ds: TzFBDataSet;
  dsName: string;
begin
  FPipeline.DestroyAll;

  if assigned(frxReport.PreviewPages) then
    frxReport.PreviewPages.Clear;

  frxReport.Clear;

  // ripristina i dataset: toglie dsBlockRead e rimette BlockReadSize/DetailDelay
  // ai valori salvati da DisableControlsExt in BeforePrint (partner simmetrico)
  for DataSet in FDataSets do
    DataSet.EnableControlsExt;
  if assigned(SelectedDataSet) and not FDataSets.Contains(SelectedDataSet) then
    SelectedDataSet.EnableControlsExt;

  // Chiude i dataset aperti automaticamente
  for ds in FOpenedDataSets do
    try
      ds.Active := False;
    except
    end;
  FOpenedDataSets.Clear;

  // Chiude i dataset specificati nel JSON
  for dsName in FDataSetsToClose do
  begin
    ds := GetDataSet(dsName);
    if assigned(ds) and ds.Active then
      try
        ds.Active := False;
      except
      end;
  end;
  FDataSetsToClose.Clear;

  if not ReportName.IsEmpty and assigned(FAfterPrintProc) then
    FAfterPrintProc(ReportName);
end;

// ------------------------------------------------------------------
// Applicazione contesto JSON
// ------------------------------------------------------------------

procedure TzReportsManager.ApplyJsonContext(const ReportName: string; const Context: TzReportJsonConfigContext);

/// Mappa TzJsonPdfConfig (record neutro dal JSON) → TPdfParams (tipo di zOffice.types)
  procedure MapJsonPdf(const Src: TzJsonPdfConfig; var Dest: TPdfParams);
  var
    s: string;
  begin
    if not Src.IsPresent then
      exit;

    s := Src.MethodStr;
    if SameText(s, 'mgfDialog') or SameText(s, 'dialog') then
      Dest.method := mgfDialog
    else
      if SameText(s, 'mgfFileName') or SameText(s, 'filename') then
        Dest.method := mgfFileName
      else
        if SameText(s, 'mgfFieldName') or SameText(s, 'fieldname') then
          Dest.method := mgfFieldName
        else
          if SameText(s, 'mgfTempFile') or SameText(s, 'tempfile') then
            Dest.method := mgfTempFile;

    Dest.FileName := Src.FileName;
    Dest.FieldName := Src.FieldName;
    Dest.OpenFileAfterExport := Src.OpenFileAfterExport;
    Dest.ShowMessageAfterExport := Src.ShowMessageAfterExport;

    s := Src.FontEmbeddingStr;
    if SameText(s, 'none') or SameText(s, 'N') then
      Dest.fontEmbedding := zfeNone
    else
      if SameText(s, 'full') or SameText(s, 'F') then
        Dest.fontEmbedding := zfeFull
      else
        if SameText(s, 'subset') or SameText(s, 'S') then
          Dest.fontEmbedding := zfeSubset;
  end;

var
  zReportDataset: TzJsonDatasetConfig;
  dsList: TStringList;
  key: string;
  varPair: TPair<string, string>;
  b: Boolean;
  pdfParams: TPdfParams;
  wordFragments: TArray<TWordFragment>;
  frag: TzJsonWordFragment;
  i: Integer;
begin
  FReportId := Context.ReportId;
  FReportGroup := Context.ReportGroup;

  // Gate 1 dal profilo su database: il JSON dichiara solo "profilo" e
  // "tipologiaDocumentale"; le azioni le fornisce il controller, una volta
  // per anteprima (il risultato resta nella sessione)
  FProfiloDocumentale := Context.ProfiloDocumentale;
  FTipologiaDocumentale := Context.TipologiaDocumentale;
  FTipoDocumento := Context.TipoDocumento;
  FTipoAllegato := Context.TipoAllegato;
  FAzioniConfig.Clear;
  if not FProfiloDocumentale.IsEmpty then
    if assigned(FActionsController) then
      FAzioniConfig := FActionsController.AzioniDelProfilo(FProfiloDocumentale);

  // Dataset principale
  if not Context.MainDataset.IsEmpty then
    WithMainDataSet(Context.MainDataset);

  // Dataset aggiuntivi
  if Length(Context.DataSets) > 0 then
  begin
    key := ReportName.ToLower;
    if not FReportDataSets.TryGetValue(key, dsList) then
    begin
      dsList := TStringList.Create;
      FReportDataSets.Add(key, dsList);
    end;
    dsList.Clear;

    for zReportDataset in Context.DataSets do
    begin
      dsList.Add(zReportDataset.Name);
      WithDataSet(zReportDataset.Name);
      if zReportDataset.Close then
        FDataSetsToClose.Add(zReportDataset.Name);
    end;
  end;

  // Variabili statiche
  for varPair in Context.Variables do
    FVariables.Set_(varPair.key, varPair.Value);

  // Word
  if Context.Word.IsPresent then
  begin
    WordParams.ReadOnly := Context.Word.ReadOnly;

    // Fragments: TzJsonWordFragment → TWordFragment
    if Length(Context.Word.Fragments) > 0 then
    begin
      SetLength(wordFragments, Length(Context.Word.Fragments));
      for i := 0 to High(Context.Word.Fragments) do
      begin
        frag := Context.Word.Fragments[i];
        wordFragments[i].variableName := frag.variableName;
        wordFragments[i].TemplateFileName := frag.TemplateFileName;
        wordFragments[i].DatasetName := frag.DatasetName;
      end;
      WordParams.Fragments := wordFragments;
    end;

    // NB fase G3: le chiavi deprecate word.firma / word.inviaMail non
    // pilotano piu' nulla (il fallback verso il nodo "azioni" resta nel
    // parsing di zOffice.Reports.Azioni): le azioni passano dal controller

    if Context.Word.pdf.IsPresent then
    begin
      pdfParams := WordParams.pdf;
      MapJsonPdf(Context.Word.pdf, pdfParams);
      WordParams.pdf := pdfParams;
    end;
  end;

  // Excel
  if Context.Excel.IsPresent then
  begin
    ExcelParams.ReadOnly := Context.Excel.ReadOnly;

    b := Context.Excel.AllowBuildReport;
    ExcelParams.AllowBuildReport := function(rn: string): Boolean
      begin
        result := b;
      end;

    if Context.Excel.pdf.IsPresent then
    begin
      pdfParams := ExcelParams.pdf;
      MapJsonPdf(Context.Excel.pdf, pdfParams);
      ExcelParams.pdf := pdfParams;
    end;

    if not Context.Excel.DataBindingJson.IsEmpty then
    begin
      // Cattura in variabile locale per la closure
      var
      dbJson := Context.Excel.DataBindingJson;
      ExcelParams.OnLoadDataBinding := function: string
        begin
          result := dbJson;
        end;
    end;
  end;

  // FastReport
  if Context.FastReport.IsPresent then
  begin
    frxPDFExport.ShowDialog := Context.FastReport.ShowDialog;
    frxPDFExport.OpenAfterExport := Context.FastReport.OpenAfterExport;
    frxPDFExport.EmbeddedFonts := Context.FastReport.EmbeddedFonts;
    frxPDFExport.OverwritePrompt := Context.FastReport.OverwritePrompt;
  end;
end;

// ------------------------------------------------------------------
// Variabili
// ------------------------------------------------------------------

procedure TzReportsManager.AddVariables;
var
  DataSet: TzFBDataSet;
begin
  FVariables.Clear;

  for DataSet in FDataSets do
    AddVariable(DataSet);

  if assigned(FAddVariablesProc) then
    FAddVariablesProc(Self);

  FVariables.SyncToFastReport(frxReport);
end;

procedure TzReportsManager.AddVariable(const Name, Value: string);
begin
  FVariables.Set_(Name, Value);
end;

procedure TzReportsManager.AddVariable(const Name: string; const Value: Variant);
begin
  FVariables.Set_(Name, Value);
end;

procedure TzReportsManager.AddVariable(const DatasetName: string; Params: TFDParams);
begin
  Assert(assigned(Params));
  SiMain.EnterMethod(Self, 'AddVariable');
  FVariables.SetFromParams(Self.Name + '_' + DatasetName, Params);
  SiMain.LeaveMethod(Self, 'AddVariable');
end;

procedure TzReportsManager.AddVariable(Query: TFDQuery);
begin
  Assert(assigned(Query));
  AddVariable(Query.Name, Query.Params);
end;

procedure TzReportsManager.AddVariable(StoredProc: TFDStoredProc);
begin
  Assert(assigned(StoredProc));
  AddVariable(StoredProc.Name, StoredProc.Params);
end;

procedure TzReportsManager.EnumVariableNames(Names: TStrings);
begin
  FVariables.EnumNames(Names);
end;

function TzReportsManager.VariableExists(Name: string): Boolean;
begin
  result := FVariables.Exists(Name);
end;

function TzReportsManager.GetVariable(Name: string): Variant;
begin
  result := FVariables.Resolve(Name);
end;

// ------------------------------------------------------------------
// Dataset
// ------------------------------------------------------------------

procedure TzReportsManager.ClearDataSets;
begin
  FDataSets.Clear;
end;

procedure TzReportsManager.AddDataSet(DataSet: TzFBDataSet);
begin
  if not FDataSets.Contains(DataSet) then
    FDataSets.Add(DataSet);
end;

procedure TzReportsManager.SetFastReportDataSet(const DataSet: TDataSet);
begin
  if assigned(DataSet) then
    frxReport.DataSet := FPipeline.GetPipeline(DataSet)
  else
    frxReport.DataSet := nil;
end;

function TzReportsManager.GetDataSet(const DatasetName: string): TzFBDataSet;
var
  DataSet: TzFBDataSet;
begin
  result := nil;

  if DatasetName.IsEmpty then
    result := SelectedDataSet
  else
    for DataSet in FDataSets do
      if SameText(DataSet.Name, DatasetName) or SameText(FPipeline.PipelineName(DataSet), DatasetName) then
      begin
        result := DataSet;
        exit;
      end;

  if not assigned(result) then
    result := SelectedDataSet;

  if not assigned(result) and (FDataSets.Count > 0) then
    result := FDataSets[0];
end;

function TzReportsManager.GetDataSetNames: string;
var
  StringList: TStringList;
  DataSet: TzFBDataSet;
begin
  StringList := TStringList.Create;
  try
    for DataSet in FDataSets do
      StringList.Add(DataSet.Name + ' = ' + FPipeline.PipelineName(DataSet));
    result := StringList.Text;
  finally
    FreeAndNil(StringList);
  end;
end;

function TzReportsManager.GetDataSetPipeName(const DatasetName: string): string;
begin
  result := FPipeline.PipelineNameByDatasetName(DatasetName);
end;

// ------------------------------------------------------------------
// Load / Prepare report
// ------------------------------------------------------------------

function TzReportsManager.LoadReport(ReportName: string): Boolean;
var
  Report: TzFile;
begin
  result := False;

  Report := GetReport(ReportName);
  if not assigned(Report) then
  begin
    ConfirmOk('Report non trovato: ' + ReportName, mtWarning);
    exit;
  end;

  result := LoadReportFile(Report);
end;

function TzReportsManager.LoadReportFile(Report: TzFile): Boolean;
begin
  result := FFastReport.LoadFromFile(Report.FullName);

  if result and assigned(FReportLoadedProc) then
    FReportLoadedProc(Report.Name);
end;

function TzReportsManager.PrepareReport(Report: string): Boolean;
begin
  result := LoadReport(Report) and FFastReport.PrepareReport;
end;

// ------------------------------------------------------------------
// Azioni report pubbliche
// ------------------------------------------------------------------

procedure TzReportsManager.ShowPreview(Report: TzFile);
begin
  case TReportKind.FromString(Report.FileExt) of
    rkFastReport:
      begin
        if LoadReportFile(Report) then
          FFastReport.Preview;
      end;
    rkWord:
      begin
        WordParams.TemplateFileName := Report.FullName;
        zOffice.MailMerge(WordParams);
      end;
    rkExcel:
      begin
        ExcelParams.TemplateFileName := Report.FullName;
        zOffice.BuildSpreadSheetReport(ExcelParams);
      end;
  end;
end;

procedure TzReportsManager.Preview(const ReportName: string; DataSet: TzFBDataSet);
var
  Report: TzFile;
  ok: Boolean;
begin
  if assigned(DataSet) then
    SelectedDataSet := DataSet;

  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := GetReport(ReportName);
    if not assigned(Report) then
    begin
      ConfirmOk('Report non trovato: ' + ReportName, mtWarning);
      exit;
    end;

    ShowPreview(Report);
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.PreviewFile(Report: TzFile; DataSet: TzFBDataSet);
var
  ok: Boolean;
  ReportName, ReportFullName: string;
begin
  if not assigned(Report) then
    exit;

  if assigned(DataSet) then
    SelectedDataSet := DataSet;

  // Mantis #315 - 2026-11-03: BeforePrint ricarica i report (LoadReports ->
  // Reports.Clear) e distrugge il TzFile ricevuto: nome e percorso si copiano
  // prima e il file si ritrova dopo, dal percorso completo.
  ReportName := Report.Name;
  ReportFullName := Report.FullName;

  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := Reports.FileByFullName(ReportFullName);
    if not assigned(Report) then
    begin
      ConfirmOk('Report non trovato: ' + ReportFullName, mtWarning);
      exit;
    end;

    ShowPreview(Report);
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.Print(const ReportName: string);
var
  Report: TzFile;
  ok: Boolean;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := GetReport(ReportName);
    if not assigned(Report) then
    begin
      ConfirmOk('Report non trovato: ' + ReportName, mtWarning);
      exit;
    end;

    case TReportKind.FromString(Report.FileExt) of
      rkFastReport:
        begin
          if LoadReport(ReportName) then
            FFastReport.Print;
        end;
      rkWord:
        begin
          WordParams.TemplateFileName := Report.FullName;
          zOffice.MailMerge(WordParams);
        end;
      rkExcel:
        begin
          ExcelParams.TemplateFileName := Report.FullName;
          zOffice.BuildSpreadSheetReport(ExcelParams);
        end;
    end;
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.ShowDesigner(Report: TzFile);
begin
  case TReportKind.FromString(Report.FileExt) of
    rkFastReport:
      FFastReport.OpenDesigner(Report, Reports.FullName);
    rkWord:
      begin
        WordParams.TemplateFileName := Report.FullName;
        WordParams.DefaultFolder := Reports.FullName;
        zOffice.EditTemplateWord(WordParams);
      end;
    rkExcel:
      begin
        ExcelParams.TemplateFileName := Report.FullName;
        ExcelParams.DefaultFolder := Reports.FullName;
        zOffice.EditTemplateExcel(ExcelParams);
      end;
  end;
end;

procedure TzReportsManager.DesignFile(Report: TzFile);
var
  ok: Boolean;
  ReportName, ReportFullName: string;
begin
  if not assigned(Report) then
    exit;

  // Mantis #315 - 2026-11-03: vedi PreviewFile, il TzFile ricevuto non
  // sopravvive a BeforePrint.
  ReportName := Report.Name;
  ReportFullName := Report.FullName;

  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := Reports.FileByFullName(ReportFullName);
    if not assigned(Report) then
    begin
      ConfirmOk('Report non trovato: ' + ReportFullName, mtWarning);
      exit;
    end;

    ShowDesigner(Report);
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.Design(ReportName: string);
var
  Report: TzFile;
  ok: Boolean;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := GetReport(ReportName);
    if not assigned(Report) then
    begin
      ConfirmOk('Report non trovato: ' + ReportName, mtWarning);
      exit;
    end;

    ShowDesigner(Report);
  finally
    AfterPrint(ReportName);
    LoadReports;
  end;
end;

procedure TzReportsManager.NewReport;
  function ChooseReportKind: Integer;
  var
    s: string;
  begin
    result := -1;
    s := '0';
    if not InputCombo('Tipo Report', 'Tipo Report', s, nil, images, True, True,
      procedure(dlg: TInputDialog)
      var
        props: TcxImageComboBoxProperties;

        procedure AddItem(p: TcxImageComboBoxProperties; Description: string; Value, ImageIndex: Integer);
        var
          item: TcxImageComboBoxItem;
        begin
          item := p.Items.Add;
          item.Description := Description;
          item.Value := Value;
          item.ImageIndex := ImageIndex;
        end;

      begin
        dlg.Width := 200;
        props := (dlg.cxCustomEdit as TcxImageComboBox).Properties;
        AddItem(props, 'FastReport', 0, 0);
        AddItem(props, 'Template Word', 1, 1);
        AddItem(props, 'Template Excel', 2, 2);
      end) then
      exit;
    result := s.ToInteger;
  end;

var
  idx: Integer;
begin
  idx := ChooseReportKind;

  // Scelta annullata: niente da aprire e niente da rileggere.
  if idx < 0 then
    exit;

  try
    case idx of
      0:
        FFastReport.OpenDesigner(nil, Reports.FullName);
      1:
        begin
          // Il template nuovo non ha ancora un nome: la cartella dei report dice
          // all'editor dove proporre il salvataggio.
          WordParams.TemplateFileName := '';
          WordParams.DefaultFolder := Reports.FullName;
          zOffice.EditTemplateWord(WordParams);
        end;
      2:
        begin
          // Come per Word: la cartella dei report dice all'editor dove salvare.
          ExcelParams.TemplateFileName := '';
          ExcelParams.DefaultFolder := Reports.FullName;
          zOffice.EditTemplateExcel(ExcelParams);
        end;
    end;
  finally
    // Come in Design: il report nuovo e' su disco, la lista lo deve rileggere.
    // LoadReports avvisa la form (OnReportsReloading / OnReportsReloaded), che
    // rigenera l'albero mantenendo la selezione.
    LoadReports;
  end;
end;

procedure TzReportsManager.ShowReportForm(aSelectedDataSet: TzFBDataSet);
var
  ReportsForm: TzReportsForm;
begin
  SelectedDataSet := aSelectedDataSet;
  LoadReports;
  Application.CreateForm(TzReportsForm, ReportsForm);
  try
    ReportsForm.ShowReportForm(Self, FzSystem);
  finally
    FreeAndNil(ReportsForm);
  end;
end;

// ------------------------------------------------------------------
// LoadReports / GetReport / GetFolder
// ------------------------------------------------------------------

procedure TzReportsManager.LoadReports;
var
  SharedFiles: TStrings;
const
  ReportFileExts: TAllowedFileExts = ['*.fr3', '*.docx', '*.xlsx'];
begin
  // Mantis #139 - 2026-09-19: Reports.Clear distrugge tutti i TzFile e i
  // TzFolder. Chi li tiene per riferimento va avvisato prima, non dopo.
  if assigned(FOnReportsReloading) then
    FOnReportsReloading(Self);

  SharedFiles := ParsedSharedReports;
  try
    Reports.Clear;
    Reports.FullName := zReportConfig.ReportRoot + Folder;
    Reports.LoadFolder(nil, Folder, ReportFileExts, ExcludeFolders);
    Reports.LoadSharedFiles(zReportConfig.ReportRoot, SharedFiles, ReportFileExts);
  finally
    FreeAndNil(SharedFiles);
  end;

  // Mantis #139 - 2026-09-19: oggetti nuovi, chi guarda l'albero lo rigenera.
  if assigned(FOnReportsReloaded) then
    FOnReportsReloaded(Self);
end;

function TzReportsManager.GetReport(const ReportName: string): TzFile;
begin
  result := nil;
  if assigned(Reports) then
    result := Reports.FileByName(ReportName);
end;

function TzReportsManager.GetFolder(const Folder: string): string;
begin
  result := IncludeTrailingPathDelimiter(zReportConfig.ReportRoot + Folder);
  ForceDirectories(result);
end;

function TzReportsManager.ParsedSharedReports: TStrings;
var
  DataSet: TDataSet;
  DatasetName, FieldName, FileName, ReportName: string;
  idx: Integer;
  s: string;
begin
  SiMain.EnterMethod(Self, 'ParsedSharedReports');
  result := TStringList.Create;
  try
    for idx := 0 to SharedReports.Count - 1 do
    begin
      s := SharedReports[idx];

      if not s.Contains('=') then
        result.Add(s)
      else
        if not SharedReports.ValueFromIndex[idx].Trim.StartsWith('[') then
          result.Add(s)
        else
        begin
          ReportName := SharedReports.KeyNames[idx];
          FileName := SharedReports.ValueFromIndex[idx].Trim.Replace('[', '').Replace(']', '');

          DatasetName := FileName.Substring(0, FileName.IndexOf('.'));
          FieldName := FileName.Substring(FileName.IndexOf('.') + 1);

          DataSet := GetDataSet(DatasetName);
          if assigned(DataSet) then
          begin
            if assigned(DataSet.FindField(FieldName)) then
            begin
              FileName := DataSet.FieldByName(FieldName).AsString;
              result.AddPair(ReportName, FileName);
            end
            else
              SiMain.LogError('Field non trovato: ' + FieldName);
          end
          else
            SiMain.LogError('DataSet non trovato: ' + DatasetName);
        end;
    end;
  except
    result.Free;
    raise;
  end;
  SiMain.LeaveMethod(Self, 'ParsedSharedReports');
end;

// ------------------------------------------------------------------
// Batch — livello basso
// ------------------------------------------------------------------

procedure TzReportsManager.BatchInit(const ReportName: string);
begin
  FBatchActive := False;
  if not BeforePrint(ReportName) then
    exit;
  if not LoadReport(ReportName) then
    exit;
  FBatchRunner.Init;
  FBatchActive := True;
end;

procedure TzReportsManager.BatchPrint(const DocumentLabel: string; ShowPrinterDialog: Boolean);
begin
  FBatchRunner.Print(DocumentLabel, ShowPrinterDialog);
end;

function TzReportsManager.BatchExportPdf(const FileName: string): Boolean;
begin
  result := FBatchRunner.ExportPdf(FileName);
end;

procedure TzReportsManager.BatchDone;
begin
  FBatchActive := False;
  FBatchRunner.Done;
end;

// ------------------------------------------------------------------
// Batch — livello alto
// ------------------------------------------------------------------

procedure TzReportsManager.RunBatchPrint(const ReportName: string; Controller: TzBatchController; const ProgressCaption: string);
begin
  FBatchRunner.RunPrint(ReportName, FReports, Controller, ProgressCaption);
end;

function TzReportsManager.RunBatchExportPdf(const ReportName: string; Controller: TzBatchController; OutputFolder: string; const ProgressCaption: string): Integer;
begin
  result := FBatchRunner.RunExportPdf(ReportName, FReports, Controller, OutputFolder, ProgressCaption);
end;

// ------------------------------------------------------------------
// Azioni documentali
// ------------------------------------------------------------------

function TzReportsManager.ConfiguraAzioniDocumento(AOwner: TComponent; EsportaPdfTemporaneo: TFunc<string>): TzDocumentActionsBarHelper;
begin
  result := nil;

  // senza controller applicativo o senza nodo "azioni" nel template
  // il gruppo "Documento" non viene agganciato (il viewer lo nasconde)
  if not assigned(FActionsController) then
    exit;
  if not FAzioniConfig.IsPresent then
    exit;

  FOnEsportaDocumentoPdf := EsportaPdfTemporaneo;

  // Owner = form del viewer: l'helper vive e muore con lei.
  // I fornitori di dato (Stato/Motivo/Estremi/persistito) vengono interrogati
  // dall'helper ad ogni OnUpdate delle Action: non serve piu' un "aggiornaStati"
  // esplicito, e' il framework delle Action a ridomandare lo stato di continuo.
  result := TzDocumentActionsBarHelper.Create(AOwner, StatoAzione, MotivoBloccoAzione, EstremiAzione,
    function: Boolean
    begin
      result := FDocumentoCorrente <> 0;
    end);

  result.OnEsegui := procedure(Azione: TzAzioneDocumento)
    begin
      try
        EseguiAzione(Azione);
        // niente ricalcolo manuale: l'OnUpdate delle Action rilegge lo stato
        // e la firma completata sblocca la PEC nella stessa sessione
      except
        on E: EzAzioneDocumentoBloccata do
          ConfirmOk(E.Message, mtWarning);
      end;
    end;

  result.OnAggiornaStato := procedure(Azione: TzAzioneDocumento)
    begin
      AggiornaStatoAzione(Azione);
    end;

  result.OnVediEstremi := procedure(Azione: TzAzioneDocumento)
    begin
      ConfirmOk(DescrizioneAzioneDocumento(Azione) + ': ' + EstremiAzione(Azione), mtInformation);
    end;

  result.PuoGenerareAllegatoFunc := function: Boolean
    begin
      result := PuoGenerareAllegato;
    end;

  result.OnGeneraAllegato := procedure
    begin
      try
        PersistiDocumentoCorrente;
        // niente ricalcolo manuale: l'OnUpdate delle Action rilegge lo stato
      except
        on E: EzAzioneDocumentoBloccata do
          ConfirmOk(E.Message, mtWarning);
      end;
    end;
end;

procedure TzReportsManager.SetActionsController(const Value: TzDocumentActionsController);
begin
  if FActionsController = Value then
    exit;

  if assigned(FActionsController) then
    FActionsController.RemoveFreeNotification(Self);

  FActionsController := Value;

  if assigned(FActionsController) then
    FActionsController.FreeNotification(Self);
end;

function TzReportsManager.ContestoCorrente: TzDocumentoContesto;
begin
  result.Clear;
  result.IdObjectFile := FDocumentoCorrente;

  result.Oid := FOidCorrente;
  if result.Oid = 0 then
    if assigned(FOnGetOid) then
      result.Oid := FOnGetOid()
    else
      // fallback generico: il dataset selezionato dichiara da solo la sua
      // colonna OID (FieldNameOID), come gia' fa TzMultiViewer.CurrentOid.
      // OnGetOid resta prioritario per compatibilita' coi casi che oggi
      // risolvono l'OID con una logica applicativa (es. i contratti Gesty)
      if assigned(SelectedDataSet) then
        result.Oid := SelectedDataSet.Oid;

  result.ReportName := FReportCorrente;
  result.TipologiaDocumentale := FTipologiaDocumentale;
  result.Profilo := FProfiloDocumentale;
  result.TipoDocumento := FTipoDocumento;
  result.TipoAllegato := FTipoAllegato;
  result.AzioniConfig := FAzioniConfig;
end;

function TzReportsManager.StatoAzione(Azione: TzAzioneDocumento): TzAzioneDocumentoStato;
begin
  // gate 1: capacita' del template (JSON)
  if not FAzioniConfig.Abilitata(Azione) then
    exit(adsNonDisponibile);

  // nessun controller assegnato = nessuna azione
  if not assigned(FActionsController) then
    exit(adsNonDisponibile);

  // gate 2-4 nel controller applicativo
  result := FActionsController.Stato(Azione, ContestoCorrente);
end;

function TzReportsManager.MotivoBloccoAzione(Azione: TzAzioneDocumento): string;
begin
  result := '';
  if assigned(FActionsController) then
    result := FActionsController.MotivoBlocco(Azione, ContestoCorrente);
end;

function TzReportsManager.EstremiAzione(Azione: TzAzioneDocumento): string;
begin
  result := '';
  if assigned(FActionsController) then
    result := FActionsController.Estremi(Azione, ContestoCorrente);
end;

procedure TzReportsManager.EseguiAzione(Azione: TzAzioneDocumento);
var
  fileTemporaneo: string;
begin
  if not assigned(FActionsController) then
    raise EzAzioneDocumentoBloccata.Create('Nessun controller delle azioni documentali assegnato (ActionsController)');

  // persistenza pigra al primo utilizzo: stessa logica del comando
  // "Genera allegato", un solo punto di verita'
  if FDocumentoCorrente <= 0 then
    PersistiDocumentoCorrente;

  // il controller RIVERIFICA le precondizioni (EzAzioneDocumentoBloccata
  // se violate): vale anche per batch e chiamate applicative dirette
  FActionsController.Esegui(Azione, ContestoCorrente);
end;

procedure TzReportsManager.AggiornaStatoAzione(Azione: TzAzioneDocumento);
begin
  if assigned(FActionsController) then
    FActionsController.AggiornaStato(Azione, ContestoCorrente);
end;

function TzReportsManager.WithOid(const Oid: Int64): TzReportsManager;
begin
  FOidCorrente := Oid;
  result := Self;
end;

// ------------------------------------------------------------------
// Fluent API
// ------------------------------------------------------------------

function TzReportsManager.SetVar(const Name: string; const Value: Variant): TzReportsManager;
begin
  FVariables.Set_(Name, Value);
  result := Self;
end;

function TzReportsManager.SetVar(const Name, Value: string): TzReportsManager;
begin
  FVariables.Set_(Name, Value);
  result := Self;
end;

function TzReportsManager.ClearVars: TzReportsManager;
begin
  FVariables.Clear;
  result := Self;
end;

function TzReportsManager.OnBeforePrint(AProc: TFunc<string, Boolean>): TzReportsManager;
begin
  FBeforePrintProc := AProc;
  result := Self;
end;

function TzReportsManager.OnAfterPrint(AProc: TProc<string>): TzReportsManager;
begin
  FAfterPrintProc := AProc;
  result := Self;
end;

function TzReportsManager.WithDataSet(DataSet: TzFBDataSet): TzReportsManager;
begin
  if assigned(DataSet) then
    AddDataSet(DataSet);
  result := Self;
end;

function TzReportsManager.WithDataSet(const DatasetName: string): TzReportsManager;
begin
  result := WithDataSet(GetDataSet(DatasetName));
end;

function TzReportsManager.WithMainDataSet(DataSet: TzFBDataSet): TzReportsManager;
begin
  if assigned(DataSet) then
  begin
    AddDataSet(DataSet);
    SelectedDataSet := DataSet;
  end;
  result := Self;
end;

function TzReportsManager.WithMainDataSet(const DatasetName: string): TzReportsManager;
begin
  result := WithMainDataSet(GetDataSet(DatasetName));
end;

function TzReportsManager.RegisterReportDataSets(const ReportName: string; const DataSetNames: array of string): TzReportsManager;
var
  dsList: TStringList;
  dsName: string;
  key: string;
begin
  key := ReportName.ToLower;
  if not FReportDataSets.TryGetValue(key, dsList) then
  begin
    dsList := TStringList.Create;
    FReportDataSets.Add(key, dsList);
  end;
  dsList.Clear;
  for dsName in DataSetNames do
    dsList.Add(dsName);
  result := Self;
end;

function TzReportsManager.OnWordBeforeShow(AProc: TProc<string, TdxRichEditControl>): TzReportsManager;
begin
  WordBeforeShow := AProc;
  result := Self;
end;

function TzReportsManager.OnExcelBeforeBuild(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
begin
  ExcelBeforeBuild := AProc;
  result := Self;
end;

function TzReportsManager.OnExcelAfterBuild(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
begin
  ExcelAfterBuild := AProc;
  result := Self;
end;

function TzReportsManager.OnExcelBeforeShow(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
begin
  ExcelBeforeShow := AProc;
  result := Self;
end;

function TzReportsManager.OnExcelGetDataSource(AFunc: TFunc<string, TDataSource>): TzReportsManager;
begin
  ExcelOnGetDataSource := AFunc;
  result := Self;
end;

function TzReportsManager.OnExcelAllowBuild(AFunc: TFunc<string, Boolean>): TzReportsManager;
begin
  ExcelAllowBuildReport := AFunc;
  result := Self;
end;

// ------------------------------------------------------------------
// Evento FastReport
// ------------------------------------------------------------------

procedure TzReportsManager.frxReportBeginDoc(Sender: TObject);
begin
  FVariables.SyncToFastReport(frxReport);
end;

function TzReportsManager.frxDesignerLoadReport(Report: TfrxReport): Boolean;
begin
  FPipeline.CreateAll;
  FVariables.SyncToFastReport(frxReport);
  result := True;
end;

procedure TzReportsManager.frxDesignerShow(Sender: TObject);
begin
  StopWait;
end;

procedure TzReportsManager.frxReportPreview(Sender: TObject);
var
  frxComponent: TfrxComponent;
  page, i: Integer;
begin
  if FFastReport.ModificaAnteprima then
    for page := 0 to frxReport.PreviewPages.Count - 1 do
      for i := 0 to frxReport.PreviewPages.page[page].AllObjects.Count - 1 do
      begin
        if TComponent(frxReport.PreviewPages.page[page].AllObjects.Items[i]) is TfrxComponent then
        begin
          frxComponent := TfrxComponent(frxReport.PreviewPages.page[page].AllObjects.Items[i]);
          frxComponent.Editable := frxComponent.Editable + [ferAllowInPreview];
        end;
      end;
end;

function TzReportsManager.frxReportUserFunction(const MethodName: string; var Params: Variant): Variant;
begin
  result := null;
end;

// ------------------------------------------------------------------
// Notification
// ------------------------------------------------------------------

procedure TzReportsManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent is TzFBDataSet) then
    FDataSets.Remove(AComponent as TzFBDataSet);

  if (Operation = opRemove) and (AComponent = FActionsController) then
    FActionsController := nil;
end;

// ------------------------------------------------------------------
// Setter vari
// ------------------------------------------------------------------

procedure TzReportsManager.SetDefaultDatabase(const Value: TFDConnection);
begin
  FDefaultDatabase := Value;
  if assigned(frxFDComponents) then
    frxFDComponents.DefaultDatabase := Value;
end;

procedure TzReportsManager.SetSharedReports(const Value: TStringList);
begin
  FSharedReports.Assign(Value);
end;

procedure TzReportsManager.SetExcludeFolders(const Value: TExcludeFolders);
begin
  FExcludeFolders := Value;
end;

// ------------------------------------------------------------------
// Wrappers OnGetVariable
// ------------------------------------------------------------------

function TzReportsManager.GetOnGetVariable: TFunc<string, Variant>;
begin
  result := FVariables.OnGetVariable;
end;

procedure TzReportsManager.SetOnGetVariable(Value: TFunc<string, Variant>);
begin
  FVariables.OnGetVariable := Value;
end;

// ------------------------------------------------------------------
// Wrappers Word params
// ------------------------------------------------------------------

function TzReportsManager.GetWordBeforeShow: TProc<string, TdxRichEditControl>;
begin
  result := WordParams.BeforeShowProc;
end;

procedure TzReportsManager.SetWordBeforeShow(Value: TProc<string, TdxRichEditControl>);
begin
  WordParams.BeforeShowProc := Value;
end;

// ------------------------------------------------------------------
// Wrappers Excel params
// ------------------------------------------------------------------

function TzReportsManager.GetExcelBeforeShow: TProc<string, TdxSpreadSheet>;
begin
  result := ExcelParams.BeforeShow;
end;

procedure TzReportsManager.SetExcelBeforeShow(Value: TProc<string, TdxSpreadSheet>);
begin
  ExcelParams.BeforeShow := Value;
end;

function TzReportsManager.GetExcelAfterBuild: TProc<string, TdxSpreadSheet>;
begin
  result := ExcelParams.AfterBuild;
end;

procedure TzReportsManager.SetExcelAfterBuild(Value: TProc<string, TdxSpreadSheet>);
begin
  ExcelParams.AfterBuild := Value;
end;

function TzReportsManager.GetExcelBeforeBuild: TProc<string, TdxSpreadSheet>;
begin
  result := ExcelParams.BeforeBuild;
end;

procedure TzReportsManager.SetExcelBeforeBuild(Value: TProc<string, TdxSpreadSheet>);
begin
  ExcelParams.BeforeBuild := Value;
end;

function TzReportsManager.GetExcelAllowBuildReport: TFunc<string, Boolean>;
begin
  result := ExcelParams.AllowBuildReport;
end;

procedure TzReportsManager.SetExcelAllowBuildReport(Value: TFunc<string, Boolean>);
begin
  ExcelParams.AllowBuildReport := Value;
end;

function TzReportsManager.GetExcelOnGetDataSource: TFunc<string, TDataSource>;
begin
  result := ExcelParams.OnGetDataSource;
end;

procedure TzReportsManager.SetExcelOnGetDataSource(Value: TFunc<string, TDataSource>);
begin
  ExcelParams.OnGetDataSource := Value;
end;

function TzReportsManager.PersistiDocumentoCorrente: Int64;
var
  fileTemporaneo: string;
begin
  if FDocumentoCorrente <> 0 then
    exit(FDocumentoCorrente);

  if not assigned(FActionsController) then
    raise EzAzioneDocumentoBloccata.Create('Nessun controller delle azioni documentali assegnato (ActionsController)');

  if not assigned(FOnEsportaDocumentoPdf) then
    raise EzAzioneDocumentoBloccata.Create('OnEsportaDocumentoPdf non assegnato: il viewer non ha fornito il documento da persistere');

  fileTemporaneo := FOnEsportaDocumentoPdf();
  try
    FDocumentoCorrente := FActionsController.PersistDocument(ContestoCorrente, fileTemporaneo);
  finally
    // PersistDocument ha copiato il file nella posizione definitiva
    // calcolata dal DB: il temporaneo non serve piu'
    try
      if TFile.Exists(fileTemporaneo) then
        TFile.Delete(fileTemporaneo);
    except
    end;
  end;

  result := FDocumentoCorrente;
end;

function TzReportsManager.PuoGenerareAllegato: Boolean;
begin
  result := assigned(FActionsController) and FAzioniConfig.IsPresent and assigned(FOnEsportaDocumentoPdf) and (FDocumentoCorrente = 0);
end;

end.
