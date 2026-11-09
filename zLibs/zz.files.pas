unit zz.files;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TFileItemType = (ftNormal, ftCustom, ftShared, ftProc);

  TzFile = class(TCollectionItem)
  private
    FFileName: string;
    FFileType: TFileItemType;
    FFolder: string;
    FName: string;
    FProc: TProc<TzFile>;
    function GetCustom: Boolean;
    function GetExt: string;
    function GetFileNameNoExt: string;
    function GetFullFileName: string;
    function GetIsProc: Boolean;
    function GetShared: Boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Name: string read FName write FName;
    property FileName: string read FFileName;
    property Folder: string read FFolder;
    property FileType: TFileItemType read FFileType;
    property Ext: string read GetExt;
    property FileNameNoExt: string read GetFileNameNoExt;
    property FullFileName: string read GetFullFileName;
    property Proc: TProc<TzFile> read FProc write FProc;

    property Custom: Boolean read GetCustom;
    property Shared: Boolean read GetShared;
    property IsProc: Boolean read GetIsProc;
  end;

  TzFiles = class(TCollection)
  public
    // In sostanza il path dell'applicazione.
    class Var AppRoot: string;
    // L'azienda corrente..
    class Var CustomFolder: string;
    class Var SharedFolder: string;
  private type
    TFileListEnumerator = class
    private
      index: Integer;
      Collection: TzFiles;
    public
      constructor Create(ACollection: TzFiles);
      function GetCurrent: TzFile;
      function MoveNext: Boolean;
      property Current: TzFile read GetCurrent;
    end;
  public
    function GetEnumerator: TFileListEnumerator;
  strict private
    class constructor ClassCreate;
  private
    FClassFolder: string;
    function GetItem(index: Integer): TzFile;
    procedure SetItem(index: Integer; const Value: TzFile);
  public
    constructor Create(const aClassFolder: string);

    function FindFile(Name: string): TzFile;
    function IndexOf(Name: string): Integer;

    function Insert(index: Integer): TzFile;
    function Add: TzFile; overload;
    function Add(const Name: string; const FullFileName: string; FileType: TFileItemType; Proc: TProc<TzFile>): TzFile; overload;

    procedure AddFolder(const Folder: string; const FileExt: string; SharedFiles: TStrings = nil; const DoClear: Boolean = True; IsValidFile: TFunc < string, Boolean >= nil);

    procedure GetFileNames(List: TStrings; const RemoveFileExt: Boolean = false);

    property Items[Index: Integer]: TzFile read GetItem write SetItem; default;
    // reports, cubes,
    property ClassFolder: string read FClassFolder;
  public
    function GetFolder(const Folder: string; FileItemType: TFileItemType): string; overload;
    function GetFolder(const Folder: string; Custom: Boolean): string; overload;

    function GetFullFileName(const Name: string): string;
  end;

implementation

uses
  System.IOUtils;

constructor TzFile.Create(Collection: TCollection);
begin
  inherited;
  FName := '';
  FFileType := ftNormal;
  FFileName := '';
  FFolder := '';
  FProc := nil;
end;

procedure TzFile.Assign(Source: TPersistent);
var
  item: TzFile;
begin
  if Source is TzFile then
  begin
    item := Source as TzFile;
    FName := item.Name;
    FFileType := item.FileType;
    FFileName := item.FileName;
    FFolder := item.Folder;
    FProc := item.Proc;
  end
  else
    inherited Assign(Source);
end;

function TzFile.GetCustom: Boolean;
begin
  Result := FFileType = ftCustom;
end;

function TzFile.GetExt: string;
begin
  Result := TPath.GetExtension(FileName);
end;

function TzFile.GetFileNameNoExt: string;
begin
  // Result := TPath.ChangeExtension(FileName, '');
  Result := ChangeFileExt(FileName, '');
end;

function TzFile.GetFullFileName: string;
begin

  if Folder.IsEmpty then
    Result := FileName
  else
    Result := IncludeTrailingPathDelimiter(Folder) + FileName;
end;

function TzFile.GetIsProc: Boolean;
begin
  Result := FFileType = ftProc;
end;

function TzFile.GetShared: Boolean;
begin
  Result := FFileType = ftShared;
end;

/// ////////////////////////////////////////////////////////////////////////////

constructor TzFiles.TFileListEnumerator.Create(ACollection: TzFiles);
begin
  inherited Create;
  index := -1;
  Collection := ACollection;
end;

function TzFiles.TFileListEnumerator.GetCurrent: TzFile;
begin
  Result := Collection.Items[index];
end;

function TzFiles.TFileListEnumerator.MoveNext: Boolean;
begin
  Result := index < Collection.Count - 1;
  if Result then
    Inc(index);
end;

/// ////////////////////////////////////////////////////////////////////////////

class constructor TzFiles.ClassCreate;
begin
  AppRoot := '';
  CustomFolder := '__Custom';
  SharedFolder := '__Shared';
end;

constructor TzFiles.Create(const aClassFolder: string);
begin
  inherited Create(TzFile);
  FClassFolder := aClassFolder;
end;

function TzFiles.GetEnumerator: TFileListEnumerator;
begin
  Result := TFileListEnumerator.Create(Self);
end;

