unit zDataSetLog;

interface

uses
  SysUtils,
  Classes,
  vcl.Forms,
  TimeSpan,
  zFbDataSet;

type
  TLogOperation = (loPrepare, loFields, loOpen);

  TDataSetLog = class(TCollectionItem)
  private
    FCount_Fields: integer;
    FDataModule: string;
    FDataSet: string;
    FCount_Open: integer;
    FCount_Prepare: integer;
    FSQL: TStrings;
    FTime_Fields: TTimeSpan;
    FTime_Open: TTimeSpan;
    FTime_Prepare: TTimeSpan;
    TStrings: integer;
    procedure SetSQL(const Value: TStrings);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property DataModule: string read FDataModule write FDataModule;
    property DataSet: string read FDataSet write FDataSet;
    property SQL: TStrings read FSQL write SetSQL;

    property Count_Open: integer read FCount_Open write FCount_Open;
    property Count_Prepare: integer read FCount_Prepare write FCount_Prepare;
    property Count_Fields: integer read FCount_Fields write FCount_Fields;

    property Time_Fields: TTimeSpan read FTime_Fields write FTime_Fields;
    property Time_Open: TTimeSpan read FTime_Open write FTime_Open;
    property Time_Prepare: TTimeSpan read FTime_Prepare write FTime_Prepare;
  end;

  TDataSetLogs = class(TCollection)
  private
    FActive: Boolean;
    function GetItem(Index: integer): TDataSetLog;
    procedure SetActive(const Value: Boolean);
    procedure SetItem(Index: integer; const Value: TDataSetLog);
  public
    constructor Create;
    function Add: TDataSetLog;
    function Insert(Index: integer): TDataSetLog;
    property Active: Boolean read FActive write SetActive;
    property Items[Index: integer]: TDataSetLog read GetItem write SetItem; default;
    function IndexOf(const DataModule: string; const DataSet: string): integer;
    procedure LogDataSet(DataSet: TzFbDataSet; LogOperation: TLogOperation; TimeSpan: TTimeSpan);
  end;

function zMonitor: TDataSetLogs;

implementation

var
  __DataSetLogs: TDataSetLogs;

function zMonitor: TDataSetLogs;
begin
  if not Assigned(__DataSetLogs) then
    __DataSetLogs := TDataSetLogs.Create;

  Result := __DataSetLogs;
end;

constructor TDataSetLog.Create(Collection: TCollection);
begin
  inherited;
  FDataModule := '';
  FDataSet := '';
  // FTime_Open := 0;
  // FTime_Prepare := 0;
  // FTime_Fields := 0;
  FCount_Open := 0;
  FCount_Prepare := 0;
  FCount_Fields := 0;
  FSQL := TStringList.Create;
end;

destructor TDataSetLog.Destroy;
begin
  FreeAndNil(FSQL);
  inherited;
end;

procedure TDataSetLog.Assign(Source: TPersistent);
var
  Item: TDataSetLog;
begin
  if Source is TDataSetLog then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := Source as TDataSetLog;
      DataModule := Item.DataModule;
      DataSet := Item.DataSet;
      Time_Open := Item.Time_Open;
      Time_Prepare := Item.Time_Prepare;
      Time_Fields := Item.Time_Fields;
      Count_Open := Item.Count_Open;
      Count_Prepare := Item.Count_Prepare;
      Count_Fields := Item.Count_Fields;

      SQL.Assign(Item.SQL);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TDataSetLog.SetSQL(const Value: TStrings);
begin
  FSQL.Assign(Value);
end;

{ TzSqlCommands }

function TDataSetLogs.Add: TDataSetLog;
begin
  Result := TDataSetLog( inherited Add);
end;

constructor TDataSetLogs.Create;
begin
  inherited Create(TDataSetLog);
  FActive := false;
end;

function TDataSetLogs.GetItem(Index: integer): TDataSetLog;
begin
  Result := TDataSetLog( inherited Items[Index]);
end;

function TDataSetLogs.IndexOf(const DataModule, DataSet: string): integer;
var
  I: integer;
begin
  Result := -1;

  for I := 0 to Count - 1 do
    if SameText(Items[I].DataModule, DataModule) then
      if SameText(Items[I].DataSet, DataSet) then
      begin
        Result := I;
        Break;
      end;
end;

function TDataSetLogs.Insert(Index: integer): TDataSetLog;
begin
  Result := TDataSetLog( inherited Insert(Index));
end;

procedure TDataSetLogs.LogDataSet(DataSet: TzFbDataSet; LogOperation: TLogOperation; TimeSpan: TTimeSpan);

  function GetDataModule(DataSet: TzFbDataSet): string;
  var
    aOwner: TComponent;
  begin
    Result := '';
    aOwner := DataSet.Owner;
    while Assigned(aOwner) and (aOwner <> Application) do
    begin
      if Trim(Result) <> '' then
        Result := aOwner.Name + '.' + Result
      else
        Result := aOwner.Name;

      aOwner := aOwner.Owner;
    end;
  end;

var
  Item: TDataSetLog;
  DataModule: string;
  idx: integer;
begin
  if not Active then
    Exit;

  if not Assigned(DataSet) then
    Exit;

  DataModule := GetDataModule(DataSet);

  idx := IndexOf(DataModule, DataSet.Name);

  if idx = -1 then
  begin
    Item := Add;
    Item.DataModule := DataModule;
    Item.DataSet := DataSet.Name;
    Item.SQL := DataSet.SelectSQL;
  end
  else
    Item := Items[idx];

  case LogOperation of
    loOpen:
      begin
        Item.Time_Open := TimeSpan;
        Item.Count_Open := Item.Count_Open + 1;
      end;
    loPrepare:
      begin
        Item.Time_Prepare := TimeSpan;
        Item.Count_Prepare := Item.Count_Prepare + 1;
      end;
    loFields:
      begin
        Item.Time_Fields := TimeSpan;
        Item.Count_Fields := Item.Count_Fields + 1;
      end;
  end;
end;

procedure TDataSetLogs.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
  end;
end;

procedure TDataSetLogs.SetItem(Index: integer; const Value: TDataSetLog);
begin
  Items[Index].Assign(Value);
end;

initialization

__DataSetLogs := nil;

finalization

if Assigned(__DataSetLogs) then
  FreeAndNil(__DataSetLogs);

end.
