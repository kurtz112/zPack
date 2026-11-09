// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.dbMaster;

// Test DUnitX per zCommon\dbMaster.pas (specifica ZCOMMON-DBM, "Raccolta dei
// dataset.md"). BOZZA scritta senza poterla compilare ne' eseguire.
//
// I dataset sono TFDMemTable (nessun database, nessuna finestra). SmartInspect
// (SiMain) senza connessione e' innocuo; Application.ProcessMessages e
// OutputDebugString non danno problemi in un programma console. Non si provoca
// mai ShowMessage: nessun dataset di prova solleva un errore in apertura.
//
// Prove con prefisso Divergenza_: descrivono il comportamento CORRETTO e sono
// attese ROSSE finche' il codice non viene corretto. La sessione principale le
// capovolge (le fa affermare il comportamento attuale) o le rimuove prima del
// sigillo:
// - Divergenza_BeforePost_SenderDelComponenteESelf        (DIV-DBM-1)
// - Divergenza_BeforeCancel_SenderDelComponenteESelf      (DIV-DBM-1)
// - Divergenza_AfterRefresh_SenderDelComponenteESelf      (DIV-DBM-2)
// - Divergenza_Assign_NonSollevaEccezioni                 (DIV-DBM-3)
// - Divergenza_Assign_CopiaDisplayName                    (DIV-DBM-3)
// - Divergenza_AssegnaCollezione_CopiaLeVoci              (DIV-DBM-3)
// - Divergenza_Notifica_StessoDataSetInDueVoci_RimosseEntrambe (DIV-DBM-9)
// - Divergenza_OpenCount_SenzaVoci_Zero                   (DIV-DBM-10)
// - Divergenza_OpenCount_ContaLeSoleVociDaAprire          (DIV-DBM-10)
//
// Le altre prove sono attese VERDI. Alcune fotografano un comportamento che la
// specifica elenca fra le divergenze ma che non e' un errore da correggere con
// certezza: IsModified_ErroreInUpdateRecord_Ingoiato (DIV-DBM-6),
// CloseAll_ErroreNelSalvataggio_InterrompeIlGiroELasciaAperteLeAltre
// (DIV-DBM-7), AddDataSet_NomeEsistente_RestituisceVoceEsistenteSenzaCambiareDataSet
// (DIV-DBM-9), Assign_CopiaLeImpostazioniPrimaDiSollevare (DIV-DBM-3).
//
// OpenAll_DataSetLento_ChiamaOnSlowDataSet dura piu' di quattro secondi (soglia
// del codice: Elapsed.Seconds > 3): e' l'unica prova lenta.
//
// Restano senza prova: il messaggio ShowMessage di OpenAll quando un dataset non
// si apre (DIV-DBM-4, apre una finestra bloccante), le soglie oltre il minuto
// (DIV-DBM-5, servirebbe un dataset che si apre in piu' di 60 secondi),
// TdbMaster.OnClose del componente mai letta (DIV-DBM-8, non c'e' un
// comportamento atteso definito) e l'editor di componente dbMasterCompEd.
//
// RISCHI NOTI della bozza (da verificare alla prima compilazione):
// - i dataset di prova si creano con FieldDefs + CreateDataSet e, se devono
//   restare chiusi, con un Close subito dopo; si da' per scontato che la
//   successiva Open (fatta da OpenAll) riusi i FieldDefs senza dati;
// - TDatasetProva sovrascrive InternalRefresh (protetto e virtuale in TDataSet)
//   per contare i Refresh senza toccare una sorgente dati che non esiste;
// - SetDesigning e Loaded sono protetti in TComponent/TdbMaster: la classe
//   TdbMasterProva li espone.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TimeSpan,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.ExprFuncs,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Phys,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  DUnitX.TestFramework,
  dbMaster;

