// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zOverrides;

// Prove delle personalizzazioni di campo (specifica "Personalizzazioni dei
// campi", ZBASE-OVR) di zOverrides.pas: caricamento della tabella OVERRIDES,
// flag attivi, ricerche, didascalie, Add, Remove e Assign.
//
// La tabella OVERRIDES gira su SQLite in memoria, senza Firebird. Restano fuori
// dalle prove SaveItem (chiama la procedura OVERRIDE_SAVE) e l'effetto di
// InitFields sui valori predefiniti, che richiedono Firebird e un dataset.
//
// Overrides e' un oggetto unico di processo: TearDown lo riporta a vuoto
// ricaricandolo da una tabella vuota (la proprieta' Loaded resta vera).

interface

uses
  System.SysUtils,
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
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  DUnitX.TestFramework,
  zOverrides;

type
  [TestFixture]
  TTestOverrides = class
  private
    FConnessione: TFDConnection;
    // i valori sono frammenti di SQL: 'NULL' o un testo fra apici, 0 o 1
    procedure Inserisci(const Dataset, Campo, DidascaliaScheda, DidascaliaGriglia: string; const ForzaObbligatorio, ForzaSolaLettura, ForzaNascosto, SopprimiPredefinito: Integer; const Nota: string = 'NULL');
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-OVR-001
    [Test]
    procedure LoadFromDB_TabellaVuota_CollezioneVuotaECaricata;
    // ZBASE-OVR-001
    [Test]
    procedure LoadFromDB_DueRighe_UnElementoPerRiga;
    // ZBASE-OVR-001
    [Test]
    procedure LoadFromDB_Ricaricamento_SostituisceIlContenuto;
    // ZBASE-OVR-001
    [Test]
    procedure LoadFromDB_LeggeNotaEProprieta;
    // ZBASE-OVR-003
    [Test]
    procedure LoadFromDB_DidascaliaNulla_FlagNonAttivo;
    // ZBASE-OVR-003
    [Test]
    procedure LoadFromDB_DidascaliaVuotaMaNonNulla_FlagAttivo;
    // ZBASE-OVR-003
    [Test]
    procedure LoadFromDB_Booleani_SoloIVeriSonoAttivi;
    // ZBASE-OVR-003
    [Test]
    procedure LoadFromDB_TuttiIFlagBooleani_Attivi;

    // ZBASE-OVR-002
    [Test]
    procedure Key_TuttoMaiuscolo;
    // ZBASE-OVR-002
    [Test]
    procedure FindOverride_SenzaDistinzioneMaiuscole;
    // ZBASE-OVR-002
    [Test]
    procedure FindOverride_Assente_Nil;
    // ZBASE-OVR-002
    [Test]
    procedure OverrideExists_Dataset_SenzaFlag_VeroSeEsisteUnaRiga;
    // ZBASE-OVR-002
    [Test]
    procedure OverrideExists_DatasetSconosciuto_Falso;
    // ZBASE-OVR-002
    [Test]
    procedure OverrideExists_Dataset_ConFlag_SoloSeAlmenoUnElementoLoHaAttivo;
    // ZBASE-OVR-002
    [Test]
    procedure OverrideExists_Campo_AlmenoUnoDeiFlagRichiesti;
    // ZBASE-OVR-002
    [Test]
    procedure OverrideExists_Campo_SenzaFlag_BastaChePersonalizzazioneEsista;
    // ZBASE-OVR-002
    [Test]
    procedure OverrideExists_CampoSconosciuto_Falso;

    // ZBASE-OVR-004
    [Test]
    procedure CaptionGrid_FlagAttivo_RestituisceIlTesto;
    // ZBASE-OVR-004
    [Test]
    procedure CaptionCard_FlagAttivo_RestituisceIlTesto;
    // ZBASE-OVR-004
    [Test]
    procedure Caption_FlagNonAttivo_StringaVuota;
    // ZBASE-OVR-004
    [Test]
    procedure Caption_CampoSconosciuto_StringaVuota;

    // ZBASE-OVR-006
    [Test]
    procedure Add_NonEVisibileFinoAlSalvataggio;
    // ZBASE-OVR-006
    [Test]
    procedure Remove_ElementoAggiuntoMaiSalvato_TornaAlConteggioDiPrima;
    // ZBASE-OVR-006
    [Test]
    procedure Remove_Nil_NessunErrore;
    // ZBASE-OVR-006
    [Test]
    procedure Collezione_Add_ActiveFlagsVuoto;
    // ZBASE-OVR-006
    [Test]
    procedure Collezione_FindItem_SenzaDistinzioneMaiuscole;
    // ZBASE-OVR-006
    [Test]
    procedure Assign_CopiaProprietaEActiveFlags;
  end;

