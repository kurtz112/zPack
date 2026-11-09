unit PageControlController;

interface

uses
  SysUtils,
  Controls,
  Classes,
  Forms,
  cxPC,
  Generics.Collections,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TPageControlController = class(TComponent)
  private
    FDisableCalcSize: boolean;
    PageControlEvents: TDictionary<TcxPageControl, TNotifyEvent>;
    procedure Base_PageControlChange(Sender: TObject);
  private
    procedure InternalActivateDataSets(PageControl: TcxPageControl);
    procedure doInitPageControls(CtrlsOwner: TComponent);

    function CalcMaxHeight: integer;
    procedure CalcPageControlSize(PageControl: TcxPageControl);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  public
    procedure InitForm(Form: TForm);
    procedure InitFrame(Frame: TFrame);
    procedure InitContainer(Container: TControl);

    procedure ResetActivePages;
    procedure ActivateDataSets;
    procedure AutoSizePageControls;

    property DisableCalcSize: boolean read FDisableCalcSize write FDisableCalcSize;
  end;

implementation

uses
  zSystem,
  zDbCard,
  zDbView,
  Math,
  Graphics;

var
  siPageControlController: TSiSession;

constructor TPageControlController.Create(aOwner: TComponent);
begin
  assert(Assigned(aOwner));
  inherited;
  FDisableCalcSize := False;
  PageControlEvents := TDictionary<TcxPageControl, TNotifyEvent>.Create;
end;

destructor TPageControlController.Destroy;
begin
  FreeAndNil(PageControlEvents);
  inherited;
end;

procedure TPageControlController.InternalActivateDataSets(PageControl: TcxPageControl);

  procedure enum(Owner: TWinControl);
  var
    I: integer;
    Ctrl: TControl;
  begin
    if not Assigned(Owner) then
      Exit;

    for I := 0 to Owner.ControlCount - 1 do
    begin
      Ctrl := Owner.Controls[I];

      if Ctrl is TzDbCard then
      begin
        TzDbCard(Ctrl).ActivateDataSet;
        TzDbCard(Ctrl).ForceDisplay;
      end
      else
        if Ctrl is TzDbView then
          TzDbView(Ctrl).ActivateDataSet
        else
          if Ctrl is TcxPageControl then
            enum(TcxPageControl(Ctrl).ActivePage)
          else
            if Ctrl is TWinControl then
              enum(TWinControl(Ctrl));
    end;
  end;

begin
  if Assigned(PageControl) then
  begin
    siPageControlController.LogWarning(PageControl.Name);
    enum(PageControl.ActivePage);
  end;
end;

procedure TPageControlController.ActivateDataSets;

  function PageControlVisible(PageControl: TcxPageControl): boolean;
  var
    Ctrl: TControl;

    function TabVisible(tab: TcxTabSheet): boolean;
    begin
      result := False;

      if tab.Visible then
        if tab.PageControl.ActivePage = tab then
          result := true;
    end;

  begin
    assert(Assigned(PageControl));

    result := true;

    if not PageControl.Visible then
      Exit(False);

    Ctrl := PageControl.Parent;
    while Assigned(Ctrl) do
    begin
      if Ctrl is TcxTabSheet then
        if not TabVisible(TcxTabSheet(Ctrl)) then
          Exit(False);

      Ctrl := Ctrl.Parent;
    end;
  end;

var
  Comp: TComponent;
  pc: TcxPageControl;
begin
  // siPageControlController.LogVerbose('AttivaPageControls');
  for Comp in Owner do
    if Comp is TcxPageControl then
    begin
      pc := TcxPageControl(Comp);
      if PageControlVisible(pc) then
        InternalActivateDataSets(pc);
    end;
end;

procedure TPageControlController.AutoSizePageControls;
var
  Comp: TComponent;
begin
  // siPageControlController.LogVerbose('AutoSizePageControls');

  for Comp in Owner do
    if Comp is TcxPageControl then
      CalcPageControlSize(TcxPageControl(Comp));
end;

procedure TPageControlController.Base_PageControlChange(Sender: TObject);
var
  OriginalOnChange: TNotifyEvent;
  PageControl: TcxPageControl;
begin
  if Sender is TcxPageControl then
  begin
    PageControl := TcxPageControl(Sender);

    InternalActivateDataSets(PageControl);
    CalcPageControlSize(PageControl);

    if PageControlEvents.ContainsKey(PageControl) then
    begin
      OriginalOnChange := PageControlEvents.Items[PageControl];
      OriginalOnChange(Sender);
    end;
  end;
end;

