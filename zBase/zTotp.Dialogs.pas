// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-30
// ---------------------------------------------------------------------------
unit zTotp.Dialogs;

// Finestre del secondo fattore con app di autenticazione: codice all'accesso,
// registrazione con il QR, codici di recupero. Le finestre non parlano col
// database: ricevono le funzioni da chiamare (TzSecurity in zSystem), cosi'
// restano riusabili in ogni programma che usa zPack.
//
// Nascono senza DFM, come TInputDialog di zMsg: i controlli si impilano dall'alto
// in una colonna di larghezza fissa scalata sul DPI del monitor.

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  dxRibbonForm,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxLabel,
  cxButtons,
  cxTextEdit,
  cxMemo,
  cxCheckBox,
  dxBarCode;

type
  // Verifica di un codice: True se accettato, altrimenti il messaggio da mostrare
  TTotpVerificaCodice = reference to function(const Codice: string; out MessaggioErrore: string): boolean;

  TTotpEsitoCodice = (
    tecVerificato, // codice accettato dal database
    tecAnnullato, // l'utente ha rinunciato
    tecRiservaMail // l'utente ha chiesto il codice via mail
  );

  TTotpDialogBase = class(TdxRibbonForm)
  protected
    Margine: integer;
    Larghezza: integer;
    Cursore: integer;
    function dpi(const Valore: integer): integer;
    function AltezzaTesto(const Testo: string; const LarghezzaDisponibile: integer): integer;
    function CreaEtichetta(const Testo: string): TcxLabel;
    function CreaEtichettaErrore: TcxLabel;
    function CreaCampoCodice: TcxTextEdit;
    function CreaPulsante(const Testo: string; const Risultato: TModalResult): TcxButton;
    procedure Impila(Controllo: TControl; const Altezza: integer = -1; const Spazio: integer = -1);
    procedure ImpilaPulsanti(const Pulsanti: array of TcxButton);
    procedure Chiudi;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: integer = 0); override;
  end;

  // Codice all'accesso: dell'app (6 cifre) o di recupero, nello stesso campo
  TTotpCodiceDialog = class(TTotpDialogBase)
  private
    Verifica: TTotpVerificaCodice;
    procedure ConfermaClick(Sender: TObject);
  public
    lblIstruzioni: TcxLabel;
    edtCodice: TcxTextEdit;
    lblErrore: TcxLabel;
    btnConferma: TcxButton;
    btnRiservaMail: TcxButton;
    btnAnnulla: TcxButton;
    constructor CreaDialogo(const NomeUtente: string; const VerificaCodice: TTotpVerificaCodice; const RiservaMailDisponibile: boolean);
  end;

  // Registrazione: QR, chiave per l'inserimento a mano, primo codice per l'attivazione
  TTotpRegistrazioneDialog = class(TTotpDialogBase)
  private
    Attiva: TTotpVerificaCodice;
    procedure ConfermaClick(Sender: TObject);
  public
    lblIstruzioni: TcxLabel;
    BarCode: TdxBarCode;
    lblChiave: TcxLabel;
    edtChiave: TcxTextEdit;
    lblCodice: TcxLabel;
    edtCodice: TcxTextEdit;
    lblErrore: TcxLabel;
    btnConferma: TcxButton;
    btnAnnulla: TcxButton;
    constructor CreaDialogo(const IndirizzoOtpauth, ChiaveAGruppi, TestoAnnulla: string; const AttivaCodice: TTotpVerificaCodice);
  end;

  // Codici di recupero, mostrati una volta sola
  TTotpCodiciRecuperoDialog = class(TTotpDialogBase)
  private
    procedure CopiaClick(Sender: TObject);
    procedure ConservatiClick(Sender: TObject);
    procedure DialogoCloseQuery(Sender: TObject; var CanClose: boolean);
  public
    lblIstruzioni: TcxLabel;
    memCodici: TcxMemo;
    chkConservati: TcxCheckBox;
    btnCopia: TcxButton;
    btnChiudi: TcxButton;
    constructor CreaDialogo(const Codici: TArray<string>);
  end;

