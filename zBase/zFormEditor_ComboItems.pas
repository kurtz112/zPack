unit zFormEditor_ComboItems;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  OkCancel,
  zSystem,
  vcl.StdCtrls,
  vcl.Mask,
  vcl.ExtCtrls,
  vcl.ToolWin,
  vcl.ComCtrls,
  vcl.ActnList,
  vcl.Menus,
  System.Actions,
  System.ImageList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxTextEdit,
  cxMaskEdit,
  cxSpinEdit,
  cxDropDownEdit,
  cxImageComboBox,
  cxImageList,
  vcl.ImgList,
  cxListView,
  cxCustomListBox,
  cxListBox,
  cxGeometry,
  dxFramedControl,
  cxSplitter,
  cxMemo,
  dxPanel;

type
  TzFormEditorComboItems = class(TForm)
    OkCancel: TOkCancel;
    Panel1: TPanel;
    ImageListView: TcxListView;
    Panel2: TPanel;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    edDisplayValue: TcxTextEdit;
    edStoredValue: TcxTextEdit;
    edIndent: TcxSpinEdit;
    edImageIndex: TcxImageComboBox;
    ImageList16: TImageList;
    PopupMenu: TPopupMenu;
    ActionList: TActionList;
    ImageList: TImageList;
    New: TAction;
    Delete: TAction;
    MoveUp: TAction;
    MoveDown: TAction;
    Clear: TAction;
    New1: TMenuItem;
    Delete1: TMenuItem;
    MoveUp1: TMenuItem;
    N1: TMenuItem;
    MoveDown1: TMenuItem;
    N2: TMenuItem;
    Clear1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    PickList: TAction;
    N3: TMenuItem;
    PickList1: TMenuItem;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ImageList24: TImageList;
    dxPanel: TdxPanel;
    ListBox: TcxListBox;
    memoDescription: TcxMemo;
    cxSplitter: TcxSplitter;
    procedure ClearExecute(Sender: TObject);
    procedure DeleteExecute(Sender: TObject);
    procedure edImageIndexChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ListBoxClick(Sender: TObject);
    procedure ListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure oldListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListBoxDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure memoDescriptionDblClick(Sender: TObject);
    procedure MoveDownExecute(Sender: TObject);
    procedure MoveUpExecute(Sender: TObject);
    procedure NewExecute(Sender: TObject);
    procedure PickListExecute(Sender: TObject);
    procedure edImageIndexPropertiesEditValueChanged(Sender: TObject);
  private
    OldItemIndex: Integer;
    SkipChanges: Boolean;
    Items: TzPickValues;
    zSystem: TzSystem;
    ImmaginiGrandi: TcxImageList;
    procedure Item2Controls;
    procedure Controls2Item;
    procedure Init;
    procedure ClearControls;
    procedure CreateColumns;
    procedure FillListBox;
    procedure FillListView;
    procedure DisplayItem(ItemIndex: Integer);
    procedure MoveItem(Delta: Integer);
    procedure ApplicaDescrizioneToPickList;
  public
    function Edit: Boolean;
  end;

function EditComboItems(zSystem: TzSystem; const Description: string; var Items: TzPickValues): Boolean;

implementation

uses
  zDX,
  zMsg;
{$R *.dfm}

const
  Tab = #9;

function EditComboItems(zSystem: TzSystem; const Description: string; var Items: TzPickValues): Boolean;
var
  zFormEditorComboItems: TzFormEditorComboItems;
begin
  result := False;

  Application.CreateForm(TzFormEditorComboItems, zFormEditorComboItems);
  try
    zFormEditorComboItems.zSystem := zSystem;
    zFormEditorComboItems.Items.Assign(Items);
    zFormEditorComboItems.memoDescription.lines.text := Description;

    result := zFormEditorComboItems.Edit;

    if result then
      Items.Assign(zFormEditorComboItems.Items);
  finally
    FreeAndNil(zFormEditorComboItems);
  end;
end;

procedure TzFormEditorComboItems.FillListBox;
var
  I: Integer;
