// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.files;

// Test DUnitX di zLibs\zz.files.pas: l'elenco dei file di un'area (modelli,
// report, guide) con le tre provenienze standard, personalizzata e condivisa
// (specifica ZLIBS-FIL, "Funzioni sui file.md"). Nessuna dipendenza da
// database o interfaccia.
//
// TzFiles tiene lo stato in tre variabili di classe (AppRoot, CustomFolder,
// SharedFolder): Setup le salva e le porta a una cartella temporanea nuova,
// TearDown le ripristina e toglie la cartella. Tutti i file di prova stanno
// li'.
//
// Le divergenze DIV-FIL-1, 2, 3 e 4 sono fotografate da prove che vanno
// capovolte quando il codice sara' corretto. DIV-FIL-5 (radice vuota in
// Gesty e zTicser) riguarda il codice dei chiamanti.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  DUnitX.TestFramework,
  zz.files;

type
  [TestFixture]
  TTestZzFiles = class
  private
    FRadice: string;
    FAppRootPrecedente: string;
    FCustomPrecedente: string;
    FSharedPrecedente: string;
    FFiles: TzFiles;
    // Cartella della classe di prova: <radice>\Modelli\
    function CartellaClasse: string;
    procedure ScriviFile(const Percorso: string);
    // Nomi degli elementi, ordinati e separati da virgola.
    function NomiOrdinati(const Elenco: TzFiles): string;
    function EccezioneDi(const Procedura: TProc): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZLIBS-FIL-001
    [Test]
    procedure Scheda_PercorsoCompleto_NomeEstensioneECartella;
    // ZLIBS-FIL-001
    [Test]
    procedure Scheda_SenzaCartella_PercorsoCompletoUgualeAlNomeFile;
    // ZLIBS-FIL-001
    [Test]
    procedure Scheda_FileSenzaEstensione_EstensioneVuota;
    // ZLIBS-FIL-001
    [Test]
    procedure Scheda_Provenienze_IndicatoriCustomSharedIsProc;
    // ZLIBS-FIL-001
    [Test]
    procedure Scheda_ElementoAggiuntoSenzaDati_TuttoVuotoETipoNormale;
    // ZLIBS-FIL-002
    [Test]
    procedure Add_NomeNuovo_AggiungeUnElemento;
    // ZLIBS-FIL-002
    [Test]
    procedure Add_StessoNome_AggiornaLElementoEsistente;
    // ZLIBS-FIL-002
    [Test]
    procedure Add_StessoNomeConMaiuscoleDiverse_AggiornaEPrendeIlNuovoNome;
    // ZLIBS-FIL-002
    [Test]
    procedure FindFile_MaiuscoleDiverse_Trova;
    // ZLIBS-FIL-002
    [Test]
    procedure FindFile_NomeAssente_Nil;
    // ZLIBS-FIL-002
    [Test]
    procedure IndexOf_PresenteEAssente_IndiceOMenoUno;
    // ZLIBS-FIL-002
    [Test]
    procedure GetFullFileName_PresenteEAssente_PercorsoOStringaVuota;
    // ZLIBS-FIL-002
    [Test]
    procedure Add_ConProcedura_LaProceduraResta;
    // ZLIBS-FIL-003
    [Test]
    procedure GetFolder_Normale_RadiceClasseECartella;
    // ZLIBS-FIL-003
    [Test]
    procedure GetFolder_Personalizzata_ContieneLaCartellaDellePersonalizzazioni;
    // ZLIBS-FIL-003
    [Test]
    procedure GetFolder_Condivisa_IgnoraLaCartellaRichiesta;
    // ZLIBS-FIL-003
    [Test]
    procedure GetFolder_VersioneBooleana_FalsoNormaleVeroPersonalizzata;
    // ZLIBS-FIL-003
    [Test]
    procedure GetFolder_RadiceConOSenzaBarraFinale_StessoRisultato;
    // ZLIBS-FIL-003
    [Test]
    procedure GetFolder_CartellaVuota_RestaLaCartellaDellaClasse;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_EstensioneSenzaAsterisco_AggiungeSoloQuelliDellEstensione;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_EstensioneConAsterisco_StessoRisultato;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_ElementiAggiunti_NomeSenzaEstensioneECartellaNormale;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_CartellaInesistente_NessunElementoECartellaCreata;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_PredefinitoDoClear_SostituisceGliElementi;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_DoClearFalso_AccodaAgliElementi;
    // ZLIBS-FIL-004
    [Test]
    procedure AddFolder_ConFiltro_EscludeIFileNonValidi;
    // ZLIBS-FIL-005
    [Test]
    procedure AddFolder_FilePersonalizzatoConLoStessoNome_SostituisceLoStandard;
    // ZLIBS-FIL-005
    [Test]
    procedure AddFolder_FilePersonalizzatoNuovo_AggiuntoComePersonalizzato;
    // ZLIBS-FIL-005
    [Test]
    procedure AddFolder_CartellaPersonalizzazioniVuota_LePersonalizzazioniSiIgnorano;
    // ZLIBS-FIL-006
    [Test]
    procedure AddFolder_FileCondivisi_NomeEFileOSoloNome;
    // ZLIBS-FIL-006
    [Test]
    procedure AddFolder_FileCondivisoMancante_Ignorato;
    // ZLIBS-FIL-006
    [Test]
    procedure AddFolder_FileCondivisoConLoStessoNome_SostituisceStandardEPersonalizzato;
    // ZLIBS-FIL-007
    [Test]
    procedure GetFileNames_SenzaRimozione_NomiDeiFileConEstensione;
    // ZLIBS-FIL-007
    [Test]
    procedure GetFileNames_ConRimozione_NomiDegliElementi;
    // ZLIBS-FIL-007
    [Test]
    procedure GetFileNames_ElencoGiaPieno_SvuotatoPrima;
    // ZLIBS-FIL-008
    [Test]
    procedure Assign_DaAltraScheda_CopiaTuttiICampi;
    // ZLIBS-FIL-008
    [Test]
    procedure Assign_DaOggettoDiAltroTipo_SollevaEConvertError;
    // ZLIBS-FIL-008
    [Test]
    procedure SetItem_AssegnazioneDiUnElemento_CopiaIValori;
    // ZLIBS-FIL-008
    [Test]
    procedure Insert_InPrimaPosizione_ElementoAlPrimoPosto;
    // ZLIBS-FIL-008
    [Test]
    procedure ForIn_ElementiPresenti_PercorsiNelOrdine;
    // ZLIBS-FIL-009
    [Test]
    procedure ValoriPredefiniti_CartellePersonalizzataECondivisa_NomiStandard;
    // ZLIBS-FIL-006 e DIV-FIL-1
    [Test]
    procedure AddFolder_EstensioneConAsterisco_FileCondivisoTrovato;
    // ZLIBS-FIL-004 e DIV-FIL-2
    [Test]
    procedure AddFolder_Filtro_SiApplicaAiFilePersonalizzati;
    // ZLIBS-FIL-004 e DIV-FIL-2
    [Test]
    procedure AddFolder_Filtro_SiApplicaAiFileCondivisi;
    // DIV-FIL-3 (da capovolgere quando il codice sara' corretto)
    [Test]
    procedure Divergenza_DIV_FIL_3_GetFolderCreaLeCartellePerSolaLettura;
  end;

