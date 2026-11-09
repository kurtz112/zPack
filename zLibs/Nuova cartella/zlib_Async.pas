unit zLib_Async;

interface

uses
  SysUtils,
  Classes,
  Forms,
  zBaseLib;

procedure Async(proc: TProc);

implementation

type
  TzThread = class(TThread)
  public
    proc: TProc;
    ErrorMsg: string;
    ok: Boolean;

    procedure Execute; override;
  end;

  { TzThread }

procedure TzThread.Execute;
begin
  inherited;
  ErrorMsg := '';
  ok := True;

  try
    proc;
  except
    on e: Exception do
    begin
      ErrorMsg := e.message;
      ok := False;
    end;
  end;

  Terminate;
end;

procedure Async(proc: TProc);
var
  t: TzThread;
begin
  StartWait('Attendere...');
  try
    t := TzThread.Create(True);
    try
      t.proc := proc;
      t.FreeOnTerminate := False;
      t.Resume;
      while not t.Terminated do
        Application.ProcessMessages;

      if not t.ok then
        raise Exception.Create(t.ErrorMsg);
    finally
      FreeAndNil(t);
    end;
  finally
    StopWait;
  end;
end;

end.

zfbdataset
