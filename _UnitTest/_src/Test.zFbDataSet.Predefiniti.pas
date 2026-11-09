// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-02
// ---------------------------------------------------------------------------

unit Test.zFbDataSet.Predefiniti;

// Test di zFIB\zFbDataSet: il valore predefinito di un campo arriva al record
// nuovo anche quando qualcosa ha azzerato la DefaultExpression del TField fra
// l'apertura e l'Append.
//
// E' il difetto dei ticket Gesty su STUDENTI_TIROCINI.MAX_ORE_GIORNALIERE (62,
// 65, 76, 79, 96, 116, 153): la colonna e' DEFAULT 8 NOT NULL, ma il campo
// arrivava NULL esplicito e il Post si fermava con "i campi seguenti devono
// avere un valore". Un test sul database non lo vede: il DEFAULT della colonna
// c'e', e' il TField che lo perde. La correzione (Mantis #153) fotografa le
// DefaultExpression e le rimette dove risultano vuote.
//
// Il dataset gira su SQLite in memoria, senza Firebird. Limiti verificati in
// SandBox (zProvaZFbDataSetSQLite, 2026-10-04), che decidono cosa si prova qui:
// - FireDAC su SQLite non riporta il DEFAULT della colonna nel campo: il
//   valore predefinito si da' con DefaultValues, come fa il dizionario LZ;
// - il Post non si completa: zPack scrive l'INSERT con le colonne qualificate
//   (TIROCINI.ID), che Firebird accetta e SQLite no. Si verifica quindi il
//   record dopo l'Append, che e' il punto in cui il difetto si vedeva;
// - senza TableName SetFieldsReadOnly considera ogni campo di un'altra
//   tabella e lo mette in sola lettura.
//
// Mantis #7054: il default testuale di un campo memo (BLOB SUB_TYPE TEXT con
// DEFAULT 'COLONNA 1') arrivava al TField senza apici e FireDAC lo valutava
// come espressione: "Column or function [COLONNA] is not found". Poiche' su
// SQLite FireDAC non riporta il DEFAULT, il valore lo mette OnInitFields, che
// e' il punto in cui lo mette il dizionario, subito prima della normalizzazione
// di UpdateDefaultExpressions.

interface

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.ExprFuncs,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  DUnitX.TestFramework,
  zFbDataSet;

type
  [TestFixture]
  TTestValoriPredefinitiZFbDataSet = class
  private
    FConnessione: TFDConnection;
    FDati: TzFbDataSet;
    FCampoPredefinito: string;
    FValorePredefinito: string;
    procedure Prepara(const ConValorePredefinito: boolean);
    procedure PreparaTemplate(const NomeCampo, ValorePredefinito: string);
    procedure ImpostaValorePredefinito(DataSet: TDataSet);
    function OreMassime: TField;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure CampiPersistenti_Append_ValorePredefinito;
    [Test]
    procedure CampiAutomatici_Append_ValorePredefinito;
    // Mantis #153 - 2026-10-04: il caso dei ticket su MAX_ORE_GIORNALIERE
    [Test]
    procedure CampiPersistenti_DefaultExpressionAzzerata_Ripristinata;
    // Mantis #153 - 2026-10-04: stesso caso sui campi nati dentro l'apertura
    [Test]
    procedure CampiAutomatici_DefaultExpressionAzzerata_Ripristinata;
    [Test]
    procedure Riapertura_ValorePredefinitoConservato;
    [Test]
    procedure ValorePredefinitoDelCodice_NonSovrascritto;
    [Test]
    procedure SenzaValorePredefinito_PostFermato;
    // Mantis #7054 - 2026-11-02: default testuale su campo memo, campi automatici
    [Test]
    procedure CampoMemo_DefaultTestuale_FraApici;
    // Mantis #7054 - 2026-11-02: default testuale su campo memo, campi persistenti
    [Test]
    procedure CampoMemoPersistente_DefaultTestuale_FraApici;
    // Mantis #7054 - 2026-11-02: DEFAULT NULL su campo memo resta senza apici
    [Test]
    procedure CampoMemo_DefaultNull_SenzaApici;
    // Mantis #7054 - 2026-11-02: il campo stringa si comporta come prima
    [Test]
    procedure CampoStringa_DefaultTestuale_Invariato;
  end;

implementation

{ TTestValoriPredefinitiZFbDataSet }