type
  // Dataset in memoria che conta i Refresh invece di rileggerli da una sorgente
  TDataSetProva = class(TFDMemTable)
  protected
    procedure InternalRefresh; override;
  public
    ConteggioRefresh: Integer;
  end;

  // Espone i metodi protetti usati dalle prove
  TdbMasterProva = class(TdbMaster)
  public
    procedure CaricaOra;
    procedure ImpostaInProgetto(Valore: Boolean);
    procedure NotificaProva(Componente: TComponent; Operazione: TOperation);
  end;

  [TestFixture]
  TTestdbMaster = class
  private
    FMaster: TdbMasterProva;
    FDataSetCreati: TObjectList<TDataSetProva>;
    FRegistro: TStringList;
    FSender: TDictionary<string, TObject>;
    FPostEseguiti: Integer;
    FAnnullamenti: Integer;
    FLentoChiamate: Integer;
    FLentoNome: string;
    FLentoDataSet: TDataSet;
    FLentoSecondi: Double;

    // creazione dei dataset e dei record di prova
    function CreaDataSet(Aperto: Boolean): TDataSetProva;
    function AggiungiDataSet(const Nome: string; Aperto: Boolean): TDataSetProva;
    procedure ConRecord(Dati: TDataSetProva);
    procedure Inserisci(Dati: TDataSetProva);
    function TestoRegistro: string;
    procedure CollegaEventiComponente;
    procedure CollegaEventiVoce(const Nome: string);

    // registrazione degli eventi
    procedure Registra(const Chiave: string; Sender: TObject);
    procedure RegistraVoce(const Evento: string; Sender: TObject);
    procedure ComponenteBeforeOpen(Sender: TObject);
    procedure ComponenteAfterOpen(Sender: TObject);
    procedure ComponenteBeforeClose(Sender: TObject);
    procedure ComponenteAfterClose(Sender: TObject);
    procedure ComponenteBeforeCancel(Sender: TObject);
    procedure ComponenteAfterCancel(Sender: TObject);
    procedure ComponenteBeforePost(Sender: TObject);
    procedure ComponenteAfterPost(Sender: TObject);
    procedure ComponenteBeforeRefresh(Sender: TObject);
    procedure ComponenteAfterRefresh(Sender: TObject);
    procedure VoceBeforeOpen(Sender: TObject);
    procedure VoceAfterOpen(Sender: TObject);
    procedure VoceBeforeClose(Sender: TObject);
    procedure VoceAfterClose(Sender: TObject);
    procedure VoceBeforeCancel(Sender: TObject);
    procedure VoceAfterCancel(Sender: TObject);
    procedure VoceBeforePost(Sender: TObject);
    procedure VoceAfterPost(Sender: TObject);
    procedure VoceBeforeRefresh(Sender: TObject);
    procedure VoceAfterRefresh(Sender: TObject);
    procedure Avanzamento(Sender: TObject; ItemName: string; ItemNo: Integer);
    procedure DataSetLento(Sender: TObject; ItemName: string; DataSet: TDataSet; Durata: TTimeSpan);

    // gestori degli eventi dei dataset e delle sorgenti dati
    procedure ContaPost(DataSet: TDataSet);
    procedure ContaAnnullamento(DataSet: TDataSet);
    procedure SollevaInPost(DataSet: TDataSet);
    procedure RitardaApertura(DataSet: TDataSet);
    procedure SollevaInAggiornamento(Sender: TObject);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZCOMMON-DBM-001
    [Test]
    procedure Master_ValoriPredefiniti;
    // ZCOMMON-DBM-001
    [Test]
    procedure Voce_ValoriPredefiniti;
    // ZCOMMON-DBM-001 (DIV-DBM-3)
    [Test]
    procedure Assign_CopiaLeImpostazioniPrimaDiSollevare;
    // ZCOMMON-DBM-001 (DIV-DBM-3, corretta)
    [Test]
    procedure Divergenza_Assign_NonSollevaEccezioni;
    // ZCOMMON-DBM-001 (DIV-DBM-3, corretta)
    [Test]
    procedure Divergenza_Assign_CopiaDisplayName;
    // ZCOMMON-DBM-001 (DIV-DBM-3, corretta)
    [Test]
    procedure Divergenza_AssegnaCollezione_CopiaLeVoci;

    // ZCOMMON-DBM-002
    [Test]
    procedure AddDataSet_NuovoNome_AggiungeLaVoce;
    // ZCOMMON-DBM-002
    [Test]
    procedure AddDataSet_DataSetNil_AggiungeVoceSenzaDataSet;
    // ZCOMMON-DBM-002 (DIV-DBM-9)
    [Test]
    procedure AddDataSet_NomeEsistente_RestituisceVoceEsistenteSenzaCambiareDataSet;
    // ZCOMMON-DBM-002
    [Test]
    procedure FindDataSetItem_SenzaDistinzioneMaiuscole;
    // ZCOMMON-DBM-002
    [Test]
    procedure FindDataSetItem_NomeAssente_Nil;

    // ZCOMMON-DBM-003, ZCOMMON-DBM-014
    [Test]
    procedure OpenAll_ApreSoloLeVociIncluseConDataSet;
    // ZCOMMON-DBM-003
    [Test]
    procedure OpenAll_SenzaVoci_ScattanoSoloGliEventiDelComponente;
    // ZCOMMON-DBM-003, ZCOMMON-DBM-013
    [Test]
    procedure OpenAll_OrdineDegliEventi;
    // ZCOMMON-DBM-003
    [Test]
    procedure OpenAll_DataSetGiaAperto_EventiScattanoERestaAperto;
    // ZCOMMON-DBM-004
    [Test]
    procedure OpenAll_Avanzamento_UnaChiamataPerVoceConIndiceDaZero;
    // ZCOMMON-DBM-004
    [Test]
    procedure OpenAll_DataSetVeloce_NonSegnalaLentezza;
    // ZCOMMON-DBM-004 (prova lenta: piu' di quattro secondi)
    [Test]
    procedure OpenAll_DataSetLento_ChiamaOnSlowDataSet;

    // ZCOMMON-DBM-005
    [Test]
    procedure CloseAll_ChiudeSoloVociIncluseEAttive;
    // ZCOMMON-DBM-005, ZCOMMON-DBM-013
    [Test]
    procedure CloseAll_OrdineDegliEventi;
    // ZCOMMON-DBM-005
    [Test]
    procedure CloseAll_ModificaInSospesoOcPost_Salva;
    // ZCOMMON-DBM-005
    [Test]
    procedure CloseAll_ModificaInSospesoOcCancel_Annulla;
    // ZCOMMON-DBM-005 (DIV-DBM-7)
    [Test]
    procedure CloseAll_ErroreNelSalvataggio_InterrompeIlGiroELasciaAperteLeAltre;

    // ZCOMMON-DBM-006
    [Test]
    procedure PostAll_SalvaSoloVociInModificaEIncluse;
    // ZCOMMON-DBM-006, ZCOMMON-DBM-013
    [Test]
    procedure PostAll_OrdineDegliEventi;

    // ZCOMMON-DBM-007
    [Test]
    procedure CancelAll_AnnullaSoloVociInModificaEIncluse;
    // ZCOMMON-DBM-007, ZCOMMON-DBM-013
    [Test]
    procedure CancelAll_OrdineDegliEventi;

    // ZCOMMON-DBM-008
    [Test]
    procedure RefreshAll_AggiornaSoloVociAttiveEIncluse;
    // ZCOMMON-DBM-008, ZCOMMON-DBM-013
    [Test]
    procedure RefreshAll_OrdineDegliEventi;

    // ZCOMMON-DBM-009
    [Test]
    procedure IsModified_SenzaVoci_Falso;
    // ZCOMMON-DBM-009
    [Test]
    procedure IsModified_InserimentoAppenaAperto_Vero;
    // ZCOMMON-DBM-009
    [Test]
    procedure IsModified_ModificaSenzaCambiamenti_Falso;
    // ZCOMMON-DBM-009
    [Test]
    procedure IsModified_CampoCambiato_Vero;
    // ZCOMMON-DBM-009
    [Test]
    procedure IsModified_DopoIlSalvataggio_Falso;
    // ZCOMMON-DBM-009
    [Test]
    procedure IsModified_DataSetChiusoOSenzaDataSet_Ignorato;
    // ZCOMMON-DBM-009 (DIV-DBM-6)
    [Test]
    procedure IsModified_ErroreInUpdateRecord_Ingoiato;

    // ZCOMMON-DBM-010 (DIV-DBM-10, attesa rossa)
    [Test]
    [Ignore('R-214: DIV-DBM-10, togliere quando OpenCount e corretto')]
    procedure Divergenza_OpenCount_SenzaVoci_Zero;
    // ZCOMMON-DBM-010 (DIV-DBM-10, attesa rossa)
    [Test]
    [Ignore('R-214: DIV-DBM-10, togliere quando OpenCount e corretto')]
    procedure Divergenza_OpenCount_ContaLeSoleVociDaAprire;

    // ZCOMMON-DBM-011
    [Test]
    procedure Notifica_DataSetDistrutto_VoceRimossa;
    // ZCOMMON-DBM-011
    [Test]
    procedure Notifica_DataSetDistruttoConProprietarioComune_VoceRimossa;
    // ZCOMMON-DBM-011
    [Test]
    procedure Notifica_VoceScollegata_NonPiuRimossa;
    // ZCOMMON-DBM-011
    [Test]
    procedure Notifica_DataSetSostituito_NotificaSoloIlNuovo;
    // ZCOMMON-DBM-011
    [Test]
    procedure Notifica_ComponenteNonRegistrato_Ignorato;
    // ZCOMMON-DBM-011
    [Test]
    procedure Notifica_Inserimento_Ignorato;
    // ZCOMMON-DBM-011 (DIV-DBM-9, attesa rossa)
    [Test]
    [Ignore('R-214: DIV-DBM-9, togliere quando Notification e corretta')]
    procedure Divergenza_Notifica_StessoDataSetInDueVoci_RimosseEntrambe;

    // ZCOMMON-DBM-012
    [Test]
    procedure Loaded_AutoOpenVero_ApreIDataSet;
    // ZCOMMON-DBM-012
    [Test]
    procedure Loaded_AutoOpenFalso_NonApre;
    // ZCOMMON-DBM-012
    [Test]
    procedure Loaded_InProgettoSenzaOpenInDesigner_NonApre;
    // ZCOMMON-DBM-012
    [Test]
    procedure OpenInDesigner_InProgetto_ApreEChiude;
    // ZCOMMON-DBM-012
    [Test]
    procedure OpenInDesigner_InEsecuzione_SoloMemorizza;
    // ZCOMMON-DBM-012
    [Test]
    procedure Distruzione_AutoCloseVero_ChiudeIDataSet;
    // ZCOMMON-DBM-012
    [Test]
    procedure Distruzione_AutoCloseFalso_LasciaApertiIDataSet;
    // ZCOMMON-DBM-012
    [Test]
    procedure Distruzione_InProgetto_LasciaApertiIDataSet;

    // ZCOMMON-DBM-013
    [Test]
    procedure Eventi_SenderDiComponenteEVoce;
    // ZCOMMON-DBM-013 (DIV-DBM-1, attesa rossa)
    [Test]
    [Ignore('R-214: DIV-DBM-1, togliere quando il Sender e corretto')]
    procedure Divergenza_BeforePost_SenderDelComponenteESelf;
    // ZCOMMON-DBM-013 (DIV-DBM-1, attesa rossa)
    [Test]
    [Ignore('R-214: DIV-DBM-1, togliere quando il Sender e corretto')]
    procedure Divergenza_BeforeCancel_SenderDelComponenteESelf;
    // ZCOMMON-DBM-013 (DIV-DBM-2, attesa rossa)
    [Test]
    [Ignore('R-214: DIV-DBM-2, togliere quando il Sender e corretto')]
    procedure Divergenza_AfterRefresh_SenderDelComponenteESelf;
  end;

