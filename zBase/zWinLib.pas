 {
This unit was generated on Tue, 28 Jun 2005 11: 33: 03 + 0100
  by the code snippets database at www.delphidabbler.com.
    Check the site for updates.

The unit is freeware and may be freely distributed providing
  only that this comment is left in the code.
    }

unit zWinLib;

interface

uses
  Windows,
  SysUtils,
  Classes,
  ShellAPI,
  IniFiles,
  Graphics,
  UrlMon,
  ShlObj,
  ActiveX,
  Registry;

{
  WinFileTimeToDateTime:
    Converts Windows FILETIME to Delphi TDateTime. Raises exception if file time
    is not a valid value.
}
function WinFileTimeToDateTime(FT: Windows.TFileTime): TDateTime;

{
  WinFileTimeToDOSFileTime:
    Converts a Windows FILETIME to a DOS file time. Raises exception if file
    time is not a valid value.
}
function WinFileTimeToDOSFileTime(FT: Windows.TFileTime): Integer;

{
  WinFileTimeToStr:
    Converts a Windows FILETIME structure to a string. Raises exception if file
    time is not a valid value.
}
function WinFileTimeToStr(FT: Windows.TFileTime): string;

{
  CopyFile:
    Copies Source file to Dest, preserving modification date.
}
procedure CopyFile(const Source, Dest: string);

{
  CreateURLShortcut:
    Creates a URL shortcut file with the given name for the given URL,
    overwriting any existing file. An exception is raised if file can't be
    created.
}
procedure CreateURLShortcut(const ShortcutFile, URL: string);

{
  DeleteFiles:
    Deletes all files in the directory Dir that match the given wildcard and
    returns the number of files deleted. If Wildcard is '' then all files are
    deleted. Sub-directories of Dir are not deleted.
}
function DeleteFiles(const Dir, Wildcard: string): Integer;

{
  DeleteFileWithUndo:
    Deletes given file and sends it to recycle bin. Returns true if file deleted
    successfully.
}
function DeleteFileWithUndo(const FileName: string): Boolean;

{
  DirToPath:
    Returns the given directory with a trailing backslash. If the directory
    already ends in backslash it is returned unchanged.
}
function DirToPath(const Dir: string): string;

{
  DOSToUnixPath:
    Converts a DOS path to a Unix path and returns it.
}
function DOSToUnixPath(const PathName: string): string;

{
  EnsureFolders:
    Ensures that the given folder and all folders on its path exist, and creates
    them if they do not. Uses recursion.
}
procedure EnsureFolders(Path: string);

{
  GetFileDate:
    Returns modification date of given file encoded as integer.
}
function GetFileDate(const FName: string): Integer;

{
  GetFixedFileVerInfo:
    Extracts fixed version information from a file. If file contains version
    information it is returned via FFI parameter and function returns true,
    otherwise false is returned and FFI is undefined.
}
function GetFixedFileVerInfo(const FileName: string;
  out FFI: Windows.TVSFixedFileInfo): Boolean;

{
  HasVerInfo:
    Returns true if the given file contains version information and false if
    not.
}
function HasVerInfo(const FileName: string): Boolean;

{
  IsDirectory:
    Returns true if given name is a valid directory and false otherwise. DirName
    can be any file system name (with or without trailing path delimiter).
}
function IsDirectory(const DirName: string): Boolean;

{
  IsURLShortcut:
    Returns true if the given file is a URL shortcut file and false if not.
}
function IsURLShortcut(const ShortcutFile: string): Boolean;

{
  ListFiles:
    Gets a list of the files and sub-directories of the given directory that
    match the given wild card. The files are appended to the given string list.
    Returns true if Dir is a valid directory and False if not. If Wildcard is
    not specified, *.* is assumed.
}
function ListFiles(const Dir, Wildcard: string;
  const List: Classes.TStrings): Boolean;

{
  LongToShortFilePath:
    Converts the given long file name to the equivalent shortened DOS style 8.3
    path.
}
function LongToShortFilePath(const LongName: string): string;

{
  PathToDir:
    Returns the given directory with any single trailing backslash removed. If
    the directory does not end in a backslash it is returned unchanged.
}
function PathToDir(const Path: string): string;

{
  SetFileDate:
    Sets modification date of given file to given integer coded value.
}
procedure SetFileDate(const FName: string; const ADate: Integer);

{
  ShortToLongFilePath:
    Converts whole of given DOS style 8.3 path to long file path and returns it.
    If path can't be converted then '' is returned.
}
function ShortToLongFilePath(const FilePath: string): string;

{
  TempFileName:
    Returns a unique temporary file name in temporary folder. File name includes
    first three characters of Stub followed by hexadecimal characters. If Create
    is true file is created. Returns empty string on failure.
}
function TempFileName(const Stub: string; const Create: Boolean): string;

{
  Touch:
    Sets modification date of given file to current date and time. Returns true
    if date set successfully or false on error.
}
function Touch(const FileName: string): Boolean;

{
  URLFromShortcut:
    Returns the URL referenced by the given URL shortcut file, or the empty
    string if the given file is not a shortcut file.
}
function URLFromShortcut(const Shortcut: string): string;

{
  FileToString:
    Stores content of a file in an ANSI string.
}
function FileToString(const FileName: string): string;

{
  IsUnicodeFile:
    Checks if a file contains unicode text and returns true if so and false if
    not.
}
function IsUnicodeFile(const FileName: string): Boolean;

{
  IsUnicodeStream:
    Checks if a stream contains unicode text at the current position. Returns
    true if stream contains unicode and false otherwise.
}
function IsUnicodeStream(const Stm: Classes.TStream): Boolean;

{
  StreamToString:
    Reads content of a stream into an ansi string. Stream is read from current
    positions.
}
function StreamToString(const Stm: Classes.TStream): string;

{
  StringToFile:
    Writes an ansi string to a text file.
}
procedure StringToFile(const Str, FileName: string);

{
  StringToStream:
    Writes an ansi string into a stream. The string is written at the current
    stream position.
}
procedure StringToStream(const Str: string; const Stm: Classes.TStream);

{
  UnicodeFileToWideString:
    Reads a file into a wide string an returns it. The routine can handle
    unicode files or ansi text files. Ansi files are converted to wide strings.
}
function UnicodeFileToWideString(const FileName: string): WideString;

{
  UnicodeStreamToWideString:
    Reads from a stream into a wide string an returns the string. The routine
    can handle unicode or ansi content on the stream. If the text is unicode
    the word at the current stream position must be a unicode marker word. Ansi
    files are converted to wide strings.
}
function UnicodeStreamToWideString(const Stm: Classes.TStream): WideString;

{
  WideStringToUnicodeFile:
    Writes a wide string to a unicode text file. The text file begins with a
    marker to indicate it is unicode.
}
procedure WideStringToUnicodeFile(const Str: WideString;
  const FileName: string);

{
  WideStringToUnicodeStream:
    Writes a wide string to a stream in unicode format. The output begins with a
    marker to indicate it is unicode.
}
procedure WideStringToUnicodeStream(const Str: WideString;
  const Stm: Classes.TStream);

{
  DriveDisplayName:
    Returns the display name for the drive with the given root path.
}
function DriveDisplayName(const Drive: string): string;

{
  DriveDisplayNames:
    Gets list of display names for all the system's drives and stores in a given
    string list.
}
procedure DriveDisplayNames(const List: Classes.TStrings);

{
  DriveRootPath:
    Returns root drive path for drive with given number.
}
function DriveRootPath(const DriveNum: Byte): string;

{
  DriveTypeFromPath:
    Returns type of drive that contains the given (full) path.
}
function DriveTypeFromPath(const Path: string): LongWord;

{
  HardDiskSerial:
    Returns the serial number of the hard disk with the given root path or 0 if
    the disk is not a hard drive or has no serial number.
}
function HardDiskSerial(const Drive: string): Windows.DWORD;

{
  IsValidDrive:
    Returns true if the given drive path represents a valid drive and false
    otherwise.
}
function IsValidDrive(const Drive: string): Boolean;

{
  IsValidDriveNum:
    Returns true if the drive specified by the given number is valid and false
    otherwise.
}
function IsValidDriveNum(const DriveNum: Byte): Boolean;

{
  ListDrives:
    Gets list of the system's drive root paths and stores in a given string list
}
procedure ListDrives(const List: Classes.TStrings);

{
  BrowseURL:
    Activates default browser or email client for given URL. Returns true if
    browser/email client is uccessfully launched and false if not. Raises
    exception if URL doesn't conform to a known valid protocol.
}
function BrowseURL(const URL: string): Boolean;

{
  ColorToHTML:
    Converts a Delphi TColor value into a string suitable for use in HTML or CSS
    code. Any system colors (like clBtnFace) are mapped to the actual colour
    according to the current Windows settings.
}
function ColorToHTML(const Color: Graphics.TColor): string;

{
  DownloadURLToFile:
    Downloads file at URL and stores in given file. Returns true if download
    succeeds and false on failure. A connection to the internet must be open
    for download to succeed.
}
function DownloadURLToFile(const URL, FileName: string): Boolean;

{
  IsValidURLProtocol:
    Checks if the given URL is valid per RFC1738. Returns true is valid and
    false if not.
}
function IsValidURLProtocol(const URL: string): Boolean;

{
  MakeSafeHTMLText:
    Replaces any characters in the given text that are HTML-compatible with
    suitable escaped versions and returns modified string.
}
function MakeSafeHTMLText(TheText: string): string;

