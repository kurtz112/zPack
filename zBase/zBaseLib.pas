unit zBaseLib;

interface

uses
  Winapi.Windows,
  Winapi.ShlObj,
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.IniFiles,
  Data.Db,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ActnList;

type
  TzCtrlType = (ctDefault, ctEdit, ctSpin, ctDate, ctTime, ctDateTime, ctPickList, ctPickListImage, ctRadioGroup, ctComboBox, ctComboDlg, ctLookup, ctLookupExt, ctLookupHyperLink, ctCheckBox, ctMemo, ctRTF, ctImage, ctProgressBar, ctRating,
    ctHyperLink, ctColorCombo, ctCustomDlg, ctCheckComboBox, ctCheckGroupBox, ctToggleSwitch, ctDateTimeWheelPicker, ctTokenEdit, ctFormattedLabel, ctButtonEdit, ctMaskEdit, ctCheckGroup, ctShellComboBox, ctGroupBox, ctButton, ctSeparator,
    ctLineBreak);

  TzCtrlTypeHelper = record helper for TzCtrlType
  private
    function GetAsString: string;
    procedure SetAsString(const Value: string);
  public
    class function DefaultLookupCtrlType: TzCtrlType; static;
    class function DefaultPickListCtrlType: TzCtrlType; static;
    function IsMultiLine: boolean;
    function IsLookup: boolean;
    function IsPickList: boolean;
    function IsHyperLink: boolean;
    function IsMemo: boolean;
    function IsBlob: boolean;
    function IsBoolean: boolean;
    function IsGroup: boolean;
    function IsDataAware: boolean;
    function IsLineBreak: boolean;
    function IsSeparator: boolean;
    function ValidForCard: boolean;
    function ValidForView: boolean;
  public
    property AsString: string read GetAsString write SetAsString;
  end;

  zException = class(Exception)
  end;

  TEnum<T> = record
    class function StringToEnum(x: String): T; static;
    class function EnumToString(x: T): String; static;
  end;

const
  Apice = #39;
  NullDate: TDateTime = { -693594 } 0;

  clSkyBlue = 16776176;
  clMoneyGreen = 12639424;
  clCream = 10930928;
  clInfo = -16777192;

type
  TzHyperLinkEvent = procedure(Sender: TObject; FieldName: string; Value: Variant) of object;
  TzCustomDialogEvent = procedure(Sender: TObject; aField: TField; TagString: string; var Value: Variant) of object;

// debug
function Debug: boolean;
// path dell'applicazione
function Path: string;
// aggiunge \ finale
function CalcPath(s: string): string;
// scompone la stringa in elemento
procedure zSplitStr(s: string; delimeter: string; parts: TStrings; NoEmpty: boolean = false);
// prima lettera maiuscola di ogni parola
function zzCapFirst(Value: string; ReplaceUnderScore: boolean): string;
// salva su file il dfm del componente
procedure ComponentToDFM(Component: TComponent; FileName: string; Ancestor: TComponent = nil);

// aggiunge 1,2,3 al nome sino a renderlo unico
function GetUniqueComponentName(const Name: string; Owner: TComponent): string;
// toglie le schifezze nel nome del componente
function ValidateComponentName(Name: string): string;
function IsNumeric(DataType: TFieldType): boolean;

function IsInteger(DataType: TFieldType): boolean;

// function CalcolaNomeFileDaData: string;

function PasswordOk(Caption: string; const Doppia: boolean = false): boolean;

function PasswordXX(Caption: string): boolean;

function ComputerName: string;

function FormatDisplayLabel(FieldName: string): string;

function IsNull(Value: Variant): boolean;

function Coalesce(const value1, value2: string): string; overload;

function StartingWith(const s: string; const SubStr: string): boolean;

function EndsWith(const s: string; const SubStr: string): boolean;

function Contains(const s: string; const SubStr: string): boolean;

function GetTempFileName: string;

procedure ActionVisible(Action: TCustomAction; Visible: boolean);

procedure StartWait(const Msg: string = 'Attendere...'; const NoTimer: boolean = True);

procedure StopWait;

procedure UpdateWait(const Msg: string);

procedure Delay(MSecs: LongInt);

