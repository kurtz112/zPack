// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zStoredProc;

// Test DUnitX di zBase\zStoredProc.pas: il contratto fra TzStoredProc e le
// classi TSP_* generate (specifica ZBASE-SPR, "Procedure memorizzate.md").
//
// Le classi TSP_* di prova sono scritte a mano sul modello del generatore
// (zStoredProcCodeFactory): attributo TStoredProcedure, direttiva RTTI
// esplicita, un campo per parametro, proprieta' con TParamAttribute e, per le
// uscite scalari, la gemella privata <Nome>_internal.
//
// Niente Firebird e niente connessione: si provano solo le operazioni sui
// parametri (scrittura, azzeramento, nullita', lettura) e lo stato di
// un'istanza mai eseguita. L'esecuzione vera, il cursore e le transazioni
// (ZFIB-SPR) restano senza prova.
//
// La divergenza provata DIV-SPR-11 fotografa il comportamento di oggi: il test
// va capovolto quando il codice e' corretto. DIV-SPR-7 e' corretta.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Variants,
  System.Rtti,
  Data.DB,
  FireDAC.Comp.Client,
  Vcl.Graphics,
  Vcl.Imaging.pngimage,
  DUnitX.TestFramework,
  zz.Nullable,
  zStoredProc;

type
  // Procedura selezionabile con parametri di ogni tipo e un'uscita scalare.
  [TStoredProcedure('PROVA_SELEZIONE', True)]
  {$RTTI EXPLICIT PROPERTIES([vcPrivate, vcPublic, vcPublished])}
  TSP_Prova = class(TzStoredProc)
  private
    fId_Cliente: TNullableInt64;
    fDescrizione: TNullableString;
    fImporto: TNullableDouble;
    fData_Registrazione: TNullableDateTime;
    fAttivo: TNullableBoolean;
    fNote: TStringList;
    fFirma: TPicture;
    fId_Esito: TNullableInteger;
  private
    property Id_Esito_internal: TNullableInteger read fId_Esito write fId_Esito;
    procedure SetFirma(const Value: TPicture);
  public
    constructor Create; override;
    destructor Destroy; override;
  public
    [TParamAttribute('ID_CLIENTE', ptInput, False)]
    property Id_Cliente: TNullableInt64 read fId_Cliente write fId_Cliente;
    [TParamAttribute('DESCRIZIONE', ptInput, False)]
    property Descrizione: TNullableString read fDescrizione write fDescrizione;
    [TParamAttribute('IMPORTO', ptInput, False)]
    property Importo: TNullableDouble read fImporto write fImporto;
    [TParamAttribute('DATA_REGISTRAZIONE', ptInput, False)]
    property Data_Registrazione: TNullableDateTime read fData_Registrazione write fData_Registrazione;
    [TParamAttribute('ATTIVO', ptInput, False)]
    property Attivo: TNullableBoolean read fAttivo write fAttivo;
    [TParamAttribute('NOTE', ptInput, False)]
    property Note: TStringList read fNote write fNote;
    [TParamAttribute('FIRMA', ptInput, True)]
    property Firma: TPicture read fFirma write SetFirma;
    [TParamAttribute('ID_ESITO', ptOutput, False)]
    property Id_Esito: TNullableInteger read fId_Esito;
  end;

  // Procedura non selezionabile: l'attributo non ha il secondo argomento.
  [TStoredProcedure('PROVA_ESEGUI')]
  {$RTTI EXPLICIT PROPERTIES([vcPrivate, vcPublic, vcPublished])}
  TSP_ProvaEsegui = class(TzStoredProc)
  private
    fId_Cliente: TNullableInt64;
  public
    [TParamAttribute('ID_CLIENTE', ptInput, False)]
    property Id_Cliente: TNullableInt64 read fId_Cliente write fId_Cliente;
  end;

  // Classe derivata senza l'attributo TStoredProcedure.
  TSP_SenzaAttributo = class(TzStoredProc)
  end;

  // Classe con una proprieta' di tipo non ammesso (un Integer semplice).
  [TStoredProcedure('PROVA_TIPO_SEMPLICE')]
  {$RTTI EXPLICIT PROPERTIES([vcPrivate, vcPublic, vcPublished])}
  TSP_TipoSemplice = class(TzStoredProc)
  private
    fContatore: Integer;
  public
    [TParamAttribute('CONTATORE', ptInput, False)]
    property Contatore: Integer read fContatore write fContatore;
  end;

  [TestFixture]
  TTestZStoredProc = class
  private
    FProcedura: TSP_Prova;
    FTabella: TFDMemTable;
    function ContieneNome(const Elenco: TStringDynArray; const Nome: string): Boolean;
    function FlussoInVariant(Flusso: TMemoryStream): Variant;
    function ByteDiUnaBitmap: Variant;
    function ValoreInternoDelCampo(Istanza: TObject; const NomeCampo: string): TValue;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-SPR-001
    [Test]
    procedure Creazione_ClasseConAttributo_NomeESelezionabile;
    // ZBASE-SPR-001
    [Test]
    procedure Creazione_AttributoSenzaSecondoArgomento_NonSelezionabile;
    // ZBASE-SPR-001
    [Test]
    procedure Creazione_ClasseSenzaAttributo_NomeVuotoENonSelezionabile;

    // ZBASE-SPR-002
    [Test]
    procedure TipoNonAmmesso_Azzeramento_SollevaEccezioneConIlNome;
    // ZBASE-SPR-002
    [Test]
    procedure TipoNonAmmesso_ScritturaENullita_SollevaEccezione;

    // ZBASE-SPR-003
    [Test]
    procedure Nomi_ClasseDiProva_IngressoEUscitaDagliAttributi;
    // ZBASE-SPR-003
    [Test]
    procedure Nomi_ProprietaDelleDueDirezioni_NomiDelleProprieta;
    // ZBASE-SPR-003
    [Test]
    procedure ParamExists_NomeInMinuscolo_Vero;
    // ZBASE-SPR-003
    [Test]
    procedure ParamExists_UscitaESconosciuto_VeroEFalso;
    // ZBASE-SPR-003
    [Test]
    procedure Scrittura_ParametroSconosciuto_EccezioneConIlNome;
    // ZBASE-SPR-003
    [Test]
    procedure Scrittura_NomeInMinuscolo_TrovaLaProprieta;

    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_Intero_ValoreLetto;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_InteroA64Bit_ValoreLetto;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_Testo_ValoreLetto;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_Decimale_ValoreLetto;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_DataOra_ValoreLetto;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_Booleano_ValoreLetto;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_Memo_TestoAssegnato;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_Uscita_PassaDallaProprietaInterna;
    // ZBASE-SPR-004
    [Test]
    procedure Scrittura_ENulloVero_AzzeraIlParametro;
    // ZBASE-SPR-004
    [Test]
    procedure CopiaDaCampo_ValoreENullo_ProprietaCoerente;
    // ZBASE-SPR-004
    [Test]
    procedure CopiaDaCampo_CampoConIlNomeDelParametro_UsaIlNomeDelCampo;
    // ZBASE-SPR-004
    [Test]
    procedure CopiaDaCampo_CampoNil_NonCambiaNiente;

    // ZBASE-SPR-005
    [Test]
    procedure Azzeramento_Scalare_NulloEValorePredefinito;
    // ZBASE-SPR-005
    [Test]
    procedure Azzeramento_Testo_NulloEVuoto;
    // ZBASE-SPR-005
    [Test]
    procedure Azzeramento_Memo_SvuotatoENullo;
    // ZBASE-SPR-005
    [Test]
    procedure Azzeramento_Immagine_Nulla;
    // ZBASE-SPR-005
    [Test]
    procedure ClearParams_IngressoEUscita_TuttiNulli;
    // ZBASE-SPR-005 e DIV-SPR-11
    [Test]
    procedure Divergenza_DIV_SPR_11_AzzeramentoIntero_ValoreInternoMenoUno;
    // ZBASE-SPR-005 e DIV-SPR-11
    [Test]
    procedure Divergenza_DIV_SPR_11_AzzeramentoTesto_ValoreInternoResta;

    // ZBASE-SPR-006
    [Test]
    procedure Nullita_ParametroMaiScritto_Nulla;
    // ZBASE-SPR-006
    [Test]
    procedure Nullita_ZeroEStringaVuotaScritti_NonNulli;
    // ZBASE-SPR-006
    [Test]
    procedure Nullita_MemoVuoto_Nullo;
    // ZBASE-SPR-006
    [Test]
    procedure Nullita_MemoConTesto_NonNullo;
    // ZBASE-SPR-006
    [Test]
    procedure Nullita_ImmagineMaiCaricata_Nulla;

    // ZBASE-SPR-007
    [Test]
    procedure Lettura_ParametroNullo_Null;
    // ZBASE-SPR-007
    [Test]
    procedure Lettura_ValoreScritto_ValoreComeVariant;
    // ZBASE-SPR-007
    [Test]
    procedure Lettura_MemoDueRighe_SenzaInterruzioneFinale;
    // ZBASE-SPR-007
    [Test]
    procedure Lettura_Booleano_ValoreComeVariant;

    // ZBASE-SPR-008
    [Test]
    procedure Immagine_BitmapInUscita_AndataERitorno;
    // ZBASE-SPR-008 e DIV-SPR-7
    [Test]
    procedure Immagine_PngInUscita_VieneLettaComeBitmap;

    // ZBASE-SPR-009
    [Test]
    procedure Stato_IstanzaNuova_SenzaConnessioneNeCursore;

    // ZBASE-SPR-010
    [Test]
    procedure Gancio_Assegnato_ChiamatoConLIstanzaAppenaCreata;
    // ZBASE-SPR-010
    [Test]
    procedure Gancio_NonAssegnato_ConnessioneETransazioneNulle;
  end;

