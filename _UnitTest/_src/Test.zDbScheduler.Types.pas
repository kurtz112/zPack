// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-12
// ---------------------------------------------------------------------------
unit Test.zDbScheduler.Types;

// Test DUnitX per zDbScheduler.Types (TzDbScheduler): appunti del copia e
// incolla, parametri di un evento, registro dei tipi di evento, aggancio
// dello storage allo schema delegato e calcoli del frame (TzSchedulerCalcoli:
// momento del nuovo evento, periodo letto dal database, fascia oraria,
// eventi entro la giornata).
//
// TzSchedulerEvents e' un registro globale che non si svuota: ogni test usa
// codici propri col prefisso 'ZT' e non conta il numero totale dei tipi.
// Il TcxSchedulerDBStorage si crea senza dataset e senza calendario: serve
// solo per leggere campi personalizzati, nomi dei campi e gestori agganciati.

interface

uses
  System.SysUtils,
  System.Variants,
  System.DateUtils,
  DUnitX.TestFramework,
  cxSchedulerStorage,
  cxSchedulerDBStorage,
  zDbScheduler.Types;

type
  [TestFixture]
  TTestCopiaIncolla = class
  public
    [Test]
    procedure Reset_Nulla;
    [Test]
    procedure TagliaOra_RicordaLOra;
    [Test]
    procedure CopiaOra_RicordaLOra;
    [Test]
    procedure CopiaGiorno_RicordaLaData_DimenticaLOra;
    [Test]
    procedure CopiaSettimana_RicordaLaData;
    [Test]
    procedure Reset_NonToccaEnabled;
  end;

  [TestFixture]
  TTestSchedulerEventParams = class
  public
    [Test]
    procedure Init_ValoriVuoti;
    [Test]
    procedure Durata_ConOraInizio_CalcolaOraFine;
    [Test]
    procedure OraFine_ConOraInizio_CalcolaDurata;
    [Test]
    procedure Durata_DopoInit_ParteDaMezzanotte;
    [Test]
    procedure Durata_InizioAMezzanotte_CalcolaOraFine;
    [Test]
    procedure OraFine_InizioAMezzanotte_CalcolaDurata;
  end;

  [TestFixture]
  TTestSchedulerCalcoli = class
  public
    // momento del nuovo evento (Mantis Gesty #197)
    [Test]
    procedure Momento_CellaConDataEOra_ValeIlPuntoCliccato;
    [Test]
    procedure Momento_IntestazioneRisorsa_ValeLaCellaSelezionata;
    [Test]
    procedure Momento_DataNullaAncheSuCella_ValeLaCellaSelezionata;
    [Test]
    procedure Momento_RighelloSolaOra_ValeLaCellaSelezionata;
    [Test]
    procedure Momento_NessunaCellaSelezionata_False;
    [Test]
    procedure Momento_VistaMese_MezzanotteConOraFine;

    // periodo letto dal database
    [Test]
    procedure Periodo_SettimanaDiMarginePerParte;
    [Test]
    procedure Periodo_Mese_DaSettimanaASettimana;
    [Test]
    procedure Periodo_MaiLetto_DaLeggere;
    [Test]
    procedure Periodo_GiaCoperto_NonSiRilegge;
    [Test]
    procedure Periodo_SettimanaDopo_SiRilegge;
    [Test]
    procedure Periodo_DataSetChiuso_SiRilegge;

    // fascia oraria visibile
    [Test]
    procedure Fascia_EventoDentro_NonCambia;
    [Test]
    procedure Fascia_EventoPrimaEDopo_Allarga;
    [Test]
    procedure Fascia_GiornoIntero_NonConta;
    [Test]
    procedure Fascia_FineAMezzanotte_FineGiornata;
    [Test]
    procedure Fascia_PiuGiorni_GiornataIntera;
    [Test]
    procedure Fascia_Arrotonda_AlleMezzOreEsterne;
    [Test]
    procedure Fascia_MezzOreEsatte_Restano;
    [Test]
    procedure Fascia_FineOltreLUltimaMezzOra_FineGiornata;

    // eventi entro la giornata (R-087)
    [Test]
    procedure Mezzanotte_DentroLaGiornata_NonSupera;
    [Test]
    procedure Mezzanotte_FineAlle24Esatte_NonSupera;
    [Test]
    procedure Mezzanotte_FineAlle0030_Supera;
    [Test]
    procedure Entro_DentroLaGiornata_NonCambia;
    [Test]
    procedure Entro_OltreLaMezzanotte_FineAlle2359;
    [Test]
    procedure Entro_FineAlle24Esatte_FineAlle2359;
    [Test]
    procedure Entro_InizioAlle2359_DurataZero;
    [Test]
    procedure Entro_OraLettaConErrore_FineAlle2359;
    [Test]
    procedure DurataEvento_Normale;
    [Test]
    procedure DurataEvento_FineAlle2359_ContaComeMezzanotte;
    [Test]
    procedure DurataEvento_FineAlle00StessoGiorno_FinoAMezzanotte;
    [Test]
    procedure DurataEvento_FineAMezzanotteDelGiornoDopo;
  end;

  [TestFixture]
  TTestSchedulerParams = class
  public
    [Test]
    procedure Init_AzzeraPeriodoEOrari;
    [Test]
    procedure SetAfterRefreshScheduler_Assegna;
  end;

  [TestFixture]
  TTestSchedulerEventKind = class
  public
    [Test]
    procedure Create_ValoriPredefiniti;
  end;

  [TestFixture]
  TTestSchedulerEvents = class
  public
    [Test]
    procedure Register_RestituisceIlTipo;
    [Test]
    procedure Find_SenzaDistinzioneMaiuscole;
    [Test]
    procedure Find_CodiceVuotoOSconosciuto_Nil;
    [Test]
    procedure Register_StessoCodice_RiprendeEAggiorna;
    [Test]
    procedure Kinds_OrdineDiRegistrazione;
    [Test]
    procedure CanIntersect_NessunoLAmmette_False;
    [Test]
    procedure CanIntersect_UnoLAmmette_True;
    [Test]
    procedure CanIntersect_TipoSconosciutoEUnoCheLAmmette_True;
    [Test]
    procedure CanIntersect_DueSconosciuti_False;
    [Test]
    procedure Apri_ChiamaIlGestoreDelTipo;
    [Test]
    procedure Sposta_Elimina_GestoriDistinti;
    [Test]
    procedure Apri_TipoSenzaGestore_False;
    [Test]
    procedure Apri_TipoSconosciuto_False;
  end;

  [TestFixture]
  TTestSchedulerStorageBinder = class
  private
    FStorage: TcxSchedulerDBStorage;
    function Occorrenze(const FieldName: string): Integer;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure InitDelegated_StorageNil_NessunErrore;
    [Test]
    procedure InitDelegated_NomiDeiCampiDellaProcedura;
    [Test]
    procedure InitDelegated_CampiPersonalizzatiDiBase;
    [Test]
    procedure InitDelegated_ChiaviDeiTipi_UnaSolaVolta;
    [Test]
    procedure InitDelegated_CampiAggiuntivi_SenzaDoppioni;
    [Test]
    procedure InitDelegated_DueVolte_NessunDoppione;
    [Test]
    procedure InitDelegated_LoStorageNonScriveMai;
    [Test]
    procedure InitDelegated_SovrapposizioneSenzaTipo_Negata;
  end;

  [TestFixture]
  TTestSchedulerEventValue = class
  public
    [Test]
    procedure EventoNil_Null;
  end;

