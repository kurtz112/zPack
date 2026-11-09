// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-27
// ---------------------------------------------------------------------------
unit zDbRecordView;

// TzDbRecordView: vista di un record su griglia verticale (TcxDBVerticalGrid),
// quarto componente dati del dizionario LZ accanto a TzDbView, TzDbCard e TzDbPivot.
//
// Una riga per campo, categorie che raccolgono le righe, righe con piu' campi
// affiancati, confronto di piu' record affiancati con le differenze evidenziate.
// Le righe nascono da TzDbRecordViewProps (collezione LZ zDbRecordViews), che
// ValidateDataset allinea ai campi del dataset: senza configurazione la vista
// mostra tutti i campi visibili tranne quelli di servizio.
//
// Analisi e prove: OUT\20261001-componentizzazione-controlli-devexpress\
//   Analisi - 20261001 - Componente TzDbVerticalGrid da TcxDBVerticalGrid.md
//   Fase 0 - 20261001 - Prove TzDbVerticalGrid.md
//
// Scelte che vengono dalle prove della fase 0:
// - OptionsData.CancelOnExit, Inserting, Appending e Deleting spenti: con i
//   valori predefiniti un inserimento aperto da codice viene annullato in
//   silenzio quando il fuoco esce dalla griglia, e Ins/Ctrl+Canc della griglia
//   scavalcherebbero le azioni del frame;
// - la modifica si apre solo dalle azioni o battendo un tasto: mai ShowEdit,
//   che porta il dataset in modifica prima di consultare OnEditing;
// - il pannello di ricerca della griglia cerca nei valori e filtra i record:
//   per trovare un campo per etichetta c'e' l'azione Trova campo (Ctrl+F).

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  System.Generics.Collections,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.DBActns,
  Vcl.StdActns,
  Vcl.ImgList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxStyles,
  cxClasses,
  cxLabel,
  cxTextEdit,
  cxImageList,
  cxBarEditItem,
  cxVGrid,
  cxDBVGrid,
  cxInplaceContainer,
  dxCore,
  dxBar,
  dxBarExtItems,
  dxFileActions,
  dxFramedControl,
  dxPanel,
  ActionListController,
  zFocusedAction,
  zFbDataSet,
  zBaseLib,
  zBase.Types,
  zSystem,
  zToolActions,
  zToolFilter,
  zToolFilterHelper,
  zDataController,
  zDescription,
  zDbCardDlg,
  zDbLookupEditors,
  zDbRecordView.Rows,
  zDbRecordView.Storage, cxFilter, dxScrollbarAnnotations, cxGeometry;

