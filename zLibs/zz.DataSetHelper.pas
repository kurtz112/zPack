unit zz.DataSetHelper;

interface

// https://www.uweraabe.de/Blog/2017/02/09/dataset-enumerator-reloaded/

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  Data.DB;

type
  TDataSetHelper = class helper for TDataSet
  private type
    TDataSetRecord<T> = class
    private type
      TMapping = class
      private
        Field: TField;
        RTTIContext: TRTTIContext;
        RttiMember: TRttiMember;

        function GetPointer(var Target: T): Pointer;
        function GetFieldValue: TValue;
      public
        constructor Create(AField: TField; ARTTIContext: TRTTIContext; ARttiMember: TRttiMember);
        procedure LoadFromField(var Target: T);
        procedure StoreToField(var Source: T);
      end;

    private
      FDataSet: TDataSet;
      FInstance: T;
      FMappings: TObjectList<TMapping>;
      RTTIContext: TRTTIContext;
      function LoadCurrent: T;
      procedure LoadMappings;
    protected
      procedure Initialize; virtual;
      property Instance: T read FInstance;
    public
      constructor Create(ADataSet: TDataSet); overload;
      constructor Create(ADataSet: TDataSet; const AInstance: T); overload;
      destructor Destroy; override;
      procedure LoadFromCurrent(var Target: T);
      procedure StoreToCurrent(var Source: T);
      property Current: T read LoadCurrent;
    end;

    TDataSetEnumerator<T> = class(TDataSetRecord<T>)
    private
      FBookmark: TBookmark;
      FMoveToFirst: Boolean;
      FWasActive: Boolean;
    protected
      procedure Initialize; override;
    public
      destructor Destroy; override;
      function MoveNext: Boolean;
    end;

    IRecords<T> = interface
      function GetEnumerator: TDataSetEnumerator<T>;
    end;

    TRecords<T> = class(TInterfacedObject, IRecords<T>)
    private
      FDataSet: TDataSet;
    public
      constructor Create(ADataSet: TDataSet);
      function GetEnumerator: TDataSetEnumerator<T>; virtual;
    end;

    TRecordsInstance<T: class> = class(TRecords<T>)
    private
      FInstance: T;
    public
      constructor Create(ADataSet: TDataSet; AInstance: T);
      function GetEnumerator: TDataSetEnumerator<T>; override;
    end;
  public
    //
    procedure LoadCurrent<T: class>(AInstance: T);
    procedure SaveCurrent<T: class>(AInstance: T);
    function Records<T: class>(AInstance: T): IRecords<T>; overload;
  public
    procedure CheckEditMode;
    procedure DeleteAll;
    procedure ForEach(proc: TProc); overload;
    function ForEach(proc: TProc<Boolean>): Boolean; overload;
    function ForEach<T: class>(item: T; proc: TProc): Boolean; overload;
    function ForEach<T: class>(item: T; proc: TProc<Boolean>): Boolean; overload;
    function ForEach<T: class, constructor>(proc: TProc<T>): Boolean; overload;
    function ForEach<T: class, constructor>(proc: TProc<T, Boolean>): Boolean; overload;
  public

  end;

implementation

uses
  System.TypInfo,
  System.Variants,
  FMX.Types,
  zz.Nullable,
  zz.Blob,
  zz.Rtti,
  Data.FmtBcd;

procedure TDataSetHelper.LoadCurrent<T>(AInstance: T);
var
  tmp: TDataSetRecord<T>;
begin
  tmp := TDataSetRecord<T>.Create(Self, AInstance);
  try
    tmp.LoadFromCurrent(AInstance);
  finally
    tmp.Free;
  end;
end;

procedure TDataSetHelper.SaveCurrent<T>(AInstance: T);
var
  tmp: TDataSetRecord<T>;
begin
  tmp := TDataSetRecord<T>.Create(Self, AInstance);
  try
    tmp.StoreToCurrent(AInstance);
  finally
    tmp.Free;
  end;
