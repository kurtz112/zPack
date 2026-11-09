// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Log.OpzioniForm
//
// Mantis #183 - 2026-10-08: finestra mostrata all'avvio della registrazione
// per l'assistenza (zDiagnostica.Log) al posto della semplice conferma.
//
// Dal 2026-10-29 e' una procedura guidata (TdxWizardControl) pensata per
// l'utente inesperto, con la spiegazione scritta nella pagina e non nei
// suggerimenti delle caselle. Le pagine erano cinque, ridotte a tre lo stesso
// giorno perche' l'utente arrivasse all'avvio con meno clic:
//  1. a cosa serve e come si usa, la nota dell'utente, scritta adesso e non
//     piu' chiesta alla chiusura, e l'invio del ticket alla fine;
//  2. cosa registrare: tempi dei fetch, tempi della griglia, monitor FireDAC
//     e il filmato della finestra (zDiagnostica.Video), quest'ultimo solo
//     nelle applicazioni che lo prevedono: altrove il gruppo si nasconde,
//     cosi' WT non lo vede. Il codice di sblocco (zDiagnostica.Video.Sblocco)
//     si controlla su Avanti;
//  3. il riepilogo delle scelte e come chiudere la registrazione; dal
//     2026-10-29 anche il pulsante Segnalibro e, dove l'applicazione lo
//     chiede (TzChiusuraNellaFinestra.ProssimoAvvio), la casella che prenota
//     la registrazione al prossimo avvio al posto della voce di menu.
//
// Unit autonoma: VCL, DevExpress e zDiagnostica.Log.Perf per il record delle
// opzioni. Nessuna dipendenza dalle applicazioni: la usa zDiagnostica.Log
// come comportamento predefinito di OnChiediOpzioni, e va bene a WT e Gesty.
//
// ***************************************************************************

unit zDiagnostica.Log.OpzioniForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxClasses,
  cxLabel,
  cxCheckBox,
  cxTextEdit,
  cxMemo,
  dxCustomWizardControl,
  dxWizardControl,
  dxLayoutContainer,
  dxLayoutControl,
  dxLayoutcxEditAdapters,
  zDiagnostica.Log.Perf,
  zDiagnostica.Video.Sblocco;

