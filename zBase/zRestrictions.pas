unit zRestrictions;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Actions,
  Vcl.Forms,
  FireDAC.Comp.Client,
  zFbDataSet,
  zSystem,
  zRestrictions.Types,
  zRestrictions.Structs;

type
  TRestrictionManager = class;

  IRestriction = interface
    ['{EE24C236-DDBB-4DC2-8820-1DB1350E418B}']
    procedure ApplyRestrictions;
    function GetRestrictionManager: TRestrictionManager;
  end;

  TRestriction = class
  public type
    TRestrictionState = (rsLoaded, rsNew, rsModified, rsDeleted);
  private
    FAccessLevel: TAccessLevel;
    FComponentClass: TzComponentClass;
    FComponentName: string;
    FFormName: string;
    FPolicy: string;
    FState: TRestrictionState;
    function GetIUD: string;
  public
    constructor Create(aPolicy: string; aFormName: string; aComponentName: string; aComponentClass: TzComponentClass; aAccessLevel: TAccessLevel);
    constructor CreateNew(aPolicy: string; aFormName: string; aComponentName: string; aComponentClass: TzComponentClass; aAccessLevel: TAccessLevel);
    procedure Update(aPolicy: string; aFormName: string; aComponentName: string; aComponentClass: TzComponentClass; aAccessLevel: TAccessLevel);
    procedure Deleted;

    property State: TRestrictionState read FState;
    property Policy: string read FPolicy write FPolicy;
    property FormName: string read FFormName;
    property ComponentName: string read FComponentName;
    property ComponentClass: TzComponentClass read FComponentClass;
    property AccessLevel: TAccessLevel read FAccessLevel default alFull;
    property IUD: string read GetIUD;
  end;

  // ZC 01.11.2026: stato originale di un'azione in sola lettura, ripristinato
  // quando la restrizione cade (per esempio dopo Ctrl+F12)
  TActionReadOnlyState = record
    OriginalUpdate: TNotifyEvent;
    OriginalEnabled: Boolean;
  end;

  TRestrictionManager = class(TComponent)
  private
    FActionsReadOnly: TDictionary<TContainedAction, TActionReadOnlyState>;
    FDefaults: TComponentDefaults;
    FForm: TCustomForm;
    FPolicies: TPolicies;
    FRestrictions: TObjectList<TRestriction>;
    FzDataModule: TzDataModule;
    FzSystem: TzSystem;
  private
    function CreateDataSet(const sql: string): TzFbDataSet;
    procedure FreeDataSet(DataSet: TzFbDataSet);
    function FindRestriction(Const Policy, ComponentName: String): TRestriction;
    procedure LoadPolicies;
    procedure SetActionReadOnly(Action: TContainedAction; ReadOnly: boolean);
    procedure ActionReadOnlyUpdate(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent; aSystem: TzSystem; aForm: TCustomForm; aDataModule: TzDataModule); overload;
    destructor Destroy; override;
  public
    function EditRestrictions: boolean;
    function EditComponentRestrictions(Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string): boolean;

    procedure SaveFormComponents(Form: TCustomForm; zDataModule: TzDataModule);
  public
    function GetComponent(ComponentName: String): TPersistent;

    function GetComponentClass(Component: TPersistent): TzComponentClass;
    function GetComponentGroup(Component: TComponent): string;
  public
    procedure AddDefaultLevel(const ComponentName, ComponentGroup: string; AccessLevel: TAccessLevel); overload;
    procedure AddDefaultLevel(Component: TComponent; const ComponentGroup: string; AccessLevel: TAccessLevel); overload;
    procedure AddDefaultLevel(Component: TComponent; AccessLevel: TAccessLevel); overload;

    function GetDefaultAccessLevel(const ComponentName: string; Const DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel): TAccessLevel; overload;
    function GetDefaultAccessLevel(const ComponentName: string; Const Policy: string): TAccessLevel; overload;

    procedure GetPolicyDefaults(const PolicyName: string; out DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel);
  public
    procedure LoadRestrictionNames(RestrictionNames: TStringList);
    procedure LoadRestrictions;
    procedure SaveRestrictions;

    procedure SaveRestriction(Policy: string; ComponentName: string; const ComponentClass: TzComponentClass; AccessLevel: TAccessLevel);
    procedure DeletePolicy(Policy: string);

    procedure ApplyRestrictions;

    function AllowComponent(Component: TComponent): boolean;
  public
    property Defaults: TComponentDefaults read FDefaults;
    property Restrictions: TObjectList<TRestriction> read FRestrictions;
    property Policies: TPolicies read FPolicies;
    property Form: TCustomForm read FForm;
    property zDataModule: TzDataModule read FzDataModule;
    property zSystem: TzSystem read FzSystem;
  end;

