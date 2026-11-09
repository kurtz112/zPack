unit Test.zCodiceFiscale;

// Test DUnitX per zCodiceFiscale.pas: funzioni libere pure, nessuna
// dipendenza da UI o database. Dove possibile si usano proprieta' di
// round-trip (calcola -> valida -> estrai) invece di attesi cablati,
// cosi' i test non dipendono dal calcolo manuale del carattere di controllo.
// Nota: EstraiDataNascitaDaCodiceFiscale disambigua il secolo con la data
// corrente, quindi si testano solo date chiaramente nel passato o dell'anno
// in corso.
//
// TTestCodiceFiscaleCasiLimite copre anche i difetti corretti il 2026-10-03
// (voce R-032): regola del nome con quattro o piu' consonanti, omocodia,
// lunghezza, nati nell'anno in corso. Gli attesi con il carattere di
// controllo sono calcolati a parte con l'algoritmo ufficiale.

interface

uses
  System.SysUtils,
  System.DateUtils,
  DUnitX.TestFramework,
  zCodiceFiscale;

type
  [TestFixture]
  TTestCodiceFiscale = class
  public
    [Test]
    procedure Calcola_EsempioNoto_MarioRossi;
    [Test]
    procedure Calcola_ProduceCodiceValido;
    [Test]
    procedure Calcola_RoundTrip_DataNascita;
    [Test]
    procedure Calcola_RoundTrip_Sesso;
    [Test]
    procedure Calcola_RoundTrip_Belfiore;
    [Test]
    procedure Valido_CodiceNoto_True;
    [Test]
    procedure Valido_CarattereControlloAlterato_False;
    [Test]
    procedure Valido_LunghezzaErrata_False;
    [Test]
    procedure Valido_Vuoto_False;
  end;

  [TestFixture]
  TTestCodiceFiscaleCasiLimite = class
  public
    // --- calcolo ---
    [Test]
    procedure Calcola_DatiMancanti_StringaVuota;
    [Test]
    procedure Calcola_NomeECognomeCorti_CompletatiConX;
    [Test]
    procedure Calcola_ApostrofiEAccenti_Ignorati;
    [Test]
    procedure Calcola_NomeConQuattroConsonanti_PrimaTerzaQuarta;
    [Test]
    procedure Calcola_NomeConTreConsonanti_LePrimeTre;
    [Test]
    procedure Calcola_NatoNel2010_SecoloCorretto;
    [Test]
    procedure Calcola_NatoNellAnnoInCorso_SecoloCorretto;
    // --- validazione ---
    [Test]
    procedure Valido_DataAlPostoDelCodice_False;
    [Test]
    procedure Valido_Estero_AccettaQualunqueTestoNonVuoto;
    [Test]
    procedure Valido_DiciassetteCaratteriConControlloCoerente_False;
    // --- omocodia: cifre sostituite da lettere (L=0, M=1, ... V=9) ---
    [Test]
    procedure Omocodico_Valido_True;
    [Test]
    procedure Omocodico_AnnoInLettere_DataEstratta;
    [Test]
    procedure Omocodico_GiornoInLettere_DataEstratta;
    [Test]
    procedure Omocodico_DecinaGiornoInLettere_SessoEstratto;
    [Test]
    procedure Omocodico_ComuneInLettere_BelfioreInCifre;
  end;

  [TestFixture]
  TTestPartitaIva = class
  public
    [Test]
    procedure Valida_ChecksumCorretto_True;
    [Test]
    procedure Valida_ChecksumErrato_False;
    [Test]
    procedure Valida_LunghezzaErrata_False;
    [Test]
    procedure Estera_PrefissoUE_Riconosciuto;
    [Test]
    procedure Estera_NumericaItaliana_False;
    [Test]
    procedure Valida_PrefissoIT_Tolto;
    [Test]
    procedure Valida_LettereNelleCifre_False;
    [Test]
    procedure Valida_EsteraUE_AccettataSenzaControllo;
    [Test]
    procedure Estera_PrefissoIT_NonEstera;
  end;

  [TestFixture]
  TTestStatoEstero = class
  public
    [Test]
    procedure Vuoto_NonEstero;
    [Test]
    procedure Italia_NonEstero;
    [Test]
    procedure ItaliaMinuscoloConSpazi_NonEstero;
    [Test]
    procedure AltraSigla_Estero;
  end;

