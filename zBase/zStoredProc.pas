unit zStoredProc;

interface

uses
  System.SysUtils,
  System.Classes,
  System.RTTI,
  System.Types,
  Data.DB,
  Generics.Collections,
  Generics.Defaults,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  zSystem,
  zFbDataSet,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TParamType = (ptInput, ptOutput);

  TParamAttribute = class(TCustomAttribute)
  private
    FIsBlob: boolean;
    FParamName: string;
    FParamType: TParamType;
  public
    constructor Create(const aParamName: string; const aParamType: TParamType; const aIsBlob: boolean = false);

    property IsBlob: boolean read FIsBlob write FIsBlob;
    property ParamName: string read FParamName write FParamName;
    property ParamType: TParamType read FParamType write FParamType;
  end;

  TStoredProcedureAttribute = class(TCustomAttribute)
  private
    FSelectable: boolean;
    FStoredProcName: string;
  public
    constructor Create(const aStoredProcName: string; Const Selectable: boolean = false);

    // true = la procedura contiene SUSPEND (RDB$PROCEDURE_TYPE = 1) e puo'
    // restituire piu' righe: va letta con Open + Next, non con Execute*
    property Selectable: boolean read FSelectable write FSelectable;
    property StoredProcName: string read FStoredProcName write FStoredProcName;
  end;

  /// //////////////////////////////////////////////////////////////////////////////////////////
  /// //////////////////////////////////////////////////////////////////////////////////////////
  /// //////////////////////////////////////////////////////////////////////////////////////////

  TzStoredProc = class(TPersistent)
  strict private
    RttiContext: TRttiContext;
    This: TRttiType;
  private
    FTransaction: TzFbTransaction;
    FDataBase: TzFbDatabase;
  private
    FCursorMode: boolean;
    FSelectable: boolean;
    FStoredProcName: string;
    FzSystem: TzSystem;
  private
    procedure InternalExecute(const doCommit: boolean);
    procedure AfterExecute(Sender: TObject);
  private
    //
    function GetInputParamNames: TStringDynArray;
    function GetOutputParamNames: TStringDynArray;
    function GetRealInputParamNames: TStringDynArray;
    function GetRealOutputParamNames: TStringDynArray;
    function InternalGetParamNames(ParamType: TParamType): TStringDynArray;
    function InternalGetRealParamNames(ParamType: TParamType): TStringDynArray;
  private
    function GetActive: boolean;
    function PropertyFromParam(RealParamName: string): string;
    function ParamFromProperty(PropertyName: string): string;
  private
    procedure ClearOutputParams;
    procedure StreamToVariant(Stream: TMemoryStream; var v: Variant);
    procedure VariantToStream(const v: Variant; Stream: TMemoryStream);
  protected
    procedure AssignInputParams;
    procedure AssignOutputParams;
  protected
    function CreateStringList: TStringList;
  public
    StoredProc: TFDStoredProc;
  public
    constructor Create; overload; virtual;
    constructor Create(aTransaction: TzFbTransaction); overload;
    // constructor Create(azSystem: TzSystem; aDataBase: TzFbDatabase; aTransaction: TzFbTransaction); overload;
    procedure CreateInternalStoredProc; overload;
    procedure CreateInternalStoredProc(const AsCursor: boolean); overload;
    procedure ApplyInternalStoredProcParams;
    //
    destructor Destroy; override;

    function DebugString: String;

    function ParamExists(const ParamName: string): boolean;

    procedure ClearParams;
    procedure ClearParam(const RealParamName: string);

    Procedure SetParamValue(const RealParamName: string; value: Variant; IsNull: boolean); overload;
    Procedure SetParamValue(Field: TField); overload;
    Procedure SetParamValue(Const RealParamName: string; Field: TField); overload;

    function GetParamValue(const RealParamName: string): Variant; overload;
    function ParamIsNull(const RealParamName: string): boolean;
    //
    // EXECUTE PROCEDURE: una sola riga di ritorno, letta dai Params.
    // Su una procedura selezionabile Firebird si ferma al primo SUSPEND.
    procedure ExecuteAndCommit;
    procedure ExecuteWithoutCommit;

    // SELECT * FROM procedura: apre il cursore e posiziona sulla prima riga.
    // I valori di ritorno arrivano dai Fields e si scorrono con Next.
    // Non esegue il commit: la transazione deve restare aperta per tutta la
    // lettura, il commit spetta al chiamante dopo Close.
    procedure Open;
    procedure Close;

    procedure Next;
    function EOF: boolean;
    //
    property Active: boolean read GetActive;
    property InputParamNames: TStringDynArray read GetInputParamNames;
    property OutputParamNames: TStringDynArray read GetOutputParamNames;
    property RealInputParamNames: TStringDynArray read GetRealInputParamNames;
    property RealOutputParamNames: TStringDynArray read GetRealOutputParamNames;
    // dichiarato dall'attributo TStoredProcedure del wrapper generato
    property Selectable: boolean read FSelectable;
  published
    property DataBase: TzFbDatabase read FDataBase write FDataBase;
    property Transaction: TzFbTransaction read FTransaction write FTransaction;
    property zSystem: TzSystem read FzSystem write FzSystem;
    property StoredProcName: string read FStoredProcName stored false;
  end;

  TzStoredProcClass = class of TzStoredProc;

