unit zz.FMX;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Rtti,
  System.ImageList,
  Data.DB,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.Effects,
  FMX.Filter.Effects,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.ListBox,
  FMX.SearchBox,
  FMX.Grid;

type
  TComponentHelper = class helper for TComponent
  public
    procedure ForEach<T: TComponent>(proc: TProc<T>);
  end;

  TControlHelper = class helper for TControl
  public
    procedure ForEach<T: TControl>(proc: TProc<T>);
    procedure InitControl; virtual;
    procedure InitMargins(const Left: Single = 3; const Top: Single = 5; const Right: Single = 3; const Bottom: Single = 5); virtual;
  end;

  TListViewHelper = class helper for TListView
  private
    procedure InitListView;
  public
    procedure Fill(proc: TProc);
    function Add: TListViewItem; overload;
    function Add(proc: TProc): TListViewItem; overload;
    function Add(proc: TProc<TListViewItem>): TListViewItem; overload;

    procedure ApplyDefaultStyle;

    function GetSearchBox: TSearchBox;
    procedure ClearSearchBox;
  end;

  TListBoxHelper = class helper for TListBox
  private
    procedure InitListBox;
  public
    procedure Fill(proc: TProc);
    function Add: TListBoxItem; overload;
    function Add(proc: TProc): TListBoxItem; overload;
    function Add(proc: TProc<TListBoxItem>): TListBoxItem; overload;

    procedure SetSelectable(const Selectable: boolean);
    procedure AutoHeight;

    procedure ApplyDefaultStyle;
  end;

  TComboBoxHelper = class helper for TComboBox
  private
    procedure InitComboBox;
  public
    procedure Fill(proc: TProc);

    function Add: TListBoxItem; overload;
    function Add(proc: TProc): TListBoxItem; overload;
    function Add(proc: TProc<TListBoxItem>): TListBoxItem; overload;
    function AddEmptyItem: TListBoxItem;
  end;

  TStringGridHelper = class helper for TStringGrid
  private
    procedure InitGrid;
  public
    procedure Fill(proc: TProc);
    procedure AddRow;
  end;

  TButtonHelper = class helper for TButton
  public
    procedure SetInternalMargins;
  end;

implementation

uses
  FMX.Styles,
  FMX.Styles.Objects;

{ TListViewHelper }

procedure TListViewHelper.InitListView;
begin
  Items.Clear;
  AlternatingColors := False;
  CanSwipeDelete := False;
  Transparent := true;
  ItemAppearanceObjects.ItemObjects.Accessory.Visible := False;
end;

function TListViewHelper.Add: TListViewItem;
begin
  result := Items.Add;
end;

function TListViewHelper.Add(proc: TProc<TListViewItem>): TListViewItem;
begin
  result := Add;
  if Assigned(proc) then
    proc(result);
end;

procedure TListViewHelper.ApplyDefaultStyle;
var
  obj: TFmxObject;
begin
  NeedStyleLookup;
  ApplyStyleLookup;

  obj := FindStyleResource('background');

  if Assigned(obj) then
  begin
    if obj is TRectangle then
    begin
      TRectangle(obj).Fill.color := TAlphaColorRec.White;
      TRectangle(obj).Stroke.Kind := TBrushKind.None;
    end
    else
      if obj is TStyleObject then
      begin
        TColorObject(obj).color := TAlphaColorRec.White;
      end
      else
        if obj is TColorObject then
          TColorObject(obj).color := TAlphaColorRec.White;
  end;

  // listViewItem
  obj := FindStyleResource('itembackground');

  if Assigned(obj) then
  begin

    if obj is TRectangle then
    begin
      TRectangle(obj).Fill.color := TAlphaColorRec.White;
      TRectangle(obj).Stroke.Kind := TBrushKind.None;
    end
    else
      if obj is TColorObject then
        TColorObject(obj).color := TAlphaColorRec.White;
  end;

  ApplyStyle;
end;

function TListViewHelper.Add(proc: TProc): TListViewItem;
begin
  result := Add;
  if Assigned(proc) then
    proc;
end;

procedure TListViewHelper.Fill(proc: TProc);
begin
  BeginUpdate;
  try
    Items.Clear;
    ClearSearchBox;

    if Assigned(proc) then
      proc;

    if Items.Count > 0 then
      ItemIndex := 0;
  finally
    EndUpdate;
  end;
end;

procedure TListViewHelper.ClearSearchBox;
var
  SearchBox: TSearchBox;
begin
  SearchBox := GetSearchBox;

  if Assigned(SearchBox) then
    SearchBox.Text := '';
end;

function TListViewHelper.GetSearchBox: TSearchBox;
var
  ctrl: TControl;
begin
  result := nil;

  for ctrl in Self.Controls do
    if ctrl is TSearchBox then
    begin
      result := TSearchBox(ctrl);
      exit;
    end;
end;

{ TListBoxHelper }

procedure TListBoxHelper.InitListBox;
begin
  AlternatingRowBackground := False;
  StyleLookup := 'transparentlistboxstyle';
end;

