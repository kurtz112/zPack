unit zDialog;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.Menus,
  Vcl.StdCtrls,
  dxRibbonForm,
  dxLayoutCommon,
  dxLayoutControl,
  dxLayoutContainer,
  dxLayoutLookAndFeels,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxClasses,
  cxDropDownEdit,
  OkCancel,
  zBaseLib,
  zFormBuilder,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto, System.ImageList, Vcl.ImgList, cxImageList;

type
  TzDialog = class(TdxRibbonForm)
    OkCancel: TOkCancel;
    ActionList: TActionList;
    dxLayoutControl: TdxLayoutControl;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    Proprieta: TAction;
    PopupMenu: TPopupMenu;
    Propriet1: TMenuItem;
    procedure ProprietaExecute(Sender: TObject);
    procedure ProprietaUpdate(Sender: TObject);
  private const
    Ext_Dlgs = '.Dlgs';
  private
    FEnterAsTab: boolean;
    FzFormBuilder: TzFormBuilder;
  private
    function GetLayoutID: string;
    procedure SetLayoutID(const Value: string);
  private
    function IniSection: string;
    procedure LoadPosition;
    procedure SavePosition;
    procedure SetEnterAsTab(const Value: boolean);
    procedure FocusFirst;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function Execute(const aLayoutID: string; const aCaption: string; proc: TProc): boolean;
  public
    property LayoutID: string read GetLayoutID write SetLayoutID;
    property zFormBuilder: TzFormBuilder read FzFormBuilder;
  public
    property EnterAsTab: boolean read FEnterAsTab write SetEnterAsTab;
  end;

implementation

uses
  zSystem,
  zDX;

{$R *.dfm}

type
  TWinControlAccess = class(TWinControl);

constructor TzDialog.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FEnterAsTab := True;
  FzFormBuilder := TzFormBuilder.Create(Self, dxLayoutControl, '');

  dx.InitLayoutControl(dxLayoutControl);
end;

destructor TzDialog.Destroy;
begin
  FreeAndNil(FzFormBuilder);
  inherited;
end;

function TzDialog.GetLayoutID: string;
begin
  result := FzFormBuilder.LayoutID;
end;

procedure TzDialog.SetLayoutID(const Value: string);
begin
  zFormBuilder.LayoutID := Value;
end;

function TzDialog.IniSection: string;
begin
  // valutare se può bastare il layoutID
  result := LayoutID;
end;

procedure TzDialog.LoadPosition;
begin

  if assigned(Base) then
    LoadFormPosition(Self, Base.ConfigFileName(Ext_Dlgs), IniSection);
end;

procedure TzDialog.SavePosition;
begin
  if assigned(Base) then
    SaveFormPosition(Self, Base.ConfigFileName(Ext_Dlgs), IniSection);
end;

function TzDialog.Execute(const aLayoutID: string; const aCaption: string; proc: TProc): boolean;
var
  i: integer;
  WinControl: TWinControl;
begin
  Caption := aCaption;

  // se stringa vuota si mantiene quanto impostato nel componente
  if not aLayoutID.isEmpty then
    LayoutID := aLayoutID;

  PopupParent := GetPopupParent(Self);

  LoadPosition;

  if assigned(proc) then
    proc;

  { TODO : Localizer.Translate(self); }

  ActiveControl := dxLayoutControl;

  tthread.ForceQueue(nil,
    procedure
    begin
      FocusFirst;
    end, 100);

  result := ShowModal = mrOk;

  SavePosition;
end;

procedure TzDialog.FocusFirst;
var
  WinControl: TWinControl;
begin
  WinControl := TWinControlAccess(dxLayoutControl).FindNextControl(nil, True, True, false);
  ActiveControl := WinControl;
end;

procedure TzDialog.KeyDown(var Key: Word; Shift: TShiftState);
var
  skip: boolean;
begin
  // inherited;

  if Key = vk_Return then
  begin
    skip := false;

    if assigned(ActiveControl) then
    begin
      if ActiveControl is TCustomMemo then
        skip := True;

      if not skip then
        if dx.ActiveControl is TcxCustomDropDownEdit then
          if (dx.ActiveControl as TcxCustomDropDownEdit).DroppedDown then
            skip := True;
    end;

    if EnterAsTab then
      if not skip then
      begin
        Key := 0;
        if SsShift in Shift then
          Perform(Wm_NextDlgCtl, 1, 0)
        else
          Perform(Wm_NextDlgCtl, 0, 0);
      end;
  end;

  inherited KeyDown(Key, Shift);
end;

procedure TzDialog.ProprietaExecute(Sender: TObject);
begin
  zFormBuilder.Customize;
end;

procedure TzDialog.ProprietaUpdate(Sender: TObject);
begin
  if assigned(Base) then
    Proprieta.Visible := Base.IsAdmin;
end;

procedure TzDialog.SetEnterAsTab(const Value: boolean);
begin
  FEnterAsTab := Value;
  OkCancel.OkBtn.default := not EnterAsTab;
end;

end.

  zformcontroller zDX
