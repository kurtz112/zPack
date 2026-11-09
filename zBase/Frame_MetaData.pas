unit Frame_MetaData;

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
  zMetadata,
  ImgList,
  ExtCtrls,
  Grids,
  ComCtrls,
  Frame_ObjectInspector,
  zSystem,
  Frame_TreeView,
  Frame_Collection,
  System.ImageList;

type
  TFrameMetadata = class(TFrame)
    FrameCollection: TFrameCollection;
    zImageList: TImageList;
  private
    FInitialized: Boolean;
    FzSystem: TzSystem;
    procedure FillTreeView;
    procedure ClearMetadata;
    function MetaDataOk: Boolean;
    procedure SetInitialized(const Value: Boolean);
    procedure SetzSystem(const Value: TzSystem);
    { Private declarations }
  public
    constructor Create(aOwner: TComponent); override;
    procedure Init;
    procedure Clear;
    procedure UpdateMetadata;
    property Initialized: Boolean read FInitialized write SetInitialized;
  published
    property zSystem: TzSystem read FzSystem write SetzSystem;
    { Public declarations }
  end;

implementation

{$R *.dfm}
{ TFormMetadata }

procedure TFrameMetadata.ClearMetadata;
begin
  FrameCollection.Clear;
end;

constructor TFrameMetadata.Create(aOwner: TComponent);
begin
  inherited;
  FInitialized := False;
end;

procedure TFrameMetadata.Clear;
begin
  ClearMetadata;
end;

procedure TFrameMetadata.FillTreeView;
var
  OldCursor: TCursor;
begin
  if not MetaDataOk then
    Exit;

  if Initialized then
    Exit;

  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    FrameCollection.Clear;
    FrameCollection.AddCollections([zSystem.Metadata.Domains, zSystem.Metadata.Tables, zSystem.Metadata.Views, zSystem.Metadata.Procedures, zSystem.Metadata.Triggers, zSystem.Metadata.Generators, zSystem.Metadata.Functions,
      zSystem.Metadata.PickLists, zSystem.Metadata.Lookups, zSystem.Metadata.DataDictionary]);
  finally
    Screen.Cursor := OldCursor;
  end;

  Initialized := True;
end;

function TFrameMetadata.MetaDataOk: Boolean;
begin
  result := False;
  if Assigned(zSystem) then
    if zSystem.Metadata <> nil then
      result := True;
end;

procedure TFrameMetadata.Init;
begin
  if MetaDataOk then
    FillTreeView
  else
    ClearMetadata;
end;

procedure TFrameMetadata.SetInitialized(const Value: Boolean);
begin
  FInitialized := Value;
end;

procedure TFrameMetadata.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
end;

procedure TFrameMetadata.UpdateMetadata;
begin
  if Initialized then
    if MetaDataOk then
      FillTreeView;
end;

end.

  zsystemfrm rm

  zbaselib

  img_MetaDataDomains = 0; img_MetaDataTables = 1; img_MetaDataViews = 2; img_MetaDataFields = 3; img_MetaDataPrimaryKeys = 4; img_MetaDataForeignKeys = 5; img_MetaDataProcedures = 6; img_MetaDataParamsInput = 7; img_MetaDataParamsOutput = 8;
img_MetaDataGenerators = 9; img_MetaDataFunctions = 10; img_MetaDataTriggers = 11; img_MetaDataCheckConstraints = 12; img_MetaDataUniqueConstraints = 13;

zMetadata
