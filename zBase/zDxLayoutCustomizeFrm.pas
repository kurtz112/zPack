unit zDxLayoutCustomizeFrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  dxLayoutCustomizeForm,
  dxSkinsCore,
  dxSkinsDefaultPainters,
  dxLayoutLookAndFeels,
  StdCtrls,
  dxLayoutControl,
  ComCtrls,
  cxControls,
  cxStyles,
  cxGraphics,
  cxEdit,
  cxSplitter,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  cxCustomData,
  cxTL,
  cxTextEdit,
  cxCheckBox,
  dxSkinsdxBarPainter,
  dxBar,
  ActnList,
  cxClasses,
  ImgList,
  Menus,
  ToolWin,
  cxLookAndFeelPainters,
  dxLayoutcxEditAdapters,
  cxButtons,
  cxContainer,
  cxTreeView,
  cxLookAndFeels,
  dxLayoutControlAdapters,
  dxLayoutContainer,
  System.ImageList,
  System.Actions,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  Vcl.ExtCtrls,
  cxImageList,
  dxScrollbarAnnotations,
  dxTreeView,
  cxFilter,
  dxFileActions,
  Vcl.StdActns,
  cxGeometry,
  dxFramedControl,
  dxPanel,
  dxUIAClasses,
  zLayoutMaintenance,
  Frame_ObjectInspector;

const
  // Messaggio differito con cui l'editor riporta in vista il nodo selezionato
  // dopo che l'albero ha ricalcolato le righe (vedi UpdateSelection).
  WM_ZLAYOUT_REVEAL_SELECTION = WM_USER + 201;

type
  TzLayoutCustomizeForm = class(TdxLayoutControlCustomizeForm)
    cxRTTIInspector: TFrameObjectInspector;
    PanelInspector: TdxPanel;
    ActionList: TActionList;
    HideTabs: TAction;
    ShowTabs: TAction;
    HideBorders: TAction;
    ShowSize: TAction;
    SalvaConNome: TdxFileSaveAs;
    CaricaDaFile: TdxFileOpen;
    FixTabs: TAction;
    LayoutReset: TAction;
    LayoutRepair: TAction;
    btnPopup: TcxButton;
    dxLayoutItemInspector: TdxLayoutItem;
    dxLayoutSplitterItem1: TdxLayoutSplitterItem;
    PopupMenu: TPopupMenu;
    HideTabs1: TMenuItem;
    ShowTabs1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    FixTabs1: TMenuItem;
    N10: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    N11: TMenuItem;
    LayoutRepair1: TMenuItem;
    LayoutReset1: TMenuItem;
    dxLayoutItemPopup: TdxLayoutItem;
    dxLayoutSeparatorItem1: TdxLayoutSeparatorItem;
    ExpandTimer: TTimer;

    procedure CaricaDaFileAccept(Sender: TObject);
    procedure ExpandTimerTimer(Sender: TObject);
    procedure FixTabsExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure HideBordersExecute(Sender: TObject);
    procedure HideTabsExecute(Sender: TObject);
    procedure LayoutRepairExecute(Sender: TObject);
    procedure LayoutResetExecute(Sender: TObject);
    procedure SalvaConNomeAccept(Sender: TObject);
    procedure ShowSizeExecute(Sender: TObject);
    procedure ShowTabsExecute(Sender: TObject);
  private
    // --- Auto-espansione ritardata durante il drag&drop su tvVisibleItems ---
    ExpandPendingItem: TdxCustomLayoutItem;

    // Gestore di disegno dei nodi gia' presente su tvVisibleItems, richiamato
    // per i nodi che VisibleItemsCustomDrawNode non disegna da se'.
    PreviousVisibleItemsCustomDrawNode: TdxTreeViewCustomDrawNodeEvent;

    procedure CancelPendingExpand;

    // --- Allineamento dell'albero alla selezione fatta sul layout ---
    procedure RevealSelectedNode(TreeView: TdxTreeViewControl);
    procedure WMRevealSelection(var Message: TMessage); message WM_ZLAYOUT_REVEAL_SELECTION;

    // --- Selezione ben visibile anche con l'albero senza focus ---
    procedure VisibleItemsCustomDrawNode(Sender: TdxCustomTreeView; Canvas: TcxCanvas; NodeViewInfo: TdxTreeViewNodeViewInfo; var Handled: Boolean);

    procedure SetTabsVisibility(Const Visible: boolean);
    function FindMaintenanceHandler: IzLayoutMaintenance;
  protected
    // chiamato da DevExpress alla fine/annullamento del drag: annulla l'espansione pendente
    procedure ResetDragAndDropObjects; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateSelection; override;

    // Sovrascrive l'auto-espansione immediata del nodo "hot" durante il drag:
    // invece di espandere subito, accoda l'espansione con un ritardo.
    procedure ToggleHotTrackState(AItem: TdxCustomLayoutItem); override;
  end;

