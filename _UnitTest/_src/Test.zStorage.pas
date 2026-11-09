// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zStorage;

// Test DUnitX di zBase\zStorage.pas: archivio di posizione, dimensione e stato
// delle finestre per profilo di schermo (specifica ZBASE-STO, "Archivio delle
// impostazioni.md").
//
// Si provano le quattro funzioni pubbliche su un TPanel e su una TForm mai
// mostrati (nessuna finestra visibile) con un file .ini nella cartella
// temporanea. Le regole di posizione stanno in funzioni della sezione di
// implementazione, non raggiungibili dai test: si provano attraverso
// LoadControlFromIni su una form, confrontando i limiti con l'area utile del
// monitor principale (Screen.PrimaryMonitor.WorkareaRect).
//
// Restano fuori dalle prove i divisori (TcxSplitter, ZBASE-STO-006), che
// richiedono finestre vere, il controllo IsIconic e la scelta del monitor della
// finestra principale (assente in un programma di prova).
//
// La divergenza DIV-STO-2 e' fotografata col comportamento di oggi: il test va
// capovolto quando il codice e' corretto.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IniFiles,
  System.IOUtils,
  System.Math,
  System.RegularExpressions,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  DUnitX.TestFramework,
  zStorage;

type
  [TestFixture]
  TTestZStorage = class
  private
    FNomeFile: string;
    FPannello: TPanel;
    FForm: TForm;
    function PixelPerPolliceDi(Controllo: TControl): Integer;
    procedure ScriviProfilo(Controllo: TControl; const Sinistra, Alto, Larghezza, Altezza: Integer; const Stato: Integer = -1);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-STO-001
    [Test]
    procedure ProfiloDiSchermo_Formato_MonitorMisuraEPpi;
    // ZBASE-STO-001
    [Test]
    procedure ProfiloDiSchermo_Valori_CoincidonoConLoSchermo;
    // ZBASE-STO-001
    [Test]
    procedure NomeSezione_ControlloNil_Vuota;
    // ZBASE-STO-001
    [Test]
    procedure NomeSezione_ControlloSenzaNome_Vuota;
    // ZBASE-STO-001
    [Test]
    procedure NomeSezione_ControlloConNome_NomePiuProfilo;

    // ZBASE-STO-002
    [Test]
    procedure Salva_Pannello_ScriveProfiloELimiti;
    // ZBASE-STO-002
    [Test]
    procedure Salva_FormNormale_ScriveStatoZeroELimiti;
    // ZBASE-STO-002
    [Test]
    procedure Salva_FormMassimizzata_ScriveStatoDueSenzaLimiti;
    // ZBASE-STO-002
    [Test]
    procedure Salva_FormRidottaAIcona_ScriveStatoUnoSenzaLimiti;
    // ZBASE-STO-002
    [Test]
    procedure Salva_NomeFileVuoto_NonSollevaENonCreaIlFile;
    // ZBASE-STO-002
    [Test]
    procedure Salva_ControlloNil_NonSollevaENonCreaIlFile;
    // ZBASE-STO-002
    [Test]
    procedure Salva_ControlloSenzaNome_NonCreaIlFile;
    // ZBASE-STO-002
    [Test]
    procedure Salva_SezioneDiProfiloSenzaPpi_LaButta;
    // ZBASE-STO-002
    [Test]
    procedure Salva_SezioneDiProfiloConPpi_ConservaLeAltreChiavi;
    // ZBASE-STO-002
    [Test]
    procedure Salva_SezioneDelFormatoVecchio_NonSiTocca;

    // ZBASE-STO-003
    [Test]
    procedure Carica_NomeFileVuoto_NonCambiaNiente;
    // ZBASE-STO-003
    [Test]
    procedure Carica_FileInesistente_NonCambiaNienteENonCreaIlFile;
    // ZBASE-STO-003
    [Test]
    procedure Carica_DopoSalva_RipristinaILimiti;
    // ZBASE-STO-003
    [Test]
    procedure Carica_FormatoVecchio_UsaLaSezioneSenzaProfilo;
    // ZBASE-STO-003
    [Test]
    procedure Carica_ProfiloConPpiDoppio_RiportaLeMisureEnonLaPosizione;
    // ZBASE-STO-003
    [Test]
    procedure Carica_ProfiloSenzaPpiENessunFormatoVecchio_ConservaILimiti;
    // ZBASE-STO-003
    [Test]
    procedure Carica_ProfiloSenzaPpiConFormatoVecchio_UsaIlFormatoVecchio;
    // ZBASE-STO-003
    [Test]
    procedure Carica_ProfiloParziale_LaMisuraVieneDallaSezioneVecchia;
    // ZBASE-STO-003
    [Test]
    procedure Carica_Form_PositionDiventaPoDesigned;

    // ZBASE-STO-004
    [Test]
    procedure Carica_FormDentroLoSchermo_ResteDoveEra;
    // ZBASE-STO-004
    [Test]
    procedure Carica_FormRidottaAIcona_MisuraDiProgettoECentrata;
    // ZBASE-STO-004
    [Test]
    procedure Carica_FormFuoriDalloSchermo_Centrata;
    // ZBASE-STO-004
    [Test]
    procedure Carica_FormPiuGrandeDelMonitor_Stretta;
    // ZBASE-STO-004 e DIV-STO-2
    [Test]
    procedure Divergenza_DIV_STO_2_SoloLarghezzaSottoIlMinimo_TornaAncheLAltezza;

    // ZBASE-STO-005
    [Test]
    procedure Carica_StatoMassimizzato_FormMassimizzata;
    // ZBASE-STO-005
    [Test]
    procedure Carica_StatoRidottoAIcona_FormNormale;
    // ZBASE-STO-005
    [Test]
    procedure Carica_FormatoVecchioShowCmdTre_FormMassimizzata;
  end;

