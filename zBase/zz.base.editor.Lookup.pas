unit zz.base.editor.Lookup;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  StdCtrls,
  Dialogs,
  Menus,
  ExtCtrls,
  ComCtrls,
  ImgList,
  ActnList,
  zCollection,
  zSystem,
  Frame_ObjectInspector,
  ToolWin,
  Mask,
  Buttons,
  dxBar,
  cxClasses,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  dxSkinscxPCPainter,
  cxPCdxBarPopupMenu,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxPC,
  dxBarBuiltInMenu,
  System.ImageList,
  System.Actions,
  cxContainer,
  cxEdit,
  cxCustomListBox,
  cxListBox,
  cxSplitter,
  cxLabel,
  cxTextEdit,
  cxMaskEdit,
  cxDropDownEdit,
  cxImageComboBox,
  cxMemo,
  cxButtons,
  dxLayoutcxEditAdapters,
  dxLayoutContainer,
  dxLayoutControlAdapters,
  dxLayoutControl,
  cxImageList,
  cxStyles,
  dxScrollbarAnnotations,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  zz.base.editor._frame,
  cxFilter;

type
  TzFrameEditor_Lookup = class(TzFrameEditorCollectionItem)
    ActionList: TActionList;
    popResult: TPopupMenu;
    Azzera: TAction;
    EliminaRiga: TAction;
    Elimina1: TMenuItem;
    Azzera1: TMenuItem;
    Automatico: TAction;
    popField: TPopupMenu;
    Aggiungi1: TMenuItem;
    Auto1: TMenuItem;
    NuovaRiga: TAction;
    lbDest: TcxListBox;
    lbSource: TcxListBox;
    btnNuovoDataset: TcxButton;
    edTableDest: TcxImageComboBox;
    edTableSrc: TcxImageComboBox;
    NuovoDataSet: TAction;
    dxBarManager: TdxBarManager;
    dxBarDockControl: TdxBarDockControl;
    dxBarButtonAzzera: TdxBarButton;
    dxBarButtonElimina: TdxBarButton;
    dxBarButtonAggiungi: TdxBarButton;
    dxBarButtonAutomatico: TdxBarButton;
    dxBarButtonNuovo: TdxBarButton;
    dxBarButtonNuovoDataSet: TdxBarButton;
    dxBarManagerBar1: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    ModificaDataSet: TAction;
    btnModificaDataSet: TcxButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    btnDuplica: TcxButton;
    DuplicaLookup: TAction;
    Memo: TAction;
    dxBarButton10: TdxBarButton;
    memoDipendenze: TcxMemo;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    dxLayoutGroupPageControl: TdxLayoutGroup;
    dxLayoutGroupEditor: TdxLayoutGroup;
    dxLayoutItemTableDest: TdxLayoutItem;
    dxLayoutItemCampiDest: TdxLayoutItem;
    dxLayoutItemTableSrc: TdxLayoutItem;
    dxLayoutItemCampiSrc: TdxLayoutItem;
    dxLayoutSplitterItem1: TdxLayoutSplitterItem;
    dxLayoutItemBarDockControl: TdxLayoutItem;
    dxLayoutGroupProprieta: TdxLayoutGroup;
    dxLayoutGroup18: TdxLayoutGroup;
    dxLayoutGroup19: TdxLayoutGroup;
    dxLayoutGroup20: TdxLayoutGroup;
    dxLayoutItem7: TdxLayoutItem;
    dxLayoutItem8: TdxLayoutItem;
    dxLayoutItem9: TdxLayoutItem;
    dxLayoutGroupDipendenze: TdxLayoutGroup;
    dxLayoutItem11: TdxLayoutItem;
    dxLayoutGroupMapping: TdxLayoutGroup;
    dxLayoutGroupTop: TdxLayoutGroup;
    dxLayoutSplitterItem2: TdxLayoutSplitterItem;
    dxLayoutGroupDest: TdxLayoutGroup;
    dxLayoutGroupSrc: TdxLayoutGroup;
    btnVerifica: TcxButton;
    dxLayoutItem1: TdxLayoutItem;
    Verifica: TAction;
    cxImageList: TcxImageList;
    cxRTTIInspector: TFrameObjectInspector;
    dxLayoutItemRTTIInspector: TdxLayoutItem;
    imageCombo: TcxImageList;
    edLegenda: TcxListBox;
    dxLayoutItemLegenda: TdxLayoutItem;
    dxLayoutSplitterItem3: TdxLayoutSplitterItem;
    memoMappings: TcxMemo;
    dxLayoutItemMappings: TdxLayoutItem;
    dxLayoutSplitterItem4: TdxLayoutSplitterItem;
    inspectorMetaLookup: TFrameObjectInspector;
    dxLayoutItemMetadata: TdxLayoutItem;
    imageTabs: TcxImageList;
    procedure AzzeraExecute(Sender: TObject);
    procedure EliminaRigaExecute(Sender: TObject);
    procedure AutomaticoExecute(Sender: TObject);
    procedure cxPageControlChange(Sender: TObject);
    procedure DuplicaLookupExecute(Sender: TObject);
    procedure edTableDestChange(Sender: TObject);
    procedure edTableSrcChange(Sender: TObject);
    procedure NuovaRigaExecute(Sender: TObject);
    procedure MemoExecute(Sender: TObject);
    procedure memoMappingsDblClick(Sender: TObject);
    procedure memoMappingsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure memoMappingsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ModificaDataSetExecute(Sender: TObject);
    procedure NuovoDataSetExecute(Sender: TObject);
    procedure VerificaExecute(Sender: TObject);
  private
    IsLoading: Boolean;
    procedure FillSource;
    procedure FillDest;
    procedure SyncFill;
    procedure Fill_Items_TableNames(Combo: TcxImageComboBox; const Value: string);
    procedure InitEditor;
    procedure DisplayDipendenze;
    procedure InitLegenda;
  protected
    InternalLookup: TzLookup;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure Init; override;
    procedure Apply; override;
    function GetEditorCaption: string; override;
    function WindowState: TWindowState; override;
  end;

