unit zFbDataSet;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Diagnostics,
  System.TimeSpan,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  // FireDAC.Phys.IBBase,
  // FireDAC.Phys.FB,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl,
  zSql.SelectOrigins,
  zSql.UpdateParziale,
  zSanificazione;

type
  TTableType = (ttPersistent, ttTempDeleteRows, ttTempPreserveRows);
  // DIV-DAT-1: amWhenNeeded non e' letto da nessuno e si comporta come amAutomatic;
  // solo amManual fa differenza (TzDataController.GetAutoOpen)
  TActivationMode = (amManual, amAutomatic, amWhenNeeded);

  TDataSetEventKind = (deNone, deAfterCancel, deAfterClose, deAfterDelete, deAfterEdit, deAfterInsert, deAfterOpen, deAfterPost, deAfterScroll, deBeforeCancel, deBeforeClose, deBeforeDelete, deBeforeEdit, deBeforeInsert, deBeforeOpen, deBeforePost,
    deBeforeScroll, deOnCalcFields, deOnNewRecord, deBeforeRefresh, deAfterRefresh, deOnEnableControls, deOnDisableControls, deOnEndScroll, OnCustomBeforePost, deOnGetQueryParams, deOnBeforeCreateFields, deOnAfterCreateFields);

  TDataSetEventKindHelper = record helper for TDataSetEventKind
  public
    function ToString: string;
    class function FromString(const s: String): TDataSetEventKind; static;
  end;

  // Mantis #183 - 2026-10-08: opzioni di lettura di zPack in aggiunta alle
  // FetchOptions di FireDAC, impostabili per dataset dal dizionario LZ
  // (TzDataSet.ExtendedFetchOptions).
  // - zfoBlobsWithRow: i BLOB arrivano insieme alla riga (fiBlobs di FireDAC,
  //   comportamento di sempre). Senza, FireDAC li legge quando il campo viene
  //   letto, rieseguendo per quella riga la RefreshSQL (FetchRowSQL): senza
  //   chiave primaria la lettura fallisce, e su una vista pesante costa una
  //   query per riga (INCARICHI_ELENCO: circa 100 ms a riga, una stampa di 300
  //   righe da 7 a 30 s). Da togliere solo sui dataset di cui si guardano i
  //   BLOB del solo record corrente, mai su quelli usati per le stampe.
  // - zfoFieldDefsWithoutRows: BuildFields legge la struttura delle colonne
  //   preparando la SELECT con "ROWS 0", senza far lavorare il server (vedi
  //   BuildFields). Senza, la legge eseguendo la query come prima: serve solo
  //   a escludere il meccanismo su un dataset che desse problemi.
  TzFetchOption = (zfoBlobsWithRow, zfoFieldDefsWithoutRows);
  TzFetchOptions = set of TzFetchOption;

const
  DefaultExtendedFetchOptions = [zfoBlobsWithRow, zfoFieldDefsWithoutRows];

type
  TzFbDataSet = class;

  TAfterLookupFieldsCopied = procedure(Sender: TzFbDataSet; lkDataSet: TDataset; LookupString: string) of object;

  TNewRecordOptions = class(TPersistent)
  private
    FMasterToFields: boolean;
    FMasterToFieldsExcluded: string;
    FParamsToFields: boolean;
    FParamsToFieldsExcluded: string;
    procedure SetMasterToFieldsExcluded(const Value: string);
    procedure SetParamsToFieldsExcluded(const Value: string);
  public
    Constructor Create;
    procedure Assign(Source: TPersistent); virtual;
  published
    property ParamsToFields: boolean read FParamsToFields write FParamsToFields default true;
    property ParamsToFieldsExcluded: string read FParamsToFieldsExcluded write SetParamsToFieldsExcluded;
    property MasterToFields: boolean read FMasterToFields write FMasterToFields default true;
    property MasterToFieldsExcluded: string read FMasterToFieldsExcluded write SetMasterToFieldsExcluded;
  end;

  // DIV-DAT-6: aggiunge a TFDConnection solo il non salvare Connected nel DFM.
  // Il nome resta perche' i DFM esistenti lo citano.
  TzFbDatabase = class(TFDConnection)
  published
    property Connected stored false;
  end;

  TzFbTransaction = class(TFDTransaction)
  private
    SavePoints: TStack<string>;
    FOperazioniAtomiche: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetSavePoint(const SavePoint: string);
    procedure RollBackToSavePoint(const SavePoint: string);
    procedure CloseTransaction(const doCommit: boolean = true);
    // DIV-SAL-3: finche' un'operazione atomica e' aperta, l'AutoCommit dei dataset che usano
    // questa transazione non conferma niente. Le chiamate si annidano e vanno in coppia
    // (BeginOperazioneAtomica ... try ... finally EndOperazioneAtomica)
    procedure BeginOperazioneAtomica;
    procedure EndOperazioneAtomica;
    function OperazioneAtomicaAperta: boolean;

  published
    property Active stored false;
  end;

  // Mantis #161 - 2026-09-30: gli attributi che zPack mette su un campo e che
  // FireDAC riscrive sui campi automatici (TFDDataSet.SetFieldAttributes:
  // Origin, DefaultExpression, ReadOnly, DisplayFormat, EditFormat).
  // ProviderFlags non c'e': zPack non lo imposta, resta quello di FireDAC.
  TAttributiCampo = record
    Campo: TField;
    Origine: string;
    ValorePredefinito: string;
    SolaLettura: boolean;
    Maschera: string;
    MascheraModifica: string;
  end;

  TzFbDataSet = class(TFDQuery)
  private
    FActivationMode: TActivationMode;
    FAutoCreateFields: boolean;
    FCountSQL: TStrings;
    FDefaultSQL: TStrings;
    FDefaultValues: TStrings;
    FIdDataSet: string;
    FIdentityField: string;
    FFieldNameOID: string;
    FPrimaryKey: string; // Mantis #74 - 2026-09-03: copia stabile della chiave primaria, usata da OID
    FOnAfterCreateFields: TDataSetNotifyEvent;
    FOnAfterLookupFieldsCopied: TAfterLookupFieldsCopied;
    FOnBeforeCreateFields: TDataSetNotifyEvent;
    FOnCustomBeforePost: TDataSetNotifyEvent;
    FOnGetQueryParams: TDataSetNotifyEvent;
    FReopenAfterPost: boolean;
    FReportPipe: string;
    FSanification: boolean;
    FTableName: string;
    FUseSqlLocate: boolean;
    FMantieniElencoSeNonTrova: boolean;
    InLocate: boolean;
    LocateWhere: string;
    StopWatch: TStopWatch;
    // Mantis #183 - 2026-10-08: misura dei rowset letti dal server durante la
    // registrazione per l'assistenza (RegistrazioneFetchAttiva di
    // zDiagnostica.Log.Perf). Il contatore riparte a ogni apertura.
    FNumeroFetch: Integer;
    FCronometroFetch: TStopWatch;
    FAutoCommit: boolean;
    // Firma dei parametri (tipo, dimensione, precisione, scala, verso) al
    // momento della preparazione conservata da BuildFields. Vuota = nessuna
    // preparazione da riusare.
    FFirmaParametriPreparati: string;
    // Mantis #183 - 2026-10-08: vedi TzFetchOption. zfoBlobsWithRow qui non fa
    // fede: lo stato vero e' fiBlobs in FetchOptions.Items.
    FExtendedFetchOptions: TzFetchOptions;
    // Mantis #257 - 2026-10-29: UPDATE automatico con le sole colonne cambiate
    // (vedi ComponiUpdateSQL). Le parti dell'UPDATE le valorizza TzSystem
    // insieme a UpdateSQL; FUltimoUpdateSQL e' il testo che il dataset sa di
    // avere, per non toccare un UpdateSQL cambiato da altri dopo.
    FUpdateChangedFields: boolean;
    FAutoUpdate: boolean;
    FAutoUpdateColumns: TStrings;
    FAutoUpdateKeyFields: TStrings;
    FAutoUpdateReturning: TStrings;
    FAutoUpdateWhere: string;
    FUltimoUpdateSQL: string;
    procedure SetAutoUpdate(const Value: boolean);
    procedure SetAutoUpdateColumns(const Value: TStrings);
    procedure SetAutoUpdateKeyFields(const Value: TStrings);
    procedure SetAutoUpdateReturning(const Value: TStrings);
    function CampoCambiato(Field: TField): boolean;
    procedure ComponiUpdateSQL;
    procedure RegistraPost;
    function GetDatabase: TFDCustomConnection;
    function GetGeneratorName: string;
    function GetLocateSQL(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): string;
    function GetOpenTime: TTimeSpan;
    function GetOrderBy: string;
    function GetPrimaryKeyFields: string;
    function GetSQL_Delete: TStrings;
    function GetSQL_Insert: TStrings;
    function GetSQL_Refresh: TStrings;
    function GetSQL_Select: TStrings;
    function GetSQL_Update: TStrings;
    function GetWhere: string;
    function FirmaParametri: string;
    function CanPrepareWithoutRows: boolean;
    function GetExtendedFetchOptions: TzFetchOptions;
    procedure SetExtendedFetchOptions(const Value: TzFetchOptions);
    function LocateFound(KeyFields: string; KeyValues: Variant; Options: TLocateOptions): boolean;
    function LocateParamsEmpty(KeyValues: Variant): boolean;
    procedure SetActivationMode(const Value: TActivationMode);
    procedure SetCountSQL(const Value: TStrings);
    procedure SetDatabase(const Value: TFDCustomConnection);
    procedure SetDefaultSQL(const Value: TStrings);
    procedure SetDefaultValues(const Value: TStrings);
    procedure SetGeneratorName(const Value: string);
    procedure SetIdDataSet(const Value: string);
    procedure SetIdentityField(const Value: string);
    procedure SetOnAfterCreateFields(const Value: TDataSetNotifyEvent);
    procedure SetOnBeforeCreateFields(const Value: TDataSetNotifyEvent);
    procedure SetOnCustomBeforePost(const Value: TDataSetNotifyEvent);
    procedure SetOnGetQueryParams(const Value: TDataSetNotifyEvent);
    procedure SetOrderBy(const Value: string);
    procedure SetPrimaryKeyFields(const Value: string);
    procedure SetSQL_Delete(const Value: TStrings);
    procedure SetSQL_Insert(const Value: TStrings);
    procedure SetSQL_Refresh(const Value: TStrings);
    procedure SetSQL_Select(const Value: TStrings);
    procedure SetSQL_Update(const Value: TStrings);
    procedure SetTableName(const Value: string);
    procedure SetUseSqlLocate(const Value: boolean);
    procedure SetWhere(const Value: string);
  private
    FFieldOrigins: TDictionary<string, string>; // FieldName → Origin

    // Mantis #153 - 2026-09-21: copia autorevole delle DefaultExpression, presa
    // una volta sola quando i campi vengono inizializzati dal dizionario LZ.
    // I TField la perdono: FireDAC riporta sui campi gli attributi della colonna
    // del tracciato ogni volta che il tracciato viene ricostruito, e su una
    // vista quella colonna non ha nessun DEFAULT (il DEFAULT sta sulla tabella
    // di origine). Da qui la DefaultExpression si rimette dove serve, invece di
    // sperare che la proprieta' sopravviva fino all'inserimento.
    FDefaultExpressions: TDictionary<string, string>; // FieldName → DefaultExpression
    FDefaultsInizializzati: boolean;

    // Mantis #161 - 2026-09-30: attributi dei campi automatici, fotografati alla
    // fine di DoCreateFields e rimessi in InitBufferPointers (vedi
    // FotografaAttributiAutomatici). Vale solo per l'apertura in corso: i campi
    // automatici vengono distrutti a ogni chiusura.
    FAttributiAutomatici: TArray<TAttributiCampo>;

    procedure FotografaAttributiAutomatici;
    procedure RimettiAttributiAutomatici;
    procedure InvalidateFieldOrigins;
    procedure SnapshotDefaultExpressions;
    procedure RestoreDefaultExpressions;
    // Posizione di Column fra le colonne omonime che la precedono nel risultato (0 = prima)
    function ColumnOccurrence(Column: TFDDatSColumn): Integer;
    // Elenco delle colonne di una tabella, per la risoluzione delle origini dal testo della SELECT
    procedure GetTableColumns(const TableName: string; Columns: TStrings);
    // Origine TABELLA.COLONNA ricavata dal testo della SELECT quando il server non la dichiara
    function OriginFromSelect(Column: TFDDatSColumn): string;
    procedure ValidateKeyFields;
    function FirstPrimaryKeyField: string; // Mantis #74 - 2026-09-03
    // Mantis #274 - 2026-10-22: testo dei campi binari (CHAR OCTETS, dominio UUID)
    procedure CampoBinarioGetText(Sender: TField; var Text: string; DisplayText: boolean);
  protected
    FlagRecordLimitReached: boolean;
    FOnRecordLimitReached: TNotifyEvent;
    procedure CheckRecordLimitReached;

    procedure DoBeforeOpen; override;
    procedure DoAfterOpen; override;

    procedure DoBeforeClose; override;
    procedure DoAfterClose; override;

    procedure DoBeforeGetRecords; override;
    procedure DoAfterGetRecords(AFromRecord, AToRecord: Integer); override;
    procedure DoBeforeScroll; override;
    procedure DoAfterScroll; override;

    procedure doBeforeCreateFields; virtual;
    procedure doAfterCreateFields; virtual;

    procedure DoCustomBeforePost; virtual;
    // Sanificazione (livello sicuro) dei campi di testo modificati, prima di DoCustomBeforePost
    procedure SanificaCampiTesto; virtual;
    procedure DoBeforePost; override;
    procedure DoAfterPost; override;
    procedure DoAfterDelete; override;
    procedure ConfermaAutoCommit;
    procedure DoBeforeInsert; override;
    procedure DoOnNewRecord; override;
    procedure DoBeforeDelete; override;

  public
    function DoMasterParamChanged(AMasterFieldList: TFDFieldList): boolean; override;
    procedure CheckMasterRange; override;

    procedure DoCreateFields; override;
    procedure DestroyFields; override;
    // Mantis #161 - 2026-09-30: TFDDataSet.InternalOpen la chiama subito dopo
    // SetFieldAttributes([lcAutomatic]) e prima di FTable.UpdateLayout; qui si
    // rimettono gli attributi dei campi automatici (RimettiAttributiAutomatici).
    procedure InitBufferPointers; override;
    procedure CloseCursor; override;
    procedure InternalClose; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    /// //////////
  private
    needInitFields: boolean;
    needRebuildFields: boolean;
    ParamsChangedByLoadParamsFromMaster: boolean;
  private
    FControlsExtNesting: Integer;
    FSavedBlockReadSize: Integer;
    FSavedDetailDelay: Integer;
    FNewRecordOptions: TNewRecordOptions;
    FOnInitFields: TDataSetNotifyEvent;
    InnerUpdateObject: TFDUpdateSQL;
    procedure DoProcessUpdateRequest(ARequest: TFDUpdateRequest; AOptions: TFDUpdateRowOptions); override;
    function DoFetch(ARow: TFDDatSRow; AColumn: Integer; ARowOptions: TFDPhysFillRowOptions): boolean; override;
    /// //////////
  private
    function GetAutoIncFields: string;
    function IsExternalField(const s: string): boolean;
    function GetExternalField(const s: string): TField;
    procedure SetAutoIncFields(const Value: string);
    procedure SetFieldsReadOnly;
    procedure SetNewRecordOptions(const Value: TNewRecordOptions);
    procedure SetRequiredForJoinFields;

    procedure UpdateFieldAttributes;
    procedure UpdateDefaultExpressions;
    function NormalizeDefaultExpression(const Value: string): string;
    procedure DumpDefaultExpressions;
    function IsContextDefault(const RawExpression: string): boolean;
    procedure UpdateFieldOrigins;
  public
    /// /////////////////////////////////////
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    ///
  public
    procedure BuildFields(const clear: boolean = false);
    // Variante estesa di DisableControls per lo scorrimento DA CODICE:
    // - sospende il ridisegno delle griglie (dsBlockRead), niente scroll;
    // - MANTIENE vivo il master/detail (il VCL DisableControls invece lo
    // disattiva);
    // - forza il refresh immediato dei dettagli (DetailDelay := 0), altrimenti
    // col ritardo il dettaglio resterebbe stale nel loop.
    // Salva/ripristina BlockReadSize e DetailDelay. Chiamate annidabili: solo
    // l'ultima EnableControlsExt ripristina lo stato precedente.
    procedure DisableControlsExt;
    procedure EnableControlsExt;

    procedure AddWhereCondition(const Condition: string);
    procedure ApplyFilter(const Filter: string);
    procedure CheckBeforePost;
    // Mantis #150 - 2026-09-21: rilettura dei campi di collegamento dal master
    // subito prima della scrittura. Vedi il commento sull'implementazione.
    procedure ReloadLinkFieldsFromMaster;

    // procedure aaaCopyLookupFields(lkDataSet: TDataset; LookupString: string; ClearFields: boolean; Field2Exclude: string = '');
    procedure CopyMappingFields(lkDataSet: TDataset; Mappings: TStringList; ClearFields: boolean; Field2Exclude: string = '');
    procedure ClearParamValues;

    procedure LoadParamsFromMaster;
    function CopyParams(Master: TzFbDataSet; const OverrideParamValues: boolean = true): boolean;

    function CanInsert: boolean;
    function CanUpdate: boolean;
    function CanDelete: boolean;

    function GetDebugInfo: string;
    function DebugInsertString: string;
    function DebugUpdateString: string;

    function FieldOrigin(Field: TField): string;
    function GetFieldByOrigin(const Origin: string): TField;
    function GetFieldNameByOrigin(const Origin: string): string;
    function GetFieldTableName(Field: TField): string;
    procedure GetParamValues(aParams: TParams);

    function ParamExists(const ParamName: string): boolean;
    ///
    function IsCalcField(FieldName: string): boolean; overload;
    function IsCalcField(Field: TField): boolean; overload;
    function IsParamUID(FieldName: string): boolean;
    function IsGeneratorField(FieldName: string): boolean;
    function IsDetailParamField(FieldName: string): boolean;
    function IsJoinedField(FieldName: string): boolean; overload;
    function IsJoinedField(Field: TField): boolean; overload;
    function IsMasterDetailParam(ParamName: string): boolean;
    function IsServerCalcField(FieldName: string): boolean; overload;
    function IsServerCalcField(Field: TField): boolean; overload;
    /// /////////////////////////////////////
    property OpenTime: TTimeSpan read GetOpenTime;
    ///
    function RecordCountFromServer(const CountSQL: string = ''): Largeint;

    function RequiredFieldOk(Field: TField): boolean;
    function RequiredFieldsOk: boolean;
    procedure SetParamValues(aParams: TParams);

    //
    // cambia la SELECT e rilancia l'errore (dopo aver ripristinato la precedente)
    procedure ChangeSQL(const NewSql: string);
    // come ChangeSQL ma non rilancia: restituisce False se il cambio fallisce
    function TryChangeSQL(const NewSql: string): boolean;
    function RevetNeeded: boolean;
    procedure RevertSQL(const Activate: boolean = false);
    procedure ReOpen(const dummy: boolean = false);
    function ReopenLocate(const LocateFieldName: string): boolean;
    function Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean; override;
    function LocateSQL(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
    function LocateNonSQL(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
    function Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant; override;
    function OID: Int64;
  public
    //
    property GeneratorName: string read GetGeneratorName write SetGeneratorName;
    property PrimaryKeyFields: string read GetPrimaryKeyFields write SetPrimaryKeyFields;
    property AutoIncFields: string read GetAutoIncFields write SetAutoIncFields;
    procedure ApplyDefaultExpression(Field: TField);
    //
    function GetRecordCountSQL: string;
    property Where: string read GetWhere write SetWhere;
    property MainWhereClause: string read GetWhere write SetWhere;
    property OrderBy: string read GetOrderBy write SetOrderBy;
    property OrderClause: string read GetOrderBy write SetOrderBy;
    //
    property CountSQL: TStrings read FCountSQL write SetCountSQL;
    property DefaultSQL: TStrings read FDefaultSQL write SetDefaultSQL;
    property SelectSQL: TStrings read GetSQL_Select write SetSQL_Select;
    property InsertSQL: TStrings read GetSQL_Insert write SetSQL_Insert;
    property UpdateSQL: TStrings read GetSQL_Update write SetSQL_Update;
    property DeleteSQL: TStrings read GetSQL_Delete write SetSQL_Delete;
    property RefreshSQL: TStrings read GetSQL_Refresh write SetSQL_Refresh;
    // alias per SQL_Select
    property SQL_Select: TStrings read GetSQL_Select write SetSQL_Select;
    property SQL_Insert: TStrings read GetSQL_Insert write SetSQL_Insert;
    property SQL_Update: TStrings read GetSQL_Update write SetSQL_Update;
    property SQL_Delete: TStrings read GetSQL_Delete write SetSQL_Delete;
    property SQL_Refresh: TStrings read GetSQL_Refresh write SetSQL_Refresh;
    // Mantis #257 - 2026-10-29: parti dell'UPDATE automatico, valorizzate da
    // TzSystem quando UpdateSQL nasce da Build_Sql_Update: colonne
    // aggiornabili nell'ordine della tabella (Get_FieldNames senza i campi
    // calcolati), colonne della chiave, WHERE completa (Calc_WhereByKeyFields)
    // e colonne del RETURNING (Get_FieldNames con i calcolati). AutoUpdate va
    // acceso DOPO aver scritto UpdateSQL: fotografa il testo, e se in seguito
    // qualcuno lo cambia il dataset non lo riscrive piu'.
    property AutoUpdate: boolean read FAutoUpdate write SetAutoUpdate;
    property AutoUpdateColumns: TStrings read FAutoUpdateColumns write SetAutoUpdateColumns;
    property AutoUpdateKeyFields: TStrings read FAutoUpdateKeyFields write SetAutoUpdateKeyFields;
    property AutoUpdateWhere: string read FAutoUpdateWhere write FAutoUpdateWhere;
    property AutoUpdateReturning: TStrings read FAutoUpdateReturning write SetAutoUpdateReturning;
  published
    property ActivationMode: TActivationMode read FActivationMode write SetActivationMode default amAutomatic;
    property Active stored false;
    property AutoCommit: boolean read FAutoCommit write FAutoCommit default true;
    property AutoCreateFields: boolean read FAutoCreateFields write FAutoCreateFields default true;
    property Database: TFDCustomConnection read GetDatabase write SetDatabase;
    property IdDataSet: string read FIdDataSet write SetIdDataSet;
    property IdentityField: string read FIdentityField write SetIdentityField; { TODO : FDAC: eliminare }
    property FieldNameOID: string read FFieldNameOID write FFieldNameOID;
    property ReopenAfterPost: boolean read FReopenAfterPost write FReopenAfterPost default false;
    property ReportPipe: string read FReportPipe write FReportPipe;
    // True: al Post i campi stringa e memo modificati passano da TzSanificazione (livello sicuro).
    // False sui dataset di appoggio degli import, che devono conservare il dato grezzo.
    property Sanification: boolean read FSanification write FSanification default true;
    // Mantis #183 - 2026-10-08: vedi TzFetchOption. Salvata nel .dfm solo se
    // diversa dal predefinito.
    property ExtendedFetchOptions: TzFetchOptions read GetExtendedFetchOptions write SetExtendedFetchOptions default DefaultExtendedFetchOptions;
    property TableName: string read FTableName write SetTableName;
    property UseSqlLocate: boolean read FUseSqlLocate write SetUseSqlLocate default true; // ZZ 26.08.2022 era default = false
    // DIV-LOC-1: vero = dopo una LocateSQL senza risultati il dataset resta filtrato (anche vuoto),
    // come vogliono i campi di scelta; falso (predefinito) = torna l'elenco completo, sul record di prima
    property MantieniElencoSeNonTrova: boolean read FMantieniElencoSeNonTrova write FMantieniElencoSeNonTrova default false;
    // Mantis #257 - 2026-10-29: True = con l'UPDATE automatico (AutoUpdate)
    // si scrivono solo le colonne cambiate rispetto al record letto; False,
    // predefinito, = UPDATE completo di sempre. Senza effetto sugli UpdateSQL
    // scritti a mano.
    property UpdateChangedFields: boolean read FUpdateChangedFields write FUpdateChangedFields default False;
  published
    property DefaultValues: TStrings read FDefaultValues write SetDefaultValues;
    property NewRecordOptions: TNewRecordOptions read FNewRecordOptions write SetNewRecordOptions;

    property OnAfterCreateFields: TDataSetNotifyEvent read FOnAfterCreateFields write SetOnAfterCreateFields;
    property OnInitFields: TDataSetNotifyEvent read FOnInitFields write FOnInitFields;
    property OnAfterLookupFieldsCopied: TAfterLookupFieldsCopied read FOnAfterLookupFieldsCopied write FOnAfterLookupFieldsCopied;
    property OnBeforeCreateFields: TDataSetNotifyEvent read FOnBeforeCreateFields write SetOnBeforeCreateFields;
    property OnCustomBeforePost: TDataSetNotifyEvent read FOnCustomBeforePost write SetOnCustomBeforePost;
    property OnGetQueryParams: TDataSetNotifyEvent read FOnGetQueryParams write SetOnGetQueryParams;
    property OnRecordLimitReached: TNotifyEvent read FOnRecordLimitReached write FOnRecordLimitReached;
  public
    procedure InitForwardOnly(const doDisableControls: boolean = true);
  end;

  TFDConnectionHelper = class helper for TFDConnection
  public
    function Gen_ID(const GeneratorName: string; Step: Int64): Int64;
  end;

  // DIV-DAT-6: classe vuota, resta per i DFM che la citano. La logica delle
  // procedure sta in TzStoredProc (unit zStoredProc, in zBase).
  TzFbStoredProc = class(TFDStoredProc)

  end;

  TFDStoredProcHelper = class helper for TFDStoredProc
  public
    // Selezionabile = True descrive la lettura come SELECT * FROM invece che EXECUTE PROCEDURE
    function DebugString(const Selezionabile: boolean = false): string;
    function ParamExists(const ParamName: string): boolean;
    function ParamByName(const ParamName: string): TFDParam;

    function InputParamsCount: Integer;
    function OutputParamsCount: Integer;
  end;

  TFDAdaptedDataSetHelper = Class Helper for TFDAdaptedDataSet
  public
    procedure CheckEditMode;

    procedure SetFieldValue(Field: TField; Value: Variant); overload; // consente di valorizzare campi readonly
    procedure SetFieldValue(const FieldName: string; Value: Variant); overload; // consente di valorizzare campi readonly

    procedure ClearFieldValue(const FieldName: string); overload;
    procedure ClearFieldValue(Field: TField); overload;
    procedure ClearFields(FieldsToClear: string);

    procedure CopyFieldValues(Source: TDataset; DoPost: boolean);
    procedure CopyRecord(Source: TDataset; DoPost: boolean);
    procedure DeleteAll;
    procedure DuplicateRecord(const DoPost: boolean; const Fields2Exclude: string);
    function IsDetailOf(DataSet: TDataset): boolean;
    function FieldExists(const FieldName: String): boolean;
    procedure RefreshCalcFields;

  End;

  TFDParamsHelper = class helper for TFDParams
    function ParamExists(const ParamName: string): boolean;
  end;

  TFDParamHelper = class helper for TFDParam
    function IsString: boolean;
    function IsInteger: boolean;
    function IsFloat: boolean;
    function IsNumeric: boolean;
    function IsDate: boolean;
    function IsTime: boolean;
    function IsDateTime: boolean;
    function IsBoolean: boolean;
    function IsBlob: boolean;
    function IsMemo: boolean;
    //
    function IsInputParam: boolean;
    function IsOutputParam: boolean;
  end;

  /// //////////////////////////////////////////////////////////////////////////
  //
  // https: // www.uweraabe.de/Blog/2010/08/07/a-magical-gathering-part-2/
  //
  TDataSetEnumerator = class
  private
    FBookmark: TBookmark;
    FDataSet: TDataset;
    FMoveToFirst: boolean;
    FWasActive: boolean;
    function GetCurrent: Variant;
  public
    constructor Create(ADataSet: TDataset);
    destructor Destroy; override;
    function MoveNext: boolean;
    property Current: Variant read GetCurrent;
  end;

type
  TDataSetHelper = class helper for TDataset
  private
    function GetCurrentRec: Variant;
  public
    function GetEnumerator: TDataSetEnumerator;
    property CurrentRec: Variant read GetCurrentRec;
  public
    procedure ForEach(proc: TProc<boolean>);
  public
    function CreateCalculatedField(aFieldClass: TFieldClass; const aFieldName: string; aSize: Integer = 0): TField;
  end;

function CreateFbDataSet(Owner: TComponent; Connection: TFDConnection; ReadTrans, WriteTrans: TFDCustomTransaction; const UniDirectional: boolean = false): TzFbDataSet;

function IsStringType(FieldType: TFieldType): boolean;
function IsIntegerType(FieldType: TFieldType): boolean;
function IsFloatType(FieldType: TFieldType): boolean;
function IsNumericType(FieldType: TFieldType): boolean;
function IsDateType(FieldType: TFieldType): boolean;
function IsTimeType(FieldType: TFieldType): boolean;
function IsDateTimeType(FieldType: TFieldType): boolean;
function IsBooleanType(FieldType: TFieldType): boolean;
function IsBlobType(FieldType: TFieldType): boolean;
function IsMemoType(FieldType: TFieldType): boolean;

// Mantis #274 - 2026-10-22: valore di un campo binario come testo esadecimale
// maiuscolo, due cifre per byte, senza separatori (la forma del letterale X'...'
// di Firebird). Vuoto per un valore vuoto
function TestoEsadecimale(const Valore: TBytes): string;

var
  // Dataset la cui apertura e' iniziata e non e' ancora finita, dove
  // "apertura" comprende la preparazione della query che la precede
  // (BuildFields). nil quando non c'e' niente in corso.
  //
  // La legge chi raccoglie il contesto di un errore del database
  // (zExceptions.firedac): nell'OnError della connessione il dataset non e'
  // altrimenti raggiungibile - arrivano TzFbDatabase e TFDPhysFBCommand - e
  // non e' ancora Active, quindi non compare nemmeno fra i dataset aperti
  // della connessione.
  //
  // E' una variabile esposta qui, e non una chiamata verso zExceptions,
  // perche' la dipendenza deve andare in un verso solo: il livello dati
  // dichiara cosa sta facendo, chi raccoglie il contesto dell'errore viene a
  // leggerlo. Con la chiamata all'incontrario ogni funzione di diagnostica
  // nuova diventava una riga in piu' dentro il dataset.
  //
  // Chi la valorizza la azzera SOLO se contiene ancora il proprio dataset: le
  // aperture si annidano (un dettaglio apre prima il suo master) e la
  // preparazione di un dataset puo' scattare dentro l'apertura di un altro,
  // quindi il completamento di quella interna non deve cancellare la traccia
  // di quella esterna, che e' ancora in corso.
  //
  // Chi la consuma (attribuendo un errore al dataset) la azzera: un'apertura
  // fallita non arriva mai a DoAfterOpen e senza quell'azzeramento la traccia
  // resterebbe valorizzata, facendo attribuire a questa query l'errore
  // successivo, che non c'entra niente.
  CurrentOpeningDataSet: TzFbDataSet = nil;

implementation

uses
  System.Variants,
  System.StrUtils,
  System.DateUtils,
  Data.DBConsts,
  zSql.SqlTxtRtns,
  FireDAC.Stan.Util,
  zExceptions.FireDAC,
  zDiagnostica.Log.Perf;

var
  sizFbDataSet: TSiSession;
  siRed: TSiSession;

  //
type
  TDataSetAccess = class(TDataset);

  TSqlOperator = (soEqual, soGraterOrEqual, soGraterThen);

function CreateFbDataSet(Owner: TComponent; Connection: TFDConnection; ReadTrans, WriteTrans: TFDCustomTransaction; const UniDirectional: boolean = false): TzFbDataSet;
begin
  Result := TzFbDataSet.Create(Owner);
  Result.Connection := Connection;
  Result.Transaction := ReadTrans;
  Result.UpdateTransaction := WriteTrans;
  Result.FetchOptions.UniDirectional := UniDirectional;

  if UniDirectional then
  begin
    Result.FetchOptions.Mode := fmOnDemand;
    Result.FetchOptions.RecsMax := -1;
    Result.ResourceOptions.SilentMode := true;
  end;
end;

function TestoEsadecimale(const Valore: TBytes): string;
var
  Indice: Integer;
begin
  Result := '';
  for Indice := 0 to High(Valore) do
    Result := Result + IntToHex(Valore[Indice], 2);
end;

function IsStringType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftString, ftFixedChar, ftWideString, ftFixedWideChar];
end;

function IsIntegerType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftLongWord, ftShortint, ftByte, ftSingle];
end;

