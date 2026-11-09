// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zExceptions.Firedac;

// Prove del contesto degli errori di zExceptions.firedac (specifica "Contesto
// degli errori", ZFIB-ERR, divergenza DIV-ERR-4): DumpDataSet, la riga SQL con i
// parametri sostituiti, CaptureFailedDataSet e HandleDataSetError.
//
// Il dataset gira su SQLite in memoria, senza Firebird. Restano fuori dalle
// prove il dump di una stored procedure e la ricostruzione della DML su un
// conflitto di aggiornamento, che richiedono Firebird (sandbox.md punto 8).

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
  zFbDataSet,
  zExceptions.context,
  zExceptions.firedac;

type
  [TestFixture]
  TTestContestoErroriFiredac = class
  private
    FConnessione: TFDConnection;
    FQuery: TFDQuery;
    function NuovaQuery(const TestoSql: string): TFDQuery;
    procedure Contiene(const Cercato, Testo, Messaggio: string);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // DumpDataSet
    [Test]
    procedure DumpDataSet_Nil_RispondeSenzaSollevare;
    [Test]
    procedure DumpDataSet_QueryNonAttiva_RiportaSqlEDatasetNonAttivo;
    [Test]
    procedure DumpDataSet_QueryAttiva_RiportaIlRecordCorrente;
    // riga SQL con i parametri sostituiti
    [Test]
    procedure RigaLetterale_Stringa_RaddoppiaGliApici;
    [Test]
    procedure RigaLetterale_DataNumeriENullo_FormatoInvariante;
    [Test]
    procedure RigaLetterale_ParametriConPrefissoComune_NonSiScambiano;
    [Test]
    procedure RigaLetterale_ValoreConDollaro_RestaIntatto;
    // CaptureFailedDataSet
    [Test]
    procedure Capture_SenzaNulla_ScriveIlMessaggioDiRipiego;
    [Test]
    procedure Capture_ConUnDataSet_RiportaIlSuoSql;
    [Test]
    procedure Capture_AperturaInCorso_LeggeEConsumaIlDataSet;
    // HandleDataSetError e finestra di validita' del suo dump (DIV-ERR-2)
    [Test]
    procedure Gestore_ScriveDumpENomeDelDataSet;
    [Test]
    procedure Gestore_DumpRecenteNonRiscritto_PoiScadeEDiventaRiscrivibile;
  end;

implementation

{ TTestContestoErroriFiredac }

procedure TTestContestoErroriFiredac.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;

  FConnessione.ExecSQL('CREATE TABLE PERSONE (ID INT NOT NULL PRIMARY KEY, NOME VARCHAR(30), NASCITA TIMESTAMP, PESO FLOAT)');
  FConnessione.ExecSQL('INSERT INTO PERSONE (ID, NOME, NASCITA, PESO) VALUES (1, ''Rossi'', ''2026-12-31 12:30:00'', 2.5)');

  FQuery := nil;

  // nessun avanzo di un errore precedente
  zExceptions.context.TakeLastFailedDataSetDump;
  zExceptions.context.TakeLastFailedDataSetName;
  zExceptions.context.TakeLastFailedDataSetId;
  zExceptions.context.TakeLastFailedDataSetOwnerModuleName;
  zExceptions.context.TakeLastFailedDataSetDataModuleName;
  zFbDataSet.CurrentOpeningDataSet := nil;
end;

procedure TTestContestoErroriFiredac.TearDown;
begin
  zFbDataSet.CurrentOpeningDataSet := nil;
  zExceptions.context.TakeLastFailedDataSetDump;
  zExceptions.context.TakeLastFailedDataSetName;
  zExceptions.context.TakeLastFailedDataSetId;
  zExceptions.context.TakeLastFailedDataSetOwnerModuleName;
  zExceptions.context.TakeLastFailedDataSetDataModuleName;
  FQuery.Free;
  FConnessione.Free;
end;

function TTestContestoErroriFiredac.NuovaQuery(const TestoSql: string): TFDQuery;
begin
  FQuery.Free;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnessione;
  FQuery.SQL.Text := TestoSql;
  Result := FQuery;
end;

procedure TTestContestoErroriFiredac.Contiene(const Cercato, Testo, Messaggio: string);
begin
  Assert.IsTrue(Pos(Cercato, Testo) > 0, Messaggio + ': manca "' + Cercato + '" in: ' + Testo);
