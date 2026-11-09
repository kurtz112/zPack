unit zz.base.editor._frame;

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
  zSystem;

type
  TzFrameEditorCollectionItem = class(TFrame)
  private
    FInitialized: Boolean;
    FzSystem: TzSystem;
    FItem: TzCollectionItem;
    procedure SetzSystem(const Value: TzSystem);
    procedure SetItem(const Value: TzCollectionItem);
  public
    constructor Create(aOwner: TComponent); override;
    procedure Apply; virtual;
    procedure Clear; virtual;
    procedure Init; virtual;

    function CanClose(ModalResult: TModalResult): Boolean; virtual;
    function GetEditorCaption: string; virtual;

    function GetDialogWidth: integer; virtual;
    function GetDialogHeight: integer; virtual;

    function WindowState: TWindowState; virtual;
  public
    property Initialized: Boolean read FInitialized;
    property Item: TzCollectionItem read FItem write SetItem;
    property zSystem: TzSystem read FzSystem write SetzSystem;
  end;

  TzFrameEditorCollectionItemClasses = class of TzFrameEditorCollectionItem;

implementation

{$R *.dfm}
{ TzFrameEditorCollectionItem }

constructor TzFrameEditorCollectionItem.Create(aOwner: TComponent);
begin
  inherited;
  FInitialized := false;
  FzSystem := nil;
  FItem := nil;
end;

procedure TzFrameEditorCollectionItem.Apply;
begin

end;

function TzFrameEditorCollectionItem.CanClose(ModalResult: TModalResult): Boolean;
begin
  result := true;
end;

procedure TzFrameEditorCollectionItem.Clear;
begin
  FInitialized := false;
end;

function TzFrameEditorCollectionItem.GetDialogHeight: integer;
begin
  result := 0;
end;

function TzFrameEditorCollectionItem.GetDialogWidth: integer;
begin
  result := 0;
end;

function TzFrameEditorCollectionItem.GetEditorCaption: string;
begin
  result := '';
end;

procedure TzFrameEditorCollectionItem.Init;
begin
  FInitialized := true;
end;

procedure TzFrameEditorCollectionItem.SetItem(const Value: TzCollectionItem);
begin
  FItem := Value;

  If not Assigned(FItem) then
    FInitialized := false;
end;

procedure TzFrameEditorCollectionItem.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
end;

function TzFrameEditorCollectionItem.WindowState: TWindowState;
begin
  result := wsMaximized;
end;

end.

  Assertion failure
(X: \ Druido \ LIB \ zPack \ zBase \ zz.base.editor.DataSet.pas, line 1019)



