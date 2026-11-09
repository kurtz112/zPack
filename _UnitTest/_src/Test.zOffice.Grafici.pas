// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-03
// ---------------------------------------------------------------------------
unit Test.zOffice.Grafici;

// Test DUnitX per zOffice.Grafici: lettura dei riferimenti chart:// dei
// modelli di stampa e registro dei grafici disponibili. Le sorgenti registrate
// qui non disegnano niente: restituiscono un testo con nome, formato e misura
// ricevuti, cosi' si controlla che cosa il registro chiede al grafico.
//
// Il registro e' globale: ogni test registra con proprietari propri e nomi
// col prefisso 'zTest', e li toglie nel TearDown.

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework,
  zOffice.Grafici;

type
  [TestFixture]
  TTestRiferimentoGrafico = class
  public
    [Test]
    procedure Completo_ConVirgoletteEMisuraDelModello;
    [Test]
    procedure SchemaMaiuscolo_PngEMisuraPredefinita;
    [Test]
    procedure AltriSchemi_NonRiferimento;
    [Test]
    procedure SoloSchema_NonRiferimento;
    [Test]
    procedure BarraFinale_Tolta;
    [Test]
    procedure Jpeg_DueGrafie;
    [Test]
    procedure Emf_OpzioniInOrdineQualsiasi;
    [Test]
    procedure PuntoEVirgola_ComeSeparatore;
    [Test]
    procedure MisuraNonValida_Ignorata;
    [Test]
    procedure MisuraXMaiuscola_Riconosciuta;
  end;

  [TestFixture]
  TTestRegistroGrafici = class
  private
    FPrimo: TObject;
    FSecondo: TObject;
    function Sorgente(const Etichetta: string): TzSorgenteGrafico;
    function Leggi(Flusso: TStream): string;
    function NomiDelTest: Integer;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Registra_NomeVuoto_Ignorato;
    [Test]
    procedure Registra_SenzaSorgente_Ignorato;
    [Test]
    procedure Esiste_NomeCompleto_SenzaDistinzioneMaiuscole;
    [Test]
    procedure Esiste_SoloNomeDelDataSet_Trovato;
    [Test]
    procedure Esiste_AltroModuloStessoDataSet_NonTrovato;
    [Test]
    procedure Registra_StessoProprietarioStessoNome_Sostituito;
    [Test]
    procedure Registra_DueProprietariStessoNome_VinceLUltimo;
    [Test]
    procedure Togli_TuttiINomiDelProprietario;
    [Test]
    procedure Togli_LasciaGliAltriProprietari;
    [Test]
    procedure Immagine_MisuraZero_Predefinita;
    [Test]
    procedure Immagine_FlussoRiavvolto;
    [Test]
    procedure Immagine_NomeSconosciuto_Nil;
    [Test]
    procedure ImmagineDaRiferimento_PassaFormatoEMisura;
    [Test]
    procedure ImmagineDaRiferimento_TestoQualsiasi_Nil;
  end;

  [TestFixture]
  TTestPixelDaCentimetri = class
  public
    [Test]
    procedure UnPollice_PuntiPerPollice;
    [Test]
    procedure VentiCentimetri_TrecentoPunti;
    [Test]
    procedure Zero_AlmenoUnPixel;
  end;

implementation

{ TTestRiferimentoGrafico }

procedure TTestRiferimentoGrafico.Completo_ConVirgoletteEMisuraDelModello;
var
  Riferimento: TzRiferimentoGrafico;
begin
  // il suffisso " @15:10" (centimetri del modello) resta a chi impagina
  Assert.IsTrue(TzRiferimentoGrafico.Prova('"chart://Mod.Andamento?svg&800x500" @15:10', Riferimento));
  Assert.AreEqual('Mod.Andamento', Riferimento.Nome);
  Assert.IsTrue(Riferimento.Formato = fgSvg);
  Assert.AreEqual(800, Riferimento.Larghezza);
  Assert.AreEqual(500, Riferimento.Altezza);
end;

procedure TTestRiferimentoGrafico.SchemaMaiuscolo_PngEMisuraPredefinita;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsTrue(TzRiferimentoGrafico.Prova('CHART://Andamento', Riferimento));
  Assert.AreEqual('Andamento', Riferimento.Nome);
  Assert.IsTrue(Riferimento.Formato = fgPng);
  Assert.AreEqual(0, Riferimento.Larghezza);
  Assert.AreEqual(0, Riferimento.Altezza);
end;

procedure TTestRiferimentoGrafico.AltriSchemi_NonRiferimento;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsFalse(TzRiferimentoGrafico.Prova('dbimg://LOGO', Riferimento));
  Assert.IsFalse(TzRiferimentoGrafico.Prova('Andamento', Riferimento));
  Assert.IsFalse(TzRiferimentoGrafico.Prova('', Riferimento));
end;

procedure TTestRiferimentoGrafico.SoloSchema_NonRiferimento;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsFalse(TzRiferimentoGrafico.Prova('chart://', Riferimento));
  Assert.IsFalse(TzRiferimentoGrafico.Prova('chart://?svg', Riferimento));
