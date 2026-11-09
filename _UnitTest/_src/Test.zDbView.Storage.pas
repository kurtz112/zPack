unit Test.zDbView.Storage;

// Test DUnitX per la serializzazione del layout colonne (zDbView.Storage):
// WriteLayoutToIni/ReadLayoutFromIni lavorano su TCustomIniFile e su un
// array di record, quindi si testano con un TMemIniFile in memoria senza
// grid DevExpress e senza toccare il disco.

interface

uses
  System.SysUtils,
  System.IniFiles,
  DUnitX.TestFramework,
  zDbView.Storage;

type
  [TestFixture]
  TTestLayoutIni = class
  private
    FIni: TMemIniFile;
    function LayoutDiEsempio: TzColumnLayout;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure RoundTrip_ColonneVisibili;
    [Test]
    procedure ColonnaNascosta_IndiceMenoUno_Width100;
    [Test]
    procedure Larghezza_ClampataA2000_InLettura;
    [Test]
    procedure ColonnaNonPresente_FoundFalse_ValoriInvariati;
    [Test]
    procedure Write_CancellaLaSezionePrecedente;
    [Test]
    procedure SezioneInesistente_NessunFound;
  end;

implementation

const
  SEZIONE = 'VistaDiProva';

{ TTestLayoutIni }

procedure TTestLayoutIni.Setup;
begin
  // TMemIniFile senza filename: tutto in memoria
  FIni := TMemIniFile.Create('');
end;

procedure TTestLayoutIni.TearDown;
begin
  FreeAndNil(FIni);
end;

function TTestLayoutIni.LayoutDiEsempio: TzColumnLayout;
begin
  SetLength(result, 3);

  result[0].FieldName := 'COGNOME';
  result[0].Index := 0;
  result[0].Width := 120;
  result[0].Visible := true;

  result[1].FieldName := 'NOME';
  result[1].Index := 1;
  result[1].Width := 2500; // oltre il clamp di lettura
  result[1].Visible := true;

  result[2].FieldName := 'NOTE';
  result[2].Index := 2;
  result[2].Width := 300;
  result[2].Visible := false; // colonna nascosta
end;

procedure TTestLayoutIni.RoundTrip_ColonneVisibili;
var
  Letto: TzColumnLayout;
begin
  TzDbViewStorage.WriteLayoutToIni(FIni, SEZIONE, LayoutDiEsempio);
  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, SEZIONE, LayoutDiEsempio);

  Assert.IsTrue(Letto[0].Found);
  Assert.IsTrue(Letto[0].Visible);
  Assert.AreEqual(0, Letto[0].Index);
  Assert.AreEqual(120, Letto[0].Width);
end;

procedure TTestLayoutIni.ColonnaNascosta_IndiceMenoUno_Width100;
var
  Letto: TzColumnLayout;
begin
  TzDbViewStorage.WriteLayoutToIni(FIni, SEZIONE, LayoutDiEsempio);

  // La colonna nascosta viene scritta come indice -1 e width fissa 100
  Assert.AreEqual(-1, FIni.ReadInteger(SEZIONE, 'NOTE', 999));
  Assert.AreEqual(100, FIni.ReadInteger(SEZIONE, 'NOTE_Width', 999));

  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, SEZIONE, LayoutDiEsempio);

  Assert.IsTrue(Letto[2].Found);
  Assert.IsFalse(Letto[2].Visible);
  Assert.AreEqual(-1, Letto[2].Index);
  Assert.AreEqual(100, Letto[2].Width);
end;

procedure TTestLayoutIni.Larghezza_ClampataA2000_InLettura;
var
  Letto: TzColumnLayout;
begin
  TzDbViewStorage.WriteLayoutToIni(FIni, SEZIONE, LayoutDiEsempio);
  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, SEZIONE, LayoutDiEsempio);

  // In scrittura il valore passa intero (2500), il clamp scatta in lettura
  Assert.AreEqual(2500, FIni.ReadInteger(SEZIONE, 'NOME_Width', 0));
  Assert.AreEqual(2000, Letto[1].Width);
end;

procedure TTestLayoutIni.ColonnaNonPresente_FoundFalse_ValoriInvariati;
var
  Attuale: TzColumnLayout;
  Letto: TzColumnLayout;
begin
  TzDbViewStorage.WriteLayoutToIni(FIni, SEZIONE, LayoutDiEsempio);

  // Una colonna nuova, non presente nella sezione salvata
  Attuale := LayoutDiEsempio;
  SetLength(Attuale, 4);
  Attuale[3].FieldName := 'DATA_NASCITA';
  Attuale[3].Index := 3;
  Attuale[3].Width := 90;
  Attuale[3].Visible := true;

  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, SEZIONE, Attuale);

  Assert.IsFalse(Letto[3].Found);
  Assert.IsTrue(Letto[3].Visible);
  Assert.AreEqual(3, Letto[3].Index);
  Assert.AreEqual(90, Letto[3].Width);
end;

procedure TTestLayoutIni.Write_CancellaLaSezionePrecedente;
var
  Ridotto: TzColumnLayout;
begin
  TzDbViewStorage.WriteLayoutToIni(FIni, SEZIONE, LayoutDiEsempio);

  // Riscrittura con una sola colonna: le chiavi delle altre devono sparire
  SetLength(Ridotto, 1);
  Ridotto[0].FieldName := 'COGNOME';
  Ridotto[0].Index := 0;
  Ridotto[0].Width := 150;
  Ridotto[0].Visible := true;

  TzDbViewStorage.WriteLayoutToIni(FIni, SEZIONE, Ridotto);

  Assert.IsTrue(FIni.ValueExists(SEZIONE, 'COGNOME'));
  Assert.IsFalse(FIni.ValueExists(SEZIONE, 'NOME'));
  Assert.IsFalse(FIni.ValueExists(SEZIONE, 'NOTE'));
end;

procedure TTestLayoutIni.SezioneInesistente_NessunFound;
var
  Letto: TzColumnLayout;
  i: integer;
begin
  Letto := TzDbViewStorage.ReadLayoutFromIni(FIni, 'SezioneCheNonEsiste', LayoutDiEsempio);

  for i := 0 to High(Letto) do
    Assert.IsFalse(Letto[i].Found, Letto[i].FieldName);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestLayoutIni);

end.
