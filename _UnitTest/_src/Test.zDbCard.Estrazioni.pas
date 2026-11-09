unit Test.zDbCard.Estrazioni;

// Test DUnitX per la logica estratta dalla card con questo refactoring:
// - MakeUniqueName ed EstraiCaptionDaIdDataSet, ora esposte da zDbCard;
// - TzDialogWidthModel (zDbCard.Layout), il calcolo puro della larghezza
//   suggerita del dialogo.
// zDbCard viene linkata solo a compile-time: nessuna card viene istanziata.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  zDbCard,
  zDbCard.Layout;

type
  [TestFixture]
  TTestMakeUniqueName = class
  public
    [Test]
    procedure NessunaCollisione_NomeNudo;
    [Test]
    procedure Collisione_AggiungeSuffissoNumerico;
    [Test]
    procedure StartIndexUno_ParteDalSuffisso;
    [Test]
    procedure CollisioniMultiple_IncrementaFinoAlLibero;
    [Test]
    procedure StartIndexNegativo_ParteDalNomeNudo;
    [Test]
    procedure StartIndexDue_ParteDaSuffissoDue;
  end;

  [TestFixture]
  TTestEstraiCaption = class
  public
    [Test]
    procedure PascalCase_SpaziatoSulleMaiuscole;
    [Test]
    procedure PrefissoConPunto_Rimosso;
    [Test]
    procedure MaiuscoleConsecutive_NonSeparate;
    [Test]
    procedure TuttoMinuscolo_Invariato;
    [Test]
    procedure StringaVuota_RestaVuota;
    [Test]
    procedure Cifra_SeguitaDaMaiuscola_Spaziata;
    // DIV-CTL-3: si tiene solo l'ultimo segmento dopo il punto
    [Test]
    procedure DuePrefissiConPunto_ResidioNellaCaption;
    [Test]
    procedure MaiuscolaAccentata_Riconosciuta;
  end;

  [TestFixture]
  TTestDialogWidthModel = class
  public
    [Test]
    procedure MaxRowSum_ListaVuota_Zero;
    [Test]
    procedure MaxRowSum_RigaUnica_Somma;
    [Test]
    procedure MaxRowSum_PiuRighe_VinceLaPiuLarga;
    [Test]
    procedure MaxRowSum_BreakFinale_NonAzzeraIlMassimo;
    [Test]
    procedure SuggestedWidth_CalcoloBase;
    [Test]
    procedure SuggestedWidth_SommaZero_UsaFallback;
    [Test]
    procedure SuggestedWidth_ClampMinimo;
    [Test]
    procedure SuggestedWidth_ClampMassimo;
    [Test]
    procedure SuggestedWidth_ArrotondaADieci;
  end;

implementation

{ TTestMakeUniqueName }

procedure TTestMakeUniqueName.NessunaCollisione_NomeNudo;
begin
  Assert.AreEqual('pannello',
    MakeUniqueName('pannello', 0,
    function(Nome: string): boolean
    begin
      result := false;
    end));
end;

procedure TTestMakeUniqueName.Collisione_AggiungeSuffissoNumerico;
begin
  Assert.AreEqual('pannello_1',
    MakeUniqueName('pannello', 0,
    function(Nome: string): boolean
    begin
      result := SameText(Nome, 'pannello');
    end));
end;

procedure TTestMakeUniqueName.StartIndexUno_ParteDalSuffisso;
begin
  Assert.AreEqual('pannello_1',
    MakeUniqueName('pannello', 1,
    function(Nome: string): boolean
    begin
      result := false;
    end));
end;

procedure TTestMakeUniqueName.CollisioniMultiple_IncrementaFinoAlLibero;
begin
  Assert.AreEqual('pannello_3',
    MakeUniqueName('pannello', 0,
    function(Nome: string): boolean
    begin
      result := SameText(Nome, 'pannello') or SameText(Nome, 'pannello_1') or SameText(Nome, 'pannello_2');
    end));
end;

procedure TTestMakeUniqueName.StartIndexNegativo_ParteDalNomeNudo;
begin
  Assert.AreEqual('pannello',
    MakeUniqueName('pannello', -3,
    function(Nome: string): boolean
    begin
      result := false;
    end));
end;

procedure TTestMakeUniqueName.StartIndexDue_ParteDaSuffissoDue;
begin
  Assert.AreEqual('pannello_3',
    MakeUniqueName('pannello', 2,
    function(Nome: string): boolean
    begin
      result := SameText(Nome, 'pannello_2');
    end));
end;

{ TTestEstraiCaption }

procedure TTestEstraiCaption.Cifra_SeguitaDaMaiuscola_Spaziata;
begin
  Assert.AreEqual('Fase2 Corso', EstraiCaptionDaIdDataSet('Fase2Corso'));
