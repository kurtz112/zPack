unit Test.zDbCard.Layout;

// Test DUnitX per la logica pura di zDbCard.Layout: TzRowModel (metriche di
// riga, wrap, snap a griglia) e TzCardLayoutNames (naming/estrazione item).
// Nessuna form DevExpress e nessuna connessione Firebird: TzRowModel viene
// costruito con AFont = nil, quindi valgono i fallback FONT_WIDTH (7 px) e
// DEFAULT_LINE_HEIGHT (18 px) e tutti gli attesi sono calcolabili a mano.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  zDbCard.Layout;

type
  [TestFixture]
  TTestRowModel = class
  private
    // Modello di riferimento: DlgWidth 800 -> RowMaxPx = 800-20-20 = 760,
    // RowMaxSize = 760 div 7 = 108 (CharWidth fallback = 7).
    FModel: TzRowModel;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // --- costruttori ---
    [Test]
    procedure Create_ConFontNil_UsaFallbackFontWidth;
    [Test]
    procedure Create_ConLarghezza_CalcolaCapacita;
    [Test]
    procedure Create_ConLarghezzaZero_UsaFallbackRowSize;
    [Test]
    procedure CreateFromAreaWidth_NonSottraeMargini;

    // --- EffectiveSize / EffectiveSlot ---
    [Test]
    procedure EffectiveSize_Esplicito_Rispettato;
    [Test]
    procedure EffectiveSize_ZeroSenzaDominio_UsaDefault;
    [Test]
    procedure EffectiveSize_OltreCapacita_Clampato;
    [Test]
    procedure EffectiveSlot_SommaCaptionPiuUno;
    [Test]
    procedure EffectiveSlot_CaptionVuota_NonAggiunge;
    [Test]
    procedure EffectiveSlot_Clampato_A_RowMaxSize;

    // --- Overflows ---
    [Test]
    procedure Overflows_AlLimiteEsatto_NonSfora;
    [Test]
    procedure Overflows_OltreIlLimite_Sfora;

    // --- MinSlotPx: invariante anti-scrollbar ---
    [Test]
    procedure MinSlotPx_CaptionASinistra_IncludeCaption;
    [Test]
    procedure MinSlotPx_MaiSopraLaDimensioneNaturale;
    [Test]
    procedure MinSlotPx_CaptionSopra_SoloMinEditChars;

    // --- SnapSlot (caratteri) ---
    [Test]
    procedure SnapSlot_ArrotondaAlMultiploSuperiore;
    [Test]
    procedure SnapSlot_GiaMultiplo_Invariato;
    [Test]
    procedure SnapSlot_ClampaAllaCapacita;
    [Test]
    procedure SnapSlot_SenzaGriglia_Neutro;
  end;

  [TestFixture]
  TTestCardLayoutNames = class
  public
    // --- costruzione ---
    [Test]
    procedure FieldItem_FormatoAtteso;
    [Test]
    procedure GroupRow_FormatoAtteso;
    [Test]
    procedure Filler_FormatoAtteso;

    // --- round-trip build -> extract ---
    [Test]
    procedure ExtractFieldName_RoundTrip_FieldItem;
    [Test]
    procedure ExtractFieldName_RoundTrip_Group;
    [Test]
    procedure ExtractFieldName_CampoConUnderscore;
    [Test]
    procedure ExtractFieldName_CardConUnderscore;
    [Test]
    procedure ExtractFieldName_RigaEFiller_Vuoto;
    [Test]
    procedure ExtractFieldName_CardSbagliata_Vuoto;
    [Test]
    procedure ExtractGroupName_RoundTrip;
    [Test]
    procedure ExtractGroupName_GruppoConUnderscore;
    [Test]
    procedure ExtractGroupName_RigaRoot_Vuoto;
    // --- requisiti ZDBCARD-LAY-005 e 006 ---
    [Test]
    procedure Row_Separator_GroupFiller_FormatoAtteso;
    [Test]
    procedure Group_FormatoAtteso;
    [Test]
    procedure ExtractFieldName_Gruppo_RoundTrip;
    [Test]
    procedure ExtractFieldName_RigheEFillerDiGruppo_Vuoto;
    [Test]
    procedure ExtractGroupName_FillerDiGruppo_Vuoto;
  end;

  // Requisiti ZDBCARD-LAY-003 e 004 e divergenze fotografate di
  // zBase\_Specifiche\Layout della card.md
  [TestFixture]
  TTestLayoutCardAggiuntivi = class
  public
    [Test]
    procedure GridColumnEdge_PrimaColonna_Zero;
    [Test]
    procedure GridColumnEdge_ColonneIntermedie_SommanoIGutter;
    [Test]
    procedure GridColumnEdge_DopoLUltimaColonna_CapacitaPiuGutter;
    [Test]
    procedure GridColumnEdge_SenzaGriglia_Zero;
    [Test]
    procedure GridColumnEdge_CapacitaMinuscola_UnPixelPerColonna;
    [Test]
    procedure MinSlotPx_SlotVuoto_UnCarattere;
    [Test]
    procedure SuggestedWidth_MassimoSottoIlMinimo_VinceIlMassimo;
    // DIV-LAY-1: fotografia del comportamento attuale
    [Test]
    procedure Create_LarghezzaStretta_RowMaxSizeSuperaLaCapacitaInPixel;
  end;

