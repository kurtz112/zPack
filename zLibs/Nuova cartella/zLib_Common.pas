unit zLib_Common;

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics;

function GetModuleName: string;
function GetModuleFolder: string;

procedure OpenFolder(const Folder: string);
procedure ExecuteApplication(const Application: string; const Params: string = '');

function GetFileSize(const FileName: string): Integer;
function FileInUse(const FileName: string): Boolean;
procedure GetAllFiles(Path, Filter: string; Dest: TStrings);
function GetFileVersion(const FileName: string): string;
procedure ExtractIconToStream(const FileName: string; Stream: TStream);

function FormatByteSize(const bytes: Int64): string;
function FileSize(const aFilename: string): Int64;

function LogFileName: string;

procedure Log(Msg: string); overload;
procedure Log(Msg: string; const LogFileName: string); overload;

procedure SaveString(Const FileName: TFileName; const Value: string);

function LoadString(Const FileName: TFileName): string;

type
  TLogProcedure = procedure(const Msg: string);

var
  LogProcedure: TLogProcedure;

implementation

uses
  SHFolder,
  ShellApi;

procedure OpenFolder(const Folder: string);
begin
  if Folder <> '' then
    ShellExecute(0, PCHAR('open'), PCHAR(Folder), nil, nil, SW_RESTORE);
end;

procedure ExecuteApplication(const Application: string; const Params: string = '');
begin
  if Params = '' then
    ShellExecute(0, PCHAR('open'), PCHAR(Application), nil, nil, SW_RESTORE)
  else
    ShellExecute(0, PCHAR('open'), PCHAR(Application), PCHAR(Params), nil, SW_RESTORE);
end;

function GetModuleName: string;
var
  szFileName: array [0 .. MAX_PATH] of Char;
begin
  FillChar(szFileName, SizeOf(szFileName), #0);
  GetModuleFileName(hInstance, szFileName, MAX_PATH);
  Result := szFileName;
end;

function GetModuleFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(GetModuleName));
end;

function LogFileName: string;
begin
  Result := ChangeFileExt(GetModuleName, '.log');
end;

procedure Log(Msg: string; const LogFileName: string);
var
  F: TextFile;
  applicationName: array [0 .. MAX_PATH] of Char;
  TempIoRes: Integer;
begin
{$I-}
  AssignFile(F, LogFileName);
  if FileExists(LogFileName) then
    Append(F)
  else
    Rewrite(F);
  Writeln(F, DateTimeToStr(Now) + ': ' + Msg);
  CloseFile(F);
{$I+} TempIoRes := IOResult;

  if Assigned(LogProcedure) then
    LogProcedure(DateTimeToStr(Now) + ': ' + Msg);
end;

procedure Log(Msg: string);
begin
  Log(Msg, LogFileName);
end;

procedure DummyLog(const Msg: string);
begin

end;

function GetFileSize(const FileName: string): Integer;
var
  F: file of byte;
  fs: cardinal;
begin
  Result := -1;
  AssignFile(F, FileName);
  try
    Reset(F);
    Result := system.FileSize(F);
  finally
    CloseFile(F);
  end;
end;

procedure GetAllFiles(Path, Filter: string; Dest: TStrings);
var
  Rec: TSearchRec;
begin
  Dest.clear;
  if length(Path) > 0 then
    if Path[length(Path)] <> '\' then
      Path := Path + '\';
  if FindFirst(Path + Filter, faAnyFile, Rec) <> 0 then
    Exit;
  repeat
    if FileExists(Path + Rec.Name) then
      Dest.Add(Rec.Name);
  until FindNext(Rec) <> 0;
end;

function FileInUse(const FileName: string): Boolean;
var
  hFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  hFileRes := CreateFile(PCHAR(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (hFileRes = INVALID_HANDLE_VALUE);

  CloseHandle(hFileRes);
end;

function GetFileVersion(const FileName: string): string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  Result := '';
  VerInfoSize := GetFileVersionInfoSize(PCHAR(FileName), Dummy);
  if VerInfoSize = 0 then
    Exit;
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PCHAR(FileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    Result := IntToStr(dwFileVersionMS shr 16);
    Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
    Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
    Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

procedure ExtractIconToStream(const FileName: string; Stream: TStream);
var
  icon: TIcon;
  Bitmap: TBitmap;
begin
  Assert(Assigned(Stream));

  icon := TIcon.Create;
  try

    icon.Handle := ExtractIcon(hInstance, PCHAR(FileName), 0);
    Bitmap := TBitmap.Create;
    try
      Bitmap.Height := icon.Height;
      Bitmap.Width := icon.Width;
      Bitmap.Canvas.Draw(0, 0, icon);
      Bitmap.SaveToStream(Stream);
    finally
      FreeAndNil(Bitmap);
    end;
  finally
    FreeAndNil(icon);
  end;
end;

function FormatByteSize(const bytes: Int64): string;
const
  B = 1; // byte
  KB = 1024 * B; // kilobyte
  MB = 1024 * KB; // megabyte
  GB = 1024 * MB; // gigabyte
begin
  if bytes > GB then
    Result := FormatFloat('#.## GB', bytes / GB)
  else
    if bytes > MB then
      Result := FormatFloat('#.## MB', bytes / MB)
    else
      if bytes > KB then
        Result := FormatFloat('#.## KB', bytes / KB)
      else
        Result := FormatFloat('#.## bytes', bytes);
end;

function FileSize(const aFilename: string): Int64;
var
  info: TWin32FileAttributeData;
begin
  Result := -1;

  if not GetFileAttributesEx(PCHAR(aFilename), GetFileExInfoStandard, @info) then
    Exit;

  Result := info.nFileSizeLow or (info.nFileSizeHigh shl 32);
end;

procedure SaveString(Const FileName: TFileName; const Value: string);
var
  strList: TStringList;
begin
  strList := TStringList.Create;
  try
    strList.Text := Value;
    strList.SaveToFile(FileName);
  finally
    FreeAndNil(strList);
  end;
end;

function LoadString(Const FileName: TFileName): string;
var
  strList: TStringList;
begin
  Result := '';

  if not FileExists(FileName) then
    Exit;

  strList := TStringList.Create;
  try
    strList.LoadFromFile(FileName);
    Result := strList.Text;
  finally
    FreeAndNil(strList);
  end;
end;

initialization

LogProcedure := DummyLog;

end.
