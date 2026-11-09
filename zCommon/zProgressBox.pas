unit zProgressBox;

interface

uses
  SysUtils,
  Windows,
  Classes,
  vcl.Graphics,
  vcl.Forms,
  vcl.StdCtrls,
  vcl.Controls,
  vcl.Dialogs,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  vcl.Menus,
  cxClasses,
  cxProgressBar,
  cxButtons,
  cxLabel,
  dxSkinsCore,
  dxUIAClasses;

type
  TProgressBox = class;

  TProgressDlg = class(TForm, IcxProgress)
    Button: TcxButton;
    Label1: TcxLabel;
    Label2: TcxLabel;
    ProgressBar: TcxProgressBar;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonClick(Sender: TObject);
  private
    ProgressBox: TProgressBox;
    CanCloseDialog: Boolean;
    FCancelEnabled: Boolean;
    FCancelled: Boolean;
    FFirstLabel: string;
    FMaxValue: integer;
    FProgress: integer;
    FSecondLabel: string;
    TaskList: pointer;
    procedure SetCancelEnabled(const Value: Boolean);
    procedure SetFirstLabel(const Value: string);
    procedure SetMaxValue(const Value: integer);
    procedure SetProgress(const Value: integer);
    procedure SetSecondLabel(const Value: string);
  protected
    procedure DoShow; override;
    procedure DoHide; override;

    procedure CalcHeight;
  public
    constructor Create(AOwner: TComponent); override;

    procedure ShowDialog; overload;
    procedure ShowDialog(aMaxValue: integer; const aCaption, aFirstLabel: string); overload;
    procedure ShowDialog(aMaxValue: integer; const aCaption, aFirstLabel, aSecondLabel: string); overload;

    procedure IncProgress(const aProgress: integer = -1); overload;
    procedure IncProgress(const Label1: string); overload;
    procedure IncProgress(const Label1, Label2: string); overload;
    procedure IncProgress(const Progress: integer; const Label1, Label2: string); overload;

    procedure doClose;

    property Cancelled: Boolean read FCancelled;
  public
    property FirstLabel: string read FFirstLabel write SetFirstLabel;
    property SecondLabel: string read FSecondLabel write SetSecondLabel;
    property MaxValue: integer read FMaxValue write SetMaxValue;
    property Progress: integer read FProgress write SetProgress;
    property CancelEnabled: Boolean read FCancelEnabled write SetCancelEnabled;
  public
    // IcxProgress
    procedure OnProgress(Sender: TObject; Percent: integer);
  end;

  TProgressBox = class(TCommonDialog)
  private
    FLabel1, FLabel2, FCaption: string;
    FMaxValue, FProgress: integer;
    FCancelEnabled: Boolean;
    FProgressDlg: TProgressDlg;

    function GetCancelled: Boolean;
    function GetMaxValue: integer;
    function GetProgress: integer;
    function GetProgressDlg: TProgressDlg;
    function GetVisible: Boolean;
    procedure SetMaxValue(Value: integer);
    procedure SetProgress(Value: integer);
    procedure SetCaption(Value: string);
    procedure SetLabel1(Value: string);
    procedure SetLabel2(Value: string);
    procedure SetCancelEnabled(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;

    procedure Show; overload;
    procedure Show(aMaxValue: integer; const aCaption, aFirstLabel: string); overload;
    procedure Show(aMaxValue: integer; const aCaption, aFirstLabel, aSecondLabel: string); overload;

    procedure IncProgress; overload;
    procedure IncProgress(const Label1: string); overload;
    procedure IncProgress(const Label1, Label2: string); overload;
    procedure IncProgress(const Progress: integer; const Label1, Label2: string); overload;

    procedure Close;

    property Cancelled: Boolean read GetCancelled;
    property ProgressDlg: TProgressDlg read GetProgressDlg;
    property Visible: Boolean read GetVisible;
  published
    property Caption: string read FCaption write SetCaption;
    property FirstLabel: string read FLabel1 write SetLabel1;
    property SecondLabel: string read FLabel2 write SetLabel2;
    property MaxValue: integer read GetMaxValue write SetMaxValue;
    property Progress: integer read GetProgress write SetProgress;
    property CancelEnabled: Boolean read FCancelEnabled write SetCancelEnabled;
  end;

var
  OnProgressBox_Show: TProc<integer> = nil;
  OnProgressBox_Progress: TProc<integer> = nil;
  OnProgressBox_Paused: TProc = nil;
  OnProgressBox_Close: TProc = nil;

implementation

uses
  vcl.FileCtrl,
  zMsg;

{$R *.DFM}

procedure TProgressDlg.ButtonClick(Sender: TObject);
begin

  if assigned(OnProgressBox_Paused) then
    OnProgressBox_Paused;

  if not ConfirmYesNo('Si desidera terminare l''operazione') then
    Exit;

  CanCloseDialog := True;
  FCancelled := True;

  doClose;
end;

constructor TProgressDlg.Create(AOwner: TComponent);
begin
  inherited;
  ProgressBox := TProgressBox(AOwner);

  FCancelEnabled := True;
  FCancelled := False;
  CanCloseDialog := False;
end;

procedure TProgressDlg.CalcHeight;
const
  vSep = 7;
var
  y: integer;
begin
  y := Label1.top + Label1.Height + vSep;
  // inizializzata in ShowDialog, se nel ciclo qualcuno la valorizza
  // allora deve essere mostrata
  if not FSecondLabel.IsEmpty then
    Label2.Visible := True;

  if Label2.Visible then
  begin
    Label2.top := y;
    y := Label2.top + Label2.Height + vSep;
  end;

  ProgressBar.top := y;
  Button.top := y;

  Self.ClientHeight := ProgressBar.top + ProgressBar.Height + Label1.top; // label1.top usato come margine
end;

procedure TProgressDlg.doClose;
var
  EraVisibile: Boolean;
begin
  EraVisibile := Visible;
  CanCloseDialog := True;
  Hide;
  Close;

  // il gancio scatta solo se la barra era a video: una chiusura ripetuta o su
  // una barra mai mostrata non deve sbilanciare chi tiene un conteggio
  if EraVisibile and assigned(OnProgressBox_Close) then
    OnProgressBox_Close;
end;

{ TProgressDlg }

procedure TProgressDlg.DoHide;
begin
  inherited;
  EnableTaskWindows(TaskList);
end;

procedure TProgressDlg.DoShow;
begin
  inherited;
  TaskList := DisableTaskWindows(Handle);
end;

procedure TProgressDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CanCloseDialog;
end;

procedure TProgressDlg.IncProgress(const aProgress: integer = -1);
begin

  if aProgress = -1 then
    Progress := Progress + 1
  else
    Progress := aProgress;

  Application.ProcessMessages;

  if assigned(OnProgressBox_Progress) then
    OnProgressBox_Progress(Progress);
end;

procedure TProgressDlg.IncProgress(const Label1: string);
begin
  FirstLabel := Label1;
  IncProgress;
end;

procedure TProgressDlg.IncProgress(const Label1, Label2: string);
begin
  FirstLabel := Label1;
  SecondLabel := Label2;
  IncProgress;
end;

procedure TProgressDlg.IncProgress(const Progress: integer; const Label1, Label2: string);
begin
  FirstLabel := Label1;
  SecondLabel := Label2;
  IncProgress(Progress);
end;

procedure TProgressDlg.OnProgress(Sender: TObject; Percent: integer);
begin
  // la percentuale si riporta al massimo del componente
  ProgressBox.Progress := MulDiv(Percent, ProgressBox.MaxValue, 100);
end;

procedure TProgressDlg.SetCancelEnabled(const Value: Boolean);
begin
  FCancelEnabled := Value;
  Button.Enabled := Value;
end;

procedure TProgressDlg.SetFirstLabel(const Value: string);
begin
  FFirstLabel := Value;
  Label1.Caption := MinimizeName(Value, Label1.Canvas.Canvas, Label1.Width);
end;

procedure TProgressDlg.SetMaxValue(const Value: integer);
begin
  FMaxValue := Value;
  ProgressBar.Properties.Max := Value;
end;

procedure TProgressDlg.SetProgress(const Value: integer);
begin
  FProgress := Value;

  // oltre il massimo la barra si ferma al massimo
  if Value <= MaxValue then
    ProgressBar.Position := Value
  else
    ProgressBar.Position := MaxValue;
end;

procedure TProgressDlg.SetSecondLabel(const Value: string);
begin
  FSecondLabel := Value;
  Label2.Caption := MinimizeName(Value, Label2.Canvas.Canvas, Label2.Width);
  CalcHeight;
end;

procedure TProgressDlg.ShowDialog;
begin
  FCancelled := False;
  CanCloseDialog := False;
  Progress := 0;

  Label2.Visible := not FSecondLabel.IsEmpty; // inizializza

  CalcHeight;
  Show;
end;

procedure TProgressDlg.ShowDialog(aMaxValue: integer; const aCaption, aFirstLabel, aSecondLabel: string);
begin
  MaxValue := aMaxValue;
  Caption := aCaption;
  FirstLabel := aFirstLabel;
  SecondLabel := aSecondLabel;

  if assigned(OnProgressBox_Show) then
    OnProgressBox_Show(aMaxValue);

  ShowDialog;
end;

procedure TProgressDlg.ShowDialog(aMaxValue: integer; const aCaption, aFirstLabel: string);
begin
  ShowDialog(aMaxValue, aCaption, aFirstLabel, '');
end;

constructor TProgressBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FProgressDlg := nil;
  CancelEnabled := True;
end;

procedure TProgressBox.SetMaxValue(Value: integer);
begin
  FMaxValue := Value;

  if assigned(ProgressDlg) then
    ProgressDlg.MaxValue := Value;
end;

procedure TProgressBox.SetProgress(Value: integer);
begin
  FProgress := Value;

  if assigned(ProgressDlg) then
    ProgressDlg.Progress := Value;
end;

procedure TProgressBox.Show;
begin
  ProgressDlg.ShowDialog;
end;

procedure TProgressBox.Show(aMaxValue: integer; const aCaption, aFirstLabel: string);
begin
  ProgressDlg.ShowDialog(aMaxValue, aCaption, aFirstLabel, '');
end;

procedure TProgressBox.Show(aMaxValue: integer; const aCaption, aFirstLabel, aSecondLabel: string);
begin
  ProgressDlg.ShowDialog(aMaxValue, aCaption, aFirstLabel, aSecondLabel);
end;

procedure TProgressBox.SetCaption(Value: string);
begin
  FCaption := Value;

  if assigned(ProgressDlg) then
    ProgressDlg.Caption := FCaption;
end;

procedure TProgressBox.SetLabel1(Value: string);
begin
  FLabel1 := Value;

  if assigned(ProgressDlg) then
    ProgressDlg.FirstLabel := Value;
end;

procedure TProgressBox.SetLabel2(Value: string);
begin
  FLabel2 := Value;

  if assigned(ProgressDlg) then
    ProgressDlg.SecondLabel := Value;
end;

procedure TProgressBox.SetCancelEnabled(Value: Boolean);
begin
  FCancelEnabled := Value;

  if assigned(ProgressDlg) then
    ProgressDlg.CancelEnabled := Value;
end;

procedure TProgressBox.Close;
begin
  ProgressDlg.doClose;
end;

function TProgressBox.GetCancelled: Boolean;
begin
  Result := False;

  if assigned(ProgressDlg) then
    Result := ProgressDlg.Cancelled;
end;

function TProgressBox.GetMaxValue: integer;
begin
  Result := FMaxValue;

  if assigned(ProgressDlg) then
    Result := ProgressDlg.MaxValue;
end;

function TProgressBox.GetProgress: integer;
begin
  Result := FProgress;

  if assigned(ProgressDlg) then
    Result := ProgressDlg.Progress;
end;

function TProgressBox.GetProgressDlg: TProgressDlg;
begin

  if csDesigning in componentState then
    Result := nil
  else
  begin

    if not assigned(FProgressDlg) then
      FProgressDlg := TProgressDlg.Create(Self); // zz 05.03.2019

    Result := FProgressDlg;
  end;
end;

function TProgressBox.GetVisible: Boolean;
begin
  Result := assigned(FProgressDlg) and ProgressDlg.Visible;
end;

procedure TProgressBox.IncProgress;
begin
  ProgressDlg.IncProgress;
end;

procedure TProgressBox.IncProgress(const Label1: string);
begin
  ProgressDlg.IncProgress(Label1);
end;

procedure TProgressBox.IncProgress(const Label1, Label2: string);
begin
  ProgressDlg.IncProgress(Label1, Label2);
end;

procedure TProgressBox.IncProgress(const Progress: integer; const Label1, Label2: string);
begin
  ProgressDlg.IncProgress(Progress, Label1, Label2);
end;

end.
