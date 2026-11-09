// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-03
// ---------------------------------------------------------------------------
unit Test.zSystem.Componenti;

// Test DUnitX per le proprieta' dei componenti nuovi nel dizionario LZ
// (zSystem.pas), nelle parti che non richiedono il database:
// - TzSchedulerMapping: quale campo del dataset va allo storage del
//   calendario; senza un campo obbligatorio DevExpress non carica nessun
//   evento e non lo dice, quindi MissingRequired e' l'unico avviso;
// - TzDbSchedulerFlags: notifiche di modifica e aggiornamento a blocchi;
// - TzChartSeriesItems: quali campi possono fare da serie del grafico;
// - TzRecordViewRows / TzRecordViewRow: righe e categorie della vista record.
//
// I dataset sono TFDMemTable mai aperti con campi persistenti: FindField
// funziona anche a dataset chiuso, ed e' tutto quello che serve a Resolve.

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  Data.FmtBcd,
  FireDAC.Comp.Client,
  DUnitX.TestFramework,
  zSystem;

type
  [TestFixture]
  TTestSchedulerMapping = class
  private
    FDataSet: TFDMemTable;
    FMapping: TzSchedulerMapping;
    procedure Campi(const Nomi: array of string);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Resolve_DataSetNil_Vuoto;
    [Test]
    procedure Resolve_Convenzione_PrimoNome;
    [Test]
    procedure Resolve_Convenzione_NomeAlternativo;
    [Test]
    procedure Resolve_Convenzione_VinceIlPrimoDellElenco;
    [Test]
    procedure Resolve_ChiaveDellAgenda_IdAgenda;
    [Test]
    procedure Resolve_Configurato_Presente;
    [Test]
    procedure Resolve_ConfiguratoAssente_NienteRipiegoSullaConvenzione;
    [Test]
    procedure Resolve_StatoERisorsa_SenzaConvenzione;
    [Test]
    procedure SetConfigured_TogliGliSpazi;
    [Test]
    procedure ProprietaPubblicata_TogliGliSpazi;
    [Test]
    procedure MissingRequired_TuttiPresenti_Vuoto;
    [Test]
    procedure MissingRequired_ElencaIMancantiInOrdine;
    [Test]
    procedure MissingRequired_DataSetVuoto_TuttiEcinque;
    [Test]
    procedure IsRequired_SoloICinqueDiDevExpress;
    [Test]
    procedure FieldCaption_NomeDellaProprieta;
    [Test]
    procedure Assign_CopiaTuttiINomi;
  end;

  [TestFixture]
  TTestDbSchedulerFlags = class
  private
    FNotifiche: Integer;
    procedure Cambiato(Sender: TObject);
  public
    [Test]
    procedure Create_ValoriPredefiniti;
    [Test]
    procedure Setter_UnaNotifica;
    [Test]
    procedure BeginEndUpdate_UnaSolaNotificaAllaFine;
    [Test]
    procedure BeginUpdateAnnidati_NotificaSoloAllUltimoEnd;
    [Test]
    procedure Assign_CopiaEUnaSolaNotifica;
  end;

  [TestFixture]
  TTestChartSeriesItems = class
  private
    function Campo(FieldClass: TFieldClass; const Kind: TFieldKind = fkData): Boolean;
  public
    [Test]
    procedure IsValueField_Nil_False;
    [Test]
    procedure IsValueField_CampiNumerici_True;
    [Test]
    procedure IsValueField_TestoDataBooleano_False;
    [Test]
    procedure IsValueField_Calcolato_True;
    [Test]
    procedure IsValueField_Lookup_False;
    [Test]
    procedure IsServiceField_ColonneDiControllo_True;
    [Test]
    procedure IsServiceField_SenzaDistinzioneMaiuscole;
    [Test]
    procedure IsServiceField_CampiDiDominio_False;
  end;

  [TestFixture]
  TTestRecordViewRows = class
  private
    FRows: TzRecordViewRows;
    function AggiungiCampo(const Nome: string): TzRecordViewRow;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Row_ValoriPredefiniti;
    [Test]
    procedure Row_Caption_RipiegaSulNome;
    [Test]
    procedure Row_Caption_Esplicita;
    [Test]
    procedure Row_Assign_CopiaAncheIMembri;
    [Test]
    procedure FieldRow_SenzaDistinzioneMaiuscole;
    [Test]
    procedure FieldRow_Categoria_NonECampo;
    [Test]
    procedure FieldRow_Assente_Nil;
    [Test]
    procedure AddCategory_Nuova;
    [Test]
    procedure AddCategory_Esistente_AggiornaSenzaDuplicare;
    [Test]
    procedure MoveToCategory_ImpostaIlGenitore;
    [Test]
    procedure MoveToCategory_PrimoLivello;
    [Test]
    procedure MoveToCategory_RigaAssente_NessunErrore;
    [Test]
    procedure Ordine_DiInserimento;
    [Test]
    procedure Json_RoundTrip;
  end;

