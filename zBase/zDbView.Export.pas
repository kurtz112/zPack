unit zDbView.Export;

interface

uses
  Winapi.Windows,
  system.SysUtils,
  system.Classes,
  Vcl.Dialogs,

  zSystem,
  zDbView,
  dxShellDialogs,
  cxExport,
  cxGridExportLink;

type
  TViewExportType = (vetExcel2007Data, vetExcel2007Full, vetExcel97Data, vetExcel97Full, vetCSV);

procedure InitExcelExportDialog(SaveDialog: TdxSaveFileDialog);

// procedure ExportView2Excel(view: TzDbView; SaveDialog: TdxSaveFileDialog); overload;

procedure ExportView2Excel(view: TzDbView); overload;

procedure ExportView(view: TzDbView);

procedure ExportViewExcel2007Data(view: TzDbView; const FileName: string);
procedure ExportViewExcel2007Full(view: TzDbView; const FileName: string);
procedure ExportViewExcel97Data(view: TzDbView; const FileName: string);
procedure ExportViewExcel97Full(view: TzDbView; const FileName: string);
procedure ExportViewCSV(view: TzDbView; const FileName: string);

implementation

uses
  System.UITypes, System.IOUtils, Vcl.Forms, Winapi.ShellAPI, zBaseLib,
  zProgressBox, QExport4, QExport4ASCII, QExport4XLS, QExport4Xlsx,
  QExport4Dialog, fuQExport4Progress, QExport4Types, SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto, zMsg;

type
  TdxExportHandler = class(TComponent, IcxExportProgress)
  private
    // IcxExportProgress
    procedure OnProgress(Sender: TObject; Percent: Integer);
  public
    ProgressBox: TProgressBox;
    constructor Create(const FileName: string; ExportType: TViewExportType);
    destructor Destroy; override;
  end;

  TQExportHandler = class
  private
    QExport: TQExport4;
    ProgressForm: TfmQExport4Progress;
    procedure OnBeginExport(Sender: TObject);
    procedure OnEndExport(Sender: TObject);
    procedure OnExportedRecord(Sender: TObject; RecNo: Integer);
    procedure OnSkippedRecord(Sender: TObject; RecNo: Integer);
    procedure OnGetExportText(Sender: TObject; ColNo: Integer; var Text: QEString);
    procedure OnStopExport(Sender: TObject; var CanContinue: Boolean);
  public
    procedure Execute(AQExport: TQExport4);
  end;

  // AQExport: TQExport4

constructor TdxExportHandler.Create(const FileName: string; ExportType: TViewExportType);
var
  s: String;
begin
  inherited Create(nil);

  case ExportType of
    vetExcel97Data:
      s := 'Microsoft Excel formato XLSX (solo dati)';
    vetExcel97Full:
      s := 'Microsoft Excel formato XLS (solo dati)';
    vetExcel2007Data:
      s := 'Microsoft Excel formato XLSX (completo)';
    vetExcel2007Full:
      s := 'Microsoft Excel formato XLS (completo)';
    vetCSV:
      s := 'Testo formato CSV';
  end;

  ProgressBox := TProgressBox.Create(self);
  ProgressBox.Show(100, s, s, ExtractFileName(FileName));
end;

destructor TdxExportHandler.Destroy;
begin
  ProgressBox.Close;
  inherited;
end;

procedure TdxExportHandler.OnProgress(Sender: TObject; Percent: Integer);
begin
  if ProgressBox.Cancelled then
    Abort
  else
  begin
    ProgressBox.Progress := Percent;
    Application.ProcessMessages;
  end;
end;

procedure InitExcelExportDialog(SaveDialog: TdxSaveFileDialog);
  procedure AddFileType(FileMask, DisplayName: string);
  var
    // item: TFileTypeItem;
    s: String;
  begin
    s := DisplayName + '|' + FileMask;

    if SaveDialog.Filter.isEmpty then
      SaveDialog.Filter := s
    else
      SaveDialog.Filter := SaveDialog.Filter + '|' + s;
    // item := SaveDialog.FileTypes.Add;
    // item.DisplayName := DisplayName;
    // item.FileMask := FileMask;
  end;

