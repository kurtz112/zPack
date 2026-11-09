unit Form_Editor_JSON;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  OkCancel,
  Frame_Editor_JSON;

type
  TFormEditorJSON = class(TForm)
    OkCancel: TOkCancel;
    EditorJSON: TFrameEditor_JSON;
  public
    function EditJSON(var JSON: string; const caption: string; const readonly: boolean = false): boolean;
  end;

function EditJSON(var JSON: string; const caption: string; const readonly: boolean = false): boolean;

implementation

{$R *.dfm}

function EditJSON(var JSON: string; const caption: string; const readonly: boolean = false): boolean;
var
  FormEditorJSON: TFormEditorJSON;
begin
  Application.CreateForm(TFormEditorJSON, FormEditorJSON);
  try
    result := FormEditorJSON.EditJSON(JSON, caption, readonly);
  finally
    FreeAndNil(FormEditorJSON);
  end;
end;

function TFormEditorJSON.EditJSON(var JSON: string; const caption: string; const readonly: boolean = false): boolean;
begin
  Self.caption := caption;

  EditorJSON.JSON := JSON;

  EditorJSON.readonly := ReadOnly;
  OkCancel.readonly := ReadOnly;

  result := ShowModal = mrOk;

  if result then
    JSON := EditorJSON.JSON;
end;

end.OkCancel

  OkCancel
