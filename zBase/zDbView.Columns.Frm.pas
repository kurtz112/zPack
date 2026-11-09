unit zDbView.Columns.Frm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.Menus,
  vcl.ImgList,
  vcl.ActnList,
  vcl.StdCtrls,
  vcl.CheckLst,
  OkCancel,
  zDbView,
  vcl.ExtCtrls,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxCheckListBox,
  dxBar,
  cxClasses,
  cxEdit,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  System.ImageList,
  System.Actions,
  zSystem,
  cxCustomListBox,
  cxTextEdit,
  cxBarEditItem,
  cxImageList,
  dxOfficeSearchBox,
  cxDropDownEdit,
  cxCheckBox, dxUIAClasses;

type
  TFormDbViewColumns = class(TForm)
    ActionList: TActionList;
    Mostra: TAction;
    Nascondi: TAction;
    MoveUp: TAction;
    MoveDown: TAction;
    ListBox: TcxCheckListBox;
    dxBarManager: TdxBarManager;
    dxBarButtonMostra: TdxBarButton;
    dxBarButtonNascondi: TdxBarButton;
    dxBarButtonMoveUp: TdxBarButton;
    dxBarButtonMoveDown: TdxBarButton;
    dxBarbar: TdxBar;
    dxTBMenu: TdxBarPopupMenu;
    OkCancel: TOkCancel;
    SelezionaTutto: TAction;
    dxBarButton1: TdxBarButton;
    dxBarEdit1: TdxBarEdit;
    cxBarEditItemSearch: TcxBarEditItem;
    dxBarButton2: TdxBarButton;
    procedure FormDestroy(Sender: TObject);
    procedure MostraExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NascondiExecute(Sender: TObject);
    procedure ListBoxDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MoveUpExecute(Sender: TObject);
    procedure MoveDownExecute(Sender: TObject);
    procedure OkCancelApply(Sender: TObject);
    procedure SelezionaTuttoExecute(Sender: TObject);
    procedure cxBarEditItemSearchPropertiesChange(Sender: TObject);
  private
    SelectedList: TList<TcxCheckListBoxItem>;
    procedure FillSelectedList(const Ascending: Boolean);
    procedure ApplySelected;
  protected
    zDbView: TzDbView;
    procedure AssignColumnsToProps;
    procedure FillListBox;
  public
    function Edit(azDbView: TzDbView): Boolean;
  end;

var
  FormDbViewColumns: TFormDbViewColumns;

function EditDbViewColumns(zDbView: TzDbView): Boolean;

implementation

uses
  DB,
  Math,
  zMsg,
  zDX;
{$R *.dfm}

function EditDbViewColumns(zDbView: TzDbView): Boolean;
begin
  Application.CreateForm(TFormDbViewColumns, FormDbViewColumns);
  try
    Result := FormDbViewColumns.Edit(zDbView);
  finally
    FreeAndNil(FormDbViewColumns);
  end;
end;

procedure TFormDbViewColumns.ApplySelected;
var
  i: Integer;
  item: TcxCheckListBoxItem;
begin
  // clear selection
  for i := 0 to ListBox.Items.Count - 1 do
    ListBox.Selected[i] := False;

  for item in SelectedList do
    ListBox.Selected[item.Index] := True;
end;

function TFormDbViewColumns.Edit(azDbView: TzDbView): Boolean;
var
  barH: Integer;
  idx: Integer;
  FieldName: string;
  Field: TField;
  ListBoxHeight: Integer;
  W: Integer;
  Margin: Integer;
begin
  zDbView := azDbView;

  if not Assigned(zDbView) then
    Exit;

  if not Assigned(zDbView.zDataSet) then
    Exit;

  FillListBox;

  Margin := 0;
  if ListBox.AlignWithMargins then
    Margin := ListBox.Margins.Top + ListBox.Margins.Bottom;

  ListBoxHeight := ListBox.GetHeight(ListBox.Items.Count + 1); // (ListBox.ItemHeight * (ListBox.Items.Count + 1)) + TBDock.Height + Margin);

  if Assigned(dxBarbar.Control) then
    barH := dxBarbar.Control.Height
  else
    barH := 21;

  Self.ClientHeight := Min(Screen.Height div 2, 20 + OkCancel.Height + ListBoxHeight + barH + Margin);

  ActiveControl := ListBox;

  Result := ShowModal = mrOk;

  if Result then
    AssignColumnsToProps;
end;

procedure TFormDbViewColumns.MostraExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ListBox.Items.Count - 1 do
    if ListBox.Selected[i] then
      ListBox.Items[i].Checked := True;
end;

