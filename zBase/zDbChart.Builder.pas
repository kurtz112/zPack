// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-20
// ---------------------------------------------------------------------------
unit zDbChart.Builder;

// Motore di TzDbChart: traduce una descrizione del grafico (TzChartSpec) in
// diagramma e serie di un TdxChartControl, e ne ricava immagini, stampa e
// punto colpito. Dipende solo da DevExpress e da zOffice.Grafici, non da
// zSystem: si collauda da solo (D:\AI\SandBox\zProvaDbChart).
//
// Scelte che vengono dalle prove della fase 0 (Fase 0 - 20261001 - Prove TzDbChart.md):
// - un tipo di serie incompatibile con il diagramma chiude l'applicazione con
//   una violazione di accesso (P14): la famiglia del diagramma la decide la
//   prima serie, le altre vengono portate a un tipo della stessa famiglia, e il
//   cambio di tipo ricostruisce il diagramma invece di cambiare ViewType al volo;
// - dopo un'esportazione a una misura diversa da quella a video il colpo sul
//   punto usa la disposizione dell'esportazione e sulla torta va in violazione
//   di accesso (P07b): il controllo si ridisegna dopo ogni esportazione e
//   prima di ogni colpo;
// - la stampa produce un'immagine raster grande: il PDF si scrive sempre
//   compresso (24 MB contro 148 KB) e la pagina e' orizzontale (P09);
// - le prime N con "Altri" sono native solo su torta e ciambella e vanno
//   sempre accoppiate all'ordinamento per valore decrescente (P15).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  Vcl.Graphics,
  dxCore,
  cxCustomData,
  dxChartCore,
  dxChartControl,
  dxChartData,
  dxChartDBData,
  dxChartXYDiagram,
  dxChartSimpleDiagram,
  dxChartXYSeriesBarView,
  dxChartXYSeriesLineView,
  dxChartXYSeriesAreaView,
  dxPSCore,
  zDbChart.Types,
  zOffice.Grafici;

type
  TzChartBuilder = class
  private
    FChart: TdxChartControl;
    FSpec: TzChartSpec;
    FDataSource: TDataSource;
    FMessage: string;
    // un'esportazione ha lasciato la disposizione dell'immagine: va ridisegnato
    // prima del prossimo colpo
    FRedrawNeeded: Boolean;
    FTitleOnScreen: Boolean;
    // uscite in corso (un PDF passa da ExportToFile a ExportToPdf): finche' e'
    // maggiore di zero il titolo sta nel grafico anche se a video non ci sta
    FExportDepth: Integer;
    procedure BeforeExport;
    procedure AfterExport;
    procedure SetTitleOnScreen(const Value: Boolean);
    function CreateReportLink(Printer: TdxComponentPrinter): TBasedxReportLink;
    procedure ApplyTitles;
    procedure ApplySeriesOptions(Serie: TdxChartCustomSeries);
  public
    constructor Create(Chart: TdxChartControl);

    // Ricrea diagramma e serie. DataSource puo' essere nil: grafico vuoto, ma
    // con assi e legenda gia' pronti
    procedure Build(const Spec: TzChartSpec; DataSource: TDataSource);
    procedure Rebuild;

    // Senza ricostruire
    procedure SetTitle(const Title: string);
    // Riga d'avviso sotto il titolo (es. troppi punti); '' la toglie
    procedure SetMessage(const Text: string);
    procedure SetLegendVisible(const Value: Boolean);
    procedure SetLabelsVisible(const Value: Boolean);
    // segni sui punti delle linee: il frame li accende solo con pochi punti
    procedure SetMarkersVisible(const Value: Boolean);
    procedure ResetZoom;

    function Family: TzChartFamily;
    function PointCount: Integer;
    function HitTest(const X, Y: Integer; out Point: TzChartPoint): Boolean;

    // Immagini: Width e Height 0 = misura a video
    procedure ExportImage(Stream: TStream; const Format: TzFormatoGrafico; const Width, Height: Integer);
    function ImageStream(const Format: TzFormatoGrafico; const Width, Height: Integer): TStream;
    // Formato dall'estensione: png, svg, emf, jpg, bmp, xlsx, docx, pdf
    procedure ExportToFile(const FileName: string; const Width: Integer = 0; const Height: Integer = 0);
    procedure CopyToClipboard;

    // Stampa: InitPrinter permette al frame di applicare dx.InitPrinter senza
    // che questa unit dipenda da zPack
    procedure Preview(const InitPrinter: TProc<TdxComponentPrinter>);
    procedure ExportToPdf(const FileName: string; const InitPrinter: TProc<TdxComponentPrinter>);

    property Chart: TdxChartControl read FChart;
    property Spec: TzChartSpec read FSpec;
    property DataSource: TDataSource read FDataSource;
    // False = il titolo non si disegna a video (lo mostra chi ospita il
    // grafico, es. nella barra) ma resta in immagini e stampe
    property TitleOnScreen: Boolean read FTitleOnScreen write SetTitleOnScreen;
  end;