implementation

const
  PixelPerPolliceVecchiaSezione = 96;

procedure TTestZStorage.Setup;
begin
  FNomeFile := TPath.Combine(TPath.GetTempPath, 'zStorageProva_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '') + '.ini');

  FPannello := TPanel.Create(nil);
  FPannello.Name := 'PannelloProva';
  FPannello.SetBounds(0, 0, 200, 100);

  FForm := TForm.CreateNew(nil);
  FForm.Name := 'FormProva';
  FForm.SetBounds(0, 0, 400, 300);
end;

procedure TTestZStorage.TearDown;
begin
  FreeAndNil(FForm);
  FreeAndNil(FPannello);

  if TFile.Exists(FNomeFile) then
    TFile.Delete(FNomeFile);
end;

function TTestZStorage.PixelPerPolliceDi(Controllo: TControl): Integer;
begin
  // lo stesso criterio di zStorage: PPI del controllo, 96 se non positivo
  Result := Controllo.CurrentPPI;

  if Result <= 0 then
    Result := PixelPerPolliceVecchiaSezione;
end;

procedure TTestZStorage.ScriviProfilo(Controllo: TControl; const Sinistra, Alto, Larghezza, Altezza: Integer; const Stato: Integer);
var
  FileIni: TIniFile;
  Sezione: string;
begin
  Sezione := TzStorage.NomeSezione(Controllo);

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'PPI', PixelPerPolliceDi(Controllo));
    FileIni.WriteInteger(Sezione, 'Left', Sinistra);
    FileIni.WriteInteger(Sezione, 'Top', Alto);
    FileIni.WriteInteger(Sezione, 'Width', Larghezza);
    FileIni.WriteInteger(Sezione, 'Height', Altezza);

    if Stato >= 0 then
      FileIni.WriteInteger(Sezione, 'State', Stato);
  finally
    FileIni.Free;
  end;
end;

// ZBASE-STO-001