implementation

const
  // Esempio classico: Mario Rossi, maschio, nato a Roma (H501) l'1/1/1980
  CF_MARIO_ROSSI = 'RSSMRA80A01H501U';

{ TTestCodiceFiscale }

procedure TTestCodiceFiscale.Calcola_EsempioNoto_MarioRossi;
begin
  Assert.AreEqual(CF_MARIO_ROSSI,
    CalcolaCodiceFiscale('Rossi', 'Mario', 'M', EncodeDate(1980, 1, 1), 'H501'));
end;

procedure TTestCodiceFiscale.Calcola_ProduceCodiceValido;
var
  Codice: string;
begin
  Codice := CalcolaCodiceFiscale('Bianchi', 'Anna Maria', 'F', EncodeDate(1975, 6, 30), 'F205');
  Assert.AreEqual(16, Length(Codice));
  Assert.IsTrue(CodiceFiscaleValido(Codice), 'CF calcolato non valido: ' + Codice);
end;

procedure TTestCodiceFiscale.Calcola_RoundTrip_DataNascita;
var
  Codice: string;
begin
  Codice := CalcolaCodiceFiscale('Verdi', 'Luigi', 'M', EncodeDate(1962, 11, 3), 'H501');
  Assert.AreEqual(EncodeDate(1962, 11, 3), EstraiDataNascitaDaCodiceFiscale(Codice));
end;

procedure TTestCodiceFiscale.Calcola_RoundTrip_Sesso;
var
  CodiceUomo, CodiceDonna: string;
begin
  CodiceUomo := CalcolaCodiceFiscale('Verdi', 'Luigi', 'M', EncodeDate(1962, 11, 3), 'H501');
  CodiceDonna := CalcolaCodiceFiscale('Verdi', 'Luisa', 'F', EncodeDate(1962, 11, 3), 'H501');
  Assert.AreEqual('M', EstraiSessoDaCodiceFiscale(CodiceUomo));
  Assert.AreEqual('F', EstraiSessoDaCodiceFiscale(CodiceDonna));
end;

procedure TTestCodiceFiscale.Calcola_RoundTrip_Belfiore;
var
  Codice: string;
begin
  Codice := CalcolaCodiceFiscale('Verdi', 'Luigi', 'M', EncodeDate(1962, 11, 3), 'F205');
  Assert.AreEqual('F205', EstraiBelfioreNascitaDaCodiceFiscale(Codice));
end;

procedure TTestCodiceFiscale.Valido_CodiceNoto_True;
begin
  Assert.IsTrue(CodiceFiscaleValido(CF_MARIO_ROSSI));
end;

procedure TTestCodiceFiscale.Valido_CarattereControlloAlterato_False;
var
  Alterato: string;
begin
  // Cambia solo il carattere di controllo finale
  Alterato := Copy(CF_MARIO_ROSSI, 1, 15) + 'A';
  Assert.IsFalse(CodiceFiscaleValido(Alterato));
end;

procedure TTestCodiceFiscale.Valido_LunghezzaErrata_False;
begin
  Assert.IsFalse(CodiceFiscaleValido('RSSMRA80A01H501'));
  Assert.IsFalse(CodiceFiscaleValido(CF_MARIO_ROSSI + 'X'));
end;

procedure TTestCodiceFiscale.Valido_Vuoto_False;
begin
  Assert.IsFalse(CodiceFiscaleValido(''));
end;

{ TTestCodiceFiscaleCasiLimite }

procedure TTestCodiceFiscaleCasiLimite.Calcola_DatiMancanti_StringaVuota;
begin
  Assert.AreEqual('', CalcolaCodiceFiscale('', 'Mario', 'M', EncodeDate(1980, 1, 1), 'H501'));
  Assert.AreEqual('', CalcolaCodiceFiscale('Rossi', '', 'M', EncodeDate(1980, 1, 1), 'H501'));
  Assert.AreEqual('', CalcolaCodiceFiscale('Rossi', 'Mario', '', EncodeDate(1980, 1, 1), 'H501'));
end;

procedure TTestCodiceFiscaleCasiLimite.Calcola_NomeECognomeCorti_CompletatiConX;
var
  Codice: string;
