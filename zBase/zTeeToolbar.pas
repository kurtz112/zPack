unit zTeeToolbar;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  dxSkinsCore,
  dxSkinsdxBarPainter,
  dxBar,
  dxBarExtItems,
  cxClasses,
  ImgList,
  ActnList,
  cxLabel,
  // Series,
  VclTee.TeeGDIPlus,
  Vcl.ExtCtrls,
  System.ImageList,
  System.Actions,
  VclTee.DBChart,
  VclTee.TeEngine,
  VclTee.TeeProcs,
  VclTee.Chart,
  VclTee.Series;

type
  TzTeeChartToolbar = class(TFrame, ITeeEventListener)
    ActionList: TActionList;
    actCopia: TAction;
    actProfondita: TAction;
    actModifica: TAction;
    actSposta: TAction;
    actNormale: TAction;
    actSalva: TAction;
    actZoom: TAction;
    act3D: TAction;

    ImageList: TImageList;
    dxBarManager: TdxBarManager;
    dxBarToolbar: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    Titolo: TdxBarStatic;
    actStampa: TAction;
    dxBarButton11: TdxBarButton;
    actEsporta: TAction;
    dxBarButton12: TdxBarButton;
    procedure act3DExecute(Sender: TObject);
    procedure actCopiaExecute(Sender: TObject);
    procedure actEsportaExecute(Sender: TObject);
    procedure actModificaExecute(Sender: TObject);
    procedure actionExecute(Sender: TObject);
    procedure actSalvaExecute(Sender: TObject);
    procedure actStampaExecute(Sender: TObject);
  private
    FChart: TCustomChart;
    procedure SetChart(const Value: TCustomChart);
  private
    procedure SaveChart;
  private
    FChartFileName: string;
    IPieSeries: TPieSeries;
    FDragging: Boolean;
    FDraggingIndex: Integer;
    FOldX: Integer;
    FOldY: Integer;
    FMouseButton: TMouseButton;
    procedure TeeEvent(Event: TTeeEvent);
    Procedure ChartMouseDown(X, Y: Integer);
    Procedure ChartMouseMove(X, Y: Integer; const Shift: TShiftState);
    Procedure ChartMouseUp;
    function GetPieSeries(X, Y: Integer): TPieSeries;
  protected
  protected
  public
    constructor Create(aOwner: TComponent); override;
    property Chart: TCustomChart read FChart write SetChart;
    property ChartFileName: string read FChartFileName write FChartFileName;
  end;

implementation

uses
  VclTee.TeeEdiGene,
  VclTee.EditChar,
  VclTee.DBEditCh,
  VclTee.TeCanvas,
  VclTee.Teexport,
  VclTee.TeeStore,
  zBaseLib,
  System.Math,
  zMsg;
{$R *.dfm}

type
  TTeePanelAccess = class(TCustomTeePanel)
  end;

constructor TzTeeChartToolbar.Create(aOwner: TComponent);
begin
  inherited;
  Titolo.Caption := 'Grafico';
  FChartFileName := '';
  FMouseButton := mbLeft;
  IPieSeries := nil;
  FDragging := False;
  FDraggingIndex := -1;

  FChart := nil;
  Titolo.Caption := 'Grafico';
  ClientHeight := 28;
end;

procedure TzTeeChartToolbar.SetChart(const Value: TCustomChart);
begin
  if Assigned(FChart) then
    TTeePanelAccess(Chart).RemoveListener(self);

  FChart := Value;
  if Assigned(FChart) then
  begin
    TTeePanelAccess(Chart).Listeners.Add(self);
    Titolo.Caption := FChart.Title.Text.Text;
    act3D.Checked := Chart.View3D;
    // Chart.OnMouseDown := ChartMouseDown;
    // Chart.OnMouseMove := ChartMouseMove;
    // Chart.OnMouseUp := ChartMouseDown;
  end;
end;

procedure TzTeeChartToolbar.act3DExecute(Sender: TObject);
begin
  Chart.View3D := not Chart.View3D;
end;

procedure TzTeeChartToolbar.actCopiaExecute(Sender: TObject);
begin
  if Assigned(FChart) then
  begin
    actCopia.Enabled := False;
    try
      FChart.CopyToClipboardBitmap;
    finally
      actCopia.Enabled := True;
    end;
    ConfirmOk('Grafico copiato nella clipboard.');
  end;
end;

procedure TzTeeChartToolbar.actModificaExecute(Sender: TObject);
begin
  if Assigned(FChart) then
  begin
    EditChart(nil, FChart);
    SaveChart;
    act3D.Checked := Chart.View3D;
  end;
end;

procedure TzTeeChartToolbar.actionExecute(Sender: TObject);
begin
  // actNormale.Caption := 'Normale: ' + BoolToStr(actNormale.Checked, True);
  // actSposta.Caption := 'Sposta: ' + BoolToStr(actSposta.Checked, True);
  // actZoom.Caption := 'Zoom: ' + BoolToStr(actZoom.Checked, True);
  // actProfondita.Caption := 'Profondita: ' + BoolToStr(actProfondita.Checked, True);
end;

procedure TzTeeChartToolbar.actSalvaExecute(Sender: TObject);
begin
  actSalva.Enabled := False;
  try
    SaveChart;
  finally
    actSalva.Enabled := True;
  end;
  ConfirmOk('Impostazioni del grafico salvate.');
end;

procedure TzTeeChartToolbar.actStampaExecute(Sender: TObject);
begin
  ChartPreview(self, Chart);
end;

function TzTeeChartToolbar.GetPieSeries(X, Y: Integer): TPieSeries;

