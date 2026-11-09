unit zFormBuilder;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Generics.Collections,
  Generics.Defaults,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Data.DB,
  cxGraphics,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxRibbonForm,
  dxLayoutCommon,
  dxLayoutControl,
  dxLayoutContainer,
  dxLayoutLookAndFeels,
  cxEdit,
  cxTextEdit,
  cxCalendar,
  cxTimeEdit,
  cxImageComboBox,
  cxCheckBox,
  cxLookupEdit,
  cxDBLookupComboBox,
  cxButtons,
  cxPC,
  zFbDataSet,
  zBaseLib,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzFormBuilder = class(TComponent)
  private
    FdxLayoutControl: TdxLayoutControl;
    ctrls: TList<TControl>;
    lkDataSources: TList<TDataSource>;
    DefaultParentGroup: TdxLayoutGroup;
    FLayoutID: string;

    function UniqueLayoutItemName(const name: string): string;
    function GetParentGroup(group: TdxLayoutGroup): TdxLayoutGroup;
    function GetLookupDataSource(zFbDataSet: TzFbDataSet): TDataSource;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent; aLayoutControl: TdxLayoutControl; const aLayoutID: string = ''); virtual;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: boolean;

    procedure Clear;
  public
    function AddLayoutGroup(ParentGroup: TdxLayoutGroup = nil; const aName: string = ''; LayoutDirection: TdxLayoutDirection = ldHorizontal; const Caption: string = '';
      const ShowBorder: boolean = False): TdxLayoutGroup;

    function AddLayoutItem(Control: TControl; group: TdxLayoutGroup = nil; const AlignHorz: TdxLayoutAlignHorz = ahClient; const AlignVert: TdxLayoutAlignVert = avClient; const Caption: string = '';
      const CaptionLayout: TdxCaptionLayout = clLeft; const ShowBorder: boolean = False): TdxLayoutItem;

    function AddLayoutSplitter(group: TdxLayoutGroup = nil; const aName: string = ''): TdxLayoutSplitterItem;
    function AddLayoutEmptySpace(group: TdxLayoutGroup = nil; const aName: string = ''): TdxLayoutEmptySpaceItem;
    function AddLayoutSeparator(group: TdxLayoutGroup = nil; const aName: string = ''): TdxLayoutSeparatorItem;
  public
    function Exists(const name: string): boolean;
    function ControlByName<T: TControl>(const name: string): T;
    function LayoutItemByName(const name: string): TdxCustomLayoutItem;
    function LayoutItemByControl(Control: TControl): TdxCustomLayoutItem;
  public
    // button
    function AddButton(Action: TContainedAction; group: TdxLayoutGroup = nil; initProc: TProc<TcxButton, TdxLayoutItem> = nil): TcxButton;
    //
    // cxCutomEdit
    function CreateControl(const zCtrlType: TzCtrlType; const aName: string; const Value: Variant): TcxCustomEdit;
    function AddControl(const zCtrlType: TzCtrlType; const aName: string; const Caption: string; const Value: Variant; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil)
      : TcxCustomEdit;
    function ChangeControlType(const zCtrlType: TzCtrlType; const aName: string; const Caption: string; const Value: Variant): TcxCustomEdit;
    function GetControl(const name: string): TcxCustomEdit;
    procedure SetValue(const name: string; Value: Variant);
    function GetValue(const name: string): Variant;

    function AddTextEdit(const aName: string; const Caption: string; const Value: string; group: TdxLayoutGroup; initProc: TProc < TcxCustomEdit >= nil): TcxTextEdit;
    function AddDate(const aName: string; const Caption: string; const Value: TDate; group: TdxLayoutGroup; initProc: TProc < TcxCustomEdit >= nil): TcxDateEdit;
    function AddTime(const aName: string; const Caption: string; const Value: TTime; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil): TcxTimeEdit;
    function AddPickList(const PickList: string; const Caption: string; const aName: string; const Value: Variant; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil): TcxImageComboBox;
    function AddLookupCombo(const aName: string; const Caption: string; DataSet: TzFbDataSet; const KeyField, ListField: string; const Value: Variant; group: TdxLayoutGroup = nil;
      initProc: TProc<TcxCustomEdit> = nil): TcxLookupComboBox;
    function AddLookupComboHyperLink(const aName: string; const Caption: string; DataSet: TzFbDataSet; const KeyField, ListField: string; const Value: Variant; group: TdxLayoutGroup = nil;
      initProc: TProc<TcxCustomEdit> = nil): TcxLookupComboBox;
    function AddCheckBox(const aName: string; const Caption: string; const Value: boolean; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil): TcxCheckBox;
  public
    procedure Customize;

    procedure LoadLayout;
    procedure SaveLayout;
    property LayoutID: string read FLayoutID write FLayoutID;
  public
    property dxLayoutControl: TdxLayoutControl read FdxLayoutControl;
  end;

