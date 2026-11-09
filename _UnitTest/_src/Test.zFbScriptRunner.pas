// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-31
// ---------------------------------------------------------------------------
unit Test.zFbScriptRunner;

// Test DUnitX di zFIB\zFbScriptRunner (specifica ZFIB-SCR, "Esecuzione di
// script.md").
//
// La spezzatura del testo (ParseOnly) non usa il database. Le prove di
// esecuzione girano su SQLite in memoria, senza Firebird: il runner manda al
// server comandi SQL comuni (CREATE, INSERT, SAVEPOINT) e gestisce da solo
// COMMIT, ROLLBACK e le direttive isql, quindi il motore non cambia l'esito.
//
// Le prove DIV-SCR-1, 2, 3 e 8 (voce R-197) sono state capovolte nel rilascio
// 008, quando le divergenze sono state corrette: ora affermano il comportamento
// giusto. DIV_SCR_4 e' stata capovolta nel rilascio 010 (Failed conta i comandi,
// non i tentativi); DIV_SCR_6 prova la spezzatura lineare.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
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
  zFbScriptRunner;

type
  [TestFixture]
  TTestSpezzaturaScript = class
  private
    FEsecutore: TzFbScriptRunner;
    FComandi: TStringList;
    procedure Spezza(const Testo: string);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZFIB-SCR-002
    [Test]
    procedure CommentoDiRiga_Tolto;
    [Test]
    procedure SegnoDiCommentoInUnLetterale_Conservato;
    // ZFIB-SCR-003
    [Test]
    procedure SetTerm_CorpoDiProcedura_UnSoloComando;
    [Test]
    procedure TerminatoreInUnLetterale_UnSoloComando;
    // ZFIB-SCR-009
    [Test]
    procedure ParseOnly_SenzaConnessione_NonSollevaErrori;
    // DIV-SCR-3
    [Test]
    procedure CommentoDiBloccoTraDueParole_LeParoleRestanoSeparate;
    // DIV-SCR-6
    [Test]
    procedure DIV_SCR_6_ComandoLungo_SpezzaturaVeloce;
  end;

  [TestFixture]
  TTestEsecuzioneScript = class
  private
    FConnessione: TFDConnection;
    FTransazione: TFDTransaction;
    FEsecutore: TzFbScriptRunner;
    FTentativi: Integer;
    function RigheInT: Integer;
    procedure RiprovaUnaVolta(Sender: TObject; const Command: string; E: Exception;
      var Action: TzScriptErrorAction);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZFIB-SCR-001
    [Test]
    procedure SenzaConnessione_SollevaEccezione;
    // ZFIB-SCR-004
    [Test]
    procedure DirettivaIsql_Saltata;
    // ZFIB-SCR-006
    [Test]
    procedure ScriptControllato_Interruzione_AnnullaDopoIlCommit;
    [Test]
    procedure TransazioneEsterna_CommitDelloScript_NonConferma;
    // ZFIB-SCR-007
    [Test]
    procedure ErroreSenzaStopOnError_ProseguePoi_Failed1;
    // ZFIB-SCR-008
    [Test]
    procedure Esito_TreInsertEUnCommit;
    // DIV-SCR-1
    [Test]
    procedure RollbackToSavepoint_VaAlServer_TornaAlPunto;
    // DIV-SCR-2
    [Test]
    procedure SetTimeZone_NonEUnaDirettivaIgnorata;
    // DIV-SCR-4
    [Test]
    procedure DIV_SCR_4_Riprova_FailedContaIComandi;
    // DIV-SCR-8
    [Test]
    procedure SenzaTransazione_IlRunnerNeUsaUnaSua_RollbackFinaleAnnulla;
  end;

implementation

{ TTestSpezzaturaScript }

procedure TTestSpezzaturaScript.Setup;
begin
  FEsecutore := TzFbScriptRunner.Create(nil);
  FComandi := TStringList.Create;
end;

procedure TTestSpezzaturaScript.TearDown;
begin
  FComandi.Free;
  FEsecutore.Free;
end;

procedure TTestSpezzaturaScript.Spezza(const Testo: string);
begin
  FEsecutore.ParseOnly(Testo, FComandi);
end;

procedure TTestSpezzaturaScript.CommentoDiRiga_Tolto;
begin
  Spezza('SELECT 1 FROM RDB$DATABASE; -- fine');

  Assert.AreEqual(1, FComandi.Count);
  Assert.AreEqual('SELECT 1 FROM RDB$DATABASE', FComandi[0]);
end;

procedure TTestSpezzaturaScript.SegnoDiCommentoInUnLetterale_Conservato;
begin
  Spezza('INSERT INTO T (A) VALUES (''a -- b'');');

  Assert.AreEqual(1, FComandi.Count);
  Assert.AreEqual('INSERT INTO T (A) VALUES (''a -- b'')', FComandi[0]);