implementation

var
  ChiamateDelGancio: Integer;
  IstanzaDelGancio: TzStoredProc;

procedure GancioDiProva(Procedura: TzStoredProc);
begin
  Inc(ChiamateDelGancio);
  IstanzaDelGancio := Procedura;
end;

// TSP_Prova

constructor TSP_Prova.Create;
begin
  inherited;
  fNote := CreateStringList;
  fFirma := TPicture.Create;
end;

destructor TSP_Prova.Destroy;
begin
  FreeAndNil(fNote);
  FreeAndNil(fFirma);
  inherited;
end;

procedure TSP_Prova.SetFirma(const Value: TPicture);
begin
  fFirma.Assign(Value);
end;

// TTestZStoredProc

procedure TTestZStoredProc.Setup;
begin
  FProcedura := TSP_Prova.Create;

  // dataset con due record: il primo completo, il secondo con tutto nullo
  FTabella := TFDMemTable.Create(nil);
  FTabella.FieldDefs.Add('ID_CLIENTE', ftInteger);
  FTabella.FieldDefs.Add('DESCRIZIONE', ftString, 30);
  FTabella.CreateDataSet;

  FTabella.Append;
  FTabella.FieldByName('ID_CLIENTE').AsInteger := 7;
  FTabella.FieldByName('DESCRIZIONE').AsString := 'Rossi';
  FTabella.Post;

  FTabella.Append;
  FTabella.Post;

  FTabella.First;
