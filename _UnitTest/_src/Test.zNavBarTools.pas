// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zNavBarTools;

// Test DUnitX di zBase\zNavBarTools (specifica ZBASE-NVB, "Barra di
// navigazione.md").
//
// Nessuna prova mostra una finestra: la form e' creata con CreateNew e mai
// mostrata, la barra laterale (TdxNavBar) e i contenitori a schede
// (TcxPageControl) non hanno genitore ne' handle. Si provano:
//   - l'azzeramento dei collegamenti alla distruzione dei componenti
//     (ZBASE-NVB-001);
//   - la costruzione dei gruppi per categoria e la ricostruzione senza
//     accumulo (ZBASE-NVB-002);
//   - il collegamento azione-scheda e il gestore assegnato solo se assente
//     (ZBASE-NVB-003);
//   - il cambio di pagina (ZBASE-NVB-004);
//   - TryNavBar sempre falsa (ZBASE-NVB-005).
// TryNavBar con valore vero apre finestre modali e non e' provata.
//
// DIV-NVB-1 fotografa il comportamento attuale: va capovolta quando il
// codice controlla il valore nullo.

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.ActnList,
  cxPC,
  dxNavBar,
  DUnitX.TestFramework,
  zNavBarTools;

type
  [TestFixture]
  TTestActionTabLinks = class
  private
    FForm: TForm;
    FCollegamenti: TActionTabLinks;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-NVB-003
    [Test]
    procedure AddLink_RegistraAzioneEScheda;
    // ZBASE-NVB-003
    [Test]
    procedure AddLink_DueVolteLaStessaCoppia_DueCollegamenti;
    // ZBASE-NVB-003
    [Test]
    procedure Insert_MetteIlCollegamentoNellaPosizioneIndicata;
    // ZBASE-NVB-003
    [Test]
    procedure Assign_CopiaAzioneEScheda;
    // ZBASE-NVB-004
    [Test]
    procedure ActivateTab_SenzaScheda_NonFaNiente;
  end;

  [TestFixture]
  TTestzNavBarTools = class
  private
    FForm: TForm;
    FStrumenti: TzNavBarTools;
    FLista: TActionList;
    FGestoreChiamato: Integer;
    procedure GestoreProva(Sender: TObject);
    function NuovaAzione(const Nome, Categoria: string): TAction;
    function NuovoContenitore: TcxPageControl;
    function NuovaPagina(Contenitore: TcxPageControl): TcxTabSheet;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-NVB-001
    [Test]
    procedure Creazione_ProprietaVuote;
    // ZBASE-NVB-001
    [Test]
    procedure ListaDistrutta_ActionListTornaNil;
    // ZBASE-NVB-001
    [Test]
    procedure BarraDistrutta_dxNavBarTornaNil;
    // DIV-NVB-1
    [Test]
    procedure AssegnareNil_LasciaLaProprietaVuota;
    // DIV-NVB-1
    [Test]
    procedure AssegnareNil_DopoUnaLista_NonNotificaPiu;
    // ZBASE-NVB-002
    [Test]
    procedure BuildSideBar_SenzaBarra_SollevaLaVerifica;
    // ZBASE-NVB-002
    [Test]
    procedure BuildSideBar_SenzaLista_SollevaLaVerifica;
    // ZBASE-NVB-002
    [Test]
    procedure BuildSideBar_GruppiPerCategoria_NellOrdineDellaPrimaAzione;
    // ZBASE-NVB-002
    [Test]
    procedure BuildSideBar_Ricostruzione_NonAccumula;
    // DIV-NVB-4
    [Test]
    procedure Divergenza_DIV_NVB_4_AzioneNascosta_NonHaVoce;
    // DIV-NVB-4
    [Test]
    procedure Divergenza_DIV_NVB_4_ListaVuota_NessunErrore;
    // ZBASE-NVB-002
    [Test]
    procedure BuildSideBar_ConParametri_AssegnaLeProprieta;
    // ZBASE-NVB-003
    [Test]
    procedure AddLink_AzioneSenzaGestore_AssegnaOnExecute;
    // ZBASE-NVB-003
    [Test]
    procedure AddLink_AzioneConGestore_LoConservaENonCambiaPagina;
    // ZBASE-NVB-004
    [Test]
    procedure ChangeActivePage_AzioneCollegata_PortaInPrimoPianoLaScheda;
    // ZBASE-NVB-004
    [Test]
    procedure ChangeActivePage_SchedeInContenitoriDiversi_AttivaTutte;
    // ZBASE-NVB-004
    [Test]
    procedure ChangeActivePage_DueSchedeNelloStessoContenitore_VinceLUltima;
    // ZBASE-NVB-004
    [Test]
    procedure ChangeActivePage_MittenteNonAzione_NonCambiaNiente;
    // ZBASE-NVB-005
    [Test]
    procedure TryNavBar_Falso_NonFaNienteERestaFalso;
  end;