end;

procedure TTestContestoErroriFiredac.DumpDataSet_Nil_RispondeSenzaSollevare;
begin
  Assert.AreEqual('(dataset = nil)', DumpDataSet(nil));
end;

procedure TTestContestoErroriFiredac.DumpDataSet_QueryNonAttiva_RiportaSqlEDatasetNonAttivo;
var
  Dump: string;
begin
  NuovaQuery('SELECT ID, NOME FROM PERSONE');

  Dump := DumpDataSet(FQuery);

  Contiene('TFDQuery', Dump, 'il nome della classe');
  Contiene('SELECT ID, NOME FROM PERSONE', Dump, 'il testo SQL');
  Contiene('dataset non attivo', Dump, 'nessun record da riportare');
end;

procedure TTestContestoErroriFiredac.DumpDataSet_QueryAttiva_RiportaIlRecordCorrente;
var
  Dump: string;
begin
  NuovaQuery('SELECT ID, NOME FROM PERSONE');
  FQuery.Open;

  Dump := DumpDataSet(FQuery);

  Contiene('Rossi', Dump, 'il valore del campo NOME del record corrente');
  Assert.IsTrue(Pos('dataset non attivo', Dump) = 0, 'un dataset attivo non e'' segnalato come non attivo');
end;

procedure TTestContestoErroriFiredac.RigaLetterale_Stringa_RaddoppiaGliApici;
var
  Dump: string;
begin
  NuovaQuery('SELECT ID FROM PERSONE WHERE NOME = :NOME');
  FQuery.Params[0].DataType := ftString;
  FQuery.Params[0].AsString := 'D''Angelo';

  Dump := DumpDataSet(FQuery);

  Contiene('WHERE NOME = ''D''''Angelo''', Dump, 'la riga SQL per IBExpert');
end;

procedure TTestContestoErroriFiredac.RigaLetterale_DataNumeriENullo_FormatoInvariante;
var
  Dump: string;
begin
  NuovaQuery('SELECT ID FROM PERSONE WHERE NASCITA > :DATA AND PESO > :PESO AND ID <> :ID AND NOME <> :VUOTO');
  FQuery.ParamByName('DATA').DataType := ftDateTime;
  FQuery.ParamByName('DATA').AsDateTime := EncodeDate(2026, 12, 31) + EncodeTime(12, 30, 0, 0);
  FQuery.ParamByName('PESO').DataType := ftFloat;
  FQuery.ParamByName('PESO').AsFloat := 2.5;
  FQuery.ParamByName('ID').DataType := ftInteger;
  FQuery.ParamByName('ID').AsInteger := 7;
  FQuery.ParamByName('VUOTO').DataType := ftString;
  FQuery.ParamByName('VUOTO').Clear;

  Dump := DumpDataSet(FQuery);

  // data con trattini e due punti, decimali con il punto qualunque sia la lingua del sistema
  Contiene('NASCITA > ''2026-12-31 12:30:00''', Dump, 'la data');
  Contiene('PESO > 2.5', Dump, 'il numero con decimali');
  Contiene('ID <> 7', Dump, 'l''intero');
  Contiene('NOME <> NULL', Dump, 'il valore nullo');
end;

procedure TTestContestoErroriFiredac.RigaLetterale_ParametriConPrefissoComune_NonSiScambiano;
var
  Dump: string;
begin
  NuovaQuery('SELECT ID FROM PERSONE WHERE ID = :ID OR ID = :ID2');
  FQuery.ParamByName('ID').DataType := ftInteger;
  FQuery.ParamByName('ID').AsInteger := 1;
  FQuery.ParamByName('ID2').DataType := ftInteger;
  FQuery.ParamByName('ID2').AsInteger := 2;

  Dump := DumpDataSet(FQuery);

  Contiene('WHERE ID = 1 OR ID = 2', Dump, ':ID non sostituisce l''inizio di :ID2');
end;

procedure TTestContestoErroriFiredac.RigaLetterale_ValoreConDollaro_RestaIntatto;
var
  Dump: string;
