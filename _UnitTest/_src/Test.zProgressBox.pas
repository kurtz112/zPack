// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zProgressBox;

// Test DUnitX di zCommon\zProgressBox (specifica ZCOMMON-PRG, "Barra di
// avanzamento.md").
//
// Prova lo stato del componente senza mai mostrare la finestra: il
// TProgressDlg viene creato dal costruttore di TProgressBox (DIV-PRG-6) e
// resta nascosto, quindi non si disabilita nessuna finestra del processo e non
// compare nessun dialogo. Restano senza prova, perche' mostrano finestre o
// aprono la conferma di Annulla: Show, la disabilitazione delle altre finestre,
// il pulsante Annulla (ZCOMMON-PRG-003 e 005), da collaudare con la sonda zapp.
//
// I ganci globali OnProgressBox_* sono variabili di unita': Setup li salva e li
// sostituisce con contatori, TearDown li ripristina.
//
// Prove che fotografano una divergenza della specifica (DIV-PRG-3, per
// IncProgress con -1): vanno riviste quando la divergenza viene corretta.
// DIV-PRG-2, 4 e 8 sono corrette (rilascio 021).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  DUnitX.TestFramework,
  cxProgressBar,
  zProgressBox;

type
  [TestFixture]
  TTestProgressBox = class
  private
    FBox: TProgressBox;
    FSalvatoShow: TProc<Integer>;
    FSalvatoProgress: TProc<Integer>;
    FSalvatoPaused: TProc;
    FSalvatoClose: TProc;
    FValoriProgress: TList<Integer>;
    FChiamateClose: Integer;
    function PosizioneBarra: Double;
    function MassimoBarra: Double;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZCOMMON-PRG-001
    [Test]
    procedure Creazione_StatoIniziale;
    // ZCOMMON-PRG-001
    [Test]
    procedure Creazione_LaFinestraHaPerProprietarioIlComponente;
    // ZCOMMON-PRG-002
    [Test]
    procedure Titolo_PassaAllaFinestra;
    // ZCOMMON-PRG-002
    [Test]
    procedure MaxValue_PassaAllaFinestraEAllaBarra;
    // ZCOMMON-PRG-002
    [Test]
    procedure Progress_DentroIlMassimo_MuoveLaBarra;
    // ZCOMMON-PRG-002
    [Test]
    procedure Progress_OltreIlMassimo_RicordaIlValoreMaNonMuoveLaBarra;
    // ZCOMMON-PRG-002
    [Test]
    procedure PrimaEtichetta_ConservaIlTestoIntero;
    // ZCOMMON-PRG-002
    [Test]
    procedure SecondaEtichetta_NonVuota_RendeVisibileLaSecondaRiga;
    // ZCOMMON-PRG-002
    [Test]
    procedure CancelEnabled_AbilitaEDisabilitaIlPulsante;
    // ZCOMMON-PRG-004
    [Test]
    procedure IncProgress_SenzaParametri_IncrementaEChiamaIlGancio;
    // ZCOMMON-PRG-004
    [Test]
    procedure IncProgress_ConUnaEtichetta_ImpostaLaPrimaEIncrementa;
    // ZCOMMON-PRG-004
    [Test]
    procedure IncProgress_ConDueEtichette_ImpostaEntrambe;
    // ZCOMMON-PRG-004
    [Test]
    procedure IncProgress_ValoreEsplicito_ImpostaLaPosizione;
    // ZCOMMON-PRG-004 (DIV-PRG-3)
    [Test]
    procedure IncProgress_MenoUno_ValeIncremento;
    // ZCOMMON-PRG-006
    [Test]
    procedure Close_SenzaComparsa_ChiamaIlGancioENonSolleva;
    // ZCOMMON-PRG-006
    [Test]
    procedure Close_Ripetuto_ChiamaIlGancioAOgniVolta;
    // ZCOMMON-PRG-007
    [Test]
    procedure GanciNonAssegnati_NonSollevano;
    // ZCOMMON-PRG-008
    [Test]
    procedure OnProgress_Percentuale_ImpostaLaPosizione;
    [Test]
    procedure Divergenza_DIV_PRG_4_OnProgress_MassimoDiverso_RiportaAlMassimo;
  end;

implementation

{ TTestProgressBox }

procedure TTestProgressBox.Setup;
begin
  FSalvatoShow := OnProgressBox_Show;
  FSalvatoProgress := OnProgressBox_Progress;
  FSalvatoPaused := OnProgressBox_Paused;
  FSalvatoClose := OnProgressBox_Close;

  FValoriProgress := TList<Integer>.Create;
  FChiamateClose := 0;

  OnProgressBox_Show := nil;
  OnProgressBox_Paused := nil;
  OnProgressBox_Progress := procedure(Valore: Integer)
    begin
      FValoriProgress.Add(Valore);
    end;
  OnProgressBox_Close := procedure
    begin
      Inc(FChiamateClose);
    end;

  FBox := TProgressBox.Create(nil);