begin
  OldItemIndex := -1;

  ListBox.Items.BeginUpdate;
  try
    ListBox.Clear;
    // CreateColumns;

    for I := 0 to Items.Count - 1 do
      DisplayItem(I);

    if Items.Count = 0 then
    begin
      New.Execute;
      ListBox.ItemIndex := 0;
    end
    else
    begin
      ListBox.ItemIndex := 0;
      Item2Controls;
    end;
  finally
    ListBox.Items.EndUpdate;
  end;
end;

procedure TzFormEditorComboItems.FormCreate(Sender: TObject);
begin
  OldItemIndex := -1;
  SkipChanges := False;
  Items := TzPickValues.Create(TzPickValue, 'PickValues', -1, nil);
  Items.Sorted := False;
end;

procedure TzFormEditorComboItems.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Items);
end;

procedure TzFormEditorComboItems.ClearControls;
begin
  OldItemIndex := -1;
    edDisplayValue.text := '';
  edStoredValue.text := '';
  edIndent.Value := -1;
  edImageIndex.Clear;
end;

procedure TzFormEditorComboItems.ClearExecute(Sender: TObject);
begin
  if not ConfirmYesNo('Elimino tutti i valori?') then
    Exit;

  Items.Clear;
  ListBox.Clear;
  ClearControls;
  FillListBox;
end;

procedure TzFormEditorComboItems.DeleteExecute(Sender: TObject);
var
  idx: Integer;
begin
  idx := ListBox.ItemIndex;
  if idx = -1 then
    Exit;

  ListBox.Items.Delete(idx);
  Items[idx].Free;
  ClearControls;
end;

function TzFormEditorComboItems.Edit: Boolean;
begin
  result := False;
  Init;

  PopupParent := Screen.ActiveForm;

  result := ShowModal = mrOk;
end;

procedure TzFormEditorComboItems.Item2Controls;
var
  idx: Integer;
begin
  if SkipChanges then
    Exit;

  SkipChanges := True;
  try
    ClearControls;

    idx := ListBox.ItemIndex;
    if idx = -1 then
      Exit;

    edDisplayValue.text := Items[idx].Name;
    edStoredValue.text := Items[idx].Value;
    edIndent.Value := Items[idx].Indent;
    edImageIndex.ItemIndex := Items[idx].ImageIndex;

    ImageListView.ItemIndex := Items[idx].ImageIndex;
    // ImageList.ScrollIntoView(ImageList.SelectedIndex);
    OldItemIndex := idx;
  finally
    SkipChanges := False;
  end;
end;

procedure TzFormEditorComboItems.Controls2Item;
var
  idx: Integer;
begin

  if SkipChanges then
    Exit;

  idx := OldItemIndex;
  if idx = -1 then
  begin
    ClearControls;
    Exit;
  end;

  Items[idx].Name := edDisplayValue.text;
  Items[idx].Value := edStoredValue.text;
  Items[idx].Indent := Trunc(edIndent.Value);
  Items[idx].ImageIndex := ImageListView.ItemIndex;
  // Items[idx].ImageIndex := edImageIndex.Value; lo segna il comp successivo

  DisplayItem(idx);
end;

procedure TzFormEditorComboItems.ListBoxClick(Sender: TObject);
begin
  Controls2Item;
  Item2Controls;
end;

procedure TzFormEditorComboItems.DisplayItem(ItemIndex: Integer);
var
  s: string;
begin
  s := Items[ItemIndex].Name;
  {
    s := Items[ItemIndex].Name + tab +
    Items[ItemIndex].Value + tab +
    IntToStr(Items[ItemIndex].Indent) + tab +
    IntToStr(Items[ItemIndex].ImageIndex) + tab;
  }

  if ItemIndex > ListBox.Items.Count - 1 then
    ListBox.Items.Add(s)
  else
    ListBox.Items[ItemIndex] := s;
end;

procedure TzFormEditorComboItems.ListBoxDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = ListBox;
end;

procedure TzFormEditorComboItems.NewExecute(Sender: TObject);
begin
  ClearControls;
  Items.Add;
  ListBox.Items.Add('');
  ListBox.ItemIndex := ListBox.Items.Count - 1;
  Item2Controls;
  ActiveControl := edDisplayValue;