implementation

// TTestZzFiles

procedure TTestZzFiles.Setup;
begin
  FRadice := TPath.Combine(TPath.GetTempPath, 'zPackTest_' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FRadice);

  FAppRootPrecedente := TzFiles.AppRoot;
  FCustomPrecedente := TzFiles.CustomFolder;
  FSharedPrecedente := TzFiles.SharedFolder;

  TzFiles.AppRoot := FRadice;
  TzFiles.CustomFolder := '__Custom';
  TzFiles.SharedFolder := '__Shared';

  FFiles := TzFiles.Create('Modelli');
end;

procedure TTestZzFiles.TearDown;
begin
  FreeAndNil(FFiles);

  TzFiles.AppRoot := FAppRootPrecedente;
  TzFiles.CustomFolder := FCustomPrecedente;
  TzFiles.SharedFolder := FSharedPrecedente;

  if TDirectory.Exists(FRadice) then
    TDirectory.Delete(FRadice, True);
end;

function TTestZzFiles.CartellaClasse: string;
begin
  Result := IncludeTrailingPathDelimiter(FRadice) + 'Modelli' + PathDelim;
end;

procedure TTestZzFiles.ScriviFile(const Percorso: string);
begin
  ForceDirectories(ExtractFilePath(Percorso));
  TFile.WriteAllText(Percorso, 'x');
end;

function TTestZzFiles.NomiOrdinati(const Elenco: TzFiles): string;
var
  Nomi: TStringList;
  Elemento: TzFile;
begin
  Nomi := TStringList.Create;
  try
    Nomi.Sorted := True;
    Nomi.Duplicates := dupAccept;
    for Elemento in Elenco do
      Nomi.Add(Elemento.Name);
    Nomi.Delimiter := ',';
    Nomi.StrictDelimiter := True;
    Result := Nomi.DelimitedText;
  finally
    Nomi.Free;
  end;
