unit zz.DataRequest;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Data.DB,
  SmartInspect.core.SiAuto,
  SmartInspect.core;

type
  TDataRequestType = (rtMeta, rtCommand, rtSelect, rtInsert, rtUpdate, rtDelete, rtCount, rtExexSP);

  TDataRequestTypeHelper = record helper for TDataRequestType
  private
    function GetAsString: String;
    procedure SetAsString(const Value: String);
  public
    function ToString: string;
    property AsString: String read GetAsString write SetAsString;
  end;

  TDataRequest = class
  private
    Fapp: string;
    Fname: string;
    FSkip: integer;
    Fdm: string;
    FSort: string;
    FTake: integer;
    FFilter: string;
    FKeyValues: string;
    FParams: TStrings;
    FRequestType: TDataRequestType;
    FRequireFields: boolean;
    procedure SetParams(const Value: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
    function ToString: string; override;

    function GetRowsTo: string;
  public
    class function Encode(DataRequest: TDataRequest): TJsonObject;
    class function Decode(const JSON: string): TDataRequest; overload;
    class function Decode(const JSON: TJsonObject): TDataRequest; overload;
  published
    property app: string read Fapp write Fapp;
    property dm: string read Fdm write Fdm;
    property name: string read Fname write Fname;

    property RequestType: TDataRequestType read FRequestType write FRequestType;

    property KeyValues: string read FKeyValues write FKeyValues;
    property Params: TStrings read FParams write SetParams;

    // property Select: TJSObject read FSelect write FSelect;
    // property Filter: TJSObject read FFilter write FFilter;
    // property Group: TJSObject read FGroup write FGroup;
    // property Sort: TJSObject read FSort write FSort;
    //
    // property Skip: integer read FSkip write FSkip;
    // property Take: integer read FTake write FTake;

    property filter: string read FFilter write FFilter;
    property Sort: string read FSort write FSort;
    property Take: integer read FTake write FTake;
    property Skip: integer read FSkip write FSkip;
    property RequireFields: boolean read FRequireFields write FRequireFields;
  end;

  TOptionsRequest = class
  private
    Fapp: string;
    Fdm: string;
    Fid: string;
    FisCustom: boolean;
    Fwidget: string;
    FOptions: string;
  public
    constructor Create;
  public
    class function Encode(OptionsRequest: TOptionsRequest): TJsonObject;
    class function Decode(const JSON: string): TOptionsRequest; overload;
    class function Decode(const JSON: TJsonObject): TOptionsRequest; overload;
  published
    property app: string read Fapp write Fapp;
    property dm: string read Fdm write Fdm;
    property id: string read Fid write Fid;
    property widget: string read Fwidget write Fwidget;
    property options: string read FOptions write FOptions;
    property isCustom: boolean read FisCustom write FisCustom;
  end;

  TDatasetProps = class
  private
    Fapp: string;
    FCanDelete: boolean;
    FCanInsert: boolean;
    FCanUpdate: boolean;
    Fdm: string;
    FDataset: string;
    FFields: TStrings;
    FSelectSql: TStrings;
    FInsertSql: TStrings;
    FUpdateSql: TStrings;
    FDeleteSql: TStrings;
    FCountSql: TStrings;
    FIsCustom: boolean;
    FPK: string;
    FRelationName: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Src: TDatasetProps);

    function IsEmptyDataset: boolean;
  public
    property app: string read Fapp write Fapp;
    property dm: string read Fdm write Fdm;
    property Dataset: string read FDataset write FDataset;
    property IsCustom: boolean read FIsCustom write FIsCustom;
    property RelationName: string read FRelationName write FRelationName;
    property PK: string read FPK write FPK;
    property Fields: TStrings read FFields write FFields;
    property CanInsert: boolean read FCanInsert write FCanInsert;
    property CanUpdate: boolean read FCanUpdate write FCanUpdate;
    property CanDelete: boolean read FCanDelete write FCanDelete;
    property SelectSql: TStrings read FSelectSql write FSelectSql;
    property InsertSql: TStrings read FInsertSql write FInsertSql;
    property UpdateSql: TStrings read FUpdateSql write FUpdateSql;
    property DeleteSql: TStrings read FDeleteSql write FDeleteSql;
    property CountSql: TStrings read FCountSql write FCountSql;
  end;

  TDataSetRequest = class
  private
    Fapp: string;
    FCanDelete: boolean;
    FCanInsert: boolean;
    FCanUpdate: boolean;
    Fdm: string;
    FDataset: string;
    FFields: TStrings;
    FSelectSql: TStrings;
    FInsertSql: TStrings;
    FUpdateSql: TStrings;
    FDeleteSql: TStrings;
    FCountSql: TStrings;
    FIsCustom: boolean;
    FPK: string;
    FRelationName: string;
  public
    constructor Create;
    destructor Destroy; override;
  public
    class function Encode(DataSetRequest: TDataSetRequest): TJsonObject;
    class function Decode(const JSON: string): TDataSetRequest; overload;
    class function Decode(const JSON: TJsonObject): TDataSetRequest; overload;

    class function FromDatasetProps(const DatasetProps: TDatasetProps): TDataSetRequest;
    procedure AssignDatasetProps(DatasetProps: TDatasetProps);
    function ToDatasetProps: TDatasetProps;
  published
    property app: string read Fapp write Fapp;
    property dm: string read Fdm write Fdm;
    property Dataset: string read FDataset write FDataset;
    property IsCustom: boolean read FIsCustom write FIsCustom;
    property RelationName: string read FRelationName write FRelationName;
    property PK: string read FPK write FPK;
    property Fields: TStrings read FFields write FFields;
    property CanInsert: boolean read FCanInsert write FCanInsert;
    property CanUpdate: boolean read FCanUpdate write FCanUpdate;
    property CanDelete: boolean read FCanDelete write FCanDelete;
    property SelectSql: TStrings read FSelectSql write FSelectSql;
    property InsertSql: TStrings read FInsertSql write FInsertSql;
    property UpdateSql: TStrings read FUpdateSql write FUpdateSql;
    property DeleteSql: TStrings read FDeleteSql write FDeleteSql;
    property CountSql: TStrings read FCountSql write FCountSql;
  end;

  /// //////////////////////////////////////////////////////////////////////////
  // ELIMINARE
  TSqlRequest = class
  private
    Fapp: string;
    Fdm: string;
    Fname: string;
    FFields: TStrings;
    FSelectSql: TStrings;
    FInsertSql: TStrings;
    FUpdateSql: TStrings;
    FDeleteSql: TStrings;
    FCountSql: TStrings;
    FPK: string;
    FTableName: string;
  public
    constructor Create;
    destructor Destroy; override;
  public
    class function Encode(SqlRequest: TSqlRequest): TJsonObject;
    class function Decode(const JSON: string): TSqlRequest; overload;
    class function Decode(const JSON: TJsonObject): TSqlRequest; overload;
  published
    property app: string read Fapp write Fapp;
    property dm: string read Fdm write Fdm;
    property name: string read Fname write Fname;

    property TableName: string read FTableName write FTableName;
    property PK: string read FPK write FPK;

    property Fields: TStrings read FFields write FFields;
    property SelectSql: TStrings read FSelectSql write FSelectSql;
    property InsertSql: TStrings read FInsertSql write FInsertSql;
    property UpdateSql: TStrings read FUpdateSql write FUpdateSql;
    property DeleteSql: TStrings read FDeleteSql write FDeleteSql;
    property CountSql: TStrings read FCountSql write FCountSql;
  end;

  /// //////////////////////////////////////////////////////////////////////////

