unit zFindReplace.Helper;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.Forms,
  dxForms,
  dxMessageDialog,
  cxButtons,
  cxTextEdit,
  cxCheckBox,
  cxLabel,
  cxGroupBox,
  cxLookAndFeels,
  cxContainer,
  cxEdit,
  cxMemo;

type
  TFindReplaceMode = (frmFind, frmReplace);

  TdxFindReplaceForm = class(TdxForm)
  private
    // Controlli UI
    lblFind: TcxLabel;
    lblReplace: TcxLabel;
    edtFind: TcxTextEdit;
    edtReplace: TcxTextEdit;
    chkMatchCase: TcxCheckBox;
    chkWholeWord: TcxCheckBox;
    btnFindNext: TcxButton;
    btnReplace: TcxButton;
    btnReplaceAll: TcxButton;
    btnClose: TcxButton;
    pnlOptions: TPanel;
    pnlButtons: TPanel;
    // Stato
    FMode: TFindReplaceMode;
    FMemo: TcxMemo;
    FLastSearchText: string;
    FLastWasCR: Boolean;
    // Metodi interni
    procedure BuildUI;
    procedure SetMode(AMode: TFindReplaceMode);
    procedure DoFindNext(Sender: TObject);
    procedure DoReplace(Sender: TObject);
    procedure DoReplaceAll(Sender: TObject);
    procedure DoClose(Sender: TObject);
    function GetInnerMemo: TCustomMemo;
    function SearchForward(const ASearchText: string; AMatchCase, AWholeWord: Boolean; AStartFrom: Integer): Integer;
  public
    constructor CreateForMemo(AOwner: TComponent; AMemo: TcxMemo; AMode: TFindReplaceMode);
    property Mode: TFindReplaceMode read FMode write SetMode;
  end;

  // Helper che gestisce le TAction e la form
  TFindReplaceHelper = class(TComponent)
  private
    FMemo: TcxMemo;
    FForm: TdxFindReplaceForm;
    FLastSearchText: string;
    FLastMatchCase: Boolean;
    FLastWholeWord: Boolean;
    procedure EnsureForm(AMode: TFindReplaceMode);
    procedure OnFormDestroy(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AMemo: TcxMemo); reintroduce;
    procedure ExecuteFind;
    procedure ExecuteReplace;
    procedure FindNext;
    property Memo: TcxMemo read FMemo write FMemo;
  end;

implementation

uses
  Vcl.ActnList,
  Winapi.Windows,
  System.Character,
  dxDPIAwareUtils;

{ TdxFindReplaceForm }

constructor TdxFindReplaceForm.CreateForMemo(AOwner: TComponent; AMemo: TcxMemo; AMode: TFindReplaceMode);
begin
  inherited CreateNew(AOwner);
  FMemo := AMemo;

  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  KeyPreview := True;

  BuildUI;
  SetMode(AMode);

  // Precarica testo selezionato
  if GetInnerMemo.SelLength > 0 then
    edtFind.Text := GetInnerMemo.SelText;
end;

function TdxFindReplaceForm.GetInnerMemo: TCustomMemo;
begin
  Result := TCustomMemo(FMemo.InnerControl);
end;

procedure TdxFindReplaceForm.BuildUI;
const
  M = 12; // Margine esterno
  S = 6; // Spaziatura tra controlli
  LBL_W = 70; // Larghezza label
  EDT_W = 230; // Larghezza edit
  BTN_W = 100; // Larghezza pulsanti
  BTN_H = 27; // Altezza pulsanti
var
  LeftCol, RightCol, Y, FormW, FormH: Integer;
