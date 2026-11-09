unit zLayouts;

// =============================================================================
// zLayouts
//
// Serializzazione delle personalizzazioni di TdxLayoutControl (DFM-based).
//
// ARCHITETTURA:
// Il modulo gestisce la persistenza dei TdxLayoutControl di DevExpress tramite
// una collection di TzLayoutItem serializzabili in DFM. Il trasferimento dei
// dati tra il TdxLayoutControl runtime e la collection avviene tramite un
// Strategy Pattern (vedi TzLayoutItemStrategy e sottoclassi):
//
// TdxCustomLayoutItem  <─── Strategy.LoadFrom ───> TzLayoutItem
// <─── Strategy.SaveTo   ────
//
// Una strategy specifica per ogni tipo di item DevExpress incapsula la logica
// di trasferimento delle proprietà type-specific. Il dispatch (GetStrategyFor)
// seleziona la strategy in base al tipo runtime del TdxCustomLayoutItem.
//
// REGOLA DI INVARIANTE — TzDxFieldLayoutItem:
// Per i campi data-aware il cui Width/Height è DERIVATO da TzControlProps
// (ColSpan via TzDbCard.BuildLayoutItems, Lines via ResolveHeight), Width e
// Height NON vengono serializzati. Vedi commento sopra TzDxFieldLayoutItem
// e TzLayoutItemFieldStrategy.
// =============================================================================

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Variants,
  System.Generics.Collections,
  System.Actions,
  data.db,

  FireDAC.Comp.Client,
  FireDAC.Stan.Option,
  FireDAC.DApt,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.FB,
  FireDAC.Comp.DataSet,

  cxPc,
  dxLayoutContainer,
  dxLayoutControl,
  dxLayoutCommon,

  zCollection,

  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TItemClassKind = (ickLayoutItem, ickLayoutGroup, ickLayoutEmptySpaceItem, ickLayoutSeparatorItem, ickLayoutSplitterItem, ickLayoutLabeledItem);

  TzLayoutItem = class;
  TzLayoutItems = class;
  TzLayout = class;
  TzLayouts = class;

  // =============================================================================
  // TzLayoutItem
  //
  // Serializzazione DFM delle personalizzazioni di un singolo TdxCustomLayoutItem.
  //
  // Le proprietà sono organizzate in famiglie:
  // - base: comuni a tutti i tipi di item
  // - CaptionOptions: ImageIndex/VisibleElements per item con caption
  // - TdxLayoutItem: ItemCaptionLayout, ItemCaptionWidth, Padding
  // - TdxLayoutGroup: tutte le GroupXxx, Offsets, ScrollOptions
  // - TdxLayoutSplitterItem: SplitterAllowCloseOnClick, SplitterIsClosed
  //
  // La logica di trasferimento dati è in TzLayoutItemStrategy (vedi sotto):
  // ogni famiglia di proprietà è gestita da una strategy dedicata.
  //
  // REGOLA DI INVARIANTE:
  // • Per i TdxLayoutItem che sono istanze di TzDxFieldLayoutItem (campi
  // data-aware il cui Width/Height è derivato da TzControlProps), Width
  // e Height NON vengono serializzati: la fonte di verità è TzControlProps
  // (ColSpan via TzDbCard.BuildLayoutItems, Lines via ResolveHeight).
  //
  // • Per tutti gli altri item (TzDxLayoutItem semplice usato da
  // zFormController, TdxLayoutGroup, TdxLayoutSplitterItem,
  // TdxLayoutEmptySpaceItem, e item user-defined), Width e tutte le altre
  // proprietà sono serializzati normalmente.
  //
  // Violare questa regola fa sì che SaveToLayout sovrascriva il ColSpan
  // calcolato, producendo controlli che non rispondono al cambio di ColSpan
  // dall'editor visuale (bug originale del 2025).
  //
  // L'invariante è codificata in TzLayoutItemFieldStrategy.LoadFrom/SaveTo,
  // che testa "dxItem is TzDxFieldLayoutItem" e salta Width/Height in quel caso.
  // =============================================================================
  TzLayoutItem = class(TzCollectionItem)
  private
    // --- base (tutti gli item) ---
    FAlignHorz: TdxLayoutAlignHorz;
    FAlignVert: TdxLayoutAlignVert;
    FCaption: string;
    FCaptionAlignHorz: TAlignment;
    FCaptionAlignVert: TdxAlignmentVert;
    FCaptionVisible: boolean;
    FEnabled: boolean;
    FGeneratedByController: boolean;
    FHeight: integer;
    FIdx: integer;
    FIsUserDefined: boolean;
    FItemClassKind: TItemClassKind;
    FOffsetBottom: integer;
    FOffsetLeft: integer;
    FOffsetRight: integer;
    FOffsetTop: integer;
    FPaddingBottom: integer;
    FPaddingLeft: integer;
    FPaddingRight: integer;
    FPaddingTop: integer;
    FParentName: string;
    FVisible: boolean;
    FWidth: integer;
    // --- CaptionOptions comuni ---
    FImageIndex: integer;
    FVisibleElements: TdxLayoutItemCaptionVisibleElements;
    // --- TdxLayoutItem specifico ---
    FItemCaptionLayout: TdxCaptionLayout;
    FItemCaptionWidth: integer;
    // --- TdxLayoutGroup specifico ---
    FGroupButtonOptionsAlignment: TdxLayoutGroupButtonsAlignment;
    FGroupButtonOptionsVisible: boolean;
    FGroupExpanded: boolean;
    FGroupHidden: boolean;
    FGroupHideTabs: boolean;
    FGroupItemControlAreaAlignment: TdxLayoutItemControlAreaAlignment;
    FGroupItemIndex: integer;
    FGroupLayoutDirection: TdxLayoutDirection;
    FGroupLayoutLookAndFeelException: boolean;
    FGroupLocked: boolean;
    FGroupShowBorder: boolean;
    FGroupShowExpandButton: boolean;
    FGroupShowTabFrame: boolean;
    FGroupTabbedHotTrack: boolean;
    FGroupTabbedMultiLine: boolean;
    FGroupTabbedRotate: boolean;
    FGroupTabbedTabHeight: integer;
    FGroupTabbedTabPosition: TcxTabPosition;
    FGroupTabbedTabWidth: integer;
    FGroupUseIndent: boolean;
    FScrollOptionsHorizontal: TdxLayoutGroupScrollMode;
    FScrollOptionsVertical: TdxLayoutGroupScrollMode;
    // --- TdxLayoutSplitterItem specifico ---
    FSplitterAllowCloseOnClick: boolean;
    FSplitterIsClosed: boolean;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    // base
    property AlignHorz: TdxLayoutAlignHorz read FAlignHorz write FAlignHorz default ahParentManaged;
    property AlignVert: TdxLayoutAlignVert read FAlignVert write FAlignVert default avParentManaged;
    property Caption: string read FCaption write FCaption;
    property CaptionAlignHorz: TAlignment read FCaptionAlignHorz write FCaptionAlignHorz default taLeftJustify;
    property CaptionAlignVert: TdxAlignmentVert read FCaptionAlignVert write FCaptionAlignVert default TdxAlignmentVert.tavCenter;
    property CaptionVisible: boolean read FCaptionVisible write FCaptionVisible default true;
    property Enabled: boolean read FEnabled write FEnabled default true;
    // default False (non true): il costruttore inizializza il campo a False,
    // quindi con 'default true' i record con valore True non venivano scritti
    // nello stream DFM e rientravano a False. Sono proprio i gruppi strutturali
    // del controller, che tornavano a essere trattati come item utente.
    property GeneratedByController: boolean read FGeneratedByController write FGeneratedByController default False;
    property Height: integer read FHeight write FHeight default 0;
    property Idx: integer read FIdx write FIdx default 0;
    property IsUserDefined: boolean read FIsUserDefined write FIsUserDefined default False;
    property ItemClassKind: TItemClassKind read FItemClassKind write FItemClassKind default ickLayoutItem;
    property OffsetBottom: integer read FOffsetBottom write FOffsetBottom default 0;
    property OffsetLeft: integer read FOffsetLeft write FOffsetLeft default 0;
    property OffsetRight: integer read FOffsetRight write FOffsetRight default 0;
    property OffsetTop: integer read FOffsetTop write FOffsetTop default 0;
    property PaddingBottom: integer read FPaddingBottom write FPaddingBottom default 0;
    property PaddingLeft: integer read FPaddingLeft write FPaddingLeft default 0;
    property PaddingRight: integer read FPaddingRight write FPaddingRight default 0;
    property PaddingTop: integer read FPaddingTop write FPaddingTop default 0;
    property ParentName: string read FParentName write FParentName;
    property Visible: boolean read FVisible write FVisible default true;
    property Width: integer read FWidth write FWidth default 0;
    // CaptionOptions comuni
    property ImageIndex: integer read FImageIndex write FImageIndex default -1;
    property VisibleElements: TdxLayoutItemCaptionVisibleElements read FVisibleElements write FVisibleElements default [cveImage, cveText];
    // TdxLayoutItem specifico
    property ItemCaptionLayout: TdxCaptionLayout read FItemCaptionLayout write FItemCaptionLayout default clTop;
    property ItemCaptionWidth: integer read FItemCaptionWidth write FItemCaptionWidth default 0;
    // TdxLayoutGroup specifico
    property GroupButtonOptionsAlignment: TdxLayoutGroupButtonsAlignment read FGroupButtonOptionsAlignment write FGroupButtonOptionsAlignment default gbaRight;
    property GroupButtonOptionsVisible: boolean read FGroupButtonOptionsVisible write FGroupButtonOptionsVisible default true;
    property GroupExpanded: boolean read FGroupExpanded write FGroupExpanded default true;
    property GroupHidden: boolean read FGroupHidden write FGroupHidden default False;
    property GroupHideTabs: boolean read FGroupHideTabs write FGroupHideTabs default true;
    property GroupItemControlAreaAlignment: TdxLayoutItemControlAreaAlignment read FGroupItemControlAreaAlignment write FGroupItemControlAreaAlignment default catDefault;
    property GroupItemIndex: integer read FGroupItemIndex write FGroupItemIndex default 0;
    property GroupLayoutDirection: TdxLayoutDirection read FGroupLayoutDirection write FGroupLayoutDirection default ldVertical;
    property GroupLayoutLookAndFeelException: boolean read FGroupLayoutLookAndFeelException write FGroupLayoutLookAndFeelException default False;
    property GroupLocked: boolean read FGroupLocked write FGroupLocked default False;
    property GroupShowBorder: boolean read FGroupShowBorder write FGroupShowBorder default False;
    property GroupShowExpandButton: boolean read FGroupShowExpandButton write FGroupShowExpandButton default False;
    property GroupShowTabFrame: boolean read FGroupShowTabFrame write FGroupShowTabFrame default False;
    property GroupTabbedHotTrack: boolean read FGroupTabbedHotTrack write FGroupTabbedHotTrack default False;
    property GroupTabbedMultiLine: boolean read FGroupTabbedMultiLine write FGroupTabbedMultiLine default False;
    property GroupTabbedRotate: boolean read FGroupTabbedRotate write FGroupTabbedRotate default False;
    property GroupTabbedTabHeight: integer read FGroupTabbedTabHeight write FGroupTabbedTabHeight default 0;
    property GroupTabbedTabPosition: TcxTabPosition read FGroupTabbedTabPosition write FGroupTabbedTabPosition default tpTop;
    property GroupTabbedTabWidth: integer read FGroupTabbedTabWidth write FGroupTabbedTabWidth default 0;
    property GroupUseIndent: boolean read FGroupUseIndent write FGroupUseIndent default true;
    property ScrollOptionsHorizontal: TdxLayoutGroupScrollMode read FScrollOptionsHorizontal write FScrollOptionsHorizontal default smNone;
    property ScrollOptionsVertical: TdxLayoutGroupScrollMode read FScrollOptionsVertical write FScrollOptionsVertical default smNone;
    // TdxLayoutSplitterItem specifico
    property SplitterAllowCloseOnClick: boolean read FSplitterAllowCloseOnClick write FSplitterAllowCloseOnClick default False;
    property SplitterIsClosed: boolean read FSplitterIsClosed write FSplitterIsClosed default False;
  end;

  TzLayoutItems = class(TzCollection<TzLayoutItem>)
  public
    // SkipGenerated = True (default): comportamento di TzDbCard. Gli item
    // generati dal controller (righe, riempitivi, campi) non vengono
    // serializzati perche' li rigenera BuildLayoutItems a ogni apertura.
    //
    // SkipGenerated = False: comportamento di TLayoutController
    // (zFormController). Li' gli item "generati" sono i gruppi strutturali
    // dei dataset (grpDataSet / Controls / Details), che sono proprio
    // l'oggetto della personalizzazione dell'amministratore: scartandoli si
    // perdeva a ogni salvataggio il LayoutDirection e ogni altra modifica.
    procedure LoadFromLayout(dxLayoutControl: TdxLayoutControl; const SkipGenerated: boolean = true);

    // ApplyToGenerated = True: applica padre e posizione anche agli item
    // generati dal controller. Serve a TLayoutController, dove la posizione
    // dei gruppi strutturali e' una scelta dell'amministratore. Per TzDbCard
    // resta False: li' il parenting e' di competenza di BuildLayoutItems.
    procedure SaveToLayout(dxLayoutControl: TdxLayoutControl; const ApplyToGenerated: boolean = False);
  end;

  TzLayout = class(TzCollectionItem)
  private
    FLayout: TzLayoutItems;
    FDesignWidth: integer;
    FDesignHeight: integer;
    procedure SetLayout(const Value: TzLayoutItems);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure DefaultProps;
  published
    property Layout: TzLayoutItems read FLayout write SetLayout;

    // Risoluzione per form 2026-09-22: dimensioni del monitor su cui QUESTA
    // form e' stata redatta, scritte da TLayoutController.SaveProps.
    // Servono a ScaleLayoutToMonitor per sapere rispetto a che cosa scalare:
    // prima si assumeva sempre 1920x1200 (costanti in zFormController), e una
    // form salvata da un monitor diverso arrivava al cliente scalata rispetto
    // a una base che non era la sua.
    //
    // La risoluzione sta QUI e non in un unico valore per tutto l'LZ perche'
    // form diverse dello stesso LZ possono essere state redatte su monitor
    // diversi: TzLayout e' l'unita' giusta, essendo indicizzata per nome del
    // controllo di layout (vedi TLayoutController.GetLayoutProps).
    //
    // default 0 = "non registrata": si ricade sulle costanti, cioe' sul
    // comportamento precedente. Nessuna regressione sull'LZ esistente, e le
    // form si allineano da sole man mano che vengono risalvate.
    property DesignWidth: integer read FDesignWidth write FDesignWidth default 0;
    property DesignHeight: integer read FDesignHeight write FDesignHeight default 0;
  end;

  TzLayouts = class(TzCollection<TzLayout>)
  end;

  TdxCustomLayoutItemHelper = class helper for TdxCustomLayoutItem
  public
    function ItemClassKind: TItemClassKind;
    procedure SetFlagSuperfluous(const Value: boolean);
    procedure SetFlagUserDefined(const Value: boolean);
    procedure zSetLoadedInfo(const AParentName: string; AIndex: integer);
  end;

  TdxLayoutContainerHelper = class helper for TdxLayoutContainer
  public
    procedure BeginLoading;
    procedure EndLoading;
  end;

  // =============================================================================
  // Sottoclassi marker dei TdxCustomLayoutItem
  //
  // Queste sottoclassi sono usate dal sistema per distinguere item creati dal
  // controller (TzDbCard, zFormController) da item user-defined nell'editor
  // visuale DevExpress. Il flag GeneratedByController = True viene settato
  // automaticamente sulle istanze di queste classi (vedi IsGeneratedByController).
  // =============================================================================

  TzDxLayoutGroup = class(TdxLayoutGroup)
  end;

  TzDxLayoutItem = class(TdxLayoutItem)
  end;

  // Sottoclasse marker per i campi data-aware il cui Width/Height sono DERIVATI
  // da TzControlProps (ColSpan via TzDbCard.BuildLayoutItems, Lines via
  // ResolveHeight). Per questi item:
  // - LoadFromLayout NON salva Width/Height (sarebbe duplicazione del ColSpan)
  // - SaveToLayout NON riapplica Width/Height (sovrascriverebbe i valori
  // appena calcolati da BuildLayoutItems)
  //
  // Da usare ESCLUSIVAMENTE in TzDbCard.BuildLayoutItems per i campi con
  // effectiveColSpan. NON usare in zFormController: lì gli item creati con
  // CreateLayoutItem hanno Width personalizzabili dall'admin via editor
  // visuale, e vanno serializzati nel TzLayout del DataModule.
  TzDxFieldLayoutItem = class(TzDxLayoutItem)
  end;

  // Sottoclasse marker per i TdxLayoutGroup creati da TzDbCard per i controlli
  // ctGroupBox/ctCheckGroupBox, il cui Width è DERIVATO da TzControlProps.Size
  // (assegnato in BuildLayoutItems, seconda passata). Stessa invariante di
  // TzDxFieldLayoutItem: Width/Height NON vengono serializzati, altrimenti
  // SaveToLayout sovrascriverebbe il peso appena calcolato e il cambio di
  // Size dal popup non avrebbe effetto finché esiste un layout salvato.
  // NON usare per le righe (EnsureRow/EnsureGroupRow): lì resta TzDxLayoutGroup.
  TzDxFieldLayoutGroup = class(TzDxLayoutGroup)
  end;

  TzDxLayoutSplitterItem = class(TdxLayoutSplitterItem)
  end;

  TzDxLayoutEmptySpaceItem = class(TdxLayoutEmptySpaceItem)
  end;

  TzDxLayoutSeparatorItem = class(TdxLayoutSeparatorItem)
  end;

  // =============================================================================
  // Strategy Pattern per il trasferimento dati TdxCustomLayoutItem <-> TzLayoutItem
  //
  // Ogni strategy gestisce le proprietà di un tipo specifico di layout item.
  // La strategy base (TzLayoutItemStrategy) gestisce le proprietà comuni
  // (AlignHorz/Vert, Caption, Width, Height, ecc.). Le sottoclassi specializzate
  // chiamano inherited e poi aggiungono le proprietà type-specific.
  //
  // Dispatch: GetStrategyFor(dxItem) ritorna la strategy giusta in base al
  // tipo runtime del dxItem.
  //
  // Le strategy sono stateless e vivono come singleton globali (istanziate
  // in initialization, distrutte in finalization).
  // =============================================================================

  TzLayoutItemStrategy = class
  public
    // Trasferisce proprietà da dxItem a target (caso lettura).
    procedure LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem); virtual;
    // Trasferisce proprietà da source a dxItem (caso scrittura).
    procedure SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem); virtual;
  end;

  // Strategy per TdxLayoutItem e sottoclassi (TzDxLayoutItem, TzDxFieldLayoutItem).
  // Per i TzDxFieldLayoutItem applica l'invariante di non-serializzazione di
  // Width/Height (vedi commento sopra TzDxFieldLayoutItem).
  TzLayoutItemFieldStrategy = class(TzLayoutItemStrategy)
  public
    procedure LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem); override;
    procedure SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem); override;
  end;

  // Strategy per TdxLayoutLabeledItem (e sottoclassi).
  TzLayoutItemLabeledStrategy = class(TzLayoutItemStrategy)
  public
    procedure LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem); override;
    procedure SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem); override;
  end;

  // Strategy per TdxLayoutGroup (e sottoclassi, es. TzDxLayoutGroup).
  TzLayoutItemGroupStrategy = class(TzLayoutItemStrategy)
  public
    procedure LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem); override;
    procedure SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem); override;
  end;

  // Strategy per TdxLayoutSplitterItem (e sottoclassi, es. TzDxLayoutSplitterItem).
  TzLayoutItemSplitterStrategy = class(TzLayoutItemStrategy)
  public
    procedure LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem); override;
    procedure SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem); override;
    // Riapplica l'allineamento del record secondo la direzione attuale del
    // gruppo padre: TzLayoutItems.AssignTo la richiama quando tutti i gruppi
    // hanno ricevuto la loro direzione.
    procedure NormalizzaAllineamento(Splitter: TdxLayoutSplitterItem; Source: TzLayoutItem);
  end;

