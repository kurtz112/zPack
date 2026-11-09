unit zLib_AsyncDB;

interface

uses
  SysUtils,
  Classes,
  Forms,
  DB,
  zFbDataSet;

procedure AsyncOpenDataSet(DataSet: TzFbDataSet);
procedure AsyncExecStoredProc(StoreProc: TzFbStoredProc);
procedure AsyncExecSQL(SQL: TzFbSQL);

implementation

uses
  zBaseLib;

type
  TThreadAction = (taOpenDataSet, taExecProc, taExecSql);

  TzThread = class(TThread)
    DataSet: TzFbDataSet;
    StoreProc: TzFbStoredProc;
    SQL: TzFbSQL;
    Action: TThreadAction;
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

  case Action of
    taOpenDataSet:
      begin
        System.TMonitor.Enter(DataSet);
        try
          try
            DataSet.Reopen(True);
          except
            on e: Exception do
            begin
              ErrorMsg := e.Message;
              ok := False;
            end;
          end;
        finally
          System.TMonitor.Exit(DataSet);
        end;
      end;
    taExecProc:
      begin
        System.TMonitor.Enter(StoreProc);
        try
          try
            StoreProc.ExecProc;
          except
            on e: Exception do
            begin
              ErrorMsg := e.Message;
              ok := False;
            end;
          end;
        finally
          System.TMonitor.Exit(StoreProc);
        end;
      end;
    taExecSql:
      begin
        System.TMonitor.Enter(SQL);
        try
          try
            SQL.ExecQuery;
          except
            on e: Exception do
            begin
              ErrorMsg := e.Message;
              ok := False;
            end;
          end;
        finally
          System.TMonitor.Exit(SQL);
        end;
      end;

  end;

  //
  Terminate;
end;

procedure AsyncOpenDataSet(DataSet: TzFbDataSet);
var
  t: TzThread;
begin
  Assert(Assigned(DataSet));

  StartWait;
  try
    t := TzThread.Create(True);
    try
      t.Action := taOpenDataSet;
      t.DataSet := DataSet;
      t.FreeOnTerminate := False;
      t.Resume;
      while not t.Terminated do
        Application.ProcessMessages;

      if not t.Ok then
        raise Exception.Create(t.ErrorMsg);
    finally
      FreeAndNil(t);
    end;
  finally
    StopWait;
  end;
end;

procedure AsyncExecStoredProc(StoreProc: TzFbStoredProc);
var
  t: TzThread;
begin
  Assert(Assigned(StoreProc));

  StartWait;
  try
    t := TzThread.Create(True);
    try
      t.Action := taExecProc;
      t.StoreProc := StoreProc;
      t.FreeOnTerminate := False;
      t.Resume;
      while not t.Terminated do
        Application.ProcessMessages;

      if not t.Ok then
        raise Exception.Create(t.ErrorMsg);
    finally
      FreeAndNil(t);
    end;
  finally
    StopWait;
  end;
end;

procedure AsyncExecSQL(SQL: TzFbSQL);
var
  t: TzThread;
begin
  Assert(Assigned(SQL));

  StartWait;
  try
    t := TzThread.Create(True);
    try
      t.Action := taExecSql;
      t.SQL := SQL;
      t.FreeOnTerminate := False;
      t.Resume;
      while not t.Terminated do
        Application.ProcessMessages;

      if not t.Ok then
        raise Exception.Create(t.ErrorMsg);
    finally
      FreeAndNil(t);
    end;
  finally
    StopWait;
  end;
end;

end.