begin
  // Fo: consonante F + vocale O + X; Al: consonante L + vocale A + X
  Codice := CalcolaCodiceFiscale('Fo', 'Al', 'M', EncodeDate(1980, 1, 1), 'H501');
  Assert.AreEqual('FOXLAX', Copy(Codice, 1, 6));
  Assert.IsTrue(CodiceFiscaleValido(Codice), Codice);
end;

procedure TTestCodiceFiscaleCasiLimite.Calcola_ApostrofiEAccenti_Ignorati;
var
  Codice: string;
begin
  // D'Angelo -> DANGELO -> consonanti DNG; solo le lettere A-Z contano
  Codice := CalcolaCodiceFiscale('D''Angelo', 'Luigi', 'M', EncodeDate(1980, 1, 1), 'H501');
  Assert.AreEqual('DNG', Copy(Codice, 1, 3));
end;

procedure TTestCodiceFiscaleCasiLimite.Calcola_NomeConQuattroConsonanti_PrimaTerzaQuarta;
var
  Codice: string;
begin
  // Gianfranco: consonanti G N F R N C -> prima, terza e quarta = GFR
  Assert.AreEqual('RSSGFR80A01H501K',
    CalcolaCodiceFiscale('Rossi', 'Gianfranco', 'M', EncodeDate(1980, 1, 1), 'H501'));

  // Francesco: F R N C S C -> FNC; la regola vale solo per il nome, non per il cognome
  Codice := CalcolaCodiceFiscale('Franceschi', 'Francesco', 'M', EncodeDate(1980, 1, 1), 'H501');
  Assert.AreEqual('FRNFNC', Copy(Codice, 1, 6));

  // Roberto: R B R T -> RRT
  Codice := CalcolaCodiceFiscale('Rossi', 'Roberto', 'M', EncodeDate(1980, 1, 1), 'H501');
  Assert.AreEqual('RRT', Copy(Codice, 4, 3));
end;

procedure TTestCodiceFiscaleCasiLimite.Calcola_NomeConTreConsonanti_LePrimeTre;
var
  Codice: string;
begin
  // Marco: M R C -> tre consonanti -> MRC, come per il cognome
  Codice := CalcolaCodiceFiscale('Rossi', 'Marco', 'M', EncodeDate(1980, 1, 1), 'H501');
  Assert.AreEqual('MRC', Copy(Codice, 4, 3));
end;

procedure TTestCodiceFiscaleCasiLimite.Calcola_NatoNel2010_SecoloCorretto;
var
  Codice: string;
begin
  // anni a due cifre: '10' e' 2010 e non 1910 (riguarda gli allievi minorenni)
  Codice := CalcolaCodiceFiscale('Verdi', 'Luigi', 'M', EncodeDate(2010, 5, 5), 'H501');
  Assert.AreEqual(EncodeDate(2010, 5, 5), EstraiDataNascitaDaCodiceFiscale(Codice));
end;

procedure TTestCodiceFiscaleCasiLimite.Calcola_NatoNellAnnoInCorso_SecoloCorretto;
var
  Nascita: TDateTime;
  Codice: string;
begin
  Nascita := EncodeDate(YearOf(Date), 1, 1);
  Codice := CalcolaCodiceFiscale('Verdi', 'Luigi', 'M', Nascita, 'H501');
  Assert.AreEqual(Nascita, EstraiDataNascitaDaCodiceFiscale(Codice));
end;

procedure TTestCodiceFiscaleCasiLimite.Valido_DataAlPostoDelCodice_False;
begin
  // Mantis Gesty #189: nell'importazione SIUF la colonna del codice fiscale
  // conteneva la data di nascita
  Assert.IsFalse(CodiceFiscaleValido('01/02/2008'));
  Assert.IsFalse(CodiceFiscaleValido('2008-02-01'));
end;

procedure TTestCodiceFiscaleCasiLimite.Valido_Estero_AccettaQualunqueTestoNonVuoto;
begin
  Assert.IsTrue(CodiceFiscaleValido('X123', True));
  Assert.IsFalse(CodiceFiscaleValido('', True));
end;

procedure TTestCodiceFiscaleCasiLimite.Valido_DiciassetteCaratteriConControlloCoerente_False;
begin
  // 'O' e' il controllo dei 16 caratteri precedenti
  Assert.IsFalse(CodiceFiscaleValido(CF_MARIO_ROSSI + 'O'));
end;