implementation

uses
  System.TypInfo, Vcl.StdCtrls, Vcl.ActnList, Vcl.Menus,
  Vcl.ComCtrls, Vcl.Dialogs, SmartInspect.VCL, SmartInspect.VCL.SiAuto,
  zRestrictions.Form, zRestrictions.Component.Form, dxBar, zDbView, zDbCard,
  cxPC, cxSplitter, zBaseLib, FireDAC.Stan.Option;

var
  SiRestrictions: TSiSession;

function dxVisible(const Visible: boolean): TdxBarItemVisible;
begin
  if Visible then
    result := ivAlways
  else
    result := ivNever;
end;

constructor TRestriction.Create(aPolicy: string; aFormName: string; aComponentName: string; aComponentClass: TzComponentClass; aAccessLevel: TAccessLevel);
begin
  inherited Create;
  FState := rsLoaded;

  FPolicy := aPolicy;
  FFormName := aFormName;
  FComponentName := aComponentName;
  FComponentClass := aComponentClass;
  FAccessLevel := aAccessLevel;
end;

constructor TRestriction.CreateNew(aPolicy: string; aFormName: string; aComponentName: string; aComponentClass: TzComponentClass; aAccessLevel: TAccessLevel);
begin
  Create(aPolicy, aFormName, aComponentName, aComponentClass, aAccessLevel);
  FState := rsNew;
end;

procedure TRestriction.Deleted;
begin
  FState := rsDeleted;
end;

function TRestriction.GetIUD: string;
begin
  result := '';

  case State of
    rsLoaded:
      result := '/';
    rsNew:
      result := '+';
    rsModified:
      result := '/';
    rsDeleted:
      result := '-';
  end;
end;

procedure TRestriction.Update(aPolicy: string; aFormName: string; aComponentName: string; aComponentClass: TzComponentClass; aAccessLevel: TAccessLevel);
begin
  // if Policy = aPolicy then
  // if FormName = aFormName then
  // if ComponentName = aComponentName then
  // if Visible = aVisible then
  // if Readonly = aReadOnly then
  // Exit;

  FState := rsModified;
  FPolicy := aPolicy;
  FFormName := aFormName;
  FComponentName := aComponentName;
  FComponentClass := aComponentClass;
  FAccessLevel := aAccessLevel;
end;

constructor TRestrictionManager.Create(aOwner: TComponent; aSystem: TzSystem; aForm: TCustomForm; aDataModule: TzDataModule);
begin
  inherited Create(aOwner);
  Assert(assigned(aSystem));
  Assert(assigned(aForm));

  FForm := aForm;
  FzDataModule := aDataModule;
  FzSystem := aSystem;

  FDefaults := TComponentDefaults.Create(TComponentDefault);
  FRestrictions := TObjectList<TRestriction>.Create;
  FPolicies := TPolicies.Create(TPolicy);
  FActionsReadOnly := TDictionary<TContainedAction, TActionReadOnlyState>.Create;
end;

destructor TRestrictionManager.Destroy;
var
  Action: TContainedAction;
