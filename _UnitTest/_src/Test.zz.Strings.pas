// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.Strings;

// Test DUnitX di zLibs\zz.Strings.pas: funzioni libere pure sui testi, senza
// database ne' interfaccia (specifica ZLIBS-STR, "Funzioni sui testi.md").
//
// Ogni prova porta sopra il codice del requisito. Le divergenze (DIV-STR-1..4)
// non sono provate: DIV-STR-1 (TCharSet ridotto a byte) descrive un
// comportamento che non si vuole imporre, le altre sono questioni di nomi e di
// codice non usato.
//
// Caratteri non ASCII scritti con #$XXXX per tenere il sorgente leggibile con
// qualunque codifica.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  zz.Strings;

type
  [TestFixture]
  TTestZzStrings = class
  public
    // ZLIBS-STR-001
    [Test]
    procedure PadString_NumeroCorto_ZeriIniziali;
    // ZLIBS-STR-001
    [Test]
    procedure PadString_TestoPiuLungoDiN_NonTroncato;
    // ZLIBS-STR-001
    [Test]
    procedure PadString_TestoVuotoConTrattino_RigaDiTrattini;
    // ZLIBS-STR-001
    [Test]
    procedure PadString_ConSpazi_SpaziAllaSinistra;
    // ZLIBS-STR-001
    [Test]
    procedure PadString_NZeroOLunghezzaUguale_TestoInvariato;
    // ZLIBS-STR-002
    [Test]
    procedure PadStringRight_Predefinito_ZeriInCoda;
    // ZLIBS-STR-002
    [Test]
    procedure PadStringRight_ConSpazi_SpaziInCoda;
    // ZLIBS-STR-002
    [Test]
    procedure PadStringRight_TestoPiuLungoDiN_NonTroncato;
    // ZLIBS-STR-003
    [Test]
    procedure WordCount_DelimitatoriRipetuti_ContaSoloLeParole;
    // ZLIBS-STR-003
    [Test]
    procedure WordCount_VuotoOSoloDelimitatori_Zero;
    // ZLIBS-STR-003
    [Test]
    procedure WordCount_PiuDelimitatori_TuttiSeparano;
    // ZLIBS-STR-004
    [Test]
    procedure ExtractWord_SecondaParola_SaltaDelimitatoriRipetuti;
    // ZLIBS-STR-004
    [Test]
    procedure ExtractWord_PrimaEUltimaParola;
    // ZLIBS-STR-004
    [Test]
    procedure ExtractWord_IndiceFuoriMisura_StringaVuota;
    // ZLIBS-STR-004
    [Test]
    procedure ExtractWord_TestoVuoto_StringaVuota;
    // ZLIBS-STR-005
    [Test]
    procedure RemoveCR_TreFormeDiInterruzione_UnoSpazio;
    // ZLIBS-STR-005
    [Test]
    procedure RemoveCR_DueInterruzioniConsecutive_DueSpazi;
    // ZLIBS-STR-005
    [Test]
    procedure RemoveCR_SenzaInterruzioni_TestoInvariato;
    // ZLIBS-STR-006
    [Test]
    procedure IIF_VeroEFalso_ScegliIlRamoGiusto;
    // ZLIBS-STR-007
    [Test]
    procedure StartingWith_MaiuscoleDiverse_Vero;
    // ZLIBS-STR-007
    [Test]
    procedure StartingWith_PrefissoPiuLungo_Falso;
    // ZLIBS-STR-007
    [Test]
    procedure StartingWith_TestoVuotoEPrefissoNonVuoto_Falso;
    // ZLIBS-STR-007
    [Test]
    procedure StartingWith_SpaziIniziali_NonTolti;
    // ZLIBS-STR-007
    [Test]
    procedure StartingWith_PrefissoDiversoAllaFine_Falso;
    // ZLIBS-STR-008
    [Test]
    procedure RemoveStrings_PiuSottostringhe_TutteTolte;
    // ZLIBS-STR-008
    [Test]
    procedure RemoveStrings_SenzaDistinzioneDiMaiuscole;
    // ZLIBS-STR-008
    [Test]
    procedure RemoveStrings_PassiSuccessivi_AgisconoSulRisultatoPrecedente;
    // ZLIBS-STR-008
    [Test]
    procedure RemoveStrings_FiltroDelServerGesty_SoloIlNome;
    // ZLIBS-STR-008
    [Test]
    procedure RemoveStrings_ElencoVuotoOTestoVuoto_Invariato;
    // ZLIBS-STR-009
    [Test]
    procedure Unicode_ParoleConAccenti_ContateEInterre;
    // ZLIBS-STR-009
    [Test]
    procedure Unicode_PadStringConEuro_UnCarattere;
  end;