implementation

uses
  Vcl.Clipbrd,
  dxCoreClasses,
  dxPrnDev,
  dxPSGlbl,
  dxPSGraphicLnk,
  dxPSdxChartControlLnk;

type
  // SortBy, SortOrder sono protette nella serie base e pubblicate nelle derivate
  TSerieAccesso = class(TdxChartCustomSeries);
  // Stretch, Proportional, Center sono protette (fase 0, P09)
  TCollegamentoGraficoAccesso = class(TCustomdxGraphicReportLink);

{ TzChartBuilder }

constructor TzChartBuilder.Create(Chart: TdxChartControl);
begin
  inherited Create;
  FChart := Chart;
  FSpec.Init;
  FDataSource := nil;
  FMessage := '';
  FRedrawNeeded := False;
  FTitleOnScreen := True;
  FExportDepth := 0;
end;

procedure TzChartBuilder.BeforeExport;
begin
  Inc(FExportDepth);

  if (FExportDepth = 1) and not FTitleOnScreen then
    ApplyTitles;
end;

procedure TzChartBuilder.AfterExport;
begin
  if FExportDepth > 0 then
  begin
    Dec(FExportDepth);

    if (FExportDepth = 0) and not FTitleOnScreen then
      ApplyTitles;
  end;

  FRedrawNeeded := True;
  FChart.Invalidate;
end;

procedure TzChartBuilder.SetTitleOnScreen(const Value: Boolean);
begin
  if FTitleOnScreen = Value then
    Exit;

  FTitleOnScreen := Value;
  ApplyTitles;
end;

function TzChartBuilder.Family: TzChartFamily;
begin
  Result := FSpec.Family;
end;

procedure TzChartBuilder.ApplyTitles;
begin
  FChart.Titles.BeginUpdate;
  try
    FChart.Titles.Clear;

    if (FSpec.Title <> '') and (FTitleOnScreen or (FExportDepth > 0)) then
      FChart.Titles.Add.Text := FSpec.Title;

    if FMessage <> '' then
      FChart.Titles.Add.Text := FMessage;
  finally
    FChart.Titles.EndUpdate;
  end;
end;

procedure TzChartBuilder.ApplySeriesOptions(Serie: TdxChartCustomSeries);
var
  Accesso: TSerieAccesso;
begin
  Accesso := TSerieAccesso(Serie);

  case FSpec.Sort of
    gsArgumentAsc:
      begin
        Accesso.SortBy := TdxChartSeriesSortBy.Argument;
        Accesso.SortOrder := TdxSortOrder.soAscending;
      end;
    gsArgumentDesc:
      begin
        Accesso.SortBy := TdxChartSeriesSortBy.Argument;
        Accesso.SortOrder := TdxSortOrder.soDescending;
      end;
    gsValueAsc:
      begin
        Accesso.SortBy := TdxChartSeriesSortBy.Value;
        Accesso.SortOrder := TdxSortOrder.soAscending;
      end;
    gsValueDesc:
      begin
        Accesso.SortBy := TdxChartSeriesSortBy.Value;
        Accesso.SortOrder := TdxSortOrder.soDescending;
      end;
  else
    Accesso.SortOrder := TdxSortOrder.soNone;
  end;

  // Prime N: native solo su torta e ciambella. Senza l'ordinamento per valore
  // decrescente prenderebbero le prime N nell'ordine della serie (P15)
  if (Serie is TdxChartSimpleSeries) and (FSpec.TopN > 0) then
  begin
    Accesso.SortBy := TdxChartSeriesSortBy.Value;
    Accesso.SortOrder := TdxSortOrder.soDescending;
    TdxChartSimpleSeries(Serie).TopNOptions.Value := FSpec.TopN;
    TdxChartSimpleSeries(Serie).TopNOptions.ShowOthers := FSpec.TopNOthers;
    TdxChartSimpleSeries(Serie).TopNOptions.Enabled := True;
  end;

  if Assigned(Serie.View) then
    Serie.View.ValueLabels.Visible := FSpec.ShowLabels;

  // senza i segni sui punti una linea si colpisce solo come serie, mai sul
  // punto: il doppio clic non saprebbe a quale record portare
  if Serie.View is TdxChartXYSeriesLineView then
    TdxChartXYSeriesLineView(Serie.View).Markers.Visible := FSpec.Markers;
