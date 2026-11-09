// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zSystem.Sistema;

// Prove di TzSystem (zSystem.pas) che non richiedono il database, per le
// specifiche "Impostazioni e cartelle" (ZBASE-CFG) e "Ciclo di vita e
// archivio LZ" (ZBASE-AVV):
// - cartelle derivate (Root_*, ConfigFolder, PersonalFolder, ConfigFileName) a
//   utente non collegato e a utente collegato;
// - Folder quando la procedura del database non risponde;
// - oggetto unico, nome predefinito del file .LZ, Login senza database;
// - precondizioni di SaveZipUnattended e casi in cui SaveZip non scrive.
//
// TzSystem e' un oggetto unico di processo (la variabile Base): ogni prova ne
// crea uno in Setup e lo libera in TearDown, quindi i test non possono girare
// in parallelo con altri che creano un TzSystem. L'utente collegato si simula
// con LoginParams.SetParams, senza passare dal database.
//
// Le cartelle derivate finiscono in una cartella temporanea: prima di
// chiamarle si mette in memoria la radice con Folder(Nome, Radice), che senza
// database restituisce il predefinito e lo ricorda (ZBASE-CFG-004, punti 3 e
// 4). Tutto cio' che le prove creano si toglie in TearDown.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Vcl.Forms,
  DUnitX.TestFramework,
  zSystem;

type
  // zLoaded e' protetta: serve per simulare un dizionario gia' caricato
  TzSystemAccesso = class(TzSystem)
  public
    procedure ImpostaCaricato(const Valore: Boolean);
  end;

  [TestFixture]
  TTestSistemaSenzaDatabase = class
  private
    FSistema: TzSystemAccesso;
    FCartellaTemporanea: string;
    procedure Accesso(const Utente: string; const Amministratore: Boolean = False);
    function MessaggioDi(const Procedura: TProc): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-CFG-004
    [Test]
    procedure Folder_SenzaDatabase_RestituisceIlPredefinito;
    // ZBASE-CFG-004
    [Test]
    procedure Folder_SenzaDatabaseEPredefinitoVuoto_Vuoto;
    // ZBASE-CFG-005
    [Test]
    procedure RadiciDelleCartelle_SenzaAccesso_Vuote;
    // ZBASE-CFG-005
    [Test]
    procedure Root_Config_ConAccesso_RadiceConfigurataConSeparatoreFinale;
    // ZBASE-CFG-005
    [Test]
    procedure Root_Files_ConAccesso_CreaLaCartella;
    // ZBASE-CFG-006
    [Test]
    procedure ConfigFolder_SenzaAccesso_Vuota;
    // ZBASE-CFG-006
    [Test]
    procedure PersonalFolder_SenzaAccesso_Vuota;
    // ZBASE-CFG-006
    [Test]
    procedure ConfigFileName_SenzaAccesso_Vuoto;
    // ZBASE-CFG-006
    [Test]
    procedure ConfigFolder_ConAccesso_CartellaDellUtenteCreata;
    // ZBASE-CFG-006
    [Test]
    procedure PersonalFolder_ConAccesso_CartellaDellUtenteCreata;
    // ZBASE-CFG-006
    [Test]
    procedure ConfigFileName_ConAccesso_NomeDellEseguibileConLEstensioneData;

    // ZBASE-AVV-001
    [Test]
    procedure Create_SecondoComponente_SollevaSingleton;
    // ZBASE-AVV-003
    [Test]
    procedure Login_DatabaseNonAssegnato_Solleva;
    // ZBASE-AVV-004
    [Test]
    procedure FileName_NonAssegnato_NomeDellEseguibileConEstensioneLZ;
    // ZBASE-AVV-004
    [Test]
    procedure FileName_SoloSpazi_UsaIlPredefinito;
    // ZBASE-AVV-004
    [Test]
    procedure FileName_Assegnato_VieneRestituito;
    // ZBASE-AVV-006
    [Test]
    procedure SaveZip_SenzaAccesso_NonScriveEAzzeraModified;
    // ZBASE-AVV-006
    [Test]
    procedure SaveZip_NonAmministratoreConFileEsistente_NonCambiaIlFile;
    // ZBASE-AVV-006
    [Test]
    procedure SaveZip_DizionarioNonCaricato_NonCambiaIlFile;
    // ZBASE-AVV-008
    [Test]
    procedure SaveZipUnattended_DizionarioNonCaricato_Solleva;
    // ZBASE-AVV-008
    [Test]
    procedure SaveZipUnattended_DizionarioCaricato_ScriveEMetteLaCopiaAccantoAllArchivio;
    // ZBASE-INI-001
    [Test]
    procedure UpdateFromDB_DatabaseNonAssegnato_Solleva;
  end;

