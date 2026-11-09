unit zz.zip;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Zip;

procedure ZipFile(const SrcFile, ZipFileName: string); overload;
procedure ZipFile(const SrcFile: string; Stream: TStream); overload;

procedure UnzipFile(const ZippedFile: string; DestFolder: string);

implementation

procedure ZipFile(const SrcFile, ZipFileName: string);
var
  Zip: TZipFile;
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(SrcFile, fmOpenRead);
  try
    Zip := TZipFile.Create;
    try

      if FileExists(ZipFileName) then
        Zip.Open(ZipFileName, zmReadWrite)
      else
        Zip.Open(ZipFileName, zmWrite);

      Zip.Add(FileStream, ExtractFileName(SrcFile));
      Zip.Close;
    finally
      Zip.Free;
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

procedure ZipFile(const SrcFile: string; Stream: TStream);
var
  Zip: TZipFile;
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(SrcFile, fmOpenRead);
  try
    Zip := TZipFile.Create;
    try
      Zip.Open(Stream, zmWrite);
      Zip.Add(FileStream, ExtractFileName(SrcFile));
      Zip.Close;
    finally
      Zip.Free;
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

procedure UnzipFile(const ZippedFile: string; DestFolder: string);
var
  Zip: TZipFile;
begin
  Zip := TZipFile.Create;
  try
    if not FileExists(ZippedFile) then
      raise Exception.Create('File ' + ZippedFile + ' non trovato.');

    Zip.Open(ZippedFile, zmRead);
    Zip.ExtractAll(DestFolder);
    Zip.Close;
  finally
    Zip.Free;
  end;
end;

end.