end;

function TDataSetHelper.Records<T>(AInstance: T): IRecords<T>;
begin
  result := TRecordsInstance<T>.Create(Self, AInstance);
end;

destructor TDataSetHelper.TDataSetEnumerator<T>.Destroy;
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

constructor TDataSetHelper.TDataSetRecord<T>.Create(ADataSet: TDataSet);
begin
  Create(ADataSet, Default (T));
end;

constructor TDataSetHelper.TDataSetRecord<T>.Create(ADataSet: TDataSet; const AInstance: T);
begin
  inherited Create;
  FDataSet := ADataSet;
  FInstance := AInstance;
  Initialize;
end;

destructor TDataSetHelper.TDataSetRecord<T>.Destroy;
begin
  FMappings.Free;
  inherited;
end;

function TDataSetHelper.TDataSetRecord<T>.LoadCurrent: T;
begin
  result := Instance;
  LoadFromCurrent(result);
end;

procedure TDataSetHelper.TDataSetRecord<T>.Initialize;
begin
  LoadMappings;
end;

procedure TDataSetHelper.TDataSetRecord<T>.LoadFromCurrent(var Target: T);
var
  mapping: TMapping;
begin
  for mapping in FMappings do
    mapping.LoadFromField(Target);
end;

procedure TDataSetHelper.TDataSetRecord<T>.LoadMappings;
var
  fld: TField;
  rttyType: TRTTIType;
  RttiMember: TRttiMember;
begin
  FMappings := TObjectList<TMapping>.Create;
  RTTIContext := TRTTIContext.Create;
  rttyType := RTTIContext.GetType(TypeInfo(T));

  if TValue.From<T>(Instance).AsObject = nil then
    raise Exception.Create('No instance provided');

  for fld in FDataSet.Fields do
  begin
    RttiMember := rttyType.GetProperty(fld.FieldName);
    if Assigned(RttiMember) then
      FMappings.Add(TMapping.Create(fld, RTTIContext, RttiMember))
    else
    begin
      RttiMember := rttyType.GetField(fld.FieldName);
      if Assigned(RttiMember) then
        FMappings.Add(TMapping.Create(fld, RTTIContext, RttiMember))
      else
      begin
        RttiMember := rttyType.GetField('F' + fld.FieldName);
        if Assigned(RttiMember) then
          FMappings.Add(TMapping.Create(fld, RTTIContext, RttiMember))
      end;
    end;
  end;
end;

procedure TDataSetHelper.TDataSetRecord<T>.StoreToCurrent(var Source: T);
var
  mapping: TMapping;
begin
  for mapping in FMappings do
    mapping.StoreToField(Source);
end;

procedure TDataSetHelper.TDataSetEnumerator<T>.Initialize;
{ The enumerator is automatically created and destroyed in the for-in loop.
  So we remember the active state and set a flag that the first MoveNext will
  not move to the next record, but stays on the first one instead. }
begin
  { save the Active state }
  FWasActive := FDataSet.Active;
  { avoid flickering }
  FDataSet.DisableControls;
  if FWasActive then
  begin
    { get a bookmark of the Current position - even if it is invalid }
    FBookmark := FDataSet.GetBookmark;
    FDataSet.First;
  end
  else
  begin
    { FBookmark is initialized to nil anyway, so no need to set it here }
    FDataSet.Active := true;
  end;
  FMoveToFirst := true;
  inherited;
end;

function TDataSetHelper.TDataSetEnumerator<T>.MoveNext: Boolean;
begin
  { Check if we have to move to the first record, which has been done already
    during Create. }
  if FMoveToFirst then
    FMoveToFirst := false
  else
    FDataSet.Next;
  result := not FDataSet.EoF;
end;

constructor TDataSetHelper.TRecords<T>.Create(ADataSet: TDataSet);
begin
  inherited Create;
  FDataSet := ADataSet;