implementation

// TTestZzStrings

procedure TTestZzStrings.PadString_NumeroCorto_ZeriIniziali;
begin
  Assert.AreEqual('007', PadString('7', 3));
end;

procedure TTestZzStrings.PadString_TestoPiuLungoDiN_NonTroncato;
begin
  Assert.AreEqual('12345', PadString('12345', 3));
end;

procedure TTestZzStrings.PadString_TestoVuotoConTrattino_RigaDiTrattini;
begin
  Assert.AreEqual('-----', PadString('', 5, '-'));
end;

procedure TTestZzStrings.PadString_ConSpazi_SpaziAllaSinistra;
begin
  Assert.AreEqual('   ab', PadString('ab', 5, ' '));
end;

procedure TTestZzStrings.PadString_NZeroOLunghezzaUguale_TestoInvariato;
begin
  Assert.AreEqual('ab', PadString('ab', 0), 'N zero');
  Assert.AreEqual('ab', PadString('ab', 2), 'N uguale alla lunghezza');
end;

procedure TTestZzStrings.PadStringRight_Predefinito_ZeriInCoda;
begin
  Assert.AreEqual('X00', PadStringRight('X', 3));
end;

procedure TTestZzStrings.PadStringRight_ConSpazi_SpaziInCoda;
begin
  Assert.AreEqual('ab   ', PadStringRight('ab', 5, ' '));
end;

procedure TTestZzStrings.PadStringRight_TestoPiuLungoDiN_NonTroncato;
begin
  Assert.AreEqual('12345', PadStringRight('12345', 3));
end;

procedure TTestZzStrings.WordCount_DelimitatoriRipetuti_ContaSoloLeParole;
begin
  Assert.AreEqual(2, WordCount('a,,b,', [',']));
end;

procedure TTestZzStrings.WordCount_VuotoOSoloDelimitatori_Zero;
begin
  Assert.AreEqual(0, WordCount('', [',']), 'testo vuoto');
  Assert.AreEqual(0, WordCount(',,,', [',']), 'soli delimitatori');
end;

