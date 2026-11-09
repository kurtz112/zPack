unit zz.Lib;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Rtti,
  FMX.Edit,
  FMX.Dialogs;

type // usata unicamente da WinEco
  iFrameBeforeShow = interface
    ['{0212BC2D-5F00-434E-A154-56CB848B4A27}']
    procedure BeforeShow(const forward: Boolean = true);
  end;

procedure AskConfirm(const Msg: string; procYes: TProc; procNo: TProc);
procedure Warning(const Msg: string; procYes: TProc; procNo: TProc);
procedure ShowError(const Msg: string; proc: TInputCloseDialogProc = nil);
procedure ShowMsg(const Msg: string; proc: TInputCloseDialogProc = nil);

function StrToChar(s: string): char;

function GetSelectedValue(AObject: TObject): TValue;

procedure doInputBox(const Caption: string; Edit: TEdit);

function Versione: string;

Function GetIPAddress(const Mask: string): String;

function HashPwd(const Password: string): string;

function IsWindows: Boolean;
function IsAndroid: Boolean;

function BytesToString(const Bytes: Int64): string;

implementation

uses
{$IFDEF ANDROID}
  FMX.Helpers.Android,
  androidapi.JNI.JavaTypes,
  androidapi.JNI.Os,
  androidapi.JNI.GraphicsContentViewText,
  androidapi.Helpers,
{$ENDIF}
  System.Math,
  Data.Bind.Components,
  FMX.DialogService,
  System.Threading,
  idGlobal,
  IdStack;

procedure AskConfirm(const Msg: string; procYes: TProc; procNo: TProc);
begin
  MessageDlg(Msg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        { Detect which button was pushed and show a different message }
        mrYes:
          begin
            if assigned(procYes) then
              procYes;
          end;
        mrNo:
          begin
            if assigned(procNo) then
              procNo;
          end;
      end;
    end);
end;

procedure Warning(const Msg: string; procYes: TProc; procNo: TProc);
begin
  MessageDlg(Msg, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        { Detect which button was pushed and show a different message }
        mrYes:
          begin
            if assigned(procYes) then
              procYes;
          end;
        mrNo:
          begin
            if assigned(procNo) then
              procNo;
          end;
      end;
    end);
end;

function StrToChar(s: string): char;
begin
  Result := #0;
  for Result in s do
    Exit; // deve uscire al primo char..
end;

function GetSelectedValue(AObject: TObject): TValue;
var
  LEditor: IBindListEditorCommon;
begin
  LEditor := GetBindEditor(AObject, IBindListEditorCommon) as IBindListEditorCommon;
  Result := LEditor.SelectedValue
end;

procedure ShowMsg(const Msg: string; proc: TInputCloseDialogProc = nil);
begin
  if TThread.Current.ThreadID = MainThreadID then
    TDialogService.ShowMessage(Msg, proc)
  else
    TThread.Synchronize(TThread.CurrentThread,
      procedure()
      begin
        TDialogService.ShowMessage(Msg, proc);
      end);
end;

procedure ShowError(const Msg: string; proc: TInputCloseDialogProc = nil);
begin
  ShowMsg(Msg, proc);
  // TDialogService.MessageDialog(Msg, TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], TMsgDlgBtn.mbOk, 0,
  // procedure(const AResult: TModalResult)
  // begin
  //
  // end);
end;

procedure doInputBox(const Caption: string; Edit: TEdit);
begin
  InputBox(Caption, Caption, Edit.Text,
    procedure(const AResult: TModalResult; const AValue: string)
    begin
      case AResult of
        mrOk:
          begin
            Edit.Text := AValue;
          end;
        mrCancel:
          begin
          end;
      end;
    end);
end;

function Versione: string;
begin
{$IFDEF ANDROID}
  Result := JStringToString(SharedActivityContext.getPackageManager.getPackageInfo(SharedActivityContext.getPackageName(), 0).versionName);
{$ELSE}
  Result := '1.0.0.0'; // qualora servisse si potrebbe recuperare da ios/win32
{$ENDIF}
end;

