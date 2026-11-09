// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------

// Finestra "Nuova richiesta di assistenza", aperta da "Le mie segnalazioni".
// Fino a qui un ticket nasceva solo da un errore (zExceptions): domande e
// richieste di funzioni passavano dalla mail e restavano fuori dal registro.
// La finestra raccoglie oggetto, descrizione e allegati; l'invio lo fa la
// form chiamante con SegnalaSuMantis, cosi' il ticket ha lo stesso progetto,
// lo stesso reporter e lo stesso contesto di quelli aperti dagli errori.
//
// Costruita in codice, senza .dfm: e' una finestra di poche righe, e le
// icone arrivano dalla lista della form chiamante.

unit zMantis.NuovaRichiesta.form;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.ImgList;

type
  TMantisNuovaRichiesta = record
    Oggetto: string;
    Descrizione: string;
    Allegati: TArray<string>;
  end;

// Chiede i dati della richiesta. AImmagini e gli indici sono quelli della
// form chiamante; ALimiteFile (byte, 0 = sconosciuto) e' la dimensione
// massima di un allegato su Mantis. False se l'utente annulla.
function MantisChiediNuovaRichiesta(AImmagini: TCustomImageList; AIconaAllega, AIconaSchermata, AIconaTogli,
  AIconaInvia: Integer; ALimiteFile: Int64; out ARichiesta: TMantisNuovaRichiesta): Boolean;

implementation

uses
  Winapi.Windows,
  System.IOUtils,
  System.UITypes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  cxControls,
  cxContainer,
  cxEdit,
  cxTextEdit,
  cxMemo,
  cxLabel,
  cxListBox,
  cxButtons,
  dxForms,
  zMsg,
  Mantis.Segnalazioni.Html,
  Mantis.Segnalazioni.Allegati;

type
  TFormNuovaRichiesta = class(TdxForm)
  private
    FOggetto: TcxTextEdit;
    FDescrizione: TcxMemo;
    FFile: TcxListBox;
    FPercorsi: TStringList;
    FLimiteFile: Int64;
    FAllega, FSchermata, FTogli, FInvia, FAnnulla: TcxButton;
    FApri: TOpenDialog;
    function Etichetta(AParent: TWinControl; const ATesto: string; ATop: Integer): TcxLabel;
    function Pulsante(AParent: TWinControl; const ATesto: string; AIcona: Integer; AEvento: TNotifyEvent): TcxButton;
    procedure Aggiungi(const APercorsi: array of string);
    procedure AggiornaElenco;
    procedure AggiornaComandi(Sender: TObject);
    procedure AllegaClick(Sender: TObject);
    procedure SchermataClick(Sender: TObject);
    procedure TogliClick(Sender: TObject);
    procedure InviaClick(Sender: TObject);
    procedure DescrizioneKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor CreaFinestra(AImmagini: TCustomImageList; AIconaAllega, AIconaSchermata, AIconaTogli, AIconaInvia: Integer;
      ALimiteFile: Int64);
    destructor Destroy; override;
  end;

function MantisChiediNuovaRichiesta(AImmagini: TCustomImageList; AIconaAllega, AIconaSchermata, AIconaTogli,
  AIconaInvia: Integer; ALimiteFile: Int64; out ARichiesta: TMantisNuovaRichiesta): Boolean;
var
  Finestra: TFormNuovaRichiesta;
begin
  ARichiesta := Default (TMantisNuovaRichiesta);
  Finestra := TFormNuovaRichiesta.CreaFinestra(AImmagini, AIconaAllega, AIconaSchermata, AIconaTogli, AIconaInvia,
    ALimiteFile);
  try
    Result := Finestra.ShowModal = mrOk;
    if Result then
    begin
      ARichiesta.Oggetto := Trim(Finestra.FOggetto.Text);
      ARichiesta.Descrizione := Trim(Finestra.FDescrizione.Text);
      ARichiesta.Allegati := Finestra.FPercorsi.ToStringArray;
    end;
  finally
    Finestra.Free;
  end;
end;

{ TFormNuovaRichiesta }

constructor TFormNuovaRichiesta.CreaFinestra(AImmagini: TCustomImageList; AIconaAllega, AIconaSchermata, AIconaTogli,
  AIconaInvia: Integer; ALimiteFile: Int64);