var
  zLayoutCustomizeForm: TzLayoutCustomizeForm;

implementation

uses
  Vcl.Clipbrd,
  zMsg;

{$R *.dfm}

type
  TdxLayoutContainerAccess = class(TdxLayoutContainer);
  TdxTreeViewNodeViewInfoAccess = class(TdxTreeViewNodeViewInfo);
  TdxCustomTreeViewAccess = class(TdxCustomTreeView);

const
  // Ritardo (in ms) prima che un nodo collassato venga auto-espanso quando il
  // cursore vi sosta sopra durante il drag&drop. DevExpress, di default,
  // espande IMMEDIATAMENTE (0 ms): cio' rende impossibile passare sopra i nodi
  // che si erano chiusi per navigare l'albero. Aumentando il ritardo, il nodo
  // si espande solo se ci si ferma davvero sopra per il tempo indicato.
  // - alzare il valore  -> serve sostare piu' a lungo per espandere
  // - valore molto alto -> di fatto disabilita l'auto-espansione
  EXPAND_HOVER_DELAY = 1200;

constructor TzLayoutCustomizeForm.Create(AOwner: TComponent);
begin
  inherited;
  Width := 640;
  Height := 480;
  BorderIcons := BorderIcons + [biMaximize];

  cxRTTIInspector.ObjectInspector.OptionsView.RowHeaderWidth := 143;

  ExpandPendingItem := nil;

  ExpandTimer.Enabled := False;
  ExpandTimer.Interval := EXPAND_HOVER_DELAY;

  // Quando si seleziona sul layout il focus resta sulla schermata, e DevExpress
  // disegna la selezione dell'albero con i colori "inattivi", poco visibili.
  // La selezione si mostra sempre e la si disegna con i colori di quella attiva;
  // il gestore preesistente (se c'e') resta in catena per gli altri nodi.
  tvVisibleItems.OptionsSelection.HideSelection := False;
  PreviousVisibleItemsCustomDrawNode := tvVisibleItems.OnCustomDrawNode;
  tvVisibleItems.OnCustomDrawNode := VisibleItemsCustomDrawNode;
end;

destructor TzLayoutCustomizeForm.Destroy;
begin
  // Mantis #202 - 2026-10-02: AV alla chiusura dell'editor con X o Chiudi.
  // Chiusa dall'utente, la form viene liberata con Release, e il distruttore
  // DevExpress libera i dizionari dei nodi PRIMA di spegnere la
  // personalizzazione (SetContainer(nil) -> Customization := False), mentre
  // Container.OnItemChanged punta ancora a questa form: un gestore di
  // OnCustomization che tocca gli item (TzDbCard.SyncLayoutFromEditor
  // riscrive le caption) finisce in FindNodeByItem su un dizionario nil.
  // Spegnendola qui, OnCustomization gira con la form ancora integra; la
  // chiamata successiva di SetContainer(nil) non fa nulla perche'
  // Customization e' gia' False. Nessuna doppia liberazione:
  // DestroyCustomizeForm salta il Free se la form e' gia' csDestroying.
  CancelPendingExpand;
  if Assigned(Container) then
    Container.Customization := False;
  inherited;
end;

procedure TzLayoutCustomizeForm.UpdateSelection;
var
  Persistent: TPersistent;
begin
  inherited;

  Persistent := nil;

  if tvVisibleItems.SelectionCount = 1 then
    if tvVisibleItems.Selections[0].Data <> nil then
      Persistent := TPersistent(tvVisibleItems.Selections[0].Data);

  if not Assigned(Persistent) then
    if tvAvailableItems.SelectionCount = 1 then
      if tvAvailableItems.Selections[0].Data <> nil then
        Persistent := TPersistent(tvAvailableItems.Selections[0].Data);

  if not Assigned(Persistent) then
    { TODO : IMPLEMENTARE }
    Persistent := nil; // Control.Items; // root

  if cxRTTIInspector.InspectedObject <> Persistent then
    cxRTTIInspector.InspectedObject := Persistent;

  // La selezione fatta cliccando sul layout arriva qui. DevExpress seleziona il
  // nodo, espande i padri e scorre l'albero nello stesso passaggio, quando le
  // righe appena aperte non sono ancora state ricalcolate: lo scorrimento parte
  // da posizioni vecchie e il nodo selezionato resta fuori vista (succede con
  // i layout profondi, es. la form incorporata con il suo FormController).
  // Il messaggio differito ripete l'operazione ad albero ormai aggiornato.
  if HandleAllocated then
    PostMessage(Handle, WM_ZLAYOUT_REVEAL_SELECTION, 0, 0);