end;

procedure TTestZStoredProc.TearDown;
begin
  FreeAndNil(FTabella);
  FreeAndNil(FProcedura);
  zStoredProc.InitStoredProc := nil;
end;

function TTestZStoredProc.ContieneNome(const Elenco: TStringDynArray; const Nome: string): Boolean;
var
  Voce: string;
begin
  Result := False;

  for Voce in Elenco do
    if Voce = Nome then
      Exit(True);
end;

function TTestZStoredProc.FlussoInVariant(Flusso: TMemoryStream): Variant;
var
  Puntatore: Pointer;
begin
  Result := VarArrayCreate([0, Flusso.Size - 1], varByte);
  Puntatore := VarArrayLock(Result);
  try
    Move(Flusso.Memory^, Puntatore^, Flusso.Size);
  finally
    VarArrayUnlock(Result);
  end;
end;

function TTestZStoredProc.ByteDiUnaBitmap: Variant;
var
  Immagine: TBitmap;
  Flusso: TMemoryStream;
begin
  Immagine := TBitmap.Create;
  Flusso := TMemoryStream.Create;
  try
    Immagine.PixelFormat := pf24bit;
    Immagine.SetSize(4, 3);
    Immagine.SaveToStream(Flusso);
    Result := FlussoInVariant(Flusso);
  finally
    Flusso.Free;
    Immagine.Free;
  end;
end;