end;

procedure TzChartBuilder.Build(const Spec: TzChartSpec; DataSource: TDataSource);
var
  Diagramma: TdxChartCustomDiagram;
  DiagrammaXY: TdxChartXYDiagram;
  DiagrammaSemplice: TdxChartSimpleDiagram;
  Famiglia: TzChartFamily;
  SerieSpec: TzChartSeriesSpec;
  Serie: TdxChartCustomSeries;
  Legame: TdxChartSeriesDBDataBinding;
  Tipo: TzChartKind;
begin
  FSpec := Spec;
  FDataSource := DataSource;
  Famiglia := FSpec.Family;

  FChart.BeginUpdate;
  try
    // il diagramma si toglie da solo dal grafico quando viene distrutto
    while FChart.DiagramCount > 0 do
      FChart.Diagrams[0].Free;

    ApplyTitles;
    FChart.Legend.Visible := FSpec.ShowLegend;

    if Famiglia = gfXY then
    begin
      DiagrammaXY := FChart.AddDiagram<TdxChartXYDiagram>('');
      DiagrammaXY.Axes.AxisX.Title.Text := FSpec.AxisTitleX;
      DiagrammaXY.Axes.AxisY.Title.Text := FSpec.AxisTitleY;
      DiagrammaXY.ZoomOptions.AxisXZoomingEnabled := FSpec.AllowZoom;
      DiagrammaXY.ZoomOptions.AxisYZoomingEnabled := FSpec.AllowZoom;
      DiagrammaXY.ScrollOptions.AxisXScrollingEnabled := FSpec.AllowZoom;
      DiagrammaXY.ScrollOptions.AxisYScrollingEnabled := FSpec.AllowZoom;
      Diagramma := DiagrammaXY;

      if FSpec.Crosshair then
        FChart.ToolTips.DefaultMode := TdxChartToolTipMode.Crosshair
      else
        FChart.ToolTips.DefaultMode := TdxChartToolTipMode.Simple;
    end
    else
    begin
      DiagrammaSemplice := FChart.AddDiagram<TdxChartSimpleDiagram>('');
      Diagramma := DiagrammaSemplice;
      // il mirino non ha senso su torta e ciambella
      FChart.ToolTips.DefaultMode := TdxChartToolTipMode.Simple;
    end;

    for SerieSpec in FSpec.Series do
    begin
      // tipo della stessa famiglia del diagramma, sempre: vedi l'intestazione
      Tipo := SerieSpec.Kind.Resolve(gkBar).ForFamily(Famiglia);

      if Diagramma is TdxChartXYDiagram then
        Serie := TdxChartXYDiagram(Diagramma).AddSeries(SerieSpec.Caption)
      else
        Serie := TdxChartSimpleDiagram(Diagramma).AddSeries(SerieSpec.Caption);

      Serie.DataBindingType := 'DB';
      Legame := Serie.DataBinding as TdxChartSeriesDBDataBinding;
      Legame.DataSource := DataSource;
      Legame.ArgumentField.FieldName := FSpec.ArgumentField;
      Legame.ValueField.FieldName := SerieSpec.FieldName;
      Serie.ViewType := Tipo.ViewType;

      ApplySeriesOptions(Serie);
    end;
  finally
    FChart.EndUpdate;
  end;
end;

procedure TzChartBuilder.Rebuild;
begin
  Build(FSpec, FDataSource);
end;

procedure TzChartBuilder.SetTitle(const Title: string);
begin
  FSpec.Title := Title;
  ApplyTitles;
end;

procedure TzChartBuilder.SetMessage(const Text: string);
begin
  if FMessage = Text then
    Exit;

  FMessage := Text;
  ApplyTitles;
end;

