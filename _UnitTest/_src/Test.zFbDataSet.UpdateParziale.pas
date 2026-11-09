// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

unit Test.zFbDataSet.UpdateParziale;

// Test dell'UPDATE con le sole colonne cambiate (Mantis #257): la funzione
// pura zSql.UpdateParziale.ComponiUpdateParziale e TzFbDataSet.InternalPost,
// che con AutoUpdate e UpdateChangedFields accesa riscrive ModifySQL prima
// del salvataggio.
//
// Il difetto del ticket: l'UPDATE automatico scriveva tutte le colonne, e una
// scheda aperta prima che un'altra finestra salvasse la nota la riscriveva con
// il valore vecchio pur avendo cambiato solo un altro campo.
//
// UpdateChangedFields e' spenta di predefinito (UPDATE completo di sempre) e
// si accende dataset per dataset: CreaScheda la accende, salvo i test che
// provano il predefinito.
//
// Il dataset gira su SQLite in memoria, senza Firebird, come in
// Test.zFbDataSet.CampiBinari. Le parti dell'UPDATE si impostano a mano come
// le imposta TzSystem (ImpostaUpdateAutomatico), senza RETURNING: la
// composizione si prova sul testo, il comportamento sui dati.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
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
  zSql.UpdateParziale,
  zFbDataSet;

type
  [TestFixture]
  TTestUpdateParzialeZFbDataSet = class
  private
    FConnessione: TFDConnection;
    FSchedaA: TzFbDataSet;
    FSchedaB: TzFbDataSet;
    function CreaScheda(const ConColonnaExtra: boolean = false; const Accesa: boolean = true): TzFbDataSet;
    function ValoreSulDatabase(const Colonna: string): string;
    function TestoSet(Scheda: TzFbDataSet): string;
    procedure CalcolaCampi(DataSet: TDataSet);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Mantis #257 - 2026-10-29: composizione con una colonna cambiata
    [Test]
    procedure Componi_UnaColonna;
    // Mantis #257 - 2026-10-29: senza colonne cambiate il SET della chiave, mai vuoto
    [Test]
    procedure Componi_NessunaColonna_SetDellaChiave;
    // Mantis #257 - 2026-10-29: niente colonne ne' chiavi, testo vuoto (chi chiama tiene il completo)
    [Test]
    procedure Componi_NienteDaScrivere_Vuoto;
    // Mantis #257 - 2026-10-29: con tutte le colonne la forma di Build_Sql_Update
    [Test]
    procedure Componi_TutteLeColonne_FormaDiBuildSqlUpdate;
    // Mantis #257 - 2026-10-29: piu' colonne nell'ordine della tabella, non dell'assegnazione
    [Test]
    procedure Post_PiuColonne_OrdineDellaTabella;
    // Mantis #257 - 2026-10-29: MEMO riassegnato con lo stesso testo, fuori dal SET
    [Test]
    procedure Post_MemoRiassegnatoUguale_NonScritto;
    // Mantis #257 - 2026-10-29: colonna assente dalla SELECT e campo calcolato, mai nel SET
    [Test]
    procedure Post_ColonnaAssenteECampoCalcolato_NonNelSet;
    // Mantis #257 - 2026-10-29: il caso del ticket, due schede sullo stesso record
    [Test]
    procedure Post_DueSchede_NotaDellAltraSchedaResta;
    // Mantis #257 - 2026-10-29: due salvataggi di campi diversi, il comando si riprepara
    [Test]
    procedure Post_DueSalvataggi_TestoNuovo;
    // Mantis #257 - 2026-10-29: salvataggio senza modifiche, UPDATE della sola chiave
    [Test]
    procedure Post_SenzaModifiche_SetDellaChiave;
    // Mantis #257 - 2026-10-29: inserimento invariato, tutte le colonne
    [Test]
    procedure Post_Inserimento_Invariato;
    // Mantis #257 - 2026-10-29: proprieta' spenta, UPDATE completo di sempre
    [Test]
    procedure Post_ProprietaSpenta_UpdateCompleto;
    // Mantis #257 - 2026-10-29: predefinito spento, il dataset si comporta come prima
    [Test]
    procedure Post_Predefinito_SpentaEUpdateCompleto;
    // Mantis #257 - 2026-10-29: UpdateSQL cambiato da altri, il dataset non lo tocca
    [Test]
    procedure Post_UpdateSQLCambiatoDaAltri_NonToccato;
  end;

implementation

const
  WhereChiave = 'WHERE' + #13 + ' ID=:OLD_ID';

procedure Riempi(Elenco: TStrings; const Valori: array of string);
var
  Valore: string;