var
  t: Integer;
  tmp: TChartSeries;
  tmpPart: TChartClickedPart;
begin
  result := nil;

  if not Assigned(FChart) then
    Exit;

  Chart.CalcClickedPart(TeePoint(X, Y), tmpPart);

  if (tmpPart.Part = cpSeries) and (tmpPart.ASeries is TPieSeries) then
    result := tmpPart.ASeries as TPieSeries
  else
    for t := 0 to Chart.SeriesCount - 1 do
    begin
      tmp := Chart.Series[t];

      if (tmp is TPieSeries) and tmp.Active then
      begin
        result := tmp as TPieSeries;
        Exit;
      end;
    end;
end;

procedure TzTeeChartToolbar.ChartMouseDown(X, Y: Integer);
begin
  if (not actNormale.Checked) or (not Chart.Canvas.SupportsFullRotation) then
    IPieSeries := GetPieSeries(X, Y)
  else
    IPieSeries := nil;

  if Assigned(IPieSeries) or actNormale.Checked then
  begin
    FDragging := True;
    FOldX := X;
    FOldY := Y;

    if Assigned(IPieSeries) then
      FDraggingIndex := IPieSeries.Clicked(X, Y)
    else
      FDraggingIndex := -1;

    Chart.CancelMouse := (FDraggingIndex <> -1) or actNormale.Checked;
  end;
end;

procedure TzTeeChartToolbar.ChartMouseMove(X, Y: Integer; const Shift: TShiftState);

  Procedure Set3D;
  begin
    Chart.View3D := True;
    act3D.Checked := True;
  end;

  Procedure DoMove;
  begin
    Set3D;

    With Chart.View3DOptions do
    begin
      HorizOffset := HorizOffset + (X - FOldX);
      VertOffset := VertOffset + (Y - FOldY);
    end;

    FOldX := X;
    FOldY := Y;
  end;

  Procedure DoZoom;

  var
    tmp: Double;
    tmp2: Double;
  begin
    Set3D;
    With Chart, View3DOptions do
    begin
      tmp := (10.0 * (FOldY - Y) / TeeDistance(ChartWidth, ChartHeight));

      tmp2 := (10.0 * tmp * ZoomFloat / 100.0);
      if tmp > 0 then
        ZoomFloat := ZoomFloat + System.Math.Max(1, tmp2)
      else
        if tmp < 0 then
          ZoomFloat := System.Math.Max(1, ZoomFloat + System.Math.Min(-1, tmp2));
    end;

    FOldY := Y;
  end;

  Function CalcDistPercent(APercent, AWidth, AHeight: Integer): Integer;
  begin
    result := Round(1.0 * APercent * TeeDistance(FOldX - X, FOldY - Y) / TeeDistance(AWidth, AHeight));
  end;

  Procedure DoDepth;

  var
    tmp: Integer;
  begin
    if Chart is TCustomAxisPanel then
      With TCustomAxisPanel(Chart) do
      begin
        Set3D;
        tmp := CalcDistPercent(200, ChartWidth, ChartHeight);
        if (tmp >= 1) then
          Chart3DPercent := System.Math.Min(100, tmp);
      end;
  end;

  Procedure DoNormal;

  Var
    tmp: Integer;
  begin
    if FDraggingIndex <> -1 then
    begin
      if Assigned(IPieSeries) then
        With IPieSeries do
        begin
          tmp := System.Math.Min(100, CalcDistPercent(100, CircleWidth, CircleHeight));
          ExplodedSlice[FDraggingIndex] := tmp;
        end;
    end;
  end;

begin
  if FDragging then
  begin
    FDragging := False;

    if actNormale.Checked then
      DoNormal { first do this !!! }
    else
      if FMouseButton = mbRight then
        DoMove
      else
        // if IsButtonDown(FButtonRotate) then
        // if ssCtrl in Shift then
        // DoZoom // 7.07
        // else
        // if ssShift in Shift then
        // DoMove // 8.02
        // else
        // DoRotate
        // else
        if actSposta.Checked then
        begin
          if ssCtrl in Shift then
            DoZoom // 7.07
          else
            // if ssShift in Shift then
            // DoRotate // 8.02
            // else
            DoMove
        end
        else
          if actZoom.Checked then
          begin
            // if ssCtrl in Shift then
            // DoRotate // 8.02
            // else
            if ssShift in Shift then
              DoMove
            else
              DoZoom
          end
          else
            if actProfondita.Checked then
              DoDepth;

    FDragging := True;
  end;
end;

procedure TzTeeChartToolbar.ChartMouseUp;
begin
  IPieSeries := nil;
  FDragging := False;
  FDraggingIndex := -1;
end;

procedure TzTeeChartToolbar.SaveChart;
begin
  if ChartFileName <> '' then
    SaveChartToFile(FChart, ChartFileName, False, True);
end;

procedure TzTeeChartToolbar.TeeEvent(Event: TTeeEvent);

var
  MouseEvent: TTeeMouseEvent;
begin
  if not(Event is TTeeMouseEvent) then
    Exit;

  MouseEvent := TTeeMouseEvent(Event);

  begin
    Case MouseEvent.Event of
      meDown:
        begin
          FMouseButton := MouseEvent.Button;
          ChartMouseDown(MouseEvent.X, MouseEvent.Y);
        end;

      meUp:
        ChartMouseUp;

      meMove:
        ChartMouseMove(MouseEvent.X, MouseEvent.Y, MouseEvent.Shift);
    end;

    MouseEvent.Sender.CancelMouse := actNormale.Checked;
  end;
end;

procedure TzTeeChartToolbar.actEsportaExecute(Sender: TObject);
begin
  TeeExport(self, Chart);
end;

end.