implementation

uses
  zDxLayoutCustomizeFrm,
  zSystem,
  zDX;

constructor TzFormBuilder.Create(aOwner: TComponent; aLayoutControl: TdxLayoutControl; const aLayoutID: string = '');
begin
  inherited Create(aOwner);

  Assert(Assigned(aLayoutControl));

  FLayoutID := aLayoutID;
  FdxLayoutControl := aLayoutControl;
  DefaultParentGroup := nil;

  ctrls := TList<TControl>.Create;
  lkDataSources := TList<TDataSource>.Create;
end;

destructor TzFormBuilder.Destroy;
begin
  FreeAndNil(ctrls);
  FreeAndNil(lkDataSources);
  inherited;
end;

//
procedure TzFormBuilder.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
    if AComponent = dxLayoutControl then
      FdxLayoutControl := nil;
end;

function TzFormBuilder.UniqueLayoutItemName(const name: string): string;
var
  i: Integer;
begin
  result := name;

  if not Assigned(dxLayoutControl) then
    Exit;

  i := 0;
  while Assigned(dxLayoutControl.FindItem(result)) do
  begin
    Inc(i);
    result := name + '_' + inttostr(i);
  end;
end;

procedure TzFormBuilder.Customize;
begin
  if Assigned(dxLayoutControl) then
  begin
    // DisableGoogleMapsHooks;
    dxLayoutControl.CustomizeFormClass := TzLayoutCustomizeForm;
    dxLayoutControl.Customization := True;
  end;

end;

function TzFormBuilder.GetParentGroup(group: TdxLayoutGroup): TdxLayoutGroup;
begin
  result := group;

  if not Assigned(result) then
  begin
    if not Assigned(DefaultParentGroup) then
    begin
      DefaultParentGroup := dxLayoutControl.CreateGroup(TdxLayoutGroup, dxLayoutControl.Items) as TdxLayoutGroup;
      DefaultParentGroup.name := dxLayoutControl.name + 'DefaultParentGroup';
      DefaultParentGroup.LayoutDirection := ldVertical;
      DefaultParentGroup.AlignHorz := ahClient;
      DefaultParentGroup.AlignVert := avClient;
      DefaultParentGroup.CaptionOptions.Visible := False;
      DefaultParentGroup.CaptionOptions.Text := 'DefaultParentGroup';
      DefaultParentGroup.ShowBorder := False;
      DefaultParentGroup.Visible := True;
    end;

    result := DefaultParentGroup;
  end;
end;

function TzFormBuilder.AddLayoutGroup(ParentGroup: TdxLayoutGroup = nil; const aName: string = ''; LayoutDirection: TdxLayoutDirection = ldHorizontal; const Caption: string = '';
  const ShowBorder: boolean = False): TdxLayoutGroup;
begin
  result := dxLayoutControl.CreateGroup(TdxLayoutGroup, GetParentGroup(ParentGroup)) as TdxLayoutGroup;

  if aName.IsEmpty then
    result.name := UniqueLayoutItemName(dxLayoutControl.name + 'Group' + aName);

  if Caption.IsEmpty then
    result.Caption := result.name
  else
    result.Caption := Caption;

  result.CaptionOptions.Visible := False;
  result.Visible := True;
  result.LayoutDirection := LayoutDirection;
  result.AlignHorz := ahClient;
  result.AlignVert := avClient;
  result.TabbedOptions.Options := result.TabbedOptions.Options - [pcoRedrawOnResize];

  // THackDxLayoutTabbedOptions(result.TabbedOptions).Style := 9;
  // THackDxLayoutTabbedOptions(result.TabbedOptions).TabSlants.Kind := skCutCorner;
  // THackDxLayoutTabbedOptions(result.TabbedOptions).TabSlants.Positions := [spRight];

  result.ShowBorder := (result.LayoutDirection = ldTabbed);

  if result.ShowBorder then
  begin
    result.TabbedOptions.HideTabs := False;
    result.TabbedOptions.ShowFrame := True;

    result.LayoutLookAndFeel := nil; // default
  end
  else
  begin
    result.TabbedOptions.HideTabs := True;
    result.TabbedOptions.ShowFrame := False;

    // result.LayoutLookAndFeel := dx.LayoutLookAndFeelNoGroupBorder;
  end;