function TTestZStoredProc.ValoreInternoDelCampo(Istanza: TObject; const NomeCampo: string): TValue;
var
  Contesto: TRttiContext;
  Record_: TValue;
begin
  // legge, per riflessione, il campo fValue del Nullable contenuto nel campo
  // privato indicato: e' quello che ClearParam scrive
  Contesto := TRttiContext.Create;
  try
    Record_ := Contesto.GetType(Istanza.ClassType).GetField(NomeCampo).GetValue(Istanza);
    Result := Contesto.GetType(Record_.TypeInfo).GetField('fValue').GetValue(Record_.GetReferenceToRawData);
  finally
    Contesto.Free;
  end;
end;

// ZBASE-SPR-001

procedure TTestZStoredProc.Creazione_ClasseConAttributo_NomeESelezionabile;
begin
  Assert.AreEqual('PROVA_SELEZIONE', FProcedura.StoredProcName, 'nome');
  Assert.IsTrue(FProcedura.Selectable, 'selezionabile');
end;

procedure TTestZStoredProc.Creazione_AttributoSenzaSecondoArgomento_NonSelezionabile;
var
  Procedura: TSP_ProvaEsegui;
begin
  Procedura := TSP_ProvaEsegui.Create;
  try
    Assert.AreEqual('PROVA_ESEGUI', Procedura.StoredProcName, 'nome');
    Assert.IsFalse(Procedura.Selectable, 'selezionabile');
  finally
    Procedura.Free;
  end;
end;

procedure TTestZStoredProc.Creazione_ClasseSenzaAttributo_NomeVuotoENonSelezionabile;
var
  Procedura: TSP_SenzaAttributo;
begin
  Procedura := TSP_SenzaAttributo.Create;
  try
    Assert.AreEqual('', Procedura.StoredProcName, 'nome');
    Assert.IsFalse(Procedura.Selectable, 'selezionabile');
  finally
    Procedura.Free;
  end;
end;

// ZBASE-SPR-002

procedure TTestZStoredProc.TipoNonAmmesso_Azzeramento_SollevaEccezioneConIlNome;
var
  Procedura: TSP_TipoSemplice;
  Messaggio: string;
begin
  Procedura := TSP_TipoSemplice.Create;
  try
    Messaggio := '';
    try
      Procedura.ClearParam('CONTATORE');
    except
      on E: Exception do
        Messaggio := E.Message;
    end;

    Assert.AreEqual('(ClearParam) Tipo parametro non gestito: CONTATORE', Messaggio);
  finally
    Procedura.Free;
  end;
end;

procedure TTestZStoredProc.TipoNonAmmesso_ScritturaENullita_SollevaEccezione;
var
  Procedura: TSP_TipoSemplice;
  MessaggioScrittura, MessaggioNullita: string;
begin
  Procedura := TSP_TipoSemplice.Create;
  try
    MessaggioScrittura := '';
    try
      Procedura.SetParamValue('CONTATORE', 5, False);
    except
      on E: Exception do
        MessaggioScrittura := E.Message;
    end;

    MessaggioNullita := '';
    try
      Procedura.ParamIsNull('CONTATORE');
    except
      on E: Exception do
        MessaggioNullita := E.Message;
    end;

    Assert.AreEqual('(SetParamValue) Tipo parametro non gestito: CONTATORE', MessaggioScrittura, 'scrittura');
    Assert.AreEqual('(ParamIsNull) Tipo parametro non gestito: CONTATORE', MessaggioNullita, 'nullita');
  finally
    Procedura.Free;
  end;
end;

// ZBASE-SPR-003

procedure TTestZStoredProc.Nomi_ClasseDiProva_IngressoEUscitaDagliAttributi;
var
  Ingresso, Uscita: TStringDynArray;
begin
  Ingresso := FProcedura.RealInputParamNames;
  Uscita := FProcedura.RealOutputParamNames;

  Assert.AreEqual(7, Length(Ingresso), 'parametri di ingresso');
  Assert.IsTrue(ContieneNome(Ingresso, 'ID_CLIENTE'), 'ID_CLIENTE');
  Assert.IsTrue(ContieneNome(Ingresso, 'DATA_REGISTRAZIONE'), 'DATA_REGISTRAZIONE');
  Assert.IsTrue(ContieneNome(Ingresso, 'FIRMA'), 'FIRMA');
  Assert.AreEqual(1, Length(Uscita), 'parametri di uscita');
  Assert.AreEqual('ID_ESITO', Uscita[0], 'uscita');