implementation

uses
  System.StrUtils,
  System.Rtti,
  REST.JSON;

function StringsToJSONArray(const Data: TStrings): TJSONArray;
var
  i: integer;
begin
  Result := TJSONArray.Create;
  for i := 0 to Data.Count - 1 do
    Result.Add(Data[i]);
end;

procedure LoadStringList(JSON: TJsonObject; const PropertyName: string; StringList: TStrings);
var
  i: integer;
  v: TJSONValue;
  a: TJSONArray;
begin
  StringList.Clear;

  v := JSON.GetValue(PropertyName);

  if Assigned(v) then
    if v is TJSONArray then
    begin

      a := TJSONArray(v);

      for i := 0 to a.Size - 1 do
        StringList.Add(a.get(i).Value);
    end;
end;

function GetString(JSON: TJsonObject; const PropertyName: string): string;
begin
  if not JSON.tryGetValue<string>(PropertyName, Result) then
    Result := '';
end;

function GetInt(JSON: TJsonObject; const PropertyName: string): integer;
begin
  if not JSON.tryGetValue<integer>(PropertyName, Result) then
    Result := -1;
end;

function GetBool(JSON: TJsonObject; const PropertyName: string): boolean;
begin
  if not JSON.tryGetValue<boolean>(PropertyName, Result) then
    Result := false;
