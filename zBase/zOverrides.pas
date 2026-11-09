unit zOverrides;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client;

//
// Rimuovere la tabella ZZ_CUSTOM_DATASETS !!!!!!!!!!!!!!!!!!!
//
type
  // -------------------------------------------------------------------
  // Flag presenti in un override – usato sia per sapere cosa è impostato
  // sia come maschera in FindOverride
  // -------------------------------------------------------------------
  // ofForceRequired, ofForceReadOnly, ofForceHidden, ofSuppressDefault sono NOT NULL DEFAULT FALSE:
  // compaiono in ActiveFlags solo se TRUE (= forzatura attiva).
  // ofCaptionCard, ofCaptionGrid sono nullable: compaiono in ActiveFlags se NOT NULL.
  TOverrideFlag = (ofCaptionCard, ofCaptionGrid, ofForceRequired, ofForceReadOnly, ofForceHidden, ofSuppressDefault);
  TOverrideFlags = set of TOverrideFlag;

  // -------------------------------------------------------------------
  // TOverrideItem
  // FActiveFlags indica quali campi sono effettivamente sovrascritti
  // (corrisponde ai NOT NULL lato DB)
  // -------------------------------------------------------------------
  TOverrideItem = class(TCollectionItem)
  private
    FDataset: string;
    FFieldName: string;
    FCaptionCard: string;
    FCaptionGrid: string;
    FForceRequired: Boolean;
    FForceReadOnly: Boolean;
    FForceHidden: Boolean;
    FSuppressDefault: Boolean;
    FNote: string;
    FActiveFlags: TOverrideFlags;

    function GetKey: string;
  public
    procedure Assign(Source: TPersistent); override;

    // Chiave di lookup (uppercase, es. 'STUDENTI.COGNOME')
    property Key: string read GetKey;
    // Per i flag NOT NULL (ForceRequired/ReadOnly/Hidden/SuppressDefault): presente in ActiveFlags solo se TRUE.
    // Per le caption nullable: presente in ActiveFlags se NOT NULL.
    property ActiveFlags: TOverrideFlags read FActiveFlags write FActiveFlags;
  published
    property Dataset: string read FDataset write FDataset;
    property FieldName: string read FFieldName write FFieldName;
    property CaptionCard: string read FCaptionCard write FCaptionCard;
    property CaptionGrid: string read FCaptionGrid write FCaptionGrid;
    property ForceRequired: Boolean read FForceRequired write FForceRequired;
    property ForceReadOnly: Boolean read FForceReadOnly write FForceReadOnly;
    property ForceHidden: Boolean read FForceHidden write FForceHidden;
    property SuppressDefault: Boolean read FSuppressDefault write FSuppressDefault;
    property Note: string read FNote write FNote;
  end;

  // -------------------------------------------------------------------
  // TOverrideCollection
  // -------------------------------------------------------------------
  TOverrideCollection = class(TCollection)
  public
    constructor Create;
    function Add: TOverrideItem;
    function Items(Index: Integer): TOverrideItem;
    function FindItem(const Dataset, FieldName: string): TOverrideItem;
  end;

  // -------------------------------------------------------------------
  // TOverrideManager  – singleton, lookup O(1)
  // -------------------------------------------------------------------
  TOverrideManager = class(TPersistent)
  private
    FOverrides: TOverrideCollection;
    FIndex: TDictionary<string, TOverrideItem>;
    FDatasetIndex: TDictionary<string, Boolean>; // dataset uppercase -> True (presenza rapida)
    FLoaded: Boolean;

    procedure RebuildIndex;
  public
    constructor Create;
    destructor Destroy; override;

    // Carica all'avvio
    procedure LoadFromDB(Connection: TFDConnection);

    // Salva un singolo item tramite SP OVERRIDE_SAVE
    function Add(const Dataset, FieldName: string): TOverrideItem;
    procedure Remove(OverrideItem: TOverrideItem);
    procedure SaveItem(Item: TOverrideItem; Connection: TFDConnection);

    // Lookup O(1) – nil se non esiste alcun override
    function FindOverride(const Dataset, FieldName: string): TOverrideItem;

    // True se esiste almeno un override per il dataset (overload senza FieldName)
    // True se esiste almeno uno dei flag richiesti per quel campo (overload con FieldName)
    // Passare Flags=[] per verificare solo l'esistenza del record/dataset
    function OverrideExists(const Dataset: string; Flags: TOverrideFlags = []): Boolean; overload;
    function OverrideExists(const Dataset, FieldName: string; Flags: TOverrideFlags = []): Boolean; overload;

    // Caption helpers: restituiscono la caption override se presente, '' altrimenti.
    // Uso tipico: Caption := Overrides.CaptionGrid(idDataSet, FieldName);
    // if Caption.IsEmpty then ... (applica priorità inferiori)
    function CaptionGrid(const Dataset, FieldName: string): string;
    function CaptionCard(const Dataset, FieldName: string): string;

    property Overrides: TOverrideCollection read FOverrides;
    property Loaded: Boolean read FLoaded;
  end;

