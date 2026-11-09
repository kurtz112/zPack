unit zSecurityLoginFrm;

interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.StdCtrls,
  vcl.ExtCtrls,
  vcl.Buttons,
  zSystem,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  vcl.Menus,
  cxMaskEdit,
  cxDropDownEdit,
  cxButtons,
  cxTextEdit, dxUIAClasses;

type
  TCheckUserFunc = TFunc<string, string, string, boolean>;

  TzSecurityLoginForm = class(TForm)
    AppIcon: TImage;
    KeyImage: TImage;
    HintLabel: TLabel;
    UserNameLabel: TLabel;
    PasswordLabel: TLabel;
    UserNameEdit: TcxTextEdit;
    PasswordEdit: TcxTextEdit;
    AppTitleLabel: TLabel;
    OkBtn: TcxButton;
    CancelBtn: TcxButton;
    CustomLabel: TLabel;
    ComboConnections: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure ComboConnectionsEnter(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure IconDblClick(Sender: TObject);
  private
    { Private declarations }
    FAttempt: Integer;
    FzSecurity: TzSecurity;
    procedure SetzSecurity(const Value: TzSecurity);
  private
    CheckUserFunc: TCheckUserFunc;
  private
    procedure BeforeEdit;
    procedure InitComboConnections;
    //
    property Attempt: Integer read FAttempt;
    property zSecurity: TzSecurity read FzSecurity write SetzSecurity;
  public
    function Login(const UserName: string; const ConnectionName: string): boolean;
    function UnLock: boolean;
  end;

function zSecurityDoLogin(zSecurity: TzSecurity; const UserName, Connection: string; CheckUserFunc: TCheckUserFunc): boolean;
function zSecurityDoUnlock(zSecurity: TzSecurity): boolean;

implementation

uses
  zMsg,
  zz.SplashWait;
{$R *.DFM}

const
  AttemptNumber = 3;

type
  // Chi aveva messo a video la schermata di avvio, perche' la si rimetta allo
  // stesso modo dopo la finestra di accesso
  TSchermataNascosta = (
    // nessuna schermata a video: non c'e' niente da rimettere
    snNessuna,
    // l'ha mostrata zz.SplashWait (TSmartSplashForm): va tolta e rimessa
    // passando da li', altrimenti la unit resterebbe convinta che sia a video
    // e la rimetterebbe sopra ogni dialogo aperto durante l'accesso.
    // Fino al 2026-10-09 c'era anche snDiretta, per la schermata mostrata dal
    // programma direttamente con TdxSplashFormManager (le SplashFm di WT,
    // Gesty, zTicser e Analysir): tolta quando tutti e quattro sono passati a
    // zz.SplashWait.
    snSmartSplash);

// Nasconde la schermata di avvio, se ce n'e' una visibile, e dice chi l'aveva
// mostrata -- cosi' chi chiama sa se e come rimetterla.
//
// PERCHE' STA QUI. La schermata di avvio e' sempre in primo piano: aperta una
// finestra di login le finirebbe sotto, e l'utente si trova davanti un
// pannello che non risponde. Fin qui l'accorgimento era a carico
// dell'applicazione (Analysir lo faceva in ConfigModule), ma da fuori non si
// sa se la finestra si aprira' davvero: con utente e password sulla riga di
// comando il login non ne apre nessuna, e la schermata spariva e riappariva
// per niente. Qui dentro il dubbio non c'e': la finestra la stiamo aprendo.
//
// In Monitor restituisce il monitor su cui stava la schermata: la finestra di
// accesso va aperta li'. Nil se la schermata non era a video.
function NascondiSchermataDiAvvio(out Monitor: TMonitor): TSchermataNascosta;
begin
  Monitor := nil;

  if not TSmartSplashForm.IsShowing then
    Exit(snNessuna);

  // Suspend restituisce anche il monitor della schermata
  TSmartSplashForm.Suspend(Monitor);
  result := snSmartSplash;
end;

// Centra la finestra sull'area di lavoro del monitor indicato. Serve perche'
// con poScreenCenter, finche' l'applicazione non ha una finestra principale,
// il monitor lo sceglie Windows: la VCL centra la finestra sul monitor in cui
// Windows l'ha creata (CW_USEDEFAULT) e DefaultMonitor non viene nemmeno
// guardato (TCustomForm.SetWindowToMonitor esce se Application.MainForm e'
// nil). Il risultato e' una finestra di accesso su un monitor e una schermata
// di avvio su un altro.
//
// Senza monitor (schermata non a video) non si tocca niente: CenterForm con nil userebbe il monitor di lavoro, ed e' una
// scelta che spetta al programma, non alla finestra di accesso.
procedure CentraSulMonitor(Form: TForm; Monitor: TMonitor);
begin
  if assigned(Monitor) then
    TWorkingMonitor.CenterForm(Form, Monitor);
end;

procedure RimettiSchermataDiAvvio(const Nascosta: TSchermataNascosta);
begin
  case Nascosta of
    snSmartSplash:
      // Ricalcola la posizione sulla larghezza corrente: senza, dopo una
      // comparsa su un monitor al 150% la schermata tornava scentrata
      TSmartSplashForm.Resume(true);
  end;
end;

function zSecurityDoLogin(zSecurity: TzSecurity; const UserName, Connection: string; CheckUserFunc: TCheckUserFunc): boolean;
var
  zSecurityLoginForm: TzSecurityLoginForm;
  SchermataDiAvvio: TSchermataNascosta;
  MonitorSchermataDiAvvio: TMonitor;
begin
  SchermataDiAvvio := NascondiSchermataDiAvvio(MonitorSchermataDiAvvio);
  try
    zSecurityLoginForm := TzSecurityLoginForm.Create(nil);
    try
      // Sul monitor della schermata di avvio, che e' quello su cui l'utente
      // sta guardando e su cui la schermata ricomparira' dopo l'accesso.
      CentraSulMonitor(zSecurityLoginForm, MonitorSchermataDiAvvio);

      zSecurityLoginForm.zSecurity := zSecurity;
      zSecurityLoginForm.CheckUserFunc := CheckUserFunc;

      result := zSecurityLoginForm.Login(UserName, Connection);
    finally
      FreeAndNil(zSecurityLoginForm);
    end;
  finally
    // Anche se il login fallisce: l'applicazione o prosegue, e allora la
    // schermata serve ancora, o si chiude, e allora non da' fastidio a
    // nessuno.
    RimettiSchermataDiAvvio(SchermataDiAvvio);
  end;
end;

function zSecurityDoUnlock(zSecurity: TzSecurity): boolean;
var
  zSecurityLoginForm: TzSecurityLoginForm;
  SchermataDiAvvio: TSchermataNascosta;
  MonitorSchermataDiAvvio: TMonitor;
begin
  // Stessa ragione di zSecurityDoLogin: anche questa finestra finirebbe sotto
  // la schermata di avvio, nel caso -- raro ma possibile -- di un blocco
  // chiesto mentre l'applicazione sta ancora partendo.
  SchermataDiAvvio := NascondiSchermataDiAvvio(MonitorSchermataDiAvvio);
  try
    zSecurityLoginForm := TzSecurityLoginForm.Create(nil);
    try
      CentraSulMonitor(zSecurityLoginForm, MonitorSchermataDiAvvio);
      zSecurityLoginForm.zSecurity := zSecurity;
      result := zSecurityLoginForm.UnLock;
    finally
      FreeAndNil(zSecurityLoginForm);
    end;
  finally
    RimettiSchermataDiAvvio(SchermataDiAvvio);
  end;
end;

procedure TzSecurityLoginForm.FormCreate(Sender: TObject);
begin
  // Height := MulDiv(Height, CurrentPPI, 96);
end;

{ TzSecurityLoginForm }

procedure TzSecurityLoginForm.OkBtnClick(Sender: TObject);
var
  SetCursor: boolean;
  ErrorMsg: string;
  Accesso: boolean;
begin
  if ComboConnections.ItemIndex = -1 then
  begin
    ConfirmOk('Selezionare una connessione.');
    exit;
  end;

  Inc(FAttempt);

  // 2026-11-01 (DIV-ACC-4): doLogin non restituisce False, solleva
  // un'eccezione con il messaggio del database: senza il try l'eccezione
  // usciva di qui prima del controllo dei tentativi, e il limite non scattava
  // mai. Il tentativo si conta prima di rilanciarla: il messaggio del database
  // lo mostra il gestore dell'applicazione come prima (chiamarlo da qui con
  // Application.HandleException aggiungeva un secondo messaggio tecnico), poi
  // con mrCancel la finestra si chiude e Login avvisa dei troppi tentativi.
  try
    Accesso := CheckUserFunc(ComboConnections.Text, UserNameEdit.Text, PasswordEdit.Text);
  except
    HintLabel.Caption := 'Utente/Password non validi';
    if FAttempt >= AttemptNumber then
      ModalResult := mrCancel;
    raise;
  end;

  if Accesso then
    ModalResult := mrOk
  else
  begin
    ModalResult := mrNone;
    MessageBeep(0);
    ErrorMsg := 'Utente/Password non validi';
    HintLabel.Caption := ErrorMsg;
    // zConfirmOk(ErrorMsg);
  end;

  if (ModalResult <> mrOk) and (FAttempt >= AttemptNumber) then
    ModalResult := mrCancel;
end;

procedure TzSecurityLoginForm.SetzSecurity(const Value: TzSecurity);
begin
  FzSecurity := Value;
end;

procedure TzSecurityLoginForm.IconDblClick(Sender: TObject);
var
  pwd: string;
begin
  pwd := '';
  if zMsg.InputPassword('Admin', 'Password', pwd) then
    if AdminPasswordOk(pwd) then
    begin
      zSecurity.ShowSecurityForm;
      InitComboConnections;
    end;
end;

procedure TzSecurityLoginForm.BeforeEdit;
begin
  HintLabel.Caption := 'Inserire nome utente e password.';
  Icon := Application.Icon;
  if Icon.Empty then
    Icon.Handle := LoadIcon(0, IDI_APPLICATION);
  AppIcon.Picture.Assign(Icon);
  AppTitleLabel.Caption := Application.Title;
  InitComboConnections
end;

procedure TzSecurityLoginForm.ComboConnectionsEnter(Sender: TObject);
begin
  ComboConnections.DroppedDown := True;
end;

procedure TzSecurityLoginForm.InitComboConnections;
var
  i: Integer;
  OldConnection: string;
begin
  OldConnection := ComboConnections.Text;
  ComboConnections.Properties.Items.Clear;

  for i := 0 to zSecurity.zConnections.Count - 1 do
    ComboConnections.Properties.Items.Add(zSecurity.zConnections[i].Name);

  ComboConnections.ItemIndex := ComboConnections.Properties.Items.IndexOf(OldConnection);
end;

function TzSecurityLoginForm.Login(const UserName: string; const ConnectionName: string): boolean;
begin
  FAttempt := 0;
  BeforeEdit;

  FormStyle := fsNormal;

  UserNameEdit.Enabled := True;
  UserNameEdit.Text := UserName;
  ComboConnections.ItemIndex := ComboConnections.Properties.Items.IndexOf(ConnectionName);

  if UserNameEdit.Text = '' then
    ActiveControl := UserNameEdit
  else
    ActiveControl := PasswordEdit;

  result := ShowModal = mrOk;

  // 2026-11-01 (DIV-ACC-4): la finestra si chiude da sola al terzo tentativo
  // non riuscito; Annulla premuto prima non arriva qui con FAttempt pieno.
  if (not result) and (FAttempt >= AttemptNumber) then
    ConfirmOk('Troppi tentativi di accesso non riusciti: il programma viene chiuso.', mtError);
end;

function TzSecurityLoginForm.UnLock: boolean;
begin
  FAttempt := 0;
  BeforeEdit;
  FormStyle := fsNormal;

  UserNameEdit.Text := zSecurity.LoginParams.UserName;
  UserNameEdit.Enabled := false;

  ActiveControl := PasswordEdit;
  result := ShowModal = mrOk;
end;

end.

  d.vclutils rxlogin zsystemfrm