procedure TTestZStorage.ProfiloDiSchermo_Formato_MonitorMisuraEPpi;
begin
  Assert.IsTrue(TRegEx.IsMatch(TzStorage.ProfiloDiSchermo, '^\d+M-\d+x\d+-\d+(-RDP)?$'), 'profilo: ' + TzStorage.ProfiloDiSchermo);
end;

procedure TTestZStorage.ProfiloDiSchermo_Valori_CoincidonoConLoSchermo;
var
  Atteso: string;
  PixelPerPollice: Integer;
begin
  if Assigned(Screen.PrimaryMonitor) then
    PixelPerPollice := Screen.PrimaryMonitor.PixelsPerInch
  else
    PixelPerPollice := Screen.PixelsPerInch;

  Atteso := Format('%dM-%dx%d-%d', [Screen.MonitorCount, Screen.DesktopWidth, Screen.DesktopHeight, PixelPerPollice]);

  if GetSystemMetrics(SM_REMOTESESSION) <> 0 then
    Atteso := Atteso + '-RDP';

  Assert.AreEqual(Atteso, TzStorage.ProfiloDiSchermo);
end;

procedure TTestZStorage.NomeSezione_ControlloNil_Vuota;
begin
  Assert.AreEqual('', TzStorage.NomeSezione(nil));
end;

procedure TTestZStorage.NomeSezione_ControlloSenzaNome_Vuota;
var
  SenzaNome: TPanel;
begin
  SenzaNome := TPanel.Create(nil);
  try
    Assert.AreEqual('', TzStorage.NomeSezione(SenzaNome));
  finally
    SenzaNome.Free;
  end;
end;

procedure TTestZStorage.NomeSezione_ControlloConNome_NomePiuProfilo;
begin
  Assert.AreEqual('PannelloProva@' + TzStorage.ProfiloDiSchermo, TzStorage.NomeSezione(FPannello));
end;

// ZBASE-STO-002

procedure TTestZStorage.Salva_Pannello_ScriveProfiloELimiti;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  FPannello.SetBounds(10, 20, 300, 200);

  TzStorage.SaveControlToIni(FNomeFile, FPannello);

  Sezione := TzStorage.NomeSezione(FPannello);
  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.AreEqual(10, FileIni.ReadInteger(Sezione, 'Left', -1), 'Left');
    Assert.AreEqual(20, FileIni.ReadInteger(Sezione, 'Top', -1), 'Top');
    Assert.AreEqual(300, FileIni.ReadInteger(Sezione, 'Width', -1), 'Width');
    Assert.AreEqual(200, FileIni.ReadInteger(Sezione, 'Height', -1), 'Height');
    Assert.IsTrue(FileIni.ReadInteger(Sezione, 'PPI', 0) > 0, 'PPI');
    Assert.IsFalse(FileIni.ValueExists(Sezione, 'State'), 'State solo per le form');
    Assert.IsFalse(FileIni.SectionExists('PannelloProva'), 'la sezione del formato vecchio non si scrive');
  finally
    FileIni.Free;
  end;
end;

procedure TTestZStorage.Salva_FormNormale_ScriveStatoZeroELimiti;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  FForm.SetBounds(30, 40, 500, 350);

  TzStorage.SaveControlToIni(FNomeFile, FForm);

  Sezione := TzStorage.NomeSezione(FForm);
  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.AreEqual(Ord(wsNormal), FileIni.ReadInteger(Sezione, 'State', -1), 'State');
    Assert.AreEqual(30, FileIni.ReadInteger(Sezione, 'Left', -1), 'Left');
    Assert.AreEqual(40, FileIni.ReadInteger(Sezione, 'Top', -1), 'Top');
    Assert.AreEqual(500, FileIni.ReadInteger(Sezione, 'Width', -1), 'Width');
    Assert.AreEqual(350, FileIni.ReadInteger(Sezione, 'Height', -1), 'Height');
  finally
    FileIni.Free;
  end;
end;

