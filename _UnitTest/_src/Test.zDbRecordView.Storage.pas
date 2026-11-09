// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-03
// ---------------------------------------------------------------------------
unit Test.zDbRecordView.Storage;

// Test DUnitX per zDbRecordView.Storage (TzDbRecordView): layout personale
// dell'utente (larghezze e categorie chiuse). Lettura e scrittura si provano
// su TMemIniFile in memoria; Save, Load e Reset su una cartella temporanea
// creata e cancellata da ogni test.
//
// Il nome del file contiene l'identificativo intero (Modulo.DataSet): due
// viste dello stesso modulo dati non devono finire nello stesso file, il
// difetto D6 del file .conditionalFormatting di TzDbView.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.IniFiles,
  DUnitX.TestFramework,
  zDbRecordView.Storage;

type
  [TestFixture]
  TTestRecordViewUserLayout = class
  public
    [Test]
    procedure Clear_AzzeraTutto;
    [Test]
    procedure IsCollapsed_SenzaDistinzioneMaiuscole;
    [Test]
    procedure IsCollapsed_Assente_False;
  end;

  [TestFixture]
  TTestRecordViewLayoutIni = class
  private
    FIni: TMemIniFile;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure RoundTrip;
    [Test]
    procedure Read_SezioneAssente_LayoutVuoto;
    [Test]
    procedure Read_ElencoConVociVuote_Saltate;
    [Test]
    procedure Write_CancellaIValoriPrecedenti;
    [Test]
    procedure IniNil_NessunErrore;
  end;

  [TestFixture]
  TTestRecordViewFileName = class
  public
    [Test]
    procedure IdentificativoConPunto_NomeIntero;
    [Test]
    procedure DueVisteStessoModulo_FileDistinti;
    [Test]
    procedure CaratteriNonAmmessi_Sostituiti;
    [Test]
    procedure CartellaOIdentificativoVuoti_NessunFile;
  end;

  [TestFixture]
  TTestRecordViewFile = class
  private
    FCartella: string;
    FStorage: TzDbRecordViewStorage;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Save_Load_RoundTrip;
    [Test]
    procedure Save_CreaLaCartella;
    [Test]
    procedure Load_FileAssente_LayoutVuoto;
    [Test]
    procedure Load_FileRovinato_LayoutVuoto;
    [Test]
    procedure Reset_CancellaIlFile;
    [Test]
    procedure Save_CartellaNonCreabile_FalsoSenzaEccezione;
    [Test]
    procedure Load_FileBloccato_LayoutVuoto;
  end;

implementation

function LayoutDiEsempio: TzRecordViewUserLayout;
begin
  result.Clear;
  result.HeaderWidth := 180;
  result.ValueWidth := 320;
  result.CollapsedCategories := ['Recapiti', 'Note'];
end;

{ TTestRecordViewUserLayout }

procedure TTestRecordViewUserLayout.Clear_AzzeraTutto;
var
  Layout: TzRecordViewUserLayout;
begin
  Layout := LayoutDiEsempio;
  Layout.Clear;

  Assert.AreEqual(0, Layout.HeaderWidth);
  Assert.AreEqual(0, Layout.ValueWidth);
  Assert.AreEqual(0, Length(Layout.CollapsedCategories));
end;

procedure TTestRecordViewUserLayout.IsCollapsed_SenzaDistinzioneMaiuscole;
begin
  Assert.IsTrue(LayoutDiEsempio.IsCollapsed('recapiti'));
end;

procedure TTestRecordViewUserLayout.IsCollapsed_Assente_False;
begin
  Assert.IsFalse(LayoutDiEsempio.IsCollapsed('Anagrafica'));
  Assert.IsFalse(LayoutDiEsempio.IsCollapsed(''));
end;

{ TTestRecordViewLayoutIni }

procedure TTestRecordViewLayoutIni.Setup;
begin
  FIni := TMemIniFile.Create('');
end;

procedure TTestRecordViewLayoutIni.TearDown;
begin
  FreeAndNil(FIni);
end;

procedure TTestRecordViewLayoutIni.RoundTrip;
var
  Letto: TzRecordViewUserLayout;
