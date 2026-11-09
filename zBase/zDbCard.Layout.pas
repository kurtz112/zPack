unit zDbCard.Layout;

// =============================================================================
// Motore di layout della card (estratto da zDbCard).
//
// - TzRowModel: fonte unica delle metriche di riga (capacita', dimensioni
//   effettive, criteri di overflow, griglia di colonne). Usato dal builder
//   e da SyncLayoutFromEditor: le due logiche devono condividere le stesse
//   regole, altrimenti le righe ricavate dall'editor non corrispondono a
//   quelle realmente costruite.
// - TzCardLayoutNames: regole di naming degli item generati dal controller
//   (li_*, row_*, fill_*, sep_*, grp_*, grprow_*, grpfill_*).
// - TzLayoutFieldInfo: descrittore piatto di un campo (nome, tipo, size,
//   gruppo, controllo ospitato); disaccoppia il builder da TzControl e rende
//   il layout testabile senza istanziare la card.
// - TzCardLayoutBuilder: costruisce il TdxLayoutControl a partire dai
//   descrittori (righe, wrap in pixel, gruppi, filler, griglia).
// =============================================================================

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ImgList,
  cxGraphics,
  cxControls,
  cxGeometry,
  cxClasses,
  cxEdit,
  dxLayoutControl,
  dxLayoutContainer,
  dxLayoutCommon,
  dxLayoutLookAndFeels,
  zBaseLib,
  zSystem,
  zLayouts;

type
  // Modello unico di riga: capacita' (RowMaxSize/RowMaxPx), dimensioni
  // effettive dei controlli (EffectiveSize/EffectiveSlot) e criteri di
  // overflow. Istanze usa-e-getta: crearle via TzDbCard.NewRowModel e
  // liberarle subito.
  TzRowModel = class
  public const
    FONT_WIDTH = 7; // px per carattere di fallback (Segoe UI 10pt @ 96dpi)
    DEFAULT_LINE_HEIGHT = 18; // px per riga di memo, fallback
    EDIT_BORDER_PX = 4;
    H_MARGIN = 20;
    VSCROLLBAR_WIDTH = 20;
    GRP_BORDER_MARGIN = 20; // margine interno bordo GroupBox (px)
    DEFAULT_SIZE = 20; // Size quando ne' props ne' dominio lo definiscono
    MIN_ROW_SIZE = 20;
    MIN_GROUP_ROW_SIZE = 10;
    FALLBACK_ROW_SIZE = 130; // quando la larghezza non e' nota
    MIN_EDIT_CHARS = 4; // larghezza minima leggibile dell'area edit (caratteri)
    // Spacing fisso (px) che dxLayoutControl inserisce tra item adiacenti in una
    // riga ahClient (= TdxLayoutLookAndFeelOffsets.ItemOffset, non letto qui
    // perche' LayoutLookAndFeel puo' essere nil con skin globale). Misurato
    // empiricamente su skin/DPI di riferimento; da ricontrollare se cambiano.
    ITEM_GAP_PX = 7;
    // Larghezza (in caratteri) dei controlli booleani nelle righe root: il loro
    // contenuto e' box + caption, quindi segue la caption (Length(DisplayLabel) +
    // BOOL_EXTRA_CHARS per il box), con minimo BOOL_MIN_CHARS. Non agganciati a
    // colonna (vedi AddFieldItem) -> scorrono negli spazi parziali.
    BOOL_EXTRA_CHARS = 3; // box del checkbox + padding, in caratteri
    BOOL_MIN_CHARS = 5; // larghezza minima (solo box) se caption vuota
  private
    FRowMaxSize: integer;
    FRowMaxPx: integer;
    FCharWidth: integer;
    FLineHeight: integer;
    procedure MeasureFont(AFont: TFont);
  public
    // AFont: se assegnato, CharWidth/LineHeight vengono misurati dal font
    // reale (quindi seguono famiglia, corpo e DPI del frame) invece dei
    // fallback FONT_WIDTH/DEFAULT_LINE_HEIGHT.
    constructor Create(const DlgWidth: integer; AFont: TFont = nil);
    // Capacita' gia' calcolata dai valori reali del motore: nessuna
    // sottrazione di margini stimati (vedi TzLayoutMetrics.RootCapacityWidth).
    constructor CreateFromAreaWidth(const AreaWidthPx: integer; AFont: TFont);
    // Size effettivo in caratteri: esplicito -> dominio -> default, clamp a RowMaxSize
    function EffectiveSize(const Size: integer; Domain: TzDomain): integer;
    // Ingombro in riga: Size effettivo + caption quando questa occupa la
    // colonna a sinistra (clLeft). E' la misura da usare per wrap e residui.
    function EffectiveSlot(const Size: integer; Domain: TzDomain; const CaptionLen: integer): integer;
    // True se aggiungere ASize a AUsed sfora la capacita' della riga
    function Overflows(const AUsed, ASize: integer): boolean;
    // Larghezza minima in px (area controllo) sotto cui l'item non si comprime;
    // oltre, il reflow lo manda a capo. Tenuta <= SlotChars*CharWidth, cosi' la
    // somma dei minimi di riga resta <= RowMaxSize*CharWidth <= client width:
    // niente scrollbar orizzontale.
    function MinSlotPx(const SlotChars, CaptionLen: integer; const CaptionAtLeft: boolean): integer;
    // Quantizzazione a griglia in CARATTERI (righe interne ai gruppi):
    // arrotonda Chars al multiplo superiore dell'unita' di colonna
    // (Capacity div GridCols), clampando alla capacita'. Allarga soltanto.
    // GridCols <= 1 = nessuna quantizzazione (ritorna Chars).
    function SnapSlot(const Chars, Capacity, GridCols: integer): integer;
    property RowMaxSize: integer read FRowMaxSize;
    // Larghezza reale disponibile in px (RowMaxSize ne e' il troncamento a
    // caratteri). E' la base del calcolo di wrap e filler in pixel, cosi' ogni
    // riga somma esattamente allo spazio distribuibile e i campi non vengono
    // stirati/compressi da dxLayoutControl.
    property RowMaxPx: integer read FRowMaxPx;
    property CharWidth: integer read FCharWidth;
    property LineHeight: integer read FLineHeight;
  end;

  // Regole di naming degli item generati dal controller. Funzioni statiche:
  // il nome della card viene passato a ogni chiamata (il Name di un frame
  // puo' essere assegnato dopo la costruzione).
  TzCardLayoutNames = record
  public
    class function FieldItem(const CardName, FieldName: string): string; static; // 'li_CAMPO_CardName'
    class function Row(const CardName: string; const RowIndex: integer): string; static; // 'row_1_CardName'
    class function Filler(const CardName: string; const RowIndex, ColUsed: integer): string; static; // 'fill_1_8_CardName'
    class function Separator(const CardName: string; const RowIndex: integer): string; static; // 'sep_1_CardName'
    class function Group(const CardName, FieldName: string): string; static; // 'grp_CAMPO_CardName'
    class function GroupRow(const CardName, GroupName: string; const RowIndex: integer): string; static; // 'grprow_1_grpAzienda_CardName'
    class function GroupFiller(const CardName, GroupName: string; const RowIndex, ColUsed: integer): string; static; // 'grpfill_1_8_grpAzienda_CardName'
    // Da un nome item generato estrae il FieldName ('' se non riconoscibile:
    // row_*, fill_*, sep_* non hanno FieldName).
    class function ExtractFieldName(const CardName, ItemName: string): string; static;
    // Da 'grprow_<idx>_<grpName>_<card>' estrae <grpName>; '' se non e' una
    // riga interna a un gruppo (es. 'row_N_<card>' = riga root).
    class function ExtractGroupNameFromRowName(const CardName, RowName: string): string; static;
  end;

  // Calcolo puro della larghezza suggerita del dialogo, estratto da
  // TzDbCard.CalcSuggestedDialogWidth per renderlo testabile senza card:
  // MaxRowSum somma gli slot per riga (ROW_BREAK delimita le righe
  // esplicite) e restituisce la riga piu' larga; SuggestedWidth converte
  // in pixel con margini, clamp e arrotondamento a 10.
  TzDialogWidthModel = record
  public const
    ROW_BREAK = -1; // marcatore di fine riga (LineBreak/Separator)
  public
    class function MaxRowSum(const Slots: TArray<integer>): integer; static;
    class function SuggestedWidth(const MaxRowSumChars, CharWidth, MinWidth, MaxAvailWidth: integer): integer; static;
  end;

  // Descrittore piatto di un campo per il builder (snapshot di TzControl).
  TzLayoutFieldInfo = class
  public
    FieldName: string;
    DisplayLabel: string;
    CtrlType: TzCtrlType;
    Size: integer;
    // Colonne fisse della griglia (0 = calcolate dal Size). Con la griglia
    // attiva prevalgono sul Size: il campo occupa sempre quelle colonne,
    // quindi resta allineato agli altri a qualunque larghezza della card.
    ColSpan: integer;
    Lines: integer;
    Group: string;
    RowPlacement: TControlRowPlacement;
    Visible: boolean;
    GroupExpandButton: boolean;
    GroupExpanded: boolean;
    // Icona di TzControlProps.ImageName: indice in Images (-1 = nessuna).
    // L'icona va nella caption di campi, gruppi e separatori solo se Images e'
    // la lista del layout; sui pulsanti Images si assegna al pulsante.
    ImageName: string;
    ImageIndex: integer;
    Images: TCustomImageList;
    Domain: TzDomain;
    EditControl: TcxCustomEdit;
    FallbackControl: TWinControl;
    // Esito del build (scritti dal builder, letti dalla card): colonne
    // occupate davvero e larghezza assegnata in px. 0 = campo non agganciato
    // alla griglia (booleani, gruppi, modalita' senza griglia). Servono al
    // popup (valore iniziale di "Colonne"), a "Fissa colonne" e alla
    // chiusura dell'editor per ricavare le colonne da una larghezza nuova.
    BuiltColSpan: integer;
    BuiltWidthPx: integer;
    constructor Create;
  end;

  // Metriche REALI del motore dxLayout (gap tra item, margini area, area
  // misurata della radice): sostituiscono le costanti empiriche di TzRowModel
  // per tutto cio' che il componente sa dire di se'. Verificate sui sorgenti
  // dx (vedi verifica_meccanismi_dx.md).
  TzLayoutMetrics = record
  public
    // LookAndFeel effettivo: con skin globale LayoutLookAndFeel e' nil e
    // va risolto dal container (TdxLayoutContainer.GetLayoutLookAndFeel).
    class function ActiveLookAndFeel(LayoutControl: TdxLayoutControl): TdxCustomLayoutLookAndFeel; static;
    // Offset reale tra item adiacenti (quello usato da CalculateItemsMajorBounds),
    // gia' scalato per il DPI del container. Fallback: TzRowModel.ITEM_GAP_PX.
    class function ItemGap(LayoutControl: TdxLayoutControl): integer; static;
    // Capacita' orizzontale della radice: client width del controllo meno gli
    // offset radice reali e la riserva per la scrollbar verticale.
    // NB: NON si misura da ItemsAreaBounds della radice — quel rettangolo
    // deriva da ContentBounds (contenuto calcolato, non viewport): se una
    // build sfora, la misura successiva restituirebbe la larghezza del
    // contenuto e l'overflow si auto-alimenterebbe a ogni rebuild.
    // 0 se il controllo non ha ancora una client area utilizzabile.
    class function RootCapacityWidth(LayoutControl: TdxLayoutControl): integer; static;
    // Riduzione orizzontale interna di un gruppo con bordo e caption in alto:
    // bordi sinistro+destro + 2 * offset dell'area item.
    class function GroupInnerHorizontalMargins(LayoutControl: TdxLayoutControl): integer; static;
    // Bordo sinistro in px della colonna ColumnIndex (0-based) di una griglia
    // di GridCols colonne su CapacityPx, gutter compresi. E' la formula del
    // builder (ColumnEdge): le guide della griglia della card la usano per
    // cadere esattamente sui bordi dei campi.
    class function GridColumnEdge(const CapacityPx, ColumnIndex, GridCols, ItemGapPx: integer): integer; static;
  end;

  TzCardLayoutBuilder = class
  private
    FOnCheckGroupBoxStateChanged: TNotifyEvent;
    FOnGroupExpandedStateChanged: TNotifyEvent;
    FEstimatedGroups: integer;
    FBuiltGridCols: integer;
    FBuiltRowCapacityPx: integer;
    FBuiltItemGapPx: integer;
  public
    // Rimuove dal layout tutti gli item generati dal controller
    // (GetFlagUserDefined = False). Gli item vengono liberati SENZA sganciare i
    // controlli ospitati: la distruzione del TdxLayoutItem scollega il Control
    // senza distruggerlo, e Build (chiamato subito dopo) lo riaggancia.
    class procedure ClearGeneratedItems(LayoutControl: TdxLayoutControl);

    // Costruisce il layout: righe root con wrap in pixel, gruppi con righe
    // interne a caratteri, filler, griglia opzionale (Props.SnapToGrid), poi
    // riapplica la struttura utente salvata (Props.Layout.SaveToLayout).
    procedure Build(LayoutControl: TdxLayoutControl; const CardName: string; Fields: TList<TzLayoutFieldInfo>; Props: TzDbCardProps; RowModel: TzRowModel);

    // Quanti gruppi hanno usato una capacita' interna STIMATA (nessuna misura
    // del build precedente disponibile). Finche' e' > 0 il layout dei campi
    // dentro quei gruppi e' costruito su una larghezza indovinata: se la stima
    // eccede l'area vera gli item a larghezza fissa NON si comprimono
    // (dxLayoutControl assegna comunque la loro SufficientWidth) e l'eccesso
    // diventa scroll orizzontale permanente. La card usa questo contatore per
    // programmare un rebuild differito che gira sulle larghezze misurate.
    property EstimatedGroups: integer read FEstimatedGroups;

    // Geometria della griglia della riga root usata dall'ultimo Build
    // (GridCols 0 = griglia disattiva): serve alle guide della griglia.
    property BuiltGridCols: integer read FBuiltGridCols;
    property BuiltRowCapacityPx: integer read FBuiltRowCapacityPx;
    property BuiltItemGapPx: integer read FBuiltItemGapPx;

    property OnCheckGroupBoxStateChanged: TNotifyEvent read FOnCheckGroupBoxStateChanged write FOnCheckGroupBoxStateChanged;
    property OnGroupExpandedStateChanged: TNotifyEvent read FOnGroupExpandedStateChanged write FOnGroupExpandedStateChanged;
  end;