var
  InitStoredProc: procedure(zStoredProc: TzStoredProc) = nil;

implementation

uses
  System.Variants,
  System.TypInfo,
  System.Diagnostics,
  Vcl.Graphics,
  Vcl.Clipbrd,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg,
  zBaseLib,
  zMetadata,
  zDiagnostica.Log.Perf;

const
  HasValueFlag = '@'; // DO NOT LOCALIZE

  /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  { Attribute }

constructor TParamAttribute.Create(const aParamName: string; const aParamType: TParamType; const aIsBlob: boolean = false);
begin
  inherited Create;
  FParamName := aParamName;
  FParamType := aParamType;
  FIsBlob := aIsBlob;
end;

constructor TStoredProcedureAttribute.Create(const aStoredProcName: string; Const Selectable: boolean = false);
begin
  inherited Create;
  FStoredProcName := aStoredProcName;
  FSelectable := Selectable;
end;

/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{ TzStoredProc }

constructor TzStoredProc.Create;
  function GetStoredProcAttribute: TStoredProcedureAttribute;
  var
    attr: TCustomAttribute;
  begin
    Result := nil;
    for attr in This.GetAttributes do
      if attr is TStoredProcedureAttribute then
        exit(TStoredProcedureAttribute(attr));
  end;

var
  StoredProcAttribute: TStoredProcedureAttribute;
begin
  inherited;

  FTransaction := nil;
  FDataBase := nil;
  StoredProc := nil;
  zSystem := nil;

  FCursorMode := false;

  RttiContext := TRttiContext.Create;
  This := RttiContext.GetType(Self.ClassInfo);

  FStoredProcName := '';
  FSelectable := false;

  StoredProcAttribute := GetStoredProcAttribute;
  if Assigned(StoredProcAttribute) then
  begin
    FStoredProcName := StoredProcAttribute.StoredProcName;
    FSelectable := StoredProcAttribute.Selectable;
  end;

  if Assigned(InitStoredProc) then
    InitStoredProc(Self);
end;

function TzStoredProc.DebugString: String;
begin
  Result := '';

  if Assigned(StoredProc) then
    Result := StoredProc.DebugString(FCursorMode);
end;

destructor TzStoredProc.Destroy;
begin
  FreeAndNil(StoredProc);
  inherited;
end;

constructor TzStoredProc.Create(aTransaction: TzFbTransaction);
begin
  Create;
  Transaction := aTransaction;
end;

// constructor TzStoredProc.Create(azSystem: TzSystem; aDataBase: TzFbDatabase; aTransaction: TzFbTransaction);
// begin
// Create;
// zSystem := azSystem;
// DataBase := aDataBase;
// Transaction := aTransaction;
// end;

