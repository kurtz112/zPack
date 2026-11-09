unit zLib_ServicesControl;

interface

uses Windows,
  WinSvc;

function ServiceStop(sMachine, sService: WideString): boolean;

function ServiceStart(sMachine, sService: WideString): boolean;

function ServiceStatus(sMachine, sService: WideString): Integer;

function RemoveService(sMachine, sService: WideString): Boolean;

function ServiceGetStatus(sMachine, sService: string): DWord;

function GetStatusStr(sMachine, sService: string): string;

implementation

//----------------------------------------------------------------------------------------------------------------------

// sMachine .. \\SERVER or empty for local machine
// sService ... service name, ie: mysqld
// return TRUE if successful

function ServiceStart(sMachine, sService: WideString): boolean;

var
  schm, // service control manager handle
  schs: SC_Handle; // service handle
  ss: TServiceStatus; // service status
  psTemp: PChar; // temp char pointer
  dwChkP: DWord; // check point

begin
  ss.dwCurrentState := 0;

  // connect to the service control manager
  schm := OpenSCManagerW(PWideChar(sMachine), nil, SC_MANAGER_CONNECT);

  // if successful...
  if (schm > 0) then
  begin
    // open a handle to the specified service
    schs := OpenServiceW(schm, PWideChar(sService), SERVICE_START or
      SERVICE_QUERY_STATUS);

    // if successful...
    if (schs > 0) then
    begin
      psTemp := nil;
      if (StartService(schs, 0, psTemp)) then
      begin
        Sleep(2000);

        // check status
        if (QueryServiceStatus(schs, ss)) then
        begin
          while (SERVICE_RUNNING <> ss.dwCurrentState) do
          begin
            // dwCheckPoint contains a
            // value that the service
            // increments periodically
            // to report its progress
            // during a lengthy
            // operation.
            //
            // save current value

            dwChkP := ss.dwCheckPoint;

            // wait a bit before
            // checking status again
            //
            // dwWaitHint is the
            // estimated amount of time
            // the calling program
            // should wait before calling
            // QueryServiceStatus() again
            //
            // idle events should be
            // handled here...
            //Sleep(ss.dwWaitHint);
            Sleep(2000);

            if (not QueryServiceStatus(schs, ss)) then
            begin
              // couldn't check status
              break;
            end;

            if (ss.dwCheckPoint <= dwChkP) then
            begin
              // QueryServiceStatus
              // didn't increment
              // dwCheckPoint as it
              // should have.
              // avoid an infinite
              // loop by breaking
              break;
            end;
          end;
        end;
      end;

      // close service handle
      CloseServiceHandle(schs);
    end;

    // close service control
    // manager handle
    CloseServiceHandle(schm);
  end;

  // return TRUE if
  // the service status is running
  Result := (SERVICE_RUNNING = ss.dwCurrentState);
end;

//----------------------------------------------------------------------------------------------------------------------

// sMachine .. \\SERVER or empty for local machine
// sService ... service name, ie: mysqld
// return TRUE if successful

function ServiceStop(sMachine, sService: WideString): boolean;

var
  schm, // service control manager handle
  schs: SC_Handle; // service handle
  ss: TServiceStatus; // service status
  dwChkP: DWord; // check point
  counter: Integer;

begin
  // connect to the service
  // control manager
  schm := OpenSCManagerW(PWideChar(sMachine), nil, SC_MANAGER_CONNECT);

  counter := 0;

  // if successful...
  if (schm > 0) then
  begin
    // open a handle to the specified service
    schs := OpenServiceW(schm, PWideChar(sService), SERVICE_STOP or
      SERVICE_QUERY_STATUS);

    // if successful...
    if (schs > 0) then
    begin
      if (ControlService(schs, SERVICE_CONTROL_STOP, ss)) then
      begin
        // check status
        if (QueryServiceStatus(
          schs,
          ss)) then
        begin
          while ((SERVICE_STOPPED
            <> ss.dwCurrentState) and (counter < 10)) do
          begin
            // dwCheckPoint contains a
            // value that the service
            // increments periodically
            // to report its progress
            // during a lengthy
            // operation.
            //
            // save current value
            dwChkP := ss.dwCheckPoint;

            // wait a bit before
            // checking status again
            //
            // dwWaitHint is the
            // estimated amount of time
            // the calling program
            // should wait before calling
            // QueryServiceStatus() again
            //
            // idle events should be
            // handled here...
            //Sleep(ss.dwWaitHint);
            Sleep(1000);

            inc(counter);

            if (not QueryServiceStatus(schs, ss)) then
            begin
              // couldn't check status
              break;
            end;

            if (ss.dwCheckPoint < dwChkP) then
            begin
              // QueryServiceStatus
              // didn't increment
              // dwCheckPoint as it
              // should have.
              // avoid an infinite
              // loop by breaking
              break;
            end;
          end;
        end;
      end;

      // close service handle
      CloseServiceHandle(schs);
    end;

    // close service control
    // manager handle
    CloseServiceHandle(schm);
  end;

  // return TRUE if
  // the service status is stopped
  Result := (SERVICE_STOPPED = ss.dwCurrentState);
