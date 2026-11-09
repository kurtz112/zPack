
unit zSideBar;

interface

uses
  Messages,
  Windows,
  SysUtils,
  Classes,
  Controls,
  Forms,
  ImgList,
  ActnList,
  StdCtrls,
  ExtCtrls,
  Graphics,
  ComCtrls;

type

  { TFourthShortcutBarColors }

  TzSideBarColors = class(TPersistent)
  private
    FBG: TColor;
    FBtnFace: TColor;
    FBtnLight: TColor;
    FBtnShadow: TColor;
    FBtnText: TColor;
    FBtnTextDisabled: TColor;
    FFace: TColor;
    FShadow: TColor;
    FLight: TColor;
    FDarkShadow: TColor;
    FHighlight: TColor;
    FUseDefault: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetBG(Value: TColor);
    procedure SetBtnFace(Value: TColor);
    procedure SetBtnLight(Value: TColor);
    procedure SetBtnShadow(Value: TColor);
    procedure SetBtnText(Value: TColor);
    procedure SetBtnTextDisabled(Value: TColor);
    procedure SetFace(Value: TColor);
    procedure SetShadow(Value: TColor);
    procedure SetLight(Value: TColor);
    procedure SetDarkShadow(Value: TColor);
    procedure SetHighlight(Value: TColor);
    procedure SetUseDefault(Value: Boolean);
  protected
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create;
  published
    property Background: TColor read FBG write SetBG default clBtnShadow;
    property BtnFace: TColor read FBtnFace write SetBtnFace default clBtnShadow;
    property BtnLight: TColor read FBtnLight write SetBtnLight default clBtnHighlight;
    property BtnShadow: TColor read FBtnShadow write SetBtnShadow default cl3DDkShadow;
    property BtnText: TColor read FBtnText write SetBtnText default clBtnHighlight;
    property BtnTextDisabled: TColor read FBtnText write SetBtnTextDisabled default clBtnFace;
    property Face: TColor read FFace write SetFace default clBtnFace;
    property Shadow: TColor read FShadow write SetShadow default clBtnShadow;
    property Light: TColor read FLight write SetLight default cl3DLight;
    property DarkShadow: TColor read FDarkShadow write SetDarkShadow default cl3DDkShadow;
    property Highlight: TColor read FHighlight write SetHighlight default clBtnHighlight;
    property UseDefault: Boolean read FUseDefault write SetUseDefault default True;
  end;

  { TzSideBar }

  TzSideBarButtonState = (sbbsHot, sbbsDefault, sbbsPressed);

  TzSideBar = class;
  TzSideBarPanel = class;
  TzSideBarButton = class;
  TzSideBarButtons = class;

  TzSideBarButtonActionLink = class(TActionLink)
  protected
    FClient: TzSideBarButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCaptionLinked: Boolean; override;
    function IsEnabledLinked: Boolean; override;
    function IsVisibleLinked: Boolean; override;
    function IsOnExecuteLinked: Boolean; override;
    procedure SetCaption(const Value: string); override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetVisible(Value: Boolean); override;
    procedure SetOnExecute(Value: TNotifyEvent); override;
    function IsImageIndexLinked: Boolean; override;
    procedure SetImageIndex(Value: Integer); override;
  end;

  TzSideBarButtonActionLinkClass = class of TzSideBarButtonActionLink;

  { TzSideBarButton }

  TzSideBarButton = class(TCollectionItem)
  private
    FActionLink: TzSideBarButtonActionLink;
    FButtonRect: TRect;
    FData: Pointer;
    FDeleting: Boolean;
    FDisplayRect: TRect;
    FEnabled: Boolean;
    FCaption: TCaption;
    FImageIndex: Integer;
    FOnClick: TNotifyEvent;
    FTag: LongInt; // offered by JH
    FVisible: Boolean;
    procedure SetData(const Value: Pointer);
    procedure SetCaption(const Value: TCaption);
    procedure SetOnClick(const Value: TNotifyEvent);
    procedure SetImageIndex(Value: Integer);
    procedure SetEnabled(Value: Boolean);
  protected
    function GetDisplayName: string; override;
    procedure Click;
    procedure DoActionChange(Sender: TObject);
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); dynamic;
    function GetAction: TBasicAction;
    function GetActionLinkClass: TzSideBarButtonActionLinkClass; dynamic;
    procedure SetAction(Value: TBasicAction);
    procedure SetVisible(Value: Boolean);
    function IsCaptionStored: Boolean;
    function IsEnabledStored: Boolean;
    function IsVisibleStored: Boolean;
    function IsOnClickStored: Boolean;
    property ActionLink: TzSideBarButtonActionLink read FActionLink write FActionLink;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
    property Data: Pointer read FData write SetData;
  published
    property Action: TBasicAction read GetAction write SetAction;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Caption: TCaption read FCaption write SetCaption;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Tag: LongInt read FTag write FTag default 0; // offered by JH
    property OnClick: TNotifyEvent read FOnClick write SetOnClick;
  end;

  { TzSideBarButtons }

  TzSideBarButtons = class(TCollection)
  private
    FFourthShortcutBarPanel: TzSideBarPanel;
    function GetItem(Index: Integer): TzSideBarButton;
    procedure SetItem(Index: Integer; Value: TzSideBarButton);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(FourthShortcutBarPanel: TzSideBarPanel);
    function Add: TzSideBarButton;
    procedure Delete(Index: Integer); //override;
    property Items[Index: Integer]: TzSideBarButton read GetItem write SetItem; default;
  end;

  { TzSideBarPanelActionLink }

  TzSideBarPanelActionLink = class(TActionLink)
  protected
    FClient: TzSideBarPanel;
    procedure AssignClient(AClient: TObject); override;
    function IsCaptionLinked: Boolean; override;
    function IsOnExecuteLinked: Boolean; override;
    procedure SetCaption(const Value: string); override;
    procedure SetOnExecute(Value: TNotifyEvent); override;
  end;

  TzSideBarPanelActionLinkClass = class of TzSideBarPanelActionLink;

  { TzSideBarPanel }

  TzSideBarPanel = class(TCollectionItem)
  private
    FActionLink: TzSideBarPanelActionLink;
    FFourthShortcutBar: TzSideBar;
    FData: Pointer;
    FDeleting: Boolean;
    FDisplayRect: TRect;
    FCaption: TCaption;
    FButtons: TzSideBarButtons;
    FOnClick: TNotifyEvent;
    FSmallImages: Boolean;
    FTag: LongInt; // offered by JH
    procedure SetData(const Value: Pointer);
    procedure SetCaption(const Value: TCaption);
    procedure SetButtons(const Value: TzSideBarButtons);
    procedure SetOnClick(const Value: TNotifyEvent);
    procedure SetSmallImages(const Value: Boolean);
  protected
    function GetDisplayName: string; override;
    procedure Click;
    procedure DoActionChange(Sender: TObject);
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); dynamic;
    function GetAction: TBasicAction;
    function GetActionLinkClass: TzSideBarPanelActionLinkClass; dynamic;
    procedure SetAction(Value: TBasicAction);
    property ActionLink: TzSideBarPanelActionLink read FActionLink write FActionLink;
    property Bar: TzSideBar read FFourthShortcutBar;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Data: Pointer read FData write SetData;
  published
    property Action: TBasicAction read GetAction write SetAction;
    property Buttons: TzSideBarButtons read FButtons write SetButtons;
    property SmallImages: Boolean read FSmallImages write SetSmallImages;
    property Tag: LongInt read FTag write FTag default 0; // offered by JH
    property Caption: TCaption read FCaption write SetCaption;
    property OnClick: TNotifyEvent read FOnClick write SetOnClick;
  end;

  { TzSideBarPanels }

  TzSideBarPanels = class(TCollection)
  private
    FFourthShortcutBar: TzSideBar;
    function GetItem(Index: Integer): TzSideBarPanel;
    procedure SetItem(Index: Integer; Value: TzSideBarPanel);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(FourthShortcutBar: TzSideBar);
    function Add: TzSideBarPanel;
    procedure Delete(Index: Integer);
    procedure Assign(Source: TPersistent); override;
    property Items[Index: Integer]: TzSideBarPanel read GetItem write SetItem; default;
  end;

  { TzSideBar }

  TzSideBarStyle = (sbs2000, sbs2002);

  TDrawPanelEvent = procedure(FourthShortcutBar: TzSideBar;
    Panel: TzSideBarPanel; const Rect: TRect) of object;

  TzSideBar = class(TCustomControl)
  private
    FPanelCursor: TCursor;
    FPanels: TzSideBarPanels;
    FPanelRect: TRect; { rectangle for active panel buttons }
    FScrollTimer: TTimer; { timer for scroll repeat }
    FScrollTop: Integer; { first visible button }
    FScrollBottom: Integer; { last visible button }
    FUpR: TRect; { rect for up scroll button }
    FUpActive: Boolean; { upscroller visible }
    FUpIsDown: Boolean; { upscroller depressed }
    FDownR: TRect; { rect for down scroll button }
    FDownActive: Boolean; { downscroller visible }
    FDownIsDown: Boolean; { downscroller depressed }
    FPanelIndex: Integer; { current panel }
    FTabHeight: Integer; { height of the clickable tabs }
    FPanelHeight: Integer; { current height of the buttons area }
    FDownTab: Integer; { current mousedown Tab }
    FDownButton: Integer; { current mousedown Button }
    FMoveButton: Integer; { current mousemove Button }
    FMoveTab: Integer; { current mousemove Tab }
    FImages: TImagelist; { large images, caption displayed below image }
    FSmallImages: TImageList; { small images, caption displayed right of image }
    FColors: TzSideBarColors; { customized colors }
    FStyle: TzSideBarStyle; { style of look: 2000 or 2002}
    FUseSystemFont: Boolean;
    FSelectedButton: Integer;
    procedure SetPanelCursor(Value: TCursor);
    procedure SetPanels(Value: TzSideBarPanels);
    procedure SetStyle(Value: TzSideBarStyle);
    procedure SetUseSystemFont(Value: Boolean);
    procedure UpdatePanelHeader(Index: Integer; State: TzSideBarButtonState);
    procedure UpdatePanels;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetPanelIndex(const Value: Integer);
    procedure SetTabHeight(const Value: Integer);
    procedure SetImages(const Value: TImagelist);
    procedure UpdatePanel(First: Boolean; Index: Integer);
    procedure UpdateButton(aPanel, aButton: Integer; State: TzSideBarButtonState);
    procedure SetSmallImages(const Value: TImageList);
    function GetButtonArea(pt: TPoint): Integer;
    procedure DrawDownRaised;
    procedure DrawDownSunken;
    procedure DrawUpRaised;
    procedure DrawUpSunken;
    procedure DrawRaised(R: TRect);
    procedure DrawUpArrow(R: TRect);
    procedure DrawDownArrow(R: TRect);
    procedure DrawSunken(R: TRect);
    procedure TimedScroll(Sender: TObject);
  protected
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure ClickAtPos(APoint: TPoint);
    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ColorsChange(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Assign(Source: TPersistent); override;
    procedure ApplyStandardColors;
    function GetPanelAtPos(APoint: TPoint): Integer;
    function GetButtonAtPos(Pt: TPoint): Integer;
  published
    property Align default alLeft;
    property Enabled;
    property Font stored True;
    property Images: TImageList read FImages write SetImages;
    property Hint;
    property Panels: TzSideBarPanels read FPanels write SetPanels;
    property PanelIndex: Integer read FPanelIndex write SetPanelIndex;
    property Colors: TzSideBarColors read FColors write FColors;
    property PanelCursor: TCursor read FPanelCursor write SetPanelCursor default crDefault;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property SelectedButton: Integer read FSelectedButton default -1;
    property ShowHint;
    property SmallImages: TImageList read FSmallImages write SetSmallImages;
    property Style: TzSideBarStyle read FStyle write SetStyle;
    property TabHeight: Integer read FTabHeight write SetTabHeight;
    property Visible;
    property UseSystemFont: Boolean read FUseSystemFont write SetUseSystemFont;
    property OnClick;
    property OnContextPopup;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

uses Math,
  Consts;

{ TzSideBarColors }

function GetXPPressedHighlight: TColor;
var
  r, g, b: Double;
  rgb: Longint;
  r_c, g_c, b_c: Double;
  rgb_c: Longint;
begin
  rgb := ColorToRGB(clBtnFace);
  r := rgb and $FF;
  g := (rgb shr 8) and $FF;
  b := (rgb shr 16) and $FF;

  rgb_c := ColorToRGB(clHighlight);
  r_c := rgb_c and $FF;
  g_c := (rgb_c shr 8) and $FF;
  b_c := (rgb_c shr 16) and $FF;

  r := r + (r_c - r) { * 0.75};
  g := g + (g_c - g) { * 0.75};
  b := b + (b_c - b) { * 0.75};

  r := r + (225 - r) * 0.6;
  g := g + (225 - g) * 0.6;
  b := b + (225 - b) * 0.6;

  r := r - (integer(122) - r) * 0.25;
  g := g - (integer(122) - g) * 0.25;
  b := b - (integer(122) - b) * 0.25;

  Result := TColor((Max(Min(Round(b), 255), 0) shl 16)
    or (Max(Min(Round(g), 255), 0) shl 8)
    or Max(Min(Round(r), 255), 0));
end;

function GetXPHotHighlight: TColor;
var
  r, g, b: Double;
  rgb: Longint;
  r_c, g_c, b_c: Double;
  rgb_c: Longint;
begin
  rgb := ColorToRGB(clBtnFace);
  r := rgb and $FF;
  g := (rgb shr 8) and $FF;
  b := (rgb shr 16) and $FF;

  rgb_c := ColorToRGB(clHighlight);
  r_c := rgb_c and $FF;
  g_c := (rgb_c shr 8) and $FF;
  b_c := (rgb_c shr 16) and $FF;

  r := r + (r_c - r) * 0.621;
  g := g + (g_c - g) * 0.621;
  b := b + (b_c - b) * 0.621;

  r := r + (225 - r) * 0.6;
  g := g + (225 - g) * 0.6;
  b := b + (225 - b) * 0.6;

  r := r - (integer(122) - r) * 0.25;
  g := g - (integer(122) - g) * 0.25;
  b := b - (integer(122) - b) * 0.25;

  Result := TColor((Max(Min(Round(b), 255), 0) shl 16)
    or (Max(Min(Round(g), 255), 0) shl 8)
    or Max(Min(Round(r), 255), 0));
end;

constructor TzSideBarColors.Create;
begin
  FBG := clBtnShadow;
  FBtnFace := clBtnShadow;
  FBtnLight := clBtnHighlight;
  FBtnShadow := cl3DDkShadow;
  FBtnText := clBtnHighlight;
  FBtnTextDisabled := clBtnFace;
  FFace := clBtnFace;
  FShadow := clBtnShadow;
  FLight := cl3dLight;
  FDarkShadow := cl3dDkShadow;
  FHighlight := clBtnHighlight;
  FUseDefault := True;
end;

function Get2002Bg(const AColor: TColor): TColor;
var
  R, G, B: Byte;
  BtnFaceRGB: Longint;
begin
  BtnFaceRGB := ColorToRGB(clBtnFace);
  if (GetRValue(BtnFaceRGB) + 7) > 255 then
    R := 255
  else
    R := GetRValue(BtnFaceRGB) + 7;
  if (GetGValue(BtnFaceRGB) + 8) > 255 then
    G := 255
  else
    G := GetGValue(BtnFaceRGB) + 8;
  if (GetBValue(BtnFaceRGB) + 9) > 255 then
    B := 255
  else
    B := GetBValue(BtnFaceRGB) + 9;
  Result := RGB(R, G, B);
end;

procedure TzSideBarColors.SetBG(Value: TColor);
begin
  if (FBG <> Value) then
  begin
    FBG := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetBtnFace(Value: TColor);
begin
  if (FBtnFace <> Value) then
  begin
    FBtnFace := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetBtnLight(Value: TColor);
begin
  if (FBtnLight <> Value) then
  begin
    FBtnLight := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetBtnShadow(Value: TColor);
begin
  if (FBtnShadow <> Value) then
  begin
    FBtnShadow := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetBtnText(Value: TColor);
begin
  if (FBtnText <> Value) then
  begin
    FBtnText := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetBtnTextDisabled(Value: TColor);
begin
  if (FBtnTextDisabled <> Value) then
  begin
    FBtnTextDisabled := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetFace(Value: TColor);
begin
  if (FFace <> Value) then
  begin
    FFace := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetShadow(Value: TColor);
begin
  if (FShadow <> Value) then
  begin
    FShadow := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetLight(Value: TColor);
begin
  if (FLight <> Value) then
  begin
    FLight := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetDarkShadow(Value: TColor);
begin
  if (FDarkShadow <> Value) then
  begin
    FDarkShadow := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetHighlight(Value: TColor);
begin
  if (FHighlight <> Value) then
  begin
    FHighlight := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TzSideBarColors.SetUseDefault(Value: Boolean);
begin
  if (FUseDefault <> Value) then
  begin
    FUseDefault := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

{ TzSideBarButtonActionLink }

procedure TzSideBarButtonActionLink.AssignClient(AClient: TObject);
begin
  FClient := AClient as TzSideBarButton;
end;

function TzSideBarButton.GetActionLinkClass: TzSideBarButtonActionLinkClass;
begin
  Result := TzSideBarButtonActionLink;
end;

function TzSideBarButtonActionLink.IsCaptionLinked: Boolean;
begin
  Result := inherited IsCaptionLinked and
    (FClient.Caption = (Action as TCustomAction).Caption);
end;

function TzSideBarButtonActionLink.IsEnabledLinked: Boolean;
begin
  Result := inherited IsEnabledLinked and
    (FClient.Enabled = (Action as TCustomAction).Enabled);
end;

function TzSideBarButtonActionLink.IsImageIndexLinked: Boolean;
begin
  Result := inherited IsImageIndexLinked; //and (FClient.ImageIndex = (Action as TCustomAction).ImageIndex);
end;

function TzSideBarButtonActionLink.IsOnExecuteLinked: Boolean;
begin
  Result := inherited IsOnExecuteLinked and
    (@FClient.OnClick = @Action.OnExecute);
end;

function TzSideBarButtonActionLink.IsVisibleLinked: Boolean;
begin
  Result := inherited IsVisibleLinked and
    (FClient.Visible = (Action as TCustomAction).Visible);
end;

procedure TzSideBarButtonActionLink.SetCaption(const Value: string);
begin
  if IsCaptionLinked then
    FClient.Caption := Value;
end;

procedure TzSideBarButtonActionLink.SetEnabled(Value: Boolean);
begin
  if IsEnabledLinked then
    FClient.Enabled := Value;
end;

procedure TzSideBarButtonActionLink.SetImageIndex(Value: Integer);
begin
  inherited;
  if IsImageIndexLinked then
    FClient.ImageIndex := Value;
end;

procedure TzSideBarButtonActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  if IsOnExecuteLinked then
    FClient.OnClick := Value;
end;

procedure TzSideBarButtonActionLink.SetVisible(Value: Boolean);
begin
  if IsVisibleLinked then
    FClient.Visible := Value;
end;

function TzSideBarButton.IsCaptionStored: Boolean;
begin
  Result := (ActionLink = nil) or not ActionLink.IsCaptionLinked;
end;

function TzSideBarButton.IsEnabledStored: Boolean;
begin
  Result := (ActionLink = nil) or not ActionLink.IsEnabledLinked;
end;
{
function TzSideBarButton.IsHintStored: Boolean;
begin
  Result := (ActionLink = nil) or not ActionLink.IsHintLinked;
end;

function TzSideBarButton.IsHelpContextStored: Boolean;
begin
  Result := (ActionLink = nil) or not ActionLink.IsHelpContextLinked;
end;
}

function TzSideBarButton.IsVisibleStored: Boolean;
begin
  Result := (ActionLink = nil) or not ActionLink.IsVisibleLinked;
end;

function TzSideBarButton.IsOnClickStored: Boolean;
begin
  Result := (ActionLink = nil) or not ActionLink.IsOnExecuteLinked;
end;

{ TzSideBarPanelActionLink }

procedure TzSideBarPanelActionLink.AssignClient(AClient: TObject);
begin
  FClient := AClient as TzSideBarPanel;
end;

function TzSideBarPanel.GetActionLinkClass: TzSideBarPanelActionLinkClass;
begin
  Result := TzSideBarPanelActionLink;
end;

function TzSideBarPanelActionLink.IsCaptionLinked: Boolean;
begin
  Result := inherited IsCaptionLinked and
    (FClient.Caption = (Action as TCustomAction).Caption);
end;

function TzSideBarPanelActionLink.IsOnExecuteLinked: Boolean;
begin
  Result := inherited IsOnExecuteLinked and
    (@FClient.OnClick = @Action.OnExecute);
end;

procedure TzSideBarPanelActionLink.SetCaption(const Value: string);
begin
  if IsCaptionLinked then
    FClient.Caption := Value;
end;

procedure TzSideBarPanelActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  if IsOnExecuteLinked then
    FClient.OnClick := Value;
end;

{ TzSideBarPanel }

constructor TzSideBarPanel.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDeleting := False;
  FButtons := TzSideBarButtons.Create(Self);
end;

destructor TzSideBarPanel.Destroy;
begin
  FDeleting := True;
  Data := nil;
  FButtons.Free;
  inherited;
end;

procedure TzSideBarPanel.Assign(Source: TPersistent);
begin
  if (Source is TzSideBarPanel) then
  begin
    Caption := TzSideBarPanel(Source).Caption;
    Data := TzSideBarPanel(Source).Data;
    Tag := TzSideBarPanel(Source).Tag;
  end
  else
    inherited Assign(Source);
end;

function TzSideBarPanel.GetDisplayName: string;
begin
  Result := Caption;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TzSideBarPanel.SetData(const Value: Pointer);
begin
  if not FDeleting and (Value <> Data) then
  begin
    FData := Value;
    Changed(False);
  end;
end;

procedure TzSideBarPanel.SetCaption(const Value: TCaption);
begin
  if (FCaption <> Value) then
  begin
    FCaption := Value;
    Changed(False);
  end;
end;

procedure TzSideBarPanel.SetButtons(const Value: TzSideBarButtons);
begin
  FButtons.Assign(Value);
end;

procedure TzSideBarPanel.SetOnClick(const Value: TNotifyEvent);
begin
  FOnClick := Value;
end;

procedure TzSideBarPanel.Click;
begin
  if Assigned(OnClick) then
    OnClick(Self);
end;

procedure TzSideBarPanel.SetSmallImages(const Value: boolean);
begin
  if (FSmallImages <> Value) then
  begin
    FSmallImages := Value;
    Changed(True);
  end;
end;

function TzSideBarPanel.GetAction: TBasicAction;
begin
  if ActionLink <> nil then
    Result := ActionLink.Action
  else
    Result := nil;
end;

procedure TzSideBarPanel.SetAction(Value: TBasicAction);
begin
  if (Value = nil) then
  begin
    if Assigned(ActionLink) then
    begin
      ActionLink.Free;
      ActionLink := nil;
      //      Exclude(FControlStyle, csActionClient);
    end;
  end
  else
    //    if Assigned(FourthShortcutBar) then
  begin
    //      Include(FControlStyle, csActionClient);
    if ActionLink = nil then
      ActionLink := GetActionLinkClass.Create(Self);
    ActionLink.Action := Value;
    ActionLink.OnChange := DoActionChange;
    ActionChange(Value, csLoading in Value.ComponentState);
    //      Value.FreeNotification(FourthShortcutBar);
  end;
end;

procedure TzSideBarPanel.DoActionChange(Sender: TObject);
begin
  if Sender = Action then
    ActionChange(Sender, False);
end;

procedure TzSideBarPanel.ActionChange(Sender: TObject; CheckDefaults: boolean);
begin
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if not CheckDefaults or (Self.Caption = '') then
        Self.Caption := Caption;
      if not CheckDefaults or not Assigned(Self.OnClick) then
        Self.OnClick := OnExecute;
    end;
end;

{ TzSideBarPanels }

constructor TzSideBarPanels.Create(FourthShortcutBar: TzSideBar);
begin
  inherited Create(TzSideBarPanel);
  FFourthShortcutBar := FourthShortcutBar;
end;

function TzSideBarPanels.Add: TzSideBarPanel;
begin
  Self.BeginUpdate;
  try
    Result := TzSideBarPanel(inherited Add);
    Result.FFourthShortcutBar := Self.FFourthShortcutBar;
  finally
    Self.EndUpdate;
  end;
end;

procedure TzSideBarPanels.Delete(Index: Integer);
begin
  Self.BeginUpdate;
  try
    inherited Delete(Index);
  finally
    Self.EndUpdate;
  end;
  if Index > 0 then
    FFourthShortcutBar.SetPanelIndex(Index - 1);
  if (Index = 0) and (Count = 0) then
    FFourthShortcutBar.SetPanelIndex(-1);
  if (Index = 0) and (Count <> 0) then
    FFourthShortcutBar.SetPanelIndex(Index);
end;

function TzSideBarPanels.GetItem(Index: Integer): TzSideBarPanel;
begin
  Result := TzSideBarPanel(inherited GetItem(Index));
end;

function TzSideBarPanels.GetOwner: TPersistent;
begin
  Result := FFourthShortcutBar;
end;

procedure TzSideBarPanels.SetItem(Index: Integer; Value: TzSideBarPanel);
begin
  Self.BeginUpdate;
  try
    inherited SetItem(Index, Value);
  finally
    Self.EndUpdate;
  end;
end;

procedure TzSideBarPanels.Update(Item: TCollectionItem);
begin
  if Item <> nil then
    FFourthShortcutBar.UpdatePanelHeader(Item.Index, sbbsDefault)
  else
    FFourthShortcutBar.UpdatePanels;
end;

{ TzSideBar }

constructor TzSideBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents {, csDoubleClicks}, csOpaque];
  Canvas.Font := Screen.IconFont;
  Width := 100;
  Align := alLeft;
  FTabHeight := 22;
  FPanelCursor := crDefault;
  FPanels := TzSideBarPanels.Create(Self);
  FColors := TzSideBarColors.Create;
  FColors.OnChange := ColorsChange;
  ParentFont := True;
  FMoveButton := -1;
  FMoveTab := -1;
  FUseSystemFont := True;