{
  URLDecode:
    Decodes the given encoded URL or URL query string. Raises exception if the
    encoded URL is badly formed.
}
function URLDecode(const S: string): string;

{
  URLEncode:
    Encodes the given string, making it suitable for use in a URL. The function
    can encode strings for use in the main part of a URL (where spaces are
    encoded as '%20') or in URL query strings (where spaces are encoded as '+'
    characters). Set InQueryString to true to encode for a query string.
}
function URLEncode(const S: string; const InQueryString: Boolean): string;

{
  CompressWhiteSpace:
    Returns a copy of given string with all white space characters replaced by
    space characters and all sequences of white space replaced by a single
    space character.
}
function CompressWhiteSpace(const S: string): string;

{
  CountDelims:
    Returns count of all occurences of any of the given delimiter characters in
    the string S.
}
function CountDelims(const S, Delims: string): Integer;

{
  ExplodeStr:
    Splits the string S into a list of strings, separated by Delim, and returns
    the number of strings in the list. If AllowEmpty is true then any empty
    strings are added to the list, while they are ignored if AllowEmpty is
    false.
}
function ExplodeStr(S: string; const Delim: Char; const List: Classes.TStrings;
  const AllowEmpty: Boolean = True): Integer;

{
  JoinStr:
    Joins all strings in given string list together into single string separated
    by given delimiter. If AllowEmpty is true then any empty strings are
    included in output string, but are ignored if false.
}
function JoinStr(const SL: Classes.TStrings; const Delim: string;
  const AllowEmpty: Boolean = True): string;

{
  MultiSzToStrings:
    Splits out individual strings from given 'MultiSz' strings buffer and adds
    each string to the given string list. A MultiSz string is a sequence of #0
    delimited strings terminated by an extra #0 character. Does nothing if
    string list or MultiSz buffer are nil.
}
procedure MultiSzToStrings(const MultiSz: PChar;
  const Strings: Classes.TStrings);

{
  ParseDelims:
    Returns the sub-string of TextLine that begins at StartPos and is terminated
    by one of the delimiting characters Delims or the end of the string.
    StartPos is updated to index of character after delimiter. Returns '' if
    there is no sub-string after StartPos.
}
function ParseDelims(const TextLine: string; var StartPos: Integer;
  const Delims: string): string;

{
  SplitStr:
    Splits the string S at the first occurence of delimiter character Delim and
    sets S1 to the sub-string before Delim and S2 to substring following Delim.
    If Delim is found in string True is returned, while if Delim is not in
    string False is returned, S1 is set to S and S2 is set to ''.
}
function SplitStr(const S: string; Delim: Char; out S1, S2: string): Boolean;

{
  StringsToMutliSz:
    Copies the strings from a given string list and stores in a provided
    MulitiSz buffer of a given size. The strings in the buffer are separated by
    #0 and the buffer is terminated by an additional #0. Returns 0 on success or
    required buffer size if MultiSz is nil or buffer size is too small. To get
    required buffer size call function with MultiSz=nil and BufSize=0.
}
function StringsToMutliSz(const Strings: Classes.TStrings;
  const MultiSz: PChar; const BufSize: Integer): Integer;

{
  AddToRecentDocs:
    Adds given file to Recent Documents folder that appears on the Start menu.
}
procedure AddToRecentDocs(const FileName: string);

{
  ClearRecentDocs:
    Clears the Recent Documents folder so that no recent documents appear on
    Start menu.
}
procedure ClearRecentDocs;

{
  CreateShellLink:
    Create a shell link named LinkFileName that is a shortcut to file
    AssocFileName with descriprion Desc. The shortcut activates its file in
    given Working Directory and passes given command line Args to
    AssocFileName. If an icon file and index offset are provided the required
    icon is used for the shortcut. Function returns true on success and false
    on error.
}
function CreateShellLink(const LinkFileName, AssocFileName, Desc, WorkDir,
  Args, IconFileName: string; const IconIdx: Integer): Boolean;

{
  EmptyRecycleBin:
    Empties the recycle bin. Returns returns true if bin is emptied and false if
    the function fails.
}
function EmptyRecycleBin: Boolean;

{
  ExecAndWait:
    Executes the given command line and waits for the program started by the
    command line to exit. Returns true if the program returns a zero exit code
    and false if the program doesn't start or returns a non-zero error code.
}
function ExecAndWait(const CommandLine: string): Boolean;

{
  ExecAssociatedApp:
    Executes the application associated with the given file name. Returns true
    if application is started successfully and false if not.
}
function ExecAssociatedApp(const FileName: string): Boolean;

{
  ExploreFolder:
    Starts Windows Explorer to explore given folder. Returns true if folder is
    valid and can be explored, or false otherwise.
}
function ExploreFolder(const Folder: string): Boolean;

{
  FindAssociatedApp:
    Returns the fully specified path of the program associated with the given
    document file name. Requires ShellAPI. Returns empty string if no such
    associated application.
}
function FindAssociatedApp(const Doc: string): string;

{
  FreePIDL:
    Uses to shell allocator to free the memory used by a given PIDL.
}
procedure FreePIDL(PIDL: ShlObj.PItemIDList);

{
  IsSpecialFolderSupported:
    Returns true if the given special folder specified by a CSIDL is supported
    on the system and false if not.
}
function IsSpecialFolderSupported(CSIDL: Integer): Boolean;

{
  OpenFolder:
    Opens given folder in Windows Explorer. Returns true if folder is valid and
    can be opened, or false otherwise.
}
function OpenFolder(const Folder: string): Boolean;

{
  PIDLToFolderPath:
    Returns the full path to a file system folder from a PIDL or '' if the PIDL
    refers to a virtual folder.
}
function PIDLToFolderPath(PIDL: ShlObj.PItemIDList): string;

{
  ShowFindFilesDlg:
    Displays the Windows find files dialog box ready for searching the given
    folder. Returns true if dialog is shown and false if can't be shown (e.g.
    if given folder is not valid).
}
function ShowFindFilesDlg(const Folder: string): Boolean;

{
  SpecialFolderPath:
    Returns the full path to a special file system folder specified by a CSIDL
    constant FolderID or '' if the special folder is virtual or CSIDL is not
    supported.
}
function SpecialFolderPath(CSIDL: Integer): string;

{
  TaskAllocWideString:
    Converts a given ANSI string to a wide string and stores in a buffer
    allocated by the Shell's task allocator. If the buffer needs to be freed
    IMalloc.Free should be used to do this.
}
function TaskAllocWideString(const S: string): Windows.PWChar;

{
  TaskbarHandle:
    Returns the window handle of the Windows task bar.
}
function WindowsTaskbarHandle: THandle;

{
  CommonFilesFolder:
    Returns directory used for common files.
}
function CommonFilesFolder: string;

{
  GetCurrentVersionRegStr:
    Gets given string value from given subkey of Windows current version
    registry key.
}
function GetCurrentVersionRegStr(const ValName: string): string;

{
  GetRegistryString:
    Gets a string value from the registry from the given root and sub key.
    Converts integers to strings and raises exception for binary and unknown
    value types. Returns '' if the sub key or value name are not known.
}
function GetRegistryString(const RootKey: Windows.HKEY;
  const SubKey, Name: string): string;

{
  IsIntResource:
    Returns true if the given resource ID is integer value or false if the ID is
    a pointer to a zero terminated string.
}
function IsIntResource(const ResID: PChar): Boolean;

{
  IsLockKeyOn:
    Detects if a given lock key is on and returns true if so. An exception is
    raised if KeyCode is not a valid lock key code. Valid lock key codes are
    VK_CAPITAL, VK_NUMLOCK and VK_SCROLL.
}
function IsLockKeyOn(const KeyCode: Integer): Boolean;

{
  IsWinNT:
    Returns true if the operating system is Windows NT (including 2000 and XP)
    and false if not.
}
function IsWinNT: Boolean;

{
  ProgramFilesFolder:
    Returns directory used for program files.
}
function ProgramFilesFolder: string;

{
  SetLockKeyState:
    Sets the given lock key state to given value. Passing True switches lock key
    on and passing False switches it off. An exception is raised if KeyCode is
    not a valid lock key code. Valid lock key codes are VK_CAPITAL, VK_NUMLOCK
    and VK_SCROLL.
}
procedure SetLockKeyState(KeyCode: Integer; IsOn: Boolean);

{
  SystemFolder:
    Returns path to Windows system folder.
}
function SystemFolder: string;

{
  TempFolder:
    Returns path to Windows temporary folder.
}
function TempFolder: string;

{
  WindowsFolder:
    Returns path to Windows folder.
}
function WindowsFolder: string;

{
  WindowsProductID:
    Returns the Windows product ID.
}
function WindowsProductID: string;

implementation

{ Implementation of public and private routines }

{
  WinFileTimeToDateTime:
    Converts Windows FILETIME to Delphi TDateTime. Raises exception if file time
    is not a valid value.
}

function WinFileTimeToDateTime(FT: Windows.TFileTime): TDateTime;
var
  SysTime: Windows.TSystemTime; // stores date/time in system time format
begin
  // Convert file time to system time, raising exception on error
  SysUtils.Win32Check(Windows.FileTimeToSystemTime(FT, SysTime));
  // Convert system time to Delphi date time, raising excpetion on error
  Result := SysUtils.SystemTimeToDateTime(SysTime);
