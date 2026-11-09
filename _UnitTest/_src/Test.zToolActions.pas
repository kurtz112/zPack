// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------
unit Test.zToolActions;

// Test DUnitX di zBase\zToolActions (specifica ZBASE-TLA, "Azioni degli
// strumenti.md").
//
// Si provano solo le parti che non richiedono finestre ne' barre a video:
//   - visibilita' e voci persistenti (ZBASE-TLA-001, 002);
//   - azioni dichiarate da codice, unione e ricarica (ZBASE-TLA-003);
//   - elenco in esecuzione: inserimento, ricerca, azione distrutta, voci
//     volatili e ricostruzione sospesa (ZBASE-TLA-004, 005, 006);
//   - BuildFromProps (ZBASE-TLA-007);
//   - descrizione testuale (ZBASE-TLA-009);
//   - risoluzione del proprietario delle azioni (ZBASE-TLA-010).
// CreateButtons (ZBASE-TLA-008) richiede un TdxBarManager con la barra a
// video e non e' provata. Le azioni sono TAction create senza lista.
//
// DIV-TLA-1, 2 e 3 sono corrette e provate. DIV-TLA-4 fotografa il
// comportamento attuale: va capovolta quando il codice viene corretto.

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.ActnList,
  Vcl.Controls,
  Vcl.ImgList,
  DUnitX.TestFramework,
  zToolActions;

type
  // Dà accesso al metodo protetto che sceglie la lista immagini
  TToolActionAccesso = class(TzToolAction);

  // Classi con campi pubblicati per provare DeclaringClass (RTTI sui campi)
  TFormBaseProva = class(TComponent)
  published
    Salva: TAction;
  end;

  TFormDerivataProva = class(TFormBaseProva)
  published
    Stampa: TAction;
  end;

  [TestFixture]
  TTestZToolActionsProps = class
  private
    function NuovaVoce(Elenco: TzToolActionsProps; const Nome: string; const DaCodice: Boolean): TzToolActionProps;
  public
    // ZBASE-TLA-001
    [Test]
    procedure Visibilita_Creazione_TuttoVisibile;
    // ZBASE-TLA-001
    [Test]
    procedure Visibilita_Assign_CopiaEntrambiGliInterruttori;
    // ZBASE-TLA-001
    [Test]
    procedure Visibilita_AssignDiAltroTipo_SollevaErrore;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_Creazione_ValoriPredefiniti;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_HideInCard_NascondeBarraEMenuNellaScheda;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_HideInView_NascondeBarraEMenuNellaVista;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_HideInPopups_NascondeSoloIlMenu;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_HideInToolbar_NascondeSoloLaBarra;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_MetodiConcatenabili_RestituisconoLaVoce;
    // ZBASE-TLA-002
    [Test]
    procedure Voce_Assign_CopiaICampiMaNonFromCode;
    // ZBASE-TLA-002
    [Test]
    procedure Elenco_Ordine_ResteQuelloDiInserimento;
    // ZBASE-TLA-003
    [Test]
    procedure Elenco_Find_NonDistingueMaiuscole;
    // ZBASE-TLA-003
    [Test]
    procedure Elenco_AssignDalDizionario_ConservaLeVociFromCode;
    // ZBASE-TLA-003
    [Test]
    procedure Elenco_AssignDalDizionario_StessoNomeVinceIlDizionario;
    // ZBASE-TLA-003
    [Test]
    procedure Elenco_MergeFromCode_AggiungeSoloINomiAssenti;
    // ZBASE-TLA-003
    [Test]
    procedure Elenco_MergeFromCode_OrigineNulla_RestituisceFalso;
    // ZBASE-TLA-003
    [Test]
    procedure Elenco_HasFromCodeEClearFromCode;
    // DIV-TLA-1 (corretta)
    [Test]
    procedure Divergenza_DIV_TLA_1_AssegnareToolbarProps_CopiaIlContenuto;
  end;

  [TestFixture]
  TTestZToolActionsEsecuzione = class
  private
    FRadice: TComponent;
    FSalva: TAction;
    FStampa: TAction;
    FElenco: TzToolActions;
    FConteggio: Integer;
    procedure ContaCambiamenti(Sender: TObject);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-TLA-004
    [Test]
    procedure Add_StessaAzioneDueVolte_NessunDoppione;
    // ZBASE-TLA-004
    [Test]
    procedure Add_AzioneAssegnata_FissaIlNomeDellaVoce;
    // ZBASE-TLA-004
    [Test]
    procedure Add_SenzaAzione_CreaUnaVoceVuota;
    // ZBASE-TLA-004
    [Test]
    procedure ContainsEFindByAction_CercanoPerAzione;
    // ZBASE-TLA-004
    [Test]
    procedure Exists_CercaPerNomeSenzaMaiuscole;
    // ZBASE-TLA-005
    [Test]
    procedure RemoveNotification_Azione_AzzeraAzioneEMantieneLaVoce;
    // ZBASE-TLA-005
    [Test]
    procedure RemoveNotification_ListaImmagini_AzzeraLaLista;
    // ZBASE-TLA-006
    [Test]
    procedure Add_Volatile_ImpostaIlFlag;
    // ZBASE-TLA-006
    [Test]
    procedure DestroyVolatiles_LasciaLeVociNonVolatili;
    // ZBASE-TLA-006
    [Test]
    procedure Ricostruzione_NonFaScattareOnChangeEPoiLoRipristina;
    // ZBASE-TLA-006
    [Test]
    procedure EndRebuild_SenzaBeginRebuild_NonFaNiente;
    // DIV-TLA-3
    [Test]
    procedure RicostruzioneAnnidata_ChiusaSoloDallUltimaEnd;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_Completa_CopiaIValoriNellOrdineDellElenco;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_VisibilitaCopiataPerValore;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_AzioneInesistente_VieneIgnorata;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_DueVolte_NessunDoppione;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_VoceNonVolatileEsistente_RestaNonVolatile;
    // Mantis #319
    [Test]
    procedure BuildFromProps_VoceCopiataDaAltroElenco_Sopravvive;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_EliminaLeVociVolatiliPrecedenti;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_ArgomentiNulli_NonFaNiente;
    // ZBASE-TLA-007
    [Test]
    procedure BuildFromProps_RipristinaOnChange;
    // ZBASE-TLA-009
    [Test]
    procedure Description_SenzaAzione_TestoFisso;
    // ZBASE-TLA-009
    [Test]
    procedure Description_CaptionEHint_SeparatiDaTrattino;
    // ZBASE-TLA-009
    [Test]
    procedure Description_SoloCaptionSenzaHint_NessunSuffissoDiTrattino;
    // ZBASE-TLA-009
    [Test]
    procedure Description_NascostaNellaVista_SoloCard;
    // ZBASE-TLA-009
    [Test]
    procedure Description_NascostaNellaScheda_SoloView;
    // ZBASE-TLA-009
    [Test]
    procedure GetImageList_ConListaAssegnata_RestituisceQuella;
    // ZBASE-TLA-009 e ZBASE-TLA-002
    [Test]
    procedure HideIn_SullAzioneInEsecuzione_ImpostaLeVisibilita;
    // DIV-TLA-2 (corretta)
    [Test]
    procedure Divergenza_DIV_TLA_2_Assign_CopiaIlNomeEIlFlagVolatile;
    // DIV-TLA-4
    [Test]
    procedure Divergenza_DIV_TLA_4_NascostaOvunque_DiceSoloCard;
  end;

  [TestFixture]
  TTestZActionOwnerResolver = class
  private
    FRadice: TComponent;
    FDue: TComponent;
    FUno: TComponent;
    FComponente: TComponent;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-TLA-010
    [Test]
    procedure ResolveOwner_NomeForzatoNellaCatena_RestituisceQuelComponente;
    // ZBASE-TLA-010
    [Test]
    procedure ResolveOwner_NomeForzatoVuoto_RestituisceIlProprietarioDiretto;
    // ZBASE-TLA-010
    [Test]
    procedure ResolveOwner_NomeForzatoInesistente_RipiegaSulProprietarioDiretto;
    // ZBASE-TLA-010
    [Test]
    procedure ResolveOwner_ComponenteNullo_RestituisceNil;
    // ZBASE-TLA-010
    [Test]
    procedure ResolveOwner_DentroUnaFinestraDiVista_RestituisceIlProprietarioDellaFinestra;
    // ZBASE-TLA-010
    [Test]
    procedure CandidateOwners_RaccoglieSoloIProprietariConAzioniNellOrdineDellaCatena;
    // ZBASE-TLA-010
    [Test]
    procedure CandidateOwners_FinestraOspitante_NessunDoppione;
    // ZBASE-TLA-010
    [Test]
    procedure CandidateOwners_NessunProprietarioConAzioni_ElencoVuoto;
    // ZBASE-TLA-010
    [Test]
    procedure ActionsOf_ElencaSoloLeAzioniPossedute;
    // ZBASE-TLA-010
    [Test]
    procedure ActionsOf_ProprietarioNullo_ElencoVuoto;
    // ZBASE-TLA-010
    [Test]
    procedure FindAction_AzioneEsistente_LaRestituisce;
    // ZBASE-TLA-010
    [Test]
    procedure FindAction_ComponenteCheNonEUnAzione_RestituisceNil;
    // ZBASE-TLA-010
    [Test]
    procedure FindAction_AzioneDiUnProprietarioPiuInAlto_NonSiTrova;
    // ZBASE-TLA-010
    [Test]
    procedure FindAction_ProprietarioNullo_RestituisceNil;
    // ZBASE-TLA-010
    [Test]
    procedure DeclaringClass_CampoDellaClasseBase_RestituisceLaBase;
    // ZBASE-TLA-010
    [Test]
    procedure DeclaringClass_CampoDellaClasseDerivata_RestituisceLaDerivata;
    // ZBASE-TLA-010
    [Test]
    procedure DeclaringClass_CampoInesistenteOProprietarioNullo_RestituisceNil;
  end;