end;

procedure TTestZStoredProc.Nomi_ProprietaDelleDueDirezioni_NomiDelleProprieta;
var
  Ingresso, Uscita: TStringDynArray;
begin
  Ingresso := FProcedura.InputParamNames;
  Uscita := FProcedura.OutputParamNames;

  Assert.AreEqual(7, Length(Ingresso), 'proprieta di ingresso');
  Assert.IsTrue(ContieneNome(Ingresso, 'Id_Cliente'), 'Id_Cliente');
  Assert.AreEqual(1, Length(Uscita), 'proprieta di uscita');
  Assert.AreEqual('Id_Esito', Uscita[0], 'uscita');
end;

procedure TTestZStoredProc.ParamExists_NomeInMinuscolo_Vero;
begin
  Assert.IsTrue(FProcedura.ParamExists('id_cliente'));
end;

procedure TTestZStoredProc.ParamExists_UscitaESconosciuto_VeroEFalso;
begin
  Assert.IsTrue(FProcedura.ParamExists('ID_ESITO'), 'uscita dichiarata');
  Assert.IsFalse(FProcedura.ParamExists('ID_INESISTENTE'), 'parametro sconosciuto');
end;

procedure TTestZStoredProc.Scrittura_ParametroSconosciuto_EccezioneConIlNome;
var
  Messaggio: string;
begin
  Messaggio := '';
  try
    FProcedura.SetParamValue('ID_X', 1, False);
  except
    on E: Exception do
      Messaggio := E.Message;
  end;

  Assert.AreEqual('Proprieta'' non trovata per il parametro ID_X', Messaggio);
end;

procedure TTestZStoredProc.Scrittura_NomeInMinuscolo_TrovaLaProprieta;
begin
  FProcedura.SetParamValue('id_cliente', 9, False);

  Assert.IsTrue(FProcedura.Id_Cliente.HasValue, 'HasValue');
  Assert.AreEqual(Int64(9), FProcedura.Id_Cliente.Value, 'valore');
end;

// ZBASE-SPR-004

procedure TTestZStoredProc.Scrittura_Intero_ValoreLetto;
begin
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);

  Assert.IsTrue(FProcedura.Id_Cliente.HasValue, 'HasValue');
  Assert.AreEqual(Int64(5), FProcedura.Id_Cliente.Value, 'valore');
end;

procedure TTestZStoredProc.Scrittura_InteroA64Bit_ValoreLetto;
var
  Valore: Variant;
begin
  Valore := Int64(5000000000);

  FProcedura.SetParamValue('ID_CLIENTE', Valore, False);

  Assert.IsTrue(FProcedura.Id_Cliente.HasValue, 'HasValue');
  Assert.IsTrue(FProcedura.Id_Cliente.Value = 5000000000, 'valore oltre i 32 bit');
end;

procedure TTestZStoredProc.Scrittura_Testo_ValoreLetto;
begin
  FProcedura.SetParamValue('DESCRIZIONE', 'Rossi', False);

  Assert.IsTrue(FProcedura.Descrizione.HasValue, 'HasValue');
  Assert.AreEqual('Rossi', FProcedura.Descrizione.Value, 'valore');
end;

procedure TTestZStoredProc.Scrittura_Decimale_ValoreLetto;
var
  Valore: Variant;
begin
  Valore := Double(12.5);

  FProcedura.SetParamValue('IMPORTO', Valore, False);

  Assert.IsTrue(FProcedura.Importo.HasValue, 'HasValue');
  Assert.AreEqual(Double(12.5), Double(FProcedura.Importo.Value), 0.0001, 'valore');
end;

procedure TTestZStoredProc.Scrittura_DataOra_ValoreLetto;
var
  Valore: Variant;
  DataOra: TDateTime;
begin
  DataOra := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 0, 0);
  Valore := DataOra;

  FProcedura.SetParamValue('DATA_REGISTRAZIONE', Valore, False);

  Assert.IsTrue(FProcedura.Data_Registrazione.HasValue, 'HasValue');
  Assert.IsTrue(FProcedura.Data_Registrazione.Value = DataOra, 'valore');
end;

