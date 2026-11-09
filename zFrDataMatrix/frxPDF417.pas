unit frxPDF417;

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
  PDF417,
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
  TfrxPDF417Object = class(TComponent); // fake component

  TfrxPDF417View = class(TfrxView)
  private
    FPDF417: TPDF417;
    FExpression: string;
    Frebuild: boolean;
    FStretch: Boolean;
    FPDFMacroFileName: string;
    FMacroPDFLastSegment: boolean;
    function GetAutoFit: boolean;
    function GetBackColor: TColor;
    function GetBarColor: TColor;
    function GetBarHeightPixels: integer;
    function GetBarWidthPixels: integer;
    function GetCode: string;
    function GetHorizontalPixelShaving: integer;
    function GetLeftMargin: integer;
    function GetOffsetX: Integer;
    function GetOffsetY: Integer;
    function GetPDFColumns: integer;
    function GetPDFECLevel: integer;
    function GetPDFMacroAddresse: string;
    function GetPDFMacroFileId: string;
    function GetPDFMacroFileSize: integer;
    function GetPDFMacroSegment: integer;
    function GetPDFMacroSegmentCount: integer;
    function GetPDFMacroSender: string;
    function GetPDFMacroTimeStamp: string;
    function GetPDFMaxRows: integer;
    function GetPDFMode: TEncoding;
    function GetPDFRows: integer;
    function GetPDFTruncated: boolean;
    function GetTopMargin: integer;
    function GetVerticalPixelShaving: integer;
    procedure SetAutoFit(const Value: boolean);
    procedure SetBackColor(const Value: TColor);
    procedure SetBarColor(const Value: TColor);
    procedure SetBarHeightPixels(const Value: integer);
    procedure SetBarWidthPixels(const Value: integer);
    procedure SetCode(const Value: string);
    procedure SetHorizontalPixelShaving(const Value: integer);
    procedure SetLeftMargin(const Value: integer);
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetY(const Value: Integer);
    procedure SetPDFColumns(const Value: integer);
    procedure SetPDFECLevel(const Value: integer);
    procedure SetPDFMacroAddresse(const Value: string);
    procedure SetPDFMacroFileId(const Value: string);
    procedure SetPDFMacroFileSize(const Value: integer);
    procedure SetPDFMacroSegment(const Value: integer);
    procedure SetPDFMacroSegmentCount(const Value: integer);
    procedure SetPDFMacroSender(const Value: string);
    procedure SetPDFMacroTimeStamp(const Value: string);
    procedure SetPDFMaxRows(const Value: integer);
    procedure SetPDFMode(const Value: TEncoding);
    procedure SetPDFRows(const Value: integer);
    procedure SetPDFTruncated(const Value: boolean);
    procedure SetStretch(const Value: Boolean);
    procedure SetTopMargin(const Value: integer);
    procedure SetVerticalPixelShaving(const Value: integer);
  protected
    property rebuild: boolean read Frebuild write Frebuild;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: string; override;
    property PDF417: TPDF417 read FPDF417;
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
    property Expression: string read FExpression write FExpression;
    property Frame;
    property OffsetX: Integer read GetOffsetX write SetOffsetX;
    property OffsetY: Integer read GetOffsetY write SetOffsetY;
    property Stretch: Boolean read FStretch write SetStretch default false;
    property TagStr;
    property URL;
    //
    property AutoFit: boolean read GetAutoFit write SetAutoFit;
    property PDFMacroSegmentCount: integer read GetPDFMacroSegmentCount write SetPDFMacroSegmentCount;
    property PDFTruncated: boolean read GetPDFTruncated write SetPDFTruncated default false;
    property MacroPDFLastSegment: boolean read FMacroPDFLastSegment write FMacroPDFLastSegment default false;
    property PDFMacroFileName: string read FPDFMacroFileName write FPDFMacroFileName;
    property PDFMode: TEncoding read GetPDFMode write SetPDFMode default PDF_BINARY;
    property PDFMacroSegment: integer read GetPDFMacroSegment write SetPDFMacroSegment default -1;
    property PDFMacroFileId: string read GetPDFMacroFileId write SetPDFMacroFileId;
    property PDFMacroTimeStamp: string read GetPDFMacroTimeStamp write SetPDFMacroTimeStamp;
    property PDFMacroSender: string read GetPDFMacroSender write SetPDFMacroSender;
    property PDFMacroAddresse: string read GetPDFMacroAddresse write SetPDFMacroAddresse;
    property PDFMacroFileSize: integer read GetPDFMacroFileSize write SetPDFMacroFileSize default 0;
    property PDFMaxRows: integer read GetPDFMaxRows write SetPDFMaxRows default 4;
    property PDFRows: integer read GetPDFRows write SetPDFRows default 0;
    property PDFColumns: integer read GetPDFColumns write SetPDFColumns default 10;
    property PDFECLevel: integer read GetPDFECLevel write SetPDFECLevel default 0;
    property HorizontalPixelShaving: integer read GetHorizontalPixelShaving write SetHorizontalPixelShaving default 0;

    property VerticalPixelShaving: integer read GetVerticalPixelShaving write SetVerticalPixelShaving default 0;

    property TopMargin: integer read GetTopMargin write SetTopMargin default 0;
    property LeftMargin: integer read GetLeftMargin write SetLeftMargin default 0;
    property BarWidthPixels: integer read GetBarWidthPixels write SetBarWidthPixels default 1;
    property BarHeightPixels: integer read GetBarHeightPixels write
      SetBarHeightPixels default 7;
  end;