implementation

{ TTestSchedulerMapping }

procedure TTestSchedulerMapping.Setup;
begin
  FDataSet := TFDMemTable.Create(nil);
  FMapping := TzSchedulerMapping.Create;
end;

procedure TTestSchedulerMapping.TearDown;
begin
  FreeAndNil(FMapping);
  FreeAndNil(FDataSet);
end;

procedure TTestSchedulerMapping.Campi(const Nomi: array of string);
var
  Nome: string;
  Field: TField;
begin
  for Nome in Nomi do
  begin
    Field := TStringField.Create(FDataSet);
    Field.FieldName := Nome;
    Field.DataSet := FDataSet;
  end;
end;

procedure TTestSchedulerMapping.Resolve_DataSetNil_Vuoto;
begin
  Assert.AreEqual('', FMapping.Resolve(sfStart, nil));
end;

procedure TTestSchedulerMapping.Resolve_Convenzione_PrimoNome;
begin
  Campi(['ID', 'INIZIO', 'FINE']);

  Assert.AreEqual('ID', FMapping.Resolve(sfID, FDataSet));
  Assert.AreEqual('INIZIO', FMapping.Resolve(sfStart, FDataSet));
  Assert.AreEqual('FINE', FMapping.Resolve(sfFinish, FDataSet));
end;

procedure TTestSchedulerMapping.Resolve_Convenzione_NomeAlternativo;
begin
  Campi(['DATA_INIZIO', 'DATA_FINE', 'TITOLO_EVENTO', 'CORPO_EVENTO']);

  Assert.AreEqual('DATA_INIZIO', FMapping.Resolve(sfStart, FDataSet));
  Assert.AreEqual('DATA_FINE', FMapping.Resolve(sfFinish, FDataSet));
  Assert.AreEqual('TITOLO_EVENTO', FMapping.Resolve(sfCaption, FDataSet));
  Assert.AreEqual('CORPO_EVENTO', FMapping.Resolve(sfMessage, FDataSet));
end;

procedure TTestSchedulerMapping.Resolve_Convenzione_VinceIlPrimoDellElenco;
begin
  // OGGETTO;TITOLO_EVENTO;TITOLO;DESCRIZIONE: l'ordine dei campi nel dataset non conta
  Campi(['DESCRIZIONE', 'TITOLO', 'OGGETTO']);

  Assert.AreEqual('OGGETTO', FMapping.Resolve(sfCaption, FDataSet));
end;

procedure TTestSchedulerMapping.Resolve_ChiaveDellAgenda_IdAgenda;
begin
  // USR_UTENTI_AGENDA non ha ID ma ID_AGENDA
  Campi(['ID_AGENDA', 'INIZIO']);

  Assert.AreEqual('ID_AGENDA', FMapping.Resolve(sfID, FDataSet));
end;

procedure TTestSchedulerMapping.Resolve_Configurato_Presente;
begin
  Campi(['INIZIO', 'INIZIO_LEZIONE']);
  FMapping.SetConfigured(sfStart, 'INIZIO_LEZIONE');

  Assert.AreEqual('INIZIO_LEZIONE', FMapping.Resolve(sfStart, FDataSet));
end;

procedure TTestSchedulerMapping.Resolve_ConfiguratoAssente_NienteRipiegoSullaConvenzione;
begin
  // un nome configurato e sbagliato deve vedersi, non essere coperto da INIZIO
  Campi(['INIZIO']);
  FMapping.SetConfigured(sfStart, 'INIZIO_SBAGLIATO');

  Assert.AreEqual('', FMapping.Resolve(sfStart, FDataSet));
end;

procedure TTestSchedulerMapping.Resolve_StatoERisorsa_SenzaConvenzione;
begin
  // STATO e i campi delle risorse cambiano significato da una tabella all'altra
  Campi(['STATO', 'RISORSA', 'ID_RISORSA']);

  Assert.AreEqual('', FMapping.Resolve(sfState, FDataSet));
  Assert.AreEqual('', FMapping.Resolve(sfResourceID, FDataSet));
