// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-31
// ---------------------------------------------------------------------------
unit Test.zSql.TestoSql;

// Test DUnitX di zFIB\zSql.SqlTxtRtns: lettura e riscrittura del testo SQL
// senza database (specifica ZFIB-SQL, "Analisi del testo SQL.md").
//
// Due gruppi:
// - TTestTestoSql: i requisiti ZFIB-SQL-001..005, che il codice mantiene;
// - TTestTestoSqlDivergenze: caratterizzazione delle divergenze DIV-SQL-1..5
//   (voce R-197). Ogni prova afferma il comportamento DEDOTTO dalla lettura del
//   codice: se passa, la divergenza e' confermata; se fallisce, il messaggio
//   riporta il testo vero e la divergenza va corretta nella specifica. Quando
//   una divergenza verra' corretta nel codice, la prova va capovolta e spostata
//   fra i requisiti.

interface

uses
  System.SysUtils,
  System.StrUtils,
  DUnitX.TestFramework,
  zSql.SqlTxtRtns;

type
  [TestFixture]
  TTestTestoSql = class
  public
    // ZFIB-SQL-001
    [Test]
    procedure TipoIstruzione_CommentoPrimaDellaSelect_Select;
    [Test]
    procedure TipoIstruzione_Update_Update;
    // ZFIB-SQL-002
    [Test]
    procedure WherePrincipale_SottoqueryConWhere_SoloLaPrincipale;
    // ZFIB-SQL-003
    [Test]
    procedure AggiuntaCondizione_ConWhere_ParentesiEAnd;
    [Test]
    procedure AggiuntaCondizione_SenzaWhere_FraFromEOrderBy;
    [Test]
    procedure AggiuntaCondizione_Vuota_TestoInvariato;
    // ZFIB-SQL-004
    [Test]
    procedure Ordinamento_Sostituzione_UnSoloOrderBy;
    [Test]
    procedure Ordinamento_Vuoto_TolgeOrderBy;
    // ZFIB-SQL-005
    [Test]
    procedure Conteggio_Semplice_SenzaCampiESenzaOrderBy;
    [Test]
    procedure Conteggio_NonSelect_Vuoto;
    [Test]
    procedure Conteggio_ConGroupBy_ContaIGruppi;
    [Test]
    procedure Conteggio_ConDistinct_ContaIValoriDistinti;
    [Test]
    procedure Conteggio_QueryConWith_ContaLaSelectPrincipale;
    [Test]
    procedure Conteggio_QueryConDueDefinizioniWith_ContaLaSelectPrincipale;
    // ZFIB-SQL-003 (DIV-SQL-1 corretta)
    [Test]
    procedure WhereDelDataset_SottoqueryNelleColonne_RiscriveLaPrincipale;
    [Test]
    procedure WhereDelDataset_SenzaWhere_AggiungeLaCondizione;
  end;

  [TestFixture]
  TTestTestoSqlDivergenze = class
  public
    // DIV-SQL-3 (resta: il tipo di una query con WITH e' sconosciuto, il conteggio e' corretto)
    [Test]
    procedure DIV_SQL_3_QueryConWith_TipoSconosciuto;
    // DIV-SQL-4
    [Test]
    procedure DIV_SQL_4_Merge_ClassificatoComeSelect;
    // DIV-SQL-5
    [Test]
    procedure DIV_SQL_5_SelectSenzaFrom_WhereInCodaAlTesto;
  end;

implementation

const
  SelectConWhere = 'SELECT ID FROM T WHERE A = 1 ORDER BY ID';
  SelectSenzaWhere = 'SELECT ID FROM T ORDER BY ID';

function NumeroOccorrenze(const Cercato, Testo: string): Integer;
var
  Posizione: Integer;
begin
  Result := 0;
  Posizione := PosEx(Cercato, UpperCase(Testo), 1);
  while Posizione > 0 do
  begin
    Inc(Result);
    Posizione := PosEx(Cercato, UpperCase(Testo), Posizione + Length(Cercato));
  end;
end;

{ TTestTestoSql }

procedure TTestTestoSql.TipoIstruzione_CommentoPrimaDellaSelect_Select;
begin
  Assert.AreEqual(Ord(skSelect), Ord(GetSQLKind('/* nota */ SELECT ID FROM T')));
end;

procedure TTestTestoSql.TipoIstruzione_Update_Update;
begin
  Assert.AreEqual(Ord(skUpdate), Ord(GetSQLKind('UPDATE T SET A = 1')));
end;

