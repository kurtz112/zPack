unit zLocalizer.Form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.ComCtrls,
  vcl.StdCtrls,
  vcl.ToolWin,
  vcl.ExtCtrls,
  vcl.Menus,
  TypInfo,
  vcl.Buttons,
  WinTypes,
  vcl.ImgList,
  zSystem,
  vcl.ActnList,
  System.Actions,
  System.ImageList,
  cxClasses,
  dxBar,
  cxImageList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxCustomData,
  cxStyles,
  cxTL,
  cxTextEdit,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxLabel,
  cxEdit,
  cxEditRepositoryItems,
  cxImageComboBox,
  cxDataStorage,
  Generics.Collections,
  cxButtons,
  System.Variants,
  cxCheckBox,
  cxExtEditRepositoryItems,
  cxImage,
  cxVGrid,
  cxOI,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  vcl.StdActns,
  OkCancel,
  zLocalizer,
  zLocalizer.types,
  dxScrollbarAnnotations,
  SmartInspect.vcl,
  SmartInspect.vcl.SiAuto,
  dxFileActions, cxFilter;

type
  TzLocalizerForm = class(TForm)
    ActionList: TActionList;
    AddLanguage: TAction;
    DeleteLanguage: TAction;
    treeImages: TcxImageList;
    dxBarManager: TdxBarManager;
    dxBarManagerBar1: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton7: TdxBarButton;
    ApplyBestWidth: TAction;
    dxBarButton9: TdxBarButton;
    dxBarSubItemAccess: TdxBarSubItem;
    Esporta: TdxFileSaveAs;
    dxBarButton10: TdxBarButton;
    OkCancel: TOkCancel;
    tree: TcxTreeList;
    colNamespace: TcxTreeListColumn;
    colResourceName: TcxTreeListColumn;
    cxEditRepository: TcxEditRepository;
    cxEditRepositoryTextItem: TcxEditRepositoryTextItem;
    Importa: TdxFileOpen;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    ColumnAutoWidth: TAction;
    dxBarButton5: TdxBarButton;
    Espandi: TAction;
    Raccogli: TAction;
    dxBarButton6: TdxBarButton;
    dxBarButton8: TdxBarButton;
    CopiaFile: TdxFileSaveAs;
    dxBarButton11: TdxBarButton;
    ReplaceDialog: TReplaceDialog;
    Sostituisci: TAction;
    dxBarButton12: TdxBarButton;
    procedure EspandiExecute(Sender: TObject);
    procedure AddLanguageExecute(Sender: TObject);
    procedure ApplyBestWidthExecute(Sender: TObject);
    procedure ColumnAutoWidthExecute(Sender: TObject);
    procedure CopiaFileAccept(Sender: TObject);
    procedure CopiaFileBeforeExecute(Sender: TObject);
    procedure CopiaFileUpdate(Sender: TObject);
    procedure DeleteLanguageExecute(Sender: TObject);
    procedure EsportaAccept(Sender: TObject);
    procedure EsportaBeforeExecute(Sender: TObject);
    procedure EsportaUpdate(Sender: TObject);
    procedure ImportaAccept(Sender: TObject);
    procedure ImportaBeforeExecute(Sender: TObject);
    procedure ImportaUpdate(Sender: TObject);
    procedure OkCancelApply(Sender: TObject);
    procedure RaccogliExecute(Sender: TObject);
    procedure ReplaceDialogClose(Sender: TObject);
    procedure ReplaceDialogFind(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
    procedure SostituisciExecute(Sender: TObject);
    procedure treeColumnHeaderClick(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
    procedure treeFocusedColumnChanged(Sender: TcxCustomTreeList; APrevFocusedColumn, AFocusedColumn: TcxTreeListColumn);
    procedure treeSelectionChanged(Sender: TObject);
  private
    cxStyleFixed: TcxStyle;
    cxStyleColumnOdd: TcxStyle;
    cxStyleColumnEven: TcxStyle;
    cxStyleSelected: TcxStyle;
    cxStyleFocused: TcxStyle;
    procedure InitStyles;
    procedure SetColumnAutoWidthIamgeIndex;
  private
    prevColumn: TcxTreeListColumn;
    NameSpaceNodes: TDictionary<string, TcxTreeListNode>;
    function GetNameSpaceNode(const NameSpace: string; const ResourceKind: TResourceKind): TcxTreeListNode;
  private
    procedure ApplyBestFit;
    function LanguageColumnName(const Language: TzLanguage): string;

    function ColumnIndex(const Language: TzLanguage): Integer;

    function CreateLanguageColumn(const Language: TzLanguage): TcxTreeListColumn; overload;
    function CreateLanguageColumn: TcxTreeListColumn; overload;

    procedure SetPolicyStyle(Column: TcxTreeListColumn);
    function SelectedLanguage: TzLanguage;

    procedure SearchReplace(doReplace: boolean);
  protected
    procedure CreateColumns;
    procedure CreateNodes;
    procedure SaveLanguages;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Edit(ScrollingWinControl: TScrollingWinControl): boolean;
  end;

function zEditLocalizations(ScrollingWinControl: TScrollingWinControl): boolean;

implementation

uses
  System.Ioutils,
  CommCtrl,
  cxCheckGroup,
  zMsg,
  zBaseLib,
  zDbView,
  zDbCard,
  zDx,
  System.Rtti,
  zFileViewer;

{$R *.DFM}

function zEditLocalizations(ScrollingWinControl: TScrollingWinControl): boolean;
var
  zLocalizerForm: TzLocalizerForm;
begin
  Application.CreateForm(TzLocalizerForm, zLocalizerForm);
  try
    result := zLocalizerForm.Edit(ScrollingWinControl);
  finally
    FreeAndNil(zLocalizerForm);
  end;
end;

constructor TzLocalizerForm.Create(aOwner: TComponent);

begin
  inherited;
  dx.AgganciaImmagini(Self);
  prevColumn := nil;
  NameSpaceNodes := TDictionary<string, TcxTreeListNode>.Create;

  dx.InitTreeList(tree);
  InitStyles;
  tree.OptionsView.ColumnAutoWidth := False;
  SetColumnAutoWidthIamgeIndex;

  Esporta.Dialog.InitialDir := Desktop;
  Importa.Dialog.InitialDir := Esporta.Dialog.InitialDir;
  CopiaFile.Dialog.InitialDir := Esporta.Dialog.InitialDir;

  WindowState := wsMaximized;
end;

destructor TzLocalizerForm.Destroy;
begin
  FreeAndNil(NameSpaceNodes);
  inherited;
end;

procedure TzLocalizerForm.EspandiExecute(Sender: TObject);
begin
  tree.FullExpand;
end;

function TzLocalizerForm.LanguageColumnName(const Language: TzLanguage): string;
  function ValidateComponentName(Name: string): string;
  const
    Alpha = ['A' .. 'Z', 'a' .. 'z', '_'];
    AlphaNumeric = Alpha + ['0' .. '9'];
  var
    i: Integer;
  begin
    result := Name;
    for i := 1 to length(result) do
      if not(result[i] in AlphaNumeric) then
        result[i] := '_';
  end;

begin
  result := 'colLanguage' + ValidateComponentName(Language.Language);
end;

function TzLocalizerForm.CreateLanguageColumn(const Language: TzLanguage): TcxTreeListColumn;
begin
  result := tree.CreateColumn(tree.Bands[1]);
  result.Name := LanguageColumnName(Language);
  result.Caption.Text := Language.Language;
  result.DataBinding.ValueType := 'String';
  result.RepositoryItem := cxEditRepositoryTextItem;
  result.Position.BandIndex := 1;
  result.Position.RowIndex := 0;
  result.Position.ColIndex := tree.ColumnCount;
  result.BestFitMaxWidth := 120;
  result.Width := 120;
  result.Options.IncSearch := False;
  result.Options.Moving := False;
  result.Options.Sorting := False;
  result.Focused := True;
  result.Tag := NativeInt(Language);

  SetPolicyStyle(result);
end;

function TzLocalizerForm.ColumnIndex(const Language: TzLanguage): Integer;
var
  col: TcxTreeListColumn;
begin
  result := -1;

  col := FindComponent(LanguageColumnName(Language)) as TcxTreeListColumn;

  if Assigned(col) then
    result := col.VisibleIndex;
end;

procedure TzLocalizerForm.CreateNodes;
var
  NameSpaceNode, node: TcxTreeListNode;
  zResource: TzResource;
  Language: TzLanguage;
  colIdx: Integer;
  s: string;
begin
  tree.Clear;
  NameSpaceNodes.Clear;

  tree.BeginUpdate;
  try
    for zResource in Localizer.Resources do
    begin
      NameSpaceNode := GetNameSpaceNode(zResource.NameSpace, zResource.ResourceKind);
      node := tree.AddChild(NameSpaceNode);
      node.Data := zResource;
      node.Texts[colNamespace.VisibleIndex] := zResource.NameSpace;
      node.Texts[colResourceName.VisibleIndex] := zResource.ResourceName;

      for Language in Localizer.Languages do
        if not Language.Deleted then
        begin
          colIdx := ColumnIndex(Language);

          if not Language.FindTranslation(zResource.FullResourceName, s) then
            s := zResource.DefaultValue;

          node.Texts[colIdx] := s;
        end;
    end;

    ApplyBestFit;
  finally
    tree.EndUpdate;
  end;
end;

procedure TzLocalizerForm.CreateColumns;
var
  Language: TzLanguage;
begin
  for Language in Localizer.Languages do
    if not Language.Deleted then
      CreateLanguageColumn(Language);
end;

procedure TzLocalizerForm.AddLanguageExecute(Sender: TObject);
begin
  CreateLanguageColumn;
end;

procedure TzLocalizerForm.ApplyBestFit;
begin
  tree.ApplyBestFit;
  colNamespace.ApplyBestFit;
  colResourceName.ApplyBestFit;
end;

procedure TzLocalizerForm.ApplyBestWidthExecute(Sender: TObject);
begin
  ApplyBestFit;
end;

procedure TzLocalizerForm.ColumnAutoWidthExecute(Sender: TObject);
begin
  tree.OptionsView.ColumnAutoWidth := not tree.OptionsView.ColumnAutoWidth;
  SetColumnAutoWidthIamgeIndex;
end;

procedure TzLocalizerForm.CopiaFileAccept(Sender: TObject);
begin
  SaveLanguages;
  TFile.Copy(Localizer.FileName, CopiaFile.Dialog.FileName);
end;

procedure TzLocalizerForm.CopiaFileBeforeExecute(Sender: TObject);
begin
  CopiaFile.Dialog.FileName := ExtractFileName(Localizer.FileName);
end;

procedure TzLocalizerForm.CopiaFileUpdate(Sender: TObject);
begin
  CopiaFile.Enabled := Localizer.FileExists;
end;

function TzLocalizerForm.CreateLanguageColumn: TcxTreeListColumn;
var
  i: Integer;
  Language: TzLanguage;
  node: TcxTreeListNode;
  s: string;
  zResource: TzResource;
begin
  result := nil;

  Language := Localizer.AddNewLanguage;
  if not Assigned(Language) then
    Exit;

  result := CreateLanguageColumn(Language);
  tree.FocusedColumn := result;

  tree.BeginUpdate;
  try
    for i := 0 to tree.AbsoluteCount - 1 do
      if tree.AbsoluteItems[i].Level = 1 then
      begin
        node := tree.AbsoluteItems[i];
        zResource := TzResource(node.Data);

        if not Language.FindTranslation(zResource.FullResourceName, s) then
          s := zResource.DefaultValue;

        node.Texts[result.VisibleIndex] := s;
      end;
  finally
    tree.EndUpdate;
  end;
end;

procedure TzLocalizerForm.DeleteLanguageExecute(Sender: TObject);
var
  col: TcxTreeListColumn;
  Language: TzLanguage;
begin
  col := tree.FocusedColumn;

  if not Assigned(tree) then
    Exit;

  Language := TzLanguage(col.Tag);

  if not Assigned(Language) then
    Exit;

  if not ConfirmYesNo('Si desidera eliminare la traduzione in ' + Language.Language + '?') then
    Exit;

  col.Free;
  Language.Deleted := True;
end;

function TzLocalizerForm.Edit(ScrollingWinControl: TScrollingWinControl): boolean;
var
  M: TMonitor;
begin
  if not Assigned(ScrollingWinControl) then
    Exit;

  M := Screen.MonitorFromWindow(Application.MainForm.Handle);
  Self.Width := trunc(M.WorkareaRect.Width * 0.9);
  Self.Height := trunc(M.WorkareaRect.Height * 0.9);

  CreateColumns;
  CreateNodes;

  result := ShowModal = mrOk;
  if result then
    SaveLanguages;
end;

procedure TzLocalizerForm.treeColumnHeaderClick(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn);
begin
  AColumn.Focused := True;
end;

function TzLocalizerForm.GetNameSpaceNode(const NameSpace: string; const ResourceKind: TResourceKind): TcxTreeListNode;
begin
  result := nil;

  if not NameSpaceNodes.TryGetValue(NameSpace, result) then
  begin
    result := tree.AddChild(tree.Root);
    result.Texts[0] := NameSpace;
    case ResourceKind of
      rkProp:
        result.ImageIndex := 0;
      rkDX:
        result.ImageIndex := 1;
      rkZZ:
        result.ImageIndex := 2;
    end;

    NameSpaceNodes.add(NameSpace, result);
  end;
end;

procedure TzLocalizerForm.SetColumnAutoWidthIamgeIndex;
begin
  if tree.OptionsView.ColumnAutoWidth then
    ColumnAutoWidth.ImageIndex := dx.IndiceIcona('expandall')
  else
    ColumnAutoWidth.ImageIndex := dx.IndiceIcona('resize');
end;

procedure TzLocalizerForm.SetPolicyStyle(Column: TcxTreeListColumn);
begin
  if not Assigned(Column) then
    Exit;

  if Column.Position.BandIndex = 0 then
    Exit;

  // if Column.Focused then
  // Column.Styles.Content := cxStylePolicyFocused
  // else
  if odd(Column.Position.ColIndex) then
    Column.Styles.Content := cxStyleColumnOdd
  else
    Column.Styles.Content := cxStyleColumnEven;
end;

procedure TzLocalizerForm.InitStyles;
begin
  cxStyleFixed := dx.GetStyle(scBtnFace);
  cxStyleColumnOdd := dx.GetStyle(scContentOdd);
  cxStyleColumnEven := dx.GetStyle(scContentEven);
  cxStyleSelected := dx.GetStyle(scHighlight);
  cxStyleFocused := dx.GetStyle(scSkyBlue);

  tree.Bands[0].Styles.Content := cxStyleFixed;
  tree.Styles.Selection := cxStyleSelected;
end;

procedure TzLocalizerForm.OkCancelApply(Sender: TObject);
begin
  if ConfirmYesNo('Si desidera salvare le traduzioni?') then
    SaveLanguages;
end;

procedure TzLocalizerForm.SaveLanguages;
var
  i: Integer;
  colIdx: Integer;
  Language: TzLanguage;
  node: TcxTreeListNode;
  ResourceName: string;
  Value: string;
Begin
  for Language in Localizer.Languages do
    if not Language.Deleted then
    begin
      Language.Dictionary.Clear;
      colIdx := ColumnIndex(Language);

      for i := 0 to tree.AbsoluteCount - 1 do
        if tree.AbsoluteItems[i].Level = 1 then
        begin
          node := tree.AbsoluteItems[i];
          ResourceName := TzResource(node.Data).FullResourceName;
          Value := node.Texts[colIdx];
          Language.Dictionary.AddOrSetValue(ResourceName, Value);
        end;
    end;

  Localizer.SaveToFile;
end;

procedure TzLocalizerForm.EsportaUpdate(Sender: TObject);
begin
  Esporta.Enabled := SelectedLanguage <> nil;
end;

procedure TzLocalizerForm.EsportaBeforeExecute(Sender: TObject);
begin
  if SelectedLanguage <> nil then
    Esporta.Dialog.FileName := SelectedLanguage.FileName;
end;

procedure TzLocalizerForm.EsportaAccept(Sender: TObject);
begin
  if SelectedLanguage <> nil then
    SelectedLanguage.SaveToFile(Esporta.Dialog.FileName);
end;

procedure TzLocalizerForm.ImportaAccept(Sender: TObject);
begin

  if SelectedLanguage <> nil then
    if ConfirmYesNo('Si desidera sovrascrivere le traduzioni per la lingua ' + SelectedLanguage.Language + '?') then
    begin
      SelectedLanguage.LoadFromFile(Importa.Dialog.FileName);
      CreateNodes;
    end;
end;

procedure TzLocalizerForm.ImportaBeforeExecute(Sender: TObject);
begin
  if SelectedLanguage <> nil then
    Importa.Dialog.FileName := SelectedLanguage.FileName;
end;

procedure TzLocalizerForm.ImportaUpdate(Sender: TObject);
begin
  Importa.Enabled := SelectedLanguage <> nil;
end;

procedure TzLocalizerForm.RaccogliExecute(Sender: TObject);
begin
  tree.FullCollapse;
end;

function TzLocalizerForm.SelectedLanguage: TzLanguage;
begin
  result := nil;

  if Assigned(tree.FocusedColumn) then
    if TObject(tree.FocusedColumn.Tag) is TzLanguage then
      result := TzLanguage(tree.FocusedColumn.Tag);
end;

procedure TzLocalizerForm.treeFocusedColumnChanged(Sender: TcxCustomTreeList; APrevFocusedColumn, AFocusedColumn: TcxTreeListColumn);
begin

  if SelectedLanguage <> nil then
  begin
    Esporta.Caption := 'Esporta - ' + SelectedLanguage.Language;
    Importa.Caption := 'Importa - ' + SelectedLanguage.Language;
  end
  else
  begin
    Esporta.Caption := 'Esporta';
    Importa.Caption := 'Importa';
  end;
end;

procedure TzLocalizerForm.treeSelectionChanged(Sender: TObject);
begin
  /// //////////////////////////////////////////////////
  if Assigned(prevColumn) then
    if Assigned(prevColumn.Position) then
    begin
      if odd(prevColumn.Position.ColIndex) then
        prevColumn.Styles.Content := cxStyleColumnOdd
      else
        prevColumn.Styles.Content := cxStyleColumnEven;
    end;
  /// //////////////////////////////////////////////////

  if not Assigned(tree.FocusedColumn) then
    Exit;

  if tree.FocusedColumn.Position.BandIndex = 0 then
    Exit;

  /// //////////////////////////////////////////////////

  prevColumn := tree.FocusedColumn;
  prevColumn.Styles.Content := cxStyleFocused;
end;

procedure TzLocalizerForm.ReplaceDialogFind(Sender: TObject);
begin
  SearchReplace(False);
end;

procedure TzLocalizerForm.ReplaceDialogReplace(Sender: TObject);
begin
  SearchReplace(True);
end;

procedure TzLocalizerForm.ReplaceDialogClose(Sender: TObject);
begin
  tree.SetFocus;
end;

procedure TzLocalizerForm.SostituisciExecute(Sender: TObject);
var
  Language: TzLanguage;
  s: string;
begin
  Language := SelectedLanguage;

  if not Assigned(Language) then
    Exit;

  ReplaceDialog.FindText := s;
  ReplaceDialog.Execute(Self.Handle);
end;

procedure TzLocalizerForm.SearchReplace(doReplace: boolean);
var
  Language: TzLanguage;
  colIdx, startIdx: Integer;
  FindText: string;
  i: Integer;
  node: TcxTreeListNode;
  Value: string;
begin

  Language := SelectedLanguage;

  if not Assigned(Language) then
  begin
    ConfirmOk('Nessuna lingua selezionata.');
    Exit;
  end;

  /// //////////////////////
  if ReplaceDialog.FindText.IsEmpty then
  begin
    ConfirmOk('Nessun testo da cercare.');
    Exit;
  end;

  FindText := ReplaceDialog.FindText.ToUpper;

  /// //////////////////////

  if doReplace then
    if frReplaceAll in ReplaceDialog.Options then
      if not ConfirmYesNo('Sostituire tutte le occorrenze di "+ReplaceDialog.FindText+" nella lingua selezionata?') then
        Exit;

  /// //////////////////////

  colIdx := ColumnIndex(Language);

  // if Assigned(tree.FocusedNode) and (tree.FocusedNode.Level = 1) and (tree.FocusedNode.Texts[colIdx].ToUpper.Contains(FindText)) then
  if Assigned(tree.FocusedNode) then
    startIdx := tree.FocusedNode.AbsoluteIndex
  else
    startIdx := 0;

  if not doReplace then
    inc(startIdx); // il successivo

  /// //////////////////////

  for i := startIdx to tree.AbsoluteCount - 1 do
    if tree.AbsoluteItems[i].Level = 1 then
    begin
      node := tree.AbsoluteItems[i];
      Value := node.Texts[colIdx];

      if Value.ToUpper.Contains(FindText) then
      begin
        node.MakeVisible;
        node.Focused := True;

        if not doReplace then
        begin
          tree.SetFocus;
          Exit; // cerca, lo ha trovato e stop
        end;

        Value := StringReplace(Value, FindText, ReplaceDialog.ReplaceText, [rfReplaceAll, rfIgnoreCase]);
        node.Texts[colIdx] := Value;

        if not(frReplaceAll in ReplaceDialog.Options) then
        begin
          tree.SetFocus;
          Exit;
        end;
      end;
    end;
end;

end.