type
  // Come si presenta il filmato nella finestra.
  TzVideoNellaFinestra = record
    // False = l'applicazione non lo prevede: la pagina del filmato si salta.
    Previsto: boolean;
    // False = previsto ma non utilizzabile (Media Foundation assente): la
    // casella e' disabilitata e Motivo compare sotto.
    Disponibile: boolean;
    Motivo: string;
    // Stima della dimensione e del tempo di invio, gia' in parole.
    Stima: string;
    // Codice da chiedere; nil = nessun codice (applicazione sotto il debugger).
    Sblocco: TzSbloccoVideo;
    class function Assente: TzVideoNellaFinestra; static;
  end;

  // Come si chiude la registrazione, per la pagina del riepilogo.
  TzChiusuraNellaFinestra = record
    // Combinazione di tasti agganciata dall'applicazione (TestoScorciatoia).
    Scorciatoia: string;
    // True = l'applicazione ha il pulsante rosso REC accanto al titolo.
    PulsanteRec: boolean;
    // Limiti oltre i quali la registrazione e il filmato si fermano da soli;
    // 0 = non si scrive.
    DurataMassimaMinuti: Integer;
    DurataMassimaVideoMinuti: Integer;
    // 2026-10-29: combinazione di tasti del segnalibro, citata nella pagina
    // finale accanto al pulsante Segnalibro (con PulsanteRec); vuota = non si cita.
    Segnalibro: string;
    // 2026-10-29: True = la pagina finale offre la casella che prenota la
    // registrazione al prossimo avvio invece di avviarla subito.
    ProssimoAvvio: boolean;
    class function Assente: TzChiusuraNellaFinestra; static;
  end;

  TFormOpzioniRegistrazione = class(TForm)
    Wizard: TdxWizardControl;
    pageScopo: TdxWizardControlPage;
    pageMisure: TdxWizardControlPage;
    pageAvvio: TdxWizardControlPage;
    lcScopo: TdxLayoutControl;
    lcScopoGroup_Root: TdxLayoutGroup;
    lblScopo: TcxLabel;
    lblComeSiUsaTitolo: TcxLabel;
    lblComeSiUsa: TcxLabel;
    lblAvviso: TcxLabel;
    lcScopoItemScopo: TdxLayoutItem;
    lcScopoItemComeSiUsaTitolo: TdxLayoutItem;
    lcScopoItemComeSiUsa: TdxLayoutItem;
    lcScopoItemAvviso: TdxLayoutItem;
    lblNota: TcxLabel;
    memoNota: TcxMemo;
    cbInviaAllaFine: TcxCheckBox;
    lcScopoItemSpiegazioneNota: TdxLayoutItem;
    lcScopoItemNota: TdxLayoutItem;
    lcScopoItemInviaAllaFine: TdxLayoutItem;
    lcMisure: TdxLayoutControl;
    lcMisureGroup_Root: TdxLayoutGroup;
    cbTempiFetch: TcxCheckBox;
    lblTempiFetch: TcxLabel;
    cbTempiGriglia: TcxCheckBox;
    lblTempiGriglia: TcxLabel;
    cbMonitorFireDAC: TcxCheckBox;
    lblMonitorFireDAC: TcxLabel;
    lcMisureItemTempiFetch: TdxLayoutItem;
    lcMisureItemSpiegazioneFetch: TdxLayoutItem;
    lcMisureItemTempiGriglia: TdxLayoutItem;
    lcMisureItemSpiegazioneGriglia: TdxLayoutItem;
    lcMisureItemMonitorFireDAC: TdxLayoutItem;
    lcMisureItemSpiegazioneMonitor: TdxLayoutItem;
    lcMisureGroupFilmato: TdxLayoutGroup;
    cbVideo: TcxCheckBox;
    lblVideoNonDisponibile: TcxLabel;
    edCodice: TcxTextEdit;
    lblStimaVideo: TcxLabel;
    lcFilmatoItemVideo: TdxLayoutItem;
    lcFilmatoItemNonDisponibile: TdxLayoutItem;
    lcFilmatoItemCodice: TdxLayoutItem;
    lcFilmatoItemStimaVideo: TdxLayoutItem;
    lcAvvio: TdxLayoutControl;
    lcAvvioGroup_Root: TdxLayoutGroup;
    lblRiepilogo: TcxLabel;
    lblChiusura: TcxLabel;
    lblLimite: TcxLabel;
    lblAvvertenze: TcxLabel;
    lblSegnalibro: TcxLabel;
    cbProssimoAvvio: TcxCheckBox;
    lcAvvioItemRiepilogo: TdxLayoutItem;
    lcAvvioItemChiusura: TdxLayoutItem;
    lcAvvioItemLimite: TdxLayoutItem;
    lcAvvioItemAvvertenze: TdxLayoutItem;
    lcAvvioItemSegnalibro: TdxLayoutItem;
    lcAvvioItemProssimoAvvio: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbVideoPropertiesChange(Sender: TObject);
    procedure cbProssimoAvvioPropertiesChange(Sender: TObject);
    procedure WizardButtonClick(Sender: TObject; AKind: TdxWizardControlButtonKind; var AHandled: Boolean);
    procedure WizardPageChanging(Sender: TObject; ANewPage: TdxWizardControlCustomPage; var AAllow: Boolean);
    procedure WizardPageChanged(Sender: TObject);
  private
    FVideo: TzVideoNellaFinestra;
    FChiusura: TzChiusuraNellaFinestra;
    FOpzioniIniziali: TzOpzioniRegistrazione;
    procedure Carica(const AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean; const AAvviso: string);
    function Leggi: TzOpzioniRegistrazione;
    procedure AggiornaVideo;
    procedure AggiornaRiepilogo;
    function CodiceDaChiedere: boolean;
    function CodiceAccettato: boolean;
    function ProssimoAvvioScelto: boolean;
  public
    // Mostra la procedura con le opzioni correnti; True = l'utente ha premuto
    // "Avvia la registrazione" e AOpzioni contiene le sue scelte, nota
    // compresa. AMonitorDisponibile a False spegne e disabilita la casella
    // del monitor FireDAC: l'applicazione non ha agganciato OnMonitorFireDAC
    // e non saprebbe accenderlo. AProssimoAvvio = True se l'utente ha spuntato
    // la prenotazione al prossimo avvio: in quel caso AOpzioni ha filmato e
    // monitor FireDAC spenti, e la registrazione non va avviata adesso.
    function Chiedi(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean; const AAvviso: string;
      const AVideo: TzVideoNellaFinestra; const AChiusura: TzChiusuraNellaFinestra;
      out AProssimoAvvio: boolean): boolean;
  end;