implementation

const
  EventiVoce: array [0 .. 9] of string = ('BeforeOpen', 'AfterOpen', 'BeforeClose', 'AfterClose', 'BeforeCancel', 'AfterCancel', 'BeforePost', 'AfterPost',
    'BeforeRefresh', 'AfterRefresh');

{ TDataSetProva }

procedure TDataSetProva.InternalRefresh;
begin
  Inc(ConteggioRefresh);
end;

{ TdbMasterProva }

procedure TdbMasterProva.CaricaOra;
begin
  Loaded;
end;

procedure TdbMasterProva.ImpostaInProgetto(Valore: Boolean);
begin
  SetDesigning(Valore);
end;

procedure TdbMasterProva.NotificaProva(Componente: TComponent; Operazione: TOperation);
begin
  Notification(Componente, Operazione);
end;

{ TTestdbMaster }

procedure TTestdbMaster.Setup;
begin
  FDataSetCreati := TObjectList<TDataSetProva>.Create(True);
  FRegistro := TStringList.Create;
  FSender := TDictionary<string, TObject>.Create;
  FPostEseguiti := 0;
  FAnnullamenti := 0;
  FLentoChiamate := 0;
  FLentoNome := '';
  FLentoDataSet := nil;
  FLentoSecondi := 0;

  FMaster := TdbMasterProva.Create(nil);
  // la distruzione non deve chiudere nulla: i dataset si liberano dopo
  FMaster.AutoClose := False;
end;

procedure TTestdbMaster.TearDown;
begin
  // prima il componente, poi i dataset che esso osserva
  FreeAndNil(FMaster);
  FreeAndNil(FDataSetCreati);
  FreeAndNil(FSender);
  FreeAndNil(FRegistro);
end;

function TTestdbMaster.CreaDataSet(Aperto: Boolean): TDataSetProva;
begin
  Result := TDataSetProva.Create(nil);
  FDataSetCreati.Add(Result);
  Result.FieldDefs.Add('Valore', ftString, 20);
  Result.CreateDataSet;
  if not Aperto then
    Result.Close;
end;

function TTestdbMaster.AggiungiDataSet(const Nome: string; Aperto: Boolean): TDataSetProva;
begin
  Result := CreaDataSet(Aperto);
  FMaster.AddDataSet(Nome, Result);
end;

procedure TTestdbMaster.ConRecord(Dati: TDataSetProva);
begin
  Dati.Append;
  Dati.FieldByName('Valore').AsString := 'uno';
  Dati.Post;
end;

procedure TTestdbMaster.Inserisci(Dati: TDataSetProva);
begin
  // lascia il dataset in dsInsert con un campo cambiato
  Dati.Append;
  Dati.FieldByName('Valore').AsString := 'nuovo';
end;

function TTestdbMaster.TestoRegistro: string;
var
  Riga: string;
begin
  Result := '';
  for Riga in FRegistro do
    if Result = '' then
      Result := Riga
    else
      Result := Result + '|' + Riga;
end;

procedure TTestdbMaster.CollegaEventiComponente;
begin
  FMaster.BeforeOpen := ComponenteBeforeOpen;
  FMaster.AfterOpen := ComponenteAfterOpen;
  FMaster.BeforeClose := ComponenteBeforeClose;
  FMaster.AfterClose := ComponenteAfterClose;
  FMaster.BeforeCancel := ComponenteBeforeCancel;
  FMaster.AfterCancel := ComponenteAfterCancel;
  FMaster.BeforePost := ComponenteBeforePost;
  FMaster.AfterPost := ComponenteAfterPost;
  FMaster.BeforeRefresh := ComponenteBeforeRefresh;
  FMaster.AfterRefresh := ComponenteAfterRefresh;
end;

procedure TTestdbMaster.CollegaEventiVoce(const Nome: string);
var
  Voce: TDataSetItem;
begin
  Voce := FMaster.FindDataSetItem(Nome);
  Voce.BeforeOpen := VoceBeforeOpen;
  Voce.AfterOpen := VoceAfterOpen;
  Voce.BeforeClose := VoceBeforeClose;
  Voce.AfterClose := VoceAfterClose;
  Voce.BeforeCancel := VoceBeforeCancel;
  Voce.AfterCancel := VoceAfterCancel;
  Voce.BeforePost := VoceBeforePost;
  Voce.AfterPost := VoceAfterPost;
  Voce.BeforeRefresh := VoceBeforeRefresh;
  Voce.AfterRefresh := VoceAfterRefresh;
end;

procedure TTestdbMaster.Registra(const Chiave: string; Sender: TObject);
begin
  // il Sender si conserva soltanto: per alcuni eventi del componente puo'
  // essere un valore non definito (DIV-DBM-1) e non va mai dereferenziato
  FRegistro.Add(Chiave);
  FSender.AddOrSetValue(Chiave, Sender);
end;

procedure TTestdbMaster.RegistraVoce(const Evento: string; Sender: TObject);
begin
  // Sender e' sempre una voce valida negli eventi di voce
  Registra('V.' + Evento + ':' + (Sender as TDataSetItem).DisplayName, Sender);
end;

procedure TTestdbMaster.ComponenteBeforeOpen(Sender: TObject);
begin
  Registra('C.BeforeOpen', Sender);
end;

procedure TTestdbMaster.ComponenteAfterOpen(Sender: TObject);
begin
  Registra('C.AfterOpen', Sender);
end;

procedure TTestdbMaster.ComponenteBeforeClose(Sender: TObject);
begin
  Registra('C.BeforeClose', Sender);
end;

procedure TTestdbMaster.ComponenteAfterClose(Sender: TObject);
begin
  Registra('C.AfterClose', Sender);
end;

procedure TTestdbMaster.ComponenteBeforeCancel(Sender: TObject);
begin
  Registra('C.BeforeCancel', Sender);
end;

procedure TTestdbMaster.ComponenteAfterCancel(Sender: TObject);
begin
  Registra('C.AfterCancel', Sender);
end;

procedure TTestdbMaster.ComponenteBeforePost(Sender: TObject);
begin
  Registra('C.BeforePost', Sender);
end;

procedure TTestdbMaster.ComponenteAfterPost(Sender: TObject);
begin
  Registra('C.AfterPost', Sender);
end;

procedure TTestdbMaster.ComponenteBeforeRefresh(Sender: TObject);
begin
  Registra('C.BeforeRefresh', Sender);
end;

procedure TTestdbMaster.ComponenteAfterRefresh(Sender: TObject);
begin
  Registra('C.AfterRefresh', Sender);
end;

procedure TTestdbMaster.VoceBeforeOpen(Sender: TObject);
begin
  RegistraVoce('BeforeOpen', Sender);
