unit zSystemVerifier;

{
  TzSystemVerifier
  ----------------
  Logica di verifica metadati CONDIVISA tra la form zSystemFrm e il tool
  console LZ_Check. È l'UNICO posto in cui vivono i controlli: i due
  consumatori differiscono solo per come reagiscono ai risultati (OnEmit),
  come mostrano il progress (OnProgress) e per il flag StopOnFirstError.

  REGOLA FONDAMENTALE: le query non vengono MAI eseguite (sono migliaia).
  Solo FDQuery.Prepare. Nessun Open.

  Nessuna dipendenza dalla UI: la classe emette TzVerifyResult; il chiamante
  decide cosa farne (selezionare il nodo, mostrare InputMemo, scrivere a log).

  ATTENZIONE ai due assi diversi sui domini, che vanno tenuti distinti:

  - CheckDomainExists  -> il dominio punta a un campo che nel DATABASE non
  esiste piu' (Exists = False). E' un difetto reale:
  InitDataDictionary marca Exists ma non elimina nulla,
  quindi l'LZ accumula domini morti a ogni giro.

  - CheckDomainCoverage -> la TABELLA esiste ma nessun DataSet la usa. NON e'
  un difetto: zDataDictionary e' il catalogo completo
  dello schema (tabelle + viste + output delle stored
  procedure), i dataset ne sono un sottoinsieme. Solo
  INFO, un risultato per relazione.

  Confondere i due assi produce decine di migliaia di falsi positivi: e'
  esattamente quello che faceva il vecchio controllo CheckDomainDataSet, che
  segnalava un warning per OGNI CAMPO di ogni relazione non coperta.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  zCollection,
  zSystem;

type
  TzVerifySeverity = (vsInfo, vsWarning, vsError);

  // Categoria del controllo: utile per filtrare/raggruppare l'output
  TzVerifyCategory = (vcSqlSelect, vcSqlOther, vcEmptySelect, vcStoredProc, vcLookupDataSet, vcLookupSelect, vcLookupFieldsFK, vcLookupDomain, vcLookupDbView, vcLookupKeyField, vcLookupMappings,
    // controlli aggiuntivi
    vcRefIntegrity, // riferimenti pendenti tra oggetti LZ
    vcDomainCoverage, // tabella priva di qualunque DataSet che la usi (info)
    vcDomainExists, // dominio non piu' presente nel DB (Exists = False)
    vcAutoSql, // AutoSQL False con script vuoto, o AutoSQL_Update su vista senza trigger modificabile
    vcLookupCardinality, // FieldNames vs FieldNamesFK sbilanciati / MasterFields
    vcDuplicate, // nomi duplicati nelle collection
    vcGenerator, // generatore non risolvibile
    vcLookupFieldExist, // campo lookup non presente nei FieldDefs del SELECT
    vcMasterParams, // parametro del dettaglio senza campo omonimo nel master
    // Mantis #320 - 2026-11-04: controlli sulla definizione dei lookup
    vcLookupGridColumns, // vista senza colonne: la tendina mostra la chiave
    vcLookupParameters, // MasterFields e parametri della SELECT non si corrispondono
    vcLookupDomainMissing, // dominio di un campo vivo con lookup inesistente
    vcLookupShowsKey, // la prima colonna e' la chiave numerica
    vcLookupSearchOnKey, // la ricerca e' sulla chiave numerica
    vcLookupOrderBy, // l'ordinamento non parte dal campo mostrato
    vcLookupColumnsExist, // colonne assenti dalla SELECT del dataset
    vcLookupCompositeKey); // chiave ripetuta: parte di una chiave primaria composta

  // Classe di riparabilità di un problema:
  // fkNone      - solo correzione manuale (default)
  // fkSafe      - fix senza perdita d'informazione (normalizzazione/trim):
  // applicabile in batch, conferma solo sul batch
  // fkSuggested - fix con un valore proposto che l'utente DEVE rivedere
  // riga per riga prima di applicarlo
  TzFixKind = (fkNone, fkSafe, fkSuggested);

  // Azione che applica la correzione sull'oggetto in memoria e la persiste.
  // nil quando FixKind = fkNone.
  TzFixAction = reference to procedure;

  TzVerifyResult = record
    Severity: TzVerifySeverity;
    Category: TzVerifyCategory;
    ObjectName: string; // nome dataset/lookup/dominio
    SubItem: string; // 'SQL_Insert', 'FieldNamesFK', ...
    Message: string;
    SQL: string; // testo SQL coinvolto (se pertinente)
    Item: TzCollectionItem; // per la navigazione UI; può essere nil
    FixKind: TzFixKind; // se/come è auto-riparabile
    FixDescription: string; // cosa farebbe il fix (mostrato in UI)
    FixAction: TzFixAction; // la correzione; nil se fkNone
  end;

  // Restituisce True per CONTINUARE, False per interrompere (StopOnFirstError)
  TzVerifyEmitEvent = reference to function(const R: TzVerifyResult): Boolean;

  // Cancel: il chiamante può impostarlo a True per annullare
  TzVerifyProgress = reference to procedure(const Current, Total: Integer; const Msg: string; var Cancel: Boolean);

  TzVerifyResults = TList<TzVerifyResult>;

  TzVerifyStats = record
    Infos: Integer;
    Warnings: Integer;
    Errors: Integer;
    procedure Clear;
    function HasErrors: Boolean;
  end;

  // Colonna in uscita da una SELECT, ricavata dal solo testo
  TzSqlSelectColumn = record
    Name: string; // nome in uscita: l'alias, altrimenti il campo; '*' = tutti i campi
    Relation: string; // relazione o alias che qualifica il campo; '' se manca
    FieldName: string; // campo d'origine; '' se la colonna e' un'espressione
    IsTextExpression: Boolean; // espressione con concatenazione o letterali
  end;

  // Forma di una SELECT letta senza database: colonne, relazioni, WHERE e
  // ORDER BY del blocco principale. Non e' un analizzatore SQL: legge quanto
  // serve ai controlli sui lookup, e con una forma che non capisce lascia
  // Complete a False, cosi' i controlli sulle colonne non danno falsi allarmi.
  TzSqlSelectShape = class
  public
    Columns: TList<TzSqlSelectColumn>;
    Relations: TStringList; // NOME=RELAZIONE per ogni relazione, alias compresi
    RelationNames: TStringList; // relazioni di FROM e JOIN, in ordine
    WhereWords: TStringList; // parole della WHERE principale
    OrderByWords: TStringList; // parole del primo termine dell'ORDER BY
    OrderByPosition: Integer; // ORDER BY <numero>: posizione; 0 se non e' un numero
    NoRepeatedRows: Boolean; // DISTINCT o GROUP BY
    Complete: Boolean; // False: colonne non tutte note
    constructor Create;
    destructor Destroy; override;
    function RelationOf(const Name: string): string;
    function FindColumn(const Name: string; out Column: TzSqlSelectColumn): Boolean;
    class function Parse(const SQL: string): TzSqlSelectShape;
  end;

  TzSystemVerifier = class
  private
    FzSystem: TzSystem;
    FFDQuery: TFDQuery;
    FOnEmit: TzVerifyEmitEvent;
    FOnProgress: TzVerifyProgress;
    FStopOnFirstError: Boolean;
    FCheckSql: Boolean;
    FCheckEmptySelect: Boolean;
    FCheckStoredProcs: Boolean;
    FCheckLookups: Boolean;
    FLookupMappingsWarning: Boolean; // controllo (6): attivo solo in console
    FCheckRefIntegrity: Boolean;
    FCheckDomainCoverage: Boolean;
    FCheckDomainExists: Boolean;
    FCheckAutoSql: Boolean;
    FCheckLookupCardinality: Boolean;
    FCheckDuplicates: Boolean;
    FCheckGenerators: Boolean;
    FCheckSeparators: Boolean;
    FCheckLookupFieldsExist: Boolean;
    // Mantis #320 - 2026-11-04: controlli sulla definizione dei lookup. Leggono
    // solo il dizionario e sono tutti spenti di norma: li accende il chiamante
    FCheckLookupGridColumns: Boolean;
    FCheckLookupParameters: Boolean;
    FCheckLookupDomainMissing: Boolean;
    FCheckLookupShowsKey: Boolean;
    FCheckLookupSearchOnKey: Boolean;
    FCheckLookupOrderBy: Boolean;
    FCheckLookupColumnsExist: Boolean;
    FCheckLookupCompositeKey: Boolean;
    FStats: TzVerifyStats;
    FCancelled: Boolean;

    // Cache dei campi di OUTPUT per dataset, popolata durante il Prepare del
    // SQL_Select in VerifyDataSets. Chiave = nome dataset (case-insensitive);
    // valore = TStringList ordinata dei nomi-colonna. Riusata dai controlli
    // sui campi (lookup/view/card) senza ulteriori Prepare.
    FFieldDefsCache: TObjectDictionary<string, TStringList>;

    // Messaggio d'errore del Prepare del SQL_Select, per dataset. Stringa vuota
    // = SELECT preparato correttamente (o vuoto). Serve a distinguere "SELECT
    // che non produce campi" da "SELECT che non si prepara" senza dover rifare
    // un Prepare diagnostico.
    FPrepareErrorCache: TDictionary<string, string>;

    // Insieme ordinato dei nomi di TABELLA noti (da MetaData.Tables), usato per
    // distinguere una tabella fisica da vista / stored procedure selezionabile /
    // relazione di sistema. nil finche' non serve: vedi KnownTables.
    FKnownTables: TStringList;

    // Campi per relazione (tabella, vista, output di stored procedure) presi da
    // zDataDictionary, senza database. nil finche' non serve: vedi RelationFields.
    FRelationFields: TObjectDictionary<string, TStringList>;

    // Forma della SELECT per dataset, con gli asterischi gia' espansi.
    FSelectShapes: TObjectDictionary<string, TzSqlSelectShape>;

    // Lookup -> relazioni dei campi vivi che lo usano. Costruito alla prima
    // richiesta: vedi LookupUsers.
    FLookupUsers: TObjectDictionary<string, TStringList>;

    // Lookup a griglia di un campo vivo di una relazione che arriva a video.
    FGridLookups: TStringList;

    // Emette un risultato; aggiorna le statistiche; ritorna False se si deve
    // interrompere (StopOnFirstError su un errore, oppure OnEmit ha chiesto stop)
    function Emit(Severity: TzVerifySeverity; Category: TzVerifyCategory; const ObjectName, SubItem, Msg: string; Item: TzCollectionItem; const SQL: string = ''): Boolean;
    function DoEmit(const R: TzVerifyResult): Boolean;

    // come Emit ma con metadati di riparazione (FixKind/descrizione/azione)
    function EmitFix(Severity: TzVerifySeverity; Category: TzVerifyCategory; const ObjectName, SubItem, Msg: string; Item: TzCollectionItem; FixKind: TzFixKind; const FixDescription: string; const FixAction: TzFixAction): Boolean;

    // Prepare puro (mai Open). Ritorna True se la query è valida.
    // Su errore emette vsError. Su SQL vuoto NON emette (gestione a parte).
    function PrepareSql(const ObjectName, SubItem, SQL: string; Category: TzVerifyCategory; Item: TzCollectionItem; out Continue: Boolean): Boolean;

    function Progress(const Current, Total: Integer; const Msg: string): Boolean;

    // Prepara il SQL_Select del dataset (se non già in cache) e restituisce la
    // lista ordinata dei suoi campi di output. nil se il SELECT è vuoto o non
    // si prepara. Popola FFieldDefsCache. Mai Open.
    function GetDataSetFields(dsObj: TzDataSet): TStringList;

    // Errore registrato dal Prepare del SQL_Select durante GetDataSetFields.
    // '' se il SELECT si prepara o se e' vuoto.
    function PrepareErrorOf(dsObj: TzDataSet): string;

    // Nomi delle tabelle fisiche note (MetaData.Tables), lista ordinata e
    // case-insensitive. Costruita alla prima richiesta.
    function KnownTables: TStringList;

    // Campi della relazione secondo zDataDictionary; nil se non e' nel dizionario.
    function RelationFields(const RelationName: string): TStringList;

    // Campi che il master mette a disposizione dei parametri del dettaglio.
    // False se non si possono conoscere (SELECT con * su relazioni ignote).
    function CollectMasterFields(MasterDataSet: TzDataSet; Fields: TStringList): Boolean;

    function VerifyDataSets(const Total: Integer; var Done: Integer): Boolean;
    function VerifyStoredProcs(const Total: Integer; var Done: Integer): Boolean;
    function VerifyLookupsInternal(const Total: Integer; var Done: Integer): Boolean;
    function VerifyDomainLookups(const Total: Integer; var Done: Integer): Boolean;

    // --- controlli aggiuntivi ---
    function VerifyRefIntegrity(const Total: Integer; var Done: Integer): Boolean;
    function VerifyDomainCoverage(const Total: Integer; var Done: Integer): Boolean;
    function VerifyDomainExists(const Total: Integer; var Done: Integer): Boolean;
    function VerifyAutoSql(const Total: Integer; var Done: Integer): Boolean;
    function VerifyLookupCardinality(const Total: Integer; var Done: Integer): Boolean;
    function VerifyDuplicates(const Total: Integer; var Done: Integer): Boolean;
    function VerifyGenerators(const Total: Integer; var Done: Integer): Boolean;
    function VerifySeparators(const Total: Integer; var Done: Integer): Boolean;
    // parametri della SELECT dei dettagli senza campo omonimo nel master
    // (parte di RefIntegrity: e' un riferimento pendente fra due dataset)
    function VerifyMasterParams(const Total: Integer; var Done: Integer): Boolean;
    // helper: verifica i campi del lookup contro i FieldDefs del SELECT
    function VerifyLookupFieldsExist(lk: TzLookup; dsObj: TzDataSet): Boolean;

    // --- definizione dei lookup (Mantis #320) ---
    function HasLookupDefinitionChecks: Boolean;
    // Campi di una relazione nell'ordine del database, se i metadati lo dicono.
    function CollectRelationFields(const RelationName: string; Fields: TStrings): Boolean;
    function SelectShapeOf(dsObj: TzDataSet): TzSqlSelectShape;
    function LookupUsers(const LookupName: string): TStringList;
    function FindDomainOf(Shape: TzSqlSelectShape; const Column: TzSqlSelectColumn): TzDomain;
    function ColumnIsText(Shape: TzSqlSelectShape; const Column: TzSqlSelectColumn): Boolean;
    function ColumnIsNumericKey(Shape: TzSqlSelectShape; const ColumnName: string): Boolean;
    // Primo campo testuale della SELECT che descrive la voce; '' se non ce n'e'.
    function DescriptiveColumn(Shape: TzSqlSelectShape; Keys: TStrings): string;
    function UnrecognizedTextColumn(Shape: TzSqlSelectShape; Keys: TStrings): string;
    // Colonna che la tendina mostra nel campo, come la sceglie zDX.GetListFieldItem.
    function ShownColumn(lk: TzLookup; Shape: TzSqlSelectShape): string;
    function MasterFieldKnown(lk: TzLookup; const FieldName: string): Boolean;
    function VerifyLookupDefinitions(const Total: Integer; var Done: Integer): Boolean;
    function VerifyLookupParameters(lk: TzLookup; dsObj: TzDataSet): Boolean;
    function VerifyLookupColumns(lk: TzLookup; dsObj: TzDataSet; Shape: TzSqlSelectShape): Boolean;
    function VerifyLookupPresentation(lk: TzLookup; dsObj: TzDataSet; Shape: TzSqlSelectShape): Boolean;
    function VerifyLookupCompositeKey(lk: TzLookup; dsObj: TzDataSet; Shape: TzSqlSelectShape): Boolean;
    function VerifyDomainLookupsExist(const Total: Integer; var Done: Integer): Boolean;
  public
    constructor Create(azSystem: TzSystem; aFDQuery: TFDQuery);
    destructor Destroy; override;

    // Esegue tutte le verifiche abilitate. I risultati passano per OnEmit;
    // se Results <> nil vengono anche accumulati lì.
    function VerifyAll(Results: TzVerifyResults = nil): TzVerifyStats;
    // Numero di item che verranno processati (= numero di chiamate IncProgress).
    // Da usare per ProgressBox.Show, così il Max coincide col conteggio reale.
    function EstimateTotal: Integer;

    // Elenca i domini obsoleti (Exists = False dopo InitializeFromDB),
    // separandoli in due insiemi:
    // Unused    - nessuna DbView/DbCard/DbPivot li usa: rimovibili;
    // StillUsed - ancora referenziati da un FieldOrigin: NON rimovibili,
    // vanno prima corretti l'interfaccia o il database.
    // Entrambi i parametri possono essere nil. Ritorna il totale dei domini
    // obsoleti trovati. Usata sia dal controllo VerifyDomainExists sia dalla
    // rimozione in blocco della form, così la regola vive in un solo posto.
    class function CollectObsoleteDomains(azSystem: TzSystem; Unused, StillUsed: TStrings): Integer;

    property OnEmit: TzVerifyEmitEvent read FOnEmit write FOnEmit;
    property OnProgress: TzVerifyProgress read FOnProgress write FOnProgress;

    // form: True (si ferma al primo errore). console: False (raccoglie tutto)
    property StopOnFirstError: Boolean read FStopOnFirstError write FStopOnFirstError;

    property CheckSql: Boolean read FCheckSql write FCheckSql;
    property CheckEmptySelect: Boolean read FCheckEmptySelect write FCheckEmptySelect;
    property CheckStoredProcs: Boolean read FCheckStoredProcs write FCheckStoredProcs;
    property CheckLookups: Boolean read FCheckLookups write FCheckLookups;
    property LookupMappingsWarning: Boolean read FLookupMappingsWarning write FLookupMappingsWarning;

    // controlli aggiuntivi (opt-in)
    property CheckRefIntegrity: Boolean read FCheckRefIntegrity write FCheckRefIntegrity;
    // ex CheckDomainDataSet: tabelle fisiche che nessun DataSet usa. Solo INFO:
    // e' una misura di copertura dell'applicazione, non un difetto.
    property CheckDomainCoverage: Boolean read FCheckDomainCoverage write FCheckDomainCoverage;
    // domini rimasti nell'LZ ma non piu' presenti nel database
    property CheckDomainExists: Boolean read FCheckDomainExists write FCheckDomainExists;
    property CheckAutoSql: Boolean read FCheckAutoSql write FCheckAutoSql;
    property CheckLookupCardinality: Boolean read FCheckLookupCardinality write FCheckLookupCardinality;
    property CheckDuplicates: Boolean read FCheckDuplicates write FCheckDuplicates;
    property CheckGenerators: Boolean read FCheckGenerators write FCheckGenerators;
    property CheckSeparators: Boolean read FCheckSeparators write FCheckSeparators;
    // confronta FieldNamesFK/KeyField/DisplayColumns del lookup contro i
    // FieldDefs prodotti dal Prepare del SELECT del dataset di lookup (no Open)
    property CheckLookupFieldsExist: Boolean read FCheckLookupFieldsExist write FCheckLookupFieldsExist;

    // Definizione dei lookup (Mantis #320). Spenti di norma: finche' il
    // chiamante non li accende la verifica resta quella di prima.
    // Vista senza colonne e senza SearchFields, con la tendina che mostra l'id [ERROR]
    property CheckLookupGridColumns: Boolean read FCheckLookupGridColumns write FCheckLookupGridColumns;
    // MasterFields e parametri della SELECT nei due versi, campo del master [ERROR]
    property CheckLookupParameters: Boolean read FCheckLookupParameters write FCheckLookupParameters;
    // Dominio di un campo vivo che cita un lookup inesistente [ERROR]
    property CheckLookupDomainMissing: Boolean read FCheckLookupDomainMissing write FCheckLookupDomainMissing;
    // La prima colonna e' la chiave numerica e c'e' un campo descrittivo [WARNING]
    property CheckLookupShowsKey: Boolean read FCheckLookupShowsKey write FCheckLookupShowsKey;
    // SearchFields sulla chiave numerica e c'e' un campo descrittivo [WARNING]
    property CheckLookupSearchOnKey: Boolean read FCheckLookupSearchOnKey write FCheckLookupSearchOnKey;
    // ORDER BY che non parte dal campo mostrato [WARNING]
    property CheckLookupOrderBy: Boolean read FCheckLookupOrderBy write FCheckLookupOrderBy;
    // Colonne della vista e DisplayColumns contro la SELECT del dataset [ERROR]
    property CheckLookupColumnsExist: Boolean read FCheckLookupColumnsExist write FCheckLookupColumnsExist;
    // Chiave che e' solo parte di una primaria composta, senza filtro sul resto [WARNING]
    property CheckLookupCompositeKey: Boolean read FCheckLookupCompositeKey write FCheckLookupCompositeKey;

    property Stats: TzVerifyStats read FStats;
    property Cancelled: Boolean read FCancelled;
  end;

  // Helper di formattazione per il log (riusabile da console e form)
function SeverityToStr(S: TzVerifySeverity): string;
function CategoryToStr(C: TzVerifyCategory): string;
function FormatVerifyResult(const R: TzVerifyResult): string;

implementation

uses
  System.StrUtils,
  zBaseLib,
  zMetaData, // MetaData.Tables: distinzione tabella / vista / stored procedure
  zTypes; // TzCtrlType + helper IsLookup

{ TzVerifyStats }

procedure TzVerifyStats.Clear;
begin
  Infos := 0;
  Warnings := 0;
  Errors := 0;
end;

function TzVerifyStats.HasErrors: Boolean;
begin
  Result := Errors > 0;
end;

{ funzioni di formattazione }

function SeverityToStr(S: TzVerifySeverity): string;
begin
  case S of
    vsInfo:
      Result := 'INFO';
    vsWarning:
      Result := 'WARN';
    vsError:
      Result := 'ERROR';
  else
    Result := '?';
  end;
end;

function CategoryToStr(C: TzVerifyCategory): string;
begin
  case C of
    vcSqlSelect:
      Result := 'SQL_Select';
    vcSqlOther:
      Result := 'SQL';
    vcEmptySelect:
      Result := 'EmptySelect';
    vcStoredProc:
      Result := 'StoredProc';
    vcLookupDataSet:
      Result := 'Lookup.DataSet';
    vcLookupSelect:
      Result := 'Lookup.Select';
    vcLookupFieldsFK:
      Result := 'Lookup.FieldNamesFK';
    vcLookupDomain:
      Result := 'Lookup.Domain';
    vcLookupDbView:
      Result := 'Lookup.DbView';
    vcLookupKeyField:
      Result := 'Lookup.KeyField';
    vcLookupMappings:
      Result := 'Lookup.Mappings';
    vcRefIntegrity:
      Result := 'RefIntegrity';
    vcDomainCoverage:
      Result := 'Domain.Coverage';
    vcDomainExists:
      Result := 'Domain.Exists';
    vcAutoSql:
      Result := 'AutoSQL';
    vcLookupCardinality:
      Result := 'Lookup.Cardinality';
    vcDuplicate:
      Result := 'Duplicate';
    vcGenerator:
      Result := 'Generator';
    vcLookupFieldExist:
      Result := 'Lookup.FieldExist';
    vcMasterParams:
      Result := 'MasterParams';
    vcLookupGridColumns:
      Result := 'Lookup.GridColumns';
    vcLookupParameters:
      Result := 'Lookup.Parameters';
    vcLookupDomainMissing:
      Result := 'Lookup.DomainMissing';
    vcLookupShowsKey:
      Result := 'Lookup.ShowsKey';
    vcLookupSearchOnKey:
      Result := 'Lookup.SearchOnKey';
    vcLookupOrderBy:
      Result := 'Lookup.OrderBy';
    vcLookupColumnsExist:
      Result := 'Lookup.ColumnsExist';
    vcLookupCompositeKey:
      Result := 'Lookup.CompositeKey';
  else
    Result := '?';
  end;
end;

function FormatVerifyResult(const R: TzVerifyResult): string;
begin
  Result := Format('[%s] %s | %s', [SeverityToStr(R.Severity), CategoryToStr(R.Category), R.ObjectName]);

  if R.SubItem <> '' then
    Result := Result + ' (' + R.SubItem + ')';

  Result := Result + ': ' + R.Message;
end;

{ TzSystemVerifier }

constructor TzSystemVerifier.Create(azSystem: TzSystem; aFDQuery: TFDQuery);
begin
  inherited Create;
  FzSystem := azSystem;
  FFDQuery := aFDQuery;

  // default sicuri: comportamento equivalente all'attuale doVerificaSql
  FStopOnFirstError := True;
  FCheckSql := True;
  FCheckEmptySelect := True;
  FCheckStoredProcs := True;
  FCheckLookups := True;
  FLookupMappingsWarning := False; // il chiamante console lo attiva
  // controlli aggiuntivi: opt-in, spenti di default (li accende il chiamante)
  FCheckRefIntegrity := False;
  FCheckDomainCoverage := False;
  FCheckDomainExists := False;
  FCheckAutoSql := False;
  FCheckLookupCardinality := False;
  FCheckDuplicates := False;
  FCheckGenerators := False;
  FCheckSeparators := False;
  FCheckLookupFieldsExist := False;
  // i controlli sulla definizione dei lookup: spenti, come gli aggiuntivi
  FCheckLookupGridColumns := False;
  FCheckLookupParameters := False;
  FCheckLookupDomainMissing := False;
  FCheckLookupShowsKey := False;
  FCheckLookupSearchOnKey := False;
  FCheckLookupOrderBy := False;
  FCheckLookupColumnsExist := False;
  FCheckLookupCompositeKey := False;
  FFieldDefsCache := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);
  FPrepareErrorCache := TDictionary<string, string>.Create;
  FStats.Clear;
