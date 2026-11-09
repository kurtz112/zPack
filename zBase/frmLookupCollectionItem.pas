unit frmLookupCollectionItem;

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
  Frame_Collection,
  OkCancel,
  zCollection,
  vcl.ImgList,
  System.ImageList;

type
  TFormLookupCollectionItem = class(TForm)
    OkCancel: TOkCancel;
    CollectionImageList: TImageList;
    FrameCollection: TFrameCollection;
    procedure FormShow(Sender: TObject);
  private
    Item: TzCollectionItem;
  public
    function Edit(Collection: TzCustomCollection; var aItem: TzCollectionItem): boolean;
  end;

function zExecuteLookupCollectionItem(Collection: TzCustomCollection; var aItem: TzCollectionItem): boolean;

implementation

{$R *.dfm}
{ TFormLkDictionary }

function zExecuteLookupCollectionItem(Collection: TzCustomCollection; var aItem: TzCollectionItem): boolean;
var
  FormLookupCollectionItem: TFormLookupCollectionItem;
begin
  result := false;
  FormLookupCollectionItem := TFormLookupCollectionItem.Create(Application);
  try
    result := FormLookupCollectionItem.Edit(Collection, aItem);
  finally
    FreeAndNil(FormLookupCollectionItem);
  end;
end;

function TFormLookupCollectionItem.Edit(Collection: TzCustomCollection; var aItem: TzCollectionItem): boolean;
begin
  result := false;

  if not Assigned(Collection) then
    Exit;

  FrameCollection.AddCollections(Collection);
  Item := aItem;
  result := ShowModal = mrOk;
  if result then
  begin
    if FrameCollection.SelectedNode <> nil then
      if FrameCollection.IsCollectionItemNode(FrameCollection.SelectedNode) then
        aItem := FrameCollection.GetCollectionItem(FrameCollection.SelectedNode);
  end;
end;

procedure TFormLookupCollectionItem.FormShow(Sender: TObject);
begin
  if Assigned(Item) then
    FrameCollection.SelectCollectionItem(Item);
end;

end.