procedure TTestCodiceFiscaleCasiLimite.Omocodico_Valido_True;
begin
  Assert.IsTrue(CodiceFiscaleValido('RSSMRA8LA01H501F'));
  Assert.IsTrue(CodiceFiscaleValido('RSSMRA80A0MH501M'));
  Assert.IsTrue(CodiceFiscaleValido('RSSMRA80A01H50MM'));
end;

procedure TTestCodiceFiscaleCasiLimite.Omocodico_AnnoInLettere_DataEstratta;
begin
  Assert.AreEqual(EncodeDate(1980, 1, 1), EstraiDataNascitaDaCodiceFiscale('RSSMRA8LA01H501F'));
end;

procedure TTestCodiceFiscaleCasiLimite.Omocodico_GiornoInLettere_DataEstratta;
begin
  Assert.AreEqual(EncodeDate(1980, 1, 1), EstraiDataNascitaDaCodiceFiscale('RSSMRA80A0MH501M'));
end;

procedure TTestCodiceFiscaleCasiLimite.Omocodico_DecinaGiornoInLettere_SessoEstratto;
begin
  Assert.AreEqual('M', EstraiSessoDaCodiceFiscale('RSSMRA80AL1H501F'));
end;

procedure TTestCodiceFiscaleCasiLimite.Omocodico_ComuneInLettere_BelfioreInCifre;
begin
  Assert.AreEqual('H501', EstraiBelfioreNascitaDaCodiceFiscale('RSSMRA80A01H50MM'));
end;

{ TTestPartitaIva }

procedure TTestPartitaIva.Valida_ChecksumCorretto_True;
begin
  // P.IVA con checksum corretto (algoritmo Luhn-like su 11 cifre)
  Assert.IsTrue(PartitaIvaValida('00000000000'));
  Assert.IsTrue(PartitaIvaValida('01234567897'));
end;

procedure TTestPartitaIva.Valida_ChecksumErrato_False;
begin
  Assert.IsFalse(PartitaIvaValida('01234567890'));
end;

procedure TTestPartitaIva.Valida_LunghezzaErrata_False;
begin
  Assert.IsFalse(PartitaIvaValida('123'));
  Assert.IsFalse(PartitaIvaValida(''));
end;

procedure TTestPartitaIva.Estera_PrefissoUE_Riconosciuto;
begin
  Assert.IsTrue(PartitaIvaEstera('DE123456789'));
end;

procedure TTestPartitaIva.Estera_NumericaItaliana_False;
begin
  Assert.IsFalse(PartitaIvaEstera('01234567897'));
end;

procedure TTestPartitaIva.Valida_PrefissoIT_Tolto;
begin
  Assert.IsTrue(PartitaIvaValida('IT01234567897'));
  Assert.IsFalse(PartitaIvaValida('IT01234567890'));
end;

procedure TTestPartitaIva.Valida_LettereNelleCifre_False;
begin
  Assert.IsFalse(PartitaIvaValida('0123456789A'));
end;

procedure TTestPartitaIva.Valida_EsteraUE_AccettataSenzaControllo;
begin
  // Comportamento attuale fotografato: per le partite IVA UE non c'e'
  // controllo di formato, basta il prefisso del paese
  Assert.IsTrue(PartitaIvaValida('DE1'));
end;

procedure TTestPartitaIva.Estera_PrefissoIT_NonEstera;
begin
  Assert.IsFalse(PartitaIvaEstera('IT01234567897'));
  Assert.IsFalse(PartitaIvaEstera('it01234567897'));
end;

{ TTestStatoEstero }

procedure TTestStatoEstero.Vuoto_NonEstero;
begin
  Assert.IsFalse(StatoEstero(''));
  Assert.IsFalse(StatoEstero('   '));
end;

procedure TTestStatoEstero.Italia_NonEstero;
begin
  Assert.IsFalse(StatoEstero('ITA'));
end;

procedure TTestStatoEstero.ItaliaMinuscoloConSpazi_NonEstero;
begin
  Assert.IsFalse(StatoEstero(' ita '));
end;

procedure TTestStatoEstero.AltraSigla_Estero;
begin
  Assert.IsTrue(StatoEstero('FRA'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCodiceFiscale);
  TDUnitX.RegisterTestFixture(TTestCodiceFiscaleCasiLimite);
  TDUnitX.RegisterTestFixture(TTestPartitaIva);
  TDUnitX.RegisterTestFixture(TTestStatoEstero);

end.
