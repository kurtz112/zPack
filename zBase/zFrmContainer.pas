unit zFrmContainer;

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
  OkCancel;

type
  TzFormContainer = class(TForm)
    OkCancel1: TOkCancel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function zShowControl(Control: TWinControl): Boolean;

implementation

{$R *.dfm}

function zShowControl(Control: TWinControl): Boolean;
var
  zFormContainer: TzFormContainer;
  oldParent: TWinControl;

begin
  Result := false;
  if not Assigned(Control) then
    Exit;

  zFormContainer := TzFormContainer.Create(Application);
  try

    oldParent := Control.Parent;
    Control.Parent := zFormContainer;
    try
      Result := zFormContainer.ShowModal = mrOk;
    finally
      Control.Parent := oldParent;
    end;
  finally
    FreeAndNil(zFormContainer);
  end;

end;
end.