implementation

uses
  System.Variants,
  System.Generics.Defaults,
  zBaseLib,
  zz.Strings,
  zMsg,
  zz.base.editor._form,
  zMetadata,
  zdx;

{$R *.dfm}

constructor TzFrameEditor_Lookup.Create(aOwner: TComponent);
begin
  inherited;
  InitLegenda;

  dx.InitLayoutControl(dxLayoutControl);
  dxLayoutControl.OptionsImage.Images := imageTabs;
  cxRTTIInspector.ObjectInspector.OptionsView.RowHeaderWidth := 134;
  inspectorMetaLookup.ObjectInspector.OptionsView.RowHeaderWidth := 134;

  IsLoading := True;
  try
    InternalLookup := TzLookup.Create(nil);
    dxLayoutGroupPageControl.ItemIndex := 0;
  finally
    IsLoading := False;
  end;
end;

destructor TzFrameEditor_Lookup.Destroy;
begin
  FreeAndNil(InternalLookup);
  inherited;
end;

procedure TzFrameEditor_Lookup.Init;
begin
  inherited;

  if not Assigned(Item) then
    Exit;

  Clear;
  InternalLookup.Assign(Item);
  InitEditor;
  DisplayDipendenze;
end;

procedure TzFrameEditor_Lookup.Apply;
begin
  inherited;

  if not Assigned(Item) then
    Exit;

  InternalLookup.Mappings.text := memoMappings.Lines.text;

  Item.Assign(InternalLookup);
end;

procedure TzFrameEditor_Lookup.FillDest;
var
  i: Integer;
  SrcTable: string;
  idx: Integer;