function IsGeneratedByController(dxLayoutItem: TdxCustomLayoutItem): boolean;

// Ritorna la strategy adatta al tipo runtime del dxItem.
// L'ordine dei test è importante: le sottoclassi specifiche (Group, Splitter,
// Labeled) sono testate PRIMA di TdxLayoutItem perché alcune potrebbero
// teoricamente ereditare da TdxLayoutItem (oggi non è il caso ma è una
// pratica difensiva).
function GetStrategyFor(dxItem: TdxCustomLayoutItem): TzLayoutItemStrategy;

implementation

// ============================================================================
// Helpers globali
// ============================================================================

function IsGeneratedByController(dxLayoutItem: TdxCustomLayoutItem): boolean;
begin
  Assert(assigned(dxLayoutItem));

  result := (dxLayoutItem is TzDxLayoutItem) or (dxLayoutItem is TzDxLayoutGroup) or (dxLayoutItem is TzDxLayoutSplitterItem) or (dxLayoutItem is TzDxLayoutEmptySpaceItem) or (dxLayoutItem is TzDxLayoutSeparatorItem);
end;

// ============================================================================
// TzLayoutItem
// ============================================================================

constructor TzLayoutItem.Create(Collection: TCollection);
begin
  inherited;
  // base
  FGeneratedByController := False;
  FItemClassKind := ickLayoutItem;
  FIsUserDefined := False;
  FIdx := 0;
  FAlignHorz := ahParentManaged;
  FAlignVert := avParentManaged;
  FWidth := 0;
  FHeight := 0;
  FCaption := '';
  FCaptionVisible := true;
  FCaptionAlignHorz := taLeftJustify;
  FCaptionAlignVert := TdxAlignmentVert.tavCenter;
  FEnabled := true;
  FVisible := true;
  FOffsetLeft := 0;
  FOffsetTop := 0;
  FOffsetRight := 0;
  FOffsetBottom := 0;
  FPaddingLeft := 0;
  FPaddingTop := 0;
  FPaddingRight := 0;
  FPaddingBottom := 0;
  FParentName := '';
  // CaptionOptions comuni
  FImageIndex := -1;
  FVisibleElements := [cveImage, cveText];
  // TdxLayoutItem specifico
  FItemCaptionLayout := clTop;
  FItemCaptionWidth := 0;
  // TdxLayoutGroup specifico
  FGroupHidden := False;
  FGroupLayoutDirection := ldVertical;
  FGroupExpanded := true;
  FGroupShowBorder := False;
  FGroupHideTabs := true;
  FGroupShowTabFrame := False;
  FGroupShowExpandButton := False;
  FGroupButtonOptionsAlignment := gbaRight;
  FGroupButtonOptionsVisible := true;
  FGroupItemIndex := 0;
  FGroupUseIndent := true;
  FGroupLocked := False;
  FGroupLayoutLookAndFeelException := False;
  FGroupItemControlAreaAlignment := catDefault;
  FGroupTabbedTabPosition := tpTop;
  FGroupTabbedMultiLine := False;
  FGroupTabbedRotate := False;
  FGroupTabbedTabHeight := 0;
  FGroupTabbedTabWidth := 0;
  FGroupTabbedHotTrack := False;
  FScrollOptionsHorizontal := smNone;
  FScrollOptionsVertical := smNone;
  // TdxLayoutSplitterItem specifico
  FSplitterAllowCloseOnClick := False;
  FSplitterIsClosed := False;