function StrToChar(s: string): char;

function FolderFromID(ID: Integer; const DirLen: Integer = 3; const MaxDirLen: Integer = 15; const Sep: char = '\'): string;

// function MSecToTime(mSec: Int64): string;

function Year(date: TDateTime): word;

function GetFileVersion: string;

function CurrencyToStr(Value: extended): string;

function SanSilvestro: TDateTime;

function Capodanno: TDateTime;

function Onnipotente: boolean;

function NomeFileFromDate(Data: TDateTime): string;

function FileNameNoExt(FileName: string): string;

function CtrlKey: boolean;
function ShiftKey: boolean;

// function Max(const A, B: Integer): Integer; overload; inline;
// function Max(const A, B: Double): Double; overload; inline;
function MaxDate(const A, B: TDateTime): TDateTime; overload; inline;

function Desktop: string;
//
procedure SaveFormPosition(Form: TForm; const IniFileName: string; const IniSection: string = '');

procedure LoadFormPosition(Form: TForm; const IniFileName: string; const IniSection: string = '');

function GetContrastColor(ABGColor: TColor): TColor;

// utilizzata per il problema delle form modali che finiscono dietro
function GetPopupParent(Comp: TComponent): TCustomForm;

function Data9999: TDate;
function DataZero: TDate;
function OraZero: TTime;

function MSecToStr(const mSec: Integer): string;

function DateNull(const date: TDateTime): boolean;

// Nessun progetto in SRC la chiama: la usano solo le unit di traduzione di DevExpress
// (dxItalian\dxItalian_Consts_*.pas, circa 1000 chiamate). Non toglierla finche' esistono.
Function ChangeResourceString(resstring: PResStringRec; newvalue: Pchar): boolean;

function CapFirst(Value: string): string;

var
  OnStartWait: TProc = nil;
  OnStopWait: TProc = nil;

implementation

uses
  Winapi.SHFolder,
  Vcl.Dialogs,
  zz.strings,
  zz.Folders,
  zWaitFrm,
  zMsg,
  Registry,
  TypInfo,
  System.IOUtils,
  System.Rtti,
  System.DateUtils;

function CapFirst(Value: string): string;
var
  i: Integer;
  s: string;
begin
  result := '';
  if trim(Value) = '' then
    Exit;
  s := uppercase(Value[1]);
  for i := 2 to length(Value) do
  begin
    if (ord(Value[i - 1]) < 33) then
      s := s + uppercase(Value[i])
    else
      s := s + lowercase(Value[i]);
  end;
  result := s;
end;

procedure zSplitStr(s: string; delimeter: string; parts: TStrings; NoEmpty: boolean = false);
var
  curpos: Integer;
  curStr: string;

  procedure Add(s: string);
  begin
    if NoEmpty then
      if trim(s) = '' then
        Exit;
    parts.Add(s);
  end;

begin
  parts.clear;
  curStr := s;
  repeat
    curpos := AnsiPos(delimeter, curStr);
    if (curpos > 0) then
    begin
      Add(copy(curStr, 1, curpos - 1));
      curStr := copy(curStr, curpos + 1, length(curStr) - (curpos));
    end
    else
      Add(curStr);
  until curpos = 0;
end;

function zzCapFirst(Value: string; ReplaceUnderScore: boolean): string;
var
  i: Integer;
  s: string;
begin
  result := '';

  if trim(Value) = '' then
    Exit;

  s := uppercase(Value[1]);

  for i := 2 to length(Value) do
  begin

    if (Value[i - 1] in [' ', '_']) then
      s := s + uppercase(Value[i])
    else
      s := s + lowercase(Value[i]);
  end;

  if ReplaceUnderScore then
    s := StringReplace(s, '_', ' ', [rfReplaceAll]);

  result := s;
end;

function CalcPath(s: string): string;
begin
  result := IncludeTrailingPathDelimiter(trim(s));
end;

function Path: string;
begin
  result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.exename));
end;

function GetUniqueComponentName(const Name: string; Owner: TComponent): string;
var
  CurrentName: string;
  i: Integer;
