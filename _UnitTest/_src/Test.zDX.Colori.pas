// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDX.Colori;

// Test DUnitX per zBase\zDX.pas, parte su colori e skin (specifica ZBASE-CSK,
// "Colori e skin.md"). BOZZA scritta senza poterla compilare ne' eseguire.
//
// Tre gruppi di prove:
// - ColoreLeggibile, ColoreSuSkin, ColorePalette e SkinScura, funzioni di unit
//   che non creano il modulo Tdx: le prove danno sempre lo sfondo esplicito,
//   cosi' il risultato non dipende dal tema di Windows; l'unica eccezione e'
//   la prova dello sfondo predefinito (clDefault), che si confronta con lo
//   sfondo che il painter dichiara (ZBASE-CSK-013 e seguenti);
// - il modulo Tdx senza nessuna skin attiva: tabelle dei colori predefiniti,
//   stili, BlendColor, valori di ricaduta (ZBASE-CSK-001 e seguenti).
//
// Il modulo Tdx si crea con la funzione dx (creazione pigra, come nei
// programmi): il costruttore (zDX.pas, Tdx.Create) usa solo componenti non
// visivi (controller di stile, liste di immagini, correttore ortografico,
// gestore degli avvisi), legge il DFM dalle risorse del programma e non apre
// finestre ne' file: SkinFileName si legge solo in LoadSkin e GetSkinNames.
// Tdx.UpdateStyles usa la funzione dx e non Self, quindi non si puo' creare
// Tdx.Create a parte. La creazione sposta il RootLookAndFeel (flat, poi nativo
// con le prove su SkinName): le prove di unit non ne dipendono perche' danno lo
// sfondo.
//
// Le prove del modulo valgono solo se nessuna skin e' attiva: se il programma
// di prova ne ha una (SkinActive vero) o il file .skinres esiste accanto
// all'eseguibile, la prova si dichiara non applicabile, come in Test.zMsg.
//
// Restano senza prova:
// - tutti i rami con skin caricata (GetColor, GetFontColor, GetSkinColor,
//   GetBarColor, GetSkinPainter, GetSkinInfo, ColorePalette e SkinScura con una
//   skin DevExpress): servirebbe un file .skinres e dxSkinController.UseSkins
//   vero, cioe' cambiare il look and feel di tutto il programma di prova;
// - il caricamento di una skin vera (LoadSkin con file) e GetSkinNames con un
//   elenco: leggono il file .skinres accanto all'eseguibile (non esiste per il
//   programma di prova);
// - la propagazione dei colori agli stili personalizzati (UpdateCustomStyles e
//   UpdateStyles sono privati, e senza skin SetSkinPaletteName non li chiama);
// - InitSkinChooserGalleryItem, InitRibbonSkinSelector,
//   RibbonSkinSelectorApplySkin (componenti DevExpress da creare e mostrare);
// - GetColorPippo (corpo vuoto, codice morto: DIV-CSK-5);
// - registrazione di uno stile senza stile base (DIV-CSK-2): sporcherebbe il
//   modulo unico per le prove successive.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.UITypes,
  Winapi.Windows,
  Vcl.Graphics,
  cxStyles,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  DUnitX.TestFramework,
  zDX;