end;

procedure TTestSchedulerMapping.SetConfigured_TogliGliSpazi;
begin
  FMapping.SetConfigured(sfFinish, '  FINE_LEZIONE  ');

  Assert.AreEqual('FINE_LEZIONE', FMapping.Configured(sfFinish));
end;

procedure TTestSchedulerMapping.ProprietaPubblicata_TogliGliSpazi;
begin
  // e' la via del dizionario LZ (editor delle proprieta' e lettura del .LZ)
  FMapping.Start := ' INIZIO_LEZIONE ';

  Assert.AreEqual('INIZIO_LEZIONE', FMapping.Configured(sfStart));
  Assert.AreEqual('INIZIO_LEZIONE', FMapping.Start);
end;

procedure TTestSchedulerMapping.MissingRequired_TuttiPresenti_Vuoto;
begin
  Campi(['ID', 'INIZIO', 'FINE', 'TIPO_EVENTO', 'OPZIONI']);

  Assert.AreEqual('', FMapping.MissingRequired(FDataSet));
end;

procedure TTestSchedulerMapping.MissingRequired_ElencaIMancantiInOrdine;
begin
  Campi(['ID', 'INIZIO', 'FINE']);

  Assert.AreEqual('EventType, Options', FMapping.MissingRequired(FDataSet));
end;

procedure TTestSchedulerMapping.MissingRequired_DataSetVuoto_TuttiEcinque;
begin
  Assert.AreEqual('ID, Start, Finish, EventType, Options', FMapping.MissingRequired(FDataSet));
end;

procedure TTestSchedulerMapping.IsRequired_SoloICinqueDiDevExpress;
var
  Campo: TzSchedulerField;
begin
  for Campo := Low(TzSchedulerField) to High(TzSchedulerField) do
    Assert.IsTrue((Campo in [sfID, sfStart, sfFinish, sfEventType, sfOptions]) = TzSchedulerMapping.IsRequired(Campo),
      TzSchedulerMapping.FieldCaption(Campo));
end;

procedure TTestSchedulerMapping.FieldCaption_NomeDellaProprieta;
begin
  Assert.AreEqual('ID', TzSchedulerMapping.FieldCaption(sfID));
  Assert.AreEqual('Start', TzSchedulerMapping.FieldCaption(sfStart));
  Assert.AreEqual('TaskStatus', TzSchedulerMapping.FieldCaption(sfTaskStatus));
end;

procedure TTestSchedulerMapping.Assign_CopiaTuttiINomi;
var
  Copia: TzSchedulerMapping;
  Campo: TzSchedulerField;
begin
  for Campo := Low(TzSchedulerField) to High(TzSchedulerField) do
    FMapping.SetConfigured(Campo, 'CAMPO_' + IntToStr(Ord(Campo)));

  Copia := TzSchedulerMapping.Create;
  try
    Copia.Assign(FMapping);

    for Campo := Low(TzSchedulerField) to High(TzSchedulerField) do
      Assert.AreEqual(FMapping.Configured(Campo), Copia.Configured(Campo));
  finally
    Copia.Free;
  end;
end;

{ TTestDbSchedulerFlags }

procedure TTestDbSchedulerFlags.Cambiato(Sender: TObject);
begin
  Inc(FNotifiche);
end;

procedure TTestDbSchedulerFlags.Create_ValoriPredefiniti;
var
  Flags: TzDbSchedulerFlags;
begin
  Flags := TzDbSchedulerFlags.Create;
  try
    Assert.IsTrue(Flags.AutoCustomFields);
    Assert.IsTrue(Flags.ButtonRefresh);
    Assert.IsFalse(Flags.DateNavigator);
    Assert.IsFalse(Flags.Params);
    Assert.IsFalse(Flags.ReadOnly);
    Assert.IsTrue(Flags.Recurrence);
    Assert.IsTrue(Flags.Toolbar);
    Assert.IsFalse(Flags.WorkTimeOnly);
  finally
    Flags.Free;
  end;
end;

procedure TTestDbSchedulerFlags.Setter_UnaNotifica;
var
  Flags: TzDbSchedulerFlags;
begin
  Flags := TzDbSchedulerFlags.Create;
  try
    FNotifiche := 0;
    Flags.OnChange := Cambiato;
    Flags.ReadOnly := True;

    Assert.AreEqual(1, FNotifiche);
  finally
    Flags.Free;
  end;
end;