procedure TTestZStoredProc.Scrittura_Booleano_ValoreLetto;
begin
  FProcedura.SetParamValue('ATTIVO', True, False);

  Assert.IsTrue(FProcedura.Attivo.HasValue, 'HasValue');
  Assert.IsTrue(FProcedura.Attivo.Value, 'valore');
end;

procedure TTestZStoredProc.Scrittura_Memo_TestoAssegnato;
begin
  FProcedura.SetParamValue('NOTE', 'prima riga', False);

  Assert.AreEqual('prima riga', FProcedura.Note.Text);
end;

procedure TTestZStoredProc.Scrittura_Uscita_PassaDallaProprietaInterna;
begin
  FProcedura.SetParamValue('ID_ESITO', 3, False);

  Assert.IsTrue(FProcedura.Id_Esito.HasValue, 'HasValue');
  Assert.AreEqual(3, FProcedura.Id_Esito.Value, 'valore');
end;

procedure TTestZStoredProc.Scrittura_ENulloVero_AzzeraIlParametro;
begin
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);

  FProcedura.SetParamValue('ID_CLIENTE', 0, True);

  Assert.IsTrue(FProcedura.Id_Cliente.IsNull);
end;

procedure TTestZStoredProc.CopiaDaCampo_ValoreENullo_ProprietaCoerente;
begin
  // primo record: valore 7
  FProcedura.SetParamValue('ID_CLIENTE', FTabella.FieldByName('ID_CLIENTE'));
  Assert.AreEqual(Int64(7), FProcedura.Id_Cliente.Value, 'primo record');

  // secondo record: il campo e' nullo e la proprieta' torna nulla
  FTabella.Next;
  FProcedura.SetParamValue('ID_CLIENTE', FTabella.FieldByName('ID_CLIENTE'));
  Assert.IsTrue(FProcedura.Id_Cliente.IsNull, 'secondo record');
end;

procedure TTestZStoredProc.CopiaDaCampo_CampoConIlNomeDelParametro_UsaIlNomeDelCampo;
begin
  FProcedura.SetParamValue(FTabella.FieldByName('DESCRIZIONE'));

  Assert.AreEqual('Rossi', FProcedura.Descrizione.Value);
end;

procedure TTestZStoredProc.CopiaDaCampo_CampoNil_NonCambiaNiente;
var
  Campo: TField;
begin
  Campo := nil;
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);

  FProcedura.SetParamValue('ID_CLIENTE', Campo);

  Assert.AreEqual(Int64(5), FProcedura.Id_Cliente.Value);
end;

// ZBASE-SPR-005

procedure TTestZStoredProc.Azzeramento_Scalare_NulloEValorePredefinito;
begin
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);

  FProcedura.ClearParam('ID_CLIENTE');

  Assert.IsTrue(FProcedura.Id_Cliente.IsNull, 'IsNull');
  Assert.AreEqual(Int64(0), FProcedura.Id_Cliente.Value, 'Value di un nullo');
end;

procedure TTestZStoredProc.Azzeramento_Testo_NulloEVuoto;
begin
  FProcedura.SetParamValue('DESCRIZIONE', 'Rossi', False);

  FProcedura.ClearParam('DESCRIZIONE');

  Assert.IsTrue(FProcedura.Descrizione.IsNull, 'IsNull');
  Assert.AreEqual('', FProcedura.Descrizione.Value, 'Value di un nullo');
end;

procedure TTestZStoredProc.Azzeramento_Memo_SvuotatoENullo;
begin
  FProcedura.Note.Text := 'qualcosa';

  FProcedura.ClearParam('NOTE');

  Assert.AreEqual('', FProcedura.Note.Text, 'testo');
  Assert.IsTrue(FProcedura.ParamIsNull('NOTE'), 'nullo');
end;

procedure TTestZStoredProc.Azzeramento_Immagine_Nulla;
begin
  FProcedura.SetParamValue('FIRMA', ByteDiUnaBitmap, False);
  Assert.IsFalse(FProcedura.ParamIsNull('FIRMA'), 'prima dell''azzeramento');

  FProcedura.ClearParam('FIRMA');

  Assert.IsTrue(FProcedura.ParamIsNull('FIRMA'), 'dopo l''azzeramento');
end;