end;

procedure TzLayoutItem.Assign(Source: TPersistent);
var
  ItemProps: TzLayoutItem;
begin
  if Source is TzLayoutItem then
  begin
    ItemProps := TzLayoutItem(Source);
    // base
    Name := ItemProps.Name;
    ItemClassKind := ItemProps.ItemClassKind;
    IsUserDefined := ItemProps.IsUserDefined;
    Idx := ItemProps.Idx;
    AlignHorz := ItemProps.AlignHorz;
    AlignVert := ItemProps.AlignVert;
    Width := ItemProps.Width;
    Height := ItemProps.Height;
    Caption := ItemProps.Caption;
    CaptionVisible := ItemProps.CaptionVisible;
    CaptionAlignHorz := ItemProps.CaptionAlignHorz;
    CaptionAlignVert := ItemProps.CaptionAlignVert;
    Enabled := ItemProps.Enabled;
    Visible := ItemProps.Visible;
    OffsetLeft := ItemProps.OffsetLeft;
    OffsetTop := ItemProps.OffsetTop;
    OffsetRight := ItemProps.OffsetRight;
    OffsetBottom := ItemProps.OffsetBottom;
    PaddingLeft := ItemProps.PaddingLeft;
    PaddingTop := ItemProps.PaddingTop;
    PaddingRight := ItemProps.PaddingRight;
    PaddingBottom := ItemProps.PaddingBottom;
    ParentName := ItemProps.ParentName;
    GeneratedByController := ItemProps.GeneratedByController;
    // CaptionOptions comuni
    ImageIndex := ItemProps.ImageIndex;
    VisibleElements := ItemProps.VisibleElements;
    // TdxLayoutItem specifico
    ItemCaptionLayout := ItemProps.ItemCaptionLayout;
    ItemCaptionWidth := ItemProps.ItemCaptionWidth;
    // TdxLayoutGroup specifico
    GroupHidden := ItemProps.GroupHidden;
    GroupLayoutDirection := ItemProps.GroupLayoutDirection;
    GroupExpanded := ItemProps.GroupExpanded;
    GroupShowBorder := ItemProps.GroupShowBorder;
    GroupHideTabs := ItemProps.GroupHideTabs;
    GroupShowTabFrame := ItemProps.GroupShowTabFrame;
    GroupShowExpandButton := ItemProps.GroupShowExpandButton;
    GroupButtonOptionsAlignment := ItemProps.GroupButtonOptionsAlignment;
    GroupButtonOptionsVisible := ItemProps.GroupButtonOptionsVisible;
    GroupItemIndex := ItemProps.GroupItemIndex;
    GroupUseIndent := ItemProps.GroupUseIndent;
    GroupLocked := ItemProps.GroupLocked;
    GroupLayoutLookAndFeelException := ItemProps.GroupLayoutLookAndFeelException;
    GroupItemControlAreaAlignment := ItemProps.GroupItemControlAreaAlignment;
    GroupTabbedTabPosition := ItemProps.GroupTabbedTabPosition;
    GroupTabbedMultiLine := ItemProps.GroupTabbedMultiLine;
    GroupTabbedRotate := ItemProps.GroupTabbedRotate;
    GroupTabbedTabHeight := ItemProps.GroupTabbedTabHeight;
    GroupTabbedTabWidth := ItemProps.GroupTabbedTabWidth;
    GroupTabbedHotTrack := ItemProps.GroupTabbedHotTrack;
    ScrollOptionsHorizontal := ItemProps.ScrollOptionsHorizontal;
    ScrollOptionsVertical := ItemProps.ScrollOptionsVertical;
    // TdxLayoutSplitterItem specifico
    SplitterAllowCloseOnClick := ItemProps.SplitterAllowCloseOnClick;
    SplitterIsClosed := ItemProps.SplitterIsClosed;
  end
  else
    inherited;
