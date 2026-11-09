unit zz.base.editor.DbPivot;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Actions,
  System.TypInfo,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.StdCtrls,
  vcl.Menus,
  vcl.ExtCtrls,
  vcl.ComCtrls,
  vcl.ImgList,
  vcl.ActnList,
  vcl.ToolWin,
  vcl.Grids,
  vcl.Mask,
  data.db,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxSplitter,
  dxBarBuiltInMenu,
  cxPC,
  cxTL,
  cxImageList,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  zCollection,
  zDBImage,
  OkCancel,
  zPanelFrame,
  zDbView,
  zSystem,
  zFbDataSet,
  zz.base.editor._frame,
  Frame_ObjectInspector,
  Frame_Collection;

type
  TzFrameEditor_DbPivot = class(TzFrameEditorCollectionItem)
    PageControl1: TcxPageControl;
    tabFields: TcxTabSheet;
    tabPivot: TcxTabSheet;
    InspectorDbView: TFrameObjectInspector;
    FrameCollection: TFrameCollection;
    procedure FrameCollectionBeforeDelete(Sender: TObject; var Handled: Boolean);
    procedure FrameCollectionBeforeInsert(Sender: TObject; var Handled: Boolean);
    procedure FrameCollectionInspectorModified(Sender: TObject);
    procedure FrameCollectionNodeChecked(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
  private
    procedure TreeSetVisible;
    procedure FillTreeList;
  private
    Internal_zDbPivotProps: TzDbPivotProps;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure Init; override;
    procedure Apply; override;
    procedure Clear; override;
    function WindowState: TWindowState; override;
  end;

implementation

{$R *.dfm}

uses
  vcl.Dialogs,
  zMsg,
  cxOI,
  zz.Inspector,
  cxCustomPivotGrid;

const
  strNewLine = '<New Line>';
  strSeparator = '<Separator>';
  Tab = #9;
  Sep = ';';
  CheckBox = 'CheckBox';
  CustomEdit = 'CustomEdit';

constructor TzFrameEditor_DbPivot.Create(aOwner: TComponent);
begin
  inherited;
  PageControl1.ActivePage := tabFields;
  Internal_zDbPivotProps := TzDbPivotProps.Create(nil);
  FrameCollection.CheckBoxes := True;
  FrameCollection.TreeList.OptionsSelection.MultiSelect := True;
end;

destructor TzFrameEditor_DbPivot.Destroy;
begin
  FreeAndNil(Internal_zDbPivotProps);
  inherited;
end;

procedure TzFrameEditor_DbPivot.Clear;
begin
  inherited;
  InspectorDbView.Clear;
  FrameCollection.Clear;
end;

procedure TzFrameEditor_DbPivot.Init;
begin
  inherited;

  if not Assigned(Item) then
    exit;

  Clear; // tutti i riferimenti precedenti, evita AV a iosa
  Caption := 'Pivot: ' + Item.Name;

  Internal_zDbPivotProps.Assign(Item);
  InspectorDbView.Add(Internal_zDbPivotProps);
  FillTreeList;
end;

procedure TzFrameEditor_DbPivot.FillTreeList;
begin
  FrameCollection.AddCollections([Internal_zDbPivotProps.Fields]);
  TreeSetVisible;
  FrameCollection.FullExpand;
end;

procedure TzFrameEditor_DbPivot.Apply;
begin
  inherited;
  if not Assigned(Item) then
    exit;

  Item.Assign(Internal_zDbPivotProps);
end;

function TzFrameEditor_DbPivot.WindowState: TWindowState;
begin
  result := wsNormal;
end;

procedure TzFrameEditor_DbPivot.TreeSetVisible;
begin
  FrameCollection.ForEachItemNode(
    procedure(Node: TcxTreeListNode; Item: TzCollectionItem)
    begin
      FrameCollection.SetChecked(Node, TzPivotField(Item).Visible);
    end);
end;

procedure TzFrameEditor_DbPivot.FrameCollectionInspectorModified(Sender: TObject);
begin
  if Sender is TzObjectInspector then
    if TzObjectInspector(Sender).FocusedRow is TcxPropertyRow then
      if SameText(TcxPropertyRow(TzObjectInspector(Sender).FocusedRow).Properties.Caption, 'visible') then
        TreeSetVisible;
end;

procedure TzFrameEditor_DbPivot.FrameCollectionNodeChecked(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
var
  Item: TzPivotField;
begin
  if Assigned(ANode) then
  begin
    Item := TzPivotField(FrameCollection.GetCollectionItem(ANode));

    if Assigned(Item) then
    begin
      Item.Visible := FrameCollection.IsChecked(ANode);
      // Refresh e non Add: il campo e' gia' nell'inspector (il clic lo
      // seleziona), e Add non ridisegna i valori, cosi' Visible restava
      // quello di prima finche' non si cambiava riga
      FrameCollection.FrameObjectInspector.Refresh;
    end;
  end;
end;

procedure TzFrameEditor_DbPivot.FrameCollectionBeforeInsert(Sender: TObject; var Handled: Boolean);
var
  NewField: TzPivotField;
  NewName: string;
begin
  Handled := True; // blocca InsertItem generico

  NewName := 'CALC_' + IntToStr(Internal_zDbPivotProps.Fields.Count);

  if not InputQuery('Nuovo campo calcolato', 'Nome:', NewName) then
    exit;

  NewField := Internal_zDbPivotProps.Fields.Add;
  NewField.Kind := fkCalc;
  NewField.Name := NewName;
  NewField.Caption := NewName;
  NewField.Area := faData;
  NewField.AreaIndex := -1;
  NewField.TotalMode := ctmNull;
  NewField.Visible := True;
  FillTreeList;
  FrameCollection.SelectCollectionItem(NewField);
  FrameCollection.UpdateInspector;
end;

procedure TzFrameEditor_DbPivot.FrameCollectionBeforeDelete(Sender: TObject; var Handled: Boolean);
var
  Node: TcxTreeListNode;
  Field: TzPivotField;
begin
  Handled := True; // blocca DeleteItem generico

  Node := FrameCollection.SelectedNode;
  if not Assigned(Node) then
    exit;

  Field := TzPivotField(FrameCollection.GetCollectionItem(Node));
  if not Assigned(Field) then
    exit;

  if Field.Kind <> fkCalc then
  begin
    ShowMessage('Solo i campi calcolati possono essere eliminati da qui.' + sLineBreak + 'I campi DB vengono gestiti dal dataset.');
    exit;
  end;

  if ConfirmYesNo('Eliminare il campo calcolato "' + Field.Caption + '"?') then
  begin
    FrameCollection.FrameObjectInspector.Clear;
    Field.Free;
    FillTreeList;
  end;
end;

end.
