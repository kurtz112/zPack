unit zFileSystem;

interface

uses
  System.SysUtils,
  System.classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  zz.GenericCollection;

type
  TObjectType = (otFile, otFolder);
  TAllowedFileExts = array of string;
  TExcludeFolders = array of string;

  TzFileSystemObject = class;
  TzFolder = class;
  TzFile = class;

  TzFileSystemObject = class(TCollectionItem)
  private
    FFullName: string;
    FParent: TzFolder;
    FName: string;
    function GetIsFile: boolean;
    function GetIsFolder: boolean;
    function GetObjectType: TObjectType; virtual;
    procedure SetFullName(const Value: string);
  protected
    property Parent: TzFolder read FParent write FParent;
    property ObjectType: TObjectType read GetObjectType;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property FullName: string read FFullName write SetFullName;
    property Name: string read FName write FName;

    property IsFile: boolean read GetIsFile;
    property IsFolder: boolean read GetIsFolder;
  end;

  TzFileSystemObjects<T: TCollectionItem> = class(TCollection)
  private type
    TCollectionEnumerator = class
    private
      index: Integer;
      Collection: TzFileSystemObjects<T>;
    public
      constructor Create(ACollection: TzFileSystemObjects<T>);
      function GetCurrent: T;
      function MoveNext: boolean;
      property Current: T read GetCurrent;
    end;
  private
    function GetItem(index: Integer): T;
    procedure SetItem(index: Integer; const Value: T);
  protected
    class function ItemAsGeneric(const Item): T;
  protected
    function Compare(Item1, Item2: T): Integer; virtual;
  public
    function GetEnumerator: TCollectionEnumerator;

    function Add: T;
    function Insert(index: Integer): T;
    procedure Remove(index: Integer);

    function IndexOf(func: TFunc<T, boolean>): Integer;
    function Get(func: TFunc<T, boolean>): T;
    procedure ForEach(func: TFunc<T, boolean>);

    procedure Sort;
    property Items[index: Integer]: T read GetItem write SetItem; default;
  end;

  TzFile = class(TzFileSystemObject)
  private
    FIsShared: boolean;
    function GetFileName: string;
    function GetFileNameNoExt: String;
    function GetFileExt: string;
    function GetFolder: string;
  protected
    function GetObjectType: TObjectType; override;
  public
    constructor Create(Collection: TCollection); override;

    property FileName: string read GetFileName; // nome + ext
    property FileNameNoExt: String read GetFileNameNoExt; // nome senza ext
    property FileExt: string read GetFileExt; // ext
    property Folder: string read GetFolder;

    property IsShared: boolean read FIsShared write FIsShared;
  end;

  TzFolder = class(TzFileSystemObject)
  private
    FFolders: TzGenericCollection<TzFolder>;
    FFiles: TzGenericCollection<TzFile>;
  protected
    function GetObjectType: TObjectType; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Clear;
    function AddFolder(const AFullName: string): TzFolder;
    function AddFile(const aName, AFullName: string; const Shared: boolean = False): TzFile;

    function FileByName(const FileName: string): TzFile;
    function FileByFullName(const FullFileName: string): TzFile;
    function FolderByName(const Folder: string): TzFolder;

    procedure Remove(AObject: TzFileSystemObject);

    procedure LoadFolder(Parent: TzFolder; const Folder: string; AllowedFileExts: TAllowedFileExts; ExcludeFolders: TExcludeFolders);
    procedure LoadSharedFiles(const FilesRoot: string; SharedFiles: TStrings; AllowedFileExts: TAllowedFileExts);

    property Folders: TzGenericCollection<TzFolder> read FFolders write FFolders;
    property Files: TzGenericCollection<TzFile> read FFiles write FFiles;
  end;

  TzFileSystem = class
  private
    FRoot: TzFolder;
  public
    destructor Destroy; override;

    procedure LoadFiles(const FilesRoot, Folder: string; AllowedFileExts: TAllowedFileExts; SharedFiles: TStrings; ExcludeFolders: TExcludeFolders);
    property root: TzFolder read FRoot write FRoot;
  end;

implementation

uses
  System.IOUtils,
  System.StrUtils,
  zOffice.Word.Utils;

{ TzFileSystemObject }

constructor TzFileSystemObject.Create(Collection: TCollection);
begin
  inherited;
  FParent := nil;
  FFullName := '';
  FName := '';
end;

destructor TzFileSystemObject.Destroy;
begin
  inherited;
end;

function TzFileSystemObject.GetIsFile: boolean;
begin
  Result := ObjectType = otFile;
end;

function TzFileSystemObject.GetIsFolder: boolean;
begin
  Result := ObjectType = otFolder;
end;

function TzFileSystemObject.GetObjectType: TObjectType;
begin
  Result := otFile;
end;

procedure TzFileSystemObject.SetFullName(const Value: string);
begin
  FFullName := Value;

  if IsFolder then
    FFullName := IncludeTrailingPathDelimiter(FullName);

  // ExtractFileName funziona solo se non finisce con \
  FName := ChangeFileExt(ExtractFileName(ExcludeTrailingPathDelimiter(FFullName)), '');
