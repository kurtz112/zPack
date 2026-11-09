unit zLib_FbBackup;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  IB_Services,
  uFBServices,
  ExtCtrls,
  TaskDialog,
  Mask,
  wwdbedit,
  Wwdotdot,
  Wwdbcomb,
  AbBase,
  AbBrowse,
  AbZBrows,
  AbZipper,
  JvStringHolder,
  AppEvnts,
  AbMeter,
  AbZipKit,
  AbCBrows,
  AbCabMak,
  ComCtrls,
  AbArcTyp,
  DProgress,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdExplicitTLSClientServerBase,
  IdFTP,
  DB,
  DBCtrls,
  zSplitter,
  Grids,
  DBGrids;

type
  TBackup = class(TObject)
    AdvInputTaskDialog1: TAdvInputTaskDialog;
    AbZipper: TAbZipper;
    //    StatusBar1: TStatusBar;
    //    Panel1: TPanel;
    //    JobsSrc: TDataSource;
    //    Timer1: TTimer;
    //    pnlBackup: TPanel;
    //    ProgressBar1: TProgressBar;
    //    ProgressBar2: TProgressBar;
    //    ProgressBar3: TProgressBar;
    //    DBGrid1: TDBGrid;
    //    Panel3: TPanel;
    //    Panel5: TPanel;
    //    Memo1: TMemo;
    //    Panel4: TPanel;
    //    progBackup: TDProgressBar;
    //    Label1: TLabel;
    procedure AbZipperArchiveItemProgress(Sender: TObject; Item: TAbArchiveItem;
      Progress: Byte; var Abort: Boolean);
    procedure AbZipperArchiveProgress(Sender: TObject; Progress: Byte; var Abort:
      Boolean);
    procedure AbZipperArchiveSaveProgress(Sender: TObject; Progress: Byte; var
      Abort: Boolean);
    destructor Destroy;
    constructor Create;
    procedure ServerLog(Sender: TObject; const Text: string);
    procedure FTPLog(msg: string);
    procedure Timer1Timer(Sender: TObject);
  private
    LogBackup: TStringList;
    function TempFolder: string;
    function GetBackupFileName(DataBaseName: string): string;
    function doBackup: string;
    function doCompress(BackupFileName: string): Boolean;
    procedure doJob;
    procedure doDeleteTmp;
    procedure doCopieLocali(BackupFileName: string);
    procedure doCopieFTP(BackupFileName: string);
  public
    procedure doJobs;

  end;

var
  backupProc: TBackup;

implementation

uses zMsg,
  zBaseLib,
  zWaitFrm,
  AbUtils,
  AbZipTyp,
  win95,
  ShellApi,
  DataModuled_Backup,
  zBackupTypes,
  FtpConnection;

constructor TBackup.Create;
begin
  //  pnlBackup.Visible := False;
  ForceDirectories(TempFolder);
  LogBackup := TStringList.Create;
  dmBackup := TdmBackup.Create(nil);
  AbZipper := TAbZipper.Create(nil);
  //  Timer1.Enabled := True;
end;

destructor TBackup.Destroy;
begin
  FreeAndNil(LogBackup);
  FreeAndNil(AbZipper);
  FreeAndNil(dmBackup);
end;

function TBackup.TempFolder: string;
begin
  Result := CalcPath(Path + 'Tmp');
end;

function TBackup.GetBackupFileName(DataBaseName: string): string;

  function NomeFileFromDate(Data: TDateTime): string;
  var
    anno, mese, giorno: word;
    hh, mm, ss, ms: word;
  begin
    DecodeDate(data, anno, mese, giorno);
    DecodeTime(data, hh, mm, ss, ms);
    result := inttostr(Anno);

    if mese < 10 then
      result := result + '0';
    result := result + inttostr(Mese);

    if giorno < 10 then
      result := result + '0';
    result := result + inttostr(Giorno);
    result := result + '-';
    if hh < 10 then
      result := result + '0';
    result := result + inttostr(hh);

    if mm < 10 then
      result := result + '0';
    result := result + inttostr(mm)
      //result := result + '  ' + FormatDateTime('dddd, dd mmmm yyyy', Now);

  end;

begin
  result := FileNameNoExt(DataBaseName); // ExtractFileName(DataBaseName)
  result := NomeFileFromDate(Date + Time) + '_' + Result;
  result := TempFolder + ChangeFileExt(result, '.FBK');
end;

procedure TBackup.AbZipperArchiveItemProgress(Sender: TObject; Item: TAbArchiveItem; Progress: Byte; var Abort: Boolean);
begin
  //  ProgressBar1.Position := Progress;
end;

procedure TBackup.AbZipperArchiveProgress(Sender: TObject; Progress: Byte; var Abort: Boolean);
begin
  //  ProgressBar2.Position := Progress;
end;

procedure TBackup.AbZipperArchiveSaveProgress(Sender: TObject; Progress: Byte; var Abort: Boolean);
begin
  //  ProgressBar3.Position := Progress;
end;

