unit Datamatrix;

{
  RDataMatrix
  Copyright (C)

  java4less@Confluencia.net
  All rights reserved

 Adquisition , use and distribution of this code is subject to restriction:
  - You may modify the source code in order to adapt it to your needs.
  - Redistribution of this ( or a modified version) source code is prohibited. You may only redistribute compiled versions.
  - You may redistribute the compiled version as part of your application, not a new component with the same purpose as this one.
  - You may not remove this notice from the source code
  - This notice disclaim all warranties of all material

The class DataMatrix is a class that creates data matrix barcode symbols. Data Matrix is a two-dimensional (2D) matrix symbology which is made up of square modules arranged within a perimeter finder pattern. It can encode up to 3116 characters from the entire 256 byte ASCII character set and it supports advanced encoding error checking and correction algorithms (reed-solomon). This algorithms allow the recognition of barcodes that are up to 60% damaged.

Other features are:

All sizes and formats (from 10x10 till 144x144)
Ascii, text , C40 and Base256 (for binary data) encoding.
The "Extended Channel Interpretation and Structured append
Configuration of colors and size of modules (points).

}

interface

uses
  reed,
  WinProcs,
  WinTypes,
  Messages,
  SysUtils,
  Classes,
  Dialogs,
  Graphics,
  Controls,
  Math;

type

  {encoding types}
  TEncoding = (
    {ascii encoding (see Data Matrix Manual for more information ). This is appropiate for data that contains mainly ascii characters (1-127).}
    E_ASCII,
    {c40 encoding (see Data Matrix Manual for more information ). This is appropiate for data that contains mainly upper case characters and digits.}
    E_C40,
    {text encoding (see Data Matrix Manual for more information ). This is appropiate for data that contains mainly lower case characters and digits.}
    E_TEXT,
    { base 256 encoding. This is mainly used for binary data.}
    E_BASE256, E_NONE,
    { automatic encoding. The class decides dinamically which encoding is more apporpiate for the data you want to encode.}
    E_AUTO);

  {formats and sizes}
  TFormat = (AUTO, C10X10, C12X12, C14X14, C16X16, C18X18, C20X20, C22X22, C24X24, C26X26, C32X32, C36X36, C40X40,
    C44X44, C48X48, C52X52, C64X64, C72X72, C80X80, C88X88, C96X96, C104X104, C120X120, C132X132,
    C144X144, C8X18, C8X32, C12X26, C12X36, C16X36, C16X48);

  { datamatrix codes }
const
  C40_PAD: Integer = 0;
const
  PAD: Integer = 129;
const
  LATCH_C40: Integer = 230;
const
  LATCH_BASE256: Integer = 231;
const
  FNC1: Integer = 232;
const
  STRUCTURED_APPEND: Integer = 233;
const
  READER_PROGRAMMING: Integer = 234;
const
  SHIFT: Integer = 235;
const
  MACRO5: Integer = 236;
const
  MACRO6: Integer = 237;
const
  LATCH_TEXT: Integer = 239;
const
  ECI: Integer = 241;
const
  UNLATCH: Integer = 254;

  {indices of the table}
const
  C_ROW: Integer = 0;
const
  C_COL: Integer = 1;
const
  C_ROWDATA: Integer = 2;
const
  C_COLDATA: Integer = 3;
const
  C_REGIONS: Integer = 4;
const
  C_ROWMAP: Integer = 5;
const
  C_COLMAP: Integer = 6;
const
  C_TOTALDATA: Integer = 7;
const
  C_TOTALERR: Integer = 8;
const
  C_REEDDATA: Integer = 9;
const
  C_REEDERR: Integer = 10;
const
  C_REEDBLOCKS: Integer = 11;

  { symbol attributtes of the configurations }
const
  configuration: array[0..30, 0..11] of Integer = (
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), // AUTO
    (10, 10, 8, 8, 1, 8, 8, 3, 5, 3, 5, 1), // 10X10
    (12, 12, 10, 10, 1, 10, 10, 5, 7, 5, 7, 1), // 12 X 12 ....
    (14, 14, 12, 12, 1, 12, 12, 8, 10, 8, 10, 1),
    (16, 16, 14, 14, 1, 14, 14, 12, 12, 12, 12, 1),
    (18, 18, 16, 16, 1, 16, 16, 18, 14, 18, 14, 1),
    (20, 20, 18, 18, 1, 18, 18, 22, 18, 22, 18, 1),
    (22, 22, 20, 20, 1, 20, 20, 30, 20, 30, 20, 1),
    (24, 24, 22, 22, 1, 22, 22, 36, 24, 36, 24, 1),
    (26, 26, 24, 24, 1, 24, 24, 44, 28, 44, 28, 1),
    (32, 32, 14, 14, 4, 28, 28, 62, 36, 62, 36, 1),
    (36, 36, 16, 16, 4, 32, 32, 86, 42, 86, 42, 1),
    (40, 40, 18, 18, 4, 36, 36, 114, 48, 114, 48, 1),
    (44, 44, 20, 20, 4, 40, 40, 144, 56, 144, 56, 1),
    (48, 48, 22, 22, 4, 44, 44, 174, 68, 174, 68, 1),
    (52, 52, 24, 24, 4, 48, 48, 204, 84, 102, 42, 2),
    (64, 64, 14, 14, 16, 56, 56, 280, 112, 140, 56, 2),
    (72, 72, 16, 16, 16, 64, 64, 368, 144, 92, 36, 4),
    (80, 80, 18, 18, 16, 72, 72, 456, 192, 114, 48, 4),
    (88, 88, 20, 20, 16, 80, 80, 576, 224, 144, 56, 4),
    (96, 96, 22, 22, 16, 88, 88, 696, 272, 174, 68, 4),
    (104, 104, 24, 24, 16, 96, 96, 816, 336, 136, 56, 6),
    (120, 120, 18, 18, 36, 108, 108, 1050, 496, 175, 68, 6),
    (132, 132, 20, 20, 36, 120, 120, 1304, 496, 163, 62, 8),
    (144, 144, 22, 22, 36, 132, 132, 1558, 620, 156, 62, 10),
    (8, 18, 6, 16, 1, 6, 16, 5, 7, 5, 7, 1),
    (8, 32, 6, 14, 2, 6, 28, 10, 11, 10, 11, 1),
    (12, 26, 10, 24, 1, 10, 24, 16, 14, 16, 14, 1),
    (12, 36, 10, 16, 2, 10, 32, 22, 18, 22, 18, 1),
    (16, 36, 14, 16, 2, 14, 32, 32, 24, 32, 24, 1),
    (16, 48, 14, 22, 2, 14, 44, 49, 28, 49, 28, 1));

