// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-21
// ---------------------------------------------------------------------------
unit zToolFilter;

{
  TzToolFilter — classe base astratta per i filtri toolbar (dxBar) dei componenti DB.
  TzToolFilterRegistry — registro e factory dei filtri disponibili nell'applicazione.

  Responsabilità di TzToolFilter:
  - Definire il contratto minimo per tutti i filtri (FilterName + Description + Apply)
  - Essere l'unica dipendenza che la libreria (zSystem, BaseFrm) ha sul
  meccanismo dei filtri
  - Fornire ai discendenti gli accessor con fallback (FilterCaption, FilterWidth,
  ecc.) che leggono gli override dal TzToolFilterProps persistito, quando presente

  Responsabilità di TzToolFilterRegistry:
  - Tenere il catalogo delle classi TzToolFilter registrate dai progetti
  - Fungere da factory: dato il prop persistito, restituisce l'istanza concreta
  (costruttore virtuale Create(AProps) — non servono factory function)
  - Rendere interrogabile l'elenco dei filtri disponibili (per AI context, debug)

  Non contiene:
  - Nessuna logica di filtro concreta
  - Nessuna dipendenza dai progetti (gesty, wintarif)
  - Nessun riferimento a dmFilters, TTools o dxBar

  Le implementazioni concrete vivono nei progetti:
  gesty: Gesty_Filters.pas
  wt:    WT_Filters.pas

  Registrazione:
  Ogni unit *_Filters chiama TzToolFilterRegistry.Register(Classe) nella propria
  sezione initialization. BaseFrm non conosce le classi concrete — usa
  solo TzToolFilterRegistry.Resolve/ApplyFilter.

  --------------------------------------------------------------------------
  2026-09-06 — Istanze multiple della stessa classe di filtro
  --------------------------------------------------------------------------
  Prima di questa revisione la chiave di risoluzione nel registro era
  TzToolFilterProps.Name. Poiche' Name e' anche la chiave dell'elemento nella
  collezione ToolFilters della view, una view non poteva avere due filtri
  della stessa classe (due 'PickList' su due campi diversi): il secondo
  sovrascriveva il primo, e rinominare Name per distinguerli rendeva il filtro
  non risolvibile.

  Ora l'identita' e' sdoppiata:
  - TzToolFilterProps.FilterName = CLASSE registrata (chiave del registro)
  - TzToolFilterProps.Name       = ISTANZA (chiave nella collezione della view)

  La risoluzione passa da EffectiveFilterName, che ricade su Name quando
  FilterName non e' valorizzata: le configurazioni LZ preesistenti
  (Name = 'PickList') continuano a funzionare senza conversione.
}

interface

uses
  System.Classes,
  System.Generics.Collections,
  zFbDataSet,
  zSystem,
  cxBarEditItem;

