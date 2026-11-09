unit zz.Taskbar;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Win.Taskbar,
  System.Win.TaskbarCore,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Taskbar,
  Vcl.ImgList,
  dximctrl,
  cxImageList,
  cxGraphics;

type
  // TTaskbar che non lascia uscire gli errori di registrazione del pulsante.
  //
  // Vcl.Forms, sul messaggio "TaskbarButtonCreated" (a ogni nuovo handle della
  // finestra e a ogni Show dopo un Hide), chiama Initialize e
  // CheckApplyChanges senza try/except. Se Windows rifiuta RegisterTab --
  // per esempio perche' la finestra principale memorizzata in TWinTaskbar non
  // esiste piu' -- TTaskbarBase.UpdateTab solleva ETaskbarException ("Could
  // not register tab"), che arriva all'utente o interrompe lo Show.
  //
  // Sono gli unici due punti chiamati da Vcl.Forms che arrivano a UpdateTab.
  // Dopo l'errore FRegistered resta False e FChangesNeedsToBeApplied resta
  // True: al messaggio successivo il componente ritenta da solo, e nel
  // frattempo si perdono solo avanzamento e icona sovrapposta.
  TzTaskbar = class(TTaskbar)
  public
    procedure Initialize; override;
    procedure CheckApplyChanges; override;
  end;

  TTaskbarManager = record
  private
    FTaskbar: TzTaskbar;
    FState: TTaskBarProgressState;
    FIcon: TIcon;
    FProgress: integer;
    FMaxValue: integer;
    procedure SetTaskbar(const Value: TzTaskbar);
    procedure SetState(const Value: TTaskBarProgressState);
    procedure SetMaxValue(const Value: integer);
    procedure SetProgress(const Value: integer);
    procedure SetIcon(const Value: TIcon);
  private
    lastTaskBarProgressState: TTaskBarProgressState;

    procedure SetCurrentState(aState: TTaskBarProgressState);
    procedure PopLastState;
  public
    procedure Init;
    procedure Reset;

    //
    procedure None;
    procedure Normal;
    procedure Indeterminate;
    procedure Paused;
    procedure Error;

    procedure StartProgress(aMaxValue: integer);
    procedure DoProgress(aProgress: integer);
    //
    procedure BeforeException;
    procedure AfterException;

    procedure StartWait;
    procedure StopWait;

    procedure ProgressBox_Start(MaxValue: integer);
    procedure ProgressBox_Progress(Progress: integer);
    procedure ProgressBox_Paused;
    procedure ProgressBox_Stop;
  public
    // Solo TzTaskbar: un TTaskbar semplice lascerebbe di nuovo uscire gli
    // errori di registrazione del pulsante.
    property Taskbar: TzTaskbar read FTaskbar write SetTaskbar;
    property State: TTaskBarProgressState read FState write SetState;
    property MaxValue: integer read FMaxValue write SetMaxValue;
    property Progress: integer read FProgress write SetProgress;
    property Icon: TIcon read FIcon write SetIcon;
  end;

var
  TaskbarManager: TTaskbarManager;

implementation

{ TzTaskbar }

procedure TzTaskbar.Initialize;
begin
  try
    inherited;
  except
    on ETaskbarException do
    begin
      // Registrazione rifiutata da Windows: si ritenta al prossimo messaggio
    end;
  end;
end;

procedure TzTaskbar.CheckApplyChanges;
begin
  try
    inherited;
  except
    on ETaskbarException do
    begin
      // Come in Initialize
    end;
  end;
end;

{ TTaskbarManager }

procedure TTaskbarManager.Init;
begin
  FTaskbar := nil;
  FIcon := nil;
  lastTaskBarProgressState := TTaskBarProgressState.None;
  FState := TTaskBarProgressState.None;
  FMaxValue := 0;
  FProgress := 0;
end;

