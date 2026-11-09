unit zAI.Context.Builder;

{
  Troncone B — costruzione del contesto runtime dallo stato VIVO.

  Due responsabilita':

    TAIFieldExtractor — l'UNICO punto in tutto il sistema autorizzato a leggere
      un TField. E' il cancello GDPR: incrocia il livello di sensibilita' del
      campo (dal classificatore) con la disclosure della policy, e legge il
      valore reale SOLO quando il risultato lo consente. Con disclosure ddNone,
      o con campo slRedacted/slSpecial sopra soglia, AsString NON viene chiamato:
      oscuramento ALLA FONTE, non in uscita.

    TAIContextBuilder — raccoglie il contesto dai componenti vivi di una form
      (record corrente, righe visibili, filtri attivi), delegando ogni lettura
      di campo all'extractor. Non lavora "a freddo": lo stato dinamico esiste
      solo su componenti istanziati con dataset attivo.

  Tabella di disclosure applicata dall'extractor (livello campo x policy):

                    ddFull        ddMasked       ddNone
    slNone          chiaro        chiaro         [omesso]
    slMasked        chiaro        mascherato     [omesso]
    slRedacted      chiaro        [omesso]       [omesso]
    slSpecial       RIMOSSO       RIMOSSO        RIMOSSO   (ignora la policy)

  "RIMOSSO" = il campo non viene emesso affatto, e nemmeno il suo nome.
}

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  zSystem,            // IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, TzComponentType
  zAI.Types,
  zAI.Context,
  zGdpr.Classifier;

type
  TAIFieldExtractor = record
  public
    // Estrae un singolo campo applicando classificazione + policy. Il flag
    // AEmit dice se il campo va emesso del tutto: false per slSpecial (rimosso).
    class function Extract(const AField: TField; const AFormMinLevel: TAISensitivity;
      const ARecord: TGdprRecordContext; const APolicy: TAIContextPolicy;
      const AClassifier: IzGdprClassifier; out AEmit: Boolean): TAIFieldValue; static;
  private
    // Maschera di default per tipo, usata per slMasked quando manca il MaskHook.
    class function DefaultMask(const AField: TField): string; static;
  end;

  // Risolve dal dataset i fatti del record che modulano la sensibilita'
  // (minore eta', tipo soggetto). E' la conoscenza di DOMINIO, specifica per
  // progetto: il builder generico non sa come si determina, la chiede e basta.
  // Iniettato esplicitamente (non opzionale): un progetto deve DICHIARARE la
  // propria logica, anche quando e' "nessun minore / sempre persona fisica".
  TAIRecordContextResolver = reference to function(
    const ADataSet: TDataSet): TGdprRecordContext;

  TAIContextBuilder = record
  private
    FClassifier: IzGdprClassifier;
    FPolicy: TAIContextPolicy;
    FFormMinLevel: TAISensitivity;
    FRecordResolver: TAIRecordContextResolver;

    function ExtractCurrentRecord(const ADataSet: TDataSet;
      const ARecord: TGdprRecordContext): TAIRecordContext;
  public
    class function Create(const AClassifier: IzGdprClassifier;
      const APolicy: TAIContextPolicy; const AFormMinLevel: TAISensitivity;
      const ARecordResolver: TAIRecordContextResolver): TAIContextBuilder; static;

    // Contesto di un singolo componente vivo. Restituisce False in AOk se il
    // componente non e' utilizzabile (no dataset / non IzBaseDbComponent).
    function BuildComponentContext(const AComp: IzBaseComponent;
      const AIsFocused: Boolean; out AOk: Boolean): TAIComponentContext;
  end;

implementation

{ TAIFieldExtractor }

function FieldTypeName(const ADataType: TFieldType): string;
begin
  case ADataType of
    ftString, ftWideString, ftFixedChar, ftFixedWideChar:
      Result := 'string';
    ftMemo, ftWideMemo:
      Result := 'text';
    ftSmallint, ftInteger, ftWord, ftLargeint, ftLongWord, ftShortint, ftByte:
      Result := 'integer';
    ftFloat, ftSingle, ftExtended:
      Result := 'float';
    ftCurrency, ftBCD, ftFMTBcd:
      Result := 'decimal';
    ftDate:
      Result := 'date';
    ftTime:
      Result := 'time';
    ftDateTime, ftTimeStamp:
      Result := 'datetime';
    ftBoolean:
      Result := 'boolean';
    ftBlob, ftGraphic:
      Result := 'blob';
  else
    Result := 'other';
  end;
end;

class function TAIFieldExtractor.DefaultMask(const AField: TField): string;
begin
  // Forma mascherata generica per tipo: conserva la "forma", non il contenuto.
  case AField.DataType of
    ftString, ftWideString, ftMemo, ftWideMemo, ftFixedChar:
      Result := '[testo]';
    ftSmallint, ftInteger, ftWord, ftLargeint, ftLongWord, ftShortint, ftByte:
      Result := '[numero]';
    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftSingle, ftExtended:
      Result := '[importo]';
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      Result := '[data]';
    ftBoolean:
      Result := '[si/no]';
  else
    Result := '[dato]';
  end;
end;

class function TAIFieldExtractor.Extract(const AField: TField;
  const AFormMinLevel: TAISensitivity; const ARecord: TGdprRecordContext;
  const APolicy: TAIContextPolicy; const AClassifier: IzGdprClassifier;
  out AEmit: Boolean): TAIFieldValue;
var
  Level: TAISensitivity;