procedure TzStoredProc.CreateInternalStoredProc;
begin
  CreateInternalStoredProc(false);
end;

procedure TzStoredProc.CreateInternalStoredProc(const AsCursor: boolean);
begin
  Assert(Assigned(DataBase));
  Assert(Assigned(Transaction));
  SiMain.LogString('CreateInternalStoredProc.StoredProcName', StoredProcName);

  if Assigned(StoredProc) then
  begin
    if StoredProc.Active then
      StoredProc.Close;

    // Con CommandKind = skStoredProc (il default) FireDAC rimanda al primo uso
    // la scelta fra EXECUTE PROCEDURE e SELECT * FROM, e poi la congela nel
    // comando gia' preparato. Riusare la stessa istanza cambiando modo
    // richiede quindi di ripreparare.
    if FCursorMode <> AsCursor then
      StoredProc.Unprepare;

    FCursorMode := AsCursor;

    if not StoredProc.Prepared then
      StoredProc.Prepare;

    AssignInputParams;
    exit;
  end;

  FCursorMode := AsCursor;

  StoredProc := TFDStoredProc.Create(nil);
  StoredProc.Connection := DataBase;
  StoredProc.Transaction := Transaction;
  // StoredProc.AfterExecute := AfterExecute; { TODO : Passaggio a FDAC: Verificare }
  StoredProc.StoredProcName := StoredProcName;
  StoredProc.Prepare;

  AssignInputParams;
end;

function TzStoredProc.CreateStringList: TStringList;
begin
  Result := TStringList.Create;
  Result.TrailingLineBreak := false;
end;

procedure TzStoredProc.InternalExecute(const doCommit: boolean);
  procedure StartTrans;
  begin
    if not Transaction.Active then
      Transaction.StartTransaction;
  end;

  procedure Commit;
  begin
    if Transaction.Active then
      // begin
      if doCommit then
        Transaction.Commit
        // else
        // Transaction.CommitRetaining;
        // end;
  end;

  procedure Rollback;
  begin
    if Transaction.Active then
      // begin
      if doCommit then
        Transaction.Rollback
        // else
        // Transaction.RollbackRetaining;
        // end;
  end;

  procedure CopiaStoredProcSuClipboard;
  begin
    if DebugHook <> 0 then
      if base.IsAdmin then
        if CtrlKey then
        begin
          try
            Clipboard.asText := StoredProc.DebugString(FCursorMode);
          except
          end;
        end;
  end;

var
  Cronometro: TStopwatch;
  Misura: boolean;
begin

  StartTrans;
  try
    CreateInternalStoredProc(false);

    CopiaStoredProcSuClipboard;

    // Misura per la sessione di registrazione attivabile dall'utente.
    Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
    if Misura then
      Cronometro := TStopwatch.StartNew;

    StoredProc.ExecProc;

    if Misura then
      zDiagnostica.Log.Perf.SegnalaOperazione(coStoredProcedure, StoredProcName, Cronometro.ElapsedMilliseconds, StoredProc.DebugString(FCursorMode));

    Commit;
  except
    CopiaStoredProcSuClipboard;

    Rollback;
    raise;
  end;

  // 16/09/2020 spostato in AfterExecute per i blob (invalid blob id)
  // 21.06.2022 Ripristinato { TODO : Passaggio a FDAC: Verificare }
  AssignOutputParams;
end;

procedure TzStoredProc.AfterExecute(Sender: TObject);
begin
  // DIV-SPR-3: NON e' collegato a StoredProc.AfterExecute (vedi
  // CreateInternalStoredProc): i valori di uscita si leggono in InternalExecute
  // e in Open con AssignOutputParams. Resta per un eventuale collegamento futuro.
  // se si utilizza AutoCommit i blob non possono essere letti
  AssignOutputParams;
end;

procedure TzStoredProc.ExecuteAndCommit;
begin
  InternalExecute(True);
end;

procedure TzStoredProc.ExecuteWithoutCommit;
begin
  InternalExecute(false);
end;

procedure TzStoredProc.Open;
var
  Cronometro: TStopwatch;
  Misura: boolean;
