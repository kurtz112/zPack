unit zz.base.editor.DataSet;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  System.Actions,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  ActnList,
  ImgList,
  ComCtrls,
  StdCtrls,
  ToolWin,
  Frame_Editor_SQL,
  zFbDataSet,
  zSystem,
  Frame_Collection,
  Frame_ObjectInspector,
  DB,
  Mask,
  acQBBase,
  acSQLBuilderPlainText,
  acAST,
  acFbSynProvider,
  acQBLocalizer,
  Menus,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxStyles,
  cxEdit,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  cxImageComboBox,
  dxBar,
  cxBarEditItem,
  cxClasses,
  cxCheckBox,
  cxCheckComboBox,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  cxSplitter,
  cxPC,
  dxBarBuiltInMenu,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  zz.base.editor._frame,
  zProgressBox,
  SmartInspect.VCL.SiAuto,
  SmartInspect.VCL;

type
  TzFrameEditor_DataSet = class(TzFrameEditorCollectionItem)
    pageDataSet: TcxPageControl;
    tsInsert: TcxTabSheet;
    tsUpdate: TcxTabSheet;
    tsDelete: TcxTabSheet;
    Splitter2: TcxSplitter;
    Splitter3: TcxSplitter;
    seInsert: TFrameEditor_SQL;
    seUpdate: TFrameEditor_SQL;
    seDelete: TFrameEditor_SQL;
    UpdateFieldsTL: TListView;
    InsertFieldsTL: TListView;
    ActionList1: TActionList;
    CopiaDalDataset: TAction;
    ApplicaAlDataSet: TAction;
    CreaDaNomeTabella: TAction;
    tabSelect: TcxTabSheet;
    tabQueryBuilder: TcxTabSheet;
    tabIUD: TcxTabSheet;
    pageRIUD: TcxPageControl;
    tabInspector: TcxTabSheet;
    FrameObjectInspector1: TFrameObjectInspector;
    images1: TImageList;
    InternalDataSet: TzFbDataSet;
    PrepareDataSet: TzFbDataSet;
    pnlSelect: TPanel;
    seSelect: TFrameEditor_SQL;
    AggiornaRefresh: TAction;
    EliminaSQL: TAction;
    imgCombo: TImageList;
    RicreaSelect: TAction;
    tsRefresh: TcxTabSheet;
    seRefresh: TFrameEditor_SQL;
    AggiungiFK: TAction;
    Cache: TAction;
    imgObjects32: TImageList;
    acFirebirdSyntaxProvider: TacFirebirdSyntaxProvider;
    acSQLBuilderPlainText: TacSQLBuilderPlainText;
    ImageList1: TImageList;
    acQueryBuilder: TacQueryBuilder;
    dxBarManager: TdxBarManager;
    dxBarManagerBar1: TdxBar;
    cxBarEditItemRelations: TcxBarEditItem;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    cxBarEditItemGenerator: TcxBarEditItem;
    dxBarButton3: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarManagerBar2: TdxBar;
    dxBarDockControlRIUD: TdxBarDockControl;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    cbAutoRefresh: TcxBarEditItem;
    cbAutoInsert: TcxBarEditItem;
    cxBarEditItem3: TcxBarEditItem;
    cbAutoUpdate: TcxBarEditItem;
    cbAutoDelete: TcxBarEditItem;
    GetNomeTabellaDaSql: TAction;
    dxBarButton6: TdxBarButton;
    imgObjects16: TImageList;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    CercaGeneratore: TAction;
    EditaGeneratore: TAction;
    ProgressBox: TProgressBox;
    procedure UpdateFieldsTLClick(Sender: TObject);
    procedure InsertFieldsTLClick(Sender: TObject);
    procedure CreaDaNomeTabellaExecute(Sender: TObject);
    procedure seSelectExit(Sender: TObject);
    procedure seSelectChange(Sender: TObject);
    procedure AggiornaRefreshExecute(Sender: TObject);
    procedure pageDataSetChange(Sender: TObject);
    procedure EliminaSQLExecute(Sender: TObject);
    procedure cbAutoInsertClick(Sender: TObject);
    procedure cbAutoUpdateClick(Sender: TObject);
    procedure cbAutoDeleteClick(Sender: TObject);
    procedure RicreaSelectExecute(Sender: TObject);
    procedure cbAutoRefreshClick(Sender: TObject);
    procedure RicreaSelectUpdate(Sender: TObject);
    procedure AggiungiFKUpdate(Sender: TObject);
    procedure CacheExecute(Sender: TObject);
    procedure acQueryBuilderValidatePopupMenu(Sender: TacQueryBuilder; AControlOwner: TacQueryBuilderControlOwner; AForControl: TControl; APopupMenu: TPopupMenu);
    procedure tabQueryBuilderEnter(Sender: TObject);
    procedure tabQueryBuilderHide(Sender: TObject);
    procedure cxRTTIInspector1ItemChanged(Sender: TObject; AOldRow: TcxCustomRow; AOldCellIndex: Integer);
    procedure cxRTTIInspector1EditValueChanged(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties);
    procedure acQueryBuilderAfterCreateControls(Sender: TObject);
    procedure CercaGeneratoreExecute(Sender: TObject);
    procedure cxBarEditItemRelationsPropertiesEditValueChanged(Sender: TObject);
    procedure cxBarEditItemGeneratorPropertiesEditValueChanged(Sender: TObject);
    procedure cxBarEditItemRelationsCurChange(Sender: TObject);
    procedure EditaGeneratoreExecute(Sender: TObject);
    procedure GetNomeTabellaDaSqlExecute(Sender: TObject);
    procedure pageDataSetPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure seSelectFormatSQL(Sender: TObject);
    procedure tabQueryBuilderShow(Sender: TObject);
  private
    //
    procedure InitImageComboProps(Combo: TcxBarEditItem);
    procedure SetItemChecked(Item: TcxBarEditItem; Value: Boolean);
    function GetItemChecked(Item: TcxBarEditItem): Boolean;
    //
    function TableNameAssigned: Boolean;
    procedure Prepare_TL_Fields;
    procedure Build_SelectSQL;

    procedure Build_SQL_Insert;
    procedure Build_SQL_Update;
    procedure Build_SQL_Delete;
    procedure Build_SQL_Refresh;
    procedure InitCombo;
    procedure Fill_Items_Generators;
    procedure Fill_Items_TableNames;
  private
    MasterQry: TacDatasource;
    Locked: Boolean;
    zDataSet: TzDataSet;
    procedure Internal_InitEditor;
    procedure Internal_PostEditor;
    procedure Internal_ApplyFromDataSet;
    procedure Internal_InitDataSet;
    procedure BuildSUID(aTableName: string);
    procedure FillQueryBuilderMetadata;
    procedure CheckQueryBuilderMetadata;
    procedure PrepareSQL(Sender: TObject);
    procedure RelationsMenuClick(Sender: TObject);
    procedure doPrepare(const SQL: string);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure Init; override;
    function CanClose(ModalResult: TModalResult): Boolean; override;
    procedure Apply; override;
    function GetEditorCaption: string; override;
  end;

