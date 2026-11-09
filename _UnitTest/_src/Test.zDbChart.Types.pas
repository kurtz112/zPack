// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-03
// ---------------------------------------------------------------------------
unit Test.zDbChart.Types;

// Test DUnitX per zDbChart.Types (TzDbChart): tipi del grafico senza
// DevExpress ne' zPack. Riprende e allarga le prove T00a-T00g di
// D:\AI\SandBox\zProvaDbChart.
//
// TTestChartEnumerati protegge i .LZ: gli enumerati sono salvati per nome nel
// dizionario, quindi un valore rinominato o inserito in mezzo rende
// illeggibili i grafici gia' configurati. Se uno di quei test fallisce non va
// aggiornato l'atteso: va rimesso il valore al suo posto.

interface

uses
  System.SysUtils,
  System.Variants,
  System.TypInfo,
  DUnitX.TestFramework,
  zDbChart.Types;

type
  [TestFixture]
  TTestChartEnumerati = class
  public
    [Test]
    procedure TzChartKind_NomiEOrdineInvariati;
    [Test]
    procedure TzChartSort_NomiEOrdineInvariati;
    [Test]
    procedure TzChartFamily_NomiEOrdineInvariati;
  end;

  [TestFixture]
  TTestChartKind = class
  public
    [Test]
    procedure Family_TortaECiambella_Semplice;
    [Test]
    procedure Family_AltriTipi_XY;
    [Test]
    procedure ViewType_UnoPerTipo;
    [Test]
    procedure ViewType_gkChart_Bar;
    [Test]
    procedure Caption_MaiVuota;
    [Test]
    procedure MaxPoints_LineeCentomila_AltriCinquemila;
    [Test]
    procedure Resolve_gkChart_PrendeIlTipoDelGrafico;
    [Test]
    procedure Resolve_gkChartAncheNelGrafico_Barre;
    [Test]
    procedure Resolve_TipoEsplicito_Invariato;
    [Test]
    procedure ForFamily_StessaFamiglia_Invariato;
    [Test]
    procedure ForFamily_VersoSemplice_Torta;
    [Test]
    procedure ForFamily_VersoXY_Barre;
    [Test]
    procedure Name_FromName_RoundTripSuTuttiITipi;
    [Test]
    procedure FromName_MaiuscoleESpazi_Riconosciuto;
    [Test]
    procedure FromName_Sconosciuto_Predefinito;
    [Test]
    procedure FromName_Vuoto_Predefinito;
  end;

  [TestFixture]
  TTestChartSpec = class
  public
    [Test]
    procedure Init_ValoriPredefiniti;
    [Test]
    procedure AddSeries_gkChart_RisoltoInBarre;
    [Test]
    procedure AddSeries_MantieneLOrdine;
    [Test]
    procedure Family_SenzaSerie_XY;
    [Test]
    procedure Family_DecideLaPrimaSerie;
    [Test]
    procedure MaxPoints_SenzaSerie_SogliaDelleLinee;
    [Test]
    procedure MaxPoints_SoloLinee_Centomila;
    [Test]
    procedure MaxPoints_LineeEBarre_VinceLaPiuBassa;
    [Test]
    procedure MaxPoints_LineaInDiagrammaATorta_ConvertitaPrima;
    [Test]
    procedure MaxPoints_Override_Vince;
  end;

  [TestFixture]
  TTestChartPoint = class
  public
    [Test]
    procedure Clear_AzzeraTutto;
    [Test]
    procedure IsRecord_IndiceZero_True;
    [Test]
    procedure IsRecord_FettaAltri_False;
  end;

implementation

{ TTestChartEnumerati }

procedure TTestChartEnumerati.TzChartKind_NomiEOrdineInvariati;
const
  Nomi: array [0 .. 9] of string = ('gkChart', 'gkBar', 'gkStackedBar', 'gkFullStackedBar', 'gkLine', 'gkStackedLine', 'gkArea',
    'gkStackedArea', 'gkPie', 'gkDoughnut');
