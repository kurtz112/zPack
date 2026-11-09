unit zLib_Config;

interface
uses SysUtils,
  Classes,
  IniFiles;

type
  TConfig = class(TObject)
  private
    FDataBasePassword: string;
    FDataBaseUser: string;
    FDataBaseName: string;
    FTemporizzazione: Integer;
    procedure SetTemporizzazione(const Value: Integer);
  protected
    function IniFileName: string; virtual;
    function SectionExists(const Section: string): Boolean;
    function ReadString(const Section, Ident, Default: string): string;
    procedure WriteString(const Section, Ident, Value: string);
    function ReadInteger(const Section, Ident: string; Default: Longint): Longint;
    procedure WriteInteger(const Section, Ident: string; Value: Longint);
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    function ReadDate(const Section, Ident: string; Default: TDateTime): TDateTime;
    function ReadDateTime(const Section, Ident: string; Default: TDateTime): TDateTime;
    function ReadFloat(const Section, Ident: string; Default: Double): Double;
    function ReadTime(const Section, Ident: string; Default: TDateTime): TDateTime;
    procedure WriteDate(const Section, Ident: string; Value: TDateTime);
    procedure WriteDateTime(const Section, Ident: string; Value: TDateTime);
    procedure WriteFloat(const Section, Ident: string; Value: Double);
    procedure WriteTime(const Section, Ident: string; Value: TDateTime);
    procedure EraseSection(const Section: string);
    procedure DeleteKey(const Section, Ident: string);
    function ValueExists(const Section, Ident: string): Boolean;
  protected
    constructor CreateInstance;
    class function AccessInstance(Request: Integer): TConfig;
  protected
    procedure Load;
  public
    IniFile: TIniFile;
    constructor Create;
    destructor Destroy; override;
    class function Instance: TConfig;
    class procedure ReleaseInstance;
  published
    property DataBaseName: string read FDataBaseName;
    property DataBaseUser: string read FDataBaseUser;
    property DataBasePassword: string read FDataBasePassword;
    property Temporizzazione: Integer read FTemporizzazione write SetTemporizzazione;
  end;

function Config: TConfig;

implementation

function Config: TConfig;
begin
  Result := TConfig.Instance;
end;

constructor TConfig.Create;
begin
  inherited Create;
  raise Exception.CreateFmt('Access class %s through Instance only', [ClassName]);
end;

constructor TConfig.CreateInstance;
begin
  inherited Create;
  IniFile := TIniFile.Create(IniFileName);
  Load;
end;

destructor TConfig.Destroy;
begin
  if AccessInstance(0) = Self then
    AccessInstance(2);

  FreeAndNil(IniFile);

  inherited Destroy;
end;

class function TConfig.AccessInstance(Request: Integer): TConfig;
{$J+}
const
  FInstance: TConfig = nil;
{$J-}
begin
  case Request of
    0: ;
    1:
      if not Assigned(FInstance) then
        FInstance := CreateInstance;
    2: FInstance := nil;
  else
    raise Exception.CreateFmt('Illegal request %d in AccessInstance', [Request]);
  end;
  Result := FInstance;
end;

class function TConfig.Instance: TConfig;
begin
  Result := AccessInstance(1);
end;

class procedure TConfig.ReleaseInstance;
begin
  AccessInstance(0).Free;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function TConfig.IniFileName: string;
begin
  Result := ChangeFileExt(GetModuleName, '.ini');
end;

procedure TConfig.DeleteKey(const Section, Ident: string);
begin
  IniFile.DeleteKey(Section, Ident);
end;

procedure TConfig.EraseSection(const Section: string);
begin
  IniFile.EraseSection(Section);
end;