implementation

{ TTestOverrides }

procedure TTestOverrides.Setup;
begin
  FConnessione := TFDConnection.Create(nil);
  FConnessione.LoginPrompt := false;
  FConnessione.Params.Values['DriverID'] := 'SQLite';
  FConnessione.Params.Values['Database'] := ':memory:';
  FConnessione.Open;

  // stessa forma della tabella di Firebird: i quattro flag sono booleani
  // obbligatori con valore predefinito falso, le didascalie facoltative
  FConnessione.ExecSQL('CREATE TABLE OVERRIDES (' +
    'DATASET VARCHAR(100) NOT NULL, ' +
    'FIELD_NAME VARCHAR(63) NOT NULL, ' +
    'CAPTION_CARD VARCHAR(100), ' +
    'CAPTION_GRID VARCHAR(100), ' +
    'FORCE_REQUIRED BOOLEAN NOT NULL DEFAULT 0, ' +
    'FORCE_READONLY BOOLEAN NOT NULL DEFAULT 0, ' +
    'FORCE_HIDDEN BOOLEAN NOT NULL DEFAULT 0, ' +
    'SUPPRESS_DEFAULT BOOLEAN NOT NULL DEFAULT 0, ' +
    'NOTE TEXT, ' +
    'PRIMARY KEY (DATASET, FIELD_NAME))');
end;

procedure TTestOverrides.TearDown;
begin
  // riporta l'oggetto unico a vuoto
  FConnessione.ExecSQL('DELETE FROM OVERRIDES');
  Overrides.LoadFromDB(FConnessione);

  FreeAndNil(FConnessione);
end;

procedure TTestOverrides.Inserisci(const Dataset, Campo, DidascaliaScheda, DidascaliaGriglia: string; const ForzaObbligatorio, ForzaSolaLettura, ForzaNascosto, SopprimiPredefinito: Integer; const Nota: string);
begin
  FConnessione.ExecSQL('INSERT INTO OVERRIDES (DATASET, FIELD_NAME, CAPTION_CARD, CAPTION_GRID, FORCE_REQUIRED, FORCE_READONLY, FORCE_HIDDEN, SUPPRESS_DEFAULT, NOTE) VALUES (' +
    QuotedStr(Dataset) + ', ' + QuotedStr(Campo) + ', ' + DidascaliaScheda + ', ' + DidascaliaGriglia + ', ' +
    IntToStr(ForzaObbligatorio) + ', ' + IntToStr(ForzaSolaLettura) + ', ' + IntToStr(ForzaNascosto) + ', ' + IntToStr(SopprimiPredefinito) + ', ' + Nota + ')');
end;

procedure TTestOverrides.LoadFromDB_TabellaVuota_CollezioneVuotaECaricata;
begin
  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual(0, Overrides.Overrides.Count);
  Assert.IsTrue(Overrides.Loaded);
end;

procedure TTestOverrides.LoadFromDB_DueRighe_UnElementoPerRiga;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Inserisci('Studenti.Elenco', 'NOME', 'NULL', 'NULL', 0, 0, 0, 0);

  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual(2, Overrides.Overrides.Count);
  Assert.IsTrue(Overrides.Loaded);
end;

