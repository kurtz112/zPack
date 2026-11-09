unit zDbCardDlg;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.StdCtrls,
  vcl.ExtCtrls,
  data.DB,
  dxForms,
  zDbCard,
  zSystem,
  OkCancel,
  zFbDataSet,
  zToolActions,
  SmartInspect.vcl,
  SmartInspect.vcl.SiAuto;

type
  TzDbCardForm = class;
  TzOnDbCardDlgEvent = procedure(Dialog: TzDbCardForm) of object;

  TzDbCardDlg = class(TComponent)
  private
    FCaption: string;
    FDataSet: TzFbDataSet;
    FOnCloseDialog: TzOnDbCardDlgEvent;
    FOnInitDialog: TzOnDbCardDlgEvent;
    procedure SetCaption(const Value: string);
    procedure SetDataSet(const Value: TzFbDataSet);
    procedure SetOnCloseDialog(const Value: TzOnDbCardDlgEvent);
    procedure SetOnInitDialog(const Value: TzOnDbCardDlgEvent);
  private
    FCardID: String;
    // firma delle ToolActions della vista gia' copiate nella card della form
    // corrente: FIRMA_DA_COPIARE per una form appena creata
    FFirmaToolActions: string;
    FOnAfterCreateControl: TAfterCreateControlEvent;
    FOnAfterCreateControls: TNotifyEvent;
    FOnAfterCreateDbControl: TAfterCreateDbControlEvent;
    FOnBeforeCreateControl: TBeforeCreateControlEvent;
    FOnBeforeCreateControls: TNotifyEvent;
    FOnBeforeCreateDbControl: TBeforeCreateDbControlEvent;
    FOnBeforeExecute: TzOnDbCardDlgEvent;
    FOnDataSetDelete: TNotifyEvent;
    FOnDataSetEdit: TNotifyEvent;
    FOnDataSetInsert: TNotifyEvent;
    FzSystem: TzSystem;
    procedure SetzSystem(const Value: TzSystem);
    procedure SetMasterView;
    class function FirmaToolActions(Actions: TzToolActions): string; static;
    procedure SetOnAfterCreateControl(const Value: TAfterCreateControlEvent);
    procedure SetOnAfterCreateControls(const Value: TNotifyEvent);
    procedure SetOnAfterCreateDbControl(const Value: TAfterCreateDbControlEvent);
    procedure SetOnBeforeCreateControl(const Value: TBeforeCreateControlEvent);
    procedure SetOnBeforeCreateControls(const Value: TNotifyEvent);
    procedure SetOnBeforeCreateDbControl(const Value: TBeforeCreateDbControlEvent);
    procedure SetOnDataSetDelete(const Value: TNotifyEvent);
    procedure SetOnDataSetEdit(const Value: TNotifyEvent);
    procedure SetOnDataSetInsert(const Value: TNotifyEvent);
    procedure SetReadOnly(const Value: Boolean);
  protected
    procedure UpdateControl;
  private
    FReadOnly: Boolean;
    ReadOnlyAssigned: Boolean;
  public
    zDbCardForm: TzDbCardForm;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateForm;
    procedure DestroyForm;

    function Execute: Boolean;
    procedure DestroyControls;

    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
  published
    property Caption: string read FCaption write SetCaption;
    property CardID: String read FCardID write FCardID;
    property DataSet: TzFbDataSet read FDataSet write SetDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;

    property OnInitDialog: TzOnDbCardDlgEvent read FOnInitDialog write SetOnInitDialog;
    property OnBeforeExecute: TzOnDbCardDlgEvent read FOnBeforeExecute write FOnBeforeExecute;
    property OnCloseDialog: TzOnDbCardDlgEvent read FOnCloseDialog write SetOnCloseDialog;

    property OnDataSetDelete: TNotifyEvent read FOnDataSetDelete write SetOnDataSetDelete;
    property OnDataSetEdit: TNotifyEvent read FOnDataSetEdit write SetOnDataSetEdit;
    property OnDataSetInsert: TNotifyEvent read FOnDataSetInsert write SetOnDataSetInsert;
    property OnBeforeCreateControls: TNotifyEvent read FOnBeforeCreateControls write SetOnBeforeCreateControls;
    property OnAfterCreateControls: TNotifyEvent read FOnAfterCreateControls write SetOnAfterCreateControls;
    property OnBeforeCreateControl: TBeforeCreateControlEvent read FOnBeforeCreateControl write SetOnBeforeCreateControl;
    property OnAfterCreateControl: TAfterCreateControlEvent read FOnAfterCreateControl write SetOnAfterCreateControl;
    property OnBeforeCreateDbControl: TBeforeCreateDbControlEvent read FOnBeforeCreateDbControl write SetOnBeforeCreateDbControl;
    property OnAfterCreateDbControl: TAfterCreateDbControlEvent read FOnAfterCreateDbControl write SetOnAfterCreateDbControl;
  end;

  TzDbCardForm = class(TdxForm)
    OkCancel: TOkCancel;
    zDbCard: TzDbCard;
    ButtonsDataSource: TDataSource;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonsDataSourceDataChange(Sender: TObject; Field: TField);
    procedure ButtonsDataSourceStateChange(Sender: TObject);
    procedure OkCancelDblClick(Sender: TObject);
  private
    UpdateHeightDelayed: Boolean;
    // dialogo trasparente finche' la card non ha la disposizione definitiva
    FRevealPending: Boolean;
    FRevealAttempts: Integer;

    procedure PostInternalMessage(const cmd: Integer);
    procedure BeginHiddenSettle;
    procedure EndHiddenSettle;
    procedure RevealWhenSettled;
    procedure CenterOnMainForm;
    procedure MessageHandler(var Message: TMessage); message ZZ_DBCARDDLG;
  private
    FDataSet: TzFbDataSet;
    FOnBeforeExecute: TzOnDbCardDlgEvent;
    FzSystem: TzSystem;
    procedure SetDataSet(const Value: TzFbDataSet);
    procedure SetzSystem(const Value: TzSystem);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WndProc(var Message: TMessage); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure EnableRecordDlgButton;
    //
    procedure LoadProps;
    property DataSet: TzFbDataSet read FDataSet write SetDataSet;
    property zSystem: TzSystem read FzSystem write SetzSystem;
  public
    constructor Create(aOwner: TComponent); override;
    function Execute: Boolean;

    procedure UpdateHeight; // usato da card
    property OnBeforeExecute: TzOnDbCardDlgEvent read FOnBeforeExecute write FOnBeforeExecute;
  end;

