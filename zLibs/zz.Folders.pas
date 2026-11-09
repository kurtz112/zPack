unit zz.folders;

interface

type
  TFolders = class
  private
    class var _WorkingFolder: string;
    class var _UserDocumentsFolder: string;
    class function SecFileName: string; static;
    class function GetUserDocumentsFolder: string; static;
    class procedure SetUserDocumentsFolder(const Value: string); static;
  public
    // Cartella in cui le finestre di salvataggio propongono i documenti dell'utente.
    // La imposta il programma dopo l'accesso (WT e Gesty: TzSystem.PersonalFolder);
    // finche' non e' impostata restituisce i Documenti di Windows, mai la cartella dell'eseguibile
    class property UserDocumentsFolder: string read GetUserDocumentsFolder write SetUserDocumentsFolder;
    // Sottocartella della cartella dell'eseguibile, creata se manca (Temp, Visure)
    class function ModuleSubFolder(const SubFolder: string): string;

    class function ModuleName: string;
    class function ModuleFullName: string;
    class function ModuleFolder: string;
    class function WorkingFolder(const doForceDirectories: Boolean = True): string;
    class function WorkingSubFolder(const SubFolder: string; const doForceDirectories: Boolean = True): string;

    class function SubFolder(const Root, SubFolder: string): string;
    //
    class function GetModuleFileName(const Ext: string): string;
    class function IniFileName: string;
    class function LogFileName: string;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
{$IF DEFINED(ANDROID)}
  Androidapi.Jni,
  Androidapi.Jni.JavaTypes,
  Androidapi.JNIBridge,
  FMX.Helpers.Android,
  Androidapi.Helpers,
  Androidapi.Jni.App,
{$ENDIF}
  System.IOUtils;

{ TFolders }
class function TFolders.ModuleFullName: string;
begin
{$IF DEFINED(ANDROID)}
  Result := IncludeTrailingPathDelimiter(JStringToString(TAndroidHelper.Activity.getApplication.getApplicationInfo.processName));
{$ELSE}
  Result := System.SysUtils.GetModuleName(HInstance);
{$ENDIF}
end;

class function TFolders.ModuleFolder: string;
begin
{$IF DEFINED(ANDROID)}
  Result := IncludeTrailingPathDelimiter(JStringToString(TAndroidHelper.Activity.getApplicationContext.getFilesDir.getAbsolutePath));
{$ELSE}
  Result := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(ModuleFullName));
{$ENDIF}
end;

class function TFolders.ModuleName: string;
begin
{$IF DEFINED(ANDROID)}
  Result := JCharSequenceToStr(TAndroidHelper.Activity.getApplication.getApplicationInfo.nonLocalizedLabel);
{$ELSE}
  Result := TPath.GetFileName(ModuleFullName);
{$ENDIF}
end;

class function TFolders.WorkingSubFolder(const SubFolder: string; const doForceDirectories: Boolean = True): string;
begin
  Result := IncludeTrailingPathDelimiter(TPath.Combine(WorkingFolder, SubFolder));

  if doForceDirectories then
    ForceDirectories(Result);
end;

class function TFolders.WorkingFolder(const doForceDirectories: Boolean = True): string;
begin
  if _WorkingFolder = '' then
  begin
    if (ParamCount >= 1) and (not StartsText('/', ParamStr(1))) and (not StartsText('-', ParamStr(1))) then
      _WorkingFolder := IncludeTrailingPathDelimiter(Trim(ParamStr(1)))
    else
    begin
{$IF DEFINED(IOS) or DEFINED(ANDROID)}
      // _WorkingFolder := IncludeTrailingPathDelimiter(TPath.GetSharedDocumentsPath);
      _WorkingFolder := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath);
{$ELSE}
      _WorkingFolder := ModuleFolder;
{$ENDIF}
    end;
  end;

  Result := _WorkingFolder;

  if doForceDirectories then
    ForceDirectories(Result);
end;

class function TFolders.GetModuleFileName(const Ext: string): string;
begin
  Result := ModuleFolder + TPath.ChangeExtension(ModuleName, Ext);
end;

class function TFolders.IniFileName: string;
begin
  Result := GetModuleFileName('.ini');
end;

class function TFolders.LogFileName: string;
begin
  Result := GetModuleFileName('.log');
end;

class function TFolders.SecFileName: string;
begin
  // Stessa estensione di zSystem.zExtension_Security: fino al 2026-09-25
  // qui c'era '.zSec', un file che non esiste.
  Result := GetModuleFileName('.Sec');
end;

class function TFolders.SubFolder(const Root, SubFolder: string): string;
begin
  Result := IncludeTrailingPathDelimiter(Root) + IncludeTrailingPathDelimiter(SubFolder);
end;

class function TFolders.ModuleSubFolder(const SubFolder: string): string;
begin
  Result := TFolders.SubFolder(ModuleFolder, SubFolder);
  ForceDirectories(Result);
end;

class function TFolders.GetUserDocumentsFolder: string;
begin
  if _UserDocumentsFolder <> '' then
    Result := _UserDocumentsFolder
  else
    Result := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath);
end;

class procedure TFolders.SetUserDocumentsFolder(const Value: string);
begin
  if Trim(Value) = '' then
    _UserDocumentsFolder := ''
  else
    _UserDocumentsFolder := IncludeTrailingPathDelimiter(Trim(Value));
end;

end.