end;

procedure TTestRiferimentoGrafico.BarraFinale_Tolta;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://Andamento/', Riferimento));
  Assert.AreEqual('Andamento', Riferimento.Nome);
end;

procedure TTestRiferimentoGrafico.Jpeg_DueGrafie;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?jpg', Riferimento));
  Assert.IsTrue(Riferimento.Formato = fgJpeg);
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?JPEG', Riferimento));
  Assert.IsTrue(Riferimento.Formato = fgJpeg);
end;

procedure TTestRiferimentoGrafico.Emf_OpzioniInOrdineQualsiasi;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?1600x900&emf', Riferimento));
  Assert.IsTrue(Riferimento.Formato = fgEmf);
  Assert.AreEqual(1600, Riferimento.Larghezza);
  Assert.AreEqual(900, Riferimento.Altezza);
end;

procedure TTestRiferimentoGrafico.PuntoEVirgola_ComeSeparatore;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?svg;640x480', Riferimento));
  Assert.IsTrue(Riferimento.Formato = fgSvg);
  Assert.AreEqual(640, Riferimento.Larghezza);
end;

procedure TTestRiferimentoGrafico.MisuraNonValida_Ignorata;
var
  Riferimento: TzRiferimentoGrafico;
begin
  // misure nulle o non numeriche: resta la misura predefinita, il nome vale
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?0x500', Riferimento));
  Assert.AreEqual(0, Riferimento.Larghezza);
  Assert.AreEqual(0, Riferimento.Altezza);

  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?axb', Riferimento));
  Assert.AreEqual(0, Riferimento.Larghezza);
  Assert.AreEqual('A', Riferimento.Nome);
end;

procedure TTestRiferimentoGrafico.MisuraXMaiuscola_Riconosciuta;
var
  Riferimento: TzRiferimentoGrafico;
begin
  Assert.IsTrue(TzRiferimentoGrafico.Prova('chart://A?800X600', Riferimento));
  Assert.AreEqual(800, Riferimento.Larghezza);
  Assert.AreEqual(600, Riferimento.Altezza);
end;

{ TTestRegistroGrafici }

procedure TTestRegistroGrafici.Setup;
begin
  FPrimo := TObject.Create;
  FSecondo := TObject.Create;
end;

procedure TTestRegistroGrafici.TearDown;
begin
  TzRegistroGrafici.Togli(FPrimo);
  TzRegistroGrafici.Togli(FSecondo);
  FreeAndNil(FPrimo);
  FreeAndNil(FSecondo);
end;

function TTestRegistroGrafici.Sorgente(const Etichetta: string): TzSorgenteGrafico;
begin
  result :=
    function(Formato: TzFormatoGrafico; Larghezza, Altezza: Integer): TStream
    begin
      result := TStringStream.Create(Format('%s|%d|%d|%d', [Etichetta, Ord(Formato), Larghezza, Altezza]));
      // posizione in fondo apposta: il registro deve riavvolgere il flusso
      result.Seek(0, soEnd);
    end;
end;

function TTestRegistroGrafici.Leggi(Flusso: TStream): string;
begin
  result := '';

  if not Assigned(Flusso) then
    Exit;

  try
    result := (Flusso as TStringStream).DataString;
  finally
    Flusso.Free;
  end;
end;

function TTestRegistroGrafici.NomiDelTest: Integer;
var
  Nome: string;
begin
  result := 0;

  for Nome in TzRegistroGrafici.Nomi do
    if Nome.StartsWith('zTest', True) then
      Inc(result);
end;

procedure TTestRegistroGrafici.Registra_NomeVuoto_Ignorato;
begin
  TzRegistroGrafici.Registra('   ', FPrimo, Sorgente('a'));
  Assert.AreEqual(0, NomiDelTest);
  Assert.IsFalse(TzRegistroGrafici.Esiste(''));
end;

procedure TTestRegistroGrafici.Registra_SenzaSorgente_Ignorato;
begin
  TzRegistroGrafici.Registra('zTestSenzaSorgente', FPrimo, nil);
  Assert.IsFalse(TzRegistroGrafici.Esiste('zTestSenzaSorgente'));
end;

procedure TTestRegistroGrafici.Esiste_NomeCompleto_SenzaDistinzioneMaiuscole;
begin
  TzRegistroGrafici.Registra('zTestModulo.Andamento', FPrimo, Sorgente('a'));
  Assert.IsTrue(TzRegistroGrafici.Esiste('ZTESTMODULO.ANDAMENTO'));
  Assert.IsTrue(TzRegistroGrafici.Esiste('  zTestModulo.Andamento  '));
end;

procedure TTestRegistroGrafici.Esiste_SoloNomeDelDataSet_Trovato;
begin
  TzRegistroGrafici.Registra('zTestModulo.zTestAndamento', FPrimo, Sorgente('a'));
  Assert.IsTrue(TzRegistroGrafici.Esiste('zTestAndamento'));
end;