begin
  LeftCol := M;
  RightCol := M + LBL_W + S + EDT_W + M;
  FormW := RightCol + BTN_W + M;

  Font.Name := 'Segoe UI';
  // ZC 30.10.2026: 9 punti sui dpi logici della finestra (alla costruzione 96, poi
  // TdxForm.DoShow la scala una volta sola); Size li convertiva con i dpi di sistema.
  Font.Height := -MulDiv(9, dxGetFormDPI(Self), 72);
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := FormW;

  Y := M;

  // --- Riga 1: Cerca ---
  lblFind := TcxLabel.Create(Self);
  lblFind.Parent := Self;
  lblFind.Caption := '&Cerca:';
  lblFind.SetBounds(LeftCol, Y + 3, LBL_W, 0);
  lblFind.Properties.Alignment.Horz := taRightJustify;
  lblFind.AutoSize := True;
  lblFind.Transparent := True;

  edtFind := TcxTextEdit.Create(Self);
  edtFind.Parent := Self;
  edtFind.SetBounds(LeftCol + LBL_W + S, Y, EDT_W, 0);
  lblFind.FocusControl := edtFind;

  // Pulsante Trova a destra
  btnFindNext := TcxButton.Create(Self);
  btnFindNext.Parent := Self;
  btnFindNext.Caption := '&Trova succ.';
  btnFindNext.Default := True;
  btnFindNext.SetBounds(RightCol, Y, BTN_W, BTN_H);
  btnFindNext.OnClick := DoFindNext;

  Y := Y + edtFind.Height + S;

  // --- Riga 2: Sostituisci ---
  lblReplace := TcxLabel.Create(Self);
  lblReplace.Parent := Self;
  lblReplace.Caption := 'S&ostituisci:';
  lblReplace.SetBounds(LeftCol, Y + 3, LBL_W, 0);
  lblReplace.Properties.Alignment.Horz := taRightJustify;
  lblReplace.AutoSize := True;
  lblReplace.Transparent := True;

  edtReplace := TcxTextEdit.Create(Self);
  edtReplace.Parent := Self;
  edtReplace.SetBounds(LeftCol + LBL_W + S, Y, EDT_W, 0);
  lblReplace.FocusControl := edtReplace;

  // Pulsante Sostituisci
  btnReplace := TcxButton.Create(Self);
  btnReplace.Parent := Self;
  btnReplace.Caption := '&Sostituisci';
  btnReplace.SetBounds(RightCol, Y, BTN_W, BTN_H);
  btnReplace.OnClick := DoReplace;

  Y := Y + edtReplace.Height + S;

  // --- Riga 3: Sostituisci tutto ---
  btnReplaceAll := TcxButton.Create(Self);
  btnReplaceAll.Parent := Self;
  btnReplaceAll.Caption := 'Sostituisci &tutto';
  btnReplaceAll.SetBounds(RightCol, Y, BTN_W, BTN_H);
  btnReplaceAll.OnClick := DoReplaceAll;

  // Opzione: Maiuscole/Minuscole
  chkMatchCase := TcxCheckBox.Create(Self);
  chkMatchCase.Parent := Self;
  chkMatchCase.Caption := 'Ma&iuscole/Minuscole';
  chkMatchCase.Transparent := True;
  chkMatchCase.SetBounds(LeftCol + LBL_W + S, Y, EDT_W, 0);
  chkMatchCase.Transparent := True;

  Y := Y + chkMatchCase.Height + S - 2;

  // --- Riga 4: Chiudi + Parola intera ---
  btnClose := TcxButton.Create(Self);
  btnClose.Parent := Self;
  btnClose.Caption := 'Chiudi';
  btnClose.Cancel := True;
  btnClose.SetBounds(RightCol, Y, BTN_W, BTN_H);
  btnClose.OnClick := DoClose;

  chkWholeWord := TcxCheckBox.Create(Self);
  chkWholeWord.Parent := Self;
  chkWholeWord.Caption := 'Pa&rola intera';
  chkWholeWord.Transparent := True;
  chkWholeWord.SetBounds(LeftCol + LBL_W + S, Y, EDT_W, 0);

  Y := Y + chkWholeWord.Height + M;

  // --- Dimensione finale ---
  ClientHeight := Y;
