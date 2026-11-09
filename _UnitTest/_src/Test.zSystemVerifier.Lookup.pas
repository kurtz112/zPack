// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-04
// ---------------------------------------------------------------------------
unit Test.zSystemVerifier.Lookup;

// Test DUnitX dei controlli sulla definizione dei lookup di TzSystemVerifier
// (Mantis #320): per ognuno il caso che scatta, quello che non scatta e, dove
// valgono, l'eccezione Exists=False e il lookup sull'id senza alternative.
//
// Il dizionario si costruisce in memoria dentro il TzSystem della prova, senza
// database: i controlli nuovi leggono solo il dizionario. Il modello e' quello
// del ticket, gia' corretto: campo INTERVENTI.ID_ASSISTENTE con lookup a griglia
// sulle coppie assistente-comune. Ogni prova rompe una proprieta' e guarda la
// categoria del controllo.
//
// TzSystem e' un oggetto unico di processo (la variabile Base): ogni prova ne
// crea uno in Setup e lo libera in TearDown, come Test.zSystem.Dizionario.

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  DUnitX.TestFramework,
  zBaseLib,
  zTypes,
  zMetadata,
  zSystem,
  zSystemVerifier;

type
  TInterruttori = reference to procedure(Verificatore: TzSystemVerifier);

  [TestFixture]
  TTestVerificaLookup = class
  private
    FSistema: TzSystem;
    FRisultati: TzVerifyResults;
    FLookup: TzLookup;
    FDati: TzDataSet;
    FVista: TzDbViewProps;
    FDominio: TzDomain;

    function NuovoDominio(const Tabella, Campo: string; const Tipo: TFieldType; const Dimensione: Integer): TzDomain;
    procedure PreparaDizionario;
    procedure AggiungiColonna(const Nome: string; const Visibile: Boolean = True);
    procedure Esegui(const Interruttori: TInterruttori);
    function Quanti(const Categoria: TzVerifyCategory): Integer;
    function GravitaDi(const Categoria: TzVerifyCategory): TzVerifySeverity;
    procedure EseguiColonneVuote;
    procedure EseguiParametri;
    procedure EseguiDomini;
    procedure EseguiChiaveMostrata;
    procedure EseguiRicerca;
    procedure EseguiOrdinamento;
    procedure EseguiColonne;
    procedure EseguiChiaveComposta;
    procedure ChiavePrimariaComposta;
    procedure SenzaAlternative;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Interruttori_SpentiDiNorma_NessunaSegnalazione;
    [Test]
    procedure Dizionario_Corretto_NessunControlloScatta;

    [Test]
    procedure VistaVuota_ChiavePrimaColonna_Errore;
    [Test]
    procedure VistaVuota_ConSearchFields_NonScatta;
    [Test]
    procedure VistaVuota_DescrizionePrimaColonna_NonScatta;
    [Test]
    procedure VistaVuota_TestoNonRiconosciuto_SoloAvviso;
    [Test]
    procedure VistaVuota_SoloCampiDiServizio_NonScatta;
    [Test]
    procedure VistaVuota_TestoNonRiconosciuto_SenzaInterruttore_NonScatta;
    [Test]
    procedure VistaVuota_CampoExistsFalse_NonScatta;
    [Test]
    procedure VistaVuota_ChiaveTestuale_NonScatta;

    [Test]
    procedure Parametri_MasterSenzaParametro_Errore;
    [Test]
    procedure Parametri_ParametroSenzaMaster_Errore;
    [Test]
    procedure Parametri_CampoDelMasterInesistente_Errore;
    [Test]
    procedure Parametri_ParametroDiversoDalCampo_NonScatta;
    [Test]
    procedure Parametri_SegnapostoAzienda_NonScatta;
    [Test]
    procedure Parametri_DataSetDiUnModulo_NonScatta;
    [Test]
    procedure Parametri_ParametroInUnCommento_NonConta;

    [Test]
    procedure Dominio_LookupInesistente_Errore;
    [Test]
    procedure Dominio_LookupInesistenteCampoMorto_NonScatta;
    [Test]
    procedure Dominio_ControlloNonLookup_Avviso;
    [Test]
    procedure Dominio_LookupEsistente_NonScatta;

    [Test]
    procedure ChiaveMostrata_PrimaColonnaChiave_Avviso;
    [Test]
    procedure ChiaveMostrata_SenzaAlternative_NonScatta;
    [Test]
    procedure ChiaveMostrata_CampoExistsFalse_NonScatta;
    [Test]
    procedure ChiaveMostrata_ChiaveNascosta_NonScatta;

    [Test]
    procedure Ricerca_SullaChiave_Avviso;
    [Test]
    procedure Ricerca_SullaDescrizione_NonScatta;
    [Test]
    procedure Ricerca_SenzaAlternative_NonScatta;

    [Test]
    procedure Ordinamento_SullaChiave_Avviso;
    [Test]
    procedure Ordinamento_Assente_Avviso;
    [Test]
    procedure Ordinamento_PerPosizione_NonScatta;
    [Test]
    procedure Ordinamento_SuEspressione_NonScatta;

    [Test]
    procedure Colonne_VistaConColonnaAssente_Errore;
    [Test]
    procedure Colonne_ColonnaNascostaAssente_NonScatta;
    [Test]
    procedure Colonne_DisplayColumnsAssente_Errore;
    [Test]
    procedure Colonne_PrimoDisplayNonVisibile_Errore;
    [Test]
    procedure Colonne_AliasDellaSelect_NonScatta;
    [Test]
    procedure Colonne_RelazioneIgnota_NonScatta;

    [Test]
    procedure ChiaveComposta_SenzaFiltro_Avviso;
    [Test]
    procedure ChiaveComposta_ConFiltro_NonScatta;
    [Test]
    procedure ChiaveComposta_Distinct_NonScatta;
    [Test]
    procedure ChiaveComposta_ChiaveSemplice_NonScatta;
  end;

  [TestFixture]
  TTestFormaDellaSelect = class
  public
    [Test]
    procedure Colonne_AliasECampiQualificati;
    [Test]
    procedure Colonne_EspressioneDiTesto;
    [Test]
    procedure Relazioni_AliasEJoin;
    [Test]
    procedure Where_SoloBloccoPrincipale;
    [Test]
    procedure OrderBy_PrimoTermine;
    [Test]
    procedure Commenti_NonContano;
    [Test]
    procedure TabellaDerivata_FormaIncompleta;
  end;