end;

function GetArray(JSON: TJsonObject; const PropertyName: string): TJSONArray;
begin
  if not JSON.tryGetValue<TJSONArray>(PropertyName, Result) then
    Result := nil;
end;

function TDataRequestTypeHelper.GetAsString: String;
begin
  case self of
    rtMeta:
      Result := 'META';
    rtCommand:
      Result := 'CMD';
    rtSelect:
      Result := 'SEL';
    rtInsert:
      Result := 'INS';
    rtUpdate:
      Result := 'UPD';
    rtDelete:
      Result := 'DEL';
    rtCount:
      Result := 'CNT';
    rtExexSP:
      Result := 'SP';
  end;
end;

procedure TDataRequestTypeHelper.SetAsString(const Value: String);
var
  i: integer;
begin
  i := IndexStr(Value, ['META', 'CMD', 'SEL', 'INS', 'UPD', 'DEL', 'CNT', 'SP']);
  self := TDataRequestType(i);
end;

function TDataRequestTypeHelper.ToString: string;
begin
  Result := TRttiEnumerationType.GetName(self);
end;

constructor TDataRequest.Create;
begin
  inherited;
  Fname := '';
  Fapp := '';
  Fdm := '';
  FRequestType := rtMeta;
  FFilter := '';
  FSort := '';
  FSkip := -1;
  FTake := -1;
  FParams := TStringList.Create;
end;

destructor TDataRequest.Destroy;
begin
  FreeAndNil(FParams);
  inherited;
end;

class function TDataRequest.Decode(const JSON: string): TDataRequest;
var
  o: TJsonObject;
begin
  o := TJsonObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0) as TJsonObject;
  try
    Result := Decode(o);
  finally
    o.Free;
  end;
end;

class function TDataRequest.Decode(const JSON: TJsonObject): TDataRequest;
var
  a: TJSONArray;
begin
  Result := TDataRequest.Create;
  try
    Result.app := GetString(JSON, 'app');
    Result.dm := GetString(JSON, 'dm');
    Result.name := GetString(JSON, 'Name');
    Result.RequestType.AsString := GetString(JSON, 'RequestType');
    Result.KeyValues := GetString(JSON, 'KeyValues');
    LoadStringList(JSON, 'Params', Result.Params);

    Result.Sort := GetString(JSON, 'Sort');
    Result.Skip := GetInt(JSON, 'Skip');
    Result.Take := GetInt(JSON, 'Take');
    Result.filter := GetString(JSON, 'Filter');
    Result.RequireFields := GetBool(JSON, 'RequireFields');
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

