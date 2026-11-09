// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zBaseLib;

// Test DUnitX per zBase\zBaseLib.pas (specifica ZBASE-LIB, "Funzioni di base.md").
// BOZZA scritta senza poterla compilare ne' eseguire.
//
// Due gruppi:
// - TTestzBaseLib: i requisiti ZBASE-LIB-001..021 per le sole logiche isolabili
//   (stringhe, date, numeri, formattazioni, tipo di controllo, posizione delle
//   finestre su un file .ini temporaneo). Non si prova nulla che apra finestre
//   modali: PasswordOk, PasswordXX, StartWait e StopWait restano senza prova.
// - TTestzBaseLibDivergenze: caratterizzazione delle divergenze DIV-LIB-n dedotte
//   dalla lettura del codice. Ogni prova afferma il comportamento DEDOTTO: se
//   passa, la divergenza e' confermata; se fallisce, il messaggio riporta il
//   valore vero e la specifica va corretta. Quando una divergenza verra'
//   corretta nel codice, la prova va capovolta e spostata fra i requisiti.
//
// Le funzioni di zBaseLib che hanno lo stesso nome di altre unit (IsNull, Year,
// Path, Contains, Coalesce, GetTempFileName) si chiamano qualificate con
// "zBaseLib." per non dipendere dall'ordine delle uses.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IniFiles,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  Data.Db,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ActnList,
  DUnitX.TestFramework,
  zBaseLib;