var
  Comandi, Fondo, Allegati: TPanel;
  Bottone: TcxButton;
  Sinistra: Integer;
begin
  inherited CreateNew(nil);
  FPercorsi := TStringList.Create;
  FLimiteFile := ALimiteFile;

  Caption := 'Nuova richiesta di assistenza';
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu];
  ClientWidth := 640;
  ClientHeight := 520;
  Constraints.MinWidth := 480;
  Constraints.MinHeight := 400;
  Font.Name := 'Segoe UI';
  Font.Height := -12;
  Padding.SetBounds(12, 8, 12, 8);

  // Con Align la VCL dispone i controlli secondo la posizione che hanno al
  // momento dell'allineamento: Top e Left si fissano prima di Align, in
  // ordine, altrimenti l'ultimo creato finisce in cima (o a sinistra).
  Etichetta(Self, 'Oggetto (una riga che riassume la richiesta)', 0);
  FOggetto := TcxTextEdit.Create(Self);
  FOggetto.Parent := Self;
  FOggetto.Top := 30;
  FOggetto.Align := alTop;
  FOggetto.Properties.MaxLength := 100;
  FOggetto.Properties.OnChange := AggiornaComandi;
  Etichetta(Self, 'Descrivi la richiesta: cosa stavi facendo, cosa ti aspettavi, cosa e'' successo', 60);

  Allegati := TPanel.Create(Self);
  Allegati.Parent := Self;
  Allegati.SetBounds(0, 300, 600, 130);
  Allegati.Align := alBottom;
  Allegati.BevelOuter := bvNone;
  Etichetta(Allegati, 'Allegati (anche con Ctrl+V nella descrizione: file copiati o un''immagine)', 0);
  Comandi := TPanel.Create(Self);
  Comandi.Parent := Allegati;
  Comandi.SetBounds(0, 100, 600, 34);
  Comandi.Align := alBottom;
  Comandi.BevelOuter := bvNone;
  FAllega := Pulsante(Comandi, 'Allega file...', AIconaAllega, AllegaClick);
  FSchermata := Pulsante(Comandi, 'Schermata', AIconaSchermata, SchermataClick);
  FTogli := Pulsante(Comandi, 'Togli', AIconaTogli, TogliClick);
  Sinistra := 0;
  for Bottone in TArray<TcxButton>.Create(FAllega, FSchermata, FTogli) do
  begin
    Bottone.SetBounds(Sinistra, 0, 120, 27);
    Bottone.AlignWithMargins := True;
    Bottone.Margins.SetBounds(0, 4, 6, 2);
    Bottone.Align := alLeft;
    Inc(Sinistra, 130);
  end;
  FFile := TcxListBox.Create(Self);
  FFile.Parent := Allegati;
  FFile.Align := alClient;
  FFile.OnClick := AggiornaComandi;

  Fondo := TPanel.Create(Self);
  Fondo.Parent := Self;
  Fondo.SetBounds(0, 480, 600, 42);
  Fondo.Align := alBottom;
  Fondo.BevelOuter := bvNone;
  FInvia := Pulsante(Fondo, 'Invia richiesta', AIconaInvia, InviaClick);
  FInvia.SetBounds(400, 0, 150, 27);
  FInvia.AlignWithMargins := True;
  FInvia.Margins.SetBounds(0, 8, 8, 6);
  FInvia.Align := alRight;
  FAnnulla := Pulsante(Fondo, 'Annulla', -1, nil);
  FAnnulla.SetBounds(560, 0, 100, 27);
  FAnnulla.ModalResult := mrCancel;
  FAnnulla.Cancel := True;
  FAnnulla.AlignWithMargins := True;
  FAnnulla.Margins.SetBounds(0, 8, 0, 6);
  FAnnulla.Align := alRight;

  FDescrizione := TcxMemo.Create(Self);
  FDescrizione.Parent := Self;
  FDescrizione.Align := alClient;
  FDescrizione.Properties.ScrollBars := ssVertical;
  FDescrizione.Properties.OnChange := AggiornaComandi;
  FDescrizione.OnKeyDown := DescrizioneKeyDown;

  for Bottone in TArray<TcxButton>.Create(FAllega, FSchermata, FTogli, FInvia) do
    Bottone.OptionsImage.Images := AImmagini;

  FApri := TOpenDialog.Create(Self);
  FApri.Options := [ofHideReadOnly, ofAllowMultiSelect, ofFileMustExist, ofEnableSizing];
  FApri.Filter := 'Tutti i file (*.*)|*.*';
  FApri.Title := 'File da allegare alla richiesta';

  ActiveControl := FOggetto;
  AggiornaComandi(nil);