end;

function TDataSetHelper.TRecords<T>.GetEnumerator: TDataSetEnumerator<T>;
begin
  result := TDataSetEnumerator<T>.Create(FDataSet);
end;

constructor TDataSetHelper.TDataSetRecord<T>.TMapping.Create(AField: TField; ARTTIContext: TRTTIContext; ARttiMember: TRttiMember);
begin
  inherited Create;
  Field := AField;
  RTTIContext := ARTTIContext;
  RttiMember := ARttiMember;
end;

function TDataSetHelper.TDataSetRecord<T>.TMapping.GetPointer(var Target: T): Pointer;
begin
  result := TValue.From<T>(Target).AsObject;
end;

function TDataSetHelper.TDataSetRecord<T>.TMapping.GetFieldValue: TValue;
var
  Value: Variant;
  variantType: TVarType;
  s: string;
begin
  result := TValue.Empty;

  if Field.isNull then
    Exit
  else
  begin
    Value := Field.Value;

    variantType := varType(Value);

    if VarIsFMTBcd(Value) then
      result := TValue.From<Double>(Field.AsFloat)
    else
      case variantType of
        varDate:
          result := TValue.From<TDateTime>(Value);
        varCurrency:
          result := TValue.From<Currency>(Value);
        varString:
          result := TValue.From<String>(Value);
        varUString:
          result := TValue.From<String>(Value);
        varInteger:
          result := TValue.From<Integer>(Value);
        varDouble:
          result := TValue.From<Double>(Value);
        varBoolean:
          result := TValue.From<Boolean>(Value);
        varSmallint:
          result := TValue.From<Smallint>(Value);
        varSingle:
          result := TValue.From<Single>(Value);
        varShortInt:
          result := TValue.From<ShortInt>(Value);
        varByte:
          result := TValue.From<Byte>(Value);
        varWord:
          result := TValue.From<Word>(Value);
        varUInt32:
          result := TValue.From<LongWord>(Value);
        varInt64:
          result := TValue.From<Int64>(Value);
        varUInt64:
          result := TValue.From<UInt64>(Value);
      else
        if Field is TSQLTimeStampField then // il varType è 271
          result := TValue.From<TDateTime>(Value)
        else
          result := TValue.FromVariant(Value);
      end;
  end;
end;

procedure TDataSetHelper.TDataSetRecord<T>.TMapping.LoadFromField(var Target: T);
var
  Instance: Pointer;
  MemberValue: TValue;
  obj: TObject;
  v: TValue;
begin
  Instance := GetPointer(Target);

  MemberValue := RttiMember.GetValue(Instance);

  if IsNullable(MemberValue.TypeInfo) then
  begin
    v := GetFieldValue;

    MemberValue.SetNullable(v);

    RttiMember.SetValue(Instance, MemberValue);
  end // \Nullable
  else
    if RttiMember.MemberType.IsInstance then
    begin
      obj := RttiMember.GetValue(Instance).AsObject;

      if obj is TCustomBlob then
        TCustomBlob(obj).LoadFromField(Field);
    end // \Blob
    else
      RttiMember.SetValue(Instance, TValue.FromVariant(Field.Value));
end;

procedure TDataSetHelper.TDataSetRecord<T>.TMapping.StoreToField(var Source: T);
var
  Instance: Pointer;
  MemberValue: TValue;
  obj: TObject;
  StreamPersist: IStreamPersist;
  Stream: TStream;
  FileStream: TFileStream;
  v: TValue;
