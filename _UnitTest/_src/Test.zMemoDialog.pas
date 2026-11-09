// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zMemoDialog;

// Test DUnitX per zBase\zMemoDialog.pas (specifica ZBASE-MDG, "Finestra di testo
// libero.md"). BOZZA scritta senza poterla compilare ne' eseguire.
//
// Si provano solo le parti che non mostrano nessuna finestra e non aprono
// nessuna domanda all'utente:
// - TzMemoDialog: valori iniziali e copia delle righe (ZBASE-MDG-008);
// - zExecuteMemoDialog con una lista nulla, che si ferma prima di ShowModal
//   (ZBASE-MDG-001, DIV-MDG-1);
// - TzMemoForm creata con Create(nil) e mai mostrata: sola lettura e
//   SostituisciUpdate (ZBASE-MDG-002), CloseQuery nei tre casi che non chiedono
//   conferma (ZBASE-MDG-004), apertura e salvataggio su file (ZBASE-MDG-007).
//
// CloseQuery e' protetto: si arriva con una classe di prova derivata
// (TzMemoFormProva). La finestra non e' mai stata eseguita, quindi il testo di
// apertura (TestoIniziale) e' vuoto: i tre casi si ottengono con testo
// modificato e ModalResult = mrOk, con memo di sola lettura, o con testo vuoto.
// Il caso che apre la domanda (ConfirmYesNoCancel) non si prova mai: sarebbe un
// dialogo modale in una console.
//
// Restano senza prova, perche' richiedono ShowModal o la domanda: Execute e quel
// che fa prima di mostrare (copia delle proprieta' del memo, a capo automatico,
// azioni personalizzate, InitCustomActions e' privato), la domanda all'uscita,
// l'azione iniziale, la ricerca e la sostituzione, il risultato delle tre
// funzioni, TzMemoDialog.Execute.
//
// Le prove "Divergenza_DIV_MDG_n_*" fotografano il comportamento attuale: vanno
// capovolte quando il codice viene corretto. Le due sulla codifica dipendono
// dalla tabella ANSI della macchina e si saltano con la tabella UTF-8 o
// dell'Estremo Oriente.
//
// RISCHIO NOTO della bozza: la classe derivata TzMemoFormProva non ha un proprio
// DFM; la VCL carica quello di TzMemoForm risalendo la catena delle classi. Se
// alla compilazione o all'esecuzione non funzionasse, si possono togliere le
// tre prove su CloseQuery.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.UITypes,
  Winapi.Windows,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  cxMemo,
  cxTextEdit,
  dxBar,
  dxFileActions,
  DUnitX.TestFramework,
  zMemoDialog;

type
  // Finestra di prova: espone la parte protetta di TzMemoForm.
  TzMemoFormProva = class(TzMemoForm)
  public
    function ChiediChiusura: Boolean;
  end;

  [TestFixture]
  TTestzMemoDialogComponente = class
  public
    // ZBASE-MDG-008
    [Test]
    procedure Creazione_ValoriIniziali_VuotiENessunEvento;
    // ZBASE-MDG-008
    [Test]
    procedure Lines_Assegnazione_CopiaLeRighe;
    // ZBASE-MDG-008
    [Test]
    procedure Caption_Assegnazione_LettaIndietro;
    // ZBASE-MDG-001
    [Test]
    procedure ListaNulla_RestituisceFalsoSenzaAprire;
  end;

  [TestFixture]
  TTestzMemoDialogFinestra = class
  private
    FForm: TzMemoFormProva;
    FCartella: string;
    function PercorsoFile(const Nome: string): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-MDG-002
    [Test]
    procedure Creazione_Memo_ModificabileConDueBarreDiScorrimento;
    // ZBASE-MDG-002
    [Test]
    procedure Creazione_BarreDeiComandi_NonARigaIntera;
    // ZBASE-MDG-002
    [Test]
    procedure SostituisciUpdate_MemoModificabile_Attiva;
    // ZBASE-MDG-002
    [Test]
    procedure SostituisciUpdate_MemoDiSolaLettura_Disattivata;

    // ZBASE-MDG-004
    [Test]
    procedure CloseQuery_ConOkEDopoModifica_NessunaDomandaEChiusuraConsentita;
    // ZBASE-MDG-004
    [Test]
    procedure CloseQuery_MemoDiSolaLettura_NessunaDomandaEChiusuraConsentita;
    // ZBASE-MDG-004
    [Test]
    procedure CloseQuery_TestoInvariato_NessunaDomandaEChiusuraConsentita;

    // ZBASE-MDG-007
    [Test]
    procedure FileOpenAccept_FileDiTestoSemplice_MemoConLeDueRighe;
    // ZBASE-MDG-007
    [Test]
    procedure FileSaveAsAccept_TestoAscii_FileSenzaBom;
    // ZBASE-MDG-007
    [Test]
    procedure Apertura_FileUtf8SenzaBom_LetteraAccentataCorretta;
    // ZBASE-MDG-007
    [Test]
    procedure Apertura_FileAnsiSenzaBom_LetteraAccentataCorretta;
    // ZBASE-MDG-007
    [Test]
    procedure Salvataggio_CarattereFuoriTabella_ScrittoInUtf8;
  end;

