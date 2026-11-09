unit zDfmLayoutArranger;

{ ==============================================================================
  VERSIONE ARRANGER: 11  (2026-07-01)
  --> incrementata a ogni rilascio. Viene scritta nel log SmartInspect a inizio
      di CaptureSource e Apply: cerca "zDfmLayoutArranger VERSIONE=" per
      verificare quale build e' effettivamente installata.

  Changelog:
   v11- diag "veritiero": per ogni controllo mostra il NOME dell'item risolto e
        il TIPO di match (per-controllo / RIPIEGO per-dataset(ALIAS) / MANCANTE).
        Rende evidenti le COLLISIONI: piu' controlli DFM dello stesso dataset che
        finiscono sullo stesso item (es. cardDocumento/cardAltriDati/viewerPdf
        -> viewDocumento_Documento) perche' non hanno un item proprio nel diagram.
   v10- diagnostica su FILE: Apply scrive "zDfmArranger_diag.txt" accanto
        all'eseguibile (fallback %TEMP%) con l'esito di risoluzione di ogni
        controllo (OK / MANCANTE) e la lista degli orfani. Serve a capire senza
        SmartInspect perche' un controllo (es. una card) non viene collocato.
   v9 - gruppi/splitter mirror creati come CLASSI BASE (TdxLayoutGroup/
        TdxLayoutSplitterItem) invece delle varianti Tz*: la persistenza li
        marcava GeneratedByController=True e NON li ricreava al reload -> il
        mirror andava perso alla riapertura. Ora persiste.
   v8 - risoluzione per-ComponentName di TUTTI i controlli (view/card/pivot/
        file/map) via BuildDataSetIndex; riuso del gruppo nascosto per evitare
        suffissi _1; harvest selettivo dei soli item referenziati.
  ============================================================================== }

{ ------------------------------------------------------------------------------
  TzDfmLayoutArranger  (v2 - clonazione fedele)

  Conversione ONE-SHOT di una form "legacy DFM" in modalita' BuildGUI,
  CLONANDO FEDELMENTE la topologia visuale del DFM (pannelli, splitter, tab
  annidati), non solo l'ordine dei dataset.

  Differenze chiave rispetto alla v1 (per-dataset):
  1. SCAN NON SI FERMA sulle view-master: una view e' una foglia, ma la
  ricorsione prosegue sui controlli figli del suo contenitore (sotto
  viewScadenze c'e' ancora pageSaldoDocumenti da mappare).
  2. CONTENITORI = GRUPPI REALI: TPanel/TcxGroupBox -> TdxLayoutGroup con
  direzione dedotta da Align (impilati = ldVertical, affiancati =
  ldHorizontal); TcxSplitter -> CreateSplitter.
  3. GRANULARITA' PER-CONTROLLO: si sposta il singolo TdxLayoutItem della
  view, identificato per IDENTITA' del controllo (il controller riusa le
  view DFM via FindComponent(ComponentName), quindi item.Control E' la
  view del DFM). Niente risoluzione via dataset.

  Conseguenza accettata: l'incapsulamento master-detail del controller NON
  viene preservato nel layout; la disposizione e' quella del DFM.

  Prerequisito: CreateControls/CreateLayoutStructure gia' eseguita.
  ------------------------------------------------------------------------------ }

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  cxPC,
  cxSplitter,
  dxLayoutContainer,
  dxLayoutControl,
  zFormController;

