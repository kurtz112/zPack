unit zLocalizer.storage;

interface

uses
  System.SysUtils,
  System.Classes,
  AbZipKit;

type
  TzLocalizerStorage = class(TObject)
  private
    FZipFileName: string;
    AbZipKit: TAbZipKit;
    procedure SetZipFileName(const Value: string);
  private
  public
    constructor Create;
    destructor Destroy; override;
    //
    property ZipFileName: string read FZipFileName write SetZipFileName stored false;
  public
    function FileExists(Const FileName: string): Boolean;
    procedure GetFileNames(const Folder, Ext: string; Files: TStrings);

    procedure SaveStrings(Strings: TStrings; FileName: string = '');
    procedure LoadStrings(Strings: TStrings; FileName: string = '');

    procedure RenameFile(const OldFileName, NewFileName: string);
    procedure DeleteFile(const FileName: string);
  end;

implementation

uses
  AbUtils,
  AbBase,
  AbBrowse,
  AbZBrows,
  AbZipper,
  AbZipTyp,
  AbArcTyp;

constructor TzLocalizerStorage.Create;
begin
  inherited Create;
  FZipFileName := '';
  AbZipKit := TAbZipKit.Create(nil);
  AbZipKit.Name := 'AbZipKit';
  AbZipKit.AutoSave := false;
  // AbZipKit.DeflationOption := doSuperFast;
  AbZipKit.DeflationOption := doNormal;
  AbZipKit.DOSMode := false;
  AbZipKit.ExtractOptions := [];
  AbZipKit.ForceType := True;
  AbZipKit.ArchiveType := atZip;
end;

procedure TzLocalizerStorage.DeleteFile(const FileName: string);
begin
  AbZipKit.DeleteFiles(FileName);
end;

destructor TzLocalizerStorage.Destroy;
begin
  AbZipKit.CloseArchive;
  AbZipKit.FileName := '';
  FreeAndNil(AbZipKit);
  inherited;
end;

procedure TzLocalizerStorage.GetFileNames(const Folder, Ext: string; Files:
    TStrings);
var
  i: Integer;
  Item: TAbArchiveItem;
  StoredPath: string;
begin
  assert(assigned(Files));

  Files.Clear;

  StoredPath := Folder;
  if StoredPath <> '' then
    StoredPath := IncludeTrailingBackslash(StoredPath);

  Files.BeginUpdate;
  try
    for i := 0 to AbZipKit.Count - 1 do
      if AbZipKit.Items[i].MatchesStoredName(StoredPath + '*' + Ext) then
        if not AbZipKit.Items[i].IsDirectory then
        begin
          Item := AbZipKit.Items[i];
          Files.Add(Item.FileName);
        end;
  finally
    Files.EndUpdate;
  end;
end;

function TzLocalizerStorage.FileExists(Const FileName: string): Boolean;
begin
  Result := AbZipKit.FindFile(FileName) > -1;
end;

procedure TzLocalizerStorage.LoadStrings(Strings: TStrings; FileName: string = '');
var
  Stream: TMemoryStream;
begin
  if AbZipKit.FindFile(FileName) = -1 then
    Exit;

  Stream := TMemoryStream.Create;
  try
    AbZipKit.ExtractToStream(FileName, Stream);
    Stream.Position := 0;
    try
      Strings.LoadFromStream(Stream);
    except
      on e: exception do
        ApplicationShowException(e);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TzLocalizerStorage.SaveStrings(Strings: TStrings; FileName: string = '');
var
  Stream: TMemoryStream;
begin
  AbZipKit.DeleteFiles(FileName);
  Stream := TMemoryStream.Create;
  try
    Strings.SaveToStream(Stream);
    AbZipKit.AddFromStream(FileName, Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TzLocalizerStorage.SetZipFileName(const Value: string);
begin
  if FZipFileName <> Value then
  begin
    FZipFileName := Value;
    AbZipKit.FileName := ZipFileName;
  end;
end;

procedure TzLocalizerStorage.RenameFile(const OldFileName, NewFileName: string);
var
  idx: Integer;
  Item: TAbArchiveItem;
begin
  idx := AbZipKit.FindFile(OldFileName);

  if idx = -1 then
    Exit;

  Item := AbZipKit.Items[idx];

  if AbZipKit.FindFile(NewFileName) > -1 then
    AbZipKit.DeleteFiles(NewFileName);

  AbZipKit.Move(Item, NewFileName);
end;

end.