implementation

uses
  zDbViewDlg;

// TTestZToolActionsProps

function TTestZToolActionsProps.NuovaVoce(Elenco: TzToolActionsProps; const Nome: string; const DaCodice: Boolean): TzToolActionProps;
begin
  Result := Elenco.Add;
  Result.Name := Nome;
  Result.FromCode := DaCodice;
end;

procedure TTestZToolActionsProps.Visibilita_Creazione_TuttoVisibile;
var
  Visibilita: TzTBCustomItemProps;
begin
  Visibilita := TzTBCustomItemProps.Create;
  try
    Assert.IsTrue(Visibilita.VisibleInView);
    Assert.IsTrue(Visibilita.VisibleInCard);
  finally
    Visibilita.Free;
  end;
end;

procedure TTestZToolActionsProps.Visibilita_Assign_CopiaEntrambiGliInterruttori;
var
  Origine, Destinazione: TzTBCustomItemProps;
begin
  Origine := TzTBCustomItemProps.Create;
  Destinazione := TzTBCustomItemProps.Create;
  try
    Origine.VisibleInView := False;
    Origine.VisibleInCard := True;

    Destinazione.Assign(Origine);

    Assert.IsFalse(Destinazione.VisibleInView);
    Assert.IsTrue(Destinazione.VisibleInCard);
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestZToolActionsProps.Visibilita_AssignDiAltroTipo_SollevaErrore;
var
  Visibilita: TzTBCustomItemProps;
  Altro: TComponent;
begin
  Visibilita := TzTBCustomItemProps.Create;
  Altro := TComponent.Create(nil);
  try
    Assert.WillRaise(
      procedure
      begin
        Visibilita.Assign(Altro);
      end,
      EConvertError);
  finally
    Altro.Free;
    Visibilita.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_Creazione_ValoriPredefiniti;
var
  Voce: TzToolActionProps;