implementation

{ TTestCopiaIncolla }

procedure TTestCopiaIncolla.Reset_Nulla;
var
  Appunti: TzCopiaIncolla;
begin
  Appunti.Reset;

  Assert.IsTrue(Appunti.Tipo = ciNulla);
  Assert.AreEqual(-1, Appunti.IdOra);
  Assert.AreEqual(Double(0), Double(Appunti.Data));
end;

procedure TTestCopiaIncolla.TagliaOra_RicordaLOra;
var
  Appunti: TzCopiaIncolla;
begin
  Appunti.Reset;
  Appunti.TagliaOra(42);

  Assert.IsTrue(Appunti.Tipo = ciTagliaOra);
  Assert.AreEqual(42, Appunti.IdOra);
end;

procedure TTestCopiaIncolla.CopiaOra_RicordaLOra;
var
  Appunti: TzCopiaIncolla;
begin
  Appunti.Reset;
  Appunti.CopiaOra(7);

  Assert.IsTrue(Appunti.Tipo = ciCopiaOra);
  Assert.AreEqual(7, Appunti.IdOra);
end;

procedure TTestCopiaIncolla.CopiaGiorno_RicordaLaData_DimenticaLOra;
var
  Appunti: TzCopiaIncolla;
begin
  // ogni operazione riparte da zero: l'ora copiata prima non resta appesa
  Appunti.Reset;
  Appunti.CopiaOra(7);
  Appunti.CopiaGiorno(EncodeDate(2026, 10, 5));

  Assert.IsTrue(Appunti.Tipo = ciCopiaGiorno);
  Assert.AreEqual(-1, Appunti.IdOra);
  Assert.AreEqual(Double(EncodeDate(2026, 10, 5)), Double(Appunti.Data));
end;

procedure TTestCopiaIncolla.CopiaSettimana_RicordaLaData;
var
  Appunti: TzCopiaIncolla;
begin
  Appunti.Reset;
  Appunti.CopiaSettimana(EncodeDate(2026, 10, 5));

  Assert.IsTrue(Appunti.Tipo = ciCopiaSettimana);
  Assert.AreEqual(Double(EncodeDate(2026, 10, 5)), Double(Appunti.Data));
end;

procedure TTestCopiaIncolla.Reset_NonToccaEnabled;
var
  Appunti: TzCopiaIncolla;
begin
  // Enabled lo governa il frame (azione Incolla), non il contenuto degli appunti
  Appunti.Enabled := True;
  Appunti.Reset;

  Assert.IsTrue(Appunti.Enabled);
end;

{ TTestSchedulerEventParams }

procedure TTestSchedulerEventParams.Init_ValoriVuoti;
var
  Params: TzSchedulerEventParams;
begin
  Params.Init;

  Assert.AreEqual('', Params.Kind);
  Assert.IsFalse(Params.ReadOnly);
  Assert.AreEqual(-1, Params.Id);
  Assert.AreEqual(0, Params.Durata);
  Assert.AreEqual(Double(0), Double(Params.OraFine));
  Assert.IsTrue(VarIsNull(Params.ResourceID));
  Assert.AreEqual('', Params.ResourceFieldName);
  Assert.IsTrue(VarIsNull(Params.Value1));
  Assert.IsTrue(VarIsNull(Params.Value5));
end;

procedure TTestSchedulerEventParams.Durata_ConOraInizio_CalcolaOraFine;
var
  Params: TzSchedulerEventParams;
begin
  Params.Init;
  Params.OraInizio := EncodeTime(9, 0, 0, 0);
  Params.Durata := 90;

  Assert.AreEqual(Double(EncodeTime(10, 30, 0, 0)), Double(Params.OraFine), OneSecond);
end;

procedure TTestSchedulerEventParams.OraFine_ConOraInizio_CalcolaDurata;
var
  Params: TzSchedulerEventParams;
begin
  Params.Init;
  Params.OraInizio := EncodeTime(9, 0, 0, 0);
  Params.OraFine := EncodeTime(11, 0, 0, 0);

  Assert.AreEqual(120, Params.Durata);
end;

