unit zLib_Compression;

interface

uses
  SysUtils,
  Classes,
  AbUtils,
  AbBrowse;

function IsFileCompressed(const FileName: string): Boolean;

procedure CompressFile(const SrcFileName, DestFileName: string; const RemoveFolderPath: Boolean);
procedure DecompressFile(const SrcFileName, DestFolder: string; ExtractedFiles: TStrings);

implementation

uses
  AbZipper,
  AbUnZper,
  AbArcTyp,
  AbMeter,
  AbBase;

function IsFileCompressed(const FileName: string): Boolean;
begin
  result := AbDetermineArcType(FileName, atUnknown) <> atUnknown;
end;

procedure CompressFile(const SrcFileName, DestFileName: string; const RemoveFolderPath: Boolean);
var
  AbZipper: TAbZipper;
begin
  if not FileExists(SrcFileName) then
    raise Exception.Create('Il file da comprimere non esiste: ' + SrcFileName);

  if FileExists(DestFileName) then
    DeleteFile(DestFileName);

  AbZipper := TAbZipper.Create(nil);
  try
    AbZipper.FileName := DestFileName;
    if RemoveFolderPath then
      AbZipper.StoreOptions := AbZipper.StoreOptions + [soStripPath];
    AbZipper.AddFiles(SrcFileName, 0);
    AbZipper.Save;
  finally
    FreeAndNil(AbZipper);
  end;
end;

procedure DecompressFile(const SrcFileName, DestFolder: string; ExtractedFiles: TStrings);
const
  FileMask = '*.*';
var
  AbUnZipper: TAbUnZipper;
  FileName: string;
  i: Integer;
begin
  Assert(Assigned(ExtractedFiles));
  //
  if not FileExists(SrcFileName) then
    raise Exception.Create('Il file da decomprimere non esiste: ' + SrcFileName);

  ForceDirectories(DestFolder);
  ExtractedFiles.Clear;

  AbUnZipper := TAbUnZipper.Create(nil);
  try
    AbUnZipper.FileName := SrcFileName;
    AbUnZipper.BaseDirectory := DestFolder;

    for i := 0 to AbUnZipper.Count - 1 do
      if AbUnZipper.Items[i].MatchesStoredNameEx(FileMask) then
      begin
        // deve estrarre nella directory dest
        FileName := ExtractFileName(AbUnZipper.Items[i].FileName);
        ExtractedFiles.Add(FileName);
        AbUnZipper.ExtractAt(i, FileName);
      end;
  finally
    FreeAndNil(AbUnZipper);
  end;
end;

end.