type
  [TestFixture]
  TTestzDXColoreLeggibile = class
  public
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_GiaLeggibile_NonCambia;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_GialloSuBianco_ScuritoFinoAlPrimoPassoLeggibile;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_BiancoSuBianco_GrigioDelSessantaPerCento;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_SuSfondoChiaro_SoloScurisce;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_SuSfondoScuro_SoloSchiarisce;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_SfondoGrigioMedio_VaVersoIlNero;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_QualunqueSfondo_ContrastoAlmenoQuattroVirgolaCinque;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_ColoreDiSistema_RestituisceIlValoreRgb;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_SecondaApplicazione_NonCambiaPiu;
    // ZBASE-CSK-014
    [Test]
    procedure ColoreLeggibile_SfondoPredefinito_UsaIlFondoDelContenutoDelPainter;
  end;

  [TestFixture]
  TTestzDXPalette = class
  public
    // ZBASE-CSK-013
    [Test]
    procedure ColorePalette_SenzaSkin_RestituisceIlPredefinito;
    // ZBASE-CSK-013
    [Test]
    procedure ColorePalette_SenzaSkin_NonConvertePredefinitoDiSistema;
    // ZBASE-CSK-015
    [Test]
    procedure ColoreSuSkin_SenzaSkin_UgualeAColoreLeggibileDelPredefinito;
    // ZBASE-CSK-016
    [Test]
    procedure SkinScura_CoerenteConIlFondoDelContenuto;
  end;

  [TestFixture]
  TTestzDXModuloSenzaSkin = class
  public
    // ZBASE-CSK-002
    [Test]
    procedure SkinAttiva_SenzaSkin_Falsa;
    // ZBASE-CSK-002
    [Test]
    procedure SkinPainterESkinInfo_SenzaSkin_Nulli;
    // ZBASE-CSK-005
    [Test]
    procedure RibbonColorSchemeName_SenzaSkin_White;
    // ZBASE-CSK-006
    [Test]
    procedure GetColorPerTipo_SenzaSkin_TabellaDeiColoriPredefiniti;
    // ZBASE-CSK-007
    [Test]
    procedure GetFontColorPerTipo_SenzaSkin_TabellaDeiColoriDelTesto;
    // ZBASE-CSK-008
    [Test]
    procedure GetColorPerStile_SenzaSkin_TabellaDeiColoriPredefiniti;
    // ZBASE-CSK-008
    [Test]
    procedure GetFontColorPerStile_SenzaSkin_TabellaDeiColoriDelTesto;
    // ZBASE-CSK-008 (fotografa DIV-CSK-4)
    [Test]
    procedure GetColorPerStile_StiliDiContenuto_NeroPerDifetto;
    // ZBASE-CSK-009
    [Test]
    procedure GetStyle_OgniStile_EsisteEDiversoDagliAltri;
    // ZBASE-CSK-009
    [Test]
    procedure GetStyle_StiliDeiColori_SeguonoColoreECarattere;
    // ZBASE-CSK-009
    [Test]
    procedure GetStyle_StiliDiGriglia_SeguonoIColoriDiGriglia;
    // ZBASE-CSK-010
    [Test]
    procedure RegisterCustomStyle_ValoriNonAssegnati_CopiatiDallaBase;
    // ZBASE-CSK-010
    [Test]
    procedure RegisterCustomStyle_ValoriAssegnati_RestanoQuelliDelloStile;
    // ZBASE-CSK-010
    [Test]
    procedure RegisterCustomStyle_Carattere_CopiatoSeNonAssegnato;
    // ZBASE-CSK-010
    [Test]
    procedure UnregisterCustomStyle_StileNonRegistrato_NonFaNiente;
    // ZBASE-CSK-011
    [Test]
    procedure BlendColor_Estremi_RestituisconoIDueColori;
    // ZBASE-CSK-011
    [Test]
    procedure BlendColor_PercentualeFuoriIntervallo_VieneLimitata;
    // ZBASE-CSK-011
    [Test]
    procedure BlendColor_VentiPerCento_MescolaCanalePerCanale;
    // ZBASE-CSK-011
    [Test]
    procedure BlendColor_ColoreDiSistema_ConvertitoInRgb;
    // ZBASE-CSK-012
    [Test]
    procedure GetSkinColor_SenzaSkin_RestituisceIlPredefinito;
    // ZBASE-CSK-012
    [Test]
    procedure GetBarColor_SenzaSkin_FinestraDiSistema;
    // ZBASE-CSK-003
    [Test]
    procedure SkinName_NomeSconosciuto_RicadeSulNativoESiRicorda;
    // ZBASE-CSK-003
    [Test]
    procedure GetSkinNames_ElencoNullo_NonFaNiente;
    // ZBASE-CSK-004
    [Test]
    procedure SkinPaletteName_SenzaSkin_SoloMemorizzata;
  end;

implementation

const
  ContrastoMinimoAtteso = 4.5;
  // tolleranza sul confronto fra numeri decimali
  Tolleranza = 0.0001;

  // sfondi e colori su cui si prova ColoreLeggibile (colori di sistema esclusi)
  SfondiDiProva: array [0 .. 8] of TColor = (clBlack, clWhite, clGray, clRed, clNavy, clYellow, TColor($00404040), TColor($00C0C0C0), clMoneyGreen);
  ColoriDiProva: array [0 .. 9] of TColor = (clBlack, clWhite, clGray, clRed, clYellow, clBlue, clLime, clSilver, clMaroon, TColor(10930928));

// Luminanza relativa delle WCAG 2.x, riscritta qui per non dipendere da
// LuminanzaRelativa di zDX (che non e' nell'interface)
function LuminanzaDiRiferimento(Colore: TColor): double;

  function Canale(Valore: integer): double;
  begin
    result := Valore / 255;

    if result <= 0.03928 then
      result := result / 12.92
    else
      result := Power((result + 0.055) / 1.055, 2.4);
  end;

var
  ColoreRgb: TColor;
begin
  ColoreRgb := ColorToRGB(Colore);
  result := 0.2126 * Canale(GetRValue(ColoreRgb)) + 0.7152 * Canale(GetGValue(ColoreRgb)) + 0.0722 * Canale(GetBValue(ColoreRgb));
end;

function ContrastoDiRiferimento(Colore1, Colore2: TColor): double;
var
  Luminanza1, Luminanza2: double;
begin
  Luminanza1 := LuminanzaDiRiferimento(Colore1);
  Luminanza2 := LuminanzaDiRiferimento(Colore2);

  if Luminanza1 < Luminanza2 then
    result := (Luminanza2 + 0.05) / (Luminanza1 + 0.05)
  else
    result := (Luminanza1 + 0.05) / (Luminanza2 + 0.05);
