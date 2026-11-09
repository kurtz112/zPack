// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.OkCancel;

// Test DUnitX per zCommon\OkCancel.pas e zCommon\dxFileActions.pas
// (specifica ZCOMMON-OKC, "Pulsanti Ok e Annulla.md"). BOZZA scritta senza
// poterla compilare ne' eseguire.
//
// TOkCancel e' un frame con il suo DFM. Si crea con TOkCancel.Create(nil), senza
// genitore e senza mostrarlo: la risorsa del DFM e' nel codice compilato
// ({$R *.dfm} nella sezione implementation di OkCancel.pas) e TFrame.Create la
// carica anche senza genitore. Il costruttore e Loaded non aprono finestre e non
// chiedono il fuoco (AutoFocus ora si memorizza, DIV-OKC-1). Fuori dalla
// progettazione (csDesigning assente) vale il ramo "runtime" di
// UpdateButtonsState.
//
// Si provano: i valori iniziali (ZCOMMON-OKC-001), la sola lettura (002),
// Applica con ApplyBtnClick (pubblicato: e' nella sezione predefinita della
// classe) (003), DefaultOk e DefaultCancel (004), la disposizione dei pulsanti con
// relazioni fra le coordinate e non con numeri assoluti (005), ResetButtons
// (007) e l'AutoFocus (008).
//
// Le azioni di dxFileActions si provano solo con la creazione senza
// Application: nome e classe della finestra di dialogo (010, 011). La finestra
// non si apre mai.
//
// Restano senza prova, perche' richiedono una finestra, il disegno o il
// progettista: la maniglia di ridimensionamento e WM_NCHITTEST (006), il
// comportamento con csDesigning (009), il click vero dei pulsanti con la chiusura
// della finestra tramite ModalResult, l'apertura delle finestre di file
// (Execute, OnAccept, OnCancel).
//
// Le prove "Divergenza_DIV_OKC_n_*" fotografano il comportamento attuale: vanno
// capovolte quando il codice viene corretto.
//
// RISCHIO NOTO della bozza: se TFrame.Create(nil) di TOkCancel richiedesse una
// finestra principale o un genitore con maniglia (non risulta dal codice), tutte
// le prove della classe TTestOkCancel fallirebbero in Setup.

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  cxButtons,
  dxShellDialogs,
  DUnitX.TestFramework,
  OkCancel,
  dxFileActions;

type
  [TestFixture]
  TTestOkCancel = class
  private
    FFrame: TOkCancel;
    FContatoreApplica: Integer;
    FUltimoMittente: TObject;
  public
    // gestore di prova per OnApply: conta le chiamate e ricorda il mittente
    procedure GestoreApplica(Sender: TObject);

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZCOMMON-OKC-001
    [Test]
    procedure Creazione_ProprietaIniziali_TuttiFalsiEGestoreNonAssegnato;
    // ZCOMMON-OKC-001
    [Test]
    procedure Creazione_Pulsanti_TestiERisultatiModali;
    // ZCOMMON-OKC-001
    [Test]
    procedure Creazione_Visibilita_OkEAnnullaSiApplicaNo;

    // ZCOMMON-OKC-002
    [Test]
    procedure SolaLettura_Vera_OkDiventaChiudiEAnnullaSparisce;
    // ZCOMMON-OKC-002
    [Test]
    procedure SolaLettura_Vera_ApplicaNascostoAncheConGestore;
    // ZCOMMON-OKC-002
    [Test]
    procedure SolaLettura_TornaFalsa_RipristinaOkEAnnulla;
    // ZCOMMON-OKC-002
    [Test]
    procedure SolaLettura_TornaFalsa_ApplicaRiappareSeCeIlGestore;

    // ZCOMMON-OKC-003
    [Test]
    procedure OnApply_Assegnato_ApplicaDiventaVisibile;
    // ZCOMMON-OKC-003
    [Test]
    procedure OnApply_TolttoConNil_ApplicaSparisce;
    // ZCOMMON-OKC-003
    [Test]
    procedure ClickApplica_ChiamaIlGestoreConIlFrameComeMittente;
    // ZCOMMON-OKC-003
    [Test]
    procedure ClickApplica_SenzaGestore_NonSolleva;

    // ZCOMMON-OKC-004
    [Test]
    procedure DefaultOk_Vero_OkDiventaIlPulsantePredefinito;
    // ZCOMMON-OKC-004
    [Test]
    procedure DefaultCancel_Vero_AnnullaRispondeAEsc;
    // ZCOMMON-OKC-004
    [Test]
    procedure DefaultOkEDefaultCancel_TornanoFalsi_SpengonoIPulsanti;

    // ZCOMMON-OKC-005
    [Test]
    procedure Disposizione_TrePulsanti_DaDestraConIntervalloDiCinque;
    // ZCOMMON-OKC-005
    [Test]
    procedure Disposizione_SenzaApplica_OkAccantoAdAnnulla;
    // ZCOMMON-OKC-005
    [Test]
    procedure Disposizione_SolaLettura_OkPrendeIlPostoDiAnnulla;

    // ZCOMMON-OKC-007
    [Test]
    procedure ResetButtons_FrameNormale_OkEAnnullaRestanoVisibili;
    // DIV-OKC-2 (ZCOMMON-OKC-007)
    [Test]
    procedure Divergenza_DIV_OKC_2_ResetButtonsMostraAnnullaInSolaLettura;

    // DIV-OKC-1 (ZCOMMON-OKC-008)
    [Test]
    procedure Divergenza_DIV_OKC_1_AutoFocusNonHaEffetto;
  end;

  [TestFixture]
  TTestdxFileActions = class
  public
    // ZCOMMON-OKC-010
    [Test]
    procedure FileOpen_Creazione_FinestraDiAperturaDevExpress;
    // ZCOMMON-OKC-010
    [Test]
    procedure FileSaveAs_Creazione_FinestraDiSalvataggioDevExpress;
    // ZCOMMON-OKC-011
    [Test]
    procedure OpenPicture_Creazione_FinestraImmaginiDiApertura;
    // ZCOMMON-OKC-011
    [Test]
    procedure SavePicture_Creazione_FinestraImmaginiDiSalvataggio;
  end;

