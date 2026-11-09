// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zMap;

// Test DUnitX di zBase\zMap.pas, nelle sole parti che non richiedono una mappa
// visibile (specifica ZBASE-MAP, "Mappa.md"):
// - SetGoogleAPI e TServiceApi (ZBASE-MAP-001);
// - TGeocodingResultStruct (ZBASE-MAP-003);
// - TzMap.IconUrl e TzMap.GetProperties (ZBASE-MAP-010 e ZBASE-MAP-006).
//
// Disegno, geocodifica, strati GIS e attesa della mappa (ZBASE-MAP-002, 004,
// 005, 007, 008, 009, 011) richiedono il browser incorporato e Firebird: non
// hanno prove automatiche, vanno provati con il collaudo sul banco.
//
// IconUrl e GetProperties sono metodi di istanza di TzMap che non leggono nessun
// campo dell'istanza. Costruire un frame vero richiederebbe form, immagini,
// WebView2 e la base di configurazione, quindi le prove usano un'istanza
// allocata con NewInstance e liberata con FreeInstance, senza eseguire il
// costruttore ne' il distruttore. Se uno di quei due metodi cominciasse a usare
// un campo dell'istanza, le prove andrebbero riscritte con un frame vero.
//
// Le divergenze (DIV-MAP-1..11) non sono provate: richiedono la mappa in
// esecuzione oppure descrivono difetti dedotti che non si vuole imporre.

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  Vcl.TMSFNCMapsCommonTypes,
  DUnitX.TestFramework,
  zMap;

type
  [TestFixture]
  TTestMapChiaviServizio = class
  private
    FServiceApiSalvata: TServiceApi;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-MAP-001
    [Test]
    procedure SetGoogleAPI_ChiaveValida_ScrittaInEntrambiICampi;
    // ZBASE-MAP-001
    [Test]
    procedure SetGoogleAPI_ChiaveVuotaDopoUnaValida_EntrambiVuoti;
    // ZBASE-MAP-001
    [Test]
    procedure SetGoogleAPI_NuovaChiave_SostituisceLaPrecedente;
    // ZBASE-MAP-001
    [Test]
    procedure ServiceApiInit_AzzeraEntrambiICampi;
  end;

  [TestFixture]
  TTestMapEsitoGeocodifica = class
  public
    // ZBASE-MAP-003
    [Test]
    procedure SetCoordinates_ZeroEZero_NonTrovato;
    // ZBASE-MAP-003
    [Test]
    procedure SetCoordinates_CoordinateValide_TrovatoConLeCoordinate;
    // ZBASE-MAP-003
    [Test]
    procedure SetCoordinates_UnSoloValoreAZero_Trovato;
    // ZBASE-MAP-003
    [Test]
    procedure SetCoordinates_ConEsitoPrecedente_AzzeraIlTestoDelRisultato;
    // ZBASE-MAP-003
    [Test]
    procedure Clear_DopoUnaRicerca_TuttoAzzerato;
  end;

  [TestFixture]
  TTestMapProprietaEColori = class
  private
    FMappa: TzMap;
    FDataSet: TFDMemTable;
    FElenco: TStringList;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-MAP-010
    [Test]
    procedure IconUrl_NessunColore_StringaVuota;
    // ZBASE-MAP-010
    [Test]
    procedure IconUrl_QuattroColori_NonVuotiEDiversi;
    // ZBASE-MAP-006
    [Test]
    procedure GetProperties_DueCampi_RigheNomeValore;
    // ZBASE-MAP-006
    [Test]
    procedure GetProperties_SeparatoreVirgolaECampoMancante_ValoreVuoto;
    // ZBASE-MAP-006
    [Test]
    procedure GetProperties_ElencoPrecedenteENomiVuoti_ElencoSostituito;
    // ZBASE-MAP-006
    [Test]
    procedure GetProperties_CampoNullo_ValoreVuoto;
    // ZBASE-MAP-006
    [Test]
    procedure GetProperties_NessunNome_ElencoVuoto;
  end;

implementation

// TTestMapChiaviServizio

procedure TTestMapChiaviServizio.Setup;
begin
  // ServiceApi e' una variabile globale letta dalle mappe: si ripristina a
  // fine prova per non lasciare chiavi nelle prove successive
  FServiceApiSalvata := ServiceApi;
end;

procedure TTestMapChiaviServizio.TearDown;
begin
  ServiceApi := FServiceApiSalvata;
end;