implementation

const
  DLG_WIDTH = 800;
  ROW_MAX_PX = 760; // 800 - H_MARGIN(20) - VSCROLLBAR_WIDTH(20)
  ROW_MAX_SIZE = 108; // 760 div FONT_WIDTH(7)

{ TTestRowModel }

procedure TTestRowModel.Setup;
begin
  FModel := TzRowModel.Create(DLG_WIDTH, nil);
end;

procedure TTestRowModel.TearDown;
begin
  FModel.Free;
end;

procedure TTestRowModel.Create_ConFontNil_UsaFallbackFontWidth;
begin
  Assert.AreEqual(TzRowModel.FONT_WIDTH, FModel.CharWidth);
  Assert.AreEqual(TzRowModel.DEFAULT_LINE_HEIGHT, FModel.LineHeight);
end;

procedure TTestRowModel.Create_ConLarghezza_CalcolaCapacita;
begin
  Assert.AreEqual(ROW_MAX_PX, FModel.RowMaxPx);
  Assert.AreEqual(ROW_MAX_SIZE, FModel.RowMaxSize);
end;

procedure TTestRowModel.Create_ConLarghezzaZero_UsaFallbackRowSize;
var
  Modello: TzRowModel;
begin
  Modello := TzRowModel.Create(0, nil);
  try
    Assert.AreEqual(TzRowModel.FALLBACK_ROW_SIZE, Modello.RowMaxSize);
    Assert.AreEqual(TzRowModel.FALLBACK_ROW_SIZE * TzRowModel.FONT_WIDTH, Modello.RowMaxPx);
  finally
    Modello.Free;
  end;
end;

procedure TTestRowModel.CreateFromAreaWidth_NonSottraeMargini;
var
  Modello: TzRowModel;
begin
  // A differenza di Create, l'area passata e' gia' al netto dei margini
  Modello := TzRowModel.CreateFromAreaWidth(700, nil);
  try
    Assert.AreEqual(700, Modello.RowMaxPx);
    Assert.AreEqual(100, Modello.RowMaxSize); // 700 div 7
  finally
    Modello.Free;
  end;
end;

procedure TTestRowModel.EffectiveSize_Esplicito_Rispettato;
begin
  Assert.AreEqual(50, FModel.EffectiveSize(50, nil));
end;

procedure TTestRowModel.EffectiveSize_ZeroSenzaDominio_UsaDefault;
begin
  Assert.AreEqual(TzRowModel.DEFAULT_SIZE, FModel.EffectiveSize(0, nil));
  Assert.AreEqual(TzRowModel.DEFAULT_SIZE, FModel.EffectiveSize(-5, nil));
end;

procedure TTestRowModel.EffectiveSize_OltreCapacita_Clampato;
begin
  Assert.AreEqual(ROW_MAX_SIZE, FModel.EffectiveSize(999, nil));