type
  TzToolFilter = class;
  TzToolFilterClass = class of TzToolFilter;

  // ── Classe base astratta ──────────────────────────────────────────────────────

  TzToolFilter = class abstract
  private
    FProps: TzToolFilterProps;
    FInitialValue: TFilterInitialValue;
    // True quando FProps e' stato creato dalla factory per conto di questo
    // filtro (overload Resolve per nome): in quel caso e' il filtro a doverlo
    // distruggere, altrimenti FProps appartiene alla collezione della view.
    FOwnsProps: Boolean;
  protected
    // ── Accessor con fallback ─────────────────────────────────────────────────
    function FilterCaption(const Default: string): string;
    function FilterHint(const Default: string): string;
    function FilterWidth(const Default: Integer): Integer;
    // Assegna a Item la larghezza del filtro (LZ o Default) scalata sul DPI del
    // BarManager. TdxBarItem.Width e' in pixel alla scala corrente del manager
    // (TdxBarItemLink.GetWidth lo converte con BarManager.ScaleFactor e
    // TdxBarItem.ChangeScale lo rimoltiplica a ogni cambio DPI): un item creato
    // in esecuzione, quando la form e' gia' scalata, deve nascere gia' scalato,
    // altrimenti a 150% il combo perde un terzo della larghezza e il testo si
    // tronca. Valori <= 0 non assegnano nulla: resta la larghezza automatica.
    procedure SetFilterWidth(Item: TcxBarEditItem; const Default: Integer);
    function FilterFieldName(const Default: string): string;
    // Posizione dell'ItemLink sulla dxBar (-1 = append).
    function FilterPosition: Integer;

    // Accessor allineati con TzToolFilterProps
    function FilterPickListName(const Default: string): string;
    function FilterAllowNull(const Default: Boolean): Boolean;
    function FilterCaptionAll(const Default: string): string;
    function FilterPickList: TzPickList;

    // Nome dell'ISTANZA (TzToolFilterProps.Name). Serve ai discendenti che
    // devono comporre un nome univoco per il controllo sulla dxBar quando la
    // stessa classe di filtro compare piu' volte sulla stessa view.
    //
    // Restituisce Props.Name SOLO quando e' un vero nome di istanza, cioe'
    // diverso dalla classe (EffectiveFilterName). Quando Name coincide con la
    // classe (configurazioni LZ precedenti, overload per nome usato da
    // BaseFrm per i TzToolFilterDefs) restituisce Default, cioe' il nome
    // storico composto dal chiamante (classe + pick list + campo): due filtri
    // 'Boolean' definiti da codice sulla stessa view su campi diversi devono
    // continuare a produrre due controlli distinti, non uno solo.
    function FilterInstanceName(const Default: string): string;

    // Converte Props.CustomValue (stringa) nel Variant da assegnare a
    // EditValue quando InitialValue = ivCustom.
    function CustomEditValue: Variant;

    // Compone la descrizione standard 'FilterDesc (default: ...)'
    function DescribeInitial(const FilterDesc, DefaultDesc: string): string;

    property Props: TzToolFilterProps read FProps;
    property InitialValue: TFilterInitialValue read FInitialValue;
  public
    // Costruttore principale
    constructor Create(AProps: TzToolFilterProps); overload; virtual;

    // Creazione manuale senza prop
    constructor Create(AInitialValue: TFilterInitialValue); overload;

    destructor Destroy; override;

    class function FilterName: string; virtual; abstract;
    function Description: string; virtual; abstract;
    procedure Apply(Component: TComponent; DataSet: TzFbDataSet); virtual; abstract;

    class procedure BindFilter(Item: TcxBarEditItem; const ParamName: string);
    class procedure ApplyTo(Component: TComponent; DataSet: TzFbDataSet; AInitialValue: TFilterInitialValue = ivDefault; const APosition: Integer = -1); overload;
  end;

  // ── Registro e factory ────────────────────────────────────────────────────────

  TzToolFilterRegistry = class
  private
    class var FEntries: TDictionary<string, TzToolFilterClass>;
    class procedure EnsureCreated;
  public
    class procedure Register(FilterClass: TzToolFilterClass);

    // Factory principale - basata su Props.
    // La classe da istanziare e' Props.EffectiveFilterName (FilterName, con
    // fallback su Name per le configurazioni LZ precedenti).
    class function Resolve(Props: TzToolFilterProps): TzToolFilter; overload;
    class procedure ApplyFilter(Props: TzToolFilterProps; Component: TComponent; DataSet: TzFbDataSet); overload;

    // Overload di compatibilità per chiamanti legacy (BaseFrm, wintarif, ecc.)
    class function Resolve(const Name: string; InitialValue: TFilterInitialValue; Params: TStrings): TzToolFilter; overload;
    class procedure ApplyFilter(const Name: string; Component: TComponent; DataSet: TzFbDataSet; InitialValue: TFilterInitialValue = ivDefault; Params: TStrings = nil); overload;

    // Utilità di ispezione
    class function RegisteredNames: TArray<string>;
    class function IsRegistered(const Name: string): Boolean;
    // Come IsRegistered, ma parte dalla classe effettiva del prop.
    class function IsRegisteredFor(Props: TzToolFilterProps): Boolean;

    // ── Descrizioni per gli editor di configurazione ─────────────────────────
    // Descrizione della CLASSE, senza alcuna istanza configurata. Restituisce
    // stringa vuota quando la classe non sa dire nulla di utile a props vuote
    // (e' il caso dei filtri generici PickList/Boolean, la cui Description
    // dipende interamente dalla configurazione): il chiamante ricade sul nome.
    class function DescribeClass(const AFilterName: string): string;
    // Descrizione dell'ISTANZA configurata, con ricaduta su TzToolFilterProps.Description.
    class function Describe(Props: TzToolFilterProps): string;

    // Pulizia
    class procedure Finalize;
  end;

