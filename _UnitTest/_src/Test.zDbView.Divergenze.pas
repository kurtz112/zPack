// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDbView.Divergenze;

// Test DUnitX di zDbView.Sort, zDbView.Storage e zDbView.Filter oltre a quelli
// gia' presenti (Test.zDbView.Sort, .Storage, .Filter): requisiti ZDBVIEW-ORD,
// ZDBVIEW-LAY, ZDBVIEW-FLT e caratterizzazione delle divergenze DIV-ORD-*,
// DIV-LAY-* e DIV-FLT-* (voce R-210).
//
// Le prove delle divergenze affermano il comportamento DEDOTTO dalla lettura
// del codice: se passano, la divergenza e' confermata; se falliscono, il
// messaggio riporta il valore vero e la specifica va corretta. Quando una
// divergenza verra' corretta nel codice la prova va capovolta e spostata fra
// i requisiti.

interface

uses
  System.SysUtils,
  System.IniFiles,
  System.Variants,
  DUnitX.TestFramework,
  cxFilter,
  zDbView.Sort,
  zDbView.Storage,
  zDbView.Filter;

type
  [TestFixture]
  TTestOrdinamentoDivergenze = class
  public
    // DIV-ORD-1
    [Test]
    procedure DIV_ORD_1_VirgolaDentroLeParentesi_EspressioneSpezzata;
    // DIV-ORD-2
    [Test]
    procedure DIV_ORD_2_AscEsplicito_RestaNellEspressione;
    [Test]
    procedure DIV_ORD_2_NullsLast_DirezioneNonRiconosciuta;
    // DIV-ORD-3
    [Test]
    procedure DIV_ORD_3_TabulazioneAlPostoDelloSpazio_NonDiscendente;
    // ZDBVIEW-ORD-002 (la prima ipotesi, virgolette tolte, era sbagliata)
    [Test]
    procedure NomeFraVirgolette_VirgoletteConservate;
  end;

  [TestFixture]
  TTestLayoutCasiLimite = class
  private
    FIni: TMemIniFile;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZDBVIEW-LAY-003
    [Test]
    procedure LarghezzaMancante_RestaQuellaAttuale;
    [Test]
    procedure IndiceZero_ColonnaVisibile;
    // DIV-LAY-1
    [Test]
    procedure DIV_LAY_1_IndiceNegativoDiversoDaMenoUno_Visibile;
    // DIV-LAY-2
    [Test]
    procedure DIV_LAY_2_LarghezzaZeroONegativa_NonCorretta;
  end;

  [TestFixture]
  TTestFiltroCasiLimite = class
  public
    // ZDBVIEW-FLT-002
    [Test]
    procedure AsteriscoIniziale_NonInterpretato;
    [Test]
    procedure OperatoreInIngresso_SempreSovrascritto;
    // ZDBVIEW-FLT-004
    [Test]
    procedure FiltroPerValore_SenzaCampo_Annullato;
  end;

implementation

{ TTestOrdinamentoDivergenze }

procedure TTestOrdinamentoDivergenze.DIV_ORD_1_VirgolaDentroLeParentesi_EspressioneSpezzata;
var
  Voci: TzSortItems;
begin
  Voci := TzDbViewSortController.ParseOrderBy('COALESCE(A, B) DESC');

  Assert.AreEqual(2, Length(Voci));
  Assert.AreEqual('COALESCE(A', Voci[0].Espressione);
  Assert.AreEqual('B)', Voci[1].Espressione);
  Assert.IsTrue(Voci[1].Discendente);
end;

procedure TTestOrdinamentoDivergenze.DIV_ORD_2_AscEsplicito_RestaNellEspressione;
var
  Voci: TzSortItems;
begin
  Voci := TzDbViewSortController.ParseOrderBy('NOME ASC');

  Assert.AreEqual(1, Length(Voci));
  Assert.AreEqual('NOME ASC', Voci[0].Espressione);
  Assert.IsFalse(Voci[0].Discendente);
end;

procedure TTestOrdinamentoDivergenze.DIV_ORD_2_NullsLast_DirezioneNonRiconosciuta;
var
  Voci: TzSortItems;
begin
  Voci := TzDbViewSortController.ParseOrderBy('DATA_DOC DESC NULLS LAST');

  Assert.AreEqual(1, Length(Voci));
  Assert.AreEqual('DATA_DOC DESC NULLS LAST', Voci[0].Espressione);
  Assert.IsFalse(Voci[0].Discendente);
end;

procedure TTestOrdinamentoDivergenze.DIV_ORD_3_TabulazioneAlPostoDelloSpazio_NonDiscendente;
var
  Voci: TzSortItems;