end;

destructor TzSideBar.Destroy;
begin
  FPanels.Free;
  FColors.Free;
  inherited Destroy;
end;

procedure TzSideBar.CreateWnd;
begin
  inherited CreateWnd;
  UpdatePanels;
end;

procedure TzSideBar.SetPanelCursor(Value: TCursor);
begin
  if (FPanelCursor <> Value) then
  begin
    FPanelCursor := Value;
  end;
end;

procedure TzSideBar.SetPanels(Value: TzSideBarPanels);
begin
  FPanels.Assign(Value);
end;

{ Отрисовка панелей }

procedure TzSideBar.UpdatePanelHeader(Index: Integer;
  State: TzSideBarButtonState);
var
  S: string;
  R: TRect;
begin
  if HandleAllocated then
  begin
    with Panels[Index] do
    begin
      S := Caption;
      R := FDisplayRect;
      Canvas.Brush.Color := FColors.FFace;
      Canvas.FillRect(R);
      Canvas.Brush.Style := bsClear;

      if FStyle = sbs2000 then
      begin
        case State of
          sbbsPressed:
            begin
              Frame3D(Canvas, R, FColors.FDarkShadow, FColors.FHighlight, 1);
              Frame3D(Canvas, R, FColors.FShadow, FColors.FLight, 1);
            end;
          sbbsDefault:
            begin
              if FPanelIndex = Index then
              begin
                Frame3D(Canvas, R, FColors.FHighlight, FColors.FDarkShadow, 1);
                Inc(R.Right);
                Dec(R.Left);
                Dec(R.Top);
                Frame3D(Canvas, R, FColors.FHighlight, FColors.FShadow, 1);
                Dec(R.Right);
                Inc(R.Left);
                Inc(R.Top);
              end
              else
              begin
                Frame3D(Canvas, R, FColors.FHighlight, FColors.FShadow, 1);
                Inc(R.Right);
                Dec(R.Left);
                Dec(R.Top);
                Frame3D(Canvas, R, FColors.FHighlight, FColors.FShadow, 1);
                Dec(R.Right);
                Inc(R.Left);
                Inc(R.Top);
              end;
            end;
          sbbsHot:
            begin
              Frame3D(Canvas, R, FColors.FHighlight, FColors.FDarkShadow, 1);
              Frame3D(Canvas, R, FColors.FLight, FColors.FShadow, 1);
            end;
        end;
      end;

      if FStyle = sbs2002 then
      begin
        case State of
          sbbsPressed:
            begin
              Frame3D(Canvas, R, FColors.FDarkShadow, FColors.FHighlight, 1);
              Frame3D(Canvas, R, FColors.FShadow, FColors.FLight, 1);
            end;
          sbbsDefault:
            begin
              if FPanelIndex = Index then
                Frame3D(Canvas, R, clBtnHighlight, clBtnShadow, 1)
              else
                Frame3D(Canvas, R, clBtnHighlight, clBtnShadow, 1);
            end;
          sbbsHot:
            begin
              Frame3D(Canvas, R, FColors.FHighlight, FColors.FDarkShadow, 1);
              Frame3D(Canvas, R, FColors.FLight, FColors.FShadow, 1);
            end;
        end;
      end;

      Dec(R.Right, 3);
      Inc(R.Left, 3);

      if FUseSystemFont then
        Canvas.Font.Color := Screen.IconFont.Color
      else
        Canvas.Font.Color := Font.Color;
      if Length(S) <> 0 then
        DrawText(Canvas.Handle, @S[1], -1, R, DT_SINGLELINE or DT_CENTER or
          DT_VCENTER or DT_END_ELLIPSIS);
    end;
  end;