end;

function TzFormBuilder.AddLayoutItem(Control: TControl; group: TdxLayoutGroup = nil; const AlignHorz: TdxLayoutAlignHorz = ahClient; const AlignVert: TdxLayoutAlignVert = avClient;
  const Caption: string = ''; const CaptionLayout: TdxCaptionLayout = clLeft; const ShowBorder: boolean = False): TdxLayoutItem;
begin
  result := nil;

  if not Assigned(dxLayoutControl) then
    Exit;

  result := TdxLayoutItem(dxLayoutControl.CreateItem(TdxLayoutItem, GetParentGroup(group)));
  result.name := UniqueLayoutItemName(dxLayoutControl.name + 'Item' + Control.name);

  if Caption.IsEmpty then
  begin
    result.ShowCaption := False;
    result.Caption := Control.name;
  end
  else
  begin
    result.ShowCaption := True;
    result.Caption := Caption;
  end;

  result.Control := Control;
  result.CaptionOptions.Layout := CaptionLayout;
  result.AlignHorz := AlignHorz;
  result.AlignVert := AlignVert;
  result.CaptionOptions.Visible := result.ShowCaption;
  result.ControlOptions.AutoColor := True;
  result.ControlOptions.ShowBorder := ShowBorder;
  // result.OnCaptionClick := ?;
end;

function TzFormBuilder.AddLayoutSplitter(group: TdxLayoutGroup = nil; const aName: string = ''): TdxLayoutSplitterItem;
begin
  result := dxLayoutControl.CreateItem(TdxLayoutSplitterItem, GetParentGroup(group)) as TdxLayoutSplitterItem;

  if aName.IsEmpty then
    result.name := UniqueLayoutItemName(dxLayoutControl.name + 'Splitter' + Name);

  result.Caption := result.name;
  result.CaptionOptions.Visible := False;

  result.Offsets.Top := 3;
  result.Offsets.Bottom := 3;
  result.Offsets.Left := 3;
  result.Offsets.Right := 3;
end;

function TzFormBuilder.AddLookupCombo(const aName: string; const Caption: string; DataSet: TzFbDataSet; const KeyField, ListField: string; const Value: Variant; group: TdxLayoutGroup = nil;
  initProc: TProc<TcxCustomEdit> = nil): TcxLookupComboBox;
var
  DataSource: TDataSource;
begin
  result := AddControl(TzCtrlType.DefaultLookupCtrlType, aName, Caption, null, group, initProc) as TcxLookupComboBox;
  DataSource := GetLookupDataSource(DataSet);
  dx.InitLookup('', result, DataSet, DataSource, KeyField, ListField);
  result.EditValue := Value;
end;

function TzFormBuilder.AddLookupComboHyperLink(const aName, Caption: string; DataSet: TzFbDataSet; const KeyField, ListField: string; const Value: Variant; group: TdxLayoutGroup;
  initProc: TProc<TcxCustomEdit>): TcxLookupComboBox;
var
  DataSource: TDataSource;
begin
  result := AddControl(ctLookupHyperLink, aName, Caption, null, group, initProc) as TcxLookupComboBox;
  DataSource := GetLookupDataSource(DataSet);
  dx.InitLookup('', result, DataSet, DataSource, KeyField, ListField, True);
  result.EditValue := Value;
end;

function TzFormBuilder.AddPickList(const PickList: string; const Caption: string; const aName: string; const Value: Variant; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil)
  : TcxImageComboBox;
begin
  result := AddControl(ctPickListImage, aName, Caption, Value, group, initProc) as TcxImageComboBox;
  dx.InitPickList(result.Properties, PickList);
end;