begin
  if not Selectable then
  begin
    SiMain.LogSeparator;
    SiMain.LogWarning('Open su una procedura non dichiarata selezionabile:');
    SiMain.LogString('ProcedureName', StoredProcName);
    SiMain.LogSeparator;
  end;

  if not Transaction.Active then
    Transaction.StartTransaction;

  try
    CreateInternalStoredProc(True);

    Misura := zDiagnostica.Log.Perf.RegistrazionePrestazioniAttiva;
    if Misura then
      Cronometro := TStopwatch.StartNew;

    StoredProc.Open;

    if Misura then
      zDiagnostica.Log.Perf.SegnalaOperazione(coStoredProcedure, StoredProcName, Cronometro.ElapsedMilliseconds, StoredProc.DebugString(FCursorMode));
  except
    // nessun rollback: la transazione e' quella del DataModule chiamante e puo'
    // avere gia' lavoro in sospeso, esattamente come in ExecuteWithoutCommit
    Close;
    raise;
  end;

  AssignOutputParams;
end;

procedure TzStoredProc.Close;
begin
  if Assigned(StoredProc) then
    if StoredProc.Active then
      StoredProc.Close;
end;

function TzStoredProc.GetActive: boolean;
begin
  Result := Assigned(StoredProc) and StoredProc.Active;
end;

function TzStoredProc.InternalGetParamNames(ParamType: TParamType): TStringDynArray;
var
  attr: TCustomAttribute;
  prop: TRttiProperty;

  // Result: TStringDynArray;
begin
  Result := nil;

  for prop in This.GetProperties do
  // if prop.IsWritable = Writable then
  begin
    for attr in prop.GetAttributes do
      if attr is TParamAttribute then
        if TParamAttribute(attr).ParamType = ParamType then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := prop.Name;

          Break; // attributi
        end;
  end;
end;

function TzStoredProc.InternalGetRealParamNames(ParamType: TParamType): TStringDynArray;
var
  attr: TCustomAttribute;
  prop: TRttiProperty;
begin
  Result := nil;

  for prop in This.GetProperties do
  // if prop.IsWritable = Writable then
  begin
    for attr in prop.GetAttributes do
      if attr is TParamAttribute then
        if TParamAttribute(attr).ParamType = ParamType then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := TParamAttribute(attr).ParamName;
          Break; // attributi
        end;
  end;
end;

function TzStoredProc.GetInputParamNames: TStringDynArray;
begin
  Result := InternalGetParamNames(ptInput);
end;

function TzStoredProc.GetOutputParamNames: TStringDynArray;
begin
  Result := InternalGetParamNames(ptOutput);
end;

function TzStoredProc.GetRealInputParamNames: TStringDynArray;
begin
  Result := InternalGetRealParamNames(ptInput);
end;

function TzStoredProc.GetRealOutputParamNames: TStringDynArray;
begin
  Result := InternalGetRealParamNames(ptOutput);
end;

function TzStoredProc.ParamExists(const ParamName: string): boolean;
var
  s: string;
begin
  Result := false;

  for s in GetRealInputParamNames do
    if SameText(ParamName, s) then
      exit(True);

  for s in GetRealOutputParamNames do
    if SameText(ParamName, s) then
      exit(True);
end;

/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TzStoredProc.ClearParam(const RealParamName: string);
var
  prop: TRttiProperty;
  fld: TRttiField;
  Rec: TRttiRecordType;
  InternalPropertyName: string;
  Obj: TObject;
  PropertyName: string;
  value: TValue;