begin

  if Field.ReadOnly then
    Exit;

  Instance := GetPointer(Source);

  MemberValue := RttiMember.GetValue(Instance);

  if IsNullable(MemberValue.TypeInfo) then
  begin
    v := MemberValue.GetNullable;

    if v.IsEmpty then
      Field.Clear
    else
      Field.Value := v.asVariant;
  end // \Nullable
  else
    if RttiMember.MemberType.IsInstance then
    begin
      obj := RttiMember.GetValue(Instance).AsObject;

      if obj is TCustomBlob then
        TCustomBlob(obj).StoreToField(Field);

      // if obj is TStrings then
      // Field.Assign(TStrings(obj))
      // else
      // if Supports(obj, IStreamPersist, StreamPersist) then
      // begin
      // Stream := TMemoryStream.Create;
      // try
      // StreamPersist.SaveToStream(Stream);
      // Stream.Position := 0;
      //
      // if Stream.Size <= 12 then
      // Field.Clear
      // else
      // TBlobField(Field).LoadFromStream(Stream);
      // finally
      // FreeAndNil(Stream);
      // end;
      // end;
    end // \Blob
    else
      Field.Value := RttiMember.GetValue(Instance).asVariant;
end;

constructor TDataSetHelper.TRecordsInstance<T>.Create(ADataSet: TDataSet; AInstance: T);
begin
  inherited Create(ADataSet);
  FInstance := AInstance;
end;

function TDataSetHelper.TRecordsInstance<T>.GetEnumerator: TDataSetEnumerator<T>;
begin
  result := TDataSetEnumerator<T>.Create(FDataSet, FInstance);
end;

procedure TDataSetHelper.CheckEditMode;
begin
  if Active then
    if not(State in dsEditModes) then
      Edit;
end;

procedure TDataSetHelper.DeleteAll;
begin
  Cancel;

  if RecordCount = 0 then
    Exit;

  Last;
  while not BOF do
    Delete;
end;

function TDataSetHelper.ForEach(proc: TProc<Boolean>): Boolean;
var
  Cancel: Boolean;
begin
  Assert(Assigned(proc));

  result := false;

  if not Active then
    Exit;

  DisableControls;
  try
    Cancel := false;

    First;
    while not EoF do
    begin

      proc(Cancel);

      if Cancel then
        Exit(false);

      Next;
    end;

    result := true;
  finally
    EnableControls;
  end;
end;

function TDataSetHelper.ForEach<T>(item: T; proc: TProc<Boolean>): Boolean;
var
  Cancel: Boolean;
begin
  Assert(Assigned(proc));

  result := false;

  if not Active then
    Exit;

  Cancel := false;

  for item in Records<T>(item) do
  begin
    proc(Cancel);

    if Cancel then
      Exit(false);
  end;

  result := true;
end;

procedure TDataSetHelper.ForEach(proc: TProc);
begin
  Assert(Assigned(proc));

  if not Active then
    Exit;

  DisableControls;
  try
    First;
    while not EoF do
    begin
      proc;
      Next;
    end;
  finally
    EnableControls;
  end;
end;

function TDataSetHelper.ForEach<T>(proc: TProc<T>): Boolean;
var
  item: T;
begin
  Assert(Assigned(proc));

  result := false;

  if not Active then
    Exit;

  item := T.Create;
  try
    for item in Records<T>(item) do
      proc(item);

    result := true;
  finally
    FreeAndNil(item);
  end;
end;

function TDataSetHelper.ForEach<T>(item: T; proc: TProc): Boolean;
begin
  Assert(Assigned(proc));

  result := false;

  if not Active then
    Exit;

  for item in Records<T>(item) do
    proc;

  result := true;
end;

function TDataSetHelper.ForEach<T>(proc: TProc<T, Boolean>): Boolean;
var
  item: T;
  Cancel: Boolean;
begin
  Assert(Assigned(proc));

  result := false;

  if not Active then
    Exit;

  item := T.Create;
  try
    Cancel := false;

    for item in Records<T>(item) do
    begin
      proc(item, Cancel);

      if Cancel then
        Exit(false);
    end;

    result := true;
  finally
    FreeAndNil(item);
  end;
end;

end.