implementation

uses
  SmartInspect.VCL.SiAuto, SmartInspect.VCL, dxCheckGroupBox, cxButtons;

var
  SiLayout: TSiSession;

type
  // Accesso a TdxLayoutContainer.GetLayoutLookAndFeel (protected): con skin
  // globale lc.LayoutLookAndFeel e' nil e il LookAndFeel effettivo e' quello
  // di default (TdxDefaultLayoutLookAndFeels) risolto dal container.
  TdxLayoutContainerAccess = class(TdxLayoutContainer);

  TGroupRowState = class
    GrpCtrlName: string; // nome del ctGroupBox nella collection (es. 'grpAzienda')
    ParentGroup: TdxLayoutGroup; // il TdxLayoutGroup del gruppo
    GrpCurrentRow: TdxLayoutGroup;
    GrpSizeUsed: integer; // somma slot in caratteri (solo naming filler, storico)
    GrpRowIndex: integer;
    GrpMaxSize: integer; // capacita' delle righe interne in caratteri (= GrpMaxPx/CharWidth)
    GrpMaxPx: integer; // capacita' UTILE delle righe interne in pixel (al netto della banda di sicurezza)
    GrpFullPx: integer; // capacita' piena, prima della banda: la usa il filler
    GrpColsUsed: integer; // colonne di griglia consumate nella riga interna corrente
    GrpNextPx: integer; // posizione px del prossimo item nella riga interna corrente
    GrpFieldCount: integer; // campi reali nella riga interna corrente (esclude il filler)
  end;

{ TzLayoutFieldInfo }

constructor TzLayoutFieldInfo.Create;
begin
  inherited Create;
  ImageIndex := -1; // nessuna icona: i descrittori creati senza ImageName restano come prima
end;

{ TzRowModel }

constructor TzRowModel.Create(const DlgWidth: integer; AFont: TFont = nil);
begin
  inherited Create;
  FCharWidth := FONT_WIDTH;
  FLineHeight := DEFAULT_LINE_HEIGHT;
  if Assigned(AFont) then
    MeasureFont(AFont);
  if DlgWidth > 0 then
  begin
    FRowMaxPx := Max(0, DlgWidth - H_MARGIN - VSCROLLBAR_WIDTH);
    FRowMaxSize := Max(MIN_ROW_SIZE, FRowMaxPx div FCharWidth);
  end
  else
  begin
    FRowMaxSize := FALLBACK_ROW_SIZE;
    FRowMaxPx := FRowMaxSize * FCharWidth;
  end;
end;

procedure TzRowModel.MeasureFont(AFont: TFont);
var
  bmp: TBitmap;
begin
  // Larghezza media su una stringa campione (piu' stabile della singola
  // cifra con font proporzionali) e altezza riga dal font reale: le unita'
  // "carattere" seguono cosi' famiglia, corpo e DPI del frame invece della
  // costante 7px tarata su Segoe UI 10pt @ 96dpi.
  try
    bmp := TBitmap.Create;
    try
      bmp.Canvas.Font.Assign(AFont);
      FCharWidth := Max(4, bmp.Canvas.TextWidth('0123456789abcdefghij') div 20);
      FLineHeight := Max(12, bmp.Canvas.TextHeight('Ag') + 1);
    finally
      bmp.Free;
    end;
  except
    // misura fallita (handle/font non disponibili): restano i fallback
  end;
end;

constructor TzRowModel.CreateFromAreaWidth(const AreaWidthPx: integer; AFont: TFont);
begin
  inherited Create;
  FCharWidth := FONT_WIDTH;
  FLineHeight := DEFAULT_LINE_HEIGHT;
  if Assigned(AFont) then
    MeasureFont(AFont);
  if AreaWidthPx > 0 then
  begin
    FRowMaxPx := AreaWidthPx;
    FRowMaxSize := Max(MIN_ROW_SIZE, FRowMaxPx div FCharWidth);
  end
  else
  begin
    FRowMaxSize := FALLBACK_ROW_SIZE;
    FRowMaxPx := FRowMaxSize * FCharWidth;
  end;
end;

function TzRowModel.EffectiveSize(const Size: integer; Domain: TzDomain): integer;
begin
  result := Size;
  if (result <= 0) and Assigned(Domain) then
    result := Domain.GetCtrlSize;
  if result <= 0 then
    result := DEFAULT_SIZE;
  if result > FRowMaxSize then
    result := FRowMaxSize;
end;

function TzRowModel.EffectiveSlot(const Size: integer; Domain: TzDomain; const CaptionLen: integer): integer;
begin
  result := EffectiveSize(Size, Domain);
  if CaptionLen > 0 then
    Inc(result, CaptionLen + 1);
  if result > FRowMaxSize then
    result := FRowMaxSize;
end;

function TzRowModel.Overflows(const AUsed, ASize: integer): boolean;
begin
  result := (AUsed + ASize) > FRowMaxSize;
end;

function TzRowModel.MinSlotPx(const SlotChars, CaptionLen: integer; const CaptionAtLeft: boolean): integer;
var
  floorChars: integer;
begin
  if CaptionAtLeft then
    floorChars := CaptionLen + MIN_EDIT_CHARS // la caption a sinistra non va tagliata
  else
    floorChars := MIN_EDIT_CHARS;
  // Mai sopra la dimensione naturale (un campo stretto non puo' avere min > slot):
  // questo tiene sum(MinWidth) <= sum(slot) <= RowMaxSize, da cui la garanzia.
  if floorChars > SlotChars then
    floorChars := SlotChars;
  result := Max(1, floorChars) * FCharWidth;
end;

function TzRowModel.SnapSlot(const Chars, Capacity, GridCols: integer): integer;
var
  colUnit: integer;
begin
  result := Chars;
  if GridCols <= 1 then
    Exit;
  if Capacity <= 0 then
    Exit;
  colUnit := Capacity div GridCols;
  if colUnit < 1 then
    Exit;
  result := ((Chars + colUnit - 1) div colUnit) * colUnit;
  if result > Capacity then
    result := Capacity;
end;

{ TzLayoutMetrics }

class function TzLayoutMetrics.ActiveLookAndFeel(LayoutControl: TdxLayoutControl): TdxCustomLayoutLookAndFeel;
begin
  result := nil;
  if Assigned(LayoutControl) and Assigned(LayoutControl.Container) then
    result := TdxLayoutContainerAccess(LayoutControl.Container).GetLayoutLookAndFeel;
end;

class function TzLayoutMetrics.ItemGap(LayoutControl: TdxLayoutControl): integer;
var
  LookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  result := 0;
  LookAndFeel := ActiveLookAndFeel(LayoutControl);
  if Assigned(LookAndFeel) then
    result := LookAndFeel.GetItemOffset(LayoutControl.Container);
  if result <= 0 then
    result := TzRowModel.ITEM_GAP_PX;
end;

class function TzLayoutMetrics.RootCapacityWidth(LayoutControl: TdxLayoutControl): integer;
var
  LookAndFeel: TdxCustomLayoutLookAndFeel;
  RootOffsetHorz: integer;
  ScrollBarReserve: integer;
begin
  result := 0;

  if not Assigned(LayoutControl) then
    Exit;
  if not LayoutControl.HandleAllocated then
    Exit;
  if LayoutControl.ClientWidth <= 0 then
    Exit;

  // Offset reale dell'area item radice (per lato); fallback: meta' del
  // margine storico.
  RootOffsetHorz := TzRowModel.H_MARGIN div 2;
  LookAndFeel := ActiveLookAndFeel(LayoutControl);
  if Assigned(LookAndFeel) then
    RootOffsetHorz := LookAndFeel.GetRootItemsAreaOffsetHorz(LayoutControl.Container);

  // Riserva SEMPRE lo spazio della scrollbar verticale (come il margine
  // storico): stimarne la visibilita' prima del build sarebbe circolare.
  ScrollBarReserve := GetSystemMetrics(SM_CXVSCROLL);
  if ScrollBarReserve <= 0 then
    ScrollBarReserve := TzRowModel.VSCROLLBAR_WIDTH;

  result := Max(0, LayoutControl.ClientWidth - 2 * RootOffsetHorz - ScrollBarReserve);
