unit zRestrictions.Form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.ComCtrls,
  vcl.StdCtrls,
  vcl.ToolWin,
  vcl.ExtCtrls,
  vcl.Menus,
  TypInfo,
  vcl.Buttons,
  WinTypes,
  vcl.ImgList,
  zSystem,
  vcl.ActnList,
  System.Actions,
  System.ImageList,
  cxClasses,
  dxBar,
  cxImageList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxCustomData,
  cxStyles,
  cxTL,
  cxTextEdit,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxLabel,
  cxEdit,
  cxEditRepositoryItems,
  cxImageComboBox,
  cxDataStorage,
  Generics.Collections,
  SmartInspect.vcl.SiAuto,
  cxButtons,
  System.Variants,
  cxCheckBox,
  cxExtEditRepositoryItems,
  cxImage,
  zRestrictions.Types,
  zRestrictions.Structs,
  zRestrictions,
  cxVGrid,
  cxOI,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  vcl.StdActns,
  OkCancel,
  dxScrollbarAnnotations,
  dxFileActions,
  cxFilter,
  dxUIAClasses,
  Frame_ObjectInspector;

type
  TzSecRestrictionsForm = class(TForm)
    ActionList: TActionList;
    AddPolicy: TAction;
    DeletePolicy: TAction;
    imagesClassi: TcxImageList;
    dxBarManager: TdxBarManager;
    tree: TcxTreeList;
    colComponentClass: TcxTreeListColumn;
    colComponentName: TcxTreeListColumn;
    cxEditRepository: TcxEditRepository;
    dxBarManagerBar1: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    DuplicaPolicy: TAction;
    ReadOnlyTuttoSolaLettura: TAction;
    actHidden: TAction;
    actReadonly: TAction;
    actWriteable: TAction;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    ApplyBestWidth: TAction;
    dxBarButton9: TdxBarButton;
    imageAccess_Da_Reindirizzare_Verso_zDmImages: TcxImageList;
    cxEditRepositoryAccess: TcxEditRepositoryImageComboBoxItem;
    dxBarSubItemAccess: TdxBarSubItem;
    cxRTTIInspector1: TFrameObjectInspector;
    Esporta: TdxFileSaveAs;
    dxBarButton6: TdxBarButton;
    dxBarButton10: TdxBarButton;
    OkCancel: TOkCancel;
    procedure AddPolicyExecute(Sender: TObject);
    procedure ApplyBestWidthExecute(Sender: TObject);
    procedure DeletePolicyExecute(Sender: TObject);
    procedure cxEditRepositoryCheckGroupItem1PropertiesChange(Sender: TObject);
    procedure cxEditRepositoryRestrictionsPropertiesEditValueToStates(Sender: TObject; const AValue: Variant; var ACheckStates: TcxCheckStates);
    procedure cxEditRepositoryRestrictionsPropertiesStatesToEditValue(Sender: TObject; const ACheckStates: TcxCheckStates; out AValue: Variant);
    procedure DuplicaPolicyExecute(Sender: TObject);
    procedure actHiddenExecute(Sender: TObject);
    procedure actWriteableExecute(Sender: TObject);
    procedure actReadonlyExecute(Sender: TObject);
    procedure EsportaAccept(Sender: TObject);
    procedure OkCancelApply(Sender: TObject);
    procedure treeColumnHeaderClick(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
    procedure treeCustomDrawDataCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: boolean);
    procedure treeCustomDrawHeaderCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListHeaderCellViewInfo; var ADone: boolean);
    procedure treeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    RestrictionManager: TRestrictionManager;
    ComponentInfos: TComponentInfos;
  private
    LastSelectedCol: TcxTreeListColumn;
    LastSelectedNode: TcxTreeListNode;
    Selections: TComponentSelections;
    procedure SelectCol(col: TcxTreeListColumn);
    procedure SelectRow(node: TcxTreeListNode);
    procedure SelectCell(node: TcxTreeListNode; Column: TcxTreeListColumn);
    procedure SelectArea(CurrentNode: TcxTreeListNode; CurrentColumn: TcxTreeListColumn);
  private
    cxStyleFixed: TcxStyle;
    cxStylePolicyOdd: TcxStyle;
    cxStylePolicyEven: TcxStyle;
    cxStyleSelected: TcxStyle;
    cxStyleFocused: TcxStyle;

    procedure InitStyles;
  private
    function CreatePolicyColumn(const Policy: string): TcxTreeListColumn; overload;
    function CreatePolicyColumn: TcxTreeListColumn; overload;
    function PolicyColumnName(const Policy: string): string;
    function GetPolicyColumnIndex(const Policy: string; const CanAppend: boolean = false): Integer;
    procedure SetPolicyStyle(Column: TcxTreeListColumn);
    procedure SetDefaultPolicyValues(const Policy: string; col: TcxTreeListColumn);
    procedure SetRestriction(AccessLevel: TAccessLevel);
  protected
    procedure CreateComponentNodes;
    procedure AddRestrictions;
    procedure SaveRestrictions;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Edit(aRestrictionManager: TRestrictionManager): boolean;
  end;

