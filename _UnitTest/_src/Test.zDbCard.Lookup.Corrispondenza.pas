// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-02
// ---------------------------------------------------------------------------
unit Test.zDbCard.Lookup.Corrispondenza;

// Test DUnitX di TzCorrispondenzaChiaveLookup (zDbCard.Lookup): il confronto fra
// la chiave del record corrente di un lookup e il valore digitato nel controllo,
// da cui dipende TzControl.CopyMappingFields. Requisito ZDBCARD-LKP-008 di
// zBase\_Specifiche\Lookup della card.md (Mantis #312).
//
// Il confronto lavora su valori, non su dataset: nessun database e nessun
// controllo visuale.

interface

uses
  System.SysUtils,
  System.Variants,
  Data.DB,
  DUnitX.TestFramework,
  zDbCard.Lookup;

type
  [TestFixture]
  TTestCorrispondenzaChiaveLookup = class
  public
    // chiave di testo: il caso del codice fiscale non ancora presente (secondo difetto del 312)
    [Test]
    procedure Testo_ChiaveUgualeAlValore_Corrisponde;
    [Test]
    procedure Testo_ChiaveDiversaDalValore_NonCorrisponde;
    [Test]
    procedure Testo_MaiuscoleDiverse_Corrisponde;
    [Test]
    procedure Testo_SpaziAiBordi_Corrisponde;
    [Test]
    procedure Testo_ChiaveNullaValoreDigitato_NonCorrisponde;
    [Test]
    procedure Testo_ChiaveNullaValoreVuoto_Corrisponde;
    [Test]
    procedure Testo_ChiaveSegnapostoValoreNuovo_NonCorrisponde;
    [Test]
    procedure Testo_TuttiITipiDiTesto_ConfrontanoComeTesto;

    // chiave intera: il caso dell'OID copiato nella riga nuova (terzo difetto del 312)
    [Test]
    procedure Intero_ChiaveUgualeAlValore_Corrisponde;
    [Test]
    procedure Intero_ChiaveDiversaDalValore_NonCorrisponde;
    [Test]
    procedure Intero_ValoreProvvisorioNegativo_NonCorrispondeAllOidDiPartenza;
    [Test]
    procedure Intero_ValoreComeTestoConSpazi_Corrisponde;
    [Test]
    procedure Intero_ValoreNonNumerico_NienteDaConfrontare;
    [Test]
    procedure Intero_ValoreVuoto_NienteDaConfrontare;
    [Test]
    procedure Intero_ChiaveNullaValoreZero_Corrisponde;
    [Test]
    procedure Intero_ChiaveNullaValoreDiverso_NonCorrisponde;
    [Test]
    procedure Intero_ChiaveGrandeOltre32Bit_Corrisponde;
    [Test]
    procedure Intero_TuttiITipiInteri_ConfrontanoComeNumeri;

    // altri tipi di chiave: non si confronta, come prima del 312
    [Test]
    procedure AltriTipi_Corrispondono;
  end;

implementation

{ TTestCorrispondenzaChiaveLookup }

procedure TTestCorrispondenzaChiaveLookup.Testo_ChiaveUgualeAlValore_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, 'ZZZDNL65R21E591F', 'ZZZDNL65R21E591F'));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_ChiaveDiversaDalValore_NonCorrisponde;
begin
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, 'ZZZDNL65R21E591F', 'ZZZZZZ99Z99Z999Z'));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_MaiuscoleDiverse_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, 'ZZZDNL65R21E591F', 'zzzdnl65r21e591f'));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_SpaziAiBordi_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, ' ZZZDNL65R21E591F  ', '  ZZZDNL65R21E591F '));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_ChiaveNullaValoreDigitato_NonCorrisponde;
begin
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, Null, 'ZZZDNL65R21E591F'));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_ChiaveNullaValoreVuoto_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, Null, ''));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_ChiaveSegnapostoValoreNuovo_NonCorrisponde;
begin
  // il caso di Trevisan Carla: prima riga del lookup con il codice fiscale segnaposto,
  // codice digitato non presente nell'elenco
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftString, '0000000000000000', 'ZZZZZZ99Z99Z999Z'));
end;

procedure TTestCorrispondenzaChiaveLookup.Testo_TuttiITipiDiTesto_ConfrontanoComeTesto;
var
  Tipo: TFieldType;
begin
  for Tipo in [ftString, ftWideString, ftFixedChar, ftFixedWideChar] do
  begin
    Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(Tipo, 'ABC', 'abc'), 'uguali, tipo ' + IntToStr(Ord(Tipo)));
    Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(Tipo, 'ABC', 'ABD'), 'diversi, tipo ' + IntToStr(Ord(Tipo)));
  end;
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ChiaveUgualeAlValore_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, 95843));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ChiaveDiversaDalValore_NonCorrisponde;
begin
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, 103102));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ValoreProvvisorioNegativo_NonCorrispondeAllOidDiPartenza;
begin
  // il caso della duplicazione: la riga nuova ha id provvisorio -2, il record corrente
  // del lookup e' quello di partenza (95843): l'OID non va ricopiato nella chiave
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, -2));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ValoreComeTestoConSpazi_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, ' 95843 '));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ValoreNonNumerico_NienteDaConfrontare;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, 'abc'));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ValoreVuoto_NienteDaConfrontare;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, ''));
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, 95843, Null));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ChiaveNullaValoreZero_Corrisponde;
begin
  // come AsLargeInt di un campo nullo: vale 0
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, Null, 0));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ChiaveNullaValoreDiverso_NonCorrisponde;
begin
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftInteger, Null, 95843));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_ChiaveGrandeOltre32Bit_Corrisponde;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftLargeint, Int64(5000000000), '5000000000'));
  Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(ftLargeint, Int64(5000000000), '705032704'));
end;

procedure TTestCorrispondenzaChiaveLookup.Intero_TuttiITipiInteri_ConfrontanoComeNumeri;
var
  Tipo: TFieldType;
begin
  for Tipo in [ftSmallint, ftInteger, ftLargeint, ftWord, ftAutoInc, ftShortint, ftByte, ftLongWord] do
  begin
    Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(Tipo, 42, 42), 'uguali, tipo ' + IntToStr(Ord(Tipo)));
    Assert.IsFalse(TzCorrispondenzaChiaveLookup.Corrisponde(Tipo, 42, 43), 'diversi, tipo ' + IntToStr(Ord(Tipo)));
  end;
end;

procedure TTestCorrispondenzaChiaveLookup.AltriTipi_Corrispondono;
begin
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftFloat, 1.5, 2.5));
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftDate, Date, 'qualunque'));
  Assert.IsTrue(TzCorrispondenzaChiaveLookup.Corrisponde(ftBoolean, True, False));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCorrispondenzaChiaveLookup);

end.
