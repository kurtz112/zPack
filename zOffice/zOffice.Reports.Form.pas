unit zOffice.Reports.Form;

interface

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Variants,
  System.Actions,
  System.Generics.Collections,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.ActnList,
  Vcl.StdActns,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxImageList,
  dxBar,
  cxClasses,
  dxStatusBar,
  cxContainer,
  cxEdit,
  cxListView,
  dxRibbonForm,
  dxFileActions,
  zRestrictions,
  zRestrictions.Types,
  zSystem,
  zOffice.Reports,
  dxUIAClasses,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxTextEdit,
  zOffice.Reports.types,
  zFileSystem;

type
  TzReportsForm = class(TdxRibbonForm, IRestriction)
    ActionList: TActionList;
    Anteprima: TAction;
    Modifica: TAction;
    Nuovo: TAction;
    Cartella: TAction;
    Chiudi: TAction;
    Stampanti: TAction;
    dxBarManager: TdxBarManager;
    PopupMenu: TdxBarPopupMenu;
    dxBarManagerBar: TdxBar;
    dxBarButtonAnteprima: TdxBarButton;
    dxBarButtonChiudi: TdxBarButton;
    dxBarSubItemSistema: TdxBarSubItem;
    dxBarButtonNuovo: TdxBarButton;
    dxBarButtonModifica: TdxBarButton;
    dxBarButtonCartella: TdxBarButton;
    dxBarButtonStampanti: TdxBarButton;
    actPoliticheAccessi: TAction;
    actRicaricaPolitiche: TAction;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarSubItem2: TdxBarSubItem;
    ElencoDataset: TAction;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton1: TdxBarButton;
    Proprieta: TAction;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    actPermessiAzione: TAction;
    popActions: TdxBarPopupMenu;
    Aggiorna: TAction;
    dxBarButton6: TdxBarButton;
    dxBarButton9: TdxBarButton;
    tree: TcxTreeList;
    treeColumn: TcxTreeListColumn;
    treeImages: TcxImageList;
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actPermessiAzioneExecute(Sender: TObject);
    procedure actPoliticheAccessiExecute(Sender: TObject);
    procedure actRicaricaPoliticheExecute(Sender: TObject);
    procedure AggiornaExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure AnteprimaExecute(Sender: TObject);
    procedure AnteprimaUpdate(Sender: TObject);
    procedure ModificaExecute(Sender: TObject);
    procedure NuovoExecute(Sender: TObject);
    procedure CartellaExecute(Sender: TObject);
    procedure dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
    procedure ElencoDatasetExecute(Sender: TObject);
    procedure StampantiExecute(Sender: TObject);
    procedure popActionsPopup(Sender: TObject);
    procedure ProprietaExecute(Sender: TObject);
    procedure ProprietaUpdate(Sender: TObject);
    procedure treeColumnTcxTreeListColumnSummaryFooterSummaryItems0GetText(Sender: TcxTreeListSummaryItem; const AValue: Variant; var AText: string);
    procedure treeDblClick(Sender: TObject);
    procedure treeSelectionChanged(Sender: TObject);
  private
    function IsReportSelected: Boolean;

    // Il nodo porta in Data l'oggetto del file system che rappresenta
    // (TzFolder o TzFile): nessuna ricerca per nome, che con due cartelle
    // omonime in rami diversi restituisce la prima trovata.
    function SelectedNode: TcxTreeListNode;
    function NodeFolder(Node: TcxTreeListNode): TzFolder;
    function NodeFile(Node: TcxTreeListNode): TzFile;

    function IsFolderNode(Node: TcxTreeListNode): Boolean;
    function IsReportNode(Node: TcxTreeListNode): Boolean;

    function SelectedReport: string;
    function SelectedFolder: string;
  private
    procedure FillTreeList;
    procedure SelectFirstNode;
    procedure RaccogliCataloghiProprieta;
  private
    ReportsManager: TzReportsManager;
    RestrictionManager: TRestrictionManager;
    zSystem: TzSystem;

    // Mantis #139 - 2026-09-19: TzReportsManager.LoadReports (chiamata da
    // BeforePrint prima di ogni anteprima/stampa/modifica) distrugge tutti i
    // TzFolder/TzFile sotto Reports. Node.Data, introdotto il 18/09 al posto
    // della ricerca per nome, resta pendente su quella memoria: il primo
    // aggiornamento di Anteprima letto durante l'Idle della finestra fa
    // "is TzFile" su un oggetto liberato -> access violation. I due gestori
    // si agganciano/sganciano dagli eventi del manager in ShowReportForm e
    // lasciano andare/riprendono il segnalibro attorno al ricaricamento.
    FBookMark: string;
    procedure ReportsReloading(Sender: TObject);
    procedure ReportsReloaded(Sender: TObject);

    procedure ApplyRestrictions;
    function GetRestrictionManager: TRestrictionManager;
  protected
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure ShowReportForm(aReportsManager: TzReportsManager; aSystem: TzSystem);
  end;

