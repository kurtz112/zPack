// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDX.Lookup;

// Test DUnitX per i lookup di zBase\zDX.pas (specifica ZBASE-LKP, "Lookup di
// zDX.md"). BOZZA scritta senza poterla compilare ne' eseguire.
//
// Si provano solo le parti che non richiedono finestre ne' il modulo Tdx:
// - TzSystem.GetLookup, la ricerca del dizionario che InitLookup chiama per
//   prima (ZBASE-LKP-002);
// - TzLookup.GetKeyFieldForCombo e GetListFieldNamesForCombo, da cui
//   InitLookup ricava chiave e colonne del combo (ZBASE-LKP-003), e i valori
//   predefiniti della ricerca (ZBASE-LKP-004);
// - TzPickList.AssignToProps, AsText e AssignToStrings, che InitPickList e
//   AssignPickList usano per riempire le caselle (ZBASE-LKP-014);
// - la costante ImmagineVoceTutti (ZBASE-LKP-015).
//
// Restano senza prova tutte le routine di Tdx (InitLookup, InitLookupColumns,
// CreateGridDBTableView, i gestori del popup, AssignPickList, InitPickList):
// sono metodi di un modulo dati, e crearlo con dx carica il DFM con le skin,
// applica la traduzione italiana ai testi di DevExpress e di Delphi (zTranslate,
// che cambia risorse comuni a tutto il processo) e tocca il look and feel
// globale; nessun test esistente lo crea (Test.zFormBuilder lo evita per lo
// stesso motivo) e senza poter eseguire non si puo' escludere che disturbi gli
// altri test. TLookupViewProps e' dichiarata nella parte implementation di
// zDX.pas, e il contatore di generazione del popup (Mantis #151) e' un membro
// privato di Tdx: nessuno dei due si raggiunge da qui.
//
// TzSystem e' un oggetto unico di processo (la variabile Base): ogni fixture ne
// crea uno in Setup e lo libera in TearDown, come Test.zSystem.Dizionario.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  cxImageComboBox,
  DUnitX.TestFramework,
  zFbDataSet,
  zSystem,
  zDX;

type
  [TestFixture]
  TTestLookupRicercaDelDizionario = class
  private
    FSistema: TzSystem;
    FDati: TzFbDataSet;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_IdSconosciuto_CreaLaRicercaConQuelNome;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_IdSconosciuto_DataSetEVistaDalDataSet;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_IdVuoto_UsaIdDelDataSet;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_SenzaChiaveIndicata_UsaLaChiavePrimaria;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_ChiaveEColonneIndicate_VengonoUsate;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_SenzaColonne_UsanoLaChiave;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_Nuova_NonDiventaChiaveEsterna;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_Nuova_SegnaIlDizionarioModificato;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_Esistente_NonSovrascriveChiaveEColonne;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_Esistente_ColonneVuote_RiempiteDaiParametri;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_Esistente_ChiaveEColonneVuote_RiempiteDalDataSet;
    // ZBASE-LKP-002
    [Test]
    procedure GetLookup_StessoId_RestituisceLaStessaRicerca;
  end;

  [TestFixture]
  TTestLookupChiaveEColonne = class
  private
    FSistema: TzSystem;
    function NuovaRicerca(const Nome: string): TzLookup;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-LKP-004
    [Test]
    procedure Ricerca_Nuova_ValoriPredefiniti;
    // ZBASE-LKP-003
    [Test]
    procedure ChiaveEColonne_LaVirgolaDiventaPuntoEVirgola;
    // ZBASE-LKP-003
    [Test]
    procedure GetKeyFieldForCombo_SenzaCampoDati_ChiaveDellaRicerca;
    // ZBASE-LKP-003
    [Test]
    procedure GetKeyFieldForCombo_ChiaveMultipla_PrendeLaPrima;
    // ZBASE-LKP-003
    [Test]
    procedure GetKeyFieldForCombo_Mappatura_UsaIlCampoMappato;
    // ZBASE-LKP-003
    [Test]
    procedure GetKeyFieldForCombo_CampoNonMappato_ChiaveDellaRicerca;
    // ZBASE-LKP-003
    [Test]
    procedure GetKeyFieldForCombo_MappaturaMultipla_PrendeLaPrima;
    // ZBASE-LKP-003
    [Test]
    procedure GetListFieldNamesForCombo_ColonneIndicate_TalIEQuali;
    // ZBASE-LKP-003
    [Test]
    procedure GetListFieldNamesForCombo_SenzaColonneESenzaVista_ChiaveDelCombo;
    // ZBASE-LKP-003
    [Test]
    procedure GetListFieldNamesForCombo_SenzaColonneESenzaVista_ChiaveMappata;
  end;

  [TestFixture]
  TTestLookupListeDiValori = class
  private
    FSistema: TzSystem;
    FProprieta: TcxImageComboBoxProperties;
    function NuovaLista: TzPickList;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-LKP-014
    [Test]
    procedure AssegnaAlleProprieta_CopiaDescrizioneValoreEImmagine;
    // ZBASE-LKP-014
    [Test]
    procedure AssegnaAlleProprieta_MantieneLOrdineDelleVoci;
    // ZBASE-LKP-014
    [Test]
    procedure AssegnaAlleProprieta_SostituisceLeVociPrecedenti;
    // ZBASE-LKP-014
    [Test]
    procedure AssegnaAlleProprieta_ListaVuota_SvuotaLeVoci;
    // ZBASE-LKP-014
    [Test]
    procedure AsText_SoloIValoriSeguitiDaInvio;
    // ZBASE-LKP-014
    [Test]
    procedure AssegnaAlleStringhe_NomeUgualeValore;
  end;

  [TestFixture]
  TTestLookupVoceTutti = class
  public
    // ZBASE-LKP-015
    [Test]
    procedure ImmagineVoceTutti_IndiceValido;
  end;