implementation

uses
  System.SysUtils,
  dxBar,
  System.Variants,
  System.DateUtils,
  zToolFilterHelper;

// dxBar non espone ScaleFactor: e' protected in TcxScalableComponent, da cui
// TdxBarManager discende. La classe di accesso e' l'idioma gia' usato in
// zFormController (TdxCustomLayoutItemAccess) e zMsg
// (TdxMessageDialogFormAccess): un discendente dichiarato qui rende visibili
// i membri protected dell'antenato senza toccare la libreria.
type
  TdxBarManagerAccess = class(TdxBarManager);

// ── TzToolFilterParamMap ──────────────────────────────────────────────────────
type
  TzToolFilterParamMap = class(TComponent)
  private
    FMap: TDictionary<TcxBarEditItem, string>;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Bind(Item: TcxBarEditItem; const ParamName: string);
    procedure ImpostaFiltroHandler(Sender: TObject);
    procedure AllineaCaselleGemelle(Origine: TcxBarEditItem; const ParamName: string);
  end;

constructor TzToolFilterParamMap.Create(AOwner: TComponent);
begin
  inherited;
  FMap := TDictionary<TcxBarEditItem, string>.Create;
end;

destructor TzToolFilterParamMap.Destroy;
begin
  FreeAndNil(FMap);
  inherited;
end;

procedure TzToolFilterParamMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent is TcxBarEditItem) then
    FMap.Remove(TcxBarEditItem(AComponent));
end;

procedure TzToolFilterParamMap.Bind(Item: TcxBarEditItem; const ParamName: string);
begin
  Assert(Assigned(Item));
  FMap.AddOrSetValue(Item, ParamName);
  Item.FreeNotification(Self);
  Item.OnChange := ImpostaFiltroHandler;
end;

procedure TzToolFilterParamMap.ImpostaFiltroHandler(Sender: TObject);
var
  ParamName: string;
begin
  // Con i filtri sospesi non si imposta niente e non si allinea niente: e' anche
  // il caso delle caselle gemelle aggiornate da AllineaCaselleGemelle, che
  // altrimenti rimbalzerebbero il valore all'infinito.
  if TzToolFilterHelper.DisableImpostaFiltro then
    Exit;
  if not(Sender is TcxBarEditItem) then
    Exit;
  if not FMap.TryGetValue(TcxBarEditItem(Sender), ParamName) then
    Exit;
  TzToolFilterHelper.ImpostaFiltro(Sender, ParamName);
  AllineaCaselleGemelle(TcxBarEditItem(Sender), ParamName);
end;

procedure TzToolFilterParamMap.AllineaCaselleGemelle(Origine: TcxBarEditItem; const ParamName: string);
var
  Coppia: TPair<TcxBarEditItem, string>;
  Gemelle: TList<TcxBarEditItem>;
  Gemella: TcxBarEditItem;
  StatoPrecedente: Boolean;

  function StessoValore(const A, B: Variant): Boolean;
  begin
    if VarIsNull(A) or VarIsNull(B) then
      Exit(VarIsNull(A) and VarIsNull(B));
    try
      Result := VarCompareValue(A, B) = vrEqual;
    except
      Result := False;
    end;
  end;

begin
  // Piu' componenti sullo stesso dataset (vista, pivot, grafico in schede
  // diverse) hanno ciascuno la propria barra con le proprie caselle di filtro.
  // Il filtro scrive il parametro del dataset, quindi i dati sono gia' gli
  // stessi per tutti; le caselle degli altri componenti invece restavano sul
  // valore vecchio, e chi passava da una scheda all'altra vedeva un filtro che
  // non corrispondeva ai dati. Gemelle = stesso dataset (Tag) e stesso
  // parametro. Si raccolgono prima e si aggiornano dopo, perche' assegnare
  // EditValue non deve avvenire mentre si scorre il dizionario.
  Gemelle := TList<TcxBarEditItem>.Create;
  try
    for Coppia in FMap do
      if (Coppia.Key <> Origine) and (Coppia.Key.Tag = Origine.Tag) and SameText(Coppia.Value, ParamName) then
        if not StessoValore(Coppia.Key.EditValue, Origine.EditValue) then
          Gemelle.Add(Coppia.Key);

    if Gemelle.Count = 0 then
      Exit;

    // Il parametro e' gia' impostato e il dataset gia' riaperto dall'origine:
    // le gemelle cambiano solo valore a video, senza un'altra riapertura.
    StatoPrecedente := TzToolFilterHelper.DisableImpostaFiltro;
    TzToolFilterHelper.DisableImpostaFiltro := True;
    try
      for Gemella in Gemelle do
        Gemella.EditValue := Origine.EditValue;
    finally
      TzToolFilterHelper.DisableImpostaFiltro := StatoPrecedente;
    end;
  finally
    Gemelle.Free;
  end;
