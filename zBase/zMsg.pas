unit zMsg;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.Controls,
  Vcl.ExtCtrls,
  dxRibbonForm,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxLabel,
  cxButtons,
  dxCore,
  cxMaskEdit,
  cxTextEdit,
  cxSpinEdit,
  cxDateUtils,
  cxTimeEdit,
  cxCalendar,
  cxDropDownEdit,
  cxImageComboBox,
  cxMemo,
  dxMessageDialog;

type
  TDateKind = (dkDate, dkTime, dkDateTime);
  TInputDialog = class;
  TInitInputDlgProc = procedure(InputDialog: TInputDialog) of object;

  TcxSpinEdit = class(cxSpinEdit.TcxSpinEdit)
  public
    procedure PasteFromClipboard; override;
  end;

  TInputDialog = class(TdxRibbonForm)
  private
    Fproc: TProc<TInputDialog>;
    FMapList: boolean;
    FEditList: boolean;
  public
    lblPrompt: TcxLabel;
    cxCustomEdit: TcxCustomEdit;
    btnOk: TcxButton;
    btnCancel: TcxButton;
  protected
    loaded: boolean;
    displayngCtrls: boolean;
    TimerResize: TTimer;
    procedure TimerResizeTimer(Sender: TObject);
    procedure Resize; override;
    function dpi(value: Integer): Integer;
  private
    procedure DisplayCtrls;
    function Execute: boolean;
    // larghezza necessaria al contenuto dell'editor (voci della combo, testo del prompt)
    function LarghezzaContenutoEditor: Integer;

    function CreateText(const Password: boolean): TcxTextEdit;
    function CreateSpin(ValueType: TcxSpinEditValueType): TcxSpinEdit;
    function CreateDate(IsDateTime: boolean): TcxDateEdit;
    function CreateTime: TcxTimeEdit;
    function CreateMemo: TcxMemo;
    function CreateCombo(Items: TStrings; ImageList: TCustomImageList): TcxImageComboBox;

    procedure cxDateEditPropertiesValidate(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
  protected
    procedure DoShow; override;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;

    function Edit(var value: string; Password: boolean): boolean; overload;
    function Edit(var value: string; Items: TStrings; ImageList: TCustomImageList): boolean; overload;
    function Edit(var value: Integer): boolean; overload;
    function Edit(var value: Int64): boolean; overload;
    function Edit(var value: Double): boolean; overload;
    function Edit(var value: currency): boolean; overload;
    function Edit(var value: TDate): boolean; overload;
    function Edit(var value: TDateTime; const DateMin, DateMax: TDate): boolean; overload;
    function Edit(var value: TTime): boolean; overload;
    function Edit(var value: TDateTime; const DateKind: TDateKind): boolean; overload;
    function Edit(var value: TStrings): boolean; overload;

    function Edit(var value: string; ItemsText: string; ImageList: TCustomImageList): boolean; overload;
    property proc: TProc<TInputDialog> read Fproc write Fproc;
    // mappa le voci nella forma Descrizione=Valore; se false il testo della voce e' anche il valore
    property MapList: boolean read FMapList write FMapList;
    // consente di digitare un valore non presente nell'elenco
    property EditList: boolean read FEditList write FEditList;
  end;

function InputString(const ACaption, APrompt: string; var value: string; proc: TProc<TInputDialog> = nil): boolean;
function InputInteger(const ACaption, APrompt: string; var value: Integer; proc: TProc<TInputDialog> = nil): boolean;
function InputInt64(const ACaption, APrompt: string; var value: Int64; proc: TProc<TInputDialog> = nil): boolean;
function InputDouble(const ACaption, APrompt: string; var value: Double; proc: TProc<TInputDialog> = nil): boolean;
function InputCurrency(const ACaption, APrompt: string; var value: currency; proc: TProc<TInputDialog> = nil): boolean;
function InputPassword(const ACaption, APrompt: string; var value: string; proc: TProc<TInputDialog> = nil): boolean;

function InputDate(const ACaption, APrompt, AContent: string; var value: TDateTime; const DateMin, DateMax: TDateTime; const FooterText: string): boolean; overload;
function InputDate(const ACaption, APrompt: string; var value: TDate; proc: TProc<TInputDialog> = nil): boolean; overload;
function InputDate(const ACaption, APrompt: string; var value: TTime; proc: TProc<TInputDialog> = nil): boolean; overload;
function InputDate(const ACaption, APrompt: string; var value: TDateTime; const DateKind: TDateKind = dkDate; proc: TProc<TInputDialog> = nil): boolean; overload;

function InputCombo(const ACaption, APrompt: string; var value: string; aItems: TStrings; ImageList: TCustomImageList = nil; const MapList: boolean = True; const EditList: boolean = True; proc: TProc<TInputDialog> = nil): boolean; overload;
function InputMemo(const ACaption, APrompt: string; value: TStrings; proc: TProc<TInputDialog> = nil): boolean;

function Confirm(const Msg: string; AButtons: TMsgDlgButtons; const MsgDlgType: TMsgDlgType = mtCustom): TModalResult;
procedure ConfirmOk(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom);
function ConfirmOkCancel(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom): boolean;
function ConfirmYesNo(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom): boolean;
function ConfirmYesNoCancel(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom): TModalResult;

// Carattere di una finestra costruita in codice, senza .dfm: quello della
// finestra attiva (o della principale), convertito ai dpi logici della finestra.
//
// Una finestra appena creata con CreateNew vale per la VCL ancora i dpi con cui
// e' nata (96 per TdxForm, quelli di sistema per TdxRibbonForm), finche'
// TdxForm.DoShow non la scala sul monitor dove compare. Font.Assign copiava
// invece l'altezza in pixel della finestra di origine, gia' scalata: su un
// monitor al 150% il carattere passava a 144 dpi e la visualizzazione lo
// moltiplicava di nuovo per 1,5 (scritte e titoli enormi). Si converte con il
// rapporto fra i dpi logici delle due finestre, e la scalatura avviene una
// volta sola. Senza finestre aperte: 9 punti.
procedure AssegnaCarattere(Finestra: TCustomForm);

// Altezza in pixel del carattere della finestra con PuntiInPiu punti in piu'
// (negativi per rimpicciolire), da assegnare a Font.Height di uno stile.
// Non si passa da Font.Size: TdxForm tiene il suo carattere ai dpi di sistema,
// non a quelli logici della finestra, e Size uscirebbe col rapporto sbagliato.
function AltezzaCarattere(Finestra: TCustomForm; const PuntiInPiu: Integer): Integer;

implementation

uses
  Winapi.Windows,
  Winapi.Messages,
  System.UITypes,
  System.Variants,
  Vcl.Graphics,
  Vcl.Clipbrd,
  dxDPIAwareUtils,
  dxLayoutContainer,
  zz.SplashWait;

type
  TdxMessageDialogFormAccess = class(TdxMessageDialogForm);

constructor TInputDialog.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  loaded := false;
  displayngCtrls := false;
  inherited;
  Fproc := nil;
  cxCustomEdit := nil;
  FMapList := True;
  FEditList := True;

  Position := poOwnerFormCenter;
  DoubleBuffered := True;

  BorderStyle := bsSizeToolWin;
  Caption := ''; // @@
  ClientHeight := dpi(100);
  ClientWidth := dpi(320);

  // il carattere si eredita da chi apre il dialogo, convertito ai dpi della
  // finestra (vedi AssegnaCarattere); le misure si calcolano con dpi()
  AssegnaCarattere(Self);

  lblPrompt := TcxLabel.Create(Self);
  lblPrompt.Parent := Self;
  lblPrompt.Transparent := True;

  btnOk := TcxButton.Create(Self);
  btnOk.Parent := Self;
  btnOk.Caption := 'Ok';
  btnOk.ModalResult := mrOk;
  btnOk.Default := True;

  btnCancel := TcxButton.Create(Self);
  btnCancel.Parent := Self;
  btnCancel.Caption := 'Annulla';
  btnCancel.ModalResult := mrCancel;
  btnCancel.Cancel := True;

  TimerResize := TTimer.Create(Self);
  TimerResize.interval := 50;
  TimerResize.onTimer := TimerResizeTimer;

  loaded := True;
end;

procedure TInputDialog.Resize;
begin
  inherited;

  if loaded then
    if not displayngCtrls then
      if assigned(TimerResize) then
      begin
        TimerResize.Enabled := false;
        TimerResize.Enabled := True;
      end;
end;

procedure TInputDialog.TimerResizeTimer(Sender: TObject);
begin
  TimerResize.Enabled := false;
  DisplayCtrls;
end;

procedure TInputDialog.DoShow;
begin
  inherited;
  // ClientWidth := MulDiv(ClientWidth, CurrentPPI, 96);
  // ClientHeight := MulDiv(ClientHeight, CurrentPPI, 96);
end;

// Misure in pixel a 96 dpi portate ai dpi logici della finestra. Non CurrentPPI:
// quando la finestra di sistema esiste gia' restituisce i dpi del monitor anche
// prima che la VCL abbia scalato la finestra, e la misura veniva scalata due volte
function TInputDialog.dpi(value: Integer): Integer;
begin
  result := MulDiv(value, dxGetFormDPI(Self), 96);
end;

function TInputDialog.LarghezzaContenutoEditor: Integer;
var
  i: Integer;
  Combo: TcxImageComboBox;
  Larghezza: Integer;
begin
  // larghezza di guardia: sotto questa il dialogo diventa illeggibile
  result := dpi(200);

  if not assigned(cxCustomEdit) then
    EXIT;

  if not(cxCustomEdit is TcxImageComboBox) then
  begin
    if cxCustomEdit.Width > result then
      result := cxCustomEdit.Width;
    EXIT;
  end;

  Combo := TcxImageComboBox(cxCustomEdit);

  // le voci si misurano col font effettivo del dialogo: e' l'unico modo per avere
  // una larghezza corretta a qualunque DPI, senza costanti in pixel
  Canvas.Font.Assign(Font);

  for i := 0 to Combo.ActiveProperties.Items.count - 1 do
  begin
    Larghezza := Canvas.TextWidth(Combo.ActiveProperties.Items[i].Description);
    if Larghezza > result then
      result := Larghezza;
  end;

  // spazio per bordo, pulsante di apertura ed eventuale immagine della voce
  inc(result, dpi(40));

  if assigned(Combo.ActiveProperties.Images) then
    inc(result, Combo.ActiveProperties.Images.Width + dpi(4));

  // oltre questa larghezza il dialogo diventa ingestibile: il testo viene troncato
  if result > dpi(600) then
    result := dpi(600);
end;

procedure TInputDialog.DisplayCtrls;
var
  Margine: Integer;
  Spazio: Integer;
  LarghezzaUtile: Integer;
begin

  if not loaded then
    EXIT;

  if not assigned(cxCustomEdit) then
    EXIT;

  displayngCtrls := True;
  try
    Margine := dpi(10);
    Spazio := dpi(7);
    //
    lblPrompt.Left := Margine;
    lblPrompt.Top := Margine;

    // la larghezza utile e' il massimo fra contenuto dell'editor, testo del prompt,
    // pulsanti affiancati e larghezza gia' scelta a mano dall'utente: cosi' il
    // ridimensionamento manuale viene rispettato invece di essere annullato
    LarghezzaUtile := LarghezzaContenutoEditor;

    if lblPrompt.Width > LarghezzaUtile then
      LarghezzaUtile := lblPrompt.Width;

    if btnOk.Width + Margine + btnCancel.Width > LarghezzaUtile then
      LarghezzaUtile := btnOk.Width + Margine + btnCancel.Width;

    if ClientWidth - (Margine * 2) > LarghezzaUtile then
      LarghezzaUtile := ClientWidth - (Margine * 2);
    //
    cxCustomEdit.Left := lblPrompt.Left;
    cxCustomEdit.Top := lblPrompt.Top + lblPrompt.Height + dpi(1);
    cxCustomEdit.Width := LarghezzaUtile;
    //
    btnCancel.Left := (cxCustomEdit.Left + cxCustomEdit.Width) - btnCancel.Width;
    btnCancel.Top := cxCustomEdit.Top + cxCustomEdit.Height + Spazio;
    //
    btnOk.Left := btnCancel.Left - Margine - btnOk.Width;
    btnOk.Top := btnCancel.Top;
    //
    Self.ClientWidth := cxCustomEdit.Left + cxCustomEdit.Width + Margine;
    Self.ClientHeight := btnOk.Top + btnOk.Height + Spazio;

    /// ///////////////////////////////////////////////////////

    if cxCustomEdit is TcxMemo then
      cxCustomEdit.Anchors := [akLeft, akTop, akRight, akBottom]
    else
      cxCustomEdit.Anchors := [akLeft, akTop, akRight];

    btnOk.Anchors := [akRight, akBottom];
    btnCancel.Anchors := [akRight, akBottom];
  finally
    displayngCtrls := false;
  end;
end;

function TInputDialog.CreateText(const Password: boolean): TcxTextEdit;
begin
  result := TcxTextEdit.Create(Self);
  result.Parent := Self;
  result.Width := dpi(300);

  if Password then
  begin
    result.Properties.EchoMode := eemPassword;
    result.Properties.PasswordChar := '*';
  end;
end;

function TInputDialog.CreateSpin(ValueType: TcxSpinEditValueType): TcxSpinEdit;
begin
  result := TcxSpinEdit.Create(Self);
  result.Parent := Self;
  result.Width := dpi(200);
  result.Properties.ValueType := ValueType;
  // result.Properties.UseDisplayFormatWhenEditing := True;
end;

function TInputDialog.CreateDate(IsDateTime: boolean): TcxDateEdit;
begin
  result := TcxDateEdit.Create(Self);
  result.Parent := Self;

  if IsDateTime then
  begin
    result.Properties.Kind := ckDateTime;
    result.Properties.SaveTime := True;
    result.Properties.ShowTime := True;
    result.Width := dpi(200);
  end
  else
  begin
    result.Properties.Kind := ckDate;
    result.Properties.SaveTime := false;
    result.Properties.ShowTime := false;
    result.Width := dpi(160);
  end;
end;

function TInputDialog.CreateTime: TcxTimeEdit;
begin
  result := TcxTimeEdit.Create(Self);
  result.Parent := Self;
  result.Width := dpi(160);
  result.Properties.SpinButtons.Position := sbpHorzRight;
  result.Properties.TimeFormat := tfHourMin;
end;

function TInputDialog.CreateCombo(Items: TStrings; ImageList: TCustomImageList): TcxImageComboBox;
var
  i: Integer;
  Item: TcxImageComboBoxItem;
begin
  result := TcxImageComboBox.Create(Self);
  result.Parent := Self;
  result.Width := dpi(300);
  result.ActiveProperties.Images := ImageList;

  // DropDownAutoWidth vale True per difetto: la tendina si allarga sulla voce piu'
  // lunga e sborda dal dialogo. Si disattiva e la larghezza la detta l'editor,
  // che DisplayCtrls ha gia' dimensionato sul contenuto
  result.Properties.DropDownAutoWidth := false;
  result.Properties.DropDownRows := 12;
  result.Properties.DropDownSizeable := True;

  // EditList consente di digitare un valore che non e' in elenco: serve per i
  // casi in cui il dialogo chiede un nome nuovo (una nuova policy, per esempio)
  if FEditList then
    result.Properties.DropDownListStyle := lsEditList
  else
    result.Properties.DropDownListStyle := lsFixedList;

  if assigned(Items) then
    for i := 0 to Items.count - 1 do
    begin
      Item := result.Properties.Items.Add;

      if FMapList then
      begin
        Item.Description := Items.Names[i];
        if Item.Description = '' then
          Item.Description := Items[i];

        Item.value := Items.ValueFromIndex[i];
        if Item.value = '' then
          Item.value := Items[i];
      end
      else
      begin
        // elenco non mappato: la riga e' insieme descrizione e valore, anche
        // quando contiene un segno di uguale
        Item.Description := Items[i];
        Item.value := Items[i];
      end;
    end;
end;

function TInputDialog.CreateMemo: TcxMemo;
begin
  result := TcxMemo.Create(Self);
  result.Parent := Self;
  result.Width := dpi(300);
  result.Height := dpi(200);
end;

function TInputDialog.Execute: boolean;

  function GetPopupParent(Comp: TComponent): TCustomForm;
  begin
    result := nil;

    while assigned(Comp) do
    begin

      if Comp IS TCustomForm then
      begin
        result := Comp as TCustomForm;
        Break;
      end;

      Comp := Comp.Owner;
    end;
  end;

begin
  // la richiamata riempie l'elenco della combo: va eseguita prima del layout,
  // altrimenti il dialogo si dimensiona su un contenuto che non c'e' ancora
  if assigned(proc) then
    proc(Self);

  DisplayCtrls;

  PopupParent := GetPopupParent(Self);
  ActiveControl := cxCustomEdit;

  result := ShowModal = mrOk;
end;

function TInputDialog.Edit(var value: string; Password: boolean): boolean;
begin
  cxCustomEdit := CreateText(Password);
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: Integer): boolean;
begin
  cxCustomEdit := CreateSpin(vtInt);
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: Int64): boolean;
begin
  cxCustomEdit := CreateSpin(vtInt);
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: Double): boolean;
begin
  cxCustomEdit := CreateSpin(vtFloat);
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: currency): boolean;
begin
  // vedere per currency
  cxCustomEdit := CreateSpin(vtFloat);
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: TDateTime; const DateKind: TDateKind): boolean;
begin

  case DateKind of
    dkDate:
      cxCustomEdit := CreateDate(false);
    dkTime:
      cxCustomEdit := CreateTime;
    dkDateTime:
      cxCustomEdit := CreateDate(True);
  end;

  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: TDate): boolean;