begin
  lbDest.Items.Clear;

  idx := zSystem.MetaData.Tables.IndexOf(InternalLookup.TableName);
  if idx <> -1 then
  begin
    for i := 0 to zSystem.MetaData.Tables[idx].Fields.Count - 1 do
      lbDest.Items.Add(zSystem.MetaData.Tables[idx].Fields[i].Name);
  end
  else
  begin
    idx := zSystem.MetaData.Views.IndexOf(InternalLookup.TableName);
    if idx <> -1 then
    begin
      for i := 0 to zSystem.MetaData.Views[idx].Fields.Count - 1 do
        lbDest.Items.Add(zSystem.MetaData.Views[idx].Fields[i].Name);
    end
    else
    begin
      idx := zSystem.MetaData.Procedures.IndexOf(InternalLookup.TableName);
      if idx <> -1 then
      begin
        for i := 0 to zSystem.MetaData.Procedures[idx].ParamsOutput.Count - 1 do
          lbDest.Items.Add(zSystem.MetaData.Procedures[idx].ParamsOutput[i].Name);
      end;
    end;
  end;
end;

procedure TzFrameEditor_Lookup.FillSource;
var
  i: Integer;
  SrcTable: string;
  idx: Integer;
begin
  lbSource.Items.Clear;

  idx := zSystem.MetaData.Tables.IndexOf(InternalLookup.TableNameFK);
  if idx <> -1 then
  begin
    for i := 0 to zSystem.MetaData.Tables[idx].Fields.Count - 1 do
      lbSource.Items.Add(zSystem.MetaData.Tables[idx].Fields[i].Name);
  end
  else
  begin
    idx := zSystem.MetaData.Views.IndexOf(InternalLookup.TableNameFK);
    if idx <> -1 then
    begin
      for i := 0 to zSystem.MetaData.Views[idx].Fields.Count - 1 do
        lbSource.Items.Add(zSystem.MetaData.Views[idx].Fields[i].Name);
    end
    else
    begin
      idx := zSystem.MetaData.Procedures.IndexOf(InternalLookup.TableNameFK);
      if idx <> -1 then
      begin
        for i := 0 to zSystem.MetaData.Procedures[idx].ParamsOutput.Count - 1 do
          lbSource.Items.Add(zSystem.MetaData.Procedures[idx].ParamsOutput[i].Name);
      end;
    end;
  end;
end;

procedure TzFrameEditor_Lookup.SyncFill;
var
  i: Integer;
  s: string;
  idx: Integer;
begin
  lbSource.Items.BeginUpdate;
  try
    lbDest.Items.BeginUpdate;
    try
      for i := 0 to memoMappings.Lines.Count - 1 do
      begin
        s := memoMappings.Lines.ValueFromIndex[i];
        idx := lbSource.Items.IndexOf(s);
        if idx <> -1 then
          lbSource.Items.Delete(idx);

        s := memoMappings.Lines.Names[i];
        idx := lbDest.Items.IndexOf(s);
        if idx <> -1 then
          lbDest.Items.Delete(idx);
      end;
    finally
      lbDest.Items.EndUpdate;
    end;
  finally
    lbSource.Items.EndUpdate;
  end;
end;

procedure TzFrameEditor_Lookup.AzzeraExecute(Sender: TObject);
begin
  inherited;
  FillSource;
  FillDest;
  memoMappings.Clear;
end;

procedure TzFrameEditor_Lookup.NuovoDataSetExecute(Sender: TObject);
var
  zDataSet: TzDataSet;
begin
  inherited;
  if not ConfirmOkCancel('Aggiungere un nuovo dataset?') then
    Exit;

  if zSystem.zDataSets.IndexOf(InternalLookup.Name) = -1 then
  begin
    zDataSet := zSystem.zDataSets.Add; // evitiamo proliferazione di belinate

    zDataSet.Name := InternalLookup.Name;
    zDataSet.TableName := InternalLookup.TableNameFK;

    InternalLookup.DataSet := zDataSet.Name;

    cxRTTIInspector.InspectedObject := InternalLookup;
  end;
end;

procedure TzFrameEditor_Lookup.EliminaRigaExecute(Sender: TObject);
begin
  inherited;
  if memoMappings.CaretPos.Y = -1 then
    Exit;

  memoMappings.Lines.Delete(memoMappings.CaretPos.Y);
  FillSource;
  FillDest;
  SyncFill;
end;