end;

procedure TzFormEditorComboItems.oldListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  iTemp: Integer;
  ptTemp: TPoint;
  szTemp: string;
begin
  { change the x,y coordinates into a TPoint record }
  ptTemp.X := X;
  ptTemp.Y := Y;

  { Use a while loop instead of a for loop due to items possible being removed
    from listboxes this prevents an out of bounds exception }
  iTemp := 0;
  while iTemp <= TListBox(Source).Items.Count - 1 do
  begin
    { look for the selected items as these are the ones we wish to move }
    if TListBox(Source).Selected[iTemp] then
    begin
      { use a with as to make code easier to read }
      with Sender as TListBox do
      begin
        { need to use a temporary variable as when the item is deleted the
          indexing will change }
        szTemp := TListBox(Source).Items[iTemp];

        { delete the item that is being dragged }
        TListBox(Source).Items.Delete(iTemp);

        { insert the item into the correct position in the listbox that it
          was dropped on }
        Items.Insert(itemAtPos(ptTemp, True), szTemp);
      end;
    end;
    Inc(iTemp);
  end;
end;

procedure TzFormEditorComboItems.CreateColumns;
const
  // The maximum number of Tabs
  // Die Anzahl der maximal aufretenen Tabs eintragen
  MAX_TABS = 4;
  Tab = #9;
var
  Tabulators: array [0 .. MAX_TABS - 1] of Integer;
  w: Integer;
begin
  w := ListBox.ClientWidth div MAX_TABS + 1;

  Tabulators[0] := ListBox.ClientWidth - (w * MAX_TABS);
  Tabulators[1] := w;
  Tabulators[2] := w;
  Tabulators[3] := w;
  ListBox.TabWidth := 1;
  SendMessage(ListBox.Handle, LB_SETTABSTOPS, MAX_TABS, LPARAM(@Tabulators));
end;

procedure TzFormEditorComboItems.edImageIndexChange(Sender: TObject);
begin
  if SkipChanges then
    Exit;

  if ImageListView.ItemIndex <> edImageIndex.ItemIndex then
    ImageListView.ItemIndex := edImageIndex.ItemIndex;

  Controls2Item;
end;

procedure TzFormEditorComboItems.edImageIndexPropertiesEditValueChanged(Sender: TObject);
begin

  if SkipChanges then
    Exit;

  Controls2Item;
end;

procedure TzFormEditorComboItems.ListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  idx: Integer;
  NewIndex: Integer;
  pt: TPoint;
begin
  idx := ListBox.ItemIndex;
  if idx = -1 then
    Exit;

  pt.X := X;
  pt.Y := Y;

  NewIndex := ListBox.itemAtPos(pt, False);

  MoveItem(NewIndex - idx);
end;

procedure TzFormEditorComboItems.MoveUpExecute(Sender: TObject);
begin
  MoveItem(-1);
end;

procedure TzFormEditorComboItems.MoveDownExecute(Sender: TObject);
begin
  MoveItem(+1);
end;

procedure TzFormEditorComboItems.MoveItem(Delta: Integer);
var
  idx: Integer;
begin
  SkipChanges := True;
  try
    ClearControls;

    idx := ListBox.ItemIndex;
    if ((idx + Delta) in [0 .. ListBox.Items.Count - 1]) then
    begin
      ListBox.Items.Move(idx, idx + Delta);
      Items[idx].Index := Items[idx].Index + Delta;
    end;
    ListBox.ItemIndex := idx + Delta;
  finally
    SkipChanges := False;
  end;
  Item2Controls;
end;

procedure TzFormEditorComboItems.ImageListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin

  if SkipChanges then
    Exit;

  Controls2Item;

  if edImageIndex.ItemIndex <> Item.Index then
    edImageIndex.ItemIndex := Item.Index;
end;

procedure TzFormEditorComboItems.FillListView;
var
  I: Integer;
  Item: TListItem;
begin
  ImageListView.Items.BeginUpdate;
  try
    ImageListView.Clear;
    for I := 0 to dx.Immagini.Count - 1 do
    begin
      Item := ImageListView.Items.Add;
      Item.Caption := IntToStr(I);
      Item.ImageIndex := I;
    end;
  finally
    ImageListView.Items.EndUpdate;
  end;