begin
  TzDbRecordViewStorage.WriteLayout(FIni, LayoutDiEsempio);
  Letto := TzDbRecordViewStorage.ReadLayout(FIni);

  Assert.AreEqual(180, Letto.HeaderWidth);
  Assert.AreEqual(320, Letto.ValueWidth);
  Assert.AreEqual(2, Length(Letto.CollapsedCategories));
  Assert.IsTrue(Letto.IsCollapsed('Recapiti'));
  Assert.IsTrue(Letto.IsCollapsed('Note'));
end;

procedure TTestRecordViewLayoutIni.Read_SezioneAssente_LayoutVuoto;
var
  Letto: TzRecordViewUserLayout;
begin
  Letto := TzDbRecordViewStorage.ReadLayout(FIni);

  Assert.AreEqual(0, Letto.HeaderWidth);
  Assert.AreEqual(0, Letto.ValueWidth);
  Assert.AreEqual(0, Length(Letto.CollapsedCategories));
end;

procedure TTestRecordViewLayoutIni.Read_ElencoConVociVuote_Saltate;
var
  Letto: TzRecordViewUserLayout;
begin
  FIni.WriteString(TzDbRecordViewStorage.SectionLayout, 'CollapsedCategories', 'A;;B;');
  Letto := TzDbRecordViewStorage.ReadLayout(FIni);

  Assert.AreEqual(2, Length(Letto.CollapsedCategories));
  Assert.AreEqual('A', Letto.CollapsedCategories[0]);
  Assert.AreEqual('B', Letto.CollapsedCategories[1]);
end;

procedure TTestRecordViewLayoutIni.Write_CancellaIValoriPrecedenti;
var
  Ridotto: TzRecordViewUserLayout;
begin
  FIni.WriteString(TzDbRecordViewStorage.SectionLayout, 'ChiaveVecchia', 'x');
  TzDbRecordViewStorage.WriteLayout(FIni, LayoutDiEsempio);

  Ridotto.Clear;
  TzDbRecordViewStorage.WriteLayout(FIni, Ridotto);

  Assert.IsFalse(FIni.ValueExists(TzDbRecordViewStorage.SectionLayout, 'ChiaveVecchia'));
  Assert.AreEqual(0, Length(TzDbRecordViewStorage.ReadLayout(FIni).CollapsedCategories));
end;

procedure TTestRecordViewLayoutIni.IniNil_NessunErrore;
begin
  TzDbRecordViewStorage.WriteLayout(nil, LayoutDiEsempio);
  Assert.AreEqual(0, TzDbRecordViewStorage.ReadLayout(nil).HeaderWidth);
end;

{ TTestRecordViewFileName }

procedure TTestRecordViewFileName.IdentificativoConPunto_NomeIntero;
var
  Storage: TzDbRecordViewStorage;
begin
  Storage := TzDbRecordViewStorage.Create;
  try
    Storage.Folder := 'C:\Utente';
    Storage.RecordViewID := 'Anagrafica.Studenti';

    Assert.AreEqual('C:\Utente\Anagrafica.Studenti.recordview', Storage.FileName);
  finally
    Storage.Free;
  end;
end;

procedure TTestRecordViewFileName.DueVisteStessoModulo_FileDistinti;
var
  Prima, Seconda: TzDbRecordViewStorage;
begin
  Prima := TzDbRecordViewStorage.Create;
  Seconda := TzDbRecordViewStorage.Create;
  try
    Prima.Folder := 'C:\Utente';
    Prima.RecordViewID := 'Anagrafica.Studenti';
    Seconda.Folder := 'C:\Utente\';
    Seconda.RecordViewID := 'Anagrafica.Docenti';

    Assert.AreNotEqual(Prima.FileName, Seconda.FileName);
  finally
    Seconda.Free;
    Prima.Free;
  end;
end;

procedure TTestRecordViewFileName.CaratteriNonAmmessi_Sostituiti;
var
  Storage: TzDbRecordViewStorage;
begin
  Storage := TzDbRecordViewStorage.Create;
  try
    Storage.Folder := 'C:\Utente';
    Storage.RecordViewID := 'A/B:C*D?E';

    Assert.AreEqual('C:\Utente\A_B_C_D_E.recordview', Storage.FileName);
  finally
    Storage.Free;
  end;
end;

procedure TTestRecordViewFileName.CartellaOIdentificativoVuoti_NessunFile;
var
  Storage: TzDbRecordViewStorage;
