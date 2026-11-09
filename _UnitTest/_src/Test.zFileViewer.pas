// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-02
// ---------------------------------------------------------------------------
unit Test.zFileViewer;

// Test DUnitX per zBase\zFileViewer.pas (specifica ZBASE-FVW, "Visualizzatore di
// file.md"). Compilata ed eseguita: 39 prove.
//
// Il riquadro si crea con TzFileViewerProva.Create(FForm): con la finestra di una form
// di prova come genitore di comodo e senza mai mostrarlo, quindi non compare nessuna finestra e non parte nessun
// caricamento di PDF. Il visualizzatore PDF di DevExpress resta vuoto: i file
// di prova sono scritti nella cartella temporanea e non vengono mai aperti,
// perche' il riquadro non e' inizializzato (Init) e quindi OpenFile non fa
// niente (DIV-FVW-1). La lettura del record (dbOpenFile) si prova chiamando
// TimerTimer, che e' pubblicato; il timer non scade da solo perche' il programma
// di prova non ha un ciclo di messaggi.
//
// I dataset sono TFDMemTable, senza Firebird.
//
// Restano senza prova, perche' servono una finestra visibile, un PDF vero o
// il dialogo di sistema: il caricamento effettivo, la barra di stato con un
// documento (pannelli 0 e 2), Print, il salvataggio (FileSaveAsAccept apre
// Esplora risorse), ApriConAdobe, GenerateFromTemplate e la configurazione degli
// strumenti (EditTools, ExecuteToolConfig).
//
// Le prove "Divergenza_DIV_FVW_n_*" fotografano il comportamento attuale: vanno
// capovolte quando il codice viene corretto.
//
// ShowLoading, chiamato da SetFileName, attiva un indicatore di attesa animato:
// nelle prove non e' stato un problema.

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Data.DB,
  FireDAC.Comp.Client,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  dxBar,
  dxStatusBar,
  dxFileActions,
  DUnitX.TestFramework,
  zSystem,
  zFbDataSet,
  zFileViewer;

