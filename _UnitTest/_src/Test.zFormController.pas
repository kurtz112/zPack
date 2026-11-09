// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zFormController;

// Test DUnitX di zBase\zFormController (specifica ZBASE-FRM, "Controller dei
// form.md").
//
// Il controller costruisce un TdxLayoutControl con i controlli del dizionario
// LZ: la costruzione vera (gruppi, schede, dataset, file .layout, altezza
// automatica) richiede un dizionario, un database e una finestra a video e non
// e' isolabile. Qui si provano solo i contratti che non mostrano finestre:
//   - valori predefiniti, ripieghi del proprietario e azzeramento dei
//     componenti distrutti (ZBASE-FRM-001, 002);
//   - CreateControls con BuildGUI falso non crea niente (ZBASE-FRM-003);
//   - le chiamate che devono essere innocue prima della costruzione
//     (ZBASE-FRM-007, 008, 013, 017);
//   - l'interfaccia IzLayoutMaintenance senza conteggio dei riferimenti
//     (ZBASE-FRM-013);
//   - il resoconto delle risoluzioni dei layout, funzione di sola lettura
//     (ZBASE-FRM-017).
//
// Nessuna prova mostra una form: il proprietario con finestra e' una form
// creata con CreateNew e mai mostrata.

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.ExtCtrls,
  DUnitX.TestFramework,
  zLayouts,
  zLayoutMaintenance,
  zSystem,
  zFormController;

type
  [TestFixture]
  TTestFormController = class
  private
    FProprietario: TComponent;
    FController: TzFormController;
    FModuli: TzDataModules;
    FChiamateDistruzione: Integer;
    procedure PrimaDellaDistruzione(zFormController: TzFormController; LayoutController: TLayoutController; Component: TComponent);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-FRM-001
    [Test]
    procedure Creazione_ValoriIniziali;
    // ZBASE-FRM-001
    [Test]
    procedure GetCtrlOwner_SenzaCtrlOwner_RestituisceIlProprietario;
    // ZBASE-FRM-001
    [Test]
    procedure GetCtrlOwner_ConCtrlOwner_RestituisceQuelloAssegnato;
    // ZBASE-FRM-001
    [Test]
    procedure GetCtrlParent_ProprietarioNonVisivo_RestituisceNil;
    // ZBASE-FRM-001
    [Test]
    procedure GetCtrlParent_ProprietarioForm_RestituisceLaForm;
    // ZBASE-FRM-002
    [Test]
    procedure CtrlParentDistrutto_TornaNil;
    // ZBASE-FRM-002
    [Test]
    procedure CtrlOwnerDistrutto_TornaNil;
    // ZBASE-FRM-003
    [Test]
    procedure CreateControls_BuildGuiFalso_NonCreaIlLayout;
    // ZBASE-FRM-007
    [Test]
    procedure DestroyControls_SenzaLayout_NonSollevaENonAvvisa;
    // ZBASE-FRM-008
    [Test]
    procedure SkipSelectFirstNode_PassaAlLayoutController;
    // ZBASE-FRM-008
    [Test]
    procedure SenzaAlbero_SelezioneVuota;
    // ZBASE-FRM-007
    [Test]
    procedure LayoutController_SenzaLayout_RicercheVuote;
    // ZBASE-FRM-013
    [Test]
    procedure Manutenzione_SenzaLayout_NonFaNiente;
    // ZBASE-FRM-013
    [Test]
    procedure Manutenzione_RilascioDellInterfaccia_NonLiberaIlController;
    // ZBASE-FRM-017
    [Test]
    procedure DumpItemSize_SenzaLayout_TestoVuoto;
    // ZBASE-FRM-017
    [Test]
    procedure ResetItemSize_SenzaLayout_NonSolleva;
  end;

  [TestFixture]
  TTestRapportoRisoluzioni = class
  private
    FModuli: TzDataModules;
    procedure AggiungiLayout(const NomeModulo, NomeLayout: string; const Larghezza, Altezza: Integer; const ConElementi: Boolean);
    function Contiene(const Testo, Parte: string): Boolean;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-FRM-017
    [Test]
    procedure SenzaModuli_NessunaSegnalazione;
    // ZBASE-FRM-017
    [Test]
    procedure RisoluzioneUguale_InLinea;
    // ZBASE-FRM-017
    [Test]
    procedure RisoluzioneDiversa_RigaDiversa;
    // ZBASE-FRM-017
    [Test]
    procedure RisoluzioneAZero_NonRegistrata;
    // ZBASE-FRM-017
    [Test]
    procedure UnaSolaDimensioneAZero_NonRegistrata;
    // ZBASE-FRM-017
    [Test]
    procedure LayoutSenzaElementi_NonSegnalato;
    // ZBASE-FRM-017
    [Test]
    procedure RiepilogoMisto_ContaOgniCategoria;
  end;