procedure TTestMapChiaviServizio.SetGoogleAPI_ChiaveValida_ScrittaInEntrambiICampi;
begin
  SetGoogleAPI('abc123');

  Assert.AreEqual('abc123', ServiceApi.MapAPI, 'chiave della mappa');
  Assert.AreEqual('abc123', ServiceApi.GeocodingApi, 'chiave della geocodifica');
end;

procedure TTestMapChiaviServizio.SetGoogleAPI_ChiaveVuotaDopoUnaValida_EntrambiVuoti;
begin
  SetGoogleAPI('abc123');

  SetGoogleAPI('');

  Assert.AreEqual('', ServiceApi.MapAPI, 'chiave della mappa');
  Assert.AreEqual('', ServiceApi.GeocodingApi, 'chiave della geocodifica');
end;

procedure TTestMapChiaviServizio.SetGoogleAPI_NuovaChiave_SostituisceLaPrecedente;
begin
  SetGoogleAPI('prima');

  SetGoogleAPI('seconda');

  Assert.AreEqual('seconda', ServiceApi.MapAPI, 'chiave della mappa');
  Assert.AreEqual('seconda', ServiceApi.GeocodingApi, 'chiave della geocodifica');
end;

procedure TTestMapChiaviServizio.ServiceApiInit_AzzeraEntrambiICampi;
begin
  ServiceApi.MapAPI := 'x';
  ServiceApi.GeocodingApi := 'y';

  ServiceApi.init;

  Assert.AreEqual('', ServiceApi.MapAPI, 'chiave della mappa');
  Assert.AreEqual('', ServiceApi.GeocodingApi, 'chiave della geocodifica');
end;

// TTestMapEsitoGeocodifica

procedure TTestMapEsitoGeocodifica.SetCoordinates_ZeroEZero_NonTrovato;
var
  Esito: TGeocodingResultStruct;
  Coordinata: TTMSFNCMapsCoordinateRec;
begin
  Coordinata.Latitude := 0;
  Coordinata.Longitude := 0;

  Esito.SetCoordinates(Coordinata);

  Assert.AreEqual(Ord(grNotFound), Ord(Esito.Result));
end;

procedure TTestMapEsitoGeocodifica.SetCoordinates_CoordinateValide_TrovatoConLeCoordinate;
var
  Esito: TGeocodingResultStruct;
  Coordinata: TTMSFNCMapsCoordinateRec;
begin
  Coordinata.Latitude := 45.5;
  Coordinata.Longitude := 9.1;

  Esito.SetCoordinates(Coordinata);

  Assert.AreEqual(Ord(grFound), Ord(Esito.Result), 'esito');
  Assert.AreEqual(Double(45.5), Double(Esito.Latitude), 0.000001, 'latitudine');
  Assert.AreEqual(Double(9.1), Double(Esito.Longitude), 0.000001, 'longitudine');
end;

procedure TTestMapEsitoGeocodifica.SetCoordinates_UnSoloValoreAZero_Trovato;
var
  Esito: TGeocodingResultStruct;
  Coordinata: TTMSFNCMapsCoordinateRec;
begin
  Coordinata.Latitude := 0;
  Coordinata.Longitude := 9;

  Esito.SetCoordinates(Coordinata);

  Assert.AreEqual(Ord(grFound), Ord(Esito.Result));
end;

procedure TTestMapEsitoGeocodifica.SetCoordinates_ConEsitoPrecedente_AzzeraIlTestoDelRisultato;
var
  Esito: TGeocodingResultStruct;
  Coordinata: TTMSFNCMapsCoordinateRec;
begin
  Esito.Clear;
  Esito.Result := grBusy;
  Esito.ResultString := 'risposta precedente del servizio';
  Coordinata.Latitude := 45.5;
  Coordinata.Longitude := 9.1;

  Esito.SetCoordinates(Coordinata);

  Assert.AreEqual('', Esito.ResultString);
end;

procedure TTestMapEsitoGeocodifica.Clear_DopoUnaRicerca_TuttoAzzerato;
var
  Esito: TGeocodingResultStruct;
begin
  Esito.Result := grFound;
  Esito.ResultString := 'testo';
  Esito.Latitude := 45.5;
  Esito.Longitude := 9.1;

  Esito.Clear;

  Assert.AreEqual(Ord(grNone), Ord(Esito.Result), 'esito');
  Assert.AreEqual('', Esito.ResultString, 'testo');
  Assert.IsTrue(Esito.Latitude = 0, 'latitudine');
  Assert.IsTrue(Esito.Longitude = 0, 'longitudine');