end;

procedure TTestProgressBox.TearDown;
begin
  FreeAndNil(FBox);

  OnProgressBox_Show := FSalvatoShow;
  OnProgressBox_Progress := FSalvatoProgress;
  OnProgressBox_Paused := FSalvatoPaused;
  OnProgressBox_Close := FSalvatoClose;

  FreeAndNil(FValoriProgress);
end;

function TTestProgressBox.PosizioneBarra: Double;
begin
  Result := Double(FBox.ProgressDlg.ProgressBar.Position);
end;

function TTestProgressBox.MassimoBarra: Double;
begin
  Result := Double(FBox.ProgressDlg.ProgressBar.Properties.Max);
end;

procedure TTestProgressBox.Creazione_StatoIniziale;
begin
  Assert.IsNotNull(FBox.ProgressDlg, 'La finestra interna deve esistere subito dopo la creazione');
  Assert.IsFalse(FBox.Cancelled);
  Assert.IsFalse(FBox.Visible);
  Assert.IsTrue(FBox.CancelEnabled);
  Assert.AreEqual(0, FBox.MaxValue);
  Assert.AreEqual(0, FBox.Progress);
end;

procedure TTestProgressBox.Creazione_LaFinestraHaPerProprietarioIlComponente;
begin
  Assert.AreSame(TObject(FBox), TObject(FBox.ProgressDlg.Owner));
end;

procedure TTestProgressBox.Titolo_PassaAllaFinestra;
begin
  FBox.Caption := 'Scadenze';

  Assert.AreEqual('Scadenze', string(FBox.ProgressDlg.Caption));
  Assert.AreEqual('Scadenze', FBox.Caption);
end;

procedure TTestProgressBox.MaxValue_PassaAllaFinestraEAllaBarra;
begin
  FBox.MaxValue := 50;

  Assert.AreEqual(50, FBox.MaxValue);
  Assert.AreEqual(50, FBox.ProgressDlg.MaxValue);
  Assert.AreEqual(Double(50), MassimoBarra, 0.001);
end;

procedure TTestProgressBox.Progress_DentroIlMassimo_MuoveLaBarra;
begin
  FBox.MaxValue := 10;
  FBox.Progress := 4;

  Assert.AreEqual(4, FBox.Progress);
  Assert.AreEqual(Double(4), PosizioneBarra, 0.001);
end;

procedure TTestProgressBox.Progress_OltreIlMassimo_RicordaIlValoreMaNonMuoveLaBarra;
begin
  FBox.MaxValue := 10;
  FBox.Progress := 4;
  FBox.Progress := 15;

  // Il valore si ricorda anche oltre il massimo, la barra si ferma al massimo (DIV-PRG-2 corretta)
  Assert.AreEqual(15, FBox.Progress);
  Assert.AreEqual(Double(10), PosizioneBarra, 0.001);
end;

procedure TTestProgressBox.PrimaEtichetta_ConservaIlTestoIntero;
const
  Percorso = 'D:\Cartella molto lunga\Altra cartella molto lunga\Sottocartella con un nome interminabile\Elenco dei contribuenti.csv';
begin
  FBox.FirstLabel := Percorso;

  // Il testo e' intero sul componente e sulla finestra; a video e' abbreviato
  Assert.AreEqual(Percorso, FBox.FirstLabel);
  Assert.AreEqual(Percorso, FBox.ProgressDlg.FirstLabel);
  Assert.IsTrue(Length(string(FBox.ProgressDlg.Label1.Caption)) <= Length(Percorso),
    'L''etichetta a video non puo'' essere piu'' lunga del testo');
end;

procedure TTestProgressBox.SecondaEtichetta_NonVuota_RendeVisibileLaSecondaRiga;
begin
  // Il valore di partenza di Label2 e' visibile: la si nasconde a mano per
  // provare che l'assegnazione la riaccende
  FBox.ProgressDlg.Label2.Visible := False;

  FBox.SecondLabel := 'Attendere...';

  Assert.IsTrue(FBox.ProgressDlg.Label2.Visible);
  Assert.AreEqual('Attendere...', FBox.SecondLabel);
  Assert.AreEqual('Attendere...', FBox.ProgressDlg.SecondLabel);
end;