const
  C40Codes: array[0..255, 0..3] of Integer = (
    (0, 0, -1, -1), (0, 1, -1, -1), (0, 2, -1, -1), (0, 3, -1, -1), (0, 4, -1, -1), (0, 5, -1, -1), (0, 6, -1, -1), (0, 7, -1, -1), (0, 8, -1, -1), (0, 9, -1, -1),
    (0, 10, -1, -1), (0, 11, -1, -1), (0, 12, -1, -1), (0, 13, -1, -1), (0, 14, -1, -1), (0, 15, -1, -1), (0, 16, -1, -1), (0, 17, -1, -1), (0, 18, -1, -1), (0, 19, -1, -1),
    (0, 20, -1, -1), (0, 21, -1, -1), (0, 22, -1, -1), (0, 23, -1, -1), (0, 24, -1, -1), (0, 25, -1, -1), (0, 26, -1, -1), (0, 27, -1, -1), (0, 28, -1, -1), (0, 29, -1, -1),
    (0, 30, -1, -1), (0, 31, -1, -1), (3, -1, -1, -1), (1, 0, -1, -1), (1, 1, -1, -1), (1, 2, -1, -1), (1, 3, -1, -1), (1, 4, -1, -1), (1, 5, -1, -1), (1, 6, -1, -1),
    (1, 7, -1, -1), (1, 8, -1, -1), (1, 9, -1, -1), (1, 10, -1, -1), (1, 11, -1, -1), (1, 12, -1, -1), (1, 13, -1, -1), (1, 14, -1, -1), (4, -1, -1, -1), (5, -1, -1, -1),
    (6, -1, -1, -1), (7, -1, -1, -1), (8, -1, -1, -1), (9, -1, -1, -1), (10, -1, -1, -1), (11, -1, -1, -1), (12, -1, -1, -1), (13, -1, -1, -1), (1, 15, -1, -1), (1, 16, -1, -1),
    (1, 17, -1, -1), (1, 18, -1, -1), (1, 19, -1, -1), (1, 20, -1, -1), (1, 21, -1, -1), (14, -1, -1, -1), (15, -1, -1, -1), (16, -1, -1, -1), (17, -1, -1, -1), (18, -1, -1, -1),
    (19, -1, -1, -1), (20, -1, -1, -1), (21, -1, -1, -1), (22, -1, -1, -1), (23, -1, -1, -1), (24, -1, -1, -1), (25, -1, -1, -1), (26, -1, -1, -1), (27, -1, -1, -1), (28, -1, -1, -1),
    (29, -1, -1, -1), (30, -1, -1, -1), (31, -1, -1, -1), (32, -1, -1, -1), (33, -1, -1, -1), (34, -1, -1, -1), (35, -1, -1, -1), (36, -1, -1, -1), (37, -1, -1, -1), (38, -1, -1, -1),
    (39, -1, -1, -1), (1, 22, -1, -1), (1, 23, -1, -1), (1, 24, -1, -1), (1, 25, -1, -1), (1, 26, -1, -1), (2, 0, -1, -1), (2, 1, -1, -1), (2, 2, -1, -1), (2, 3, -1, -1),
    (2, 4, -1, -1), (2, 5, -1, -1), (2, 6, -1, -1), (2, 7, -1, -1), (2, 8, -1, -1), (2, 9, -1, -1), (2, 10, -1, -1), (2, 11, -1, -1), (2, 12, -1, -1), (2, 13, -1, -1),
    (2, 14, -1, -1), (2, 15, -1, -1), (2, 16, -1, -1), (2, 17, -1, -1), (2, 18, -1, -1), (2, 19, -1, -1), (2, 20, -1, -1), (2, 21, -1, -1), (2, 22, -1, -1), (2, 23, -1, -1),
    (2, 24, -1, -1), (2, 25, -1, -1), (2, 26, -1, -1), (2, 27, -1, -1), (2, 28, -1, -1), (2, 29, -1, -1), (2, 30, -1, -1), (2, 31, -1, -1), (1, 30, 0, 0), (1, 30, 0, 1),
    (1, 30, 0, 2), (1, 30, 0, 3), (1, 30, 0, 4), (1, 30, 0, 5), (1, 30, 0, 6), (1, 30, 0, 7), (1, 30, 0, 8), (1, 30, 0, 9), (1, 30, 0, 10), (1, 30, 0, 11),
    (1, 30, 0, 12), (1, 30, 0, 13), (1, 30, 0, 14), (1, 30, 0, 15), (1, 30, 0, 16), (1, 30, 0, 17), (1, 30, 0, 18), (1, 30, 0, 19), (1, 30, 0, 20), (1, 30, 0, 21),
    (1, 30, 0, 22), (1, 30, 0, 23), (1, 30, 0, 24), (1, 30, 0, 25), (1, 30, 0, 26), (1, 30, 0, 27), (1, 30, 0, 28), (1, 30, 0, 29), (1, 30, 0, 30), (1, 30, 0, 31),
    (1, 30, 3, -1), (1, 30, 1, 0), (1, 30, 1, 1), (1, 30, 1, 2), (1, 30, 1, 3), (1, 30, 1, 4), (1, 30, 1, 5), (1, 30, 1, 6), (1, 30, 1, 7), (1, 30, 1, 8),
    (1, 30, 1, 9), (1, 30, 1, 10), (1, 30, 1, 11), (1, 30, 1, 12), (1, 30, 1, 13), (1, 30, 1, 14), (1, 30, 4, -1), (1, 30, 5, -1), (1, 30, 6, -1), (1, 30, 7, -1),
    (1, 30, 8, -1), (1, 30, 9, -1), (1, 30, 10, -1), (1, 30, 11, -1), (1, 30, 12, -1), (1, 30, 13, -1), (1, 30, 1, 15), (1, 30, 1, 16), (1, 30, 1, 17), (1, 30, 1, 18),
    (1, 30, 1, 19), (1, 30, 1, 20), (1, 30, 1, 21), (1, 30, 14, -1), (1, 30, 15, -1), (1, 30, 16, -1), (1, 30, 17, -1), (1, 30, 18, -1), (1, 30, 19, -1), (1, 30, 20, -1),
    (1, 30, 21, -1), (1, 30, 22, -1), (1, 30, 23, -1), (1, 30, 24, -1), (1, 30, 25, -1), (1, 30, 26, -1), (1, 30, 27, -1), (1, 30, 28, -1), (1, 30, 29, -1), (1, 30, 30, -1),
    (1, 30, 31, -1), (1, 30, 32, -1), (1, 30, 33, -1), (1, 30, 34, -1), (1, 30, 35, -1), (1, 30, 36, -1), (1, 30, 37, -1), (1, 30, 38, -1), (1, 30, 39, -1), (1, 30, 1, 22),
    (1, 30, 1, 23), (1, 30, 1, 24), (1, 30, 1, 25), (1, 30, 1, 26), (1, 30, 2, 0), (1, 30, 2, 1), (1, 30, 2, 2), (1, 30, 2, 3), (1, 30, 2, 4), (1, 30, 2, 5),
    (1, 30, 2, 6), (1, 30, 2, 7), (1, 30, 2, 8), (1, 30, 2, 9), (1, 30, 2, 10), (1, 30, 2, 11), (1, 30, 2, 12), (1, 30, 2, 13), (1, 30, 2, 14), (1, 30, 2, 15),
    (1, 30, 2, 16), (1, 30, 2, 17), (1, 30, 2, 18), (1, 30, 2, 19), (1, 30, 2, 20), (1, 30, 2, 21), (1, 30, 2, 22), (1, 30, 2, 23), (1, 30, 2, 24), (1, 30, 2, 25),
    (1, 30, 2, 26), (1, 30, 2, 27), (1, 30, 2, 28), (1, 30, 2, 29), (1, 30, 2, 30), (1, 30, 2, 31));

