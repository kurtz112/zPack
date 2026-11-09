unit Test.zDbView.Sort;

// Test DUnitX per la logica ORDER BY estratta in zDbView.Sort:
// BuildOrderBy/ParseOrderBy sono class function pure, testabili senza grid.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  zDbView.Sort;

type
  [TestFixture]
  TTestBuildOrderBy = class
  public
    [Test]
    procedure ListaVuota_StringaVuota;
    [Test]
    procedure SingoloCampoAscendente;
    [Test]
    procedure SingoloCampoDiscendente;
    [Test]
    procedure PiuCampi_SeparatiDaVirgola;
    [Test]
    procedure EspressioneVuota_Saltata;
  end;

  [TestFixture]
  TTestParseOrderBy = class
  public
    [Test]
    procedure StringaVuota_NessunItem;
    [Test]
    procedure SingoloCampo;
    [Test]
    procedure CampoDiscendente;
    [Test]
    procedure PiuCampiMisti;
    [Test]
    procedure DescMinuscolo_Riconosciuto;
    [Test]
    procedure CampoCheContieneDesc_NonEDiscendente;
    [Test]
    procedure ElementiVuoti_Saltati;
    [Test]
    procedure RoundTrip_BuildParse;
  end;

implementation

{ TTestBuildOrderBy }

procedure TTestBuildOrderBy.ListaVuota_StringaVuota;
begin
  Assert.AreEqual('', TzDbViewSortController.BuildOrderBy(nil));
end;

procedure TTestBuildOrderBy.SingoloCampoAscendente;
var
  Items: TzSortItems;
begin
  SetLength(Items, 1);
  Items[0].Espressione := 'COGNOME';
  Items[0].Discendente := false;

  Assert.AreEqual('COGNOME', TzDbViewSortController.BuildOrderBy(Items));
end;

procedure TTestBuildOrderBy.SingoloCampoDiscendente;
var
  Items: TzSortItems;
begin
  SetLength(Items, 1);
  Items[0].Espressione := 'DATA_DOC';
  Items[0].Discendente := true;

  Assert.AreEqual('DATA_DOC DESC', TzDbViewSortController.BuildOrderBy(Items));
end;

procedure TTestBuildOrderBy.PiuCampi_SeparatiDaVirgola;
var
  Items: TzSortItems;
begin
  SetLength(Items, 3);
  Items[0].Espressione := 'COGNOME';
  Items[0].Discendente := false;
  Items[1].Espressione := 'NOME';
  Items[1].Discendente := false;
  Items[2].Espressione := '3';
  Items[2].Discendente := true;

  Assert.AreEqual('COGNOME, NOME, 3 DESC', TzDbViewSortController.BuildOrderBy(Items));
end;

procedure TTestBuildOrderBy.EspressioneVuota_Saltata;
var
  Items: TzSortItems;
begin
  // Un item senza espressione non deve produrre virgole orfane
  SetLength(Items, 3);
  Items[0].Espressione := 'A';
  Items[0].Discendente := false;
  Items[1].Espressione := '';
  Items[1].Discendente := true;
  Items[2].Espressione := 'B';
  Items[2].Discendente := false;

  Assert.AreEqual('A, B', TzDbViewSortController.BuildOrderBy(Items));
end;

{ TTestParseOrderBy }

procedure TTestParseOrderBy.StringaVuota_NessunItem;
begin
  Assert.AreEqual(0, Length(TzDbViewSortController.ParseOrderBy('')));
end;

procedure TTestParseOrderBy.SingoloCampo;
var
  Items: TzSortItems;
begin
  Items := TzDbViewSortController.ParseOrderBy('COGNOME');

  Assert.AreEqual(1, Length(Items));
  Assert.AreEqual('COGNOME', Items[0].Espressione);
  Assert.IsFalse(Items[0].Discendente);
end;

procedure TTestParseOrderBy.CampoDiscendente;
var
  Items: TzSortItems;
begin
  Items := TzDbViewSortController.ParseOrderBy('DATA_DOC DESC');

  Assert.AreEqual(1, Length(Items));
  Assert.AreEqual('DATA_DOC', Items[0].Espressione);
  Assert.IsTrue(Items[0].Discendente);
end;

procedure TTestParseOrderBy.PiuCampiMisti;
var
  Items: TzSortItems;
begin
  Items := TzDbViewSortController.ParseOrderBy('COGNOME, NOME, 3 DESC');

  Assert.AreEqual(3, Length(Items));
  Assert.AreEqual('COGNOME', Items[0].Espressione);
  Assert.IsFalse(Items[0].Discendente);
  Assert.AreEqual('NOME', Items[1].Espressione);
  Assert.IsFalse(Items[1].Discendente);
  Assert.AreEqual('3', Items[2].Espressione);
  Assert.IsTrue(Items[2].Discendente);
end;

procedure TTestParseOrderBy.DescMinuscolo_Riconosciuto;
var
  Items: TzSortItems;
begin
  Items := TzDbViewSortController.ParseOrderBy('campo desc');

  Assert.AreEqual(1, Length(Items));
  Assert.AreEqual('campo', Items[0].Espressione);
  Assert.IsTrue(Items[0].Discendente);
end;

procedure TTestParseOrderBy.CampoCheContieneDesc_NonEDiscendente;
var
  Items: TzSortItems;
begin
  // Il vecchio ContainsStr(' DESC') avrebbe mutilato espressioni che
  // contengono la sequenza al proprio interno: ora conta solo il suffisso.
  Items := TzDbViewSortController.ParseOrderBy('DESCRIZIONE');

  Assert.AreEqual(1, Length(Items));
  Assert.AreEqual('DESCRIZIONE', Items[0].Espressione);
  Assert.IsFalse(Items[0].Discendente);
end;

procedure TTestParseOrderBy.ElementiVuoti_Saltati;
var
  Items: TzSortItems;
begin
  Items := TzDbViewSortController.ParseOrderBy('A, , B');

  Assert.AreEqual(2, Length(Items));
  Assert.AreEqual('A', Items[0].Espressione);
  Assert.AreEqual('B', Items[1].Espressione);
end;

procedure TTestParseOrderBy.RoundTrip_BuildParse;
const
  OrderBy = 'COGNOME, NOME DESC, 3';
begin
  // Parse -> Build deve restituire la stringa canonica identica
  Assert.AreEqual(OrderBy,
    TzDbViewSortController.BuildOrderBy(TzDbViewSortController.ParseOrderBy(OrderBy)));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestBuildOrderBy);
  TDUnitX.RegisterTestFixture(TTestParseOrderBy);

end.
