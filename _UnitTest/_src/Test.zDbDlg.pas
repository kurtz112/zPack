// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDbDlg;

// Test DUnitX per zBase\zDbViewDlg.pas e zBase\zDbCardDlg.pas (specifiche
// ZBASE-DVW, "Dialogo di selezione della vista.md", e ZBASE-DCD, "Dialogo della
// scheda.md"). BOZZA scritta senza poterla compilare ne' eseguire.
//
// Si provano solo le parti che non mostrano nessuna finestra:
// - i valori predefiniti dei due componenti dopo Create(nil)
//   (ZBASE-DVW-002, ZBASE-DCD-002);
// - l'errore di Execute senza dataset, che sale prima di creare qualunque
//   finestra (ZBASE-DVW-001, ZBASE-DCD-001);
// - FindValue e gli eventi memorizzati senza finestra aperta (ZBASE-DVW-008,
//   ZBASE-DVW-010, ZBASE-DCD-011);
// - ReadOnly, DestroyForm e DestroyControls senza finestra (ZBASE-DCD-004,
//   ZBASE-DCD-008).
//
// Restano senza prova, perche' aprono una finestra modale (ShowModal, senza punti
// di aggancio): l'esito di Execute, la scelta multipla, la copia su DestDataSet,
// il salvataggio e l'annullo alla chiusura, l'ordine degli eventi, la comparsa
// ritardata. FirmaToolActions (ZBASE-DCD-005) e' una class function privata di
// TzDbCardDlg: da una unit di prova non si puo' chiamare. Per provare le parti
// con la finestra servirebbe una variabile di aggancio, come OnStartWait di
// zBaseLib, che sostituisca ShowModal (dichiarata, non implementata qui).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  DUnitX.TestFramework,
  zFbDataSet,
  zDbViewDlg,
  zDbCardDlg;

type
  // Ricevitore di eventi: i gestori non fanno niente, servono solo a verificare
  // che l'evento si memorizzi e si rilegga.
  TRicevitoreEventi = class
  public
    procedure GestoreVista(Dialog: TzDbViewForm);
    procedure GestoreScheda(Dialog: TzDbCardForm);
    procedure GestoreNotifica(Sender: TObject);
  end;

  [TestFixture]
  TTestzDbViewDlg = class
  private
    Dialogo: TzDbViewDlg;
    Ricevitore: TRicevitoreEventi;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-DVW-002
    [Test]
    procedure Create_ValoriPredefiniti_TestiVuotiENessunCollegamento;
    // ZBASE-DVW-002
    [Test]
    procedure Create_Options_PredefinitiAutoAppendAutoPostRaiseOnError;
    // ZBASE-DVW-002
    [Test]
    procedure Create_ToolActions_CollezioneVuotaCreataDalComponente;
    // ZBASE-DVW-002
    [Test]
    procedure Proprieta_Assegnate_SiRileggono;
    // ZBASE-DVW-001
    [Test]
    procedure Execute_SenzaDataSet_EccezioneConNomeDelComponente;
    // ZBASE-DVW-001
    [Test]
    procedure Execute_SenzaDataSet_NessunaFinestraCreata;
    // ZBASE-DVW-001 (la caption scritta resta: DIV-DVW-7)
    [Test]
    procedure ExecuteConTitolo_SenzaDataSet_ScriveComunqueLaCaption;
    // ZBASE-DVW-008
    [Test]
    procedure FindValue_SenzaFinestra_SiMemorizza;
    // ZBASE-DVW-010
    [Test]
    procedure Eventi_Assegnati_SiRileggonoSenzaFinestra;
  end;

  [TestFixture]
  TTestzDbCardDlg = class
  private
    Dialogo: TzDbCardDlg;
    Ricevitore: TRicevitoreEventi;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-DCD-002
    [Test]
    procedure Create_ValoriPredefiniti_TestiVuotiENessunCollegamento;
    // ZBASE-DCD-002
    [Test]
    procedure Create_ReadOnly_Falso;
    // ZBASE-DCD-002
    [Test]
    procedure Proprieta_Assegnate_SiRileggono;
    // ZBASE-DCD-001
    [Test]
    procedure Execute_SenzaDataSet_EccezioneConNomeDelComponente;
    // ZBASE-DCD-001
    [Test]
    procedure Execute_SenzaDataSet_NessunaFinestraCreata;
    // ZBASE-DCD-004
    [Test]
    procedure ReadOnly_SenzaFinestra_SiMemorizzaENonCreaLaFinestra;
    // ZBASE-DCD-008
    [Test]
    procedure DestroyForm_SenzaFinestra_NonFaNiente;
    // ZBASE-DCD-008
    [Test]
    procedure DestroyControls_SenzaFinestra_NonFaNiente;
    // ZBASE-DCD-002, ZBASE-DCD-008
    [Test]
    procedure CambioDiDataSet_SenzaFinestra_SiMemorizza;
    // ZBASE-DCD-011
    [Test]
    procedure Eventi_Assegnati_SiRileggonoSenzaFinestra;
  end;