implementation

uses
  zSqlLib,
  zSql.SqlTxtRtns,
  zMetadata,
  zBaseLib,
  zFrmInspector;
{$R *.dfm}
{ TFrameSUID }

constructor TzFrameEditor_DataSet.Create(aOwner: TComponent);
var
  i: Integer;
begin
  inherited;
  zDataSet := TzDataSet.Create(nil);

  seSelect.OnPrepare := PrepareSQL;
  seInsert.OnPrepare := PrepareSQL;
  seUpdate.OnPrepare := PrepareSQL;
  seDelete.OnPrepare := PrepareSQL;
  seRefresh.OnPrepare := PrepareSQL;

  // per le procedure va in palla con DB_KEY
  InsertFieldsTL.OnClick := InsertFieldsTLClick;
  UpdateFieldsTL.OnClick := UpdateFieldsTLClick;

  Locked := True;
  try
    pageDataSet.ActivePage := tabSelect;
    pageRIUD.ActivePage := tsRefresh;
  finally
    Locked := False;
  end;

  for i := 0 to acQBLanguageManager.LanguagesCount - 1 do
    if sametext('italian', acQBLanguageManager.Language[i].LanguageName) then
    begin
      acQBLanguageManager.CurrentLanguageIndex := i;
      break;
    end;
  //
end;

procedure TzFrameEditor_DataSet.cxRTTIInspector1ItemChanged(Sender: TObject; AOldRow: TcxCustomRow; AOldCellIndex: Integer);
begin
  inherited;

end;

/// /////////////////////////////////////////////////////////////////////////
/// //// Build_SQL

procedure TzFrameEditor_DataSet.Build_SQL_Insert;
var
  i: Integer;
  Str: TStringList;
  FieldName: string;
begin
  Str := TStringList.Create;
  try
    Str.Clear;
    for i := 0 to InsertFieldsTL.Items.Count - 1 do
    begin
      if InsertFieldsTL.Items[i].Checked then
      begin
        FieldName := InsertFieldsTL.Items[i].Caption;
        Str.Add(FieldName);
      end;
    end;

    seInsert.SQL := zSqlLib.Build_SQL_Insert(zSystem.MetaData, zDataSet.TableName, Str);
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzFrameEditor_DataSet.Build_SQL_Update;
var
  i: Integer;
  Str: TStringList;
  FieldName: string;
begin
  Str := TStringList.Create;
  try
    Str.Clear;
    for i := 0 to UpdateFieldsTL.Items.Count - 1 do
    begin
      if UpdateFieldsTL.Items[i].Checked then
      begin
        FieldName := UpdateFieldsTL.Items[i].Caption;
        Str.Add(FieldName);
      end;
    end;
    seUpdate.SQL := zSqlLib.Build_SQL_Update(zSystem.MetaData, zDataSet.TableName, zDataSet.PrimaryKeyFields, Str);
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzFrameEditor_DataSet.CacheExecute(Sender: TObject);
begin
  inherited;

  Cache.Enabled := False;
  try
    Apply;

    zSystem.InitializeFromDB();

    Init;
    FillQueryBuilderMetadata;
  finally
    Cache.Enabled := True;
  end;

end;

procedure TzFrameEditor_DataSet.Build_SQL_Delete;
begin
  seDelete.SQL := zSqlLib.Build_SQL_Delete(zSystem.MetaData, zDataSet.TableName, zDataSet.PrimaryKeyFields);
end;