implementation

const
  SelectCorretta =
    'SELECT ASSISTENTI_COMUNI.ID_ASSISTENTE, ASSISTENTI_COMUNI.BELFIORE, ASSISTENTI.NOMINATIVO ' +
    'FROM ASSISTENTI_COMUNI ' +
    'INNER JOIN ASSISTENTI ON ASSISTENTI.ID_ASSISTENTE = ASSISTENTI_COMUNI.ID_ASSISTENTE ' +
    'WHERE ASSISTENTI_COMUNI.BELFIORE = :COMUNE_SIA ' +
    'ORDER BY ASSISTENTI.NOMINATIVO';

  // come il lookup su ID_INCARICO: solo la chiave e campi che non descrivono la voce
  SelectSenzaAlternative = 'SELECT INCARICHI.ID_INCARICO, INCARICHI.SEDE_SVOLGIMENTO FROM INCARICHI ORDER BY INCARICHI.ID_INCARICO';

{ TTestVerificaLookup }

procedure TTestVerificaLookup.Setup;
begin
  FSistema := TzSystem.Create(nil);
  FRisultati := TzVerifyResults.Create;
  PreparaDizionario;
end;

procedure TTestVerificaLookup.TearDown;
begin
  FreeAndNil(FRisultati);
  FreeAndNil(FSistema);
end;

function TTestVerificaLookup.NuovoDominio(const Tabella, Campo: string; const Tipo: TFieldType; const Dimensione: Integer): TzDomain;
begin
  Result := FSistema.zDataDictionary.Add;
  Result.Name := Tabella + '.' + Campo;
  Result.TableName := Tabella;
  Result.FieldName := Campo;
  Result.DataType := Tipo;
  Result.Size := Dimensione;
end;

procedure TTestVerificaLookup.PreparaDizionario;
var
  Modulo: TzDataSet;