implementation

uses
  // frxPDF417RTTI,
  frxDsgnIntf,
  frxRes,
  frxUtils;

const
  cbDefaultText = '12345678';

  { TfrxPDF417View }

constructor TfrxPDF417View.Create(AOwner: TComponent);
begin
  inherited;
  FExpression := '';
  FPDF417 := TPDF417.Create(nil);
  FStretch := False;
end;

destructor TfrxPDF417View.Destroy;
begin
  FreeAndNil(FPDF417);
  inherited Destroy;
end;

class function TfrxPDF417View.GetDescription: string;
begin
  Result := 'PDF417'; //frxResources.Get('obBarC');
end;

procedure TfrxPDF417View.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  SaveWidth: Extended;
  ErrorText: string;
  DrawRect: TRect;
  Bitmap: TBitmap;
  r: TRect;
begin
  SaveWidth := Width;
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;
  FPDF417.SetBounds(FX, FY, FX1 - FX, FY1 - FY);
  Bitmap := TBitmap.Create; { construct the bitmap object }
  try
    Bitmap.Height := FPDF417.Height;
    Bitmap.Width := FPDF417.Width;
    r := Rect(FX, FY, FX1, FY1);

    if Stretch then
      FPDF417.paintBarcodeAutoSize(Bitmap.Canvas)
    else
      FPDF417.paintBarcode(Bitmap.Canvas);

    frxDrawGraphic(Canvas, r, Bitmap, True, False, False, clNone);
  finally
    FreeAndNil(BitMap);
  end;

  DrawFrame;
end;

function TfrxPDF417View.GetAutoFit: boolean;
begin
  Result := PDF417.AutoFit;
end;

function TfrxPDF417View.GetBackColor: TColor;
begin
  Result := PDF417.BackColor;
end;

function TfrxPDF417View.GetBarColor: TColor;
begin
  Result := PDF417.BarColor;
end;

function TfrxPDF417View.GetBarHeightPixels: integer;
begin
  Result := PDF417.BarHeightPixels;
end;

function TfrxPDF417View.GetBarWidthPixels: integer;
begin
  Result := PDF417.BarWidthPixels;
end;

function TfrxPDF417View.GetCode: string;
begin
  Result := PDF417.Code;
end;

procedure TfrxPDF417View.SetBackColor(const Value: TColor);
begin
  PDF417.BackColor := Value;
end;

procedure TfrxPDF417View.SetBarColor(const Value: TColor);
begin
  PDF417.BarColor := Value;
end;

procedure TfrxPDF417View.SetCode(const Value: string);
begin
  PDF417.Code := Value;
end;

procedure TfrxPDF417View.GetData;
begin
  inherited;
  if IsDataField then
    Code := VarToStr(DataSet.Value[DataField])
  else
    if Expression <> '' then
      Code := VarToStr(Report.Calc(Expression));
end;

function TfrxPDF417View.GetHorizontalPixelShaving: integer;
begin
  Result := PDF417.HorizontalPixelShaving;
end;

function TfrxPDF417View.GetLeftMargin: integer;
begin
  Result := PDF417.LeftMargin;
end;

function TfrxPDF417View.GetOffsetX: Integer;
begin
  Result := PDF417.OffsetX;
end;

function TfrxPDF417View.GetOffsetY: Integer;
begin
  Result := PDF417.OffsetY;
end;

function TfrxPDF417View.GetPDFColumns: integer;
begin
  Result := PDF417.PDFColumns;
end;

function TfrxPDF417View.GetPDFECLevel: integer;
begin
  Result := PDF417.PDFECLevel;
end;

function TfrxPDF417View.GetPDFMacroAddresse: string;
begin
  Result := PDF417.PDFMacroAddresse;
end;

function TfrxPDF417View.GetPDFMacroFileId: string;
begin
  Result := PDF417.PDFMacroFileId;
end;

function TfrxPDF417View.GetPDFMacroFileSize: integer;
begin
  Result := PDF417.PDFMacroFileSize;
