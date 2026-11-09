unit zLz.JsonExport;

// ==============================================================================
// Esportazione su cartella del contenuto dell'LZ in JSON e dei relativi JSON
// Schema, per la modifica assistita (Claude, jq, Python) e la validazione
// prima della reimportazione.
//
// Uso tipico da un'azione riservata all'amministratore:
//   ExportLzJson(Base, 'D:\AI\SRC\WT\LZ\json');
//   ExportLzJsonSchemas(Base, 'D:\AI\SRC\WT\LZ\schema');
//
// Le collection si ricavano dalla RTTI di TzSystem (proprieta' published di
// tipo TzCustomCollection), cosi' una collection nuova viene esportata senza
// toccare questa unit. MetaData (TzMetadata) viene esportato come oggetto con
// una sezione per collection.
// ==============================================================================

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  zCollection,
  zCollection.Json,
  zSystem;

// Scrive <Folder>\<ClassName>.json per ogni collection e <Folder>\MetaData.json.
procedure ExportLzJson(ASystem: TzSystem; const Folder: string);

// Scrive <Folder>\<ClassName>.schema.json per ogni collection e
// <Folder>\MetaData.schema.json.
procedure ExportLzJsonSchemas(ASystem: TzSystem; const Folder: string);

implementation

type
  TCollectionProc = reference to procedure(Collection: TzCustomCollection; const FileBaseName: string);

procedure ForEachCollection(ASystem: TzSystem; Proc: TCollectionProc);
var
  Ctx: TRttiContext;
  Prop: TRttiProperty;
  Obj: TObject;
begin
  Ctx := TRttiContext.Create;
  try
    for Prop in Ctx.GetType(ASystem.ClassType).GetProperties do
    begin
      if Prop.Visibility <> mvPublished then
        Continue;
      if Prop.PropertyType.TypeKind <> tkClass then
        Continue;

      Obj := Prop.GetValue(ASystem).AsObject;
      if Obj is TzCustomCollection then
        Proc(TzCustomCollection(Obj), Obj.ClassName);
    end;
  finally
    Ctx.Free;
  end;
end;

procedure ExportLzJson(ASystem: TzSystem; const Folder: string);
var
  Stream: TFileStream;
begin
  ForceDirectories(Folder);

  ForEachCollection(ASystem,
    procedure(Collection: TzCustomCollection; const FileBaseName: string)
    var
      FileStream: TFileStream;
    begin
      if Collection.Count = 0 then
        Exit;

      FileStream := TFileStream.Create(IncludeTrailingPathDelimiter(Folder) + FileBaseName + '.json', fmCreate);
      try
        TzCollectionJson.SaveToStream(Collection, FileStream);
      finally
        FileStream.Free;
      end;
    end);

  Stream := TFileStream.Create(IncludeTrailingPathDelimiter(Folder) + 'MetaData.json', fmCreate);
  try
    TzCollectionJson.SaveComponentToStream(ASystem.MetaData, Stream);
  finally
    Stream.Free;
  end;
end;

procedure ExportLzJsonSchemas(ASystem: TzSystem; const Folder: string);
var
  Stream: TFileStream;
begin
  ForceDirectories(Folder);

  ForEachCollection(ASystem,
    procedure(Collection: TzCustomCollection; const FileBaseName: string)
    var
      FileStream: TFileStream;
    begin
      FileStream := TFileStream.Create(IncludeTrailingPathDelimiter(Folder) + FileBaseName + '.schema.json', fmCreate);
      try
        TzCollectionJson.WriteSchema(Collection, FileStream, FileBaseName);
      finally
        FileStream.Free;
      end;
    end);

  Stream := TFileStream.Create(IncludeTrailingPathDelimiter(Folder) + 'MetaData.schema.json', fmCreate);
  try
    TzCollectionJson.WriteComponentSchema(ASystem.MetaData, Stream, 'MetaData');
  finally
    Stream.Free;
  end;
end;

end.
