unit Test.zDbView.Filter;

// Test DUnitX per ParseStringFilterValue (zDbView.Filter), promossa a
// class function pubblica: interpreta il testo digitato dall'utente nel
// filtro rapido (asterisco finale = ricerca "contiene").
// Il progetto di test linka DevExpress a compile-time (cxFilter per
// TcxFilterOperatorKind) ma non crea alcun controllo a runtime.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  System.Variants,
  cxFilter,
  cxFilterControlUtils,
  zDbView.Filter;

type
  [TestFixture]
  TTestParseStringFilterValue = class
  public
    [Test]
    procedure TestoSemplice_BeginsWith;
    [Test]
    procedure AsteriscoFinale_Contains_ERimosso;
    [Test]
    procedure SoloAsterisco_Contains_StringaVuota;
    [Test]
    procedure AsteriscoInMezzo_NonInterpretato;
    [Test]
    procedure StringaVuota_BeginsWith;
    [Test]
    procedure DoppioAsteriscoFinale_RimossoSoloUltimo;
  end;

  // Mantis #4777 - 2026-11-02: non e' vuoto dal menu usava il valore della riga
  [TestFixture]
  TTestValoreFiltroDaMenu = class
  public
    [Test]
    procedure NonVuoto_Intero_Null;
    [Test]
    procedure Vuoto_Intero_Null;
    [Test]
    procedure NonVuoto_Testo_Null;
    [Test]
    procedure Uguale_ValoreDellaCella;
    [Test]
    procedure Fra_ArrayConIlValore;
    [Test]
    procedure NellElenco_ArrayConIlValore;
  end;

implementation

{ TTestParseStringFilterValue }

procedure TTestParseStringFilterValue.TestoSemplice_BeginsWith;
var
  s: string;
  Kind: TcxFilterOperatorKind;
begin
  s := 'rossi';
  TzDbViewFilterController.ParseStringFilterValue(s, Kind);

  Assert.AreEqual(foBeginsWith, Kind);
  Assert.AreEqual('rossi', s);
end;

procedure TTestParseStringFilterValue.AsteriscoFinale_Contains_ERimosso;
var
  s: string;
  Kind: TcxFilterOperatorKind;
begin
  s := 'rossi*';
  TzDbViewFilterController.ParseStringFilterValue(s, Kind);

  Assert.AreEqual(foContains, Kind);
  Assert.AreEqual('rossi', s);
end;

procedure TTestParseStringFilterValue.SoloAsterisco_Contains_StringaVuota;
var
  s: string;
  Kind: TcxFilterOperatorKind;
begin
  s := '*';
  TzDbViewFilterController.ParseStringFilterValue(s, Kind);

  Assert.AreEqual(foContains, Kind);
  Assert.AreEqual('', s);
end;

procedure TTestParseStringFilterValue.AsteriscoInMezzo_NonInterpretato;
var
  s: string;
  Kind: TcxFilterOperatorKind;
begin
  s := 'ros*si';
  TzDbViewFilterController.ParseStringFilterValue(s, Kind);

  Assert.AreEqual(foBeginsWith, Kind);
  Assert.AreEqual('ros*si', s);
end;

procedure TTestParseStringFilterValue.StringaVuota_BeginsWith;
var
  s: string;
  Kind: TcxFilterOperatorKind;
begin
  s := '';
  TzDbViewFilterController.ParseStringFilterValue(s, Kind);

  Assert.AreEqual(foBeginsWith, Kind);
  Assert.AreEqual('', s);
end;

procedure TTestParseStringFilterValue.DoppioAsteriscoFinale_RimossoSoloUltimo;
var
  s: string;
  Kind: TcxFilterOperatorKind;
begin
  // Comportamento attuale fotografato: viene consumato un solo asterisco
  s := 'rossi**';
  TzDbViewFilterController.ParseStringFilterValue(s, Kind);

  Assert.AreEqual(foContains, Kind);
  Assert.AreEqual('rossi*', s);
end;

{ TTestValoreFiltroDaMenu }

procedure TTestValoreFiltroDaMenu.NonVuoto_Intero_Null;
begin
  Assert.IsTrue(VarIsNull(TzDbViewFilterController.ValoreFiltroDaMenu(fcoNonBlanks, 163)));
end;

procedure TTestValoreFiltroDaMenu.Vuoto_Intero_Null;
begin
  Assert.IsTrue(VarIsNull(TzDbViewFilterController.ValoreFiltroDaMenu(fcoBlanks, 163)));
end;

procedure TTestValoreFiltroDaMenu.NonVuoto_Testo_Null;
begin
  Assert.IsTrue(VarIsNull(TzDbViewFilterController.ValoreFiltroDaMenu(fcoNonBlanks, 'ROSSI')));
end;

procedure TTestValoreFiltroDaMenu.Uguale_ValoreDellaCella;
begin
  Assert.AreEqual(163, Integer(TzDbViewFilterController.ValoreFiltroDaMenu(fcoEqual, 163)));
end;

procedure TTestValoreFiltroDaMenu.Fra_ArrayConIlValore;
var
  Valore: Variant;
begin
  Valore := TzDbViewFilterController.ValoreFiltroDaMenu(fcoBetween, 163);

  Assert.IsTrue(VarIsArray(Valore));
  Assert.AreEqual(163, Integer(Valore[0]));
  Assert.AreEqual(163, Integer(Valore[1]));
end;

procedure TTestValoreFiltroDaMenu.NellElenco_ArrayConIlValore;
var
  Valore: Variant;
begin
  Valore := TzDbViewFilterController.ValoreFiltroDaMenu(fcoInList, 163);

  Assert.IsTrue(VarIsArray(Valore));
  Assert.AreEqual(163, Integer(Valore[0]));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestParseStringFilterValue);
  TDUnitX.RegisterTestFixture(TTestValoreFiltroDaMenu);

end.
