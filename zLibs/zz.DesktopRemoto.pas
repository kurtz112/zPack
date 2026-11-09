unit zz.DesktopRemoto;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes;

const
  WTS_CURRENT_SERVER_HANDLE: THandle = 0;
  WTS_CURRENT_SESSION: DWORD = DWORD(-1);

type
  WTS_INFO_CLASS = (WTSInitialProgram, WTSApplicationName, WTSWorkingDirectory, WTSOEMId, WTSSessionId, WTSUserName, WTSWinStationName, WTSDomainName, WTSConnectState, WTSClientBuildNumber,
    WTSClientName, WTSClientDirectory, WTSClientProductId, WTSClientHardwareId, WTSClientAddress, WTSClientDisplay, WTSClientProtocolType, WTSIdleTime, WTSLogonTime, WTSIncomingBytes,
    WTSOutgoingBytes, WTSIncomingFrames, WTSOutgoingFrames, WTSClientInfo, WTSSessionInfo, WTSSessionInfoEx, WTSConfigInfo, WTSValidationInfo, WTSSessionAddressV4, WTSIsRemoteSession);

  WTS_CONNECTSTATE_CLASS = (WTSActive, // User logged on to WinStation
    WTSConnected, // WinStation connected to client
    WTSConnectQuery, // In the process of connecting to client
    WTSShadow, // Shadowing another WinStation
    WTSDisconnected, // WinStation logged on without client
    WTSIdle, // Waiting for client to connect
    WTSListen, // WinStation is listening for connection
    WTSReset, // WinStation is being reset
    WTSDown, // WinStation is down due to error
    WTSInit); // WinStation in initialization

  TWTSQuerySessionInformationFunction = function(hServer: THandle; SessionId: DWORD; WTSInfoClass: WTS_INFO_CLASS; var ppBuffer: Pointer; var pBytesReturned: DWORD): BOOL; stdcall;
  TWTSFreeMemoryProcedure = procedure(pMemory: Pointer); stdcall;

function IsTerminalServer: boolean;
function TSClientState: WTS_CONNECTSTATE_CLASS;

implementation


function IsTerminalServer: boolean;
const
  sm_RemoteSession = $1000; { from WinUser.h }
  sm_RemoteControl = $2001; { from WinUser.h }
begin
  Result := (GetSystemMetrics(sm_RemoteSession) <> 0) or (GetSystemMetrics(sm_RemoteControl) <> 0);
end;

function TSClientState: WTS_CONNECTSTATE_CLASS;
var
  LibHandle: HMODULE;
  WTSQuerySessionInformation: TWTSQuerySessionInformationFunction;
  WTSFreeMemory: TWTSFreeMemoryProcedure;
  ClientState: Pointer;
  cBytesReturned: DWORD;
begin

  LibHandle := LoadLibrary('wtsapi32.dll');
  if LibHandle <> 0 then
  begin
    try
      @WTSQuerySessionInformation := GetProcAddress(LibHandle, 'WTSQuerySessionInformationA');
      @WTSFreeMemory := GetProcAddress(LibHandle, 'WTSFreeMemory');
      if Assigned(WTSQuerySessionInformation) and Assigned(WTSFreeMemory) then
      begin
        if WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, WTS_CURRENT_SESSION, WTSConnectState, ClientState, cBytesReturned) then
          try
            result := WTS_CONNECTSTATE_CLASS(ClientState^);
          finally
            WTSFreeMemory(ClientState);
          end;

      end;
    finally
      FreeLibrary(LibHandle);
    end;
  end;
end;

end.