procedure TTestValoriPredefinitiZFbDataSet.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;

  // INT e non INTEGER: in SQLite "INTEGER PRIMARY KEY" e' il contatore della
  // riga, che FireDAC tratta come autoincremento in sola lettura
  FConnessione.ExecSQL('CREATE TABLE TIROCINI (ID INT NOT NULL PRIMARY KEY, MAX_ORE INTEGER DEFAULT 8 NOT NULL, NOTE VARCHAR(100))');

  // Mantis #7054: TEXT senza lunghezza e' un memo per FireDAC, come il
  // BLOB SUB_TYPE TEXT di WEB_CIT_CNF_TEMPLATE_COMUNI
  FConnessione.ExecSQL('CREATE TABLE TEMPLATE (ID INT NOT NULL PRIMARY KEY, PIEDE TEXT, TITOLO VARCHAR(50))');

  FDati := nil;
  FCampoPredefinito := '';
  FValorePredefinito := '';
end;

procedure TTestValoriPredefinitiZFbDataSet.TearDown;
begin
  FDati.Free;
  FConnessione.Free;
end;

procedure TTestValoriPredefinitiZFbDataSet.Prepara(const ConValorePredefinito: boolean);
begin
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.SQL.Text := 'SELECT ID, MAX_ORE, NOTE FROM TIROCINI';
  FDati.TableName := 'TIROCINI';

  // Come il dizionario LZ: il default del campo dichiarato sul dataset
  if ConValorePredefinito then
    FDati.DefaultValues.Text := 'MAX_ORE=8';
end;

procedure TTestValoriPredefinitiZFbDataSet.PreparaTemplate(const NomeCampo, ValorePredefinito: string);
begin
  FCampoPredefinito := NomeCampo;
  FValorePredefinito := ValorePredefinito;

  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.SQL.Text := 'SELECT ID, PIEDE, TITOLO FROM TEMPLATE';
  FDati.TableName := 'TEMPLATE';
  FDati.OnInitFields := ImpostaValorePredefinito;
end;

// Fa la parte del dizionario (e di FireDAC su Firebird): il default arriva
// sul TField com'e' scritto nei metadati, fra apici, prima che
// UpdateDefaultExpressions lo normalizzi
procedure TTestValoriPredefinitiZFbDataSet.ImpostaValorePredefinito(DataSet: TDataSet);
var
  Campo: TField;
begin
  Campo := DataSet.FindField(FCampoPredefinito);
  if Assigned(Campo) then
    Campo.DefaultExpression := FValorePredefinito;
end;

function TTestValoriPredefinitiZFbDataSet.OreMassime: TField;
begin
  Result := FDati.FieldByName('MAX_ORE');
end;

procedure TTestValoriPredefinitiZFbDataSet.CampiPersistenti_Append_ValorePredefinito;
begin
  Prepara(true);
  FDati.BuildFields;
  FDati.Open;
  FDati.Append;

  Assert.IsFalse(OreMassime.IsNull, 'MAX_ORE vuoto dopo Append');
  Assert.AreEqual(8, OreMassime.AsInteger);
end;

procedure TTestValoriPredefinitiZFbDataSet.CampiAutomatici_Append_ValorePredefinito;
begin
  Prepara(true);
  FDati.Open;
  FDati.Append;

  Assert.AreEqual(Ord(lcAutomatic), Ord(OreMassime.LifeCycle), 'il campo deve nascere dentro l''apertura');
  Assert.IsFalse(OreMassime.IsNull, 'MAX_ORE vuoto dopo Append');
  Assert.AreEqual(8, OreMassime.AsInteger);
end;

procedure TTestValoriPredefinitiZFbDataSet.CampiPersistenti_DefaultExpressionAzzerata_Ripristinata;
begin
  Prepara(true);
  FDati.BuildFields;
  FDati.Open;

  // Il difetto: qualcosa svuota la DefaultExpression prima dell'inserimento
  OreMassime.DefaultExpression := '';
  FDati.Append;

  Assert.IsFalse(OreMassime.IsNull, 'MAX_ORE vuoto dopo Append: il default azzerato non e'' stato rimesso');
  Assert.AreEqual(8, OreMassime.AsInteger);
  Assert.AreEqual('8', OreMassime.DefaultExpression);
end;

procedure TTestValoriPredefinitiZFbDataSet.CampiAutomatici_DefaultExpressionAzzerata_Ripristinata;
begin
  Prepara(true);
  FDati.Open;

  OreMassime.DefaultExpression := '';
  FDati.Append;

  Assert.IsFalse(OreMassime.IsNull, 'MAX_ORE vuoto dopo Append: il default azzerato non e'' stato rimesso');
  Assert.AreEqual(8, OreMassime.AsInteger);