end;

function TfrxPDF417View.GetPDFMacroSegment: integer;
begin
  Result := PDF417.PDFMacroSegment;
end;

function TfrxPDF417View.GetPDFMacroSegmentCount: integer;
begin
  Result := PDF417.PDFMacroSegmentCount;
end;

function TfrxPDF417View.GetPDFMacroSender: string;
begin
  Result := PDF417.PDFMacroSender;
end;

function TfrxPDF417View.GetPDFMacroTimeStamp: string;
begin
  Result := PDF417.PDFMacroTimeStamp;
end;

function TfrxPDF417View.GetPDFMaxRows: integer;
begin
  Result := PDF417.PDFMaxRows;
end;

function TfrxPDF417View.GetPDFMode: TEncoding;
begin
  Result := PDF417.PDFMode;
end;

function TfrxPDF417View.GetPDFRows: integer;
begin
  Result := PDF417.PDFRows;
end;

function TfrxPDF417View.GetPDFTruncated: boolean;
begin
  Result := PDF417.PDFTruncated;
end;

function TfrxPDF417View.GetTopMargin: integer;
begin
  Result := PDF417.TopMargin;
end;

function TfrxPDF417View.GetVerticalPixelShaving: integer;
begin
  Result := PDF417.VerticalPixelShaving;
end;

procedure TfrxPDF417View.SetAutoFit(const Value: boolean);
begin
  PDF417.AutoFit := Value;
end;

procedure TfrxPDF417View.SetBarHeightPixels(const Value: integer);
begin
  PDF417.BarHeightPixels := Value;
end;

procedure TfrxPDF417View.SetBarWidthPixels(const Value: integer);
begin
  PDF417.BarWidthPixels := Value;
end;

procedure TfrxPDF417View.SetHorizontalPixelShaving(const Value: integer);
begin
  PDF417.HorizontalPixelShaving := Value;
end;

procedure TfrxPDF417View.SetLeftMargin(const Value: integer);
begin
  PDF417.LeftMargin := Value;
end;

procedure TfrxPDF417View.SetOffsetX(const Value: Integer);
begin
  PDF417.OffsetX := Value;
end;

procedure TfrxPDF417View.SetOffsetY(const Value: Integer);
begin
  PDF417.OffsetY := Value
end;

procedure TfrxPDF417View.SetPDFColumns(const Value: integer);
begin
  PDF417.PDFColumns := Value;
end;

procedure TfrxPDF417View.SetPDFECLevel(const Value: integer);
begin
  PDF417.PDFECLevel := Value;
end;

procedure TfrxPDF417View.SetPDFMacroAddresse(const Value: string);
begin
  PDF417.PDFMacroAddresse := Value;
end;

procedure TfrxPDF417View.SetPDFMacroFileId(const Value: string);
begin
  PDF417.PDFMacroFileId := Value;
end;

procedure TfrxPDF417View.SetPDFMacroFileSize(const Value: integer);
begin
  PDF417.PDFMacroFileSize := Value;
end;

procedure TfrxPDF417View.SetPDFMacroSegment(const Value: integer);
begin
  PDF417.PDFMacroSegment := Value;
end;

procedure TfrxPDF417View.SetPDFMacroSegmentCount(const Value: integer);
begin
  PDF417.PDFMacroSegmentCount := Value;
end;

procedure TfrxPDF417View.SetPDFMacroSender(const Value: string);
begin
  PDF417.PDFMacroSender := Value;
end;

procedure TfrxPDF417View.SetPDFMacroTimeStamp(const Value: string);
begin
  PDF417.PDFMacroTimeStamp := Value;
end;

procedure TfrxPDF417View.SetPDFMaxRows(const Value: integer);
begin
  PDF417.PDFMaxRows := Value;
end;

procedure TfrxPDF417View.SetPDFMode(const Value: TEncoding);
begin
  PDF417.PDFMode := Value;
end;

procedure TfrxPDF417View.SetPDFRows(const Value: integer);
begin
  PDF417.PDFRows := Value;
end;

procedure TfrxPDF417View.SetPDFTruncated(const Value: boolean);
begin
  PDF417.PDFTruncated := Value;
end;

procedure TfrxPDF417View.SetStretch(const Value: Boolean);
begin
  FStretch := Value;
end;

procedure TfrxPDF417View.SetTopMargin(const Value: integer);
begin
  PDF417.TopMargin := Value;
end;

procedure TfrxPDF417View.SetVerticalPixelShaving(const Value: integer);
begin
  PDF417.VerticalPixelShaving := Value;
end;

initialization
  frxObjects.RegisterObject1(TfrxPDF417View, nil, '', '', 0, 23);

finalization
  frxObjects.UnRegister(TfrxPDF417View);
end.