end;

procedure TTestdbMaster.VoceAfterOpen(Sender: TObject);
begin
  RegistraVoce('AfterOpen', Sender);
end;

procedure TTestdbMaster.VoceBeforeClose(Sender: TObject);
begin
  RegistraVoce('BeforeClose', Sender);
end;

procedure TTestdbMaster.VoceAfterClose(Sender: TObject);
begin
  RegistraVoce('AfterClose', Sender);
end;

procedure TTestdbMaster.VoceBeforeCancel(Sender: TObject);
begin
  RegistraVoce('BeforeCancel', Sender);
end;

procedure TTestdbMaster.VoceAfterCancel(Sender: TObject);
begin
  RegistraVoce('AfterCancel', Sender);
end;

procedure TTestdbMaster.VoceBeforePost(Sender: TObject);
begin
  RegistraVoce('BeforePost', Sender);
end;

procedure TTestdbMaster.VoceAfterPost(Sender: TObject);
begin
  RegistraVoce('AfterPost', Sender);
end;

procedure TTestdbMaster.VoceBeforeRefresh(Sender: TObject);
begin
  RegistraVoce('BeforeRefresh', Sender);
end;

procedure TTestdbMaster.VoceAfterRefresh(Sender: TObject);
begin
  RegistraVoce('AfterRefresh', Sender);
end;

procedure TTestdbMaster.Avanzamento(Sender: TObject; ItemName: string; ItemNo: Integer);
begin
  FRegistro.Add('P:' + ItemName + ':' + IntToStr(ItemNo));
end;

procedure TTestdbMaster.DataSetLento(Sender: TObject; ItemName: string; DataSet: TDataSet; Durata: TTimeSpan);
begin
  Inc(FLentoChiamate);
  FLentoNome := ItemName;
  FLentoDataSet := DataSet;
  FLentoSecondi := Durata.TotalSeconds;
end;

procedure TTestdbMaster.ContaPost(DataSet: TDataSet);
begin
  Inc(FPostEseguiti);
end;

procedure TTestdbMaster.ContaAnnullamento(DataSet: TDataSet);
begin
  Inc(FAnnullamenti);
end;

procedure TTestdbMaster.SollevaInPost(DataSet: TDataSet);
begin
  raise Exception.Create('errore di prova nel salvataggio');
end;

procedure TTestdbMaster.RitardaApertura(DataSet: TDataSet);
begin
  // la soglia del codice e' Elapsed.Seconds > 3: servono almeno quattro secondi
  TThread.Sleep(4100);
end;

procedure TTestdbMaster.SollevaInAggiornamento(Sender: TObject);
begin
  raise Exception.Create('errore di prova in UpdateRecord');
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-001
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-001
procedure TTestdbMaster.Master_ValoriPredefiniti;
var
  Nuovo: TdbMaster;
begin
  Nuovo := TdbMaster.Create(nil);
  try
    Assert.IsTrue(Nuovo.AutoOpen, 'AutoOpen');
    Assert.IsTrue(Nuovo.AutoClose, 'AutoClose');
    Assert.IsFalse(Nuovo.OpenInDesigner, 'OpenInDesigner');
    Assert.AreEqual(0, Nuovo.DataSets.Count, 'nessuna voce');
    Assert.AreSame(TObject(Nuovo), TObject(Nuovo.DataSets.Owner), 'proprietario della collezione');
    Assert.AreEqual(Ord(ocPost), Ord(Nuovo.OnClose), 'OnClose del componente');
    Assert.IsFalse(Assigned(Nuovo.OnOpenProgress), 'OnOpenProgress');
    Assert.IsFalse(Assigned(Nuovo.OnSlowDataSet), 'OnSlowDataSet');
    Assert.IsFalse(Assigned(Nuovo.BeforeOpen), 'BeforeOpen');
    Assert.IsFalse(Assigned(Nuovo.AfterOpen), 'AfterOpen');
    Assert.IsFalse(Assigned(Nuovo.BeforeClose), 'BeforeClose');
    Assert.IsFalse(Assigned(Nuovo.AfterClose), 'AfterClose');
    Assert.IsFalse(Assigned(Nuovo.BeforeCancel), 'BeforeCancel');
    Assert.IsFalse(Assigned(Nuovo.AfterCancel), 'AfterCancel');
    Assert.IsFalse(Assigned(Nuovo.BeforePost), 'BeforePost');
    Assert.IsFalse(Assigned(Nuovo.AfterPost), 'AfterPost');
    Assert.IsFalse(Assigned(Nuovo.BeforeRefresh), 'BeforeRefresh');
    Assert.IsFalse(Assigned(Nuovo.AfterRefresh), 'AfterRefresh');
  finally
    Nuovo.Free;
  end;
end;

// ZCOMMON-DBM-001
procedure TTestdbMaster.Voce_ValoriPredefiniti;
var
  Voce: TDataSetItem;
begin
  Voce := FMaster.DataSets.Add as TDataSetItem;

  Assert.IsTrue(Voce.DataSet = nil, 'DataSet');
  Assert.AreEqual('', Voce.DisplayName, 'DisplayName');
  Assert.IsTrue(Voce.IncludeInOpen, 'IncludeInOpen');
  Assert.IsTrue(Voce.IncludeInClose, 'IncludeInClose');
  Assert.IsTrue(Voce.IncludeInPost, 'IncludeInPost');
  Assert.IsTrue(Voce.IncludeInCancel, 'IncludeInCancel');
  Assert.IsTrue(Voce.IncludeInRefresh, 'IncludeInRefresh');
  Assert.AreEqual(Ord(ocPost), Ord(Voce.OnClose), 'OnClose');
  Assert.IsFalse(Assigned(Voce.BeforeOpen), 'BeforeOpen');
  Assert.IsFalse(Assigned(Voce.AfterOpen), 'AfterOpen');
  Assert.IsFalse(Assigned(Voce.BeforePost), 'BeforePost');
  Assert.IsFalse(Assigned(Voce.AfterRefresh), 'AfterRefresh');
end;

// ZCOMMON-DBM-001 (DIV-DBM-3): i campi si copiano prima che Assign sollevi
procedure TTestdbMaster.Assign_CopiaLeImpostazioniPrimaDiSollevare;
var
  Dati: TDataSetProva;
  Origine: TDataSetItem;
  Destinazione: TDataSetItem;
  EccezioneSollevata: Boolean;
begin
  EccezioneSollevata := False;
  Dati := CreaDataSet(True);
  Origine := FMaster.AddDataSet('Origine', Dati);
  Origine.IncludeInOpen := False;
  Origine.IncludeInPost := False;
  Origine.OnClose := ocCancel;
  Origine.BeforeOpen := VoceBeforeOpen;
  Destinazione := FMaster.DataSets.Add as TDataSetItem;

  try
    Destinazione.Assign(Origine);
  except
    // atteso oggi: vedi Divergenza_Assign_NonSollevaEccezioni
    on EConvertError do
      EccezioneSollevata := True;
  end;

  Assert.IsTrue(Destinazione.DataSet = Dati, 'DataSet');
  Assert.IsFalse(Destinazione.IncludeInOpen, 'IncludeInOpen');
  Assert.IsFalse(Destinazione.IncludeInPost, 'IncludeInPost');
  Assert.AreEqual(Ord(ocCancel), Ord(Destinazione.OnClose), 'OnClose');
  Assert.IsTrue(Assigned(Destinazione.BeforeOpen), 'BeforeOpen');