end;

procedure TTestRowModel.EffectiveSlot_SommaCaptionPiuUno;
begin
  // Size 20 + caption 10 + separatore 1 = 31
  Assert.AreEqual(31, FModel.EffectiveSlot(20, nil, 10));
end;

procedure TTestRowModel.EffectiveSlot_CaptionVuota_NonAggiunge;
begin
  Assert.AreEqual(20, FModel.EffectiveSlot(20, nil, 0));
end;

procedure TTestRowModel.EffectiveSlot_Clampato_A_RowMaxSize;
begin
  Assert.AreEqual(ROW_MAX_SIZE, FModel.EffectiveSlot(100, nil, 20));
end;

procedure TTestRowModel.Overflows_AlLimiteEsatto_NonSfora;
begin
  Assert.IsFalse(FModel.Overflows(ROW_MAX_SIZE - 8, 8));
end;

procedure TTestRowModel.Overflows_OltreIlLimite_Sfora;
begin
  Assert.IsTrue(FModel.Overflows(ROW_MAX_SIZE - 8, 9));
end;

procedure TTestRowModel.MinSlotPx_CaptionASinistra_IncludeCaption;
begin
  // floor = CaptionLen(8) + MIN_EDIT_CHARS(4) = 12 caratteri -> 84 px
  Assert.AreEqual(84, FModel.MinSlotPx(20, 8, True));
end;

procedure TTestRowModel.MinSlotPx_MaiSopraLaDimensioneNaturale;
begin
  // Invariante anti-scrollbar: il minimo non supera SlotChars * CharWidth,
  // cosi' la somma dei minimi di riga resta <= larghezza client.
  Assert.AreEqual(10 * TzRowModel.FONT_WIDTH, FModel.MinSlotPx(10, 8, True));
end;

procedure TTestRowModel.MinSlotPx_CaptionSopra_SoloMinEditChars;
begin
  Assert.AreEqual(TzRowModel.MIN_EDIT_CHARS * TzRowModel.FONT_WIDTH,
    FModel.MinSlotPx(20, 8, False));
end;

procedure TTestRowModel.SnapSlot_ArrotondaAlMultiploSuperiore;
begin
  // colUnit = 100 div 10 = 10 -> 13 sale a 20
  Assert.AreEqual(20, FModel.SnapSlot(13, 100, 10));
end;

procedure TTestRowModel.SnapSlot_GiaMultiplo_Invariato;
begin
  Assert.AreEqual(10, FModel.SnapSlot(10, 100, 10));
end;

procedure TTestRowModel.SnapSlot_ClampaAllaCapacita;
begin
  Assert.AreEqual(100, FModel.SnapSlot(95, 100, 10));
end;

procedure TTestRowModel.SnapSlot_SenzaGriglia_Neutro;
begin
  Assert.AreEqual(13, FModel.SnapSlot(13, 100, 1));
  Assert.AreEqual(13, FModel.SnapSlot(13, 0, 10));
end;

{ TTestCardLayoutNames }

procedure TTestCardLayoutNames.FieldItem_FormatoAtteso;
begin
  Assert.AreEqual('li_NOME_Card1', TzCardLayoutNames.FieldItem('Card1', 'NOME'));
end;

procedure TTestCardLayoutNames.GroupRow_FormatoAtteso;
begin
  Assert.AreEqual('grprow_2_grpAzienda_Card1',
    TzCardLayoutNames.GroupRow('Card1', 'grpAzienda', 2));
end;

procedure TTestCardLayoutNames.Filler_FormatoAtteso;
begin
  Assert.AreEqual('fill_1_8_Card1', TzCardLayoutNames.Filler('Card1', 1, 8));
end;

procedure TTestCardLayoutNames.ExtractFieldName_RoundTrip_FieldItem;
begin
  Assert.AreEqual('NOME',
    TzCardLayoutNames.ExtractFieldName('Card1', TzCardLayoutNames.FieldItem('Card1', 'NOME')));
end;