function Overrides: TOverrideManager;

implementation

// -------------------------------------------------------------------
// Singleton
// -------------------------------------------------------------------
var
  GOverrides: TOverrideManager = nil;

function Overrides: TOverrideManager;
begin
  if GOverrides = nil then
    GOverrides := TOverrideManager.Create;
  Result := GOverrides;
end;

function BuildKey(const Dataset, FieldName: string): string;
begin
  Result := UpperCase(Dataset + '.' + FieldName);
end;

// -------------------------------------------------------------------
// TOverrideItem
// -------------------------------------------------------------------
function TOverrideItem.GetKey: string;
begin
  Result := BuildKey(FDataset, FFieldName);
end;

procedure TOverrideItem.Assign(Source: TPersistent);
var
  S: TOverrideItem;
begin
  if Source is TOverrideItem then
  begin
    S := TOverrideItem(Source);
    FDataset := S.FDataset;
    FFieldName := S.FFieldName;
    FCaptionCard := S.FCaptionCard;
    FCaptionGrid := S.FCaptionGrid;
    FForceRequired := S.FForceRequired;
    FForceReadOnly := S.FForceReadOnly;
    FForceHidden := S.FForceHidden;
    FSuppressDefault := S.FSuppressDefault;
    FNote := S.FNote;
    FActiveFlags := S.FActiveFlags;
  end
  else
    inherited;
end;

// -------------------------------------------------------------------
// TOverrideCollection
// -------------------------------------------------------------------
constructor TOverrideCollection.Create;
begin
  inherited Create(TOverrideItem);
end;

function TOverrideCollection.Add: TOverrideItem;
begin
  Result := TOverrideItem(inherited Add);
  Result.FActiveFlags := [];
end;

function TOverrideCollection.Items(Index: Integer): TOverrideItem;
begin
  Result := TOverrideItem(inherited Items[Index]);
end;

function TOverrideCollection.FindItem(const Dataset, FieldName: string): TOverrideItem;
var
  Key: string;
  I: Integer;
begin
  Key := BuildKey(Dataset, FieldName);
  for I := 0 to Count - 1 do
    if Items(I).Key = Key then
      Exit(Items(I));
  Result := nil;
end;

// -------------------------------------------------------------------
// TOverrideManager
// -------------------------------------------------------------------
constructor TOverrideManager.Create;
begin
  inherited;
  FOverrides := TOverrideCollection.Create;
  FIndex := TDictionary<string, TOverrideItem>.Create;
  FDatasetIndex := TDictionary<string, Boolean>.Create;
  FLoaded := False;
end;

destructor TOverrideManager.Destroy;
begin
  FDatasetIndex.Free;
  FIndex.Free;
  FOverrides.Free;
  inherited;
end;

