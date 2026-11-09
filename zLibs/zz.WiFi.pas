unit zz.wifi;

interface

type
  TAndroidStatiWifi = (WIFI_SCONOSCIUTO, WIFI_ATTIVO, WIFI_DISATTIVO);

function AttivaWIFI(out ErrorMsg: string; const raiseError: boolean): boolean;
function DisattivaWIFI(out ErrorMsg: string; const raiseError: boolean): boolean;
function StatoWifi: TAndroidStatiWifi;

implementation

{$IFDEF ANDROID}

uses
  System.SysUtils,
  Androidapi.Helpers,
  Androidapi.JNI.Net,
  Androidapi.JNI.GraphicsContentViewText,
  FMX.Forms;
{$ENDIF}

function StatoWifi: TAndroidStatiWifi;
{$IFDEF ANDROID}
var
  WiFIServiceNative: JWifiManager;
{$ENDIF}
begin
  Result := WIFI_SCONOSCIUTO;
{$IFDEF ANDROID}
  WiFIServiceNative := TJWifiManager.Wrap(TAndroidHelper.Context.getSystemService(TJContext.JavaClass.WIFI_SERVICE));

  if not Assigned(WiFIServiceNative) then
    Exit;

  if WiFIServiceNative.getWifiState >= 2 then
    Result := WIFI_ATTIVO
  else
    Result := WIFI_DISATTIVO;
{$ENDIF}
end;

function AttivaWIFI(out ErrorMsg: string; const raiseError: boolean): boolean;
var
{$IFDEF ANDROID}
  WiFIServiceNative: JWifiManager;
{$ENDIF}
  Step: integer;
begin
  Result := false;
  ErrorMsg := '';

{$IFDEF ANDROID}
  WiFIServiceNative := TJWifiManager.Wrap(TAndroidHelper.Context.getSystemService(TJContext.JavaClass.WIFI_SERVICE));

  if not Assigned(WiFIServiceNative) then
    Exit;

  Result := WiFIServiceNative.getWifiState >= 2;

  if Result then
    Exit;

  if not WiFIServiceNative.setWifiEnabled(true) then
  begin
    ErrorMsg := 'Impossibile attivare il Wi-Fi';

    if raiseError then
      raise exception.Create(ErrorMsg)
    else
      Exit;
  end;

  Step := 0;
  repeat
    Result := WiFIServiceNative.getWifiState >= 2;
    if Result then
      Exit;

    sleep(500);

    inc(Step);
    if Step >= 50 then
    begin
      ErrorMsg := 'Timeout attivazione del Wi-Fi';

      if raiseError then
        raise exception.Create(ErrorMsg)
      else
        Exit;
    end;

  until Result or Application.Terminated;
{$ENDIF}
end;

function DisattivaWIFI(out ErrorMsg: string; const raiseError: boolean): boolean;
var
{$IFDEF ANDROID}
  WiFIServiceNative: JWifiManager;
{$ENDIF}
  Step: integer;
begin
  Result := false;
  ErrorMsg := '';

{$IFDEF ANDROID}
  WiFIServiceNative := TJWifiManager.Wrap(TAndroidHelper.Context.getSystemService(TJContext.JavaClass.WIFI_SERVICE));

  if not Assigned(WiFIServiceNative) then
    Exit;

  Result := WiFIServiceNative.getWifiState < 2;
  if Result then
    Exit;

  if not WiFIServiceNative.setWifiEnabled(false) then
  begin
    ErrorMsg := 'Impossibile disattivare il Wi-Fi';

    if raiseError then
      raise exception.Create(ErrorMsg)
    else
      Exit;
  end;

  Step := 0;
  repeat
    Result := WiFIServiceNative.getWifiState < 2;
    if Result then
      Exit;

    sleep(500);

    inc(Step);
    if Step >= 50 then
    begin
      ErrorMsg := 'Timeout disattivazione del Wi-Fi';

      if raiseError then
        raise exception.Create(ErrorMsg)
      else
        Exit;
    end;

  until Result or Application.Terminated;
{$ENDIF}
end;

end.
