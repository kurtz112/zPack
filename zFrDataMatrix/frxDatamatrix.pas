unit frxDataMatrix;

interface

{$I frx.inc}

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
  Menus,
  DataMatrix,
  frxClass,
  ExtCtrls
{$IFDEF Delphi6}
    ,
  Variants
{$ENDIF}
{$IFDEF FR_COM}
    ,
  FastReport_TLB
{$ENDIF};

type
  TfrxDataMatrixObject = class(TComponent)
  end; // fake component

  TfrxDataMatrixView = class(TfrxView)
  private
    FDataMatrix: TDataMatrix;
    FExpression: string;
    FFlip: boolean;
    Frebuild: boolean;
    FReverse: boolean;
    FStretch: boolean;
    function GetBackColor: TColor;
    function GetBarColor: TColor;
    function GetCode: string;
    function GetEncoding: TEncoding;
    function GetMargin: integer;
    function GetOffsetX: integer;
    function GetOffsetY: integer;
    function GetPixelsDot: integer;
    function GetPreferredFormat: TFormat;
    function GetProcessTilde: boolean;
    procedure SetBackColor(const Value: TColor);
    procedure SetBarColor(const Value: TColor);
    procedure SetCode(const Value: string);
    procedure SetEncoding(const Value: TEncoding);
    procedure SetMargin(const Value: integer);
    procedure SetOffsetX(const Value: integer);
    procedure SetOffsetY(const Value: integer);
    procedure SetPixelsDot(const Value: integer);
    procedure SetPreferredFormat(const Value: TFormat);
    procedure SetProcessTilde(const Value: boolean);
    procedure SetFlip(const Value: boolean);
    procedure SetStretch(const Value: boolean);
  protected
    property rebuild: boolean read Frebuild write Frebuild;

    procedure RotateImage(Bitmap: TBitmap);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: string; override;
    property DataMatrix: TDataMatrix read FDataMatrix;
  published
    property BackColor: TColor read GetBackColor write SetBackColor default clWhite;
    property BarColor: TColor read GetBarColor write SetBarColor default clBlack;
    property BrushStyle;
    property Code: string read GetCode write SetCode;
    property Color;
    property Cursor;
    property DataField;
    property DataSet;
    property DataSetName;
    property Encoding: TEncoding read GetEncoding write SetEncoding default E_ASCII;
    property Expression: string read FExpression write FExpression;
    property Frame;
    property Margin: integer read GetMargin write SetMargin default 30;
    property OffsetX: integer read GetOffsetX write SetOffsetX;
    property OffsetY: integer read GetOffsetY write SetOffsetY;
    property PixelsDot: integer read GetPixelsDot write SetPixelsDot default 2;
    property PreferredFormat: TFormat read GetPreferredFormat write SetPreferredFormat default AUTO;
    property ProcessTilde: boolean read GetProcessTilde write SetProcessTilde default false;
    property Flip: boolean read FFlip write SetFlip;
    property Reverse: boolean read FReverse write FReverse;
    property Stretch: boolean read FStretch write SetStretch default false;
    property TagStr;
    property URL;

  end;

implementation

uses
  // frxDataMatrixRTTI,
  frxDsgnIntf,
  frxRes,
  frxUtils,
  frWinGraphicUtils,
  frGraphicPlatformHelper;

const
  cbDefaultText = '12345678';

  { TfrxDataMatrixView }

constructor TfrxDataMatrixView.Create(AOwner: TComponent);
begin
  inherited;
  FExpression := '';
  FDataMatrix := TDataMatrix.Create(nil);
  FDataMatrix.Margin := 0;
  FStretch := false;
  FFlip := false;
  FReverse := false;
end;

destructor TfrxDataMatrixView.Destroy;
begin
  FreeAndNil(FDataMatrix);
  inherited Destroy;
end;

class function TfrxDataMatrixView.GetDescription: string;
begin
  Result := 'zDataMatrix'; // frxResources.Get('obBarC');
end;

procedure TfrxDataMatrixView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  SaveWidth: Extended;
  ErrorText: string;
  DrawRect: TRect;
  Bitmap: TBitmap;
  r: TRect;
begin
  SaveWidth := Width;
  // try
  // if (FRotation = 0) or (FRotation = 180) then
  // Width := FDataMatrix.Width * FZoom
  // else
  // Height := FDataMatrix.Width * FZoom;
  // except
  // on e: Exception do
  // begin
  // FDataMatrix.Text := '12345678';
  // ErrorText := e.Message;
  // end;
  // end;
  //
  // if FHAlign = haRight then
  // Left := Left + SaveWidth - Width
  // else
  // if FHAlign = haCenter then
  // Left := Left + (SaveWidth - Width) / 2;

  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;
  FDataMatrix.SetBounds(FX, FY, FX1 - FX, FY1 - FY);
  Bitmap := TBitmap.Create; { construct the bitmap object }
  try
    Bitmap.Height := FDataMatrix.Height;
    Bitmap.Width := FDataMatrix.Width;
    r := Rect(FX, FY, FX1, FY1);
    FDataMatrix.rebuild := True;

    if Stretch then
      FDataMatrix.paintBarcodeAutoSize(Bitmap.Canvas)
    else
      FDataMatrix.paintBarcode(Bitmap.Canvas);

    // ZZ 29.01.2014
    if Flip or Reverse then
      RotateImage(Bitmap);

    frxDrawGraphic(Canvas, r, Bitmap, True, false, false, clNone, nil);
  finally
    FreeAndNil(Bitmap);
  end;

  DrawFrame;