begin
  Voce := TzToolActionProps.Create(nil);
  try
    Assert.IsFalse(Voce.BeginGroup);
    Assert.AreEqual(-1, Voce.Position);
    Assert.IsTrue(Voce.ShowCaption);
    Assert.AreEqual('', Voce.SubMenu);
    Assert.IsFalse(Voce.FromCode);
    Assert.IsTrue(Voce.PopupProps.VisibleInView);
    Assert.IsTrue(Voce.PopupProps.VisibleInCard);
    Assert.IsTrue(Voce.ToolbarProps.VisibleInView);
    Assert.IsTrue(Voce.ToolbarProps.VisibleInCard);
  finally
    Voce.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_HideInCard_NascondeBarraEMenuNellaScheda;
var
  Voce: TzToolActionProps;
begin
  Voce := TzToolActionProps.Create(nil);
  try
    Voce.HideInCard;

    Assert.IsFalse(Voce.ToolbarProps.VisibleInCard);
    Assert.IsFalse(Voce.PopupProps.VisibleInCard);
    Assert.IsTrue(Voce.ToolbarProps.VisibleInView);
    Assert.IsTrue(Voce.PopupProps.VisibleInView);
  finally
    Voce.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_HideInView_NascondeBarraEMenuNellaVista;
var
  Voce: TzToolActionProps;
begin
  Voce := TzToolActionProps.Create(nil);
  try
    Voce.HideInView;

    Assert.IsFalse(Voce.ToolbarProps.VisibleInView);
    Assert.IsFalse(Voce.PopupProps.VisibleInView);
    Assert.IsTrue(Voce.ToolbarProps.VisibleInCard);
    Assert.IsTrue(Voce.PopupProps.VisibleInCard);
  finally
    Voce.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_HideInPopups_NascondeSoloIlMenu;
var
  Voce: TzToolActionProps;
begin
  Voce := TzToolActionProps.Create(nil);
  try
    Voce.HideInPopups;

    Assert.IsFalse(Voce.PopupProps.VisibleInView);
    Assert.IsFalse(Voce.PopupProps.VisibleInCard);
    Assert.IsTrue(Voce.ToolbarProps.VisibleInView);
    Assert.IsTrue(Voce.ToolbarProps.VisibleInCard);
  finally
    Voce.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_HideInToolbar_NascondeSoloLaBarra;
var
  Voce: TzToolActionProps;
begin
  Voce := TzToolActionProps.Create(nil);
  try
    Voce.HideInToolbar;

    Assert.IsFalse(Voce.ToolbarProps.VisibleInView);
    Assert.IsFalse(Voce.ToolbarProps.VisibleInCard);
    Assert.IsTrue(Voce.PopupProps.VisibleInView);
    Assert.IsTrue(Voce.PopupProps.VisibleInCard);
  finally
    Voce.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_MetodiConcatenabili_RestituisconoLaVoce;
var
  Voce: TzToolActionProps;
begin
  Voce := TzToolActionProps.Create(nil);
  try
    Assert.AreSame(TObject(Voce), TObject(Voce.HideInCard.SetSubMenu('Stampe')));
    Assert.AreEqual('Stampe', Voce.SubMenu);

    Assert.AreSame(TObject(Voce), TObject(Voce.SetShowCaption(False)));
    Assert.IsFalse(Voce.ShowCaption);

    Assert.AreSame(TObject(Voce), TObject(Voce.HideInView));
    Assert.AreSame(TObject(Voce), TObject(Voce.HideInPopups));
    Assert.AreSame(TObject(Voce), TObject(Voce.HideInToolbar));
  finally
    Voce.Free;
  end;
end;

procedure TTestZToolActionsProps.Voce_Assign_CopiaICampiMaNonFromCode;
var
  Origine, Destinazione: TzToolActionProps;
begin
  Origine := TzToolActionProps.Create(nil);
  Destinazione := TzToolActionProps.Create(nil);
  try
    Origine.Name := 'Stampa';
    Origine.BeginGroup := True;
    Origine.Position := 3;
    Origine.ShowCaption := False;
    Origine.SubMenu := 'Stampe';
    Origine.ToolbarProps.VisibleInCard := False;
    Origine.PopupProps.VisibleInView := False;
    Origine.FromCode := True;

    Destinazione.Assign(Origine);

    Assert.AreEqual('Stampa', Destinazione.Name);
    Assert.IsTrue(Destinazione.BeginGroup);
    Assert.AreEqual(3, Destinazione.Position);
    Assert.IsFalse(Destinazione.ShowCaption);
    Assert.AreEqual('Stampe', Destinazione.SubMenu);
    Assert.IsFalse(Destinazione.ToolbarProps.VisibleInCard);
    Assert.IsFalse(Destinazione.PopupProps.VisibleInView);
    // FromCode non si copia con Assign
    Assert.IsFalse(Destinazione.FromCode);
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_Ordine_ResteQuelloDiInserimento;
var
  Elenco: TzToolActionsProps;
begin
  Elenco := TzToolActionsProps.Create;
  try
    NuovaVoce(Elenco, 'Zeta', False);
    NuovaVoce(Elenco, 'Alfa', False);
    NuovaVoce(Elenco, 'Beta', False);

    Assert.AreEqual(3, Elenco.Count);
    Assert.AreEqual('Zeta', Elenco[0].Name);
    Assert.AreEqual('Alfa', Elenco[1].Name);
    Assert.AreEqual('Beta', Elenco[2].Name);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_Find_NonDistingueMaiuscole;
var
  Elenco: TzToolActionsProps;
begin
  Elenco := TzToolActionsProps.Create;
  try
    NuovaVoce(Elenco, 'Salva', False);

    Assert.IsTrue(Elenco.Exists('SALVA'));
    Assert.AreSame(TObject(Elenco[0]), TObject(Elenco.Find('salva')));
    Assert.IsFalse(Elenco.Exists('Altra'));
    Assert.IsNull(Elenco.Find('Altra'));
  finally
    Elenco.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_AssignDalDizionario_ConservaLeVociFromCode;