end;

// ZCOMMON-DBM-001 (DIV-DBM-3, corretta)
procedure TTestdbMaster.Divergenza_Assign_NonSollevaEccezioni;
var
  Origine: TDataSetItem;
  Destinazione: TDataSetItem;
begin
  Origine := FMaster.AddDataSet('Origine', CreaDataSet(True));
  Destinazione := FMaster.DataSets.Add as TDataSetItem;

  Assert.WillNotRaise(
    procedure
    begin
      Destinazione.Assign(Origine);
    end, nil, 'TCollectionItem non ha Assign: inherited solleva EConvertError');
end;

// ZCOMMON-DBM-001 (DIV-DBM-3, corretta)
procedure TTestdbMaster.Divergenza_Assign_CopiaDisplayName;
var
  Origine: TDataSetItem;
  Destinazione: TDataSetItem;
  EccezioneSollevata: Boolean;
begin
  EccezioneSollevata := False;
  Origine := FMaster.AddDataSet('Origine', CreaDataSet(True));
  Destinazione := FMaster.DataSets.Add as TDataSetItem;
  Destinazione.DisplayName := 'Altro';

  try
    Destinazione.Assign(Origine);
  except
    // l'eccezione e' oggetto di un'altra prova: qui conta solo il nome
    on EConvertError do
      EccezioneSollevata := True;
  end;

  Assert.AreEqual('Origine', Destinazione.DisplayName, 'DisplayName copiato');
end;

// ZCOMMON-DBM-001 (DIV-DBM-3, corretta)
procedure TTestdbMaster.Divergenza_AssegnaCollezione_CopiaLeVoci;
var
  Altro: TdbMaster;
begin
  AggiungiDataSet('A', True);
  Altro := TdbMaster.Create(nil);
  try
    Altro.AutoClose := False;

    Assert.WillNotRaise(
      procedure
      begin
        Altro.DataSets := FMaster.DataSets;
      end, nil, 'SetCollection chiama Assign voce per voce');
    Assert.AreEqual(1, Altro.DataSets.Count, 'voci copiate');
    Assert.AreEqual('A', Altro.DataSets[0].DisplayName, 'nome copiato');
  finally
    Altro.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-002
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-002
procedure TTestdbMaster.AddDataSet_NuovoNome_AggiungeLaVoce;
var
  Dati: TDataSetProva;
  Voce: TDataSetItem;
begin
  Dati := CreaDataSet(True);

  Voce := FMaster.AddDataSet('Anagrafe', Dati);

  Assert.AreEqual(1, FMaster.DataSets.Count, 'una voce');
  Assert.AreSame(TObject(FMaster.DataSets[0]), TObject(Voce), 'voce restituita');
  Assert.AreEqual('Anagrafe', Voce.DisplayName, 'nome');
  Assert.IsTrue(Voce.DataSet = Dati, 'dataset');
end;

// ZCOMMON-DBM-002
procedure TTestdbMaster.AddDataSet_DataSetNil_AggiungeVoceSenzaDataSet;
var
  Voce: TDataSetItem;
begin
  Voce := FMaster.AddDataSet('Vuota', nil);

  Assert.AreEqual(1, FMaster.DataSets.Count, 'una voce');
  Assert.IsTrue(Voce.DataSet = nil, 'senza dataset');
  // tutte le operazioni saltano la voce senza dataset
  Assert.WillNotRaise(
    procedure
    begin
      FMaster.OpenAll;
      FMaster.PostAll;
      FMaster.CancelAll;
      FMaster.RefreshAll;
      FMaster.CloseAll;
    end, nil, 'voce senza dataset ignorata');
end;

// ZCOMMON-DBM-002 (DIV-DBM-9)
procedure TTestdbMaster.AddDataSet_NomeEsistente_RestituisceVoceEsistenteSenzaCambiareDataSet;
var
  Primo: TDataSetProva;
  Secondo: TDataSetProva;
  Voce: TDataSetItem;
  Ripetuta: TDataSetItem;
begin
  Primo := CreaDataSet(True);
  Secondo := CreaDataSet(True);
  Voce := FMaster.AddDataSet('Anagrafe', Primo);

  Ripetuta := FMaster.AddDataSet('ANAGRAFE', Secondo);

  Assert.AreSame(TObject(Voce), TObject(Ripetuta), 'stessa voce');
  Assert.AreEqual(1, FMaster.DataSets.Count, 'nessuna voce nuova');
  Assert.IsTrue(Ripetuta.DataSet = Primo, 'il dataset resta il primo');
end;

// ZCOMMON-DBM-002
procedure TTestdbMaster.FindDataSetItem_SenzaDistinzioneMaiuscole;
var
  Voce: TDataSetItem;
begin
  Voce := FMaster.AddDataSet('Anagrafe', CreaDataSet(True));

  Assert.AreSame(TObject(Voce), TObject(FMaster.FindDataSetItem('aNaGrAfE')));
end;

// ZCOMMON-DBM-002
procedure TTestdbMaster.FindDataSetItem_NomeAssente_Nil;
begin
  FMaster.AddDataSet('Anagrafe', CreaDataSet(True));

  Assert.IsTrue(FMaster.FindDataSetItem('Altro') = nil);
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-003 e 004
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-003, ZCOMMON-DBM-014
procedure TTestdbMaster.OpenAll_ApreSoloLeVociIncluseConDataSet;
var
  Incluso: TDataSetProva;
  Escluso: TDataSetProva;
begin
  Incluso := AggiungiDataSet('A', False);
  Escluso := AggiungiDataSet('B', False);
  FMaster.FindDataSetItem('B').IncludeInOpen := False;
  FMaster.AddDataSet('C', nil);

  FMaster.OpenAll;

  Assert.IsTrue(Incluso.Active, 'A aperto');
  Assert.IsFalse(Escluso.Active, 'B escluso resta chiuso');
end;

// ZCOMMON-DBM-003
procedure TTestdbMaster.OpenAll_SenzaVoci_ScattanoSoloGliEventiDelComponente;
begin
  CollegaEventiComponente;

  FMaster.OpenAll;

  Assert.AreEqual('C.BeforeOpen|C.AfterOpen', TestoRegistro);
end;

// ZCOMMON-DBM-003, ZCOMMON-DBM-013
procedure TTestdbMaster.OpenAll_OrdineDegliEventi;
begin
  AggiungiDataSet('A', False);
  AggiungiDataSet('B', False);
  CollegaEventiComponente;
  CollegaEventiVoce('A');
  CollegaEventiVoce('B');
  FMaster.OnOpenProgress := Avanzamento;

  FMaster.OpenAll;

  Assert.AreEqual('C.BeforeOpen|P:A:0|V.BeforeOpen:A|V.AfterOpen:A|P:B:1|V.BeforeOpen:B|V.AfterOpen:B|C.AfterOpen', TestoRegistro);
end;

// ZCOMMON-DBM-003
procedure TTestdbMaster.OpenAll_DataSetGiaAperto_EventiScattanoERestaAperto;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  CollegaEventiVoce('A');

  FMaster.OpenAll;

  Assert.IsTrue(Dati.Active, 'resta aperto');
  Assert.AreEqual('V.BeforeOpen:A|V.AfterOpen:A', TestoRegistro);
end;