procedure TTestDbSchedulerFlags.BeginEndUpdate_UnaSolaNotificaAllaFine;
var
  Flags: TzDbSchedulerFlags;
begin
  Flags := TzDbSchedulerFlags.Create;
  try
    FNotifiche := 0;
    Flags.OnChange := Cambiato;

    Flags.BeginUpdate;
    Flags.ReadOnly := True;
    Flags.Toolbar := False;
    Flags.WorkTimeOnly := True;
    Assert.AreEqual(0, FNotifiche, 'nessuna notifica durante l''aggiornamento');
    Flags.EndUpdate;

    Assert.AreEqual(1, FNotifiche);
  finally
    Flags.Free;
  end;
end;

procedure TTestDbSchedulerFlags.BeginUpdateAnnidati_NotificaSoloAllUltimoEnd;
var
  Flags: TzDbSchedulerFlags;
begin
  Flags := TzDbSchedulerFlags.Create;
  try
    FNotifiche := 0;
    Flags.OnChange := Cambiato;

    Flags.BeginUpdate;
    Flags.BeginUpdate;
    Flags.ReadOnly := True;
    Flags.EndUpdate;
    Assert.AreEqual(0, FNotifiche);
    Flags.EndUpdate;

    Assert.AreEqual(1, FNotifiche);
  finally
    Flags.Free;
  end;
end;

procedure TTestDbSchedulerFlags.Assign_CopiaEUnaSolaNotifica;
var
  Origine, Destinazione: TzDbSchedulerFlags;
begin
  Origine := TzDbSchedulerFlags.Create;
  Destinazione := TzDbSchedulerFlags.Create;
  try
    Origine.ReadOnly := True;
    Origine.DateNavigator := True;
    Origine.Recurrence := False;

    FNotifiche := 0;
    Destinazione.OnChange := Cambiato;
    Destinazione.Assign(Origine);

    Assert.IsTrue(Destinazione.ReadOnly);
    Assert.IsTrue(Destinazione.DateNavigator);
    Assert.IsFalse(Destinazione.Recurrence);
    Assert.AreEqual(1, FNotifiche);
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

{ TTestChartSeriesItems }

function TTestChartSeriesItems.Campo(FieldClass: TFieldClass; const Kind: TFieldKind): Boolean;
var
  Field: TField;
begin
  Field := FieldClass.Create(nil);
  try
    Field.FieldKind := Kind;
    result := TzChartSeriesItems.IsValueField(Field);
  finally
    Field.Free;
  end;
end;

procedure TTestChartSeriesItems.IsValueField_Nil_False;
begin
  Assert.IsFalse(TzChartSeriesItems.IsValueField(nil));
end;

procedure TTestChartSeriesItems.IsValueField_CampiNumerici_True;
begin
  Assert.IsTrue(Campo(TIntegerField), 'Integer');
  Assert.IsTrue(Campo(TSmallintField), 'Smallint');
  Assert.IsTrue(Campo(TLargeintField), 'Largeint');
  Assert.IsTrue(Campo(TFloatField), 'Float');
  Assert.IsTrue(Campo(TCurrencyField), 'Currency');
  Assert.IsTrue(Campo(TBCDField), 'BCD');
  Assert.IsTrue(Campo(TFMTBCDField), 'FMTBcd');
end;

procedure TTestChartSeriesItems.IsValueField_TestoDataBooleano_False;
begin
  Assert.IsFalse(Campo(TStringField), 'String');
  Assert.IsFalse(Campo(TDateField), 'Date');
  Assert.IsFalse(Campo(TDateTimeField), 'DateTime');
  Assert.IsFalse(Campo(TBooleanField), 'Boolean');
  Assert.IsFalse(Campo(TMemoField), 'Memo');
end;

procedure TTestChartSeriesItems.IsValueField_Calcolato_True;
begin
  Assert.IsTrue(Campo(TFloatField, fkCalculated));
  Assert.IsTrue(Campo(TIntegerField, fkInternalCalc));
end;

procedure TTestChartSeriesItems.IsValueField_Lookup_False;
begin
  // il valore di un lookup e' di un altro dataset: non e' una serie
  Assert.IsFalse(Campo(TIntegerField, fkLookup));
end;

procedure TTestChartSeriesItems.IsServiceField_ColonneDiControllo_True;
begin
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('USR_USER_INS'));
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('USR_DATA_INS'));
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('USR_USER_MDF'));
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('USR_DATA_MDF'));
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('USR_DATA_DBA'));
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('DATA_INS'));
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('SYSDBA_DATA_MDF'));
end;

