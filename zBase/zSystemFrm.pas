unit zSystemFrm;

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
  StdCtrls,
  ExtCtrls,
  Grids,
  FireDAC.Comp.Client,
  zSystem,
  zCollection,
  ActnList,
  Menus,
  typinfo,
  zTypes,
  ImgList,
  OkCancel,
  ComCtrls,
  Frame_ObjectInspector,
  ToolWin,
  DB,
  zFbDataSet,
  Frame_MetaData,
  zProgressBox,
  StrUtils,
  StdActns,
  dxBar,
  cxClasses,
  cxDropDownEdit,
  cxBarEditItem,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  cxTextEdit,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxButtons,
  System.ImageList,
  System.Actions,
  dxSkinscxPCPainter,
  dxBarBuiltInMenu,
  cxPC,
  cxTL,
  cxSplitter,
  dxFileActions,
  cxImageList,
  zz.base.editor._frame,
  zSystemVerifier,
  zSystemRename,
  System.Generics.Collections,
  cxLabel,
  cxCheckBox,
  cxTLData,
  cxInplaceContainer,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTLdxBarBuiltInMenu,
  cxMaskEdit,
  dxLayoutControlAdapters,
  dxLayoutContainer,
  dxLayoutControl,
  dxLayoutcxEditAdapters,
  Frame_Collection,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzSystemForm = class(TForm)
    ActionList: TActionList;
    SelezionaTutto: TAction;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    Nuovo: TAction;
    Elimina: TAction;
    Nuovo1: TMenuItem;
    Elimina1: TMenuItem;
    Aggiorna: TAction;
    Aggiorna1: TMenuItem;
    OkCancel1: TOkCancel;
    AggiornaCache: TAction;
    Duplica: TAction;
    N2: TMenuItem;
    Duplica1: TMenuItem;
    TimerEditor: TTimer;
    Sicurezza: TAction;
    Generatori: TAction;
    ProgressBox: TProgressBox;
    CercaSQL: TAction;
    GeneraStoredProc: TdxFileSaveAs;
    dxBarManager: TdxBarManager;
    dxBarManagerBar1: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    CercaDallInizio: TAction;
    CercaSuccessivo: TAction;
    SearchPanel: TPanel;
    edCerca: TcxTextEdit;
    Label1: TLabel;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    dxBarButton10: TdxBarButton;
    SostituisciSQL: TAction;
    ReplaceDialog: TReplaceDialog;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton11: TdxBarButton;
    SostituisciCampo: TAction;
    SostituisciNomeDataset: TAction;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    dxBarButton15: TdxBarButton;
    UserConfigFolder: TAction;
    UserPersonalDataFolder: TAction;
    UsersRootConfigFolder: TAction;
    FilesAppRootFolder: TAction;
    dxBarButton16: TdxBarButton;
    dxBarButton17: TdxBarButton;
    pageMain: TcxPageControl;
    tabSystem: TcxTabSheet;
    tabMetadata: TcxTabSheet;
    FrameMetadata: TFrameMetadata;
    CollectionImageList: TcxImageList;
    FrameCollection: TFrameCollection;
    VerificheImageList: TcxImageList;

    tabVerifyResults: TcxTabSheet;
    VerifyTree: TcxTreeList;
    colSeverity: TcxTreeListColumn;
    colCategory: TcxTreeListColumn;
    colSubItem: TcxTreeListColumn;
    colMessage: TcxTreeListColumn;
    layoutVerifica: TdxLayoutControl;
    btnRecheck: TcxButton;
    btnFixSelected: TcxButton;
    btnFixAllSafe: TcxButton;
    btnPurgeDeadDomains: TcxButton;
    chkStopOnFirstError: TcxCheckBox;
    chkCheckSql: TcxCheckBox;
    chkCheckEmptySelect: TcxCheckBox;
    chkCheckStoredProcs: TcxCheckBox;
    chkCheckLookups: TcxCheckBox;
    chkCheckLookupFieldsExist: TcxCheckBox;
    chkCheckRefIntegrity: TcxCheckBox;
    // copertura delle tabelle da parte dei DataSet: solo INFO (ex "Domain/DS")
    chkCheckDomainDataSet: TcxCheckBox;
    // domini rimasti nell'LZ ma non piu' presenti nel database
    chkCheckDomainExists: TcxCheckBox;
    chkCheckAutoSql: TcxCheckBox;
    chkCheckLookupCardinality: TcxCheckBox;
    chkCheckDuplicates: TcxCheckBox;
    chkCheckGenerators: TcxCheckBox;
    chkCheckSeparators: TcxCheckBox;
    chkLookupMappingsWarning: TcxCheckBox;
    layoutVerificaGroup_Root: TdxLayoutGroup;
    dxLayoutItemVerificaRiVerifica: TdxLayoutItem;
    dxLayoutItemVerificaRiparaSelezionato: TdxLayoutItem;
    dxLayoutItemVerificaRiparaTutti: TdxLayoutItem;
    dxLayoutItemVerificaPurgeDomini: TdxLayoutItem;
    dxLayoutItemStopOnFirstError: TdxLayoutItem;
    dxLayoutItemCheckSql: TdxLayoutItem;
    dxLayoutItemCheckEmptySelect: TdxLayoutItem;
    dxLayoutItemCheckStoredProcs: TdxLayoutItem;
    dxLayoutItemCheckLookups: TdxLayoutItem;
    dxLayoutItemCheckLookupFieldsExist: TdxLayoutItem;
    dxLayoutItemCheckRefIntegrity: TdxLayoutItem;
    dxLayoutItemCheckDomainDataSet: TdxLayoutItem;
    dxLayoutItemCheckDomainExists: TdxLayoutItem;
    dxLayoutItemCheckAutoSql: TdxLayoutItem;
    dxLayoutItemCheckLookupCardinality: TdxLayoutItem;
    dxLayoutItemCheckDuplicates: TdxLayoutItem;
    dxLayoutItemCheckGenerators: TdxLayoutItem;
    dxLayoutItemCheckSeparators: TdxLayoutItem;
    dxLayoutItemLookupMappingsWarning: TdxLayoutItem;
    dxLayoutGroupBottoni: TdxLayoutGroup;
    dxLayoutGroupFlagsRow1: TdxLayoutGroup;
    dxLayoutGroupFlagsRow2: TdxLayoutGroup;
    dxLayoutGroupFlagsRow3: TdxLayoutGroup;
    dxLayoutGroupFlags: TdxLayoutGroup;
    tabRename: TcxTabSheet;
    PanelRenameTop: TPanel;
    lblRenameMode: TcxLabel;
    lblRenameQualifier: TcxLabel;
    lblRenameOld: TcxLabel;
    lblRenameNew: TcxLabel;
    cbRenameMode: TcxComboBox;
    chkRenameCase: TcxCheckBox;
    edRenameQualifier: TcxTextEdit;
    edRenameOld: TcxTextEdit;
    edRenameNew: TcxTextEdit;
    btnRenamePreview: TcxButton;
    btnRenameApply: TcxButton;
    RenameTree: TcxTreeList;
    colRnObject: TcxTreeListColumn;
    colRnScript: TcxTreeListColumn;
    colRnLine: TcxTreeListColumn;
    colRnStatus: TcxTreeListColumn;
    colRnPreview: TcxTreeListColumn;

    RenameAnteprima: TAction;
    RenameApplica: TAction;
    Verifica: TAction;
    VerificaRiVerifica: TAction;
    VerificaRiparaSelezionato: TAction;
    VerificaRiparaTutti: TAction;
    VerificaRimuoviDominiObsoleti: TAction;
    VerificaApplyBestFit: TAction;
    VerificaElimina: TAction;
    dxBarButton18: TdxBarButton;
    dxBarButton19: TdxBarButton;
    popVerifyTree: TdxBarPopupMenu;

    procedure NuovoExecute(Sender: TObject);
    procedure EliminaExecute(Sender: TObject);
    procedure AggiornaExecute(Sender: TObject);
    procedure AggiornaCacheExecute(Sender: TObject);
    procedure CercaDallInizioExecute(Sender: TObject);
    procedure CercaSQLExecute(Sender: TObject);
    procedure CercaSuccessivoExecute(Sender: TObject);
    procedure cxTabSheet2Show(Sender: TObject);
    procedure OkCancel1Apply(Sender: TObject);
    procedure DuplicaExecute(Sender: TObject);
    procedure FilesAppRootFolderExecute(Sender: TObject);
    procedure GeneraStoredProcAccept(Sender: TObject);
    procedure TimerEditorTimer(Sender: TObject);
    procedure SicurezzaExecute(Sender: TObject);
    procedure GeneratoriExecute(Sender: TObject);
    procedure SostituisciCampoExecute(Sender: TObject);
    procedure SostituisciSQLExecute(Sender: TObject);
    procedure ReplaceDialogReplaceSQL(Sender: TObject);
    procedure ReplaceDialogReplaceCampo(Sender: TObject);
    procedure ReplaceDialogReplaceNomeDataset(Sender: TObject);
    procedure SostituisciNomeDatasetExecute(Sender: TObject);
    procedure UserConfigFolderExecute(Sender: TObject);
    procedure UserPersonalDataFolderExecute(Sender: TObject);
    procedure UsersRootConfigFolderExecute(Sender: TObject);
    procedure FrameCollectionSelectNode(Sender: TObject);
    procedure FrameCollectionBeforeSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
    procedure FrameCollectionDblClick(Sender: TObject);
    procedure pageEditorChange(Sender: TObject);
    procedure VerificaExecute(Sender: TObject);
    procedure VerificaRiVerificaExecute(Sender: TObject);
    procedure VerificaRiparaSelezionatoExecute(Sender: TObject);
    procedure VerificaRiparaTuttiExecute(Sender: TObject);
    procedure VerificaRimuoviDominiObsoletiExecute(Sender: TObject);
    procedure VerificaApplyBestFitExecute(Sender: TObject);
    procedure VerificaEliminaExecute(Sender: TObject);
    procedure VerifyTreeDblClick(Sender: TObject);
    procedure VerifyTreeCustomDrawDataCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
    procedure VerifyTreeCollapsed(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
    procedure VerifyTreeExpanded(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
    procedure VerifyTreeSelectionChanged(Sender: TObject);
    procedure RenameAnteprimaExecute(Sender: TObject);
    procedure RenameApplicaExecute(Sender: TObject);
    procedure RenameTreeDblClick(Sender: TObject);
    procedure VerifyTreeResize(Sender: TObject);
  private
    // --- Verifica unificata ---
    FVerifyResults: TzVerifyResults;
    FVerifyTreeSelectionChanging: Boolean;
    function NodeResultIndex(Node: TcxTreeListNode): Integer;
    procedure FillVerifyTree;
    procedure RunUnifiedVerify;
    procedure IncolonnaVerifiche;
  private
    // --- Rename massivo SQL ---
    FRenameOccurrences: TzRenameOccurrences;
    procedure ShowRenamePanel;
    function BuildRenameEngine: TzSqlRenameEngine;
  private
    procedure doCercaSql(CercaSucecssivo: Boolean);
  private
    NodeDataDictionary, NodeByDomain, NodeByTable, NodeByCtrlType: TcxTreeListNode;
    FzSystem: TzSystem;
    ItemEditor: TzFrameEditorCollectionItem;
    procedure SetzSystem(const Value: TzSystem);
    procedure FillTreeList;
    procedure ResetDataDictionaryNodes;
    procedure FrameCollectionExpanding(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
    procedure FrameCollectionEditorChanged(Sender: TObject);
    procedure InitEditor;
    procedure ApplyEditor;
    function GetCollection: TzCustomCollection;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Edit: Boolean;
    property zSystem: TzSystem read FzSystem write SetzSystem;
  end;

function ShowSystemForm(zSystem: TzSystem): Boolean;

implementation

uses
  Winapi.ShellAPI,
  zFrmInspector,
  zBaseLib,
  zMsg,
  zStoredProcCodeFactory,
  zz.base.editor._form,
  zz.base.editor._factory,
  zDX;

{$R *.dfm}

var
  zSystemForm: TzSystemForm;

const
  // ---- Indici immagine per il TcxTreeList dei risultati verifica ----
  // Popolare l'ImageList associato a VerifyTree con queste posizioni.
  //
  // Severita' (nodi di primo livello)
  IMG_SEV_INFO = 0;
  IMG_SEV_WARNING = 1;
  IMG_SEV_ERROR = 2;
  //
  // Categorie (nodi di secondo livello) � raggruppate per famiglia logica,
  // cosi' l'ImageList resta compatto: un'icona per famiglia.
  IMG_CAT_SQL = 3; // SQL_Select / SQL / EmptySelect / StoredProc
  IMG_CAT_LOOKUP = 4; // tutte le categorie Lookup.*
  IMG_CAT_INTEGRITY = 5; // RefIntegrity / Domain.DataSet
  IMG_CAT_QUALITY = 6; // AutoSQL / Cardinality / Duplicate
  IMG_CAT_GENERATOR = 7; // Generator
  IMG_CAT_DEFAULT = 8; // fallback

  // Mappa una categoria di verifica all'indice immagine della sua famiglia.
function CategoryImageIndex(C: TzVerifyCategory): Integer;
begin
  case C of
    vcSqlSelect, vcSqlOther, vcEmptySelect, vcStoredProc:
      Result := IMG_CAT_SQL;
    vcLookupDataSet, vcLookupSelect, vcLookupFieldsFK, vcLookupDomain, vcLookupDbView, vcLookupKeyField, vcLookupMappings, vcLookupFieldExist:
      Result := IMG_CAT_LOOKUP;
    vcRefIntegrity, vcDomainExists:
      Result := IMG_CAT_INTEGRITY;
    vcAutoSql, vcLookupCardinality, vcDuplicate, vcDomainCoverage:
      Result := IMG_CAT_QUALITY;
    vcGenerator:
      Result := IMG_CAT_GENERATOR;
  else
    Result := IMG_CAT_DEFAULT;
  end;
end;

// Indice immagine per un nodo di severita'.
function SeverityImageIndex(S: TzVerifySeverity): Integer;
begin
  case S of
    vsWarning:
      Result := IMG_SEV_WARNING;
    vsError:
      Result := IMG_SEV_ERROR;
  else
    Result := IMG_SEV_INFO;
  end;
end;

function ShowSystemForm(zSystem: TzSystem): Boolean;
begin
  Result := False;

  if Assigned(zSystemForm) then // evita ricorsione
    Exit;

  zSystemForm := TzSystemForm.Create(Application);
  try
    zSystemForm.zSystem := zSystem;
    Result := zSystemForm.Edit;
  finally
    FreeAndNil(zSystemForm);
  end;
end;

constructor TzSystemForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  SearchPanel.Visible := False;

  FrameCollection.AutoUpdateInspector := False;
  FrameCollection.CheckBoxes := False;
  FrameCollection.ImageList := CollectionImageList;
  FrameCollection.OnPageChange := pageEditorChange;
  FrameCollection.TreeList.OnDblClick := FrameCollectionDblClick;
  FrameCollection.TreeList.OnExpanding := FrameCollectionExpanding;
  FrameCollection.TreeList.OnSelectionChanged := FrameCollectionSelectNode;
  FrameCollection.TreeList.OnCanSelectNode := FrameCollectionBeforeSelectNode;
  FrameCollection.OnEditorChanged := FrameCollectionEditorChanged;

  // Valori di default per le opzioni di verifica (specchio di RunUnifiedVerify)
  chkStopOnFirstError.Checked := False;
  chkCheckSql.Checked := True;
  chkCheckEmptySelect.Checked := True;
  chkCheckStoredProcs.Checked := True;
  chkCheckLookups.Checked := True;
  chkCheckLookupFieldsExist.Checked := True;
  chkCheckRefIntegrity.Checked := True;
  chkCheckDomainExists.Checked := True;
  // Copertura tabelle: spenta per default. Produce solo INFO e su un DB grande
  // sono comunque centinaia di righe (tabelle usate solo da trigger, stored
  // procedure o report): si accende quando si vuole quella misura, non sempre.
  chkCheckDomainDataSet.Checked := False;
  chkCheckAutoSql.Checked := True;
  chkCheckLookupCardinality.Checked := True;
  chkCheckDuplicates.Checked := True;
  chkCheckGenerators.Checked := True;
  chkCheckSeparators.Checked := True;
  chkLookupMappingsWarning.Checked := False;
end;

destructor TzSystemForm.Destroy;
begin
  StartWait('Rilascio memoria');
  try
    // ADATTATO: la corrente usava "DestroyEditor" (metodo locale) e
    // "FrameTreeView.Clear"; qui l'equivalente e' l'API di FrameCollection.
    FrameCollection.ClearEditor;
    ItemEditor := nil;
    FrameCollection.Clear;
    FrameMetadata.Clear;
    FreeAndNil(FVerifyResults);
    FreeAndNil(FRenameOccurrences);
  finally
    StopWait;
  end;

  inherited;
end;


// ---------------------------------------------------------------------------

procedure TzSystemForm.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
  FrameMetadata.zSystem := zSystem;
end;

function TzSystemForm.Edit: Boolean;
begin
  SiMain.EnterMethod(Self, 'Edit');

  ItemEditor := nil;
  StartWait('Loading..');
  try

    if not base.Modified then
      base.LoadZip(False);

    FillTreeList;
  finally
    StopWait;
  end;

  SiMain.LogVerbose('TreeList Caricato');

  pageMain.ActivePage := tabSystem;
  ActiveControl := FrameCollection.TreeList;
  FrameCollection.ShowInspector;
  // FrameCollection.InspectorSplitter := 150;

  Result := ShowModal = mrOk;

  StartWait('Attendere...', True);
  try
    if Result then
    begin
      ApplyEditor;
      base.SaveZip(csAll, 'ShowSystemForm');
    end
    else
      base.LoadZip(False);
  finally
    StopWait;
  end;

  SiMain.LeaveMethod(Self, 'Edit');
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.FillTreeList;
var
  DummyNode: TcxTreeListNode;
begin
  SiMain.EnterMethod(Self, 'FillTreeList');

  // Qui c'era una UpdateInspector, tolta: ricostruisce l'inspector
  // leggendo il Data dei nodi selezionati, e nel giro di Aggiorna Cache
  // quei puntatori sono gia' stati liberati da InitializeFromDB. Era
  // comunque lavoro buttato, visto che l'inspector viene azzerato due
  // righe piu' sotto.
  FrameCollection.BeginUpdate;
  try
    // Si ricostruisce da zero. FillTreeList non viene chiamata solo alla
    // prima apertura: la richiamano Aggiorna e Aggiorna Cache, e senza
    // questa pulizia il secondo giro appende una seconda copia di tutte
    // le categorie sotto la stessa radice - l'albero raddoppia e non
    // c'e' niente che lo segnali.
    //
    // L'editor si sgancia prima: Aggiorna Cache ha appena rifatto le
    // collection con InitializeFromDB, quindi l'item che l'editor stava
    // mostrando non esiste piu'. Clear azzera anche l'inspector, che
    // punta ai nodi che stiamo per distruggere.
    //
    // Si usa SetEditor(nil) e non ClearEditor: il secondo, dopo aver
    // distrutto l'editor, riporta il page control sull'inspector, e quel
    // cambio pagina fa scattare pageEditorChange -> InitEditor, che
    // ricostruirebbe un editor sul nodo ancora selezionato. Cioe'
    // proprio sull'item appena liberato.
    ItemEditor := nil;
    FrameCollection.SetEditor(nil);
    FrameCollection.Clear;

    NodeDataDictionary := FrameCollection.TreeList.Root.AddChild;
    NodeDataDictionary.Values[0] := zSystem.zDataDictionary.Name;
    NodeDataDictionary.Data := zSystem.zDataDictionary;
    NodeDataDictionary.ImageIndex := zSystem.zDataDictionary.ImageIndex;
    NodeDataDictionary.SelectedIndex := zSystem.zDataDictionary.ImageIndex;

    NodeByDomain := NodeDataDictionary.AddChild;
    NodeByDomain.Values[0] := 'By Domain';
    DummyNode := NodeByDomain.AddChild;
    DummyNode.Values[0] := '';

    NodeByTable := NodeDataDictionary.AddChild;
    NodeByTable.Values[0] := 'By Table';
    DummyNode := NodeByTable.AddChild;
    DummyNode.Values[0] := '';

    NodeByCtrlType := NodeDataDictionary.AddChild;
    NodeByCtrlType.Values[0] := 'By CtrlType';
    DummyNode := NodeByCtrlType.AddChild;
    DummyNode.Values[0] := '';

    FrameCollection.AddCollection(zSystem.zDataSets);
    FrameCollection.AddCollection(zSystem.zDataModules);
    FrameCollection.AddCollection(zSystem.zStoredProcs);
    FrameCollection.AddCollection(zSystem.zDbCards);
    FrameCollection.AddCollection(zSystem.zDbViews);
    FrameCollection.AddCollection(zSystem.zDbPivots);
    FrameCollection.AddCollection(zSystem.zDbRecordViews);
    FrameCollection.AddCollection(zSystem.zDbTrees);
    FrameCollection.AddCollection(zSystem.zDbCharts);
    FrameCollection.AddCollection(zSystem.zDbSchedulers);
    FrameCollection.AddCollection(zSystem.zGenerators);
    FrameCollection.AddCollection(zSystem.zLookups);
    FrameCollection.AddCollection(zSystem.zPickLists);
    FrameCollection.AddCollection(zSystem.zForms);
    FrameCollection.AddCollection(zSystem.zWizards);
    FrameCollection.AddCollection(zSystem.zCubes);
    FrameCollection.AddCollection(zSystem.zMaps);
    FrameCollection.AddCollection(zSystem.zFiles);
    FrameCollection.AddCollection(zSystem.zTatukMaps);
    FrameCollection.AddCollection(zSystem.zTips);
  finally
    FrameCollection.EndUpdate;
  end;

  FrameMetadata.UpdateMetadata;

  SiMain.LeaveMethod(Self, 'FillTreeList');
end;

procedure TzSystemForm.ResetDataDictionaryNodes;

  procedure ResetNode(Node: TcxTreeListNode);
  var
    DummyNode: TcxTreeListNode;
  begin
    if not Assigned(Node) then
      Exit;

    Node.Collapse(True);
    Node.DeleteChildren;
    DummyNode := Node.AddChild;
    DummyNode.Values[0] := '';
  end;

begin
  // Riporta i tre rami del DataDictionary allo stato pigro di FillTreeList
  // (un solo figlio segnaposto): i nodi gia' materializzati hanno Data che
  // punta a item che possono essere stati distrutti, e
  // FrameCollectionExpanding li ricrea alla prossima espansione.
  FrameCollection.BeginUpdate;
  try
    ResetNode(NodeByDomain);
    ResetNode(NodeByTable);
    ResetNode(NodeByCtrlType);
  finally
    FrameCollection.EndUpdate;
  end;

  FrameCollection.UpdateInspector;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.AggiornaCacheExecute(Sender: TObject);
begin
  zSystem.InitializeFromDB();

  StartWait('Aggiornamento cache...', True);
  try
    FillTreeList;

    TimerEditor.Enabled := False;
    Application.ProcessMessages;
    TimerEditor.Enabled := True;
  finally
    StopWait;
  end;

  ConfirmOk('Cache aggiornata!');
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.FrameCollectionSelectNode(Sender: TObject);
var
  Collection: TzCustomCollection;
  NewItem: TzCollectionItem;
  NewEditorClass: TzFrameEditorCollectionItemClasses;
begin
  ApplyEditor;

  Collection := GetCollection;
  if not Assigned(Collection) then
    Exit;

  Nuovo.Visible := Collection.CanInsert;
  Elimina.Visible := Collection.CanDelete;

  if not FrameCollection.EditorVisible then
    FrameCollection.ShowInspector;

  if Assigned(ItemEditor) and FrameCollection.IsCollectionItemNode(FrameCollection.SelectedNode) and (FrameCollection.TreeList.SelectionCount = 1) then
  begin
    NewItem := FrameCollection.GetCollectionItem(FrameCollection.SelectedNode);
    if Assigned(NewItem) then
    begin
      NewEditorClass := GetEditorClass(NewItem);
      if not Assigned(NewEditorClass) or (ItemEditor.ClassType <> NewEditorClass) then
      begin
        // Il tipo � cambiato: distrugge l'editor corrente prima di ricaricare
        // l'inspector, cos� non c'� mai una finestra in cui inspector e editor
        // sono disallineati sul tipo.
        FrameCollection.ClearEditor;
        ItemEditor := nil;
      end;
    end;
  end;

  FrameCollection.UpdateInspector;

  TimerEditor.Enabled := False;
  Application.ProcessMessages; // Roger ==> NoCopyFields
  TimerEditor.Enabled := True;
  // InitEditor;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.NuovoExecute(Sender: TObject);
begin
  FrameCollection.InsertItem;
end;

procedure TzSystemForm.EliminaExecute(Sender: TObject);
begin
  if ConfirmOkCancel('Eliminare gli elementi selezionati?') then
  begin
    FrameCollection.ClearEditor;
    ItemEditor := nil;
    FrameCollection.DeleteItem;
  end;
end;

function TzSystemForm.GetCollection: TzCustomCollection;
begin
  Result := FrameCollection.GetCollection(FrameCollection.SelectedNode);
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.OkCancel1Apply(Sender: TObject);
begin
  ApplyEditor;

  if Assigned(FzSystem) then
  begin
    StartWait('Attendere...', True);
    try
      zSystem.SaveZip(csAll, 'SystemForm');
    finally
      StopWait;
    end;

    ConfirmOk('Impostazioni salvate.');
  end;
end;

procedure TzSystemForm.DuplicaExecute(Sender: TObject);
begin
  FrameCollection.DuplicateItem;
end;

procedure TzSystemForm.ApplyEditor;
begin
  FrameCollection.InspectorUpdateRow;

  if Assigned(ItemEditor) and ItemEditor.Initialized then
    ItemEditor.Apply;
end;

procedure TzSystemForm.FrameCollectionEditorChanged(Sender: TObject);
begin
  // Tiene la cache tipizzata allineata all'editor reale della FrameCollection:
  // quando l'editor viene distrutto (DeleteItem, ClearEditor) la cache torna
  // nil e ApplyEditor non puo' piu' passare da un riferimento pendente.
  ItemEditor := TzFrameEditorCollectionItem(FrameCollection.Editor);
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.CercaSQLExecute(Sender: TObject);
begin
  SearchPanel.Visible := NOT SearchPanel.Visible;
  CercaSQL.Checked := SearchPanel.Visible;

  if SearchPanel.Visible then
    edCerca.SetFocus();
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.FrameCollectionDblClick(Sender: TObject);
var
  Item: TzCollectionItem;
begin
  Item := nil;
  if FrameCollection.IsCollectionItemNode(FrameCollection.SelectedNode) then
    if FrameCollection.TreeList.SelectionCount = 1 then
      Item := FrameCollection.GetCollectionItem(FrameCollection.SelectedNode);

  if Assigned(Item) then
  begin
    Edit_CollectionItem(zSystem, Item);
    FrameCollection.RefreshInspector;
  end;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.pageEditorChange(Sender: TObject);
begin
  InitEditor;
  FrameCollection.RefreshInspector;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.InitEditor;

  procedure CreateEditor(Item: TzCollectionItem);
  var
    EditorClass: TzFrameEditorCollectionItemClasses;
  begin
    if not Assigned(Item) then
    begin
      FrameCollection.ClearEditor;
      ItemEditor := nil;
      Exit;
    end;

    EditorClass := GetEditorClass(Item);

    if not Assigned(EditorClass) then
    begin
      FrameCollection.ClearEditor;
      ItemEditor := nil;
      Exit;
    end;

    if Assigned(ItemEditor) then
    begin
      if ItemEditor.ClassType = EditorClass then
        Exit
      else
      begin
        FrameCollection.ClearEditor;
        ItemEditor := nil;
      end;
    end;

    Screen.Cursor := crHourGlass;
    try
      FrameCollection.SetEditor(EditorClass.Create(Self));
    finally
      Screen.Cursor := crDefault;
    end;

    ItemEditor := TzFrameEditorCollectionItem(FrameCollection.editor);
  end;

var
  Item: TzCollectionItem;
  EditorWasVisible: Boolean;
begin
  ApplyEditor;

  Item := nil;
  if FrameCollection.IsCollectionItemNode(FrameCollection.SelectedNode) then
    if FrameCollection.TreeList.SelectionCount = 1 then
      Item := FrameCollection.GetCollectionItem(FrameCollection.SelectedNode);

  if not Assigned(Item) then
  begin
    FrameCollection.ClearEditor;
    ItemEditor := nil;
    Exit;
  end;

  EditorWasVisible := FrameCollection.EditorVisible;

  CreateEditor(Item);

  if not Assigned(ItemEditor) then
  begin
    FrameCollection.ClearEditor;
    ItemEditor := nil;
    Exit;
  end;

  if FrameCollection.EditorVisible then
  begin
    ItemEditor.zSystem := zSystem;
    ItemEditor.Item := Item;
    ItemEditor.Init;

    if EditorWasVisible then
      FrameCollection.ShowEditor;
  end;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.TimerEditorTimer(Sender: TObject);
begin
  TimerEditor.Enabled := False;

  if Self.Visible then
    InitEditor;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.SicurezzaExecute(Sender: TObject);
begin
  zSystem.zSecurity.ShowSecurityForm;
end;

procedure TzSystemForm.GeneratoriExecute(Sender: TObject);
begin
  zSystem.UpdateGenerators;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.doCercaSql(CercaSucecssivo: Boolean);
var
  i: Integer;
  Start: Integer;
  Item: TzCollectionItem;
  DataSetCount: Integer;
  StoredProcCount: Integer;
  SqlCommandCount: Integer;
  Count: Integer;
  Token: string;
  function TokenFound(const S: string): Boolean;
  begin
    Result := AnsiContainsText(S, Token);
  end;

begin
  if not Assigned(FzSystem) then
    Exit;

  edCerca.PostEditValue;
  Token := edCerca.EditValue;
  if Token = '' then
    Exit;

  ApplyEditor;
  FrameCollection.ClearEditor;
  ItemEditor := nil;

  Count := zSystem.zDataSets.Count + zSystem.zStoredProcs.Count;

  Start := 0;
  { TODO : ottimizzare.. }
  DataSetCount := zSystem.zDataSets.Count;
  StoredProcCount := zSystem.zStoredProcs.Count;

  if GetCollection = zSystem.zDataSets then
    Start := 0
  else
    if GetCollection = zSystem.zStoredProcs then
      Start := DataSetCount;

  Item := nil;
  if FrameCollection.IsCollectionItemNode(FrameCollection.SelectedNode) then
    if FrameCollection.TreeList.SelectionCount = 1 then
      Item := FrameCollection.GetCollectionItem(FrameCollection.SelectedNode);

  if CercaSucecssivo then
  begin
    if Assigned(Item) then
      Start := Start + Item.Index + 1;
  end;

  if Start < 0 then
    Start := 0;

  if Start > Count then
    Start := Count;

  ProgressBox.Show(Count - Start, 'Ricerca SQL', 'Ricerca in corso...', '');
  try
    for i := Start to zSystem.zDataSets.Count - 1 do
    begin
      Application.ProcessMessages;
      Sleep(1);

      ProgressBox.IncProgress;

      if ProgressBox.Cancelled then
        Exit;

      if TokenFound(zSystem.zDataSets[i].SQL_Select.Text) or TokenFound(zSystem.zDataSets[i].SQL_Insert.Text) or TokenFound(zSystem.zDataSets[i].SQL_Update.Text) or TokenFound(zSystem.zDataSets[i].SQL_Delete.Text) or
        TokenFound(zSystem.zDataSets[i].SQL_Refresh.Text) then
      begin
        FrameCollection.SelectCollectionItem(zSystem.zDataSets[i]);
        Exit;
      end;
    end;

    if Start > 0 then
      Start := Start - DataSetCount;

    if Start < 0 then
      Start := 0;

    if not ProgressBox.Cancelled then
      for i := Start to zSystem.zStoredProcs.Count - 1 do
      begin
        Application.ProcessMessages;
        Sleep(1);
        ProgressBox.IncProgress;

        if ProgressBox.Cancelled then
          Exit;

        if TokenFound(zSystem.zStoredProcs[i].SQL.Text) then
        begin
          FrameCollection.SelectCollectionItem(zSystem.zStoredProcs[i]);
          Exit;
        end;
      end;

    if Start > 0 then
      Start := Start - StoredProcCount;

    if Start < 0 then
      Start := 0;

  finally
    ProgressBox.Close;
  end;

  ConfirmOk(Token + ' non trovato.');
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.GeneraStoredProcAccept(Sender: TObject);
var
  DatabaseName: string;
begin
  DatabaseName := '';
  if Assigned(zSystem.zFbDatabase) then
    DatabaseName := zSystem.zFbDatabase.Params.Database;

  StartWait('Attendere...', True);
  try
    GenerateStoredProcCode(zSystem.MetaData, GeneraStoredProc.Dialog.FileName, DatabaseName);
  finally
    StopWait;
  end;
end;

procedure TzSystemForm.CercaDallInizioExecute(Sender: TObject);
begin
  doCercaSql(False);
end;

procedure TzSystemForm.CercaSuccessivoExecute(Sender: TObject);
begin
  doCercaSql(True);
end;

procedure TzSystemForm.cxTabSheet2Show(Sender: TObject);
begin
  FrameMetadata.Init;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.SostituisciSQLExecute(Sender: TObject);
begin
  ReplaceDialog.OnReplace := ReplaceDialogReplaceSQL;
  ReplaceDialog.Execute(Self.Handle);
end;

procedure TzSystemForm.SostituisciCampoExecute(Sender: TObject);
begin
  ReplaceDialog.OnReplace := ReplaceDialogReplaceCampo;
  ReplaceDialog.Execute(Self.Handle);
end;

procedure TzSystemForm.SostituisciNomeDatasetExecute(Sender: TObject);
begin
  // ReplaceDialog.OnReplace := ReplaceDialogReplaceNomeDataset;
  // ReplaceDialog.Execute(Self.Handle);
  ShowRenamePanel;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.ReplaceDialogReplaceSQL(Sender: TObject);
var
  OldToken, NewToken: string;
  zDataSet: TzDataSet;
  Lookup: TzLookup;
begin
  OldToken := ReplaceDialog.FindText;
  NewToken := ReplaceDialog.ReplaceText;

  if NewToken = '' then
    Exit;

  for zDataSet in zSystem.zDataSets do
  begin
    if SameText(zDataSet.TableName, OldToken) then
      zDataSet.TableName := NewToken;

    zDataSet.SQL_Select.Text := StringReplace(zDataSet.SQL_Select.Text, OldToken, NewToken, [rfReplaceAll, rfIgnoreCase]);
    zDataSet.SQL_Insert.Text := StringReplace(zDataSet.SQL_Insert.Text, OldToken, NewToken, [rfReplaceAll, rfIgnoreCase]);
    zDataSet.SQL_Update.Text := StringReplace(zDataSet.SQL_Update.Text, OldToken, NewToken, [rfReplaceAll, rfIgnoreCase]);
    zDataSet.SQL_Delete.Text := StringReplace(zDataSet.SQL_Delete.Text, OldToken, NewToken, [rfReplaceAll, rfIgnoreCase]);
    zDataSet.SQL_Refresh.Text := StringReplace(zDataSet.SQL_Refresh.Text, OldToken, NewToken, [rfReplaceAll, rfIgnoreCase]);
  end;

  for Lookup in zSystem.zLookups do
  begin
    if SameText(Lookup.TableName, OldToken) then
      Lookup.TableName := NewToken;

    if SameText(Lookup.TableNameFK, OldToken) then
      Lookup.TableNameFK := NewToken;
  end;

  ConfirmOk('Sostituzione completata.');

  ReplaceDialog.CloseDialog;
  InitEditor;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.ReplaceDialogReplaceCampo(Sender: TObject);
var
  oldField, newField: string;
  card: TzDbCardProps;
  view: TzDbviewProps;
  ctrl: TzControlProps;
  column: TzColumn;
  recordView: TzDbRecordViewProps;
  recordRow: TzRecordViewRow;
  // non "i": piu' sotto il metodo dichiara gia' "for var i" in linea
  IndiceMembro: integer;
  tree: TzDbTreeProps;
  treeColumn: TzTreeColumn;
  chart: TzDbChartProps;
  chartSeries: TzChartSeriesItem;
  scheduler: TzDbSchedulerProps;
  schedulerField: TzSchedulerField;
  Lookup: TzLookup;
  function replaceField(const S, oldField, newField: string): string;
  begin
    Result := S;

    if SameText(Result, oldField) then
      Result := newField
    else
      Result := StringReplace(Result, oldField + ';', newField + ';', [rfReplaceAll, rfIgnoreCase]);
  end;

begin
  oldField := ReplaceDialog.FindText;
  newField := ReplaceDialog.ReplaceText;

  if newField = '' then
    Exit;

  for card in zSystem.zDbCards do
    for ctrl in card.Controls do
      if SameText(ctrl.Name, oldField) then
        ctrl.Name := newField;

  for view in zSystem.zDbViews do
    for column in view.columns do
      if SameText(column.Name, oldField) then
        column.Name := newField;

  for recordView in zSystem.zDbRecordViews do
    for recordRow in recordView.Rows do
    begin
      if recordRow.IsField and SameText(recordRow.Name, oldField) then
        recordRow.Name := newField;

      for IndiceMembro := 0 to recordRow.Members.Count - 1 do
        if SameText(Trim(recordRow.Members[IndiceMembro]), oldField) then
          recordRow.Members[IndiceMembro] := newField;
    end;

  for tree in zSystem.zDbTrees do
  begin
    for treeColumn in tree.Columns do
      if SameText(treeColumn.Name, oldField) then
        treeColumn.Name := newField;

    if SameText(tree.KeyFieldName, oldField) then
      tree.KeyFieldName := newField;

    if SameText(tree.ParentFieldName, oldField) then
      tree.ParentFieldName := newField;

    if SameText(tree.ImageIndexFieldName, oldField) then
      tree.ImageIndexFieldName := newField;

    if SameText(tree.PreviewFieldName, oldField) then
      tree.PreviewFieldName := newField;
  end;

  for chart in zSystem.zDbCharts do
  begin
    for chartSeries in chart.Series do
      if SameText(chartSeries.Name, oldField) then
        chartSeries.Name := newField;

    if SameText(chart.ArgumentField, oldField) then
      chart.ArgumentField := newField;
  end;

  for scheduler in zSystem.zDbSchedulers do
  begin
    for schedulerField := Low(TzSchedulerField) to High(TzSchedulerField) do
      if SameText(scheduler.Mapping.Configured(schedulerField), oldField) then
        scheduler.Mapping.SetConfigured(schedulerField, newField);

    if SameText(scheduler.ResourceIdField, oldField) then
      scheduler.ResourceIdField := newField;

    if SameText(scheduler.ResourceNameField, oldField) then
      scheduler.ResourceNameField := newField;

    if SameText(scheduler.ResourceColorField, oldField) then
      scheduler.ResourceColorField := newField;
  end;

  for Lookup in zSystem.zLookups do
  begin
    // TODO : BASE.LOOKUPS Lookup.ForeignKeyFields := replaceField(Lookup.ForeignKeyFields, oldField, newField);
    Lookup.FieldNames := replaceField(Lookup.FieldNames, oldField, newField);
    Lookup.FieldNamesFK := replaceField(Lookup.FieldNamesFK, oldField, newField);
    // TODO : BASE.LOOKUPS Lookup.ListFields := replaceField(Lookup.ListFields, oldField, newField);
    Lookup.MasterFields := replaceField(Lookup.MasterFields, oldField, newField);
    // TODO : BASE.LOOKUPS Lookup.SearchFields := replaceField(Lookup.SearchFields, oldField, newField);

    for var i := 0 to Lookup.Mappings.Count - 1 do
    begin
      if SameText(Lookup.Mappings.Names[i], oldField) then
        Lookup.Mappings[i] := newField + '=' + Lookup.Mappings.ValueFromIndex[i];

      if SameText(Lookup.Mappings.ValueFromIndex[i], oldField) then
        Lookup.Mappings.ValueFromIndex[i] := newField;
    end;
  end;

  ConfirmOk('Sostituzione completata.');

  ReplaceDialog.CloseDialog;
  InitEditor;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.ReplaceDialogReplaceNomeDataset(Sender: TObject);
var
  newName: string;
  oldName: string;
  zDataSet: TzDataSet;
  view: TzDbviewProps;
  card: TzDbCardProps;
  pivot: TzDbPivotProps;
  recordView: TzDbRecordViewProps;
  tree: TzDbTreeProps;
  chart: TzDbChartProps;
  scheduler: TzDbSchedulerProps;
  Lookup: TzLookup;
begin
  oldName := ReplaceDialog.FindText;
  newName := ReplaceDialog.ReplaceText;

  if newName = '' then
    Exit;

  for zDataSet in zSystem.zDataSets do
    if SameText(zDataSet.Name, oldName) then
      zDataSet.Name := newName;

  for view in zSystem.zDbViews do
  begin
    if SameText(view.Name, oldName) then
      view.Name := newName;

    if SameText(view.DataSet, oldName) then
      view.DataSet := newName;
  end;

  for card in zSystem.zDbCards do
  begin
    if SameText(card.Name, oldName) then
      card.Name := newName;

    if SameText(card.DataSet, oldName) then
      card.DataSet := newName;
  end;

  for pivot in zSystem.zDbPivots do
  begin
    if SameText(pivot.Name, oldName) then
      pivot.Name := newName;

    if SameText(pivot.DataSet, oldName) then
      pivot.DataSet := newName;
  end;

  for recordView in zSystem.zDbRecordViews do
  begin
    if SameText(recordView.Name, oldName) then
      recordView.Name := newName;

    if SameText(recordView.DataSet, oldName) then
      recordView.DataSet := newName;
  end;

  for tree in zSystem.zDbTrees do
  begin
    if SameText(tree.Name, oldName) then
      tree.Name := newName;

    if SameText(tree.DataSet, oldName) then
      tree.DataSet := newName;
  end;

  for chart in zSystem.zDbCharts do
  begin
    if SameText(chart.Name, oldName) then
      chart.Name := newName;

    if SameText(chart.DataSet, oldName) then
      chart.DataSet := newName;
  end;

  for scheduler in zSystem.zDbSchedulers do
  begin
    if SameText(scheduler.Name, oldName) then
      scheduler.Name := newName;

    // ResourceDataSet e' il solo nome, nel modulo di DataSet: si confronta
    // prima di aggiornare DataSet
    if (scheduler.ResourceDataSet <> '') and (Pos('.', scheduler.DataSet) > 0) and (Pos('.', newName) > 0) then
      if SameText(Copy(scheduler.DataSet, 1, Pos('.', scheduler.DataSet)) + scheduler.ResourceDataSet, oldName) then
        scheduler.ResourceDataSet := Copy(newName, Pos('.', newName) + 1, MaxInt);

    if SameText(scheduler.DataSet, oldName) then
      scheduler.DataSet := newName;
  end;

  for Lookup in zSystem.zLookups do
  begin
    if SameText(Lookup.DataSet, oldName) then
      Lookup.DataSet := newName;

    if SameText(Lookup.DbView, oldName) then
      Lookup.DbView := newName;
  end;

  ConfirmOk('Sostituzione completata.');

  ReplaceDialog.CloseDialog;
  InitEditor;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.UserConfigFolderExecute(Sender: TObject);
begin
  ShellExecute(0, PCHAR('open'), PCHAR(zSystem.ConfigFolder), nil, nil, SW_RESTORE);
end;

procedure TzSystemForm.UserPersonalDataFolderExecute(Sender: TObject);
begin
  ShellExecute(0, PCHAR('open'), PCHAR(zSystem.Root_PersonalData), nil, nil, SW_RESTORE);
end;

procedure TzSystemForm.UsersRootConfigFolderExecute(Sender: TObject);
begin
  ShellExecute(0, PCHAR('open'), PCHAR(zSystem.Root_Config), nil, nil, SW_RESTORE);
end;

procedure TzSystemForm.FilesAppRootFolderExecute(Sender: TObject);
begin
  ShellExecute(0, PCHAR('open'), PCHAR(zSystem.Root_Files), nil, nil, SW_RESTORE);
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.FrameCollectionBeforeSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
begin
  ApplyEditor;
end;

procedure TzSystemForm.FrameCollectionExpanding(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
begin
  if ANode.Count = 1 then
  begin
    FrameCollection.BeginUpdate;
    try
      if ANode = NodeByDomain then
        zSystem.zDataDictionary.AddNodesToTreeList(ANode, doByDomain)
      else
        if ANode = NodeByTable then
          zSystem.zDataDictionary.AddNodesToTreeList(ANode, doByTable)
        else
          if ANode = NodeByCtrlType then
            zSystem.zDataDictionary.AddNodesToTreeList(ANode, doByCtrlType);
    finally
      FrameCollection.EndUpdate;
    end;
  end;
end;

// ---------------------------------------------------------------------------

procedure TzSystemForm.AggiornaExecute(Sender: TObject);
begin
  StartWait('Attendere...', True);
  try
    FrameCollection.UpdateInspector;
    FillTreeList;
  finally
    StopWait;
  end;
end;

// ---------------------------------------------------------------------------

// Fase 1: verifica unica (SQL + StoredProc + Lookup + controlli aggiuntivi),
// raccolta in FVerifyResults SENZA fermarsi e SENZA UI durante il giro. Poi
// Fase 2: popola il pannello.
procedure TzSystemForm.RunUnifiedVerify;
var
  FDQuery: TFDQuery;
  Verifier: TzSystemVerifier;
begin
  if not Assigned(FzSystem) then
    Exit;

  ApplyEditor;
  // ADATTATO: la corrente chiamava "DestroyEditor" (metodo locale).
  FrameCollection.ClearEditor;
  ItemEditor := nil;

  if not Assigned(FVerifyResults) then
    FVerifyResults := TzVerifyResults.Create
  else
    FVerifyResults.Clear;

  FDQuery := TFDQuery.Create(Self);
  try
    FDQuery.Connection := zSystem.zFbDatabase;
    FDQuery.Transaction := zSystem.zFbTransaction;

    Verifier := TzSystemVerifier.Create(zSystem, FDQuery);
    try
      Verifier.StopOnFirstError := chkStopOnFirstError.Checked;
      Verifier.CheckSql := chkCheckSql.Checked;
      Verifier.CheckEmptySelect := chkCheckEmptySelect.Checked;
      Verifier.CheckStoredProcs := chkCheckStoredProcs.Checked;
      Verifier.CheckLookups := chkCheckLookups.Checked;
      Verifier.CheckLookupFieldsExist := chkCheckLookupFieldsExist.Checked;
      Verifier.CheckRefIntegrity := chkCheckRefIntegrity.Checked;
      Verifier.CheckDomainExists := chkCheckDomainExists.Checked;
      Verifier.CheckDomainCoverage := chkCheckDomainDataSet.Checked;
      Verifier.CheckAutoSql := chkCheckAutoSql.Checked;
      Verifier.CheckLookupCardinality := chkCheckLookupCardinality.Checked;
      Verifier.CheckDuplicates := chkCheckDuplicates.Checked;
      Verifier.CheckGenerators := chkCheckGenerators.Checked;
      Verifier.CheckSeparators := chkCheckSeparators.Checked;
      Verifier.LookupMappingsWarning := chkLookupMappingsWarning.Checked;

      ProgressBox.Show(Verifier.EstimateTotal div 50 + 1, 'Verifica', 'Verifica in corso...', '');
      try
        Verifier.OnProgress := procedure(const Current, ATotal: Integer; const Msg: string; var Cancel: Boolean)
          begin
            // pattern canonico del ProgressBox: IncProgress(Msg) a OGNI item
            // (il Max e' Total), e lettura diretta di Cancelled.
            if (Current mod 50 = 0) then
            begin
              ProgressBox.IncProgress(Msg);
              Cancel := ProgressBox.Cancelled;
            end;
          end;

        // niente side-effect durante il giro: solo raccolta
        Verifier.VerifyAll(FVerifyResults);
      finally
        ProgressBox.Close;
      end;
    finally
      FreeAndNil(Verifier);
    end;
  finally
    FreeAndNil(FDQuery);
  end;

  // Fase 2: presentazione navigabile
  FillVerifyTree;
end;

// Crea la struttura ad albero dei risultati (Severita' -> Categoria -> Dettaglio).
procedure TzSystemForm.FillVerifyTree;
var
  i: Integer;
  R: TzVerifyResult;
  sevNodes: TDictionary<string, TcxTreeListNode>;
  catNodes: TDictionary<string, TcxTreeListNode>;
  sevKey, catKey, sevLabel: string;
  sevNode, catNode, leaf: TcxTreeListNode;

  function SevLabelOf(S: TzVerifySeverity): string;
  begin
    case S of
      vsError:
        Result := 'ERRORI';
      vsWarning:
        Result := 'WARNING';
    else
      Result := 'INFO';
    end;
  end;

begin
  VerifyTree.BeginUpdate;
  sevNodes := TDictionary<string, TcxTreeListNode>.Create;
  catNodes := TDictionary<string, TcxTreeListNode>.Create;
  try
    VerifyTree.Clear;

    if not Assigned(FVerifyResults) then
      Exit;

    for i := 0 to FVerifyResults.Count - 1 do
    begin
      R := FVerifyResults[i];
      sevLabel := SevLabelOf(R.Severity);

      // --- livello 1: nodo Severita' ---
      sevKey := sevLabel;
      if not sevNodes.TryGetValue(sevKey, sevNode) then
      begin
        sevNode := VerifyTree.Add;
        sevNode.Texts[colSeverity.ItemIndex] := sevLabel;
        sevNode.Texts[colCategory.ItemIndex] := '';
        sevNode.Texts[colSubItem.ItemIndex] := '';
        sevNode.Texts[colMessage.ItemIndex] := '';
        sevNode.Data := nil; // nodo di raggruppamento: nessun result
        sevNode.ImageIndex := SeverityImageIndex(R.Severity);
        sevNode.SelectedIndex := SeverityImageIndex(R.Severity);
        sevNodes.Add(sevKey, sevNode);
      end;

      // --- livello 2: nodo Categoria (dentro la severita') ---
      catKey := sevLabel + '|' + CategoryToStr(R.Category);
      if not catNodes.TryGetValue(catKey, catNode) then
      begin
        catNode := VerifyTree.AddChild(sevNode);
        catNode.Texts[colSeverity.ItemIndex] := '';
        catNode.Texts[colCategory.ItemIndex] := CategoryToStr(R.Category);
        catNode.Texts[colSubItem.ItemIndex] := '';
        catNode.Texts[colMessage.ItemIndex] := '';
        catNode.Data := nil;
        catNode.ImageIndex := CategoryImageIndex(R.Category);
        catNode.SelectedIndex := CategoryImageIndex(R.Category);
        catNodes.Add(catKey, catNode);
      end;

      // --- livello 3: il singolo problema ---
      leaf := VerifyTree.AddChild(catNode);
      leaf.Texts[colSeverity.ItemIndex] := '';
      leaf.Texts[colCategory.ItemIndex] := '';
      leaf.Texts[colSubItem.ItemIndex] := R.ObjectName + IfThen(R.SubItem <> '', ' / ' + R.SubItem, '');
      leaf.Texts[colMessage.ItemIndex] := R.Message;
      leaf.Data := Pointer(NativeInt(i + 1)); // indice result (1-based)
    end;

    /// ////////////////////////////////////////////////////////////////////////
    // Aggiunge il conteggio degli elementi alle etichette di Categoria (figli
    // diretti = foglie) e di Severita' (somma dei conteggi delle sue categorie).
    for catNode in catNodes.Values do
      catNode.Texts[colCategory.ItemIndex] := catNode.Texts[colCategory.ItemIndex] + Format(' (%d)', [catNode.Count]);

    for sevNode in sevNodes.Values do
    begin
      var
      sevTotal := 0;
      for var j := 0 to sevNode.Count - 1 do
        Inc(sevTotal, sevNode.Items[j].Count);

      sevNode.Texts[colSeverity.ItemIndex] := sevNode.Texts[colSeverity.ItemIndex] + Format(' (%d)', [sevTotal]);
    end;

    /// ////////////////////////////////////////////////////////////////////////
    // Espande severita' e categorie, ma lascia COLLASSATI i dettagli (foglie).
    for sevNode in sevNodes.Values do
      sevNode.Expand(False);

    for catNode in catNodes.Values do
      catNode.Collapse(False); // le foglie restano nascoste
  finally
    catNodes.Free;
    sevNodes.Free;
    VerifyTree.EndUpdate;
  end;

  // ADATTATO: la corrente usava "pageEditor.ActivePage" (pannello destro
  // nidificato dentro tabSystem); qui i due nuovi tab sono di primo livello
  // dentro pageMain (vedi 01_frammenti_dfm.txt, punto 2).
  pageMain.ActivePage := tabVerifyResults;
end;

// Colore per severita' (errore rosso, warning ambra)
procedure TzSystemForm.VerifyTreeCustomDrawDataCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
var
  Root: TcxTreeListNode;
  sev: string;
begin
  if not Assigned(AViewInfo.Node) then
    Exit;

  // risale all'antenato di primo livello (il nodo Severita')
  Root := AViewInfo.Node;
  while Assigned(Root.Parent) do
    Root := Root.Parent;

  sev := Root.Texts[colSeverity.ItemIndex];
  if SameText(sev, 'ERRORI') then
    ACanvas.Font.Color := clRed
  else
    if SameText(sev, 'WARNING') then
      ACanvas.Font.Color := $000080FF; // ambra
end;

// Restituisce l'indice del result associato al nodo (-1 se nessuno)
function TzSystemForm.NodeResultIndex(Node: TcxTreeListNode): Integer;
begin
  Result := -1;
  if not Assigned(Node) or not Assigned(Node.Data) then
    Exit;
  Result := NativeInt(Node.Data) - 1; // era 1-based
  if not Assigned(FVerifyResults) or (Result < 0) or (Result >= FVerifyResults.Count) then
    Result := -1;
end;

// Doppio-click: seleziona l'oggetto nell'albero principale e rinfresca
// l'inspector.
procedure TzSystemForm.VerifyTreeDblClick(Sender: TObject);
var
  idx: Integer;
  Item: TzCollectionItem;
begin
  idx := NodeResultIndex(VerifyTree.FocusedNode);
  if idx < 0 then
    Exit;

  Item := FVerifyResults[idx].Item;
  if not Assigned(Item) then
    Exit;

  // lazy loading dei domains
  if (Item is TzDomain) and (NodeByTable.Count = 1) then
  begin
    FrameCollection.BeginUpdate;
    try
      zSystem.zDataDictionary.AddNodesToTreeList(NodeByTable, doByTable);
    finally
      FrameCollection.EndUpdate;
    end;
  end;

  // porta comunque la selezione sull'albero (cosi' l'utente vede dov'e')
  pageMain.ActivePage := tabSystem;
  // ADATTATO: FrameTreeView.SelectCollectionItem -> FrameCollection.SelectCollectionItem
  FrameCollection.SelectCollectionItem(Item);

  // ADATTATO: RefreshInspector (metodo locale) -> FrameCollection.RefreshInspector
  FrameCollection.RefreshInspector;
end;

procedure TzSystemForm.VerificaExecute(Sender: TObject);
begin
  pageMain.ActivePage := tabVerifyResults;
  RunUnifiedVerify;
end;

procedure TzSystemForm.VerificaRiVerificaExecute(Sender: TObject);
begin
  RunUnifiedVerify;
end;

// Ripara la sola riga selezionata. fkSafe: conferma leggera. fkSuggested:
// mostra il valore proposto e chiede conferma esplicita. fkNone: avvisa.
procedure TzSystemForm.VerificaRiparaSelezionatoExecute(Sender: TObject);
var
  idx: Integer;
  R: TzVerifyResult;
begin
  idx := NodeResultIndex(VerifyTree.FocusedNode);
  if idx < 0 then
    Exit;

  R := FVerifyResults[idx];

  if (R.FixKind = fkNone) or (not Assigned(R.FixAction)) then
  begin
    ConfirmOk('Questo problema non e'' riparabile automaticamente: ' + 'correzione manuale (doppio-click per aprire l''oggetto).');
    Exit;
  end;

  if not ConfirmYesNo(R.FixDescription + sLineBreak + sLineBreak + 'Procedere?') then
    Exit;

  // backup prima di toccare l'LZ (riusa quello esistente di TzSystem)
  zSystem.BackupZip;
  R.FixAction();

  RunUnifiedVerify; // rilancia e aggiorna l'albero
end;

// Ripara in batch SOLO i fkSafe. Un solo backup, una sola conferma sul batch.
procedure TzSystemForm.VerificaRiparaTuttiExecute(Sender: TObject);
var
  i, n: Integer;
begin
  if not Assigned(FVerifyResults) then
    Exit;

  n := 0;
  for i := 0 to FVerifyResults.Count - 1 do
    if (FVerifyResults[i].FixKind = fkSafe) and Assigned(FVerifyResults[i].FixAction) then
      Inc(n);

  if n = 0 then
  begin
    ConfirmOk('Nessun problema riparabile automaticamente in sicurezza.');
    Exit;
  end;

  if not ConfirmYesNo(Format('Applicare %d correzioni sicure? ' + 'Verra'' creato un backup dell''LZ.', [n])) then
    Exit;

  zSystem.BackupZip; // un solo backup per il batch
  for i := 0 to FVerifyResults.Count - 1 do
    if (FVerifyResults[i].FixKind = fkSafe) and Assigned(FVerifyResults[i].FixAction) then
      FVerifyResults[i].FixAction();

  RunUnifiedVerify;
end;

// Rimuove in blocco i domini obsoleti (Exists = False) NON usati da alcuna
// DbView/DbCard/DbPivot. Non passa dalle FixAction dei singoli risultati: sono
// migliaia e ognuna salverebbe l'LZ. Qui: una conferma, un backup, un salvataggio.
//
// I domini obsoleti ANCORA USATI non vengono toccati: la verifica li segnala
// come errore e vanno risolti a mano (ripristinando il campo nel database o
// togliendo la colonna / il controllo dall'interfaccia).
procedure TzSystemForm.VerificaRimuoviDominiObsoletiExecute(Sender: TObject);
var
  unused, stillUsed: TStringList;
  i, idx, removed: Integer;
begin
  if not Assigned(FzSystem) then
    Exit;

  unused := TStringList.Create;
  stillUsed := TStringList.Create;
  try
    TzSystemVerifier.CollectObsoleteDomains(zSystem, unused, stillUsed);

    if unused.Count = 0 then
    begin
      if stillUsed.Count > 0 then
        ConfirmOk(Format('Nessun dominio obsoleto rimovibile. ' + '%d domini obsoleti sono ancora usati da DbView/DbCard/DbPivot ' + 'e vanno corretti a mano.', [stillUsed.Count]))
      else
        ConfirmOk('Nessun dominio obsoleto: i metadati sono allineati al database.');
      Exit;
    end;

    if not ConfirmYesNo(Format('Rimuovere %d domini non piu'' presenti nel database?' + sLineBreak + sLineBreak + '%d domini obsoleti restano (ancora usati da DbView/DbCard/DbPivot).' + sLineBreak + 'Verra'' creato un backup dell''LZ.',
      [unused.Count, stillUsed.Count])) then
      Exit;

    StartWait('Rimozione domini obsoleti...');
    try
      zSystem.BackupZip; // un solo backup per il batch
      removed := 0;

      // a ritroso non serve (si cerca per nome), ma si evita comunque di
      // ricalcolare gli indici a ogni giro
      for i := 0 to unused.Count - 1 do
      begin
        idx := zSystem.zDataDictionary.IndexOf(unused[i]);
        if idx >= 0 then
        begin
          zSystem.zDataDictionary.Delete(idx);
          Inc(removed);
        end;
      end;

      // I rami By Domain/By Table/By CtrlType gia' espansi contengono nodi
      // che puntano ai domini appena distrutti: si riportano allo stato
      // pigro, cosi' si ripopolano alla prossima espansione.
      ResetDataDictionaryNodes;

      // un solo salvataggio per tutta la rimozione
      zSystem.SaveZip(csDataDictionary, Format('Rimozione %d domini obsoleti', [removed]));
    finally
      StopWait;
    end;

    ConfirmOk(Format('Rimossi %d domini obsoleti.', [removed]));
  finally
    stillUsed.Free;
    unused.Free;
  end;

  RunUnifiedVerify;
end;

// La multi-selezione e' consentita solo sulle foglie (nodi con Data <> nil)
// e solo tra foglie dello stesso nodo-categoria (stesso parent).
procedure TzSystemForm.VerifyTreeSelectionChanged(Sender: TObject);
var
  i, j, k: Integer;
  sevNode, catNode, leaf: TcxTreeListNode;
  focused: TcxTreeListNode;
  allowedParent: TcxTreeListNode;
begin
  if FVerifyTreeSelectionChanging then
    Exit;

  focused := VerifyTree.FocusedNode;

  if not Assigned(focused) or not Assigned(focused.Data) then
    Exit;

  allowedParent := focused.Parent; // nodo categoria

  FVerifyTreeSelectionChanging := True;
  try
    for i := 0 to VerifyTree.Count - 1 do
    begin
      sevNode := VerifyTree.Items[i];
      for j := 0 to sevNode.Count - 1 do
      begin
        catNode := sevNode.Items[j];
        for k := 0 to catNode.Count - 1 do
        begin
          leaf := catNode.Items[k];
          if leaf.Selected and (catNode <> allowedParent) then
            leaf.Selected := False;
        end;
      end;
    end;
  finally
    FVerifyTreeSelectionChanging := False;
  end;
end;

procedure TzSystemForm.VerificaEliminaExecute(Sender: TObject);
var
  itemsToDelete: TList<TzCollectionItem>;
  i, idx: Integer;
  Node: TcxTreeListNode;
  Item: TzCollectionItem;
  Collection: TzCustomCollection;
begin
  if not Assigned(FVerifyResults) or (FVerifyResults.Count = 0) then
    Exit;

  if VerifyTree.SelectionCount = 0 then
    Exit;

  itemsToDelete := TList<TzCollectionItem>.Create;
  try
    // Raccoglie gli oggetti reali (TzCollectionItem) delle sole foglie
    // selezionate. I nodi di gruppo (Severita'/Categoria) hanno Data = nil:
    // NodeResultIndex restituisce -1 e vengono ignorati, come richiesto.
    for i := 0 to VerifyTree.SelectionCount - 1 do
    begin
      Node := VerifyTree.Selections[i];
      idx := NodeResultIndex(Node);
      if idx < 0 then
        Continue;

      Item := FVerifyResults[idx].Item;
      if Assigned(Item) and (itemsToDelete.IndexOf(Item) < 0) then
        itemsToDelete.Add(Item);
    end;

    if itemsToDelete.Count = 0 then
    begin
      ConfirmOk('Nessun oggetto eliminabile tra gli elementi selezionati.');
      Exit;
    end;

    if not ConfirmYesNo(Format('Eliminare definitivamente %d oggetti dalle ' + 'collection di sistema?' + sLineBreak + 'Verra'' creato un backup dell''LZ.', [itemsToDelete.Count])) then
      Exit;

    zSystem.BackupZip; // un solo backup per il batch

    // L'editor e l'inspector possono essere agganciati a uno degli item da
    // eliminare: vanno staccati prima della Free, altrimenti il primo
    // ApplyEditor scrive su memoria liberata.
    FrameCollection.ClearEditor;
    ItemEditor := nil;

    // Prima rimuove dai risultati TUTTE le righe che puntano agli oggetti da
    // eliminare (iterando a ritroso), cosi' FVerifyResults non resta con
    // riferimenti pendenti dopo la Free degli item.
    for i := FVerifyResults.Count - 1 downto 0 do
      if itemsToDelete.IndexOf(FVerifyResults[i].Item) >= 0 then
        FVerifyResults.Delete(i);

    // Poi elimina gli oggetti reali dalle rispettive collection di origine.
    // Il nodo corrispondente nel tree principale va tolto PRIMA della Free:
    // un nodo con Data pendente riprodurrebbe l'AV alla prima selezione.
    FrameCollection.BeginUpdate;
    try
      for i := 0 to itemsToDelete.Count - 1 do
      begin
        Item := itemsToDelete[i];

        Node := FrameCollection.FindNodeByInstance(Item);
        if Assigned(Node) then
          Node.Delete;

        Collection := Item.Collection as TzCustomCollection;
        Collection.Delete(Item.Index);
      end;
    finally
      FrameCollection.EndUpdate;
    end;

    zSystem.SaveZip(csAll, 'VerificaElimina');
  finally
    itemsToDelete.Free;
  end;

  FillVerifyTree;
end;

procedure TzSystemForm.ShowRenamePanel;
begin
  // ADATTATO: la corrente usava "pageEditor.ActivePage"; qui tabRename e'
  // un tab di primo livello di pageMain.
  pageMain.ActivePage := tabRename;
end;

function TzSystemForm.BuildRenameEngine: TzSqlRenameEngine;
var
  Mode: TzRenameMode;
begin
  case cbRenameMode.ItemIndex of
    0:
      Mode := rmTable;
    1:
      Mode := rmFieldGlobal;
    2:
      Mode := rmFieldQualified;
  else
    Mode := rmTable;
  end;

  Result := TzSqlRenameEngine.Create(zSystem);
  Result.Configure(Mode, edRenameOld.Text, edRenameNew.Text, chkRenameCase.Checked, edRenameQualifier.Text);
end;

procedure TzSystemForm.RenameTreeDblClick(Sender: TObject);
var
  Node: TcxTreeListNode;
  idx: Integer;
  Item: TzCollectionItem;
begin
  Node := RenameTree.FocusedNode;
  if not Assigned(Node) or not Assigned(Node.Data) then
    Exit;
  idx := NativeInt(Node.Data) - 1;
  if not Assigned(FRenameOccurrences) or (idx < 0) or (idx >= FRenameOccurrences.Count) then
    Exit;

  Item := FRenameOccurrences[idx].Item;
  if Assigned(Item) then
  begin
    // ADATTATO: FrameTreeView.SelectCollectionItem -> FrameCollection.SelectCollectionItem
    FrameCollection.SelectCollectionItem(Item);
    Edit_CollectionItem(zSystem, Item);
    // ADATTATO: RefreshInspector (metodo locale) -> FrameCollection.RefreshInspector
    FrameCollection.RefreshInspector;
  end;
end;

procedure TzSystemForm.RenameAnteprimaExecute(Sender: TObject);
var
  Engine: TzSqlRenameEngine;
  i, realHits: Integer;
  occ: TzRenameOccurrence;
  Node: TcxTreeListNode;
begin
  if Trim(edRenameOld.Text) = '' then
  begin
    ConfirmOk('Indicare il nome da rinominare.');
    Exit;
  end;

  if Trim(edRenameNew.Text) = '' then
  begin
    ConfirmOk('Indicare il nuovo nome.');
    Exit;
  end;

  // libera l'anteprima precedente
  FreeAndNil(FRenameOccurrences);

  Engine := BuildRenameEngine;
  try
    FRenameOccurrences := Engine.Preview;
  finally
    Engine.Free;
  end;

  RenameTree.BeginUpdate;
  try
    RenameTree.Clear;
    realHits := 0;
    for i := 0 to FRenameOccurrences.Count - 1 do
    begin
      occ := FRenameOccurrences[i];
      Node := RenameTree.Add;
      Node.Texts[colRnObject.ItemIndex] := occ.ObjectName;
      Node.Texts[colRnScript.ItemIndex] := ScriptKindToStr(occ.ScriptKind);
      Node.Texts[colRnLine.ItemIndex] := IntToStr(occ.LineNo);
      if occ.Ambiguous then
        Node.Texts[colRnStatus.ItemIndex] := 'AMBIGUO'
      else
      begin
        Node.Texts[colRnStatus.ItemIndex] := Format('%d hit', [occ.HitCount]);
        Inc(realHits, occ.HitCount);
      end;
      Node.Texts[colRnPreview.ItemIndex] := occ.LinePreview;
      Node.Data := Pointer(NativeInt(i + 1));
    end;
  finally
    RenameTree.EndUpdate;
  end;

  btnRenameApply.Enabled := realHits > 0;

  if realHits = 0 then
    ConfirmOk('Nessuna occorrenza da rinominare.' + sLineBreak + 'Le righe AMBIGUO (campi senza prefisso tabella) non vengono toccate.');
end;

procedure TzSystemForm.RenameApplicaExecute(Sender: TObject);
var
  Engine: TzSqlRenameEngine;
  touchedDS, touchedSP: Boolean;
  changed: Integer;
  Msg: string;
begin
  if not Assigned(FRenameOccurrences) or (FRenameOccurrences.Count = 0) then
  begin
    ConfirmOk('Esegui prima un''anteprima.');
    Exit;
  end;

  Engine := BuildRenameEngine;
  try
    Msg := Engine.Describe + sLineBreak + sLineBreak + 'Verra'' creato un backup dell''LZ prima di applicare. Procedere?';

    if not ConfirmYesNo(Msg) then
      Exit;

    zSystem.BackupZip;
    changed := Engine.Apply(touchedDS, touchedSP);

    // persistenza: salva solo le collezioni effettivamente toccate
    if touchedDS then
      zSystem.SaveZip(csDataSets, 'Rename SQL: ' + Engine.Describe);
    if touchedSP then
      zSystem.SaveZip(csStoredProcs, 'Rename SQL: ' + Engine.Describe);
  finally
    Engine.Free;
  end;

  ConfirmOk(Format('Rename completato: %d script modificati.', [changed]));

  // svuota l'anteprima (ora obsoleta) e disabilita Apply
  FreeAndNil(FRenameOccurrences);
  RenameTree.Clear;
  btnRenameApply.Enabled := False;
end;

procedure TzSystemForm.VerifyTreeResize(Sender: TObject);
begin
  IncolonnaVerifiche;
end;

procedure TzSystemForm.VerifyTreeCollapsed(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
begin
  IncolonnaVerifiche;
end;

procedure TzSystemForm.VerifyTreeExpanded(Sender: TcxCustomTreeList; ANode: TcxTreeListNode);
begin
  IncolonnaVerifiche;
end;

procedure TzSystemForm.VerificaApplyBestFitExecute(Sender: TObject);
begin
  IncolonnaVerifiche;
end;

procedure TzSystemForm.IncolonnaVerifiche;
var
  AvailableWidth: Integer;
begin
  // deve essere disattivo, altrimenti le allarga proporzionalmente;
  VerifyTree.OptionsView.ColumnAutoWidth := False;
  colSubItem.ApplyBestFit;

  AvailableWidth := VerifyTree.ClientWidth - colSeverity.Width - colCategory.Width - colSubItem.Width;
  if AvailableWidth < 100 then
    AvailableWidth := 100;

  colMessage.Width := AvailableWidth;
end;

end.zSystem

