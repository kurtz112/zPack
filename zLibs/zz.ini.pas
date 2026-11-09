unit zz.ini;

interface

uses SysUtils,
  Classes,
  IniFiles;

// util
function DefaultIniFileName: string;
//
procedure DeleteSection(const Section: string; const INI_FileName: string = ''); overload;
procedure DeleteSection(INI: TIniFile; const Section: string; const INI_FileName: string = ''); overload;

procedure ReadSections(Strings: TStrings; const INI_FileName: string = ''); overload;
procedure ReadSections(INI: TIniFile; Strings: TStrings; const INI_FileName: string = ''); overload;

procedure ReadSectionValues(const Section: string; Strings: TStrings; const INI_FileName: string = ''); overload;
procedure ReadSectionValues(INI: TIniFile; const Section: string; Strings: TStrings; const INI_FileName: string = ''); overload;

procedure DeleteKey(const Section, Ident: string; const INI_FileName: string = ''); overload;
procedure DeleteKey(INI: TIniFile; const Section, Ident: string; const INI_FileName: string = ''); overload;

function ValueExists(const Section, Ident: string; const INI_FileName: string = ''): Boolean; overload;
function ValueExists(INI: TIniFile; const Section, Ident: string; const INI_FileName: string = ''): Boolean; overload;

