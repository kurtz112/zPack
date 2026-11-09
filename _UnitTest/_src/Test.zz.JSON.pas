// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.JSON;

// Test DUnitX di zLibs\zz.JSON.pas: i due helper di TJSONObject e TJSONArray
// (specifica ZLIBS-JSN, "JSON di base.md"). Non e' la unit zz.JSON.DTO, che ha
// la sua specifica ZLIBS-DTO e il suo test (Test.zz.JSON.DTO). Nessuna
// dipendenza da database, rete o interfaccia.
//
// Gli oggetti JSON si liberano nel TearDown (l'oggetto del fixture) o con
// try/finally. Le funzioni dell'helper che sostituiscono un valore (setter,
// Replace, Clear) ne liberano il vecchio (DIV-JSN-4 e 5, corrette): se il
// programma di prova segnala perdite o liberazioni doppie, vengono da li'.
//
// Le divergenze DIV-JSN-6 (data scritta e non rileggibile), DIV-JSN-8 (le
// letture "Try" che sollevano invece di restituire falso) e DIV-JSN-9 (valore
// di ritorno di Replace), DIV-JSN-4, 5 e 7 (memoria dei valori sostituiti e
// Replace con nomi che differiscono per le maiuscole) sono corrette e provate.
// DIV-JSN-1 (codifica di Parse) e DIV-JSN-2 (errori di Parse ignorati,
// parzialmente provata) non sono provate fino in fondo: dipendono dalla pagina
// di codice della macchina.

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  DUnitX.TestFramework,
  zz.JSON;

