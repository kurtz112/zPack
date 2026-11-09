unit zz.SmartInspect;

interface

uses
  System.SysUtils,
  System.classes,
  System.UITypes;

type
  TLogger = record
  private
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
  public
    procedure EnterMethod(const AMethodName: UnicodeString); overload;
    procedure EnterMethod(const AMethodName: UnicodeString; aColor: TColor); overload;
    procedure EnterMethod(const AMethodName: UnicodeString; aColor: TColor; aSeparator: boolean); overload;

    procedure EnterMethod(const AInstance: TObject; const AMethodName: UnicodeString); overload;
    procedure EnterMethod(const AInstance: TObject; const AMethodName: UnicodeString; aColor: TColor); overload;
    procedure EnterMethod(const AInstance: TObject; const AMethodName: UnicodeString; aColor: TColor; aSeparator: boolean); overload;

    procedure LeaveMethod(const AMethodName: UnicodeString; const aSeparator: boolean = false); overload;
    procedure LeaveMethod(AInstance: TObject; const AMethodName: UnicodeString; const aSeparator: boolean = false); overload;

    procedure LogWarning(const ATitle: UnicodeString);
    procedure LogVerbose(const ATitle: UnicodeString);
    procedure LogError(const aError: UnicodeString);
    procedure LogException(const AException: Exception; const ATitle: UnicodeString = '');
    procedure LogColored(const aColor: TColor; const ATitle: UnicodeString);
    procedure LogSeparator;

    procedure LogString(const AName: UnicodeString; const AValue: String);
    procedure LogBoolean(const AName: UnicodeString; const AValue: boolean);
    procedure LogInteger(const AName: UnicodeString; const AValue: Integer);
    procedure LogInt64(const AName: UnicodeString; const AValue: Int64);
    procedure LogDateTime(const AName: UnicodeString; const AValue: TDateTime);
    procedure LogStringList(const ATitle: UnicodeString; const AStrings: TStrings);
    procedure LogObject(const ATitle: UnicodeString; const AInstance: TObject);

    property Color: TColor read GetColor write SetColor;
  end;

var
  SiMain: TLogger;

implementation

// definire {$DEFINE DISABLE_SMART_INSPECT} a livello di progetto per firemonkey

{$IFDEF MSWINDOWS}
{$IFNDEF DISABLE_SMART_INSPECT}
{$DEFINE SMART_INSPECT}
{$ENDIF}
{$ENDIF}

uses
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
{$ENDIF}
  zz.Folders;

const
  DefaultColor = TColors.SysWindow;

procedure InitSmartInspect;
var
  FileName: string;
begin
{$IFDEF SMART_INSPECT}
  FileName := TFolders.GetModuleFileName('.sic');

  if FileExists(FileName) then
    si.LoadConfiguration(FileName)
  else
    si.Enabled := True;
{$ENDIF}
end;

procedure TLogger.EnterMethod(const AMethodName: UnicodeString);
begin
  EnterMethod(AMethodName, DefaultColor);
end;

procedure TLogger.EnterMethod(const AMethodName: UnicodeString; aColor: TColor);
begin
  EnterMethod(AMethodName, aColor, false);
end;

procedure TLogger.EnterMethod(const AMethodName: UnicodeString; aColor: TColor; aSeparator: boolean);
begin
{$IFDEF SMART_INSPECT}
  Color := aColor;

  if aSeparator then
    SmartInspect.Vcl.SiAuto.SiMain.LogSeparator;

  SmartInspect.Vcl.SiAuto.SiMain.EnterMethod(AMethodName);
{$ENDIF}
end;

procedure TLogger.EnterMethod(const AInstance: TObject; const AMethodName: UnicodeString);
begin
  EnterMethod(AInstance, AMethodName, DefaultColor);
end;

procedure TLogger.EnterMethod(const AInstance: TObject; const AMethodName: UnicodeString; aColor: TColor);
begin
  EnterMethod(AInstance, AMethodName, aColor, false);
end;

