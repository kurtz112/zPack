// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-31
// ---------------------------------------------------------------------------
unit Test.zFbDataSet.Divergenze;

// Prove delle correzioni delle divergenze di zFIB\zFbDataSet raccolte nella voce
// R-196 (rilascio 008): DIV-LOC-1, 2, 3, 4, 8, 9, 10 e 11 (ricerca con SQL),
// DIV-DAT-2 (ValidateKeyFields), DIV-PRE-1 (DisableControlsExt e
// EnableControlsExt a dataset chiuso), DIV-SAL-2 e 3 (AutoCommit dopo Delete e
// operazioni atomiche), DIV-TRA-2 (punto di salvataggio con il nome sbagliato).
// Le prove DIV_* del rilascio 004 affermavano il comportamento difettoso: sono
// state capovolte e ora affermano quello corretto.
//
// Il dataset gira su SQLite in memoria, senza Firebird (come
// Test.zFbDataSet.Predefiniti). La condizione di LocateSQL si legge dal testo
// della SELECT dopo la ricerca, perche' GetLocateSQL e' privata. Su SQLite una
// colonna FLOAT non diventa ftSingle: la prova di DIV-LOC-4 resta non
// applicabile qui. Le stored procedure (DIV-SPR-1 e 5) non si provano senza
// Firebird.

interface

uses
  System.SysUtils,
  System.StrUtils,
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
  zFbDataSet;

type
  [TestFixture]
  TTestDivergenzeZFbDataSet = class
  private
    FConnessione: TFDConnection;
    FDati: TzFbDataSet;
    FTransazione: TzFbTransaction;
    procedure ApriDati;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // DIV-LOC-1
    [Test]
    procedure LocateSQL_NonTrovato_RipristinaElencoERecordCorrente;
    [Test]
    procedure LocateSQL_NonTrovato_ConMantieniElenco_RestaFiltrato;
    // DIV-LOC-2
    [Test]
    procedure LocateSQL_CaseInsensitive_MaiuscoloSuValoreECampo;
    // DIV-LOC-3
    [Test]
    procedure LocateSQL_DataConOra_LaCondizioneHaAncheLOra;
    // DIV-LOC-4
    [Test]
    procedure LocateSQL_Single_ValoreConDecimali_NumeroNonNull;
    // DIV-LOC-8
    [Test]
    procedure LocateSQL_TabellaConAlias_LaCondizioneUsaLAlias;
    // DIV-LOC-9
    [Test]
    procedure LocateSQL_InteroConDecimali_CondizioneNumericaNonNull;
    // DIV-LOC-10
    [Test]
    procedure LocateSQL_Contiene_ProteggeIJolly;
    // DIV-LOC-11
    [Test]
    procedure LocateSQL_StringaVuotaInChiaveComposta_SaltaIlCampo;
    // DIV-DAT-2
    [Test]
    procedure ChiaveInesistente_TieneLeChiaviValide;
    // DIV-PRE-1
    [Test]
    procedure DisableEnableACavalloDiUnaChiusura_ContatoreAllineato;
    // DIV-SAL-2 e 3
    [Test]
    procedure AutoCommit_DopoDelete_ConfermaLaTransazione;
    [Test]
    procedure AutoCommit_DentroOperazioneAtomica_NonConferma;
    // DIV-TRA-2
    [Test]
    procedure PuntoDiSalvataggio_NomeSbagliato_NonAnnullaNiente;
  end;

implementation

{ TTestDivergenzeZFbDataSet }

procedure TTestDivergenzeZFbDataSet.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;

  // INT e non INTEGER: vedi Test.zFbDataSet.Predefiniti
  FConnessione.ExecSQL('CREATE TABLE PERSONE (ID INT NOT NULL PRIMARY KEY, NOME VARCHAR(30), NASCITA TIMESTAMP, PESO FLOAT)');
  FConnessione.ExecSQL('INSERT INTO PERSONE (ID, NOME, NASCITA, PESO) VALUES (1, ''Rossi'', ''2026-12-31 12:30:00'', 2.5)');
  FConnessione.ExecSQL('INSERT INTO PERSONE (ID, NOME, NASCITA, PESO) VALUES (2, ''Bianchi'', ''2026-12-31 00:00:00'', 3)');

  FDati := nil;
  FTransazione := nil;
end;

procedure TTestDivergenzeZFbDataSet.TearDown;
begin
  FDati.Free;
  FTransazione.Free;
  FConnessione.Free;
end;

procedure TTestDivergenzeZFbDataSet.ApriDati;
begin
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.SQL.Text := 'SELECT ID, NOME, NASCITA, PESO FROM PERSONE';
  // senza il testo di partenza LocateSQL non puo' tornare alla SELECT originale
  FDati.DefaultSQL.Text := FDati.SQL.Text;
  FDati.TableName := 'PERSONE';
  FDati.UseSqlLocate := true;
  FDati.Open;
  // Il record corrente non deve gia' essere quello cercato: LocateFound lo
  // riconosce e LocateSQL esce senza toccare la SELECT
  FDati.Last;
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_NonTrovato_RipristinaElencoERecordCorrente;
var
  Trovato: boolean;