// Punto di ingresso usato da zDiagnostica.Log: crea la finestra, la mostra e
// la libera. AAvviso e' un testo in piu' per la prima pagina; vuoto = solo il
// testo della pagina, che dal 2026-10-29 contiene gia' l'avviso di sempre.
function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string): boolean; overload;
function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra): boolean; overload;
function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra; const AChiusura: TzChiusuraNellaFinestra): boolean; overload;
// 2026-10-29: come sopra, e dice se l'utente ha prenotato la registrazione al
// prossimo avvio (casella offerta solo con AChiusura.ProssimoAvvio).
function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra; const AChiusura: TzChiusuraNellaFinestra;
  out AProssimoAvvio: boolean): boolean; overload;

implementation

uses
  System.StrUtils,
  Vcl.Dialogs,
  zDX,
  zMsg;

{$R *.dfm}

class function TzVideoNellaFinestra.Assente: TzVideoNellaFinestra;
begin
  result.Previsto := False;
  result.Disponibile := False;
  result.Motivo := '';
  result.Stima := '';
  result.Sblocco := nil;
end;

class function TzChiusuraNellaFinestra.Assente: TzChiusuraNellaFinestra;
begin
  result.Scorciatoia := '';
  result.PulsanteRec := False;
  result.DurataMassimaMinuti := 0;
  result.DurataMassimaVideoMinuti := 0;
  result.Segnalibro := '';
  result.ProssimoAvvio := False;
end;

function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string): boolean;
begin
  result := ChiediOpzioniRegistrazione(AOpzioni, AMonitorDisponibile, AAvviso, TzVideoNellaFinestra.Assente,
    TzChiusuraNellaFinestra.Assente);
end;

function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra): boolean;
begin
  result := ChiediOpzioniRegistrazione(AOpzioni, AMonitorDisponibile, AAvviso, AVideo, TzChiusuraNellaFinestra.Assente);
end;

function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra; const AChiusura: TzChiusuraNellaFinestra): boolean;
var
  ProssimoAvvio: boolean;
begin
  result := ChiediOpzioniRegistrazione(AOpzioni, AMonitorDisponibile, AAvviso, AVideo, AChiusura, ProssimoAvvio);
end;

function ChiediOpzioniRegistrazione(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra; const AChiusura: TzChiusuraNellaFinestra;
  out AProssimoAvvio: boolean): boolean;
var
  Finestra: TFormOpzioniRegistrazione;
begin
  Finestra := TFormOpzioniRegistrazione.Create(Application);
  try
    result := Finestra.Chiedi(AOpzioni, AMonitorDisponibile, AAvviso, AVideo, AChiusura, AProssimoAvvio);
  finally
    FreeAndNil(Finestra);
  end;
end;

// TFormOpzioniRegistrazione

procedure TFormOpzioniRegistrazione.FormCreate(Sender: TObject);
begin
  dx.InitLayoutControl(lcScopo);
  dx.InitLayoutControl(lcMisure);
  dx.InitLayoutControl(lcAvvio);
end;

