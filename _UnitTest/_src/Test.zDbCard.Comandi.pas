// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDbCard.Comandi;

// Test DUnitX di zDbCard.Commands (coda dei comandi differiti) e di
// zDbCard.Saver (salvataggio differito su thread): requisiti ZDBCARD-CMD di
// zBase\_Specifiche\Comandi e salvataggio della card.md.
//
// La coda si prova su un controllo senza finestra (comandi differiti) e su una
// form vera mostrata (comandi postati): il conteggio dei messaggi si fa
// agganciando il WindowProc della form. Il salvataggio si prova con un task
// vero; la chiusura in coda (TThread.Queue) si consuma con CheckSynchronize,
// perche' il runner e' un'applicazione console senza ciclo dei messaggi.

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  DUnitX.TestFramework,
  zDbCard.Commands,
  zDbCard.Saver;

type
  [TestFixture]
  TTestCodaComandiSenzaFinestra = class
  private
    FControllo: TWinControl;
    FCoda: TzDeferredCommandQueue;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure CodaNuova_NessunComandoInSospeso;
    [Test]
    procedure PostSenzaFinestra_ComandoDifferito;
    [Test]
    procedure PostSenzaFinestra_ComandiDiversiIndipendenti;
    [Test]
    procedure RepostDeferredSenzaFinestra_RestaDifferito;
    [Test]
    procedure ReleaseLatch_NonToglieIlDifferito;
  end;

  [TestFixture]
  TTestCodaComandiConFinestra = class
  private
    const
      MESSAGGIO_PROVA = WM_USER + 211;
    var
      FForm: TForm;
      FCoda: TzDeferredCommandQueue;
      FWindowProcOriginale: TWndMethod;
      FRicevuti: integer;
      FUltimoParametro: NativeUInt;
    procedure WindowProcForm(var Message: TMessage);
    procedure Pompa;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure PostConFinestra_ArrivaUnMessaggioERestaInSospeso;
    [Test]
    procedure PostRipetuto_Coalizzato;
    [Test]
    procedure DopoReleaseLatch_ilComandoSiRipuoPostare;
    [Test]
    procedure MovePostedToDeferred_ConservaIlComando;
    [Test]
    procedure RepostDeferred_RipostaIlComandoDifferito;
  end;

  [TestFixture]
  TTestGuardiaCard = class
  public
    [Test]
    procedure Guardia_NuovaEViva;
    [Test]
    procedure Guardia_SiPuoSpegnere;
  end;

  [TestFixture]
  TTestSalvataggioDifferito = class
  private
    FSaver: TzDeferredSaver;
    FPreparazioni: integer;
    FEsecuzioni: integer;
    FRipostati: integer;
    FSblocco: TEvent;
    procedure Attendi(const Condizione: TFunc<boolean>);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure RequestSave_EseguePrepareEdEsecuzione;
    [Test]
    procedure RequestSave_InVolo_AccodaUnaSolaRichiesta;
    [Test]
    procedure DeferIfRunning_SenzaTask_Falso;
    [Test]
    procedure DeferIfRunning_ConTaskInVolo_VeroEAccoda;
    [Test]
    procedure ClearQueuedRequest_AzzeraLaRichiesta;
    [Test]
    procedure Shutdown_DisattivaIlRilancioDellaRichiestaAccodata;
    [Test]
    procedure Shutdown_SenzaTask_NonSollevaNulla;
    // DIV-CMD-4: l'errore del task e' consegnato al gestore e il saver resta utilizzabile
    [Test]
    procedure ErroreNelTask_ConsegnatoAlGestoreESaverUtilizzabile;
  end;

implementation

{ TTestCodaComandiSenzaFinestra }

procedure TTestCodaComandiSenzaFinestra.Setup;
begin
  // nessun Parent e nessun Handle: HandleAllocated e Showing sono falsi
  FControllo := TWinControl.Create(nil);
  FCoda := TzDeferredCommandQueue.Create(FControllo, WM_USER + 210);