begin
  NuovaQuery('SELECT ID FROM PERSONE WHERE NOME = :NOME');
  FQuery.Params[0].DataType := ftString;
  FQuery.Params[0].AsString := 'a$1b';

  Dump := DumpDataSet(FQuery);

  // un $ non deve diventare un riferimento a un gruppo dell'espressione regolare
  Contiene('WHERE NOME = ''a$1b''', Dump, 'il valore con il dollaro');
end;

procedure TTestContestoErroriFiredac.Capture_SenzaNulla_ScriveIlMessaggioDiRipiego;
begin
  CaptureFailedDataSet(nil, nil);

  Assert.IsTrue(zExceptions.context.HasLastFailedDataSetDump, 'la sezione del log non sparisce');
end;

procedure TTestContestoErroriFiredac.Capture_ConUnDataSet_RiportaIlSuoSql;
begin
  NuovaQuery('SELECT ID, NOME FROM PERSONE');
  FQuery.Name := 'qProva';

  CaptureFailedDataSet(nil, FQuery);

  Contiene('SELECT ID, NOME FROM PERSONE', zExceptions.context.PeekLastFailedDataSetDump, 'il dump del dataset responsabile');
  Assert.AreEqual('qProva', zExceptions.context.TakeLastFailedDataSetName);
end;

procedure TTestContestoErroriFiredac.Capture_AperturaInCorso_LeggeEConsumaIlDataSet;
var
  DataSetInApertura: TzFbDataSet;
begin
  // DIV-ERR-1: se l'iniziatore non e' un dataset, il responsabile e' quello che
  // ha dichiarato di essere in apertura; la traccia si consuma subito
  DataSetInApertura := TzFbDataSet.Create(nil);
  try
    DataSetInApertura.Connection := FConnessione;
    DataSetInApertura.SQL.Text := 'SELECT ID FROM PERSONE WHERE ID = 1';
    zFbDataSet.CurrentOpeningDataSet := DataSetInApertura;

    CaptureFailedDataSet(nil, nil);

    Contiene('SELECT ID FROM PERSONE WHERE ID = 1', zExceptions.context.PeekLastFailedDataSetDump, 'il dataset in apertura');
    Assert.IsNull(zFbDataSet.CurrentOpeningDataSet, 'la traccia e'' consumata');
  finally
    zFbDataSet.CurrentOpeningDataSet := nil;
    DataSetInApertura.Free;
  end;
end;

procedure TTestContestoErroriFiredac.Gestore_ScriveDumpENomeDelDataSet;
var
  Eccezione: Exception;
begin
  NuovaQuery('SELECT ID FROM PERSONE');
  FQuery.Name := 'qGestore';
  Eccezione := nil;

  DataSetErrorHandler.HandleDataSetError(FQuery, nil, Eccezione);

  Contiene('SELECT ID FROM PERSONE', zExceptions.context.PeekLastFailedDataSetDump, 'il dump del dataset');
  Assert.AreEqual('qGestore', zExceptions.context.TakeLastFailedDataSetName);
  Assert.IsNull(Eccezione, 'il gestore non tocca l''eccezione');
end;

procedure TTestContestoErroriFiredac.Gestore_DumpRecenteNonRiscritto_PoiScadeEDiventaRiscrivibile;
var
  Eccezione: Exception;
  Altra: TFDQuery;
begin
  // DIV-ERR-2: il dump del gestore vale per due secondi; dopo, Capture lo riscrive
  NuovaQuery('SELECT ID FROM PERSONE');
  Eccezione := nil;
  DataSetErrorHandler.HandleDataSetError(FQuery, nil, Eccezione);

  Altra := TFDQuery.Create(nil);
  try
    Altra.Connection := FConnessione;
    Altra.SQL.Text := 'SELECT NOME FROM PERSONE';

    CaptureFailedDataSet(nil, Altra);
    Contiene('SELECT ID FROM PERSONE', zExceptions.context.PeekLastFailedDataSetDump, 'entro la finestra resta il dump del gestore');
    Assert.IsTrue(Pos('SELECT NOME FROM PERSONE', zExceptions.context.PeekLastFailedDataSetDump) = 0, 'entro la finestra non e'' riscritto');

    Sleep(2200);

    CaptureFailedDataSet(nil, Altra);
    Contiene('SELECT NOME FROM PERSONE', zExceptions.context.PeekLastFailedDataSetDump, 'scaduta la finestra il dump si riscrive');
  finally
    Altra.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestContestoErroriFiredac);

end.