begin
  PropertyName := PropertyFromParam(RealParamName);

  if PropertyName = '' then
    exit;

  prop := This.GetProperty(PropertyName);

  if Assigned(prop) then
  begin
    if prop.PropertyType.IsRecord then
    begin
      if not prop.IsWritable then
      begin
        InternalPropertyName := PropertyName + '_internal';
        prop := This.GetProperty(InternalPropertyName);
      end;

      value := prop.GetValue(Self);
      Rec := RttiContext.GetType(prop.GetValue(Self).TypeInfo).AsRecord;

      // IsNull
      fld := Rec.GetField('fHasValue');
      if Assigned(fld) then
        fld.SetValue(value.GetReferenceToRawData, '');
      // Value
      fld := Rec.GetField('fValue');
      if Assigned(fld) then
        case fld.FieldType.TypeKind of
          tkInteger:
            fld.SetValue(value.GetReferenceToRawData, -1);
          tkChar:
            fld.SetValue(value.GetReferenceToRawData, ' ');
          tkFloat:
            fld.SetValue(value.GetReferenceToRawData, 0);
          tkString:
            fld.SetValue(value.GetReferenceToRawData, '');
          tkWChar:
            fld.SetValue(value.GetReferenceToRawData, '');
          tkLString:
            fld.SetValue(value.GetReferenceToRawData, '');
          tkWString:
            fld.SetValue(value.GetReferenceToRawData, '');
          tkVariant:
            fld.SetValue(value.GetReferenceToRawData, nil);
          tkInt64:
            fld.SetValue(value.GetReferenceToRawData, -1);
          tkClass:
            begin
              raise Exception.Create('(ClearParam) Tipo parametro classe non gestito: ' + RealParamName);
            end;
        end;

      prop.SetValue(Self, value);
    end
    else
      if prop.PropertyType.IsInstance then
      begin
        fld := This.GetField('f' + prop.Name);
        Obj := fld.GetValue(Self).AsObject;
        if Obj is TStrings then
          TStrings(Obj).Clear
        else
          if Obj is TPicture then
            TPicture(Obj).Assign(nil);
      end
      else
        raise Exception.Create('(ClearParam) Tipo parametro non gestito: ' + RealParamName);
  end;
end;

procedure TzStoredProc.SetParamValue(const RealParamName: string; value: Variant; IsNull: boolean);
var
  prop: TRttiProperty;
  fld: TRttiField;
  Rec: TRttiRecordType;
  InternalPropertyName: string;
  Obj: TObject;
  Stream: TMemoryStream;
  Immagine: TPicture;
  PropertyName: string;
  RecValue: TValue;
  tv: TValue;
begin
  // SiMain.EnterMethod(Self, 'SetParamValue');

  /// ////////////////////////////////////
  ///
  ///
  ///
  if IsNull then
  begin
    ClearParam(RealParamName);
    exit;
  end;
  ///
  ///
  ///
  PropertyName := PropertyFromParam(RealParamName);

  if PropertyName = '' then
    exit;

  prop := This.GetProperty(PropertyName);

  if Assigned(prop) then
  begin
    if prop.PropertyType.IsRecord then
    begin
      if not prop.IsWritable then
      begin
        InternalPropertyName := PropertyName + '_internal';
        prop := This.GetProperty(InternalPropertyName);
      end;

      RecValue := prop.GetValue(Self);
      Rec := RttiContext.GetType(prop.GetValue(Self).TypeInfo).AsRecord;

      // IsNull
      fld := Rec.GetField('fHasValue');
      if Assigned(fld) then
      begin
        fld.SetValue(RecValue.GetReferenceToRawData, HasValueFlag);
        // SiMain.LogString('pippo', fld.GetValue(RecValue.GetReferenceToRawData).AsString);
      end;
      // Value
      fld := Rec.GetField('fValue');
      if Assigned(fld) then
      begin
        // non fromVariant
        case VarType(value) of
          varDate:
            tv := TValue.From<TDateTime>(value);
          varCurrency:
            tv := TValue.From<Currency>(value);
          varString:
            tv := TValue.From<String>(value);
          varInteger:
            tv := TValue.From<Integer>(value);
          varDouble:
            tv := TValue.From<extended>(value);
          varBoolean:
            tv := TValue.From<boolean>(value);
        else
          tv := TValue.From<Variant>(value);
        end;

        fld.SetValue(RecValue.GetReferenceToRawData, tv);
      end;

      prop.SetValue(Self, RecValue);
    end
    else
      if prop.PropertyType.IsInstance then
      begin
        fld := This.GetField('f' + prop.Name);
        Obj := fld.GetValue(Self).AsObject;
        if Obj is TStrings then
          TStrings(Obj).Text := value
        else
          if Obj is TPicture then
          begin
            Stream := TMemoryStream.Create;
            Immagine := TPicture.Create;
            try
              VariantToStream(value, Stream);
              // Mantis non indicato - 2026-11-01: BMP, PNG e JPEG (DIV-SPR-7); il formato si riconosce dai primi byte
              Immagine.LoadFromStream(Stream);
              // Il resto del wrapper lavora sempre sul Bitmap della proprieta'
              TPicture(Obj).Bitmap.Assign(Immagine.Graphic);
            finally
              FreeAndNil(Immagine);
              FreeAndNil(Stream);
            end;
          end;
      end
      else
      begin
        raise Exception.Create('(SetParamValue) Tipo parametro non gestito: ' + RealParamName);
      end;
  end;