var
  i: Integer;
begin
  Assert.AreEqual(High(Nomi), Ord(High(TzChartKind)), 'valori aggiunti o tolti: aggiornare solo aggiungendo in coda');

  for i := Low(Nomi) to High(Nomi) do
    Assert.AreEqual(Nomi[i], GetEnumName(TypeInfo(TzChartKind), i));
end;

procedure TTestChartEnumerati.TzChartSort_NomiEOrdineInvariati;
const
  Nomi: array [0 .. 4] of string = ('gsNone', 'gsArgumentAsc', 'gsArgumentDesc', 'gsValueAsc', 'gsValueDesc');
var
  i: Integer;
begin
  Assert.AreEqual(High(Nomi), Ord(High(TzChartSort)));

  for i := Low(Nomi) to High(Nomi) do
    Assert.AreEqual(Nomi[i], GetEnumName(TypeInfo(TzChartSort), i));
end;

procedure TTestChartEnumerati.TzChartFamily_NomiEOrdineInvariati;
begin
  Assert.AreEqual(1, Ord(High(TzChartFamily)));
  Assert.AreEqual('gfXY', GetEnumName(TypeInfo(TzChartFamily), 0));
  Assert.AreEqual('gfSimple', GetEnumName(TypeInfo(TzChartFamily), 1));
end;

{ TTestChartKind }

procedure TTestChartKind.Family_TortaECiambella_Semplice;
begin
  Assert.IsTrue(gkPie.Family = gfSimple);
  Assert.IsTrue(gkDoughnut.Family = gfSimple);
end;

procedure TTestChartKind.Family_AltriTipi_XY;
var
  Tipo: TzChartKind;
begin
  for Tipo := Low(TzChartKind) to High(TzChartKind) do
    if not(Tipo in [gkPie, gkDoughnut]) then
      Assert.IsTrue(Tipo.Family = gfXY, Tipo.Name);
end;

procedure TTestChartKind.ViewType_UnoPerTipo;
begin
  Assert.AreEqual('Bar', gkBar.ViewType);
  Assert.AreEqual('StackedBar', gkStackedBar.ViewType);
  Assert.AreEqual('FullStackedBar', gkFullStackedBar.ViewType);
  Assert.AreEqual('Line', gkLine.ViewType);
  Assert.AreEqual('StackedLine', gkStackedLine.ViewType);
  Assert.AreEqual('Area', gkArea.ViewType);
  Assert.AreEqual('StackedArea', gkStackedArea.ViewType);
  Assert.AreEqual('Pie', gkPie.ViewType);
  Assert.AreEqual('Doughnut', gkDoughnut.ViewType);
end;

procedure TTestChartKind.ViewType_gkChart_Bar;
begin
  // gkChart non arriva mai al motore (AddSeries lo risolve), ma se ci
  // arrivasse deve produrre un tipo valido e non una stringa vuota
  Assert.AreEqual('Bar', gkChart.ViewType);
end;

procedure TTestChartKind.Caption_MaiVuota;
var
  Tipo: TzChartKind;
begin
  for Tipo := Low(TzChartKind) to High(TzChartKind) do
    Assert.IsFalse(Tipo.Caption.IsEmpty, Tipo.Name);
end;

procedure TTestChartKind.MaxPoints_LineeCentomila_AltriCinquemila;
var
  Tipo: TzChartKind;
begin
  for Tipo := Low(TzChartKind) to High(TzChartKind) do
    if Tipo in [gkLine, gkStackedLine] then
      Assert.AreEqual(100000, Tipo.MaxPoints, Tipo.Name)
    else
      Assert.AreEqual(5000, Tipo.MaxPoints, Tipo.Name);
end;