implementation

uses
  Winapi.ShellAPI,
  Winapi.Windows,
  Vcl.Printers,
  Vcl.Clipbrd,
  frxVariables,
  zdx,
  zz.Strings,
  zMsg,
  zFbDataSet,
  zOffice.Reports.Proprieta,
  // Solo per linkare la unit: gli editor a tendina di Profilo e Tipologia
  // documentale si registrano nella propria initialization e cxOI li trova
  // per tipo. Nessuno la citava, quindi non finiva nell'eseguibile e le
  // tendine non comparivano.
  zOffice.Reports.PropertyEditors,
  zOffice.Stampanti;

{$R *.DFM}

const
  identPdfExportEngine = 'PdfExportEngine';

constructor TzReportsForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  ReportsManager := nil;
  RestrictionManager := nil;
  zSystem := nil;
  FBookMark := '';

  ActiveControl := tree;
end;

destructor TzReportsForm.Destroy;
begin
  RootLookAndFeel.RemoveChangeListener(Self);
  FreeAndNil(RestrictionManager);
  inherited;
end;

procedure TzReportsForm.ShowReportForm(aReportsManager: TzReportsManager; aSystem: TzSystem);
begin
  ReportsManager := aReportsManager;
  zSystem := aSystem;

  RestrictionManager := TRestrictionManager.Create(Self, aSystem, Self, nil);
  RestrictionManager.AddDefaultLevel(Chiudi, 'Base', TAccessLevel.alFull);
  RestrictionManager.AddDefaultLevel(Anteprima, 'Base', TAccessLevel.alFull);
  RestrictionManager.AddDefaultLevel(Stampanti, 'Base', TAccessLevel.alFull);
  RestrictionManager.AddDefaultLevel(Nuovo, 'Base', TAccessLevel.alNone);
  RestrictionManager.AddDefaultLevel(Modifica, 'Base', TAccessLevel.alNone);
  RestrictionManager.AddDefaultLevel(Cartella, 'Base', TAccessLevel.alNone);
  RestrictionManager.AddDefaultLevel(actPoliticheAccessi, 'Base', TAccessLevel.alNone);
  RestrictionManager.AddDefaultLevel(actRicaricaPolitiche, 'Base', TAccessLevel.alNone);
  RestrictionManager.AddDefaultLevel(Proprieta, 'Base', TAccessLevel.alNone);

  if Assigned(zSystem) then
    dxBarSubItemSistema.Visible := dx.Visible(zSystem.Authorizhed(REPORT_SYSTEM_MENU_PERMISSION))
  else
    dxBarSubItemSistema.Visible := dx.Visible(False);

  // Mantis #139 - 2026-09-19: il gestore sopravvive alla finestra (vive nel
  // DataModule), quindi l'aggancio va tolto sempre, anche se ShowModal
  // solleva un'eccezione: altrimenti il gestore richiamerebbe i metodi di una
  // form gia' distrutta al primo ricaricamento successivo.
  ReportsManager.OnReportsReloading := ReportsReloading;
  ReportsManager.OnReportsReloaded := ReportsReloaded;
  try
    FillTreeList;

    ApplyRestrictions;

    SelectFirstNode;

    ActiveControl := tree;

    ShowModal;
  finally
    ReportsManager.OnReportsReloading := nil;
    ReportsManager.OnReportsReloaded := nil;
  end;
end;