procedure TTestZStoredProc.ClearParams_IngressoEUscita_TuttiNulli;
begin
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);
  FProcedura.SetParamValue('DESCRIZIONE', 'Rossi', False);
  FProcedura.SetParamValue('ATTIVO', True, False);
  FProcedura.SetParamValue('ID_ESITO', 3, False);

  FProcedura.ClearParams;

  Assert.IsTrue(FProcedura.ParamIsNull('ID_CLIENTE'), 'ID_CLIENTE');
  Assert.IsTrue(FProcedura.ParamIsNull('DESCRIZIONE'), 'DESCRIZIONE');
  Assert.IsTrue(FProcedura.ParamIsNull('ATTIVO'), 'ATTIVO');
  Assert.IsTrue(FProcedura.ParamIsNull('ID_ESITO'), 'ID_ESITO (uscita)');
end;

procedure TTestZStoredProc.Divergenza_DIV_SPR_11_AzzeramentoIntero_ValoreInternoMenoUno;
begin
  // DIV-SPR-11: ClearParam scrive -1 nel valore interno di un intero, mentre
  // TNullable.Clear scrive il valore predefinito. Va capovolto (atteso 0)
  // quando il codice e' corretto.
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);

  FProcedura.ClearParam('ID_CLIENTE');

  Assert.AreEqual(Int64(-1), ValoreInternoDelCampo(FProcedura, 'fId_Cliente').AsInt64, 'fValue dopo ClearParam');
end;

procedure TTestZStoredProc.Divergenza_DIV_SPR_11_AzzeramentoTesto_ValoreInternoResta;
begin
  // DIV-SPR-11: per il tipo string ClearParam non azzera il valore interno
  // (manca tkUString nell'elenco dei tipi). Va capovolto (atteso '') quando il
  // codice e' corretto.
  FProcedura.SetParamValue('DESCRIZIONE', 'Rossi', False);

  FProcedura.ClearParam('DESCRIZIONE');

  Assert.AreEqual('Rossi', ValoreInternoDelCampo(FProcedura, 'fDescrizione').AsString, 'fValue dopo ClearParam');
end;

// ZBASE-SPR-006

procedure TTestZStoredProc.Nullita_ParametroMaiScritto_Nulla;
begin
  Assert.IsTrue(FProcedura.ParamIsNull('ID_CLIENTE'), 'intero');
  Assert.IsTrue(FProcedura.ParamIsNull('DESCRIZIONE'), 'testo');
  Assert.IsTrue(FProcedura.ParamIsNull('DATA_REGISTRAZIONE'), 'data');
end;

procedure TTestZStoredProc.Nullita_ZeroEStringaVuotaScritti_NonNulli;
begin
  FProcedura.SetParamValue('ID_CLIENTE', 0, False);
  FProcedura.SetParamValue('DESCRIZIONE', '', False);

  Assert.IsFalse(FProcedura.ParamIsNull('ID_CLIENTE'), 'zero scritto');
  Assert.IsFalse(FProcedura.ParamIsNull('DESCRIZIONE'), 'stringa vuota scritta');
end;

procedure TTestZStoredProc.Nullita_MemoVuoto_Nullo;
begin
  FProcedura.Note.Text := '';

  Assert.IsTrue(FProcedura.ParamIsNull('NOTE'));
end;

procedure TTestZStoredProc.Nullita_MemoConTesto_NonNullo;
begin
  FProcedura.Note.Text := 'x';

  Assert.IsFalse(FProcedura.ParamIsNull('NOTE'));
end;

procedure TTestZStoredProc.Nullita_ImmagineMaiCaricata_Nulla;
begin
  Assert.IsTrue(FProcedura.ParamIsNull('FIRMA'));
end;

// ZBASE-SPR-007

procedure TTestZStoredProc.Lettura_ParametroNullo_Null;
begin
  Assert.IsTrue(VarIsNull(FProcedura.GetParamValue('ID_CLIENTE')));
end;

procedure TTestZStoredProc.Lettura_ValoreScritto_ValoreComeVariant;
var
  Valore: Variant;
begin
  FProcedura.SetParamValue('ID_CLIENTE', 5, False);
  FProcedura.SetParamValue('DESCRIZIONE', 'Rossi', False);

  Valore := FProcedura.GetParamValue('ID_CLIENTE');
  Assert.AreEqual(Int64(5), Int64(Valore), 'intero');

  Valore := FProcedura.GetParamValue('DESCRIZIONE');
  Assert.AreEqual('Rossi', string(Valore), 'testo');