type
  TTargetNodeKind = (tnRoot, tnTabbed, tnContainer, tnSplitter, tnLeaf);

  TTargetNode = class
  public
    Kind: TTargetNodeKind;
    SourceName: string;
    Caption: string;
    LeafControlName: string; // solo tnLeaf: nome del controllo DFM
    LeafControl: TControl;   // solo tnLeaf: il controllo DFM (view/card/file)
    DataSetName: string; // solo tnLeaf: nome dataset (fallback)
    Direction: TdxLayoutDirection; // solo tnContainer
    Children: TObjectList<TTargetNode>;
    constructor Create(AKind: TTargetNodeKind);
    destructor Destroy; override;
    function HasDbLeaf: boolean;
  end;

  TzDfmLayoutArranger = class
  private
    FLayout: TLayoutController;
    FRoot: TTargetNode;
    FOrphans: TStringList;
    FHideUnreferencedDatasets: boolean;
    // indice dataSetName -> item (fallback), costruito in Apply (post-CreateControls)
    FDsToItem: TDictionary<string, TdxLayoutItem>;
    // indice ComponentName -> item, per TUTTI i controlli (view/card/pivot/file/map)
    FCompItems: TDictionary<string, TdxLayoutItem>;

    // Legge il nome dataset dalla view DFM (zDataSet assegnato all'avvio form,
    // prima dell'arranger). Chiave robusta indipendente dal naming del diagram.
    function LeafDataSetName(Ctrl: TControl): string;

    // Costruisce FDsToItem scorrendo i TzDiagramDataSet del datamodule e
    // ricomponendo il nome item dal ComponentName della view (ctView).
    procedure BuildDataSetIndex;
    function ItemForDataSet(const DataSetName: string): TdxLayoutItem;

    // FASE 2: scan
    function IsLeafDbControl(Ctrl: TControl): boolean;
    function DeduceDirection(WinCtrl: TWinControl): TdxLayoutDirection;
    procedure ScanControl(WinCtrl: TWinControl; Parent: TTargetNode);

    // FASE 3: emit
    // Creano gruppi/splitter mirror come CLASSI BASE (TdxLayoutGroup/
    // TdxLayoutSplitterItem) e NON come varianti Tz*: cosi' la persistenza
    // (LoadFromLayout) NON li marca GeneratedByController e SaveToLayout li
    // RICREA al reload. Con le varianti Tz* il mirror andava perso alla
    // riapertura.
    function UniqueMirrorName(const base: string): string;
    function CreateMirrorGroup(Parent: TdxLayoutGroup; const aName: string; Dir: TdxLayoutDirection; const ACaption: string): TdxLayoutGroup;
    function CreateMirrorSplitter(Parent: TdxLayoutGroup; const aName: string): TdxLayoutSplitterItem;
    function ItemForNode(Node: TTargetNode): TdxLayoutItem;
    function SortChildrenByPosition(WinCtrl: TWinControl; Direction: TdxLayoutDirection): TList<TControl>;
    function IsGroupStructurallyEmpty(grp: TdxLayoutGroup): boolean;
    procedure CollectReferencedItems(Node: TTargetNode; Referenced: TList<TdxLayoutItem>);

    procedure EmitNode(Node: TTargetNode; TargetParent: TdxLayoutGroup; var RunningIndex: Integer);
    procedure PruneEmpty(Node: TTargetNode);

    // diagnostica
    procedure SiArrangerLog(const Msg: string; Color: TColor);
    procedure DumpTargetTree(Node: TTargetNode; Depth: Integer; CheckItems: boolean);
    procedure DumpLayoutTree(Item: TdxCustomLayoutItem; Depth: Integer);
    procedure DumpOrphans;
    procedure WriteDiagFile;
  public
    constructor Create(ALayout: TLayoutController);
    destructor Destroy; override;

    { Flusso a due fasi attorno a CreateControls:

      Arranger := TzDfmLayoutArranger.Create(FormController.LayoutController);
      Arranger.CaptureSource(Self);     // PRIMA di CreateControls:
      //   - scandisce i TcxPageControl del DFM
      //     (ancora popolati)
      //   - forza UsePageControl := True
      Documenti.zDataModule.BuildGUI := True;
      FormController.CreateControls;    // genera il layout (tab visibili)
      Arranger.Apply(True);             // DOPO: riparenta + SaveProps

      Il vecchio Convert(SourceRoot) e' deprecato: non funziona perche'
      CreateControls smonta i TcxTabSheet del DFM prima dello scan. }

    procedure CaptureSource(SourceRoot: TWinControl);
    procedure Apply(PersistAfter: boolean = True);

    property Orphans: TStringList read FOrphans;
    // Se True, i dataset del datamodule SENZA view fisica sul DFM non restano
    // nel canonico residuo ma vengono spostati in un gruppo nascosto (persistente
    // al reload). Default False.
    property HideUnreferencedDatasets: boolean read FHideUnreferencedDatasets write FHideUnreferencedDatasets;
  end;

implementation

uses
  System.StrUtils,
  System.UITypes,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto,
  zSystem,
  System.Generics.Defaults;

const
  ARRANGER_VERSION = 11; // <-- incrementare a ogni rilascio (vedi header)

var
  SiArranger: TSiSession = nil; // sessione SmartInspect dedicata

  { ================================ TTargetNode ============================= }

constructor TTargetNode.Create(AKind: TTargetNodeKind);
begin
  inherited Create;
  Kind := AKind;
  Direction := ldVertical;
  Children := TObjectList<TTargetNode>.Create(True);
end;

destructor TTargetNode.Destroy;
begin
  Children.Free;
  inherited;
end;

// true se il nodo (o un discendente) e' una foglia db. Controllo PURAMENTE
// STRUTTURALE: non accede agli item del layout (che in fase di cattura non
// esistono ancora). Serve a potare i container privi di foglie db.
function TTargetNode.HasDbLeaf: boolean;
var
  child: TTargetNode;
begin
  if Kind = tnLeaf then
    Exit(True);

  for child in Children do
    if child.HasDbLeaf then
      Exit(True);

  result := False;
end;

{ =========================== TzDfmLayoutArranger ========================== }

constructor TzDfmLayoutArranger.Create(ALayout: TLayoutController);
begin
  inherited Create;
  FLayout := ALayout;
  FOrphans := TStringList.Create;
  FDsToItem := TDictionary<string, TdxLayoutItem>.Create;
  FCompItems := TDictionary<string, TdxLayoutItem>.Create;
end;

destructor TzDfmLayoutArranger.Destroy;
begin
  FRoot.Free;
  FCompItems.Free;
  FDsToItem.Free;
  FOrphans.Free;
  inherited;