type
  // Il riquadro, creato senza genitore, solleva "has no parent window" appena un controllo figlio
  // chiede la finestra: la finestra dell'applicazione fa da genitore di comodo.
  TzFileViewerProva = class(TzFileViewer)
  public
    class var HandleGenitore: HWND;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  // Causa del vecchio errore (R-213): il riquadro e' un frame che, mentre si costruisce, fa
  // chiedere la finestra a un controllo figlio; senza genitore solleva "has no parent window".
  // Application.Handle in un programma di console vale 0, quindi non serve da genitore di
  // comodo: lo fa la finestra di una form di prova (HandleGenitore, assegnato in Setup).
  [TestFixture]
  TTestzFileViewer = class
  private
    FViewer: TzFileViewer;
    FForm: TForm;
    FCartella: string;
    FFilePdf: string;
    FFileImmagine: string;
    FImportMittente: TzFileViewer;
    FImportNome: string;
    FImportChiamate: Integer;
    FGenerazioneChiamate: Integer;
    procedure ConGenitoreDiComodo(const Chiamata: TProc);
    procedure ImportaGestore(sender: TzFileViewer; const FileName: string);
    procedure GenerazioneGestore(sender: TzFileViewer);
    function CreaDataSet(const NomeCampo, Valore: string): TFDMemTable;
    function CreaDataSetVuoto(const NomeCampo: string): TFDMemTable;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-FVW-008
    [Test]
    procedure Creazione_ValoriIniziali_TuttiVuotiEPredefiniti;
    // ZBASE-FVW-005
    [Test]
    procedure Creazione_TimerSpento;
    // ZBASE-FVW-008
    [Test]
    procedure CreateFileViewer_ValoriPredefiniti_NomeEAllineamento;
    // ZBASE-FVW-008
    [Test]
    procedure CreateFileViewer_ValoriIndicati_NomeEAllineamento;

    // ZBASE-FVW-002
    [Test]
    procedure Folder_ConSpaziEBarraMancante_Normalizzata;
    // ZBASE-FVW-002
    [Test]
    procedure Folder_GiaTerminataDaBarra_UnaSolaBarra;
    // ZBASE-FVW-002
    [Test]
    procedure Folder_SoloSpazi_Vuota;

    // ZBASE-FVW-003
    [Test]
    procedure FileName_FileMancante_Svuotato;
    // ZBASE-FVW-001
    [Test]
    procedure FileName_EstensioneDiversaDaPdf_Svuotato;
    // ZBASE-FVW-005
    [Test]
    procedure FileName_PdfPrimaDiInit_NomeConservato;
    // ZBASE-FVW-005
    [Test]
    procedure Init_ConFileNameConservato_CaricaIlPdf;
    // ZBASE-FVW-009
    [Test]
    procedure CloseFile_FileNameAzzerato;

    // ZBASE-FVW-004
    [Test]
    procedure FileName_Locked_Svuotato;
    // ZBASE-FVW-004
    [Test]
    procedure Locked_RitornoAFalso_AvviaIlTimer;
    // ZBASE-FVW-004
    [Test]
    procedure Locked_StessoValore_NonAvviaIlTimer;
    // ZBASE-FVW-004
    [Test]
    procedure Divergenza_DIV_FVW_4_Locked_BarraDiStatoNonAggiornata;
    // ZBASE-FVW-009
    [Test]
    procedure BarraDiStato_LockedDopoPulizia_SegnoDiBlocco;
    // ZBASE-FVW-009
    [Test]
    procedure BarraDiStato_SenzaDocumento_PaginaVuota;

    // ZBASE-FVW-002
    [Test]
    procedure Dataset_NomeRelativoPiuCartella_FileNameComposto;
    // ZBASE-FVW-002
    [Test]
    procedure Dataset_PercorsoCompletoConCartellaVuota_FileNameUgualeAlCampo;
    // ZBASE-FVW-003
    [Test]
    procedure Dataset_CampoVuoto_RiquadroSvuotato;
    // ZBASE-FVW-003
    [Test]
    procedure Dataset_FileInesistente_RiquadroSvuotato;
    // ZBASE-FVW-003
    [Test]
    procedure Dataset_Vuoto_RiquadroSvuotato;
    // ZBASE-FVW-003
    [Test]
    procedure Divergenza_DIV_FVW_3_CampoInesistente_RiquadroNonCambia;
    // ZBASE-FVW-005
    [Test]
    procedure Dataset_CambioDiRecord_AvviaIlTimer;
    // ZBASE-FVW-005
    [Test]
    procedure Dataset_ModificaDiAltroCampo_NonAvviaIlTimer;
    // ZBASE-FVW-005
    [Test]
    procedure Dataset_ModificaDelCampoDelFile_AvviaIlTimer;

    // ZBASE-FVW-006
    [Test]
    procedure Dataset_DistruttoConStessoProprietario_RiquadroScollegato;
    // ZBASE-FVW-006
    [Test]
    procedure Dataset_DistruttoConAltroProprietario_RiquadroScollegato;
    // ZBASE-FVW-006
    [Test]
    procedure ZDataSet_DatasetNullo_Nullo;
    // ZBASE-FVW-006
    [Test]
    procedure Divergenza_DIV_FVW_8_ZDataSet_DatasetDiAltroTipo_EInvalidCast;

    // ZBASE-FVW-007
    [Test]
    procedure Importa_SenzaGestore_NonVisibile;
    // ZBASE-FVW-007
    [Test]
    procedure Importa_ConGestore_Visibile;
    // ZBASE-FVW-007
    [Test]
    procedure ImportaAccept_ConGestore_RiceveMittenteENome;
    // ZBASE-FVW-007
    [Test]
    procedure ImportaAccept_SenzaGestore_NonSollevaEccezioni;

    // ZBASE-FVW-011
    [Test]
    procedure GeneraDaTemplate_SenzaEvento_NonVisibile;
    // ZBASE-FVW-011
    [Test]
    procedure GeneraDaTemplate_ConEvento_VisibileEExecuteLoRichiama;

    // ZBASE-FVW-010
    [Test]
    procedure Interfaccia_TipoDiComponente_File;
    // ZBASE-FVW-010
    [Test]
    procedure Interfaccia_Id_LettoESCritto;
    // ZBASE-FVW-010
    [Test]
    procedure AddAction_AzioneNulla_Nullo;
    // ZBASE-FVW-010
    [Test]
    procedure Divergenza_DIV_FVW_10_Props_SenzaIdENessunDizionario_Nullo;
  end;

