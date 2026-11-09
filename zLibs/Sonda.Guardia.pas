// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-27
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Guardia
//
// La guardia della copia di collaudo: da quando si accende, il programma non
// puo' piu' scrivere fuori dalle cartelle ammesse, avviare programmi che non
// stanno li' dentro, scrivere nel registro, aprire connessioni di rete che
// non siano verso il computer stesso.
//
// PERCHE'. Un programma come zBuilder lavora proprio sulle cartelle vere
// (D:\AI\SRC, D:\AI\Rilasci, l'agenda, i repository git, Mantis, la posta).
// Il file di impostazioni del banco le sposta in SandBox, ma basta un
// percorso predefinito dimenticato, scritto nel codice, perche' una prova
// tocchi i dati veri. La guardia non dipende da quello che dice il file: lo
// impone il codice, sotto tutte le funzioni del programma.
//
// COME. Le funzioni di Windows che il programma importa (tabella delle
// importazioni dell'eseguibile) si sostituiscono con funzioni che controllano
// gli argomenti e poi chiamano l'originale, oppure rifiutano con
// ERROR_ACCESS_DENIED. Si sostituisce anche GetProcAddress, cosi' le
// funzioni caricate dopo (le importazioni differite di Delphi, Winsock di
// Indy) passano dallo stesso controllo. Il codice Delphi dell'eseguibile
// chiama Windows solo da quella tabella: niente di quello che e' compilato
// dentro il programma la scavalca.
//
// LIMITI. Le DLL di sistema che il programma carica (shell, COM, il motore
// di WebView2) chiamano Windows dalle proprie tabelle e non passano di qui:
// per questo l'avvio di programmi e ShellExecute si rifiutano sempre, che e'
// la strada da cui quelle DLL farebbero il danno vero. Un collegamento
// simbolico dentro una cartella ammessa che punta fuori non si riconosce.
//
// RIFIUTI. Ogni rifiuto si annota (funzione, oggetto, ora) in memoria e nel
// file di registro indicato all'accensione: chi collauda vede che cosa il
// programma ha provato a fare. La funzione chiamata riceve un errore, come se
// il file fosse protetto, e il programma lo tratta come tratterebbe un disco
// di sola lettura.
//
// Analisi: D:\AI\Analisi\COLLAUDO e D:\AI\OUT\20261027-sonda-collaudo-zbuilder\.
//
// ***************************************************************************

unit Sonda.Guardia;

interface

type
  TRifiutoGuardia = record
    Quando: TDateTime;
    Funzione: string;
    Oggetto: string;
  end;

// Accende la guardia. Radici: le sole cartelle in cui si puo' scrivere e da
// cui si possono avviare programmi. FileRegistro: dove annotare i rifiuti, ''
// per nessun file. Una seconda chiamata non fa niente.
procedure AttivaGuardia(const Radici: array of string; const FileRegistro: string);
function GuardiaAttiva: Boolean;

// I rifiuti dall'accensione, dal piu' vecchio.
function RifiutiGuardia: TArray<TRifiutoGuardia>;

// Vero se il percorso, reso assoluto, sta dentro una delle radici.
function PercorsoAmmessoGuardia(const Percorso: string): Boolean;

implementation

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.SysUtils,
  System.StrUtils,
  System.SyncObjs,
  System.Generics.Collections;