end;

procedure TdxFindReplaceForm.SetMode(AMode: TFindReplaceMode);
var
  Delta: Integer;
begin
  FMode := AMode;

  lblReplace.Visible := (AMode = frmReplace);
  edtReplace.Visible := (AMode = frmReplace);
  btnReplace.Visible := (AMode = frmReplace);
  btnReplaceAll.Visible := (AMode = frmReplace);

  case AMode of
    frmFind:
      begin
        Caption := 'Trova';
        // Sposta checkbox e btnClose su, al posto della riga Sostituisci
        Delta := edtReplace.Top - edtFind.Top;
        chkMatchCase.Top := chkMatchCase.Top - Delta;
        chkWholeWord.Top := chkWholeWord.Top - Delta;
        btnClose.Top := btnClose.Top - Delta;
        // Accorcia la finestra
        ClientHeight := chkWholeWord.Top + chkWholeWord.Height + 12;
      end;
    frmReplace:
      begin
        Caption := 'Sostituisci';
        // Ripristina posizioni originali (rebuild se necessario)
      end;
  end;
end;

function TdxFindReplaceForm.SearchForward(const ASearchText: string; AMatchCase, AWholeWord: Boolean; AStartFrom: Integer): Integer;
var
  FullText, Search: string;
  FoundAt: Integer;

  function IsWordBoundary(APos: Integer; const AText: string): Boolean;
  var
    ChBefore, ChAfter: Char;
  begin
    if not AWholeWord then
      Exit(True);
    if APos > 1 then
      ChBefore := AText[APos - 1]
    else
      ChBefore := ' ';
    if APos + Length(Search) <= Length(AText) then
      ChAfter := AText[APos + Length(Search)]
    else
      ChAfter := ' ';

    Result := (not ChBefore.IsLetterOrDigit) and (not ChAfter.IsLetterOrDigit);
  end;

begin
  Result := 0;
  if ASearchText = '' then
    Exit;

  FullText := GetInnerMemo.Text;
  Search := ASearchText;

  if not AMatchCase then
  begin
    FullText := AnsiUpperCase(FullText);
    Search := AnsiUpperCase(Search);
  end;

  // Cerca dalla posizione corrente in avanti
  FoundAt := PosEx(Search, FullText, AStartFrom);
  while (FoundAt > 0) and not IsWordBoundary(FoundAt, FullText) do
    FoundAt := PosEx(Search, FullText, FoundAt + 1);

  // Wrap around
  if (FoundAt = 0) and (AStartFrom > 1) then
  begin
    FoundAt := PosEx(Search, FullText, 1);
    while (FoundAt > 0) and (FoundAt < AStartFrom) and not IsWordBoundary(FoundAt, FullText) do
      FoundAt := PosEx(Search, FullText, FoundAt + 1);
    if (FoundAt >= AStartFrom) then
      FoundAt := 0;
  end;

  Result := FoundAt;
end;

procedure TdxFindReplaceForm.DoFindNext(Sender: TObject);
var
  Memo: TCustomMemo;
  FoundAt, StartFrom: Integer;
begin
  if edtFind.Text = '' then
    Exit;

  Memo := GetInnerMemo;
  StartFrom := Memo.SelStart + Memo.SelLength + 1;

  FoundAt := SearchForward(edtFind.Text, chkMatchCase.Checked, chkWholeWord.Checked, StartFrom);

  if FoundAt > 0 then
  begin
    Memo.SetFocus;
    Memo.SelStart := FoundAt - 1;
    Memo.SelLength := Length(edtFind.Text);
    FLastSearchText := edtFind.Text;
  end
  else
    dxMessageDlg(Format('Testo "%s" non trovato.', [edtFind.Text]), mtInformation, [mbOK], 0);
end;

procedure TdxFindReplaceForm.DoReplace(Sender: TObject);
var
  Memo: TCustomMemo;
  SelTxt, SearchTxt: string;