implementation

{ TRicevitoreEventi }

procedure TRicevitoreEventi.GestoreVista(Dialog: TzDbViewForm);
begin
  // nessuna azione: serve solo come destinazione dell'evento
end;

procedure TRicevitoreEventi.GestoreScheda(Dialog: TzDbCardForm);
begin
  // nessuna azione: serve solo come destinazione dell'evento
end;

procedure TRicevitoreEventi.GestoreNotifica(Sender: TObject);
begin
  // nessuna azione: serve solo come destinazione dell'evento
end;

{ TTestzDbViewDlg }

procedure TTestzDbViewDlg.Setup;
begin
  Dialogo := TzDbViewDlg.Create(nil);
  Ricevitore := TRicevitoreEventi.Create;
end;

procedure TTestzDbViewDlg.TearDown;
begin
  Ricevitore.Free;
  Dialogo.Free;
end;

procedure TTestzDbViewDlg.Create_ValoriPredefiniti_TestiVuotiENessunCollegamento;
begin
  Assert.AreEqual('', Dialogo.Caption, 'Caption');
  Assert.AreEqual('', Dialogo.idLookup, 'idLookup');
  Assert.IsTrue(Dialogo.DataSet = nil, 'DataSet');
  Assert.IsTrue(Dialogo.DestDataSet = nil, 'DestDataSet');
  Assert.IsTrue(Dialogo.zSystem = nil, 'zSystem');
  Assert.IsTrue(Dialogo.zDbViewForm = nil, 'zDbViewForm');
  Assert.IsTrue(VarIsNull(Dialogo.FindValue), 'FindValue');
  Assert.IsFalse(Assigned(Dialogo.MultiSelectEvent), 'MultiSelectEvent');
  Assert.IsFalse(Assigned(Dialogo.OnInitDialog), 'OnInitDialog');
  Assert.IsFalse(Assigned(Dialogo.OnCloseDialog), 'OnCloseDialog');
  Assert.IsFalse(Assigned(Dialogo.OnBeforeExecute), 'OnBeforeExecute');
end;

procedure TTestzDbViewDlg.Create_Options_PredefinitiAutoAppendAutoPostRaiseOnError;
begin
  Assert.IsTrue(Dialogo.Options = [ddAutoAppend, ddAutoPost, ddRaiseOnError]);
  Assert.IsFalse(ddShowSelectBtns in Dialogo.Options, 'ddShowSelectBtns');
  Assert.IsFalse(ddClearFilterOnExit in Dialogo.Options, 'ddClearFilterOnExit');
end;

procedure TTestzDbViewDlg.Create_ToolActions_CollezioneVuotaCreataDalComponente;
begin
  Assert.IsTrue(Assigned(Dialogo.ToolActions), 'ToolActions creata');
  Assert.AreEqual(0, Dialogo.ToolActions.Count, 'ToolActions vuota');
end;

procedure TTestzDbViewDlg.Proprieta_Assegnate_SiRileggono;
var
  DatiScelta: TzFbDataSet;
  DatiDestinazione: TzFbDataSet;