implementation

// TTestActionTabLinks

procedure TTestActionTabLinks.Setup;
begin
  FForm := TForm.CreateNew(nil);
  FCollegamenti := TActionTabLinks.Create(TActionTabLink);
end;

procedure TTestActionTabLinks.TearDown;
begin
  FreeAndNil(FCollegamenti);
  FreeAndNil(FForm);
end;

procedure TTestActionTabLinks.AddLink_RegistraAzioneEScheda;
var
  Azione: TAction;
  Collegamento: TActionTabLink;
begin
  Azione := TAction.Create(FForm);

  Collegamento := FCollegamenti.AddLink(Azione, nil);

  Assert.AreEqual(1, FCollegamenti.Count);
  Assert.AreSame(TObject(Azione), TObject(Collegamento.Action));
  Assert.IsNull(Collegamento.TabSheet);
  Assert.AreSame(TObject(Collegamento), TObject(FCollegamenti[0]));
end;

procedure TTestActionTabLinks.AddLink_DueVolteLaStessaCoppia_DueCollegamenti;
var
  Azione: TAction;
begin
  Azione := TAction.Create(FForm);

  FCollegamenti.AddLink(Azione, nil);
  FCollegamenti.AddLink(Azione, nil);

  Assert.AreEqual(2, FCollegamenti.Count);
end;

procedure TTestActionTabLinks.Insert_MetteIlCollegamentoNellaPosizioneIndicata;
var
  Prima, Seconda: TAction;
  Inserito: TActionTabLink;
begin
  Prima := TAction.Create(FForm);
  Seconda := TAction.Create(FForm);
  FCollegamenti.AddLink(Prima, nil);
  FCollegamenti.AddLink(Seconda, nil);

  Inserito := FCollegamenti.Insert(0);

  Assert.AreEqual(3, FCollegamenti.Count);
  Assert.AreSame(TObject(Inserito), TObject(FCollegamenti[0]));
  Assert.AreSame(TObject(Prima), TObject(FCollegamenti[1].Action));
end;

procedure TTestActionTabLinks.Assign_CopiaAzioneEScheda;
var
  Azione: TAction;
  Origine, Destinazione: TActionTabLink;
begin
  Azione := TAction.Create(FForm);
  Origine := FCollegamenti.AddLink(Azione, nil);
  Destinazione := FCollegamenti.Add;

  Destinazione.Assign(Origine);

  Assert.AreSame(TObject(Azione), TObject(Destinazione.Action));
  Assert.IsNull(Destinazione.TabSheet);
end;

procedure TTestActionTabLinks.ActivateTab_SenzaScheda_NonFaNiente;
var
  Collegamento: TActionTabLink;
begin
  Collegamento := FCollegamenti.AddLink(TAction.Create(FForm), nil);

  Assert.WillNotRaiseAny(
    procedure
    begin
      Collegamento.ActivateTab;
    end);
end;

// TTestzNavBarTools

procedure TTestzNavBarTools.Setup;
begin
  FForm := TForm.CreateNew(nil);
  FStrumenti := TzNavBarTools.Create(FForm);
  FLista := TActionList.Create(FForm);
  FGestoreChiamato := 0;
end;

procedure TTestzNavBarTools.TearDown;
begin
  FreeAndNil(FForm);
end;