implementation

{ TTestFormController }

procedure TTestFormController.Setup;
begin
  FProprietario := TComponent.Create(nil);
  FController := TzFormController.Create(FProprietario);
  FModuli := nil;
  FChiamateDistruzione := 0;
end;

procedure TTestFormController.TearDown;
begin
  // Prima il controller, poi il modulo dati a cui puo' puntare
  FreeAndNil(FController);
  FreeAndNil(FProprietario);
  FreeAndNil(FModuli);
end;

procedure TTestFormController.PrimaDellaDistruzione(zFormController: TzFormController; LayoutController: TLayoutController; Component: TComponent);
begin
  Inc(FChiamateDistruzione);
end;

procedure TTestFormController.Creazione_ValoriIniziali;
begin
  Assert.AreEqual(1920, FController.DesignWidth);
  Assert.AreEqual(1200, FController.DesignHeight);
  Assert.IsFalse(FController.SkipSelectFirstNode);
  Assert.IsNull(FController.CtrlOwner);
  Assert.IsNull(FController.CtrlParent);
  Assert.IsNull(FController.zSystem);
  Assert.IsNull(FController.zDataModule);
  Assert.IsNotNull(FController.LayoutController);
end;

procedure TTestFormController.GetCtrlOwner_SenzaCtrlOwner_RestituisceIlProprietario;
begin
  Assert.AreSame(TObject(FProprietario), TObject(FController.GetCtrlOwner));
end;

procedure TTestFormController.GetCtrlOwner_ConCtrlOwner_RestituisceQuelloAssegnato;
var
  Altro: TComponent;
begin
  Altro := TComponent.Create(FProprietario);
  FController.CtrlOwner := Altro;

  Assert.AreSame(TObject(Altro), TObject(FController.GetCtrlOwner));
end;

procedure TTestFormController.GetCtrlParent_ProprietarioNonVisivo_RestituisceNil;
begin
  // Il proprietario di prova e' un TComponent, non un controllo a finestra
  Assert.IsNull(FController.GetCtrlParent);
end;

procedure TTestFormController.GetCtrlParent_ProprietarioForm_RestituisceLaForm;
var
  Finestra: TForm;
  ControllerDellaForm: TzFormController;
begin
  // Form creata e mai mostrata; il controller e' un suo componente e si libera con lei
  Finestra := TForm.CreateNew(nil);
  try
    ControllerDellaForm := TzFormController.Create(Finestra);

    Assert.AreSame(TObject(Finestra), TObject(ControllerDellaForm.GetCtrlParent));
    Assert.AreSame(TObject(Finestra), TObject(ControllerDellaForm.GetCtrlOwner));
  finally
    FreeAndNil(Finestra);
  end;
end;

procedure TTestFormController.CtrlParentDistrutto_TornaNil;
var
  Pannello: TPanel;
begin
  // Stesso proprietario del controller: e' il solo caso in cui Notification arriva
  Pannello := TPanel.Create(FProprietario);
  FController.CtrlParent := Pannello;
  Assert.AreSame(TObject(Pannello), TObject(FController.CtrlParent));

  FreeAndNil(Pannello);

  Assert.IsNull(FController.CtrlParent);
  Assert.IsNull(FController.GetCtrlParent);
end;

procedure TTestFormController.CtrlOwnerDistrutto_TornaNil;
var
  Altro: TComponent;
begin
  Altro := TComponent.Create(FProprietario);
  FController.CtrlOwner := Altro;

  FreeAndNil(Altro);

  Assert.IsNull(FController.CtrlOwner);
  Assert.AreSame(TObject(FProprietario), TObject(FController.GetCtrlOwner));
end;

procedure TTestFormController.CreateControls_BuildGuiFalso_NonCreaIlLayout;
var
  Modulo: TzDataModule;