begin
  Elenco.Clear;
  for Valore in Valori do
    Elenco.Add(Valore);
end;

// TTestUpdateParzialeZFbDataSet

procedure TTestUpdateParzialeZFbDataSet.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;

  // INT e non INTEGER: in SQLite "INTEGER PRIMARY KEY" e' il contatore della
  // riga, che FireDAC tratta come autoincremento in sola lettura. NOTE TEXT
  // diventa un MEMO di FireDAC, come le note del ticket.
  FConnessione.ExecSQL('CREATE TABLE SCHEDE (ID INT NOT NULL PRIMARY KEY, NOTE TEXT, INFORMAZIONI VARCHAR(100), STATO VARCHAR(10), EXTRA VARCHAR(10))');
  FConnessione.ExecSQL('INSERT INTO SCHEDE (ID, NOTE, INFORMAZIONI, STATO, EXTRA) VALUES (1, ''NO ISEE'', ''prima'', ''A'', ''fuori'')');

  FSchedaA := nil;
  FSchedaB := nil;
end;

procedure TTestUpdateParzialeZFbDataSet.TearDown;
begin
  FSchedaA.Free;
  FSchedaB.Free;
  FConnessione.Free;
end;

function TTestUpdateParzialeZFbDataSet.CreaScheda(const ConColonnaExtra: boolean; const Accesa: boolean): TzFbDataSet;
begin
  Result := TzFbDataSet.Create(nil);
  Result.Connection := FConnessione;
  Result.SQL.Text := 'SELECT ID, NOTE, INFORMAZIONI, STATO FROM SCHEDE ORDER BY ID';
  Result.TableName := 'SCHEDE';
  Result.InsertSQL.Text := 'INSERT INTO SCHEDE (ID, NOTE, INFORMAZIONI, STATO) VALUES (:ID, :NOTE, :INFORMAZIONI, :STATO)';

  // come ImpostaUpdateAutomatico di zSystem: testo completo, parti, AutoUpdate per ultimo
  if ConColonnaExtra then
    Riempi(Result.AutoUpdateColumns, ['ID', 'NOTE', 'INFORMAZIONI', 'STATO', 'EXTRA'])
  else
    Riempi(Result.AutoUpdateColumns, ['ID', 'NOTE', 'INFORMAZIONI', 'STATO']);
  Riempi(Result.AutoUpdateKeyFields, ['SCHEDE.ID']);
  Result.AutoUpdateReturning.Clear;
  Result.AutoUpdateWhere := WhereChiave;
  Result.UpdateSQL.Text := ComponiUpdateParziale('SCHEDE', Result.AutoUpdateColumns, nil, WhereChiave, nil);
  Result.AutoUpdate := true;

  // spenta di predefinito: la accende chi la vuole, come il dizionario
  if Accesa then
    Result.UpdateChangedFields := true;
end;

function TTestUpdateParzialeZFbDataSet.ValoreSulDatabase(const Colonna: string): string;
begin
  Result := VarToStr(FConnessione.ExecSQLScalar('SELECT ' + Colonna + ' FROM SCHEDE WHERE ID = 1'));
end;

// Parte fra SET e WHERE dell'UPDATE che il dataset ha usato
function TTestUpdateParzialeZFbDataSet.TestoSet(Scheda: TzFbDataSet): string;
var
  Testo: string;
  Inizio: Integer;
  Fine: Integer;
begin
  Testo := Scheda.UpdateSQL.Text;
  Inizio := Pos('SET', Testo);
  Fine := Pos('WHERE', Testo);
  Result := Trim(Copy(Testo, Inizio + 3, Fine - Inizio - 3));
end;

procedure TTestUpdateParzialeZFbDataSet.CalcolaCampi(DataSet: TDataSet);
begin
  DataSet.FieldByName('CALCOLATO').AsString := DataSet.FieldByName('INFORMAZIONI').AsString + '!';
end;

procedure TTestUpdateParzialeZFbDataSet.Componi_UnaColonna;
var
  Colonne: TStringList;
  Chiavi: TStringList;
  Returning: TStringList;