end;

function TTestZzFiles.EccezioneDi(const Procedura: TProc): string;
begin
  Result := '';
  try
    Procedura();
  except
    on E: Exception do
      Result := E.ClassName;
  end;
end;

procedure TTestZzFiles.Scheda_PercorsoCompleto_NomeEstensioneECartella;
var
  Scheda: TzFile;
begin
  Scheda := FFiles.Add('Rapporto', 'C:\Dati\Rapporto.fr3', ftNormal, nil);

  Assert.AreEqual('Rapporto', Scheda.Name, 'Name');
  Assert.AreEqual('Rapporto.fr3', Scheda.FileName, 'FileName');
  Assert.AreEqual('C:\Dati\', Scheda.Folder, 'Folder: sempre con la barra finale');
  Assert.AreEqual('.fr3', Scheda.Ext, 'Ext: con il punto');
  Assert.AreEqual('Rapporto', Scheda.FileNameNoExt, 'FileNameNoExt');
  Assert.AreEqual('C:\Dati\Rapporto.fr3', Scheda.FullFileName, 'FullFileName');
end;

procedure TTestZzFiles.Scheda_SenzaCartella_PercorsoCompletoUgualeAlNomeFile;
var
  Scheda: TzFile;
begin
  Scheda := FFiles.Add('Solo', 'solo.txt', ftNormal, nil);

  Assert.AreEqual('solo.txt', Scheda.FileName, 'FileName');
  // oggi senza cartella Folder torna la sola barra (IncludeTrailingPathDelimiter di una stringa vuota)
  Assert.AreEqual(PathDelim, Scheda.Folder, 'Folder senza cartella');
  Assert.IsTrue(Scheda.FullFileName.EndsWith('solo.txt'), 'FullFileName: ' + Scheda.FullFileName);
end;

procedure TTestZzFiles.Scheda_FileSenzaEstensione_EstensioneVuota;
var
  Scheda: TzFile;
begin
  Scheda := FFiles.Add('Nudo', 'C:\Dati\LEGGIMI', ftNormal, nil);

  Assert.AreEqual('', Scheda.Ext, 'Ext');
  Assert.AreEqual('LEGGIMI', Scheda.FileNameNoExt, 'FileNameNoExt');
end;

procedure TTestZzFiles.Scheda_Provenienze_IndicatoriCustomSharedIsProc;
var
  Normale: TzFile;
  Personalizzato: TzFile;
  Condiviso: TzFile;
  Procedura: TzFile;
begin
  Normale := FFiles.Add('N', 'C:\a\n.txt', ftNormal, nil);
  Personalizzato := FFiles.Add('C', 'C:\a\c.txt', ftCustom, nil);
  Condiviso := FFiles.Add('S', 'C:\a\s.txt', ftShared, nil);
  Procedura := FFiles.Add('P', 'procedura', ftProc, nil);

  Assert.IsFalse(Normale.Custom or Normale.Shared or Normale.IsProc, 'normale: nessun indicatore');
  Assert.IsTrue(Personalizzato.Custom, 'personalizzato: Custom');
  Assert.IsFalse(Personalizzato.Shared or Personalizzato.IsProc, 'personalizzato: solo Custom');
  Assert.IsTrue(Condiviso.Shared, 'condiviso: Shared');
  Assert.IsFalse(Condiviso.Custom or Condiviso.IsProc, 'condiviso: solo Shared');
  Assert.IsTrue(Procedura.IsProc, 'procedura: IsProc');
  Assert.IsFalse(Procedura.Custom or Procedura.Shared, 'procedura: solo IsProc');
end;

procedure TTestZzFiles.Scheda_ElementoAggiuntoSenzaDati_TuttoVuotoETipoNormale;
var
  Scheda: TzFile;
begin
  Scheda := FFiles.Add;

  Assert.AreEqual('', Scheda.Name, 'Name');
  Assert.AreEqual('', Scheda.FileName, 'FileName');
  Assert.AreEqual('', Scheda.Folder, 'Folder');
  Assert.IsTrue(Scheda.FileType = ftNormal, 'FileType normale');
  Assert.IsFalse(Assigned(Scheda.Proc), 'nessuna procedura');
  Assert.AreEqual('', Scheda.FullFileName, 'FullFileName');
end;

procedure TTestZzFiles.Add_NomeNuovo_AggiungeUnElemento;
begin
  FFiles.Add('A', 'C:\a\a.txt', ftNormal, nil);
  FFiles.Add('B', 'C:\a\b.txt', ftNormal, nil);

  Assert.AreEqual(2, FFiles.Count);
  Assert.AreEqual('A,B', NomiOrdinati(FFiles));
end;

procedure TTestZzFiles.Add_StessoNome_AggiornaLElementoEsistente;
var
  Primo: TzFile;
  Secondo: TzFile;
begin
  Primo := FFiles.Add('Report', 'C:\standard\r.fr3', ftNormal, nil);
  Secondo := FFiles.Add('Report', 'C:\custom\r.fr3', ftCustom, nil);

  Assert.AreEqual(1, FFiles.Count, 'un solo elemento');
  Assert.IsTrue(Primo = Secondo, 'e'' lo stesso oggetto, aggiornato');
  Assert.AreEqual('C:\custom\r.fr3', Primo.FullFileName, 'percorso nuovo');
  Assert.IsTrue(Primo.FileType = ftCustom, 'tipo nuovo');
end;

procedure TTestZzFiles.Add_StessoNomeConMaiuscoleDiverse_AggiornaEPrendeIlNuovoNome;
var
  Scheda: TzFile;
begin
  FFiles.Add('Report', 'C:\a\r.fr3', ftNormal, nil);

  Scheda := FFiles.Add('REPORT', 'C:\b\r.fr3', ftNormal, nil);

  Assert.AreEqual(1, FFiles.Count, 'il confronto dei nomi ignora le maiuscole');
  Assert.AreEqual('REPORT', Scheda.Name, 'il nome diventa quello nuovo');
end;

procedure TTestZzFiles.FindFile_MaiuscoleDiverse_Trova;
var
  Trovato: TzFile;
begin
  FFiles.Add('Report', 'C:\a\r.fr3', ftNormal, nil);

  Trovato := FFiles.FindFile('rEpOrT');

  Assert.IsTrue(Trovato <> nil, 'trovato');
  Assert.AreEqual('Report', Trovato.Name);
end;

procedure TTestZzFiles.FindFile_NomeAssente_Nil;
begin
  FFiles.Add('Report', 'C:\a\r.fr3', ftNormal, nil);

  Assert.IsTrue(FFiles.FindFile('Altro') = nil, 'assente');
  Assert.IsTrue(FFiles.FindFile('') = nil, 'nome vuoto');
end;

procedure TTestZzFiles.IndexOf_PresenteEAssente_IndiceOMenoUno;
begin
  FFiles.Add('A', 'C:\a\a.txt', ftNormal, nil);
  FFiles.Add('B', 'C:\a\b.txt', ftNormal, nil);

  Assert.AreEqual(0, FFiles.IndexOf('A'), 'primo');
  Assert.AreEqual(1, FFiles.IndexOf('b'), 'secondo, maiuscole diverse');
  Assert.AreEqual(-1, FFiles.IndexOf('Z'), 'assente');
end;

procedure TTestZzFiles.GetFullFileName_PresenteEAssente_PercorsoOStringaVuota;
begin
  FFiles.Add('A', 'C:\a\a.txt', ftNormal, nil);

  Assert.AreEqual('C:\a\a.txt', FFiles.GetFullFileName('A'), 'presente');
  Assert.AreEqual('', FFiles.GetFullFileName('Z'), 'assente: stringa vuota');
end;

procedure TTestZzFiles.Add_ConProcedura_LaProceduraResta;
var
  Chiamata: Boolean;
  Scheda: TzFile;
begin
  Chiamata := False;

  Scheda := FFiles.Add('Azione', 'azione', ftProc,
    procedure(Elemento: TzFile)
    begin
      Chiamata := True;
    end);

  Assert.IsTrue(Assigned(Scheda.Proc), 'procedura associata');
  Scheda.Proc(Scheda);
  Assert.IsTrue(Chiamata, 'la procedura associata si puo'' chiamare');
  Assert.IsTrue(Scheda.IsProc, 'IsProc');
end;

procedure TTestZzFiles.GetFolder_Normale_RadiceClasseECartella;
begin
  Assert.AreEqual(CartellaClasse + 'Sub' + PathDelim, FFiles.GetFolder('Sub', ftNormal));
end;

procedure TTestZzFiles.GetFolder_Personalizzata_ContieneLaCartellaDellePersonalizzazioni;
begin
  Assert.AreEqual(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim, FFiles.GetFolder('Sub', ftCustom));
end;

procedure TTestZzFiles.GetFolder_Condivisa_IgnoraLaCartellaRichiesta;
begin
  Assert.AreEqual(CartellaClasse + '__Shared' + PathDelim, FFiles.GetFolder('Sub', ftShared), 'con una cartella');
  Assert.AreEqual(CartellaClasse + '__Shared' + PathDelim, FFiles.GetFolder('', ftShared), 'senza cartella');
end;

procedure TTestZzFiles.GetFolder_VersioneBooleana_FalsoNormaleVeroPersonalizzata;
begin
  Assert.AreEqual(FFiles.GetFolder('Sub', ftNormal), FFiles.GetFolder('Sub', False), 'falso: normale');
  Assert.AreEqual(FFiles.GetFolder('Sub', ftCustom), FFiles.GetFolder('Sub', True), 'vero: personalizzata');
end;

procedure TTestZzFiles.GetFolder_RadiceConOSenzaBarraFinale_StessoRisultato;
var
  SenzaBarra: string;
begin
  // FRadice non ha la barra finale (Setup): con la barra il risultato e' lo stesso
  SenzaBarra := FFiles.GetFolder('Sub', ftNormal);
  TzFiles.AppRoot := IncludeTrailingPathDelimiter(FRadice);

  Assert.AreEqual(SenzaBarra, FFiles.GetFolder('Sub', ftNormal));
end;

procedure TTestZzFiles.GetFolder_CartellaVuota_RestaLaCartellaDellaClasse;
var
  Risultato: string;
begin
  Risultato := FFiles.GetFolder('', ftNormal);
  Assert.IsTrue(Risultato.StartsWith(ExcludeTrailingPathDelimiter(CartellaClasse)), 'GetFolder: ' + Risultato);
end;

procedure TTestZzFiles.AddFolder_EstensioneSenzaAsterisco_AggiungeSoloQuelliDellEstensione;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'b.docx');
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'c.txt');

  FFiles.AddFolder('Sub', '.docx');

  Assert.AreEqual(2, FFiles.Count, 'due file .docx');
  Assert.AreEqual('a,b', NomiOrdinati(FFiles));