begin
  DatiScelta := TzFbDataSet.Create(nil);
  DatiDestinazione := TzFbDataSet.Create(nil);
  try
    Dialogo.Caption := 'Scelta del comune';
    Dialogo.idLookup := 'Comuni.Elenco';
    Dialogo.DataSet := DatiScelta;
    Dialogo.DestDataSet := DatiDestinazione;
    Dialogo.Options := [ddShowSelectBtns, ddClearFilterOnExit];

    Assert.AreEqual('Scelta del comune', Dialogo.Caption, 'Caption');
    Assert.AreEqual('Comuni.Elenco', Dialogo.idLookup, 'idLookup');
    Assert.IsTrue(Dialogo.DataSet = DatiScelta, 'DataSet');
    Assert.IsTrue(Dialogo.DestDataSet = DatiDestinazione, 'DestDataSet');
    Assert.IsTrue(Dialogo.Options = [ddShowSelectBtns, ddClearFilterOnExit], 'Options');
    // nessuna finestra viene creata dalle sole assegnazioni
    Assert.IsTrue(Dialogo.zDbViewForm = nil, 'zDbViewForm');
  finally
    // il dialogo non possiede i dataset: si liberano dopo averlo scollegato
    Dialogo.DataSet := nil;
    Dialogo.DestDataSet := nil;
    DatiDestinazione.Free;
    DatiScelta.Free;
  end;
end;

procedure TTestzDbViewDlg.Execute_SenzaDataSet_EccezioneConNomeDelComponente;
var
  Messaggio: string;
  Sollevata: Boolean;
begin
  Dialogo.Name := 'dlgProva';
  Sollevata := False;
  Messaggio := '';

  try
    Dialogo.Execute;
  except
    on Errore: Exception do
    begin
      Sollevata := True;
      Messaggio := Errore.Message;
    end;
  end;

  Assert.IsTrue(Sollevata, 'eccezione');
  Assert.AreEqual('Dataset non assegnato: dlgProva', Messaggio);
end;

procedure TTestzDbViewDlg.Execute_SenzaDataSet_NessunaFinestraCreata;
var
  Sollevata: Boolean;
begin
  Sollevata := False;

  try
    Dialogo.Execute;
  except
    on Errore: Exception do
      Sollevata := True;
  end;

  Assert.IsTrue(Sollevata, 'eccezione');
  Assert.IsTrue(Dialogo.zDbViewForm = nil, 'zDbViewForm');
end;

procedure TTestzDbViewDlg.ExecuteConTitolo_SenzaDataSet_ScriveComunqueLaCaption;
var
  Sollevata: Boolean;
begin
  Sollevata := False;

  try
    // la forma lunga scrive Caption e DataSet nel componente prima di controllare
    Dialogo.Execute('Titolo di prova', nil);
  except
    on Errore: Exception do
      Sollevata := True;
  end;

  Assert.IsTrue(Sollevata, 'eccezione');
  Assert.AreEqual('Titolo di prova', Dialogo.Caption);
end;

procedure TTestzDbViewDlg.FindValue_SenzaFinestra_SiMemorizza;
begin
  Dialogo.FindValue := 'rossi';

  Assert.AreEqual('rossi', string(Dialogo.FindValue));

  // il valore non si azzera da solo (DIV-DVW-4): si riporta a null a mano
  Dialogo.FindValue := Null;
  Assert.IsTrue(VarIsNull(Dialogo.FindValue), 'null');
end;