implementation

{ TTestLookupRicercaDelDizionario }

procedure TTestLookupRicercaDelDizionario.Setup;
begin
  FSistema := TzSystem.Create(nil);

  // dataset mai aperto e senza connessione: GetLookup legge solo IdDataSet e la
  // chiave primaria dichiarata
  FDati := TzFbDataSet.Create(nil);
  FDati.IdDataSet := 'Anagrafica.Soggetti';
  FDati.PrimaryKeyFields := 'ID_SOGGETTO';
end;

procedure TTestLookupRicercaDelDizionario.TearDown;
begin
  FreeAndNil(FDati);
  FreeAndNil(FSistema);
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_IdSconosciuto_CreaLaRicercaConQuelNome;
var
  Ricerca: TzLookup;
begin
  Assert.IsFalse(FSistema.zLookups.Exists('LK_SOGGETTI'), 'prima della chiamata non c''e''');

  Ricerca := FSistema.GetLookup('LK_SOGGETTI', FDati);

  Assert.IsNotNull(Ricerca);
  Assert.AreEqual('LK_SOGGETTI', Ricerca.Name);
  Assert.IsTrue(FSistema.zLookups.Exists('LK_SOGGETTI'), 'ora e'' nel dizionario');
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_IdSconosciuto_DataSetEVistaDalDataSet;
var
  Ricerca: TzLookup;
begin
  Ricerca := FSistema.GetLookup('LK_SOGGETTI', FDati);

  Assert.AreEqual('Anagrafica.Soggetti', Ricerca.DataSet, 'DataSet');
  Assert.AreEqual('Anagrafica.Soggetti', Ricerca.DbView, 'DbView');
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_IdVuoto_UsaIdDelDataSet;
var
  Ricerca: TzLookup;
begin
  Ricerca := FSistema.GetLookup('', FDati);

  Assert.IsNotNull(Ricerca);
  Assert.AreEqual('Anagrafica.Soggetti', Ricerca.Name);
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_SenzaChiaveIndicata_UsaLaChiavePrimaria;
var
  Ricerca: TzLookup;
begin
  Ricerca := FSistema.GetLookup('LK_SOGGETTI', FDati);

  Assert.AreEqual('ID_SOGGETTO', Ricerca.KeyField);
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_ChiaveEColonneIndicate_VengonoUsate;
var
  Ricerca: TzLookup;