begin
  NuovoDominio('ASSISTENTI_COMUNI', 'ID_ASSISTENTE', ftLargeint, -1);
  NuovoDominio('ASSISTENTI_COMUNI', 'BELFIORE', ftString, 4);
  NuovoDominio('ASSISTENTI', 'ID_ASSISTENTE', ftLargeint, -1);
  NuovoDominio('ASSISTENTI', 'NOMINATIVO', ftString, 100);
  NuovoDominio('INCARICHI', 'ID_INCARICO', ftLargeint, -1);
  NuovoDominio('INCARICHI', 'SEDE_SVOLGIMENTO', ftString, 100);
  NuovoDominio('INTERVENTI', 'COMUNE_SIA', ftString, 4);

  FDominio := NuovoDominio('INTERVENTI', 'ID_ASSISTENTE', ftLargeint, -1);
  FDominio.zCtrlType := ctLookupExt;
  FDominio.Lookup := 'LK_ASSISTENTI';

  // la relazione del campo arriva a video attraverso il dataset di un modulo
  Modulo := FSistema.zDataSets.Add;
  Modulo.Name := 'Interventi.Interventi';
  Modulo.TableName := 'INTERVENTI';
  Modulo.SQL_Select.Text := 'SELECT INTERVENTI.ID_ASSISTENTE, INTERVENTI.COMUNE_SIA FROM INTERVENTI';

  FDati := FSistema.zDataSets.Add;
  FDati.Name := '_lk_LK_ASSISTENTI';
  FDati.TableName := 'ASSISTENTI_COMUNI';
  FDati.SQL_Select.Text := SelectCorretta;

  FVista := FSistema.zDbViews.Add;
  FVista.Name := '_lk_LK_ASSISTENTI';
  FVista.DataSet := '_lk_LK_ASSISTENTI';
  FVista.SearchFields := 'NOMINATIVO';
  AggiungiColonna('NOMINATIVO');
  AggiungiColonna('ID_ASSISTENTE', False);

  FLookup := FSistema.zLookups.Add;
  FLookup.Name := 'LK_ASSISTENTI';
  FLookup.DataSet := '_lk_LK_ASSISTENTI';
  FLookup.DbView := '_lk_LK_ASSISTENTI';
  FLookup.TableName := 'INTERVENTI';
  FLookup.FieldNames := 'ID_ASSISTENTE; COMUNE_SIA';
  FLookup.FieldNamesFK := 'ID_ASSISTENTE; BELFIORE';
  FLookup.KeyField := 'ID_ASSISTENTE';
  FLookup.DisplayColumns := 'NOMINATIVO;';
  FLookup.MasterFields := 'COMUNE_SIA';
end;

procedure TTestVerificaLookup.AggiungiColonna(const Nome: string; const Visibile: Boolean);
var
  Colonna: TzColumn;
begin
  Colonna := FVista.Columns.Add;
  Colonna.Name := Nome;
  Colonna.Visible := Visibile;
end;

procedure TTestVerificaLookup.Esegui(const Interruttori: TInterruttori);
var
  Verificatore: TzSystemVerifier;
begin
  FRisultati.Clear;
  Verificatore := TzSystemVerifier.Create(FSistema, nil);
  try
    // i controlli che preparano la SQL chiedono un database: qui non c'e'
    Verificatore.StopOnFirstError := False;
    Verificatore.CheckSql := False;
    Verificatore.CheckEmptySelect := False;
    Verificatore.CheckStoredProcs := False;
    Verificatore.CheckLookups := False;
    if Assigned(Interruttori) then
      Interruttori(Verificatore);
    Verificatore.VerifyAll(FRisultati);
  finally
    Verificatore.Free;
  end;
end;

function TTestVerificaLookup.Quanti(const Categoria: TzVerifyCategory): Integer;
var
  Risultato: TzVerifyResult;
begin
  Result := 0;
  for Risultato in FRisultati do
    if Risultato.Category = Categoria then
      Inc(Result);
end;

function TTestVerificaLookup.GravitaDi(const Categoria: TzVerifyCategory): TzVerifySeverity;
var
  Risultato: TzVerifyResult;
begin
  for Risultato in FRisultati do
    if Risultato.Category = Categoria then
      Exit(Risultato.Severity);
  raise Exception.Create('Nessun risultato della categoria ' + CategoryToStr(Categoria));
end;

procedure TTestVerificaLookup.EseguiColonneVuote;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupGridColumns := True;
    end);
end;

procedure TTestVerificaLookup.EseguiParametri;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupParameters := True;
    end);
end;

procedure TTestVerificaLookup.EseguiDomini;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupDomainMissing := True;
    end);
end;

procedure TTestVerificaLookup.EseguiChiaveMostrata;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupShowsKey := True;
    end);
end;

procedure TTestVerificaLookup.EseguiRicerca;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupSearchOnKey := True;
    end);
end;

procedure TTestVerificaLookup.EseguiOrdinamento;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupOrderBy := True;
    end);
end;

procedure TTestVerificaLookup.EseguiColonne;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupColumnsExist := True;
    end);
end;

procedure TTestVerificaLookup.EseguiChiaveComposta;
begin
  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupCompositeKey := True;
    end);
end;

procedure TTestVerificaLookup.ChiavePrimariaComposta;
var
  Tabella: TzmdTable;
begin
  Tabella := FSistema.MetaData.Tables.Add;
  Tabella.Name := 'ASSISTENTI_COMUNI';
  Tabella.PrimaryKey.Add.Name := 'ID_ASSISTENTE';
  Tabella.PrimaryKey.Add.Name := 'BELFIORE';
end;