begin
  Assert(Assigned(SaveDialog));

  if SaveDialog.InitialDir.isEmpty then
    SaveDialog.InitialDir := Base.PersonalFolder;

  SaveDialog.Options := SaveDialog.Options + [ofOverwritePrompt, ofPathMustExist, ofNoReadOnlyReturn];

  AddFileType('*.xlsx', 'Microsoft Excel formato XLSX (solo dati)');
  AddFileType('*.xlsx', 'Microsoft Excel formato XLSX (completo)');
  AddFileType('*.xls', 'Microsoft Excel formato XLS (completo)');
  AddFileType('*.xls', 'Microsoft Excel formato XLS (solo dati)');
  AddFileType('*.csv', 'Testo formato CSV');

  SaveDialog.FilterIndex := 0;
  SaveDialog.DefaultExt := '*.xlsx';
end;

procedure oldExportView2Excel(view: TzDbView; SaveDialog: TdxSaveFileDialog);
var
  tmpFileName: string;
  ExportHandler: TdxExportHandler;
  ExportType: TViewExportType;
  FileName: string;
begin
  Assert(Assigned(view));

  FileName := SaveDialog.FileName;
  ExportType := TViewExportType(SaveDialog.FilterIndex - 1);

  if FileName = '' then
    Exit;

  ExportHandler := TdxExportHandler.Create(FileName, ExportType);
  try
    Application.ProcessMessages;

    tmpFileName := system.IOUtils.TPath.GetTempFileName;
    try
      siMain.LogString('FileName', FileName);
      siMain.LogString('TempFileName', tmpFileName);
      // filte temporaneo, per via di terminal server

      case ExportType of
        vetExcel97Full:
          ExportGridToExcel(tmpFileName, view.cxGrid, true, true, true, 'tmp', ExportHandler);
        vetExcel97Data:
          ExportGridDataToExcel(tmpFileName, view.cxGrid, true, true, true, 'tmp', ExportHandler);
        vetExcel2007Full:
          ExportGridToXLSX(tmpFileName, view.cxGrid, true, true, true, 'tmp', ExportHandler);
        vetExcel2007Data:
          ExportGridDataToXLSX(tmpFileName, view.cxGrid, true, true, true, 'tmp', ExportHandler);
        vetCSV:
          ExportGridDataToCSV(tmpFileName, view.cxGrid, true, true, ';', 'tmp', ExportHandler);
      end;

      siMain.LogVerbose('File esportato');

      if system.IOUtils.TFile.Exists(FileName) then
        system.IOUtils.TFile.Delete(FileName);
      system.IOUtils.TFile.Copy(tmpFileName, FileName);

      siMain.LogVerbose('File copiato');
    finally
      system.IOUtils.TFile.Delete(tmpFileName);
      siMain.LogVerbose('File temp eliminato');
    end;
  finally
    FreeAndNil(ExportHandler);
  end;

  if ConfirmYesNo('Si desidera aprire il file esportato?') then
    ShellExecute(0, Pchar('open'), Pchar(FileName), nil, nil, SW_RESTORE)
  else
    ShellExecute(0, Pchar('open'), Pchar(ExtractFilePath(FileName)), nil, nil, SW_RESTORE);
end;

procedure ExportView2Excel(view: TzDbView);
var
  FileSaveDialog: TdxSaveFileDialog;
  FileName: string;
  tmpFileName: string;
  ExportType: TViewExportType;
begin
  FileSaveDialog := TdxSaveFileDialog.Create(view);
  try
    InitExcelExportDialog(FileSaveDialog);

    if not FileSaveDialog.Execute then
      Exit;

    FileName := FileSaveDialog.FileName;

    tmpFileName := system.IOUtils.TPath.GetTempFileName;
    try
      siMain.LogString('FileName', FileName);
      siMain.LogString('TempFileName', tmpFileName);
      // filte temporaneo, per via di terminal server

      ExportType := TViewExportType(FileSaveDialog.FilterIndex - 1);

      //
      case ExportType of
        vetExcel97Full:
          ExportViewExcel97Full(view, tmpFileName);
        vetExcel97Data:
          ExportViewExcel97Data(view, tmpFileName);
        vetExcel2007Full:
          ExportViewExcel2007Full(view, tmpFileName);
        vetExcel2007Data:
          ExportViewExcel2007Data(view, tmpFileName);
        vetCSV:
          ExportViewCSV(view, tmpFileName);
      end;

      siMain.LogVerbose('File esportato');

      if system.IOUtils.TFile.Exists(FileName) then
        system.IOUtils.TFile.Delete(FileName);
      system.IOUtils.TFile.Copy(tmpFileName, FileName);

      siMain.LogVerbose('File copiato');
    finally
      system.IOUtils.TFile.Delete(tmpFileName);
      siMain.LogVerbose('File temp eliminato');
    end;
  finally
    FreeAndNil(FileSaveDialog);
  end;

  if ConfirmYesNo('Si desidera aprire il file generato?') then
    ShellExecute(0, 'open', Pchar(FileName), '', '', SW_SHOWNORMAL);
