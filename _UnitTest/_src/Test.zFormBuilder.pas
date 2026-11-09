// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zFormBuilder;

// Test DUnitX di zBase\zFormBuilder (specifica ZBASE-FRB, "Costruttore di
// form.md").
//
// Il costruttore lavora su un TdxLayoutControl: qui se ne crea uno senza
// mostrarlo (la form e' creata con CreateNew e mai visualizzata). Si provano
// il collegamento al layout, le ricerche, i gruppi, gli elementi, i pulsanti,
// la liberazione e la sospensione degli aggiornamenti. I controlli di modifica
// creati da CreateControl passano dal modulo Tdx di zDX (stili, immagini) e
// non sono provati; non lo sono nemmeno le caselle di ricerca e la finestra
// di personalizzazione.
//
// Le divergenze provate (DIV-FRB-2, 3) fotografano il comportamento attuale:
// vanno capovolte quando il codice viene corretto. DIV-FRB-1 (Clear liberava
// due volte i controlli gia' distrutti dal layout) e DIV-FRB-5 (gruppo
// predefinito che pendeva) sono corrette e provate come comportamento voluto.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Vcl.Forms,
  Vcl.ActnList,
  cxButtons,
  cxCheckBox,
  cxEdit,
  dxLayoutCommon,
  dxLayoutContainer,
  dxLayoutControl,
  DUnitX.TestFramework,
  zFormBuilder;

type
  [TestFixture]
  TTestzFormBuilder = class
  private
    FForm: TForm;
    FLayout: TdxLayoutControl;
    FBuilder: TzFormBuilder;
    function NuovaAzione(const Nome: string): TAction;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-FRB-001
    [Test]
    procedure Creazione_ColleganLayoutEIdentificativo;
    // ZBASE-FRB-001
    [Test]
    procedure LayoutLiberato_IlRiferimentoTornaNil;
    // ZBASE-FRB-001
    [Test]
    procedure SenzaLayout_LeChiamateProtetteNonSollevano;
    // ZBASE-FRB-005
    [Test]
    procedure CostruttoreVuoto_RicercheSenzaRisultato;
    // ZBASE-FRB-005
    [Test]
    procedure CostruttoreVuoto_SetValueNonSolleva;
    // ZBASE-FRB-005
    [Test]
    procedure LayoutItemByName_Inesistente_RestituisceNil;
    // ZBASE-FRB-002
    [Test]
    procedure AddLayoutGroup_ASchede_HaBordoELinguetteVisibili;
    // ZBASE-FRB-002
    [Test]
    procedure AddLayoutGroup_NonASchede_NienteBordoENonRispettaMostraBordo;
    // ZBASE-FRB-002
    [Test]
    procedure AddLayoutGroup_SenzaGenitore_UsaUnSoloGruppoPredefinito;
    // ZBASE-FRB-002
    [Test]
    procedure AddLayoutGroup_SenzaNome_NomeGeneratoEUnivoco;
    // ZBASE-FRB-002
    [Test]
    procedure AddLayoutGroup_SenzaTitolo_IlTitoloEIlNome;
    // DIV-FRB-2
    [Test]
    procedure Divergenza_DIV_FRB_2_UnNomeRichiestoNonVieneApplicato;
    // DIV-FRB-2
    [Test]
    procedure Divergenza_DIV_FRB_2_IlDivisoreUsaIlNomeDelCostruttore;
    // ZBASE-FRB-003
    [Test]
    procedure AddLayoutItem_SenzaTitolo_NascondeIlTitolo;
    // ZBASE-FRB-003
    [Test]
    procedure AddLayoutItem_ConTitolo_LoMostra;
    // ZBASE-FRB-003
    [Test]
    procedure AddLayoutItem_NomeGiaUsato_AggiungeIlSuffisso;
    // ZBASE-FRB-007
    [Test]
    procedure AddButton_CreaIlPulsanteDaAzione;
    // ZBASE-FRB-009
    [Test]
    procedure Clear_CostruttoreVuoto_NonSolleva;
    // ZBASE-FRB-009 e DIV-FRB-1
    [Test]
    procedure Clear_ConPiuControlli_LiLiberaTuttiESvuotaLElenco;
    // ZBASE-FRB-009 e DIV-FRB-5
    [Test]
    procedure Clear_PoiNuovoGruppoSenzaGenitore_CreaUnGruppoPredefinitoVivo;
    // ZBASE-FRB-010
    [Test]
    procedure BeginUpdateEEndUpdate_SospendonoEPoiRiattivanoIlLayout;
    // DIV-FRB-3
    [Test]
    procedure Divergenza_DIV_FRB_3_IsUpdatingRispondeSempreFalso;
    // ZBASE-FRB-011 e DIV-FRB-4
    [Test]
    procedure SaveLayoutELoadLayout_NonFannoNiente;
  end;

