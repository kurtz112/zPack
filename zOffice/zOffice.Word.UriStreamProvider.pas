unit zOffice.Word.UriStreamProvider;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Vcl.Forms,
  Data.DB,
  dxRichEdit.Utils.UriStreamService,
  dxThreading,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TImageStream = class(TCollectionItem)
  private
    FStream: TStream;
    FUri: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property Uri: string read FUri write FUri;
    property Stream: TStream read FStream;
  end;

  TImages = class(TCollection)
  private
    function IndexOf(const Uri: string): integer;
  public
    procedure AddImageStream(Uri: string; Stream: TStream);
    function Get(const Uri: string; const DestStream: TStream): Boolean;
  end;

  TImageUriStreamProvider = class(TInterfacedObject, IdxUriStreamProvider)
  private
    FGetImageFunc: TFunc<string, TStream>;
    Images: TImages;
  protected
    function IsAsyncLoadingSupported(const aUri: string): Boolean;
    function AsyncGetStream(const aUri: string; ATimeout: Cardinal; const ACancelStatus: TdxTaskCancelCallback): TStream;
    function GetStream(const aUri: string; ATimeout: Cardinal): TStream;
    function IsRemote(const aUri: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearImages;

    procedure AddImageStream(Uri: string; Stream: TStream);
    procedure AddImage(Uri: string; DataSet: TDataSet; const FieldName: string); overload;
    procedure AddImage(Uri: string; Field: TField); overload;
    procedure AddImages(DataSet: TDataSet);

    property GetImageFunc: TFunc<string, TStream> read FGetImageFunc write FGetImageFunc;
  end;

implementation

uses
  dxUriRecord,
  dxWinInet,
  dxRichEdit.Utils.OfficeImage,
  zOffice.Grafici,
  zOffice.Word.Utils;

{ TImageStream }

constructor TImageStream.Create(Collection: TCollection);
begin
  inherited;
  FUri := '';
  FStream := TMemoryStream.Create;
end;

destructor TImageStream.Destroy;
begin
  FreeAndNil(FStream);
  inherited;
end;

{ TImages }

procedure TImages.AddImageStream(Uri: string; Stream: TStream);
var
  idx: integer;
  item: TImageStream;
begin
  idx := IndexOf(Uri);

  if idx = -1 then
    item := TImageStream(inherited Add)
  else
    item := TImageStream(Items[idx]);

  item.Uri := Uri;

  Stream.Position := 0;
  TMemoryStream(item.Stream).Clear;
  item.Stream.CopyFrom(Stream);
  item.Stream.Position := 0;
end;

function TImages.IndexOf(const Uri: string): integer;
var
  i: integer;
  item: TImageStream;
begin
  Result := -1;

  for i := 0 to Count - 1 do
  begin
    item := TImageStream(Items[i]);

    if sameText(Uri, item.Uri) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TImages.Get(const Uri: string; const DestStream: TStream): Boolean;
var
  idx: integer;
  item: TImageStream;
begin
  SiMain.LogVerbose(Uri);

  Result := false;

  idx := IndexOf(Uri);

  Result := idx <> -1;

  if Result then
  begin
    item := TImageStream(Items[idx]);
    item.Stream.Position := 0;
    DestStream.CopyFrom(item.Stream);
    DestStream.Position := 0;
    Result := true;
  end;
end;

{ TImageUriStreamProvider }

procedure TImageUriStreamProvider.AddImageStream(Uri: string; Stream: TStream);
begin
  Images.AddImageStream(Uri, Stream);
end;

constructor TImageUriStreamProvider.Create;
begin
  inherited Create;
  FGetImageFunc := nil;
  Images := TImages.Create(TImageStream);
end;

destructor TImageUriStreamProvider.Destroy;
begin
  FreeAndNil(Images);
  inherited Destroy;
end;

procedure TImageUriStreamProvider.AddImage(Uri: string; DataSet: TDataSet; const FieldName: string);
var
  Field: TField;
begin
  assert(assigned(DataSet));

  Field := DataSet.FindField(FieldName);

  if not assigned(Field) then
    exit;

  AddImage(Uri, Field);
end;

procedure TImageUriStreamProvider.AddImage(Uri: string; Field: TField);
var
  Stream: TMemoryStream;
  PageWidth: single;
begin

  if not assigned(Field) then
    exit;

  if Field.IsNull then
    exit;

  Stream := TMemoryStream.Create;
  try
    TBlobField(Field).SaveToStream(Stream);
    AddImageStream('dbimg://' + Uri, Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TImageUriStreamProvider.AddImages(DataSet: TDataSet);
var
  i: integer;
  Field: TField;
begin

  if not assigned(DataSet) then
    exit;

  // for Field in DataSet.Fields do
  for i := 0 to DataSet.Fields.Count - 1 do
  begin
    Field := DataSet.Fields[i];

    if Field is TBlobField then
      if Field.DataType = ftGraphic then
        Self.AddImage(Field.FieldName, Field);

    Field := nil;
  end;
end;

function TImageUriStreamProvider.AsyncGetStream(const aUri: string; ATimeout: Cardinal; const ACancelStatus: TdxTaskCancelCallback): TStream;

  function IsCancel: Boolean;
  begin
    Result := assigned(ACancelStatus) and ACancelStatus;
  end;

var
  AUriRecord: TdxUri;
  AFile: string;
begin
  Result := nil;

  AUriRecord := TdxUri.Create(aUri);

  if AUriRecord.IsWebScheme then
  begin
    try
      if IsCancel then
        exit;

      Result := TMemoryStream.Create;
      AFile := AUriRecord.Uri;

      if TdxHttpHelper.GetStream(Application.Title, AFile, '', Result, nil, ATimeout) and not IsCancel and TdxImageLoaderHelper.IsImageStream(Result) then
        Result.Position := 0
      else
        FreeAndNil(Result);
    except
      FreeAndNil(Result);
    end;
  end;
end;

procedure TImageUriStreamProvider.ClearImages;
begin
  Images.Clear;
end;

function TImageUriStreamProvider.IsAsyncLoadingSupported(const aUri: string): Boolean;
begin
  Result := IsRemote(aUri);
end;

function TImageUriStreamProvider.GetStream(const aUri: string; ATimeout: Cardinal): TStream;
var
  Uri: string;
begin
  SiMain.EnterMethod(Self, 'GetStream');
  SiMain.LogString('Uri', aUri);

  Result := nil;

  Uri := aUri;

  if IsRemote(aUri) then
  begin
    SiMain.LogVerbose('RemoteStream');
    // webp al momento non supportato
    Result := AsyncGetStream(aUri, ATimeout, nil);
  end
  else
  begin
    // via il suffisso @L:A (o @hidden) prima di risolvere l'immagine
    Uri := TImageSizeTag.Strip(Uri);

    // chart://Nome: immagine di un grafico TzDbChart aperto (zOffice.Grafici).
    // La misura del campo (@L:A) la applica poi TzWordImmagini.ApplicaMisure
    Result := TzRegistroGrafici.ImmagineDaRiferimento(Uri);

    if (not assigned(Result)) and assigned(FGetImageFunc) then
      Result := GetImageFunc(Uri.Replace('dbimg://', '', [rfIgnoreCase]));

    if assigned(Result) then
    begin
      Result.Position := 0;
      exit;
    end
    else
    begin
      System.TMonitor.Enter(Images);
      try
        Result := TMemoryStream.Create;
        Images.Get(Uri, Result);
        Result.Position := 0
      finally
        System.TMonitor.exit(Images);
      end;
    end;
  end;
  SiMain.LeaveMethod(Self, 'GetStream');
end;

function TImageUriStreamProvider.IsRemote(const aUri: string): Boolean;
begin
  Result := aUri.StartsWith('http');
end;

end.