type
  [TestFixture]
  TTestZzJson = class
  private
    FOggetto: TJSONObject;
    function EccezioneDi(const Procedura: TProc): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZLIBS-JSN-001
    [Test]
    procedure Add_TestoDiversoDalPredefinito_ScriveLaCoppia;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_TestoUgualeAlPredefinito_NonScrive;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_PredefinitoPersonalizzato_ScriveSoloSeDiverso;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_Intero_ScriveIlNumeroENonLoZero;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_Booleano_ScriveVeroENonFalso;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_BooleanoConPredefinitoVero_ScriveFalso;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_Decimale_ScriveIlNumeroConIlPunto;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_ChiaveGiaPresente_AggiungeUnaSecondaCoppia;
    // ZLIBS-JSN-001
    [Test]
    procedure Add_Decimale_ZeroNonScritto;
    // ZLIBS-JSN-002
    [Test]
    procedure Lettura_ChiaveAssente_ValoreVuotoPerOgniTipo;
    // ZLIBS-JSN-002
    [Test]
    procedure Lettura_TipiSemplici_ValoriLetti;
    // ZLIBS-JSN-002
    [Test]
    procedure Lettura_ConversioniCompatibili_NumeroInTestoETestoInNumero;
    // ZLIBS-JSN-002
    [Test]
    procedure Lettura_TestoCheNonEUnNumero_SollevaEJSONException;
    // ZLIBS-JSN-002
    [Test]
    procedure Lettura_ValoreNullEsplicito_ChiavePresenteETestoVuoto;
    // ZLIBS-JSN-002
    [Test]
    procedure Lettura_OggettoEArrayDelTipoSbagliato_Nil;
    // ZLIBS-JSN-003
    [Test]
    procedure Exist_ChiavePresenteEAssente_VeroEFalso;
    // ZLIBS-JSN-003
    [Test]
    procedure Exist_ChiaveConValoreNull_Vero;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaS_ValoreNuovo_SostituisceIlPrecedente;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaS_SostituzioneSpostaLaCoppiaInFondo;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaS_ValorePredefinito_RimuoveLaChiave;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaI_ValoreEZero_ScrittoLettoERimosso;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaI_ValoreOltre32Bit_Conservato;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaF_ValoreEZero_ScrittoLettoERimosso;
    // ZLIBS-JSN-004
    [Test]
    procedure ProprietaB_VeroEFalso_ScrittoLettoERimosso;
    // ZLIBS-JSN-005
    [Test]
    procedure AddDateTime_ValoreDiversoDaZero_FormatoAnnoMeseGiornoOreMinutiSecondi;
    // ZLIBS-JSN-005
    [Test]
    procedure AddDateTime_Zero_NonScrive;
    // ZLIBS-JSN-005
    [Test]
    procedure Data_LetturaIso8601ConLaT_ValoreCorretto;
    // ZLIBS-JSN-005
    [Test]
    procedure Data_LetturaSoloData_MezzanotteDelGiorno;
    // ZLIBS-JSN-005
    [Test]
    procedure Data_ChiaveAssente_Zero;
    // ZLIBS-JSN-006
    [Test]
    procedure AddObject_Figlio_AgganciatoAlPadre;
    // ZLIBS-JSN-006
    [Test]
    procedure AddArray_Elementi_AgganciatiAlPadre;
    // ZLIBS-JSN-006
    [Test]
    procedure ProprietaO_OggettoAssegnato_LettoEPossedutoDalPadre;
    // ZLIBS-JSN-006
    [Test]
    procedure ProprietaO_Nil_ScriveNullEIlGetterRestituisceNil;
    // ZLIBS-JSN-006
    [Test]
    procedure ProprietaA_ArrayAssegnato_LettoEPossedutoDalPadre;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGetString_Presente_VeroEValore;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGet_ChiaveAssente_FalsoEValoreInvariato;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGetInt_TreTipiDiRisultato_ValoreLetto;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGetFloat_DoppiaESingola_ValoreLetto;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGetBoolean_Presente_VeroEValore;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGetDateTime_Iso8601_VeroEValore;
    // ZLIBS-JSN-007
    [Test]
    procedure TryGetString_ValoreNull_VeroETestoVuoto;
    // ZLIBS-JSN-008
    [Test]
    procedure Parse_OggettoValido_ValoriLeggibili;
    // ZLIBS-JSN-008
    [Test]
    procedure Parse_OggettoAnnidato_FigliLeggibili;
    // ZLIBS-JSN-008
    [Test]
    procedure Parse_OggettoGiaPieno_AccodaLeCoppie;
    // ZLIBS-JSN-008
    [Test]
    procedure Parse_TestoCheNonEUnOggetto_NessunErroreENessunaCoppia;
    // ZLIBS-JSN-008
    [Test]
    procedure Parse_TestoVuoto_NessunErroreENessunaCoppia;
    // ZLIBS-JSN-009
    [Test]
    procedure Replace_ChiaveEsistente_SostituisceNellaStessaPosizione;
    // ZLIBS-JSN-009
    [Test]
    procedure Replace_ChiaveAssente_AccodaLaCoppia;
    // ZLIBS-JSN-009
    [Test]
    procedure Replace_OggettoVuoto_AggiungeERestituisceLOggetto;
    // ZLIBS-JSN-009
    [Test]
    procedure Replace_MaiuscoleDiverse_SostituisceEPrendeIlNuovoNome;
    // ZLIBS-JSN-010
    [Test]
    procedure ArrayClear_ConElementi_SvuotaLArray;
    // ZLIBS-JSN-010
    [Test]
    procedure ArrayClear_ArrayVuoto_NessunErrore;
    // ZLIBS-JSN-010
    [Test]
    procedure ArrayReplace_IndiceCentrale_SostituisceIlValore;
    // ZLIBS-JSN-010
    [Test]
    procedure ArrayReplace_PrimoEUltimo_SostituisceIValori;
    // ZLIBS-JSN-010
    [Test]
    procedure ArrayReplace_IndiceUgualeAlConteggio_Accoda;
    // DIV-JSN-6
    [Test]
    procedure DataScrittaConLoSpazio_SiRilegge;
    // DIV-JSN-6
    [Test]
    procedure DataScrittaDallaProprieta_SiRilegge;
    // DIV-JSN-6
    [Test]
    procedure TryGetDateTime_DataScritta_SiRilegge;
    // DIV-JSN-8
    [Test]
    procedure TryGetIntSuTesto_RestituisceFalsoEParametroInvariato;
    // DIV-JSN-8
    [Test]
    procedure TryGetDateTimeSuTesto_RestituisceFalso;
    // DIV-JSN-9
    [Test]
    procedure Replace_OggettoNonVuoto_RestituisceLOggetto;
    // DIV-JSN-7
    [Test]
    procedure Divergenza_DIV_JSN_7_ChiaviCheDifferisconoPerMaiuscole_UnaSolaCoppia;
    // DIV-JSN-4
    [Test]
    procedure Divergenza_DIV_JSN_4_SetterRipetuto_UnaSolaCoppiaConUltimoValore;
    // DIV-JSN-5
    [Test]
    procedure Divergenza_DIV_JSN_5_ArrayReplaceEClear_LiberanoGliElementi;
  end;

implementation

// TTestZzJson

procedure TTestZzJson.Setup;
begin
  FOggetto := TJSONObject.Create;
end;

procedure TTestZzJson.TearDown;
begin
  FreeAndNil(FOggetto);
end;

function TTestZzJson.EccezioneDi(const Procedura: TProc): string;
begin
  Result := '';
  try
    Procedura();
  except
    on E: Exception do
      Result := E.ClassName;
  end;
end;

