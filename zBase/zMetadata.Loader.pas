unit zMetadata.Loader;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  zMetadata,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

procedure FillFirebirdMetadata(Metadata: TzMetadata; Connection: TFDConnection; Transaction: TFDTransaction; const LoadSource: Boolean; CallBack: TProc<string> = nil; const loadBase: Boolean = true);

const
  FirebirdMetadataCallBackSteps = 17;

implementation

uses
  Data.DB,
  Vcl.Clipbrd,
  Vcl.Dialogs,
  zMetadata.Query,
  zMetadata.Utils,
  zMetadata.Types,
  zAI.Types;

type
  TFieldHelper = class helper for TField
    function AsTrimmedString: string;
  end;

function TFieldHelper.AsTrimmedString: string;
begin
  result := AsString.Trim;
end;

type
  TzFbMetadata = class(TObject)
  private
    Metadata: TzMetadata;
    Connection: TFDConnection;
    Transaction: TFDTransaction;
    Qry: TFDQuery;

    function CreateQry: TFDQuery;
    procedure OpenQry(const SQL: string; const LoadSource: Boolean = False);
    procedure CloseQry;
  private
    // function getFunction(const PackageName, FuncName: string; const FromIndex: integer): TzmdFunction;
  private
    procedure Fill_Domains;
    procedure Fill_Generators;
    procedure Fill_Tables;
    procedure Fill_TableFields;
    procedure Fill_TablePrimaryKeys;
    procedure Fill_TableForeignKeys;
    procedure Fill_TableUniques;
    procedure Fill_TableChecks;
    procedure Fill_TableIndexes;
    procedure Fill_TableDependencies;
    procedure Fill_Procedures(const LoadSource: Boolean);
    procedure Fill_ProcedureParams;
    procedure Fill_Views(const LoadSource: Boolean);
    procedure Fill_ViewFields;
    procedure Fill_Functions(const LoadSource: Boolean);
    procedure Fill_FunctionParams;
    procedure Fill_Triggers(const LoadSource: Boolean);
    procedure Fill_Packages;

    procedure Fill_Picklists;
    procedure Fill_Lookups;
    procedure Fill_DataDictionary;

    procedure AssignPackageDetails;
  public
    constructor Create(aMetadata: TzMetadata; aConnection: TFDConnection; aTransaction: TFDTransaction);
    destructor Destroy; override;
    //
    procedure FillMetadata(const LoadSource: Boolean; CallBack: TProc<string> = nil; const loadBase: Boolean = true);
  end;

  { TzFbMetadata }

constructor TzFbMetadata.Create(aMetadata: TzMetadata; aConnection: TFDConnection; aTransaction: TFDTransaction);
begin
  inherited Create;
  Metadata := aMetadata;
  Connection := aConnection;
  Transaction := aTransaction;

  Qry := CreateQry;
end;

function TzFbMetadata.CreateQry: TFDQuery;
begin
  result := TFDQuery.Create(nil);
  result.Connection := Connection;
  result.Transaction := Transaction;
  result.UpdateTransaction := Transaction;
  result.FetchOptions.UniDirectional := true;
end;

destructor TzFbMetadata.Destroy;
begin
  FreeAndNil(Qry);
  inherited;
end;

procedure TzFbMetadata.CloseQry;
begin
  Qry.Active := False;
end;

procedure TzFbMetadata.OpenQry(const SQL: string; const LoadSource: Boolean = False);
var
  Param: TFDParam;
begin
  // Qry.Close;
  // Qry.SQL.Text := SQL;
  // Qry.ExecQuery;

  Qry.Active := False;
  Qry.Fields.Clear;
  Qry.FieldDefs.Clear;
  Qry.Params.Clear;
  // Qry.SQL.Text := StringReplace(SQL, '@LOAD_SOURCE', BoolToStr(LoadSource, true), []);
  Qry.SQL.Text := SQL;
  Qry.Prepare;

  Param := Qry.FindParam('LOAD_SOURCE');

  if Assigned(Param) then
    Param.value := LoadSource;

  Qry.Active := true;
end;

procedure TzFbMetadata.FillMetadata(const LoadSource: Boolean; CallBack: TProc<string> = nil; const loadBase: Boolean = true);

  procedure doCallBack(const msg: string);
  begin
    if Assigned(CallBack) then
      CallBack(msg);
  end;

var
  ProcDomains, ProcTables, ProcProcedures, ProcViews: TProc;