function TzFiles.GetItem(index: Integer): TzFile;
begin
  Result := TzFile(inherited Items[Index]);
end;

procedure TzFiles.SetItem(index: Integer; const Value: TzFile);
begin
  Items[Index].Assign(Value);
end;

function TzFiles.Insert(index: Integer): TzFile;
begin
  Result := TzFile(inherited Insert(Index));
end;

function TzFiles.FindFile(Name: string): TzFile;
var
  item: TzFile;
begin
  Result := nil;

  for item in Self do
    if SameText(Name, item.Name) then
    begin
      Result := item;
      exit;
    end;
end;

function TzFiles.IndexOf(Name: string): Integer;
var
  item: TzFile;
begin
  Result := -1;

  item := FindFile(Name);

  if assigned(item) then
    Result := item.index;
end;

function TzFiles.Add: TzFile;
begin
  Result := TzFile(inherited Add);
end;

function TzFiles.Add(const Name: string; const FullFileName: string; FileType: TFileItemType; Proc: TProc<TzFile>): TzFile;
var
  idx: Integer;
  FileName: string;
  Folder: String;
begin
  Result := nil;

  FileName := TPath.GetFileName(FullFileName);
  Folder := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(FullFileName));

  idx := IndexOf(Name);
  if idx = -1 then
    Result := Add
  else
    Result := Items[idx];

  Result.FName := Name;
  Result.FFileName := FileName;
  Result.FFolder := Folder;
  Result.FFileType := FileType;
  Result.FProc := Proc;
end;

procedure TzFiles.AddFolder(const Folder: string; const FileExt: string; SharedFiles: TStrings = nil; const DoClear: Boolean = True; IsValidFile: TFunc < string, Boolean >= nil);

  procedure AddFiles;
  var
    FileName: string;
    tmpFolder: string;

    function CalcName(Const FullFileName: String): string;
    begin
      Result := ChangeFileExt(TPath.GetFileName(FullFileName), '');
    end;

    function FileOk(const FileName: string): Boolean;
    begin
      Result := True;

      if assigned(IsValidFile) then
        Result := IsValidFile(FileName);
    end;

  begin
    tmpFolder := GetFolder(Folder, ftNormal);

    for FileName in TDirectory.GetFiles(tmpFolder, '*' + FileExt) do
      if FileOk(FileName) then

        Add(CalcName(FileName), FileName, ftNormal, nil);

    if CustomFolder <> '' then
    begin
      tmpFolder := GetFolder(Folder, ftCustom);
      for FileName in TDirectory.GetFiles(tmpFolder, '*' + FileExt) do
        // DIV-FIL-2: il filtro vale anche per i file personalizzati
        if FileOk(FileName) then
          Add(CalcName(FileName), FileName, ftCustom, nil);
    end;
  end;

  procedure AddSharedFiles;
  var
    i: Integer;
    tmpFolder: string;
    SharedName: string;
    SharedFile: string;

    function FileOk(const FileName: string): Boolean;
    begin
      Result := not assigned(IsValidFile) or IsValidFile(FileName);
    end;

  begin
    // Shared
    tmpFolder := GetFolder('', ftShared);

    if assigned(SharedFiles) then
      for i := 0 to SharedFiles.Count - 1 do
      begin
        SharedName := SharedFiles.KeyNames[i];
        SharedFile := SharedFiles.ValueFromIndex[i];

        if SharedFile.IsEmpty then
          SharedFile := SharedName;

        // DIV-FIL-1: l'asterisco serve alla scansione, non al nome del file condiviso
        SharedFile := tmpFolder + ChangeFileExt(SharedFile, StringReplace(FileExt, '*', '', [rfReplaceAll]));

        // DIV-FIL-2: il filtro vale anche per i file condivisi
        if FileExists(SharedFile) and FileOk(SharedFile) then
          Add(SharedName, SharedFile, ftShared, nil);
      end;
  end;

begin
  if DoClear then
    Clear;

  AddFiles;
  AddSharedFiles;
end;

procedure TzFiles.GetFileNames(List: TStrings; const RemoveFileExt: Boolean);
var
  item: TzFile;
begin
  Assert(assigned(List));

  List.Clear;

  for item in Self do
    if RemoveFileExt then
      List.Add(item.Name)
    else
      List.Add(item.FileName);
end;

function TzFiles.GetFolder(const Folder: string; FileItemType: TFileItemType): string;
begin
  Result := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AppRoot) + ClassFolder);

  case FileItemType of
    ftNormal:
      Result := Result + IncludeTrailingPathDelimiter(Folder);
    ftCustom:
      Result := Result + IncludeTrailingPathDelimiter(CustomFolder) + IncludeTrailingPathDelimiter(Folder);
    ftShared:
      Result := Result + IncludeTrailingPathDelimiter(SharedFolder);
  end;

  ForceDirectories(Result);
end;

function TzFiles.GetFolder(const Folder: string; Custom: Boolean): string;
begin

  if Custom then
    Result := GetFolder(Folder, ftCustom)
  else
    Result := GetFolder(Folder, ftNormal);
end;

function TzFiles.GetFullFileName(const Name: string): string;
var
  item: TzFile;
begin
  Result := '';

  item := FindFile(Name);

  if assigned(item) then
    Result := item.FullFileName;
end;

end.