begin
  Colonne := TStringList.Create;
  Chiavi := TStringList.Create;
  Returning := TStringList.Create;
  try
    Riempi(Colonne, ['NOTE']);
    Riempi(Chiavi, ['T.ID']);
    Riempi(Returning, ['ID', 'NOTE']);

    Assert.AreEqual(
      'UPDATE T' + sLineBreak +
      'SET' + sLineBreak +
      ' NOTE=:NOTE' + sLineBreak +
      'WHERE' + #13 + ' T.ID=:OLD_ID' + sLineBreak +
      'RETURNING ' + sLineBreak +
      '  ID,' + sLineBreak +
      '  NOTE' + sLineBreak,
      ComponiUpdateParziale('T', Colonne, Chiavi, 'WHERE' + #13 + ' T.ID=:OLD_ID', Returning));
  finally
    Returning.Free;
    Chiavi.Free;
    Colonne.Free;
  end;
end;

procedure TTestUpdateParzialeZFbDataSet.Componi_NessunaColonna_SetDellaChiave;
var
  Colonne: TStringList;
  Chiavi: TStringList;
  Testo: string;
begin
  Colonne := TStringList.Create;
  Chiavi := TStringList.Create;
  try
    Riempi(Chiavi, ['T.ID', 'T.ANNO']);
    Testo := ComponiUpdateParziale('T', Colonne, Chiavi, 'WHERE ID=:OLD_ID AND ANNO=:OLD_ANNO', nil);

    Assert.AreEqual(
      'UPDATE T' + sLineBreak +
      'SET' + sLineBreak +
      ' ID=:ID,' + sLineBreak +
      ' ANNO=:ANNO' + sLineBreak +
      'WHERE ID=:OLD_ID AND ANNO=:OLD_ANNO' + sLineBreak,
      Testo);
  finally
    Chiavi.Free;
    Colonne.Free;
  end;
end;

procedure TTestUpdateParzialeZFbDataSet.Componi_NienteDaScrivere_Vuoto;
var
  Colonne: TStringList;
begin
  Colonne := TStringList.Create;
  try
    Assert.AreEqual('', ComponiUpdateParziale('T', Colonne, nil, 'WHERE ID=:OLD_ID', nil));
    Assert.AreEqual('', ComponiUpdateParziale('T', nil, nil, 'WHERE ID=:OLD_ID', nil));
    Riempi(Colonne, ['NOTE']);
    Assert.AreEqual('', ComponiUpdateParziale('', Colonne, nil, 'WHERE ID=:OLD_ID', nil));
  finally
    Colonne.Free;
  end;
end;

procedure TTestUpdateParzialeZFbDataSet.Componi_TutteLeColonne_FormaDiBuildSqlUpdate;
var
  Colonne: TStringList;
  Returning: TStringList;
begin
  // testo che Build_Sql_Update (zSqlLib) produce per la stessa tabella
  Colonne := TStringList.Create;
  Returning := TStringList.Create;
  try
    Riempi(Colonne, ['ID', 'NOTE', 'INFORMAZIONI']);
    Riempi(Returning, ['ID', 'NOTE', 'INFORMAZIONI', 'CALCOLATA']);

    Assert.AreEqual(
      'UPDATE SCHEDE' + sLineBreak +
      'SET' + sLineBreak +
      ' ID=:ID,' + sLineBreak +
      ' NOTE=:NOTE,' + sLineBreak +
      ' INFORMAZIONI=:INFORMAZIONI' + sLineBreak +
      WhereChiave + sLineBreak +
      'RETURNING ' + sLineBreak +
      '  ID,' + sLineBreak +
      '  NOTE,' + sLineBreak +
      '  INFORMAZIONI,' + sLineBreak +
      '  CALCOLATA' + sLineBreak,
      ComponiUpdateParziale('SCHEDE', Colonne, nil, WhereChiave, Returning));
  finally
    Returning.Free;
    Colonne.Free;
  end;
end;

procedure TTestUpdateParzialeZFbDataSet.Post_PiuColonne_OrdineDellaTabella;
begin
  FSchedaA := CreaScheda;
  FSchedaA.Open;

  FSchedaA.Edit;
  FSchedaA.FieldByName('STATO').AsString := 'B';
  FSchedaA.FieldByName('NOTE').AsString := 'nota nuova';
  FSchedaA.Post;

  Assert.AreEqual('NOTE=:NOTE,' + sLineBreak + ' STATO=:STATO', TestoSet(FSchedaA));
  Assert.AreEqual('nota nuova', ValoreSulDatabase('NOTE'));
  Assert.AreEqual('B', ValoreSulDatabase('STATO'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_MemoRiassegnatoUguale_NonScritto;
begin
  FSchedaA := CreaScheda;
  FSchedaA.Open;
  Assert.IsTrue(FSchedaA.FieldByName('NOTE').IsBlob, 'NOTE deve essere un MEMO, non ' + FSchedaA.FieldByName('NOTE').ClassName);

  // un'altra finestra cambia la nota dopo la lettura
  FConnessione.ExecSQL('UPDATE SCHEDE SET NOTE = ''nota di un''''altra finestra'' WHERE ID = 1');

  FSchedaA.Edit;
  FSchedaA.FieldByName('NOTE').AsString := FSchedaA.FieldByName('NOTE').AsString;
  FSchedaA.FieldByName('INFORMAZIONI').AsString := 'dopo';
  FSchedaA.Post;

  Assert.AreEqual('INFORMAZIONI=:INFORMAZIONI', TestoSet(FSchedaA));
  Assert.AreEqual('nota di un''altra finestra', ValoreSulDatabase('NOTE'));
  Assert.AreEqual('dopo', ValoreSulDatabase('INFORMAZIONI'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_ColonnaAssenteECampoCalcolato_NonNelSet;
var
  Calcolato: TStringField;
begin
  FSchedaA := CreaScheda(true);
  // CALCOLATO e' fra le colonne aggiornabili ma e' un campo calcolato
  FSchedaA.AutoUpdateColumns.Add('CALCOLATO');
  FSchedaA.AutoUpdate := true;
  FSchedaA.BuildFields;
  Calcolato := TStringField.Create(FSchedaA);
  Calcolato.FieldName := 'CALCOLATO';
  Calcolato.FieldKind := fkCalculated;
  Calcolato.Size := 120;
  Calcolato.DataSet := FSchedaA;
  FSchedaA.OnCalcFields := CalcolaCampi;
  FSchedaA.Open;

  FSchedaA.Edit;
  FSchedaA.FieldByName('INFORMAZIONI').AsString := 'dopo';
  FSchedaA.Post;

  Assert.AreEqual('INFORMAZIONI=:INFORMAZIONI', TestoSet(FSchedaA));
  Assert.AreEqual('fuori', ValoreSulDatabase('EXTRA'));
  Assert.AreEqual('dopo', ValoreSulDatabase('INFORMAZIONI'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_DueSchede_NotaDellAltraSchedaResta;
begin
  // casi 4 e 5 dell'analisi: due schede aperte sullo stesso intervento
  FSchedaA := CreaScheda;
  FSchedaB := CreaScheda;
  FSchedaA.Open;
  FSchedaB.Open;

  FSchedaA.Edit;
  FSchedaA.FieldByName('NOTE').AsString := 'NO ISEE' + sLineBreak + 'riga aggiunta';
  FSchedaA.Post;

  // B ha ancora in memoria la nota senza la riga aggiunta
  FSchedaB.Edit;
  FSchedaB.FieldByName('INFORMAZIONI').AsString := 'da B';
  FSchedaB.Post;

  Assert.AreEqual('NO ISEE' + sLineBreak + 'riga aggiunta', ValoreSulDatabase('NOTE'));
  Assert.AreEqual('da B', ValoreSulDatabase('INFORMAZIONI'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_DueSalvataggi_TestoNuovo;
begin
  FSchedaA := CreaScheda;
  FSchedaA.Open;

  FSchedaA.Edit;
  FSchedaA.FieldByName('NOTE').AsString := 'prima nota';
  FSchedaA.Post;
  Assert.AreEqual('NOTE=:NOTE', TestoSet(FSchedaA));

  // nel frattempo un'altra finestra cambia la nota: il secondo salvataggio,
  // se usasse ancora il primo UPDATE, la riscriverebbe
  FConnessione.ExecSQL('UPDATE SCHEDE SET NOTE = ''nota esterna'' WHERE ID = 1');

  FSchedaA.Edit;
  FSchedaA.FieldByName('STATO').AsString := 'C';
  FSchedaA.Post;

  Assert.AreEqual('STATO=:STATO', TestoSet(FSchedaA));
  Assert.AreEqual('nota esterna', ValoreSulDatabase('NOTE'));
  Assert.AreEqual('C', ValoreSulDatabase('STATO'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_SenzaModifiche_SetDellaChiave;
begin
  FSchedaA := CreaScheda;
  FSchedaA.Open;
  FConnessione.ExecSQL('UPDATE SCHEDE SET NOTE = ''nota esterna'' WHERE ID = 1');

  FSchedaA.Edit;
  FSchedaA.Post;

  Assert.AreEqual('ID=:ID', TestoSet(FSchedaA));
  Assert.AreEqual('nota esterna', ValoreSulDatabase('NOTE'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_Inserimento_Invariato;
var
  UpdatePrima: string;
begin
  FSchedaA := CreaScheda;
  FSchedaA.Open;
  UpdatePrima := FSchedaA.UpdateSQL.Text;

  FSchedaA.Append;
  FSchedaA.FieldByName('ID').AsInteger := 2;
  FSchedaA.FieldByName('NOTE').AsString := 'nuova';
  FSchedaA.FieldByName('INFORMAZIONI').AsString := 'inserita';
  FSchedaA.FieldByName('STATO').AsString := 'N';
  FSchedaA.Post;

  Assert.AreEqual(UpdatePrima, FSchedaA.UpdateSQL.Text, 'l''inserimento non deve toccare l''UPDATE');
  Assert.AreEqual('nuova|inserita|N',
    VarToStr(FConnessione.ExecSQLScalar('SELECT NOTE || ''|'' || INFORMAZIONI || ''|'' || STATO FROM SCHEDE WHERE ID = 2')));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_ProprietaSpenta_UpdateCompleto;
var
  UpdateCompleto: string;
begin
  FSchedaA := CreaScheda;
  FSchedaB := CreaScheda;
  UpdateCompleto := FSchedaB.UpdateSQL.Text;
  FSchedaA.Open;
  FSchedaB.Open;

  // B prima salva con la proprieta' accesa (UPDATE ridotto)...
  FSchedaB.Edit;
  FSchedaB.FieldByName('STATO').AsString := 'B';
  FSchedaB.Post;
  Assert.AreEqual('STATO=:STATO', TestoSet(FSchedaB));

  FSchedaA.Edit;
  FSchedaA.FieldByName('NOTE').AsString := 'nota di A';
  FSchedaA.Post;

  // ...poi la spegne: torna l'UPDATE completo e, come prima della correzione,
  // la nota vecchia che B ha in memoria sovrascrive quella di A
  FSchedaB.UpdateChangedFields := false;
  FSchedaB.Edit;
  FSchedaB.FieldByName('INFORMAZIONI').AsString := 'da B';
  FSchedaB.Post;

  // a capo sostituiti: DUnitX taglia il messaggio alla prima riga
  Assert.AreEqual(StringReplace(UpdateCompleto, sLineBreak, ' | ', [rfReplaceAll]),
    StringReplace(FSchedaB.UpdateSQL.Text, sLineBreak, ' | ', [rfReplaceAll]));
  Assert.AreEqual('NO ISEE', ValoreSulDatabase('NOTE'));
  Assert.AreEqual('da B', ValoreSulDatabase('INFORMAZIONI'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_Predefinito_SpentaEUpdateCompleto;
var
  UpdateCompleto: string;
begin
  // dataset nuovo, proprieta' non toccata: spenta, e il salvataggio usa
  // l'UPDATE completo di sempre anche se le parti per ridurlo ci sono
  FSchedaA := CreaScheda(false, false);
  FSchedaB := CreaScheda(false, false);
  Assert.IsFalse(FSchedaB.UpdateChangedFields, 'UpdateChangedFields deve essere spenta di predefinito');
  UpdateCompleto := FSchedaB.UpdateSQL.Text;
  FSchedaA.Open;
  FSchedaB.Open;

  FSchedaA.Edit;
  FSchedaA.FieldByName('NOTE').AsString := 'nota di A';
  FSchedaA.Post;

  FSchedaB.Edit;
  FSchedaB.FieldByName('INFORMAZIONI').AsString := 'da B';
  FSchedaB.Post;

  // come prima della correzione: B, con la nota vecchia, riscrive tutto
  Assert.AreEqual(StringReplace(UpdateCompleto, sLineBreak, ' | ', [rfReplaceAll]),
    StringReplace(FSchedaB.UpdateSQL.Text, sLineBreak, ' | ', [rfReplaceAll]));
  Assert.AreEqual('NO ISEE', ValoreSulDatabase('NOTE'));
  Assert.AreEqual('da B', ValoreSulDatabase('INFORMAZIONI'));
end;

procedure TTestUpdateParzialeZFbDataSet.Post_UpdateSQLCambiatoDaAltri_NonToccato;
const
  UpdateAMano = 'UPDATE SCHEDE SET INFORMAZIONI = :INFORMAZIONI WHERE ID = :OLD_ID';
begin
  FSchedaA := CreaScheda;
  FSchedaA.UpdateSQL.Text := UpdateAMano;
  FSchedaA.Open;

  FSchedaA.Edit;
  FSchedaA.FieldByName('INFORMAZIONI').AsString := 'a mano';
  FSchedaA.Post;

  Assert.AreEqual(UpdateAMano, Trim(FSchedaA.UpdateSQL.Text));
  Assert.AreEqual('a mano', ValoreSulDatabase('INFORMAZIONI'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestUpdateParzialeZFbDataSet);

end.