// Chiede il codice finche' il database non lo accetta o l'utente rinuncia
function TotpChiediCodice(const NomeUtente: string; const VerificaCodice: TTotpVerificaCodice; const RiservaMailDisponibile: boolean): TTotpEsitoCodice;

// Mostra il QR e attende il primo codice. True se l'app e' stata attivata.
function TotpRegistraApp(const IndirizzoOtpauth, ChiaveAGruppi, TestoAnnulla: string; const AttivaCodice: TTotpVerificaCodice): boolean;

procedure TotpMostraCodiciRecupero(const Codici: TArray<string>);

implementation

uses
  Winapi.Windows,
  System.UITypes,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.Clipbrd,
  dxBarCodeUtils,
  dxDPIAwareUtils,
  zMsg;

{ TTotpDialogBase }

constructor TTotpDialogBase.CreateNew(AOwner: TComponent; Dummy: integer);
begin
  inherited;

  // All'accesso la finestra principale puo' non esserci ancora
  Position := poScreenCenter;
  BorderStyle := bsDialog;
  DoubleBuffered := True;
  Caption := 'Verifica in due passaggi';

  // Carattere della finestra che apre il dialogo, ai dpi di questa (zMsg)
  AssegnaCarattere(Self);

  Margine := dpi(12);
  Larghezza := dpi(380);
  Cursore := Margine;
end;

// Dpi logici della finestra, non CurrentPPI: vedi TInputDialog.dpi in zMsg
function TTotpDialogBase.dpi(const Valore: integer): integer;
begin
  result := MulDiv(Valore, dxGetFormDPI(Self), 96);
end;

function TTotpDialogBase.AltezzaTesto(const Testo: string; const LarghezzaDisponibile: integer): integer;
var
  Rettangolo: TRect;