procedure TPageControlController.doInitPageControls(CtrlsOwner: TComponent);

  // Mantis non indicato - 2026-11-03: DIV-PGC-3, le schede si cercano fra i controlli figli (come CalcPageControlSize) e non fra i componenti posseduti
  function HasCard(Ctrl: TWinControl): boolean;
  var
    I: integer;
  begin
    result := False;

    if Assigned(Ctrl) then
      for I := 0 to Ctrl.ControlCount - 1 do
      begin
        if Ctrl.Controls[I] is TzDbCard then
          Exit(true);

        if Ctrl.Controls[I] is TWinControl then
          if HasCard(TWinControl(Ctrl.Controls[I])) then
            Exit(true);
      end;
  end;

  // Mantis non indicato - 2026-11-02: DIV-PGC-1, il contenitore e' gia' agganciato se il suo OnChange e' il gestore di questo controller
  function GiaAgganciato(PageControl: TcxPageControl): boolean;
  var
    Gestore: TNotifyEvent;
  begin
    Gestore := Base_PageControlChange;
    result := (TMethod(PageControl.OnChange).Data = TMethod(Gestore).Data) and (TMethod(PageControl.OnChange).Code = TMethod(Gestore).Code);
  end;

var
  I: integer;
  OriginalOnChange: TNotifyEvent;
  PageControl: TcxPageControl;
begin
  // siPageControlController.LogVerbose('doInitPageControls');

  for I := 0 to CtrlsOwner.ComponentCount - 1 do
    if CtrlsOwner.Components[I] is TcxPageControl then
    begin
      PageControl := CtrlsOwner.Components[I] as TcxPageControl;

      if not PageControlEvents.ContainsKey(PageControl) and not GiaAgganciato(PageControl) then
      begin
        OriginalOnChange := PageControl.OnChange;
        if Assigned(OriginalOnChange) then
          PageControlEvents.Add(PageControl, OriginalOnChange);

        PageControl.OnChange := Base_PageControlChange;
        if (PageControl.Align in [AlTop, AlBottom]) then
        begin
          if HasCard(PageControl) then
            PageControl.Tag := PageControl.Height
          else
            PageControl.Tag := 0;
          CalcPageControlSize(PageControl);
        end;
      end;
    end;
end;

procedure TPageControlController.InitContainer(Container: TControl);
begin
  doInitPageControls(Container);
end;

procedure TPageControlController.ResetActivePages;
  function FirstVisiblePage(PageControl: TcxPageControl): integer;
  var
    I: integer;
  begin
    result := 0;
    for I := 0 to PageControl.PageCount - 1 do
      if PageControl.Pages[I].Visible then
        Exit(I);
  end;

var
  Comp: TComponent;
  PageControl: TcxPageControl;
begin
  // siPageControlController.LogVerbose('ResetActivePages');

  for Comp in Owner do
    if Comp is TcxPageControl then
    begin
      PageControl := TcxPageControl(Comp);
      if PageControl.PageCount > 0 then
        PageControl.ActivePageIndex := FirstVisiblePage(PageControl);
    end;
end;

procedure TPageControlController.InitForm(Form: TForm);
begin
  doInitPageControls(Form);
end;

procedure TPageControlController.InitFrame(Frame: TFrame);
begin
  doInitPageControls(Frame);
end;

function TPageControlController.CalcMaxHeight: integer;
begin
  if Owner is TCustomForm then
    result := TCustomForm(Owner).Height
  else
    if Owner is TCustomFrame then
      result := TCustomFrame(Owner).Height;
end;

procedure TPageControlController.CalcPageControlSize(PageControl: TcxPageControl);
var
  H: integer;
  TabSheet: TcxTabSheet;
  ZCard: TzDbCard;
  MaxHeight: integer;

  function EnumCtrls(Ctrl: TWinControl): integer;
  var
    I: integer;
  begin
    result := -1;

    if not Assigned(Ctrl) then
      Exit;

    if Ctrl is TzDbCard then
      result := (Ctrl as TzDbCard).CalcDialogHeight;

    for I := 0 to Ctrl.ControlCount - 1 do
    begin
      if Ctrl.Controls[I] is TzDbCard then
      begin
        ZCard := Ctrl.Controls[I] as TzDbCard;
        H := Max(result, ZCard.CalcDialogHeight);
      end;

      if Ctrl.Controls[I] is TWinControl then
        result := Max(result, EnumCtrls(Ctrl.Controls[I] as TWinControl));
    end;
  end;

begin
  // siPageControlController.LogVerbose('CalcPageControlSize');

  if FDisableCalcSize then
    Exit;

  if not Assigned(PageControl) then
    Exit;

  // Host non ancora mostrato: il layout delle card nei tab non e' costruito,
  // ricalcolare ora dereferenzia ViewInfo nil. Si rimanda al primo display reale.
  if not PageControl.HandleAllocated then
    Exit;

  if not(PageControl.Align in [AlTop, AlBottom]) then
    Exit;

  TabSheet := PageControl.ActivePage;

  H := EnumCtrls(TabSheet);

  if H = -1 then // non c'e' nessuna card
  begin
    if PageControl.Tag = 0 then // non esiste nessuna card in tutto il pagecontrol, non nel solo tab attivo
      H := PageControl.Height
    else
      H := PageControl.Tag;
  end
  else
    H := H + 3 + (PageControl.Height - TabSheet.ClientHeight); // altezza del bordo

  // controllo dell'altezza
  MaxHeight := Max(CalcMaxHeight - 50, 0);

  if H > MaxHeight then
    H := MaxHeight;

  if PageControl.Height <> H then
    PageControl.Height := H;
end;

initialization

siPageControlController := Si.AddSession('PageControlController', true);

end.
