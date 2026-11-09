unit zLocalizer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.RTTI,
  System.Actions,
  System.Generics.Defaults,
  System.Generics.Collections,
  Vcl.ActnList,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  zz.GenericCollection,
  zdbView,
  zdbCard,
  zDbPivot,
  zFileViewer,
  // zGoogleMaps,
  zTreeMenu,
  zFormController,
  OkCancel,
  zDx,
  cxPC,
  dxLayoutControl,
  zLocalizer.types;

type
  TzResource = class(TCollectionItem)
  private
    FDefaultValue: string;
    FResourceKind: TResourceKind;
    FNamespace: string;
    FResourceName: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function FullResourceName: string;
  published
    property Namespace: string read FNamespace write FNamespace;
    property ResourceName: string read FResourceName write FResourceName;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property ResourceKind: TResourceKind read FResourceKind write FResourceKind;
  end;

  TzResources = class(TzGenericCollection<TzResource>)
  public const
    FileName = 'Resources';
  protected
    function Compare(Item1, Item2: TzResource): Integer; override;
  public
    constructor Create;

    function GetResource(const Namespace, ResourceName: string): TzResource;
    function GetResourceName(const ClassName, ComponentName, PropertyName: string): string;

    procedure AddResource(const Namespace, ResourceName, DefaultValue: string; const ResourceKind: TResourceKind); overload;
    procedure AddResource(const Namespace, ClassName, ComponentName, PropertyName, DefaultValue: string; const ResourceKind: TResourceKind); overload;

    procedure EnumResourceStrings;
  end;

  TzLanguage = class(TCollectionItem)
  private
    FDeleted: boolean;
    FLanguage: string;
    FDictionary: TDictionary<string, string>;
    FLocaleID: Cardinal;
    FModified: boolean;
    function GetFileName: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function FindTranslation(const ResourceName: string; out Value: string; const Default: string = ''): boolean;
    property Dictionary: TDictionary<string, string> read FDictionary write FDictionary;
  public
    property Modified: boolean read FModified write FModified;
    property Deleted: boolean read FDeleted write FDeleted;
  public
    property FileName: string read GetFileName;

    procedure LoadFromStrings(Strings: TStrings);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToStrings(Strings: TStrings);
    procedure SaveToFile(const FileName: string);
  published
    property Language: string read FLanguage write FLanguage;
    property LocaleID: Cardinal read FLocaleID write FLocaleID;
  end;

  TzLanguages = class(TzGenericCollection<TzLanguage>)
  private
    FActiveLanguage: TzLanguage;
  protected
    procedure Notify(Item: TCollectionItem; Action: System.Classes.TCollectionNotification); override;
  public const
    Ext = '.txt';
  public
    constructor Create;

    function GetLanguage(const Language: string): TzLanguage; overload;
    function GetLanguage(const LocaleID: Cardinal): TzLanguage; overload;

    procedure SetActiveLanguage(const Language: string); overload;
    procedure SetActiveLanguage(const LocaleID: Cardinal); overload;

    property ActiveLanguage: TzLanguage read FActiveLanguage;
  end;

  TzLocalizer = class(TComponent)
  private
    FCurrentLanguage: string;
    FFileExists: boolean;
    FFileName: string;
    FileLoaded: boolean;
    FLanguages: TzLanguages;
    FResources: TzResources;
    Listeners: TList<IzLocalizerListener>;

    procedure SetCurrentLanguage(const Value: string);
    procedure SetLanguages(const Value: TzLanguages);
    procedure SetResources(const Value: TzResources);
  private
    function DefaultLanguage: string;
    procedure AssignDxResources;
    function GetOwnerName(OwnerType: TRttiType; parentType: TRttiType; ComponentName: string): string;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

  public
    function AddNewLanguage: TzLanguage;
    function ChooseLanguage: boolean;
    function EditLocalizations(const Namespace: string; ScrollingWinControl: TScrollingWinControl): boolean;

    procedure LoadFromFile;
    procedure SaveToFile;
  public
    procedure RegisterComponentProps(Component: TComponent; const Namespace: string);
    procedure Translate(Component: TComponent; Namespace: string = ''); overload;
    // procedure Translate(ScrollingWinControl: TScrollingWinControl; const Namespace: string); overload;
    function GetTranslation(const ResStringName: string; const DefaultValue: string): string;
  public
    procedure AddListener(Listener: IzLocalizerListener);
    procedure RemoveListener(Listener: IzLocalizerListener);
    procedure NotifyListeners;
  public
    property CurrentLanguage: string read FCurrentLanguage write SetCurrentLanguage;
    property FileName: string read FFileName write FFileName;
    property FileExists: boolean read FFileExists write FFileExists;

    property Resources: TzResources read FResources write SetResources;
    property Languages: TzLanguages read FLanguages write SetLanguages;
  end;