procedure TTestzDbViewDlg.Eventi_Assegnati_SiRileggonoSenzaFinestra;
begin
  Dialogo.OnInitDialog := Ricevitore.GestoreVista;
  Dialogo.OnCloseDialog := Ricevitore.GestoreVista;
  Dialogo.OnBeforeExecute := Ricevitore.GestoreVista;
  Dialogo.MultiSelectEvent := Ricevitore.GestoreNotifica;
  Dialogo.OnCardBeforeCreateControls := Ricevitore.GestoreNotifica;
  Dialogo.OnCardAfterCreateControls := Ricevitore.GestoreNotifica;

  Assert.IsTrue(Assigned(Dialogo.OnInitDialog), 'OnInitDialog');
  Assert.IsTrue(Assigned(Dialogo.OnCloseDialog), 'OnCloseDialog');
  Assert.IsTrue(Assigned(Dialogo.OnBeforeExecute), 'OnBeforeExecute');
  Assert.IsTrue(Assigned(Dialogo.MultiSelectEvent), 'MultiSelectEvent');
  Assert.IsTrue(Assigned(Dialogo.OnCardBeforeCreateControls), 'OnCardBeforeCreateControls');
  Assert.IsTrue(Assigned(Dialogo.OnCardAfterCreateControls), 'OnCardAfterCreateControls');

  // senza finestra nessun setter ha una vista a cui inoltrare: nessun errore
  Dialogo.OnInitDialog := nil;
  Assert.IsFalse(Assigned(Dialogo.OnInitDialog), 'OnInitDialog azzerato');
end;

{ TTestzDbCardDlg }

procedure TTestzDbCardDlg.Setup;
begin
  Dialogo := TzDbCardDlg.Create(nil);
  Ricevitore := TRicevitoreEventi.Create;
end;

procedure TTestzDbCardDlg.TearDown;
begin
  Ricevitore.Free;
  Dialogo.Free;
end;

procedure TTestzDbCardDlg.Create_ValoriPredefiniti_TestiVuotiENessunCollegamento;
begin
  Assert.AreEqual('', Dialogo.Caption, 'Caption');
  Assert.AreEqual('', Dialogo.CardID, 'CardID');
  Assert.IsTrue(Dialogo.DataSet = nil, 'DataSet');
  Assert.IsTrue(Dialogo.zSystem = nil, 'zSystem');
  Assert.IsTrue(Dialogo.zDbCardForm = nil, 'zDbCardForm');
  Assert.IsFalse(Assigned(Dialogo.OnInitDialog), 'OnInitDialog');
  Assert.IsFalse(Assigned(Dialogo.OnBeforeExecute), 'OnBeforeExecute');
  Assert.IsFalse(Assigned(Dialogo.OnCloseDialog), 'OnCloseDialog');
  Assert.IsFalse(Assigned(Dialogo.OnDataSetDelete), 'OnDataSetDelete');
  Assert.IsFalse(Assigned(Dialogo.OnDataSetEdit), 'OnDataSetEdit');
  Assert.IsFalse(Assigned(Dialogo.OnDataSetInsert), 'OnDataSetInsert');
end;

procedure TTestzDbCardDlg.Create_ReadOnly_Falso;
begin
  Assert.IsFalse(Dialogo.ReadOnly);
end;

procedure TTestzDbCardDlg.Proprieta_Assegnate_SiRileggono;
begin
  Dialogo.Caption := 'Orario';
  Dialogo.CardID := 'RettificaRecapito';

  Assert.AreEqual('Orario', Dialogo.Caption, 'Caption');
  Assert.AreEqual('RettificaRecapito', Dialogo.CardID, 'CardID');
  // nessuna finestra viene creata dalle sole assegnazioni
  Assert.IsTrue(Dialogo.zDbCardForm = nil, 'zDbCardForm');
end;

procedure TTestzDbCardDlg.Execute_SenzaDataSet_EccezioneConNomeDelComponente;
var
  Messaggio: string;
  Sollevata: Boolean;
begin
  Dialogo.Name := 'dlgScheda';
  Sollevata := False;
  Messaggio := '';

  try
    Dialogo.Execute;
  except
    on Errore: Exception do
    begin
      Sollevata := True;
      Messaggio := Errore.Message;
    end;
  end;

  Assert.IsTrue(Sollevata, 'eccezione');
  Assert.AreEqual('Dataset non assegnato: dlgScheda', Messaggio);
end;

procedure TTestzDbCardDlg.Execute_SenzaDataSet_NessunaFinestraCreata;
var
  Sollevata: Boolean;
begin
  Sollevata := False;

  try
    Dialogo.Execute;
  except
    on Errore: Exception do
      Sollevata := True;
  end;

  Assert.IsTrue(Sollevata, 'eccezione');
  Assert.IsTrue(Dialogo.zDbCardForm = nil, 'zDbCardForm');