procedure TTestSchedulerEventParams.Durata_DopoInit_ParteDaMezzanotte;
var
  Params: TzSchedulerEventParams;
begin
  // dal 2026-10-12 la mezzanotte e' un'ora vera: dopo Init l'ora di inizio e'
  // 00:00 e la durata calcola l'ora di fine da li' (prima OraFine restava 0)
  Params.Init;
  Params.Durata := 60;

  Assert.AreEqual(60, Params.Durata);
  Assert.AreEqual(Double(EncodeTime(1, 0, 0, 0)), Double(Params.OraFine), OneSecond);
end;

procedure TTestSchedulerEventParams.Durata_InizioAMezzanotte_CalcolaOraFine;
var
  Params: TzSchedulerEventParams;
begin
  // evento nuovo dalla vista mese: SelStart porta la sola data
  Params.Init;
  Params.OraInizio := EncodeTime(0, 0, 0, 0);
  Params.Durata := 60;

  Assert.AreEqual(Double(EncodeTime(1, 0, 0, 0)), Double(Params.OraFine), OneSecond);
end;

procedure TTestSchedulerEventParams.OraFine_InizioAMezzanotte_CalcolaDurata;
var
  Params: TzSchedulerEventParams;
begin
  Params.Init;
  Params.OraInizio := EncodeTime(0, 0, 0, 0);
  Params.OraFine := EncodeTime(1, 30, 0, 0);

  Assert.AreEqual(90, Params.Durata);
end;

{ TTestSchedulerCalcoli }

const
  // NullDate di DevExpress: HitTest.Time fuori dalle celle che portano una data
  DataNulla = -700000;

procedure TTestSchedulerCalcoli.Momento_CellaConDataEOra_ValeIlPuntoCliccato;
var
  Momento: TDateTime;
begin
  Assert.IsTrue(TzSchedulerCalcoli.MomentoNuovoEvento(True, EncodeDateTime(2026, 10, 12, 9, 30, 0, 0),
    EncodeDateTime(2026, 10, 14, 15, 0, 0, 0), Momento));
  Assert.AreEqual(Double(EncodeDateTime(2026, 10, 12, 9, 30, 0, 0)), Double(Momento), OneSecond);
end;

procedure TTestSchedulerCalcoli.Momento_IntestazioneRisorsa_ValeLaCellaSelezionata;
var
  Momento: TDateTime;
begin
  // il caso del ticket 197: clic destro sull'intestazione dell'aula
  Assert.IsTrue(TzSchedulerCalcoli.MomentoNuovoEvento(False, DataNulla, EncodeDateTime(2026, 10, 12, 10, 0, 0, 0),
    Momento));
  Assert.AreEqual(Double(EncodeDateTime(2026, 10, 12, 10, 0, 0, 0)), Double(Momento), OneSecond);
end;

procedure TTestSchedulerCalcoli.Momento_DataNullaAncheSuCella_ValeLaCellaSelezionata;
var
  Momento: TDateTime;
begin
  Assert.IsTrue(TzSchedulerCalcoli.MomentoNuovoEvento(True, DataNulla, EncodeDateTime(2026, 10, 12, 10, 0, 0, 0),
    Momento));
  Assert.AreEqual(Double(EncodeDateTime(2026, 10, 12, 10, 0, 0, 0)), Double(Momento), OneSecond);
end;

procedure TTestSchedulerCalcoli.Momento_RighelloSolaOra_ValeLaCellaSelezionata;
var
  Momento: TDateTime;
begin
  // sul righello HitTest.Time porta l'ora senza data (giorno 0)
  Assert.IsTrue(TzSchedulerCalcoli.MomentoNuovoEvento(True, EncodeTime(9, 0, 0, 0),
    EncodeDateTime(2026, 10, 12, 11, 0, 0, 0), Momento));
  Assert.AreEqual(Double(EncodeDateTime(2026, 10, 12, 11, 0, 0, 0)), Double(Momento), OneSecond);
end;

procedure TTestSchedulerCalcoli.Momento_NessunaCellaSelezionata_False;
var
  Momento: TDateTime;
begin
  Assert.IsFalse(TzSchedulerCalcoli.MomentoNuovoEvento(False, DataNulla, 0, Momento));
  Assert.IsFalse(TzSchedulerCalcoli.MomentoNuovoEvento(False, DataNulla, DataNulla, Momento));
  Assert.IsFalse(TzSchedulerCalcoli.MomentoNuovoEvento(True, EncodeTime(9, 0, 0, 0), EncodeTime(10, 0, 0, 0), Momento));
end;

procedure TTestSchedulerCalcoli.Momento_VistaMese_MezzanotteConOraFine;
var
  Momento: TDateTime;
  Params: TzSchedulerEventParams;
begin
  // vista mese: la cella porta la sola data, l'evento parte a mezzanotte;
  // stessa sequenza di TzDbScheduler.NuovoEvento
  Assert.IsTrue(TzSchedulerCalcoli.MomentoNuovoEvento(False, DataNulla, EncodeDate(2026, 10, 12), Momento));

  Params.Init;
  Params.Data := DateOf(Momento);
  Params.OraInizio := TimeOf(Momento);
  Params.Durata := 60;

  Assert.AreEqual(Double(EncodeDate(2026, 10, 12)), Double(Params.Data), OneSecond);
  Assert.AreEqual(Double(0), Double(Params.OraInizio), OneSecond);
  Assert.AreEqual(Double(EncodeTime(1, 0, 0, 0)), Double(Params.OraFine), OneSecond);
end;

procedure TTestSchedulerCalcoli.Periodo_SettimanaDiMarginePerParte;
var
  Dal, Al: TDateTime;