function Localizer: TzLocalizer;

implementation

uses
  dxCore,
  cxGridDBTableView,
  zLocalizer.utils,
  zLocalizer.form,
  zLocalizer.storage,
  zLocalizer.dx,
  zLocalizer.helper,
  zDbRecordView,
  zDbTree,
  zDbChart,
  zDbScheduler,
  zMsg,
  cxLabel,
  dxRibbon,
  dxBar,
  System.IOUtils,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

var
  __Localizer: TzLocalizer;
  siMain: TSiSession;

function Localizer: TzLocalizer;
begin
  if not Assigned(__Localizer) then
  begin
    __Localizer := TzLocalizer.Create(nil);
    __Localizer.LoadFromFile;
  end;

  result := __Localizer;
end;

constructor TzLocalizer.Create(aOwner: TComponent);
begin
  inherited;
  FileLoaded := False;
  FFileName := ChangeFileExt(Application.ExeName, '.lng'); //
  FFileExists := TFile.Exists(FFileName);

  FCurrentLanguage := DefaultLanguage;
  Listeners := TList<IzLocalizerListener>.Create;
  FResources := TzResources.Create;
  FLanguages := TzLanguages.Create;
end;

function TzLocalizer.DefaultLanguage: string;
begin
  result := LanguageFromLocale(SysLocale.DefaultLCID);
end;

destructor TzLocalizer.Destroy;
begin
  FreeAndNil(Listeners);
  FreeAndNil(FLanguages);
  FreeAndNil(FResources);
  inherited;
end;

procedure TzLocalizer.AddListener(Listener: IzLocalizerListener);
begin
  if Listeners.IndexOf(Listener) = -1 then
    Listeners.Add(Listener);
end;

function TzLocalizer.AddNewLanguage: TzLanguage;
var
  s: string;
  StringList: TStringList;
begin
  result := nil;

  StringList := TStringList.Create;
  try
    EnumLanguages(StringList);

    s := '';
    if not InputCombo('Lingua', 'Lingua', s, StringList) then
      Exit;
  finally
    FreeAndNil(StringList);
  end;

  /// /////////////

  if Languages.get(
    function(Item: TzLanguage): boolean
    begin
      result := SameText(s, Item.Language);
    end, False) <> nil then
    Exit;

  result := Languages.Add;
  result.Language := s;
  result.LocaleID := LocaleFromLanguage(s);
end;

procedure TzLocalizer.AssignDxResources;
var
  r: TzResource;
begin

  for r in Resources do
    if r.ResourceKind = rkDX then
      zDxSetResourceString(r.ResourceName, r.DefaultValue);
end;

function TzLocalizer.ChooseLanguage: boolean;
var
  Language: TzLanguage;
  StringList: TStringList;
  s: string;
begin
  result := False;

  StringList := TStringList.Create;
  try
    for Language in Languages do
      StringList.Add(Language.Language);

    s := CurrentLanguage;

    if InputCombo('Lingua', 'Lingua', s, StringList, nil, False, False) then
    begin
      CurrentLanguage := s; // save
      result := True;
    end;
  finally
    FreeAndNil(StringList);
  end;
end;

function TzLocalizer.EditLocalizations(const Namespace: string; ScrollingWinControl: TScrollingWinControl): boolean;
begin
  assert(Assigned(ScrollingWinControl));

  result := False;

  Resources.EnumResourceStrings;

  RegisterComponentProps(ScrollingWinControl, Namespace);

  Resources.Sort;

  result := zEditLocalizations(ScrollingWinControl);

  if result then
  begin
    SaveToFile;
    NotifyListeners;
  end;
end;