begin
  Ricerca := FSistema.GetLookup('LK_SOGGETTI', FDati, 'CODICE', 'CODICE;DESCRIZIONE');

  Assert.AreEqual('CODICE', Ricerca.KeyField, 'chiave');
  Assert.AreEqual('CODICE;DESCRIZIONE', Ricerca.DisplayColumns, 'colonne');
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_SenzaColonne_UsanoLaChiave;
var
  Ricerca: TzLookup;
begin
  Ricerca := FSistema.GetLookup('LK_SOGGETTI', FDati, 'CODICE');

  Assert.AreEqual('CODICE', Ricerca.DisplayColumns);
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_Nuova_NonDiventaChiaveEsterna;
var
  Ricerca: TzLookup;
begin
  Ricerca := FSistema.GetLookup('LK_SOGGETTI', FDati);

  // altrimenti l'aggiornamento della cache la eliminerebbe
  Assert.IsFalse(Ricerca.IsForeignKey);
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_Nuova_SegnaIlDizionarioModificato;
begin
  FSistema.Modified := false;

  FSistema.GetLookup('LK_SOGGETTI', FDati);

  Assert.IsTrue(FSistema.Modified);
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_Esistente_NonSovrascriveChiaveEColonne;
var
  Esistente: TzLookup;
  Ricerca: TzLookup;
begin
  Esistente := FSistema.zLookups.Add;
  Esistente.Name := 'LK_ESISTENTE';
  Esistente.KeyField := 'COD';
  Esistente.DisplayColumns := 'COD;DESC';

  Ricerca := FSistema.GetLookup('LK_ESISTENTE', FDati, 'ALTRA_CHIAVE', 'ALTRA_CHIAVE;ALTRA_COLONNA');

  Assert.AreEqual('COD', Ricerca.KeyField, 'chiave');
  Assert.AreEqual('COD;DESC', Ricerca.DisplayColumns, 'colonne');
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_Esistente_ColonneVuote_RiempiteDaiParametri;
var
  Esistente: TzLookup;
  Ricerca: TzLookup;
begin
  Esistente := FSistema.zLookups.Add;
  Esistente.Name := 'LK_ESISTENTE';
  Esistente.KeyField := 'COD';

  Ricerca := FSistema.GetLookup('LK_ESISTENTE', FDati, 'ALTRA_CHIAVE', 'COD;DESC');

  Assert.AreEqual('COD', Ricerca.KeyField, 'la chiave presente non cambia');
  Assert.AreEqual('COD;DESC', Ricerca.DisplayColumns, 'le colonne vuote si riempiono');
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_Esistente_ChiaveEColonneVuote_RiempiteDalDataSet;
var
  Esistente: TzLookup;
  Ricerca: TzLookup;
begin
  Esistente := FSistema.zLookups.Add;
  Esistente.Name := 'LK_ESISTENTE';

  Ricerca := FSistema.GetLookup('LK_ESISTENTE', FDati);

  Assert.AreEqual('ID_SOGGETTO', Ricerca.KeyField, 'chiave dalla chiave primaria');
  Assert.AreEqual('ID_SOGGETTO', Ricerca.DisplayColumns, 'colonne dalla chiave');
end;

procedure TTestLookupRicercaDelDizionario.GetLookup_StessoId_RestituisceLaStessaRicerca;
var
  Prima: TzLookup;
  Seconda: TzLookup;
  Quante: integer;
begin
  Prima := FSistema.GetLookup('LK_SOGGETTI', FDati);
  Quante := FSistema.zLookups.Count;

  Seconda := FSistema.GetLookup('LK_SOGGETTI', FDati);

  Assert.AreSame(Prima, Seconda, 'stesso oggetto');
  Assert.AreEqual(Quante, FSistema.zLookups.Count, 'nessuna ricerca in piu''');
end;

{ TTestLookupChiaveEColonne }

procedure TTestLookupChiaveEColonne.Setup;
begin
  FSistema := TzSystem.Create(nil);
end;

procedure TTestLookupChiaveEColonne.TearDown;
begin
  FreeAndNil(FSistema);
end;

function TTestLookupChiaveEColonne.NuovaRicerca(const Nome: string): TzLookup;
begin
  result := FSistema.zLookups.Add;
  result.Name := Nome;
end;