function TzFormBuilder.AddTextEdit(const aName, Caption, Value: string; group: TdxLayoutGroup; initProc: TProc<TcxCustomEdit>): TcxTextEdit;
begin
  result := AddControl(ctEdit, aName, Caption, Value, group, initProc) as TcxTextEdit;
end;

function TzFormBuilder.AddTime(const aName: string; const Caption: string; const Value: TTime; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil): TcxTimeEdit;
begin
  result := AddControl(ctTime, aName, Caption, Value, group, initProc) as TcxTimeEdit;
end;

function TzFormBuilder.AddLayoutEmptySpace(group: TdxLayoutGroup = nil; const aName: string = ''): TdxLayoutEmptySpaceItem;
begin
  result := dxLayoutControl.CreateItem(TdxLayoutEmptySpaceItem, GetParentGroup(group)) as TdxLayoutEmptySpaceItem;

  if aName.IsEmpty then
    result.name := UniqueLayoutItemName(dxLayoutControl.name + 'EmptySpace' + Name);

  result.Caption := result.name;
  result.CaptionOptions.Visible := False;
end;

function TzFormBuilder.AddLayoutSeparator(group: TdxLayoutGroup = nil; const aName: string = ''): TdxLayoutSeparatorItem;
begin
  result := dxLayoutControl.CreateItem(TdxLayoutSeparatorItem, GetParentGroup(group)) as TdxLayoutSeparatorItem;

  if aName.IsEmpty then
    result.name := UniqueLayoutItemName(dxLayoutControl.name + 'Separator' + Name);

  result.Caption := result.name;
  result.CaptionOptions.Visible := False;
end;

procedure TzFormBuilder.Clear;
var
  i: Integer;
begin
  // dxLayoutControl.Clear distrugge anche i gruppi (compreso quello predefinito)
  // e i controlli collegati agli elementi
  if Assigned(dxLayoutControl) then
    dxLayoutControl.Clear;

  DefaultParentGroup := nil;

  // Ciclo all'indietro sui componenti del costruttore: un controllo gia'
  // distrutto dal layout si e' tolto da solo da Components e non si libera
  // due volte. Il confronto fra puntatori non legge mai l'oggetto.
  for i := ComponentCount - 1 downto 0 do
    if ctrls.Contains(TControl(Components[i])) or lkDataSources.Contains(TDataSource(Components[i])) then
      Components[i].Free;

  ctrls.Clear;
  lkDataSources.Clear;
end;

function TzFormBuilder.ControlByName<T>(const name: string): T;
var
  ctrl: TComponent;
begin
  result := nil;

  for ctrl in ctrls do
    if SameText(Name, ctrl.name) then
      if ctrl is T then
      begin
        result := T(ctrl);
        Exit;
      end;
end;

function TzFormBuilder.LayoutItemByName(const name: string): TdxCustomLayoutItem;
begin
  result := nil;

  if Assigned(dxLayoutControl) then
    result := dxLayoutControl.FindItem(name);
end;

function TzFormBuilder.LayoutItemByControl(Control: TControl): TdxCustomLayoutItem;
begin
  result := nil;

  if Assigned(dxLayoutControl) then
    result := dxLayoutControl.FindItem(Control);
end;

function TzFormBuilder.AddButton(Action: TContainedAction; group: TdxLayoutGroup = nil; initProc: TProc<TcxButton, TdxLayoutItem> = nil): TcxButton;
var
  item: TdxLayoutItem;
begin
  result := TcxButton.Create(Self);
  ctrls.Add(result);

  result.name := 'btn' + Action.name;
  result.Action := Action;

  if Action.ActionList is TCustomActionList then
    result.OptionsImage.Images := TCustomActionList(Action.ActionList).Images;

  item := AddLayoutItem(result, group, ahRight, avTop);

  if Assigned(initProc) then
    initProc(result, item);
end;

function TzFormBuilder.AddCheckBox(const aName: string; const Caption: string; const Value: boolean; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil): TcxCheckBox;
begin
  result := AddControl(ctCheckBox, aName, Caption, Value, group, initProc) as TcxCheckBox;
end;

function TzFormBuilder.GetControl(const name: string): TcxCustomEdit;
begin
  result := ControlByName<TcxCustomEdit>(Name);
end;

procedure TzFormBuilder.SetValue(const name: string; Value: Variant);
var
  cxCustomEdit: TcxCustomEdit;
