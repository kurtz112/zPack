// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zSystem.Dizionario;

// Prove di Init_zSystem (zSystem_Init.pas), specifica "Creazione e
// allineamento del dizionario" (ZBASE-INI): la sequenza dei passi, i generatori,
// le liste di valori e le voci del dizionario dei dati, con le regole per
// dominio SQL.
//
// I metadati si costruiscono in memoria dentro il TzSystem della prova, senza
// database e senza archivio .LZ. TzSystem e' un oggetto unico di processo (la
// variabile Base): ogni prova ne crea uno in Setup e lo libera in TearDown.
//
// Restano fuori le ricerche (InitLookups) con i dataset, le schede e le viste
// collegati, e AssignTableNameToDataset: chiedono tabelle dei metadati con
// chiavi esterne e dataset con SELECT.

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Data.DB,
  DUnitX.TestFramework,
  zBaseLib,
  zMetadata,
  zSystem,
  zSystem_Init;

type
  [TestFixture]
  TTestInitSistema = class
  private
    FSistema: TzSystem;
    function VoceDeiMetadati(const Nome, Tabella, Campo: string; const Tipo: TFieldType; const Dominio: string = ''): TzmdDataDictionaryItem;
    function VoceDelDizionario(const Nome: string): TzDomain;
    procedure Esegui;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-INI-001
    [Test]
    procedure Init_SenzaMetadati_NessunaEccezioneEDizionarioVuoto;
    // ZBASE-INI-001
    [Test]
    procedure Init_Richiamata_RiceveISeiPassiNellOrdine;

    // ZBASE-INI-002
    [Test]
    procedure Generatori_Nuovo_SenzaTabella_ESistemaTuttoVuoto;
    // ZBASE-INI-002
    [Test]
    procedure Generatori_PresenteNeiMetadati_RestaEsistente;
    // ZBASE-INI-002
    [Test]
    procedure Generatori_SparitoDaiMetadati_ExistsFalso;

    // ZBASE-INI-003
    [Test]
    procedure ListeDiValori_Nuova_DescrizioneEVoci;

    // ZBASE-INI-005
    [Test]
    procedure Voci_NuovaIntera_CopiaTabellaCampoENumeroDiVisualizzazione;
    // ZBASE-INI-005
    [Test]
    procedure Voci_NuovaDecimale_DueCifreDecimali;
    // ZBASE-INI-005
    [Test]
    procedure Voci_NuovaCopiaDominioDidascaliaEValorePredefinito;
    // ZBASE-INI-005
    [Test]
    procedure Voci_NuovaObbligatoria_FlagDiCampoDaiMetadati;
    // ZBASE-INI-005
    [Test]
    procedure Voci_Presente_ValorePredefinitoGiaDecisoNonSiSovrascrive;
    // ZBASE-INI-005
    [Test]
    procedure Voci_Presente_ValorePredefinitoMancanteSiRiempie;
    // ZBASE-INI-005
    [Test]
    procedure Voci_SparitaDaiMetadati_ExistsFalsoERestaNelDizionario;
    // ZBASE-INI-005
    [Test]
    procedure Voci_PresenteNeiMetadati_ExistsVero;

    // ZBASE-INI-006
    [Test]
    procedure Domini_Anno_NessunFormatoDiVisualizzazione;
    // ZBASE-INI-006
    [Test]
    procedure Domini_SiNoETrueFalse_Casella;
    // ZBASE-INI-006
    [Test]
    procedure Domini_Note_TestoLungoConBlobMemo;
    // ZBASE-INI-006
    [Test]
    procedure Domini_Immagine_ControlloImmagineConBlobGrafico;
    // ZBASE-INI-006
    [Test]
    procedure Domini_Valuta_ImportoInValuta;
  end;

implementation

{ TTestInitSistema }

procedure TTestInitSistema.Setup;
begin
  FSistema := TzSystem.Create(nil);
end;

procedure TTestInitSistema.TearDown;
begin
  FreeAndNil(FSistema);
end;