end;

// TTestMapProprietaEColori

procedure TTestMapProprietaEColori.Setup;
begin
  // istanza senza costruttore: vedi il commento in testa all'unit
  FMappa := TzMap(TzMap.NewInstance);

  FElenco := TStringList.Create;

  // dataset con due record: il primo completo, il secondo senza NOME
  FDataSet := TFDMemTable.Create(nil);
  FDataSet.FieldDefs.Add('ID', ftInteger);
  FDataSet.FieldDefs.Add('NOME', ftString, 30);
  FDataSet.CreateDataSet;

  FDataSet.Append;
  FDataSet.FieldByName('ID').AsInteger := 7;
  FDataSet.FieldByName('NOME').AsString := 'Rossi';
  FDataSet.Post;

  FDataSet.Append;
  FDataSet.FieldByName('ID').AsInteger := 8;
  FDataSet.Post;

  FDataSet.First;
end;

procedure TTestMapProprietaEColori.TearDown;
begin
  FDataSet.Free;
  FElenco.Free;
  // FreeInstance e non Free: il distruttore di TzMap leggerebbe campi mai creati
  FMappa.FreeInstance;
end;

procedure TTestMapProprietaEColori.IconUrl_NessunColore_StringaVuota;
begin
  Assert.AreEqual('', FMappa.IconUrl(icNone));
end;

procedure TTestMapProprietaEColori.IconUrl_QuattroColori_NonVuotiEDiversi;
var
  Blu, Verde, Rosso, Viola: string;
begin
  Blu := FMappa.IconUrl(icBlue);
  Verde := FMappa.IconUrl(icGreen);
  Rosso := FMappa.IconUrl(icRed);
  Viola := FMappa.IconUrl(icPurple);

  Assert.IsTrue((Blu <> '') and (Verde <> '') and (Rosso <> '') and (Viola <> ''), 'indirizzi non vuoti');
  Assert.IsTrue((Blu <> Verde) and (Blu <> Rosso) and (Blu <> Viola), 'blu diverso dagli altri');
  Assert.IsTrue((Verde <> Rosso) and (Verde <> Viola), 'verde diverso da rosso e viola');
  Assert.IsTrue(Rosso <> Viola, 'rosso diverso da viola');
end;

procedure TTestMapProprietaEColori.GetProperties_DueCampi_RigheNomeValore;
begin
  FMappa.GetProperties(FDataSet, 'ID;NOME', FElenco);

  Assert.AreEqual(2, FElenco.Count, 'numero di righe');
  Assert.AreEqual('ID=7', FElenco[0], 'prima riga');
  Assert.AreEqual('NOME=Rossi', FElenco[1], 'seconda riga');
end;

procedure TTestMapProprietaEColori.GetProperties_SeparatoreVirgolaECampoMancante_ValoreVuoto;
begin
  FMappa.GetProperties(FDataSet, 'ID,INESISTENTE', FElenco);

  Assert.AreEqual(2, FElenco.Count, 'numero di righe');
  Assert.AreEqual('ID=7', FElenco[0], 'campo esistente');
  Assert.AreEqual('INESISTENTE=', FElenco[1], 'campo mancante');
end;

procedure TTestMapProprietaEColori.GetProperties_ElencoPrecedenteENomiVuoti_ElencoSostituito;
begin
  FElenco.Add('vecchia=riga');

  FMappa.GetProperties(FDataSet, ';ID;;', FElenco);

  Assert.AreEqual(1, FElenco.Count, 'numero di righe');
  Assert.AreEqual('ID=7', FElenco[0], 'unica riga');
end;

procedure TTestMapProprietaEColori.GetProperties_CampoNullo_ValoreVuoto;
begin
  // secondo record: NOME e' nullo
  FDataSet.Last;

  FMappa.GetProperties(FDataSet, 'ID;NOME', FElenco);

  Assert.AreEqual('ID=8', FElenco[0], 'identificativo');
  Assert.AreEqual('NOME=', FElenco[1], 'campo nullo');
end;

procedure TTestMapProprietaEColori.GetProperties_NessunNome_ElencoVuoto;
begin
  FElenco.Add('vecchia=riga');

  FMappa.GetProperties(FDataSet, '', FElenco);

  Assert.AreEqual(0, FElenco.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMapChiaviServizio);
  TDUnitX.RegisterTestFixture(TTestMapEsitoGeocodifica);
  TDUnitX.RegisterTestFixture(TTestMapProprietaEColori);

end.