end;

procedure TzStoredProc.SetParamValue(Const RealParamName: string; Field: TField);
begin
  if not Assigned(Field) then
    exit;

  SetParamValue(RealParamName, Field.value, Field.IsNull);
end;

procedure TzStoredProc.SetParamValue(Field: TField);
begin
  if not Assigned(Field) then
    exit;

  SetParamValue(Field.FieldName, Field);
end;

procedure TzStoredProc.ClearParams;
var
  s: string;
begin
  for s in GetRealInputParamNames do
    ClearParam(s);

  for s in GetRealOutputParamNames do
    ClearParam(s);
end;

procedure TzStoredProc.ClearOutputParams;
var
  s: string;
begin
  for s in GetRealOutputParamNames do
    ClearParam(s);
end;

/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
procedure TzStoredProc.ApplyInternalStoredProcParams;
var
  I: Integer;
  Param: TFDParam;
begin
  for I := 0 to StoredProc.ParamCount - 1 do
  begin
    Param := StoredProc.Params[I];
    SetParamValue(Param.Name, Param.value, Param.IsNull);
  end;
end;

procedure TzStoredProc.AssignInputParams;
var
  I: Integer;
  ParamName: string;
  value: Variant;
  Param: TFDParam;
begin
  SiMain.EnterMethod(Self, 'AssignInputParams');

  for I := 0 to StoredProc.ParamCount - 1 do
    StoredProc.Params[I].Clear;

  for ParamName in RealInputParamNames do
  begin
    if not StoredProc.ParamExists(ParamName) then
    begin
      SiMain.LogSeparator;
      SiMain.LogError('Parametro di input non trovato:');
      SiMain.LogString('ProcedureName', StoredProcName);
      SiMain.LogString('ParamName', ParamName);
      SiMain.LogSeparator;
      Continue;
    end;

    if ParamIsNull(ParamName) then
      StoredProc.ParamByName(ParamName).Clear
    else
    begin
      Param := StoredProc.ParamByName(ParamName);
      value := GetParamValue(ParamName);

      if Param.DataType = ftDate then
        Param.AsDate := value
      else
        if Param.DataType = ftTime then
          Param.AsTime := value
        else
          if Param.DataType = ftDateTime then
            Param.AsDateTime := value
          else
            if Param.DataType = ftBoolean then
              Param.AsBoolean := value
            else
              Param.value := value;
    end;
  end;
  SiMain.LeaveMethod(Self, 'AssignInputParams');
end;

procedure TzStoredProc.AssignOutputParams;
var
  DaCursore: boolean;
  Field: TField;
  Param: TFDParam;
  ParamName: string;