end;

procedure TTestZzFiles.AddFolder_EstensioneConAsterisco_StessoRisultato;
begin
  // e' la forma usata dai chiamanti: AddFolder(Folder, '*.pdf')
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'b.docx');
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'c.txt');

  FFiles.AddFolder('Sub', '*.docx');

  Assert.AreEqual(2, FFiles.Count, 'due file .docx');
  Assert.AreEqual('a,b', NomiOrdinati(FFiles));
end;

procedure TTestZzFiles.AddFolder_ElementiAggiunti_NomeSenzaEstensioneECartellaNormale;
var
  Scheda: TzFile;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'Lettera.docx');

  FFiles.AddFolder('Sub', '.docx');

  Scheda := FFiles.FindFile('Lettera');
  Assert.IsTrue(Scheda <> nil, 'trovato col nome senza estensione');
  Assert.AreEqual('Lettera.docx', Scheda.FileName, 'FileName');
  Assert.IsTrue(Scheda.FileType = ftNormal, 'tipo normale');
  Assert.IsTrue(SameText(CartellaClasse + 'Sub' + PathDelim, Scheda.Folder), 'cartella della classe');
  Assert.IsTrue(SameText(CartellaClasse + 'Sub' + PathDelim + 'Lettera.docx', Scheda.FullFileName), 'percorso completo');