procedure TzChartBuilder.SetLegendVisible(const Value: Boolean);
begin
  FSpec.ShowLegend := Value;
  FChart.Legend.Visible := Value;
end;

procedure TzChartBuilder.SetLabelsVisible(const Value: Boolean);
var
  IndiceDiagramma, IndiceSerie: Integer;
  Serie: TdxChartCustomSeries;
begin
  FSpec.ShowLabels := Value;

  FChart.BeginUpdate;
  try
    for IndiceDiagramma := 0 to FChart.DiagramCount - 1 do
      for IndiceSerie := 0 to FChart.Diagrams[IndiceDiagramma].SeriesCount - 1 do
      begin
        Serie := FChart.Diagrams[IndiceDiagramma].Series[IndiceSerie];
        if Assigned(Serie.View) then
          Serie.View.ValueLabels.Visible := Value;
      end;
  finally
    FChart.EndUpdate;
  end;
end;

procedure TzChartBuilder.SetMarkersVisible(const Value: Boolean);
var
  IndiceDiagramma, IndiceSerie: Integer;
  Serie: TdxChartCustomSeries;
begin
  if FSpec.Markers = Value then
    Exit;

  FSpec.Markers := Value;

  FChart.BeginUpdate;
  try
    for IndiceDiagramma := 0 to FChart.DiagramCount - 1 do
      for IndiceSerie := 0 to FChart.Diagrams[IndiceDiagramma].SeriesCount - 1 do
      begin
        Serie := FChart.Diagrams[IndiceDiagramma].Series[IndiceSerie];
        if Serie.View is TdxChartXYSeriesLineView then
          TdxChartXYSeriesLineView(Serie.View).Markers.Visible := Value;
      end;
  finally
    FChart.EndUpdate;
  end;
end;

procedure TzChartBuilder.ResetZoom;
var
  Indice: Integer;
begin
  for Indice := 0 to FChart.DiagramCount - 1 do
    if FChart.Diagrams[Indice] is TdxChartXYDiagram then
      TdxChartXYDiagram(FChart.Diagrams[Indice]).ResetZoom;
end;

function TzChartBuilder.PointCount: Integer;
var
  IndiceDiagramma, IndiceSerie: Integer;
begin
  Result := 0;

  for IndiceDiagramma := 0 to FChart.DiagramCount - 1 do
    for IndiceSerie := 0 to FChart.Diagrams[IndiceDiagramma].SeriesCount - 1 do
      Inc(Result, FChart.Diagrams[IndiceDiagramma].Series[IndiceSerie].Points.Count);
end;

function TzChartBuilder.HitTest(const X, Y: Integer; out Point: TzChartPoint): Boolean;
var
  Informazione: TdxChartSeriesPointInfo;
begin
  Result := False;
  Point.Clear;

  // dopo un'esportazione la disposizione e' quella dell'immagine (P07b)
  if FRedrawNeeded then
  begin
    FChart.Invalidate;
    FChart.Update;
    FRedrawNeeded := False;
  end;

  FChart.CalculateHitTest(X, Y);

  // SeriesPoint si legge solo sul punto: sull'etichetta del valore e' andato
  // in violazione di accesso nella prima esecuzione della fase 0
  if FChart.HitTest.HitCode <> TdxChartHitCode.SeriesPoint then
    Exit;

  Informazione := FChart.HitTest.SeriesPoint;

  if not Assigned(Informazione) then
    Exit;

  Point.SeriesCaption := Informazione.Series.Caption;
  Point.Argument := Informazione.Argument;
  Point.Value := Informazione.Value;
  Point.RecordIndex := Informazione.Index;

  // ArgumentDisplayText del punto colpito torna vuoto: si rilegge dalla serie
  if Informazione.Index >= 0 then
    Point.ArgumentText := Informazione.Series.Points.ArgumentDisplayTexts[Informazione.Index]
  else
    Point.ArgumentText := VarToStr(Informazione.Argument);

  if Informazione.Series.DataBinding is TdxChartSeriesDBDataBinding then
    Point.FieldName := TdxChartSeriesDBDataBinding(Informazione.Series.DataBinding).ValueField.FieldName;

  Result := True;
end;