implementation

{ TzSystemAccesso }

procedure TzSystemAccesso.ImpostaCaricato(const Valore: Boolean);
begin
  zLoaded := Valore;
end;

{ TTestSistemaSenzaDatabase }

procedure TTestSistemaSenzaDatabase.Setup;
begin
  FSistema := TzSystemAccesso.Create(nil);

  FCartellaTemporanea := TPath.Combine(TPath.GetTempPath, 'zPackTest_' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FCartellaTemporanea);
end;

procedure TTestSistemaSenzaDatabase.TearDown;
begin
  FreeAndNil(FSistema);

  if TDirectory.Exists(FCartellaTemporanea) then
    TDirectory.Delete(FCartellaTemporanea, True);
end;

procedure TTestSistemaSenzaDatabase.Accesso(const Utente: string; const Amministratore: Boolean);
begin
  // stessa chiamata che TzSecurity.doLogin fa dopo USR_LOGIN
  FSistema.zSecurity.LoginParams.SetParams('Prova', Utente, '', 1, 1, Utente, Date + 30, Amministratore, False, False, False);
end;

function TTestSistemaSenzaDatabase.MessaggioDi(const Procedura: TProc): string;
begin
  result := '<nessuna eccezione>';
  try
    Procedura();
  except
    on E: Exception do
      result := E.Message;
  end;
end;

procedure TTestSistemaSenzaDatabase.Folder_SenzaDatabase_RestituisceIlPredefinito;
var
  Predefinita: string;
begin
  Predefinita := TPath.Combine(FCartellaTemporanea, 'Prova');

  Assert.AreEqual(Predefinita, FSistema.Folder('CARTELLA_PROVA', Predefinita));
end;

procedure TTestSistemaSenzaDatabase.Folder_SenzaDatabaseEPredefinitoVuoto_Vuoto;
begin
  Assert.AreEqual('', FSistema.Folder('CARTELLA_PROVA', ''));
end;

procedure TTestSistemaSenzaDatabase.RadiciDelleCartelle_SenzaAccesso_Vuote;
begin
  Assert.AreEqual('', FSistema.Root_Config, 'Root_Config');
  Assert.AreEqual('', FSistema.Root_PersonalData, 'Root_PersonalData');
  Assert.AreEqual('', FSistema.Root_Files, 'Root_Files');
end;

procedure TTestSistemaSenzaDatabase.Root_Config_ConAccesso_RadiceConfigurataConSeparatoreFinale;
var
  Radice: string;
begin
  Radice := TPath.Combine(FCartellaTemporanea, 'Config');
  FSistema.Folder('ROOT_CONFIG', Radice);
  Accesso('MARIO');

  Assert.AreEqual(IncludeTrailingPathDelimiter(Radice), FSistema.Root_Config);
  Assert.IsTrue(TDirectory.Exists(Radice), 'la cartella della radice esiste');
end;

procedure TTestSistemaSenzaDatabase.Root_Files_ConAccesso_CreaLaCartella;
var
  Radice: string;