implementation

{ TzMemoFormProva }

function TzMemoFormProva.ChiediChiusura: Boolean;
begin
  Result := CloseQuery;
end;

{ TTestzMemoDialogComponente }

// ZBASE-MDG-008
procedure TTestzMemoDialogComponente.Creazione_ValoriIniziali_VuotiENessunEvento;
var
  Dialogo: TzMemoDialog;
begin
  Dialogo := TzMemoDialog.Create(nil);
  try
    Assert.AreEqual('', Dialogo.Caption);
    Assert.AreEqual(0, Dialogo.Lines.Count);
    Assert.IsFalse(Assigned(Dialogo.OnInitDialog));
    Assert.IsFalse(Assigned(Dialogo.OnCloseDialog));
  finally
    Dialogo.Free;
  end;
end;

// ZBASE-MDG-008
procedure TTestzMemoDialogComponente.Lines_Assegnazione_CopiaLeRighe;
var
  Dialogo: TzMemoDialog;
  Origine: TStringList;
begin
  Dialogo := TzMemoDialog.Create(nil);
  Origine := TStringList.Create;
  try
    Origine.Add('prima');
    Origine.Add('seconda');

    Dialogo.Lines := Origine;
    // la lista originale cambia: la copia nel componente no
    Origine.Clear;
    Origine.Add('altro');

    Assert.AreEqual(2, Dialogo.Lines.Count);
    Assert.AreEqual('prima', Dialogo.Lines[0]);
    Assert.AreEqual('seconda', Dialogo.Lines[1]);
  finally
    Origine.Free;
    Dialogo.Free;
  end;
end;

// ZBASE-MDG-008
procedure TTestzMemoDialogComponente.Caption_Assegnazione_LettaIndietro;
var
  Dialogo: TzMemoDialog;
begin
  Dialogo := TzMemoDialog.Create(nil);
  try
    Dialogo.Caption := 'Esito valutazione';
    Assert.AreEqual('Esito valutazione', Dialogo.Caption);
  finally
    Dialogo.Free;
  end;
end;

// ZBASE-MDG-001
// DIV-MDG-1 corretta: con una lista nulla la forma TStrings restituisce falso
// senza aprire la finestra.
procedure TTestzMemoDialogComponente.ListaNulla_RestituisceFalsoSenzaAprire;
var
  Righe: TStrings;
begin
  Righe := nil;

  Assert.IsFalse(zExecuteMemoDialog(Righe, 'Titolo'));
end;

{ TTestzMemoDialogFinestra }

procedure TTestzMemoDialogFinestra.Setup;
begin
  FCartella := TPath.Combine(TPath.GetTempPath, 'zMemoDialogTest_' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FCartella);
  FForm := TzMemoFormProva.Create(nil);
end;

