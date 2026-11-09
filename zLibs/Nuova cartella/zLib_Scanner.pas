unit zLib_Scanner;

interface

uses
  Graphics,
  EnDiGrph, { for TDibGraphic }
  Generics.Collections;

type
  TScanner = class
  private
    Images: TList < TDibGraphic > ;
    procedure ClearImages;
    procedure SaveImages(const DestFileName: string);
    procedure OnAcquire(const DibHandle: THandle; const XDpi, YDpi: Word; const CallBackData: Integer);
    function GetGraphic(const ImageNo: Integer; var FreeGraphic: Boolean): TGraphic;
  public
    constructor Create;
    destructor Destroy; override;
    function SelectScanner: Boolean;
    function Scannerizza(const DestFileName: string): Boolean;
  end;

function Scanner: TScanner;

implementation

uses
  SysUtils,
  Classes,
  Forms,

  Dialogs,
  EnMisc,
  EnScan, { for Scanner }

  EnTifGr, { for TTifGraphic }
  EnPdfGr; { for TPdfGraphic }

var
  _Scanner: TScanner;

function Scanner: TScanner;
begin
  if not Assigned(_Scanner) then
    _Scanner := TScanner.Create;
  result := _Scanner;
end;

function TScanner.SelectScanner: Boolean;
begin
  result := False;

  if EnScan.Scanner.IsConfigured then
    Result := EnScan.Scanner.SelectScanner
  else
  begin
    ShowMessage('Nessuno Scanner rilevato nel sistema.');
    Exit(False);
  end;
end;

procedure TScanner.SaveImages(const DestFileName: string);
var
  Stream: TFileStream;
  Graphic: TPdfGraphic;
begin
  if FileExists(DestFileName) then
    DeleteFile(DestFileName);

  if Images.Count = 0 then
    Exit;

  Stream := TFileStream.Create(DestFileName, fmCreate);
  try
    Graphic := TPdfGraphic.Create;
    try
      Graphic.MultiSaveToStream(Stream, Images.Count, GetGraphic);
    finally
      FreeAndNil(Graphic);
    end;
  finally
    FreeAndNil(Stream);
  end;
  ClearImages;
end;

function TScanner.Scannerizza(const DestFileName: string): Boolean;
begin
  Result := False;

  ClearImages;

  if not EnScan.Scanner.IsConfigured then
  begin
    ShowMessage('Nessuno Scanner rilevato nel sistema.');
    Exit(False);
  end;

  EnScan.Scanner.OpenSource;
  try
    EnScan.Scanner.AcquireWithSourceOpen(OnAcquire, 0);
  finally
    EnScan.Scanner.CloseSource;
  end;

  SaveImages(DestFileName);

  Result := True;
end;

procedure TScanner.ClearImages;
var
  Graphic: TDibGraphic;
  i: integer;
begin
  for i := Images.Count - 1 downto 0 do
  begin
    Graphic := Images[i];
    Images.Remove(Graphic);
    FreeAndNil(Graphic);
  end;
end;

constructor TScanner.Create;
begin
  Images := TList < TDibGraphic > .Create;
end;

destructor TScanner.Destroy;
begin
  ClearImages;
  FreeAndNil(Images);
  inherited;
end;

function TScanner.GetGraphic(const ImageNo: Integer; var FreeGraphic: Boolean): TGraphic;
begin
  Result := Images[ImageNo - 1];
end;

procedure TScanner.OnAcquire(const DibHandle: THandle;
  const XDpi: Word;
  const YDpi: Word;
  const CallBackData: LongInt);
var
  Graphic: TDibGraphic;
begin
  Graphic := TDibGraphic.Create;
  Graphic.AssignFromDIBHandle(DibHandle);
  Graphic.XDotsPerInch := XDpi;
  Graphic.YDotsPerInch := YDpi;
  Images.add(Graphic);
end;

initialization
  _Scanner := nil;
finalization
  FreeAndNil(_Scanner);
end.