procedure TzFrameEditor_Lookup.AutomaticoExecute(Sender: TObject);
var
  i: Integer;
  FieldName: string;
begin
  inherited;
  // fare il giro su src o dest è indifferente

  for i := 0 to lbSource.Items.Count - 1 do
  begin
    FieldName := lbSource.Items[i];

    if not FieldName.StartsWith('USR_', True) then
      if lbDest.Items.IndexOf(FieldName) <> -1 then
        memoMappings.Lines.AddPair(FieldName, FieldName);
  end;
end;

function TzFrameEditor_Lookup.WindowState: TWindowState;
begin
  Result := wsNormal;
end;

function TzFrameEditor_Lookup.GetEditorCaption: string;
begin
  if Assigned(Item) then
    Result := 'Lookup: ' + Item.Name
  else
    Result := Inherited GetEditorCaption;
end;

procedure TzFrameEditor_Lookup.NuovaRigaExecute(Sender: TObject);
var
  i: Integer;
  SourceField, DestField: string;
begin
  inherited;
  if lbSource.ItemIndex = -1 then
    SourceField := ''
  else
    SourceField := lbSource.Items[lbSource.ItemIndex];

  if lbDest.ItemIndex = -1 then
    DestField := SourceField
  else
    DestField := lbDest.Items[lbDest.ItemIndex];

  if not InputQuery('Campo sorgente', 'Source', SourceField) then
    Exit;

  if not InputQuery('Campo destinazione', 'Dest', DestField) then
    Exit;

  memoMappings.Lines.AddPair(DestField, SourceField);
end;

procedure TzFrameEditor_Lookup.cxPageControlChange(Sender: TObject);
begin
  inherited;

  if IsLoading then
    Exit;

  if dxLayoutGroupPageControl.ItemIndex = 0 then
  begin
    InitEditor;
  end
  else
    if dxLayoutGroupPageControl.ItemIndex = 1 then
    begin
      InternalLookup.Mappings.text := memoMappings.text;
      cxRTTIInspector.InspectedObject := InternalLookup;
    end;
end;

procedure TzFrameEditor_Lookup.DuplicaLookupExecute(Sender: TObject);
var
  NewName: string;
  newDataSet: TzDataSet;
  newView: TzDbViewProps;
  newLookup: TzLookup;
begin
  inherited;

  NewName := '__lk_';

  if not InputQuery('Nuovo Lookup', 'Nuovo Lookup', NewName) then
    Exit;

  NewName := Trim(NewName);

  if SameText(NewName, InternalLookup.Name) then
    Exit;

  /// ///////////////////////////

  newDataSet := zSystem.zDataSets.Add;
  if Assigned(InternalLookup.DataSet_Obj) then
    newDataSet.Assign(InternalLookup.DataSet_Obj);
  newDataSet.Name := NewName;

  newView := zSystem.zDbViews.Add;

  if Assigned(InternalLookup.DbView_Obj) then
    newView.Assign(InternalLookup.DbView_Obj);
  newView.Name := NewName;
  newView.DataSet := newDataSet.Name;

  newLookup := zSystem.zLookups.Add;

  if Assigned(InternalLookup) then
    newLookup.Assign(InternalLookup);
  newLookup.Name := NewName;
  newLookup.IsForeignKey := False;
  newLookup.DataSet := newDataSet.Name;
  newLookup.DbView := newView.Name;

  InternalLookup.Assign(newLookup);
  //
  cxRTTIInspector.InspectedObject := InternalLookup;
  InitEditor;
end;

procedure TzFrameEditor_Lookup.edTableDestChange(Sender: TObject);
begin
  inherited;
  InternalLookup.TableName := VarToStr(edTableDest.EditValue);
  FillDest;
end;

procedure TzFrameEditor_Lookup.edTableSrcChange(Sender: TObject);
begin
  inherited;
  InternalLookup.TableNameFK := VarToStr(edTableSrc.EditValue);
  FillSource;
end;