type
  //  TDatamatrix = class(TQRPrintable)
  TDatamatrix = class(TGraphicControl)
  private
    { Private Declarations }
           {resize the image when painting on the screen to fit the size of the control}
    FAutoFit: boolean;
    {Size in pixels of the square modules that made up the symbol.}
    FPixelsDot: Integer;

    {margin in pixels of the symbol}
    FMargin: Integer;

    FoffsetX: Integer;
    FoffsetY: Integer;

    {if true (default is false) the class will process the ~ character in the input data (see Data Matrix Manual for more information ).}
    FProcessTilde: Boolean;
    FCurrentEncoding: TEncoding;
    { if -1 (default) , the class wil automatically select the format of the symbol. Otherwise you must specify a value (C10X10 till C144X144).}
    FPreferredFormat: TFormat;
    {current configuration}
    rows: Integer;
    cols: Integer;
    datarows: Integer;
    datacols: Integer;
    maprows: Integer;
    mapcols: Integer;
    regions: Integer;
    totaldata: Integer;
    totalerr: Integer;
    reeddata: Integer;
    reederr: Integer;
    reedblocks: Integer;
    FCurrentX: Integer;
    FCurrentY: Integer;

    C49rest: Integer;

    FBitmap: array of array of Integer;
    FreBuild: boolean;
    FInternalCode: string;
    FCode: string;

    {charplacer fields}
    FCharPlacer_nrow: Integer;
    FCharPlacer_ncol: Integer;
    FCharPlacer_array: array of Integer;

    { format used}
    FCalculatedFormat: TFormat;

    { selects the encoding you want to use: E_AUTO, E_ASCII (default), E_C40, E_TEXT or E_BASE256.}
    FEncoding: TEncoding;
    FBackColor: TColor;
    FBarColor: TColor;

    function myRound(d: Double): Integer;
    function random255(code: Integer; position: Integer): Integer;
    function isDigit(c: Integer): boolean;
    procedure copyArray(var src: array of integer; var dest: array of Integer; initSrc: Integer; initDest: Integer; longi: Integer);
    function lookAheadTest(Data: array of Integer; currentEnc: TEncoding; pos: Integer; var specialSymbols: array of string): TEncoding;
    function CodeLength(a: array of Integer): Integer;
    function encodeAuto(longi: Integer; ina: array of Integer; var outa: array of Integer; var specialSymbols: array of string): Integer;
    function encodeBase256(longi: Integer; var initial: Integer; ina: array of Integer; var outInit: Integer; var outa: array of Integer; makeLookAhead: boolean; var specialSymbols: array
      of
      string): Integer;
    function encodeC40(longi: Integer; var initial: Integer; ina: array of Integer; var outa: array of Integer; doTextEncoding: boolean; inititaLatch: boolean; onlyOneWord: boolean):
      Integer;
    function applyTilde(code: string; specialSymbol: array of string): string;
    function random253(code: Integer; position: Integer): Integer;
    procedure drawBarcode(codeStr: array of Integer; specialSymbols: array of string);
    procedure debugMatrix(c: Integer; r: Integer);
    procedure createBitmap(codeStr: array of Integer);
    procedure drawBorders(x: Integer; y: Integer; w: Integer; h: Integer);
    function encodeAscii(longi: Integer; ina: array of Integer; var outa: array of Integer; var specialSymbols: array of string): Integer;
    procedure doCode();
    procedure utah(row: integer; col: integer; charac: integer);
    procedure corner1(charac: Integer);
    procedure corner2(charac: Integer);
    procedure corner3(charac: Integer);
    procedure corner4(charac: Integer);
    procedure charPlacer_make();
    procedure module(r: Integer; c: Integer; charac: Integer; bit: Integer);
    procedure fillRect(canvas: TCanvas; x: integer; y: integer; w: integer; h: integer);
    procedure paintDot(canvas: TCanvas; x: Integer; y: Integer; w: Integer; col: TColor);
  protected
    procedure Paint; override;
  public
    FBinaryCode: array of Integer;
    constructor Create(Owner: TComponent); override;
    procedure paintBarcode(canvas: TCanvas);
    procedure paintBarcodeAutoSize(c: TCanvas);
  published
    property offsetX: Integer read FoffsetX write FoffsetX;
    property offsetY: Integer read FoffsetY write FoffsetY;
    property AutoFit: boolean read FAutoFit write FAutoFit;
    property PixelsDot: integer read FPixelsDot write FPixelsDot default 2;
    property Code: string read FCode write FCode;
    property rebuild: boolean read Frebuild write Frebuild;
    property CurrentX: integer read FCurrentX;
    property CurrentY: integer read FCurrentY;
    property Margin: integer read FMargin write FMargin default 30;
    property ProcessTilde: boolean read FProcessTilde write FProcessTilde default false;
    property PreferredFormat: TFormat read FPreferredFormat write FPreferredFormat default AUTO;
    property Encoding: TEncoding read FEncoding write FEncoding default E_ASCII;
    property BackColor: TColor read FBackColor write FBackColor default clWhite;
    property BarColor: TColor read FBarColor write FBarColor default clBlack;
    property CalculatedFormat: TFormat read FCalculatedFormat;
  end;

procedure Register;

implementation

//procedure TDatamatrix.Print(OfsX, OfsY: Integer);
//begin
//
//  offsetX := ParentReport.QRPrinter.XPos(OfsX + Size.Left);
//  offsety := ParentReport.QRPrinter.Ypos(OfsY + Size.Top);
//
//  rebuild := true;
//  paintBarcode(ParentReport.QRPrinter.Canvas);
//
//  FOffsetX := 0;
//  FOffsetY := 0;
//
//end;

procedure TDatamatrix.Paint;
var
  Bitmap: TBitmap;
  src, dest: TRect;
