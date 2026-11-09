{ *******************************************************************************
  *
  *  TExplorerDrop Component - Add Windows Explorer Drop support for TWinControl
  *                          - This component is freeware!
  *
  *
  *  Copyright (c) 2002 - Simon Grossenbacher (webmaster@swissdelphicenter.ch)
  *  All rights reserved.
  *
  *  Version history:
  *  1.1 - Added DragQueryPoint and AllowFolders property
  *  1.0 - release
  *
  *  www.SwissDelphiCenter.com - developers knowledge base.
  ******************************************************************************* }
unit ExplorerDrop;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  vcl.Controls,
  Shellapi;

type
  TOnDropped = procedure(Sender: TObject; Files: TStrings; FileCount: Integer; x, y: Integer) of object;
  TOnFolderNotAllowed = procedure(Sender: TObject; FileName: String) of object;

  TExplorerDrop = class(TComponent)
  private
    FEnabled: Boolean;
    FOnDropped: TOnDropped;
    FOnBeginDrop: TNotifyEvent;
    FDestinationControl: TWinControl;
    FDefProc: Pointer;
    FWndProcInstance: Pointer;
    FWndHandle: Hwnd;
    FFileNames: TStrings;
    FFileCount: Integer;
    FOnFolderNotAllowed: TOnFolderNotAllowed;
    FAllowFolders: Boolean;
    procedure SetDestinationControl(const Value: TWinControl);
    procedure SetEnabled(const Value: Boolean);
    procedure SetOnBeginDrop(const Value: TNotifyEvent);
    procedure SetOnDropped(const Value: TOnDropped);
    procedure Init;
    procedure Unhook;
    procedure WndProc(var Msg: TMessage);
    procedure DropFiles(hDropHandle: HDrop);
    procedure SetOnFolderNotAllowed(const Value: TOnFolderNotAllowed);
    procedure SetAllowFolders(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property FileNames: TStrings read FFileNames;
    property FileCount: Integer read FFileCount;
  published
    property Enabled: Boolean read FEnabled write SetEnabled;
    property AllowFolders: Boolean read FAllowFolders write SetAllowFolders;
    property DestinationControl: TWinControl read FDestinationControl write SetDestinationControl;
    property OnBeginDrop: TNotifyEvent read FOnBeginDrop write SetOnBeginDrop;
    property OnDropped: TOnDropped read FOnDropped write SetOnDropped;
    property OnFolderNotAllowed: TOnFolderNotAllowed read FOnFolderNotAllowed write SetOnFolderNotAllowed;
  end;

implementation

{ TExplorerDrop }

constructor TExplorerDrop.Create(AOwner: TComponent);
begin
  inherited;
  FFileNames := TStringList.Create;
end;

destructor TExplorerDrop.Destroy;
begin
  Unhook;

  FFileNames.Free;
  inherited;
end;

procedure TExplorerDrop.DropFiles(hDropHandle: HDrop);
var
  sFileName: PChar;
  iFile, iStrLen, iTempLen, iFileCount: Integer;
  DropPoint: TPoint;
begin
  if Assigned(FOnBeginDrop) then
  begin
    FOnBeginDrop(self);
  end;

  iStrLen := 128;
  sFileName := StrAlloc(iStrLen);
  iFile := 0;

  FFileNames.Clear;

  iFileCount := DragQueryFile(hDropHandle, $FFFFFFFF, nil, iStrLen);

  DragQueryPoint(hDropHandle, DropPoint);

  while (iFile < iFileCount) do
  begin
    iTempLen := DragQueryFile(hDropHandle, iFile, nil, 0) + 1;
    if (iTempLen > iStrLen) then
    begin
      iStrLen := iTempLen;
      StrDispose(sFileName);
      sFileName := StrAlloc(iStrLen);
    end;

    DragQueryFile(hDropHandle, iFile, sFileName, iStrLen);

    if not FAllowFolders then
    begin
      if FileExists(sFileName) then
      begin
        FFileNames.Add(StrPas(sFileName));
      end
      else
      begin
        If Assigned(FOnFolderNotAllowed) then
          FOnFolderNotAllowed(nil, StrPas(sFileName));
      end;
    end
    else
      FFileNames.Add(StrPas(sFileName));

    Inc(iFile);
  end;

  StrDispose(sFileName);

  FFileCount := FFileNames.Count;

  if Assigned(FOnDropped) then
    FOnDropped(self, FFileNames, FFileCount, DropPoint.x, DropPoint.y);
end;

procedure TExplorerDrop.Init;
var
  WinCtrl: TWinControl;
begin
  // un controllo gia' agganciato va sganciato prima: altrimenti la sua
  // procedura di finestra resta sostituita e l'istanza va persa
  Unhook;

  if FDestinationControl is TWinControl then
  begin
    WinCtrl := TWinControl(FDestinationControl);
    FWndHandle := WinCtrl.Handle;
    FWndProcInstance := MakeObjectInstance(WndProc);
    FDefProc := Pointer(GetWindowLongPtr(FWndHandle, GWL_WNDPROC));
    SetWindowLongPtr(FWndHandle, GWL_WNDPROC, NativeInt(FWndProcInstance));
  end
  else
    SetEnabled(false);
end;

procedure TExplorerDrop.Unhook;
begin
  // Unico punto di sgancio, e rieseguibile: azzera tutto dopo aver liberato.
  // Prima SetDestinationControl(nil) e il distruttore liberavano entrambi la
  // stessa istanza: FreeObjectInstance la reinserisce nella lista libera
  // della RTL puntando a se stessa, e ReleaseObjectInstanceBlocks (nella
  // finalization di System.Classes) gira per sempre su quell'anello:
  // l'applicazione non terminava piu' alla chiusura.
  if FWndProcInstance = nil then
    Exit;

  if (FWndHandle <> 0) and IsWindow(FWndHandle) then
    SetWindowLongPtr(FWndHandle, GWL_WNDPROC, NativeInt(FDefProc));

  FreeObjectInstance(FWndProcInstance);

  FWndProcInstance := nil;
  FDefProc := nil;
  FWndHandle := 0;
end;

procedure TExplorerDrop.SetAllowFolders(const Value: Boolean);
begin
  FAllowFolders := Value;
end;

procedure TExplorerDrop.SetDestinationControl(const Value: TWinControl);
begin
  if Value = nil then
  begin
    SetEnabled(false);
    Unhook;
    FDestinationControl := nil;
    exit;
  end
  else
  begin
    if Value <> FDestinationControl then
    begin
      FDestinationControl := Value;
      Init;
      SetEnabled(true);
    end;
  end;
end;

procedure TExplorerDrop.SetEnabled(const Value: Boolean);
begin
  if FDestinationControl = nil then
    exit;

  FEnabled := Value;

  if FWndHandle <> 0 then
    DragAcceptFiles(FWndHandle, FEnabled);
end;

procedure TExplorerDrop.SetOnBeginDrop(const Value: TNotifyEvent);
begin
  FOnBeginDrop := Value;
end;

procedure TExplorerDrop.SetOnDropped(const Value: TOnDropped);
begin
  FOnDropped := Value;
end;

procedure TExplorerDrop.SetOnFolderNotAllowed(const Value: TOnFolderNotAllowed);
begin
  FOnFolderNotAllowed := Value;
end;

procedure TExplorerDrop.WndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_DROPFILES then
    DropFiles(HDrop(Msg.wParam))
  else
    Msg.Result := CallWindowProc(FDefProc, FWndHandle, Msg.Msg, Msg.wParam, Msg.LParam);
end;

end.