end;

destructor TzSystemVerifier.Destroy;
begin
  FGridLookups.Free;
  FLookupUsers.Free;
  FSelectShapes.Free;
  FKnownTables.Free;
  FRelationFields.Free;
  FPrepareErrorCache.Free;
  FFieldDefsCache.Free;
  inherited;
end;

function TzSystemVerifier.KnownTables: TStringList;
var
  i: Integer;
begin
  if Assigned(FKnownTables) then
    Exit(FKnownTables);

  FKnownTables := TStringList.Create;
  FKnownTables.CaseSensitive := False;
  FKnownTables.Sorted := True;
  FKnownTables.Duplicates := dupIgnore;

  // MetaData e' sempre disponibile: LoadZip carica MetaData dall'LZ e
  // InitializeFromDB la rilegge dal database. Tables contiene SOLO tabelle
  // fisiche (META.TABLES): viste e stored procedure stanno in Views/Procedures.
  if Assigned(FzSystem) and Assigned(FzSystem.MetaData) then
    for i := 0 to FzSystem.MetaData.Tables.Count - 1 do
      if Trim(FzSystem.MetaData.Tables[i].Name) <> '' then
        FKnownTables.Add(Trim(FzSystem.MetaData.Tables[i].Name));

  Result := FKnownTables;
end;

type
  TSqlTokenProc = reference to procedure(const Token: string);

// Scanner minimale della SQL: salta stringhe e commenti, passa a OnParam il
// nome di ogni parametro (:NOME, maiuscolo, '#' compreso: :##AZIENDA_DI_LAVORO)
// e a OnWord ogni identificatore, anche fra virgolette, piu' i simboli '.' e '*'
// (servono a riconoscere TABELLA.* e SELECT *). Non interpreta l'SQL.
procedure ScanSql(const SQL: string; const OnParam, OnWord: TSqlTokenProc);
const
  Starters: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '_', '$'];
  ParamStarters: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '_', '$', '#'];
  Followers: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_', '$', '#'];
var
  i, start, len: Integer;

  procedure ReadName;
  begin
    start := i;
    while i <= len do
    begin
      if not CharInSet(SQL[i], Followers) then
        Break;
      Inc(i);
    end;
  end;