end;

function TzLayoutItem.GetDisplayName: string;
begin
  result := Name;
end;

// ============================================================================
// TzLayoutItemStrategy (base)
//
// Gestisce le proprietà comuni a tutti i TdxCustomLayoutItem.
// Le sottoclassi chiamano "inherited" prima di aggiungere proprietà type-specific.
// ============================================================================

procedure TzLayoutItemStrategy.LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem);
begin
  // base (tutti gli item)
  target.Name := dxItem.Name;
  target.ItemClassKind := dxItem.ItemClassKind;
  target.IsUserDefined := dxItem.IsUserDefined;
  target.AlignHorz := dxItem.AlignHorz;
  target.AlignVert := dxItem.AlignVert;
  target.Caption := dxItem.Caption;
  target.CaptionVisible := dxItem.CaptionOptions.Visible;
  target.CaptionAlignHorz := dxItem.CaptionOptions.AlignHorz;
  target.CaptionAlignVert := dxItem.CaptionOptions.AlignVert;
  target.Enabled := dxItem.Enabled;
  target.Visible := dxItem.Visible;
  target.GeneratedByController := IsGeneratedByController(dxItem);

  if dxItem.Parent <> nil then
  begin
    target.ParentName := dxItem.Parent.Name;
    target.Idx := dxItem.Index;
  end
  else
  begin
    target.ParentName := '';
    target.Idx := -1;
  end;

  // Width/Height: la strategy base li scrive sempre. Le sottoclassi che
  // hanno una regola particolare (es. TzLayoutItemFieldStrategy per i
  // TzDxFieldLayoutItem) sovrascrivono dopo aver chiamato inherited.
  target.Width := dxItem.Width;
  target.Height := dxItem.Height;
end;

procedure TzLayoutItemStrategy.SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem);
begin
  // base (tutti gli item)
  dxItem.AlignHorz := Source.AlignHorz;
  dxItem.AlignVert := Source.AlignVert;
  dxItem.Caption := Source.Caption;
  dxItem.CaptionOptions.Visible := Source.CaptionVisible;
  dxItem.CaptionOptions.AlignHorz := Source.CaptionAlignHorz;
  dxItem.CaptionOptions.AlignVert := Source.CaptionAlignVert;
  dxItem.Enabled := Source.Enabled;
  dxItem.Visible := Source.Visible;

  // Width/Height: come sopra. Vedi TzLayoutItemFieldStrategy.SaveTo per
  // il caso particolare dei TzDxFieldLayoutItem.
  dxItem.Width := Source.Width;
  dxItem.Height := Source.Height;