implementation

// TTestOkCancel

procedure TTestOkCancel.GestoreApplica(Sender: TObject);
begin
  Inc(FContatoreApplica);
  FUltimoMittente := Sender;
end;

procedure TTestOkCancel.Setup;
begin
  FContatoreApplica := 0;
  FUltimoMittente := nil;
  FFrame := TOkCancel.Create(nil);
end;

procedure TTestOkCancel.TearDown;
begin
  FreeAndNil(FFrame);
end;

// ZCOMMON-OKC-001

procedure TTestOkCancel.Creazione_ProprietaIniziali_TuttiFalsiEGestoreNonAssegnato;
begin
  Assert.IsFalse(FFrame.ReadOnly, 'ReadOnly');
  Assert.IsFalse(FFrame.DefaultOk, 'DefaultOk');
  Assert.IsFalse(FFrame.DefaultCancel, 'DefaultCancel');
  Assert.IsFalse(FFrame.AutoFocus, 'AutoFocus');
  Assert.IsFalse(Assigned(FFrame.OnApply), 'OnApply');
  Assert.IsFalse(FFrame.AutoScroll, 'AutoScroll');
end;

procedure TTestOkCancel.Creazione_Pulsanti_TestiERisultatiModali;
begin
  Assert.AreEqual('Ok', FFrame.OkBtn.Caption, 'testo di Ok');
  Assert.AreEqual('Annulla', FFrame.CancelBtn.Caption, 'testo di Annulla');
  Assert.AreEqual('Applica', FFrame.ApplyBtn.Caption, 'testo di Applica');

  Assert.AreEqual(Integer(mrOk), Integer(FFrame.OkBtn.ModalResult), 'risultato di Ok');
  Assert.AreEqual(Integer(mrCancel), Integer(FFrame.CancelBtn.ModalResult), 'risultato di Annulla');
  // Applica non chiude la finestra
  Assert.AreEqual(Integer(mrNone), Integer(FFrame.ApplyBtn.ModalResult), 'Applica non ha risultato modale');
end;

procedure TTestOkCancel.Creazione_Visibilita_OkEAnnullaSiApplicaNo;
begin
  Assert.IsTrue(FFrame.OkBtn.Visible, 'Ok visibile');
  Assert.IsTrue(FFrame.CancelBtn.Visible, 'Annulla visibile');
  Assert.IsFalse(FFrame.ApplyBtn.Visible, 'Applica nascosto senza OnApply');
end;

// ZCOMMON-OKC-002

procedure TTestOkCancel.SolaLettura_Vera_OkDiventaChiudiEAnnullaSparisce;
begin
  FFrame.ReadOnly := True;

  Assert.AreEqual('Chiudi', FFrame.OkBtn.Caption, 'testo del pulsante principale');
  Assert.IsFalse(FFrame.CancelBtn.Visible, 'Annulla nascosto');
  // il pulsante resta quello di conferma: ShowModal restituisce mrOk
  Assert.AreEqual(Integer(mrOk), Integer(FFrame.OkBtn.ModalResult), 'Chiudi restituisce mrOk');