function TTestInitSistema.VoceDeiMetadati(const Nome, Tabella, Campo: string; const Tipo: TFieldType; const Dominio: string): TzmdDataDictionaryItem;
begin
  result := FSistema.MetaData.DataDictionary.Add;
  result.Name := Nome;
  result.RelationName := Tabella;
  result.RelationField := Campo;
  result.FieldType := Tipo;
  result.FieldDomain := Dominio;
end;

function TTestInitSistema.VoceDelDizionario(const Nome: string): TzDomain;
begin
  result := FSistema.zDataDictionary.Get(Nome, False);
end;

procedure TTestInitSistema.Esegui;
begin
  Init_zSystem(FSistema, FSistema.MetaData, nil);
end;

procedure TTestInitSistema.Init_SenzaMetadati_NessunaEccezioneEDizionarioVuoto;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Esegui;
    end);

  Assert.AreEqual(0, FSistema.zDataDictionary.Count);
  Assert.AreEqual(0, FSistema.zGenerators.Count);
  Assert.AreEqual(0, FSistema.zPickLists.Count);
end;

procedure TTestInitSistema.Init_Richiamata_RiceveISeiPassiNellOrdine;
var
  Passi: TStringList;
begin
  Passi := TStringList.Create;
  try
    Init_zSystem(FSistema, FSistema.MetaData,
      procedure(msg: string)
      begin
        Passi.Add(msg);
      end);

    Assert.AreEqual(6, Passi.Count);
    Assert.AreEqual('Inizializzazione Generators', Passi[0]);
    Assert.AreEqual('Inizializzazione PickLists', Passi[1]);
    Assert.AreEqual('Inizializzazione Lookups', Passi[2]);
    Assert.AreEqual('Inizializzazione DataDictionary', Passi[3]);
    Assert.AreEqual('Aggiornamento TableName', Passi[4]);
    Assert.AreEqual('Sistemazioni finali', Passi[5]);
  finally
    Passi.Free;
  end;
end;

procedure TTestInitSistema.Generatori_Nuovo_SenzaTabella_ESistemaTuttoVuoto;
var
  Generatore: TzGenerator;
begin
  FSistema.MetaData.Generators.Add.Name := 'GEN_PERSONE_ID';

  Esegui;
  Generatore := FSistema.zGenerators.Get('GEN_PERSONE_ID', False);

  Assert.IsNotNull(Generatore);
  Assert.AreEqual('GEN_PERSONE_ID', Generatore.GeneratorName);
  Assert.IsTrue(Generatore.Exists);
  Assert.AreEqual('', Generatore.TableName, 'nei metadati non c''e'' nessuna tabella PERSONE');
end;

procedure TTestInitSistema.Generatori_PresenteNeiMetadati_RestaEsistente;
var
  Generatore: TzGenerator;
begin
  Generatore := FSistema.zGenerators.Add;
  Generatore.Name := 'GEN_PERSONE_ID';
  Generatore.GeneratorName := 'GEN_PERSONE_ID';
  Generatore.Exists := False;
  FSistema.MetaData.Generators.Add.Name := 'GEN_PERSONE_ID';

  Esegui;

  Assert.AreEqual(1, FSistema.zGenerators.Count, 'nessun doppione');
  Assert.IsTrue(FSistema.zGenerators.Get('GEN_PERSONE_ID', False).Exists);
end;

procedure TTestInitSistema.Generatori_SparitoDaiMetadati_ExistsFalso;
var
  Generatore: TzGenerator;
begin
  Generatore := FSistema.zGenerators.Add;
  Generatore.Name := 'GEN_VECCHIO_ID';
  Generatore.GeneratorName := 'GEN_VECCHIO_ID';

  Esegui;

  Assert.AreEqual(1, FSistema.zGenerators.Count, 'il generatore non viene tolto');
  Assert.IsFalse(FSistema.zGenerators.Get('GEN_VECCHIO_ID', False).Exists);
end;

procedure TTestInitSistema.ListeDiValori_Nuova_DescrizioneEVoci;
var
  Lista: TzmdPicklist;
  Creata: TzPickList;