end;

function CanaleRosso(Colore: TColor): integer;
begin
  result := GetRValue(ColorToRGB(Colore));
end;

function CanaleVerde(Colore: TColor): integer;
begin
  result := GetGValue(ColorToRGB(Colore));
end;

function CanaleBlu(Colore: TColor): integer;
begin
  result := GetBValue(ColorToRGB(Colore));
end;

function ColoreRgbDaCanali(Rosso, Verde, Blu: integer): TColor;
begin
  result := TColor(RGB(Rosso, Verde, Blu));
end;

// Vero se il programma di prova ha una skin applicata al look and feel di
// base: ColorePalette e SkinScura dipenderebbero dalla skin
function SkinDiBasePresente: boolean;
begin
  result := Assigned(RootLookAndFeel.SkinPainter);
end;

// Vero se le prove sul modulo senza skin non si possono applicare
function ProveSenzaSkinNonApplicabili: boolean;
begin
  result := dx.SkinActive or FileExists(ChangeFileExt(ParamStr(0), '.skinres'));
end;

{ TTestzDXColoreLeggibile }

procedure TTestzDXColoreLeggibile.ColoreLeggibile_GiaLeggibile_NonCambia;
begin
  // nero su bianco: contrasto 21, nessuna correzione
  Assert.AreEqual(Integer(clBlack), Integer(ColoreLeggibile(clBlack, clWhite)), 'nero su bianco');
  // rosso scuro su bianco: contrasto oltre 10
  Assert.AreEqual(Integer(ColoreRgbDaCanali(128, 0, 0)), Integer(ColoreLeggibile(ColoreRgbDaCanali(128, 0, 0), clWhite)), 'rosso scuro su bianco');
  // bianco su nero
  Assert.AreEqual(Integer(clWhite), Integer(ColoreLeggibile(clWhite, clBlack)), 'bianco su nero');
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_GialloSuBianco_ScuritoFinoAlPrimoPassoLeggibile;
begin
  // il giallo su bianco ha contrasto circa 1,07: si scurisce verso il nero a
  // passi del 10%; al 50% il contrasto e' ancora sotto 4,5, al 60% e' circa 6
  Assert.AreEqual(Integer(ColoreRgbDaCanali(102, 102, 0)), Integer(ColoreLeggibile(clYellow, clWhite)));
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_BiancoSuBianco_GrigioDelSessantaPerCento;
begin
  // contrasto 1: verso il nero; al 50% il grigio ha contrasto circa 4 (sotto),
  // al 60% il grigio 102 ha contrasto circa 5,7
  Assert.AreEqual(Integer(ColoreRgbDaCanali(102, 102, 102)), Integer(ColoreLeggibile(clWhite, clWhite)));
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_SuSfondoChiaro_SoloScurisce;
var
  Risultato: TColor;
begin
  Risultato := ColoreLeggibile(clYellow, clWhite);

  Assert.IsTrue(CanaleRosso(Risultato) <= CanaleRosso(clYellow), 'rosso non aumenta');
  Assert.IsTrue(CanaleVerde(Risultato) <= CanaleVerde(clYellow), 'verde non aumenta');
  Assert.IsTrue(CanaleBlu(Risultato) <= CanaleBlu(clYellow), 'blu non aumenta');
  Assert.IsTrue(ContrastoDiRiferimento(Risultato, clWhite) >= ContrastoMinimoAtteso - Tolleranza, 'contrasto minimo');
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_SuSfondoScuro_SoloSchiarisce;
var
  Risultato: TColor;
begin
  // blu scuro su nero: contrasto circa 1,3
  Risultato := ColoreLeggibile(clNavy, clBlack);

  Assert.IsTrue(CanaleRosso(Risultato) >= CanaleRosso(clNavy), 'rosso non diminuisce');
  Assert.IsTrue(CanaleVerde(Risultato) >= CanaleVerde(clNavy), 'verde non diminuisce');
  Assert.IsTrue(CanaleBlu(Risultato) >= CanaleBlu(clNavy), 'blu non diminuisce');
  Assert.IsTrue(ContrastoDiRiferimento(Risultato, clBlack) >= ContrastoMinimoAtteso - Tolleranza, 'contrasto minimo');
  Assert.AreNotEqual(Integer(clNavy), Integer(Risultato), 'il colore e'' cambiato');
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_SfondoGrigioMedio_VaVersoIlNero;
var
  Risultato: TColor;
begin
  // su grigio 128 il nero (contrasto circa 5,3) si legge meglio del bianco
  // (circa 4): un grigio chiaro viene quindi scurito, non schiarito
  Risultato := ColoreLeggibile(clSilver, clGray);

  Assert.IsTrue(CanaleRosso(Risultato) < CanaleRosso(clSilver), 'scurito');
  Assert.IsTrue(ContrastoDiRiferimento(Risultato, clGray) >= ContrastoMinimoAtteso - Tolleranza, 'contrasto minimo');
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_QualunqueSfondo_ContrastoAlmenoQuattroVirgolaCinque;
var
  IndiceSfondo, IndiceColore: integer;
  Risultato: TColor;
