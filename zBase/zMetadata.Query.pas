unit zMetadata.Query;

interface

{ (* }

type
  TMetadataQuery = record
  public const
    Domains = 'SELECT * FROM META.DOMAINS';
    Sequences = 'SELECT * FROM META.SEQUENCES';
    Functions = 'SELECT * FROM META.FUNCTIONS(:LOAD_SOURCE)';
    FunctionParams = 'SELECT * FROM META.FUNCTION_PARAMS';

    Tables = 'SELECT * FROM META.TABLES';
    TableFields = 'SELECT * FROM META.TABLE_FIELDS';
    TablePrimaryKeys = 'SELECT * FROM META.TABLE_PRIMARY_KEYS';
    TableForeignKeys = 'SELECT * FROM META.TABLE_FOREIGN_KEYS';
    TableUniques = 'SELECT * FROM META.TABLE_UNIQUES';
    TableChecks = 'SELECT * FROM META.TABLE_CHECKS';
    TableIndexes = 'SELECT * FROM META.TABLE_INDEXES';
    TableDependencies = 'SELECT * FROM META.TABLE_DEPENDENCIES';

    Triggers = 'SELECT * FROM META.TRIGGERS(NULL, :LOAD_SOURCE)';

    Procedures = 'SELECT * FROM META.PROCEDURES(:LOAD_SOURCE)';
    ProcedureParams = 'SELECT * FROM META.PROCEDURE_PARAMS';

    Views = 'SELECT * FROM META.VIEWS(:LOAD_SOURCE)';
    ViewFields = 'SELECT * FROM META.VIEW_FIELDS';

    Packages = 'SELECT * FROM META.PACKAGES';

    PickLists = 'SELECT * FROM BASE.PICKLISTS';
    Lookups = 'SELECT * FROM BASE.LOOKUPS';
    DataDictionary = 'SELECT * FROM BASE.DATA_DICTIONARY';
  end;

implementation

end.