procedure TTestCardLayoutNames.ExtractFieldName_RoundTrip_Group;
begin
  Assert.AreEqual('NOTE',
    TzCardLayoutNames.ExtractFieldName('Card1', TzCardLayoutNames.Group('Card1', 'NOTE')));
end;

procedure TTestCardLayoutNames.ExtractFieldName_CampoConUnderscore;
begin
  // I nomi campo Firebird contengono spesso underscore: il round-trip
  // deve restituirli intatti (il parsing e' a prefisso/suffisso).
  Assert.AreEqual('DATA_NASCITA',
    TzCardLayoutNames.ExtractFieldName('Card1',
    TzCardLayoutNames.FieldItem('Card1', 'DATA_NASCITA')));
end;

procedure TTestCardLayoutNames.ExtractFieldName_CardConUnderscore;
begin
  Assert.AreEqual('NOME',
    TzCardLayoutNames.ExtractFieldName('frm_Card',
    TzCardLayoutNames.FieldItem('frm_Card', 'NOME')));
end;

procedure TTestCardLayoutNames.ExtractFieldName_RigaEFiller_Vuoto;
begin
  Assert.AreEqual('', TzCardLayoutNames.ExtractFieldName('Card1', 'row_1_Card1'));
  Assert.AreEqual('', TzCardLayoutNames.ExtractFieldName('Card1', 'fill_1_8_Card1'));
  Assert.AreEqual('', TzCardLayoutNames.ExtractFieldName('Card1', 'sep_1_Card1'));
end;

procedure TTestCardLayoutNames.ExtractFieldName_CardSbagliata_Vuoto;
begin
  Assert.AreEqual('', TzCardLayoutNames.ExtractFieldName('AltraCard', 'li_NOME_Card1'));
end;

procedure TTestCardLayoutNames.ExtractGroupName_RoundTrip;
begin
  Assert.AreEqual('grpAzienda',
    TzCardLayoutNames.ExtractGroupNameFromRowName('Card1',
    TzCardLayoutNames.GroupRow('Card1', 'grpAzienda', 2)));
end;

procedure TTestCardLayoutNames.ExtractGroupName_GruppoConUnderscore;
begin
  // Caso fragile documentato: il parsing usa il primo '_' dopo l'indice,
  // quindi un nome gruppo con underscore deve comunque tornare intero.
  Assert.AreEqual('grp_Dati_Anagrafici',
    TzCardLayoutNames.ExtractGroupNameFromRowName('Card1',
    TzCardLayoutNames.GroupRow('Card1', 'grp_Dati_Anagrafici', 1)));
end;

procedure TTestCardLayoutNames.ExtractGroupName_RigaRoot_Vuoto;
begin
  Assert.AreEqual('',
    TzCardLayoutNames.ExtractGroupNameFromRowName('Card1', 'row_1_Card1'));
end;

procedure TTestCardLayoutNames.Row_Separator_GroupFiller_FormatoAtteso;
begin
  Assert.AreEqual('row_3_Card1', TzCardLayoutNames.Row('Card1', 3));
  Assert.AreEqual('sep_2_Card1', TzCardLayoutNames.Separator('Card1', 2));
  Assert.AreEqual('grpfill_1_8_grpA_Card1', TzCardLayoutNames.GroupFiller('Card1', 'grpA', 1, 8));
end;

procedure TTestCardLayoutNames.Group_FormatoAtteso;
begin
  Assert.AreEqual('grp_NOTE_Card1', TzCardLayoutNames.Group('Card1', 'NOTE'));
end;

procedure TTestCardLayoutNames.ExtractFieldName_Gruppo_RoundTrip;
begin
  Assert.AreEqual('NOTE', TzCardLayoutNames.ExtractFieldName('Card1', 'grp_NOTE_Card1'));
end;

procedure TTestCardLayoutNames.ExtractFieldName_RigheEFillerDiGruppo_Vuoto;
begin
  // iniziano per 'grp' ma non per 'grp_': non sono campi
  Assert.AreEqual('', TzCardLayoutNames.ExtractFieldName('Card1', 'grprow_1_grpA_Card1'));
  Assert.AreEqual('', TzCardLayoutNames.ExtractFieldName('Card1', 'grpfill_1_8_grpA_Card1'));
