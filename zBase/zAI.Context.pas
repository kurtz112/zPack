unit zAI.Context;

{
  Troncone B, passo 5 — contesto runtime ("gemello dinamico" del descrittore).

  Mentre zAI.Descriptors dice COM'E' FATTA una form (statico, dai props),
  zAI.Context dice DOV'E' l'utente e COSA STA GUARDANDO in questo momento
  (dinamico, raccolto solo dai componenti VIVI e attivi: lo stato dinamico —
  record corrente, righe visibili, filtri applicati ora — non esiste a freddo).

  Questa unit definisce solo i TIPI (record neutri + vocabolari). La raccolta
  dallo stato vivo e l'unico punto che legge i TField (TAIFieldExtractor, il
  cancello GDPR) vivono in zAI.Context.Builder. Il classificatore di
  sensibilita' vive nel data layer (es. zGdpr.Classifier) e consuma l'enum
  TAISensitivity definito qui.

  Principi (vedi design concordato):
    - Non si esportano interi dataset: solo metadati di stato + il singolo
      record corrente.
    - Oscuramento ALLA FONTE: con disclosure ddNone il valore non viene mai
      letto, non "letto e scartato".
    - Un solo cancello per i dati: TAIFieldExtractor (nel builder).
    - Policy risolta a monte (regola "il piu' restrittivo vince") e passata
      gia' calcolata.

  Dipendenze: RTL, System.JSON, zSystem (TzComponentType), zAI.Descriptors
  (riuso di zComponentTypeToStr).
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  Data.DB,
  zSystem,          // TzComponentType
  zAI.Types,        // TAISensitivity, TAIDataDisclosure
  zAI.Descriptors;  // zComponentTypeToStr

type
  // TAISensitivity e TAIDataDisclosure sono definiti in zAI.Types (unit foglia)
  // e ri-esportati qui per comodita' di chi usa solo zAI.Context.
  TAISensitivity = zAI.Types.TAISensitivity;
  TAIDataDisclosure = zAI.Types.TAIDataDisclosure;

  // Hook opzionale di mascheramento parziale per i campi slMasked sotto ddMasked.
  // Riceve nome campo e il TField (sola lettura), ritorna la forma mascherata.
  // Se non assegnato, l'extractor usa una maschera di default per tipo.
  TAIMaskHook = reference to function(const AFieldName: string;
    const AField: TField): string;

  // Policy di disclosure/azione, gia' risolta, passata al builder del contesto.
  TAIContextPolicy = record
    DataDisclosure: TAIDataDisclosure;
    AllowActions: Boolean;       // se False, le azioni non saranno esposte al
                                 // tool registry (non incide sulla raccolta dati)
    MaskHook: TAIMaskHook;       // opzionale

    class function Create(ADisclosure: TAIDataDisclosure;
      AAllowActions: Boolean; AMaskHook: TAIMaskHook = nil): TAIContextPolicy; static;
    // Policy di default prudente: nessun dato, nessuna azione.
    class function Restrictive: TAIContextPolicy; static;
  end;

  // Esito dell'estrazione di un singolo campo: cio' che e' lecito esporre.
  // Costruito esclusivamente da TAIFieldExtractor.
  TAIFieldValue = record
    FieldName: string;       // nome del campo (assente solo per slSpecial)
    DataType: string;        // tipo logico del campo (per orientamento)
    Value: string;           // valore gia' eventualmente mascherato/omesso
    Sensitivity: TAISensitivity;
    WasMasked: Boolean;      // true se il valore reale e' stato alterato/omesso

    function ToJSON: TJSONObject; // di proprieta' del chiamante
  end;

  // Record corrente di un componente: i suoi campi, gia' filtrati dall'extractor.
  TAIRecordContext = record
    HasRecord: Boolean;                 // false se dataset chiuso/vuoto/EOF+BOF
    Fields: TArray<TAIFieldValue>;

    procedure AddField(const AField: TAIFieldValue);
    function FieldCount: Integer;
    function ToJSON: TJSONObject;       // di proprieta' del chiamante
  end;

  // Una condizione di filtro attiva in questo momento sul componente.
  TAIActiveFilter = record
    Name: string;
    CurrentValue: string;  // descrizione testuale dello stato attuale del filtro
  end;

  // Contesto dinamico di un singolo componente vivo. Variante per tipo:
  //  - View  : RowCount + record corrente + filtri attivi
  //  - Pivot  : RowCount (aggregato) + filtri attivi (no record corrente utile)
  //  - Card   : record corrente (il contenuto stesso della card)
  //  - File   : record corrente + metadati file (popolati dal builder)
  // I campi non pertinenti a un tipo restano vuoti (HasRecord=false, RowCount=-1).
  TAIComponentContext = record
    Kind: TzComponentType;
    Title: string;
    IsFocused: Boolean;              // ha il focus dell'utente in questo momento
    RowCount: Integer;              // righe visibili dopo i filtri; -1 se non pertinente
    ActiveFilters: TArray<TAIActiveFilter>;
    CurrentRecord: TAIRecordContext;

    procedure AddFilter(const AFilter: TAIActiveFilter);
    function KindName: string;
    function HasRowCount: Boolean;
    function HasFilters: Boolean;
    function ToJSON: TJSONObject;    // di proprieta' del chiamante
  end;

  // Contesto radice: dove si trova l'utente e cosa ha sotto gli occhi ora.
  TAIContext = record
    FormId: string;                 // identificativo della form/voce di menu attiva
    FormTitle: string;
    Policy: TAIContextPolicy;       // gia' risolta
    Components: TArray<TAIComponentContext>; // solo i componenti vivi/attivi

    procedure AddComponent(const AComp: TAIComponentContext);
    function ComponentCount: Integer;
    function FocusedComponent: string; // Title del componente in focus, '' se nessuno
    function ToJSON: TJSONObject;    // di proprieta' del chiamante
  end;