function zEditRestrictions(RestrictionManager: TRestrictionManager): boolean;

implementation

uses
  System.Rtti,
  CommCtrl,
  zMsg,
  zBaseLib,
  dxCore,
  cxCheckGroup,
  zDbView,
  zDbCard,
  zDx,
  zFileViewer,
  cxTLExportLink;

const
  imgEnabled = 1;
  imgVisible = 2;
  imgReadOnly = 3;
  imgCustom = 4;

{$R *.DFM}

function zEditRestrictions(RestrictionManager: TRestrictionManager): boolean;
var
  zSecRestrictionsForm: TzSecRestrictionsForm;
begin
  Application.CreateForm(TzSecRestrictionsForm, zSecRestrictionsForm);
  try
    result := zSecRestrictionsForm.Edit(RestrictionManager);
  finally
    FreeAndNil(zSecRestrictionsForm);
  end;
end;

constructor TzSecRestrictionsForm.Create(aOwner: TComponent);
begin
  inherited;
  RestrictionManager := Nil;
  LastSelectedCol := nil;
  LastSelectedNode := nil;

  ComponentInfos := TComponentInfos.Create(tree);
  Selections := TComponentSelections.Create(TComponentSelection);

  dx.InitTreeList(tree);
  InitStyles;

  // Lista unica assegnata qui e non nel DFM: un collegamento a dx.Immagini
  // nel DFM l'IDE propone di toglierlo quando il modulo dx non e' aperto,
  // e una volta tolto azioni e barra restano senza icone
  ActionList.Images := dx.Immagini;
  dxBarManager.ImageOptions.Images := dx.Immagini;

  tree.OptionsCustomizing.ColumnFiltering := TdxDefaultBoolean.bTrue;

  WindowState := wsMaximized;
end;

destructor TzSecRestrictionsForm.Destroy;
begin
  FreeAndNil(Selections);
  FreeAndNil(ComponentInfos);
  inherited;
end;

function TzSecRestrictionsForm.PolicyColumnName(const Policy: string): string;
  function ValidateComponentName(Name: string): string;
  const
    Alpha = ['A' .. 'Z', 'a' .. 'z', '_'];
    AlphaNumeric = Alpha + ['0' .. '9'];
  var
    i: Integer;
  begin
    result := Name;
    for i := 1 to length(result) do
      if not(result[i] in AlphaNumeric) then
        result[i] := '_';
  end;

begin
  result := 'colPolicy' + ValidateComponentName(Policy);
end;

function TzSecRestrictionsForm.CreatePolicyColumn(const Policy: string): TcxTreeListColumn;
begin
  result := tree.CreateColumn(tree.Bands[1]);
  result.Name := PolicyColumnName(Policy);
  result.Caption.Text := Policy;
  result.DataBinding.ValueType := 'String';
  result.RepositoryItem := cxEditRepositoryAccess;
  result.Position.BandIndex := 1;
  result.Position.RowIndex := 0;
  result.Position.ColIndex := tree.ColumnCount;
  result.BestFitMaxWidth := 120;
  result.Width := 120;
  result.Options.IncSearch := false;
  result.Options.Moving := false;
  result.Options.Sorting := false;
  result.Focused := True;

  SetDefaultPolicyValues(Policy, result);
  SetPolicyStyle(result);