procedure TzReportsForm.ReportsReloading(Sender: TObject);
begin
  // Mantis #139 - 2026-09-19: gli oggetti puntati da Node.Data stanno per
  // essere distrutti (TzReportsManager.LoadReports -> Reports.Clear): il
  // segnalibro si legge adesso, finche' i puntatori sono ancora validi, e
  // l'albero si svuota subito per non lasciare in giro nodi pendenti fino al
  // prossimo FillTreeList.
  FBookMark := SelectedReport;
  tree.Clear;
end;

procedure TzReportsForm.ReportsReloaded(Sender: TObject);
begin
  // Mantis #139 - 2026-09-19: oggetti nuovi sotto Reports, l'albero si
  // rigenera usando il segnalibro letto in ReportsReloading.
  FillTreeList;
end;

procedure TzReportsForm.actPoliticheAccessiExecute(Sender: TObject);
begin
  if Assigned(RestrictionManager) then
    RestrictionManager.EditRestrictions;
end;

procedure TzReportsForm.actRicaricaPoliticheExecute(Sender: TObject);
begin
  ApplyRestrictions;
end;

procedure TzReportsForm.ApplyRestrictions;
begin
  if Assigned(RestrictionManager) then
    RestrictionManager.ApplyRestrictions;
end;

procedure TzReportsForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzReportsForm.StampantiExecute(Sender: TObject);
begin
  MostraProprietaStampanti;
  Printer.Refresh;
end;

procedure TzReportsForm.NuovoExecute(Sender: TObject);
begin
  ReportsManager.NewReport;
  FillTreeList;
end;

procedure TzReportsForm.ModificaExecute(Sender: TObject);
begin
  if IsReportSelected then
  begin
    // Mantis #6949 - 2026-11-02: il file scelto nell'albero, non il primo omonimo per nome
    ReportsManager.DesignFile(NodeFile(SelectedNode));
    FillTreeList;
  end;
end;

procedure TzReportsForm.CartellaExecute(Sender: TObject);
var
  Folder: string;
begin
  Folder := SelectedFolder;

  if Folder.IsEmpty then
    exit;

  // La cartella dei modelli puo' non esistere ancora su disco: e' proprio il
  // caso in cui non c'e' nessun file e si preme Cartella per andarci a
  // mettere il primo. TzFolder.LoadFolder esce in silenzio se la cartella non
  // c'e' (DirectoryExists) e ShellExecute su un percorso inesistente non apre
  // niente e non segnala niente: il pulsante sembra rotto. Si crea, come
  // faceva il vecchio TzFiles.GetFolder e come fa TzReportsManager.GetFolder.
  if not DirectoryExists(Folder) then
    if not ForceDirectories(Folder) then
    begin
      ConfirmOk('Non e'' stato possibile creare la cartella ' + Folder, mtWarning);
      exit;
    end;

  ShellExecute(0, PCHAR('open'), PCHAR(Folder), nil, nil, SW_RESTORE);
end;

procedure TzReportsForm.ElencoDatasetExecute(Sender: TObject);
var
  s: String;
begin
  s := ReportsManager.DataSetNames;

  Clipboard.asText := s;
  ConfirmOk(s, mtInformation);
end;

function TzReportsForm.GetRestrictionManager: TRestrictionManager;
begin
  Result := RestrictionManager;
end;

function TzReportsForm.IsReportSelected: Boolean;
begin
  Result := not SelectedReport.IsEmpty;
end;

procedure TzReportsForm.SelectFirstNode;
var
  i: integer;
  Node: TcxTreeListNode;
begin
  for i := 0 to tree.AbsoluteVisibleCount - 1 do
  begin
    Node := tree.AbsoluteVisibleItems[i];

    if Node.Count = 0 then
    begin
      Node.MakeVisible;
      Node.Selected := true;
      exit;
    end;
  end;
end;

procedure TzReportsForm.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  if Assigned(zSystem) then
    dxBarSubItemSistema.Visible := dx.Visible(zSystem.Authorizhed(REPORT_SYSTEM_MENU_PERMISSION))
  else
    dxBarSubItemSistema.Visible := dx.Visible(False);
end;

procedure TzReportsForm.actPermessiAzioneExecute(Sender: TObject);
var
  Action: TCustomAction;
begin
  Action := TCustomAction(popActions.Tag);

  if Assigned(Action) and Assigned(RestrictionManager) then
    RestrictionManager.EditComponentRestrictions(ClassName, ccAction, Action.Name);
