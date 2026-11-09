unit Lib_Script;

interface

uses Classes,
  Forms;

procedure AddForm2Script(Form: TComponent);

implementation
uses
  fs_iinterpreter;

procedure AddForm2Script(Form: TComponent);
begin
  fsGlobalUnit.AddForm(Form);
end;

initialization
//fsGlobalUnit.AddClass(TzIboDataSet, 'TDataSet');
end.