procedure TBackup.ServerLog(Sender: TObject; const Text: string);
begin
  Writeln(Text); //  Memo1.Lines.add(Text);

  LogBackup.Add(text);
  Application.ProcessMessages;
end;

procedure TBackup.FTPLog(msg: string);
begin
  //Writeln(Msg);//Memo1.Lines.add(Msg);
end;

procedure TBackup.doDeleteTmp;
begin
  Win95Erase(Application.Handle, TempFolder + '*.*', true);
end;

procedure TBackup.doJob;
var
  backupFile: string;
begin
  Writeln(''); //// Memo1.Lines.Clear;
  backupFile := doBackup;
  if backupFile <> '' then
    if doCompress(backupFile) then
    begin
      doCopieLocali(backupFile);
      doCopieFTP(backupFile);
    end;
  doDeleteTmp;
end;

procedure TBackup.doJobs;
begin
  dmBackup.ApriDB;

  dmBackup.Jobs.First;
  while not dmBackup.Jobs.Eof do
  begin
    Application.ProcessMessages;
    doJob;
    dmBackup.Jobs.Next;
  end;
  
end;

function TBackup.doBackup: string;

  function ProgExecute(cmdline: string; wait: boolean): boolean;
  var
    startupInfo: TStartupInfo;
    processInfo: TProcessInformation;
    errorMsg: string;
  begin
    Result := false;
    fillchar(startupInfo, sizeof(startupInfo), 0);
    startupInfo.cb := sizeof(startupInfo);
    if (CreateProcess(nil,
      pchar(cmdLine),
      nil,
      nil,
      false,
      NORMAL_PRIORITY_CLASS,
      nil,
      nil,
      startupInfo,
      processInfo)) then
    begin
      while (WaitForSingleObject(ProcessInfo.hProcess, 0) = WAIT_TIMEOUT) do
        Application.ProcessMessages;
      ProcessInfo.hProcess := 0;
      CloseHandle(processInfo.hProcess);
      Result := true;

    end
    else
    begin
      errorMsg := 'Create Process Error:' + #13#10 + cmdLine + #13#10#13#10 + SysErrorMessage(GetLastError);
      Writeln(errorMsg);
    end;
  end;

  function GetFirebirdServer: TFirebirdServer;
  var
    dbServer: TDbServer;
  begin
    dbServer := dmBackup.GetDbServer;
    Result := TFirebirdServer.Instance(dbServer.SrvName, dbServer.userName, dbServer.password, dbServer.Protocol, dbServer.ClientLib);
    Result.OnFbTextNotify := ServerLog;
  end;
var
  DataBaseFileName, BackupFileName, parameter: string;
begin
  result := '';

  Writeln('Backup'); // Label1.Caption := 'Backup';
  DataBaseFileName := dmBackup.DataBaseName;
  BackupFileName := GetBackupFileName(DataBaseFileName);

  if dmBackup.DataBaseGbakPath <> '' then
  begin
    // Baclup tramite gbak
    Writeln(dmBackup.DataBaseGbakPath + '\gbak.exe -v -t -user ' + dmBackup.DataBaseUser + ' -password "**************"  ' + dmBackup.DataBaseNameComplete + ' ' + BackupFileName);

    parameter := '-v -t -user ' + dmBackup.DataBaseUser + ' -password "' + dmBackup.DataBasePws + '"  ' + dmBackup.DataBaseNameComplete + ' ' + BackupFileName;

   // ProgExecute('cmd '+dmBackup.DataBaseGbakPath + '\gbak.exe ' + parameter, true);

    ShellExecute(Application.Handle, 'open', 'gbak.exe', PChar(parameter), PChar(dmBackup.DataBaseGbakPath), SW_SHOW);
    //     repeat
     //      Application.ProcessMessages;
    //       GetExitCodeProcess(Application.Handle, ExitCode) ;
     //    until (ExitCode <> STILL_ACTIVE) or

  end
  else
  begin

    //  Backup tramite FIB
    try
      if GetFirebirdServer.BackupDB(DataBaseFileName, BackupFileName) then
        Result := BackupFileName;
    finally
    end;
  end;
end;

function TBackup.doCompress(BackupFileName: string): Boolean;
var
  Stream: TMemoryStream;
  FileStream: TFileStream;
  ZipFileName: string;
begin
  result := false;
  Writeln('Compressione'); //   Label1.Caption := 'Compressione';

  //pnlBackup.Visible := True;
  try

    // BackupFileName := GetBackupFileName(dmBackup.DataBaseName);
    ZipFileName := ChangeFileExt(BackupFileName, '.zip');

    if FileExists(ZipFileName) then
      DeleteFile(ZipFileName);

    AbZipper.AutoSave := True;
    AbZipper.DeflationOption := doNormal;
    AbZipper.DOSMode := False;
    AbZipper.ArchiveType := atZip;
    AbZipper.StoreOptions := [];
    AbZipper.FileName := ZipFileName;

    Stream := TMemoryStream.Create;
    try
      LogBackup.SaveToStream(Stream);
      AbZipper.AddFromStream(ChangeFileExt(ExtractFileName(BackupFileName), '.log'), Stream);
    finally
      FreeAndNil(Stream);
    end;
    //
    FileStream := TFileStream.Create(BackupFileName, fmOpenRead);
    try
      AbZipper.AddFromStream(ExtractFileName(BackupFileName), FileStream);
    finally
      FreeAndNil(FileStream);
    end;

    AbZipper.CloseArchive;
    AbZipper.FileName := '';
    //    ProgressBar1.Position := 100;
    //    ProgressBar2.Position := 100;
    //    ProgressBar3.Position := 100;
  finally
    //    pnlBackup.Visible := False;
  end;
  result := true;
