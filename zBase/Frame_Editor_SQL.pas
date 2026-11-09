unit Frame_Editor_SQL;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  ExtCtrls,
  ImgList,
  SynEdit,
  ActnMan,
  ToolWin,
  Grids,
  StdCtrls,
  Menus,
  StdActns,
  ActnList,
  System.Actions,
  System.ImageList,
  SynFunc,
  SynCompletionProposal,
  SynEditTypes,
  SynEditHighlighter,
  SynEditOptionsDialog,
  SynEditMiscClasses,
  SynEditRegexSearch,
  SynHighlighterSQL,
  SynEditPlugins,
  SynMacroRecorder,
  zMetaData,
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
  dxUIAClasses;

type
  TzSqlType = (zstSelect, zstInsert, zstUpdate, zstDelete, zstRefresh);

type
  TFrameEditor_Sql = class(TFrame, IcxLookAndFeelNotificationListener)
    Splitter: TcxSplitter;
    Log: TcxMemo;
    PanelEditor: TPanel;
    StatusBar: TdxStatusBar;
    Editor: TSynEdit;
    CompletionProposal: TSynCompletionProposal;
    ParamProposal: TSynCompletionProposal;
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
    Prepara: TAction;
    FindDialog: TFindDialog;
    ReplaceDialog: TReplaceDialog;
    SynEditRegexSearch: TSynEditRegexSearch;
    SynSQLSyn: TSynSQLSyn;
    VScrollBar: TcxScrollBar;
    HScrollBar: TcxScrollBar;
    FormatSQL: TAction;
    Esegui: TAction;
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
    dxBarButton3: TdxBarButton;
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
    procedure actRipristinaExecute(Sender: TObject);
    procedure EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure actOpzioniEditorExecute(Sender: TObject);
    procedure actRipristinaUpdate(Sender: TObject);
    procedure CaricaDalFileBeforeExecute(Sender: TObject);
    procedure CaricaDalFileAccept(Sender: TObject);
    procedure SalvaSuFileAccept(Sender: TObject);
    procedure actTrovaExecute(Sender: TObject);
    procedure actSostituisciExecute(Sender: TObject);
    procedure CompletionProposalExecute(Kind: SynCompletionType; Sender: TObject; var CurrentInput: string; var x, y: Integer; var CanExecute: Boolean);
    procedure DoFindText(Sender: TObject);
    procedure DoReplaceText(Sender: TObject);
    procedure SalvaSuFileBeforeExecute(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure DuplicaLineaExecute(Sender: TObject);
    procedure EditorSpecialLineColors(Sender: TObject; Line: TSynNativeInt; var Special: Boolean; var FG, BG: TColor);
    procedure EseguiExecute(Sender: TObject);
    procedure EseguiUpdate(Sender: TObject);
    procedure FormatSQLExecute(Sender: TObject);
    procedure FormatSQLUpdate(Sender: TObject);
    procedure HScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure MaiuscoloExecute(Sender: TObject);
    procedure MinuscoloExecute(Sender: TObject);
    procedure ParamProposalExecute(Kind: SynCompletionType; Sender: TObject; var CurrentInput: string; var x, y: Integer; var CanExecute: Boolean);
    procedure PreparaExecute(Sender: TObject);
    procedure PreparaUpdate(Sender: TObject);
    procedure VScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
  private
    ErrorLine: Integer;
    FOnChange: TNotifyEvent;
    FOnExecute: TNotifyEvent;
    FOnFormatSQL: TNotifyEvent;
    FilesDefaultExt: string;
    FilesFilter: string;
    FMetadata: TzMetadata;
    FOnPrepare: TNotifyEvent;
    InsertList, ItemList: TStringList;
    procedure SetOnChange(const Value: TNotifyEvent);
    function FormatItem(const Icon: Integer; const Color: TColor; const ItemClass, ItemName, ItemParams: string): string;
    function GetSQL: string;
    procedure SetMetadata(const Value: TzMetadata);
    procedure SetSQL(const Value: string);
    procedure CalcLogHeight;
    procedure SetScrollbarsRange;
  private
    function doPrepare: Boolean;
    function doExecute: Boolean;
  private
    procedure SetReadonly(const Value: Boolean);
    procedure VisualizzaLog(const visibile: Boolean);
  private
    FReadonly: Boolean;
    IsScrolling: Boolean;
  private
    // ridimensionamento manuale del log: quando true CalcLogHeight non tocca piu' l'altezza
    LogHeightManuale: Boolean;
    procedure SplitterMoved(Sender: TObject);
    procedure AggiornaScrollbarLog;
  protected
    function GetObject: TObject;
    procedure MasterLookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
    procedure MasterLookAndFeelDestroying(Sender: TcxLookAndFeel);
    procedure SetEditorColorsOld;
    procedure SetEditorColors;
  public
    procedure DisplayException(e: exception);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure BuilMetadata;
    property Metadata: TzMetadata read FMetadata write SetMetadata;
    property SQL: string read GetSQL write SetSQL;
  public
    function IsSelect: Boolean;
    function IsScript: Boolean;
  public
    procedure InsertTextAtCaret(const s: string);
    procedure InsertTextAtPos(x, y: Integer; const s: string);
    function Empty: Boolean;
    procedure Clear;
    procedure ClearLog;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
  published
    property Readonly: Boolean read FReadonly write SetReadonly default false;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property OnPrepare: TNotifyEvent read FOnPrepare write FOnPrepare;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    property OnFormatSQL: TNotifyEvent read FOnFormatSQL write FOnFormatSQL;
  end;

var
  FrameEditor_Sql: TFrameEditor_Sql;

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

constructor TFrameEditor_Sql.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FReadonly := false;
  IsScrolling := false;
  ErrorLine := -1;
  FMetadata := nil;
  FilesDefaultExt := '';
  FilesFilter := '';
  FOnChange := nil;
  FOnPrepare := nil;
  FOnExecute := nil;
  FOnFormatSQL := nil;

  InsertList := TStringList.Create;
  ItemList := TStringList.Create;
  Editor.Highlighter := SynSQLSyn;
  CompletionProposal.Images := CompletionImageList;
  ParamProposal.Images := CompletionImageList;
  FilesDefaultExt := '*.sql';
  FilesFilter := 'Sql|*.Sql|Tutti|*.*';

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

destructor TFrameEditor_Sql.Destroy;
begin
  RootLookAndFeel.RemoveChangeListener(self);
  FreeAndNil(InsertList);
  FreeAndNil(ItemList);
  inherited;
end;

procedure TFrameEditor_Sql.actRipristinaUpdate(Sender: TObject);
begin
  actRipristina.Enabled := Editor.CanRedo;
end;

procedure TFrameEditor_Sql.actRipristinaExecute(Sender: TObject);
begin
  if Editor.CanRedo then
    Editor.Redo;
end;

procedure TFrameEditor_Sql.EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
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

procedure TFrameEditor_Sql.actOpzioniEditorExecute(Sender: TObject);
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

procedure TFrameEditor_Sql.CaricaDalFileBeforeExecute(Sender: TObject);
begin
  if Editor.Modified then
    if not ConfirmYesNo('Il testo è stato variato.' + #13 + #10 + 'Continuare perdendo le modifiche?', mtWarning) then
      SysUtils.Abort;

  CaricaDalFile.Dialog.DefaultExt := FilesDefaultExt;
  CaricaDalFile.Dialog.Filter := FilesFilter;
end;

procedure TFrameEditor_Sql.CaricaDalFileAccept(Sender: TObject);
begin
  LoadFromFile(CaricaDalFile.Dialog.FileName);
end;

procedure TFrameEditor_Sql.SalvaSuFileAccept(Sender: TObject);
begin
  SaveToFile(SalvaSuFile.Dialog.FileName);
end;

procedure TFrameEditor_Sql.actTrovaExecute(Sender: TObject);
begin
  if Editor.SelText <> '' then
    FindDialog.FindText := Editor.SelText
  else
    FindDialog.FindText := Editor.WordAtCursor;

  FindDialog.Execute;
end;

procedure TFrameEditor_Sql.actSostituisciExecute(Sender: TObject);
begin
  if Editor.SelText <> '' then
    ReplaceDialog.FindText := Editor.SelText
  else
    ReplaceDialog.FindText := Editor.WordAtCursor;

  ReplaceDialog.Execute;
end;

procedure TFrameEditor_Sql.DoFindText(Sender: TObject);
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

procedure TFrameEditor_Sql.DoReplaceText(Sender: TObject);
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

function TFrameEditor_Sql.FormatItem(const Icon: Integer; const Color: TColor; const ItemClass: string; const ItemName: string; const ItemParams: string): string;
const
  FormatStr = '\image{%d} \color{$%x} %s \color{clBlack} \style{+B}%s\style{-B}%s';
begin
  result := format(FormatStr, [Icon, Color, ItemClass, ItemName, ItemParams]);
end;

procedure TFrameEditor_Sql.SalvaSuFileBeforeExecute(Sender: TObject);
begin
  SalvaSuFile.Dialog.DefaultExt := FilesDefaultExt;
  SalvaSuFile.Dialog.Filter := FilesFilter;
end;

procedure TFrameEditor_Sql.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TFrameEditor_Sql.EditorChange(Sender: TObject);
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

procedure TFrameEditor_Sql.DuplicaLineaExecute(Sender: TObject);
begin
  if Editor.CaretY > 0 then
    Editor.Lines.Insert(Editor.CaretY, Editor.Lines[Editor.CaretY - 1]);
end;

procedure TFrameEditor_Sql.MaiuscoloExecute(Sender: TObject);
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

procedure TFrameEditor_Sql.MinuscoloExecute(Sender: TObject);
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

procedure TFrameEditor_Sql.PreparaExecute(Sender: TObject);
begin
  doPrepare;
end;

procedure TFrameEditor_Sql.CalcLogHeight;
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
    Exit;
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

procedure TFrameEditor_Sql.DisplayException(e: exception);

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
      Exit;

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

function TFrameEditor_Sql.doPrepare: Boolean;
var
  PrepTime: cardinal;
begin
  result := false;

  ErrorLine := -1;

  if not Assigned(FOnPrepare) then
    Exit;

  Log.Lines.Clear;
  try
    PrepTime := GetTickCount;
    OnPrepare(self);
    PrepTime := GetTickCount - PrepTime;
  except
    on e: exception do
      DisplayException(e);
  end;

  // Log.Lines.Add(Query.PlanClause); -- Ripristinare??
  VisualizzaLog(true);
  Log.Lines.Add(format('Prepare: %d ms.', [PrepTime]));
  CalcLogHeight;
  Editor.Invalidate;

  result := true;
end;

function TFrameEditor_Sql.doExecute: Boolean;
var
  execTime: cardinal;
begin
  result := false;

  ErrorLine := -1;

  if not Assigned(FOnExecute) then
    Exit;

  Log.Lines.Clear;
  try
    execTime := GetTickCount;
    OnExecute(self);
    execTime := GetTickCount - execTime;
  except
    on e: exception do
      DisplayException(e);
  end;

  VisualizzaLog(true);
  Log.Lines.Add(format('Execute: %d ms.', [execTime]));
  CalcLogHeight;
  Editor.Invalidate;

  result := true;
end;

function TFrameEditor_Sql.GetSQL: string;
begin
  result := Editor.Lines.Text;
end;

procedure TFrameEditor_Sql.SetMetadata(const Value: TzMetadata);
begin
  FMetadata := Value;
  BuilMetadata;
end;

procedure TFrameEditor_Sql.SetSQL(const Value: string);
begin
  Editor.Lines.Text := Value;
  ErrorLine := -1;
  Log.Lines.Clear;

  SetScrollbarsRange;
end;

function TFrameEditor_Sql.GetObject: TObject;
begin
  // IcxLookAndFeelNotificationListener
  result := self;
end;

procedure TFrameEditor_Sql.SetScrollbarsRange;
begin
  if IsScrolling then
    Exit;

  if HScrollBar.Position <> Editor.CaretX - 1 then
    HScrollBar.Position := Editor.CaretX - 1;

  if VScrollBar.Position <> Editor.CaretY - 1 then
    VScrollBar.Position := Editor.CaretY - 1;

  if VScrollBar.Max <> Editor.Lines.Count then
    VScrollBar.Max := Editor.Lines.Count;
end;

procedure TFrameEditor_Sql.VScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
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

procedure TFrameEditor_Sql.HScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
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

procedure TFrameEditor_Sql.MasterLookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  // IcxLookAndFeelNotificationListener
  SetEditorColors;
end;

procedure TFrameEditor_Sql.MasterLookAndFeelDestroying(Sender: TcxLookAndFeel);
begin
  // IcxLookAndFeelNotificationListener
end;

procedure TFrameEditor_Sql.SetEditorColorsOld;
begin
  Editor.Gutter.BorderColor := dx.cxStyleHeader.Color;
  Editor.Gutter.Color := dx.cxStyleBtnFace.Color;

  Exit;
  // spostare in dx
  // toolbar

  // Editor.SelectedColor.Background := RootLookAndFeel.Painter.DefaultSelectionColor;
  // Editor.SelectedColor.Foreground := RootLookAndFeel.Painter.DefaultSelectionTextColor;
  // Editor.Color := RootLookAndFeel.Painter.DefaultEditorBackgroundColor(False);
  // Editor.Font.Color := RootLookAndFeel.Painter.DefaultEditorTextColor(False);

  // LoadColors;
  // Log.Style.Color := RootLookAndFeel.Painter.DefaultEditorBackgroundColor(true);
  // Log.Style.Font.Color := RootLookAndFeel.Painter.DefaultEditorTextColor(true);
end;

procedure TFrameEditor_Sql.SetEditorColors;
var
  painter: TcxCustomLookAndFeelPainter;
  Sfondo: TColor;
  Testo: TColor;

  // Senza skin il painter standard risponde clDefault (o clNone) per molti
  // colori, e SynEdit disegna clDefault nero: testo nero su fondo nero.
  // In quel caso si usa il colore di sistema, convertito in RGB come tutti
  // gli altri. Con una skin il painter da' colori veri e non cambia nulla
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
  // painter attivo ADESSO: niente snapshot da dx.cxStyle*, che in GestyTools
  // resta sui colori di sistema (Tdx non vede lo skin del MainForm)
  painter := RootLookAndFeel.painter;

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

  // pannello log (readonly: usa la variante "disabled"). E' un controllo
  // DevExpress, per cui clDefault vuol dire "colore del painter" e va
  // lasciato: si sostituisce la coppia solo quando e' illeggibile
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

procedure TFrameEditor_Sql.FormatSQLExecute(Sender: TObject);
begin
  if Assigned(FOnFormatSQL) then
    FOnFormatSQL(self);
end;

procedure TFrameEditor_Sql.FormatSQLUpdate(Sender: TObject);
begin
  FormatSQL.Visible := Assigned(FOnFormatSQL);
end;

procedure TFrameEditor_Sql.BuilMetadata;
var
  i: Integer;

  procedure AddSQLTokens;
  var
    i: Integer;
  begin
    for i := low(SQLToKens) to high(SQLToKens) do
    begin
      InsertList.Add(SQLToKens[i]);
      ItemList.Add(format(SQLITEMSTR, [SQLToKens[i]]));
    end;
  end;

begin
  InsertList.Clear;
  ItemList.Clear;
  AddSQLTokens;
  // TABLE

  for i := 0 to Metadata.Tables.Count - 1 do
  begin
    InsertList.Add(Metadata.Tables[i].Name);
    ItemList.Add(FormatItem(3, clGreen, 'Table', Metadata.Tables[i].Name, ''));
  end;

  // PROCEDURE

  for i := 0 to Metadata.Procedures.Count - 1 do
  begin
    InsertList.Add(Metadata.Procedures[i].Name);
    ItemList.Add(FormatItem(5, clTeal, 'Procedure', Metadata.Procedures[i].Name, ''));
  end;

  // VIEW
  for i := 0 to Metadata.Views.Count - 1 do
  begin
    InsertList.Add(Metadata.Views[i].Name);
    ItemList.Add(FormatItem(4, clMaroon, 'View', Metadata.Views[i].Name, ''));
  end;
end;

procedure TFrameEditor_Sql.CompletionProposalExecute(Kind: SynCompletionType; Sender: TObject; var CurrentInput: string; var x, y: Integer; var CanExecute: Boolean);
  function FindTable: Boolean;
  var
    table, s: string;
    start, stop: Integer;

    function GetMetaTable: Boolean;
    var
      i, j: Integer;
      Icon: Integer;
      FieldList, ProcedureParamNames: TStringList;
      idx: Integer;
      FieldName: string;

      function IsPrimaryKey(const TableName, FieldName: string): Boolean;
      begin
        result := false;
      end;

    // function IsForeignKey(const TableName, FieldName: string): boolean;
    // begin
    // result := MetadataForeignKeys.IndexOf(TableName + '.' + FieldName) <> -1;
    // end;

      function ForeignStr(const TableName, FieldName: string): string;
      begin
      end;

    //
    // function ForeignStr(node: TMetaTableField): string;
    // var
    // i, j: Integer;
    // begin
    // for i := 0 to TMetaTable(Node.Parent).ForeignCount - 1 do
    // for j := 0 to TMetaTable(Node.Parent).Foreign[i].FieldsCount - 1 do
    // if TMetaTable(Node.Parent).Foreign[i].Fields[j] = Node then
    // with TMetaTable(Node.Parent).Foreign[i] do
    // begin
    // result := format(' \image{11} \color{$%x}\style{+B}%s\style{-B}\color{clBlack}(%s)',
    // [NodeInfos[TMetaTable.NodeType].color, ForTable.Name, ForFields[j].Name]);
    // Exit;
    // end;
    // end;
    begin
      result := false;

      CompletionProposal.ClearList;
      // TABLES

      // TABLES
      idx := Metadata.Tables.IndexOf(table);
      if idx <> -1 then
      begin
        for i := 0 to Metadata.Tables[idx].Fields.Count - 1 do
        begin
          FieldName := Metadata.Tables[idx].Fields[i].Name;
          if Metadata.Tables[idx].PrimaryKey.IndexOf(FieldName) <> -1 then
          begin
            if Metadata.Tables[idx].PrimaryKey.IndexOf(FieldName) <> -1 then
              Icon := 13
            else
              Icon := 11;
          end
          else
            if Metadata.Tables[idx].PrimaryKey.IndexOf(FieldName) <> -1 then
              Icon := 12
            else
              Icon := 10; //

          if (Icon in [12, 13]) then
            CompletionProposal.AddItem(format(FIELDSFORMAT, [Icon, FieldName, FieldName + ForeignStr(table, FieldName)]), FieldName)
          else
            CompletionProposal.AddItem(format(FIELDSFORMAT, [Icon, FieldName, FieldName]), FieldName);
        end;
        result := true;
        Exit; // Trovata
      end;

      // PROCEDURES
      idx := Metadata.Procedures.IndexOf(table);
      if idx <> -1 then
      begin
        for i := 0 to Metadata.Procedures[idx].ParamsOutput.Count - 1 do
        begin
          FieldName := Metadata.Procedures[idx].ParamsOutput[i].Name;
          CompletionProposal.AddItem(format(FIELDSFORMAT, [10, FieldName, FieldName]), FieldName);
        end;
        result := true; // proc found
        Exit;
      end;

      // VIEWS
      idx := Metadata.Views.IndexOf(table);
      if idx <> -1 then
      begin
        for i := 0 to Metadata.Views[idx].Fields.Count - 1 do
        begin
          FieldName := Metadata.Views[idx].Fields[i].Name;
          CompletionProposal.AddItem(format(FIELDSFORMAT, [10, FieldName, FieldName]), FieldName);
        end;
        result := true; // view found
        Exit;
      end;
    end;

  var
    c: Integer;
  begin
    result := false;
    s := Editor.Text;
    if s = '' then
      Exit;
    stop := 0;
    for c := 0 to Editor.CaretY - 2 do
      stop := stop + Length(Editor.Lines[c]) + 2; // crlf
    stop := stop + Editor.CaretX - 1;
    if (Editor.CaretX > 1) then
      while (stop > 0) do
      begin
        if (s[stop] = '.') then
        begin
          start := stop;
          while (start > 1) and (s[start - 1] in ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '$']) do
            dec(start);
          if (start <> stop) then
          begin
            // i've found a table name
            table := copy(s, start, stop - start);
            if GetMetaTable then
            begin
              result := true;
              Exit;
            end;
          end;
          Exit;
        end
        else
          if (s[stop] > #32) then
            dec(stop)
          else
            Exit;
      end;
  end;

begin
  if not(FindTable) then
  begin
    CompletionProposal.ItemList.Assign(ItemList);
    CompletionProposal.InsertList.Assign(InsertList);
  end;
end;

procedure TFrameEditor_Sql.ParamProposalExecute(Kind: SynCompletionType; Sender: TObject; var CurrentInput: string; var x, y: Integer; var CanExecute: Boolean);
  function FindTable: Boolean;
  var
    locline, lookup: string;
    TmpX, savepos, StartX, ParenCounter, TmpLocation: Integer;
    FoundMatch: Boolean;
    c: Integer;

    function GetMetaTable: Boolean;
    var
      i, j, k: Integer;
      proposal: string;
      Params: TStringList;
      idx: Integer;
      ParamName: string;
    begin
      result := false;
      ParamProposal.ClearList;

      // PROCEDURES

      idx := Metadata.Procedures.IndexOf(lookup);
      if idx <> -1 then
      begin
        for i := 0 to Metadata.Procedures[idx].ParamsInput.Count - 1 do
        begin
          ParamName := Metadata.Procedures[idx].ParamsInput[i].Name;
          if i = 0 then
            proposal := format('"%s: %s', [ParamName, 'Type'])
          else
            proposal := proposal + format(', "%s: %s', [ParamName, 'Type']);
          if i = Metadata.Procedures[idx].ParamsInput.Count - 1 then
            proposal := proposal + '"'
          else
            proposal := proposal + ',"';
        end;
        ParamProposal.ItemList.Text := proposal;
        result := true;
        Exit;
      end;

      // // UDFS
      // for i := 0 to Meta.UDFSCount - 1 do
      // if CompareText(Meta.UDFS[i].Name, lookup) = 0 then
      // begin
      // if Meta.UDFS[i].Return = 0 then
      // k := 1
      // else
      // k := 0;
      // for j := k to Meta.UDFS[i].FieldsCount - 1 do
      // with Meta.UDFS[i].Fields[j] do
      // begin
      // if (j = k) then
      // proposal := format('"%s', [LowerCase(ShortFieldType)])
      // else
      // proposal := proposal + format(', "%s', [LowerCase(ShortFieldType)]);
      // if j = Meta.UDFS[i].FieldsCount - 1 then
      // proposal := proposal + '"'
      // else
      // proposal := proposal + ',"';
      // end;
      // ParamProposal.ItemList.Text := proposal;
      // result := true;
      // exit;
      // end;

      // SQL
      for i := 0 to High(SQLComp) do
        if CompareText(SQLComp[i].Token, lookup) = 0 then
        begin
          ParamProposal.ItemList.Text := SQLComp[i].Comp;
          result := true;
          Exit;
        end;

    end;

  begin
    result := false;
    locline := Editor.Text;
    if locline = '' then
      Exit;
    TmpX := 0;
    for c := 0 to Editor.CaretY - 2 do
      TmpX := TmpX + Length(Editor.Lines[c]) + 2; // crlf
    TmpX := TmpX + Editor.CaretX - 1;

    FoundMatch := false;
    TmpLocation := 0;

    if (Editor.CaretX > 1) then
      while (TmpX > 0) and not(FoundMatch) do
      begin
        if locline[TmpX] = ',' then
        begin
          inc(TmpLocation);
          dec(TmpX);
        end
        else
          if locline[TmpX] = ')' then
          begin
            // We found a close, go till it's opening paren
            ParenCounter := 1;
            dec(TmpX);
            while (TmpX > 0) and (ParenCounter > 0) do
            begin
              if locline[TmpX] = ')' then
                inc(ParenCounter)
              else
                if locline[TmpX] = '(' then
                  dec(ParenCounter);
              dec(TmpX);
            end;
            if TmpX > 0 then
              dec(TmpX); // eat the open paren
          end
          else
            if locline[TmpX] = '(' then
            begin
              // we have a valid open paren, lets see what the word before it is
              StartX := TmpX;
              while (TmpX > 0) and not Editor.IsIdentChar(locline[TmpX]) do
                dec(TmpX);
              if TmpX > 0 then
              begin
                savepos := TmpX;
                while (TmpX > 0) and not Editor.IsIdentChar(locline[TmpX]) do
                  dec(TmpX);
                inc(TmpX);
                lookup := copy(locline, TmpX, savepos - TmpX + 1);
                FoundMatch := GetMetaTable; // LookupList.IndexOf(Lookup) > -1;
                if not(FoundMatch) then
                begin
                  TmpX := StartX;
                  dec(TmpX);
                end;
              end;
            end
            else
              dec(TmpX);

        CanExecute := FoundMatch;
        if CanExecute then
          ParamProposal.Form.CurrentIndex := TmpLocation;
      end;
  end;

begin
  FindTable;
end;

function TFrameEditor_Sql.Empty: Boolean;
begin
  result := Editor.Lines.Count = 0;
end;

procedure TFrameEditor_Sql.Clear;
begin
  Editor.Lines.Clear;
end;

procedure TFrameEditor_Sql.ClearLog;
begin
  Log.Clear;
end;

procedure TFrameEditor_Sql.EseguiExecute(Sender: TObject);
begin
  doExecute;
end;

procedure TFrameEditor_Sql.EseguiUpdate(Sender: TObject);
begin
  Esegui.Visible := Assigned(FOnExecute) and not Empty;
end;

procedure TFrameEditor_Sql.LoadFromFile(const FileName: string);
begin
  Editor.Lines.LoadFromFile(FileName);
  Editor.SelStart := 0;
  Editor.Modified := true;
end;

procedure TFrameEditor_Sql.SaveToFile(const FileName: string);
begin
  Editor.Lines.SaveToFile(FileName);
end;

function TFrameEditor_Sql.IsSelect: Boolean;
var
  Token: string;
  FullText: string;
begin
  result := false;

  if Empty then
    result := false
  else
  begin
    FullText := Editor.Text.Trim.ToUpper;
    Token := FullText.Substring(0, 50);

    if Token.StartsWith('SELECT') then
      result := true
    else
      if Token.StartsWith('EXECUTE BLOCK') then
        result := FullText.Contains('SUSPEND')
      else
        if Token.StartsWith('WITH') then
          result := true
  end;
end;

function TFrameEditor_Sql.IsScript: Boolean;
begin

  if Empty then
    result := false
  else
    result := not IsSelect;
end;

procedure TFrameEditor_Sql.PreparaUpdate(Sender: TObject);
begin
  Prepara.Visible := Assigned(FOnPrepare) and IsSelect and not Empty;
end;

procedure TFrameEditor_Sql.InsertTextAtCaret(const s: string);
begin
  TSynEditAccess(Editor).InsertTextAtCaret(s);
end;

procedure TFrameEditor_Sql.InsertTextAtPos(x, y: Integer; const s: string);
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

procedure TFrameEditor_Sql.EditorSpecialLineColors(Sender: TObject; Line: TSynNativeInt; var Special: Boolean; var FG, BG: TColor);
begin

  if Line = ErrorLine then
  begin
    Special := true;
    BG := clRed;
  end;
end;

procedure TFrameEditor_Sql.SetReadonly(const Value: Boolean);
begin
  FReadonly := Value;
  Editor.ReadOnly := ReadOnly;
end;

procedure TFrameEditor_Sql.VisualizzaLog(const visibile: Boolean);
begin
  Splitter.Visible := visibile;
  Log.Visible := visibile;

  Splitter.Top := Log.Top + 1;
end;

procedure TFrameEditor_Sql.SplitterMoved(Sender: TObject);
begin
  LogHeightManuale := true;
  AggiornaScrollbarLog;
end;

// mostra solo le scrollbar effettivamente necessarie per il contenuto corrente
procedure TFrameEditor_Sql.AggiornaScrollbarLog;
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
  else
    if needVertical then
      newScrollBars := ssVertical
    else
      if needHorizontal then
        newScrollBars := ssHorizontal
      else
        newScrollBars := ssNone;

  // cambiare ScrollBars ricrea la finestra del memo: solo se serve davvero
  if Log.Properties.ScrollBars <> newScrollBars then
    Log.Properties.ScrollBars := newScrollBars;
end;

end.

  AutoAlignBars = true CanCustomize = false NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