begin
  ApriDati;
  FDati.UpdateOptions.KeyFields := 'ID';

  Trovato := FDati.LocateSQL('ID', 99, []);

  Assert.IsFalse(Trovato);
  Assert.AreEqual(2, FDati.RecordCount, 'l''elenco completo e'' tornato');
  Assert.AreEqual(2, FDati.FieldByName('ID').AsInteger, 'il record di prima (l''ultimo) e'' ancora quello corrente');
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_NonTrovato_ConMantieniElenco_RestaFiltrato;
begin
  ApriDati;
  FDati.MantieniElencoSeNonTrova := true;

  FDati.LocateSQL('ID', 99, []);

  Assert.IsTrue(FDati.IsEmpty, 'come vogliono i campi di scelta, il dataset resta filtrato e vuoto');
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_CaseInsensitive_MaiuscoloSuValoreECampo;
var
  Trovato: boolean;
begin
  ApriDati;

  Trovato := FDati.LocateSQL('NOME', 'rossi', [loCaseInsensitive]);

  Assert.IsTrue(ContainsText(FDati.SelectSQL.Text, 'UPPER(''rossi'')'), 'valore in maiuscolo: ' + FDati.SelectSQL.Text);
  Assert.IsTrue(ContainsText(FDati.Where, 'UPPER(PERSONE.NOME)') or ContainsText(FDati.Where, 'UPPER(NOME)'), 'campo in maiuscolo: ' + FDati.Where);
  Assert.IsTrue(Trovato, 'la ricerca trova Rossi qualunque sia la collazione del campo');
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_DataConOra_LaCondizioneHaAncheLOra;
begin
  ApriDati;
  // la condizione si legge dalla SELECT: con la ricerca fallita non verrebbe ripristinata
  FDati.MantieniElencoSeNonTrova := true;

  FDati.LocateSQL('NASCITA', EncodeDate(2026, 12, 31) + EncodeTime(12, 30, 0, 0), []);

  Assert.IsTrue(ContainsText(FDati.SelectSQL.Text, '31.12.2026 12:30:00.000'), 'data e ora nella condizione: ' + FDati.SelectSQL.Text);
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_Single_ValoreConDecimali_NumeroNonNull;
begin
  ApriDati;
  FDati.MantieniElencoSeNonTrova := true;

  if FDati.FieldByName('PESO').DataType <> ftSingle then
  begin
    // SQLite non mappa la colonna su un Single: la prova vale solo su Firebird (colonna FLOAT)
    Assert.Pass('SQLite riporta PESO come ' + FDati.FieldByName('PESO').ClassName + ', non ftSingle: prova non applicabile');
    Exit;
  end;

  FDati.LocateSQL('PESO', 2.5, []);

  Assert.IsTrue(ContainsText(FDati.Where, '= 2.5'), 'un Single con decimali resta un numero: ' + FDati.Where);
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_TabellaConAlias_LaCondizioneUsaLAlias;
begin
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.SQL.Text := 'SELECT P.ID, P.NOME FROM PERSONE P';
  FDati.TableName := 'PERSONE';
  FDati.UseSqlLocate := true;
  FDati.Open;
  FDati.Last;

  FDati.LocateSQL('NOME', 'Rossi', []);

  Assert.IsTrue(ContainsText(FDati.Where, 'P.NOME'), 'la condizione usa l''alias: ' + FDati.Where);
  Assert.IsFalse(ContainsText(FDati.Where, 'PERSONE.NOME'), 'non il nome originale della tabella: ' + FDati.Where);
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_InteroConDecimali_CondizioneNumericaNonNull;
begin
  ApriDati;
  FDati.MantieniElencoSeNonTrova := true;

  FDati.LocateSQL('ID', 2.5, []);

  Assert.IsTrue(ContainsText(FDati.Where, '= 2.5'), 'il decimale resta un numero: ' + FDati.Where);
  Assert.IsFalse(ContainsText(FDati.Where, 'null'), FDati.Where);
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_Contiene_ProteggeIJolly;
begin
  ApriDati;
  FDati.MantieniElencoSeNonTrova := true;

  FDati.LocateSQL('NOME', '50%_*', []);

  Assert.IsTrue(ContainsText(FDati.Where, '''%50\%\_%'''), 'jolly protetti: ' + FDati.Where);
  Assert.IsTrue(ContainsText(FDati.Where, 'ESCAPE'), FDati.Where);
end;

