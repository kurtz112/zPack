// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------
unit zDbChart.Types;

// Tipi del grafico dati TzDbChart, senza dipendenze da DevExpress ne' da zPack:
// li usano il dizionario LZ (zSystem.pas, TzDbChartProps), il motore di disegno
// (zDbChart.Builder) e il frame (zDbChart).
//
// Gli enumerati sono scritti per nome nel dizionario: si aggiunge sempre in
// coda e non si rinomina, altrimenti i .LZ esistenti non si rileggono.

interface

uses
  System.SysUtils,
  System.Variants;

type
  // Tipo di una serie. gkChart vale "come il tipo del grafico" (TzDbChartProps.Kind)
  TzChartKind = (gkChart, gkBar, gkStackedBar, gkFullStackedBar, gkLine, gkStackedLine, gkArea, gkStackedArea, gkPie, gkDoughnut);

  // Famiglia del diagramma. Le serie di famiglie diverse non stanno nello stesso
  // diagramma: un tipo incompatibile manda il controllo in violazione di accesso
  // e chiude l'applicazione (fase 0, P14), quindi il motore lo impedisce prima
  TzChartFamily = (gfXY, gfSimple);

  // Ordine dei punti di ogni serie. Per argomento l'ordine e' alfabetico anche
  // per i mesi scritti in lettere: in quel caso si lascia l'ordine della query
  TzChartSort = (gsNone, gsArgumentAsc, gsArgumentDesc, gsValueAsc, gsValueDesc);

  TzChartKindHelper = record helper for TzChartKind
    function Family: TzChartFamily;
    // nome del tipo di vista per TdxChartCustomSeries.ViewType
    function ViewType: string;
    function Caption: string;
    // Soglia di punti oltre la quale il disegno non e' piu' interattivo
    // (fase 0: barre 10.000 punti 0,34 s, 100.000 3,9 s; linee 100.000 0,25 s)
    function MaxPoints: Integer;
    // gkChart diventa ChartKind; un gkChart anche li' diventa gkBar
    function Resolve(const ChartKind: TzChartKind): TzChartKind;
    // tipo da usare in un diagramma dell'altra famiglia
    function ForFamily(const AFamily: TzChartFamily): TzChartKind;
    function Name: string;
    class function FromName(const Value: string; const Default: TzChartKind): TzChartKind; static;
  end;

  // Una serie da disegnare: un campo valore del dataset
  TzChartSeriesSpec = record
    FieldName: string;
    Caption: string;
    // gia' risolto, mai gkChart
    Kind: TzChartKind;
  end;

  // Che cosa disegnare: il frame lo costruisce dalle proprieta' del dizionario
  // e dalle scelte dell'utente, il motore lo traduce in diagramma e serie
  TzChartSpec = record
    Title: string;
    ArgumentField: string;
    AxisTitleX: string;
    AxisTitleY: string;
    Series: TArray<TzChartSeriesSpec>;
    Sort: TzChartSort;
    // prime N categorie (solo torta e ciambella, dove e' nativo); 0 = tutte
    TopN: Integer;
    TopNOthers: Boolean;
    ShowLegend: Boolean;
    ShowLabels: Boolean;
    Crosshair: Boolean;
    AllowZoom: Boolean;
    // segni sui punti delle linee: servono al doppio clic, pesano con molti punti
    Markers: Boolean;
    procedure Init;
    procedure AddSeries(const FieldName, Caption: string; const Kind: TzChartKind);
    // famiglia del diagramma: quella della prima serie
    function Family: TzChartFamily;
    // soglia di punti: la piu' bassa fra i tipi delle serie, o Override se > 0
    function MaxPoints(const Override: Integer): Integer;
  end;

  // Punto colpito con il mouse
  TzChartPoint = record
    SeriesCaption: string;
    FieldName: string;
    Argument: Variant;
    ArgumentText: string;
    Value: Variant;
    // posizione del record nel dataset (RecNo - 1), anche con l'ordinamento
    // attivo (fase 0, P06); -1 per la fetta "Altri" delle prime N
    RecordIndex: Integer;
    procedure Clear;
    function IsRecord: Boolean;
  end;

  // Handled := True blocca il comportamento predefinito (il dataset si porta
  // sul record del punto)
  TzChartPointEvent = procedure(Sender: TObject; const Point: TzChartPoint; var Handled: Boolean) of object;

implementation

uses
  System.TypInfo;

{ TzChartKindHelper }