type
  TDescrittoreImportazione = record
    OriginalFirstThunk: DWORD;
    TimeDateStamp: DWORD;
    ForwarderChain: DWORD;
    Name: DWORD;
    FirstThunk: DWORD;
  end;
  PDescrittoreImportazione = ^TDescrittoreImportazione;

  TVoceGuardia = record
    Nome: string;
    Sostituto: Pointer;
    Originale: PPointer;
  end;

  TCreateFileW = function(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
    lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
    hTemplateFile: THandle): THandle; stdcall;
  TCreateFileA = function(lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
    lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
    hTemplateFile: THandle): THandle; stdcall;
  TCopyFileW = function(lpExistingFileName, lpNewFileName: PWideChar; bFailIfExists: BOOL): BOOL; stdcall;
  TCopyFileExW = function(lpExistingFileName, lpNewFileName: PWideChar; lpProgressRoutine, lpData: Pointer;
    pbCancel: PBOOL; dwCopyFlags: DWORD): BOOL; stdcall;
  TMoveFileW = function(lpExistingFileName, lpNewFileName: PWideChar): BOOL; stdcall;
  TMoveFileExW = function(lpExistingFileName, lpNewFileName: PWideChar; dwFlags: DWORD): BOOL; stdcall;
  TMoveFileWithProgressW = function(lpExistingFileName, lpNewFileName: PWideChar; lpProgressRoutine,
    lpData: Pointer; dwFlags: DWORD): BOOL; stdcall;
  TDeleteFileW = function(lpFileName: PWideChar): BOOL; stdcall;
  TCreateDirectoryW = function(lpPathName: PWideChar; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
  TCreateDirectoryExW = function(lpTemplateDirectory, lpNewDirectory: PWideChar;
    lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
  TRemoveDirectoryW = function(lpPathName: PWideChar): BOOL; stdcall;
  TSetFileAttributesW = function(lpFileName: PWideChar; dwFileAttributes: DWORD): BOOL; stdcall;
  TReplaceFileW = function(lpReplacedFileName, lpReplacementFileName, lpBackupFileName: PWideChar;
    dwReplaceFlags: DWORD; lpExclude, lpReserved: Pointer): BOOL; stdcall;
  TCreateHardLinkW = function(lpFileName, lpExistingFileName: PWideChar;
    lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
  TCreateSymbolicLinkW = function(lpSymlinkFileName, lpTargetFileName: PWideChar; dwFlags: DWORD): BOOLEAN; stdcall;
  TWritePrivateProfileStringW = function(lpAppName, lpKeyName, lpString, lpFileName: PWideChar): BOOL; stdcall;
  TWritePrivateProfileSectionW = function(lpAppName, lpString, lpFileName: PWideChar): BOOL; stdcall;
  TCreateProcessW = function(lpApplicationName, lpCommandLine: PWideChar; lpProcessAttributes,
    lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD;
    lpEnvironment: Pointer; lpCurrentDirectory: PWideChar; lpStartupInfo, lpProcessInformation: Pointer): BOOL; stdcall;
  TCreateProcessA = function(lpApplicationName, lpCommandLine: PAnsiChar; lpProcessAttributes,
    lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD;
    lpEnvironment: Pointer; lpCurrentDirectory: PAnsiChar; lpStartupInfo, lpProcessInformation: Pointer): BOOL; stdcall;
  TShellExecuteW = function(hWnd: HWND; Operation, FileName, Parameters, Directory: PWideChar;
    ShowCmd: Integer): HINST; stdcall;
  TShellExecuteExW = function(lpExecInfo: PShellExecuteInfoW): BOOL; stdcall;
  TRegSetValueExW = function(hKey: HKEY; lpValueName: PWideChar; Reserved, dwType: DWORD; lpData: Pointer;
    cbData: DWORD): Longint; stdcall;
  TRegSetValueExA = function(hKey: HKEY; lpValueName: PAnsiChar; Reserved, dwType: DWORD; lpData: Pointer;
    cbData: DWORD): Longint; stdcall;
  TRegSetKeyValueW = function(hKey: HKEY; lpSubKey, lpValueName: PWideChar; dwType: DWORD; lpData: Pointer;
    cbData: DWORD): Longint; stdcall;
  TRegCreateKeyExW = function(hKey: HKEY; lpSubKey: PWideChar; Reserved: DWORD; lpClass: PWideChar;
    dwOptions: DWORD; samDesired: REGSAM; lpSecurityAttributes: PSecurityAttributes; phkResult: PHKEY;
    lpdwDisposition: PDWORD): Longint; stdcall;
  TRegDeleteValueW = function(hKey: HKEY; lpValueName: PWideChar): Longint; stdcall;
  TRegDeleteKeyW = function(hKey: HKEY; lpSubKey: PWideChar): Longint; stdcall;
  TRegDeleteKeyExW = function(hKey: HKEY; lpSubKey: PWideChar; samDesired: REGSAM; Reserved: DWORD): Longint; stdcall;
  TRegDeleteTreeW = function(hKey: HKEY; lpSubKey: PWideChar): Longint; stdcall;
  TRegisterHotKey = function(hWnd: HWND; id: Integer; fsModifiers, vk: UINT): BOOL; stdcall;
  TConnect = function(s: NativeUInt; name: Pointer; namelen: Integer): Integer; stdcall;
  TWSAConnect = function(s: NativeUInt; name: Pointer; namelen: Integer; lpCallerData, lpCalleeData, lpSQOS,
    lpGQOS: Pointer): Integer; stdcall;
  TWSASetLastError = procedure(iError: Integer); stdcall;
  TWinHttpConnect = function(hSession: Pointer; pswzServerName: PWideChar; nServerPort: Word;
    dwReserved: DWORD): Pointer; stdcall;
  TInternetConnectW = function(hInternet: Pointer; lpszServerName: PWideChar; nServerPort: Word;
    lpszUserName, lpszPassword: PWideChar; dwService, dwFlags: DWORD; dwContext: NativeUInt): Pointer; stdcall;
  TInternetOpenUrlW = function(hInternet: Pointer; lpszUrl, lpszHeaders: PWideChar; dwHeadersLength,
    dwFlags: DWORD; dwContext: NativeUInt): Pointer; stdcall;
  TGetProcAddress = function(hModule: HMODULE; lpProcName: PAnsiChar): Pointer; stdcall;

const
  // Diritti che modificano un file o le sue proprieta'
  AccessoScritturaFile = GENERIC_WRITE or GENERIC_ALL or MAXIMUM_ALLOWED or FILE_WRITE_DATA or
    FILE_APPEND_DATA or FILE_WRITE_EA or FILE_WRITE_ATTRIBUTES or _DELETE or WRITE_DAC or WRITE_OWNER;
  // Diritti che modificano una chiave del registro
  AccessoScritturaRegistro = KEY_SET_VALUE or KEY_CREATE_SUB_KEY or KEY_CREATE_LINK or _DELETE or
    WRITE_DAC or WRITE_OWNER or GENERIC_WRITE or GENERIC_ALL or MAXIMUM_ALLOWED;
  FlagCancellaAllaChiusura = $04000000;
  ErroreAccessoNegatoWinsock = 10013;
  ErroreAccessoNegatoShell = 5;
  PrefissoLungo = '\\?\';
  PrefissoLungoRete = '\\?\UNC\';
  PrefissoDispositivo = '\\.\';

var
  Attiva: Boolean = False;
  RadiciAmmesse: TArray<string>;
  Blocco: TCriticalSection;
  Rifiuti: TList<TRifiutoGuardia>;
  Registro: THandle = INVALID_HANDLE_VALUE;
  Voci: TArray<TVoceGuardia>;

  OriginaleCreateFileW: Pointer;
  OriginaleCreateFileA: Pointer;
  OriginaleCopyFileW: Pointer;
  OriginaleCopyFileExW: Pointer;
  OriginaleMoveFileW: Pointer;
  OriginaleMoveFileExW: Pointer;
  OriginaleMoveFileWithProgressW: Pointer;
  OriginaleDeleteFileW: Pointer;
  OriginaleCreateDirectoryW: Pointer;
  OriginaleCreateDirectoryExW: Pointer;
  OriginaleRemoveDirectoryW: Pointer;
  OriginaleSetFileAttributesW: Pointer;
  OriginaleReplaceFileW: Pointer;
  OriginaleCreateHardLinkW: Pointer;
  OriginaleCreateSymbolicLinkW: Pointer;
  OriginaleWritePrivateProfileStringW: Pointer;
  OriginaleWritePrivateProfileSectionW: Pointer;
  OriginaleCreateProcessW: Pointer;
  OriginaleCreateProcessA: Pointer;
  OriginaleShellExecuteW: Pointer;
  OriginaleShellExecuteExW: Pointer;
  OriginaleRegSetValueExW: Pointer;
  OriginaleRegSetValueExA: Pointer;
  OriginaleRegSetKeyValueW: Pointer;
  OriginaleRegCreateKeyExW: Pointer;
  OriginaleRegDeleteValueW: Pointer;
  OriginaleRegDeleteKeyW: Pointer;
  OriginaleRegDeleteKeyExW: Pointer;
  OriginaleRegDeleteTreeW: Pointer;
  OriginaleRegisterHotKey: Pointer;
  OriginaleConnect: Pointer;
  OriginaleWSAConnect: Pointer;
  OriginaleWinHttpConnect: Pointer;
  OriginaleInternetConnectW: Pointer;
  OriginaleInternetOpenUrlW: Pointer;
  OriginaleGetProcAddress: Pointer;

// ---------------------------------------------------------------------------
// Percorsi
// ---------------------------------------------------------------------------

function PercorsoCompleto(const Percorso: string): string;
var
  Sorgente: string;
  Lunghezza: DWORD;
  Parte: PWideChar;
begin
  Sorgente := Percorso;
  if StartsText(PrefissoLungoRete, Sorgente) then
    Sorgente := '\\' + Copy(Sorgente, Length(PrefissoLungoRete) + 1, MaxInt)
  else if StartsText(PrefissoLungo, Sorgente) then
    Sorgente := Copy(Sorgente, Length(PrefissoLungo) + 1, MaxInt);
  Result := Sorgente;
  // GetFullPathName risolve i percorsi relativi sulla cartella corrente e
  // toglie i "..": e' quello che fara' Windows aprendo il file
  Lunghezza := GetFullPathNameW(PWideChar(Sorgente), 0, nil, Parte);
  if Lunghezza = 0 then
    Exit;
  SetLength(Result, Lunghezza);
  Lunghezza := GetFullPathNameW(PWideChar(Sorgente), Lunghezza, PWideChar(Result), Parte);
  SetLength(Result, Lunghezza);
end;

function PercorsoAmmessoGuardia(const Percorso: string): Boolean;
var
  Completo: string;
  Radice: string;
begin
  Result := False;
  if Trim(Percorso) = '' then
    Exit;
  Completo := PercorsoCompleto(Percorso);
  // I dispositivi (\\.\PhysicalDrive0, le pipe di altri programmi) non sono
  // file: si ammettono solo NUL e la console
  if StartsText(PrefissoDispositivo, Completo) then
    Exit(SameText(Completo, '\\.\NUL') or SameText(Completo, '\\.\CONOUT$') or SameText(Completo, '\\.\CONIN$'));
  Completo := IncludeTrailingPathDelimiter(Completo);
  for Radice in RadiciAmmesse do
    if StartsText(Radice, Completo) then
      Exit(True);
end;

function TestoDa(Testo: PWideChar): string; overload;
begin
  if Testo = nil then
    Result := ''
  else
    Result := Testo;
end;

function TestoDa(Testo: PAnsiChar): string; overload;
begin
  if Testo = nil then
    Result := ''
  else
    Result := string(AnsiString(Testo));
end;

// ---------------------------------------------------------------------------
// Rifiuti
// ---------------------------------------------------------------------------

procedure ScriviRegistro(const Riga: string);
var
  Dati: TBytes;
  Scritti: DWORD;
begin
  if Registro = INVALID_HANDLE_VALUE then
    Exit;
  Dati := TEncoding.UTF8.GetBytes(Riga + sLineBreak);
  if Length(Dati) > 0 then
    WriteFile(Registro, Dati[0], Length(Dati), Scritti, nil);
end;

procedure Rifiuta(const Funzione, Oggetto: string);
var
  Rifiuto: TRifiutoGuardia;
begin
  Rifiuto.Quando := Now;
  Rifiuto.Funzione := Funzione;
  Rifiuto.Oggetto := Oggetto;
  Blocco.Enter;
  try
    Rifiuti.Add(Rifiuto);
    ScriviRegistro(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Rifiuto.Quando) + #9 + Funzione + #9 + Oggetto);
  finally
    Blocco.Leave;
  end;
  OutputDebugString(PChar('Guardia del collaudo, rifiutato ' + Funzione + ': ' + Oggetto));
end;

function RifiutaFile(const Funzione, Percorso: string): Boolean;
begin
  Result := not PercorsoAmmessoGuardia(Percorso);
  if Result then
  begin
    Rifiuta(Funzione, Percorso);
    SetLastError(ERROR_ACCESS_DENIED);
  end;
end;

function RifiutiGuardia: TArray<TRifiutoGuardia>;
begin
  if Blocco = nil then
    Exit(nil);
  Blocco.Enter;
  try
    Result := Rifiuti.ToArray;
  finally
    Blocco.Leave;
  end;
end;

function GuardiaAttiva: Boolean;
begin
  Result := Attiva;
end;

// ---------------------------------------------------------------------------
// File
// ---------------------------------------------------------------------------

function CreaFileScrive(dwDesiredAccess, dwCreationDisposition, dwFlagsAndAttributes: DWORD): Boolean;
begin
  // OPEN_ALWAYS crea il file se manca anche quando si apre in sola lettura
  Result := ((dwDesiredAccess and AccessoScritturaFile) <> 0) or (dwCreationDisposition = CREATE_NEW) or
    (dwCreationDisposition = CREATE_ALWAYS) or (dwCreationDisposition = OPEN_ALWAYS) or
    (dwCreationDisposition = TRUNCATE_EXISTING) or ((dwFlagsAndAttributes and FlagCancellaAllaChiusura) <> 0);
end;

function GuardiaCreateFileW(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
begin
  if CreaFileScrive(dwDesiredAccess, dwCreationDisposition, dwFlagsAndAttributes) and
    RifiutaFile('CreateFileW', TestoDa(lpFileName)) then
    Exit(INVALID_HANDLE_VALUE);
  Result := TCreateFileW(OriginaleCreateFileW)(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes,
    dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
end;

function GuardiaCreateFileA(lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
begin
  if CreaFileScrive(dwDesiredAccess, dwCreationDisposition, dwFlagsAndAttributes) and
    RifiutaFile('CreateFileA', TestoDa(lpFileName)) then
    Exit(INVALID_HANDLE_VALUE);
  Result := TCreateFileA(OriginaleCreateFileA)(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes,
    dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
end;

function GuardiaCopyFileW(lpExistingFileName, lpNewFileName: PWideChar; bFailIfExists: BOOL): BOOL; stdcall;
begin
  if RifiutaFile('CopyFileW', TestoDa(lpNewFileName)) then
    Exit(False);
  Result := TCopyFileW(OriginaleCopyFileW)(lpExistingFileName, lpNewFileName, bFailIfExists);
end;

function GuardiaCopyFileExW(lpExistingFileName, lpNewFileName: PWideChar; lpProgressRoutine, lpData: Pointer;
  pbCancel: PBOOL; dwCopyFlags: DWORD): BOOL; stdcall;
begin
  if RifiutaFile('CopyFileExW', TestoDa(lpNewFileName)) then
    Exit(False);
  Result := TCopyFileExW(OriginaleCopyFileExW)(lpExistingFileName, lpNewFileName, lpProgressRoutine, lpData,
    pbCancel, dwCopyFlags);
end;

// Spostare toglie il file dalla cartella di partenza: si controllano tutte e
// due. Senza destinazione (MOVEFILE_DELAY_UNTIL_REBOOT) e' una cancellazione.
function RifiutaSpostamento(const Funzione: string; lpExistingFileName, lpNewFileName: PWideChar): Boolean;
begin
  Result := RifiutaFile(Funzione, TestoDa(lpExistingFileName));
  if not Result and (lpNewFileName <> nil) then
    Result := RifiutaFile(Funzione, TestoDa(lpNewFileName));
end;

function GuardiaMoveFileW(lpExistingFileName, lpNewFileName: PWideChar): BOOL; stdcall;
begin
  if RifiutaSpostamento('MoveFileW', lpExistingFileName, lpNewFileName) then
    Exit(False);
  Result := TMoveFileW(OriginaleMoveFileW)(lpExistingFileName, lpNewFileName);
end;

function GuardiaMoveFileExW(lpExistingFileName, lpNewFileName: PWideChar; dwFlags: DWORD): BOOL; stdcall;
begin
  if RifiutaSpostamento('MoveFileExW', lpExistingFileName, lpNewFileName) then
    Exit(False);
  Result := TMoveFileExW(OriginaleMoveFileExW)(lpExistingFileName, lpNewFileName, dwFlags);
end;

function GuardiaMoveFileWithProgressW(lpExistingFileName, lpNewFileName: PWideChar; lpProgressRoutine,
  lpData: Pointer; dwFlags: DWORD): BOOL; stdcall;
begin
  if RifiutaSpostamento('MoveFileWithProgressW', lpExistingFileName, lpNewFileName) then
    Exit(False);
  Result := TMoveFileWithProgressW(OriginaleMoveFileWithProgressW)(lpExistingFileName, lpNewFileName,
    lpProgressRoutine, lpData, dwFlags);
end;

function GuardiaDeleteFileW(lpFileName: PWideChar): BOOL; stdcall;
begin
  if RifiutaFile('DeleteFileW', TestoDa(lpFileName)) then
    Exit(False);
  Result := TDeleteFileW(OriginaleDeleteFileW)(lpFileName);
end;

function GuardiaCreateDirectoryW(lpPathName: PWideChar; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
begin
  if RifiutaFile('CreateDirectoryW', TestoDa(lpPathName)) then
    Exit(False);
  Result := TCreateDirectoryW(OriginaleCreateDirectoryW)(lpPathName, lpSecurityAttributes);
end;

function GuardiaCreateDirectoryExW(lpTemplateDirectory, lpNewDirectory: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
begin
  if RifiutaFile('CreateDirectoryExW', TestoDa(lpNewDirectory)) then
    Exit(False);
  Result := TCreateDirectoryExW(OriginaleCreateDirectoryExW)(lpTemplateDirectory, lpNewDirectory,
    lpSecurityAttributes);
end;

function GuardiaRemoveDirectoryW(lpPathName: PWideChar): BOOL; stdcall;
begin
  if RifiutaFile('RemoveDirectoryW', TestoDa(lpPathName)) then
    Exit(False);
  Result := TRemoveDirectoryW(OriginaleRemoveDirectoryW)(lpPathName);
end;

function GuardiaSetFileAttributesW(lpFileName: PWideChar; dwFileAttributes: DWORD): BOOL; stdcall;
begin
  if RifiutaFile('SetFileAttributesW', TestoDa(lpFileName)) then
    Exit(False);
  Result := TSetFileAttributesW(OriginaleSetFileAttributesW)(lpFileName, dwFileAttributes);
end;

function GuardiaReplaceFileW(lpReplacedFileName, lpReplacementFileName, lpBackupFileName: PWideChar;
  dwReplaceFlags: DWORD; lpExclude, lpReserved: Pointer): BOOL; stdcall;
begin
  if RifiutaFile('ReplaceFileW', TestoDa(lpReplacedFileName)) or
    RifiutaFile('ReplaceFileW', TestoDa(lpReplacementFileName)) or
    ((lpBackupFileName <> nil) and RifiutaFile('ReplaceFileW', TestoDa(lpBackupFileName))) then
    Exit(False);
  Result := TReplaceFileW(OriginaleReplaceFileW)(lpReplacedFileName, lpReplacementFileName, lpBackupFileName,
    dwReplaceFlags, lpExclude, lpReserved);
end;

function GuardiaCreateHardLinkW(lpFileName, lpExistingFileName: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
begin
  // Un collegamento dentro la SandBox a un file di fuori renderebbe
  // scrivibile quel file: si controllano tutti e due
  if RifiutaFile('CreateHardLinkW', TestoDa(lpFileName)) or
    RifiutaFile('CreateHardLinkW', TestoDa(lpExistingFileName)) then
    Exit(False);
  Result := TCreateHardLinkW(OriginaleCreateHardLinkW)(lpFileName, lpExistingFileName, lpSecurityAttributes);
end;

function GuardiaCreateSymbolicLinkW(lpSymlinkFileName, lpTargetFileName: PWideChar; dwFlags: DWORD): BOOLEAN; stdcall;
begin
  if RifiutaFile('CreateSymbolicLinkW', TestoDa(lpSymlinkFileName)) or
    RifiutaFile('CreateSymbolicLinkW', TestoDa(lpTargetFileName)) then
    Exit(False);
  Result := TCreateSymbolicLinkW(OriginaleCreateSymbolicLinkW)(lpSymlinkFileName, lpTargetFileName, dwFlags);
end;

// Un file .ini senza percorso, per Windows, sta nella cartella di Windows:
// PercorsoCompleto lo metterebbe nella cartella corrente, quindi si rifiuta
function RifiutaFileIni(const Funzione: string; lpFileName: PWideChar): Boolean;
var
  Nome: string;
begin
  Nome := TestoDa(lpFileName);
  if (Nome <> '') and (ExtractFilePath(Nome) = '') then
  begin
    Rifiuta(Funzione, Nome + ' (cartella di Windows)');
    SetLastError(ERROR_ACCESS_DENIED);
    Exit(True);
  end;
  Result := RifiutaFile(Funzione, Nome);
end;

function GuardiaWritePrivateProfileStringW(lpAppName, lpKeyName, lpString, lpFileName: PWideChar): BOOL; stdcall;
begin
  if RifiutaFileIni('WritePrivateProfileStringW', lpFileName) then
    Exit(False);
  Result := TWritePrivateProfileStringW(OriginaleWritePrivateProfileStringW)(lpAppName, lpKeyName, lpString,
    lpFileName);
end;

function GuardiaWritePrivateProfileSectionW(lpAppName, lpString, lpFileName: PWideChar): BOOL; stdcall;
begin
  if RifiutaFileIni('WritePrivateProfileSectionW', lpFileName) then
    Exit(False);
  Result := TWritePrivateProfileSectionW(OriginaleWritePrivateProfileSectionW)(lpAppName, lpString, lpFileName);
end;

// ---------------------------------------------------------------------------
// Programmi
// ---------------------------------------------------------------------------

// L'eseguibile che Windows avvierebbe: il nome dell'applicazione se c'e',
// altrimenti la prima parola della riga di comando, cercata come farebbe
// Windows (cartella dell'eseguibile, cartella corrente, PATH)
function EseguibileDi(const Applicazione, RigaComando: string): string;
var
  Fine: Integer;
  Trovato: array[0..MAX_PATH] of Char;
  Parte: PChar;
begin
  Result := Trim(Applicazione);
  if Result = '' then
  begin
    Result := TrimLeft(RigaComando);
    if StartsStr('"', Result) then
    begin
      Fine := PosEx('"', Result, 2);
      if Fine = 0 then
        Fine := Length(Result) + 1;
      Result := Copy(Result, 2, Fine - 2);
    end
    else
    begin
      Fine := Pos(' ', Result);
      if Fine > 0 then
        Result := Copy(Result, 1, Fine - 1);
    end;
  end;
  if (Result <> '') and (SearchPathW(nil, PChar(Result), '.exe', Length(Trovato), Trovato, Parte) > 0) then
    Result := Trovato;
end;

function RifiutaProcesso(const Funzione, Applicazione, RigaComando: string): Boolean;
var
  Eseguibile: string;
begin
  Eseguibile := EseguibileDi(Applicazione, RigaComando);
  // Solo eseguibili veri dentro le radici: un interprete (cmd, PowerShell)
  // eseguirebbe qualunque comando, e fuori dalle radici c'e' tutto il resto
  Result := not (SameText(ExtractFileExt(Eseguibile), '.exe') and PercorsoAmmessoGuardia(Eseguibile));
  if Result then
  begin
    Rifiuta(Funzione, Trim(Applicazione + ' ' + RigaComando));
    SetLastError(ERROR_ACCESS_DENIED);
  end;
end;

function GuardiaCreateProcessW(lpApplicationName, lpCommandLine: PWideChar; lpProcessAttributes,
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD;
  lpEnvironment: Pointer; lpCurrentDirectory: PWideChar; lpStartupInfo, lpProcessInformation: Pointer): BOOL; stdcall;
begin
  if RifiutaProcesso('CreateProcessW', TestoDa(lpApplicationName), TestoDa(lpCommandLine)) then
    Exit(False);
  Result := TCreateProcessW(OriginaleCreateProcessW)(lpApplicationName, lpCommandLine, lpProcessAttributes,
    lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo,
    lpProcessInformation);
end;

function GuardiaCreateProcessA(lpApplicationName, lpCommandLine: PAnsiChar; lpProcessAttributes,
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD;
  lpEnvironment: Pointer; lpCurrentDirectory: PAnsiChar; lpStartupInfo, lpProcessInformation: Pointer): BOOL; stdcall;
begin
  if RifiutaProcesso('CreateProcessA', TestoDa(lpApplicationName), TestoDa(lpCommandLine)) then
    Exit(False);
  Result := TCreateProcessA(OriginaleCreateProcessA)(lpApplicationName, lpCommandLine, lpProcessAttributes,
    lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo,
    lpProcessInformation);
end;

// ShellExecute si rifiuta sempre: apre programmi, documenti e cartelle da
// dentro le DLL della shell, dove la guardia non arriva. Il rifiuto dice che
// cosa il programma voleva aprire, che basta a collaudare il comando.
function GuardiaShellExecuteW(hWnd: HWND; Operation, FileName, Parameters, Directory: PWideChar;
  ShowCmd: Integer): HINST; stdcall;
begin
  Rifiuta('ShellExecuteW', Trim(TestoDa(Operation) + ' ' + TestoDa(FileName) + ' ' + TestoDa(Parameters)));
  SetLastError(ERROR_ACCESS_DENIED);
  Result := ErroreAccessoNegatoShell;
end;

function GuardiaShellExecuteExW(lpExecInfo: PShellExecuteInfoW): BOOL; stdcall;
begin
  if lpExecInfo <> nil then
  begin
    Rifiuta('ShellExecuteExW', Trim(TestoDa(lpExecInfo.lpVerb) + ' ' + TestoDa(lpExecInfo.lpFile) + ' ' +
      TestoDa(lpExecInfo.lpParameters)));
    lpExecInfo.hInstApp := ErroreAccessoNegatoShell;
  end
  else
    Rifiuta('ShellExecuteExW', '');
  SetLastError(ERROR_ACCESS_DENIED);
  Result := False;
end;

// ---------------------------------------------------------------------------
// Registro di Windows
// ---------------------------------------------------------------------------

function RifiutaRegistro(const Funzione, Oggetto: string): Longint;
begin
  Rifiuta(Funzione, Oggetto);
  Result := ERROR_ACCESS_DENIED;
end;

function GuardiaRegSetValueExW(hKey: HKEY; lpValueName: PWideChar; Reserved, dwType: DWORD; lpData: Pointer;
  cbData: DWORD): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegSetValueExW', TestoDa(lpValueName));
end;

function GuardiaRegSetValueExA(hKey: HKEY; lpValueName: PAnsiChar; Reserved, dwType: DWORD; lpData: Pointer;
  cbData: DWORD): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegSetValueExA', TestoDa(lpValueName));
end;

function GuardiaRegSetKeyValueW(hKey: HKEY; lpSubKey, lpValueName: PWideChar; dwType: DWORD; lpData: Pointer;
  cbData: DWORD): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegSetKeyValueW', TestoDa(lpSubKey) + '\' + TestoDa(lpValueName));
end;

// TRegistry.OpenKey(..., True) apre con RegCreateKeyEx anche solo per
// leggere: se la chiave esiste si apre in sola lettura (le scritture dopo le
// rifiuta RegSetValueEx), se manca crearla e' una scrittura e si rifiuta
function GuardiaRegCreateKeyExW(hKey: HKEY; lpSubKey: PWideChar; Reserved: DWORD; lpClass: PWideChar;
  dwOptions: DWORD; samDesired: REGSAM; lpSecurityAttributes: PSecurityAttributes; phkResult: PHKEY;
  lpdwDisposition: PDWORD): Longint; stdcall;
var
  Chiave: Winapi.Windows.HKEY;
begin
  Result := RegOpenKeyExW(hKey, lpSubKey, 0, samDesired and not AccessoScritturaRegistro, Chiave);
  if Result = ERROR_SUCCESS then
  begin
    if phkResult <> nil then
      phkResult^ := Chiave
    else
      RegCloseKey(Chiave);
    if lpdwDisposition <> nil then
      lpdwDisposition^ := REG_OPENED_EXISTING_KEY;
  end
  else
    Result := RifiutaRegistro('RegCreateKeyExW', TestoDa(lpSubKey));
end;

function GuardiaRegDeleteValueW(hKey: HKEY; lpValueName: PWideChar): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegDeleteValueW', TestoDa(lpValueName));
end;

function GuardiaRegDeleteKeyW(hKey: HKEY; lpSubKey: PWideChar): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegDeleteKeyW', TestoDa(lpSubKey));
end;

function GuardiaRegDeleteKeyExW(hKey: HKEY; lpSubKey: PWideChar; samDesired: REGSAM; Reserved: DWORD): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegDeleteKeyExW', TestoDa(lpSubKey));
end;

function GuardiaRegDeleteTreeW(hKey: HKEY; lpSubKey: PWideChar): Longint; stdcall;
begin
  Result := RifiutaRegistro('RegDeleteTreeW', TestoDa(lpSubKey));
end;

// Una scorciatoia di tastiera globale toglierebbe la stessa combinazione
// alla copia di lavoro dell'utente
function GuardiaRegisterHotKey(hWnd: HWND; id: Integer; fsModifiers, vk: UINT): BOOL; stdcall;
begin
  Rifiuta('RegisterHotKey', Format('modificatori %d, tasto %d', [fsModifiers, vk]));
  SetLastError(ERROR_ACCESS_DENIED);
  Result := False;
end;

// ---------------------------------------------------------------------------
// Rete: solo verso il computer stesso
// ---------------------------------------------------------------------------

function IndirizzoLocale(Indirizzo: PByte; Lunghezza: Integer): Boolean;
const
  FamigliaIPv4 = 2;
  FamigliaIPv6 = 23;
var
  Famiglia: Word;
  Indice: Integer;
begin
  Result := False;
  if (Indirizzo = nil) or (Lunghezza < 8) then
    Exit;
  Famiglia := PWord(Indirizzo)^;
  if Famiglia = FamigliaIPv4 then
    // sin_addr dopo famiglia e porta: 127.x.x.x
    Exit(PByte(Indirizzo + 4)^ = 127);
  if (Famiglia = FamigliaIPv6) and (Lunghezza >= 24) then
  begin
    // sin6_addr dopo famiglia, porta e flowinfo: ::1 oppure ::ffff:127.x.x.x
    for Indice := 0 to 9 do
      if PByte(Indirizzo + 8 + Indice)^ <> 0 then
        Exit(False);
    if (PByte(Indirizzo + 18)^ = $FF) and (PByte(Indirizzo + 19)^ = $FF) then
      Exit(PByte(Indirizzo + 20)^ = 127);
    if (PByte(Indirizzo + 18)^ = 0) and (PByte(Indirizzo + 19)^ = 0) and (PByte(Indirizzo + 20)^ = 0) and
      (PByte(Indirizzo + 21)^ = 0) and (PByte(Indirizzo + 22)^ = 0) and (PByte(Indirizzo + 23)^ = 1) then
      Exit(True);
  end;
end;

procedure ErroreWinsock;
var
  Imposta: TWSASetLastError;
  Modulo: HMODULE;
begin
  Modulo := GetModuleHandle('ws2_32.dll');
  if Modulo = 0 then
    Exit;
  @Imposta := TGetProcAddress(OriginaleGetProcAddress)(Modulo, 'WSASetLastError');
  if Assigned(Imposta) then
    Imposta(ErroreAccessoNegatoWinsock);
end;

function GuardiaConnect(s: NativeUInt; name: Pointer; namelen: Integer): Integer; stdcall;
begin
  if not IndirizzoLocale(name, namelen) then
  begin
    Rifiuta('connect', 'indirizzo non locale');
    ErroreWinsock;
    Exit(-1);
  end;
  Result := TConnect(OriginaleConnect)(s, name, namelen);
end;

function GuardiaWSAConnect(s: NativeUInt; name: Pointer; namelen: Integer; lpCallerData, lpCalleeData, lpSQOS,
  lpGQOS: Pointer): Integer; stdcall;
begin
  if not IndirizzoLocale(name, namelen) then
  begin
    Rifiuta('WSAConnect', 'indirizzo non locale');
    ErroreWinsock;
    Exit(-1);
  end;
  Result := TWSAConnect(OriginaleWSAConnect)(s, name, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS);
end;

function NomeLocale(const Nome: string): Boolean;
var
  Pulito: string;
begin
  Pulito := LowerCase(Trim(Nome));
  if StartsStr('[', Pulito) then
    Pulito := Copy(Pulito, 2, Length(Pulito) - 2);
  Result := (Pulito = 'localhost') or (Pulito = '::1') or StartsStr('127.', Pulito);
end;

function HostDaUrl(const Url: string): string;
var
  Inizio, Fine: Integer;
begin
  Result := Url;
  Inizio := Pos('://', Result);
  if Inizio > 0 then
    Result := Copy(Result, Inizio + 3, MaxInt);
  Fine := Pos('/', Result);
  if Fine > 0 then
    Result := Copy(Result, 1, Fine - 1);
  Fine := Pos('@', Result);
  if Fine > 0 then
    Result := Copy(Result, Fine + 1, MaxInt);
  if StartsStr('[', Result) then
  begin
    Fine := Pos(']', Result);
    if Fine > 0 then
      Result := Copy(Result, 1, Fine);
  end
  else
  begin
    Fine := Pos(':', Result);
    if Fine > 0 then
      Result := Copy(Result, 1, Fine - 1);
  end;
end;

function GuardiaWinHttpConnect(hSession: Pointer; pswzServerName: PWideChar; nServerPort: Word;
  dwReserved: DWORD): Pointer; stdcall;
begin
  if not NomeLocale(TestoDa(pswzServerName)) then
  begin
    Rifiuta('WinHttpConnect', TestoDa(pswzServerName));
    SetLastError(ERROR_ACCESS_DENIED);
    Exit(nil);
  end;
  Result := TWinHttpConnect(OriginaleWinHttpConnect)(hSession, pswzServerName, nServerPort, dwReserved);
end;

function GuardiaInternetConnectW(hInternet: Pointer; lpszServerName: PWideChar; nServerPort: Word;
  lpszUserName, lpszPassword: PWideChar; dwService, dwFlags: DWORD; dwContext: NativeUInt): Pointer; stdcall;
begin
  if not NomeLocale(TestoDa(lpszServerName)) then
  begin
    Rifiuta('InternetConnectW', TestoDa(lpszServerName));
    SetLastError(ERROR_ACCESS_DENIED);
    Exit(nil);
  end;
  Result := TInternetConnectW(OriginaleInternetConnectW)(hInternet, lpszServerName, nServerPort, lpszUserName,
    lpszPassword, dwService, dwFlags, dwContext);
end;

function GuardiaInternetOpenUrlW(hInternet: Pointer; lpszUrl, lpszHeaders: PWideChar; dwHeadersLength,
  dwFlags: DWORD; dwContext: NativeUInt): Pointer; stdcall;
begin
  if not NomeLocale(HostDaUrl(TestoDa(lpszUrl))) then
  begin
    Rifiuta('InternetOpenUrlW', TestoDa(lpszUrl));
    SetLastError(ERROR_ACCESS_DENIED);
    Exit(nil);
  end;
  Result := TInternetOpenUrlW(OriginaleInternetOpenUrlW)(hInternet, lpszUrl, lpszHeaders, dwHeadersLength,
    dwFlags, dwContext);
end;

// ---------------------------------------------------------------------------
// Sostituzione nella tabella delle importazioni
// ---------------------------------------------------------------------------

function CercaVoce(const Nome: string): Integer;
var
  Indice: Integer;
begin
  for Indice := 0 to High(Voci) do
    if Voci[Indice].Nome = Nome then
      Exit(Indice);
  Result := -1;
end;

// Le funzioni chieste dopo, per nome: l'originale si ricorda (serve alla
// funzione sostituta) e al chiamante si da' la sostituta
function GuardiaGetProcAddress(hModule: HMODULE; lpProcName: PAnsiChar): Pointer; stdcall;
var
  Indice: Integer;
begin
  Result := TGetProcAddress(OriginaleGetProcAddress)(hModule, lpProcName);
  if (Result = nil) or (NativeUInt(lpProcName) <= $FFFF) then
    Exit;
  Indice := CercaVoce(string(AnsiString(lpProcName)));
  if (Indice < 0) or (Voci[Indice].Sostituto = Result) then
    Exit;
  if Voci[Indice].Originale^ = nil then
    Voci[Indice].Originale^ := Result;
  Result := Voci[Indice].Sostituto;
end;

procedure AggiungiVoce(const Nome: string; Sostituto: Pointer; var Originale: Pointer);
var
  Voce: TVoceGuardia;
begin
  Voce.Nome := Nome;
  Voce.Sostituto := Sostituto;
  Voce.Originale := @Originale;
  Voci := Voci + [Voce];
end;

procedure PreparaVoci;
begin
  AggiungiVoce('CreateFileW', @GuardiaCreateFileW, OriginaleCreateFileW);
  AggiungiVoce('CreateFileA', @GuardiaCreateFileA, OriginaleCreateFileA);
  AggiungiVoce('CopyFileW', @GuardiaCopyFileW, OriginaleCopyFileW);
  AggiungiVoce('CopyFileExW', @GuardiaCopyFileExW, OriginaleCopyFileExW);
  AggiungiVoce('MoveFileW', @GuardiaMoveFileW, OriginaleMoveFileW);
  AggiungiVoce('MoveFileExW', @GuardiaMoveFileExW, OriginaleMoveFileExW);
  AggiungiVoce('MoveFileWithProgressW', @GuardiaMoveFileWithProgressW, OriginaleMoveFileWithProgressW);
  AggiungiVoce('DeleteFileW', @GuardiaDeleteFileW, OriginaleDeleteFileW);
  AggiungiVoce('CreateDirectoryW', @GuardiaCreateDirectoryW, OriginaleCreateDirectoryW);
  AggiungiVoce('CreateDirectoryExW', @GuardiaCreateDirectoryExW, OriginaleCreateDirectoryExW);
  AggiungiVoce('RemoveDirectoryW', @GuardiaRemoveDirectoryW, OriginaleRemoveDirectoryW);
  AggiungiVoce('SetFileAttributesW', @GuardiaSetFileAttributesW, OriginaleSetFileAttributesW);
  AggiungiVoce('ReplaceFileW', @GuardiaReplaceFileW, OriginaleReplaceFileW);
  AggiungiVoce('CreateHardLinkW', @GuardiaCreateHardLinkW, OriginaleCreateHardLinkW);
  AggiungiVoce('CreateSymbolicLinkW', @GuardiaCreateSymbolicLinkW, OriginaleCreateSymbolicLinkW);
  AggiungiVoce('WritePrivateProfileStringW', @GuardiaWritePrivateProfileStringW,
    OriginaleWritePrivateProfileStringW);
  AggiungiVoce('WritePrivateProfileSectionW', @GuardiaWritePrivateProfileSectionW,
    OriginaleWritePrivateProfileSectionW);
  AggiungiVoce('CreateProcessW', @GuardiaCreateProcessW, OriginaleCreateProcessW);
  AggiungiVoce('CreateProcessA', @GuardiaCreateProcessA, OriginaleCreateProcessA);
  AggiungiVoce('ShellExecuteW', @GuardiaShellExecuteW, OriginaleShellExecuteW);
  AggiungiVoce('ShellExecuteExW', @GuardiaShellExecuteExW, OriginaleShellExecuteExW);
  AggiungiVoce('RegSetValueExW', @GuardiaRegSetValueExW, OriginaleRegSetValueExW);
  AggiungiVoce('RegSetValueExA', @GuardiaRegSetValueExA, OriginaleRegSetValueExA);
  AggiungiVoce('RegSetKeyValueW', @GuardiaRegSetKeyValueW, OriginaleRegSetKeyValueW);
  AggiungiVoce('RegCreateKeyExW', @GuardiaRegCreateKeyExW, OriginaleRegCreateKeyExW);
  AggiungiVoce('RegDeleteValueW', @GuardiaRegDeleteValueW, OriginaleRegDeleteValueW);
  AggiungiVoce('RegDeleteKeyW', @GuardiaRegDeleteKeyW, OriginaleRegDeleteKeyW);
  AggiungiVoce('RegDeleteKeyExW', @GuardiaRegDeleteKeyExW, OriginaleRegDeleteKeyExW);
  AggiungiVoce('RegDeleteTreeW', @GuardiaRegDeleteTreeW, OriginaleRegDeleteTreeW);
  AggiungiVoce('RegisterHotKey', @GuardiaRegisterHotKey, OriginaleRegisterHotKey);
  AggiungiVoce('connect', @GuardiaConnect, OriginaleConnect);
  AggiungiVoce('WSAConnect', @GuardiaWSAConnect, OriginaleWSAConnect);
  AggiungiVoce('WinHttpConnect', @GuardiaWinHttpConnect, OriginaleWinHttpConnect);
  AggiungiVoce('InternetConnectW', @GuardiaInternetConnectW, OriginaleInternetConnectW);
  AggiungiVoce('InternetOpenUrlW', @GuardiaInternetOpenUrlW, OriginaleInternetOpenUrlW);
  AggiungiVoce('GetProcAddress', @GuardiaGetProcAddress, OriginaleGetProcAddress);
end;

procedure ScriviPuntatore(Destinazione: PPointer; Valore: Pointer);
var
  Protezione: DWORD;
begin
  if VirtualProtect(Destinazione, SizeOf(Pointer), PAGE_READWRITE, Protezione) then
  begin
    Destinazione^ := Valore;
    VirtualProtect(Destinazione, SizeOf(Pointer), Protezione, Protezione);
  end;
end;

// Scorre le importazioni del modulo e sostituisce, per nome, le funzioni
// delle voci. L'indirizzo trovato nella tabella e' l'originale.
procedure SostituisciImportazioni(Modulo: HMODULE);
const
  FlagOrdinale = NativeUInt(1) shl (SizeOf(NativeUInt) * 8 - 1);
var
  Intestazione: PImageNtHeaders;
  Cartella: TImageDataDirectory;
  Descrittore: PDescrittoreImportazione;
  Nomi, Indirizzi: PNativeUInt;
  Nome: string;
  Indice: Integer;
begin
  Intestazione := PImageNtHeaders(Modulo + NativeUInt(PImageDosHeader(Modulo)._lfanew));
  Cartella := Intestazione.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
  if Cartella.VirtualAddress = 0 then
    Exit;
  Descrittore := PDescrittoreImportazione(Modulo + Cartella.VirtualAddress);
  while Descrittore.Name <> 0 do
  begin
    if Descrittore.OriginalFirstThunk <> 0 then
      Nomi := PNativeUInt(Modulo + Descrittore.OriginalFirstThunk)
    else
      Nomi := PNativeUInt(Modulo + Descrittore.FirstThunk);
    Indirizzi := PNativeUInt(Modulo + Descrittore.FirstThunk);
    while Nomi^ <> 0 do
    begin
      if (Nomi^ and FlagOrdinale) = 0 then
      begin
        // IMAGE_IMPORT_BY_NAME: due byte di suggerimento, poi il nome
        Nome := string(AnsiString(PAnsiChar(Modulo + Nomi^ + 2)));
        Indice := CercaVoce(Nome);
        if (Indice >= 0) and (Pointer(Indirizzi^) <> Voci[Indice].Sostituto) then
        begin
          if Voci[Indice].Originale^ = nil then
            Voci[Indice].Originale^ := Pointer(Indirizzi^);
          ScriviPuntatore(PPointer(Indirizzi), Voci[Indice].Sostituto);
        end;
      end;
      Inc(Nomi);
      Inc(Indirizzi);
    end;
    Inc(Descrittore);
  end;
end;

procedure AttivaGuardia(const Radici: array of string; const FileRegistro: string);
var
  Radice: string;
begin
  if Attiva then
    Exit;
  for Radice in Radici do
    if Trim(Radice) <> '' then
      RadiciAmmesse := RadiciAmmesse + [IncludeTrailingPathDelimiter(PercorsoCompleto(Radice))];
  Blocco := TCriticalSection.Create;
  Rifiuti := TList<TRifiutoGuardia>.Create;
  // Il registro si apre prima della sostituzione, con la funzione originale:
  // le righe dopo si scrivono con WriteFile, che non passa dalla guardia
  if FileRegistro <> '' then
  begin
    Registro := CreateFile(PChar(FileRegistro), FILE_APPEND_DATA, FILE_SHARE_READ, nil, OPEN_ALWAYS,
      FILE_ATTRIBUTE_NORMAL, 0);
    ScriviRegistro(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + #9 + 'avvio' + #9 + 'radici ammesse: ' +
      string.Join('; ', RadiciAmmesse));
  end;
  PreparaVoci;
  // Le funzioni che l'eseguibile non importa direttamente prendono
  // l'originale alla prima richiesta, in GuardiaGetProcAddress
  SostituisciImportazioni(HInstance);
  Attiva := True;
end;

initialization

finalization

if Registro <> INVALID_HANDLE_VALUE then
  CloseHandle(Registro);

end.
