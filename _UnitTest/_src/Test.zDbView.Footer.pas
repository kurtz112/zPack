// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDbView.Footer;

// Test DUnitX dei totali di piede (zDbView.Footer.BuildFooterSQL): specifica
// "Totali di piede della vista.md", requisiti ZDBVIEW-TOT e divergenze
// DIV-TOT-1 e DIV-TOT-2 (voce R-210).
//
// BuildFooterSQL e' una class function pura: riceve il testo SQL della vista,
// le colonne (TzColumns) e una funzione che risolve l'origine di ogni colonna,
// quindi si prova senza griglia e senza database.
//
// Le prove delle divergenze affermano il comportamento DEDOTTO dalla lettura
// del codice: se passano, la divergenza e' confermata. Quando verra' corretta
// nel codice la prova va capovolta e spostata fra i requisiti.

interface

uses
  System.SysUtils,
  System.StrUtils,
  DUnitX.TestFramework,
  cxCustomData,
  cxDataUtils,
  zSystem,
  zDbView.Footer;

type
  [TestFixture]
  TTestTotaliDiPiede = class
  private
    FProprieta: TzDbViewProps;
    function Colonna(const Nome: string; Tipo: TcxSummaryKind): TzColumn;
    function Risolvi(const Nome: string): string;
    function Costruisci(const Sql: string): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZDBVIEW-TOT-001
    [Test]
    procedure SqlVuoto_StringaVuota;
    [Test]
    procedure NessunTotale_StringaVuota;
    [Test]
    procedure SelectSemplice_SommaSulOrigine;
    [Test]
    procedure SelectSemplice_ConservaWhereETogliOrderBy;
    // ZDBVIEW-TOT-002
    [Test]
    procedure TipiDiTotale_FunzioniSql;
    // ZDBVIEW-TOT-003
    [Test]
    procedure OrigineVuota_ColonnaSaltata;
    [Test]
    procedure TutteSaltate_StringaVuota;
    [Test]
    procedure PiuColonne_UnaPerRigaSeparateDaVirgola;
  end;

  [TestFixture]
  TTestTotaliDiPiedeDivergenze = class
  private
    FProprieta: TzDbViewProps;
    function Costruisci(const Sql: string): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // DIV-TOT-1
    [Test]
    procedure DIV_TOT_1_ConGroupBy_OrigineFuoriDallaSottoquery;
    // DIV-TOT-2
    [Test]
    procedure DIV_TOT_2_NonSelect_SqlSenzaFrom;
  end;

implementation

function Contiene(const Testo, Pezzo: string): Boolean;
begin
  Result := ContainsText(Testo, Pezzo);
end;

{ TTestTotaliDiPiede }

procedure TTestTotaliDiPiede.Setup;
begin
  FProprieta := TzDbViewProps.Create(nil);
end;

procedure TTestTotaliDiPiede.TearDown;
begin
  FreeAndNil(FProprieta);
end;

function TTestTotaliDiPiede.Colonna(const Nome: string; Tipo: TcxSummaryKind): TzColumn;
begin
  Result := FProprieta.Columns.Get(Nome);
  Result.FooterKind := Tipo;
end;

function TTestTotaliDiPiede.Risolvi(const Nome: string): string;
begin
  // il nome SENZA_ORIGINE simula un campo che il data controller non risolve
  if Nome = 'SENZA_ORIGINE' then
    Result := ''
  else
    Result := 'PAGAMENTI.' + Nome;
end;

function TTestTotaliDiPiede.Costruisci(const Sql: string): string;
begin
  Result := TzDbViewFooterController.BuildFooterSQL(Sql, FProprieta.Columns,
    function(Nome: string): string
    begin
      Result := Risolvi(Nome);
    end);
end;

procedure TTestTotaliDiPiede.SqlVuoto_StringaVuota;
begin
  Colonna('IMPORTO', skSum);
  Assert.AreEqual('', Costruisci(''));
  Assert.AreEqual('', Costruisci('   '));
end;

procedure TTestTotaliDiPiede.NessunTotale_StringaVuota;
begin
  Colonna('IMPORTO', skNone);
  Assert.AreEqual('', Costruisci('SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI'));
end;

procedure TTestTotaliDiPiede.SelectSemplice_SommaSulOrigine;
var
  Sql: string;
begin
  Colonna('IMPORTO', skSum);
  Sql := Costruisci('SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI');

  Assert.IsTrue(StartsText('SELECT', Sql), Sql);
  Assert.IsTrue(Contiene(Sql, 'SUM(PAGAMENTI.IMPORTO) IMPORTO'), Sql);
  Assert.IsTrue(Contiene(Sql, 'FROM PAGAMENTI'), Sql);
end;