end;

{
  WinFileTimeToDOSFileTime:
    Converts a Windows FILETIME to a DOS file time. Raises exception if file
    time is not a valid value.
}

function WinFileTimeToDOSFileTime(FT: Windows.TFileTime): Integer;
begin
  SysUtils.Win32Check(
    Windows.FileTimeToDosDateTime(
    FT, SysUtils.LongRec(Result).Hi, SysUtils.LongRec(Result).Lo
    )
    );
end;

{
  WinFileTimeToStr:
    Converts a Windows FILETIME structure to a string. Raises exception if file
    time is not a valid value.
}

function WinFileTimeToStr(FT: Windows.TFileTime): string;
begin
  Result := SysUtils.DateTimeToStr(WinFileTimeToDateTime(FT));
end;

{
  CopyFile:
    Copies Source file to Dest, preserving modification date.
}

procedure CopyFile(const Source, Dest: string);
var
  SourceStream, DestStream: Classes.TFileStream; // source and dest file streams
begin
  DestStream := nil;
  // Open source and dest file streams
  SourceStream := Classes.TFileStream.Create(
    Source, SysUtils.fmOpenRead or SysUtils.fmShareDenyWrite
    );
  try
    DestStream := Classes.TFileStream.Create(
      Dest, Classes.fmCreate or SysUtils.fmShareExclusive
      );
    // Copy file from source to dest
    DestStream.CopyFrom(SourceStream, SourceStream.Size);
    // Set dest file's modification date to same as source file
    SysUtils.FileSetDate(
      DestStream.Handle, SysUtils.FileGetDate(SourceStream.Handle)
      );
  finally
    // Close files
    DestStream.Free;
    SourceStream.Free;
  end;
end;

{
  CreateURLShortcut:
    Creates a URL shortcut file with the given name for the given URL,
    overwriting any existing file. An exception is raised if file can't be
    created.
}

procedure CreateURLShortcut(const ShortcutFile, URL: string);
var
  F: TextFile; // text file
begin
{$I+} // ensure file i/o raises exception on error
  // Open new file for writing (overwrites any existing file)
  AssignFile(F, ShortcutFile);
  Rewrite(F);
  try
    // Write file contents: this is simplest basic format of shortcut file
    WriteLn(F, '[InternetShortcut]');
    WriteLn(F, 'URL=', URL);
  finally
    // Close file
    CloseFile(F);
  end;
end;

{
  DeleteFiles:
    Deletes all files in the directory Dir that match the given wildcard and
    returns the number of files deleted. If Wildcard is '' then all files are
    deleted. Sub-directories of Dir are not deleted.
}

function DeleteFiles(const Dir, Wildcard: string): Integer;
var
  Files: Classes.TStringList; // stores files to be deleted
  I: Integer; // loops thru files in folder
  AFile: string; // a file to be deleted
  Path: string; // path to directory
  Attr: Integer; // attributes of a file
begin
  Result := 0;
  // Create list to stores files to be deleted
  Files := Classes.TStringList.Create;
  try
    // List files per file spec into string list
    if not ListFiles(Dir, Wildcard, Files) then
      Exit;
    // Get path of directory containing files
    Path := DirToPath(Dir);
    // Loop through all files
    for I := 0 to Pred(Files.Count) do
    begin
      // Get name and attributes of file to be deleted
      AFile := Path + Files[I];
      Attr := SysUtils.FileGetAttr(AFile);
      // Delete file if it is not a directory
      if (Attr and SysUtils.faDirectory = 0) then
      begin
        if SysUtils.DeleteFile(AFile) then
          // File deleted: count it
          Inc(Result);
      end;
    end;
  finally
    // Tidy up
    Files.Free;
  end;
end;

{
  DeleteFileWithUndo:
    Deletes given file and sends it to recycle bin. Returns true if file deleted
    successfully.
}

function DeleteFileWithUndo(const FileName: string): Boolean;
var
  FOS: ShellAPI.TSHFileOpStruct; // contains info about required file operation