// ZCOMMON-DBM-004
procedure TTestdbMaster.OpenAll_Avanzamento_UnaChiamataPerVoceConIndiceDaZero;
begin
  AggiungiDataSet('A', False);
  AggiungiDataSet('B', False);
  FMaster.FindDataSetItem('B').IncludeInOpen := False;
  FMaster.AddDataSet('C', nil);
  FMaster.OnOpenProgress := Avanzamento;

  FMaster.OpenAll;

  Assert.AreEqual('P:A:0|P:B:1|P:C:2', TestoRegistro);
end;

// ZCOMMON-DBM-004
procedure TTestdbMaster.OpenAll_DataSetVeloce_NonSegnalaLentezza;
begin
  AggiungiDataSet('A', False);
  FMaster.OnSlowDataSet := DataSetLento;

  FMaster.OpenAll;

  Assert.AreEqual(0, FLentoChiamate);
end;

// ZCOMMON-DBM-004 (prova lenta: piu' di quattro secondi)
procedure TTestdbMaster.OpenAll_DataSetLento_ChiamaOnSlowDataSet;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('Lenta', False);
  Dati.BeforeOpen := RitardaApertura;
  FMaster.OnSlowDataSet := DataSetLento;

  FMaster.OpenAll;

  Assert.AreEqual(1, FLentoChiamate, 'una chiamata');
  Assert.AreEqual('Lenta', FLentoNome, 'nome della voce');
  Assert.AreSame(TObject(Dati), TObject(FLentoDataSet), 'dataset');
  Assert.IsTrue(FLentoSecondi >= 4.0, 'durata di almeno quattro secondi');
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-005
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-005
procedure TTestdbMaster.CloseAll_ChiudeSoloVociIncluseEAttive;
var
  Incluso: TDataSetProva;
  Escluso: TDataSetProva;
begin
  Incluso := AggiungiDataSet('A', True);
  Escluso := AggiungiDataSet('B', True);
  FMaster.FindDataSetItem('B').IncludeInClose := False;
  FMaster.AddDataSet('C', nil);
  AggiungiDataSet('D', False);

  FMaster.CloseAll;

  Assert.IsFalse(Incluso.Active, 'A chiuso');
  Assert.IsTrue(Escluso.Active, 'B escluso resta attivo');
end;

// ZCOMMON-DBM-005, ZCOMMON-DBM-013
procedure TTestdbMaster.CloseAll_OrdineDegliEventi;
begin
  AggiungiDataSet('A', True);
  AggiungiDataSet('B', True);
  CollegaEventiComponente;
  CollegaEventiVoce('A');
  CollegaEventiVoce('B');

  FMaster.CloseAll;

  Assert.AreEqual('C.BeforeClose|V.BeforeClose:A|V.AfterClose:A|V.BeforeClose:B|V.AfterClose:B|C.AfterClose', TestoRegistro);
end;

// ZCOMMON-DBM-005
procedure TTestdbMaster.CloseAll_ModificaInSospesoOcPost_Salva;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  Dati.AfterPost := ContaPost;
  Dati.AfterCancel := ContaAnnullamento;
  FMaster.FindDataSetItem('A').OnClose := ocPost;
  Inserisci(Dati);

  FMaster.CloseAll;

  Assert.AreEqual(1, FPostEseguiti, 'Post eseguito');
  Assert.AreEqual(0, FAnnullamenti, 'nessun Cancel');
  Assert.IsFalse(Dati.Active, 'chiuso');
end;

// ZCOMMON-DBM-005
procedure TTestdbMaster.CloseAll_ModificaInSospesoOcCancel_Annulla;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  Dati.AfterPost := ContaPost;
  Dati.AfterCancel := ContaAnnullamento;
  FMaster.FindDataSetItem('A').OnClose := ocCancel;
  Inserisci(Dati);

  FMaster.CloseAll;

  Assert.AreEqual(0, FPostEseguiti, 'nessun Post');
  Assert.AreEqual(1, FAnnullamenti, 'Cancel eseguito');
  Assert.IsFalse(Dati.Active, 'chiuso');
end;

// ZCOMMON-DBM-005 (DIV-DBM-7)
procedure TTestdbMaster.CloseAll_ErroreNelSalvataggio_InterrompeIlGiroELasciaAperteLeAltre;
var
  Primo: TDataSetProva;
  Secondo: TDataSetProva;
begin
  Primo := AggiungiDataSet('A', True);
  Secondo := AggiungiDataSet('B', True);
  CollegaEventiComponente;
  Primo.BeforePost := SollevaInPost;
  Inserisci(Primo);

  Assert.WillRaise(
    procedure
    begin
      FMaster.CloseAll;
    end, Exception, 'l''errore di Post arriva al chiamante');

  Assert.IsTrue(Primo.Active, 'il primo resta aperto in modifica');
  Assert.IsTrue(Secondo.Active, 'il secondo non e'' stato chiuso');
  Assert.AreEqual('C.BeforeClose', TestoRegistro, 'AfterClose del componente non scatta');
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-006
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-006
procedure TTestdbMaster.PostAll_SalvaSoloVociInModificaEIncluse;
var
  InInserimento: TDataSetProva;
  InNavigazione: TDataSetProva;
  Escluso: TDataSetProva;
begin
  InInserimento := AggiungiDataSet('A', True);
  InNavigazione := AggiungiDataSet('B', True);
  Escluso := AggiungiDataSet('C', True);
  FMaster.FindDataSetItem('C').IncludeInPost := False;
  FMaster.AddDataSet('D', nil);
  AggiungiDataSet('E', False);
  InInserimento.AfterPost := ContaPost;
  Inserisci(InInserimento);
  Inserisci(Escluso);

  FMaster.PostAll;

  Assert.IsTrue(InInserimento.State = dsBrowse, 'A salvato');
  Assert.AreEqual(1, FPostEseguiti, 'un solo Post');
  Assert.IsTrue(InNavigazione.State = dsBrowse, 'B invariato');
  Assert.IsTrue(Escluso.State = dsInsert, 'C escluso resta in inserimento');
end;

// ZCOMMON-DBM-006, ZCOMMON-DBM-013
procedure TTestdbMaster.PostAll_OrdineDegliEventi;
begin
  Inserisci(AggiungiDataSet('A', True));
  CollegaEventiComponente;
  CollegaEventiVoce('A');

  FMaster.PostAll;

  Assert.AreEqual('C.BeforePost|V.BeforePost:A|V.AfterPost:A|C.AfterPost', TestoRegistro);
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-007
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-007
procedure TTestdbMaster.CancelAll_AnnullaSoloVociInModificaEIncluse;
var
  InInserimento: TDataSetProva;
  InNavigazione: TDataSetProva;
  Escluso: TDataSetProva;
begin
  InInserimento := AggiungiDataSet('A', True);
  InNavigazione := AggiungiDataSet('B', True);
  Escluso := AggiungiDataSet('C', True);
  FMaster.FindDataSetItem('C').IncludeInCancel := False;
  InInserimento.AfterCancel := ContaAnnullamento;
  Inserisci(InInserimento);
  Inserisci(Escluso);

  FMaster.CancelAll;

  Assert.IsTrue(InInserimento.State = dsBrowse, 'A annullato');
  Assert.AreEqual(0, InInserimento.RecordCount, 'il record nuovo e'' scartato');
  Assert.AreEqual(1, FAnnullamenti, 'un solo Cancel');
  Assert.IsTrue(InNavigazione.State = dsBrowse, 'B invariato');
  Assert.IsTrue(Escluso.State = dsInsert, 'C escluso resta in inserimento');
end;