procedure TzFrameEditor_Lookup.InitEditor;
begin
  inherited;
  Fill_Items_TableNames(edTableDest, InternalLookup.TableName);
  Fill_Items_TableNames(edTableSrc, InternalLookup.TableNameFK);

  cxRTTIInspector.InspectedObject := InternalLookup;

  inspectorMetaLookup.InspectedObject := zSystem.MetaData.Lookups.Get(InternalLookup.Name, False);
  dxLayoutItemMetadata.Visible := inspectorMetaLookup.InspectedObject <> nil;

  dxLayoutGroupDipendenze.Visible := False;

  memoMappings.Lines.text := InternalLookup.Mappings.text;

  FillSource;
  FillDest;
  SyncFill;
end;

procedure TzFrameEditor_Lookup.ModificaDataSetExecute(Sender: TObject);
var
  idx: Integer;
  zDataSet: TzDataSet;
begin
  inherited;

  idx := zSystem.zDataSets.IndexOf(InternalLookup.DataSet);

  if idx = -1 then
    Exit
  else
    zDataSet := zSystem.zDataSets[idx];

  Edit_CollectionItem(zSystem, zDataSet);
  // if Edit_CollectionItem(zSystem, zDataSet) then
  // zSystem.zDataSets[idx].Assign(zDataSet);
  // InternalLookup.DataSet_Obj := zDataSet;
  // end;
end;

procedure TzFrameEditor_Lookup.MemoExecute(Sender: TObject);
  procedure checkStringList(stringList: TStringList);
  var
    i: Integer;
  begin
    for i := 0 to stringList.Count - 1 do
      if stringList.Names[i].IsEmpty then
        stringList[i] := stringList[i] + '=' + stringList[i];
  end;

var
  stringList: TStringList;
begin
  inherited;

  stringList := TStringList.Create;
  try
    stringList.Assign(memoMappings.Lines);
    if InputMemo('Mappings', 'Mappings', stringList) then
    begin
      checkStringList(stringList);
      memoMappings.Lines.Assign(stringList);
    end;
  finally
    FreeAndNil(stringList)
  end;
end;

procedure TzFrameEditor_Lookup.Fill_Items_TableNames(Combo: TcxImageComboBox; const Value: string);
var
  i, idx: Integer;
  Item: TcxImageComboBoxItem;
begin
  Combo.Properties.Items.BeginUpdate;
  try
    Combo.Clear;
    Combo.Properties.Items.Clear;

    // per togliere tablename

    Item := Combo.Properties.Items.Add;
    Item.Description := '---';
    Item.Value := '---';

    // Tabelle
    for i := 0 to zSystem.MetaData.Tables.Count - 1 do
    begin
      Item := Combo.Properties.Items.Add;
      Item.Description := zSystem.MetaData.Tables[i].Name;
      Item.Value := zSystem.MetaData.Tables[i].Name;
      Item.ImageIndex := 0;
    end;

    // Procedure
    for i := 0 to zSystem.MetaData.Procedures.Count - 1 do
      if zSystem.MetaData.Procedures[i].ParamsOutput.Count > 0 then
      begin
        Item := Combo.Properties.Items.Add;
        Item.Description := zSystem.MetaData.Procedures[i].Name;
        Item.Value := zSystem.MetaData.Procedures[i].Name;
        Item.ImageIndex := 1;
      end;
    // Viste
    for i := 0 to zSystem.MetaData.Views.Count - 1 do
    begin
      Item := Combo.Properties.Items.Add;
      Item.Description := zSystem.MetaData.Views[i].Name;
      Item.Value := zSystem.MetaData.Views[i].Name;
      Item.ImageIndex := 2;
    end;

    Combo.Properties.Items.Sort(TComparer<TCollectionItem>.Construct(
      function(const L, R: TCollectionItem): Integer
      begin
        Result := AnsiCompareText(TcxImageComboBoxItem(L).Description, TcxImageComboBoxItem(R).Description);
      end));
  finally
    Combo.Properties.Items.EndUpdate;
  end;
  //
  //
  //
  // ItemIndex
  try // saltuariamente da errore di conversione da variant
    Combo.ItemIndex := -1;

    for i := 0 to Combo.Properties.Items.Count - 1 do
      if SameText(VarToStr(Combo.Properties.Items[i].Value), Value) then
      begin
        Combo.ItemIndex := i;
        break;
      end;
  except
  end;