end;

procedure TTestZStoredProc.Lettura_MemoDueRighe_SenzaInterruzioneFinale;
var
  Testo: string;
begin
  Testo := 'a' + sLineBreak + 'b';
  FProcedura.Note.Text := Testo;

  Assert.AreEqual(Testo, string(FProcedura.GetParamValue('NOTE')));
end;

procedure TTestZStoredProc.Lettura_Booleano_ValoreComeVariant;
begin
  FProcedura.SetParamValue('ATTIVO', True, False);

  Assert.IsTrue(Boolean(FProcedura.GetParamValue('ATTIVO')));
end;

// ZBASE-SPR-008

procedure TTestZStoredProc.Immagine_BitmapInUscita_AndataERitorno;
var
  Letto: Variant;
begin
  FProcedura.SetParamValue('FIRMA', ByteDiUnaBitmap, False);

  Assert.AreEqual(4, FProcedura.Firma.Bitmap.Width, 'larghezza');
  Assert.AreEqual(3, FProcedura.Firma.Bitmap.Height, 'altezza');
  Assert.IsFalse(FProcedura.ParamIsNull('FIRMA'), 'non nulla');

  Letto := FProcedura.GetParamValue('FIRMA');
  Assert.IsTrue(VarIsArray(Letto), 'vettore di byte');
  Assert.IsTrue(VarArrayHighBound(Letto, 1) > 0, 'contenuto non vuoto');
end;

procedure TTestZStoredProc.Immagine_PngInUscita_VieneLettaComeBitmap;
var
  Immagine: TPngImage;
  Flusso: TMemoryStream;
  BytePng: Variant;
begin
  // DIV-SPR-7 (corretta): l'uscita si legge riconoscendo il formato, non solo BMP
  Immagine := TPngImage.CreateBlank(COLOR_RGB, 8, 2, 2);
  Flusso := TMemoryStream.Create;
  try
    Immagine.SaveToStream(Flusso);
    BytePng := FlussoInVariant(Flusso);
  finally
    Flusso.Free;
    Immagine.Free;
  end;

  FProcedura.SetParamValue('FIRMA', BytePng, False);

  Assert.AreEqual(2, FProcedura.Firma.Bitmap.Width, 'larghezza');
  Assert.AreEqual(2, FProcedura.Firma.Bitmap.Height, 'altezza');
  Assert.IsFalse(FProcedura.ParamIsNull('FIRMA'), 'non nulla');
end;

// ZBASE-SPR-009

procedure TTestZStoredProc.Stato_IstanzaNuova_SenzaConnessioneNeCursore;
begin
  Assert.IsNull(FProcedura.StoredProc, 'StoredProc interno');
  Assert.IsFalse(FProcedura.Active, 'Active');
  Assert.IsTrue(FProcedura.EOF, 'EOF');
  Assert.AreEqual('', FProcedura.DebugString, 'DebugString');

  // Next e Close su un'istanza mai aperta non fanno niente
  FProcedura.Next;
  FProcedura.Close;

  Assert.IsFalse(FProcedura.Active, 'ancora non attiva');
end;

// ZBASE-SPR-010

procedure TTestZStoredProc.Gancio_Assegnato_ChiamatoConLIstanzaAppenaCreata;
var
  Procedura: TSP_ProvaEsegui;
begin
  ChiamateDelGancio := 0;
  IstanzaDelGancio := nil;
  zStoredProc.InitStoredProc := GancioDiProva;

  Procedura := TSP_ProvaEsegui.Create;
  try
    Assert.AreEqual(1, ChiamateDelGancio, 'chiamate del gancio');
    Assert.IsTrue(IstanzaDelGancio = Procedura, 'istanza passata al gancio');
  finally
    Procedura.Free;
  end;
end;

procedure TTestZStoredProc.Gancio_NonAssegnato_ConnessioneETransazioneNulle;
begin
  Assert.IsNull(FProcedura.DataBase, 'DataBase');
  Assert.IsNull(FProcedura.Transaction, 'Transaction');
  Assert.IsNull(FProcedura.zSystem, 'zSystem');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZStoredProc);

end.