begin
  // le azioni ancora vive riprendono il loro gestore di aggiornamento
  for Action in FActionsReadOnly.Keys.ToArray do
    SetActionReadOnly(Action, False);
  FreeAndNil(FActionsReadOnly);
  FreeAndNil(FDefaults);
  FreeAndNil(FRestrictions);
  FreeAndNil(FPolicies);
  inherited;
end;

procedure TRestrictionManager.SetActionReadOnly(Action: TContainedAction; ReadOnly: boolean);
var
  State: TActionReadOnlyState;
begin
  if ReadOnly then
  begin
    // il gestore di aggiornamento della form puo' riabilitare l'azione:
    // lo si avvolge in uno che la rimette disabilitata dopo di lui
    if not FActionsReadOnly.ContainsKey(Action) then
    begin
      State.OriginalUpdate := Action.OnUpdate;
      State.OriginalEnabled := Action.Enabled;
      FActionsReadOnly.Add(Action, State);
      Action.OnUpdate := ActionReadOnlyUpdate;
      Action.FreeNotification(Self);
    end;
    Action.Enabled := False;
  end
  else
    if FActionsReadOnly.TryGetValue(Action, State) then
    begin
      FActionsReadOnly.Remove(Action);
      Action.RemoveFreeNotification(Self);
      Action.OnUpdate := State.OriginalUpdate;
      Action.Enabled := State.OriginalEnabled;
    end;
end;

procedure TRestrictionManager.ActionReadOnlyUpdate(Sender: TObject);
var
  State: TActionReadOnlyState;
begin
  if FActionsReadOnly.TryGetValue(TContainedAction(Sender), State) then
    if Assigned(State.OriginalUpdate) then
      State.OriginalUpdate(Sender);

  TContainedAction(Sender).Enabled := False;
end;

procedure TRestrictionManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and Assigned(FActionsReadOnly) and (AComponent is TContainedAction) then
    FActionsReadOnly.Remove(TContainedAction(AComponent));
end;

procedure TRestrictionManager.AddDefaultLevel(const ComponentName, ComponentGroup: string; AccessLevel: TAccessLevel);
begin
  Defaults.AddDefault(ComponentName, ComponentGroup, AccessLevel);
end;

procedure TRestrictionManager.AddDefaultLevel(Component: TComponent; const ComponentGroup: string; AccessLevel: TAccessLevel);
begin
  if assigned(Component) then
    AddDefaultLevel(Component.Name, ComponentGroup, AccessLevel);
end;

procedure TRestrictionManager.AddDefaultLevel(Component: TComponent; AccessLevel: TAccessLevel);
begin
  if assigned(Component) then
    AddDefaultLevel(Component.Name, GetComponentClass(Component).Description, AccessLevel);
end;

function TRestrictionManager.AllowComponent(Component: TComponent): boolean;
begin
  result := False;

  if Component.Name = '' then
    Exit(False)
  else
    if Component is TContainedAction then
      Exit(True)
    else
      if Component is TcxTabSheet then
        Exit(True)
      else
        if Component is TcxPageControl then
          Exit(True)
        else
          if Component is TcxSplitter then
            Exit(True)
          else
            // se sono create dinamicamente non vanno impostate
            // occhio con al NOT all'inizio
            if not(assigned(zDataModule) and (zDataModule.BuildGui)) then
            begin
              if Component is TzDbView then
                Exit(True)
              else
                if Component is TzDbCard then
                  Exit(True);
            end;
end;

procedure TRestrictionManager.ApplyRestrictions;
var
  CompMap:    TDictionary<string, TComponent>;
  DataSetMap: TDictionary<string, TzDiagramDataSet>;
  DefaultMap: TDictionary<string, TAccessLevel>;

  DataSet: TzFbDataSet;
  comp: TComponent;
  DiagramDataSet: TzDiagramDataSet;
  ComponentName: string;
  zComponentClass: TzComponentClass;
  DefaultActionAccessLevel, DefaultDataSetAccessLevel, AccessLevel: TAccessLevel;
  PropInfo: PPropInfo;
  I: Integer;

  procedure AddDiagramDataSets(DataSets: TzDiagramDataSets);
  var
    DS: TzDiagramDataSet;
  begin
    for DS in DataSets do
    begin
      DataSetMap.AddOrSetValue(
        UpperCase(zDataModule.Name + '.' + DS.Name), DS);
      if DS.HasDetailDataSets then
        AddDiagramDataSets(DS.DetailDatasets);
    end;
  end;