end;

procedure TTestCodaComandiSenzaFinestra.TearDown;
begin
  FreeAndNil(FCoda);
  FreeAndNil(FControllo);
end;

procedure TTestCodaComandiSenzaFinestra.CodaNuova_NessunComandoInSospeso;
var
  Comando: TzDbCardCommand;
begin
  for Comando := Low(TzDbCardCommand) to High(TzDbCardCommand) do
    Assert.IsFalse(FCoda.IsPending(Comando), 'comando ' + Ord(Comando).ToString);
end;

procedure TTestCodaComandiSenzaFinestra.PostSenzaFinestra_ComandoDifferito;
begin
  FCoda.Post(cmd_UpdateActions);

  Assert.IsTrue(FCoda.IsPending(cmd_UpdateActions));
end;

procedure TTestCodaComandiSenzaFinestra.PostSenzaFinestra_ComandiDiversiIndipendenti;
begin
  FCoda.Post(cmd_Resize);

  Assert.IsTrue(FCoda.IsPending(cmd_Resize));
  Assert.IsFalse(FCoda.IsPending(cmd_UpdateActions));
end;

procedure TTestCodaComandiSenzaFinestra.RepostDeferredSenzaFinestra_RestaDifferito;
begin
  FCoda.Post(cmd_SaveProperties);
  FCoda.RepostDeferred;

  // senza finestra il rilancio ricade nel differimento: il comando non si perde
  Assert.IsTrue(FCoda.IsPending(cmd_SaveProperties));
end;

procedure TTestCodaComandiSenzaFinestra.ReleaseLatch_NonToglieIlDifferito;
begin
  FCoda.Post(cmd_RebuildControls);
  FCoda.ReleaseLatch(cmd_RebuildControls);

  Assert.IsTrue(FCoda.IsPending(cmd_RebuildControls));
end;

{ TTestCodaComandiConFinestra }

procedure TTestCodaComandiConFinestra.Setup;
begin
  FRicevuti := 0;
  FUltimoParametro := 0;
  FForm := TForm.CreateNew(nil);
  FForm.Visible := true;
  FForm.HandleNeeded;
  FWindowProcOriginale := FForm.WindowProc;
  FForm.WindowProc := WindowProcForm;
  FCoda := TzDeferredCommandQueue.Create(FForm, MESSAGGIO_PROVA);
  Pompa;
end;

procedure TTestCodaComandiConFinestra.TearDown;
begin
  FreeAndNil(FCoda);
  if Assigned(FForm) then
    FForm.WindowProc := FWindowProcOriginale;
  FreeAndNil(FForm);
end;

procedure TTestCodaComandiConFinestra.WindowProcForm(var Message: TMessage);
begin
  if Message.Msg = MESSAGGIO_PROVA then
  begin
    Inc(FRicevuti);
    FUltimoParametro := Message.LParam;
  end
  else
    FWindowProcOriginale(Message);
end;

procedure TTestCodaComandiConFinestra.Pompa;
var
  Messaggio: TMsg;
begin
  while PeekMessage(Messaggio, 0, 0, 0, PM_REMOVE) do
  begin
    TranslateMessage(Messaggio);
    DispatchMessage(Messaggio);
  end;
end;

procedure TTestCodaComandiConFinestra.PostConFinestra_ArrivaUnMessaggioERestaInSospeso;
begin
  Assert.IsTrue(FForm.Showing, 'la form di prova deve essere a video');

  FCoda.Post(cmd_Resize, 7);
  Assert.IsTrue(FCoda.IsPending(cmd_Resize), 'postato e con il latch alzato');

  Pompa;

  Assert.AreEqual(1, FRicevuti);
  Assert.AreEqual(NativeUInt(7), FUltimoParametro);
  Assert.IsTrue(FCoda.IsPending(cmd_Resize), 'il latch resta alzato finche'' non lo rilascia il gestore');
end;