begin
  result := Name;

  if not Assigned(Owner) then
    Exit;

  if not Assigned(Owner.FindComponent(Name)) then
    Exit
  else
    for i := 0 to MaxInt do
    begin
      CurrentName := Name + IntToStr(i);
      if not Assigned(Owner.FindComponent(CurrentName)) then
      begin
        result := CurrentName;
        Exit;
      end;
    end;
end;

procedure ComponentToDFM(Component: TComponent; FileName: string; Ancestor: TComponent = nil);
var
  FileStream: TFileStream;
  TempStream: TMemoryStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try

    TempStream := TMemoryStream.Create;
    try
      TempStream.WriteDescendent(Component, Ancestor);
      TempStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(TempStream, FileStream);
    finally
      TempStream.Free;
    end;

  finally
    FileStream.Free;
  end;
end;

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

function IsNumeric(DataType: TFieldType): boolean;
begin
  result := DataType in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftLongWord, ftShortint, ftByte, ftFloat, ftCurrency, ftBCD, ftFMTBcd, TFieldType.ftSingle];

end;

function IsInteger(DataType: TFieldType): boolean;
begin
  result := DataType in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftLongWord, ftShortint, ftByte];
end;

// function CalcolaNomeFileDaData: string;
// var
// anno, mese, giorno: word;
// begin
// DecodeDate(date, anno, mese, giorno);
// result := inttostr(anno);
// if mese < 10 then
// result := result + '0';
// result := result + inttostr(mese);
// if giorno < 10 then
// result := result + '0';
// result := result + '  ' + FormatDateTime('dddd, d mmmm yyyy hh:mm:ss', Now);
// end;

function PasswordOk(Caption: string; const Doppia: boolean = false): boolean;

  function WTPassword: string;
  begin
    result := 'D';
    result := result + 'R';
    result := result + 'S';
    result := result + 'G';
    result := result + 'T';
    result := result + 'N';
  end;

  function WTPassword2: string;
  begin
    result := 'P';
    result := result + 'o';
    result := result + 'v';
    result := result + 'e';
    result := result + 'r';
    result := result + 'o';
    result := result + 'R';
    result := result + 'o';
    result := result + 'g';
    result := result + 'e';
    result := result + 'r';
  end;

var
  s: string;
begin
  if Onnipotente then
  begin
    result := True;
    Exit;
  end;

  result := false;
  s := '';
  if InputPassword(Caption, 'Password', s) then
    if uppercase(s) = WTPassword then
      result := True
    else
      ShowMessage('Password errata');

  if result then
    if Doppia then
      if InputPassword(Caption, 'Password 2', s) then
        if uppercase(s) = uppercase(WTPassword2) then
          result := True
        else
        begin
          result := false;
          ShowMessage('Password errata');
        end;
end;

function PasswordXX(Caption: string): boolean;

  function GetPasswordXX: string;
  begin
    result := 'O';
    result := result + 'N';
    result := result + 'N';
    result := result + 'I';
    result := result + 'P';
    result := result + 'O';
    result := result + 'T';
    result := result + 'E';
    result := result + 'N';
    result := result + 'T';
    result := result + 'E';
  end;

var
  s: string;
begin
  result := false;
  s := '';
  if InputPassword(Caption, 'Password', s) then
    if uppercase(s) = GetPasswordXX then
      result := True
    else
      ShowMessage('Password errata');
end;

function ComputerName: string;
var
  cresult: string;
  pw: Pchar;
  pwSize: cardinal;
begin
  GetMem(pw, 300);
  pwSize := 300;
  try
    if GetComputerName(Pchar(pw), pwSize) then
    begin
      cresult := StrPas(pw);
    end;
  finally
    FreeMem(pw, 300);
  end;
  result := uppercase(cresult);
end;

function FormatDisplayLabel(FieldName: string): string;
begin
  result := CapFirst(StringReplace(FieldName, '_', ' ', [rfReplaceAll]));
end;

function IsNull(Value: Variant): boolean;
begin
  result := VarIsEmpty(Value) or VarIsNull(Value);
end;

function StartingWith(const s: string; const SubStr: string): boolean;
var
  Token: string;
begin
  Token := System.copy(s, 0, length(SubStr));
  result := SameText(SubStr, Token);
end;

function EndsWith(const s: string; const SubStr: string): boolean;
var
  Token: string;
