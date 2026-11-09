// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-22
// ---------------------------------------------------------------------------

unit Test.zFbDataSet.CampiBinari;

// Test di zFIB\zFbDataSet: il testo di un campo binario e' il suo valore in
// esadecimale, non la descrizione del tipo.
//
// E' il difetto del ticket 274 (CAPAC): le colonne del dominio UUID,
// CHAR(16) CHARACTER SET OCTETS, diventano TBytesField in FireDAC, e
// TBinaryField.GetText di Data.DB restituisce "(BYTES)". Schede e griglie
// mostravano quella scritta al posto del valore.
//
// Il dataset gira su SQLite in memoria, senza Firebird, come in
// Test.zFbDataSet.Predefiniti: una colonna BINARY(16) di SQLite diventa un
// campo binario di FireDAC, che e' il caso da provare.

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
  TTestCampiBinariZFbDataSet = class
  private
    FConnessione: TFDConnection;
    FDati: TzFbDataSet;
    procedure Prepara;
    procedure GuidGetTextProprio(Sender: TField; var Text: string; DisplayText: boolean);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Mantis #274 - 2026-10-22: valore vuoto, testo vuoto
    [Test]
    procedure TestoEsadecimale_Vuoto;
    // Mantis #274 - 2026-10-22: un UUID di 16 byte diventa 32 cifre maiuscole
    [Test]
    procedure TestoEsadecimale_Uuid;
    // Mantis #274 - 2026-10-22: gli zeri a sinistra di ogni byte restano
    [Test]
    procedure TestoEsadecimale_ZeriIniziali;
    // Mantis #274 - 2026-10-22: il caso del ticket, campo nato dentro l'apertura
    [Test]
    procedure CampiAutomatici_Valorizzato_Esadecimale;
    // Mantis #274 - 2026-10-22: stesso caso sui campi creati da BuildFields
    [Test]
    procedure CampiPersistenti_Valorizzato_Esadecimale;
    // Mantis #274 - 2026-10-22: un campo nullo non mostra niente
    [Test]
    procedure CampoNullo_TestoVuoto;
    // Mantis #274 - 2026-10-22: un gestore messo dal codice applicativo resta
    [Test]
    procedure GestoreProprio_NonSovrascritto;
  end;

implementation

const
  UuidEsadecimale = '9B1DEB4D3B7D4BAD9BDD2B0D7B3DCB6D';

{ TTestCampiBinariZFbDataSet }

procedure TTestCampiBinariZFbDataSet.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;

  // INT e non INTEGER: in SQLite "INTEGER PRIMARY KEY" e' il contatore della
  // riga, che FireDAC tratta come autoincremento in sola lettura
  FConnessione.ExecSQL('CREATE TABLE LOGS_ATTIVITA (ID INT NOT NULL PRIMARY KEY, GUID_ATTIVITA BINARY(16))');
  FConnessione.ExecSQL('INSERT INTO LOGS_ATTIVITA (ID, GUID_ATTIVITA) VALUES (1, X''' + UuidEsadecimale + ''')');
  FConnessione.ExecSQL('INSERT INTO LOGS_ATTIVITA (ID, GUID_ATTIVITA) VALUES (2, NULL)');

  FDati := nil;
end;

procedure TTestCampiBinariZFbDataSet.TearDown;
begin
  FDati.Free;
  FConnessione.Free;
end;

procedure TTestCampiBinariZFbDataSet.Prepara;
begin
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.SQL.Text := 'SELECT ID, GUID_ATTIVITA FROM LOGS_ATTIVITA ORDER BY ID';
  FDati.TableName := 'LOGS_ATTIVITA';
end;

procedure TTestCampiBinariZFbDataSet.GuidGetTextProprio(Sender: TField; var Text: string; DisplayText: boolean);
begin
  Text := 'proprio';
end;

procedure TTestCampiBinariZFbDataSet.TestoEsadecimale_Vuoto;
begin
  Assert.AreEqual('', TestoEsadecimale(nil));
end;

procedure TTestCampiBinariZFbDataSet.TestoEsadecimale_Uuid;
var
  Valore: TBytes;
begin
  Valore := TBytes.Create($9B, $1D, $EB, $4D, $3B, $7D, $4B, $AD, $9B, $DD, $2B, $0D, $7B, $3D, $CB, $6D);

  Assert.AreEqual(UuidEsadecimale, TestoEsadecimale(Valore));
end;

procedure TTestCampiBinariZFbDataSet.TestoEsadecimale_ZeriIniziali;
begin
  Assert.AreEqual('000A', TestoEsadecimale(TBytes.Create($00, $0A)));
end;

procedure TTestCampiBinariZFbDataSet.CampiAutomatici_Valorizzato_Esadecimale;
var
  Guid: TField;
begin
  Prepara;
  FDati.Open;
  Guid := FDati.FieldByName('GUID_ATTIVITA');

  Assert.IsTrue(Guid is TBinaryField, 'SQLite deve dare un campo binario, non ' + Guid.ClassName);
  Assert.AreEqual(UuidEsadecimale, Guid.DisplayText);
  Assert.AreEqual(UuidEsadecimale, Guid.Text);
end;

procedure TTestCampiBinariZFbDataSet.CampiPersistenti_Valorizzato_Esadecimale;
var
  Guid: TField;
begin
  Prepara;
  FDati.BuildFields;
  FDati.Open;
  Guid := FDati.FieldByName('GUID_ATTIVITA');

  Assert.IsTrue(Guid is TBinaryField, 'SQLite deve dare un campo binario, non ' + Guid.ClassName);
  Assert.AreEqual(UuidEsadecimale, Guid.DisplayText);
end;

procedure TTestCampiBinariZFbDataSet.CampoNullo_TestoVuoto;
begin
  Prepara;
  FDati.Open;
  FDati.Last;

  Assert.IsTrue(FDati.FieldByName('GUID_ATTIVITA').IsNull, 'la seconda riga deve avere il GUID nullo');
  Assert.AreEqual('', FDati.FieldByName('GUID_ATTIVITA').DisplayText);
end;

procedure TTestCampiBinariZFbDataSet.GestoreProprio_NonSovrascritto;
begin
  // Un DataModule che assegna il suo OnGetText deve trovarlo ancora dopo la
  // riapertura, che e' il momento in cui i campi vengono ricreati
  Prepara;
  FDati.BuildFields;
  FDati.FieldByName('GUID_ATTIVITA').OnGetText := GuidGetTextProprio;
  FDati.Open;
  FDati.Close;
  FDati.Open;

  Assert.AreEqual('proprio', FDati.FieldByName('GUID_ATTIVITA').DisplayText);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCampiBinariZFbDataSet);

end.