end;

procedure TTestZzFiles.AddFolder_CartellaInesistente_NessunElementoECartellaCreata;
begin
  Assert.IsFalse(TDirectory.Exists(CartellaClasse + 'Nuova'), 'prima: la cartella non c''e''');

  FFiles.AddFolder('Nuova', '.docx');

  Assert.AreEqual(0, FFiles.Count, 'nessun elemento');
  Assert.IsTrue(TDirectory.Exists(CartellaClasse + 'Nuova'), 'dopo: la cartella e'' stata creata');
end;

procedure TTestZzFiles.AddFolder_PredefinitoDoClear_SostituisceGliElementi;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  FFiles.Add('Vecchio', 'C:\x\vecchio.docx', ftNormal, nil);

  FFiles.AddFolder('Sub', '.docx');

  Assert.AreEqual('a', NomiOrdinati(FFiles), 'l''elemento precedente e'' stato tolto');
end;

procedure TTestZzFiles.AddFolder_DoClearFalso_AccodaAgliElementi;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  FFiles.Add('Vecchio', 'C:\x\vecchio.docx', ftNormal, nil);

  FFiles.AddFolder('Sub', '.docx', nil, False);

  Assert.AreEqual(2, FFiles.Count, 'due elementi');
  Assert.IsTrue(FFiles.FindFile('Vecchio') <> nil, 'l''elemento precedente resta');
  Assert.IsTrue(FFiles.FindFile('a') <> nil, 'l''elemento nuovo e'' aggiunto');