const
  AI_OMITTED = '[omesso]';

implementation

{ TAIContextPolicy }

class function TAIContextPolicy.Create(ADisclosure: TAIDataDisclosure;
  AAllowActions: Boolean; AMaskHook: TAIMaskHook): TAIContextPolicy;
begin
  Result.DataDisclosure := ADisclosure;
  Result.AllowActions := AAllowActions;
  Result.MaskHook := AMaskHook;
end;

class function TAIContextPolicy.Restrictive: TAIContextPolicy;
begin
  Result.DataDisclosure := ddNone;
  Result.AllowActions := False;
  Result.MaskHook := nil;
end;

{ TAIFieldValue }

function TAIFieldValue.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  // slSpecial non espone il nome: la sola presenza del campo sarebbe informativa.
  if Sensitivity <> slSpecial then
  begin
    Result.AddPair('field', FieldName);
    if not DataType.IsEmpty then
      Result.AddPair('type', DataType);
  end;
  Result.AddPair('value', Value);
  if WasMasked then
    Result.AddPair('masked', TJSONBool.Create(True));
end;

{ TAIRecordContext }

procedure TAIRecordContext.AddField(const AField: TAIFieldValue);
begin
  Fields := Fields + [AField];
end;

function TAIRecordContext.FieldCount: Integer;
begin
  Result := Length(Fields);
end;

function TAIRecordContext.ToJSON: TJSONObject;
var
  Arr: TJSONArray;
  F: TAIFieldValue;
begin
  Result := TJSONObject.Create;
  Result.AddPair('hasRecord', TJSONBool.Create(HasRecord));
  if HasRecord and (FieldCount > 0) then
  begin
    Arr := TJSONArray.Create;
    for F in Fields do
      Arr.Add(F.ToJSON);
    Result.AddPair('fields', Arr);
  end;
end;

{ TAIComponentContext }

procedure TAIComponentContext.AddFilter(const AFilter: TAIActiveFilter);
begin
  ActiveFilters := ActiveFilters + [AFilter];
end;

function TAIComponentContext.KindName: string;
begin
  Result := zComponentTypeToStr(Kind);
end;

function TAIComponentContext.HasRowCount: Boolean;
begin
  Result := RowCount >= 0;
end;

function TAIComponentContext.HasFilters: Boolean;
begin
  Result := Length(ActiveFilters) > 0;
end;

function TAIComponentContext.ToJSON: TJSONObject;
var
  FiltersArr: TJSONArray;
  Filter: TAIActiveFilter;
  FilterObj: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('kind', KindName);
  Result.AddPair('title', Title);
  if IsFocused then
    Result.AddPair('focused', TJSONBool.Create(True));

  if HasRowCount then
    Result.AddPair('rowCount', TJSONNumber.Create(RowCount));

  if HasFilters then
  begin
    FiltersArr := TJSONArray.Create;
    for Filter in ActiveFilters do
    begin
      FilterObj := TJSONObject.Create;
      FilterObj.AddPair('name', Filter.Name);
      if not Filter.CurrentValue.IsEmpty then
        FilterObj.AddPair('value', Filter.CurrentValue);
      FiltersArr.Add(FilterObj);
    end;
    Result.AddPair('filters', FiltersArr);
  end;

  if CurrentRecord.HasRecord then
    Result.AddPair('currentRecord', CurrentRecord.ToJSON);
end;

{ TAIContext }

procedure TAIContext.AddComponent(const AComp: TAIComponentContext);
begin
  Components := Components + [AComp];
end;

function TAIContext.ComponentCount: Integer;
begin
  Result := Length(Components);
end;

function TAIContext.FocusedComponent: string;
var
  C: TAIComponentContext;
begin
  Result := '';
  for C in Components do
    if C.IsFocused then
      Exit(C.Title);
end;

function TAIContext.ToJSON: TJSONObject;
var
  Arr: TJSONArray;
  C: TAIComponentContext;
  PolicyObj: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('formId', FormId);
  Result.AddPair('formTitle', FormTitle);

  // La policy nel JSON serve all'orientamento del modello (sa quanto puo'
  // chiedere), non come dato sensibile.
  PolicyObj := TJSONObject.Create;
  case Policy.DataDisclosure of
    ddFull:   PolicyObj.AddPair('disclosure', 'full');
    ddMasked: PolicyObj.AddPair('disclosure', 'masked');
    ddNone:   PolicyObj.AddPair('disclosure', 'none');
  end;
  PolicyObj.AddPair('allowActions', TJSONBool.Create(Policy.AllowActions));
  Result.AddPair('policy', PolicyObj);

  if ComponentCount > 0 then
  begin
    Arr := TJSONArray.Create;
    for C in Components do
      Arr.Add(C.ToJSON);
    Result.AddPair('components', Arr);
  end;
end;

end.