end;

procedure TBackup.doCopieLocali(BackupFileName: string);
var
  DestFolders, CopieDaMantenere, FilePresenti: TStringList;
  MySearchRec: TSearchRec;
  i, j, numFileCopieDaMantenere: Integer;
  DestFolder: string;
  ZipFileName: string;
  DestFileName: string;
begin
  Writeln('Copie Locali'); //   Label1.Caption := 'Copie Locali';

  DestFolders := TStringList.Create;
  CopieDaMantenere := TStringList.Create;
  FilePresenti := TStringList.Create;
  try

    dmBackup.GetDestFolders(DestFolders, CopieDaMantenere);
    for i := 0 to DestFolders.Count - 1 do
    begin
      //  BackupFileName := GetBackupFileName(dmBackup.DataBaseName);
      ZipFileName := ChangeFileExt(BackupFileName, '.zip');

      DestFolder := CalcPath(DestFolders[i]);
      DestFileName := DestFolder + ExtractFileName(ZipFileName);

      Writeln('Copia di ' + ZipFileName + ' in ' + DestFileName); // Memo1.lines.Add('Copia di ' + ZipFileName + ' in ' + DestFileName);
      Writeln(''); // Memo1.lines.Add('');

      if FileExists(DestFileName) then
      begin
        Writeln('Eliminato il file ' + DestFileName); // Memo1.lines.Add('Eliminato il file ' + DestFileName);
        DeleteFile(DestFileName);
      end;

      if Win95Copy(Application.Handle, ZipFileName, DestFileName) then
        Writeln('Copia eseguita.') // Memo1.lines.Add('Copia eseguita.')
      else
        Writeln('COPIA NON RIUSCITA'); // Memo1.lines.Add('COPIA NON RIUSCITA');

      // Controllo se devo cancellare qualche file nella cartella
      if CopieDaMantenere[i] <> '-1' then
      begin
        numFileCopieDaMantenere := StrToInt(CopieDaMantenere[i]);

        FilePresenti.Clear;
        FilePresenti.Sorted := true;

        if FindFirst(DestFolder + '*.zip', faAnyFile, MySearchRec) = 0 then
        begin
          begin
            repeat
              FilePresenti.Append(MySearchRec.Name);
            until FindNext(MySearchRec) <> 0;

            // Corntrollo se devo cancellare qualche file
            if FilePresenti.Count > numFileCopieDaMantenere then
            begin
              for j := 0 to (FilePresenti.Count - numFileCopieDaMantenere) - 1 do
                Win95Erase(Application.Handle, DestFolder + FilePresenti[j], false);

            end;

          end;
        end;

      end;
    end;
  finally
    FreeAndNil(DestFolders);
    FreeAndNil(FilePresenti);
    FreeAndNil(CopieDaMantenere);
  end;
end;

procedure TBackup.doCopieFTP(BackupFileName: string);
var
  CopieFTP: TCopieFTP;
  item: TCopiaFTP;
  i: Integer;
  FtpConnection: TFtpConnection;
  ZipFileName: string;
  DestFileName: string;
begin
  //Label1.Caption := 'Copie FTP';

//  BackupFileName := GetBackupFileName(dmBackup.DataBaseName);
  ZipFileName := ChangeFileExt(BackupFileName, '.zip');
  DestFileName := ExtractFileName(zipFileName);

  //  progBackup.Animate := True;
  try
    CopieFTP := TCopieFTP.Create(TCopiaFTP, '', -1, nil);
    try
      dmBackup.GetCopieFTP(CopieFTP);

      for i := 0 to CopieFTP.Count - 1 do
      begin
        item := CopieFTP[i];

        FtpConnection := TFtpConnection.Create(item.host, item.UserName, item.Password, item.Porta);
        try
          FtpConnection.OnStatus := FTPLog;
          if not FtpConnection.Connect(item.Passivo) then
            ShowMessage('FTP non connesso');

          FtpConnection.Directory := item.CartellaFTP;

          if FtpConnection.GetFileSize(DestFileName) <> 0 then
            FtpConnection.DeleteFile(DestFileName);

          FtpConnection.Upload(ZipFileName, DestFileName);
        finally
          FreeAndNil(FtpConnection)
        end;
      end;
    finally
      FreeAndNil(CopieFTP);
    end;
  finally
    //progBackup.Animate := False;
    //progBackup.Position := 99;
  end;
end;

procedure TBackup.Timer1Timer(Sender: TObject);
begin
  //Timer1.Enabled := False;
  doJobs;
end;

end.