procedure TOverrideManager.RebuildIndex;
var
  I: Integer;
  Item: TOverrideItem;
begin
  FIndex.Clear;
  FDatasetIndex.Clear;
  for I := 0 to FOverrides.Count - 1 do
  begin
    Item := FOverrides.Items(I);
    FIndex.AddOrSetValue(Item.Key, Item);
    FDatasetIndex.AddOrSetValue(UpperCase(Item.Dataset), True);
  end;
end;

procedure TOverrideManager.Remove(OverrideItem: TOverrideItem);
begin
  if assigned(OverrideItem) then
    FOverrides.Delete(OverrideItem.Index);
end;

procedure TOverrideManager.LoadFromDB(Connection: TFDConnection);
const
  SQL = 'SELECT * FROM OVERRIDES ORDER BY DATASET, FIELD_NAME';
var
  QRY: TFDQuery;
  Item: TOverrideItem;
  Flags: TOverrideFlags;
begin
  FOverrides.Clear;
  QRY := TFDQuery.Create(nil);
  try
    QRY.Connection := Connection;
    QRY.SQL.Text := SQL;
    QRY.Open;
    while not QRY.Eof do
    begin
      Item := FOverrides.Add;
      Flags := [];

      Item.Dataset := QRY.FieldByName('DATASET').AsString;
      Item.FieldName := QRY.FieldByName('FIELD_NAME').AsString;

      // Caption: nullable – in ActiveFlags solo se NOT NULL
      if not QRY.FieldByName('CAPTION_CARD').IsNull then
      begin
        Item.CaptionCard := QRY.FieldByName('CAPTION_CARD').AsString;
        Include(Flags, ofCaptionCard);
      end;

      if not QRY.FieldByName('CAPTION_GRID').IsNull then
      begin
        Item.CaptionGrid := QRY.FieldByName('CAPTION_GRID').AsString;
        Include(Flags, ofCaptionGrid);
      end;

      // Flag NOT NULL DEFAULT FALSE: in ActiveFlags solo se TRUE
      Item.ForceRequired := QRY.FieldByName('FORCE_REQUIRED').AsBoolean;
      if Item.ForceRequired then
        Include(Flags, ofForceRequired);

      Item.ForceReadOnly := QRY.FieldByName('FORCE_READONLY').AsBoolean;
      if Item.ForceReadOnly then
        Include(Flags, ofForceReadOnly);

      Item.ForceHidden := QRY.FieldByName('FORCE_HIDDEN').AsBoolean;
      if Item.ForceHidden then
        Include(Flags, ofForceHidden);

      Item.SuppressDefault := QRY.FieldByName('SUPPRESS_DEFAULT').AsBoolean;
      if Item.SuppressDefault then
        Include(Flags, ofSuppressDefault);

      Item.Note := QRY.FieldByName('NOTE').AsString;
      Item.ActiveFlags := Flags;

      QRY.Next;
    end;
  finally
    QRY.Free;
  end;
  RebuildIndex;
  FLoaded := True;
end;

procedure TOverrideManager.SaveItem(Item: TOverrideItem; Connection: TFDConnection);
var
  QRY: TFDStoredProc;