procedure TTestzNavBarTools.GestoreProva(Sender: TObject);
begin
  Inc(FGestoreChiamato);
end;

function TTestzNavBarTools.NuovaAzione(const Nome, Categoria: string): TAction;
begin
  Result := TAction.Create(FForm);
  Result.Name := Nome;
  Result.Caption := Nome;
  Result.Category := Categoria;
  Result.ActionList := FLista;
end;

function TTestzNavBarTools.NuovoContenitore: TcxPageControl;
begin
  Result := TcxPageControl.Create(FForm);
end;

function TTestzNavBarTools.NuovaPagina(Contenitore: TcxPageControl): TcxTabSheet;
begin
  Result := TcxTabSheet.Create(FForm);
  Result.PageControl := Contenitore;
end;

procedure TTestzNavBarTools.Creazione_ProprietaVuote;
begin
  Assert.IsNull(FStrumenti.ActionList);
  Assert.IsNull(FStrumenti.dxNavBar);
  Assert.IsFalse(FStrumenti.TryNavBar);
end;

procedure TTestzNavBarTools.ListaDistrutta_ActionListTornaNil;
begin
  FStrumenti.ActionList := FLista;
  Assert.AreSame(TObject(FLista), TObject(FStrumenti.ActionList));

  FreeAndNil(FLista);

  Assert.IsNull(FStrumenti.ActionList);
end;

procedure TTestzNavBarTools.BarraDistrutta_dxNavBarTornaNil;
var
  Barra: TdxNavBar;
begin
  Barra := TdxNavBar.Create(FForm);
  FStrumenti.dxNavBar := Barra;
  Assert.AreSame(TObject(Barra), TObject(FStrumenti.dxNavBar));

  FreeAndNil(Barra);

  Assert.IsNull(FStrumenti.dxNavBar);
end;

procedure TTestzNavBarTools.AssegnareNil_LasciaLaProprietaVuota;
begin
  // DIV-NVB-1: i setter controllano il valore nullo
  FStrumenti.ActionList := nil;
  FStrumenti.dxNavBar := nil;

  Assert.IsNull(FStrumenti.ActionList);
  Assert.IsNull(FStrumenti.dxNavBar);
end;

procedure TTestzNavBarTools.AssegnareNil_DopoUnaLista_NonNotificaPiu;
begin
  // DIV-NVB-1: si toglie il collegamento e la lista distrutta dopo non tocca
  // piu' lo strumento
  FStrumenti.ActionList := FLista;
  FStrumenti.ActionList := nil;

  FreeAndNil(FLista);

  Assert.IsNull(FStrumenti.ActionList);
end;

procedure TTestzNavBarTools.BuildSideBar_SenzaBarra_SollevaLaVerifica;
begin
  FStrumenti.ActionList := FLista;

  Assert.WillRaise(
    procedure
    begin
      FStrumenti.BuildSideBar;
    end,
    EAssertionFailed);
end;

procedure TTestzNavBarTools.BuildSideBar_SenzaLista_SollevaLaVerifica;
begin
  FStrumenti.dxNavBar := TdxNavBar.Create(FForm);

  Assert.WillRaise(
    procedure
    begin
      FStrumenti.BuildSideBar;
    end,
    EAssertionFailed);
end;

procedure TTestzNavBarTools.BuildSideBar_GruppiPerCategoria_NellOrdineDellaPrimaAzione;
var
  Barra: TdxNavBar;
begin
  Barra := TdxNavBar.Create(FForm);
  NuovaAzione('ElencoUno', 'Elenchi');
  NuovaAzione('AttoUno', 'Atti');
  NuovaAzione('ElencoDue', 'Elenchi');

  FStrumenti.ActionList := FLista;
  FStrumenti.dxNavBar := Barra;
  FStrumenti.BuildSideBar;

  Assert.AreEqual(2, Barra.Groups.Count);
  Assert.AreEqual('Elenchi', Barra.Groups[0].Caption);
  Assert.AreEqual(2, Barra.Groups[0].LinkCount);
  Assert.AreEqual('Atti', Barra.Groups[1].Caption);
  Assert.AreEqual(1, Barra.Groups[1].LinkCount);
  Assert.AreEqual(3, Barra.Items.Count);