end;

procedure TTestSpezzaturaScript.SetTerm_CorpoDiProcedura_UnSoloComando;
begin
  Spezza('SET TERM ^ ;' + sLineBreak +
    'CREATE PROCEDURE P AS BEGIN EXIT; END^' + sLineBreak +
    'SET TERM ; ^' + sLineBreak +
    'SELECT 1 FROM RDB$DATABASE;');

  Assert.AreEqual(2, FComandi.Count, FComandi.Text);
  Assert.AreEqual('CREATE PROCEDURE P AS BEGIN EXIT; END', FComandi[0]);
  Assert.AreEqual('SELECT 1 FROM RDB$DATABASE', FComandi[1]);
  Assert.AreEqual(';', FEsecutore.CurrentTerminator);
end;

procedure TTestSpezzaturaScript.TerminatoreInUnLetterale_UnSoloComando;
begin
  Spezza('INSERT INTO T (A) VALUES (''x;y'');');

  Assert.AreEqual(1, FComandi.Count);
end;

procedure TTestSpezzaturaScript.ParseOnly_SenzaConnessione_NonSollevaErrori;
begin
  Spezza('SELECT 1 FROM RDB$DATABASE; SELECT 2 FROM RDB$DATABASE;');

  Assert.AreEqual(2, FComandi.Count);
end;

procedure TTestSpezzaturaScript.CommentoDiBloccoTraDueParole_LeParoleRestanoSeparate;
begin
  Spezza('SELECT/*c*/1 FROM RDB$DATABASE;');

  Assert.AreEqual(1, FComandi.Count);
  Assert.IsTrue(FComandi[0].StartsWith('SELECT'), FComandi[0]);
  Assert.IsFalse(FComandi[0].Contains('SELECT1'), 'le parole non si incollano: ' + FComandi[0]);
end;

procedure TTestSpezzaturaScript.DIV_SCR_6_ComandoLungo_SpezzaturaVeloce;
var
  Testo: string;
  Cronometro: TStopwatch;
begin
  // un solo comando di 400.000 caratteri: con la potatura a ogni carattere
  // il tempo cresceva col quadrato della lunghezza
  Testo := 'INSERT INTO T VALUES (' + StringOfChar('1', 400000) + ');' + sLineBreak +
    'SET TERM ^ ;' + sLineBreak + 'CREATE PROCEDURE P AS BEGIN END^' + sLineBreak + 'SET TERM ; ^';

  Cronometro := TStopwatch.StartNew;
  Spezza(Testo);
  Cronometro.Stop;

  Assert.AreEqual(2, FComandi.Count);
  Assert.IsTrue(Cronometro.ElapsedMilliseconds < 2000, 'tempo: ' + Cronometro.ElapsedMilliseconds.ToString + ' ms');
end;

{ TTestEsecuzioneScript }

procedure TTestEsecuzioneScript.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;
  FConnessione.ExecSQL('CREATE TABLE T (A INT)');

  // Transazione esplicita, come TzFbDatabase: vedi DIV_SCR_8 per il caso senza
  FTransazione := TFDTransaction.Create(nil);
  FTransazione.Connection := FConnessione;
  FConnessione.Transaction := FTransazione;

  FEsecutore := TzFbScriptRunner.Create(nil);
  FEsecutore.Connection := FConnessione;
  FEsecutore.Transaction := FTransazione;
  FTentativi := 0;
end;

procedure TTestEsecuzioneScript.TearDown;
begin
  FEsecutore.Free;
  FConnessione.Free;
  FTransazione.Free;
end;

function TTestEsecuzioneScript.RigheInT: Integer;
begin
  Result := FConnessione.ExecSQLScalar('SELECT COUNT(*) FROM T');
end;

procedure TTestEsecuzioneScript.RiprovaUnaVolta(Sender: TObject; const Command: string;
  E: Exception; var Action: TzScriptErrorAction);
begin
  Inc(FTentativi);
  if FTentativi = 1 then
    Action := eaRetry
  else
    Action := eaSkip;
end;

procedure TTestEsecuzioneScript.SenzaConnessione_SollevaEccezione;
var
  SenzaConnessione: TzFbScriptRunner;
begin
  SenzaConnessione := TzFbScriptRunner.Create(nil);
  try
    Assert.WillRaise(
      procedure
      begin
        SenzaConnessione.ExecuteText('SELECT 1 FROM RDB$DATABASE;');
      end, Exception);
  finally
    SenzaConnessione.Free;
  end;
end;

procedure TTestEsecuzioneScript.DirettivaIsql_Saltata;
var
  Esito: TzScriptResult;