end;

procedure TTestZzFiles.AddFolder_ConFiltro_EscludeIFileNonValidi;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'bozza.docx');

  FFiles.AddFolder('Sub', '.docx', nil, True,
    function(NomeFile: string): Boolean
    begin
      Result := not TPath.GetFileName(NomeFile).StartsWith('bozza');
    end);

  Assert.AreEqual('a', NomiOrdinati(FFiles), 'il file escluso dal filtro non compare');
end;

procedure TTestZzFiles.AddFolder_FilePersonalizzatoConLoStessoNome_SostituisceLoStandard;
var
  Scheda: TzFile;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  ScriviFile(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim + 'a.docx');

  FFiles.AddFolder('Sub', '.docx');

  Assert.AreEqual(1, FFiles.Count, 'un solo elemento: la personalizzazione sostituisce');
  Scheda := FFiles.FindFile('a');
  Assert.IsTrue(Scheda.Custom, 'e'' quello personalizzato');
  Assert.IsTrue(SameText(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim, Scheda.Folder), 'cartella delle personalizzazioni');
end;

procedure TTestZzFiles.AddFolder_FilePersonalizzatoNuovo_AggiuntoComePersonalizzato;
var
  Scheda: TzFile;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  ScriviFile(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim + 'solo-cliente.docx');

  FFiles.AddFolder('Sub', '.docx');

  Assert.AreEqual('a,solo-cliente', NomiOrdinati(FFiles));
  Scheda := FFiles.FindFile('solo-cliente');
  Assert.IsTrue(Scheda.Custom, 'personalizzato');
  Assert.IsFalse(FFiles.FindFile('a').Custom, 'l''altro resta normale');
end;

procedure TTestZzFiles.AddFolder_CartellaPersonalizzazioniVuota_LePersonalizzazioniSiIgnorano;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.docx');
  ScriviFile(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim + 'a.docx');
  TzFiles.CustomFolder := '';

  FFiles.AddFolder('Sub', '.docx');

  Assert.AreEqual(1, FFiles.Count, 'un elemento');
  Assert.IsFalse(FFiles.FindFile('a').Custom, 'resta quello normale');
end;

procedure TTestZzFiles.AddFolder_FileCondivisi_NomeEFileOSoloNome;
var
  Condivisi: TStringList;
  ConNome: TzFile;
  SoloNome: TzFile;
begin
  ScriviFile(CartellaClasse + '__Shared' + PathDelim + 'guida.txt');
  ScriviFile(CartellaClasse + '__Shared' + PathDelim + 'Altro.txt');

  Condivisi := TStringList.Create;
  try
    // "Nome=file": il nome dell'elemento e' a sinistra, il file a destra
    Condivisi.Add('Manuale=guida');
    // senza il segno uguale il nome e il file coincidono
    Condivisi.Add('Altro');

    FFiles.AddFolder('Sub', '.txt', Condivisi);
  finally
    Condivisi.Free;
  end;

  ConNome := FFiles.FindFile('Manuale');
  SoloNome := FFiles.FindFile('Altro');
  Assert.IsTrue(ConNome <> nil, 'Manuale trovato');
  Assert.IsTrue(ConNome.Shared, 'Manuale e'' condiviso');
  Assert.AreEqual('guida.txt', ConNome.FileName, 'Manuale punta a guida.txt');
  Assert.IsTrue(SoloNome <> nil, 'Altro trovato');
  Assert.AreEqual('Altro.txt', SoloNome.FileName, 'Altro punta a Altro.txt');
end;

procedure TTestZzFiles.AddFolder_FileCondivisoMancante_Ignorato;
var
  Condivisi: TStringList;
begin
  ScriviFile(CartellaClasse + '__Shared' + PathDelim + 'presente.txt');

  Condivisi := TStringList.Create;
  try
    Condivisi.Add('Presente=presente');
    Condivisi.Add('Assente=assente');
    FFiles.AddFolder('Sub', '.txt', Condivisi);
  finally
    Condivisi.Free;
  end;

  Assert.AreEqual('Presente', NomiOrdinati(FFiles), 'solo il file che esiste');
end;

procedure TTestZzFiles.AddFolder_FileCondivisoConLoStessoNome_SostituisceStandardEPersonalizzato;
var
  Condivisi: TStringList;
  Scheda: TzFile;
