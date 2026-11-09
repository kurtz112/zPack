(*
  DBImageAspect, created Dec 8th, 1996 by Alexander Halser (halser@easycash.co.at)

  TzDbImage is a replace for TDBImage. It has the same properties and
  Events. The difference is, that the image will be displayed with its correct
  aspect ratio,

  when 'TzDbImage.Stretch := true' (it is by default).
  When 'Stretch := false', it behaves like a normal DBImage.

  NOTE:  The Image is only stretched until its original size, not beyond.
*)

unit zDbImage;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  DB,
  Clipbrd,
  dbctrls;

type
  TzDbImage = class(TCustomControl)
  private
    FDataLink: TFieldDataLink;
    FBorderStyle: TBorderStyle;
    FAutoDisplay: Boolean;
    FStretch: Boolean;
    FCenter: Boolean;
    FPictureLoaded: Boolean;
    FQuickDraw: Boolean;
    FPicture: TPicture;
    procedure DataChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    procedure PictureChanged(Sender: TObject);
    procedure SetAutoDisplay(Value: Boolean);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCenter(Value: Boolean);
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetPicture(Value: TPicture);
    procedure SetReadOnly(Value: Boolean);
    procedure SetStretch(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMCopy(var Message: TMessage); message WM_COPY;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetPalette: HPALETTE; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
  public
    property Field: TField read GetField;
    property Picture: TPicture read FPicture write SetPicture;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure LoadPicture;
    procedure PasteFromClipboard;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure ForceEditMode;
    function Test: String;
  published
    property Align;
    property Anchors;
    property AutoDisplay: Boolean read FAutoDisplay write SetAutoDisplay default True;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Center: Boolean read FCenter write SetCenter default false;
    property Color;
    property Constraints;
    property Ctl3D;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor default false;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default false;
    property QuickDraw: Boolean read FQuickDraw write FQuickDraw default True;
    property ShowHint;
    property Stretch: Boolean read FStretch write SetStretch default True;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

{ TDBImage }

constructor TzDbImage.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  ControlStyle := ControlStyle + [csOpaque, csReplicatable, csNeedsBorderPaint];
  if not NewStyleControls then
    ControlStyle := ControlStyle + [csFramed];
  Width := 105;
  Height := 105;
  TabStop := True;
  ParentColor := false;

  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;

  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FBorderStyle := bsSingle;
  FAutoDisplay := True;
  // FCenter := True;
  FStretch := True;
  FQuickDraw := True;
end;

destructor TzDbImage.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  FPicture.Free;
  inherited Destroy;
end;

function TzDbImage.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TzDbImage.SetDataSource(Value: TDataSource);
begin
  if not(FDataLink.DataSourceFixed or (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

function TzDbImage.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TzDbImage.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TzDbImage.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TzDbImage.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TzDbImage.GetField: TField;
begin
  Result := FDataLink.Field;
end;

function TzDbImage.GetPalette: HPALETTE;
begin
  Result := 0;
  if FPicture.Graphic is TBitmap then
    Result := TBitmap(FPicture.Graphic).Palette;
end;

procedure TzDbImage.SetAutoDisplay(Value: Boolean);
begin
  if FAutoDisplay <> Value then
  begin
    FAutoDisplay := Value;
    if Value then
      LoadPicture;
  end;
end;

procedure TzDbImage.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TzDbImage.SetCenter(Value: Boolean);
begin
  if FCenter <> Value then
  begin
    FCenter := Value;
    Invalidate;
  end;
end;

procedure TzDbImage.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TzDbImage.SetStretch(Value: Boolean);
begin
  if FStretch <> Value then
  begin
    FStretch := Value;
    Invalidate;
  end;
end;

procedure TzDbImage.Paint;
var
  W, H: Integer;
  X, Y: Integer;
  R, RAspect: TRect;
  S: string;
  DrawPict: TPicture;
  lWICImage: TWICImage;
begin
  with Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Color;
    if FPictureLoaded or (csPaintCopy in ControlState) then
    begin
      DrawPict := TPicture.Create;
      H := 0;
      try
        if (csPaintCopy in ControlState) and Assigned(FDataLink.Field) and (FDataLink.Field is TBlobField) then
        begin
          // inizio modifiche
          if (TBlobField(FDataLink.Field).BlobSize > 0) then
          begin { Assume image }
            lWICImage := TWICImage.Create;
            try
              lWICImage.Assign(FDataLink.Field);
              DrawPict.Assign(lWICImage);
            finally
              lWICImage.Free;
            end;
          end
          else
            DrawPict.Assign(nil); // \fine modifiche
          // Originale DrawPict.Assign(FDataLink.Field);

          if DrawPict.Graphic is TBitmap then
            DrawPict.Bitmap.IgnorePalette := QuickDraw; // !!
        end
        else
        begin
          DrawPict.Assign(Picture);
          if Focused and (DrawPict.Graphic is TBitmap) and (DrawPict.Bitmap.Palette <> 0) then
          begin
            { Control has focus, so realize the bitmap palette in foreground }
            H := SelectPalette(Handle, DrawPict.Bitmap.Palette, false);
            RealizePalette(Handle);
          end;
        end;
        if Stretch then
          if (DrawPict.Graphic = nil) or DrawPict.Graphic.Empty then
            FillRect(ClientRect)
          else
          begin
            X := DrawPict.Width;
            Y := DrawPict.Height;

            if X > Clientwidth then
            begin
              Y := round(Y * (Clientwidth / X));
              X := Clientwidth;
            end;
            if Y > Clientheight then
            begin
              X := round(X * (Clientheight / Y));
              Y := Clientheight;
            end;
            RAspect := ClientRect;
            RAspect.right := X;
            RAspect.bottom := Y;
            if Center then
              OffsetRect(RAspect, (Clientwidth - X) div 2, (Clientheight - Y) div 2);
            StretchDraw(RAspect, DrawPict.Graphic);
            ExcludeClipRect(Handle, RAspect.Left, RAspect.Top, RAspect.right, RAspect.bottom);
            FillRect(ClientRect);
            SelectClipRgn(Handle, 0);
          end
        else
        begin
          SetRect(R, 0, 0, DrawPict.Width, DrawPict.Height);
          if Center then
            OffsetRect(R, (Clientwidth - DrawPict.Width) div 2, (Clientheight - DrawPict.Height) div 2);
          StretchDraw(R, DrawPict.Graphic);
          ExcludeClipRect(Handle, R.Left, R.Top, R.right, R.bottom);
          FillRect(ClientRect);
          SelectClipRgn(Handle, 0);
        end;
      finally
        if H <> 0 then
          SelectPalette(Handle, H, True);
        DrawPict.Free;
      end;
    end
    else
    begin
      Font := Self.Font;
      if FDataLink.Field <> nil then
        S := FDataLink.Field.DisplayLabel
      else
        S := Name;
      S := '(' + S + ')';
      W := TextWidth(S);
      H := TextHeight(S);
      R := ClientRect;
      TextRect(R, (R.right - W) div 2, (R.bottom - H) div 2, S);
    end;
    if (GetParentForm(Self).ActiveControl = Self) and not(csDesigning in ComponentState) and not(csPaintCopy in ControlState) then
    begin
      Brush.Color := clWindowFrame;
      FrameRect(ClientRect);
    end;
  end;
end;

procedure TzDbImage.PictureChanged(Sender: TObject);
begin
  FDataLink.Modified;
  FPictureLoaded := True;
  Invalidate;
end;

procedure TzDbImage.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource) then
    DataSource := nil;
end;

procedure TzDbImage.LoadPicture;
var
  lWICImage: TWICImage;
begin
  // Originale
  // if not FPictureLoaded and (FDataLink.Field is TBlobField) then
  // Picture.Assign(FDataLink.Field);
  // \Originale

  if not FPictureLoaded then
    if (FDataLink.Field is TBlobField) then
    begin
      if (TBlobField(FDataLink.Field).BlobSize > 0) then
      begin { Assume image }
        lWICImage := TWICImage.Create;
        try
          lWICImage.Assign(FDataLink.Field);
          Picture.Assign(lWICImage);
        finally
          lWICImage.Free;
        end;
      end
      else { Empty }
      begin
        Picture.Assign(nil);
      end;
    end;
end;

procedure TzDbImage.DataChange(Sender: TObject);
begin
  Picture.Graphic := nil;
  FPictureLoaded := false;
  if FAutoDisplay then
    LoadPicture;
end;

procedure TzDbImage.UpdateData(Sender: TObject);
var
  BlobField: TBlobField;
  lWICImage: TWICImage;
begin
  // Originale
  // if FDataLink.Field is TBlobField then
  // begin
  // BlobField := TBlobField(FDataLink.Field);
  // if Picture.Graphic is TBitmap then
  // BlobField.Assign(Picture.Graphic)
  // else
  // BlobField.Clear;
  // end;
  // \Originale

  if FDataLink.Field is TBlobField then
  begin
    BlobField := TBlobField(FDataLink.Field);
    if Picture.Graphic is TBitmap then
    begin
      lWICImage := TWICImage.Create;
      try
        lWICImage.Assign(Picture.Graphic);
        BlobField.Assign(lWICImage);
      finally
        lWICImage.Free;
      end;
    end
    else
      BlobField.Clear;
  end;
end;

procedure TzDbImage.CopyToClipboard;
begin
  if Picture.Graphic <> nil then
    Clipboard.Assign(Picture);
end;

procedure TzDbImage.CutToClipboard;
begin
  if Picture.Graphic <> nil then
    if FDataLink.Edit then
    begin
      CopyToClipboard;
      Picture.Graphic := nil;
    end;
end;

procedure TzDbImage.PasteFromClipboard;
begin
  if Clipboard.HasFormat(CF_BITMAP) and FDataLink.Edit then
    Picture.Bitmap.Assign(Clipboard);
end;

procedure TzDbImage.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if FBorderStyle = bsSingle then
      if NewStyleControls and Ctl3D then
        ExStyle := ExStyle or WS_EX_CLIENTEDGE
      else
        Style := Style or WS_BORDER;
    WindowClass.Style := WindowClass.Style and not(CS_HREDRAW or CS_VREDRAW);
  end;

end;

procedure TzDbImage.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_INSERT:
      if ssShift in Shift then
        PasteFromClipboard
      else
        if ssCtrl in Shift then
          CopyToClipboard;
    VK_DELETE:
      if ssShift in Shift then
        CutToClipboard;
  end;
end;

procedure TzDbImage.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  case Key of
    ^X:
      CutToClipboard;
    ^C:
      CopyToClipboard;
    ^V:
      PasteFromClipboard;
    #13:
      LoadPicture;
    #27:
      FDataLink.Reset;
  end;
end;

procedure TzDbImage.CMEnter(var Message: TCMEnter);
begin
  Invalidate; { Draw the focus marker }
  inherited;
end;

procedure TzDbImage.CMExit(var Message: TCMExit);
begin
  Invalidate; { Erase the focus marker }
  inherited;
end;

procedure TzDbImage.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not FPictureLoaded then
    Invalidate;
end;

procedure TzDbImage.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if TabStop and CanFocus then
    SetFocus;
  inherited;
end;

procedure TzDbImage.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  LoadPicture;
  inherited;
end;

procedure TzDbImage.WMCut(var Message: TMessage);
begin
  CutToClipboard;
end;

procedure TzDbImage.WMCopy(var Message: TMessage);
begin
  CopyToClipboard;
end;

procedure TzDbImage.WMPaste(var Message: TMessage);
begin
  PasteFromClipboard;
end;

procedure TzDbImage.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

function TzDbImage.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (FDataLink <> nil) and FDataLink.UpdateAction(Action);
end;

procedure TzDbImage.ForceEditMode;
begin
  if Assigned(Field) then
    if Field.DataSet.Active then
      if not(Field.DataSet.State in dsEditModes) then
        Field.DataSet.Edit;
end;

function TzDbImage.Test: String;
begin
  Result := '';

  if Assigned(FDataLink) then
    if Assigned(FDataLink.Field) then
      Result := FDataLink.Field.FieldName;
end;

end.