end;

// ============================================================================
// TzLayoutItemFieldStrategy
//
// Per TdxLayoutItem e tutte le sottoclassi (TzDxLayoutItem, TzDxFieldLayoutItem).
// Aggiunge le proprietà CaptionOptions extended e Padding.
//
// REGOLA DI INVARIANTE — TzDxFieldLayoutItem:
// Per i campi data-aware (istanze di TzDxFieldLayoutItem) Width/Height sono
// derivati da TzControlProps e non vanno serializzati. La strategy:
// - in LoadFrom azzera Width/Height dopo che inherited li ha assegnati
// - in SaveTo preserva i Width/Height pre-esistenti (assegnati da
// BuildLayoutItems come effectiveColSpan/ResolveHeight) usando un
// pattern save/restore intorno a inherited
// ============================================================================

procedure TzLayoutItemFieldStrategy.LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem);
var
  fld: TdxLayoutItem;
begin
  inherited;

  // Invariante: Width/Height dei campi data-aware sono derivati da TzControlProps
  if dxItem is TzDxFieldLayoutItem then
  begin
    target.Width := 0;
    target.Height := 0;
  end;

  fld := TdxLayoutItem(dxItem);
  // Campi: l'icona non si salva (vedi SaveTo)
  if dxItem is TzDxFieldLayoutItem then
    target.ImageIndex := -1
  else
    target.ImageIndex := fld.CaptionOptions.ImageIndex;
  target.VisibleElements := fld.CaptionOptions.VisibleElements;
  target.ItemCaptionLayout := fld.CaptionOptions.Layout;
  target.ItemCaptionWidth := fld.CaptionOptions.Width;
  target.PaddingLeft := fld.Padding.Left;
  target.PaddingTop := fld.Padding.Top;
  target.PaddingRight := fld.Padding.Right;
  target.PaddingBottom := fld.Padding.Bottom;
end;

procedure TzLayoutItemFieldStrategy.SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem);
var
  fld: TdxLayoutItem;
  preservedWidth, preservedHeight: integer;
  isField: boolean;
begin
  // Invariante: per i TzDxFieldLayoutItem, dxItem.Width/Height sono già stati
  // assegnati da BuildLayoutItems (peso da Size / ResolveHeight). inherited
  // li sovrascriverebbe con source.Width=0/source.Height=0. Preserviamo i
  // valori CORRENTI (che sono i valori configurati appena calcolati, non
  // misure renderizzate: dxItem.Height mappa su SizeOptions.Height).
  isField := dxItem is TzDxFieldLayoutItem;
  if isField then
  begin
    preservedWidth := dxItem.Width;
    preservedHeight := dxItem.Height;
  end
  else
  begin
    preservedWidth := 0; // unused
    preservedHeight := 0; // unused
  end;

  inherited;

  if isField then
  begin
    dxItem.Width := preservedWidth;
    dxItem.Height := preservedHeight;
  end;

  fld := TdxLayoutItem(dxItem);
  // Campi: l'icona viene da TzControlProps.ImageName (BuildLayoutItems), come
  // Width e Height; un layout salvato con -1 la cancellerebbe.
  if not isField then
    fld.CaptionOptions.ImageIndex := Source.ImageIndex;
  fld.CaptionOptions.VisibleElements := Source.VisibleElements;
  fld.CaptionOptions.Layout := Source.ItemCaptionLayout;
  fld.CaptionOptions.Width := Source.ItemCaptionWidth;
  fld.Padding.Left := Source.PaddingLeft;
  fld.Padding.Top := Source.PaddingTop;
  fld.Padding.Right := Source.PaddingRight;
  fld.Padding.Bottom := Source.PaddingBottom;
end;

// ============================================================================
// TzLayoutItemLabeledStrategy
//
// Per TdxLayoutLabeledItem. Solo ImageIndex/VisibleElements oltre alla base.
// ============================================================================

procedure TzLayoutItemLabeledStrategy.LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem);
var
  lbl: TdxCustomLayoutLabeledItem;
begin
  inherited;
  lbl := TdxCustomLayoutLabeledItem(dxItem);
  target.ImageIndex := lbl.CaptionOptions.ImageIndex;
  target.VisibleElements := lbl.CaptionOptions.VisibleElements;
end;

procedure TzLayoutItemLabeledStrategy.SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem);
var
  lbl: TdxCustomLayoutLabeledItem;
begin
  inherited;
  lbl := TdxCustomLayoutLabeledItem(dxItem);
  lbl.CaptionOptions.ImageIndex := Source.ImageIndex;
  lbl.CaptionOptions.VisibleElements := Source.VisibleElements;
end;

// ============================================================================
// TzLayoutItemGroupStrategy
//
// Per TdxLayoutGroup (e sottoclassi come TzDxLayoutGroup). Tutte le GroupXxx
// properties, Offsets, Padding, ScrollOptions, CaptionOptions.
// ============================================================================

procedure TzLayoutItemGroupStrategy.LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem);
var
  grp: TdxLayoutGroup;
begin
  inherited;

  // Invariante: Width/Height dei gruppi derivati da TzControlProps.Size
  // (ctGroupBox/ctCheckGroupBox) non vanno serializzati: la loro geometria è
  // funzione di Size (Width via BuildLayoutItems) e del contenuto (Height).
  // Vedi TzDxFieldLayoutGroup.
  if dxItem is TzDxFieldLayoutGroup then
  begin
    target.Width := 0;
    target.Height := 0;
  end;

  grp := TdxLayoutGroup(dxItem);

  target.GroupHidden := grp.Hidden;
  target.GroupLayoutDirection := grp.LayoutDirection;
  target.GroupExpanded := grp.Expanded;
  target.GroupShowBorder := grp.ShowBorder;
  target.GroupHideTabs := grp.TabbedOptions.HideTabs;
  target.GroupShowTabFrame := grp.TabbedOptions.ShowFrame;
  target.GroupShowExpandButton := grp.ButtonOptions.ShowExpandButton;
  target.GroupButtonOptionsAlignment := grp.ButtonOptions.Alignment;
  target.GroupButtonOptionsVisible := grp.ButtonOptions.Visible;
  target.GroupItemIndex := grp.ItemIndex;
  target.GroupUseIndent := grp.UseIndent;
  target.GroupLocked := grp.Locked;
  target.GroupLayoutLookAndFeelException := grp.LayoutLookAndFeelException;
  target.GroupItemControlAreaAlignment := grp.ItemControlAreaAlignment;
  target.GroupTabbedTabPosition := grp.TabbedOptions.TabPosition;
  target.GroupTabbedMultiLine := grp.TabbedOptions.MultiLine;
  target.GroupTabbedRotate := grp.TabbedOptions.Rotate;
  target.GroupTabbedTabHeight := grp.TabbedOptions.TabHeight;
  target.GroupTabbedTabWidth := grp.TabbedOptions.TabWidth;
  target.GroupTabbedHotTrack := grp.TabbedOptions.HotTrack;
  if dxItem is TzDxFieldLayoutGroup then
    target.ImageIndex := -1
  else
    target.ImageIndex := grp.CaptionOptions.ImageIndex;
  target.VisibleElements := grp.CaptionOptions.VisibleElements;
  target.ScrollOptionsHorizontal := grp.ScrollOptions.Horizontal;
  target.ScrollOptionsVertical := grp.ScrollOptions.Vertical;
  target.OffsetLeft := grp.Offsets.Left;
  target.OffsetTop := grp.Offsets.Top;
  target.OffsetRight := grp.Offsets.Right;
  target.OffsetBottom := grp.Offsets.Bottom;
  target.PaddingLeft := grp.Padding.Left;
  target.PaddingTop := grp.Padding.Top;
  target.PaddingRight := grp.Padding.Right;
  target.PaddingBottom := grp.Padding.Bottom;