procedure TTestChartKind.Resolve_gkChart_PrendeIlTipoDelGrafico;
begin
  Assert.IsTrue(gkChart.Resolve(gkLine) = gkLine);
end;

procedure TTestChartKind.Resolve_gkChartAncheNelGrafico_Barre;
begin
  Assert.IsTrue(gkChart.Resolve(gkChart) = gkBar);
end;

procedure TTestChartKind.Resolve_TipoEsplicito_Invariato;
begin
  Assert.IsTrue(gkArea.Resolve(gkLine) = gkArea);
end;

procedure TTestChartKind.ForFamily_StessaFamiglia_Invariato;
begin
  Assert.IsTrue(gkLine.ForFamily(gfXY) = gkLine);
  Assert.IsTrue(gkDoughnut.ForFamily(gfSimple) = gkDoughnut);
end;

procedure TTestChartKind.ForFamily_VersoSemplice_Torta;
begin
  // un tipo XY in un diagramma a torta chiuderebbe l'applicazione (fase 0, P14)
  Assert.IsTrue(gkLine.ForFamily(gfSimple) = gkPie);
  Assert.IsTrue(gkStackedBar.ForFamily(gfSimple) = gkPie);
end;

procedure TTestChartKind.ForFamily_VersoXY_Barre;
begin
  Assert.IsTrue(gkPie.ForFamily(gfXY) = gkBar);
  Assert.IsTrue(gkDoughnut.ForFamily(gfXY) = gkBar);
end;

procedure TTestChartKind.Name_FromName_RoundTripSuTuttiITipi;
var
  Tipo: TzChartKind;
begin
  for Tipo := Low(TzChartKind) to High(TzChartKind) do
    Assert.IsTrue(TzChartKind.FromName(Tipo.Name, gkBar) = Tipo, Tipo.Name);
end;

procedure TTestChartKind.FromName_MaiuscoleESpazi_Riconosciuto;
begin
  Assert.IsTrue(TzChartKind.FromName('  GKSTACKEDAREA ', gkBar) = gkStackedArea);
end;

procedure TTestChartKind.FromName_Sconosciuto_Predefinito;
begin
  Assert.IsTrue(TzChartKind.FromName('gkRadar', gkLine) = gkLine);
end;

procedure TTestChartKind.FromName_Vuoto_Predefinito;
begin
  Assert.IsTrue(TzChartKind.FromName('', gkArea) = gkArea);
  Assert.IsTrue(TzChartKind.FromName('   ', gkArea) = gkArea);
end;

{ TTestChartSpec }

procedure TTestChartSpec.Init_ValoriPredefiniti;
var
  Spec: TzChartSpec;
begin
  Spec.Init;

  Assert.AreEqual(0, Length(Spec.Series));
  Assert.IsTrue(Spec.Sort = gsNone);
  Assert.AreEqual(0, Spec.TopN);
  Assert.IsTrue(Spec.TopNOthers);
  Assert.IsTrue(Spec.ShowLegend);
  Assert.IsFalse(Spec.ShowLabels);
  Assert.IsTrue(Spec.Crosshair);
  Assert.IsTrue(Spec.AllowZoom);
  Assert.IsTrue(Spec.Markers);
  Assert.AreEqual('', Spec.Title);
  Assert.AreEqual('', Spec.ArgumentField);
end;

procedure TTestChartSpec.AddSeries_gkChart_RisoltoInBarre;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Spec.AddSeries('IMPORTO', 'Importo', gkChart);

  Assert.AreEqual(1, Length(Spec.Series));
  Assert.IsTrue(Spec.Series[0].Kind = gkBar, 'una serie non deve mai restare gkChart');
end;

procedure TTestChartSpec.AddSeries_MantieneLOrdine;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Spec.AddSeries('A', 'Prima', gkLine);
  Spec.AddSeries('B', 'Seconda', gkArea);

  Assert.AreEqual(2, Length(Spec.Series));
  Assert.AreEqual('A', Spec.Series[0].FieldName);
  Assert.AreEqual('Prima', Spec.Series[0].Caption);
  Assert.AreEqual('B', Spec.Series[1].FieldName);
  Assert.IsTrue(Spec.Series[1].Kind = gkArea);
