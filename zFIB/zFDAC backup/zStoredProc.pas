unit zStoredProc;

interface

uses
  SysUtils,
  Classes,
  RTTI,
  Types,
  db,
  zSystem,
  zFbDataSet,
  Generics.Collections,
  Generics.Defaults,
  SiAuto,
  SmartInspect;

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
    FStoredProcName: string;
  public
    constructor Create(const aStoredProcName: string; Const Selectable: boolean = false);
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
    FStoredProcName: string;
    FzSystem: TzSystem;
  private
    procedure InternalExecute(const doCommit: boolean);
  private
    //
    function GetInputParamNames: TStringDynArray;
    function GetOutputParamNames: TStringDynArray;
    function GetRealInputParamNames: TStringDynArray;
    function GetRealOutputParamNames: TStringDynArray;
    function InternalGetParamNames(ParamType: TParamType): TStringDynArray;
    function InternalGetRealParamNames(ParamType: TParamType): TStringDynArray;
  private
    function PropertyFromParam(RealParamName: string): string;
    function ParamFromProperty(PropertyName: string): string;
  private
    procedure StreamToVariant(Stream: TMemoryStream; var v: Variant);
    procedure VariantToStream(const v: Variant; Stream: TMemoryStream);
  protected
    procedure AssignInputParams;
    procedure AssignOutputParams;
  public
    StoredProc: TzFbStoredProc;
    procedure CreateInternalStoredProc;
  public
    constructor Create; overload; virtual;
    constructor Create(aTransaction: TzFbTransaction); overload;
    // constructor Create(azSystem: TzSystem; aDataBase: TzFbDatabase; aTransaction: TzFbTransaction); overload;
    //
    destructor Destroy; override;
    function ParamExists(const ParamName: string): boolean;

    procedure ClearParams;
    procedure ClearParam(const RealParamName: string);

    Procedure SetParamValue(const RealParamName: string; value: Variant; IsNull: boolean); overload;
    Procedure SetParamValue(Field: TField); overload;
    Procedure SetParamValue(Const RealParamName: string; Field: TField); overload;

    function GetParamValue(const RealParamName: string): Variant; overload;
    function ParamIsNull(const RealParamName: string): boolean;
    //
    procedure ExecuteAndCommit;
    procedure ExecuteWithoutCommit;

    procedure Next;
    function EOF: boolean;
    //
    property InputParamNames: TStringDynArray read GetInputParamNames;
    property OutputParamNames: TStringDynArray read GetOutputParamNames;
    property RealInputParamNames: TStringDynArray read GetRealInputParamNames;
    property RealOutputParamNames: TStringDynArray read GetRealOutputParamNames;
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
  pFIBProps,
  zMetadata,
  TypInfo,
  Graphics,
  Jpeg,
  pngimage,
  GIFImg,
  zBaseLib,
  Clipbrd,
  Variants,
  FIBQuery,
  ibase;

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
end;

/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{ TzStoredProc }

constructor TzStoredProc.Create;
  function GetStoredProcName: string;
  var
    attr: TCustomAttribute;
  begin
    Result := '';
    for attr in This.GetAttributes do
      if attr is TStoredProcedureAttribute then
        exit(TStoredProcedureAttribute(attr).StoredProcName);
  end;

begin
  inherited;

  FTransaction := nil;
  FDataBase := nil;
  StoredProc := nil;
  zSystem := nil;

  RttiContext := TRttiContext.Create;
  This := RttiContext.GetType(Self.ClassInfo);

  FStoredProcName := GetStoredProcName;

  if Assigned(InitStoredProc) then
    InitStoredProc(Self);
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
  procedure BuildSql;
  var
    SQL: string;
    I, idx: Integer;
    proc: TzMdProcedure;
  begin
    Assert(Assigned(StoredProc));
    Assert(StoredProcName <> '');

    idx := zSystem.MetaData.Procedures.IndexOf(StoredProc.StoredProcName);
    if idx = -1 then
      raise Exception.Create('StoredProc non trovata (cache): ' + StoredProcName);

    proc := zSystem.MetaData.Procedures[idx];
    SQL := 'EXECUTE PROCEDURE ' + proc.Name;

    if proc.ParamsInput.count > 0 then
    begin
      SQL := SQL + '( ';

      for I := 0 to proc.ParamsInput.count - 1 do
      begin
        SQL := SQL + '?' + proc.ParamsInput[I].Name;

        if I < proc.ParamsInput.count - 1 then
          SQL := SQL + ', ';
      end;

      SQL := SQL + ')';

      StoredProc.SQL.Text := SQL;
    end;

    StoredProc.SQL.Text := SQL;
  end;

begin
  Assert(Assigned(DataBase));
  Assert(Assigned(Transaction));
  SiMain.LogString('CreateInternalStoredProc.StoredProcName', StoredProcName);

  if Assigned(StoredProc) then
    exit;

  StoredProc := TzFbStoredProc.Create(nil);
  StoredProc.DataBase := DataBase;
  StoredProc.Transaction := Transaction;
  StoredProc.Options := StoredProc.Options + [qoStartTransaction, qoTrimCharFields];
  StoredProc.StoredProcName := StoredProcName;

  BuildSql;
  StoredProc.Prepare;