end;

procedure TzLayoutItemGroupStrategy.SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem);
var
  grp: TdxLayoutGroup;
  preservedWidth, preservedHeight: integer;
  preservedShowExpand, preservedExpanded: boolean;
  preservedImageIndex: integer;
  isFieldGroup: boolean;
begin
  // Invariante: per i TzDxFieldLayoutGroup, Width/Height sono già stati
  // assegnati da BuildLayoutItems (peso da Size; altezza dal contenuto).
  // inherited li sovrascriverebbe col valore serializzato (stantio).
  // dxItem.Width/Height mappano su SizeOptions (valore configurato), quindi
  // preservare i valori correnti è corretto.
  // Stessa regola per ShowExpandButton/Expanded: per i gruppi derivati da
  // ctGroupBox la fonte di verità è TzControlProps (GroupExpandButton /
  // GroupExpanded, applicati da BuildLayoutItems); un blob legacy che
  // contenesse ancora i grp_* non deve azzerarli.
  isFieldGroup := dxItem is TzDxFieldLayoutGroup;
  if isFieldGroup then
  begin
    preservedWidth := dxItem.Width;
    preservedHeight := dxItem.Height;
    preservedShowExpand := TdxLayoutGroup(dxItem).ButtonOptions.ShowExpandButton;
    preservedExpanded := TdxLayoutGroup(dxItem).Expanded;
    preservedImageIndex := TdxLayoutGroup(dxItem).CaptionOptions.ImageIndex;
  end
  else
  begin
    preservedWidth := 0; // unused
    preservedHeight := 0; // unused
    preservedShowExpand := False; // unused
    preservedExpanded := true; // unused
    preservedImageIndex := -1; // unused
  end;

  inherited;

  if isFieldGroup then
  begin
    // Ripristina la geometria calcolata da BuildLayoutItems (peso da Size,
    // altezza dal contenuto): un blob legacy non deve sovrascriverla.
    dxItem.Width := preservedWidth;
    dxItem.Height := preservedHeight;
  end;

  grp := TdxLayoutGroup(dxItem);

  grp.Hidden := Source.GroupHidden;
  grp.Expanded := Source.GroupExpanded;
  grp.ShowBorder := Source.GroupShowBorder;
  grp.TabbedOptions.HideTabs := Source.GroupHideTabs;
  grp.TabbedOptions.ShowFrame := Source.GroupShowTabFrame;
  grp.LayoutDirection := Source.GroupLayoutDirection;
  grp.ButtonOptions.ShowExpandButton := Source.GroupShowExpandButton;
  grp.ButtonOptions.Alignment := Source.GroupButtonOptionsAlignment;
  grp.ButtonOptions.Visible := Source.GroupButtonOptionsVisible;
  grp.ItemIndex := Source.GroupItemIndex;
  grp.UseIndent := Source.GroupUseIndent;
  grp.Locked := Source.GroupLocked;
  grp.LayoutLookAndFeelException := Source.GroupLayoutLookAndFeelException;
  grp.ItemControlAreaAlignment := Source.GroupItemControlAreaAlignment;
  grp.TabbedOptions.TabPosition := Source.GroupTabbedTabPosition;
  grp.TabbedOptions.MultiLine := Source.GroupTabbedMultiLine;
  grp.TabbedOptions.Rotate := Source.GroupTabbedRotate;
  grp.TabbedOptions.TabHeight := Source.GroupTabbedTabHeight;
  grp.TabbedOptions.TabWidth := Source.GroupTabbedTabWidth;
  grp.TabbedOptions.HotTrack := Source.GroupTabbedHotTrack;
  grp.CaptionOptions.ImageIndex := Source.ImageIndex;
  grp.CaptionOptions.VisibleElements := Source.VisibleElements;
  grp.ScrollOptions.Horizontal := Source.ScrollOptionsHorizontal;
  grp.ScrollOptions.Vertical := Source.ScrollOptionsVertical;
  grp.Offsets.Left := Source.OffsetLeft;
  grp.Offsets.Top := Source.OffsetTop;
  grp.Offsets.Right := Source.OffsetRight;
  grp.Offsets.Bottom := Source.OffsetBottom;
  grp.Padding.Left := Source.PaddingLeft;
  grp.Padding.Top := Source.PaddingTop;
  grp.Padding.Right := Source.PaddingRight;
  grp.Padding.Bottom := Source.PaddingBottom;

  // Ripristino per i gruppi derivati (vedi commento in testa): lo stato di
  // collasso vive in TzControlProps, non nel Layout serializzato.
  if isFieldGroup then
  begin
    grp.ButtonOptions.ShowExpandButton := preservedShowExpand;
    grp.Expanded := preservedExpanded;
    // Icona: viene da TzControlProps.ImageName (BuildLayoutItems)
    grp.CaptionOptions.ImageIndex := preservedImageIndex;
  end;
end;

// ============================================================================
// TzLayoutItemSplitterStrategy
//
// Per TdxLayoutSplitterItem (e sottoclassi come TzDxLayoutSplitterItem).
// AllowCloseOnClick, IsClosed.
//
// Invariante: uno splitter non ha dimensioni proprie (lo spessore lo decide il
// look and feel) e lungo la direzione del gruppo padre non deve mai essere
// allineato "client", altrimenti DevExpress gli assegna lo spazio libero come
// a un item qualunque e appare una fascia larga. Il record LZ quindi non
// conserva Width/Height e l'allineamento viene normalizzato sia in scrittura
// (LoadFrom) sia in rilettura (SaveTo), cosi' i record gia' salvati diventano innocui.
// ============================================================================

procedure TzLayoutItemSplitterStrategy.LoadFrom(dxItem: TdxCustomLayoutItem; target: TzLayoutItem);
var
  Splitter: TdxLayoutSplitterItem;
begin
  inherited;
  Splitter := TdxLayoutSplitterItem(dxItem);
  target.SplitterAllowCloseOnClick := Splitter.AllowCloseOnClick;
  target.SplitterIsClosed := Splitter.IsClosed;

  // nessuna dimensione propria da conservare
  target.Width := 0;
  target.Height := 0;

  // mai "client" lungo l'asse del gruppo padre
  if Assigned(Splitter.Parent) then
    if Splitter.Parent.LayoutDirection = ldHorizontal then
    begin
      if target.AlignHorz in [ahClient, ahParentManaged] then
        target.AlignHorz := ahLeft;
    end
    else
      if target.AlignVert in [avClient, avParentManaged] then
        target.AlignVert := avTop;
end;

procedure TzLayoutItemSplitterStrategy.SaveTo(dxItem: TdxCustomLayoutItem; Source: TzLayoutItem);
var
  Splitter: TdxLayoutSplitterItem;
begin
  inherited;
  Splitter := TdxLayoutSplitterItem(dxItem);
  Splitter.AllowCloseOnClick := Source.SplitterAllowCloseOnClick;
  Splitter.IsClosed := Source.SplitterIsClosed;

  // la strategia base ha appena riapplicato Width/Height/Align dal record:
  // per uno splitter vanno riportati ai valori canonici
  Splitter.SizeOptions.Width := 0;
  Splitter.SizeOptions.Height := 0;

  NormalizzaAllineamento(Splitter, Source);
end;