procedure TTestChartSeriesItems.IsServiceField_SenzaDistinzioneMaiuscole;
begin
  Assert.IsTrue(TzChartSeriesItems.IsServiceField('usr_data_ins'));
end;

procedure TTestChartSeriesItems.IsServiceField_CampiDiDominio_False;
begin
  Assert.IsFalse(TzChartSeriesItems.IsServiceField('IMPORTO'));
  Assert.IsFalse(TzChartSeriesItems.IsServiceField('DATA_INIZIO'));
  Assert.IsFalse(TzChartSeriesItems.IsServiceField('USR_ALTRO'));
  Assert.IsFalse(TzChartSeriesItems.IsServiceField(''));
end;

{ TTestRecordViewRows }

procedure TTestRecordViewRows.Setup;
begin
  FRows := TzRecordViewRows.Create(nil);
end;

procedure TTestRecordViewRows.TearDown;
begin
  FreeAndNil(FRows);
end;

function TTestRecordViewRows.AggiungiCampo(const Nome: string): TzRecordViewRow;
begin
  result := FRows.Add;
  result.Name := Nome;
  result.RowKind := rkField;
end;

procedure TTestRecordViewRows.Row_ValoriPredefiniti;
var
  Riga: TzRecordViewRow;
begin
  Riga := FRows.Add;

  Assert.IsTrue(Riga.RowKind = rkField);
  Assert.IsTrue(Riga.IsField);
  Assert.IsTrue(Riga.Visible);
  Assert.IsFalse(Riga.ReadOnly);
  Assert.IsTrue(Riga.Expanded);
  Assert.AreEqual(-1, Riga.Height, 'altezza automatica');
  Assert.AreEqual('', Riga.ParentName);
  Assert.AreEqual(0, Riga.Members.Count);
  Assert.IsNull(Riga.Domain);
end;

procedure TTestRecordViewRows.Row_Caption_RipiegaSulNome;
var
  Riga: TzRecordViewRow;
begin
  // senza didascalia e senza dominio risolto vale il nome del campo
  Riga := AggiungiCampo('DATA_NASCITA');

  Assert.AreEqual('DATA_NASCITA', Riga.Caption);
end;

procedure TTestRecordViewRows.Row_Caption_Esplicita;
var
  Riga: TzRecordViewRow;
begin
  Riga := AggiungiCampo('DATA_NASCITA');
  Riga.Caption := 'Nato il';

  Assert.AreEqual('Nato il', Riga.Caption);
end;

procedure TTestRecordViewRows.Row_Assign_CopiaAncheIMembri;
var
  Origine, Copia: TzRecordViewRow;
begin
  Origine := FRows.Add;
  Origine.Name := 'Indirizzo';
  Origine.RowKind := rkMultiField;
  Origine.Caption := 'Indirizzo completo';
  Origine.ParentName := 'Recapiti';
  Origine.Visible := False;
  Origine.ReadOnly := True;
  Origine.Height := 40;
  Origine.Members.Add('VIA');
  Origine.Members.Add('CAP');

  Copia := FRows.Add;
  Copia.Assign(Origine);

  Assert.AreEqual('Indirizzo', Copia.Name);
  Assert.IsTrue(Copia.RowKind = rkMultiField);
  Assert.AreEqual('Indirizzo completo', Copia.Caption);
  Assert.AreEqual('Recapiti', Copia.ParentName);
  Assert.IsFalse(Copia.Visible);
  Assert.IsTrue(Copia.ReadOnly);
  Assert.AreEqual(40, Copia.Height);
  Assert.AreEqual(2, Copia.Members.Count);
  Assert.AreEqual('CAP', Copia.Members[1]);

  // i membri sono una copia, non lo stesso elenco
  Origine.Members.Clear;
  Assert.AreEqual(2, Copia.Members.Count);
end;

procedure TTestRecordViewRows.FieldRow_SenzaDistinzioneMaiuscole;
var
  Riga: TzRecordViewRow;
begin
  Riga := AggiungiCampo('COGNOME');

  Assert.AreSame(Riga, FRows.FieldRow('cognome'));
end;

procedure TTestRecordViewRows.FieldRow_Categoria_NonECampo;
begin
  FRows.AddCategory('Anagrafica', 'Dati anagrafici');

  Assert.IsNull(FRows.FieldRow('Anagrafica'));
end;

procedure TTestRecordViewRows.FieldRow_Assente_Nil;
begin
  AggiungiCampo('COGNOME');

  Assert.IsNull(FRows.FieldRow('NOME'));