implementation

uses
  zBaseLib,
  zDbView,
  cxDropDownEdit,
  zDx,
  zLocalizer;

{$R *.dfm}

const
  // comandi di ZZ_DBCARDDLG (WParam)
  DLG_CMD_UPDATE_HEIGHT = 0;
  DLG_CMD_REVEAL = 1;
  // limite anti-ciclo: oltre si mostra comunque il dialogo, anche se la card
  // non si e' assestata (meglio un salto che una finestra invisibile)
  MAX_REVEAL_ATTEMPTS = 30;
  // FirmaToolActions produce solo cifre esadecimali, punti e virgola e a capo
  FIRMA_DA_COPIARE = '<da copiare>';

procedure TzDbCardForm.EnableRecordDlgButton;
var
  RecordOk: Boolean;
begin
  RecordOk := True;
  if zDbCard.zDataSet.State in dsEditModes then
    RecordOk := zDbCard.zDataSet.RequiredFieldsOk;

  OkCancel.OkBtn.Enabled := RecordOk;
  OkCancel.CancelBtn.Enabled := True;
end;

function TzDbCardForm.Execute: Boolean;
begin
  zDbCard.Visible := False;

  // ZZ 07.06.2019
  zDbCard.DataSource.Enabled := True;

  LoadProps;

  if assigned(FOnBeforeExecute) then
    OnBeforeExecute(self);

  { TODO : Analizzare }
  Localizer.Translate(self, zDbCard.CardID);

  // Mantis #269 - 2026-10-21: nessun filtro della vista resta aperto e cliccabile
  // accanto alla scheda (anche OnModalBegin lo fa, qui prima di costruire la finestra)
  dx.ChiudiFiltriAperti;

  BeginHiddenSettle;
  try
    Result := ShowModal = mrOk;
  finally
    EndHiddenSettle;
  end;

  // ZZ 07.06.2019 evita di chiamare gli eventi durante lo scroll della view proprietaria
  zDbCard.DataSource.Enabled := False;