class function TDataRequest.Encode(DataRequest: TDataRequest): TJsonObject;
begin
  Result := TJsonObject.Create;
  try
    Result.AddPair('app', DataRequest.app);
    Result.AddPair('dm', DataRequest.dm);
    Result.AddPair('Name', DataRequest.name);
    Result.AddPair('KeyValues', DataRequest.KeyValues);
    Result.AddPair('Params', StringsToJSONArray(DataRequest.Params));
    Result.AddPair('Filter', DataRequest.filter);
    Result.AddPair('Sort', DataRequest.Sort);
    Result.AddPair('Take', TJSONNumber.Create(DataRequest.Take));
    Result.AddPair('Skip', TJSONNumber.Create(DataRequest.Skip));
    Result.AddPair('RequireFields', TJSONBool.Create(DataRequest.RequireFields));
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

function TDataRequest.GetRowsTo: string;
var
  rows_, to_: integer;
begin
  Result := '';

  if Take >= 0 then
  begin
    rows_ := Skip + 1;
    to_ := Skip + 1 + Take;
    Result := sLineBreak + ' ROWS ' + rows_.ToString + ' TO ' + to_.ToString;
  end;
end;

procedure TDataRequest.SetParams(const Value: TStrings);
begin
  FParams.Assign(Value);
end;

function TDataRequest.ToString: string;
begin
  Result := 'DataSet = ' + Name + sLineBreak;
  Result := Result + 'App= ' + app + sLineBreak;
  Result := Result + 'DataModule = ' + dm + sLineBreak;
  Result := Result + 'RequestType = ' + RequestType.ToString + sLineBreak;
  Result := Result + 'KeyValues= ' + KeyValues + sLineBreak;
  Result := Result + 'Params= ' + Params.Text + sLineBreak;
  Result := Result + 'Filter = ' + filter + sLineBreak;
  Result := Result + 'Sort = ' + Sort + sLineBreak;
  Result := Result + 'Take = ' + Take.ToString + sLineBreak;
  Result := Result + 'Skip = ' + Skip.ToString;
end;

constructor TOptionsRequest.Create;
begin
  inherited;
  Fapp := '';
  Fdm := '';
  Fid := '';
  Fwidget := '';
  FOptions := '';
  FisCustom:=false;
end;

class function TOptionsRequest.Decode(const JSON: string): TOptionsRequest;
var
  o: TJsonObject;
begin
  o := TJsonObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0) as TJsonObject;
  try
    Result := Decode(o);
  finally
    o.Free;
  end;
end;

class function TOptionsRequest.Decode(const JSON: TJsonObject): TOptionsRequest;
var
  a: TJSONArray;
begin
  Result := TOptionsRequest.Create;
  try
    Result.app := GetString(JSON, 'app');
    Result.dm := GetString(JSON, 'dm');
    Result.id := GetString(JSON, 'id');
    Result.widget := GetString(JSON, 'widget');
    Result.options := GetString(JSON, 'options');
    Result.isCustom:= GetBool(JSON, 'isCustom');
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

class function TOptionsRequest.Encode(OptionsRequest: TOptionsRequest): TJsonObject;
var
  j: TJSONValue;
begin
  siMain.EnterMethod('TOptionsRequest.Encode');

  Result := TJsonObject.Create;
  try
    Result.AddPair('app', OptionsRequest.app);
    Result.AddPair('dm', OptionsRequest.dm);
    Result.AddPair('id', OptionsRequest.id);
    Result.AddPair('widget', OptionsRequest.widget);
    Result.AddPair('options', OptionsRequest.options);
    Result.AddPair('isCustom', OptionsRequest.isCustom);
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;

  siMain.LeaveMethod('TOptionsRequest.Encode');
end;

{ TSqlRequest }

constructor TSqlRequest.Create;
begin
  inherited;
  Fapp := '';
  Fdm := '';
  Fname := '';
  FTableName := '';
  FPK := '';
  FFields := TStringList.Create;
  FSelectSql := TStringList.Create;
  FInsertSql := TStringList.Create;
  FUpdateSql := TStringList.Create;
  FDeleteSql := TStringList.Create;
  FCountSql := TStringList.Create;
