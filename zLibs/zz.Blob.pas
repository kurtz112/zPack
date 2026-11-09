unit zz.Blob;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.TypInfo,
  System.RTTI,
  System.Variants,
  Data.Db;

type
  TBlobKind = (bkStrings, bkImage);

  TCustomBlob = class abstract(TPersistent) // (TInterfacedPersistent, IStreamPersist)
  protected
    procedure doLoadFromField(Field: TField); virtual; abstract;
    procedure doStoreToField(Field: TField); virtual; abstract;
  public
    function BlobKind: TBlobKind; virtual; abstract;
    function IsNull: boolean; virtual; abstract;
    function IsEmpty: boolean;
    procedure Clear; virtual; abstract;
    procedure LoadFromFile(const FileName: string); virtual; abstract;
    procedure SaveToFile(const FileName: string); virtual; abstract;

    procedure LoadFromField(Field: TField);
    procedure StoreToField(Field: TField);
  end;

  TBlobStrings = class(TCustomBlob)
  private
    FStrings: TStrings;
    function GetText: String;
    procedure SetStrings(const Value: TStrings);
    procedure SetText(const Value: String);
  protected
    procedure doLoadFromField(Field: TField); override;
    procedure doStoreToField(Field: TField); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function BlobKind: TBlobKind; override;
    function IsNull: boolean; override;
    procedure Clear; override;

    procedure LoadFromFile(const FileName: string); override;
    procedure SaveToFile(const FileName: string); override;
  public
    property Strings: TStrings read FStrings write SetStrings;
    [NeonIgnore]
    property Text: String read GetText write SetText;
  end;

implementation

{ TCustomBlob }

function TCustomBlob.IsEmpty: boolean;
begin
  Result := IsNull;
end;

procedure TCustomBlob.LoadFromField(Field: TField);
begin
  Assert(Assigned(Field));

  if Field.IsNull then
    Clear
  else
    doLoadFromField(Field);
end;

procedure TCustomBlob.StoreToField(Field: TField);
begin
  Assert(Assigned(Field));

  if IsNull then
    Field.Clear
  else
    doStoreToField(Field);
end;

{ TBlobStrings }

constructor TBlobStrings.Create;
begin
  inherited;
  FStrings := TStringList.Create;
end;

destructor TBlobStrings.Destroy;
begin
  FreeAndNil(FStrings);
  inherited;
end;

procedure TBlobStrings.Assign(Source: TPersistent);
begin
  if Source = Self then // assegnazione da Neon
    exit
  else
    if Source is TBlobStrings then
      Strings.Assign(TBlobStrings(Source).Strings)
    else
      inherited;
end;

function TBlobStrings.BlobKind: TBlobKind;
begin
  Result := bkStrings;
end;

procedure TBlobStrings.Clear;
begin
  inherited;
  Strings.Clear;
end;

function TBlobStrings.IsNull: boolean;
begin
  Result := FStrings.Count = 0;
end;

procedure TBlobStrings.LoadFromFile(const FileName: string);
begin
  inherited;
  Strings.LoadFromFile(FileName);
end;

procedure TBlobStrings.SaveToFile(const FileName: string);
begin
  inherited;
  Strings.SaveToFile(FileName);
end;

procedure TBlobStrings.SetStrings(const Value: TStrings);
begin
  FStrings.Assign(Value);
end;

procedure TBlobStrings.doLoadFromField(Field: TField);
begin
  inherited;
  Strings.Text := Field.AsString;
end;

procedure TBlobStrings.doStoreToField(Field: TField);
begin
  inherited;
  Field.Assign(Strings);
end;

function TBlobStrings.GetText: String;
begin
  Result := Strings.Text;
end;

procedure TBlobStrings.SetText(const Value: String);
begin
  Strings.Text := Value;
end;

end.

  zz.Blob.vcl zz.Blob.fmx