end;

procedure TzFolder.Clear;
begin
  Folders.Clear;
  Files.Clear;
end;

{ TFolder }

constructor TzFolder.Create(Collection: TCollection);
begin
  inherited;
  FFolders := TzGenericCollection<TzFolder>.Create(TzFolder);
  FFiles := TzGenericCollection<TzFile>.Create(TzFile)
end;

destructor TzFolder.Destroy;
begin
  FreeAndNil(FFolders);
  FreeAndNil(FFiles);
  inherited;
end;

function TzFolder.AddFolder(const AFullName: string): TzFolder;
begin
  Result := Folders.Add;
  // Result := TzFolder.Create(Folders);
  Result.Parent := self;
  Result.FullName := IncludeTrailingPathDelimiter(AFullName);
end;

function TzFolder.AddFile(const aName, AFullName: string; const Shared: boolean = False): TzFile;
begin
  Result := Files.Add;
  // Result := TzFile.Create(Files);
  Result.Parent := self;
  Result.FullName := AFullName;

  if not aName.IsEmpty then
    Result.Name := aName;

  Result.IsShared := Shared;
end;

procedure TzFolder.Remove(AObject: TzFileSystemObject);
begin

  if assigned(AObject) then
  begin
    if AObject.IsFolder then
      Folders.Remove(AObject as TzFolder)
    else
      Files.Remove(AObject as TzFile);
  end;
end;

function TzFolder.FileByName(const FileName: string): TzFile;
var
  zFile: TzFile;
  zFolder: TzFolder;
begin
  Result := nil;

  for zFile in Files do
    if sameText(zFile.Name, FileName) then
    begin
      Result := zFile;
      exit;
    end;

  for zFolder in Folders do
  begin
    Result := zFolder.FileByName(FileName);

    if assigned(Result) then
      exit;
  end;
end;

function TzFolder.FileByFullName(const FullFileName: string): TzFile;
var
  zFile: TzFile;
  zFolder: TzFolder;
begin
  // Mantis #315 - 2026-11-03: ritrova un file dal percorso completo, anche dopo
  // che il ricaricamento dei report ha distrutto e ricreato tutti i TzFile.
  Result := nil;

  for zFile in Files do
    if sameText(zFile.FullName, FullFileName) then
    begin
      Result := zFile;
      exit;
    end;

  for zFolder in Folders do
  begin
    Result := zFolder.FileByFullName(FullFileName);

    if assigned(Result) then
      exit;
  end;
end;

function TzFolder.FolderByName(const Folder: string): TzFolder;
var
  zFolder: TzFolder;
begin
  // Senza questa inizializzazione il risultato e' indefinito quando la
  // cartella non viene trovata e il ciclo sulle sottocartelle non entra
  // mai (cartella foglia): il chiamante riceve il contenuto casuale di
  // EAX, lo trova assigned e lo restituisce a sua volta come se fosse la
  // cartella cercata. FileByName, qui sopra, azzera gia' Result.
  Result := nil;

  if sameText(Folder, self.Name) then
  begin
    Result := self;
    exit;
  end;

  for zFolder in Folders do
  begin
    Result := zFolder.FolderByName(Folder);

    if assigned(Result) then
      exit;
  end;
end;

function TzFolder.GetObjectType: TObjectType;
begin
  inherited;
  Result := otFolder;
end;

procedure TzFolder.LoadFolder(Parent: TzFolder; const Folder: string; AllowedFileExts: TAllowedFileExts; ExcludeFolders: TExcludeFolders);
var
  s, subFolder: string;
  zFolder: TzFolder;
  FileName: string;
  FileExt: string;
begin

  if assigned(Parent) then
    zFolder := Parent.AddFolder(Parent.FullName + Folder)
  else
    zFolder := self;

  if not DirectoryExists(zFolder.FullName) then
    exit;

  for s in TDirectory.GetDirectories(zFolder.FullName) do
  begin
    subFolder := ExtractFileName(s);
    // if not sameText(subFolder, '__Shared') then
    if not subFolder.StartsWith('_') then
      if not MatchText(subFolder, ExcludeFolders) then
        LoadFolder(zFolder, subFolder, AllowedFileExts, ExcludeFolders);
  end;

  for FileExt in AllowedFileExts do
    for FileName in TDirectory.GetFiles(zFolder.FullName, FileExt) do
      if not TFragmentHelper.IsFragment(FileName) then
        zFolder.AddFile('', FileName);
end;

procedure TzFolder.LoadSharedFiles(const FilesRoot: string; SharedFiles: TStrings; AllowedFileExts: TAllowedFileExts);
const
  SharedFolder = '__Shared';

  procedure AddFile(const Name, FileName, ext: string);
  var
    FullFileName: string;
  begin
    FullFileName := IncludeTrailingBackslash(FilesRoot + SharedFolder) + ChangeFileExt(FileName, ext);
    if FileExists(FullFileName) then
      self.AddFile(Name, FullFileName, true);
  end;

var
  Name: string;
  FileName: string;
  FileExt: string;
  i: Integer;
