unit frmNuovaLookup;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  dxForms,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxClasses,
  dxLayoutContainer,
  dxLayoutControl,
  OkCancel,
  dxLayoutcxEditAdapters,
  cxContainer,
  cxEdit,
  cxTextEdit,
  cxCustomListBox,
  cxListBox,
  Vcl.ComCtrls,
  cxTreeView,
  dxLayoutLookAndFeels,
  System.ImageList,
  Vcl.ImgList,
  cxImageList,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  dxLayoutControlAdapters,
  Vcl.Menus,
  Vcl.StdCtrls,
  cxButtons,
  System.Actions,
  Vcl.ActnList,
  dxBar;

type
  TFormNuovaLookup = class(TdxForm)
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    edLookupName: TcxTextEdit;
    dxLayoutItemLookupName: TdxLayoutItem;
    treeLookups: TcxTreeList;
    dxLayoutItemFK: TdxLayoutItem;
    treeMeta: TcxTreeList;
    dxLayoutItemTreeMeta: TdxLayoutItem;
    dxLayoutEmptySpaceItem: TdxLayoutEmptySpaceItem;
    dxLayoutLookAndFeelList: TdxLayoutLookAndFeelList;
    dxLayoutSkinLookAndFeel: TdxLayoutSkinLookAndFeel;
    cxImageList: TcxImageList;
    treeMetaColumn: TcxTreeListColumn;
    dxLayoutEmptySpaceItem1: TdxLayoutEmptySpaceItem;
    dxLayoutSeparatorItem1: TdxLayoutSeparatorItem;
    dxLayoutGroupMain: TdxLayoutGroup;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    dxLayoutItemOk: TdxLayoutItem;
    dxLayoutItemCancel: TdxLayoutItem;
    dxLayoutGroupBottom: TdxLayoutGroup;
    treeLookupsColumn: TcxTreeListColumn;
    ActionList: TActionList;
    Duplica: TAction;
    Elimina: TAction;
    Sistema: TAction;
    dxBarPopupMenu: TdxBarPopupMenu;
    dxBarManager: TdxBarManager;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    ModificaLookup: TAction;
    dxBarButton4: TdxBarButton;
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure DuplicaExecute(Sender: TObject);
    procedure SistemaExecute(Sender: TObject);
    procedure treeLookupsDblClick(Sender: TObject);
    procedure treeMetaDblClick(Sender: TObject);
    procedure edLookupNamePropertiesEditValueChanged(Sender: TObject);
    procedure EliminaExecute(Sender: TObject);
    procedure ModificaLookupExecute(Sender: TObject);
  private

    function GetSelected(tree: TcxTreeList; RequiredLevel: integer): string;
    function SelectedLookup: string;
    function SelectedFK: string;
  private
    procedure FillLookups;
    procedure FillMetaData;
  public
    constructor Create(aOwner: TComponent); override;

    function GetLookupName(out Lookup: string): Boolean;
  end;

function GetNewLookupName(out Lookup: string): Boolean;

implementation

uses
  zdx,
  zSystem,
  zMetadata,
  zz.base.editor._form,
  zMsg;
{$R *.dfm}
{ TFormNuovaLookup }

function GetNewLookupName(out Lookup: string): Boolean;
var
  FormNuovaLookup: TFormNuovaLookup;
begin
  Application.CreateForm(TFormNuovaLookup, FormNuovaLookup);
  try
    result := FormNuovaLookup.GetLookupName(Lookup);
  finally
    FreeAndNil(FormNuovaLookup);
  end;
end;

constructor TFormNuovaLookup.Create(aOwner: TComponent);
begin
  inherited;
  dxLayoutGroupMain.ItemIndex := 0;

  edLookupName.Text := '';
  dx.InitLayoutControl(dxLayoutControl);
  dxLayoutControl.LookAndFeel := dxLayoutSkinLookAndFeel;
  dxLayoutControl.LayoutLookAndFeel := dxLayoutSkinLookAndFeel;
  dxLayoutControl.OptionsImage.Images := cxImageList;

  dx.InitTreeList(treeLookups, true);
  treeLookups.Images := cxImageList;

  dx.InitTreeList(treeMeta, true);
  treeMeta.Images := cxImageList;

  FillLookups;
  FillMetaData;
end;

function TFormNuovaLookup.GetLookupName(out Lookup: string): Boolean;
begin

  result := ShowModal = mrOk;

  if result then
  begin
    Lookup := edLookupName.Text;
  end;
end;

procedure TFormNuovaLookup.FillMetaData;
var
  table: TzmdTable;
  fk: TzmdForeignKey;
  master, node: TcxTreeListNode;
begin
  treeMeta.BeginUpdate;
  try
    treeMeta.Clear;

    for table in base.MetaData.Tables do
      if table.ForeignKeys.Count > 0 then
      begin
        master := treeMeta.AddChild(nil);
        master.Texts[0] := table.Name;
        master.ImageIndex := 0;

        for fk in table.ForeignKeys do
        begin
          node := treeMeta.AddChild(master);
          node.Texts[0] := fk.Name;
          node.ImageIndex := 1;
        end
      end;
  finally
    treeMeta.EndUpdate;
  end;
end;

procedure TFormNuovaLookup.FillLookups;
var
  Lookup: TzLookup;
  node: TcxTreeListNode;