end;

procedure TzLayoutCustomizeForm.WMRevealSelection(var Message: TMessage);
begin
  // Form in chiusura o in aggiornamento: la selezione verra' riallineata
  // dalla prossima UpdateSelection.
  if (csDestroying in ComponentState) or IsLocked then
    Exit;

  // Durante il trascinamento l'albero lo governa ToggleHotTrackState.
  if (DragHelper <> nil) and (DragHelper.DragItem <> nil) then
    Exit;

  if tvVisibleItems.SelectionCount > 0 then
    RevealSelectedNode(tvVisibleItems)
  else if tvAvailableItems.SelectionCount > 0 then
    RevealSelectedNode(tvAvailableItems);
end;

procedure TzLayoutCustomizeForm.RevealSelectedNode(TreeView: TdxTreeViewControl);
var
  Node: TdxTreeViewNode;
  ParentNode: TdxTreeViewNode;
begin
  if not TreeView.Visible then
    Exit;

  // Stesso nodo che DevExpress rende attivo in TdxCustomTreeView.Select.
  Node := TreeView.Selections[0];
  if (Node = nil) or Node.IsRoot then
    Exit;

  // Apre i gruppi che contengono il nodo, altrimenti resterebbe nascosto.
  ParentNode := Node.Parent;
  while (ParentNode <> nil) and not ParentNode.IsRoot do
  begin
    ParentNode.Expanded := True;
    ParentNode := ParentNode.Parent;
  end;

  // Nodo attivo dell'albero (rettangolo di focus): con la selezione multipla
  // non cambia la selezione, sposta solo il nodo corrente.
  Node.Focused := True;

  // Lo scorrimento si rifa' anche se il nodo era gia' quello attivo: in quel
  // caso SetFocusedNode non scorrerebbe.
  TreeView.MakeVisible(Node);
end;

procedure TzLayoutCustomizeForm.VisibleItemsCustomDrawNode(Sender: TdxCustomTreeView; Canvas: TcxCanvas; NodeViewInfo: TdxTreeViewNodeViewInfo; var Handled: Boolean);
var
  State: TdxTreeViewNodeStates;
begin
  // Con il focus sull'albero, o per i nodi non selezionati, disegna DevExpress
  // (o il gestore preesistente).
  if Sender.Focused or not NodeViewInfo.HasSelection or NodeViewInfo.Node.Deleting then
  begin
    if Assigned(PreviousVisibleItemsCustomDrawNode) then
      PreviousVisibleItemsCustomDrawNode(Sender, Canvas, NodeViewInfo, Handled);
    Exit;
  end;

  // Stato della selezione attiva, senza dxtnsInactive che DevExpress aggiunge
  // quando l'albero non ha il focus (TdxTreeViewNodeViewInfo.GetState).
  State := [dxtnsSelected];
  if not Sender.Enabled then
    Include(State, dxtnsDisabled);

  NodeViewInfo.LookAndFeelPainter.DrawTreeViewNodeBackground(Canvas, NodeViewInfo.SelectionRect, State);
  // DrawCaption scrive con FTextColor, calcolato da DevExpress con lo stato
  // inattivo prima di chiamare questo gestore.
  TdxTreeViewNodeViewInfoAccess(NodeViewInfo).FTextColor := NodeViewInfo.LookAndFeelPainter.GetTreeViewNodeTextColor(State);

  // Il resto come TdxTreeViewNodeViewInfo.DefaultDraw, senza DrawSelection che
  // ridisegnerebbe lo sfondo inattivo.
  if NodeViewInfo.HasTreeLines then
    NodeViewInfo.DrawTreeLines(Canvas);
  if NodeViewInfo.HasExpandButton then
    NodeViewInfo.DrawExpandButton(Canvas);
  if NodeViewInfo.HasCheckBox then
    NodeViewInfo.DrawCheckBox(Canvas);
  if NodeViewInfo.HasImage then
    NodeViewInfo.DrawImage(Canvas);
  if NodeViewInfo.HasStateImage then
    NodeViewInfo.DrawStateImage(Canvas);
  if not (Sender.IsEditing and (NodeViewInfo.Node = TdxCustomTreeViewAccess(Sender).EditingItem)) then
    NodeViewInfo.DrawCaption(Canvas);

  Handled := True;
