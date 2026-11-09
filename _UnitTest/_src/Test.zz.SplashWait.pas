// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-19
// ---------------------------------------------------------------------------
unit Test.zz.SplashWait;

// Test DUnitX della finestra di attesa di zz.SplashWait quando la finestra
// DevExpress e' stata persa (Mantis #238): TdxWaitForm disegna in un thread
// suo, e se quel thread finisce l'oggetto conserva l'handle vecchio e ogni
// chiamata solleva "PostMessage failed. Win32Error=1400".
//
// Il guasto si riproduce senza aspettare un errore di disegno: si chiude il
// thread della finestra con WM_QUIT, che e' quello che fa il suo ciclo dei
// messaggi quando termina per un'eccezione.
//
// I test creano finestre vere: il runner deve girare in una sessione con
// desktop, non come servizio.
//
// FORM BERSAGLIO NASCOSTO: zBuilder avvia il runner con STARTF_USESHOWWINDOW
// e SW_HIDE, e Windows applica quel valore alla prima ShowWindow del
// processo, cioe' al form del primo test che ne mostra uno. Il form restava
// invisibile, TSmartWaitForm lo scartava come bersaglio e la finestra di
// attesa non compariva: il primo test falliva, gli altri passavano. Setup
// rimostra il form se non e' a video, e LoseWaitWindow controlla che la
// finestra di attesa fosse comparsa prima di perderla, cosi' un bersaglio
// non valido non passa piu' per una finestra persa.

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Types,
  Vcl.Forms,
  DUnitX.TestFramework,
  dxGDIPlusClasses,
  dxSplashForms,
  zz.SplashWait;

type
  [TestFixture]
  TTestSmartWaitForm = class
  private
    FForm: TForm;
    // Chiude il thread di disegno della finestra di attesa predefinita del
    // gestore, dopo averla creata con una comparsa
    procedure LoseWaitWindow;
    function WaitWindowAlive: Boolean;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Mantis #238 - 2026-10-13: Show dopo la perdita della finestra
    [Test]
    procedure Show_FinestraPersa_RicreaENonSolleva;
    // Mantis #238 - 2026-10-13: Update e Hide con la finestra persa a video
    [Test]
    procedure UpdateEHide_FinestraPersaAVideo_NonSollevano;
    // Mantis #238 - 2026-10-13: StartWait fuori dal try non sbilancia il contatore
    [Test]
    procedure Contatore_DopoGuasto_Bilanciato;
    // Mantis #238 - 2026-10-13: dialogo aperto con la finestra persa a video
    [Test]
    procedure SuspendForDialog_FinestraPersa_NonSolleva;

    // Animazione senza immagine: riceve il cerchio SVG di un fotogramma al
    // posto della GIF predefinita, che blocca la ricomparsa dopo una pausa
    [Test]
    procedure UseStaticAnimation_SenzaImmagine_UnFotogramma;
    // Un'immagine scelta nella definizione non va sostituita
    [Test]
    procedure UseStaticAnimation_ConImmagine_NonToccata;
    // La Show della finestra di attesa assegna il cerchio da sola
    [Test]
    procedure Show_AnimazioniDellaFinestraConImmagine;
  end;

implementation

type
  // Thread e Wnd sono strict protected in TdxSplashFormBase: li raggiunge un
  // metodo di una discendente
  TWaitFormProbe = class(TdxWaitForm)
  public
    procedure StopDrawingThread;
    function WindowAlive: Boolean;
  end;

procedure TWaitFormProbe.StopDrawingThread;
var
  Limit: Cardinal;
begin
  if Thread = nil then
    Exit;

  PostThreadMessage(Thread.ThreadID, WM_QUIT, 0, 0);
  // Attesa con un limite: un thread che non finisce non deve bloccare il runner
  Limit := TThread.GetTickCount + 5000;
  while not Thread.Finished and (TThread.GetTickCount < Limit) do
    Sleep(10);
end;

function TWaitFormProbe.WindowAlive: Boolean;
begin
  Result := (Thread <> nil) and not Thread.Finished and IsWindow(Wnd);
end;

{ TTestSmartWaitForm }

procedure TTestSmartWaitForm.Setup;
begin
  FForm := TForm.CreateNew(nil);
  FForm.SetBounds(100, 100, 480, 320);
  FForm.Caption := 'Bersaglio dell''attesa';
  FForm.Show;
  // La prima ShowWindow del processo usa il valore di avvio (SW_HIDE sotto
  // zBuilder): la seconda chiamata lo esegue davvero
  if not IsWindowVisible(FForm.Handle) or IsIconic(FForm.Handle) then
    ShowWindow(FForm.Handle, SW_SHOWNORMAL);
  Application.ProcessMessages;
  Assert.IsTrue(IsWindowVisible(FForm.Handle) and not IsIconic(FForm.Handle),
    'Il form bersaglio dell''attesa non e'' a video');
end;

procedure TTestSmartWaitForm.TearDown;
begin
  try
    TSmartWaitForm.Hide(True);
  except
    // Senza correzione anche la chiusura solleva: non deve coprire l'esito
  end;
  FreeAndNil(FForm);
  Application.ProcessMessages;
end;

procedure TTestSmartWaitForm.LoseWaitWindow;
begin
  // Senza finestra a video non c'e' niente da perdere: il test proverebbe
  // la comparsa mancata, non il ripristino
  Assert.IsTrue(WaitWindowAlive, 'La finestra di attesa doveva essere a video prima del guasto');
  TWaitFormProbe(TdxSplashFormManager.WaitForm).StopDrawingThread;
  Assert.IsFalse(WaitWindowAlive, 'La finestra di attesa doveva risultare persa');