procedure TLogger.EnterMethod(const AInstance: TObject; const AMethodName: UnicodeString; aColor: TColor; aSeparator: boolean);
begin
{$IFDEF SMART_INSPECT}
  Color := aColor;

  if aSeparator then
    SmartInspect.Vcl.SiAuto.SiMain.LogSeparator;

  SmartInspect.Vcl.SiAuto.SiMain.EnterMethod(AInstance, AMethodName);
{$ENDIF}
end;

procedure TLogger.LeaveMethod(const AMethodName: UnicodeString; const aSeparator: boolean = false);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LeaveMethod(AMethodName);

  if aSeparator then
    SmartInspect.Vcl.SiAuto.SiMain.LogSeparator;

  Color := DefaultColor;
{$ENDIF}
end;

procedure TLogger.LeaveMethod(AInstance: TObject; const AMethodName: UnicodeString; const aSeparator: boolean = false);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LeaveMethod(AInstance, AMethodName);

  if aSeparator then
    SmartInspect.Vcl.SiAuto.SiMain.LogSeparator;

  Color := DefaultColor;
{$ENDIF}
end;

procedure TLogger.LogVerbose(const ATitle: UnicodeString);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogVerbose(ATitle);
{$ENDIF}
end;

procedure TLogger.LogError(const aError: UnicodeString);
var
  lastColor: TColor;
begin
{$IFDEF SMART_INSPECT}
  lastColor := Color;
  Color := TColors.Red;
  SmartInspect.Vcl.SiAuto.SiMain.LogError(aError);
  Color := lastColor;
{$ENDIF}
end;

procedure TLogger.LogWarning(const ATitle: UnicodeString);
var
  lastColor: TColor;
begin
{$IFDEF SMART_INSPECT}
  lastColor := Color;
  Color := TColors.Yellow;
  SmartInspect.Vcl.SiAuto.SiMain.LogWarning(ATitle);
  Color := lastColor;
{$ENDIF}
end;

procedure TLogger.LogException(const AException: Exception; const ATitle: UnicodeString = '');
var
  lastColor: TColor;
begin
{$IFDEF SMART_INSPECT}
  lastColor := Color;
  Color := TColors.Yellow;
  SmartInspect.Vcl.SiAuto.SiMain.LogException(AException, ATitle);
  Color := lastColor;
{$ENDIF}
end;

procedure TLogger.LogColored(const aColor: TColor; const ATitle: UnicodeString);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogColored(aColor, ATitle);
{$ENDIF}
end;

procedure TLogger.LogSeparator;
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogSeparator;
{$ENDIF}
end;

procedure TLogger.LogString(const AName: UnicodeString; const AValue: String);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogString(AName, AValue);
{$ENDIF}
end;

procedure TLogger.LogBoolean(const AName: UnicodeString; const AValue: boolean);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogBoolean(AName, AValue);
{$ENDIF}
end;

procedure TLogger.LogDateTime(const AName: UnicodeString; const AValue: TDateTime);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogDateTime(AName, AValue);
{$ENDIF}
end;

procedure TLogger.LogInt64(const AName: UnicodeString; const AValue: Int64);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogInt64(AName, AValue);
{$ENDIF}
end;

procedure TLogger.LogInteger(const AName: UnicodeString; const AValue: Integer);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogInteger(AName, AValue);
{$ENDIF}
end;

procedure TLogger.LogStringList(const ATitle: UnicodeString; const AStrings: TStrings);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogStringList(ATitle, AStrings);
{$ENDIF}
end;

procedure TLogger.LogObject(const ATitle: UnicodeString; const AInstance: TObject);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.LogObject(ATitle, AInstance);
{$ENDIF}
end;

function TLogger.GetColor: TColor;
begin
{$IFDEF SMART_INSPECT}
  Result := SmartInspect.Vcl.SiAuto.SiMain.Color;
{$ENDIF}
end;

procedure TLogger.SetColor(const Value: TColor);
begin
{$IFDEF SMART_INSPECT}
  SmartInspect.Vcl.SiAuto.SiMain.Color := Value;
{$ENDIF}
end;

initialization

InitSmartInspect;

end.