end;

procedure TzFormEditorComboItems.Init;
var
  Item: TcxImageComboBoxItem;
  I: Integer;
begin
  edImageIndex.Properties.Items.Clear;
  ClearControls;

  if not Assigned(zSystem) then
    Exit;

  // Le icone delle picklist sono indici di dx.Immagini, la lista unica di zPack.
  // La vista a icone grandi ne usa una copia a 32 px: CopyImages conserva le SVG
  // e le ridisegna alla misura della lista, mentre una TImageList VCL copierebbe
  // solo le bitmap a 16.
  if not Assigned(ImmaginiGrandi) then
  begin
    ImmaginiGrandi := TcxImageList.Create(Self);
    ImmaginiGrandi.Width := 32;
    ImmaginiGrandi.Height := 32;
    ImmaginiGrandi.CopyImages(dx.Immagini);
  end;

  edImageIndex.Properties.Images := dx.Immagini;
  ImageListView.SmallImages := dx.Immagini;
  ImageListView.LargeImages := ImmaginiGrandi;
  ImageListView.StateImages := dx.Immagini;

  for I := 0 to dx.Immagini.Count - 1 do
  begin
    Item := edImageIndex.Properties.Items.Add;
    Item.Description := IntToStr(I);
    Item.Value := IntToStr(I);
    Item.ImageIndex := I;
  end;

  FillListView;
  FillListBox;
end;

procedure TzFormEditorComboItems.PickListExecute(Sender: TObject);
var
  I: Integer;
  Item: TzPickValue;
  StringList: TStringList;
begin

  StringList := TStringList.Create;
  try
    for I := 0 to Items.Count - 1 do
      if ((Items[I].Name <> '') or (Items[I].Value <> '')) then
        StringList.Add(Items[I].Name + '=' + Items[I].Value);

    if InputMemo('PickList', 'PickList', StringList) then
    begin
      Items.Clear;
      for I := 0 to StringList.Count - 1 do
        if trim(StringList[I]) <> '' then
        begin
          Item := Items.Add;
          Item.Name := trim(StringList.Names[I]);
          Item.Value := trim(StringList.ValueFromIndex[I]);
        end;
      FillListBox;
    end;
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzFormEditorComboItems.memoDescriptionDblClick(Sender: TObject);
begin
  ApplicaDescrizioneToPickList;
end;

procedure TzFormEditorComboItems.ApplicaDescrizioneToPickList;
var
  I: Integer;
  Item: TzPickValue;
  StringList: TStringList;
begin

  if memoDescription.lines.text.IsEmpty then
    Exit;

  if not ConfirmOkCancel('Applicare la descrizione del domain come elementi della picklist?') then
    Exit;

  StringList := TStringList.Create;
  try
    Items.Clear;

    StringList.text := memoDescription.lines.text;
    for I := 0 to StringList.Count - 1 do
      if trim(StringList[I]) <> '' then
      begin
        Item := Items.Add;
        Item.Name := trim(StringList.Names[I]);
        Item.Value := trim(StringList.ValueFromIndex[I]);
      end;

    FillListBox;
  finally
    FreeAndNil(StringList);
  end;
end;

end.

  zSystem

  procedure TForm1.ListBox1DrawItem
(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);

var
  Bitmap: TBitmap;

begin
  with ListBox1 do
  begin
    Canvas.FillRect(Rect);
    if Items.Objects[Index] <> nil then
    begin
      Bitmap := Items.Objects[Index] as TBitmap;
      Canvas.BrushCopy(Bounds(Rect.Left + 2, Rect.Top + 2, Bitmap.Width, Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width, Bitmap.Height), Bitmap.Canvas.Pixels[0, Bitmap.Height - 1]);
    end;
    Rect.Left := Rect.Left + Bitmap.Width + 4;
    Rect.Bottom := Rect.Top + Bitmap.Height + 4;
    CenterText(Canvas, Rect, Items.Strings[Index]);
  end;
end;
