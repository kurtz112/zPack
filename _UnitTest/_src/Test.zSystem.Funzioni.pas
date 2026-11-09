// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------
unit Test.zSystem.Funzioni;

// Prove delle funzioni pure di zSystem.pas (specifica "Creazione e
// allineamento del dizionario", ZBASE-INI-007): GetCtrlType sceglie il tipo
// di controllo di un campo dal tipo di dato e dal dominio SQL; CapFirst da'
// la didascalia di ripiego di una colonna. Non servono ne' database ne'
// componenti: sono funzioni di unit.
//
// ComputerName e' la funzione che da' il nome del computer in maiuscolo alla
// procedura USR_FOLDERS_GET_VALUE (specifica "Impostazioni e cartelle",
// ZBASE-CFG-004).

interface

uses
  System.SysUtils,
  Data.DB,
  DUnitX.TestFramework,
  zBaseLib,
  zSystem;

type
  [TestFixture]
  TTestTipoDiControllo = class
  public
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_Testo_CasellaDiTesto;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_Numeri_CasellaDiTesto;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_Booleano_Casella;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_DataOra_ControlliDedicati;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_MemoEGrafico_ControlliDedicati;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_TipoNonPrevisto_Predefinito;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_DominioNoto_PrevaleSulTipo;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_DominioSenzaDistinzioneMaiuscole;
    // ZBASE-INI-007
    [Test]
    procedure GetCtrlType_DominioSconosciuto_ResteTipo;
    // Mantis #5307 - 2026-11-03: i segnaposto non sono domini
    [Test]
    procedure IsDomainPlaceholder_Segnaposto_Vero;
    // Mantis #5307 - 2026-11-03: i domini veri non sono segnaposto
    [Test]
    procedure IsDomainPlaceholder_DominioVeroOVuoto_Falso;
  end;

  [TestFixture]
  TTestDidascaliaDiRipiego = class
  public
    // ZBASE-INI-007
    [Test]
    procedure CapFirst_Vuoto_Vuoto;
    // ZBASE-INI-007
    [Test]
    procedure CapFirst_SoloSpazi_Vuoto;
    // ZBASE-INI-007
    [Test]
    procedure CapFirst_TuttoMaiuscolo_PrimaMaiuscolaRestoMinuscolo;
    // ZBASE-INI-007
    [Test]
    procedure CapFirst_TrattinoBasso_NonSeparaLeParole;
    // ZBASE-INI-007
    [Test]
    procedure CapFirst_SpaziFraParole_InizialiMaiuscole;
  end;

  [TestFixture]
  TTestNomeDelComputer = class
  public
    // ZBASE-CFG-004
    [Test]
    procedure ComputerName_NonVuotoETuttoMaiuscolo;
  end;

implementation

{ TTestTipoDiControllo }

procedure TTestTipoDiControllo.GetCtrlType_Testo_CasellaDiTesto;
begin
  Assert.IsTrue(GetCtrlType(ftString, '') = ctEdit, 'String');
  Assert.IsTrue(GetCtrlType(ftFixedChar, '') = ctEdit, 'FixedChar');
  Assert.IsTrue(GetCtrlType(ftWideString, '') = ctEdit, 'WideString');
end;

procedure TTestTipoDiControllo.GetCtrlType_Numeri_CasellaDiTesto;
begin
  Assert.IsTrue(GetCtrlType(ftSmallint, '') = ctEdit, 'Smallint');
  Assert.IsTrue(GetCtrlType(ftInteger, '') = ctEdit, 'Integer');
  Assert.IsTrue(GetCtrlType(TFieldType.ftWord, '') = ctEdit, 'Word');
  Assert.IsTrue(GetCtrlType(ftAutoInc, '') = ctEdit, 'AutoInc');
  Assert.IsTrue(GetCtrlType(ftLargeint, '') = ctEdit, 'Largeint');
  Assert.IsTrue(GetCtrlType(ftFloat, '') = ctEdit, 'Float');
  Assert.IsTrue(GetCtrlType(ftCurrency, '') = ctEdit, 'Currency');
  Assert.IsTrue(GetCtrlType(ftBCD, '') = ctEdit, 'BCD');
end;

procedure TTestTipoDiControllo.GetCtrlType_Booleano_Casella;
begin
  Assert.IsTrue(GetCtrlType(ftBoolean, '') = ctCheckBox);
end;

procedure TTestTipoDiControllo.GetCtrlType_DataOra_ControlliDedicati;
begin
  Assert.IsTrue(GetCtrlType(ftDate, '') = ctDate, 'Date');
  Assert.IsTrue(GetCtrlType(ftTime, '') = ctTime, 'Time');
  Assert.IsTrue(GetCtrlType(ftDateTime, '') = ctDateTime, 'DateTime');
  Assert.IsTrue(GetCtrlType(ftTimeStamp, '') = ctDateTime, 'TimeStamp');
end;

procedure TTestTipoDiControllo.GetCtrlType_MemoEGrafico_ControlliDedicati;
begin
  Assert.IsTrue(GetCtrlType(ftMemo, '') = ctMemo, 'Memo');
  Assert.IsTrue(GetCtrlType(ftFmtMemo, '') = ctMemo, 'FmtMemo');
  Assert.IsTrue(GetCtrlType(ftGraphic, '') = ctImage, 'Graphic');