end;

procedure TzStoredProc.InternalExecute(const doCommit: boolean);
begin
  CreateInternalStoredProc;

  if doCommit then
    StoredProc.Options := StoredProc.Options + [qoAutoCommit]
  else
    StoredProc.Options := StoredProc.Options - [qoAutoCommit];

  AssignInputParams;

  if DebugHook <> 0 then
    if CtrlKey then
      Clipboard.asText := StoredProc.DebugString;

  try
    StoredProc.ExecProc;
  except
    if DebugHook <> 0 then
      Clipboard.asText := StoredProc.DebugString;
    raise ;
  end;

  AssignOutputParams;
end;

procedure TzStoredProc.ExecuteAndCommit;
begin
  InternalExecute(true);
end;

procedure TzStoredProc.ExecuteWithoutCommit;
begin
  InternalExecute(false);
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
      exit(true);

  for s in GetRealOutputParamNames do
    if SameText(ParamName, s) then
      exit(true);
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
  PropertyName: string;
  RecValue: TValue;
  tv: TValue;
begin
  // SiMain.EnterMethod(lvDebug, Self, 'SetParamValue');

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
            try
              VariantToStream(value, Stream);
              TPicture(Obj).Bitmap.LoadFromStream(Stream);
            finally
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

/// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
procedure TzStoredProc.AssignInputParams;
var
  I: Integer;
  dummy: Integer;
  ParamName: string;
  value: Variant;
  Param: TFIBXSQLVAR;
begin
  SiMain.EnterMethod(lvDebug, Self, 'AssignInputParams');

  for I := 0 to StoredProc.ParamCount - 1 do
    StoredProc.Params[I].Clear;

  for ParamName in RealInputParamNames do
  begin
    dummy := 0;
    if not StoredProc.ParamExist(ParamName, dummy) then
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

      case Param.SQLType of
        // SQL_DATE: Param.AsDate := value;
        SQL_TYPE_DATE:
          Param.AsDate := value;
        SQL_TYPE_TIME:
          Param.AsTime := value;
        SQL_TIMESTAMP:
          Param.AsDateTime := value; // alias di SQL_DATE
      else
        Param.value := value;
      end;
    end;
  end;

  SiMain.LeaveMethod(lvDebug, Self, 'AssignInputParams');
end;

procedure TzStoredProc.AssignOutputParams;
var
  ParamName: string;
  Param: TFIBXSQLVAR;
  Stream: TMemoryStream;
  value: Variant;
begin
  SiMain.EnterMethod(lvDebug, Self, 'AssignOutputParams');

  for ParamName in RealOutputParamNames do
  begin
    // ParamByName fornisce param/field a seconda dei casi
    Param := StoredProc.ParamByName(ParamName);

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
    begin
      if (Param.IsBlob) and (Param.SQLSubtype = 0) then
      begin

        if Param.IsNull then
          value := Null
        else
        begin
          Stream := TMemoryStream.Create;
          try
            Param.SaveToStream(Stream);
            Stream.Position := 0;
            StreamToVariant(Stream, value);
          finally
            FreeAndNil(Stream);
          end;
        end;

        // SiMain.LogValue(ParamName, VarTypeAsText(VarType(value)));
        SetParamValue(ParamName, value, false);
      end
      else
        SetParamValue(ParamName, Param.value, false);
    end;
  end;

  SiMain.LeaveMethod(lvDebug, Self, 'AssignOutputParams');
end;

function TzStoredProc.EOF: boolean;
begin
  Result := true;
  if Assigned(StoredProc) then
    Result := StoredProc.EOF;
end;

function TzStoredProc.PropertyFromParam(RealParamName: string): string;
var
  prop: TRttiProperty;
  attr: TCustomAttribute;
begin
  Result := '';
  for prop in This.GetProperties do
    for attr in prop.GetAttributes do
      if attr is TParamAttribute then
        if SameText(TParamAttribute(attr).ParamName, RealParamName) then
          exit(prop.Name);

  if Result = '' then
    raise Exception.Create('Proprietà non trovata per il parametro ' + RealParamName);
end;

function TzStoredProc.ParamFromProperty(PropertyName: string): string;
var
  prop: TRttiProperty;
  attr: TCustomAttribute;
begin
  Result := '';
  prop := This.GetProperty(PropertyName);

  if Assigned(prop) then
    for attr in prop.GetAttributes do
      if attr is TParamAttribute then
        exit(TParamAttribute(attr).ParamName);

  if Result = '' then
    raise Exception.Create('XParametro non trovato per la proprietà ' + PropertyName);
end;

function TzStoredProc.ParamIsNull(const RealParamName: string): boolean;
var
  dummy: string;
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
            Result := not Assigned(TPicture(Obj).Bitmap);

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
  if Assigned(StoredProc) then
  begin
    StoredProc.Next;
    AssignOutputParams;
  end;
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

zStoredProccodefactory