end;

function TzSecRestrictionsForm.GetPolicyColumnIndex(const Policy: string; const CanAppend: boolean = false): Integer;
var
  col: TcxTreeListColumn;
begin
  result := -1;

  col := FindComponent(PolicyColumnName(Policy)) as TcxTreeListColumn;

  if not Assigned(col) then
    if CanAppend then
      col := CreatePolicyColumn(Policy);

  if Assigned(col) then
    result := col.Position.ColIndex;
end;

procedure TzSecRestrictionsForm.CreateComponentNodes;
  procedure Enum(owner: TComponent);
  var
    comp: TComponent;
    ComponentClass: TzComponentClass;
    ComponentGroup: string;
    ComponentInfo: TComponentInfo;
  begin
    for comp in owner do
      if RestrictionManager.AllowComponent(comp) then
      begin
        ComponentClass := RestrictionManager.GetComponentClass(comp);
        ComponentGroup := RestrictionManager.GetComponentGroup(comp);
        ComponentInfo := ComponentInfos.AddComponent(comp, ComponentClass, ComponentGroup);
      end
      else
        if comp.ComponentCount > 0 then
          Enum(comp);
  end;

var
  i: Integer;
  PropInfo: PPropInfo;
  comp: TComponent;
  // isInherited: Boolean;

  RttiContext: TRttiContext;
  CompType: TRttiType;
  OwnerType: TRttiType;
  parentType: TRttiType;
  ComponentGroupNode: TcxTreeListNode;
  ComponentNode: TcxTreeListNode;
  DataSet: TzDiagramDataSet;
  DataSetName: string;
  node: TcxTreeListNode;
begin
  RttiContext := TRttiContext.Create;
  OwnerType := RttiContext.GetType(RestrictionManager.Form.ClassInfo);
  parentType := RttiContext.GetType(OwnerType.BaseType.AsInstance.MetaclassType);

  tree.Clear;
  ComponentInfos.Clear;

  colComponentClass.DataBinding.ValueTypeClass := TcxStringValueType;
  colComponentName.DataBinding.ValueTypeClass := TcxStringValueType;

  Enum(RestrictionManager.Form);
  // for comp in RestrictionManager.Form do
  // if RestrictionManager.AllowComponent(comp) then
  // begin
  // ComponentClass := RestrictionManager.GetComponentClass(comp);
  // ComponentGroup := RestrictionManager.GetComponentGroup(comp);
  // ComponentInfo := ComponentInfos.AddComponent(comp, ComponentClass, ComponentGroup);
  // end;

  /// ///////////////
  /// ///////////////
  /// ///////////////
  if Assigned(RestrictionManager.zDataModule) then
    if RestrictionManager.zDataModule.BuildGUI then // zz 02.11.2018 altrimenti confonde le idee...
      for DataSet in RestrictionManager.zDataModule.DataSets do
        ComponentInfos.AddDataSet(DataSet);

  /// ///////////////

  ComponentInfos.PackTree;

  /// ///////////////
end;

procedure TzSecRestrictionsForm.AddRestrictions;
var
  node: TcxTreeListNode;
  ColIndex: Integer;
  Restriction: TRestriction;
  s: string;
begin
  RestrictionManager.LoadRestrictions;

  for Restriction in RestrictionManager.Restrictions do
  begin
    ColIndex := GetPolicyColumnIndex(Restriction.Policy, True);
    if ColIndex <> -1 then
    begin
      node := ComponentInfos.GetComponentNode(Restriction.ComponentName);

      if Assigned(node) then // il componente potrebbe essere stato eliminato nel frattempo
      begin
        s := Restriction.AccessLevel.ToString;
        // 2 per la banda
        node.Values[2 + ColIndex] := s;
      end;
    end;
  end;
end;