end;

procedure GetExportedFields(view: TzDbView; Fields, Captions: TStrings);
var
  i: Integer;
begin
  Fields.Clear;
  Captions.Clear;

  for i := 0 to view.cxGridDBTableView.ColumnCount - 1 do
    if view.cxGridDBTableView.Columns[i].Visible then
    begin
      Fields.Add(view.cxGridDBTableView.Columns[i].DataBinding.FieldName);
      Captions.Add(view.cxGridDBTableView.Columns[i].Caption);
    end;
end;

procedure InitFormats(Formats: TQExportFormats);
begin
  Formats.TimeFormat := 'hh:mm';
end;

procedure ExportView(view: TzDbView);

  procedure SetUnidirectional(const UniDirectional: Boolean);
  begin
    view.zDataSet.Active := False;
    view.zDataSet.FetchOptions.UniDirectional := UniDirectional;

    if UniDirectional then
      view.zDataSet.DisableControls
    else
      view.zDataSet.EnableControls;

    view.zDataSet.Active := true;
  end;

var
  QExport4Dialog: TQExport4Dialog;
begin
  SetUnidirectional(true);
  try
    QExport4Dialog := TQExport4Dialog.Create(view);
    try
      QExport4Dialog.FileName := '';
      QExport4Dialog.DataSet := view.zDataSet;
      GetExportedFields(view, QExport4Dialog.ExportedFields, QExport4Dialog.Captions);
      InitFormats(QExport4Dialog.Formats);
      QExport4Dialog.Execute;
    finally
      FreeAndNil(QExport4Dialog);
    end;
  finally
    SetUnidirectional(False);
  end;
end;

procedure ExportGridData(ExportType: TViewExportType; view: TzDbView; const FileName: string);
var
  ExportHandler: TdxExportHandler;
  wasGridMode: Boolean;
  wasFiltered: Boolean;
begin
  wasGridMode := view.cxGridDBTableView.DataController.DataModeController.GridMode;
  wasFiltered := view.cxGridDBTableView.DataController.Filter.Active;

  StartWait('Attendere...', true);
  try
    view.cxGridDBTableView.DataController.Filter.OnChanged := nil;
    view.cxGridDBTableView.DataController.DataModeController.GridMode := False;

    if wasGridMode then
      view.cxGridDBTableView.DataController.Filter.Active := False;
  finally
    StopWait;
  end;

  ExportHandler := TdxExportHandler.Create(FileName, ExportType);
  try
    case ExportType of
      vetExcel2007Full:
        ExportGridToXLSX(FileName, view.cxGrid, true, true, true, 'tmp', ExportHandler);
      vetExcel97Full:
        ExportGridToExcel(FileName, view.cxGrid, true, true, true, 'tmp', ExportHandler);
    end;

  finally
    FreeAndNil(ExportHandler);
  end;

  StartWait('Attendere...', true);
  try
    view.cxGridDBTableView.DataController.Filter.OnChanged := view.cxGridDBTableViewDataControllerFilterChanged;
    view.cxGridDBTableView.DataController.DataModeController.GridMode := wasGridMode;
    view.cxGridDBTableView.DataController.Filter.Active := wasFiltered;
  finally
    StopWait;
  end;
end;

procedure doExport(AQExport: TQExport4);
var
  QExportHandler: TQExportHandler;
begin
  QExportHandler := TQExportHandler.Create;
  try
    QExportHandler.Execute(AQExport);
  finally
    FreeAndNil(QExportHandler);
  end;
end;

procedure ExportViewExcel2007Full(view: TzDbView; const FileName: string);
begin
  ExportGridData(vetExcel2007Full, view, FileName);
end;

procedure ExportViewExcel97Full(view: TzDbView; const FileName: string);
begin
  ExportGridData(vetExcel97Full, view, FileName);
end;

procedure ExportViewExcel2007Data(view: TzDbView; const FileName: string);
var
  QExport4Xlsx: TQExport4Xlsx;
begin
  QExport4Xlsx := TQExport4Xlsx.Create(view);
  try
    QExport4Xlsx.FileName := FileName;
    QExport4Xlsx.DataSet := view.zDataSet;
    QExport4Xlsx.AutoTruncateValue := true; // Mail Paolo 14.06.2025

    GetExportedFields(view, QExport4Xlsx.ExportedFields, QExport4Xlsx.Captions);
    InitFormats(QExport4Xlsx.Formats);
    doExport(QExport4Xlsx);
  finally
    FreeAndNil(QExport4Xlsx);
  end;