begin
  SiRestrictions.EnterMethod('TRestrictionManager.ApplyRestrictions');

  // 1. Mappa componenti Form  O(n)
  CompMap := TDictionary<string, TComponent>.Create(Form.ComponentCount + 32);
  DataSetMap := TDictionary<string, TzDiagramDataSet>.Create(32);
  try
    for I := 0 to Form.ComponentCount - 1 do
    begin
      comp := Form.Components[I];
      if comp.Name <> '' then
        CompMap.AddOrSetValue(UpperCase(comp.Name), comp);
    end;

    // 2. Mappa TzDiagramDataSet per ccFormController  O(d)
    if Assigned(zDataModule) then
      AddDiagramDataSets(zDataModule.DataSets);

    // 3. Mappa default  O(d)
    DefaultMap := TDictionary<string, TAccessLevel>.Create(FDefaults.Count + 8);
    try
      for I := 0 to FDefaults.Count - 1 do
        DefaultMap.AddOrSetValue(
          UpperCase(FDefaults.Items[I].ComponentName),
          FDefaults.Items[I].AccessLevel);

      // 4. Query e applicazione
      DataSet := CreateDataSet(
        'SELECT * FROM USR_POLICIES_APPLY_RESTRICTIONS(:APP, :FORM)');
      try
        DataSet.Name := '__RestrictionManager';
        DataSet.ParamByName('APP').AsString  := zSystem.AppName;
        DataSet.ParamByName('FORM').AsString := Form.Name;
        DataSet.DisableControls;
        DataSet.FetchOptions.Unidirectional := True;
        DataSet.FetchOptions.Mode           := fmAll;
        DataSet.Active := True;

        while not DataSet.Eof do
        begin
          DiagramDataSet := nil;
          ComponentName   := DataSet.FieldByName('COMPONENT').AsString;
          zComponentClass := zComponentClass.Parse(
            DataSet.FieldByName('COMPONENT_CLASS').AsString);

          // lookup O(1) invece di FindDataSet lineare
          if zComponentClass = ccFormController then
            DataSetMap.TryGetValue(UpperCase(ComponentName), DiagramDataSet);

          DefaultActionAccessLevel := DefaultActionAccessLevel.Parse(
            DataSet.FieldByName('DEFAULT_ACTION_ACCESS').AsString);
          DefaultDataSetAccessLevel := DefaultDataSetAccessLevel.Parse(
            DataSet.FieldByName('DEFAULT_DATASET_ACCESS').AsString);

          if zSystem.IsAdmin then
            AccessLevel := alFull
          else if DataSet.FieldByName('ACCESS').IsNull then
          begin
            if not DefaultMap.TryGetValue(UpperCase(ComponentName), AccessLevel) then
              case zComponentClass of
                ccAction:         AccessLevel := DefaultActionAccessLevel;
                ccFormController: AccessLevel := DefaultDataSetAccessLevel;
              else
                AccessLevel := alFull;
              end;

            if Assigned(DiagramDataSet) and
               (DiagramDataSet.DefaultAccessLevel = alNone) then
              AccessLevel := alNone;
          end
          else
            AccessLevel := AccessLevel.Parse(
              DataSet.FieldByName('ACCESS').AsString);

          if zComponentClass = ccFormController then
          begin
            if Assigned(DiagramDataSet) then
              DiagramDataSet.ActualAccessLevel := AccessLevel;
          end
          else
          begin
            if CompMap.TryGetValue(UpperCase(ComponentName), comp) then
            begin
              if comp is TzDbView then
              begin
                TzDbView(comp).RestrictionReadOnly := AccessLevel <> alFull;
                TzDbView(comp).Visible             := AccessLevel <> alNone;
              end
              else if comp is TzDbCard then
              begin
                TzDbCard(comp).RestrictionReadOnly := AccessLevel <> alFull;
                TzDbCard(comp).Visible             := AccessLevel <> alNone;
              end
              else if comp is TcxTabSheet then
                TcxTabSheet(comp).TabVisible := AccessLevel <> alNone
              else if comp is TdxBarItem then
              begin
                if not Assigned(TdxBarItem(comp).Action) then
                  TdxBarItem(comp).Visible := dxVisible(AccessLevel <> alNone);
              end
              else
              begin
                PropInfo := GetPropInfo(comp.ClassInfo, 'Visible');
                if PropInfo <> nil then
                  SetOrdProp(comp, PropInfo, Integer(AccessLevel <> alNone));
              end;

              if not (comp is TzDbView) and not (comp is TzDbCard) then
              begin
                PropInfo := GetPropInfo(comp.ClassInfo, 'ReadOnly');
                if PropInfo <> nil then
                  SetOrdProp(comp, PropInfo, Integer(AccessLevel = alRead));
              end;

              // ZC 01.11.2026: le azioni non hanno ReadOnly, la sola lettura le disabilita
              if comp is TContainedAction then
                SetActionReadOnly(TContainedAction(comp), AccessLevel = alRead);
            end;
          end;

          DataSet.Next;
        end;
      finally
        FreeDataSet(DataSet);
      end;
    finally
      FreeAndNil(DefaultMap);
    end;
  finally
    FreeAndNil(DataSetMap);
    FreeAndNil(CompMap);
  end;

  SiRestrictions.LeaveMethod('TRestrictionManager.ApplyRestrictions');