procedure TTestzMemoDialogFinestra.TearDown;
begin
  FreeAndNil(FForm);
  if TDirectory.Exists(FCartella) then
    TDirectory.Delete(FCartella, True);
end;

function TTestzMemoDialogFinestra.PercorsoFile(const Nome: string): string;
begin
  Result := TPath.Combine(FCartella, Nome);
end;

// ZBASE-MDG-002
procedure TTestzMemoDialogFinestra.Creazione_Memo_ModificabileConDueBarreDiScorrimento;
begin
  Assert.IsFalse(FForm.cxMemo.Properties.ReadOnly);
  Assert.AreEqual(Ord(ssBoth), Ord(FForm.cxMemo.Properties.ScrollBars));
end;

// ZBASE-MDG-002
procedure TTestzMemoDialogFinestra.Creazione_BarreDeiComandi_NonARigaIntera;
begin
  Assert.IsFalse(FForm.dxBarManagerBarToolbar.WholeRow);
  Assert.AreEqual(0, FForm.dxBarManagerBarToolbar.Row);
  Assert.IsFalse(FForm.dxBarManagerBarFree.WholeRow);
  Assert.AreEqual(0, FForm.dxBarManagerBarFree.Row);
end;

// ZBASE-MDG-002
procedure TTestzMemoDialogFinestra.SostituisciUpdate_MemoModificabile_Attiva;
begin
  FForm.cxMemo.Properties.ReadOnly := False;
  FForm.SostituisciUpdate(nil);
  Assert.IsTrue(FForm.Sostituisci.Enabled);
end;

// ZBASE-MDG-002
procedure TTestzMemoDialogFinestra.SostituisciUpdate_MemoDiSolaLettura_Disattivata;
begin
  FForm.cxMemo.Properties.ReadOnly := True;
  FForm.SostituisciUpdate(nil);
  Assert.IsFalse(FForm.Sostituisci.Enabled);
end;

// ZBASE-MDG-004
procedure TTestzMemoDialogFinestra.CloseQuery_ConOkEDopoModifica_NessunaDomandaEChiusuraConsentita;
begin
  FForm.cxMemo.Text := 'testo modificato';
  FForm.ModalResult := mrOk;

  Assert.IsTrue(FForm.ChiediChiusura);
end;

// ZBASE-MDG-004
procedure TTestzMemoDialogFinestra.CloseQuery_MemoDiSolaLettura_NessunaDomandaEChiusuraConsentita;
begin
  FForm.cxMemo.Properties.ReadOnly := True;
  FForm.cxMemo.Text := 'testo modificato';

  Assert.IsTrue(FForm.ChiediChiusura);
end;

// ZBASE-MDG-004
procedure TTestzMemoDialogFinestra.CloseQuery_TestoInvariato_NessunaDomandaEChiusuraConsentita;
begin
  // la finestra non e' mai stata eseguita: il testo di apertura e' vuoto, come
  // il testo del memo
  FForm.cxMemo.Text := '';

  Assert.IsTrue(FForm.ChiediChiusura);
end;

// ZBASE-MDG-007
procedure TTestzMemoDialogFinestra.FileOpenAccept_FileDiTestoSemplice_MemoConLeDueRighe;
var
  NomeFile: string;