end;

procedure TTestRecordViewRows.AddCategory_Nuova;
var
  Categoria: TzRecordViewRow;
begin
  Categoria := FRows.AddCategory('Recapiti', 'Recapiti e contatti');

  Assert.IsNotNull(Categoria);
  Assert.AreEqual('Recapiti', Categoria.Name);
  Assert.IsTrue(Categoria.RowKind = rkCategory);
  Assert.IsFalse(Categoria.IsField);
  Assert.AreEqual('Recapiti e contatti', Categoria.Caption);
end;

procedure TTestRecordViewRows.AddCategory_Esistente_AggiornaSenzaDuplicare;
var
  Prima, Seconda: TzRecordViewRow;
begin
  Prima := FRows.AddCategory('Recapiti', 'Vecchia');
  Seconda := FRows.AddCategory('Recapiti', 'Nuova');

  Assert.AreSame(Prima, Seconda);
  Assert.AreEqual(1, FRows.Count);
  Assert.AreEqual('Nuova', Seconda.Caption);
end;

procedure TTestRecordViewRows.MoveToCategory_ImpostaIlGenitore;
begin
  AggiungiCampo('TELEFONO');
  FRows.AddCategory('Recapiti', 'Recapiti');

  FRows.MoveToCategory('TELEFONO', 'Recapiti');

  Assert.AreEqual('Recapiti', FRows.FieldRow('TELEFONO').ParentName);
end;

procedure TTestRecordViewRows.MoveToCategory_PrimoLivello;
begin
  AggiungiCampo('TELEFONO').ParentName := 'Recapiti';

  FRows.MoveToCategory('TELEFONO', '');

  Assert.AreEqual('', FRows.FieldRow('TELEFONO').ParentName);
end;

procedure TTestRecordViewRows.MoveToCategory_RigaAssente_NessunErrore;
begin
  FRows.MoveToCategory('INESISTENTE', 'Recapiti');

  Assert.AreEqual(0, FRows.Count, 'nessuna riga creata per errore');
end;

procedure TTestRecordViewRows.Ordine_DiInserimento;
begin
  // Sorted = False: l'ordine della collezione e' l'ordine a video
  AggiungiCampo('ZETA');
  AggiungiCampo('ALFA');
  AggiungiCampo('EMME');

  Assert.AreEqual('ZETA', FRows[0].Name);
  Assert.AreEqual('ALFA', FRows[1].Name);
  Assert.AreEqual('EMME', FRows[2].Name);
end;

procedure TTestRecordViewRows.Json_RoundTrip;
var
  Copia: TzRecordViewRows;
  Riga: TzRecordViewRow;
begin
  // formato del dizionario LZ: quello che si scrive deve rileggersi uguale
  FRows.AddCategory('Recapiti', 'Recapiti e contatti').Expanded := False;
  Riga := AggiungiCampo('TELEFONO');
  Riga.ParentName := 'Recapiti';
  Riga.ReadOnly := True;
  Riga.Height := 30;
  Riga := FRows.Add;
  Riga.Name := 'Indirizzo';
  Riga.RowKind := rkMultiField;
  Riga.Members.Add('VIA');
  Riga.Members.Add('CAP');

  Copia := TzRecordViewRows.Create(nil);
  try
    Copia.AsJSON := FRows.AsJSON;

    Assert.AreEqual(3, Copia.Count);

    Assert.AreEqual('Recapiti', Copia[0].Name);
    Assert.IsTrue(Copia[0].RowKind = rkCategory);
    Assert.AreEqual('Recapiti e contatti', Copia[0].Caption);
    Assert.IsFalse(Copia[0].Expanded);

    Assert.AreEqual('TELEFONO', Copia[1].Name);
    Assert.AreEqual('Recapiti', Copia[1].ParentName);
    Assert.IsTrue(Copia[1].ReadOnly);
    Assert.AreEqual(30, Copia[1].Height);

    Assert.IsTrue(Copia[2].RowKind = rkMultiField);
    Assert.AreEqual(2, Copia[2].Members.Count);
    Assert.AreEqual('VIA', Copia[2].Members[0]);
  finally
    Copia.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSchedulerMapping);
  TDUnitX.RegisterTestFixture(TTestDbSchedulerFlags);
  TDUnitX.RegisterTestFixture(TTestChartSeriesItems);
  TDUnitX.RegisterTestFixture(TTestRecordViewRows);

end.