begin
  QRY := TFDStoredProc.Create(nil);
  try
    QRY.Connection := Connection;
    QRY.StoredProcName := 'OVERRIDE_SAVE';
    QRY.Prepare;

    QRY.ParamByName('DATASET').AsString := Item.Dataset;
    QRY.ParamByName('FIELD_NAME').AsString := Item.FieldName;
    // NOT NULL DEFAULT FALSE: sempre valorizzati, mai NULL
    QRY.ParamByName('FORCE_REQUIRED').AsInteger := Ord(Item.ForceRequired);
    QRY.ParamByName('FORCE_READONLY').AsInteger := Ord(Item.ForceReadOnly);
    QRY.ParamByName('FORCE_HIDDEN').AsInteger := Ord(Item.ForceHidden);
    QRY.ParamByName('SUPPRESS_DEFAULT').AsInteger := Ord(Item.SuppressDefault);
    QRY.ParamByName('NOTE').AsString := Item.Note;

    // Caption nullable: NULL se flag non attivo
    if ofCaptionCard in Item.ActiveFlags then
      QRY.ParamByName('CAPTION_CARD').AsString := Item.CaptionCard
    else
      QRY.ParamByName('CAPTION_CARD').Clear;

    if ofCaptionGrid in Item.ActiveFlags then
      QRY.ParamByName('CAPTION_GRID').AsString := Item.CaptionGrid
    else
      QRY.ParamByName('CAPTION_GRID').Clear;

    QRY.ExecProc;
    Connection.Commit;
  finally
    QRY.Free;
  end;
  // Aggiorna indici senza rebuild completo
  FIndex.AddOrSetValue(Item.Key, Item);
  FDatasetIndex.AddOrSetValue(UpperCase(Item.Dataset), True);
  // Assicura che l'item sia nella collection (se creato fuori da LoadFromDB)
  if FOverrides.FindItem(Item.Dataset, Item.FieldName) = nil then
    FOverrides.Add.Assign(Item);
end;

// -------------------------------------------------------------------
// Lookup
// -------------------------------------------------------------------
function TOverrideManager.FindOverride(const Dataset, FieldName: string): TOverrideItem;
begin
  if not FIndex.TryGetValue(BuildKey(Dataset, FieldName), Result) then
    Result := nil;
end;

function TOverrideManager.OverrideExists(const Dataset: string; Flags: TOverrideFlags): Boolean;
var
  I: Integer;
  Item: TOverrideItem;
  DatasetUp: string;
begin
  // Controllo rapido O(1): esiste almeno un record per questo dataset?
  DatasetUp := UpperCase(Dataset);
  if not FDatasetIndex.ContainsKey(DatasetUp) then
    Exit(False);
  // Flags vuoto = "esiste almeno un record per il dataset"
  if Flags = [] then
    Exit(True);
  // Scansione lineare limitata agli item del dataset (tipicamente pochi)
  for I := 0 to FOverrides.Count - 1 do
  begin
    Item := FOverrides.Items(I);
    if (UpperCase(Item.Dataset) = DatasetUp) and ((Item.ActiveFlags * Flags) <> []) then
      Exit(True);
  end;
  Result := False;
end;

function TOverrideManager.OverrideExists(const Dataset, FieldName: string; Flags: TOverrideFlags): Boolean;
var
  Item: TOverrideItem;
begin
  Item := FindOverride(Dataset, FieldName);
  if Item = nil then
    Exit(False);
  // Flags vuoto = "esiste il record per questo campo"
  if Flags = [] then
    Exit(True);
  // Almeno uno dei flag richiesti deve essere attivo
  Result := (Item.ActiveFlags * Flags) <> [];
end;

// -------------------------------------------------------------------
// Caption helpers
// -------------------------------------------------------------------
function TOverrideManager.CaptionGrid(const Dataset, FieldName: string): string;
var
  Item: TOverrideItem;
begin
  Item := FindOverride(Dataset, FieldName);
  if (Item <> nil) and (ofCaptionGrid in Item.ActiveFlags) then
    Result := Item.CaptionGrid
  else
    Result := '';
end;

function TOverrideManager.Add(const Dataset, FieldName: string): TOverrideItem;
begin
  Result := FOverrides.Add;
  Result.Dataset := Dataset;
  Result.FieldName := FieldName;
end;

function TOverrideManager.CaptionCard(const Dataset, FieldName: string): string;
var
  Item: TOverrideItem;
begin
  Item := FindOverride(Dataset, FieldName);
  if (Item <> nil) and (ofCaptionCard in Item.ActiveFlags) then
    Result := Item.CaptionCard
  else
    Result := '';
end;

initialization

finalization

FreeAndNil(GOverrides);

end.