procedure TTestCodaComandiConFinestra.PostRipetuto_Coalizzato;
begin
  FCoda.Post(cmd_UpdateActions, 1);
  FCoda.Post(cmd_UpdateActions, 2);
  FCoda.Post(cmd_UpdateActions, 3);
  Pompa;

  Assert.AreEqual(1, FRicevuti);
  // vale il primo parametro: i successivi, a latch alzato, sono scartati
  Assert.AreEqual(NativeUInt(1), FUltimoParametro);
end;

procedure TTestCodaComandiConFinestra.DopoReleaseLatch_ilComandoSiRipuoPostare;
begin
  FCoda.Post(cmd_UpdateActions, 1);
  Pompa;
  FCoda.ReleaseLatch(cmd_UpdateActions);
  Assert.IsFalse(FCoda.IsPending(cmd_UpdateActions));

  FCoda.Post(cmd_UpdateActions, 2);
  Pompa;

  Assert.AreEqual(2, FRicevuti);
  Assert.AreEqual(NativeUInt(2), FUltimoParametro);
end;

procedure TTestCodaComandiConFinestra.MovePostedToDeferred_ConservaIlComando;
begin
  FCoda.Post(cmd_SaveProperties, 5);
  FCoda.MovePostedToDeferred;

  Assert.IsTrue(FCoda.IsPending(cmd_SaveProperties), 'da postato a differito resta in sospeso');
end;

procedure TTestCodaComandiConFinestra.RepostDeferred_RipostaIlComandoDifferito;
begin
  FCoda.Post(cmd_SaveProperties, 5);
  Pompa;
  FRicevuti := 0;

  // la finestra viene distrutta: il messaggio andrebbe perso, si conserva
  FCoda.MovePostedToDeferred;
  FCoda.RepostDeferred;
  Pompa;

  Assert.AreEqual(1, FRicevuti);
  Assert.AreEqual(NativeUInt(5), FUltimoParametro);
end;

{ TTestGuardiaCard }

procedure TTestGuardiaCard.Guardia_NuovaEViva;
var
  Guardia: IzCardAliveGuard;
begin
  Guardia := TzCardAliveGuard.Create;

  Assert.IsTrue(Guardia.Alive);
end;

procedure TTestGuardiaCard.Guardia_SiPuoSpegnere;
var
  Guardia: IzCardAliveGuard;
begin
  Guardia := TzCardAliveGuard.Create;
  Guardia.Alive := false;

  Assert.IsFalse(Guardia.Alive);
end;

{ TTestSalvataggioDifferito }

procedure TTestSalvataggioDifferito.Setup;
begin
  FPreparazioni := 0;
  FEsecuzioni := 0;
  FRipostati := 0;
  FSblocco := TEvent.Create(nil, true, false, '');

  FSaver := TzDeferredSaver.Create;
  FSaver.OnPrepare :=
      procedure
    begin
      Inc(FPreparazioni);
    end;
  FSaver.OnExecuteSave :=
      procedure
    begin
      TInterlocked.Increment(FEsecuzioni);
      FSblocco.WaitFor(5000);
    end;
  FSaver.OnRepostRequest :=
      procedure
    begin
      Inc(FRipostati);
    end;
end;

procedure TTestSalvataggioDifferito.TearDown;
begin
  FSblocco.SetEvent;
  FSaver.Shutdown(5000);
  CheckSynchronize(0);
  FreeAndNil(FSaver);
  FreeAndNil(FSblocco);
end;

procedure TTestSalvataggioDifferito.Attendi(const Condizione: TFunc<boolean>);
var
  Inizio: cardinal;
begin
  Inizio := GetTickCount;
  while (not Condizione()) and (GetTickCount - Inizio < 5000) do
  begin
    CheckSynchronize(10);
    Sleep(5);
  end;
end;

procedure TTestSalvataggioDifferito.RequestSave_EseguePrepareEdEsecuzione;
begin
  FSblocco.SetEvent;

  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := FEsecuzioni >= 1;
    end);
  CheckSynchronize(50);

  Assert.AreEqual(1, FPreparazioni);
  Assert.AreEqual(1, FEsecuzioni);
  Assert.AreEqual(0, FRipostati, 'nessuna richiesta accodata: niente rilancio');