begin
  len := Length(SQL);
  i := 1;
  while i <= len do
  begin
    case SQL[i] of
      '''':
        begin
          // stringa: l'apice raddoppiato non la chiude
          Inc(i);
          while i <= len do
            if SQL[i] = '''' then
            begin
              if (i < len) and (SQL[i + 1] = '''') then
                Inc(i, 2)
              else
              begin
                Inc(i);
                Break;
              end;
            end
            else
              Inc(i);
        end;
      '"':
        begin
          // identificatore fra virgolette: vale come parola
          Inc(i);
          start := i;
          while (i <= len) and (SQL[i] <> '"') do
            Inc(i);
          if Assigned(OnWord) then
            OnWord(UpperCase(Copy(SQL, start, i - start)));
          Inc(i);
        end;
      '-':
        if (i < len) and (SQL[i + 1] = '-') then
        begin
          while (i <= len) and not CharInSet(SQL[i], [#10, #13]) do
            Inc(i);
        end
        else
          Inc(i);
      '/':
        if (i < len) and (SQL[i + 1] = '*') then
        begin
          Inc(i, 2);
          while (i < len) and not((SQL[i] = '*') and (SQL[i + 1] = '/')) do
            Inc(i);
          Inc(i, 2);
        end
        else
          Inc(i);
      ':':
        begin
          Inc(i);
          if (i <= len) and CharInSet(SQL[i], ParamStarters) then
          begin
            ReadName;
            if Assigned(OnParam) then
              OnParam(UpperCase(Copy(SQL, start, i - start)));
          end;
        end;
      '.', '*':
        begin
          if Assigned(OnWord) then
            OnWord(SQL[i]);
          Inc(i);
        end;
    else
      if CharInSet(SQL[i], Starters) then
      begin
        ReadName;
        if Assigned(OnWord) then
          OnWord(UpperCase(Copy(SQL, start, i - start)));
      end
      else
        Inc(i);
    end;
  end;
end;

function TzSystemVerifier.RelationFields(const RelationName: string): TStringList;
var
  i: Integer;
  domain: TzDomain;
  relName: string;
  Fields: TStringList;
begin
  if not Assigned(FRelationFields) then
  begin
    FRelationFields := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);

    // zDataDictionary e' il catalogo dello schema (tabelle, viste, output delle
    // stored procedure) e c'e' anche senza database: LoadZip lo carica dall'LZ
    for i := 0 to FzSystem.zDataDictionary.Count - 1 do
    begin
      domain := FzSystem.zDataDictionary[i];
      relName := UpperCase(Trim(domain.TableName));
      if (relName = '') or (Trim(domain.FieldName) = '') then
        Continue;

      if not FRelationFields.TryGetValue(relName, Fields) then
      begin
        Fields := TStringList.Create;
        FRelationFields.Add(relName, Fields);
      end;
      Fields.Add(UpperCase(Trim(domain.FieldName)));
    end;
  end;

  if not FRelationFields.TryGetValue(UpperCase(Trim(RelationName)), Result) then
    Result := nil;
end;

function TzSystemVerifier.CollectMasterFields(MasterDataSet: TzDataSet; Fields: TStringList): Boolean;
var
  Prepared: TStringList;
  StarUsed: Boolean;
  KnownRelations: Integer;
begin
  // Con il database la SELECT del master e' gia' stata preparata da
  // VerifyDataSets (controllo Sql): i suoi campi sono quelli esatti
  if FFieldDefsCache.TryGetValue(MasterDataSet.Name, Prepared) then
    if (PrepareErrorOf(MasterDataSet) = '') and (Prepared.Count > 0) then
    begin
      Fields.AddStrings(Prepared);
      Exit(True);
    end;

  // Senza database: ogni parola della SELECT del master, piu' i campi delle
  // relazioni che vi compaiono (per TABELLA.* e SELECT *). La stima e'
  // larga di proposito: un parametro che coincide con una parola qualunque
  // del master non viene segnalato, per non dare falsi allarmi.
  StarUsed := False;
  KnownRelations := 0;
  ScanSql(MasterDataSet.SQL_Select.Text, nil,
    procedure(const Token: string)
    var
      Relation: TStringList;
    begin
      if Token = '*' then
        StarUsed := True
      else if Token <> '.' then
      begin
        Fields.Add(Token);
        Relation := RelationFields(Token);
        if Assigned(Relation) then
        begin
          Fields.AddStrings(Relation);
          Inc(KnownRelations);
        end;
      end;
    end);

  // un * su relazioni che il dizionario non conosce: i campi non si sanno
  Result := (not StarUsed) or (KnownRelations > 0);
end;

function TzSystemVerifier.GetDataSetFields(dsObj: TzDataSet): TStringList;
var
  fd: Integer;
  key: string;
begin
  key := dsObj.Name;

  // già in cache (anche un nil cache-ato lo gestiamo: vedi sotto)
  if FFieldDefsCache.TryGetValue(key, Result) then
    Exit;

  Result := nil;

  if Trim(dsObj.SQL_Select.Text) = '' then
  begin
    // niente da preparare: cache un valore vuoto per non riprovare
    Result := TStringList.Create;
    Result.Sorted := True;
    Result.CaseSensitive := False;
    Result.Duplicates := dupIgnore;
    FFieldDefsCache.Add(key, Result);
    FPrepareErrorCache.AddOrSetValue(key, '');
    Exit;
  end;

  Result := TStringList.Create;
  Result.Sorted := True;
  Result.CaseSensitive := False;
  Result.Duplicates := dupIgnore;
  try
    FFDQuery.SQL.Text := dsObj.SQL_Select.Text;
    FFDQuery.Prepare; // mai Open: popola i FieldDefs con le colonne output
    for fd := 0 to FFDQuery.FieldDefs.Count - 1 do
      Result.Add(FFDQuery.FieldDefs[fd].Name);
    FPrepareErrorCache.AddOrSetValue(key, '');
  except
    on e: Exception do
      // SELECT che non si prepara: si registra il messaggio, cosi' il chiamante
      // lo emette senza rifare un Prepare diagnostico. Result resta vuota ma
      // valida: i controlli sui campi la trattano come "non confrontabile".
      FPrepareErrorCache.AddOrSetValue(key, e.Message);
  end;

  FFieldDefsCache.Add(key, Result);
end;

function TzSystemVerifier.PrepareErrorOf(dsObj: TzDataSet): string;
begin
  if not FPrepareErrorCache.TryGetValue(dsObj.Name, Result) then
    Result := '';
end;

function TzSystemVerifier.DoEmit(const R: TzVerifyResult): Boolean;
begin
  case R.Severity of
    vsInfo:
      Inc(FStats.Infos);
    vsWarning:
      Inc(FStats.Warnings);
    vsError:
      Inc(FStats.Errors);
  end;

  Result := True;
  if Assigned(FOnEmit) then
    Result := FOnEmit(R);

  // StopOnFirstError ha priorità: su un errore interrompe a prescindere
  if (R.Severity = vsError) and FStopOnFirstError then
    Result := False;
end;

function TzSystemVerifier.Emit(Severity: TzVerifySeverity; Category: TzVerifyCategory; const ObjectName, SubItem, Msg: string; Item: TzCollectionItem; const SQL: string): Boolean;
var
  R: TzVerifyResult;
begin
  R := Default (TzVerifyResult);
  R.Severity := Severity;
  R.Category := Category;
  R.ObjectName := ObjectName;
  R.SubItem := SubItem;
  R.Message := Msg;
  R.SQL := SQL;
  R.Item := Item;
  R.FixKind := fkNone;
  Result := DoEmit(R);
end;

function TzSystemVerifier.EmitFix(Severity: TzVerifySeverity; Category: TzVerifyCategory; const ObjectName, SubItem, Msg: string; Item: TzCollectionItem; FixKind: TzFixKind; const FixDescription: string; const FixAction: TzFixAction): Boolean;
var
  R: TzVerifyResult;
begin
  R := Default (TzVerifyResult);
  R.Severity := Severity;
  R.Category := Category;
  R.ObjectName := ObjectName;
  R.SubItem := SubItem;
  R.Message := Msg;
  R.Item := Item;
  R.FixKind := FixKind;
  R.FixDescription := FixDescription;
  R.FixAction := FixAction;
  Result := DoEmit(R);
end;

function TzSystemVerifier.PrepareSql(const ObjectName, SubItem, SQL: string; Category: TzVerifyCategory; Item: TzCollectionItem; out Continue: Boolean): Boolean;
begin
  Continue := True;

  // SQL vuoto: NON è un errore di Prepare. La gestione (skip vs errore) è
  // del chiamante — qui ritorniamo True senza emettere nulla.
  if Trim(SQL) = '' then
    Exit(True);

  FFDQuery.SQL.Text := SQL;
  try
    FFDQuery.Prepare; // MAI Open: solo validazione struttura
    Result := True;
  except
    on e: Exception do
    begin
      Result := False;
      Continue := Emit(vsError, Category, ObjectName, SubItem, e.Message, Item, SQL);
    end;
  end;
end;

function TzSystemVerifier.Progress(const Current, Total: Integer; const Msg: string): Boolean;
var
  Cancel: Boolean;
begin
  if Assigned(FOnProgress) then
  begin
    Cancel := False;
    FOnProgress(Current, Total, Msg, Cancel);
    if Cancel then
      FCancelled := True;
  end;
  Result := not FCancelled;
end;

function TzSystemVerifier.VerifyDataSets(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  ds: TzDataSet;
  Continue: Boolean;

  // SELECT / non-SELECT con politica diversa sul vuoto
  function TestScript(const SubItem, SQL: string; Category: TzVerifyCategory; IsSelect: Boolean): Boolean;
  begin
    Result := True;

    if Trim(SQL) = '' then
    begin
      // requisito Luca: SQL_Select vuoto = vsError. Gli altri script: skip.
      if IsSelect and FCheckEmptySelect then
        Result := Emit(vsError, vcEmptySelect, ds.Name, SubItem, 'SQL_Select vuoto o non definito', ds);
      Exit;
    end;

    PrepareSql(ds.Name, SubItem, SQL, Category, ds, Continue);
    Result := Continue;
  end;

begin
  Result := True;

  for i := 0 to FzSystem.zDataSets.Count - 1 do
  begin
    ds := FzSystem.zDataSets[i];

    Inc(Done);
    if not Progress(Done, Total, 'DataSet: ' + ds.Name) then
      Exit(False);

    // --- SQL_Select: caso speciale ---
    // vuoto = errore (requisito); altrimenti UN solo Prepare via
    // GetDataSetFields, che valida la sintassi E popola la cache dei campi.
    if Trim(ds.SQL_Select.Text) = '' then
    begin
      if FCheckEmptySelect then
        if not Emit(vsError, vcEmptySelect, ds.Name, 'SQL_Select', 'SQL_Select vuoto o non definito', ds) then
          Exit(False);
    end
    else
    begin
      // UN solo Prepare via GetDataSetFields: valida la sintassi e popola la
      // cache dei campi. L'eventuale errore e' registrato in PrepareErrorOf, per
      // cui non serve un secondo Prepare diagnostico e un SELECT valido che non
      // produce campi non viene piu' segnalato come errore.
      GetDataSetFields(ds);

      var
      prepareError := PrepareErrorOf(ds);
      if prepareError <> '' then
        if not Emit(vsError, vcSqlSelect, ds.Name, 'SQL_Select', prepareError, ds, ds.SQL_Select.Text) then
          Exit(False);
    end;

    // --- gli altri script: solo Prepare, vuoto = skip (come prima) ---
    if not TestScript('SQL_Insert', ds.SQL_Insert.Text, vcSqlOther, False) then
      Exit(False);
    if not TestScript('SQL_Update', ds.SQL_Update.Text, vcSqlOther, False) then
      Exit(False);
    if not TestScript('SQL_Delete', ds.SQL_Delete.Text, vcSqlOther, False) then
      Exit(False);
    if not TestScript('SQL_Refresh', ds.SQL_Refresh.Text, vcSqlOther, False) then
      Exit(False);
  end;
end;

function TzSystemVerifier.VerifyStoredProcs(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  sp: TzStoredProc;
  Continue: Boolean;
begin
  Result := True;

  for i := 0 to FzSystem.zStoredProcs.Count - 1 do
  begin
    sp := FzSystem.zStoredProcs[i];

    Inc(Done);
    if not Progress(Done, Total, 'StoredProc: ' + sp.Name) then
      Exit(False);

    PrepareSql(sp.Name + ': ' + sp.StoredProc, 'SQL', sp.SQL.Text, vcStoredProc, sp, Continue);
    if not Continue then
      Exit(False);
  end;
end;

function TzSystemVerifier.VerifyLookupsInternal(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  lk: TzLookup;
  dsObj: TzDataSet;
begin
  Result := True;

  for i := 0 to FzSystem.zLookups.Count - 1 do
  begin
    lk := FzSystem.zLookups[i];

    Inc(Done);
    if not Progress(Done, Total, 'Lookup: ' + lk.Name) then
      Exit(False);

    // (1) DataSet valorizzato e DataSet_Obj risolvibile  [ERROR]
    dsObj := lk.DataSet_Obj;
    if (Trim(lk.DataSet) = '') or (not Assigned(dsObj)) then
    begin
      if not Emit(vsError, vcLookupDataSet, lk.Name, 'DataSet', Format('DataSet di lookup non definito o non risolvibile (DataSet="%s")', [lk.DataSet]), lk) then
        Exit(False);

      // senza dataset risolto i controlli (2) non hanno senso: passa al prossimo
      Continue;
    end;

    // (2) il dataset di lookup ha un SQL_Select non vuoto  [ERROR]
    if Trim(dsObj.SQL_Select.Text) = '' then
      if not Emit(vsError, vcLookupSelect, lk.Name, 'DataSet.SQL_Select', Format('Il dataset di lookup "%s" non ha SQL_Select definito', [dsObj.Name]), lk) then
        Exit(False);

    // (3) FieldNamesFK non vuoto  [ERROR]
    if Trim(lk.FieldNamesFK) = '' then
      if not Emit(vsError, vcLookupFieldsFK, lk.Name, 'FieldNamesFK', 'Campo di ricerca (FieldNamesFK) non definito', lk) then
        Exit(False);

    // (3b) esistenza campi nei FieldDefs del SELECT (Prepare, no Open) [WARNING]
    if FCheckLookupFieldsExist and (Trim(dsObj.SQL_Select.Text) <> '') then
      if not VerifyLookupFieldsExist(lk, dsObj) then
        Exit(False);

    // (4) se DbView valorizzato allora DbView_Obj risolvibile  [WARNING]
    if Trim(lk.DbView) <> '' then
      if not Assigned(lk.DbView_Obj) then
        if not Emit(vsWarning, vcLookupDbView, lk.Name, 'DbView', Format('DbView "%s" non risolvibile', [lk.DbView]), lk) then
          Exit(False);

    // (5) KeyField presente  [WARNING]
    if Trim(lk.KeyField) = '' then
      if not Emit(vsWarning, vcLookupKeyField, lk.Name, 'KeyField', 'KeyField non definito (usato come fallback per il combo)', lk) then
        Exit(False);

    // (6) Mappings coerenti  [WARNING, solo se abilitato — console]
    // Coerenza "strutturale": ogni riga deve essere nella forma chiave=valore
    // con entrambi i lati non vuoti. NON si verifica l'esistenza reale dei
    // campi (scelta esplicita).
    if FLookupMappingsWarning and Assigned(lk.Mappings) then
    begin
      var
        m: Integer;
      for m := 0 to lk.Mappings.Count - 1 do
      begin
        var
        nme := lk.Mappings.Names[m];
        var
        val := lk.Mappings.ValueFromIndex[m];
        if (Trim(nme) = '') or (Trim(val) = '') then
          if not Emit(vsWarning, vcLookupMappings, lk.Name, 'Mappings', Format('Mapping incompleto alla riga %d: "%s"', [m, lk.Mappings[m]]), lk) then
            Exit(False);
      end;
    end;
  end;
end;

function TzSystemVerifier.VerifyDomainLookups(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  domain: TzDomain;
begin
  Result := True;

  // (7) domini con zCtrlType.IsLookup ma IdLookup vuoto / non risolvibile [ERROR]
  for i := 0 to FzSystem.zDataDictionary.Count - 1 do
  begin
    domain := FzSystem.zDataDictionary[i];

    Inc(Done);
    if not Progress(Done, Total, 'Dominio: ' + domain.Name) then
      Exit(False);

    if not domain.zCtrlType.IsLookup then
      Continue;

    if Trim(domain.Lookup) = '' then
    begin
      if not Emit(vsError, vcLookupDomain, domain.Name, 'Lookup', 'Dominio di tipo lookup senza IdLookup associato', domain) then
        Exit(False);
    end
    else
      if not Assigned(domain.Lookup_Obj) then
      begin
        if not Emit(vsError, vcLookupDomain, domain.Name, 'Lookup', Format('IdLookup "%s" non risolvibile in zLookups', [domain.Lookup]), domain) then
          Exit(False);
      end;
  end;
end;

// Conta i token separati da ';' ignorando vuoti agli estremi
function CountTokens(const S: string): Integer;
var
  parts: TArray<string>;
  p: string;
begin
  Result := 0;
  parts := Trim(S).Split([';']);
  for p in parts do
    if Trim(p) <> '' then
      Inc(Result);
end;

// (A) Integrità referenziale tra oggetti LZ: riferimenti pendenti
function TzSystemVerifier.VerifyRefIntegrity(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  dv: TzDbViewProps;
  dc: TzDbCardProps;
  dp: TzDbPivotProps;
  rv: TzDbRecordViewProps;
  tr: TzDbTreeProps;
  ch: TzDbChartProps;
  sc: TzDbSchedulerProps;
  ResourceDataSetID: string;
  lk: TzLookup;
begin
  Result := True;

  // zDbView.DataSet -> dataset esistente
  for i := 0 to FzSystem.zDbViews.Count - 1 do
  begin
    dv := FzSystem.zDbViews[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbView: ' + dv.Name) then
      Exit(False);
    if (Trim(dv.DataSet) <> '') and (FzSystem.zDataSets.get(dv.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, dv.Name, 'DataSet', Format('DbView riferisce un DataSet inesistente: "%s"', [dv.DataSet]), dv) then
        Exit(False);
  end;

  // zDbCard.DataSet -> dataset esistente
  for i := 0 to FzSystem.zDbCards.Count - 1 do
  begin
    dc := FzSystem.zDbCards[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbCard: ' + dc.Name) then
      Exit(False);
    if (Trim(dc.DataSet) <> '') and (FzSystem.zDataSets.get(dc.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, dc.Name, 'DataSet', Format('DbCard riferisce un DataSet inesistente: "%s"', [dc.DataSet]), dc) then
        Exit(False);
  end;

  // zDbPivot.DataSet -> dataset esistente
  for i := 0 to FzSystem.zDbPivots.Count - 1 do
  begin
    dp := FzSystem.zDbPivots[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbPivot: ' + dp.Name) then
      Exit(False);
    if (Trim(dp.DataSet) <> '') and (FzSystem.zDataSets.get(dp.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, dp.Name, 'DataSet', Format('DbPivot riferisce un DataSet inesistente: "%s"', [dp.DataSet]), dp) then
        Exit(False);
  end;

  // zDbRecordView.DataSet -> dataset esistente
  for i := 0 to FzSystem.zDbRecordViews.Count - 1 do
  begin
    rv := FzSystem.zDbRecordViews[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbRecordView: ' + rv.Name) then
      Exit(False);
    if (Trim(rv.DataSet) <> '') and (FzSystem.zDataSets.get(rv.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, rv.Name, 'DataSet', Format('DbRecordView riferisce un DataSet inesistente: "%s"', [rv.DataSet]), rv) then
        Exit(False);
  end;

  // zDbTree.DataSet -> dataset esistente; chiave e padre si indicano in coppia
  for i := 0 to FzSystem.zDbTrees.Count - 1 do
  begin
    tr := FzSystem.zDbTrees[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbTree: ' + tr.Name) then
      Exit(False);
    if (Trim(tr.DataSet) <> '') and (FzSystem.zDataSets.get(tr.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, tr.Name, 'DataSet', Format('DbTree riferisce un DataSet inesistente: "%s"', [tr.DataSet]), tr) then
        Exit(False);
    // Con uno solo dei due il componente ricava l'altro per convenzione e
    // puo' sbagliare in silenzio: l'albero resta vuoto senza errori
    if (Trim(tr.KeyFieldName) = '') <> (Trim(tr.ParentFieldName) = '') then
      if not Emit(vsWarning, vcRefIntegrity, tr.Name, 'KeyFieldName', 'DbTree con KeyFieldName e ParentFieldName indicati solo in parte', tr) then
        Exit(False);
  end;

  // zDbChart.DataSet -> dataset esistente
  for i := 0 to FzSystem.zDbCharts.Count - 1 do
  begin
    ch := FzSystem.zDbCharts[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbChart: ' + ch.Name) then
      Exit(False);
    if (Trim(ch.DataSet) <> '') and (FzSystem.zDataSets.get(ch.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, ch.Name, 'DataSet', Format('DbChart riferisce un DataSet inesistente: "%s"', [ch.DataSet]), ch) then
        Exit(False);
  end;

  // zDbScheduler.DataSet -> dataset esistente; ResourceDataSet -> dataset
  // dello stesso modulo dati. I campi della mappatura li controlla il
  // componente all'apertura: qui la SELECT non si esegue
  for i := 0 to FzSystem.zDbSchedulers.Count - 1 do
  begin
    sc := FzSystem.zDbSchedulers[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity DbScheduler: ' + sc.Name) then
      Exit(False);
    if (Trim(sc.DataSet) <> '') and (FzSystem.zDataSets.get(sc.DataSet, False) = nil) then
      if not Emit(vsError, vcRefIntegrity, sc.Name, 'DataSet', Format('DbScheduler riferisce un DataSet inesistente: "%s"', [sc.DataSet]), sc) then
        Exit(False);

    if Trim(sc.ResourceDataSet) <> '' then
    begin
      // ResourceDataSet e' il solo nome: il modulo e' quello di DataSet
      ResourceDataSetID := Trim(sc.ResourceDataSet);
      if Pos('.', sc.DataSet) > 0 then
        ResourceDataSetID := Copy(sc.DataSet, 1, Pos('.', sc.DataSet)) + ResourceDataSetID;

      if FzSystem.zDataSets.get(ResourceDataSetID, False) = nil then
        if not Emit(vsError, vcRefIntegrity, sc.Name, 'ResourceDataSet', Format('DbScheduler riferisce un DataSet delle risorse inesistente: "%s"', [ResourceDataSetID]), sc) then
          Exit(False);

      // senza chiave della risorsa e campo di legame le risorse non si vedono
      if (Trim(sc.ResourceIdField) = '') or (sc.Mapping.ResourceID = '') then
        if not Emit(vsWarning, vcRefIntegrity, sc.Name, 'ResourceIdField', 'DbScheduler con ResourceDataSet ma senza ResourceIdField o Mapping.ResourceID', sc) then
          Exit(False);
    end;
  end;

  // zLookup.DbCard -> risolvibile (se valorizzato)
  for i := 0 to FzSystem.zLookups.Count - 1 do
  begin
    lk := FzSystem.zLookups[i];
    Inc(Done);
    if not Progress(Done, Total, 'RefIntegrity Lookup: ' + lk.Name) then
      Exit(False);
    if (Trim(lk.DbCard) <> '') and (not Assigned(lk.DbCard_Obj)) then
      if not Emit(vsError, vcRefIntegrity, lk.Name, 'DbCard', Format('Lookup riferisce una DbCard inesistente: "%s"', [lk.DbCard]), lk) then
        Exit(False);
  end;

  // parametri dei dettagli -> campi del master
  Result := VerifyMasterParams(Total, Done);
end;

function TzSystemVerifier.VerifyMasterParams(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  dm: TzDataModule;

  // Parametri che il dettaglio non riceve dal master per nome. Esclusi quelli
  // che assegna zPack: FILTRO_* (filtri della barra), ##* e __* (valori
  // dell'applicazione, come :##AZIENDA_DI_LAVORO, e prefissi dei filtri).
  function CheckDetail(Detail, Master: TzDiagramDataSet): Boolean;
  var
    DetailDataSet, MasterDataSet: TzDataSet;
    Params, MasterFields: TStringList;
    Missing: TStringList;
    ParamName: string;
  begin
    Result := True;

    DetailDataSet := FzSystem.zDataSets.get(Detail.idDataSet, False);
    MasterDataSet := FzSystem.zDataSets.get(Master.idDataSet, False);
    // dataset mancanti: li segnalano gli altri controlli
    if (DetailDataSet = nil) or (MasterDataSet = nil) then
      Exit;
    if Trim(DetailDataSet.SQL_Select.Text) = '' then
      Exit;

    Params := TStringList.Create;
    MasterFields := TStringList.Create;
    Missing := TStringList.Create;
    try
      Params.Sorted := True;
      Params.Duplicates := dupIgnore;
      MasterFields.Sorted := True;
      MasterFields.CaseSensitive := False;
      MasterFields.Duplicates := dupIgnore;

      ScanSql(DetailDataSet.SQL_Select.Text,
        procedure(const Token: string)
        begin
          Params.Add(Token);
        end, nil);

      // niente parametri da confrontare, o campi del master non ricostruibili
      if Params.Count = 0 then
        Exit;
      if not CollectMasterFields(MasterDataSet, MasterFields) then
        Exit;

      for ParamName in Params do
      begin
        if ParamName.StartsWith('FILTRO_') or ParamName.StartsWith('##') or ParamName.StartsWith('__') then
          Continue;
        if MasterFields.IndexOf(ParamName) < 0 then
          Missing.Add(':' + ParamName);
      end;

      // Il collegamento master/dettaglio assegna i parametri per nome dai campi
      // del master: un parametro senza campo omonimo resta NULL e il dettaglio
      // resta vuoto. Succede dopo un cambio di master nel modulo (zTicser,
      // TicserConfigurazione, :VOCE), ma molti parametri li assegna il codice
      // (TzSystem.QueryParams, OnBeforeOpen): nei dizionari di Gesty e WT sono
      // circa 150 e il dizionario non li distingue. Per questo e' un'informazione,
      // da guardare sul modulo appena modificato, non un avviso.
      if Missing.Count > 0 then
        Result := Emit(vsInfo, vcMasterParams, DetailDataSet.Name, 'SQL_Select',
          Format('Parametri senza un campo omonimo nel master "%s": %s. Il dettaglio li riceve vuoti e non mostra righe, salvo che li assegni il codice', [MasterDataSet.Name, string.Join(', ', Missing.ToStringArray)]),
          DetailDataSet, DetailDataSet.SQL_Select.Text);
    finally
      Missing.Free;
      MasterFields.Free;
      Params.Free;
    end;
  end;

  function enum(zDiagramDataSets: TzDiagramDataSets): Boolean;
  var
    ds, det: TzDiagramDataSet;
  begin
    Result := True;
    for ds in zDiagramDataSets do
      if ds.HasDetailDataSets then
      begin
        for det in ds.DetailDatasets do
          if not det.IsLookupDataSet then
            if not CheckDetail(det, ds) then
              Exit(False);

        if not enum(ds.DetailDatasets) then
          Exit(False);
      end;
  end;

begin
  Result := True;

  for i := 0 to FzSystem.zDataModules.Count - 1 do
  begin
    dm := FzSystem.zDataModules[i];
    Inc(Done);
    if not Progress(Done, Total, 'MasterParams: ' + dm.Name) then
      Exit(False);
    if not enum(dm.DataSets) then
      Exit(False);
  end;
end;

// True per le relazioni che non appartengono al dominio applicativo e per cui
// non ha quindi senso pretendere l'esistenza di un DataSet:
// - relazioni di sistema Firebird (contengono '$': RDB$..., MON$..., SEC$...),
//   stessa regola di BASE.FILTER_NAME_OK;
// - relazioni scartate per convenzione ('AAA_');
// - tabelle di servizio del framework metadata ('ZZZ_BASE_').
function IsFrameworkRelation(const Name: string): Boolean;
var
  up: string;
begin
  up := UpperCase(Trim(Name));
  Result := (Pos('$', up) > 0) or up.StartsWith('AAA_') or up.StartsWith('ZZZ_BASE_');
end;

// Aggiunge a Referenced ogni identificatore dello script che compare in Known.
// Scanner minimale sugli identificatori Firebird: NON interpreta l'SQL, quindi
// intercetta anche le tabelle citate in JOIN, sottoquery, EXISTS e IN — che e'
// esattamente lo scopo. Un falso accoppiamento (un alias di colonna omonimo di
// una tabella) rende la copertura piu' permissiva, mai piu' severa.
procedure CollectKnownTokens(const SQL: string; Known, Referenced: TStringList);
const
  Starters: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '_', '$'];
  Followers: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_', '$'];
var
  i, start, len: Integer;
  tok: string;
begin
  if SQL = '' then
    Exit;

  len := Length(SQL);
  i := 1;
  while i <= len do
  begin
    if CharInSet(SQL[i], Starters) then
    begin
      start := i;
      Inc(i);

      // il test di fine stringa e' PRIMA dell'indicizzazione: non si dipende
      // dalla valutazione a corto circuito ({$B} non e' garantito)
      while i <= len do
      begin
        if not CharInSet(SQL[i], Followers) then
          Break;
        Inc(i);
      end;

      tok := Copy(SQL, start, i - start);
      // Known e' ordinata e case-insensitive: IndexOf e' una ricerca binaria
      if Known.IndexOf(tok) >= 0 then
        Referenced.Add(tok);
    end
    else
      Inc(i);
  end;
end;

// Costruisce la closure di rimozione di un dominio obsoleto. Il dominio arriva
// come PARAMETRO e non come variabile del chiamante: in Delphi una anonymous
// method cattura la variabile, non il suo valore, per cui una closure creata
// dentro un ciclo su una variabile locale finirebbe per operare sull'ultimo
// elemento del ciclo.
function MakeDeleteDomainFix(sys: TzSystem; domain: TzDomain): TzFixAction;
begin
  Result := procedure
    var
      idx: Integer;
      nme: string;
    begin
      nme := domain.Name;
      idx := sys.zDataDictionary.IndexOf(nme);
      if idx < 0 then
        Exit;

      sys.zDataDictionary.Delete(idx);
      sys.SaveZip(csDataDictionary, 'AutoFix: rimozione dominio obsoleto ' + nme);
    end;
end;

// (B) Copertura applicativa delle tabelle: tabelle fisiche su cui esistono
// domini ma che nessun DataSet / lookup / stored procedure dell'LZ tocca.
// [INFO]
//
// PERCHE' SOLO INFO: zDataDictionary e' il catalogo COMPLETO dello schema —
// BASE.DATA_DICTIONARY enumera ogni campo di ogni tabella, vista e parametro di
// output di ogni stored procedure. L'insieme dei dataset e' per costruzione un
// sottoinsieme: il disallineamento non e' un difetto dei metadati ma la misura
// di quanta parte del database l'interfaccia non copre. Le tabelle usate solo da
// trigger, stored procedure o report ricadono qui legittimamente.
//
// Rispetto alla versione precedente cambiano tre cose:
// 1. si confrontano solo le TABELLE fisiche (un dominio su vista o su output di
//    SP e' derivato: nessun dataset avra' mai quel nome in TableName);
// 2. l'insieme "usato" comprende TUTTE le tabelle citate negli script, non solo
//    ds.TableName, che contiene la sola relazione base aggiornabile;
// 3. si emette UN risultato per relazione, non uno per campo.
function TzSystemVerifier.VerifyDomainCoverage(const Total: Integer; var Done: Integer): Boolean;
var
  i, idx: Integer;
  ds: TzDataSet;
  lk: TzLookup;
  domain: TzDomain;
  tables: TStringList; // tabelle fisiche note (cache del verifier)
  referenced: TStringList; // tabelle toccate da qualunque oggetto dell'LZ
  orphans: TStringList; // relazione -> conteggio domini (in Objects[])
  relName: string;

  procedure AddIfKnown(const Name: string);
  begin
    if (Trim(Name) <> '') and (tables.IndexOf(Trim(Name)) >= 0) then
      referenced.Add(Trim(Name));
  end;

begin
  Result := True;
  tables := KnownTables;

  referenced := TStringList.Create;
  orphans := TStringList.Create;
  try
    referenced.CaseSensitive := False;
    referenced.Sorted := True;
    referenced.Duplicates := dupIgnore;

    orphans.CaseSensitive := False;
    orphans.Sorted := True;
    orphans.Duplicates := dupIgnore;

    // --- 1) tutte le tabelle che l'applicazione tocca ---------------------
    for i := 0 to FzSystem.zDataSets.Count - 1 do
    begin
      ds := FzSystem.zDataSets[i];
      AddIfKnown(ds.TableName);
      CollectKnownTokens(ds.SQL_Select.Text, tables, referenced);
      CollectKnownTokens(ds.SQL_Insert.Text, tables, referenced);
      CollectKnownTokens(ds.SQL_Update.Text, tables, referenced);
      CollectKnownTokens(ds.SQL_Delete.Text, tables, referenced);
      CollectKnownTokens(ds.SQL_Refresh.Text, tables, referenced);
    end;

    // i lookup portano la propria tabella e quella puntata dalla FK
    for i := 0 to FzSystem.zLookups.Count - 1 do
    begin
      lk := FzSystem.zLookups[i];
      AddIfKnown(lk.TableName);
      AddIfKnown(lk.TableNameFK);
    end;

    // una stored procedure dell'LZ puo' essere l'unico accesso a una tabella
    for i := 0 to FzSystem.zStoredProcs.Count - 1 do
      CollectKnownTokens(FzSystem.zStoredProcs[i].SQL.Text, tables, referenced);

    // --- 2) raccolta per RELAZIONE, non per campo ------------------------
    for i := 0 to FzSystem.zDataDictionary.Count - 1 do
    begin
      domain := FzSystem.zDataDictionary[i];

      Inc(Done);
      if not Progress(Done, Total, 'Copertura DataSet: ' + domain.Name) then
        Exit(False);

      // i calcolati non hanno una tabella fisica
      if domain.Calculated then
        Continue;

      // i domini obsoleti sono competenza di VerifyDomainExists
      if not domain.Exists then
        Continue;

      relName := Trim(domain.TableName);
      if relName = '' then
        Continue;

      // solo tabelle fisiche: viste e SP selezionabili sono escluse
      if tables.IndexOf(relName) < 0 then
        Continue;

      if IsFrameworkRelation(relName) then
        Continue;

      if referenced.IndexOf(relName) >= 0 then
        Continue;

      idx := orphans.IndexOf(relName);
      if idx < 0 then
        orphans.AddObject(relName, TObject(NativeInt(1)))
      else
        orphans.Objects[idx] := TObject(NativeInt(orphans.Objects[idx]) + 1);
    end;

    // --- 3) un solo risultato per relazione ------------------------------
    for i := 0 to orphans.Count - 1 do
      if not Emit(vsInfo, vcDomainCoverage, orphans[i], 'TableName', Format('Tabella non usata da alcun DataSet, lookup o stored procedure dell''LZ (%d domini definiti)', [NativeInt(orphans.Objects[i])]), nil) then
        Exit(False);
  finally
    orphans.Free;
    referenced.Free;
  end;
end;

class function TzSystemVerifier.CollectObsoleteDomains(azSystem: TzSystem; Unused, StillUsed: TStrings): Integer;
var
  used: TStringList;
  i, j: Integer;
  domain: TzDomain;

  procedure AddOrigin(const Origin: string);
  begin
    if Trim(Origin) <> '' then
      used.Add(Trim(Origin));
  end;

begin
  Result := 0;

  if not Assigned(azSystem) then
    Exit;

  used := TStringList.Create;
  try
    used.CaseSensitive := False;
    used.Sorted := True;
    used.Duplicates := dupIgnore;

    // FieldOrigin e' il riferimento PERSISTITO al dominio (Domain e' solo il
    // puntatore risolto a runtime da UpdateStructure): e' quello che stabilisce
    // se un dominio morto e' ancora in uso da qualche parte.
    for i := 0 to azSystem.zDbViews.Count - 1 do
      for j := 0 to azSystem.zDbViews[i].Columns.Count - 1 do
        AddOrigin(azSystem.zDbViews[i].Columns[j].FieldOrigin);

    for i := 0 to azSystem.zDbCards.Count - 1 do
      for j := 0 to azSystem.zDbCards[i].Controls.Count - 1 do
        AddOrigin(azSystem.zDbCards[i].Controls[j].FieldOrigin);

    for i := 0 to azSystem.zDbPivots.Count - 1 do
      for j := 0 to azSystem.zDbPivots[i].Fields.Count - 1 do
        AddOrigin(azSystem.zDbPivots[i].Fields[j].FieldOrigin);

    // Senza questo ciclo un dominio usato solo da una vista record
    // risulterebbe inutilizzato e verrebbe proposto per la cancellazione
    for i := 0 to azSystem.zDbRecordViews.Count - 1 do
      for j := 0 to azSystem.zDbRecordViews[i].Rows.Count - 1 do
        AddOrigin(azSystem.zDbRecordViews[i].Rows[j].FieldOrigin);

    for i := 0 to azSystem.zDbTrees.Count - 1 do
      for j := 0 to azSystem.zDbTrees[i].Columns.Count - 1 do
        AddOrigin(azSystem.zDbTrees[i].Columns[j].FieldOrigin);

    for i := 0 to azSystem.zDbCharts.Count - 1 do
      for j := 0 to azSystem.zDbCharts[i].Series.Count - 1 do
        AddOrigin(azSystem.zDbCharts[i].Series[j].FieldOrigin);

    for i := 0 to azSystem.zDataDictionary.Count - 1 do
    begin
      domain := azSystem.zDataDictionary[i];

      if domain.Exists then
        Continue;

      Inc(Result);

      if used.IndexOf(domain.Name) >= 0 then
      begin
        if Assigned(StillUsed) then
          StillUsed.Add(domain.Name);
      end
      else
        if Assigned(Unused) then
          Unused.Add(domain.Name);
    end;
  finally
    used.Free;
  end;
end;

// (B2) Domini obsoleti: InitDataDictionary azzera Exists e lo riaccende solo
// per i campi trovati nel DB, ma — a differenza di DeleteNonExistentLookups per
// i lookup — non elimina mai i rimanenti. Restano quindi nell'LZ domini che
// puntano a campi cancellati dal database.
//
// vsError   se una DbView/DbCard/DbPivot li usa ancora (a runtime la colonna o
//           il controllo non trovera' il campo);
// vsWarning se sono solo zavorra, con rimozione SUGGERITA (mai fkSafe: e'
//           distruttiva; in blocco si usa il comando dedicato della form).
function TzSystemVerifier.VerifyDomainExists(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  domain: TzDomain;
  stillUsed: TStringList;
  sys: TzSystem;
begin
  Result := True;
  sys := FzSystem;

  stillUsed := TStringList.Create;
  try
    stillUsed.CaseSensitive := False;
    stillUsed.Sorted := True;
    stillUsed.Duplicates := dupIgnore;
    CollectObsoleteDomains(FzSystem, nil, stillUsed);

    for i := 0 to FzSystem.zDataDictionary.Count - 1 do
    begin
      domain := FzSystem.zDataDictionary[i];

      Inc(Done);
      if not Progress(Done, Total, 'Domini obsoleti: ' + domain.Name) then
        Exit(False);

      if domain.Exists then
        Continue;

      if stillUsed.IndexOf(domain.Name) >= 0 then
      begin
        if not Emit(vsError, vcDomainExists, domain.Name, 'Exists', Format('Il campo "%s"."%s" non esiste piu'' nel database ma e'' ancora usato da una DbView/DbCard/DbPivot', [domain.TableName, domain.FieldName]), domain) then
          Exit(False);
      end
      else
        if not EmitFix(vsWarning, vcDomainExists, domain.Name, 'Exists', Format('Dominio non piu'' presente nel database ("%s"."%s"): nessuna DbView/DbCard/DbPivot lo usa', [domain.TableName, domain.FieldName]), domain, fkSuggested,
          Format('Rimuovere il dominio "%s" dal file LZ', [domain.Name]), MakeDeleteDomainFix(sys, domain)) then
          Exit(False);
    end;
  finally
    stillUsed.Free;
  end;
end;

// (C) Auto-SQL vs SQL manuale: AutoSQL_x = False ma script x vuoto -> nessuna
// persistenza possibile su quel verbo.  [WARNING]
//
// Voce R-044 - 2026-10-09: anche il caso opposto, AutoSQL_Update = True con
// SQL_Update vuoto su una vista senza trigger di aggiornamento. zSqlLib.IsSqlAllowed
// lascia vuota l'istruzione, e se una DbView o una DbCard permette la modifica
// l'UPDATE lo compone FireDAC, che qualifica le colonne con il nome della vista
// su una tabella sottostante: errore -206 "Column unknown" al salvataggio
// (Mantis Gesty #205, Orario.Orario_Files_Lezioni). Segnalato solo quando
// qualcosa permette davvero di modificare, perche' una vista di sola lettura
// su una vista non aggiornabile e' il caso normale.  [WARNING]
function TzSystemVerifier.VerifyAutoSql(const Total: Integer; var Done: Integer): Boolean;
var
  i, idxView: Integer;
  ds: TzDataSet;
  dv: TzDbViewProps;
  dc: TzDbCardProps;
  // dataset (maiuscolo) -> controlli che lo modificano, separati da virgola
  editors: TDictionary<string, string>;
  editorNames: string;

  procedure AddEditor(const DataSetName, EditorName: string);
  var
    key, current: string;
  begin
    key := AnsiUpperCase(Trim(DataSetName));
    if key = '' then
      Exit;
    if editors.TryGetValue(key, current) then
      editors[key] := current + ', ' + EditorName
    else
      editors.Add(key, EditorName);
  end;

  function Check(const Auto: Boolean; const Script, Verb: string): Boolean;
  begin
    Result := True;
    if (not Auto) and (Trim(Script) = '') then
      Result := Emit(vsWarning, vcAutoSql, ds.Name, Verb, Format('AutoSQL_%s=False ma SQL_%s vuoto: nessuna persistenza su %s', [Verb, Verb, Verb]), ds);
  end;

begin
  Result := True;
  editors := TDictionary<string, string>.Create;
  try
    // griglia: modifica col pulsante o direttamente nelle celle
    for i := 0 to FzSystem.zDbViews.Count - 1 do
    begin
      dv := FzSystem.zDbViews[i];
      if (not dv.Flags.Readonly) and (dv.Flags.ButtonUpdate or dv.Flags.Editing) then
        AddEditor(dv.DataSet, 'DbView ' + dv.Name);
    end;
    // scheda: con AutoEdit si modifica appena si scrive, basta che non sia di sola lettura
    for i := 0 to FzSystem.zDbCards.Count - 1 do
    begin
      dc := FzSystem.zDbCards[i];
      if (not dc.Flags.Readonly) and (dc.Flags.ButtonUpdate or dc.Flags.AutoEdit) then
        AddEditor(dc.DataSet, 'DbCard ' + dc.Name);
    end;

    for i := 0 to FzSystem.zDataSets.Count - 1 do
    begin
      ds := FzSystem.zDataSets[i];
      Inc(Done);
      if not Progress(Done, Total, 'AutoSQL: ' + ds.Name) then
        Exit(False);

      if not Check(ds.AutoSQL_Insert, ds.SQL_Insert.Text, 'Insert') then
        Exit(False);
      if not Check(ds.AutoSQL_Update, ds.SQL_Update.Text, 'Update') then
        Exit(False);
      if not Check(ds.AutoSQL_Delete, ds.SQL_Delete.Text, 'Delete') then
        Exit(False);
      if not Check(ds.AutoSQL_Refresh, ds.SQL_Refresh.Text, 'Refresh') then
        Exit(False);

      // vista senza trigger di aggiornamento, modificabile da griglia o scheda
      if ds.AutoSQL_Update and (Trim(ds.SQL_Update.Text) = '') and (Trim(ds.TableName) <> '')
        and Assigned(FzSystem.MetaData) then
      begin
        idxView := FzSystem.MetaData.Views.IndexOf(Trim(ds.TableName));
        if (idxView >= 0) and not FzSystem.MetaData.Views[idxView].HasTriggerUpdate
          and editors.TryGetValue(AnsiUpperCase(Trim(ds.Name)), editorNames) then
          if not Emit(vsWarning, vcAutoSql, ds.Name, 'Update', Format('TableName %s e'' una vista senza trigger di ' +
            'aggiornamento: con AutoSQL_Update e SQL_Update vuoto l''UPDATE lo compone FireDAC e il salvataggio fallisce ' +
            '(-206 Column unknown). Modificabile da: %s. Rendere sola lettura oppure aggiungere il trigger alla vista e ' +
            'una SQL_Update esplicita', [Trim(ds.TableName), editorNames]), ds) then
            Exit(False);
      end;
    end;
  finally
    editors.Free;
  end;
end;

// (D) Lookup self-consistency: FieldNames vs FieldNamesFK con cardinalità
// diversa (mapping master/FK sbilanciato).  [WARNING]
function TzSystemVerifier.VerifyLookupCardinality(const Total: Integer; var Done: Integer): Boolean;
var
  i, nFK, nMaster: Integer;
  lk: TzLookup;
begin
  Result := True;
  for i := 0 to FzSystem.zLookups.Count - 1 do
  begin
    lk := FzSystem.zLookups[i];
    Inc(Done);
    if not Progress(Done, Total, 'Cardinality: ' + lk.Name) then
      Exit(False);

    nFK := CountTokens(lk.FieldNamesFK);
    nMaster := CountTokens(lk.FieldNames);

    // confronto solo se entrambi valorizzati (FieldNamesFK vuoto è già un
    // errore gestito dal controllo 3)
    if (nFK > 0) and (nMaster > 0) and (nFK <> nMaster) then
      if not Emit(vsWarning, vcLookupCardinality, lk.Name, 'FieldNames/FieldNamesFK', Format('Cardinalità sbilanciata: FieldNames=%d campi, FieldNamesFK=%d campi', [nMaster, nFK]), lk) then
        Exit(False);
  end;
end;

// (E) Duplicati: nomi duplicati nelle collection principali.  [WARNING]
function TzSystemVerifier.VerifyDuplicates(const Total: Integer; var Done: Integer): Boolean;

  function ScanCollection(const Label_: string; get: TFunc<Integer, TzCollectionItem>; Count: Integer): Boolean;
  var
    seen: TStringList;
    j: Integer;
    it: TzCollectionItem;
  begin
    Result := True;
    seen := TStringList.Create;
    try
      seen.Sorted := True;
      seen.CaseSensitive := False;
      for j := 0 to Count - 1 do
      begin
        it := get(j);
        Inc(Done);
        if not Progress(Done, Total, 'Duplicati ' + Label_ + ': ' + it.Name) then
          Exit(False);
        if seen.IndexOf(it.Name) >= 0 then
        begin
          if not Emit(vsWarning, vcDuplicate, it.Name, Label_, Format('Nome duplicato nella collection %s', [Label_]), it) then
            Exit(False);
        end
        else
          seen.Add(it.Name);
      end;
    finally
      seen.Free;
    end;
  end;

begin
  Result := True;
  if not ScanCollection('DataSets',
    function(k: Integer): TzCollectionItem
    begin
      Result := FzSystem.zDataSets[k];
    end, FzSystem.zDataSets.Count) then
    Exit(False);
  if not ScanCollection('Lookups',
    function(k: Integer): TzCollectionItem
    begin
      Result := FzSystem.zLookups[k];
    end, FzSystem.zLookups.Count) then
    Exit(False);
  if not ScanCollection('DataDictionary',
    function(k: Integer): TzCollectionItem
    begin
      Result := FzSystem.zDataDictionary[k];
    end, FzSystem.zDataDictionary.Count) then
    Exit(False);
end;

// Costruisce la closure che assegna al dataset il generatore della sua tabella.
// Come per MakeDeleteDomainFix dataset e generatore arrivano come PARAMETRI:
// catturare le variabili del ciclo farebbe operare tutte le closure
// sull'ultimo dataset esaminato.
function MakeGeneratorFix(sys: TzSystem; ds: TzDataSet; const GeneratorName: string): TzFixAction;
begin
  Result := procedure
    begin
      ds.Generator := GeneratorName;
      sys.SaveZip(csDataSets, 'AutoFix: Generator ' + ds.Name + ' = ' + GeneratorName);
    end;
end;

// (F) Generatori  [ERROR / WARNING]
// Mantis #4760 #6934 - 2026-10-26: il dataset riceve chiave auto-incrementale
// e generatore (TzSystem.DataSetLoadProps) solo se Generator e' una voce di
// zGenerators con Exists. Altrimenti la chiave resta vuota e l'inserimento si
// ferma su "i campi seguenti devono avere un valore". Tre casi:
// - Generator non in zGenerators e la tabella del dataset ha UN generatore
// esistente registrato in zGenerators: e' il difetto dei ticket (segnaposto
// GEN__ID mai sostituito), ERROR con il generatore della tabella proposto;
// - Generator non in zGenerators e nessun generatore certo per la tabella
// (nessuno, o piu' d'uno): WARNING come prima, quasi sempre tabelle a chiave
// naturale dove il segnaposto e' innocuo;
// - Generator in zGenerators ma con Exists = False: il generatore non esiste
// nel database (secondo l'ultimo allineamento dei metadati), WARNING.
function TzSystemVerifier.VerifyGenerators(const Total: Integer; var Done: Integer): Boolean;
var
  i, g: Integer;
  ds: TzDataSet;
  Generatore: TzGenerator;
  GeneratoreTabella: TzGenerator;
  CandidatiTabella: Integer;
  sys: TzSystem;
begin
  Result := True;
  sys := FzSystem;
  for i := 0 to FzSystem.zDataSets.Count - 1 do
  begin
    ds := FzSystem.zDataSets[i];
    Inc(Done);
    if not Progress(Done, Total, 'Generator: ' + ds.Name) then
      Exit(False);

    if Trim(ds.Generator) = '' then
      Continue;

    Generatore := ds.Generator_Obj;

    if Assigned(Generatore) then
    begin
      if not Generatore.Exists then
        if not Emit(vsWarning, vcGenerator, ds.Name, 'Generator', Format('Generatore "%s" registrato in zGenerators ma non presente nel database (Exists = False): la chiave del dataset non viene generata', [ds.Generator]), ds) then
          Exit(False);
      Continue;
    end;

    // Generatore non registrato: si cerca quello della tabella del dataset.
    // Solo generatori esistenti e con il campo chiave, gli stessi che
    // DataSetLoadProps userebbe; con piu' candidati non si propone nulla.
    GeneratoreTabella := nil;
    CandidatiTabella := 0;
    if Trim(ds.TableName) <> '' then
      for g := 0 to FzSystem.zGenerators.Count - 1 do
        if SameText(Trim(FzSystem.zGenerators[g].TableName), Trim(ds.TableName)) and FzSystem.zGenerators[g].Exists and (Trim(FzSystem.zGenerators[g].FieldName) <> '') then
        begin
          Inc(CandidatiTabella);
          GeneratoreTabella := FzSystem.zGenerators[g];
        end;

    if CandidatiTabella = 1 then
    begin
      // fkSuggested: il generatore della tabella e' quasi sempre quello giusto,
      // ma va confrontato con il trigger BEFORE INSERT prima di applicarlo
      if not EmitFix(vsError, vcGenerator, ds.Name, 'Generator',
        Format('Generatore "%s" inesistente, ma la tabella %s ha il generatore "%s" (campo %s): la chiave resta vuota in inserimento', [ds.Generator, ds.TableName, GeneratoreTabella.GeneratorName, GeneratoreTabella.FieldName]),
        ds, fkSuggested, Format('Impostare Generator = "%s" (verificare che sia quello del trigger BEFORE INSERT di %s)', [GeneratoreTabella.GeneratorName, ds.TableName]),
        MakeGeneratorFix(sys, ds, GeneratoreTabella.GeneratorName)) then
        Exit(False);
    end
    else
      // NIENTE auto-fix: l'assenza in zGenerators può riflettere un generatore
      // mancante nel DB Firebird, non solo nei metadati. Creare una voce LZ
      // maschererebbe il problema senza creare il generatore reale, e il valore
      // iniziale della sequenza è una decisione di dominio. Solo evidenziazione.
      if not Emit(vsWarning, vcGenerator, ds.Name, 'Generator', Format('Generatore "%s" non presente in zGenerators', [ds.Generator]), ds) then
        Exit(False);
  end;
end;

// Costruisce la closure di normalizzazione dei separatori. Come per
// MakeDeleteDomainFix il lookup arriva come PARAMETRO: catturare la variabile
// del ciclo significherebbe creare N closure che operano tutte sull'ultimo
// lookup esaminato.
function MakeFieldNamesFKFix(sys: TzSystem; lk: TzLookup): TzFixAction;
begin
  Result := procedure
    begin
      lk.FieldNamesFK := StringReplace(lk.FieldNamesFK, ',', ';', [rfReplaceAll]);
      sys.SaveZip(csLookups, 'AutoFix: FieldNamesFK separatori ' + lk.Name);
    end;
end;

// (G) Separatori: FieldNamesFK con virgole invece di ';' (FieldNamesFK NON è
// normalizzato dal setter, a differenza di KeyField/DisplayColumns).
// fkSafe: la sostituzione ','->';' non perde informazione.  [WARNING]
function TzSystemVerifier.VerifySeparators(const Total: Integer; var Done: Integer): Boolean;
var
  i: Integer;
  lk: TzLookup;
  sys: TzSystem;
begin
  Result := True;
  sys := FzSystem;
  for i := 0 to FzSystem.zLookups.Count - 1 do
  begin
    lk := FzSystem.zLookups[i];
    Inc(Done);
    if not Progress(Done, Total, 'Separatori: ' + lk.Name) then
      Exit(False);

    if Pos(',', lk.FieldNamesFK) > 0 then
      if not EmitFix(vsWarning, vcLookupFieldsFK, lk.Name, 'FieldNamesFK', 'FieldNamesFK usa la virgola come separatore invece di '';''', lk, fkSafe, Format('Sostituire '','' con '';'' in FieldNamesFK ("%s")', [lk.FieldNamesFK]), MakeFieldNamesFKFix(sys, lk)) then
        Exit(False);
  end;
