// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------
unit Test.zFileSystem;

// Test DUnitX di zOffice\zFileSystem.pas: l'albero delle cartelle e dei file
// dei report. Nessuna dipendenza da database o interfaccia: le prove lavorano
// su una cartella temporanea nuova, tolta alla fine.

interface

uses
  System.SysUtils,
  System.IOUtils,
  DUnitX.TestFramework,
  zFileSystem;

type
  [TestFixture]
  TTestZFileSystem = class
  private
    FRadice: string;
    procedure ScriviFile(const Percorso: string);
    function CaricaGruppo: TzFolder;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Mantis #6949 - 2026-11-02: una cartella che comincia con _ e' di archivio e non entra nell'albero
    [Test]
    procedure LoadFolder_CartellaConTrattinoBasso_NonViene_Caricata;
    // Mantis #6949 - 2026-11-02: con due omonimi, FileByName preferisce il file della cartella del gruppo
    [Test]
    procedure FileByName_Omonimi_PrecedenzaAllaCartellaDelGruppo;
    // Mantis #6949 - 2026-11-02: i due omonimi restano due file distinti, con il percorso proprio:
    // e' cio' che permette all'anteprima di aprire quello scelto nell'albero
    [Test]
    procedure LoadFolder_Omonimi_DueFileConPercorsiDiversi;

    // Mantis #315 - 2026-11-03: con due omonimi, il percorso completo identifica quello scelto nell'albero
    [Test]
    procedure FileByFullName_PercorsoEsistente_TrovaIlFile;
    // Mantis #315 - 2026-11-03: un percorso che non c'e' non trova niente
    [Test]
    procedure FileByFullName_PercorsoInesistente_RestituisceNil;
    // Mantis #315 - 2026-11-03: dopo Clear e nuovo caricamento (come LoadReports) il file si ritrova dal percorso salvato prima
    [Test]
    procedure FileByFullName_DopoRicaricamento_TrovaIlFileNuovo;
  end;

implementation

procedure TTestZFileSystem.Setup;
begin
  FRadice := TPath.Combine(TPath.GetTempPath, 'zPackTest_' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FRadice);
end;

procedure TTestZFileSystem.TearDown;
begin
  if TDirectory.Exists(FRadice) then
    TDirectory.Delete(FRadice, True);
end;

procedure TTestZFileSystem.ScriviFile(const Percorso: string);
begin
  ForceDirectories(ExtractFilePath(Percorso));
  TFile.WriteAllText(Percorso, 'x');
end;

function TTestZFileSystem.CaricaGruppo: TzFolder;
begin
  // L'albero lo possiede la cartella radice, che chiude il test.
  Result := TzFolder.Create(nil);
  Result.FullName := TPath.Combine(FRadice, 'Gruppo');
  Result.LoadFolder(nil, 'Gruppo', ['*.fr3'], []);
end;

procedure TTestZFileSystem.LoadFolder_CartellaConTrattinoBasso_NonViene_Caricata;
var
  Gruppo: TzFolder;
begin
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\_old\A.fr3'));
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\B.fr3'));

  Gruppo := CaricaGruppo;
  try
    Assert.IsNotNull(Gruppo.FileByName('B'), 'B nella cartella del gruppo');
    Assert.IsNull(Gruppo.FileByName('A'), 'A sta in _old, che non si carica');
    Assert.AreEqual(0, Gruppo.Folders.Count, 'nessuna sottocartella');
  finally
    Gruppo.Free;
  end;
end;

procedure TTestZFileSystem.FileByName_Omonimi_PrecedenzaAllaCartellaDelGruppo;
var
  Gruppo: TzFolder;
begin
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\A.fr3'));
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\old\A.fr3'));

  Gruppo := CaricaGruppo;
  try
    Assert.AreEqual(IncludeTrailingPathDelimiter(FRadice) + 'Gruppo\A.fr3', Gruppo.FileByName('A').FullName);
  finally
    Gruppo.Free;
  end;
end;

procedure TTestZFileSystem.LoadFolder_Omonimi_DueFileConPercorsiDiversi;
var
  Gruppo: TzFolder;
begin
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\A.fr3'));
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\old\A.fr3'));

  Gruppo := CaricaGruppo;
  try
    Assert.AreEqual(1, Gruppo.Files.Count, 'un file nella cartella del gruppo');
    Assert.AreEqual(1, Gruppo.Folders.Count, 'la sottocartella old');
    Assert.AreEqual(1, Gruppo.Folders[0].Files.Count, 'un file in old');
    Assert.AreNotEqual(Gruppo.Files[0].FullName, Gruppo.Folders[0].Files[0].FullName);
    Assert.AreEqual(Gruppo.Files[0].Name, Gruppo.Folders[0].Files[0].Name, 'stesso nome');
  finally
    Gruppo.Free;
  end;
end;

procedure TTestZFileSystem.FileByFullName_PercorsoEsistente_TrovaIlFile;
var
  Gruppo: TzFolder;
  Percorso: string;
  Trovato: TzFile;
begin
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\A.fr3'));
  Percorso := TPath.Combine(FRadice, 'Gruppo\old\A.fr3');
  ScriviFile(Percorso);

  Gruppo := CaricaGruppo;
  try
    Trovato := Gruppo.FileByFullName(Percorso);
    Assert.IsNotNull(Trovato, 'il file di old esiste');
    Assert.AreEqual(Percorso, Trovato.FullName, 'e'' quello di old, non l''omonimo del gruppo');
  finally
    Gruppo.Free;
  end;
end;

procedure TTestZFileSystem.FileByFullName_PercorsoInesistente_RestituisceNil;
var
  Gruppo: TzFolder;
begin
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\A.fr3'));

  Gruppo := CaricaGruppo;
  try
    Assert.IsNull(Gruppo.FileByFullName(TPath.Combine(FRadice, 'Gruppo\B.fr3')));
  finally
    Gruppo.Free;
  end;
end;

procedure TTestZFileSystem.FileByFullName_DopoRicaricamento_TrovaIlFileNuovo;
var
  Gruppo: TzFolder;
  Percorso: string;
  Trovato: TzFile;
begin
  ScriviFile(TPath.Combine(FRadice, 'Gruppo\A.fr3'));
  Percorso := TPath.Combine(FRadice, 'Gruppo\B.fr3');
  ScriviFile(Percorso);

  Gruppo := CaricaGruppo;
  try
    // come TzReportsManager.LoadReports: si distrugge tutto e si rilegge la cartella
    Gruppo.Clear;
    Gruppo.LoadFolder(nil, 'Gruppo', ['*.fr3'], []);

    Trovato := Gruppo.FileByFullName(Percorso);
    Assert.IsNotNull(Trovato, 'il file si ritrova nell''albero ricaricato');
    Assert.AreEqual(Percorso, Trovato.FullName);
  finally
    Gruppo.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZFileSystem);

end.