function IsFloatType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended];
end;

function IsNumericType(FieldType: TFieldType): boolean;
begin
  Result := IsIntegerType(FieldType) or IsFloatType(FieldType);
end;

function IsDateType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftDate];
end;

function IsTimeType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftTime];
end;

function IsDateTimeType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftDate, ftTime, ftDateTime, ftTimeStamp];
end;

function IsBlobType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftWideMemo];
end;

function IsMemoType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftMemo, ftFmtMemo, ftWideMemo];
end;

function IsBooleanType(FieldType: TFieldType): boolean;
begin
  Result := FieldType in [ftBoolean];
end;

{ TDataSetEventKindHelper }

class function TDataSetEventKindHelper.FromString(const s: String): TDataSetEventKind;
var
  i: Integer;
begin
  Result := deNone;

  i := IndexStr(s, ['None', 'AfterCancel', 'AfterClose', 'AfterDelete', 'AfterEdit', 'AfterInsert', 'AfterOpen', 'AfterPost', 'AfterScroll', 'BeforeCancel', 'BeforeClose', 'BeforeDelete', 'deBeforeEdit', 'BeforeInsert', 'BeforeOpen', 'BeforePost',
    'BeforeScroll', 'OnCalcFields', 'OnNewRecord', 'BeforeRefresh', 'AfterRefresh', 'OnEnableControls', 'OnDisableControls', 'OnEndScroll', 'OnCustomBeforePost', 'OnGetQueryParams', 'OnBeforeCreateFields', 'OnAfterCreateFields']);

  if i >= 0 then
    Result := TDataSetEventKind(i);
end;

function TDataSetEventKindHelper.ToString: string;
begin
  case self of
    deNone:
      Result := '';
    deAfterCancel:
      Result := 'AfterCancel';
    deAfterClose:
      Result := 'AfterClose';
    deAfterDelete:
      Result := 'AfterDelete';
    deAfterEdit:
      Result := 'AfterEdit';
    deAfterInsert:
      Result := 'AfterInsert';
    deAfterOpen:
      Result := 'AfterOpen';
    deAfterPost:
      Result := 'AfterPost';
    deAfterScroll:
      Result := 'AfterScroll';
    deBeforeCancel:
      Result := 'BeforeCancel';
    deBeforeClose:
      Result := 'BeforeClose';
    deBeforeDelete:
      Result := 'BeforeDelete';
    deBeforeEdit:
      Result := 'BeforeEdit';
    deBeforeInsert:
      Result := 'BeforeInsert';
    deBeforeOpen:
      Result := 'BeforeOpen';
    deBeforePost:
      Result := 'BeforePost';
    deBeforeScroll:
      Result := 'BeforeScroll';
    deOnCalcFields:
      Result := 'OnCalcFields';
    deOnNewRecord:
      Result := 'OnNewRecord';
    deBeforeRefresh:
      Result := 'BeforeRefresh';
    deAfterRefresh:
      Result := 'AfterRefresh';
    deOnEnableControls:
      Result := 'OnEnableControls';
    deOnDisableControls:
      Result := 'OnDisableControls';
    deOnEndScroll:
      Result := 'OnEndScroll';
    OnCustomBeforePost:
      Result := 'OnCustomBeforePost';
    deOnGetQueryParams:
      Result := 'OnGetQueryParams';
    deOnBeforeCreateFields:
      Result := 'OnBeforeCreateFields';
    deOnAfterCreateFields:
      Result := 'OnAfterCreateFields';
  end;
end;

function FormatSQLCondition(const FieldName: string; aOperator: TSqlOperator; const Value: string; FieldType: TFieldType; Exact: boolean): string;
const
  ServerDateFmt = #39 + 'dd.mm.yyyy' + #39;
  TrueExpr = '0=0';
  NullDate = 0;
var
  EmptyValue: boolean;
  FieldValue: string;
  DateValue: TDateTime;

  function CheckValue(Value: string): string;
  begin
    Result := StringReplace(Value, #39, #39#39, [rfReplaceAll]);
  end;

begin
  Result := '';
  FieldValue := '';
  DateValue := NullDate;

  if FieldType in [ftDate, ftTime, ftDateTime] then
  begin
    DateValue := StrToDateDef(Value, NullDate);
    EmptyValue := (DateValue = NullDate);
    FieldValue := FormatDateTime(ServerDateFmt, DateValue);
  end
  else
  begin
    FieldValue := CheckValue(Value);
    EmptyValue := FieldValue = '';
    if FieldType in [ftString, ftWideString] then
      FieldValue := QuotedStr(FieldValue);
  end;

  if EmptyValue then
  begin
    Result := TrueExpr;
    Exit;
  end;

  case aOperator of
    soEqual:
      begin
        if (FieldType = ftDateTime) then
        begin
          DateValue := DateValue + 1;
          Result := Format('(%s %s %s) and (%s < %s)', [FieldName, '>=', FieldValue, FieldName, FormatDateTime(ServerDateFmt, DateValue)]);
        end
        else
          Result := Format('%s %s %s', [FieldName, '=', FieldValue]);
      end;
    soGraterOrEqual:
      begin
        Result := Format('%s %s %s', [FieldName, '>=', FieldValue]);
      end;
    soGraterThen:
      begin
        Result := Format('%s %s %s', [FieldName, '>', FieldValue]);
      end;
  end;
end;

function StartingWith(const s: string; const SubStr: string): boolean;
var
  Token: string;
begin
  Token := System.Copy(s, 0, Length(SubStr));
  Result := SameText(SubStr, Token);
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TNewRecordOptions }

constructor TNewRecordOptions.Create;
begin
  inherited Create;
  FParamsToFields := true;
  FParamsToFieldsExcluded := '';
  FMasterToFields := true;
  FMasterToFieldsExcluded := '';
end;

procedure TNewRecordOptions.Assign(Source: TPersistent);
var
  Item: TNewRecordOptions;
begin
  if Source is TNewRecordOptions then
  begin
    Item := Source as TNewRecordOptions;

    FParamsToFields := Item.ParamsToFields;
    FParamsToFieldsExcluded := Item.ParamsToFieldsExcluded;
    FMasterToFields := Item.MasterToFields;
    FMasterToFieldsExcluded := Item.MasterToFieldsExcluded;
  end
  else
    inherited;
end;

procedure TNewRecordOptions.SetMasterToFieldsExcluded(const Value: string);
begin
  FMasterToFieldsExcluded := Value.Replace(',', ';', [rfReplaceAll]);
end;

procedure TNewRecordOptions.SetParamsToFieldsExcluded(const Value: string);
begin
  FParamsToFieldsExcluded := Value.Replace(',', ';', [rfReplaceAll]);
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TFDConnectionHelper }

function TFDConnectionHelper.Gen_ID(const GeneratorName: string; Step: Int64): Int64;
var
  i: Integer;
begin
  // DIV-TRA-3: il nome entra nel testo SQL, quindi deve essere un identificatore
  // Firebird non quotato (lettera o _, poi lettere, cifre, _ e $)
  if GeneratorName = '' then
    raise EArgumentException.Create('Gen_ID: nome del generatore vuoto');

  for i := 1 to Length(GeneratorName) do
    if not (CharInSet(GeneratorName[i], ['A'..'Z', 'a'..'z', '_']) or
      ((i > 1) and CharInSet(GeneratorName[i], ['0'..'9', '$']))) then
      raise EArgumentException.Create('Gen_ID: nome del generatore non valido: ' + GeneratorName);

  Result := ExecSQLScalar('SELECT GEN_ID(' + GeneratorName + ', ' + Step.ToString + ') FROM RDB$DATABASE');
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TFDStoredProcHelper }

function TFDStoredProcHelper.DebugString(const Selezionabile: boolean = false): string;
var
  Param: TFDParam;
  indent: string;
  i, pCount, Scritti: Integer;
begin
  // DIV-SPR-6: una procedura letta come cursore si descrive come SELECT * FROM
  if Selezionabile then
    Result := 'SELECT * FROM ' + StoredProcName
  else
    Result := 'EXECUTE PROCEDURE ' + StoredProcName;

  pCount := InputParamsCount;
  Scritti := 0;

  if pCount > 0 then
  begin
    Result := Result + '(';

    indent := ''.PadLeft(Result.Length, ' ');

    for i := 0 to ParamCount - 1 do
    begin
      Param := Params[i];

      if Param.IsInputParam then
      begin

        if Param.IsNull then
          Result := Result + 'NULL'
        else
          if Param.IsNumeric then
            Result := Result + Param.asString.Replace(',', '.')
          else
            if Param.IsDateTime then
              Result := Result + AnsiQuotedStr(Param.asString, #39).Replace('/', '.')
            else
              Result := Result + AnsiQuotedStr(Param.asString, #39);

        // DIV-SPR-5: il separatore dipende da quanti parametri in ingresso sono gia' scritti
        if Scritti < pCount - 1 then
          Result := Result + ', ' + sLineBreak + indent;
        Inc(Scritti);
      end;
    end;

    Result := Result + ');';
  end;
end;

function TFDStoredProcHelper.InputParamsCount: Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to Params.Count - 1 do
    if Params[i].IsInputParam then
      inc(Result);
end;

function TFDStoredProcHelper.OutputParamsCount: Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to Params.Count - 1 do
    if Params[i].IsOutputParam then
      inc(Result);
end;

function TFDStoredProcHelper.ParamByName(const ParamName: string): TFDParam;
begin
  Result := Params.ParamByName(ParamName);
end;

function TFDStoredProcHelper.ParamExists(const ParamName: string): boolean;
begin
  Result := Params.ParamExists(ParamName);
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TFDAdaptedDataSetHelper }

procedure TFDAdaptedDataSetHelper.CheckEditMode;
begin
  if Active then
  begin
    if State in dsEditModes then
    else
      edit;
  end;
end;

procedure TFDAdaptedDataSetHelper.CopyRecord(Source: TDataset; DoPost: boolean);
begin
  CopyFieldValues(Source, DoPost);
end;

procedure TFDAdaptedDataSetHelper.DeleteAll;
begin
  Cancel;
  if recordCount = 0 then
    Exit;
  First;
  while not EOF do
    Delete;
end;

procedure TFDAdaptedDataSetHelper.DuplicateRecord(const DoPost: boolean; const Fields2Exclude: string);
var
  RecArray: array [0 .. 255] of Variant;
  i: Integer;
  FieldsToCopy: TStringList;
  // Pos: Integer;
  FieldName: string;
  GeneratorField: TField;
  GeneratorValue: Integer;
  ChiaveDaAzzerare: string; // Mantis #89 - 2026-09-12

  // Mantis #89 - 2026-09-12: primo campo della chiave primaria, restituito soltanto quando e'
  // un identificativo numerico assegnato dal database.
  //
  // Solo il primo campo: sulle chiavi composte dei dataset di dettaglio i campi successivi
  // sono il collegamento al record padre (ID_INTERVENTO_SIA;ID_DESTINATARIO_EFFETTIVO) e
  // azzerarli spezzerebbe il legame con il master.
  //
  // Solo se numerico: sulle chiavi naturali testuali (GRUPPO, AULA, CODICE_MATERIALE) il
  // valore lo digita l'utente e non lo rigenera nessun trigger; toglierlo dalla copia gli
  // svuoterebbe il campo invece di risolvergli un errore.
  function PrimaryKeyFieldToReset: string;
  var
    Chiave: string;
    Campi: TArray<string>;
    Campo: TField;
  begin
    Result := '';

    Chiave := '';
    if self is TzFbDataSet then
      // include il recupero su FPrimaryKey introdotto col Mantis #74, che sopravvive ai
      // rebuild dei campi di FireDAC quando UpdateOptions.KeyFields viene azzerato.
      Chiave := TzFbDataSet(self).FirstPrimaryKeyField;

    if Chiave.Trim = '' then
    begin
      Campi := UpdateOptions.KeyFields.Split([';', ',']);

      if Length(Campi) = 0 then
        Exit;

      Chiave := Campi[0];
    end;

    Chiave := Chiave.Trim;

    if Chiave = '' then
      Exit;

    Campo := FindField(Chiave);

    if not Assigned(Campo) then
      Exit;

    // i campi calcolati e di lookup non arrivano al database: non c'e' niente da azzerare
    if Campo.FieldKind <> fkData then
      Exit;

    if not(Campo.DataType in [ftSmallint, ftInteger, ftLargeint, ftWord, ftAutoInc]) then
      Exit;

    Result := Campo.FieldName;
  end;

begin
  GeneratorField := nil;
  GeneratorValue := 0;

  FieldsToCopy := TStringList.Create;
  try
    GetFieldNames(FieldsToCopy);

    for FieldName in Fields2Exclude.Replace(',', ';', [rfReplaceAll]).Split([';']) do
      if FieldsToCopy.IndexOf(FieldName) <> -1 then
        FieldsToCopy.Delete(FieldsToCopy.IndexOf(FieldName));

    // Mantis #89 - 2026-09-12: toglie dalla copia l'identificativo della riga anche quando il
    // dataset non ha un generatore. Le tabelle a OID ricevono la chiave da OBJECT_CREATE nel
    // trigger BEFORE INSERT e non hanno generatore, quindi la salvaguardia qui sotto non
    // scattava: la chiave primaria finiva ricopiata tale e quale nel nuovo record e il
    // vincolo di univocita' lo rifiutava (SIA_INTERVENTI, ID_INTERVENTO_SIA = 99086).
    if UpdateOptions.GeneratorName.Trim = '' then
    begin
      ChiaveDaAzzerare := PrimaryKeyFieldToReset;

      if (ChiaveDaAzzerare <> '') and (FieldsToCopy.IndexOf(ChiaveDaAzzerare) <> -1) then
        FieldsToCopy.Delete(FieldsToCopy.IndexOf(ChiaveDaAzzerare));
    end;

    // Pos := 1;
    // while Pos <= Length(ExcludeFields) do
    // begin
    // FieldName := ExtractFieldName(ExcludeFields, Pos);
    //
    // if Assigned(FindField(FieldName)) then
    // if FieldsToCopy.IndexOf(FieldName) <> -1 then
    // FieldsToCopy.Delete(FieldsToCopy.IndexOf(FieldName));
    // end;

    try
      //
      for i := 0 to FieldsToCopy.Count - 1 do
        RecArray[i] := FieldByName(FieldsToCopy[i]).Value;
      //
      Insert;

      if UpdateOptions.GeneratorName <> '' then
      begin
        GeneratorField := FindField(UpdateOptions.KeyFields);
        if Assigned(GeneratorField) then
          GeneratorValue := GeneratorField.AsInteger;
      end;
      //
      for i := 0 to FieldsToCopy.Count - 1 do
        if FieldByName(FieldsToCopy[i]).CanModify then
          FieldByName(FieldsToCopy[i]).Value := RecArray[i];
      //
      if UpdateOptions.GeneratorName <> '' then
        if Assigned(GeneratorField) then
          GeneratorField.AsInteger := GeneratorValue;
      //

      if DoPost then
        Post;
    except
      on EDatabaseError do
        Cancel;
    end;
  finally
    FreeAndNil(FieldsToCopy);
  end;
end;

function TFDAdaptedDataSetHelper.FieldExists(const FieldName: String): boolean;
begin
  Result := Assigned(FindField(FieldName));
end;

function TFDAdaptedDataSetHelper.IsDetailOf(DataSet: TDataset): boolean;
begin
  Result := false;

  if Assigned(DataSource) then
    if Assigned(DataSource.DataSet) then
      if DataSource.DataSet = DataSet then
        Result := true;
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TFDParamsHelper }