begin
  cxCustomEdit := CreateDate(false);
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: TTime): boolean;
begin
  cxCustomEdit := CreateTime;
  cxCustomEdit.EditValue := value;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

function TInputDialog.Edit(var value: string; Items: TStrings; ImageList: TCustomImageList): boolean;
var
  Combo: TcxImageComboBox;
begin
  Combo := CreateCombo(Items, ImageList);
  cxCustomEdit := Combo;

  Combo.EditValue := value;

  // valore proposto dal chiamante che non corrisponde a nessuna voce: senza questo
  // il campo appare vuoto e il valore di partenza si perde
  if FEditList and (Combo.ItemIndex < 0) and (value <> '') then
    Combo.Text := value;

  result := Execute;

  if result then
    if varIsNull(Combo.EditValue) or (VarToStr(Combo.EditValue) = '') then
      // niente voce selezionata: vale quello che l'utente ha digitato
      value := Combo.text
    else
      value := Combo.EditValue;
end;

function TInputDialog.Edit(var value: string; ItemsText: string; ImageList: TCustomImageList): boolean;
var
  Items: TStringList;
begin
  Items := TStringList.Create;
  try
    Items.text := ItemsText;
    result := Edit(value, Items, ImageList);
  finally
    FreeAndNil(Items);
  end;