var
  Corrente, Dizionario: TzToolActionsProps;
begin
  Corrente := TzToolActionsProps.Create;
  Dizionario := TzToolActionsProps.Create;
  try
    NuovaVoce(Corrente, 'Stampa', True);
    NuovaVoce(Dizionario, 'Salva', False);

    Corrente.Assign(Dizionario);

    Assert.AreEqual(2, Corrente.Count);
    // Prima quella del dizionario, poi quella di codice in coda
    Assert.AreEqual('Salva', Corrente[0].Name);
    Assert.IsFalse(Corrente[0].FromCode);
    Assert.AreEqual('Stampa', Corrente[1].Name);
    Assert.IsTrue(Corrente[1].FromCode);
  finally
    Dizionario.Free;
    Corrente.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_AssignDalDizionario_StessoNomeVinceIlDizionario;
var
  Corrente, Dizionario: TzToolActionsProps;
begin
  Corrente := TzToolActionsProps.Create;
  Dizionario := TzToolActionsProps.Create;
  try
    NuovaVoce(Corrente, 'Stampa', True).BeginGroup := True;
    NuovaVoce(Dizionario, 'Stampa', False).BeginGroup := False;

    Corrente.Assign(Dizionario);

    Assert.AreEqual(1, Corrente.Count);
    Assert.IsFalse(Corrente[0].BeginGroup);
    Assert.IsFalse(Corrente[0].FromCode);
  finally
    Dizionario.Free;
    Corrente.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_MergeFromCode_AggiungeSoloINomiAssenti;
var
  Corrente, Origine: TzToolActionsProps;
begin
  Corrente := TzToolActionsProps.Create;
  Origine := TzToolActionsProps.Create;
  try
    NuovaVoce(Corrente, 'Salva', False);
    NuovaVoce(Origine, 'Salva', False);
    NuovaVoce(Origine, 'Stampa', False);

    Assert.IsTrue(Corrente.MergeFromCode(Origine));
    Assert.AreEqual(2, Corrente.Count);
    Assert.IsFalse(Corrente.Find('Salva').FromCode);
    Assert.IsTrue(Corrente.Find('Stampa').FromCode);

    // Secondo giro: non c'e' piu' niente da aggiungere
    Assert.IsFalse(Corrente.MergeFromCode(Origine));
    Assert.AreEqual(2, Corrente.Count);
  finally
    Origine.Free;
    Corrente.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_MergeFromCode_OrigineNulla_RestituisceFalso;
var
  Corrente: TzToolActionsProps;
begin
  Corrente := TzToolActionsProps.Create;
  try
    Assert.IsFalse(Corrente.MergeFromCode(nil));
    Assert.AreEqual(0, Corrente.Count);
  finally
    Corrente.Free;
  end;
end;

procedure TTestZToolActionsProps.Elenco_HasFromCodeEClearFromCode;
var
  Elenco: TzToolActionsProps;
begin
  Elenco := TzToolActionsProps.Create;
  try
    NuovaVoce(Elenco, 'Salva', False);
    Assert.IsFalse(Elenco.HasFromCode);

    NuovaVoce(Elenco, 'Stampa', True);
    Assert.IsTrue(Elenco.HasFromCode);

    Elenco.ClearFromCode;
    Assert.IsFalse(Elenco.HasFromCode);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZToolActionsProps.Divergenza_DIV_TLA_1_AssegnareToolbarProps_CopiaIlContenuto;
var
  Voce: TzToolActionProps;
  Originale, Altro: TzTBCustomItemProps;
begin
  Voce := TzToolActionProps.Create(nil);
  Altro := TzTBCustomItemProps.Create;
  try
    Originale := Voce.ToolbarProps;
    Altro.VisibleInView := False;

    Voce.ToolbarProps := Altro;

    // DIV-TLA-1: il setter copia il contenuto e la voce libera i suoi oggetti
    Assert.AreSame(TObject(Originale), TObject(Voce.ToolbarProps), 'stesso oggetto della voce');
    Assert.AreNotSame(TObject(Altro), TObject(Voce.ToolbarProps), 'nessun alias');
    Assert.IsFalse(Voce.ToolbarProps.VisibleInView, 'contenuto copiato');

    Altro.VisibleInView := True;
    Assert.IsFalse(Voce.ToolbarProps.VisibleInView, 'modificare la sorgente non tocca la voce');
  finally
    Voce.Free;
    Altro.Free;
  end;
end;

// TTestZToolActionsEsecuzione

procedure TTestZToolActionsEsecuzione.Setup;
begin
  FRadice := TComponent.Create(nil);

  FSalva := TAction.Create(FRadice);
  FSalva.Name := 'Salva';
  FSalva.Caption := 'Salva';

  FStampa := TAction.Create(FRadice);
  FStampa.Name := 'Stampa';
  FStampa.Caption := 'Stampa';

  FElenco := TzToolActions.Create(FRadice);
  FConteggio := 0;
end;

procedure TTestZToolActionsEsecuzione.TearDown;
begin
  // Prima l'elenco, poi il proprietario che possiede le azioni
  FreeAndNil(FElenco);
  FreeAndNil(FRadice);
end;

procedure TTestZToolActionsEsecuzione.ContaCambiamenti(Sender: TObject);
begin
  Inc(FConteggio);
end;

procedure TTestZToolActionsEsecuzione.Add_StessaAzioneDueVolte_NessunDoppione;
var
  Prima, Seconda: TzToolAction;
begin
  Prima := FElenco.Add(FSalva, nil);
  Seconda := FElenco.Add(FSalva, nil);

  Assert.AreEqual(1, FElenco.Count);
  Assert.AreSame(TObject(Prima), TObject(Seconda));
end;

procedure TTestZToolActionsEsecuzione.Add_AzioneAssegnata_FissaIlNomeDellaVoce;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);

  Assert.AreEqual('Salva', Voce.Name);
  Assert.AreSame(TObject(FSalva), TObject(Voce.Action));
  Assert.IsFalse(Voce.Volatile);
