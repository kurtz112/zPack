unit zz.Signals;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Variants,
  Data.DB;

type
  { Forward Declarations }
  ISignalBase = interface;

  { Procedural Types }
  // TSignalEffect = TProc;
  // TOutputHandler<T> = TProc<T>;
  TSignalEffect = reference to procedure;
  TOutputHandler<T> = reference to procedure(const Value: T);

  { 1. Base Interface }
  ISignalBase = interface
    ['{ABC12345-6789-4DEF-A1B2-C3D4E5F6A7B8}']
    procedure Subscribe(AEffect: TSignalEffect);
    procedure Notify;
    procedure PerformNotify;
  end;

  { 2. Signal Interface (Read/Write) }
  ISignal<T> = interface(ISignalBase)
    ['{F1D2B3C4-E5F6-4A7B-8C9D-0E1F2A3B4C5D}']
    function GetValue: T;
    procedure SetValue(const Value: T);
    function HasError: Boolean;
    function GetErrorMessage: string;
    property Value: T read GetValue write SetValue;
  end;

  { 3. Output Interface (Events) }
  IOutput<T> = interface
    ['{0048279B-49C5-4BC9-93DF-39DBAAB90622}']
    procedure Emit(const Value: T);
    procedure Subscribe(AHandler: TOutputHandler<T>);
  end;

  { 4. Model Interface (Two-Way) }
  IModel<T> = interface(ISignal<T>)
    ['{5805F4FF-196A-48CB-BD65-81DF41BCDCC3}']
    function OnChange: IOutput<T>;
  end;

  { Internal Result Container for Error States }
  TResult<T> = record
    Value: T;
    Error: Exception;
    HasError: Boolean;
  end;

  { Base Implementation with Batch Logic }
  TSignalBaseImpl = class(TInterfacedObject, ISignalBase)
  private
    class var FBatchLevel: Integer;
    class var FPendingNotifications: TList<TSignalBaseImpl>;
  protected
    FEffects: TList<TSignalEffect>;
    procedure Notify; virtual;
    procedure PerformNotify; virtual;
    procedure Subscribe(AEffect: TSignalEffect);
  public
    class constructor Create;
    class destructor Destroy;
    constructor Create;
    destructor Destroy; override;
  end;

  { Standard Signal Implementation }
  TSignalImpl<T> = class(TSignalBaseImpl, ISignal<T>)
  protected
    FResult: TResult<T>;
    function GetValue: T; virtual;
    procedure SetValue(const Value: T); virtual;
    function HasError: Boolean;
    function GetErrorMessage: string;
  public
    constructor Create(const InitialValue: T);
  end;

  { Model Implementation }
  TModelImpl<T> = class(TSignalImpl<T>, IModel<T>)
  private
    FOutput: IOutput<T>;
  public
    constructor Create(const InitialValue: T);
    function OnChange: IOutput<T>;
    procedure SetValue(const Value: T); override;
  end;

  { Output Implementation }
  TOutputImpl<T> = class(TInterfacedObject, IOutput<T>)
  private
    FHandlers: TList<TOutputHandler<T>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Emit(const Value: T);
    procedure Subscribe(AHandler: TOutputHandler<T>);
  end;

  { Lazy Computed Implementation }
  TComputedImpl<T> = class(TSignalImpl<T>)
  private
    FFunc: TFunc<T>;
    FIsDirty: Boolean;
  protected
    function GetValue: T; override;
  public
    constructor Create(const AFunc: TFunc<T>; const ADependencies: array of ISignalBase);
  end;

  { --- Factory Functions (Angular-like API) --- }
  TReactive = record
    class function Signal<T>(const InitialValue: T): ISignal<T>; static;
    class function Computed<T>(const AFunc: TFunc<T>; const ADependencies: array of ISignalBase): ISignal<T>; static;
    class function Model<T>(const InitialValue: T): IModel<T>; static;
    class function Output<T>: IOutput<T>; static;
    class function ToSignal(ADataSet: TDataSet; const AFieldName: string): IModel<Variant>; static;

    { Global Reative Tools }
    class procedure Effect(const ADependencies: array of ISignalBase; const AProc: TSignalEffect); static;
    class procedure ExecuteBatch(AProc: TProc); static;
  end;

implementation

type

  { FireDAC Bridge Implementation }
  TDataSetSignalBridge = class(TModelImpl<Variant>)
  private
    FDataSet: TDataSet;
    FFieldName: string;
    FUpdating: Boolean;
    procedure InternalOnScroll(DataSet: TDataSet);
  public
    constructor Create(ADataSet: TDataSet; const AFieldName: string);
    procedure SetValue(const Value: Variant); override;
  end;

  { --- Global Procedures Implementation --- }

class function TReactive.Signal<T>(const InitialValue: T): ISignal<T>;
begin
  Result := TSignalImpl<T>.Create(InitialValue);
end;

class function TReactive.Computed<T>(const AFunc: TFunc<T>; const ADependencies: array of ISignalBase): ISignal<T>;
begin
  Result := TComputedImpl<T>.Create(AFunc, ADependencies);
end;

class function TReactive.Model<T>(const InitialValue: T): IModel<T>;
begin
  Result := TModelImpl<T>.Create(InitialValue);
end;

class function TReactive.Output<T>: IOutput<T>;
begin
  Result := TOutputImpl<T>.Create;
end;

class function TReactive.ToSignal(ADataSet: TDataSet; const AFieldName: string): IModel<Variant>;
begin
  Result := TDataSetSignalBridge.Create(ADataSet, AFieldName);
end;

class procedure TReactive.Effect(const ADependencies: array of ISignalBase; const AProc: TSignalEffect);
var
  Dep: ISignalBase;