end;

function TRestrictionManager.CreateDataSet(const sql: string): TzFbDataSet;
begin
  result := CreateFbDataSet(nil, zSystem.zFbDatabase, zSystem.zFbTransaction, zSystem.zFbTransaction, True);
  result.AutoCommit := True;
  result.SelectSQL.Text := sql;
  result.Prepare;
end;

procedure TRestrictionManager.FreeDataSet(DataSet: TzFbDataSet);
begin
  DataSet.Active := False;
  FreeAndNil(DataSet);
end;

procedure TRestrictionManager.DeletePolicy(Policy: string);
var
  Restriction: TRestriction;
begin
  for Restriction in Restrictions do
    if SameText(Restriction.Policy, Policy) then
      Restriction.Deleted;
end;

function TRestrictionManager.EditRestrictions: boolean;
begin
  result := zEditRestrictions(Self);
end;

function TRestrictionManager.FindRestriction(Const Policy, ComponentName: String): TRestriction;
begin

  for result in Restrictions do
    if SameText(result.Policy, Policy) then
      if SameText(result.FormName, Form.Name) then
        if SameText(result.ComponentName, ComponentName) then
          Exit;

  // se arriva fin qui non l'ha trovato
  result := nil;
end;

function TRestrictionManager.GetComponent(ComponentName: String): TPersistent;
begin
  result := Form.FindComponent(ComponentName);

  if not assigned(result) then
    if assigned(zDataModule) then
      result := zDataModule.DataSets.FindDataSet(StringReplace(ComponentName, zDataModule.Name + '.', '', [rfIgnoreCase]));
end;

function TRestrictionManager.GetComponentClass(Component: TPersistent): TzComponentClass;
begin
  result := ccUnknown;

  if (Component is TContainedAction) then
    result := ccAction
  else
    if (Component is TzDiagramDataSet) then
      result := ccFormController
    else
      if Component is TcxTabSheet then
        result := ccTabSheet
      else
        if Component is TcxPageControl then
          result := ccTabSheet
        else
          if Component is TzDbView then
            result := ccView
          else
            if Component is TzDbCard then
              result := ccCard
            else
              // if Component is TzTatukViewer then
              // result := ccGisMap
              // else
              if Component is TcxSplitter then
                result := ccUnknown;