// Esc chiude come Annulla, come faceva il pulsante della finestra di prima.
procedure TFormOpzioniRegistrazione.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TFormOpzioniRegistrazione.Carica(const AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string);
begin
  FOpzioniIniziali := AOpzioni;

  // Pagina 1: il testo e' nel DFM; AAvviso si aggiunge solo se dice altro.
  lblAvviso.Caption := AAvviso;
  lcScopoItemAvviso.Visible := AAvviso.Trim <> '';
  if FChiusura.PulsanteRec then
    lblComeSiUsa.Caption := '1. Avvia la registrazione con questa procedura.' + sLineBreak +
      '2. Ripeti l''operazione che d'#$00E0' problemi, una volta sola.' + sLineBreak +
      '3. Chiudi subito la registrazione con il pulsante rosso '#$25CF' REC in alto.'
  else
    lblComeSiUsa.Caption := '1. Avvia la registrazione con questa procedura.' + sLineBreak +
      '2. Ripeti l''operazione che d'#$00E0' problemi, una volta sola.' + sLineBreak +
      '3. Chiudi subito la registrazione con la stessa voce di menu' +
      IfThen(FChiusura.Scorciatoia <> '', ' o con ' + FChiusura.Scorciatoia, '') + '.';
  // La nota ripresa, se la procedura viene riaperta con una nota.
  memoNota.Lines.Text := AOpzioni.Nota;
  cbInviaAllaFine.Checked := AOpzioni.InviaAllaFine;

  // Pagina 2
  cbTempiFetch.Checked := AOpzioni.TempiFetch;
  cbTempiGriglia.Checked := AOpzioni.TempiGriglia;
  cbMonitorFireDAC.Checked := AOpzioni.MonitorFireDAC and AMonitorDisponibile;
  cbMonitorFireDAC.Enabled := AMonitorDisponibile;
  if not AMonitorDisponibile then
    lblMonitorFireDAC.Caption := 'Non disponibile in questo programma.';

  // Filmato, sempre nella pagina 2: nascosto dove non e' previsto.
  lcMisureGroupFilmato.Visible := FVideo.Previsto;
  cbVideo.Enabled := FVideo.Disponibile;
  cbVideo.Checked := AOpzioni.Video and FVideo.Disponibile;
  lblVideoNonDisponibile.Caption := 'Non disponibile su questo computer: ' + FVideo.Motivo;
  lcFilmatoItemNonDisponibile.Visible := FVideo.Previsto and not FVideo.Disponibile;
  // Limite del filmato e pausa in un solo testo; il limite si legge dalla
  // sessione, e senza limite resta la stima passata dall'applicazione.
  if FChiusura.DurataMassimaVideoMinuti > 0 then
    lblStimaVideo.Caption := Format('Il filmato si interrompe da solo dopo %d minuti.',
      [FChiusura.DurataMassimaVideoMinuti])
  else
    lblStimaVideo.Caption := FVideo.Stima;
  lblStimaVideo.Caption := Trim(lblStimaVideo.Caption + ' Per oscurare una schermata durante la registrazione ' +
    'premi Pausa filmato in alto.');
  AggiornaVideo;

  // Pagina 3: il segnalibro e' il pulsante accanto a REC (dal 2026-10-29 al
  // posto della voce di menu); senza pulsante resta la combinazione di tasti.
  if FChiusura.PulsanteRec then
    lblSegnalibro.Caption := 'Quando compare il problema: premi il pulsante Segnalibro in alto, accanto a REC' +
      IfThen(FChiusura.Segnalibro <> '', ', oppure la combinazione di tasti ' + FChiusura.Segnalibro, '') +
      '. Nella registrazione resta il segno del momento esatto, e l''assistenza lo trova subito.'
  else if FChiusura.Segnalibro <> '' then
    lblSegnalibro.Caption := 'Quando compare il problema: premi la combinazione di tasti ' + FChiusura.Segnalibro +
      '. Nella registrazione resta il segno del momento esatto, e l''assistenza lo trova subito.'
  else
    lblSegnalibro.Caption := '';
  lcAvvioItemSegnalibro.Visible := lblSegnalibro.Caption <> '';
  // La prenotazione si offre solo dove l'applicazione l'ha tolta dal menu.
  cbProssimoAvvio.Checked := False;
  lcAvvioItemProssimoAvvio.Visible := FChiusura.ProssimoAvvio;

  Wizard.ActivePage := pageScopo;
end;

function TFormOpzioniRegistrazione.ProssimoAvvioScelto: boolean;
begin
  result := FChiusura.ProssimoAvvio and cbProssimoAvvio.Checked;
end;

procedure TFormOpzioniRegistrazione.cbProssimoAvvioPropertiesChange(Sender: TObject);
begin
  AggiornaRiepilogo;
end;

function TFormOpzioniRegistrazione.CodiceDaChiedere: boolean;
begin
  result := cbVideo.Checked and (FVideo.Sblocco <> nil) and not FVideo.Sblocco.Sbloccato;
end;