end;

// helper di confronto campi lookup vs FieldDefs (Prepare, mai Open)
function TzSystemVerifier.VerifyLookupFieldsExist(lk: TzLookup; dsObj: TzDataSet): Boolean;
var
  defNames: TStringList;

  // confronta una lista ';'-separata di campi contro i campi cache-ati; emette
  // warning per ciascun campo mancante. SubItem identifica la proprietà.
  function CheckList(const fields, SubItem: string): Boolean;
  var
    parts: TArray<string>;
    p, fname: string;
  begin
    Result := True;
    if Trim(fields) = '' then
      Exit;
    parts := fields.Split([';']);
    for p in parts do
    begin
      fname := Trim(p);
      if fname = '' then
        Continue;
      if defNames.IndexOf(fname) < 0 then
        if not Emit(vsWarning, vcLookupFieldExist, lk.Name, SubItem, Format('Campo "%s" non presente nei campi prodotti dal SELECT del dataset "%s"', [fname, dsObj.Name]), lk) then
          Exit(False);
    end;
  end;

begin
  Result := True;

  // Riusa la cache popolata da VerifyDataSets: NESSUN Prepare aggiuntivo.
  defNames := GetDataSetFields(dsObj);

  // lista vuota = SELECT vuoto o non preparabile: lo segnala già il flusso
  // SQL/lookup. Qui non possiamo confrontare i campi: usciamo senza rumore.
  if (defNames = nil) or (defNames.Count = 0) then
    Exit;

  if not CheckList(lk.FieldNamesFK, 'FieldNamesFK') then
    Exit(False);
  if not CheckList(lk.KeyField, 'KeyField') then
    Exit(False);
  if not CheckList(lk.DisplayColumns, 'DisplayColumns') then
    Exit(False);