procedure TTestVerificaLookup.SenzaAlternative;
begin
  FDati.SQL_Select.Text := SelectSenzaAlternative;
  FLookup.FieldNamesFK := 'ID_INCARICO';
  FLookup.MasterFields := '';
end;

// Mantis #320 - 2026-11-04: la form di verifica di WT e Gesty non deve cambiare
procedure TTestVerificaLookup.Interruttori_SpentiDiNorma_NessunaSegnalazione;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  FLookup.MasterFields := 'INESISTENTE';
  FDominio.Lookup := 'LOOKUP_INESISTENTE';

  Esegui(nil);

  Assert.AreEqual(0, FRisultati.Count, 'con i soli interruttori di norma nessun controllo nuovo parla');
end;

procedure TTestVerificaLookup.Dizionario_Corretto_NessunControlloScatta;
begin
  ChiavePrimariaComposta;

  Esegui(
    procedure(Verificatore: TzSystemVerifier)
    begin
      Verificatore.CheckLookupGridColumns := True;
      Verificatore.CheckLookupParameters := True;
      Verificatore.CheckLookupDomainMissing := True;
      Verificatore.CheckLookupShowsKey := True;
      Verificatore.CheckLookupSearchOnKey := True;
      Verificatore.CheckLookupOrderBy := True;
      Verificatore.CheckLookupColumnsExist := True;
      Verificatore.CheckLookupCompositeKey := True;
    end);

  Assert.AreEqual(0, FRisultati.Count, 'il lookup del ticket, corretto, non deve dare segnalazioni');
end;

// Mantis #320 - 2026-11-04: vista senza colonne, il campo mostra l'id
procedure TTestVerificaLookup.VistaVuota_ChiavePrimaColonna_Errore;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';

  EseguiColonneVuote;

  Assert.AreEqual(1, Quanti(vcLookupGridColumns));
  Assert.IsTrue(GravitaDi(vcLookupGridColumns) = vsError, 'gravita''');
end;

procedure TTestVerificaLookup.VistaVuota_ConSearchFields_NonScatta;
begin
  FVista.Columns.Clear;

  EseguiColonneVuote;

  Assert.AreEqual(0, Quanti(vcLookupGridColumns));
end;

procedure TTestVerificaLookup.VistaVuota_DescrizionePrimaColonna_NonScatta;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI.NOMINATIVO, ASSISTENTI.ID_ASSISTENTE FROM ASSISTENTI ORDER BY ASSISTENTI.NOMINATIVO';

  EseguiColonneVuote;

  Assert.AreEqual(0, Quanti(vcLookupGridColumns), 'la vista si riempie dal dataset: il primo campo e'' la descrizione');
end;

// Mantis #320 - 2026-11-04: SEDE_SVOLGIMENTO e' un testo che il nome non dice se descriva
// la voce (lookup su ID_INCARICO): puo' essere un id legittimo, quindi avviso e non errore
procedure TTestVerificaLookup.VistaVuota_TestoNonRiconosciuto_SoloAvviso;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  SenzaAlternative;

  EseguiColonneVuote;

  Assert.AreEqual(1, Quanti(vcLookupGridColumns));
  Assert.IsTrue(GravitaDi(vcLookupGridColumns) = vsWarning, 'gravita'': senza un descrittivo riconosciuto e'' un avviso');
end;

procedure TTestVerificaLookup.VistaVuota_SoloCampiDiServizio_NonScatta;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  FDati.SQL_Select.Text := 'SELECT INCARICHI.ID_INCARICO, INCARICHI.CODICE_INCARICO, INCARICHI.USR_DATA_INS FROM INCARICHI ORDER BY INCARICHI.ID_INCARICO';
  FLookup.FieldNamesFK := 'ID_INCARICO';
  FLookup.MasterFields := '';

  EseguiColonneVuote;

  Assert.AreEqual(0, Quanti(vcLookupGridColumns), 'nessun testo che possa descrivere la voce: l''id e'' tutto quello che c''e''');
end;

procedure TTestVerificaLookup.VistaVuota_TestoNonRiconosciuto_SenzaInterruttore_NonScatta;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  SenzaAlternative;

  Esegui(nil);

  Assert.AreEqual(0, Quanti(vcLookupGridColumns), 'con l''interruttore spento nemmeno l''avviso nuovo parla');
end;

procedure TTestVerificaLookup.VistaVuota_CampoExistsFalse_NonScatta;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  FDominio.Exists := False;

  EseguiColonneVuote;

  Assert.AreEqual(0, Quanti(vcLookupGridColumns), 'nessun campo vivo usa il lookup');
end;

