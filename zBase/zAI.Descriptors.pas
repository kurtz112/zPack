unit zAI.Descriptors;

{
  Layer di descrizione condiviso per il sottosistema AI.

  Scopo: fornire una rappresentazione NEUTRA della struttura di un componente
  (View / Card / Pivot / ...) e delle sue azioni e filtri, indipendente sia
  dalla GUI runtime VCL sia dai consumatori a valle.

  Due consumatori previsti:
    - HelpGen.* : generazione documentazione Word (batch, offline).
    - TAISystemPromptBuilder : contesto per la chat AI (runtime).

  La fonte semantica e' SEMPRE la Description dichiarativa scritta nei props
  (TzToolAction.Description, TzToolFilterProps.Description,
  TzBaseComponentProps.Description), non i Caption/Hint del TCustomAction
  runtime. Questa unit definisce solo i tipi e il contratto; la costruzione
  effettiva dei descrittori (dai props / dalle interfacce IzBaseComponent)
  vive nel passo 2.

  Vincoli di dipendenza: questa unit NON usa HelpGen.*, ne' alcun provider AI,
  ne' alcuna unit di UI. Puo' dipendere solo dalla RTL e da zSystem per
  l'enumerato TzComponentType.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  zSystem; // solo per TzComponentType

type
  // Descrittore neutro di una singola azione (tool action) di un componente.
  // Popolato a partire dalla Description dichiarativa, non dal TCustomAction.
  TAIActionDescriptor = record
    Name: string;        // nome interno dell'azione (TCustomAction.Name)
    Caption: string;     // etichetta leggibile (fallback se Description vuota)
    Hint: string;        // hint runtime del TCustomAction (fallback descrittivo)
    ShortCut: string;    // rappresentazione testuale dello shortcut, se presente
    Description: string; // testo descrittivo dichiarativo (TzToolAction.Description)

    class function Create(const AName, ACaption, AHint, AShortCut,
      ADescription: string): TAIActionDescriptor; static;
    function IsEmpty: Boolean;
    function ToJSON: TJSONObject; // l'oggetto e' di proprieta' del chiamante
  end;

  // Descrittore neutro di un singolo filtro di un componente filtrabile.
  // Popolato dalla Description dichiarativa di TzToolFilterProps.
  TAIFilterDescriptor = record
    Name: string;        // nome interno del filtro
    Description: string; // TzToolFilterProps.Description

    class function Create(const AName,
      ADescription: string): TAIFilterDescriptor; static;
    function IsEmpty: Boolean;
    function ToJSON: TJSONObject; // l'oggetto e' di proprieta' del chiamante
  end;

  // Descrittore neutro di un componente (View / Card / Pivot / File / Map).
  // E' il tipo cardine condiviso fra HelpGen e il contesto chat.
  TAIComponentDescriptor = record
    Kind: TzComponentType;            // ctView / ctCard / ctPivot / ...
    Title: string;                    // titolo leggibile (IzBaseComponent.ConfigTitle)
    Description: string;              // descrizione dichiarativa del componente
    Actions: TArray<TAIActionDescriptor>;
    Filters: TArray<TAIFilterDescriptor>;

    function KindName: string;        // nome testuale del Kind (per JSON/log)
    function HasActions: Boolean;
    function HasFilters: Boolean;
    function ToJSON: TJSONObject;     // l'oggetto e' di proprieta' del chiamante

    // Helper di costruzione incrementale, comodi per chi popola il record
    // scorrendo props o componenti runtime.
    procedure AddAction(const AAction: TAIActionDescriptor); overload;
    procedure AddAction(const AName, ACaption, AHint, AShortCut,
      ADescription: string); overload;
    procedure AddFilter(const AFilter: TAIFilterDescriptor); overload;
    procedure AddFilter(const AName, ADescription: string); overload;
  end;

  // Contratto opzionale: un componente che sa descriversi per l'AI.
  // In questo passo l'interfaccia e' definita ma non ancora implementata dai
  // componenti concreti (passo 3). Tenuta separata da IzBaseComponent per non
  // forzare ora modifiche alla gerarchia esistente.
  IzDescribable = interface
    ['{6F2A1B94-3D57-4E0C-9A18-7C4B5E2D8F03}']
    function DescribeAI: TAIComponentDescriptor;
  end;

// Converte un TzComponentType nella sua forma testuale stabile, usata nel JSON
// e nei log. Non localizzata: e' un identificatore, non una etichetta UI.
function zComponentTypeToStr(const AKind: TzComponentType): string;

implementation

function zComponentTypeToStr(const AKind: TzComponentType): string;
begin
  case AKind of
    ctView:  Result := 'view';
    ctCard:  Result := 'card';
    ctPivot: Result := 'pivot';
    ctFile:  Result := 'file';
    ctMap:   Result := 'map';
    ctRecordView: Result := 'recordview';
    ctTree: Result := 'tree';
    ctChart: Result := 'chart';
    ctScheduler: Result := 'scheduler';
  else
    Result := 'null';
  end;
end;

{ TAIActionDescriptor }

class function TAIActionDescriptor.Create(const AName, ACaption, AHint, AShortCut,
  ADescription: string): TAIActionDescriptor;
begin
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Hint := AHint;
  Result.ShortCut := AShortCut;
  Result.Description := ADescription;
end;

function TAIActionDescriptor.IsEmpty: Boolean;
begin
  Result := Name.IsEmpty and Caption.IsEmpty and Description.IsEmpty;
end;

function TAIActionDescriptor.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  Result.AddPair('caption', Caption);
  if not Hint.IsEmpty then
    Result.AddPair('hint', Hint);
  if not ShortCut.IsEmpty then
    Result.AddPair('shortcut', ShortCut);
  if not Description.IsEmpty then
    Result.AddPair('description', Description);
end;

{ TAIFilterDescriptor }

class function TAIFilterDescriptor.Create(const AName,
  ADescription: string): TAIFilterDescriptor;
begin
  Result.Name := AName;
  Result.Description := ADescription;
end;

function TAIFilterDescriptor.IsEmpty: Boolean;
begin
  Result := Name.IsEmpty and Description.IsEmpty;
end;

function TAIFilterDescriptor.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  if not Description.IsEmpty then
    Result.AddPair('description', Description);
end;

{ TAIComponentDescriptor }

function TAIComponentDescriptor.KindName: string;
begin
  Result := zComponentTypeToStr(Kind);
end;

function TAIComponentDescriptor.HasActions: Boolean;
begin
  Result := Length(Actions) > 0;
end;

function TAIComponentDescriptor.HasFilters: Boolean;
begin
  Result := Length(Filters) > 0;
end;

procedure TAIComponentDescriptor.AddAction(const AAction: TAIActionDescriptor);
begin
  Actions := Actions + [AAction];
end;

procedure TAIComponentDescriptor.AddAction(const AName, ACaption, AHint, AShortCut,
  ADescription: string);
begin
  AddAction(TAIActionDescriptor.Create(AName, ACaption, AHint, AShortCut, ADescription));
end;

procedure TAIComponentDescriptor.AddFilter(const AFilter: TAIFilterDescriptor);
begin
  Filters := Filters + [AFilter];
end;

procedure TAIComponentDescriptor.AddFilter(const AName, ADescription: string);
begin
  AddFilter(TAIFilterDescriptor.Create(AName, ADescription));
end;

function TAIComponentDescriptor.ToJSON: TJSONObject;
var
  ActionsArr, FiltersArr: TJSONArray;
  Action: TAIActionDescriptor;
  Filter: TAIFilterDescriptor;
begin
  Result := TJSONObject.Create;
  Result.AddPair('kind', KindName);
  Result.AddPair('title', Title);
  if not Description.IsEmpty then
    Result.AddPair('description', Description);

  if HasActions then
  begin
    ActionsArr := TJSONArray.Create;
    for Action in Actions do
      ActionsArr.Add(Action.ToJSON);
    Result.AddPair('actions', ActionsArr);
  end;

  if HasFilters then
  begin
    FiltersArr := TJSONArray.Create;
    for Filter in Filters do
      FiltersArr.Add(Filter.ToJSON);
    Result.AddPair('filters', FiltersArr);
  end;
end;

end.