type
  [TestFixture]
  TTestzBaseLib = class
  private
    function NomeFileTemporaneo(const Estensione: string): string;
    procedure EliminaFileSeEsiste(const NomeFile: string);
  public
    // ---- ZBASE-LIB-001 maiuscole iniziali ----
    // ZBASE-LIB-001
    [Test]
    procedure CapFirst_FraseMista_InizialiMaiuscole;
    // ZBASE-LIB-001
    [Test]
    procedure CapFirst_Apostrofo_RestaMinuscolo;
    // ZBASE-LIB-001
    [Test]
    procedure CapFirst_Tabulazione_ESeparatore;
    // ZBASE-LIB-001
    [Test]
    procedure CapFirst_VuotoOSoloSpazi_Vuoto;
    // ZBASE-LIB-001
    [Test]
    procedure zzCapFirst_UnderscoreSeparatoreESostituito;
    // ZBASE-LIB-001
    [Test]
    procedure zzCapFirst_SenzaSostituzione_ConservaUnderscore;
    // ZBASE-LIB-001
    [Test]
    procedure zzCapFirst_Tabulazione_NonESeparatore;
    // ZBASE-LIB-001
    [Test]
    procedure FormatDisplayLabel_NomeCampo_EtichettaLeggibile;

    // ---- ZBASE-LIB-002 confronti e valore predefinito ----
    // ZBASE-LIB-002
    [Test]
    procedure StartingWith_IgnoraMaiuscole;
    // ZBASE-LIB-002
    [Test]
    procedure StartingWith_PrefissoPiuLungoDelTesto_False;
    // ZBASE-LIB-002
    [Test]
    procedure EndsWith_IgnoraMaiuscole;
    // ZBASE-LIB-002
    [Test]
    procedure EndsWith_SuffissoPiuLungoDelTesto_False;
    // ZBASE-LIB-002
    [Test]
    procedure Contains_DistingueMaiuscole;
    // ZBASE-LIB-002
    [Test]
    procedure Coalesce_PrimoValorizzato_PrimoValore;
    // ZBASE-LIB-002
    [Test]
    procedure Coalesce_PrimoVuoto_SecondoValore;
    // ZBASE-LIB-002
    [Test]
    procedure Coalesce_EntrambiVuoti_Vuoto;
    // ZBASE-LIB-002
    [Test]
    procedure StrToChar_TestoNonVuoto_PrimoCarattere;
    // ZBASE-LIB-002
    [Test]
    procedure StrToChar_Vuoto_CarattereNullo;

    // ---- ZBASE-LIB-003 scomposizione ----
    // ZBASE-LIB-003
    [Test]
    procedure zSplitStr_ConVociVuote_LeConserva;
    // ZBASE-LIB-003
    [Test]
    procedure zSplitStr_SenzaVociVuote_ScartaVuoteESoloSpazi;
    // ZBASE-LIB-003
    [Test]
    procedure zSplitStr_ListaGiaPiena_VieneSvuotata;
    // ZBASE-LIB-003
    [Test]
    procedure zSplitStr_TestoVuoto_UnaVoceVuotaOppureNessuna;
    // ZBASE-LIB-003
    [Test]
    procedure zSplitStr_VociNonSiTagliano;

    // ---- ZBASE-LIB-004 percorsi e nomi di file ----
    // ZBASE-LIB-004
    [Test]
    procedure CalcPath_AggiungeBarraFinaleEToglieSpazi;
    // ZBASE-LIB-004
    [Test]
    procedure CalcPath_BarraGiaPresente_NonLaRaddoppia;
    // ZBASE-LIB-004
    [Test]
    procedure Path_CartellaDelloEseguibileConBarraFinale;
    // ZBASE-LIB-004
    [Test]
    procedure FileNameNoExt_PercorsoConPuntiNelNome_TogliSoloUltimaEstensione;
    // ZBASE-LIB-004
    [Test]
    procedure FileNameNoExt_SenzaEstensione_NomeInvariato;
    // ZBASE-LIB-004
    [Test]
    procedure FileNameNoExt_PuntoSoloNellaCartella_NomeInvariato;
    // ZBASE-LIB-004
    [Test]
    procedure NomeFileFromDate_Inizia_ConAnnoMeseGiornoDellaData;
    // ZBASE-LIB-004
    [Test]
    procedure FolderFromID_IdPiccolo_QuattroCartelleDiZeri;
    // ZBASE-LIB-004
    [Test]
    procedure FolderFromID_IdGrande_GruppiDiTreCifre;
    // ZBASE-LIB-004
    [Test]
    procedure FolderFromID_IdConLeStesseMigliaia_StessaCartella;
    // ZBASE-LIB-004
    [Test]
    procedure FolderFromID_SeparatoreELunghezzeIndicati;
    // ZBASE-LIB-004
    [Test]
    procedure GetTempFileName_CreaFileVuotoNellaSottocartellaTemp;

    // ---- ZBASE-LIB-005 nomi dei componenti ----
    // ZBASE-LIB-005
    [Test]
    procedure ValidateComponentName_CaratteriNonAmmessi_Underscore;
    // ZBASE-LIB-005
    [Test]
    procedure ValidateComponentName_Accentate_Underscore;
    // ZBASE-LIB-005
    [Test]
    procedure GetUniqueComponentName_ProprietarioNullo_NomeInvariato;
    // ZBASE-LIB-005
    [Test]
    procedure GetUniqueComponentName_NomeLibero_NomeInvariato;
    // ZBASE-LIB-005
    [Test]
    procedure GetUniqueComponentName_NomeOccupato_AggiungeContatoreDaZero;

    // ---- ZBASE-LIB-006 valori e date nulli ----
    // ZBASE-LIB-006
    [Test]
    procedure IsNull_NullEUnassigned_True;
    // ZBASE-LIB-006
    [Test]
    procedure IsNull_StringaVuotaEZero_False;
    // ZBASE-LIB-006
    [Test]
    procedure DateNull_ZeroEMenoSettecentomila_True;
    // ZBASE-LIB-006
    [Test]
    procedure DateNull_DataVera_False;
    // ZBASE-LIB-006
    [Test]
    procedure DateNull_SoloOraNelGiornoZero_False;
    // ZBASE-LIB-006
    [Test]
    procedure DataZeroEOraZero_ValgonoZero;
    // ZBASE-LIB-006
    [Test]
    procedure Data9999_UltimoGiornoDelNovemilaNovecento;
    // ZBASE-LIB-006
    [Test]
    procedure MaxDate_RestituisceLaPiuRecente;

    // ---- ZBASE-LIB-007 anno corrente ----
    // ZBASE-LIB-007
    [Test]
    procedure Year_DataQualsiasi_Anno;
    // ZBASE-LIB-007
    [Test]
    procedure Capodanno_PrimoGennaioDellAnnoInCorso;
    // ZBASE-LIB-007
    [Test]
    procedure SanSilvestro_TrentunoDicembreDellAnnoInCorso;

    // ---- ZBASE-LIB-008 tipi di campo ----
    // ZBASE-LIB-008
    [Test]
    procedure IsNumeric_TipiNumerici_True;
    // ZBASE-LIB-008
    [Test]
    procedure IsNumeric_TipiNonNumerici_False;
    // ZBASE-LIB-008
    [Test]
    procedure IsInteger_SoloGliInteri;

    // ---- ZBASE-LIB-009 importi e durate ----
    // ZBASE-LIB-009
    [Test]
    procedure CurrencyToStr_ImpostazioniItaliane_SimboloDopoLImporto;
    // ZBASE-LIB-009
    [Test]
    procedure CurrencyToStr_SegueLeCifreDecimaliDelSistema;
    // ZBASE-LIB-009
    [Test]
    procedure MSecToStr_UnMinutoECinqueSecondi;
    // ZBASE-LIB-009
    [Test]
    procedure MSecToStr_Zero_OraZero;

    // ---- ZBASE-LIB-010 colore di contrasto ----
    // ZBASE-LIB-010
    [Test]
    procedure GetContrastColor_SfondiChiari_TestoNero;
    // ZBASE-LIB-010
    [Test]
    procedure GetContrastColor_SfondiScuri_TestoBianco;
    // ZBASE-LIB-010
    [Test]
    procedure GetContrastColor_Bianco_TestoNero;

    // ---- ZBASE-LIB-011 posizione delle finestre ----
    // ZBASE-LIB-011
    [Test]
    procedure SaveFormPosition_ScriveStatoMisurePPI;
    // ZBASE-LIB-011
    [Test]
    procedure SaveFormPosition_CartellaInesistente_NonCreaIlFile;
    // ZBASE-LIB-011
    [Test]
    procedure LoadFormPosition_DopoIlSalvataggio_RiportaLeMisure;
    // ZBASE-LIB-011
    [Test]
    procedure LoadFormPosition_FileAssente_NonModificaLaFinestra;
    // ZBASE-LIB-011
    [Test]
    procedure LoadFormPosition_PiuGrandeDelMonitor_RestaNellAreaUtile;
    // ZBASE-LIB-011
    [Test]
    procedure LoadFormPosition_PPIDimezzato_RaddoppiaLeMisure;

    // ---- ZBASE-LIB-012 tipo di controllo ----
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_AsString_LeggeIlNomeDellEnumerato;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_AsString_ScriveDalNome;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_AsString_RoundTripPerOgniValore;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_ValoriPredefiniti;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_IsLookupEIsPickListEIsHyperLink;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_IsMemoEIsBlobEIsBoolean;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_IsMultiLine;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_IsGroupELineBreakESeparator;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_IsDataAware;
    // ZBASE-LIB-012
    [Test]
    procedure TzCtrlType_ValidForCardSempreVeroValidForViewEscludeDiversi;

    // ---- ZBASE-LIB-013 enumerati e testo ----
    // ZBASE-LIB-013
    [Test]
    procedure TEnum_EnumToString_NomeDelValore;
    // ZBASE-LIB-013
    [Test]
    procedure TEnum_StringToEnum_ValoreDalNome;

    // ---- ZBASE-LIB-014 azioni ----
    // ZBASE-LIB-014
    [Test]
    procedure ActionVisible_Falso_NascondeEDisabilita;
    // ZBASE-LIB-014
    [Test]
    procedure ActionVisible_Vero_MostraEAbilita;

    // ---- ZBASE-LIB-016 ambiente ----
    // ZBASE-LIB-016
    [Test]
    procedure ComputerName_EIlNomeDelComputerInMaiuscolo;
    // ZBASE-LIB-016
    [Test]
    procedure GetFileVersion_VuotoOppureQuattroNumeriSeparatiDaPunti;

    // ---- ZBASE-LIB-018 finestra proprietaria ----
    // ZBASE-LIB-018
    [Test]
    procedure GetPopupParent_ComponenteDiUnaForm_LaForm;
    // ZBASE-LIB-018
    [Test]
    procedure GetPopupParent_LaFormStessa_LaForm;

    // ---- ZBASE-LIB-019 salvataggio DFM ----
    // ZBASE-LIB-019
    [Test]
    procedure ComponentToDFM_ScriveIlTestoDelComponente;
    // ZBASE-LIB-019
    [Test]
    procedure ComponentToDFM_PercorsoInesistente_SollevaEccezione;

    // ---- ZBASE-LIB-020 stringhe di risorsa ----
    // ZBASE-LIB-020
    [Test]
    procedure ChangeResourceString_RiferimentoNullo_Falso;
    // ZBASE-LIB-020
    [Test]
    procedure ChangeResourceString_StringaDiRisorsa_CambiaIlValoreLetto;

    // ---- ZBASE-LIB-021 costanti ----
    // ZBASE-LIB-021
    [Test]
    procedure Apice_EIlCarattereApice;
    // ZBASE-LIB-021
    [Test]
    procedure NullDate_EZero;
  end;

  [TestFixture]
  TTestzBaseLibDivergenze = class
  public
    // ZBASE-LIB-003 (DIV-LIB-4)
    [Test]
    procedure DIV_LIB_4_zSplitStr_DelimitatoreDiDueCaratteri_ResiduoNellaVoce;
    // ZBASE-LIB-010 (DIV-LIB-6)
    [Test]
    procedure DIV_LIB_6_GetContrastColor_NeroESistema_NeroSuNero;
    // ZBASE-LIB-013 (DIV-LIB-7)
    [Test]
    procedure DIV_LIB_7_StringToEnum_NomeSconosciuto_ValoreFuoriIntervallo;
    // ZBASE-LIB-004 (DIV-LIB-9)
    [Test]
    procedure DIV_LIB_9_NomeFileFromDate_TestoDescrittivoDaNow;
    // ZBASE-LIB-008 (DIV-LIB-11)
    [Test]
    procedure DIV_LIB_11_IsNumeric_Extended_False;
    // ZBASE-LIB-004 (DIV-LIB-12)
    [Test]
    procedure DIV_LIB_12_FileNameNoExt_ToglieLaPrimaOccorrenzaDellEstensione;
    // ZBASE-LIB-011 (DIV-LIB-14)
    [Test]
    procedure DIV_LIB_14_SaveFormPosition_NomeSenzaCartella_NonSalva;
    // ZBASE-LIB-002 (DIV-LIB-15)
    [Test]
    procedure DIV_LIB_15_Contains_SottostringaVuota_False;
    // ZBASE-LIB-009 (DIV-LIB-17)
    [Test]
    procedure DIV_LIB_17_MSecToStr_OltreVentiquattroOre_PerdeIGiorni;
    // ZBASE-LIB-005 (DIV-LIB-19)
    [Test]
    procedure DIV_LIB_19_ValidateComponentName_CifraIniziale_Resta;
  end;

