unit zDescription;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxGeometry,
  dxFramedControl,
  cxButtons,
  dxPanel,
  dxFormattedLabel,
  dxBar,
  cxClasses,
  cxImageList,
  zSystem;

type
  TFrameDescription = class(TFrame)
    dxFormattedLabel: TdxFormattedLabel;
    pnlTop: TdxPanel;
    btnClose: TcxButton;
    ActionList: TActionList;
    dxBarManager: TdxBarManager;
    dxBarPopupMenu: TdxBarPopupMenu;
    Editor: TAction;
    Sinistra: TAction;
    Alto: TAction;
    Basso: TAction;
    Destra: TAction;
    Chiudi: TAction;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    TimerResize: TTimer;
    procedure AltoExecute(Sender: TObject);
    procedure BassoExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure DestraExecute(Sender: TObject);
    procedure dxBarPopupMenuShow(Sender: TObject);
    procedure dxFormattedLabelDblClick(Sender: TObject);
    procedure EditorExecute(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure SinistraExecute(Sender: TObject);
    procedure TimerResizeTimer(Sender: TObject);
  private
    function GetVisible: boolean;
    procedure SetVisible(const Value: boolean);
  private
    FzDescription: TzDescription;
  private
    DisableChanged: boolean;
    FChangedProc: TProc;
    procedure Changed;
  private
    function IsAdmin: boolean;
    procedure InternalSetVisible(const visible: boolean);
    procedure SetAlignment(Align: TAlign);
    procedure ResizeParent(Size: integer);
    procedure SetzDescription(const Value: TzDescription);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure ShowDescription;
    procedure HideDescription;
    procedure ShowEditor;
  public
    property visible: boolean read GetVisible write SetVisible;
  public
    property ChangedProc: TProc read FChangedProc write FChangedProc;

    property zDescription: TzDescription read FzDescription write SetzDescription;
  end;

implementation

uses
  dxFormattedLabelCaptionEditor,
  zDX;
{$R *.dfm}

constructor TFrameDescription.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  DisableChanged := false;
  TimerResize.Enabled := false;
  FChangedProc := nil;
  FzDescription := TzDescription.Create;
end;

destructor TFrameDescription.Destroy;
begin
  FreeAndNil(FzDescription);
  inherited;
end;

procedure TFrameDescription.Changed;
begin

  if not DisableChanged then
    if assigned(FChangedProc) then
      ChangedProc;
end;

function TFrameDescription.IsAdmin: boolean;
begin
  result := true;
end;

procedure TFrameDescription.InternalSetVisible(const visible: boolean);
begin
  // (ini per tenere traccia dei chiusi/aperti)
  Parent.visible := visible;
  zDescription.visible := visible;

  if visible then
    if zDescription.Size = 0 then
      ResizeParent(150);

  Changed;
end;

procedure TFrameDescription.ShowDescription;
begin
  InternalSetVisible(true);
end;

procedure TFrameDescription.HideDescription;
begin
  InternalSetVisible(false);
end;

procedure TFrameDescription.ShowEditor;
begin

  if IsAdmin then
  begin
    dxShowFormattedLabelCaptionEditor(dxFormattedLabel);
    zDescription.Description.text := dxFormattedLabel.Caption;
    Changed;
  end;
end;

procedure TFrameDescription.SetAlignment(Align: TAlign);
begin
  Parent.Align := Align;

  begin
    case Align of
      alTop:
        Parent.Top := -1;
      alBottom:
        Parent.Top := Parent.ClientHeight + 1;
      alLeft:
        Parent.Left := -1;
      alRight:
        Parent.Left := Parent.ClientWidth + 1;
    end;
  end;

  // due volte, è un po' sordo...
  pnlTop.Realign;
  pnlTop.Realign;

  zDescription.Align := Align;

  Alto.checked := Align = alTop;
  Basso.checked := Align = alBottom;
  Sinistra.checked := Align = alLeft;
  Destra.checked := Align = alRight;

  Changed;
end;

procedure TFrameDescription.ResizeParent(Size: integer);
begin

  // Size
  case Parent.Align of
    alNone:
      Parent.Width := Size;
    alTop:
      Parent.Height := Size;
    alBottom:
      Parent.Height := Size;
    alLeft:
      Parent.Width := Size;
    alRight:
      Parent.Width := Size;
    alClient:
      Parent.Width := Size;
    alCustom:
      Parent.Width := Size;
  end;
end;

procedure TFrameDescription.dxBarPopupMenuShow(Sender: TObject);
begin

  if not IsAdmin then
    Abort;
end;

procedure TFrameDescription.dxFormattedLabelDblClick(Sender: TObject);
begin
  ShowEditor;
end;

procedure TFrameDescription.btnCloseClick(Sender: TObject);
begin
  // chiedere conferma?
  HideDescription;
end;

procedure TFrameDescription.ChiudiExecute(Sender: TObject);
begin
  HideDescription;
end;

procedure TFrameDescription.EditorExecute(Sender: TObject);
begin
  ShowEditor;
end;

procedure TFrameDescription.SinistraExecute(Sender: TObject);
begin
  SetAlignment(alLeft);
end;

procedure TFrameDescription.AltoExecute(Sender: TObject);
begin
  SetAlignment(alTop);
end;

procedure TFrameDescription.BassoExecute(Sender: TObject);
begin
  SetAlignment(alBottom);
end;

procedure TFrameDescription.DestraExecute(Sender: TObject);
begin
  SetAlignment(alRight);
end;

function TFrameDescription.GetVisible: boolean;
begin
  result := false;

  if assigned(Parent) then
    result := Parent.visible;
end;

procedure TFrameDescription.SetVisible(const Value: boolean);
begin
  if assigned(Parent) then
    Parent.visible := Value;

  Changed;
end;

procedure TFrameDescription.SetzDescription(const Value: TzDescription);
begin
  DisableChanged := true;
  try
    FzDescription.Assign(Value);
    //
    dxFormattedLabel.Caption := Value.Description.text;

    if assigned(Parent) then
    begin
      // Align
      SetAlignment(Value.Align);
      ResizeParent(Value.Size);
      Parent.visible := Value.visible;
    end;
  finally
    DisableChanged := false;
  end;
end;

procedure TFrameDescription.FrameResize(Sender: TObject);
begin
  TimerResize.Enabled := false;
  TimerResize.Enabled := true;
end;

procedure TFrameDescription.TimerResizeTimer(Sender: TObject);
begin
  TimerResize.Enabled := false;

  if assigned(Parent) then
  begin
    case Parent.Align of
      alNone:
        zDescription.Size := Parent.Width;
      alTop:
        zDescription.Size := Parent.Height;
      alBottom:
        zDescription.Size := Parent.Height;
      alLeft:
        zDescription.Size := Parent.Width;
      alRight:
        zDescription.Size := Parent.Width;
      alClient:
        zDescription.Size := Parent.Width;
      alCustom:
        zDescription.Size := Parent.Width;
    end;
  end;

  Changed;
end;

end.