end;

procedure TTestOkCancel.SolaLettura_Vera_ApplicaNascostoAncheConGestore;
begin
  FFrame.OnApply := GestoreApplica;
  Assert.IsTrue(FFrame.ApplyBtn.Visible, 'prima della sola lettura Applica e'' visibile');

  FFrame.ReadOnly := True;

  Assert.IsFalse(FFrame.ApplyBtn.Visible, 'in sola lettura Applica e'' nascosto');
end;

procedure TTestOkCancel.SolaLettura_TornaFalsa_RipristinaOkEAnnulla;
begin
  FFrame.ReadOnly := True;

  FFrame.ReadOnly := False;

  Assert.AreEqual('Ok', FFrame.OkBtn.Caption, 'testo di Ok');
  Assert.IsTrue(FFrame.CancelBtn.Visible, 'Annulla visibile');
end;

procedure TTestOkCancel.SolaLettura_TornaFalsa_ApplicaRiappareSeCeIlGestore;
begin
  FFrame.OnApply := GestoreApplica;
  FFrame.ReadOnly := True;

  FFrame.ReadOnly := False;

  Assert.IsTrue(FFrame.ApplyBtn.Visible, 'Applica torna visibile');
end;

// ZCOMMON-OKC-003

procedure TTestOkCancel.OnApply_Assegnato_ApplicaDiventaVisibile;
begin
  Assert.IsFalse(FFrame.ApplyBtn.Visible, 'prima');

  FFrame.OnApply := GestoreApplica;

  Assert.IsTrue(FFrame.ApplyBtn.Visible, 'dopo');
end;

procedure TTestOkCancel.OnApply_TolttoConNil_ApplicaSparisce;
begin
  FFrame.OnApply := GestoreApplica;

  FFrame.OnApply := nil;

  Assert.IsFalse(FFrame.ApplyBtn.Visible);
end;

procedure TTestOkCancel.ClickApplica_ChiamaIlGestoreConIlFrameComeMittente;
begin
  FFrame.OnApply := GestoreApplica;

  // ApplyBtnClick e' il gestore di OnClick di ApplyBtn nel DFM
  FFrame.ApplyBtnClick(FFrame.ApplyBtn);

  Assert.AreEqual(1, FContatoreApplica, 'numero di chiamate');
  Assert.IsTrue(FUltimoMittente = FFrame, 'il mittente e'' il frame');
end;

procedure TTestOkCancel.ClickApplica_SenzaGestore_NonSolleva;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FFrame.ApplyBtnClick(FFrame.ApplyBtn);
    end);
end;

// ZCOMMON-OKC-004

procedure TTestOkCancel.DefaultOk_Vero_OkDiventaIlPulsantePredefinito;
begin
  Assert.IsFalse(FFrame.OkBtn.Default, 'prima');

  FFrame.DefaultOk := True;

  Assert.IsTrue(FFrame.DefaultOk, 'proprieta''');
  Assert.IsTrue(FFrame.OkBtn.Default, 'pulsante');
end;

procedure TTestOkCancel.DefaultCancel_Vero_AnnullaRispondeAEsc;
begin
  Assert.IsFalse(FFrame.CancelBtn.Cancel, 'prima');

  FFrame.DefaultCancel := True;

  Assert.IsTrue(FFrame.DefaultCancel, 'proprieta''');
  Assert.IsTrue(FFrame.CancelBtn.Cancel, 'pulsante');
end;

procedure TTestOkCancel.DefaultOkEDefaultCancel_TornanoFalsi_SpengonoIPulsanti;
begin
  FFrame.DefaultOk := True;
  FFrame.DefaultCancel := True;

  FFrame.DefaultOk := False;
  FFrame.DefaultCancel := False;

  Assert.IsFalse(FFrame.OkBtn.Default, 'Ok');
  Assert.IsFalse(FFrame.CancelBtn.Cancel, 'Annulla');
end;

// ZCOMMON-OKC-005

procedure TTestOkCancel.Disposizione_TrePulsanti_DaDestraConIntervalloDiCinque;
begin
  FFrame.OnApply := GestoreApplica;

  Assert.AreEqual(FFrame.PaintBox.Left, FFrame.CancelBtn.Left + FFrame.CancelBtn.Width + 5, 'Annulla contro la maniglia');
  Assert.AreEqual(FFrame.CancelBtn.Left, FFrame.OkBtn.Left + FFrame.OkBtn.Width + 5, 'Ok a sinistra di Annulla');
  Assert.AreEqual(FFrame.OkBtn.Left, FFrame.ApplyBtn.Left + FFrame.ApplyBtn.Width + 5, 'Applica a sinistra di Ok');