implementation

{ TzFileViewerProva }

procedure TzFileViewerProva.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // Application.Handle in un programma di console e' 0: il genitore di comodo e' la
  // finestra di una form di prova (HandleGenitore)
  if Params.WndParent = 0 then
    Params.WndParent := HandleGenitore;
end;

{ TTestzFileViewer }

procedure TTestzFileViewer.Setup;
begin
  FCartella := TPath.Combine(TPath.GetTempPath, 'zFileViewerTest_' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FCartella);

  FFilePdf := TPath.Combine(FCartella, 'a.pdf');
  FFileImmagine := TPath.Combine(FCartella, 'foto.jpg');
  // contenuto finto: il riquadro non lo apre mai (non e' inizializzato)
  TFile.WriteAllText(FFilePdf, 'non e'' un pdf vero');
  TFile.WriteAllText(FFileImmagine, 'non e'' una foto vera');

  FImportMittente := nil;
  FImportNome := '';
  FImportChiamate := 0;
  FGenerazioneChiamate := 0;

  FForm := TForm.CreateNew(nil);
  FForm.HandleNeeded;
  TzFileViewerProva.HandleGenitore := FForm.Handle;
  FViewer := TzFileViewerProva.Create(FForm);
end;

procedure TTestzFileViewer.TearDown;
begin
  FViewer := nil;
  FreeAndNil(FForm);
  if TDirectory.Exists(FCartella) then
    TDirectory.Delete(FCartella, True);
end;

procedure TTestzFileViewer.ImportaGestore(sender: TzFileViewer; const FileName: string);
begin
  FImportMittente := sender;
  FImportNome := FileName;
  Inc(FImportChiamate);
end;

procedure TTestzFileViewer.GenerazioneGestore(sender: TzFileViewer);
begin
  Inc(FGenerazioneChiamate);
end;

function TTestzFileViewer.CreaDataSetVuoto(const NomeCampo: string): TFDMemTable;
begin
  Result := TFDMemTable.Create(nil);
  Result.FieldDefs.Add(NomeCampo, ftString, 260);
  Result.CreateDataSet;
end;

function TTestzFileViewer.CreaDataSet(const NomeCampo, Valore: string): TFDMemTable;
begin
  Result := CreaDataSetVuoto(NomeCampo);
  Result.Append;
  Result.FieldByName(NomeCampo).AsString := Valore;
  Result.Post;
end;

// ZBASE-FVW-008
procedure TTestzFileViewer.Creazione_ValoriIniziali_TuttiVuotiEPredefiniti;
begin
  Assert.AreEqual('FULL_FILE_NAME', FViewer.FieldName);
  Assert.AreEqual('', FViewer.FileName);
  Assert.AreEqual('', FViewer.Folder);
  Assert.AreEqual('', FViewer.FieldNameOID);
  Assert.AreEqual('', FViewer.ID);
  Assert.IsFalse(FViewer.Locked);
  Assert.IsTrue(FViewer.DataSet = nil);
  Assert.IsFalse(Assigned(FViewer.OnImportFile));
  Assert.IsFalse(Assigned(FViewer.OnGenerateFromTemplate));
end;

// ZBASE-FVW-005
procedure TTestzFileViewer.Creazione_TimerSpento;
begin
  Assert.IsFalse(FViewer.Timer.Enabled);
end;

// CreateFileViewer crea il vero TzFileViewer, che in costruzione chiede la finestra
// a un controllo figlio: in un programma di console Application.Handle vale 0 e
// solleva "has no parent window". Per la durata della chiamata la finestra della
// form di prova fa da finestra dell'applicazione.
procedure TTestzFileViewer.ConGenitoreDiComodo(const Chiamata: TProc);
var
  HandleSalvato: HWND;
begin
  HandleSalvato := Application.Handle;
  Application.Handle := FForm.Handle;
  try
    Chiamata();
  finally
    Application.Handle := HandleSalvato;
  end;
end;

// ZBASE-FVW-008
procedure TTestzFileViewer.CreateFileViewer_ValoriPredefiniti_NomeEAllineamento;
var
  Proprietario: TComponent;
  Creato: TzFileViewer;