procedure TzSecRestrictionsForm.AddPolicyExecute(Sender: TObject);
begin
  CreatePolicyColumn;
end;

procedure TzSecRestrictionsForm.ApplyBestWidthExecute(Sender: TObject);
begin
  tree.OptionsView.ColumnAutoWidth := not tree.OptionsView.ColumnAutoWidth;
  tree.ApplyBestFit;
end;

function TzSecRestrictionsForm.CreatePolicyColumn: TcxTreeListColumn;
var
  Name: string;
  i: Integer;
  RestrictionNames: TStringList;
begin
  result := nil;

  Name := 'Nuova Policy';

  RestrictionNames := TStringList.Create;
  try
    RestrictionManager.LoadRestrictionNames(RestrictionNames);

    // elenco non mappato (il nome della policy e' anche il valore) e digitabile,
    // perche' qui si crea una policy nuova, non si sceglie fra quelle esistenti
    if not InputCombo('Policy', 'Nome della policy', Name, RestrictionNames, nil, false, True) then
      Exit;

  finally
    FreeAndNil(RestrictionNames);
  end;

  /// /////////////

  if Assigned(tree.ColumnByName(name)) then
  begin
    i := 1;
    while Assigned(tree.ColumnByName(name + '_' + i.ToString)) do
      inc(i);

    name := name + '_' + i.ToString;
  end;

  /// /////////////

  result := CreatePolicyColumn(Name);

  tree.FocusedColumn := result;
end;

procedure TzSecRestrictionsForm.DeletePolicyExecute(Sender: TObject);
var
  col: TcxTreeListColumn;
  Policy: String;
begin
  col := tree.FocusedColumn;

  // R-200 DIV-RES-7 - 2026-11-01: si controllava Assigned(tree) invece della colonna a fuoco, con una violazione di accesso
  // se non c'era; e con a fuoco la colonna dei nomi (banda 0) la si eliminava come fosse una policy.
  // Le colonne delle policy stanno nella banda 1 (CreatePolicyColumn).
  if not Assigned(col) then
    Exit;

  if col.Position.BandIndex <> 1 then
    Exit;

  Policy := col.Caption.Text;

  if not ConfirmYesNo('Si desidera eliminare la policy ' + Policy + '?') then
    Exit;

  col.Free;

  RestrictionManager.DeletePolicy(Policy);
end;

function TzSecRestrictionsForm.Edit(aRestrictionManager: TRestrictionManager): boolean;
var
  M: TMonitor;
begin
  if not Assigned(aRestrictionManager) then
    Exit;

  Self.RestrictionManager := aRestrictionManager;

  CreateComponentNodes;

  AddRestrictions;

  tree.images := base.ImageList24;

  M := Screen.MonitorFromWindow(Application.MainForm.Handle);
  Self.Width := trunc(M.WorkareaRect.Width * 0.9);
  Self.Height := trunc(M.WorkareaRect.Height * 0.9);

  tree.OptionsView.ColumnAutoWidth := True;
  tree.ApplyBestFit;
  colComponentName.ApplyBestFit;

  result := ShowModal = mrOk;
  if result then
    SaveRestrictions;
end;

procedure TzSecRestrictionsForm.SaveRestrictions;
var
  i, J: Integer;
  ComponentInfo: TComponentInfo;
  Restriction: TRestriction;
  col: TcxTreeListColumn;
  Policy: string;
  s: string;
  AccessLevel: TAccessLevel;
Begin
  Screen.Cursor := crSQLWait;
  try
    for J := 0 to ComponentInfos.count - 1 do
    begin
      ComponentInfo := ComponentInfos[J];

      // if ComponentInfo.ComponentName = 'Progetti_Budget_Elenco' then
      // ConfirmOk('pippo');

      for i := 2 to tree.ColumnCount - 1 do
      begin
        col := tree.Columns[i];

        Policy := col.Caption.Text;

        if not VarIsNull(ComponentInfo.ComponentNode.Values[i]) then
        begin
          s := ComponentInfo.ComponentNode.Values[i];
          AccessLevel := AccessLevel.Parse(s);
          RestrictionManager.SaveRestriction(Policy, ComponentInfo.ComponentName, ComponentInfo.ComponentClass, AccessLevel);
        end;
      end;
    end;

    RestrictionManager.SaveRestrictions;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TzSecRestrictionsForm.cxEditRepositoryCheckGroupItem1PropertiesChange(Sender: TObject);