procedure TTestZStorage.Salva_FormMassimizzata_ScriveStatoDueSenzaLimiti;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  FForm.WindowState := wsMaximized;

  TzStorage.SaveControlToIni(FNomeFile, FForm);

  Sezione := TzStorage.NomeSezione(FForm);
  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.AreEqual(Ord(wsMaximized), FileIni.ReadInteger(Sezione, 'State', -1), 'State');
    Assert.IsFalse(FileIni.ValueExists(Sezione, 'Left'), 'Left non riscritto');
    Assert.IsFalse(FileIni.ValueExists(Sezione, 'Width'), 'Width non riscritto');
  finally
    FileIni.Free;
  end;
end;

procedure TTestZStorage.Salva_FormRidottaAIcona_ScriveStatoUnoSenzaLimiti;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  FForm.WindowState := wsMinimized;

  TzStorage.SaveControlToIni(FNomeFile, FForm);

  Sezione := TzStorage.NomeSezione(FForm);
  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.AreEqual(Ord(wsMinimized), FileIni.ReadInteger(Sezione, 'State', -1), 'State');
    Assert.IsFalse(FileIni.ValueExists(Sezione, 'Top'), 'Top non riscritto');
  finally
    FileIni.Free;
  end;
end;

procedure TTestZStorage.Salva_NomeFileVuoto_NonSollevaENonCreaIlFile;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      TzStorage.SaveControlToIni('', FPannello);
    end);

  Assert.IsFalse(TFile.Exists(FNomeFile));
end;

procedure TTestZStorage.Salva_ControlloNil_NonSollevaENonCreaIlFile;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      TzStorage.SaveControlToIni(FNomeFile, nil);
    end);

  Assert.IsFalse(TFile.Exists(FNomeFile));
end;

procedure TTestZStorage.Salva_ControlloSenzaNome_NonCreaIlFile;
var
  SenzaNome: TPanel;
begin
  SenzaNome := TPanel.Create(nil);
  try
    TzStorage.SaveControlToIni(FNomeFile, SenzaNome);
  finally
    SenzaNome.Free;
  end;

  Assert.IsFalse(TFile.Exists(FNomeFile));
end;

