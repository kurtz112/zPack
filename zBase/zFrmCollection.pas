unit zFrmCollection;

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
  zCollection,
  OkCancel,
  Frame_Collection;

type
  TzFormCollection = class(TForm)
    FrameCollection: TFrameCollection;
    OkCancel: TOkCancel;
  public
    function EditCollections(zCollectionArray: array of TzCustomCollection; proc: TProc<TzFormCollection> = nil): boolean;
  end;

var
  zFormCollection: TzFormCollection;

function Edit_zCollections(zCollectionArray: array of TzCustomCollection; proc: TProc<TzFormCollection> = nil): boolean;

implementation

{$R *.dfm}

function Edit_zCollections(zCollectionArray: array of TzCustomCollection; proc: TProc<TzFormCollection> = nil): boolean;
begin
  if Assigned(zFormCollection) then // evita di essere chiamata da se stessa...
    Exit;

  if not Assigned(zFormCollection) then
    Application.CreateForm(TzFormCollection, zFormCollection);
  try
    Result := zFormCollection.EditCollections(zCollectionArray, proc);
  finally
    FreeAndNil(zFormCollection);
  end;
end;

{ TzFormCollection }

function TzFormCollection.EditCollections(zCollectionArray: array of TzCustomCollection; proc: TProc<TzFormCollection> = nil): boolean;
begin
  FrameCollection.AddCollections(zCollectionArray);

  if Assigned(proc) then
    proc(self);

  Result := ShowModal = mrOk;
  FrameCollection.Clear;
end;

end.