end;

function TRestrictionManager.GetComponentGroup(Component: TComponent): string;
begin
  result := '';

  if Defaults.TryGetComponentGroup(Component.Name, result) then
    Exit(result)
  else
    result := GetComponentClass(Component).Description;
end;

function TRestrictionManager.GetDefaultAccessLevel(const ComponentName: string; Const DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel): TAccessLevel;
var
  Component: TPersistent;
  zComponentClass: TzComponentClass;
begin
  result := alNone;

  if Defaults.TryGetAccessLevel(ComponentName, result) then
    Exit(result)
  else
  begin

    Component := GetComponent(ComponentName);
    if not assigned(Component) then
      Exit(alNone);

    zComponentClass := GetComponentClass(Component);

    /// //////////////////////////////////////////////////////

    case zComponentClass of
      ccUnknown:
        result := alFull;
      ccTabSheet:
        result := alFull;
      ccAction:
        result := DefaultActionAccessLevel; // !!!
      ccFormController:
        result := DefaultDataSetAccessLevel;
      ccView:
        result := alFull;
      ccCard:
        result := alFull;
      ccCube:
        result := alFull;
      ccFilePdf:
        result := alFull;
      ccGisMap:
        result := alFull;
    end;
  end;
end;

function TRestrictionManager.GetDefaultAccessLevel(const ComponentName: string; Const Policy: string): TAccessLevel;
var
  DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel;
begin
  GetPolicyDefaults(Policy, DefaultActionAccessLevel, DefaultDataSetAccessLevel);
  result := GetDefaultAccessLevel(ComponentName, DefaultActionAccessLevel, DefaultDataSetAccessLevel);
end;

procedure TRestrictionManager.GetPolicyDefaults(const PolicyName: string; out DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel);
var
  Policy: TPolicy;
begin
  DefaultActionAccessLevel := alNone;
  DefaultDataSetAccessLevel := alNone;

  Policy := Policies.Find(PolicyName);

  if assigned(Policy) then
  begin
    DefaultActionAccessLevel := Policy.DefaultActionAccessLevel;
    DefaultDataSetAccessLevel := Policy.DefaultDataSetAccessLevel;
  end;
end;

procedure TRestrictionManager.LoadPolicies;
var
  DataSet: TzFbDataSet;
  Policy: string;
  DefaultActionAccessLevel, DefaultDataSetAccessLevel: TAccessLevel;
begin
  Policies.Clear;

  DataSet := CreateDataSet('SELECT * FROM USR_POLICIES');
  try
    DataSet.Active := True;

    while not DataSet.Eof do
    begin
      Policy := DataSet.FieldByName('POLICY').AsString;
      DefaultActionAccessLevel := DefaultActionAccessLevel.Parse(DataSet.FieldByName('DEFAULT_ACTION_ACCESS').AsString);
      DefaultDataSetAccessLevel := DefaultDataSetAccessLevel.Parse(DataSet.FieldByName('DEFAULT_DATASET_ACCESS').AsString);

      Policies.AddPolicy(Policy, DefaultActionAccessLevel, DefaultDataSetAccessLevel);
      DataSet.Next;
    end;
  finally
    FreeDataSet(DataSet);
  end;
end;

procedure TRestrictionManager.LoadRestrictionNames(RestrictionNames: TStringList);
var
  DataSet: TzFbDataSet;
begin
  Assert(assigned(RestrictionNames));

  RestrictionNames.Clear;

  DataSet := CreateDataSet('SELECT * FROM USR_POLICIES_GET_POLICY_NAMES');
  try
    DataSet.Active := True;

    while not DataSet.Eof do
    begin
      RestrictionNames.Add(DataSet.FieldByName('POLICY').AsString);
      DataSet.Next;
    end;
  finally
    FreeDataSet(DataSet);
  end;