function TzLocalizer.GetOwnerName(OwnerType: TRttiType; parentType: TRttiType; ComponentName: string): string;
begin
  if (Assigned(parentType) and Assigned(parentType.GetField(ComponentName))) then
    result := parentType.Name
  else
    result := OwnerType.Name;
end;

function TzLocalizer.GetTranslation(const ResStringName: string; const DefaultValue: string): string;
begin
  result := DefaultValue;

  if not FileLoaded then
    Exit;

  if not Assigned(Languages.ActiveLanguage) then
    Languages.SetActiveLanguage(CurrentLanguage);

  if Assigned(Languages.ActiveLanguage) then
    if not Languages.ActiveLanguage.FindTranslation(ResStringName, result) then
      result := DefaultValue;
end;

procedure TzLocalizer.LoadFromFile;
  procedure LoadResources(zip: TzLocalizerStorage);
  var
    s: string;
    r: TzResource;
    StringList: TStringList;
    tokens: TStringList;
    Namespace, ResourceName, DefaultValue: string;
  begin
    Resources.Clear;

    if not zip.FileExists(Resources.FileName) then
      Exit;

    StringList := TStringList.Create;
    try
      tokens := TStringList.Create;
      try
        tokens.StrictDelimiter := True;
        tokens.Delimiter := #9;

        zip.LoadStrings(StringList, Resources.FileName);

        for s in StringList do
        begin
          tokens.DelimitedText := s;

          Namespace := tokens[0];
          ResourceName := tokens[1];
          DefaultValue := tokens[2];

          Resources.AddResource(Namespace, ResourceName, DefaultValue, rkProp);
        end;
      finally
        FreeAndNil(tokens);
      end;
    finally
      FreeAndNil(StringList);
    end;
  end;

  procedure LoadLanguages(zip: TzLocalizerStorage);
  var
    files: TStringList;
    FileName: string;
    Language: TzLanguage;
    StringList: TStringList;
  begin
    Languages.Clear;

    StringList := TStringList.Create;
    try
      files := TStringList.Create;
      try
        zip.GetFileNames('', TzLanguages.Ext, files);

        for FileName in files do
        begin
          Language := Languages.Add;
          Language.Language := ChangeFileExt(FileName, '');
          Language.LocaleID := LocaleFromLanguage(Language.Language);

          StringList.Clear;
          zip.LoadStrings(StringList, FileName);
          Language.LoadFromStrings(StringList);
        end;
      finally
        FreeAndNil(files);
      end;
    finally
      FreeAndNil(StringList);
    end;
  end;

var
  zip: TzLocalizerStorage;
  StringList: TStringList;
  r: TzResource;
  Language: TzLanguage;

begin
  siMain.EnterMethod('TzLocalizer.LoadFromFile');

  if TFile.Exists(FileName) then
  begin

    zip := TzLocalizerStorage.Create;
    try
      zip.ZipFileName := FileName;

      LoadResources(zip);
      LoadLanguages(zip);
    finally
      FreeAndNil(zip);
    end;

    FileLoaded := True;
    FileExists := True;
  end;

  siMain.LeaveMethod('TzLocalizer.LoadFromFile');
end;

procedure TzLocalizer.NotifyListeners;
var
  Listener: IzLocalizerListener;
begin
  AssignDxResources;

  if FileLoaded then
    for Listener in Listeners do
      Listener.TranslationChanged;
end;

procedure TzLocalizer.RemoveListener(Listener: IzLocalizerListener);
begin
  Listeners.Remove(Listener);
end;

procedure TzLocalizer.SaveToFile;
var
  zip: TzLocalizerStorage;
  StringList: TStringList;
  r: TzResource;
  Language: TzLanguage;
