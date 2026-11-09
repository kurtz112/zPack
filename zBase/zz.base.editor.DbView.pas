unit zz.base.editor.DbView;

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
  cxTL,
  cxPC,
  zCollection,
  OkCancel,
  zPanelFrame,
  zDbView,
  zSystem,
  zFbDataSet,
  Frame_Collection,
  zz.base.editor._frame,
  Frame_ObjectInspector;

type
  TzFrameEditor_DbView = class(TzFrameEditorCollectionItem)
    PageControl1: TcxPageControl;
    tabColumns: TcxTabSheet;
    tabView: TcxTabSheet;
    InspectorDbView: TFrameObjectInspector;
    FrameCollection: TFrameCollection;
    procedure actUpdateListboxExecute(Sender: TObject);
    procedure FrameCollectionInspectorModified(Sender: TObject);
    procedure FrameCollectionNodeChecked(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
  private
    Internal_zDbViewProps: TzDbViewProps;
  protected
    procedure FillTreeList;
    procedure TreeSetVisible;
    procedure OnModified(Sender: TObject);
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
  zBaseLib,
  zMsg,
  cxOI,
  zz.Inspector;

const
  Tab = #9;
  Sep = ';';
  CheckBox = 'CheckBox';
  CustomEdit = 'CustomEdit';

constructor TzFrameEditor_DbView.Create(aOwner: TComponent);
begin
  inherited;
  PageControl1.ActivePage := tabColumns;
  Internal_zDbViewProps := TzDbViewProps.Create(nil);
  FrameCollection.CheckBoxes := True;
  FrameCollection.TreeList.OptionsSelection.MultiSelect := True;
end;

destructor TzFrameEditor_DbView.Destroy;
begin
  FreeAndNil(Internal_zDbViewProps);
  inherited;
end;

procedure TzFrameEditor_DbView.actUpdateListboxExecute(Sender: TObject);
begin
  FillTreeList;
end;

procedure TzFrameEditor_DbView.Clear;
begin
  inherited;
  InspectorDbView.Clear;
  FrameCollection.Clear;
end;

procedure TzFrameEditor_DbView.FillTreeList;
begin
  FrameCollection.AddCollections([Internal_zDbViewProps.Columns]);
  TreeSetVisible;
  FrameCollection.FullExpand;
end;

procedure TzFrameEditor_DbView.Init;
begin
  inherited;

  if not Assigned(item) then
    Exit;

  Clear; // tutti i riferimenti precedenti, evita AV a iosa

  Caption := 'Vista: ' + item.Name;
  Internal_zDbViewProps.Assign(item);

  InspectorDbView.Add(Internal_zDbViewProps);
  FillTreeList;
end;

procedure TzFrameEditor_DbView.Apply;
begin
  inherited;
  if not Assigned(item) then
    Exit;

  item.Assign(Internal_zDbViewProps);
end;

procedure TzFrameEditor_DbView.FrameCollectionInspectorModified(Sender: TObject);
begin
  inherited;
  if Sender is TzObjectInspector then
    if TzObjectInspector(Sender).FocusedRow is TcxPropertyRow then
      if SameText(TcxPropertyRow(TzObjectInspector(Sender).FocusedRow).Properties.Caption, 'visible') then
        TreeSetVisible;
end;

procedure TzFrameEditor_DbView.FrameCollectionNodeChecked(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
var
  item: TzColumn;
begin
  if Assigned(ANode) then
  begin
    item := TzColumn(FrameCollection.GetCollectionItem(ANode));
    if Assigned(item) then
    begin
      item.Visible := FrameCollection.IsChecked(ANode);
      // Refresh e non Add: la colonna e' gia' nell'inspector (il clic la
      // seleziona), e Add non ridisegna i valori, cosi' Visible restava
      // quello di prima finche' non si cambiava riga
      FrameCollection.FrameObjectInspector.Refresh;
    end;
  end;
end;

procedure TzFrameEditor_DbView.OnModified(Sender: TObject);
begin
  if Sender is TzObjectInspector then
    if TzObjectInspector(Sender).FocusedRow is TcxPropertyRow then
      if SameText(TcxPropertyRow(TzObjectInspector(Sender).FocusedRow).Properties.Caption, 'visible') then
        TreeSetVisible;
end;

procedure TzFrameEditor_DbView.TreeSetVisible;
begin
  FrameCollection.ForEachItemNode(
    procedure(Node: TcxTreeListNode; item: TzCollectionItem)
    begin
      FrameCollection.SetChecked(Node, TzColumn(item).Visible);
    end);
end;

function TzFrameEditor_DbView.WindowState: TWindowState;
begin
  result := wsNormal;
end;

end.