// read
function ReadStringFromIni(const Section, Ident, Default: string; const INI_FileName: string = ''): string; overload;
function ReadStringFromIni(INI: TIniFile; const Section, Ident, Default: string; const INI_FileName: string = ''): string; overload;
function ReadIntegerFromIni(const Section, Ident: string; const Default: Integer; const INI_FileName: string = ''): Integer; overload;
function ReadIntegerFromIni(INI: TIniFile; const Section, Ident: string; const Default: Integer; const INI_FileName: string = ''): Integer; overload;
function ReadDoubleFromIni(const Section, Ident: string; const Default: double; const INI_FileName: string = ''): double; overload;
function ReadDoubleFromIni(INI: TIniFile; const Section, Ident: string; const Default: double; const INI_FileName: string = ''): double; overload;
function ReadBoolFromIni(const Section, Ident: string; const Default: Boolean; const INI_FileName: string = ''): Boolean; overload;
function ReadBoolFromIni(INI: TIniFile; const Section, Ident: string; const Default: Boolean; const INI_FileName: string = ''): Boolean; overload;
function ReadDateFromIni(const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime; overload;
function ReadDateFromIni(INI: TIniFile; const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime; overload;
function ReadDateTimeFromIni(const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime; overload;
function ReadDateTimeFromIni(INI: TIniFile; const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime; overload;
function ReadTimeFromIni(const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime; overload;
function ReadTimeFromIni(INI: TIniFile; const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime; overload;

// write
procedure WriteStringToIni(const Section, Ident, Value: string; const INI_FileName: string = ''); overload;
procedure WriteStringToIni(INI: TIniFile; const Section, Ident, Value: string; const INI_FileName: string = ''); overload;
procedure WriteIntegerToIni(const Section, Ident: string; const Value: Integer; const INI_FileName: string = ''); overload;
procedure WriteIntegerToIni(INI: TIniFile; const Section, Ident: string; const Value: Integer; const INI_FileName: string = ''); overload;
procedure WriteDoubleToIni(const Section, Ident: string; const Value: double; const INI_FileName: string = ''); overload;
procedure WriteDoubleToIni(INI: TIniFile; const Section, Ident: string; const Value: double; const INI_FileName: string = ''); overload;
procedure WriteBoolToIni(const Section, Ident: string; const Value: Boolean; const INI_FileName: string = ''); overload;
procedure WriteBoolToIni(INI: TIniFile; const Section, Ident: string; const Value: Boolean; const INI_FileName: string = ''); overload;
procedure WriteDateToIni(const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = ''); overload;
procedure WriteDateToIni(INI: TIniFile; const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = ''); overload;
procedure WriteDateTimeToIni(const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = ''); overload;
procedure WriteDateTimeToIni(INI: TIniFile; const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = ''); overload;
procedure WriteTimeToIni(const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = ''); overload;
procedure WriteTimeToIni(INI: TIniFile; const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = ''); overload;

implementation

uses zz.folders;

function DefaultIniFileName: string;
begin
  result := TFolders.IniFileName;
end;

function CreateIniFile(const IniFileName: string): TIniFile;
begin
  if IniFileName <> '' then
    result := TIniFile.Create(IniFileName)
  else
    result := TIniFile.Create(DefaultIniFileName);
end;

procedure DeleteSection(const Section: string; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    DeleteSection(INI, Section);
  finally
    FreeAndNil(INI);
  end;
end;

procedure DeleteSection(INI: TIniFile; const Section: string; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.EraseSection(Section);
end;

procedure ReadSections(Strings: TStrings; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    ReadSections(INI, Strings);
  finally
    FreeAndNil(INI);
  end;
end;

procedure ReadSections(INI: TIniFile; Strings: TStrings; const INI_FileName: string = ''); overload;
begin
  Assert(Assigned(INI));
  INI.ReadSections(Strings);
end;

procedure ReadSectionValues(const Section: string; Strings: TStrings; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    ReadSectionValues(INI, Section, Strings);
  finally
    FreeAndNil(INI);
  end;
end;

procedure ReadSectionValues(INI: TIniFile; const Section: string; Strings: TStrings; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.ReadSectionValues(Section, Strings);
end;

procedure DeleteKey(const Section, Ident: string; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    DeleteKey(INI, Section, Ident);
  finally
    FreeAndNil(INI);
  end;
end;

procedure DeleteKey(INI: TIniFile; const Section, Ident: string; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.DeleteKey(Section, Ident);
end;

function ValueExists(const Section, Ident: string; const INI_FileName: string = ''): Boolean;
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    result := ValueExists(INI, Section, Ident);
  finally
    FreeAndNil(INI);
  end;
end;

function ValueExists(INI: TIniFile; const Section, Ident: string; const INI_FileName: string = ''): Boolean;
begin
  Assert(Assigned(INI));
  result := INI.ValueExists(Section, Ident);
end;

/// /////////////////////////////////////////////////////////////////////////////

function ReadStringFromIni(const Section, Ident, Default: string; const INI_FileName: string = ''): string;
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    result := ReadStringFromIni(INI, Section, Ident, Default)
  finally
    FreeAndNil(INI);
  end;
end;

function ReadStringFromIni(INI: TIniFile; const Section, Ident, Default: string; const INI_FileName: string = ''): string;
begin
  Assert(Assigned(INI));
  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadString(Section, Ident, Default)
  else
    INI.WriteString(Section, Ident, Default); // inizializza nell'ini il valore
end;

function ReadIntegerFromIni(const Section, Ident: string; const Default: Integer; const INI_FileName: string = ''): Integer;
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    result := ReadIntegerFromIni(INI, Section, Ident, Default)
  finally
    FreeAndNil(INI);
  end;
end;

function ReadIntegerFromIni(INI: TIniFile; const Section, Ident: string; const Default: Integer; const INI_FileName: string = ''): Integer;
begin
  Assert(Assigned(INI));

  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadInteger(Section, Ident, Default)
  else
    INI.WriteInteger(Section, Ident, Default); // inizializza nell'ini il valore
end;

function ReadDoubleFromIni(const Section, Ident: string; const Default: double; const INI_FileName: string = ''): double;
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    result := ReadDoubleFromIni(INI, Section, Ident, Default);
  finally
    FreeAndNil(INI);
  end;
end;

function ReadDoubleFromIni(INI: TIniFile; const Section, Ident: string; const Default: double; const INI_FileName: string = ''): double;
begin
  Assert(Assigned(INI));

  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadFloat(Section, Ident, Default)
  else
    INI.WriteFloat(Section, Ident, Default); // inizializza nell'ini il valore
end;

function ReadBoolFromIni(const Section, Ident: string; const Default: Boolean; const INI_FileName: string = ''): Boolean;
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    result := ReadBoolFromIni(INI, Section, Ident, Default); // inizializza nell'ini il valore
  finally
    FreeAndNil(INI);
  end;
end;

function ReadBoolFromIni(INI: TIniFile; const Section, Ident: string; const Default: Boolean; const INI_FileName: string = ''): Boolean;
begin
  Assert(Assigned(INI));
  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadBool(Section, Ident, Default)
  else
    INI.WriteBool(Section, Ident, Default); // inizializza nell'ini il valore
end;

function ReadDateFromIni(const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime;
var
  INI: TIniFile;
begin
  result := Default;

  INI := CreateIniFile(INI_FileName);
  try
    result := ReadDateFromIni(INI, Section, Ident, Default)
  finally
    FreeAndNil(INI);
  end;
end;

function ReadDateFromIni(INI: TIniFile; const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime;
begin
  Assert(Assigned(INI));
  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadDate(Section, Ident, Default)
  else
    INI.WriteDate(Section, Ident, Default); // inizializza nell'ini il valore
end;

function ReadDateTimeFromIni(const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime;
var
  INI: TIniFile;
begin
  result := Default;

  INI := CreateIniFile(INI_FileName);
  try
    result := ReadDateTimeFromIni(INI, Section, Ident, Default)
  finally
    FreeAndNil(INI);
  end;
end;

function ReadDateTimeFromIni(INI: TIniFile; const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime;
begin
  Assert(Assigned(INI));
  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadDateTime(Section, Ident, Default)
  else
    INI.WriteDateTime(Section, Ident, Default); // inizializza nell'ini il valore
end;

function ReadTimeFromIni(const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime;
var
  INI: TIniFile;
begin
  result := Default;

  INI := CreateIniFile(INI_FileName);
  try
    result := ReadTimeFromIni(INI, Section, Ident, Default)
  finally
    FreeAndNil(INI);
  end;
end;

function ReadTimeFromIni(INI: TIniFile; const Section, Ident: string; const Default: TDateTime; const INI_FileName: string = ''): TDateTime;
begin
  Assert(Assigned(INI));
  result := Default;

  if INI.ValueExists(Section, Ident) then
    result := INI.ReadTime(Section, Ident, Default)
  else
    INI.WriteTime(Section, Ident, Default); // inizializza nell'ini il valore
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure WriteStringToIni(const Section, Ident, Value: string; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteStringToIni(INI, Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteStringToIni(INI: TIniFile; const Section, Ident, Value: string; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteString(Section, Ident, Value);
end;

procedure WriteIntegerToIni(const Section, Ident: string; const Value: Integer; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteIntegerToIni(INI, Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteIntegerToIni(INI: TIniFile; const Section, Ident: string; const Value: Integer; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteInteger(Section, Ident, Value);
end;

procedure WriteDoubleToIni(const Section, Ident: string; const Value: double; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteDoubleToIni(Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteDoubleToIni(INI: TIniFile; const Section, Ident: string; const Value: double; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteFloat(Section, Ident, Value);
end;

procedure WriteBoolToIni(const Section, Ident: string; const Value: Boolean; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteBoolToIni(INI, Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteBoolToIni(INI: TIniFile; const Section, Ident: string; const Value: Boolean; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteBool(Section, Ident, Value);
end;

procedure WriteDateToIni(const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteDateToIni(INI, Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteDateToIni(INI: TIniFile; const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteDate(Section, Ident, Value);
end;

procedure WriteDateTimeToIni(const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteDateToIni(INI, Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteDateTimeToIni(INI: TIniFile; const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteDateTime(Section, Ident, Value);
end;

procedure WriteTimeToIni(const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = '');
var
  INI: TIniFile;
begin
  INI := CreateIniFile(INI_FileName);
  try
    WriteTimeToIni(INI, Section, Ident, Value);
  finally
    FreeAndNil(INI);
  end;
end;

procedure WriteTimeToIni(INI: TIniFile; const Section, Ident: string; const Value: TDateTime; const INI_FileName: string = '');
begin
  Assert(Assigned(INI));
  INI.WriteTime(Section, Ident, Value);
end;

end.