procedure TTestLookupChiaveEColonne.Ricerca_Nuova_ValoriPredefiniti;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');

  Assert.IsTrue(Ricerca.OnlyFromLookup, 'OnlyFromLookup');
  Assert.IsTrue(Ricerca.IsForeignKey, 'IsForeignKey');
  Assert.IsTrue(Ricerca.Exists, 'Exists');
  Assert.IsTrue(Ricerca.IgnoreFieldReadOnly, 'IgnoreFieldReadOnly');
end;

procedure TTestLookupChiaveEColonne.ChiaveEColonne_LaVirgolaDiventaPuntoEVirgola;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');

  Ricerca.KeyField := 'ID_ANNO,ID_CORSO';
  Ricerca.DisplayColumns := 'ID_ANNO,DESCRIZIONE';

  Assert.AreEqual('ID_ANNO;ID_CORSO', Ricerca.KeyField, 'chiave');
  Assert.AreEqual('ID_ANNO;DESCRIZIONE', Ricerca.DisplayColumns, 'colonne');
end;

procedure TTestLookupChiaveEColonne.GetKeyFieldForCombo_SenzaCampoDati_ChiaveDellaRicerca;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'ID';

  Assert.AreEqual('ID', Ricerca.GetKeyFieldForCombo(''));
end;

procedure TTestLookupChiaveEColonne.GetKeyFieldForCombo_ChiaveMultipla_PrendeLaPrima;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'ID_ANNO;ID_CORSO';

  Assert.AreEqual('ID_ANNO', Ricerca.GetKeyFieldForCombo(''));
end;

procedure TTestLookupChiaveEColonne.GetKeyFieldForCombo_Mappatura_UsaIlCampoMappato;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'ID';
  Ricerca.Mappings.Values['ID_CLIENTE'] := 'COD_CLIENTE';

  Assert.AreEqual('COD_CLIENTE', Ricerca.GetKeyFieldForCombo('ID_CLIENTE'));
end;

procedure TTestLookupChiaveEColonne.GetKeyFieldForCombo_CampoNonMappato_ChiaveDellaRicerca;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'ID';
  Ricerca.Mappings.Values['ID_CLIENTE'] := 'COD_CLIENTE';

  Assert.AreEqual('ID', Ricerca.GetKeyFieldForCombo('ALTRO'));
end;

procedure TTestLookupChiaveEColonne.GetKeyFieldForCombo_MappaturaMultipla_PrendeLaPrima;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'ID';
  // il valore mappato passa dal TStringList e non dal setter di KeyField:
  // la virgola viene comunque trattata come separatore
  Ricerca.Mappings.Values['ID_CLIENTE'] := 'COD_A,COD_B';

  Assert.AreEqual('COD_A', Ricerca.GetKeyFieldForCombo('ID_CLIENTE'));
end;

procedure TTestLookupChiaveEColonne.GetListFieldNamesForCombo_ColonneIndicate_TalIEQuali;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'ID';
  Ricerca.DisplayColumns := 'ID;DESCRIZIONE;SIGLA';

  Assert.AreEqual('ID;DESCRIZIONE;SIGLA', Ricerca.GetListFieldNamesForCombo(''));
end;

procedure TTestLookupChiaveEColonne.GetListFieldNamesForCombo_SenzaColonneESenzaVista_ChiaveDelCombo;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'COD';
  Ricerca.DbView := '';

  Assert.AreEqual('COD', Ricerca.GetListFieldNamesForCombo(''));
end;

procedure TTestLookupChiaveEColonne.GetListFieldNamesForCombo_SenzaColonneESenzaVista_ChiaveMappata;
var
  Ricerca: TzLookup;
begin
  Ricerca := NuovaRicerca('LK_PROVA');
  Ricerca.KeyField := 'COD';
  Ricerca.DbView := '';
  Ricerca.Mappings.Values['ID_CLIENTE'] := 'COD_CLIENTE';

  Assert.AreEqual('COD_CLIENTE', Ricerca.GetListFieldNamesForCombo('ID_CLIENTE'));
end;

{ TTestLookupListeDiValori }

procedure TTestLookupListeDiValori.Setup;
begin
  FSistema := TzSystem.Create(nil);
  // proprieta' di una casella immagine create da sole, senza editor ne' finestra
  FProprieta := TcxImageComboBoxProperties.Create(nil);
