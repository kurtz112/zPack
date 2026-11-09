unit zOffice.Reports;

interface

uses
  System.SysUtils,
  System.Classes,
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
  zFileSystem,
  zSystem,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  frLocalization,
  frLanguageItalian,
  Vcl.Dialogs,
  zProgressBox,
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
    FFolder: string;
    FExcludeFolders: TExcludeFolders;
    FSharedReports: TStringList;
    FReports: TzFolder;
    FDataSets: TList<TzFBDataSet>;
    FVisibleDataSets: TStrings;
    FMailMergeDataSet: TzFBDataSet;
    FPipes: TList<TfrxDBDataSet>;
    frxFDComponents: TfrxFDComponents;
    FUserVariables: TDictionary<string, Variant>; // Centralized Variables Dictionary
    FReportDataSets: TObjectDictionary<string, TStringList>; // Auto-Open datasets mapping
    FOpenedDataSets: TList<TzFBDataSet>; // Tracks datasets opened during printing
    FReportId: string;
    FReportGroup: string;
    FDataSetsToClose: TStringList;
    FDefaultDatabase: TFDConnection;
    FCurrentUserDisplayName: string;
    FJsonPath: string;
    FzSystem: TzSystem;
    procedure LoadReportJsonConfig(const ReportName: string);
    function AddWordFragment(const DatasetName: string): string;
    function SaveExcelDataBinding(const jsonStr: string): Boolean;
    procedure SetDefaultDatabase(const Value: TFDConnection);
  private
    function CreatePipeline(DataSet: TDataSet; const aName: string = ''; const aPipelineName: string = ''): TfrxDBDataSet;
    function GetPipeline(DataSet: TDataSet; const aName: string = ''; const aPipelineName: string = ''): TfrxDBDataSet;

    procedure CreatePipes;
    procedure DestroyPipes;
    function GetPipelineName(DataSet: TDataSet): string;
  private
    FOnCustomGetVariable: TFunc<string, Variant>;
    FBeforePrintProc: TFunc<string, Boolean>;
    FAfterPrintProc: TProc<string>;
    FAddVariablesProc: TProc<TzReportsManager>;
  private
    FReportLoadedProc: TProc<string>;
    ModificaAnteprima: Boolean;
    FBatchActive: Boolean;
    procedure InitModificaAnteprima;
  private
    function LoadReport(ReportName: string): Boolean;
    function BeforePrint(const ReportName: string): Boolean;
    procedure AfterPrint(const ReportName: string);
    function PrepareReport(Report: string): Boolean;
    procedure FreeReportMemory;
    procedure AddVariables;
    function GetDataSetNames: string;
    function GetDataSet(const DatasetName: string): TzFBDataSet;
    function GetDataSetPipeName(const DatasetName: string): string;

    procedure SetSharedReports(const Value: TStringList);

    property Pipes: TList<TfrxDBDataSet> read FPipes;
    property VisibleDataSets: TStrings read FVisibleDataSets;
  private
    function ParsedSharedReports: TStrings;
  private
    procedure PreviewFastReport(ReportName: string);
    procedure PrintFastReport(ReportName: string);
    function ExportFastReport(ReportName: string; const FileNamePdf: string): Integer;
    procedure EditFastReport(ReportName: string);
    procedure ShowDesigner(ReportName: string);
    procedure NewFastReport();
  private
    // Getter/Setter Wrappers for WordParams/ExcelParams for IDE Autocomplete and discovery
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
    function GetWordFirmaEnabled: TFunc<string, Boolean>;
    procedure SetWordFirmaEnabled(Value: TFunc<string, Boolean>);
    function GetWordFirmaDoc: TProc<string>;
    procedure SetWordFirmaDoc(Value: TProc<string>);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure LoadReports;
  public
    procedure AddVariable(const Name: string; const Value: string); overload;
    procedure AddVariable(const Name: string; const Value: Variant); overload;
    procedure AddVariable(const DatasetName: string; Params: TFDParams); overload;
    procedure AddVariable(Query: TFDQuery); overload;
    procedure AddVariable(StoredProc: TFDStoredProc); overload;

    procedure EnumVariableNames(Names: TStrings);
    function VariableExists(Name: string): Boolean;

    function GetVariable(Name: string): Variant;
  private
    function GetExpressionVar(const variableName: string; out Value: Variant): Boolean;
    procedure SetExcludeFolders(const Value: TExcludeFolders);
  public
    procedure ShowReportForm(aSelectedDataSet: TzFBDataSet);

    function GetFolder(const Folder: string): string;

    function GetReport(const ReportName: String): TzFile;

    procedure Preview(const ReportName: string; DataSet: TzFBDataSet = nil);
    procedure Print(const ReportName: string);
    procedure Design(ReportName: string);
    procedure NewReport;
  public
    procedure SetFastReportDataSet(const DataSet: TDataSet);
  public
    procedure ClearDataSets;
    procedure AddDataSet(DataSet: TzFBDataSet);
  public
    // -------------------------------------------------------------------------
    // Batch (stampa/export massivo) - equivalente dei metodi Massiv* di zFormReports
    // -------------------------------------------------------------------------

    /// Inizializza il motore FastReport per una sessione batch (senza UI).
    /// Deve essere chiamato una volta prima del ciclo BatchPrint/BatchExportPdf.
    procedure BatchInit(const ReportName: string);

    /// Stampa un singolo documento nella sessione batch.
    /// FileName è usato come ReportOptions.Name (utile per log/identificazione).
    /// Il dialogo stampante viene mostrato solo al primo documento (gestito dal caller).
    procedure BatchPrint(const DocumentLabel: string; ShowPrinterDialog: Boolean = False);

    /// Esporta un singolo documento PDF nella sessione batch.
    /// FileName deve essere il percorso completo del file PDF di destinazione.
    function BatchExportPdf(const FileName: string): Boolean;

    /// Chiude la sessione batch e ripristina le impostazioni normali.
    procedure BatchDone;

    // --- Livello alto: ciclo completo guidato da TzBatchController (FastReport + Word + Excel) ---

    /// Esegue la stampa batch per tutti i tipi di report (FastReport, Word, Excel).
    /// Usa TzBatchController per iterare i record (Init/Next/Count).
    /// Mostra la ProgressBox integrata del datamodule; supporta la cancellazione.
    procedure RunBatchPrint(const ReportName: string; Controller: TzBatchController; const ProgressCaption: string = 'Stampa in corso');

    /// Esegue l'export PDF batch per tutti i tipi di report (FastReport, Word, Excel).
    /// Usa TzBatchController.FileNamePdf per il nome file di ogni documento.
    /// OutputFolder: cartella di destinazione; se vuoto viene chiesta all'utente con SelectDirectory.
    /// Restituisce il numero di PDF generati.
    function RunBatchExportPdf(const ReportName: string; Controller: TzBatchController; OutputFolder: string = ''; const ProgressCaption: string = 'Generazione PDF'): Integer;
  public
    property SelectedDataSet: TzFBDataSet read FMailMergeDataSet write FMailMergeDataSet;
    property ReportId: string read FReportId write FReportId;
    property ReportGroup: string read FReportGroup write FReportGroup;

    property DataSets: TList<TzFBDataSet> read FDataSets;
    property DataSetNames: string read GetDataSetNames;
  public
    property Folder: string read FFolder write FFolder;
    property ExcludeFolders: TExcludeFolders read FExcludeFolders write FExcludeFolders;

    property SharedReports: TStringList read FSharedReports write SetSharedReports;

    property Reports: TzFolder read FReports;
  public
  private
    WordParams: TWordParams;
    ExcelParams: TExcelParams;
  public
    property ReportLoadedProc: TProc<string> read FReportLoadedProc write FReportLoadedProc;
    property BeforePrintProc: TFunc<string, Boolean> read FBeforePrintProc write FBeforePrintProc;
    property AfterPrintProc: TProc<string> read FAfterPrintProc write FAfterPrintProc;

    property AddVariablesProc: TProc<TzReportsManager> read FAddVariablesProc write FAddVariablesProc;
    property OnCustomGetVariable: TFunc<string, Variant> read FOnCustomGetVariable write FOnCustomGetVariable;

    // Easy Access Property wrappers to avoid direct WordParams/ExcelParams record access
    property WordBeforeShow: TProc<string, TdxRichEditControl> read GetWordBeforeShow write SetWordBeforeShow;
    property WordFirmaEnabled: TFunc<string, Boolean> read GetWordFirmaEnabled write SetWordFirmaEnabled;
    property WordFirmaDoc: TProc<string> read GetWordFirmaDoc write SetWordFirmaDoc;

    property ExcelBeforeShow: TProc<string, TdxSpreadSheet> read GetExcelBeforeShow write SetExcelBeforeShow;
    property ExcelBeforeBuild: TProc<string, TdxSpreadSheet> read GetExcelBeforeBuild write SetExcelBeforeBuild;
    property ExcelAfterBuild: TProc<string, TdxSpreadSheet> read GetExcelAfterBuild write SetExcelAfterBuild;
    property ExcelAllowBuildReport: TFunc<string, Boolean> read GetExcelAllowBuildReport write SetExcelAllowBuildReport;
    property ExcelOnGetDataSource: TFunc<string, TDataSource> read GetExcelOnGetDataSource write SetExcelOnGetDataSource;

    // Fluent Chaining Methods (Variables & Properties)
    function SetVar(const Name: string; const Value: Variant): TzReportsManager; overload;
    function SetVar(const Name: string; const Value: string): TzReportsManager; overload;
    function ClearVars: TzReportsManager;

    // Chaining configuration helpers
    function OnBeforePrint(AProc: TFunc<string, Boolean>): TzReportsManager;
    function OnAfterPrint(AProc: TProc<string>): TzReportsManager;

    // Chaining callback helpers
    function OnWordBeforeShow(AProc: TProc<string, TdxRichEditControl>): TzReportsManager;
    function OnWordFirmaEnabled(AFunc: TFunc<string, Boolean>): TzReportsManager;
    function OnWordFirmaDoc(AProc: TProc<string>): TzReportsManager;

    // Chaining callback helpers Excel
    function OnExcelBeforeBuild(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
    function OnExcelAfterBuild(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
    function OnExcelBeforeShow(AProc: TProc<string, TdxSpreadSheet>): TzReportsManager;
    function OnExcelGetDataSource(AFunc: TFunc<string, TDataSource>): TzReportsManager;
    function OnExcelAllowBuild(AFunc: TFunc<string, Boolean>): TzReportsManager;

    // Fluent Chaining Methods (Datasets passing & dependencies)
    function WithDataSet(DataSet: TzFBDataSet): TzReportsManager; overload;
    function WithDataSet(const DatasetName: string): TzReportsManager; overload;
    function WithMainDataSet(DataSet: TzFBDataSet): TzReportsManager; overload;
    function WithMainDataSet(const DatasetName: string): TzReportsManager; overload;
    function RegisterReportDataSets(const ReportName: string; const DataSetNames: array of string): TzReportsManager;

    // Properties for decoupled config
    property DefaultDatabase: TFDConnection read FDefaultDatabase write SetDefaultDatabase;
    property CurrentUserDisplayName: string read FCurrentUserDisplayName write FCurrentUserDisplayName;
    property zSystem: TzSystem read FzSystem write FzSystem;
  end;

implementation

uses
  System.json,
  System.Variants,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  Vcl.FileCtrl,
  cxImageComboBox,
  frxExportPDFHelpers,
  zOffice.Word.UriStreamProvider,
  zOffice.Reports.Form,
  zOffice.Reports.json,
  zMsg,
  zBaseLib;

{$R *.DFM}

const
  VarCategory = 'zVariabili';

constructor TzReportsManager.Create(aOwner: TComponent);
begin
  inherited;

  FUserVariables := TDictionary<string, Variant>.Create;
  FReportDataSets := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);
  FOpenedDataSets := TList<TzFBDataSet>.Create;
  FDataSetsToClose := TStringList.Create;

  if assigned(Owner) then
    Name := 'ReportsManager_' + Owner.Name;

  FFolder := '';
  FExcludeFolders := [];
  FReportLoadedProc := nil;
  FBeforePrintProc := nil;
  FAfterPrintProc := nil;
  FAddVariablesProc := nil;
  FMailMergeDataSet := nil;
  FOnCustomGetVariable := nil;
  FDefaultDatabase := nil;
  FCurrentUserDisplayName := '';
  FJsonPath := '';
  FzSystem := nil;

  WordParams.Init;

  WordParams.OnGetVariable := function(variableName: String): Variant
    begin
      result := GetVariable(variableName);
    end;

  WordParams.OnGetDataSet := Function(DatasetName: string): TDataSet
    begin
      if DatasetName.IsEmpty then
        result := SelectedDataSet
      else
        result := GetDataSet(DatasetName);
    end;

  WordParams.OnGetDataSetName := Function(DatasetName: string): string
    begin
      result := GetDataSetPipeName(DatasetName);
    end;

  WordParams.OnGetDataSetList := Procedure(DataSetNames: TStrings)
    begin
      Assert(assigned(DataSetNames));
      DataSetNames.Text := Self.DataSetNames;
    end;

  WordParams.OnGetImages := procedure(TemplateFileName: string; DataSet: TDataSet; provider: TImageUriStreamProvider)
    begin
      provider.ClearImages;

      if assigned(DataSet) then
      begin
        provider.AddImages(DataSet); // tutti i campi TGraphicField
        //
        provider.AddImage('Header', DataSet, 'CARTA_INTESTATA_LOGO_INTESTAZ');
        provider.AddImage('Logo', DataSet, 'CARTA_INTESTATA_TIMBRO');
        provider.AddImage('Footer', DataSet, 'CARTA_INTESTATA_LOGO_FOOTER');
        provider.AddImage('FirmaDirettore', DataSet, 'CARTA_INTESTATA_IMM_FIRMA_DIRET');
        provider.AddImage('FirmaLegaleRappresentante', DataSet, 'CARTA_INTESTATA_IMM_FIRMA_LEG_R');

        // Progetti
        provider.AddImage('FIRMA_RESPONSABILE', DataSet, 'FIRMA_RESPONSABILE');
        provider.AddImage('FIRMA_COORDINATORE_CORSO', DataSet, 'FIRMA_COORDINATORE_CORSO');
        provider.AddImage('FIRMA_REFERENTE_SEGRETERIA', DataSet, 'FIRMA_REFERENTE_SEGRETERIA');
        provider.AddImage('LOGO_INTESTAZIONE', DataSet, 'LOGO_INTESTAZIONE');
        provider.AddImage('LOGO_FOOTER', DataSet, 'LOGO_FOOTER');
      end;
    end;

  ExcelParams.Init;

  ExcelParams.OnGetVariable := function(variableName: String): Variant
    begin
      result := GetVariable(variableName);
    end;

  ExcelParams.OnGetDataSet := Function(DatasetName: string): TDataSet
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

      for DataSet in DataSets do
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

  FDataSets := TList<TzFBDataSet>.Create;

  FReports := TzFolder.Create(nil);
  FSharedReports := TStringList.Create;
  FSharedReports.Duplicates := dupIgnore;
  FPipes := TList<TfrxDBDataSet>.Create;

  frxFDComponents := TfrxFDComponents.Create(Self);
  frxFDComponents.DefaultDatabase := nil; // Managed externally via DefaultDatabase property

  // FastReport
  frxPDFExport.OpenAfterExport := False;
  frxPDFExport.ShowDialog := True;
  frxPDFExport.OverwritePrompt := False;
  frxPDFExport.EmbeddedFonts := True;
end;

destructor TzReportsManager.Destroy;
begin
  FreeAndNil(FDataSetsToClose);
  FreeAndNil(FReportDataSets);
  FreeAndNil(FOpenedDataSets);
  FreeAndNil(FUserVariables);
  FreeAndNil(FPipes);
  FreeAndNil(FSharedReports);
  FreeAndNil(FReports);
  FreeAndNil(FDataSets);
  inherited;
end;

procedure TzReportsManager.SetDefaultDatabase(const Value: TFDConnection);
begin
  FDefaultDatabase := Value;
  if assigned(frxFDComponents) then
    frxFDComponents.DefaultDatabase := Value;
end;

procedure TzReportsManager.AddDataSet(DataSet: TzFBDataSet);
begin
  if not DataSets.Contains(DataSet) then
    DataSets.Add(DataSet);
end;

procedure TzReportsManager.AddVariables;
var
  DataSet: TzFBDataSet;
  pair: TPair<string, Variant>;
begin
  frxReport.Variables.clear;
  frxReport.Variables[' ' + VarCategory] := null;

  for DataSet in DataSets do
    AddVariable(DataSet);

  if assigned(FUserVariables) then
  begin
    for pair in FUserVariables do
    begin
      if VarIsStr(pair.Value) then
        frxReport.Variables.AddVariable(VarCategory, pair.Key, QuotedStr(pair.Value))
      else
        frxReport.Variables.AddVariable(VarCategory, pair.Key, pair.Value);
    end;
  end;

  if assigned(FAddVariablesProc) then
    AddVariablesProc(Self);
end;

function TzReportsManager.BeforePrint(const ReportName: string): Boolean;
var
  DataSet: TzFBDataSet;
  dsNames: TStringList;
  dsName: string;
  ds: TzFBDataSet;
begin
  result := True;

  LoadReports;

  // Load JSON Configuration if it exists for this report
  LoadReportJsonConfig(ReportName);

  // Auto-Open datasets defined for this report
  if assigned(FReportDataSets) and FReportDataSets.TryGetValue(ReportName.ToLower, dsNames) then
  begin
    for dsName in dsNames do
    begin
      ds := GetDataSet(dsName);
      if assigned(ds) and not ds.Active then
      begin
        ds.Active := True;
        if not assigned(FOpenedDataSets) then
          FOpenedDataSets := TList<TzFBDataSet>.Create;
        FOpenedDataSets.Add(ds);
      end;
    end;
  end;

  CreatePipes;

  AddVariables;

  for DataSet in DataSets do
    DataSet.DisableMasterDetailDelayed;

  if not ReportName.IsEmpty then
    if assigned(FBeforePrintProc) then
      result := BeforePrintProc(ReportName);
end;

procedure TzReportsManager.AfterPrint(const ReportName: string);
var
  DataSet: TzFBDataSet;
  ds: TzFBDataSet;
  dsName: string;
begin
  DestroyPipes;
  FreeReportMemory;

  frxReport.clear;

  for DataSet in DataSets do
    DataSet.DisableMasterDetailDelayed;

  // Auto-Close datasets that we opened
  if assigned(FOpenedDataSets) then
  begin
    for ds in FOpenedDataSets do
    begin
      try
        ds.Active := False;
      except
        // suppress exceptions in cleanup
      end;
    end;
    FOpenedDataSets.clear;
  end;

  // Close datasets specified to be closed at the end of printing
  if assigned(FDataSetsToClose) then
  begin
    for dsName in FDataSetsToClose do
    begin
      ds := GetDataSet(dsName);
      if assigned(ds) and ds.Active then
      begin
        try
          ds.Active := False;
        except
          // suppress exceptions in cleanup
        end;
      end;
    end;
    FDataSetsToClose.clear;
  end;

  if not ReportName.IsEmpty then
    if assigned(FAfterPrintProc) then
      AfterPrintProc(ReportName);
end;

function TzReportsManager.GetPipeline(DataSet: TDataSet; const aName: string = ''; const aPipelineName: string = ''): TfrxDBDataSet;
var
  ComponentName: string;
  comp: TComponent;
begin
  result := nil;

  if not assigned(DataSet) then
    exit;

  ComponentName := Coalesce(aName, GetPipelineName(DataSet));

  comp := Self.FindComponent(ComponentName);

  if assigned(comp) then
    if comp is TfrxDBDataSet then
      result := comp as TfrxDBDataSet;
end;

function TzReportsManager.CreatePipeline(DataSet: TDataSet; const aName: string = ''; const aPipelineName: string = ''): TfrxDBDataSet;
var
  ComponentName: string;
  comp: TComponent;
begin
  result := nil;

  if not assigned(DataSet) then
    exit;

  ComponentName := Coalesce(aName, GetPipelineName(DataSet));

  comp := Self.FindComponent(ComponentName);

  if assigned(comp) then
    if comp is TfrxDBDataSet then
      exit(comp as TfrxDBDataSet);

  result := TfrxDBDataSet.Create(Self);
  Pipes.Add(result);
  result.Name := ComponentName;
  result.UserName := Coalesce(aPipelineName, GetPipelineName(DataSet));
  result.DataSet := DataSet;
end;

procedure TzReportsManager.CreatePipes;
var
  DataSet: TzFBDataSet;
begin
  DestroyPipes;

  for DataSet in DataSets do
    CreatePipeline(DataSet);
end;

procedure TzReportsManager.DestroyPipes;
var
  pipe: TfrxDBDataSet;
begin
  for pipe in Pipes do
    pipe.Free;

  Pipes.clear;
end;

procedure TzReportsManager.SetExcludeFolders(const Value: TExcludeFolders);
begin
  FExcludeFolders := Value;
end;

{ Fluent Chaining Methods for Datasets passing & dependencies }

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

// Fluent Excel Chaining
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

// Fluent Word Chaining
function TzReportsManager.OnWordBeforeShow(AProc: TProc<string, TdxRichEditControl>): TzReportsManager;
begin
  WordBeforeShow := AProc;
  result := Self;
end;

function TzReportsManager.OnWordFirmaEnabled(AFunc: TFunc<string, Boolean>): TzReportsManager;
begin
  WordFirmaEnabled := AFunc;
  result := Self;
end;

function TzReportsManager.OnWordFirmaDoc(AProc: TProc<string>): TzReportsManager;
begin
  WordFirmaDoc := AProc;
  result := Self;
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

procedure TzReportsManager.SetSharedReports(const Value: TStringList);
begin
  FSharedReports.Assign(Value);
end;

procedure TzReportsManager.FreeReportMemory;
begin
  if assigned(frxReport.PreviewPages) then
    frxReport.PreviewPages.clear;
end;

function TzReportsManager.GetPipelineName(DataSet: TDataSet): string;
begin
  Assert(assigned(DataSet));

  result := '';

  if DataSet is TzFBDataSet then
    result := (DataSet as TzFBDataSet).ReportPipe;

  if result = '' then
    result := Owner.Name + '_' + DataSet.Name;
end;

function TzReportsManager.GetReport(const ReportName: String): TzFile;
begin
  result := nil;

  if assigned(Reports) then
    result := Reports.FileByName(ReportName);
end;

function TzReportsManager.frxDesignerLoadReport(Report: TfrxReport): Boolean;
begin
  CreatePipes;
  AddVariables;
  result := True;
end;

procedure TzReportsManager.frxReportBeginDoc(Sender: TObject);
begin
  AddVariables;
end;

function TzReportsManager.LoadReport(ReportName: string): Boolean;
var
  Report: TzFile;
begin
  result := False;

  Report := GetReport(ReportName);

  if not assigned(Report) then
  begin
    ShowMessage('Report non trovato: ' + ReportName);
    exit;
  end;

  if not TFile.Exists(Report.FullName) then
    ShowMessage('File Report non trovato: ' + Report.FullName)
  else
  begin
    frxReport.LoadFromFile(Report.FullName);

    if assigned(FReportLoadedProc) then
      ReportLoadedProc(ReportName);

    result := True;
  end;
end;

function TzReportsManager.PrepareReport(Report: string): Boolean;
begin
  result := False;

  if LoadReport(Report) then
    result := frxReport.PrepareReport(True);
end;

procedure TzReportsManager.PreviewFastReport(ReportName: string);
var
  ok: Boolean;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    InitModificaAnteprima;

    if PrepareReport(ReportName) then
      frxReport.ShowPreparedReport;
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.PrintFastReport(ReportName: string);
var
  ok: Boolean;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    if PrepareReport(ReportName) then
    begin
      if CtrlKey then
        frxReport.ShowReport(False)
      else
        frxReport.Print;
    end;
  finally
    AfterPrint(ReportName);
  end;
end;

function TzReportsManager.ExportFastReport(ReportName: string; const FileNamePdf: string): Integer;
var
  ok: Boolean;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit(0);

    if PrepareReport(ReportName) then
    begin
      frxPDFExport.OpenAfterExport := True;
      frxPDFExport.OverwritePrompt := True;
      frxPDFExport.ShowDialog := True;
      frxPDFExport.EmbeddedFonts := True;
      frxPDFExport.FileName := FileNamePdf;
      frxPDFExport.Author := FCurrentUserDisplayName;
      frxPDFExport.Creator := FCurrentUserDisplayName;

      frxReport.Export(frxPDFExport);
      result := 1;
    end
    else
      result := 0;
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.AddVariable(const Name, Value: string);
begin
  if not assigned(FUserVariables) then
    FUserVariables := TDictionary<string, Variant>.Create;
  FUserVariables.AddOrSetValue(Name, Value);
  frxReport.Variables.AddVariable(VarCategory, Name, QuotedStr(Value));
end;

procedure TzReportsManager.AddVariable(const DatasetName: string; Params: TFDParams);
var
  i: Integer;
  VarName: string;
  varValue: Variant;
  s: string;
begin
  Assert(assigned(Params));

  SiMain.EnterMethod(Self, 'AddVariable');

  for i := 0 to Params.Count - 1 do
  begin
    VarName := Self.Name + '_' + DatasetName + Params[i].Name;
    SiMain.LogString('VariabileDiStampa', VarName);
    varValue := Params[i].Value;

    if VarIsStr(varValue) then
    begin
      s := varValue;
      AddVariable(VarName, s);
    end
    else
      AddVariable(VarName, varValue);
  end;

  SiMain.LeaveMethod(Self, 'AddVariable');
end;

procedure TzReportsManager.AddVariable(const Name: string; const Value: Variant);
begin
  if not assigned(FUserVariables) then
    FUserVariables := TDictionary<string, Variant>.Create;
  FUserVariables.AddOrSetValue(Name, Value);
  frxReport.Variables.AddVariable(VarCategory, Name, Value);
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

procedure TzReportsManager.ClearDataSets;
begin
  DataSets.clear;
end;

function TzReportsManager.frxReportUserFunction(const MethodName: string; var Params: Variant): Variant;
begin
  result := null;
end;

procedure TzReportsManager.NewFastReport;
begin
  ShowDesigner('');
end;

procedure TzReportsManager.EditFastReport(ReportName: string);
begin
  if not ReportName.IsEmpty then
    ShowDesigner(ReportName);
end;

function TzReportsManager.GetDataSet(const DatasetName: string): TzFBDataSet;
var
  DataSet: TzFBDataSet;
begin
  result := nil;

  if DatasetName.IsEmpty then
    result := SelectedDataSet
  else
    for DataSet in DataSets do
      if SameText(DataSet.Name, DatasetName) or SameText(GetPipelineName(DataSet), DatasetName) then
      begin
        result := DataSet;
        exit;
      end;

  if not assigned(result) then
    result := SelectedDataSet;

  if not assigned(result) then
    if DataSets.Count > 0 then
      result := DataSets[0];
end;

function TzReportsManager.GetDataSetNames: string;
var
  StringList: TStringList;
  DataSet: TzFBDataSet;
begin
  result := '';

  StringList := TStringList.Create;
  try
    for DataSet in DataSets do
      StringList.Add(DataSet.Name + ' = ' + GetPipelineName(DataSet));

    result := StringList.Text;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzReportsManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
    if AComponent is TzFBDataSet then
      DataSets.Remove(AComponent as TzFBDataSet);
end;

procedure TzReportsManager.ShowDesigner(ReportName: string);
var
  Report: TzFile;
  FileName: string;
  Folder: string;
  backupFile: string;
  backupFolder: string;
  ok: Boolean;
begin
  frxReport.clear;
  frxReport.FileName := '';

  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := GetReport(ReportName);

    if not assigned(Report) then
    begin
      ShowMessage('Report non trovato: ' + ReportName);
      exit;
    end;

    if assigned(Report) then
    begin
      FileName := Report.FullName;
      Folder := Report.Folder;

      backupFolder := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(FileName)) + '_backup\';
      ForceDirectories(backupFolder);
      backupFile := backupFolder + FormatDateTime('yyyymmdd hh nn ss', now) + ' - ' + TPath.GetFileName(FileName);
      TFile.Copy(FileName, backupFile);
      frxReport.LoadFromFile(FileName);
    end
    else
    begin
      FileName := '';
      Folder := Reports.FullName;
    end;

    frxDesigner.OpenDir := Folder;
    frxDesigner.SaveDir := Folder;
    frxDesigner.TemplateDir := Folder;

    StartWait;
    try
      frxReport.DesignReport;
      StopWait;
    except
      StopWait;
      raise;
    end;
  finally
    AfterPrint(ReportName);
  end;

  LoadReports;