end;

class function TzLayoutMetrics.GroupInnerHorizontalMargins(LayoutControl: TdxLayoutControl): integer;
var
  LookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  LookAndFeel := ActiveLookAndFeel(LayoutControl);
  if Assigned(LookAndFeel) then
    // Composizione reale della larghezza di un gruppo con bordo (vedi
    // TdxLayoutGroupViewInfo.GetBorderWidth + CalculateItemsAreaBounds):
    // bordo sx + bordo dx + offset area su entrambi i lati. I nostri gruppi
    // hanno caption in alto (CaptionSide = sdTop) e sono espansi.
    result := LookAndFeel.GetGroupBorderWidth(LayoutControl.Container, sdLeft, sdTop, true, true) +
      LookAndFeel.GetGroupBorderWidth(LayoutControl.Container, sdRight, sdTop, true, true) +
      2 * LookAndFeel.GetItemsAreaOffsetHorz(LayoutControl.Container)
  else
    result := TzRowModel.GRP_BORDER_MARGIN;
end;

class function TzLayoutMetrics.GridColumnEdge(const CapacityPx, ColumnIndex, GridCols, ItemGapPx: integer): integer;
var
  InnerWidth: integer;
begin
  result := 0;
  if GridCols <= 0 then
    Exit;
  // Unita' di colonna sullo spazio netto (capacita' meno i gutter interni)
  InnerWidth := Max(GridCols, CapacityPx - (GridCols - 1) * ItemGapPx);
  result := (ColumnIndex * InnerWidth) div GridCols + ColumnIndex * ItemGapPx;
end;

{ TzCardLayoutNames }

class function TzCardLayoutNames.FieldItem(const CardName, FieldName: string): string;
begin
  result := Format('li_%s_%s', [FieldName, CardName]);
end;

class function TzCardLayoutNames.Row(const CardName: string; const RowIndex: integer): string;
begin
  result := Format('row_%d_%s', [RowIndex, CardName]);
end;

class function TzCardLayoutNames.Filler(const CardName: string; const RowIndex, ColUsed: integer): string;
begin
  result := Format('fill_%d_%d_%s', [RowIndex, ColUsed, CardName]);
end;

class function TzCardLayoutNames.Separator(const CardName: string; const RowIndex: integer): string;
begin
  result := Format('sep_%d_%s', [RowIndex, CardName]);
end;

class function TzCardLayoutNames.Group(const CardName, FieldName: string): string;
begin
  result := Format('grp_%s_%s', [FieldName, CardName]);
end;

class function TzCardLayoutNames.GroupRow(const CardName, GroupName: string; const RowIndex: integer): string;
begin
  result := Format('grprow_%d_%s_%s', [RowIndex, GroupName, CardName]);
end;

class function TzCardLayoutNames.GroupFiller(const CardName, GroupName: string; const RowIndex, ColUsed: integer): string;
begin
  result := Format('grpfill_%d_%d_%s_%s', [RowIndex, ColUsed, GroupName, CardName]);
end;

class function TzCardLayoutNames.ExtractFieldName(const CardName, ItemName: string): string;
var
  s, Suffix: string;
begin
  result := '';
  Suffix := '_' + CardName;
  if not ItemName.EndsWith(Suffix) then
    Exit;
  s := ItemName.Substring(0, ItemName.Length - Suffix.Length);
  if s.StartsWith('li_') then
    result := s.Substring(3)
  else
    if s.StartsWith('grp_') then
      result := s.Substring(4);
end;

class function TzCardLayoutNames.ExtractGroupNameFromRowName(const CardName, RowName: string): string;
var
  Suffix, body: string;
  p: integer;
begin
  result := '';
  Suffix := '_' + CardName;
  if not RowName.EndsWith(Suffix) then
    Exit;
  if not RowName.StartsWith('grprow_') then
    Exit;
  body := RowName.Substring(7, RowName.Length - 7 - Suffix.Length); // '<idx>_<grpName>'
  p := body.IndexOf('_');
  if p > 0 then
    result := body.Substring(p + 1);
end;

{ TzDialogWidthModel }

class function TzDialogWidthModel.MaxRowSum(const Slots: TArray<integer>): integer;
var
  Slot: integer;
  RowSum: integer;
begin
  result := 0;
  RowSum := 0;

  for Slot in Slots do
    if Slot = ROW_BREAK then
    begin
      result := Max(result, RowSum);
      RowSum := 0;
    end
    else
      Inc(RowSum, Slot);

  result := Max(result, RowSum);
end;

class function TzDialogWidthModel.SuggestedWidth(const MaxRowSumChars, CharWidth, MinWidth, MaxAvailWidth: integer): integer;
var
  RowChars: integer;
begin
  RowChars := MaxRowSumChars;
  if RowChars <= 0 then
    RowChars := TzRowModel.FALLBACK_ROW_SIZE;

  result := RowChars * CharWidth + TzRowModel.H_MARGIN + TzRowModel.VSCROLLBAR_WIDTH;
  result := Max(result, MinWidth);
  result := Min(result, MaxAvailWidth);
  result := (result div 10) * 10;
end;

{ TzCardLayoutBuilder }

class procedure TzCardLayoutBuilder.ClearGeneratedItems(LayoutControl: TdxLayoutControl);

  procedure ClearGroup(grp: TdxLayoutGroup);
  var
    i: integer;
    item: TdxCustomLayoutItem;
  begin
    for i := grp.Count - 1 downto 0 do
    begin
      item := grp.items[i];

      if item is TdxLayoutGroup then
        ClearGroup(item as TdxLayoutGroup);

      if IsGeneratedByController(item) then
        item.Free;
    end;
  end;

{$IFDEF DEBUG}
var
  i: integer;
{$ENDIF}
begin
  if not Assigned(LayoutControl) then
    Exit;

  LayoutControl.BeginUpdate;
  try
    ClearGroup(LayoutControl.items);
  finally
    LayoutControl.EndUpdate;
  end;

{$IFDEF DEBUG}
  for i := 0 to LayoutControl.AbsoluteItemCount - 1 do
    if IsGeneratedByController(LayoutControl.AbsoluteItems[i]) then
      raise Exception.Create('ClearGeneratedItems: item ' + LayoutControl.AbsoluteItems[i].name + ' (' + LayoutControl.AbsoluteItems[i].classname + ') rimasto!');
{$ENDIF}
end;

