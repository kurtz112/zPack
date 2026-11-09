unit zOffice.Reports.Pipeline;

{
  TzReportPipelineManager
  -----------------------
  Gestione dei TfrxDBDataSet ("pipe") che collegano i TzFBDataSet
  al motore FastReport.

  Responsabilità:
  - Creare / distruggere i pipe al momento giusto (BeforePrint / AfterPrint)
  - Calcolare il nome canonico del pipe per un dataset
  - Fornire accesso al pipe associato a un dataset (GetPipeline)

  Non conosce variabili, JSON, Word o Excel.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  frxDBSet,
  zFbDataSet;

type
  TzReportPipelineManager = class
  private
    FOwner: TComponent;
    FDataSets: TList<TzFBDataSet>; // riferimento non posseduto
    FPipes: TList<TfrxDBDataSet>; // posseduto

    function CalcPipelineName(DataSet: TDataSet): string;
  public
    constructor Create(Owner: TComponent; DataSets: TList<TzFBDataSet>);
    destructor Destroy; override;

    // ------------------------------------------------------------------
    // Gestione ciclo di vita pipe
    // ------------------------------------------------------------------

    /// Crea i pipe per tutti i dataset nella lista FDataSets.
    procedure CreateAll;

    /// Distrugge tutti i pipe e svuota la lista interna.
    procedure DestroyAll;

    // ------------------------------------------------------------------
    // Accesso / creazione singolo pipe
    // ------------------------------------------------------------------

    /// Restituisce il pipe esistente per DataSet, nil se non trovato.
    function GetPipeline(DataSet: TDataSet; const aName: string = ''; const aPipelineName: string = ''): TfrxDBDataSet;

    /// Crea il pipe per DataSet se non esiste già; lo restituisce.
    function CreatePipeline(DataSet: TDataSet; const aName: string = ''; const aPipelineName: string = ''): TfrxDBDataSet;

    // ------------------------------------------------------------------
    // Nomi
    // ------------------------------------------------------------------

    /// Nome canonico del pipe per DataSet
    /// (usa TzFBDataSet.ReportPipe se valorizzato, altrimenti Owner.Name + '_' + DataSet.Name).
    function PipelineName(DataSet: TDataSet): string;

    /// Nome del pipe a partire dal nome del dataset (ricerca per nome).
    /// Restituisce '' se il dataset non è nella lista.
    function PipelineNameByDatasetName(const DatasetName: string): string;
  end;

implementation

uses
  System.StrUtils,
  zBaseLib; // Coalesce

{ TzReportPipelineManager }

constructor TzReportPipelineManager.Create(Owner: TComponent; DataSets: TList<TzFBDataSet>);
begin
  inherited Create;
  Assert(assigned(Owner));
  Assert(assigned(DataSets));
  FOwner := Owner;
  FDataSets := DataSets;
  FPipes := TList<TfrxDBDataSet>.Create;
end;

destructor TzReportPipelineManager.Destroy;
begin
  DestroyAll;
  FreeAndNil(FPipes);
  inherited;
end;

// ------------------------------------------------------------------
// Nomi
// ------------------------------------------------------------------

function TzReportPipelineManager.CalcPipelineName(DataSet: TDataSet): string;
var
  dmName: string;
begin
  result := '';

  if DataSet is TzFBDataSet then
    result := (DataSet as TzFBDataSet).ReportPipe;

  if result.IsEmpty then
  begin
    // Owner qui È il TzReportsManager, quindi la base nome è FOwner.Owner.
    if assigned(FOwner.Owner) then
      dmName := FOwner.Owner.Name
    else
      dmName := FOwner.Name; // fallback se il manager non ha owner

    result := dmName + '_' + DataSet.Name;
  end;
end;

function TzReportPipelineManager.PipelineName(DataSet: TDataSet): string;
begin
  Assert(assigned(DataSet));
  result := CalcPipelineName(DataSet);
end;

function TzReportPipelineManager.PipelineNameByDatasetName(const DatasetName: string): string;
var
  ds: TzFBDataSet;
begin
  result := '';
  for ds in FDataSets do
    if SameText(ds.Name, DatasetName) or SameText(CalcPipelineName(ds), DatasetName) then
    begin
      result := CalcPipelineName(ds);
      exit;
    end;
end;

// ------------------------------------------------------------------
// Accesso / creazione singolo pipe
// ------------------------------------------------------------------

function TzReportPipelineManager.GetPipeline(DataSet: TDataSet; const aName: string; const aPipelineName: string): TfrxDBDataSet;
var
  ComponentName: string;
  comp: TComponent;
begin
  result := nil;

  if not assigned(DataSet) then
    exit;

  ComponentName := Coalesce(aName, CalcPipelineName(DataSet));

  comp := FOwner.FindComponent(ComponentName);
  if assigned(comp) and (comp is TfrxDBDataSet) then
    result := comp as TfrxDBDataSet;
end;

function TzReportPipelineManager.CreatePipeline(DataSet: TDataSet; const aName: string; const aPipelineName: string): TfrxDBDataSet;
var
  ComponentName: string;
  comp: TComponent;
begin
  result := nil;

  if not assigned(DataSet) then
    exit;

  ComponentName := Coalesce(aName, CalcPipelineName(DataSet));

  // Reuse se già esiste (es. chiamata doppia)
  comp := FOwner.FindComponent(ComponentName);
  if assigned(comp) then
  begin
    if comp is TfrxDBDataSet then
      result := comp as TfrxDBDataSet;
    exit;
  end;

  result := TfrxDBDataSet.Create(FOwner);
  FPipes.Add(result);
  result.Name := ComponentName;
  result.UserName := Coalesce(aPipelineName, CalcPipelineName(DataSet));
  result.DataSet := DataSet;
end;

// ------------------------------------------------------------------
// Ciclo di vita
// ------------------------------------------------------------------

procedure TzReportPipelineManager.CreateAll;
var
  ds: TzFBDataSet;
begin
  DestroyAll;
  for ds in FDataSets do
    CreatePipeline(ds);
end;

procedure TzReportPipelineManager.DestroyAll;
var
  pipe: TfrxDBDataSet;
begin
  for pipe in FPipes do
    pipe.Free;
  FPipes.Clear;
end;

end.