end;

procedure TTestTipoDiControllo.GetCtrlType_TipoNonPrevisto_Predefinito;
begin
  Assert.IsTrue(GetCtrlType(ftUnknown, '') = ctDefault, 'Unknown');
  Assert.IsTrue(GetCtrlType(ftBlob, '') = ctDefault, 'Blob');
end;

procedure TTestTipoDiControllo.GetCtrlType_DominioNoto_PrevaleSulTipo;
begin
  Assert.IsTrue(GetCtrlType(ftString, 'DATA') = ctDate, 'DATA');
  Assert.IsTrue(GetCtrlType(ftString, 'DATA_ORA') = ctDateTime, 'DATA_ORA');
  Assert.IsTrue(GetCtrlType(ftString, 'ORA') = ctTime, 'ORA');
  Assert.IsTrue(GetCtrlType(ftInteger, 'SI_NO') = ctCheckBox, 'SI_NO');
  Assert.IsTrue(GetCtrlType(ftInteger, 'BOOLEAN') = ctCheckBox, 'BOOLEAN');
  Assert.IsTrue(GetCtrlType(ftString, 'NOTE') = ctMemo, 'NOTE');
  Assert.IsTrue(GetCtrlType(ftString, 'MEMO') = ctMemo, 'MEMO');
  Assert.IsTrue(GetCtrlType(ftBlob, 'IMMAGINE') = ctImage, 'IMMAGINE');
end;

procedure TTestTipoDiControllo.GetCtrlType_DominioSenzaDistinzioneMaiuscole;
begin
  Assert.IsTrue(GetCtrlType(ftInteger, 'si_no') = ctCheckBox);
  Assert.IsTrue(GetCtrlType(ftString, 'Data') = ctDate);
end;

procedure TTestTipoDiControllo.GetCtrlType_DominioSconosciuto_ResteTipo;
begin
  Assert.IsTrue(GetCtrlType(ftString, 'STR_50') = ctEdit);
  Assert.IsTrue(GetCtrlType(ftDate, 'STR_50') = ctDate);
end;

// Mantis #5307 - 2026-11-03: <procedure> con una picklist omonima trasformava
// la colonna in un elenco M/F/A e il valore non si vedeva
procedure TTestTipoDiControllo.IsDomainPlaceholder_Segnaposto_Vero;
begin
  Assert.IsTrue(IsDomainPlaceholder('<procedure>'), 'procedure');
  Assert.IsTrue(IsDomainPlaceholder('<view>'), 'view');
  Assert.IsTrue(IsDomainPlaceholder('<table>'), 'table');
  Assert.IsTrue(IsDomainPlaceholder('<???>'), 'sconosciuto');
end;

// Mantis #5307 - 2026-11-03: i domini veri e il dominio vuoto restano
// com'erano
procedure TTestTipoDiControllo.IsDomainPlaceholder_DominioVeroOVuoto_Falso;
begin
  Assert.IsFalse(IsDomainPlaceholder(''), 'vuoto');
  Assert.IsFalse(IsDomainPlaceholder('<'), 'solo apertura');
  Assert.IsFalse(IsDomainPlaceholder('STR_50'), 'dominio vero');
  Assert.IsFalse(IsDomainPlaceholder('ID'), 'dominio vero corto');
end;

{ TTestDidascaliaDiRipiego }

procedure TTestDidascaliaDiRipiego.CapFirst_Vuoto_Vuoto;
begin
  Assert.AreEqual('', CapFirst(''));
end;

procedure TTestDidascaliaDiRipiego.CapFirst_SoloSpazi_Vuoto;
begin
  Assert.AreEqual('', CapFirst('   '));
end;

procedure TTestDidascaliaDiRipiego.CapFirst_TuttoMaiuscolo_PrimaMaiuscolaRestoMinuscolo;
begin
  Assert.AreEqual('Rossi', CapFirst('ROSSI'));
  Assert.AreEqual('Rossi', CapFirst('rossi'));
end;

procedure TTestDidascaliaDiRipiego.CapFirst_TrattinoBasso_NonSeparaLeParole;
begin
  Assert.AreEqual('Data_nascita', CapFirst('DATA_NASCITA'));
end;

procedure TTestDidascaliaDiRipiego.CapFirst_SpaziFraParole_InizialiMaiuscole;
begin
  Assert.AreEqual('Rossi Mario', CapFirst('rossi mario'));
  Assert.AreEqual('Rossi Mario', CapFirst('ROSSI MARIO'));
end;

{ TTestNomeDelComputer }

procedure TTestNomeDelComputer.ComputerName_NonVuotoETuttoMaiuscolo;
begin
  Assert.IsTrue(ComputerName <> '', 'il nome del computer non e'' vuoto');
  Assert.AreEqual(UpperCase(ComputerName), ComputerName);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTipoDiControllo);
  TDUnitX.RegisterTestFixture(TTestDidascaliaDiRipiego);
  TDUnitX.RegisterTestFixture(TTestNomeDelComputer);

end.