// ZCOMMON-DBM-007, ZCOMMON-DBM-013
procedure TTestdbMaster.CancelAll_OrdineDegliEventi;
begin
  Inserisci(AggiungiDataSet('A', True));
  CollegaEventiComponente;
  CollegaEventiVoce('A');

  FMaster.CancelAll;

  Assert.AreEqual('C.BeforeCancel|V.BeforeCancel:A|V.AfterCancel:A|C.AfterCancel', TestoRegistro);
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-008
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-008
procedure TTestdbMaster.RefreshAll_AggiornaSoloVociAttiveEIncluse;
var
  Primo: TDataSetProva;
  Escluso: TDataSetProva;
  Chiuso: TDataSetProva;
begin
  Primo := AggiungiDataSet('A', True);
  Escluso := AggiungiDataSet('B', True);
  Chiuso := AggiungiDataSet('C', False);
  FMaster.FindDataSetItem('B').IncludeInRefresh := False;

  FMaster.RefreshAll;

  Assert.AreEqual(1, Primo.ConteggioRefresh, 'A aggiornato');
  Assert.AreEqual(0, Escluso.ConteggioRefresh, 'B escluso');
  Assert.AreEqual(0, Chiuso.ConteggioRefresh, 'C chiuso');
end;

// ZCOMMON-DBM-008, ZCOMMON-DBM-013
procedure TTestdbMaster.RefreshAll_OrdineDegliEventi;
begin
  AggiungiDataSet('A', True);
  CollegaEventiComponente;
  CollegaEventiVoce('A');

  FMaster.RefreshAll;

  Assert.AreEqual('C.BeforeRefresh|V.BeforeRefresh:A|V.AfterRefresh:A|C.AfterRefresh', TestoRegistro);
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-009
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-009
procedure TTestdbMaster.IsModified_SenzaVoci_Falso;
begin
  Assert.IsFalse(FMaster.IsModified);
end;

// ZCOMMON-DBM-009
procedure TTestdbMaster.IsModified_InserimentoAppenaAperto_Vero;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  Dati.Append;

  Assert.IsTrue(FMaster.IsModified, 'dsInsert senza campi toccati');
end;

// ZCOMMON-DBM-009
procedure TTestdbMaster.IsModified_ModificaSenzaCambiamenti_Falso;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  ConRecord(Dati);
  Dati.Edit;

  Assert.IsFalse(FMaster.IsModified, 'dsEdit senza campi cambiati');
end;

// ZCOMMON-DBM-009
procedure TTestdbMaster.IsModified_CampoCambiato_Vero;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  ConRecord(Dati);
  Dati.Edit;
  Dati.FieldByName('Valore').AsString := 'due';

  Assert.IsTrue(FMaster.IsModified);
end;

// ZCOMMON-DBM-009
procedure TTestdbMaster.IsModified_DopoIlSalvataggio_Falso;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);
  Inserisci(Dati);
  Dati.Post;

  Assert.IsFalse(FMaster.IsModified);
end;

// ZCOMMON-DBM-009
procedure TTestdbMaster.IsModified_DataSetChiusoOSenzaDataSet_Ignorato;
begin
  AggiungiDataSet('A', False);
  FMaster.AddDataSet('B', nil);

  Assert.IsFalse(FMaster.IsModified);
end;

// ZCOMMON-DBM-009 (DIV-DBM-6)
procedure TTestdbMaster.IsModified_ErroreInUpdateRecord_Ingoiato;
var
  Dati: TDataSetProva;
  Sorgente: TDataSource;
begin
  Dati := AggiungiDataSet('A', True);
  Sorgente := TDataSource.Create(nil);
  try
    Sorgente.DataSet := Dati;
    Sorgente.OnUpdateData := SollevaInAggiornamento;
    Inserisci(Dati);

    // controllo: UpdateRecord, chiamato direttamente, solleva davvero
    Assert.WillRaise(
      procedure
      begin
        Dati.UpdateRecord;
      end, Exception, 'la sorgente dati solleva in UpdateRecord');

    Assert.IsTrue(FMaster.IsModified, 'l''errore e'' ingoiato e il risultato e'' vero');
  finally
    Sorgente.DataSet := nil;
    Sorgente.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-010
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-010 (DIV-DBM-10, attesa rossa)
procedure TTestdbMaster.Divergenza_OpenCount_SenzaVoci_Zero;
begin
  Assert.AreEqual(0, FMaster.OpenCount, 'senza voci non c''e'' niente da aprire');
end;

// ZCOMMON-DBM-010 (DIV-DBM-10, attesa rossa)
procedure TTestdbMaster.Divergenza_OpenCount_ContaLeSoleVociDaAprire;
begin
  AggiungiDataSet('A', False);
  AggiungiDataSet('B', False);
  AggiungiDataSet('C', False);
  FMaster.FindDataSetItem('C').IncludeInOpen := False;

  Assert.AreEqual(2, FMaster.OpenCount, 'due voci da aprire');
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-011
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-011
procedure TTestdbMaster.Notifica_DataSetDistrutto_VoceRimossa;
var
  Primo: TDataSetProva;
begin
  Primo := AggiungiDataSet('A', True);
  AggiungiDataSet('B', True);

  // Remove libera il dataset (la lista ne e' proprietaria)
  FDataSetCreati.Remove(Primo);

  Assert.AreEqual(1, FMaster.DataSets.Count, 'una voce in meno');
  Assert.AreEqual('B', FMaster.DataSets[0].DisplayName, 'resta B');
end;

// ZCOMMON-DBM-011
procedure TTestdbMaster.Notifica_DataSetDistruttoConProprietarioComune_VoceRimossa;
var
  Proprietario: TComponent;
  Master: TdbMaster;
  Dati: TDataSetProva;
begin
  Proprietario := TComponent.Create(nil);
  try
    Master := TdbMaster.Create(Proprietario);
    Master.AutoClose := False;
    Dati := TDataSetProva.Create(Proprietario);
    Dati.FieldDefs.Add('Valore', ftString, 20);
    Master.AddDataSet('A', Dati);

    Dati.Free;

    Assert.AreEqual(0, Master.DataSets.Count, 'voce rimossa tramite il proprietario comune');
  finally
    Proprietario.Free;
  end;
end;

// ZCOMMON-DBM-011
procedure TTestdbMaster.Notifica_VoceScollegata_NonPiuRimossa;
var
  Dati: TDataSetProva;
  Voce: TDataSetItem;
begin
  Dati := CreaDataSet(True);
  Voce := FMaster.AddDataSet('A', Dati);
  Voce.DataSet := nil;

  FDataSetCreati.Remove(Dati);

  Assert.AreEqual(1, FMaster.DataSets.Count, 'la voce resta');
end;

// ZCOMMON-DBM-011
procedure TTestdbMaster.Notifica_DataSetSostituito_NotificaSoloIlNuovo;
var
  Vecchio: TDataSetProva;
  Nuovo: TDataSetProva;
  Voce: TDataSetItem;
begin
  Vecchio := CreaDataSet(True);
  Nuovo := CreaDataSet(True);
  Voce := FMaster.AddDataSet('A', Vecchio);
  Voce.DataSet := Nuovo;

  FDataSetCreati.Remove(Vecchio);
  Assert.AreEqual(1, FMaster.DataSets.Count, 'distrutto il vecchio: la voce resta');
  Assert.IsTrue(Voce.DataSet = Nuovo, 'punta al nuovo');

  FDataSetCreati.Remove(Nuovo);
  Assert.AreEqual(0, FMaster.DataSets.Count, 'distrutto il nuovo: la voce sparisce');
end;