end;

procedure TzSideBar.UpdateButton(aPanel, aButton: Integer;
  State: TzSideBarButtonState);
var
  R, btnR: TRect;
  fsbButton: TzSideBarButton;
  img, h, w, dx, dy: Integer;
  s: string;
  small: Boolean;
begin
  if Panels.Count = 0 then
    Exit;
  if Panels[aPanel].Buttons.Count = 0 then
    Exit;
  fsbButton := Panels[aPanel].Buttons[aButton];
  R := fsbButton.FDisplayRect;
  btnR := fsbButton.FButtonRect;
  small := Panels[aPanel].SmallImages;
  img := fsbButton.ImageIndex;

  if (FStyle = sbs2000) then { Outlook 2000 }
  begin
    case State of
      sbbsPressed:
        if Panels[aPanel].Buttons[aButton].Enabled then
          Frame3D(Canvas, btnR, FColors.FDarkShadow, FColors.FFace, 1);
      sbbsHot:
        if Panels[aPanel].Buttons[aButton].Enabled then
          Frame3D(Canvas, btnR, FColors.FFace, FColors.FDarkShadow, 1);
      sbbsDefault:
        Frame3D(Canvas, btnR, FColors.FBG, FColors.FBG, 1);
    end;
    if Panels[aPanel].Buttons[aButton].Enabled then
      Canvas.Font.Color := FColors.FBtnText
    else
      Canvas.Font.Color := FColors.FBtnTextDisabled;
  end;

  if (FStyle = sbs2002) then { Outlook XP }
  begin
    case State of
      sbbsPressed:
        begin
          if Panels[aPanel].Buttons[aButton].Enabled then
          begin
            Canvas.Brush.Color := GetXPPressedHighlight;
            Canvas.FillRect(btnR);
            Frame3D(Canvas, btnR, clHighlight, clHighlight, 1);
          end;
        end;
      sbbsHot:
        begin
          if Panels[aPanel].Buttons[aButton].Enabled then
          begin
            Canvas.Brush.Color := GetXPHotHighlight;
            Canvas.FillRect(btnR);
            Frame3D(Canvas, btnR, clHighlight, clHighlight, 1);
          end;
        end;
      sbbsDefault:
        begin
          Canvas.Brush.Color := Get2002Bg(FColors.Background);
          Canvas.FillRect(btnR);
          Frame3D(Canvas, btnR, Get2002Bg(FColors.Background), Get2002Bg(FColors.Background), 1);
        end;
    end;
    Canvas.Brush.Color := Get2002Bg(FColors.Background);
    if Panels[aPanel].Buttons[aButton].Enabled then
    begin
      if FUseSystemFont then
        Canvas.Font.Color := Screen.IconFont.Color
      else
        Canvas.Font.Color := FColors.FBtnText;
    end
    else
      Canvas.Font.Color := FColors.FBtnTextDisabled;
  end; // end XP

  if Small then
  begin
    W := 16;
    H := 16;
    if Assigned(FSmallImages) then
    begin
      W := FSmallImages.Width;
      H := FSmallImages.height;
    end;
  end
  else
  begin
    W := 32;
    H := 32;
    if Assigned(FImages) then
    begin
      W := FImages.Width;
      H := FImages.Height;
    end;
  end;

  dx := (btnR.Right - BtnR.Left - W) div 2;
  dy := (btnR.Bottom - BtnR.Top - H) div 2;

  if Small then
    FSmallImages.Draw(Canvas, btnR.Left + dx, btnR.Top + dy, img)
  else
    FImages.Draw(Canvas, btnR.Left + dx, btnR.Top + dy, img);

  S := fsbButton.Caption;

  if Small then
  begin
    R.Left := btnR.Right + 4;
    DrawText(Canvas.Handle, @S[1], -1, R, DT_SINGLELINE or DT_LEFT or DT_END_ELLIPSIS);
  end
  else
  begin
    R.Top := btnR.Bottom + 2;
    DrawText(Canvas.Handle, @S[1], -1, R, DT_WORDBREAK or DT_CENTER or DT_TOP or DT_END_ELLIPSIS);
  end;