procedure TTestProgressBox.CancelEnabled_AbilitaEDisabilitaIlPulsante;
begin
  FBox.CancelEnabled := False;

  Assert.IsFalse(FBox.CancelEnabled);
  Assert.IsFalse(FBox.ProgressDlg.CancelEnabled);
  Assert.IsFalse(FBox.ProgressDlg.Button.Enabled);

  FBox.CancelEnabled := True;

  Assert.IsTrue(FBox.ProgressDlg.Button.Enabled);
end;

procedure TTestProgressBox.IncProgress_SenzaParametri_IncrementaEChiamaIlGancio;
begin
  FBox.MaxValue := 5;

  FBox.IncProgress;
  FBox.IncProgress;

  Assert.AreEqual(2, FBox.Progress);
  Assert.AreEqual(2, FValoriProgress.Count);
  Assert.AreEqual(1, FValoriProgress[0]);
  Assert.AreEqual(2, FValoriProgress[1]);
end;

procedure TTestProgressBox.IncProgress_ConUnaEtichetta_ImpostaLaPrimaEIncrementa;
begin
  FBox.MaxValue := 5;

  FBox.IncProgress('Prima fase');

  Assert.AreEqual('Prima fase', FBox.ProgressDlg.FirstLabel);
  Assert.AreEqual(1, FBox.Progress);
end;

procedure TTestProgressBox.IncProgress_ConDueEtichette_ImpostaEntrambe;
begin
  FBox.MaxValue := 5;

  FBox.IncProgress('Prima fase', 'Verifica');

  Assert.AreEqual('Prima fase', FBox.ProgressDlg.FirstLabel);
  Assert.AreEqual('Verifica', FBox.ProgressDlg.SecondLabel);
  Assert.AreEqual(1, FBox.Progress);
end;

procedure TTestProgressBox.IncProgress_ValoreEsplicito_ImpostaLaPosizione;
begin
  FBox.MaxValue := 10;
  FBox.Progress := 2;

  FBox.IncProgress(7, 'Fase 2', 'Verifica');

  Assert.AreEqual(7, FBox.Progress);
  Assert.AreEqual('Fase 2', FBox.ProgressDlg.FirstLabel);
  Assert.AreEqual('Verifica', FBox.ProgressDlg.SecondLabel);
  Assert.AreEqual(1, FValoriProgress.Count);
  Assert.AreEqual(7, FValoriProgress[0]);
end;

procedure TTestProgressBox.IncProgress_MenoUno_ValeIncremento;
begin
  FBox.MaxValue := 10;
  FBox.Progress := 3;

  // -1 non e' una posizione: vale "aggiungi 1" (DIV-PRG-3)
  FBox.IncProgress(-1, 'a', 'b');

  Assert.AreEqual(4, FBox.Progress);
end;

procedure TTestProgressBox.Close_SenzaComparsa_ChiamaIlGancioENonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FBox.Close;
    end);

  Assert.IsFalse(FBox.Visible);
  // DIV-PRG-8 corretta: su una barra mai mostrata il gancio non scatta
  Assert.AreEqual(0, FChiamateClose);
end;

procedure TTestProgressBox.Close_Ripetuto_ChiamaIlGancioAOgniVolta;
begin
  FBox.Close;
  FBox.Close;

  // Il gancio non scatta su una barra mai mostrata (DIV-PRG-8 corretta)
  Assert.AreEqual(0, FChiamateClose);
  Assert.IsFalse(FBox.Cancelled);
end;

procedure TTestProgressBox.GanciNonAssegnati_NonSollevano;
begin
  OnProgressBox_Show := nil;
  OnProgressBox_Progress := nil;
  OnProgressBox_Paused := nil;
  OnProgressBox_Close := nil;

  FBox.MaxValue := 3;

  Assert.WillNotRaiseAny(
    procedure
    begin
      FBox.IncProgress;
      FBox.IncProgress('uno');
      FBox.Close;
    end);

  Assert.AreEqual(2, FBox.Progress);
end;

procedure TTestProgressBox.OnProgress_Percentuale_ImpostaLaPosizione;
begin
  FBox.MaxValue := 100;

  // Interfaccia IcxProgress: con massimo 100 la percentuale e' la posizione
  FBox.ProgressDlg.OnProgress(nil, 40);

  Assert.AreEqual(40, FBox.Progress);
  Assert.AreEqual(Double(40), PosizioneBarra, 0.001);
end;

procedure TTestProgressBox.Divergenza_DIV_PRG_4_OnProgress_MassimoDiverso_RiportaAlMassimo;
begin
  FBox.MaxValue := 200;

  // DIV-PRG-4 corretta: il 40% di 200 e' 80
  FBox.ProgressDlg.OnProgress(nil, 40);

  Assert.AreEqual(80, FBox.Progress);
  Assert.AreEqual(Double(80), PosizioneBarra, 0.001);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestProgressBox);

end.