begin
  NomeFile := PercorsoFile('note.txt');
  TFile.WriteAllBytes(NomeFile, TEncoding.ASCII.GetBytes('riga1' + #13#10 + 'riga2'));
  FForm.FileOpen.Dialog.FileName := NomeFile;

  FForm.FileOpenAccept(nil);

  Assert.AreEqual(2, FForm.cxMemo.Lines.Count);
  Assert.AreEqual('riga1', FForm.cxMemo.Lines[0]);
  Assert.AreEqual('riga2', FForm.cxMemo.Lines[1]);
end;

// ZBASE-MDG-007
procedure TTestzMemoDialogFinestra.FileSaveAsAccept_TestoAscii_FileSenzaBom;
var
  NomeFile: string;
  Contenuto: TBytes;
begin
  NomeFile := PercorsoFile('uscita.txt');
  FForm.cxMemo.Text := 'abc';
  FForm.FileSaveAs.Dialog.FileName := NomeFile;

  FForm.FileSaveAsAccept(nil);

  Contenuto := TFile.ReadAllBytes(NomeFile);
  // TStrings.SaveToFile aggiunge il fine riga dopo l'ultima riga: si guardano
  // solo i primi tre byte
  Assert.IsTrue(Length(Contenuto) >= 3);
  Assert.AreEqual(Integer($61), Integer(Contenuto[0]));
  Assert.AreEqual(Integer($62), Integer(Contenuto[1]));
  Assert.AreEqual(Integer($63), Integer(Contenuto[2]));
end;

// ZBASE-MDG-007
// DIV-MDG-2 corretta: un file UTF-8 senza BOM e' riconosciuto come UTF-8.
procedure TTestzMemoDialogFinestra.Apertura_FileUtf8SenzaBom_LetteraAccentataCorretta;
var
  NomeFile: string;
  Contenuto: TBytes;
begin
  NomeFile := PercorsoFile('utf8.txt');
  // "e" accentata in UTF-8, senza BOM: i due byte C3 A8
  SetLength(Contenuto, 2);
  Contenuto[0] := $C3;
  Contenuto[1] := $A8;
  TFile.WriteAllBytes(NomeFile, Contenuto);
  FForm.FileOpen.Dialog.FileName := NomeFile;

  FForm.FileOpenAccept(nil);

  Assert.AreEqual(string(#$00E8), FForm.cxMemo.Lines[0]);
end;

// ZBASE-MDG-007
// Un file che non e' UTF-8 valido (e accentata ANSI: il solo byte E8) si legge
// ancora con la tabella ANSI del sistema.
procedure TTestzMemoDialogFinestra.Apertura_FileAnsiSenzaBom_LetteraAccentataCorretta;
var
  NomeFile: string;
  Contenuto: TBytes;
begin
  if GetACP <> 1252 then
  begin
    Assert.Pass('la tabella ANSI del sistema non e'' la 1252, prova non applicabile');
    Exit;
  end;

  NomeFile := PercorsoFile('ansi.txt');
  SetLength(Contenuto, 1);
  Contenuto[0] := $E8;
  TFile.WriteAllBytes(NomeFile, Contenuto);
  FForm.FileOpen.Dialog.FileName := NomeFile;

  FForm.FileOpenAccept(nil);

  Assert.AreEqual(string(#$00E8), FForm.cxMemo.Lines[0]);
end;

// ZBASE-MDG-007
// DIV-MDG-2 corretta: il salvataggio scrive UTF-8 senza BOM e un carattere
// fuori dalla tabella ANSI si conserva.
procedure TTestzMemoDialogFinestra.Salvataggio_CarattereFuoriTabella_ScrittoInUtf8;
var
  NomeFile: string;
  Contenuto: TBytes;
begin
  NomeFile := PercorsoFile('cinese.txt');
  // 'a', ideogramma U+4E2D, 'b'
  FForm.cxMemo.Text := 'a' + Char($4E2D) + 'b';
  FForm.FileSaveAs.Dialog.FileName := NomeFile;

  FForm.FileSaveAsAccept(nil);

  Contenuto := TFile.ReadAllBytes(NomeFile);
  // 'a', E4 B8 AD (U+4E2D in UTF-8), 'b'
  Assert.IsTrue(Length(Contenuto) >= 5);
  Assert.AreEqual(Integer($61), Integer(Contenuto[0]));
  Assert.AreEqual(Integer($E4), Integer(Contenuto[1]));
  Assert.AreEqual(Integer($B8), Integer(Contenuto[2]));
  Assert.AreEqual(Integer($AD), Integer(Contenuto[3]));
  Assert.AreEqual(Integer($62), Integer(Contenuto[4]));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzMemoDialogComponente);
  TDUnitX.RegisterTestFixture(TTestzMemoDialogFinestra);

end.