begin
  Radice := TPath.Combine(FCartellaTemporanea, 'FileApplicazione');
  FSistema.Folder('ROOT_APP_FILES', Radice);
  Accesso('MARIO');

  Assert.AreEqual(IncludeTrailingPathDelimiter(Radice), FSistema.Root_Files);
  Assert.IsTrue(TDirectory.Exists(Radice));
end;

procedure TTestSistemaSenzaDatabase.ConfigFolder_SenzaAccesso_Vuota;
begin
  Assert.AreEqual('', FSistema.ConfigFolder);
end;

procedure TTestSistemaSenzaDatabase.PersonalFolder_SenzaAccesso_Vuota;
begin
  Assert.AreEqual('', FSistema.PersonalFolder);
end;

procedure TTestSistemaSenzaDatabase.ConfigFileName_SenzaAccesso_Vuoto;
begin
  Assert.AreEqual('', FSistema.ConfigFileName('.Settings'));
end;

procedure TTestSistemaSenzaDatabase.ConfigFolder_ConAccesso_CartellaDellUtenteCreata;
var
  Radice, Atteso: string;
begin
  Radice := TPath.Combine(FCartellaTemporanea, 'Config');
  FSistema.Folder('ROOT_CONFIG', Radice);
  Accesso('MARIO');

  Atteso := IncludeTrailingPathDelimiter(TPath.Combine(Radice, 'MARIO'));

  Assert.AreEqual(Atteso, FSistema.ConfigFolder);
  Assert.IsTrue(TDirectory.Exists(Atteso), 'la cartella dell''utente esiste');
end;

procedure TTestSistemaSenzaDatabase.PersonalFolder_ConAccesso_CartellaDellUtenteCreata;
var
  Radice, Atteso: string;
begin
  Radice := TPath.Combine(FCartellaTemporanea, 'DatiPersonali');
  FSistema.Folder('ROOT_PERSONAL_DATA', Radice);
  Accesso('MARIO');

  Atteso := IncludeTrailingPathDelimiter(TPath.Combine(Radice, 'MARIO'));

  Assert.AreEqual(Atteso, FSistema.PersonalFolder);
  Assert.IsTrue(TDirectory.Exists(Atteso));
end;

procedure TTestSistemaSenzaDatabase.ConfigFileName_ConAccesso_NomeDellEseguibileConLEstensioneData;
var
  Radice, Atteso: string;
begin
  Radice := TPath.Combine(FCartellaTemporanea, 'Config');
  FSistema.Folder('ROOT_CONFIG', Radice);
  Accesso('MARIO');

  Atteso := IncludeTrailingPathDelimiter(TPath.Combine(Radice, 'MARIO')) + ChangeFileExt(ExtractFileName(Application.ExeName), '.Settings');

  Assert.AreEqual(Atteso, FSistema.ConfigFileName('.Settings'));
end;

procedure TTestSistemaSenzaDatabase.Create_SecondoComponente_SollevaSingleton;
begin
  // dopo questo tentativo Base resta nil (DIV-AVV-1): TearDown libera
  // comunque il primo componente
  Assert.AreEqual('TzSystem Singleton',
    MessaggioDi(
      procedure
      begin
        TzSystem.Create(nil).Free;
      end));
end;

procedure TTestSistemaSenzaDatabase.Login_DatabaseNonAssegnato_Solleva;
begin
  Assert.AreEqual('Database non assegnato',
    MessaggioDi(
      procedure
      begin
        FSistema.Login(False);
      end));
end;

procedure TTestSistemaSenzaDatabase.FileName_NonAssegnato_NomeDellEseguibileConEstensioneLZ;
begin
  Assert.AreEqual(ChangeFileExt(Application.ExeName, '.LZ'), FSistema.FileName);
end;

procedure TTestSistemaSenzaDatabase.FileName_SoloSpazi_UsaIlPredefinito;
begin
  FSistema.FileName := '   ';

  Assert.AreEqual(ChangeFileExt(Application.ExeName, '.LZ'), FSistema.FileName);
end;

procedure TTestSistemaSenzaDatabase.FileName_Assegnato_VieneRestituito;
var
  Nome: string;