begin
  AEmit := True;
  Level := AClassifier.Classify(AField, AFormMinLevel, ARecord);

  Result.FieldName := AField.FieldName;
  Result.DataType := FieldTypeName(AField.DataType);
  Result.Sensitivity := Level;
  Result.WasMasked := False;

  // slSpecial: rimosso sempre, ignora la policy. Non si legge nulla, non si
  // emette nulla (nemmeno il nome: lo gestisce comunque ToJSON, ma qui non
  // emettiamo proprio il campo).
  if Level = slSpecial then
  begin
    AEmit := False;
    Result.Value := AI_OMITTED;
    Result.WasMasked := True;
    Exit;
  end;

  // Disclosure ddNone: nessun dato di record. Nessuna lettura del valore.
  if APolicy.DataDisclosure = ddNone then
  begin
    Result.Value := AI_OMITTED;
    Result.WasMasked := True;
    Exit;
  end;

  // ddMasked: dipende dal livello del campo.
  if APolicy.DataDisclosure = ddMasked then
  begin
    case Level of
      slNone:
        Result.Value := AField.AsString;            // non sensibile: chiaro
      slMasked:
        begin
          if Assigned(APolicy.MaskHook) then
            Result.Value := APolicy.MaskHook(AField.FieldName, AField)
          else
            Result.Value := DefaultMask(AField);
          Result.WasMasked := True;
        end;
      slRedacted:
        begin
          Result.Value := AI_OMITTED;               // omesso, mai letto
          Result.WasMasked := True;
        end;
    end;
    Exit;
  end;

  // ddFull: accesso pieno al vedibile (slSpecial gia' escluso sopra).
  // slNone/slMasked/slRedacted passano tutti in chiaro.
  Result.Value := AField.AsString;
end;

{ TAIContextBuilder }

class function TAIContextBuilder.Create(const AClassifier: IzGdprClassifier;
  const APolicy: TAIContextPolicy; const AFormMinLevel: TAISensitivity;
  const ARecordResolver: TAIRecordContextResolver): TAIContextBuilder;
begin
  Result.FClassifier := AClassifier;
  Result.FPolicy := APolicy;
  Result.FFormMinLevel := AFormMinLevel;
  Result.FRecordResolver := ARecordResolver;
end;

function TAIContextBuilder.ExtractCurrentRecord(const ADataSet: TDataSet;
  const ARecord: TGdprRecordContext): TAIRecordContext;
var
  i: Integer;
  fv: TAIFieldValue;
  emit: Boolean;
begin
  Result := Default(TAIRecordContext);

  Result.HasRecord := Assigned(ADataSet) and ADataSet.Active
    and not (ADataSet.Bof and ADataSet.Eof and ADataSet.IsEmpty);

  if not Result.HasRecord then
    Exit;

  for i := 0 to ADataSet.FieldCount - 1 do
  begin
    fv := TAIFieldExtractor.Extract(ADataSet.Fields[i], FFormMinLevel, ARecord,
      FPolicy, FClassifier, emit);
    if emit then
      Result.AddField(fv);
  end;
end;

function TAIContextBuilder.BuildComponentContext(const AComp: IzBaseComponent;
  const AIsFocused: Boolean; out AOk: Boolean): TAIComponentContext;
var
  dbComp: IzBaseDbComponent;
  filterable: IzBaseFilterableComponent;
  ds: TDataSet;
  recCtx: TGdprRecordContext;
  i: Integer;
  filterProp: TzToolFilterProps;
  af: TAIActiveFilter;
begin
  AOk := False;
  Result := Default(TAIComponentContext);
  Result.RowCount := -1; // non pertinente finche' non valorizzato

  if not Supports(AComp, IzBaseDbComponent, dbComp) then
    Exit; // senza dataset non c'e' contesto dinamico

  Result.Kind := AComp.ComponentType;
  Result.Title := AComp.ConfigTitle;
  Result.IsFocused := AIsFocused;

  ds := dbComp.zDataSet; // TzFbDataSet e' un TDataSet
  // Il contesto-record (minore, tipo soggetto) lo determina il resolver di
  // dominio iniettato. Se assente, contesto vuoto (nessuna escalation).
  if Assigned(FRecordResolver) then
    recCtx := FRecordResolver(ds)
  else
    recCtx := TGdprRecordContext.Empty;

  // Righe: con FetchOptions.Mode = fmOnDemand, RecordCount riflette i record
  // GIA' MATERIALIZZATI localmente, non il totale lato server: lettura NON
  // onerosa. Si evita deliberatamente RecordCountFromServer (costoso). Il valore
  // e' quindi un "conteggio parziale" (righe caricate finora), sufficiente per
  // orientare l'assistente; non un totale assoluto.
  if Assigned(ds) and ds.Active then
    Result.RowCount := ds.RecordCount;

  // Record corrente: per la card e' il contenuto; per view/pivot e' la riga su
  // cui l'utente e' posizionato. In tutti i casi e' il record corrente del ds.
  Result.CurrentRecord := ExtractCurrentRecord(ds, recCtx);

  // Filtri attivi: solo i componenti filtrabili (view, pivot).
  if Supports(AComp, IzBaseFilterableComponent, filterable)
     and Assigned(filterable.ToolFilters) then
    for i := 0 to filterable.ToolFilters.Count - 1 do
    begin
      filterProp := filterable.ToolFilters.Items[i];
      af.Name := filterProp.Name;
      af.CurrentValue := filterProp.Description; // riga riassuntiva dello stato
      Result.AddFilter(af);
    end;

  AOk := True;
end;

end.