begin

  if (FAutoFit) then
    paintBarcodeAutosize(Canvas)
  else
  begin

    Bitmap := TBitmap.Create; { construct the bitmap object }
    Bitmap.width := Width;
    Bitmap.height := height;
    src := Rect(0, 0, width, height);
    dest := Rect(0, 0, width, height);

    try
      { draw on the bitmap }
      paintBarcode(Bitmap.Canvas);
      { copy the result into the control's canvas }
      Canvas.copyRect(src, Bitmap.Canvas, dest)
    finally
      Bitmap.Free; { destroy the bitmap object }
    end;
  end;

end;

procedure TDatamatrix.paintBarcodeAutosize(c: TCanvas);
var
  bmp: TBitmap;
  requiredWith: integer;
  requiredHeight: integer;
  rect: TRect;
  rect2: TRect;
begin

  // test paint to find out required size
  bmp := TBitmap.create();
  bmp.width := 100;
  bmp.height := 100;

  paintBarcode(bmp.canvas);

  requiredWith := FcurrentX;
  requiredHeight := FcurrentY;

  bmp.free;
  bmp := nil;

  // paint now on bmp of exact size
  bmp := TBitmap.create();
  bmp.width := requiredWith + Margin;
  bmp.height := requiredHeight + Margin;

  paintBarcode(bmp.canvas);
  rect.top := 0;
  rect.left := 0;
  rect.bottom := height;
  rect.right := width;

  rect2.top := 0;
  rect2.left := 0;
  rect2.bottom := bmp.height;
  rect2.right := bmp.width;

  c.Brush.Color := backColor;
  fillRect(c, rect.left, rect.top, rect.Right, rect.bottom);

  c.copyMode := cmSrcCopy;
  c.copyRect(rect, bmp.canvas, rect2);

  bmp.free;
  bmp := nil;

end;

{ 255 randomizing algorithm }

function TDatamatrix.random255(code: Integer; position: Integer): Integer;
var
  random: Integer;
  tmp: Integer;
begin

  random := (149 * position) mod 255;
  random := random + 1;
  tmp := code + random;

  if (tmp <= 255) then
    result := tmp
  else
    result := (tmp - 256);

end;

function TDatamatrix.isDigit(c: Integer): boolean;
begin
  result := ((c >= ord('0')) and (c <= ord('9')));
end;

procedure TDatamatrix.copyArray(var src: array of integer; var dest: array of Integer; initSrc: Integer; initDest: Integer; longi: Integer);
var
  i: Integer;
begin

  for i := 0 to longi - 1 do
    dest[initDest + i] := src[initSrc + i];

end;

function TDatamatrix.myRound(d: Double): Integer;
begin
  result := Floor(d + 0.5);
end;

{code length. Count number of elements distinct from -1}

function TDatamatrix.CodeLength(a: array of Integer): Integer;
begin

  {if the element is -1, treat it as null}
  result := 4;
  if (a[3] = -1) then
    result := 3;
  if (a[2] = -1) then
    result := 2;
  if (a[1] = -1) then
    result := 1;

end;

{ select which encoding system is more appropiate }

function TDatamatrix.lookAheadTest(Data: array of Integer; currentEnc: TEncoding; pos: Integer; var specialSymbols: array of string): TEncoding;
var
  asciiCount: Double;
  c40Count: Double;
  textCount: Double;
  b256Count: Double;
  initialPos: Integer;
  c: Integer;
  cText: Integer;
  tmp: string;
begin

  { datamatrix speficiations algorithm }

  // step J
  asciiCount := 0;
  c40Count := 1;
  textCount := 1;
  b256Count := 1.25;

  initialPos := pos;

  if (currentEnc <> E_ASCII) then
  begin
    asciiCount := 1;
    c40Count := 2;
    textCount := 2;
    b256Count := 2.25;
  end;

  if (currentEnc = E_C40) then
    c40Count := 0;
  if (currentEnc = E_TEXT) then
    textCount := 0;
  if (currentEnc = E_BASE256) then
    b256Count := 0;

  while (pos < Length(Data)) do
  begin
    c := Data[pos];

    { step L, ascii count }
    if (isDigit(c)) then
      asciiCount := asciiCount + 0.5
    else
      if (c > 127) then
        asciiCount := myRound(asciiCount) + 2
      else
        asciiCount := myRound(asciiCount) + 1;

    { step M c40 Count }
    if (CodeLength(C40Codes[c]) = 1) then
      c40Count := c40Count + 0.66 // native c40
    else
      if (c > 127) then
        c40Count := c40Count + 2.66
      else
        c40Count := c40Count + 1.33;

    { step N, text count }
    cText := c;
    tmp := chr(c);
    if ((c >= ord('A')) and (c <= ord('Z'))) then
      cText := ord(LowerCase(tmp)[1]);
    if ((c >= ord('a')) and (c <= ord('z'))) then
      cText := ord(UpperCase(tmp)[1]);

    if (CodeLength(C40Codes[cText]) = 1) then
      textCount := textCount + 0.66 // native c40
    else
      if (cText > 127) then
        textCount := textCount + 2.66
      else
        textCount := textCount + 1.33;

    { step Q, b256 count }
    b256Count := b256Count + 1;

    { if there is a special symbol, use ASCII }
    if (specialSymbols[pos] <> '') then
    begin
      {exit now}
      result := E_ASCII;
      exit;
    end;

    { step R }
    if ((pos - initialPos) >= 4) then
    begin

      if (((asciiCount + 1) <= c40Count) and ((asciiCount + 1) <= textCount) and ((asciiCount + 1) <= b256Count)) then
      begin
        result := E_ASCII;
        exit;
      end;

      if ((b256Count + 1) <= asciiCount) then
      begin
        result := E_BASE256;
        exit;
      end;

      if ((b256Count + 1) < textCount) and ((b256Count + 1) < c40Count) then
      begin
        result := E_BASE256;
        exit;
      end;

      if ((textCount + 1) < asciiCount) and ((textCount + 1) < c40Count) and ((textCount + 1) < b256Count) then
      begin
        result := E_TEXT;
        exit;
      end;

      if (((c40Count + 1) < asciiCount) and ((c40Count + 1) < textCount) and ((c40Count + 1) < b256Count)) then
      begin
        result := E_C40;
        exit;
      end;

    end;

    pos := pos + 1;

  end; { while }

  { step K, end of data }

       { myRound up }
  asciiCount := myRound(asciiCount);
  c40Count := myRound(c40Count);
  textCount := myRound(textCount);
  b256Count := myRound(b256Count);

  if ((asciiCount <= c40Count) and (asciiCount <= textCount) and (asciiCount <= b256Count)) then
  begin
    result := E_ASCII;
    exit;
  end;
  if ((textCount < asciiCount) and (textCount < c40Count) and (textCount < b256Count)) then
  begin
    result := E_TEXT;
    exit;
  end;
  if ((b256Count < asciiCount) and (b256Count < textCount) and (b256Count < c40Count)) then
  begin
    result := E_BASE256;
    exit;
  end;

  result := E_C40;
end;

// encode automatic

function TDatamatrix.encodeAuto(longi: Integer; ina: array of Integer; var outa: array of Integer; var specialSymbols: array of string): Integer;
var
  tmp: array[0..5999] of Integer;
  tmpResult: array[0..5999] of Integer;
  tmpResultLen: Integer;
  posResult: Integer;
  proposedEncoding: TEncoding;
  Initial: Integer;
  InitialOut: Integer;
  previousEncoding: TEncoding;
  specialSymbolsTMP: array[0..10] of string;
  i: Integer;
  pos: Integer;
  done: boolean;
begin

  posResult := 0;
  previousEncoding := E_ASCII;

  { initialize}
  for i := 0 to length(specialSymbolsTMP) - 1 do
    specialSymbolsTMP[i] := '';

  pos := 0;

  { datamatrix speficiations algorithm }

  {  step A  }
  FCurrentEncoding := E_ASCII;

  while (pos < longi) do
  begin

    { step B  }
    while ((FCurrentEncoding = E_ASCII) and (pos < longi)) do
    begin

      // System.out.println("ASCII");

      done := false;

      { 2 digits? }
      if (pos + 1) < longi then
        if (isDigit(ina[pos]) or isDigit(ina[pos + 1])) then
        begin

          if (previousEncoding <> E_ASCII) and (previousEncoding <> E_BASE256) then
          begin // fix 2.11.2005
            outa[posResult] := UNLATCH;
            posResult := posResult + 1;
          end;

          tmp[0] := ina[pos];
          tmp[1] := ina[pos + 1];

          { copy to final array }
          tmpResultLen := encodeAscii(2, tmp, tmpResult, specialSymbolsTMP);
          copyArray(tmpResult, outa, 0, posResult, tmpResultLen);
          posResult := posResult + tmpResultLen;

          pos := pos + 1;
          pos := pos + 1;
          done := true;

          previousEncoding := E_ASCII;
        end;

      if (not done) then
      begin
        { make test }
        proposedEncoding := lookAheadTest(ina, FCurrentEncoding, pos, specialSymbols);

        // change proposed encoding
        if (proposedEncoding <> E_ASCII) then
        begin
          previousEncoding := FCurrentEncoding;
          FCurrentEncoding := proposedEncoding;
        end;
      end;

      if ((not done) and ((FCurrentEncoding = E_ASCII))) then
      begin

        if (previousEncoding <> E_ASCII) and (previousEncoding <> E_BASE256) then
        begin // fix 2.11.2005
          outa[posResult] := UNLATCH;
          posResult := posResult + 1;
        end;

        tmp[0] := ina[pos];

        specialSymbolsTMP[0] := specialSymbols[pos]; { set parameter for special symbols }
        tmpResultLen := encodeAscii(1, tmp, tmpResult, specialSymbolsTMP);
        specialSymbolsTMP[0] := '';

        { copy to final array }
        copyArray(tmpResult, outa, 0, posResult, tmpResultLen);
        posResult := posResult + tmpResultLen;
        pos := pos + 1;

        previousEncoding := E_ASCII;
      end;

    end; { B }

    // step C
    while ((FCurrentEncoding = E_C40) and (pos < longi)) do
    begin

      //System.out.println("C40");

      if ((previousEncoding <> E_ASCII) and (previousEncoding <> E_C40) and (previousEncoding <> E_BASE256)) then
      begin // fix 2.11.2005
        outa[posResult] := UNLATCH;
        posResult := posResult + 1;
      end;

      // what does test tell us?
      Initial := pos;
      tmpResultLen := encodeC40(longi, Initial, ina, tmpResult, false, (previousEncoding <> E_C40), true);
      pos := Initial;

      copyArray(tmpResult, outa, 0, posResult, tmpResultLen);
      posResult := posResult + tmpResultLen;

      // make test
      proposedEncoding := lookAheadTest(ina, FCurrentEncoding, pos, specialSymbols);
      previousEncoding := FCurrentEncoding;
      FCurrentEncoding := proposedEncoding;

    end; { C }

    { step D }
    while ((FCurrentEncoding = E_TEXT) and (pos < longi)) do
    begin

      // System.out.println("Text");

      if ((previousEncoding <> E_ASCII) and (previousEncoding <> E_TEXT) and (previousEncoding <> E_BASE256)) then
      begin // fix 2.11.2005
        outa[posResult] := UNLATCH;
        posResult := posResult + 1;
      end;

      { what does test tell us? }
      Initial := pos;
      tmpResultLen := encodeC40(longi, Initial, ina, tmpResult, true, (previousEncoding <> E_TEXT), true);
      pos := Initial;

      copyArray(tmpResult, outa, 0, posResult, tmpResultLen);
      posResult := posResult + tmpResultLen;

      {  make test }
      proposedEncoding := lookAheadTest(ina, FCurrentEncoding, pos, specialSymbols);
      previousEncoding := FCurrentEncoding;
      FCurrentEncoding := proposedEncoding;

    end; { D }

    { step G }
    if (FCurrentEncoding = E_BASE256) then
    begin

      if ((previousEncoding <> E_ASCII) and (previousEncoding <> E_BASE256)) then
      begin
        outa[posResult] := UNLATCH;
        posResult := posResult + 1;
      end;

      Initial := pos;
      InitialOut := posResult;
      encodeBase256(longi, Initial, ina, InitialOut, outa, true, specialSymbols);
      pos := Initial;
      posResult := InitialOut;

      // make test
      proposedEncoding := lookAheadTest(ina, FCurrentEncoding, pos, specialSymbols);
      previousEncoding := FCurrentEncoding;
      FCurrentEncoding := proposedEncoding;

    end; { G}

  end; {while}

  result := posResult;

end;

{ encode Base 256 }

function TDatamatrix.encodeBase256(longi: Integer; var initial: Integer; ina: array of Integer; var outInit: Integer; var outa: array of Integer; makeLookAhead: boolean; var specialSymbols:
  array of string): Integer;
var
  count: Integer;
  tmp: array[0..5999] of Integer;
  tmpInitCount: Integer;
  pos: Integer;
  k: Integer;
  k2: Integer;
begin

  tmpInitCount := outInit;
  count := 0;

  { move to tmp, to count the number of bytes in B256 mode }
  k2 := initial;
  for k := initial to longi - 1 do
  begin
    k2 := k;
    tmp[count] := ina[k];
    count := count + 1;

    pos := k + 1;

    if (pos = 24) then
    begin
      pos := pos;
    end;

    if (makeLookAhead) then
      if (lookAheadTest(ina, E_BASE256, pos, specialSymbols) <> E_BASE256) then
      begin
        k2 := k2 + 1; // fix 2.11.2005
        break;
      end;
  end;

  { return current position }
  initial := k2;

  outa[tmpInitCount] := LATCH_BASE256;
  tmpInitCount := tmpInitCount + 1;

  if (count < 250) then
  begin
    outa[tmpInitCount] := random255(count, tmpInitCount + 1);
    tmpInitCount := tmpInitCount + 1;
  end
  else
  begin
    outa[tmpInitCount] := random255(249 + ((longi - (longi mod 250)) div 250), tmpInitCount + 1);
    tmpInitCount := tmpInitCount + 1;
    outa[tmpInitCount] := random255(longi mod 250, tmpInitCount + 1);
    tmpInitCount := tmpInitCount + 1;
  end;

  for k := 0 to count - 1 do
  begin
    outa[tmpInitCount] := random255(tmp[k], tmpInitCount + 1);
    tmpInitCount := tmpInitCount + 1;
  end;

  outInit := tmpInitCount;

  result := tmpInitCount;

end;

{ encode C40 }

function TDatamatrix.encodeC40(longi: Integer; var initial: Integer; ina: array of Integer; var outa: array of Integer; doTextEncoding: boolean; inititaLatch: boolean; onlyOneWord:
  boolean): Integer;
var
  count: Integer;
  countMod3: Integer;
  tmp: array[0..2] of Integer;
  charac: integer;
  specialSymbolsTMP: array[0..10] of string;
  tmpS: string;
  code: array[0..3] of Integer;
  k: Integer;
  h: Integer;
  i: Integer;
  t: Integer;
  encodedASCII: array[0..1] of Integer;
  toencode: array of Integer;
  asciiLen: Integer;
begin

  count := 0;
  countMod3 := 0;
  tmp[0] := 0;
  tmp[1] := 0;
  tmp[2] := 0;

  { with c40 and text we do not encode special symbols }
  for i := 0 to length(specialSymbolsTMP) - 1 do
    specialSymbolsTMP[i] := '';

  if (inititaLatch) then
  begin
    if (doTextEncoding) then
    begin
      outa[count] := LATCH_TEXT;
      count := count + 1;
    end
    else
    begin
      outa[count] := LATCH_C40;
      count := count + 1;
    end;
  end;

  for k := initial to longi - 1 do
  begin

    charac := ina[k];

    { if do text encoding, swith Upper and Lowercase }
    if (doTextEncoding) then
    begin
      tmpS := '' + chr(charac);
      if ((charac >= ord('a')) and (charac <= ord('z'))) then
        tmpS := UpperCase(tmpS); { if it is lower, convert to upper }
      if ((charac >= ord('A')) and (charac <= ord('Z'))) then
        tmpS := LowerCase(tmpS); { if it is upper, convert to lower }
      charac := ord(tmpS[1]);
    end;

    code[0] := C40Codes[charac][0];
    code[1] := C40Codes[charac][1];
    code[2] := C40Codes[charac][2];
    code[3] := C40Codes[charac][3];

    for h := 0 to 3 do
    begin

      if (code[h] = -1) then
        break;

      tmp[countMod3] := code[h];
      countMod3 := countMod3 + 1;

      { one codeword completed }
      if (countMod3 = 3) then
      begin
        t := tmp[0] * 1600 + tmp[1] * 40 + tmp[2] + 1;
        outa[count] := t div 256;
        count := count + 1;
        outa[count] := t mod 256;
        count := count + 1;
        countMod3 := 0;
      end;
    end;

    if ((onlyOneWord) and (countMod3 = 0)) then
    begin
      C49rest := countMod3;
      initial := k + 1;

      if (initial = longi) then
      begin
        outa[count] := UNLATCH;
        count := count + 1;
      end;

      result := count;
      exit;
    end;

  end;

  initial := longi;

  if (countMod3 > 0) then
  begin

    if (countMod3 = 2) then
    begin
      { use C40 PAD, 0 as third value }
      t := tmp[0] * 1600 + tmp[1] * 40 + C40_PAD + 1;
      outa[count] := t div 256;
      count := count + 1;
      outa[count] := t mod 256;
      count := count + 1;
      outa[count] := UNLATCH;
      count := count + 1;
    end;

    if (countMod3 = 1) then
    begin

      { unlatch to ASCII }
      outa[count] := UNLATCH;
      count := count + 1;

      { encode last char as ASCII }
      setLength(toencode, countMod3);
      for h := 0 to countMod3 - 1 do
        toencode[h] := ina[longi - (countMod3 - h)];

      asciiLen := encodeAscii(countMod3, toencode, encodedASCII, specialSymbolsTMP);

      for h := 0 to asciiLen - 1 do
      begin
        outa[count] := encodedASCII[h]; { character }
        count := count + 1;
      end;

    end;

  end
  else
  begin
    outa[count] := UNLATCH;
    count := count + 1;
  end;

  C49rest := countMod3;

  result := count;
end;

{ 253 randomizing algorithm for PAD characters }

function TDatamatrix.random253(code: Integer; position: Integer): Integer;
var
  random: Integer;
  tmp: Integer;
begin
  random := (149 * position) mod 253;
  random := random + 1;

  tmp := code + random;

  if (tmp <= 254) then
    result := tmp
  else
    result := tmp - 254;

end;

function TDatamatrix.applyTilde(code: string; specialSymbol: array of string): string;
var
  i: Integer;
  c: Integer;
  longi: Integer;
  nextc: Integer;
  eciString: string;
  eci: Integer;
  c1: Integer;
  c2: Integer;
  c3: Integer;
  ascString: string;
  asc: Integer;
  valCode: Integer;
begin

  longi := Length(code);
  result := '';

  i := 0;
  while i < longi do
  begin

    c := ord(code[i + 1]);

    if (c = ord('~')) then
    begin
      { process special cases }

      if (i < (longi - 1)) then
      begin
        i := i + 1; // bug fixed 02.10.2003

        nextc := ord(code[i + 1]);

        { comes a char <= 26}

        if ((nextc >= 64) and (nextc <= (64 + 26))) then
        begin
          i := i + 1;
          result := result + chr(nextc - 64);
        end;

        { 2 }
        if (nextc = ord('~')) then
        begin
          result := result + '~';
          i := i + 1;
        end;

        { 1    }
        if (nextc = ord('1')) then
        begin
          if ((Length(result) = 0) or (Length(result) = 1) or (Length(result) = 4) or (Length(result) = 5)) then
          begin { first or second position}
            specialSymbol[Length(result)] := ' ';
            result := result + chr(FNC1);
          end
          else
            result := result + chr(29); { transmit as separator}

          i := i + 1;
        end;

        { 2 }
        if (nextc = ord('2')) then
          if (i < (longi - 4)) then
          begin
            { add symbol secuence and file identifier ( the next 3 codewords)}
            specialSymbol[Length(result)] := '' + code[i + 2] + code[i + 3] + code[i + 4];
            result := result + chr(STRUCTURED_APPEND);
            i := i + 4;
          end;

        { 3 }
        if ((nextc = ord('3')) and (Length(result) = 0)) then
        begin
          specialSymbol[Length(result)] := ' ';
          result := result + chr(READER_PROGRAMMING);
          i := i + 1;
        end;

        { 5 }
        if ((nextc = ord('5')) and (Length(result) = 0)) then
        begin
          specialSymbol[Length(result)] := ' ';
          result := result + chr(MACRO5);
          i := i + 1;
        end;

        {  6   }
        if ((nextc = ord('6')) and (length(result) = 0)) then
        begin
          specialSymbol[Length(Result)] := '';
          result := result + chr(MACRO6);
          i := i + 1;
        end;

        { 7 }
        if (nextc = ord('7')) then
          if (i < (longi - 7)) then
          begin
            eciString := copy(code, i + 2, 6);

            val(eciString, eci, valCode);

            if (eci <= 126) then
            begin
              specialSymbol[Length(Result)] := '' + chr(eci + 1);
              result := result + chr(ECI);

            end;

            if ((eci >= 127) and (eci <= 16382)) then
            begin
              c1 := ((eci - 127) div 254) + 128;
              c2 := ((eci - 127) mod 254) + 1;

              specialSymbol[Length(Result)] := '' + chr(c1) + chr(c2);
              result := result + chr(ECI);
            end;

            if (eci >= 16383) then
            begin
              c1 := ((eci - 16383) div 64516) + 192;
              c2 := ((eci - 16383) div 254);
              c2 := (c2 mod 254) + 1;
              c3 := ((eci - 16383) mod 254) + 1;

              specialSymbol[Length(Result)] := '' + chr(c1) + chr(c2) + chr(c3);
              result := result + chr(ECI);
            end;

            i := i + 7;

          end;

        { dNNN }
        if (nextc = ord('d')) then
          if (i < (longi - 3)) then
          begin
            ascString := copy(code, i + 2, 3);

            val(ascString, asc, valCode);

            if (asc > 255) then
              asc := 255;

            { the ascii value    }
            result := result + chr(asc);

            i := i + 4;
          end;

      end;

      i := i - 1;

    end {~}
    else
      { no escape }
      result := result + chr(c);

    i := i + 1;
  end; // while

end;

{draw barcode }

procedure TDatamatrix.drawBarcode(codeStr: array of Integer; specialSymbols: array of string);
var
  encoded: array[0..4999] of Integer;
  dummy: Integer;
  dummy2: Integer;
  encodedLength: Integer;
  i: Integer;
  config: Integer;
  blocks: array[0..9, 0..254] of Integer;
  h: Integer;
  firstPad: boolean;
  tmp: Integer;
  tmpcol: Integer;
  blocksLen: array[0..9] of Integer;
  totalLen: Integer;
  tmpReedData: Integer;
  finalBlock: array of Integer;
  c: Integer;
  j: Integer;

begin

  { encode as desired }
  encodedLength := 0;
  dummy := 0;
  dummy2 := 0;

  if (encoding <> E_AUTO) then
    FCurrentEncoding := encoding;
  if (encoding = E_AUTO) then
    encodedLength := encodeAuto(length(codeStr), codeStr, encoded, specialSymbols);
  if (encoding = E_ASCII) then
    encodedLength := encodeAscii(length(codeStr), codeStr, encoded, specialSymbols);
  if (encoding = E_C40) then
    encodedLength := encodeC40(length(codeStr), dummy, codeStr, encoded, false, true, false);
  if (encoding = E_TEXT) then
    encodedLength := encodeC40(length(codeStr), dummy, codeStr, encoded, true, true, false);
  if (encoding = E_BASE256) then
    encodedLength := encodeBase256(length(codeStr), dummy, codeStr, dummy2, encoded, false, specialSymbols);
  if (encoding = E_NONE) then
  begin
    encodedLength := length(codeStr);
    for i := 0 to encodedLength - 1 do
      encoded[i] := codeStr[i];
  end;

  { which configuration id appropiate? }
  i := 1;
  if (FPreferredFormat <> AUTO) then
  begin
    i := ord(FPreferredFormat);
    { if preferred is too small, then make auto }
    if (encodedLength > configuration[i][C_TOTALDATA]) then
      i := 1;
  end;

  while (encodedLength > configuration[i][C_TOTALDATA]) and (i <= 30) do
  begin
    if (FCurrentEncoding = E_C40) or (FCurrentEncoding = E_TEXT) then
    begin
      if ((C49rest = 1) and (encoded[encodedLength - 2] = UNLATCH) and (configuration[i][C_TOTALDATA] = (encodedLength - 1))) then
      begin
        encoded[encodedLength - 2] := encoded[encodedLength - 1];
        encoded[encodedLength - 1] := 0;
        encodedLength := encodedLength - 1;
        break;
      end;
      { remove last unlacht }
      if ((C49rest = 0) and (encoded[encodedLength - 1] = UNLATCH) and (configuration[i][C_TOTALDATA] = (encodedLength - 1))) then
      begin
        encoded[encodedLength - 1] := 0;
        encodedLength := encodedLength - 1;
        break;
      end;
    end;
    i := i + 1;
  end;

  if (i > 30) then
  begin
    { no configuration available}
    exit;
  end;

  config := i;
  { remember format used. The user might read it with getCalcukatedFormat() }
  FCalculatedFormat := AUTO;
  Inc(FCalculatedFormat, config);

  { read configuration }
  rows := configuration[config][C_ROW];
  cols := configuration[config][C_COL];
  datarows := configuration[config][C_ROWDATA];
  datacols := configuration[config][C_COLDATA];
  maprows := configuration[config][C_ROWMAP];
  mapcols := configuration[config][C_COLMAP];
  regions := configuration[config][C_REGIONS];
  totaldata := configuration[config][C_TOTALDATA];
  totalerr := configuration[config][C_TOTALERR];
  reeddata := configuration[config][C_REEDDATA];
  reederr := configuration[config][C_REEDERR];
  reedblocks := configuration[config][C_REEDBLOCKS];

  { remove last UNLATCH }
  if ((FCurrentEncoding = E_C40) or (FCurrentEncoding = E_TEXT)) then
    if ((C49rest = 0) and (encodedLength = totaldata) and (encoded[encodedLength - 1] = UNLATCH)) then
      encoded[encodedLength - 1] := 129;

  { do we need more than 1 reed solomon block}

  // pad encoded data
  firstPad := true;
  for h := encodedLength to totaldata - 1 do
  begin
    if (firstPad) then
      encoded[h] := PAD
    else
      { apply 253-state randomizin algorithm }
      encoded[h] := random253(PAD, h + 1);

    firstPad := false;
  end;

  {interleaved blocks }
  tmp := 0;
  tmpcol := 0;
  for h := 1 to totaldata do
  begin
    blocks[tmp][tmpcol] := encoded[h - 1];
    tmp := tmp + 1;
    if (tmp = reedblocks) then
    begin
      tmp := 0;
      tmpcol := tmpcol + 1;
    end;
  end;

  totalLen := 0;

  {calculate reedsol for each block}
  //K:=reeddata;
  for h := 0 to reedblocks - 1 do
  begin

    blocksLen[h] := reeddata + reederr;

    tmpReedData := reeddata;

    // special case 144
    if ((rows = 144) and (h > 7)) then
    begin
      blocksLen[h] := reeddata + reederr - 1;
      tmpReedData := 155;
    end;

    calcRS(blocks[h], tmpReedData, reederr);

    totalLen := totalLen + blocksLen[h];
  end;

  { mix interleaved blocks }
  setLength(finalBlock, totalLen);
  c := 0;
  for j := 0 to blocksLen[0] - 1 do
    for h := 0 to reedblocks - 1 do
      if (j < blocksLen[h]) then
      begin { this condition is for the special case 144}

        finalBlock[c] := blocks[h][j];
        c := c + 1;
      end;

  createBitmap(finalBlock);

end;

procedure TDatamatrix.debugMatrix(c: Integer; r: Integer);
var
  s: string;
  j1: Integer;
  i1: Integer;
begin

  s := '';
  write(s);
  write(s);
  write(s);
  for j1 := 0 to r - 1 do
  begin
    s := '';
    for i1 := 0 to c - 1 do
    begin

      if (FBitmap[i1][j1] <> 0) then

        s := s + 'X'

      else
        s := s + ' ';

    end;
    write(s);
  end;
  write('');
  write('');
end;

{ create bitmap of the code }

procedure TDatamatrix.createBitmap(codeStr: array of Integer);
var
  curx: Integer;
  cury: Integer;
  tmp: Integer;
  i: Integer;
  j: Integer;
  r: Integer;
  vertical: Integer;
  r2: Integer;
  c2: Integer;
  horizontal: Integer;
  bit: Integer;
  dot: Integer;
  character: Integer;
  c: Integer;
begin
  setLength(FBitmap, cols, rows);

  { draw side }
  curx := 0;
  cury := 0;
  if (regions = 2) then
  begin
    drawBorders(curx, cury, datacols + 2, datarows + 2);
    drawBorders(curx + datacols + 2, cury, datacols + 2, datarows + 2);
  end
  else
  begin

    tmp := trunc(sqrt(regions));
    for i := 0 to tmp - 1 do
      for j := 0 to tmp - 1 do
        drawBorders(curx + (i * (datacols + 2)), cury + (j * (datarows + 2)), datacols + 2, datarows + 2);

  end;

  { place bits }
  setLength(FCharPlacer_array, (mapcols + 10) * maprows);
  FCharPlacer_ncol := mapcols;
  FCharPlacer_nrow := maprows;
  CharPlacer_make();

  { move data from tmpMap (without pattern) to resuls (with patterns)}
  vertical := 1;
  for r := 0 to maprows - 1 do
  begin
    horizontal := 1;
    for c := 0 to mapcols - 1 do
    begin
      c2 := c + horizontal;
      r2 := r + vertical;

      if (FCharPlacer_array[(r * mapcols) + c] > 9) then
      begin
        character := (FCharPlacer_array[(r * mapcols) + c] div 10);
        //System.out.println("CC "+character );
        bit := FCharPlacer_array[(r * mapcols) + c] mod 10;
        dot := codeStr[character - 1] and (1 shl (8 - bit));

        FBitmap[c2][r2] := dot;
      end
      else
        FBitmap[c2][r2] := FCharPlacer_array[(r * mapcols) + c];

      if ((c > 0) and (((c + 1) mod datacols) = 0)) then
        horizontal := horizontal + 2;
    end;

    if ((r > 0) and (((r + 1) mod datarows) = 0)) then
      vertical := vertical + 2;

  end;

  //  debugMatrix(cols,rows);

end;

procedure TDatamatrix.drawBorders(x: Integer; y: Integer; w: Integer; h: Integer);
var
  alternative: Integer;
  i: Integer;
begin
  { draw borders of a region }

  // horizontal
  for i := 0 to w - 1 do
  begin

    if ((i mod 2) = 0) then
      alternative := 1
    else
      alternative := 0;

    FBitmap[x + i][y + h - 1] := 1;
    FBitmap[x + i][y] := alternative;
  end;

  { vertical }
  for i := 0 to h - 1 do
  begin

    if (((i + 1) mod 2) = 0) then
      alternative := 1
    else
      alternative := 0;

    FBitmap[x][y + i] := 1;
    FBitmap[x + w - 1][y + i] := alternative;
  end;

end;

{ encode as ascii }

function TDatamatrix.encodeAscii(longi: Integer; ina: array of Integer; var outa: array of Integer; var specialSymbols: array of string): Integer;
var
  outp: Integer;
  done: boolean;
  j: Integer;
  tmp: Integer;
  l: Integer;
begin
  outp := 0;

  j := 0;
  while j < longi do
  begin

    done := false;
    if (j < (longi - 1)) then
    begin
      { two consecutive digits }
      if ((ina[j] >= 48) and (ina[j] <= 57) and (ina[j + 1] >= 48) and (ina[j + 1] <= 57) and (j < longi)) then
      begin
        tmp := (ina[j] - 48) * 10 + (ina[j + 1] - 48);
        outa[outp] := 130 + tmp;
        outp := outp + 1;
        j := j + 1;
        done := true;
      end;
    end;

    { encode special symbols }
    if (not done) then
      if (specialSymbols[j] <> '') then
      begin

        { special symbol without parameters }
        if ((ina[j] = READER_PROGRAMMING) or (ina[j] = MACRO6) or (ina[j] = MACRO5) or (ina[j] = FNC1)) then
        begin
          outa[outp] := ina[j];
          outp := outp + 1;
          done := true;
        end;

        { special symbol with parameters}
        if ((ina[j] = STRUCTURED_APPEND) or (ina[j] = ECI)) then
        begin
          outa[outp] := ina[j];
          outp := outp + 1;
          for l := 0 to Length(specialSymbols[j]) - 1 do
          begin
            outa[outp] := ord(specialSymbols[j][1]);
            outp := outp + 1;
          end;
          done := true;
        end;

      end;

    { ascii }
    if (not done) then
    begin
      if (ina[j] < 128) then
      begin
        outa[outp] := ina[j] + 1;
        outp := outp + 1;
      end
      else
      begin { extended ascii }
        outa[outp] := SHIFT;
        outp := outp + 1;
        outa[outp] := (ina[j] - 128) + 1;
        outp := outp + 1;
      end;
    end; {doPair}

    j := j + 1;
  end; { while }

  result := outp;
end;

{paint a dot}

procedure TDatamatrix.paintDot(canvas: TCanvas; x: Integer; y: Integer; w: Integer; col: TColor);
var
  a, b, c, d: TPoint;
  //brush:TBrush;
begin

  canvas.pen.width := 1;
  canvas.pen.Color := col;
  canvas.brush.color := col;
  canvas.brush.style := bsSolid;
  //canvas.Brush:=brush;
  a.x := x;
  a.y := y;
  b.x := x + w - 1;
  b.y := y;
  c.x := x + w - 1;
  c.y := y + w - 1;
  d.x := x;
  d.y := y + w - 1;
  canvas.polygon([a, b, c, d]);

end;

procedure TDatamatrix.fillRect(canvas: TCanvas; x: integer; y: integer; w: integer; h: integer);
var
  a, b, c, d: TPoint;
begin
  canvas.pen.width := 1;
  canvas.brush.style := bsSolid;
  a.x := x;
  a.y := y;
  b.x := x + w;
  b.y := y;
  c.x := x + w;
  c.y := y + h;
  d.x := x;
  d.y := y + h;
  canvas.polygon([a, b, c, d]);
end;

{ paints the barcode in the specified graphic context }

procedure TDatamatrix.paintBarcode(canvas: TCanvas);
var
  x: Integer;
  y: Integer;
  i: Integer;
  j: Integer;
begin

  if (FreBuild) then
    doCode();

  {no canvas, exit}
  if (canvas = nil) then
    exit;

  { paint in the graphics context}
  x := Fmargin + FOffsetX;
  y := Fmargin + FOffsetY;

  { background color}
  canvas.pen.Color := backColor;
  canvas.Brush.Color := backColor;
  //fillRect(canvas,canvas.Cliprect.left,canvas.Cliprect.top,canvas.Cliprect.Right,canvas.Cliprect.bottom);
  fillRect(canvas, FOffsetX, FOffsetY, FOffsetX + width, FOffsetY + height);

  for j := 0 to rows - 1 do
    for i := 0 to cols - 1 do
      if Fbitmap[i, j] <> 0 then
        paintDot(canvas, x + (FPixelsDot * i), y + (FPixelsdot * j), FPixelsdot, FbarColor)
      else
        paintDot(canvas, x + (FPixelsdot * i), y + (FPixelsdot * j), FPixelsdot, FbackColor);

  FcurrentX := (FPixelsdot * cols) + Fmargin + FoffsetX;
  FcurrentY := (FPixelsdot * rows) + Fmargin + FoffsetY;

  {DEMO}
  canvas.Brush.Color := backColor;
  canvas.Pen.Color := clRed;

  //       if (random(256)<50) then         canvas.TextOut(margin,FCurrentY div 2,'TRIAL VERSION');

end;

procedure TDatamatrix.doCode();
var
  specialSymbol: array of string;
  c: array of Integer;
  i: Integer;
begin

  FreBuild := false;

  //  if (FBinaryCode=null) then begin

  FinternalCode := Fcode;
  setLength(specialSymbol, 5000);

  if (FProcessTilde) then
    FInternalCode := applyTilde(FCode, specialSymbol);

  if (Length(FInternalCode) = 0) then
    exit;

  setLength(c, Length(FInternalCode));

  for i := 0 to length(FInternalCode) - 1 do
    c[i] := ord(FInternalCode[i + 1]);

  {            end ;
       else
            begin
                setLength(specialSymbol,length(FBinaryCode));

                setLength(c,Length(FBinaryCode));

                for i:=0 to length(FBinaryCode)-1 do
                    c[i]:=ord(FBinaryCode[i+1]);

            end;      }

  drawBarcode(c, specialSymbol);
end;

{ CHAR PLACER METHODS }

    { "utah" places the 8 bits of a utah-shaped symbol character in ECC200 }

procedure TDatamatrix.utah(row: integer; col: integer; charac: integer);
begin
  module(row - 2, col - 2, charac, 1);
  module(row - 2, col - 1, charac, 2);
  module(row - 1, col - 2, charac, 3);
  module(row - 1, col - 1, charac, 4);
  module(row - 1, col, charac, 5);
  module(row, col - 2, charac, 6);
  module(row, col - 1, charac, 7);
  module(row, col, charac, 8);
end;

{ "cornerN" places 8 bits of the four special corner cases in ECC200 }

procedure TDatamatrix.corner1(charac: Integer);
begin
  module(FCharPlacer_nrow - 1, 0, charac, 1);
  module(FCharPlacer_nrow - 1, 1, charac, 2);
  module(FCharPlacer_nrow - 1, 2, charac, 3);
  module(0, FCharPlacer_ncol - 2, charac, 4);
  module(0, FCharPlacer_ncol - 1, charac, 5);
  module(1, FCharPlacer_ncol - 1, charac, 6);
  module(2, FCharPlacer_ncol - 1, charac, 7);
  module(3, FCharPlacer_ncol - 1, charac, 8);

end;

procedure TDatamatrix.corner2(charac: Integer);
begin

  module(FCharPlacer_nrow - 3, 0, charac, 1);
  module(FCharPlacer_nrow - 2, 0, charac, 2);
  module(FCharPlacer_nrow - 1, 0, charac, 3);
  module(0, FCharPlacer_ncol - 4, charac, 4);
  module(0, FCharPlacer_ncol - 3, charac, 5);
  module(0, FCharPlacer_ncol - 2, charac, 6);
  module(0, FCharPlacer_ncol - 1, charac, 7);
  module(1, FCharPlacer_ncol - 1, charac, 8);

end;

procedure TDatamatrix.corner3(charac: Integer);
begin

  module(FCharPlacer_nrow - 3, 0, charac, 1);
  module(FCharPlacer_nrow - 2, 0, charac, 2);
  module(FCharPlacer_nrow - 1, 0, charac, 3);
  module(0, FCharPlacer_ncol - 2, charac, 4);
  module(0, FCharPlacer_ncol - 1, charac, 5);
  module(1, FCharPlacer_ncol - 1, charac, 6);
  module(2, FCharPlacer_ncol - 1, charac, 7);
  module(3, FCharPlacer_ncol - 1, charac, 8);

end;

procedure TDatamatrix.corner4(charac: Integer);
begin

  module(FCharPlacer_nrow - 1, 0, charac, 1);
  module(FCharPlacer_nrow - 1, FCharPlacer_ncol - 1, charac, 2);
  module(0, FCharPlacer_ncol - 3, charac, 3);
  module(0, FCharPlacer_ncol - 2, charac, 4);
  module(0, FCharPlacer_ncol - 1, charac, 5);
  module(1, FCharPlacer_ncol - 3, charac, 6);
  module(1, FCharPlacer_ncol - 2, charac, 7);
  module(1, FCharPlacer_ncol - 1, charac, 8);

end;

{ "ecc200" fills an nrow x ncol array with appropriate values for ECC200 }

procedure TDatamatrix.CharPlacer_make();
var
  charac: Integer;
  row: Integer;
  col: Integer;
  r: Integer;
  c: Integer;
begin
  { Starting in the correct location for character #1, bit 8,... }
  charac := 1;
  row := 4;
  col := 0;

  { First, fill the array[] with invalid entries }
  for r := 0 to FCharPlacer_nrow - 1 do
    for c := 0 to FCharPlacer_ncol - 1 do
      FCharPlacer_array[r * FCharPlacer_ncol + c] := 0;

  repeat

    { repeatedly first check for one of the special corner cases, then... }
    if ((row = FCharPlacer_nrow) and (col = 0)) then
    begin
      corner1(charac);
      charac := charac + 1;
    end;
    if ((row = FCharPlacer_nrow - 2) and (col = 0) and (FCharPlacer_ncol mod 4 <> 0)) then
    begin
      corner2(charac);
      charac := charac + 1;
    end;
    if ((row = FCharPlacer_nrow - 2) and (col = 0) and (FCharPlacer_ncol mod 8 = 4)) then
    begin
      corner3(charac);
      charac := charac + 1;
    end;
    if ((row = FCharPlacer_nrow + 4) and (col = 2) and (FCharPlacer_ncol mod 8 = 0)) then
    begin
      corner4(charac);
      charac := charac + 1;
    end;

    repeat
      { sweep upward diagonally, inserting successive characters,... }

      if ((row < FCharPlacer_nrow) and (col >= 0)) then
        if (FCharPlacer_array[row * FCharPlacer_ncol + col] = 0) then
        begin
          utah(row, col, charac);
          charac := charac + 1;
        end;
      row := row - 2;
      col := col + 2;

    until not ((row >= 0) and (col < FCharPlacer_ncol));

    row := row + 1;
    col := col + 3;
    { & then sweep downward diagonally, inserting successive characters,... }
    repeat
      if ((row >= 0) and (col < FCharPlacer_ncol)) then
        if (FCharPlacer_array[row * FCharPlacer_ncol + col] = 0) then
        begin
          utah(row, col, charac);
          charac := charac + 1;
        end;
      row := row + 2;
      col := col - 2;

    until not ((row < FCharPlacer_nrow) and (col >= 0));
    row := row + 3;
    col := col + 1;

    { ... until the entire array is scanned }
  until not ((row < FCharPlacer_nrow) or (col < FCharPlacer_ncol));

  { Lastly, if the lower righthand corner is untouched, fill in fixed pattern }
  if (FCharPlacer_array[FCharPlacer_nrow * FCharPlacer_ncol - 1] = 0) then
  begin
    FCharPlacer_array[FCharPlacer_nrow * FCharPlacer_ncol - 1] := 1;
    FCharPlacer_array[FCharPlacer_nrow * FCharPlacer_ncol - FCharPlacer_ncol - 2] := 1;
  end;

end;

{ "module" places "chr+bit" with appropriate wrapping within array[] }

procedure TDatamatrix.module(r: Integer; c: Integer; charac: Integer; bit: Integer);
begin

  if (r < 0) then
  begin
    r := r + FCharPlacer_nrow;
    c := c + 4 - ((FCharPlacer_nrow + 4) mod 8);
  end;

  if (c < 0) then
  begin
    c := c + FCharPlacer_ncol;
    r := r + 4 - ((FCharPlacer_ncol + 4) mod 8);
  end;

  FCharPlacer_array[r * FCharPlacer_ncol + c] := 10 * charac + bit;

end;

procedure Register;
begin
  //     RegisterComponents('Barcodes', [TDatamatrix]);
end;

constructor TDatamatrix.Create(Owner: TComponent);
begin
  inherited Create(Owner); { always call the inherited constructor }
  //MessageDlg('RDatamatrix for Delphi. Trial Version.', mtInformation, [mbOk], 0);
  FPixelsDot := 4;
  FMargin := 30;
  FProcessTilde := false;
  FReBuild := true;
  FInternalCode := '';
  FCode := 'This is a test of the barcode DataMatrix';
  FCurrentEncoding := E_ASCII;
  C49Rest := 0;
  FCalculatedFormat := AUTO;
  FEncoding := E_ASCII;
  FPreferredFormat := AUTO;
  FBarColor := clBlack;
  FBackColor := clWhite;
  height := 200;
  width := 200;
  FOffsetX := 0;
  FOffsetY := 0;
  FAutoFit := true;

end;

end.