procedure TTestVerificaLookup.VistaVuota_ChiaveTestuale_NonScatta;
begin
  FVista.Columns.Clear;
  FVista.SearchFields := '';
  FLookup.FieldNamesFK := 'NOMINATIVO';
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI.NOMINATIVO FROM ASSISTENTI ORDER BY ASSISTENTI.NOMINATIVO';

  EseguiColonneVuote;

  Assert.AreEqual(0, Quanti(vcLookupGridColumns), 'una chiave di testo si legge: non e'' un id');
end;

// Mantis #320 - 2026-11-04: WHERE perso e MasterFields rimasto
procedure TTestVerificaLookup.Parametri_MasterSenzaParametro_Errore;
begin
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI_COMUNI.ID_ASSISTENTE, ASSISTENTI.NOMINATIVO FROM ASSISTENTI_COMUNI ' +
    'INNER JOIN ASSISTENTI ON ASSISTENTI.ID_ASSISTENTE = ASSISTENTI_COMUNI.ID_ASSISTENTE';

  EseguiParametri;

  Assert.AreEqual(1, Quanti(vcLookupParameters));
  Assert.IsTrue(GravitaDi(vcLookupParameters) = vsError, 'gravita''');
end;

procedure TTestVerificaLookup.Parametri_ParametroSenzaMaster_Errore;
begin
  FLookup.MasterFields := '';

  EseguiParametri;

  Assert.AreEqual(1, Quanti(vcLookupParameters), ':COMUNE_SIA non arriva da nessuna parte');
end;

procedure TTestVerificaLookup.Parametri_CampoDelMasterInesistente_Errore;
begin
  FLookup.MasterFields := 'COMUNE_SIA=CAMPO_CHE_NON_ESISTE';

  EseguiParametri;

  Assert.AreEqual(1, Quanti(vcLookupParameters), 'il parametro c''e'', il campo del master no');
end;

procedure TTestVerificaLookup.Parametri_ParametroDiversoDalCampo_NonScatta;
begin
  FDati.SQL_Select.Text := StringReplace(SelectCorretta, ':COMUNE_SIA', ':BELFIORE_SCELTO', []);
  FLookup.MasterFields := 'BELFIORE_SCELTO@COMUNE_SIA';

  EseguiParametri;

  Assert.AreEqual(0, Quanti(vcLookupParameters), 'PARAMETRO@CAMPO, la forma di TzMasterFieldsBinder');
end;

procedure TTestVerificaLookup.Parametri_SegnapostoAzienda_NonScatta;
begin
  FDati.SQL_Select.Text := StringReplace(SelectCorretta, 'ORDER BY', 'AND ASSISTENTI_COMUNI.ID_AZIENDA = :##AZIENDA_DI_LAVORO ORDER BY', []);

  EseguiParametri;

  Assert.AreEqual(0, Quanti(vcLookupParameters));
end;

procedure TTestVerificaLookup.Parametri_DataSetDiUnModulo_NonScatta;
begin
  FDati.Name := 'Interventi.lkAssistenti';
  FLookup.DataSet := 'Interventi.lkAssistenti';
  FLookup.MasterFields := '';

  EseguiParametri;

  Assert.AreEqual(0, Quanti(vcLookupParameters), 'i parametri di un dataset di modulo li assegna il DataModule');
end;

procedure TTestVerificaLookup.Parametri_ParametroInUnCommento_NonConta;
begin
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI.ID_ASSISTENTE FROM ASSISTENTI' + sLineBreak + '-- WHERE ASSISTENTI.BELFIORE = :COMUNE_SIA';

  EseguiParametri;

  Assert.AreEqual(1, Quanti(vcLookupParameters), 'un WHERE commentato non filtra');
end;

// Mantis #320 - 2026-11-04: dominio che punta a un lookup sparito
procedure TTestVerificaLookup.Dominio_LookupInesistente_Errore;
begin
  FDominio.Lookup := 'LOOKUP_INESISTENTE';

  EseguiDomini;

  Assert.AreEqual(1, Quanti(vcLookupDomainMissing));
  Assert.IsTrue(GravitaDi(vcLookupDomainMissing) = vsError, 'gravita''');
end;

procedure TTestVerificaLookup.Dominio_LookupInesistenteCampoMorto_NonScatta;
begin
  FDominio.Lookup := 'LOOKUP_INESISTENTE';
  FDominio.Exists := False;

  EseguiDomini;

  Assert.AreEqual(0, Quanti(vcLookupDomainMissing), 'i campi con Exists=false sono gia'' noti come morti');
end;

procedure TTestVerificaLookup.Dominio_ControlloNonLookup_Avviso;
begin
  FDominio.Lookup := 'LOOKUP_INESISTENTE';
  FDominio.zCtrlType := ctPickListImage;

  EseguiDomini;

  Assert.AreEqual(1, Quanti(vcLookupDomainMissing));
  Assert.IsTrue(GravitaDi(vcLookupDomainMissing) = vsWarning, 'il controllo non legge il lookup: solo un residuo');