end;

procedure TTestValoriPredefinitiZFbDataSet.Riapertura_ValorePredefinitoConservato;
begin
  // Chiusura e riapertura ricostruiscono il tracciato, che e' il momento in
  // cui FireDAC riscrive gli attributi dei campi
  Prepara(true);
  FDati.BuildFields;
  FDati.Open;
  FDati.Close;
  FDati.Open;
  FDati.Append;

  Assert.AreEqual(8, OreMassime.AsInteger);
end;

procedure TTestValoriPredefinitiZFbDataSet.ValorePredefinitoDelCodice_NonSovrascritto;
begin
  // Il ripristino tappa solo i buchi: un default diverso messo dal codice
  // applicativo e' una scelta, e resta
  Prepara(true);
  FDati.BuildFields;
  FDati.Open;

  OreMassime.DefaultExpression := '5';
  FDati.Append;

  Assert.AreEqual(5, OreMassime.AsInteger);
end;

procedure TTestValoriPredefinitiZFbDataSet.SenzaValorePredefinito_PostFermato;
var
  Messaggio: string;
begin
  // Senza default il campo resta vuoto e zPack ferma il Post prima di
  // mandarlo al database, col messaggio visto nei ticket
  Prepara(false);
  FDati.BuildFields;
  FDati.Open;
  FDati.Append;
  FDati.FieldByName('ID').AsInteger := 1;

  Assert.IsTrue(OreMassime.IsNull, 'senza default MAX_ORE deve essere vuoto');

  Messaggio := '';
  try
    FDati.Post;
  except
    on E: Exception do
      Messaggio := E.Message;
  end;

  Assert.Contains(Messaggio, 'devono avere un valore');
end;

// Mantis #7054 - 2026-11-02: default testuale su campo memo, campi automatici
procedure TTestValoriPredefinitiZFbDataSet.CampoMemo_DefaultTestuale_FraApici;
var
  Piede: TField;
begin
  PreparaTemplate('PIEDE', '''COLONNA 1''');
  FDati.Open;

  Piede := FDati.FieldByName('PIEDE');
  Assert.IsTrue(Piede.DataType in [ftMemo, ftWideMemo, ftFmtMemo], 'PIEDE deve essere un memo');
  Assert.AreEqual('''COLONNA 1''', Piede.DefaultExpression, 'il default del memo deve restare fra apici');

  // Senza apici FireDAC solleva qui [Stan][Eval]-100 "Column or function [COLONNA] is not found"
  FDati.Append;

  Assert.AreEqual('COLONNA 1', Piede.AsString);
end;

// Mantis #7054 - 2026-11-02: default testuale su campo memo, campi persistenti
procedure TTestValoriPredefinitiZFbDataSet.CampoMemoPersistente_DefaultTestuale_FraApici;
var
  Piede: TField;
begin
  PreparaTemplate('PIEDE', '''COLONNA 1''');
  FDati.BuildFields;
  FDati.Open;

  Piede := FDati.FieldByName('PIEDE');
  Assert.AreEqual('''COLONNA 1''', Piede.DefaultExpression, 'il default del memo deve restare fra apici');

  FDati.Append;

  Assert.AreEqual('COLONNA 1', Piede.AsString);
end;

// Mantis #7054 - 2026-11-02: DEFAULT NULL su campo memo resta senza apici
procedure TTestValoriPredefinitiZFbDataSet.CampoMemo_DefaultNull_SenzaApici;
var
  Piede: TField;
begin
  PreparaTemplate('PIEDE', 'NULL');
  FDati.Open;

  Piede := FDati.FieldByName('PIEDE');
  Assert.AreEqual('NULL', Piede.DefaultExpression, 'NULL non va messo fra apici');

  FDati.Append;

  Assert.IsTrue(Piede.IsNull, 'con DEFAULT NULL il memo deve restare vuoto, non contenere il testo NULL');
end;

// Mantis #7054 - 2026-11-02: il campo stringa si comporta come prima
procedure TTestValoriPredefinitiZFbDataSet.CampoStringa_DefaultTestuale_Invariato;
var
  Titolo: TField;
begin
  PreparaTemplate('TITOLO', '''COLONNA 1''');
  FDati.Open;

  Titolo := FDati.FieldByName('TITOLO');
  Assert.AreEqual('''COLONNA 1''', Titolo.DefaultExpression);

  FDati.Append;

  Assert.AreEqual('COLONNA 1', Titolo.AsString);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestValoriPredefinitiZFbDataSet);

end.