var
  cb: TcxCheckGroup;
  s: string;
  ReadOnly: boolean;
  Visible: boolean;
begin
  cb := Sender as TcxCheckGroup;

  s := cb.EditValue;

  ReadOnly := s.Substring(0, 1) = '1';
  Visible := s.Substring(1, 1) = '1';
end;

procedure TzSecRestrictionsForm.cxEditRepositoryRestrictionsPropertiesEditValueToStates(Sender: TObject; const AValue: Variant; var ACheckStates: TcxCheckStates);
var
  s: String;
begin

  if AValue = null then
    Exit;

  s := AValue;

  if s.length = 2 then
  begin
    if s.Substring(0, 1) = '1' then
      ACheckStates[0] := cbsChecked
    else
      ACheckStates[0] := cbsUnchecked;

    if s.Substring(1, 1) = '1' then
      ACheckStates[1] := cbsChecked
    else
      ACheckStates[1] := cbsUnchecked;
  end;
end;

procedure TzSecRestrictionsForm.cxEditRepositoryRestrictionsPropertiesStatesToEditValue(Sender: TObject; const ACheckStates: TcxCheckStates; out AValue: Variant);
begin
  AValue := '';

  if ACheckStates[0] = cbsChecked then
    AValue := AValue + '1'
  else
    AValue := AValue + '0';

  if ACheckStates[1] = cbsChecked then
    AValue := AValue + '1'
  else
    AValue := AValue + '0';
end;

procedure TzSecRestrictionsForm.DuplicaPolicyExecute(Sender: TObject);
var
  oldCol: TcxTreeListColumn;
  newCol: TcxTreeListColumn;
  compNode: TPair<string, TcxTreeListNode>;
  ComponentInfo: TComponentInfo;
  i: Integer;
  node: TcxTreeListNode;
begin
  oldCol := tree.FocusedColumn;

  if not Assigned(oldCol) then
    Exit;

  newCol := CreatePolicyColumn;

  if not Assigned(newCol) then
    Exit;

  for i := 0 to ComponentInfos.count - 1 do
  begin
    ComponentInfo := ComponentInfos[i];
    node := ComponentInfo.ComponentNode;
    node.Values[2 + newCol.Position.ColIndex] := node.Values[2 + oldCol.Position.ColIndex];
  end;
end;

procedure TzSecRestrictionsForm.SetDefaultPolicyValues(const Policy: string; col: TcxTreeListColumn);
var
  node: TcxTreeListNode;
  ComponentName: string;
  AccessLevel: TAccessLevel;
  ComponentInfo: TComponentInfo;
  DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel;
  i: Integer;
begin
  RestrictionManager.GetPolicyDefaults(Policy, DefaultActionAccessLevel, DefaultDataSetAccessLevel);

  for i := 0 to ComponentInfos.count - 1 do
  begin
    ComponentInfo := ComponentInfos[i];
    node := ComponentInfo.ComponentNode;
    ComponentName := ComponentInfo.ComponentName;
    AccessLevel := RestrictionManager.GetDefaultAccessLevel(ComponentName, DefaultActionAccessLevel, DefaultDataSetAccessLevel);

    if ComponentInfo.IsDataSet then
      if TzDiagramDataSet(ComponentInfo.Component).DefaultAccessLevel = alNone then
        AccessLevel := alNone;

    node.Values[2 + col.Position.ColIndex] := AccessLevel.ToString; // 2 per la banda
  end;
end;

procedure TzSecRestrictionsForm.actHiddenExecute(Sender: TObject);
begin
  SetRestriction(alNone);
end;

procedure TzSecRestrictionsForm.actReadonlyExecute(Sender: TObject);
begin
  SetRestriction(alRead);