// Il codice si controlla uscendo in avanti dalla pagina 2: se e'
// sbagliato si resta sulla pagina, con le scelte fatte, e l'utente riprova.
// Le regole sono quelle di zDiagnostica.Video.Sblocco (nessun limite di
// tentativi dal 2026-10-29, nessun codice sotto il debugger).
function TFormOpzioniRegistrazione.CodiceAccettato: boolean;
begin
  result := True;
  if not CodiceDaChiedere then
    Exit;
  result := FVideo.Sblocco.Verifica(edCodice.Text);
  if not result then
  begin
    ConfirmOk('Codice non valido: controlla le cifre o chiedine uno nuovo all''assistenza.' + sLineBreak + sLineBreak +
      'Per registrare senza filmato togli la spunta dalla casella.', mtWarning);
    if edCodice.CanFocus then
      edCodice.SetFocus;
  end;
end;

procedure TFormOpzioniRegistrazione.AggiornaVideo;
begin
  lcFilmatoItemCodice.Visible := CodiceDaChiedere;
  lcFilmatoItemStimaVideo.Visible := cbVideo.Checked;
end;

procedure TFormOpzioniRegistrazione.cbVideoPropertiesChange(Sender: TObject);
begin
  AggiornaVideo;
  if lcFilmatoItemCodice.Visible and edCodice.CanFocus then
    edCodice.SetFocus;
end;

procedure TFormOpzioniRegistrazione.AggiornaRiepilogo;
var
  Opzioni: TzOpzioniRegistrazione;
  Voci: TStringList;
  Elenco: string;
  Riepilogo: string;
  Chiusura: string;
begin
  Opzioni := Leggi;
  Voci := TStringList.Create;
  try
    Voci.Add('le operazioni che esegui nel programma');
    if Opzioni.TempiFetch and Opzioni.TempiGriglia then
      Voci.Add('i tempi di risposta dei dati e delle griglie')
    else if Opzioni.TempiFetch then
      Voci.Add('i tempi di risposta dei dati')
    else if Opzioni.TempiGriglia then
      Voci.Add('i tempi delle griglie');
    if Opzioni.MonitorFireDAC then
      Voci.Add('il registro dettagliato del database');
    if Opzioni.Video then
      Voci.Add('il filmato delle finestre del programma');
    // Elenco in italiano: virgole fra le voci, "e" prima dell'ultima.
    Elenco := Voci[Voci.Count - 1];
    if Voci.Count > 1 then
    begin
      Voci.Delete(Voci.Count - 1);
      Elenco := string.Join(', ', Voci.ToStringArray) + ' e ' + Elenco;
    end;
  finally
    FreeAndNil(Voci);
  end;
  Riepilogo := 'La registrazione comprender'#$00E0' ' + Elenco + '.';
  // 2026-10-29: prenotata, la registrazione parte alla prossima apertura,
  // prima dell'accesso. Filmato e registro del database li toglie Leggi: il
  // primo non ha ancora una finestra da riprendere, il secondo chiude e riapre
  // una connessione che all'avvio non esiste ancora.
  if ProssimoAvvioScelto then
  begin
    Riepilogo := Riepilogo + ' Non parte adesso: partir'#$00E0' da sola la prossima volta che apri il programma ' +
      'su questo computer, accesso compreso. Chiudi il programma e riaprilo.';
    if cbVideo.Checked or (cbMonitorFireDAC.Checked and cbMonitorFireDAC.Enabled) then
      Riepilogo := Riepilogo + ' Il filmato e il registro dettagliato del database all''avvio non si registrano.';
  end;
  if Opzioni.Nota.Trim <> '' then
    Riepilogo := Riepilogo + ' Sar'#$00E0' allegata la tua descrizione del problema.';
  if Opzioni.InviaAllaFine then
    Riepilogo := Riepilogo + ' Alla fine tutto verr'#$00E0' inviato automaticamente all''assistenza.'
  else
    Riepilogo := Riepilogo + ' Alla fine non verr'#$00E0' inviato niente: i file resteranno sul computer e ' +
      'ti verr'#$00E0' indicata la cartella.';
  lblRiepilogo.Caption := Riepilogo;

  if FChiusura.PulsanteRec then
    Chiusura := 'Come interrompere: per fermare la registrazione in qualsiasi momento premi il pulsante rosso ' +
      #$25CF' REC in alto, accanto al titolo della finestra'
  else
    Chiusura := 'Come interrompere: per fermare la registrazione in qualsiasi momento usa di nuovo la stessa voce ' +
      'di menu';
  if FChiusura.Scorciatoia <> '' then
    Chiusura := Chiusura + ', oppure la combinazione di tasti ' + FChiusura.Scorciatoia;
  lblChiusura.Caption := Chiusura + '.';

  // I limiti si leggono dalla sessione, non si scrivono nel testo: il filmato
  // ha il suo (15 minuti di norma), la registrazione uno piu' lungo.
  if Opzioni.Video and (FChiusura.DurataMassimaVideoMinuti > 0) and
    (FChiusura.DurataMassimaVideoMinuti < FChiusura.DurataMassimaMinuti) then
    lblLimite.Caption := Format('Interruzione automatica: il filmato si interrompe da solo dopo %d minuti e la ' +
      'registrazione dopo %d. Un minuto prima compare un avviso.', [FChiusura.DurataMassimaVideoMinuti,
      FChiusura.DurataMassimaMinuti])
  else if FChiusura.DurataMassimaMinuti > 0 then
    lblLimite.Caption := Format('Interruzione automatica: la registrazione si interrompe da sola dopo %d minuti. ' +
      'Un minuto prima compare un avviso.', [FChiusura.DurataMassimaMinuti])
  else
    lblLimite.Caption := '';
  lcAvvioItemLimite.Visible := lblLimite.Caption <> '';

  if ProssimoAvvioScelto then
    Wizard.Buttons.Finish.Caption := 'Prenota la registrazione'
  else
    Wizard.Buttons.Finish.Caption := 'Avvia la registrazione';
