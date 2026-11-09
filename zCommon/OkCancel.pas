unit OkCancel;

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
  cxGraphics,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  vcl.Menus,
  cxButtons,
  dxUIAClasses;

type
  TOkCancel = class(TFrame)
    OkBtn: TcxButton;
    CancelBtn: TcxButton;
    PaintBox: TPaintBox;
    ApplyBtn: TcxButton;
    procedure PaintBoxPaint(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
  private
    FSizeGripWidth: Integer;
    FSizeGripHeight: Integer;
    FSizeGripRect: TRect;
    FOnApply: TNotifyEvent;
    FDefaultOk: Boolean;
    FDefaultCancel: Boolean;
    FReadOnly: Boolean;
    FAutoFocus: Boolean;
    procedure SetAutoFocus(const Value: Boolean);
    procedure SetOnApply(const Value: TNotifyEvent);
    procedure SetDefaultCancel(const Value: Boolean);
    procedure SetDefaultOk(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure ReCalcPositions;
    procedure AlignButtons;
    procedure UpdateButtonsState;
  protected
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;

  public
    constructor Create(aOwner: TComponent); override;
    procedure ResetButtons;
  published
    property AutoFocus: Boolean read FAutoFocus write SetAutoFocus default False;
    property DefaultOk: Boolean read FDefaultOk write SetDefaultOk;
    property DefaultCancel: Boolean read FDefaultCancel write SetDefaultCancel;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;

    property OnApply: TNotifyEvent read FOnApply write SetOnApply;
  end;

implementation

{$R *.dfm}

uses
  vcl.Themes,
  System.StrUtils;

constructor TOkCancel.Create(aOwner: TComponent);
begin
  inherited;
  FAutoFocus := False;
  FOnApply := nil;
  FDefaultOk := False;
  FDefaultCancel := False;
  FReadOnly := False;

  AutoScroll := False;
  FSizeGripWidth := GetSystemMetrics(SM_CXVSCROLL);
  FSizeGripHeight := GetSystemMetrics(SM_CYHSCROLL);

  OkBtn.ModalResult := mrOk;
  CancelBtn.ModalResult := mrCancel;

  UpdateButtonsState;
end;

procedure TOkCancel.UpdateButtonsState;
begin
  if csDesigning in ComponentState then
  begin
    ApplyBtn.Enabled := Assigned(FOnApply);

    if FReadOnly then
    begin
      OkBtn.Caption := 'Chiudi';
      CancelBtn.Enabled := False;
    end
    else
    begin
      OkBtn.Caption := 'Ok';
      CancelBtn.Enabled := True;
    end;
  end
  else
  begin
    // Logica Runtime (già verificata)
    OkBtn.Caption := IfThen(FReadOnly, 'Chiudi', 'Ok');
    CancelBtn.Visible := not FReadOnly;
    ApplyBtn.Visible := (not FReadOnly) and Assigned(FOnApply);
  end;

  AlignButtons;
end;

procedure TOkCancel.SetOnApply(const Value: TNotifyEvent);
begin
  FOnApply := Value;
  UpdateButtonsState;
end;

procedure TOkCancel.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    UpdateButtonsState;
  end;
end;

procedure TOkCancel.DefineProperties(Filer: TFiler);
begin
  inherited;
  if csDesigning in ComponentState then
    UpdateButtonsState;
end;

procedure TOkCancel.AlignButtons;
var
  CurrentRight: Integer;
begin
  CurrentRight := PaintBox.Left;

  // In DESIGN-TIME e READONLY: OkBtn deve stare a DESTRA di CancelBtn
  if (csDesigning in ComponentState) and FReadOnly then
  begin
    // 1. Posiziona prima OK (Chiudi) tutto a destra
    OkBtn.Left := CurrentRight - OkBtn.Width - 5;
    CurrentRight := OkBtn.Left;
    // 2. Poi posiziona CANCEL (Annulla) alla sua sinistra
    CancelBtn.Left := CurrentRight - CancelBtn.Width - 5;
    CurrentRight := CancelBtn.Left;
  end
  else
  begin
    // LOGICA STANDARD (Runtime o Editing)
    if CancelBtn.Visible or (csDesigning in ComponentState) then
    begin
      CancelBtn.Left := CurrentRight - CancelBtn.Width - 5;
      CurrentRight := CancelBtn.Left;
    end;
    if OkBtn.Visible or (csDesigning in ComponentState) then
    begin
      OkBtn.Left := CurrentRight - OkBtn.Width - 5;
      CurrentRight := OkBtn.Left;
    end;
  end;

  // APPLY rimane sempre l'ultimo a sinistra
  if ApplyBtn.Visible or (csDesigning in ComponentState) then
    ApplyBtn.Left := CurrentRight - ApplyBtn.Width - 5;
end;

procedure TOkCancel.ReCalcPositions;
begin
  FSizeGripRect := PaintBox.ClientRect;
  FSizeGripRect.Left := FSizeGripRect.Right - FSizeGripWidth;
  FSizeGripRect.Top := FSizeGripRect.Bottom - FSizeGripHeight;
end;

procedure TOkCancel.FrameResize(Sender: TObject);
begin
  ReCalcPositions;
  AlignButtons;
  Refresh;
end;

procedure TOkCancel.Loaded;
begin
  inherited;
  UpdateButtonsState;

  if FAutoFocus and not(csDesigning in ComponentState) then
  begin
    if OkBtn.CanFocus then
      OkBtn.SetFocus;
  end;
end;

procedure TOkCancel.ApplyBtnClick(Sender: TObject);
begin
  if Assigned(FOnApply) then
    FOnApply(Self);
end;

procedure TOkCancel.SetAutoFocus(const Value: Boolean);
begin
  FAutoFocus := Value;
end;

procedure TOkCancel.SetDefaultCancel(const Value: Boolean);
begin
  FDefaultCancel := Value;
  CancelBtn.Cancel := Value;
end;

procedure TOkCancel.SetDefaultOk(const Value: Boolean);
begin
  FDefaultOk := Value;
  OkBtn.Default := Value;
end;

procedure TOkCancel.PaintBoxPaint(Sender: TObject);
begin
  ReCalcPositions;
  if StyleServices.Enabled then
    StyleServices.DrawElement(PaintBox.Canvas.Handle, StyleServices.GetElementDetails(tsSizeBoxRightAlign), FSizeGripRect)
  else
    DrawFrameControl(PaintBox.Canvas.Handle, FSizeGripRect, DFC_SCROLL, DFCS_SCROLLSIZEGRIP);
end;

procedure TOkCancel.WMNCHitTest(var Message: TWMNCHitTest);
var
  P: TPoint;
begin
  inherited;
  ReCalcPositions;
  P := PaintBox.ScreenToClient(SmallPointToPoint(Message.Pos));
  if PtInRect(FSizeGripRect, P) then
    Message.Result := HTBOTTOMRIGHT;
end;

procedure TOkCancel.ResetButtons;
begin
  // Forza il ridisegno dei pulsanti principali se necessario
  if Assigned(OkBtn) then
  begin
    OkBtn.Hide;
    OkBtn.Show;
  end;
  if Assigned(CancelBtn) then
  begin
    CancelBtn.Hide;
    CancelBtn.Show;
  end;
  // Hide e Show rimettono visibile Annulla anche in sola lettura: si ricalcola la visibilita'
  UpdateButtonsState;
end;

end.

  Form_Editor_JSON