begin

  for i := 0 to SharedFiles.count - 1 do
  begin

    if SharedFiles[i].Contains('=') then
    begin
      Name := SharedFiles.KeyNames[i];
      FileName := SharedFiles.ValueFromIndex[i]
    end
    else
    begin
      Name := '';
      FileName := SharedFiles[i];
    end;

    for FileExt in AllowedFileExts do
      AddFile(Name, FileName, FileExt.replace('*', '', []));
  end;
end;

{ TFile }

constructor TzFile.Create(Collection: TCollection);
begin
  inherited;
  FIsShared := False;
end;

destructor TzFileSystem.Destroy;
begin
  FreeAndNil(FRoot);
  inherited;
end;

function TzFile.GetFileName: string;
begin
  Result := ExtractFileName(FullName);
end;

function TzFile.GetFileNameNoExt: String;
begin
  Result := ChangeFileExt(ExtractFileName(FullName), '');
end;

function TzFile.GetFileExt: string;
begin
  Result := ExtractFileExt(FullName);
end;

function TzFile.GetFolder: string;
begin
  Result := ExtractFilePath(FullName);
end;

function TzFile.GetObjectType: TObjectType;
begin
  inherited;
  Result := otFile;
end;

procedure TzFileSystem.LoadFiles(const FilesRoot, Folder: string; AllowedFileExts: TAllowedFileExts; SharedFiles: TStrings; ExcludeFolders: TExcludeFolders);
begin
  FreeAndNil(root);
  FRoot := TzFolder.Create(nil);
  FRoot.FullName := FilesRoot + Folder;

  FRoot.LoadFolder(nil, Folder, AllowedFileExts, ExcludeFolders);
  FRoot.LoadSharedFiles(FilesRoot, SharedFiles, AllowedFileExts);
end;

/// ////////////////////////////
function TzFileSystemObjects<T>.Compare(Item1, Item2: T): Integer;
begin
  (*

    Descendant classes would override this method and cast Item1 and Item2 to the
    decendant class's collection item type perform the field comparisions

    if item1.MyField < item2.MyField
    return -1
    else if item1.MyField > item2.MyField
    return 1
    else return 0

  *)
  Result := 0;
end;

procedure TzFileSystemObjects<T>.ForEach(func: TFunc<T, boolean>);
var
  Item: T;
begin
  assert(assigned(func));

  for Item in self do
    if not func(Item) then
      exit;
end;

function TzFileSystemObjects<T>.GetEnumerator: TCollectionEnumerator;
begin
  Result := TCollectionEnumerator.Create(self);
end;

function TzFileSystemObjects<T>.GetItem(index: Integer): T;

var
  Item: TCollectionItem;
begin
  Item := inherited Items[index];
  Result := ItemAsGeneric(Item);
end;

function TzFileSystemObjects<T>.IndexOf(func: TFunc<T, boolean>): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to count - 1 do
    if func(Items[i]) then
    begin
      Result := i;
      exit;
    end;
end;

function TzFileSystemObjects<T>.Get(func: TFunc<T, boolean>): T;
var
  idx: Integer;
  dummy: TCollectionItem;
begin
  dummy := nil;

  Result := ItemAsGeneric(dummy);

  idx := IndexOf(func);

  if idx <> -1 then
    Result := Items[idx]
end;

function TzFileSystemObjects<T>.Add: T;
var
  Item: TCollectionItem;
begin
  Item := inherited Add;
  Result := ItemAsGeneric(Item);
end;

function TzFileSystemObjects<T>.Insert(index: Integer): T;
var
  Item: TCollectionItem;
begin
  Item := inherited Insert(index);
  Result := ItemAsGeneric(Item);
end;

class function TzFileSystemObjects<T>.ItemAsGeneric(const Item): T;
begin
  Result := T(Item);
end;

procedure TzFileSystemObjects<T>.Remove(index: Integer);
begin
  Delete(index);
end;

procedure TzFileSystemObjects<T>.SetItem(index: Integer; const Value: T);
begin
  Items[index].Assign(Value);
end;

//
procedure TzFileSystemObjects<T>.Sort;
var
  Comparer: IComparer<TCollectionItem>;
begin

  Comparer := TComparer<TCollectionItem>.Construct(
    function(const Item1, Item2: TCollectionItem): Integer
    begin
      Result := Compare(ItemAsGeneric(Item1), ItemAsGeneric(Item2));
    end);

  inherited Sort(Comparer);
end;

// begin
// if Count > 1 then
// begin
// BeginUpdate;
// try
// QuickSort(0, Count - 1);
// finally
// EndUpdate;
// end;
// end;
// end;

{ TzCollection<T>.TCollectionEnumerator }

constructor TzFileSystemObjects<T>.TCollectionEnumerator.Create(ACollection: TzFileSystemObjects<T>);
begin
  inherited Create;
  index := -1;
  Collection := ACollection;
end;

function TzFileSystemObjects<T>.TCollectionEnumerator.GetCurrent: T;
begin
  Result := Collection.Items[index];
end;

function TzFileSystemObjects<T>.TCollectionEnumerator.MoveNext: boolean;
begin
  Result := index < Collection.count - 1;
  if Result then
    inc(index);
end;

end.

  __Shared