function TzChartKindHelper.Family: TzChartFamily;
begin
  if Self in [gkPie, gkDoughnut] then
    Result := gfSimple
  else
    Result := gfXY;
end;

function TzChartKindHelper.ViewType: string;
begin
  case Self of
    gkStackedBar:
      Result := 'StackedBar';
    gkFullStackedBar:
      Result := 'FullStackedBar';
    gkLine:
      Result := 'Line';
    gkStackedLine:
      Result := 'StackedLine';
    gkArea:
      Result := 'Area';
    gkStackedArea:
      Result := 'StackedArea';
    gkPie:
      Result := 'Pie';
    gkDoughnut:
      Result := 'Doughnut';
  else
    Result := 'Bar';
  end;
end;

function TzChartKindHelper.Caption: string;
begin
  case Self of
    gkChart:
      Result := 'Come il grafico';
    gkBar:
      Result := 'Barre';
    gkStackedBar:
      Result := 'Barre impilate';
    gkFullStackedBar:
      Result := 'Barre in percentuale';
    gkLine:
      Result := 'Linee';
    gkStackedLine:
      Result := 'Linee impilate';
    gkArea:
      Result := 'Aree';
    gkStackedArea:
      Result := 'Aree impilate';
    gkPie:
      Result := 'Torta';
    gkDoughnut:
      Result := 'Ciambella';
  else
    Result := '';
  end;
end;

function TzChartKindHelper.MaxPoints: Integer;
begin
  // le linee reggono due ordini di grandezza in piu' delle barre (fase 0, sezione 4)
  if Self in [gkLine, gkStackedLine] then
    Result := 100000
  else
    Result := 5000;
end;

function TzChartKindHelper.Resolve(const ChartKind: TzChartKind): TzChartKind;
begin
  Result := Self;

  if Result = gkChart then
    Result := ChartKind;

  if Result = gkChart then
    Result := gkBar;
end;

function TzChartKindHelper.ForFamily(const AFamily: TzChartFamily): TzChartKind;
begin
  Result := Self;

  if Result.Family = AFamily then
    Exit;

  if AFamily = gfSimple then
    Result := gkPie
  else
    Result := gkBar;
end;

function TzChartKindHelper.Name: string;
begin
  Result := GetEnumName(TypeInfo(TzChartKind), Ord(Self));
end;

class function TzChartKindHelper.FromName(const Value: string; const Default: TzChartKind): TzChartKind;
var
  Ordinale: Integer;
begin
  Result := Default;

  if Value.Trim = '' then
    Exit;

  Ordinale := GetEnumValue(TypeInfo(TzChartKind), Value.Trim);

  if (Ordinale >= Ord(Low(TzChartKind))) and (Ordinale <= Ord(High(TzChartKind))) then
    Result := TzChartKind(Ordinale);
end;

{ TzChartSpec }

procedure TzChartSpec.Init;
begin
  Title := '';
  ArgumentField := '';
  AxisTitleX := '';
  AxisTitleY := '';
  Series := nil;
  Sort := gsNone;
  TopN := 0;
  TopNOthers := True;
  ShowLegend := True;
  ShowLabels := False;
  Crosshair := True;
  AllowZoom := True;
  Markers := True;
end;

procedure TzChartSpec.AddSeries(const FieldName, Caption: string; const Kind: TzChartKind);
var
  Serie: TzChartSeriesSpec;
begin
  Serie.FieldName := FieldName;
  Serie.Caption := Caption;
  Serie.Kind := Kind.Resolve(gkBar);
  Series := Series + [Serie];
end;

function TzChartSpec.Family: TzChartFamily;
begin
  if Length(Series) = 0 then
    Result := gfXY
  else
    Result := Series[0].Kind.Family;
end;

function TzChartSpec.MaxPoints(const Override: Integer): Integer;
var
  Serie: TzChartSeriesSpec;
  Soglia: Integer;
begin
  if Override > 0 then
    Exit(Override);

  Result := gkLine.MaxPoints;

  for Serie in Series do
  begin
    // nel diagramma della prima serie i tipi dell'altra famiglia sono gia' convertiti
    Soglia := Serie.Kind.ForFamily(Family).MaxPoints;

    if Soglia < Result then
      Result := Soglia;
  end;
end;

{ TzChartPoint }

procedure TzChartPoint.Clear;
begin
  SeriesCaption := '';
  FieldName := '';
  Argument := Null;
  ArgumentText := '';
  Value := Null;
  RecordIndex := -1;
end;

function TzChartPoint.IsRecord: Boolean;
begin
  Result := RecordIndex >= 0;
end;

end.