procedure TzFrameEditor_DataSet.Build_SQL_Refresh;

  function ClearWO(const SQL: string): string;
  var
    Parser: TSQLParser;
  begin
    Result := '';
    Parser := TSQLParser.Create;
    try
      Parser.SQLText := SQL;
      Result := Parser.SetMainWhereClause('');
      Parser.SQLText := Result;
      Result := Parser.SetOrderClause('');
    finally
      FreeAndNil(Parser);
    end;
  end;

var
  WhereStr: string;
  SQL: string;
begin
  Internal_PostEditor;

  SQL := zDataSet.SQL_Select.Text;

  if zDataSet.TableName <> '' then
  begin
    // clear Where e Order By
    SQL := ClearWO(SQL);

    SQL := Trim(SQL);
    // calcolo nuovo pezzo
    WhereStr := Trim(zSqlLib.Calc_WhereByKeyFields(zSystem.MetaData, zDataSet.TableName, zDataSet.PrimaryKeyFields, False));

    if Trim(WhereStr) <> '' then
      SQL := AddToWhereClause(SQL, WhereStr, True);

    seRefresh.SQL := SQL;
  end;
end;

/// /////

procedure TzFrameEditor_DataSet.Prepare_TL_Fields;
var
  Fields: TStringList;

  procedure PreparaListView(ListView: TListView);
  var
    i: Integer;
    Item: TListItem;
  begin
    ListView.Items.BeginUpdate;
    try
      ListView.Items.Clear;

      for i := 0 to Fields.Count - 1 do
      begin
        Item := ListView.Items.Add;
        Item.Caption := Fields[i];
        Item.Checked := True;
      end;
    finally
      ListView.Items.EndUpdate;
    end;
  end;

begin
  Fields := TStringList.Create;
  try
    zSqlLib.Get_FieldNames(zSystem.MetaData, zDataSet.TableName, Fields, False);

    if IsSqlAllowed(zSystem.MetaData, zDataSet.TableName, qtInsert) then
      PreparaListView(InsertFieldsTL);

    if IsSqlAllowed(zSystem.MetaData, zDataSet.TableName, qtUpdate) then
      PreparaListView(UpdateFieldsTL);
  finally
    FreeAndNil(Fields);
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////

procedure TzFrameEditor_DataSet.BuildSUID(aTableName: string);
begin
  cxBarEditItemRelations.EditValue := aTableName;
  Build_SQL_Insert;
  Build_SQL_Update;
  Build_SQL_Delete;
  Build_SQL_Refresh;
end;

procedure TzFrameEditor_DataSet.InsertFieldsTLClick(Sender: TObject);
begin
  inherited;
  Build_SQL_Insert;
end;

procedure TzFrameEditor_DataSet.UpdateFieldsTLClick(Sender: TObject);
begin
  inherited;
  Build_SQL_Update;
end;

procedure TzFrameEditor_DataSet.CreaDaNomeTabellaExecute(Sender: TObject);
begin
  inherited;
  BuildSUID(zDataSet.TableName);
end;

procedure TzFrameEditor_DataSet.Fill_Items_Generators;
var
  i: Integer;
  Props: TcxImageComboBoxProperties;
  dxItem: TcxImageComboBoxItem;

begin

  InitImageComboProps(cxBarEditItemGenerator);
  Props := cxBarEditItemGenerator.Properties as TcxImageComboBoxProperties;
  Props.OnEditValueChanged := cxBarEditItemGeneratorPropertiesEditValueChanged;

  Props.Items.BeginUpdate;
  try
    Props.Items.Clear;
    dxItem := Props.Items.Add;
    dxItem.Description := '---';
    dxItem.Value := '---';
    dxItem.ImageIndex := -1;

    for i := 0 to zSystem.zGenerators.Count - 1 do
    begin
      dxItem := Props.Items.Add;
      dxItem.Description := zSystem.zGenerators[i].Name;
      dxItem.Value := zSystem.zGenerators[i].Name;
      dxItem.ImageIndex := 3;
    end;

  finally
    Props.Items.EndUpdate;
  end;
  cxBarEditItemGenerator.EditValue := zDataSet.Generator;
end;

procedure TzFrameEditor_DataSet.Fill_Items_TableNames;
var
  i: Integer;
  strlist: TStringList;
  Props: TcxImageComboBoxProperties;
  dxItem: TcxImageComboBoxItem;
begin

  strlist := TStringList.Create;
  try
    for i := 0 to zSystem.MetaData.Tables.Count - 1 do
      strlist.Add(zSystem.MetaData.Tables[i].Name + '=0');

    for i := 0 to zSystem.MetaData.Procedures.Count - 1 do
      strlist.Add(zSystem.MetaData.Procedures[i].Name + '=1');

    for i := 0 to zSystem.MetaData.Views.Count - 1 do
      strlist.Add(zSystem.MetaData.Views[i].Name + '=2');

    strlist.Sort;

    InitImageComboProps(cxBarEditItemRelations);
    Props := cxBarEditItemRelations.Properties as TcxImageComboBoxProperties;
    Props.OnEditValueChanged := cxBarEditItemRelationsPropertiesEditValueChanged;

    Props.Items.BeginUpdate;
    try
      Props.Items.Clear;
      dxItem := Props.Items.Add;
      dxItem.Description := '---';
      dxItem.Value := '---';
      dxItem.ImageIndex := -1;

      for i := 0 to strlist.Count - 1 do
      begin
        dxItem := Props.Items.Add;
        dxItem.Description := strlist.Names[i];
        dxItem.Value := strlist.Names[i];
        dxItem.ImageIndex := StrToInt(strlist.ValueFromIndex[i]);
      end;
    finally
      Props.Items.EndUpdate;
    end;
    cxBarEditItemRelations.EditValue := InternalDataSet.TableName;
  finally
    FreeAndNil(strlist);
  end;