procedure TTestZStorage.Salva_SezioneDiProfiloSenzaPpi_LaButta;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  Sezione := TzStorage.NomeSezione(FPannello);

  // la sezione scritta dal rilascio 005: nessun PPI
  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'Residuo', 1);
  finally
    FileIni.Free;
  end;

  TzStorage.SaveControlToIni(FNomeFile, FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.IsFalse(FileIni.ValueExists(Sezione, 'Residuo'), 'la chiave residua e'' buttata');
    Assert.IsTrue(FileIni.ReadInteger(Sezione, 'PPI', 0) > 0, 'PPI scritto');
  finally
    FileIni.Free;
  end;
end;

procedure TTestZStorage.Salva_SezioneDiProfiloConPpi_ConservaLeAltreChiavi;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  Sezione := TzStorage.NomeSezione(FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'PPI', PixelPerPolliceDi(FPannello));
    FileIni.WriteInteger(Sezione, 'Altro', 1);
  finally
    FileIni.Free;
  end;

  TzStorage.SaveControlToIni(FNomeFile, FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.AreEqual(1, FileIni.ReadInteger(Sezione, 'Altro', 0), 'chiave estranea conservata');
  finally
    FileIni.Free;
  end;
end;

procedure TTestZStorage.Salva_SezioneDelFormatoVecchio_NonSiTocca;
var
  FileIni: TIniFile;
begin
  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger('PannelloProva', 'Left', 1);
  finally
    FileIni.Free;
  end;

  FPannello.SetBounds(77, 88, 300, 200);
  TzStorage.SaveControlToIni(FNomeFile, FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    Assert.AreEqual(1, FileIni.ReadInteger('PannelloProva', 'Left', -1), 'sezione senza profilo invariata');
    Assert.IsFalse(FileIni.ValueExists('PannelloProva', 'Width'), 'nessuna chiave nuova nella sezione vecchia');
  finally
    FileIni.Free;
  end;
end;

// ZBASE-STO-003

procedure TTestZStorage.Carica_NomeFileVuoto_NonCambiaNiente;
begin
  FPannello.SetBounds(1, 2, 150, 120);

  TzStorage.LoadControlFromIni('', FPannello, 1000, 800);

  Assert.AreEqual(1, FPannello.Left, 'Left');
  Assert.AreEqual(2, FPannello.Top, 'Top');
  Assert.AreEqual(150, FPannello.Width, 'Width');
  Assert.AreEqual(120, FPannello.Height, 'Height');
end;

procedure TTestZStorage.Carica_FileInesistente_NonCambiaNienteENonCreaIlFile;
begin
  FPannello.SetBounds(1, 2, 150, 120);

  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  Assert.AreEqual(150, FPannello.Width, 'Width');
  Assert.IsFalse(TFile.Exists(FNomeFile), 'il file non viene creato dalla lettura');
end;

procedure TTestZStorage.Carica_DopoSalva_RipristinaILimiti;
begin
  FPannello.SetBounds(10, 20, 300, 200);
  TzStorage.SaveControlToIni(FNomeFile, FPannello);

  FPannello.SetBounds(0, 0, 100, 50);
  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  Assert.AreEqual(10, FPannello.Left, 'Left');
  Assert.AreEqual(20, FPannello.Top, 'Top');
  Assert.AreEqual(300, FPannello.Width, 'Width');
  Assert.AreEqual(200, FPannello.Height, 'Height');
end;

procedure TTestZStorage.Carica_FormatoVecchio_UsaLaSezioneSenzaProfilo;
var
  FileIni: TIniFile;
  PixelPerPollice: Integer;
begin
  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger('PannelloProva', 'Left', 15);
    FileIni.WriteInteger('PannelloProva', 'Top', 25);
    FileIni.WriteInteger('PannelloProva', 'Width', 300);
    FileIni.WriteInteger('PannelloProva', 'Height', 200);
  finally
    FileIni.Free;
  end;
  PixelPerPollice := PixelPerPolliceDi(FPannello);

  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  // posizione cosi' com'e', misure riportate dal PPI 96 (la sezione vecchia non lo dichiara)
  Assert.AreEqual(15, FPannello.Left, 'Left');
  Assert.AreEqual(25, FPannello.Top, 'Top');
  Assert.AreEqual(MulDiv(300, PixelPerPollice, PixelPerPolliceVecchiaSezione), FPannello.Width, 'Width');
  Assert.AreEqual(MulDiv(200, PixelPerPollice, PixelPerPolliceVecchiaSezione), FPannello.Height, 'Height');
end;

procedure TTestZStorage.Carica_ProfiloConPpiDoppio_RiportaLeMisureEnonLaPosizione;
var
  FileIni: TIniFile;
  Sezione: string;
  PixelPerPollice: Integer;
begin
  PixelPerPollice := PixelPerPolliceDi(FPannello);
  Sezione := TzStorage.NomeSezione(FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'PPI', PixelPerPollice * 2);
    FileIni.WriteInteger(Sezione, 'Left', 40);
    FileIni.WriteInteger(Sezione, 'Top', 50);
    FileIni.WriteInteger(Sezione, 'Width', 600);
    FileIni.WriteInteger(Sezione, 'Height', 400);
  finally
    FileIni.Free;
  end;

  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  Assert.AreEqual(40, FPannello.Left, 'Left non scalato');
  Assert.AreEqual(50, FPannello.Top, 'Top non scalato');
  Assert.AreEqual(300, FPannello.Width, 'Width dimezzato');
  Assert.AreEqual(200, FPannello.Height, 'Height dimezzato');
end;

procedure TTestZStorage.Carica_ProfiloSenzaPpiENessunFormatoVecchio_ConservaILimiti;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  Sezione := TzStorage.NomeSezione(FPannello);
  FPannello.SetBounds(1, 2, 150, 120);

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'Left', 99);
    FileIni.WriteInteger(Sezione, 'Width', 500);
  finally
    FileIni.Free;
  end;

  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  Assert.AreEqual(1, FPannello.Left, 'Left');
  Assert.AreEqual(150, FPannello.Width, 'Width');
end;

procedure TTestZStorage.Carica_ProfiloSenzaPpiConFormatoVecchio_UsaIlFormatoVecchio;
var
  FileIni: TIniFile;
  Sezione: string;
begin
  Sezione := TzStorage.NomeSezione(FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'Left', 99);
    FileIni.WriteInteger('PannelloProva', 'Left', 15);
  finally
    FileIni.Free;
  end;

  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  Assert.AreEqual(15, FPannello.Left);
end;

procedure TTestZStorage.Carica_ProfiloParziale_LaMisuraVieneDallaSezioneVecchia;
var
  FileIni: TIniFile;
  Sezione: string;
  PixelPerPollice: Integer;
begin
  PixelPerPollice := PixelPerPolliceDi(FPannello);
  Sezione := TzStorage.NomeSezione(FPannello);

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger(Sezione, 'PPI', PixelPerPollice);
    FileIni.WriteInteger('PannelloProva', 'Width', 300);
  finally
    FileIni.Free;
  end;

  TzStorage.LoadControlFromIni(FNomeFile, FPannello, 1000, 800);

  Assert.AreEqual(MulDiv(300, PixelPerPollice, PixelPerPolliceVecchiaSezione), FPannello.Width);
end;

procedure TTestZStorage.Carica_Form_PositionDiventaPoDesigned;
var
  Area: TRect;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  ScriviProfilo(FForm, Area.Left + 50, Area.Top + 50, 400, 300);
  FForm.Position := poScreenCenter;

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Ord(poDesigned), Ord(FForm.Position));
end;

// ZBASE-STO-004

procedure TTestZStorage.Carica_FormDentroLoSchermo_ResteDoveEra;
var
  Area: TRect;
  Larghezza, Altezza: Integer;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  Larghezza := Min(500, Area.Width - 100);
  Altezza := Min(400, Area.Height - 100);
  ScriviProfilo(FForm, Area.Left + 50, Area.Top + 50, Larghezza, Altezza);

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Area.Left + 50, FForm.Left, 'Left');
  Assert.AreEqual(Area.Top + 50, FForm.Top, 'Top');
  Assert.AreEqual(Larghezza, FForm.Width, 'Width');
  Assert.AreEqual(Altezza, FForm.Height, 'Height');