end;

destructor TSqlRequest.Destroy;
begin
  FreeAndNil(FFields);
  FreeAndNil(FSelectSql);
  FreeAndNil(FInsertSql);
  FreeAndNil(FUpdateSql);
  FreeAndNil(FDeleteSql);
  FreeAndNil(FCountSql);
  inherited;
end;

class function TSqlRequest.Decode(const JSON: string): TSqlRequest;
var
  o: TJsonObject;
begin
  o := TJsonObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0) as TJsonObject;
  try
    Result := Decode(o);
  finally
    o.Free;
  end;
end;

class function TSqlRequest.Decode(const JSON: TJsonObject): TSqlRequest;
var
  a: TJSONArray;
begin
  Result := TSqlRequest.Create;
  try
    Result.app := GetString(JSON, 'app');
    Result.dm := GetString(JSON, 'dm');
    Result.name := GetString(JSON, 'Name');
    Result.TableName := GetString(JSON, 'TableName');
    Result.PK := GetString(JSON, 'PK');
    LoadStringList(JSON, 'Fields', Result.Fields);
    LoadStringList(JSON, 'SelectSql', Result.SelectSql);
    LoadStringList(JSON, 'InsertSql', Result.InsertSql);
    LoadStringList(JSON, 'UpdateSql', Result.UpdateSql);
    LoadStringList(JSON, 'DeleteSql', Result.DeleteSql);
    LoadStringList(JSON, 'CountSql', Result.CountSql);
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

class function TSqlRequest.Encode(SqlRequest: TSqlRequest): TJsonObject;
begin
  Result := TJsonObject.Create;
  try
    Result.AddPair('app', SqlRequest.app);
    Result.AddPair('dm', SqlRequest.dm);
    Result.AddPair('Name', SqlRequest.name);
    Result.AddPair('TableName', SqlRequest.TableName);
    Result.AddPair('PK', SqlRequest.PK);
    Result.AddPair('Fields', StringsToJSONArray(SqlRequest.Fields));
    Result.AddPair('SelectSql', StringsToJSONArray(SqlRequest.SelectSql));
    Result.AddPair('InsertSql', StringsToJSONArray(SqlRequest.InsertSql));
    Result.AddPair('UpdateSql', StringsToJSONArray(SqlRequest.UpdateSql));
    Result.AddPair('DeleteSql', StringsToJSONArray(SqlRequest.DeleteSql));
    Result.AddPair('CountSql', StringsToJSONArray(SqlRequest.CountSql));
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

constructor TDatasetProps.Create;
begin
  inherited;
  Fapp := '';
  Fdm := '';
  FDataset := '';
  FIsCustom := false;
  FRelationName := '';
  FPK := '';
  FCanInsert := True;
  FCanUpdate := True;
  FCanDelete := True;
  FFields := TStringList.Create;
  FSelectSql := TStringList.Create;
  FInsertSql := TStringList.Create;
  FUpdateSql := TStringList.Create;
  FDeleteSql := TStringList.Create;
  FCountSql := TStringList.Create;
end;

destructor TDatasetProps.Destroy;
begin
  FreeAndNil(FFields);
  FreeAndNil(FSelectSql);
  FreeAndNil(FInsertSql);
  FreeAndNil(FUpdateSql);
  FreeAndNil(FDeleteSql);
  FreeAndNil(FCountSql);

  inherited;
end;

function TDatasetProps.IsEmptyDataset: boolean;
begin
  Result := RelationName.Equals('RDB$DATABASE');
end;

{ TDataSetRequest }

constructor TDataSetRequest.Create;
begin
  inherited;
  Fapp := '';
  Fdm := '';
  FDataset := '';
  FIsCustom := false;
  FRelationName := '';
  FPK := '';
  FCanInsert := True;
  FCanUpdate := True;
  FCanDelete := True;
  FFields := TStringList.Create;
  FSelectSql := TStringList.Create;
  FInsertSql := TStringList.Create;
  FUpdateSql := TStringList.Create;
  FDeleteSql := TStringList.Create;
  FCountSql := TStringList.Create;