begin
  // su nessuno sfondo nero e bianco falliscono insieme (il punto d'incrocio ha
  // contrasto circa 4,6): l'ultimo passo, al 100%, e' sempre leggibile
  for IndiceSfondo := Low(SfondiDiProva) to High(SfondiDiProva) do
    for IndiceColore := Low(ColoriDiProva) to High(ColoriDiProva) do
    begin
      Risultato := ColoreLeggibile(ColoriDiProva[IndiceColore], SfondiDiProva[IndiceSfondo]);

      Assert.IsTrue(ContrastoDiRiferimento(Risultato, SfondiDiProva[IndiceSfondo]) >= ContrastoMinimoAtteso - Tolleranza,
        Format('colore %d su sfondo %d', [Integer(ColoriDiProva[IndiceColore]), Integer(SfondiDiProva[IndiceSfondo])]));
    end;
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_ColoreDiSistema_RestituisceIlValoreRgb;
begin
  // anche quando non serve correggere, il risultato e' sempre un valore RGB:
  // un colore di sistema perde il legame con il tema di Windows
  Assert.AreEqual(Integer(ColorToRGB(clWindowText)), Integer(ColoreLeggibile(clWindowText, clWhite)));
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_SecondaApplicazione_NonCambiaPiu;
var
  IndiceSfondo, IndiceColore: integer;
  Primo: TColor;
begin
  for IndiceSfondo := Low(SfondiDiProva) to High(SfondiDiProva) do
    for IndiceColore := Low(ColoriDiProva) to High(ColoriDiProva) do
    begin
      Primo := ColoreLeggibile(ColoriDiProva[IndiceColore], SfondiDiProva[IndiceSfondo]);

      Assert.AreEqual(Integer(Primo), Integer(ColoreLeggibile(Primo, SfondiDiProva[IndiceSfondo])),
        Format('colore %d su sfondo %d', [Integer(ColoriDiProva[IndiceColore]), Integer(SfondiDiProva[IndiceSfondo])]));
    end;
end;

procedure TTestzDXColoreLeggibile.ColoreLeggibile_SfondoPredefinito_UsaIlFondoDelContenutoDelPainter;
var
  Sfondo: TColor;
begin
  // clDefault = fondo del contenuto del painter attivo (dipende dal tema)
  Sfondo := ColorToRGB(RootLookAndFeel.Painter.DefaultContentColor);

  Assert.AreEqual(Integer(ColoreLeggibile(clYellow, Sfondo)), Integer(ColoreLeggibile(clYellow, clDefault)), 'stesso risultato dello sfondo esplicito');
  Assert.IsTrue(ContrastoDiRiferimento(ColoreLeggibile(clYellow, clDefault), Sfondo) >= ContrastoMinimoAtteso - Tolleranza, 'contrasto minimo');
end;

{ TTestzDXPalette }