begin
  Canvas.Font.Assign(Font);
  Rettangolo := Rect(0, 0, LarghezzaDisponibile, 0);
  DrawText(Canvas.Handle, PChar(Testo), -1, Rettangolo, DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
  result := Rettangolo.Bottom - Rettangolo.Top + dpi(4);
end;

function TTotpDialogBase.CreaEtichetta(const Testo: string): TcxLabel;
begin
  result := TcxLabel.Create(Self);
  result.Parent := Self;
  result.Transparent := True;
  result.AutoSize := False;
  result.Properties.WordWrap := True;
  result.Properties.ShowAccelChar := False;
  result.Caption := Testo;
end;

function TTotpDialogBase.CreaEtichettaErrore: TcxLabel;
begin
  result := CreaEtichetta('');
  result.Style.TextColor := clRed;
end;

function TTotpDialogBase.CreaCampoCodice: TcxTextEdit;
begin
  result := TcxTextEdit.Create(Self);
  result.Parent := Self;
  result.Properties.MaxLength := 30;
  result.Properties.CharCase := ecUpperCase;
  result.Style.Font.Assign(Font);
  result.Style.Font.Height := AltezzaCarattere(Self, 4);
end;

function TTotpDialogBase.CreaPulsante(const Testo: string; const Risultato: TModalResult): TcxButton;
begin
  result := TcxButton.Create(Self);
  result.Parent := Self;
  result.Caption := Testo;
  result.ModalResult := Risultato;

  Canvas.Font.Assign(Font);
  result.Width := Canvas.TextWidth(Testo) + dpi(30);

  if result.Width < dpi(90) then
    result.Width := dpi(90);
end;

procedure TTotpDialogBase.Impila(Controllo: TControl; const Altezza: integer; const Spazio: integer);
begin
  Controllo.Left := Margine;
  Controllo.Top := Cursore;
  Controllo.Width := Larghezza;

  if Controllo is TcxLabel then
    Controllo.Height := AltezzaTesto(TcxLabel(Controllo).Caption, Larghezza)
  else if Altezza > 0 then
    Controllo.Height := Altezza;

  if Spazio >= 0 then
    Cursore := Controllo.Top + Controllo.Height + Spazio
  else
    Cursore := Controllo.Top + Controllo.Height + dpi(8);
end;

procedure TTotpDialogBase.ImpilaPulsanti(const Pulsanti: array of TcxButton);
var
  Indice: integer;
  Destra: integer;
begin
  Cursore := Cursore + dpi(4);
  Destra := Margine + Larghezza;

  for Indice := High(Pulsanti) downto 0 do
  begin
    if not Pulsanti[Indice].Visible then
      Continue;

    Pulsanti[Indice].Top := Cursore;
    Pulsanti[Indice].Left := Destra - Pulsanti[Indice].Width;
    Destra := Pulsanti[Indice].Left - dpi(8);
  end;

  Cursore := Cursore + Pulsanti[0].Height;
end;

procedure TTotpDialogBase.Chiudi;
begin
  ClientWidth := Larghezza + Margine * 2;
  ClientHeight := Cursore + Margine;
end;

{ TTotpCodiceDialog }

constructor TTotpCodiceDialog.CreaDialogo(const NomeUtente: string; const VerificaCodice: TTotpVerificaCodice; const RiservaMailDisponibile: boolean);
begin
  CreateNew(Application);

  Verifica := VerificaCodice;

  lblIstruzioni := CreaEtichetta(
    'Apri l''app di autenticazione sul telefono e digita il codice di 6 cifre indicato per ' + NomeUtente + '.' + sLineBreak +
    'Se non hai il telefono puoi digitare nello stesso campo uno dei codici di recupero.');
  Impila(lblIstruzioni);

  edtCodice := CreaCampoCodice;
  Impila(edtCodice, -1, dpi(5));

  // Due righe: i messaggi del blocco sono lunghi
  lblErrore := CreaEtichettaErrore;
  Impila(lblErrore, -1, 0);
  lblErrore.Height := AltezzaTesto('A' + sLineBreak + 'A', Larghezza);
  Cursore := lblErrore.Top + lblErrore.Height;

  btnConferma := CreaPulsante('Conferma', mrNone);
  btnConferma.Default := True;
  btnConferma.OnClick := ConfermaClick;

  btnRiservaMail := CreaPulsante('Non ho il telefono', mrRetry);
  btnRiservaMail.Visible := RiservaMailDisponibile;

  btnAnnulla := CreaPulsante('Annulla', mrCancel);
  btnAnnulla.Cancel := True;

  ImpilaPulsanti([btnRiservaMail, btnConferma, btnAnnulla]);

  // Il pulsante della riserva sta a sinistra, staccato dagli altri due
  btnRiservaMail.Left := Margine;

  Chiudi;
  ActiveControl := edtCodice;
end;

procedure TTotpCodiceDialog.ConfermaClick(Sender: TObject);
var
  MessaggioErrore: string;
begin
  if Trim(edtCodice.Text) = '' then
  begin
    lblErrore.Caption := 'Digitare il codice.';
    edtCodice.SetFocus;
    Exit;
  end;

  lblErrore.Caption := '';
  Screen.Cursor := crHourGlass;
  try
    if Verifica(Trim(edtCodice.Text), MessaggioErrore) then
    begin
      ModalResult := mrOk;
      Exit;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if MessaggioErrore = '' then
    MessaggioErrore := 'Codice non valido.';

  lblErrore.Caption := MessaggioErrore;
  edtCodice.SelectAll;
  edtCodice.SetFocus;
end;

{ TTotpRegistrazioneDialog }

constructor TTotpRegistrazioneDialog.CreaDialogo(const IndirizzoOtpauth, ChiaveAGruppi, TestoAnnulla: string; const AttivaCodice: TTotpVerificaCodice);
var
  Simbologia: TdxBarCodeQRCodeSymbology;
begin
  CreateNew(Application);

  Caption := 'Registrazione dell''app di autenticazione';
  Attiva := AttivaCodice;

  lblIstruzioni := CreaEtichetta(
    '1. Installa sul telefono un''app di autenticazione: Google Authenticator, Microsoft Authenticator, Aegis o un''altra a scelta.' + sLineBreak +
    '2. Nell''app scegli di aggiungere un account e inquadra il codice qui sotto.' + sLineBreak +
    '3. Digita il codice di 6 cifre che compare nell''app.');
  Impila(lblIstruzioni);

  BarCode := TdxBarCode.Create(Self);
  BarCode.Parent := Self;
  BarCode.Properties.BarCodeSymbologyClass := TdxBarCodeQRCodeSymbology;
  Simbologia := BarCode.Properties.Symbology as TdxBarCodeQRCodeSymbology;
  Simbologia.CompactionMode := qrmByte;
  Simbologia.ErrorCorrectionLevel := eclM;
  BarCode.Properties.ShowText := False;
  BarCode.Properties.ModuleWidth := 4;
  BarCode.Style.Color := clWhite;
  BarCode.AutoSize := True;
  BarCode.Text := IndirizzoOtpauth;
  BarCode.Top := Cursore;
  // Centrato: AutoSize ha gia' calcolato la dimensione dal testo
  BarCode.Left := Margine + (Larghezza - BarCode.Width) div 2;
  Cursore := BarCode.Top + BarCode.Height + dpi(8);

  lblChiave := CreaEtichetta('Se non riesci a inquadrare il codice, nell''app scegli l''inserimento manuale e digita questa chiave:');
  Impila(lblChiave, -1, dpi(2));

  edtChiave := TcxTextEdit.Create(Self);
  edtChiave.Parent := Self;
  edtChiave.Properties.ReadOnly := True;
  edtChiave.Style.Font.Name := 'Consolas';
  edtChiave.Style.Font.Height := AltezzaCarattere(Self, 1);
  edtChiave.Text := ChiaveAGruppi;
  Impila(edtChiave);

  lblCodice := CreaEtichetta('Codice di 6 cifre mostrato dall''app:');
  Impila(lblCodice, -1, dpi(2));

  edtCodice := CreaCampoCodice;
  edtCodice.Properties.MaxLength := 7;
  Impila(edtCodice, -1, dpi(5));

  lblErrore := CreaEtichettaErrore;
  Impila(lblErrore, -1, 0);
  lblErrore.Height := AltezzaTesto('A' + sLineBreak + 'A', Larghezza);
  Cursore := lblErrore.Top + lblErrore.Height;

  btnConferma := CreaPulsante('Attiva', mrNone);
  btnConferma.Default := True;
  btnConferma.OnClick := ConfermaClick;

  btnAnnulla := CreaPulsante(TestoAnnulla, mrCancel);
  btnAnnulla.Cancel := True;

  ImpilaPulsanti([btnConferma, btnAnnulla]);

  Chiudi;
  ActiveControl := edtCodice;
end;

procedure TTotpRegistrazioneDialog.ConfermaClick(Sender: TObject);
var
  MessaggioErrore: string;
begin
  if Trim(edtCodice.Text) = '' then
  begin
    lblErrore.Caption := 'Digitare il codice mostrato dall''app.';
    edtCodice.SetFocus;
    Exit;
  end;

  lblErrore.Caption := '';
  Screen.Cursor := crHourGlass;
  try
    if Attiva(Trim(edtCodice.Text), MessaggioErrore) then
    begin
      ModalResult := mrOk;
      Exit;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if MessaggioErrore = '' then
    MessaggioErrore := 'Codice non valido.';

  lblErrore.Caption := MessaggioErrore;
  edtCodice.SelectAll;
  edtCodice.SetFocus;
end;

{ TTotpCodiciRecuperoDialog }

constructor TTotpCodiciRecuperoDialog.CreaDialogo(const Codici: TArray<string>);
var
  Codice: string;
begin
  CreateNew(Application);

  Caption := 'Codici di recupero';
  OnCloseQuery := DialogoCloseQuery;

  lblIstruzioni := CreaEtichetta(
    'L''app di autenticazione e'' attiva.' + sLineBreak + sLineBreak +
    'Questi codici servono a entrare se perdi il telefono: ognuno vale una volta sola. ' +
    'Conservali in un posto sicuro, fuori da questo computer (stampati o in un gestore di password). ' +
    'Non verranno piu'' mostrati.');
  Impila(lblIstruzioni);

  memCodici := TcxMemo.Create(Self);
  memCodici.Parent := Self;
  memCodici.Properties.ReadOnly := True;
  memCodici.Properties.ScrollBars := ssNone;
  memCodici.Style.Font.Name := 'Consolas';
  memCodici.Style.Font.Height := AltezzaCarattere(Self, 2);

  for Codice in Codici do
    memCodici.Lines.Add(Codice);

  Canvas.Font.Assign(memCodici.Style.Font);
  Impila(memCodici, (Canvas.TextHeight('A') + dpi(1)) * Length(Codici) + dpi(12));

  chkConservati := TcxCheckBox.Create(Self);
  chkConservati.Parent := Self;
  chkConservati.Caption := 'Ho conservato i codici in un posto sicuro';
  chkConservati.Transparent := True;
  chkConservati.Properties.OnChange := ConservatiClick;
  Impila(chkConservati);

  btnCopia := CreaPulsante('Copia', mrNone);
  btnCopia.OnClick := CopiaClick;

  btnChiudi := CreaPulsante('Chiudi', mrOk);
  btnChiudi.Default := True;
  btnChiudi.Enabled := False;

  ImpilaPulsanti([btnCopia, btnChiudi]);
  btnCopia.Left := Margine;

  Chiudi;
  ActiveControl := btnCopia;
end;

procedure TTotpCodiciRecuperoDialog.CopiaClick(Sender: TObject);
begin
  Clipboard.AsText := memCodici.Lines.Text;
end;

procedure TTotpCodiciRecuperoDialog.ConservatiClick(Sender: TObject);
begin
  btnChiudi.Enabled := chkConservati.Checked;
end;

procedure TTotpCodiciRecuperoDialog.DialogoCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  // Chi chiude senza conservarli resta senza riserva: lo si ferma ogni volta
  CanClose := chkConservati.Checked;

  if not CanClose then
    chkConservati.Style.TextColor := clRed
  else
  try
    // DIV-TOT-4: se il pulsante Copia ha messo i codici negli appunti, alla chiusura
    // li si toglie (solo se ci sono ancora: altrimenti si cancellerebbe altro)
    if Clipboard.AsText = memCodici.Lines.Text then
      Clipboard.Clear;
  except
    // appunti occupati da un altro programma: la chiusura non deve fallire
  end;
end;

{ funzioni }

function TotpChiediCodice(const NomeUtente: string; const VerificaCodice: TTotpVerificaCodice; const RiservaMailDisponibile: boolean): TTotpEsitoCodice;
var
  Dialogo: TTotpCodiceDialog;
begin
  Dialogo := TTotpCodiceDialog.CreaDialogo(NomeUtente, VerificaCodice, RiservaMailDisponibile);
  try
    case Dialogo.ShowModal of
      mrOk:
        result := tecVerificato;
      mrRetry:
        result := tecRiservaMail;
    else
      result := tecAnnullato;
    end;
  finally
    Dialogo.Free;
  end;
end;

function TotpRegistraApp(const IndirizzoOtpauth, ChiaveAGruppi, TestoAnnulla: string; const AttivaCodice: TTotpVerificaCodice): boolean;
var
  Dialogo: TTotpRegistrazioneDialog;
begin
  Dialogo := TTotpRegistrazioneDialog.CreaDialogo(IndirizzoOtpauth, ChiaveAGruppi, TestoAnnulla, AttivaCodice);
  try
    result := Dialogo.ShowModal = mrOk;
  finally
    Dialogo.Free;
  end;
end;

procedure TotpMostraCodiciRecupero(const Codici: TArray<string>);
var
  Dialogo: TTotpCodiciRecuperoDialog;
begin
  Dialogo := TTotpCodiciRecuperoDialog.CreaDialogo(Codici);
  try
    Dialogo.ShowModal;
  finally
    Dialogo.Free;
  end;
end;

end.