begin
  Assert(Assigned(Metadata));
  Assert(Assigned(Connection));
  Assert(Assigned(Transaction));

  Metadata.Clear;
  //
  doCallBack('Lettura Domains');
  Fill_Domains;
  doCallBack('Lettura Sequences');
  Fill_Generators;
  doCallBack('Lettura Functions');
  Fill_Functions(LoadSource);
  doCallBack('Lettura Function Params');
  Fill_FunctionParams;
  // Tables
  doCallBack('Lettura Tables');
  Fill_Tables;
  doCallBack('Lettura Table Fields');
  Fill_TableFields;
  doCallBack('Lettura Table PrimaryKeys');
  Fill_TablePrimaryKeys;
  doCallBack('Lettura Table ForeignKeys');
  Fill_TableForeignKeys;
  doCallBack('Lettura Table Uniques');
  Fill_TableUniques;
  doCallBack('Lettura Table Checks');
  Fill_TableChecks;
  doCallBack('Lettura Table Indexes');
  Fill_TableIndexes;
  doCallBack('Lettura Table Dependencies;');
  Fill_TableDependencies;;
  // Procedures
  doCallBack('Lettura Procedures');
  Fill_Procedures(LoadSource);
  doCallBack('Lettura Procedure Params');
  Fill_ProcedureParams;
  // Views
  doCallBack('Lettura Views');
  Fill_Views(LoadSource);
  doCallBack('Lettura View Fields');
  Fill_ViewFields;
  // trigger
  doCallBack('Lettura Triggers');
  Fill_Triggers(LoadSource);
  // packages
  doCallBack('Lettura Packages');
  Fill_Packages;

  if loadBase then
  begin
    doCallBack('Lettura Picklists');
    Fill_Picklists;
    doCallBack('Lettura Lookups');
    Fill_Lookups;
    doCallBack('Lettura DataDictionary');
    Fill_DataDictionary;
  end;

  AssignPackageDetails;

  Metadata.Loaded := true;
end;

procedure TzFbMetadata.Fill_Domains;

var
  zDomain: TzmdDomain;
begin
  SiMain.EnterMethod(Self, 'Fill_Domains');

  OpenQry(TMetadataQuery.Domains);
  try
    while not Qry.Eof do
    begin
      zDomain := Metadata.Domains.Add;
      zDomain.name := Qry.FieldByName('DOMAIN_NAME').AsTrimmedString;
      zDomain.Description.Text := Qry.FieldByName('DOMAIN_DESCRIPTION').AsTrimmedString;
      zDomain.Size := Qry.FieldByName('DOMAIN_LENGTH').AsInteger;
      zDomain.DataType := GetDataType(Qry.FieldByName('DOMAIN_TYPE').AsInteger, Qry.FieldByName('DOMAIN_SUB_TYPE').AsInteger);
      zDomain.DefaultValue := Trim(Qry.FieldByName('DEFAULT_VALUE').AsTrimmedString); // 02.08.2012 In alcuni casi FB2.5 ritorna uno spazio prima di default
      zDomain.CheckConstraint := Qry.FieldByName('CHECK_CONSTRAINT').AsTrimmedString;
      zDomain.Required := Qry.FieldByName('DOMAIN_REQUIRED').AsInteger = 1;
      zDomain.FbDataType := Qry.FieldByName('DOMAIN_SQL_DATA_TYPE').AsTrimmedString;

      /// ///

      zDomain.CharacterSetId := -1;
      if not Qry.FieldByName('CHARACTER_SET_ID').isNull then
        zDomain.CharacterSetId := Qry.FieldByName('CHARACTER_SET_ID').value;

      zDomain.CharacterSetName := Qry.FieldByName('CHARACTER_SET_NAME').AsTrimmedString;

      /// ///

      zDomain.CollationId := -1;
      if not Qry.FieldByName('COLLATION_ID').isNull then
        zDomain.CollationId := Qry.FieldByName('COLLATION_ID').value;

      zDomain.CollationName := Qry.FieldByName('COLLATION_NAME').AsTrimmedString;

      /// ///

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Domains');
end;

procedure TzFbMetadata.Fill_Generators;
var
  zGenerator: TzmdGenerator;
begin
  SiMain.EnterMethod(Self, 'Fill_Generators');

  OpenQry(TMetadataQuery.Sequences);
  try
    while not Qry.Eof do
    begin
      zGenerator := Metadata.Generators.Add;
      zGenerator.name := Qry.FieldByName('GENERATOR_NAME').AsTrimmedString;
      zGenerator.Description.Text := '';
      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Generators');
end;

procedure TzFbMetadata.Fill_Tables;
var
  zTable: TzmdTable;
begin
  SiMain.EnterMethod(Self, 'Fill_Tables');

  OpenQry(TMetadataQuery.Tables);
  try
    while not Qry.Eof do
    begin
      zTable := Metadata.Tables.Add;
      zTable.name := Qry.FieldByName('TABLE_NAME').AsTrimmedString;
      zTable.IdentityField := Qry.FieldByName('IDENTITY_FIELD').AsTrimmedString;
      zTable.Description.Text := Qry.FieldByName('TABLE_DESCRIPTION').AsTrimmedString;

      case Qry.FieldByName('TABLE_TYPE').AsInteger of
        0:
          zTable.TableType := ttPersistent;
        4:
          zTable.TableType := ttPerConnection;
        5:
          zTable.TableType := ttPerSession;
      end;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Tables');
end;

//
procedure TzFbMetadata.Fill_TableFields;
var
  zTable: TzmdTable;
  zField: TzmdTableField;