begin
  siMain.EnterMethod('TzLocalizer.SaveToFile');

  zip := TzLocalizerStorage.Create;
  try
    zip.ZipFileName := FileName;

    StringList := TStringList.Create;
    try
      for r in Resources do
        if r.ResourceKind = rkProp then
          StringList.Add(r.Namespace + #9 + r.ResourceName + #9 + r.DefaultValue);

      zip.SaveStrings(StringList, 'Resources');

      for Language in Languages do
        if Language.Deleted then
          zip.DeleteFile(Language.FileName) // rename
        else
        begin
          StringList.Clear;
          Language.SaveToStrings(StringList);
          zip.SaveStrings(StringList, Language.FileName);
        end;
    finally
      FreeAndNil(StringList);
    end;
  finally
    FreeAndNil(zip);
  end;

  FileExists := True;

  siMain.LeaveMethod('TzLocalizer.SaveToFile');
end;

procedure TzLocalizer.SetCurrentLanguage(const Value: string);
begin
  if Value.IsEmpty then
    FCurrentLanguage := DefaultLanguage
  else
    FCurrentLanguage := Value;

  Languages.SetActiveLanguage(CurrentLanguage);

  if FileLoaded then
    NotifyListeners;
end;

procedure TzLocalizer.SetLanguages(const Value: TzLanguages);
begin
  FLanguages.Assign(Value);
end;

procedure TzLocalizer.SetResources(const Value: TzResources);
begin
  FResources.Assign(Value);
end;

procedure TzLocalizer.RegisterComponentProps(Component: TComponent; const Namespace: string);
var
  sub: TComponent;
begin
  case GetClassType(Component) of
    rctActionList:
      TActionList(Component).RegisterResources(Namespace, rkProp);
    rctPageControl:
      TcxPageControl(Component).RegisterResources(Namespace);
    rctLayoutControl:
      TdxLayoutControl(Component).RegisterResources(Namespace);
    rctCard:
      TzdbCard(Component).RegisterResources;
    rctView:
      TzDbView(Component).RegisterResources;
    rctPivot:
      TzDbPivot(Component).RegisterResources;
    rctRecordView:
      TzDbRecordView(Component).RegisterResources;
    rctTree:
      TzDbTree(Component).RegisterResources;
    rctChart:
      TzDbChart(Component).RegisterResources;
    rctScheduler:
      TzDbScheduler(Component).RegisterResources;
    rctFormController:
      TzFormController(Component).RegisterResources(Namespace);
    rctFileViewer:
      TzFileViewer(Component).RegisterResources;
    // rctGoogleMaps:
    // TzGoogleMaps(Component).RegisterResources(Namespace);
    rctOkCancel:
      TOkCancel(Component).RegisterResources(Namespace);
    rctLabel:
      TcxLabel(Component).RegisterResources(Namespace);
    rctRibbonTab:
      TdxRibbonTab(Component).RegisterResources(Namespace);
    rctScrollingWinControl:
      begin
        for sub in Component do
          if IsFrame(sub) then
            RegisterComponentProps(sub, Namespace + '.' + sub.Name)
          else
            RegisterComponentProps(sub, Namespace);
      end;
  end;
end;

procedure TzLocalizer.Translate(Component: TComponent; Namespace: string = '');
var
  sub: TComponent;
begin
  assert(Assigned(Component));

  if not FileLoaded then
    Exit;

  try
    case GetClassType(Component) of
      rctActionList:
        TActionList(Component).Translate(Namespace);
      rctPageControl:
        TcxPageControl(Component).Translate(Namespace);
      rctLayoutControl:
        TdxLayoutControl(Component).Translate(Namespace);
      rctCard:
        TzdbCard(Component).Translate;
      rctView:
        TzDbView(Component).Translate;
      rctPivot:
        TzDbPivot(Component).Translate;
      rctRecordView:
        TzDbRecordView(Component).Translate;
      rctTree:
        TzDbTree(Component).Translate;
      rctChart:
        TzDbChart(Component).Translate;
      rctScheduler:
        TzDbScheduler(Component).Translate;
      rctFormController:
        TzFormController(Component).Translate(Namespace);
      rctFileViewer:
        TzFileViewer(Component).Translate;
      // rctGoogleMaps:
      // TzGoogleMaps(Component).Translate(Namespace);
      rctOkCancel:
        TOkCancel(Component).Translate(Namespace);
      rctLabel:
        TcxLabel(Component).Translate(Namespace);
      rctRibbonTab:
        TdxRibbonTab(Component).Translate(Namespace);
      rctScrollingWinControl:
        begin
          for sub in Component do
            if IsFrame(sub) then
              Translate(sub, Namespace + '.' + sub.Name)
            else
              Translate(sub, Namespace);
        end;
    end;

  except
    on e: exception do
    begin
      siMain.LogException(e);
      siMain.LogString('ComponentName', Component.Name);
      siMain.LogString('ClassName', Component.ClassName);
      siMain.LogObject('Component', Component);
      raise;
    end;
  end;
end;
//
// procedure TzLocalizer.Translate(ScrollingWinControl: TScrollingWinControl; const Namespace: string);
// var
// RttiContext: TRttiContext;
// OwnerType: TRttiType;
// parentType: TRttiType;
// Component: TComponent;
// begin
// siMain.EnterMethod('TzLocalizer.Translate');
//
// if not FileLoaded then
// Exit;
//
// //
// // { TODO : Caption della form? }
// //
//
// RttiContext := TRttiContext.Create;
// OwnerType := RttiContext.GetType(ScrollingWinControl.ClassInfo);
// parentType := RttiContext.GetType(OwnerType.BaseType.AsInstance.MetaclassType);
//
// siMain.LogVerbose('Before Translate inner components');
//
// for Component in ScrollingWinControl do
// Translate(Component, GetOwnerName(OwnerType, parentType, Component.Name));
//
// siMain.LogVerbose('After Translate inner components');
//
// siMain.LeaveMethod('TzLocalizer.Translate');
// end;

{ TzLanguage }

constructor TzLanguage.Create(Collection: TCollection);
begin
  inherited;
  FLocaleID := SysLocale.DefaultLCID;
  FLanguage := LanguageFromLocale(LocaleID);

  FDictionary := TDictionary<string, string>.Create;
  // FDictionary.Sorted := True;
  // FDictionary.Duplicates := dupIgnore;
end;

destructor TzLanguage.Destroy;
begin
  FreeAndNil(FDictionary);
  inherited;
end;

function TzLanguage.FindTranslation(const ResourceName: string; out Value: string; const Default: string = ''): boolean;
begin
  Value := '';

  result := Dictionary.TryGetValue(ResourceName, Value);

  if not result then
    if not Default.IsEmpty then
    begin
      Dictionary.Add(ResourceName, Default);
      Value := Default;
      result := True;
    end;
end;

function TzLanguage.GetFileName: string;
begin
  result := ChangeFileExt(Language, TzLanguages.Ext);
end;

procedure TzLanguage.LoadFromFile(const FileName: string);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.LoadFromFile(FileName);
    LoadFromStrings(StringList);
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzLanguage.LoadFromStrings(Strings: TStrings);
var
  i: Integer;
begin
  assert(Assigned(Strings));

  Dictionary.Clear;

  for i := 0 to Strings.Count - 1 do
    Dictionary.AddOrSetValue(Strings.Names[i], Strings.ValueFromIndex[i]);
end;

procedure TzLanguage.SaveToFile(const FileName: string);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    SaveToStrings(StringList);
    StringList.SaveToFile(FileName);
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzLanguage.SaveToStrings(Strings: TStrings);
var
  pair: TPair<string, string>;
begin
  assert(Assigned(Strings));

  Strings.Clear;
  for pair in Dictionary do
    Strings.AddPair(pair.Key, pair.Value);
end;

{ TzResource }

constructor TzResource.Create(Collection: TCollection);
begin
  inherited;
  FNamespace := '';
  FResourceName := '';
  FDefaultValue := '';
  FResourceKind := rkProp;
end;

procedure TzResource.Assign(Source: TPersistent);
var
  src: TzResource;
begin
  if Source is TzResource then
  begin
    src := TzResource(Source);
    FNamespace := src.Namespace;
    FResourceName := src.ResourceName;
    FDefaultValue := src.DefaultValue;
    FResourceKind := src.ResourceKind;
  end
  else
    inherited;
end;

function TzResource.FullResourceName: string;
begin
  result := zLocalizer.utils.FullResourceName(Namespace, ResourceName);
end;

procedure TzResources.AddResource(const Namespace, ResourceName, DefaultValue: string; const ResourceKind: TResourceKind);
var
  r: TzResource;
begin
  r := GetResource(Namespace, ResourceName);

  if not Assigned(r) then
  begin
    r := Add;
    r.Namespace := Namespace;
    r.ResourceName := ResourceName;
  end;

  r.DefaultValue := DefaultValue;
  r.ResourceKind := ResourceKind;
end;

procedure TzResources.AddResource(const Namespace, ClassName, ComponentName, PropertyName, DefaultValue: string; const ResourceKind: TResourceKind);
begin
  AddResource(Namespace, GetResourceName(ClassName, ComponentName, PropertyName), DefaultValue, ResourceKind);
end;

procedure TzResources.EnumResourceStrings;
  procedure DeleteResources;
  var
    i: Integer;
  begin
    for i := Count - 1 downto 0 do
      if items[i].ResourceKind <> rkProp then
        Delete(i);
  end;

  procedure EnumResourceStringsDX;
  var
    i: Integer;
    p: Integer;
    r: TzResource;
  begin
    for p := 0 to dxResourceStringsRepository.ProductsCount - 1 do
      for i := 0 to dxResourceStringsRepository.Products[p].ResStringsCount - 1 do
      begin
        r := Add;
        r.Namespace := dxResourceStringsRepository.Products[p].Name;
        r.ResourceName := dxResourceStringsRepository.Products[p].Names[i];

        r.DefaultValue := zDxGetResourceString(r.ResourceName);
        r.ResourceKind := rkDX;
      end;
  end;

  procedure EnumResourceStringsZZ;
  begin
    TzdbCard.EnumResourceStrings;
    TzDbView.EnumResourceStrings;
    TzDbPivot.EnumResourceStrings;
    TzDbRecordView.EnumResourceStrings;
    TzDbTree.EnumResourceStrings;
    TzDbChart.EnumResourceStrings;
    TzDbScheduler.EnumResourceStrings;
    TzFileViewer.EnumResourceStrings;
    // TzGoogleMaps.EnumResourceStrings;
    TOkCancel.EnumResourceStrings;
  end;

begin
  DeleteResources;
  EnumResourceStringsDX;
  EnumResourceStringsZZ;
end;

function TzResources.Compare(Item1, Item2: TzResource): Integer;
begin
  if ord(Item1.ResourceKind) > ord(Item2.ResourceKind) then
    result := 1
  else
    if ord(Item1.ResourceKind) < ord(Item2.ResourceKind) then
      result := -1
    else
    begin
      result := CompareText(Item1.Namespace, Item2.Namespace);

      if result = 0 then
        result := CompareText(Item1.ResourceName, Item2.ResourceName)
    end;
end;

constructor TzResources.Create;
begin
  inherited Create(TzResource);
end;

function TzResources.GetResource(const Namespace, ResourceName: string): TzResource;
begin
  for result in self do
    if SameText(result.Namespace, Namespace) then
      if SameText(result.ResourceName, ResourceName) then
        Exit;

  result := nil;
end;

function TzResources.GetResourceName(const ClassName, ComponentName, PropertyName: string): string;
begin
  result := zLocalizer.utils.GetResourceName(ClassName, ComponentName, PropertyName);
end;

constructor TzLanguages.Create;
begin
  inherited Create(TzLanguage);
  FActiveLanguage := nil;
end;

function TzLanguages.GetLanguage(const Language: string): TzLanguage;
begin
  for result in self do
    if SameText(result.Language, Language) then
      Exit;

  result := nil;
end;

function TzLanguages.GetLanguage(const LocaleID: Cardinal): TzLanguage;
begin
  for result in self do
    if result.LocaleID = LocaleID then
      Exit;

  result := nil;
end;

procedure TzLanguages.Notify(Item: TCollectionItem; Action: System.Classes.TCollectionNotification);
begin
  if Action = cnDeleting then
    if Item = ActiveLanguage then
      FActiveLanguage := nil;
end;

procedure TzLanguages.SetActiveLanguage(const LocaleID: Cardinal);
begin
  FActiveLanguage := GetLanguage(LocaleID);
end;

procedure TzLanguages.SetActiveLanguage(const Language: string);
begin
  FActiveLanguage := GetLanguage(Language);
end;

initialization

__Localizer := nil;

siMain := Si.AddSession('zLocalizer', True);

//dxLocalizeITA; // da rivedere

finalization

FreeAndNil(__Localizer);

siMain := nil;

end.


// Valutare quando enumerare anche i subcomponenti }
// i componenti inherited sono da trattare come ResourceString?
// implementare gli helper

  zLocalizer.types;

IzLocalizerListener)