begin
  ScriviFile(CartellaClasse + 'Sub' + PathDelim + 'a.txt');
  ScriviFile(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim + 'a.txt');
  ScriviFile(CartellaClasse + '__Shared' + PathDelim + 'a.txt');

  Condivisi := TStringList.Create;
  try
    Condivisi.Add('a');
    FFiles.AddFolder('Sub', '.txt', Condivisi);
  finally
    Condivisi.Free;
  end;

  Assert.AreEqual(1, FFiles.Count, 'un solo elemento');
  Scheda := FFiles.FindFile('a');
  Assert.IsTrue(Scheda.Shared, 'vince quello condiviso');
end;

procedure TTestZzFiles.GetFileNames_SenzaRimozione_NomiDeiFileConEstensione;
var
  Nomi: TStringList;
begin
  FFiles.Add('Rapporto', 'C:\x\file.pdf', ftNormal, nil);
  FFiles.Add('Altro', 'C:\x\altro.docx', ftNormal, nil);

  Nomi := TStringList.Create;
  try
    FFiles.GetFileNames(Nomi);

    Assert.AreEqual(2, Nomi.Count, 'due nomi');
    Assert.AreEqual('file.pdf', Nomi[0], 'primo');
    Assert.AreEqual('altro.docx', Nomi[1], 'secondo');
  finally
    Nomi.Free;
  end;
end;

procedure TTestZzFiles.GetFileNames_ConRimozione_NomiDegliElementi;
var
  Nomi: TStringList;
begin
  // Documenta il comportamento attuale (DIV-FIL-4): con RemoveFileExt vero
  // si ottiene il nome dell'elemento, non il nome del file senza estensione.
  // I due coincidono solo per gli elementi nati da AddFolder.
  FFiles.Add('Rapporto', 'C:\x\file.pdf', ftNormal, nil);

  Nomi := TStringList.Create;
  try
    FFiles.GetFileNames(Nomi, True);

    Assert.AreEqual(1, Nomi.Count, 'un nome');
    Assert.AreEqual('Rapporto', Nomi[0], 'il nome dell''elemento');
  finally
    Nomi.Free;
  end;
end;

procedure TTestZzFiles.GetFileNames_ElencoGiaPieno_SvuotatoPrima;
var
  Nomi: TStringList;
begin
  FFiles.Add('A', 'C:\x\a.txt', ftNormal, nil);
  Nomi := TStringList.Create;
  try
    Nomi.Add('prima');
    Nomi.Add('seconda');

    FFiles.GetFileNames(Nomi);

    Assert.AreEqual(1, Nomi.Count, 'solo il nome nuovo');
    Assert.AreEqual('a.txt', Nomi[0]);
  finally
    Nomi.Free;
  end;
end;

procedure TTestZzFiles.Assign_DaAltraScheda_CopiaTuttiICampi;
var
  Origine: TzFile;
  Destinazione: TzFile;
  Chiamata: Boolean;