procedure TTaskbarManager.Reset;
begin
  // forza la normalizzazione dell'icona

  if assigned(FTaskbar) then
  begin
    try
      FTaskbar.ProgressState := TTaskBarProgressState.None;
      FTaskbar.ProgressValue := 0;
      FTaskbar.OverlayIcon := nil;
    except
      // rdp / handle non pronto
    end;
  end;
end;

procedure TTaskbarManager.SetTaskbar(const Value: TzTaskbar);
begin
  FTaskbar := Value;
  Reset;
end;

procedure TTaskbarManager.SetState(const Value: TTaskBarProgressState);
begin
  FState := Value;

  if assigned(FTaskbar) then
  begin
    try
      if FTaskbar.ProgressState <> State then
        FTaskbar.ProgressState := State;
    except
      // Silenzia l'errore se Windows (o RDP) rifiuta la registrazione della Tab
    end;
  end;
end;

procedure TTaskbarManager.SetMaxValue(const Value: integer);
begin
  FMaxValue := Value;

  if assigned(FTaskbar) then
    if FTaskbar.ProgressMaxValue <> MaxValue then
    begin
      try
        FTaskbar.ProgressMaxValue := MaxValue;
      except
        // rdp
      end;
    end;
end;

procedure TTaskbarManager.SetProgress(const Value: integer);
begin
  FProgress := Value;

  if assigned(FTaskbar) then
  begin
    try
      FTaskbar.ProgressValue := Value;
    except
      // rdp
    end;
  end;
end;

procedure TTaskbarManager.SetIcon(const Value: TIcon);
begin
  FIcon := Value;

  if assigned(FTaskbar) then
  begin
    try
      FTaskbar.OverlayIcon := Icon;
    except
      // rdp
    end;
  end;
end;

procedure TTaskbarManager.SetCurrentState(aState: TTaskBarProgressState);
begin

  if assigned(FTaskbar) then
  begin
    try
      lastTaskBarProgressState := TaskbarManager.State;
      State := aState;
    except
      // rdp
    end;
  end;
end;

procedure TTaskbarManager.PopLastState;
begin

  if assigned(FTaskbar) then
    // TaskbarManager.State := lastTaskBarProgressState;
    None;
end;

procedure TTaskbarManager.None;
begin
  SetCurrentState(TTaskBarProgressState.None);
end;

procedure TTaskbarManager.Normal;
begin
  SetCurrentState(TTaskBarProgressState.Normal);
end;

procedure TTaskbarManager.Indeterminate;
begin
  SetCurrentState(TTaskBarProgressState.Indeterminate);
end;

procedure TTaskbarManager.Paused;
begin
  SetCurrentState(TTaskBarProgressState.Paused);
end;

procedure TTaskbarManager.Error;
begin
  SetCurrentState(TTaskBarProgressState.Error);
end;

procedure TTaskbarManager.StartProgress(aMaxValue: integer);
begin

  if assigned(FTaskbar) then
  begin
    SetState(TTaskBarProgressState.Normal);
    Progress := 0;
    MaxValue := aMaxValue;
  end;
end;

procedure TTaskbarManager.DoProgress(aProgress: integer);
begin

  if assigned(FTaskbar) then
  begin
    SetState(TTaskBarProgressState.Normal);

    if aProgress < MaxValue then
      Progress := aProgress;
  end;
end;

procedure TTaskbarManager.BeforeException;
begin
  Error;
end;

procedure TTaskbarManager.AfterException;
begin
  PopLastState;
end;

procedure TTaskbarManager.StartWait;
begin
  Indeterminate;
end;

procedure TTaskbarManager.StopWait;
begin
  PopLastState;
end;

procedure TTaskbarManager.ProgressBox_Start(MaxValue: integer);
begin
  StartProgress(MaxValue);
end;

procedure TTaskbarManager.ProgressBox_Progress(Progress: integer);
begin
  DoProgress(Progress);
end;

procedure TTaskbarManager.ProgressBox_Paused;
begin
  Paused;
end;

procedure TTaskbarManager.ProgressBox_Stop;
begin
  PopLastState;
end;

initialization

TaskbarManager.Init;

end.