end;

procedure TzReportsManager.frxDesignerShow(Sender: TObject);
begin
  StopWait;
end;

function TzReportsManager.ParsedSharedReports: TStrings;
var
  DataSet: TDataSet;
  DatasetName: string;
  FieldName: string;
  FileName: string;
  ReportName: string;
  idx: Integer;
  s: string;
begin
  SiMain.EnterMethod(Self, 'ParsedSharedReports');

  result := TStringList.Create;
  try
    for idx := 0 to SharedReports.Count - 1 do
    begin
      s := SharedReports[idx];

      if not s.Contains('=') then // report normale
        result.Add(s)
      else
        if not SharedReports.ValueFromIndex[idx].Trim.StartsWith('[') then // caption=fileName
          result.Add(s)
        else
        begin
          ReportName := SharedReports.KeyNames[idx];
          FileName := SharedReports.ValueFromIndex[idx].Trim.Replace('[', '').Replace(']', '');

          DatasetName := FileName.Substring(0, FileName.IndexOf('.'));
          FieldName := FileName.Substring(FileName.IndexOf('.') + 1);

          SiMain.LogString('SharedReport', s);
          SiMain.LogString('ReportName', ReportName);
          SiMain.LogString('FileName', FileName);
          SiMain.LogString('DataSetName', DatasetName);
          SiMain.LogString('FieldName', FieldName);

          DataSet := GetDataSet(DatasetName);

          if assigned(DataSet) then
          begin
            if assigned(DataSet.FindField(FieldName)) then // se non lo trova inutile aggiungerlo
            begin
              SiMain.LogVerbose('Dataset trovato');
              FileName := DataSet.FieldByName(FieldName).AsString;
              SiMain.LogString('FileName da dataset', FileName);

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

