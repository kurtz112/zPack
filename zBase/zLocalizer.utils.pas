unit zLocalizer.utils;

interface

uses
  System.SysUtils,
  System.Classes,
  zLocalizer.types;

procedure EnumLanguages(Localizations: TStrings);
function LanguageFromLocale(Locale: Cardinal): string;
function LocaleFromLanguage(Language: string): Cardinal;

function FullResourceName(const NameSpace, ResourceName: string): string; overload;
function FullResourceName(const NameSpace, ClassName, ComponentName, PropertyName: string): string; overload;
function GetResourceName(const ClassName, ComponentName, PropertyName: string): string;

function GetClassType(Component: TComponent): TResourceClassType;

function ClassNameSpace(Clazz: TClass; ID: string): string;
function ClassPrefix(Clazz: TClass): string;

function IsFrame(Component: TComponent): boolean;

implementation

uses
  System.Actions,
  Vcl.ActnList,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  zdbView,
  zdbCard,
  zDbPivot,
  zDbRecordView,
  zDbTree,
  zDbChart,
  zDbScheduler,
  zFileViewer,
//  zGoogleMaps,
  zTreeMenu,
  zSystem,
  zFormController,
  zDx,
  cxPC,
  dxLayoutControl,
  OkCancel,
  cxLabel,
  dxRibbon,
  dxBar;

function LanguageFromLocale(Locale: Cardinal): string;
var
  Languages: TLanguages;
begin
  Languages := TLanguages.Create;
  try
    result := Languages.NameFromLocaleID[Locale];
  finally
    FreeAndNil(Languages);
  end;
end;

function LocaleFromLanguage(Language: string): Cardinal;
var
  Languages: TLanguages;
begin
  Languages := TLanguages.Create;
  try
    result := Languages.LocaleIDFromName[Language];
  finally
    FreeAndNil(Languages);
  end;
end;

procedure EnumLanguages(Localizations: TStrings);
var
  i: integer;
  Languages: TLanguages;
begin
  assert(assigned(Localizations));

  Localizations.Clear;

  Languages := TLanguages.Create;
  try
    for i := 0 to Languages.Count - 1 do
      Localizations.Add(Languages.Name[i]);
  finally
    FreeAndNil(Languages);
  end;
end;

function FullResourceName(const NameSpace, ResourceName: string): string;
begin
  result := NameSpace + '->' + ResourceName;
end;

function FullResourceName(const NameSpace, ClassName, ComponentName, PropertyName: string): string; overload;
begin
  result := FullResourceName(NameSpace, GetResourceName(ClassName, ComponentName, PropertyName));
end;

function GetResourceName(const ClassName, ComponentName, PropertyName: string): string;
begin
  // ClassName pu� essere vuoto
  result := Trim(ClassName + ' ' + ComponentName + '.' + PropertyName);
end;

function GetClassType(Component: TComponent): TResourceClassType;
begin
  result := rctComponent;

  if Component is TActionList then
    result := rctActionList
  else
    if Component is TcxPageControl then
      result := rctPageControl
    else
      if Component is TzDbView then
        result := rctView
      else
        if Component is TzDbCard then
          result := rctCard
        else
          if Component is TzDbPivot then
            result := rctPivot
          else
            if Component is TzFileViewer then
              result := rctFileViewer
            else
//              if Component is TzGoogleMaps then
//                result := rctGoogleMaps
//              else
                if Component is TdxLayoutControl then
                  result := rctLayoutControl
                else
                  if Component is TzFormController then
                    result := rctFormController
                  else
                    if Component is TdxRibbonTab then
                      result := rctRibbonTab
                    else
                      if Component is TcxLabel then
                        result := rctLabel
                      else
                        if Component is TOkCancel then
                          result := rctOkCancel
                        else
                          if Component is TScrollingWinControl then
                            result := rctScrollingWinControl;

  // R-017: i componenti dati nati dopo TzDbPivot. Fuori dalla catena perche'
  // sono frame: senza questi controlli finirebbero in rctScrollingWinControl
  // e la traduzione li tratterebbe come frame generici
  if Component is TzDbRecordView then
    result := rctRecordView
  else if Component is TzDbTree then
    result := rctTree
  else if Component is TzDbChart then
    result := rctChart
  else if Component is TzDbScheduler then
    result := rctScheduler;
end;

function IsFrame(Component: TComponent): boolean;
begin
  result := Component Is TFrame;

  if result then
    result := not(GetClassType(Component) in [rctCard, rctView, rctPivot, rctRecordView, rctTree, rctChart, rctScheduler, rctFormController, rctFileViewer, rctGoogleMaps,
      rctOkCancel]);
end;

function ClassNameSpace(Clazz: TClass; ID: string): string;
begin
  if ID.IsEmpty then
    result := ''
  else
    result := ClassPrefix(Clazz) + '.' + ID;
end;

function ClassPrefix(Clazz: TClass): string;
begin
  result := '';

  if Clazz = TzDbView then
    result := 'zDbView'
  else
    if Clazz = TzDbCard then
      result := 'zDbCard'
    else
      if Clazz = TzDbPivot then
        result := 'zDbPivot'
      else
        if Clazz = TzDiagramDataset.TDbView then
          result := 'zDbView'
        else
          if Clazz = TzDiagramDataset.TDbCard then
            result := 'zDbCard'
          else
            if Clazz = TzDiagramDataset.TDbPivot then
              result := 'zDbPivot';

  // R-017: stesso prefisso per il frame e per la voce del diagramma, cosi' il
  // titolo del gruppo nel layout (TLayoutController.TranslateGroupCaptions)
  // e quello del frame leggono la stessa traduzione
  if (Clazz = TzDbRecordView) or (Clazz = TzDiagramDataset.TDbRecordView) then
    result := 'zDbRecordView'
  else if (Clazz = TzDbTree) or (Clazz = TzDiagramDataset.TDbTree) then
    result := 'zDbTree'
  else if (Clazz = TzDbChart) or (Clazz = TzDiagramDataset.TDbChart) then
    result := 'zDbChart'
  else if (Clazz = TzDbScheduler) or (Clazz = TzDiagramDataset.TDbScheduler) then
    result := 'zDbScheduler';
end;

end.