procedure TzCardLayoutBuilder.Build(LayoutControl: TdxLayoutControl; const CardName: string; Fields: TList<TzLayoutFieldInfo>; Props: TzDbCardProps; RowModel: TzRowModel);
var
  lc: TdxLayoutControl;
  RowMaxSize: integer; // larghezza massima della riga root in unita' Size
  GridCols: integer; // colonne della griglia di allineamento (0 = disattiva)
  WrapTolerancePx: integer; // banda di compressione per item prima del wrap (shrink-before-wrap)
  SingleLineHeight: integer; // altezza naturale di un edit a riga singola (0 = non trovato)
  CurrentRowIsGroup: boolean; // la riga root corrente contiene gruppi (no filler)
  CurrentRow: TdxLayoutGroup;
  CurrentSizeUsed: integer; // somma dei Size (caratteri) nella riga corrente (naming filler + righe gruppo)
  CurrentPxUsed: integer; // somma px nella riga root corrente (solo modalita' SENZA griglia)
  CurrentColsUsed: integer; // colonne di griglia consumate nella riga root corrente
  CurrentNextPx: integer; // posizione px del prossimo item nella riga root corrente (griglia)
  CurrentFieldCount: integer; // numero di campi/gruppi reali piazzati nella riga corrente (esclude il filler)
  ItemGapPx: integer; // offset reale tra item adiacenti (TzLayoutMetrics.ItemGap)
  RowGuardPx: integer; // banda di sicurezza sottratta alla capacita' prima di calcolare le colonne
  RowCapacityPx: integer; // capacita' UTILE della riga root (RowMaxPx - RowGuardPx)
  GroupMarginPx: integer; // riduzione orizzontale interna reale dei gruppi con bordo
  CaptionMeasure: TBitmap; // canvas per misurare le caption col font reale
  // Larghezza REALE dell'area item di ogni gruppo (nome dx -> px), misurata
  // dal ViewInfo del build PRECEDENTE prima di ClearGeneratedItems. Per i
  // gruppi (a differenza della radice) la misura e' sicura: la loro larghezza
  // la decide la distribuzione della riga padre, non il contenuto, quindi non
  // c'e' retroazione. Serve soprattutto ai gruppi AFFIANCATI, la cui quota
  // reale non e' derivabile dal Size nominale.
  PrevGroupAreaWidths: TDictionary<string, integer>;
  RowIndex: integer;
  GroupStates: TObjectDictionary<string, TGroupRowState>;

  // Larghezza reale del testo di una caption (font del layout control):
  // sostituisce la stima Length * CharWidth, imprecisa con font proporzionali.
  function CaptionTextPx(const Caption: string): integer;
  begin
    if Caption = '' then
      Exit(0);
    result := CaptionMeasure.Canvas.TextWidth(Caption) + 2; // margine anti-troncamento
  end;

  // Icona di TzControlProps.ImageName nella caption del layout: solo se
  // l'indice e' valido e la lista e' quella del layout (una form puo'
  // assegnarne un'altra nel DFM: lo stesso indice sarebbe un'altra icona).
  // I pulsanti mostrano l'icona sul pulsante, non nella caption.
  function HasCaptionIcon(field: TzLayoutFieldInfo): boolean;
  begin
    result := (field.ImageIndex >= 0) and Assigned(field.Images) and (field.Images = lc.OptionsImage.Images) and (field.CtrlType <> ctButton);
  end;

  // Px che l'icona aggiunge alla caption: icona piu' spazio fra icona e
  // testo. Senza questa quota l'etichetta si tronca o il campo esce dalla
  // colonna.
  function CaptionIconPx(field: TzLayoutFieldInfo): integer;
  begin
    if not HasCaptionIcon(field) then
      Exit(0);
    result := MulDiv(field.Images.Width + 4, lc.CurrentPPI, 96);
  end;

  function CaptionIconChars(field: TzLayoutFieldInfo): integer;
  begin
    result := (CaptionIconPx(field) + RowModel.CharWidth - 1) div RowModel.CharWidth;
  end;

  // Larghezza della caption di un campo, icona compresa
  function FieldCaptionPx(field: TzLayoutFieldInfo): integer;
  begin
    result := CaptionTextPx(field.DisplayLabel) + CaptionIconPx(field);
  end;

  function FindFieldInfo(const AFieldName: string): TzLayoutFieldInfo;
  var
    candidate: TzLayoutFieldInfo;
  begin
    result := nil;
    for candidate in Fields do
      if SameText(candidate.FieldName, AFieldName) then
        Exit(candidate);
  end;

  // ===========================================================================
  // Griglia a COLONNE ESATTE (modalita' SnapToGrid, GridCols > 1).
  //
  // La capacita' viene divisa in GridCols colonne separate da GridCols-1
  // gutter reali (ItemGapPx): l'unita' di colonna e' quindi calcolata sullo
  // spazio NETTO (InnerWidth = capacita' - gutter), non sulla capacita' lorda
  // come faceva SnapSlotPx — era quella la causa del wrap prematuro nelle
  // righe piene (4 colonne + 3 gutter non ci stavano mai).
  //
  // ColumnEdge(m) = posizione px di inizio della colonna m (0-based), gutter
  // inclusi. Ogni item agganciato termina ESATTAMENTE a ColumnEdge(m)-gap:
  // i bordi dipendono solo dal numero cumulato di colonne, mai dalla
  // composizione della riga, quindi coincidono al pixel tra righe diverse
  // dello stesso contenitore. Le larghezze vengono applicate con AlignHorz
  // ahLeft (fisse): dxLayoutControl non ridistribuisce piu' proporzionalmente
  // e due campi con lo stesso span rendono identici anche su righe con un
  // numero diverso di item (era la causa di E Mail piu' larga di Telefono 1).
  // ===========================================================================
  function GridInnerWidth(const CapacityPx: integer): integer;
  begin
    result := Max(GridCols, CapacityPx - (GridCols - 1) * ItemGapPx);
  end;

  function ColumnEdge(const CapacityPx, ColumnIndex: integer): integer;
  begin
    // Formula condivisa con le guide della griglia della card
    result := TzLayoutMetrics.GridColumnEdge(CapacityPx, ColumnIndex, GridCols, ItemGapPx);
  end;

  function ColumnSpan(const NaturalPx, CapacityPx: integer): integer;
  var
    spanDenom: integer;
  begin
    // Colonne necessarie alla larghezza naturale, CONTANDO i gutter interni
    // allo span: un item di s colonne arriva a ColumnEdge(k+s)-gap, quindi
    // rende s*colUnit + (s-1)*ItemGapPx px, non s*colUnit. La vecchia formula
    // ceil(NaturalPx/colUnit) ignorava i gutter recuperati e prenotava una
    // colonna in piu' appena la larghezza naturale superava di pochi px il
    // multiplo di colonna (tipico delle caption lunghe in clTop, es. "Data
    // Disattivazione"): la somma degli span sfondava GridCols e l'ultimo
    // campo rpSameRow andava a capo con la riga ancora capiente.
    // s*colUnit + (s-1)*gap >= N  <=>  s >= (N+gap)*GridCols / (Inner+GridCols*gap)
    spanDenom := GridInnerWidth(CapacityPx) + GridCols * ItemGapPx;
    result := ((NaturalPx + ItemGapPx) * GridCols + spanDenom - 1) div spanDenom;
    if result < 1 then
      result := 1;
    if result > GridCols then
      result := GridCols;
  end;

  // --- Gestione righe root ---
  procedure FlushRow;
  // Chiude la riga corrente. Una riga di CAMPI riceve un filler per assorbire
  // lo spazio residuo (i campi non devono stirarsi); una riga di GRUPPI no:
  // i gruppi sono ahClient e devono riempire la larghezza al 100% (o dividersi
  // proporzionalmente se affiancati). Il flag CurrentRowIsGroup distingue i due
  // casi, cosi' QUALUNQUE chiusura (finale, da campo o linebreak successivo)
  // rispetta la natura della riga.
  var
    filler: TdxLayoutEmptySpaceItem;
    fillerWidth: integer;
  begin
    if not Assigned(CurrentRow) then
      Exit;
    if not CurrentRowIsGroup then
    begin
      // Residuo esatto della riga: in modalita' griglia e' capacita' meno la
      // posizione del prossimo item (gia' comprensiva dei gutter reali); senza
      // griglia e' il calcolo storico a somma di larghezze + gap stimati.
      if GridCols > 1 then
        fillerWidth := RowModel.RowMaxPx - CurrentNextPx
      else
        fillerWidth := RowModel.RowMaxPx - CurrentPxUsed - CurrentFieldCount * ItemGapPx;

      if fillerWidth > 0 then
      begin
        filler := lc.CreateItem(TzDxLayoutEmptySpaceItem) as TdxLayoutEmptySpaceItem;
        filler.name := TzCardLayoutNames.Filler(CardName, RowIndex, CurrentSizeUsed);
        filler.Parent := CurrentRow;
        filler.AlignHorz := ahClient;
        filler.Width := fillerWidth;
        filler.SetFlagUserDefined(false);
      end;
    end;
    CurrentRow := nil;
    CurrentSizeUsed := 0;
    CurrentPxUsed := 0;
    CurrentColsUsed := 0;
    CurrentNextPx := 0;
    CurrentFieldCount := 0;
    CurrentRowIsGroup := false;
    // NB: nessun Inc(RowIndex) qui — lo fa EnsureRow alla creazione della riga
    // (uno per riga). Il doppio incremento desincronizzava i nomi di righe e
    // filler.
  end;

  function EnsureRow: TdxLayoutGroup;
  begin
    if not Assigned(CurrentRow) then
    begin
      Inc(RowIndex);
      CurrentRowIsGroup := false; // default: riga di campi (il branch gruppo la rimarca)
      CurrentRow := lc.CreateItem(TzDxLayoutGroup) as TdxLayoutGroup;
      CurrentRow.name := TzCardLayoutNames.Row(CardName, RowIndex);
      CurrentRow.Parent := lc.items;
      CurrentRow.LayoutDirection := ldHorizontal;
      CurrentRow.ShowBorder := false;
      CurrentRow.CaptionOptions.Visible := false;
      CurrentRow.AlignHorz := ahClient;
      CurrentRow.AlignVert := avTop;
      // Disabilita l'allineamento automatico delle caption nella riga:
      // con clLeft + catDefault il motore ignora Width proporzionale.
      // catNone permette a Width di funzionare come peso.
      CurrentRow.ItemControlAreaAlignment := catNone;
      CurrentRow.SetFlagUserDefined(false);
    end;
    result := CurrentRow;
  end;

  // --- Stato righe interne ai gruppi ---
  procedure FlushGroupRow(gs: TGroupRowState);
  var
    filler: TdxLayoutEmptySpaceItem;
    fillerWidth: integer;
  begin
    if not Assigned(gs.GrpCurrentRow) then
      Exit;

    // Residuo esatto della riga interna (vedi FlushRow)
    // Capacita' PIENA (non quella ridotta dalla banda): cosi' il filler include
    // anche la banda di sicurezza ed e' lui, essendo ahClient, ad assorbire
    // l'eventuale differenza tra area calcolata e area reale.
    if GridCols > 1 then
      fillerWidth := gs.GrpFullPx - gs.GrpNextPx
    else
      fillerWidth := gs.GrpFullPx - gs.GrpNextPx - gs.GrpFieldCount * ItemGapPx;

    if fillerWidth > 0 then
    begin
      filler := lc.CreateItem(TzDxLayoutEmptySpaceItem) as TdxLayoutEmptySpaceItem;
      filler.name := TzCardLayoutNames.GroupFiller(CardName, gs.GrpCtrlName, gs.GrpRowIndex, gs.GrpSizeUsed);
      filler.Parent := gs.GrpCurrentRow;
      filler.AlignHorz := ahClient;
      filler.Width := fillerWidth;
      filler.SetFlagUserDefined(false);
    end;
    gs.GrpCurrentRow := nil;
    gs.GrpSizeUsed := 0;
    gs.GrpColsUsed := 0;
    gs.GrpNextPx := 0;
    gs.GrpFieldCount := 0;
  end;

  function EnsureGroupRow(gs: TGroupRowState): TdxLayoutGroup;
  begin
    if not Assigned(gs.GrpCurrentRow) then
    begin
      Inc(gs.GrpRowIndex);
      gs.GrpCurrentRow := lc.CreateItem(TzDxLayoutGroup) as TdxLayoutGroup;
      gs.GrpCurrentRow.name := TzCardLayoutNames.GroupRow(CardName, gs.GrpCtrlName, gs.GrpRowIndex);
      gs.GrpCurrentRow.Parent := gs.ParentGroup;
      gs.GrpCurrentRow.LayoutDirection := ldHorizontal;
      gs.GrpCurrentRow.ShowBorder := false;
      gs.GrpCurrentRow.CaptionOptions.Visible := false;
      gs.GrpCurrentRow.AlignHorz := ahClient;
      gs.GrpCurrentRow.AlignVert := avTop;
      gs.GrpCurrentRow.ItemControlAreaAlignment := catNone;
      gs.GrpCurrentRow.SetFlagUserDefined(false);
    end;
    result := gs.GrpCurrentRow;
  end;

  function GroupSharesRow(GroupItem: TdxLayoutGroup): boolean;
  begin
    // Vero se il TdxLayoutGroup del gruppo e' gia' stato piazzato in una riga
    // root insieme ad altri item (gruppi/campi affiancati). Un gruppo ancora
    // "parcheggiato" sotto la radice (membri dichiarati prima del ctGroupBox)
    // non e' decidibile da qui: in quel caso decide il RowPlacement.
    result := false;
    if not Assigned(GroupItem.Parent) then
      Exit;
    if GroupItem.Parent = lc.items then
      Exit;
    result := GroupItem.Parent.Count > 1;
  end;

  function GetOrCreateGroupState(const GroupName: string): TGroupRowState;
  var
    dxGrpItem: TdxCustomLayoutItem;
    grpInfo: TzLayoutFieldInfo;
  begin
    if not GroupStates.TryGetValue(GroupName, result) then
    begin
      result := TGroupRowState.Create;
      result.GrpCtrlName := GroupName;
      dxGrpItem := lc.FindItem(TzCardLayoutNames.Group(CardName, GroupName));
      if Assigned(dxGrpItem) and (dxGrpItem is TdxLayoutGroup) then
        result.ParentGroup := TdxLayoutGroup(dxGrpItem)
      else
        result.ParentGroup := nil;
      result.GrpCurrentRow := nil;
      result.GrpSizeUsed := 0;
      result.GrpColsUsed := 0;
      result.GrpNextPx := 0;
      result.GrpFieldCount := 0;
      result.GrpRowIndex := 0;

      // Capacita' REALE delle righe interne, in ordine di preferenza:
      // 1) larghezza misurata dal build precedente (PrevGroupAreaWidths):
      //    esatta anche per i gruppi AFFIANCATI, la cui quota dipende dalla
      //    distribuzione dei pesi nella riga padre;
      // 2) gruppo su riga propria (caso comune): capacita' della riga root
      //    meno i margini reali del bordo;
      // 3) gruppo affiancato mai misurato: quota stimata dal Size nominale.
      result.GrpMaxSize := RowMaxSize;
      result.GrpMaxPx := RowModel.RowMaxPx;
      if Assigned(result.ParentGroup) then
      begin
        // Il valore misurato (ItemsAreaBounds) e' gia' al netto di bordi e offset
        if not PrevGroupAreaWidths.TryGetValue(result.ParentGroup.name, result.GrpMaxPx) then
        begin
          grpInfo := FindFieldInfo(GroupName);
          if Assigned(grpInfo) and (GroupSharesRow(result.ParentGroup) or (grpInfo.RowPlacement = rpSameRow)) then
            result.GrpMaxPx := RowModel.EffectiveSize(grpInfo.Size, grpInfo.Domain) * RowModel.CharWidth - GroupMarginPx
          else
            result.GrpMaxPx := RowModel.RowMaxPx - GroupMarginPx;

          // Capacita' STIMATA: nessuna misura disponibile (primo build della
          // card). La card ne tiene conto per programmare un rebuild sulle
          // larghezze vere, vedi TzCardLayoutBuilder.EstimatedGroups.
          Inc(FEstimatedGroups);
        end;

        // TETTO alla capacita' misurata: un gruppo NON puo' mai essere piu'
        // largo della riga radice corrente (meno i propri margini). La misura
        // di PrevGroupAreaWidths viene dal build PRECEDENTE: se la card e' stata
        // ristretta, quel valore e' piu' grande della riga di ora e -- essendo
        // usato per impaccare le righe INTERNE del gruppo -- le costruirebbe per
        // la larghezza vecchia, sfondando quella nuova (scrollbar orizzontale che
        // si auto-alimenta a ogni resize, come gia' evitato per la capacita'
        // radice). Il clamp spezza la retroazione: sui gruppi affiancati la quota
        // misurata resta sotto il tetto (nessun effetto), sui gruppi a piena
        // larghezza forza la capacita' reale della riga di adesso.
        result.GrpMaxPx := Min(result.GrpMaxPx, RowModel.RowMaxPx - GroupMarginPx);
        result.GrpMaxPx := Max(TzRowModel.MIN_GROUP_ROW_SIZE * RowModel.CharWidth, result.GrpMaxPx);
      end;

      // Banda di sicurezza anche dentro i gruppi (vedi RowGuardPx): le colonne
      // si calcolano su GrpMaxPx ridotto, il filler chiude su GrpFullPx.
      result.GrpFullPx := result.GrpMaxPx;
      result.GrpMaxPx := Max(RowModel.CharWidth, result.GrpMaxPx - RowGuardPx);
      result.GrpMaxSize := Max(TzRowModel.MIN_GROUP_ROW_SIZE, result.GrpMaxPx div RowModel.CharWidth);

      GroupStates.Add(GroupName, result);
    end;
  end;

  // --- Size e Height ---
  function ResolveSize(field: TzLayoutFieldInfo): integer;
  begin
    result := RowModel.EffectiveSize(field.Size, field.Domain);
  end;

  // Altezza NATURALE di un controllo a riga singola gia' presente sulla card,
  // letta dal componente VCL vero invece che stimata. Serve come riferimento
  // per i memo/rtf a 1 riga (vedi ResolveHeight): la formula
  // LineHeight+EDIT_BORDER_PX sottostima l'altezza reale di un edit DevExpress,
  // facendo apparire il memo piu' basso dei campi vicini. Tutti i controlli a
  // riga singola con lo stesso ControlFont hanno la stessa altezza, ne basta uno.
  function FindSingleLineHeight: integer;
  var
    refField: TzLayoutFieldInfo;
  begin
    result := 0;
    for refField in Fields do
    begin
      if not refField.Visible then
        Continue;
      if refField.CtrlType.IsMultiLine then
        Continue;
      if refField.CtrlType in [ctLineBreak, ctSeparator] then
        Continue;
      if not Assigned(refField.EditControl) then
        Continue;
      if refField.EditControl.Height > 0 then
        Exit(refField.EditControl.Height);
    end;
  end;

  function ResolveHeight(field: TzLayoutFieldInfo): integer;
  // Altezza esplicita dell'ITEM di layout in px (0 = auto/avParentManaged).
  //
  // Per i memo/rtf l'altezza e' SEMPRE esplicita (anche a 1 riga): assegnare
  // direttamente Control.Height lasciando l'item auto NON funziona, perche' il
  // layout chiede al controllo la sua dimensione "naturale", governata dalle
  // sue proprieta' interne (VisibleLineCount, AutoSize) e non modificabile via
  // Height. Assegnando invece l'Height sull'ITEM con AlignVert=avTop, il layout
  // posiziona il controllo con SetBounds su un rettangolo fisso, bypassando il
  // calcolo naturale — unico meccanismo efficace (gia' usato per Lines>1).
  //
  // Regole per tipo di controllo:
  // - memo/rtf con Lines<=1: altezza = SingleLineHeight (altezza naturale di un
  //   edit vero sulla card, vedi FindSingleLineHeight); se non disponibile,
  //   ricade sulla formula LineHeight+EDIT_BORDER_PX.
  // - memo/rtf con Lines>1: Max(1,Lines) righe con la formula.
  // - altri multi-riga (immagine, radiogroup...): esplicita solo se Lines>1.
  // - riga singola (edit, lookup, date...): SEMPRE auto, Lines ignorato (un
  //   Lines "sporco" persistito su un edit lo renderebbe altissimo).
  const
    MAX_LINES = 40; // tetto difensivo: oltre e' comunque fuori scala
  var
    Lines: integer;
  begin
    result := 0;
    Lines := field.Lines;
    if Lines > MAX_LINES then
      Lines := MAX_LINES;

    if field.CtrlType in [ctMemo, ctRTF] then
    begin
      if Lines <= 1 then
        if SingleLineHeight > 0 then
          Exit(SingleLineHeight)
        else
          Lines := 1;
    end
    else
      if not(field.CtrlType.IsMultiLine and (Lines > 1)) then
        Exit; // riga singola, o multiriga non-testo senza Lines espliciti: auto

    // LineHeight misurato dal font reale del frame (segue corpo e DPI).
    result := (Lines * RowModel.LineHeight) + TzRowModel.EDIT_BORDER_PX;
  end;

  // --- Separatore ---
  procedure AddSeparator;
  var
    sep: TdxLayoutSeparatorItem;
  begin
    FlushRow;
    Inc(RowIndex);
    sep := lc.CreateItem(TzDxLayoutSeparatorItem) as TdxLayoutSeparatorItem;
    sep.name := TzCardLayoutNames.Separator(CardName, RowIndex);
    sep.Parent := lc.items;
    sep.AlignHorz := ahClient;
    sep.SetFlagUserDefined(false);
  end;

  // --- Aggiunge un TdxLayoutItem dentro un parent ---
  procedure AddFieldItem(field: TzLayoutFieldInfo; EffectiveSize: integer; ParentGroup: TdxLayoutGroup);
  var
    dxItem: TdxLayoutItem;
    h: integer;
    isNormalRow: boolean;
    countedInGroup: boolean;
    slotSize: integer;
    slotPx: integer; // larghezza FINALE dell'item in px
    span: integer; // colonne di griglia occupate (0 = non agganciato: booleani / no griglia)
    startCol: integer; // prima colonna libera dopo la posizione reale (griglia)
    isGridItem: boolean; // larghezza esatta su colonne -> AlignHorz ahLeft
    gs: TGroupRowState;
    memoReserve: integer; // px riservati ai flag rpSameRow che seguono un memo (0 = nessuno)
    fixedSpan: integer; // colonne fisse del campo (0 = calcolate dal Size)

    function BoolSlotPx: integer;
    var
      extraChars: integer;
    begin
      // Ingombro reale di un booleano: dipende da dove sta la caption.
      // clLeft: caption a fianco del box -> caption + box (BOOL_EXTRA_CHARS);
      // clTop (default): caption SOPRA il box -> l'ingombro e' la caption
      // stessa piu' un piccolo margine. Il vecchio +3 fisso gonfiava le righe
      // di sole checkbox (gruppo ID) fino a spezzarle.
      if Props.CaptionLayout = clLeft then
        extraChars := TzRowModel.BOOL_EXTRA_CHARS
      else
        extraChars := 1;
      result := Max(TzRowModel.BOOL_MIN_CHARS * RowModel.CharWidth, FieldCaptionPx(field) + extraChars * RowModel.CharWidth);
    end;

    // Px da riservare per i flag (booleani) marcati rpSameRow che seguono un
    // memo NELLO STESSO contenitore. Serve a tenere il flag a destra del memo,
    // sulla stessa riga: senza riserva il memo si prende tutte le colonne
    // residue e chiude la riga, spingendo il flag sotto.
    // DELIBERATAMENTE limitata ai BOOLEANI: sono flottanti (avanzano a pixel,
    // non a colonne) e si compongono col memo posizionato a pixel. Un follower
    // NON booleano (data/lookup) usa la griglia a colonne e finirebbe con
    // larghezza incoerente dopo un memo pixel-based: per quei casi si tiene il
    // comportamento storico (memo pieno, follower a capo), cosi' le card che
    // gia' li usano (WT: Richiesta, Richieste_Intestatario) NON cambiano.
    function TrailingSameRowBoolReservePx: integer;
    var
      idx, k, extraChars, followerPx: integer;
      f: TzLayoutFieldInfo;
    begin
      result := 0;
      idx := Fields.IndexOf(field);
      if idx < 0 then
        Exit;
      for k := idx + 1 to Fields.Count - 1 do
      begin
        f := Fields[k];
        if not f.Visible then
          Continue;
        if f.CtrlType = ctSeparator then
          Break;
        if f.CtrlType = ctLineBreak then
          if SameText(f.Group, field.Group) then
            Break
          else
            Continue;
        if not SameText(f.Group, field.Group) then
          Continue; // altro contenitore: non e' un follower di questa riga
        // Primo campo dello stesso contenitore dopo il memo:
        if f.RowPlacement <> rpSameRow then
          Break; // non chiede la stessa riga -> niente riserva
        if not f.CtrlType.IsBoolean then
          Break; // solo i flag scorrono a pixel accanto al memo
        if Props.CaptionLayout = clLeft then
          extraChars := TzRowModel.BOOL_EXTRA_CHARS
        else
          extraChars := 1;
        followerPx := Max(TzRowModel.BOOL_MIN_CHARS * RowModel.CharWidth, FieldCaptionPx(f) + extraChars * RowModel.CharWidth);
        Inc(result, ItemGapPx + followerPx);
        // continua: piu' flag consecutivi rpSameRow si accodano tutti
      end;
    end;

    function GridNaturalPx: integer;
    begin
      // Larghezza naturale per il calcolo dello span: il controllo, ma MAI
      // meno della caption quando sta sopra/sotto — il motore dx non scende
      // sotto Max(caption, controllo) (TdxLayoutCellItemViewInfo.GetContentWidth
      // con clTop/clBottom), quindi prenotare meno colonne della caption
      // significherebbe farsi allargare l'item a insaputa della contabilita'.
      result := slotSize * RowModel.CharWidth;
      if Props.CaptionLayout in [clTop, clBottom] then
        result := Max(result, FieldCaptionPx(field));
    end;

    function GridMinItemPx: integer;
    begin
      // Minimo REALE dell'item per dx: area controllo (ControlOptions.MinWidth,
      // che impostiamo noi) e caption secondo la sua posizione.
      if Props.CaptionLayout = clLeft then
        result := RowModel.MinSlotPx(EffectiveSize, Length(field.DisplayLabel) + CaptionIconChars(field), true)
      else
      begin
        result := RowModel.MinSlotPx(EffectiveSize, 0, false);
        if Props.CaptionLayout in [clTop, clBottom] then
          result := Max(result, FieldCaptionPx(field));
      end;
    end;

    // Prima colonna il cui bordo non precede la posizione reale NextPx.
    // I booleani avanzano a pixel senza consumare colonne: dopo di loro
    // ColsUsed resta indietro rispetto a NextPx, e calcolare il bordo di
    // arrivo da ColsUsed dava una larghezza negativa, poi alzata al solo
    // minimo dal ciclo su GridMinItemPx (campo Cup di Progetti.Progetti
    // ridotto a ~40 px dopo quattro checkbox). Senza booleani NextPx coincide
    // con ColumnEdge(ColsUsed) e il risultato e' ColsUsed: nessun cambiamento.
    function FirstFreeColumn(const CapacityPx, ColsUsed, NextPx: integer): integer;
    begin
      result := ColsUsed;
      while (result < GridCols) and (ColumnEdge(CapacityPx, result) < NextPx) do
        Inc(result);
    end;

    // Se la riga e' gia' avanzata oltre il bordo di colonna (booleani), il
    // tratto fra NextPx e il bordo di FromCol e' gia' disponibile: puo'
    // bastare a risparmiare una colonna. Con NextPx sul bordo (nessun
    // booleano prima) lo span resta quello di ColumnSpan, senza ricalcoli che
    // per arrotondamento potrebbero cambiarlo di una colonna.
    function FitSpan(const NaturalSpan, FromCol, NextPx, CapacityPx: integer): integer;
    begin
      result := NaturalSpan;
      // Colonne fisse: lo span e' quello dichiarato, senza risparmi.
      if fixedSpan > 0 then
        Exit;
      if NextPx >= ColumnEdge(CapacityPx, FromCol) then
        Exit;
      while (result > 1) and (ColumnEdge(CapacityPx, FromCol + result - 1) - ItemGapPx - NextPx >= GridNaturalPx) do
        Dec(result);
    end;

  begin
    gs := nil; // valorizzato solo per i campi raggruppati
    span := 0;
    startCol := 0;
    isGridItem := false;

    // Colonne fisse: valgono solo con la griglia attiva e mai per i booleani,
    // che non consumano colonne. Limitate alle colonne della griglia.
    fixedSpan := 0;
    if (GridCols > 1) and (field.ColSpan > 0) and not field.CtrlType.IsBoolean then
      fixedSpan := Min(field.ColSpan, GridCols);

    // Ingombro in riga: con clLeft la caption occupa la colonna a sinistra
    // del controllo, quindi va conteggiata nel wrap e nei residui.
    slotSize := EffectiveSize;
    if Props.CaptionLayout = clLeft then
      Inc(slotSize, Length(field.DisplayLabel) + CaptionIconChars(field) + 1);
    if slotSize > RowMaxSize then
      slotSize := RowMaxSize;
    // Default (modalita' senza griglia): larghezza naturale in px.
    slotPx := slotSize * RowModel.CharWidth;

    // Campo raggruppato: crea righe interne al gruppo
    if not field.Group.IsEmpty then
    begin
      gs := GetOrCreateGroupState(field.Group);
      if Assigned(gs.ParentGroup) then
      begin
        // La capacita' e' quella REALE del gruppo (GrpMaxPx), non la riga root
        if EffectiveSize > gs.GrpMaxSize then
          EffectiveSize := gs.GrpMaxSize;
        if slotSize > gs.GrpMaxSize then
        begin
          slotSize := gs.GrpMaxSize;
          slotPx := slotSize * RowModel.CharWidth;
        end;

        if GridCols > 1 then
        begin
          // Colonne esatte sulla capacita' del gruppo (vedi ColumnEdge): i
          // bordi coincidono al pixel tra tutte le righe interne del gruppo.
          if field.CtrlType.IsBoolean then
          begin
            // Booleano: larghezza reale della caption, non consuma colonne
            slotPx := BoolSlotPx;
            if Assigned(gs.GrpCurrentRow) and ((field.RowPlacement = rpForceNewLine) or (gs.GrpNextPx + slotPx > gs.GrpMaxPx)) then
              FlushGroupRow(gs);
            ParentGroup := EnsureGroupRow(gs);
          end
          else
          begin
            if fixedSpan > 0 then
              span := fixedSpan
            else
              span := ColumnSpan(GridNaturalPx, gs.GrpMaxPx);
            if Assigned(gs.GrpCurrentRow) then
            begin
              startCol := FirstFreeColumn(gs.GrpMaxPx, gs.GrpColsUsed, gs.GrpNextPx);
              if (field.RowPlacement = rpForceNewLine) or (startCol + FitSpan(span, startCol, gs.GrpNextPx, gs.GrpMaxPx) > GridCols) then
                FlushGroupRow(gs);
            end;
            ParentGroup := EnsureGroupRow(gs);
            startCol := FirstFreeColumn(gs.GrpMaxPx, gs.GrpColsUsed, gs.GrpNextPx);
            span := FitSpan(span, startCol, gs.GrpNextPx, gs.GrpMaxPx);
            memoReserve := 0;
            if field.CtrlType.IsMemo and (fixedSpan = 0) then
              memoReserve := TrailingSameRowBoolReservePx;
            if field.CtrlType.IsMemo and (memoReserve > 0) then
            begin
              // Un flag rpSameRow segue il memo: il memo NON riempie le colonne
              // residue, lascia memoReserve px al flag e avanza a pixel (span=0)
              // cosi' la riga interna non viene chiusa dopo di lui.
              span := 0;
              slotPx := gs.GrpMaxPx - gs.GrpNextPx - ItemGapPx - memoReserve;
              if slotPx < GridMinItemPx then
                slotPx := GridMinItemPx;
              isGridItem := true;
            end
            else
            begin
              // Memo/RTF: riempiono tutte le colonne residue della riga —
              // larghezza piena se soli, il resto della riga se affiancati.
              // Con colonne fisse il memo occupa solo quelle dichiarate.
              if field.CtrlType.IsMemo and (fixedSpan = 0) then
                span := Max(span, GridCols - startCol);
              // Larghezza = fino al bordo della colonna di arrivo, contata
              // dalla prima colonna libera dopo i booleani flottanti (startCol);
              // se la caption impone di piu', lo span si estende finche' l'item
              // resta sopra il minimo reale di dx.
              slotPx := ColumnEdge(gs.GrpMaxPx, startCol + span) - ItemGapPx - gs.GrpNextPx;
              while (slotPx < GridMinItemPx) and (startCol + span < GridCols) do
              begin
                Inc(span);
                slotPx := ColumnEdge(gs.GrpMaxPx, startCol + span) - ItemGapPx - gs.GrpNextPx;
              end;
              if slotPx < RowModel.CharWidth then
                slotPx := RowModel.CharWidth;
              isGridItem := true;
            end;
          end;
        end
        else
        begin
          // Senza griglia: wrap storico a caratteri, pesi proporzionali
          if Assigned(gs.GrpCurrentRow) and ((field.RowPlacement = rpForceNewLine) or (gs.GrpSizeUsed + slotSize > gs.GrpMaxSize)) then
            FlushGroupRow(gs);
          ParentGroup := EnsureGroupRow(gs);
        end;
      end;
      // Se il gruppo non e' stato trovato, ParentGroup resta quello passato (fallback)
    end;

    isNormalRow := not Assigned(ParentGroup);

    if isNormalRow then
    begin
      if GridCols > 1 then
      begin
        // Colonne esatte sulla capacita' della riga root (vedi ColumnEdge).
        // Eccezione BOOLEANI (checkbox/toggle): larghezza reale della caption,
        // non consumano colonne e scorrono negli spazi parziali.
        if field.CtrlType.IsBoolean then
        begin
          slotPx := BoolSlotPx;
          if Assigned(CurrentRow) and (CurrentNextPx + slotPx > RowCapacityPx) then
            FlushRow;
          ParentGroup := EnsureRow;
        end
        else
        begin
          if fixedSpan > 0 then
            span := fixedSpan
          else
            span := ColumnSpan(GridNaturalPx, RowCapacityPx);
          if Assigned(CurrentRow) then
          begin
            startCol := FirstFreeColumn(RowCapacityPx, CurrentColsUsed, CurrentNextPx);
            if startCol + FitSpan(span, startCol, CurrentNextPx, RowCapacityPx) > GridCols then
              FlushRow;
          end;
          ParentGroup := EnsureRow;
          startCol := FirstFreeColumn(RowCapacityPx, CurrentColsUsed, CurrentNextPx);
          span := FitSpan(span, startCol, CurrentNextPx, RowCapacityPx);
          memoReserve := 0;
          if field.CtrlType.IsMemo and (fixedSpan = 0) then
            memoReserve := TrailingSameRowBoolReservePx;
          if field.CtrlType.IsMemo and (memoReserve > 0) then
          begin
            // Vedi ramo gruppo: il memo lascia spazio al flag rpSameRow.
            span := 0;
            slotPx := RowCapacityPx - CurrentNextPx - ItemGapPx - memoReserve;
            if slotPx < GridMinItemPx then
              slotPx := GridMinItemPx;
            isGridItem := true;
          end
          else
          begin
            // Memo/RTF: riempiono tutte le colonne residue della riga —
            // larghezza piena se soli, il resto della riga se affiancati.
            // Con colonne fisse il memo occupa solo quelle dichiarate.
            if field.CtrlType.IsMemo and (fixedSpan = 0) then
              span := Max(span, GridCols - startCol);
            slotPx := ColumnEdge(RowCapacityPx, startCol + span) - ItemGapPx - CurrentNextPx;
            while (slotPx < GridMinItemPx) and (startCol + span < GridCols) do
            begin
              Inc(span);
              slotPx := ColumnEdge(RowCapacityPx, startCol + span) - ItemGapPx - CurrentNextPx;
            end;
            if slotPx < RowModel.CharWidth then
              slotPx := RowModel.CharWidth;
            isGridItem := true;
          end;
        end;
      end
      else
      begin
        // Senza griglia: larghezze naturali e wrap in pixel con banda di
        // tolleranza (shrink-before-wrap), comportamento storico.
        if field.CtrlType.IsBoolean then
          slotPx := BoolSlotPx;
        if Assigned(CurrentRow) and (CurrentPxUsed + slotPx + CurrentFieldCount * ItemGapPx > RowCapacityPx + (CurrentFieldCount + 1) * WrapTolerancePx) then
          FlushRow;
        ParentGroup := EnsureRow;
      end;
    end;

    dxItem := lc.CreateItem(TzDxFieldLayoutItem) as TdxLayoutItem;
    dxItem.name := TzCardLayoutNames.FieldItem(CardName, field.FieldName);
    dxItem.Parent := ParentGroup;
    dxItem.Caption := field.DisplayLabel;
    dxItem.CaptionOptions.Visible := true;
    dxItem.CaptionOptions.Layout := Props.CaptionLayout;
    if HasCaptionIcon(field) then
      dxItem.CaptionOptions.ImageIndex := field.ImageIndex;

    // Pulsante: l'icona va sul pulsante, con la sua lista
    if (field.CtrlType = ctButton) and (field.FallbackControl is TcxButton) then
      if (field.ImageIndex >= 0) and Assigned(field.Images) then
      begin
        TcxButton(field.FallbackControl).OptionsImage.Images := field.Images;
        TcxButton(field.FallbackControl).OptionsImage.ImageIndex := field.ImageIndex;
      end
      else
        TcxButton(field.FallbackControl).OptionsImage.ImageIndex := -1;

    // Modalita' griglia: larghezza ESATTA (ahLeft, nessuna ridistribuzione
    // proporzionale di dxLayoutControl — era quella a far rendere due campi
    // con lo stesso peso a px diversi su righe con item count diverso).
    // Senza griglia: peso proporzionale ahClient come sempre.
    if (GridCols > 1) and (isGridItem or field.CtrlType.IsBoolean) then
      dxItem.AlignHorz := ahLeft
    else
      dxItem.AlignHorz := ahClient;
    dxItem.Width := slotPx;

    // Esito per la card (popup "Colonne", "Fissa colonne", editor): solo
    // per gli item agganciati a colonne intere.
    if isGridItem and (span > 0) then
    begin
      field.BuiltColSpan := span;
      field.BuiltWidthPx := slotPx;
    end
    else
    begin
      field.BuiltColSpan := 0;
      field.BuiltWidthPx := 0;
    end;

    // MinWidth controllato sull'AREA CONTROLLO (ControlOptions.MinWidth, px):
    // e' il minimo sotto cui l'item ahClient non si comprime e che determina
    // la comparsa della scrollbar orizzontale. Il default DevExpress e' 20px
    // (dxLayoutItemControlDefaultMinWidth): troppo alto e fuori dal nostro
    // controllo, era la causa per cui i campi non si stringevano. Impostandolo
    // dal modello, la somma dei minimi di riga resta <= RowMaxSize*CharWidth
    // <= client e la scrollbar non compare; quando il minimo non basta, il
    // reflow (CheckReflow) manda il campo a capo.
    // NB: ControlOptions.MinWidth e' la sola area controllo; con clLeft la
    // caption ha colonna propria, quindi qui NON va inclusa (a differenza del
    // peso Width e dello slot di wrap).
    dxItem.ControlOptions.MinWidth := RowModel.MinSlotPx(EffectiveSize, 0, false);

    dxItem.Visible := field.Visible;
    dxItem.SetFlagUserDefined(false);

    h := ResolveHeight(field);
    if h > 0 then
    begin
      dxItem.AlignVert := avTop;
      dxItem.Height := h;
    end;

    if Assigned(field.EditControl) then
      dxItem.Control := field.EditControl
    else
      if Assigned(field.FallbackControl) then
        dxItem.Control := field.FallbackControl;

    // Memo/rtf: SizeOptions.Height sull'item riserva lo spazio ma non basta a
    // fissare l'altezza del CONTROLLO (di default il layout lo stira, e con
    // AutoSize il controllo si rioccupa sul contenuto). ControlOptions.FixedSize
    // dice al layout di non stirarlo; con Height esplicita il controllo disegna
    // la misura richiesta (h). AutoSize=False e' impostato in InitControlProperties.
    if (h > 0) and (field.CtrlType in [ctMemo, ctRTF]) and Assigned(field.EditControl) then
    begin
      dxItem.ControlOptions.FixedSize := true;
      field.EditControl.Height := h;
    end;

    // NB: la larghezza extra dei pick-list (il combo sforava l'area assegnata)
    // si corregge disattivando l'AutoSize del controllo in InitControlProperties
    // (rami ctPickList/ctPickListImage), non con FixedSize qui: cosi' resta
    // elastico al resize.

    countedInGroup := false;
    if Assigned(gs) and Assigned(gs.ParentGroup) then
    begin
      Inc(gs.GrpSizeUsed, slotSize); // solo per il naming del filler (storico)
      Inc(gs.GrpFieldCount);
      if GridCols > 1 then
      begin
        if span > 0 then
        begin
          // Item agganciato: avanza per colonne, la posizione successiva e'
          // sempre un bordo di colonna (allineamento garantito).
          gs.GrpColsUsed := startCol + span;
          gs.GrpNextPx := ColumnEdge(gs.GrpMaxPx, gs.GrpColsUsed);
        end
        else
          // Booleano flottante: avanza della larghezza reale + gap
          gs.GrpNextPx := gs.GrpNextPx + slotPx + ItemGapPx;

        if (gs.GrpColsUsed >= GridCols) or (gs.GrpNextPx >= gs.GrpMaxPx) then
          FlushGroupRow(gs);
      end
      else
      begin
        Inc(gs.GrpNextPx, slotPx); // per il filler px di FlushGroupRow
        if gs.GrpSizeUsed >= gs.GrpMaxSize then
          FlushGroupRow(gs);
      end;
      countedInGroup := true;
    end;

    // Comprende il fallback: un campo con Group il cui gruppo non esiste
    // viene collocato nella riga normale e va conteggiato li', altrimenti
    // la riga non si riempie mai e il wrapping salta.
    if (not countedInGroup) and isNormalRow then
    begin
      Inc(CurrentSizeUsed, slotSize); // solo per il naming del filler
      Inc(CurrentFieldCount);
      if GridCols > 1 then
      begin
        if span > 0 then
        begin
          CurrentColsUsed := startCol + span;
          CurrentNextPx := ColumnEdge(RowCapacityPx, CurrentColsUsed);
        end
        else
          CurrentNextPx := CurrentNextPx + slotPx + ItemGapPx;

        if (CurrentColsUsed >= GridCols) or (CurrentNextPx >= RowCapacityPx) then
          FlushRow;
      end
      else
      begin
        Inc(CurrentPxUsed, slotPx);
        if CurrentPxUsed >= RowCapacityPx then
          FlushRow;
      end;
    end;
  end;

  // --- PRIMA PASSATA: crea TdxLayoutGroup per ctGroupBox/ctCheckGroupBox ---
  procedure CreateGroupForControl(field: TzLayoutFieldInfo);
  // Prima passata: crea solo il TdxLayoutGroup parcheggiato sotto lc.Items.
  // Il posizionamento in riga avviene nella seconda passata.
  // TzDxFieldLayoutGroup: il Width (derivato da Size) non viene serializzato
  // ne' sovrascritto da SaveToLayout (vedi invariante in zLayouts).
  var
    grp: TdxLayoutGroup;
  begin
    grp := lc.CreateItem(TzDxFieldLayoutGroup) as TdxLayoutGroup;
    grp.name := TzCardLayoutNames.Group(CardName, field.FieldName);
    grp.Parent := lc.items;
    grp.ShowBorder := true;
    grp.Caption := field.DisplayLabel;
    if HasCaptionIcon(field) then
      grp.CaptionOptions.ImageIndex := field.ImageIndex;
    grp.AlignHorz := ahClient;
    grp.AlignVert := avTop;
    grp.SetFlagUserDefined(false);

    if field.CtrlType = ctCheckGroupBox then
    begin
      grp.ButtonOptions.CheckBox.Visible := true;
      grp.ButtonOptions.CheckBox.CheckAction := cbaToggleChildrenEnabledState;
      grp.ButtonOptions.CheckBox.Checked := true; // aggiornato da UpdateCheckGroupBoxes
      grp.OnCheckBoxStateChanged := FOnCheckGroupBoxStateChanged;
    end;

    // Bottone di collasso e stato espanso: persistiti in TzControlProps
    // (gli item generati dal controller non sono serializzati nel Layout,
    // vedi zLayouts.LoadFromLayout) e riapplicati qui a ogni rebuild.
    // Il collasso alla sola riga di caption richiede ShowBorder=True e
    // ButtonOptions.Visible=True (default), gia' garantiti sopra.
    grp.ButtonOptions.ShowExpandButton := field.GroupExpandButton;
    if field.GroupExpandButton then
      grp.Expanded := field.GroupExpanded
    else
      grp.Expanded := true; // senza bottone il gruppo non deve restare collassato
    // Hook DOPO il set programmatico di Expanded: solo i click utente salvano
    grp.OnExpanded := FOnGroupExpandedStateChanged;
    grp.OnCollapsed := FOnGroupExpandedStateChanged;
  end;

  // Diagnostica [FIT]: legge dal build PRECEDENTE (ViewInfo gia' calcolati,
  // nessun ricalcolo forzato) le righe root il cui contenuto sfora l'area
  // disponibile. E' li' che nasce lo scroll orizzontale: gli item non-client
  // ricevono comunque la loro larghezza dichiarata
  // (CalculateNonClientAlignedItemsVisibleSizes), quindi l'eccesso non viene
  // riassorbito da nessuno.
  procedure AuditPreviousLayout;
  // Scansione GLOBALE del build precedente (ViewInfo gia' calcolati, nessun
  // ricalcolo): trova gli item il cui bordo destro reale supera il client.
  // E' l'unica misura che dice davvero chi genera lo scroll orizzontale,
  // ovunque sia annidato (le righe root da sole nascondono gli sforamenti
  // che avvengono DENTRO i gruppi).
  var
    i, clientW, r, maxRight: integer;
    dxItem: TdxCustomLayoutItem;
    maxName: string;
    isLeaf: boolean;
  begin
    clientW := lc.ClientWidth;
    if clientW <= 0 then
      Exit;

    SiLayout.LogMessage(Format('[FIT] client=%d capacita=%d RowMaxPx=%d gap=%d grpMargin=%d guard=%d',
      [clientW, TzLayoutMetrics.RootCapacityWidth(lc), RowModel.RowMaxPx, ItemGapPx, GroupMarginPx, RowGuardPx]));

    maxRight := 0;
    maxName := '';
    for i := 0 to lc.Container.AbsoluteItemCount - 1 do
    begin
      dxItem := lc.Container.AbsoluteItems[i];
      if not Assigned(dxItem.ViewInfo) then
        Continue;
      r := dxItem.ViewInfo.Bounds.Right;
      // Foglie con un controllo vero (i campi): sono quelle che "pungono" oltre
      // il client. I gruppi/righe si loggano solo come contesto piu' avanti.
      isLeaf := (dxItem is TdxLayoutItem) and Assigned(TdxLayoutItem(dxItem).Control);
      if r > maxRight then
      begin
        maxRight := r;
        maxName := dxItem.name;
      end;
      // Qualunque item (foglia o gruppo) che sfora il client va segnalato:
      // l'eccesso e' esattamente lo scroll orizzontale.
      if r > clientW then
        SiLayout.LogMessage(Format('[FIT] OLTRE %s (leaf=%s): right=%d client=%d eccesso=%d',
          [dxItem.name, BoolToStr(isLeaf, true), r, clientW, r - clientW]));
    end;

    SiLayout.LogMessage(Format('[FIT] MAX-RIGHT %s: right=%d client=%d delta=%d',
      [maxName, maxRight, clientW, maxRight - clientW]));
  end;

  procedure ApplyCaptionLayout;
  var
    i: integer;
    dxItem: TdxCustomLayoutItem;
  begin
    for i := 0 to lc.Container.AbsoluteItemCount - 1 do
    begin
      dxItem := lc.Container.AbsoluteItems[i];
      if dxItem is TzDxLayoutItem then
        TdxLayoutItem(dxItem).CaptionOptions.Layout := Props.CaptionLayout;
    end;
  end;