end;

procedure TTestZToolActionsEsecuzione.Add_SenzaAzione_CreaUnaVoceVuota;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(TCustomImageList(nil));

  Assert.AreEqual(1, FElenco.Count);
  Assert.IsNull(Voce.Action);
end;

procedure TTestZToolActionsEsecuzione.ContainsEFindByAction_CercanoPerAzione;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);

  Assert.IsTrue(FElenco.Contains(FSalva));
  Assert.IsFalse(FElenco.Contains(FStampa));
  Assert.AreSame(TObject(Voce), TObject(FElenco.FindByAction(FSalva)));
  Assert.IsNull(FElenco.FindByAction(FStampa));
end;

procedure TTestZToolActionsEsecuzione.Exists_CercaPerNomeSenzaMaiuscole;
begin
  FElenco.Add(FSalva, nil);

  Assert.IsTrue(FElenco.Exists('SALVA'));
  Assert.IsTrue(FElenco.Exists('salva'));
  Assert.IsFalse(FElenco.Exists('Altra'));
end;

procedure TTestZToolActionsEsecuzione.RemoveNotification_Azione_AzzeraAzioneEMantieneLaVoce;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);

  FElenco.RemoveNotification(FSalva);

  Assert.AreEqual(1, FElenco.Count);
  Assert.IsNull(Voce.Action);
  Assert.AreEqual('Salva', Voce.Name);
end;

procedure TTestZToolActionsEsecuzione.RemoveNotification_ListaImmagini_AzzeraLaLista;
var
  Voce: TzToolAction;
  Lista: TImageList;
begin
  Lista := TImageList.Create(FRadice);
  Voce := FElenco.Add(FSalva, Lista);
  Assert.AreSame(TObject(Lista), TObject(Voce.ImageList));

  FElenco.RemoveNotification(Lista);

  Assert.IsNull(Voce.ImageList);
  Assert.AreSame(TObject(FSalva), TObject(Voce.Action));
end;

procedure TTestZToolActionsEsecuzione.Add_Volatile_ImpostaIlFlag;
begin
  Assert.IsTrue(FElenco.Add(FSalva, nil, True).Volatile);
  Assert.IsFalse(FElenco.Add(FStampa, nil, False).Volatile);
end;

procedure TTestZToolActionsEsecuzione.DestroyVolatiles_LasciaLeVociNonVolatili;
begin
  FElenco.Add(FSalva, nil, True);
  FElenco.Add(FStampa, nil, False);

  FElenco.DestroyVolatiles;

  Assert.AreEqual(1, FElenco.Count);
  Assert.AreEqual('Stampa', FElenco[0].Name);
end;

procedure TTestZToolActionsEsecuzione.Ricostruzione_NonFaScattareOnChangeEPoiLoRipristina;
begin
  FElenco.OnChange := ContaCambiamenti;

  FElenco.BeginRebuild;
  FElenco.Add(FSalva, nil);
  FElenco.Add(FStampa, nil);
  FElenco.EndRebuild;

  // Nessun avviso durante la ricostruzione ne' alla sua chiusura
  Assert.AreEqual(0, FConteggio);

  // Ripristinato: una modifica successiva fa scattare l'avviso
  FElenco.Delete(0);
  Assert.IsTrue(FConteggio > 0);
end;

procedure TTestZToolActionsEsecuzione.EndRebuild_SenzaBeginRebuild_NonFaNiente;
begin
  FElenco.OnChange := ContaCambiamenti;

  FElenco.EndRebuild;
  FElenco.Add(FSalva, nil);

  // L'avviso e' rimasto agganciato: EndRebuild da sola non lo ha toccato
  Assert.IsTrue(FConteggio > 0);
end;

procedure TTestZToolActionsEsecuzione.RicostruzioneAnnidata_ChiusaSoloDallUltimaEnd;
begin
  FElenco.OnChange := ContaCambiamenti;

  FElenco.BeginRebuild;
  FElenco.BeginRebuild;
  FElenco.EndRebuild;

  // DIV-TLA-3: la ricostruzione esterna e' ancora aperta, OnChange resta
  // sospeso e la modifica non lo fa scattare.
  FElenco.Add(FSalva, nil);
  Assert.AreEqual(0, FConteggio);

  FElenco.EndRebuild;
  Assert.IsTrue(Assigned(FElenco.OnChange), 'dopo l''ultima EndRebuild OnChange e'' ripristinato');
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_Completa_CopiaIValoriNellOrdineDellElenco;
var
  Props: TzToolActionsProps;
  Voce: TzToolActionProps;
begin
  Props := TzToolActionsProps.Create;
  try
    Voce := Props.Add;
    Voce.Name := 'Stampa';
    Voce.BeginGroup := True;
    Voce.SubMenu := 'Stampe';
    Voce.Position := 2;
    Voce.ShowCaption := False;
    Props.Add.Name := 'Salva';

    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);

    Assert.AreEqual(2, FElenco.Count);
    Assert.AreEqual('Stampa', FElenco[0].Name);
    Assert.AreEqual('Salva', FElenco[1].Name);
    Assert.IsTrue(FElenco[0].Volatile);
    Assert.IsTrue(FElenco[1].Volatile);
    Assert.IsTrue(FElenco[0].BeginGroup);
    Assert.AreEqual('Stampe', FElenco[0].SubMenu);
    Assert.AreEqual(2, FElenco[0].Position);
    Assert.IsFalse(FElenco[0].ShowCaption);
    // Valori predefiniti della seconda voce
    Assert.IsFalse(FElenco[1].BeginGroup);
    Assert.AreEqual(-1, FElenco[1].Position);
    Assert.IsTrue(FElenco[1].ShowCaption);
    Assert.AreEqual('', FElenco[1].SubMenu);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_VisibilitaCopiataPerValore;
var
  Props: TzToolActionsProps;
  Voce: TzToolActionProps;