begin
  Esito := FEsecutore.ExecuteText('SET SQL DIALECT 3;');

  Assert.AreEqual(1, Esito.Skipped);
  Assert.AreEqual(0, Esito.Executed);
  Assert.IsTrue(Esito.Succeeded);
end;

procedure TTestEsecuzioneScript.ScriptControllato_Interruzione_AnnullaDopoIlCommit;
var
  Esito: TzScriptResult;
begin
  Esito := FEsecutore.ExecuteText(
    'INSERT INTO T VALUES (1);' + sLineBreak +
    'INSERT INTO T VALUES (2);' + sLineBreak +
    'COMMIT;' + sLineBreak +
    'INSERT INTO T VALUES (3);' + sLineBreak +
    'INSERT INTO NONESISTE VALUES (4);');

  Assert.IsTrue(Esito.Aborted);
  Assert.AreEqual(2, RigheInT, 'restano le righe confermate dal COMMIT, la terza viene annullata');
end;

procedure TTestEsecuzioneScript.TransazioneEsterna_CommitDelloScript_NonConferma;
begin
  FEsecutore.TransactionMode := tmExternal;
  FConnessione.StartTransaction;

  FEsecutore.ExecuteText('INSERT INTO T VALUES (1); COMMIT;');

  Assert.IsTrue(FConnessione.InTransaction, 'la transazione del chiamante resta aperta');
  FConnessione.Rollback;
  Assert.AreEqual(0, RigheInT, 'il COMMIT dello script non ha confermato niente');
end;

procedure TTestEsecuzioneScript.ErroreSenzaStopOnError_ProseguePoi_Failed1;
var
  Esito: TzScriptResult;
begin
  FEsecutore.StopOnError := false;

  Esito := FEsecutore.ExecuteText(
    'INSERT INTO NONESISTE VALUES (1);' + sLineBreak +
    'INSERT INTO T VALUES (2);');

  Assert.AreEqual(1, Esito.Failed);
  Assert.AreEqual(1, Esito.Executed);
  Assert.IsFalse(Esito.Succeeded);
  Assert.AreEqual(1, RigheInT);
end;

procedure TTestEsecuzioneScript.Esito_TreInsertEUnCommit;
var
  Esito: TzScriptResult;
begin
  Esito := FEsecutore.ExecuteText(
    'INSERT INTO T VALUES (1); INSERT INTO T VALUES (2); INSERT INTO T VALUES (3); COMMIT;');

  Assert.AreEqual(4, Esito.Total);
  Assert.AreEqual(3, Esito.Executed);
  Assert.AreEqual(1, Esito.Skipped);
  Assert.AreEqual(0, Esito.Failed);
  Assert.IsTrue(Esito.Succeeded);
end;

procedure TTestEsecuzioneScript.RollbackToSavepoint_VaAlServer_TornaAlPunto;
begin
  FEsecutore.ExecuteText(
    'INSERT INTO T VALUES (1);' + sLineBreak +
    'SAVEPOINT PUNTO;' + sLineBreak +
    'INSERT INTO T VALUES (2);' + sLineBreak +
    'ROLLBACK TO SAVEPOINT PUNTO;');

  // Il server torna al punto: resta la riga 1
  Assert.AreEqual(1, RigheInT);
end;

procedure TTestEsecuzioneScript.SetTimeZone_NonEUnaDirettivaIgnorata;
var
  Esito: TzScriptResult;
begin
  // SQLite non conosce il comando e lo rifiuta: basta che il runner non lo salti come direttiva
  Esito := FEsecutore.ExecuteText('SET TIME ZONE ''UTC'';');

  Assert.AreEqual(0, Esito.Skipped, 'il comando arriva al server');
end;

procedure TTestEsecuzioneScript.DIV_SCR_4_Riprova_FailedContaIComandi;
var
  Esito: TzScriptResult;
begin
  FEsecutore.OnError := RiprovaUnaVolta;

  Esito := FEsecutore.ExecuteText('INSERT INTO NONESISTE VALUES (1);');

  Assert.AreEqual(2, FTentativi);
  Assert.AreEqual(1, Esito.Failed, 'un solo comando, che alla fine e'' fallito: Failed conta i comandi');
end;

procedure TTestEsecuzioneScript.SenzaTransazione_IlRunnerNeUsaUnaSua_RollbackFinaleAnnulla;
begin
  // Ne' Transaction del runner ne' Transaction della connessione: il runner ne usa una sua
  FEsecutore.Transaction := nil;
  FConnessione.Transaction := nil;

  FEsecutore.ExecuteText(
    'INSERT INTO T VALUES (1);' + sLineBreak +
    'INSERT INTO NONESISTE VALUES (2);');

  Assert.AreEqual(0, RigheInT, 'lo script e'' abortito e la riga 1 e'' stata annullata');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSpezzaturaScript);
  TDUnitX.RegisterTestFixture(TTestEsecuzioneScript);

end.