function TFDParamsHelper.ParamExists(const ParamName: string): boolean;
begin
  Result := Assigned(FindParam(ParamName));
end;

/// ////////////////////////////////////////////////////////////////////////////

{ TFDParamHelper }

function TFDParamHelper.IsBlob: boolean;
begin
  Result := IsBlobType(DataType);
end;

function TFDParamHelper.IsBoolean: boolean;
begin
  Result := IsBooleanType(DataType);
end;

function TFDParamHelper.IsDate: boolean;
begin
  Result := IsDateType(DataType);
end;

function TFDParamHelper.IsDateTime: boolean;
begin
  Result := IsDateTimeType(DataType);
end;

function TFDParamHelper.IsFloat: boolean;
begin
  Result := IsFloatType(DataType);
end;

function TFDParamHelper.IsInteger: boolean;
begin
  Result := IsIntegerType(DataType);
end;

function TFDParamHelper.IsMemo: boolean;
begin
  Result := IsMemoType(DataType);
end;

function TFDParamHelper.IsNumeric: boolean;
begin
  Result := IsNumericType(DataType);
end;

function TFDParamHelper.IsString: boolean;
begin
  Result := IsStringType(DataType);
end;

function TFDParamHelper.IsTime: boolean;
begin
  Result := IsTimeType(DataType);
end;

function TFDParamHelper.IsInputParam: boolean;
begin
  Result := ParamType in [ptInput, ptInputOutput];
end;

function TFDParamHelper.IsOutputParam: boolean;
begin
  Result := ParamType in [ptOutput, ptInputOutput];
end;

constructor TzFbTransaction.Create(AOwner: TComponent);
begin
  inherited;
  SavePoints := TStack<string>.Create;
end;

destructor TzFbTransaction.Destroy;
begin
  FreeAndNil(SavePoints);
  inherited;
end;

procedure TzFbTransaction.CloseTransaction(const doCommit: boolean = true);
begin
  if not Active then
    Exit;

  if doCommit then
    Commit
  else
    Rollback;
end;

procedure TzFbTransaction.SetSavePoint(const SavePoint: string);
begin

  if Active then
    CommitRetaining;

  SavePoints.Push(SavePoint);
end;

procedure TzFbTransaction.RollBackToSavePoint(const SavePoint: string);
begin
  // DIV-TRA-2: il nome si controlla prima, cosi' un errore di programmazione non annulla il lavoro
  if SavePoints.Count = 0 then
    raise Exception.Create('Punto di salvataggio "' + SavePoint + '" mai impostato: nessun annullamento eseguito');

  if not SameText(SavePoints.Peek, SavePoint) then
    raise Exception.Create('Punto di salvataggio "' + SavePoint + '" diverso dall''ultimo impostato ("' + SavePoints.Peek + '"): nessun annullamento eseguito');

  SavePoints.Pop;

  if Active then
    RollbackRetaining;
end;

procedure TzFbTransaction.BeginOperazioneAtomica;
begin
  Inc(FOperazioniAtomiche);
end;

procedure TzFbTransaction.EndOperazioneAtomica;
begin
  if FOperazioniAtomiche > 0 then
    Dec(FOperazioniAtomiche);
end;

function TzFbTransaction.OperazioneAtomicaAperta: boolean;
begin
  Result := FOperazioniAtomiche > 0;
end;

constructor TzFbDataSet.Create(AOwner: TComponent);
begin
  inherited;
  self.OnError := zExceptions.FireDAC.DataSetErrorHandler.HandleDataSetError;
  FControlsExtNesting := 0;
  FSavedBlockReadSize := 0;
  FSavedDetailDelay := 0;

  FIdentityField := '';
  FFieldNameOID := '';
  FPrimaryKey := ''; // Mantis #74 - 2026-09-03

  needInitFields := true;
  needRebuildFields := false;
  ParamsChangedByLoadParamsFromMaster := false;

  FAutoCommit := true;

  FlagRecordLimitReached := false;
  FOnRecordLimitReached := nil;

  FActivationMode := amAutomatic;
  FOnAfterLookupFieldsCopied := nil;
  FOnInitFields := nil;

  FFieldOrigins := TDictionary<string, string>.Create;
  FDefaultExpressions := TDictionary<string, string>.Create; // Mantis #153 - 2026-09-21
  FDefaultsInizializzati := false; // Mantis #153 - 2026-09-21
  InnerUpdateObject := TFDUpdateSQL.Create(self);
  UpdateObject := InnerUpdateObject;
  // Mantis #257 - 2026-10-29
  FUpdateChangedFields := False;
  FAutoUpdate := false;
  FAutoUpdateColumns := TStringList.Create;
  FAutoUpdateKeyFields := TStringList.Create;
  FAutoUpdateReturning := TStringList.Create;
  FAutoUpdateWhere := '';
  FUltimoUpdateSQL := '';

  StopWatch := TStopWatch.Create;
  InLocate := false;
  LocateWhere := '';
  FReportPipe := '';
  FSanification := true;
  FExtendedFetchOptions := DefaultExtendedFetchOptions; // Mantis #183 - 2026-10-08
  FUseSqlLocate := true; // ZZ 26.08.2022 era false
  FDefaultSQL := TStringList.Create;
  FCountSQL := TStringList.Create;
  FDefaultValues := TStringList.Create;
  FNewRecordOptions := TNewRecordOptions.Create;
  FActivationMode := amAutomatic;
  FAutoCreateFields := true;
  CachedUpdates := false;
  FReopenAfterPost := false;
  FOnAfterLookupFieldsCopied := nil;

  FetchOptions.DetailDelay := 300;
  // esempio: master/detail su detail documenti,
  // insert sul master causa il download dell'intero datset
  FetchOptions.AutoFetchAll := afTruncate;

  // AutoUpdateOptions.WhenGetGenID := wgOnNewRecord;
  // AutoUpdateOptions.AutoParamsToFields := True;
  // AutoUpdateOptions.SeparateBlobUpdate := True;
  //
  // DetailConditions := [dcIgnoreMasterClose, dcWaitEndMasterScroll];
  // Options := Options + [poStartTransaction, poFreeHandlesAfterClose, poNoForceIsNull, poRefreshAfterPost];
  // PrepareOptions := PrepareOptions - [psUseBooleanField, pfImportDefaultValues] + [psSetEmptyStrToNull, psUseLargeIntField];
  //
  // RefreshTransactionKind := tkUpdateTransaction;
  //
  // DefaultFormats.DisplayFormatTime := 'hh:mm';
  // DefaultFormats.DateTimeDisplayFormat := 'dd.mm.yyyy hh:mm';
  // {
  // nel caso di master detail, con
  // M/D/Sub
  // per il subdetail non vengono chiamati
  // gli eventi del datasource (causa disablecontrols)
  // per cui bisogna farlo a mano
  // }
  //
end;

destructor TzFbDataSet.Destroy;
begin
  UpdateObject := nil;
  FreeAndNil(InnerUpdateObject);
  FreeAndNil(FAutoUpdateColumns); // Mantis #257 - 2026-10-29
  FreeAndNil(FAutoUpdateKeyFields);
  FreeAndNil(FAutoUpdateReturning);
  FreeAndNil(FDefaultSQL);
  FreeAndNil(FCountSQL);
  FreeAndNil(FDefaultValues);
  FreeAndNil(FNewRecordOptions);
  inherited;
  // viene chiamato anche da DestroyFields e altro
  FreeAndNil(FFieldOrigins);
  FreeAndNil(FDefaultExpressions); // Mantis #153 - 2026-09-21
end;

procedure TzFbDataSet.DestroyFields;
begin
  sizFbDataSet.EnterMethod(self, 'DestroyFields');
  InvalidateFieldOrigins;
  // Mantis #161 - 2026-09-30: la fotografia punta ai campi che stanno per
  // essere distrutti.
  FAttributiAutomatici := [];
  inherited;
  sizFbDataSet.LeaveMethod(self, 'DestroyFields');
end;

procedure TzFbDataSet.AddWhereCondition(const Condition: string);
var
  SQL: string;
begin
  SQL := zSql.SqlTxtRtns.AddToWhereClause(SelectSQL.Text, Condition, true);
  ChangeSQL(SQL);
end;

procedure TzFbDataSet.ApplyFilter(const Filter: string);
var
  SQL: string;
begin

  if Filter <> '' then
    SQL := zSql.SqlTxtRtns.AddToWhereClause(DefaultSQL.Text, Filter, true)
  else
    SQL := DefaultSQL.Text;

  ChangeSQL(SQL);
end;

procedure TzFbDataSet.DoCreateFields;

  function TrimAll(const s: string): string;
  const
    ValidChar = ['A' .. 'Z', 'a' .. 'z', '_', '0' .. '9'];
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(s) do
      if s[i] in ValidChar then
        Result := Result + s[i];
  end;

var
  i: Integer;
begin
  sizFbDataSet.EnterMethod(self, 'DoCreateFields');
  InvalidateFieldOrigins;
  doBeforeCreateFields;

  needInitFields := FieldCount = 0;

  inherited;

  for i := 0 to FieldCount - 1 do
  begin
    Fields[i].Name := Name + TrimAll(Fields[i].FieldName);

    // Mantis #274 - 2026-10-22: FireDAC crea un TBytesField per le colonne
    // CHAR(n) CHARACTER SET OCTETS (dominio UUID), e il testo di un campo
    // binario in Data.DB e' la descrizione del tipo: schede e griglie
    // mostravano "(BYTES)". Si mostra il valore in esadecimale. Un gestore gia'
    // assegnato da un DataModule resta il suo
    if (Fields[i] is TBinaryField) and not Assigned(Fields[i].OnGetText) then
      Fields[i].OnGetText := CampoBinarioGetText;
  end;

  // era in InternalOpen
  // Mantis #153 - 2026-09-21: "solo una volta" vale per l'inizializzazione dal
  // dizionario, che e' costosa e non cambia. Non vale per le DefaultExpression:
  // i campi riusati arrivano qui con la proprieta' gia' azzerata, e prima
  // nessuno la rimetteva piu' per tutta la vita del dataset. Se la copia non e'
  // mai stata presa, l'inizializzazione non e' passata di qui (campi creati
  // prima che il dizionario fosse disponibile) e si fa per intero.
  //
  // Mantis #161 - 2026-09-29: diagnostica per il difetto delle didascalie di
  // colonna e delle DisplayFormat mancanti solo su alcune postazioni.
  // RestoreDefaultExpressions rimette sui campi riusati solo la
  // DefaultExpression: DisplayLabel, DisplayFormat e Alignment restano quelli
  // che i TField gia' avevano. Se questo ramo viene preso su un dataset i cui
  // campi non erano ancora stati inizializzati una prima volta (bug nell'ordine
  // di apertura, oggetto TzFbDataSet riusato da un pool, ecc.), le proprieta'
  // dal dizionario non arrivano mai sul campo: questa riga dice quale dei due
  // rami e' stato preso e perche'.
  sizFbDataSet.LogString(Name, Format('DoCreateFields: needInitFields=%s FDefaultsInizializzati=%s -> ramo %s', [BoolToStr(needInitFields, true), BoolToStr(FDefaultsInizializzati, true), IfThen(needInitFields or not FDefaultsInizializzati, 'UpdateFieldAttributes (completo)', 'RestoreDefaultExpressions (solo default)')]));

  if needInitFields or not FDefaultsInizializzati then
    UpdateFieldAttributes
  else
    RestoreDefaultExpressions;

  doAfterCreateFields;
  FotografaAttributiAutomatici;
  sizFbDataSet.LeaveMethod(self, 'DoCreateFields');
end;