end;

procedure TzDbCardForm.FormShow(Sender: TObject);
begin
  /// /////////////////////////////////////////////////////////////
  zDbCard.Visible := True;
  zDbCard.RefreshDisplay;

  ActiveControl := zDbCard;

  /// ///////////////////////////////////////
  ///
  if UpdateHeightDelayed then
    PostInternalMessage(DLG_CMD_UPDATE_HEIGHT)
  else
  begin // form appena creata, deve calcolare subito
    UpdateHeightDelayed := True;
    UpdateHeight;
    // Alla prima apertura il layout del dxLayoutControl potrebbe non essere
    // ancora assestato quando UpdateHeight legge l'altezza occupata: ripetiamo
    // il calcolo in modo differito (dopo che il DXM_LAYOUT_LAYOUTCHANGED postato
    // dalla card e' stato processato), esattamente come per le aperture
    // successive. Cosi' la prima apertura non resta con lo spazio vuoto in fondo.
    PostInternalMessage(DLG_CMD_UPDATE_HEIGHT);
  end;

  // Il dialogo e' ancora trasparente (BeginHiddenSettle): diventa visibile solo
  // quando la card ha la disposizione definitiva. Postato dopo i comandi della
  // card accodati alla comparsa (CreateWnd, RepostDeferred), quindi li trova
  // gia' eseguiti o li aspetta.
  if FRevealPending then
    PostInternalMessage(DLG_CMD_REVEAL);
  // valutare se è il caso
  // Perform(Wm_NextDlgCtl, 0, 0);

  // ZZ 06.02.2019: se è in inserimento forza i lookup a copiare i valori
  if assigned(DataSet) then
    if DataSet.State = dsInsert then
      zDbCard.ForceCopyMappingFields;
end;

procedure TzDbCardForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;

  OkCancel.ResetButtons; // altrimenti il pulsante premuto risulterà invisibile alla successiva apertura

  if not assigned(zDbCard.zDataSet) then
    exit;

  if ModalResult = mrOk then
  begin
    CanClose := False;
    zDbCard.Post;
    CanClose := True;
  end
  else
  begin
    if zDbCard.zDataSet.State in dsEditModes then
      zDbCard.Cancel;
  end;
end;

procedure TzDbCardForm.ButtonsDataSourceDataChange(Sender: TObject; Field: TField);
begin
  EnableRecordDlgButton;
end;

procedure TzDbCardForm.ButtonsDataSourceStateChange(Sender: TObject);
begin
  EnableRecordDlgButton;
end;

constructor TzDbCardForm.Create(aOwner: TComponent);
begin
  inherited;
  FOnBeforeExecute := nil;
  UpdateHeightDelayed := False; // la prima volta deve calcolare subito
  KeyPreview := True;
  // Consorzio 21.01.2016
  Position := poMainFormCenter;
end;

procedure TzDbCardForm.CreateParams(var Params: TCreateParams);
begin
  // https://www.devexpress.com/Support/Center/Question/Details/Q315016/skins-result-in-flickering-for-complex-forms
  inherited CreateParams(Params);
  // disattiva i pulsanti dell'OkCancel
  // Params.Style := Params.Style and not WS_CLIPCHILDREN;
end;

procedure TzDbCardForm.KeyDown(var Key: Word; Shift: TShiftState);
var
  skip: Boolean;
begin
  // inherited;

  if Key = vk_Return then
  begin

    skip := False;

    if assigned(ActiveControl) then
    begin
      if ActiveControl is TCustomMemo then // copre anche RTF
        skip := True
      else
        if dx.ActiveControl is TcxCustomDropDownEdit then
          if (dx.ActiveControl as TcxCustomDropDownEdit).DroppedDown then
            skip := True;
    end;

    if not skip then
    begin
      Key := 0;
      if ssShift in Shift then
        Perform(Wm_NextDlgCtl, 1, 0)
      else
        Perform(Wm_NextDlgCtl, 0, 0);
    end;
  end;

  inherited KeyDown(Key, Shift);