var
  field: TzLayoutFieldInfo;
  EffectiveSize: integer;
  dxGrp: TdxCustomLayoutItem;
  gs: TGroupRowState;
  gsPair: TPair<string, TGroupRowState>;
  AbsoluteIndex: integer;
  PrevGroupItem: TdxCustomLayoutItem;
begin
  lc := LayoutControl;
  RowMaxSize := RowModel.RowMaxSize;

  // Griglia di colonne condivisa (allineamento verticale): con SnapToGrid
  // ogni slot viene allargato al multiplo di colonna successivo (ColCount
  // colonne per riga), cosi' i bordi dei controlli coincidono tra righe
  // diverse invece di produrre il "rumore" di larghezze libere.
  if Props.SnapToGrid then
    GridCols := Max(1, Props.ColCount)
  else
    GridCols := 0;

  // Banda di compressione tollerata per item prima di mandare a capo
  // (shrink-before-wrap, vedi wrap in AddFieldItem): mezzo carattere per
  // item. Piccola (invisibile) ma sufficiente a evitare i wrap "arbitrari"
  // per sforamenti minimi (< 1%); uno sforamento vero la supera comunque.
  WrapTolerancePx := Max(1, RowModel.CharWidth div 2);

  // Metriche REALI del motore (vedi TzLayoutMetrics): offset tra item e
  // margini interni dei gruppi, gia' scalati per DPI/skin correnti. La
  // griglia a colonne esatte include i gutter nel calcolo dei bordi
  // (vedi ColumnEdge), quindi i valori veri contano.
  ItemGapPx := TzLayoutMetrics.ItemGap(lc);
  GroupMarginPx := TzLayoutMetrics.GroupInnerHorizontalMargins(lc);

  // BANDA DI SICUREZZA.
  // La larghezza REALE dell'area item puo' essere di qualche pixel inferiore a
  // quella calcolata (padding del gruppo, offset dell'area radice, presenza
  // della scrollbar verticale, arrotondamenti della griglia). In modalita'
  // griglia gli item sono ahLeft, cioe' NON-client: dxLayoutControl assegna
  // loro esattamente la larghezza dichiarata e non li comprime mai
  // (CalculateNonClientAlignedItemsVisibleSizes), quindi anche pochi pixel di
  // eccesso sfondano la riga e restano li' come scroll orizzontale.
  // Costruendo le colonne su RowMaxPx - RowGuardPx la differenza finisce nel
  // filler di fine riga, che essendo ahClient si comprime fino a sparire:
  // l'errore viene assorbito invece di propagarsi.
  RowGuardPx := Max(2, ItemGapPx);
  RowCapacityPx := Max(RowModel.CharWidth, RowModel.RowMaxPx - RowGuardPx);

  FBuiltGridCols := GridCols;
  FBuiltRowCapacityPx := RowCapacityPx;
  FBuiltItemGapPx := ItemGapPx;

  FEstimatedGroups := 0;

  AuditPreviousLayout;

  // Riferimento reale per l'altezza dei memo a 1 riga (vedi ResolveHeight):
  // calcolato una sola volta per card, non per campo.
  SingleLineHeight := FindSingleLineHeight;

  // Fotografa la larghezza reale dell'area item dei gruppi del build
  // precedente PRIMA di distruggerli (vedi PrevGroupAreaWidths).
  PrevGroupAreaWidths := TDictionary<string, integer>.Create;
  for AbsoluteIndex := 0 to lc.Container.AbsoluteItemCount - 1 do
  begin
    PrevGroupItem := lc.Container.AbsoluteItems[AbsoluteIndex];
    if PrevGroupItem is TzDxFieldLayoutGroup then
      if Assigned(PrevGroupItem.ViewInfo) then
        if PrevGroupItem.ViewInfo is TdxLayoutGroupViewInfo then
          if TdxLayoutGroupViewInfo(PrevGroupItem.ViewInfo).ItemsAreaBounds.Width > 0 then
          begin
            PrevGroupAreaWidths.AddOrSetValue(PrevGroupItem.name, TdxLayoutGroupViewInfo(PrevGroupItem.ViewInfo).ItemsAreaBounds.Width);
            SiLayout.LogMessage(Format('[FIT] gruppo %s: areaMisurata=%d',
              [PrevGroupItem.name, TdxLayoutGroupViewInfo(PrevGroupItem.ViewInfo).ItemsAreaBounds.Width]));
          end;
  end;

  ClearGeneratedItems(lc);

  CaptionMeasure := TBitmap.Create;
  CaptionMeasure.Canvas.Font.Assign(lc.Font);

  GroupStates := TObjectDictionary<string, TGroupRowState>.Create([doOwnsValues]);
  try
    lc.BeginUpdate;
    try
      CurrentRow := nil;
      CurrentSizeUsed := 0;
      CurrentPxUsed := 0;
      CurrentColsUsed := 0;
      CurrentNextPx := 0;
      CurrentFieldCount := 0;
      RowIndex := 0;
      CurrentRowIsGroup := false;

      // ==============================================================
      // PRIMA PASSATA: crea TdxLayoutGroup per ctGroupBox/ctCheckGroupBox
      // ==============================================================
      for field in Fields do
      begin
        if not field.Visible then
          Continue;
        if field.CtrlType = ctSeparator then
          Continue;
        if field.CtrlType = ctLineBreak then
          Continue;
        if not field.Group.IsEmpty then
          Continue;

        if field.CtrlType in [ctGroupBox, ctCheckGroupBox] then
          CreateGroupForControl(field);
      end;

      // Reset contatori per la seconda passata
      FlushRow;
      CurrentRow := nil;
      CurrentSizeUsed := 0;
      CurrentPxUsed := 0;
      CurrentColsUsed := 0;
      CurrentNextPx := 0;
      CurrentFieldCount := 0;
      RowIndex := 0;
      CurrentRowIsGroup := false;

      // ==============================================================
      // SECONDA PASSATA: crea TdxLayoutItem per tutti i campi dati
      // ==============================================================
      for field in Fields do
      begin
        if field.CtrlType = ctSeparator then
        begin
          // Un separatore con Visible=false non va disegnato (come i campi e i ritorni a capo)
          if field.Visible then
            AddSeparator;
          Continue;
        end;

        if field.CtrlType = ctLineBreak then
        begin
          if field.Visible then
          begin
            // LineBreak con Group: flush della riga interna al gruppo
            if not field.Group.IsEmpty then
            begin
              if GroupStates.TryGetValue(field.Group, gs) then
                FlushGroupRow(gs);
            end
            else
              FlushRow;
          end;
          Continue;
        end;

        // ctGroupBox/ctCheckGroupBox: posiziona il gruppo (gia' creato nella prima
        // passata) dentro la riga corrente della seconda passata.
        if field.CtrlType in [ctGroupBox, ctCheckGroupBox] then
        begin
          if not field.Visible then
            Continue;
          EffectiveSize := ResolveSize(field);
          // Anche i gruppi si agganciano alla griglia: pesi coerenti con
          // quelli dei campi quando sono affiancati su una stessa riga.
          EffectiveSize := RowModel.SnapSlot(EffectiveSize, RowMaxSize, GridCols);
          dxGrp := lc.FindItem(TzCardLayoutNames.Group(CardName, field.FieldName));
          if Assigned(dxGrp) and (dxGrp is TdxLayoutGroup) then
          begin
            // Affianca al precedente (gruppo O campo, es. Foto + gruppi) SOLO se
            // l'utente l'ha disposto cosi' (RowPlacement = rpSameRow). Default
            // rpAuto per un gruppo = riga propria a tutta larghezza.
            if (field.RowPlacement = rpSameRow) and Assigned(CurrentRow) and (CurrentSizeUsed > 0) then
            begin
              // NESSUN vincolo di capacita': il Size del gruppo (130 = "pieno")
              // e' un peso, non una larghezza; i gruppi affiancati si dividono la
              // riga in proporzione ai Width. Niente filler: marca riga di gruppo.
              // La riga torna orizzontale: se il precedente era un gruppo su riga
              // dedicata, EnsureRow l'aveva messa in verticale (vedi sotto).
              CurrentRow.LayoutDirection := ldHorizontal;
              dxGrp.Parent := CurrentRow;
              TdxLayoutGroup(dxGrp).Width := EffectiveSize * RowModel.CharWidth;
              Inc(CurrentSizeUsed, EffectiveSize);
              CurrentRowIsGroup := true;
            end
            else
            begin
              // Chiudi la riga pendente (FlushRow mette il filler solo se era
              // una riga di campi) e apri una riga dedicata al gruppo.
              FlushRow;
              EnsureRow;
              CurrentRowIsGroup := true; // questa riga non avra' filler
              // Riga dedicata a UN solo gruppo: direzione VERTICALE, non
              // orizzontale. DevExpress collassa un gruppo lungo l'asse del
              // contenitore (TdxLayoutGroupViewInfo.AllowCollapsedHeight richiede
              // Parent.LayoutDirection = ldVertical, AllowCollapsedWidth il
              // contrario): dentro una riga orizzontale il gruppo chiuso si
              // stringeva alla larghezza della caption e TENEVA l'altezza del
              // contenuto (riquadro vuoto sotto il titolo). Con un solo item la
              // direzione non cambia la geometria (ahClient riempie la riga).
              CurrentRow.LayoutDirection := ldVertical;
              dxGrp.Parent := CurrentRow;
              // Width = peso: da solo sulla riga ahClient riempie il 100%;
              // serve per dividere proporzionalmente in caso di affiancamento.
              TdxLayoutGroup(dxGrp).Width := EffectiveSize * RowModel.CharWidth;
              CurrentSizeUsed := EffectiveSize;
            end;
          end;
          Continue;
        end;

        if not field.Visible then
          Continue;
        if (field.EditControl = nil) and (field.FallbackControl = nil) then
          Continue;

        EffectiveSize := ResolveSize(field);

        // Campo con Group: va dentro il suo TdxLayoutGroup (via righe interne)
        if not field.Group.IsEmpty then
        begin
          AddFieldItem(field, EffectiveSize, nil);
          Continue;
        end;

        // Campo normale.
        // - se la riga corrente e' di gruppi, chiudila prima (FlushRow non mette
        // filler perche' CurrentRowIsGroup) cosi' il campo non ci finisce dentro;
        // - RowPlacement = rpForceNewLine forza una nuova riga (equivalente a un
        // LineBreak davanti, ma per-campo);
        // - rpAuto/rpSameRow: i campi FLUISCONO (auto-wrap quando la riga e' piena).
        if CurrentRowIsGroup then
          FlushRow
        else
          if (field.RowPlacement = rpForceNewLine) and Assigned(CurrentRow) and (CurrentSizeUsed > 0) then
            FlushRow;
        AddFieldItem(field, EffectiveSize, nil);
      end;

      FlushRow;

      // Flush delle righe interne a tutti i gruppi
      for gsPair in GroupStates do
        FlushGroupRow(gsPair.Value);

      // Ripristina struttura salvata dall'editor
      if Props.Layout.Count > 0 then
        Props.Layout.SaveToLayout(lc);

      // Garantisce l'allineamento automatico delle caption con clLeft.
      ApplyCaptionLayout;

      lc.OptionsItem.AutoControlAreaAlignment := true;

      // Belt: nessuno scroll orizzontale a livello root (la garanzia primaria
      // resta il calcolo congruo dei ControlOptions.MinWidth + reflow).
      lc.items.ScrollOptions.Horizontal := smNone;

      SiLayout.LogMessage(Format('Build: %d righe root, RowMaxSize=%d, CharWidth=%d, LineHeight=%d, RowCapacityPx=%d, gruppiStimati=%d',
        [RowIndex, RowMaxSize, RowModel.CharWidth, RowModel.LineHeight, RowCapacityPx, FEstimatedGroups]));
    finally
      lc.EndUpdate;
    end;
  finally
    FreeAndNil(GroupStates);
    FreeAndNil(CaptionMeasure);
    FreeAndNil(PrevGroupAreaWidths);
  end;
end;

initialization

SiLayout := Si.AddSession('zDbCard.Layout', true);

finalization

SiLayout := nil;

end.
