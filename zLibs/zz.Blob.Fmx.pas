unit zz.Blob.Fmx;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.TypInfo,
  System.RTTI,
  System.Variants,
  Data.DB,
  Fmx.Graphics,
  zz.Blob;

type
  TBlobImage = class(TCustomBlob)
  private
    FImage: TBitmap;
    procedure SetImage(const Value: TBitmap);
  protected
    procedure doLoadFromField(Field: TField); override;
    procedure doStoreToField(Field: TField); override;
  public
    constructor Create;
    destructor Destroy; override;

    function BlobKind: TBlobKind; override;
    function IsNull: boolean; override;
    procedure Clear; override;
    procedure LoadFromFile(const FileName: string); override;
    procedure SaveToFile(const FileName: string); override;

    property Image: TBitmap read FImage write SetImage;
  end;

implementation

{ TBlobImage }

constructor TBlobImage.Create;
begin
  inherited;
  FImage := TBitmap.Create;
end;

destructor TBlobImage.Destroy;
begin
  FreeAndNil(FImage);
  inherited;
end;

function TBlobImage.BlobKind: TBlobKind;
begin
  result := bkImage;
end;

procedure TBlobImage.SetImage(const Value: TBitmap);
begin
  FImage.Assign(Value);
end;

procedure TBlobImage.Clear;
begin
  inherited;
  Image.Assign(nil);
end;

function TBlobImage.IsNull: boolean;
begin
  result := Image.IsEmpty;
end;

procedure TBlobImage.doLoadFromField(Field: TField);
begin
  inherited;
  Image.Assign(Field);
end;

procedure TBlobImage.doStoreToField(Field: TField);
var
  Stream: TMemoryStream;
begin
  inherited;

  Field.Assign(Image);
  Exit;

  Stream := TMemoryStream.Create;
  try
    Image.SaveToStream(Stream);
    Stream.Position := 0;

    if Stream.Size <= 12 then
      Field.Clear
    else
      TBlobField(Field).LoadFromStream(Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TBlobImage.LoadFromFile(const FileName: string);
begin
  inherited;
  Image.LoadFromFile(FileName);
end;

procedure TBlobImage.SaveToFile(const FileName: string);
begin
  inherited;
  Image.SaveToFile(FileName);
end;

end.