end;

// drawing of scroll buttons

procedure TzSideBar.DrawRaised(R: TRect);
begin
  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := FColors.FFace;
    FillRect(R);
    Frame3D(Canvas, R, FColors.FLight, FColors.FDarkShadow, 1);
    Frame3D(Canvas, R, FColors.FHighlight, FColors.FShadow, 1);
    Brush.Style := bsClear;
  end;
end;

procedure TzSideBar.DrawSunken(R: TRect);
begin
  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := FColors.FFace;
    FillRect(R);
    Pen.Color := FColors.FDarkShadow;
    MoveTo(R.Right - 1, R.top);
    LineTo(R.left, R.top);
    lineto(R.left, R.bottom - 1);
    pen.color := FColors.FLight;
    moveto(R.left, R.bottom);
    lineto(R.right, R.bottom);
    lineto(R.right, R.top);
    pen.color := FColors.FShadow;
    moveto(R.right - 2, R.top + 1);
    lineto(R.left + 1, R.top + 1);
    lineto(R.left + 1, R.bottom - 2);
    pen.color := FColors.FFace;
    moveto(R.left + 1, R.bottom - 1);
    lineto(R.right - 1, R.bottom - 1);
    lineto(R.right - 1, R.top + 1);
    brush.style := bsclear;
  end;