implementation

// TTestzFormBuilder

procedure TTestzFormBuilder.Setup;
begin
  FForm := TForm.CreateNew(nil);

  FLayout := TdxLayoutControl.Create(FForm);
  FLayout.Name := 'dxLayoutProva';
  FLayout.Parent := FForm;

  // Stesso proprietario del layout: e' il caso in cui Notification arriva
  FBuilder := TzFormBuilder.Create(FForm, FLayout, 'Parametri');
end;

procedure TTestzFormBuilder.TearDown;
begin
  FreeAndNil(FForm);
end;

function TTestzFormBuilder.NuovaAzione(const Nome: string): TAction;
begin
  Result := TAction.Create(FForm);
  Result.Name := Nome;
end;

procedure TTestzFormBuilder.Creazione_ColleganLayoutEIdentificativo;
begin
  Assert.AreSame(TObject(FLayout), TObject(FBuilder.dxLayoutControl));
  Assert.AreEqual('Parametri', FBuilder.LayoutID);

  FBuilder.LayoutID := 'Altro';
  Assert.AreEqual('Altro', FBuilder.LayoutID);
end;

procedure TTestzFormBuilder.LayoutLiberato_IlRiferimentoTornaNil;
begin
  FreeAndNil(FLayout);

  Assert.IsNull(FBuilder.dxLayoutControl);
end;

procedure TTestzFormBuilder.SenzaLayout_LeChiamateProtetteNonSollevano;
begin
  FreeAndNil(FLayout);

  Assert.WillNotRaiseAny(
    procedure
    begin
      FBuilder.BeginUpdate;
      FBuilder.EndUpdate;
      FBuilder.Customize;
    end);

  Assert.IsNull(FBuilder.LayoutItemByName('X'));
  Assert.IsNull(FBuilder.LayoutItemByControl(nil));
  Assert.IsFalse(FBuilder.IsUpdating);
end;

procedure TTestzFormBuilder.CostruttoreVuoto_RicercheSenzaRisultato;
begin
  Assert.IsFalse(FBuilder.Exists('X'));
  Assert.IsNull(FBuilder.GetControl('X'));
  Assert.IsNull(FBuilder.ControlByName<TcxCheckBox>('X'));
  Assert.IsTrue(VarIsNull(FBuilder.GetValue('X')));
end;

procedure TTestzFormBuilder.CostruttoreVuoto_SetValueNonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FBuilder.SetValue('X', 1);
    end);
end;

procedure TTestzFormBuilder.LayoutItemByName_Inesistente_RestituisceNil;
begin
  Assert.IsNull(FBuilder.LayoutItemByName('NonEsiste'));
end;

procedure TTestzFormBuilder.AddLayoutGroup_ASchede_HaBordoELinguetteVisibili;
var
  Gruppo: TdxLayoutGroup;
begin
  Gruppo := FBuilder.AddLayoutGroup(nil, '', ldTabbed, 'Dati');

  Assert.AreEqual('Dati', Gruppo.Caption);
  Assert.IsTrue(Gruppo.ShowBorder);
  Assert.IsFalse(Gruppo.TabbedOptions.HideTabs);
  Assert.IsTrue(Gruppo.TabbedOptions.ShowFrame);
end;

procedure TTestzFormBuilder.AddLayoutGroup_NonASchede_NienteBordoENonRispettaMostraBordo;
var
  Gruppo: TdxLayoutGroup;
begin
  // Il quinto parametro (MostraBordo) e' vero ma non ha effetto (DIV-FRB-2)
  Gruppo := FBuilder.AddLayoutGroup(nil, '', ldHorizontal, '', True);

  Assert.IsFalse(Gruppo.ShowBorder);
  Assert.IsTrue(Gruppo.TabbedOptions.HideTabs);
  Assert.IsFalse(Gruppo.TabbedOptions.ShowFrame);