end;

procedure TzFrameEditor_Lookup.DisplayDipendenze;
var
  domain: TzDomain;
  card: TzDbCardProps;
  ctrl: TzControlProps;
begin
  memoDipendenze.Clear;

  // for domain in zSystem.zDataDictionary do
  // if SameText(domain.Lookup, InternalLookup.Name) then
  // begin
  // memoDipendenze.Lines.Add(domain.Name);
  //
  // for card in zSystem.zDbCards do
  // for ctrl in card.Controls do
  // if SameText(ctrl.Name, domain.Name) then
  // memoDipendenze.Lines.Add('   ' + ctrl.Name);
  // end;
end;

procedure TzFrameEditor_Lookup.VerificaExecute(Sender: TObject);
var
  Errori: TStringList;
  Campi: TStringList;
  s: string;
  TableNameFK, TableName: TzmdTable;
begin
  inherited;

  Errori := TStringList.Create;
  try
    Campi := TStringList.Create;
    try
      Campi.Delimiter := ';';

      TableNameFK := base.MetaData.Tables.Get(InternalLookup.TableNameFK, False);
      TableName := base.MetaData.Tables.Get(InternalLookup.TableName, False);

      /// //////////

      if not Assigned(TableName) then
        Errori.Add('Tabella Rel. non trovata: ' + InternalLookup.TableName);

      // // KeyField su TableName
      // if Assigned(TableName) then
      // begin
      // // TODO : BASE.LOOKUPS Campi.DelimitedText := InternalLookup.KeyField;
      //
      // for s in Campi do
      // if not TableName.Fields.Exists(s) then
      // Errori.Add('KeyField: campo ' + s + ' non trovato nella tabella ' + InternalLookup.TableName);
      // end;

      /// //////////

      if not Assigned(TableNameFK) then
        Errori.Add('Tabella FK non trovata: ' + InternalLookup.TableNameFK);

      // // SearchFields su TableNameFK
      // if Assigned(TableNameFK) then
      // begin
      // // TODO : BASE.LOOKUPS Campi.DelimitedText := InternalLookup.SearchFields;
      //
      // for s in Campi do
      // if not TableNameFK.Fields.Exists(s) then
      // Errori.Add('SearchFields: campo ' + s + ' non trovato nella tabella ' + InternalLookup.TableNameFK);
      // end;

      /// ///////////////////////////////////////////

      if Errori.Count = 0 then
        ConfirmOk('Nessun problema rilevato.')
      else
        ConfirmOk(Errori.text);

    finally
      FreeAndNil(Campi);
    end;
  finally
    FreeAndNil(Errori);
  end;
end;

procedure TzFrameEditor_Lookup.InitLegenda;
begin
  edLegenda.Items.Clear;

  edLegenda.Items.Add('');

  edLegenda.ReadOnly := True;
end;

procedure TzFrameEditor_Lookup.memoMappingsDblClick(Sender: TObject);
var
  s: String;
begin
  inherited;

  if memoMappings.CaretPos.Y < 0 then
    Exit;

  s := memoMappings.Lines[memoMappings.CaretPos.Y];

  if InputQuery('', 'Riga:', s) then
    memoMappings.Lines[memoMappings.CaretPos.Y] := s;
end;

procedure TzFrameEditor_Lookup.memoMappingsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited;
  Accept := (Source = lbSource) or ((Source is TDragControlObject) and (TDragControlObject(Source).Control = lbSource));
end;

procedure TzFrameEditor_Lookup.memoMappingsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i: Integer;
  s: String;
begin
  inherited;

  for i := 0 to lbSource.Items.Count - 1 do
    if lbSource.Selected[i] then
    begin
      s := lbSource.Items[i] + '=' + lbSource.Items[i];
      memoMappings.Lines.Append(s);
    end;
end;

end.