end;

procedure TTestVerificaLookup.Dominio_LookupEsistente_NonScatta;
begin
  EseguiDomini;

  Assert.AreEqual(0, Quanti(vcLookupDomainMissing));
end;

// Mantis #320 - 2026-11-04: di norma l'id non si espone
procedure TTestVerificaLookup.ChiaveMostrata_PrimaColonnaChiave_Avviso;
begin
  FVista.Columns.Clear;
  AggiungiColonna('ID_ASSISTENTE');
  AggiungiColonna('NOMINATIVO');

  EseguiChiaveMostrata;

  Assert.AreEqual(1, Quanti(vcLookupShowsKey));
  Assert.IsTrue(GravitaDi(vcLookupShowsKey) = vsWarning, 'gravita''');
end;

procedure TTestVerificaLookup.ChiaveMostrata_SenzaAlternative_NonScatta;
begin
  SenzaAlternative;
  FVista.Columns.Clear;
  AggiungiColonna('ID_INCARICO');
  AggiungiColonna('SEDE_SVOLGIMENTO');

  EseguiChiaveMostrata;

  Assert.AreEqual(0, Quanti(vcLookupShowsKey), 'lookup su ID_INCARICO: l''id si espone');
end;

procedure TTestVerificaLookup.ChiaveMostrata_CampoExistsFalse_NonScatta;
begin
  FVista.Columns.Clear;
  AggiungiColonna('ID_ASSISTENTE');
  AggiungiColonna('NOMINATIVO');
  FDominio.Exists := False;

  EseguiChiaveMostrata;

  Assert.AreEqual(0, Quanti(vcLookupShowsKey), 'nessun campo vivo usa il lookup');
end;

procedure TTestVerificaLookup.ChiaveMostrata_ChiaveNascosta_NonScatta;
begin
  EseguiChiaveMostrata;

  Assert.AreEqual(0, Quanti(vcLookupShowsKey), 'la prima colonna visibile e'' NOMINATIVO');
end;

// Mantis #320 - 2026-11-04: SearchFields sulla chiave, digitare il cognome non trova niente
procedure TTestVerificaLookup.Ricerca_SullaChiave_Avviso;
begin
  FVista.SearchFields := 'ID_ASSISTENTE';

  EseguiRicerca;

  Assert.AreEqual(1, Quanti(vcLookupSearchOnKey));
  Assert.IsTrue(GravitaDi(vcLookupSearchOnKey) = vsWarning, 'gravita''');
end;

procedure TTestVerificaLookup.Ricerca_SullaDescrizione_NonScatta;
begin
  EseguiRicerca;

  Assert.AreEqual(0, Quanti(vcLookupSearchOnKey));
end;

procedure TTestVerificaLookup.Ricerca_SenzaAlternative_NonScatta;
begin
  SenzaAlternative;
  FVista.SearchFields := 'ID_INCARICO';

  EseguiRicerca;

  Assert.AreEqual(0, Quanti(vcLookupSearchOnKey), 'lookup su ID_INCARICO: si cerca per id');
end;

// Mantis #320 - 2026-11-04: l'elenco va ordinato per il campo mostrato
procedure TTestVerificaLookup.Ordinamento_SullaChiave_Avviso;
begin
  FDati.SQL_Select.Text := StringReplace(SelectCorretta, 'ORDER BY ASSISTENTI.NOMINATIVO', 'ORDER BY ASSISTENTI_COMUNI.ID_ASSISTENTE, ASSISTENTI.NOMINATIVO', []);

  EseguiOrdinamento;

  Assert.AreEqual(1, Quanti(vcLookupOrderBy), 'il NOMINATIVO in seconda posizione non basta');
  Assert.IsTrue(GravitaDi(vcLookupOrderBy) = vsWarning, 'gravita''');
end;

procedure TTestVerificaLookup.Ordinamento_Assente_Avviso;
begin
  FDati.SQL_Select.Text := StringReplace(SelectCorretta, 'ORDER BY ASSISTENTI.NOMINATIVO', '', []);

  EseguiOrdinamento;

  Assert.AreEqual(1, Quanti(vcLookupOrderBy));
end;

procedure TTestVerificaLookup.Ordinamento_PerPosizione_NonScatta;
begin
  FDati.SQL_Select.Text := StringReplace(SelectCorretta, 'ORDER BY ASSISTENTI.NOMINATIVO', 'ORDER BY 3', []);

  EseguiOrdinamento;

  Assert.AreEqual(0, Quanti(vcLookupOrderBy), 'la terza colonna e'' NOMINATIVO');