end;

procedure TzDbCardForm.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SYSCOMMAND:
      if Message.WParam = SC_MINIMIZE then
      begin
        ShowWindow(Application.Handle, SW_SHOWMINNOACTIVE);
        exit;
      end;

    WM_ACTIVATE:
      if Message.WParamLo <> WA_INACTIVE then
      begin
        ShowWindow(Application.Handle, SW_SHOWNORMAL);
        self.BringToFront;
      end;
  end;

  inherited WndProc(Message);
end;

procedure TzDbCardForm.SetDataSet(const Value: TzFbDataSet);
begin
  FDataSet := Value;
end;

procedure TzDbCardForm.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
end;

constructor TzDbCardDlg.Create(aOwner: TComponent);
begin
  inherited;
  FCardID := '';
  FzSystem := nil;
  FCaption := '';
  FDataSet := nil;
  FOnInitDialog := nil;
  FOnCloseDialog := nil;
  zDbCardForm := nil;
  FOnBeforeExecute := nil;
  FReadOnly := False;
  ReadOnlyAssigned := False;

  FOnDataSetDelete := nil;
  FOnDataSetEdit := nil;
  FOnDataSetInsert := nil;
  FOnBeforeCreateControls := nil;
  FOnAfterCreateControls := nil;
  FOnBeforeCreateControl := nil;
  FOnAfterCreateControl := nil;
  FOnBeforeCreateDbControl := nil;
  FOnAfterCreateDbControl := nil;
end;

destructor TzDbCardDlg.Destroy;
begin
  DestroyForm;
  inherited;
end;

procedure TzDbCardDlg.CreateForm;
begin
  if assigned(zDbCardForm) then
    exit;

  // zz 24.01.2019
  // Owner è il componente stesso.
  // Application pone problemi di duplicazione nome e altro
  zDbCardForm := TzDbCardForm.Create(self);
  zDbCardForm.FreeNotification(self);
  // card nuova: le azioni della vista vanno copiate anche se la vista non ne
  // ha (firma vuota), come prima, quindi un valore che nessuna firma assume
  FFirmaToolActions := FIRMA_DA_COPIARE;
  zDbCardForm.Name := zDbCardForm.Name + '__' + Owner.Name + '__' + self.Name;
  zDbCardForm.zSystem := zSystem;
  zDbCardForm.DataSet := DataSet;

  zDbCardForm.zDbCard.OnDataSetDelete := OnDataSetDelete;
  zDbCardForm.zDbCard.OnDataSetEdit := OnDataSetEdit;
  zDbCardForm.zDbCard.OnDataSetInsert := OnDataSetInsert;
  zDbCardForm.zDbCard.OnBeforeCreateControls := OnBeforeCreateControls;
  zDbCardForm.zDbCard.OnAfterCreateControls := OnAfterCreateControls;
  zDbCardForm.zDbCard.OnBeforeCreateControl := OnBeforeCreateControl;
  zDbCardForm.zDbCard.OnAfterCreateControl := OnAfterCreateControl;
  zDbCardForm.zDbCard.OnBeforeCreateDbControl := OnBeforeCreateDbControl;
  zDbCardForm.zDbCard.OnAfterCreateDbControl := OnAfterCreateDbControl;

  if ReadOnlyAssigned then
  begin
    if readonly then
      zDbCardForm.zDbCard.ReadOnly := crForceReadOnly
    else
      zDbCardForm.zDbCard.ReadOnly := crForceWriteable;
  end;
end;

procedure TzDbCardDlg.DestroyControls;
begin
  DestroyForm;
end;

procedure TzDbCardDlg.DestroyForm;
begin
  if assigned(zDbCardForm) then
  begin
    if zDbCardForm.Visible then
      zDbCardForm.Close;

    zDbCardForm.Free;
    zDbCardForm := nil;
  end;
end;

class function TzDbCardDlg.FirmaToolActions(Actions: TzToolActions): string;
var
  Elenco: TStringBuilder;
  Item: TzToolAction;