end;

procedure TTestzNavBarTools.BuildSideBar_Ricostruzione_NonAccumula;
var
  Barra: TdxNavBar;
begin
  Barra := TdxNavBar.Create(FForm);
  NuovaAzione('ElencoUno', 'Elenchi');
  NuovaAzione('AttoUno', 'Atti');
  NuovaAzione('ElencoDue', 'Elenchi');
  FStrumenti.ActionList := FLista;
  FStrumenti.dxNavBar := Barra;

  FStrumenti.BuildSideBar;
  FStrumenti.BuildSideBar;

  Assert.AreEqual(2, Barra.Groups.Count);
  Assert.AreEqual(3, Barra.Items.Count);
end;

procedure TTestzNavBarTools.Divergenza_DIV_NVB_4_AzioneNascosta_NonHaVoce;
var
  Barra: TdxNavBar;
begin
  Barra := TdxNavBar.Create(FForm);
  NuovaAzione('ElencoUno', 'Elenchi');
  NuovaAzione('AttoNascosto', 'Atti');
  TAction(FLista.Actions[1]).Visible := False;
  FStrumenti.ActionList := FLista;
  FStrumenti.dxNavBar := Barra;

  FStrumenti.BuildSideBar;

  // DIV-NVB-4: l'azione nascosta non crea ne' voce ne' gruppo
  Assert.AreEqual(1, Barra.Items.Count);
  Assert.AreEqual(1, Barra.Groups.Count);
  Assert.AreEqual('Elenchi', Barra.Groups[0].Caption);
end;

procedure TTestzNavBarTools.Divergenza_DIV_NVB_4_ListaVuota_NessunErrore;
var
  Barra: TdxNavBar;
begin
  Barra := TdxNavBar.Create(FForm);
  FStrumenti.ActionList := FLista;
  FStrumenti.dxNavBar := Barra;

  FStrumenti.BuildSideBar;

  Assert.AreEqual(0, Barra.Groups.Count);
  Assert.AreEqual(0, Barra.Items.Count);
end;

procedure TTestzNavBarTools.BuildSideBar_ConParametri_AssegnaLeProprieta;
var
  Barra: TdxNavBar;
begin
  Barra := TdxNavBar.Create(FForm);
  NuovaAzione('ElencoUno', 'Elenchi');

  FStrumenti.BuildSideBar(Barra, FLista);

  Assert.AreSame(TObject(FLista), TObject(FStrumenti.ActionList));
  Assert.AreSame(TObject(Barra), TObject(FStrumenti.dxNavBar));
  Assert.AreEqual(1, Barra.Groups.Count);
end;

procedure TTestzNavBarTools.AddLink_AzioneSenzaGestore_AssegnaOnExecute;
var
  Azione: TAction;
begin
  Azione := NuovaAzione('Elenco', 'Elenchi');
  Assert.IsFalse(Assigned(Azione.OnExecute));

  FStrumenti.AddLink(Azione, NuovaPagina(NuovoContenitore));

  Assert.IsTrue(Assigned(Azione.OnExecute));
end;

procedure TTestzNavBarTools.AddLink_AzioneConGestore_LoConservaENonCambiaPagina;
var
  Azione: TAction;
  Contenitore: TcxPageControl;
  PaginaUno, PaginaDue: TcxTabSheet;
begin
  Azione := NuovaAzione('Elenco', 'Elenchi');
  Azione.OnExecute := GestoreProva;
  Contenitore := NuovoContenitore;
  PaginaUno := NuovaPagina(Contenitore);
  PaginaDue := NuovaPagina(Contenitore);
  Contenitore.ActivePage := PaginaUno;

  FStrumenti.AddLink(Azione, PaginaDue);
  Azione.OnExecute(Azione);

  // Il gestore originale e' rimasto e il collegamento non e' mai usato
  Assert.AreEqual(1, FGestoreChiamato);
  Assert.AreSame(TObject(PaginaUno), TObject(Contenitore.ActivePage));
end;