procedure TTestTotaliDiPiede.SelectSemplice_ConservaWhereETogliOrderBy;
var
  Sql: string;
begin
  Colonna('IMPORTO', skSum);
  Sql := Costruisci('SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI WHERE PAGAMENTI.ANNO = 2026 ORDER BY 1 DESC');

  Assert.IsTrue(Contiene(Sql, 'WHERE PAGAMENTI.ANNO = 2026'), Sql);
  Assert.IsFalse(Contiene(Sql, 'ORDER BY'), Sql);
end;

procedure TTestTotaliDiPiede.TipiDiTotale_FunzioniSql;
begin
  Colonna('A', skSum);
  Colonna('B', skAverage);
  Colonna('C', skCount);
  Colonna('D', skMin);
  Colonna('E', skMax);

  var Sql := Costruisci('SELECT PAGAMENTI.A FROM PAGAMENTI');

  Assert.IsTrue(Contiene(Sql, 'SUM(PAGAMENTI.A) A'), Sql);
  Assert.IsTrue(Contiene(Sql, 'AVG(PAGAMENTI.B) B'), Sql);
  Assert.IsTrue(Contiene(Sql, 'COUNT(PAGAMENTI.C) C'), Sql);
  Assert.IsTrue(Contiene(Sql, 'MIN(PAGAMENTI.D) D'), Sql);
  Assert.IsTrue(Contiene(Sql, 'MAX(PAGAMENTI.E) E'), Sql);
end;

procedure TTestTotaliDiPiede.OrigineVuota_ColonnaSaltata;
var
  Sql: string;
begin
  Colonna('IMPORTO', skSum);
  Colonna('SENZA_ORIGINE', skSum);
  Sql := Costruisci('SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI');

  Assert.IsTrue(Contiene(Sql, 'SUM(PAGAMENTI.IMPORTO) IMPORTO'), Sql);
  Assert.IsFalse(Contiene(Sql, 'SENZA_ORIGINE'), Sql);
end;

procedure TTestTotaliDiPiede.TutteSaltate_StringaVuota;
begin
  Colonna('SENZA_ORIGINE', skSum);
  Assert.AreEqual('', Costruisci('SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI'));
end;

procedure TTestTotaliDiPiede.PiuColonne_UnaPerRigaSeparateDaVirgola;
var
  Sql: string;
begin
  Colonna('A', skSum);
  Colonna('B', skMax);
  Sql := Costruisci('SELECT PAGAMENTI.A FROM PAGAMENTI');

  Assert.IsTrue(Contiene(Sql, 'SUM(PAGAMENTI.A) A,' + #13 + 'MAX(PAGAMENTI.B) B'), Sql);
end;

{ TTestTotaliDiPiedeDivergenze }

procedure TTestTotaliDiPiedeDivergenze.Setup;
begin
  FProprieta := TzDbViewProps.Create(nil);
end;

procedure TTestTotaliDiPiedeDivergenze.TearDown;
begin
  FreeAndNil(FProprieta);
end;

function TTestTotaliDiPiedeDivergenze.Costruisci(const Sql: string): string;
begin
  Result := TzDbViewFooterController.BuildFooterSQL(Sql, FProprieta.Columns,
    function(Nome: string): string
    begin
      Result := 'PAGAMENTI.' + Nome;
    end);
end;

procedure TTestTotaliDiPiedeDivergenze.DIV_TOT_1_ConGroupBy_OrigineFuoriDallaSottoquery;
var
  Sql: string;
begin
  FProprieta.Columns.Get('IMPORTO').FooterKind := skSum;
  Sql := Costruisci('SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI GROUP BY PAGAMENTI.IMPORTO');

  // la query di conteggio diventa SELECT COUNT(*) FROM (...) AS CONTEGGIO_RIGHE
  // e il totale resta su PAGAMENTI.IMPORTO, colonna che fuori dalla sottoquery
  // non esiste: Firebird rifiuta la query e il piede resta vuoto
  Assert.IsTrue(Contiene(Sql, 'CONTEGGIO_RIGHE'), Sql);
  Assert.IsTrue(Pos('SUM(PAGAMENTI.IMPORTO)', Sql) < Pos('FROM (', Sql), Sql);
end;

procedure TTestTotaliDiPiedeDivergenze.DIV_TOT_2_NonSelect_SqlSenzaFrom;
var
  Sql: string;
begin
  FProprieta.Columns.Get('IMPORTO').FooterKind := skSum;
  Sql := Costruisci('UPDATE PAGAMENTI SET IMPORTO = 0');

  Assert.AreNotEqual('', Sql);
  Assert.IsFalse(Contiene(Sql, 'FROM'), Sql);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTotaliDiPiede);
  TDUnitX.RegisterTestFixture(TTestTotaliDiPiedeDivergenze);

end.