end;

procedure TzFrameEditor_DataSet.InitCombo;

var
  s, TableName: string;
begin
  if not Assigned(InternalDataSet) then
    exit;

  if InternalDataSet.TableName <> '' then
    TableName := InternalDataSet.TableName
  else
    if zSqlLib.Get_TableNameFromSQL(zSystem.MetaData, InternalDataSet.SelectSQL.Text, s, False) then
      TableName := s;

  Fill_Items_TableNames;

  s := zDataSet.Generator;
  s := StringReplace(s, #10, '', [rfReplaceAll]);
  s := StringReplace(s, #13, '', [rfReplaceAll]);

  Fill_Items_Generators;
end;

procedure TzFrameEditor_DataSet.seSelectExit(Sender: TObject);
begin
  try
    InternalDataSet.SelectSQL.Text := seSelect.SQL;
  except
    on e: exception do
      ApplicationShowException(e);
  end;
end;

destructor TzFrameEditor_DataSet.Destroy;
begin
  try
    FreeAndNil(zDataSet);

    if Assigned(InternalDataSet) then
      InternalDataSet.Active := False;

    if Assigned(PrepareDataSet) then
      PrepareDataSet.Active := False;
  except
    on e: exception do
      siMain.LogException(e); // mai propagare: qui l'oggetto muore comunque
  end;

  inherited;
end;

procedure TzFrameEditor_DataSet.Internal_InitEditor;
begin
  if Locked then
    exit;

  if csDesigning in ComponentState then
    exit;

  if csDestroying in ComponentState then
    exit;

  if pageDataSet.ActivePage = tabSelect then
  begin
    seSelect.SQL := InternalDataSet.SelectSQL.Text
  end
  else
    if pageDataSet.ActivePage = tabQueryBuilder then
    begin
      CheckQueryBuilderMetadata;
      acQueryBuilder.SQL := InternalDataSet.SelectSQL.Text;
    end
    else
      if pageDataSet.ActivePage = tabIUD then
      begin
        SetItemChecked(cbAutoRefresh, zDataSet.AutoSQL_Refresh);
        SetItemChecked(cbAutoInsert, zDataSet.AutoSQL_Insert);
        SetItemChecked(cbAutoUpdate, zDataSet.AutoSQL_Update);
        SetItemChecked(cbAutoDelete, zDataSet.AutoSQL_Delete);
        seInsert.SQL := InternalDataSet.InsertSQL.Text;
        seUpdate.SQL := InternalDataSet.UpdateSQL.Text;
        seDelete.SQL := InternalDataSet.DefaultSQL.Text;
        seRefresh.SQL := InternalDataSet.RefreshSQL.Text;
        Prepare_TL_Fields;
      end
      else
        if pageDataSet.ActivePage = tabInspector then
        begin
          FrameObjectInspector1.Clear;
          // FrameObjectInspector1.Add(InternalDataSet);
          FrameObjectInspector1.Add(zDataSet);
        end;
end;

procedure TzFrameEditor_DataSet.Internal_PostEditor;
begin
  if Locked then
    exit;

  if pageDataSet.ActivePage = tabSelect then
  begin
    InternalDataSet.SelectSQL.Text := seSelect.SQL;
    Internal_ApplyFromDataSet;
  end
  else
    if pageDataSet.ActivePage = tabQueryBuilder then
    begin
      InternalDataSet.SelectSQL.Text := acSQLBuilderPlainText.SQL;
      Internal_ApplyFromDataSet;
    end
    else
      if pageDataSet.ActivePage = tabIUD then
      begin
        zDataSet.AutoSQL_Refresh := GetItemChecked(cbAutoRefresh);
        zDataSet.AutoSQL_Insert := GetItemChecked(cbAutoInsert);
        zDataSet.AutoSQL_Update := GetItemChecked(cbAutoUpdate);
        zDataSet.AutoSQL_Delete := GetItemChecked(cbAutoDelete);
        InternalDataSet.RefreshSQL.Text := seRefresh.SQL;
        InternalDataSet.InsertSQL.Text := seInsert.SQL;
        InternalDataSet.DeleteSQL.Text := seDelete.SQL;
        InternalDataSet.UpdateSQL.Text := seUpdate.SQL;
        Internal_ApplyFromDataSet;
      end;
end;

procedure TzFrameEditor_DataSet.Internal_InitDataSet;
begin
  InternalDataSet.SelectSQL.Text := zDataSet.SQL_Select.Text;
  InternalDataSet.InsertSQL.Text := zDataSet.SQL_Insert.Text;
  InternalDataSet.UpdateSQL.Text := zDataSet.SQL_Update.Text;
  InternalDataSet.DeleteSQL.Text := zDataSet.SQL_Delete.Text;
  InternalDataSet.RefreshSQL.Text := zDataSet.SQL_Refresh.Text;
  InternalDataSet.TableName := zDataSet.TableName;
  InternalDataSet.IdDataSet := zDataSet.Name;
  InternalDataSet.GeneratorName := zDataSet.Generator;
end;

procedure TzFrameEditor_DataSet.Internal_ApplyFromDataSet;
begin
  zDataSet.TableName := InternalDataSet.TableName;
  zDataSet.SQL_Select.Text := InternalDataSet.SelectSQL.Text;
  zDataSet.SQL_Insert.Text := InternalDataSet.InsertSQL.Text;
  zDataSet.SQL_Update.Text := InternalDataSet.UpdateSQL.Text;
  zDataSet.SQL_Delete.Text := InternalDataSet.DeleteSQL.Text;
  zDataSet.SQL_Refresh.Text := InternalDataSet.RefreshSQL.Text;
end;

procedure TzFrameEditor_DataSet.Init;
begin
  inherited;

  if Assigned(Item) then
    zDataSet.Assign(Item);

  seSelect.MetaData := zSystem.MetaData;
  seRefresh.MetaData := zSystem.MetaData;
  seInsert.MetaData := zSystem.MetaData;
  seUpdate.MetaData := zSystem.MetaData;
  seDelete.MetaData := zSystem.MetaData;

  InternalDataSet.Active := False;
  InternalDataSet.Fields.Clear;
  SetItemChecked(cbAutoRefresh, zDataSet.AutoSQL_Refresh);
  SetItemChecked(cbAutoInsert, zDataSet.AutoSQL_Insert);
  SetItemChecked(cbAutoUpdate, zDataSet.AutoSQL_Update);
  SetItemChecked(cbAutoDelete, zDataSet.AutoSQL_Delete);

  Internal_InitDataSet;
  InternalDataSet.Database := zSystem.zFbDatabase;
  InternalDataSet.Transaction := zSystem.zFbTransaction;

  PrepareDataSet.Active := False;
  PrepareDataSet.Fields.Clear;
  PrepareDataSet.Database := zSystem.zFbDatabase;
  PrepareDataSet.Transaction := zSystem.zFbTransaction;

  InitCombo;
  Internal_InitEditor;

  if not InternalDataSet.SelectSQL.Text.IsEmpty then
  begin
    try
      try
        InternalDataSet.BuildFields(True);
      except
        on e: exception do
          seSelect.DisplayException(e);
      end;
    except
    end;
  end;
end;

procedure TzFrameEditor_DataSet.AggiungiFKUpdate(Sender: TObject);
begin
  inherited;
  AggiungiFK.Visible := TableNameAssigned and (pageDataSet.ActivePage = tabQueryBuilder);
end;

procedure TzFrameEditor_DataSet.Apply;
begin
  inherited;
  if not Assigned(Item) then
    exit;

  zDataSet.AutoSQL_Refresh := GetItemChecked(cbAutoRefresh);
  zDataSet.AutoSQL_Insert := GetItemChecked(cbAutoInsert);
  zDataSet.AutoSQL_Update := GetItemChecked(cbAutoUpdate);
  zDataSet.AutoSQL_Delete := GetItemChecked(cbAutoDelete);

  Internal_PostEditor;
  Internal_ApplyFromDataSet;
  Item.Assign(zDataSet);
end;

procedure TzFrameEditor_DataSet.seSelectChange(Sender: TObject);
begin
  inherited;
  try
    Build_SQL_Refresh;
  except
  end;
end;

procedure TzFrameEditor_DataSet.acQueryBuilderAfterCreateControls(Sender: TObject);
begin
  inherited;
  // acQueryBuilder.MetadataTree.Columns[0].PropertiesClassName := 'TcxTextEditProperties';
end;

procedure TzFrameEditor_DataSet.acQueryBuilderValidatePopupMenu(Sender: TacQueryBuilder; AControlOwner: TacQueryBuilderControlOwner; AForControl: TControl; APopupMenu: TPopupMenu);
var
  newds: TacDatasource; // TacDataSourceObject;
  tbl: TacMetadataTable;
  s: string;
  i: Integer;
  J: Integer;
  FKMenu, Menu: TMenuItem;
  MetaDataTbl: TacMetadataTable;
begin
  // 'TacUnionSubQuery'
  if not(AControlOwner is TacDatasource) then
    exit;

  MasterQry := AControlOwner as TacDatasource;

  if MasterQry.DatasourceType <> dtTable then
    exit;

  tbl := MasterQry.MetadataObject as TacMetadataTable;

  if tbl.Relations.Count = 0 then
    exit;

  APopupMenu.Images := imgObjects16;

  FKMenu := TMenuItem.Create(Self);
  FKMenu.Caption := '-';
  APopupMenu.Items.Add(FKMenu);

  FKMenu := TMenuItem.Create(Self);
  FKMenu.Caption := 'Foreign Keys';
  FKMenu.ImageIndex := 6;
  APopupMenu.Items.Add(FKMenu);

  for i := 0 to tbl.Relations.Count - 1 do
  begin
    Menu := TMenuItem.Create(Self);
    Menu.Caption := tbl.Relations[i].ChildNameStr;
    Menu.OnClick := RelationsMenuClick;
    Menu.ImageIndex := 6;
    FKMenu.Add(Menu);
  end;

  // /// ////////////////////
  // /// separatore
  // Menu := TMenuItem.Create(Self);
  // Menu.Caption := '-';
  // Menu.OnClick := nil;
  // FKMenu.Add(Menu);

  /// ////////////////////
  ///
  FKMenu := TMenuItem.Create(Self);
  FKMenu.Caption := 'Relations';
  FKMenu.ImageIndex := 6;
  APopupMenu.Items.Add(FKMenu);

  for i := 0 to acQueryBuilder.MetadataContainer.Count - 1 do
    if acQueryBuilder.MetadataContainer.Items[i] is TacMetadataTable then
    begin
      MetaDataTbl := acQueryBuilder.MetadataContainer.Items[i] as TacMetadataTable;

      for J := 0 to MetaDataTbl.Relations.Count - 1 do
        if sametext(tbl.NameStr, MetaDataTbl.Relations[J].ChildNameStr) then
        begin
          Menu := TMenuItem.Create(Self);
          Menu.Caption := MetaDataTbl.NameStr;
          Menu.OnClick := RelationsMenuClick;
          Menu.ImageIndex := 6;
          FKMenu.Add(Menu);
        end;
    end;
end;

procedure TzFrameEditor_DataSet.AggiornaRefreshExecute(Sender: TObject);
begin
  inherited;
  Build_SQL_Refresh;
end;

procedure TzFrameEditor_DataSet.pageDataSetChange(Sender: TObject);
begin
  inherited;
  Internal_InitEditor;
end;

procedure TzFrameEditor_DataSet.pageDataSetPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  inherited;
  Internal_PostEditor;
end;

procedure TzFrameEditor_DataSet.EliminaSQLExecute(Sender: TObject);
begin
  inherited;
  seInsert.editor.Clear;
  seUpdate.editor.Clear;
  seDelete.editor.Clear;
  seRefresh.editor.Clear;
end;

procedure TzFrameEditor_DataSet.cbAutoInsertClick(Sender: TObject);
begin
  inherited;
  if GetItemChecked(cbAutoInsert) then
    seInsert.editor.Clear
  else
    Build_SQL_Insert;
end;

procedure TzFrameEditor_DataSet.cbAutoRefreshClick(Sender: TObject);
begin
  inherited;
  if GetItemChecked(cbAutoRefresh) then
    seRefresh.editor.Clear
  else
    Build_SQL_Refresh;
end;

procedure TzFrameEditor_DataSet.cbAutoUpdateClick(Sender: TObject);
begin
  inherited;
  if GetItemChecked(cbAutoUpdate) then
    seUpdate.editor.Clear
  else
    Build_SQL_Update;
end;

procedure TzFrameEditor_DataSet.cbAutoDeleteClick(Sender: TObject);
begin
  inherited;
  if GetItemChecked(cbAutoDelete) then
    seDelete.editor.Clear
  else
    Build_SQL_Delete;
end;

procedure TzFrameEditor_DataSet.RicreaSelectExecute(Sender: TObject);
begin
  inherited;
  Build_SelectSQL;
end;

procedure TzFrameEditor_DataSet.RicreaSelectUpdate(Sender: TObject);
begin
  inherited;
  RicreaSelect.Visible := TableNameAssigned and (pageDataSet.ActivePage = tabSelect);
end;

procedure TzFrameEditor_DataSet.tabQueryBuilderEnter(Sender: TObject);
begin
  inherited;

  CheckQueryBuilderMetadata;
  try
    acQueryBuilder.SQL := InternalDataSet.SelectSQL.Text;
  except
    on e: exception do
      ApplicationShowException(e);
  end;

end;

procedure TzFrameEditor_DataSet.tabQueryBuilderHide(Sender: TObject);
begin
  inherited;
  try
    InternalDataSet.SelectSQL.Text := acSQLBuilderPlainText.SQL;
  except
    on e: exception do
      ApplicationShowException(e);
  end;
end;

procedure TzFrameEditor_DataSet.Build_SelectSQL;
var
  idx: Integer;
begin
  inherited;
  Prepare_TL_Fields;

  // aggiorna il generatore
  idx := zSystem.zGenerators.FindItemByTableName(InternalDataSet.TableName);
  if idx <> -1 then
  begin
    zDataSet.Generator := zSystem.zGenerators[idx].GeneratorName;
    cxBarEditItemGenerator.EditValue := zDataSet.Generator;
  end;
  //

  InternalDataSet.SelectSQL.Text := zSqlLib.Build_Sql_Select(zSystem.MetaData, InternalDataSet.TableName, nil);
  Internal_InitEditor;
  //
end;

procedure TzFrameEditor_DataSet.cxRTTIInspector1EditValueChanged(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties);
begin
  inherited;
  ComponentToDFM(acSQLBuilderPlainText, path + 'x.dfm');
end;

procedure TzFrameEditor_DataSet.RelationsMenuClick(Sender: TObject);
var
  DetailTblName: string;
  DetailQry: TacDatasource;
  Pt: TPoint;
begin
  DetailTblName := (Sender as TMenuItem).Caption;
  Pt := Point(MasterQry.Left + MasterQry.Width + 50, MasterQry.Top);
  DetailQry := acQueryBuilder.Query.ActiveUnionSubquery.AddObjectWithFKAt(DetailTblName, Pt, '');
end;

function TzFrameEditor_DataSet.TableNameAssigned: Boolean;
var
  s: string;
begin
  s := VarToStr(cxBarEditItemRelations.EditValue);
  Result := (s <> '') and (s <> '---');
end;

procedure TzFrameEditor_DataSet.cxBarEditItemGeneratorPropertiesEditValueChanged(Sender: TObject);
begin
  inherited;
  zDataSet.Generator := VarToStr(cxBarEditItemGenerator.EditValue);
end;

procedure TzFrameEditor_DataSet.cxBarEditItemRelationsPropertiesEditValueChanged(Sender: TObject);
begin
  inherited;
  InternalDataSet.TableName := VarToStr(cxBarEditItemRelations.EditValue);
  zDataSet.TableName := InternalDataSet.TableName;

  if Trim(seSelect.SQL) = '' then
    RicreaSelect.Execute;
end;

procedure TzFrameEditor_DataSet.InitImageComboProps(Combo: TcxBarEditItem);
var
  Properties: TcxImageComboBoxProperties;
begin
  Assert(Assigned(Combo));
  Properties := Combo.Properties as TcxImageComboBoxProperties;

  Properties.ClearKey := VK_DELETE;
  Properties.DropDownRows := 12;
  Properties.ImmediatePost := True;
  Properties.ImmediateUpdateText := True;
  Properties.PostPopupValueOnTab := True;
  Properties.Revertable := True;
  Properties.Images := imgCombo;
end;

procedure TzFrameEditor_DataSet.SetItemChecked(Item: TcxBarEditItem; Value: Boolean);
begin
  Assert(Assigned(Item));
  Item.EditValue := Value;
end;

function TzFrameEditor_DataSet.GetEditorCaption: string;
begin
  Result := zDataSet.Name;
end;

function TzFrameEditor_DataSet.GetItemChecked(Item: TcxBarEditItem): Boolean;
begin
  // Assert(Assigned(Item));

  Result := False;

  if Assigned(Item) then
    Result := Item.EditValue
  else
    Result := False;
end;

procedure TzFrameEditor_DataSet.GetNomeTabellaDaSqlExecute(Sender: TObject);
var
  idx: Integer;
  TableName: string;
begin
  inherited;

  TableName := VarToStr(cxBarEditItemRelations.EditValue);

  if not zSqlLib.Get_TableNameFromSQL(zSystem.MetaData, seSelect.SQL, TableName, True) then
    exit;

  InternalDataSet.TableName := TableName;
  zDataSet.TableName := InternalDataSet.TableName;
  cxBarEditItemRelations.EditValue := InternalDataSet.TableName;

  idx := zSystem.zGenerators.FindItemByTableName(TableName);
  if idx <> -1 then
  begin
    zDataSet.Generator := zSystem.zGenerators[idx].GeneratorName;
    cxBarEditItemGenerator.EditValue := zDataSet.Generator;
  end;

  zDataSet.IdentityField := zSystem.MetaData.GetIdentity(InternalDataSet.TableName);
end;

procedure TzFrameEditor_DataSet.FillQueryBuilderMetadata;
  procedure AddTables;
  var
    t: TacMetadataTable;
    r: TacMetadataRelation;
    f: TacMetadataField;

    zTable: TzmdTable;
    fk: TzmdForeignKey;
    zField: TzmdField;
    iTable: Integer;
    iField: Integer;
    iFk: Integer;
    iFieldName: Integer;
  begin
    for iTable := 0 to zSystem.MetaData.Tables.Count - 1 do
    begin
      zTable := zSystem.MetaData.Tables[iTable];

      t := acQueryBuilder.MetadataContainer.AddTable(zTable.Name);

      for iField := 0 to zTable.Fields.Count - 1 do
      begin
        zField := zTable.Fields[iField];
        f := t.Fields.Add;
        f.NameStr := zField.Name;
        f.FieldType := zField.DataType;
        f.Size := zField.Size;
        f.Nullable := not zField.NotNull;
        f.PrimaryKey := zTable.PrimaryKey.IndexOf(zField.Name) <> -1;
      end;

      for iFk := 0 to zTable.ForeignKeys.Count - 1 do
      begin
        fk := zTable.ForeignKeys[iFk];
        r := t.Relations.Add;
        r.ChildNameStr := fk.FkTable;

        for iFieldName := 0 to fk.Fields.Count - 1 do
          r.KeyFields.Add(fk.Fields[iFieldName].Name);

        for iFieldName := 0 to fk.FkFields.Count - 1 do
          r.ChildFields.Add(fk.FkFields[iFieldName].Name);
      end;
    end;
  end;
  procedure AddViews;
  var
    t: TacMetadataView;
    f: TacMetadataField;
    zView: TzmdView;
    zField: TzmdField;
    iView: Integer;
    iField: Integer;
  begin
    for iView := 0 to zSystem.MetaData.Views.Count - 1 do
    begin
      zView := zSystem.MetaData.Views[iView];
      t := acQueryBuilder.MetadataContainer.AddView(zView.Name);

      for iField := 0 to zView.Fields.Count - 1 do
      begin
        zField := zView.Fields[iField];
        f := t.Fields.Add;
        f.NameStr := zField.Name;
        f.FieldType := zField.DataType;
        f.Size := zField.Size;
        f.Nullable := not zField.NotNull;
      end;
    end;
  end;

  procedure AddProcedures;
  var
    Proc: TacMetadataProcedure;
    zProcedure: TzmdProcedure;
    zParam: TzmdParam;
    Param: TacMetadataParameter;
    iProc: Integer;
    iParam: Integer;
    f: TacMetadataField;
  begin

    for iProc := 0 to zSystem.MetaData.Procedures.Count - 1 do
    begin
      zProcedure := zSystem.MetaData.Procedures[iProc];
      if zProcedure.ParamsOutput.Count > 0 then
      begin

        Proc := acQueryBuilder.MetadataContainer.AddProcedure(zProcedure.Name);
        Proc.AltName := zProcedure.Name;

        for iParam := 0 to zProcedure.ParamsInput.Count - 1 do
        begin
          zParam := zProcedure.ParamsInput[iParam];
          Param := Proc.Parameters.Add;
          // param.NameStr := zParam.Name;
          Param.FieldType := zParam.DataType;
          Param.Size := zParam.Size;
          Param.ParamType := ptInput;
        end;

        for iParam := 0 to zProcedure.ParamsOutput.Count - 1 do
        begin
          zParam := zProcedure.ParamsOutput[iParam];
          Param := Proc.Parameters.Add;
          // param.Name := zParam.Name;
          Param.FieldType := zParam.DataType;
          Param.Size := zParam.Size;
          Param.ParamType := ptOutput;

          f := Proc.Fields.Add;
          f.NameStr := zParam.Name;
          f.FieldType := zParam.DataType;
          f.Size := zParam.Size;
          f.Nullable := True;
        end;
      end;
    end;
  end;

begin

  acQueryBuilder.TreeOptionsMetadata.ImageList := imgObjects16;
  acQueryBuilder.AddObjectFormOptions.ImageListSmall := imgObjects16;
  acQueryBuilder.AddObjectFormOptions.ImageListLarge := imgObjects32;
  acQueryBuilder.AddObjectFormOptions.ListViewStyle := vsIcon;

  acQueryBuilder.WorkOffLine := True;
  acQueryBuilder.MetadataProvider := nil;

  StartWait('Attendere...', True);
  try
    acQueryBuilder.MetadataContainer.BeginUpdate;
    try
      acQueryBuilder.MetadataContainer.Clear;
      /// ////////
      AddTables;
      AddViews;
      AddProcedures;
    finally
      acQueryBuilder.MetadataContainer.EndUpdate;
    end;
  finally
    StopWait;
  end;
end;

procedure TzFrameEditor_DataSet.tabQueryBuilderShow(Sender: TObject);
begin
  inherited;
  CheckQueryBuilderMetadata;
end;

procedure TzFrameEditor_DataSet.CercaGeneratoreExecute(Sender: TObject);
var
  idx: Integer;
begin
  inherited;

  zDataSet.IdentityField := zSystem.MetaData.GetIdentity(InternalDataSet.TableName);

  idx := zSystem.zGenerators.FindItemByTableName(InternalDataSet.TableName);
  if idx <> -1 then
  begin
    zDataSet.Generator := zSystem.zGenerators[idx].GeneratorName;
    cxBarEditItemGenerator.EditValue := zDataSet.Generator;
  end;
end;

procedure TzFrameEditor_DataSet.CheckQueryBuilderMetadata;
begin
  if acQueryBuilder.MetadataContainer.Count = 0 then
    FillQueryBuilderMetadata;
end;

procedure TzFrameEditor_DataSet.cxBarEditItemRelationsCurChange(Sender: TObject);
begin
  inherited;
  zDataSet.IdentityField := zSystem.MetaData.GetIdentity(InternalDataSet.TableName);
end;

procedure TzFrameEditor_DataSet.EditaGeneratoreExecute(Sender: TObject);
var
  idx: Integer;
begin
  inherited;
  idx := zSystem.zGenerators.IndexOf(zDataSet.Generator);
  if idx <> -1 then
  begin
    zSystem.zGenerators[idx].Inspect;
    zSystem.SaveZip(csGenerators, 'Generatore');
  end;
end;

procedure TzFrameEditor_DataSet.doPrepare(const SQL: string);
begin
  PrepareDataSet.Active := False;
  PrepareDataSet.Fields.Clear;
  PrepareDataSet.SelectSQL.Text := SQL;
  PrepareDataSet.Prepare;
end;

procedure TzFrameEditor_DataSet.PrepareSQL(Sender: TObject);
begin
  doPrepare(TFrameEditor_SQL(Sender).SQL);
end;

function TzFrameEditor_DataSet.CanClose(ModalResult: TModalResult): Boolean;
begin
  Result := True;

  if ModalResult = mrOk then
  begin
    Internal_PostEditor;
    try
      doPrepare(InternalDataSet.SelectSQL.Text);
    except
      on e: exception do
      begin
        Result := False;
        Application.HandleException(e);
      end;
    end;
  end;
end;

procedure TzFrameEditor_DataSet.seSelectFormatSQL(Sender: TObject);
begin
  inherited;
  CheckQueryBuilderMetadata;

  if acQueryBuilder.SQL <> seSelect.SQL then
    acQueryBuilder.SQL := seSelect.SQL;

  seSelect.SQL := acSQLBuilderPlainText.SQL;
end;

end.
