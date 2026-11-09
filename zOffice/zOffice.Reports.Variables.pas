unit zOffice.Reports.Variables;

{
  TzReportVariables
  -----------------
  Gestione centralizzata delle variabili di stampa per i tre motori:
  FastReport, Word (MailMerge) ed Excel (SpreadSheetReport).

  Ordine di risoluzione (identico per tutti i motori):
    1. OnGetVariable  (hook esterno / variabili dinamiche del chiamante)
    2. Dizionario     (variabili aggiunte con Set_ / SetFromParams)
    3. ExpressionVar  (TODAY, NOW, TOMORROW, YESTERDAY, ecc.)
    4. null

  Il manager collega i tre motori tramite la stessa lambda:
    Word/Excel  →  Resolve(Name)
    FastReport  →  SyncToFastReport(frxReport)  prima di PrepareReport
                   oppure nell'evento OnBeginDoc per aggiornamento live
}

interface

uses
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  System.Classes,
  System.DateUtils,
  System.StrUtils,
  FireDAC.Stan.Param,
  frxClass;

type
  TzReportVariables = class
  private
    FVariables: TDictionary<string, Variant>;
    FOnGetVariable: TFunc<string, Variant>;

    function Clean(const Name: string): string;
    function GetExpressionVar(const Name: string; out Value: Variant): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // ------------------------------------------------------------------
    // Scrittura
    // ------------------------------------------------------------------

    /// Aggiunge o aggiorna una variabile nel dizionario.
    procedure Set_(const Name: string; const Value: Variant); overload;
    procedure Set_(const Name, Value: string); overload;

    /// Aggiunge tutte le variabili da un TFDParams con prefisso opzionale.
    /// Il nome risultante è: Prefix + Params[i].Name
    procedure SetFromParams(const Prefix: string; Params: TFDParams);

    /// Svuota il dizionario (non tocca OnGetVariable).
    procedure Clear;

    // ------------------------------------------------------------------
    // Lettura
    // ------------------------------------------------------------------

    /// Risolve una variabile nell'ordine: OnGetVariable → dizionario →
    /// expression vars → null.
    function Resolve(const Name: string): Variant;

    function Exists(const Name: string): Boolean;

    procedure EnumNames(Names: TStrings);

    // ------------------------------------------------------------------
    // Integrazione FastReport
    // ------------------------------------------------------------------

    /// Push del dizionario verso frxReport.Variables.
    /// Da chiamare prima di PrepareReport (o in OnBeginDoc).
    /// Sovrascrive il contenuto attuale della categoria.
    procedure SyncToFastReport(Report: TfrxReport;
      const Category: string = 'zVariabili');

    // ------------------------------------------------------------------
    // Hook esterno
    // ------------------------------------------------------------------

    /// Callback chiamata per prima nella risoluzione.
    /// Restituire null per delegare ai livelli successivi.
    property OnGetVariable: TFunc<string, Variant>
      read FOnGetVariable write FOnGetVariable;
  end;

implementation

const
  QuoteChar = #39;

{ TzReportVariables }

constructor TzReportVariables.Create;
begin
  inherited;
  FVariables := TDictionary<string, Variant>.Create;
end;

destructor TzReportVariables.Destroy;
begin
  FreeAndNil(FVariables);
  inherited;
end;

function TzReportVariables.Clean(const Name: string): string;
begin
  result := AnsiDequotedStr(Trim(Name), QuoteChar);
end;

// ------------------------------------------------------------------
// Scrittura
// ------------------------------------------------------------------

procedure TzReportVariables.Set_(const Name: string; const Value: Variant);
begin
  FVariables.AddOrSetValue(Name, Value);
end;

procedure TzReportVariables.Set_(const Name, Value: string);
begin
  FVariables.AddOrSetValue(Name, Value);
end;

procedure TzReportVariables.SetFromParams(const Prefix: string; Params: TFDParams);
var
  i: Integer;
  VarName: string;
  v: Variant;
begin
  Assert(assigned(Params));

  for i := 0 to Params.Count - 1 do
  begin
    VarName := Prefix + Params[i].Name;
    v := Params[i].Value;
    if VarIsStr(v) then
      Set_(VarName, string(v))
    else
      Set_(VarName, v);
  end;
end;

procedure TzReportVariables.Clear;
begin
  FVariables.Clear;
end;

// ------------------------------------------------------------------
// Lettura
// ------------------------------------------------------------------

function TzReportVariables.Resolve(const Name: string): Variant;
var
  cleaned: string;
  v: Variant;
begin
  result := null;
  cleaned := Clean(Name);

  // 1. Hook esterno
  if assigned(FOnGetVariable) then
  begin
    v := FOnGetVariable(cleaned);
    if not VarIsNull(v) then
    begin
      result := v;
      exit;
    end;
  end;

  // 2. Dizionario
  if FVariables.TryGetValue(cleaned, v) then
  begin
    result := v;
    exit;
  end;

  // 3. Expression vars
  if GetExpressionVar(cleaned, v) then
    result := v;
end;

function TzReportVariables.Exists(const Name: string): Boolean;
begin
  result := FVariables.ContainsKey(Clean(Name));
end;

procedure TzReportVariables.EnumNames(Names: TStrings);
var
  pair: TPair<string, Variant>;
begin
  Assert(assigned(Names));
  for pair in FVariables do
    Names.Add(pair.Key);
end;

function TzReportVariables.GetExpressionVar(const Name: string;
  out Value: Variant): Boolean;
begin
  result := True;
  case IndexText(Name,
    ['NOW', 'CURRENT_TIME', 'CURRENT_TIMESTAMP',
     'TODAY', 'CURRENT_DATE',
     'TOMORROW', 'YESTERDAY']) of
    0, 1, 2: Value := Now;
    3, 4:    Value := Date;
    5:       Value := IncDay(Date,  1);
    6:       Value := IncDay(Date, -1);
  else
    result := False;
  end;
end;

// ------------------------------------------------------------------
// Integrazione FastReport
// ------------------------------------------------------------------

procedure TzReportVariables.SyncToFastReport(Report: TfrxReport;
  const Category: string);
var
  pair: TPair<string, Variant>;
begin
  Assert(assigned(Report));

  Report.Variables.Clear;
  Report.Variables[' ' + Category] := null; // intestazione categoria visibile nel designer

  for pair in FVariables do
  begin
    if VarIsStr(pair.Value) then
      Report.Variables.AddVariable(Category, pair.Key, QuotedStr(pair.Value))
    else
      Report.Variables.AddVariable(Category, pair.Key, pair.Value);
  end;
end;

end.