end;

procedure TTestCardLayoutNames.ExtractGroupName_FillerDiGruppo_Vuoto;
begin
  Assert.AreEqual('', TzCardLayoutNames.ExtractGroupNameFromRowName('Card1', 'grpfill_1_8_grpA_Card1'));
end;

{ TTestLayoutCardAggiuntivi }

procedure TTestLayoutCardAggiuntivi.GridColumnEdge_PrimaColonna_Zero;
begin
  Assert.AreEqual(0, TzLayoutMetrics.GridColumnEdge(1000, 0, 4, 7));
end;

procedure TTestLayoutCardAggiuntivi.GridColumnEdge_ColonneIntermedie_SommanoIGutter;
begin
  // spazio netto = 1000 - 3 * 7 = 979; colonna 1 = 979 div 4 + 7, colonna 2 = 979 * 2 div 4 + 14
  Assert.AreEqual(251, TzLayoutMetrics.GridColumnEdge(1000, 1, 4, 7));
  Assert.AreEqual(503, TzLayoutMetrics.GridColumnEdge(1000, 2, 4, 7));
end;

procedure TTestLayoutCardAggiuntivi.GridColumnEdge_DopoLUltimaColonna_CapacitaPiuGutter;
begin
  // il bordo della colonna "dopo l'ultima" cade un gutter oltre la capacita'
  Assert.AreEqual(1007, TzLayoutMetrics.GridColumnEdge(1000, 4, 4, 7));
end;

procedure TTestLayoutCardAggiuntivi.GridColumnEdge_SenzaGriglia_Zero;
begin
  Assert.AreEqual(0, TzLayoutMetrics.GridColumnEdge(1000, 2, 0, 7));
  Assert.AreEqual(0, TzLayoutMetrics.GridColumnEdge(1000, 2, -1, 7));
end;

procedure TTestLayoutCardAggiuntivi.GridColumnEdge_CapacitaMinuscola_UnPixelPerColonna;
begin
  // con capacita' 3 il netto negativo viene portato a GridCols (4): 1 px a colonna
  Assert.AreEqual(8, TzLayoutMetrics.GridColumnEdge(3, 1, 4, 7));
end;

procedure TTestLayoutCardAggiuntivi.MinSlotPx_SlotVuoto_UnCarattere;
var
  Modello: TzRowModel;
begin
  Modello := TzRowModel.Create(800, nil);
  try
    Assert.AreEqual(TzRowModel.FONT_WIDTH, Modello.MinSlotPx(0, 8, True));
  finally
    Modello.Free;
  end;
end;

procedure TTestLayoutCardAggiuntivi.SuggestedWidth_MassimoSottoIlMinimo_VinceIlMassimo;
begin
  // 10 * 7 + 40 = 110, minimo 400, ma sullo schermo ci sono solo 300 px
  Assert.AreEqual(300, TzDialogWidthModel.SuggestedWidth(10, 7, 400, 300));
end;

procedure TTestLayoutCardAggiuntivi.Create_LarghezzaStretta_RowMaxSizeSuperaLaCapacitaInPixel;
var
  Modello: TzRowModel;
begin
  // DIV-LAY-1: RowMaxSize ha il minimo MIN_ROW_SIZE (20 caratteri = 140 px),
  // RowMaxPx no (100 - 40 = 60 px): le due capacita' non coincidono.
  Modello := TzRowModel.Create(100, nil);
  try
    Assert.AreEqual(60, Modello.RowMaxPx);
    Assert.AreEqual(TzRowModel.MIN_ROW_SIZE, Modello.RowMaxSize);
    Assert.IsTrue(Modello.RowMaxSize * Modello.CharWidth > Modello.RowMaxPx);
  finally
    Modello.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRowModel);
  TDUnitX.RegisterTestFixture(TTestCardLayoutNames);
  TDUnitX.RegisterTestFixture(TTestLayoutCardAggiuntivi);

end.