end;

procedure TTestEstraiCaption.DuePrefissiConPunto_ResidioNellaCaption;
begin
  // DIV-CTL-3 corretta: si tiene solo l'ultimo segmento
  Assert.AreEqual('Altro', EstraiCaptionDaIdDataSet('Anagrafica.Soggetti.Altro'));
end;

procedure TTestEstraiCaption.MaiuscolaAccentata_Riconosciuta;
begin
  Assert.AreEqual('Pagamento Èmesso', EstraiCaptionDaIdDataSet('PagamentoÈmesso'));
end;

procedure TTestEstraiCaption.PascalCase_SpaziatoSulleMaiuscole;
begin
  Assert.AreEqual('Soggetti Fisici', EstraiCaptionDaIdDataSet('SoggettiFisici'));
end;

procedure TTestEstraiCaption.PrefissoConPunto_Rimosso;
begin
  Assert.AreEqual('Soggetti Fisici', EstraiCaptionDaIdDataSet('Anagrafica.SoggettiFisici'));
end;

procedure TTestEstraiCaption.MaiuscoleConsecutive_NonSeparate;
begin
  // Comportamento attuale fotografato: lo spazio scatta solo quando la
  // maiuscola segue una NON maiuscola, quindi una sigla resta attaccata
  // anche alla parola successiva ('IVADocumenti' non diventa 'IVA Documenti')
  Assert.AreEqual('IVADocumenti', EstraiCaptionDaIdDataSet('IVADocumenti'));
end;

procedure TTestEstraiCaption.TuttoMinuscolo_Invariato;
begin
  Assert.AreEqual('documenti', EstraiCaptionDaIdDataSet('documenti'));
end;

procedure TTestEstraiCaption.StringaVuota_RestaVuota;
begin
  Assert.AreEqual('', EstraiCaptionDaIdDataSet(''));
end;

{ TTestDialogWidthModel }

procedure TTestDialogWidthModel.MaxRowSum_ListaVuota_Zero;
begin
  Assert.AreEqual(0, TzDialogWidthModel.MaxRowSum(nil));
end;

procedure TTestDialogWidthModel.MaxRowSum_RigaUnica_Somma;
begin
  Assert.AreEqual(30, TzDialogWidthModel.MaxRowSum([10, 20]));
end;

procedure TTestDialogWidthModel.MaxRowSum_PiuRighe_VinceLaPiuLarga;
begin
  Assert.AreEqual(25, TzDialogWidthModel.MaxRowSum(
    [10, TzDialogWidthModel.ROW_BREAK, 20, 5]));
end;

procedure TTestDialogWidthModel.MaxRowSum_BreakFinale_NonAzzeraIlMassimo;
begin
  Assert.AreEqual(10, TzDialogWidthModel.MaxRowSum(
    [10, TzDialogWidthModel.ROW_BREAK]));
end;

procedure TTestDialogWidthModel.SuggestedWidth_CalcoloBase;
begin
  // 100 caratteri * 7 px + H_MARGIN(20) + VSCROLLBAR_WIDTH(20) = 740
  Assert.AreEqual(740, TzDialogWidthModel.SuggestedWidth(100, 7, 400, 1000));
end;

procedure TTestDialogWidthModel.SuggestedWidth_SommaZero_UsaFallback;
begin
  // 0 -> FALLBACK_ROW_SIZE(130) * 7 + 40 = 950
  Assert.AreEqual(950, TzDialogWidthModel.SuggestedWidth(0, 7, 400, 1200));
end;

procedure TTestDialogWidthModel.SuggestedWidth_ClampMinimo;
begin
  // 10 * 7 + 40 = 110 -> clamp al minimo 400
  Assert.AreEqual(400, TzDialogWidthModel.SuggestedWidth(10, 7, 400, 1000));
end;

procedure TTestDialogWidthModel.SuggestedWidth_ClampMassimo;
begin
  // 500 * 7 + 40 = 3540 -> clamp al massimo disponibile 800
  Assert.AreEqual(800, TzDialogWidthModel.SuggestedWidth(500, 7, 400, 800));
end;

procedure TTestDialogWidthModel.SuggestedWidth_ArrotondaADieci;
begin
  // 33 * 7 + 40 = 271 -> troncato al multiplo di 10 inferiore = 270
  Assert.AreEqual(270, TzDialogWidthModel.SuggestedWidth(33, 7, 100, 1000));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMakeUniqueName);
  TDUnitX.RegisterTestFixture(TTestEstraiCaption);
  TDUnitX.RegisterTestFixture(TTestDialogWidthModel);

end.