end;

procedure TTestZStorage.Carica_FormRidottaAIcona_MisuraDiProgettoECentrata;
var
  Area: TRect;
  Larghezza, Altezza: Integer;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  // misura di progetto: quella che la form ha prima della lettura (400 per 300)
  Larghezza := Min(FForm.Width, Area.Width);
  Altezza := Min(FForm.Height, Area.Height);
  ScriviProfilo(FForm, -32000, -32000, 160, 28);

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Larghezza, FForm.Width, 'Width di progetto');
  Assert.AreEqual(Altezza, FForm.Height, 'Height di progetto');
  Assert.AreEqual(Area.Left + (Area.Width - Larghezza) div 2, FForm.Left, 'Left centrato');
  Assert.AreEqual(Area.Top + (Area.Height - Altezza) div 2, FForm.Top, 'Top centrato');
end;

procedure TTestZStorage.Carica_FormFuoriDalloSchermo_Centrata;
var
  Area: TRect;
  Larghezza, Altezza: Integer;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  Larghezza := Min(500, Area.Width);
  Altezza := Min(400, Area.Height);
  // oltre il bordo destro del desktop virtuale: nessun monitor la mostra
  ScriviProfilo(FForm, Screen.DesktopLeft + Screen.DesktopWidth + 5000, Area.Top, 500, 400);

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Larghezza, FForm.Width, 'Width');
  Assert.AreEqual(Altezza, FForm.Height, 'Height');
  Assert.AreEqual(Area.Left + (Area.Width - Larghezza) div 2, FForm.Left, 'Left centrato');
  Assert.AreEqual(Area.Top + (Area.Height - Altezza) div 2, FForm.Top, 'Top centrato');