end;

{ TzSqlSelectShape }

constructor TzSqlSelectShape.Create;
begin
  inherited Create;
  Columns := TList<TzSqlSelectColumn>.Create;
  Relations := TStringList.Create;
  RelationNames := TStringList.Create;
  WhereWords := TStringList.Create;
  WhereWords.Sorted := True;
  WhereWords.Duplicates := dupIgnore;
  OrderByWords := TStringList.Create;
  Complete := True;
end;

destructor TzSqlSelectShape.Destroy;
begin
  OrderByWords.Free;
  WhereWords.Free;
  RelationNames.Free;
  Relations.Free;
  Columns.Free;
  inherited;
end;

function TzSqlSelectShape.RelationOf(const Name: string): string;
begin
  Result := Relations.Values[UpperCase(Name)];
  if Result = '' then
    Result := UpperCase(Name);
end;

function TzSqlSelectShape.FindColumn(const Name: string; out Column: TzSqlSelectColumn): Boolean;
var
  Candidate: TzSqlSelectColumn;
begin
  for Candidate in Columns do
    if SameText(Candidate.Name, Name) then
    begin
      Column := Candidate;
      Exit(True);
    end;
  Column := Default (TzSqlSelectColumn);
  Result := False;
end;

// Divide la SQL in parole (maiuscole), apici (una stringa diventa il solo '),
// parametri (:NOME) e simboli di un carattere, '||' a parte. Salta i commenti.
function TokenizeSql(const SQL: string): TArray<string>;
const
  Starters: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_', '$'];
  Followers: TSysCharSet = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_', '$', '#'];