end;

procedure TzSideBar.DrawUpArrow(R: TRect);
begin
  with Canvas do
  begin
    Pen.Color := FColors.FDarkShadow;
    moveto(R.left + 5, R.top + 11);
    Lineto(R.left + 13, R.top + 11);
    moveto(R.left + 6, R.top + 10);
    Lineto(R.left + 12, R.top + 10);
    moveto(R.left + 7, R.top + 9);
    Lineto(R.left + 11, R.top + 9);
    moveto(R.left + 8, R.top + 8);
    Lineto(R.left + 10, R.top + 8);
    moveto(R.left + 9, R.top + 7);
    Lineto(R.left + 9, R.top + 7);
  end;
end;

procedure TzSideBar.DrawDownArrow(R: TRect);
begin
  with Canvas do
  begin
    Pen.Color := FColors.FDarkShadow;
    moveto(R.left + 5, R.top + 8);
    Lineto(R.left + 13, R.top + 8);
    moveto(R.left + 6, R.top + 9);
    Lineto(R.left + 12, R.top + 9);
    moveto(R.left + 7, R.top + 10);
    Lineto(R.left + 11, R.top + 10);
    moveto(R.left + 8, R.top + 11);
    Lineto(R.left + 10, R.top + 11);
    moveto(R.left + 9, R.top + 12);
    Lineto(R.left + 9, R.top + 12);
  end;
end;

procedure TzSideBar.DrawUpRaised;
begin
  DrawRaised(FUpR);
  DrawUpArrow(FUpR);
end;

procedure TzSideBar.DrawUpSunken;
begin
  DrawSunken(FUpR);
  DrawUpArrow(FUpR);
end;

procedure TzSideBar.DrawDownRaised;
begin
  DrawRaised(FDownR);
  DrawDownArrow(FDownR);
end;

procedure TzSideBar.DrawDownSunken;
begin
  DrawSunken(FDownR);
  DrawDownArrow(FDownR);
end;

procedure TzSideBar.UpdatePanel(First: Boolean; Index: Integer);
var
  I, Count, ButtonPos, W, H, dx: Integer;
  R, btnR: TRect;
  Small: Boolean;
  ZoneHeight: Integer;
  ZoneR: TRect;