begin
  // Una riga per azione con tutti e soli i valori che TzToolAction.Assign
  // copia: se la firma non cambia, una nuova copia darebbe la stessa card.
  // Azione e ImageList per indirizzo: un'azione distrutta e ricreata conta
  // come diversa, ed e' quello che serve.
  Elenco := TStringBuilder.Create;
  try
    for Item in Actions do
      Elenco.Append(IntToHex(NativeInt(Item.Action), 16)).Append(';')
        .Append(IntToHex(NativeInt(Item.ImageList), 16)).Append(';')
        .Append(Ord(Item.BeginGroup)).Append(';')
        .Append(Ord(Item.LargeButton)).Append(';')
        .Append(Ord(Item.ShowCaption)).Append(';')
        .Append(Item.Position).Append(';')
        .Append(Ord(Item.PopupProps.VisibleInCard)).Append(Ord(Item.PopupProps.VisibleInView)).Append(';')
        .Append(Ord(Item.ToolbarProps.VisibleInCard)).Append(Ord(Item.ToolbarProps.VisibleInView))
        .AppendLine;
    Result := Elenco.ToString;
  finally
    Elenco.Free;
  end;
end;

procedure TzDbCardDlg.SetMasterView;
var
  zDbView: TzDbView;
  Firma: string;
begin

  if Owner is TzDbView then
    zDbView := TzDbView(Owner)
  else
    exit;

  if zDbView.CardID <> '' then
    zDbCardForm.zDbCard.CardID := zDbView.CardID
  else
    zDbCardForm.zDbCard.CardID := zDbView.ViewID;

  // Assign scatena OnChange della card -> InitToolActions, che ricostruisce
  // la barra degli strumenti e i suoi pulsanti: farlo a ogni apertura costava
  // tempo anche con le azioni identiche. Si copia solo se le azioni della vista
  // sono cambiate dall'ultima copia in questa form.
  Firma := FirmaToolActions(zDbView.ToolActions);
  if Firma <> FFirmaToolActions then
  begin
    zDbCardForm.zDbCard.ToolActions.Assign(zDbView.ToolActions);
    FFirmaToolActions := Firma;
  end;

  zDbCardForm.zDbCard.OnBeforeCreateControls := zDbView.OnCardBeforeCreateControls;
  zDbCardForm.zDbCard.OnAfterCreateControls := zDbView.OnCardAfterCreateControls;
  zDbCardForm.zDbCard.OnBeforeCreateControl := zDbView.OnCardBeforeCreateControl;
  zDbCardForm.zDbCard.OnAfterCreateControl := zDbView.OnCardAfterCreateControl;
  zDbCardForm.zDbCard.OnBeforeCreateDbControl := zDbView.OnCardBeforeCreateDbControl;
  zDbCardForm.zDbCard.OnAfterCreateDbControl := zDbView.OnCardAfterCreateDbControl;
  zDbCardForm.zDbCard.OnDataSetDelete := zDbView.OnDataSetDelete;
  zDbCardForm.zDbCard.OnDataSetEdit := zDbView.OnDataSetEdit;
  zDbCardForm.zDbCard.OnDataSetInsert := zDbView.OnDataSetInsert;

  if zDbView.Flags.CardInherits then
  begin
    zDbCardForm.zDbCard.DisableDelete := not zDbView.Flags.ButtonDelete;
    zDbCardForm.zDbCard.DisableInsert := not zDbView.Flags.ButtonInsert;
    zDbCardForm.zDbCard.DisableEdit := not zDbView.Flags.ButtonUpdate;
  end;

  // da policy
  zDbCardForm.zDbCard.RestrictionReadOnly := zDbView.RestrictionReadOnly;
end;

function TzDbCardDlg.Execute: Boolean;
var
  idx: Integer;
  s: string;