begin
  Voci := TzDbViewSortController.ParseOrderBy('DATA_DOC' + #9 + 'DESC');

  Assert.AreEqual(1, Length(Voci));
  Assert.IsFalse(Voci[0].Discendente);
end;

procedure TTestOrdinamentoDivergenze.NomeFraVirgolette_VirgoletteConservate;
var
  Voci: TzSortItems;
begin
  Voci := TzDbViewSortController.ParseOrderBy('COGNOME, "NOME ANNO" DESC');

  Assert.AreEqual(2, Length(Voci));
  Assert.AreEqual('"NOME ANNO"', Voci[1].Espressione);
  Assert.IsTrue(Voci[1].Discendente);
end;

{ TTestLayoutCasiLimite }

procedure TTestLayoutCasiLimite.Setup;
begin
  FIni := TMemIniFile.Create('');
end;

procedure TTestLayoutCasiLimite.TearDown;
begin
  FreeAndNil(FIni);
end;

procedure TTestLayoutCasiLimite.LarghezzaMancante_RestaQuellaAttuale;
var
  Attuale, Letto: TzColumnLayout;
begin
  FIni.WriteInteger('V', 'COGNOME', 2);
  SetLength(Attuale, 1);
  Attuale[0].FieldName := 'COGNOME';
  Attuale[0].Width := 135;
  Attuale[0].Visible := false;

  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, 'V', Attuale);

  Assert.IsTrue(Letto[0].Found);
  Assert.IsTrue(Letto[0].Visible);
  Assert.AreEqual(2, Letto[0].Index);
  Assert.AreEqual(135, Letto[0].Width);
end;

procedure TTestLayoutCasiLimite.IndiceZero_ColonnaVisibile;
var
  Attuale, Letto: TzColumnLayout;
begin
  FIni.WriteInteger('V', 'COGNOME', 0);
  SetLength(Attuale, 1);
  Attuale[0].FieldName := 'COGNOME';
  Attuale[0].Width := 80;

  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, 'V', Attuale);

  Assert.IsTrue(Letto[0].Visible);
  Assert.AreEqual(0, Letto[0].Index);
end;

procedure TTestLayoutCasiLimite.DIV_LAY_1_IndiceNegativoDiversoDaMenoUno_Visibile;
var
  Attuale, Letto: TzColumnLayout;
begin
  FIni.WriteInteger('V', 'COGNOME', -5);
  SetLength(Attuale, 1);
  Attuale[0].FieldName := 'COGNOME';
  Attuale[0].Width := 80;

  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, 'V', Attuale);

  Assert.IsTrue(Letto[0].Visible);
  Assert.AreEqual(-5, Letto[0].Index);
end;

procedure TTestLayoutCasiLimite.DIV_LAY_2_LarghezzaZeroONegativa_NonCorretta;
var
  Attuale, Letto: TzColumnLayout;
begin
  FIni.WriteInteger('V', 'COGNOME', 0);
  FIni.WriteInteger('V', 'COGNOME_Width', -30);
  SetLength(Attuale, 1);
  Attuale[0].FieldName := 'COGNOME';
  Attuale[0].Width := 80;

  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, 'V', Attuale);

  Assert.AreEqual(-30, Letto[0].Width);
end;

{ TTestFiltroCasiLimite }

procedure TTestFiltroCasiLimite.AsteriscoIniziale_NonInterpretato;
var
  s: string;
  Operatore: TcxFilterOperatorKind;
begin
  s := '*rossi';
  TzDbViewFilterController.ParseStringFilterValue(s, Operatore);

  Assert.AreEqual(foBeginsWith, Operatore);
  Assert.AreEqual('*rossi', s);
end;

procedure TTestFiltroCasiLimite.OperatoreInIngresso_SempreSovrascritto;
var
  s: string;
  Operatore: TcxFilterOperatorKind;
begin
  s := 'rossi';
  Operatore := foEqual;
  TzDbViewFilterController.ParseStringFilterValue(s, Operatore);

  Assert.AreEqual(foBeginsWith, Operatore);
end;

procedure TTestFiltroCasiLimite.FiltroPerValore_SenzaCampo_Annullato;
var
  Valore: Variant;
  Operatore: TcxFilterOperatorKind;
begin
  Valore := 'x';
  Operatore := foLike;

  Assert.IsFalse(TzDbViewFilterController.ChiediFiltroPerValore(nil, 'T.C', 'Campo', Null, Valore, Operatore));
  Assert.IsTrue(VarIsNull(Valore));
  Assert.AreEqual(foEqual, Operatore);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestOrdinamentoDivergenze);
  TDUnitX.RegisterTestFixture(TTestLayoutCasiLimite);
  TDUnitX.RegisterTestFixture(TTestFiltroCasiLimite);

end.