end;

destructor TFormNuovaRichiesta.Destroy;
begin
  FPercorsi.Free;
  inherited;
end;

function TFormNuovaRichiesta.Etichetta(AParent: TWinControl; const ATesto: string; ATop: Integer): TcxLabel;
begin
  Result := TcxLabel.Create(Self);
  Result.Parent := AParent;
  Result.Top := ATop;
  Result.Align := alTop;
  Result.Caption := ATesto;
  Result.Transparent := True;
  Result.AlignWithMargins := True;
  Result.Margins.SetBounds(0, 6, 0, 2);
end;

function TFormNuovaRichiesta.Pulsante(AParent: TWinControl; const ATesto: string; AIcona: Integer;
  AEvento: TNotifyEvent): TcxButton;
begin
  Result := TcxButton.Create(Self);
  Result.Parent := AParent;
  Result.Caption := ATesto;
  Result.OptionsImage.ImageIndex := AIcona;
  Result.OnClick := AEvento;
end;

procedure TFormNuovaRichiesta.Aggiungi(const APercorsi: array of string);
var
  Percorso: string;
  Scartati: string;
begin
  Scartati := '';
  for Percorso in APercorsi do
  begin
    if (Percorso = '') or not TFile.Exists(Percorso) or (FPercorsi.IndexOf(Percorso) >= 0) then
      Continue;
    if (FLimiteFile > 0) and (TFile.GetSize(Percorso) > FLimiteFile) then
    begin
      Scartati := Scartati + sLineBreak + ExtractFileName(Percorso);
      Continue;
    end;
    FPercorsi.Add(Percorso);
  end;
  if Scartati <> '' then
    ConfirmOk(Format('Questi file superano il limite di %s del servizio di assistenza e non sono stati aggiunti:%s',
      [MantisDimensioneTesto(FLimiteFile), Scartati]), mtWarning);
  AggiornaElenco;
end;

procedure TFormNuovaRichiesta.AggiornaElenco;
var
  Percorso: string;
begin
  FFile.Items.BeginUpdate;
  try
    FFile.Items.Clear;
    for Percorso in FPercorsi do
      FFile.Items.Add(ExtractFileName(Percorso) + ' (' + MantisDimensioneTesto(TFile.GetSize(Percorso)) + ')');
  finally
    FFile.Items.EndUpdate;
  end;
  AggiornaComandi(nil);
end;

procedure TFormNuovaRichiesta.AggiornaComandi(Sender: TObject);
begin
  FInvia.Enabled := (Trim(FOggetto.Text) <> '') and (Trim(FDescrizione.Text) <> '');
  FTogli.Enabled := FFile.ItemIndex >= 0;
end;

procedure TFormNuovaRichiesta.AllegaClick(Sender: TObject);
begin
  if FApri.Execute then
    Aggiungi(FApri.Files.ToStringArray);
end;

procedure TFormNuovaRichiesta.SchermataClick(Sender: TObject);
begin
  Aggiungi([MantisCatturaSchermata(Handle)]);
end;

procedure TFormNuovaRichiesta.TogliClick(Sender: TObject);
begin
  if (FFile.ItemIndex < 0) or (FFile.ItemIndex >= FPercorsi.Count) then
    Exit;
  FPercorsi.Delete(FFile.ItemIndex);
  AggiornaElenco;
end;

procedure TFormNuovaRichiesta.InviaClick(Sender: TObject);
begin
  if not FInvia.Enabled then
    Exit;
  ModalResult := mrOk;
end;

procedure TFormNuovaRichiesta.DescrizioneKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Ctrl+V con file o un'immagine negli appunti: diventano allegati invece
  // di finire (o non finire) nel testo.
  if (Key = Ord('V')) and (Shift = [ssCtrl]) and MantisAppuntiConAllegati then
  begin
    Key := 0;
    Aggiungi(MantisAllegatiDagliAppunti);
  end;
end;

end.