end;

procedure TTestzFormBuilder.AddLayoutGroup_SenzaGenitore_UsaUnSoloGruppoPredefinito;
var
  Primo, Secondo: TdxLayoutGroup;
begin
  Primo := FBuilder.AddLayoutGroup(nil, '', ldHorizontal);
  Secondo := FBuilder.AddLayoutGroup(nil, '', ldVertical);

  Assert.IsNotNull(Primo.Parent);
  Assert.AreSame(TObject(Primo.Parent), TObject(Secondo.Parent));
  Assert.AreEqual('dxLayoutProvaDefaultParentGroup', Primo.Parent.Name);
end;

procedure TTestzFormBuilder.AddLayoutGroup_SenzaNome_NomeGeneratoEUnivoco;
var
  Primo, Secondo: TdxLayoutGroup;
begin
  Primo := FBuilder.AddLayoutGroup;
  Secondo := FBuilder.AddLayoutGroup;

  Assert.AreEqual('dxLayoutProvaGroup', Primo.Name);
  Assert.AreEqual('dxLayoutProvaGroup_1', Secondo.Name);
end;

procedure TTestzFormBuilder.AddLayoutGroup_SenzaTitolo_IlTitoloEIlNome;
var
  Gruppo: TdxLayoutGroup;
begin
  Gruppo := FBuilder.AddLayoutGroup;

  Assert.AreEqual(Gruppo.Name, Gruppo.Caption);
end;

procedure TTestzFormBuilder.Divergenza_DIV_FRB_2_UnNomeRichiestoNonVieneApplicato;
var
  Gruppo: TdxLayoutGroup;
begin
  Gruppo := FBuilder.AddLayoutGroup(nil, 'gruppoProva');

  // Oggi il nome si assegna solo quando aName e' vuoto: quello richiesto si
  // perde. Quando il codice e' corretto, questo test va capovolto
  // (il nome deve essere gruppoProva) e va tolto l'altro caso.
  Assert.AreNotEqual('gruppoProva', Gruppo.Name);
  Assert.IsNull(FBuilder.LayoutItemByName('gruppoProva'));
end;

procedure TTestzFormBuilder.Divergenza_DIV_FRB_2_IlDivisoreUsaIlNomeDelCostruttore;
var
  Divisore: TdxLayoutSplitterItem;
begin
  FBuilder.Name := 'Costruttore';

  Divisore := FBuilder.AddLayoutSplitter;

  // Il testo aggiunto e' Name del costruttore e non il parametro aName; quando
  // il codice e' corretto il nome sara' dxLayoutProvaSplitter (senza il nome
  // del costruttore) e il test va capovolto
  Assert.AreEqual('dxLayoutProvaSplitterCostruttore', Divisore.Name);
end;

procedure TTestzFormBuilder.AddLayoutItem_SenzaTitolo_NascondeIlTitolo;
var
  Pulsante: TcxButton;
  Elemento: TdxLayoutItem;
begin
  Pulsante := TcxButton.Create(FForm);
  Pulsante.Name := 'Prova';

  Elemento := FBuilder.AddLayoutItem(Pulsante);

  Assert.AreEqual('dxLayoutProvaItemProva', Elemento.Name);
  Assert.IsFalse(Elemento.ShowCaption);
  Assert.AreEqual('Prova', Elemento.Caption);
  Assert.AreSame(TObject(Pulsante), TObject(Elemento.Control));
end;

procedure TTestzFormBuilder.AddLayoutItem_ConTitolo_LoMostra;
var
  Pulsante: TcxButton;
  Elemento: TdxLayoutItem;
begin
  Pulsante := TcxButton.Create(FForm);
  Pulsante.Name := 'Prova';

  Elemento := FBuilder.AddLayoutItem(Pulsante, nil, ahClient, avClient, 'Etichetta');

  Assert.IsTrue(Elemento.ShowCaption);
  Assert.AreEqual('Etichetta', Elemento.Caption);
end;

procedure TTestzFormBuilder.AddLayoutItem_NomeGiaUsato_AggiungeIlSuffisso;
var
  Pulsante, Gemello: TcxButton;
  Primo, Secondo: TdxLayoutItem;