procedure TTestzDXPalette.ColorePalette_SenzaSkin_RestituisceIlPredefinito;
begin
  if SkinDiBasePresente then
  begin
    Assert.Pass('esiste una skin applicata al look and feel di base, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual(Integer(clFuchsia), Integer(ColorePalette('Red', clFuchsia)), 'nome che c''e'' in molte palette');
  Assert.AreEqual(Integer(clTeal), Integer(ColorePalette('NomeCheNonEsiste', clTeal)), 'nome inesistente');
  Assert.AreEqual(Integer(clTeal), Integer(ColorePalette('', clTeal)), 'nome vuoto');
end;

procedure TTestzDXPalette.ColorePalette_SenzaSkin_NonConvertePredefinitoDiSistema;
begin
  if SkinDiBasePresente then
  begin
    Assert.Pass('esiste una skin applicata al look and feel di base, prova non applicabile');
    Exit;
  end;

  // a differenza di ColoreLeggibile, ColorePalette non converte in RGB
  Assert.AreEqual(Integer(clBtnFace), Integer(ColorePalette('Red', clBtnFace)));
end;

procedure TTestzDXPalette.ColoreSuSkin_SenzaSkin_UgualeAColoreLeggibileDelPredefinito;
begin
  if SkinDiBasePresente then
  begin
    Assert.Pass('esiste una skin applicata al look and feel di base, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual(Integer(ColoreLeggibile(clYellow, clWhite)), Integer(ColoreSuSkin('Red', clYellow, clWhite)), 'giallo su bianco');
  Assert.AreEqual(Integer(ColoreLeggibile(clNavy, clBlack)), Integer(ColoreSuSkin('Blue', clNavy, clBlack)), 'blu scuro su nero');
end;

procedure TTestzDXPalette.SkinScura_CoerenteConIlFondoDelContenuto;
var
  Sfondo: TColor;
begin
  // scuro = il bianco ci si legge sopra meglio del nero
  Sfondo := ColorToRGB(RootLookAndFeel.Painter.DefaultContentColor);

  Assert.AreEqual<boolean>(ContrastoDiRiferimento(Sfondo, clWhite) > ContrastoDiRiferimento(Sfondo, clBlack), SkinScura);
end;

{ TTestzDXModuloSenzaSkin }

procedure TTestzDXModuloSenzaSkin.SkinAttiva_SenzaSkin_Falsa;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  // il DFM ha UseSkins = False e il costruttore non lo cambia
  Assert.IsFalse(dx.SkinActive);
  Assert.AreEqual('', dx.SkinName, 'nome della skin');
  Assert.AreEqual('', dx.SkinPaletteName, 'nome della tavolozza');
end;

procedure TTestzDXModuloSenzaSkin.SkinPainterESkinInfo_SenzaSkin_Nulli;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Assert.IsTrue(dx.GetSkinPainter = nil, 'GetSkinPainter');
  Assert.IsTrue(dx.GetSkinInfo = nil, 'GetSkinInfo');
end;

procedure TTestzDXModuloSenzaSkin.RibbonColorSchemeName_SenzaSkin_White;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual('White', dx.RibbonColorSchemeName);
end;

procedure TTestzDXModuloSenzaSkin.GetColorPerTipo_SenzaSkin_TabellaDeiColoriPredefiniti;

  procedure Verifica(Tipo: TColorKind; Atteso: TColor; const Nome: string);
  begin
    Assert.AreEqual(Integer(Atteso), Integer(dx.GetColor(Tipo)), Nome);
  end;

begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Verifica(ckControl, TColors.SysBtnFace, 'ckControl');
  Verifica(ckContent, TColors.SysInfoBk, 'ckContent');
  Verifica(ckTitle, TColors.SysInfoBk, 'ckTitle');
  Verifica(ckEditorNormal, TColors.MoneyGreen, 'ckEditorNormal');
  Verifica(ckEditorRequired, TColor(10930928), 'ckEditorRequired');
  Verifica(ckEditorReadOnly, TColors.SysInfoBk, 'ckEditorReadOnly');
  Verifica(ckEditorDisabled, TColors.SysBtnFace, 'ckEditorDisabled');
  Verifica(ckLabel, TColors.SysBtnFace, 'ckLabel');
  Verifica(ckSeparator, TColors.SysBtnShadow, 'ckSeparator');
  Verifica(ckWizard, TColors.SysBtnFace, 'ckWizard');
  Verifica(ckWizardTitle, TColors.SysWindow, 'ckWizardTitle');
  Verifica(ckWizardWaterMark, clActiveCaption, 'ckWizardWaterMark');
  Verifica(ckGridContent, TColors.MoneyGreen, 'ckGridContent');
  Verifica(ckGridContentEven, TColor($00DDECDD), 'ckGridContentEven');
  Verifica(ckGridContentOdd, TColors.MoneyGreen, 'ckGridContentOdd');
  Verifica(ckGridFooter, clBtnFace, 'ckGridFooter');
  Verifica(ckFilterBox, clBtnShadow, 'ckFilterBox');
  Verifica(ckTreeView, TColors.MoneyGreen, 'ckTreeView');
  Verifica(ckInspector, clBtnFace, 'ckInspector');
  Verifica(ckInspectorValues, clBtnFace, 'ckInspectorValues');
  Verifica(ckBtnFace, clBtnFace, 'ckBtnFace');
end;

procedure TTestzDXModuloSenzaSkin.GetFontColorPerTipo_SenzaSkin_TabellaDeiColoriDelTesto;

  procedure Verifica(Tipo: TColorKind; Atteso: TColor; const Nome: string);
  begin
    Assert.AreEqual(Integer(Atteso), Integer(dx.GetFontColor(Tipo)), Nome);
  end;

begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  // nero ovunque, tranne tre eccezioni
  Verifica(ckControl, TColors.Black, 'ckControl');
  Verifica(ckContent, TColors.Black, 'ckContent');
  Verifica(ckTitle, TColors.Black, 'ckTitle');
  Verifica(ckEditorNormal, TColors.Black, 'ckEditorNormal');
  Verifica(ckEditorRequired, TColors.Black, 'ckEditorRequired');
  Verifica(ckEditorReadOnly, TColors.Black, 'ckEditorReadOnly');
  Verifica(ckEditorDisabled, TColors.SysGrayText, 'ckEditorDisabled');
  Verifica(ckLabel, TColors.Black, 'ckLabel');
  Verifica(ckSeparator, TColors.SysBtnHighlight, 'ckSeparator');
  Verifica(ckWizard, TColors.Black, 'ckWizard');
  Verifica(ckWizardTitle, TColors.Black, 'ckWizardTitle');
  Verifica(ckWizardWaterMark, TColors.Black, 'ckWizardWaterMark');
  Verifica(ckGridContent, TColors.Black, 'ckGridContent');
  Verifica(ckGridContentEven, TColors.Black, 'ckGridContentEven');
  Verifica(ckGridContentOdd, TColors.Black, 'ckGridContentOdd');
  Verifica(ckGridFooter, TColors.Black, 'ckGridFooter');
  Verifica(ckFilterBox, TColors.Black, 'ckFilterBox');
  Verifica(ckTreeView, TColors.Black, 'ckTreeView');
  Verifica(ckInspector, TColors.Black, 'ckInspector');
  Verifica(ckInspectorValues, TColors.Navy, 'ckInspectorValues');
  Verifica(ckBtnFace, TColors.Black, 'ckBtnFace');
end;

procedure TTestzDXModuloSenzaSkin.GetColorPerStile_SenzaSkin_TabellaDeiColoriPredefiniti;

  procedure Verifica(Stile: TStyleColor; Atteso: TColor; const Nome: string);
  begin
    Assert.AreEqual(Integer(Atteso), Integer(dx.GetColor(Stile)), Nome);
  end;

begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Verifica(scBtnFace, clBtnFace, 'scBtnFace');
  Verifica(scMoneyGreen, TColors.MoneyGreen, 'scMoneyGreen');
  Verifica(scMoneyGreenLight, TColor($00E7F1E7), 'scMoneyGreenLight');
  Verifica(scCream, TColor(10930928), 'scCream');
  Verifica(scInfoBk, TColors.SysInfoBk, 'scInfoBk');
  Verifica(scSkyBlue, TColors.Skyblue, 'scSkyBlue');
  Verifica(scSkyBlueLight, TColor($00FAF1E4), 'scSkyBlueLight');
  Verifica(scHeader, clBtnFace, 'scHeader');
  Verifica(scHeaderBackground, clBtnShadow, 'scHeaderBackground');
  Verifica(scHighlight, clHighlight, 'scHighlight');
end;

procedure TTestzDXModuloSenzaSkin.GetFontColorPerStile_SenzaSkin_TabellaDeiColoriDelTesto;

  procedure Verifica(Stile: TStyleColor; Atteso: TColor; const Nome: string);
  begin
    Assert.AreEqual(Integer(Atteso), Integer(dx.GetFontColor(Stile)), Nome);
  end;

begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Verifica(scBtnFace, TColors.Black, 'scBtnFace');
  Verifica(scMoneyGreen, TColors.Black, 'scMoneyGreen');
  Verifica(scMoneyGreenLight, TColors.Black, 'scMoneyGreenLight');
  Verifica(scCream, TColors.Black, 'scCream');
  Verifica(scInfoBk, TColors.SysInfoText, 'scInfoBk');
  Verifica(scSkyBlue, TColors.Black, 'scSkyBlue');
  Verifica(scSkyBlueLight, TColors.Black, 'scSkyBlueLight');
  Verifica(scHeader, clBtnText, 'scHeader');
  Verifica(scHeaderBackground, clBtnFace, 'scHeaderBackground');
  Verifica(scHighlight, TColors.Black, 'scHighlight');
end;

procedure TTestzDXModuloSenzaSkin.GetColorPerStile_StiliDiContenuto_NeroPerDifetto;
var
  Stili: TArray<TStyleColor>;
  Stile: TStyleColor;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  // DIV-CSK-4: questi cinque valori esistono nell'enumerazione, GetStyle li
  // gestisce, ma GetColor e GetFontColor li lasciano al valore iniziale (nero).
  // Da capovolgere quando il codice viene corretto.
  Stili := [scControl, scContent, scContentOdd, scContentEven, scFooter];

  for Stile in Stili do
  begin
    Assert.AreEqual(Integer(TColors.Black), Integer(dx.GetColor(Stile)), 'GetColor');
    Assert.AreEqual(Integer(TColors.Black), Integer(dx.GetFontColor(Stile)), 'GetFontColor');
  end;
end;

procedure TTestzDXModuloSenzaSkin.GetStyle_OgniStile_EsisteEDiversoDagliAltri;
var
  Stili: TArray<TStyleColor>;
  Primo, Secondo: integer;
begin
  Stili := [scBtnFace, scMoneyGreen, scMoneyGreenLight, scCream, scInfoBk, scSkyBlue, scSkyBlueLight, scHeader, scHeaderBackground, scHighlight, scControl, scContent, scContentOdd, scContentEven,
    scFooter];

  for Primo := Low(Stili) to High(Stili) do
  begin
    Assert.IsTrue(dx.GetStyle(Stili[Primo]) <> nil, Format('stile %d assente', [Primo]));

    for Secondo := Primo + 1 to High(Stili) do
      Assert.IsTrue(dx.GetStyle(Stili[Primo]) <> dx.GetStyle(Stili[Secondo]), Format('stili %d e %d coincidono', [Primo, Secondo]));
  end;
end;

procedure TTestzDXModuloSenzaSkin.GetStyle_StiliDeiColori_SeguonoColoreECarattere;
var
  Stili: TArray<TStyleColor>;
  Stile: TStyleColor;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  // UpdateStyles, chiamato dalla funzione dx alla creazione, assegna a ognuno
  // dei dieci stili il colore e il colore del carattere dei due GetColor
  Stili := [scBtnFace, scMoneyGreen, scMoneyGreenLight, scCream, scInfoBk, scSkyBlue, scSkyBlueLight, scHeader, scHeaderBackground, scHighlight];

  for Stile in Stili do
  begin
    Assert.AreEqual(Integer(dx.GetColor(Stile)), Integer(dx.GetStyle(Stile).Color), Format('colore dello stile %d', [Ord(Stile)]));
    Assert.AreEqual(Integer(dx.GetFontColor(Stile)), Integer(dx.GetStyle(Stile).Font.Color), Format('carattere dello stile %d', [Ord(Stile)]));
  end;
end;

procedure TTestzDXModuloSenzaSkin.GetStyle_StiliDiGriglia_SeguonoIColoriDiGriglia;

  procedure Verifica(Stile: TStyleColor; Tipo: TColorKind; const Nome: string);
  begin
    Assert.AreEqual(Integer(dx.GetColor(Tipo)), Integer(dx.GetStyle(Stile).Color), Nome + ' colore');
    Assert.AreEqual(Integer(dx.GetFontColor(Tipo)), Integer(dx.GetStyle(Stile).Font.Color), Nome + ' carattere');
  end;

begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Verifica(scControl, ckControl, 'scControl');
  Verifica(scContent, ckGridContent, 'scContent');
  Verifica(scContentEven, ckGridContentEven, 'scContentEven');
  Verifica(scContentOdd, ckGridContentOdd, 'scContentOdd');
  Verifica(scFooter, ckGridFooter, 'scFooter');
end;

procedure TTestzDXModuloSenzaSkin.RegisterCustomStyle_ValoriNonAssegnati_CopiatiDallaBase;
var
  Base, Derivato: TcxStyle;
begin
  Base := TcxStyle.Create(nil);
  Derivato := TcxStyle.Create(nil);
  try
    Base.Color := clRed;
    Base.TextColor := clBlue;
    Derivato.Color := clGreen;
    Derivato.TextColor := clYellow;

    // come il calendario dei turni di WT: solo il colore del testo e' proprio
    dx.RegisterCustomStyle(Derivato, Base, [svTextColor]);
    try
      Assert.AreEqual(Integer(clRed), Integer(Derivato.Color), 'colore copiato dalla base');
      Assert.AreEqual(Integer(clYellow), Integer(Derivato.TextColor), 'colore del testo proprio');
    finally
      dx.UnregisterCustomStyle(Derivato);
    end;
  finally
    Derivato.Free;
    Base.Free;
  end;
end;

procedure TTestzDXModuloSenzaSkin.RegisterCustomStyle_ValoriAssegnati_RestanoQuelliDelloStile;
var
  Base, Derivato: TcxStyle;
begin
  Base := TcxStyle.Create(nil);
  Derivato := TcxStyle.Create(nil);
  try
    Base.Color := clRed;
    Base.TextColor := clBlue;
    Derivato.Color := clGreen;
    Derivato.TextColor := clYellow;

    dx.RegisterCustomStyle(Derivato, Base, [svColor]);
    try
      Assert.AreEqual(Integer(clGreen), Integer(Derivato.Color), 'colore proprio');
      Assert.AreEqual(Integer(clBlue), Integer(Derivato.TextColor), 'colore del testo copiato dalla base');
    finally
      dx.UnregisterCustomStyle(Derivato);
    end;
  finally
    Derivato.Free;
    Base.Free;
  end;
end;

procedure TTestzDXModuloSenzaSkin.RegisterCustomStyle_Carattere_CopiatoSeNonAssegnato;
var
  Base, Derivato: TcxStyle;
begin
  Base := TcxStyle.Create(nil);
  Derivato := TcxStyle.Create(nil);
  try
    Base.Font.Name := 'Courier New';
    Base.Font.Size := 14;
    Derivato.Font.Name := 'Arial';
    Derivato.Font.Size := 8;

    dx.RegisterCustomStyle(Derivato, Base, []);
    try
      Assert.AreEqual('Courier New', Derivato.Font.Name, 'nome del carattere');
      Assert.AreEqual(14, Derivato.Font.Size, 'dimensione del carattere');
    finally
      dx.UnregisterCustomStyle(Derivato);
    end;
  finally
    Derivato.Free;
    Base.Free;
  end;
end;

procedure TTestzDXModuloSenzaSkin.UnregisterCustomStyle_StileNonRegistrato_NonFaNiente;
var
  Estraneo: TcxStyle;
begin
  Estraneo := TcxStyle.Create(nil);
  try
    dx.UnregisterCustomStyle(Estraneo);
    dx.UnregisterCustomStyle(nil);
    Assert.Pass;
  finally
    Estraneo.Free;
  end;
end;

procedure TTestzDXModuloSenzaSkin.BlendColor_Estremi_RestituisconoIDueColori;
begin
  Assert.AreEqual(Integer(clBlack), Integer(dx.BlendColor(clBlack, clWhite, 0)), '0%');
  Assert.AreEqual(Integer(clWhite), Integer(dx.BlendColor(clBlack, clWhite, 100)), '100%');
  Assert.AreEqual(Integer(clRed), Integer(dx.BlendColor(clRed, clBlue, 0)), '0% rosso');
  Assert.AreEqual(Integer(clBlue), Integer(dx.BlendColor(clRed, clBlue, 100)), '100% blu');
end;

procedure TTestzDXModuloSenzaSkin.BlendColor_PercentualeFuoriIntervallo_VieneLimitata;
begin
  Assert.AreEqual(Integer(clBlack), Integer(dx.BlendColor(clBlack, clWhite, -5)), 'sotto zero');
  Assert.AreEqual(Integer(clWhite), Integer(dx.BlendColor(clBlack, clWhite, 150)), 'sopra cento');
end;

procedure TTestzDXModuloSenzaSkin.BlendColor_VentiPerCento_MescolaCanalePerCanale;
begin
  // 255 * 20 / 100 = 51 esatti, senza arrotondamenti
  Assert.AreEqual(Integer(ColoreRgbDaCanali(51, 51, 51)), Integer(dx.BlendColor(clBlack, clWhite, 20)), 'dal nero verso il bianco');
  Assert.AreEqual(Integer(ColoreRgbDaCanali(204, 204, 204)), Integer(dx.BlendColor(clWhite, clBlack, 20)), 'dal bianco verso il nero');
  // un canale alla volta: rosso (255,0,0) verso blu (0,0,255)
  Assert.AreEqual(Integer(ColoreRgbDaCanali(204, 0, 51)), Integer(dx.BlendColor(clRed, clBlue, 20)), 'rosso verso blu');
end;

procedure TTestzDXModuloSenzaSkin.BlendColor_ColoreDiSistema_ConvertitoInRgb;
begin
  // a 0% il risultato e' il primo colore gia' convertito in RGB
  Assert.AreEqual(Integer(ColorToRGB(clBtnFace)), Integer(dx.BlendColor(clBtnFace, clWhite, 0)));
end;

procedure TTestzDXModuloSenzaSkin.GetSkinColor_SenzaSkin_RestituisceIlPredefinito;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual(Integer(clFuchsia), Integer(dx.GetSkinColor('ContentColor', clFuchsia)));
end;

procedure TTestzDXModuloSenzaSkin.GetBarColor_SenzaSkin_FinestraDiSistema;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual(Integer(clWindow), Integer(dx.GetBarColor));
end;

procedure TTestzDXModuloSenzaSkin.SkinName_NomeSconosciuto_RicadeSulNativoESiRicorda;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  // senza file .skinres e senza uno stile predefinito con quel nome, LoadSkin
  // ricade sullo stile nativo: nessuna skin applicata, ma il nome resta quello
  // chiesto (DIV-CSK-6)
  dx.SkinName := 'NomeSkinInesistente';
  try
    Assert.AreEqual('NomeSkinInesistente', dx.SkinName, 'nome ricordato');
    Assert.IsFalse(dx.SkinActive, 'nessuna skin applicata');
    Assert.AreEqual(Integer(TColors.MoneyGreen), Integer(dx.GetColor(ckEditorNormal)), 'i colori restano quelli predefiniti');
  finally
    dx.SkinName := '';
  end;
end;

procedure TTestzDXModuloSenzaSkin.GetSkinNames_ElencoNullo_NonFaNiente;
begin
  dx.GetSkinNames(nil);
  Assert.Pass;
end;

procedure TTestzDXModuloSenzaSkin.SkinPaletteName_SenzaSkin_SoloMemorizzata;
begin
  if ProveSenzaSkinNonApplicabili then
  begin
    Assert.Pass('skin attiva o file .skinres presente, prova non applicabile');
    Exit;
  end;

  dx.SkinPaletteName := 'Red';
  try
    Assert.AreEqual('Red', dx.SkinPaletteName, 'nome ricordato');
    Assert.AreEqual(Integer(TColors.MoneyGreen), Integer(dx.GetColor(ckEditorNormal)), 'i colori non cambiano senza skin');
  finally
    dx.SkinPaletteName := '';
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzDXColoreLeggibile);
  TDUnitX.RegisterTestFixture(TTestzDXPalette);
  TDUnitX.RegisterTestFixture(TTestzDXModuloSenzaSkin);

end.