begin
  Result := False;

  if not assigned(DataSet) then
    raise exception.Create('Dataset non assegnato: ' + self.Name);

  if not assigned(zDbCardForm) then
    CreateForm;

  if Caption <> '' then
    zDbCardForm.Caption := Caption;

  // zDbCardForm.Name := 'zDbCardDlgForm_' + DataSet.IdDataSet;
  if Owner is TzDbView then
    SetMasterView
  else
    zDbCardForm.zDbCard.CardID := CardID;

  if assigned(FOnInitDialog) then
    OnInitDialog(zDbCardForm);

  zDbCardForm.PopupParent := GetPopupParent(self);
  zDbCardForm.OnBeforeExecute := OnBeforeExecute;
  //
  try
    Result := zDbCardForm.Execute;
  except
    on e: exception do
    begin
      FreeAndNil(zDbCardForm);
      raise;
    end;
  end;

  //
  if assigned(FOnCloseDialog) then
    OnCloseDialog(zDbCardForm);
end;

procedure TzDbCardDlg.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TzDbCardDlg.SetDataSet(const Value: TzFbDataSet);
begin
  if FDataSet <> Value then
  begin
    DestroyForm;
    FDataSet := Value;
  end;
end;

procedure TzDbCardDlg.SetOnAfterCreateControl(const Value: TAfterCreateControlEvent);
begin
  FOnAfterCreateControl := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnAfterCreateControl := Value;
end;

procedure TzDbCardDlg.SetOnAfterCreateControls(const Value: TNotifyEvent);
begin
  FOnAfterCreateControls := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnAfterCreateControls := Value;
end;

procedure TzDbCardDlg.SetOnAfterCreateDbControl(const Value: TAfterCreateDbControlEvent);
begin
  FOnAfterCreateDbControl := Value;
end;

procedure TzDbCardDlg.SetOnBeforeCreateControl(const Value: TBeforeCreateControlEvent);
begin
  FOnBeforeCreateControl := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnBeforeCreateControl := Value;
end;

procedure TzDbCardDlg.SetOnBeforeCreateControls(const Value: TNotifyEvent);
begin
  FOnBeforeCreateControls := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnBeforeCreateControls := Value;
end;

procedure TzDbCardDlg.SetOnBeforeCreateDbControl(const Value: TBeforeCreateDbControlEvent);
begin
  FOnBeforeCreateDbControl := Value;
end;

procedure TzDbCardDlg.UpdateControl;
begin; // interfaccia
end;

procedure TzDbCardDlg.SetOnCloseDialog(const Value: TzOnDbCardDlgEvent);
begin
  FOnCloseDialog := Value;
end;

procedure TzDbCardDlg.SetOnDataSetDelete(const Value: TNotifyEvent);
begin
  FOnDataSetDelete := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnDataSetDelete := Value;
end;

procedure TzDbCardDlg.SetOnDataSetEdit(const Value: TNotifyEvent);
begin
  FOnDataSetEdit := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnDataSetEdit := Value;
end;

procedure TzDbCardDlg.SetOnDataSetInsert(const Value: TNotifyEvent);
begin
  FOnDataSetInsert := Value;

  if assigned(zDbCardForm) then
    if assigned(zDbCardForm.zDbCard) then
      zDbCardForm.zDbCard.OnDataSetInsert := Value;
end;

procedure TzDbCardDlg.SetOnInitDialog(const Value: TzOnDbCardDlgEvent);
begin
  FOnInitDialog := Value;
end;

procedure TzDbCardDlg.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  ReadOnlyAssigned := True;

  if assigned(zDbCardForm) then
  begin
    if readonly then
      zDbCardForm.zDbCard.ReadOnly := crForceReadOnly
    else
      zDbCardForm.zDbCard.ReadOnly := crForceWriteable;
  end;
end;

procedure TzDbCardDlg.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
end;

procedure TzDbCardForm.PostInternalMessage(const cmd: Integer);
begin
  PostMessage(self.Handle, ZZ_DBCARDDLG, cmd, 0);
end;

procedure TzDbCardForm.MessageHandler(var Message: TMessage);
begin
  inherited;
  if Message.WParam = DLG_CMD_REVEAL then
    RevealWhenSettled
  else
    UpdateHeight;
end;

procedure TzDbCardForm.BeginHiddenSettle;
begin
  // Prima di ShowModal la card e' nascosta e costruisce la disposizione su una
  // larghezza stimata; quella reale si legge solo a form mostrata, e la
  // ricostruzione che segue (CheckReflow) sposta i campi e cambia l'altezza.
  // La form viene quindi mostrata trasparente: il layout DevExpress ha le misure
  // vere, ma l'utente vede il dialogo solo ad assestamento finito.
  FRevealPending := True;
  FRevealAttempts := 0;
  AlphaBlendValue := 0;
  AlphaBlend := True;