begin
  FModuli := TzDataModules.Create(TzDataModule, 'DataModules', -1, nil, False);
  Modulo := FModuli.Add;
  Modulo.Name := 'ModuloDiProva';
  Assert.IsFalse(Modulo.BuildGUI, 'Il valore predefinito di BuildGUI deve essere falso');

  FController.zDataModule := Modulo;
  FController.CreateControls;

  Assert.IsNull(FController.LayoutController.dxLayoutControl);
end;

procedure TTestFormController.DestroyControls_SenzaLayout_NonSollevaENonAvvisa;
begin
  FController.OnBeforeDestroyComponent := PrimaDellaDistruzione;

  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.DestroyControls;
    end);

  Assert.AreEqual(0, FChiamateDistruzione);
end;

procedure TTestFormController.SkipSelectFirstNode_PassaAlLayoutController;
begin
  FController.SkipSelectFirstNode := True;
  Assert.IsTrue(FController.LayoutController.SkipSelectFirstNode);

  FController.SkipSelectFirstNode := False;
  Assert.IsFalse(FController.LayoutController.SkipSelectFirstNode);
end;

procedure TTestFormController.SenzaAlbero_SelezioneVuota;
begin
  Assert.IsNull(FController.LayoutController.TreeMenu);
  Assert.AreEqual('', FController.SelectedDataSetName);
  Assert.IsNull(FController.SelectedDataSet);

  // Assegnare il nome senza albero non fa niente
  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.SelectedDataSetName := 'Intestatari';
    end);
  Assert.AreEqual('', FController.SelectedDataSetName);
end;

procedure TTestFormController.LayoutController_SenzaLayout_RicercheVuote;
begin
  Assert.IsNull(FController.LayoutController.FindGroup('dxLayoutGroupMain'));
  Assert.IsNull(FController.LayoutController.FindItem('dxLayoutItemTreeMenu'));
  Assert.IsNull(FController.LayoutController.FindCustomItem('dxLayoutGroupMain'));
  Assert.IsFalse(FController.LayoutController.IsContainerReady);
  Assert.IsFalse(FController.LayoutController.IsControlVisible(nil));
  Assert.IsNull(FController.LayoutController.AddControl(nil, 'Cartografia'));
  // Un nome sconosciuto non fa niente neppure prima della costruzione
  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.LayoutController.MakeVisible('NonEsiste');
    end);
end;

procedure TTestFormController.Manutenzione_SenzaLayout_NonFaNiente;
var
  Manutenzione: IzLayoutMaintenance;
begin
  Assert.IsTrue(Supports(FController.LayoutController, IzLayoutMaintenance, Manutenzione),
    'TLayoutController deve implementare IzLayoutMaintenance');

  Assert.IsFalse(Manutenzione.CanMaintainLayout);
  Assert.WillNotRaiseAny(
    procedure
    begin
      Manutenzione.ResetLayout;
      Manutenzione.RepairLayout;
    end);
end;

procedure TTestFormController.Manutenzione_RilascioDellInterfaccia_NonLiberaIlController;
var
  Manutenzione: IzLayoutMaintenance;
begin
  Assert.IsTrue(Supports(FController.LayoutController, IzLayoutMaintenance, Manutenzione));

  // _AddRef e _Release restituiscono -1: il rilascio non libera il controller del layout
  Manutenzione := nil;

  Assert.IsNotNull(FController.LayoutController);
  Assert.IsFalse(FController.LayoutController.CanMaintainLayout);
end;

procedure TTestFormController.DumpItemSize_SenzaLayout_TestoVuoto;
begin
  Assert.AreEqual('', FController.DumpItemSize(800, 600));
end;

procedure TTestFormController.ResetItemSize_SenzaLayout_NonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.ResetItemSize;
    end);
end;

{ TTestRapportoRisoluzioni }

procedure TTestRapportoRisoluzioni.Setup;
begin
  FModuli := TzDataModules.Create(TzDataModule, 'DataModules', -1, nil, False);
end;

procedure TTestRapportoRisoluzioni.TearDown;
begin
  FreeAndNil(FModuli);
end;

procedure TTestRapportoRisoluzioni.AggiungiLayout(const NomeModulo, NomeLayout: string; const Larghezza, Altezza: Integer; const ConElementi: Boolean);
var
  Modulo: TzDataModule;
  Layout: TzLayout;