procedure TTestZzJson.Add_TestoDiversoDalPredefinito_ScriveLaCoppia;
begin
  FOggetto.Add('nome', 'Rossi');

  Assert.AreEqual('{"nome":"Rossi"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Add_TestoUgualeAlPredefinito_NonScrive;
begin
  FOggetto.Add('nome', '');

  Assert.AreEqual(0, FOggetto.Count, 'nessuna coppia');
  Assert.AreEqual('{}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Add_PredefinitoPersonalizzato_ScriveSoloSeDiverso;
begin
  FOggetto.Add('stato', 'A', 'A');
  Assert.AreEqual(0, FOggetto.Count, 'uguale al predefinito: non scritto');

  FOggetto.Add('stato', 'B', 'A');
  Assert.AreEqual('{"stato":"B"}', FOggetto.ToJSON, 'diverso dal predefinito: scritto');
end;

procedure TTestZzJson.Add_Intero_ScriveIlNumeroENonLoZero;
var
  Cinque: Int64;
  Zero: Int64;
begin
  Cinque := 5;
  Zero := 0;

  FOggetto.Add('quantita', Cinque);
  FOggetto.Add('resto', Zero);

  Assert.AreEqual('{"quantita":5}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Add_Booleano_ScriveVeroENonFalso;
var
  Vero: Boolean;
  Falso: Boolean;
begin
  Vero := True;
  Falso := False;

  FOggetto.Add('attivo', Vero);
  FOggetto.Add('sospeso', Falso);

  Assert.AreEqual('{"attivo":true}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Add_BooleanoConPredefinitoVero_ScriveFalso;
var
  Falso: Boolean;
  Vero: Boolean;
begin
  Falso := False;
  Vero := True;

  FOggetto.Add('abilitato', Falso, Vero);

  Assert.AreEqual('{"abilitato":false}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Add_Decimale_ScriveIlNumeroConIlPunto;
var
  Importo: Double;
begin
  Importo := 12.5;

  FOggetto.Add('importo', Importo);

  Assert.AreEqual('{"importo":12.5}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Add_ChiaveGiaPresente_AggiungeUnaSecondaCoppia;
begin
  // Add non sostituisce: per sostituire servono le proprieta' S, I, F, B, D
  // oppure Replace
  FOggetto.Add('chiave', 'a');
  FOggetto.Add('chiave', 'b');

  Assert.AreEqual(2, FOggetto.Count, 'due coppie con la stessa chiave');
  Assert.AreEqual('a', FOggetto.S['chiave'], 'la lettura trova la prima');
end;

procedure TTestZzJson.Add_Decimale_ZeroNonScritto;
var
  Zero: Double;
begin
  Zero := 0;

  FOggetto.Add('importo', Zero);

  Assert.AreEqual(0, FOggetto.Count);
end;

procedure TTestZzJson.Lettura_ChiaveAssente_ValoreVuotoPerOgniTipo;
begin
  Assert.AreEqual('', FOggetto.GetString('x'), 'testo');
  Assert.IsTrue(FOggetto.GetInt64('x') = 0, 'intero');
  Assert.AreEqual(Double(0), FOggetto.GetFloat('x'), 0.0000001, 'decimale');
  Assert.IsFalse(FOggetto.GetBoolean('x'), 'booleano');
  Assert.AreEqual(Double(0), Double(FOggetto.GetDateTime('x')), 0.0000001, 'data');
  Assert.IsTrue(FOggetto.GetJsonObject('x') = nil, 'oggetto');
  Assert.IsTrue(FOggetto.GetJsonArray('x') = nil, 'array');
  // le stesse tramite le proprieta'
  Assert.AreEqual('', FOggetto.S['x'], 'S');
  Assert.IsTrue(FOggetto.I['x'] = 0, 'I');
  Assert.IsFalse(FOggetto.B['x'], 'B');
end;

procedure TTestZzJson.Lettura_TipiSemplici_ValoriLetti;
begin
  FOggetto.Parse('{"s":"Rossi","i":42,"f":1.5,"b":true}');

  Assert.AreEqual('Rossi', FOggetto.GetString('s'), 'testo');
  Assert.IsTrue(FOggetto.GetInt64('i') = 42, 'intero');
  Assert.AreEqual(Double(1.5), FOggetto.GetFloat('f'), 0.0000001, 'decimale');
  Assert.IsTrue(FOggetto.GetBoolean('b'), 'booleano');
end;

procedure TTestZzJson.Lettura_ConversioniCompatibili_NumeroInTestoETestoInNumero;
begin
  FOggetto.Parse('{"n":5,"t":"7","v":"true","u":1,"z":0}');

  Assert.AreEqual('5', FOggetto.S['n'], 'numero letto come testo');
  Assert.IsTrue(FOggetto.I['t'] = 7, 'testo numerico letto come intero');
  Assert.IsTrue(FOggetto.B['v'], 'testo true letto come booleano');
  Assert.IsTrue(FOggetto.B['u'], 'numero 1 letto come booleano vero');
  Assert.IsFalse(FOggetto.B['z'], 'numero 0 letto come booleano falso');
end;

procedure TTestZzJson.Lettura_TestoCheNonEUnNumero_SollevaEJSONException;
var
  Classe: string;
begin
  FOggetto.Parse('{"k":"abc"}');

  Classe := EccezioneDi(
    procedure
    begin
      FOggetto.GetInt64('k');
    end);

  Assert.AreEqual('EJSONException', Classe);
end;

procedure TTestZzJson.Lettura_ValoreNullEsplicito_ChiavePresenteETestoVuoto;
begin
  FOggetto.Parse('{"k":null}');

  Assert.IsTrue(FOggetto.Exist('k'), 'la chiave esiste');
  Assert.AreEqual('', FOggetto.GetString('k'), 'testo vuoto');
  Assert.IsTrue(FOggetto.GetJsonObject('k') = nil, 'non e'' un oggetto');
end;

procedure TTestZzJson.Lettura_OggettoEArrayDelTipoSbagliato_Nil;
begin
  FOggetto.Parse('{"o":{"a":1},"a":[1,2],"t":"x"}');

  Assert.IsTrue(FOggetto.GetJsonArray('o') = nil, 'un oggetto non e'' un array');
  Assert.IsTrue(FOggetto.GetJsonObject('a') = nil, 'un array non e'' un oggetto');
  Assert.IsTrue(FOggetto.GetJsonObject('t') = nil, 'un testo non e'' un oggetto');
  Assert.IsTrue(FOggetto.GetJsonArray('t') = nil, 'un testo non e'' un array');
  Assert.IsTrue(FOggetto.GetJsonObject('o') <> nil, 'l''oggetto e'' un oggetto');
  Assert.IsTrue(FOggetto.GetJsonArray('a') <> nil, 'l''array e'' un array');
end;

procedure TTestZzJson.Exist_ChiavePresenteEAssente_VeroEFalso;
begin
  FOggetto.Parse('{"a":"x"}');

  Assert.IsTrue(FOggetto.Exist('a'), 'presente');
  Assert.IsFalse(FOggetto.Exist('b'), 'assente');
  Assert.IsFalse(FOggetto.Exist('A'), 'le chiavi distinguono le maiuscole');
end;

procedure TTestZzJson.Exist_ChiaveConValoreNull_Vero;
begin
  FOggetto.Parse('{"a":null}');

  Assert.IsTrue(FOggetto.Exist('a'));
end;

procedure TTestZzJson.ProprietaS_ValoreNuovo_SostituisceIlPrecedente;
begin
  FOggetto.S['a'] := 'x';
  FOggetto.S['a'] := 'y';

  Assert.AreEqual(1, FOggetto.Count, 'una sola coppia');
  Assert.AreEqual('{"a":"y"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.ProprietaS_SostituzioneSpostaLaCoppiaInFondo;
begin
  FOggetto.S['a'] := '1';
  FOggetto.S['b'] := '2';

  FOggetto.S['a'] := '3';

  Assert.AreEqual('{"b":"2","a":"3"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.ProprietaS_ValorePredefinito_RimuoveLaChiave;
begin
  FOggetto.S['a'] := 'x';
  Assert.IsTrue(FOggetto.Exist('a'), 'scritta');

  FOggetto.S['a'] := '';

  Assert.IsFalse(FOggetto.Exist('a'), 'rimossa: il testo vuoto non si scrive');
  Assert.AreEqual('', FOggetto.S['a'], 'si legge comunque vuoto');
end;

procedure TTestZzJson.ProprietaI_ValoreEZero_ScrittoLettoERimosso;
begin
  FOggetto.I['n'] := 42;
  Assert.IsTrue(FOggetto.I['n'] = 42, 'letto');
  Assert.AreEqual('{"n":42}', FOggetto.ToJSON, 'scritto come numero');

  FOggetto.I['n'] := 0;
  Assert.IsFalse(FOggetto.Exist('n'), 'zero: la chiave sparisce');
end;

procedure TTestZzJson.ProprietaI_ValoreOltre32Bit_Conservato;
begin
  FOggetto.I['grande'] := 5000000000;

  Assert.IsTrue(FOggetto.I['grande'] = 5000000000, 'valore letto');
  Assert.AreEqual('{"grande":5000000000}', FOggetto.ToJSON);
end;

procedure TTestZzJson.ProprietaF_ValoreEZero_ScrittoLettoERimosso;
begin
  FOggetto.F['f'] := 12.5;
  Assert.AreEqual(Double(12.5), FOggetto.F['f'], 0.0000001, 'letto');

  FOggetto.F['f'] := 0;
  Assert.IsFalse(FOggetto.Exist('f'), 'zero: la chiave sparisce');
end;

procedure TTestZzJson.ProprietaB_VeroEFalso_ScrittoLettoERimosso;
begin
  FOggetto.B['b'] := True;
  Assert.IsTrue(FOggetto.B['b'], 'vero letto');
  Assert.AreEqual('{"b":true}', FOggetto.ToJSON, 'scritto come booleano');

  FOggetto.B['b'] := False;
  Assert.IsFalse(FOggetto.Exist('b'), 'falso: la chiave sparisce');
  Assert.IsFalse(FOggetto.B['b'], 'si legge comunque falso');
end;

procedure TTestZzJson.AddDateTime_ValoreDiversoDaZero_FormatoAnnoMeseGiornoOreMinutiSecondi;
var
  Istante: TDateTime;
begin
  // il separatore delle ore e' quello della macchina (:) nelle impostazioni italiane
  Istante := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 15, 0);

  FOggetto.AddDateTime('quando', Istante);

  Assert.AreEqual('{"quando":"2026-11-01 10:30:15"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.AddDateTime_Zero_NonScrive;
begin
  FOggetto.AddDateTime('quando', 0);
  FOggetto.D['altro'] := 0;

  Assert.AreEqual(0, FOggetto.Count);
end;

procedure TTestZzJson.Data_LetturaIso8601ConLaT_ValoreCorretto;
var
  Atteso: TDateTime;
begin
  Atteso := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 15, 0);
  FOggetto.Parse('{"d":"2026-11-01T10:30:15"}');

  Assert.AreEqual(Double(Atteso), Double(FOggetto.D['d']), 0.00000001);
  Assert.AreEqual(Double(Atteso), Double(FOggetto.GetDateTime('d')), 0.00000001);
end;

procedure TTestZzJson.Data_LetturaSoloData_MezzanotteDelGiorno;
begin
  FOggetto.Parse('{"d":"2026-11-01"}');

  Assert.AreEqual(Double(EncodeDate(2026, 11, 1)), Double(FOggetto.D['d']), 0.00000001);
end;

procedure TTestZzJson.Data_ChiaveAssente_Zero;
begin
  Assert.AreEqual(Double(0), Double(FOggetto.D['assente']), 0.00000001);
end;

procedure TTestZzJson.AddObject_Figlio_AgganciatoAlPadre;
var
  Figlio: TJSONObject;
begin
  Figlio := FOggetto.AddObject('cliente');
  Figlio.Add('nome', 'Rossi');

  Assert.AreEqual('{"cliente":{"nome":"Rossi"}}', FOggetto.ToJSON);
  Assert.IsTrue(FOggetto.GetJsonObject('cliente') = Figlio, 'GetJsonObject restituisce lo stesso figlio');
end;

procedure TTestZzJson.AddArray_Elementi_AgganciatiAlPadre;
var
  Voci: TJSONArray;
begin
  Voci := FOggetto.AddArray('voci');
  Voci.Add('uno').Add('due');

  Assert.AreEqual('{"voci":["uno","due"]}', FOggetto.ToJSON);
  Assert.IsTrue(FOggetto.GetJsonArray('voci') = Voci, 'GetJsonArray restituisce lo stesso array');
  Assert.AreEqual(2, FOggetto.A['voci'].Count, 'due elementi');
end;

procedure TTestZzJson.ProprietaO_OggettoAssegnato_LettoEPossedutoDalPadre;
var
  Figlio: TJSONObject;
begin
  Figlio := TJSONObject.Create;
  Figlio.Add('nome', 'Rossi');

  // il padre ne prende la proprieta': non va liberato a parte
  FOggetto.O['cliente'] := Figlio;

  Assert.IsTrue(FOggetto.O['cliente'] = Figlio, 'letto');
  Assert.AreEqual('Rossi', FOggetto.O['cliente'].S['nome']);
end;

procedure TTestZzJson.ProprietaO_Nil_ScriveNullEIlGetterRestituisceNil;
begin
  FOggetto.O['cliente'] := nil;

  Assert.AreEqual('{"cliente":null}', FOggetto.ToJSON, 'scritto null');
  Assert.IsTrue(FOggetto.Exist('cliente'), 'la chiave esiste');
  Assert.IsTrue(FOggetto.O['cliente'] = nil, 'il getter restituisce nil');
end;

procedure TTestZzJson.ProprietaA_ArrayAssegnato_LettoEPossedutoDalPadre;
var
  Voci: TJSONArray;
begin
  Voci := TJSONArray.Create;
  Voci.Add('x');

  FOggetto.A['voci'] := Voci;

  Assert.IsTrue(FOggetto.A['voci'] = Voci, 'letto');
  Assert.AreEqual('{"voci":["x"]}', FOggetto.ToJSON);
end;

procedure TTestZzJson.TryGetString_Presente_VeroEValore;
var
  Valore: string;
begin
  FOggetto.Parse('{"s":"Rossi"}');

  Assert.IsTrue(FOggetto.TryGetString('s', Valore), 'presente');
  Assert.AreEqual('Rossi', Valore);
end;

procedure TTestZzJson.TryGet_ChiaveAssente_FalsoEValoreInvariato;
var
  Testo: string;
  Intero: Integer;
  Flag: Boolean;
  Decimale: Double;
  Istante: TDateTime;
begin
  Testo := 'prima';
  Intero := 7;
  Flag := True;
  Decimale := 2.5;
  Istante := 100;

  Assert.IsFalse(FOggetto.TryGetString('x', Testo), 'testo');
  Assert.IsFalse(FOggetto.TryGetInt('x', Intero), 'intero');
  Assert.IsFalse(FOggetto.TryGetBoolean('x', Flag), 'booleano');
  Assert.IsFalse(FOggetto.TryGetFloat('x', Decimale), 'decimale');
  Assert.IsFalse(FOggetto.TryGetDateTime('x', Istante), 'data');

  Assert.AreEqual('prima', Testo, 'testo invariato');
  Assert.AreEqual(7, Intero, 'intero invariato');
  Assert.IsTrue(Flag, 'booleano invariato');
  Assert.AreEqual(Double(2.5), Decimale, 0.0000001, 'decimale invariato');
  Assert.AreEqual(Double(100), Double(Istante), 0.0000001, 'data invariata');
end;

procedure TTestZzJson.TryGetInt_TreTipiDiRisultato_ValoreLetto;
var
  Corto: Integer;
  Lungo: Int64;
  SenzaSegno: Cardinal;
begin
  FOggetto.Parse('{"i":42,"g":5000000000,"c":4000000000}');

  Assert.IsTrue(FOggetto.TryGetInt('i', Corto), 'Integer: presente');
  Assert.AreEqual(42, Corto, 'Integer: valore');
  Assert.IsTrue(FOggetto.TryGetInt('g', Lungo), 'Int64: presente');
  Assert.IsTrue(Lungo = 5000000000, 'Int64: valore');
  Assert.IsTrue(FOggetto.TryGetInt('c', SenzaSegno), 'Cardinal: presente');
  Assert.IsTrue(SenzaSegno = 4000000000, 'Cardinal: valore');
end;

procedure TTestZzJson.TryGetFloat_DoppiaESingola_ValoreLetto;
var
  Doppia: Double;
  Singola: Single;
begin
  FOggetto.Parse('{"f":1.5}');

  Assert.IsTrue(FOggetto.TryGetFloat('f', Doppia), 'Double: presente');
  Assert.AreEqual(Double(1.5), Doppia, 0.0000001, 'Double: valore');
  Assert.IsTrue(FOggetto.TryGetFloat('f', Singola), 'Single: presente');
  Assert.AreEqual(Double(1.5), Double(Singola), 0.0000001, 'Single: valore');
end;

procedure TTestZzJson.TryGetBoolean_Presente_VeroEValore;
var
  Flag: Boolean;
begin
  FOggetto.Parse('{"b":true,"f":false}');

  Assert.IsTrue(FOggetto.TryGetBoolean('b', Flag), 'b presente');
  Assert.IsTrue(Flag, 'b vero');
  Assert.IsTrue(FOggetto.TryGetBoolean('f', Flag), 'f presente');
  Assert.IsFalse(Flag, 'f falso');
end;

procedure TTestZzJson.TryGetDateTime_Iso8601_VeroEValore;
var
  Istante: TDateTime;
begin
  FOggetto.Parse('{"d":"2026-11-01T10:30:15"}');

  Assert.IsTrue(FOggetto.TryGetDateTime('d', Istante), 'presente');
  Assert.AreEqual(Double(EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 15, 0)), Double(Istante), 0.00000001);
end;

procedure TTestZzJson.TryGetString_ValoreNull_VeroETestoVuoto;
var
  Testo: string;
begin
  FOggetto.Parse('{"k":null}');
  Testo := 'prima';

  Assert.IsTrue(FOggetto.TryGetString('k', Testo), 'la chiave c''e'': vero');
  Assert.AreEqual('', Testo, 'testo vuoto');
end;

procedure TTestZzJson.Parse_OggettoValido_ValoriLeggibili;
begin
  FOggetto.Parse('{"a":"1","b":2}');

  Assert.AreEqual(2, FOggetto.Count, 'due coppie');
  Assert.AreEqual('1', FOggetto.S['a']);
  Assert.IsTrue(FOggetto.I['b'] = 2, 'b');
end;

procedure TTestZzJson.Parse_OggettoAnnidato_FigliLeggibili;
begin
  FOggetto.Parse('{"a":{"b":[1,2]}}');

  Assert.IsTrue(FOggetto.O['a'] <> nil, 'oggetto figlio');
  Assert.IsTrue(FOggetto.O['a'].A['b'] <> nil, 'array nipote');
  Assert.AreEqual(2, FOggetto.O['a'].A['b'].Count, 'due elementi');
end;

procedure TTestZzJson.Parse_OggettoGiaPieno_AccodaLeCoppie;
begin
  FOggetto.S['prima'] := 'x';

  FOggetto.Parse('{"a":"1"}');

  Assert.AreEqual(2, FOggetto.Count, 'la coppia gia'' presente resta');
  Assert.AreEqual('x', FOggetto.S['prima']);
  Assert.AreEqual('1', FOggetto.S['a']);
end;

procedure TTestZzJson.Parse_TestoCheNonEUnOggetto_NessunErroreENessunaCoppia;
begin
  // l'esito di Parse (negativo in caso di errore) viene ignorato
  FOggetto.Parse('questo non e'' JSON');

  Assert.AreEqual(0, FOggetto.Count);
end;

procedure TTestZzJson.Parse_TestoVuoto_NessunErroreENessunaCoppia;
begin
  FOggetto.Parse('');

  Assert.AreEqual(0, FOggetto.Count);
end;

procedure TTestZzJson.Replace_ChiaveEsistente_SostituisceNellaStessaPosizione;
begin
  FOggetto.Parse('{"a":"1","b":"2","c":"3"}');

  // il valore di ritorno non si usa: vedi DIV-JSN-9
  FOggetto.Replace('b', TJSONString.Create('X'));

  Assert.AreEqual('{"a":"1","b":"X","c":"3"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Replace_ChiaveAssente_AccodaLaCoppia;
begin
  FOggetto.Parse('{"a":"1"}');

  FOggetto.Replace('z', TJSONString.Create('9'));

  Assert.AreEqual('{"a":"1","z":"9"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Replace_OggettoVuoto_AggiungeERestituisceLOggetto;
var
  Risultato: TJSONObject;
begin
  Risultato := FOggetto.Replace('a', TJSONString.Create('1'));

  Assert.IsTrue(Risultato = FOggetto, 'oggetto vuoto: restituisce l''oggetto stesso');
  Assert.AreEqual('{"a":"1"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Replace_MaiuscoleDiverse_SostituisceEPrendeIlNuovoNome;
begin
  FOggetto.Parse('{"nome":"x","altro":"y"}');

  FOggetto.Replace('NOME', TJSONString.Create('Z'));

  Assert.AreEqual(2, FOggetto.Count, 'nessuna coppia in piu''');
  Assert.AreEqual('{"NOME":"Z","altro":"y"}', FOggetto.ToJSON, 'sostituita con il nome nuovo');
end;

procedure TTestZzJson.ArrayClear_ConElementi_SvuotaLArray;
var
  Elenco: TJSONArray;
begin
  Elenco := TJSONArray.Create;
  try
    Elenco.Add(1).Add(2).Add(3);
    Assert.AreEqual(3, Elenco.Count, 'prima');

    Elenco.Clear;

    Assert.AreEqual(0, Elenco.Count, 'dopo');
    Assert.AreEqual('[]', Elenco.ToJSON);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZzJson.ArrayClear_ArrayVuoto_NessunErrore;
var
  Elenco: TJSONArray;
begin
  Elenco := TJSONArray.Create;
  try
    Elenco.Clear;

    Assert.AreEqual(0, Elenco.Count);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZzJson.ArrayReplace_IndiceCentrale_SostituisceIlValore;
var
  Elenco: TJSONArray;
  Risultato: TJSONArray;
begin
  Elenco := TJSONArray.Create;
  try
    Elenco.Add(1).Add(2).Add(3);

    Risultato := Elenco.Replace(1, TJSONNumber.Create(9));

    Assert.IsTrue(Risultato = Elenco, 'restituisce l''array stesso');
    Assert.AreEqual('[1,9,3]', Elenco.ToJSON);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZzJson.ArrayReplace_PrimoEUltimo_SostituisceIValori;
var
  Elenco: TJSONArray;
begin
  Elenco := TJSONArray.Create;
  try
    Elenco.Add(1).Add(2).Add(3);

    Elenco.Replace(0, TJSONNumber.Create(7));
    Elenco.Replace(2, TJSONNumber.Create(8));

    Assert.AreEqual('[7,2,8]', Elenco.ToJSON);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZzJson.ArrayReplace_IndiceUgualeAlConteggio_Accoda;
var
  Elenco: TJSONArray;
begin
  Elenco := TJSONArray.Create;
  try
    Elenco.Add(1).Add(2).Add(3);

    // l'indice e' ammesso fino al conteggio: oltre l'ultimo elemento si accoda
    Elenco.Replace(3, TJSONNumber.Create(4));

    Assert.AreEqual('[1,2,3,4]', Elenco.ToJSON);
  finally
    Elenco.Free;
  end;
end;

procedure TTestZzJson.DataScrittaConLoSpazio_SiRilegge;
var
  Istante: TDateTime;
begin
  // DIV-JSN-6: AddDateTime scrive "aaaa-mm-gg hh:nn:ss" (con lo spazio) e la
  // lettura deve accettare lo stesso formato.
  Istante := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 15, 0);
  FOggetto.AddDateTime('quando', Istante);

  Assert.AreEqual('2026-11-01 10:30:15', FOggetto.GetString('quando'));
  Assert.AreEqual(Double(Istante), Double(FOggetto.D['quando']), 0.00001);
end;

procedure TTestZzJson.DataScrittaDallaProprieta_SiRilegge;
var
  Istante: TDateTime;
begin
  // DIV-JSN-6: la proprieta' D scrive il numero della data e lo rilegge
  Istante := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 15, 0);
  FOggetto.D['quando'] := Istante;

  Assert.AreEqual(Double(Istante), Double(FOggetto.D['quando']), 0.00001);
end;

procedure TTestZzJson.TryGetDateTime_DataScritta_SiRilegge;
var
  Istante: TDateTime;
  Letto: TDateTime;
begin
  // DIV-JSN-6, lettura "Try"
  Istante := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 15, 0);
  FOggetto.AddDateTime('quando', Istante);
  Letto := 0;

  Assert.IsTrue(FOggetto.TryGetDateTime('quando', Letto));
  Assert.AreEqual(Double(Istante), Double(Letto), 0.00001);
end;

procedure TTestZzJson.TryGetIntSuTesto_RestituisceFalsoEParametroInvariato;
var
  Intero: Integer;
begin
  // DIV-JSN-8: valore presente ma non convertibile = falso, senza errore
  FOggetto.Parse('{"k":"abc"}');
  Intero := 77;

  Assert.IsFalse(FOggetto.TryGetInt('k', Intero));
  Assert.AreEqual(77, Intero, 'il parametro resta com''era');
end;

procedure TTestZzJson.TryGetDateTimeSuTesto_RestituisceFalso;
var
  Letto: TDateTime;
begin
  // DIV-JSN-8
  FOggetto.Parse('{"k":"non una data"}');
  Letto := 5;

  Assert.IsFalse(FOggetto.TryGetDateTime('k', Letto));
  Assert.AreEqual(5.0, Double(Letto), 0.00001);
end;

procedure TTestZzJson.Replace_OggettoNonVuoto_RestituisceLOggetto;
var
  Risultato: TJSONObject;
begin
  // DIV-JSN-9: il valore di ritorno era indefinito con l'oggetto non vuoto
  FOggetto.Parse('{"a":"1"}');

  Risultato := FOggetto.Replace('a', TJSONString.Create('2'));

  Assert.AreSame(FOggetto, Risultato);
end;

procedure TTestZzJson.Divergenza_DIV_JSN_7_ChiaviCheDifferisconoPerMaiuscole_UnaSolaCoppia;
begin
  // DIV-JSN-7: prima ogni chiave che corrispondeva riceveva lo stesso valore e
  // alla liberazione dell'oggetto il valore veniva liberato due volte
  FOggetto.Parse('{"a":"1","A":"2","b":"3"}');

  FOggetto.Replace('a', TJSONString.Create('9'));

  Assert.AreEqual(2, FOggetto.Count, 'le coppie che corrispondono diventano una sola');
  Assert.AreEqual('{"a":"9","b":"3"}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Divergenza_DIV_JSN_4_SetterRipetuto_UnaSolaCoppiaConUltimoValore;
begin
  // DIV-JSN-4: la coppia sostituita ora viene liberata con il suo valore
  FOggetto.S['nome'] := 'x';
  FOggetto.S['nome'] := 'y';
  FOggetto.I['numero'] := 1;
  FOggetto.I['numero'] := 2;

  Assert.AreEqual(2, FOggetto.Count);
  Assert.AreEqual('{"nome":"y","numero":2}', FOggetto.ToJSON);
end;

procedure TTestZzJson.Divergenza_DIV_JSN_5_ArrayReplaceEClear_LiberanoGliElementi;
var
  Elenco: TJSONArray;
begin
  // DIV-JSN-5: l'elemento sostituito e quelli tolti da Clear ora vengono liberati
  Elenco := TJSONArray.Create;
  try
    Elenco.Add(1);
    Elenco.Add(2);
    Elenco.Add(3);

    Elenco.Replace(1, TJSONNumber.Create(9));
    Assert.AreEqual('[1,9,3]', Elenco.ToJSON);

    Elenco.Clear;
    Assert.AreEqual(0, Elenco.Count);
  finally
    Elenco.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZzJson);

end.
