unit zz.ActiveDirectory;

interface

function ActiveDirectoryAuthenticate(const Domain, UserName, Password: string): boolean;

implementation

uses
  SysUtils,
{$IFNDEF LINUX}
  ActiveX, // used for the COM Moniker stuff...
  ActiveDs_TLB, // the created type library
{$ENDIF }
  zz.SmartInspect;

{$IFNDEF LINUX}
function ADsOpenObject(lpszPathName: WideString; lpszUserName: WideString; lpszPassword: WideString; dwReserved: DWORD; const riid: TGUID; out ppObject): HRESULT; stdcall;
// safecall;
external 'activeds.dll';

function ActiveDirectoryAuthenticate(const Domain, UserName, Password: string): boolean;
var
  hr: HRESULT;
  Obj: IADs;
  // Obj: IAdsUser;
begin
  SiMain.EnterMethod('lib.ActiveDirectory.ActiveDirectoryAuthenticate');

  if Domain.IsEmpty or UserName.IsEmpty or Password.IsEmpty then
  begin
    result := false;
    exit;
  end;

  CoInitialize(nil);
  try
    hr := ADsOpenObject('LDAP://' + Domain, UserName, Password, ADS_SECURE_AUTHENTICATION, IADs, Obj);
    result := Succeeded(hr);
    Obj := nil;
  finally
    CoUninitialize;
  end;

  SiMain.LogBoolean('lib.ActiveDirectory.ActiveDirectoryAuthenticate', result);
  SiMain.LeaveMethod('lib.ActiveDirectory.ActiveDirectoryAuthenticate');
end;
{$ELSE}

function ActiveDirectoryAuthenticate(const Domain, UserName, Password: string): boolean;
begin
  result := false;
end;
{$ENDIF }

end.