begin
  Storage := TzDbRecordViewStorage.Create;
  try
    Storage.RecordViewID := 'Anagrafica.Studenti';
    Assert.AreEqual('', Storage.FileName, 'senza cartella');

    Storage.Folder := 'C:\Utente';
    Storage.RecordViewID := '';
    Assert.AreEqual('', Storage.FileName, 'senza identificativo');
  finally
    Storage.Free;
  end;
end;

{ TTestRecordViewFile }

procedure TTestRecordViewFile.Setup;
begin
  FCartella := TPath.Combine(TPath.GetTempPath, 'zPackTests_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  FStorage := TzDbRecordViewStorage.Create;
  FStorage.Folder := FCartella;
  FStorage.RecordViewID := 'Modulo.Vista';
end;

procedure TTestRecordViewFile.TearDown;
begin
  FreeAndNil(FStorage);

  if TDirectory.Exists(FCartella) then
    TDirectory.Delete(FCartella, True);
end;

procedure TTestRecordViewFile.Save_Load_RoundTrip;
var
  Letto: TzRecordViewUserLayout;
begin
  FStorage.Save(LayoutDiEsempio);
  Letto := FStorage.Load;

  Assert.AreEqual(180, Letto.HeaderWidth);
  Assert.AreEqual(320, Letto.ValueWidth);
  Assert.IsTrue(Letto.IsCollapsed('Note'));
end;

procedure TTestRecordViewFile.Save_CreaLaCartella;
begin
  Assert.IsFalse(TDirectory.Exists(FCartella));
  FStorage.Save(LayoutDiEsempio);

  Assert.IsTrue(TFile.Exists(FStorage.FileName));
end;

procedure TTestRecordViewFile.Load_FileAssente_LayoutVuoto;
begin
  Assert.AreEqual(0, FStorage.Load.HeaderWidth);
end;

procedure TTestRecordViewFile.Load_FileRovinato_LayoutVuoto;
begin
  // un file con byte non UTF-8 non deve impedire l'apertura della vista
  TDirectory.CreateDirectory(FCartella);
  TFile.WriteAllBytes(FStorage.FileName, TBytes.Create($5B, $4C, $61, $C3, $28, $FF, $FE, $0D, $0A));

  Assert.WillNotRaise(
    procedure
    begin
      FStorage.Load;
    end);
  Assert.AreEqual(0, FStorage.Load.HeaderWidth);
end;

procedure TTestRecordViewFile.Reset_CancellaIlFile;
begin
  FStorage.Save(LayoutDiEsempio);
  Assert.IsTrue(TFile.Exists(FStorage.FileName));

  FStorage.Reset;

  Assert.IsFalse(TFile.Exists(FStorage.FileName));
  Assert.AreEqual(0, FStorage.Load.HeaderWidth);
end;

procedure TTestRecordViewFile.Save_CartellaNonCreabile_FalsoSenzaEccezione;
var
  Esito: boolean;
begin
  // La "cartella personale" e' in realta' un file: non ci si puo' scrivere dentro
  TDirectory.CreateDirectory(FCartella);
  FStorage.Folder := TPath.Combine(FCartella, 'non-una-cartella');
  TFile.WriteAllText(FStorage.Folder, 'x');

  Esito := True;
  Assert.WillNotRaise(
    procedure
    begin
      Esito := FStorage.Save(LayoutDiEsempio);
    end);
  Assert.IsFalse(Esito);
end;

procedure TTestRecordViewFile.Load_FileBloccato_LayoutVuoto;
var
  Blocco: TFileStream;
begin
  FStorage.Save(LayoutDiEsempio);

  // Un altro processo tiene il file aperto in esclusiva
  Blocco := TFileStream.Create(FStorage.FileName, fmOpenReadWrite or fmShareExclusive);
  try
    Assert.WillNotRaise(
      procedure
      begin
        FStorage.Load;
      end);
    Assert.AreEqual(0, FStorage.Load.HeaderWidth);
  finally
    Blocco.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRecordViewUserLayout);
  TDUnitX.RegisterTestFixture(TTestRecordViewLayoutIni);
  TDUnitX.RegisterTestFixture(TTestRecordViewFileName);
  TDUnitX.RegisterTestFixture(TTestRecordViewFile);

end.