end;

procedure TzSecRestrictionsForm.actWriteableExecute(Sender: TObject);
begin
  SetRestriction(alFull);
end;

procedure TzSecRestrictionsForm.SetRestriction(AccessLevel: TAccessLevel);
var
  Selection: TComponentSelection;
begin

  for Selection in Selections do
    Selection.node.Values[Selection.col.Position.ColIndex + 2] := AccessLevel.ToString;
end;

procedure TzSecRestrictionsForm.treeColumnHeaderClick(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
begin
  AColumn.Focused := True;
end;

procedure TzSecRestrictionsForm.treeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  if Button <> mbLeft then
    Exit;

  /// /////////////////////////////////////////////////////

  if (ssShift in Shift) then
  begin
    if (tree.HitTest.HitAtNode and tree.HitTest.HitAtColumn) and (tree.HitTest.HitColumn.Position.BandIndex = 1) then
      SelectArea(tree.HitTest.HitNode, tree.HitTest.HitColumn);
  end
  else
  begin
    // in ogni caso, anche con il sx senza ctrl
    if (tree.HitTest.HitAtNode and tree.HitTest.HitAtColumn) and (tree.HitTest.HitColumn.Position.BandIndex = 1) then
    begin
      LastSelectedCol := tree.HitTest.HitColumn;
      LastSelectedNode := tree.HitTest.HitNode;
    end;

    // senza ctrl o alt:
    if Shift = [ssLeft] then
    begin
      // last point
      Selections.Clear;
      SelectCell(LastSelectedNode, LastSelectedCol);
      tree.Invalidate;
    end
    else
      if (ssCtrl in Shift) then
      begin
        // cella delle policy
        if tree.HitTest.HitAtColumn and (tree.HitTest.HitColumn.Position.BandIndex = 1) then
        begin
          SelectCell(tree.HitTest.HitNode, tree.HitTest.HitColumn);
        end
        else
          // cella della colonna dei componenti
          if tree.HitTest.HitAtColumn and (tree.HitTest.HitColumn.Position.BandIndex = 0) then
          begin
            SelectRow(tree.HitTest.HitNode);
          end
          else
            // header di colonna
            if tree.HitTest.HitAtColumnHeader and (tree.HitTest.HitColumn.Position.BandIndex = 1) then
            begin
              SelectCol(tree.HitTest.HitColumn);
            end
            else
              // indicatore
              if tree.HitTest.HitAtIndicator then
              begin
                SelectRow(tree.HitTest.HitNode);
              end;
      end;
  end;
end;

procedure TzSecRestrictionsForm.EsportaAccept(Sender: TObject);
begin
  cxExportTLToExcel(Esporta.Dialog.FileName, tree);
end;

procedure TzSecRestrictionsForm.SelectRow(node: TcxTreeListNode);
var
  i: Integer;
begin

  for i := 2 to tree.ColumnCount - 1 do
    SelectCell(node, tree.Columns[i]);

  tree.Invalidate;
end;

procedure TzSecRestrictionsForm.SelectCol(col: TcxTreeListColumn);
var
  i: Integer;
  ComponentInfo: TComponentInfo;
begin
  for i := 0 to ComponentInfos.count - 1 do
  begin
    ComponentInfo := ComponentInfos[i];

    if ComponentInfo.ComponentNode.Parent.Expanded then
      SelectCell(ComponentInfo.ComponentNode, col);
  end;

  tree.Invalidate;
end;

procedure TzSecRestrictionsForm.SelectArea(CurrentNode: TcxTreeListNode; CurrentColumn: TcxTreeListColumn);
var
  FirstCol: Integer;
  LastCol: Integer;

  FirstNode: Integer;
  idxCol: Integer;
  idxNode: Integer;
  LastNode: Integer;

  col: TcxTreeListColumn;
  node: TcxTreeListNode;
begin
  if not Assigned(CurrentNode) then
    Exit;

  if not Assigned(CurrentColumn) then
    Exit;

  if not Assigned(LastSelectedNode) then
    Exit;

  if not Assigned(LastSelectedCol) then
    Exit;

  if LastSelectedNode.Parent <> CurrentNode.Parent then
    Exit;

  /// /////////////////////////////////////
  /// col
  if LastSelectedCol.Position.ColIndex <= CurrentColumn.Position.ColIndex then
  begin
    FirstCol := LastSelectedCol.Position.ColIndex;
    LastCol := CurrentColumn.Position.ColIndex;
  end
  else
  begin
    FirstCol := CurrentColumn.Position.ColIndex;
    LastCol := LastSelectedCol.Position.ColIndex;
  end;
  /// node
  if LastSelectedNode.Index <= CurrentNode.Index then
  begin
    FirstNode := LastSelectedNode.Index;
    LastNode := CurrentNode.Index;
  end
  else
  begin
    FirstNode := CurrentNode.Index;
    LastNode := LastSelectedNode.Index;
  end;

  /// /////////////////////////////////////
  for idxCol := FirstCol to LastCol do
    for idxNode := FirstNode to LastNode do
    begin
      col := tree.Columns[idxCol + 2];
      node := CurrentNode.Parent.Items[idxNode];

      SelectCell(node, col);
    end;

  tree.Invalidate;
end;

procedure TzSecRestrictionsForm.SelectCell(node: TcxTreeListNode; Column: TcxTreeListColumn);
begin
  if Assigned(node) then
    if Assigned(Column) then
      Selections.AddSelection(node, Column);
end;

procedure TzSecRestrictionsForm.treeCustomDrawHeaderCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListHeaderCellViewInfo; var ADone: boolean);
var
  Column: TcxTreeListColumn;