begin

  treeLookups.BeginUpdate;
  try
    treeLookups.Clear;

    for Lookup in base.zLookups do
    begin
      node := treeLookups.AddChild(nil);
      node.Texts[0] := Lookup.Name;
      node.ImageIndex := 5;
    end;
  finally
    treeLookups.EndUpdate;
  end;
end;

procedure TFormNuovaLookup.treeLookupsDblClick(Sender: TObject);
begin
  edLookupName.Text := SelectedLookup;
end;

procedure TFormNuovaLookup.treeMetaDblClick(Sender: TObject);
begin
  edLookupName.Text := SelectedFK;
end;

function TFormNuovaLookup.SelectedFK: string;
begin
  result := GetSelected(treeMeta, 1);
end;

function TFormNuovaLookup.SelectedLookup: string;
begin
  result := GetSelected(treeLookups, 0);
end;

function TFormNuovaLookup.GetSelected(tree: TcxTreeList; RequiredLevel: integer): string;
var
  node: TcxTreeListNode;
begin
  result := '';

  if tree.SelectionCount <> 1 then
    exit;

  node := tree.Selections[0];

  if assigned(node) then
    if node.Level = RequiredLevel then
      result := node.Texts[0];
end;

procedure TFormNuovaLookup.edLookupNamePropertiesEditValueChanged(Sender: TObject);
begin
  btnOk.Enabled := edLookupName.Text <> '';
end;

procedure TFormNuovaLookup.SistemaExecute(Sender: TObject);
begin

  if base.ShowSystemForm then
  begin
    FillLookups;
    FillMetaData;
  end;
end;

procedure TFormNuovaLookup.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  ModificaLookup.Visible := dxLayoutGroupMain.ItemIndex = 0;
  Duplica.Visible := dxLayoutGroupMain.ItemIndex = 0;
  Elimina.Visible := dxLayoutGroupMain.ItemIndex = 0;
end;

procedure TFormNuovaLookup.EliminaExecute(Sender: TObject);
var
  idx: integer;
  s: string;
  zLookup: TzLookup;
begin
  s := SelectedLookup;

  if not s.IsEmpty then
    if ConfirmYesNo('Si desidera eliminare il lookup selezionato?') then
    begin
      zLookup := base.zLookups.Get(s, false);

      if assigned(zLookup) then
      begin
        idx := base.zLookups.FindItemID(zLookup.ID).Index;
        base.zLookups.Delete(idx);
        base.SaveZip(csLookups, 'Nuovo Lookup');
        FillLookups;
      end;
    end;
end;

procedure TFormNuovaLookup.DuplicaExecute(Sender: TObject);
var
  newName: String;
  oldLookup, newLookup: TzLookup;
  DataSet_Obj: TzDataSet;
  DbCard_Obj: TzDbCardProps;
  DbView_Obj: TzDbViewProps;
begin
  newName := '';

  oldLookup := base.zLookups.Get(SelectedLookup, false);

  if assigned(oldLookup) then
    if InputQuery('Nuovo Lookup', 'Nuovo Lookup', newName) then
    begin
      newLookup := base.zLookups.Add;
      newLookup.Assign(oldLookup);
      newLookup.Name := newName;
      //
      // DataSet_Obj
      if assigned(oldLookup.DataSet_Obj) then
      begin
        DataSet_Obj := base.zDataSets.Add;
        DataSet_Obj.Assign(oldLookup.DataSet_Obj);
        DataSet_Obj.Name := newName;
        newLookup.DataSet_Obj := DataSet_Obj; // assegna anche il nome
      end
      else
        newLookup.DataSet := newName;
      //
      // DbCard_Obj
      if assigned(oldLookup.DbCard_Obj) then
      begin
        DbCard_Obj := base.zDbCards.Add;
        DbCard_Obj.Assign(oldLookup.DbCard_Obj);
        DbCard_Obj.Name := newName;
        DbCard_Obj.DataSet := newName;
        newLookup.DbCard_Obj := DbCard_Obj;
      end
      else
        newLookup.DataSet := newName;
      //
      // DbView_Obj
      if assigned(oldLookup.DbView_Obj) then
      begin
        DbView_Obj := base.zDbViews.Add;
        DbView_Obj.Assign(oldLookup.DbView_Obj);
        DbView_Obj.Name := newName;
        DbView_Obj.DataSet := newName;
        newLookup.DbView_Obj := DbView_Obj;
      end
      else
        newLookup.DataSet := newName;
      //
      // Salva e ricarica
      base.SaveZip(csAll, 'Nuovo Lookup');
      FillLookups;
    end;
end;

procedure TFormNuovaLookup.ModificaLookupExecute(Sender: TObject);
var
  Lookup, tmpLookup: TzLookup;
begin
  Lookup := base.zLookups.Get(SelectedLookup, false);

  if not assigned(Lookup) then
    exit;

  tmpLookup := TzLookup.Create(nil);
  try
    tmpLookup.Assign(Lookup);

    if Edit_CollectionItem(base, tmpLookup) then
    begin
      base.zLookups.SaveLookup(tmpLookup);
      base.SaveZip(csLookups, 'Modifica Lookup');
      FillLookups;
    end;
  finally
    FreeAndNil(tmpLookup);
  end;
end;

end.