begin
  Props := TzToolActionsProps.Create;
  try
    Voce := Props.Add;
    Voce.Name := 'Salva';
    Voce.ToolbarProps.VisibleInCard := False;
    Voce.PopupProps.VisibleInView := False;

    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);

    Assert.IsFalse(FElenco[0].ToolbarProps.VisibleInCard);
    Assert.IsFalse(FElenco[0].PopupProps.VisibleInView);

    // Una modifica successiva ai dati persistenti non tocca quelli in esecuzione
    Voce.ToolbarProps.VisibleInCard := True;
    Assert.IsFalse(FElenco[0].ToolbarProps.VisibleInCard);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_AzioneInesistente_VieneIgnorata;
var
  Props: TzToolActionsProps;
begin
  Props := TzToolActionsProps.Create;
  try
    Props.Add.Name := 'NonEsiste';
    Props.Add.Name := 'Salva';

    Assert.WillNotRaiseAny(
      procedure
      begin
        TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);
      end);

    Assert.AreEqual(1, FElenco.Count);
    Assert.AreEqual('Salva', FElenco[0].Name);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_DueVolte_NessunDoppione;
var
  Props: TzToolActionsProps;
begin
  Props := TzToolActionsProps.Create;
  try
    Props.Add.Name := 'Salva';
    Props.Add.Name := 'Stampa';

    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);
    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);

    Assert.AreEqual(2, FElenco.Count);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_VoceNonVolatileEsistente_RestaNonVolatile;
var
  Props: TzToolActionsProps;
  Voce: TzToolActionProps;
begin
  FElenco.Add(FSalva, nil, False);

  Props := TzToolActionsProps.Create;
  try
    Voce := Props.Add;
    Voce.Name := 'Salva';
    Voce.BeginGroup := True;

    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);

    // La voce aggiunta direttamente da codice viene riusata: riceve i valori
    // persistenti ma non diventa volatile
    Assert.AreEqual(1, FElenco.Count);
    Assert.IsFalse(FElenco[0].Volatile);
    Assert.IsTrue(FElenco[0].BeginGroup);
  finally
    Props.Free;
  end;
end;

// Mantis #319 - 2026-11-03: le azioni della vista copiate nella scheda con
// Assign restano dopo la ricostruzione della barra della scheda, che ha
// impostazioni proprie vuote
procedure TTestZToolActionsEsecuzione.BuildFromProps_VoceCopiataDaAltroElenco_Sopravvive;
var
  Vista: TzToolActions;
  PropsScheda: TzToolActionsProps;
begin
  Vista := TzToolActions.Create(FRadice);
  PropsScheda := TzToolActionsProps.Create;
  try
    // la voce della vista e' volatile, come quelle create da BuildFromProps
    Vista.Add(FSalva, nil, True);

    FElenco.Assign(Vista);
    TzActionBuilder.BuildFromProps(PropsScheda, FElenco, FRadice);

    Assert.AreEqual(1, FElenco.Count);
    Assert.AreSame(TObject(FSalva), TObject(FElenco[0].Action));
    Assert.AreEqual('Salva', FElenco[0].Name);
  finally
    PropsScheda.Free;
    Vista.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_EliminaLeVociVolatiliPrecedenti;
var
  Props: TzToolActionsProps;
begin
  FElenco.Add(FSalva, nil, True);

  Props := TzToolActionsProps.Create;
  try
    Props.Add.Name := 'Stampa';

    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);

    Assert.AreEqual(1, FElenco.Count);
    Assert.AreEqual('Stampa', FElenco[0].Name);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_ArgomentiNulli_NonFaNiente;
var
  Props: TzToolActionsProps;
begin
  FElenco.Add(FSalva, nil, True);

  Props := TzToolActionsProps.Create;
  try
    Props.Add.Name := 'Stampa';

    // Senza dati persistenti o senza elenco in esecuzione esce senza toccare niente
    TzActionBuilder.BuildFromProps(nil, FElenco, FRadice);
    Assert.AreEqual(1, FElenco.Count);
    Assert.AreEqual('Salva', FElenco[0].Name);

    Assert.WillNotRaiseAny(
      procedure
      begin
        TzActionBuilder.BuildFromProps(Props, nil, FRadice);
      end);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.BuildFromProps_RipristinaOnChange;
var
  Props: TzToolActionsProps;
begin
  Props := TzToolActionsProps.Create;
  try
    Props.Add.Name := 'Salva';
    FElenco.OnChange := ContaCambiamenti;

    TzActionBuilder.BuildFromProps(Props, FElenco, FRadice);
    Assert.AreEqual(0, FConteggio);

    // Dopo la costruzione le modifiche tornano a essere segnalate
    FElenco.Add(FStampa, nil);
    Assert.IsTrue(FConteggio > 0);
  finally
    Props.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.Description_SenzaAzione_TestoFisso;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(TCustomImageList(nil));

  Assert.AreEqual('(azione non assegnata)', Voce.Description);
end;

procedure TTestZToolActionsEsecuzione.Description_CaptionEHint_SeparatiDaTrattino;
var
  Voce: TzToolAction;
begin
  FSalva.Hint := 'Salva il record';
  Voce := FElenco.Add(FSalva, nil);

  Assert.AreEqual('Salva ' + #$2014 + ' Salva il record', Voce.Description);
end;

procedure TTestZToolActionsEsecuzione.Description_SoloCaptionSenzaHint_NessunSuffissoDiTrattino;
var
  Voce: TzToolAction;
begin
  FSalva.Hint := '';
  Voce := FElenco.Add(FSalva, nil);

  Assert.AreEqual('Salva', Voce.Description);
end;

procedure TTestZToolActionsEsecuzione.Description_NascostaNellaVista_SoloCard;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);
  Voce.ToolbarProps.VisibleInView := False;

  Assert.AreEqual('Salva [solo card]', Voce.Description);
end;