end;

procedure TTestOkCancel.Disposizione_SenzaApplica_OkAccantoAdAnnulla;
begin
  Assert.AreEqual(FFrame.PaintBox.Left, FFrame.CancelBtn.Left + FFrame.CancelBtn.Width + 5, 'Annulla contro la maniglia');
  Assert.AreEqual(FFrame.CancelBtn.Left, FFrame.OkBtn.Left + FFrame.OkBtn.Width + 5, 'Ok a sinistra di Annulla');
end;

procedure TTestOkCancel.Disposizione_SolaLettura_OkPrendeIlPostoDiAnnulla;
begin
  FFrame.ReadOnly := True;

  Assert.AreEqual(FFrame.PaintBox.Left, FFrame.OkBtn.Left + FFrame.OkBtn.Width + 5, 'Chiudi contro la maniglia');
end;

// ZCOMMON-OKC-007

procedure TTestOkCancel.ResetButtons_FrameNormale_OkEAnnullaRestanoVisibili;
begin
  FFrame.ResetButtons;

  Assert.IsTrue(FFrame.OkBtn.Visible, 'Ok');
  Assert.IsTrue(FFrame.CancelBtn.Visible, 'Annulla');
end;

procedure TTestOkCancel.Divergenza_DIV_OKC_2_ResetButtonsMostraAnnullaInSolaLettura;
begin
  FFrame.ReadOnly := True;
  Assert.IsFalse(FFrame.CancelBtn.Visible, 'in sola lettura Annulla e'' nascosto');

  FFrame.ResetButtons;

  // DIV-OKC-2 corretta: ResetButtons ricalcola la visibilita', Annulla resta
  // nascosto in sola lettura.
  Assert.IsFalse(FFrame.CancelBtn.Visible, 'DIV-OKC-2: Annulla resta nascosto');
end;

// ZCOMMON-OKC-008

procedure TTestOkCancel.Divergenza_DIV_OKC_1_AutoFocusNonHaEffetto;
begin
  FFrame.AutoFocus := True;

  // DIV-OKC-1 corretta: SetAutoFocus memorizza il valore.
  Assert.IsTrue(FFrame.AutoFocus, 'DIV-OKC-1: il valore viene memorizzato');
end;

// TTestdxFileActions

procedure TTestdxFileActions.FileOpen_Creazione_FinestraDiAperturaDevExpress;
var
  Azione: TdxFileOpen;
begin
  Azione := TdxFileOpen.Create(nil);
  try
    Assert.IsTrue(Assigned(Azione.Dialog), 'finestra');
    Assert.IsTrue(Azione.Dialog.ClassType = TdxOpenFileDialog, 'classe della finestra');
    Assert.AreEqual('dxOpenDialog', Azione.Dialog.Name, 'nome della finestra');
  finally
    Azione.Free;
  end;
end;

procedure TTestdxFileActions.FileSaveAs_Creazione_FinestraDiSalvataggioDevExpress;
var
  Azione: TdxFileSaveAs;
begin
  Azione := TdxFileSaveAs.Create(nil);
  try
    Assert.IsTrue(Assigned(Azione.Dialog), 'finestra');
    Assert.IsTrue(Azione.Dialog.ClassType = TdxSaveFileDialog, 'classe della finestra');
    Assert.AreEqual('dxSaveDialog', Azione.Dialog.Name, 'nome della finestra');
  finally
    Azione.Free;
  end;
end;

procedure TTestdxFileActions.OpenPicture_Creazione_FinestraImmaginiDiApertura;
var
  Azione: TdxOpenPicture;
begin
  Azione := TdxOpenPicture.Create(nil);
  try
    Assert.IsTrue(Assigned(Azione.Dialog), 'finestra');
    Assert.IsTrue(Azione.Dialog.ClassType = TdxOpenPictureDialog, 'classe della finestra');
  finally
    Azione.Free;
  end;
end;

procedure TTestdxFileActions.SavePicture_Creazione_FinestraImmaginiDiSalvataggio;
var
  Azione: TdxSavePicture;
begin
  Azione := TdxSavePicture.Create(nil);
  try
    Assert.IsTrue(Assigned(Azione.Dialog), 'finestra');
    Assert.IsTrue(Azione.Dialog.ClassType = TdxSavePictureDialog, 'classe della finestra');
  finally
    Azione.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestOkCancel);
  TDUnitX.RegisterTestFixture(TTestdxFileActions);

end.