end;

//----------------------------------------------------------------------------------------------------------------------

// sMachine .. \\SERVER or empty for local machine
// sService ... service name, ie: mysqld
// return codes:
//   -1 if not successful
//   SERVICE_STOPPED
//   SERVICE_RUNNING
//   SERVICE_PAUSED
//   SERVICE_START_PENDING
//   SERVICE_STOP_PENDING
//   SERVICE_CONTINUE_PENDING
//   SERVICE_PAUSE_PENDING

function ServiceStatus(sMachine, sService: WideString): Integer;

var
  SC: SC_Handle;
  SHwnd: SC_Handle;
  ST: TServiceStatus;

begin
  SC := OpenSCManager(nil, nil, GENERIC_READ);
  if (SC > 0) then
  begin
    SHwnd := OpenServiceW(SC, PWideChar(sService), SERVICE_QUERY_STATUS);
    if (SHwnd > 0) then
    begin
      if (not (QueryServiceStatus(SHwnd, ST))) then
        Result := -1
          //raise EMyxSystemError.Create(_('Cannot query service state'), GetLastError)
      else
        Result := ST.dwCurrentState;

      CloseServiceHandle(SHwnd);
    end
    else
      Result := -1;
    //raise EMyxSystemError.Create(_('Cannot query service state'), GetLastError);

    CloseServiceHandle(SC);
  end
  else
    Result := -1;
  //raise EMyxSystemError.Create(_('Cannot query service state'), GetLastError);
end;

//----------------------------------------------------------------------------------------------------------------------

//Returns 0 on success

function RemoveService(sMachine, sService: WideString): Boolean;

var
  SCMHandle: SC_Handle;
  ServiceHandle: SC_Handle;

begin
  SCMHandle := OpenSCManagerW(nil, nil, SC_MANAGER_CREATE_SERVICE);
  if (SCMHandle > 0) then
  begin
    ServiceHandle := OpenServiceW(SCMHandle, PWideChar(sService), SERVICE_ALL_ACCESS);
    if (ServiceHandle > 0) then
    begin
      if (not (DeleteService(ServiceHandle))) then
        Result := False
          //raise EMyxSystemError.Create(_('Cannot delete service'), GetLastError)
      else
        Result := True;

      CloseServiceHandle(ServiceHandle);
    end
    else
      Result := False;
    //raise EMyxSystemError.Create(_('Cannot open service'), GetLastError);

    CloseServiceHandle(SCMHandle);
  end
  else
    Result := False;
  //raise EMyxSystemError.Create(_('Cannot connect to service manager'), GetLastError);
end;

function ServiceGetStatus(sMachine, sService: string): DWord;
var
  h_manager, h_svc: SC_Handle;
  service_status: TServiceStatus;
  hStat: DWord;
begin
  hStat := 1;
  h_manager := OpenSCManager(PChar(sMachine), nil, SC_MANAGER_CONNECT);

  if h_manager > 0 then
  begin
    h_svc := OpenService(h_manager, PChar(sService), SERVICE_QUERY_STATUS);

    if h_svc > 0 then
    begin
      if (QueryServiceStatus(h_svc, service_status)) then
        hStat := service_status.dwCurrentState;

      CloseServiceHandle(h_svc);
    end;
    CloseServiceHandle(h_manager);
  end;

  Result := hStat;
end;

function GetStatusStr(sMachine, sService: string): string;
begin
  Result := '';
  case ServiceGetStatus(sMachine, sService) of
    SERVICE_STOPPED:
      Result := 'SERVICE_STOPPED';
    SERVICE_RUNNING:
      Result := 'SERVICE_RUNNING';
    SERVICE_PAUSED:
      Result := 'SERVICE_PAUSED';
    SERVICE_START_PENDING:
      Result := 'SERVICE_START_PENDING';
    SERVICE_STOP_PENDING:
      Result := 'SERVICE_STOP_PENDING';
    SERVICE_CONTINUE_PENDING:
      Result := 'SERVICE_CONTINUE_PENDING';
    SERVICE_PAUSE_PENDING:
      Result := 'SERVICE_PAUSE_PENDING';
  end;
end;
end.