procedure TTestZToolActionsEsecuzione.Description_NascostaNellaScheda_SoloView;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);
  Voce.ToolbarProps.VisibleInCard := False;

  Assert.AreEqual('Salva [solo view]', Voce.Description);
end;

procedure TTestZToolActionsEsecuzione.GetImageList_ConListaAssegnata_RestituisceQuella;
var
  Voce: TzToolAction;
  Lista: TImageList;
begin
  Lista := TImageList.Create(FRadice);
  Voce := FElenco.Add(FSalva, Lista);

  // Con la lista assegnata non serve il globale Base (DIV-TLA-7)
  Assert.AreSame(TObject(Lista), TObject(TToolActionAccesso(Voce).GetImageList));
end;

procedure TTestZToolActionsEsecuzione.HideIn_SullAzioneInEsecuzione_ImpostaLeVisibilita;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);

  Voce.HideInCard;
  Assert.IsFalse(Voce.ToolbarProps.VisibleInCard);
  Assert.IsFalse(Voce.PopupProps.VisibleInCard);
  Assert.IsTrue(Voce.ToolbarProps.VisibleInView);

  Voce.HideInPopups;
  Assert.IsFalse(Voce.PopupProps.VisibleInView);
  Assert.IsTrue(Voce.ToolbarProps.VisibleInView);

  Voce.HideInToolbar;
  Assert.IsFalse(Voce.ToolbarProps.VisibleInView);

  Voce.ToolbarProps.VisibleInView := True;
  Voce.PopupProps.VisibleInView := True;
  Voce.HideInView;
  Assert.IsFalse(Voce.ToolbarProps.VisibleInView);
  Assert.IsFalse(Voce.PopupProps.VisibleInView);
end;

// Mantis #319 - 2026-11-03: Assign copia il nome ma non il flag volatile
procedure TTestZToolActionsEsecuzione.Divergenza_DIV_TLA_2_Assign_CopiaIlNomeEIlFlagVolatile;
var
  Copia: TzToolActions;
begin
  FElenco.Add(FSalva, nil, True);

  Copia := TzToolActions.Create(FRadice);
  try
    Copia.Assign(FElenco);

    Assert.AreEqual(1, Copia.Count);
    Assert.AreSame(TObject(FSalva), TObject(Copia[0].Action));
    // DIV-TLA-2: Assign copia il nome; Mantis #319: il flag volatile no
    Assert.AreEqual('Salva', Copia[0].Name);
    Assert.IsTrue(Copia.Exists('Salva'));
    Assert.IsFalse(Copia[0].Volatile);
  finally
    Copia.Free;
  end;
end;

procedure TTestZToolActionsEsecuzione.Divergenza_DIV_TLA_4_NascostaOvunque_DiceSoloCard;
var
  Voce: TzToolAction;
begin
  Voce := FElenco.Add(FSalva, nil);
  Voce.ToolbarProps.VisibleInView := False;
  Voce.ToolbarProps.VisibleInCard := False;

  // Oggi risponde «solo card» anche se la barra la nasconde in tutti e due i
  // contesti; quando il codice distingue il caso, questo test va capovolto
  Assert.AreEqual('Salva [solo card]', Voce.Description);
end;

// TTestZActionOwnerResolver

procedure TTestZActionOwnerResolver.Setup;
begin
  FRadice := TComponent.Create(nil);

  FDue := TComponent.Create(FRadice);
  FDue.Name := 'FormDue';

  FUno := TComponent.Create(FDue);
  FUno.Name := 'FormUno';

  // Il componente non ha nome: il confronto per nome avviene sui proprietari
  FComponente := TComponent.Create(FUno);
end;

procedure TTestZActionOwnerResolver.TearDown;
begin
  FreeAndNil(FRadice);
end;

procedure TTestZActionOwnerResolver.ResolveOwner_NomeForzatoNellaCatena_RestituisceQuelComponente;
begin
  Assert.AreSame(TObject(FDue), TObject(TzActionOwnerResolver.ResolveOwner(FComponente, 'FormDue')));
  Assert.AreSame(TObject(FUno), TObject(TzActionOwnerResolver.ResolveOwner(FComponente, 'formuno')));
end;

procedure TTestZActionOwnerResolver.ResolveOwner_NomeForzatoVuoto_RestituisceIlProprietarioDiretto;
begin
  Assert.AreSame(TObject(FUno), TObject(TzActionOwnerResolver.ResolveOwner(FComponente, '')));
end;

procedure TTestZActionOwnerResolver.ResolveOwner_NomeForzatoInesistente_RipiegaSulProprietarioDiretto;
begin
  Assert.AreSame(TObject(FUno), TObject(TzActionOwnerResolver.ResolveOwner(FComponente, 'NonEsiste')));
end;

procedure TTestZActionOwnerResolver.ResolveOwner_ComponenteNullo_RestituisceNil;
begin
  Assert.IsNull(TzActionOwnerResolver.ResolveOwner(nil, 'FormDue'));
  Assert.IsNull(TzActionOwnerResolver.ResolveOwner(nil, ''));
end;

procedure TTestZActionOwnerResolver.ResolveOwner_DentroUnaFinestraDiVista_RestituisceIlProprietarioDellaFinestra;
var
  Finestra: TzDbViewDlg;
  Dentro: TComponent;
begin
  Finestra := TzDbViewDlg.Create(FUno);
  Dentro := TComponent.Create(Finestra);

  // Le azioni di dominio stanno nella form che ha aperto la finestra, non nella
  // finestra stessa
  Assert.AreSame(TObject(FUno), TObject(TzActionOwnerResolver.ResolveOwner(Dentro, '')));
end;

procedure TTestZActionOwnerResolver.CandidateOwners_RaccoglieSoloIProprietariConAzioniNellOrdineDellaCatena;
var
  Risultato: TArray<TComponent>;