procedure TTestRegistroGrafici.Esiste_AltroModuloStessoDataSet_NonTrovato;
begin
  // con il punto il nome e' un identificativo completo: niente ripiego sul dataset
  TzRegistroGrafici.Registra('zTestModulo.zTestAndamento', FPrimo, Sorgente('a'));
  Assert.IsFalse(TzRegistroGrafici.Esiste('zTestAltro.zTestAndamento'));
end;

procedure TTestRegistroGrafici.Registra_StessoProprietarioStessoNome_Sostituito;
begin
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('vecchio'));
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('nuovo'));

  Assert.AreEqual(1, NomiDelTest);
  Assert.StartsWith('nuovo|', Leggi(TzRegistroGrafici.Immagine('zTestGrafico', fgPng, 10, 10)));
end;

procedure TTestRegistroGrafici.Registra_DueProprietariStessoNome_VinceLUltimo;
begin
  // la stessa form aperta due volte: risponde la piu' recente
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('primo'));
  TzRegistroGrafici.Registra('zTestGrafico', FSecondo, Sorgente('secondo'));

  Assert.AreEqual(2, NomiDelTest);
  Assert.StartsWith('secondo|', Leggi(TzRegistroGrafici.Immagine('zTestGrafico', fgPng, 10, 10)));
end;

procedure TTestRegistroGrafici.Togli_TuttiINomiDelProprietario;
begin
  // nome di stampa e identificativo dello stesso grafico
  TzRegistroGrafici.Registra('zTestStampa', FPrimo, Sorgente('a'));
  TzRegistroGrafici.Registra('zTestModulo.DataSet', FPrimo, Sorgente('a'));

  TzRegistroGrafici.Togli(FPrimo);

  Assert.AreEqual(0, NomiDelTest);
end;

procedure TTestRegistroGrafici.Togli_LasciaGliAltriProprietari;
begin
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('primo'));
  TzRegistroGrafici.Registra('zTestGrafico', FSecondo, Sorgente('secondo'));

  TzRegistroGrafici.Togli(FSecondo);

  Assert.StartsWith('primo|', Leggi(TzRegistroGrafici.Immagine('zTestGrafico', fgPng, 10, 10)));
end;

procedure TTestRegistroGrafici.Immagine_MisuraZero_Predefinita;
begin
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('a'));

  Assert.AreEqual(Format('a|%d|%d|%d', [Ord(fgSvg), TzRegistroGrafici.LarghezzaPredefinita, TzRegistroGrafici.AltezzaPredefinita]),
    Leggi(TzRegistroGrafici.Immagine('zTestGrafico', fgSvg, 0, 0)));
end;

procedure TTestRegistroGrafici.Immagine_FlussoRiavvolto;
var
  Flusso: TStream;
begin
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('a'));

  Flusso := TzRegistroGrafici.Immagine('zTestGrafico', fgPng, 10, 10);
  try
    Assert.IsNotNull(Flusso);
    Assert.AreEqual(Int64(0), Flusso.Position);
  finally
    Flusso.Free;
  end;
end;

procedure TTestRegistroGrafici.Immagine_NomeSconosciuto_Nil;
begin
  Assert.IsNull(TzRegistroGrafici.Immagine('zTestNonRegistrato', fgPng, 10, 10));
end;

procedure TTestRegistroGrafici.ImmagineDaRiferimento_PassaFormatoEMisura;
begin
  TzRegistroGrafici.Registra('zTestModulo.zTestVendite', FPrimo, Sorgente('v'));

  Assert.AreEqual(Format('v|%d|%d|%d', [Ord(fgEmf), 320, 200]),
    Leggi(TzRegistroGrafici.ImmagineDaRiferimento('"chart://zTestVendite?emf&320x200" @8:5')));
end;

procedure TTestRegistroGrafici.ImmagineDaRiferimento_TestoQualsiasi_Nil;
begin
  TzRegistroGrafici.Registra('zTestGrafico', FPrimo, Sorgente('a'));
  Assert.IsNull(TzRegistroGrafici.ImmagineDaRiferimento('zTestGrafico'));
end;

{ TTestPixelDaCentimetri }

procedure TTestPixelDaCentimetri.UnPollice_PuntiPerPollice;
begin
  Assert.AreEqual(300, TzRegistroGrafici.PixelDaCentimetri(2.54));
  Assert.AreEqual(96, TzRegistroGrafici.PixelDaCentimetri(2.54, 96));
end;

procedure TTestPixelDaCentimetri.VentiCentimetri_TrecentoPunti;
begin
  // 20 / 2,54 * 300 = 2362,2
  Assert.AreEqual(2362, TzRegistroGrafici.PixelDaCentimetri(20));
end;

procedure TTestPixelDaCentimetri.Zero_AlmenoUnPixel;
begin
  Assert.AreEqual(1, TzRegistroGrafici.PixelDaCentimetri(0));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRiferimentoGrafico);
  TDUnitX.RegisterTestFixture(TTestRegistroGrafici);
  TDUnitX.RegisterTestFixture(TTestPixelDaCentimetri);

end.