begin
  // Set up structure that determines file operation
  FillChar(FOS, SizeOf(FOS), 0);
  with FOS do
  begin
    wFunc := ShellAPI.FO_DELETE; // we're deleting
    pFrom := PChar(FileName + #0); // this file (#0#0 terminated)
    fFlags := ShellAPI.FOF_ALLOWUNDO // with facility to undo op
      or ShellAPI.FOF_NOCONFIRMATION // and we don't want any dialogs
      or ShellAPI.FOF_SILENT;
  end;
  // Perform the operation
  Result := ShellAPI.SHFileOperation(FOS) = 0;
end;

{
  DirToPath:
    Returns the given directory with a trailing backslash. If the directory
    already ends in backslash it is returned unchanged.
}

function DirToPath(const Dir: string): string;
begin
  if (Dir <> '') and (Dir[Length(Dir)] <> '\') then
    Result := Dir + '\'
  else
    Result := Dir;
end;

{
  DOSToUnixPath:
    Converts a DOS path to a Unix path and returns it.
}

function DOSToUnixPath(const PathName: string): string;
begin
  Result := SysUtils.StringReplace(PathName, '\', '/', [SysUtils.rfReplaceAll]);
end;

{
  EnsureFolders:
    Ensures that the given folder and all folders on its path exist, and creates
    them if they do not. Uses recursion.
}

procedure EnsureFolders(Path: string);
var
  SlashPos: Integer; // position of last backslash in path
  SubPath: string; // immediate parent folder of given path
begin
  // Check there's a path to create
  if Length(Path) = 0 then
    Exit;
  // Remove any trailing '\'
  Path := PathToDir(Path);
  // Check if folder exists and quit if it does - we're done
  if IsDirectory(Path) then
    Exit;
  // Recursively call routine on immediate parent folder
  // remove bottomost folder from path - ie move up to parent folder
  SubPath := Path;
  SlashPos := Length(SubPath);
  while (SlashPos > 2) and (SubPath[SlashPos] <> '\') do
    Dec(SlashPos);
  Delete(SubPath, SlashPos, Length(Path) - SlashPos + 1);
  // do recursive call - ensures that parent folder of current path exist
  EnsureFolders(SubPath);
  // Create this current folder now we know parent folder exists
  SysUtils.CreateDir(Path);
end;

{
  GetFileDate:
    Returns modification date of given file encoded as integer.
}

function GetFileDate(const FName: string): Integer;
var
  FileH: Integer; // file handle
begin
  // Open file
  FileH := SysUtils.FileOpen(FName, SysUtils.fmOpenRead);
  if FileH = -1 then
    // Couldn't open file - return -1 to indicate can't get date
    Result := -1
  else
  begin
    // File opened OK - record date and close file
    Result := SysUtils.FileGetDate(FileH);
    SysUtils.FileClose(FileH);
  end;
end;

{
  GetFixedFileVerInfo:
    Extracts fixed version information from a file. If file contains version
    information it is returned via FFI parameter and function returns true,
    otherwise false is returned and FFI is undefined.
}

function GetFixedFileVerInfo(const FileName: string;
  out FFI: Windows.TVSFixedFileInfo): Boolean;
var
  VerInfoBuf: Pointer; // points to memory storing version info
  VerInfoSize: Integer; // size of version info memory
  Dummy: Windows.THandle; // unused parameter required by API function
  PFFI: Pointer; // points to fixed file info
  FFISize: LongWord; // size of file file info returned from API (unused)
begin
  // Assume failure: sets zero result
  FillChar(FFI, SizeOf(FFI), 0);
  Result := False;
  // Get size of version info: there is none if this is zero
  VerInfoSize := Windows.GetFileVersionInfoSize(PChar(FileName), Dummy);
  if VerInfoSize > 0 then
  begin
    // Allocate memory to store ver info
    GetMem(VerInfoBuf, VerInfoSize);
    try
      // Get the version info, filling buffer
      if Windows.GetFileVersionInfo(
        PChar(FileName), Dummy, VerInfoSize, VerInfoBuf
        ) then
      begin
        // Get a pointer to fixed file info
        if Windows.VerQueryValue(VerInfoBuf, '\', PFFI, FFISize) then
        begin
          // Got pointer OK: record file version
          FFI := Windows.PVSFixedFileInfo(PFFI)^;
          Result := True;
        end;
      end;
    finally
      // Dispose of ver info storage
      FreeMem(VerInfoBuf, VerInfoSize);
    end;
  end;
end;

{
  HasVerInfo:
    Returns true if the given file contains version information and false if
    not.
}

function HasVerInfo(const FileName: string): Boolean;
var
  Dummy: Windows.THandle; // dummy variable required by API function
begin
  // API function returns size of ver info: 0 if none
  Result := Windows.GetFileVersionInfoSize(PChar(FileName), Dummy) > 0;
end;

{
  IsDirectory:
    Returns true if given name is a valid directory and false otherwise. DirName
    can be any file system name (with or without trailing path delimiter).
}

function IsDirectory(const DirName: string): Boolean;
var
  Attr: Integer; // directory's file attributes
begin
  Attr := SysUtils.FileGetAttr(DirName);
  Result := (Attr <> -1)
    and (Attr and SysUtils.faDirectory = SysUtils.faDirectory);
end;

{
  IsURLShortcut:
    Returns true if the given file is a URL shortcut file and false if not.
}

function IsURLShortcut(const ShortcutFile: string): Boolean;
var
  Ini: IniFiles.TIniFile; // used to read ini files
begin
  // File must exist
  if SysUtils.FileExists(ShortcutFile) then
  begin
    // Open ini file and check value exists
    Ini := IniFiles.TIniFile.Create(ShortcutFile);
    try
      Result := Ini.SectionExists('InternetShortcut')
        and Ini.ValueExists('InternetShortcut', 'URL')
        and (Ini.ReadString('InternetShortcut', 'URL', '') <> '');
    finally
      Ini.Free;
    end;
  end
  else
    Result := False;
end;

{
  ListFiles:
    Gets a list of the files and sub-directories of the given directory that
    match the given wild card. The files are appended to the given string list.
    Returns true if Dir is a valid directory and False if not. If Wildcard is
    not specified, *.* is assumed.
}

function ListFiles(const Dir, Wildcard: string;
  const List: Classes.TStrings): Boolean;
var
  FileSpec: string; // search file specification
  SR: SysUtils.TSearchRec; // file search result
  Success: Integer; // success code for FindXXX routines
begin
  Assert(Assigned(List));
  // Check if true directory and exit if not
  Result := IsDirectory(Dir);
  if not Result then
    Exit;
  // Build file spec from directory and wildcard
  FileSpec := DirToPath(Dir);
  if Wildcard = '' then
    FileSpec := FileSpec + '*.*'
  else
    FileSpec := FileSpec + Wildcard;
  // Initialise search for matching files
  Success := SysUtils.FindFirst(FileSpec, SysUtils.faAnyFile, SR);
  try
    // Loop for all files in directory
    while Success = 0 do
    begin
      // only add true files or directories to list
      if (SR.Name <> '.') and (SR.Name <> '..')
        and (SR.Attr and SysUtils.faVolumeId = 0) then
        List.Add(SR.Name);
      // get next file
      Success := SysUtils.FindNext(SR);
    end;
  finally
    // Tidy up
    SysUtils.FindClose(SR);
  end;
end;

{
  LongToShortFilePath:
    Converts the given long file name to the equivalent shortened DOS style 8.3
    path.
}

function LongToShortFilePath(const LongName: string): string;
begin
  SetLength(Result, Windows.MAX_PATH);
  SetLength(
    Result,
    Windows.GetShortPathName(
    PChar(LongName), PChar(Result), Windows.MAX_PATH
    )
    );
end;

{
  PathToDir:
    Returns the given directory with any single trailing backslash removed. If
    the directory does not end in a backslash it is returned unchanged.
}

function PathToDir(const Path: string): string;
begin
  Result := Path;
  if (Path <> '') and (Path[Length(Path)] = '\') then
    Delete(Result, Length(Result), 1);
end;

{
  SetFileDate:
    Sets modification date of given file to given integer coded value.
}

procedure SetFileDate(const FName: string; const ADate: Integer);
var
  FileH: Integer; // file handle
begin
  // Open file
  FileH := SysUtils.FileOpen(FName, SysUtils.fmOpenWrite);
  if FileH <> -1 then
  begin
    // File opened OK - set date and close file
    SysUtils.FileSetDate(FileH, ADate);
    SysUtils.FileClose(FileH);
  end;
end;

{
  ShortToLongFilePath:
    Converts whole of given DOS style 8.3 path to long file path and returns it.
    If path can't be converted then '' is returned.
}

function ShortToLongFilePath(const FilePath: string): string;
var
  PrevPath: string; // path before last file/dir in FilePath
  ExpandedName: string; // long form of file name
  SR: SysUtils.TSearchRec; // record used by file find functions
  Success: Integer; // indicates success in finding a file
  // ---------------------------------------------------------------------------
  function CountPathDelims(const Name: string): Integer;
    {Counts path separators in given name}
  var
    Idx: Integer; // loops thru name string
  begin
    Result := 0;
    for Idx := 1 to Length(Name) do
      if SysUtils.IsPathDelimiter(Name, Idx) then
        Inc(Result);
  end;

  function IsServerName(const Name: string): Boolean;
    {Returns true if Names is in form \\Server\Share}
  begin
    Result := (SysUtils.AnsiPos('\\', Name) = 1)
      and (CountPathDelims(Name) = 3);
  end;
  // ---------------------------------------------------------------------------
begin
  // Check if we have a drive, server/share or root path, and exit if so
  // (we can't apply file search to any of these, so we return them unchanged
  if (FilePath = '')
    or (FilePath = '\')
    or ((Length(FilePath) = 2) and (FilePath[2] = ':'))
    or ((Length(FilePath) = 3) and (FilePath[2] = ':') and (FilePath[3] = '\'))
    or IsServerName(FilePath) then
  begin
    Result := FilePath;
    Exit;
  end;
  // Do a file search on file: this is used to expand name
  Success := SysUtils.FindFirst(FilePath, SysUtils.faAnyFile, SR);
  try
    if Success = 0 then
      ExpandedName := SR.FindData.cFileName
    else
      ExpandedName := '';
  finally
    SysUtils.FindClose(SR);
  end;
  // Check if there's any part of path we've not handled, and convert it if so
  PrevPath := SysUtils.ExtractFileDir(FilePath);
  if PrevPath <> '' then
  begin
    // We have unprocessed part of path: expand that
    Result := ShortToLongFilePath(PrevPath);
    // Appended currently expanded name to path
    if (Result <> '') and (Result[Length(Result)] <> '\') then
      Result := Result + '\';
    Result := Result + ExpandedName;
  end
  else
    // No earlier parts of path: just record expanded name
    Result := ExpandedName;
end;

{
  TempFileName:
    Returns a unique temporary file name in temporary folder. File name includes
    first three characters of Stub followed by hexadecimal characters. If Create
    is true file is created. Returns empty string on failure.
}

function TempFileName(const Stub: string; const Create: Boolean): string;
begin
  // Get temporary folder
  SetLength(Result, Windows.MAX_PATH);
  Windows.GetTempPath(Windows.MAX_PATH, PChar(Result));
  // Get unique temporary file name (it is created as side effect of this call)
  if Windows.GetTempFileName(
    PChar(Result), PChar(Stub), 0, PChar(Result)
    ) <> 0 then
  begin
    // Succeeded
    Result := PChar(Result);
    if not Create then
      // user doesn't want file creating: so we delete the file
      SysUtils.DeleteFile(Result);
  end
  else
    // Failed
    Result := '';
end;

{
  Touch:
    Sets modification date of given file to current date and time. Returns true
    if date set successfully or false on error.
}

function Touch(const FileName: string): Boolean;
var
  FileH: Integer; // handle of file
begin
  // Assume failure
  Result := False;
  // Try to open file: bail out if can't open
  FileH := SysUtils.FileOpen(
    FileName, SysUtils.fmOpenWrite or SysUtils.fmShareDenyWrite
    );
  if FileH = -1 then
    Exit;
  try
    // Set date to current date and time: return true if succeed
    if SysUtils.FileSetDate(
      FileH, SysUtils.DateTimeToFileDate(SysUtils.Now())
      ) = 0 then
      Result := True;
  finally
    // Close the file
    SysUtils.FileClose(FileH);
  end;
end;

{
  URLFromShortcut:
    Returns the URL referenced by the given URL shortcut file, or the empty
    string if the given file is not a shortcut file.
}

function URLFromShortcut(const Shortcut: string): string;
var
  Ini: IniFiles.TIniFile; // object used to read shortcut file
begin
  // Return URL item from [InternetShortcut] section of shortcut file
  Ini := IniFiles.TIniFile.Create(Shortcut);
  try
    try
      Result := Ini.ReadString('InternetShortcut', 'URL', '');
    except;
      // We return '' on error
      Result := '';
    end;
  finally
    Ini.Free;
  end;
end;

{
  FileToString:
    Stores content of a file in an ANSI string.
}

function FileToString(const FileName: string): string;
var
  FS: Classes.TFileStream; // stream used to read file
begin
  // Open stream to file and copy stream to string
  FS := Classes.TFileStream.Create(
    FileName, SysUtils.fmOpenRead or SysUtils.fmShareDenyNone
    );
  try
    Result := StreamToString(FS);
  finally
    FS.Free;
  end;
end;

{
  IsUnicodeFile:
    Checks if a file contains unicode text and returns true if so and false if
    not.
}

function IsUnicodeFile(const FileName: string): Boolean;
var
  FS: Classes.TFileStream; // stream onto file being tested
begin
  // Open stream to file and examine stream for unicode marker
  FS := Classes.TFileStream.Create(
    FileName, SysUtils.fmOpenRead or SysUtils.fmShareDenyNone
    );
  try
    Result := IsUnicodeStream(FS);
  finally
    FS.Free;
  end;
end;

{
  IsUnicodeStream:
    Checks if a stream contains unicode text at the current position. Returns
    true if stream contains unicode and false otherwise.
}

function IsUnicodeStream(const Stm: Classes.TStream): Boolean;
var
  StmPos: Int64; // current position in stream
  UnicodeMarker: Word; // marker that indicates a unicode stream
begin
  // Record current location in stream
  StmPos := Stm.Position;
  // Check if stream large enough to contain unicode marker
  if StmPos <= Stm.Size - SizeOf(Word) then
  begin
    // Read first word and check if it is the unicode marker
    Stm.ReadBuffer(UnicodeMarker, SizeOf(UnicodeMarker));
    Result := (UnicodeMarker = $FEFF);
    // Restore stream positions
    Stm.Position := StmPos;
  end
  else
    // Stream too small: can't be unicode
    Result := False;
end;

{
  StreamToString:
    Reads content of a stream into an ansi string. Stream is read from current
    positions.
}

function StreamToString(const Stm: Classes.TStream): string;
var
  SS: Classes.TStringStream; // used to copy stream to string
begin
  SS := Classes.TStringStream.Create('');
  try
    // Copy given stream to string stream and return value
    SS.CopyFrom(Stm, 0);
    Result := SS.DataString;
  finally
    SS.Free;
  end;
end;

{
  StringToFile:
    Writes an ansi string to a text file.
}

procedure StringToFile(const Str, FileName: string);
var
  FS: Classes.TFileStream; // stream used to write file
begin
  // Create stream onto file and write to it
  FS := Classes.TFileStream.Create(FileName, Classes.fmCreate);
  try
    StringToStream(Str, FS);
  finally
    FS.Free;
  end;
end;

{
  StringToStream:
    Writes an ansi string into a stream. The string is written at the current
    stream position.
}

procedure StringToStream(const Str: string; const Stm: Classes.TStream);
var
  SS: Classes.TStringStream; // used to copy string to stream
begin
  // Create stream onto string and copy it to given stream
  SS := Classes.TStringStream.Create(Str);
  try
    Stm.CopyFrom(SS, Length(Str));
  finally
    SS.Free;
  end;
end;

{
  UnicodeFileToWideString:
    Reads a file into a wide string an returns it. The routine can handle
    unicode files or ansi text files. Ansi files are converted to wide strings.
}

function UnicodeFileToWideString(const FileName: string): WideString;
var
  FS: Classes.TFileStream; // Stream used to read file
begin
  // Open stream onto file and read unicode from it
  FS := Classes.TFileStream.Create(
    FileName, SysUtils.fmOpenRead or SysUtils.fmShareDenyNone);
  try
    Result := UnicodeStreamToWideString(FS);
  finally
    FS.Free;
  end;
end;

{
  UnicodeStreamToWideString:
    Reads from a stream into a wide string an returns the string. The routine
    can handle unicode or ansi content on the stream. If the text is unicode
    the word at the current stream position must be a unicode marker word. Ansi
    files are converted to wide strings.
}

function UnicodeStreamToWideString(const Stm: Classes.TStream): WideString;
var
  DataSize: Int64; // size of the unicode in bytes
begin
  if IsUnicodeStream(Stm) then
  begin
    // Data on stream is unicode
    // set size of unicode (excluding marker word)
    DataSize := Stm.Size - Stm.Position - SizeOf(Word);
    // size must be multiple of size of unicode char
    if DataSize mod SizeOf(WideChar) <> 0 then
      Classes.EStreamError.CreateFmt(
        'Remaining data in stream must be a mulitple of %d bytes',
        [SizeOf(WideChar)]
        );
    // Skip over unicode marker
    Stm.Position := Stm.Position + SizeOf(Word);
    // Read stream into result
    SetLength(Result, DataSize div SizeOf(WideChar));
    Stm.ReadBuffer(PByte(PWideChar(Result))^, DataSize);
  end
  else
    // Data on stream is not unicode: read it with ansi reader
    // result of StreamToString is automatically converted to WideString
    Result := StreamToString(Stm);
end;

{
  WideStringToUnicodeFile:
    Writes a wide string to a unicode text file. The text file begins with a
    marker to indicate it is unicode.
}

procedure WideStringToUnicodeFile(const Str: WideString;
  const FileName: string);
var
  FS: Classes.TFileStream; // Stream onto file being created
begin
  // Open stream onto file and write unicode to it
  FS := Classes.TFileStream.Create(FileName, Classes.fmCreate);
  try
    WideStringToUnicodeStream(Str, FS);
  finally
    FS.Free;
  end;
end;

{
  WideStringToUnicodeStream:
    Writes a wide string to a stream in unicode format. The output begins with a
    marker to indicate it is unicode.
}

procedure WideStringToUnicodeStream(const Str: WideString;
  const Stm: Classes.TStream);
var
  UnicodeMarker: Word; // Marker that begins unicode
begin
  // Write out unicode marker
  UnicodeMarker := $FEFF;
  Stm.WriteBuffer(UnicodeMarker, SizeOf(Word));
  // Write unicode text
  Stm.WriteBuffer(PByte(PWideChar(Str))^, SizeOf(WideChar) * Length(Str));
end;

{
  DriveDisplayName:
    Returns the display name for the drive with the given root path.
}

function DriveDisplayName(const Drive: string): string;
var
  FI: ShellAPI.TSHFileInfo; // info about drive
begin
  if ShellAPI.SHGetFileInfo(
    PChar(Drive),
    0,
    FI,
    SizeOf(FI),
    ShellAPI.SHGFI_DISPLAYNAME
    ) = 0 then
    SysUtils.RaiseLastWin32Error;
  Result := FI.szDisplayName;
end;

{
  DriveDisplayNames:
    Gets list of display names for all the system's drives and stores in a given
    string list.
}

procedure DriveDisplayNames(const List: Classes.TStrings);
var
  Drives: Classes.TStringList; // list of drives
  Idx: Integer; // loops thru drives
begin
  // Get list of drives
  Drives := Classes.TStringList.Create;
  try
    ListDrives(Drives);
    // Loop thru drive list getting drive info
    for Idx := 0 to Pred(Drives.Count) do
      List.Add(DriveDisplayName(Drives[Idx]));
  finally
    Drives.Free;
  end;
end;

{
  DriveRootPath:
    Returns root drive path for drive with given number.
}

function DriveRootPath(const DriveNum: Byte): string;
begin
  if DriveNum in [0..25] then
    Result := Char(DriveNum + Ord('A')) + ':\'
  else
    Result := '';
end;

{
  DriveTypeFromPath:
    Returns type of drive that contains the given (full) path.
}

function DriveTypeFromPath(const Path: string): LongWord;
var
  Drive: string; // the drive name
begin
  Drive := SysUtils.ExtractFileDrive(Path) + '\';
  Result := Windows.GetDriveType(PChar(Drive));
end;

{
  HardDiskSerial:
    Returns the serial number of the hard disk with the given root path or 0 if
    the disk is not a hard drive or has no serial number.
}

function HardDiskSerial(const Drive: string): Windows.DWORD;
var
  Unused: Windows.DWORD; // unused parameters
begin
  Result := 0;
  Windows.GetVolumeInformation(
    PChar(Drive), nil, 0, @Result, Unused, Unused, nil, 0
    );
end;

{
  IsValidDrive:
    Returns true if the given drive path represents a valid drive and false
    otherwise.
}

function IsValidDrive(const Drive: string): Boolean;
begin
  Result := DriveTypeFromPath(Drive) <> 1;
end;

{
  IsValidDriveNum:
    Returns true if the drive specified by the given number is valid and false
    otherwise.
}

function IsValidDriveNum(const DriveNum: Byte): Boolean;
begin
  if DriveNum in [0..25] then
    Result := Windows.GetLogicalDrives and (1 shl DriveNum) <> 0
  else
    Result := False;
end;

{
  ListDrives:
    Gets list of the system's drive root paths and stores in a given string list
}

procedure ListDrives(const List: Classes.TStrings);
var
  Drives: PChar; // buffer for list of drives
  BufSize: Integer; // size of drive buffer
begin
  // Get buffer size and allocate it
  BufSize := Windows.GetLogicalDriveStrings(0, nil);
  GetMem(Drives, BufSize);
  try
    // Get #0 delimited drives list and convert to string list
    if Windows.GetLogicalDriveStrings(BufSize, Drives) = 0 then
      SysUtils.RaiseLastWin32Error;
    MultiSzToStrings(Drives, List);
  finally
    FreeMem(Drives);
  end;
end;

{
  BrowseURL:
    Activates default browser or email client for given URL. Returns true if
    browser/email client is uccessfully launched and false if not. Raises
    exception if URL doesn't conform to a known valid protocol.
}

function BrowseURL(const URL: string): Boolean;
begin
  if not IsValidURLProtocol(URL) then
    raise SysUtils.Exception.CreateFmt('"%s" is not a valid URL', [URL]);
  Result := ExecAssociatedApp(URL);
end;

{
  ColorToHTML:
    Converts a Delphi TColor value into a string suitable for use in HTML or CSS
    code. Any system colors (like clBtnFace) are mapped to the actual colour
    according to the current Windows settings.
}

function ColorToHTML(const Color: Graphics.TColor): string;
var
  ColorRGB: Integer;
begin
  ColorRGB := Graphics.ColorToRGB(Color);
  Result := SysUtils.Format(
    '#%0.2X%0.2X%0.2X',
    [Windows.GetRValue(ColorRGB),
    Windows.GetGValue(ColorRGB),
      Windows.GetBValue(ColorRGB)]
      );
end;

{
  DownloadURLToFile:
    Downloads file at URL and stores in given file. Returns true if download
    succeeds and false on failure. A connection to the internet must be open
    for download to succeed.
}

function DownloadURLToFile(const URL, FileName: string): Boolean;
begin
  // URLDownloadFile returns true if URL exists even if file not created
  // hence we also check file has been created.
  Result := Windows.Succeeded(
    UrlMon.URLDownloadToFile(nil, PChar(URL), PChar(FileName), 0, nil)
    ) and SysUtils.FileExists(FileName);
end;

{
  IsValidURLProtocol:
    Checks if the given URL is valid per RFC1738. Returns true is valid and
    false if not.
}

function IsValidURLProtocol(const URL: string): Boolean;
const
  CNumProtocols = 10; // number of known protocols
  CProtocols: array[1..CNumProtocols] of string = (
    // Array of valid protocols - per RFC 1738
    'ftp://', 'http://', 'gopher://', 'mailto:', 'news:', 'nntp://',
    'telnet://', 'wais://', 'file://', 'prospero://'
    );
var
  I: Integer; // loops thru known protocols
begin
  // Scan array of protocols checking for a match with start of given URL
  Result := False;
  for I := 1 to CNumProtocols do
    if Pos(CProtocols[I], SysUtils.LowerCase(URL)) <> 0 then
    begin
      Result := True;
      Break;
    end;
end;

{
  MakeSafeHTMLText:
    Replaces any characters in the given text that are HTML-compatible with
    suitable escaped versions and returns modified string.
}

function MakeSafeHTMLText(TheText: string): string;
var
  Idx: Integer; // loops thru the given text
begin
  Result := '';
  for Idx := 1 to Length(TheText) do
    case TheText[Idx] of
      '<': // opens tags: replace with special char reference
        Result := Result + '&lt;';
      '>': // closes tags: replace with special char reference
        Result := Result + '&gt;';
      '&': // begins char references: replace with special char reference
        Result := Result + '&amp;';
      '"': // quotes (can be a problem in quoted attributes)
        Result := Result + '&quot;';
      #0..#31, #127..#255: // control and special chars: replace with encoding
        Result := Result + '&#' + SysUtils.IntToStr(Ord(TheText[Idx])) + ';';
    else // compatible text: pass thru
      Result := Result + TheText[Idx];
    end;
end;

{
  URLDecode:
    Decodes the given encoded URL or URL query string. Raises exception if the
    encoded URL is badly formed.
}

function URLDecode(const S: string): string;
var
  Idx: Integer; // loops thru chars in string
  Hex: string; // string of hex characters
  Code: Integer; // hex character code (-1 on error)
begin
  // Intialise result and string index
  Result := '';
  Idx := 1;
  // Loop thru string decoding each character
  while Idx <= Length(S) do
  begin
    case S[Idx] of
      '%':
        begin
        // % should be followed by two hex digits - exception otherwise
          if Idx <= Length(S) - 2 then
          begin
          // there are sufficient digits - try to decode hex digits
            Hex := S[Idx + 1] + S[Idx + 2];
            Code := SysUtils.StrToIntDef('$' + Hex, -1);
            Inc(Idx, 2);
          end
          else
          // insufficient digits - error
            Code := -1;
        // check for error and raise exception if found
          if Code = -1 then
            raise SysUtils.EConvertError.Create(
              'Invalid hex digit in URL'
              );
        // decoded OK - add character to result
          Result := Result + Chr(Code);
        end;
      '+':
        // + is decoded as a space
        Result := Result + ' '
    else
        // All other characters pass thru unchanged
      Result := Result + S[Idx];
    end;
    Inc(Idx);
  end;
end;

{
  URLEncode:
    Encodes the given string, making it suitable for use in a URL. The function
    can encode strings for use in the main part of a URL (where spaces are
    encoded as '%20') or in URL query strings (where spaces are encoded as '+'
    characters). Set InQueryString to true to encode for a query string.
}

function URLEncode(const S: string; const InQueryString: Boolean): string;
var
  Idx: Integer; // loops thru characters in string
begin
  Result := '';
  for Idx := 1 to Length(S) do
  begin
    case S[Idx] of
      'A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.':
        Result := Result + S[Idx];
      ' ':
        if InQueryString then
          Result := Result + '+'
        else
          Result := Result + '%20';
    else
      Result := Result + '%' + SysUtils.IntToHex(Ord(S[Idx]), 2);
    end;
  end;
end;

{
  CompressWhiteSpace:
    Returns a copy of given string with all white space characters replaced by
    space characters and all sequences of white space replaced by a single
    space character.
}

function CompressWhiteSpace(const S: string): string;
var
  Idx: Integer; // loops thru all characters in string
  ResCount: Integer; // counts number of characters in result string
  PRes: PChar; // pointer to characters in result string
const
  // The white space characters we convert to spaces
  cWhiteSpace = [#9, #10, #11, #12, #13, ' '];
begin
  // Set length of result to length of source string and set pointer to it
  SetLength(Result, Length(S));
  PRes := PChar(Result);
  // Reset count of characters in result string
  ResCount := 0;
  // Loop thru characters of source string
  Idx := 1;
  while Idx <= Length(S) do
  begin
    if S[Idx] in cWhiteSpace then
    begin
      // Current char is white space: replace by space char and count it
      PRes^ := ' ';
      Inc(PRes);
      Inc(ResCount);
      // Skip past any following white space
      Inc(Idx);
      while S[Idx] in cWhiteSpace do
        Inc(Idx);
    end
    else
    begin
      // Current char is not white space: copy it literally and count it
      PRes^ := S[Idx];
      Inc(PRes);
      Inc(ResCount);
      Inc(Idx);
    end;
  end;
  // Reduce length of result string if it is shorter than source string
  if ResCount < Length(S) then
    SetLength(Result, ResCount);
end;

{
  CountDelims:
    Returns count of all occurences of any of the given delimiter characters in
    the string S.
}

function CountDelims(const S, Delims: string): Integer;
var
  Idx: Integer; //loops thru all characters in string
begin
  Result := 0;
  for Idx := 1 to Length(S) do
    if SysUtils.IsDelimiter(Delims, S, Idx) then
      Inc(Result);
end;

{
  ExplodeStr:
    Splits the string S into a list of strings, separated by Delim, and returns
    the number of strings in the list. If AllowEmpty is true then any empty
    strings are added to the list, while they are ignored if AllowEmpty is
    false.
}

function ExplodeStr(S: string; const Delim: Char; const List: Classes.TStrings;
  const AllowEmpty: Boolean = True): Integer;
var
  Item: string; // current delimted text
  Remainder: string; // remaining unconsumed part of string
begin
  // Clear the list
  List.Clear;
  // Check we have some entries in the string
  if S <> '' then
  begin
    // Repeatedly split string until we have no more entries
    while SplitStr(S, Delim, Item, Remainder) do
    begin
      // Add the current string, is required
      if (Item <> '') or AllowEmpty then
        List.Add(Item);
      // Go round again with remainder of string
      S := Remainder;
    end;
    // Add any terminal item
    if (Item <> '') or AllowEmpty then
      List.Add(Item);
  end;
  // Return number of items read
  Result := List.Count;
end;

{
  JoinStr:
    Joins all strings in given string list together into single string separated
    by given delimiter. If AllowEmpty is true then any empty strings are
    included in output string, but are ignored if false.
}

function JoinStr(const SL: Classes.TStrings; const Delim: string;
  const AllowEmpty: Boolean = True): string;
var
  Idx: Integer; // loops thru all items in string list
begin
  Result := '';
  for Idx := 0 to Pred(SL.Count) do
  begin
    if (SL[Idx] <> '') or AllowEmpty then
      if Result = '' then
        Result := SL[Idx]
      else
        Result := Result + Delim + SL[Idx];
  end;
end;

{
  MultiSzToStrings:
    Splits out individual strings from given 'MultiSz' strings buffer and adds
    each string to the given string list. A MultiSz string is a sequence of #0
    delimited strings terminated by an extra #0 character. Does nothing if
    string list or MultiSz buffer are nil.
}

procedure MultiSzToStrings(const MultiSz: PChar;
  const Strings: Classes.TStrings);
var
  P: PChar; // pointer to strings in buffer
begin
  // Do nothing in MultiSz is nil
  if not Assigned(MultiSz) then
    Exit;
  // Scan thru #0 delimited strings until #0#0 found
  P := MultiSz;
  while P^ <> #0 do
  begin
    // add string to list
    Strings.Add(P);
    // move pointer to start of next string if any
    Inc(P, SysUtils.StrLen(P) + 1);
  end;
end;

{
  ParseDelims:
    Returns the sub-string of TextLine that begins at StartPos and is terminated
    by one of the delimiting characters Delims or the end of the string.
    StartPos is updated to index of character after delimiter. Returns '' if
    there is no sub-string after StartPos.
}

function ParseDelims(const TextLine: string; var StartPos: Integer;
  const Delims: string): string;
var
  StringEnd: Integer; // tracks end of current string being parsed out
begin
  // Find next non-delimiter char - this is where token starts
  while (StartPos <= Length(TextLine))
    and SysUtils.IsDelimiter(Delims, TextLine, StartPos) do
    Inc(StartPos);
  // Now find next delimiter - this is where token ends
  StringEnd := StartPos;
  while (StringEnd <= Length(TextLine))
    and not SysUtils.IsDelimiter(Delims, TextLine, StringEnd) do
    Inc(StringEnd);
  // Copy result out of string
  Result := Copy(TextLine, StartPos, StringEnd - StartPos);
  StartPos := StringEnd + 1;
end;

{
  SplitStr:
    Splits the string S at the first occurence of delimiter character Delim and
    sets S1 to the sub-string before Delim and S2 to substring following Delim.
    If Delim is found in string True is returned, while if Delim is not in
    string False is returned, S1 is set to S and S2 is set to ''.
}

function SplitStr(const S: string; Delim: Char; out S1, S2: string): Boolean;
var
  DelimPos: Integer; // position of delimiter in source string
begin
  // Find position of first occurence of delimter in string
  DelimPos := SysUtils.AnsiPos(Delim, S);
  if DelimPos > 0 then
  begin
    // Delimiter found: do split and return True
    S1 := Copy(S, 1, DelimPos - 1);
    S2 := Copy(S, DelimPos + 1, MaxInt);
    Result := True;
  end
  else
  begin
    // Delimeter not found: return false and set S1 to whole string
    S1 := S;
    S2 := '';
    Result := False;
  end;
end;

{
  StringsToMutliSz:
    Copies the strings from a given string list and stores in a provided
    MulitiSz buffer of a given size. The strings in the buffer are separated by
    #0 and the buffer is terminated by an additional #0. Returns 0 on success or
    required buffer size if MultiSz is nil or buffer size is too small. To get
    required buffer size call function with MultiSz=nil and BufSize=0.
}

function StringsToMutliSz(const Strings: Classes.TStrings;
  const MultiSz: PChar; const BufSize: Integer): Integer;
var
  ReqSize: Integer; // required buffer size
  Idx: Integer; // loops thru Strings
  P: PChar; // pointer into MultiSz
begin
  Result := 0;
  if not Assigned(Strings) then
    Exit;
  // Get required size of buffer
  ReqSize := 1;
  for Idx := 0 to Pred(Strings.Count) do
    Inc(ReqSize, Length(Strings[Idx]) + 1);
  if (BufSize >= ReqSize) and Assigned(MultiSz) then
  begin
    // BufSize OK and MultiSz not nil: copy string and return zero
    P := MultiSz;
    for Idx := 0 to Pred(Strings.Count) do
    begin
      // copy current string, #0 terminated
      SysUtils.StrPCopy(P, Strings[Idx]);
      // moves to next pos in buffer
      Inc(P, Length(Strings[Idx]) + 1);
    end;
    // add terminating additional #0
    P^ := #0;
  end
  else
    // BufSize too small or MultiSz is nil: return required size
    Result := ReqSize;
end;

{
  AddToRecentDocs:
    Adds given file to Recent Documents folder that appears on the Start menu.
}

procedure AddToRecentDocs(const FileName: string);
begin
  ShlObj.SHAddToRecentDocs(ShlObj.SHARD_PATH, PChar(FileName));
end;

{
  ClearRecentDocs:
    Clears the Recent Documents folder so that no recent documents appear on
    Start menu.
}

procedure ClearRecentDocs;
begin
  ShlObj.SHAddToRecentDocs(ShlObj.SHARD_PATH, nil);
end;

{
  CreateShellLink:
    Create a shell link named LinkFileName that is a shortcut to file
    AssocFileName with descriprion Desc. The shortcut activates its file in
    given Working Directory and passes given command line Args to
    AssocFileName. If an icon file and index offset are provided the required
    icon is used for the shortcut. Function returns true on success and false
    on error.
}

function CreateShellLink(const LinkFileName, AssocFileName, Desc, WorkDir,
  Args, IconFileName: string; const IconIdx: Integer): Boolean;
var
  SL: ShlObj.IShellLink; // shell link object
  PF: ActiveX.IPersistFile; // persistant file interface to shell link object
begin
  // Assume failure
  Result := False;
  // Ensure COM is initialised
  ActiveX.CoInitialize(nil);
  try
    // Create shell link object
    if ActiveX.Succeeded(
      ActiveX.CoCreateInstance(
      ShlObj.CLSID_ShellLink,
      nil,
      ActiveX.CLSCTX_INPROC_SERVER,
      ShlObj.IShellLink, SL
      )
      ) then
    begin
      // Store required properties of shell link
      SL.SetPath(PChar(AssocFileName));
      SL.SetDescription(PChar(Desc));
      SL.SetWorkingDirectory(PChar(WorkDir));
      SL.SetArguments(PChar(Args));
      if (IconFileName <> '') and (IconIdx >= 0) then
        SL.SetIconLocation(PChar(IconFileName), IconIdx);
      // Create persistant file interface to shell link to save link file
      PF := SL as ActiveX.IPersistFile;
      Result := ActiveX.Succeeded(
        PF.Save(PWideChar(WideString(LinkFileName)), True)
        );
    end;
  finally
    // Finalize COM
    ActiveX.CoUninitialize;
  end;
end;

{
  EmptyRecycleBin:
    Empties the recycle bin. Returns returns true if bin is emptied and false if
    the function fails.
}

function EmptyRecycleBin: Boolean;
const
  // Flags passed to SHEmptyRecycleBin
  SHERB_NOCONFIRMATION = $00000001;
  SHERB_NOPROGRESSUI = $00000002;
  SHERB_NOSOUND = $00000004;
  // DLL containing function
  cDLLName = 'Shell32.dll';
  // Function name
  cFnName = 'SHEmptyRecycleBinA';
type
  // Prototype of API function
  TSHEmptyRecycleBin = function(
    Wnd: Windows.HWND;
    pszRootPath: PChar;
    dwFlags: Windows.DWORD
    ): HRESULT; stdcall;
var
  SHEmptyRecycleBin: TSHEmptyRecycleBin; // API function address
  DLLHandle: Windows.THandle; // Handle of required DLL
begin
  // Assume failure
  Result := False;
  // Load required DLL
  DLLHandle := Windows.LoadLibrary(cDLLName);
  if DLLHandle <> 0 then
  begin
    try
      // Get reference of API function from DLL
      @SHEmptyRecycleBin := Windows.GetProcAddress(DLLHandle, cFnName);
      if Assigned(@SHEmptyRecycleBin) then
      begin
        // Try to empty recycle bin
        Result := Windows.Succeeded(
          SHEmptyRecycleBin(
          0,
          nil,
          SHERB_NOCONFIRMATION or SHERB_NOSOUND or SHERB_NOPROGRESSUI
          )
          );
      end;
    finally
      Windows.FreeLibrary(DLLHandle);
    end;
  end;
end;

{
  ExecAndWait:
    Executes the given command line and waits for the program started by the
    command line to exit. Returns true if the program returns a zero exit code
    and false if the program doesn't start or returns a non-zero error code.
}

function ExecAndWait(const CommandLine: string): Boolean;
var
  StartupInfo: Windows.TStartupInfo; // start-up info passed to process
  ProcessInfo: Windows.TProcessInformation; // info about the process
  ProcessExitCode: Windows.DWord; // process's exit code
begin
  // Set default error result
  Result := False;
  // Initialise startup info structure to 0, and record length
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  // Execute application commandline
  if Windows.CreateProcess(nil, PChar(CommandLine),
    nil, nil, False, 0, nil, nil,
    StartupInfo, ProcessInfo) then
  begin
    try
      // Now wait for application to complete
      if Windows.WaitForSingleObject(ProcessInfo.hProcess, INFINITE)
        = WAIT_OBJECT_0 then
        // It's completed - get its exit code
        if Windows.GetExitCodeProcess(ProcessInfo.hProcess,
          ProcessExitCode) then
          // Check exit code is zero => successful completion
          if ProcessExitCode = 0 then
            Result := True;
    finally
      // Tidy up
      Windows.CloseHandle(ProcessInfo.hProcess);
      Windows.CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;

{
  ExecAssociatedApp:
    Executes the application associated with the given file name. Returns true
    if application is started successfully and false if not.
}

function ExecAssociatedApp(const FileName: string): Boolean;
begin
  Result := ShellAPI.ShellExecute(
    0,
    nil,
    PChar(FileName),
    nil,
    nil,
    Windows.SW_SHOW
    ) > 32;
end;

{
  ExploreFolder:
    Starts Windows Explorer to explore given folder. Returns true if folder is
    valid and can be explored, or false otherwise.
}

function ExploreFolder(const Folder: string): Boolean;
begin
  if SysUtils.FileGetAttr(Folder) and faDirectory = faDirectory then
    // Folder is valid directory: try to explore it
    Result := ShellAPI.ShellExecute(
      0, 'explore', PChar(Folder), nil, nil, Windows.SW_SHOWNORMAL
      ) > 32
  else
    // Folder is not a directory: error
    Result := False;
end;

{
  FindAssociatedApp:
    Returns the fully specified path of the program associated with the given
    document file name. Requires ShellAPI. Returns empty string if no such
    associated application.
}

function FindAssociatedApp(const Doc: string): string;
var
  PExecFile: array[0..Windows.MAX_PATH] of Char; // buffer to hold exe name
begin
  // Win API call in ShellAPI
  if ShellAPI.FindExecutable(PChar(Doc), nil, PExecFile) < 32 then
    // No associated program found
    Result := ''
  else
    // Return program file name
    Result := PExecFile;
end;

{
  FreePIDL:
    Uses to shell allocator to free the memory used by a given PIDL.
}

procedure FreePIDL(PIDL: ShlObj.PItemIDList);
var
  Malloc: ActiveX.IMalloc; // shell's allocator
begin
  // Try to get shell allocator
  if Windows.Succeeded(ShlObj.SHGetMalloc(Malloc)) then
    // Use allocator to free PIDL: Malloc is freed by Delphi
    Malloc.Free(PIDL);
end;

{
  IsSpecialFolderSupported:
    Returns true if the given special folder specified by a CSIDL is supported
    on the system and false if not.
}

function IsSpecialFolderSupported(CSIDL: Integer): Boolean;
var
  PIDL: ShlObj.PItemIDList; // PIDL of the special folder
begin
  // Try to get PIDL for folder: fails if not supported
  Result := Windows.Succeeded(
    ShlObj.SHGetSpecialFolderLocation(0, CSIDL, PIDL)
    );
  if Result then
    // Free the PIDL using shell allocator
    FreePIDL(PIDL);
end;

{
  OpenFolder:
    Opens given folder in Windows Explorer. Returns true if folder is valid and
    can be opened, or false otherwise.
}

function OpenFolder(const Folder: string): Boolean;
begin
  if SysUtils.FileGetAttr(Folder) and faDirectory = faDirectory then
    // Folder is valid directory: try to open it
    Result := ShellAPI.ShellExecute(
      0, 'open', PChar(Folder), nil, nil, Windows.SW_SHOWNORMAL
      ) > 32
  else
    // Folder is not a directory: error
    Result := False;
end;

{
  PIDLToFolderPath:
    Returns the full path to a file system folder from a PIDL or '' if the PIDL
    refers to a virtual folder.
}

function PIDLToFolderPath(PIDL: ShlObj.PItemIDList): string;
begin
  // Set max length of return string
  SetLength(Result, Windows.MAX_PATH);
  // Get the path
  if ShlObj.SHGetPathFromIDList(PIDL, PChar(Result)) then
    Result := PChar(Result)
  else
    Result := '';
end;

{
  ShowFindFilesDlg:
    Displays the Windows find files dialog box ready for searching the given
    folder. Returns true if dialog is shown and false if can't be shown (e.g.
    if given folder is not valid).
}

function ShowFindFilesDlg(const Folder: string): Boolean;
begin
  Result := ShellAPI.ShellExecute(
    0, 'find', PChar(Folder), '', '', Windows.SW_SHOW
    ) > 32;
end;

{
  SpecialFolderPath:
    Returns the full path to a special file system folder specified by a CSIDL
    constant FolderID or '' if the special folder is virtual or CSIDL is not
    supported.
}

function SpecialFolderPath(CSIDL: Integer): string;
var
  PIDL: ShlObj.PItemIDList; // PIDL of the special folder
begin
  Result := '';
  // Get PIDL for required folder
  if Windows.Succeeded(
    ShlObj.SHGetSpecialFolderLocation(0, CSIDL, PIDL)
    ) then
  begin
    try
      // Get path from PIDL
      Result := PIDLToFolderPath(PIDL);
    finally
      // Free the PIDL using shell allocator
      FreePIDL(PIDL);
    end;
  end
end;

{
  TaskAllocWideString:
    Converts a given ANSI string to a wide string and stores in a buffer
    allocated by the Shell's task allocator. If the buffer needs to be freed
    IMalloc.Free should be used to do this.
}

function TaskAllocWideString(const S: string): Windows.PWChar;
var
  StrLen: Integer; // length of string in bytes
begin
  // Store length of string allowing for terminal #0
  StrLen := Length(S) + 1;
  // Alloc buffer for wide string using task allocator
  Result := ActiveX.CoTaskMemAlloc(StrLen * SizeOf(WideChar));
  if Assigned(Result) then
    // Convert string to wide string and store in buffer
    StringToWideChar(S, Result, StrLen);
end;

{
  TaskbarHandle:
    Returns the window handle of the Windows task bar.
}

function WindowsTaskbarHandle: THandle;
begin
  Result := Windows.FindWindow('Shell_TrayWnd', nil);
end;

{
  CommonFilesFolder:
    Returns directory used for common files.
}

function CommonFilesFolder: string;
begin
  Result := GetCurrentVersionRegStr('CommonFilesDir');
end;

{
  GetCurrentVersionRegStr:
    Gets given string value from given subkey of Windows current version
    registry key.
}

function GetCurrentVersionRegStr(const ValName: string): string;
const
  cWdwCurrentVer = '\Software\Microsoft\Windows\CurrentVersion';
begin
  Result := GetRegistryString(
    Windows.HKEY_LOCAL_MACHINE,
    cWdwCurrentVer,
    ValName
    );
end;

{
  GetRegistryString:
    Gets a string value from the registry from the given root and sub key.
    Converts integers to strings and raises exception for binary and unknown
    value types. Returns '' if the sub key or value name are not known.
}

function GetRegistryString(const RootKey: Windows.HKEY;
  const SubKey, Name: string): string;
var
  Reg: Registry.TRegistry; // registry access object
  ValueInfo: Registry.TRegDataInfo; // info about registry value
begin
  Result := '';
  // Open registry at required root key
  Reg := Registry.TRegistry.Create;
  try
    Reg.RootKey := RootKey;
    // Open registry key and check value exists
    if Reg.OpenKeyReadOnly(SubKey)
      and Reg.ValueExists(Name) then
    begin
      // Check if registry value is string or integer
      Reg.GetDataInfo(Name, ValueInfo);
      case ValueInfo.RegData of
        Registry.rdString, Registry.rdExpandString:
          // string value: just return it
          Result := Reg.ReadString(Name);
        Registry.rdInteger:
          // integer value: convert to string
          Result := SysUtils.IntToStr(Reg.ReadInteger(Name));
      else
          // unsupported value: raise exception
        raise SysUtils.Exception.Create(
          'Unsupported registry type'
          );
      end;
    end;
  finally
    // Close registry
    Reg.Free;
  end;
end;

{
  IsIntResource:
    Returns true if the given resource ID is integer value or false if the ID is
    a pointer to a zero terminated string.
}

function IsIntResource(const ResID: PChar): Boolean;
begin
  Result := (Windows.HiWord(Windows.DWORD(ResID)) = 0);
end;

{
  IsLockKeyOn:
    Detects if a given lock key is on and returns true if so. An exception is
    raised if KeyCode is not a valid lock key code. Valid lock key codes are
    VK_CAPITAL, VK_NUMLOCK and VK_SCROLL.
}

function IsLockKeyOn(const KeyCode: Integer): Boolean;
begin
  if not (
    KeyCode in [Windows.VK_CAPITAL, Windows.VK_NUMLOCK, Windows.VK_SCROLL]
    ) then
    raise SysUtils.Exception.Create('Invalid lock key specified.');
  Result := Odd(Windows.GetKeyState(KeyCode));
end;

{
  IsWinNT:
    Returns true if the operating system is Windows NT (including 2000 and XP)
    and false if not.
}

function IsWinNT: Boolean;
begin
  Result := (SysUtils.Win32Platform = Windows.VER_PLATFORM_WIN32_NT);
end;

{
  ProgramFilesFolder:
    Returns directory used for program files.
}

function ProgramFilesFolder: string;
begin
  Result := GetCurrentVersionRegStr('ProgramFilesDir');
end;

{
  SetLockKeyState:
    Sets the given lock key state to given value. Passing True switches lock key
    on and passing False switches it off. An exception is raised if KeyCode is
    not a valid lock key code. Valid lock key codes are VK_CAPITAL, VK_NUMLOCK
    and VK_SCROLL.
}

procedure SetLockKeyState(KeyCode: Integer; IsOn: Boolean);
  // ---------------------------------------------------------------------------
  procedure MoveKey(KeyCode: Integer; Up: Boolean);
  var
    Flags: Integer; // flags for MapVirtualKey()
  begin
    // Set up flags
    Flags := Windows.KEYEVENTF_EXTENDEDKEY;
    if Up then
      Flags := Flags or Windows.KEYEVENTF_KEYUP;
    // Simulate key movement
    Windows.keybd_event(
      KeyCode,
      Windows.MapVirtualkey(KeyCode, 0),
      Flags,
      0
      );
  end;
  // ---------------------------------------------------------------------------
begin
  if not (
    KeyCode in [Windows.VK_CAPITAL, Windows.VK_NUMLOCK, Windows.VK_SCROLL]
    ) then
    raise SysUtils.Exception.Create('Invalid lock key specified.');
  if IsLockKeyOn(KeyCode) <> IsOn then
  begin
    // Need to change state: press & release key
    MoveKey(KeyCode, False);
    MoveKey(KeyCode, True);
  end;
end;

{
  SystemFolder:
    Returns path to Windows system folder.
}

function SystemFolder: string;
begin
  SetLength(Result, Windows.MAX_PATH);
  SetLength(
    Result, Windows.GetSystemDirectory(PChar(Result), Windows.MAX_PATH)
    );
end;

{
  TempFolder:
    Returns path to Windows temporary folder.
}

function TempFolder: string;
begin
  SetLength(Result, Windows.MAX_PATH);
  SetLength(
    Result, Windows.GetTempPath(Windows.MAX_PATH, PChar(Result))
    );
end;

{
  WindowsFolder:
    Returns path to Windows folder.
}

function WindowsFolder: string;
begin
  SetLength(Result, Windows.MAX_PATH);
  SetLength(
    Result, Windows.GetWindowsDirectory(PChar(Result), Windows.MAX_PATH)
    );
end;

{
  WindowsProductID:
    Returns the Windows product ID.
}

function WindowsProductID: string;
const
  // Registry keys for Win 9x/NT
  cRegKey: array[Boolean] of string = (
    'Software\Microsoft\Windows\CurrentVersion',
    'Software\Microsoft\Windows NT\CurrentVersion'
    );
  // Registry key name
  cName = 'ProductID';
begin
  Result := GetRegistryString(
    Windows.HKEY_LOCAL_MACHINE, cRegKey[IsWinNT], cName
    );
end;

end.