begin
  Modulo := FModuli.Add;
  Modulo.Name := NomeModulo;

  Layout := Modulo.Layouts.Add;
  Layout.Name := NomeLayout;
  Layout.DesignWidth := Larghezza;
  Layout.DesignHeight := Altezza;

  if ConElementi then
    Layout.Layout.Add;
end;

function TTestRapportoRisoluzioni.Contiene(const Testo, Parte: string): Boolean;
begin
  Result := Pos(Parte, Testo) > 0;
end;

procedure TTestRapportoRisoluzioni.SenzaModuli_NessunaSegnalazione;
var
  Rapporto: string;
begin
  Rapporto := LayoutDesignResolutionReport(nil, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '0 layout esaminati: 0 in linea, 0 diversi, 0 senza risoluzione registrata.'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Nessuna segnalazione.'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'riferimento 1920x1200'), Rapporto);
end;

procedure TTestRapportoRisoluzioni.RisoluzioneUguale_InLinea;
var
  Rapporto: string;
begin
  AggiungiLayout('Studenti', 'dxLayout', 1920, 1200, True);

  Rapporto := LayoutDesignResolutionReport(FModuli, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '1 layout esaminati: 1 in linea, 0 diversi, 0 senza risoluzione registrata.'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Nessuna segnalazione.'), Rapporto);
end;

procedure TTestRapportoRisoluzioni.RisoluzioneDiversa_RigaDiversa;
var
  Rapporto: string;
begin
  AggiungiLayout('Studenti', 'dxLayout', 1366, 768, True);

  Rapporto := LayoutDesignResolutionReport(FModuli, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '1 layout esaminati: 0 in linea, 1 diversi, 0 senza risoluzione registrata.'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Studenti.dxLayout'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, '1366x768  DIVERSA dal riferimento 1920x1200'), Rapporto);
  Assert.IsFalse(Contiene(Rapporto, 'Nessuna segnalazione.'), Rapporto);
end;

procedure TTestRapportoRisoluzioni.RisoluzioneAZero_NonRegistrata;
var
  Rapporto: string;
begin
  AggiungiLayout('Studenti', 'dxLayout', 0, 0, True);

  Rapporto := LayoutDesignResolutionReport(FModuli, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '1 layout esaminati: 0 in linea, 0 diversi, 1 senza risoluzione registrata.'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Studenti.dxLayout'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'non registrata'), Rapporto);
end;

procedure TTestRapportoRisoluzioni.UnaSolaDimensioneAZero_NonRegistrata;
var
  Rapporto: string;
begin
  // Basta una dimensione a zero: la coppia non descrive nessun monitor
  AggiungiLayout('Studenti', 'dxLayout', 1920, 0, True);

  Rapporto := LayoutDesignResolutionReport(FModuli, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '0 in linea, 0 diversi, 1 senza risoluzione registrata.'), Rapporto);
end;

procedure TTestRapportoRisoluzioni.LayoutSenzaElementi_NonSegnalato;
var
  Rapporto: string;
begin
  // Un layout mai personalizzato non ha elementi: non produce righe (DIV-FRM-13
  // sul modo in cui viene contato nel riepilogo)
  AggiungiLayout('Studenti', 'dxLayout', 0, 0, False);

  Rapporto := LayoutDesignResolutionReport(FModuli, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '1 layout esaminati:'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Nessuna segnalazione.'), Rapporto);
  Assert.IsFalse(Contiene(Rapporto, 'Studenti.dxLayout'), Rapporto);
end;

procedure TTestRapportoRisoluzioni.RiepilogoMisto_ContaOgniCategoria;
var
  Rapporto: string;
begin
  AggiungiLayout('Studenti', 'dxLayout', 1920, 1200, True);
  AggiungiLayout('Progetti', 'dxLayout', 2560, 1440, True);
  AggiungiLayout('Tirocini', 'dxLayout', 0, 0, True);

  Rapporto := LayoutDesignResolutionReport(FModuli, 1920, 1200);

  Assert.IsTrue(Contiene(Rapporto, '3 layout esaminati: 1 in linea, 1 diversi, 1 senza risoluzione registrata.'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Progetti.dxLayout'), Rapporto);
  Assert.IsTrue(Contiene(Rapporto, 'Tirocini.dxLayout'), Rapporto);
  Assert.IsFalse(Contiene(Rapporto, 'Studenti.dxLayout'), Rapporto);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestFormController);
  TDUnitX.RegisterTestFixture(TTestRapportoRisoluzioni);

end.