var
  Tokens: TList<string>;
  Index, Start, Size: Integer;
begin
  Tokens := TList<string>.Create;
  try
    Size := Length(SQL);
    Index := 1;
    while Index <= Size do
    begin
      if SQL[Index] = '''' then
      begin
        Inc(Index);
        while Index <= Size do
          if SQL[Index] = '''' then
          begin
            if (Index < Size) and (SQL[Index + 1] = '''') then
              Inc(Index, 2)
            else
              Break;
          end
          else
            Inc(Index);
        Inc(Index);
        Tokens.Add('''');
      end
      else if SQL[Index] = '"' then
      begin
        Inc(Index);
        Start := Index;
        while (Index <= Size) and (SQL[Index] <> '"') do
          Inc(Index);
        Tokens.Add(UpperCase(Copy(SQL, Start, Index - Start)));
        Inc(Index);
      end
      else if (SQL[Index] = '-') and (Index < Size) and (SQL[Index + 1] = '-') then
      begin
        while (Index <= Size) and not CharInSet(SQL[Index], [#10, #13]) do
          Inc(Index);
      end
      else if (SQL[Index] = '/') and (Index < Size) and (SQL[Index + 1] = '*') then
      begin
        Inc(Index, 2);
        while (Index < Size) and not((SQL[Index] = '*') and (SQL[Index + 1] = '/')) do
          Inc(Index);
        Inc(Index, 2);
      end
      else if (SQL[Index] = '|') and (Index < Size) and (SQL[Index + 1] = '|') then
      begin
        Tokens.Add('||');
        Inc(Index, 2);
      end
      else if SQL[Index] = ':' then
      begin
        Start := Index;
        Inc(Index);
        while Index <= Size do
        begin
          if not CharInSet(SQL[Index], Followers) then
            Break;
          Inc(Index);
        end;
        Tokens.Add(UpperCase(Copy(SQL, Start, Index - Start)));
      end
      else if CharInSet(SQL[Index], Starters) then
      begin
        Start := Index;
        while Index <= Size do
        begin
          if not CharInSet(SQL[Index], Followers) then
            Break;
          Inc(Index);
        end;
        Tokens.Add(UpperCase(Copy(SQL, Start, Index - Start)));
      end
      else if CharInSet(SQL[Index], [#9, #10, #13, ' ']) then
        Inc(Index)
      else
      begin
        Tokens.Add(SQL[Index]);
        Inc(Index);
      end;
    end;
    Result := Tokens.ToArray;
  finally
    Tokens.Free;
  end;
end;

function IsSqlWord(const Token: string): Boolean;
begin
  Result := (Token <> '') and CharInSet(Token[1], ['A' .. 'Z', '_', '$']);
end;

class function TzSqlSelectShape.Parse(const SQL: string): TzSqlSelectShape;
type
  TSection = (sNone, sFrom, sWhere);
var
  Tokens: TArray<string>;
  Position, Count, Depth, ItemStart: Integer;
  Section: TSection;
  ExpectRelation: Boolean;
  Shape: TzSqlSelectShape;

  function TokenAt(const Index: Integer): string;
  begin
    if (Index >= 0) and (Index < Count) then
      Result := Tokens[Index]
    else
      Result := '';
  end;

  // Dalla parentesi aperta in Index alla posizione dopo quella che la chiude
  function SkipParenthesis(Index: Integer): Integer;
  var
    Level: Integer;
  begin
    Level := 0;
    while Index < Count do
    begin
      if Tokens[Index] = '(' then
        Inc(Level)
      else if Tokens[Index] = ')' then
      begin
        Dec(Level);
        if Level = 0 then
          Exit(Index + 1);
      end;
      Inc(Index);
    end;
    Result := Count;
  end;

  function IsFromKeyword(const Token: string): Boolean;
  const
    Keywords: array [0 .. 15] of string = ('INNER', 'LEFT', 'RIGHT', 'FULL', 'CROSS', 'NATURAL', 'OUTER', 'JOIN', 'ON', 'USING', 'WHERE', 'GROUP', 'HAVING', 'ORDER', 'UNION', 'PLAN');
  var
    Keyword: string;
  begin
    for Keyword in Keywords do
      if Keyword = Token then
        Exit(True);
    Result := False;
  end;

  procedure AddRelationName(const Name, Relation: string);
  begin
    Shape.Relations.Values[Name] := Relation;
  end;

  procedure AddItem(const First, Last: Integer);
  var
    Column: TzSqlSelectColumn;
    Alias: string;
    ExpressionLast, Index: Integer;
  begin
    if Last < First then
      Exit;

    Column := Default (TzSqlSelectColumn);

    // SELECT * e TABELLA.*: li espande chi conosce i campi delle relazioni
    if (First = Last) and (Tokens[First] = '*') then
    begin
      Column.Name := '*';
      Shape.Columns.Add(Column);
      Exit;
    end;
    if (Last = First + 2) and (Tokens[First + 1] = '.') and (Tokens[Last] = '*') then
    begin
      Column.Name := '*';
      Column.Relation := Tokens[First];
      Shape.Columns.Add(Column);
      Exit;
    end;

    Alias := '';
    ExpressionLast := Last;
    if (Last >= First + 2) and (Tokens[Last - 1] = 'AS') then
    begin
      Alias := Tokens[Last];
      ExpressionLast := Last - 2;
    end
    else if (Last > First) and IsSqlWord(Tokens[Last]) and (Tokens[Last] <> 'END') and (IsSqlWord(Tokens[Last - 1]) or (Tokens[Last - 1] = ')') or (Tokens[Last - 1] = '''')) then
    begin
      Alias := Tokens[Last];
      ExpressionLast := Last - 1;
    end;

    if (ExpressionLast = First) and IsSqlWord(Tokens[First]) then
      Column.FieldName := Tokens[First]
    else if (ExpressionLast = First + 2) and (Tokens[First + 1] = '.') then
    begin
      Column.Relation := Tokens[First];
      Column.FieldName := Tokens[ExpressionLast];
    end
    else
      for Index := First to ExpressionLast do
        if (Tokens[Index] = '||') or (Tokens[Index] = '''') then
          Column.IsTextExpression := True;

    if Alias <> '' then
      Column.Name := Alias
    else
      Column.Name := Column.FieldName;

    Shape.Columns.Add(Column);
  end;

  procedure ReadOrderBy(Index: Integer);
  var
    Level: Integer;
  begin
    Level := 0;
    while Index < Count do
    begin
      if Tokens[Index] = '(' then
        Inc(Level)
      else if Tokens[Index] = ')' then
        Dec(Level)
      else if (Level = 0) and ((Tokens[Index] = ',') or (Tokens[Index] = 'ASC') or (Tokens[Index] = 'DESC') or (Tokens[Index] = 'ASCENDING') or (Tokens[Index] = 'DESCENDING') or (Tokens[Index] = 'NULLS') or (Tokens[Index] = 'COLLATE') or (Tokens[Index] = 'ROWS')) then
        Break
      else if IsSqlWord(Tokens[Index]) then
        Shape.OrderByWords.Add(Tokens[Index])
      else if (Shape.OrderByWords.Count = 0) and (Shape.OrderByPosition = 0) then
        Shape.OrderByPosition := StrToIntDef(Tokens[Index], 0);
      Inc(Index);
    end;
  end;

begin
  Shape := TzSqlSelectShape.Create;
  Result := Shape;

  Tokens := TokenizeSql(SQL);
  Count := Length(Tokens);

  // primo SELECT fuori dalle parentesi: salta un eventuale WITH
  Position := 0;
  Depth := 0;
  while Position < Count do
  begin
    if Tokens[Position] = '(' then
      Inc(Depth)
    else if Tokens[Position] = ')' then
      Dec(Depth)
    else if (Depth = 0) and (Tokens[Position] = 'SELECT') then
      Break;
    Inc(Position);
  end;
  if Position >= Count then
  begin
    Shape.Complete := False;
    Exit;
  end;
  Inc(Position);

  // FIRST, SKIP e DISTINCT stanno prima dell'elenco delle colonne
  while Position < Count do
    if Tokens[Position] = 'DISTINCT' then
    begin
      Shape.NoRepeatedRows := True;
      Inc(Position);
    end
    else if Tokens[Position] = 'ALL' then
      Inc(Position)
    else if (Tokens[Position] = 'FIRST') or (Tokens[Position] = 'SKIP') then
    begin
      if TokenAt(Position + 1) = '(' then
        Position := SkipParenthesis(Position + 1)
      else
        Inc(Position, 2);
    end
    else
      Break;

  // elenco delle colonne fino al FROM principale
  ItemStart := Position;
  Depth := 0;
  while Position < Count do
  begin
    if Tokens[Position] = '(' then
      Inc(Depth)
    else if Tokens[Position] = ')' then
      Dec(Depth)
    else if Depth = 0 then
      if Tokens[Position] = ',' then
      begin
        AddItem(ItemStart, Position - 1);
        ItemStart := Position + 1;
      end
      else if Tokens[Position] = 'FROM' then
        Break;
    Inc(Position);
  end;
  AddItem(ItemStart, Position - 1);

  // relazioni, WHERE e ORDER BY del blocco principale
  Section := sFrom;
  ExpectRelation := True;
  Inc(Position);
  Depth := 0;
  while Position < Count do
  begin
    if (Section = sFrom) and (Tokens[Position] = '(') then
    begin
      // tabella derivata se la relazione e' attesa, altrimenti una condizione
      if ExpectRelation then
      begin
        Shape.Complete := False;
        ExpectRelation := False;
      end;
      Position := SkipParenthesis(Position);
      Continue;
    end;

    if Tokens[Position] = '(' then
      Inc(Depth)
    else if Tokens[Position] = ')' then
      Dec(Depth)
    else if Depth = 0 then
    begin
      if Tokens[Position] = 'WHERE' then
      begin
        Section := sWhere;
        Inc(Position);
        Continue;
      end;
      if Tokens[Position] = 'GROUP' then
      begin
        Shape.NoRepeatedRows := True;
        Section := sNone;
      end
      else if (Tokens[Position] = 'HAVING') or (Tokens[Position] = 'UNION') or (Tokens[Position] = 'PLAN') then
        Section := sNone
      else if (Tokens[Position] = 'ORDER') and (TokenAt(Position + 1) = 'BY') then
      begin
        // con una UNION vale l'ultimo ORDER BY: si rilegge da capo
        Shape.OrderByWords.Clear;
        Shape.OrderByPosition := 0;
        ReadOrderBy(Position + 2);
        Section := sNone;
      end;
    end;

    case Section of
      sFrom:
        if (Tokens[Position] = 'JOIN') or (Tokens[Position] = ',') then
          ExpectRelation := True
        else if ExpectRelation and IsSqlWord(Tokens[Position]) then
        begin
          ExpectRelation := False;
          var
          Relation := Tokens[Position];
          Shape.RelationNames.Add(Relation);
          AddRelationName(Relation, Relation);

          // argomenti di una stored procedure selezionabile
          if TokenAt(Position + 1) = '(' then
            Position := SkipParenthesis(Position + 1) - 1;

          if TokenAt(Position + 1) = 'AS' then
          begin
            AddRelationName(TokenAt(Position + 2), Relation);
            Inc(Position, 2);
          end
          else if IsSqlWord(TokenAt(Position + 1)) and not IsFromKeyword(TokenAt(Position + 1)) then
          begin
            AddRelationName(TokenAt(Position + 1), Relation);
            Inc(Position);
          end;
        end;
      sWhere:
        if IsSqlWord(Tokens[Position]) then
          Shape.WhereWords.Add(Tokens[Position]);
    end;

    Inc(Position);
  end;
end;

// Divide i campi separati da ';' o ','. Le voci vuote si scartano.
procedure SplitFieldList(const Value: string; List: TStrings);
var
  Part: string;
begin
  for Part in Value.Split([';', ',']) do
    if Trim(Part) <> '' then
      List.Add(UpperCase(Trim(Part)));
end;

function IsNumericFieldType(const DataType: TFieldType): Boolean;
begin
  Result := DataType in [ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftShortint, ftByte, ftLongWord, ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftSingle, ftExtended];
end;

function IsTextFieldType(const DataType: TFieldType): Boolean;
begin
  Result := DataType in [ftString, ftWideString, ftFixedChar, ftFixedWideChar];
end;

// Campi che esistono per il programma, o sono codici, e non dicono a chi usa la
// tendina di che voce si tratta. Un lookup che ha solo questi non ha alternative
// all'id (ID_INCARICO): meglio tacere un caso che dare un falso allarme.
function IsServiceField(const FieldName: string): Boolean;
const
  Prefixes: array [0 .. 7] of string = ('USR_', 'ID_', 'CODICE', 'COD_', 'TIPO', 'STATO', 'FLAG', 'BELFIORE');
var
  Prefix: string;
begin
  for Prefix in Prefixes do
    if FieldName.StartsWith(Prefix) then
      Exit(True);
  Result := (FieldName = 'OID') or FieldName.EndsWith('_STR') or FieldName.EndsWith('_CODICE');
end;

// Un campo descrive la voce se il nome lo dice (NOMINATIVO, RAGIONE_SOCIALE...)
// o se ripete quello della chiave (ID_AULA, AULA). Un testo qualunque non basta:
// i lookup su ID_INCARICO hanno sedi e note, ma nessuna dice quale incarico sia.
function IsDescriptiveName(const FieldName, KeyName: string): Boolean;
const
  Words: array [0 .. 8] of string = ('NOMINATIVO', 'COGNOME', 'NOME', 'RAGIONE_SOCIALE', 'DENOMINAZIONE', 'DESCRIZIONE', 'DESC_', 'TITOLO', 'OGGETTO');
var
  Word, Stem: string;
begin
  if FieldName.Contains('AGGIUNTIV') then
    Exit(False);

  for Word in Words do
    if FieldName.Contains(Word) then
      Exit(True);

  Stem := KeyName;
  if Stem.StartsWith('ID_') then
    Stem := Stem.Substring(3);
  Result := (Stem <> '') and (Stem <> KeyName) and FieldName.Contains(Stem);
end;

function TzSystemVerifier.HasLookupDefinitionChecks: Boolean;
begin
  Result := FCheckLookupGridColumns or FCheckLookupParameters or FCheckLookupShowsKey or FCheckLookupSearchOnKey or FCheckLookupOrderBy or FCheckLookupColumnsExist or FCheckLookupCompositeKey;
end;

function TzSystemVerifier.CollectRelationFields(const RelationName: string; Fields: TStrings): Boolean;
var
  Index, FieldIndex: Integer;
  Known: TStringList;
begin
  Fields.Clear;

  if Assigned(FzSystem.MetaData) then
  begin
    Index := FzSystem.MetaData.Tables.IndexOf(RelationName);
    if Index >= 0 then
      for FieldIndex := 0 to FzSystem.MetaData.Tables[Index].Fields.Count - 1 do
        Fields.Add(UpperCase(FzSystem.MetaData.Tables[Index].Fields[FieldIndex].Name));

    if Fields.Count = 0 then
    begin
      Index := FzSystem.MetaData.Views.IndexOf(RelationName);
      if Index >= 0 then
        for FieldIndex := 0 to FzSystem.MetaData.Views[Index].Fields.Count - 1 do
          Fields.Add(UpperCase(FzSystem.MetaData.Views[Index].Fields[FieldIndex].Name));
    end;
  end;

  if Fields.Count = 0 then
  begin
    Known := RelationFields(RelationName);
    if Assigned(Known) then
      Fields.AddStrings(Known);
  end;

  Result := Fields.Count > 0;
end;

function TzSystemVerifier.SelectShapeOf(dsObj: TzDataSet): TzSqlSelectShape;
var
  Index: Integer;
  Star, Expanded: TzSqlSelectColumn;
  StarRelations, Fields: TStringList;
  Relation, FieldName: string;
begin
  if not Assigned(FSelectShapes) then
    FSelectShapes := TObjectDictionary<string, TzSqlSelectShape>.Create([doOwnsValues]);

  if FSelectShapes.TryGetValue(dsObj.Name, Result) then
    Exit;

  Result := TzSqlSelectShape.Parse(dsObj.SQL_Select.Text);
  FSelectShapes.Add(dsObj.Name, Result);

  StarRelations := TStringList.Create;
  Fields := TStringList.Create;
  try
    Index := 0;
    while Index < Result.Columns.Count do
    begin
      Star := Result.Columns[Index];
      if Star.Name <> '*' then
      begin
        Inc(Index);
        Continue;
      end;

      Result.Columns.Delete(Index);
      StarRelations.Clear;
      if Star.Relation <> '' then
        StarRelations.Add(Result.RelationOf(Star.Relation))
      else
        StarRelations.AddStrings(Result.RelationNames);

      for Relation in StarRelations do
      begin
        if not CollectRelationFields(Relation, Fields) then
        begin
          Result.Complete := False;
          Continue;
        end;
        for FieldName in Fields do
        begin
          Expanded := Default (TzSqlSelectColumn);
          Expanded.Name := FieldName;
          Expanded.FieldName := FieldName;
          Expanded.Relation := Relation;
          Result.Columns.Insert(Index, Expanded);
          Inc(Index);
        end;
      end;
    end;
  finally
    Fields.Free;
    StarRelations.Free;
  end;
end;

function TzSystemVerifier.LookupUsers(const LookupName: string): TStringList;
var
  Index: Integer;
  domain: TzDomain;
  key: string;
  Users, ModuleTables: TStringList;
begin
  if not Assigned(FLookupUsers) then
  begin
    FLookupUsers := TObjectDictionary<string, TStringList>.Create([doOwnsValues]);
    FGridLookups := TStringList.Create;
    FGridLookups.Sorted := True;
    FGridLookups.Duplicates := dupIgnore;
    FGridLookups.CaseSensitive := False;

    // Relazioni su cui lavora un dataset di un modulo: quelle che arrivano a
    // video. I controlli delle schede non si possono guardare: molte hanno
    // Controls vuoto e li costruiscono dal dataset in esecuzione
    ModuleTables := TStringList.Create;
    try
      ModuleTables.Sorted := True;
      ModuleTables.Duplicates := dupIgnore;
      ModuleTables.CaseSensitive := False;
      for Index := 0 to FzSystem.zDataSets.Count - 1 do
        if Pos('.', FzSystem.zDataSets[Index].Name) > 0 then
          ModuleTables.Add(Trim(FzSystem.zDataSets[Index].TableName));

      for Index := 0 to FzSystem.zDataDictionary.Count - 1 do
      begin
        domain := FzSystem.zDataDictionary[Index];
        if (not domain.Exists) or (Trim(domain.Lookup) = '') or not domain.zCtrlType.IsLookup then
          Continue;

        key := UpperCase(Trim(domain.Lookup));
        if not FLookupUsers.TryGetValue(key, Users) then
        begin
          Users := TStringList.Create;
          Users.Sorted := True;
          Users.Duplicates := dupIgnore;
          FLookupUsers.Add(key, Users);
        end;
        Users.Add(UpperCase(Trim(domain.TableName)));

        if (domain.zCtrlType = ctLookupExt) and (ModuleTables.IndexOf(Trim(domain.TableName)) >= 0) then
          FGridLookups.Add(key);
      end;
    finally
      ModuleTables.Free;
    end;
  end;

  if not FLookupUsers.TryGetValue(UpperCase(Trim(LookupName)), Result) then
    Result := nil;
end;

function TzSystemVerifier.FindDomainOf(Shape: TzSqlSelectShape; const Column: TzSqlSelectColumn): TzDomain;
var
  Relation: string;
begin
  Result := nil;
  if Column.FieldName = '' then
    Exit;

  if Column.Relation <> '' then
    Exit(FzSystem.zDataDictionary.get(Shape.RelationOf(Column.Relation) + '.' + Column.FieldName, False));

  for Relation in Shape.RelationNames do
  begin
    Result := FzSystem.zDataDictionary.get(Relation + '.' + Column.FieldName, False);
    if Assigned(Result) then
      Exit;
  end;
end;

function TzSystemVerifier.ColumnIsText(Shape: TzSqlSelectShape; const Column: TzSqlSelectColumn): Boolean;
var
  domain: TzDomain;
begin
  if Column.IsTextExpression then
    Exit(True);

  domain := FindDomainOf(Shape, Column);
  Result := Assigned(domain) and IsTextFieldType(domain.DataType);
end;

function TzSystemVerifier.ColumnIsNumericKey(Shape: TzSqlSelectShape; const ColumnName: string): Boolean;
var
  Column: TzSqlSelectColumn;
  domain: TzDomain;
begin
  Result := False;
  if not Shape.FindColumn(ColumnName, Column) then
    Exit;

  domain := FindDomainOf(Shape, Column);
  if Assigned(domain) then
    Result := IsNumericFieldType(domain.DataType)
  else
    Result := ColumnName.ToUpper.StartsWith('ID_') or SameText(ColumnName, 'OID');
end;

function TzSystemVerifier.DescriptiveColumn(Shape: TzSqlSelectShape; Keys: TStrings): string;
const
  // sotto questa lunghezza un testo e' una sigla, non una descrizione
  MinimumSize = 15;
var
  Column: TzSqlSelectColumn;
  domain: TzDomain;
begin
  Result := '';
  for Column in Shape.Columns do
    if (Column.Name <> '') and (Keys.IndexOf(Column.Name) < 0) and not IsServiceField(Column.Name) and IsDescriptiveName(Column.Name, Keys[0]) then
      if ColumnIsText(Shape, Column) then
      begin
        domain := FindDomainOf(Shape, Column);
        if (not Assigned(domain)) or (domain.Size <= 0) or (domain.Size >= MinimumSize) then
          Exit(Column.Name);
      end;
end;

// Primo campo di testo della SELECT che non e' chiave, non e' di servizio e il cui
// nome DescriptiveColumn non riconosce (SIA_INTERVENTI.ID_DOMANDA...): puo' essere
// la descrizione che la tendina dovrebbe mostrare. Serve solo ad avvisare.
function TzSystemVerifier.UnrecognizedTextColumn(Shape: TzSqlSelectShape; Keys: TStrings): string;
var
  Column: TzSqlSelectColumn;
begin
  Result := '';
  for Column in Shape.Columns do
    if (Column.Name <> '') and (Keys.IndexOf(Column.Name) < 0) and not IsServiceField(Column.Name) and ColumnIsText(Shape, Column) then
      Exit(Column.Name);
end;

function TzSystemVerifier.ShownColumn(lk: TzLookup; Shape: TzSqlSelectShape): string;
var
  View: TzDbViewProps;
  Index: Integer;
  Column: TzSqlSelectColumn;
  Display: TStringList;
begin
  Result := '';
  View := lk.DbView_Obj;

  // InitLookupColumns prende le colonne visibili della vista che il dataset
  // ha davvero. Una vista vuota si riempie dai campi del dataset, tutti
  // visibili: si vede il primo della SELECT
  if Assigned(View) then
  begin
    for Index := 0 to View.Columns.Count - 1 do
      if View.Columns[Index].Visible and Shape.FindColumn(View.Columns[Index].Name, Column) then
        Exit(UpperCase(View.Columns[Index].Name));

    if View.Columns.Count = 0 then
      for Column in Shape.Columns do
        if Column.Name <> '' then
          Exit(Column.Name);
    Exit;
  end;

  // senza vista conta DisplayColumns
  Display := TStringList.Create;
  try
    SplitFieldList(lk.DisplayColumns, Display);
    if Display.Count > 0 then
      Result := Display[0];
  finally
    Display.Free;
  end;
end;

function TzSystemVerifier.MasterFieldKnown(lk: TzLookup; const FieldName: string): Boolean;
var
  Relations, Fields: TStringList;
  Users: TStringList;
  Relation: string;
  Index: Integer;
  dsObj: TzDataSet;
  Column: TzSqlSelectColumn;
  AnyRelationKnown: Boolean;
  Ancestors: TList<TzDataSet>;

  // TzMasterFieldsBinder risale la catena master/dettaglio: si guardano i
  // master dei dataset che lavorano sulle relazioni del lookup
  function FoundInAncestors(Items: TzDiagramDataSets): Boolean;
  var
    Item: TzDiagramDataSet;
    Current, Ancestor: TzDataSet;
    Found: TzSqlSelectColumn;
  begin
    Result := False;
    for Item in Items do
    begin
      Current := FzSystem.zDataSets.get(Item.idDataSet, False);
      if Assigned(Current) and (Relations.IndexOf(UpperCase(Trim(Current.TableName))) >= 0) then
        for Ancestor in Ancestors do
          if SelectShapeOf(Ancestor).FindColumn(FieldName, Found) then
            Exit(True);

      if Assigned(Current) and Item.HasDetailDataSets then
      begin
        Ancestors.Add(Current);
        try
          if FoundInAncestors(Item.DetailDatasets) then
            Exit(True);
        finally
          Ancestors.Delete(Ancestors.Count - 1);
        end;
      end;
    end;
  end;

begin
  Relations := TStringList.Create;
  Fields := TStringList.Create;
  try
    Relations.Sorted := True;
    Relations.Duplicates := dupIgnore;
    if Trim(lk.TableName) <> '' then
      Relations.Add(UpperCase(Trim(lk.TableName)));
    Users := LookupUsers(lk.Name);
    if Assigned(Users) then
      Relations.AddStrings(Users);

    AnyRelationKnown := False;
    for Relation in Relations do
      if CollectRelationFields(Relation, Fields) then
      begin
        AnyRelationKnown := True;
        if Fields.IndexOf(FieldName) >= 0 then
          Exit(True);
      end;

    // relazioni che il dizionario non conosce: non si puo' dire niente
    if not AnyRelationKnown then
      Exit(True);

    // Il master e' un dataset: puo' portare campi di altre tabelle nella sua SELECT
    for Index := 0 to FzSystem.zDataSets.Count - 1 do
    begin
      dsObj := FzSystem.zDataSets[Index];
      if Relations.IndexOf(UpperCase(Trim(dsObj.TableName))) >= 0 then
        if SelectShapeOf(dsObj).FindColumn(FieldName, Column) then
          Exit(True);
    end;

    Ancestors := TList<TzDataSet>.Create;
    try
      for Index := 0 to FzSystem.zDataModules.Count - 1 do
        if FoundInAncestors(FzSystem.zDataModules[Index].DataSets) then
          Exit(True);
    finally
      Ancestors.Free;
    end;

    Result := False;
  finally
    Fields.Free;
    Relations.Free;
  end;
end;

// (H) Parametri del lookup nei due versi. TzMasterFieldsBinder assegna ogni voce
// di MasterFields (PARAMETRO oppure PARAMETRO=CAMPO) al parametro omonimo della
// SELECT: se il parametro manca la voce non fa niente e l'elenco non si filtra
// (Mantis #320: WHERE perso, MasterFields rimasto), se manca la voce il
// parametro resta vuoto e l'elenco resta senza righe.  [ERROR]
function TzSystemVerifier.VerifyLookupParameters(lk: TzLookup; dsObj: TzDataSet): Boolean;
var
  Parameters, Masters: TStringList;
  Entry, ParameterName, FieldName, Text: string;
  Separator: Integer;
begin
  Result := True;
  Parameters := TStringList.Create;
  Masters := TStringList.Create;
  try
    Parameters.Sorted := True;
    Parameters.Duplicates := dupIgnore;
    ScanSql(dsObj.SQL_Select.Text,
      procedure(const Token: string)
      begin
        Parameters.Add(Token);
      end, nil);

    // stesse sostituzioni di TzMasterFieldsBinder
    Text := lk.MasterFields.Replace('@', '=').Replace(' ', '');
    SplitFieldList(Text, Masters);

    for Entry in Masters do
    begin
      Separator := Pos('=', Entry);
      if Separator > 0 then
      begin
        ParameterName := Copy(Entry, 1, Separator - 1);
        FieldName := Copy(Entry, Separator + 1, MaxInt);
      end
      else
      begin
        ParameterName := Entry;
        FieldName := Entry;
      end;

      if Parameters.IndexOf(ParameterName) < 0 then
        if not Emit(vsError, vcLookupParameters, lk.Name, 'MasterFields', Format('MasterFields cita "%s" ma la SELECT del dataset "%s" non ha il parametro :%s: l''elenco non si filtra', [ParameterName, dsObj.Name, ParameterName]), lk, dsObj.SQL_Select.Text) then
          Exit(False);

      if not MasterFieldKnown(lk, FieldName) then
        if not Emit(vsError, vcLookupParameters, lk.Name, 'MasterFields', Format('MasterFields legge il campo "%s", che il master non ha (TableName "%s" e campi che usano il lookup)', [FieldName, lk.TableName]), lk) then
          Exit(False);
    end;

    // I dataset di un modulo ("Orario.lkProgetti") ricevono i parametri dal
    // codice del DataModule: dal dizionario non si distinguono, come in
    // VerifyMasterParams. Il verso si controlla sui dataset dei soli lookup
    if Pos('.', dsObj.Name) > 0 then
      Exit;

    for ParameterName in Parameters do
    begin
      // valori che assegna zPack: gli stessi esclusi da VerifyMasterParams
      if ParameterName.StartsWith('FILTRO_') or ParameterName.StartsWith('##') or ParameterName.StartsWith('__') then
        Continue;

      Separator := -1;
      for Entry in Masters do
        if SameText(Entry, ParameterName) or Entry.StartsWith(ParameterName + '=') then
          Separator := 0;

      if Separator < 0 then
        if not Emit(vsError, vcLookupParameters, lk.Name, 'SQL_Select', Format('Il parametro :%s della SELECT del dataset "%s" non e'' fornito da MasterFields: resta vuoto e l''elenco non mostra righe', [ParameterName, dsObj.Name]), lk, dsObj.SQL_Select.Text) then
          Exit(False);
    end;
  finally
    Masters.Free;
    Parameters.Free;
  end;
end;

// (I) Colonne della vista e DisplayColumns contro la SELECT del dataset.
// ValidateDataset cancella in silenzio le colonne che il dataset non ha, e
// GetListFieldItem prende il primo elemento di ListFieldNames solo se e' fra
// le colonne visibili: altrimenti ripiega sulla chiave.  [ERROR]
function TzSystemVerifier.VerifyLookupColumns(lk: TzLookup; dsObj: TzDataSet; Shape: TzSqlSelectShape): Boolean;
var
  View: TzDbViewProps;
  Index: Integer;
  Column: TzSqlSelectColumn;
  Display: TStringList;
  FieldName: string;
  FirstDisplayVisible: Boolean;
begin
  Result := True;
  View := lk.DbView_Obj;

  if Shape.Complete then
  begin
    if Assigned(View) then
      for Index := 0 to View.Columns.Count - 1 do
        // una colonna nascosta che il dataset non ha piu' non si vede: ValidateDataset la toglie
        if View.Columns[Index].Visible and not Shape.FindColumn(View.Columns[Index].Name, Column) then
          if not Emit(vsError, vcLookupColumnsExist, lk.Name, 'DbView', Format('La colonna "%s" della vista "%s" non e'' nella SELECT del dataset "%s"', [View.Columns[Index].Name, View.Name, dsObj.Name]), lk) then
            Exit(False);
  end;

  Display := TStringList.Create;
  try
    SplitFieldList(lk.DisplayColumns, Display);

    if Shape.Complete then
      for FieldName in Display do
        if not Shape.FindColumn(FieldName, Column) then
          if not Emit(vsError, vcLookupColumnsExist, lk.Name, 'DisplayColumns', Format('La colonna "%s" di DisplayColumns non e'' nella SELECT del dataset "%s"', [FieldName, dsObj.Name]), lk) then
            Exit(False);

    if Assigned(View) and (View.Columns.Count > 0) and (Display.Count > 0) then
    begin
      FirstDisplayVisible := False;
      for Index := 0 to View.Columns.Count - 1 do
        if View.Columns[Index].Visible and SameText(View.Columns[Index].Name, Display[0]) then
          FirstDisplayVisible := True;

      if not FirstDisplayVisible then
        if not Emit(vsError, vcLookupColumnsExist, lk.Name, 'DisplayColumns', Format('Il primo elemento di DisplayColumns ("%s") non e'' una colonna visibile della vista "%s": la tendina ripiega sulla chiave', [Display[0], View.Name]), lk) then
          Exit(False);
    end;
  finally
    Display.Free;
  end;
end;

// (J) Quello che la tendina mostra, cerca e ordina. Regola: di norma l'id non si
// espone, salvo che il lookup non abbia un campo descrittivo (ID_INCARICO).
// Valgono per i lookup che un campo vivo usa: gli altri nessuno li vede.
function TzSystemVerifier.VerifyLookupPresentation(lk: TzLookup; dsObj: TzDataSet; Shape: TzSqlSelectShape): Boolean;
var
  View: TzDbViewProps;
  Keys, Searched: TStringList;
  Shown, Descriptive, KeyName, FieldName, Unrecognized: string;
  Column: TzSqlSelectColumn;
  KeyShown, SearchOnKey: Boolean;
begin
  Result := True;

  if not Assigned(LookupUsers(lk.Name)) or not Shape.Complete then
    Exit;

  View := lk.DbView_Obj;
  Keys := TStringList.Create;
  Searched := TStringList.Create;
  try
    SplitFieldList(lk.FieldNamesFK, Keys);
    if Keys.Count = 0 then
      Exit;
    KeyName := Keys[0];

    Shown := ShownColumn(lk, Shape);
    Descriptive := DescriptiveColumn(Shape, Keys);
    KeyShown := SameText(Shown, KeyName) and ColumnIsNumericKey(Shape, KeyName);

    // (J1) vista vuota: il campo mostra la chiave  [ERROR]
    if FCheckLookupGridColumns and Assigned(View) and (View.Columns.Count = 0) and (Trim(View.SearchFields) = '') and KeyShown and (Descriptive <> '') and (FGridLookups.IndexOf(lk.Name) >= 0) then
      if not Emit(vsError, vcLookupGridColumns, lk.Name, 'DbView', Format('La vista "%s" non ha colonne ne'' SearchFields: si riempie dal dataset, la prima colonna e'' la chiave %s e il campo mostra l''id invece di %s', [View.Name, KeyName, Descriptive]), lk) then
        Exit(False);

    // (J1b) stessa vista vuota, ma la SELECT non ha un descrittivo riconosciuto e ha
    // un campo di testo: potrebbe essere la descrizione, e il campo mostra l'id.
    // Solo avviso: un lookup su un id legittimo (ID_INCARICO) ha testi che non descrivono  [WARNING]
    if FCheckLookupGridColumns and Assigned(View) and (View.Columns.Count = 0) and (Trim(View.SearchFields) = '') and KeyShown and (Descriptive = '') and (FGridLookups.IndexOf(lk.Name) >= 0) then
    begin
      Unrecognized := UnrecognizedTextColumn(Shape, Keys);
      if Unrecognized <> '' then
        if not Emit(vsWarning, vcLookupGridColumns, lk.Name, 'DbView', Format('La vista "%s" non ha colonne ne'' SearchFields: la prima colonna e'' la chiave %s e il campo mostra l''id; la SELECT non ha un campo descrittivo riconosciuto, ma ha il testo %s: da controllare se e'' la descrizione', [View.Name, KeyName, Unrecognized]), lk) then
          Exit(False);
    end;

    // (J2) la vista dichiara la chiave come prima colonna  [WARNING]
    if FCheckLookupShowsKey and KeyShown and (Descriptive <> '') and Assigned(View) and (View.Columns.Count > 0) then
      if not Emit(vsWarning, vcLookupShowsKey, lk.Name, 'DbView', Format('La prima colonna visibile della vista "%s" e'' la chiave %s: il campo mostra l''id, e la SELECT ha %s', [View.Name, KeyName, Descriptive]), lk) then
        Exit(False);

    // (J3) ricerca sulla chiave  [WARNING]
    if FCheckLookupSearchOnKey and Assigned(View) and (Descriptive <> '') and ColumnIsNumericKey(Shape, KeyName) then
    begin
      SplitFieldList(View.SearchFields, Searched);
      SearchOnKey := Searched.Count > 0;
      for FieldName in Searched do
        if (Keys.IndexOf(FieldName) < 0) then
          SearchOnKey := False;
      if SearchOnKey then
        if not Emit(vsWarning, vcLookupSearchOnKey, lk.Name, 'SearchFields', Format('La vista "%s" cerca su %s, la chiave: digitare un nome non trova niente, e la SELECT ha %s', [View.Name, View.SearchFields, Descriptive]), lk) then
          Exit(False);
    end;

    // (J4) ordinamento: solo se il campo mostrato e' descrittivo, altrimenti
    // il difetto e' a monte e lo dicono J1 e J2  [WARNING]
    if FCheckLookupOrderBy and (Shown <> '') and not SameText(Shown, KeyName) and Shape.FindColumn(Shown, Column) and ColumnIsText(Shape, Column) then
    begin
      if Shape.OrderByPosition > 0 then
      begin
        if (Shape.OrderByPosition <= Shape.Columns.Count) and SameText(Shape.Columns[Shape.OrderByPosition - 1].Name, Shown) then
          Exit;
      end
      else if (Shape.OrderByWords.IndexOf(Shown) >= 0) or ((Column.FieldName <> '') and (Shape.OrderByWords.IndexOf(Column.FieldName) >= 0)) then
        Exit;

      if not Emit(vsWarning, vcLookupOrderBy, lk.Name, 'SQL_Select', Format('Il dataset "%s" non ordina per %s, il campo mostrato: l''elenco esce in un ordine che chi digita non si aspetta', [dsObj.Name, Shown]), lk, dsObj.SQL_Select.Text) then
        Exit(False);
    end;
  finally
    Searched.Free;
    Keys.Free;
  end;
end;

// (K) La tendina ha per chiave un solo campo (GetKeyFieldForCombo): se e' parte
// di una primaria composta e la SELECT non filtra il resto, la stessa chiave
// compare su piu' righe e la scelta prende la prima (Mantis #320, 94 righe di
// ASSISTENTI_SOCIALI_COMUNI per 59 assistenti). Legge la chiave primaria da
// MetaData, che c'e' anche senza database.  [WARNING]
function TzSystemVerifier.VerifyLookupCompositeKey(lk: TzLookup; dsObj: TzDataSet; Shape: TzSqlSelectShape): Boolean;
var
  Keys: TStringList;
  KeyName, Relation, Unfiltered, PartName: string;
  Column: TzSqlSelectColumn;
  TableIndex, Index: Integer;
  KeyInPrimary: Boolean;
begin
  Result := True;

  if not Assigned(LookupUsers(lk.Name)) or Shape.NoRepeatedRows or not Assigned(FzSystem.MetaData) then
    Exit;

  Keys := TStringList.Create;
  try
    SplitFieldList(lk.FieldNamesFK, Keys);
    if Keys.Count = 0 then
      Exit;
    KeyName := Keys[0];
  finally
    Keys.Free;
  end;

  Relation := '';
  if Shape.FindColumn(KeyName, Column) then
  begin
    if Column.Relation <> '' then
      Relation := Shape.RelationOf(Column.Relation);
    if Column.FieldName <> '' then
      KeyName := Column.FieldName;
  end;
  if Relation = '' then
    Relation := UpperCase(Trim(lk.TableNameFK));
  if Relation = '' then
    Exit;

  TableIndex := FzSystem.MetaData.Tables.IndexOf(Relation);
  if (TableIndex < 0) or (FzSystem.MetaData.Tables[TableIndex].PrimaryKey.Count < 2) then
    Exit;

  KeyInPrimary := False;
  Unfiltered := '';
  for Index := 0 to FzSystem.MetaData.Tables[TableIndex].PrimaryKey.Count - 1 do
  begin
    PartName := UpperCase(FzSystem.MetaData.Tables[TableIndex].PrimaryKey[Index].Name);
    if PartName = KeyName then
      KeyInPrimary := True
    else if Shape.WhereWords.IndexOf(PartName) < 0 then
      Unfiltered := Unfiltered + IfThen(Unfiltered <> '', ', ') + PartName;
  end;

  if KeyInPrimary and (Unfiltered <> '') then
    Result := Emit(vsWarning, vcLookupCompositeKey, lk.Name, 'SQL_Select', Format('La chiave %s e'' parte della chiave primaria composta di %s e la SELECT non filtra %s: la stessa chiave compare su piu'' righe', [KeyName, Relation, Unfiltered]), lk, dsObj.SQL_Select.Text);
end;

function TzSystemVerifier.VerifyLookupDefinitions(const Total: Integer; var Done: Integer): Boolean;
var
  Index: Integer;
  lk: TzLookup;
  dsObj: TzDataSet;
  Shape: TzSqlSelectShape;
begin
  Result := True;

  for Index := 0 to FzSystem.zLookups.Count - 1 do
  begin
    lk := FzSystem.zLookups[Index];

    Inc(Done);
    if not Progress(Done, Total, 'Definizione lookup: ' + lk.Name) then
      Exit(False);

    // lookup senza dataset o senza SELECT: li segnala il controllo Lookups
    dsObj := lk.DataSet_Obj;
    if (not lk.Exists) or (not Assigned(dsObj)) or (Trim(dsObj.SQL_Select.Text) = '') then
      Continue;

    Shape := SelectShapeOf(dsObj);

    if FCheckLookupParameters then
      if not VerifyLookupParameters(lk, dsObj) then
        Exit(False);

    if FCheckLookupColumnsExist then
      if not VerifyLookupColumns(lk, dsObj, Shape) then
        Exit(False);

    if FCheckLookupGridColumns or FCheckLookupShowsKey or FCheckLookupSearchOnKey or FCheckLookupOrderBy then
      if not VerifyLookupPresentation(lk, dsObj, Shape) then
        Exit(False);

    if FCheckLookupCompositeKey then
      if not VerifyLookupCompositeKey(lk, dsObj, Shape) then
        Exit(False);
  end;
end;

// (L) Domini di campi vivi che citano un lookup inesistente. A differenza del
// controllo Lookups non guarda il tipo di controllo e tralascia i campi con
// Exists = False, che da soli sono centinaia: qui restano quelli da correggere.
// [ERROR; WARNING se il controllo del campo non e' un lookup]
function TzSystemVerifier.VerifyDomainLookupsExist(const Total: Integer; var Done: Integer): Boolean;
var
  Index: Integer;
  domain: TzDomain;
begin
  Result := True;

  for Index := 0 to FzSystem.zDataDictionary.Count - 1 do
  begin
    domain := FzSystem.zDataDictionary[Index];

    Inc(Done);
    if not Progress(Done, Total, 'Lookup dei domini: ' + domain.Name) then
      Exit(False);

    if (not domain.Exists) or (Trim(domain.Lookup) = '') then
      Continue;

    if Assigned(domain.Lookup_Obj) then
      Continue;

    // con un controllo che non e' un lookup il riferimento e' un residuo: nessuno lo legge
    if domain.zCtrlType.IsLookup then
    begin
      if not Emit(vsError, vcLookupDomainMissing, domain.Name, 'Lookup', Format('Il campo cita il lookup "%s", che non esiste in TzLookups', [domain.Lookup]), domain) then
        Exit(False);
    end
    else if not Emit(vsWarning, vcLookupDomainMissing, domain.Name, 'Lookup', Format('Il campo cita il lookup "%s", che non esiste in TzLookups, ma il suo controllo non lo usa', [domain.Lookup]), domain) then
      Exit(False);
  end;
end;

function TzSystemVerifier.EstimateTotal: Integer;
begin
  Result := 0;
  if FCheckSql then
    Inc(Result, FzSystem.zDataSets.Count);
  if FCheckStoredProcs then
    Inc(Result, FzSystem.zStoredProcs.Count);
  if FCheckLookups then
    Inc(Result, FzSystem.zLookups.Count + FzSystem.zDataDictionary.Count);
  if FCheckRefIntegrity then
    Inc(Result, FzSystem.zDbViews.Count + FzSystem.zDbCards.Count + FzSystem.zDbPivots.Count + FzSystem.zDbRecordViews.Count + FzSystem.zDbTrees.Count + FzSystem.zDbCharts.Count + FzSystem.zDbSchedulers.Count + FzSystem.zLookups.Count + FzSystem.zDataModules.Count);
  if FCheckDomainCoverage then
    Inc(Result, FzSystem.zDataDictionary.Count);
  if FCheckDomainExists then
    Inc(Result, FzSystem.zDataDictionary.Count);
  if FCheckAutoSql then
    Inc(Result, FzSystem.zDataSets.Count);
  if FCheckLookupCardinality then
    Inc(Result, FzSystem.zLookups.Count);
  if FCheckDuplicates then
    Inc(Result, FzSystem.zDataSets.Count + FzSystem.zLookups.Count + FzSystem.zDataDictionary.Count);
  if FCheckGenerators then
    Inc(Result, FzSystem.zDataSets.Count);
  if FCheckSeparators then
    Inc(Result, FzSystem.zLookups.Count);
  if HasLookupDefinitionChecks then
    Inc(Result, FzSystem.zLookups.Count);
  if FCheckLookupDomainMissing then
    Inc(Result, FzSystem.zDataDictionary.Count);
  if Result = 0 then
    Result := 1;
end;

function TzSystemVerifier.VerifyAll(Results: TzVerifyResults): TzVerifyStats;
var
  Total, Done: Integer;
  SavedEmit: TzVerifyEmitEvent;
begin
  FStats.Clear;
  FCancelled := False;
  Done := 0;

  // Se il chiamante vuole accumulare in Results, incapsuliamo OnEmit
  SavedEmit := FOnEmit;
  if Assigned(Results) then
    FOnEmit := function(const R: TzVerifyResult): Boolean
      begin
        Results.Add(R);
        if Assigned(SavedEmit) then
          Result := SavedEmit(R)
        else
          Result := True;
      end;

  try
    // stima del totale per il progress
    Total := EstimateTotal;

    if FCheckSql then
      if not VerifyDataSets(Total, Done) then
        Exit(FStats);

    if FCheckStoredProcs then
      if not VerifyStoredProcs(Total, Done) then
        Exit(FStats);

    if FCheckLookups then
    begin
      if not VerifyLookupsInternal(Total, Done) then
        Exit(FStats);
      if not VerifyDomainLookups(Total, Done) then
        Exit(FStats);
    end;

    if FCheckRefIntegrity then
      if not VerifyRefIntegrity(Total, Done) then
        Exit(FStats);

    if FCheckDomainExists then
      if not VerifyDomainExists(Total, Done) then
        Exit(FStats);

    if FCheckDomainCoverage then
      if not VerifyDomainCoverage(Total, Done) then
        Exit(FStats);

    if FCheckAutoSql then
      if not VerifyAutoSql(Total, Done) then
        Exit(FStats);

    if FCheckLookupCardinality then
      if not VerifyLookupCardinality(Total, Done) then
        Exit(FStats);

    if FCheckDuplicates then
      if not VerifyDuplicates(Total, Done) then
        Exit(FStats);

    if FCheckGenerators then
      if not VerifyGenerators(Total, Done) then
        Exit(FStats);

    if FCheckSeparators then
      if not VerifySeparators(Total, Done) then
        Exit(FStats);

    if HasLookupDefinitionChecks then
      if not VerifyLookupDefinitions(Total, Done) then
        Exit(FStats);

    if FCheckLookupDomainMissing then
      if not VerifyDomainLookupsExist(Total, Done) then
        Exit(FStats);
  finally
    FOnEmit := SavedEmit;
    Result := FStats;
  end;
end;

end.