implementation

resourcestring
  // usata solo da ChangeResourceString_StringaDiRisorsa_CambiaIlValoreLetto
  RisorsaDiProva = 'valore originale';

{ TTestzBaseLib }

function TTestzBaseLib.NomeFileTemporaneo(const Estensione: string): string;
var
  Identificativo: string;
begin
  Identificativo := TGUID.NewGuid.ToString;
  Identificativo := Identificativo.Replace('{', '').Replace('}', '');
  Result := TPath.Combine(TPath.GetTempPath, 'zBaseLibProva_' + Identificativo + Estensione);
end;

procedure TTestzBaseLib.EliminaFileSeEsiste(const NomeFile: string);
begin
  if TFile.Exists(NomeFile) then
    TFile.Delete(NomeFile);
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-001 maiuscole iniziali
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.CapFirst_FraseMista_InizialiMaiuscole;
begin
  Assert.AreEqual('Mario Rossi', CapFirst('mario ROSSI'));
  Assert.AreEqual('Via Roma 12', CapFirst('VIA roma 12'));
end;

procedure TTestzBaseLib.CapFirst_Apostrofo_RestaMinuscolo;
begin
  // l'apostrofo non separa le parole: dopo "L'" la lettera resta minuscola
  Assert.AreEqual('L''aquila', CapFirst('L''AQUILA'));
  Assert.AreEqual('Ab-cd', CapFirst('AB-CD'));
end;