procedure TTestDivergenzeZFbDataSet.LocateSQL_StringaVuotaInChiaveComposta_SaltaIlCampo;
begin
  ApriDati;
  FDati.MantieniElencoSeNonTrova := true;

  FDati.LocateSQL('NOME;ID', VarArrayOf(['', 1]), []);

  Assert.IsFalse(ContainsText(FDati.Where, 'NOME'), 'il campo vuoto e'' saltato: ' + FDati.Where);
  Assert.IsTrue(ContainsText(FDati.Where, 'ID = 1'), FDati.Where);
end;

procedure TTestDivergenzeZFbDataSet.ChiaveInesistente_TieneLeChiaviValide;
var
  I: Integer;
begin
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.SQL.Text := 'SELECT ID, NOME FROM PERSONE';
  FDati.TableName := 'PERSONE';
  FDati.UpdateOptions.KeyFields := 'ID;NONESISTE';
  // campi persistenti: cosi' all'apertura esistono gia' e si possono confrontare con le chiavi
  FDati.FieldDefs.Update;
  for I := 0 to FDati.FieldDefs.Count - 1 do
    FDati.FieldDefs[I].CreateField(FDati);

  FDati.Open;

  Assert.AreEqual('ID', FDati.UpdateOptions.KeyFields);
end;

procedure TTestDivergenzeZFbDataSet.DisableEnableACavalloDiUnaChiusura_ContatoreAllineato;
var
  BlockReadSizeIniziale: Integer;
begin
  ApriDati;
  BlockReadSizeIniziale := FDati.BlockReadSize;

  FDati.DisableControlsExt;
  FDati.Close;
  // Dataset chiuso: EnableControlsExt decrementa comunque il contatore
  FDati.EnableControlsExt;
  FDati.Open;

  // Una coppia nuova: salva i valori di adesso e li rimette
  FDati.DisableControlsExt;
  Assert.AreEqual(MaxInt, FDati.BlockReadSize);
  FDati.EnableControlsExt;

  Assert.AreEqual(BlockReadSizeIniziale, FDati.BlockReadSize, 'BlockReadSize e'' stato ripristinato');
end;

procedure TTestDivergenzeZFbDataSet.AutoCommit_DopoDelete_ConfermaLaTransazione;
begin
  FTransazione := TzFbTransaction.Create(nil);
  FTransazione.Connection := FConnessione;
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.Transaction := FTransazione;
  FDati.UpdateTransaction := FTransazione;
  FDati.SQL.Text := 'SELECT ID, NOME FROM PERSONE';
  FDati.TableName := 'PERSONE';
  FDati.UpdateOptions.KeyFields := 'ID';
  FDati.DeleteSQL.Text := 'DELETE FROM PERSONE WHERE ID = :OLD_ID';
  FDati.AutoCommit := true;
  FDati.Open;
  if not FTransazione.Active then
    FTransazione.StartTransaction;

  FDati.First;
  FDati.Delete;

  Assert.IsFalse(FTransazione.Active, 'la cancellazione e'' stata confermata da AutoCommit');
end;

procedure TTestDivergenzeZFbDataSet.AutoCommit_DentroOperazioneAtomica_NonConferma;
begin
  FTransazione := TzFbTransaction.Create(nil);
  FTransazione.Connection := FConnessione;
  FDati := TzFbDataSet.Create(nil);
  FDati.Connection := FConnessione;
  FDati.Transaction := FTransazione;
  FDati.UpdateTransaction := FTransazione;
  FDati.SQL.Text := 'SELECT ID, NOME FROM PERSONE';
  FDati.TableName := 'PERSONE';
  FDati.UpdateOptions.KeyFields := 'ID';
  FDati.DeleteSQL.Text := 'DELETE FROM PERSONE WHERE ID = :OLD_ID';
  FDati.AutoCommit := true;
  FDati.Open;
  if not FTransazione.Active then
    FTransazione.StartTransaction;

  FTransazione.BeginOperazioneAtomica;
  try
    FDati.First;
    FDati.Delete;
    Assert.IsTrue(FTransazione.Active, 'dentro l''operazione atomica la transazione resta aperta');
  finally
    FTransazione.EndOperazioneAtomica;
  end;
  Assert.IsFalse(FTransazione.OperazioneAtomicaAperta);
end;

procedure TTestDivergenzeZFbDataSet.PuntoDiSalvataggio_NomeSbagliato_NonAnnullaNiente;
begin
  FTransazione := TzFbTransaction.Create(nil);
  FTransazione.Connection := FConnessione;
  FTransazione.SetSavePoint('Primo');

  Assert.WillRaise(
    procedure
    begin
      FTransazione.RollBackToSavePoint('Altro');
    end, Exception);

  // il punto giusto e' ancora l'ultimo: ora l'annullamento funziona
  FTransazione.RollBackToSavePoint('Primo');
  Assert.Pass;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestDivergenzeZFbDataSet);

end.