procedure TTestZzStrings.WordCount_PiuDelimitatori_TuttiSeparano;
begin
  Assert.AreEqual(3, WordCount('a b'#9'c', [' ', #9]));
end;

procedure TTestZzStrings.ExtractWord_SecondaParola_SaltaDelimitatoriRipetuti;
begin
  Assert.AreEqual('due', ExtractWord(2, 'uno,,due,tre', [',']));
end;

procedure TTestZzStrings.ExtractWord_PrimaEUltimaParola;
begin
  Assert.AreEqual('uno', ExtractWord(1, ',uno,,due,tre', [',']), 'prima, con delimitatore iniziale');
  Assert.AreEqual('tre', ExtractWord(3, 'uno,,due,tre,', [',']), 'ultima, con delimitatore finale');
end;

procedure TTestZzStrings.ExtractWord_IndiceFuoriMisura_StringaVuota;
begin
  Assert.AreEqual('', ExtractWord(0, 'uno,,due,tre', [',']), 'indice 0');
  Assert.AreEqual('', ExtractWord(-1, 'uno,,due,tre', [',']), 'indice negativo');
  Assert.AreEqual('', ExtractWord(4, 'uno,,due,tre', [',']), 'indice oltre il numero di parole');
end;

procedure TTestZzStrings.ExtractWord_TestoVuoto_StringaVuota;
begin
  Assert.AreEqual('', ExtractWord(1, '', [',']));
end;

procedure TTestZzStrings.RemoveCR_TreFormeDiInterruzione_UnoSpazio;
begin
  Assert.AreEqual('a b', RemoveCR('a' + #13#10 + 'b'), 'CR LF');
  Assert.AreEqual('a b', RemoveCR('a' + #10 + 'b'), 'LF');
  Assert.AreEqual('a b', RemoveCR('a' + #13 + 'b'), 'CR');
end;

procedure TTestZzStrings.RemoveCR_DueInterruzioniConsecutive_DueSpazi;
begin
  Assert.AreEqual('a  b', RemoveCR('a' + #13#10#13#10 + 'b'));
end;

procedure TTestZzStrings.RemoveCR_SenzaInterruzioni_TestoInvariato;
begin
  Assert.AreEqual('a b', RemoveCR('a b'), 'gli spazi non cambiano');
  Assert.AreEqual('', RemoveCR(''), 'testo vuoto');
end;

procedure TTestZzStrings.IIF_VeroEFalso_ScegliIlRamoGiusto;
begin
  Assert.AreEqual('si', IIF(True, 'si', 'no'));
  Assert.AreEqual('no', IIF(False, 'si', 'no'));
end;

procedure TTestZzStrings.StartingWith_MaiuscoleDiverse_Vero;
begin
  Assert.IsTrue(StartingWith('Wintarif', 'WIN'), 'prefisso in maiuscolo');
  Assert.IsTrue(StartingWith('Wintarif', 'wintarif'), 'testo intero in minuscolo');
end;

procedure TTestZzStrings.StartingWith_PrefissoPiuLungo_Falso;
begin
  Assert.IsFalse(StartingWith('Win', 'Wintarif'));
end;

procedure TTestZzStrings.StartingWith_TestoVuotoEPrefissoNonVuoto_Falso;
begin
  Assert.IsFalse(StartingWith('', 'a'));
end;

procedure TTestZzStrings.StartingWith_SpaziIniziali_NonTolti;
begin
  Assert.IsFalse(StartingWith(' abc', 'abc'));
end;

procedure TTestZzStrings.StartingWith_PrefissoDiversoAllaFine_Falso;
begin
  Assert.IsFalse(StartingWith('abc', 'abd'));
end;

procedure TTestZzStrings.RemoveStrings_PiuSottostringhe_TutteTolte;
begin
  Assert.AreEqual('abc', RemoveStrings('a-b_c', ['-', '_']));
end;

procedure TTestZzStrings.RemoveStrings_SenzaDistinzioneDiMaiuscole;
begin
  Assert.AreEqual('Foo', RemoveStrings('FooBAR', ['bar']));
end;

procedure TTestZzStrings.RemoveStrings_PassiSuccessivi_AgisconoSulRisultatoPrecedente;
begin
  // il primo 'ab' lascia 'ab' (nato dall'unione di 'a' e 'b'), il secondo lo toglie
  Assert.AreEqual('', RemoveStrings('aabb', ['ab', 'ab']), 'due passi');
  Assert.AreEqual('ab', RemoveStrings('aabb', ['ab']), 'un solo passo');
end;

procedure TTestZzStrings.RemoveStrings_FiltroDelServerGesty_SoloIlNome;
begin
  Assert.AreEqual('NOME',
    RemoveStrings('[{"property":"NOME"}]', ['[', '{', '"property"', ':', '"', '}', ']']));
end;

procedure TTestZzStrings.RemoveStrings_ElencoVuotoOTestoVuoto_Invariato;
begin
  Assert.AreEqual('abc', RemoveStrings('abc', []), 'elenco vuoto');
  Assert.AreEqual('', RemoveStrings('', ['a']), 'testo vuoto');
end;

procedure TTestZzStrings.Unicode_ParoleConAccenti_ContateEInterre;
var
  Testo: string;
begin
  // 'Citta' con la a accentata (U+00E0), poi 'di' e 'Roma'
  Testo := 'Citt' + #$00E0 + ' di Roma';

  Assert.AreEqual(3, WordCount(Testo, [' ']), 'numero di parole');
  Assert.AreEqual('Citt' + #$00E0, ExtractWord(1, Testo, [' ']), 'prima parola con accento');
  Assert.AreEqual('Roma', ExtractWord(3, Testo, [' ']), 'ultima parola');
end;

procedure TTestZzStrings.Unicode_PadStringConEuro_UnCarattere;
begin
  Assert.AreEqual('00' + #$20AC, PadString(#$20AC, 3));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZzStrings);

end.
