unit zz.base.editor._form;

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
  zCollection,
  zSystem,
  zz.base.editor._frame,
  OkCancel;

type
  TzFormEditorCollectionItem = class(TForm)
    OkCancel: TOkCancel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure OkCancelApply(Sender: TObject);
  private
    ItemEditor: TzFrameEditorCollectionItem;
    onApply: TNotifyEvent;
  public
    function Edit(zSystem: TzSystem; Item: TzCollectionItem; aOnApply: TNotifyEvent = nil): Boolean;
  end;

function Edit_CollectionItem(zSystem: TzSystem; Item: TzCollectionItem; aOnApply: TNotifyEvent = nil): Boolean;

implementation

uses
  zz.base.editor._factory;

{$R *.dfm}

function Edit_CollectionItem(zSystem: TzSystem; Item: TzCollectionItem; aOnApply: TNotifyEvent = nil): Boolean;
var
  zFormEditorCollectionItem: TzFormEditorCollectionItem;
begin
  if not Assigned(zSystem) then
    Exit;

  if not Assigned(Item) then
    Exit;

  // if not Assigned(zFormEditorCollectionItem) then //var locale
  Application.CreateForm(TzFormEditorCollectionItem, zFormEditorCollectionItem);
  try
    Result := zFormEditorCollectionItem.Edit(zSystem, Item, aOnApply);
  finally
    FreeAndNil(zFormEditorCollectionItem);
  end;
end;

procedure TzFormEditorCollectionItem.FormCreate(Sender: TObject);
begin
  Width := 604;
  Height := 480;
end;

procedure TzFormEditorCollectionItem.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;

  if Assigned(ItemEditor) then
  begin
    try
      CanClose := ItemEditor.CanClose(ModalResult);
    except
      on e: exception do
      begin
        Application.HandleException(e);
      end;
    end;
  end;
end;

function TzFormEditorCollectionItem.Edit(zSystem: TzSystem; Item: TzCollectionItem; aOnApply: TNotifyEvent = nil): Boolean;
var
  EditorClass: TzFrameEditorCollectionItemClasses;
begin
  Result := false;

  EditorClass := GetEditorClass(Item);

  if not Assigned(EditorClass) then
    Exit;

  ItemEditor := EditorClass.Create(Self);
  ItemEditor.Parent := Self;
  ItemEditor.Align := alClient;

  ItemEditor.zSystem := zSystem;
  ItemEditor.Item := Item;
  ItemEditor.Init;

  if ItemEditor.GetEditorCaption <> '' then
    Caption := ItemEditor.GetEditorCaption;

  WindowState := ItemEditor.WindowState;

  if ItemEditor.GetDialogHeight > 0 then
    Height := ItemEditor.GetDialogHeight;

  // Il controllo e' sulla larghezza: con quello sull'altezza una larghezza 0
  // passava e la finestra si riduceva al minimo di Windows.
  if ItemEditor.GetDialogWidth > 0 then
    Width := ItemEditor.GetDialogWidth;

  onApply := aOnApply;

  if Assigned(onApply) then
    OkCancel.onApply := OkCancelApply
  else
    OkCancel.onApply := nil;

  Result := ShowModal = mrOk;

  if Result then
    ItemEditor.Apply;
end;

procedure TzFormEditorCollectionItem.OkCancelApply(Sender: TObject);
begin
  if Assigned(onApply) then
  begin
    ItemEditor.Apply;
    onApply(Self);
  end;
end;

end.