end;

destructor TDataSetRequest.Destroy;
begin
  FreeAndNil(FFields);
  FreeAndNil(FSelectSql);
  FreeAndNil(FInsertSql);
  FreeAndNil(FUpdateSql);
  FreeAndNil(FDeleteSql);
  FreeAndNil(FCountSql);

  inherited;
end;

class function TDataSetRequest.Decode(const JSON: TJsonObject): TDataSetRequest;
var
  a: TJSONArray;
begin
  Result := TDataSetRequest.Create;
  try
    Result.app := GetString(JSON, 'app');
    Result.dm := GetString(JSON, 'dm');
    Result.Dataset := GetString(JSON, 'dataset');
    Result.IsCustom := GetBool(JSON, 'isCustom');
    Result.RelationName := GetString(JSON, 'relationName');
    Result.PK := GetString(JSON, 'pk');
    Result.CanInsert := GetBool(JSON, 'canInsert');
    Result.CanUpdate := GetBool(JSON, 'canUpdate');
    Result.CanDelete := GetBool(JSON, 'canDelete');
    // Result.Fields := GetString(JSON, 'fields');
    Result.SelectSql.Text := GetString(JSON, 'selectSql');
    Result.InsertSql.Text := GetString(JSON, 'insertSql');
    Result.UpdateSql.Text := GetString(JSON, 'updateSql');
    Result.DeleteSql.Text := GetString(JSON, 'deleteSql');
    Result.CountSql.Text := GetString(JSON, 'countSql');
    // LoadStringList(JSON, 'fields', Result.Fields);
    // LoadStringList(JSON, 'selectSql', Result.SelectSql);
    // LoadStringList(JSON, 'insertSql', Result.InsertSql);
    // LoadStringList(JSON, 'updateSql', Result.UpdateSql);
    // LoadStringList(JSON, 'deleteSql', Result.DeleteSql);
    // LoadStringList(JSON, 'countSql', Result.CountSql);
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

class function TDataSetRequest.Decode(const JSON: string): TDataSetRequest;
var
  o: TJsonObject;
begin
  o := TJsonObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0) as TJsonObject;
  try
    Result := Decode(o);
  finally
    o.Free;
  end;
end;

class function TDataSetRequest.Encode(DataSetRequest: TDataSetRequest): TJsonObject;
begin
  Result := TJsonObject.Create;
  try
    Result.AddPair('app', DataSetRequest.app);
    Result.AddPair('dm', DataSetRequest.dm);
    Result.AddPair('dataset', DataSetRequest.Dataset);
    Result.AddPair('isCustom', DataSetRequest.IsCustom);
    Result.AddPair('relationName', DataSetRequest.RelationName);
    Result.AddPair('pk', DataSetRequest.PK);

    Result.AddPair('canInsert', DataSetRequest.CanInsert);
    Result.AddPair('canUpdate', DataSetRequest.CanUpdate);
    Result.AddPair('canDelete', DataSetRequest.CanDelete);

    // Result.AddPair('fields', StringsToJSONArray(DataSetRequest.Fields));
    // Result.AddPair('selectSql', StringsToJSONArray(DataSetRequest.SelectSql));
    // Result.AddPair('insertSql', StringsToJSONArray(DataSetRequest.InsertSql));
    // Result.AddPair('updateSql', StringsToJSONArray(DataSetRequest.UpdateSql));
    // Result.AddPair('deleteSql', StringsToJSONArray(DataSetRequest.DeleteSql));
    // Result.AddPair('countSql', StringsToJSONArray(DataSetRequest.CountSql));

    Result.AddPair('fields', DataSetRequest.Fields.Text);
    Result.AddPair('selectSql', DataSetRequest.SelectSql.Text);
    Result.AddPair('insertSql', DataSetRequest.InsertSql.Text);
    Result.AddPair('updateSql', DataSetRequest.UpdateSql.Text);
    Result.AddPair('deleteSql', DataSetRequest.DeleteSql.Text);
    Result.AddPair('countSql', DataSetRequest.CountSql.Text);
  except
    on e: exception do
    begin
      Result.Free;
      raise;
    end;
  end;