end;

procedure TTestVerificaLookup.Ordinamento_SuEspressione_NonScatta;
begin
  FDati.SQL_Select.Text := StringReplace(SelectCorretta, 'ORDER BY ASSISTENTI.NOMINATIVO', 'ORDER BY UPPER(ASSISTENTI.NOMINATIVO) DESC', []);

  EseguiOrdinamento;

  Assert.AreEqual(0, Quanti(vcLookupOrderBy));
end;

// Mantis #320 - 2026-11-04: colonne della vista e DisplayColumns contro la SELECT
procedure TTestVerificaLookup.Colonne_VistaConColonnaAssente_Errore;
begin
  AggiungiColonna('COLONNA_SPARITA');

  EseguiColonne;

  Assert.AreEqual(1, Quanti(vcLookupColumnsExist));
  Assert.IsTrue(GravitaDi(vcLookupColumnsExist) = vsError, 'gravita''');
end;

procedure TTestVerificaLookup.Colonne_ColonnaNascostaAssente_NonScatta;
begin
  AggiungiColonna('COLONNA_SPARITA', False);

  EseguiColonne;

  Assert.AreEqual(0, Quanti(vcLookupColumnsExist), 'ValidateDataset la toglie e nessuno la vede');
end;

procedure TTestVerificaLookup.Colonne_DisplayColumnsAssente_Errore;
begin
  FLookup.DisplayColumns := 'NOMINATIVO;COLONNA_SPARITA';

  EseguiColonne;

  Assert.AreEqual(1, Quanti(vcLookupColumnsExist));
end;

procedure TTestVerificaLookup.Colonne_PrimoDisplayNonVisibile_Errore;
begin
  FLookup.DisplayColumns := 'ID_ASSISTENTE;NOMINATIVO';

  EseguiColonne;

  Assert.AreEqual(1, Quanti(vcLookupColumnsExist), 'ID_ASSISTENTE e'' una colonna nascosta della vista');
end;

procedure TTestVerificaLookup.Colonne_AliasDellaSelect_NonScatta;
begin
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI.ID_ASSISTENTE, ASSISTENTI.NOMINATIVO AS DESCRIZIONE, ASSISTENTI.NOMINATIVO FROM ASSISTENTI';
  AggiungiColonna('DESCRIZIONE');

  EseguiColonne;

  Assert.AreEqual(0, Quanti(vcLookupColumnsExist));
end;

procedure TTestVerificaLookup.Colonne_RelazioneIgnota_NonScatta;
begin
  FDati.SQL_Select.Text := 'SELECT * FROM RELAZIONE_NON_NEL_DIZIONARIO';

  EseguiColonne;

  Assert.AreEqual(0, Quanti(vcLookupColumnsExist), 'i campi non si sanno: niente falsi allarmi');
end;

// Mantis #320 - 2026-11-04: 94 righe per 59 assistenti, chiavi ripetute nell'elenco
procedure TTestVerificaLookup.ChiaveComposta_SenzaFiltro_Avviso;
begin
  ChiavePrimariaComposta;
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI_COMUNI.ID_ASSISTENTE, ASSISTENTI_COMUNI.BELFIORE FROM ASSISTENTI_COMUNI';

  EseguiChiaveComposta;

  Assert.AreEqual(1, Quanti(vcLookupCompositeKey));
  Assert.IsTrue(GravitaDi(vcLookupCompositeKey) = vsWarning, 'gravita''');
end;

procedure TTestVerificaLookup.ChiaveComposta_ConFiltro_NonScatta;
begin
  ChiavePrimariaComposta;

  EseguiChiaveComposta;

  Assert.AreEqual(0, Quanti(vcLookupCompositeKey), 'la WHERE fissa BELFIORE: una riga per assistente');
end;

procedure TTestVerificaLookup.ChiaveComposta_Distinct_NonScatta;
begin
  ChiavePrimariaComposta;
  FDati.SQL_Select.Text := 'SELECT DISTINCT ASSISTENTI_COMUNI.ID_ASSISTENTE FROM ASSISTENTI_COMUNI';

  EseguiChiaveComposta;

  Assert.AreEqual(0, Quanti(vcLookupCompositeKey));
end;

procedure TTestVerificaLookup.ChiaveComposta_ChiaveSemplice_NonScatta;
var
  Tabella: TzmdTable;
begin
  Tabella := FSistema.MetaData.Tables.Add;
  Tabella.Name := 'ASSISTENTI_COMUNI';
  Tabella.PrimaryKey.Add.Name := 'ID_ASSISTENTE';
  FDati.SQL_Select.Text := 'SELECT ASSISTENTI_COMUNI.ID_ASSISTENTE FROM ASSISTENTI_COMUNI';

  EseguiChiaveComposta;

  Assert.AreEqual(0, Quanti(vcLookupCompositeKey));