begin
  SiMain.EnterMethod(Self, 'Fill_TableFields');

  OpenQry(TMetadataQuery.TableFields);
  try
    zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, 0);
    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('TABLE_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, zTable.Index);

      zField := zTable.Fields.Add;
      zField.name := Qry.FieldByName('FIELD_NAME').AsTrimmedString;
      zField.Domain := Qry.FieldByName('DOMAIN_NAME').AsTrimmedString;
      zField.NotNull := ((Qry.FieldByName('FIELD_NOT_NULL').AsTrimmedString = '1') or (Qry.FieldByName('DOMAIN_NOT_NULL').AsTrimmedString = '1'));
      zField.Size := Qry.FieldByName('DOMAIN_LENGTH').AsInteger;
      zField.DataType := GetDataType(Qry.FieldByName('DOMAIN_TYPE').AsInteger, Qry.FieldByName('DOMAIN_SUB_TYPE').AsInteger);

      zField.DefaultFromDomain := Trim(Qry.FieldByName('DOMAIN_DEFAULT').AsTrimmedString);
      zField.DefaultFromField := Trim(Qry.FieldByName('FIELD_DEFAULT').AsTrimmedString);

      zField.DefaultValue := Qry.FieldByName('FIELD_DEFAULT').AsTrimmedString;
      if zField.DefaultValue = '' then
        zField.DefaultValue := Qry.FieldByName('DOMAIN_DEFAULT').AsTrimmedString;

      zField.DefaultValue := Trim(zField.DefaultValue); // 02.08.2012 In alcuni casi FB2.5 ritorna uno spazio prima di default

      zField.CalculatedSource := Qry.FieldByName('DOMAIN_SOURCE').AsTrimmedString;
      zField.FbDataType := Qry.FieldByName('FIELD_SQL_DATA_TYPE').AsTrimmedString;
      zField.Identity := SameText(Qry.FieldByName('FIELD_IDENTITY_TYPE').AsTrimmedString, '1');
      zField.Description.Text := Qry.FieldByName('FIELD_DESCRIPTION').AsTrimmedString;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TableFields');
end;

procedure TzFbMetadata.Fill_TablePrimaryKeys;
var
  zTable: TzmdTable;
  zFieldName: TzmdFieldName;
begin
  SiMain.EnterMethod(Self, 'Fill_TablePrimaryKeys');

  OpenQry(TMetadataQuery.TablePrimaryKeys);
  try
    zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, 0);
    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('TABLE_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, zTable.Index);

      zTable.PrimaryKeyName := Qry.FieldByName('PRIMARY_KEY_NAME').AsTrimmedString;
      zFieldName := zTable.PrimaryKey.Add;
      zFieldName.name := Qry.FieldByName('FIELD_NAME').AsTrimmedString;
      zFieldName.Description.Text := '';

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TablePrimaryKeys');
end;

procedure TzFbMetadata.Fill_TableForeignKeys;
var
  zTable: TzmdTable;
  zForeignKey: TzmdForeignKey;
begin
  SiMain.EnterMethod(Self, 'Fill_TableForeignKeys');

  OpenQry(TMetadataQuery.TableForeignKeys);
  try
    if Qry.IsEmpty then
      exit;

    zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, 0);

    if not Assigned(zTable) then
      raise exception.Create('FK - Tabella non trovata: ' + Qry.FieldByName('TABLE_NAME').AsTrimmedString);

    zForeignKey := zTable.ForeignKeys.Add;
    zForeignKey.name := Qry.FieldByName('FK_NAME').AsTrimmedString;
    zForeignKey.FkTable := Qry.FieldByName('FK_TABLE_NAME').AsTrimmedString;

    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('TABLE_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, zTable.Index);

      if not SameText(zForeignKey.name, Qry.FieldByName('FK_NAME').AsTrimmedString) then
      begin
        zForeignKey := zTable.ForeignKeys.Add;
        zForeignKey.name := Qry.FieldByName('FK_NAME').AsTrimmedString;
        zForeignKey.FkTable := Qry.FieldByName('FK_TABLE_NAME').AsTrimmedString;

        zForeignKey.FkContraintType := getConstraintType(Qry.FieldByName('FK_CONSTRAINT_TYPE').AsTrimmedString);
        zForeignKey.FkContraintName := Qry.FieldByName('FK_CONSTRAINT_NAME').AsTrimmedString;

        zForeignKey.UpdateRule := Qry.FieldByName('UPD_RULE').AsTrimmedString;
        zForeignKey.DeleteRule := Qry.FieldByName('DEL_RULE').AsTrimmedString;
      end;

      zForeignKey.Fields.Add.name := Qry.FieldByName('FIELD_NAME').AsTrimmedString;
      zForeignKey.FkFields.Add.name := Qry.FieldByName('FK_FIELD_NAME').AsTrimmedString;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TableForeignKeys');
end;

procedure TzFbMetadata.Fill_Views(const LoadSource: Boolean);
var
  zView: TzmdView;
begin
  SiMain.EnterMethod(Self, 'Fill_Views');

  OpenQry(TMetadataQuery.Views, LoadSource);
  try
    while not Qry.Eof do
    begin
      zView := Metadata.Views.Add;
      zView.name := Qry.FieldByName('VIEW_NAME').AsTrimmedString;
      zView.HasTriggerInsert := Qry.FieldByName('TRIGGER_INS').AsBoolean;
      zView.HasTriggerUpdate := Qry.FieldByName('TRIGGER_UPD').AsBoolean;
      zView.HasTriggerDelete := Qry.FieldByName('TRIGGER_DEL').AsBoolean;
      zView.Description.Text := Qry.FieldByName('VIEW_DESCRIPTION').AsTrimmedString;
      zView.Source.Text := Qry.FieldByName('VIEW_SOURCE').AsTrimmedString;
      zView.CreationOrder := Qry.FieldByName('CREATION_ORDER').AsInteger;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Views');
end;

procedure TzFbMetadata.Fill_ViewFields;
var
  zView: TzmdView;
  zField: TzmdViewField;
begin
  SiMain.EnterMethod(Self, 'Fill_ViewFields');

  OpenQry(TMetadataQuery.ViewFields);
  try
    zView := Metadata.Views.Get(Qry.FieldByName('VIEW_NAME').AsTrimmedString, 0);

    while not Qry.Eof do
    begin

      if not SameText(zView.name, Qry.FieldByName('VIEW_NAME').AsTrimmedString) then
        zView := Metadata.Views.Get(Qry.FieldByName('VIEW_NAME').AsTrimmedString, zView.Index);

      zField := zView.Fields.Add;
      zField.name := Qry.FieldByName('FIELD_NAME').AsTrimmedString;
      zField.Domain := Qry.FieldByName('DOMAIN_NAME').AsTrimmedString;
      zField.NotNull := ((Qry.FieldByName('FIELD_NOT_NULL').AsTrimmedString = '1') or (Qry.FieldByName('DOMAIN_NOT_NULL').AsTrimmedString = '1'));
      zField.Size := Qry.FieldByName('DOMAIN_LENGTH').AsInteger;
      zField.DataType := GetDataType(Qry.FieldByName('DOMAIN_TYPE').AsInteger, Qry.FieldByName('DOMAIN_SUB_TYPE').AsInteger);

      zField.DefaultValue := Qry.FieldByName('FIELD_DEFAULT').AsTrimmedString;
      if zField.DefaultValue = '' then
        zField.DefaultValue := Qry.FieldByName('DOMAIN_DEFAULT').AsTrimmedString;

      zField.DefaultValue := Trim(zField.DefaultValue); // 02.08.2012 In alcuni casi FB2.5 ritorna uno spazio prima di default

      zField.CalculatedSource := Qry.FieldByName('DOMAIN_SOURCE').AsTrimmedString;
      zField.Description.Text := Qry.FieldByName('FIELD_DESCRIPTION').AsTrimmedString;

      zField.SrcRelation := Qry.FieldByName('SRC_RELATION_NAME').AsTrimmedString;
      zField.SrcFieldName := Qry.FieldByName('SRC_RELATION_FIELD').AsTrimmedString;
      zField.FbDataType := Qry.FieldByName('FIELD_SQL_DATA_TYPE').AsTrimmedString;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_ViewFields');
end;

procedure TzFbMetadata.Fill_Procedures(const LoadSource: Boolean);
var
  zProcedure: TzmdProcedure;
begin
  SiMain.EnterMethod(Self, 'Fill_Procedures');

  OpenQry(TMetadataQuery.Procedures, LoadSource);
  try
    while not Qry.Eof do
    begin
      zProcedure := Metadata.Procedures.Add;
      zProcedure.name := Qry.FieldByName('PROCEDURE_NAME').AsTrimmedString;
      zProcedure.Package := Qry.FieldByName('PACKAGE_NAME').AsTrimmedString;

      zProcedure.name := FullMetadataName(zProcedure.Package, zProcedure.name);

      zProcedure.Description.Text := Qry.FieldByName('PROCEDURE_DESCRIPTION').AsTrimmedString;
      zProcedure.Source.Text := Qry.FieldByName('PROCEDURE_SOURCE').AsTrimmedString;

      case Qry.FieldByName('PROCEDURE_TYPE').AsInteger of
        0:
          zProcedure.ProcedureType := ptLegacy;
        1:
          zProcedure.ProcedureType := ptSelect;
        2:
          zProcedure.ProcedureType := ptExecute;
      end;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Procedures');
end;

procedure TzFbMetadata.Fill_ProcedureParams;
var
  zProcedure: TzmdProcedure;
  zParam: TzmdParam;
  FullName: String;

begin
  SiMain.EnterMethod(Self, 'Fill_ProcedureParams');

  OpenQry(TMetadataQuery.ProcedureParams);
  try
    FullName := FullMetadataName(Qry.FieldByName('PACKAGE_NAME').AsTrimmedString, Qry.FieldByName('PROCEDURE_NAME').AsTrimmedString);
    zProcedure := Metadata.Procedures.Get(FullName, 0);

    while not Qry.Eof do
    begin
      FullName := FullMetadataName(Qry.FieldByName('PACKAGE_NAME').AsTrimmedString, Qry.FieldByName('PROCEDURE_NAME').AsTrimmedString);

      if not SameText(FullMetadataName(zProcedure.Package, zProcedure.name), FullName) then
        zProcedure := Metadata.Procedures.Get(FullName, zProcedure.Index);

      if Qry.FieldByName('PARAM_TYPE').AsInteger = 0 then
        zParam := zProcedure.ParamsInput.Add
      else
        zParam := zProcedure.ParamsOutput.Add;

      zParam.name := Qry.FieldByName('PARAM_NAME').AsTrimmedString;
      zParam.Domain := Qry.FieldByName('DOMAIN_NAME').AsTrimmedString;
      zParam.Size := Qry.FieldByName('DOMAIN_LENGTH').AsInteger;
      zParam.FbDataType := Qry.FieldByName('PARAM_SQL_DATA_TYPE').AsTrimmedString;
      zParam.DataType := GetDataType(Qry.FieldByName('DOMAIN_TYPE').AsInteger, Qry.FieldByName('DOMAIN_SUB_TYPE').AsInteger);
      zParam.Description.Text := Qry.FieldByName('PARAM_DESCRIPTION').AsTrimmedString;
      zParam.DefaultValue := Qry.FieldByName('FIELD_DEFAULT').AsTrimmedString;
      zParam.Mechanism := Qry.FieldByName('MECHANISM').AsInteger;
      zParam.TypeOfColumn := Qry.FieldByName('TYPE_OF_COLUMN').AsTrimmedString;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_ProcedureParams');
end;

procedure TzFbMetadata.Fill_TableChecks;
var
  idx: integer;
  zTable: TzmdTable;
  CheckConstraint: TzmdCheckConstraint;
begin
  SiMain.EnterMethod(Self, 'Fill_TableChecks');

  OpenQry(TMetadataQuery.TableChecks);
  try
    zTable := Metadata.Tables.Get(Qry.FieldByName('RELATION_NAME').AsTrimmedString, 0);
    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('RELATION_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('RELATION_NAME').AsTrimmedString, zTable.Index);

      CheckConstraint := zTable.CheckConstraints.Add;
      CheckConstraint.name := Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString;
      CheckConstraint.CheckConstraint.Text := Qry.FieldByName('TRIGGER_SOURCE').AsTrimmedString;
      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TableChecks');
end;

procedure TzFbMetadata.Fill_TableIndexes;
var
  idx: integer;
  zTable: TzmdTable;
  TableIndex: TzmdTableIndex;
begin
  SiMain.EnterMethod(Self, 'Fill_TableIndexes');

  OpenQry(TMetadataQuery.TableIndexes);
  try
    zTable := Metadata.Tables.Get(Qry.FieldByName('RELATION_NAME').AsTrimmedString, 0);
    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('RELATION_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('RELATION_NAME').AsTrimmedString, zTable.Index);

      // if not assigned (ztable) then
      // raise exception.create(Qry.FieldByName('RELATION_NAME').AsTrimmedString);

      idx := zTable.Indexes.IndexOf(Qry.FieldByName('INDEX_NAME').AsTrimmedString);
      if idx = -1 then
      begin
        TableIndex := zTable.Indexes.Add;
        TableIndex.name := Qry.FieldByName('INDEX_NAME').AsTrimmedString;
        TableIndex.TableName := Qry.FieldByName('RELATION_NAME').AsTrimmedString;
        TableIndex.Unique := Qry.FieldByName('UNIQUE_FLAG').AsInteger = 1;
        TableIndex.Inactive := Qry.FieldByName('INDEX_INACTIVE').AsInteger = 1;
        TableIndex.Descending := Qry.FieldByName('INDEX_TYPE').AsInteger = 1;
        TableIndex.IndexExpression := Qry.FieldByName('EXPRESSION_SOURCE').AsTrimmedString;
      end
      else
        TableIndex := zTable.Indexes[idx];

      TableIndex.IndexFieldNames.Add.name := Qry.FieldByName('FIELD_NAME').AsTrimmedString;
      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TableIndexes');
end;

procedure TzFbMetadata.Fill_TableUniques;
var
  idx: integer;
  zTable: TzmdTable;
  Unique: TzmdUniqueConstraint;
begin
  SiMain.EnterMethod(Self, 'Fill_TableUniques');

  OpenQry(TMetadataQuery.TableUniques);
  try
    zTable := Metadata.Tables.Get(Qry.FieldByName('RELATION_NAME').AsTrimmedString, 0);
    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('RELATION_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('RELATION_NAME').AsTrimmedString, zTable.Index);

      idx := zTable.UniqueConstraints.IndexOf(Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString);
      if idx = -1 then
      begin
        Unique := zTable.UniqueConstraints.Add;
        Unique.name := Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString;
        Unique.IndexName := Qry.FieldByName('INDEX_NAME').AsTrimmedString;
      end
      else
        Unique := zTable.UniqueConstraints[idx];

      Unique.UniqueFieldNames.Add.name := Qry.FieldByName('FIELD_NAME').AsTrimmedString;
      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TableUniques');
end;

procedure TzFbMetadata.Fill_Triggers(const LoadSource: Boolean);
var
  zTrigger: TzmdTrigger;
begin
  SiMain.EnterMethod(Self, 'Fill_Triggers');

  OpenQry(TMetadataQuery.Triggers, LoadSource);
  try
    while not Qry.Eof do
    begin
      zTrigger := Metadata.Triggers.Add;
      zTrigger.name := Qry.FieldByName('TRIGGER_NAME').AsTrimmedString;
      zTrigger.TableName := Qry.FieldByName('RELATION_NAME').AsTrimmedString;
      zTrigger.Position := Qry.FieldByName('TRIGGER_SEQUENCE').AsInteger;
      zTrigger.Active := not SameText(Qry.FieldByName('TRIGGER_INACTIVE').AsTrimmedString, '1');
      zTrigger.TriggerType := Qry.FieldByName('TRIGGER_TYPE').AsLargeInt;
      // zTrigger.BeforeInsert := SameText(Qry.FieldByName('BEFORE_INSERT').AsTrimmedString, 'S');
      // zTrigger.BeforeUpdate := SameText(Qry.FieldByName('BEFORE_UPDATE').AsTrimmedString, 'S');
      // zTrigger.BeforeDelete := SameText(Qry.FieldByName('BEFORE_DELETE').AsTrimmedString, 'S');
      // zTrigger.AfterInsert := SameText(Qry.FieldByName('AFTER_INSERT').AsTrimmedString, 'S');
      // zTrigger.AfterUpdate := SameText(Qry.FieldByName('AFTER_UPDATE').AsTrimmedString, 'S');
      // zTrigger.AfterDelete := SameText(Qry.FieldByName('AFTER_DELETE').AsTrimmedString, 'S');
      zTrigger.Description.Text := Qry.FieldByName('DESCRIPTION').AsTrimmedString;
      zTrigger.Source.Text := Qry.FieldByName('TRIGGER_SOURCE').AsTrimmedString;
      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Triggers');
end;

procedure TzFbMetadata.Fill_Functions(const LoadSource: Boolean);
var
  zFunc: TzmdFunction;
begin
  SiMain.EnterMethod(Self, 'Fill_Functions');

  OpenQry(TMetadataQuery.Functions, LoadSource);
  try
    while not Qry.Eof do
    begin
      zFunc := Metadata.Functions.Add;

      zFunc.name := Qry.FieldByName('FUNCTION_NAME').AsTrimmedString;
      zFunc.Package := Qry.FieldByName('PACKAGE_NAME').AsTrimmedString;

      zFunc.name := FullMetadataName(zFunc.Package, zFunc.name);

      zFunc.ReturnParam.FbDataType := Qry.FieldByName('RETURN_SQL_DATA_TYPE').AsTrimmedString;
      zFunc.ReturnParam.Domain := Qry.FieldByName('RETURN_DOMAIN').AsTrimmedString;
      zFunc.ReturnParam.Mechanism := Qry.FieldByName('RETURN_MECHANISM').AsInteger;
      zFunc.ReturnParam.TypeOfColumn := Qry.FieldByName('RETURN_TYPE_OF_COLUMN').AsTrimmedString;
      zFunc.ReturnParam.DataType := GetDataType(Qry.FieldByName('RETURN_TYPE').AsInteger, Qry.FieldByName('RETURN_SUB_TYPE').AsInteger);
      zFunc.Description.Text := Qry.FieldByName('DESCRIPTION').AsTrimmedString;
      zFunc.Source.Text := Qry.FieldByName('FUNCTION_SOURCE').AsTrimmedString;
      zFunc.RequiredByTable := Qry.FieldByName('REQUIRED_BY_TABLE').AsBoolean;
      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Functions');
end;

/// //////////////////////////////////////////////////////
procedure TzFbMetadata.Fill_FunctionParams;
var
  zFunction: TzmdFunction;
  zParam: TzmdParam;
  FullName: String;
begin
  SiMain.EnterMethod(Self, 'Fill_ProcedureParams');

  OpenQry(TMetadataQuery.FunctionParams);
  try
    FullName := FullMetadataName(Qry.FieldByName('PACKAGE_NAME').AsTrimmedString, Qry.FieldByName('FUNCTION_NAME').AsTrimmedString);
    zFunction := Metadata.Functions.Get(FullName, 0);

    while not Qry.Eof do
    begin
      FullName := FullMetadataName(Qry.FieldByName('PACKAGE_NAME').AsTrimmedString, Qry.FieldByName('FUNCTION_NAME').AsTrimmedString);

      if not SameText(FullMetadataName(zFunction.Package, zFunction.name), FullName) then
        zFunction := Metadata.Functions.Get(FullName, zFunction.Index);

      zParam := zFunction.Params.Add;
      zParam.name := Qry.FieldByName('ARGUMENT_NAME').AsTrimmedString;
      zParam.FbDataType := Qry.FieldByName('PARAM_SQL_DATA_TYPE').AsTrimmedString;
      zParam.Domain := Qry.FieldByName('PARAM_DOMAIN').AsTrimmedString;
      zParam.Mechanism := Qry.FieldByName('PARAM_MECHANISM').AsInteger;
      zParam.TypeOfColumn := Qry.FieldByName('PARAM_TYPE_OF_COLUMN').AsTrimmedString;
      zParam.Size := Qry.FieldByName('PARAM_LENGTH').AsInteger;
      zParam.DataType := GetDataType(Qry.FieldByName('PARAM_TYPE').AsInteger, Qry.FieldByName('PARAM_SUB_TYPE').AsInteger);
      zParam.DefaultValue := Trim(Qry.FieldByName('DEFAULT_SOURCE').AsTrimmedString);
      zParam.Description.Text := Qry.FieldByName('DESCRIPTION').AsTrimmedString;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_ProcedureParams');
end;

procedure TzFbMetadata.Fill_TableDependencies;
var
  dependency: TzmdDependency;
  idx: integer;
  zTable: TzmdTable;
  TableIndex: TzmdTableIndex;
begin
  SiMain.EnterMethod(Self, 'Fill_TableDependencies');

  OpenQry(TMetadataQuery.TableDependencies);
  try
    zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, 0);
    while not Qry.Eof do
    begin
      if not SameText(zTable.name, Qry.FieldByName('TABLE_NAME').AsTrimmedString) then
        zTable := Metadata.Tables.Get(Qry.FieldByName('TABLE_NAME').AsTrimmedString, zTable.Index);

      // if not assigned (ztable) then
      // raise exception.create(Qry.FieldByName('RELATION_NAME').AsTrimmedString);

      if SameText(Qry.FieldByName('CONSTRAINT_TYPE').AsTrimmedString, 'PRIMARY KEY') then
      begin
        // if not SameText(Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString, zTable.PrimaryKeyName) then
        // raise exception.Create('Nome PK non valido. Tabella ' + zTable.name + ' pk/unique ' + Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString);

        dependency := zTable.PrimaryKeyDependencies.Add;
        dependency.name := Qry.FieldByName('DEPENDENT_FK_NAME').AsTrimmedString;
        dependency.TableName := Qry.FieldByName('DEPENDENT_TABLE').AsTrimmedString;
      end
      else
        if SameText(Qry.FieldByName('CONSTRAINT_TYPE').AsTrimmedString, 'UNIQUE') then
        begin
          idx := zTable.UniqueConstraints.IndexOf(Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString);
          if idx <> -1 then
          begin
            dependency := zTable.UniqueConstraints[idx].Dependencies.Add;
            dependency.name := Qry.FieldByName('DEPENDENT_FK_NAME').AsTrimmedString;
            dependency.TableName := Qry.FieldByName('DEPENDENT_TABLE').AsTrimmedString;
          end
          else
            raise exception.Create('PK/UNIQUE non trovato. Tabella ' + zTable.name + ' pk/unique ' + Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString);
        end
        else
          raise exception.Create('Tipo constraint non gestito: ' + Qry.FieldByName('CONSTRAINT_TYPE').AsTrimmedString + '. Tabella ' + zTable.name + ' pk/unique ' + Qry.FieldByName('CONSTRAINT_NAME').AsTrimmedString);

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_TableDependencies');
end;

procedure TzFbMetadata.Fill_Packages;
var
  zPackage: TzmdPackage;
begin
  SiMain.EnterMethod(Self, 'Fill_Packages');

  OpenQry(TMetadataQuery.Packages);
  try
    while not Qry.Eof do
    begin
      zPackage := Metadata.Packages.Add;
      zPackage.name := Qry.FieldByName('PACKAGE_NAME').AsTrimmedString;
      zPackage.Header.Text := Qry.FieldByName('PACKAGE_HEADER').AsTrimmedString;
      zPackage.Body.Text := Qry.FieldByName('PACKAGE_BODY').AsTrimmedString;
      zPackage.Description.Text := Qry.FieldByName('PACKAGE_DESCRIPTION').AsTrimmedString;

      Qry.Next;
    end;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Procedures');
end;

procedure TzFbMetadata.Fill_Picklists;
var
  Picklist: TzmdPicklist;
begin
  SiMain.EnterMethod(Self, 'Fill_Picklists');

  { TODO : Togliere }
  if TMetadataQuery.PickLists.IsEmpty then
    exit;

  OpenQry(TMetadataQuery.PickLists);
  /// ///////////////
  try
    while not Qry.Eof do
    begin
      Picklist := Metadata.PickLists.Add;
      Picklist.name := Qry.FieldByName('PICKLIST').AsTrimmedString;
      Picklist.Description.Text := Qry.FieldByName('DESCRIPTION').AsTrimmedString;
      Qry.Next;
    end;

    Metadata.PickLists.Sort;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Picklists');
end;

procedure TzFbMetadata.Fill_Lookups;
var
  Lookup: TzmdLookup;
begin
  SiMain.EnterMethod(Self, 'Fill_Lookups');

  { TODO : Togliere }
  if TMetadataQuery.Lookups.IsEmpty then
    exit;

  OpenQry(TMetadataQuery.Lookups);
  /// ///////////////
  try
    while not Qry.Eof do
    begin
      Lookup := Metadata.Lookups.Add;
      Lookup.name := Qry.FieldByName('LOOKUP').AsTrimmedString;
      Lookup.FieldNames := Qry.FieldByName('FIELD_NAMES').AsTrimmedString;
      Lookup.TableName := Qry.FieldByName('TABLE_NAME').AsTrimmedString;
      Lookup.FieldNamesFK := Qry.FieldByName('FIELD_NAMES_FK').AsTrimmedString;
      Lookup.TableNameFK := Qry.FieldByName('TABLE_NAME_FK').AsTrimmedString;
      Lookup.DisplayColumns := Qry.FieldByName('DISPLAY_COLUMNS').AsTrimmedString;
      Lookup.Mappings.Text := Qry.FieldByName('MAPPINGS').AsTrimmedString;
      Lookup.SelectSQL.Text := Qry.FieldByName('SELECT_SQL').AsTrimmedString;
      Qry.Next;
    end;

    Metadata.Lookups.Sort;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_Lookups');
end;

procedure TzFbMetadata.Fill_DataDictionary;

  function GetAlignment(const Aligment: string): TAlignment;
  var
    s: String;
  begin
    s := Aligment.Trim.ToUpper;

    if s = 'D' then
      result := taRightJustify
    else
      if s = 'S' then
        result := taLeftJustify
      else
        result := taCenter;
  end;

var
  FieldSensitivityExists: Boolean;
  item: TzmdDataDictionaryItem;
begin
  SiMain.EnterMethod(Self, 'Fill_DataDictionary');

  { TODO : Togliere }
  if TMetadataQuery.DataDictionary.IsEmpty then
    exit;

  OpenQry(TMetadataQuery.DataDictionary);
  /// ///////////////
  try
    FieldSensitivityExists := Assigned(Qry.FindField('SENSITIVITY'));

    Metadata.DataDictionary.BeginUpdate;
    try
      while not Qry.Eof do
      begin
        item := Metadata.DataDictionary.Add;
        item.name := Qry.FieldByName('FIELD_ORIGIN').AsTrimmedString;
        item.RelationType := Qry.FieldByName('RELATION_TYPE').AsTrimmedString;
        item.PackageName := Qry.FieldByName('PACKAGE_NAME').AsTrimmedString;
        item.RelationName := Qry.FieldByName('RELATION_NAME').AsTrimmedString;
        item.RelationField := Qry.FieldByName('RELATION_FIELD').AsTrimmedString;
        item.FieldOrigin := Qry.FieldByName('FIELD_ORIGIN').AsTrimmedString;
        item.OriginRelationType := Qry.FieldByName('ORIGIN_RELATION_TYPE').AsTrimmedString;
        item.OriginRelationName := Qry.FieldByName('ORIGIN_RELATION_NAME').AsTrimmedString;
        item.OriginRelationField := Qry.FieldByName('ORIGIN_FIELD_NAME').AsTrimmedString;
        item.FieldPosition := Qry.FieldByName('FIELD_POSITION').AsInteger;
        item.FieldDomain := Qry.FieldByName('FIELD_DOMAIN').AsTrimmedString;
        item.FieldType := GetDataType(Qry.FieldByName('FIELD_TYPE').AsInteger, Qry.FieldByName('FIELD_SUB_TYPE').AsInteger);
        item.FieldSize := Qry.FieldByName('FIELD_SIZE').AsInteger;
        item.FieldDecimals := Qry.FieldByName('FIELD_DECIMALS').AsInteger;
        item.Calculated := Qry.FieldByName('CALCULATED').AsBoolean;
        item.Identity := Qry.FieldByName('IDENTITY_').AsBoolean;
        item.Readonly := Qry.FieldByName('READONLY').AsBoolean;
        item.Required := Qry.FieldByName('REQUIRED').AsBoolean;
        item.DefaultValue := Qry.FieldByName('DEFAULT_VALUE').AsTrimmedString;
        item.Caption := Qry.FieldByName('CAPTION').AsTrimmedString;
        item.Alignment := GetAlignment(Qry.FieldByName('ALIGN').AsTrimmedString);
        item.EditorType.AsString := Qry.FieldByName('EDITOR_TYPE').AsTrimmedString;
        item.ColSpan := Qry.FieldByName('COL_SPAN').AsInteger;
        item.Lookup := Qry.FieldByName('LOOKUP').AsTrimmedString;
        item.Picklist := Qry.FieldByName('PICKLIST').AsTrimmedString;

        item.HasSensitivity := False;
        item.Sensitivity := slNone;

        if FieldSensitivityExists then
        begin
          item.HasSensitivity := not Qry.FieldByName('SENSITIVITY').isNull;
          if item.HasSensitivity then
            item.Sensitivity := TAISensitivity(Qry.FieldByName('SENSITIVITY').AsInteger)
          else
            item.Sensitivity := slNone;
        end;

        Qry.Next;
      end;
    finally
      Metadata.DataDictionary.EndUpdate;
    end;

    Metadata.DataDictionary.Sort;
  finally
    CloseQry;
  end;
  SiMain.LeaveMethod(Self, 'Fill_DataDictionary');
end;

procedure TzFbMetadata.AssignPackageDetails;
var
  zPackage: TzmdPackage;
  zFunc: TzmdFunction;
  zProcedure: TzmdProcedure;
begin

  for zPackage in Metadata.Packages do
  begin
    zPackage.Functions.Clear;
    for zFunc in Metadata.Functions do
      if SameText(zFunc.Package, zPackage.name) then
        zPackage.Functions.Add.Assign(zFunc);

    zPackage.Procedures.Clear;
    for zProcedure in Metadata.Procedures do
      if SameText(zProcedure.Package, zPackage.name) then
        zPackage.Procedures.Add.Assign(zProcedure);
  end;
end;

/// //////////////////////////////////////////////////////

procedure FillFirebirdMetadata(Metadata: TzMetadata; Connection: TFDConnection; Transaction: TFDTransaction; const LoadSource: Boolean; CallBack: TProc<string> = nil; const loadBase: Boolean = true);
var
  zFbMetadata: TzFbMetadata;
begin
  SiMain.EnterMethod('FillFirebirdMetadata');
  Assert(Assigned(Metadata));
  Assert(Assigned(Connection));
  Assert(Assigned(Transaction));

  zFbMetadata := TzFbMetadata.Create(Metadata, Connection, Transaction);
  try
    zFbMetadata.FillMetadata(LoadSource, CallBack, loadBase);
  finally
    FreeAndNil(zFbMetadata);
  end;
  SiMain.LeaveMethod('FillFirebirdMetadata');
end;

end.