begin
  R := FPanelRect;
  if FStyle = sbs2000 then
    Canvas.Brush.Color := FColors.FBG;
  if FStyle = sbs2002 then
    Canvas.Brush.Color := Get2002Bg(FColors.Background);
  Canvas.FillRect(FPanelRect);

  FUpR := Rect(R.Right - 25, R.Top + 5, R.Right - 6, R.Top + 24);
  FUpActive := False;

  FDownR := Rect(R.Right - 25, R.Bottom - 25, R.Right - 6, R.Bottom - 6);
  FDownActive := False;

  Small := Panels[Index].SmallImages;
  if Panels[Index].Buttons = nil then
    Exit; // JH 30-jun-2001
  Count := Panels[Index].Buttons.Count;
  if Count = 0 then
    Exit;
  ButtonPos := FPanelRect.Top + 2;
  if Small then
  begin
    if Assigned(FSmallImages) then
    begin
      H := FSmallImages.Height + 2;
      W := FSmallImages.Width + 2;
      ZoneHeight := H + 7;
      ZoneR := Rect(R.Left + 2, ButtonPos, R.Right - 2, ButtonPos + ZoneHeight - 1);
      btnR := Rect(ZoneR.Left + 2, ZoneR.Top + 2, ZoneR.Left + 4 + W, ZoneR.Top + 4 + H);
    end
    else
      Exit; // only display buttons when images assigned
  end
  else
    { if Large Images }
  begin
    if Assigned(FImages) then
    begin
      H := FImages.Height + 4;
      W := FImages.Width + 2;
      ZoneHeight := H + Canvas.TextHeight('hq') + 21;
      ZoneR := Rect(R.Left + 2, ButtonPos, R.Right - 2, ButtonPos + ZoneHeight - 1);
      dx := (R.Right - R.Left - 4 - W) div 2;
      btnR := Rect(ZoneR.left + dx, ZoneR.Top + 4, ZoneR.Left + dx + 4 + W, ZoneR.Top + 6 + H);
    end
    else
      Exit; // only display buttons when images assigned
  end;
  if First then
    FScrollTop := 0;
  FScrollBottom := FScrollTop + ((FPanelRect.Bottom - FPanelRect.Top + 1) div ZoneHeight) - 1;
  if FScrollBottom > (Count - 1) then
    FScrollBottom := Count - 1;
  // set button rects
  if Panels[Index].Buttons.Count > FScrollBottom then
    for I := FScrollTop to FScrollBottom do
    begin
      Panels[Index].Buttons[I].FDisplayRect := ZoneR;
      Panels[Index].Buttons[I].FButtonRect := btnR;
      // next zone
      Inc(ZoneR.Top, ZoneHeight);
      Inc(ZoneR.Bottom, ZoneHeight);
      Inc(btnR.Top, ZoneHeight);
      Inc(btnR.Bottom, Zoneheight);
    end;
  // display buttons
  if Panels[Index].Buttons.Count > FScrollBottom then
    for I := FScrollTop to FScrollBottom do
      UpdateButton(Index, I, sbbsDefault);
  // check display of scroll buttons
//  timed:= assigned(FScrollTimer) and (FScrollTimer.enabled);

  if (FScrollTop > 0) then
  begin
    FUpActive := True;
    if FUpIsDown then
      DrawUpSunken
    else
      DrawUpRaised;
  end
  else
    FUpActive := False;

  if FScrollBottom < (Count - 1) then
  begin
    FDownActive := True;
    if FDownIsDown then
      DrawDownSunken
    else
      DrawDownRaised;
  end
  else
    FDownActive := False;
end;

procedure TzSideBar.UpdatePanels;
const
  MaxPanelCount = 128;
var
  I, Count, PanelPos, ot: Integer;
  R: TRect;
begin
  if HandleAllocated then
  begin
    R := ClientRect;
    if FUseSystemFont then
      Canvas.Font := Screen.IconFont
    else
      Canvas.Font := Self.Font;
    if FStyle = sbs2000 then
      Canvas.Brush.Color := FColors.FBG;
    if FStyle = sbs2002 then
      Canvas.Brush.Color := Get2002Bg(FColors.Background);
    Canvas.FillRect(R);
    if FStyle = sbs2000 then
    begin
      Frame3D(Canvas, R, FColors.FShadow, FColors.FHighlight, 1);
      Frame3D(Canvas, R, FColors.FDarkShadow, FColors.FShadow, 1);
    end
    else
    begin
      Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
    end;
    Count := Panels.Count;

    if Count > MaxPanelCount then
      Count := MaxPanelCount;
    if Count = 0 then
    begin
      //
    end
    else
    begin
      FPanelHeight := Height - 2 - (Count * FTabHeight);
      PanelPos := 1;
      for I := 0 to Count - 1 do
      begin
        Panels[I].FDisplayRect := Rect(1, PanelPos, Width - 1, PanelPos + FTabHeight);
        Inc(PanelPos, FTabHeight);
        if I = PanelIndex then
          Inc(PanelPos, FPanelHeight);
      end;
    end;

    if (Count > 0) then
    begin
      for I := 0 to (Count - 1) do
      begin
        UpdatePanelHeader(I, sbbsDefault);
        if (I = PanelIndex) then
        begin
          ot := Panels[I].FDisplayRect.Bottom + 1;
          FPanelRect := Rect(2, ot, Width - 3, ot + FPanelHeight - 2);
          UpdatePanel(True, I);
        end;
      end;
    end;

  end;
end;

procedure TzSideBar.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdatePanels;
  Invalidate;
end;

procedure TzSideBar.WMPaint(var Message: TWMPaint);
begin
  inherited;
  UpdatePanels;
end;

procedure TzSideBar.WMSize(var Message: TWMSize);
begin
  { Eat WM_SIZE message to prevent control from doing alignment }
  if not (csLoading in ComponentState) then
    Resize;
  UpdatePanels;
end;

procedure TzSideBar.CMDesignHitTest(var Msg: TCMDesignHitTest);
const
  CTL_CLICK = 1;
begin
  inherited;
  if (Msg.Keys = CTL_CLICK) then
    ClickAtPos(Point(Msg.Pos.x, Msg.Pos.y));
end;

procedure TzSideBar.ClickAtPos(APoint: TPoint);
var
  Index: Integer;
begin
  Index := GetPanelAtPos(APoint);
  if (Index <> -1) then
    PanelIndex := Index;
end;