end;

function TInputDialog.Edit(var value: TStrings): boolean;
var
  memo: TcxMemo;
begin

  memo := CreateMemo;
  cxCustomEdit := memo;

  memo.Parent := Self;
  memo.Lines := value;

  result := Execute;
  if result then
    value.Assign(memo.Lines);
end;

function TInputDialog.Edit(var value: TDateTime; const DateMin, DateMax: TDate): boolean;
var
  cxDateEdit: TcxDateEdit;
begin
  cxDateEdit := CreateDate(false); // solo la data
  cxCustomEdit := cxDateEdit;
  cxCustomEdit.EditValue := value;

  cxDateEdit.Properties.MinDate := DateMin;
  cxDateEdit.Properties.MaxDate := DateMax;

  if (Date >= DateMin) and (Date <= DateMax) then
    cxDateEdit.Properties.DateButtons := [btnClear, btnToday]
  else
    cxDateEdit.Properties.DateButtons := [btnClear];

  cxDateEdit.Properties.DateOnError := deNull;
  cxDateEdit.Properties.ShowOnlyValidDates := True;
  cxDateEdit.Properties.ValidationOptions := [evoRaiseException];
  cxDateEdit.Properties.OnValidate := cxDateEditPropertiesValidate;

  result := Execute;

  if result then
    value := cxCustomEdit.EditValue;