procedure TTestzNavBarTools.ChangeActivePage_AzioneCollegata_PortaInPrimoPianoLaScheda;
var
  Azione: TAction;
  Contenitore: TcxPageControl;
  PaginaUno, PaginaDue: TcxTabSheet;
begin
  Azione := NuovaAzione('Elenco', 'Elenchi');
  Contenitore := NuovoContenitore;
  PaginaUno := NuovaPagina(Contenitore);
  PaginaDue := NuovaPagina(Contenitore);
  Contenitore.ActivePage := PaginaUno;

  FStrumenti.AddLink(Azione, PaginaDue);
  Azione.OnExecute(Azione);

  Assert.AreSame(TObject(PaginaDue), TObject(Contenitore.ActivePage));
end;

procedure TTestzNavBarTools.ChangeActivePage_SchedeInContenitoriDiversi_AttivaTutte;
var
  Azione: TAction;
  ContenitoreEsterno, ContenitoreInterno: TcxPageControl;
  EsternaUno, EsternaDue, InternaUno, InternaDue: TcxTabSheet;
begin
  Azione := NuovaAzione('Elenco', 'Elenchi');
  ContenitoreEsterno := NuovoContenitore;
  EsternaUno := NuovaPagina(ContenitoreEsterno);
  EsternaDue := NuovaPagina(ContenitoreEsterno);
  ContenitoreInterno := NuovoContenitore;
  InternaUno := NuovaPagina(ContenitoreInterno);
  InternaDue := NuovaPagina(ContenitoreInterno);
  ContenitoreEsterno.ActivePage := EsternaUno;
  ContenitoreInterno.ActivePage := InternaUno;

  FStrumenti.AddLink(Azione, [EsternaDue, InternaDue]);
  Azione.OnExecute(Azione);

  Assert.AreSame(TObject(EsternaDue), TObject(ContenitoreEsterno.ActivePage));
  Assert.AreSame(TObject(InternaDue), TObject(ContenitoreInterno.ActivePage));
end;

procedure TTestzNavBarTools.ChangeActivePage_DueSchedeNelloStessoContenitore_VinceLUltima;
var
  Azione: TAction;
  Contenitore: TcxPageControl;
  PaginaUno, PaginaDue, PaginaTre: TcxTabSheet;
begin
  Azione := NuovaAzione('Elenco', 'Elenchi');
  Contenitore := NuovoContenitore;
  PaginaUno := NuovaPagina(Contenitore);
  PaginaDue := NuovaPagina(Contenitore);
  PaginaTre := NuovaPagina(Contenitore);
  Contenitore.ActivePage := PaginaUno;

  FStrumenti.AddLink(Azione, [PaginaDue, PaginaTre]);
  Azione.OnExecute(Azione);

  Assert.AreSame(TObject(PaginaTre), TObject(Contenitore.ActivePage));
end;

procedure TTestzNavBarTools.ChangeActivePage_MittenteNonAzione_NonCambiaNiente;
var
  Azione: TAction;
  Contenitore: TcxPageControl;
  PaginaUno, PaginaDue: TcxTabSheet;
begin
  Azione := NuovaAzione('Elenco', 'Elenchi');
  Contenitore := NuovoContenitore;
  PaginaUno := NuovaPagina(Contenitore);
  PaginaDue := NuovaPagina(Contenitore);
  Contenitore.ActivePage := PaginaUno;
  FStrumenti.AddLink(Azione, PaginaDue);

  // Il gestore e' quello assegnato da AddLink: lo si chiama con un mittente
  // che non e' un'azione
  Assert.WillNotRaiseAny(
    procedure
    begin
      Azione.OnExecute(FForm);
    end);

  Assert.AreSame(TObject(PaginaUno), TObject(Contenitore.ActivePage));
end;

procedure TTestzNavBarTools.TryNavBar_Falso_NonFaNienteERestaFalso;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FStrumenti.TryNavBar := False;
    end);

  Assert.IsFalse(FStrumenti.TryNavBar);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestActionTabLinks);
  TDUnitX.RegisterTestFixture(TTestzNavBarTools);

end.