procedure TTestzBaseLib.CapFirst_Tabulazione_ESeparatore;
begin
  // ogni carattere con codice minore di 33 (spazio, tabulazione, a capo) separa le parole
  Assert.AreEqual('Via'#9'Roma', CapFirst('via'#9'roma'));
end;

procedure TTestzBaseLib.CapFirst_VuotoOSoloSpazi_Vuoto;
begin
  Assert.AreEqual('', CapFirst(''));
  Assert.AreEqual('', CapFirst('   '));
end;

procedure TTestzBaseLib.zzCapFirst_UnderscoreSeparatoreESostituito;
begin
  Assert.AreEqual('Data Nascita', zzCapFirst('data_nascita', True));
  Assert.AreEqual('Mario Rossi', zzCapFirst('MARIO rossi', True));
end;

procedure TTestzBaseLib.zzCapFirst_SenzaSostituzione_ConservaUnderscore;
begin
  Assert.AreEqual('Data_Nascita', zzCapFirst('DATA_NASCITA', False));
end;

procedure TTestzBaseLib.zzCapFirst_Tabulazione_NonESeparatore;
begin
  // a differenza di CapFirst, qui separano solo lo spazio e l'underscore
  Assert.AreEqual('Via'#9'roma', zzCapFirst('via'#9'roma', False));
end;

procedure TTestzBaseLib.FormatDisplayLabel_NomeCampo_EtichettaLeggibile;
begin
  Assert.AreEqual('Data Nascita', FormatDisplayLabel('DATA_NASCITA'));
  Assert.AreEqual('Id Utente', FormatDisplayLabel('ID_UTENTE'));
  Assert.AreEqual('', FormatDisplayLabel(''));
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-002 confronti e valore predefinito
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.StartingWith_IgnoraMaiuscole;
begin
  Assert.IsTrue(StartingWith('Codice Fiscale', 'CODICE'));
  Assert.IsTrue(StartingWith('Codice Fiscale', 'codice fisc'));
  Assert.IsFalse(StartingWith('Codice Fiscale', 'fiscale'));
end;

procedure TTestzBaseLib.StartingWith_PrefissoPiuLungoDelTesto_False;
begin
  Assert.IsFalse(StartingWith('ab', 'abc'));
end;

procedure TTestzBaseLib.EndsWith_IgnoraMaiuscole;
begin
  Assert.IsTrue(EndsWith('Relazione.PDF', '.pdf'));
  Assert.IsFalse(EndsWith('Relazione.PDF', 'Relazione'));
end;

procedure TTestzBaseLib.EndsWith_SuffissoPiuLungoDelTesto_False;
begin
  Assert.IsFalse(EndsWith('c', 'abc'));
end;

procedure TTestzBaseLib.Contains_DistingueMaiuscole;
begin
  Assert.IsTrue(zBaseLib.Contains('Codice fiscale', 'fisc'));
  Assert.IsFalse(zBaseLib.Contains('Codice fiscale', 'FISC'));
end;

procedure TTestzBaseLib.Coalesce_PrimoValorizzato_PrimoValore;
begin
  Assert.AreEqual('a', zBaseLib.Coalesce('a', 'b'));
  // una stringa di soli spazi conta come valorizzata
  Assert.AreEqual(' ', zBaseLib.Coalesce(' ', 'b'));
end;

procedure TTestzBaseLib.Coalesce_PrimoVuoto_SecondoValore;
begin
  Assert.AreEqual('b', zBaseLib.Coalesce('', 'b'));
end;

procedure TTestzBaseLib.Coalesce_EntrambiVuoti_Vuoto;
begin
  Assert.AreEqual('', zBaseLib.Coalesce('', ''));
end;

procedure TTestzBaseLib.StrToChar_TestoNonVuoto_PrimoCarattere;
begin
  Assert.IsTrue(StrToChar('Mario') = 'M');
end;

procedure TTestzBaseLib.StrToChar_Vuoto_CarattereNullo;
begin
  Assert.AreEqual(0, Ord(StrToChar('')));
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-003 scomposizione di una stringa
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.zSplitStr_ConVociVuote_LeConserva;
var
  Voci: TStringList;
begin
  Voci := TStringList.Create;
  try
    zSplitStr('a;b;;c', ';', Voci, False);

    Assert.AreEqual(4, Voci.Count);
    Assert.AreEqual('a', Voci[0]);
    Assert.AreEqual('b', Voci[1]);
    Assert.AreEqual('', Voci[2]);
    Assert.AreEqual('c', Voci[3]);
  finally
    Voci.Free;
  end;
end;

procedure TTestzBaseLib.zSplitStr_SenzaVociVuote_ScartaVuoteESoloSpazi;
var
  Voci: TStringList;
begin
  Voci := TStringList.Create;
  try
    zSplitStr('a; ;b;', ';', Voci, True);

    Assert.AreEqual(2, Voci.Count);
    Assert.AreEqual('a', Voci[0]);
    Assert.AreEqual('b', Voci[1]);
  finally
    Voci.Free;
  end;
end;

procedure TTestzBaseLib.zSplitStr_ListaGiaPiena_VieneSvuotata;
var
  Voci: TStringList;
begin
  Voci := TStringList.Create;
  try
    Voci.Add('vecchia');
    zSplitStr('x;y', ';', Voci, False);

    Assert.AreEqual(2, Voci.Count);
    Assert.AreEqual('x', Voci[0]);
  finally
    Voci.Free;
  end;
end;

procedure TTestzBaseLib.zSplitStr_TestoVuoto_UnaVoceVuotaOppureNessuna;
var
  Voci: TStringList;
begin
  Voci := TStringList.Create;
  try
    zSplitStr('', ';', Voci, False);
    Assert.AreEqual(1, Voci.Count);
    Assert.AreEqual('', Voci[0]);

    zSplitStr('', ';', Voci, True);
    Assert.AreEqual(0, Voci.Count);
  finally
    Voci.Free;
  end;
end;

procedure TTestzBaseLib.zSplitStr_VociNonSiTagliano;
var
  Voci: TStringList;
begin
  Voci := TStringList.Create;
  try
    zSplitStr(' a ;b', ';', Voci, False);

    Assert.AreEqual(' a ', Voci[0]);
  finally
    Voci.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-004 percorsi e nomi di file
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.CalcPath_AggiungeBarraFinaleEToglieSpazi;
begin
  Assert.AreEqual('C:\Temp\', CalcPath('C:\Temp'));
  Assert.AreEqual('C:\Temp\', CalcPath('  C:\Temp  '));
end;

procedure TTestzBaseLib.CalcPath_BarraGiaPresente_NonLaRaddoppia;
begin
  Assert.AreEqual('C:\Temp\', CalcPath('C:\Temp\'));
end;

procedure TTestzBaseLib.Path_CartellaDelloEseguibileConBarraFinale;
begin
  Assert.AreEqual(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)), zBaseLib.Path);
end;

procedure TTestzBaseLib.FileNameNoExt_PercorsoConPuntiNelNome_TogliSoloUltimaEstensione;
begin
  Assert.AreEqual('Relazione.2026', FileNameNoExt('C:\Dati\Relazione.2026.pdf'));
  Assert.AreEqual('fattura', FileNameNoExt('fattura.xml'));
end;

procedure TTestzBaseLib.FileNameNoExt_SenzaEstensione_NomeInvariato;
begin
  Assert.AreEqual('leggimi', FileNameNoExt('C:\Dati\leggimi'));
end;

procedure TTestzBaseLib.FileNameNoExt_PuntoSoloNellaCartella_NomeInvariato;
begin
  Assert.AreEqual('file', FileNameNoExt('C:\a.b\file'));
end;

procedure TTestzBaseLib.NomeFileFromDate_Inizia_ConAnnoMeseGiornoDellaData;
var
  Nome: string;
begin
  Nome := NomeFileFromDate(EncodeDate(2026, 11, 1));

  Assert.AreEqual('20261101', Copy(Nome, 1, 8));
  // dopo la data compatta ci sono due spazi, poi il testo con il nome del giorno
  Assert.AreEqual('  ', Copy(Nome, 9, 2));
  Assert.IsTrue(Length(Nome) > 10, Nome);
end;

procedure TTestzBaseLib.FolderFromID_IdPiccolo_QuattroCartelleDiZeri;
begin
  Assert.AreEqual('000\000\000\000\', FolderFromID(123));
  Assert.AreEqual('000\000\000\000\', FolderFromID(0));
end;

procedure TTestzBaseLib.FolderFromID_IdGrande_GruppiDiTreCifre;
begin
  // l'identificativo si porta a quindici cifre e si dividono i gruppi di tre,
  // senza l'ultimo gruppo: restano quattro cartelle
  Assert.AreEqual('000\000\001\234\', FolderFromID(1234567));
end;

procedure TTestzBaseLib.FolderFromID_IdConLeStesseMigliaia_StessaCartella;
begin
  // l'ultimo gruppo di tre cifre non entra nel percorso: mille identificativi
  // consecutivi finiscono nella stessa cartella
  Assert.AreEqual(FolderFromID(1234000), FolderFromID(1234999));
  Assert.AreNotEqual(FolderFromID(1234999), FolderFromID(1235000));
end;

procedure TTestzBaseLib.FolderFromID_SeparatoreELunghezzeIndicati;
begin
  Assert.AreEqual('000/000/001/234/', FolderFromID(1234567, 3, 15, '/'));
  // otto cifre a gruppi di quattro: resta una sola cartella
  Assert.AreEqual('0012\', FolderFromID(123456, 4, 8));
end;

procedure TTestzBaseLib.GetTempFileName_CreaFileVuotoNellaSottocartellaTemp;
var
  NomeFile: string;
  Cartella: string;
begin
  NomeFile := zBaseLib.GetTempFileName;
  try
    Assert.IsTrue(TFile.Exists(NomeFile), 'il file viene creato: ' + NomeFile);
    Assert.AreEqual(0, Integer(TFile.GetSize(NomeFile)), 'il file e'' vuoto');
    Assert.AreEqual(1, Pos('~', ExtractFileName(NomeFile)), 'il nome comincia con la tilde');

    Cartella := ExtractFileName(ExcludeTrailingPathDelimiter(ExtractFilePath(NomeFile)));
    Assert.IsTrue(SameText('Temp', Cartella), 'sta nella sottocartella Temp: ' + NomeFile);
  finally
    EliminaFileSeEsiste(NomeFile);
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-005 nomi dei componenti
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.ValidateComponentName_CaratteriNonAmmessi_Underscore;
begin
  Assert.AreEqual('Mario_Rossi_1', ValidateComponentName('Mario Rossi-1'));
  Assert.AreEqual('Edit_1', ValidateComponentName('Edit_1'));
  Assert.AreEqual('', ValidateComponentName(''));
end;

procedure TTestzBaseLib.ValidateComponentName_Accentate_Underscore;
begin
  Assert.AreEqual('Citt_', ValidateComponentName('Citt' + #$00E0));
end;

procedure TTestzBaseLib.GetUniqueComponentName_ProprietarioNullo_NomeInvariato;
begin
  Assert.AreEqual('Edit', GetUniqueComponentName('Edit', nil));
end;

procedure TTestzBaseLib.GetUniqueComponentName_NomeLibero_NomeInvariato;
var
  Proprietario: TComponent;
begin
  Proprietario := TComponent.Create(nil);
  try
    Assert.AreEqual('Edit', GetUniqueComponentName('Edit', Proprietario));
  finally
    Proprietario.Free;
  end;
end;

procedure TTestzBaseLib.GetUniqueComponentName_NomeOccupato_AggiungeContatoreDaZero;
var
  Proprietario: TComponent;
  Figlio: TComponent;
begin
  Proprietario := TComponent.Create(nil);
  try
    Figlio := TComponent.Create(Proprietario);
    Figlio.Name := 'Edit';
    Assert.AreEqual('Edit0', GetUniqueComponentName('Edit', Proprietario));

    Figlio := TComponent.Create(Proprietario);
    Figlio.Name := 'Edit0';
    Assert.AreEqual('Edit1', GetUniqueComponentName('Edit', Proprietario));
  finally
    Proprietario.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-006 valori e date nulli
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.IsNull_NullEUnassigned_True;
begin
  Assert.IsTrue(zBaseLib.IsNull(Null));
  Assert.IsTrue(zBaseLib.IsNull(Unassigned));
end;

procedure TTestzBaseLib.IsNull_StringaVuotaEZero_False;
begin
  Assert.IsFalse(zBaseLib.IsNull(''));
  Assert.IsFalse(zBaseLib.IsNull(0));
end;

procedure TTestzBaseLib.DateNull_ZeroEMenoSettecentomila_True;
begin
  Assert.IsTrue(DateNull(0));
  Assert.IsTrue(DateNull(-700000));
end;

procedure TTestzBaseLib.DateNull_DataVera_False;
begin
  Assert.IsFalse(DateNull(EncodeDate(2026, 11, 1)));
end;

procedure TTestzBaseLib.DateNull_SoloOraNelGiornoZero_False;
begin
  // il confronto e' esatto: mezzogiorno del 30/12/1899 non vale come data nulla
  Assert.IsFalse(DateNull(0.5));
end;

procedure TTestzBaseLib.DataZeroEOraZero_ValgonoZero;
begin
  Assert.IsTrue(DataZero = 0, 'DataZero');
  Assert.IsTrue(OraZero = 0, 'OraZero');
  Assert.IsTrue(DateNull(DataZero), 'DataZero e'' una data nulla');
end;

procedure TTestzBaseLib.Data9999_UltimoGiornoDelNovemilaNovecento;
begin
  Assert.IsTrue(Data9999 = EncodeDate(9999, 12, 31));
end;

procedure TTestzBaseLib.MaxDate_RestituisceLaPiuRecente;
var
  Prima: TDateTime;
  Dopo: TDateTime;
begin
  Prima := EncodeDate(2026, 1, 1);
  Dopo := EncodeDate(2026, 11, 1);

  Assert.IsTrue(MaxDate(Prima, Dopo) = Dopo, 'ordine crescente');
  Assert.IsTrue(MaxDate(Dopo, Prima) = Dopo, 'ordine inverso');
  Assert.IsTrue(MaxDate(Dopo, Dopo) = Dopo, 'uguali');
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-007 anno corrente
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.Year_DataQualsiasi_Anno;
begin
  Assert.AreEqual(2026, Integer(zBaseLib.Year(EncodeDate(2026, 11, 1))));
  Assert.AreEqual(1899, Integer(zBaseLib.Year(0)));
end;

procedure TTestzBaseLib.Capodanno_PrimoGennaioDellAnnoInCorso;
begin
  Assert.IsTrue(Capodanno = EncodeDate(YearOf(Date), 1, 1));
end;

procedure TTestzBaseLib.SanSilvestro_TrentunoDicembreDellAnnoInCorso;
begin
  Assert.IsTrue(SanSilvestro = EncodeDate(YearOf(Date), 12, 31));
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-008 tipi di campo
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.IsNumeric_TipiNumerici_True;
begin
  Assert.IsTrue(IsNumeric(ftInteger), 'ftInteger');
  Assert.IsTrue(IsNumeric(ftSmallint), 'ftSmallint');
  Assert.IsTrue(IsNumeric(ftLargeint), 'ftLargeint');
  Assert.IsTrue(IsNumeric(ftFloat), 'ftFloat');
  Assert.IsTrue(IsNumeric(ftCurrency), 'ftCurrency');
  Assert.IsTrue(IsNumeric(ftBCD), 'ftBCD');
  Assert.IsTrue(IsNumeric(ftFMTBcd), 'ftFMTBcd');
  Assert.IsTrue(IsNumeric(ftAutoInc), 'ftAutoInc');
end;

procedure TTestzBaseLib.IsNumeric_TipiNonNumerici_False;
begin
  Assert.IsFalse(IsNumeric(ftString), 'ftString');
  Assert.IsFalse(IsNumeric(ftDate), 'ftDate');
  Assert.IsFalse(IsNumeric(ftDateTime), 'ftDateTime');
  Assert.IsFalse(IsNumeric(ftBoolean), 'ftBoolean');
  Assert.IsFalse(IsNumeric(ftMemo), 'ftMemo');
end;

procedure TTestzBaseLib.IsInteger_SoloGliInteri;
begin
  Assert.IsTrue(IsInteger(ftInteger), 'ftInteger');
  Assert.IsTrue(IsInteger(ftSmallint), 'ftSmallint');
  Assert.IsTrue(IsInteger(ftLargeint), 'ftLargeint');
  Assert.IsFalse(IsInteger(ftFloat), 'ftFloat');
  Assert.IsFalse(IsInteger(ftCurrency), 'ftCurrency');
  Assert.IsFalse(IsInteger(ftString), 'ftString');
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-009 importi e durate
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.CurrencyToStr_ImpostazioniItaliane_SimboloDopoLImporto;
var
  ImpostazioniSalvate: TFormatSettings;
begin
  ImpostazioniSalvate := FormatSettings;
  try
    FormatSettings.CurrencyString := #$20AC;
    FormatSettings.CurrencyFormat := 3;
    FormatSettings.CurrencyDecimals := 2;
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';

    Assert.AreEqual('1.234,50 ' + #$20AC, CurrencyToStr(1234.5));
    Assert.AreEqual('0,00 ' + #$20AC, CurrencyToStr(0));
  finally
    FormatSettings := ImpostazioniSalvate;
  end;
end;

procedure TTestzBaseLib.CurrencyToStr_SegueLeCifreDecimaliDelSistema;
var
  ImpostazioniSalvate: TFormatSettings;
begin
  ImpostazioniSalvate := FormatSettings;
  try
    FormatSettings.CurrencyString := #$20AC;
    FormatSettings.CurrencyFormat := 3;
    FormatSettings.CurrencyDecimals := 0;
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';

    Assert.AreEqual('1.234 ' + #$20AC, CurrencyToStr(1234));
  finally
    FormatSettings := ImpostazioniSalvate;
  end;
end;

procedure TTestzBaseLib.MSecToStr_UnMinutoECinqueSecondi;
begin
  // l'attesa e' scritta con lo stesso formato dell'ora del sistema
  Assert.AreEqual(TimeToStr(EncodeTime(0, 1, 5, 0)), MSecToStr(65000));
end;

procedure TTestzBaseLib.MSecToStr_Zero_OraZero;
begin
  Assert.AreEqual(TimeToStr(0), MSecToStr(0));
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-010 colore di contrasto
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.GetContrastColor_SfondiChiari_TestoNero;
begin
  Assert.AreEqual(Integer(clBlack), Integer(GetContrastColor(clYellow)), 'giallo');
  Assert.AreEqual(Integer(clBlack), Integer(GetContrastColor(clLime)), 'verde acceso');
end;

procedure TTestzBaseLib.GetContrastColor_SfondiScuri_TestoBianco;
begin
  Assert.AreEqual(Integer(clWhite), Integer(GetContrastColor(clNavy)), 'blu scuro');
  Assert.AreEqual(Integer(clWhite), Integer(GetContrastColor(clRed)), 'rosso');
end;

procedure TTestzBaseLib.GetContrastColor_Bianco_TestoNero;
begin
  Assert.AreEqual(Integer(clBlack), Integer(GetContrastColor(clWhite)));
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-011 posizione delle finestre
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.SaveFormPosition_ScriveStatoMisurePPI;
var
  Finestra: TForm;
  NomeFile: string;
  FileIni: TIniFile;
begin
  NomeFile := NomeFileTemporaneo('.ini');
  Finestra := TForm.CreateNew(nil);
  try
    Finestra.Name := 'FinestraProva';
    Finestra.SetBounds(100, 100, 400, 300);

    SaveFormPosition(Finestra, NomeFile);

    FileIni := TIniFile.Create(NomeFile);
    try
      Assert.AreEqual(100, FileIni.ReadInteger('FinestraProva', 'Left', -1), 'Left');
      Assert.AreEqual(100, FileIni.ReadInteger('FinestraProva', 'Top', -1), 'Top');
      Assert.AreEqual(400, FileIni.ReadInteger('FinestraProva', 'Width', -1), 'Width');
      Assert.AreEqual(300, FileIni.ReadInteger('FinestraProva', 'Height', -1), 'Height');
      Assert.AreEqual(Ord(wsNormal), FileIni.ReadInteger('FinestraProva', 'State', -1), 'State');
      Assert.IsTrue(FileIni.ReadInteger('FinestraProva', 'PPI', 0) > 0, 'PPI');
    finally
      FileIni.Free;
    end;
  finally
    Finestra.Free;
    EliminaFileSeEsiste(NomeFile);
  end;
end;

procedure TTestzBaseLib.SaveFormPosition_CartellaInesistente_NonCreaIlFile;
var
  Finestra: TForm;
  NomeFile: string;
begin
  NomeFile := TPath.Combine(TPath.Combine(TPath.GetTempPath, 'zBaseLibCartellaInesistente_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '')), 'prova.ini');
  Finestra := TForm.CreateNew(nil);
  try
    Finestra.Name := 'FinestraProva';

    SaveFormPosition(Finestra, NomeFile);

    Assert.IsFalse(TFile.Exists(NomeFile));
  finally
    Finestra.Free;
  end;
end;

procedure TTestzBaseLib.LoadFormPosition_DopoIlSalvataggio_RiportaLeMisure;
var
  Sorgente: TForm;
  Destinazione: TForm;
  NomeFile: string;
begin
  NomeFile := NomeFileTemporaneo('.ini');
  Sorgente := TForm.CreateNew(nil);
  Destinazione := TForm.CreateNew(nil);
  try
    Sorgente.Name := 'FinestraProva';
    Sorgente.SetBounds(100, 100, 400, 300);
    SaveFormPosition(Sorgente, NomeFile);

    Destinazione.Name := 'AltraFinestra';
    LoadFormPosition(Destinazione, NomeFile, 'FinestraProva');

    Assert.AreEqual(100, Destinazione.Left, 'Left');
    Assert.AreEqual(100, Destinazione.Top, 'Top');
    Assert.AreEqual(400, Destinazione.Width, 'Width');
    Assert.AreEqual(300, Destinazione.Height, 'Height');
  finally
    Destinazione.Free;
    Sorgente.Free;
    EliminaFileSeEsiste(NomeFile);
  end;
end;

procedure TTestzBaseLib.LoadFormPosition_FileAssente_NonModificaLaFinestra;
var
  Finestra: TForm;
  NomeFile: string;
begin
  NomeFile := NomeFileTemporaneo('.ini');
  Finestra := TForm.CreateNew(nil);
  try
    Finestra.Name := 'FinestraProva';
    Finestra.SetBounds(50, 60, 300, 200);

    LoadFormPosition(Finestra, NomeFile);

    Assert.AreEqual(50, Finestra.Left, 'Left');
    Assert.AreEqual(60, Finestra.Top, 'Top');
    Assert.AreEqual(300, Finestra.Width, 'Width');
    Assert.AreEqual(200, Finestra.Height, 'Height');
  finally
    Finestra.Free;
  end;
end;

procedure TTestzBaseLib.LoadFormPosition_PiuGrandeDelMonitor_RestaNellAreaUtile;
var
  Finestra: TForm;
  NomeFile: string;
  FileIni: TIniFile;
  AreaUtile: TRect;
begin
  NomeFile := NomeFileTemporaneo('.ini');
  Finestra := TForm.CreateNew(nil);
  try
    Finestra.Name := 'FinestraProva';

    FileIni := TIniFile.Create(NomeFile);
    try
      FileIni.WriteInteger('FinestraProva', 'Left', 0);
      FileIni.WriteInteger('FinestraProva', 'Top', 0);
      FileIni.WriteInteger('FinestraProva', 'Width', 99999);
      FileIni.WriteInteger('FinestraProva', 'Height', 99999);
      // stesso PPI della finestra: nessuna scalatura, si prova solo il contenimento
      FileIni.WriteInteger('FinestraProva', 'PPI', Finestra.CurrentPPI);
    finally
      FileIni.Free;
    end;

    LoadFormPosition(Finestra, NomeFile);

    AreaUtile := Screen.MonitorFromRect(Finestra.BoundsRect, mdNearest).WorkareaRect;
    Assert.IsTrue(Finestra.Left >= AreaUtile.Left, 'bordo sinistro');
    Assert.IsTrue(Finestra.Top >= AreaUtile.Top, 'bordo alto');
    Assert.IsTrue(Finestra.Left + Finestra.Width <= AreaUtile.Right, 'bordo destro');
    Assert.IsTrue(Finestra.Top + Finestra.Height <= AreaUtile.Bottom, 'bordo basso');
  finally
    Finestra.Free;
    EliminaFileSeEsiste(NomeFile);
  end;
end;

procedure TTestzBaseLib.LoadFormPosition_PPIDimezzato_RaddoppiaLeMisure;
var
  Finestra: TForm;
  NomeFile: string;
  FileIni: TIniFile;
begin
  Finestra := TForm.CreateNew(nil);
  try
    // con un PPI dispari il rapporto non e' esatto: la prova non ha senso
    if Odd(Finestra.CurrentPPI) then
    begin
      Assert.Pass('PPI dispari, prova non applicabile');
      Exit;
    end;

    NomeFile := NomeFileTemporaneo('.ini');
    try
      Finestra.Name := 'FinestraProva';

      FileIni := TIniFile.Create(NomeFile);
      try
        FileIni.WriteInteger('FinestraProva', 'Left', 100);
        FileIni.WriteInteger('FinestraProva', 'Top', 100);
        FileIni.WriteInteger('FinestraProva', 'Width', 200);
        FileIni.WriteInteger('FinestraProva', 'Height', 150);
        // salvata a meta' del PPI attuale: larghezza e altezza raddoppiano (Mantis #310)
        FileIni.WriteInteger('FinestraProva', 'PPI', Finestra.CurrentPPI div 2);
      finally
        FileIni.Free;
      end;

      LoadFormPosition(Finestra, NomeFile);

      Assert.AreEqual(400, Finestra.Width, 'Width');
      Assert.AreEqual(300, Finestra.Height, 'Height');
    finally
      EliminaFileSeEsiste(NomeFile);
    end;
  finally
    Finestra.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-012 tipo di controllo
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.TzCtrlType_AsString_LeggeIlNomeDellEnumerato;
var
  Tipo: TzCtrlType;
begin
  Tipo := ctMemo;
  Assert.AreEqual('ctMemo', Tipo.AsString);

  Tipo := ctLookupExt;
  Assert.AreEqual('ctLookupExt', Tipo.AsString);
end;

procedure TTestzBaseLib.TzCtrlType_AsString_ScriveDalNome;
var
  Tipo: TzCtrlType;
begin
  Tipo := ctDefault;
  Tipo.AsString := 'ctRTF';

  Assert.AreEqual(Ord(ctRTF), Ord(Tipo));
end;

procedure TTestzBaseLib.TzCtrlType_AsString_RoundTripPerOgniValore;
var
  Tipo: TzCtrlType;
  Copia: TzCtrlType;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    Copia := ctDefault;
    Copia.AsString := Tipo.AsString;
    Assert.AreEqual(Ord(Tipo), Ord(Copia), Tipo.AsString);
  end;
end;

procedure TTestzBaseLib.TzCtrlType_ValoriPredefiniti;
begin
  Assert.AreEqual(Ord(ctLookupExt), Ord(TzCtrlType.DefaultLookupCtrlType));
  Assert.AreEqual(Ord(ctPickListImage), Ord(TzCtrlType.DefaultPickListCtrlType));
end;

procedure TTestzBaseLib.TzCtrlType_IsLookupEIsPickListEIsHyperLink;
var
  Tipo: TzCtrlType;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    // ctComboDlg non e' piu' un lookup (commento nel sorgente)
    Assert.IsTrue((Tipo in [ctLookup, ctLookupExt, ctLookupHyperLink]) = Tipo.IsLookup, 'IsLookup ' + Tipo.AsString);
    Assert.IsTrue((Tipo in [ctPickList, ctPickListImage]) = Tipo.IsPickList, 'IsPickList ' + Tipo.AsString);
    Assert.IsTrue((Tipo in [ctHyperLink, ctLookupHyperLink]) = Tipo.IsHyperLink, 'IsHyperLink ' + Tipo.AsString);
  end;
  Tipo := ctComboDlg;
  Assert.IsFalse(Tipo.IsLookup, 'ctComboDlg');
end;

procedure TTestzBaseLib.TzCtrlType_IsMemoEIsBlobEIsBoolean;
var
  Tipo: TzCtrlType;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    Assert.IsTrue((Tipo in [ctMemo, ctRTF]) = Tipo.IsMemo, 'IsMemo ' + Tipo.AsString);
    Assert.IsTrue((Tipo in [ctImage, ctMemo, ctRTF]) = Tipo.IsBlob, 'IsBlob ' + Tipo.AsString);
    Assert.IsTrue((Tipo in [ctCheckBox, ctToggleSwitch]) = Tipo.IsBoolean, 'IsBoolean ' + Tipo.AsString);
  end;
end;

procedure TTestzBaseLib.TzCtrlType_IsMultiLine;
var
  Tipo: TzCtrlType;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
    Assert.IsTrue((Tipo in [ctMemo, ctRTF, ctImage, ctRadioGroup, ctCheckGroup, ctCheckGroupBox, ctDateTimeWheelPicker, ctGroupBox]) = Tipo.IsMultiLine,
      'IsMultiLine ' + Tipo.AsString);
end;

procedure TTestzBaseLib.TzCtrlType_IsGroupELineBreakESeparator;
var
  Tipo: TzCtrlType;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    Assert.IsTrue((Tipo in [ctCheckGroupBox, ctGroupBox]) = Tipo.IsGroup, 'IsGroup ' + Tipo.AsString);
    Assert.IsTrue((Tipo = ctLineBreak) = Tipo.IsLineBreak, 'IsLineBreak ' + Tipo.AsString);
    Assert.IsTrue((Tipo = ctSeparator) = Tipo.IsSeparator, 'IsSeparator ' + Tipo.AsString);
  end;
end;

procedure TTestzBaseLib.TzCtrlType_IsDataAware;
var
  Tipo: TzCtrlType;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
    Assert.IsTrue((not (Tipo in [ctGroupBox, ctButton, ctSeparator, ctLineBreak])) = Tipo.IsDataAware, 'IsDataAware ' + Tipo.AsString);

  // il contenitore con le caselle di spunta e' legato ai dati, il semplice gruppo no
  Tipo := ctCheckGroupBox;
  Assert.IsTrue(Tipo.IsDataAware, 'ctCheckGroupBox');
  Tipo := ctGroupBox;
  Assert.IsFalse(Tipo.IsDataAware, 'ctGroupBox');
end;

procedure TTestzBaseLib.TzCtrlType_ValidForCardSempreVeroValidForViewEscludeDiversi;
var
  Tipo: TzCtrlType;
  Atteso: boolean;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    Assert.IsTrue(Tipo.ValidForCard, 'ValidForCard ' + Tipo.AsString);

    Atteso := Tipo.IsDataAware and not (Tipo in [ctRadioGroup, ctCheckGroupBox, ctDateTimeWheelPicker, ctCheckGroup]);
    Assert.IsTrue(Atteso = Tipo.ValidForView, 'ValidForView ' + Tipo.AsString);
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-013 enumerati e testo
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.TEnum_EnumToString_NomeDelValore;
begin
  Assert.AreEqual('ctLookupExt', TEnum<TzCtrlType>.EnumToString(ctLookupExt));
  Assert.AreEqual('ctDefault', TEnum<TzCtrlType>.EnumToString(ctDefault));
end;

procedure TTestzBaseLib.TEnum_StringToEnum_ValoreDalNome;
begin
  Assert.AreEqual(Ord(ctRTF), Ord(TEnum<TzCtrlType>.StringToEnum('ctRTF')));
  Assert.AreEqual(Ord(ctLineBreak), Ord(TEnum<TzCtrlType>.StringToEnum('ctLineBreak')));
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-014 azioni
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.ActionVisible_Falso_NascondeEDisabilita;
var
  Azione: TAction;
begin
  Azione := TAction.Create(nil);
  try
    Azione.Visible := True;
    Azione.Enabled := True;

    ActionVisible(Azione, False);

    Assert.IsFalse(Azione.Visible, 'Visible');
    Assert.IsFalse(Azione.Enabled, 'Enabled');
  finally
    Azione.Free;
  end;
end;

procedure TTestzBaseLib.ActionVisible_Vero_MostraEAbilita;
var
  Azione: TAction;
begin
  Azione := TAction.Create(nil);
  try
    Azione.Visible := False;
    Azione.Enabled := False;

    ActionVisible(Azione, True);

    Assert.IsTrue(Azione.Visible, 'Visible');
    Assert.IsTrue(Azione.Enabled, 'Enabled');
  finally
    Azione.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-016 ambiente
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.ComputerName_EIlNomeDelComputerInMaiuscolo;
begin
  Assert.AreEqual(UpperCase(GetEnvironmentVariable('COMPUTERNAME')), ComputerName);
end;

procedure TTestzBaseLib.GetFileVersion_VuotoOppureQuattroNumeriSeparatiDaPunti;
var
  Versione: string;
  Parti: TStringList;
  Indice: Integer;
  Numero: Integer;
begin
  Versione := GetFileVersion;
  if Versione = '' then
  begin
    // l'eseguibile di prova puo' non avere le informazioni di versione
    Assert.Pass('nessuna informazione di versione');
    Exit;
  end;

  Parti := TStringList.Create;
  try
    zSplitStr(Versione, '.', Parti, False);
    Assert.AreEqual(4, Parti.Count, Versione);
    for Indice := 0 to Parti.Count - 1 do
      Assert.IsTrue(TryStrToInt(Parti[Indice], Numero), 'numero atteso: ' + Parti[Indice]);
  finally
    Parti.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-018 finestra proprietaria
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.GetPopupParent_ComponenteDiUnaForm_LaForm;
var
  Finestra: TForm;
  Figlio: TComponent;
begin
  Finestra := TForm.CreateNew(nil);
  try
    Figlio := TComponent.Create(Finestra);

    Assert.AreSame(TObject(Finestra), TObject(GetPopupParent(Figlio)));
  finally
    Finestra.Free;
  end;
end;

procedure TTestzBaseLib.GetPopupParent_LaFormStessa_LaForm;
var
  Finestra: TForm;
begin
  Finestra := TForm.CreateNew(nil);
  try
    Assert.AreSame(TObject(Finestra), TObject(GetPopupParent(Finestra)));
  finally
    Finestra.Free;
  end;
end;

// Tolto GetPopupParent_SenzaForm_LaFinestraAttiva: senza una form il risultato e'
// Screen.ActiveCustomForm, e nel programma di prova (console) Screen e' nullo.

// ---------------------------------------------------------------------------
// ZBASE-LIB-019 salvataggio DFM
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.ComponentToDFM_ScriveIlTestoDelComponente;
var
  Componente: TComponent;
  NomeFile: string;
  Testo: string;
begin
  NomeFile := NomeFileTemporaneo('.dfm');
  Componente := TComponent.Create(nil);
  try
    Componente.Name := 'ComponenteProva';

    ComponentToDFM(Componente, NomeFile, nil);

    Testo := TFile.ReadAllText(NomeFile);
    Assert.IsTrue(Pos('object ComponenteProva: TComponent', Testo) > 0, Testo);
  finally
    Componente.Free;
    EliminaFileSeEsiste(NomeFile);
  end;
end;

procedure TTestzBaseLib.ComponentToDFM_PercorsoInesistente_SollevaEccezione;
var
  Componente: TComponent;
  NomeFile: string;
begin
  NomeFile := TPath.Combine(TPath.Combine(TPath.GetTempPath, 'zBaseLibCartellaInesistente_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '')), 'x.dfm');
  Componente := TComponent.Create(nil);
  try
    Componente.Name := 'ComponenteProva';

    Assert.WillRaise(
      procedure
      begin
        ComponentToDFM(Componente, NomeFile, nil);
      end,
      EFCreateError);
  finally
    Componente.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-020 stringhe di risorsa
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.ChangeResourceString_RiferimentoNullo_Falso;
begin
  Assert.IsFalse(ChangeResourceString(nil, 'qualunque'));
end;

procedure TTestzBaseLib.ChangeResourceString_StringaDiRisorsa_CambiaIlValoreLetto;
begin
  Assert.AreEqual('valore originale', RisorsaDiProva, 'valore di partenza');
  try
    Assert.IsTrue(ChangeResourceString(@RisorsaDiProva, 'valore sostituito'));
    Assert.AreEqual('valore sostituito', RisorsaDiProva);
  finally
    // si rimette un letterale con lo stesso testo: il testo vero della risorsa non si recupera
    ChangeResourceString(@RisorsaDiProva, 'valore originale');
  end;
end;

// ---------------------------------------------------------------------------
// ZBASE-LIB-021 costanti
// ---------------------------------------------------------------------------

procedure TTestzBaseLib.Apice_EIlCarattereApice;
begin
  Assert.AreEqual('''', string(Apice));
end;

procedure TTestzBaseLib.NullDate_EZero;
begin
  Assert.IsTrue(NullDate = 0);
end;

{ TTestzBaseLibDivergenze }

procedure TTestzBaseLibDivergenze.DIV_LIB_4_zSplitStr_DelimitatoreDiDueCaratteri_ResiduoNellaVoce;
var
  Voci: TStringList;
begin
  Voci := TStringList.Create;
  try
    zSplitStr('a||b', '||', Voci, False);

    // dopo il delimitatore si salta un solo carattere: nella seconda voce resta una barra
    Assert.AreEqual(2, Voci.Count);
    Assert.AreEqual('a', Voci[0]);
    Assert.AreEqual('|b', Voci[1], 'atteso "b" se il delimitatore fosse saltato per intero');
  finally
    Voci.Free;
  end;
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_6_GetContrastColor_NeroESistema_NeroSuNero;
begin
  // sfondo nero: il testo e' nero, quindi illeggibile
  Assert.AreEqual(Integer(clBlack), Integer(GetContrastColor(clBlack)), 'sfondo nero');
  // i colori di sistema sono numeri negativi e non si convertono in RGB
  Assert.AreEqual(Integer(clBlack), Integer(GetContrastColor(clBtnFace)), 'colore di sistema');
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_7_StringToEnum_NomeSconosciuto_ValoreFuoriIntervallo;
var
  Valore: TzCtrlType;
  Ordinale: Integer;
begin
  Valore := TEnum<TzCtrlType>.StringToEnum('NomeCheNonEsiste');
  // si legge il byte grezzo: con Ord() l'ottimizzatore da' per scontato un valore valido
  Ordinale := PByte(@Valore)^;

  Assert.IsTrue(Ordinale > Integer(High(TzCtrlType)), 'nessun errore: il risultato e'' un ordinale fuori dall''enumerato, ' + IntToStr(Ordinale));
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_9_NomeFileFromDate_TestoDescrittivoDaNow;
var
  Nome: string;
begin
  Nome := NomeFileFromDate(EncodeDate(2001, 2, 3));

  Assert.AreEqual('20010203', Copy(Nome, 1, 8));
  // il testo che segue descrive l'istante attuale, non la data passata
  Assert.IsTrue(Pos(IntToStr(YearOf(Date)), Copy(Nome, 11, MaxInt)) > 0, 'atteso l''anno corrente dopo la data compatta: ' + Nome);
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_11_IsNumeric_Extended_False;
begin
  Assert.IsFalse(IsNumeric(ftExtended), 'ftExtended non e'' fra i tipi numerici');
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_12_FileNameNoExt_ToglieLaPrimaOccorrenzaDellEstensione;
begin
  // l'estensione e' ".doc", ma si toglie la prima ".doc" del nome, che sta dentro ".docx"
  Assert.AreEqual('relx.doc', FileNameNoExt('rel.docx.doc'), 'atteso "rel.docx"');
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_14_SaveFormPosition_NomeSenzaCartella_NonSalva;
var
  Finestra: TForm;
  NomeFile: string;
begin
  NomeFile := 'zBaseLibSenzaCartella.ini';
  if TFile.Exists(NomeFile) then
    TFile.Delete(NomeFile);

  Finestra := TForm.CreateNew(nil);
  try
    Finestra.Name := 'FinestraProva';

    SaveFormPosition(Finestra, NomeFile);

    Assert.IsFalse(TFile.Exists(NomeFile), 'la cartella del nome e'' vuota e TDirectory.Exists('''') e'' falso');
  finally
    Finestra.Free;
    if TFile.Exists(NomeFile) then
      TFile.Delete(NomeFile);
  end;
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_15_Contains_SottostringaVuota_False;
begin
  // StartingWith e EndsWith con la sottostringa vuota sono veri
  Assert.IsFalse(zBaseLib.Contains('abc', ''), 'Contains');
  Assert.IsTrue(StartingWith('abc', ''), 'StartingWith');
  Assert.IsTrue(EndsWith('abc', ''), 'EndsWith');
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_17_MSecToStr_OltreVentiquattroOre_PerdeIGiorni;
begin
  // 25 ore, 1 minuto, 1 secondo: il giorno in piu' sparisce
  Assert.AreEqual(TimeToStr(EncodeTime(1, 1, 1, 0)), MSecToStr(90061000));
end;

procedure TTestzBaseLibDivergenze.DIV_LIB_19_ValidateComponentName_CifraIniziale_Resta;
begin
  Assert.AreEqual('1abc', ValidateComponentName('1abc'), 'un identificativo non puo'' cominciare con una cifra');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzBaseLib);
  TDUnitX.RegisterTestFixture(TTestzBaseLibDivergenze);

end.
