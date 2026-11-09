unit zMetadata;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  zCollection,
  zBaseLib,
  zMetadata.Types,
  zAI.Types;

type
  TMetadataElement = (meDomain, meTable, meView, meStoredProc, meFunc, mePackage, meTrigger, meSequence);

  TProcedureType = (ptLegacy, ptSelect, ptExecute);
  TContraintType = (ctNone, ctPrimaryKey, ctForeignKey, ctUnique, ctCheck);

  TzmdTable = class;

  TzMetadataItem = class(TzCollectionItem)
  private
    FDescription: TStringList;
    procedure SetDescription(const Value: TStringList);
  protected
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Description: TStringList read FDescription write SetDescription;
  end;

  TzMetadataSourceCodeItem = class(TzMetadataItem)
  private
    FSource: TStringList;
    procedure SetSource(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Source: TStringList read FSource write SetSource;
  end;

  TzmdParam = class(TzMetadataItem)
  private
    FDataType: TFieldType;
    FDefaultValue: string;
    FDomain: string;
    FFbDataType: string;
    FSize: integer;
    FMechanism: integer;
    FTypeOfColumn: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function IsBlob: boolean;
    function HasDomain: boolean;

    function DDL(const UseDomains: boolean = true): string;
  published
    property DataType: TFieldType read FDataType write FDataType default ftString;
    property FbDataType: string read FFbDataType write FFbDataType;
    property Domain: string read FDomain write FDomain;
    property Size: integer read FSize write FSize default 0;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property Mechanism: integer read FMechanism write FMechanism;
    property TypeOfColumn: string read FTypeOfColumn write FTypeOfColumn;
  end;

  TzmdDependency = class(TzMetadataItem)
  private
    FTableName: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property TableName: string read FTableName write FTableName;
  end;

  TzmdFieldName = class(TzMetadataItem)
  end;

  TzmdGenerator = class(TzMetadataItem)
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  end;

  TzmdDomain = class(TzMetadataItem)
  private
    FCharacterSetId: integer;
    FCharacterSetName: string;
    FCheckConstraint: string;
    FCollationId: integer;
    FCollationName: string;
    FDataType: TFieldType;
    FDefaultValue: string;
    FFbDataType: string;
    FRequired: boolean;
    FSize: integer;
    procedure SetCheckConstraint(const Value: string);
    procedure SetDataType(const Value: TFieldType);
    procedure SetDefaultValue(const Value: string);
    procedure SetSize(const Value: integer);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property DataType: TFieldType read FDataType write SetDataType default ftString;
    property FbDataType: string read FFbDataType write FFbDataType;
    property DefaultValue: string read FDefaultValue write SetDefaultValue;
    property Required: boolean read FRequired write FRequired default false;
    property CheckConstraint: string read FCheckConstraint write SetCheckConstraint;
    property Size: integer read FSize write SetSize default 0;
    ///
    property CharacterSetId: integer read FCharacterSetId write FCharacterSetId;
    property CharacterSetName: string read FCharacterSetName write FCharacterSetName;
    property CollationId: integer read FCollationId write FCollationId;
    property CollationName: string read FCollationName write FCollationName;
  end;

  TzmdFunction = class(TzMetadataSourceCodeItem)
  private
    FPackage: String;
    FParams: TzCollection<TzmdParam>;
    FRequiredByTable: boolean;
    FReturnParam: TzmdParam;
    procedure SetParams(const Value: TzCollection<TzmdParam>);
    procedure SetReturnParam(const Value: TzmdParam);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Package: String read FPackage write FPackage;
    property Params: TzCollection<TzmdParam> read FParams write SetParams;
    property ReturnParam: TzmdParam read FReturnParam write SetReturnParam;
    property RequiredByTable: boolean read FRequiredByTable write FRequiredByTable;
  end;

  TzmdField = class(TzMetadataItem)
  private
    FCalculatedSource: string;
    FDataType: TFieldType;
    FDefaultFromDomain: string;
    FDefaultFromField: string;
    FDefaultValue: string;
    FDomain: string;
    FFbDataType: string;
    FNotNull: boolean;
    FSize: integer;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function IsBlob: boolean;
    function Calculated: boolean;
    function HasDomain: boolean;
  published
    property CalculatedSource: string read FCalculatedSource write FCalculatedSource;
    property DataType: TFieldType read FDataType write FDataType default ftString;
    property FbDataType: string read FFbDataType write FFbDataType;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property DefaultFromField: string read FDefaultFromField write FDefaultFromField;
    property DefaultFromDomain: string read FDefaultFromDomain write FDefaultFromDomain;
    property Domain: string read FDomain write FDomain;
    property NotNull: boolean read FNotNull write FNotNull;
    property Size: integer read FSize write FSize default 0;
  end;

  TzmdTableField = class(TzmdField)
  private
    FIdentity: boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;

    function Table: TzmdTable;
  published
    property Identity: boolean read FIdentity write FIdentity default false;
  end;

  TzmdViewField = class(TzmdField)
  private
    FSrcFieldName: string;
    FSrcRelation: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property SrcRelation: string read FSrcRelation write FSrcRelation;
    property SrcFieldName: string read FSrcFieldName write FSrcFieldName;
  end;

  TzmdTableConstraint = class(TzMetadataItem)
  public
    function Table: TzmdTable;
  end;

  TzmdForeignKey = class(TzmdTableConstraint)
  private
    FDeleteRule: String;
    FFkFields: TzCollection<TzmdFieldName>;
    FFields: TzCollection<TzmdFieldName>;
    FFkContraintName: string;
    FFkContraintType: TContraintType;
    FFkTable: string;
    FUpdateRule: String;
    procedure SetFkFields(const Value: TzCollection<TzmdFieldName>);
    procedure SetFields(const Value: TzCollection<TzmdFieldName>);
    procedure SetFkTable(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Fields: TzCollection<TzmdFieldName> read FFields write SetFields;
    property FkFields: TzCollection<TzmdFieldName> read FFkFields write SetFkFields;
    property FkTable: string read FFkTable write SetFkTable;
    property FkContraintType: TContraintType read FFkContraintType write FFkContraintType default ctNone;
    property FkContraintName: string read FFkContraintName write FFkContraintName;
    property UpdateRule: String read FUpdateRule write FUpdateRule;
    property DeleteRule: String read FDeleteRule write FDeleteRule;
  end;

  TzmdCheckConstraint = class(TzmdTableConstraint)
  private
    FCheckConstraint: TStringList;
    procedure SetCheckConstraint(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property CheckConstraint: TStringList read FCheckConstraint write SetCheckConstraint;
  end;

  TzmdUniqueConstraint = class(TzmdTableConstraint)
  private
    FDependencies: TzCollection<TzmdDependency>;
    FIndexName: string;
    FUniqueFieldNames: TzCollection<TzmdFieldName>;
    procedure SetDependencies(const Value: TzCollection<TzmdDependency>);
    procedure SetUniqueFieldNames(const Value: TzCollection<TzmdFieldName>);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property IndexName: string read FIndexName write FIndexName;
    property UniqueFieldNames: TzCollection<TzmdFieldName> read FUniqueFieldNames write SetUniqueFieldNames;
    property Dependencies: TzCollection<TzmdDependency> read FDependencies write SetDependencies;
  end;

  TzmdTableIndex = class(TzmdTableConstraint)
  private
    FDescending: boolean;
    FInactive: boolean;
    FIndexExpression: string;
    FIndexFieldNames: TzCollection<TzmdFieldName>;
    FTableName: string;
    FUnique: boolean;
    procedure SetIndexFieldNames(const Value: TzCollection<TzmdFieldName>);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property TableName: string read FTableName write FTableName;
    property Unique: boolean read FUnique write FUnique default false;
    property Inactive: boolean read FInactive write FInactive default false;
    property Descending: boolean read FDescending write FDescending default false;
    property IndexExpression: string read FIndexExpression write FIndexExpression;
    property IndexFieldNames: TzCollection<TzmdFieldName> read FIndexFieldNames write SetIndexFieldNames;
  end;

  TzmdTable = class(TzMetadataItem)
  public type
    TTableType = (ttPersistent, ttPerConnection, ttPerSession);
  private
    FCheckConstraints: TzCollection<TzmdCheckConstraint>;
    FFields: TzCollection<TzmdTableField>;
    FForeignKeys: TzCollection<TzmdForeignKey>;
    FIdentityField: string;
    FIndexes: TzCollection<TzmdTableIndex>;
    FPrimaryKey: TzCollection<TzmdFieldName>;
    FPrimaryKeyDependencies: TzCollection<TzmdDependency>;
    FPrimaryKeyName: string;
    FTableType: TTableType;
    FUniqueConstraints: TzCollection<TzmdUniqueConstraint>;
    procedure SetCheckConstraints(const Value: TzCollection<TzmdCheckConstraint>);
    procedure SetFields(const Value: TzCollection<TzmdTableField>);
    procedure SetForeignKeys(const Value: TzCollection<TzmdForeignKey>);
    procedure SetIndexes(const Value: TzCollection<TzmdTableIndex>);
    procedure SetPrimaryKey(const Value: TzCollection<TzmdFieldName>);
    procedure SetPrimaryKeyDependencies(const Value: TzCollection<TzmdDependency>);
    procedure SetUniqueConstraints(const Value: TzCollection<TzmdUniqueConstraint>);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property TableType: TTableType read FTableType write FTableType default ttPersistent;
    property Fields: TzCollection<TzmdTableField> read FFields write SetFields;
    property IdentityField: string read FIdentityField write FIdentityField;
    property PrimaryKeyName: string read FPrimaryKeyName write FPrimaryKeyName;
    property PrimaryKey: TzCollection<TzmdFieldName> read FPrimaryKey write SetPrimaryKey;
    property PrimaryKeyDependencies: TzCollection<TzmdDependency> read FPrimaryKeyDependencies write SetPrimaryKeyDependencies;
    property ForeignKeys: TzCollection<TzmdForeignKey> read FForeignKeys write SetForeignKeys;
    property Indexes: TzCollection<TzmdTableIndex> read FIndexes write SetIndexes;
    property CheckConstraints: TzCollection<TzmdCheckConstraint> read FCheckConstraints write SetCheckConstraints;
    property UniqueConstraints: TzCollection<TzmdUniqueConstraint> read FUniqueConstraints write SetUniqueConstraints;
  end;

  TzmdView = class(TzMetadataSourceCodeItem)
  private
    FFields: TzCollection<TzmdViewField>;
    FHasTriggerDelete: boolean;
    FHasTriggerInsert: boolean;
    FHasTriggerUpdate: boolean;
    FCreationOrder: integer;
    procedure SetFields(const Value: TzCollection<TzmdViewField>);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanModify: boolean;

    procedure GetFieldSrc(const FieldName: string; out SrcRelation, SrcFieldName: string);
    function GetSrcRelation(const FieldName: string): string;
    function GetSrcFieldName(const FieldName: string): string;
  published
    property Fields: TzCollection<TzmdViewField> read FFields write SetFields;
    property HasTriggerDelete: boolean read FHasTriggerDelete write FHasTriggerDelete default false;
    property HasTriggerInsert: boolean read FHasTriggerInsert write FHasTriggerInsert default false;
    property HasTriggerUpdate: boolean read FHasTriggerUpdate write FHasTriggerUpdate default false;
    property CreationOrder: integer read FCreationOrder write FCreationOrder;
  end;

  TzmdProcedure = class(TzMetadataSourceCodeItem)
  private
    FPackage: string;
    FParamsInput: TzCollection<TzmdParam>;
    FParamsOutput: TzCollection<TzmdParam>;
    FProcedureType: TProcedureType;
    procedure SetParamsInput(const Value: TzCollection<TzmdParam>);
    procedure SetParamsOutput(const Value: TzCollection<TzmdParam>);
    procedure SetProcedureType(const Value: TProcedureType);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    function HasTypeOfColumnParams: boolean;
    function HasInputParams: boolean;
    function HasOutputParams: boolean;
  published
    property Package: string read FPackage write FPackage;
    property ParamsInput: TzCollection<TzmdParam> read FParamsInput write SetParamsInput;
    property ParamsOutput: TzCollection<TzmdParam> read FParamsOutput write SetParamsOutput;
    property ProcedureType: TProcedureType read FProcedureType write SetProcedureType default ptLegacy;
  end;

  TzmdTrigger = class(TzMetadataSourceCodeItem)
  private
    FActive: boolean;
    FAfterAnyStatement: boolean;
    FAfterDelete: boolean;
    FAfterInsert: boolean;
    FAfterUpdate: boolean;
    FBeforeAnyStatement: boolean;
    FBeforeDelete: boolean;
    FBeforeInsert: boolean;
    FBeforeUpdate: boolean;
    FIsDbTrigger: boolean;
    FOnConnect: boolean;
    FOnDisconnect: boolean;
    FOnTransactionCommit: boolean;
    FOnTransactionRollback: boolean;
    FOnTransactionStart: boolean;
    FPosition: integer;
    FTableName: string;
    FTriggerType: Largeint;
    procedure SetTriggerType(const Value: Largeint);
  public type
    TTriggerKind = (tkUnknown, tkBefore, tkAfter);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function TriggerKind: TTriggerKind;
  published
    property TableName: string read FTableName write FTableName;
    property TriggerType: Largeint read FTriggerType write SetTriggerType;

    property Position: integer read FPosition write FPosition default 0;
    property Active: boolean read FActive write FActive default true;
  public
    property IsDbTrigger: boolean read FIsDbTrigger;

    property BeforeInsert: boolean read FBeforeInsert;
    property BeforeUpdate: boolean read FBeforeUpdate;
    property BeforeDelete: boolean read FBeforeDelete;
    property AfterInsert: boolean read FAfterInsert;
    property AfterUpdate: boolean read FAfterUpdate;
    property AfterDelete: boolean read FAfterDelete;

    property OnConnect: boolean read FOnConnect;
    property OnDisconnect: boolean read FOnDisconnect;
    property OnTransactionStart: boolean read FOnTransactionStart;
    property OnTransactionCommit: boolean read FOnTransactionCommit;
    property OnTransactionRollback: boolean read FOnTransactionRollback;
    property BeforeAnyStatement: boolean read FBeforeAnyStatement;
    property AfterAnyStatement: boolean read FAfterAnyStatement;
  end;

  TzmdPackage = class(TzMetadataSourceCodeItem)
  private
    FBody: TStringList;
    FFunctions: TzCollection<TzmdFunction>;
    FHeader: TStringList;
    FProcedures: TzCollection<TzmdProcedure>;
    procedure SetBody(const Value: TStringList);
    procedure SetFunctions(const Value: TzCollection<TzmdFunction>);
    procedure SetHeader(const Value: TStringList);
    procedure SetProcedures(const Value: TzCollection<TzmdProcedure>);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Functions: TzCollection<TzmdFunction> read FFunctions write SetFunctions;
    property Procedures: TzCollection<TzmdProcedure> read FProcedures write SetProcedures;
  published
    property Header: TStringList read FHeader write SetHeader;
    property Body: TStringList read FBody write SetBody;
  end;

  TzmdPicklist = class(TzMetadataSourceCodeItem)
  private
    FDescription: TStringList;
    procedure SetDescription(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Description: TStringList read FDescription write SetDescription;
  end;

  TzmdLookup = class(TzMetadataSourceCodeItem)
  private
    FDisplayColumns: String;
    FFieldNames: string;
    FFieldNamesFK: string;
    FMappings: TStringList;
    FSelectSQL: TStringList;
    FTableName: string;
    FTableNameFK: string;
    procedure SetMappings(const Value: TStringList);
    procedure SetSelectSQL(const Value: TStringList);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldNames: string read FFieldNames write FFieldNames;
    property TableName: string read FTableName write FTableName;
    property FieldNamesFK: string read FFieldNamesFK write FFieldNamesFK;
    property TableNameFK: string read FTableNameFK write FTableNameFK;
    property DisplayColumns: String read FDisplayColumns write FDisplayColumns;
    property Mappings: TStringList read FMappings write SetMappings;
    property SelectSQL: TStringList read FSelectSQL write SetSelectSQL;
  end;

  TzmdDataDictionaryItem = class(TzMetadataSourceCodeItem)
  private
    FAlignment: TAlignment;
    FCalculated: boolean;
    FCaption: string;
    FColSpan: integer;
    FDefaultValue: string;
    FEditorType: TMetaEditorType;
    FFieldDecimals: integer;
    FFieldDomain: string;
    FFieldOrigin: string;
    FFieldPosition: integer;
    FFieldSize: integer;
    FFieldType: TFieldType;
    FIdentity: boolean;
    FLookup: string;
    FOriginRelationField: string;
    FOriginRelationName: string;
    FOriginRelationType: string;
    FPackageName: string;
    FPicklist: string;
    FReadonly: boolean;
    FRelationField: string;
    FRelationName: string;
    FRelationType: string;
    FRequired: boolean;
    FHasSensitivity: boolean;
    FSensitivity: TAISensitivity;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property PackageName: string read FPackageName write FPackageName;
    property RelationType: string read FRelationType write FRelationType;
    property RelationName: string read FRelationName write FRelationName;
    property RelationField: string read FRelationField write FRelationField;
    property FieldOrigin: string read FFieldOrigin write FFieldOrigin;
    property OriginRelationType: string read FOriginRelationType write FOriginRelationType;
    property OriginRelationName: string read FOriginRelationName write FOriginRelationName;
    property OriginRelationField: string read FOriginRelationField write FOriginRelationField;
    property FieldPosition: integer read FFieldPosition write FFieldPosition;
    property FieldDomain: string read FFieldDomain write FFieldDomain;
    property FieldType: TFieldType read FFieldType write FFieldType;
    property FieldSize: integer read FFieldSize write FFieldSize;
    property FieldDecimals: integer read FFieldDecimals write FFieldDecimals;
    property Calculated: boolean read FCalculated write FCalculated;
    property Identity: boolean read FIdentity write FIdentity;
    property Readonly: boolean read FReadonly write FReadonly;
    property Required: boolean read FRequired write FRequired;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property Caption: string read FCaption write FCaption;
    property Alignment: TAlignment read FAlignment write FAlignment;
    property EditorType: TMetaEditorType read FEditorType write FEditorType;
    property ColSpan: integer read FColSpan write FColSpan;
    property Lookup: string read FLookup write FLookup;
    property Picklist: string read FPicklist write FPicklist;
    property HasSensitivity: boolean read FHasSensitivity write FHasSensitivity;
    property Sensitivity: TAISensitivity read FSensitivity write FSensitivity;
  end;

  TzMetadata = class(TComponent)
  private
    FDataDictionary: TzCollection<TzmdDataDictionaryItem>;
    FDomains: TzCollection<TzmdDomain>;
    FFunctions: TzCollection<TzmdFunction>;
    FGenerators: TzCollection<TzmdGenerator>;
    FLoaded: boolean;
    FLookups: TzCollection<TzmdLookup>;
    FPackages: TzCollection<TzmdPackage>;
    FPickLists: TzCollection<TzmdPicklist>;
    FProcedures: TzCollection<TzmdProcedure>;
    FTables: TzCollection<TzmdTable>;
    FTriggers: TzCollection<TzmdTrigger>;
    FViews: TzCollection<TzmdView>;
    procedure SetDataDictionary(const Value: TzCollection<TzmdDataDictionaryItem>);
    procedure SetDomains(const Value: TzCollection<TzmdDomain>);
    procedure SetFunctions(const Value: TzCollection<TzmdFunction>);
    procedure SetGenerators(const Value: TzCollection<TzmdGenerator>);
    procedure SetLookups(const Value: TzCollection<TzmdLookup>);
    procedure SetPackages(const Value: TzCollection<TzmdPackage>);
    procedure SetPickLists(const Value: TzCollection<TzmdPicklist>);
    procedure SetProcedures(const Value: TzCollection<TzmdProcedure>);
    procedure SetTables(const Value: TzCollection<TzmdTable>);
    procedure SetTriggers(const Value: TzCollection<TzmdTrigger>);
    procedure SetViews(const Value: TzCollection<TzmdView>);
  protected
    function GetFieldNames(Fields: TzCollection<TzmdFieldName>; CapFirst: boolean): string;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function IsEmpty: boolean;
  public
    function FieldOrParamExists(const TableName: string; const FieldName: string): boolean;
    function GetLookup(const RelationName, RelationField: string): string;
    function GetFK(const FkName: string): TzmdForeignKey;
    function GetIndex(const IndexName: string): TzmdTableIndex;
    function GetUniqueConstraint(const ConstraintName: string): TzmdUniqueConstraint;
    function GetCheckConstraint(const ConstraintName: string): TzmdCheckConstraint;
    function GetIdentity(const TableName: string): string;

    function ExtractFkParams(const FkName: string; out TableName, FkTableName, FieldNames: string): boolean;
    function ExtractUniqueParams(const ConstraintName: string; out TableName, FieldNames: string): boolean;
    function ExtractCheckConstraintParams(const ConstraintName: string; out TableName, CheckConstraint: string): boolean;
  public
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    // SaveToStream: formato deciso da zCollectionPersistence (zResolveWriteFormat).
    // LoadFromStream: riconosce da solo DFM e JSON.
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStreamAs(Stream: TStream; const aFormat: TzPersistenceFormat);
    procedure SaveToFile(const FileName: string);

    property Loaded: boolean read FLoaded write FLoaded;
  published
    property Domains: TzCollection<TzmdDomain> read FDomains write SetDomains;
    property Generators: TzCollection<TzmdGenerator> read FGenerators write SetGenerators;
    property Functions: TzCollection<TzmdFunction> read FFunctions write SetFunctions;
    property Procedures: TzCollection<TzmdProcedure> read FProcedures write SetProcedures;
    property Tables: TzCollection<TzmdTable> read FTables write SetTables;
    property Views: TzCollection<TzmdView> read FViews write SetViews;
    property Triggers: TzCollection<TzmdTrigger> read FTriggers write SetTriggers;
    property Packages: TzCollection<TzmdPackage> read FPackages write SetPackages;
    //
    property PickLists: TzCollection<TzmdPicklist> read FPickLists write SetPickLists;
    property Lookups: TzCollection<TzmdLookup> read FLookups write SetLookups;
    property DataDictionary: TzCollection<TzmdDataDictionaryItem> read FDataDictionary write SetDataDictionary;
  end;

function getConstraintType(const s: string): TContraintType;

function FullMetadataName(const Package: String; const ObjName: string): string;

const
  img_MetaDataDomains = 0;
  img_MetaDataTables = 1;
  img_MetaDataViews = 2;
  img_MetaDataFields = 3;
  img_MetaDataPrimaryKeys = 4;
  img_MetaDataForeignKeys = 5;
  img_MetaDataProcedures = 6;
  img_MetaDataParamsInput = 7;
  img_MetaDataParamsOutput = 8;
  img_MetaDataGenerators = 9;
  img_MetaDataFunctions = 10;
  img_MetaDataTriggers = 11;
  img_MetaDataCheckConstraints = 12;
  img_MetaDataUniqueConstraints = 13;
  img_MetaDataIndexes = 14;
  img_MetaDataDependencies = 15;
  img_MetaDataPackages = 16;

  img_MetaDataPickLists = 17;
  img_MetaDataLookups = 18;
  img_MetaDataDictionary = 19;

implementation

uses
  zCollection.Json;

function getConstraintType(const s: string): TContraintType;
begin
  result := ctNone;

  if SameText(s, 'PRIMARY KEY') then
    result := ctPrimaryKey
  else
    if SameText(s, 'FOREIGN KEY') then
      result := ctForeignKey
    else
      if SameText(s, 'UNIQUE') then
        result := ctUnique
      else
        if SameText(s, 'CHECK') then
          result := ctCheck;
end;

function IsBlobDataType(DataType: TFieldType): boolean;
begin
  result := DataType in [ftBytes, ftVarBytes, ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob, ftVariant, ftInterface, ftIDispatch, ftWideMemo,
    ftConnection, ftParams, ftStream, ftObject];
end;

constructor TzMetadataItem.Create(Collection: TCollection);
begin
  inherited;
  FDescription := TStringList.Create;
end;

destructor TzMetadataItem.Destroy;
begin
  FreeAndNil(FDescription);
  inherited;
end;

{ TzMetadataItem }

procedure TzMetadataItem.Assign(Source: TPersistent);
begin
  inherited; // name e isNew
  if Source is TzMetadataItem then
    Description.Text := TzMetadataItem(Source).Description.Text;
end;

procedure TzMetadataItem.SetDescription(const Value: TStringList);
begin
  FDescription := Value;
end;

constructor TzmdGenerator.Create(Collection: TCollection);
begin
  inherited;
end;

{ TzmdGenerator }

procedure TzmdGenerator.Assign(Source: TPersistent);
begin
  inherited;
end;

constructor TzmdDomain.Create(Collection: TCollection);
begin
  inherited;
  FSize := 0;
  FRequired := false;
  FDataType := ftString;
  FFbDataType := '';
  FCheckConstraint := '';
  FDefaultValue := '';
  FCharacterSetId := -1;
  FCharacterSetName := '';
  FCollationId := -1;
  FCollationName := '';
end;

{ TzmdDomain }

procedure TzmdDomain.Assign(Source: TPersistent);
var
  srcDomain: TzmdDomain;
begin
  if Source is TzmdDomain then
  begin
    srcDomain := TzmdDomain(Source);

    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := srcDomain.Name;
      Size := srcDomain.Size;
      DataType := srcDomain.DataType;
      FbDataType := srcDomain.FbDataType;
      Required := srcDomain.Required;
      CheckConstraint := srcDomain.CheckConstraint;
      CheckConstraint := srcDomain.CheckConstraint;
      DefaultValue := srcDomain.DefaultValue;
      Description.Text := srcDomain.Description.Text;
      CharacterSetId := srcDomain.CharacterSetId;
      CharacterSetName := srcDomain.CharacterSetName;
      CollationId := srcDomain.CollationId;
      CollationName := srcDomain.CollationName;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdDomain.SetCheckConstraint(const Value: string);
begin
  FCheckConstraint := Value;
end;

procedure TzmdDomain.SetDataType(const Value: TFieldType);
begin
  FDataType := Value;
end;

procedure TzmdDomain.SetDefaultValue(const Value: string);
begin
  FDefaultValue := Value;
end;

procedure TzmdDomain.SetSize(const Value: integer);
begin
  FSize := Value;
end;

constructor TzmdField.Create(Collection: TCollection);
begin
  inherited;
  FDomain := '';
  FNotNull := false;
  FSize := 0;
  FDataType := ftString;
  FbDataType := '';
  FDefaultValue := '';
  FDefaultFromDomain := '';
  FDefaultFromField := '';
  FCalculatedSource := '';
end;

function TzmdField.IsBlob: boolean;
begin
  result := IsBlobDataType(DataType);
end;

{ TzmdField }

procedure TzmdField.Assign(Source: TPersistent);
var
  src: TzmdField;
begin
  if Source is TzmdField then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzmdField(Source).Name;
      src := TzmdField(Source);
      Description.Text := src.Description.Text;
      Domain := src.Domain;
      NotNull := src.NotNull;
      Size := src.Size;
      DataType := src.DataType;
      FbDataType := src.FbDataType;
      DefaultValue := src.DefaultValue;
      DefaultFromField := src.DefaultFromField;
      DefaultFromDomain := src.DefaultFromDomain;
      CalculatedSource := src.CalculatedSource;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzmdField.Calculated: boolean;
begin
  result := CalculatedSource <> '';
end;

function TzmdField.HasDomain: boolean;
begin
  result := (Domain <> '') and not Domain.StartsWith('RDB$');
end;

constructor TzmdDependency.Create(Collection: TCollection);
begin
  inherited;
  FTableName := '';
end;

procedure TzmdDependency.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TzmdDependency then
    FTableName := TzmdDependency(Source).TableName
end;

constructor TzmdParam.Create(Collection: TCollection);
begin
  inherited;
  FSize := 0;
  FDataType := ftString;
  FFbDataType := '';
  FDomain := '';
  FDefaultValue := '';
  FMechanism := 0;
  FTypeOfColumn := '';
end;

function TzmdParam.DDL(const UseDomains: boolean = true): string;
begin

  if not UseDomains then
    result := FbDataType
  else
  begin

    if not TypeOfColumn.IsEmpty then
      result := 'TYPE OF COLUMN ' + TypeOfColumn
    else
      if (Mechanism = 1) and HasDomain then
        result := 'TYPE OF ' + Domain
      else
        if HasDomain then
          result := Domain
        else
          result := FbDataType;
  end;
end;

function TzmdParam.IsBlob: boolean;
begin
  result := IsBlobDataType(DataType);
end;

{ TzmdParam }

procedure TzmdParam.Assign(Source: TPersistent);
var
  src: TzmdParam;
begin
  if Source is TzmdParam then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      src := TzmdParam(Source);
      Name := src.Name;
      Description.Text := src.Description.Text;
      Size := src.Size;
      DataType := src.DataType;
      FbDataType := src.FbDataType;
      Domain := src.Domain;
      DefaultValue := src.DefaultValue;
      Mechanism := src.Mechanism;
      TypeOfColumn := src.TypeOfColumn;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TzmdParam.HasDomain: boolean;
begin
  result := (Domain <> '') and not Domain.StartsWith('RDB$');
end;

constructor TzmdTable.Create(Collection: TCollection);
begin
  inherited;
  FTableType := ttPersistent;
  FPrimaryKeyName := '';
  FIdentityField := '';

  FFields := TzCollection<TzmdTableField>.Create(TzmdTableField, 'Fields', img_MetaDataFields, Self);
  FFields.Sorted := false;

  FPrimaryKey := TzCollection<TzmdFieldName>.Create(TzmdFieldName, 'PrimaryKey', img_MetaDataPrimaryKeys, Self);
  FPrimaryKey.Sorted := false;
  FPrimaryKeyDependencies := TzCollection<TzmdDependency>.Create(TzmdDependency, 'PrimaryKeyDependencies', img_MetaDataDependencies, Self);
  FPrimaryKeyDependencies.Sorted := false;
  FForeignKeys := TzCollection<TzmdForeignKey>.Create(TzmdForeignKey, 'ForeignKeys', img_MetaDataForeignKeys, Self);
  FForeignKeys.Sorted := false;
  FIndexes := TzCollection<TzmdTableIndex>.Create(TzmdTableIndex, 'Indexes', img_MetaDataIndexes, Self);
  FIndexes.Sorted := false;
  FCheckConstraints := TzCollection<TzmdCheckConstraint>.Create(TzmdCheckConstraint, 'CheckConstraints', img_MetaDataCheckConstraints, Self);
  FCheckConstraints.Sorted := false;
  FUniqueConstraints := TzCollection<TzmdUniqueConstraint>.Create(TzmdUniqueConstraint, 'UniqueConstraints', img_MetaDataUniqueConstraints, Self);
  FUniqueConstraints.Sorted := false;
end;

destructor TzmdTable.Destroy;
begin
  FreeAndNil(FFields);
  FreeAndNil(FPrimaryKey);
  FreeAndNil(FPrimaryKeyDependencies);
  FreeAndNil(FForeignKeys);
  FreeAndNil(FIndexes);
  FreeAndNil(FCheckConstraints);
  FreeAndNil(FUniqueConstraints);
  inherited;
end;

{ TzmdTable }

procedure TzmdTable.Assign(Source: TPersistent);
var
  src: TzmdTable;
begin
  if Source is TzmdTable then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      src := TzmdTable(Source);
      FTableType := src.TableType;
      Fields.Assign(src.Fields);
      IdentityField := src.IdentityField;
      PrimaryKeyName := src.PrimaryKeyName;
      PrimaryKey.Assign(src.PrimaryKey);
      PrimaryKeyDependencies.Assign(src.PrimaryKeyDependencies);
      ForeignKeys.Assign(src.ForeignKeys);
      Indexes.Assign(src.Indexes);
      CheckConstraints.Assign(src.CheckConstraints);
      UniqueConstraints.Assign(src.UniqueConstraints);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdTable.SetCheckConstraints(const Value: TzCollection<TzmdCheckConstraint>);
begin
  FCheckConstraints.Assign(Value);
end;

procedure TzmdTable.SetFields(const Value: TzCollection<TzmdTableField>);
begin
  FFields.Assign(Value);
end;

procedure TzmdTable.SetForeignKeys(const Value: TzCollection<TzmdForeignKey>);
begin
  FForeignKeys.Assign(Value);
end;

procedure TzmdTable.SetIndexes(const Value: TzCollection<TzmdTableIndex>);
begin
  FIndexes.Assign(Value);
end;

procedure TzmdTable.SetPrimaryKey(const Value: TzCollection<TzmdFieldName>);
begin
  FPrimaryKey.Assign(Value);
end;

procedure TzmdTable.SetPrimaryKeyDependencies(const Value: TzCollection<TzmdDependency>);
begin
  FPrimaryKeyDependencies.Assign(Value);
end;

procedure TzmdTable.SetUniqueConstraints(const Value: TzCollection<TzmdUniqueConstraint>);
begin
  FUniqueConstraints.Assign(Value);
end;

constructor TzmdForeignKey.Create(Collection: TCollection);
begin
  inherited;
  FFkTable := '';
  FUpdateRule := '';
  FDeleteRule := '';
  FFkContraintType := ctNone;
  FFkContraintName := '';
  FFields := TzCollection<TzmdFieldName>.Create(TzmdFieldName, 'Fields', img_MetaDataFields, Self);
  FFields.Sorted := false;
  FFkFields := TzCollection<TzmdFieldName>.Create(TzmdFieldName, 'FkFields', img_MetaDataFields, Self);
  FFkFields.Sorted := false;
end;

destructor TzmdForeignKey.Destroy;
begin
  FreeAndNil(FFkFields);
  FreeAndNil(FFields);
  inherited;
end;

{ TzmdForeignKey }

procedure TzmdForeignKey.Assign(Source: TPersistent);
var
  src: TzmdForeignKey;
begin
  if Source is TzmdForeignKey then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      src := TzmdForeignKey(Source);
      Name := src.Name;
      UpdateRule := src.UpdateRule;
      DeleteRule := src.DeleteRule;

      Description.Text := src.Description.Text;
      FkTable := src.FkTable;
      FkContraintType := src.FkContraintType;
      FkContraintName := src.FkContraintName;
      Fields.Assign(src.Fields);
      FkFields.Assign(src.FkFields);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdForeignKey.SetFkFields(const Value: TzCollection<TzmdFieldName>);
begin
  FFkFields := Value;
end;

procedure TzmdForeignKey.SetFields(const Value: TzCollection<TzmdFieldName>);
begin
  FFields := Value;
end;

procedure TzmdForeignKey.SetFkTable(const Value: string);
begin
  FFkTable := Value;
end;

constructor TzmdCheckConstraint.Create(Collection: TCollection);
begin
  inherited;
  FCheckConstraint := TStringList.Create;
end;

destructor TzmdCheckConstraint.Destroy;
begin
  inherited;
  FreeAndNil(FCheckConstraint);
end;

{ TzmdCheckConstraint }

procedure TzmdCheckConstraint.Assign(Source: TPersistent);
begin
  if Source is TzmdCheckConstraint then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzmdCheckConstraint(Source).Name;
      Description.Text := TzmdCheckConstraint(Source).Description.Text;
      CheckConstraint.Text := TzmdCheckConstraint(Source).CheckConstraint.Text;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdCheckConstraint.SetCheckConstraint(const Value: TStringList);
begin
  FCheckConstraint.Assign(Value);
end;

constructor TzmdUniqueConstraint.Create(Collection: TCollection);
begin
  inherited;
  FUniqueFieldNames := TzCollection<TzmdFieldName>.Create(TzmdFieldName, 'UniqueFieldNames', -1, Self);
  FUniqueFieldNames.Sorted := false;
  FDependencies := TzCollection<TzmdDependency>.Create(TzmdDependency, 'UniqueDependencies', img_MetaDataDependencies, Self);
  FDependencies.Sorted := false;
end;

destructor TzmdUniqueConstraint.Destroy;
begin
  inherited;
  FreeAndNil(FUniqueFieldNames);
  FreeAndNil(FDependencies);
end;

{ TzmdUniqueConstraint }

procedure TzmdUniqueConstraint.Assign(Source: TPersistent);
begin
  if Source is TzmdUniqueConstraint then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Name := TzmdUniqueConstraint(Source).Name;
      Description.Text := TzmdUniqueConstraint(Source).Description.Text;
      IndexName := TzmdUniqueConstraint(Source).IndexName;
      UniqueFieldNames.Assign(TzmdUniqueConstraint(Source).UniqueFieldNames);
      Dependencies.Assign(TzmdUniqueConstraint(Source).Dependencies);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdUniqueConstraint.SetDependencies(const Value: TzCollection<TzmdDependency>);
begin
  FDependencies.Assign(Value);
end;

procedure TzmdUniqueConstraint.SetUniqueFieldNames(const Value: TzCollection<TzmdFieldName>);
begin
  FUniqueFieldNames.Assign(Value);
end;

constructor TzmdView.Create(Collection: TCollection);
begin
  inherited;
  FHasTriggerDelete := false;
  FHasTriggerInsert := false;
  FHasTriggerUpdate := false;
  FFields := TzCollection<TzmdViewField>.Create(TzmdViewField, 'Fields', img_MetaDataFields, Self);
  FFields.Sorted := false;
  FCreationOrder := -1;
end;

destructor TzmdView.Destroy;
begin
  FreeAndNil(FFields);
  inherited;
end;

procedure TzmdView.GetFieldSrc(const FieldName: string; out SrcRelation, SrcFieldName: string);
var
  Field: TzmdViewField;
begin
  Field := Fields.Get(FieldName, false);

  if Assigned(Field) then
  begin
    SrcRelation := Field.SrcRelation;
    SrcFieldName := Field.SrcFieldName;
  end;

end;

function TzmdView.GetSrcRelation(const FieldName: string): string;
var
  SrcRelation, SrcFieldName: string;
begin
  GetFieldSrc(FieldName, SrcRelation, SrcFieldName);
  result := SrcRelation;
end;

function TzmdView.GetSrcFieldName(const FieldName: string): string;
var
  SrcRelation, SrcFieldName: string;
begin
  GetFieldSrc(FieldName, SrcRelation, SrcFieldName);
  result := SrcFieldName;
end;

function TzmdView.CanModify: boolean;
begin
  result := HasTriggerInsert or HasTriggerUpdate or HasTriggerDelete;
end;

{ TzmdView }

procedure TzmdView.Assign(Source: TPersistent);
var
  Item: TzmdView;
begin
  if Source is TzmdView then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := Source as TzmdView;
      Fields.Assign(Item.Fields);
      FHasTriggerDelete := Item.HasTriggerDelete;
      FHasTriggerInsert := Item.HasTriggerInsert;
      FHasTriggerUpdate := Item.HasTriggerUpdate;
      FSource.Assign(Item.Source);
      FCreationOrder := Item.CreationOrder;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdView.SetFields(const Value: TzCollection<TzmdViewField>);
begin
  FFields := Value;
end;

constructor TzmdProcedure.Create(Collection: TCollection);
begin
  inherited;
  FPackage := '';
  FProcedureType := ptLegacy;
  FParamsInput := TzCollection<TzmdParam>.Create(TzmdParam, 'ParamsInput', img_MetaDataParamsInput, Self);
  FParamsInput.Sorted := false;
  FParamsOutput := TzCollection<TzmdParam>.Create(TzmdParam, 'ParamsOutput', img_MetaDataParamsOutput, Self);
  FParamsOutput.Sorted := false;
end;

destructor TzmdProcedure.Destroy;
begin
  FreeAndNil(FParamsInput);
  FreeAndNil(FParamsOutput);
  inherited;
end;

function TzmdProcedure.HasInputParams: boolean;
begin
  result := ParamsInput.Count > 0;
end;

function TzmdProcedure.HasOutputParams: boolean;
begin
  result := ParamsOutput.Count > 0;
end;

function TzmdProcedure.HasTypeOfColumnParams: boolean;
var
  param: TzmdParam;
begin
  result := false;

  for param in ParamsInput do
    if not param.TypeOfColumn.IsEmpty then
      Exit(true);

  for param in ParamsOutput do
    if not param.TypeOfColumn.IsEmpty then
      Exit(true);
end;

{ TzmdProcedure }

procedure TzmdProcedure.Assign(Source: TPersistent);
var
  Item: TzmdProcedure;
begin
  if Source is TzmdProcedure then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdProcedure(Source);
      FPackage := Item.Package;
      ParamsInput.Assign(Item.ParamsInput);
      ParamsOutput.Assign(Item.ParamsOutput);
      ProcedureType := Item.ProcedureType;
      FSource.Assign(Item.Source);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdProcedure.SetParamsInput(const Value: TzCollection<TzmdParam>);
begin
  FParamsInput := Value;
end;

procedure TzmdProcedure.SetParamsOutput(const Value: TzCollection<TzmdParam>);
begin
  FParamsOutput := Value;
end;

procedure TzmdProcedure.SetProcedureType(const Value: TProcedureType);
begin
  FProcedureType := Value;
end;

constructor TzMetadata.Create(aOwner: TComponent);
begin
  inherited;
  FLoaded := false;
  FDomains := TzCollection<TzmdDomain>.Create(TzmdDomain, 'Domains', img_MetaDataDomains, nil, false);
  FTables := TzCollection<TzmdTable>.Create(TzmdTable, 'Tables', img_MetaDataTables, nil, false);
  FViews := TzCollection<TzmdView>.Create(TzmdView, 'Views', img_MetaDataViews, nil, false);
  FProcedures := TzCollection<TzmdProcedure>.Create(TzmdProcedure, 'Procedures', img_MetaDataProcedures, nil, false);
  FGenerators := TzCollection<TzmdGenerator>.Create(TzmdGenerator, 'Generators', img_MetaDataGenerators, nil, false);
  FFunctions := TzCollection<TzmdFunction>.Create(TzmdFunction, 'Functions', img_MetaDataFunctions, nil, false);
  FTriggers := TzCollection<TzmdTrigger>.Create(TzmdTrigger, 'Triggers', img_MetaDataTriggers, nil, false);
  FPackages := TzCollection<TzmdPackage>.Create(TzmdPackage, 'Packages', img_MetaDataPackages, nil, false);
  FPickLists := TzCollection<TzmdPicklist>.Create(TzmdPicklist, 'PickLists', img_MetaDataPickLists, nil, false);
  FLookups := TzCollection<TzmdLookup>.Create(TzmdLookup, 'Lookups', img_MetaDataLookups, nil, false);
  FDataDictionary := TzCollection<TzmdDataDictionaryItem>.Create(TzmdDataDictionaryItem, 'DataDictionary', img_MetaDataDictionary, nil, false);
end;

destructor TzMetadata.Destroy;
begin
  FreeAndNil(FDomains);
  FreeAndNil(FProcedures);
  FreeAndNil(FTables);
  FreeAndNil(FViews);
  FreeAndNil(FGenerators);
  FreeAndNil(FFunctions);
  FreeAndNil(FTriggers);
  FreeAndNil(FPackages);
  FreeAndNil(FPickLists);
  FreeAndNil(FLookups);
  FreeAndNil(FDataDictionary);
  inherited;
end;

function TzMetadata.ExtractFkParams(const FkName: string; out TableName, FkTableName, FieldNames: string): boolean;
var
  Field: TzmdFieldName;
  FK: TzmdForeignKey;
begin
  result := false;

  FK := GetFK(FkName);

  result := Assigned(FK);

  TableName := zzCapFirst(FK.Table.Name.Replace('ZZ_', ''), true);
  FkTableName := zzCapFirst(FK.FkTable.Replace('ZZ_', ''), true);
  FieldNames := GetFieldNames(FK.Fields, true);
end;

function TzMetadata.ExtractUniqueParams(const ConstraintName: string; out TableName, FieldNames: string): boolean;
var
  Field: TzmdFieldName;
  index: TzmdTableIndex;
  Table: TzmdTable;
  Unique: TzmdUniqueConstraint;
begin
  result := false;

  /// ////
  for Table in Tables do
    if SameText(Table.PrimaryKeyName, ConstraintName) then
    begin
      TableName := zzCapFirst(Table.Name.Replace('ZZ_', ''), true);
      FieldNames := GetFieldNames(Table.PrimaryKey, true);
      result := true;
      Exit;
    end;

  /// ////
  Unique := GetUniqueConstraint(ConstraintName);
  if Assigned(Unique) then
  begin
    TableName := zzCapFirst(Unique.Table.Name.Replace('ZZ_', ''), true);
    FieldNames := GetFieldNames(Unique.UniqueFieldNames, true);
    result := true;
    Exit;
  end;

  /// ////
  index := GetIndex(ConstraintName);
  if Assigned(index) then
  begin
    TableName := zzCapFirst(Index.Table.Name.Replace('ZZ_', ''), true);
    FieldNames := GetFieldNames(Index.IndexFieldNames, true);
    result := true;
    Exit;
  end
end;

function TzMetadata.ExtractCheckConstraintParams(const ConstraintName: string; out TableName, CheckConstraint: string): boolean;
var
  Constraint: TzmdCheckConstraint;
begin
  result := false;

  Constraint := GetCheckConstraint(ConstraintName);

  result := Assigned(Constraint);

  if result then
  begin
    TableName := zzCapFirst(Constraint.Table.Name.Replace('ZZ_', ''), true);
    CheckConstraint := Constraint.CheckConstraint.Text.Trim;

    if CheckConstraint.StartsWith('CHECK') then
      CheckConstraint := CheckConstraint.Replace('CHECK ', '').Trim;

    if CheckConstraint.StartsWith('(') then
      CheckConstraint := CheckConstraint.Replace('(', '').Trim;

    if CheckConstraint.EndsWith(')') then
      CheckConstraint := CheckConstraint.Substring(0, CheckConstraint.Length - 1);
  end;
end;

function TzMetadata.FieldOrParamExists(const TableName, FieldName: string): boolean;
var
  Table: TzmdTable;
  View: TzmdView;
  Proc: TzmdProcedure;
begin
  result := false;

  Table := Tables.Get(TableName, false);
  if Assigned(Table) then
  begin
    result := Table.Fields.Exists(FieldName);
    Exit;
  end;

  View := Views.Get(TableName, false);
  if Assigned(View) then
  begin
    result := View.Fields.Exists(FieldName);
    Exit;
  end;

  Proc := Procedures.Get(TableName, false);
  if Assigned(Proc) then
  begin
    result := Proc.ParamsInput.Exists(FieldName);

    if not result then
      result := Proc.ParamsOutput.Exists(FieldName);

    Exit;
  end;
end;

{ TzMetadata }

procedure TzMetadata.Clear;
begin
  FLoaded := false;
  Domains.Clear;
  Tables.Clear;
  Views.Clear;
  Procedures.Clear;
  Generators.Clear;
  Functions.Clear;
  Triggers.Clear;
  Packages.Clear;
  PickLists.Clear;
  Lookups.Clear;
  DataDictionary.Clear;
end;

function TzMetadata.GetCheckConstraint(const ConstraintName: string): TzmdCheckConstraint;
var
  Table: TzmdTable;
begin
  result := nil;

  for Table in Tables do
    for result in Table.CheckConstraints do
      if SameText(result.Name, ConstraintName) then
        Exit;

  result := Nil;
end;

function TzMetadata.GetFieldNames(Fields: TzCollection<TzmdFieldName>; CapFirst: boolean): string;
var
  Field: TzmdFieldName;
begin
  result := '';

  for Field in Fields do
  begin
    if not result.IsEmpty then
      result := result + ', ';

    if CapFirst then
      result := result + zzCapFirst(Field.Name, true)
    else
      result := result + Field.Name;
  end;
end;

function TzMetadata.GetFK(const FkName: string): TzmdForeignKey;
var
  Table: TzmdTable;
begin
  result := nil;

  for Table in Tables do
    for result in Table.ForeignKeys do
      if SameText(result.Name, FkName) then
        Exit;

  result := Nil;
end;

function TzMetadata.GetIdentity(const TableName: string): string;
var
  tbl: TzmdTable;
begin
  result := '';

  tbl := Tables.Get(TableName, false);

  if Assigned(tbl) then
    result := tbl.IdentityField;
end;

function TzMetadata.GetIndex(const IndexName: string): TzmdTableIndex;
var
  Table: TzmdTable;
begin
  result := nil;

  for Table in Tables do
    for result in Table.Indexes do
      if SameText(result.Name, IndexName) then
        Exit;

  result := Nil;
end;

function TzMetadata.GetLookup(const RelationName, RelationField: string): string;
var
  idx: integer;
  TableName, FieldName: string;
  iFk: integer;
begin
  result := '';

  if Views.Exists(RelationName) then
  begin
    idx := Views.IndexOf(RelationName);
    Views[idx].GetFieldSrc(RelationField, TableName, FieldName);
  end
  else
  begin
    TableName := RelationName;
    FieldName := RelationField;
  end;

  /// /////////////////////////

  idx := Tables.IndexOf(TableName);
  if idx <> -1 then
    for iFk := 0 to Tables[idx].ForeignKeys.Count - 1 do
      if Tables[idx].ForeignKeys[iFk].Fields.IndexOf(FieldName) <> -1 then
      begin
        result := Tables[idx].ForeignKeys[iFk].Name;
        break;
      end;
end;

function TzMetadata.GetUniqueConstraint(const ConstraintName: string): TzmdUniqueConstraint;
var
  Table: TzmdTable;
begin
  result := nil;

  for Table in Tables do
    for result in Table.UniqueConstraints do
      if SameText(result.Name, ConstraintName) then
        Exit;

  result := Nil;
end;

function TzMetadata.IsEmpty: boolean;
begin
  result := false;

  if Domains.IsEmpty then
    if Tables.IsEmpty then
      if Views.IsEmpty then
        if Procedures.IsEmpty then
          if Generators.IsEmpty then
            if Functions.IsEmpty then
              if Triggers.IsEmpty then
                if Packages.IsEmpty then
                  if PickLists.IsEmpty then
                    if Lookups.IsEmpty then
                      if DataDictionary.IsEmpty then
                        result := true;
end;

procedure TzMetadata.LoadFromStream(Stream: TStream);
var
  MemStream: TMemoryStream;
  Options: TJsonSerializerOptions;
begin
  if not Assigned(Stream) then
    Exit;

  if Stream.Size = 0 then
    Exit;

  if TzCollectionJson.DetectFormat(Stream) = pfJSON then
  begin
    Options := TJsonSerializerOptions.Default;
    Options.StrictMode := zCollectionPersistence.StrictJSON;
    TzCollectionJson.LoadComponentFromStream(Self, Stream, Options);
  end
  else
  begin
    MemStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(Stream, MemStream);
      MemStream.Seek(0, soFromBeginning);
      MemStream.ReadComponent(Self);
    finally
      MemStream.Free;
    end;
  end;

  FLoaded := true;
end;

procedure TzMetadata.SaveToStream(Stream: TStream);
begin
  SaveToStreamAs(Stream, zResolveWriteFormat);
end;

procedure TzMetadata.SaveToStreamAs(Stream: TStream; const aFormat: TzPersistenceFormat);
var
  MemStream: TMemoryStream;
begin
  if not Assigned(Stream) then
    Exit;

  if aFormat = pfJSON then
  begin
    TzCollectionJson.SaveComponentToStream(Self, Stream);
    Exit;
  end;

  MemStream := TMemoryStream.Create;
  try
    MemStream.WriteComponent(Self);
    MemStream.Seek(0, soFromBeginning);
    ObjectBinaryToText(MemStream, Stream);
  finally
    MemStream.Free;
  end;
end;

procedure TzMetadata.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TzMetadata.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TzMetadata.SetDataDictionary(const Value: TzCollection<TzmdDataDictionaryItem>);
begin
  FDataDictionary.Assign(Value);
end;

procedure TzMetadata.SetDomains(const Value: TzCollection<TzmdDomain>);
begin
  FDomains := Value;
end;

procedure TzMetadata.SetFunctions(const Value: TzCollection<TzmdFunction>);
begin
  FFunctions.Assign(Value);
end;

procedure TzMetadata.SetGenerators(const Value: TzCollection<TzmdGenerator>);
begin
  FGenerators := Value;
end;

procedure TzMetadata.SetLookups(const Value: TzCollection<TzmdLookup>);
begin
  FLookups.Assign(Value);
end;

procedure TzMetadata.SetPackages(const Value: TzCollection<TzmdPackage>);
begin
  FPackages.Assign(Value);
end;

procedure TzMetadata.SetPickLists(const Value: TzCollection<TzmdPicklist>);
begin
  FPickLists.Assign(Value);
end;

procedure TzMetadata.SetProcedures(const Value: TzCollection<TzmdProcedure>);
begin
  FProcedures := Value;
end;

procedure TzMetadata.SetTables(const Value: TzCollection<TzmdTable>);
begin
  FTables := Value;
end;

procedure TzMetadata.SetTriggers(const Value: TzCollection<TzmdTrigger>);
begin
  FTriggers.Assign(Value);
end;

procedure TzMetadata.SetViews(const Value: TzCollection<TzmdView>);
begin
  FViews := Value;
end;

{ TzmdViewField }

constructor TzmdViewField.Create(Collection: TCollection);
begin
  inherited;
  FSrcRelation := '';
  FSrcFieldName := '';
end;

procedure TzmdViewField.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TzmdViewField then
  begin
    FSrcRelation := TzmdViewField(Source).SrcRelation;
    FSrcFieldName := TzmdViewField(Source).SrcFieldName;
  end;
end;

constructor TzmdFunction.Create(Collection: TCollection);
begin
  inherited;
  FPackage := '';
  FParams := TzCollection<TzmdParam>.Create(TzmdParam, 'Params', img_MetaDataParamsInput, Self);
  FParams.Sorted := false;
  FReturnParam := TzmdParam.Create(nil);
  FRequiredByTable := false;
end;

destructor TzmdFunction.Destroy;
begin
  inherited;
  FreeAndNil(FParams);
  FreeAndNil(FReturnParam);
end;

procedure TzmdFunction.Assign(Source: TPersistent);
var
  Item: TzmdFunction;
begin
  if Source is TzmdFunction then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdFunction(Source);
      Name := Item.Name;
      Package := Item.Package;
      Params.Assign(Item.Params);
      ReturnParam.Assign(Item.ReturnParam);

      Description.Assign(Item.Description);
      FSource.Assign(Item.Source);
      FRequiredByTable := Item.RequiredByTable;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdFunction.SetParams(const Value: TzCollection<TzmdParam>);
begin
  FParams.Assign(Value);
end;

procedure TzmdFunction.SetReturnParam(const Value: TzmdParam);
begin
  FReturnParam.Assign(Value);
end;

constructor TzmdTrigger.Create(Collection: TCollection);
begin
  inherited;
  FTableName := '';
  FPosition := 0;
  FActive := true;
  TriggerType := -1;
  FBeforeDelete := false;
  FBeforeInsert := false;
  FBeforeUpdate := false;
  FAfterDelete := false;
  FAfterInsert := false;
  FAfterUpdate := false;
  FIsDbTrigger := false;
  FOnConnect := false;
  FOnDisconnect := false;
  FOnTransactionStart := false;
  FOnTransactionCommit := false;
  FOnTransactionRollback := false;
  FBeforeAnyStatement := false;
  FAfterAnyStatement := false;
end;

procedure TzmdTrigger.Assign(Source: TPersistent);
var
  Item: TzmdTrigger;
begin
  if Source is TzmdTrigger then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdTrigger(Source);
      Name := Item.Name;
      TableName := Item.TableName;
      Position := Item.Position;
      Active := Item.Active;
      TriggerType := Item.TriggerType;
      Description.Assign(Item.Description);
      FSource.Assign(Item.Source);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdTrigger.SetTriggerType(const Value: Largeint);
begin
  FTriggerType := Value;

  FBeforeInsert := TriggerType in [1, 17, 25, 113];
  FAfterInsert := TriggerType in [2, 18, 26, 114];

  FBeforeUpdate := TriggerType in [3, 17, 27, 113];
  FAfterUpdate := TriggerType in [4, 18, 28, 114];

  FBeforeDelete := TriggerType in [5, 25, 27, 113];
  FAfterDelete := TriggerType in [6, 26, 28, 114];

  FOnConnect := TriggerType = 8192;
  FOnDisconnect := TriggerType = 8193;
  FOnTransactionStart := TriggerType = 8194;
  FOnTransactionCommit := TriggerType = 8195;
  FOnTransactionRollback := TriggerType = 8196;
  FBeforeAnyStatement := TriggerType = 9223372036854767614;
  FAfterAnyStatement := TriggerType = 9223372036854767615;

  FIsDbTrigger := OnConnect or OnDisconnect or OnTransactionStart or OnTransactionCommit or OnTransactionRollback or BeforeAnyStatement or AfterAnyStatement;
end;

function TzmdTrigger.TriggerKind: TTriggerKind;
begin
  result := tkUnknown;

  if BeforeInsert or BeforeUpdate or BeforeDelete then
    result := tkBefore
  else
    if AfterInsert or AfterUpdate or AfterDelete then
      result := tkAfter;
end;

constructor TzMetadataSourceCodeItem.Create(Collection: TCollection);
begin
  inherited;
  FSource := TStringList.Create;
end;

destructor TzMetadataSourceCodeItem.Destroy;
begin
  inherited;
  FreeAndNil(FSource);
end;

procedure TzMetadataSourceCodeItem.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TzMetadataSourceCodeItem then
    FSource.Text := TzMetadataSourceCodeItem(Source).Source.Text;
end;

procedure TzMetadataSourceCodeItem.SetSource(const Value: TStringList);
begin
  FSource.Assign(Value);
end;

constructor TzmdTableIndex.Create(Collection: TCollection);
begin
  inherited;
  FTableName := '';
  FUnique := false;
  FInactive := false;
  FDescending := false;
  FIndexExpression := '';
  FIndexFieldNames := TzCollection<TzmdFieldName>.Create(TzmdFieldName, 'Index Fields', -1, Self);
  FIndexFieldNames.Sorted := false;
end;

destructor TzmdTableIndex.Destroy;
begin
  inherited;
  FreeAndNil(FIndexFieldNames);
end;

procedure TzmdTableIndex.Assign(Source: TPersistent);
var
  idx: TzmdTableIndex;
begin
  if Source is TzmdTableIndex then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      idx := TzmdTableIndex(Source);
      Name := idx.Name;
      Description.Text := idx.Description.Text;

      TableName := idx.TableName;
      Unique := idx.Unique;
      Inactive := idx.Inactive;
      Descending := idx.Descending;
      IndexExpression := idx.IndexExpression;
      IndexFieldNames.Assign(idx.IndexFieldNames);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdTableIndex.SetIndexFieldNames(const Value: TzCollection<TzmdFieldName>);
begin
  FIndexFieldNames.Assign(Value);
end;

constructor TzmdTableField.Create(Collection: TCollection);
begin
  inherited;
  FIdentity := false;
end;

procedure TzmdTableField.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TzmdTableField then
    FIdentity := TzmdTableField(Source).Identity;
end;

function TzmdTableField.Table: TzmdTable;
begin
  result := nil;

  if Collection is TzCustomCollection then
    if TzCustomCollection(Collection).HasMaster then
      if TzCustomCollection(Collection).Master is TzmdTable then
        result := TzmdTable(TzCustomCollection(Collection).Master);
end;

function TzmdTableConstraint.Table: TzmdTable;
begin
  result := nil;

  if Collection is TzCustomCollection then
    if TzCustomCollection(Collection).HasMaster then
      if TzCustomCollection(Collection).Master is TzmdTable then
        result := TzmdTable(TzCustomCollection(Collection).Master);
end;

function FullMetadataName(const Package: String; const ObjName: string): string;
begin

  if Package.IsEmpty then
    result := ObjName
  else
    result := Package + '.' + ObjName;
end;

constructor TzmdPackage.Create(Collection: TCollection);
begin
  inherited;
  FProcedures := TzCollection<TzmdProcedure>.Create(TzmdProcedure, 'Procedures', img_MetaDataProcedures, nil, false);
  FFunctions := TzCollection<TzmdFunction>.Create(TzmdFunction, 'Functions', img_MetaDataFunctions, nil, false);
  FHeader := TStringList.Create;
  FBody := TStringList.Create;
end;

procedure TzmdPackage.Assign(Source: TPersistent);
var
  Item: TzmdPackage;
begin
  if Source is TzmdPackage then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdPackage(Source);
      Name := Item.Name;
      Procedures.Assign(Item.Procedures);
      Functions.Assign(Item.Functions);
      Header.Assign(Item.Header);
      Body.Assign(Item.Body);
      Description.Assign(Item.Description);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdPackage.SetBody(const Value: TStringList);
begin
  FBody.Assign(Value);
end;

procedure TzmdPackage.SetFunctions(const Value: TzCollection<TzmdFunction>);
begin
  FFunctions.Assign(Value);
end;

procedure TzmdPackage.SetHeader(const Value: TStringList);
begin
  FHeader.Assign(Value);
end;

procedure TzmdPackage.SetProcedures(const Value: TzCollection<TzmdProcedure>);
begin
  FProcedures.Assign(Value);
end;

constructor TzmdPicklist.Create(Collection: TCollection);
begin
  inherited;
  FDescription := TStringList.Create;
end;

destructor TzmdPicklist.Destroy;
begin
  inherited;
  FreeAndNil(FDescription);
end;

procedure TzmdPicklist.Assign(Source: TPersistent);
var
  Item: TzmdPicklist;
begin
  if Source is TzmdPicklist then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdPicklist(Source);
      Name := Item.Name;
      Description.Assign(Item.Description);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdPicklist.SetDescription(const Value: TStringList);
begin
  FDescription.Assign(Value);
end;

constructor TzmdLookup.Create(Collection: TCollection);
begin
  inherited;
  FFieldNames := '';
  FTableName := '';
  FFieldNamesFK := '';
  FTableNameFK := '';
  FDisplayColumns := '';
  FMappings := TStringList.Create;
  FSelectSQL := TStringList.Create;
end;

destructor TzmdLookup.Destroy;
begin
  inherited;
  FreeAndNil(FMappings);
  FreeAndNil(FSelectSQL);
end;

procedure TzmdLookup.Assign(Source: TPersistent);
var
  Item: TzmdLookup;
begin
  if Source is TzmdLookup then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdLookup(Source);
      Name := Item.Name;
      FFieldNames := Item.FieldNames;
      FTableName := Item.TableName;
      FFieldNamesFK := Item.FFieldNamesFK;
      FTableNameFK := Item.TableNameFK;
      DisplayColumns := Item.DisplayColumns;
      Mappings.Assign(Item.Mappings);
      SelectSQL.Assign(Item.SelectSQL);
      Description.Assign(Item.Description);
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TzmdLookup.SetMappings(const Value: TStringList);
begin
  FMappings.Assign(Value);
end;

procedure TzmdLookup.SetSelectSQL(const Value: TStringList);
begin
  FSelectSQL := Value;
end;

{ TzmdDataDictionaryItem }

constructor TzmdDataDictionaryItem.Create(Collection: TCollection);
begin
  inherited;
  FPackageName := '';
  FRelationType := '';
  FRelationName := '';
  FRelationField := '';
  FFieldOrigin := '';
  FOriginRelationType := '';
  FOriginRelationName := '';
  FOriginRelationField := '';
  FFieldPosition := 0;
  FFieldDomain := '';
  FFieldType := ftUnknown;
  FFieldSize := 0;
  FFieldDecimals := 0;
  FCalculated := false;
  FIdentity := false;
  FReadonly := false;
  FRequired := false;
  FDefaultValue := '';
  FCaption := '';
  FAlignment := taLeftJustify;
  FEditorType := metText;
  FColSpan := 0;
  FLookup := '';
  FPicklist := '';
  FHasSensitivity := false;
  FSensitivity := slNone;
end;

procedure TzmdDataDictionaryItem.Assign(Source: TPersistent);
var
  Item: TzmdDataDictionaryItem;
begin
  if Source is TzmdDataDictionaryItem then
  begin
    if Assigned(Collection) then
      Collection.BeginUpdate;
    try
      Item := TzmdDataDictionaryItem(Source);
      Name := Item.Name;
      FPackageName := Item.PackageName;
      FRelationType := Item.RelationType;
      FRelationName := Item.RelationName;
      FRelationField := Item.RelationField;
      FFieldOrigin := Item.FieldOrigin;
      FOriginRelationType := Item.OriginRelationType;
      FOriginRelationName := Item.OriginRelationName;
      FOriginRelationField := Item.OriginRelationField;
      FFieldPosition := Item.FieldPosition;
      FFieldDomain := Item.FieldDomain;
      FFieldType := Item.FieldType;
      FFieldSize := Item.FieldSize;
      FFieldDecimals := Item.FieldDecimals;
      FCalculated := Item.Calculated;
      FIdentity := Item.Identity;
      FReadonly := Item.Readonly;
      FRequired := Item.Required;
      FDefaultValue := Item.DefaultValue;
      FCaption := Item.Caption;
      FAlignment := Item.Alignment;
      FEditorType := Item.EditorType;
      FColSpan := Item.ColSpan;
      FLookup := Item.Lookup;
      FPicklist := Item.Picklist;
      FHasSensitivity := Item.HasSensitivity;
      FSensitivity := Item.Sensitivity;
    finally
      if Assigned(Collection) then
        Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

end.

  zsystemfrm

  zMetadata.Types
