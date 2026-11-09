unit zCommon_Register;

interface

uses
  System.Classes,
  System.Actions,
  dbMaster,
  dbMasterCompEd,
  ExplorerDrop,
  zProgressBox,
  OkCancel,
  dxFileActions;

procedure Register;

implementation

uses
  DesignEditors,
  DesignIntf;

procedure Register;
begin
  RegisterComponents('zCommon', [TProgressBox]);
  RegisterComponents('zCommon', [TExplorerDrop]);
  RegisterComponents('zCommon', [TOkCancel]);
  RegisterComponents('zCommon', [TdbMaster]);

  RegisterActions('dxFile', [TdxFileOpen, TdxFileSaveAs, TdxOpenPicture, TdxSavePicture], nil);

  RegisterComponentEditor(TdbMaster, TdbMasterEditor);
end;

end.