function TzSideBar.GetPanelAtPos(APoint: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Panels.Count = 0 then
    Exit;
  for I := 0 to FPanels.Count - 1 do
  begin
    if PtInRect(FPanels[I].FDisplayRect, APoint) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TzSideBar.SetPanelIndex(const Value: Integer);
begin
  if Panels.Count = 0 then
    Exit;
  FMoveButton := -1;
  FMoveTab := -1;
  if (FPanelIndex <> Value) then
  begin
    FPanelIndex := Value;
    UpdatePanels;
  end;
end;

procedure TzSideBar.SetTabHeight(const Value: Integer);
begin
  if FTabHeight <> Value then
  begin
    FTabHeight := Value;
    UpdatePanels;
  end;
end;

function TzSideBar.GetButtonArea(Pt: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Panels.Count = 0 then
    Exit;
  if PanelIndex = -1 then
    Exit;
  if Panels[PanelIndex].Buttons.Count = 0 then
    Exit;
  for I := FScrollTop to FScrollBottom do
  begin
    try
      if PtInRect(FPanels[PanelIndex].Buttons[I].FDisplayRect, Pt) then
      begin
        Result := I;
        Exit;
      end;
    except
      Beep;
      Continue;
    end;
  end;
end;

function TzSideBar.GetButtonAtPos(pt: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Panels.Count = 0 then
    Exit;
  if PanelIndex = -1 then
    Exit;
  if Panels[PanelIndex].Buttons.Count = 0 then
    Exit;
  for I := FScrollTop to FScrollBottom do
  begin
    if ptInRect(Panels[PanelIndex].Buttons[I].FButtonRect, pt) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TzSideBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
  I: Integer;
begin
  Cursor := Self.Cursor;

  if Panels.Count = 0 then
    Exit;

  Idx := GetPanelAtPos(Point(X, Y));
  FSelectedButton := GetButtonAtPos(Point(X, Y));

  if (Idx <> -1) then
    Cursor := FPanelCursor
  else
    Cursor := Self.Cursor;

  if (not (ssLeft in Shift)) and (Idx <> FMoveTab) and
    (Panels.Count <> 0) then
  begin
    for I := 0 to Pred(Panels.Count) do
    begin
      if I <> Idx then
        UpdatePanelHeader(I, sbbsDefault)
      else
        UpdatePanelHeader(I, sbbsHot);
    end;
    FMoveTab := Idx;
  end;

  if not (ssLeft in Shift) then
  begin
    if (PanelIndex <> -1) and (Panels[PanelIndex].Buttons.Count > 0) then
    begin
      Idx := GetButtonArea(Point(X, Y));
      if (Idx <> FMoveButton) then
      begin
        for I := FScrollTop to FScrollBottom do
          if (I <> Idx) then
            UpdateButton(PanelIndex, I, sbbsDefault)
          else
            UpdateButton(PanelIndex, Idx, sbbsHot);
        FMoveButton := Idx;
      end;
    end;
  end; { if not (ssLeft in Shift) ... }
end;

procedure TzSideBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Idx: Integer;
begin
  if Panels.Count = 0 then
    Exit;

  FDownTab := -1;
  FDownButton := -1;

  if (FUpActive = True) then // check if upscroll is pressed
  begin
    if (PtInRect(FUpR, Point(X, Y)) = True) then
    begin
      FUpIsDown := True;
      DrawUpSunken;
      FScrollTimer := TTimer.Create(Self);
      FScrollTimer.Interval := 200;
      FScrollTimer.OnTimer := TimedScroll;
      FScrollTimer.Enabled := True;
      Exit;
    end;
  end;

  if (FDownActive = True) then // check if downscroll is pressed
  begin
    if PtInRect(FDownR, Point(X, Y)) then
    begin
      FDownIsDown := True;
      DrawDownSunken;
      FScrollTimer := TTimer.Create(self);
      FScrollTimer.Interval := 200;
      FScrollTimer.OnTimer := TimedScroll;
      FScrollTimer.Enabled := True;
      Exit;
    end;
  end;

  Idx := GetPanelAtPos(Point(X, Y));

  if (Idx <> -1) then
  begin
    FDownTab := Idx;
    FMoveButton := -1;
    UpdatePanelHeader(FDownTab, sbbsPressed);
  end
  else
  begin
    Idx := GetButtonAtPos(Point(X, Y));
    if (Idx <> -1) then
    begin
      FDownButton := Idx;
      UpdateButton(PanelIndex, FDownButton, sbbsPressed);
      FSelectedButton := Idx;
    end;
  end;
end;

procedure TzSideBar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Idx: Integer;
begin
  if Panels.Count = 0 then
    Exit;

  if (FUpIsDown = True) then
  begin
    if Assigned(FScrollTimer) then
      FScrollTimer.Free;
    FUpIsDown := False;
    //    DrawUpRaised;
    if FUpActive then
    begin
      Inc(FScrollTop, -1);
      UpdatePanel(False, PanelIndex);
      Exit;
    end;
  end;

  if (FDownIsDown = True) then
  begin
    if Assigned(FScrollTimer) then
      FScrollTimer.Free;
    FDownIsDown := False;
    //    DrawDownRaised;
    if FDownActive then
    begin
      Inc(FScrollTop, 1);
      UpdatePanel(False, PanelIndex);
      Exit;
    end;
  end;

  if (FDownTab <> -1) then
  begin
    UpdatePanelHeader(FDownTab, sbbsDefault);
    Idx := FDownTab;
    FDownTab := -1;
    PanelIndex := Idx;
    Panels[PanelIndex].Click;
  end
  else
    if (FDownButton <> -1) then
    begin
      UpdateButton(PanelIndex, FDownButton, sbbsDefault);
      Idx := FDownButton;
      FDownButton := -1;
      Panels[PanelIndex].Buttons[Idx].Click;
    end;

  Idx := GetButtonAtPos(Point(X, Y));
  if (Idx <> -1) then
  begin
    FDownButton := Idx;
    UpdateButton(PanelIndex, FDownButton, sbbsHot);
  end;
end;

procedure TzSideBar.SetImages(const Value: TImagelist);
begin
  FImages := Value;
end;

procedure TzSideBar.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FImages) then
    SetImages(nil);
  if (Operation = opRemove) and (AComponent = FSmallImages) then
    SetSmallImages(nil);
end;

procedure TzSideBar.SetSmallImages(const Value: TImageList);
begin
  FSmallImages := Value;
end;

procedure TzSideBar.TimedScroll(Sender: TObject);
begin
  if FUpIsDown then
  begin
    if FUpActive then
    begin
      Inc(FScrollTop, -1);
      UpdatePanel(False, PanelIndex);
    end;
    if not FUpActive then
      if Assigned(FScrollTimer) then
        FScrollTimer.Enabled := False;
  end
  else
    if FDownIsDown then
    begin
      if FDownActive then
      begin
        Inc(FScrollTop, 1);
        UpdatePanel(False, PanelIndex);
      end;
      if not FDownActive then
        if Assigned(FScrollTimer) then
          FScrollTimer.Enabled := False;
    end
    else
      if Assigned(FScrollTimer) then
        FScrollTimer.Enabled := False;
end;

procedure TzSideBar.ColorsChange(Sender: TObject);
begin
  if FColors.UseDefault = True then
    ApplyStandardColors;
  Invalidate;
end;

{ TzSideBarButton }

constructor TzSideBarButton.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDeleting := False;
  FImageIndex := -1;
  FEnabled := True;
  //  FVisible := True;
end;

destructor TzSideBarButton.Destroy;
begin
  if Assigned(ActionLink) then
  begin
    FActionLink.Free;
    FActionLink := nil;
  end;
  FDeleting := True;
  Data := nil;
  inherited;
end;

procedure TzSideBarButton.Assign(Source: TPersistent);
begin
  if (Source is TzSideBarButton) then
  begin
    Action := TzSideBarButton(Source).Action;
    Caption := TzSideBarButton(Source).Caption;
    Data := TzSideBarButton(Source).Data;
    Enabled := TzSideBarButton(Source).Enabled;
    ImageIndex := TzSideBarButton(Source).ImageIndex;
    Tag := TzSideBarButton(Source).Tag;
    Visible := TzSideBarButton(Source).Visible;
    OnClick := TzSideBarButton(Source).OnClick;
  end
  else
    inherited Assign(Source);
end;

procedure TzSideBarButton.Click;
begin
  if Assigned(FOnClick) and (Action <> nil) and (@FOnClick <> @Action.OnExecute) then
    FOnClick(Self)
  else
    if {not (csDesigning in ComponentState) and }(ActionLink <> nil) and (ActionLink.IsEnabledLinked) then
      ActionLink.Execute
    else
      if Assigned(FOnClick) then
        FOnClick(Self);
end;

function TzSideBarButton.GetDisplayName: string;
begin
  Result := Caption;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TzSideBarButton.SetImageIndex(Value: Integer);
begin
  if (FImageIndex <> Value) then
  begin
    FImageIndex := Value;
    Changed(False)
  end;
end;

procedure TzSideBarButton.SetOnClick(const Value: TNotifyEvent);
begin
  FOnClick := Value;
end;

procedure TzSideBarButton.SetData(const Value: Pointer);
begin
  if not FDeleting and (Value <> Data) then
  begin
    FData := Value;
    Changed(False);
  end;
end;

procedure TzSideBarButton.SetCaption(const Value: TCaption);
begin
  if (FCaption <> Value) then
  begin
    FCaption := Value;
    Changed(False);
  end;
end;

procedure TzSideBarButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Assigned(Action) and (Operation = opRemove) and (Action = AComponent) then
    Action := nil;
end;

function TzSideBarButton.GetAction: TBasicAction;
begin
  if ActionLink <> nil then
    Result := ActionLink.Action
  else
    Result := nil;
end;

procedure TzSideBarButton.SetAction(Value: TBasicAction);
begin
  if (Value = nil) then
  begin
    if Assigned(ActionLink) then
    begin
      ActionLink.Free;
      ActionLink := nil;
    end;
  end
  else
    //    if Assigned(FourthShortcutBar) then
  begin
    if ActionLink = nil then
      ActionLink := GetActionLinkClass.Create(Self);
    ActionLink.Action := Value;
    ActionLink.OnChange := DoActionChange;
    ActionChange(Value, csLoading in Value.ComponentState);
    //      Value.FreeNotification(FourthShortcutBar);
  end;
end;

procedure TzSideBarButton.DoActionChange(Sender: TObject);
begin
  ActionChange(Sender, False);
end;

procedure TzSideBarButton.ActionChange(Sender: TObject; CheckDefaults: boolean);
begin
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if not CheckDefaults or (Self.Caption = '') then
        Self.Caption := TCustomAction(Sender).Caption;
      if not CheckDefaults or (Self.Enabled = True) then
        Self.Enabled := TCustomAction(Sender).Enabled;
      if not CheckDefaults or (Self.Visible = True) then
        Self.Visible := TCustomAction(Sender).Visible;
      if not CheckDefaults or not Assigned(Self.OnClick) then
        Self.OnClick := TCustomAction(Sender).OnExecute;
      if not CheckDefaults or (Self.ImageIndex = -1) then
        Self.ImageIndex := TCustomAction(Sender).ImageIndex;
    end;
end;

procedure TzSideBarButton.SetEnabled(Value: Boolean);
begin
  if (FEnabled <> Value) then
  begin
    FEnabled := Value;
    Changed(True);
  end;
end;
{
procedure TzSideBarButton.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(True);
  end;
end;
}
{ TzSideBarButtons }

function TzSideBarButtons.Add: TzSideBarButton;
begin
  Result := TzSideBarButton(inherited Add);
end;

procedure TzSideBarButtons.Delete(Index: Integer);
begin
  Self.BeginUpdate;
  try
    inherited Delete(Index);
  finally
    Self.EndUpdate;
  end;
  Self.FFourthShortcutBarPanel.FFourthShortcutBar.Invalidate;
  {
    if Index > 0 then
      FFourthShortcutBar.SetPanelIndex(Index-1);
    if (Index = 0) and (Count = 0) then
      FFourthShortcutBar.SetPanelIndex(-1);
    if (Index = 0) and (Count <> 0) then
      FFourthShortcutBar.SetPanelIndex(Index);
     }
end;

constructor TzSideBarButtons.Create(FourthShortcutBarPanel: TzSideBarPanel);
begin
  inherited Create(TzSideBarButton);
  FFourthShortcutBarPanel := FourthShortcutBarPanel;
end;

function TzSideBarButtons.GetItem(Index: Integer): TzSideBarButton;
begin
  Result := TzSideBarButton(inherited GetItem(Index));
end;

function TzSideBarButtons.GetOwner: TPersistent;
begin
  Result := FFourthShortcutBarPanel;
end;

procedure TzSideBarButtons.SetItem(Index: Integer; Value: TzSideBarButton);
begin
  inherited SetItem(Index, Value);
end;

procedure TzSideBarButtons.Update(Item: TCollectionItem);
begin
  if (Item <> nil) then
    FFourthShortcutBarPanel.Changed(False);
end;

procedure TzSideBarPanels.Assign(Source: TPersistent);
var
  I, B: Integer;
begin
  if (Source is TzSideBarPanels) then
  begin
    for I := 0 to Pred(TzSideBarPanels(Source).Count) do
    begin
      with Add do
      begin
        Caption := TzSideBarPanels(Source).Items[I].Caption;
        Data := TzSideBarPanels(Source).Items[I].Data;
        SmallImages := TzSideBarPanels(Source).Items[I].SmallImages;
        Tag := TzSideBarPanels(Source).Items[I].Tag;
        if TzSideBarPanels(Source).Items[I].Buttons.Count <> 0 then
        begin
          for B := 0 to Pred((Source as TzSideBarPanels).Items[I].Buttons.Count) do
          begin
            with (Source as TzSideBarPanels).Items[I].Buttons.Add do
            begin
              Action := (Source as TzSideBarPanels).Items[I].Buttons[B].Action;
              Caption := (Source as TzSideBarPanels).Items[I].Buttons[B].Caption;
              Data := (Source as TzSideBarPanels).Items[I].Buttons[B].Data;
              Enabled := (Source as TzSideBarPanels).Items[I].Buttons[B].Enabled;
              ImageIndex := (Source as TzSideBarPanels).Items[I].Buttons[B].ImageIndex;
              Tag := (Source as TzSideBarPanels).Items[I].Buttons[B].Tag;
              Visible := (Source as TzSideBarPanels).Items[I].Buttons[B].Visible;
            end;
          end;
        end;
      end;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzSideBar.Assign(Source: TPersistent);
begin
  if (Source is TzSideBar) then
  begin
    Top := (Source as TzSideBar).Top;
    Left := (Source as TzSideBar).Left;
    Height := (Source as TzSideBar).Height;
    Width := (Source as TzSideBar).Width;
    Align := (Source as TzSideBar).Align;
    Images.Assign((Source as TzSideBar).Images);
    SmallImages.Assign((Source as TzSideBar).SmallImages);
    Font.Assign((Source as TzSideBar).Font);
    FPanels.Assign((Source as TzSideBar).Panels);
    Tag := (Source as TzSideBar).Tag;
  end
  else
    inherited Assign(Source);
end;

procedure TzSideBar.SetStyle(Value: TzSideBarStyle);
begin
  if (FStyle <> Value) then
  begin
    FStyle := Value;
    ApplyStandardColors;
    Repaint;
  end;
end;

procedure TzSideBar.SetUseSystemFont(Value: Boolean);
begin
  if (FUseSystemFont <> Value) then
  begin
    FUseSystemFont := Value;
    Repaint;
  end;
end;

procedure TzSideBar.ApplyStandardColors;
begin
  case FStyle of
    sbs2000:
      begin
        with Self.Colors do
        begin
          Background := clBtnShadow;
          BtnFace := clBtnShadow;
          BtnLight := clBtnHighlight;
          BtnShadow := cl3DDkShadow;
          BtnText := clBtnHighlight;
          BtnTextDisabled := clBtnFace;
          Face := clBtnFace;
          Shadow := clBtnShadow;
          Light := cl3DLight;
          DarkShadow := cl3DDkShadow;
          Highlight := clBtnHighlight;
        end;
      end;
    sbs2002:
      begin
        with Self.Colors do
        begin
          Background := clBtnFace;
          BtnFace := clHighlight;
          BtnLight := clHighlight;
          BtnShadow := clHighlight;
          BtnText := clBtnHighlight;
          BtnTextDisabled := clGrayText;
          Face := clBtnFace;
          Shadow := clBtnShadow;
          Light := cl3DLight;
          DarkShadow := cl3DDkShadow;
          Highlight := clBtnHighlight;
        end;
      end;
  end;
end;

procedure TzSideBarButton.SetVisible(Value: Boolean);
begin
  //
end;

end.