procedure TzReportsManager.EnumVariableNames(Names: TStrings);
begin
  frxReport.Variables.GetVariablesList(VarCategory, Names);
end;

function TzReportsManager.VariableExists(Name: string): Boolean;
begin
  result := frxReport.Variables.IndexOf(Name) <> -1;
end;

procedure TzReportsManager.Preview(const ReportName: string; DataSet: TzFBDataSet = nil);
var
  Report: TzFile;
  ok: Boolean;
begin
  if assigned(DataSet) then
    SelectedDataSet := DataSet;

  ok := BeforePrint(ReportName);
  try
    if ok then
    begin
      Report := GetReport(ReportName);

      if not assigned(Report) then
      begin
        ShowMessage('Report non trovato: ' + ReportName);
        exit;
      end;

      case TReportKind.FromString(Report.FileExt) of
        rkUnknow:
          ;
        rkFastReport:
          PreviewFastReport(ReportName);
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
  finally
    AfterPrint(ReportName);
  end;
end;

procedure TzReportsManager.Print(const ReportName: string);
var
  ok: Boolean;
  Report: TzFile;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;

    Report := GetReport(ReportName);

    if not assigned(Report) then
    begin
      ShowMessage('Report non trovato: ' + ReportName);
      exit;
    end;

    case TReportKind.FromString(Report.FileExt) of
      rkUnknow:
        ;
      rkFastReport:
        PreviewFastReport(ReportName);
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

