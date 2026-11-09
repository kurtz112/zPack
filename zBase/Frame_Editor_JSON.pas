unit Frame_Editor_JSON;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Actions,
  System.ImageList,
  System.JSON,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.ActnMan,
  Vcl.ToolWin,
  Vcl.Grids,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.StdActns,
  Vcl.ActnList,

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

  SynEdit,
  SynFunc,
  SynEditTypes,
  SynEditHighlighter,
  SynEditOptionsDialog,
  SynEditMiscClasses,
  SynEditRegexSearch,
  SynEditPlugins,
  SynMacroRecorder,
  SynEditCodeFolding,
  SynHighlighterJSON;

type
  TFrameEditor_JSON = class(TFrame, IcxLookAndFeelNotificationListener)
    Splitter: TcxSplitter;
    Log: TcxMemo;
    PanelEditor: TPanel;
    StatusBar: TdxStatusBar;
    Editor: TSynEdit;
    SynEditOptionsDialog: TSynEditOptionsDialog;
    ActionList: TActionList;
    actAnnulla: TEditUndo;
    actRipristina: TAction;
    actTaglia: TEditCut;
    actCopia: TEditCopy;
    actIncolla: TEditPaste;
    actSelezionaTutto: TEditSelectAll;
    actElimina: TEditDelete;
    actTrova: TAction;
    actSostituisci: TAction;
    CaricaDalFile: TdxFileOpen;
    SalvaSuFile: TdxFileSaveAs;
    actOpzioniEditor: TAction;
    DuplicaLinea: TAction;
    Maiuscolo: TAction;
    Minuscolo: TAction;
    FindDialog: TFindDialog;
    ReplaceDialog: TReplaceDialog;
    SynEditRegexSearch: TSynEditRegexSearch;
    VScrollBar: TcxScrollBar;
    HScrollBar: TcxScrollBar;
    FormatJSON: TAction;
    dxBarManager: TdxBarManager;
    dxBarPopupMenu: TdxBarPopupMenu;
    Prepara1: TdxBarButton;
    Annulla1: TdxBarButton;
    Ripristina1: TdxBarButton;
    Cut1: TdxBarButton;
    Copy1: TdxBarButton;
    Paste1: TdxBarButton;
    Elimina1: TdxBarButton;
    SelectAll1: TdxBarButton;
    FormatSQL1: TdxBarButton;
    DuplicaLinea1: TdxBarButton;
    Maiuscolo1: TdxBarButton;
    Minuscolo1: TdxBarButton;
    Find1: TdxBarButton;
    Searchagain1: TdxBarButton;
    CaricadaFile1: TdxBarButton;
    SalvasuFile1: TdxBarButton;
    EditorOptions1: TdxBarButton;
    dxBarButton1: TdxBarButton;
    dxBarManagerBar1: TdxBar;
    dxBarButton2: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxBarButton11: TdxBarButton;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    dxBarButton15: TdxBarButton;
    CompletionImageList: TcxImageList;
    dxBarButton16: TdxBarButton;
    SynJSONSyn: TSynJSONSyn;
    VerificaJSON: TAction;
    procedure actRipristinaExecute(Sender: TObject);
    procedure EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure actOpzioniEditorExecute(Sender: TObject);
    procedure actRipristinaUpdate(Sender: TObject);
    procedure CaricaDalFileBeforeExecute(Sender: TObject);
    procedure CaricaDalFileAccept(Sender: TObject);
    procedure SalvaSuFileAccept(Sender: TObject);
    procedure actTrovaExecute(Sender: TObject);
    procedure actSostituisciExecute(Sender: TObject);
    procedure DoFindText(Sender: TObject);
    procedure DoReplaceText(Sender: TObject);
    procedure SalvaSuFileBeforeExecute(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure DuplicaLineaExecute(Sender: TObject);
    procedure EditorScanForFoldRanges(Sender: TObject; FoldRanges: TSynFoldRanges; LinesToScan: TStrings; FromLine, ToLine: Integer);
    procedure EditorSpecialLineColors(Sender: TObject; Line: TSynNativeInt; var Special: Boolean; var FG, BG: TColor);
    procedure FormatJSONExecute(Sender: TObject);
    procedure FormatJSONUpdate(Sender: TObject);
    procedure HScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure MaiuscoloExecute(Sender: TObject);
    procedure MinuscoloExecute(Sender: TObject);
    procedure VerificaJSONUpdate(Sender: TObject);
    procedure VScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
  private
    ErrorLine: Integer;
    FOnChange: TNotifyEvent;
    FilesDefaultExt: string;
    FilesFilter: string;
    // ridimensionamento manuale del log: quando true CalcLogHeight non tocca piu' l'altezza
    LogHeightManuale: Boolean;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetJSON: string;
    procedure SetJSON(const Value: string);
    procedure CalcLogHeight;
    procedure SetScrollbarsRange;
    procedure SplitterMoved(Sender: TObject);
    procedure AggiornaScrollbarLog;
  private
    function tryParseJSON(out JSONValue: TJSONValue): Boolean;
    function doFormat: Boolean;
    function doVerifica: Boolean;
  private
    procedure SetReadOnly(const Value: Boolean);
    procedure VisualizzaLog(const visibile: Boolean);
  private
    FReadOnly: Boolean;
    IsScrolling: Boolean;
  protected
    function GetObject: TObject;
    procedure MasterLookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
    procedure MasterLookAndFeelDestroying(Sender: TcxLookAndFeel);
    procedure SetEditorColors;
  public
    procedure DisplayException(e: exception);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    property JSON: string read GetJSON write SetJSON;
  public
  public
    procedure InsertTextAtCaret(const s: string);
    procedure InsertTextAtPos(x, y: Integer; const s: string);
    function Empty: Boolean;
    procedure Clear;
    procedure ClearLog;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
  published
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default false;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;

var
  FrameEditor_JSON: TFrameEditor_JSON;

implementation

uses
  System.StrUtils,
  zdx,
  zMsg;
{$R *.dfm}

type
  TSynEditAccess = class(TSynEdit)
  public
    procedure InsertBlock(BB, BE: TBufferCoord; aText: String);
    procedure InsertTextAtCaret(aText: String);
    procedure InsertTextAtPos(const x, y: Integer; aText: String);
  end;

  TSQLCompInfo = record
    Token: string;
    Comp: string;
  end;

const
  FIELDSFORMAT = '\image{%d} \color{clNavy}Field\color{clBlack} \style{+B}%s\style{-B} %s';
  SQLITEMSTR = 'SQL \style{+B}%s\style{-B}';

  SQLComp: array [0 .. 14] of TSQLCompInfo = ((Token: 'GEN_ID'; Comp: '"<generator>,", "<step>"'), (Token: 'CAST'; Comp: '"<value> AS <datatype>"'), (Token: 'DECIMAL'; Comp: '"<precision>,", "<scale>"'), (Token: 'NUMERIC';
    Comp: '"<precision>,", "<scale>"'), (Token: 'CHAR'; Comp: '"<count>"'), (Token: 'VARCHAR'; Comp: '"<count>"'), (Token: 'CSTRING'; Comp: '"<count>"'), (Token: 'AVG'; Comp: '"[ALL] <value>"'#13'"DISTINCT <value>"'), (Token: 'MAX';
    Comp: '"[ALL] <value>"'#13'"DISTINCT <value>"'), (Token: 'MIN'; Comp: '"[ALL] <value>"'#13'"DISTINCT <value>"'), (Token: 'SUM'; Comp: '"[ALL] <value>"'#13'"DISTINCT <value>"'), (Token: 'COUNT';
    Comp: '"*"'#13'"[ALL] <value>"'#13'"DISTINCT <value>"'), (Token: 'UPPER'; Comp: '"<string expr>"'), (Token: 'EXTRACT'; Comp: '"part FROM value"'), (Token: 'SUBSTRING'; Comp: '"<string expr> FROM <pos> [FOR <length>]"'));

  SQLToKens: array [0 .. 254] of string = ('ACTION', 'ACTIVE', 'ADD', 'ADMIN', 'AFTER', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'ASCENDING', 'AT', 'AUTO', 'AVG', 'BACKUP', 'BASE_NAME', 'BEFORE', 'BEGIN', 'BETWEEN', 'BIGINT', 'BLOB', 'BOOLEAN',
    'BREAK', 'BY', 'CACHE', 'CASCADE', 'CASE', 'CAST', 'CHAR', 'CHARACTER', 'CHECK', 'CHECK_POINT_LENGTH', 'CLOSE', 'COALESCE', 'COLLATE', 'COLUMN', 'COMMIT', 'COMMITTED', 'COMPUTED', 'CONDITIONAL', 'CONSTRAINT', 'CONTAINING', 'COUNT', 'CREATE',
    'CSTRING', 'CURRENT', 'CURRENT_CONNECTION', 'CURRENT_DATE', 'CURRENT_ROLE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_TRANSACTION', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DATE', 'DAY', 'DEBUG', 'DEC', 'DECIMAL', 'DECLARE', 'DEFAULT',
    'DELETE', 'DELETING', 'DESC', 'DESCENDING', 'DESCRIPTOR', 'DIFFERENCE', 'DISTINCT', 'DO', 'DOMAIN', 'DOUBLE', 'DROP', 'ELSE', 'END', 'ENTRY_POINT', 'ESCAPE', 'EXCEPTION', 'EXECUTE', 'EXISTS', 'EXIT', 'EXTERNAL', 'EXTRACT', 'FALSE', 'FETCH',
    'FILE', 'FILTER', 'FIRST', 'FLOAT', 'FOR', 'FOREIGN', 'FREE_IT', 'FROM', 'FULL', 'FUNCTION', 'GDSCODE', 'GENERATOR', 'GEN_ID', 'GLOBAL', 'GRANT', 'GROUP', 'GROUP_COMMIT_WAIT_TIME', 'HAVING', 'HOUR', 'IF', 'IN', 'INACTIVE', 'INDEX', 'INNER',
    'INPUT_TYPE', 'INSERT', 'INSERTING', 'INT', 'INTEGER', 'INTO', 'IS', 'ISOLATION', 'JOIN', 'KEY', 'LAST', 'LEAVE', 'LEFT', 'LENGTH', 'LEVEL', 'LIKE', 'LOGFILE', 'LOG_BUFFER_SIZE', 'LONG', 'MANUAL', 'MAX', 'MAXIMUM_SEGMENT', 'MERGE', 'MESSAGE',
    'MIN', 'MINUTE', 'MODULE_NAME', 'MONTH', 'NAMES', 'NATIONAL', 'NATURAL', 'NCHAR', 'NO', 'NOT', 'NULLIF', 'NULL', 'NULLS', 'LOCK', 'NUMERIC', 'NUM_LOG_BUFFERS', 'OF', 'ON', 'ONLY', 'OPEN', 'OPTION', 'OR', 'ORDER', 'OUTER', 'OUTPUT_TYPE',
    'OVERFLOW', 'PAGE', 'PAGES', 'PAGE_SIZE', 'PARAMETER', 'PASSWORD', 'PERCENT', 'PLAN', 'POSITION', 'POST_EVENT', 'PRECISION', 'PRIMARY', 'PRIVILEGES', 'PROCEDURE', 'PROTECTED', 'RAW_PARTITIONS', 'RDB$DB_KEY', 'PRESERVE', 'READ', 'REAL',
    'RECORD_VERSION', 'RECREATE', 'REFERENCES', 'RELEASE', 'RESERV', 'RESERVING', 'RESTRICT', 'RETAIN', 'RETURNING_VALUES', 'RETURNS', 'REVOKE', 'RIGHT', 'ROLE', 'ROLLBACK', 'ROW_COUNT', 'ROWS', 'SAVEPOINT', 'SCHEMA', 'SECOND', 'SEGMENT', 'SELECT',
    'SET', 'SHADOW', 'SHARED', 'SINGULAR', 'SIZE', 'SKIP', 'SMALLINT', 'SNAPSHOT', 'SOME', 'SORT', 'SQLCODE', 'STABILITY', 'STARTING', 'STARTS', 'zFbDataSet', 'STATISTICS', 'SUBSTRING', 'SUB_TYPE', 'SUM', 'SUSPEND', 'TABLE', 'TEMPORARY', 'THEN',
    'TIES', 'TIME', 'TIMESTAMP', 'TO', 'TRANSACTION', 'TRIGGER', 'TRUE', 'TYPE', 'UNCOMMITTED', 'UNION', 'UNIQUE', 'UPDATE', 'UPDATING', 'UPPER', 'USER', 'USING', 'VALUE', 'VALUES', 'VARCHAR', 'VARIABLE', 'VARYING', 'VIEW', 'WAIT', 'WEEKDAY', 'WHEN',
    'WHERE', 'WHILE', 'WITH', 'WORK', 'WRITE', 'YEAR', 'YEARDAY');

constructor TFrameEditor_JSON.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FReadOnly := false;
  IsScrolling := false;
  ErrorLine := -1;

  FilesDefaultExt := '';
  FilesFilter := '';
  FOnChange := nil;

  Editor.Highlighter := SynJSONSyn;
  Editor.UseCodeFolding := true;

  FilesDefaultExt := '*.json';
  FilesFilter := 'JSON|*.json|Tutti|*.*';

  VisualizzaLog(false);

  // log ridimensionabile tramite lo splitter; la hot zone lo comprime/espande
  Splitter.Control := Log;
  Splitter.MinSize := 40;
  Splitter.OnMoved := SplitterMoved;

  // le righe lunghe scorrono in orizzontale invece di andare a capo
  Log.Properties.WordWrap := false;
  LogHeightManuale := false;

  HScrollBar.Margins.Right := VScrollBar.Width; // quadrato libero in basso a dx

  SetEditorColors;
  RootLookAndFeel.AddChangeListener(self);

  // Editor.CodeFolding.Enabled := True;
  // Editor.CodeFolding.FolderBarColor := clBtnFace;
  // Editor.CodeFolding.HighlighterFoldRegions := False;
  // Editor.CodeFolding.CollapsedCodeHint := True;
  // Editor.CodeFolding.FoldRegions.Add(
  // rtKeyWord,
  // false,
  // false,
  // true,
  // 'begin',
  // 'end',
  // nil);

  // Editor.CodeFolding.FoldRegions.Add(
  // rtKeyWord,
  // false,
  // false,
  // true,
  // 'select',
  // 'into',
  // nil);
  //
  // Editor.InitCodeFolding;
end;

destructor TFrameEditor_JSON.Destroy;
begin
  RootLookAndFeel.RemoveChangeListener(self);
  inherited;
end;

procedure TFrameEditor_JSON.actRipristinaUpdate(Sender: TObject);
begin
  actRipristina.Enabled := Editor.CanRedo;
end;

procedure TFrameEditor_JSON.actRipristinaExecute(Sender: TObject);
begin
  if Editor.CanRedo then
    Editor.Redo;
end;

procedure TFrameEditor_JSON.EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
const
  Modi: array [Boolean] of string[10] = ('', 'Modified');
  Modes: array [Boolean] of string[10] = ('Overwrite', 'Insert');
begin
  StatusBar.Panels[0].Text := IntToStr(Editor.CaretY) + ':' + IntToStr(Editor.CaretX);
  StatusBar.Panels[1].Text := Modi[Editor.Modified];

  if Editor.ReadOnly then
    StatusBar.Panels[2].Text := 'ReadOnly'
  else
    StatusBar.Panels[2].Text := Modes[Editor.InsertMode];

  SetScrollbarsRange;
end;

procedure TFrameEditor_JSON.actOpzioniEditorExecute(Sender: TObject);
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

procedure TFrameEditor_JSON.CaricaDalFileBeforeExecute(Sender: TObject);
begin
  if Editor.Modified then
    if not ConfirmYesNo('Il testo � stato variato.' + #13 + #10 + 'Continuare perdendo le modifiche?', mtWarning) then
      System.SysUtils.Abort;

  CaricaDalFile.Dialog.DefaultExt := FilesDefaultExt;
  CaricaDalFile.Dialog.Filter := FilesFilter;
end;

procedure TFrameEditor_JSON.CaricaDalFileAccept(Sender: TObject);
begin
  LoadFromFile(CaricaDalFile.Dialog.FileName);
end;

procedure TFrameEditor_JSON.SalvaSuFileAccept(Sender: TObject);
begin
  SaveToFile(SalvaSuFile.Dialog.FileName);
end;

procedure TFrameEditor_JSON.actTrovaExecute(Sender: TObject);
begin
  if Editor.SelText <> '' then
    FindDialog.FindText := Editor.SelText
  else
    FindDialog.FindText := Editor.WordAtCursor;

  FindDialog.Execute;
end;

procedure TFrameEditor_JSON.actSostituisciExecute(Sender: TObject);
begin
  if Editor.SelText <> '' then
    ReplaceDialog.FindText := Editor.SelText
  else
    ReplaceDialog.FindText := Editor.WordAtCursor;

  ReplaceDialog.Execute;
end;

procedure TFrameEditor_JSON.DoFindText(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog then
    dlg := ReplaceDialog
  else
    dlg := FindDialog;
  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
  end
  else
  begin
    rOptions := [];
    if not(frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if Editor.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
    end;
  end;
end;

procedure TFrameEditor_JSON.DoReplaceText(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
  end
  else
  begin
    rOptions := [ssoEntireScope, ssoReplace];
    if frMatchCase in ReplaceDialog.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog.Options then
      Include(rOptions, ssoReplaceAll);
    if Editor.SearchReplace(sSearch, ReplaceDialog.ReplaceText, rOptions) = 0 then
    begin
      Beep;
    end;
  end;
end;

procedure TFrameEditor_JSON.SalvaSuFileBeforeExecute(Sender: TObject);
begin
  SalvaSuFile.Dialog.DefaultExt := FilesDefaultExt;
  SalvaSuFile.Dialog.Filter := FilesFilter;
end;

procedure TFrameEditor_JSON.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TFrameEditor_JSON.EditorChange(Sender: TObject);
begin
  // Editor.ReScanForFoldRanges;
  ErrorLine := -1;

  if Assigned(FOnChange) then
  begin
    try
      OnChange(Sender);
    except
      on e: exception do
        ApplicationShowException(e);
    end;
  end
end;

procedure TFrameEditor_JSON.DuplicaLineaExecute(Sender: TObject);
begin
  if Editor.CaretY > 0 then
    Editor.Lines.Insert(Editor.CaretY, Editor.Lines[Editor.CaretY - 1]);
end;

procedure TFrameEditor_JSON.MaiuscoloExecute(Sender: TObject);
var
  oldSelStart: Integer;
  oldSelLength: Integer;
begin
  if Editor.SelText = '' then
    Editor.Text := UpperCase(Editor.Text)
  else
  begin
    oldSelStart := Editor.SelStart;
    oldSelLength := Editor.SelLength;
    Editor.SelText := UpperCase(Editor.SelText);
    Editor.SelStart := oldSelStart;
    Editor.SelLength := oldSelLength;
  end;
end;

procedure TFrameEditor_JSON.MinuscoloExecute(Sender: TObject);
var
  oldSelStart: Integer;
  oldSelLength: Integer;
begin
  if Editor.SelText = '' then
    Editor.Text := LowerCase(Editor.Text)
  else
  begin
    oldSelStart := Editor.SelStart;
    oldSelLength := Editor.SelLength;
    Editor.SelText := LowerCase(Editor.SelText);
    Editor.SelStart := oldSelStart;
    Editor.SelLength := oldSelLength;
  end;
end;

procedure TFrameEditor_JSON.CalcLogHeight;
var
  Lines: Integer;
  canvas: TcxScreenCanvas;
  desiredHeight: Integer;
  maxHeight: Integer;
begin
  // dopo un ridimensionamento manuale l'altezza scelta dall'utente va rispettata
  if LogHeightManuale then
  begin
    AggiornaScrollbarLog;
    exit;
  end;

  Lines := SendMessage(Log.InnerControl.Handle, EM_GETLINECOUNT, 0, 0);
  canvas := TcxScreenCanvas.Create();
  try
    canvas.Font := Log.Style.Font;
    desiredHeight := 20 + canvas.TextHeight('Wg') * Lines;
  finally
    canvas.Free;
  end;

  // oltre meta' del frame si scorre con la scrollbar
  maxHeight := Height div 2;
  if desiredHeight > maxHeight then
    desiredHeight := maxHeight;

  Log.Height := desiredHeight;

  AggiornaScrollbarLog;
end;

procedure TFrameEditor_JSON.SplitterMoved(Sender: TObject);
begin
  LogHeightManuale := true;
  AggiornaScrollbarLog;
end;

// mostra solo le scrollbar effettivamente necessarie per il contenuto corrente
procedure TFrameEditor_JSON.AggiornaScrollbarLog;
var
  canvas: TcxScreenCanvas;
  lineHeight: Integer;
  lineWidth: Integer;
  maxLineWidth: Integer;
  i: Integer;
  needVertical: Boolean;
  needHorizontal: Boolean;
  newScrollBars: TScrollStyle;
begin
  canvas := TcxScreenCanvas.Create();
  try
    canvas.Font := Log.Style.Font;
    lineHeight := canvas.TextHeight('Wg');

    maxLineWidth := 0;
    for i := 0 to Log.Lines.Count - 1 do
    begin
      lineWidth := canvas.TextWidth(Log.Lines[i]);
      if lineWidth > maxLineWidth then
        maxLineWidth := lineWidth;
    end;
  finally
    canvas.Free;
  end;

  needVertical := Log.Lines.Count * lineHeight > Log.InnerControl.ClientHeight;
  needHorizontal := maxLineWidth > Log.InnerControl.ClientWidth;

  if needVertical and needHorizontal then
    newScrollBars := ssBoth
  else if needVertical then
    newScrollBars := ssVertical
  else if needHorizontal then
    newScrollBars := ssHorizontal
  else
    newScrollBars := ssNone;

  // cambiare ScrollBars ricrea la finestra del memo: solo se serve davvero
  if Log.Properties.ScrollBars <> newScrollBars then
    Log.Properties.ScrollBars := newScrollBars;
end;

procedure TFrameEditor_JSON.DisplayException(e: exception);

  procedure MoveCaret2Error(const msg: string);
  const
    TokenForLine = 'At line ';
    TokenForColumn = ', column ';
  var
    x, y: Integer;
    s, Token: string;
    i: Integer;

    function Cut(const s: string; const Token: string): string;
    begin
      if SameText(Token, System.copy(s, 0, Length(Token))) then
        result := System.copy(s, Length(Token) + 1, Length(s) - Length(Token));
    end;

  begin
    x := 1;
    y := 1;

    s := msg;

    i := AnsiPos(TokenForLine, s);
    if i = 0 then
      exit;

    // taglia la parte iniziale
    s := System.copy(s, i, Length(s) - 1);
    /// ///////////////////////////////////////////////////////////////////////

    // estrae la linea
    s := Cut(s, TokenForLine);
    Token := System.copy(s, 1, Pos(',', s) - 1);

    if TryStrToInt(Trim(Token), y) then
    begin
      Editor.CaretY := y;
      ErrorLine := y;
    end;
    /// ///////////////////////////////////////////////////////////////////////

    s := Cut(s, Token); // la Y
    s := Cut(s, TokenForColumn);

    Token := System.copy(s, 1, Pos('.', s) - 1);

    if TryStrToInt(Trim(Token), x) then
      Editor.CaretX := x;
  end;

begin
  VisualizzaLog(true);
  Log.Lines.Text := e.Message;
  CalcLogHeight;
  MoveCaret2Error(e.Message);
  Editor.Invalidate;
  try
    Editor.SetFocus;
  except
  end;
end;

function TFrameEditor_JSON.GetJSON: string;
begin
  result := Editor.Lines.Text;
end;

procedure TFrameEditor_JSON.SetJSON(const Value: string);
begin
  Editor.Lines.Text := Value;
  ErrorLine := -1;
  Log.Lines.Clear;

  SetScrollbarsRange;
end;

function TFrameEditor_JSON.GetObject: TObject;
begin
  // IcxLookAndFeelNotificationListener
  result := self;
end;

procedure TFrameEditor_JSON.SetScrollbarsRange;
begin
  if IsScrolling then
    exit;

  if HScrollBar.Position <> Editor.CaretX - 1 then
    HScrollBar.Position := Editor.CaretX - 1;

  if VScrollBar.Position <> Editor.CaretY - 1 then
    VScrollBar.Position := Editor.CaretY - 1;

  if VScrollBar.Max <> Editor.Lines.Count then
    VScrollBar.Max := Editor.Lines.Count;
end;

procedure TFrameEditor_JSON.VScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if Editor.TopLine <> ScrollPos then
  begin
    IsScrolling := true;
    try
      Editor.TopLine := ScrollPos;
      Editor.UpdateCarets;
    finally
      IsScrolling := false;
    end;
  end;
end;

procedure TFrameEditor_JSON.HScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if Editor.LeftChar <> ScrollPos then
  begin
    IsScrolling := true;
    try
      Editor.LeftChar := ScrollPos;
      Editor.UpdateCarets;
    finally
      IsScrolling := false;
    end;
  end;
end;

procedure TFrameEditor_JSON.MasterLookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  // IcxLookAndFeelNotificationListener
  SetEditorColors;
end;

procedure TFrameEditor_JSON.MasterLookAndFeelDestroying(Sender: TcxLookAndFeel);
begin
  // IcxLookAndFeelNotificationListener
end;

procedure TFrameEditor_JSON.SetEditorColors;
var
  painter: TcxCustomLookAndFeelPainter;
  Sfondo: TColor;
  Testo: TColor;

  // Mantis #274 - 2026-10-22: stessa regola di Frame_Editor_SQL. Senza skin il
  // painter standard risponde clDefault (o clNone) per molti colori, e SynEdit
  // disegna clDefault nero: in quel caso si usa il colore di sistema
  function ColoreValido(Colore, Sostituto: TColor): TColor;
  begin
    if (Colore = clDefault) or (Colore = clNone) then
      Colore := Sostituto;

    Result := ColorToRGB(Colore);
  end;

  // Mantis #274 - 2026-10-22: luminosita' percepita di un colore, da 0 a 255
  function Luminosita(Colore: TColor): Integer;
  begin
    Colore := ColorToRGB(Colore);
    Result := (GetRValue(Colore) * 299 + GetGValue(Colore) * 587 + GetBValue(Colore) * 114) div 1000;
  end;

  // Mantis #274 - 2026-10-22: con il tema scuro di Windows il painter nativo
  // restituisce colori veri ma illeggibili insieme (sfondo nero, testo nero), e
  // ColoreValido non se ne accorge perche' nessuno dei due e' clDefault. Sotto
  // la differenza di luminosita' di 125 (soglia W3C) si scarta la coppia intera
  // e si usa quella di sistema, che Windows tiene sempre leggibile. Una skin
  // scura vera (sfondo scuro, testo chiaro) supera la soglia e resta com'e'
  procedure CoppiaLeggibile(var ColoreSfondo, ColoreTesto: TColor; SfondoSistema, TestoSistema: TColor);
  begin
    if Abs(Luminosita(ColoreSfondo) - Luminosita(ColoreTesto)) < 125 then
    begin
      ColoreSfondo := ColorToRGB(SfondoSistema);
      ColoreTesto := ColorToRGB(TestoSistema);
    end;
  end;

begin
  // painter attivo al momento della chiamata: niente snapshot da dx.cxStyle*,
  // che viene calcolato una volta sola e non segue i cambi di skin
  painter := RootLookAndFeel.Painter;

  // area di testo: i token con Background = clNone ricadono su Editor.Color
  Sfondo := ColoreValido(painter.DefaultEditorBackgroundColor(false), clWindow);
  Testo := ColoreValido(painter.DefaultEditorTextColor(false), clWindowText);
  CoppiaLeggibile(Sfondo, Testo, clWindow, clWindowText);
  Editor.Color := Sfondo;
  Editor.Font.Color := Testo;

  // selezione
  Sfondo := ColoreValido(painter.DefaultSelectionColor, clHighlight);
  Testo := ColoreValido(painter.DefaultSelectionTextColor, clHighlightText);
  CoppiaLeggibile(Sfondo, Testo, clHighlight, clHighlightText);
  Editor.SelectedColor.Background := Sfondo;
  Editor.SelectedColor.Foreground := Testo;

  // gutter: con Gradient attivo Color viene ignorato
  Editor.Gutter.Gradient := false;
  Sfondo := ColoreValido(painter.DefaultControlColor, clBtnFace);
  Testo := ColoreValido(painter.DefaultControlTextColor, clGrayText);
  CoppiaLeggibile(Sfondo, Testo, clBtnFace, clBtnText);
  Editor.Gutter.Color := Sfondo;
  Editor.Gutter.Font.Color := Testo;
  Editor.Gutter.BorderColor := ColoreValido(painter.DefaultHeaderColor, clBtnShadow);
  Editor.Gutter.UseFontStyle := true;

  // pannello log (readonly: variante "disabled"). E' un controllo DevExpress,
  // per cui clDefault vuol dire "colore del painter" e va lasciato: si
  // sostituisce la coppia solo quando e' illeggibile
  Sfondo := painter.DefaultEditorBackgroundColor(true);
  Testo := painter.DefaultEditorTextColor(true);
  if Abs(Luminosita(ColoreValido(Sfondo, clBtnFace)) - Luminosita(ColoreValido(Testo, clGrayText))) < 125 then
  begin
    Sfondo := clWindow;
    Testo := clWindowText;
  end;
  Log.Style.Color := Sfondo;
  Log.Style.Font.Color := Testo;

  Editor.Invalidate;
end;

function TFrameEditor_JSON.Empty: Boolean;
begin
  result := Editor.Lines.Count = 0;
end;

procedure TFrameEditor_JSON.Clear;
begin
  Editor.Lines.Clear;
end;

procedure TFrameEditor_JSON.ClearLog;
begin
  Log.Clear;
end;

procedure TFrameEditor_JSON.LoadFromFile(const FileName: string);
begin
  Editor.Lines.LoadFromFile(FileName);
  Editor.SelStart := 0;
  Editor.Modified := true;
end;

procedure TFrameEditor_JSON.SaveToFile(const FileName: string);
begin
  Editor.Lines.SaveToFile(FileName);
end;

procedure TFrameEditor_JSON.InsertTextAtCaret(const s: string);
begin
  TSynEditAccess(Editor).InsertTextAtCaret(s);
end;

procedure TFrameEditor_JSON.InsertTextAtPos(x, y: Integer; const s: string);
begin
  TSynEditAccess(Editor).InsertTextAtPos(x, y, s);
end;

{ TSynEditAccess }

procedure TSynEditAccess.InsertBlock(BB, BE: TBufferCoord; aText: String);
// var
// oldSelectionMode: TSynSelectionMode;
begin
  SetCaretAndSelection(BB, BB, BE);

  // oldSelectionMode := SelectionMode;
  // SelectionMode := smColumn;

  // SetSelTextPrimitive(smColumn, aText, nil);
  // SetSelTextPrimitiveEx(smColumn, aText);
  SetSelTextPrimitiveEx(aText, BB, BE, true, false);
  StatusChanged([scSelection]);
  // SelectionMode := oldSelectionMode;
end;

procedure TSynEditAccess.InsertTextAtCaret(aText: String);
begin
  InsertBlock(CaretXY, CaretXY, aText);
end;

procedure TSynEditAccess.InsertTextAtPos(const x, y: Integer; aText: String);
var
  dc: TDisplayCoord;
  bc: TBufferCoord;
begin
  dc := PixelsToNearestRowColumn(x, y);
  bc := DisplayToBufferPos(dc);
  InsertBlock(bc, bc, aText);
end;

procedure TFrameEditor_JSON.VisualizzaLog(const visibile: Boolean);
begin
  Splitter.Visible := visibile;
  Log.Visible := visibile;

  Splitter.Top := Log.Top + 1;
end;

procedure TFrameEditor_JSON.FormatJSONExecute(Sender: TObject);
begin
  doFormat;
end;

procedure TFrameEditor_JSON.VerificaJSONUpdate(Sender: TObject);
begin
  VerificaJSON.Enabled := not Empty;
end;

procedure TFrameEditor_JSON.FormatJSONUpdate(Sender: TObject);
begin
  FormatJSON.Enabled := not(Empty or ReadOnly);
end;

function TFrameEditor_JSON.tryParseJSON(out JSONValue: TJSONValue): Boolean;
begin
  result := false;

  JSONValue := nil;
  ErrorLine := -1;

  Log.Lines.Clear;

  try
    JSONValue := TJSONObject.ParseJSONValue(JSON, true, true);
    result := Assigned(JSONValue);
  except
    on e: exception do
      DisplayException(e);
  end;

  VisualizzaLog(true);
  CalcLogHeight;
  Editor.Invalidate;
end;

function TFrameEditor_JSON.doFormat: Boolean;
var
  J: TJSONValue;
  BufferCoord: TBufferCoord;
begin
  if ReadOnly then
    exit(false);

  BufferCoord := Editor.CaretXY;

  result := tryParseJSON(J);

  if result then
  begin
    try
      JSON := J.Format(4);
      Editor.CaretXY := BufferCoord;
    finally
      J.Free;
    end;
  end;
end;

function TFrameEditor_JSON.doVerifica: Boolean;
var
  J: TJSONValue;
begin
  result := tryParseJSON(J);

  if result then
    J.Free;
end;

procedure TFrameEditor_JSON.EditorScanForFoldRanges(Sender: TObject; FoldRanges: TSynFoldRanges; LinesToScan: TStrings; FromLine, ToLine: Integer);
var
  Line: string;
  i: Integer;
  Trimmed: string;

  procedure CheckOpen(const ALine: string);
  var
    C: Char;
  begin
    // Cerca l'ultimo carattere significativo della riga
    for C in ALine do
    begin
      // Ogni { o [ apre un range
    end;
    if ALine.EndsWith('{') or ALine.EndsWith('[') or ALine.EndsWith('{,') // non capita in JSON valido, ma per sicurezza
    then
      FoldRanges.StartFoldRange(i + 1, 1)
    else
      if ALine.EndsWith('}') or ALine.EndsWith(']') or ALine.EndsWith('},') or ALine.EndsWith('],') or ALine.EndsWith('}') or ALine.EndsWith(']') then
        FoldRanges.StopFoldRange(i + 1, 1)
      else
        FoldRanges.NoFoldInfo(i + 1);
  end;

begin
  for i := FromLine to ToLine do
  begin
    Line := LinesToScan[i];
    Trimmed := Trim(Line);

    if (Trimmed = '{') or (Trimmed = '[') or Trimmed.EndsWith(': {') or Trimmed.EndsWith(': [') or Trimmed.EndsWith('"{') or // raro
      (Length(Trimmed) > 0) and (Trimmed[Length(Trimmed)] = '{') or (Length(Trimmed) > 0) and (Trimmed[Length(Trimmed)] = '[') then
      FoldRanges.StartFoldRange(i + 1, 1)
    else
      if (Trimmed = '}') or (Trimmed = ']') or (Trimmed = '},') or (Trimmed = '],') or (Trimmed = '},') or (Trimmed = '],') then
        FoldRanges.StopFoldRange(i + 1, 1)
      else
        FoldRanges.NoFoldInfo(i + 1);
  end;
end;

procedure TFrameEditor_JSON.EditorSpecialLineColors(Sender: TObject; Line: TSynNativeInt; var Special: Boolean; var FG, BG: TColor);
begin

  if Line = ErrorLine then
  begin
    Special := true;
    BG := clRed;
  end;
end;

procedure TFrameEditor_JSON.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  Editor.ReadOnly := ReadOnly;
end;

end.

  AutoAlignBars = true CanCustomize = false NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