type
  TzDbRecordViewCommand = (rvcUpdateActions, rvcDisplayToolbars, rvcSaveZip, rvcApplyEmptyRows, rvcFocusFirstEditable, rvcApplyTitle, rvcOpenLookups);

  // Come TzDbCardReadOnly: le props decidono, il codice della form puo' forzare
  TzDbRecordViewReadOnly = (rroUseLoadedProps, rroForceReadOnly, rroForceWriteable);

  // Le azioni del .dfm sono TzFocusedAction: con il fuoco nella vista le
  // scorciatoie restano alla vista e non passano alle altre della stessa form
  TzDbRecordView = class(TFrame, IzBaseComponent, IzBaseDbComponent, IzBaseFilterableComponent, IzShortCutConsumer)
    ActionList: TActionList;
    DataSource: TDataSource;
    Titolo: TcxLabel;
    cxDBVerticalGrid: TcxDBVerticalGrid;
    pnlDescrizione: TdxPanel;
    cxStyleRepository: TcxStyleRepository;
    cxStyleBold: TcxStyle;
    cxStyleDifferent: TcxStyle;
    dxBarManager: TdxBarManager;
    dxBarToolbar: TdxBar;
    dxBarToolbarFree: TdxBar;
    popRecordView: TdxBarPopupMenu;
    popField: TdxBarPopupMenu;
    dxBarControlContainerTitolo: TdxBarControlContainerItem;
    dxBarEditTitolo: TcxBarEditItem;
    dxBarSubItemImpostazioni: TdxBarSubItem;
    // Azioni standard di modifica del testo
    EditUndo: TEditUndo;
    EditCut: TEditCut;
    EditCopy: TEditCopy;
    EditPaste: TEditPaste;
    EditDelete: TEditDelete;
    EditSelectAll: TEditSelectAll;
    // Navigazione e modifica del record
    actDbFirst: TzFocusedAction;
    actDbPrior: TzFocusedAction;
    actDbNext: TzFocusedAction;
    actDbLast: TzFocusedAction;
    actDbRefresh: TDataSetRefresh;
    actDbInsert: TzFocusedAction;
    actDbEdit: TzFocusedAction;
    actDbDelete: TzFocusedAction;
    actDbPost: TzFocusedAction;
    actDbCancel: TzFocusedAction;
    // Vista
    actTrovaCampo: TzFocusedAction;
    actNascondiVuote: TzFocusedAction;
    actConfronta: TzFocusedAction;
    Espandi: TzFocusedAction;
    Riduci: TzFocusedAction;
    AdattaLarghezze: TzFocusedAction;
    Elabora: TzFocusedAction;
    actExcel: TdxFileSaveAs;
    actStampa: TzFocusedAction;
    Descrizione: TzFocusedAction;
    RipristinaLayout: TzFocusedAction;
    // Amministrazione
    actPersonalizza: TzFocusedAction;
    actPersonalizzaRighe: TzFocusedAction;
    actPersonalizzaRiga: TzFocusedAction;
    actPersonalizzaCampo: TzFocusedAction;
    actResetRighe: TzFocusedAction;
    SalvaImpostazioni: TzFocusedAction;
    CaricaImpostazioni: TzFocusedAction;
    actSQL: TzFocusedAction;
    MostraQueryUtilizzata: TzFocusedAction;
    CopiaQueryUtilizzata: TzFocusedAction;
    CopyName: TzFocusedAction;
    NomeFileIni: TzFocusedAction;
    EditTools: TzFocusedAction;
    // Pulsanti della barra e dei menu
    dxBarButtonactDbFirst: TdxBarButton;
    dxBarButtonactDbPrior: TdxBarButton;
    dxBarButtonactDbNext: TdxBarButton;
    dxBarButtonactDbLast: TdxBarButton;
    dxBarButtonactDbRefresh: TdxBarButton;
    dxBarButtonactDbInsert: TdxBarButton;
    dxBarButtonactDbEdit: TdxBarButton;
    dxBarButtonactDbDelete: TdxBarButton;
    dxBarButtonactDbPost: TdxBarButton;
    dxBarButtonactDbCancel: TdxBarButton;
    dxBarButtonactTrovaCampo: TdxBarButton;
    dxBarButtonactNascondiVuote: TdxBarButton;
    dxBarButtonactConfronta: TdxBarButton;
    dxBarButtonEspandi: TdxBarButton;
    dxBarButtonRiduci: TdxBarButton;
    dxBarButtonAdattaLarghezze: TdxBarButton;
    dxBarButtonElabora: TdxBarButton;
    dxBarButtonactExcel: TdxBarButton;
    dxBarButtonactStampa: TdxBarButton;
    dxBarButtonDescrizione: TdxBarButton;
    dxBarButtonRipristinaLayout: TdxBarButton;
    dxBarButtonactPersonalizza: TdxBarButton;
    dxBarButtonactPersonalizzaRighe: TdxBarButton;
    dxBarButtonactPersonalizzaRiga: TdxBarButton;
    dxBarButtonactPersonalizzaCampo: TdxBarButton;
    dxBarButtonactResetRighe: TdxBarButton;
    dxBarButtonSalvaImpostazioni: TdxBarButton;
    dxBarButtonCaricaImpostazioni: TdxBarButton;
    dxBarButtonactSQL: TdxBarButton;
    dxBarButtonMostraQueryUtilizzata: TdxBarButton;
    dxBarButtonCopiaQueryUtilizzata: TdxBarButton;
    dxBarButtonCopyName: TdxBarButton;
    dxBarButtonNomeFileIni: TdxBarButton;
    dxBarButtonEditTools: TdxBarButton;
    dxBarButtonEditUndo: TdxBarButton;
    dxBarButtonEditCut: TdxBarButton;
    dxBarButtonEditCopy: TdxBarButton;
    dxBarButtonEditPaste: TdxBarButton;
    dxBarButtonEditDelete: TdxBarButton;
    dxBarButtonEditSelectAll: TdxBarButton;
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    procedure DataSourceStateChange(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actDbFirstExecute(Sender: TObject);
    procedure actDbPriorExecute(Sender: TObject);
    procedure actDbNextExecute(Sender: TObject);
    procedure actDbLastExecute(Sender: TObject);
    procedure actDbRefreshExecute(Sender: TObject);
    procedure actDbInsertExecute(Sender: TObject);
    procedure actDbEditExecute(Sender: TObject);
    procedure actDbDeleteExecute(Sender: TObject);
    procedure actDbPostExecute(Sender: TObject);
    procedure actDbCancelExecute(Sender: TObject);
    procedure actTrovaCampoExecute(Sender: TObject);
    procedure actNascondiVuoteExecute(Sender: TObject);
    procedure actConfrontaExecute(Sender: TObject);
    procedure EspandiExecute(Sender: TObject);
    procedure RiduciExecute(Sender: TObject);
    procedure AdattaLarghezzeExecute(Sender: TObject);
    procedure ElaboraExecute(Sender: TObject);
    procedure actExcelBeforeExecute(Sender: TObject);
    procedure actExcelAccept(Sender: TObject);
    procedure actStampaExecute(Sender: TObject);
    procedure DescrizioneExecute(Sender: TObject);
    procedure RipristinaLayoutExecute(Sender: TObject);
    procedure actPersonalizzaExecute(Sender: TObject);
    procedure actPersonalizzaRigheExecute(Sender: TObject);
    procedure actPersonalizzaRigaExecute(Sender: TObject);
    procedure actPersonalizzaCampoExecute(Sender: TObject);
    procedure actResetRigheExecute(Sender: TObject);
    procedure SalvaImpostazioniExecute(Sender: TObject);
    procedure CaricaImpostazioniExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure MostraQueryUtilizzataExecute(Sender: TObject);
    procedure CopiaQueryUtilizzataExecute(Sender: TObject);
    procedure CopyNameExecute(Sender: TObject);
    procedure NomeFileIniExecute(Sender: TObject);
    procedure EditToolsExecute(Sender: TObject);
    procedure EditToolsUpdate(Sender: TObject);
    procedure dxBarEditTitoloChange(Sender: TObject);
    procedure dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
    procedure PopupRecordViewPopup(Sender: TObject);
  private
    FzDataSet: TzFbDataSet;
    FzSystem: TzSystem;
    FDataController: TzDataController;
    FzDbRecordViewProps: TzDbRecordViewProps;
    FRowsBuilder: TzDbRecordViewRowsBuilder;
    FStorage: TzDbRecordViewStorage;
    FLoadedUserLayout: TzRecordViewUserLayout;
    // larghezza voluta delle didascalie: la griglia riscrive RowHeaderWidth
    // tagliandolo alla larghezza disponibile meno ValueMinWidth
    // (CheckRowHeaderWidth di cxVGrid) e non lo ripristina quando si allarga
    FLarghezzaEtichette: Integer;
    // nessuna larghezza dal dizionario ne' dall'utente: si ricalcola sulle didascalie
    FEtichetteAutomatiche: Boolean;
    FLarghezzaPrimaDelClic: Integer;
    FGridWindowProc: TWndMethod;
    FToolActions: TzToolActions;
    ActionListController: TActionListController;
    FrameDescription: TFrameDescription;
    FReadOnly: TzDbRecordViewReadOnly;
    FRestrictionReadOnly: Boolean;
    FBuilt: Boolean;
    FLoadingProps: Boolean;
    FIsDestroying: Boolean;
    FSaveZipQueued: Boolean;
    FCompareMode: Boolean;
    FHideEmptyRows: Boolean;
    FLastSearch: string;
    // righe nascoste dal filtro dei campi vuoti, da rimettere quando si spegne
    FHiddenAsEmpty: TList<TcxCustomRow>;
    AlreadyShown: Boolean;
  private
    FOnUpdateActions: TNotifyEvent;
    FOnBeforeCreateControls: TNotifyEvent;
    FOnAfterCreateControls: TNotifyEvent;
    FOnCustomLoadProps: TNotifyEvent;
    FOnCustomSaveProps: TNotifyEvent;
    FOnDataSetInsert: TNotifyEvent;
    FOnDataSetEdit: TNotifyEvent;
    FOnDataSetDelete: TNotifyEvent;
    FOnRowCreated: TzRecordViewRowCreatedEvent;
    FOnRecordChanged: TNotifyEvent;
    FOnShowCard: TzShowCardEvent;
    // scheda di inserimento e modifica, creata al primo uso (solo in esecuzione)
    FCardDlg: TzDbCardDlg;
    FCardID: string;
    FShowingCard: Boolean;
    // lookup del dizionario negli editor delle celle
    FLookupEditors: TzLookupEditors;
  private // IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
    function GetComponentType: TzComponentType;
    function GetID: string;
    procedure SetID(const Value: string);
    function GetToolActions: TzToolActions;
    procedure SetToolActions(const Value: TzToolActions);
    function GetActionOwner: TComponent;
    function GetActionOwnerName: string;
    procedure SetActionOwnerName(const Value: string);
    procedure RebuildActions;
    function ConfigTitle: string;
    procedure RebuildToolbar;
    function GetProps: TzBaseComponentProps;
    function GetToolbar: TdxBar;
    function GetzDataSet: TzFbDataSet;
    procedure SetzDataSet(const Value: TzFbDataSet);
    function GetToolFilters: TzToolFiltersProps;
    procedure SetToolFilters(const Value: TzToolFiltersProps);
    procedure RebuildFilters;
  private
    function GetRecordViewID: string;
    procedure SetRecordViewID(const Value: string);
    function GetFlags: TzDbRecordViewFlags;
    function GetDataSourceEnabled: Boolean;
    procedure SetDataSourceEnabled(const Value: Boolean);
    procedure SetReadOnly(const Value: TzDbRecordViewReadOnly);
    procedure SetRestrictionReadOnly(const Value: Boolean);
    procedure SetzSystem(const Value: TzSystem);
    function zSystemOk: Boolean;
    function IsAdmin: Boolean;
    function EffectiveLayout: TzRecordViewLayout;
    function IsEmptyRowsFilterActive: Boolean;
  private
    procedure InitRecordView;
    procedure LoadProperties(const LoadDefaults: Boolean);
    procedure InternalLoadProperties;
    procedure InternalSaveProperties;
    procedure doSalvaImpostazioni(const Silent: Boolean = False);
    procedure ApplyGridOptions;
    procedure CreateFiltersFromProps;
    procedure DisplayToolbars;
    procedure UpdateActions;
    procedure OnFlagChange(Sender: TObject);
    procedure ToolActionsChanged(Sender: TObject);
    procedure DoRowCreated(Sender: TObject; Row: TcxCustomRow; Item: TzRecordViewRow; Field: TField);
    procedure ApplyEmptyRows;
    procedure RestoreEmptyRows;
    procedure FocusFirstEditableRow;
    function FocusedFieldName: string;
    function HasCategories: Boolean;
  private // layout personale
    function CurrentUserLayout: TzRecordViewUserLayout;
    procedure LoadUserLayout;
    procedure SaveUserLayout;
  private // descrizione
    procedure CreateDescription;
    procedure LoadDescription;
    procedure SaveDescription;
  private // eventi della griglia, assegnati nel costruttore
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridEditing(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties; var Allow: Boolean);
    procedure GridGetHeaderStyle(Sender: TObject; ARow: TcxCustomRow; var AStyle: TcxStyle);
    procedure GridGetContentStyle(Sender: TObject; AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean; ARecordIndex: Integer;
      var AStyle: TcxStyle);
    // Colori delle differenze adatti allo skin
    procedure UpdateDifferentStyle;
    procedure GridDblClick(Sender: TObject);
    procedure GridWindowProc(var Message: TMessage);
    procedure ImpostaLarghezzaEtichette(const Larghezza: Integer; const Automatica: Boolean);
    procedure ApplicaLarghezzaEtichette;
  private // scheda (TzDbCardDlg o OnShowCard), come in TzDbView
    function UsesCard: Boolean;
    function GetCardDlg: TzDbCardDlg;
    function EffectiveCardID: string;
    function ShowCard(const Inserting: Boolean): Boolean;
  private
    procedure PostInternalMessage(const Command: TzDbRecordViewCommand);
    procedure ExecuteCommand(const Command: TzDbRecordViewCommand);
    procedure MessageHandler(var Message: TMessage); message ZZ_DBRECORDVIEW;
  protected
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateDataSet;
    // Riallinea le props al dataset e ricrea le righe
    procedure RebuildRows;
    // Rilegge le props dal dizionario e ricrea la vista
    procedure ReloadProps;

    procedure ApplyHeaderBestFit;
    // Allarga soltanto la colonna delle didascalie fino alla larghezza misurata
    procedure AllargaDidascalie;
    // Larghezza che serve alle didascalie visibili, misurata in grassetto
    function LarghezzaDidascalie: Integer;
    procedure ExpandAll;
    procedure CollapseAll;

    // Righe e campi
    function RowByField(const FieldName: string): TcxCustomRow;
    function FocusField(const FieldName: string): Boolean;
    procedure ShowField(const FieldName: string);
    procedure HideField(const FieldName: string);
    procedure SetFieldReadOnly(const FieldName: string; const IsReadOnly: Boolean);
    // Categoria definita da codice (per esempio nel DataModule della form):
    // vale per la vista corrente; finisce nel dizionario solo se un
    // amministratore salva le impostazioni
    procedure DefineCategory(const CategoryName, CategoryCaption: string; const FieldNames: array of string);

    // Modifica del record
    function IsRecordViewReadOnly: Boolean;
    function ValidateRequiredFields(RaiseError: Boolean): Boolean;
    procedure Post;
    procedure Cancel;

    // Confronto di piu' record affiancati (impaginazione a piu' record)
    procedure SetCompareMode(const Value: Boolean);

    // Uscite
    procedure ExportToFile(const FileName: string);
    procedure Preview;

    function GetTitle: string;
    procedure SetTitle(const Title: string);

    procedure InitToolActions;
    procedure ExecuteToolConfig;
    function AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
  public
    property zDataSet: TzFbDataSet read FzDataSet write SetzDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property DataController: TzDataController read FDataController;
    property Grid: TcxDBVerticalGrid read cxDBVerticalGrid;
    property RowsBuilder: TzDbRecordViewRowsBuilder read FRowsBuilder;
    property RecordViewID: string read GetRecordViewID write SetRecordViewID;
    property Flags: TzDbRecordViewFlags read GetFlags;
    property zDbRecordViewProps: TzDbRecordViewProps read FzDbRecordViewProps;
    property ReadOnly: TzDbRecordViewReadOnly read FReadOnly write SetReadOnly;
    // Sola lettura imposta dai permessi sul dataset (livello di accesso)
    property RestrictionReadOnly: Boolean read FRestrictionReadOnly write SetRestrictionReadOnly;
    property CompareMode: Boolean read FCompareMode write SetCompareMode;
    property DataSourceEnabled: Boolean read GetDataSourceEnabled write SetDataSourceEnabled;
    // Scheda del record (OnShowCard o TzDbCardDlg); doInsert inserisce prima un
    // record nuovo, come TzDbView.ShowRecord
    function ShowRecord(const doInsert: Boolean): Boolean;
    // Scheda usata da TzDbCardDlg; vuoto = quella del dataset (Modulo.DataSet)
    property CardID: string read FCardID write FCardID;
    // Dialogo della scheda, per agganciarne gli eventi da codice
    property CardDlg: TzDbCardDlg read GetCardDlg;
  published
    property OnUpdateActions: TNotifyEvent read FOnUpdateActions write FOnUpdateActions;
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write FOnBeforeCreateControls;
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write FOnAfterCreateControls;
    property OnCustomLoadProps: TNotifyEvent read FOnCustomLoadProps write FOnCustomLoadProps;
    property OnCustomSaveProps: TNotifyEvent read FOnCustomSaveProps write FOnCustomSaveProps;
    // Se assegnati sostituiscono il comportamento predefinito (come in TzDbCard)
    property OnDataSetInsert: TNotifyEvent read FOnDataSetInsert write FOnDataSetInsert;
    property OnDataSetEdit: TNotifyEvent read FOnDataSetEdit write FOnDataSetEdit;
    property OnDataSetDelete: TNotifyEvent read FOnDataSetDelete write FOnDataSetDelete;
    // Se assegnato la scheda la apre la form, al posto di TzDbCardDlg
    property OnShowCard: TzShowCardEvent read FOnShowCard write FOnShowCard;
    // Per ogni riga creata, a costruzione completa: editor particolari, colori
    property OnRowCreated: TzRecordViewRowCreatedEvent read FOnRowCreated write FOnRowCreated;
    // Solo al cambio di record, non a ogni modifica di campo
    property OnRecordChanged: TNotifyEvent read FOnRecordChanged write FOnRecordChanged;
    property ToolActions: TzToolActions read GetToolActions write SetToolActions;
    property ToolFilters: TzToolFiltersProps read GetToolFilters write SetToolFilters;
  end;

implementation

uses
  Winapi.ShellAPI,
  Vcl.Clipbrd,
  cxExportVGLink,
  dxPSCore,
  dxPScxVGridLnk,
  zDX,
  zMsg,
  zFrmParams,
  zToolConfigDlg,
  zToolFilter.Builder;

{$R *.dfm}

const
  SEliminoIlRecord = 'Elimino il record?';
  SCampiObbligatori = 'Compilare i campi obbligatori:';

{ TzDbRecordView }

constructor TzDbRecordView.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FzDataSet := nil;
  FzSystem := nil;
  FrameDescription := nil;
  FReadOnly := rroUseLoadedProps;
  FRestrictionReadOnly := False;
  FBuilt := False;
  FLoadingProps := False;
  FIsDestroying := False;
  FSaveZipQueued := False;
  FCompareMode := False;
  FHideEmptyRows := False;
  FLastSearch := '';
  FHiddenAsEmpty := TList<TcxCustomRow>.Create;
  AlreadyShown := False;
  FLoadedUserLayout.Clear;
  FLarghezzaEtichette := 0;
  FEtichetteAutomatiche := True;
  FLarghezzaPrimaDelClic := 0;

  FzDbRecordViewProps := TzDbRecordViewProps.Create(nil);
  FzDbRecordViewProps.Flags.OnChange := OnFlagChange;

  FDataController := TzDataController.Create(Self);
  FRowsBuilder := TzDbRecordViewRowsBuilder.Create(cxDBVerticalGrid, FDataController);

  // oggetto semplice, non un componente: nessun rischio di finire nel .dfm
  FLookupEditors := TzLookupEditors.Create(
    function: TzSystem
    begin
      result := FzSystem;
    end,
    function: TzFbDataSet
    begin
      result := FzDataSet;
    end,
    function: string
    begin
      result := FocusedFieldName;
    end);
  FRowsBuilder.LookupEditors := FLookupEditors;
  FStorage := TzDbRecordViewStorage.Create;

  FToolActions := TzToolActions.Create(Self);
  FToolActions.OnChange := ToolActionsChanged;

  ActionListController := TActionListController.Create;

  Titolo.Visible := False;
  Titolo.PopupMenu := popRecordView;
  dxBarControlContainerTitolo.Visible := dx.Visible(False);
  dxBarToolbar.MultiLine := True;
  dxBarToolbarFree.MultiLine := True;
  dx.InitTitle(Titolo);

  // Vedi l'intestazione della unit: le operazioni sul record passano dalle azioni
  cxDBVerticalGrid.OptionsData.Inserting := False;
  cxDBVerticalGrid.OptionsData.Appending := False;
  cxDBVerticalGrid.OptionsData.Deleting := False;
  cxDBVerticalGrid.OptionsData.CancelOnExit := False;

  cxDBVerticalGrid.OnKeyDown := GridKeyDown;
  cxDBVerticalGrid.OnEditing := GridEditing;
  cxDBVerticalGrid.Styles.OnGetHeaderStyle := GridGetHeaderStyle;
  cxDBVerticalGrid.Styles.OnGetContentStyle := GridGetContentStyle;
  cxDBVerticalGrid.OnDblClick := GridDblClick;

  // la griglia non ha un evento per il ridimensionamento ne' per il
  // trascinamento del bordo delle didascalie: si guardano i messaggi
  FGridWindowProc := cxDBVerticalGrid.WindowProc;
  cxDBVerticalGrid.WindowProc := GridWindowProc;

  FOnShowCard := nil;
  FCardDlg := nil;
  FCardID := '';
  FShowingCard := False;

  UpdateDifferentStyle;

  UpdateActions;
end;

destructor TzDbRecordView.Destroy;
begin
  FIsDestroying := True;

  if Assigned(FGridWindowProc) then
    cxDBVerticalGrid.WindowProc := FGridWindowProc;

  if FBuilt and not(csDesigning in ComponentState) then
    SaveUserLayout;

  // scrittura dello zip rimasta in coda: il messaggio postato non verra' recapitato
  if FSaveZipQueued then
  begin
    FSaveZipQueued := False;
    if zSystemOk then
      zSystem.SaveZip(csDbRecordViews, 'TzDbRecordView.Destroy');
  end;

  FreeAndNil(FrameDescription);
  FreeAndNil(ActionListController);
  FreeAndNil(FToolActions);
  FreeAndNil(FHiddenAsEmpty);
  FreeAndNil(FStorage);
  // gli editor dei lookup si sganciano finche' la griglia esiste ancora
  if Assigned(FLookupEditors) then
    FLookupEditors.Clear;
  if Assigned(FRowsBuilder) then
    FRowsBuilder.LookupEditors := nil;
  FreeAndNil(FLookupEditors);
  FreeAndNil(FRowsBuilder);
  FreeAndNil(FDataController);
  FreeAndNil(FzDbRecordViewProps);
  inherited;
end;

procedure TzDbRecordView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation <> opRemove then
    Exit;

  if AComponent = FzSystem then
    FzSystem := nil;

  if AComponent = FzDataSet then
  begin
    FzDataSet := nil;
    if Assigned(FDataController) then
      FDataController.DataSet := nil;
  end;

  if (AComponent is TAction) or (AComponent is TImageList) then
    if Assigned(FToolActions) then
      FToolActions.RemoveNotification(AComponent);
end;

procedure TzDbRecordView.CMShowingChanged(var M: TMessage);
begin
  inherited;
  AlreadyShown := True;

  // lo skin puo' essere cambiato mentre la vista era nascosta
  if Showing then
    UpdateDifferentStyle;

  PostInternalMessage(rvcDisplayToolbars);
end;

procedure TzDbRecordView.PostInternalMessage(const Command: TzDbRecordViewCommand);
begin
  if FIsDestroying or (csDestroying in ComponentState) then
    Exit;

  // Handle crea la finestra, e un frame senza genitore (creato dal
  // FormController e non ancora messo nel layout) solleverebbe "Control has
  // no parent window": in quel caso il comando si esegue subito
  if HandleAllocated or Assigned(Parent) then
    PostMessage(Self.Handle, ZZ_DBRECORDVIEW, NativeUInt(Command), 0)
  else
    ExecuteCommand(Command);
end;

procedure TzDbRecordView.MessageHandler(var Message: TMessage);
begin
  ExecuteCommand(TzDbRecordViewCommand(Message.WParam));
end;

procedure TzDbRecordView.ExecuteCommand(const Command: TzDbRecordViewCommand);
begin
  if FIsDestroying then
    Exit;

  case Command of
    rvcUpdateActions:
      UpdateActions;
    rvcDisplayToolbars:
      DisplayToolbars;
    rvcApplyEmptyRows:
      ApplyEmptyRows;
    rvcFocusFirstEditable:
      FocusFirstEditableRow;
    rvcOpenLookups:
      if Assigned(FLookupEditors) then
        FLookupEditors.EnsureOpen;
    rvcApplyTitle:
      SetTitle(FzDbRecordViewProps.Title);
    rvcSaveZip:
      begin
        FSaveZipQueued := False;
        if zSystemOk then
          zSystem.SaveZip(csDbRecordViews, 'TzDbRecordView.SalvaImpostazioni');
      end;
  end;
end;

// ---------------------------------------------------------------------------
// IzBaseComponent / IzBaseDbComponent / IzBaseFilterableComponent
// ---------------------------------------------------------------------------

function TzDbRecordView.GetComponentType: TzComponentType;
begin
  result := ctRecordView;
end;

function TzDbRecordView.GetID: string;
begin
  result := RecordViewID;
end;

procedure TzDbRecordView.SetID(const Value: string);
begin
  RecordViewID := Value;
end;

function TzDbRecordView.GetToolActions: TzToolActions;
begin
  result := FToolActions;
end;

procedure TzDbRecordView.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
end;

function TzDbRecordView.GetActionOwner: TComponent;
begin
  result := TzActionOwnerResolver.ResolveOwner(Self, FzDbRecordViewProps.ActionOwnerName);
end;

function TzDbRecordView.GetActionOwnerName: string;
begin
  result := FzDbRecordViewProps.ActionOwnerName;
end;

procedure TzDbRecordView.SetActionOwnerName(const Value: string);
begin
  FzDbRecordViewProps.ActionOwnerName := Value;
end;

procedure TzDbRecordView.RebuildActions;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

procedure TzDbRecordView.RebuildFilters;
begin
  RebuildToolbar;
  doSalvaImpostazioni(True);
end;

function TzDbRecordView.ConfigTitle: string;
begin
  result := GetTitle;
  if result = '' then
    result := RecordViewID;
end;

procedure TzDbRecordView.RebuildToolbar;
begin
  // Prima i filtri, poi le azioni: i filtri precedono le azioni sulla barra
  CreateFiltersFromProps;
  InitToolActions;
end;

function TzDbRecordView.GetProps: TzBaseComponentProps;
begin
  result := FzDbRecordViewProps;
end;

function TzDbRecordView.GetToolbar: TdxBar;
begin
  result := dxBarToolbarFree;
end;

function TzDbRecordView.GetzDataSet: TzFbDataSet;
begin
  result := FzDataSet;
end;

procedure TzDbRecordView.SetzDataSet(const Value: TzFbDataSet);
begin
  if FzDataSet = Value then
    Exit;

  if Assigned(FzDataSet) then
    FzDataSet.RemoveFreeNotification(Self);

  FzDataSet := Value;

  if Assigned(FzDataSet) then
    FzDataSet.FreeNotification(Self);

  FDataController.DataSet := Value;
  DataSource.DataSet := nil;

  // dataset diverso: la vista va ricostruita da capo
  FBuilt := False;
  InitRecordView;
end;

function TzDbRecordView.GetToolFilters: TzToolFiltersProps;
begin
  result := FzDbRecordViewProps.ToolFilters;
end;

procedure TzDbRecordView.SetToolFilters(const Value: TzToolFiltersProps);
begin
  FzDbRecordViewProps.ToolFilters.Assign(Value);
end;

// ---------------------------------------------------------------------------
// Proprieta'
// ---------------------------------------------------------------------------

function TzDbRecordView.GetRecordViewID: string;
begin
  if (FzDbRecordViewProps.Name = '') and FDataController.DataSetOk then
    FzDbRecordViewProps.Name := FDataController.IdDataSet;

  result := FzDbRecordViewProps.Name;
end;

procedure TzDbRecordView.SetRecordViewID(const Value: string);
begin
  FzDbRecordViewProps.Name := Value;
end;

function TzDbRecordView.GetFlags: TzDbRecordViewFlags;
begin
  result := FzDbRecordViewProps.Flags;
end;

function TzDbRecordView.GetDataSourceEnabled: Boolean;
begin
  result := DataSource.Enabled;
end;

procedure TzDbRecordView.SetDataSourceEnabled(const Value: Boolean);
begin
  DataSource.Enabled := Value;
end;

procedure TzDbRecordView.SetReadOnly(const Value: TzDbRecordViewReadOnly);
begin
  if FReadOnly = Value then
    Exit;

  FReadOnly := Value;
  FDataController.ReadOnly := IsRecordViewReadOnly;

  if FBuilt then
  begin
    ApplyGridOptions;
    RebuildRows;
  end;

  UpdateActions;
end;

procedure TzDbRecordView.SetRestrictionReadOnly(const Value: Boolean);
begin
  if FRestrictionReadOnly = Value then
    Exit;

  FRestrictionReadOnly := Value;
  FDataController.ReadOnly := IsRecordViewReadOnly;

  if FBuilt then
  begin
    ApplyGridOptions;
    RebuildRows;
  end;

  UpdateActions;
end;

procedure TzDbRecordView.SetzSystem(const Value: TzSystem);
begin
  if FzSystem = Value then
    Exit;

  FzSystem := Value;

  if Assigned(FzSystem) then
    FzSystem.FreeNotification(Self);

  InitRecordView;
end;

function TzDbRecordView.zSystemOk: Boolean;
begin
  result := Assigned(FzSystem);
end;

function TzDbRecordView.IsAdmin: Boolean;
begin
  result := zSystemOk and FzSystem.IsAdmin;
end;

function TzDbRecordView.IsRecordViewReadOnly: Boolean;
begin
  case FReadOnly of
    rroForceReadOnly:
      result := True;
    rroForceWriteable:
      result := False;
  else
    result := FzDbRecordViewProps.Flags.ReadOnly or FRestrictionReadOnly;
  end;
end;

function TzDbRecordView.EffectiveLayout: TzRecordViewLayout;
begin
  result := FzDbRecordViewProps.Flags.Layout;

  // il confronto da menu porta a piu' record una vista nata a record singolo
  if FCompareMode and (result = rlSingleRecord) then
    result := rlMultiRecord;
end;

function TzDbRecordView.IsEmptyRowsFilterActive: Boolean;
begin
  // ha senso solo con un record a video: con piu' record una riga vuota in
  // uno puo' essere piena in un altro
  result := (FzDbRecordViewProps.Flags.HideEmptyRows or FHideEmptyRows) and (EffectiveLayout = rlSingleRecord);
end;

// ---------------------------------------------------------------------------
// Costruzione
// ---------------------------------------------------------------------------

procedure TzDbRecordView.InitRecordView;
begin
  if FBuilt then
    Exit;

  if csDesigning in ComponentState then
    Exit;

  if not zSystemOk then
    Exit;

  if not FDataController.DataSetOk then
    Exit;

  cxDBVerticalGrid.BeginUpdate;
  try
    DataSource.DataSet := FzDataSet;

    FStorage.Folder := FzSystem.PersonalFolder;

    LoadProperties(True);

    FStorage.RecordViewID := RecordViewID;

    FBuilt := True;
    RebuildRows;
    LoadUserLayout;
  finally
    cxDBVerticalGrid.EndUpdate;
  end;
end;

procedure TzDbRecordView.LoadProperties(const LoadDefaults: Boolean);
begin
  if csDesigning in ComponentState then
    Exit;

  FLoadingProps := True;
  try
    if LoadDefaults then
      InternalLoadProperties;

    if zSystemOk and FzSystem.zDbRecordViews.Exists(RecordViewID) then
      SetTitle(FzDbRecordViewProps.Title);

    FDataController.ReadOnly := IsRecordViewReadOnly;

    ApplyGridOptions;
    LoadDescription;
    RebuildToolbar;
  finally
    FLoadingProps := False;
  end;

  UpdateActions;
end;

procedure TzDbRecordView.InternalLoadProperties;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzDbRecordViewProps.Name = '' then
    FzDbRecordViewProps.Name := RecordViewID;

  if FzDbRecordViewProps.DataSet = '' then
    FzDbRecordViewProps.DataSet := FDataController.IdDataSet;

  if Assigned(FOnCustomLoadProps) then
    FOnCustomLoadProps(Self)
  else
    if zSystemOk then
      FzDbRecordViewProps.LoadFromBase;

  FzDbRecordViewProps.Rows.ValidateDataset(FDataController.zFbDataSet);
end;

procedure TzDbRecordView.InternalSaveProperties;
begin
  if Assigned(FOnCustomSaveProps) then
    FOnCustomSaveProps(Self)
  else
    if zSystemOk then
    begin
      // aggiornamento in memoria sincrono, scrittura dello zip differita e
      // coalescente come in TzDbPivot
      FzDbRecordViewProps.SaveToBase(False);

      if not FSaveZipQueued then
      begin
        FSaveZipQueued := True;
        PostInternalMessage(rvcSaveZip);
      end;
    end;
end;

procedure TzDbRecordView.doSalvaImpostazioni(const Silent: Boolean = False);
var
  FilterWasActive: Boolean;
begin
  if csDesigning in ComponentState then
    Exit;

  if not Silent then
    StartWait('Attendere...', True);
  try
    if FzDbRecordViewProps.Name = '' then
      FzDbRecordViewProps.Name := RecordViewID;

    if FzDbRecordViewProps.DataSet = '' then
      FzDbRecordViewProps.DataSet := FDataController.IdDataSet;

    if FBuilt then
    begin
      // le righe nascoste perche' vuote non devono finire nel dizionario:
      // si rimettono, si legge la griglia, si riapplica il filtro
      FilterWasActive := FHiddenAsEmpty.Count > 0;
      RestoreEmptyRows;

      FRowsBuilder.AssignToProps(FzDbRecordViewProps);

      if FilterWasActive then
        ApplyEmptyRows;
    end;

    InternalSaveProperties;
  finally
    if not Silent then
      StopWait;
  end;
end;

procedure TzDbRecordView.ApplyGridOptions;
begin
  cxDBVerticalGrid.BeginUpdate;
  try
    case EffectiveLayout of
      rlSingleRecord:
        begin
          cxDBVerticalGrid.LayoutStyle := lsSingleRecordView;
          // Mantis #315 - 2026-11-03: con un solo record la banda riempie la larghezza (AutoScaleBands),
          // quindi la barra orizzontale non serve; se puo' comparire, su schermi piccoli appare e sparisce
          // all'infinito con la barra verticale (BoundsChanged -> UpdateScrollBars -> BoundsChanged)
          cxDBVerticalGrid.OptionsView.ScrollBars := ssVertical;
        end;
      rlMultiRecord:
        begin
          cxDBVerticalGrid.LayoutStyle := lsMultiRecordView;
          cxDBVerticalGrid.OptionsView.ScrollBars := ssBoth;
        end;
      rlBands:
        begin
          cxDBVerticalGrid.LayoutStyle := lsBandsView;
          cxDBVerticalGrid.OptionsView.ScrollBars := ssBoth;
        end;
    end;

    // con GridMode la griglia legge solo i record che mostra; il confronto
    // ha bisogno di tutti i record caricati
    cxDBVerticalGrid.DataController.DataModeController.GridMode := FzDbRecordViewProps.Flags.GridMode and not FCompareMode;

    cxDBVerticalGrid.OptionsData.Inserting := False;
    cxDBVerticalGrid.OptionsData.Appending := False;
    cxDBVerticalGrid.OptionsData.Deleting := False;
    cxDBVerticalGrid.OptionsData.CancelOnExit := False;
    // celle e scheda sono indipendenti: InplaceEditing decide le celle
    cxDBVerticalGrid.OptionsData.Editing := not IsRecordViewReadOnly and FzDbRecordViewProps.Flags.InplaceEditing;

    // HeaderWidth del dizionario e' una forzatura: senza, la larghezza segue le didascalie
    if FzDbRecordViewProps.HeaderWidth > 0 then
      ImpostaLarghezzaEtichette(FzDbRecordViewProps.HeaderWidth, False);

    if FzDbRecordViewProps.ValueWidth > 0 then
      cxDBVerticalGrid.OptionsView.ValueWidth := FzDbRecordViewProps.ValueWidth;
  finally
    cxDBVerticalGrid.EndUpdate;
  end;
end;

procedure TzDbRecordView.RebuildRows;
begin
  if not FBuilt then
    Exit;

  if Assigned(FOnBeforeCreateControls) then
    FOnBeforeCreateControls(Self);

  // le righe vengono distrutte e ricreate: i riferimenti tenuti dal filtro
  // delle righe vuote non valgono piu'
  FHiddenAsEmpty.Clear;

  FzDbRecordViewProps.Rows.ValidateDataset(FDataController.zFbDataSet);
  FRowsBuilder.Build(FzDbRecordViewProps, IsRecordViewReadOnly, DoRowCreated);

  if FEtichetteAutomatiche and (FzDbRecordViewProps.HeaderWidth <= 0) then
    ImpostaLarghezzaEtichette(LarghezzaDidascalie, True)
  else
    AllargaDidascalie;

  if IsEmptyRowsFilterActive then
    ApplyEmptyRows;

  if Assigned(FOnAfterCreateControls) then
    FOnAfterCreateControls(Self);

  UpdateActions;
end;

procedure TzDbRecordView.ReloadProps;
begin
  if not FBuilt then
    Exit;

  cxDBVerticalGrid.BeginUpdate;
  try
    LoadProperties(True);
    RebuildRows;
    LoadUserLayout;
  finally
    cxDBVerticalGrid.EndUpdate;
  end;
end;

procedure TzDbRecordView.DoRowCreated(Sender: TObject; Row: TcxCustomRow; Item: TzRecordViewRow; Field: TField);
begin
  if Assigned(FOnRowCreated) then
    FOnRowCreated(Self, Row, Item, Field);
end;

procedure TzDbRecordView.CreateFiltersFromProps;
begin
  TzToolFilterBuilder.Build(FzDbRecordViewProps.ToolFilters, Self, dxBarManager, FzDataSet);
end;

procedure TzDbRecordView.InitToolActions;
begin
  TzActionBuilder.BuildFromProps(FzDbRecordViewProps.ToolActions, ToolActions, GetActionOwner);
  ToolActions.CreateButtons(dxBarToolbarFree, popRecordView, otView);
  DisplayToolbars;
end;

function TzDbRecordView.AddAction(Action: TCustomAction; ImageList: TCustomImagelist): TzToolActionProps;
begin
  // Scrive sui props persistiti, come TzDbView e TzDbPivot: il runtime
  // ToolActions e' rigenerato da InitToolActions. FromCode protegge l'azione
  // da codice dall'Assign del dizionario. ImageList non e' persistibile.
  result := nil;

  if not Assigned(Action) then
    Exit;

  result := FzDbRecordViewProps.ToolActions.Find(Action.Name);
  if not Assigned(result) then
  begin
    result := FzDbRecordViewProps.ToolActions.Add;
    result.Name := Action.Name;
  end;

  result.FromCode := True;
end;

procedure TzDbRecordView.ExecuteToolConfig;
begin
  if not IsAdmin then
    Exit;

  TzToolConfigDlgForm.Execute(Self);
end;

procedure TzDbRecordView.ToolActionsChanged(Sender: TObject);
begin
  InitToolActions;
end;

procedure TzDbRecordView.OnFlagChange(Sender: TObject);
begin
  // durante il caricamento delle props l'Assign dei flag scatta piu' volte:
  // LoadProperties applica tutto alla fine
  if FLoadingProps or FIsDestroying then
    Exit;

  FDataController.ReadOnly := IsRecordViewReadOnly;
  ApplyGridOptions;

  if FBuilt then
    RebuildRows;

  DisplayToolbars;
  UpdateActions;
end;

procedure TzDbRecordView.DisplayToolbars;
begin
  dxBarManager.BeginUpdate;
  try
    // ordine inverso di visualizzazione
    dxBarToolbarFree.Visible := Flags.Toolbar;
    dxBarToolbar.Visible := Flags.Toolbar;
    dxBarToolbar.UseRestSpace := not dxBarToolbarFree.Visible;
    Titolo.Visible := Flags.Toolbar and (Titolo.Caption <> '');
  finally
    dxBarManager.EndUpdate;
  end;
end;

procedure TzDbRecordView.UpdateActions;
var
  Editing: Boolean;
  CanModify: Boolean;
  HasData: Boolean;
  HasRecord: Boolean;
begin
  if (csDestroying in ComponentState) or FIsDestroying then
    Exit;

  Editing := FDataController.IsEditing;
  CanModify := not IsRecordViewReadOnly;

  ActionVisible(actDbFirst, Flags.ButtonArrows);
  ActionVisible(actDbPrior, Flags.ButtonArrows);
  ActionVisible(actDbNext, Flags.ButtonArrows);
  ActionVisible(actDbLast, Flags.ButtonArrows);

  actDbFirst.Enabled := FDataController.CanFirst;
  actDbPrior.Enabled := FDataController.CanPrior;
  actDbNext.Enabled := FDataController.CanNext;
  actDbLast.Enabled := FDataController.CanLast;

  ActionVisible(actDbRefresh, Flags.ButtonRefresh and FDataController.CanRefresh);

  // come TzDbView: un gestore della form mostra l'azione anche in sola lettura
  ActionVisible(actDbInsert, (CanModify and Flags.ButtonInsert) or Assigned(FOnDataSetInsert));
  ActionVisible(actDbEdit, (CanModify and Flags.ButtonUpdate) or Assigned(FOnDataSetEdit));
  ActionVisible(actDbDelete, (CanModify and Flags.ButtonDelete) or Assigned(FOnDataSetDelete));
  // Il gestore della form decide da se': in sola lettura CanEdit e simili sono
  // sempre falsi, e l'azione resterebbe visibile ma spenta
  HasData := FDataController.DataSetOk and FDataController.IsActive;
  HasRecord := HasData and not FDataController.DataSet.IsEmpty;
  actDbInsert.Enabled := (not Editing) and (FDataController.CanInsert or (Assigned(FOnDataSetInsert) and HasData));
  actDbEdit.Enabled := (not Editing) and (FDataController.CanEdit or (Assigned(FOnDataSetEdit) and HasRecord));
  actDbDelete.Enabled := (not Editing) and (FDataController.CanDelete or (Assigned(FOnDataSetDelete) and HasRecord));

  ActionVisible(actDbPost, Flags.ButtonOkCancel and Editing);
  ActionVisible(actDbCancel, Flags.ButtonOkCancel and Editing);
  actDbPost.Enabled := FDataController.CanPost;
  actDbCancel.Enabled := FDataController.CanCancel;

  ActionVisible(Espandi, Flags.ButtonExpand and HasCategories);
  ActionVisible(Riduci, Flags.ButtonExpand and HasCategories);

  ActionVisible(Elabora, Flags.Params);

  actNascondiVuote.Checked := IsEmptyRowsFilterActive;
  actNascondiVuote.Enabled := EffectiveLayout = rlSingleRecord;
  actConfronta.Checked := FCompareMode;
  actConfronta.Enabled := Flags.Layout = rlSingleRecord;

  ActionVisible(actPersonalizza, IsAdmin);
  ActionVisible(actPersonalizzaRighe, IsAdmin);
  ActionVisible(actPersonalizzaRiga, IsAdmin);
  ActionVisible(actPersonalizzaCampo, IsAdmin);
  ActionVisible(actResetRighe, IsAdmin);
  ActionVisible(SalvaImpostazioni, IsAdmin);
  ActionVisible(CaricaImpostazioni, IsAdmin);
  ActionVisible(actSQL, IsAdmin);
  ActionVisible(MostraQueryUtilizzata, IsAdmin);
  ActionVisible(CopiaQueryUtilizzata, IsAdmin);
  ActionVisible(CopyName, IsAdmin);
  ActionVisible(NomeFileIni, IsAdmin);

  if Assigned(FOnUpdateActions) then
    FOnUpdateActions(Self);
end;

function TzDbRecordView.HasCategories: Boolean;
var
  i: Integer;
begin
  result := False;

  for i := 0 to cxDBVerticalGrid.Rows.Count - 1 do
    if cxDBVerticalGrid.Rows[i] is TcxCategoryRow then
      Exit(True);
end;

// ---------------------------------------------------------------------------
// Eventi del dataset e della griglia
// ---------------------------------------------------------------------------

procedure TzDbRecordView.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  if FIsDestroying then
    Exit;

  PostInternalMessage(rvcUpdateActions);

  // Field = nil: cambio di record (o riapertura), non modifica di un campo
  if Field = nil then
  begin
    if IsEmptyRowsFilterActive then
      PostInternalMessage(rvcApplyEmptyRows);

    if Assigned(FOnRecordChanged) then
      FOnRecordChanged(Self);
  end;
end;

procedure TzDbRecordView.DataSourceStateChange(Sender: TObject);
begin
  // dataset aperto: i lookup delle celle servono anche solo a mostrare la descrizione
  if Assigned(FzDataSet) and FzDataSet.Active and (FzDataSet.State = dsBrowse) then
    PostInternalMessage(rvcOpenLookups);

  PostInternalMessage(rvcUpdateActions);
end;

procedure TzDbRecordView.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  // aggiornamento affidato a UpdateActions, chiamato dagli eventi del dataset
end;

procedure TzDbRecordView.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Esc fuori dall'editor: l'annullamento passa da DataController, come le azioni
  if (Key = VK_ESCAPE) and (Shift = []) and not cxDBVerticalGrid.IsEditing then
    if FDataController.IsEditing then
    begin
      Key := 0;
      Cancel;
      Exit;
    end;

  // Ctrl+F: trova un campo per etichetta (il pannello di ricerca filtra i record)
  if (Key = Ord('F')) and (Shift = [ssCtrl]) then
  begin
    Key := 0;
    actTrovaCampo.Execute;
  end;
end;

procedure TzDbRecordView.GridEditing(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties; var Allow: Boolean);
begin
  if FIsDestroying or IsRecordViewReadOnly then
  begin
    Allow := False;
    Exit;
  end;

  if not EditorRowEditing(ARowProperties) then
  begin
    Allow := False;
    Exit;
  end;

  // Con una modifica personalizzata (per esempio in una finestra) la riga
  // si scrive solo quando la form ha gia' aperto la modifica
  if Assigned(FOnDataSetEdit) and not FDataController.IsEditing then
  begin
    Allow := False;
    Exit;
  end;

  if not FDataController.IsEditing then
    Allow := Flags.ButtonUpdate and FDataController.CanEdit;
end;

procedure TzDbRecordView.GridGetHeaderStyle(Sender: TObject; ARow: TcxCustomRow; var AStyle: TcxStyle);
var
  Field: TField;
begin
  if FIsDestroying then
    Exit;

  if not Flags.MarkRequired then
    Exit;

  if not(ARow is TcxDBEditorRow) then
    Exit;

  if FDataController.TryGetField(TcxDBEditorRow(ARow).Properties.DataBinding.FieldName, Field) then
    if Field.Required and not Field.ReadOnly then
      AStyle := cxStyleBold;
end;

procedure TzDbRecordView.GridGetContentStyle(Sender: TObject; AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean; ARecordIndex: Integer;
  var AStyle: TcxStyle);
var
  ReferenceIndex: Integer;
  Value, ReferenceValue: Variant;
  Different: Boolean;
begin
  if FIsDestroying then
    Exit;

  if cxDBVerticalGrid.LayoutStyle = lsSingleRecordView then
    Exit;

  if not Flags.HighlightDifferences then
    Exit;

  // il record con il fuoco e' il riferimento: si evidenziano gli altri
  ReferenceIndex := cxDBVerticalGrid.FocusedRecordIndex;
  if (ReferenceIndex < 0) or (ARecordIndex = ReferenceIndex) then
    Exit;

  try
    Value := AEditProp.Values[ARecordIndex];
    ReferenceValue := AEditProp.Values[ReferenceIndex];

    if VarIsNull(Value) or VarIsNull(ReferenceValue) then
      Different := VarIsNull(Value) <> VarIsNull(ReferenceValue)
    else
      Different := not VarSameValue(Value, ReferenceValue);
  except
    // tipi non confrontabili: si lascia lo stile normale
    Different := False;
  end;

  if Different then
    AStyle := cxStyleDifferent;
end;

procedure TzDbRecordView.UpdateDifferentStyle;
const
  // giallo chiaro di sempre per gli skin chiari, ambra scuro per quelli scuri
  ColoreChiaro = $00CCFFFF;
  ColoreScuro = $001E5C7A;
var
  Sfondo: TColor;
  Testo: TColor;
begin
  // Lo stile del .dfm fissava solo lo sfondo: il testo restava quello dello
  // skin, bianco negli skin scuri, e sul giallo chiaro non si leggeva.
  // Sfondo secondo lo skin e testo sempre in contrasto con lo sfondo
  if GetContrastColor(dx.GetColor(scMoneyGreen)) = clWhite then
    Sfondo := ColoreScuro
  else
    Sfondo := ColoreChiaro;

  Testo := GetContrastColor(Sfondo);

  // assegnare uno stile ridisegna la griglia: solo se cambia davvero
  if (cxStyleDifferent.Color <> Sfondo) or (cxStyleDifferent.TextColor <> Testo) or not(svTextColor in cxStyleDifferent.AssignedValues) then
  begin
    cxStyleDifferent.Color := Sfondo;
    cxStyleDifferent.TextColor := Testo;
  end;
end;

// ---------------------------------------------------------------------------
// Righe e campi
// ---------------------------------------------------------------------------

function TzDbRecordView.RowByField(const FieldName: string): TcxCustomRow;
var
  Item: TzRecordViewRow;
begin
  result := nil;

  Item := FzDbRecordViewProps.Rows.FieldRow(FieldName);
  if Assigned(Item) then
    result := FRowsBuilder.RowOfItem(Item.Name);
end;

function TzDbRecordView.FocusField(const FieldName: string): Boolean;
var
  Row, ParentRow: TcxCustomRow;
begin
  result := False;

  Row := RowByField(FieldName);
  if not Assigned(Row) or not Row.Visible then
    Exit;

  // una riga dentro una categoria chiusa non si vede: si aprono i padri
  ParentRow := Row.Parent;
  while Assigned(ParentRow) do
  begin
    ParentRow.Expanded := True;
    ParentRow := ParentRow.Parent;
  end;

  cxDBVerticalGrid.FocusRow(Row);
  if cxDBVerticalGrid.CanFocus then
    cxDBVerticalGrid.SetFocus;

  result := True;
end;

procedure TzDbRecordView.ShowField(const FieldName: string);
var
  Row: TcxCustomRow;
begin
  Row := RowByField(FieldName);
  if Assigned(Row) then
    Row.Visible := True;
end;

procedure TzDbRecordView.HideField(const FieldName: string);
var
  Row: TcxCustomRow;
begin
  Row := RowByField(FieldName);
  if Assigned(Row) then
    Row.Visible := False;
end;

procedure TzDbRecordView.SetFieldReadOnly(const FieldName: string; const IsReadOnly: Boolean);
var
  Row: TcxCustomRow;
begin
  Row := RowByField(FieldName);
  if Assigned(Row) then
    FRowsBuilder.ApplyRowEditability(Row, IsReadOnly or IsRecordViewReadOnly);
end;

procedure TzDbRecordView.DefineCategory(const CategoryName, CategoryCaption: string; const FieldNames: array of string);
var
  FieldName: string;
begin
  FzDbRecordViewProps.Rows.AddCategory(CategoryName, CategoryCaption);

  for FieldName in FieldNames do
    FzDbRecordViewProps.Rows.MoveToCategory(FieldName, CategoryName);

  RebuildRows;
end;

function TzDbRecordView.FocusedFieldName: string;
var
  Row: TcxCustomRow;
begin
  result := '';
  Row := cxDBVerticalGrid.FocusedRow;

  if Row is TcxDBEditorRow then
    result := TcxDBEditorRow(Row).Properties.DataBinding.FieldName;
end;

procedure TzDbRecordView.FocusFirstEditableRow;
var
  i: Integer;
  Row: TcxCustomRow;
begin
  for i := 0 to cxDBVerticalGrid.Rows.Count - 1 do
  begin
    Row := cxDBVerticalGrid.Rows[i];

    if (Row is TcxDBEditorRow) and Row.Visible and TcxDBEditorRow(Row).Properties.Options.Editing then
    begin
      FocusField(TcxDBEditorRow(Row).Properties.DataBinding.FieldName);
      Exit;
    end;
  end;
end;

procedure TzDbRecordView.RestoreEmptyRows;
var
  Row: TcxCustomRow;
begin
  // rimette solo le righe nascoste dal filtro: quelle nascoste dal dizionario,
  // dall'amministratore o dalla form (HideField) restano come sono
  for Row in FHiddenAsEmpty do
    Row.Visible := True;

  FHiddenAsEmpty.Clear;
end;

procedure TzDbRecordView.ApplyEmptyRows;
var
  Item: TzRecordViewRow;
  Row: TcxCustomRow;
  Field: TField;
begin
  if not FBuilt then
    Exit;

  cxDBVerticalGrid.BeginUpdate;
  try
    RestoreEmptyRows;

    if not IsEmptyRowsFilterActive then
      Exit;

    if not FDataController.IsActive or FDataController.IsEmpty then
      Exit;

    for Item in FzDbRecordViewProps.Rows do
    begin
      if not Item.IsField then
        Continue;

      Row := FRowsBuilder.RowOfItem(Item.Name);
      if not Assigned(Row) or not Row.Visible then
        Continue;

      if FDataController.TryGetField(Item.Name, Field) and Field.IsNull then
      begin
        Row.Visible := False;
        FHiddenAsEmpty.Add(Row);
      end;
    end;
  finally
    cxDBVerticalGrid.EndUpdate;
  end;
end;

procedure TzDbRecordView.ApplyHeaderBestFit;
begin
  // richiesta esplicita (Adatta larghezze): senza forzatura del dizionario
  // si torna alla larghezza automatica, e il layout personale la dimentica
  ImpostaLarghezzaEtichette(LarghezzaDidascalie, FzDbRecordViewProps.HeaderWidth <= 0);
end;

procedure TzDbRecordView.AllargaDidascalie;
var
  Larghezza: Integer;
begin
  Larghezza := LarghezzaDidascalie;

  if Larghezza > FLarghezzaEtichette then
    FLarghezzaEtichette := Larghezza;

  ApplicaLarghezzaEtichette;
end;

procedure TzDbRecordView.ImpostaLarghezzaEtichette(const Larghezza: Integer; const Automatica: Boolean);
begin
  if Larghezza <= 0 then
    Exit;

  FLarghezzaEtichette := Larghezza;
  FEtichetteAutomatiche := Automatica;
  ApplicaLarghezzaEtichette;
end;

procedure TzDbRecordView.ApplicaLarghezzaEtichette;
begin
  // la griglia taglia il valore se lo spazio non basta: si riassegna sempre
  // la larghezza voluta, cosi' torna intera quando la griglia si allarga
  if (FLarghezzaEtichette > 0) and (cxDBVerticalGrid.OptionsView.RowHeaderWidth <> FLarghezzaEtichette) then
    cxDBVerticalGrid.OptionsView.RowHeaderWidth := FLarghezzaEtichette;
end;

procedure TzDbRecordView.GridWindowProc(var Message: TMessage);
begin
  if Message.Msg = WM_LBUTTONDOWN then
    FLarghezzaPrimaDelClic := cxDBVerticalGrid.OptionsView.RowHeaderWidth;

  FGridWindowProc(Message);

  if not FBuilt or FIsDestroying then
    Exit;

  case Message.Msg of
    WM_SIZE:
      begin
        // le didascalie non cambiano col ridimensionamento, ma il carattere si'
        // quando la form passa a un monitor con DPI diversi
        if FEtichetteAutomatiche then
          FLarghezzaEtichette := LarghezzaDidascalie;

        ApplicaLarghezzaEtichette;
      end;
    WM_LBUTTONUP:
      // la larghezza cambia fra pressione e rilascio solo se l'utente ha
      // trascinato il bordo delle didascalie: la sua scelta vince e si salva
      if cxDBVerticalGrid.OptionsView.RowHeaderWidth <> FLarghezzaPrimaDelClic then
      begin
        FLarghezzaEtichette := cxDBVerticalGrid.OptionsView.RowHeaderWidth;
        FEtichetteAutomatiche := False;
      end;
  end;
end;

function TzDbRecordView.LarghezzaDidascalie: Integer;
var
  i: Integer;
  Row: TcxCustomRow;
  Caption: string;
  MaxWidth, CurrentWidth: Integer;
  Bitmap: TBitmap;
  Margin: Integer;
begin
  MaxWidth := 0;

  Bitmap := TBitmap.Create;
  try
    // il carattere della griglia e' gia' scalato ai DPI del monitor: anche il
    // margine si misura in caratteri, cosi' segue la stessa scala.
    // Si misura in grassetto: categorie e campi obbligatori si disegnano cosi',
    // e la misura col carattere normale li tagliava. Per le altre righe
    // costa qualche pixel di troppo
    Bitmap.Canvas.Font.Assign(cxDBVerticalGrid.Font);
    Bitmap.Canvas.Font.Style := Bitmap.Canvas.Font.Style + [fsBold];
    Margin := Bitmap.Canvas.TextWidth('MM');

    for i := 0 to cxDBVerticalGrid.Rows.Count - 1 do
    begin
      Row := cxDBVerticalGrid.Rows[i];

      if not Row.Visible then
        Continue;

      // TcxCustomRow non ha Properties: la didascalia sta nelle classi derivate
      if Row is TcxDBEditorRow then
        Caption := TcxDBEditorRow(Row).Properties.Caption
      else
        if Row is TcxCategoryRow then
          Caption := TcxCategoryRow(Row).Properties.Caption
        else
          Continue;

      // rientro dei livelli piu' margine per il pulsante di espansione
      CurrentWidth := Bitmap.Canvas.TextWidth(Caption) + (Row.Level + 2) * Margin;

      if CurrentWidth > MaxWidth then
        MaxWidth := CurrentWidth;
    end;
  finally
    FreeAndNil(Bitmap);
  end;

  result := MaxWidth;
end;

procedure TzDbRecordView.ExpandAll;
begin
  cxDBVerticalGrid.FullExpand;
end;

procedure TzDbRecordView.CollapseAll;
begin
  cxDBVerticalGrid.FullCollapse;
end;

// ---------------------------------------------------------------------------
// Modifica del record
// ---------------------------------------------------------------------------

function TzDbRecordView.ValidateRequiredFields(RaiseError: Boolean): Boolean;
var
  Item: TzRecordViewRow;
  Field: TField;
  ErrorFields: string;
begin
  // TzFbDataSet controlla gia' gli obbligatori prima del salvataggio: questo
  // controllo serve alla form che vuole saperlo prima, con le etichette della vista
  result := True;

  if not FDataController.IsEditing then
    Exit;

  ErrorFields := '';

  for Item in FzDbRecordViewProps.Rows do
    if Item.IsField and Item.Visible then
      if FDataController.TryGetField(Item.Name, Field) then
        if not FDataController.RequiredFieldOk(Field) then
          ErrorFields := ErrorFields + Item.Caption + sLineBreak;

  if ErrorFields <> '' then
  begin
    result := False;

    if RaiseError then
    begin
      ConfirmOk(SCampiObbligatori + sLineBreak + sLineBreak + ErrorFields);
      System.SysUtils.Abort;
    end;
  end;
end;

procedure TzDbRecordView.Post;
begin
  // il valore battuto nell'editor ancora aperto va prima nel campo
  cxDBVerticalGrid.DataController.PostEditingData;
  FDataController.CheckBrowseMode;
end;

procedure TzDbRecordView.Cancel;
begin
  cxDBVerticalGrid.CancelEdit;
  FDataController.Cancel;
end;

procedure TzDbRecordView.SetCompareMode(const Value: Boolean);
begin
  if FCompareMode = Value then
    Exit;

  FCompareMode := Value;

  ApplyGridOptions;

  if FBuilt then
    ApplyEmptyRows;

  UpdateActions;
end;

// ---------------------------------------------------------------------------
// Layout personale
// ---------------------------------------------------------------------------

function TzDbRecordView.CurrentUserLayout: TzRecordViewUserLayout;
var
  Item: TzRecordViewRow;
  Row: TcxCustomRow;
  Collapsed: TArray<string>;
begin
  result.Clear;
  // la larghezza voluta, non RowHeaderWidth: con la form stretta la griglia
  // lo taglia, e salvarlo renderebbe permanente il taglio. Quella automatica
  // non si salva, cosi' resta automatica anche alla prossima apertura
  if FEtichetteAutomatiche then
    result.HeaderWidth := 0
  else
    result.HeaderWidth := FLarghezzaEtichette;
  result.ValueWidth := cxDBVerticalGrid.OptionsView.ValueWidth;

  Collapsed := nil;
  for Item in FzDbRecordViewProps.Rows do
    if Item.RowKind = rkCategory then
    begin
      Row := FRowsBuilder.RowOfItem(Item.Name);
      if Assigned(Row) and not Row.Expanded then
        Collapsed := Collapsed + [Item.Name];
    end;

  result.CollapsedCategories := Collapsed;
end;

procedure TzDbRecordView.LoadUserLayout;
var
  Layout: TzRecordViewUserLayout;
  Item: TzRecordViewRow;
  Row: TcxCustomRow;
begin
  if not FBuilt then
    Exit;

  Layout := FStorage.Load;

  cxDBVerticalGrid.BeginUpdate;
  try
    if Layout.HeaderWidth > 0 then
      ImpostaLarghezzaEtichette(Layout.HeaderWidth, False);

    if Layout.ValueWidth > 0 then
      cxDBVerticalGrid.OptionsView.ValueWidth := Layout.ValueWidth;

    for Item in FzDbRecordViewProps.Rows do
      if Item.RowKind = rkCategory then
      begin
        Row := FRowsBuilder.RowOfItem(Item.Name);
        if Assigned(Row) and Layout.IsCollapsed(Item.Name) then
          Row.Expanded := False;
      end;
  finally
    cxDBVerticalGrid.EndUpdate;
  end;

  // la larghezza salvata puo' tagliare didascalie rinominate o aggiunte dopo:
  // si allarga, mai si stringe. Prima di FLoadedUserLayout, cosi'
  // l'allargamento da solo non provoca una scrittura del layout
  AllargaDidascalie;

  // si salva solo se l'utente cambia qualcosa rispetto a quanto letto
  FLoadedUserLayout := CurrentUserLayout;
end;

procedure TzDbRecordView.SaveUserLayout;
var
  Layout: TzRecordViewUserLayout;
begin
  if not zSystemOk then
    Exit;

  Layout := CurrentUserLayout;

  if (Layout.HeaderWidth = FLoadedUserLayout.HeaderWidth) and (Layout.ValueWidth = FLoadedUserLayout.ValueWidth) and
    (string.Join(';', Layout.CollapsedCategories) = string.Join(';', FLoadedUserLayout.CollapsedCategories)) then
    Exit;

  try
    FStorage.Save(Layout);
  except
    // il layout personale non deve impedire la chiusura della form
    on Exception do
      ;
  end;
end;

// ---------------------------------------------------------------------------
// Descrizione
// ---------------------------------------------------------------------------

procedure TzDbRecordView.CreateDescription;
begin
  FrameDescription := TFrameDescription.Create(Self);
  FrameDescription.Parent := pnlDescrizione;
  FrameDescription.Align := alClient;

  FrameDescription.ChangedProc := procedure
    begin
      SaveDescription;
    end;
end;

procedure TzDbRecordView.LoadDescription;
begin
  if not Assigned(FrameDescription) then
    CreateDescription;

  FzDbRecordViewProps.Description.LoadFromIni(RecordViewID);
  FrameDescription.zDescription := FzDbRecordViewProps.Description;

  Descrizione.Checked := FrameDescription.zDescription.Visible;
end;

procedure TzDbRecordView.SaveDescription;
begin
  FzDbRecordViewProps.Description.Assign(FrameDescription.zDescription);
  FzDbRecordViewProps.Description.SaveToIni(RecordViewID);
  Descrizione.Checked := FzDbRecordViewProps.Description.Visible;
end;

// ---------------------------------------------------------------------------
// Titolo
// ---------------------------------------------------------------------------

function TzDbRecordView.GetTitle: string;
begin
  result := Titolo.Caption;

  if result.IsEmpty then
    result := FzDbRecordViewProps.Title;

  if result.IsEmpty then
  begin
    result := Name;
    if result.StartsWith('recview') then
      result := result.Replace('recview', '', [rfIgnoreCase]);
  end;
end;

procedure TzDbRecordView.SetTitle(const Title: string);
begin
  Titolo.Caption := Trim(Title);
  Titolo.Visible := Titolo.Caption <> '';
  dxBarControlContainerTitolo.Visible := dx.Visible(Titolo.Visible);

  dxBarEditTitolo.OnChange := nil;
  try
    dxBarEditTitolo.EditValue := Titolo.Caption;
  finally
    dxBarEditTitolo.OnChange := dxBarEditTitoloChange;
  end;
end;

procedure TzDbRecordView.dxBarEditTitoloChange(Sender: TObject);
begin
  FzDbRecordViewProps.Title := VarToStr(dxBarEditTitolo.EditValue);
  doSalvaImpostazioni;

  // il titolo a video si aggiorna dopo: durante OnChange la casella di testo
  // della barra e' ancora in modifica e SetTitle ne riscrive il valore
  PostInternalMessage(rvcApplyTitle);
end;

// ---------------------------------------------------------------------------
// Uscite
// ---------------------------------------------------------------------------

procedure TzDbRecordView.ExportToFile(const FileName: string);
var
  Extension: string;
begin
  Extension := LowerCase(ExtractFileExt(FileName));

  if Extension = '.csv' then
    cxExportVGToCSV(FileName, cxDBVerticalGrid)
  else
    if Extension = '.xls' then
      cxExportVGToExcel(FileName, cxDBVerticalGrid)
    else
      cxExportVGToXLSX(FileName, cxDBVerticalGrid);
end;

procedure TzDbRecordView.Preview;
var
  Printer: TdxComponentPrinter;
begin
  // printer creato al momento e liberato subito: niente stato condiviso fra
  // stampe successive. dx.InitPrinter spegne la clessidra di ExpressPrinting
  // (contatore globale che restava bloccato, 2026-09-29).
  Printer := TdxComponentPrinter.Create(nil);
  try
    dx.InitPrinter(Printer);
    Printer.AddLink(cxDBVerticalGrid);
    Printer.Preview(True, nil);
  finally
    FreeAndNil(Printer);
  end;
end;

// ---------------------------------------------------------------------------
// Azioni
// ---------------------------------------------------------------------------

procedure TzDbRecordView.ActivateDataSet;
begin
  if not FDataController.DataSetOk then
    Exit;

  if FDataController.IsActive then
    Exit;

  if FDataController.AutoOpen then
    FDataController.OpenDataSet;
end;

procedure TzDbRecordView.actDbFirstExecute(Sender: TObject);
begin
  FDataController.First;
end;

procedure TzDbRecordView.actDbPriorExecute(Sender: TObject);
begin
  FDataController.Prior;
end;

procedure TzDbRecordView.actDbNextExecute(Sender: TObject);
begin
  FDataController.Next;
end;

procedure TzDbRecordView.actDbLastExecute(Sender: TObject);
begin
  FDataController.Last;
end;

procedure TzDbRecordView.actDbRefreshExecute(Sender: TObject);
begin
  actDbRefresh.Enabled := False;
  try
    FDataController.Refresh;
  finally
    actDbRefresh.Enabled := True;
  end;
end;

procedure TzDbRecordView.actDbInsertExecute(Sender: TObject);
begin
  if Assigned(FOnDataSetInsert) then
    FOnDataSetInsert(Self)
  else
    if FDataController.CanInsert and Flags.ButtonInsert and not IsRecordViewReadOnly then
    begin
      if UsesCard then
        ShowRecord(True)
      else
      begin
        FDataController.Insert;
        PostInternalMessage(rvcFocusFirstEditable);
      end;
    end;
end;

procedure TzDbRecordView.actDbEditExecute(Sender: TObject);
begin
  if Assigned(FOnDataSetEdit) then
    FOnDataSetEdit(Self)
  else
    if FDataController.CanEdit and Flags.ButtonUpdate and not IsRecordViewReadOnly then
    begin
      if UsesCard then
      begin
        // come TzDbView.dbEdit: la scheda della form decide da se'
        if not Assigned(FOnShowCard) then
          FDataController.CheckEditMode;
        ShowCard(False);
      end
      else
      begin
        FDataController.CheckEditMode;
        if cxDBVerticalGrid.FocusedRow = nil then
          PostInternalMessage(rvcFocusFirstEditable);
      end;
    end;
end;

procedure TzDbRecordView.actDbDeleteExecute(Sender: TObject);
begin
  if Assigned(FOnDataSetDelete) then
    FOnDataSetDelete(Self)
  else
    if FDataController.CanDelete and Flags.ButtonDelete and not IsRecordViewReadOnly then
      if ConfirmYesNo(SEliminoIlRecord) then
        FDataController.Delete;
end;

procedure TzDbRecordView.actDbPostExecute(Sender: TObject);
begin
  Post;
end;

procedure TzDbRecordView.actDbCancelExecute(Sender: TObject);
begin
  Cancel;
end;

procedure TzDbRecordView.actTrovaCampoExecute(Sender: TObject);
var
  Testo: string;
  i, Start, Count: Integer;
  Row: TcxCustomRow;
  Caption: string;
begin
  Testo := FLastSearch;

  if not InputQuery('Trova campo', 'Etichetta del campo:', Testo) then
    Exit;

  Testo := Trim(Testo);
  if Testo = '' then
    Exit;

  FLastSearch := Testo;

  // si riparte dalla riga dopo quella con il fuoco, e si fa il giro
  Count := cxDBVerticalGrid.Rows.Count;
  Start := 0;
  if Assigned(cxDBVerticalGrid.FocusedRow) then
    Start := cxDBVerticalGrid.Rows.IndexOf(cxDBVerticalGrid.FocusedRow) + 1;

  for i := 0 to Count - 1 do
  begin
    Row := cxDBVerticalGrid.Rows[(Start + i) mod Count];

    if not(Row is TcxDBEditorRow) or not Row.Visible then
      Continue;

    Caption := TcxDBEditorRow(Row).Properties.Caption;

    if Pos(UpperCase(Testo), UpperCase(Caption)) > 0 then
    begin
      FocusField(TcxDBEditorRow(Row).Properties.DataBinding.FieldName);
      Exit;
    end;
  end;

  ConfirmOk(Format('Nessun campo contiene "%s".', [Testo]));
end;

procedure TzDbRecordView.actNascondiVuoteExecute(Sender: TObject);
begin
  FHideEmptyRows := actNascondiVuote.Checked;
  ApplyEmptyRows;
  UpdateActions;
end;

procedure TzDbRecordView.actConfrontaExecute(Sender: TObject);
begin
  SetCompareMode(actConfronta.Checked);
end;

procedure TzDbRecordView.EspandiExecute(Sender: TObject);
begin
  ExpandAll;
end;

procedure TzDbRecordView.RiduciExecute(Sender: TObject);
begin
  CollapseAll;
end;

procedure TzDbRecordView.AdattaLarghezzeExecute(Sender: TObject);
begin
  ApplyHeaderBestFit;
end;

procedure TzDbRecordView.ElaboraExecute(Sender: TObject);
begin
  ShowParams(RecordViewID + '_Params', zDataSet, 'Parametri', True);
end;

procedure TzDbRecordView.actExcelBeforeExecute(Sender: TObject);
begin
  if (actExcel.Dialog.InitialDir = '') and zSystemOk then
    actExcel.Dialog.InitialDir := FzSystem.PersonalFolder;
end;

procedure TzDbRecordView.actExcelAccept(Sender: TObject);
var
  FileName: string;
begin
  FileName := actExcel.Dialog.FileName;

  case actExcel.Dialog.FilterIndex of
    2:
      FileName := ChangeFileExt(FileName, '.xls');
    3:
      FileName := ChangeFileExt(FileName, '.csv');
  else
    FileName := ChangeFileExt(FileName, '.xlsx');
  end;

  ExportToFile(FileName);

  ShellExecute(0, PChar('open'), PChar(ExtractFilePath(FileName)), nil, nil, SW_RESTORE);
end;

procedure TzDbRecordView.actStampaExecute(Sender: TObject);
begin
  Preview;
end;

procedure TzDbRecordView.DescrizioneExecute(Sender: TObject);
begin
  if Descrizione.Checked then
    FrameDescription.ShowDescription
  else
    FrameDescription.HideDescription;
end;

procedure TzDbRecordView.RipristinaLayoutExecute(Sender: TObject);
begin
  if not ConfirmYesNo('Ripristinare il layout predefinito della vista?') then
    Exit;

  FStorage.Reset;
  FLoadedUserLayout.Clear;
  FEtichetteAutomatiche := True;

  ApplyGridOptions;
  RebuildRows;
  LoadUserLayout;
end;

procedure TzDbRecordView.actPersonalizzaExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  // le props riflettono prima la griglia, poi l'amministratore le modifica
  FRowsBuilder.AssignToProps(FzDbRecordViewProps);

  if FzDbRecordViewProps.Inspect then
  begin
    LoadProperties(False);
    RebuildRows;
    doSalvaImpostazioni(False);
  end;
end;

procedure TzDbRecordView.actPersonalizzaRigheExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  // il modulo della griglia permette di nascondere, spostare e raccogliere
  // le righe in categorie; Salva impostazioni le porta nel dizionario
  cxDBVerticalGrid.Customizing.ShowCategoryButtons := True;
  cxDBVerticalGrid.Customizing.Visible := True;
end;

procedure TzDbRecordView.actPersonalizzaRigaExecute(Sender: TObject);
var
  ItemName: string;
  Item: TzRecordViewRow;
begin
  if not IsAdmin then
    Exit;

  if not Assigned(cxDBVerticalGrid.FocusedRow) then
    Exit;

  FRowsBuilder.AssignToProps(FzDbRecordViewProps);

  ItemName := FRowsBuilder.ItemOfRow(cxDBVerticalGrid.FocusedRow);
  Item := FzDbRecordViewProps.Rows.get(ItemName, False);

  if not Assigned(Item) then
    Exit;

  if Item.Inspect then
  begin
    RebuildRows;
    doSalvaImpostazioni(False);
    FocusField(ItemName);
  end;
end;

procedure TzDbRecordView.actPersonalizzaCampoExecute(Sender: TObject);
var
  FieldName: string;
  Field: TField;
  Origin: string;
  Idx: Integer;
  Domain: TzDomain;
begin
  if not IsAdmin then
    Exit;

  FieldName := FocusedFieldName;
  if FieldName = '' then
    Exit;

  if not FDataController.TryGetField(FieldName, Field) then
    Exit;

  Origin := FDataController.GetFieldOrigin(Field);

  Idx := FzSystem.zDataDictionary.IndexOf(Origin);
  if Idx = -1 then
    Exit;

  Domain := FzSystem.zDataDictionary[Idx];

  if Domain.Inspect then
  begin
    FzSystem.SaveZip(csFieldProps, 'Personalizzazione Campo DbRecordView');
    RebuildRows;
    FocusField(FieldName);
  end;
end;

procedure TzDbRecordView.actResetRigheExecute(Sender: TObject);
begin
  if not IsAdmin then
    Exit;

  if not ConfirmYesNo('Azzerare ordine, categorie e visibilita'' delle righe?', mtWarning) then
    Exit;

  FzDbRecordViewProps.Rows.Reset(FDataController.zFbDataSet);
  RebuildRows;
end;

procedure TzDbRecordView.SalvaImpostazioniExecute(Sender: TObject);
begin
  doSalvaImpostazioni;
end;

procedure TzDbRecordView.CaricaImpostazioniExecute(Sender: TObject);
begin
  if ConfirmYesNo('Ricarico le impostazioni salvate?') then
    ReloadProps;
end;

procedure TzDbRecordView.actSQLExecute(Sender: TObject);
begin
  if not FDataController.DataSetOk then
    Exit;

  if FzSystem.DataSetEditProps(zDataSet) then
  begin
    FDataController.OpenDataSet;
    RebuildRows;
  end;
end;

procedure TzDbRecordView.MostraQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
    ConfirmOk(FDataController.GetDebugInfo);
end;

procedure TzDbRecordView.CopiaQueryUtilizzataExecute(Sender: TObject);
begin
  if FDataController.DataSetOk then
  begin
    Clipboard.AsText := FDataController.GetDebugInfo;
    ConfirmOk('Query copiata.');
  end;
end;

procedure TzDbRecordView.CopyNameExecute(Sender: TObject);
begin
  Clipboard.AsText := RecordViewID;
  ConfirmOk(RecordViewID);
end;

procedure TzDbRecordView.NomeFileIniExecute(Sender: TObject);
begin
  Clipboard.AsText := FStorage.FileName;
  ConfirmOk(FStorage.FileName);
end;

procedure TzDbRecordView.EditToolsExecute(Sender: TObject);
begin
  ExecuteToolConfig;
end;

procedure TzDbRecordView.EditToolsUpdate(Sender: TObject);
begin
  EditTools.Visible := IsAdmin;
end;

procedure TzDbRecordView.dxBarManagerShowToolbarsPopup(Sender: TdxBarManager; PopupItemLinks: TdxBarItemLinks);
begin
  if IsAdmin then
    popRecordView.PopupFromCursorPos;
end;

procedure TzDbRecordView.PopupRecordViewPopup(Sender: TObject);
begin
  dxBarSubItemImpostazioni.Visible := dx.Visible(IsAdmin);
  dxBarEditTitolo.Visible := dx.Visible(IsAdmin);
  CopyName.Caption := 'Copia RecordViewID - ' + RecordViewID;
end;

// ---------------------------------------------------------------------------
// Scheda del record (come in TzDbView)
// ---------------------------------------------------------------------------

function TzDbRecordView.UsesCard: Boolean;
begin
  result := Assigned(FOnShowCard) or FzDbRecordViewProps.Flags.EditInCard;
end;

function TzDbRecordView.GetCardDlg: TzDbCardDlg;
begin
  // al primo uso: il frame vive anche nel .dfm delle form, e un componente
  // creato nel costruttore finirebbe scritto nel .dfm
  if not Assigned(FCardDlg) then
    FCardDlg := TzDbCardDlg.Create(Self);

  result := FCardDlg;
end;

function TzDbRecordView.EffectiveCardID: string;
begin
  result := Trim(FCardID);

  if result = '' then
    result := FDataController.IdDataSet;
end;

function TzDbRecordView.ShowCard(const Inserting: Boolean): Boolean;
begin
  result := False;

  // il doppio clic e l'azione possono arrivare insieme
  if FShowingCard then
    Exit;

  FShowingCard := True;
  try
    if Assigned(FOnShowCard) then
    begin
      FOnShowCard(Self, Inserting);
      result := True;
      Exit;
    end;

    if not FDataController.IsActive then
      Exit;

    if FDataController.IsEmpty and not Inserting then
      Exit;

    CardDlg.zSystem := zSystem;
    CardDlg.DataSet := zDataSet;
    CardDlg.CardID := EffectiveCardID;
    CardDlg.ReadOnly := IsRecordViewReadOnly;

    result := CardDlg.Execute;

    // come TzDbView.ShowRecord: confermata si scrive, annullata si scarta
    if result then
      FDataController.CheckBrowseMode
    else
      if FDataController.IsEditing then
        FDataController.Cancel;
  finally
    FShowingCard := False;
  end;
end;

function TzDbRecordView.ShowRecord(const doInsert: Boolean): Boolean;
begin
  result := False;

  // con la scheda della form l'inserimento lo fa la form
  if doInsert and not Assigned(FOnShowCard) then
  begin
    if IsRecordViewReadOnly or not FDataController.CanInsert then
      Exit;

    FDataController.Insert;
  end;

  result := ShowCard(doInsert);
end;

procedure TzDbRecordView.GridDblClick(Sender: TObject);
var
  Row: TcxCustomRow;
  CellEditable: Boolean;
begin
  // senza scheda il doppio clic resta alla griglia (modifica nella cella)
  if not UsesCard then
    Exit;

  // su una cella modificabile il doppio clic e' della cella; altrove apre la scheda
  CellEditable := False;
  if cxDBVerticalGrid.OptionsData.Editing then
  begin
    Row := cxDBVerticalGrid.FocusedRow;

    if Row is TcxDBEditorRow then
      CellEditable := EditorRowEditing(TcxDBEditorRow(Row).Properties)
    else
      CellEditable := Row is TcxDBMultiEditorRow;
  end;

  if not CellEditable then
    ShowCard(False);
end;
end.