procedure TzReportsManager.Design(ReportName: string);
var
  ok: Boolean;
  Report: TzFile;
begin
  ok := BeforePrint(ReportName);
  try
    if not ok then
      exit;
    Report := GetReport(ReportName);

    if not assigned(Report) then
    begin
      ShowMessage('Report non trovato: ' + ReportName);
      exit;
    end;

    case TReportKind.FromString(Report.FileExt) of
      rkUnknow:
        ;
      rkFastReport:
        EditFastReport(ReportName);
      rkWord:
        begin
          WordParams.TemplateFileName := Report.FullName;
          zOffice.EditTemplateWord(WordParams);
        end;
      rkExcel:
        begin
          ExcelParams.TemplateFileName := Report.FullName;
          zOffice.EditTemplateExcel(ExcelParams);
        end;
    end;
  finally
    AfterPrint(ReportName);
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

        procedure AddItem(props: TcxImageComboBoxProperties; Description: string; Value: Integer; ImageIndex: Integer);
        var
          item: TcxImageComboBoxItem;
        begin
          item := props.Items.Add;
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

    result := s.ToInteger();
  end;

var
  idx: Integer;
begin
  idx := ChooseReportKind;

  case idx of
    0:
      NewFastReport();
    1:
      begin
        WordParams.TemplateFileName := '';
        zOffice.EditTemplateWord(WordParams);
      end;
    2:
      begin
        ExcelParams.TemplateFileName := '';
        zOffice.EditTemplateExcel(ExcelParams);
      end;
  end;