// Mantis #274 - 2026-10-22: solo lettura. TBinaryField.SetText solleva
// AccessError come prima: il campo resta non modificabile da tastiera
procedure TzFbDataSet.CampoBinarioGetText(Sender: TField; var Text: string; DisplayText: boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TestoEsadecimale(Sender.AsBytes);
end;

// Mantis #161 - 2026-09-30: un campo creato dentro l'apertura e' automatico
// (lcAutomatic), e su quelli TFDDataSet.InternalOpen, subito dopo
// DoCreateFields e BindFields, chiama SetFieldAttributes([lcAutomatic]), che
// riscrive senza condizioni Origin, DefaultExpression, ProviderFlags, ReadOnly
// e le maschere (DisplayFormat, e EditFormat sui numerici) con i valori della
// colonna e di FormatOptions: cioe' cancella quello che InitFields,
// UpdateFieldOrigins, UpdateDefaultExpressions, SetFieldsReadOnly e
// OnAfterCreateFields hanno appena messo. Succede ai dataset che non passano
// mai da BuildFields (creati da codice, lookup LK_FK_*) a ogni apertura, e a
// quelli che cambiano la SELECT prima di averne costruiti (DoBeforeOpen, vedi
// sopra). Qui si fotografano quegli attributi; RimettiAttributiAutomatici li
// rimette dopo la riscrittura. InitFields non si ripete e OnAfterCreateFields
// resta al suo posto. I campi persistenti non si toccano: FireDAC non li
// riscrive.
procedure TzFbDataSet.FotografaAttributiAutomatici;
var
  Campo: TField;
  Attributi: TAttributiCampo;
begin
  FAttributiAutomatici := [];
  if not (lcAutomatic in Fields.LifeCycles) then
    Exit;

  for Campo in Fields do
    if Campo.LifeCycle = lcAutomatic then
    begin
      Attributi := Default(TAttributiCampo);
      Attributi.Campo := Campo;
      Attributi.Origine := Campo.Origin;
      Attributi.ValorePredefinito := Campo.DefaultExpression;
      Attributi.SolaLettura := Campo.ReadOnly;
      if Campo is TNumericField then
      begin
        Attributi.Maschera := TNumericField(Campo).DisplayFormat;
        Attributi.MascheraModifica := TNumericField(Campo).EditFormat;
      end
      else if Campo is TDateTimeField then // comprende TDateField e TTimeField
        Attributi.Maschera := TDateTimeField(Campo).DisplayFormat
      else if Campo is TSQLTimeStampField then
        Attributi.Maschera := TSQLTimeStampField(Campo).DisplayFormat;
      FAttributiAutomatici := FAttributiAutomatici + [Attributi];
    end;
end;

// Rimette gli attributi fotografati. ReadOnly sempre: il valore fotografato
// nasce dagli stessi attributi della colonna che usa FireDAC, piu' quello che
// ha deciso zPack (join, identita', SELECTED). Le maschere e l'origine solo se
// zPack ne aveva messa una: dove erano vuote vale quella di FireDAC. La
// DefaultExpression se zPack ne aveva una, oppure vuota sui campi calcolati
// dal server, che UpdateDefaultExpressions svuota apposta (Mantis 0006163).
procedure TzFbDataSet.RimettiAttributiAutomatici;
var
  Attributi: TAttributiCampo;
  Campo: TField;
begin
  if Length(FAttributiAutomatici) = 0 then
    Exit;

  for Attributi in FAttributiAutomatici do
  begin
    Campo := Attributi.Campo;
    if Fields.IndexOf(Campo) < 0 then
      Continue;

    Campo.ReadOnly := Attributi.SolaLettura;
    if Attributi.Origine <> '' then
      Campo.Origin := Attributi.Origine;
    if Attributi.ValorePredefinito <> '' then
      Campo.DefaultExpression := Attributi.ValorePredefinito
    else if IsServerCalcField(Campo) then
      Campo.DefaultExpression := '';

    if Attributi.Maschera <> '' then
      if Campo is TNumericField then
        TNumericField(Campo).DisplayFormat := Attributi.Maschera
      else if Campo is TDateTimeField then
        TDateTimeField(Campo).DisplayFormat := Attributi.Maschera
      else if Campo is TSQLTimeStampField then
        TSQLTimeStampField(Campo).DisplayFormat := Attributi.Maschera;
    if (Attributi.MascheraModifica <> '') and (Campo is TNumericField) then
      TNumericField(Campo).EditFormat := Attributi.MascheraModifica;
  end;

  sizFbDataSet.LogString(Name, Format('RimettiAttributiAutomatici: %d campi automatici', [Length(FAttributiAutomatici)]));
  FAttributiAutomatici := [];
end;

procedure TzFbDataSet.InitBufferPointers;
begin
  RimettiAttributiAutomatici;
  inherited;
end;

// Mantis #150 - 2026-09-21: fix errore "Valore non valido per il campo
// STUDENTI_PROGETTI.ID_STUDENTE, valore '*** null ***'" inserendo l'iscrizione
// a un corso subito dopo aver creato l'anagrafica dello studente.
//
// I campi di collegamento del dettaglio (quelli che compaiono anche come
// parametro della sua SELECT: ID_STUDENTE per Studenti.Studenti_Corsi) vengono
// valorizzati una volta sola, alla creazione della riga, dentro DoOnNewRecord.
// Se in quel momento il record master e' ancora in inserimento, il suo
// identificativo non esiste: lo assegna il server alla scrittura, e il valore
// torna al client solo con la RETURNING della INSERT del master. La riga di
// dettaglio nasce quindi con il collegamento NULL e nessuno lo rilegge piu'.
// Il controllo RequiredFieldOk non lo intercetta: il dataset legge una vista,
// e su una vista Firebird non riporta il NOT NULL della colonna della tabella
// di origine, quindi Field.Required e' False. L'errore arriva da Firebird con
// un messaggio che nomina la tabella e non la causa.
//
// Qui, subito prima della scrittura, il master e' gia' stato salvato (PostAll
// scrive nell'ordine dei dataset del DataModule, il master precede i dettagli),
// quindi il valore e' disponibile e si puo' ricopiare. Si interviene solo sui
// campi ancora NULL: un valore gia' assegnato - da una DefaultExpression, dai
// DefaultValues o dall'operatore - non viene mai sovrascritto.
//
// Sostituisce, generalizzandolo a tutti i master/dettaglio, il gestore
// ProgettiBeforePost aggiunto al solo WizInserimentoStudenteDM per il ticket
// #136: le form generate dai metadati LZ (come Studenti/Destinatari Corsi) non
// hanno codice Delphi proprio dove ripetere quella correzione.
procedure TzFbDataSet.ReloadLinkFieldsFromMaster;
var
  Field: TField;
  Master: TzFbDataSet;
  Value: Variant;
begin

  if not Assigned(DataSource) then
    Exit;

  if not Assigned(DataSource.DataSet) then
    Exit;

  if not(DataSource.DataSet is TzFbDataSet) then
    Exit;

  Master := DataSource.DataSet as TzFbDataSet;

  for Field in Fields do
    if Field.IsNull then
      if Field.FieldKind = fkData then
        if IsDetailParamField(Field.FieldName) then
        begin
          Value := Null;

          // Stesso ordine di CopyParams: prima il parametro omonimo del master
          // (catena di dettagli), poi il suo campo. Il parametro del master puo'
          // essere rimasto indietro, quindi si tiene il primo valore non nullo.
          if Master.ParamExists(Field.FieldName) then
            Value := Master.ParamByName(Field.FieldName).Value;

          if VarIsNull(Value) or VarIsClear(Value) then
            if Master.FieldExists(Field.FieldName) then
              Value := Master.FieldByName(Field.FieldName).Value;

          if not(VarIsNull(Value) or VarIsClear(Value)) then
          begin
            SetFieldValue(Field, Value);
            sizFbDataSet.LogString(Name, 'Campo di collegamento riletto dal master alla scrittura: ' + Field.FieldName);
          end;
        end;
end;

procedure TzFbDataSet.CheckBeforePost;
var
  i: Integer;
  Msg: string;
  ErrorFields: string;
  ErrorCount: Integer;
  Field: TField;
begin
  // Mantis #150 - 2026-09-21: prima di qualunque controllo, rilettura dei campi
  // di collegamento dal master (vedi ReloadLinkFieldsFromMaster).
  if State = dsInsert then
    ReloadLinkFieldsFromMaster;

  // Mantis #106 - 2026-09-10: in inserimento un campo che ha una
  // DefaultExpression ma e' ancora NULL segnala che il default non e' stato
  // applicato (voce di dizionario mancante, origine del campo non determinata).
  // Sui campi nascosti nella card nessuno se ne accorge finche' Firebird non
  // rifiuta il record per violazione NOT NULL, con un messaggio che parla della
  // tabella di origine e non del difetto. Qui la causa resta scritta nel log.
  // Volutamente non si assegna il default: coprirebbe il difetto invece di
  // renderlo visibile, e cambierebbe il senso di un campo svuotato apposta.
  if State = dsInsert then
    for i := 0 to FieldCount - 1 do
    begin
      Field := Fields[i];

      if not Field.DefaultExpression.IsEmpty then
        if Field.IsNull then
          sizFbDataSet.LogString(Name, 'Default previsto ma campo NULL: ' + Field.FieldName + ' = ' + Field.DefaultExpression);
    end;

  if not RequiredFieldsOk then
  begin
    Msg := '';
    ErrorFields := '';
    ErrorCount := 0;

    for i := 0 to FieldCount - 1 do

    begin
      Field := Fields[i];
      if not RequiredFieldOk(Field) then
      begin
        inc(ErrorCount);
        ErrorFields := ErrorFields + Field.DisplayLabel + ' ' + #13;
      end;
    end;

    if ErrorCount > 0 then
    begin
      Msg := Name + ': i campi seguenti devono avere un valore:' + #13 + #13 + ErrorFields;
      raise Exception.Create(Msg);
    end;
  end;
end;

procedure TzFbDataSet.CheckMasterRange;
begin
  sizFbDataSet.EnterMethod(self, 'CheckMasterRange');

  // proc chiamata in afterScroll invece della beforeOpen
  // Esempio: WT/Send/Send_Flussi_Uscita_Export_Destinatari_Pagamenti
  LoadParamsFromMaster;

  inherited;
  sizFbDataSet.LeaveMethod(self, 'CheckMasterRange');
end;

procedure TzFbDataSet.UpdateFieldAttributes;
begin
  DisableControls;
  try
    UpdateFieldOrigins;

    // Mantis #161 - 2026-09-29: se OnInitFields non e' ancora agganciato in
    // questo momento (es. dataset aperto prima che DataSetLoadProps abbia fatto
    // DataSet.OnInitFields := InitFields), TzSystem.InitFields non gira affatto
    // su questi campi: DisplayLabel, DisplayFormat e DefaultExpression restano
    // quelli di default di FireDAC, e nessuno se ne accorge finche' non lo si
    // vede in griglia. Registrato qui perche' e' l'unico punto in cui la
    // condizione e' visibile prima della chiamata.
    sizFbDataSet.LogString(Name, 'UpdateFieldAttributes: Assigned(OnInitFields)=' + BoolToStr(Assigned(FOnInitFields), true));

    if Assigned(FOnInitFields) then
      OnInitFields(self);

    needInitFields := false;
    UpdateDefaultExpressions;

    // Mantis #153 - 2026-09-21: la copia vale solo se il dizionario era gia'
    // agganciato: senza OnInitFields nessun campo ha ricevuto il suo default e
    // fotografare il nulla farebbe passare il dataset per "gia' inizializzato"
    // per sempre. In quel caso si riprova alla prossima costruzione dei campi.
    FDefaultsInizializzati := Assigned(FOnInitFields);
    SetFieldsReadOnly;
    SetRequiredForJoinFields;
    ValidateKeyFields;
  finally
    EnableControls;
  end;
end;

function TzFbDataSet.ColumnOccurrence(Column: TFDDatSColumn): Integer;
var
  i: Integer;
begin
  Result := 0;

  if not Assigned(Column) or not Assigned(Table) then
    Exit;

  for i := 0 to Column.Index - 1 do
    if SameText(Table.Columns[i].SourceName, Column.SourceName) then
      inc(Result);
end;

procedure TzFbDataSet.GetTableColumns(const TableName: string; Columns: TStrings);
begin
  if Assigned(Connection) and Connection.Connected then
    Connection.GetFieldNames('', '', TableName, '', Columns);
end;

function TzFbDataSet.OriginFromSelect(Column: TFDDatSColumn): string;
var
  Resolver: TSelectOriginResolver;
begin
  Result := '';

  if not Assigned(Column) then
    Exit;

  Resolver := TSelectOriginResolver.Create(SQL.Text, GetTableColumns);
  try
    Result := Resolver.OriginOf(Column.SourceName, ColumnOccurrence(Column));
  finally
    Resolver.Free;
  end;
end;

procedure TzFbDataSet.UpdateFieldOrigins;
var
  i: Integer;
  Column: TFDDatSColumn;
  Field: TField;
  Resolver: TSelectOriginResolver;
  Origin: string;
  DotPosition: Integer;
begin
  if not Assigned(Table) then
    Exit;

  // Aggiornamento di Column.OriginTabName e Column.OriginColName per le colonne
  // di cui il server non ha dichiarato la provenienza: si ricavano dal testo
  // della SELECT (zSql.SelectOrigins). La ricerca va fatta per SourceName, il
  // nome della colonna nel risultato, perche' quando manca la tabella FireDAC
  // lascia vuoto anche OriginColName. Il risolutore si costruisce una volta
  // sola e solo se serve.
  Resolver := nil;
  try
    for i := 0 to Table.Columns.Count - 1 do
      if Table.Columns[i].OriginTabName.IsEmpty then
      begin
        Column := Table.Columns[i];

        if not Assigned(Resolver) then
          Resolver := TSelectOriginResolver.Create(SQL.Text, GetTableColumns);

        Origin := Resolver.OriginOf(Column.SourceName, ColumnOccurrence(Column));
        DotPosition := Origin.LastIndexOf('.');

        if DotPosition > 0 then
        begin
          Column.OriginTabName := Origin.Substring(0, DotPosition);
          Column.OriginColName := Origin.Substring(DotPosition + 1);
        end;
      end;
  finally
    Resolver.Free;
  end;

  /// ////////////////////////////
  // Aggiornamento di Field.Origin
  /// ////////////////////////////

  InvalidateFieldOrigins;

  for Field in Fields do
    if Table.Columns.IndexOfName(Field.FieldName) <> -1 then
    begin
      Column := Table.Columns.ColumnByName(Field.FieldName);

      if Assigned(Column) then
        if not Column.OriginTabName.IsEmpty then
        begin
          // Field.Origin := Column.OriginTabName + '.' + Column.OriginColName;
          // Mantis 0005935
          Field.Origin := AnsiDequotedStr(Column.OriginTabName, '"') + '.' + AnsiDequotedStr(Column.OriginColName, '"');

          FFieldOrigins.AddOrSetValue(Field.FieldName, Field.Origin);
        end;
    end;
end;

procedure TzFbDataSet.ValidateKeyFields;
var
  FieldName: string;
  Validi: string;
  Scartato: boolean;
begin
  // Prima dell'apertura i campi possono non esistere ancora: non c'e' niente da confrontare
  if Fields.Count = 0 then
    Exit;

  // KeyFields: DIV-DAT-2, si tolgono solo i campi che non esistono, gli altri restano
  if not UpdateOptions.KeyFields.Trim.IsEmpty then
  begin
    Validi := '';
    Scartato := false;
    for FieldName in UpdateOptions.KeyFields.Split([';']) do
      if not FieldName.Trim.IsEmpty then
        if Assigned(FindField(FieldName.Trim)) then
          Validi := Validi + IfThen(Validi = '', '', ';') + FieldName.Trim
        else
        begin
          sizFbDataSet.LogError(Format('KeyFields non valido sul dataset "%s": il campo "%s" non esiste nel result set e viene tolto.', [Name, FieldName.Trim]));
          Scartato := true;
        end;
    if Scartato then
      UpdateOptions.KeyFields := Validi;
  end;

  // AutoIncFields
  if not UpdateOptions.AutoIncFields.Trim.IsEmpty then
  begin
    Validi := '';
    Scartato := false;
    for FieldName in UpdateOptions.AutoIncFields.Split([';']) do
      if not FieldName.Trim.IsEmpty then
        if Assigned(FindField(FieldName.Trim)) then
          Validi := Validi + IfThen(Validi = '', '', ';') + FieldName.Trim
        else
        begin
          siMain.LogMessage(Format('AutoIncFields non valido sul dataset "%s": il campo "%s" non esiste nel result set e viene tolto.', [Name, FieldName.Trim]));
          Scartato := true;
        end;
    if Scartato then
      UpdateOptions.AutoIncFields := Validi;
  end;
end;

procedure TzFbDataSet.CheckRecordLimitReached;
begin
  // aggiungere un evento
  // chiamarla da AfterGetRecords e AfterScroll
  // Settare un flag (resettato in AfterOpen) per evitare di chiamare più volte l'evento

  // FlagRecordLimitReached := false;

  if not FlagRecordLimitReached then
    if EOF then
      if recordCount = FetchOptions.RecsMax then
      // Rallenta su query complesse if recordCount < RecordCountFromServer then
      begin
        FlagRecordLimitReached := true;

        if Assigned(FOnRecordLimitReached) then
          OnRecordLimitReached(self);
      end;
end;

procedure TzFbDataSet.ClearParamValues;
var
  i: Integer;
begin
  for i := 0 to ParamCount - 1 do
    if Params[i].ParamType in [ptInput, ptInputOutput] then
      Params[i].clear(0);
end;

procedure TzFbDataSet.CloseCursor;
begin
  // sizFbDataSet.EnterMethod(self, 'CloseCursor');
  inherited;
  // sizFbDataSet.LeaveMethod(self, 'CloseCursor');
end;

// procedure TzFbDataSet.aaaCopyLookupFields(lkDataSet: TDataset; LookupString: string; ClearFields: boolean; Field2Exclude: string = '');
// var
// SourceField, DestField: string;
// link: string;
// i: Integer;
// Str, Str2: TStringList;
// s: string;
//
// /// /////////////////////////
//
// procedure CopyField(SourceFieldName, DestFieldName: string);
// var
// Esci: boolean;
// SrcField, DestField: TField;
// WasReadOnly: boolean;
// begin
// DestField := FindField(DestFieldName);
//
// Esci := not Assigned(DestField);
//
// if not Esci then
// begin
// SrcField := lkDataSet.FindField(SourceFieldName);
// Esci := not Assigned(SrcField);
// end;
//
// if Esci then
// begin
// sizFbDataSet.LogString(Name, 'Lookup: non ho trovato i campi ' + SourceFieldName + ' e ' + DestFieldName);
// Exit;
// end;
//
// // CheckEditMode; // se un precedente clear avesse provocato un cancel/post
//
// // WasReadOnly := DestField.ReadOnly;
// // DestField.ReadOnly := false;
//
// if ClearFields then
// ClearFieldValue(DestField)
// else
// begin
// try
// if DestField.Value <> SrcField.Value then
// // DestField.Value := SrcField.Value;
// SetFieldValue(DestField, SrcField.Value);
// except
// on e: Exception do
// begin
// sizFbDataSet.LogValue(DestField.FieldName, DestField.asString);
// sizFbDataSet.LogValue(SrcField.FieldName, SrcField.asString);
// raise;
// end;
// end;
// end;
//
// // DestField.ReadOnly := WasReadOnly;
// end;
//
/// // ////////////////////////
// begin
// if not Assigned(lkDataSet) then
// Exit;
//
// if lkDataSet.IsEmpty then
// Exit;
//
// // CheckEditMode;
// Str := TStringList.Create;
// try
// Str2 := TStringList.Create;
// try
// Str2.Delimiter := '@';
// Str.Delimiter := ';';
// Str.DelimitedText := LookupString;
// for i := 0 to Str.Count - 1 do
// if Str[i] <> '' then
// begin
// s := Trim(Str[i]);
// Str2.DelimitedText := s;
//
// if Str2.Count = 1 then
// begin
// DestField := s;
// SourceField := s;
// end
// else
// if Str2.Count = 2 then
// begin
// SourceField := Str2[0];
// DestField := Str2[1];
// end;
//
// if DestField <> Field2Exclude then
// CopyField(SourceField, DestField);
// end;
// finally
// FreeAndNil(Str2);
// end;
// finally
// FreeAndNil(Str);
// end;
//
// if Assigned(FOnAfterLookupFieldsCopied) then
// OnAfterLookupFieldsCopied(self, lkDataSet, LookupString);
// end;

procedure TzFbDataSet.CopyMappingFields(lkDataSet: TDataset; Mappings: TStringList; ClearFields: boolean; Field2Exclude: string = '');
var
  SourceField, DestField: string;
  i: Integer;
  StringList, Str2: TStringList;

  /// /////////////////////////

  procedure CopyField(SourceFieldName, DestFieldName: string);
  var
    Esci: boolean;
    SrcField, DestField: TField;
    WasReadOnly: boolean;
  begin
    DestField := FindField(DestFieldName);

    Esci := not Assigned(DestField);

    if not Esci then
    begin
      SrcField := lkDataSet.FindField(SourceFieldName);
      Esci := not Assigned(SrcField);
    end;

    if Esci then
    begin
      sizFbDataSet.LogString(Name, 'Lookup: non ho trovato i campi ' + SourceFieldName + ' e ' + DestFieldName);
      Exit;
    end;

    // CheckEditMode; // se un precedente clear avesse provocato un cancel/post

    // WasReadOnly := DestField.ReadOnly;
    // DestField.ReadOnly := false;

    if ClearFields then
      ClearFieldValue(DestField)
    else
    begin
      try
        if DestField.Value <> SrcField.Value then
          // DestField.Value := SrcField.Value;
          SetFieldValue(DestField, SrcField.Value);
      except
        on e: Exception do
        begin
          sizFbDataSet.LogValue(DestField.FieldName, DestField.asString);
          sizFbDataSet.LogValue(SrcField.FieldName, SrcField.asString);
          raise;
        end;
      end;
    end;

    // DestField.ReadOnly := WasReadOnly;
  end;

/// ////////////////////////
begin
  if not Assigned(Mappings) then
    Exit;

  if not Assigned(lkDataSet) then
    Exit;

  if lkDataSet.IsEmpty then
    Exit;

  // CheckEditMode;
  for i := 0 to Mappings.Count - 1 do
  begin
    DestField := Mappings.Names[i];
    SourceField := Mappings.ValueFromIndex[i];

    if DestField <> Field2Exclude then
      CopyField(SourceField, DestField);
  end;

  if Assigned(FOnAfterLookupFieldsCopied) then
    OnAfterLookupFieldsCopied(self, lkDataSet, Mappings.Text);
end;

function TzFbDataSet.DebugInsertString: string;
var
  Field: TField;
  i: Integer;
  s: string;
  Str: TStringList;
  FieldNames: TStringList;
begin
  Result := '';

  FieldNames := TStringList.Create;
  try
    Connection.GetFieldNames('', '', TableName, '', FieldNames);

    if FieldNames.Count = 0 then
      Exit;

    Str := TStringList.Create;
    try
      Str.clear;
      Str.Add('INSERT INTO ' + TableName + ' (');
      for i := 0 to FieldNames.Count - 1 do
      begin
        s := '  ' + FieldNames.Strings[i];
        if i <> FieldNames.Count - 1 then
          s := s + ','
        else
          s := s + ')';
        Str.Add(s);
      end;

      Str.Add('VALUES (');
      for i := 0 to FieldNames.Count - 1 do
      begin

        Field := FindField(FieldNames.Strings[i]);

        if not Assigned(Field) then
          s := 'NULL'
        else
          if Field.IsNull then
            s := 'NULL'
          else
            case Field.DataType of
              ftString, ftFixedChar, ftWideString:
                begin
                  s := AnsiQuotedStr(Field.asString, #39);
                end;
              ftSmallint, ftInteger, ftWord, ftLargeint:
                s := Field.asString;
              ftBoolean:
                s := BoolToStr(Field.asBoolean, true);
              ftFloat, ftCurrency, ftBCD:
                s := Field.asString;
              ftDate, ftTime, ftDateTime:
                s := AnsiQuotedStr(StringReplace(Field.asString, FormatSettings.DateSeparator, '.', [rfReplaceAll]), #39);

              ftBlob, ftMemo, ftWideMemo, ftGraphic, ftFmtMemo:
                s := '(BLOB)';
            else
              s := '(unknown)';
            end;

        if i <> FieldNames.Count - 1 then
          s := s + ','
        else
          s := s + ')';
        Str.Add(s);
      end;
      Result := Str.Text;
    finally
      FreeAndNil(Str);
    end;
  finally
    FreeAndNil(FieldNames);
  end;
end;

function TzFbDataSet.DebugUpdateString: string;
var
  Field: TField;
  Str: TStringList;
begin
  Result := '';

  Str := TStringList.Create;
  try
    Str.Add('UPDATE ' + TableName);
    Str.Add('SET');

    for Field in Fields do
    begin
      if Field.IsNull then
        Str.Add('  ' + Field.Name + '= (Null)')
      else
        if IsNumericType(Field.DataType) then
          Str.Add('  ' + Field.Name + '=' + Field.asString.Replace(',', '.'))
        else
          if IsDateTimeType(Field.DataType) then
            Str.Add('  ' + Field.Name + '=' + AnsiQuotedStr(Field.asString, #39).Replace('/', '.'))
          else
            Str.Add('  ' + Field.Name + '=' + AnsiQuotedStr(Field.asString, #39));
    end;
    Result := Str.Text;
  finally
    FreeAndNil(Str);
  end;
end;

procedure TzFbDataSet.doAfterCreateFields;
begin
  if Assigned(FOnAfterCreateFields) then
    OnAfterCreateFields(self);
end;

procedure TzFbDataSet.DoAfterGetRecords(AFromRecord, AToRecord: Integer);
var
  DurataMs: Int64;
  Righe: Integer;
  NomeMisura: string;
  Dettaglio: string;
begin
  inherited;
  CheckRecordLimitReached;

  // Mantis #183 - 2026-10-08: durata e righe di ogni rowset letto dal server.
  // Il primo fetch e' quello in cui Firebird esegue la query e la ordina, i
  // successivi sono solo trasferimento: per questo hanno due nomi, cosi' il
  // riepilogo li somma separati. AFromRecord e AToRecord sono gli indici (da
  // zero) del primo e dell'ultimo record arrivati con questo fetch; AToRecord
  // + 1 e' quindi quanto e' stato letto finora in questa apertura. Il
  // cronometro parte in DoBeforeGetRecords: se la registrazione e' stata
  // accesa fra i due, non c'e' misura e non si scrive niente.
  if zDiagnostica.Log.Perf.RegistrazioneFetchAttiva and FCronometroFetch.IsRunning then
  begin
    FCronometroFetch.Stop;
    DurataMs := FCronometroFetch.ElapsedMilliseconds;
    Inc(FNumeroFetch);
    Righe := AToRecord - AFromRecord + 1;
    if Righe < 0 then
      Righe := 0;
    if FNumeroFetch = 1 then
      NomeMisura := Name + ' fetch 1'
    else
      NomeMisura := Name + ' fetch 2+';
    Dettaglio := Format('fetch %d: record %d-%d, %d righe, lette finora %d, %d ms',
      [FNumeroFetch, AFromRecord, AToRecord, Righe, AToRecord + 1, DurataMs]);
    sizFbDataSet.LogMessage(Name + ' - ' + Dettaglio);
    zDiagnostica.Log.Perf.SegnalaOperazione(coDataSet, NomeMisura, DurataMs, Dettaglio, Righe);
  end;
end;

procedure TzFbDataSet.DoAfterOpen;
begin
  sizFbDataSet.EnterMethod(self, 'DoAfterOpen');

  inherited;

  // Mantis #49 - 2026-07-28: apertura conclusa senza errori, la traccia
  // del dataset in apertura non serve piu'. Si azzera solo se e' ancora la
  // nostra: le aperture si annidano.
  if CurrentOpeningDataSet = self then
    CurrentOpeningDataSet := nil;

  StopWatch.Stop;
  sizFbDataSet.LogVerbose('OpenTime: ' + GetOpenTime.ToString);

  // Misura per la sessione di registrazione attivabile dall'utente. A
  // registrazione spenta il costo e' la lettura di un booleano: GetDebugInfo,
  // che ricostruisce SQL e parametri, viene chiamato solo se serve davvero.
  if zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva then
    zDiagnostica.Log.Perf.SegnalaOperazione(coDataSet, Name, Round(GetOpenTime.TotalMilliseconds), GetDebugInfo);

  // Mantis #183 - 2026-10-08: quanti fetch ha richiesto l'apertura (prima di
  // DoAfterOpen li chiedono i buffer del dataset e il caricamento della griglia).
  if zDiagnostica.Log.Perf.RegistrazioneFetchAttiva then
    sizFbDataSet.LogString(Name + ' fetch all''apertura', FNumeroFetch.ToString);

  // Dopo l'apertura la preparazione e' quella definitiva: la firma dei
  // parametri va allineata, altrimenti l'apertura successiva spreparerebbe
  // a vuoto.
  if Prepared then
    FFirmaParametriPreparati := FirmaParametri;

  FlagRecordLimitReached := false;

  sizFbDataSet.LogStringList(Name + '.DoAfterOpen', SelectSQL);
  // Time_Open := GetTickCount - Time_Open;
  // zMonitor.LogDataSet(Self, loOpen);

  // if false then // ZZ 18.11.2018: se vengono impostati dal load props vengono sovrascritti
  // if not(csDesigning in ComponentState) then
  // begin
  // DisableControls;
  // try
  // SetFieldsReadOnly;
  // SetRequiredForJoinFields;
  // finally
  // EnableControls;
  // end;
  // end;

  sizFbDataSet.LeaveMethod(self, 'DoAfterOpen');
end;

procedure TzFbDataSet.DoAfterPost;
begin
  inherited;

  ConfermaAutoCommit;
end;

procedure TzFbDataSet.DoAfterDelete;
begin
  inherited;

  // DIV-SAL-2: anche la cancellazione si conferma con AutoCommit
  ConfermaAutoCommit;
end;

procedure TzFbDataSet.ConfermaAutoCommit;
begin
  // 20.09.2022: caso inserimento risorsa [non salva nonostante l'autocommit
  if AutoCommit then
    if Assigned(UpdateTransaction) then
      if UpdateTransaction.Active then
      begin
        // DIV-SAL-3: dentro un'operazione atomica non si conferma
        if UpdateTransaction is TzFbTransaction then
          if TzFbTransaction(UpdateTransaction).OperazioneAtomicaAperta then
            Exit;

        UpdateTransaction.Commit;
      end;
end;

procedure TzFbDataSet.DoAfterScroll;
begin
  sizFbDataSet.EnterMethod(self, 'DoAfterScroll');

  inherited;
  CheckRecordLimitReached;

  sizFbDataSet.LeaveMethod(self, 'DoAfterScroll');
end;

procedure TzFbDataSet.DoBeforeClose;
begin
  sizFbDataSet.EnterMethod(self, 'DoBeforeClose');

  if Modified then
    checkBrowseMode;

  inherited;
  sizFbDataSet.LeaveMethod(self, 'DoBeforeClose');
end;

procedure TzFbDataSet.doBeforeCreateFields;
begin
  if Assigned(FOnBeforeCreateFields) then
    OnBeforeCreateFields(self);
end;

procedure TzFbDataSet.DoBeforeDelete;
begin
  sizFbDataSet.LogStringList('BeforeDelete', InnerUpdateObject.DeleteSQL);
  inherited;
end;

procedure TzFbDataSet.DoBeforeGetRecords;
begin
  // Mantis #183 - 2026-10-08: parte il cronometro del rowset. A registrazione
  // spenta, o senza la casella "tempi dei dataset", il costo e' un booleano;
  // un cronometro rimasto in corsa da un fetch fallito si ferma, cosi' non
  // viene attribuito al fetch successivo.
  if zDiagnostica.Log.Perf.RegistrazioneFetchAttiva then
    FCronometroFetch := TStopWatch.StartNew
  else if FCronometroFetch.IsRunning then
    FCronometroFetch.Stop;
  inherited;
end;

procedure TzFbDataSet.DoBeforeInsert;
begin
  // ZZ 18.05.2016
  // M/D: verifica che il master non sia ancora in stato di Insert

  if Assigned(DataSource) then
    if Assigned(DataSource.DataSet) then
      if DataSource.DataSet.State in dsEditModes then
      // ZZ 06.12.2022: anche per il dsEdit; i combo di dettaglio
      // potrebbero non essere sincronizzati
      // if DataSource.DataSet.State = dsInsert then
      begin
        DisableControlsExt; // Altrimenti manda in post anche il detail
        try
          DataSource.DataSet.checkBrowseMode;
        finally
          EnableControlsExt;
        end;
      end;

  inherited;
end;

procedure TzFbDataSet.DoBeforeOpen;
var
  i: Integer;
begin
  sizFbDataSet.EnterMethod(self, 'DoBeforeOpen');

  // Mantis #49 - 2026-07-28: traccia il dataset in apertura, cosi' che un
  // errore durante la lettura delle righe possa essere attribuito a questa
  // query. Vedi il commento di CurrentOpeningDataSet in coda alla sezione interface.
  CurrentOpeningDataSet := self;

  sizFbDataSet.LogString('Opening DataSet', Name);
  sizFbDataSet.LogString('With Sql', GetDebugInfo);

  siRed.LogVerbose(Name);

  ValidateKeyFields;

  // if not(csDesigning in ComponentState) then
  // if AutoCreateFields then
  // BuildFields;

  inherited;

  LoadParamsFromMaster;

  if Assigned(FOnGetQueryParams) then
    OnGetQueryParams(self);

  // Mantis #161 - 2026-09-30: dopo un cambio della SELECT (ordinamento
  // dall'intestazione di colonna, filtri, Where) i campi vanno ricostruiti
  // qui, prima che l'apertura cominci, e non dentro InternalOpen. Un campo
  // creato dentro l'apertura nasce automatico (lcAutomatic), e su quelli
  // FireDAC, subito dopo DoCreateFields, riscrive DisplayFormat, EditFormat,
  // ReadOnly, DefaultExpression e Origin (TFDDataSet.InternalOpen ->
  // SetFieldAttributes([lcAutomatic])): le maschere messe da InitFields
  // sparivano dalla griglia (123456 al posto di 123.456) e non tornavano piu',
  // perche' i campi automatici vengono distrutti a ogni chiusura e rinascono
  // automatici. Costruiti qui restano persistenti, come quelli di
  // DataSetLoadProps, e FireDAC li lascia come sono.
  // Solo se il dataset ha gia' dei campi costruiti: chi non e' mai passato da
  // BuildFields continua a crearli dentro l'apertura, come prima. Il punto e'
  // dopo l'assegnazione dei parametri, cosi' la preparazione conservata da
  // BuildFields nasce gia' con la firma definitiva.
  if needRebuildFields and (FieldCount > 0) then
  begin
    sizFbDataSet.LogString(Name, 'DoBeforeOpen: SELECT cambiata, campi ricostruiti prima dell''apertura');
    BuildFields(true);
  end;

  // I parametri sono tutti assegnati: master, filtri, OnGetQueryParams. Se
  // la firma e' diversa da quella della preparazione conservata da
  // BuildFields, FireDAC rifiuterebbe l'esecuzione ("Query must be
  // reprepared"): si sprepara adesso, e l'apertura ripete la preparazione
  // come faceva prima. Nel caso normale la firma coincide e il giro di rete
  // si risparmia.
  if Prepared and (FFirmaParametriPreparati <> '') then
    if FirmaParametri <> FFirmaParametriPreparati then
    begin
      sizFbDataSet.LogVerbose('Parametri cambiati dopo la preparazione: UnPrepare di ' + Name);
      UnPrepare;
      FFirmaParametriPreparati := '';
    end;

  try
    for i := 0 to ParamCount - 1 do
    begin
      if Params[i].IsNull then
        sizFbDataSet.LogString(Params[i].Name, '<null>')
      else
        sizFbDataSet.LogString(Params[i].Name, Params[i].asString);
    end;
  except
  end;

  StopWatch.Reset;
  StopWatch.Start;
  FNumeroFetch := 0; // Mantis #183 - 2026-10-08: i fetch si contano per apertura

  sizFbDataSet.LeaveMethod(self, 'DoBeforeOpen');
end;

// Sanificazione automatica dei campi di testo al salvataggio, livello SICURO di
// TzSanificazione (controlli, caratteri di formato invisibili, spazi Unicode, simboli
// di font, ricomposizione NFC). Non tocca punteggiatura tipografica ne' spazi ai bordi:
// qui arriva anche testo assegnato da codice (modelli, script, JSON di configurazione).
// - solo campi stringa e memo, scrivibili, non calcolati e non di lookup
// - solo i campi cambiati in questa modifica: il dato storico non cambia di nascosto
// - mai su RTF, HTML, XML, JSON (TzSanificazione.SembraMarcatura)
// Nessun errore sollevato: la validazione di formato resta ai trigger e agli editor.
procedure TzFbDataSet.SanificaCampiTesto;
var
  Field: TField;
  Testo: string;
  Ripulito: string;
  Multiriga: boolean;
begin
  if not FSanification then
    Exit;
  if not(State in [dsInsert, dsEdit]) then
    Exit;

  for Field in Fields do
  begin
    if not(Field.DataType in [ftString, ftWideString, ftMemo, ftWideMemo]) then
      Continue;
    if Field.ReadOnly or (Field.FieldKind <> fkData) then
      Continue;
    if Field.IsNull then
      Continue;

    // in inserimento ogni campo valorizzato e' "toccato"; in modifica solo quelli cambiati
    if (State = dsEdit) and VarSameValue(Field.OldValue, Field.Value) then
      Continue;

    Testo := Field.asString;
    if Testo = '' then
      Continue;
    if TzSanificazione.SembraMarcatura(Testo) then
      Continue;

    Multiriga := Field.DataType in [ftMemo, ftWideMemo];
    Ripulito := TzSanificazione.Sanifica(Testo, Multiriga, TzSanificazione.OpzioniSicure);

    if Ripulito <> Testo then
    begin
      sizFbDataSet.LogString('SanificaCampiTesto ' + Field.FieldName, TzSanificazione.DescriviAnomalie(Testo, Multiriga));
      Field.asString := Ripulito;
    end;
  end;
end;

procedure TzFbDataSet.DoBeforePost;
begin
  inherited;
  SanificaCampiTesto;
  DoCustomBeforePost;
  // Mantis #257 - 2026-10-29: il registro dell'istruzione e dei valori e'
  // passato in RegistraPost, chiamata da InternalPost dopo ComponiUpdateSQL:
  // qui avrebbe registrato l'UPDATE del salvataggio precedente.
end;

// Mantis #257 - 2026-10-29: registro SmartInspect del salvataggio, prima in
// DoBeforePost. Chiamata da InternalPost dopo ComponiUpdateSQL, cosi' registra
// l'UPDATE che parte davvero.
procedure TzFbDataSet.RegistraPost;
var
  Field: TField;
begin
  sizFbDataSet.LogVerbose('BeforePost');
  sizFbDataSet.LogString('DataSet', Name);

  if State = dsInsert then
    sizFbDataSet.LogStringList('BeforePost - Insert', InnerUpdateObject.InsertSQL)
  else
    sizFbDataSet.LogStringList('BeforePost - Update', InnerUpdateObject.ModifySQL);

  for Field in Fields do
  begin

    if Field.IsNull then
      sizFbDataSet.LogString(Field.FieldName, '<null>')
    else
      sizFbDataSet.LogString(Field.FieldName, Field.asString);
  end;
end;

procedure TzFbDataSet.DoBeforeScroll;
begin
  // sizFbDataSet.EnterMethod(self, 'DoBeforeScroll');
  inherited;
  // sizFbDataSet.LeaveMethod(self, 'DoBeforeScroll');
end;

procedure TzFbDataSet.DoCustomBeforePost;
begin
  if Assigned(FOnCustomBeforePost) then
    OnCustomBeforePost(self);
end;

procedure TzFbDataSet.ApplyDefaultExpression(Field: TField);
var
  DefaultExpression: string;
  FormatoData: TFormatSettings;
  TestoData: string;
  ValoreData: TDateTime;
  WasReadOnly: boolean;
begin
  assert(Assigned(Field));

  if Field.DefaultExpression.IsEmpty then
    Exit;

  if not(State in dsEditModes) then // 03.11.2022: tasto cancel durante l'inserimento
    Exit;

  WasReadOnly := Field.ReadOnly;
  Field.ReadOnly := false;

  DefaultExpression := Field.DefaultExpression;

  if SameText(DefaultExpression, 'NULL') then
    Field.clear
  else
    if (Field is TDateTimeField) or (Field is TSQLTimeStampField) then
    begin

      case IndexText(AnsiDequotedStr(DefaultExpression, #39), ['NOW', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'TODAY', 'CURRENT_DATE', 'TOMORROW', 'YESTERDAY']) of
        0, 1, 2:
          Field.AsDateTime := Now;
        // 'NOW', 'CURRENT_TIME', 'CURRENT_TIMESTAMP'
        3, 4:
          Field.AsDateTime := Date; // 'TODAY', 'CURRENT_DATE'
        5:
          Field.AsDateTime := IncDay(Date, 1); // 'TOMORROW'
        6:
          Field.AsDateTime := IncDay(Date, -1); // 'YESTERDAY'
      else
        begin
          // DIV-SAL-5: il default 31/12/9999 e' giorno/mese/anno qualunque sia il formato data della postazione
          TestoData := AnsiDequotedStr(DefaultExpression, #39).Replace('.', '/');
          FormatoData := TFormatSettings.Create;
          FormatoData.DateSeparator := '/';
          FormatoData.ShortDateFormat := 'dd/mm/yyyy';
          FormatoData.TimeSeparator := ':';
          FormatoData.LongTimeFormat := 'hh:nn:ss';
          if TryStrToDateTime(TestoData, ValoreData, FormatoData) then
            Field.AsDateTime := ValoreData
          else
            Field.asString := TestoData;
        end;
      end;
    end
    else
      if Field is TBooleanField then
      begin
        if SameText(DefaultExpression.ToUpper, 'TRUE') then
          Field.Value := true
        else
          if SameText(DefaultExpression.ToUpper, 'FALSE') then
            Field.Value := false
          else
            Field.asString := DefaultExpression;
      end
      else
        if Field is TNumericField then
        begin
          // Mantis #106 - 2026-09-10: il separatore decimale e' quello della
          // postazione, non la virgola italiana: su impostazioni internazionali
          // diverse '1.0' diventava '1,0', StrToFloat sollevava EConvertError e
          // l'inserimento si interrompeva.
          Field.asString := DefaultExpression.Replace('.', FormatSettings.DecimalSeparator);
        end
        else
          // Mantis #7054 - 2026-11-02: anche i memo ricevono ora il default
          // fra apici, che qui vanno tolti come per le stringhe. Si guarda il
          // DataType e non la classe: TWideMemoField discende da TBlobField,
          // non da TMemoField
          if (Field is TStringField) or (Field.DataType in [ftMemo, ftWideMemo, ftFmtMemo]) then
            Field.asString := AnsiDequotedStr(DefaultExpression, #39)
          else
            Field.asString := DefaultExpression;

  Field.ReadOnly := WasReadOnly;
end;

procedure TzFbDataSet.DoOnNewRecord;

  procedure ApplyDefaultExpressions;
  var
    Field: TField;
  begin
    // Mantis #153 - 2026-09-21: prima di applicarli, rimette i default che i
    // TField possono aver perso dopo la prima apertura. E' il punto decisivo:
    // qui si e' certi che valgano al momento dell'inserimento, qualunque sia
    // stata la strada che li ha azzerati.
    RestoreDefaultExpressions;

    if State in dsEditModes then // 03.11.2022: tasto cancel durante l'inserimento
      for Field in Fields do
        ApplyDefaultExpression(Field);
  end;

  procedure ApplyDefaultValues;
  var
    ExternalField: TField;
    Field: TField;
    FieldName: string;
    i: Integer;
  begin
    /// //////////////////////////////////////
    // Valori presi da campi di altri dataset
    // es.: Campo=[TableName.FieldName]
    for i := 0 to DefaultValues.Count - 1 do
      if IsExternalField(DefaultValues.ValueFromIndex[i]) then
      begin
        FieldName := DefaultValues.Names[i];
        Field := FindField(FieldName);

        if Assigned(Field) then
          if State in dsEditModes then // 03.11.2022: tasto cancel dutante l'inserimento
          begin
            ExternalField := GetExternalField(DefaultValues.ValueFromIndex[i]);
            if Assigned(ExternalField) then
              SetFieldValue(Field, ExternalField.Value);
          end;
      end;
  end;

  procedure CopyParamsToFields;
  var
    i: Integer;
    Field: TField;
    Param: TFDParam;
    ExcludedFields: TStringList;
  begin
    /// //////////////////////////////////////
    ///
    // copia i valori presenti nei parametri come valori nei campi. Ad esempio per il Master/Detail
    ///
    /// //////////////////////////////////////

    if not NewRecordOptions.ParamsToFields then
      Exit;

    ExcludedFields := TStringList.Create;
    try
      ExcludedFields.Delimiter := ';';
      ExcludedFields.DelimitedText := NewRecordOptions.ParamsToFieldsExcluded;

      for i := 0 to Params.Count - 1 do
      begin
        Param := Params[i];
        Field := FindField(Param.Name.Replace('##', ''));

        if Assigned(Field) then
          if State in dsEditModes then // 03.11.2022: tasto cancel dutante l'inserimento
            if ExcludedFields.IndexOf(Field.FieldName) = -1 then
              if not(Param.IsNull and not Field.IsNull) then // Esempio: Progetti.Tipo_Progetto
                SetFieldValue(Field, Param.Value)
      end;
    finally
      FreeAndNil(ExcludedFields);
    end;
  end;

  procedure CopyMasterFields;
  var
    Master: TDataset;
    MasterField: TField;
    Field: TField;
    ExcludedFields: TStringList;
  begin
    // assegna i valori del master

    if not NewRecordOptions.MasterToFields then
      Exit;

    ExcludedFields := TStringList.Create;
    try
      ExcludedFields.Delimiter := ';';
      ExcludedFields.DelimitedText := NewRecordOptions.MasterToFieldsExcluded;

      if Assigned(DataSource) then
        if Assigned(DataSource.DataSet) then
        begin
          Master := DataSource.DataSet;

          for Field in Fields do
            if ExcludedFields.IndexOf(Field.FieldName) = -1 then
              if Field.IsNull then // Nota 1
                // DIV-SAL-1: il campo chiamato Note non si copia mai dal master, per scelta fissa
                // e indipendente da MasterToFieldsExcluded
                if not SameText(Field.FieldName, 'Note') then
                  if State in dsEditModes then // 03.11.2022: tasto cancel dutante l'inserimento
                  begin
                    MasterField := Master.FindField(Field.FieldName);

                    if Assigned(MasterField) then
                      SetFieldValue(Field, MasterField.Value);
                  end;
        end;
    finally
      FreeAndNil(ExcludedFields);
    end;
    // Nota 1:
    // Se è stato assegnato un valore tramite i Default/DefaultExpression
    // deve essere rispettato e non sovrascritto.
    // esempio: caso WizardIntestatari, campo ESCLUDI_CALCOLO_KL di variazioni
  end;

begin
  sizFbDataSet.EnterMethod(self, 'DoOnNewRecord');

  DisableControls;
  try
    ApplyDefaultExpressions;
    ApplyDefaultValues;
    CopyParamsToFields;
    CopyMasterFields;
  finally
    EnableControls;
  end;
  inherited;
  sizFbDataSet.LeaveMethod(self, 'DoOnNewRecord');
end;

procedure TzFbDataSet.DoProcessUpdateRequest(ARequest: TFDUpdateRequest; AOptions: TFDUpdateRowOptions);
begin
  InnerUpdateObject.Connection := Connection;
  inherited;
end;

function TzFbDataSet.DoFetch(ARow: TFDDatSRow; AColumn: Integer; ARowOptions: TFDPhysFillRowOptions): boolean;
begin
  InnerUpdateObject.Connection := Connection;
  Result := inherited;
end;

function TzFbDataSet.DoMasterParamChanged(AMasterFieldList: TFDFieldList): boolean;
begin
  // DIV-DAT-4: il confronto parametro per parametro con il master (che stava
  // dopo un Exit e non e' mai stato eseguito) e' stato tolto. Il cambio dei
  // parametri lo rileva FireDAC (inherited) o LoadParamsFromMaster.
  Result := inherited;

  if not Result then
    Result := ParamsChangedByLoadParamsFromMaster;

  ParamsChangedByLoadParamsFromMaster := false;
end;

function TzFbDataSet.FieldOrigin(Field: TField): string;
var
  Column: TFDDatSColumn;
  Alias: string;
  TableName: string;
  FieldName: string;
  tmp: string;
begin
  Result := '';

  if not Assigned(Field) then
    Exit;

  if Assigned(FFieldOrigins) then
    if FFieldOrigins.TryGetValue(Field.FieldName, Result) then
      Exit;

  if Assigned(Field) then
    if Assigned(Table) then
      if Table.Columns.IndexOfName(Field.FieldName) <> -1 then
      begin
        Column := Table.Columns.ColumnByName(Field.FieldName);

        if Assigned(Column) then
        begin
          // Mantis 0005935
          // FieldName := Column.OriginColName;
          // TableName := Column.OriginTabName;
          FieldName := AnsiDequotedStr(Column.OriginColName, '"');
          TableName := AnsiDequotedStr(Column.OriginTabName, '"');

          // ripiego sul testo della SELECT: se il server non ha dichiarato la
          // tabella, FireDAC ha lasciato vuoto anche il nome della colonna, e
          // vanno ricavati entrambi
          if TableName.IsEmpty then
          begin
            tmp := OriginFromSelect(Column);

            if tmp.Contains('.') then
            begin
              TableName := tmp.Substring(0, tmp.LastIndexOf('.'));
              FieldName := tmp.Substring(tmp.LastIndexOf('.') + 1);
            end;
          end;

          if TableName.IsEmpty then
          begin
            sizFbDataSet.LogSeparator;
            sizFbDataSet.LogError('Origin non determinato');
            sizFbDataSet.LogString('FieldName', Field.FieldName);

            sizFbDataSet.LogString('OriginColName', Column.OriginColName);

            sizFbDataSet.LogString('ActualOriginColName', Column.ActualOriginColName);
            sizFbDataSet.LogString('OriginTabName', Column.OriginTabName);
            sizFbDataSet.LogString('ActualOriginTabName', Column.ActualOriginTabName);

            sizFbDataSet.LogString('Table.SourceName', Table.SourceName);
            sizFbDataSet.LogString('Table.Name', Table.Name);

            sizFbDataSet.LogStringList('SQL', SQL);
          end;

          // con la tabella nota il nome della colonna non puo' mancare: prima
          // la sola tabella veniva restituita come origine, senza colonna
          if TableName = '' then
            Result := FieldName
          else
          begin
            if FieldName = '' then
              FieldName := Field.FieldName;
            Result := TableName + '.' + FieldName;
          end;
        end;
      end;

  // Per i campi calcolati l'origine e' il solo nome del campo, senza tabella
  // (DIV-DAT-7: qui TableName e' sempre vuoto, il vecchio ripiego che la
  // anteponeva non si eseguiva mai)
  if Result.IsEmpty then
    Result := Field.FieldName;

  if Assigned(FFieldOrigins) then
    FFieldOrigins.AddOrSetValue(Field.FieldName, Result);
end;

function TzFbDataSet.GetDatabase: TFDCustomConnection;
begin
  Result := Connection;
end;

function TzFbDataSet.GetDebugInfo: string;
var
  i: Integer;
  ParamStr: string;
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  try
    StrList.Add(Name + '.Active = ' + BoolToStr(Active, true));
    StrList.Add('');
    StrList.Add('SQL:'#13#10 + SelectSQL.Text);
    StrList.Add('');

    if ParamCount > 0 then
    begin
      StrList.Add('Params:');

      for i := 0 to ParamCount - 1 do
      begin
        if Params[i].IsNull then
          ParamStr := Params[i].Name + '= (Null)'
        else
        begin
          if Params[i].IsNumeric then
            ParamStr := Params[i].Name + '=' + Params[i].asString
          else
            if Params[i].IsFloat then
              ParamStr := Params[i].Name + '=' + Params[i].asString
            else
              if Params[i].IsDateTime then
                ParamStr := Params[i].Name + '=' + AnsiQuotedStr(Params[i].asString, #39)
              else
                ParamStr := Params[i].Name + '=' + AnsiQuotedStr(Params[i].asString, #39);
        end;
        StrList.Add(ParamStr);
      end;
    end;
    Result := StrList.Text;
  finally
    FreeAndNil(StrList);
  end;
end;

function TzFbDataSet.GetExternalField(const s: string): TField;
var
  TableName: String;
  tmp: string;
  FieldName: String;
  Component: TComponent;
begin
  Result := nil;

  tmp := s.Replace('[', '').Replace(']', '');

  TableName := tmp.Substring(0, tmp.IndexOf('.'));
  FieldName := tmp.Substring(tmp.IndexOf('.') + 1);

  if not Assigned(Owner) then
    Exit;

  Component := Owner.FindComponent(TableName);

  if Component is TDataset then
    Result := TDataset(Component).FindField(FieldName);
end;

function TzFbDataSet.GetFieldByOrigin(const Origin: string): TField;
begin
  Result := nil;
  for Result in Fields do
    if SameText(Result.Origin, Origin) or SameText(Result.FieldName, Origin) or SameText(FieldOrigin(Result), Origin) then
      Exit;

  Result := nil;
end;

function TzFbDataSet.GetFieldNameByOrigin(const Origin: string): string;
var
  Field: TField;
begin
  Result := '';

  Field := GetFieldByOrigin(Origin);
  if Assigned(Field) then
    Result := Field.FieldName;
end;

function TzFbDataSet.GetFieldTableName(Field: TField): string;
var
  Origin: string;
begin
  assert(Assigned(Field));

  Result := '';

  if Assigned(Field) then
    if Assigned(Table) then
      if Table.Columns.IndexOfName(Field.FieldName) <> -1 then
        Result := Table.Columns.ColumnByName(Field.FieldName).OriginTabName;

  if Result.IsEmpty then
  begin
    Origin := FieldOrigin(Field);
    if not Origin.IsEmpty then
      Result := System.Copy(Origin, 1, Pos('.', Origin) - 1);
  end;

  if Result.IsEmpty then
    Result := TableName;
end;

function TzFbDataSet.GetGeneratorName: string;
begin
  Result := UpdateOptions.GeneratorName;
end;

// DIV-LOC-4 e DIV-LOC-9: numero da scrivere nella condizione di ricerca.
// I numeri veri passano senza conversione di testo (il decimale e' sempre il
// punto, che e' quello che vuole Firebird); le stringhe si leggono con le
// impostazioni della postazione. Un valore non numerico diventa null.
function NumeroPerRicerca(const Value: Variant): string;
var
  Testo: string;
  Intero: Int64;
  Decimale: Extended;
begin
  Result := 'null';

  if VarIsNumeric(Value) and not VarIsStr(Value) then
  begin
    case VarType(Value) and varTypeMask of
      varSmallint, varShortInt, varByte, varWord, varInteger, varLongWord, varInt64, varUInt64:
        Result := VarToStr(Value);
    else
      Result := FloatToStr(Extended(Value), TFormatSettings.Invariant);
    end;
    Exit;
  end;

  Testo := StringReplace(Trim(VarToStr(Value)), FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
  if TryStrToInt64(Testo, Intero) then
    Result := IntToStr(Intero)
  else
    if TryStrToFloat(Testo, Decimale) then
      Result := FloatToStr(Decimale, TFormatSettings.Invariant);
end;

function TzFbDataSet.GetLocateSQL(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): string;
var
  ClausolaEscape: string;
  Field: TField;
  FieldName: string;
  Fields: TList;
  i: Integer;
  OperatorStr: string;
  PuntoOrigine: Integer;
  ValStr: string;
  Value: Variant;
  // Values: Variant;
begin
  Result := '';
  try
    Fields := TList.Create;
    try
      GetFieldList(Fields, KeyFields);

      for i := 0 to Fields.Count - 1 do
      begin
        if (Fields.Count = 1) and not VarIsArray(KeyValues) then
          Value := KeyValues
        else
          Value := KeyValues[i];

        // DIV-LOC-11: la stringa vuota salta il campo come il valore nullo
        if VarIsNull(Value) or (VarIsStr(Value) and (VarToStr(Value) = '')) then
          Continue;

        Field := TField(Fields[i]);
        FieldName := FieldOrigin(Field);
        if FieldName = '' then
          FieldName := Field.FieldName
        else
        begin
          // DIV-LOC-8: se nel FROM la tabella ha un alias, Firebird non accetta
          // piu' il nome originale: la condizione usa l'alias
          PuntoOrigine := Pos('.', FieldName);
          if PuntoOrigine > 1 then
            FieldName := zSql.SqlTxtRtns.AliasForTable(SelectSQL.Text, Copy(FieldName, 1, PuntoOrigine - 1)) + Copy(FieldName, PuntoOrigine, MaxInt);
        end;

        OperatorStr := ' = ';
        ClausolaEscape := '';

        case Field.DataType of
          ftString, ftFixedChar, ftWideString, ftGUID, ftFixedWideChar:
            begin
              ValStr := VarToStr(Value);
              OperatorStr := ' STARTING WITH ';

              // if ValStr = '' then
              // ValStr := #255
              // else
              // zz 13 marzo 2018: non entra mai nel giro dell' like
              // if (I = Fields.Count - 1) and (LoPartialKey in Options) then
              // begin
              // OperatorStr := ' STARTING WITH ';
              // end
              // else
              if ValStr.EndsWith('*') then
              begin
                OperatorStr := ' LIKE ';
                ValStr := System.Copy(ValStr, 1, Length(ValStr) - 1);
                // DIV-LOC-10: % e _ sono caratteri jolly di LIKE, si proteggono con ESCAPE
                ValStr := ValStr.Replace('\', '\\').Replace('%', '\%').Replace('_', '\_');
                ValStr := '%' + ValStr + '%';
                ClausolaEscape := ' ESCAPE ''\''';
              end
              else
                if loPartialKey in Options then
                  // ricerca prefisso esplicita
                  OperatorStr := ' STARTING WITH '
                else
                  // corrispondenza esatta
                  OperatorStr := ' = ';

              ValStr := QuotedStr(ValStr);

              // DIV-LOC-2: in maiuscolo il valore e il campo
              if LoCaseInsensitive in Options then
              begin
                ValStr := 'UPPER(' + ValStr + ')';
                FieldName := 'UPPER(' + FieldName + ')';
              end;
            end;
          ftDate:
            ValStr := QuotedStr(FormatDateTime('dd.mm.yyyy', VarToDateTime(Value)));
          ftTime:
            // DIV-LOC-3: anche l'ora, non solo la data
            ValStr := QuotedStr(FormatDateTime('hh:nn:ss.zzz', VarToDateTime(Value)));
          ftDateTime, ftTimeStamp, ftTimeStampOffset:
            ValStr := QuotedStr(FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', VarToDateTime(Value)));
          ftBoolean:
            begin
              if Value then
                ValStr := 'TRUE'
              else
                ValStr := 'FALSE';
            end;
          // DIV-LOC-4 e DIV-LOC-9: ftSingle e' un decimale; un intero cercato con
          // decimali non trova nessuna riga (non diventa piu' null o un altro numero)
          ftSmallint, ftShortint, ftByte, ftInteger, ftWord, ftAutoInc, ftLargeint, TFieldType.ftSingle, ftFloat, ftCurrency, ftBCD, ftFMTBcd:
            ValStr := NumeroPerRicerca(Value);
        else
          DatabaseErrorFmt(SBadFieldType, [TField(Fields[i]).FieldName]);
        end;

        if Result <> '' then
          Result := Result + ' AND ';

        // if VarIsNull(Value) then
        // Result := Result + FieldName + ' IS NULL'
        // else
        Result := Result + FieldName + OperatorStr + ValStr + ClausolaEscape;
      end;
    finally
      FreeAndNil(Fields);
    end;

  finally
    // OutputDebugString('');
    // OutputDebugString('----Locate------');
    // OutputDebugString('---');
    // OutputDebugString(PChar(Result));
    // OutputDebugString('---');
    // OutputDebugString(PChar('KeyFields: ' + KeyFields));
    // OutputDebugString(PChar('KeyValues: >' + VarToStr(KeyValues) + '<'));
    // if loCaseInsensitive in Options then
    // OutputDebugString('loCaseInsensitive');
    //
    // if loPartialKey in Options then
    // OutputDebugString('loPartialKey');
  end;
end;

function TzFbDataSet.GetOpenTime: TTimeSpan;
begin
  Result := StopWatch.Elapsed;
end;

function TzFbDataSet.GetOrderBy: string;
var
  StartPos, EndPos: Integer;
begin
  Result := zSql.SqlTxtRtns.OrderStringTxt(SelectSQL.Text, StartPos, EndPos);
end;

procedure TzFbDataSet.GetParamValues(aParams: TParams);
var
  i: Integer;
  CurParam: TParam;
  FldType: TFieldType;
begin
  if not Assigned(aParams) then
    Exit;

  aParams.clear;

  for i := 0 to Pred(Params.Count) do
  begin
    CurParam := aParams.CreateParam(Params[i].DataType, Params[i].Name, Params[i].ParamType);
    CurParam.Value := Params[i].Value
  end;
end;

function TzFbDataSet.GetPrimaryKeyFields: string;
begin
  Result := UpdateOptions.KeyFields;
end;

function TzFbDataSet.FirstPrimaryKeyField: string;
var
  Sorgente: string;
  Campi: TArray<string>;
begin
  // Mantis #74 - 2026-09-03: primo campo della chiave primaria, senza mai indicizzare
  // un array vuoto (era la causa dell'AV in OID quando la chiave non e' impostata).
  Result := '';

  Sorgente := FPrimaryKey;
  if Sorgente.Trim = '' then
    // compatibilita': dataset creati da codice su tabella reale, dove la chiave la
    // calcola FireDAC direttamente in UpdateOptions.KeyFields senza passare dal setter.
    Sorgente := UpdateOptions.KeyFields;

  Campi := Sorgente.Split([';', ',']);
  if Length(Campi) > 0 then
    Result := Campi[0].Trim;
end;

function TzFbDataSet.GetRecordCountSQL: string;
begin

  if CountSQL.Count <> 0 then
    Result := CountSQL.Text
  else
    Result := zSql.SqlTxtRtns.CountSelect(self.SelectSQL.Text);
end;

function TzFbDataSet.GetSQL_Delete: TStrings;
begin
  Result := InnerUpdateObject.DeleteSQL;
end;

function TzFbDataSet.GetSQL_Insert: TStrings;
begin
  Result := InnerUpdateObject.InsertSQL;
end;

function TzFbDataSet.GetSQL_Refresh: TStrings;
begin
  Result := InnerUpdateObject.FetchRowSQL;
end;

function TzFbDataSet.GetSQL_Select: TStrings;
begin
  Result := SQL;
end;

function TzFbDataSet.GetSQL_Update: TStrings;
begin
  Result := InnerUpdateObject.ModifySQL;
end;

function TzFbDataSet.GetWhere: string;
begin
  Result := zSql.SqlTxtRtns.MainWhereClause(SelectSQL.Text);
end;

procedure TzFbDataSet.InitForwardOnly(const doDisableControls: boolean);
begin
  // DIV-PRE-2: con doDisableControls vero i controlli restano disabilitati: il
  // chiamante deve chiamare EnableControls a fine lettura (di solito in un
  // try/finally); questo metodo non lo fa e non puo' farlo.

  if doDisableControls then
    DisableControls;

  FetchOptions.UniDirectional := true;
  FetchOptions.Mode := fmOnDemand;
  FetchOptions.RecsMax := -1;
  ResourceOptions.SilentMode := true;
  BuildFields(true);
end;

procedure TzFbDataSet.InternalClose;
begin
  // sizFbDataSet.EnterMethod(self, 'InternalClose');
  inherited;
  // sizFbDataSet.LeaveMethod(self, 'InternalClose');
end;

procedure TzFbDataSet.InternalOpen;
begin
  sizFbDataSet.EnterMethod(self, 'InternalOpen');

  if SelectSQL.Text.Trim.IsEmpty then
    sizFbDataSet.LogColored(clRed, 'SQL non specificato: ' + Name);

  // Mantis #161 - 2026-09-30: qui arriva ancora segnato solo il dataset che
  // non aveva campi costruiti prima dell'apertura; gli altri li ha gia'
  // ricostruiti DoBeforeOpen.
  if needRebuildFields then
  begin
    Fields.clear;
    needRebuildFields := false;
    needInitFields := true;
    InvalidateFieldOrigins;
  end;

  DumpDefaultExpressions;

  // Rete di sicurezza per la preparazione conservata da BuildFields (vedi
  // DoBeforeOpen). La firma dei parametri confronta i TIPI riportati da
  // Params[i].DataType, ma per il costrutto "(CAMPO = :P) OR (:P IS NULL)",
  // usato in 201 dataset LZ di Gesty per i filtri facoltativi, il protocollo
  // Firebird descrive le due occorrenze dello stesso parametro con SQLTYPE
  // diversi: la seconda (nel ramo "IS NULL") e' sempre SQL_NULL, per
  // costruzione del protocollo, indipendentemente dal tipo vero della
  // colonna (Language Reference, isc_dsql_describe_bind). Quale delle due
  // FireDAC riporta sulla proprieta' puo' non essere quella usata
  // internamente al bind reale, e la firma non se ne accorgerebbe perche'
  // sul lato Delphi non cambia nulla di visibile. Se questo succede, FireDAC
  // solleva un errore qui dentro, in fase di esecuzione: si sprepara e si
  // riprova una sola volta, esattamente il comportamento di prima ma solo
  // quando serve davvero.
  if FFirmaParametriPreparati <> '' then
  begin
    try
      inherited;
    except
      on e: Exception do
      begin
        sizFbDataSet.LogColored(clRed, 'InternalOpen: preparazione riusata non valida su ' + Name + ', ripreparo - ' + e.Message);
        UnPrepare;
        FFirmaParametriPreparati := '';
        inherited;
      end;
    end;
  end
  else
    inherited;

  // spostato in DoCreateFields
  // if needInitFields then // solo una volta...
  // UpdateFieldAttributes;

  sizFbDataSet.LeaveMethod(self, 'InternalOpen');
end;

procedure TzFbDataSet.InternalPost;
begin
  CheckBeforePost;
  // Mantis #257 - 2026-10-29: qui i valori sono definitivi (DoBeforePost,
  // sanificazione e OnBeforePost sono gia' passati) e la riga e' ancora in
  // modifica: e' l'ultimo punto in cui ModifySQL si puo' cambiare prima che
  // FireDAC prenda il comando (TFDCustomTableAdapter.Update lo ricrea a ogni
  // Post se il testo e' cambiato).
  ComponiUpdateSQL;
  RegistraPost;
  inherited;

  // 20.09.2022
  // Il componente non pùò recuperare valori calcolati da view o altro:
  // returning sulle view non sempre funziona
  // da vedere effetti collaterali: se spostare in afterpost o altro
  if ReopenAfterPost then
    RefreshRecord();
end;

procedure TzFbDataSet.SetAutoUpdate(const Value: boolean);
begin
  FAutoUpdate := Value;
  // il testo di partenza e' quello appena scritto da TzSystem (vedi la
  // proprieta'): finche' ModifySQL resta quello o uno composto qui, il dataset
  // lo puo' riscrivere
  if FAutoUpdate then
    FUltimoUpdateSQL := InnerUpdateObject.ModifySQL.Text
  else
    FUltimoUpdateSQL := '';
end;

procedure TzFbDataSet.SetAutoUpdateColumns(const Value: TStrings);
begin
  FAutoUpdateColumns.Assign(Value);
end;

procedure TzFbDataSet.SetAutoUpdateKeyFields(const Value: TStrings);
begin
  FAutoUpdateKeyFields.Assign(Value);
end;

procedure TzFbDataSet.SetAutoUpdateReturning(const Value: TStrings);
begin
  FAutoUpdateReturning.Assign(Value);
end;

// Mantis #257 - 2026-10-29: True se il valore da salvare e' diverso da quello
// letto da questo dataset (non da quello del database: una scheda vecchia con
// la nota vecchia, non toccata, non la riscrive).
// - MEMO, BLOB e campi binari: confronto dei buffer di FireDAC fra la versione
//   in modifica e quella letta (CompareColumnVersions, esatto e senza
//   convertire il contenuto in Variant). Un BLOB non ancora letto e non
//   toccato non risulta cambiato.
// - Gli altri: VarSameValue, lo stesso criterio di SanificaCampiTesto.
//   Riassegnare lo stesso valore non rende il campo cambiato.
function TzFbDataSet.CampoCambiato(Field: TField): boolean;
var
  Riga: TFDDatSRow;
  Indice: Integer;
begin
  if Field.IsBlob or (Field is TBinaryField) then
  begin
    Riga := GetRow;
    if Assigned(Riga) and (Riga.RowState = rsEditing) and Assigned(Table) then
    begin
      Indice := Table.Columns.IndexOfName(Field.FieldName);
      if Indice <> -1 then
        Exit(not Riga.CompareColumnVersions(Indice, rvProposed, rvCurrent));
    end;
  end;

  try
    Result := not VarSameValue(Field.OldValue, Field.Value);
  except
    // valori che VarSameValue non sa confrontare: meglio scriverli che perderli
    on EVariantError do
      Result := true;
  end;
end;

// Mantis #257 - 2026-10-29: riscrive ModifySQL prima del Post di una modifica.
// L'UPDATE automatico (Build_Sql_Update) mette nel SET tutte le colonne: un
// dataset che aveva in memoria il record letto prima del salvataggio di
// un'altra finestra riscriveva cosi' anche le colonne che non aveva toccato,
// con i valori vecchi (la nota persa del ticket, casi 4 e 5 dell'analisi).
// Con UpdateChangedFields accesa nel SET vanno solo le colonne del dataset
// cambiate rispetto al record letto; se non ne e' cambiata nessuna, il SET
// della sola chiave (il salvataggio parte lo stesso, come prima, per trigger
// e USR_DATA_MDF). WHERE e RETURNING restano quelli di sempre.
// - Solo con AutoUpdate (UpdateSQL scritti a mano esclusi), in modifica, senza
//   CachedUpdates, e solo se ModifySQL e' ancora quello che il dataset conosce.
// - UpdateChangedFields falso (predefinito): si rimette l'UPDATE completo, se
//   un Post precedente l'aveva ridotto.
// - Il testo si assegna solo se cambia: l'assegnazione sprepara il comando e
//   costa una preparazione sul server al Post successivo.
// - Mai un testo vuoto: FireDAC eseguirebbe il comando precedente. Se la
//   composizione non da' niente resta il testo attuale.
procedure TzFbDataSet.ComponiUpdateSQL;
var
  Cambiate: TStringList;
  Normalizzato: TStringList;
  Colonna: string;
  Field: TField;
  Testo: string;
begin
  if not FAutoUpdate then
    Exit;
  if State <> dsEdit then
    Exit;
  if CachedUpdates then
    Exit;

  if InnerUpdateObject.ModifySQL.Text <> FUltimoUpdateSQL then
  begin
    sizFbDataSet.LogWarning(Name + ': UpdateSQL cambiato dopo l''impostazione automatica, si usa cosi'' com''e''');
    Exit;
  end;

  Testo := '';
  if FUpdateChangedFields then
  begin
    Cambiate := TStringList.Create;
    try
      for Colonna in FAutoUpdateColumns do
      begin
        // colonne assenti dalla SELECT, campi calcolati e lookup: mai nel SET
        Field := FindField(Colonna);
        if (Field = nil) or (Field.FieldKind <> fkData) then
          Continue;
        if CampoCambiato(Field) then
          Cambiate.Add(Colonna);
      end;

      Testo := ComponiUpdateParziale(TableName, Cambiate, FAutoUpdateKeyFields, FAutoUpdateWhere, FAutoUpdateReturning);
    finally
      FreeAndNil(Cambiate);
    end;
  end;

  if Testo = '' then
    Testo := ComponiUpdateParziale(TableName, FAutoUpdateColumns, nil, FAutoUpdateWhere, FAutoUpdateReturning);

  if Testo = '' then
    Exit;

  // confronto riga per riga: la WHERE di Calc_WhereByKeyFields contiene #13
  // senza #10, che TStrings divide in righe. Si assegna con Text e non con
  // Assign, che copierebbe anche le opzioni della lista (a capo finale) e
  // cambierebbe il testo che ModifySQL restituisce.
  Normalizzato := TStringList.Create;
  try
    Normalizzato.Text := Testo;
    if not InnerUpdateObject.ModifySQL.Equals(Normalizzato) then
      InnerUpdateObject.ModifySQL.Text := Testo;
  finally
    FreeAndNil(Normalizzato);
  end;

  FUltimoUpdateSQL := InnerUpdateObject.ModifySQL.Text;
end;

function TzFbDataSet.IsCalcField(FieldName: string): boolean;
var
  col: TFDDatSColumn;
begin
  Result := false;

  if Assigned(Table) then
    if Table.Columns.IndexOfName(FieldName) <> -1 then
    begin
      col := Table.Columns.ColumnByName(FieldName);

      if Assigned(col) then
        Result := caExpr in col.Attributes
    end;
end;

function TzFbDataSet.IsCalcField(Field: TField): boolean;
begin
  Result := IsCalcField(Field.FieldName);
end;

function TzFbDataSet.IsDetailParamField(FieldName: string): boolean;
begin
  Result := ParamExists(FieldName);
end;

function TzFbDataSet.IsExternalField(const s: string): boolean;
begin
  // es.: [TableName.FieldName]
  Result := s.StartsWith('[') and s.EndsWith(']');
end;

function TzFbDataSet.IsGeneratorField(FieldName: string): boolean;
begin
  Result := SameText(FieldName, UpdateOptions.KeyFields);
end;

function TzFbDataSet.IsJoinedField(FieldName: string): boolean;
var
  col: TFDDatSColumn;
begin
  Result := false;

  if Assigned(Table) then
    if Table.Columns.IndexOfName(FieldName) <> -1 then
    begin
      col := Table.Columns.ColumnByName(FieldName);

      if Assigned(col) then
        Result := not SameText(TableName, col.OriginTabName);
    end;
end;

function TzFbDataSet.IsJoinedField(Field: TField): boolean;
begin
  assert(Assigned(Field));
  Result := IsJoinedField(Field.FieldName);
end;

function TzFbDataSet.IsMasterDetailParam(ParamName: string): boolean;
begin
  Result := false;
  if ParamExists(ParamName) then
    if Assigned(DataSource) then
      if Assigned(DataSource.DataSet) then
        if Assigned(DataSource.DataSet.FindField(ParamName)) then
          Result := true;
end;

function TzFbDataSet.IsParamUID(FieldName: string): boolean;
var
  dummy: Integer;
begin
  Result := false;

  if not Assigned(Adapter) then
    Exit;

  if Assigned(Adapter.InsertCommand) then
    if Assigned(Adapter.InsertCommand.Params.FindParam(FieldName)) then
      Exit(true);

  if Assigned(Adapter.UpdateCommand) then
    if Assigned(Adapter.UpdateCommand.Params.FindParam(FieldName)) then
      Exit(true);

  if Assigned(Adapter.DeleteCommand) then
    if Assigned(Adapter.DeleteCommand.Params.FindParam(FieldName)) then
      Exit(true);
end;

function TzFbDataSet.IsServerCalcField(FieldName: string): boolean;
var
  col: TFDDatSColumn;
begin
  Result := false;

  if Assigned(Table) then
    if Table.Columns.IndexOfName(FieldName) <> -1 then
    begin
      col := Table.Columns.ColumnByName(FieldName);

      if Assigned(col) then
        Result := caCalculated in col.Attributes
    end;
end;

function TzFbDataSet.IsServerCalcField(Field: TField): boolean;
begin
  Result := IsServerCalcField(Field.FieldName);
end;

function TzFbDataSet.Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
var
  s: String;
  color: tcolor;
begin
  // 10.11.2022 i combo non chiamano più DataSet.Locate
  // Result := inherited Locate(AKeyFields, AKeyValues, AOptions);
  // Exit; // <---------------------------------------------------
  /// /////////////////////////////////////////////////////////

  if UseSqlLocate then
    Result := LocateSQL(AKeyFields, AKeyValues, AOptions)
  else
    Result := inherited Locate(AKeyFields, AKeyValues, AOptions);

  if true then
  begin
    if not Active then
      sizFbDataSet.LogColored(clPurple, 'CLOSED');

    if Result then
      color := clGreen
    else
      color := clRed;

    if VarIsNull(AKeyValues) or (VarIsStr(AKeyValues) and (AKeyValues = '')) or ((not VarIsArray(AKeyValues)) and (AKeyValues = Null)) then
      s := ''
    else
      if VarIsArray(AKeyValues) then
        s := 'VarArray'
      else
        s := VarToStr(AKeyValues);

    sizFbDataSet.LogColored(color, Name);
    sizFbDataSet.LogColored(color, AKeyFields + ': ' + s);
    sizFbDataSet.LogColored(color, Where);
    sizFbDataSet.LogSeparator;
  end;
end;

function TzFbDataSet.LocateFound(KeyFields: string; KeyValues: Variant; Options: TLocateOptions): boolean;
  function SameValue(V1, V2: Variant; IsString, CaseInsensitive, PartialLength: boolean): boolean;
  var
    S1, S2: string;
  begin
    if not IsString then
    begin
      try
        Result := VarSameValue(V1, V2)
      except
        on e: EVariantTypeCastError do
          Result := false;
      end;
    end
    else
    begin
      S1 := VarToStr(V1);
      S2 := VarToStr(V2);
      if PartialLength then
      begin
        if (Length(S1) = 0) and (Length(S2) > 0) then
        begin
          Result := false;
          Exit;
        end;
        S2 := Copy(S2, 1, Length(S1));
      end;
      if CaseInsensitive then
        Result := AnsiSameText(S1, S2)
      else
        Result := AnsiSameStr(S1, S2);
    end;
  end;

var
  J: Integer;
  Field: TField;
  Fields: TList;
  Values: Variant;
begin
  Result := true;

  Fields := TList.Create;
  try
    GetFieldList(Fields, KeyFields);

    if VarIsArray(KeyValues) then
      Values := KeyValues
    else
      Values := VarArrayOf([KeyValues]);

    for J := 0 to Fields.Count - 1 do
    begin
      Field := TField(Fields[J]);
      if not SameValue(Field.Value, Values[J], Field.DataType in [ftString, ftFixedChar, ftWideString, ftFixedWideChar, ftGUID], LoCaseInsensitive in Options, loPartialKey in Options) then
      begin
        Result := false;
        Break;
      end;
    end;

  finally
    FreeAndNil(Fields);
  end;
end;

function TzFbDataSet.LocateParamsEmpty(KeyValues: Variant): boolean;
  function Empty(KeyValue: Variant): boolean;
  begin
    Result := (KeyValue = Null) or VarIsNull(KeyValue);

    if not Result then
      if VarIsStr(KeyValue) then
        Result := VarToStr(KeyValue) = '';
  end;

var
  i: Integer;
begin
  Result := true;

  if VarIsArray(KeyValues) then
  begin
    for i := VarArrayLowBound(KeyValues, 1) to VarArrayHighBound(KeyValues, 1) do
      if not Empty(KeyValues[i]) then
        Exit(false);

    Exit(true);
  end
  else
    Result := Empty(KeyValues);
end;

function TzFbDataSet.LocateSQL(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
var
  CampiChiave: string;
  ChiaveCorrente: Variant;
  Where: string;
begin
  Result := false;

  if not Active then
    Exit(false);

  if InLocate then
    Exit;

  InLocate := true;
  try

    if LocateParamsEmpty(AKeyValues) then
    begin
      // zz 26.10.2017: per i MasterFields variati dopo la creazione dei lookup
      // if (LocateWhere <> '') then
      RevertSQL(true);

      Exit(false); //
    end;

    if LocateFound(AKeyFields, AKeyValues, AOptions) then
      Exit(true); // sarebbe da verificare con il resto della lista..

    Where := GetLocateSQL(AKeyFields, AKeyValues, AOptions);

    // se non è valido con il test sopra è inutile mantenere la where precedente
    // if (LocateWhere <> Where) then
    // begin
    LocateWhere := Where;

    // DIV-LOC-1: il record corrente si ricorda per tornarci se la ricerca fallisce
    ChiaveCorrente := Unassigned;
    CampiChiave := UpdateOptions.KeyFields;
    if not MantieniElencoSeNonTrova and not CampiChiave.Trim.IsEmpty then
      try
        ChiaveCorrente := FieldValues[CampiChiave];
      except
        ChiaveCorrente := Unassigned;
      end;

    DisableControls;
    try
      RevertSQL(false);
      AddWhereCondition(LocateWhere);
      Active := true;
      Result := not IsEmpty;
    finally
      EnableControls;
    end;

    // ZZ 05.05.2026: i campi di scelta non devono ritrovarsi il primo record della lista quando non
    // c'e' corrispondenza; per loro MantieniElencoSeNonTrova e' vero. Per ogni altro chiamante una
    // ricerca fallita non lascia il dataset filtrato (DIV-LOC-1)
    if not Result and not MantieniElencoSeNonTrova then
    begin
      LocateWhere := '';
      RevertSQL(true); // ripristina SQL e riapre con tutti i record
      if not VarIsEmpty(ChiaveCorrente) then
        LocateNonSQL(CampiChiave, ChiaveCorrente, []);
    end;
  finally
    InLocate := false;
  end;
end;

function TzFbDataSet.Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant;
begin
  // DIV-LOC-7: la riga di registro in rosso e' stata tolta; Lookup resta la ricerca in memoria
  // di TDataSet e non passa da UseSqlLocate
  Result := inherited Lookup(KeyFields, KeyValues, ResultFields);
end;

function TzFbDataSet.ParamExists(const ParamName: string): boolean;
begin
  Result := Assigned(FindParam(ParamName));
end;

function TzFbDataSet.FirmaParametri: string;
var
  i: Integer;
begin
  // Tipo, dimensione, precisione, scala e verso di ogni parametro: sono i
  // tratti che FireDAC confronta con quelli fissati alla preparazione. Il
  // valore non c'entra: cambia a ogni apertura senza bisogno di ripreparare.
  Result := '';
  for i := 0 to ParamCount - 1 do
    Result := Result + Params[i].Name + '|' + IntToStr(Ord(Params[i].DataType)) + '|' + IntToStr(Params[i].Size) + '|' + IntToStr(Params[i].Precision) + '|' + IntToStr(Params[i].NumericScale) + '|' + IntToStr(Ord(Params[i].ParamType)) + ';';
end;

procedure TzFbDataSet.BuildFields(const clear: boolean = false);
var
  wasPrepared: boolean;
  RebuildFieldDefs: boolean;
  PreparedWithoutRows: boolean;
  SavedRecsMax: Integer;
  DataSetPrecedente: TzFbDataSet;
  Misura: boolean;
  Cronometro: TStopWatch;
begin
  // Misura per la sessione di registrazione attivabile dall'utente: e' la
  // voce che ha reso visibile il costo della preparazione (255 ms su
  // Progetti, 11,3 s su 64 dataset in una sessione in VPN).
  Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
  if Misura then
    Cronometro := TStopWatch.StartNew;

  wasPrepared := Prepared;
  RebuildFieldDefs := clear or (FieldDefs.Count = 0); // 13.09.2022: Ingiunzioni.IngDaRinnovare

  // Mantis #183 - 2026-10-08: struttura letta senza far lavorare il server.
  // FieldDefs.Update a dataset chiuso ESEGUE la SELECT (il driver Firebird di
  // FireDAC definisce le colonne aprendo il cursore, InternalColInfoStart in
  // FireDAC.Phys.IBBase), e il server la risolve per intero nel commit che
  // chiude la transazione avviata da FireDAC: su "Incarichi Da Gestire" 3,7 s
  // buttati, poi l'apertura vera esegue di nuovo la stessa query. Con
  // RecsMax = 0 impostato PRIMA del Prepare FireDAC prepara la SELECT con
  // "ROWS 0" in coda: il server non produce righe e la definizione costa
  // pochi ms, con FieldDefs identici (prova in D:\AI\SandBox\Prova183FieldDefs).
  // Impostato dopo il Prepare non serve: la clausola nasce in preparazione.
  // Solo se la struttura va davvero riletta: altrimenti la preparazione
  // resta quella normale e l'apertura che segue la riusa, come prima.
  PreparedWithoutRows := (not wasPrepared) and RebuildFieldDefs and CanPrepareWithoutRows;
  SavedRecsMax := FetchOptions.RecsMax;

  try
    if not Prepared then
    begin
      // Il Prepare fallisce ogni volta che la SELECT dell'LZ non corrisponde
      // piu' al database (colonna rinominata o tolta), e qui non c'e' nessuna
      // Open in corso: senza questa riga chi raccoglie il contesto non sa a chi
      // attribuire l'errore e il dettaglio dell'eccezione resta senza il nome
      // del dataset da correggere.
      // Il salva/ripristina serve perche' BuildFields viene chiamata anche
      // dentro l'apertura di un ALTRO dataset, quando si caricano le proprieta'
      // dall'LZ: la traccia di quella apertura non va persa.
      DataSetPrecedente := CurrentOpeningDataSet;
      CurrentOpeningDataSet := self;
      try
        if PreparedWithoutRows then
        begin
          FetchOptions.RecsMax := 0;
          try
            Prepare;
          except
            on e: Exception do
            begin
              // Mantis #183 - 2026-10-08: SELECT che non ammette "ROWS" in
              // coda (per esempio una SELECT FIRST n, che Firebird rifiuta
              // insieme a ROWS con l'errore -104). Si torna alla preparazione
              // normale qui sotto: costa l'esecuzione in piu' come prima, ma
              // la struttura si legge lo stesso, e se la SELECT e' davvero
              // sbagliata l'errore esce dal Prepare normale come sempre.
              sizFbDataSet.LogString(Name, 'BuildFields: preparazione senza righe rifiutata, preparazione normale - ' + e.Message);
              PreparedWithoutRows := false;
              FetchOptions.RecsMax := SavedRecsMax;
              if Prepared then
                UnPrepare;
            end;
          end;
        end;

        if not Prepared then
          Prepare;
      finally
        if CurrentOpeningDataSet = self then
          CurrentOpeningDataSet := DataSetPrecedente;
      end;
    end;

    if RebuildFieldDefs then
    begin
      try
        FieldDefs.Updated := false;
        FieldDefs.Update;
      except
        on e: Exception do
          sizFbDataSet.LogException(e); // es. Intestatari.Segnalazioni
      end;
    end;

    if clear then
      Fields.clear;

    DoCreateFields;
  finally
    // Mantis #183 - 2026-10-08: la preparazione con "ROWS 0" non deve mai
    // servire a un'apertura vera, che restituirebbe zero righe: si rimette il
    // limite del dizionario e si sprepara, anche se la definizione e' fallita.
    // Comunque non sarebbe sopravvissuta: il commit della transazione avviata
    // da FireDAC per la definizione sprepara il comando
    // (TFDPhysCommand.Disconnect -> Unprepare).
    if PreparedWithoutRows then
    begin
      FetchOptions.RecsMax := SavedRecsMax;
      if Prepared then
        UnPrepare;
      FFirmaParametriPreparati := '';
    end;
  end;

  // ZZ 26.05.2026: ottimizzazione creazione TFields
  needRebuildFields := false; // i campi sono appena stati costruiti

  // La preparazione resta in piedi: l'apertura che segue la riusa invece di
  // rifare Prepare e descrizione, cioe' un giro di rete piu' il lavoro
  // dell'ottimizzatore, per ogni dataset. Prima qui si chiamava UnPrepare
  // "altrimenti risultera' che i tipi dei parametri sono cambiati": quel
  // caso e' gestito in DoBeforeOpen, che confronta la firma dei parametri
  // fotografata qui con quella al momento dell'apertura e sprepara solo se
  // e' davvero cambiata.
  // Mantis #183 - 2026-10-08: vale solo quando la struttura non e' stata
  // riletta qui (campi gia' definiti) o il dataset era gia' preparato; dopo
  // una preparazione senza righe non c'e' niente da conservare.
  if Prepared then
    FFirmaParametriPreparati := FirmaParametri
  else
    FFirmaParametriPreparati := '';

  if Misura then
    zDiagnostica.Log.Perf.SegnalaOperazione(coInterfaccia, 'BuildFields', Cronometro.ElapsedMilliseconds, Name + ' | gia'' preparato=' + BoolToStr(wasPrepared, true) + ' | senza righe=' + BoolToStr(PreparedWithoutRows, true));
end;

// Mantis #183 - 2026-10-08: dice se FireDAC, preparando con RecsMax = 0,
// mette davvero il limite nella SELECT. Con fmExactRecsMax non lo genera
// (verificato in D:\AI\SandBox\Prova183FieldDefs): la definizione eseguirebbe
// la query come prima, e tanto vale non toccare il limite. Con RecsSkip il
// limite diventerebbe un intervallo: nessun dataset lo usa, e si lascia stare.
// Spento togliendo zfoFieldDefsWithoutRows da ExtendedFetchOptions (dizionario LZ).
function TzFbDataSet.CanPrepareWithoutRows: boolean;
begin
  Result := (zfoFieldDefsWithoutRows in FExtendedFetchOptions) and (FetchOptions.Mode <> fmExactRecsMax) and (FetchOptions.RecsSkip <= 0) and not SelectSQL.Text.Trim.IsEmpty;
end;

// Mantis #183 - 2026-10-08: zfoBlobsWithRow e' una vista su fiBlobs di
// FetchOptions.Items, che resta l'unico stato vero: chi tocca FetchOptions
// direttamente (codice o .dfm) lo vede riflesso qui.
function TzFbDataSet.GetExtendedFetchOptions: TzFetchOptions;
begin
  Result := FExtendedFetchOptions - [zfoBlobsWithRow];
  if fiBlobs in FetchOptions.Items then
    Include(Result, zfoBlobsWithRow);
end;

procedure TzFbDataSet.SetExtendedFetchOptions(const Value: TzFetchOptions);
begin
  FExtendedFetchOptions := Value;

  if (zfoBlobsWithRow in Value) <> (fiBlobs in FetchOptions.Items) then
    if zfoBlobsWithRow in Value then
      FetchOptions.Items := FetchOptions.Items + [fiBlobs]
    else
      FetchOptions.Items := FetchOptions.Items - [fiBlobs];
end;

function TzFbDataSet.RecordCountFromServer(const CountSQL: string = ''): Largeint;
var
  FDQuery: TFDQuery;
  i: Integer;
begin
  Result := -1;

  FDQuery := TFDQuery.Create(self);
  try
    FDQuery.Name := self.Name + '__RecordCountFromSrv';
    FDQuery.Connection := self.Connection;
    FDQuery.Transaction := self.Transaction;
    // DIV-DAT-3: un conteggio proprio passato dal chiamante ha la precedenza
    if Trim(CountSQL) <> '' then
      FDQuery.SQL.Text := CountSQL
    else
      FDQuery.SQL.Text := GetRecordCountSQL;
    FDQuery.Prepare;

    for i := 0 to FDQuery.Params.Count - 1 do
      if self.ParamExists(FDQuery.Params[i].Name) then
        FDQuery.Params[i].Value := self.ParamByName(FDQuery.Params[i].Name).Value;

    FDQuery.Open;
    try
      Result := FDQuery.Fields[0].AsLargeInt;
    finally
      FDQuery.Close;
    end;
  finally
    FreeAndNil(FDQuery);
  end;
end;

procedure TFDAdaptedDataSetHelper.RefreshCalcFields;
var
  SaveState: TDatasetState;
begin

  if not(State in dsEditModes) then
    if State <> dsCalcFields then
      Exit;

  SaveState := SetTempState(dsCalcFields);
  try
    TDataSetAccess(self).CalculateFields(ActiveBuffer);
  finally
    RestoreState(SaveState);
  end;
end;

procedure TzFbDataSet.ReOpen(const dummy: boolean = false);
var
  bm: TBookmark;
  rec: Integer;
begin
  sizFbDataSet.EnterMethod(self, 'ReOpen');

  bm := GetBookmark;
  try
    rec := RecNo;
    Active := false;
    Active := true;
    try
      try
        if BookmarkValid(bm) then
          GotoBookmark(bm);
      except
        // se da errore di bookmark tenta il recno
        RecNo := rec;
      end;
    except
    end;
  finally
    FreeBookmark(bm);
  end;

  sizFbDataSet.LeaveMethod(self, 'ReOpen');
end;

function TzFbDataSet.RequiredFieldOk(Field: TField): boolean;
begin
  assert(Assigned(Field));
  Result := true;

  if Field.Required then
    if Field.IsNull then
      if not Field.ReadOnly then
        if Field.FieldKind = fkData then
          if not IsJoinedField(Field) then
            if not IsServerCalcField(Field.FieldName) then
              if not IsCalcField(Field.FieldName) then
                Result := false;
end;

function TzFbDataSet.RequiredFieldsOk: boolean;
var
  Field: TField;
  i: Integer;
begin
  Result := true;

  for i := 0 to FieldCount - 1 do
  begin
    Field := Fields[i];
    if not RequiredFieldOk(Field) then
    begin
      Result := false;
      Break;
    end;
  end;
end;

procedure TzFbDataSet.RevertSQL(const Activate: boolean = false);
var
  NeedsChange: boolean;
begin
  NeedsChange := not SameText(SelectSQL.Text, FDefaultSQL.Text) and (Trim(FDefaultSQL.Text) <> '');

  // ZZ 30.05.2017: prima l'active False interveniva solamente se era variato l'sql
  if NeedsChange or Activate then
    Active := false;

  if NeedsChange then
    SelectSQL.Assign(FDefaultSQL);

  if Activate then
    Active := true;
end;

procedure TzFbDataSet.SetActivationMode(const Value: TActivationMode);
begin
  FActivationMode := Value;
end;

procedure TzFbDataSet.SetCountSQL(const Value: TStrings);
begin
  FCountSQL.Assign(Value);
end;

procedure TzFbDataSet.SetDatabase(const Value: TFDCustomConnection);
begin
  Connection := Value;
end;

procedure TzFbDataSet.SetDefaultSQL(const Value: TStrings);
begin
  FDefaultSQL.Assign(Value);
end;

procedure TzFbDataSet.SetDefaultValues(const Value: TStrings);
begin
  FDefaultValues.Assign(Value);
end;

procedure TzFbDataSet.SetFieldsReadOnly;
var
  Field: TField;
begin

  for Field in Fields do
  // if not Field.ReadOnly then // per selected
  begin
    if SameText(Field.FieldName, 'SELECTED') then
      Field.ReadOnly := false
    else
      if SameText(Field.FieldName, IdentityField) then
        Field.ReadOnly := true
      else
        if IsJoinedField(Field.FieldName) then
          if not IsParamUID(Field.FieldName) then
            Field.ReadOnly := true;
  end;
end;

procedure TzFbDataSet.SetGeneratorName(const Value: string);
begin
  UpdateOptions.GeneratorName := Value;
end;

procedure TzFbDataSet.SetIdDataSet(const Value: string);
begin
  FIdDataSet := Value;
end;

procedure TzFbDataSet.SetIdentityField(const Value: string);
var
  Field: TField;
begin
  FIdentityField := Value;

  Field := FindField(IdentityField);
  if Assigned(Field) then
    Field.ReadOnly := true;
end;

procedure TzFbDataSet.SetOnAfterCreateFields(const Value: TDataSetNotifyEvent);
begin
  FOnAfterCreateFields := Value;
end;

procedure TzFbDataSet.SetOnBeforeCreateFields(const Value: TDataSetNotifyEvent);
begin
  FOnBeforeCreateFields := Value;
end;

procedure TzFbDataSet.SetOnCustomBeforePost(const Value: TDataSetNotifyEvent);
begin
  FOnCustomBeforePost := Value;
end;

procedure TzFbDataSet.SetOnGetQueryParams(const Value: TDataSetNotifyEvent);
begin
  FOnGetQueryParams := Value;
end;

procedure TzFbDataSet.SetOrderBy(const Value: string);
var
  SQL: string;
begin
  SQL := zSql.SqlTxtRtns.SetOrderClause(SelectSQL.Text, Value);
  ChangeSQL(SQL);
end;

procedure TzFbDataSet.SetParamValues(aParams: TParams);
var
  i: Integer;
  CurParam: TFDParam;
begin
  if Assigned(aParams) then
    for i := 0 to aParams.Count - 1 do
    begin
      CurParam := FindParam(aParams[i].Name);
      if CurParam <> nil then
        CurParam.Value := aParams[i].Value;
    end;
end;

procedure TzFbDataSet.SetPrimaryKeyFields(const Value: string);
begin
  UpdateOptions.KeyFields := Value;

  // Mantis #74 - 2026-09-03: conserva la chiave dichiarata dai metadati (LZ / generatore)
  // in una copia che ValidateKeyFields e i rebuild dei campi di FireDAC non azzerano.
  // La usa OID come sorgente prioritaria del fallback.
  if Value.Trim <> '' then
    FPrimaryKey := Value;
end;

procedure TzFbDataSet.SetRequiredForJoinFields;
var
  Field: TField;
begin
  for Field in Fields do
    if Field.Required then
      if IsJoinedField(Field.FieldName) or IsServerCalcField(Field.FieldName) or IsCalcField(Field.FieldName) then
        Field.Required := false;
end;

procedure TzFbDataSet.SetSQL_Delete(const Value: TStrings);
begin
  InnerUpdateObject.DeleteSQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Insert(const Value: TStrings);
begin
  InnerUpdateObject.InsertSQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Refresh(const Value: TStrings);
begin
  InnerUpdateObject.FetchRowSQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Select(const Value: TStrings);
begin
  // ZZ 26.05.2026: ottimizzazione creazione TFields
  if not SQL.Equals(Value) then
    needRebuildFields := true;

  SQL.Assign(Value);
end;

procedure TzFbDataSet.SetSQL_Update(const Value: TStrings);
begin
  InnerUpdateObject.ModifySQL.Assign(Value);
end;

procedure TzFbDataSet.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

procedure TzFbDataSet.SetUseSqlLocate(const Value: boolean);
begin
  FUseSqlLocate := Value;
end;

procedure TzFbDataSet.SetWhere(const Value: string);
var
  Parser: TSQLParser;
  SQL: string;
begin
  Parser := TSQLParser.Create(SelectSQL.Text);
  try
    // DIV-SQL-1: la WHERE principale (non la prima del testo, che puo' stare in una sottoquery);
    // se manca, la condizione si aggiunge
    SQL := Parser.SetMainWhereClause(Value);
  finally
    Parser.Free
  end;

  ChangeSQL(SQL);
end;

function TzFbDataSet.TryChangeSQL(const NewSql: string): boolean;
begin
  // DIV-DAT-5: versione che non rilancia, per chi preferisce l'esito all'eccezione.
  // L'errore resta nel registro; il dataset e' gia' tornato alla SELECT precedente.
  try
    ChangeSQL(NewSql);
    Result := true;
  except
    on e: Exception do
    begin
      sizFbDataSet.LogColored(clRed, 'TryChangeSQL: cambio SQL fallito su ' + Name + ' - ' + e.Message);
      Result := false;
    end;
  end;
end;

procedure TzFbDataSet.ChangeSQL(const NewSql: string);
var
  wasActive: boolean;
  oldSql: string;
begin
  if SameText(SelectSQL.Text, NewSql) then
    Exit;

  wasActive := Active;
  Active := false;

  oldSql := SelectSQL.Text;

  // il cambio di SQL passa dal getter (SelectSQL.Text := ...) e non da
  // SetSQL_Select: la marcatura per la ricostruzione dei TFields va fatta qui,
  // altrimenti InternalOpen salta Fields.Clear e i campi restano agganciati
  // al tracciato precedente
  needRebuildFields := true;
  SelectSQL.Text := NewSql;

  if not wasActive then
    Exit;

  try
    Active := true;
  except
    // il ripristino dell'SQL precedente non deve mascherare l'eccezione
    // originale: se anche la riapertura col vecchio SQL fallisce, si logga
    // e si rilancia comunque l'errore vero
    try
      Active := false;
      needRebuildFields := true;
      SelectSQL.Text := oldSql;
      Active := true;
    except
      on e: Exception do
        sizFbDataSet.LogColored(clRed, 'ChangeSQL: ripristino SQL fallito su ' + Name + ' - ' + e.Message);
    end;

    raise;
  end;
end;

function TzFbDataSet.NormalizeDefaultExpression(const Value: string): string;
begin
  // Riporta sempre la default expression al valore "grezzo", indipendentemente
  // da quante volte la procedura sia gia' stata chiamata sullo stesso campo.
  // Questo rende UpdateDefaultExpressions idempotente: si ricalcola sempre a
  // partire dal valore non quotato e senza prefisso DEFAULT.
  Result := Trim(Value);

  // senza replaceAll
  if StartingWith(Result, 'DEFAULT ') then
    Result := StringReplace(Result, 'DEFAULT ', '', [rfIgnoreCase]);

  // ZZ 13.05.2016: FB3 - rimuove eventuali apici esterni
  Result := AnsiDequotedStr(Trim(Result), #39);

  // Normalizzazione date sentinella sul valore grezzo
  if SameText(Result, '31.12.9999') then
    Result := '31/12/9999'
  else
    if SameText(Result, '01.01.1900') then
      Result := '01/01/1900';
end;

function TzFbDataSet.IsContextDefault(const RawExpression: string): boolean;
begin
  // Keyword di contesto Firebird: devono restare NON quotate perche' risolte
  // lato client da ApplyDefaultExpression. Quotandole, FireDAC le valuta come
  // stringa e solleva [Stan][Eval]-118.
  Result := IndexText(RawExpression, ['NOW', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'TODAY', 'CURRENT_DATE', 'TOMORROW', 'YESTERDAY']) >= 0;
end;

// Mantis #153 - 2026-09-21: fotografa le DefaultExpression dei campi.
// Le voci vuote non si conservano: un default soppresso di proposito
// (OVERRIDES/ofSuppressDefault) o inesistente non ha niente da ripristinare.
procedure TzFbDataSet.SnapshotDefaultExpressions;
var
  Field: TField;
begin
  if not Assigned(FDefaultExpressions) then
    Exit;

  FDefaultExpressions.clear;

  for Field in Fields do
    if not Field.DefaultExpression.IsEmpty then
      FDefaultExpressions.AddOrSetValue(Field.FieldName, Field.DefaultExpression);
end;

// Mantis #153 - 2026-09-21: rimette sui TField le DefaultExpression fotografate
// da SnapshotDefaultExpressions. Ogni ripristino viene registrato: e' la prova
// che qualcuno le aveva azzerate, e dice su quale dataset e su quale campo e'
// successo - informazione che finora mancava del tutto, perche' il difetto si
// vedeva solo molto piu' tardi, come violazione NOT NULL in POST, e su una
// colonna che con la causa non c'entrava niente.
procedure TzFbDataSet.RestoreDefaultExpressions;
var
  Field: TField;
  Atteso: string;
begin
  if not Assigned(FDefaultExpressions) then
    Exit;

  if FDefaultExpressions.Count = 0 then
    Exit;

  // Si rimette il default SOLO dove la proprieta' e' vuota. Un valore diverso
  // ma presente e' una scelta di chi lo ha messo (codice applicativo che
  // assegna una DefaultExpression sua) e non va sovrascritta: qui si tappa un
  // buco, non si impone la copia.
  for Field in Fields do
    if Field.DefaultExpression.IsEmpty then
      if FDefaultExpressions.TryGetValue(Field.FieldName, Atteso) then
      begin
        sizFbDataSet.LogString(Name, 'Default azzerato e ripristinato: ' + Field.FieldName + ' = ' + Atteso);
        Field.DefaultExpression := Atteso;
      end;
end;

procedure TzFbDataSet.UpdateDefaultExpressions;
var
  Field: TField;
  Raw: string;
  i: Integer;
begin
  for Field in self.Fields do
    if Field.DefaultExpression <> '' then
    begin
      // I campi calcolati lato server (COMPUTED BY in Firebird) non hanno
      // una vera DEFAULT: FireDAC eredita l'Expression dai metadati e la
      // propaga via SetColumnAttributes → oCol.Expression, che sovrascrive
      // il valore reale durante il fetch.
      // Mantis 0006163, DefaultExpression su Documenti.Provvisorio sballa il valore
      if IsServerCalcField(Field) then
      begin
        Field.DefaultExpression := '';
        Continue;
      end;

      /// /
      /// /
      Raw := NormalizeDefaultExpression(Field.DefaultExpression);

      // Firebird vuole il punto, mentre win vuole la virgola
      { TODO : FDAC }
      // if Field is TNumericField then
      // Raw := StringReplace(Raw, '.', FormatSettings.DecimalSeparator, []);

      case Field.DataType of
        ftString, ftWideString, ftFixedChar, ftFixedWideChar:
          Field.DefaultExpression := QuotedStr(Raw);
        // Mantis #7054 - 2026-11-02: default testuale dei campi memo fra apici.
        // Senza apici FireDAC compila la DefaultExpression come espressione:
        // DEFAULT 'COLONNA 1' di un BLOB SUB_TYPE TEXT diventava COLONNA 1 e
        // l'apertura falliva con [Stan][Eval]-100 "Column or function [COLONNA]
        // is not found". NULL resta non quotato: ApplyDefaultExpression lo
        // riconosce cosi' e svuota il campo.
        ftMemo, ftWideMemo, ftFmtMemo:
          if SameText(Raw, 'NULL') then
            Field.DefaultExpression := Raw
          else
            Field.DefaultExpression := QuotedStr(Raw);
        ftDate, ftTime, ftDateTime:
          begin
            Raw := Raw.Replace('.', '/', [rfReplaceAll]);

            if IsContextDefault(Raw) then
              Field.DefaultExpression := Raw
            else
              Field.DefaultExpression := QuotedStr(Raw);
          end;
      else
        // ftSingle, ftInteger, e tutti gli altri: valore grezzo non quotato
        Field.DefaultExpression := Raw;
      end;
    end;

  //

  for i := 0 to DefaultValues.Count - 1 do
    if not IsExternalField(DefaultValues.ValueFromIndex[i]) then
    begin
      Field := FindField(DefaultValues.Names[i]);

      // DIV-SAL-4: un campo calcolato dal server non riceve un default (Mantis 0006163)
      if Assigned(Field) and not IsServerCalcField(Field) then
        Field.DefaultExpression := DefaultValues.ValueFromIndex[i];
    end;

  // Mantis #153 - 2026-09-21: qui, in fondo, le DefaultExpression sono complete
  // e definitive: InitFields le ha lette dal dizionario e applicato le
  // soppressioni di OVERRIDES, il ciclo di normalizzazione le ha ripulite e
  // quello qui sopra ha aggiunto i default dichiarati sul dataset
  // (DefaultValues dell'LZ). La copia si prende adesso, e da qui in poi la
  // fonte e' lei.
  SnapshotDefaultExpressions;
end;

function TzFbDataSet.ReopenLocate(const LocateFieldName: string): boolean;
var
  CurrentValue: Variant;
  OldUseSqlLocate: boolean;
begin
  CurrentValue := FieldByName(LocateFieldName).Value;

  ReOpen(true);

  OldUseSqlLocate := UseSqlLocate;
  try
    UseSqlLocate := false;
    Result := Locate(LocateFieldName, CurrentValue, []);
  finally
    UseSqlLocate := OldUseSqlLocate;
  end;
end;

procedure TzFbDataSet.DisableControlsExt;
begin

  if not Active then
    Exit;

  if FControlsExtNesting = 0 then
  begin
    FSavedBlockReadSize := BlockReadSize;
    FSavedDetailDelay := FetchOptions.DetailDelay;
  end;

  inc(FControlsExtNesting);

  // scroll congelato (le griglie non ridisegnano)...
  BlockReadSize := MaxInt; // valore ampio: copre tutti i record del report senza uscire dal block-read

  // i dettagli devono seguire SUBITO il master (niente ritardo)
  FetchOptions.DetailDelay := 0;
end;

procedure TzFbDataSet.EnableControlsExt;
begin
  // Enable senza Disable corrispondente: no-op difensivo
  if FControlsExtNesting = 0 then
    Exit;

  // DIV-PRE-1: il contatore scende anche a dataset chiuso (la chiusura puo' cadere fra la
  // Disable e la Enable) e i valori salvati si rimettono comunque
  Dec(FControlsExtNesting);

  if FControlsExtNesting = 0 then
  begin
    BlockReadSize := FSavedBlockReadSize;
    FetchOptions.DetailDelay := FSavedDetailDelay;
  end;
end;

procedure TzFbDataSet.DoAfterClose;
begin
  sizFbDataSet.EnterMethod(self, 'DoAfterClose');
  inherited;
  sizFbDataSet.LeaveMethod(self, 'DoAfterClose');
end;

function TzFbDataSet.GetAutoIncFields: string;
begin
  Result := UpdateOptions.AutoIncFields;
end;

function TzFbDataSet.LocateNonSQL(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): boolean;
begin
  Result := inherited Locate(AKeyFields, AKeyValues, AOptions);
end;

function TzFbDataSet.RevetNeeded: boolean;
begin
  Result := false;

  if not SameText(SelectSQL.Text, FDefaultSQL.Text) then
    if Trim(FDefaultSQL.Text) <> '' then
      Result := true;
end;

procedure TzFbDataSet.SetAutoIncFields(const Value: string);
begin
  UpdateOptions.AutoIncFields := Value;
end;

procedure TzFbDataSet.SetNewRecordOptions(const Value: TNewRecordOptions);
begin
  FNewRecordOptions.Assign(Value);
end;

procedure TFDAdaptedDataSetHelper.CopyFieldValues(Source: TDataset; DoPost: boolean);
var
  i: Integer;
  s: string;
begin
  if (State in dsEditModes) then
  else
    Append;

  for i := 0 to Source.FieldCount - 1 do
    if not SameText(Source.Fields[i].FieldName, UpdateOptions.KeyFields) then // generatore
      if Assigned(FindField(Source.Fields[i].FieldName)) then
      begin
        s := Source.Fields[i].FieldName;
        if (not Source.Fields[i].IsNull) then
          try
            // valutare se mandarlo su SetFieldValue
            FieldByName(Source.Fields[i].FieldName).Value := Source.Fields[i].Value;
          except
          end;
      end;

  if DoPost then
    checkBrowseMode;
end;

procedure TFDAdaptedDataSetHelper.ClearFields(FieldsToClear: string);
var
  i: Integer;
  Str: TStringList;
begin
  if Trim(FieldsToClear) = '' then
    Exit;

  CheckEditMode;

  Str := TStringList.Create;
  try
    Str.Delimiter := ';';
    Str.DelimitedText := FieldsToClear;

    for i := 0 to Str.Count - 1 do
      if Str[i] <> '' then
        ClearFieldValue(Str[i]);
  finally
    FreeAndNil(Str);
  end;
end;

procedure TFDAdaptedDataSetHelper.ClearFieldValue(const FieldName: string);
var
  Field: TField;
begin
  Field := FindField(FieldName);

  if Assigned(Field) then
    ClearFieldValue(Field);
end;

procedure TFDAdaptedDataSetHelper.ClearFieldValue(Field: TField);
var
  WasReadOnly: boolean;
begin
  // WasReadOnly := Field.ReadOnly;
  // Field.ReadOnly := false;
  // Field.clear;
  // Field.ReadOnly := WasReadOnly;

  SetFieldValue(Field, Null);
end;

procedure TFDAdaptedDataSetHelper.SetFieldValue(const FieldName: string; Value: Variant);
var
  Field: TField;
begin
  Field := FieldByName(FieldName);
  SetFieldValue(Field, Value);
end;

procedure TFDAdaptedDataSetHelper.SetFieldValue(Field: TField; Value: Variant);

  procedure SetCheckReadOnly(const CheckReadOnly: boolean);
  begin

    if UpdateOptions.CheckReadOnly <> CheckReadOnly then
      UpdateOptions.CheckReadOnly := CheckReadOnly;
  end;

var
  WasCheckReadOnly: boolean;
begin
  WasCheckReadOnly := UpdateOptions.CheckReadOnly;
  SetCheckReadOnly(false);

  CheckEditMode; // TcxDBDataProvider.Freeze; chiama cancel in certi casi

  if VarIsNull(Value) then
    Field.clear
  else
    Field.Value := Value;

  SetCheckReadOnly(WasCheckReadOnly);
end;

function TzFbDataSet.CanInsert: boolean;
begin
  Result := UpdateOptions.EnableInsert;
end;

function TzFbDataSet.CanUpdate: boolean;
begin
  Result := UpdateOptions.EnableUpdate;
end;

function TzFbDataSet.CanDelete: boolean;
begin
  Result := UpdateOptions.EnableDelete;
end;

procedure TzFbDataSet.LoadParamsFromMaster;
begin
  if Assigned(DataSource) and Assigned(DataSource.DataSet) and (DataSource.DataSet is TzFbDataSet) then
    ParamsChangedByLoadParamsFromMaster := CopyParams(DataSource.DataSet as TzFbDataSet, true);
end;

function TzFbDataSet.CopyParams(Master: TzFbDataSet; const OverrideParamValues: boolean): boolean;
var
  i: Integer;
  OldValue: Variant;
begin
  Result := false;

  if not Assigned(Master) then
    Exit;

  for i := 0 to ParamCount - 1 do
    if Params[i].ParamType in [ptInput, ptInputOutput] then
    begin
      OldValue := Params[i].Value;

      if Params[i].IsNull or OverrideParamValues then
      begin
        if Master.ParamExists(Params[i].Name) then
          Params[i].Value := Master.ParamByName(Params[i].Name).Value
        else
          if Master.FieldExists(Params[i].Name) then
            Params[i].Value := Master.FieldByName(Params[i].Name).Value;

        if not FDSameVariants(OldValue, Params[i].Value) then
          Result := true;
      end;
    end;
end;

procedure TzFbDataSet.DumpDefaultExpressions;
var
  Field: TField;
begin

  for Field in Fields do
    if not Field.DefaultExpression.IsEmpty then
      sizFbDataSet.LogString(Field.FieldName, Field.DefaultExpression);
end;

procedure TzFbDataSet.InvalidateFieldOrigins;
begin

  if Assigned(FFieldOrigins) then
    FFieldOrigins.clear;
end;

/// ////////////////////////////////////////////////////////////////////////////

type
  { A custom variant type that implements the mapping from the property names
    to the DataSet fields. }
  TVarDataRecordType = class(TInvokeableVariantType)
  public
    procedure clear(var V: TVarData); override;
    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: boolean); override;
    function GetProperty(var Dest: TVarData; const V: TVarData; const Name: string): boolean; override;
    function SetProperty(const V: TVarData; const Name: string; const Value: TVarData): boolean; override;
  end;

type
  { Our layout of the variants record data.
    We only hold a pointer to the DataSet. }
  TVarDataRecordData = packed record
    VType: TVarType;
    Reserved1, Reserved2, Reserved3: Word;
    DataSet: TDataset;
    Reserved4: LongInt;
  end;

var
  { The global instance of the custom variant type. The data of the custom
    variant is stored in a TVarData record, but the methods and properties
    are implemented in this class instance. }
  VarDataRecordType: TVarDataRecordType = nil;

  { A global function the get our custom VarType value. This may vary and thus
    is determined at runtime. }
function VarDataRecord: TVarType;
begin
  Result := VarDataRecordType.VarType;
end;

{ A global function that fills the VarData fields with the correct values. }
function VarDataRecordCreate(ADataSet: TDataset): Variant;
begin
  VarClear(Result);
  TVarDataRecordData(Result).VType := VarDataRecord;
  TVarDataRecordData(Result).DataSet := ADataSet;
end;

procedure TVarDataRecordType.clear(var V: TVarData);
begin
  { No fancy things to do here, we are only holding a pointer to a TDataSet and
    we are not supposed to destroy it here. }
  SimplisticClear(V);
end;

procedure TVarDataRecordType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: boolean);
begin
  { No fancy things to do here, we are only holding a pointer to a TDataSet and
    that can simply be copied here. }
  SimplisticCopy(Dest, Source, Indirect);
end;

function TVarDataRecordType.GetProperty(var Dest: TVarData; const V: TVarData; const Name: string): boolean;
var
  fld: TField;
begin
  { Find a field with the property's name. If there is one, return its current value. }
  fld := TVarDataRecordData(V).DataSet.FindField(Name);
  Result := (fld <> nil);
  if Result then
    Variant(Dest) := fld.Value;
end;

function TVarDataRecordType.SetProperty(const V: TVarData; const Name: string; const Value: TVarData): boolean;
var
  fld: TField;
begin
  { Find a field with the property's name. If there is one, set its value. }
  fld := TVarDataRecordData(V).DataSet.FindField(Name);
  Result := (fld <> nil);
  if Result then
  begin
    { Well, we have to be in Edit mode to do this, don't we? }
    TVarDataRecordData(V).DataSet.edit;
    fld.Value := Variant(Value);
  end;
end;

constructor TDataSetEnumerator.Create(ADataSet: TDataset);
{ The enumerator is automatically created and destroyed in the for-in loop.
  So we remember the active state and set a flag that the first MoveNext will
  not move to the next record, but stays on the first one instead. }
begin
  inherited Create;
  FDataSet := ADataSet;
  assert(FDataSet <> nil);
  { save the Active state }
  FWasActive := FDataSet.Active;
  { avoid flickering }
  FDataSet.DisableControls;
  if FWasActive then
  begin
    { get a bookmark of the current position - even if it is invalid }
    FBookmark := FDataSet.GetBookmark;
    FDataSet.First;
  end
  else
  begin
    { FBookmark is initialized to nil anyway, so no need to set it here }
    FDataSet.Active := true;
  end;
  FMoveToFirst := true;
end;

destructor TDataSetEnumerator.Destroy;
{ Restore the DataSet to its previous state. }
begin
  if FWasActive then
  begin
    { if we have a valid bookmark, use it }
    if FDataSet.BookmarkValid(FBookmark) then
      FDataSet.GotoBookmark(FBookmark);
    { I'm not sure, if FreeBokmark can handle nil pointers - so to be safe }
    if FBookmark <> nil then
      FDataSet.FreeBookmark(FBookmark);
  end
  else
    FDataSet.Active := false;
  { don't forget this one! }
  FDataSet.EnableControls;
  inherited;
end;

function TDataSetEnumerator.GetCurrent: Variant;
begin
  { We simply return the CurrentRec property of the DataSet, which is exposed
    due to the class helper. }
  Result := FDataSet.CurrentRec;
end;

function TDataSetEnumerator.MoveNext: boolean;
begin
  { Check if we have to move to the first record, which has been done already
    during Create. }
  if FMoveToFirst then
    FMoveToFirst := false
  else
    FDataSet.Next;
  Result := not FDataSet.EOF;
end;

function TDataSetHelper.CreateCalculatedField(aFieldClass: TFieldClass; const aFieldName: string; aSize: Integer): TField;
begin
  Result := FindField(aFieldName);
  if Assigned(Result) then
    Exit;

  Result := aFieldClass.Create(self);
  Result.Name := self.Name + aFieldName;
  Result.FieldName := aFieldName;
  Result.FieldKind := fkCalculated;
  Result.Size := aSize;
  Result.DataSet := self;
end;

procedure TDataSetHelper.ForEach(proc: TProc<boolean>);
var
  Stop: boolean;
begin
  if not Assigned(proc) then
    Exit;

  Stop := false;

  self.First;
  while not self.EOF do
  begin
    proc(Stop);

    if Stop then
      Break;

    self.Next;
  end;
end;

function TDataSetHelper.GetCurrentRec: Variant;
begin
  { return one of our custom variants }
  Result := VarDataRecordCreate(self);
end;

function TDataSetHelper.GetEnumerator: TDataSetEnumerator;
begin
  { return a new enumerator }
  Result := TDataSetEnumerator.Create(self);
end;

function TzFbDataSet.OID: Int64;
var
  Field: TField;
  NomeCampoOID: string;
begin
  Result := 0;

  if IsEmpty then
    Exit;

  NomeCampoOID := FFieldNameOID;

  if NomeCampoOID = '' then
    // Mantis #74 - 2026-09-03: fallback sulla chiave primaria stabile (FPrimaryKey,
    // fissata da SetPrimaryKeyFields quando i metadati LZ / il generatore la
    // assegnano), non su UpdateOptions.KeyFields che puo' essere transitoriamente
    // vuoto. Con chiave composta si usa solo il primo campo: l'OID resta singolo.
    NomeCampoOID := FirstPrimaryKeyField;

  if NomeCampoOID = '' then
    Exit;

  Field := FindField(NomeCampoOID);
  if Assigned(Field) and not Field.IsNull then
    Result := Field.AsLargeInt;
end;

initialization

{ Create our custom variant type, which will be registered automatically. }
VarDataRecordType := TVarDataRecordType.Create;

sizFbDataSet := Si.AddSession('zFbDataSet', true);
sizFbDataSet.color := clMoneyGreen;

siRed := Si.AddSession('sizFbDataSet - Red', true);
siRed.color := clRed;

finalization

{ Free our custom variant type. }
FreeAndNil(VarDataRecordType);

sizFbDataSet := nil;
siRed := nil;

end.