end;

{ TTestFormaDellaSelect }

procedure TTestFormaDellaSelect.Colonne_AliasECampiQualificati;
var
  Forma: TzSqlSelectShape;
  Colonna: TzSqlSelectColumn;
begin
  Forma := TzSqlSelectShape.Parse('SELECT FIRST 10 A.ID, B.NOME AS DESCRIZIONE, C.CAMPO ETICHETTA FROM T A, U B, V C');
  try
    Assert.AreEqual(3, Forma.Columns.Count);
    Assert.IsTrue(Forma.FindColumn('DESCRIZIONE', Colonna), 'alias con AS');
    Assert.AreEqual('NOME', Colonna.FieldName);
    Assert.AreEqual('U', Forma.RelationOf(Colonna.Relation));
    Assert.IsTrue(Forma.FindColumn('ETICHETTA', Colonna), 'alias senza AS');
    Assert.AreEqual('CAMPO', Colonna.FieldName);
  finally
    Forma.Free;
  end;
end;

procedure TTestFormaDellaSelect.Colonne_EspressioneDiTesto;
var
  Forma: TzSqlSelectShape;
  Colonna: TzSqlSelectColumn;
begin
  Forma := TzSqlSelectShape.Parse('SELECT T.COGNOME || '' '' || T.NOME AS NOMINATIVO, COUNT(*) AS TOTALE FROM T');
  try
    Assert.IsTrue(Forma.FindColumn('NOMINATIVO', Colonna));
    Assert.IsTrue(Colonna.IsTextExpression, 'concatenazione');
    Assert.IsTrue(Forma.FindColumn('TOTALE', Colonna));
    Assert.IsFalse(Colonna.IsTextExpression, 'conteggio');
  finally
    Forma.Free;
  end;
end;

procedure TTestFormaDellaSelect.Relazioni_AliasEJoin;
var
  Forma: TzSqlSelectShape;
begin
  Forma := TzSqlSelectShape.Parse('SELECT * FROM T LEFT OUTER JOIN U ON U.ID = T.ID INNER JOIN V RUOLO ON RUOLO.ID = T.ID');
  try
    Assert.AreEqual(3, Forma.RelationNames.Count);
    Assert.AreEqual('V', Forma.RelationOf('RUOLO'));
  finally
    Forma.Free;
  end;
end;

procedure TTestFormaDellaSelect.Where_SoloBloccoPrincipale;
var
  Forma: TzSqlSelectShape;
begin
  Forma := TzSqlSelectShape.Parse('SELECT T.ID, (SELECT MAX(U.X) FROM U WHERE U.Y = 1) AS M FROM T WHERE T.ANNO = :ANNO GROUP BY T.ID');
  try
    Assert.IsTrue(Forma.WhereWords.IndexOf('ANNO') >= 0, 'WHERE principale');
    Assert.IsTrue(Forma.WhereWords.IndexOf('Y') < 0, 'la sottoquery delle colonne non conta');
    Assert.IsTrue(Forma.NoRepeatedRows, 'GROUP BY');
  finally
    Forma.Free;
  end;
end;

procedure TTestFormaDellaSelect.OrderBy_PrimoTermine;
var
  Forma: TzSqlSelectShape;
begin
  Forma := TzSqlSelectShape.Parse('SELECT T.A, T.B FROM T ORDER BY T.B DESC, T.A');
  try
    Assert.IsTrue(Forma.OrderByWords.IndexOf('B') >= 0);
    Assert.IsTrue(Forma.OrderByWords.IndexOf('A') < 0, 'solo il primo termine');
  finally
    Forma.Free;
  end;
end;

procedure TTestFormaDellaSelect.Commenti_NonContano;
var
  Forma: TzSqlSelectShape;
begin
  Forma := TzSqlSelectShape.Parse('SELECT T.A FROM T -- WHERE T.B = 1' + sLineBreak + '/* ORDER BY T.A */');
  try
    Assert.AreEqual(0, Forma.WhereWords.Count);
    Assert.AreEqual(0, Forma.OrderByWords.Count);
  finally
    Forma.Free;
  end;
end;

procedure TTestFormaDellaSelect.TabellaDerivata_FormaIncompleta;
var
  Forma: TzSqlSelectShape;
begin
  Forma := TzSqlSelectShape.Parse('SELECT D.A FROM (SELECT T.A FROM T) D');
  try
    Assert.IsFalse(Forma.Complete);
  finally
    Forma.Free;
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TTestVerificaLookup);
TDUnitX.RegisterTestFixture(TTestFormaDellaSelect);

end.