function TConfig.ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadBool(Section, Ident, Default)
  else
  begin
    WriteBool(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.ReadDate(const Section, Ident: string; Default: TDateTime): TDateTime;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadDate(Section, Ident, Default)
  else
  begin
    WriteDate(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.ReadDateTime(const Section, Ident: string; Default: TDateTime): TDateTime;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadDateTime(Section, Ident, Default)
  else
  begin
    WriteDateTime(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.ReadFloat(const Section, Ident: string; Default: Double): Double;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadFloat(Section, Ident, Default)
  else
  begin
    WriteFloat(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.ReadInteger(const Section, Ident: string; Default: Longint): Longint;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadInteger(Section, Ident, Default)
  else
  begin
    WriteInteger(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.ReadString(const Section, Ident, Default: string): string;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadString(Section, Ident, Default)
  else
  begin
    WriteString(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.ReadTime(const Section, Ident: string; Default: TDateTime): TDateTime;
begin
  if ValueExists(Section, Ident) then
    Result := IniFile.ReadTime(Section, Ident, Default)
  else
  begin
    WriteTime(Section, Ident, Default);
    Result := Default;
  end;
end;

function TConfig.SectionExists(const Section: string): Boolean;
begin
  Result := IniFile.SectionExists(Section);
end;

function TConfig.ValueExists(const Section, Ident: string): Boolean;
begin
  Result := IniFile.ValueExists(Section, Ident);
end;

procedure TConfig.WriteBool(const Section, Ident: string; Value: Boolean);
begin
  IniFile.WriteBool(Section, Ident, Value);
end;

procedure TConfig.WriteDate(const Section, Ident: string; Value: TDateTime);
begin
  IniFile.WriteDate(Section, Ident, Value);
end;

procedure TConfig.WriteDateTime(const Section, Ident: string; Value: TDateTime);
begin
  IniFile.WriteDateTime(Section, Ident, Value);
end;

procedure TConfig.WriteFloat(const Section, Ident: string; Value: Double);
begin
  IniFile.WriteFloat(Section, Ident, Value);
end;

procedure TConfig.WriteInteger(const Section, Ident: string; Value: Longint);
begin
  IniFile.WriteInteger(Section, Ident, Value);
end;

procedure TConfig.WriteString(const Section, Ident, Value: string);
begin
  IniFile.WriteString(Section, Ident, Value);
end;

procedure TConfig.WriteTime(const Section, Ident: string; Value: TDateTime);
begin
  IniFile.WriteTime(Section, Ident, Value);
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure TConfig.Load;
const
  Section_DataBase = 'DataBase';
  Section_Service = 'Service';
  Section_FTP_Immobili = 'FTP_Immobili';
  Section_ExportImmobili = 'ExportImmobili';
  Section_Reports = 'Reports';
  //
  Ident_Port = 'Port';
  Ident_DisplayName = 'DisplayName';
  Ident_DataBaseName = 'DataBaseName';
  Ident_UserName = 'UserName';
  Ident_Password = 'Password';
  Ident_Temporizzazione = 'Temporizzazione';
  Ident_Host = 'Host';
  Ident_Passive = 'Passive';
  Ident_RootFolder = 'RootFolder';
  Ident_ExportImmobiliRecordCount = 'ExportImmobiliRecordCount';
  //
  ident_ReportFolder = 'ReportFolder';
  //
  DefaultPortNumber = 211;
  Default_WT3DataSnapService = 'WT3_DataSnapService';
  Default_SYSDBA = 'SYSDBA';
  //

begin
  FDataBaseName := ReadString(Section_DataBase, Ident_DataBaseName, '');
  FDataBaseUser := ReadString(Section_DataBase, Ident_UserName, Default_SYSDBA);
  FDataBasePassword := ReadString(Section_DataBase, Ident_Password, '');
  FTemporizzazione := ReadInteger(Section_DataBase, Ident_Temporizzazione, 300000);
end;

procedure TConfig.SetTemporizzazione(const Value: Integer);
begin
  FTemporizzazione := Value;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

initialization
finalization
  TConfig.ReleaseInstance;
end.