end;

procedure TRestrictionManager.LoadRestrictions;
var
  DataSet: TzFbDataSet;
  Policy: string;
  FormName: string;
  ComponentName: string;
  DefaultActionAccessLevel, DefaultDataSetAccessLevel, AccessLevel: TAccessLevel;
  RestrictionType: string;
begin
  LoadPolicies;
  Restrictions.Clear;
  FormName := Form.Name;

  DataSet := CreateDataSet('SELECT * FROM USR_POLICIES_LOAD_RESTRICTIONS(:APP, :FORM)');
  try
    DataSet.ParamByName('APP').AsString := zSystem.AppName;
    DataSet.ParamByName('FORM').AsString := FormName;
    DataSet.Active := True;
    while not DataSet.Eof do
    begin
      Policy := DataSet.FieldByName('POLICY').AsString;
      ComponentName := DataSet.FieldByName('COMPONENT').AsString;

      DefaultActionAccessLevel := DefaultActionAccessLevel.Parse(DataSet.FieldByName('DEFAULT_ACTION_ACCESS').AsString);
      DefaultDataSetAccessLevel := DefaultDataSetAccessLevel.Parse(DataSet.FieldByName('DEFAULT_DATASET_ACCESS').AsString);

      if DataSet.FieldByName('ACCESS').IsNull then
        AccessLevel := GetDefaultAccessLevel(ComponentName, DefaultActionAccessLevel, DefaultDataSetAccessLevel)
      else
        AccessLevel := AccessLevel.Parse(DataSet.FieldByName('ACCESS').AsString);

      Restrictions.Add(TRestriction.Create(Policy, FormName, ComponentName, ccUnknown, AccessLevel));
      DataSet.Next;
    end;
  finally
    FreeDataSet(DataSet);
  end;
end;

procedure TRestrictionManager.SaveRestriction(Policy: string; ComponentName: string; const ComponentClass: TzComponentClass; AccessLevel: TAccessLevel);
var
  Restriction: TRestriction;
begin
  // se AccessLevel = zzGetDefault deve andare in delete

  Restriction := FindRestriction(Policy, ComponentName);

  if assigned(Restriction) then
  begin
    // if GetDefaultAccessLevel then
    Restriction.Update(Policy, Form.Name, ComponentName, ComponentClass, AccessLevel)
  end
  else
  begin
    // if GetDefaultAccessLevel then
    // se non trovata l'aggiunge
    Restriction := TRestriction.CreateNew(Policy, Form.Name, ComponentName, ComponentClass, AccessLevel);
    Restrictions.Add(Restriction);
  end;
end;

procedure TRestrictionManager.SaveRestrictions;
  procedure CheckRestrictions;
  var
    Restriction: TRestriction;
    defaultLevel: TAccessLevel;
  begin
    for Restriction in Restrictions do
    begin
      defaultLevel := GetDefaultAccessLevel(Restriction.ComponentName, Restriction.Policy);

      if defaultLevel = Restriction.AccessLevel then
        Restriction.Deleted;
    end;
  end;

var
  sp: TFDStoredProc;
  Restriction: TRestriction;
begin
  // ZZ 02.11.2018: meglio salvare sempre tutto CheckRestrictions;

  sp := CreateStoredProc('USR_POLICIES_SAVE_RESTRICTION');
  try
    // sp.Connection := zSystem.zFbDatabase;
    // sp.Transaction := zSystem.zFbDatabase.UpdateTransaction;
    // sp.UpdateTransaction := zSystem.zFbDatabase.UpdateTransaction;
    //
    // if not assigned(sp.Transaction) then
    // sp.Transaction := zSystem.zFbTransaction;
    //
    // sp.StoredProcName := 'USR_POLICIES_SAVE_RESTRICTION';
    // sp.UpdateTransaction.Options.AutoStart := True;
    // sp.UpdateTransaction.Options.AutoCommit := True;
    sp.Prepare;

    for Restriction in Restrictions do
    begin
      sp.ParamByName('POLICY').AsString := Restriction.Policy;
      sp.ParamByName('APP').AsString := zSystem.AppName;
      sp.ParamByName('FORM').AsString := Restriction.FormName;
      sp.ParamByName('COMPONENT').AsString := Restriction.ComponentName;
      sp.ParamByName('COMPONENT_CLASS').AsString := Restriction.ComponentClass.ToString;

      sp.ParamByName('ACCESS').AsString := Restriction.AccessLevel.ToString;
      sp.ParamByName('IUD').AsString := Restriction.IUD;

      sp.ExecProc;
    end;
  finally
    FreeAndNil(sp);
  end;