end;

procedure TzReportsForm.dxBarManagerBarVisibleChange(Sender: TdxBarManager; ABar: TdxBar);
begin
  dx.dxBarAssignPopupMenu(ABar, popActions);
end;

procedure TzReportsForm.ProprietaExecute(Sender: TObject);
var
  Report: TzFile;
begin
  Report := NodeFile(SelectedNode);

  // proprieta' del template = contenuto del JSON sidecar (proposto vuoto se
  // il file non esiste) + dati del TzFile in sola lettura. Il TzFile non si
  // passa direttamente all'inspector: le sue proprieta' sono public, non
  // published, e l'inspector non le mostrerebbe.
  if assigned(Report) then
  begin
    RaccogliCataloghiProprieta;
    zEditReportProprieta(Report);
  end;
end;

procedure TzReportsForm.RaccogliCataloghiProprieta;
// Riempie le due liste esposte da zOffice.Reports.Proprieta, che gli editor a
// tendina di Gruppo e MainDataset leggono quando l'inspector costruisce le
// righe. Il dato lo ha questa form (e' lei ad avere il manager sotto mano);
// gli editor, che cxOI crea per conto suo, non hanno nessun modo di risalire
// al manager: per questo il verso e' "chi ha il dato lo espone", non "chi
// mostra il dato lo va a chiedere".

  procedure EnumFolder(Folder: TzFolder);
  var
    sub: TzFolder;
  begin
    if Folder.Name <> '' then
      if zReportGruppiProposti.IndexOf(Folder.Name) < 0 then
        zReportGruppiProposti.Add(Folder.Name);

    for sub in Folder.Folders do
      EnumFolder(sub);
  end;

var
  DataSet: TzFbDataSet;
begin
  zReportGruppiProposti.Clear;
  zReportDatasetProposti.Clear;

  if not assigned(ReportsManager) then
    exit;

  if assigned(ReportsManager.Reports) then
    EnumFolder(ReportsManager.Reports);

  for DataSet in ReportsManager.DataSets do
    if zReportDatasetProposti.IndexOf(DataSet.Name) < 0 then
      zReportDatasetProposti.Add(DataSet.Name);
end;

procedure TzReportsForm.ProprietaUpdate(Sender: TObject);
begin
  if Assigned(zSystem) then
    Proprieta.Visible := zSystem.Authorizhed(REPORT_SYSTEM_MENU_PERMISSION)
  else
    Proprieta.Visible := False;
end;

procedure TzReportsForm.popActionsPopup(Sender: TObject);
begin
  if Assigned(zSystem) then
  begin
    if not zSystem.CanEditRestrictions then
      System.SysUtils.Abort;
  end
  else
    System.SysUtils.Abort;
end;

procedure TzReportsForm.AggiornaExecute(Sender: TObject);
begin
  ReportsManager.LoadReports;

  FillTreeList;

  ApplyRestrictions;

  ActiveControl := tree;
end;

procedure TzReportsForm.treeDblClick(Sender: TObject);
begin
  Anteprima.Execute;
end;

procedure TzReportsForm.treeSelectionChanged(Sender: TObject);
begin
  UpdateActions;
  tree.Summary.Recalculate;
end;

procedure TzReportsForm.AnteprimaUpdate(Sender: TObject);
begin
  Anteprima.Enabled := IsReportSelected;
end;

procedure TzReportsForm.AnteprimaExecute(Sender: TObject);
begin
  if IsReportSelected then
    // Mantis #6949 - 2026-11-02: il file scelto nell'albero, non il primo omonimo per nome
    ReportsManager.PreviewFile(NodeFile(SelectedNode));
end;

procedure TzReportsForm.treeColumnTcxTreeListColumnSummaryFooterSummaryItems0GetText(Sender: TcxTreeListSummaryItem; const AValue: Variant; var AText: string);
var
  Report: TzFile;
begin
  if not assigned(ReportsManager) then
    exit;

  Report := NodeFile(SelectedNode);

  if assigned(Report) then
    AText := Report.fullName
  else
    AText := SelectedFolder;
end;

