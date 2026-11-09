unit zResFiles;

interface

uses SysUtils,
  zCollection,
  classes,
  Dialogs,
  ComCtrls;

type
  TzResFile = class(TzCollectionItem)
  private
    FFileName: string;
    procedure SetFileName(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property FileName: string read FFileName write SetFileName;
  end;

  TzResFiles = class(TzCollection)
  private
    FFolder: string;
    FFileExt: string;
    FGroup: string;
    function GetItem(Index: Integer): TzResFile;
    procedure SetItem(Index: Integer; const Value: TzResFile);
    procedure SetFolder(const Value: string);
    procedure SetFileExt(const Value: string);
    procedure SetGroup(const Value: string);
  public
    function Add: TzResFile;
    function Insert(Index: Integer): TzResFile;
    procedure LoadFromFolder;
    procedure FillTreeView(TreeView: TTreeView); override;
    property Items[Index: Integer]: TzResFile read GetItem write SetItem; default;
    function AddNewFile(Name: string; Custom: boolean = false): TzResFile;
    function WorkingDir: string;
  published
    property Folder: string read FFolder write SetFolder;
    property Group: string read FGroup write SetGroup;
    property FileExt: string read FFileExt write SetFileExt;
  end;

implementation

uses zMsg;

constructor TzResFile.Create(Collection: TCollection);
begin
  inherited;
  FFileName := '';
end;

procedure TzResFile.Assign(Source: TPersistent);
begin
  if Source is TzResFile then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzResFile(Source).Name;
      FileName := TzResFile(Source).FileName;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzResFile.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

{ TzResFiles }

function TzResFiles.Add: TzResFile;
begin
  Result := TzResFile(inherited Add);
end;

function TzResFiles.GetItem(Index: Integer): TzResFile;
begin
  Result := TzResFile(inherited Items[Index]);
end;

function TzResFiles.Insert(Index: Integer): TzResFile;
begin
  Result := TzResFile(inherited Insert(Index));
end;

procedure TzResFiles.SetFolder(const Value: string);
begin
  FFolder := Value;
end;

procedure TzResFiles.SetItem(Index: Integer; const Value: TzResFile);
begin
  Items[Index].Assign(Value);
end;

procedure TzResFiles.LoadFromFolder;

  procedure GetAllFiles(Path, Filter: string; Dest: TStrings);
  var
    Rec: TSearchRec;
    FileName: string;
  begin
    Dest.clear;
    if length(Path) > 0 then
      if Path[length(Path)] <> '\' then
        Path := Path + '\';
    if FindFirst(Path + Filter, faAnyFile, Rec) <> 0 then
      Exit;
    repeat
      FileName := Path + Rec.Name;
      if fileexists(FileName) then
        Dest.Add(FileName);
    until FindNext(Rec) <> 0;
  end;

  function FileNameNoExt(filename: string): string;
  var
    ext: string;
    temp: string;
  begin
    temp := extractFileName(filename);
    ext := extractFileExt(filename);
    if pos(ext, temp) > 0 then
      system.delete(temp, pos(ext, temp), length(ext));
    result := temp;
  end;

  function calcPath(s: string): string;
  begin
    result := trim(s);
    if s = '' then
      Result := '\'
    else
      if result[length(result)] <> '\' then
        result := result + '\';
  end;

  function CustomDir: string;
  begin
    result := CalcPath(WorkingDir) + 'Custom';
  end;

var
  i: integer;
  Str: TStringList;
  Item: TzResFile;
  Directory: string;
  idx: Integer;

begin
  Directory := WorkingDir;

  Clear;
  Str := TStringList.Create;
  try
    GetAllFiles(Directory, '*' + FileExt, Str);

    for i := 0 to Str.Count - 1 do
    begin
      Item := Add;
      Item.Name := FileNameNoExt(Str[i]);
      Item.FileName := Str[i];
    end;

    Directory := CustomDir;
    if DirectoryExists(Directory) then
    begin
      GetAllFiles(Directory, '*' + FileExt, Str);

      for i := 0 to Str.Count - 1 do
      begin
        idx := IndexOf(FileNameNoExt(Str[i]));
        if idx = -1 then
          Item := Add
        else
          Item := Items[idx];
          
        Item.Name := FileNameNoExt(Str[i]);
        Item.FileName := Str[i];
      end;
    end;

  finally
    FreeAndNil(Str);
  end;
end;

function TzResFiles.AddNewFile(Name: string; Custom: boolean = false): TzResFile;
var
  Path: string;
begin
  Result := Add;
  Result.Name := Name;
  Path := Folder;
  if Path[length(Path)] <> '\' then
    Path := Path + '\';

  Result.FileName := Path + Name + FileExt;
end;

procedure TzResFiles.SetFileExt(const Value: string);
begin
  FFileExt := Value;
end;

procedure TzResFiles.FillTreeView(TreeView: TTreeView);
  procedure Add(TreeView: TTreeView; MasterNode: TTreeNode; zCollection: TzCollection);
  var
    i, x: integer;
    ImageIndex: integer;
    Node, Child: TTreeNode;
  begin
    Node := MasterNode;
    if Assigned(Node) then
      Node := TreeView.Items.AddChildObject(node, zCollection.Name, zCollection)
    else //root
      Node := TreeView.Items.AddObject(nil, zCollection.Name, zCollection);

    ImageIndex := zCollection.ImageIndex;
    Node.ImageIndex := ImageIndex;
    Node.SelectedIndex := ImageIndex;

    for i := 0 to zCollection.Count - 1 do
    begin
      Child := TreeView.Items.AddChildObject(node, zCollection[i].Name, zCollection[i]);
      Child.ImageIndex := ImageIndex;
      Child.SelectedIndex := ImageIndex;
      for x := 0 to zCollection[i].Details.Count - 1 do
        Add(TreeView, Child, TzCollection(zCollection[i].Details[x]));
    end;
    Node := nil;
  end;
begin
//inherited; non deve essere chiamato
  TreeView.Items.BeginUpdate;
  try
    Add(TreeView, nil, Self);
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TzResFiles.SetGroup(const Value: string);
begin
  FGroup := Value;
end;

function TzResFiles.WorkingDir: string;
  function calcPath(s: string): string;
  begin
    result := trim(s);
    if s = '' then
      Result := '\'
    else
      if result[length(result)] <> '\' then
        result := result + '\';
  end;

var
  s: string;
begin
  result := '';

  if Trim(Folder) = '' then
  begin
    zConfirmOk('Percorso non assegnato. (' + Self.Name + ')');
    Exit;
  end;

  if not ForceDirectories(Folder) then
  begin
    zConfirmOk('Impossibile creare la cartella ' + Folder + '.');
    Exit;
  end;

  s := Folder;
  s := CalcPath(s);
  if Trim(Group) <> '' then
    s := CalcPath(s + Group);

  if not ForceDirectories(s) then
  begin
    zConfirmOk('Impossibile creare la cartella ' + s + '.');
    Exit;
  end;
  Result := s;
end;

end.