begin
  SiMain.EnterMethod(Self, 'AssignOutputParams');
  try
    if not Assigned(StoredProc) then
      exit;

    // Dopo Open (SELECT * FROM procedura) i valori di ritorno stanno nei Fields;
    // dopo ExecProc (EXECUTE PROCEDURE) stanno nei Params. Il modo si riconosce
    // dallo stato del dataset.
    DaCursore := StoredProc.Active;

    // Cursore esaurito: azzera, altrimenti restano i valori della riga precedente
    if DaCursore and StoredProc.EOF then
    begin
      ClearOutputParams;
      exit;
    end;

    for ParamName in RealOutputParamNames do
    begin
      if DaCursore then
      begin
        Field := StoredProc.FindField(ParamName);

        if not Assigned(Field) then
        begin
          SiMain.LogSeparator;
          SiMain.LogError('Colonna di output non trovata:');
          SiMain.LogString('ProcedureName', StoredProcName);
          SiMain.LogString('FieldName', ParamName);
          SiMain.LogSeparator;
          Continue;
        end;

        if Field.IsNull then
          ClearParam(ParamName)
        else
          SetParamValue(ParamName, Field.value, false);
      end
      else
      begin
        // FindParam e non ParamByName: ParamByName solleva quando il nome non
        // esiste, rendendo irraggiungibile la segnalazione qui sotto
        Param := StoredProc.Params.FindParam(ParamName);

        if not Assigned(Param) then
        begin
          SiMain.LogSeparator;
          SiMain.LogError('Parametro di output non trovato:');
          SiMain.LogString('ProcedureName', StoredProcName);
          SiMain.LogString('ParamName', ParamName);
          SiMain.LogSeparator;
          Continue;
        end;

        if Param.IsNull then
          ClearParam(ParamName)
        else
          SetParamValue(ParamName, Param.value, false);
      end;
    end;
  finally
    SiMain.LeaveMethod(Self, 'AssignOutputParams');
  end;
end;

function TzStoredProc.EOF: boolean;
begin
  // Senza cursore aperto non c'e' niente da scorrere: TDataSet.EOF su un
  // dataset mai aperto non e' affidabile e Next solleverebbe 'Dataset not open'
  Result := True;

  if Assigned(StoredProc) then
    if StoredProc.Active then
      Result := StoredProc.EOF;
end;

function TzStoredProc.PropertyFromParam(RealParamName: string): string;
var
  prop: TRttiProperty;
  attr: TCustomAttribute;
begin
  // DIV-SPR-2: scelta voluta. Se la proprieta' manca solleva sempre; in scrittura
  // (ClearParam, SetParamValue, ParamIsNull, GetParamValue) l'errore arriva al
  // chiamante, perche' indica una classe generata fuori allineamento. In ingresso
  // (AssignInputParams, ZFIB-SPR-005) un parametro senza proprieta' si salta con
  // una riga nel registro, per non bloccare una procedura con parametri nuovi.
  // I controlli "if PropertyName = ''" nei chiamanti sono quindi superflui.
  Result := '';
  for prop in This.GetProperties do
    for attr in prop.GetAttributes do
      if attr is TParamAttribute then
        if SameText(TParamAttribute(attr).ParamName, RealParamName) then
          exit(prop.Name);

  if Result = '' then
    raise Exception.Create('Proprieta'' non trovata per il parametro ' + RealParamName);
end;

function TzStoredProc.ParamFromProperty(PropertyName: string): string;
var
  prop: TRttiProperty;
  attr: TCustomAttribute;
begin
  // DIV-SPR-4: non chiamato da nessuno (verificato con find_references), resta
  // come inverso di PropertyFromParam
  Result := '';
  prop := This.GetProperty(PropertyName);

  if Assigned(prop) then
    for attr in prop.GetAttributes do
      if attr is TParamAttribute then
        exit(TParamAttribute(attr).ParamName);

  if Result = '' then
    raise Exception.Create('Parametro non trovato per la proprieta'' ' + PropertyName);
end;

function TzStoredProc.ParamIsNull(const RealParamName: string): boolean;
var
  fld: TRttiField;
  Obj: TObject;
  prop: TRttiProperty;
  PropertyName: string;
  Rec: TRttiRecordType;
  s: string;
  value: TValue;