begin
  Pulsante := TcxButton.Create(FForm);
  Pulsante.Name := 'Prova';
  // stesso nome, altro proprietario: DevExpress non accetta lo stesso controllo in due elementi
  Gemello := TcxButton.Create(TComponent.Create(FForm));
  Gemello.Name := 'Prova';

  Primo := FBuilder.AddLayoutItem(Pulsante);
  Secondo := FBuilder.AddLayoutItem(Gemello);

  Assert.AreEqual('dxLayoutProvaItemProva', Primo.Name);
  Assert.AreEqual('dxLayoutProvaItemProva_1', Secondo.Name);
end;

procedure TTestzFormBuilder.AddButton_CreaIlPulsanteDaAzione;
var
  Azione: TAction;
  Pulsante: TcxButton;
begin
  Azione := NuovaAzione('Salva');

  Pulsante := FBuilder.AddButton(Azione);

  Assert.AreEqual('btnSalva', Pulsante.Name);
  Assert.AreSame(TObject(Azione), TObject(Pulsante.Action));
  // Il pulsante e' fra i controlli del costruttore ma non e' un controllo di modifica
  Assert.IsTrue(FBuilder.Exists('btnSalva'));
  Assert.AreSame(TObject(Pulsante), TObject(FBuilder.ControlByName<TcxButton>('btnSalva')));
  Assert.IsNull(FBuilder.GetControl('btnSalva'));
  // Ha il suo elemento di layout
  Assert.IsNotNull(FBuilder.LayoutItemByControl(Pulsante));
end;

procedure TTestzFormBuilder.Clear_CostruttoreVuoto_NonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FBuilder.Clear;
    end);
end;

procedure TTestzFormBuilder.Clear_ConPiuControlli_LiLiberaTuttiESvuotaLElenco;
begin
  FBuilder.AddButton(NuovaAzione('Salva'));
  FBuilder.AddButton(NuovaAzione('Annulla'));
  FBuilder.AddButton(NuovaAzione('Chiudi'));
  Assert.IsTrue(FBuilder.Exists('btnChiudi'));

  // Prima della correzione: il ciclo in avanti con Remove usciva dall'elenco
  // (EArgumentOutOfRangeException) e liberava di nuovo controlli gia' distrutti
  Assert.WillNotRaiseAny(
    procedure
    begin
      FBuilder.Clear;
    end);

  Assert.IsFalse(FBuilder.Exists('btnSalva'));
  Assert.IsFalse(FBuilder.Exists('btnAnnulla'));
  Assert.IsFalse(FBuilder.Exists('btnChiudi'));
end;

procedure TTestzFormBuilder.Clear_PoiNuovoGruppoSenzaGenitore_CreaUnGruppoPredefinitoVivo;
var
  Gruppo: TdxLayoutGroup;
begin
  FBuilder.AddLayoutGroup(nil, '', ldHorizontal);

  FBuilder.Clear;

  // Il gruppo predefinito e' stato distrutto da Clear del layout: ne serve uno nuovo
  Gruppo := FBuilder.AddLayoutGroup(nil, '', ldVertical);

  Assert.IsNotNull(Gruppo.Parent);
  Assert.AreEqual('dxLayoutProvaDefaultParentGroup', Gruppo.Parent.Name);
end;

procedure TTestzFormBuilder.BeginUpdateEEndUpdate_SospendonoEPoiRiattivanoIlLayout;
begin
  FBuilder.BeginUpdate;
  try
    Assert.IsTrue(FLayout.Container.IsUpdateLocked);
  finally
    FBuilder.EndUpdate;
  end;

  Assert.IsFalse(FLayout.Container.IsUpdateLocked);
end;

procedure TTestzFormBuilder.Divergenza_DIV_FRB_3_IsUpdatingRispondeSempreFalso;
begin
  FBuilder.BeginUpdate;
  try
    // Oggi il risultato di IsUpdateLocked non viene restituito: quando il
    // codice e' corretto questo test va capovolto (deve rispondere vero)
    Assert.IsFalse(FBuilder.IsUpdating);
  finally
    FBuilder.EndUpdate;
  end;
end;

procedure TTestzFormBuilder.SaveLayoutELoadLayout_NonFannoNiente;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FBuilder.SaveLayout;
      FBuilder.LoadLayout;
    end);

  // Oggi sono vuote: quando verranno implementate questo test va riscritto
  Assert.AreEqual('Parametri', FBuilder.LayoutID);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzFormBuilder);

end.