end;

{ --------------------------------------------------------------------------
  Risoluzione item per NOME del controllo.
  CreateLayoutStructure crea ogni item con nome = ItemName(ComponentName),
  dove ItemName(n) = dxLayoutControl.Name + 'Item' + n. L'item esiste sempre,
  anche se item.Control e' ancora nil (lazy-init). Si usa il FindItem
  pubblico del controller, replicando la formula del nome.
  -------------------------------------------------------------------------- }
function TzDfmLayoutArranger.LeafDataSetName(Ctrl: TControl): string;
var
  DbComp: IzBaseDbComponent;
begin
  result := '';
  if not Supports(Ctrl, IzBaseDbComponent, DbComp) then
    Exit;
  if DbComp.zDataSet = nil then
    Exit;
  result := DbComp.zDataSet.Name;
end;

{ Scorre ricorsivamente i TzDiagramDataSet del datamodule (master + detail) e
  mappa dataset.Name -> item, ricomponendo il nome item dal ComponentName
  della view di tipo ctView. Indipendente dal lazy-init (non legge item.Control)
  e dal naming DFM. }
procedure TzDfmLayoutArranger.BuildDataSetIndex;

  // indicizza per ComponentName tutti i controlli di una collezione
  procedure IndexCtrls(Ctrls: TzDiagramDataSet.TzDiagramCtrls);
  var
    c: Integer;
    ctrl: TzDiagramDataSet.TzDiagramCtrl;
    it: TdxLayoutItem;
  begin
    for c := 0 to Ctrls.Count - 1 do
    begin
      ctrl := TzDiagramDataSet.TzDiagramCtrl(Ctrls[c]);
      it := FLayout.FindItem(FLayout.dxLayoutControl.Name + 'Item' + ctrl.ComponentName);
      if it <> nil then
        FCompItems.AddOrSetValue(ctrl.ComponentName, it);
    end;
  end;

  procedure Recurse(DataSets: TzDiagramDataSets);
  var
    ds: TzDiagramDataSet;
    i: Integer;
    it: TdxLayoutItem;
  begin
    for i := 0 to DataSets.Count - 1 do
    begin
      ds := DataSets[i];

      // indice PER-CONTROLLO: view, card, pivot, file, map
      IndexCtrls(ds.DbViews);
      IndexCtrls(ds.DbCards);
      IndexCtrls(ds.DbPivots);
      IndexCtrls(ds.DbRecordViews);
      IndexCtrls(ds.DbTrees);
      IndexCtrls(ds.DbCharts);
      IndexCtrls(ds.DbSchedulers);
      IndexCtrls(ds.DbFiles);
      IndexCtrls(ds.GisMaps);

      // fallback per-dataset: prima view del dataset
      if (ds.DbViews.Count > 0) and (not FDsToItem.ContainsKey(ds.Name)) then
      begin
        it := FLayout.FindItem(FLayout.dxLayoutControl.Name + 'Item' + ds.DbViews[0].ComponentName);
        if it <> nil then
          FDsToItem.Add(ds.Name, it);
      end;

      // ricorsione sui detail
      if ds.DetailDatasets <> nil then
        Recurse(ds.DetailDatasets);
    end;
  end;

begin
  FDsToItem.Clear;
  FCompItems.Clear;
  Recurse(FLayout.FormController.zDataModule.DataSets);
end;

function TzDfmLayoutArranger.ItemForDataSet(const DataSetName: string): TdxLayoutItem;
begin
  if (DataSetName = '') or (not FDsToItem.TryGetValue(DataSetName, result)) then
    result := nil;
end;

{ Risoluzione PER-CONTROLLO: dopo CreateControls (BuildGUI) il controller riusa
  il controllo del DFM come item.Control, quindi FindItem(control) restituisce
  l'item che ospita proprio quella view/card/file. Funziona per QUALSIASI tipo
  di controllo db (non solo le view), e distingue piu' controlli dello stesso
  dataset (view + card + card). Fallback: risoluzione per dataset. }
function TzDfmLayoutArranger.ItemForNode(Node: TTargetNode): TdxLayoutItem;
var
  key: string;
begin
  result := nil;
  if Node.LeafControlName <> '' then
  begin
    // Il ComponentName del diagram e' <NomeControllo>_<Dataset>
    // (es. viewDocumenti_Documenti, cardDocumento_Documenti).
    if FCompItems.TryGetValue(Node.LeafControlName + '_' + Node.DataSetName, result) then
      Exit;
    // nome esatto (senza suffisso dataset)
    if FCompItems.TryGetValue(Node.LeafControlName, result) then
      Exit;
    // scan per prefisso <NomeControllo>_ (dataset diverso dal nome atteso)
    for key in FCompItems.Keys do
      if StartsText(Node.LeafControlName + '_', key) then
        Exit(FCompItems[key]);
  end;
  // ultimo fallback per-dataset (puo' aliasare piu' controlli sullo stesso item)
  result := ItemForDataSet(Node.DataSetName);
end;