end;

function TTestSmartWaitForm.WaitWindowAlive: Boolean;
begin
  // Dopo una sostituzione la finestra nuova diventa la predefinita del
  // gestore, se lo era quella persa
  Result := TWaitFormProbe(TdxSplashFormManager.WaitForm).WindowAlive;
end;

procedure TTestSmartWaitForm.Show_FinestraPersa_RicreaENonSolleva;
begin
  TSmartWaitForm.Show(FForm, 'Prima attesa');
  TSmartWaitForm.Hide;
  LoseWaitWindow;

  Assert.WillNotRaiseAny(
    procedure
    begin
      TSmartWaitForm.Show(FForm, 'Seconda attesa');
    end);
  Assert.IsTrue(TSmartWaitForm.IsShowing);
  Assert.IsTrue(WaitWindowAlive, 'La finestra di attesa doveva essere ricreata');

  Assert.WillNotRaiseAny(
    procedure
    begin
      TSmartWaitForm.Hide;
    end);
  Assert.IsFalse(TSmartWaitForm.IsShowing);
end;

procedure TTestSmartWaitForm.UpdateEHide_FinestraPersaAVideo_NonSollevano;
begin
  TSmartWaitForm.Show(FForm, 'Breve');
  LoseWaitWindow;

  // Il testo piu' lungo allarga la finestra: SetBounds passa dal thread
  Assert.WillNotRaiseAny(
    procedure
    begin
      TSmartWaitForm.Update('Un messaggio molto piu'' lungo del primo, che allarga la finestra');
    end);
  Assert.WillNotRaiseAny(
    procedure
    begin
      TSmartWaitForm.Hide;
    end);
  Assert.IsFalse(TSmartWaitForm.IsShowing);
end;

procedure TTestSmartWaitForm.Contatore_DopoGuasto_Bilanciato;
var
  Index: Integer;
begin
  TSmartWaitForm.Show(FForm, 'Attesa');
  TSmartWaitForm.Hide;
  LoseWaitWindow;

  // Come StartWait fuori dal try: la Hide arriva solo se la Show e' tornata
  for Index := 1 to 3 do
  begin
    try
      TSmartWaitForm.Show(FForm, 'Attesa');
      TSmartWaitForm.Hide;
    except
    end;
    Assert.IsFalse(TSmartWaitForm.IsShowing, Format('Contatore sbilanciato al giro %d', [Index]));
  end;

  TSmartWaitForm.Show(FForm, 'Ultima attesa');
  Assert.IsTrue(WaitWindowAlive, 'Dopo il guasto la finestra di attesa deve tornare a video');
  TSmartWaitForm.Hide;
end;

procedure TTestSmartWaitForm.SuspendForDialog_FinestraPersa_NonSolleva;
begin
  TSmartWaitForm.Show(FForm, 'Attesa');
  LoseWaitWindow;

  Assert.WillNotRaiseAny(
    procedure
    begin
      TSmartWaitForm.SuspendForDialog;
      TSmartWaitForm.ResumeAfterDialog;
    end);
  Assert.WillNotRaiseAny(
    procedure
    begin
      TSmartWaitForm.Hide;
    end);
end;

procedure TTestSmartWaitForm.UseStaticAnimation_SenzaImmagine_UnFotogramma;
var
  Form: TdxSplashFormBase;
  Animation: TdxSplashFormBase.TAnimation;
begin
  // Finestra a parte, mai mostrata: niente thread di disegno
  Form := TdxSplashFormManager.AddSplashForm(TdxSplashFormKind.Wait, 'ProvaCerchioSenzaImmagine');
  Animation := Form.Content.AddAnimation(Rect(0, 0, 32, 32), nil);
  Assert.IsTrue(Animation.Image.Empty, 'L''animazione di partenza deve essere senza immagine');

  TSmartWaitForm.UseStaticAnimation(Form);

  Assert.IsFalse(Animation.Image.Empty, 'L''animazione deve ricevere il cerchio');
  Assert.IsTrue(Animation.Image.AnimationFrameCount <= 1,
    Format('Il cerchio deve avere un solo fotogramma, ne ha %d', [Animation.Image.AnimationFrameCount]));
end;

procedure TTestSmartWaitForm.UseStaticAnimation_ConImmagine_NonToccata;
var
  Form: TdxSplashFormBase;
  Animation: TdxSplashFormBase.TAnimation;
  Own: TdxSmartImage;
  Before: Integer;
begin
  Form := TdxSplashFormManager.AddSplashForm(TdxSplashFormKind.Wait, 'ProvaCerchioConImmagine');
  Own := TdxSmartImage.CreateSize(8, 8);
  try
    Animation := Form.Content.AddAnimation(Rect(0, 0, 32, 32), Own);
  finally
    Own.Free;
  end;
  Before := Animation.Image.Width;

  TSmartWaitForm.UseStaticAnimation(Form);

  Assert.AreEqual(Before, Animation.Image.Width, 'L''immagine della definizione non va sostituita');
end;

procedure TTestSmartWaitForm.Show_AnimazioniDellaFinestraConImmagine;
var
  Item: TdxSplashFormBase.TContentItem;
begin
  TSmartWaitForm.Show(FForm, 'Attesa con il cerchio');
  try
    for Item in TSmartWaitForm.ActiveWaitForm.Content.Items do
      if Item is TdxSplashFormBase.TAnimation then
        Assert.IsFalse(TdxSplashFormBase.TAnimation(Item).Image.Empty,
          'Animazione ' + Item.Name + ' ancora senza immagine dopo la Show');
    Assert.Pass;
  finally
    TSmartWaitForm.Hide;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSmartWaitForm);

end.