begin
  // mercoledi' 14 ottobre 2026: settimana da lunedi' 12 a domenica 18
  TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 14), EncodeDate(2026, 10, 14), False, False, 0, 0, Dal, Al);

  Assert.AreEqual(Double(EncodeDate(2026, 10, 5)), Double(Dal), OneSecond);
  Assert.AreEqual(Double(EncodeDate(2026, 10, 25)), Double(DateOf(Al)), OneSecond);
  // la fine e' l'ultimo istante della domenica, non la mezzanotte
  Assert.IsTrue(Al > EncodeDateTime(2026, 10, 25, 23, 59, 59, 0));
end;

procedure TTestSchedulerCalcoli.Periodo_Mese_DaSettimanaASettimana;
var
  Dal, Al: TDateTime;
begin
  // ottobre 2026: giovedi' 1 - sabato 31
  TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 1), EncodeDate(2026, 10, 31), False, False, 0, 0, Dal, Al);

  Assert.AreEqual(Double(EncodeDate(2026, 9, 21)), Double(Dal), OneSecond);
  Assert.AreEqual(Double(EncodeDate(2026, 11, 8)), Double(DateOf(Al)), OneSecond);
end;

procedure TTestSchedulerCalcoli.Periodo_MaiLetto_DaLeggere;
var
  Dal, Al: TDateTime;
begin
  // anche con un periodo che lo conterrebbe: senza PeriodoValido si legge
  Assert.IsTrue(TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 14), EncodeDate(2026, 10, 14), False, True,
    EncodeDate(2026, 1, 1), EncodeDate(2026, 12, 31), Dal, Al));
end;

procedure TTestSchedulerCalcoli.Periodo_GiaCoperto_NonSiRilegge;
var
  PeriodoDal, PeriodoAl, Dal, Al: TDateTime;
begin
  // prima lettura: settimana del 14 ottobre
  Assert.IsTrue(TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 14), EncodeDate(2026, 10, 14), False, False,
    0, 0, PeriodoDal, PeriodoAl));

  // stessa settimana, un altro giorno: periodo identico, gia' letto
  Assert.IsFalse(TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 16), EncodeDate(2026, 10, 16), True, True,
    PeriodoDal, PeriodoAl, Dal, Al));
end;

procedure TTestSchedulerCalcoli.Periodo_SettimanaDopo_SiRilegge;
var
  PeriodoDal, PeriodoAl, Dal, Al: TDateTime;
begin
  TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 14), EncodeDate(2026, 10, 14), False, False, 0, 0,
    PeriodoDal, PeriodoAl);

  // la settimana dopo chiede una settimana di margine oltre quella letta
  Assert.IsTrue(TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 21), EncodeDate(2026, 10, 21), True, True,
    PeriodoDal, PeriodoAl, Dal, Al));
  Assert.AreEqual(Double(EncodeDate(2026, 10, 12)), Double(Dal), OneSecond);
  Assert.AreEqual(Double(EncodeDate(2026, 11, 1)), Double(DateOf(Al)), OneSecond);
end;

procedure TTestSchedulerCalcoli.Periodo_DataSetChiuso_SiRilegge;
var
  PeriodoDal, PeriodoAl, Dal, Al: TDateTime;
begin
  TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 14), EncodeDate(2026, 10, 14), False, False, 0, 0,
    PeriodoDal, PeriodoAl);

  Assert.IsTrue(TzSchedulerCalcoli.PeriodoDaLeggere(EncodeDate(2026, 10, 14), EncodeDate(2026, 10, 14), True, False,
    PeriodoDal, PeriodoAl, Dal, Al));
end;

procedure TTestSchedulerCalcoli.Fascia_EventoDentro_NonCambia;
var
  Inizio, Fine: Double;