begin
  Token := System.copy(s, 1 + length(s) - length(SubStr), length(SubStr));
  result := SameText(SubStr, Token);
end;

function Contains(const s: string; const SubStr: string): boolean;
begin
  result := AnsiPos(SubStr, s) <> 0;
end;

function GetTempFileName: string;
var
  Buffer: array [0 .. MAX_PATH] of char;
begin
  // nella sottocartella Temp dell'eseguibile, non accanto all'eseguibile
  Winapi.Windows.GetTempFileName(Pchar(TFolders.ModuleSubFolder('Temp')), '~', 0, Buffer);
  result := Buffer;
end;

procedure ActionVisible(Action: TCustomAction; Visible: boolean);
begin
  // se non dsi disabilita risponde alle shortcut
  Action.Visible := Visible;
  Action.Enabled := Visible;
end;

procedure StartWait(const Msg: string = 'Attendere...'; const NoTimer: boolean = True);
begin

  if Assigned(OnStartWait) then
    OnStartWait;

  zWaitFrm.StartWait(Msg, NoTimer);
end;

procedure StopWait;
begin
  if Assigned(OnStopWait) then
    OnStopWait;

  zWaitFrm.StopWait;
end;

procedure UpdateWait(const Msg: string);
begin
  zWaitFrm.UpdateWait(Msg);
end;

procedure Delay(MSecs: LongInt);
var
  FirstTickCount, Now: LongInt;
begin
  FirstTickCount := GetTickCount;
  repeat
    Application.ProcessMessages;
    { allowing access to other controls, etc. }
    Now := GetTickCount;
  until (Now - FirstTickCount >= MSecs) or (Now < FirstTickCount);
end;

function StrToChar(s: string): char;
begin
  result := #0;
  if s <> '' then
    result := s[low(s)];
end;