begin
  Chiamata := False;
  Origine := FFiles.Add('Origine', 'C:\a\o.txt', ftCustom,
    procedure(Elemento: TzFile)
    begin
      Chiamata := True;
    end);
  Destinazione := FFiles.Add;

  Destinazione.Assign(Origine);

  Assert.AreEqual('Origine', Destinazione.Name, 'Name');
  Assert.AreEqual('o.txt', Destinazione.FileName, 'FileName');
  Assert.AreEqual('C:\a\', Destinazione.Folder, 'Folder');
  Assert.IsTrue(Destinazione.FileType = ftCustom, 'FileType');
  Assert.IsTrue(Assigned(Destinazione.Proc), 'Proc');
  Destinazione.Proc(Destinazione);
  Assert.IsTrue(Chiamata, 'la procedura copiata e'' quella originale');
end;

procedure TTestZzFiles.Assign_DaOggettoDiAltroTipo_SollevaEConvertError;
var
  Scheda: TzFile;
  Estraneo: TPersistent;
  Classe: string;
begin
  Scheda := FFiles.Add;
  Estraneo := TPersistent.Create;
  try
    Classe := EccezioneDi(
      procedure
      begin
        Scheda.Assign(Estraneo);
      end);
  finally
    Estraneo.Free;
  end;

  Assert.AreEqual('EConvertError', Classe);
end;

procedure TTestZzFiles.SetItem_AssegnazioneDiUnElemento_CopiaIValori;
begin
  FFiles.Add('Uno', 'C:\a\uno.txt', ftNormal, nil);
  FFiles.Add('Due', 'C:\a\due.txt', ftShared, nil);

  FFiles[0] := FFiles[1];

  Assert.AreEqual(2, FFiles.Count, 'nessun elemento aggiunto');
  Assert.AreEqual('Due', FFiles[0].Name, 'nome copiato');
  Assert.AreEqual('due.txt', FFiles[0].FileName, 'file copiato');
  Assert.IsTrue(FFiles[0].Shared, 'tipo copiato');
end;

procedure TTestZzFiles.Insert_InPrimaPosizione_ElementoAlPrimoPosto;
var
  Nuovo: TzFile;
begin
  FFiles.Add('B', 'C:\a\b.txt', ftNormal, nil);

  Nuovo := FFiles.Insert(0);
  Nuovo.Name := 'A';

  Assert.AreEqual(2, FFiles.Count, 'due elementi');
  Assert.AreEqual('A', FFiles[0].Name, 'il nuovo e'' primo');
  Assert.AreEqual('B', FFiles[1].Name, 'il vecchio e'' secondo');
end;

procedure TTestZzFiles.ForIn_ElementiPresenti_PercorsiNelOrdine;
var
  Scheda: TzFile;
  Ordine: string;
begin
  FFiles.Add('A', 'C:\a\a.txt', ftNormal, nil);
  FFiles.Add('B', 'C:\a\b.txt', ftNormal, nil);
  FFiles.Add('C', 'C:\a\c.txt', ftNormal, nil);

  Ordine := '';
  for Scheda in FFiles do
    Ordine := Ordine + Scheda.Name;

  Assert.AreEqual('ABC', Ordine);
end;

procedure TTestZzFiles.ValoriPredefiniti_CartellePersonalizzataECondivisa_NomiStandard;
begin
  // letti da Setup prima di portarli ai valori della prova
  Assert.AreEqual('__Custom', FCustomPrecedente, 'CustomFolder');
  Assert.AreEqual('__Shared', FSharedPrecedente, 'SharedFolder');
end;

procedure TTestZzFiles.AddFolder_EstensioneConAsterisco_FileCondivisoTrovato;
var
  Condivisi: TStringList;
begin
  // DIV-FIL-1 corretta: con l'estensione scritta come fanno i chiamanti
  // ('*.txt') anche il file condiviso si trova.
  ScriviFile(CartellaClasse + '__Shared' + PathDelim + 'guida.txt');

  Condivisi := TStringList.Create;
  try
    Condivisi.Add('Manuale=guida');
    FFiles.AddFolder('Sub', '*.txt', Condivisi);
  finally
    Condivisi.Free;
  end;

  Assert.IsTrue(FFiles.FindFile('Manuale') <> nil, 'il file condiviso viene trovato');
end;

procedure TTestZzFiles.AddFolder_Filtro_SiApplicaAiFilePersonalizzati;
begin
  // DIV-FIL-2 corretta: il filtro IsValidFile vale anche per i file personalizzati.
  ScriviFile(CartellaClasse + '__Custom' + PathDelim + 'Sub' + PathDelim + 'bozza.docx');

  FFiles.AddFolder('Sub', '.docx', nil, True,
    function(NomeFile: string): Boolean
    begin
      Result := False;
    end);

  Assert.AreEqual(0, FFiles.Count, 'il file personalizzato e'' escluso dal filtro');
end;

procedure TTestZzFiles.AddFolder_Filtro_SiApplicaAiFileCondivisi;
var
  Condivisi: TStringList;
begin
  ScriviFile(CartellaClasse + '__Shared' + PathDelim + 'guida.txt');

  Condivisi := TStringList.Create;
  try
    Condivisi.Add('Manuale=guida');
    FFiles.AddFolder('Sub', '.txt', Condivisi, True,
      function(NomeFile: string): Boolean
      begin
        Result := False;
      end);
  finally
    Condivisi.Free;
  end;

  Assert.IsTrue(FFiles.FindFile('Manuale') = nil, 'il file condiviso e'' escluso dal filtro');
end;

procedure TTestZzFiles.Divergenza_DIV_FIL_3_GetFolderCreaLeCartellePerSolaLettura;
begin
  // Documenta il comportamento attuale: chiedere il percorso di una cartella
  // la crea (e crea anche la radice della classe). Da capovolgere quando il
  // codice sara' corretto.
  Assert.IsFalse(TDirectory.Exists(CartellaClasse), 'prima: nemmeno la cartella della classe esiste');

  FFiles.GetFolder('Sconosciuta', ftNormal);

  Assert.IsTrue(TDirectory.Exists(CartellaClasse + 'Sconosciuta'), 'dopo: la cartella e'' stata creata');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZzFiles);

end.