begin
  Inizio := EncodeTime(8, 0, 0, 0);
  Fine := EncodeTime(18, 0, 0, 0);

  TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, EncodeDateTime(2026, 10, 12, 9, 0, 0, 0),
    EncodeDateTime(2026, 10, 12, 10, 0, 0, 0), False);

  Assert.AreEqual(Double(EncodeTime(8, 0, 0, 0)), Inizio, OneSecond);
  Assert.AreEqual(Double(EncodeTime(18, 0, 0, 0)), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_EventoPrimaEDopo_Allarga;
var
  Inizio, Fine: Double;
begin
  Inizio := EncodeTime(8, 0, 0, 0);
  Fine := EncodeTime(18, 0, 0, 0);

  TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, EncodeDateTime(2026, 10, 12, 7, 15, 0, 0),
    EncodeDateTime(2026, 10, 12, 8, 0, 0, 0), False);
  TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, EncodeDateTime(2026, 10, 13, 17, 0, 0, 0),
    EncodeDateTime(2026, 10, 13, 23, 30, 0, 0), False);

  Assert.AreEqual(Double(EncodeTime(7, 15, 0, 0)), Inizio, OneSecond);
  Assert.AreEqual(Double(EncodeTime(23, 30, 0, 0)), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_GiornoIntero_NonConta;
var
  Inizio, Fine: Double;
begin
  Inizio := EncodeTime(8, 0, 0, 0);
  Fine := EncodeTime(18, 0, 0, 0);

  TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, EncodeDate(2026, 10, 12), EncodeDate(2026, 10, 14), True);

  Assert.AreEqual(Double(EncodeTime(8, 0, 0, 0)), Inizio, OneSecond);
  Assert.AreEqual(Double(EncodeTime(18, 0, 0, 0)), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_FineAMezzanotte_FineGiornata;
var
  Inizio, Fine: Double;
begin
  Inizio := EncodeTime(8, 0, 0, 0);
  Fine := EncodeTime(18, 0, 0, 0);

  // 22:00 - 00:00 del giorno dopo: non e' un evento di due giorni
  TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, EncodeDateTime(2026, 10, 12, 22, 0, 0, 0),
    EncodeDate(2026, 10, 13), False);

  Assert.AreEqual(Double(EncodeTime(8, 0, 0, 0)), Inizio, OneSecond);
  Assert.AreEqual(Double(TzSchedulerCalcoli.FineGiornata), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_PiuGiorni_GiornataIntera;
var
  Inizio, Fine: Double;
begin
  Inizio := EncodeTime(8, 0, 0, 0);
  Fine := EncodeTime(18, 0, 0, 0);

  // finisce il giorno dopo ma non a mezzanotte
  TzSchedulerCalcoli.AllargaFasciaAllEvento(Inizio, Fine, EncodeDateTime(2026, 10, 12, 23, 0, 0, 0),
    EncodeDateTime(2026, 10, 13, 1, 0, 0, 0), False);

  Assert.AreEqual(Double(0), Inizio, OneSecond);
  Assert.AreEqual(Double(TzSchedulerCalcoli.FineGiornata), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_Arrotonda_AlleMezzOreEsterne;
var
  Inizio, Fine: Double;
begin
  Inizio := EncodeTime(7, 15, 0, 0);
  Fine := EncodeTime(19, 10, 0, 0);

  TzSchedulerCalcoli.ArrotondaFasciaAMezzOre(Inizio, Fine);

  Assert.AreEqual(Double(EncodeTime(7, 0, 0, 0)), Inizio, OneSecond);
  Assert.AreEqual(Double(EncodeTime(19, 30, 0, 0)), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_MezzOreEsatte_Restano;
var
  Inizio, Fine: Double;
begin
  // EncodeTime non da' multipli esatti di 1/48: il margine deve assorbirlo
  Inizio := EncodeTime(8, 30, 0, 0);
  Fine := EncodeTime(17, 30, 0, 0);

  TzSchedulerCalcoli.ArrotondaFasciaAMezzOre(Inizio, Fine);

  Assert.AreEqual(Double(EncodeTime(8, 30, 0, 0)), Inizio, OneSecond);
  Assert.AreEqual(Double(EncodeTime(17, 30, 0, 0)), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Fascia_FineOltreLUltimaMezzOra_FineGiornata;
var
  Inizio, Fine: Double;
begin
  // 23:45 andrebbe a mezzanotte: si ferma all'ultimo minuto del giorno
  Inizio := EncodeTime(8, 0, 0, 0);
  Fine := EncodeTime(23, 45, 0, 0);

  TzSchedulerCalcoli.ArrotondaFasciaAMezzOre(Inizio, Fine);

  Assert.AreEqual(Double(TzSchedulerCalcoli.FineGiornata), Fine, OneSecond);
end;

procedure TTestSchedulerCalcoli.Mezzanotte_DentroLaGiornata_NonSupera;
begin
  Assert.IsFalse(TzSchedulerCalcoli.SuperaLaMezzanotte(EncodeTime(22, 0, 0, 0), 60));
end;

procedure TTestSchedulerCalcoli.Mezzanotte_FineAlle24Esatte_NonSupera;
begin
  Assert.IsFalse(TzSchedulerCalcoli.SuperaLaMezzanotte(EncodeTime(23, 0, 0, 0), 60));
end;

procedure TTestSchedulerCalcoli.Mezzanotte_FineAlle0030_Supera;
begin
  // il caso di R-087: 23:30 per un'ora
  Assert.IsTrue(TzSchedulerCalcoli.SuperaLaMezzanotte(EncodeTime(23, 30, 0, 0), 60));
end;

procedure TTestSchedulerCalcoli.Entro_DentroLaGiornata_NonCambia;
begin
  Assert.AreEqual(90, TzSchedulerCalcoli.DurataEntroLaGiornata(EncodeTime(9, 0, 0, 0), 90));
end;

procedure TTestSchedulerCalcoli.Entro_OltreLaMezzanotte_FineAlle2359;
var
  Params: TzSchedulerEventParams;
begin
  Assert.AreEqual(29, TzSchedulerCalcoli.DurataEntroLaGiornata(EncodeTime(23, 30, 0, 0), 60));

  // come la usa il frame: la fine dei parametri diventa 23:59
  Params.Init;
  Params.OraInizio := EncodeTime(23, 30, 0, 0);
  Params.Durata := TzSchedulerCalcoli.DurataEntroLaGiornata(Params.OraInizio, 60);
  Assert.AreEqual(Double(TzSchedulerCalcoli.FineGiornata), Double(Params.OraFine), OneSecond);
end;

procedure TTestSchedulerCalcoli.Entro_FineAlle24Esatte_FineAlle2359;
begin
  // 00:00 vale durata zero per MINUTES_BETWEEN, 23:59 vale la mezzanotte
  Assert.AreEqual(59, TzSchedulerCalcoli.DurataEntroLaGiornata(EncodeTime(23, 0, 0, 0), 60));
end;

procedure TTestSchedulerCalcoli.Entro_InizioAlle2359_DurataZero;
begin
  Assert.AreEqual(0, TzSchedulerCalcoli.DurataEntroLaGiornata(EncodeTime(23, 59, 0, 0), 60));
end;

procedure TTestSchedulerCalcoli.Entro_OraLettaConErrore_FineAlle2359;
begin
  // 23:30 letta da un campo TIME con un millesimo in meno
  Assert.AreEqual(29, TzSchedulerCalcoli.DurataEntroLaGiornata(EncodeTime(23, 30, 0, 0) - OneMillisecond, 60));
end;

procedure TTestSchedulerCalcoli.DurataEvento_Normale;
begin
  Assert.AreEqual(90, TzSchedulerCalcoli.DurataEvento(EncodeDateTime(2026, 10, 12, 9, 0, 0, 0),
    EncodeDateTime(2026, 10, 12, 10, 30, 0, 0)));
end;

procedure TTestSchedulerCalcoli.DurataEvento_FineAlle2359_ContaComeMezzanotte;
begin
  Assert.AreEqual(60, TzSchedulerCalcoli.DurataEvento(EncodeDateTime(2026, 10, 12, 23, 0, 0, 0),
    EncodeDateTime(2026, 10, 12, 23, 59, 0, 0)));
end;

procedure TTestSchedulerCalcoli.DurataEvento_FineAlle00StessoGiorno_FinoAMezzanotte;
begin
  // FINE = DATA + ORA_FINE con ORA_FINE = 00:00 (PRENOTAZIONI_SCHEDULER di WT)
  Assert.AreEqual(60, TzSchedulerCalcoli.DurataEvento(EncodeDateTime(2026, 10, 12, 23, 0, 0, 0),
    EncodeDateTime(2026, 10, 12, 0, 0, 0, 0)));
end;

procedure TTestSchedulerCalcoli.DurataEvento_FineAMezzanotteDelGiornoDopo;
begin
  Assert.AreEqual(60, TzSchedulerCalcoli.DurataEvento(EncodeDateTime(2026, 10, 12, 23, 0, 0, 0),
    EncodeDateTime(2026, 10, 13, 0, 0, 0, 0)));
end;

{ TTestSchedulerParams }

procedure TTestSchedulerParams.Init_AzzeraPeriodoEOrari;
var
  Params: TzSchedulerParams;
begin
  Params.DalGiorno := Date;
  Params.OraFine := EncodeTime(20, 0, 0, 0);
  Params.Init(nil);

  Assert.IsNull(Params.Storage);
  Assert.AreEqual(Double(0), Double(Params.DalGiorno));
  Assert.AreEqual(Double(0), Double(Params.AlGiorno));
  Assert.AreEqual(Double(0), Double(Params.OraInizio));
  Assert.AreEqual(Double(0), Double(Params.OraFine));
  Assert.IsFalse(Assigned(Params.AfterRefreshScheduler));
end;

procedure TTestSchedulerParams.SetAfterRefreshScheduler_Assegna;
var
  Params: TzSchedulerParams;
  Chiamato: Boolean;
begin
  Chiamato := False;
  Params.Init(nil);
  Params.SetAfterRefreshScheduler(
    procedure
    begin
      Chiamato := True;
    end);

  Assert.IsTrue(Assigned(Params.AfterRefreshScheduler));
  Params.AfterRefreshScheduler();
  Assert.IsTrue(Chiamato);
end;

{ TTestSchedulerEventKind }

procedure TTestSchedulerEventKind.Create_ValoriPredefiniti;
var
  Kind: TzSchedulerEventKind;
begin
  Kind := TzSchedulerEventKind.Create('L');
  try
    Assert.AreEqual('L', Kind.Code);
    Assert.AreEqual('L', Kind.Description);
    Assert.AreEqual('', Kind.NewCaption);
    Assert.AreEqual('', Kind.IdFieldName);
    Assert.AreEqual(-1, Kind.NewImageIndex);
    Assert.AreEqual(-1, Kind.EventImageIndex);
    Assert.AreEqual(60, Kind.DefaultDuration);
    Assert.IsFalse(Kind.IntersectionAllowed);
    Assert.AreEqual('', Kind.InsertKind);
    Assert.IsFalse(Assigned(Kind.Apri));
    Assert.IsFalse(Assigned(Kind.Sposta));
    Assert.IsFalse(Assigned(Kind.Elimina));
  finally
    Kind.Free;
  end;
end;

{ TTestSchedulerEvents }

procedure TTestSchedulerEvents.Register_RestituisceIlTipo;
var
  Kind: TzSchedulerEventKind;
begin
  Kind := TzSchedulerEvents.Register('ZTR1', 'Lezione di prova', 'ID_ORARIO');

  Assert.IsNotNull(Kind);
  Assert.AreEqual('ZTR1', Kind.Code);
  Assert.AreEqual('Lezione di prova', Kind.Description);
  Assert.AreEqual('ID_ORARIO', Kind.IdFieldName);
end;

procedure TTestSchedulerEvents.Find_SenzaDistinzioneMaiuscole;
var
  Kind: TzSchedulerEventKind;
begin
  Kind := TzSchedulerEvents.Register('ztf1', 'Prenotazione', 'ID_PRENOTAZIONE');

  Assert.AreSame(Kind, TzSchedulerEvents.Find('ZTF1'));
  Assert.AreSame(Kind, TzSchedulerEvents.Find('ztf1'));
end;

procedure TTestSchedulerEvents.Find_CodiceVuotoOSconosciuto_Nil;
begin
  Assert.IsNull(TzSchedulerEvents.Find(''));
  Assert.IsNull(TzSchedulerEvents.Find('ZT_MAI_REGISTRATO'));
end;

procedure TTestSchedulerEvents.Register_StessoCodice_RiprendeEAggiorna;
var
  Primo, Secondo: TzSchedulerEventKind;
begin
  Primo := TzSchedulerEvents.Register('ZTU1', 'Vecchia', 'ID_VECCHIO');
  Primo.DefaultDuration := 45;
  Secondo := TzSchedulerEvents.Register('ztu1', 'Nuova', 'ID_NUOVO');

  // stesso oggetto: le impostazioni gia' date restano, descrizione e chiave cambiano
  Assert.AreSame(Primo, Secondo);
  Assert.AreEqual('Nuova', Secondo.Description);
  Assert.AreEqual('ID_NUOVO', Secondo.IdFieldName);
  Assert.AreEqual(45, Secondo.DefaultDuration);
end;

procedure TTestSchedulerEvents.Kinds_OrdineDiRegistrazione;
var
  Kinds: TArray<TzSchedulerEventKind>;
  i, PosizioneA, PosizioneB: Integer;
begin
  // e' l'ordine delle azioni di inserimento nel calendario
  TzSchedulerEvents.Register('ZTK_B', 'B', 'ID_B');
  TzSchedulerEvents.Register('ZTK_A', 'A', 'ID_A');

  Kinds := TzSchedulerEvents.Kinds;
  PosizioneA := -1;
  PosizioneB := -1;

  for i := 0 to High(Kinds) do
    if SameText(Kinds[i].Code, 'ZTK_A') then
      PosizioneA := i
    else
      if SameText(Kinds[i].Code, 'ZTK_B') then
        PosizioneB := i;

  Assert.IsTrue(PosizioneB >= 0, 'ZTK_B assente');
  Assert.IsTrue(PosizioneA > PosizioneB, 'ordine alfabetico al posto di quello di registrazione');
end;

procedure TTestSchedulerEvents.CanIntersect_NessunoLAmmette_False;
begin
  TzSchedulerEvents.Register('ZTI_NO1', 'a', 'ID_A').IntersectionAllowed := False;
  TzSchedulerEvents.Register('ZTI_NO2', 'b', 'ID_B').IntersectionAllowed := False;

  Assert.IsFalse(TzSchedulerEvents.CanIntersect('ZTI_NO1', 'ZTI_NO2'));
  Assert.IsFalse(TzSchedulerEvents.CanIntersect('ZTI_NO1', 'ZTI_NO1'));
end;

procedure TTestSchedulerEvents.CanIntersect_UnoLAmmette_True;
begin
  TzSchedulerEvents.Register('ZTI_SI', 'a', 'ID_A').IntersectionAllowed := True;
  TzSchedulerEvents.Register('ZTI_NO3', 'b', 'ID_B').IntersectionAllowed := False;

  Assert.IsTrue(TzSchedulerEvents.CanIntersect('ZTI_SI', 'ZTI_NO3'));
  Assert.IsTrue(TzSchedulerEvents.CanIntersect('ZTI_NO3', 'ZTI_SI'));
end;

procedure TTestSchedulerEvents.CanIntersect_TipoSconosciutoEUnoCheLAmmette_True;
begin
  TzSchedulerEvents.Register('ZTI_SI2', 'a', 'ID_A').IntersectionAllowed := True;

  Assert.IsTrue(TzSchedulerEvents.CanIntersect('ZTI_SI2', ''));
end;

procedure TTestSchedulerEvents.CanIntersect_DueSconosciuti_False;
begin
  Assert.IsFalse(TzSchedulerEvents.CanIntersect('', ''));
  Assert.IsFalse(TzSchedulerEvents.CanIntersect('ZT_MAI1', 'ZT_MAI2'));
end;

procedure TTestSchedulerEvents.Apri_ChiamaIlGestoreDelTipo;
var
  Ricevuto: Integer;
  Params: TzSchedulerEventParams;
begin
  Ricevuto := 0;
  TzSchedulerEvents.Register('ZTA1', 'a', 'ID_A').Apri :=
    function(const P: TzSchedulerEventParams): Boolean
    begin
      Ricevuto := P.Id;
      result := True;
    end;

  Params.Init;
  Params.Kind := 'zta1';
  Params.Id := 123;

  Assert.IsTrue(TzSchedulerEvents.Apri(Params));
  Assert.AreEqual(123, Ricevuto);
end;

procedure TTestSchedulerEvents.Sposta_Elimina_GestoriDistinti;
var
  Chiamate: string;
  Kind: TzSchedulerEventKind;
  Params: TzSchedulerEventParams;
begin
  Chiamate := '';
  Kind := TzSchedulerEvents.Register('ZTS1', 'a', 'ID_A');
  Kind.Apri :=
    function(const P: TzSchedulerEventParams): Boolean
    begin
      Chiamate := Chiamate + 'A';
      result := True;
    end;
  Kind.Sposta :=
    function(const P: TzSchedulerEventParams): Boolean
    begin
      Chiamate := Chiamate + 'S';
      result := True;
    end;
  Kind.Elimina :=
    function(const P: TzSchedulerEventParams): Boolean
    begin
      Chiamate := Chiamate + 'E';
      result := False;
    end;

  Params.Init;
  Params.Kind := 'ZTS1';

  Assert.IsTrue(TzSchedulerEvents.Sposta(Params));
  // il risultato e' quello del gestore: un'eliminazione rifiutata resta False
  Assert.IsFalse(TzSchedulerEvents.Elimina(Params));
  Assert.AreEqual('SE', Chiamate);
end;

procedure TTestSchedulerEvents.Apri_TipoSenzaGestore_False;
var
  Params: TzSchedulerEventParams;
begin
  TzSchedulerEvents.Register('ZTN1', 'a', 'ID_A');

  Params.Init;
  Params.Kind := 'ZTN1';

  Assert.IsFalse(TzSchedulerEvents.Apri(Params));
  Assert.IsFalse(TzSchedulerEvents.Sposta(Params));
  Assert.IsFalse(TzSchedulerEvents.Elimina(Params));
end;

procedure TTestSchedulerEvents.Apri_TipoSconosciuto_False;
var
  Params: TzSchedulerEventParams;
begin
  Params.Init;
  Params.Kind := 'ZT_MAI_REGISTRATO';

  Assert.IsFalse(TzSchedulerEvents.Apri(Params));
end;

{ TTestSchedulerStorageBinder }

procedure TTestSchedulerStorageBinder.Setup;
begin
  FStorage := TcxSchedulerDBStorage.Create(nil);
end;

procedure TTestSchedulerStorageBinder.TearDown;
begin
  FreeAndNil(FStorage);
end;

function TTestSchedulerStorageBinder.Occorrenze(const FieldName: string): Integer;
var
  i: Integer;
begin
  result := 0;

  for i := 0 to FStorage.CustomFields.Count - 1 do
    if SameText(FStorage.CustomFields.Items[i].FieldName, FieldName) then
      Inc(result);
end;

procedure TTestSchedulerStorageBinder.InitDelegated_StorageNil_NessunErrore;
begin
  TzSchedulerStorageBinder.InitDelegated(nil, []);
  Assert.Pass('nessuna eccezione con lo storage non assegnato');
end;

procedure TTestSchedulerStorageBinder.InitDelegated_NomiDeiCampiDellaProcedura;
begin
  TzSchedulerStorageBinder.InitDelegated(FStorage, []);

  // gli stessi di TSchedulerTools.InitStorageFields di Gesty e WT
  Assert.AreEqual('ID', string(FStorage.FieldNames.ID));
  Assert.AreEqual('TIPO_EVENTO', string(FStorage.FieldNames.EventType));
  Assert.AreEqual('INIZIO', string(FStorage.FieldNames.Start));
  Assert.AreEqual('FINE', string(FStorage.FieldNames.Finish));
  Assert.AreEqual('OPZIONI', string(FStorage.FieldNames.Options));
  Assert.AreEqual('TITOLO_EVENTO', string(FStorage.FieldNames.Caption));
  Assert.AreEqual('CORPO_EVENTO', string(FStorage.FieldNames.Message));
end;

procedure TTestSchedulerStorageBinder.InitDelegated_CampiPersonalizzatiDiBase;
begin
  TzSchedulerStorageBinder.InitDelegated(FStorage, []);

  Assert.AreEqual(1, Occorrenze('TITOLO_EVENTO'));
  Assert.AreEqual(1, Occorrenze('CORPO_EVENTO'));
  Assert.AreEqual(1, Occorrenze(zSchedulerKindField));
  Assert.AreEqual(1, Occorrenze(zSchedulerEditableField));
  Assert.AreEqual(1, Occorrenze(zSchedulerColorField));
end;

procedure TTestSchedulerStorageBinder.InitDelegated_ChiaviDeiTipi_UnaSolaVolta;
begin
  // due tipi con la stessa colonna chiave (scritta in modo diverso)
  TzSchedulerEvents.Register('ZTB1', 'a', 'ZT_ID_COMUNE');
  TzSchedulerEvents.Register('ZTB2', 'b', 'zt_id_comune');
  TzSchedulerEvents.Register('ZTB3', 'c', 'ZT_ID_PROPRIO');

  TzSchedulerStorageBinder.InitDelegated(FStorage, []);

  Assert.AreEqual(1, Occorrenze('ZT_ID_COMUNE'));
  Assert.AreEqual(1, Occorrenze('ZT_ID_PROPRIO'));
end;

procedure TTestSchedulerStorageBinder.InitDelegated_CampiAggiuntivi_SenzaDoppioni;
begin
  TzSchedulerStorageBinder.InitDelegated(FStorage, ['ZT_EXTRA', 'COLORE', 'zt_extra', '']);

  Assert.AreEqual(1, Occorrenze('ZT_EXTRA'));
  Assert.AreEqual(1, Occorrenze(zSchedulerColorField));
  Assert.AreEqual(0, Occorrenze(''));
end;

procedure TTestSchedulerStorageBinder.InitDelegated_DueVolte_NessunDoppione;
begin
  // un frame riaperto riaggancia lo stesso storage
  TzSchedulerStorageBinder.InitDelegated(FStorage, ['ZT_EXTRA']);
  TzSchedulerStorageBinder.InitDelegated(FStorage, ['ZT_EXTRA']);

  Assert.AreEqual(1, Occorrenze('TITOLO_EVENTO'));
  Assert.AreEqual(1, Occorrenze('ZT_EXTRA'));
end;

procedure TTestSchedulerStorageBinder.InitDelegated_LoStorageNonScriveMai;
var
  Gestito: Boolean;
begin
  TzSchedulerStorageBinder.InitDelegated(FStorage, []);

  Assert.IsTrue(Assigned(FStorage.OnEventInserted));
  Assert.IsTrue(Assigned(FStorage.OnEventModified));
  Assert.IsTrue(Assigned(FStorage.OnEventDeleted));

  Gestito := False;
  FStorage.OnEventInserted(FStorage, nil, Gestito);
  Assert.IsTrue(Gestito, 'inserimento');

  Gestito := False;
  FStorage.OnEventModified(FStorage, nil, Gestito);
  Assert.IsTrue(Gestito, 'modifica');

  Gestito := False;
  FStorage.OnEventDeleted(FStorage, nil, Gestito);
  Assert.IsTrue(Gestito, 'eliminazione');
end;

procedure TTestSchedulerStorageBinder.InitDelegated_SovrapposizioneSenzaTipo_Negata;
var
  Ammessa: Boolean;
begin
  TzSchedulerStorageBinder.InitDelegated(FStorage, []);

  Assert.IsTrue(Assigned(FStorage.OnEventIntersect));

  // eventi senza tipo leggibile: nessun tipo registrato ammette la sovrapposizione
  Ammessa := True;
  FStorage.OnEventIntersect(FStorage, nil, nil, Ammessa);
  Assert.IsFalse(Ammessa);
end;

{ TTestSchedulerEventValue }

procedure TTestSchedulerEventValue.EventoNil_Null;
begin
  Assert.IsTrue(VarIsNull(SchedulerEventValue(nil, 'QUALSIASI')));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCopiaIncolla);
  TDUnitX.RegisterTestFixture(TTestSchedulerEventParams);
  TDUnitX.RegisterTestFixture(TTestSchedulerParams);
  TDUnitX.RegisterTestFixture(TTestSchedulerEventKind);
  TDUnitX.RegisterTestFixture(TTestSchedulerEvents);
  TDUnitX.RegisterTestFixture(TTestSchedulerStorageBinder);
  TDUnitX.RegisterTestFixture(TTestSchedulerEventValue);
  TDUnitX.RegisterTestFixture(TTestSchedulerCalcoli);

end.