// ZCOMMON-DBM-011
procedure TTestdbMaster.Notifica_ComponenteNonRegistrato_Ignorato;
var
  Altro: TComponent;
begin
  AggiungiDataSet('A', True);
  Altro := TComponent.Create(nil);
  try
    FMaster.NotificaProva(Altro, opRemove);

    Assert.AreEqual(1, FMaster.DataSets.Count);
  finally
    Altro.Free;
  end;
end;

// ZCOMMON-DBM-011
procedure TTestdbMaster.Notifica_Inserimento_Ignorato;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', True);

  FMaster.NotificaProva(Dati, opInsert);

  Assert.AreEqual(1, FMaster.DataSets.Count);
end;

// ZCOMMON-DBM-011 (DIV-DBM-9, attesa rossa)
procedure TTestdbMaster.Divergenza_Notifica_StessoDataSetInDueVoci_RimosseEntrambe;
var
  Dati: TDataSetProva;
begin
  Dati := TDataSetProva.Create(nil);
  Dati.FieldDefs.Add('Valore', ftString, 20);
  FMaster.AddDataSet('A', Dati);
  FMaster.AddDataSet('B', Dati);

  Dati.Free;
  try
    // la seconda voce resterebbe con un puntatore a un oggetto distrutto
    Assert.AreEqual(0, FMaster.DataSets.Count, 'entrambe le voci del dataset distrutto');
  finally
    // si svuota senza toccare i dataset (il distruttore delle voci non li usa)
    FMaster.DataSets.Clear;
  end;
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-012
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-012
procedure TTestdbMaster.Loaded_AutoOpenVero_ApreIDataSet;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', False);
  FMaster.AutoOpen := True;

  FMaster.CaricaOra;

  Assert.IsTrue(Dati.Active);
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.Loaded_AutoOpenFalso_NonApre;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', False);
  FMaster.AutoOpen := False;

  FMaster.CaricaOra;

  Assert.IsFalse(Dati.Active);
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.Loaded_InProgettoSenzaOpenInDesigner_NonApre;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', False);
  FMaster.AutoOpen := True;
  FMaster.ImpostaInProgetto(True);

  FMaster.CaricaOra;

  Assert.IsFalse(Dati.Active, 'in progetto conta solo OpenInDesigner');
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.OpenInDesigner_InProgetto_ApreEChiude;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', False);
  FMaster.ImpostaInProgetto(True);

  FMaster.OpenInDesigner := True;
  Assert.IsTrue(Dati.Active, 'OpenInDesigner vero apre');

  FMaster.OpenInDesigner := False;
  Assert.IsFalse(Dati.Active, 'OpenInDesigner falso chiude');
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.OpenInDesigner_InEsecuzione_SoloMemorizza;
var
  Dati: TDataSetProva;
begin
  Dati := AggiungiDataSet('A', False);

  FMaster.OpenInDesigner := True;

  Assert.IsTrue(FMaster.OpenInDesigner, 'valore memorizzato');
  Assert.IsFalse(Dati.Active, 'nessuna apertura in esecuzione');
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.Distruzione_AutoCloseVero_ChiudeIDataSet;
var
  Dati: TDataSetProva;
  Master: TdbMaster;
begin
  Dati := CreaDataSet(True);
  Master := TdbMaster.Create(nil);
  Master.AddDataSet('A', Dati);

  Master.Free;

  Assert.IsFalse(Dati.Active, 'AutoClose e'' vero per impostazione predefinita');
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.Distruzione_AutoCloseFalso_LasciaApertiIDataSet;
var
  Dati: TDataSetProva;
  Master: TdbMaster;
begin
  Dati := CreaDataSet(True);
  Master := TdbMaster.Create(nil);
  Master.AutoClose := False;
  Master.AddDataSet('A', Dati);

  Master.Free;

  Assert.IsTrue(Dati.Active);
end;

// ZCOMMON-DBM-012
procedure TTestdbMaster.Distruzione_InProgetto_LasciaApertiIDataSet;
var
  Dati: TDataSetProva;
  Master: TdbMasterProva;
begin
  Dati := CreaDataSet(True);
  Master := TdbMasterProva.Create(nil);
  Master.AddDataSet('A', Dati);
  Master.ImpostaInProgetto(True);

  Master.Free;

  Assert.IsTrue(Dati.Active, 'in progetto la distruzione non chiude');
end;

// ---------------------------------------------------------------------------
// ZCOMMON-DBM-013
// ---------------------------------------------------------------------------

// ZCOMMON-DBM-013
procedure TTestdbMaster.Eventi_SenderDiComponenteEVoce;
var
  Dati: TDataSetProva;
  Voce: TDataSetItem;
  Evento: string;
begin
  Dati := AggiungiDataSet('A', False);
  Voce := FMaster.FindDataSetItem('A');
  CollegaEventiComponente;
  CollegaEventiVoce('A');

  FMaster.OpenAll;
  Inserisci(Dati);
  FMaster.PostAll;
  Inserisci(Dati);
  FMaster.CancelAll;
  FMaster.RefreshAll;
  FMaster.CloseAll;

  // BeforePost, BeforeCancel e AfterRefresh del componente sono nelle prove Divergenza_*
  Assert.AreSame(TObject(FMaster), FSender['C.BeforeOpen'], 'C.BeforeOpen');
  Assert.AreSame(TObject(FMaster), FSender['C.AfterOpen'], 'C.AfterOpen');
  Assert.AreSame(TObject(FMaster), FSender['C.BeforeClose'], 'C.BeforeClose');
  Assert.AreSame(TObject(FMaster), FSender['C.AfterClose'], 'C.AfterClose');
  Assert.AreSame(TObject(FMaster), FSender['C.AfterPost'], 'C.AfterPost');
  Assert.AreSame(TObject(FMaster), FSender['C.AfterCancel'], 'C.AfterCancel');
  Assert.AreSame(TObject(FMaster), FSender['C.BeforeRefresh'], 'C.BeforeRefresh');

  for Evento in EventiVoce do
    Assert.AreSame(TObject(Voce), FSender['V.' + Evento + ':A'], 'evento di voce ' + Evento);
end;

// ZCOMMON-DBM-013 (DIV-DBM-1, attesa rossa)
procedure TTestdbMaster.Divergenza_BeforePost_SenderDelComponenteESelf;
begin
  Inserisci(AggiungiDataSet('A', True));
  CollegaEventiComponente;

  FMaster.PostAll;

  Assert.AreSame(TObject(FMaster), FSender['C.BeforePost'], 'BeforePost riceve la variabile item non assegnata');
end;

// ZCOMMON-DBM-013 (DIV-DBM-1, attesa rossa)
procedure TTestdbMaster.Divergenza_BeforeCancel_SenderDelComponenteESelf;
begin
  Inserisci(AggiungiDataSet('A', True));
  CollegaEventiComponente;

  FMaster.CancelAll;

  Assert.AreSame(TObject(FMaster), FSender['C.BeforeCancel'], 'BeforeCancel riceve la variabile item non assegnata');
end;

// ZCOMMON-DBM-013 (DIV-DBM-2, attesa rossa)
procedure TTestdbMaster.Divergenza_AfterRefresh_SenderDelComponenteESelf;
begin
  AggiungiDataSet('A', True);
  CollegaEventiComponente;

  FMaster.RefreshAll;

  Assert.AreSame(TObject(FMaster), FSender['C.AfterRefresh'], 'AfterRefresh riceve l''ultima voce');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestdbMaster);

end.