end;

// ----------------------------------------------------------------------------
// Auto-espansione ritardata durante il drag&drop
// ----------------------------------------------------------------------------

procedure TzLayoutCustomizeForm.ToggleHotTrackState(AItem: TdxCustomLayoutItem);
var
  ANode: TdxTreeViewNode;
begin
  // Replica la logica della base (toggle del DropTarget + invalidate) ma, al
  // posto dell'espansione IMMEDIATA del nodo collassato, accoda l'espansione
  // tramite timer. Cosi' il nodo si espande solo se il cursore vi sosta sopra
  // per almeno EXPAND_HOVER_DELAY ms.
  if FindNodeByItem(AItem, ANode) and ANode.IsVisible then
  begin
    ANode.DropTarget := not ANode.DropTarget;

    if ANode.DropTarget and ANode.HasChildren and not ANode.Expanded then
    begin
      // Il nodo e' diventato il bersaglio del drop ed e' collassato:
      // programma l'espansione ritardata (riavviando il conteggio).
      ExpandPendingItem := AItem;
      ExpandTimer.Enabled := False;
      ExpandTimer.Enabled := True;
      ANode.Invalidate; // evidenzia il bersaglio senza espanderlo subito
    end
    else
    begin
      // Stiamo lasciando il nodo (DropTarget=False) oppure e' gia' espanso:
      // annulla un'eventuale espansione pendente relativa a questo nodo.
      if ExpandPendingItem = AItem then
        CancelPendingExpand;
      ANode.Invalidate;
    end;
  end;
end;

procedure TzLayoutCustomizeForm.CancelPendingExpand;
begin
  ExpandTimer.Enabled := False;
  ExpandPendingItem := nil;
end;

procedure TzLayoutCustomizeForm.ResetDragAndDropObjects;
begin
  CancelPendingExpand;
  inherited;
end;

// ----------------------------------------------------------------------------

procedure TzLayoutCustomizeForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  // 10.05.2011 AV in chiusura.
  CancelPendingExpand;
  tvVisibleItems.OnDeletion := nil;
  tvAvailableItems.OnDeletion := nil;
end;

procedure TzLayoutCustomizeForm.FormShow(Sender: TObject);
begin
  inherited;
  // garantisce la completa visibilita' anche in configurazioni multi-monitor
  // (con monitor a sinistra/sopra il principale, Left/Top negativi sono legittimi)
  MakeFullyVisible(Monitor);
end;

procedure TzLayoutCustomizeForm.HideTabsExecute(Sender: TObject);
begin
  inherited;

  if ConfirmYesNo('Si desidera nascondere tutti i PageControl?') then
    SetTabsVisibility(False);
end;

procedure TzLayoutCustomizeForm.ShowTabsExecute(Sender: TObject);
begin
  inherited;

  if ConfirmYesNo('Si desidera mostrare tutti i PageControl?') then
    SetTabsVisibility(True);
end;

procedure TzLayoutCustomizeForm.SetTabsVisibility(Const Visible: boolean);
var
  i: integer;
  group: TdxLayoutGroup;
begin
  Screen.Cursor := crHourGlass;
  try
    Container.BeginUpdate;
    try
      for i := 0 to Container.AbsoluteItemCount - 1 do
        if Container.AbsoluteItems[i] is TdxLayoutGroup then
        begin
          group := TdxLayoutGroup(Container.AbsoluteItems[i]);
          group.TabbedOptions.HideTabs := not Visible;
          // NB: rimosso "group.ShowBorder := False;".
          // Mostrare/nascondere le tab NON deve toccare i bordi: era un effetto
          // collaterale che azzerava ShowBorder su TUTTI i gruppi ad ogni
          // Show/Hide Tabs. Per agire sui bordi usare l'azione "Hide Borders".
        end;
    finally
      Container.EndUpdate;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TzLayoutCustomizeForm.HideBordersExecute(Sender: TObject);
var
  i: integer;
  group: TdxLayoutGroup;
begin
  Screen.Cursor := crHourGlass;
  try
    Container.BeginUpdate;
    try
      for i := 0 to Container.AbsoluteItemCount - 1 do
        if Container.AbsoluteItems[i] is TdxLayoutGroup then
        begin
          group := TdxLayoutGroup(Container.AbsoluteItems[i]);
          group.ShowBorder := False;
        end;
    finally
      Container.EndUpdate;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TzLayoutCustomizeForm.ShowSizeExecute(Sender: TObject);