begin
  AProc(); // Initial run
  for Dep in ADependencies do
    Dep.Subscribe(AProc);
end;

class procedure TReactive.ExecuteBatch(AProc: TProc);
begin
  TSignalBaseImpl.FBatchLevel := TSignalBaseImpl.FBatchLevel + 1;
  try
    AProc();
  finally
    TSignalBaseImpl.FBatchLevel := TSignalBaseImpl.FBatchLevel - 1;
    if TSignalBaseImpl.FBatchLevel = 0 then
    begin
      var
      UniqueList := TList<TSignalBaseImpl>.Create;
      try
        for var Sig in TSignalBaseImpl.FPendingNotifications do
          if not UniqueList.Contains(Sig) then
            UniqueList.Add(Sig);
        TSignalBaseImpl.FPendingNotifications.Clear;
        for var Sig in UniqueList do
          Sig.PerformNotify;
      finally
        UniqueList.Free;
      end;
    end;
  end;
end;

{ --- Class Implementations --- }

{ TSignalBaseImpl }
class constructor TSignalBaseImpl.Create;
begin
  FBatchLevel := 0;
  FPendingNotifications := TList<TSignalBaseImpl>.Create;
end;

class destructor TSignalBaseImpl.Destroy;
begin
  FPendingNotifications.Free;
end;

constructor TSignalBaseImpl.Create;
begin
  inherited Create;
  FEffects := TList<TSignalEffect>.Create;
end;

destructor TSignalBaseImpl.Destroy;
begin
  FEffects.Free;
  inherited;
end;

procedure TSignalBaseImpl.Notify;
begin
  if FBatchLevel > 0 then
    FPendingNotifications.Add(Self)
  else
    PerformNotify;
end;

procedure TSignalBaseImpl.PerformNotify;
begin
  for var EffectProc in FEffects do
    EffectProc();
end;

procedure TSignalBaseImpl.Subscribe(AEffect: TSignalEffect);
begin
  FEffects.Add(AEffect);
end;

{ TSignalImpl<T> }
constructor TSignalImpl<T>.Create(const InitialValue: T);
begin
  inherited Create;
  FResult.Value := InitialValue;
  FResult.HasError := False;
end;

function TSignalImpl<T>.GetValue: T;
begin
  if FResult.HasError then
    raise FResult.Error;
  Result := FResult.Value;
end;

procedure TSignalImpl<T>.SetValue(const Value: T);
begin
  if not TComparer<T>.Default.Compare(FResult.Value, Value) = 0 then
  begin
    FResult.Value := Value;
    FResult.HasError := False;
    Notify;
  end;
end;

function TSignalImpl<T>.HasError: Boolean;
begin
  Result := FResult.HasError;
end;

function TSignalImpl<T>.GetErrorMessage: string;
begin
  if FResult.HasError then
    Result := FResult.Error.Message
  else
    Result := '';
end;

{ TComputedImpl<T> }
constructor TComputedImpl<T>.Create(const AFunc: TFunc<T>; const ADependencies: array of ISignalBase);
begin
  inherited Create(Default (T));
  FFunc := AFunc;
  FIsDirty := True;
  for var Dep in ADependencies do
    Dep.Subscribe(
      procedure
      begin
        FIsDirty := True;
        Notify;
      end);
end;

function TComputedImpl<T>.GetValue: T;
begin
  if FIsDirty then
  begin
    try
      FResult.Value := FFunc();
      FResult.HasError := False;
    except
      on E: Exception do
      begin
        FResult.Error := E;
        FResult.HasError := True;
      end;
    end;
    FIsDirty := False;
  end;
  Result := inherited GetValue;
end;

{ TOutputImpl<T> }
constructor TOutputImpl<T>.Create;
begin
  inherited Create;
  FHandlers := TList < TOutputHandler < T >>.Create;
end;

destructor TOutputImpl<T>.Destroy;
begin
  FHandlers.Free;
  inherited;
end;

procedure TOutputImpl<T>.Emit(const Value: T);
begin
  for var Handler in FHandlers do
    Handler(Value);
end;

procedure TOutputImpl<T>.Subscribe(AHandler: TOutputHandler<T>);
begin
  FHandlers.Add(AHandler);
end;

{ TModelImpl<T> }
constructor TModelImpl<T>.Create(const InitialValue: T);
begin
  inherited Create(InitialValue);
  FOutput := TOutputImpl<T>.Create;
end;

function TModelImpl<T>.OnChange: IOutput<T>;
begin
  Result := FOutput;
end;

procedure TModelImpl<T>.SetValue(const Value: T);
begin
  if not TComparer<T>.Default.Compare(FResult.Value, Value) = 0 then
  begin
    inherited SetValue(Value);
    FOutput.Emit(Value);
  end;
end;

{ TDataSetSignalBridge }
constructor TDataSetSignalBridge.Create(ADataSet: TDataSet; const AFieldName: string);
begin
  inherited Create(ADataSet.FieldByName(AFieldName).AsVariant);
  FDataSet := ADataSet;
  FFieldName := AFieldName;
  FUpdating := False;
  FDataSet.AfterScroll := InternalOnScroll;
end;

procedure TDataSetSignalBridge.InternalOnScroll(DataSet: TDataSet);
begin
  if not FUpdating then
    Self.SetValue(FDataSet.FieldByName(FFieldName).AsVariant);
end;

procedure TDataSetSignalBridge.SetValue(const Value: Variant);
begin
  inherited SetValue(Value);
  if not FUpdating then
  begin
    FUpdating := True;
    try
      if not(FDataSet.State in [dsEdit, dsInsert]) then
        FDataSet.Edit;
      FDataSet.FieldByName(FFieldName).AsVariant := Value;
    finally
      FUpdating := False;
    end;
  end;
end;

end.