end;

procedure TDataSetRequest.AssignDatasetProps(DatasetProps: TDatasetProps);
begin
  self.app := DatasetProps.app;
  self.dm := DatasetProps.dm;
  self.Dataset := DatasetProps.Dataset;
  self.RelationName := DatasetProps.RelationName;
  self.PK := DatasetProps.PK;
  self.CanInsert := DatasetProps.CanInsert;
  self.CanUpdate := DatasetProps.CanUpdate;
  self.CanDelete := DatasetProps.CanDelete;
  self.SelectSql.Text := DatasetProps.SelectSql.Text;
  self.InsertSql.Text := DatasetProps.InsertSql.Text;
  self.UpdateSql.Text := DatasetProps.UpdateSql.Text;
  self.DeleteSql.Text := DatasetProps.DeleteSql.Text;
  self.CountSql.Text := DatasetProps.CountSql.Text;
end;

class function TDataSetRequest.FromDatasetProps(const DatasetProps: TDatasetProps): TDataSetRequest;
begin
  Result := TDataSetRequest.Create;
  Result.app := DatasetProps.app;
  Result.dm := DatasetProps.dm;
  Result.Dataset := DatasetProps.Dataset;
  Result.IsCustom := DatasetProps.IsCustom;
  Result.RelationName := DatasetProps.RelationName;
  Result.PK := DatasetProps.PK;
  Result.CanInsert := DatasetProps.CanInsert;
  Result.CanUpdate := DatasetProps.CanUpdate;
  Result.CanDelete := DatasetProps.CanDelete;
  Result.SelectSql.Text := DatasetProps.SelectSql.Text;
  Result.InsertSql.Text := DatasetProps.InsertSql.Text;
  Result.UpdateSql.Text := DatasetProps.UpdateSql.Text;
  Result.DeleteSql.Text := DatasetProps.DeleteSql.Text;
  Result.CountSql.Text := DatasetProps.CountSql.Text;
end;

function TDataSetRequest.ToDatasetProps: TDatasetProps;
begin
  Result := TDatasetProps.Create;
  Result.app := self.app;
  Result.dm := self.dm;
  Result.Dataset := self.Dataset;
  Result.IsCustom := self.IsCustom;
  Result.RelationName := self.RelationName;
  Result.PK := self.PK;
  Result.CanInsert := self.CanInsert;
  Result.CanUpdate := self.CanUpdate;
  Result.CanDelete := self.CanDelete;
  Result.SelectSql.Text := self.SelectSql.Text;
  Result.InsertSql.Text := self.InsertSql.Text;
  Result.UpdateSql.Text := self.UpdateSql.Text;
  Result.DeleteSql.Text := self.DeleteSql.Text;
  Result.CountSql.Text := self.CountSql.Text;
end;

procedure TDatasetProps.Assign(Src: TDatasetProps);
begin
  self.app := Src.app;
  self.dm := Src.dm;
  self.Dataset := Src.Dataset;
  self.IsCustom := Src.IsCustom;
  self.RelationName := Src.RelationName;
  self.PK := Src.PK;
  self.CanInsert := Src.CanInsert;
  self.CanUpdate := Src.CanUpdate;
  self.CanDelete := Src.CanDelete;
  self.SelectSql.Text := Src.SelectSql.Text;
  self.InsertSql.Text := Src.InsertSql.Text;
  self.UpdateSql.Text := Src.UpdateSql.Text;
  self.DeleteSql.Text := Src.DeleteSql.Text;
  self.CountSql.Text := Src.CountSql.Text;
end;

end.
