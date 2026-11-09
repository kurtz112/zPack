unit Form_Editor_SQL;

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
  Frame_Editor_SQL;

type
  TFormEditorSQL = class(TForm)
    OkCancel: TOkCancel;
    EditorSQL: TFrameEditor_Sql;
    procedure EditorSQLFormatSQL(Sender: TObject);
  public
    function EditSQL(var SQL: string; const caption: string; const readonly: boolean = false): boolean;
  end;

function EditSQL(var SQL: string; const caption: string; const readonly: boolean = false): boolean;

implementation

uses
  SQLFormatter;

{$R *.dfm}

function EditSQL(var SQL: string; const caption: string; const readonly: boolean = false): boolean;
var
  FormEditorSQL: TFormEditorSQL;
begin
  Application.CreateForm(TFormEditorSQL, FormEditorSQL);
  try
    result := FormEditorSQL.EditSQL(SQL, caption, readonly);
  finally
    FreeAndNil(FormEditorSQL);
  end;
end;

procedure TFormEditorSQL.EditorSQLFormatSQL(Sender: TObject);
begin
  EditorSQL.SQL := FormatFirebirdSQL(EditorSQL.SQL);
end;

function TFormEditorSQL.EditSQL(var SQL: string; const caption: string; const readonly: boolean = false): boolean;
begin
  Self.caption := caption;

  EditorSQL.SQL := SQL;

  EditorSQL.readonly := ReadOnly;
  OkCancel.readonly := ReadOnly;

  result := ShowModal = mrOk;

  if result then
    SQL := EditorSQL.SQL;
end;

end.OkCancel

  OkCancel
