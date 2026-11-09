unit zDbViewDlg;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  system.SysUtils,
  system.Variants,
  system.Classes,
  system.Actions,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.StdCtrls,
  vcl.ExtCtrls,
  vcl.ActnList,
  dxForms,
  Data.DB,
  zDbView,
  OkCancel,
  zSystem,
  zFbDataSet,
  zToolActions;

type
  TzDbViewForm = class;
  TzOnDbViewDlgEvent = procedure(Dialog: TzDbViewForm) of object;
  TDbViewDlgOption = (ddAutoAppend, ddAutoPost, ddShowSelectBtns, ddClearFilterOnExit, ddRaiseOnError);
  TDbViewDlgOptions = set of TDbViewDlgOption;
  TMultiSelectProc = TProc<TzFbDataSet>;

  TzDbViewDlg = class(TComponent)
  private
    FCaption: string;
    FDataSet: TzFbDataSet;
    FDestDataSet: TzFbDataSet;
    FFindValue: Variant;
    FToolActions: TzToolActions;
    FidLookup: string;
    FMultiSelectEvent: TNotifyEvent;
    FOnBeforeExecute: TzOnDbViewDlgEvent;
    FOnCardAfterCreateControl: TAfterCreateControlEvent;
    FOnCardAfterCreateControls: TNotifyEvent;
    FOnCardAfterCreateDbControl: TAfterCreateDbControlEvent;
    FOnCardBeforeCreateControl: TBeforeCreateControlEvent;
    FOnCardBeforeCreateControls: TNotifyEvent;
    FOnCardBeforeCreateDbControl: TBeforeCreateDbControlEvent;
    FOnCloseDialog: TzOnDbViewDlgEvent;
    FOnInitDialog: TzOnDbViewDlgEvent;
    FOptions: TDbViewDlgOptions;
    FzSystem: TzSystem;
    procedure SetCaption(const Value: string);
    procedure SetDataSet(const Value: TzFbDataSet);
    procedure SetFindValue(const Value: Variant);
    procedure SetToolActions(const Value: TzToolActions);
    procedure SetOnCardAfterCreateControl(const Value: TAfterCreateControlEvent);
    procedure SetOnCardAfterCreateControls(const Value: TNotifyEvent);
    procedure SetOnCardAfterCreateDbControl(const Value: TAfterCreateDbControlEvent);
    procedure SetOnCardBeforeCreateControl(const Value: TBeforeCreateControlEvent);
    procedure SetOnCardBeforeCreateControls(const Value: TNotifyEvent);
    procedure SetOnCardBeforeCreateDbControl(const Value: TBeforeCreateDbControlEvent);
    procedure SetOnCloseDialog(const Value: TzOnDbViewDlgEvent);
    procedure SetOnInitDialog(const Value: TzOnDbViewDlgEvent);
    procedure SetzSystem(const Value: TzSystem);
  protected
    zLookup: TzLookup;
    procedure Internal_MultiSelectEvent(Sender: TObject);
  public
    zDbViewForm: TzDbViewForm;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(const aCaption: String; aDataSet: TzFbDataSet; MultiSelectProc: TProc = nil; BeforeExecuteProc: TProc = nil): boolean; overload;
    function Execute(MultiSelectProc: TProc = nil; BeforeExecuteProc: TProc = nil): boolean; overload;

    property FindValue: Variant read FFindValue write SetFindValue;
  published
    property Caption: string read FCaption write SetCaption;
    property DataSet: TzFbDataSet read FDataSet write SetDataSet;
    property DestDataSet: TzFbDataSet read FDestDataSet write FDestDataSet;
    property ToolActions: TzToolActions read FToolActions write SetToolActions;
    property idLookup: string read FidLookup write FidLookup;
    property Options: TDbViewDlgOptions read FOptions write FOptions default [ddAutoAppend, ddAutoPost, ddRaiseOnError];
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property MultiSelectEvent: TNotifyEvent read FMultiSelectEvent write FMultiSelectEvent;
    property OnBeforeExecute: TzOnDbViewDlgEvent read FOnBeforeExecute write FOnBeforeExecute;
    property OnCloseDialog: TzOnDbViewDlgEvent read FOnCloseDialog write SetOnCloseDialog;
    property OnInitDialog: TzOnDbViewDlgEvent read FOnInitDialog write SetOnInitDialog;

    property OnCardBeforeCreateControls: TNotifyEvent read FOnCardBeforeCreateControls write SetOnCardBeforeCreateControls;
    property OnCardAfterCreateControls: TNotifyEvent read FOnCardAfterCreateControls write SetOnCardAfterCreateControls;
    property OnCardBeforeCreateControl: TBeforeCreateControlEvent read FOnCardBeforeCreateControl write SetOnCardBeforeCreateControl;
    property OnCardAfterCreateControl: TAfterCreateControlEvent read FOnCardAfterCreateControl write SetOnCardAfterCreateControl;
    property OnCardBeforeCreateDbControl: TBeforeCreateDbControlEvent read FOnCardBeforeCreateDbControl write SetOnCardBeforeCreateDbControl;
    property OnCardAfterCreateDbControl: TAfterCreateDbControlEvent read FOnCardAfterCreateDbControl write SetOnCardAfterCreateDbControl;
  end;

  TzDbViewForm = class(TdxForm)
    OkCancel: TOkCancel;
    zDbView: TzDbView;
    Panel: TPanel;
    ActionList: TActionList;
    Tutti: TAction;
    Nessuno: TAction;
    procedure ButtonVisible(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NessunoExecute(Sender: TObject);
    procedure TuttiExecute(Sender: TObject);
  private
    FBeforeExecuteProc: TProc;
    FMultiSelectEvent: TNotifyEvent;
    FMultiSelectProc: TProc;

    FDataSet: TzFbDataSet;
    FFindValue: Variant;
    FOnBeforeExecute: TzOnDbViewDlgEvent;
    FShowSelectBtns: boolean;
    FzSystem: TzSystem;
    procedure SetDataSet(const Value: TzFbDataSet);
    procedure SetFindValue(const Value: Variant);
    procedure SetzSystem(const Value: TzSystem);
  protected
    IniSection: string;
    TuttiBtn: TButton;
    NessunoBtn: TButton;

    KeyboardBufferField: string;
    KeyboardBufferValue: char;
    procedure Init;
    property MultiSelectEvent: TNotifyEvent read FMultiSelectEvent write FMultiSelectEvent;
    property MultiSelectProc: TProc read FMultiSelectProc write FMultiSelectProc;
    property BeforeExecuteProc: TProc read FBeforeExecuteProc write FBeforeExecuteProc;
    property OnBeforeExecute: TzOnDbViewDlgEvent read FOnBeforeExecute write FOnBeforeExecute;
    property zSystem: TzSystem read FzSystem write SetzSystem;
    property DataSet: TzFbDataSet read FDataSet write SetDataSet;
    property ShowSelectBtns: boolean read FShowSelectBtns write FShowSelectBtns;

    property FindValue: Variant read FFindValue write SetFindValue;
  public
    constructor Create(aOwner: TComponent); override;
    function Execute: boolean;
  end;

implementation

uses
  zBaseLib,
  zLocalizer,
  SmartInspect.vcl,
  SmartInspect.vcl.SiAuto;

{$R *.dfm}
{ TzDbViewForm }

procedure TzDbViewForm.SetDataSet(const Value: TzFbDataSet);
begin
  FDataSet := Value;
end;

procedure TzDbViewForm.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
end;

function TzDbViewForm.Execute: boolean;
const
  Ext_Dlgs = '.Dlgs';
var
  i: Integer;
begin
  Init;

  if Assigned(FOnBeforeExecute) then
    OnBeforeExecute(Self);

  if zDbView.ToolActions.Count > 0 then
    zDbView.InitToolActions;

  if Caption = '' then
    Caption := zDbView.GetDbViewProps.Title;

  LoadFormPosition(Self, zSystem.ConfigFileName(Ext_Dlgs), IniSection);

  //
  if Assigned(BeforeExecuteProc) then
    BeforeExecuteProc;

  { TODO : Analizzare }
  Localizer.Translate(Self, zDbView.ViewID);

  // altrimenti tenta di riassegnare left e top
  DefaultMonitor := dmDesktop;

  Result := ShowModal = mrOk;

  SaveFormPosition(Self, zSystem.ConfigFileName(Ext_Dlgs), IniSection);

  if Result then
    if Assigned(FDataSet) then
      if not FDataSet.IsEmpty then
        if Assigned(FMultiSelectEvent) or Assigned(FMultiSelectProc) then
        begin
          zDbView.GetSelectedRows(
            procedure
            begin
              if Assigned(FMultiSelectProc) then
                MultiSelectProc
              else
                if Assigned(FMultiSelectEvent) then
                  MultiSelectEvent(Self);
            end);
          // // uno solo selezionato, non scata il multiselect
          // if zDbView.cxGridDBTableView.Controller.SelectedRowCount = 0 then
          // zDbView.cxGridDBTableView.Controller.FocusedRecord.Selected := True;
          //
          // // per ogni record della griglia lanciare l'evento
          // for i := 0 to zDbView.cxGridDBTableView.Controller.SelectedRowCount - 1 do
          // begin
          // zDbView.DataController.GotoBookmark(zDbView.cxGridDBTableView.DataController.GetSelectedBookmark(i));
          //
          // if Assigned(FMultiSelectProc) then
          // MultiSelectProc
          // else
          // if Assigned(FMultiSelectEvent) then
          // MultiSelectEvent(Self);
          // end;
        end;
end;

constructor TzDbViewForm.Create(aOwner: TComponent);
begin
  inherited;
  IniSection := '';
  FMultiSelectEvent := nil;
  FMultiSelectProc := nil;
  FOnBeforeExecute := nil;
  FDataSet := nil;
  FzSystem := nil;
  //
  TuttiBtn := TButton.Create(Self);
  TuttiBtn.Name := 'TuttiBtn';
  TuttiBtn.Parent := OkCancel;
  TuttiBtn.Top := TuttiBtn.Top;
  TuttiBtn.Left := 7;
  TuttiBtn.Action := Tutti;
  //
  NessunoBtn := TButton.Create(Self);
  NessunoBtn.Name := 'NessunoBtn';
  NessunoBtn.Parent := OkCancel;
  NessunoBtn.Top := NessunoBtn.Top;
  NessunoBtn.Left := TuttiBtn.Left + TuttiBtn.Width + 5;
  NessunoBtn.Action := Nessuno;
  //
  ShowSelectBtns := False;
end;

procedure TzDbViewForm.Init;
begin
  try
    if not DataSet.SelectSql.Text.IsEmpty then
      DataSet.Active := True; // potrebbe arrivare 'spento', serve per dopo..
  except
    on e: exception do
      Application.HandleException(e);
  end;

  zDbView.zSystem := zSystem;
  zDbView.zDataSet := DataSet;

  zDbView.cxGridDBTableView.ApplyBestFit(nil);

  OnResize := Nil;
  try
    ClientHeight := zDbView.GetDbViewProps.DlgHeight;
    ClientWidth := zDbView.GetDbViewProps.DlgWidth;
  finally
    OnResize := FormResize;
  end;
end;

constructor TzDbViewDlg.Create(aOwner: TComponent);
begin
  inherited;
  FToolActions := TzToolActions.Create(Self);
  zLookup := nil;
  FCaption := '';
  FOptions := [ddAutoAppend, ddAutoPost, ddRaiseOnError];
  FMultiSelectEvent := nil;
  FidLookup := '';
  FDataSet := nil;
  FDestDataSet := nil;
  FzSystem := nil;
  FOnInitDialog := nil;
  FOnCloseDialog := nil;
  FOnBeforeExecute := nil;
  FOnCardBeforeCreateControls := nil;
  FOnCardAfterCreateControls := nil;
  FOnCardBeforeCreateControl := nil;
  FOnCardBeforeCreateDbControl := nil;
  FOnCardAfterCreateControl := nil;
  FOnCardAfterCreateDbControl := nil;
  FFindValue := null;
end;

destructor TzDbViewDlg.Destroy;
begin
  FreeAndNil(FToolActions);
  inherited;
end;

function TzDbViewDlg.Execute(const aCaption: String; aDataSet: TzFbDataSet; MultiSelectProc: TProc = nil; BeforeExecuteProc: TProc = nil): boolean;
begin
  Caption := aCaption;
  DataSet := aDataSet;
  Result := Execute(MultiSelectProc);
end;

function TzDbViewDlg.Execute(MultiSelectProc: TProc = nil; BeforeExecuteProc: TProc = nil): boolean;
var
  idx: Integer;
begin
  Result := False;

  if not Assigned(DataSet) then
    raise exception.Create('Dataset non assegnato: ' + Self.Name);

  // zz 24.01.2019
  // Application pone problemi di duplicazione nome e altro
  zDbViewForm := TzDbViewForm.Create(nil);
  try
    zDbViewForm.Caption := Caption;
    zDbViewForm.zSystem := zSystem;
    zDbViewForm.DataSet := DataSet;
    zDbViewForm.MultiSelectProc := MultiSelectProc;
    // R-214 DIV-DVW-3 - 2026-11-01: senza idLookup la sezione e' quella del componente (proprietario e nome),
    // cosi' ogni dialogo ricorda posizione e dimensione per conto suo
    if idLookup.IsEmpty then
    begin
      if (Owner <> nil) and (Name <> '') then
        zDbViewForm.IniSection := Owner.ClassName + '.' + Name
    end
    else
      zDbViewForm.IniSection := idLookup; // zz 19.06.2019: es. in ManutenzioniScheda

    if Assigned(FMultiSelectEvent) or (Assigned(DestDataSet) and Assigned(zLookup)) then
      zDbViewForm.MultiSelectEvent := Internal_MultiSelectEvent;

    // zDbViewForm.KeyboardBufferField := KeyboardBufferField;
    // zDbViewForm.KeyboardBufferValue := KeyboardBufferValue;

    zDbViewForm.zDbView.OnCardBeforeCreateControls := OnCardBeforeCreateControls;
    zDbViewForm.zDbView.OnCardAfterCreateControls := OnCardAfterCreateControls;
    zDbViewForm.zDbView.OnCardBeforeCreateControl := OnCardBeforeCreateControl;
    zDbViewForm.zDbView.OnCardAfterCreateControl := OnCardAfterCreateControl;

    zDbViewForm.ShowSelectBtns := ddShowSelectBtns in Options;
    zDbViewForm.BeforeExecuteProc := BeforeExecuteProc;
    zDbViewForm.OnBeforeExecute := OnBeforeExecute;
    zDbViewForm.zDbView.ToolActions.Assign(Self.ToolActions);
    zDbViewForm.FindValue := FindValue;

    if not idLookup.IsEmpty then
    begin
      idx := zSystem.zLookups.IndexOf(idLookup);

      if idx <> -1 then
      begin
        zLookup := zSystem.zLookups[idx];
        zDbViewForm.zDbView.ViewID := zLookup.DbView;
      end
      else
      begin
        zLookup := zSystem.zLookups.Add;
        zLookup.Name := idLookup;
        zSystem.SaveZip(csLookups, 'Execute DbViewDlg');
      end;
    end;

    if Assigned(FOnInitDialog) then
      OnInitDialog(zDbViewForm);

    zDbViewForm.PopupParent := GetPopupParent(Self);
    //
    Result := zDbViewForm.Execute;
    //

    if Assigned(FOnCloseDialog) then
      OnCloseDialog(zDbViewForm);

    if ddClearFilterOnExit in Options then
      zDbViewForm.zDbView.ClearFilter(DataSet.Active);

    if Assigned(zLookup) then
      zLookup.UpdateDisplayColumnsFromView(True);
  finally
    FreeAndNil(zDbViewForm);
  end;
end;

procedure TzDbViewDlg.Internal_MultiSelectEvent(Sender: TObject);
begin
  if DataSet.IsEmpty then
    Exit;

  if Assigned(FMultiSelectEvent) then
    MultiSelectEvent(Self)
  else
  begin
    if Assigned(DestDataSet) then
      if Assigned(zLookup) then
      begin

        if ddAutoAppend in Options then
          DestDataSet.Append;

        DestDataSet.CopyMappingFields(DataSet, zLookup.Mappings, False);

        if ddAutoPost in Options then
        begin
          try
            DestDataSet.Post;
          except
            DestDataSet.Cancel;
            if ddRaiseOnError in Options then
              raise;
          end;
        end;
      end;
  end;
end;

procedure TzDbViewDlg.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

{ TzDbViewDlg }

procedure TzDbViewDlg.SetDataSet(const Value: TzFbDataSet);
begin
  FDataSet := Value;
end;

procedure TzDbViewDlg.SetToolActions(const Value: TzToolActions);
begin
  FToolActions.Assign(Value);
  // InitToolActions;
end;

procedure TzDbViewDlg.SetOnCardAfterCreateControl(const Value: TAfterCreateControlEvent);
begin
  FOnCardAfterCreateControl := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.zDbView.OnCardAfterCreateControl := OnCardAfterCreateControl;
end;

procedure TzDbViewDlg.SetOnCardAfterCreateControls(const Value: TNotifyEvent);
begin
  FOnCardAfterCreateControls := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.zDbView.OnCardAfterCreateControls := OnCardAfterCreateControls;
end;

procedure TzDbViewDlg.SetOnCardAfterCreateDbControl(const Value: TAfterCreateDbControlEvent);
begin
  FOnCardAfterCreateDbControl := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.zDbView.OnCardAfterCreateDbControl := OnCardAfterCreateDbControl;
end;

procedure TzDbViewDlg.SetOnCardBeforeCreateControl(const Value: TBeforeCreateControlEvent);
begin
  FOnCardBeforeCreateControl := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.zDbView.OnCardBeforeCreateControl := OnCardBeforeCreateControl;
end;

procedure TzDbViewDlg.SetOnCardBeforeCreateControls(const Value: TNotifyEvent);
begin
  FOnCardBeforeCreateControls := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.zDbView.OnCardBeforeCreateControls := OnCardBeforeCreateControls;
end;

procedure TzDbViewDlg.SetOnCardBeforeCreateDbControl(const Value: TBeforeCreateDbControlEvent);
begin
  FOnCardBeforeCreateDbControl := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.zDbView.OnCardBeforeCreateDbControl := OnCardBeforeCreateDbControl;
end;

procedure TzDbViewDlg.SetOnCloseDialog(const Value: TzOnDbViewDlgEvent);
begin
  FOnCloseDialog := Value;
end;

procedure TzDbViewDlg.SetOnInitDialog(const Value: TzOnDbViewDlgEvent);
begin
  FOnInitDialog := Value;
end;

procedure TzDbViewDlg.SetzSystem(const Value: TzSystem);
begin
  FzSystem := Value;
end;

procedure TzDbViewForm.ButtonVisible(Sender: TObject);
begin
  ActionVisible(Tutti, ShowSelectBtns);
  ActionVisible(Nessuno, ShowSelectBtns);
end;

procedure TzDbViewForm.FormResize(Sender: TObject);
begin
  zDbView.GetDbViewProps.DlgHeight := ClientHeight;
  zDbView.GetDbViewProps.DlgWidth := ClientWidth;
end;

procedure TzDbViewForm.NessunoExecute(Sender: TObject);
begin
  zDbView.actNessuno.Execute;
end;

procedure TzDbViewForm.TuttiExecute(Sender: TObject);
begin
  zDbView.actSelezionaTutto.Execute;
end;

procedure TzDbViewDlg.SetFindValue(const Value: Variant);
begin
  FFindValue := Value;

  if Assigned(zDbViewForm) then
    zDbViewForm.FindValue := Value;
end;

procedure TzDbViewForm.SetFindValue(const Value: Variant);
begin
  // if Visible then
  FFindValue := Value;
end;

procedure TzDbViewForm.FormShow(Sender: TObject);
begin
  ActiveControl := zDbView; // 19.02.2023:
  zDbView.FindValue := FindValue;
end;

end.