end;

var
  __FilterParamMap: TzToolFilterParamMap;

// ── TzToolFilter ──────────────────────────────────────────────────────────────

constructor TzToolFilter.Create(AProps: TzToolFilterProps);
begin
  inherited Create;
  FProps := AProps;
  FOwnsProps := False;
  if Assigned(AProps) then
    FInitialValue := AProps.EffectiveInitialValue
  else
    FInitialValue := ivDefault;
end;

constructor TzToolFilter.Create(AInitialValue: TFilterInitialValue);
begin
  inherited Create;
  FProps := nil;
  FOwnsProps := False;
  FInitialValue := AInitialValue;
end;

destructor TzToolFilter.Destroy;
begin
  if FOwnsProps then
    FreeAndNil(FProps);
  inherited;
end;

function TzToolFilter.FilterCaption(const Default: string): string;
begin
  Result := Default;
  if Assigned(FProps) and not FProps.EffectiveCaption.IsEmpty then
    Result := FProps.EffectiveCaption;
end;

function TzToolFilter.FilterHint(const Default: string): string;
begin
  Result := Default;
  if Assigned(FProps) and not FProps.EffectiveHint.IsEmpty then
    Result := FProps.EffectiveHint;
end;

function TzToolFilter.FilterWidth(const Default: Integer): Integer;
begin
  if Assigned(FProps) then
    Result := FProps.EffectiveWidth(Default)
  else
    Result := Default;
end;

procedure TzToolFilter.SetFilterWidth(Item: TcxBarEditItem; const Default: Integer);
var
  LarghezzaLogica: Integer;
begin
  LarghezzaLogica := FilterWidth(Default);
  if LarghezzaLogica <= 0 then
    Exit;
  if Assigned(Item.BarManager) then
    Item.Width :=
      TdxBarManagerAccess(Item.BarManager).ScaleFactor.Apply(LarghezzaLogica)
  else
    Item.Width := LarghezzaLogica;
end;

function TzToolFilter.FilterFieldName(const Default: string): string;
begin
  Result := Default;
  if Assigned(FProps) and not FProps.EffectiveFieldName.IsEmpty then
    Result := FProps.EffectiveFieldName;
end;

function TzToolFilter.FilterPosition: Integer;
begin
  Result := -1;
  if Assigned(FProps) then
    Result := FProps.Position;
end;

function TzToolFilter.FilterPickListName(const Default: string): string;
begin
  Result := Default;
  if Assigned(FProps) and not FProps.EffectivePickListName.IsEmpty then
    Result := FProps.EffectivePickListName;
end;

function TzToolFilter.FilterAllowNull(const Default: Boolean): Boolean;
begin
  if Assigned(FProps) then
    Result := FProps.EffectiveAllowNull
  else
    Result := Default;
end;

function TzToolFilter.FilterCaptionAll(const Default: string): string;
begin
  Result := Default;
  if Assigned(FProps) and not FProps.EffectiveCaptionAll.IsEmpty then
    Result := FProps.EffectiveCaptionAll;
end;

function TzToolFilter.FilterPickList: TzPickList;
begin
  Result := nil;
  if Assigned(FProps) then
    Result := FProps.PickList;
end;

function TzToolFilter.FilterInstanceName(const Default: string): string;
begin
  Result := Default;

  if not Assigned(FProps) then
    Exit;

  if FProps.Name.IsEmpty then
    Exit;

  // Name uguale alla classe = configurazione senza nome di istanza: si tiene
  // il nome storico (Default), che il chiamante compone gia' con pick list e
  // campo e che resta univoco fra istanze su campi diversi.
  if SameText(FProps.Name, FProps.EffectiveFilterName) then
    Exit;

  Result := FProps.Name;
end;