begin
  Proprietario := TComponent.Create(nil);
  try
    ConGenitoreDiComodo(
      procedure
      begin
        Creato := CreateFileViewer(Proprietario, FForm);
      end);
    Assert.AreEqual('zFileViewer', Creato.Name);
    Assert.AreEqual(Ord(alClient), Ord(Creato.Align));
    Assert.IsTrue(Proprietario.FindComponent('zFileViewer') = Creato);
    Assert.IsTrue(Creato.Owner = Proprietario);
    Assert.IsTrue(Creato.Parent = FForm);
  finally
    // libera anche il riquadro creato, che ha il proprietario come padrone
    Proprietario.Free;
  end;
end;

// ZBASE-FVW-008
procedure TTestzFileViewer.CreateFileViewer_ValoriIndicati_NomeEAllineamento;
var
  Proprietario: TComponent;
  Creato: TzFileViewer;
begin
  Proprietario := TComponent.Create(nil);
  try
    ConGenitoreDiComodo(
      procedure
      begin
        Creato := CreateFileViewer(Proprietario, FForm, 'viewerAllegati', alTop);
      end);
    Assert.AreEqual('viewerAllegati', Creato.Name);
    Assert.AreEqual(Ord(alTop), Ord(Creato.Align));
  finally
    Proprietario.Free;
  end;
end;