procedure TzChartBuilder.ExportImage(Stream: TStream; const Format: TzFormatoGrafico; const Width, Height: Integer);
begin
  BeforeExport;
  try
    case Format of
      fgSvg:
        FChart.ExportToSVG(Stream, Width, Height);
      fgEmf:
        FChart.ExportToEMF(Stream, Width, Height);
      fgJpeg:
        FChart.ExportToJPEG(Stream, Width, Height);
    else
      FChart.ExportToPNG(Stream, Width, Height);
    end;
  finally
    // vedi l'intestazione: la disposizione a video va ricalcolata
    AfterExport;
  end;
end;

function TzChartBuilder.ImageStream(const Format: TzFormatoGrafico; const Width, Height: Integer): TStream;
begin
  Result := TMemoryStream.Create;
  try
    ExportImage(Result, Format, Width, Height);
    Result.Position := 0;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TzChartBuilder.ExportToFile(const FileName: string; const Width, Height: Integer);
var
  Estensione: string;
begin
  Estensione := LowerCase(ExtractFileExt(FileName));

  BeforeExport;
  try
    if Estensione = '.svg' then
      FChart.ExportToSVG(FileName, Width, Height)
    else
      if Estensione = '.emf' then
        FChart.ExportToEMF(FileName, Width, Height)
      else
        if (Estensione = '.jpg') or (Estensione = '.jpeg') then
          FChart.ExportToJPEG(FileName, Width, Height)
        else
          if Estensione = '.bmp' then
            FChart.ExportToBMP(FileName, Width, Height)
          else
            if Estensione = '.xlsx' then
              FChart.ExportToXLSX(FileName, Width, Height)
            else
              if Estensione = '.docx' then
                FChart.ExportToDOCX(FileName, Width, Height)
              else
                if Estensione = '.pdf' then
                  ExportToPdf(FileName, nil)
                else
                  FChart.ExportToPNG(FileName, Width, Height);
  finally
    AfterExport;
  end;
end;

procedure TzChartBuilder.CopyToClipboard;
var
  Flusso: TMemoryStream;
  Immagine: TBitmap;
begin
  BeforeExport;
  Flusso := TMemoryStream.Create;
  Immagine := TBitmap.Create;
  try
    FChart.ExportToBMP(Flusso, 0, 0);
    Flusso.Position := 0;
    Immagine.LoadFromStream(Flusso);
    Clipboard.Assign(Immagine);
  finally
    Immagine.Free;
    Flusso.Free;
    AfterExport;
  end;
end;

function TzChartBuilder.CreateReportLink(Printer: TdxComponentPrinter): TBasedxReportLink;
begin
  Result := Printer.AddEmptyLinkEx(TdxChartControlReportLink, nil);
  Result.Component := FChart;

  // in verticale il grafico esce su due pagine anche adattato (P09)
  TCollegamentoGraficoAccesso(Result).Stretch := True;
  TCollegamentoGraficoAccesso(Result).Proportional := True;
  TCollegamentoGraficoAccesso(Result).Center := True;
  Result.PrinterPage.Orientation := poLandscape;
end;

procedure TzChartBuilder.Preview(const InitPrinter: TProc<TdxComponentPrinter>);
var
  Stampante: TdxComponentPrinter;
  Collegamento: TBasedxReportLink;
begin
  BeforeExport;
  // stampante creata al momento e liberata subito, come in TzDbTree.Preview
  Stampante := TdxComponentPrinter.Create(nil);
  try
    if Assigned(InitPrinter) then
      InitPrinter(Stampante);

    Collegamento := CreateReportLink(Stampante);
    Stampante.Preview(True, Collegamento);
  finally
    Stampante.Free;
    AfterExport;
  end;
end;

procedure TzChartBuilder.ExportToPdf(const FileName: string; const InitPrinter: TProc<TdxComponentPrinter>);
var
  Stampante: TdxComponentPrinter;
  Collegamento: TBasedxReportLink;
  Opzioni: TdxPSPDFReportExportOptions;
begin
  BeforeExport;
  Stampante := TdxComponentPrinter.Create(nil);
  Opzioni := TdxPSPDFReportExportOptions.Create;
  try
    if Assigned(InitPrinter) then
      InitPrinter(Stampante);

    Collegamento := CreateReportLink(Stampante);
    Collegamento.RebuildReport;

    // senza compressione il PDF di un grafico pesa 24 MB (P09)
    Opzioni.CompressStreams := True;
    Collegamento.ExportToPDF(FileName, False, Opzioni);
  finally
    Opzioni.Free;
    Stampante.Free;
    AfterExport;
  end;
end;

end.