begin
  Result := false;

  PropertyName := PropertyFromParam(RealParamName);

  if PropertyName = '' then
    exit;

  prop := This.GetProperty(PropertyName);

  if Assigned(prop) then
  begin
    if prop.PropertyType.IsRecord then
    begin
      value := prop.GetValue(Self);
      Rec := RttiContext.GetType(prop.GetValue(Self).TypeInfo).AsRecord;

      // IsNull
      fld := Rec.GetField('fHasValue');
      if Assigned(fld) then
      begin
        // dummy := fld.GetValue(Value.GetReferenceToRawData).AsString;
        // result := dummy = '';
        s := fld.GetValue(value.GetReferenceToRawData).AsString;
        Result := s = '';
      end;
    end
    else
      if prop.PropertyType.IsInstance then
      begin
        fld := This.GetField('f' + prop.Name);
        Obj := fld.GetValue(Self).AsObject;
        if Obj is TStrings then
          Result := TStrings(Obj).Text = ''
        else
          if Obj is TPicture then
            // DIV-SPR-1: Bitmap esiste sempre (la crea la lettura), si guarda il Graphic
            Result := not Assigned(TPicture(Obj).Graphic) or TPicture(Obj).Graphic.Empty;

      end
      else
      begin
        raise Exception.Create('(ParamIsNull) Tipo parametro non gestito: ' + RealParamName);
      end;
  end;
end;

function TzStoredProc.GetParamValue(const RealParamName: string): Variant;
var
  fld: TRttiField;
  Obj: TObject;
  prop: TRttiProperty;
  PropertyName: string;
  Rec: TRttiRecordType;
  Stream: TMemoryStream;
  value: TValue;
begin
  Result := Null;

  if ParamIsNull(RealParamName) then
    exit;

  /// //////////////////////////////////////////////////////////////////////////////////////////
  PropertyName := PropertyFromParam(RealParamName);

  if PropertyName = '' then
    exit;

  prop := This.GetProperty(PropertyName);

  if prop.PropertyType.IsRecord then
  begin
    value := prop.GetValue(Self);
    Rec := RttiContext.GetType(prop.GetValue(Self).TypeInfo).AsRecord;

    // IsNull
    fld := Rec.GetField('fValue');
    if Assigned(fld) then
      Result := fld.GetValue(value.GetReferenceToRawData).AsVariant;
  end
  else
    if prop.PropertyType.IsInstance then
    begin
      fld := This.GetField('f' + prop.Name);
      Obj := fld.GetValue(Self).AsObject;
      if Obj is TStrings then
        Result := TStrings(Obj).Text
      else
        if Obj is TPicture then
        begin
          if Assigned(TPicture(Obj).Bitmap) then
          begin

            Stream := TMemoryStream.Create;
            try
              TPicture(Obj).Bitmap.SaveToStream(Stream);
              StreamToVariant(Stream, Result);
            finally
              FreeAndNil(Stream);
            end;
          end
          else
            Result := Null;
        end;
    end
    else
    begin
      raise Exception.Create('(GetParamValue) Tipo parametro non gestito: ' + RealParamName);
    end;
end;

procedure TzStoredProc.Next;
begin
  if not Assigned(StoredProc) then
    exit;

  // Senza cursore aperto MoveBy solleverebbe 'Dataset not open'
  if not StoredProc.Active then
    exit;

  StoredProc.Next;
  AssignOutputParams;
end;

procedure TzStoredProc.VariantToStream(const v: Variant; Stream: TMemoryStream);
var
  p: Pointer;
begin
  Stream.Position := 0;
  Stream.Size := VarArrayHighBound(v, 1) - VarArrayLowBound(v, 1) + 1;
  p := VarArrayLock(v);
  try
    Stream.Write(p^, Stream.Size);
  finally
    VarArrayUnlock(v);
  end;
  Stream.Position := 0;
end;

procedure TzStoredProc.StreamToVariant(Stream: TMemoryStream; var v: Variant);
var
  p: Pointer;
begin
  v := VarArrayCreate([0, Stream.Size - 1], varByte);
  p := VarArrayLock(v);
  try
    Stream.Position := 0;
    Stream.Read(p^, Stream.Size);
  finally
    VarArrayUnlock(v);
  end;
end;

end.