end;

procedure TTestzDbCardDlg.ReadOnly_SenzaFinestra_SiMemorizzaENonCreaLaFinestra;
begin
  Dialogo.ReadOnly := True;
  Assert.IsTrue(Dialogo.ReadOnly, 'vero');
  Assert.IsTrue(Dialogo.zDbCardForm = nil, 'nessuna finestra dopo True');

  Dialogo.ReadOnly := False;
  Assert.IsFalse(Dialogo.ReadOnly, 'falso');
  Assert.IsTrue(Dialogo.zDbCardForm = nil, 'nessuna finestra dopo False');
end;

procedure TTestzDbCardDlg.DestroyForm_SenzaFinestra_NonFaNiente;
begin
  Dialogo.DestroyForm;

  Assert.IsTrue(Dialogo.zDbCardForm = nil);
end;

procedure TTestzDbCardDlg.DestroyControls_SenzaFinestra_NonFaNiente;
begin
  Dialogo.DestroyControls;

  Assert.IsTrue(Dialogo.zDbCardForm = nil);
end;

procedure TTestzDbCardDlg.CambioDiDataSet_SenzaFinestra_SiMemorizza;
var
  PrimiDati: TzFbDataSet;
  SecondiDati: TzFbDataSet;
begin
  PrimiDati := TzFbDataSet.Create(nil);
  SecondiDati := TzFbDataSet.Create(nil);
  try
    Dialogo.DataSet := PrimiDati;
    Assert.IsTrue(Dialogo.DataSet = PrimiDati, 'primo dataset');

    // con un dataset diverso il componente distrugge la finestra: senza finestra
    // si limita a memorizzare il nuovo valore
    Dialogo.DataSet := SecondiDati;
    Assert.IsTrue(Dialogo.DataSet = SecondiDati, 'secondo dataset');
    Assert.IsTrue(Dialogo.zDbCardForm = nil, 'zDbCardForm');
  finally
    Dialogo.DataSet := nil;
    SecondiDati.Free;
    PrimiDati.Free;
  end;
end;

procedure TTestzDbCardDlg.Eventi_Assegnati_SiRileggonoSenzaFinestra;
begin
  Dialogo.OnInitDialog := Ricevitore.GestoreScheda;
  Dialogo.OnBeforeExecute := Ricevitore.GestoreScheda;
  Dialogo.OnCloseDialog := Ricevitore.GestoreScheda;
  Dialogo.OnDataSetDelete := Ricevitore.GestoreNotifica;
  Dialogo.OnDataSetEdit := Ricevitore.GestoreNotifica;
  Dialogo.OnDataSetInsert := Ricevitore.GestoreNotifica;
  Dialogo.OnBeforeCreateControls := Ricevitore.GestoreNotifica;
  Dialogo.OnAfterCreateControls := Ricevitore.GestoreNotifica;

  Assert.IsTrue(Assigned(Dialogo.OnInitDialog), 'OnInitDialog');
  Assert.IsTrue(Assigned(Dialogo.OnBeforeExecute), 'OnBeforeExecute');
  Assert.IsTrue(Assigned(Dialogo.OnCloseDialog), 'OnCloseDialog');
  Assert.IsTrue(Assigned(Dialogo.OnDataSetDelete), 'OnDataSetDelete');
  Assert.IsTrue(Assigned(Dialogo.OnDataSetEdit), 'OnDataSetEdit');
  Assert.IsTrue(Assigned(Dialogo.OnDataSetInsert), 'OnDataSetInsert');
  Assert.IsTrue(Assigned(Dialogo.OnBeforeCreateControls), 'OnBeforeCreateControls');
  Assert.IsTrue(Assigned(Dialogo.OnAfterCreateControls), 'OnAfterCreateControls');

  Dialogo.OnDataSetInsert := nil;
  Assert.IsFalse(Assigned(Dialogo.OnDataSetInsert), 'OnDataSetInsert azzerato');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzDbViewDlg);
  TDUnitX.RegisterTestFixture(TTestzDbCardDlg);

end.
