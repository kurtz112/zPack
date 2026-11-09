unit zOffice.SynEdit.Frame;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Actions,
  System.ImageList,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  ExtCtrls,
  ImgList,
  ActnMan,
  ToolWin,
  StdCtrls,
  Menus,
  StdActns,
  ActnList,
  SynEdit,
  SynCompletionProposal,
  SynEditTypes,
  SynEditHighlighter,
  SynEditOptionsDialog,
  SynEditMiscClasses,
  SynHighlighterSQL,
  SynEditPlugins,
  SynMacroRecorder,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxSplitter,
  dxStatusBar,
  cxContainer,
  cxEdit,
  cxTextEdit,
  cxMemo,
  cxScrollBar,
  dxFileActions,
  cxClasses,
  dxBar,
  cxImageList,
  dxUIAClasses,
  SynEditCodeFolding,
  SynHighlighterJSON,
  SynHighlighterXML,
  SynEditPrint,
  SynEditRegexSearch,
  zOffice.types,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzViewerSynEditFrame = class;
  TImportFileSynEditEvent = procedure(sender: TzViewerSynEditFrame; const FileName: string) of object;

  TzViewerSynEditFrame = class(TFrame, izViewerFrame, IcxLookAndFeelNotificationListener)
    PanelEditor: TPanel;
    StatusBar: TdxStatusBar;
    Editor: TSynEdit;
    SynEditOptionsDialog: TSynEditOptionsDialog;
    ActionList: TActionList;
    actCopia: TEditCopy;
    actSelezionaTutto: TEditSelectAll;
    actTrova: TAction;
    SalvaSuFile: TdxFileSaveAs;
    actOpzioniEditor: TAction;
    FindDialog: TFindDialog;
    VScrollBar: TcxScrollBar;
    HScrollBar: TcxScrollBar;
    dxBarManager: TdxBarManager;
    dxBarPopupMenu: TdxBarPopupMenu;
    Copy1: TdxBarButton;
    SelectAll1: TdxBarButton;
    Find1: TdxBarButton;
    EditorOptions1: TdxBarButton;
    dxBarManagerBar: TdxBar;
    dxBarButton5: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    dxBarButton1: TdxBarButton;
    SynXMLSyn: TSynXMLSyn;
    SynJSONSyn: TSynJSONSyn;
    SynEditPrint: TSynEditPrint;
    Importa: TdxFileOpen;
    Apri: TAction;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    Stampa: TAction;
    dxBarButton6: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    SynEditRegexSearch: TSynEditRegexSearch;
    Formatta: TAction;
    dxBarButton11: TdxBarButton;
    PrintDialog: TPrintDialog;
    procedure EditorStatusChange(sender: TObject; Changes: TSynStatusChanges);
    procedure actOpzioniEditorExecute(sender: TObject);
    procedure SalvaSuFileAccept(sender: TObject);
    procedure actTrovaExecute(sender: TObject);
    procedure ApriExecute(sender: TObject);
    procedure DoFindText(sender: TObject);
    procedure FormattaExecute(sender: TObject);
    procedure FormattaUpdate(sender: TObject);
    procedure SalvaSuFileBeforeExecute(sender: TObject);
    procedure HScrollBarScroll(sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure ImportaAccept(sender: TObject);
    procedure ImportaBeforeExecute(sender: TObject);
    procedure ImportaUpdate(sender: TObject);
    procedure VScrollBarScroll(sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure SetFileName(const Value: string);
    procedure StampaExecute(sender: TObject);
  private
    FilesDefaultExt: string;
    FilesFilter: string;

    procedure SetScrollbarsRange;
  private
    FFileName: string;
    FFileType: TzFileType;
    FIsEmbedded: boolean;
    FOnImportFile: TImportFileSynEditEvent;
    IsScrolling: boolean;
  protected
    function GetObject: TObject;
    procedure MasterLookAndFeelChanged(sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
    procedure MasterLookAndFeelDestroying(sender: TcxLookAndFeel);
    procedure SetEditorColors;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    property IsEmbedded: boolean read FIsEmbedded;
  public
    function Empty: boolean;
    procedure Clear;
    procedure SaveToFile(const FileName: string);
  public // izViewerFrame
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
  published
    property FileType: TzFileType read FFileType;
    property FileName: string read FFileName write SetFileName stored False;
    property OnImportFile: TImportFileSynEditEvent read FOnImportFile write FOnImportFile;
  end;

var
  zViewerSynEditFrame: TzViewerSynEditFrame;

implementation

uses
  Xml.XMLDoc,
  System.StrUtils,
  System.JSON,
  zDX,
  zOffice.MultiViewer,
  zOffice.utils,
  zOffice;
{$R *.dfm}

constructor TzViewerSynEditFrame.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FFileName := '';
  FFileType := ftNone;
  FilesDefaultExt := '';
  FilesFilter := '';
  FOnImportFile := nil;
  FIsEmbedded := assigned(aOwner) and (aOwner is TzMultiViewer);

  IsScrolling := False;
  HScrollBar.Margins.Right := VScrollBar.Width; // quadrato libero in basso a dx

  RootLookAndFeel.AddChangeListener(self);

  SetEditorColors;
  Editor.readonly := true;
  Editor.UseCodeFolding := true;

  // Importa.Dialog.DefaultExt := '*.xlsx';
  // Importa.Dialog.Filter := FilterForFileTypes(ftExcel);
end;

destructor TzViewerSynEditFrame.Destroy;
begin
  RootLookAndFeel.RemoveChangeListener(self);
  inherited;
end;

procedure TzViewerSynEditFrame.EditorStatusChange(sender: TObject; Changes: TSynStatusChanges);
const
  Modi: array [boolean] of string[10] = ('', 'Modified');
  Modes: array [boolean] of string[10] = ('Overwrite', 'Insert');
begin
  StatusBar.Panels[0].Text := IntToStr(Editor.CaretY) + ':' + IntToStr(Editor.CaretX);

  SetScrollbarsRange;
end;

procedure TzViewerSynEditFrame.actOpzioniEditorExecute(sender: TObject);
var
  SynEditorOptionsContainer: TSynEditorOptionsContainer;
begin
  SynEditorOptionsContainer := TSynEditorOptionsContainer.Create(self);
  try
    SynEditorOptionsContainer.Assign(Editor);
    if SynEditOptionsDialog.Execute(SynEditorOptionsContainer) then
      SynEditorOptionsContainer.AssignTo(Editor);
  finally
    FreeAndNil(SynEditorOptionsContainer);
  end;
end;

procedure TzViewerSynEditFrame.actTrovaExecute(sender: TObject);
begin
  if Editor.SelText <> '' then
    FindDialog.FindText := Editor.SelText
  else
    FindDialog.FindText := Editor.WordAtCursor;

  FindDialog.Execute;
end;

procedure TzViewerSynEditFrame.DoFindText(sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := FindDialog.FindText;

  if Length(sSearch) = 0 then
  begin
    Beep;
  end
  else
  begin
    rOptions := [];
    if not(frDown in FindDialog.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in FindDialog.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in FindDialog.Options then
      Include(rOptions, ssoWholeWord);
    if Editor.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
    end;
  end;
end;

function TzViewerSynEditFrame.GetObject: TObject;
begin
  // IcxLookAndFeelNotificationListener
  result := self;
end;

procedure TzViewerSynEditFrame.SetScrollbarsRange;
begin
  if IsScrolling then
    exit;

  try
    if HScrollBar.Position <> Editor.CaretX - 1 then
      HScrollBar.Position := Editor.CaretX - 1;

    if VScrollBar.Position <> Editor.CaretY - 1 then
      VScrollBar.Position := Editor.CaretY - 1;

    if VScrollBar.Max <> Editor.Lines.Count then
      VScrollBar.Max := Editor.Lines.Count;
  except
    // in caso di chiusura etc
  end;
end;

procedure TzViewerSynEditFrame.VScrollBarScroll(sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  try
    if Editor.TopLine <> ScrollPos then
    begin
      IsScrolling := true;
      try
        Editor.TopLine := ScrollPos;
        Editor.UpdateCarets;
      finally
        IsScrolling := False;
      end;
    end;
  except
  end;
end;

procedure TzViewerSynEditFrame.HScrollBarScroll(sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  try
    if Editor.LeftChar <> ScrollPos then
    begin
      IsScrolling := true;
      try
        Editor.LeftChar := ScrollPos;
        Editor.UpdateCarets;
      finally
        IsScrolling := False;
      end;
    end;
  except
  end;
end;

procedure TzViewerSynEditFrame.MasterLookAndFeelChanged(sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  // IcxLookAndFeelNotificationListener
  SetEditorColors;
end;

procedure TzViewerSynEditFrame.MasterLookAndFeelDestroying(sender: TcxLookAndFeel);
begin
  // IcxLookAndFeelNotificationListener
end;

procedure TzViewerSynEditFrame.SetAllowedImportFileTypes(FileTypes: TzFileTypes);
begin
  // se impostato da zOffice.MultiViewer
  Importa.dialog.Filter := FilterForFileTypes(FileTypes);
end;

procedure TzViewerSynEditFrame.SetEditorColors;
var
  painter: TcxCustomLookAndFeelPainter;
begin
  // painter attivo al momento della chiamata: niente snapshot da dx.cxStyle*,
  // che viene calcolato una volta sola e non segue i cambi di skin
  painter := RootLookAndFeel.Painter;

  // area di testo: i token con Background = clNone ricadono su Editor.Color
  Editor.Color := painter.DefaultEditorBackgroundColor(false);
  Editor.Font.Color := painter.DefaultEditorTextColor(false);

  // selezione
  Editor.SelectedColor.Background := painter.DefaultSelectionColor;
  Editor.SelectedColor.Foreground := painter.DefaultSelectionTextColor;

  // gutter: con Gradient attivo Color viene ignorato
  Editor.Gutter.Gradient := false;
  Editor.Gutter.Color := painter.DefaultControlColor;
  Editor.Gutter.BorderColor := painter.DefaultHeaderColor;
  Editor.Gutter.Font.Color := painter.DefaultControlTextColor;
  Editor.Gutter.UseFontStyle := true;

  Editor.Invalidate;
end;

function TzViewerSynEditFrame.Empty: boolean;
begin
  result := Editor.Lines.Count = 0;
end;

procedure TzViewerSynEditFrame.Clear;
begin
  Editor.Lines.Clear;
end;

procedure TzViewerSynEditFrame.ImportaAccept(sender: TObject);
begin
  if assigned(FOnImportFile) then
    OnImportFile(self, Importa.dialog.FileName);
end;

procedure TzViewerSynEditFrame.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := assigned(FOnImportFile);
end;

procedure TzViewerSynEditFrame.ImportaBeforeExecute(sender: TObject);
begin
  Importa.dialog.DefaultExt := FilesDefaultExt;

  if not IsEmbedded then // altrimenti impostato da SetAllowedImportFileTypes
    Importa.dialog.Filter := FilesFilter;
end;

procedure TzViewerSynEditFrame.SalvaSuFileBeforeExecute(sender: TObject);
begin
  SalvaSuFile.dialog.DefaultExt := FilesDefaultExt;
  SalvaSuFile.dialog.Filter := FilesFilter;
end;

procedure TzViewerSynEditFrame.SalvaSuFileAccept(sender: TObject);
begin
  SaveToFile(SalvaSuFile.dialog.FileName);
end;

procedure TzViewerSynEditFrame.SaveToFile(const FileName: string);
begin
  Editor.Lines.SaveToFile(FileName);
end;

procedure TzViewerSynEditFrame.OpenFile(const FileName: string);
var
  ext: string;
begin

  if FileName.IsEmpty then
    CloseFile
  else
  begin
    FFileName := FileName;

    Editor.Lines.LoadFromFile(FileName);
    Editor.SelStart := 0;
    Editor.Modified := true;

    ext := ExtractFileExt(FileName);

    if sameText(ext, '.xml') then
      FFileType := ftXML
    else
      if sameText(ext, '.json') then
        FFileType := ftJSON
      else
        if sameText(ext, '.txt') then
          FFileType := ftTXT
        else
          FFileType := ftTXT;

    case FileType of
      ftNone:
        begin
          FilesDefaultExt := '*.*';
          FilesFilter := 'Tutti|*.*';
          Editor.Highlighter := nil;
        end;
      ftTXT:
        begin
          FilesDefaultExt := '*.txt';
          FilesFilter := 'Testo|*.txt|Tutti|*.*';
          Editor.Highlighter := nil;
        end;
      ftXML:
        begin
          FilesDefaultExt := '*.xml';
          FilesFilter := 'File xml|*.xml|Tutti|*.*';
          Editor.Highlighter := SynXMLSyn;
        end;
      ftJSON:
        begin
          FilesDefaultExt := '*.json';
          FilesFilter := 'File json|*.json|Tutti|*.*';
          Editor.Highlighter := SynJSONSyn;
        end;
    end;
  end;
end;

procedure TzViewerSynEditFrame.CloseFile;
begin
  Clear;
  FFileName := '';
  FFileType := ftNone;
end;

procedure TzViewerSynEditFrame.Print;
begin
  SynEditPrint.SynEdit := Editor;

  if PrintDialog.Execute then
    SynEditPrint.Print
end;

procedure TzViewerSynEditFrame.StampaExecute(sender: TObject);
begin
  Print;
end;

procedure TzViewerSynEditFrame.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(self, 'SetFileName');

  if not FileExists(Value) then
    CloseFile
  else
    OpenFile(Value);

  SiMain.LeaveMethod(self, 'SetFileName');
end;

procedure TzViewerSynEditFrame.ApriExecute(sender: TObject);
begin
  if FileExists(FileName) then
    ViewFile(FileName);
end;

procedure TzViewerSynEditFrame.FormattaUpdate(sender: TObject);
begin
  Formatta.Visible := FileType in [ftXML, ftJSON];
end;

procedure TzViewerSynEditFrame.FormattaExecute(sender: TObject);

  function FormatXML(const Xml: string): String;
  begin
    result := FormatXMLData(Xml);
  end;

  function FormatJSON(const JSON: string): String;
  var
    j: TJSONValue;
  begin
    j := TJSONObject.ParseJSONValue(JSON);
    try
      result := j.format(4);
    finally
      FreeAndNil(j);
    end;
  end;

begin
  case FileType of
    ftXML:
      Editor.Lines.Text := FormatXML(Editor.Lines.Text);
    ftJSON:
      Editor.Lines.Text := FormatJSON(Editor.Lines.Text);
  end;
end;

end.


zz.SmartInspect