begin
  Memo := GetInnerMemo;
  SelTxt := Memo.SelText;
  SearchTxt := edtFind.Text;

  // Se la selezione corrente corrisponde, sostituisci
  if chkMatchCase.Checked then
  begin
    if SelTxt = SearchTxt then
      Memo.SelText := edtReplace.Text;
  end
  else
  begin
    if SameText(SelTxt, SearchTxt) then
      Memo.SelText := edtReplace.Text;
  end;

  // Trova il prossimo
  DoFindNext(Sender);
end;

procedure TdxFindReplaceForm.DoReplaceAll(Sender: TObject);
var
  Memo: TCustomMemo;
  Count, FoundAt: Integer;
begin
  if edtFind.Text = '' then
    Exit;

  Memo := GetInnerMemo;
  Count := 0;
  Memo.SelStart := 0;
  Memo.SelLength := 0;

  FoundAt := SearchForward(edtFind.Text, chkMatchCase.Checked, chkWholeWord.Checked, 1);

  while FoundAt > 0 do
  begin
    Memo.SelStart := FoundAt - 1;
    Memo.SelLength := Length(edtFind.Text);
    Memo.SelText := edtReplace.Text;
    Inc(Count);
    // Continua dopo il testo sostituito
    FoundAt := SearchForward(edtFind.Text, chkMatchCase.Checked, chkWholeWord.Checked, FoundAt + Length(edtReplace.Text));
    // Evita wrap-around nel replace all
    if (FoundAt > 0) and (FoundAt <= Memo.SelStart) then
      Break;
  end;

  if Count > 0 then
    dxMessageDlg(Format('Effettuate %d sostituzioni.', [Count]), mtInformation, [mbOK], 0)
  else
    dxMessageDlg(Format('Testo "%s" non trovato.', [edtFind.Text]), mtInformation, [mbOK], 0);
end;

procedure TdxFindReplaceForm.DoClose(Sender: TObject);
begin
  Close;
end;

{ TFindReplaceHelper }

constructor TFindReplaceHelper.Create(AOwner: TComponent; AMemo: TcxMemo);
begin
  inherited Create(AOwner);
  FMemo := AMemo;
end;

procedure TFindReplaceHelper.EnsureForm(AMode: TFindReplaceMode);
begin
  if (FForm = nil) or (FForm.Mode <> AMode) then
  begin
    FreeAndNil(FForm);
    FForm := TdxFindReplaceForm.CreateForMemo(Self, FMemo, AMode);
    FForm.OnDestroy := OnFormDestroy;
  end;
end;

procedure TFindReplaceHelper.OnFormDestroy(Sender: TObject);
begin
  // Salva l'ultimo testo cercato prima che la form venga distrutta
  if FForm <> nil then
  begin
    FLastSearchText := FForm.edtFind.Text;
    FLastMatchCase := FForm.chkMatchCase.Checked;
    FLastWholeWord := FForm.chkWholeWord.Checked;
  end;
  FForm := nil;
end;

procedure TFindReplaceHelper.ExecuteFind;
begin
  EnsureForm(frmFind);
  FForm.Show;
  FForm.edtFind.SetFocus;
end;

procedure TFindReplaceHelper.ExecuteReplace;
begin
  EnsureForm(frmReplace);
  FForm.Show;
  FForm.edtFind.SetFocus;
end;

procedure TFindReplaceHelper.FindNext;
begin
  if (FForm <> nil) and FForm.Visible then
    FForm.DoFindNext(nil)
  else
    if FLastSearchText <> '' then
    begin
      // Cerca usando l'ultimo testo anche senza form aperta
      EnsureForm(frmFind);
      FForm.edtFind.Text := FLastSearchText;
      FForm.chkMatchCase.Checked := FLastMatchCase;
      FForm.chkWholeWord.Checked := FLastWholeWord;
      FForm.DoFindNext(nil);
    end
    else
      ExecuteFind;
end;

end.