begin
  Lista := FSistema.MetaData.PickLists.Add;
  Lista.Name := 'STATO_PRATICA';
  Lista.Description.Text := 'A=Aperta' + sLineBreak + 'C=Chiusa' + sLineBreak + 'S=Sospesa';

  Esegui;
  Creata := FSistema.zPickLists.Get('STATO_PRATICA', False);

  Assert.IsNotNull(Creata);
  Assert.AreEqual(Lista.Description.Text, Creata.Description.Text);
  Assert.AreEqual(3, Creata.PickValues.Count);
end;

procedure TTestInitSistema.Voci_NuovaIntera_CopiaTabellaCampoENumeroDiVisualizzazione;
var
  Voce: TzDomain;
begin
  VoceDeiMetadati('PERSONE.ETA', 'PERSONE', 'ETA', ftInteger);

  Esegui;
  Voce := VoceDelDizionario('PERSONE.ETA');

  Assert.IsNotNull(Voce);
  Assert.AreEqual('PERSONE', Voce.TableName);
  Assert.AreEqual('ETA', Voce.FieldName);
  Assert.IsTrue(Voce.DataType = ftInteger);
  Assert.IsTrue(Voce.Exists);
  Assert.AreEqual('###,##0', Voce.DisplayFormat);
end;

procedure TTestInitSistema.Voci_NuovaDecimale_DueCifreDecimali;
begin
  VoceDeiMetadati('PERSONE.PESO', 'PERSONE', 'PESO', ftFloat);

  Esegui;

  Assert.AreEqual('###,##0.00', VoceDelDizionario('PERSONE.PESO').DisplayFormat);
end;

procedure TTestInitSistema.Voci_NuovaCopiaDominioDidascaliaEValorePredefinito;
var
  Voce: TzDomain;
  Metadati: TzmdDataDictionaryItem;
begin
  Metadati := VoceDeiMetadati('PERSONE.COGNOME', 'PERSONE', 'COGNOME', ftString, 'STR_50');
  Metadati.Caption := 'Cognome della persona';
  Metadati.DefaultValue := 'X';

  Esegui;
  Voce := VoceDelDizionario('PERSONE.COGNOME');

  Assert.AreEqual('STR_50', Voce.Domain);
  Assert.AreEqual('Cognome della persona', Voce.DisplayLabel);
  Assert.AreEqual('X', Voce.DefaultExpression);
end;

procedure TTestInitSistema.Voci_NuovaObbligatoria_FlagDiCampoDaiMetadati;
var
  Voce: TzDomain;
  Metadati: TzmdDataDictionaryItem;
begin
  Metadati := VoceDeiMetadati('PERSONE.COGNOME', 'PERSONE', 'COGNOME', ftString);
  Metadati.Required := True;
  Metadati.Readonly := False;

  Esegui;
  Voce := VoceDelDizionario('PERSONE.COGNOME');

  Assert.IsTrue(Voce.RequiredField);
  Assert.IsFalse(Voce.ReadOnlyField);
  Assert.IsTrue(Voce.Required, 'senza scelta manuale vale il flag di campo');
end;

procedure TTestInitSistema.Voci_Presente_ValorePredefinitoGiaDecisoNonSiSovrascrive;
var
  Voce: TzDomain;
  Metadati: TzmdDataDictionaryItem;
begin
  Voce := FSistema.zDataDictionary.Add;
  Voce.Name := 'PERSONE.COGNOME';
  Voce.DefaultExpression := 'X';
  Metadati := VoceDeiMetadati('PERSONE.COGNOME', 'PERSONE', 'COGNOME', ftString);
  Metadati.DefaultValue := 'Y';

  Esegui;

  Assert.AreEqual('X', VoceDelDizionario('PERSONE.COGNOME').DefaultExpression);
end;

procedure TTestInitSistema.Voci_Presente_ValorePredefinitoMancanteSiRiempie;
var
  Voce: TzDomain;
  Metadati: TzmdDataDictionaryItem;
begin
  Voce := FSistema.zDataDictionary.Add;
  Voce.Name := 'PERSONE.COGNOME';
  Metadati := VoceDeiMetadati('PERSONE.COGNOME', 'PERSONE', 'COGNOME', ftString);
  Metadati.DefaultValue := 'Y';

  Esegui;

  Assert.AreEqual('Y', VoceDelDizionario('PERSONE.COGNOME').DefaultExpression);