end;

procedure TFormOpzioniRegistrazione.WizardButtonClick(Sender: TObject; AKind: TdxWizardControlButtonKind;
  var AHandled: Boolean);
begin
  case AKind of
    wcbkCancel:
      begin
        AHandled := True;
        ModalResult := mrCancel;
      end;
    wcbkFinish:
      begin
        AHandled := True;
        // Rete di sicurezza: alla pagina finale si arriva solo passando dal
        // controllo del codice, ma senza codice il filmato non parte. La
        // prenotazione non ha filmato: il codice non serve.
        if ProssimoAvvioScelto or CodiceAccettato then
          ModalResult := mrOk;
      end;
  end;
end;

procedure TFormOpzioniRegistrazione.WizardPageChanging(Sender: TObject; ANewPage: TdxWizardControlCustomPage;
  var AAllow: Boolean);
begin
  // Solo in avanti: tornare indietro dalla pagina del filmato non chiede il codice.
  if (Wizard.ActivePage = pageMisure) and (ANewPage <> nil) and (ANewPage.PageIndex > pageMisure.PageIndex) then
    AAllow := CodiceAccettato;
  if AAllow then
    AggiornaVideo;
end;

procedure TFormOpzioniRegistrazione.WizardPageChanged(Sender: TObject);
begin
  if Wizard.ActivePage = pageAvvio then
    AggiornaRiepilogo
  else if Wizard.ActivePage = pageMisure then
    AggiornaVideo;
end;

function TFormOpzioniRegistrazione.Leggi: TzOpzioniRegistrazione;
begin
  result := FOpzioniIniziali;
  result.TempiFetch := cbTempiFetch.Checked;
  result.TempiGriglia := cbTempiGriglia.Checked;
  result.MonitorFireDAC := cbMonitorFireDAC.Checked and cbMonitorFireDAC.Enabled;
  // La nota si scrive qui: alla chiusura non si chiede piu'.
  result.Nota := memoNota.Lines.Text.Trim;
  result.ChiediCommento := False;
  result.InviaAllaFine := cbInviaAllaFine.Checked;
  result.Video := FVideo.Previsto and cbVideo.Checked and cbVideo.Enabled and
    ((FVideo.Sblocco = nil) or FVideo.Sblocco.Sbloccato);
  if ProssimoAvvioScelto then
  begin
    result.Video := False;
    result.MonitorFireDAC := False;
  end;
end;

function TFormOpzioniRegistrazione.Chiedi(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean;
  const AAvviso: string; const AVideo: TzVideoNellaFinestra; const AChiusura: TzChiusuraNellaFinestra;
  out AProssimoAvvio: boolean): boolean;
begin
  AProssimoAvvio := False;
  FVideo := AVideo;
  FChiusura := AChiusura;
  Carica(AOpzioni, AMonitorDisponibile, AAvviso);
  result := ShowModal = mrOk;
  if result then
  begin
    AOpzioni := Leggi;
    AProssimoAvvio := ProssimoAvvioScelto;
  end;
end;

end.