function FolderFromID(ID: Integer; const DirLen: Integer = 3; const MaxDirLen: Integer = 15; const Sep: char = '\'): string;
var
  s: string;
begin
  result := '';
  s := IntToStr(ID);
  s := PadString(s, MaxDirLen, '0');

  while length(s) > DirLen do
  begin
    result := result + System.copy(s, 1, DirLen) + Sep;
    System.Delete(s, 1, DirLen);
  end;
end;

// function MSecToTime(mSec: Int64): string;
// var
// dt: TDateTime;
// begin
// dt := mSec / MSecsPerSec / SecsPerDay;
// Result := Format('%d days, %s', [Trunc(dt), FormatDateTime('hh:nn:ss.z', Frac(dt))]);
// end;

function Year(date: TDateTime): word;
var
  y, m, d: word;
begin
  result := 0;
  DecodeDate(date, y, m, d);
  result := y;
end;

function GetFileVersion: string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  result := '';
  VerInfoSize := GetFileVersionInfoSize(Pchar(Application.exename), Dummy);
  if VerInfoSize = 0 then
    Exit;

  GetMem(VerInfo, VerInfoSize);
  try
    GetFileVersionInfo(Pchar(ParamStr(0)), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);

    with VerValue^ do
    begin
      result := IntToStr(dwFileVersionMS shr 16);
      result := result + '.' + IntToStr(dwFileVersionMS and $FFFF);
      result := result + '.' + IntToStr(dwFileVersionLS shr 16);
      result := result + '.' + IntToStr(dwFileVersionLS and $FFFF);
    end;

  finally
    FreeMem(VerInfo, VerInfoSize);
  end;
end;

function CurrencyToStr(Value: extended): string;
begin
  result := '';
  try
    result := FloatToStrF(Value, ffCurrency, 18, FormatSettings.CurrencyDecimals);
  except
  end;
end;

function SanSilvestro: TDateTime;
begin
  result := EncodeDate(Year(date), 12, 31);
end;

function Capodanno: TDateTime;
begin
  result := EncodeDate(Year(date), 1, 1);
end;

function Onnipotente: boolean;
begin
  result := (ComputerName = 'MASTER') or (ComputerName = 'LUCA') or (ComputerName = 'VOYAGER');
end;

function NomeFileFromDate(Data: TDateTime): string;
var
  anno, mese, giorno: word;
begin
  DecodeDate(Data, anno, mese, giorno);

  result := IntToStr(anno);

  if mese < 10 then
    result := result + '0';
  result := result + IntToStr(mese);

  if giorno < 10 then
    result := result + '0';
  result := result + IntToStr(giorno);

  result := result + '  ' + FormatDateTime('dddd, dd mmmm yyyy hh mm ss', Now);
end;

function FileNameNoExt(FileName: string): string;
var
  Ext: string;
  temp: string;
begin
  temp := extractFileName(FileName);
  Ext := extractFileExt(FileName);
  if pos(Ext, temp) > 0 then
    System.Delete(temp, pos(Ext, temp), length(Ext));
  result := temp;
end;

function CtrlKey: boolean;
begin
  result := (GetKeyState(VK_CONTROL) < 0);
end;

function ShiftKey: boolean;
begin
  result := (GetKeyState(VK_SHIFT) < 0);
end;

////////////////////////////////////////////////////////////////////////////////

// function Max(const A, B: Integer): Integer;
// begin
// if A > B then
// Result := A
// else
// Result := B;
// end;
//
// function Max(const A, B: Double): Double;
// begin
// if A > B then
// Result := A
// else
// Result := B;
// end;

function MaxDate(const A, B: TDateTime): TDateTime;
begin
  if A > B then
    result := A
  else
    result := B;
end;

// function Desktop: string;
// var
// INI: TRegIniFile;
// begin
// Result := '';
// INI := TRegIniFile.Create('');
// try
// Result := INI.ReadString('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'Desktop', 'C:\windows\Desktop');
// Result := CalcPath(Result);
// finally
// INI.Free;
// end;
// end;

function Desktop: string;
var
  LStr: array [0 .. MAX_PATH] of char;
begin
  SetLastError(ERROR_SUCCESS);
  if SHGetFolderPath(0, CSIDL_DESKTOP, 0, 0, @LStr) = S_OK then
    result := LStr;
end;

// Disposizione adattiva 2026-10-27: riporta il rettangolo dentro l'area utile
// del monitor piu' vicino (esclusa la barra delle applicazioni): prima lo
// stringe se e' piu' grande, poi lo sposta se sborda. Il monitor si sceglie
// dal rettangolo salvato, non dalla finestra, che a questo punto puo' non
// essere ancora stata creata.
function RettangoloNellAreaUtile(const Rettangolo: TRect): TRect;
var
  Monitor: TMonitor;
  AreaUtile: TRect;
  Larghezza, Altezza: Integer;
begin
  result := Rettangolo;

  Monitor := Screen.MonitorFromRect(Rettangolo, mdNearest);
  if not Assigned(Monitor) then
    Monitor := Screen.PrimaryMonitor;
  if not Assigned(Monitor) then
    Exit;

  AreaUtile := Monitor.WorkareaRect;

  Larghezza := Rettangolo.Width;
  if Larghezza > AreaUtile.Width then
    Larghezza := AreaUtile.Width;

  Altezza := Rettangolo.Height;
  if Altezza > AreaUtile.Height then
    Altezza := AreaUtile.Height;

  result.Left := Rettangolo.Left;
  if result.Left + Larghezza > AreaUtile.Right then
    result.Left := AreaUtile.Right - Larghezza;
  if result.Left < AreaUtile.Left then
    result.Left := AreaUtile.Left;

  result.Top := Rettangolo.Top;
  if result.Top + Altezza > AreaUtile.Bottom then
    result.Top := AreaUtile.Bottom - Altezza;
  if result.Top < AreaUtile.Top then
    result.Top := AreaUtile.Top;

  result.Right := result.Left + Larghezza;
  result.Bottom := result.Top + Altezza;
end;

// Disposizione adattiva 2026-10-27: limiti della finestra "normale", cioe'
// quelli a cui torna quando la si ripristina, anche se ora e' massimizzata.
// GetWindowPlacement li restituisce in coordinate dell'area di lavoro, che
// differiscono da quelle dello schermo quando la barra delle applicazioni
// sta in alto o a sinistra: si riportano allo schermo con lo scarto fra area
// utile e area intera del monitor su cui sta la finestra. Un eventuale
// residuo lo corregge RettangoloNellAreaUtile alla riapertura.
function LimitiNormali(Form: TForm): TRect;
var
  Collocazione: TWindowPlacement;
  Monitor: TMonitor;
begin
  result := Form.BoundsRect;

  if Form.WindowState = wsNormal then
    Exit;

  if (Form.FormStyle = fsMDIChild) or not Form.HandleAllocated then
    Exit;

  FillChar(Collocazione, SizeOf(Collocazione), 0);
  Collocazione.length := SizeOf(Collocazione);
  if not GetWindowPlacement(Form.Handle, @Collocazione) then
    Exit;

  result := Collocazione.rcNormalPosition;

  if (GetWindowLong(Form.Handle, GWL_EXSTYLE) and WS_EX_TOOLWINDOW) = 0 then
  begin
    Monitor := Screen.MonitorFromWindow(Form.Handle, mdNearest);
    if Assigned(Monitor) then
      result.Offset(Monitor.WorkareaRect.Left - Monitor.BoundsRect.Left, Monitor.WorkareaRect.Top - Monitor.BoundsRect.Top);
  end;
end;

procedure LoadFormPosition(Form: TForm; const IniFileName: string; const IniSection: string = '');
var
  IniFile: TIniFile;
  ws: TWindowState;
  Section: string;
  Rettangolo: TRect;
  PixelPerPolliceSalvato: integer;
begin
  Assert(Assigned(Form));

  if CtrlKey then
    Exit;

  Section := IniSection;
  if Section = '' then
    Section := Form.Name;

  IniFile := TIniFile.Create(IniFileName);
  try
    if IniFile.SectionExists(Section) then
      Form.Position := poDesigned;

    Rettangolo.Left := IniFile.ReadInteger(Section, 'Left', Form.Left);
    Rettangolo.Top := IniFile.ReadInteger(Section, 'Top', Form.Top);
    Rettangolo.Width := IniFile.ReadInteger(Section, 'Width', Form.Width);
    Rettangolo.Height := IniFile.ReadInteger(Section, 'Height', Form.Height);

    // Mantis #310 - 2026-10-30: Width e Height sono pixel fisici del PPI in cui
    // sono stati scritti (chiave PPI di SaveFormPosition). Il file e' per utente e
    // lo leggono sia il fisso a 96 PPI sia il portatile in desktop remoto a 192:
    // riletti tali e quali, un dialogo salvato sul fisso si apriva grande meta'.
    // Si riportano al PPI della form con PPI attuale / PPI salvato; senza la
    // chiave (file scritto prima) si presume 96. Left e Top restano pixel del
    // desktop e li corregge RettangoloNellAreaUtile.
    PixelPerPolliceSalvato := IniFile.ReadInteger(Section, 'PPI', 96);
    if (PixelPerPolliceSalvato > 0) and (Form.CurrentPPI > 0) then
    begin
      if IniFile.ValueExists(Section, 'Width') then
        Rettangolo.Width := MulDiv(Rettangolo.Width, Form.CurrentPPI, PixelPerPolliceSalvato);
      if IniFile.ValueExists(Section, 'Height') then
        Rettangolo.Height := MulDiv(Rettangolo.Height, Form.CurrentPPI, PixelPerPolliceSalvato);
    end;

    // Disposizione adattiva 2026-10-27: prima si sceglievano il monitor dalla
    // finestra e la misura da Monitor.Width/Height, e la riduzione scriveva
    // su Form.BoundsRect.Width, cioe' su una copia del rettangolo: la finestra
    // salvata su un monitor grande restava piu' grande di quello piccolo
    // (desktop remoto, portatile). Ora si calcola il rettangolo finale
    // sull'area utile e lo si applica in un colpo solo. Le figlie MDI hanno
    // coordinate relative alla finestra principale e restano come sono.
    if Form.FormStyle <> fsMDIChild then
      Rettangolo := RettangoloNellAreaUtile(Rettangolo);

    Form.SetBounds(Rettangolo.Left, Rettangolo.Top, Rettangolo.Width, Rettangolo.Height);

    // lo stato dopo i limiti: una finestra massimizzata conserva cosi' i
    // limiti normali a cui tornare quando la si ripristina
    ws := TWindowState(IniFile.ReadInteger(Section, 'State', Integer(Form.WindowState)));

    if ws in [wsMinimized] then
      Form.WindowState := wsNormal
    else
      Form.WindowState := ws;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure SaveFormPosition(Form: TForm; const IniFileName: string; const IniSection: string = '');
var
  IniFile: TIniFile;
  Folder: string;
  Section: string;
  Rettangolo: TRect;
begin
  Assert(Assigned(Form));

  Folder := ExtractFilePath(IniFileName);
  if not TDirectory.Exists(Folder) then
    Exit;

  Section := IniSection;
  if Section = '' then
    Section := Form.Name;

  IniFile := TIniFile.Create(IniFileName);
  try
    IniFile.WriteInteger(Section, 'State', Integer(Form.WindowState));

    // Disposizione adattiva 2026-10-27: i limiti si salvano anche per la
    // finestra massimizzata (quelli normali, da GetWindowPlacement). Prima si
    // saltavano, e alla prima riduzione la finestra tornava dove stava l'ultima
    // volta che era stata chiusa non massimizzata, magari su un monitor che
    // non c'e' piu'. Una finestra ridotta a icona non ha limiti utili.
    if Form.WindowState <> wsMinimized then
    begin
      Rettangolo := LimitiNormali(Form);

      IniFile.WriteInteger(Section, 'Top', Rettangolo.Top);
      IniFile.WriteInteger(Section, 'Left', Rettangolo.Left);
      IniFile.WriteInteger(Section, 'Height', Rettangolo.Height);
      IniFile.WriteInteger(Section, 'Width', Rettangolo.Width);

      // PPI del monitor al salvataggio: per ora solo registrato, servira' ai
      // profili di schermo (fase 2) per convertire le misure fra scale diverse
      IniFile.WriteInteger(Section, 'PPI', Form.CurrentPPI);
    end;
  finally
    FreeAndNil(IniFile);
  end;
end;

class function TEnum<T>.EnumToString(x: T): String;
begin
  case Sizeof(T) of
    1:
      result := GetEnumName(TypeInfo(T), PByte(@x)^);
    2:
      result := GetEnumName(TypeInfo(T), PWord(@x)^);
    4:
      result := GetEnumName(TypeInfo(T), PCardinal(@x)^);
  end;
end;

class function TEnum<T>.StringToEnum(x: String): T;
begin
  case Sizeof(T) of
    1:
      PByte(@result)^ := GetEnumValue(TypeInfo(T), x);
    2:
      PWord(@result)^ := GetEnumValue(TypeInfo(T), x);
    4:
      PCardinal(@result)^ := GetEnumValue(TypeInfo(T), x);
  end;
end;

function GetContrastColor(ABGColor: TColor): TColor;
var
  ADouble: Double;
  R, G, B: Byte;
begin
  if ABGColor <= 0 then
    Exit(clBlack);

  if ABGColor = clWhite then
    Exit(clBlack);

  // Get RGB from Color
  R := GetRValue(ABGColor);
  G := GetGValue(ABGColor);
  B := GetBValue(ABGColor);

  // Counting the perceptive luminance - human eye favors green color...
  ADouble := 1 - (0.299 * R + 0.587 * G + 0.114 * B) / 255;

  if (ADouble < 0.5) then
    result := clBlack // bright colors - black font
  else
    result := clWhite; // dark colors - white font
end;

function Coalesce(const value1, value2: string): string;
var
  s: String;
begin
  result := '';

  if not value1.isEmpty then
    result := value1
  else
    if not value2.isEmpty then
      result := value2;
end;

function GetPopupParent(Comp: TComponent): TCustomForm;
begin
  result := nil;

  while Assigned(Comp) do
  begin

    if Comp IS TCustomForm then
    begin
      result := Comp as TCustomForm;
      Break;
    end;

    Comp := Comp.Owner;
  end;

  if not Assigned(result) then
    result := Screen.ActiveCustomForm;
end;

function Data9999: TDate;
begin
  result := EncodeDate(9999, 12, 31)
end;

function DataZero: TDate;
begin
  result := EncodeDate(1899, 12, 30);
end;

function OraZero: TTime;
begin
  result := EncodeTime(0, 0, 0, 0);
end;

// usata solo da MSecToStr
function MSecToDateTime(const mSec: Integer): TDateTime;
begin
  result := mSec / MSecsPerSec / SecsPerDay;
end;

function MSecToStr(const mSec: Integer): string;
begin
  result := TimeToStr(MSecToDateTime(mSec));
end;

function Debug: boolean;
begin
  result := DebugHook <> 0;
end;

class function TzCtrlTypeHelper.DefaultLookupCtrlType: TzCtrlType;
begin
  result := ctLookupExt;
end;

class function TzCtrlTypeHelper.DefaultPickListCtrlType: TzCtrlType;
begin
  result := ctPickListImage;
end;

{ TzCtrlTypeHelper }

function TzCtrlTypeHelper.GetAsString: string;
begin
  result := TRttiEnumerationType.GetName<TzCtrlType>(Self);
end;

procedure TzCtrlTypeHelper.SetAsString(const Value: string);
begin
  Self := TRttiEnumerationType.GetValue<TzCtrlType>(Value);
end;

function TzCtrlTypeHelper.IsBlob: boolean;
begin
  result := Self in [ctImage, ctMemo, ctRTF];
end;

function TzCtrlTypeHelper.IsBoolean: boolean;
begin
  result := Self in [ctCheckBox, ctToggleSwitch];
end;

function TzCtrlTypeHelper.IsGroup: boolean;
begin
  result := Self in [ctCheckGroupBox, ctGroupBox];
end;

function TzCtrlTypeHelper.IsHyperLink: boolean;
begin
  result := Self in [ctHyperLink, ctLookupHyperLink];
end;

function TzCtrlTypeHelper.IsLineBreak: boolean;
begin
  result := Self = ctLineBreak;
end;

function TzCtrlTypeHelper.IsLookup: boolean;
begin
  // result := Self in [ctComboDlg, ctLookup, ctLookupExt, ctLookupHyperLink]; // or (item.zCtrlType = ctCheckComboBox);
  // Tolto ctComboDlg: es. REPORT_FILE di GedoEstrazioniMassive
  result := Self in [ctLookup, ctLookupExt, ctLookupHyperLink]; // or (item.zCtrlType = ctCheckComboBox);
end;

function TzCtrlTypeHelper.IsMultiLine: boolean;
begin
  result := Self in [ctMemo, ctRTF, ctImage, ctRadioGroup, ctCheckGroup, ctCheckGroupBox, ctDateTimeWheelPicker, ctGroupBox];
end;

function TzCtrlTypeHelper.IsPickList: boolean;
begin
  result := Self in [ctPickList, ctPickListImage];
end;

function TzCtrlTypeHelper.IsSeparator: boolean;
begin
  result := Self = ctSeparator;
end;

function TzCtrlTypeHelper.IsDataAware: boolean;
begin
  result := not(Self in [ctGroupBox, ctButton, ctSeparator, ctLineBreak]);
end;

function TzCtrlTypeHelper.IsMemo: boolean;
begin
  result := Self in [ctMemo, ctRTF];
end;

function TzCtrlTypeHelper.ValidForCard: boolean;
begin
  result := True;
end;

function TzCtrlTypeHelper.ValidForView: boolean;
begin
  result := IsDataAware and not(Self in [ctRadioGroup, ctCheckGroupBox, ctDateTimeWheelPicker, ctCheckGroup]);
end;

function DateNull(const date: TDateTime): boolean;
begin
  result := (date = NullDate) or (date = -700000 { dx } );
end;

Function ChangeResourceString(resstring: PResStringRec; newvalue: Pchar): boolean;
Var
  oldprotect: DWORD;
Begin
  result := false;

  If resstring = nil Then
    Exit;

  Assert(Assigned(newvalue), 'ChangeResourceString: newvalue must be <> nil');

  result := VirtualProtect(resstring, Sizeof(resstring^), PAGE_EXECUTE_READWRITE, @oldprotect);

  If result Then
  Begin
    resstring^.Identifier := Integer(newvalue);
    VirtualProtect(resstring, Sizeof(resstring^), oldprotect, @oldprotect);
  End;
End;

end.