end;

procedure TTestSalvataggioDifferito.RequestSave_InVolo_AccodaUnaSolaRichiesta;
begin
  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := FEsecuzioni >= 1;
    end);

  // raffica mentre il task e' in volo: una sola richiesta accodata
  FSaver.RequestSave;
  FSaver.RequestSave;
  FSaver.RequestSave;
  Assert.IsTrue(FSaver.HasQueuedRequest);
  Assert.AreEqual(1, FPreparazioni, 'OnPrepare solo per il task avviato');

  FSblocco.SetEvent;
  Attendi(
    function: boolean
    begin
      result := FRipostati >= 1;
    end);

  Assert.AreEqual(1, FRipostati);
  Assert.IsFalse(FSaver.HasQueuedRequest, 'la richiesta accodata e'' consumata dal rilancio');
end;

procedure TTestSalvataggioDifferito.DeferIfRunning_SenzaTask_Falso;
begin
  Assert.IsFalse(FSaver.DeferIfRunning);
  Assert.IsFalse(FSaver.HasQueuedRequest);
end;

procedure TTestSalvataggioDifferito.DeferIfRunning_ConTaskInVolo_VeroEAccoda;
begin
  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := FEsecuzioni >= 1;
    end);

  Assert.IsTrue(FSaver.DeferIfRunning);
  Assert.IsTrue(FSaver.HasQueuedRequest);
end;

procedure TTestSalvataggioDifferito.ClearQueuedRequest_AzzeraLaRichiesta;
begin
  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := FEsecuzioni >= 1;
    end);
  FSaver.RequestSave;
  Assert.IsTrue(FSaver.HasQueuedRequest);

  FSaver.ClearQueuedRequest;

  Assert.IsFalse(FSaver.HasQueuedRequest);
end;

procedure TTestSalvataggioDifferito.Shutdown_DisattivaIlRilancioDellaRichiestaAccodata;
begin
  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := FEsecuzioni >= 1;
    end);
  FSaver.RequestSave; // accodata

  FSblocco.SetEvent;
  FSaver.Shutdown(5000);
  CheckSynchronize(50);

  Assert.AreEqual(0, FRipostati, 'dopo Shutdown nessuna chiusura in coda tocca il proprietario');
end;

procedure TTestSalvataggioDifferito.Shutdown_SenzaTask_NonSollevaNulla;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FSaver.Shutdown(100);
    end);
end;

procedure TTestSalvataggioDifferito.ErroreNelTask_ConsegnatoAlGestoreESaverUtilizzabile;
var
  Errore: string;
begin
  Errore := '';
  FSaver.OnExecuteSave :=
      procedure
    begin
      TInterlocked.Increment(FEsecuzioni);
      raise Exception.Create('database irraggiungibile');
    end;
  FSaver.OnSaveError :=
      procedure(Messaggio: string)
    begin
      Errore := Messaggio;
    end;

  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := Errore <> '';
    end);

  Assert.IsTrue(Errore.Contains('database irraggiungibile'), 'errore consegnato: ' + Errore);
  Assert.IsTrue(Errore.Contains('Exception'), 'con la classe dell''eccezione: ' + Errore);

  // il task e' concluso: una nuova richiesta parte e non resta accodata
  FSaver.RequestSave;
  Attendi(
    function: boolean
    begin
      result := FEsecuzioni >= 2;
    end);

  Assert.AreEqual(2, FEsecuzioni);
  Assert.IsFalse(FSaver.HasQueuedRequest);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCodaComandiSenzaFinestra);
  TDUnitX.RegisterTestFixture(TTestCodaComandiConFinestra);
  TDUnitX.RegisterTestFixture(TTestGuardiaCard);
  TDUnitX.RegisterTestFixture(TTestSalvataggioDifferito);

end.