end;

procedure TTestZStorage.Carica_FormPiuGrandeDelMonitor_Stretta;
var
  Area, AreaDelMonitor: TRect;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  ScriviProfilo(FForm, Area.Left + 10, Area.Top + 10, Area.Width + 400, Area.Height + 400);

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  AreaDelMonitor := Screen.MonitorFromRect(FForm.BoundsRect, mdNearest).WorkareaRect;
  Assert.IsTrue(FForm.Width <= AreaDelMonitor.Width, 'larghezza nell''area utile');
  Assert.IsTrue(FForm.Height <= AreaDelMonitor.Height, 'altezza nell''area utile');
  Assert.IsTrue(FForm.Left >= AreaDelMonitor.Left, 'bordo sinistro nell''area utile');
  Assert.IsTrue(FForm.Left + FForm.Width <= AreaDelMonitor.Right, 'bordo destro nell''area utile');
  Assert.IsTrue(FForm.Top >= AreaDelMonitor.Top, 'bordo superiore nell''area utile');
  Assert.IsTrue(FForm.Top + FForm.Height <= AreaDelMonitor.Bottom, 'bordo inferiore nell''area utile');
end;

procedure TTestZStorage.Divergenza_DIV_STO_2_SoloLarghezzaSottoIlMinimo_TornaAncheLAltezza;
var
  Area: TRect;
begin
  // DIV-STO-2: con la sola larghezza sotto 200 tornano a quelle di progetto
  // larghezza e altezza insieme. Va capovolto (altezza 450) quando il codice
  // e' corretto.
  Area := Screen.PrimaryMonitor.WorkareaRect;
  ScriviProfilo(FForm, Area.Left + 50, Area.Top + 50, 150, 450);

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(400, FForm.Width, 'larghezza di progetto');
  Assert.AreEqual(300, FForm.Height, 'anche l''altezza e'' tornata a quella di progetto');
end;

// ZBASE-STO-005

procedure TTestZStorage.Carica_StatoMassimizzato_FormMassimizzata;
var
  Area: TRect;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  ScriviProfilo(FForm, Area.Left + 50, Area.Top + 50, 400, 300, Ord(wsMaximized));

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Ord(wsMaximized), Ord(FForm.WindowState));
end;

procedure TTestZStorage.Carica_StatoRidottoAIcona_FormNormale;
var
  Area: TRect;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;
  ScriviProfilo(FForm, Area.Left + 50, Area.Top + 50, 400, 300, Ord(wsMinimized));

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Ord(wsNormal), Ord(FForm.WindowState));
end;

procedure TTestZStorage.Carica_FormatoVecchioShowCmdTre_FormMassimizzata;
var
  FileIni: TIniFile;
  Area: TRect;
begin
  Area := Screen.PrimaryMonitor.WorkareaRect;

  FileIni := TIniFile.Create(FNomeFile);
  try
    FileIni.WriteInteger('FormProva', 'Left', Area.Left + 50);
    FileIni.WriteInteger('FormProva', 'Top', Area.Top + 50);
    FileIni.WriteInteger('FormProva', 'Width', 400);
    FileIni.WriteInteger('FormProva', 'Height', 300);
    FileIni.WriteInteger('FormProva', 'ShowCmd', 3);
  finally
    FileIni.Free;
  end;

  TzStorage.LoadControlFromIni(FNomeFile, FForm, FForm.ClientWidth, FForm.ClientHeight);

  Assert.AreEqual(Ord(wsMaximized), Ord(FForm.WindowState));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZStorage);

end.
