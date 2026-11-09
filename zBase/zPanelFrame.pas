unit zPanelFrame;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Buttons,
  vcl.StdCtrls,
  vcl.ExtCtrls,
  vcl.Forms;

type
  TzPanelFrame = class(TFrame)
    fPanello: TScrollBox;
    fBottone: TSpeedButton;
    fTitolo: TStaticText;
    Separatore: TStaticText;
    SizePanel: TPanel;
    procedure fBottoneClick(Sender: TObject);
    procedure SizePanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SizePanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SizePanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
    procedure RiduciEspandi(Sender: TObject);
  private
    OldHeight: Integer;
    FDragging: Boolean;
    DownPos: TPoint;
    FMinimized: Boolean;
    procedure SetMinimized(const Value: Boolean);
  protected
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Minimized: Boolean read FMinimized write SetMinimized;
    property _Bottone: TSpeedButton read fBottone;
    property _Pannello: TScrollBox read fPanello;
    property _Titolo: TStaticText read fTitolo;
    { Public declarations }
  end;

procedure Register;

implementation

{$R *.dfm}

procedure Register;
begin
  RegisterComponents('Zebro', [TzPanelFrame]);
end;

constructor TzPanelFrame.Create(AOwner: TComponent);
begin
  inherited;
  fPanello.SetSubComponent(True);
  fBottone.SetSubComponent(True);
  fTitolo.SetSubComponent(True);

  fBottone.Align := alRight;
  fTitolo.Align := alClient;

  VertScrollBar.Visible := False;
  OldHeight := Height;
  FMinimized := False;
  FDragging := False;

  fPanello.OnDblClick := RiduciEspandi;
  fBottone.OnClick := RiduciEspandi;
  fTitolo.OnDblClick := RiduciEspandi;
end;

procedure TzPanelFrame.fBottoneClick(Sender: TObject);
begin
  Minimized := not Minimized;
end;

procedure TzPanelFrame.SetMinimized(const Value: Boolean);
begin
  if FMinimized <> Value then
  begin
    FMinimized := Value;

    SizePanel.Visible := not Minimized;
    SizePanel.Top := 0;
    if Minimized then
    begin
      OldHeight := Height;
      Height := fPanello.Height;
    end
    else
    begin
      if OldHeight > fPanello.Height + 20 then
        Height := OldHeight
      else
        Height := 100;
    end;
  end;
end;

procedure TzPanelFrame.SizePanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    FDragging := True;
    DownPos := Point(x, y);
  end;
end;

procedure TzPanelFrame.SizePanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  NewHeight: Integer;
begin
  if not FDragging then
    Exit;

  NewHeight := Height - (Y - DownPos.Y);

  if NewHeight < fPanello.Height then
    NewHeight := fPanello.Height + 10;

  Height := NewHeight;
end;

procedure TzPanelFrame.SizePanelMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

procedure TzPanelFrame.FrameResize(Sender: TObject);
begin
  if not Minimized then
    OldHeight := Height;
end;

procedure TzPanelFrame.RiduciEspandi(Sender: TObject);
begin
  Minimized := not Minimized;
end;

end.