end;

function TRestrictionManager.EditComponentRestrictions(Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string): boolean;
var
  sp: TFDStoredProc;
begin
  sp := CreateStoredProc('USR_APPS_FORMS_COMPONENTS_ADD');
  try
    sp.Prepare;
    sp.ParamByName('APP').AsString := zSystem.AppName;
    sp.ParamByName('FORM').AsString := FormName;
    sp.ParamByName('COMPONENT').AsString := ComponentName;
    sp.ParamByName('COMPONENT_CLASS').AsString := ComponentClass.ToString;
    sp.ExecProc;
  finally
    FreeAndNil(sp);
  end;

  result := zEditComponentRestrictions(FormName, ComponentClass, ComponentName);
end;

procedure TRestrictionManager.SaveFormComponents(Form: TCustomForm; zDataModule: TzDataModule);
var
  sp: TFDStoredProc;

  procedure SaveComponent(const ComponentName: string; Obj: TPersistent);
  begin
    sp.ParamByName('COMPONENT').AsString := ComponentName;
    sp.ParamByName('COMPONENT_CLASS').AsString := GetComponentClass(Obj).ToString;
    sp.ExecProc;
  end;

  // ZC 01.11.2026: dataset registrati come Modulo.Dataset, dettagli compresi,
  // come li cercano ApplyRestrictions e l'editor (prima solo il nome)
  procedure SaveDiagramDataSets(DataSets: TzDiagramDataSets);
  var
    zDiagramDataSet: TzDiagramDataSet;
  begin
    for zDiagramDataSet in DataSets do
    begin
      SaveComponent(zDataModule.Name + '.' + zDiagramDataSet.Name, zDiagramDataSet);
      if zDiagramDataSet.HasDetailDataSets then
        SaveDiagramDataSets(zDiagramDataSet.DetailDatasets);
    end;
  end;

  procedure SaveDataModule;
  begin
    if assigned(zDataModule) then
      if zDataModule.BuildGui then // zz 02.11.2018 altrimenti confonde le idee...
        SaveDiagramDataSets(zDataModule.DataSets);
  end;

  procedure SaveForm;
    procedure Enum(owner: TComponent);
    var
      comp: TComponent;
      ComponentClass: TzComponentClass;
      ComponentGroup: string;
      ComponentInfo: TComponentInfo;
    begin
      for comp in owner do
        if AllowComponent(comp) then
          SaveComponent(comp.Name, comp)
        else
          if comp.ComponentCount > 0 then
            Enum(comp);
    end;

  begin
    Enum(Form);
  end;

begin
  if not assigned(Form) then
    Exit;

  StartWait('Attendere...', True);
  try
    sp := CreateStoredProc('USR_APPS_FORMS_COMPONENTS_ADD');
    try
      sp.Prepare;
      sp.ParamByName('APP').AsString := zSystem.AppName;
      sp.ParamByName('FORM').AsString := Form.ClassName;

      SaveForm;
      SaveDataModule;
    finally
      FreeAndNil(sp);
    end;
  finally
    StopWait;
  end;
end;

initialization

SiRestrictions := Si.AddSession('RestrictionManager', True);

finalization

SiRestrictions := nil;

end.zDbView zDbView

zsystem