procedure TzReportsForm.FillTreeList;

  procedure EnumFolder(Folder: TzFolder; Parent: TcxTreeListNode);
  var
    sub: TzFolder;
    zReport: TzFile;
    folderNode, fileNode: TcxTreeListNode;
  begin
    folderNode := tree.AddChild(Parent);
    folderNode.Texts[0] := Folder.Name;
    folderNode.ImageIndex := 0;
    folderNode.Data := Pointer(Folder);

    for sub in Folder.Folders do
      EnumFolder(sub, folderNode);

    for zReport in Folder.Files do
    begin
      fileNode := tree.AddChild(folderNode);
      fileNode.Texts[0] := zReport.Name;
      fileNode.Data := Pointer(zReport);

      case TReportKind.FromString(zReport.FileExt) of
        rkUnknow:
          fileNode.ImageIndex := 1;
        rkFastReport:
          fileNode.ImageIndex := 2;
        rkWord:
          fileNode.ImageIndex := 3;
        rkExcel:
          fileNode.ImageIndex := 4;
      end;
    end;
  end;

var
  i: integer;
  Node: TcxTreeListNode;
begin
  // Mantis #139 - 2026-09-19: se l'albero e' gia' vuoto, il segnalibro e'
  // stato letto da ReportsReloading un istante prima che LoadReports
  // distruggesse gli oggetti puntati dai vecchi nodi. Rileggerlo qui da
  // SelectedReport, come faceva il codice precedente, tornerebbe a fare
  // "is TzFile" su quella stessa memoria ormai liberata.
  if tree.AbsoluteVisibleCount > 0 then
    FBookMark := SelectedReport;

  tree.clear;

  EnumFolder(ReportsManager.Reports, nil);
  tree.root.Expand(true);

  ActiveControl := tree;

  if not FBookMark.IsEmpty then
    for i := 0 to tree.AbsoluteVisibleCount - 1 do
    begin
      Node := tree.AbsoluteVisibleItems[i];

      if IsReportNode(Node) then
        if Node.Texts[0] = FBookMark then
        begin
          Node.MakeVisible;
          Node.Selected := true;
          exit;
        end;
    end;
end;

function TzReportsForm.SelectedNode: TcxTreeListNode;
begin
  Result := nil;

  if tree.SelectionCount > 0 then
    Result := tree.Selections[0];
end;

function TzReportsForm.NodeFolder(Node: TcxTreeListNode): TzFolder;
var
  FileSystemObject: TObject;
begin
  Result := nil;

  if not assigned(Node) then
    exit;

  FileSystemObject := TObject(Node.Data);

  if FileSystemObject is TzFolder then
    Result := TzFolder(FileSystemObject);
end;

function TzReportsForm.NodeFile(Node: TcxTreeListNode): TzFile;
var
  FileSystemObject: TObject;
begin
  Result := nil;

  if not assigned(Node) then
    exit;

  FileSystemObject := TObject(Node.Data);

  if FileSystemObject is TzFile then
    Result := TzFile(FileSystemObject);
end;

function TzReportsForm.IsFolderNode(Node: TcxTreeListNode): Boolean;
begin
  Result := assigned(NodeFolder(Node));
end;

function TzReportsForm.IsReportNode(Node: TcxTreeListNode): Boolean;
begin
  Result := assigned(NodeFile(Node));
end;

function TzReportsForm.SelectedReport: string;
var
  Report: TzFile;
begin
  Result := '';

  Report := NodeFile(SelectedNode);

  if assigned(Report) then
    Result := Report.Name;
end;

function TzReportsForm.SelectedFolder: string;
var
  Node: TcxTreeListNode;
  Report: TzFile;
  Folder: TzFolder;
begin
  Result := '';

  Node := SelectedNode;

  Folder := NodeFolder(Node);
  if assigned(Folder) then
    exit(Folder.fullName);

  Report := NodeFile(Node);
  if assigned(Report) then
    exit(Report.Folder);

  // Nessuna selezione (albero vuoto, o messa a fuoco persa): vale la cartella
  // del gruppo di report caricato, altrimenti il pulsante Cartella non
  // avrebbe nessun bersaglio proprio quando serve di piu'.
  if assigned(ReportsManager) and assigned(ReportsManager.Reports) then
    Result := ReportsManager.Reports.fullName;
end;

end.