var
  s: String;
  layoutControl: TdxLayoutControl;
begin
  inherited;

  if not(Container.Owner is TdxLayoutControl) then
    Exit;

  layoutControl := TdxLayoutControl(Container.Owner);

  s := 'W: ' + layoutControl.OccupiedClientWidth.ToString + ' - H: ' + layoutControl.OccupiedClientHeight.ToString;

  Clipboard.astext := s;
  ConfirmOk(s);
end;

procedure TzLayoutCustomizeForm.SalvaConNomeAccept(Sender: TObject);
var
  Stream: TFileStream;
begin
  inherited;

  TdxLayoutContainerAccess(Container).StoreToIniFile(SalvaConNome.Dialog.FileName);
  Exit;

  Stream := TFileStream.Create(SalvaConNome.Dialog.FileName, fmCreate);
  try
    TdxLayoutContainerAccess(Container).StoreToStream(Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TzLayoutCustomizeForm.CaricaDaFileAccept(Sender: TObject);
var
  Stream: TFileStream;
begin
  inherited;

  TdxLayoutContainerAccess(Container).RestoreFromIniFile(CaricaDaFile.Dialog.FileName);
  Exit;

  Stream := TFileStream.Create(CaricaDaFile.Dialog.FileName, fmOpenRead);
  try
    TdxLayoutContainerAccess(Container).RestoreFromStream(Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TzLayoutCustomizeForm.ExpandTimerTimer(Sender: TObject);
var
  ANode: TdxTreeViewNode;
  Item: TdxCustomLayoutItem;
begin
  ExpandTimer.Enabled := False;

  if not Assigned(ExpandPendingItem) then
    Exit;

  Item := ExpandPendingItem;
  ExpandPendingItem := nil;

  // Espande solo se: il drag e' ancora in corso, il nodo esiste, e' ancora il
  // bersaglio del drop ed e' tuttora collassato. Il lookup tramite
  // FindNodeByItem evita di usare puntatori a nodo potenzialmente non validi.
  if (DragHelper <> nil) and (DragHelper.DragItem <> nil) and FindNodeByItem(Item, ANode) and ANode.IsVisible and ANode.DropTarget and ANode.HasChildren and not ANode.Expanded then
    ANode.Expand(False);
end;

procedure TzLayoutCustomizeForm.FixTabsExecute(Sender: TObject);
var
  i: integer;
  group: TdxLayoutGroup;
begin
  Screen.Cursor := crHourGlass;
  try
    Container.BeginUpdate;
    try
      for i := 0 to Container.AbsoluteItemCount - 1 do
        if Container.AbsoluteItems[i] is TdxLayoutGroup then
        begin
          group := TdxLayoutGroup(Container.AbsoluteItems[i]);
          group.ShowBorder := False;

          if group.VisibleCount <= 1 then
            group.TabbedOptions.HideTabs := True;
        end;
    finally
      Container.EndUpdate;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TzLayoutCustomizeForm.FindMaintenanceHandler: IzLayoutMaintenance;
begin
  result := nil;

  if Assigned(Container) then
    result := TzLayoutMaintenanceRegistry.FindHandler(Container.Owner);
end;

procedure TzLayoutCustomizeForm.LayoutResetExecute(Sender: TObject);
var
  Handler: IzLayoutMaintenance;
begin
  inherited;

  Handler := FindMaintenanceHandler;

  if (not Assigned(Handler)) or (not Handler.CanMaintainLayout) then
  begin
    ConfirmOk('Reset non disponibile: nessun gestore registrato per questo layout.');
    Exit;
  end;

  if not ConfirmYesNo('Reimpostare il layout come appena creato?' + sLineBreak + 'Tutte le personalizzazioni andranno perse.') then
    Exit;

  Handler.ResetLayout; // accoda l'operazione: verra' eseguita alla chiusura del form
  Close;
end;

procedure TzLayoutCustomizeForm.LayoutRepairExecute(Sender: TObject);
var
  Handler: IzLayoutMaintenance;
begin
  inherited;

  Handler := FindMaintenanceHandler;

  if (not Assigned(Handler)) or (not Handler.CanMaintainLayout) then
  begin
    ConfirmOk('Riparazione non disponibile: nessun gestore registrato per questo layout.');
    Exit;
  end;

  if not ConfirmYesNo('Riparare il layout?' + sLineBreak + 'I gruppi orfani verranno ricollegati e i dataset riordinati secondo l''ordine logico.') then
    Exit;

  Handler.RepairLayout; // accoda l'operazione: verra' eseguita alla chiusura del form
  Close;
end;

end.

