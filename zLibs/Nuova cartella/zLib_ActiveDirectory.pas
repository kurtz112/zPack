unit zLib_ActiveDirectory;

interface

function Login(const Domain, UserName, Password: string): boolean;

implementation

uses
  SysUtils,
  ActiveX, // used for the COM Moniker stuff...
  ActiveDs_TLB, // the created type library
  ComObj; // used for OleCheck and other COM functions

function ADsOpenObject(lpszPathName: WideString;
  lpszUserName: WideString;
  lpszPassword: WideString;
  dwReserved: DWORD;
  const riid: TGUID;
  out ppObject): HRESULT; safecall; external 'activeds.dll';

//function ADsOpenObject      ;external ADSI;

function Login(const Domain, UserName, Password: string): boolean;
var
  Obj: IADs;
begin
  result := False;
  CoInitialize(nil);
  try
    result := Succeeded(ADsOpenObject('WinNT://' + Domain, UserName, Password, ADS_SECURE_AUTHENTICATION, IADs, Obj));
  finally
    CoUninitialize;
  end;
end;

end.