function TzDfmLayoutArranger.IsLeafDbControl(Ctrl: TControl): boolean;
var
  dummy: IzBaseDbComponent;
begin
  result := Supports(Ctrl, IzBaseDbComponent, dummy);
end;

{ --------------------------------------------------------------------------
  Direzione di un contenitore: dedotta dall'Align dei figli WinControl.
  - figli alTop/alBottom (impilati)        -> ldVertical
  - figli alLeft/alRight (affiancati)      -> ldHorizontal
  - default                                -> ldVertical
  -------------------------------------------------------------------------- }
function TzDfmLayoutArranger.DeduceDirection(WinCtrl: TWinControl): TdxLayoutDirection;
var
  i: Integer;
  c: TControl;
  horiz, vert: Integer;
begin
  horiz := 0;
  vert := 0;
  for i := 0 to WinCtrl.ControlCount - 1 do
  begin
    c := WinCtrl.Controls[i];
    case c.Align of
      alTop, alBottom:
        Inc(vert);
      alLeft, alRight:
        Inc(horiz);
    end;
  end;
  if horiz > vert then
    result := ldHorizontal
  else
    result := ldVertical;
end;

{ --------------------------------------------------------------------------
  FASE 2 - walk ricorsivo. A differenza della v1, una foglia db NON ferma
  la ricorsione: si emette il nodo foglia e si prosegue sui figli (una
  view-master ha sotto di se' un page control di detail).
  -------------------------------------------------------------------------- }
procedure TzDfmLayoutArranger.ScanControl(WinCtrl: TWinControl; Parent: TTargetNode);
var
  i: Integer;
  child: TControl;
  Node: TTargetNode;
  recurseTarget: TTargetNode;
  ordered: TList<TControl>;
begin
  // NON scendere nel dxLayoutControl del controller: scandiamo SOLO l'albero
  // originale del DFM (TcxPageControl/TcxTabSheet/TPanel).
  if (FLayout.dxLayoutControl <> nil) and (WinCtrl = FLayout.dxLayoutControl) then
    Exit;

  // 1) foglia db (view/card/file/pivot)
  if IsLeafDbControl(WinCtrl) then
  begin
    Node := TTargetNode.Create(tnLeaf);
    Node.SourceName := WinCtrl.Name;
    Node.LeafControlName := WinCtrl.Name;
    Node.LeafControl := WinCtrl;                   // il controllo fisico (view/card/file)
    Node.DataSetName := LeafDataSetName(WinCtrl); // fallback per-dataset
    Parent.Children.Add(Node);
    // NB: prosegue sotto; una view-master puo' contenere altri controlli.
    // I detail vanno accanto alla foglia, nello stesso Parent.
    recurseTarget := Parent;
  end

  // 2) page control -> gruppo tabbed; ricorsione sui Pages[]
  else
    if WinCtrl is TcxPageControl then
    begin
      Node := TTargetNode.Create(tnTabbed);
      Node.SourceName := WinCtrl.Name;
      Parent.Children.Add(Node);
      for i := 0 to TcxPageControl(WinCtrl).PageCount - 1 do
        ScanControl(TcxPageControl(WinCtrl).Pages[i], Node);
      Exit;
    end

    // 3) tab sheet -> gruppo "pagina" (figlio di un tabbed)
    else
      if WinCtrl is TcxTabSheet then
      begin
        Node := TTargetNode.Create(tnContainer);
        Node.SourceName := WinCtrl.Name;
        Node.Caption := TcxTabSheet(WinCtrl).Caption;
        Node.Direction := DeduceDirection(WinCtrl);
        Parent.Children.Add(Node);
        recurseTarget := Node;
      end

      // 4) splitter -> nodo segnaposto (emesso tra due gruppi)
      else
        if (WinCtrl is TcxSplitter) then
        begin
          Node := TTargetNode.Create(tnSplitter);
          Node.SourceName := WinCtrl.Name;
          Parent.Children.Add(Node);
          Exit;
        end

        // 5) contenitore generico (TPanel, TcxGroupBox, ...) -> gruppo reale
        else
        begin
          Node := TTargetNode.Create(tnContainer);
          Node.SourceName := WinCtrl.Name;
          Node.Direction := DeduceDirection(WinCtrl);
          Parent.Children.Add(Node);
          recurseTarget := Node;
        end;

  // ricorsione sui figli ORDINATI PER POSIZIONE VISIVA (non z-order):
  // orizzontale -> per Left, verticale -> per Top. Cosi' l'ordine emesso
  // rispetta la disposizione reale del DFM (alClient vs alTop/alRight) e
  // lo splitter si colloca da solo tra i due gruppi che separa.
  ordered := SortChildrenByPosition(WinCtrl, recurseTarget.Direction);
  try
    for i := 0 to ordered.Count - 1 do
    begin
      child := ordered[i];
      if child is TWinControl then
        ScanControl(TWinControl(child), recurseTarget);
    end;
  finally
    ordered.Free;
  end;
end;

{ --------------------------------------------------------------------------
  Pota i nodi senza foglie mappabili (tab vuoti, pannelli di soli controlli
  non-db) per non generare gruppi spurii.
  -------------------------------------------------------------------------- }
procedure TzDfmLayoutArranger.PruneEmpty(Node: TTargetNode);
var
  i: Integer;
begin
  for i := Node.Children.Count - 1 downto 0 do
  begin
    PruneEmpty(Node.Children[i]);
    if (Node.Children[i].Kind in [tnTabbed, tnContainer]) and (not Node.Children[i].HasDbLeaf) then
      Node.Children.Delete(i);
  end;
end;

{ --------------------------------------------------------------------------
  FASE 3 - emissione. Crea gruppi/splitter del target tree e riparenta gli
  item delle foglie (per identita' di controllo).
  -------------------------------------------------------------------------- }

function TzDfmLayoutArranger.UniqueMirrorName(const base: string): string;
var
  n, i: Integer;
  taken: boolean;
begin
  result := base;
  n := 0;
  repeat
    taken := False;
    for i := 0 to FLayout.dxLayoutControl.AbsoluteItemCount - 1 do
      if SameText(FLayout.dxLayoutControl.AbsoluteItems[i].Name, result) then
      begin
        taken := True;
        Break;
      end;
    if taken then
    begin
      Inc(n);
      result := base + '_' + IntToStr(n);
    end;
  until not taken;
end;

function TzDfmLayoutArranger.CreateMirrorGroup(Parent: TdxLayoutGroup; const aName: string; Dir: TdxLayoutDirection; const ACaption: string): TdxLayoutGroup;
begin
  // CLASSE BASE (non TzDxLayoutGroup) -> persistita come user-defined
  result := FLayout.dxLayoutControl.CreateGroup(TdxLayoutGroup, nil) as TdxLayoutGroup;
  if aName <> '' then
    result.Name := UniqueMirrorName('dxLayoutGroup' + aName);
  result.Parent := Parent;
  result.LayoutDirection := Dir;
  result.AlignHorz := ahClient;
  result.AlignVert := avClient;
  result.Caption := ACaption;
  result.CaptionOptions.Visible := ACaption <> '';
end;

function TzDfmLayoutArranger.CreateMirrorSplitter(Parent: TdxLayoutGroup; const aName: string): TdxLayoutSplitterItem;
begin
  // CLASSE BASE (non TzDxLayoutSplitterItem)
  result := Parent.CreateItem(TdxLayoutSplitterItem) as TdxLayoutSplitterItem;
  if aName <> '' then
    result.Name := UniqueMirrorName('dxLayoutSplitter' + aName);
  result.Parent := Parent;
  result.CaptionOptions.Visible := False;
end;

procedure TzDfmLayoutArranger.EmitNode(Node: TTargetNode; TargetParent: TdxLayoutGroup; var RunningIndex: Integer);
var
  grp: TdxLayoutGroup;
  it: TdxLayoutItem;
  spl: TdxLayoutSplitterItem;
  child: TTargetNode;
  childIndex: Integer;
begin
  case Node.Kind of

    { ---- foglia: sposta l'item (per-controllo) nel gruppo mirror corrente ---- }
    tnLeaf:
      begin
        it := ItemForNode(Node);
        if it = nil then
        begin
          FOrphans.Add(Format('%s -> dataset "%s" (nessun item)', [Node.SourceName, Node.DataSetName]));
          Exit;
        end;
        it.Parent := TargetParent;
        it.Index := RunningIndex;
        Inc(RunningIndex);
      end;

    { ---- page control -> gruppo tabbed mirror ---- }
    tnTabbed:
      begin
        grp := CreateMirrorGroup(TargetParent, Node.SourceName, ldTabbed, '');
        grp.TabbedOptions.HideTabs := False;
        grp.ShowBorder := False;
        grp.Index := RunningIndex;
        Inc(RunningIndex);
        childIndex := 0;
        for child in Node.Children do
          EmitNode(child, grp, childIndex);
      end;

    { ---- tab sheet / panel -> gruppo mirror con direzione dedotta ---- }
    tnContainer:
      begin
        grp := CreateMirrorGroup(TargetParent, Node.SourceName, Node.Direction, Node.Caption);
        grp.ShowBorder := False;
        grp.Index := RunningIndex;
        Inc(RunningIndex);
        childIndex := 0;
        for child in Node.Children do
          EmitNode(child, grp, childIndex);
      end;

    { ---- splitter -> ricreato tra i due gruppi che separa ---- }
    tnSplitter:
      begin
        spl := CreateMirrorSplitter(TargetParent, Node.SourceName);
        spl.Index := RunningIndex;
        Inc(RunningIndex);
      end;

  else { tnRoot }
    for child in Node.Children do
      EmitNode(child, TargetParent, RunningIndex);
  end;
end;

{ ============================== Diagnostica ============================== }

procedure TzDfmLayoutArranger.SiArrangerLog(const Msg: string; Color: TColor);
begin
  // sessione SmartInspect dedicata, creata pigramente
  if SiArranger = nil then
    SiArranger := Si.AddSession('zDfmLayoutArranger', True);
  SiArranger.LogColored(Color, Msg);
end;

function TzDfmLayoutArranger.SortChildrenByPosition(WinCtrl: TWinControl; Direction: TdxLayoutDirection): TList<TControl>;
var
  i: Integer;
begin
  result := TList<TControl>.Create;
  for i := 0 to WinCtrl.ControlCount - 1 do
    result.Add(WinCtrl.Controls[i]);

  // ordine visivo: orizzontale -> per Left; verticale -> per Top.
  // (le coordinate provengono dal DFM e riflettono la disposizione reale)
  result.Sort(TComparer<TControl>.Construct(
    function(const L, R: TControl): Integer
    begin
      if Direction = ldHorizontal then
        result := L.Left - R.Left
      else
        result := L.Top - R.Top;
    end));
end;

procedure TzDfmLayoutArranger.DumpTargetTree(Node: TTargetNode; Depth: Integer; CheckItems: boolean);
const
  Kind: array [TTargetNodeKind] of string = ('ROOT', 'TABBED', 'CONTAINER', 'SPLITTER', 'LEAF');
var
  child: TTargetNode;
  line: string;
  mapped: string;
begin
  mapped := '';
  if Node.Kind = tnLeaf then
  begin
    mapped := ' ctrl=' + Node.LeafControlName + ' ds=' + Node.DataSetName;
    if CheckItems then
    begin
      if ItemForNode(Node) <> nil then
        mapped := mapped + ' [item OK]'
      else
        mapped := mapped + ' [item MANCANTE]';
    end;
  end;

  line := StringOfChar(' ', Depth * 2) + Format('%s  %s%s%s', [Kind[Node.Kind], Node.SourceName, IfThen(Node.Caption <> '', ' "' + Node.Caption + '"', ''), mapped]);
  SiArrangerLog(line, TColors.Teal);

  for child in Node.Children do
    DumpTargetTree(child, Depth + 1, CheckItems);
end;

procedure TzDfmLayoutArranger.DumpLayoutTree(Item: TdxCustomLayoutItem; Depth: Integer);
var
  i: Integer;
  grp: TdxLayoutGroup;
  it: TdxLayoutItem;
  line, Kind, extra: string;
begin
  if Item is TdxLayoutGroup then
  begin
    grp := TdxLayoutGroup(Item);
    case grp.LayoutDirection of
      ldHorizontal:
        Kind := 'GRP-H';
      ldVertical:
        Kind := 'GRP-V';
      ldTabbed:
        Kind := 'GRP-TAB';
    else
      Kind := 'GRP-?';
    end;
    extra := Format(' hideTabs=%s', [BoolToStr(grp.TabbedOptions.HideTabs, True)]);
  end
  else
    if Item is TdxLayoutItem then
    begin
      it := TdxLayoutItem(Item);
      Kind := 'ITEM';
      if it.Control <> nil then
        extra := ' ctrl=' + it.Control.Name
      else
        extra := ' ctrl=nil';
    end
    else
      if Item is TdxLayoutSplitterItem then
        Kind := 'SPLIT'
      else
        Kind := '?';

  line := StringOfChar(' ', Depth * 2) + Format('%s  %s%s', [Kind, Item.Name, extra]);
  SiArrangerLog(line, TColors.Navy);

  if Item is TdxLayoutGroup then
    for i := 0 to TdxLayoutGroup(Item).Count - 1 do
      DumpLayoutTree(TdxLayoutGroup(Item).Items[i], Depth + 1);
end;

procedure TzDfmLayoutArranger.DumpOrphans;
var
  s: string;
begin
  SiArrangerLog(Format('ORFANI: %d', [FOrphans.Count]), TColors.Red);
  for s in FOrphans do
    SiArrangerLog('  ' + s, TColors.Red);
end;

{ Scrive un file di testo accanto all'eseguibile con l'esito di risoluzione di
  OGNI foglia (view/card/file...) e la lista degli orfani. Serve per capire,
  senza SmartInspect, perche' un controllo (es. una card) non viene collocato. }
procedure TzDfmLayoutArranger.WriteDiagFile;

  // risoluzione "spiegata": ritorna item + tipo di match
  function ResolveExplain(Node: TTargetNode; out itemName: string): string;
  var
    it: TdxLayoutItem;
    key: string;
  begin
    itemName := '';
    // 1) match ESATTO per-controllo: <ctrl>_<dataset>
    if FCompItems.TryGetValue(Node.LeafControlName + '_' + Node.DataSetName, it) then
    begin
      itemName := it.Name;
      Exit('per-controllo');
    end;
    // 2) match per nome controllo
    if FCompItems.TryGetValue(Node.LeafControlName, it) then
    begin
      itemName := it.Name;
      Exit('per-controllo');
    end;
    // 3) prefisso <ctrl>_
    for key in FCompItems.Keys do
      if StartsText(Node.LeafControlName + '_', key) then
      begin
        itemName := FCompItems[key].Name;
        Exit('per-controllo(prefisso ' + key + ')');
      end;
    // 4) ripiego per-dataset (ALIAS: collide con altri controlli dello stesso dataset!)
    it := ItemForDataSet(Node.DataSetName);
    if it <> nil then
    begin
      itemName := it.Name;
      Exit('*** RIPIEGO per-dataset (ALIAS) ***');
    end;
    result := '*** MANCANTE ***';
  end;

  procedure WalkLeaves(Node: TTargetNode; Lines: TStringList);
  var
    child: TTargetNode;
    itemName, kind: string;
  begin
    if Node.Kind = tnLeaf then
    begin
      kind := ResolveExplain(Node, itemName);
      Lines.Add(Format('  ctrl=%-32s ds=%-22s item=%-34s [%s]', [Node.LeafControlName, Node.DataSetName, itemName, kind]));
    end;
    for child in Node.Children do
      WalkLeaves(child, Lines);
  end;

var
  Lines: TStringList;
  s, fn: string;
begin
  Lines := TStringList.Create;
  try
    Lines.Add(Format('zDfmLayoutArranger VERSIONE=%d', [ARRANGER_VERSION]));
    Lines.Add('Form: ' + FLayout.FormController.zDataModule.Name);
    Lines.Add('');
    Lines.Add('=== RISOLUZIONE FOGLIE (controllo -> item) ===');
    if FRoot <> nil then
      WalkLeaves(FRoot, Lines);
    Lines.Add('');
    Lines.Add(Format('=== ORFANI: %d ===', [FOrphans.Count]));
    for s in FOrphans do
      Lines.Add('  ' + s);

    fn := ExtractFilePath(ParamStr(0)) + 'zDfmArranger_diag.txt';
    try
      Lines.SaveToFile(fn);
    except
      // se la cartella dell'exe non e' scrivibile, ripiega sul TEMP
      Lines.SaveToFile(IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + 'zDfmArranger_diag.txt');
    end;
  finally
    Lines.Free;
  end;
end;

{ ========================= CaptureSource / Apply ========================= }

{ FASE PRE-CreateControls: scandisce l'albero DFM (TcxPageControl ancora
  popolati) e forza UsePageControl := True cosi' i gruppi tabbed generati
  da CreateControls mostreranno le linguette. }
procedure TzDfmLayoutArranger.CaptureSource(SourceRoot: TWinControl);
begin
  if SourceRoot = nil then
    raise Exception.Create('CaptureSource: SourceRoot = nil');

  // i tab generati devono essere visibili: HideTabs deriva da UsePageControl
  FLayout.FormController.zDataModule.ControllerOptions.UsePageControl := True;

  FRoot.Free;
  SiArrangerLog(Format('zDfmLayoutArranger VERSIONE=%d - CaptureSource(%s)', [ARRANGER_VERSION, SourceRoot.Name]), TColors.Green);

  FRoot := TTargetNode.Create(tnRoot);
  FRoot.SourceName := SourceRoot.Name;
  ScanControl(SourceRoot, FRoot);
  PruneEmpty(FRoot); // pota i container senza foglie db

  SiArrangerLog('=== TARGET TREE (post-capture) ===', TColors.Teal);
  DumpTargetTree(FRoot, 0, False);
end;

{ FASE POST-CreateControls: gli item esistono; riparenta secondo il
  target tree e persiste. }
function TzDfmLayoutArranger.IsGroupStructurallyEmpty(grp: TdxLayoutGroup): boolean;
var
  j: Integer;
begin
  // "vuoto" = nessun item o sotto-gruppo reale: Count=0 oppure soli splitter.
  result := True;
  for j := 0 to grp.Count - 1 do
    if not (grp.Items[j] is TdxLayoutSplitterItem) then
      Exit(False);
end;

procedure TzDfmLayoutArranger.CollectReferencedItems(Node: TTargetNode; Referenced: TList<TdxLayoutItem>);
var
  child: TTargetNode;
  it: TdxLayoutItem;
begin
  if Node.Kind = tnLeaf then
  begin
    it := ItemForNode(Node);
    if (it <> nil) and (Referenced.IndexOf(it) < 0) then
      Referenced.Add(it);
  end;
  for child in Node.Children do
    CollectReferencedItems(child, Referenced);
end;

procedure TzDfmLayoutArranger.Apply(PersistAfter: boolean = True);
var
  rootIndex, i: Integer;
  topParent: TdxLayoutGroup;
  hiddenGrp: TdxLayoutGroup;
  child: TdxCustomLayoutItem;
  referenced: TList<TdxLayoutItem>;
  removed: boolean;
begin
  if FRoot = nil then
    raise Exception.Create('Apply senza CaptureSource: target tree assente.');
  if FLayout.dxLayoutControl = nil then
    raise Exception.Create('Layout non generato: chiamare CreateControls prima di Apply.');

  SiArrangerLog(Format('zDfmLayoutArranger VERSIONE=%d - Apply', [ARRANGER_VERSION]), TColors.Green);

  // gli item esistono: costruisci l'indice dataset -> item
  BuildDataSetIndex;

  SiArrangerLog('=== TARGET TREE (pre-emit, item check) ===', TColors.Teal);
  DumpTargetTree(FRoot, 0, True);

  // diagnostica su FILE (accanto all'exe): esito di risoluzione di ogni foglia
  WriteDiagFile;

  // Insieme degli item REFERENZIATI dal DFM (foglie dell'albero catturato).
  // Solo questi vanno spostati nel mirror; gli item dei dataset presenti nel
  // datamodule ma SENZA view fisica sul DFM (es. Doc_Immobili) NON vanno
  // toccati, altrimenti finiscono orfani sotto il root.
  referenced := TList<TdxLayoutItem>.Create;
  try
    CollectReferencedItems(FRoot, referenced);

    FLayout.dxLayoutControl.BeginUpdate;
    try
      topParent := FLayout.dxLayoutControl.Items as TdxLayoutGroup;

      // 1) HARVEST: stacca sotto il root SOLO gli item referenziati dal DFM.
      for i := 0 to referenced.Count - 1 do
        referenced[i].Parent := topParent;

      // 1b) HIDE opzionale: i dataset senza view fisica sul DFM (item non
      // referenziati) vengono spostati in un gruppo NASCOSTO invece di restare
      // nel canonico residuo. Il gruppo, contenendo item, sopravvive al nuke e
      // al Pack del reload, ma non e' visibile; essendo user-defined viene
      // ricreato dal load -> l'occultamento persiste.
      if FHideUnreferencedDatasets then
      begin
        // RIUSA un eventuale gruppo nascosto di una conversione precedente
        // (ricaricato dall'LZ), per non accumulare suffissi _1/_2 su LZ non vuoto.
        hiddenGrp := nil;
        for i := 0 to FLayout.dxLayoutControl.AbsoluteItemCount - 1 do
        begin
          child := FLayout.dxLayoutControl.AbsoluteItems[i];
          if (child is TdxLayoutGroup) and StartsText('dxLayoutGroupDatasetNascosti', child.Name) then
          begin
            hiddenGrp := TdxLayoutGroup(child);
            Break;
          end;
        end;

        for i := FLayout.dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
        begin
          child := FLayout.dxLayoutControl.AbsoluteItems[i];
          if not (child is TdxLayoutItem) then
            Continue;
          if Pos('TreeMenu', child.Name) > 0 then
            Continue;
          if referenced.IndexOf(TdxLayoutItem(child)) >= 0 then
            Continue;
          if hiddenGrp = nil then
          begin
            hiddenGrp := CreateMirrorGroup(topParent, 'DatasetNascosti', ldVertical, '');
            hiddenGrp.Hidden := True;
            hiddenGrp.Visible := False;
          end;
          if child.Parent <> hiddenGrp then
            child.Parent := hiddenGrp;
        end;

        // assicura stato nascosto anche se il gruppo e' stato riusato
        if hiddenGrp <> nil then
        begin
          hiddenGrp.Hidden := True;
          hiddenGrp.Visible := False;
        end;
      end;

      // 2) NUKE a CASCATA (tutti i livelli): elimina i gruppi STRUTTURALMENTE
      // VUOTI (Count=0 o soli splitter), tranne il TreeMenu. Svuotandone uno il
      // padre puo' diventare vuoto -> si ripete. Cosi' spariscono il mirror
      // vecchio (svuotato dall'harvest) e i gusci canonici dei dataset
      // referenziati; i gruppi che contengono ancora item di dataset NON
      // presenti sul DFM sopravvivono (restano nel canonico, non al root).
      repeat
        removed := False;
        for i := FLayout.dxLayoutControl.AbsoluteItemCount - 1 downto 0 do
        begin
          child := FLayout.dxLayoutControl.AbsoluteItems[i];
          if Pos('TreeMenu', child.Name) > 0 then
            Continue;
          if (child is TdxLayoutGroup) and IsGroupStructurallyEmpty(TdxLayoutGroup(child)) then
          begin
            child.Free;
            removed := True;
          end;
        end;
      until not removed;

      // splitter isolati rimasti come figli diretti del root (tranne TreeMenu)
      for i := topParent.Count - 1 downto 0 do
      begin
        child := topParent.Items[i];
        if (child is TdxLayoutSplitterItem) and (Pos('TreeMenu', child.Name) = 0) then
          child.Free;
      end;

      // 3) BUILD: ricostruisci il mirror; EmitNode riparenta gli item
      // referenziati (ora sotto il root) nelle posizioni del DFM.
      rootIndex := topParent.Count;
      EmitNode(FRoot, topParent, rootIndex);

      FLayout.InitLayoutGroups;
    finally
      FLayout.dxLayoutControl.EndUpdate;
    end;
  finally
    referenced.Free;
  end;

  DumpOrphans;
  SiArrangerLog('=== LAYOUT TREE (post-emit) ===', TColors.Navy);
  DumpLayoutTree(FLayout.dxLayoutControl.Items, 0);

  if PersistAfter then
    FLayout.SaveProps(True);
end;

end.