procedure TTestTestoSql.WherePrincipale_SottoqueryConWhere_SoloLaPrincipale;
begin
  Assert.AreEqual('T.A = 1',
    Trim(MainWhereClause('SELECT (SELECT MAX(X) FROM U WHERE U.ID = T.ID) FROM T WHERE T.A = 1')));
end;

procedure TTestTestoSql.AggiuntaCondizione_ConWhere_ParentesiEAnd;
var
  Risultato: string;
begin
  Risultato := AddToWhereClause(SelectConWhere, 'B = 2', true);

  Assert.AreEqual(1, NumeroOccorrenze('WHERE', Risultato), 'una sola WHERE');
  // Gli spazi e i ritorni a capo attorno alle parentesi sono quelli di ForceCLRF: si guardano
  // solo parentesi, condizioni e congiunzione
  Assert.IsTrue(ContainsText(StringReplace(Risultato, ' ', '', [rfReplaceAll]), '(A=1'), 'vecchia condizione fra parentesi: ' + Risultato);
  Assert.IsTrue(ContainsText(Risultato, '( B = 2 )'), 'nuova condizione fra parentesi: ' + Risultato);
  Assert.IsTrue(ContainsText(Risultato, ' and '), 'unite da and: ' + Risultato);
  Assert.IsTrue(EndsText('ORDER BY ID', Trim(Risultato)), 'ORDER BY resta in fondo: ' + Risultato);
end;

procedure TTestTestoSql.AggiuntaCondizione_SenzaWhere_FraFromEOrderBy;
var
  Risultato: string;
  PosizioneFrom, PosizioneWhere, PosizioneOrder: Integer;
begin
  Risultato := UpperCase(AddToWhereClause(SelectSenzaWhere, 'B = 2', true));
  PosizioneFrom := Pos('FROM T', Risultato);
  PosizioneWhere := Pos('WHERE', Risultato);
  PosizioneOrder := Pos('ORDER BY', Risultato);

  Assert.IsTrue((PosizioneFrom > 0) and (PosizioneWhere > PosizioneFrom) and (PosizioneOrder > PosizioneWhere),
    'WHERE fra FROM e ORDER BY: ' + Risultato);
end;

procedure TTestTestoSql.AggiuntaCondizione_Vuota_TestoInvariato;
begin
  Assert.AreEqual(SelectConWhere, AddToWhereClause(SelectConWhere, '   ', true));
end;

procedure TTestTestoSql.Ordinamento_Sostituzione_UnSoloOrderBy;
var
  Risultato: string;
begin
  Risultato := SetOrderClause(SelectSenzaWhere, 'NOME DESC');

  Assert.AreEqual(1, NumeroOccorrenze('ORDER BY', Risultato), Risultato);
  Assert.IsTrue(EndsText('NOME DESC', Trim(Risultato)), Risultato);
end;

procedure TTestTestoSql.Ordinamento_Vuoto_TolgeOrderBy;
begin
  Assert.AreEqual(0, NumeroOccorrenze('ORDER BY', SetOrderClause(SelectSenzaWhere, '')));
end;

procedure TTestTestoSql.Conteggio_Semplice_SenzaCampiESenzaOrderBy;
var
  Risultato: string;
begin
  Risultato := UpperCase(CountSelect('SELECT ID, NOME FROM T WHERE A = 1 ORDER BY NOME'));

  Assert.IsTrue(StartsText('SELECT COUNT(*)', Risultato), Risultato);
  Assert.IsTrue(ContainsText(Risultato, 'FROM T'), Risultato);
  Assert.IsTrue(ContainsText(Risultato, 'WHERE A = 1'), Risultato);
  Assert.IsFalse(ContainsText(Risultato, 'ORDER BY'), Risultato);
  Assert.IsFalse(ContainsText(Risultato, 'NOME'), Risultato);
end;

procedure TTestTestoSql.Conteggio_NonSelect_Vuoto;
begin
  Assert.AreEqual('', CountSelect('UPDATE T SET A = 1'));
end;

procedure TTestTestoSql.Conteggio_ConGroupBy_ContaIGruppi;
var
  Risultato: string;
begin
  Risultato := UpperCase(CountSelect('SELECT TIPO, COUNT(*) FROM T GROUP BY TIPO ORDER BY TIPO'));

  Assert.IsTrue(StartsText('SELECT COUNT(*) FROM (SELECT TIPO, COUNT(*) FROM T GROUP BY TIPO)', Risultato), Risultato);
  Assert.IsFalse(ContainsText(Risultato, 'ORDER BY'), 'l''ordinamento non serve al conteggio: ' + Risultato);