begin
  // FComponente e FUno senza azioni: nessun candidato
  TAction.Create(FDue).Name := 'AzioneDue';
  Risultato := TzActionOwnerResolver.CandidateOwners(FComponente);
  Assert.AreEqual(1, Integer(Length(Risultato)));
  Assert.AreSame(TObject(FDue), TObject(Risultato[0]));

  // Ora anche FUno ha un'azione: prima il piu' vicino al componente
  TAction.Create(FUno).Name := 'AzioneUno';
  Risultato := TzActionOwnerResolver.CandidateOwners(FComponente);
  Assert.AreEqual(2, Integer(Length(Risultato)));
  Assert.AreSame(TObject(FUno), TObject(Risultato[0]));
  Assert.AreSame(TObject(FDue), TObject(Risultato[1]));
end;

procedure TTestZActionOwnerResolver.CandidateOwners_FinestraOspitante_NessunDoppione;
var
  Finestra: TzDbViewDlg;
  Dentro: TComponent;
  Risultato: TArray<TComponent>;
begin
  TAction.Create(FUno).Name := 'AzioneUno';
  Finestra := TzDbViewDlg.Create(FUno);
  Dentro := TComponent.Create(Finestra);

  // La catena (componente, finestra, FUno, FDue) incontra FUno una volta; il
  // proprietario della finestra ospitante e' lo stesso FUno e non si ripete
  Risultato := TzActionOwnerResolver.CandidateOwners(Dentro);

  Assert.AreEqual(1, Integer(Length(Risultato)));
  Assert.AreSame(TObject(FUno), TObject(Risultato[0]));
end;

procedure TTestZActionOwnerResolver.CandidateOwners_NessunProprietarioConAzioni_ElencoVuoto;
begin
  Assert.AreEqual(0, Integer(Length(TzActionOwnerResolver.CandidateOwners(FComponente))));
  Assert.AreEqual(0, Integer(Length(TzActionOwnerResolver.CandidateOwners(nil))));
end;

procedure TTestZActionOwnerResolver.ActionsOf_ElencaSoloLeAzioniPossedute;
var
  Prima, Seconda: TAction;
  Risultato: TArray<TCustomAction>;
begin
  Prima := TAction.Create(FUno);
  Prima.Name := 'Prima';
  TComponent.Create(FUno).Name := 'NonAzione';
  Seconda := TAction.Create(FUno);
  Seconda.Name := 'Seconda';
  // Un'azione di un altro proprietario non conta
  TAction.Create(FDue).Name := 'AzioneDue';

  Risultato := TzActionOwnerResolver.ActionsOf(FUno);

  Assert.AreEqual(2, Integer(Length(Risultato)));
  Assert.AreSame(TObject(Prima), TObject(Risultato[0]));
  Assert.AreSame(TObject(Seconda), TObject(Risultato[1]));
end;

procedure TTestZActionOwnerResolver.ActionsOf_ProprietarioNullo_ElencoVuoto;
begin
  Assert.AreEqual(0, Integer(Length(TzActionOwnerResolver.ActionsOf(nil))));
end;

procedure TTestZActionOwnerResolver.FindAction_AzioneEsistente_LaRestituisce;
var
  Azione: TAction;
begin
  Azione := TAction.Create(FUno);
  Azione.Name := 'Salva';

  Assert.AreSame(TObject(Azione), TObject(TzActionOwnerResolver.FindAction(FUno, 'Salva')));
end;

procedure TTestZActionOwnerResolver.FindAction_ComponenteCheNonEUnAzione_RestituisceNil;
begin
  TComponent.Create(FUno).Name := 'Salva';

  Assert.IsNull(TzActionOwnerResolver.FindAction(FUno, 'Salva'));
  Assert.IsNull(TzActionOwnerResolver.FindAction(FUno, 'NonEsiste'));
end;

procedure TTestZActionOwnerResolver.FindAction_AzioneDiUnProprietarioPiuInAlto_NonSiTrova;
begin
  TAction.Create(FDue).Name := 'Salva';

  // FindComponent guarda solo i componenti posseduti direttamente
  Assert.IsNull(TzActionOwnerResolver.FindAction(FUno, 'Salva'));
  Assert.IsNotNull(TzActionOwnerResolver.FindAction(FDue, 'Salva'));
end;

procedure TTestZActionOwnerResolver.FindAction_ProprietarioNullo_RestituisceNil;
begin
  Assert.IsNull(TzActionOwnerResolver.FindAction(nil, 'Salva'));
end;

procedure TTestZActionOwnerResolver.DeclaringClass_CampoDellaClasseBase_RestituisceLaBase;
var
  Derivata: TFormDerivataProva;
begin
  Derivata := TFormDerivataProva.Create(FRadice);

  Assert.IsTrue(TzActionOwnerResolver.DeclaringClass(Derivata, 'Salva') = TFormBaseProva);
end;

procedure TTestZActionOwnerResolver.DeclaringClass_CampoDellaClasseDerivata_RestituisceLaDerivata;
var
  Derivata: TFormDerivataProva;
begin
  Derivata := TFormDerivataProva.Create(FRadice);

  Assert.IsTrue(TzActionOwnerResolver.DeclaringClass(Derivata, 'Stampa') = TFormDerivataProva);
  // Il confronto sul nome non distingue maiuscole e minuscole
  Assert.IsTrue(TzActionOwnerResolver.DeclaringClass(Derivata, 'STAMPA') = TFormDerivataProva);
end;

procedure TTestZActionOwnerResolver.DeclaringClass_CampoInesistenteOProprietarioNullo_RestituisceNil;
var
  Derivata: TFormDerivataProva;
begin
  Derivata := TFormDerivataProva.Create(FRadice);

  Assert.IsTrue(TzActionOwnerResolver.DeclaringClass(Derivata, 'CampoCheNonEsiste') = nil);
  Assert.IsTrue(TzActionOwnerResolver.DeclaringClass(nil, 'Salva') = nil);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZToolActionsProps);
  TDUnitX.RegisterTestFixture(TTestZToolActionsEsecuzione);
  TDUnitX.RegisterTestFixture(TTestZActionOwnerResolver);

end.