end;

procedure TzDbCardForm.EndHiddenSettle;
begin
  FRevealPending := False;
  // prima opaca, poi senza WS_EX_LAYERED: la form torna una finestra normale
  AlphaBlendValue := 255;
  AlphaBlend := False;
end;

procedure TzDbCardForm.RevealWhenSettled;
begin
  if not FRevealPending then
    exit;

  Inc(FRevealAttempts);

  // ogni ripostaggio finisce in coda dietro ai comandi della card, che nel
  // frattempo vengono eseguiti
  if (FRevealAttempts < MAX_REVEAL_ATTEMPTS) and not zDbCard.EnsureLayoutSettled then
  begin
    PostInternalMessage(DLG_CMD_REVEAL);
    exit;
  end;

  // dimensioni e posizione finali, poi la form diventa visibile
  UpdateHeight;
  CenterOnMainForm;
  EndHiddenSettle;
end;

procedure TzDbCardForm.CenterOnMainForm;
var
  Riferimento: TCustomForm;
  AreaLavoro: TRect;
  Sinistra: Integer;
  Alto: Integer;
begin
  // poMainFormCenter centra la form quando compare, ma con l'altezza di quel
  // momento: dopo l'assestamento il dialogo resterebbe spostato in basso o in
  // alto. Si ricentra con le dimensioni definitive, finche' e' ancora invisibile.
  if Position <> poMainFormCenter then
    exit;

  Riferimento := Application.MainForm;
  if not assigned(Riferimento) or not Riferimento.Visible then
    exit;

  Sinistra := Riferimento.Left + (Riferimento.Width - Width) div 2;
  Alto := Riferimento.Top + (Riferimento.Height - Height) div 2;

  // dentro l'area di lavoro del monitor in cui si trova il dialogo
  AreaLavoro := Screen.MonitorFromWindow(Handle).WorkAreaRect;
  if Sinistra + Width > AreaLavoro.Right then
    Sinistra := AreaLavoro.Right - Width;
  if Alto + Height > AreaLavoro.Bottom then
    Alto := AreaLavoro.Bottom - Height;
  if Sinistra < AreaLavoro.Left then
    Sinistra := AreaLavoro.Left;
  if Alto < AreaLavoro.Top then
    Alto := AreaLavoro.Top;

  SetBounds(Sinistra, Alto, Width, Height);
end;

procedure TzDbCardForm.LoadProps;
begin
  if not assigned(zSystem) then
    exit;

  if not assigned(DataSet) then
    exit;

  zDbCard.zSystem := zSystem;
  zDbCard.zDataSet := DataSet;

  ButtonsDataSource.DataSet := DataSet;

  self.Caption := zDbCard.GetDialogTitle;
  self.ClientWidth := zDbCard.GetDialogWidth;
end;

procedure TzDbCardForm.UpdateHeight;
var
  h: Integer;
  w: Integer;
  MaxFormHeight: Integer;
  DebugString: string;
  M: TMonitor;
begin

  w := zDbCard.GetDialogWidth;
  if w <> ClientWidth then
    ClientWidth := w;

  h := zDbCard.CalcDialogHeight(True);
  if h > 0 then
    ClientHeight := h + OkCancel.Height + 7;

  if assigned(Application.MainForm) then
  begin
    // M := Screen.MonitorFromWindow(Application.MainForm.Handle);
    M := Screen.MonitorFromWindow(self.Handle);

    MaxFormHeight := M.WorkAreaRect.Bottom - M.WorkAreaRect.Top - 50; // barra inferiore

    if self.Height > MaxFormHeight then
      self.Height := MaxFormHeight;
  end;

  // if  zSystem.IsAdmin then
  // caption :=
end;

procedure TzDbCardForm.OkCancelDblClick(Sender: TObject);
begin

  Caption := self.CurrentPPI.ToString + ' - ' + zDbCard.GetDialogWidth.ToString + ':' + self.ClientWidth.ToString
end;

end.
