unit zExceptions.utils;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes;

function ComputerName: String;
function ModuleName: string;
function ModulePath: string;
function VersionInfo: String;
function SysUserName: String;
function UserName: String;
function UserEmail: string;
function DbName: string;
function ClientName: string; // cliente/ente: usato come progetto Mantis

procedure SetLoginInfo(const aDbName, aUserName, aUserEmail: string);
procedure SetClientName(const aClientName: string);

implementation

uses
  System.IOUtils;

const
  _UserName: String = '';
  _UserEmail: String = '';
  _DbName: String = '';
  _ClientName: String = '';

function ComputerName: String;
var
  BufSize: dword;
  buffer: PWideChar;
begin
  BufSize := 256;
  buffer := AllocMem(BufSize);
  try
    if GetComputerName(buffer, BufSize) then
    begin
      SetString(result, buffer, BufSize);
      result := result.Replace(#0, '');
    end
    else
      result := '';
  finally
    FreeMem(buffer);
  end;
end;

function SysUserName: String;
var
  BufSize: dword;
  buffer: PWideChar;
begin
  BufSize := 1024;
  buffer := AllocMem(BufSize);
  try
    if GetUserName(buffer, BufSize) then
    begin
      SetString(result, buffer, BufSize);
      result := result.Replace(#0, '');
    end
    else
      result := '';
  finally
    FreeMem(buffer);
  end;
end;

function ModuleName: string;
begin
  result := TPath.GetFileName(System.SysUtils.GetModuleName(HInstance));
end;

function ModulePath: string;
begin
  result := System.SysUtils.GetModuleName(HInstance);
end;

function VersionInfo: String;

type
  TLang = packed record
    Lng, Page: WORD;
  end;

  TLangs = array [0 .. 10000] of TLang;
  PLangs = ^TLangs;

var
  BLngs: PLangs;
  BLngsCnt: Cardinal;
  BLangId: String;
  RM: TMemoryStream;
  RS: TResourceStream;
  BP: PChar;
  BL: Cardinal;
  BId: String;

begin
  // Assume error
  result := '';

{$IFNDEF LINUX}
  RM := TMemoryStream.Create;
  try
    // Load the version resource into memory
    RS := TResourceStream.CreateFromID(HInstance, 1, RT_VERSION);
    try
      RM.CopyFrom(RS, RS.size);
    finally
      FreeAndNil(RS);
    end;

    // Extract the translations list
    if not VerQueryValue(RM.Memory, '\\VarFileInfo\\Translation', Pointer(BLngs), BL) then
      Exit; // Failed to parse the translations table
    BLngsCnt := BL div sizeof(TLang);
    if BLngsCnt <= 0 then
      Exit; // No translations available

    // Use the first translation from the table (in most cases will be OK)
    with BLngs[0] do
      BLangId := IntToHex(Lng, 4) + IntToHex(Page, 4);

    // Extract field by parameter
    BId := '\\StringFileInfo\\' + BLangId + '\\FileVersion';
    if not VerQueryValue(RM.Memory, PChar(BId), Pointer(BP), BL) then
      Exit; // No such field

    // Prepare result
    result := BP;
  finally
    FreeAndNil(RM);
  end;
{$ENDIF}
end;

function UserName: String;
begin
  result := _UserName;
end;

function UserEmail: string;
begin
  result := _UserEmail;
end;

function DbName: string;
begin
  result := _DbName;
end;

function ClientName: string;
begin
  result := _ClientName;
end;

procedure SetLoginInfo(const aDbName, aUserName, aUserEmail: string);
begin
  _DbName := aDbName;
  _UserName := aUserName;
  _UserEmail := aUserEmail;
end;

procedure SetClientName(const aClientName: string);
begin
  _ClientName := aClientName;
end;

end.