end;

procedure TTestLookupListeDiValori.TearDown;
begin
  FreeAndNil(FProprieta);
  FreeAndNil(FSistema);
end;

function TTestLookupListeDiValori.NuovaLista: TzPickList;
var
  Voce: TzPickValue;
begin
  result := FSistema.zPickLists.Get('STATI_PRATICA', true);

  Voce := result.PickValues.Add;
  Voce.Name := 'Aperta';
  Voce.Value := 'A';
  Voce.ImageIndex := 3;

  Voce := result.PickValues.Add;
  Voce.Name := 'Chiusa';
  Voce.Value := 'C';
end;

procedure TTestLookupListeDiValori.AssegnaAlleProprieta_CopiaDescrizioneValoreEImmagine;
begin
  NuovaLista.AssignToProps(FProprieta);

  Assert.AreEqual(2, FProprieta.Items.Count, 'numero di voci');
  Assert.AreEqual('Aperta', FProprieta.Items[0].Description, 'descrizione');
  Assert.AreEqual('A', VarToStr(FProprieta.Items[0].Value), 'valore');
  Assert.AreEqual(3, Integer(FProprieta.Items[0].ImageIndex), 'icona');
  Assert.AreEqual(-1, Integer(FProprieta.Items[1].ImageIndex), 'senza icona');
end;

procedure TTestLookupListeDiValori.AssegnaAlleProprieta_MantieneLOrdineDelleVoci;
begin
  NuovaLista.AssignToProps(FProprieta);

  Assert.AreEqual('Aperta', FProprieta.Items[0].Description, 'prima voce');
  Assert.AreEqual('Chiusa', FProprieta.Items[1].Description, 'seconda voce');
  Assert.AreEqual('C', VarToStr(FProprieta.Items[1].Value), 'valore della seconda');
end;

procedure TTestLookupListeDiValori.AssegnaAlleProprieta_SostituisceLeVociPrecedenti;
begin
  FProprieta.Items.Add.Description := 'Prova';

  NuovaLista.AssignToProps(FProprieta);

  Assert.AreEqual(2, FProprieta.Items.Count);
  Assert.AreEqual('Aperta', FProprieta.Items[0].Description);
end;

procedure TTestLookupListeDiValori.AssegnaAlleProprieta_ListaVuota_SvuotaLeVoci;
var
  Vuota: TzPickList;
begin
  FProprieta.Items.Add.Description := 'Prova';
  Vuota := FSistema.zPickLists.Get('LISTA_VUOTA', true);

  Vuota.AssignToProps(FProprieta);

  Assert.AreEqual(0, FProprieta.Items.Count);
end;

procedure TTestLookupListeDiValori.AsText_SoloIValoriSeguitiDaInvio;
begin
  // i nomi non compaiono: ogni valore e' seguito da #13
  Assert.AreEqual('A' + #13 + 'C' + #13, NuovaLista.AsText);
end;

procedure TTestLookupListeDiValori.AssegnaAlleStringhe_NomeUgualeValore;
var
  Righe: TStringList;
begin
  Righe := TStringList.Create;
  try
    NuovaLista.AssignToStrings(Righe);

    Assert.AreEqual(2, Righe.Count, 'righe');
    Assert.AreEqual('Aperta=A', Righe[0], 'prima riga');
    Assert.AreEqual('Chiusa=C', Righe[1], 'seconda riga');
  finally
    Righe.Free;
  end;
end;

{ TTestLookupVoceTutti }

procedure TTestLookupVoceTutti.ImmagineVoceTutti_IndiceValido;
begin
  // e' un indice nella lista Immagini: un numero negativo vorrebbe dire
  // «nessuna icona». Il valore esatto non si fissa qui: cambia quando il
  // catalogo delle icone si rigenera (DIV-LKP-12)
  Assert.IsTrue(ImmagineVoceTutti >= 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestLookupRicercaDelDizionario);
  TDUnitX.RegisterTestFixture(TTestLookupChiaveEColonne);
  TDUnitX.RegisterTestFixture(TTestLookupListeDiValori);
  TDUnitX.RegisterTestFixture(TTestLookupVoceTutti);

end.