begin
  Column := TcxTreeListColumnHeaderCellViewInfo(AViewInfo).Column;

  if Column = LastSelectedCol then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsBold]
  else
    ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
end;

procedure TzSecRestrictionsForm.treeCustomDrawDataCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: boolean);
var
  tmp: TColor;
begin
  if AViewInfo.Column.Position.BandIndex = 0 then
  begin
    if AViewInfo.node = LastSelectedNode then
      ACanvas.Font.Style := ACanvas.Font.Style + [fsBold]
    else
      ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
  end
  else
  begin
    //
    if Selections.Find(AViewInfo.node, AViewInfo.Column) <> nil then
      ACanvas.Brush.Color := cxStyleSelected.Color
    else
      if (AViewInfo.Column = LastSelectedCol) or (AViewInfo.node = LastSelectedNode) then
        ACanvas.Brush.Color := cxStyleFocused.Color
      else
        if Assigned(AViewInfo.Column.Styles.Content) then
          ACanvas.Brush.Color := AViewInfo.Column.Styles.Content.Color
        else
          ACanvas.Brush.Color := cxStyleFocused.Color;
  end;
end;

procedure TzSecRestrictionsForm.SetPolicyStyle(Column: TcxTreeListColumn);
begin
  if not Assigned(Column) then
    Exit;

  if Column.Position.BandIndex = 0 then
    Exit;

  // if Column.Focused then
  // Column.Styles.Content := cxStylePolicyFocused
  // else
  if odd(Column.Position.ColIndex) then
    Column.Styles.Content := cxStylePolicyOdd
  else
    Column.Styles.Content := cxStylePolicyEven;
end;

procedure TzSecRestrictionsForm.InitStyles;
begin
  cxStyleFixed := dx.GetStyle(scBtnFace);
  cxStylePolicyOdd := dx.GetStyle(scContentOdd);
  cxStylePolicyEven := dx.GetStyle(scContentEven);
  cxStyleSelected := dx.GetStyle(scHighlight);
  cxStyleFocused := dx.GetStyle(scSkyBlue);

  tree.Bands[0].Styles.Content := cxStyleFixed;
  tree.Styles.Selection := cxStyleSelected;
end;

procedure TzSecRestrictionsForm.OkCancelApply(Sender: TObject);
begin
  if ConfirmYesNo('Si desidera salvare le policy?', mtConfirmation) then
    SaveRestrictions;
end;

end.