Function GetIPAddress(const Mask: string): String;
var
  I: Integer;
  IdStackLocalAddressList: TIdStackLocalAddressList;
begin
  Result := '';

  TIdStack.IncUsage;
  try
    IdStackLocalAddressList := TIdStackLocalAddressList.Create;
    try
      GStack.GetLocalAddressList(IdStackLocalAddressList);

      for I := 0 to IdStackLocalAddressList.Count - 1 do
      begin
        if IdStackLocalAddressList[I].IPVersion = Id_IPv4 then
          if IdStackLocalAddressList[I].IPAddress.StartsWith(Mask) then
            Exit(IdStackLocalAddressList[I].IPAddress);
      end;
    finally
      FreeAndNil(IdStackLocalAddressList);
    end;
  finally
    TIdStack.DecUsage;
  end;
end;

// Mattia 21/10/2018
function HashPwd(const Password: string): string;
const
  base = 'ds43aF32SJAKlfa=';

var
  I, c, partenza: Integer;
  value_base: Byte;
  value_password: Byte;
  value_xor: Byte;
  word_xor: SmallInt;
  block_hash, block_password, temp: string;
begin
  Result := '';

  // init valore j su tutta la stringa da convertire
  partenza := 0;
  for I := 1 to Length(Password) do
  BEGIN
    partenza := 93 * ord(Password[I]) + partenza;
    partenza := partenza mod 256;
  END;

  c := 1;
  while (c <= Length(Password)) do
  begin

    block_password := Copy(Password, c, 16);

    // Calcolo hash facendo XOR per byte tra J la stringa BASE e la PASSWORD
    block_hash := '';
    for I := 1 to 16 do
    begin
      value_base := ord(base[I]);

      if I <= Length(block_password) then
        value_password := ord(block_password[I])
      else
        value_password := 0;

      value_xor := value_base xor value_password xor partenza;

      // il blocco di 2 carattere di hash è il valore esadecimale della variabile VALUE_XOR
      block_hash := Concat(block_hash, IntToHex(value_xor));

      partenza := (value_xor mod 256);
    end;

    if (c = 1) then
      Result := block_hash
    else
    begin
      // Nel caso di più blocchi di 16 caratteri faccio XOR del risultato con quello già calcolato
      temp := '';
      I := 1;
      while (I < 32) do
      begin
        value_xor := StrToInt('$' + Copy(block_hash, I, 2)) xor StrToInt('$' + Copy(Result, I, 2));
        temp := Concat(temp, IntToHex(value_xor));
        Inc(I, 2);
      end;
      Result := temp;
    end;

    c := c + 16;
  end;
end;

function IsWindows: Boolean;
begin
  Result := TOSVersion.Platform = pfWindows;
end;

function IsAndroid: Boolean;
begin
  Result := TOSVersion.Platform = pfAndroid;
end;

function BytesToString(const Bytes: Int64): string;
const
  Description: Array [0 .. 8] of string = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
var
  I: Integer;
begin
  I := 0;

  while Bytes > Power(1024, I + 1) do
    Inc(I);

  Result := FormatFloat('###0.##', Bytes / Power(1024, I)) + #32 + Description[I];
end;

end.

  uses androidapi.JNIBridge, androidapi.JNI.Media;

procedure Sound
(ADuration: Integer);

implementation

var
  Volume: Integer;
  StreamType: Integer;
  ToneType: Integer;
  ToneGenerator: JToneGenerator;
begin

  Volume := TJToneGenerator.JavaClass.MAX_VOLUME;

  StreamType := ? ToneType := TJToneGenerator.JavaClass.TONE_DTMF_0;

  ToneGenerator := TJToneGenerator.JavaClass.init(StreamType, Volume);
  ToneGenerator.startTone(ToneType, ADuration);

end;
