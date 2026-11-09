unit zBaseRegister;

interface

procedure Register;

implementation

uses
  Classes,
  DesignIntf,
  System.Actions,
  Frame_Collection,
  Frame_Editor_SQL,
  Frame_Editor_JSON,
  Frame_MetaData,
  Frame_ObjectInspector,
  SQLParser,
  zDbCard,
  zDbView,
  zDbViewDlg,
  zDbPivot,
  zDbRecordView,
  zDbTree,
  zDbChart,
  zDbScheduler,
  zDbImage,
  zSideBar,
  zSystem,
  Frame_TreeView,
  Frame_TreeList,
  zFileViewer,
  zOffice.MultiViewer,
  // zCube,
  // zTatukViewer,
  zDbCardDlg,
  zNavBarTools,
  zTeeToolbar,
  // zGoogleMaps,
  zMap,
  dxFileActions,
  zFocusedAction,
  TeeCumu, // curva cumulativa
  zz.base.editor.DataSet,
  zz.base.editor.DbCard,
  zz.base.editor.DbView,
  zz.base.editor.Lookup,
  zOffice.SynEdit.Frame;

procedure Register;
begin
  // RegisterComponents('zBase', [TzSideBar]);
  // RegisterComponents('zBase', [TzPageControl]);
  // RegisterComponents('zBase', [TzTreeList]);

  RegisterComponents('zBase', [TSQLParser]);
  // RegisterComponents('zBase', [TFrameEditor_Pas]);
  RegisterComponents('zBase', [TFrameCollection]);
  RegisterComponents('zBase', [TFrameEditor_SQL]);
  RegisterComponents('zBase', [TFrameEditor_JSON]);
  RegisterComponents('zBase', [TFrameMetadata]);
  RegisterComponents('zBase', [TFrameObjectInspector]);
  RegisterComponents('zBase', [TzFrameEditor_DataSet]);
  RegisterComponents('zBase', [TzFrameEditor_DbCard]);
  RegisterComponents('zBase', [TzFrameEditor_DbView]);
  RegisterComponents('zBase', [TzFrameEditor_Lookup]);

  RegisterComponents('zBase', [TzSystem]);
  RegisterComponents('zBase', [TzDbCard]);
  RegisterComponents('zBase', [TzDbView]);
  RegisterComponents('zBase', [TzDbViewDlg]);
  RegisterComponents('zBase', [TzDbCardDlg]);
  RegisterComponents('zBase', [TzDbPivot]);
  RegisterComponents('zBase', [TzDbRecordView]);
  RegisterComponents('zBase', [TzDbTree]);
  RegisterComponents('zBase', [TzDbChart]);
  RegisterComponents('zBase', [TzDbScheduler]);
  // RegisterComponents('zBase', [TzDBComboDlg, TzDBComboBox, TzDBRadioGroup, TzDBImageComboBox, TzDbSpinEdit]);
  // RegisterComponents('zBase', [TzDBComboDlg, TzDBImageComboBox]);
  RegisterComponents('zBase', [TzDbImage]);
  // RegisterComponents('zBase', [TzFrameFiltro]);

  // RegisterComponents('zBase', [TzTatukViewer]);
  RegisterComponents('zBase', [TFrameTreeView]);
  RegisterComponents('zBase', [TFrameTreeList]);
  // RegisterComponents('zBase', [TzCube]);

  RegisterComponents('zBase', [TzNavBarTools]);
  RegisterComponents('zBase', [TzFileViewer]);
  RegisterComponents('zBase', [TzMultiViewer]);
  RegisterComponents('zBase', [TzTeeChartToolbar]);
  // RegisterComponents('zBase', [TzGoogleMaps]);
  RegisterComponents('zBase', [TzMap]);

  RegisterActions('dxFile', [TdxFileOpen, TdxFileSaveAs, TdxOpenPicture, TdxSavePicture], nil);

  // Azioni dei frame zDbView e zDbPivot: senza, l'editor delle ActionList non
  // propone la classe e non la sa creare.
  RegisterActions('zBase', [TzFocusedAction], nil);
end;

end.