procedure TFormDbViewColumns.FormCreate(Sender: TObject);
begin
  dx.AgganciaImmagini(Self);
  ListBox.InnerCheckListBox.MultiSelect := True;
  SelectedList := TList<TcxCheckListBoxItem>.Create;
end;

procedure TFormDbViewColumns.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SelectedList);
end;

procedure TFormDbViewColumns.NascondiExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ListBox.Items.Count - 1 do
    if ListBox.Selected[i] then
      ListBox.Items[i].Checked := False;
end;

procedure TFormDbViewColumns.AssignColumnsToProps;
var
  i: Integer;
  zDbViewProps: TzDbViewProps;
  column: TzColumn;
begin
  zDbViewProps := zDbView.GetDbViewProps;

  for i := 0 to ListBox.Items.Count - 1 do
  begin
    column := zDbViewProps.Columns.Get(TField(ListBox.Items.Objects[i]).FieldName, False);
    if Assigned(column) then
    begin
      column.Visible := ListBox.Items[i].Checked;
      column.Index := i;
    end;
  end;

  zDbView.ReloadColumnProps;
end;

procedure TFormDbViewColumns.ListBoxDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = ListBox;
end;

procedure TFormDbViewColumns.ListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  pt: TPoint;
  NewIdx: Integer;
  item: TcxCheckListBoxItem;
begin
  pt.X := X;
  pt.Y := Y;

  NewIdx := ListBox.itemAtPos(pt, True);

  FillSelectedList(False);

  for item in SelectedList do
    item.Index := NewIdx;

  ApplySelected;
end;

procedure TFormDbViewColumns.MoveUpExecute(Sender: TObject);
var
  item: TcxCheckListBoxItem;
begin
  FillSelectedList(True);

  for item in SelectedList do
    if item.Index > 0 then
      item.Index := item.Index - 1;

  ApplySelected;
end;

procedure TFormDbViewColumns.MoveDownExecute(Sender: TObject);
var
  item: TcxCheckListBoxItem;
begin
  FillSelectedList(False);

  for item in SelectedList do
    if item.Index < ListBox.Count - 1 then
      item.Index := item.Index + 1;

  ApplySelected;
end;

procedure TFormDbViewColumns.FillListBox;
var
  Field: TField;
  item: TcxCheckListBoxItem;
  column: TzColumn;
  cxTextEditProperties: TcxTextEditProperties;
begin
  ListBox.Clear;
  cxTextEditProperties := TcxTextEditProperties(cxBarEditItemSearch.Properties);
  cxTextEditProperties.LookupItems.Clear;

  for column in zDbView.GetDbViewProps.Columns do
  begin
    zDbView.DataController.TryGetField(column.Name, Field);
    if not Assigned(Field) then
      Continue;

    item := ListBox.Items.Add;
    item.Text := column.Caption; // Mantis 977 - era: Field.DisplayLabel;
    item.ItemObject := Field;
    item.Checked := column.Visible;

    cxTextEditProperties.LookupItems.Add(Field.DisplayLabel);
  end;
end;

procedure TFormDbViewColumns.ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    ListBox.BeginDrag(False);
end;

procedure TFormDbViewColumns.ListBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx: Integer;
begin
  if ListBox.Dragging then
    Exit;

  idx := ListBox.itemAtPos(Point(X, Y), True);
  if (idx >= 0) then
    ListBox.Items[idx].Checked := not ListBox.Items[idx].Checked;
end;

procedure TFormDbViewColumns.OkCancelApply(Sender: TObject);
begin
  AssignColumnsToProps;
end;

procedure TFormDbViewColumns.SelezionaTuttoExecute(Sender: TObject);
var
  i: Integer;
begin

  for i := 0 to ListBox.Items.Count - 1 do
    ListBox.Selected[i] := True;
end;

procedure TFormDbViewColumns.cxBarEditItemSearchPropertiesChange(Sender: TObject);
var
  i: Integer;
  s: string;
begin

  s := VarToStr(cxBarEditItemSearch.CurEditValue);

  if s = '' then
    Exit;

  s := s.ToUpper;

  for i := 0 to ListBox.Items.Count - 1 do
    if pos(s, UpperCase(ListBox.Items[i].Text)) > 0 then
    begin
      ListBox.ItemIndex := i;
      Break;
    end;
end;

procedure TFormDbViewColumns.FillSelectedList(const Ascending: Boolean);
var
  i: Integer;
begin
  SelectedList.Clear;

  if Ascending then
  begin
    for i := 0 to ListBox.Items.Count - 1 do
      if ListBox.Selected[i] then
        SelectedList.Add(ListBox.Items[i]);
  end
  else
  begin
    for i := ListBox.Items.Count - 1 downto 0 do
      if ListBox.Selected[i] then
        SelectedList.Add(ListBox.Items[i]);
  end;
end;

end.
