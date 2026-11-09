unit zz.base.editor._factory;

interface

uses
  zCollection,
  zSystem,
  zz.base.editor._frame;

function GetEditorClass(Item: TzCollectionItem): TzFrameEditorCollectionItemClasses;

implementation

uses
  zz.base.editor.DbView,
  zz.base.editor.DbCard,
  zz.base.editor.DbPivot,
  zz.base.editor.DataSet,
  zz.base.editor.DataModule,
  zz.base.editor.Lookup;

function GetEditorClass(Item: TzCollectionItem): TzFrameEditorCollectionItemClasses;
begin
  Result := nil;
  if not Assigned(Item) then
    Exit;

  if Item is TzDataSet then
    Result := TzFrameEditor_DataSet
  else
    if Item is TzDbViewProps then
      Result := TzFrameEditor_DbView
    else
      if Item is TzDbCardProps then
        Result := TzFrameEditor_DbCard
      else
        if Item is TzLookup then
          Result := TzFrameEditor_Lookup
        else
          if Item is TzDataModule then
            Result := TFrameEditor_DataModule
          else
            if Item is TzDbPivotProps then
              Result := TzFrameEditor_DbPivot;
end;

end.



zdbcard