end;

procedure TTestInitSistema.Voci_SparitaDaiMetadati_ExistsFalsoERestaNelDizionario;
var
  Voce: TzDomain;
begin
  Voce := FSistema.zDataDictionary.Add;
  Voce.Name := 'PERSONE.VECCHIO';
  Voce.Exists := True;

  Esegui;

  Assert.AreEqual(1, FSistema.zDataDictionary.Count);
  Assert.IsFalse(VoceDelDizionario('PERSONE.VECCHIO').Exists);
end;

procedure TTestInitSistema.Voci_PresenteNeiMetadati_ExistsVero;
var
  Voce: TzDomain;
begin
  Voce := FSistema.zDataDictionary.Add;
  Voce.Name := 'PERSONE.COGNOME';
  Voce.Exists := False;
  VoceDeiMetadati('PERSONE.COGNOME', 'PERSONE', 'COGNOME', ftString);

  Esegui;

  Assert.AreEqual(1, FSistema.zDataDictionary.Count, 'nessun doppione');
  Assert.IsTrue(VoceDelDizionario('PERSONE.COGNOME').Exists);
end;

procedure TTestInitSistema.Domini_Anno_NessunFormatoDiVisualizzazione;
begin
  // altrimenti un anno si scriverebbe 1.971
  VoceDeiMetadati('PRATICHE.ANNO', 'PRATICHE', 'ANNO', ftInteger, 'ANNO');

  Esegui;

  Assert.AreEqual('', VoceDelDizionario('PRATICHE.ANNO').DisplayFormat);
end;

procedure TTestInitSistema.Domini_SiNoETrueFalse_Casella;
begin
  VoceDeiMetadati('PERSONE.ATTIVO', 'PERSONE', 'ATTIVO', ftString, 'SI_NO');
  VoceDeiMetadati('PERSONE.VISIBILE', 'PERSONE', 'VISIBILE', ftBoolean, 'TRUE_FALSE');

  Esegui;

  Assert.IsTrue(VoceDelDizionario('PERSONE.ATTIVO').zCtrlType = ctCheckBox, 'SI_NO');
  Assert.IsTrue(VoceDelDizionario('PERSONE.VISIBILE').zCtrlType = ctCheckBox, 'TRUE_FALSE');
end;

procedure TTestInitSistema.Domini_Note_TestoLungoConBlobMemo;
var
  Voce: TzDomain;
begin
  VoceDeiMetadati('PERSONE.NOTE', 'PERSONE', 'NOTE', ftMemo, 'NOTE');

  Esegui;
  Voce := VoceDelDizionario('PERSONE.NOTE');

  Assert.IsTrue(Voce.zCtrlType = ctMemo);
  Assert.IsTrue(Voce.BlobType = ftMemo);
end;

procedure TTestInitSistema.Domini_Immagine_ControlloImmagineConBlobGrafico;
var
  Voce: TzDomain;
begin
  VoceDeiMetadati('PERSONE.FOTO', 'PERSONE', 'FOTO', ftBlob, 'IMMAGINE');

  Esegui;
  Voce := VoceDelDizionario('PERSONE.FOTO');

  Assert.IsTrue(Voce.zCtrlType = ctImage);
  Assert.IsTrue(Voce.BlobType = ftGraphic);
end;

procedure TTestInitSistema.Domini_Valuta_ImportoInValuta;
var
  Voce: TzDomain;
begin
  VoceDeiMetadati('PRATICHE.IMPORTO', 'PRATICHE', 'IMPORTO', ftFloat, 'VALUTA_2');

  Esegui;
  Voce := VoceDelDizionario('PRATICHE.IMPORTO');

  Assert.IsTrue(Voce.Currency);
  // il simbolo della valuta sta prima: nel sorgente e' un carattere in
  // codifica Windows-1252
  Assert.IsTrue(EndsText('###,##0.00', Voce.DisplayFormat), Voce.DisplayFormat);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestInitSistema);

end.