begin
  cxCustomEdit := GetControl(name);

  if Assigned(cxCustomEdit) then
    cxCustomEdit.EditValue := Value;
end;

function TzFormBuilder.GetValue(const name: string): Variant;
var
  cxCustomEdit: TcxCustomEdit;
begin
  result := null;

  cxCustomEdit := GetControl(name);

  if Assigned(cxCustomEdit) then
    result := cxCustomEdit.EditValue;
end;

function TzFormBuilder.CreateControl(const zCtrlType: TzCtrlType; const aName: string; const Value: Variant): TcxCustomEdit;
begin
  result := dx.GetCustomEditClass(zCtrlType, False).Create(Self);
  ctrls.Add(result);

  result.name := aName;

  dx.SetValue(result, Value);
end;

function TzFormBuilder.AddControl(const zCtrlType: TzCtrlType; const aName: string; const Caption: string; const Value: Variant; group: TdxLayoutGroup = nil; initProc: TProc<TcxCustomEdit> = nil)
  : TcxCustomEdit;
begin
  result := CreateControl(zCtrlType, aName, Value);

  AddLayoutItem(result, group, ahClient, avTop, Caption);

  if Assigned(initProc) then
    initProc(result);
end;

function TzFormBuilder.ChangeControlType(const zCtrlType: TzCtrlType; const aName, Caption: string; const Value: Variant): TcxCustomEdit;
var
  item: TdxCustomLayoutItem;
  old: TcxCustomEdit;
begin

  old := GetControl(aName);

  if Assigned(old) then
  begin
    item := LayoutItemByControl(old);
    old.name := '_old' + aName;
    result := CreateControl(zCtrlType, aName, Value);
    TdxLayoutItem(item).Control := result;
    ctrls.Remove(old);
    old.Free;
  end
  else
    result := AddControl(zCtrlType, aName, Caption, Value);
end;

function TzFormBuilder.AddDate(const aName: string; const Caption: string; const Value: TDate; group: TdxLayoutGroup; initProc: TProc<TcxCustomEdit>): TcxDateEdit;
begin
  result := AddControl(ctDate, aName, Caption, Value, group, initProc) as TcxDateEdit;
end;

// function TzFormBuilder.AddGoogleMaps(group: TdxLayoutGroup = nil; const aName: string = ''; initProc: TProc<TzGoogleMaps> = nil): TzGoogleMaps;
// begin
// result := TzGoogleMaps.Create(Self);
// ctrls.Add(result);
//
// if aName.IsEmpty then
// result.name := aName;
//
// AddLayoutItem(result, group, ahClient, avClient, '');
//
// if Assigned(initProc) then
// initProc(result);
// end;
//
// function TzFormBuilder.GetGoogleMaps(const name: string): TzGoogleMaps;
// begin
// result := ControlByName<TzGoogleMaps>(Name);
// end;

function TzFormBuilder.GetLookupDataSource(zFbDataSet: TzFbDataSet): TDataSource;
begin
  result := nil;

  for result in lkDataSources do
    if result.DataSet = zFbDataSet then
      Exit;

  // non trovato
  result := TDataSource.Create(Self);
  lkDataSources.Add(result);
  result.DataSet := zFbDataSet;
  result.name := zFbDataSet.name + 'Src';
end;

procedure TzFormBuilder.BeginUpdate;
begin

  if Assigned(dxLayoutControl) then
    dxLayoutControl.BeginUpdate;
end;

procedure TzFormBuilder.EndUpdate;
begin

  if Assigned(dxLayoutControl) then
    dxLayoutControl.EndUpdate;
end;

function TzFormBuilder.Exists(const name: string): boolean;
var
  ctrl: TComponent;
begin
  result := False;

  for ctrl in ctrls do
    if SameText(Name, ctrl.name) then
    begin
      result := True;
      Exit;
    end;
end;

function TzFormBuilder.IsUpdating: boolean;
begin
  result := False;
  if Assigned(dxLayoutControl) then
    dxLayoutControl.Container.IsUpdateLocked;
end;

procedure TzFormBuilder.LoadLayout;
begin
  { TODO : Implementare }
end;

procedure TzFormBuilder.SaveLayout;
begin
  { TODO : Implementare }
end;

end.

// zformcontroller
