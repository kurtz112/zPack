unit dbMasterCompEd;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  DB,
  DesignEditors,
  DesignIntf,
  dbMaster;

type
  TdbMasterEditor = class(TComponentEditor)
    function GetVerbCount: integer; override;
    function GetVerb(Index: integer): string; override;
    procedure ExecuteVerb(Index: integer); override;
    procedure AddAllTables;
  end;

implementation

function TdbMasterEditor.GetVerbCount: integer;
begin
  Result := 3;
end;

function TdbMasterEditor.GetVerb(Index: integer): string;
begin
  case index of
    0:
      Result := 'Open Datasets';
    1:
      Result := 'Close Datasets';
    2:
      Result := 'Add all tables';
  end;
end;

procedure TdbMasterEditor.ExecuteVerb(Index: integer);
begin
  case index of
    0:
      TdbMaster(Component).OpenInDesigner := true;
    1:
      TdbMaster(Component).OpenInDesigner := false;
    2:
      AddAllTables;
  end;
  Designer.Modified;
end;

procedure TdbMasterEditor.AddAllTables;
var
  i, Index: integer;
  found: boolean;
begin
  if not assigned(TdbMaster(Component).Owner) then
    exit;
  with TdbMaster(Component).Owner do
  begin
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TDataset then
      begin
        found := false;
        for index := 0 to TdbMaster(Component).DataSets.Count - 1 do
          if TdbMaster(Component).DataSets[index].DisplayName = (Components[i] as TDataset).Name then
            found := true;
        if not found then
          with TDataSetItem(TdbMaster(Component).DataSets.Add) do
          begin
            DisplayName := (TdbMaster(Component).Owner.Components[i] as TDataset).Name;
            DataSet := Components[i] as TDataset;
          end;
      end;
  end;
end;

end.