end;

procedure TTestChartSpec.Family_SenzaSerie_XY;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Assert.IsTrue(Spec.Family = gfXY);
end;

procedure TTestChartSpec.Family_DecideLaPrimaSerie;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Spec.AddSeries('A', 'A', gkPie);
  Spec.AddSeries('B', 'B', gkLine);

  Assert.IsTrue(Spec.Family = gfSimple);
end;

procedure TTestChartSpec.MaxPoints_SenzaSerie_SogliaDelleLinee;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Assert.AreEqual(100000, Spec.MaxPoints(0));
end;

procedure TTestChartSpec.MaxPoints_SoloLinee_Centomila;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Spec.AddSeries('A', 'A', gkLine);
  Spec.AddSeries('B', 'B', gkStackedLine);

  Assert.AreEqual(100000, Spec.MaxPoints(0));
end;

procedure TTestChartSpec.MaxPoints_LineeEBarre_VinceLaPiuBassa;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Spec.AddSeries('A', 'A', gkLine);
  Spec.AddSeries('B', 'B', gkBar);

  Assert.AreEqual(5000, Spec.MaxPoints(0));
end;

procedure TTestChartSpec.MaxPoints_LineaInDiagrammaATorta_ConvertitaPrima;
var
  Spec: TzChartSpec;
begin
  // la linea in un diagramma a torta diventa torta: vale la soglia della torta
  Spec.Init;
  Spec.AddSeries('A', 'A', gkPie);
  Spec.AddSeries('B', 'B', gkLine);

  Assert.AreEqual(5000, Spec.MaxPoints(0));
end;

procedure TTestChartSpec.MaxPoints_Override_Vince;
var
  Spec: TzChartSpec;
begin
  Spec.Init;
  Spec.AddSeries('A', 'A', gkLine);

  Assert.AreEqual(250, Spec.MaxPoints(250));
  Assert.AreEqual(100000, Spec.MaxPoints(-1), 'un valore negativo vale come non impostato');
end;

{ TTestChartPoint }

procedure TTestChartPoint.Clear_AzzeraTutto;
var
  Punto: TzChartPoint;
begin
  Punto.SeriesCaption := 'x';
  Punto.FieldName := 'x';
  Punto.Argument := 1;
  Punto.ArgumentText := 'x';
  Punto.Value := 2;
  Punto.RecordIndex := 5;

  Punto.Clear;

  Assert.AreEqual('', Punto.SeriesCaption);
  Assert.AreEqual('', Punto.FieldName);
  Assert.AreEqual('', Punto.ArgumentText);
  Assert.IsTrue(VarIsNull(Punto.Argument));
  Assert.IsTrue(VarIsNull(Punto.Value));
  Assert.AreEqual(-1, Punto.RecordIndex);
  Assert.IsFalse(Punto.IsRecord);
end;

procedure TTestChartPoint.IsRecord_IndiceZero_True;
var
  Punto: TzChartPoint;
begin
  Punto.Clear;
  Punto.RecordIndex := 0;
  Assert.IsTrue(Punto.IsRecord);
end;

procedure TTestChartPoint.IsRecord_FettaAltri_False;
var
  Punto: TzChartPoint;
begin
  // la fetta "Altri" delle prime N non corrisponde a un record
  Punto.Clear;
  Punto.RecordIndex := -1;
  Assert.IsFalse(Punto.IsRecord);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestChartEnumerati);
  TDUnitX.RegisterTestFixture(TTestChartKind);
  TDUnitX.RegisterTestFixture(TTestChartSpec);
  TDUnitX.RegisterTestFixture(TTestChartPoint);

end.
