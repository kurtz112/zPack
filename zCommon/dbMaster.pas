unit dbMaster;

{ TdbMaster (C)opyright 1998 Version 1.0
  Author : Jeff Swim
  eMail : doodler@doodler.com
  Internet : http://www.doodler.com }

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.TimeSpan,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  data.DB,
  SmartInspect.vcl.SiAuto,
  SmartInspect.vcl;

type
  TOnCloseOperation = (ocPost, ocCancel);
  TOnOpenProgress = procedure(Sender: TObject; ItemName: string; ItemNo: integer) of object;
  TOnSlowDataSet = procedure(Sender: TObject; ItemName: string; DataSet: TDataSet; TimeSpan: TTimeSpan) of object;

  TDataSetItem = class(TCollectionItem)
  private
    FDataSet: TDataSet;
    FBeforeOpen: TNotifyEvent;
    FAfterOpen: TNotifyEvent;
    FBeforeClose: TNotifyEvent;
    FAfterClose: TNotifyEvent;
    FBeforeCancel: TNotifyEvent;
    FAfterCancel: TNotifyEvent;
    FBeforePost: TNotifyEvent;
    FAfterPost: TNotifyEvent;
    FBeforeRefresh: TNotifyEvent;
    FAfterRefresh: TNotifyEvent;
    FIncludeInOpen: boolean;
    FIncludeInClose: boolean;
    FIncludeInCancel: boolean;
    FIncludeInPost: boolean;
    FIncludeInRefresh: boolean;
    FOnClose: TOnCloseOperation;
    FDisplayName: string;
    procedure SetDataSet(const Value: TDataSet);
  protected
    procedure SetDisplayName(const Value: string); override;
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property DisplayName;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property IncludeInOpen: boolean read FIncludeInOpen write FIncludeInOpen default True;
    property IncludeInClose: boolean read FIncludeInClose write FIncludeInClose default True;
    property IncludeInPost: boolean read FIncludeInPost write FIncludeInPost default True;
    property IncludeInCancel: boolean read FIncludeInCancel write FIncludeInCancel default True;
    property IncludeInRefresh: boolean read FIncludeInRefresh write FIncludeInRefresh default True;
    property OnClose: TOnCloseOperation read FOnClose write FOnClose;
    property BeforeOpen: TNotifyEvent read FBeforeOpen write FBeforeOpen;
    property AfterOpen: TNotifyEvent read FAfterOpen write FAfterOpen;
    property BeforeClose: TNotifyEvent read FBeforeClose write FBeforeClose;
    property AfterClose: TNotifyEvent read FAfterClose write FAfterClose;
    property BeforeCancel: TNotifyEvent read FBeforeCancel write FBeforeCancel;
    property AfterCancel: TNotifyEvent read FAfterCancel write FAfterCancel;
    property BeforePost: TNotifyEvent read FBeforePost write FBeforePost;
    property AfterPost: TNotifyEvent read FAfterPost write FAfterPost;
    property AfterRefresh: TNotifyEvent read FAfterRefresh write FAfterRefresh;
    property BeforeRefresh: TNotifyEvent read FBeforeRefresh write FBeforeRefresh;
  end;

  TDataSetCollection = class(TCollection)
  protected
    FOwner: TPersistent;
    function GetOwner: TPersistent; override;
    function GetItem(Index: integer): TDataSetItem;
    procedure SetItem(Index: integer; Value: TDataSetItem);
  public
    property Items[Index: integer]: TDataSetItem read GetItem write SetItem; default;
  end;

  TdbMaster = class(TComponent)
  private
    FDataSets: TDataSetCollection;
    FOpenInDesigner: boolean;
    FAutoOpen: boolean;
    FAutoClose: boolean;
    fOnOpenProgress: TOnOpenProgress;
    FBeforeRefresh: TNotifyEvent;
    FAfterClose: TNotifyEvent;
    FBeforeOpen: TNotifyEvent;
    FBeforePost: TNotifyEvent;
    FBeforeCancel: TNotifyEvent;
    FAfterRefresh: TNotifyEvent;
    FBeforeClose: TNotifyEvent;
    FAfterOpen: TNotifyEvent;
    FAfterPost: TNotifyEvent;
    FAfterCancel: TNotifyEvent;
    FOnClose: TOnCloseOperation;
    FOnSlowDataSet: TOnSlowDataSet;
  protected
    procedure SetCollection(const Value: TDataSetCollection);
    procedure SetOpenInDesigner(Value: boolean);
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenAll;
    procedure CloseAll;
    procedure CancelAll;
    procedure PostAll;
    procedure RefreshAll;
    function IsModified: boolean; virtual;
    function OpenCount: integer;
    function AddDataSet(const DisplayName: string; DataSet: TDataSet): TDataSetItem;
    function FindDataSetItem(const DisplayName: string): TDataSetItem;
  published
    property DataSets: TDataSetCollection read FDataSets write SetCollection;
    property OpenInDesigner: boolean read FOpenInDesigner write SetOpenInDesigner stored false;
    property AutoOpen: boolean read FAutoOpen write FAutoOpen default True;
    property AutoClose: boolean read FAutoClose write FAutoClose default True;
    property OnOpenProgress: TOnOpenProgress read fOnOpenProgress write fOnOpenProgress;
    property OnSlowDataSet: TOnSlowDataSet read FOnSlowDataSet write FOnSlowDataSet;
    property OnClose: TOnCloseOperation read FOnClose write FOnClose;
    property BeforeOpen: TNotifyEvent read FBeforeOpen write FBeforeOpen;
    property AfterOpen: TNotifyEvent read FAfterOpen write FAfterOpen;
    property BeforeClose: TNotifyEvent read FBeforeClose write FBeforeClose;
    property AfterClose: TNotifyEvent read FAfterClose write FAfterClose;
    property BeforeCancel: TNotifyEvent read FBeforeCancel write FBeforeCancel;
    property AfterCancel: TNotifyEvent read FAfterCancel write FAfterCancel;
    property BeforePost: TNotifyEvent read FBeforePost write FBeforePost;
    property AfterPost: TNotifyEvent read FAfterPost write FAfterPost;
    property BeforeRefresh: TNotifyEvent read FBeforeRefresh write FBeforeRefresh;
    property AfterRefresh: TNotifyEvent read FAfterRefresh write FAfterRefresh;
  end;

implementation

uses
  Diagnostics;

constructor TDataSetItem.Create(Collection: TCollection);
begin
  inherited;
  FIncludeInOpen := True;
  FIncludeInClose := True;
  FIncludeInCancel := True;
  FIncludeInPost := True;
  FIncludeInRefresh := True;
end;

procedure TDataSetItem.SetDisplayName(const Value: string);
begin
  FDisplayName := Value;
  inherited SetDisplayName(Value);
end;

function TDataSetItem.GetDisplayName: string;
begin
  result := inherited GetDisplayName;
  result := FDisplayName;
end;

procedure TDataSetItem.Assign(Source: TPersistent);
begin
  if Source is TDataSetItem then
  begin
    // R-214 DIV-DBM-3 - 2026-11-01: il nome non era copiato e inherited Assign sollevava EConvertError
    DisplayName := TDataSetItem(Source).DisplayName;
    DataSet := TDataSetItem(Source).DataSet;
    IncludeInOpen := TDataSetItem(Source).IncludeInOpen;
    IncludeInClose := TDataSetItem(Source).IncludeInClose;
    IncludeInPost := TDataSetItem(Source).IncludeInPost;
    IncludeInCancel := TDataSetItem(Source).IncludeInCancel;
    IncludeInRefresh := TDataSetItem(Source).IncludeInRefresh;
    OnClose := TDataSetItem(Source).OnClose;
    BeforeOpen := TDataSetItem(Source).BeforeOpen;
    AfterOpen := TDataSetItem(Source).AfterOpen;
    BeforeClose := TDataSetItem(Source).BeforeClose;
    AfterClose := TDataSetItem(Source).AfterClose;
    BeforeCancel := TDataSetItem(Source).BeforeCancel;
    AfterCancel := TDataSetItem(Source).AfterCancel;
    BeforePost := TDataSetItem(Source).BeforePost;
    AfterPost := TDataSetItem(Source).AfterPost;
    BeforeRefresh := TDataSetItem(Source).BeforeRefresh;
    AfterRefresh := TDataSetItem(Source).FAfterRefresh;
  end
  else
    inherited Assign(Source);
end;

procedure TDataSetItem.SetDataSet(const Value: TDataSet);
var
  Comp: TComponent;
begin
  if FDataSet <> Value then
  begin
    Comp := TComponent(Collection.Owner);
    if (FDataSet <> nil) and (Comp <> nil) then
      FDataSet.RemoveFreeNotification(Comp);
    FDataSet := Value;
    if (FDataSet <> nil) and (Comp <> nil) then
      FDataSet.FreeNotification(Comp);
  end;
end;

function TDataSetCollection.GetOwner: TPersistent;
begin
  result := FOwner;
end;

function TDataSetCollection.GetItem(Index: integer): TDataSetItem;
begin
  result := TDataSetItem(inherited GetItem(Index));
end;

procedure TDataSetCollection.SetItem(Index: integer; Value: TDataSetItem);
begin
  inherited SetItem(Index, Value);
end;

constructor TdbMaster.Create(AOwner: TComponent);
begin
  inherited;
  fOnOpenProgress := nil;
  FDataSets := TDataSetCollection.Create(TDataSetItem);
  FDataSets.FOwner := Self;
  FAutoOpen := True;
  FAutoClose := True;
  FOpenInDesigner := false;
end;

destructor TdbMaster.Destroy;
begin
  if not(csDesigning in ComponentState) and (AutoClose) then
    CloseAll;

  FDataSets.Free;
  inherited;
end;

function TdbMaster.AddDataSet(const DisplayName: string; DataSet: TDataSet): TDataSetItem;
begin
  result := FindDataSetItem(DisplayName);

  if assigned(result) then
    Exit;

  // se non lo trova lo aggiunge
  result := DataSets.Add as TDataSetItem;
  result.DisplayName := DisplayName;
  result.DataSet := DataSet;
end;

function TdbMaster.IsModified: boolean;
var
  idx: integer;
  item: TDataSetItem;
begin
  result := false;
  for idx := 0 to FDataSets.Count - 1 do
  begin
    item := TDataSetItem(FDataSets.Items[idx]);
    if not assigned(item.DataSet) then
      continue;
    with item.DataSet do
    begin
      if Active = false then
        continue;

      if State in dsEditModes then
        try
          UpdateRecord;
        except
        end;

      if Modified or (State = dsInsert) then
      begin
        result := True;
        break;
      end;
    end;
  end;
end;

procedure TdbMaster.OpenAll;
var
  idx: integer;
  item: TDataSetItem;
  Stopwatch: TStopwatch;
begin
  SiMain.EnterMethod(Self, 'OpenAll');
  Stopwatch := TStopwatch.Create;
  // Stopwatch.IsHighResolution := True;

  if assigned(BeforeOpen) then
    BeforeOpen(Self);

  for idx := 0 to FDataSets.Count - 1 do
  begin
    Application.ProcessMessages;

    item := TDataSetItem(FDataSets.Items[idx]);
    if assigned(fOnOpenProgress) then
      OnOpenProgress(Self, item.DisplayName, idx);

    if not assigned(item.DataSet) then
      continue;

    if item.IncludeInOpen then
    begin
      // ShowMessage(item.DisplayName);
      if assigned(item.BeforeOpen) then
        item.BeforeOpen(item);
      //
      OutputDebugString(PChar('Opening Dataset: + ' + item.DisplayName));

      Stopwatch.Start;

      try
        item.DataSet.Open;
      except
        on e: exception do
        begin
          ShowMessage('Errore apertura dataset ' + item.DisplayName);
          raise;
        end;
      end;

      Stopwatch.Stop;

      OutputDebugString(PChar('Open Dataset + ' + item.DisplayName + ' Tempo: ' + Stopwatch.Elapsed));

      if Stopwatch.Elapsed.Seconds > 3 then
      begin
        SiMain.LogSeparator;

        if Stopwatch.Elapsed.Seconds > 60 then
          SiMain.LogColored(clRed, 'Tempo di apertura elevato: ' + item.DisplayName)
        else
          if Stopwatch.Elapsed.Seconds > 30 then
            SiMain.LogColored(clYellow, 'Tempo di apertura elevato: ' + item.DisplayName)
          else
            if Stopwatch.Elapsed.Seconds > 10 then
              SiMain.LogColored(clAqua, 'Tempo di apertura elevato: ' + item.DisplayName);

        SiMain.LogInteger('Secondi', Stopwatch.Elapsed.Seconds);

        if assigned(FOnSlowDataSet) then
          OnSlowDataSet(Self, item.DisplayName, item.DataSet, Stopwatch.Elapsed);
      end;

      Stopwatch.Reset;
      //
      if assigned(item.AfterOpen) then
        item.AfterOpen(item);
    end;
  end;
  if assigned(AfterOpen) then
    AfterOpen(Self);
  SiMain.LeaveMethod(Self, 'OpenAll');
end;

procedure TdbMaster.CloseAll;
var
  idx: integer;
  item: TDataSetItem;
begin
  if assigned(BeforeClose) then
    BeforeClose(Self);
  for idx := 0 to FDataSets.Count - 1 do
  begin
    item := TDataSetItem(FDataSets.Items[idx]);
    OutputDebugString(PChar('Closing Dataset: ' + item.DisplayName));

    if assigned(item.DataSet) then
      if (item.IncludeInClose) and (item.DataSet.Active) then
      begin
        if assigned(item.BeforeClose) then
          item.BeforeClose(item);
        if item.DataSet.State in [dsEdit, dsInsert] then
          case item.OnClose of
            ocPost:
              item.DataSet.Post;
            ocCancel:
              item.DataSet.Cancel;
          end;
        item.DataSet.Close;
        if assigned(item.AfterClose) then
          item.AfterClose(item);
      end;
  end;
  if assigned(AfterClose) then
    AfterClose(Self);
end;

procedure TdbMaster.CancelAll;
var
  idx: integer;
  item: TDataSetItem;
begin
  if assigned(BeforeCancel) then
    BeforeCancel(item);

  for idx := 0 to FDataSets.Count - 1 do
  begin
    item := TDataSetItem(FDataSets.Items[idx]);
    if not assigned(item.DataSet) then
      continue;

    if (item.IncludeInCancel) and (item.DataSet.Active) and (item.DataSet.State in [dsEdit, dsInsert]) then
    begin
      if assigned(item.BeforeCancel) then
        item.BeforeCancel(item);

        item.DataSet.Cancel;

      if assigned(item.AfterCancel) then
        item.AfterCancel(item);
    end;
  end;
  if assigned(AfterCancel) then
    AfterCancel(Self);
end;

function TdbMaster.FindDataSetItem(const DisplayName: string): TDataSetItem;
var
  idx: integer;
begin
  result := nil;

  for idx := 0 to FDataSets.Count - 1 do
    if SameText(TDataSetItem(FDataSets.Items[idx]).DisplayName, DisplayName) then
    begin
      result := FDataSets.Items[idx];
      Exit;
    end;
end;

procedure TdbMaster.PostAll;
var
  idx: integer;
  item: TDataSetItem;
begin
  if assigned(BeforePost) then
    BeforePost(item);
  for idx := 0 to FDataSets.Count - 1 do
  begin
    item := TDataSetItem(FDataSets.Items[idx]);
    if not assigned(item.DataSet) then
      continue;
    if (item.IncludeInPost) and (item.DataSet.Active) and (item.DataSet.State in [dsEdit, dsInsert]) then
    begin
      if assigned(item.BeforePost) then
        item.BeforePost(item);
      item.DataSet.Post;
      if assigned(item.AfterPost) then
        item.AfterPost(item);
    end;
  end;
  if assigned(AfterPost) then
    AfterPost(Self);
end;

procedure TdbMaster.RefreshAll;
var
  idx: integer;
  item: TDataSetItem;
begin
  if assigned(BeforeRefresh) then
    BeforeRefresh(Self);
  for idx := 0 to FDataSets.Count - 1 do
  begin
    item := TDataSetItem(FDataSets.Items[idx]);
    if not assigned(item.DataSet) then
      continue;
    if (item.IncludeInRefresh) and (item.DataSet.Active) then
    begin
      if assigned(item.BeforeRefresh) then
        item.BeforeRefresh(item);
      item.DataSet.Refresh;
      if assigned(item.AfterRefresh) then
        item.AfterRefresh(item);
    end;
  end;
  if assigned(AfterRefresh) then
    AfterRefresh(item);
end;

procedure TdbMaster.SetOpenInDesigner(Value: boolean);
begin
  if Value <> FOpenInDesigner then
  begin
    FOpenInDesigner := Value;
    if csDesigning in ComponentState then
      if FOpenInDesigner then
        OpenAll
      else
        CloseAll;
  end;
end;

procedure TdbMaster.SetCollection(const Value: TDataSetCollection);
begin
  FDataSets.Assign(Value);
end;

procedure TdbMaster.Loaded;
begin
  inherited;
  if ((csDesigning in ComponentState) and (OpenInDesigner)) or (not(csDesigning in ComponentState) and (AutoOpen)) then
    OpenAll;
end;

procedure TdbMaster.Notification(AComponent: TComponent; Operation: TOperation);
var
  idx: integer;
  item: TDataSetItem;
begin
  inherited Notification(AComponent, Operation);

  if not(csDestroying in ComponentState) and (Operation = opRemove) and assigned(FDataSets) then
    if AComponent is TDataSet then
      for idx := 0 to FDataSets.Count - 1 do
      begin
        item := TDataSetItem(FDataSets.Items[idx]);
        if assigned(item.DataSet) then
          if item.DataSet = AComponent then
          begin
            FDataSets.Delete(idx);
            break;
          end;
      end;
end;

function TdbMaster.OpenCount: integer;
var
  idx: integer;
begin
  result := 1;
  for idx := 0 to FDataSets.Count - 1 do
    if FDataSets[idx].IncludeInOpen then
      inc(result);
end;

end.