function TzToolFilter.CustomEditValue: Variant;
var
  S: string;
  I: Int64;
  F: Double;
  D: TDateTime;
begin
  Result := Null;
  if not Assigned(FProps) then
    Exit;
  S := FProps.CustomValue.Trim;
  if S.IsEmpty then
    Exit;

  // Mantis #141 - 2026-09-20: il tipo del valore personalizzato si deduce dal
  // testo, perche' qui il parametro di destinazione non e' ancora noto. Due
  // deduzioni erano sbagliate e arrivavano intatte fino al parametro:
  //
  // - un codice che comincia per zero ('0123', '007') e' un codice, non un
  //   numero: convertirlo perdeva gli zeri iniziali e cercava in archivio un
  //   valore che non esiste;
  // - TryStrToFloat legge le impostazioni locali, quindi '1.234' diventava
  //   milleduecentotrentaquattro su una macchina italiana e uno-virgola-due
  //   su un'altra. Ora il numero con la virgola si riconosce solo quando il
  //   separatore decimale c'e' davvero.
  //
  // Quello che resta di ambiguo lo risolve la conversione guidata dal tipo del
  // parametro in TzParamValue.Assegna, che e' l'unico punto che il tipo lo sa.
  if (S = '0') or not S.StartsWith('0') then
    if TryStrToInt64(S, I) then
      Exit(I);

  if TryISO8601ToDate(S, D) then
    Exit(D);

  if S.Contains(FormatSettings.DecimalSeparator) then
    if TryStrToFloat(S, F) then
      Exit(F);

  Result := S;
end;

function TzToolFilter.DescribeInitial(const FilterDesc, DefaultDesc: string): string;
begin
  case FInitialValue of
    ivNull:
      Result := FilterDesc + ' (default: nessun filtro)';
    ivCustom:
      Result := FilterDesc + ' (default: ' + VarToStr(CustomEditValue) + ')';
  else
    Result := FilterDesc + ' (default: ' + DefaultDesc + ')';
  end;
end;

class procedure TzToolFilter.BindFilter(Item: TcxBarEditItem; const ParamName: string);
begin
  __FilterParamMap.Bind(Item, ParamName);
end;

class procedure TzToolFilter.ApplyTo(Component: TComponent; DataSet: TzFbDataSet; AInitialValue: TFilterInitialValue; const APosition: Integer);
var
  Filter: TzToolFilter;
  TmpProps: TzToolFilterProps;
begin
  TmpProps := TzToolFilterProps.Create(nil);
  try
    TmpProps.FilterName := Self.FilterName;
    TmpProps.Name := Self.FilterName;
    TmpProps.Position := APosition;
    TmpProps.InitialValue := AInitialValue;
    Filter := Self.Create(TmpProps);
    try
      Filter.Apply(Component, DataSet);
    finally
      Filter.Free;
    end;
  finally
    TmpProps.Free;
  end;
end;

// ── TzToolFilterRegistry ──────────────────────────────────────────────────────

class procedure TzToolFilterRegistry.EnsureCreated;
begin
  if not Assigned(FEntries) then
    FEntries := TDictionary<string, TzToolFilterClass>.Create;
end;

class procedure TzToolFilterRegistry.Register(FilterClass: TzToolFilterClass);
begin
  EnsureCreated;
  FEntries.AddOrSetValue(LowerCase(FilterClass.FilterName), FilterClass);
end;

class function TzToolFilterRegistry.Resolve(Props: TzToolFilterProps): TzToolFilter;
var
  FilterClass: TzToolFilterClass;
  Key: string;
begin
  if not Assigned(Props) then
    raise Exception.Create('TzToolFilterRegistry.Resolve: Props non assegnato');

  EnsureCreated;

  // La CLASSE e' FilterName; Name identifica l'istanza dentro la view.
  // EffectiveFilterName ricade su Name per le configurazioni precedenti.
  Key := Props.EffectiveFilterName;

  if not FEntries.TryGetValue(LowerCase(Key), FilterClass) then
    raise Exception.CreateFmt('Filtro bar "%s" non registrato. Verificare che la unit *_Filters sia inclusa nel progetto.', [Key]);

  Result := FilterClass.Create(Props);
end;

class function TzToolFilterRegistry.Resolve(const Name: string; InitialValue: TFilterInitialValue; Params: TStrings): TzToolFilter;
var
  TmpProps: TzToolFilterProps;