end;

procedure TTestTestoSql.Conteggio_ConDistinct_ContaIValoriDistinti;
var
  Risultato: string;
begin
  Risultato := UpperCase(CountSelect('SELECT DISTINCT TIPO FROM T'));

  Assert.IsTrue(StartsText('SELECT COUNT(*) FROM (SELECT DISTINCT TIPO FROM T)', Risultato), Risultato);
end;

procedure TTestTestoSql.Conteggio_QueryConWith_ContaLaSelectPrincipale;
var
  Risultato: string;
begin
  Risultato := UpperCase(CountSelect('WITH C AS (SELECT 1 AS X FROM RDB$DATABASE) SELECT X FROM C'));

  Assert.IsTrue(StartsText('WITH C AS (SELECT 1 AS X FROM RDB$DATABASE) SELECT COUNT(*) FROM (SELECT X FROM C)', Risultato), Risultato);
end;

procedure TTestTestoSql.Conteggio_QueryConDueDefinizioniWith_ContaLaSelectPrincipale;
var
  Risultato: string;
begin
  Risultato := UpperCase(CountSelect('WITH A (X) AS (SELECT 1 FROM RDB$DATABASE), B AS (SELECT X FROM A WHERE X IN (1, 2)) SELECT X FROM B ORDER BY X'));

  Assert.IsTrue(ContainsText(Risultato, ') SELECT COUNT(*) FROM (SELECT X FROM B)'), Risultato);
  Assert.IsTrue(StartsText('WITH A (X) AS (SELECT 1 FROM RDB$DATABASE), B AS (', Risultato), Risultato);
end;

procedure TTestTestoSql.WhereDelDataset_SottoqueryNelleColonne_RiscriveLaPrincipale;
var
  Lettore: TSQLParser;
  Risultato: string;
begin
  // Come TzFbDataSet.SetWhere: la WHERE principale, non la prima del testo
  Lettore := TSQLParser.Create('SELECT (SELECT MAX(X) FROM U WHERE U.ID = T.ID) AS M FROM T WHERE T.A = 1');
  try
    Risultato := Lettore.SetMainWhereClause('T.A = 2');
  finally
    Lettore.Free;
  end;

  Assert.IsTrue(ContainsText(Risultato, 'U.ID = T.ID'), 'la WHERE della sottoquery doveva restare: ' + Risultato);
  Assert.IsTrue(ContainsText(Risultato, 'T.A = 2'), 'la WHERE principale doveva cambiare: ' + Risultato);
  Assert.IsFalse(ContainsText(Risultato, 'T.A = 1'), Risultato);
end;

procedure TTestTestoSql.WhereDelDataset_SenzaWhere_AggiungeLaCondizione;
var
  Lettore: TSQLParser;
  Risultato: string;
begin
  Lettore := TSQLParser.Create(SelectSenzaWhere);
  try
    Risultato := Lettore.SetMainWhereClause('A = 1');
  finally
    Lettore.Free;
  end;

  Assert.AreEqual(1, NumeroOccorrenze('WHERE', Risultato), Risultato);
  Assert.IsTrue(ContainsText(Risultato, 'A = 1'), Risultato);
end;

{ TTestTestoSqlDivergenze }

procedure TTestTestoSqlDivergenze.DIV_SQL_3_QueryConWith_TipoSconosciuto;
const
  QueryConWith = 'WITH C AS (SELECT 1 AS X FROM RDB$DATABASE) SELECT X FROM C';
begin
  Assert.AreEqual(Ord(skUnknown), Ord(GetSQLKind(QueryConWith)));
end;

procedure TTestTestoSqlDivergenze.DIV_SQL_4_Merge_ClassificatoComeSelect;
begin
  Assert.AreEqual(Ord(skSelect),
    Ord(GetSQLKind('MERGE INTO T USING U ON T.ID = U.ID WHEN MATCHED THEN UPDATE SET A = 1')));
end;

procedure TTestTestoSqlDivergenze.DIV_SQL_5_SelectSenzaFrom_WhereInCodaAlTesto;
var
  Risultato: string;
begin
  Risultato := UpperCase(AddToWhereClause('SELECT 1', 'A = 1', true));

  Assert.IsTrue((Pos('WHERE', Risultato) > Pos('SELECT', Risultato)) and (Pos('SELECT', Risultato) > 0),
    'la WHERE doveva seguire la SELECT: ' + Risultato);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTestoSql);
  TDUnitX.RegisterTestFixture(TTestTestoSqlDivergenze);

end.