end;

function TzReportsManager.GetDataSetPipeName(const DatasetName: string): string;
var
  DataSet: TDataSet;
begin
  result := '';

  DataSet := GetDataSet(DatasetName);

  if assigned(DataSet) then
    result := GetPipelineName(DataSet);
end;

function TzReportsManager.GetVariable(Name: string): Variant;
var
  idx: Integer;
  v: Variant;
begin
  result := null;

  if assigned(FOnCustomGetVariable) then
  begin
    v := OnCustomGetVariable(Name);

    if not VarisNull(v) then
    begin
      result := v;
      exit;
    end;
  end;

  if assigned(FUserVariables) and FUserVariables.TryGetValue(Name, v) then
  begin
    result := v;
    exit;
  end;

  idx := frxReport.Variables.IndexOf(Name);

  if idx <> -1 then
  begin
    result := frxReport.Variables.Items[idx].Value;

    if VarIsStr(result) then
      result := AnsiDequotedStr(result, #39);
  end
  else
    if GetExpressionVar(Name, v) then
      result := v
    else
      result := null;
end;

function TzReportsManager.GetExpressionVar(const variableName: string; out Value: Variant): Boolean;
begin
  result := True;

  case IndexText(AnsiDequotedStr(variableName, #39), ['NOW', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'TODAY', 'CURRENT_DATE', 'TOMORROW', 'YESTERDAY']) of
    0, 1, 2:
      Value := now;
    3, 4:
      Value := Date;
    5:
      Value := IncDay(Date, 1);
    6:
      Value := IncDay(Date, -1);
  else
    result := False
  end;
end;

procedure TzReportsManager.frxReportPreview(Sender: TObject);
var
  frxComponent: TfrxComponent;
  page: Integer;
  i: Integer;
begin
  if ModificaAnteprima then
    for page := 0 to frxReport.PreviewPages.Count - 1 do
      for i := 0 to frxReport.PreviewPages.page[page].AllObjects.Count - 1 do
        if TComponent(frxReport.PreviewPages.page[page].AllObjects.Items[i]) is TfrxComponent then
        begin
          frxComponent := TfrxComponent(frxReport.PreviewPages.page[page].AllObjects.Items[i]);
          frxComponent.Editable := frxComponent.Editable + [ferAllowInPreview];
        end;
end;

procedure TzReportsManager.InitModificaAnteprima;
begin
  if assigned(FzSystem) then
    ModificaAnteprima := FzSystem.Authorizhed(REPORT_PREVIEW_EDITING_PERMISSION)
  else
    ModificaAnteprima := False;

  frxReport.PreviewOptions.AllowPreviewEdit := ModificaAnteprima;

  if ModificaAnteprima then
    frxReport.PreviewOptions.Buttons := frxReport.PreviewOptions.Buttons + [pbInplaceEdit]
  else
    frxReport.PreviewOptions.Buttons := frxReport.PreviewOptions.Buttons - [pbInplaceEdit];
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

procedure TzReportsManager.LoadReports;
var
  SharedFiles: TStrings;
const
  ReportFileExts: TAllowedFileExts = ['*.fr3', '*.docx', '*.xlsx'];
begin
  SharedFiles := ParsedSharedReports;
  try
    Reports.clear;
    Reports.FullName := zReportConfig.ReportRoot + Folder;

    Reports.LoadFolder(nil, Folder, ReportFileExts, ExcludeFolders);
    Reports.LoadSharedFiles(zReportConfig.ReportRoot, SharedFiles, ReportFileExts);
  finally
    FreeAndNil(SharedFiles);
  end;
end;

function TzReportsManager.GetFolder(const Folder: string): string;
begin
  result := IncludeTrailingPathDelimiter(zReportConfig.ReportRoot + Folder);
  ForceDirectories(result);
end;

procedure TzReportsManager.SetFastReportDataSet(const DataSet: TDataSet);
begin
  if assigned(DataSet) then
    frxReport.DataSet := GetPipeline(DataSet)
  else
    frxReport.DataSet := nil;
end;

{ Wrapper getters/setters for WordParams and ExcelParams }

function TzReportsManager.GetWordBeforeShow: TProc<string, TdxRichEditControl>;
begin
  result := WordParams.BeforeShowProc;
end;

procedure TzReportsManager.SetWordBeforeShow(Value: TProc<string, TdxRichEditControl>);
begin
  WordParams.BeforeShowProc := Value;
end;

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

// Excel params wrappers
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

// Word params wrappers
function TzReportsManager.GetWordFirmaEnabled: TFunc<string, Boolean>;
begin
  result := WordParams.FirmaEnabled;
end;

procedure TzReportsManager.SetWordFirmaEnabled(Value: TFunc<string, Boolean>);
begin
  WordParams.FirmaEnabled := Value;
end;

// Word signature
function TzReportsManager.GetWordFirmaDoc: TProc<string>;
begin
  result := WordParams.OnFirma;
end;

procedure TzReportsManager.SetWordFirmaDoc(Value: TProc<string>);
begin
  WordParams.OnFirma := Value;
end;

{ Fluent API Chaining Methods }

function TzReportsManager.SetVar(const Name: string; const Value: Variant): TzReportsManager;
begin
  AddVariable(Name, Value);
  result := Self;
end;

function TzReportsManager.SetVar(const Name: string; const Value: string): TzReportsManager;
begin
  AddVariable(Name, Value);
  result := Self;
end;

function TzReportsManager.ClearVars: TzReportsManager;
begin
  if assigned(FUserVariables) then
    FUserVariables.clear;
  frxReport.Variables.clear;
  result := Self;
end;

function TzReportsManager.OnBeforePrint(AProc: TFunc<string, Boolean>): TzReportsManager;
begin
  BeforePrintProc := AProc;
  result := Self;
end;

function TzReportsManager.OnAfterPrint(AProc: TProc<string>): TzReportsManager;
begin
  AfterPrintProc := AProc;
  result := Self;
end;

{ Fluent Chaining Methods (Datasets passing & dependencies) }
function TzReportsManager.RegisterReportDataSets(const ReportName: string; const DataSetNames: array of string): TzReportsManager;
var
  dsList: TStringList;
  dsName: string;
  Key: string;
begin
  if not assigned(FReportDataSets) then
    FReportDataSets := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);

  Key := ReportName.ToLower;
  if not FReportDataSets.TryGetValue(Key, dsList) then
  begin
    dsList := TStringList.Create;
    FReportDataSets.Add(Key, dsList);
  end;

  dsList.clear;
  for dsName in DataSetNames do
    dsList.Add(dsName);

  result := Self;
end;

function TzReportsManager.AddWordFragment(const DatasetName: string): string;
var
  Params: TzJsonReportParams;
  Frag: TzWordFragment;
begin
  result := '';
  if FJsonPath.IsEmpty then
    exit;
  try
    Params := nil;
    if TFile.Exists(FJsonPath) then
      Params := TzJsonReportParams.FromJSON(TFile.ReadAllText(FJsonPath, TEncoding.UTF8));
    if not assigned(Params) then
      Params := TzJsonReportParams.Create;
    try
      if not assigned(Params.Word) then
        Params.Word := TzWordParams.Create;

      result := ChangeFileExt(ExtractFileName(FJsonPath), '') + '_' + DatasetName + '.docx';

      Frag := TzWordFragment.Create;
      Frag.variable := DatasetName;
      Frag.template := result;
      Frag.DataSet := DatasetName;
      Params.Word.fragments.Add(Frag);

      TFile.WriteAllText(FJsonPath, Params.ToJSONString, TEncoding.UTF8);
    finally
      Params.Free;
    end;
  except
    result := '';
  end;
end;

function TzReportsManager.SaveExcelDataBinding(const jsonStr: string): Boolean;
var
  Params: TzJsonReportParams;
begin
  result := False;
  if FJsonPath.IsEmpty then
    exit;
  try
    Params := nil;
    if TFile.Exists(FJsonPath) then
      Params := TzJsonReportParams.FromJSON(TFile.ReadAllText(FJsonPath, TEncoding.UTF8));
    if not assigned(Params) then
      Params := TzJsonReportParams.Create;
    try
      if not assigned(Params.excel) then
        Params.excel := TzExcelParams.Create;

      if assigned(Params.excel.databinding) then
        Params.excel.databinding.Free;
      Params.excel.databinding := nil;

      if not jsonStr.IsEmpty then
        Params.excel.databinding := TJSONObject.ParseJSONValue(jsonStr) as TJSONObject;

      TFile.WriteAllText(FJsonPath, Params.ToJSONString, TEncoding.UTF8);
      result := True;
    finally
      Params.Free;
    end;
  except
    result := False;
  end;
end;

{ ============================================================================
  Metodi Batch (stampa/export massivo)
  Corrispondono ai metodi InitExportMassivo / DoExportMassivo /
  DoExportMassivoStampa / DoneExportMassivo di TzFormReports.
  ============================================================================ }

procedure TzReportsManager.BatchInit(const ReportName: string);
var
  ok: Boolean;
begin
  FBatchActive := False;

  ok := BeforePrint(ReportName);
  if not ok then
    exit;

  // Disabilita dialogo e progress durante il ciclo batch
  frxReport.DatasetName := '';
  frxReport.ReportOptions.Name := '';
  frxReport.PrintOptions.ShowDialog := False;
  frxReport.ShowProgress := False;

  // Carica il report una volta sola
  if not LoadReport(ReportName) then
    exit;

  // Configura export PDF in modalità silenziosa
  frxPDFExport.OpenAfterExport := False;
  frxPDFExport.ShowDialog := False;
  frxPDFExport.OverwritePrompt := False;
  frxPDFExport.Compressed := True;
  frxPDFExport.EmbeddedFonts := True;
  frxPDFExport.PDFStandard := psPDFA_1a;

  FBatchActive := True;
end;

procedure TzReportsManager.BatchPrint(const DocumentLabel: string; ShowPrinterDialog: Boolean);
begin
  if not FBatchActive then
    exit;

  frxReport.ReportOptions.Name := DocumentLabel;
  frxReport.PrintOptions.ShowDialog := ShowPrinterDialog;

  if frxReport.PrepareReport(True) then
    frxReport.Print;

  FreeReportMemory;
end;

function TzReportsManager.BatchExportPdf(const FileName: string): Boolean;
begin
  result := False;

  if not FBatchActive then
    exit;

  if FileName.IsEmpty then
    raise EArgumentException.Create('BatchExportPdf: FileName non specificato.');

  ForceDirectories(TPath.GetDirectoryName(FileName));

  if not frxReport.PrepareReport(True) then
    exit;

  frxPDFExport.FileName := ChangeFileExt(FileName, '.pdf');
  result := frxReport.Export(frxPDFExport);
  frxPDFExport.FileName := ''; // reset per evitare interferenze con export da anteprima

  FreeReportMemory;
end;

procedure TzReportsManager.BatchDone;
begin
  FBatchActive := False;

  frxReport.OnBeforePrint := nil;
  frxReport.ShowProgress := True;
  frxReport.PrintOptions.ShowDialog := True;

  AfterPrint('');
end;

{ ============================================================================
  RunBatchPrint / RunBatchExportPdf
  Livello alto: ciclo guidato da TzBatchController.
  Supportano FastReport, Word ed Excel in modo uniforme.
  Usano il ProgressBox integrato del datamodule.
  ============================================================================ }

procedure TzReportsManager.RunBatchPrint(const ReportName: string; Controller: TzBatchController; const ProgressCaption: string);
var
  Report: TzFile;
  Kind: TReportKind;
  i: Integer;
  PrimoGiro: Boolean;
begin
  if not assigned(Controller) then
    raise EArgumentNilException.Create('RunBatchPrint: Controller non assegnato.');

  LoadReports;
  Report := GetReport(ReportName);
  if not assigned(Report) then
  begin
    ShowMessage('Report non trovato: ' + ReportName);
    exit;
  end;

  Kind := TReportKind.FromString(Report.FileExt);

  Controller.AvvisaSeSuperamentoMax;
  Controller.Init;

  ProgressBox.Show(Controller.Count, ProgressCaption, ProgressCaption, 'Attendere...');
  try
    PrimoGiro := True;

    for i := 0 to Controller.Count - 1 do
    begin
      ProgressBox.IncProgress(Format('%d / %d', [i + 1, Controller.Count]));
      if ProgressBox.Cancelled then
        exit;

      if not BeforePrint(ReportName) then
      begin
        Controller.Next;
        Continue;
      end;
      try
        case Kind of
          rkFastReport:
            begin
              frxReport.PrintOptions.ShowDialog := PrimoGiro;
              if LoadReport(ReportName) then
                if frxReport.PrepareReport(True) then
                begin
                  frxReport.Print;
                  FreeReportMemory;
                end;
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

        PrimoGiro := False;
      finally
        AfterPrint(ReportName);
      end;

      Controller.Next;
    end;

  finally
    ProgressBox.Close;
    // Ripristina impostazioni FastReport
    frxReport.PrintOptions.ShowDialog := True;
    frxReport.ShowProgress := True;
  end;
end;

function TzReportsManager.RunBatchExportPdf(const ReportName: string; Controller: TzBatchController; OutputFolder: string; const ProgressCaption: string): Integer;
var
  Report: TzFile;
  Kind: TReportKind;
  i: Integer;
  FileName: string;
  SavedWordPdf: TPdfParams;
  SavedExcelPdf: TPdfParams;
begin
  result := 0;

  if not assigned(Controller) then
    raise EArgumentNilException.Create('RunBatchExportPdf: Controller non assegnato.');

  LoadReports;
  Report := GetReport(ReportName);
  if not assigned(Report) then
  begin
    ShowMessage('Report non trovato: ' + ReportName);
    exit;
  end;

  Kind := TReportKind.FromString(Report.FileExt);

  // Se OutputFolder non specificata, la chiede all'utente
  if OutputFolder.IsEmpty then
    if not SelectDirectory('Seleziona la cartella di destinazione PDF', '', OutputFolder) then
      exit;
  OutputFolder := IncludeTrailingPathDelimiter(OutputFolder);
  ForceDirectories(OutputFolder);

  // Salva i pdf params correnti per Word/Excel per ripristinarli dopo ogni documento
  SavedWordPdf := WordParams.pdf;
  SavedExcelPdf := ExcelParams.pdf;

  // Configura FastReport in modalità batch silenzioso
  if Kind = rkFastReport then
  begin
    frxReport.PrintOptions.ShowDialog := False;
    frxReport.ShowProgress := False;
    frxPDFExport.OpenAfterExport := False;
    frxPDFExport.ShowDialog := False;
    frxPDFExport.OverwritePrompt := False;
    frxPDFExport.Compressed := True;
    frxPDFExport.EmbeddedFonts := True;
    frxPDFExport.PDFStandard := psPDFA_1a;
  end;

  Controller.Init;

  ProgressBox.Show(Controller.Count, ProgressCaption, ProgressCaption, 'Attendere...');
  try
    for i := 0 to Controller.Count - 1 do
    begin
      ProgressBox.IncProgress(Format('%d / %d', [i + 1, Controller.Count]), Controller.FileNamePdf);
      if ProgressBox.Cancelled then
        exit;

      FileName := Controller.FileNamePdf;
      if FileName.IsEmpty then
        FileName := FormatDateTime('yyyymmdd_hhnnss', now) + '_' + IntToStr(i);
      FileName := OutputFolder + ChangeFileExt(FileName, '.pdf');

      if not BeforePrint(ReportName) then
      begin
        Controller.Next;
        Continue;
      end;
      try
        case Kind of
          rkFastReport:
            begin
              if LoadReport(ReportName) then
              begin
                ForceDirectories(TPath.GetDirectoryName(FileName));
                if frxReport.PrepareReport(True) then
                begin
                  frxPDFExport.FileName := FileName;
                  if frxReport.Export(frxPDFExport) then
                    Inc(result);
                  frxPDFExport.FileName := '';
                  FreeReportMemory;
                end;
              end;
            end;

          rkWord:
            begin
              WordParams.TemplateFileName := Report.FullName;
              var
              wp := WordParams.pdf;
              wp.method := mgfFileName;
              wp.FileName := FileName;
              wp.OpenFileAfterExport := False;
              wp.ShowMessageAfterExport := False;
              WordParams.pdf := wp;
              try
                zOffice.MailMerge(WordParams);
                Inc(result);
              finally
                WordParams.pdf := SavedWordPdf;
              end;
            end;

          rkExcel:
            begin
              ExcelParams.TemplateFileName := Report.FullName;
              var
              ep := ExcelParams.pdf;
              ep.method := mgfFileName;
              ep.FileName := FileName;
              ep.OpenFileAfterExport := False;
              ep.ShowMessageAfterExport := False;
              ExcelParams.pdf := ep;
              try
                zOffice.BuildSpreadSheetReport(ExcelParams);
                Inc(result);
              finally
                ExcelParams.pdf := SavedExcelPdf;
              end;
            end;
        end;
      finally
        AfterPrint(ReportName);
      end;

      Controller.Next;
    end;

  finally
    ProgressBox.Close;
    // Ripristina FastReport
    if Kind = rkFastReport then
    begin
      frxReport.PrintOptions.ShowDialog := True;
      frxReport.ShowProgress := True;
      frxPDFExport.FileName := '';
    end;
  end;
end;

{ end of batch/scope methods }

procedure TzReportsManager.LoadReportJsonConfig(const ReportName: string);

  procedure MapPdfParams(const Src: TzPdfParams; var Dest: TPdfParams);
  var
    s: string;
  begin
    if not assigned(Src) then
      exit;

    s := Src.method;
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

    Dest.FieldName := Src.FieldName;
    Dest.FileName := Src.FileName;

    s := Src.fontEmbedding;
    if SameText(s, 'none') or SameText(s, 'N') then
      Dest.fontEmbedding := zfeNone
    else
      if SameText(s, 'full') or SameText(s, 'F') then
        Dest.fontEmbedding := zfeFull
      else
        if SameText(s, 'subset') or SameText(s, 'S') then
          Dest.fontEmbedding := zfeSubset;

    Dest.OpenFileAfterExport := Src.OpenFileAfterExport;
    Dest.ShowMessageAfterExport := Src.ShowMessageAfterExport;
  end;

var
  Report: TzFile;
  jsonStr: string;
  JsonValue: TJSONValue;
  JsonObj: TJSONObject;
  dsName: string;
  dsList: TStringList;
  Key: string;
  b: Boolean;
  pdfParams: TPdfParams;
  JsonParams: TzJsonReportParams;
  wordFragments: TArray<TWordFragment>;

  procedure ResolveDatasets;
  var
    zReportDataset: TzReportDataset;
  begin
    if not JsonParams.mainDataset.IsEmpty then
      WithMainDataSet(JsonParams.mainDataset);

    if assigned(JsonParams.DataSets) and (JsonParams.DataSets.Count > 0) then
    begin
      Key := ReportName.ToLower;
      if not FReportDataSets.TryGetValue(Key, dsList) then
      begin
        dsList := TStringList.Create;
        FReportDataSets.Add(Key, dsList);
      end;
      dsList.clear;

      for zReportDataset in JsonParams.DataSets do
      begin
        dsName := zReportDataset.Name;
        dsList.Add(dsName);
        WithDataSet(dsName);

        if zReportDataset.Close then
        begin
          if assigned(FDataSetsToClose) then
            FDataSetsToClose.Add(dsName);
        end;
      end;
    end;
  end;

  procedure ResolveVariables;
  var
    pair: TJSONPair;
    val: TJSONValue;
  begin
    val := JsonObj.FindValue('variables');
    if assigned(val) and (val is TJSONObject) then
    begin
      for pair in (val as TJSONObject) do
        SetVar(pair.JsonString.Value, pair.JsonValue.Value);
    end;
  end;

  procedure ConfigureWord;
  var
    i: Integer;
  begin
    if not assigned(JsonParams.Word) then
      exit;

    WordParams.ReadOnly := JsonParams.Word.ReadOnly;

    WordParams.OnAddFragment := function(DatasetName: string): string
      begin
        result := AddWordFragment(DatasetName);
      end;

    if assigned(JsonParams.Word.fragments) and (JsonParams.Word.fragments.Count > 0) then
    begin
      SetLength(wordFragments, JsonParams.Word.fragments.Count);
      for i := 0 to JsonParams.Word.fragments.Count - 1 do
      begin
        wordFragments[i].variableName := JsonParams.Word.fragments[i].variable;
        wordFragments[i].TemplateFileName := JsonParams.Word.fragments[i].template;
        wordFragments[i].DatasetName := JsonParams.Word.fragments[i].DataSet;
      end;
      WordParams.fragments := wordFragments;
    end;

    b := JsonParams.Word.firma;
    WordParams.FirmaEnabled := function(ReportName: string): Boolean
      begin
        result := b;
      end;

    b := JsonParams.Word.inviaMail;
    WordParams.InviaMailEnabled := function(ReportName: string): Boolean
      begin
        result := b;
      end;

    if assigned(JsonParams.Word.pdf) then
    begin
      pdfParams := WordParams.pdf;
      MapPdfParams(JsonParams.Word.pdf, pdfParams);
      WordParams.pdf := pdfParams;
    end;
  end;

  procedure ConfigureExcel;
  begin
    if not assigned(JsonParams.excel) then
      exit;

    ExcelParams.ReadOnly := JsonParams.excel.ReadOnly;

    b := JsonParams.excel.AllowBuildReport;
    ExcelParams.AllowBuildReport := function(ReportName: string): Boolean
      begin
        result := b;
      end;

    if assigned(JsonParams.excel.pdf) then
    begin
      pdfParams := ExcelParams.pdf;
      MapPdfParams(JsonParams.excel.pdf, pdfParams);
      ExcelParams.pdf := pdfParams;
    end;

    ExcelParams.OnLoadDataBinding := function: string
      begin
        result := '';
        if assigned(JsonParams) and assigned(JsonParams.excel) and assigned(JsonParams.excel.databinding) then
          result := JsonParams.excel.databinding.ToString;
      end;

    ExcelParams.OnSaveDataBinding := function(jsonStr: string): Boolean
      begin
        result := SaveExcelDataBinding(jsonStr);
      end;
  end;

  procedure ConfigureFastReport;
  begin
    if not assigned(JsonParams.fastreport) then
      exit;

    frxPDFExport.ShowDialog := JsonParams.fastreport.ShowDialog;
    frxPDFExport.OpenAfterExport := JsonParams.fastreport.OpenAfterExport;
    frxPDFExport.EmbeddedFonts := JsonParams.fastreport.EmbeddedFonts;
    frxPDFExport.OverwritePrompt := JsonParams.fastreport.OverwritePrompt;
  end;

begin
  FReportId := '';
  FReportGroup := '';
  FJsonPath := '';
  if assigned(FDataSetsToClose) then
    FDataSetsToClose.clear;

  Report := GetReport(ReportName);
  if not assigned(Report) then
    exit;

  FJsonPath := TPath.ChangeExtension(Report.FullName, '.json');
  if not TFile.Exists(FJsonPath) then
  begin
    FJsonPath := Report.FullName + '.json';
    if not TFile.Exists(FJsonPath) then
      exit;
  end;

  try
    jsonStr := TFile.ReadAllText(FJsonPath, TEncoding.UTF8);
    JsonValue := TJSONObject.ParseJSONValue(jsonStr);
    if not assigned(JsonValue) then
      exit;

    if not(JsonValue is TJSONObject) then
    begin
      JsonValue.Free;
      exit;
    end;

    JsonObj := JsonValue as TJSONObject;
    try
      JsonParams := TzJsonReportParams.FromJSON(JsonObj);
      if not assigned(JsonParams) then
        exit;

      FReportId := JsonParams.Id;
      FReportGroup := JsonParams.group;

      try
        ResolveDatasets;
        ResolveVariables;
        ConfigureWord;
        ConfigureExcel;
        ConfigureFastReport;
      finally
        JsonParams.Free;
      end;
    finally
      JsonObj.Free;
    end;
  except
    on E: Exception do
    begin
      SiMain.LogError('Errore nel caricamento del file JSON di configurazione per: ' + ReportName + '. Errore: ' + E.Message);
    end;
  end;
end;

end.