begin
  TmpProps := TzToolFilterProps.Create(nil);
  try
    TmpProps.FilterName := Name;
    TmpProps.Name := Name;
    TmpProps.InitialValue := InitialValue;
    if Assigned(Params) then
      TmpProps.Params.Assign(Params);

    Result := Resolve(TmpProps);
    // TmpProps non appartiene a nessuna collezione: la proprieta' passa al
    // filtro restituito, che lo distrugge nel proprio destructor.
    // Senza questo passaggio ogni chiamata perdeva un TzToolFilterProps.
    Result.FOwnsProps := True;
  except
    TmpProps.Free;
    raise;
  end;
end;

class procedure TzToolFilterRegistry.ApplyFilter(Props: TzToolFilterProps; Component: TComponent; DataSet: TzFbDataSet);
var
  Filter: TzToolFilter;
begin
  if not Assigned(Props) then
    Exit;

  if not Props.Visible then
    Exit;

  Filter := Resolve(Props);
  try
    Filter.Apply(Component, DataSet);
  finally
    Filter.Free;
  end;
end;

class procedure TzToolFilterRegistry.ApplyFilter(const Name: string; Component: TComponent; DataSet: TzFbDataSet; InitialValue: TFilterInitialValue; Params: TStrings);
var
  TmpProps: TzToolFilterProps;
begin
  TmpProps := TzToolFilterProps.Create(nil);
  try
    TmpProps.FilterName := Name;
    TmpProps.Name := Name;
    TmpProps.InitialValue := InitialValue;
    if Assigned(Params) then
      TmpProps.Params.Assign(Params);

    ApplyFilter(TmpProps, Component, DataSet);
  finally
    TmpProps.Free;
  end;
end;

class function TzToolFilterRegistry.RegisteredNames: TArray<string>;
var
  Keys: TArray<string>;
  I: Integer;
begin
  EnsureCreated;
  Keys := FEntries.Keys.ToArray;
  SetLength(Result, Length(Keys));
  for I := 0 to High(Keys) do
    Result[I] := FEntries[Keys[I]].FilterName;
end;

class function TzToolFilterRegistry.IsRegistered(const Name: string): Boolean;
begin
  EnsureCreated;
  Result := FEntries.ContainsKey(LowerCase(Name));
end;

class function TzToolFilterRegistry.IsRegisteredFor(Props: TzToolFilterProps): Boolean;
begin
  Result := Assigned(Props) and IsRegistered(Props.EffectiveFilterName);
end;

class function TzToolFilterRegistry.DescribeClass(const AFilterName: string): string;
var
  Filter: TzToolFilter;
  TmpProps: TzToolFilterProps;
  Testo: string;
begin
  Result := '';

  TmpProps := TzToolFilterProps.Create(nil);
  try
    TmpProps.FilterName := AFilterName;
    TmpProps.Name := AFilterName;

    try
      Filter := Resolve(TmpProps);
      try
        Testo := Filter.Description.Trim;
      finally
        Filter.Free;
      end;
    except
      Testo := '';
    end;
  finally
    TmpProps.Free;
  end;

  // I filtri generici (PickList, Boolean) compongono Description dalla
  // configurazione: a props vuote restituiscono un moncone tipo 'Filtro '.
  // In quel caso e' meglio non dire nulla e lasciare il nome della classe.
  if Testo.IsEmpty then
    Exit;
  if SameText(Testo, 'Filtro') then
    Exit;
  if Testo.EndsWith('Filtro') then
    Exit;

  Result := Testo;
end;

class function TzToolFilterRegistry.Describe(Props: TzToolFilterProps): string;
var
  Filter: TzToolFilter;
begin
  Result := '';

  if not Assigned(Props) then
    Exit;

  try
    Filter := Resolve(Props);
    try
      Result := Filter.Description.Trim;
    finally
      Filter.Free;
    end;
  except
    Result := '';
  end;

  if Result.IsEmpty or SameText(Result, 'Filtro') then
    Result := Props.Description;
end;

class procedure TzToolFilterRegistry.Finalize;
begin
  FreeAndNil(FEntries);
end;

initialization

__FilterParamMap := TzToolFilterParamMap.Create(nil);

finalization

TzToolFilterRegistry.Finalize;
FreeAndNil(__FilterParamMap);

end.