procedure TTestOverrides.LoadFromDB_Ricaricamento_SostituisceIlContenuto;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Inserisci('Studenti.Elenco', 'NOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);
  Assert.AreEqual(2, Overrides.Overrides.Count);

  FConnessione.ExecSQL('DELETE FROM OVERRIDES WHERE FIELD_NAME = ''NOME''');
  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual(1, Overrides.Overrides.Count);
  Assert.IsNotNull(Overrides.FindOverride('Studenti.Elenco', 'COGNOME'));
  Assert.IsNull(Overrides.FindOverride('Studenti.Elenco', 'NOME'), 'l''indice riparte da zero a ogni caricamento');
end;

procedure TTestOverrides.LoadFromDB_LeggeNotaEProprieta;
var
  Elemento: TOverrideItem;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', '''Cognome scheda''', '''Cognome griglia''', 1, 0, 1, 0, '''Nota di prova''');

  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.FindOverride('Studenti.Elenco', 'COGNOME');

  Assert.IsNotNull(Elemento);
  Assert.AreEqual('Studenti.Elenco', Elemento.Dataset);
  Assert.AreEqual('COGNOME', Elemento.FieldName);
  Assert.AreEqual('Cognome scheda', Elemento.CaptionCard);
  Assert.AreEqual('Cognome griglia', Elemento.CaptionGrid);
  Assert.IsTrue(Elemento.ForceRequired);
  Assert.IsFalse(Elemento.ForceReadOnly);
  Assert.IsTrue(Elemento.ForceHidden);
  Assert.IsFalse(Elemento.SuppressDefault);
  Assert.AreEqual('Nota di prova', Elemento.Note);
end;

procedure TTestOverrides.LoadFromDB_DidascaliaNulla_FlagNonAttivo;
var
  Elemento: TOverrideItem;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', '''Cognome e nome''', 0, 0, 0, 0);

  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.FindOverride('Studenti.Elenco', 'COGNOME');

  Assert.IsTrue(ofCaptionGrid in Elemento.ActiveFlags);
  Assert.IsFalse(ofCaptionCard in Elemento.ActiveFlags);
end;

procedure TTestOverrides.LoadFromDB_DidascaliaVuotaMaNonNulla_FlagAttivo;
var
  Elemento: TOverrideItem;
begin
  // una stringa vuota non e' NULL: la riga ha una didascalia impostata
  Inserisci('Studenti.Elenco', 'COGNOME', '''''', 'NULL', 0, 0, 0, 0);

  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.FindOverride('Studenti.Elenco', 'COGNOME');

  Assert.IsTrue(ofCaptionCard in Elemento.ActiveFlags);
  Assert.AreEqual('', Overrides.CaptionCard('Studenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.LoadFromDB_Booleani_SoloIVeriSonoAttivi;
var
  Elemento: TOverrideItem;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 0, 0, 1, 0);

  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.FindOverride('Studenti.Elenco', 'COGNOME');

  Assert.IsTrue(Elemento.ActiveFlags = [ofForceHidden]);
end;

procedure TTestOverrides.LoadFromDB_TuttiIFlagBooleani_Attivi;
var
  Elemento: TOverrideItem;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 1, 1, 1, 1);

  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.FindOverride('Studenti.Elenco', 'COGNOME');

  Assert.IsTrue(Elemento.ActiveFlags = [ofForceRequired, ofForceReadOnly, ofForceHidden, ofSuppressDefault]);
end;

procedure TTestOverrides.Key_TuttoMaiuscolo;
var
  Elemento: TOverrideItem;
begin
  Inserisci('Studenti.Elenco', 'Cognome', 'NULL', 'NULL', 0, 0, 0, 0);

  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.Overrides.Items(0);

  Assert.AreEqual('STUDENTI.ELENCO.COGNOME', Elemento.Key);
end;

procedure TTestOverrides.FindOverride_SenzaDistinzioneMaiuscole;
var
  Elemento: TOverrideItem;
begin
  Inserisci('Studenti.Elenco', 'Cognome', 'NULL', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);
  Elemento := Overrides.Overrides.Items(0);

  Assert.AreSame(Elemento, Overrides.FindOverride('STUDENTI.ELENCO', 'cognome'));
  Assert.AreSame(Elemento, Overrides.FindOverride('studenti.elenco', 'COGNOME'));
end;

procedure TTestOverrides.FindOverride_Assente_Nil;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.IsNull(Overrides.FindOverride('Studenti.Elenco', 'NOME'));
  Assert.IsNull(Overrides.FindOverride('Docenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.OverrideExists_Dataset_SenzaFlag_VeroSeEsisteUnaRiga;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.IsTrue(Overrides.OverrideExists('Studenti.Elenco'));
  Assert.IsTrue(Overrides.OverrideExists('STUDENTI.ELENCO'), 'senza distinzione di maiuscole');
end;

procedure TTestOverrides.OverrideExists_DatasetSconosciuto_Falso;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.IsFalse(Overrides.OverrideExists('Docenti.Elenco'));
  Assert.IsFalse(Overrides.OverrideExists('Docenti.Elenco', [ofSuppressDefault]));
end;

procedure TTestOverrides.OverrideExists_Dataset_ConFlag_SoloSeAlmenoUnElementoLoHaAttivo;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', '''Cognome''', 'NULL', 0, 0, 0, 0);
  Inserisci('Studenti.Elenco', 'NOME', 'NULL', 'NULL', 0, 0, 0, 1);
  Overrides.LoadFromDB(FConnessione);

  Assert.IsTrue(Overrides.OverrideExists('Studenti.Elenco', [ofSuppressDefault]));
  Assert.IsTrue(Overrides.OverrideExists('Studenti.Elenco', [ofCaptionCard]));
  Assert.IsFalse(Overrides.OverrideExists('Studenti.Elenco', [ofForceHidden]));
end;

procedure TTestOverrides.OverrideExists_Campo_AlmenoUnoDeiFlagRichiesti;
begin
  Inserisci('Studenti.Elenco', 'NOME', 'NULL', 'NULL', 0, 0, 0, 1);
  Overrides.LoadFromDB(FConnessione);

  Assert.IsTrue(Overrides.OverrideExists('Studenti.Elenco', 'NOME', [ofCaptionCard, ofSuppressDefault]));
  Assert.IsFalse(Overrides.OverrideExists('Studenti.Elenco', 'NOME', [ofCaptionCard]));
end;

procedure TTestOverrides.OverrideExists_Campo_SenzaFlag_BastaChePersonalizzazioneEsista;
begin
  Inserisci('Studenti.Elenco', 'NOME', 'NULL', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.IsTrue(Overrides.OverrideExists('Studenti.Elenco', 'NOME'));
  Assert.IsFalse(Overrides.OverrideExists('Studenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.OverrideExists_CampoSconosciuto_Falso;
begin
  Overrides.LoadFromDB(FConnessione);

  Assert.IsFalse(Overrides.OverrideExists('Studenti.Elenco', 'NOME', [ofSuppressDefault]));
end;

procedure TTestOverrides.CaptionGrid_FlagAttivo_RestituisceIlTesto;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', 'NULL', '''Cognome e nome''', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual('Cognome e nome', Overrides.CaptionGrid('Studenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.CaptionCard_FlagAttivo_RestituisceIlTesto;
begin
  Inserisci('Studenti.Elenco', 'COGNOME', '''Il cognome''', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual('Il cognome', Overrides.CaptionCard('Studenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.Caption_FlagNonAttivo_StringaVuota;
begin
  // solo la didascalia della scheda: quella della griglia non e' personalizzata
  Inserisci('Studenti.Elenco', 'COGNOME', '''Il cognome''', 'NULL', 0, 0, 0, 0);
  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual('', Overrides.CaptionGrid('Studenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.Caption_CampoSconosciuto_StringaVuota;
begin
  Overrides.LoadFromDB(FConnessione);

  Assert.AreEqual('', Overrides.CaptionGrid('Studenti.Elenco', 'COGNOME'));
  Assert.AreEqual('', Overrides.CaptionCard('Studenti.Elenco', 'COGNOME'));
end;

procedure TTestOverrides.Add_NonEVisibileFinoAlSalvataggio;
var
  Elemento: TOverrideItem;
  ConteggioPrima: Integer;
begin
  Overrides.LoadFromDB(FConnessione);
  ConteggioPrima := Overrides.Overrides.Count;

  Elemento := Overrides.Add('Studenti.Elenco', 'NOME');

  Assert.AreEqual(ConteggioPrima + 1, Overrides.Overrides.Count);
  Assert.AreEqual('Studenti.Elenco', Elemento.Dataset);
  Assert.AreEqual('NOME', Elemento.FieldName);
  Assert.IsNull(Overrides.FindOverride('Studenti.Elenco', 'NOME'), 'Add non aggiorna gli indici: lo fa SaveItem');
end;

procedure TTestOverrides.Remove_ElementoAggiuntoMaiSalvato_TornaAlConteggioDiPrima;
var
  Elemento: TOverrideItem;
  ConteggioPrima: Integer;
begin
  Overrides.LoadFromDB(FConnessione);
  ConteggioPrima := Overrides.Overrides.Count;

  Elemento := Overrides.Add('Studenti.Elenco', 'NOME');
  Overrides.Remove(Elemento);

  Assert.AreEqual(ConteggioPrima, Overrides.Overrides.Count);
end;

procedure TTestOverrides.Remove_Nil_NessunErrore;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Overrides.Remove(nil);
    end);
end;

procedure TTestOverrides.Collezione_Add_ActiveFlagsVuoto;
var
  Collezione: TOverrideCollection;
begin
  Collezione := TOverrideCollection.Create;
  try
    Assert.IsTrue(Collezione.Add.ActiveFlags = []);
  finally
    Collezione.Free;
  end;
end;

procedure TTestOverrides.Collezione_FindItem_SenzaDistinzioneMaiuscole;
var
  Collezione: TOverrideCollection;
  Elemento: TOverrideItem;
begin
  Collezione := TOverrideCollection.Create;
  try
    Elemento := Collezione.Add;
    Elemento.Dataset := 'Studenti.Elenco';
    Elemento.FieldName := 'Cognome';

    Assert.AreSame(Elemento, Collezione.FindItem('STUDENTI.ELENCO', 'cognome'));
    Assert.IsNull(Collezione.FindItem('Studenti.Elenco', 'Nome'));
  finally
    Collezione.Free;
  end;
end;

procedure TTestOverrides.Assign_CopiaProprietaEActiveFlags;
var
  Collezione: TOverrideCollection;
  Origine, Copia: TOverrideItem;
begin
  Collezione := TOverrideCollection.Create;
  try
    Origine := Collezione.Add;
    Origine.Dataset := 'Studenti.Elenco';
    Origine.FieldName := 'COGNOME';
    Origine.CaptionCard := 'Il cognome';
    Origine.CaptionGrid := 'Cognome e nome';
    Origine.ForceRequired := True;
    Origine.ForceReadOnly := True;
    Origine.ForceHidden := True;
    Origine.SuppressDefault := True;
    Origine.Note := 'Nota';
    Origine.ActiveFlags := [ofCaptionCard, ofForceHidden];

    Copia := Collezione.Add;
    Copia.Assign(Origine);

    Assert.AreEqual('Studenti.Elenco', Copia.Dataset);
    Assert.AreEqual('COGNOME', Copia.FieldName);
    Assert.AreEqual('Il cognome', Copia.CaptionCard);
    Assert.AreEqual('Cognome e nome', Copia.CaptionGrid);
    Assert.IsTrue(Copia.ForceRequired);
    Assert.IsTrue(Copia.ForceReadOnly);
    Assert.IsTrue(Copia.ForceHidden);
    Assert.IsTrue(Copia.SuppressDefault);
    Assert.AreEqual('Nota', Copia.Note);
    Assert.IsTrue(Copia.ActiveFlags = [ofCaptionCard, ofForceHidden]);
  finally
    Collezione.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestOverrides);

end.