end;

procedure TfrxDataMatrixView.SetFlip(const Value: boolean);
begin
  FFlip := Value;
end;

function TfrxDataMatrixView.GetBackColor: TColor;
begin
  Result := DataMatrix.BackColor;
end;

function TfrxDataMatrixView.GetBarColor: TColor;
begin
  Result := DataMatrix.BarColor;
end;

function TfrxDataMatrixView.GetCode: string;
begin
  Result := DataMatrix.Code;
end;

function TfrxDataMatrixView.GetEncoding: TEncoding;
begin
  Result := DataMatrix.Encoding;
end;

function TfrxDataMatrixView.GetMargin: integer;
begin
  Result := DataMatrix.Margin;
end;

procedure TfrxDataMatrixView.SetBackColor(const Value: TColor);
begin
  DataMatrix.BackColor := Value;
end;

procedure TfrxDataMatrixView.SetBarColor(const Value: TColor);
begin
  DataMatrix.BarColor := Value;
end;

procedure TfrxDataMatrixView.SetCode(const Value: string);
begin
  DataMatrix.Code := Value;
end;

procedure TfrxDataMatrixView.SetEncoding(const Value: TEncoding);
begin
  DataMatrix.Encoding := Value;
end;

procedure TfrxDataMatrixView.SetMargin(const Value: integer);
begin
  DataMatrix.Margin := Value;
end;

procedure TfrxDataMatrixView.GetData;
begin
  inherited;
  if IsDataField then
    Code := VarToStr(DataSet.Value[DataField])
  else
    if Expression <> '' then
      Code := VarToStr(Report.Calc(Expression));
end;

function TfrxDataMatrixView.GetOffsetX: integer;
begin
  Result := DataMatrix.OffsetX;
end;

function TfrxDataMatrixView.GetOffsetY: integer;
begin
  Result := DataMatrix.OffsetY;
end;

function TfrxDataMatrixView.GetPixelsDot: integer;
begin
  Result := DataMatrix.PixelsDot;
end;

function TfrxDataMatrixView.GetPreferredFormat: TFormat;
begin
  Result := DataMatrix.PreferredFormat;
end;

function TfrxDataMatrixView.GetProcessTilde: boolean;
begin
  Result := DataMatrix.ProcessTilde;
end;

procedure TfrxDataMatrixView.SetOffsetX(const Value: integer);
begin
  DataMatrix.OffsetX := Value;
end;

procedure TfrxDataMatrixView.SetOffsetY(const Value: integer);
begin
  DataMatrix.OffsetY := Value
end;

procedure TfrxDataMatrixView.SetPixelsDot(const Value: integer);
begin
  DataMatrix.PixelsDot := Value;
end;

procedure TfrxDataMatrixView.SetPreferredFormat(const Value: TFormat);
begin
  DataMatrix.PreferredFormat := Value;
end;

procedure TfrxDataMatrixView.SetProcessTilde(const Value: boolean);
begin
  DataMatrix.ProcessTilde := Value;
end;

procedure TfrxDataMatrixView.SetStretch(const Value: boolean);
begin
  FStretch := Value;
end;

procedure TfrxDataMatrixView.RotateImage(Bitmap: TBitmap);
VAR
  Bottom: integer;
  Left: integer;
  Right: integer;
  Top: integer;
  tmp: TBitmap;
begin
  Assert(Assigned(Bitmap));

  // Bitmap.SaveToFile('c:\temp\temp1.bmp');

  tmp := TBitmap.Create;
  try
    tmp.Width := Bitmap.Width;
    tmp.Height := Bitmap.Height;
    tmp.PixelFormat := Bitmap.PixelFormat;

    if Flip then
    begin
      Top := Bitmap.Height - 1;
      Bottom := -1
    end
    else
    begin
      Top := 0;
      Bottom := Bitmap.Height
    end;

    // Left 2 Right
    if Reverse then
    begin
      Left := Bitmap.Width - 1;
      Right := -1;
    end
    else
    begin
      Left := 0;
      Right := Bitmap.Width;
    end;

    tmp.Canvas.CopyRect(Rect(Left, Top, Right, Bottom), Bitmap.Canvas, Rect(0, 0, Bitmap.Width, Bitmap.Height));
    // tmp.SaveToFile('c:\temp\temp2.bmp');
    Bitmap.Assign(tmp);
    // Bitmap.SaveToFile('c:\temp\temp3.bmp');
  finally
    FreeAndNil(tmp);
  end;
end;

initialization

frxObjects.RegisterObject1(TfrxDataMatrixView, nil, 'zDataMatrix', '', 0, 23);

finalization

frxObjects.UnRegister(TfrxDataMatrixView);

end.
