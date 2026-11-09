unit FrmApplicationInspector;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Frame_ObjectInspector,
  ComCtrls,
  ExtCtrls,
  Menus,
  ToolWin,
  ActnList,
  ImgList,
  StdActns,
  cxClasses,
  dxBar,
  System.Actions,
  System.ImageList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxSplitter,
  cxContainer,
  cxEdit,
  cxTreeView,
  dxStatusBar,
  dxBarBuiltInMenu,
  cxPC,
  cxImageList,
  cxButtonEdit,
  cxCheckBox,
  cxBarEditItem,
  cxTextEdit,
  dxFileActions,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  dxUIAClasses,
  cxFilter,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer;

type
  TFormApplicationInspector = class(TForm)
    ActionList1: TActionList;
    imgTree: TcxImageList;
    PopupMenu1: TPopupMenu;
    Splitter1: TcxSplitter;
    StatusBar1: TdxStatusBar;
    // Era un TzPropertyInspector (zObjectInspector): griglia disegnata a mano
    // che prendeva dallo skin solo sfondo e caratteri, e il DFM le imponeva
    // Font.Color = clBlack dopo UpdateColors, titoli illeggibili sugli skin
    // scuri. Il frame incapsula TzObjectInspector (cxOI), skinnato per natura
    // e gia' usato da zSystemFrm e zFrmInspector. I riferimenti a componenti
    // li risolve cxOI da solo (TcxComponentProperty, nome completo
    // Owner.Nome), quindi i tre gestori OnGetComponent* non servono piu'.
    FrameObjectInspector: TFrameObjectInspector;
    tree: TcxTreeList;
    SaveDFM: TdxFileSaveAs;
    dxBarManager: TdxBarManager;
    dxBarButtonSaveDFM: TdxBarButton;
    dxBarTBbar: TdxBar;
    timerFiltri: TTimer;
    treeColumnName: TcxTreeListColumn;
    treeColumnClass: TcxTreeListColumn;
    procedure FormShow(Sender: TObject);
    procedure SaveDFMAccept(Sender: TObject);
    procedure treeSelectionChanged(Sender: TObject);
  private
    WasActiveComp: TComponent;
    function FindNode(comp: TComponent): TcxTreeListNode;
    procedure FillTreeView;
    procedure SelectActiveControl;
  public
    constructor Create(aOwner: TComponent); override;
    procedure Edit;
  end;

procedure ShowApplicationInspector;

implementation

uses
  zBaseLib,
  SmartInspect.Vcl.SiAuto,
  zWaitFrm,
  baseFrm,
  zDX;
{$R *.dfm}

procedure ShowApplicationInspector;
var
  FormApplicationInspector: TFormApplicationInspector;
begin
  Application.CreateForm(TFormApplicationInspector, FormApplicationInspector);
  try
    FormApplicationInspector.Edit;
  finally
    FreeAndNil(FormApplicationInspector);
  end;
end;

{ TFormApplicationInspector }

constructor TFormApplicationInspector.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
end;

procedure TFormApplicationInspector.Edit;
begin
  WasActiveComp := Screen.ActiveControl;

  FillTreeView;

  // if fsModal in screen.ActiveForm.FormState then
  ShowModal;
  // else
  // Show;
end;

procedure TFormApplicationInspector.FillTreeView;
var
  Node: TcxTreeListNode;
  i: Integer;
  ImageIndex: Integer;

  procedure Add(MasterNode: TcxTreeListNode; Component: TComponent; ImageIndex: Integer);
  var
    i, x: Integer;
    Node, Child: TcxTreeListNode;

    function GetName(Component: TComponent): string;
    begin
      if Component.Name = '' then
        Result := '(noname) : ' + Component.ClassName
      else
        Result := Component.Name;// + ': ' + Component.ClassName;
    end;

  begin
    Node := MasterNode;

    if Assigned(Node) then
      Node := tree.AddChild(Node, Component)
    else // root
    begin
      Node := tree.Add;
      Node.Data := Component;
    end;

    Node.Texts[0] := GetName(Component);
    Node.Texts[1] := Component.ClassName;
    Node.ImageIndex := ImageIndex;
    Node.SelectedIndex := ImageIndex;

    for i := 0 to Component.ComponentCount - 1 do
    begin
      Child := tree.AddChild(Node, Component.Components[i]);
      Child.Texts[0] := GetName(Component.Components[i]);
      Child.Texts[1] := Component.Components[i].ClassName;
      Child.ImageIndex := ImageIndex;
      Child.SelectedIndex := ImageIndex;

      for x := 0 to Component.Components[i].ComponentCount - 1 do
        Add(Child, Component.Components[i].Components[x], ImageIndex);
    end;
  end;