begin
  Nome := TPath.Combine(FCartellaTemporanea, 'prova.lz');
  FSistema.FileName := Nome;

  Assert.AreEqual(Nome, FSistema.FileName);
end;

procedure TTestSistemaSenzaDatabase.SaveZip_SenzaAccesso_NonScriveEAzzeraModified;
begin
  FSistema.FileName := TPath.Combine(FCartellaTemporanea, 'prova.lz');
  FSistema.ImpostaCaricato(True);
  FSistema.Modified := True;

  FSistema.SaveZip(csAll, 'prova');

  Assert.IsFalse(FSistema.Modified, 'il segno modificato si azzera comunque');
  Assert.IsFalse(TFile.Exists(FSistema.FileName), 'senza utente collegato non si scrive');
end;

procedure TTestSistemaSenzaDatabase.SaveZip_NonAmministratoreConFileEsistente_NonCambiaIlFile;
begin
  FSistema.FileName := TPath.Combine(FCartellaTemporanea, 'prova.lz');
  TFile.WriteAllText(FSistema.FileName, 'ORIGINALE');
  FSistema.ImpostaCaricato(True);
  Accesso('MARIO', False);

  FSistema.SaveZip(csAll, 'prova');

  Assert.AreEqual('ORIGINALE', TFile.ReadAllText(FSistema.FileName));
end;

procedure TTestSistemaSenzaDatabase.SaveZip_DizionarioNonCaricato_NonCambiaIlFile;
begin
  FSistema.FileName := TPath.Combine(FCartellaTemporanea, 'prova.lz');
  TFile.WriteAllText(FSistema.FileName, 'ORIGINALE');
  FSistema.ImpostaCaricato(False);
  Accesso('MARIO', True);

  FSistema.SaveZip(csAll, 'prova');

  Assert.AreEqual('ORIGINALE', TFile.ReadAllText(FSistema.FileName));
end;

procedure TTestSistemaSenzaDatabase.SaveZipUnattended_DizionarioNonCaricato_Solleva;
begin
  FSistema.FileName := TPath.Combine(FCartellaTemporanea, 'prova.lz');

  Assert.AreEqual('SaveZipUnattended: dizionario non caricato, l''archivio non si salva',
    MessaggioDi(
      procedure
      begin
        FSistema.SaveZipUnattended(csAll, 'prova', 'zBuilder');
      end));
  Assert.IsFalse(TFile.Exists(FSistema.FileName));
end;

procedure TTestSistemaSenzaDatabase.SaveZipUnattended_DizionarioCaricato_ScriveEMetteLaCopiaAccantoAllArchivio;
var
  CartellaCopie: string;
begin
  // dizionario vuoto ma caricato: la scrittura crea l'archivio; al secondo
  // salvataggio il file esistente finisce in BackupLZ accanto all'archivio
  FSistema.FileName := TPath.Combine(FCartellaTemporanea, 'prova.lz');
  FSistema.ImpostaCaricato(True);
  CartellaCopie := TPath.Combine(FCartellaTemporanea, 'BackupLZ');

  FSistema.SaveZipUnattended(csAll, 'primo', 'zBuilder');
  Assert.IsTrue(TFile.Exists(FSistema.FileName), 'archivio creato');
  Assert.AreEqual(0, Length(TDirectory.GetFiles(CartellaCopie)), 'nessuna copia al primo salvataggio');

  FSistema.SaveZipUnattended(csAll, 'secondo', 'zBuilder');
  Assert.AreEqual(1, Length(TDirectory.GetFiles(CartellaCopie)), 'una copia al secondo salvataggio');
end;

procedure TTestSistemaSenzaDatabase.UpdateFromDB_DatabaseNonAssegnato_Solleva;
begin
  Assert.AreEqual('UpdateFromDB: database non assegnato',
    MessaggioDi(
      procedure
      begin
        FSistema.UpdateFromDB(nil, nil, nil);
      end));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSistemaSenzaDatabase);

end.