// ZBASE-FVW-002
procedure TTestzFileViewer.Folder_ConSpaziEBarraMancante_Normalizzata;
begin
  FViewer.Folder := '  C:\Allegati ';
  Assert.AreEqual('C:\Allegati\', FViewer.Folder);
end;

// ZBASE-FVW-002
procedure TTestzFileViewer.Folder_GiaTerminataDaBarra_UnaSolaBarra;
begin
  FViewer.Folder := 'C:\Allegati\';
  Assert.AreEqual('C:\Allegati\', FViewer.Folder);
end;

// ZBASE-FVW-002
procedure TTestzFileViewer.Folder_SoloSpazi_Vuota;
begin
  FViewer.Folder := 'C:\Allegati\';
  FViewer.Folder := '   ';
  Assert.AreEqual('', FViewer.Folder);
end;

// ZBASE-FVW-003
procedure TTestzFileViewer.FileName_FileMancante_Svuotato;
begin
  FViewer.FileName := TPath.Combine(FCartella, 'non-esiste.pdf');
  Assert.AreEqual('', FViewer.FileName);
end;

// ZBASE-FVW-001
procedure TTestzFileViewer.FileName_EstensioneDiversaDaPdf_Svuotato;
begin
  FViewer.FileName := FFileImmagine;
  Assert.AreEqual('', FViewer.FileName);
end;

// ZBASE-FVW-005
// Senza Init il nome di un PDF esistente resta in FileName, senza caricare niente.
procedure TTestzFileViewer.FileName_PdfPrimaDiInit_NomeConservato;
begin
  FViewer.FileName := FFilePdf;
  Assert.AreEqual(FFilePdf, FViewer.FileName);
end;

// ZBASE-FVW-005
// DIV-FVW-1 corretta: Init carica il nome conservato prima dell'inizializzazione.
procedure TTestzFileViewer.Init_ConFileNameConservato_CaricaIlPdf;
var
  FilePdfVero: string;
begin
  FilePdfVero := TPath.Combine(FCartella, 'vero.pdf');
  TFile.WriteAllText(FilePdfVero,
    '%PDF-1.4'#10 +
    '1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj'#10 +
    '2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj'#10 +
    '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 100 100]>>endobj'#10 +
    'trailer<</Root 1 0 R/Size 4>>'#10 +
    '%%EOF'#10, TEncoding.ASCII);
  FViewer.FileName := FilePdfVero;
  Assert.IsFalse(FViewer.dxPDFViewer.IsDocumentLoaded);

  FViewer.Init;

  Assert.IsTrue(FViewer.dxPDFViewer.IsDocumentLoaded);
end;

// ZBASE-FVW-009
procedure TTestzFileViewer.CloseFile_FileNameAzzerato;
begin
  FViewer.FileName := FFilePdf;
  Assert.AreEqual(FFilePdf, FViewer.FileName);

  FViewer.CloseFile;

  Assert.AreEqual('', FViewer.FileName);
end;

// ZBASE-FVW-004
procedure TTestzFileViewer.FileName_Locked_Svuotato;
begin
  FViewer.Locked := True;
  FViewer.FileName := FFilePdf;
  Assert.AreEqual('', FViewer.FileName);
end;

// ZBASE-FVW-004
procedure TTestzFileViewer.Locked_RitornoAFalso_AvviaIlTimer;
begin
  FViewer.Locked := True;
  Assert.IsFalse(FViewer.Timer.Enabled, 'bloccare non deve far partire la lettura');

  FViewer.Locked := False;

  Assert.IsTrue(FViewer.Timer.Enabled);
end;

// ZBASE-FVW-004
procedure TTestzFileViewer.Locked_StessoValore_NonAvviaIlTimer;
begin
  FViewer.Locked := False;
  Assert.IsFalse(FViewer.Timer.Enabled);
end;

// ZBASE-FVW-004
// Divergenza DIV-FVW-4: SetLocked non aggiorna la barra di stato. Da capovolgere
// (il pannello 1 diventa visibile subito) se il codice viene corretto.
procedure TTestzFileViewer.Divergenza_DIV_FVW_4_Locked_BarraDiStatoNonAggiornata;
begin
  FViewer.Locked := True;
  Assert.IsFalse(FViewer.StatusBar.Panels[1].Visible);
end;

// ZBASE-FVW-009
procedure TTestzFileViewer.BarraDiStato_LockedDopoPulizia_SegnoDiBlocco;
begin
  FViewer.Locked := True;
  // un nome vuoto non esiste e con il blocco comunque svuota: passa da CloseFile,
  // che aggiorna la barra di stato
  FViewer.FileName := '';

  Assert.IsTrue(FViewer.StatusBar.Panels[1].Visible);
  Assert.AreEqual('!', FViewer.StatusBar.Panels[1].Text);
end;

// ZBASE-FVW-009
procedure TTestzFileViewer.BarraDiStato_SenzaDocumento_PaginaVuota;
begin
  FViewer.CloseFile;
  Assert.AreEqual('', FViewer.StatusBar.Panels[2].Text);
  Assert.IsFalse(FViewer.StatusBar.Panels[0].Visible);
end;

// ZBASE-FVW-002
procedure TTestzFileViewer.Dataset_NomeRelativoPiuCartella_FileNameComposto;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('FULL_FILE_NAME', 'a.pdf');
  try
    FViewer.Folder := FCartella;
    FViewer.DataSet := Dati;

    FViewer.TimerTimer(nil);

    Assert.AreEqual(IncludeTrailingPathDelimiter(FCartella) + 'a.pdf', FViewer.FileName);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-002
procedure TTestzFileViewer.Dataset_PercorsoCompletoConCartellaVuota_FileNameUgualeAlCampo;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('FULL_FILE_NAME', FFilePdf);
  try
    FViewer.DataSet := Dati;

    FViewer.TimerTimer(nil);

    Assert.AreEqual(FFilePdf, FViewer.FileName);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-003
procedure TTestzFileViewer.Dataset_CampoVuoto_RiquadroSvuotato;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('FULL_FILE_NAME', '');
  try
    FViewer.FileName := FFilePdf;
    Assert.AreEqual(FFilePdf, FViewer.FileName);
    FViewer.DataSet := Dati;

    FViewer.TimerTimer(nil);

    Assert.AreEqual('', FViewer.FileName);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-003
procedure TTestzFileViewer.Dataset_FileInesistente_RiquadroSvuotato;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('FULL_FILE_NAME', TPath.Combine(FCartella, 'sparito.pdf'));
  try
    FViewer.DataSet := Dati;

    FViewer.TimerTimer(nil);

    Assert.AreEqual('', FViewer.FileName);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-003
procedure TTestzFileViewer.Dataset_Vuoto_RiquadroSvuotato;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSetVuoto('FULL_FILE_NAME');
  try
    FViewer.FileName := FFilePdf;
    Assert.AreEqual(FFilePdf, FViewer.FileName);
    FViewer.DataSet := Dati;

    FViewer.TimerTimer(nil);

    Assert.AreEqual('', FViewer.FileName);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-003
// Divergenza DIV-FVW-3: con un campo FieldName inesistente il riquadro non si
// svuota. Da capovolgere se il codice viene corretto.
procedure TTestzFileViewer.Divergenza_DIV_FVW_3_CampoInesistente_RiquadroNonCambia;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('ALTRO_CAMPO', 'x.pdf');
  try
    FViewer.FileName := FFilePdf;
    FViewer.DataSet := Dati;

    FViewer.TimerTimer(nil);

    Assert.AreEqual(FFilePdf, FViewer.FileName);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-005
procedure TTestzFileViewer.Dataset_CambioDiRecord_AvviaIlTimer;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('FULL_FILE_NAME', 'a.pdf');
  try
    Dati.Append;
    Dati.FieldByName('FULL_FILE_NAME').AsString := 'b.pdf';
    Dati.Post;
    FViewer.DataSet := Dati;
    FViewer.Timer.Enabled := False;

    // il cambio di record e' un evento di scorrimento del dataset
    Dati.First;

    Assert.IsTrue(FViewer.Timer.Enabled);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-005
// DIV-FVW-2 corretta: la modifica di un campo diverso da quello del file non
// riavvia il timer.
procedure TTestzFileViewer.Dataset_ModificaDiAltroCampo_NonAvviaIlTimer;
var
  Dati: TFDMemTable;
begin
  Dati := TFDMemTable.Create(nil);
  try
    Dati.FieldDefs.Add('FULL_FILE_NAME', ftString, 260);
    Dati.FieldDefs.Add('NOTE', ftString, 100);
    Dati.CreateDataSet;
    Dati.Append;
    Dati.FieldByName('FULL_FILE_NAME').AsString := 'a.pdf';
    Dati.Post;
    FViewer.DataSet := Dati;

    // l'ingresso in modifica e' un evento senza campo: il timer si spegne dopo
    Dati.Edit;
    FViewer.Timer.Enabled := False;
    Dati.FieldByName('NOTE').AsString := 'appunto';

    Assert.IsFalse(FViewer.Timer.Enabled);
    Dati.Cancel;
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-005
procedure TTestzFileViewer.Dataset_ModificaDelCampoDelFile_AvviaIlTimer;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSet('FULL_FILE_NAME', 'a.pdf');
  try
    FViewer.DataSet := Dati;

    Dati.Edit;
    FViewer.Timer.Enabled := False;
    Dati.FieldByName('FULL_FILE_NAME').AsString := 'c.pdf';

    Assert.IsTrue(FViewer.Timer.Enabled);
    Dati.Cancel;
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-006
procedure TTestzFileViewer.Dataset_DistruttoConStessoProprietario_RiquadroScollegato;
var
  Proprietario: TComponent;
  Riquadro: TzFileViewer;
  Dati: TFDMemTable;
begin
  Proprietario := TComponent.Create(nil);
  try
    Riquadro := TzFileViewerProva.Create(Proprietario);
    Dati := TFDMemTable.Create(Proprietario);
    Dati.FieldDefs.Add('FULL_FILE_NAME', ftString, 260);
    Dati.CreateDataSet;
    Riquadro.DataSet := Dati;
    Assert.IsTrue(Riquadro.DataSet = Dati);

    Dati.Free;

    Assert.IsTrue(Riquadro.DataSet = nil);
  finally
    Proprietario.Free;
  end;
end;

// ZBASE-FVW-006
// DIV-FVW-6 corretta: anche con un altro proprietario la distruzione del
// dataset scollega il riquadro.
procedure TTestzFileViewer.Dataset_DistruttoConAltroProprietario_RiquadroScollegato;
var
  Dati: TFDMemTable;
begin
  Dati := CreaDataSetVuoto('FULL_FILE_NAME');
  FViewer.DataSet := Dati;

  Dati.Free;

  Assert.IsTrue(FViewer.DataSet = nil);
end;

// ZBASE-FVW-006
procedure TTestzFileViewer.ZDataSet_DatasetNullo_Nullo;
begin
  Assert.IsTrue((FViewer as IzBaseDbComponent).zDataSet = nil);
end;

// ZBASE-FVW-006
// Divergenza DIV-FVW-8: DataSet accetta qualunque TDataSet ma zDataSet lo
// legge con "as TzFbDataSet".
procedure TTestzFileViewer.Divergenza_DIV_FVW_8_ZDataSet_DatasetDiAltroTipo_EInvalidCast;
var
  Dati: TFDMemTable;
  Letto: TzFbDataSet;
begin
  Dati := CreaDataSetVuoto('FULL_FILE_NAME');
  try
    FViewer.DataSet := Dati;

    Assert.WillRaise(
      procedure
      begin
        Letto := (FViewer as IzBaseDbComponent).zDataSet;
      end, EInvalidCast);
  finally
    FViewer.DataSet := nil;
    Dati.Free;
  end;
end;

// ZBASE-FVW-007
procedure TTestzFileViewer.Importa_SenzaGestore_NonVisibile;
begin
  FViewer.ImportaUpdate(nil);
  Assert.IsFalse(FViewer.Importa.Visible);
end;

// ZBASE-FVW-007
procedure TTestzFileViewer.Importa_ConGestore_Visibile;
begin
  FViewer.OnImportFile := ImportaGestore;
  FViewer.ImportaUpdate(nil);
  Assert.IsTrue(FViewer.Importa.Visible);
end;

// ZBASE-FVW-007
procedure TTestzFileViewer.ImportaAccept_ConGestore_RiceveMittenteENome;
begin
  FViewer.OnImportFile := ImportaGestore;
  FViewer.Importa.Dialog.FileName := 'C:\Posta\verbale.pdf';

  FViewer.ImportaAccept(nil);

  Assert.AreEqual(1, FImportChiamate);
  Assert.IsTrue(FImportMittente = FViewer);
  Assert.AreEqual('C:\Posta\verbale.pdf', FImportNome);
end;

// ZBASE-FVW-007
procedure TTestzFileViewer.ImportaAccept_SenzaGestore_NonSollevaEccezioni;
begin
  FViewer.Importa.Dialog.FileName := 'C:\Posta\verbale.pdf';

  Assert.WillNotRaiseAny(
    procedure
    begin
      FViewer.ImportaAccept(nil);
    end);
end;

// ZBASE-FVW-011
procedure TTestzFileViewer.GeneraDaTemplate_SenzaEvento_NonVisibile;
begin
  FViewer.GeneraDaTemplateUpdate(nil);
  Assert.IsFalse(FViewer.GeneraDaTemplate.Visible);
end;

// ZBASE-FVW-011
procedure TTestzFileViewer.GeneraDaTemplate_ConEvento_VisibileEExecuteLoRichiama;
begin
  FViewer.OnGenerateFromTemplate := GenerazioneGestore;

  FViewer.GeneraDaTemplateUpdate(nil);
  Assert.IsTrue(FViewer.GeneraDaTemplate.Visible);

  FViewer.GeneraDaTemplateExecute(nil);
  Assert.AreEqual(1, FGenerazioneChiamate);
end;

// ZBASE-FVW-010
procedure TTestzFileViewer.Interfaccia_TipoDiComponente_File;
begin
  Assert.AreEqual(Ord(ctFile), Ord((FViewer as IzBaseComponent).ComponentType));
end;

// ZBASE-FVW-010
procedure TTestzFileViewer.Interfaccia_Id_LettoESCritto;
begin
  (FViewer as IzBaseComponent).ID := 'FILE_ALLEGATI';
  Assert.AreEqual('FILE_ALLEGATI', FViewer.ID);
  Assert.AreEqual('FILE_ALLEGATI', (FViewer as IzBaseComponent).ID);
end;

// ZBASE-FVW-010
procedure TTestzFileViewer.AddAction_AzioneNulla_Nullo;
begin
  Assert.IsTrue(FViewer.AddAction(nil, nil) = nil);
end;

// ZBASE-FVW-010
// Divergenza DIV-FVW-10: il contratto di IzBaseComponent dice che Props e'
// "sempre assegnato", ma senza ID (o senza dizionario) e' nullo. Da capovolgere
// se il codice viene corretto.
procedure TTestzFileViewer.Divergenza_DIV_FVW_10_Props_SenzaIdENessunDizionario_Nullo;
begin
  Assert.IsTrue((FViewer as IzBaseComponent).Props = nil);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzFileViewer);

end.