procedure TzLayoutItemSplitterStrategy.NormalizzaAllineamento(Splitter: TdxLayoutSplitterItem; Source: TzLayoutItem);
begin
  // si riparte dal record: una normalizzazione fatta prima, con il padre non
  // ancora configurato, puo' aver forzato l'asse sbagliato
  Splitter.AlignHorz := Source.AlignHorz;
  Splitter.AlignVert := Source.AlignVert;

  if Assigned(Splitter.Parent) then
    if Splitter.Parent.LayoutDirection = ldHorizontal then
    begin
      if Splitter.AlignHorz in [ahClient, ahParentManaged] then
        Splitter.AlignHorz := ahLeft;
    end
    else
      if Splitter.AlignVert in [avClient, avParentManaged] then
        Splitter.AlignVert := avTop;
end;

// ============================================================================
// Strategy singletons + dispatch
// ============================================================================

var
  DefaultStrategy: TzLayoutItemStrategy;
  FieldStrategy: TzLayoutItemFieldStrategy;
  LabeledStrategy: TzLayoutItemLabeledStrategy;
  GroupStrategy: TzLayoutItemGroupStrategy;
  SplitterStrategy: TzLayoutItemSplitterStrategy;

function GetStrategyFor(dxItem: TdxCustomLayoutItem): TzLayoutItemStrategy;
begin
  // Ordine importante: le sottoclassi specifiche prima di TdxLayoutItem.
  if dxItem is TdxLayoutGroup then
    result := GroupStrategy
  else
    if dxItem is TdxLayoutSplitterItem then
      result := SplitterStrategy
    else
      if dxItem is TdxLayoutLabeledItem then
        result := LabeledStrategy
      else
        if dxItem is TdxLayoutItem then
          // Cattura TdxLayoutItem, TzDxLayoutItem, TzDxFieldLayoutItem.
          // L'invariante TzDxFieldLayoutItem è gestita dentro FieldStrategy.
          result := FieldStrategy
        else
          // EmptySpaceItem, SeparatorItem, e altri item senza proprietà extra.
          result := DefaultStrategy;
end;

// ============================================================================
// TzLayoutItems
// ============================================================================

procedure TzLayoutItems.LoadFromLayout(dxLayoutControl: TdxLayoutControl; const SkipGenerated: boolean = true);
var
  i: integer;
  dxItem: TdxCustomLayoutItem;
  target: TzLayoutItem;
begin
  if not assigned(dxLayoutControl) then
    Exit;

  Clear;
  for i := 0 to dxLayoutControl.Container.AbsoluteItemCount - 1 do
  begin
    dxItem := dxLayoutControl.Container.AbsoluteItems[i];

    // Con SkipGenerated (caso TzDbCard) persiste SOLO le personalizzazioni
    // utente: gli item generati dal controller (righe row_*/grprow_*, filler
    // *fill_*, campi li_*, gruppi grp_* da ctGroupBox) sono funzione di Size +
    // larghezza corrente e li rigenera BuildLayoutItems. Serializzarli
    // congelava la disposizione alla larghezza di cattura (filler dentro le
    // righe, mancato collasso allargando) e gonfiava il blob. Scartandoli qui,
    // i Layout gia' salvati si auto-ripuliscono al primo sync.
    //
    // Senza SkipGenerated (caso TLayoutController) vengono invece salvati
    // tutti: li' i "generati" sono i gruppi strutturali dei dataset, cioe'
    // l'oggetto stesso della personalizzazione.
    if SkipGenerated then
      if IsGeneratedByController(dxItem) then
        Continue;

    target := Add;
    GetStrategyFor(dxItem).LoadFrom(dxItem, target);
  end;
end;

procedure TzLayoutItems.SaveToLayout(dxLayoutControl: TdxLayoutControl; const ApplyToGenerated: boolean = False);

  function GetParent(const ParentName: string): TdxLayoutGroup;
  var
    dxItem: TdxCustomLayoutItem;
  begin
    result := nil;
    if ParentName = '' then
      Exit;

    dxItem := dxLayoutControl.FindItem(ParentName);
    if assigned(dxItem) then
      if dxItem is TdxLayoutGroup then
        result := dxItem as TdxLayoutGroup;
  end;

  function VerifyParentName(const ParentName: string): boolean;
  begin
    result := assigned(GetParent(ParentName));
    if not result then
      siMain.LogString('VerifyParentName=False', ParentName);
  end;

  function GetItemClass(Item: TzLayoutItem): TdxCustomLayoutItemClass;
  begin
    result := nil;
    case Item.ItemClassKind of
      ickLayoutItem:
        result := TdxLayoutItem;
      ickLayoutGroup:
        result := TdxLayoutGroup;
      ickLayoutEmptySpaceItem:
        result := TdxLayoutEmptySpaceItem;
      ickLayoutSeparatorItem:
        result := TdxLayoutSeparatorItem;
      ickLayoutSplitterItem:
        // Classe base, non TzDxLayoutSplitterItem: qui arrivano solo i record
        // dell'utente (gli splitter del controller li crea CreateSplitter).
        // Con la classe Tz* LoadFromLayout marcava il record GeneratedByController
        // al primo salvataggio e alla riapertura dopo lo splitter non veniva
        // piu' creato (stesso motivo delle classi base di zDfmLayoutArranger v9).
        result := TdxLayoutSplitterItem;
      ickLayoutLabeledItem:
        result := TdxLayoutLabeledItem;
    end;
  end;

  procedure AssignParentAndIndex(dxLayoutItem: TdxCustomLayoutItem; Item: TzLayoutItem);
  var
    parentGrp: TdxLayoutGroup;
    PadreDichiaratoAssente: boolean;
  begin
    // Mantis #128 - 2026-09-17: distinguo il record senza padre (ParentName vuoto,
    // legittimamente alla radice) dal record con un padre dichiarato che non esiste
    // in questa sessione (gruppo di un dataset a cui l'utente non ha accesso).
    PadreDichiaratoAssente := False;

    if Item.ParentName <> '' then
      if not VerifyParentName(Item.ParentName) then
      begin
        PadreDichiaratoAssente := True;
        Item.ParentName := '';
      end;

    parentGrp := GetParent(Item.ParentName);

    // Fallback anti-orfani: se il parent salvato non esiste più (es. righe
    // rinominate dopo un cambio struttura), gli item USER-DEFINED finiscono
    // in coda al gruppo radice invece che orfani invisibili (il caso dei
    // gruppi con ParentName='' / Idx=-1 sanato da RepairLayout).
    // Gli item generati dal controller restano di competenza di
    // BuildLayoutItems: per loro nessun reparenting.
    if (not assigned(parentGrp)) and (not Item.GeneratedByController) then
    begin
      parentGrp := dxLayoutControl.Items;

      // Mantis #128 - 2026-09-17: il gruppo padre manca perche' il suo dataset non
      // e' accessibile all'utente (CreateLayoutStructure non lo crea). La voce
      // resta alla radice per non andare persa, ma nascosta: lasciata visibile e
      // ahClient si prendeva meta' larghezza accanto a OGNI pagina della form
      // (pannello filtri layoutCP1 di frmRisorse mostrato in Elenco Incarichi).
      if PadreDichiaratoAssente then
      begin
        dxLayoutItem.Visible := False;
        siMain.LogString('AssignParentAndIndex: gruppo padre assente, voce nascosta', dxLayoutItem.Name);
      end;
    end;

    if not assigned(parentGrp) then
    begin
      dxLayoutItem.zSetLoadedInfo('', -1);
      Exit;
    end;

    dxLayoutItem.zSetLoadedInfo(parentGrp.Name, Item.Idx);
    dxLayoutItem.Parent := parentGrp;

    // Idx = -1 (info di posizione assente): resta in coda al parent
    if Item.Idx >= 0 then
      if Item.Idx < parentGrp.count then
        dxLayoutItem.Index := Item.Idx
      else
        dxLayoutItem.Index := parentGrp.count - 1;
  end;