end;

procedure ExportViewExcel97Data(view: TzDbView; const FileName: string);
var
  QExport4XLS: TQExport4XLS;
begin
  QExport4XLS := TQExport4XLS.Create(view);
  try
    QExport4XLS.FileName := FileName;
    QExport4XLS.DataSet := view.zDataSet;
    QExport4XLS.AutoTruncateValue := true; // Mail Paolo 14.06.2025

    GetExportedFields(view, QExport4XLS.ExportedFields, QExport4XLS.Captions);
    InitFormats(QExport4XLS.Formats);
    doExport(QExport4XLS);
  finally
    FreeAndNil(QExport4XLS);
  end;
end;

procedure ExportViewCSV(view: TzDbView; const FileName: string);
var
  QExport4ASCII: TQExport4ASCII;
begin
  QExport4ASCII := TQExport4ASCII.Create(view);
  try
    QExport4ASCII.FileName := FileName;
    QExport4ASCII.DataSet := view.zDataSet;

    GetExportedFields(view, QExport4ASCII.ExportedFields, QExport4ASCII.Captions);
    InitFormats(QExport4ASCII.Formats);

    QExport4ASCII.ExportType := etCSV;

    doExport(QExport4ASCII);
  finally
    FreeAndNil(QExport4ASCII);
  end;
end;

{ TQExportHandler }

procedure TQExportHandler.Execute(AQExport: TQExport4);
begin
  QExport := AQExport;
  QExport.OnBeginExport := OnBeginExport;
  QExport.OnEndExport := OnEndExport;
  QExport.OnSkippedRecord := OnSkippedRecord;
  QExport.OnExportedRecord := OnExportedRecord;
  QExport.OnStopExport := OnStopExport;
  QExport.OnGetExportText := OnGetExportText;

  ProgressForm := TfmQExport4Progress.CreateProgress(nil, QExport);
  try
    ProgressForm.Show;
    QExport.Execute;

    // if ShowFile then
    // begin
    // if not AQExport.Aborted and Assigned(Progress) then
    // begin
    // PostMessage(Progress.Handle, WM_QEXPORT_PROGRESS, QEP_DONE, 0);
    // Application.ProcessMessages;
    // end;
    // end
    // else
    while ProgressForm.ModalResult <> mrOk do
    begin
      Sleep(0);
      Application.ProcessMessages;
    end;
  finally
    FreeAndNil(ProgressForm);
  end;

  QExport.OnBeginExport := nil;
  QExport.OnEndExport := nil;
  QExport.OnSkippedRecord := nil;
  QExport.OnExportedRecord := nil;
  QExport.OnStopExport := nil;
  QExport.OnGetExportText := nil;
  QExport.OnBeforeExportRow := nil;
end;

procedure TQExportHandler.OnBeginExport(Sender: TObject);
begin
  if Assigned(ProgressForm) then
  begin
    PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_START, 0);
    Application.ProcessMessages;
  end;
end;

procedure TQExportHandler.OnEndExport(Sender: TObject);
begin
  if Assigned(ProgressForm) then
  begin
    if not QExport.Aborted then
      PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_FINISH, 0);
    Application.ProcessMessages;
  end;
end;

procedure TQExportHandler.OnExportedRecord(Sender: TObject; RecNo: Integer);
begin
  if Assigned(ProgressForm) then
  begin
    PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_EXPORTED, 0);
    Application.ProcessMessages;
  end;
end;

procedure TQExportHandler.OnGetExportText(Sender: TObject; ColNo: Integer; var Text: QEString);
begin
end;

procedure TQExportHandler.OnSkippedRecord(Sender: TObject; RecNo: Integer);
begin
  if Assigned(ProgressForm) then
  begin
    PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_SKIPPED, 0);
    Application.ProcessMessages;
  end;
end;

procedure TQExportHandler.OnStopExport(Sender: TObject; var CanContinue: Boolean);
begin
  if Assigned(ProgressForm) then
  begin
    PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_PAUSE, 0);
    Application.ProcessMessages;
  end;

  CanContinue := not ConfirmYesNo('Si desidera annullare l''esportazione?');

  if Assigned(ProgressForm) then
  begin
    if CanContinue then
      PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_CONTINUE, 0)
    else
      PostMessage(ProgressForm.Handle, WM_QEXPORT_PROGRESS, QEP_ABORT, 0);
    Application.ProcessMessages;
  end;
end;

end.

  dxfileactions