end;

procedure TInputDialog.cxDateEditPropertiesValidate(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: boolean);
var
  cxDateEdit: TcxDateEdit;
  data, MinDate, MaxDate: TDateTime;
begin
  Error := false;

  cxDateEdit := cxCustomEdit as TcxDateEdit;

  if varIsNull(DisplayValue) then
    EXIT;

  if not TryStrToDate(DisplayValue, data) then
  begin
    Error := True;
    ErrorText := 'Data non valida.';
    EXIT;
  end;

  MinDate := cxDateEdit.Properties.MinDate;
  MaxDate := cxDateEdit.Properties.MaxDate;

  if not((data >= MinDate) and (data <= MaxDate)) then
  begin
    Error := True;
    ErrorText := 'La data deve essere compresa tra il giorno ' + DateTostr(MinDate) + ' e il giorno ' + DateTostr(MaxDate) + '.';
  end;
end;

function CreateInputDialog(const Caption: string; const Prompt: string; proc: TProc<TInputDialog>): TInputDialog;
begin
  result := TInputDialog.CreateNew(Application);
  result.Caption := Caption;
  result.lblPrompt.Caption := Prompt;
  result.proc := proc;
end;

function InputString(const ACaption, APrompt: string; var value: string; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value, false);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputInteger(const ACaption, APrompt: string; var value: Integer; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputInt64(const ACaption, APrompt: string; var value: Int64; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputDouble(const ACaption, APrompt: string; var value: Double; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputCurrency(const ACaption, APrompt: string; var value: currency; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputPassword(const ACaption, APrompt: string; var value: string; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value, True);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputDate(const ACaption, APrompt: string; var value: TDate; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputDate(const ACaption, APrompt: string; var value: TTime; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputDate(const ACaption, APrompt: string; var value: TDateTime; const DateKind: TDateKind = dkDate; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value, DateKind);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputCombo(const ACaption, APrompt: string; var value: string; aItems: TStrings; ImageList: TCustomImageList = nil; const MapList: boolean = True; const EditList: boolean = True; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    // fino alla correzione del 2026-09-11 i due parametri venivano ignorati:
    // la combo era sempre mappata e mai digitabile
    dlg.MapList := MapList;
    dlg.EditList := EditList;

    result := dlg.Edit(value, aItems, ImageList);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputMemo(const ACaption, APrompt: string; value: TStrings; proc: TProc<TInputDialog> = nil): boolean;
var
  dlg: TInputDialog;
begin

  dlg := CreateInputDialog(ACaption, APrompt, proc);
  try
    result := dlg.Edit(value);
  finally
    FreeAndNil(dlg);
  end;
end;

function InputDate(const ACaption, APrompt, AContent: string; var value: TDateTime; const DateMin, DateMax: TDateTime; const FooterText: string): boolean;
var
  dlg: TInputDialog;
begin
  dlg := CreateInputDialog(ACaption, APrompt, nil);
  try
    result := dlg.Edit(value, DateMin, DateMax);
  finally
    FreeAndNil(dlg);
  end;
end;

{ TcxSpinEdit }

procedure TcxSpinEdit.PasteFromClipboard;
begin
  // rimuove i separatori delle migliaia
  Clipboard.asText := StringReplace(Clipboard.asText.Trim, '.', '', [rfReplaceAll]);
  inherited;
end;

/// //////////////////////////////////////////////////////////////////////////////

procedure ConfirmOk(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom);
begin
  Confirm(Msg, [mbOk], MsgDlgType);
end;

function ConfirmOkCancel(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom): boolean;
begin
  result := Confirm(Msg, mbOKCancel, MsgDlgType) = mrOk;
end;

function ConfirmYesNo(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom): boolean;
begin
  result := Confirm(Msg, mbYesNo, MsgDlgType) = MrYes;
end;

function ConfirmYesNoCancel(const Msg: string; const MsgDlgType: TMsgDlgType = mtCustom): TModalResult;
begin
  result := Confirm(Msg, mbYesNoCancel, MsgDlgType);
end;

function Confirm(const Msg: string; AButtons: TMsgDlgButtons; const MsgDlgType: TMsgDlgType = mtCustom): TModalResult;
const
  // il dialogo DevExpress si dimensiona esattamente sul testo che contiene: con
  // un messaggio breve la finestra risulta sensibilmente piu' piccola del
  // MessageDlg standard della VCL. Questi valori, espressi in pixel a 96 DPI e
  // riscalati sul DPI corrente, la riportano a una dimensione confrontabile
  // senza renderla sproporzionata.
  LarghezzaMinimaContenuto = 255;
  AltezzaMinimaContenuto = 75;
  MargineContenuto = 12;
  MargineBottoni = 12;
  MargineSottoBottoni = 8;
var
  dlg: TdxMessageDialogForm;
  oldUseLatestCommonDialogs: boolean;

  // il fattore di scala e' protetto in TdxForm: si legge dalla classe di accesso
  function Scala(const Valore: Integer): Integer;
  begin
    result := TdxMessageDialogFormAccess(dlg).ScaleFactor.Apply(Valore);
  end;

begin
  // result := TModalResult(dxMessageDlg(Msg, MsgDlgType, AButtons, 0));

  dlg := dxCreateMessageDialog(Msg, MsgDlgType, AButtons, TMsgDlgBtn.FirstButton, nil, nil);
  try
    // if ATitle <> '' then
    // dlg.Caption := ATitle;
    dlg.HelpFile := '';
    dlg.HelpContext := 0;
    dlg.SetPosition(-1, -1);
    dlg.AlignButtons; //

    if AButtons = [TMsgDlgBtn.mbOk] then
      dlg.lcButtonHost.AlignHorz := ahCenter
    else
      dlg.lcButtonHost.AlignHorz := ahRight;

    // i margini attorno a testo e pulsanti vanno impostati prima di
    // UpdateMessageConstraints: quel metodo sottrae gli scostamenti del
    // contenitore dalla larghezza massima concessa al testo
    dlg.lcContentHost.Offsets.Left := Scala(MargineContenuto);
    dlg.lcContentHost.Offsets.Right := Scala(MargineContenuto);
    dlg.lcContentHost.Offsets.Top := Scala(MargineContenuto);
    dlg.lcContentHost.Offsets.Bottom := Scala(MargineContenuto);
    dlg.lcButtonHost.Offsets.Left := Scala(MargineBottoni);
    dlg.lcButtonHost.Offsets.Right := Scala(MargineBottoni);
    dlg.lcButtonHost.Offsets.Bottom := Scala(MargineSottoBottoni);

    oldUseLatestCommonDialogs := UseLatestCommonDialogs;
    try
      UseLatestCommonDialogs := false;
      TdxMessageDialogFormAccess(dlg).UpdateMessageConstraints;
    finally
      UseLatestCommonDialogs := oldUseLatestCommonDialogs;
    end;

    // sul gruppo radice Width e Height si comportano da minimo, non da misura
    // fissa: un messaggio lungo continua ad allargare e ad alzare la finestra
    // (e' lo stesso meccanismo con cui DevExpress impone MinimalMessageBoxWidth)
    dlg.lcMainGroup_Root.SizeOptions.Width := Scala(LarghezzaMinimaContenuto);
    dlg.lcMainGroup_Root.SizeOptions.Height := Scala(AltezzaMinimaContenuto);

    // La finestra di attesa resterebbe accanto al dialogo, e la schermata di
    // avvio sopra: si tolgono tutte e due finche' l'utente non risponde
    TSmartWaitForm.SuspendForDialog;
    try
      result := dlg.ShowModal;
    finally
      TSmartWaitForm.ResumeAfterDialog;
    end;
  finally
    dlg.Free;
  end;
end;

procedure AssegnaCarattere(Finestra: TCustomForm);
var
  Origine: TCustomForm;
begin
  Origine := Screen.ActiveCustomForm;
  if Origine = nil then
    Origine := Application.MainForm;
  if Origine <> nil then
    dxAssignFont(Finestra.Font, Origine.Font, dxGetFormDPI(Finestra), dxGetFormDPI(Origine))
  else
    Finestra.Font.Height := -MulDiv(9, dxGetFormDPI(Finestra), 72);
end;

function AltezzaCarattere(Finestra: TCustomForm; const PuntiInPiu: Integer): Integer;
begin
  Result := Finestra.Font.Height - MulDiv(PuntiInPiu, dxGetFormDPI(Finestra), 72);
end;

initialization

// per il supporto agli skin
UseLatestCommonDialogs := false;
dxUseStandardMessageDialogs := True;

end.