begin
  StartWait('Attedere...', True);
  try
    FrameObjectInspector.Clear;

    tree.BeginUpdate;
    try
      tree.Clear;

      Node := tree.Add;
      Node.Texts[0] := 'Application';
      Node.Data := Application;
      Node.ImageIndex := 0;

      for i := 0 to Application.ComponentCount - 1 do
        if not(Application.Components[i] is TCustomForm) then
          if not(Application.Components[i] is TDataModule) then
            Add(Node, Application.Components[i], ImageIndex);

      ImageIndex := 1;
      Node := tree.Add;
      Node.Texts[0] := 'Forms';
      Node.ImageIndex :=ImageIndex;
      for i := 0 to Screen.CustomFormCount - 1 do
        if not(Screen.CustomForms[i] is TBaseForm) then
          Add(Node, Screen.CustomForms[i], ImageIndex);

      ImageIndex := 2;
      Node := tree.Add;
      Node.Texts[0] := 'dbForms';
      Node.ImageIndex :=ImageIndex;
      for i := 0 to Screen.CustomFormCount - 1 do
        if Screen.CustomForms[i] is TBaseForm then
          Add(Node, Screen.CustomForms[i], ImageIndex);

      ImageIndex := 3;
      Node := tree.Add;
      Node.Texts[0] := 'DataModules';
      Node.ImageIndex :=ImageIndex;
      for i := 0 to Screen.DataModuleCount - 1 do
        Add(Node, Screen.DataModules[i], ImageIndex);
    finally
      tree.EndUpdate;
    end;
  finally
    StopWait;
  end;
end;

function TFormApplicationInspector.FindNode(comp: TComponent): TcxTreeListNode;
var
  i: Integer;
  Node: TcxTreeListNode;
begin
  Result := nil;

  for i := 0 to tree.AbsoluteCount - 1 do
    if tree.AbsoluteItems[i].Data = comp then
    begin
      Result := Node;
      exit;
    end;
end;

procedure TFormApplicationInspector.SaveDFMAccept(Sender: TObject);
var
  Persistent: TPersistent;
begin
  Persistent := nil;

  if tree.SelectionCount = 0 then
    exit;

  Persistent := TPersistent(tree.Selections[0].Data);

  if Assigned(Persistent) then
    if Persistent is TComponent then
      zBaseLib.ComponentToDFM(Persistent as TComponent, SaveDFM.Dialog.FileName, nil);
end;

procedure TFormApplicationInspector.treeSelectionChanged(Sender: TObject);
var
  i: Integer;
  Persistent: TPersistent;
begin
  FrameObjectInspector.Clear;

  for i := 0 to tree.SelectionCount - 1 do
  begin
    Persistent := nil;
    Persistent := TPersistent(tree.Selections[i].Data);
    if Assigned(Persistent) then
      FrameObjectInspector.Add(Persistent);
  end;
  // niente UpdateSplitterPos: il frame crea l'inspector con AutoSplitter
end;

procedure TFormApplicationInspector.FormShow(Sender: TObject);
begin
  tree.ApplyBestFit;
  SelectActiveControl;
end;

procedure TFormApplicationInspector.SelectActiveControl;
var
  Node: TcxTreeListNode;
begin

  if not visible then
    exit;

  Node := nil;
  if not Assigned(WasActiveComp) then
    Node := FindNode(WasActiveComp);

  if Assigned(Node) then
  begin
    Node.Focused := True;
    Node.Selected := True;
    Node.MakeVisible;
  end;
end;

end.