procedure TListBoxHelper.Fill(proc: TProc);
begin
  BeginUpdate;
  try
    Items.Clear;

    if Assigned(proc) then
      proc;

    if Items.Count > 0 then
      ItemIndex := 0;
  finally
    EndUpdate;
  end;
end;

function TListBoxHelper.Add: TListBoxItem;
begin
  result := TListBoxItem.Create(Self);
  result.Parent := Self;
end;

function TListBoxHelper.Add(proc: TProc): TListBoxItem;
begin
  result := Add;
  if Assigned(proc) then
    proc;
end;

function TListBoxHelper.Add(proc: TProc<TListBoxItem>): TListBoxItem;
begin
  result := Add;
  if Assigned(proc) then
    proc(result);
end;

procedure TListBoxHelper.ApplyDefaultStyle;
var
  obj: TFmxObject;
begin
  inherited;

  obj := FindStyleResource('background');

  if Assigned(obj) then
  begin
    if obj is TRectangle then
    begin
      TRectangle(obj).Fill.color := TAlphaColorRec.White;
      TRectangle(obj).Stroke.Kind := TBrushKind.None;
    end
    else
      if obj is TColorObject then
        TColorObject(obj).color := TAlphaColorRec.White
  end;
end;

procedure TListBoxHelper.SetSelectable(const Selectable: boolean);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    ListItems[I].Selectable := Selectable;
end;

procedure TListBoxHelper.AutoHeight;
var
  I: Integer;
  h: Single;
begin
  inherited;

  h := Margins.Top + Margins.Bottom + 3;

  for I := 0 to Count - 1 do
    h := h + ListItems[I].Height;

  Height := h;
end;

{ TComboBoxHelper }

procedure TComboBoxHelper.InitComboBox;
begin
end;

procedure TComboBoxHelper.Fill(proc: TProc);
begin
  BeginUpdate;
  try
    Clear;

    if Assigned(proc) then
      proc;
  finally
    EndUpdate;
  end;
end;

function TComboBoxHelper.Add: TListBoxItem;
begin
  result := TListBoxItem.Create(Self);
  result.Parent := Self;
  AddObject(result);
end;

function TComboBoxHelper.Add(proc: TProc): TListBoxItem;
begin
  result := Add;
  if Assigned(proc) then
    proc;
end;

function TComboBoxHelper.Add(proc: TProc<TListBoxItem>): TListBoxItem;
begin
  result := Add;
  if Assigned(proc) then
    proc(result);
end;

function TComboBoxHelper.AddEmptyItem: TListBoxItem;
begin
  result := Add;
  result.Index := 0;
  ItemIndex := 0;
end;

{ TStringGridHelper }

procedure TStringGridHelper.InitGrid;
begin
  RowCount := 1;
  Options := [TGridOption.AlternatingRowBackground, TGridOption.ColumnResize, TGridOption.ColLines, TGridOption.RowSelect, TGridOption.AlwaysShowSelection, TGridOption.Tabs, TGridOption.Header,
    TGridOption.AutoDisplacement];
end;

procedure TStringGridHelper.Fill(proc: TProc);
begin
  BeginUpdate;
  try
    model.RowCount := 0;

    if Assigned(proc) then
      proc;

    if model.RowCount > 0 then
      SelectRow(0);
  finally
    EndUpdate;
  end;
end;

procedure TStringGridHelper.AddRow;
begin
  model.RowCount := model.RowCount + 1;
end;

{ TButtonHelper }

procedure TButtonHelper.SetInternalMargins;
const
  w = 80;
var
  m: Integer;
begin
  if TOSVersion.Platform = pfWindows then
    m := 1
  else
    m := 5;

  Margins.Top := m;
  Margins.Left := m;
  Margins.Right := m;
  Margins.Bottom := m;

  Align := TAlignLayout.None;
  Width := w;
  Align := TAlignLayout.FitRight;
end;

{ TComponentHelper }

procedure TComponentHelper.ForEach<T>(proc: TProc<T>);
var
  comp: TComponent;
begin
  assert(Assigned(proc));

  for comp in Self do
    if comp is T then
      proc(T(comp));
end;

{ TControlHelper }

procedure TControlHelper.ForEach<T>(proc: TProc<T>);
var
  ctrl: TControl;
begin
  assert(Assigned(proc));

  for ctrl in Self.Controls do
    if ctrl is T then
      proc(T(ctrl));
end;

procedure TControlHelper.InitControl;
begin
  Touch.InteractiveGestures := [TInteractiveGesture.DoubleTap];
  InitMargins;

  if Self is TListView then
    (Self as TListView).InitListView
  else
    if Self is TListBox then
      (Self as TListBox).InitListBox
    else
      if Self is TComboBox then
        (Self as TComboBox).InitComboBox
      else
        if Self is TStringGrid then
          (Self as TStringGrid).InitGrid;
end;

procedure TControlHelper.InitMargins(const Left: Single = 3; const Top: Single = 5; const Right: Single = 3; const Bottom: Single = 5);
begin
  Margins.Top := Top;
  Margins.Left := Left;
  Margins.Right := Right;
  Margins.Bottom := Bottom;
end;

end.