var
  dxLayoutItem: TdxCustomLayoutItem;
  Superfluous: boolean;
  Item: TzLayoutItem;
begin
  if not assigned(dxLayoutControl) then
    Exit;

  if count = 0 then
    Exit;

  if dxLayoutControl.Container.AbsoluteItemCount = 0 then
    Exit;

  // Primo giro: crea eventuali item mancanti (gruppi user-defined, splitter, ecc.)
  for Item in self do
  begin
    Superfluous := False;
    dxLayoutItem := dxLayoutControl.FindItem(Item.Name);

    if not assigned(dxLayoutItem) then
      if not Item.GeneratedByController then
      begin
        siMain.LogString('AssignTo.CreateItem', Item.Name);
        dxLayoutItem := dxLayoutControl.CreateItem(GetItemClass(Item));
        dxLayoutItem.Name := Item.Name;
        Superfluous := not Item.IsUserDefined;

        // Uno splitter non ha dimensioni proprie ne' puo' essere ridimensionato
        // dall'editor: stesse impostazioni di TLayoutController.CreateSplitter.
        if dxLayoutItem is TdxLayoutSplitterItem then
        begin
          dxLayoutItem.SizeOptions.SizableHorz := False;
          dxLayoutItem.SizeOptions.SizableVert := False;
          dxLayoutItem.SizeOptions.Width := 0;
          dxLayoutItem.SizeOptions.Height := 0;
        end;
      end;

    if assigned(dxLayoutItem) then
      dxLayoutItem.SetFlagSuperfluous(Superfluous);
  end;

  // Secondo giro: assegna parent/index, poi delega alla strategy per le proprieta'.
  // Con ApplyToGenerated = False (TzDbCard) il parenting degli item generati dal
  // controller resta di competenza di BuildLayoutItems: NON va sovrascritto dalla
  // struttura salvata, altrimenti la disposizione fresca (per la larghezza
  // corrente) verrebbe riportata a quella congelata nel Layout.
  // Con ApplyToGenerated = True (TLayoutController) vale l'opposto: la posizione
  // dei gruppi strutturali e' una scelta dell'amministratore e va riapplicata.
  for Item in self do
  begin
    dxLayoutItem := dxLayoutControl.FindItem(Item.Name);
    if assigned(dxLayoutItem) then
    begin
      if (not Item.GeneratedByController) or ApplyToGenerated then
        AssignParentAndIndex(dxLayoutItem, Item);
      GetStrategyFor(dxLayoutItem).SaveTo(dxLayoutItem, Item);
    end;
  end;

  // Allineamento degli splitter con la direzione definitiva dei gruppi padre.
  // Nel secondo giro uno splitter il cui record precede quello del gruppo padre
  // trovava il gruppo appena creato, ancora verticale (direzione predefinita):
  // in un gruppo poi orizzontale restava avTop, cioe' una barra alta 0 che
  // nemmeno l'utente puo' spostare (TFormAziende.dxLayoutSplitterAziendeDetails).
  for Item in self do
  begin
    dxLayoutItem := dxLayoutControl.FindItem(Item.Name);
    if dxLayoutItem is TdxLayoutSplitterItem then
      SplitterStrategy.NormalizzaAllineamento(TdxLayoutSplitterItem(dxLayoutItem), Item);
  end;

  // Terzo giro: marca UserDefined gli item senza Control associato
  for Item in self do
  begin
    dxLayoutItem := dxLayoutControl.FindItem(Item.Name);
    if assigned(dxLayoutItem) then
      if dxLayoutItem is TdxLayoutItem then
        if not assigned(TdxLayoutItem(dxLayoutItem).Control) then
          TdxLayoutItem(dxLayoutItem).SetFlagUserDefined(true);
  end;
end;

// ============================================================================
// TzLayout
// ============================================================================

constructor TzLayout.Create(Collection: TCollection);
begin
  inherited;
  FLayout := TzLayoutItems.Create(TzLayoutItem, '', -1, nil);
  FLayout.Sorted := False;
  // Risoluzione per form 2026-09-22: 0 = non registrata. Il valore DEVE
  // coincidere con il 'default 0' della proprieta' pubblicata, altrimenti il
  // valore non viene scritto nello stream e rientra da solo (e' l'errore gia'
  // documentato nel commento di TzLayoutItem.GeneratedByController).
  FDesignWidth := 0;
  FDesignHeight := 0;
end;

destructor TzLayout.Destroy;
begin
  FreeAndNil(FLayout);
  inherited;
end;

procedure TzLayout.Assign(Source: TPersistent);
var
  Item: TzLayout;
begin
  inherited;
  if Source is TzLayout then
  begin
    Item := Source as TzLayout;
    Name := Item.Name;
    Layout.Assign(Item.Layout);
    // Risoluzione per form 2026-09-22
    DesignWidth := Item.DesignWidth;
    DesignHeight := Item.DesignHeight;
  end;
end;

procedure TzLayout.DefaultProps;
begin
  Layout.Clear;
  // Risoluzione per form 2026-09-22: svuotando l'LZ cade anche la risoluzione
  // di redazione, che descriveva il layout appena scartato.
  FDesignWidth := 0;
  FDesignHeight := 0;
end;

procedure TzLayout.SetLayout(const Value: TzLayoutItems);
begin
  FLayout.Assign(Value);
end;

// ============================================================================
// TdxCustomLayoutItemHelper
// ============================================================================

function TdxCustomLayoutItemHelper.ItemClassKind: TItemClassKind;
begin
  result := TItemClassKind(GetItemClassKind);
end;

procedure TdxCustomLayoutItemHelper.SetFlagSuperfluous(const Value: boolean);
begin
  Superfluous := Value;
end;

procedure TdxCustomLayoutItemHelper.SetFlagUserDefined(const Value: boolean);
begin
  IsUserDefined := Value;
end;

procedure TdxCustomLayoutItemHelper.zSetLoadedInfo(const AParentName: string; AIndex: integer);
begin
  self.SetLoadedInfo(AParentName, AIndex);
end;

// ============================================================================
// TdxLayoutContainerHelper
// ============================================================================

procedure TdxLayoutContainerHelper.BeginLoading;
begin
  BeginUpdate;
  IsRestoring := true;
end;

procedure TdxLayoutContainerHelper.EndLoading;
begin
  IsRestoring := False;
  EndUpdate;
end;

initialization

RegisterClasses([TzDxLayoutGroup, TzDxFieldLayoutGroup, TzDxLayoutItem, TzDxFieldLayoutItem, TzDxLayoutSplitterItem, TzDxLayoutEmptySpaceItem, TzDxLayoutSeparatorItem]);

DefaultStrategy := TzLayoutItemStrategy.Create;
FieldStrategy := TzLayoutItemFieldStrategy.Create;
LabeledStrategy := TzLayoutItemLabeledStrategy.Create;
GroupStrategy := TzLayoutItemGroupStrategy.Create;
SplitterStrategy := TzLayoutItemSplitterStrategy.Create;

finalization

FreeAndNil(DefaultStrategy);
FreeAndNil(FieldStrategy);
FreeAndNil(LabeledStrategy);
FreeAndNil(GroupStrategy);
FreeAndNil(SplitterStrategy);

end.
