// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------

// Form "Le mie segnalazioni": l'utente rivede le richieste di assistenza che
// ha aperto con zExceptions, segue la conversazione con l'assistenza,
// risponde con testo e allegati e chiude quelle risolte.
//
// Disposizione:
// - a sinistra l'elenco delle segnalazioni, con l'icona dello stato e quella
//   delle novita';
// - a destra la testata del ticket, la struttura della conversazione
//   (richiesta iniziale, risposte dell'assistenza, risposte del cliente, con
//   i loro allegati sotto) e l'anteprima della voce scelta: la conversazione
//   intera, un messaggio, oppure un allegato (PDF, Markdown, testo,
//   immagine);
// - in basso il riquadro della risposta, con i file da allegare: da disco,
//   trascinati, incollati con Ctrl+V, una schermata del programma o il
//   registro diagnostico. La risposta non inviata resta in bozza fino alla
//   chiusura del programma.
//
// Dalla barra si apre anche una richiesta nuova, non legata a un errore, e
// si esporta la conversazione in PDF. L'elenco nasconde di serie le
// segnalazioni chiuse e si filtra per testo.
//
// Sicurezza: gli allegati arrivano da Internet. I programmi (exe, script,
// collegamenti...) non si aprono mai dalla form, si possono solo salvare.
//
// L'assistenza risponde dal sito di Mantis allegando alla nota, se servono,
// file Markdown o PDF: qui arrivano sotto la loro risposta e si leggono senza
// uscire dal programma.
//
// Regole verificate sul Mantis Softline con un token di livello reporter:
// - il ticket si vede per intero (oggetto, descrizione, stato, assegnatario,
//   allegati); delle note arrivano solo le pubbliche; la storia non arriva;
// - si possono aggiungere note e allegati e chiudere un ticket risolto;
// - non si puo' riaprire ne' cambiare oggetto, priorita' o assegnatario.
// Con reassign_on_feedback (attivo di serie in MantisBT) una risposta a un
// ticket "in attesa di informazioni" lo riporta da solo all'assistenza.
//
// L'elenco dei ticket NON viene da Mantis (il reporter e' l'utente di
// servizio, uguale per tutti): viene dal registro locale
// IMantisSegnalazioniStore, che l'applicazione riempie all'apertura di ogni
// ticket. La form chiama Mantis solo per gli id di quella lista.
//
// Form autonoma di zPack sul modello di zExceptions.form: nessuna dipendenza
// da unit applicative, cosi' WT e Gesty la usano identica.

unit zMantis.TicketAssistenza.form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxCustomData,
  cxStyles,
  cxImageList,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxClasses,
  cxContainer,
  cxEdit,
  cxTextEdit,
  cxMemo,
  cxCheckBox,
  cxLabel,
  cxListBox,
  cxImage,
  cxButtons,
  cxSplitter,
  cxPC,
  dxBarBuiltInMenu,
  dxGDIPlusClasses,
  dxRichEdit.Types,
  dxRichEdit.Options,
  dxRichEdit.Control,
  dxRichEdit.Control.Core,
  dxRichEdit.NativeApi,
  dxRichEdit.Platform.Win.Control,
  dxCustomPreview,
  dxPDFDocument,
  dxPDFViewer,
  dxForms,
  zExceptions.mantis,
  Mantis.Api,
  Mantis.Segnalazioni.Types,
  Mantis.Segnalazioni.Html;

type
  TVoceTipo = (vtConversazione, vtMessaggio, vtAllegato);

  // Voce dell'albero della conversazione; il nodo porta l'indice in FVoci.
  TVoceConversazione = record
    Tipo: TVoceTipo;
    IndiceMessaggio: Integer; // vtMessaggio e vtAllegato
    Allegato: TMantisAllegato; // vtAllegato
  end;

  TzTicketAssistenzaForm = class(TdxForm)
    Immagini: TcxImageList;
    pnlComandi: TPanel;
    btnAggiorna: TcxButton;
    btnNuovaRichiesta: TcxButton;
    btnBrowser: TcxButton;
    btnChiudiTicket: TcxButton;
    btnEsportaPdf: TcxButton;
    btnEsci: TcxButton;
    pnlElenco: TPanel;
    pnlFiltro: TPanel;
    txtCerca: TcxTextEdit;
    chkMostraChiuse: TcxCheckBox;
    treeTicket: TcxTreeList;
    colNumero: TcxTreeListColumn;
    colData: TcxTreeListColumn;
    colOggetto: TcxTreeListColumn;
    colStato: TcxTreeListColumn;
    splitter: TcxSplitter;
    pnlDettaglio: TPanel;
    pnlTestata: TPanel;
    lblTitolo: TcxLabel;
    lblInfo: TcxLabel;
    pnlAvviso: TPanel;
    lblAvviso: TcxLabel;
    pnlRisposta: TPanel;
    lblRisposta: TcxLabel;
    memoRisposta: TcxMemo;
    pnlAllegatiRisposta: TPanel;
    lstAllegatiRisposta: TcxListBox;
    pnlAllegatiComandi: TPanel;
    btnAllegaFile: TcxButton;
    btnSchermata: TcxButton;
    btnRegistro: TcxButton;
    btnTogliAllegato: TcxButton;
    pnlInvio: TPanel;
    lblStatoRisposta: TcxLabel;
    btnInvia: TcxButton;
    splitterRisposta: TcxSplitter;
    treeConversazione: TcxTreeList;
    colVoce: TcxTreeListColumn;
    colVoceData: TcxTreeListColumn;
    splitterConversazione: TcxSplitter;
    pnlAnteprima: TPanel;
    pnlAnteprimaComandi: TPanel;
    lblAnteprima: TcxLabel;
    btnApriAllegato: TcxButton;
    btnSalvaAllegato: TcxButton;
    pcAnteprima: TcxPageControl;
    tabTesto: TcxTabSheet;
    richAnteprima: TdxRichEditControl;
    tabPdf: TcxTabSheet;
    pdfAnteprima: TdxPDFViewer;
    tabImmagine: TcxTabSheet;
    imgAnteprima: TcxImage;
    dlgApri: TOpenDialog;
    dlgSalva: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAggiornaClick(Sender: TObject);
    procedure btnBrowserClick(Sender: TObject);
    procedure btnChiudiTicketClick(Sender: TObject);
    procedure btnEsciClick(Sender: TObject);
    procedure btnAllegaFileClick(Sender: TObject);
    procedure btnTogliAllegatoClick(Sender: TObject);
    procedure btnInviaClick(Sender: TObject);
    procedure btnApriAllegatoClick(Sender: TObject);
    procedure btnSalvaAllegatoClick(Sender: TObject);
    procedure treeTicketSelectionChanged(Sender: TObject);
    procedure treeConversazioneSelectionChanged(Sender: TObject);
    procedure treeConversazioneDblClick(Sender: TObject);
    procedure memoRispostaPropertiesChange(Sender: TObject);
    procedure lstAllegatiRispostaClick(Sender: TObject);
    procedure btnNuovaRichiestaClick(Sender: TObject);
    procedure btnEsportaPdfClick(Sender: TObject);
    procedure btnSchermataClick(Sender: TObject);
    procedure btnRegistroClick(Sender: TObject);
    procedure txtCercaPropertiesChange(Sender: TObject);
    procedure chkMostraChiusePropertiesChange(Sender: TObject);
    procedure memoRispostaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FParametri: TMantisServerParams;
    // Dimensione massima di un allegato su Mantis (max_file_size), 0 se non
    // e' leggibile con il token: in quel caso decide Mantis all'invio.
    FLimiteFile: Int64;
    // Ticket di cui sono mostrati dettaglio e risposta: la bozza si salva
    // sotto questo numero quando si passa a un altro.
    FIdMostrato: Integer;
    FApi: TMantisApi;
    FStore: IMantisSegnalazioniStore;
    FLocali: TArray<TMantisSegnalazioneLocale>;
    // Dettagli letti da Mantis in questa sessione, per numero di ticket.
    FDettagli: TDictionary<Integer, TMantisIssue>;
    // Ticket che Mantis non ha restituito, con il motivo: la riga resta con
    // la copia locale e l'avviso "non aggiornato".
    FErrori: TDictionary<Integer, string>;
    // Conversazione del ticket mostrato e voci del suo albero.
    FMessaggi: TArray<TMantisMessaggio>;
    FVoci: TArray<TVoceConversazione>;
    // File scelti per la prossima risposta, percorsi completi.
    FAllegatiRisposta: TStringList;
    // Colori dell'anteprima, ricavati dalla skin a ogni caricamento.
    FColori: TMantisColoriHtml;
    function IdSelezionato: Integer;
    function IndiceLocale(AId: Integer): Integer;
    function DettaglioSelezionato(out AIssue: TMantisIssue): Boolean;
    function VoceSelezionata(out AVoce: TVoceConversazione): Boolean;
    // Legge il ticket da Mantis e aggiorna la copia locale. False se la
    // chiamata fallisce: il motivo finisce in FErrori.
    function LeggiDaMantis(AId: Integer): Boolean;
    procedure CaricaElenco;
    procedure AggiornaRiga(ANodo: TcxTreeListNode; const ALocale: TMantisSegnalazioneLocale);
    procedure MostraDettaglio(AId: Integer);
    procedure MostraTestata(const AIssue: TMantisIssue);
    procedure MostraTestataLocale(AId: Integer);
    procedure CostruisciConversazione(const AIssue: TMantisIssue);
    procedure MostraVoce;
    procedure MostraAllegato(AId: Integer; const AAllegato: TMantisAllegato);
    procedure CaricaHtml(const AHtml: string);
    // Colori dell'anteprima e della striscia di avviso dalla skin attiva.
    procedure AggiornaColori;
    procedure SegnaVisto(AId: Integer);
    procedure RileggiSelezionato;
    // Percorso locale dell'allegato, scaricato da Mantis la prima volta.
    function FileAllegato(AId: Integer; const AAllegato: TMantisAllegato): string;
    procedure AggiungiAllegatiRisposta(const APercorsi: array of string);
    procedure AggiornaAllegatiRisposta;
    procedure AggiornaComandi;
    procedure AggiornaTitolo;
    // Nasconde le righe escluse dal filtro (chiuse, testo cercato).
    procedure ApplicaFiltro;
    function RigaVisibile(const ALocale: TMantisSegnalazioneLocale): Boolean;
    procedure SelezionaTicket(AId: Integer);
    // Bozza della risposta del ticket mostrato, salvata e ripresa.
    procedure SalvaBozza;
    procedure RipristinaBozza(AId: Integer);
    procedure AggiornaRegistro;
    // Data dell'ultima risposta dell'assistenza nella conversazione, 0 se
    // non ce ne sono.
    function UltimaRispostaAssistenza: TDateTime;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  protected
    procedure CreateWnd; override;
  public
    procedure Inizializza(const AParametri: TMantisServerParams; const AStore: IMantisSegnalazioniStore);
  end;

// Apre la form in modo modale. AParametri sono quelli gia' caricati in
// TzExceptionManager.MantisServerParams; AStore e' il registro locale
// dell'applicazione.
procedure MostraTicketAssistenza(const AParametri: TMantisServerParams; const AStore: IMantisSegnalazioniStore);

implementation

uses
  Winapi.ShellAPI,
  System.IOUtils,
  System.StrUtils,
  System.Variants,
  dxRichEdit.Html,
  dxRichEdit.PlainText,
  dxPSCore,
  dxPSRichEditControlLnk,
  zMsg,
  zExceptions.utils,
  zDiagnostica.Log,
  Mantis.Segnalazioni.Allegati,
  zMantis.NuovaRichiesta.form;

{$R *.dfm}

const
  FormatoDataOra = 'dd/mm/yyyy hh:nn';
  FormatoData = 'dd/mm/yyyy';
  // Nell'albero della conversazione la colonna e' stretta.
  FormatoDataOraBreve = 'dd/mm/yy hh:nn';

  // Indici di Immagini, nell'ordine della lista nel .dfm.
  idxAggiorna = 0;
  idxBrowser = 1;
  idxChiudiSegnalazione = 2;
  idxEsci = 3;
  idxAllega = 4;
  idxTogli = 5;
  idxInvia = 6;
  idxSalva = 7;
  idxApri = 8;
  idxStatoNuova = 9;
  idxStatoAttesa = 10;
  idxStatoInCarico = 11;
  idxStatoSospesa = 12;
  idxStatoRisolta = 13;
  idxStatoChiusa = 14;
  idxNovita = 15;
  idxConversazione = 16;
  idxRichiesta = 17;
  idxRispostaAssistenza = 18;
  idxNotaCliente = 19;
  idxAllegatoPdf = 20;
  idxAllegatoMarkdown = 21;
  idxAllegatoImmagine = 22;
  idxAllegatoTesto = 23;
  idxAllegatoAltro = 24;
  idxNuovaRichiesta = 25;
  idxSchermata = 26;
  idxRegistro = 27;
  idxEsportaPdf = 28;

  // Un file di testo oltre questa dimensione non si mostra nell'anteprima:
  // il RichEdit impiegherebbe troppo a impaginarlo.
  DimensioneMassimaAnteprimaTesto = 2 * 1024 * 1024;

  // Allegati scaricati, schermate e registri in %TEMP%\zMantis: oltre questa
  // eta' si tolgono.
  GiorniCartellaTemporanea = 30;

  // Lunghezza massima dell'oggetto di un ticket MantisBT (campo summary).
  LunghezzaMassimaOggetto = 128;

type
  // Risposta non ancora inviata: testo e file scelti.
  TBozzaRisposta = record
    Testo: string;
    Allegati: TArray<string>;
  end;

var
  // Bozze per numero di ticket. Vivono quanto il programma: chi chiude la
  // form per riprodurre un problema ritrova la risposta a meta' quando la
  // riapre.
  Bozze: TDictionary<Integer, TBozzaRisposta> = nil;
  // La pulizia della cartella temporanea si fa una volta per esecuzione.
  CartellaTemporaneaPulita: Boolean = False;

function ElencoBozze: TDictionary<Integer, TBozzaRisposta>;
begin
  if Bozze = nil then
    Bozze := TDictionary<Integer, TBozzaRisposta>.Create;
  Result := Bozze;
end;

function GiorniFaTesto(AData: TDateTime): string;
var
  Giorni: Integer;
begin
  Giorni := Trunc(Date) - Trunc(AData);
  if Giorni <= 0 then
    Result := 'oggi'
  else
    if Giorni = 1 then
      Result := 'ieri'
    else
      Result := Format('%d giorni fa', [Giorni]);
end;

procedure MostraTicketAssistenza(const AParametri: TMantisServerParams; const AStore: IMantisSegnalazioniStore);
var
  Form: TzTicketAssistenzaForm;
begin
  Application.CreateForm(TzTicketAssistenzaForm, Form);
  try
    Form.Inizializza(AParametri, AStore);
    Form.ShowModal;
  finally
    FreeAndNil(Form);
  end;
end;

function DataOraTesto(AValore: TDateTime; const AFormato: string = FormatoDataOra): string;
begin
  if AValore = 0 then
    Result := '-'
  else
    Result := FormatDateTime(AFormato, AValore);
end;

function IndiceStato(const AStato: string): Integer;
begin
  if SameText(AStato, 'new') then
    Result := idxStatoNuova
  else
    if SameText(AStato, 'feedback') then
      Result := idxStatoAttesa
    else
      if SameText(AStato, 'sospesa') then
        Result := idxStatoSospesa
      else
        if SameText(AStato, 'resolved') then
          Result := idxStatoRisolta
        else
          if SameText(AStato, 'closed') then
            Result := idxStatoChiusa
          else
            Result := idxStatoInCarico;
end;

function IndiceMessaggio(ATipo: TMantisTipoMessaggio): Integer;
begin
  case ATipo of
    tmRichiesta:
      Result := idxRichiesta;
    tmRispostaAssistenza:
      Result := idxRispostaAssistenza;
  else
    Result := idxNotaCliente;
  end;
end;

function IndiceAllegato(const ANome: string): Integer;
begin
  case MantisFormatoAllegato(ANome) of
    faPdf:
      Result := idxAllegatoPdf;
    faMarkdown:
      Result := idxAllegatoMarkdown;
    faImmagine:
      Result := idxAllegatoImmagine;
    faTesto:
      Result := idxAllegatoTesto;
  else
    Result := idxAllegatoAltro;
  end;
end;

// Nome di file sicuro per la cartella temporanea.
function NomeFileSicuro(const ANome: string): string;
var
  Carattere: Char;
begin
  Result := ANome;
  for Carattere in TPath.GetInvalidFileNameChars do
    Result := Result.Replace(Carattere, '_');
  if Result = '' then
    Result := 'allegato';
end;

{ TzTicketAssistenzaForm }

procedure TzTicketAssistenzaForm.FormCreate(Sender: TObject);
begin
  FApi := nil;
  FStore := nil;
  FLocali := [];
  FMessaggi := [];
  FVoci := [];
  FDettagli := TDictionary<Integer, TMantisIssue>.Create;
  FErrori := TDictionary<Integer, string>.Create;
  FAllegatiRisposta := TStringList.Create;
  FLimiteFile := 0;
  FIdMostrato := 0;

  if not CartellaTemporaneaPulita then
  begin
    CartellaTemporaneaPulita := True;
    MantisPulisciCartellaTemporanea(GiorniCartellaTemporanea);
  end;

  treeTicket.BorderStyle := cxcbsNone;
  treeTicket.LookAndFeel.Kind := lfFlat;
  treeConversazione.BorderStyle := cxcbsNone;
  treeConversazione.LookAndFeel.Kind := lfFlat;

  richAnteprima.ReadOnly := True;
  // I collegamenti delle risposte si aprono con il semplice clic.
  richAnteprima.Options.Hyperlinks.ModifierKeys := 0;
  richAnteprima.Options.Import.Html.AsyncImageLoading := False;
  richAnteprima.Views.Simple.Padding.All := 8;
  // Nella vista semplice il testo va a capo da solo: la barra orizzontale
  // comparirebbe vuota.
  richAnteprima.Options.HorizontalScrollbar.Visibility := TdxRichEditScrollbarVisibility.Hidden;

  pcAnteprima.ActivePage := tabTesto;
  pnlAvviso.Visible := False;
  AggiornaColori;
  AggiornaRegistro;

  AggiornaComandi;
end;

procedure TzTicketAssistenzaForm.CreateWnd;
begin
  inherited;
  // I file trascinati sulla form vanno nella risposta. Qui e non in
  // FormCreate: la finestra si ricrea, per esempio al cambio di skin.
  DragAcceptFiles(Handle, True);
end;

procedure TzTicketAssistenzaForm.FormDestroy(Sender: TObject);
begin
  SalvaBozza;
  FreeAndNil(FAllegatiRisposta);
  FreeAndNil(FDettagli);
  FreeAndNil(FErrori);
  FreeAndNil(FApi);
  FStore := nil;
end;

procedure TzTicketAssistenzaForm.Inizializza(const AParametri: TMantisServerParams; const AStore: IMantisSegnalazioniStore);
begin
  FreeAndNil(FApi);
  FApi := TMantisApi.Create(AParametri.BaseUrl, AParametri.ApiToken, AParametri.TimeoutMs);
  FParametri := AParametri;
  FStore := AStore;
  FLimiteFile := FApi.ConfigNumero('max_file_size', 0);
  CaricaElenco;
end;

function TzTicketAssistenzaForm.IdSelezionato: Integer;
begin
  Result := 0;
  if (treeTicket.FocusedNode <> nil) and not VarIsNull(treeTicket.FocusedNode.Values[0]) then
    Result := treeTicket.FocusedNode.Values[0];
end;

function TzTicketAssistenzaForm.IndiceLocale(AId: Integer): Integer;
var
  Indice: Integer;
begin
  Result := -1;
  for Indice := 0 to High(FLocali) do
    if FLocali[Indice].IdTicket = AId then
      Exit(Indice);
end;

function TzTicketAssistenzaForm.DettaglioSelezionato(out AIssue: TMantisIssue): Boolean;
var
  Id: Integer;
begin
  Id := IdSelezionato;
  Result := (Id > 0) and (FDettagli <> nil) and FDettagli.TryGetValue(Id, AIssue);
end;

function TzTicketAssistenzaForm.VoceSelezionata(out AVoce: TVoceConversazione): Boolean;
var
  Indice: Integer;
begin
  Result := False;
  if treeConversazione.FocusedNode = nil then
    Exit;
  Indice := Integer(treeConversazione.FocusedNode.Data);
  if (Indice < 0) or (Indice > High(FVoci)) then
    Exit;
  AVoce := FVoci[Indice];
  Result := True;
end;

function TzTicketAssistenzaForm.LeggiDaMantis(AId: Integer): Boolean;
var
  Issue: TMantisIssue;
  Indice: Integer;
begin
  Result := False;
  try
    Issue := FApi.Issue(AId);
  except
    on E: Exception do
    begin
      FErrori.AddOrSetValue(AId, E.Message);
      Exit;
    end;
  end;

  FDettagli.AddOrSetValue(AId, Issue);
  FErrori.Remove(AId);

  Indice := IndiceLocale(AId);
  if Indice >= 0 then
  begin
    FLocali[Indice].Stato := Issue.Stato;
    FLocali[Indice].AssegnatoA := Issue.AssegnatarioVisibile;
    FLocali[Indice].AggiornatoIl := Issue.AggiornatoIl;
    // La copia locale serve all'avviso di novita' al prossimo avvio e alle
    // righe dei ticket chiusi, che non si rileggono piu'.
    try
      FStore.Aggiorna(AId, Issue.Stato, Issue.AssegnatarioVisibile, Issue.AggiornatoIl);
    except
      on E: Exception do
        ConfirmOk('Aggiornamento della copia locale non riuscito:' + sLineBreak + E.Message, mtWarning);
    end;
  end;
  Result := True;
end;

procedure TzTicketAssistenzaForm.AggiornaRiga(ANodo: TcxTreeListNode; const ALocale: TMantisSegnalazioneLocale);
var
  Stato: string;
begin
  Stato := MantisStatoEtichetta(ALocale.Stato);
  if FErrori.ContainsKey(ALocale.IdTicket) then
    Stato := Stato + ' (non aggiornato)';

  ANodo.Values[0] := ALocale.IdTicket;
  ANodo.Values[1] := DataOraTesto(ALocale.DataApertura, FormatoData);
  // "[WinTarif3.exe - Luca]" e' uguale su tutte le righe: in elenco si toglie.
  ANodo.Values[2] := MantisOggettoSenzaPrefisso(ALocale.Oggetto);
  ANodo.Values[3] := Stato;
  ANodo.ImageIndex := IndiceStato(ALocale.Stato);
  ANodo.SelectedIndex := ANodo.ImageIndex;
  // La campanella dice che c'e' qualcosa di nuovo da leggere.
  if ALocale.Novita then
    ANodo.StateIndex := idxNovita
  else
    ANodo.StateIndex := -1;
end;

procedure TzTicketAssistenzaForm.CaricaElenco;
var
  Indice: Integer;
  Nodo: TcxTreeListNode;
  CursorePrecedente: TCursor;
begin
  CursorePrecedente := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  treeTicket.BeginUpdate;
  try
    treeTicket.Clear;
    FDettagli.Clear;
    FErrori.Clear;

    FLocali := FStore.Elenco;

    // I ticket aperti si rileggono subito da Mantis, una chiamata ciascuno;
    // i chiusi restano sulla copia locale e si leggono solo se selezionati.
    for Indice := 0 to High(FLocali) do
    begin
      if not FLocali[Indice].Chiuso then
        LeggiDaMantis(FLocali[Indice].IdTicket);
      Nodo := treeTicket.Root.AddChild;
      AggiornaRiga(Nodo, FLocali[Indice]);
    end;
  finally
    treeTicket.EndUpdate;
    Screen.Cursor := CursorePrecedente;
  end;

  AggiornaTitolo;
  ApplicaFiltro;
  AggiornaComandi;
end;

function TzTicketAssistenzaForm.RigaVisibile(const ALocale: TMantisSegnalazioneLocale): Boolean;
var
  Cerca: string;
begin
  // Le chiuse restano disponibili ma non ingombrano: per rileggerle basta
  // la spunta.
  if ALocale.Chiuso and not chkMostraChiuse.Checked then
    Exit(False);
  Cerca := Trim(txtCerca.Text);
  Result := (Cerca = '') or ContainsText(ALocale.Oggetto, Cerca) or ContainsText(ALocale.IdTicket.ToString, Cerca) or
    ContainsText(MantisStatoEtichetta(ALocale.Stato), Cerca);
end;

procedure TzTicketAssistenzaForm.ApplicaFiltro;
var
  Indice, IdLocale: Integer;
  Nodo, PrimaVisibile: TcxTreeListNode;
begin
  PrimaVisibile := nil;
  treeTicket.BeginUpdate;
  try
    for Indice := 0 to treeTicket.Root.Count - 1 do
    begin
      Nodo := treeTicket.Root.Items[Indice];
      IdLocale := IndiceLocale(Nodo.Values[0]);
      Nodo.Visible := (IdLocale >= 0) and RigaVisibile(FLocali[IdLocale]);
      if Nodo.Visible and (PrimaVisibile = nil) then
        PrimaVisibile := Nodo;
    end;
  finally
    treeTicket.EndUpdate;
  end;

  // La riga selezionata resta se e' ancora visibile; altrimenti la prima.
  if (treeTicket.FocusedNode <> nil) and treeTicket.FocusedNode.Visible then
  begin
    if IdSelezionato <> FIdMostrato then
      MostraDettaglio(IdSelezionato);
  end
  else
    if PrimaVisibile <> nil then
      PrimaVisibile.Focused := True
    else
    begin
      treeTicket.FocusedNode := nil;
      MostraDettaglio(0);
    end;
end;

procedure TzTicketAssistenzaForm.SelezionaTicket(AId: Integer);
var
  Indice: Integer;
begin
  for Indice := 0 to treeTicket.Root.Count - 1 do
    if treeTicket.Root.Items[Indice].Values[0] = AId then
    begin
      treeTicket.Root.Items[Indice].Visible := True;
      treeTicket.Root.Items[Indice].Focused := True;
      Exit;
    end;
end;

procedure TzTicketAssistenzaForm.AggiornaTitolo;
var
  Indice: Integer;
  Novita: Integer;
begin
  Novita := 0;
  for Indice := 0 to High(FLocali) do
    if FLocali[Indice].Novita then
      Inc(Novita);

  if Novita > 0 then
    Caption := Format('Le mie segnalazioni (%d con novita'')', [Novita])
  else
    Caption := 'Le mie segnalazioni';
end;

function TzTicketAssistenzaForm.UltimaRispostaAssistenza: TDateTime;
var
  Messaggio: TMantisMessaggio;
begin
  Result := 0;
  for Messaggio in FMessaggi do
    if (Messaggio.Tipo = tmRispostaAssistenza) and (Messaggio.Data > Result) then
      Result := Messaggio.Data;
end;

procedure TzTicketAssistenzaForm.MostraTestata(const AIssue: TMantisIssue);
var
  Info, Quando: string;
  Ultima: TDateTime;
begin
  lblTitolo.Caption := Format('Segnalazione n. %d - %s', [AIssue.Id, MantisOggettoSenzaPrefisso(AIssue.Oggetto)]);
  Info := 'Stato: ' + MantisStatoEtichetta(AIssue.Stato);
  if AIssue.AssegnatarioVisibile <> '' then
    Info := Info + '    Presa in carico da: ' + AIssue.AssegnatarioVisibile;
  Info := Info + '    Aperta il: ' + DataOraTesto(AIssue.CreatoIl);
  // "Quanto tempo fa" dice piu' dell'ultimo aggiornamento, che cambia anche
  // per una risposta del cliente.
  Ultima := UltimaRispostaAssistenza;
  Quando := '';
  if Ultima <> 0 then
  begin
    Quando := GiorniFaTesto(Ultima);
    Info := Info + '    Ultima risposta dell''assistenza: ' + DataOraTesto(Ultima) + ' (' + Quando + ')';
  end
  else
    Info := Info + '    Nessuna risposta dell''assistenza per ora';
  lblInfo.Caption := Info;

  // L'avviso dice all'utente cosa ci si aspetta da lui adesso.
  if SameText(AIssue.Stato, 'feedback') then
  begin
    if Quando <> '' then
      Quando := ' ' + Quando;
    lblAvviso.Caption := 'L''assistenza ti ha chiesto maggiori informazioni' + Quando + ': rispondi qui sotto. ' +
      'Con la tua risposta la segnalazione torna all''assistenza.';
    pnlAvviso.Visible := True;
  end
  else
    if AIssue.Risolto then
    begin
      lblAvviso.Caption := 'L''assistenza considera risolta la segnalazione: se confermi, chiudila con "Chiudi segnalazione". ' +
        'Se il problema c''e'' ancora, scrivilo qui sotto.';
      pnlAvviso.Visible := True;
    end
    else
      pnlAvviso.Visible := False;
end;

procedure TzTicketAssistenzaForm.MostraTestataLocale(AId: Integer);
var
  Indice: Integer;
begin
  pnlAvviso.Visible := False;
  Indice := IndiceLocale(AId);
  if Indice < 0 then
  begin
    lblTitolo.Caption := '';
    lblInfo.Caption := '';
    Exit;
  end;
  lblTitolo.Caption := Format('Segnalazione n. %d - %s', [AId, MantisOggettoSenzaPrefisso(FLocali[Indice].Oggetto)]);
  lblInfo.Caption := 'Stato (copia locale): ' + MantisStatoEtichetta(FLocali[Indice].Stato) + '    Aperta il: ' +
    DataOraTesto(FLocali[Indice].DataApertura) + '    Ultimo aggiornamento: ' + DataOraTesto(FLocali[Indice].AggiornatoIl);
end;

procedure TzTicketAssistenzaForm.CostruisciConversazione(const AIssue: TMantisIssue);

  function AggiungiVoce(const AVoce: TVoceConversazione): Integer;
  begin
    FVoci := FVoci + [AVoce];
    Result := High(FVoci);
  end;

var
  Radice, NodoMessaggio, NodoAllegato: TcxTreeListNode;
  Voce: TVoceConversazione;
  Indice: Integer;
  Allegato: TMantisAllegato;
begin
  FMessaggi := MantisConversazione(AIssue);
  FVoci := [];

  treeConversazione.BeginUpdate;
  try
    treeConversazione.Clear;

    Voce := Default (TVoceConversazione);
    Voce.Tipo := vtConversazione;
    Radice := treeConversazione.Root.AddChild;
    Radice.Data := Pointer(AggiungiVoce(Voce));
    if Length(FMessaggi) = 1 then
      Radice.Values[0] := 'Conversazione (1 messaggio)'
    else
      Radice.Values[0] := Format('Conversazione (%d messaggi)', [Length(FMessaggi)]);
    Radice.ImageIndex := idxConversazione;
    Radice.SelectedIndex := idxConversazione;

    for Indice := 0 to High(FMessaggi) do
    begin
      Voce := Default (TVoceConversazione);
      Voce.Tipo := vtMessaggio;
      Voce.IndiceMessaggio := Indice;
      NodoMessaggio := Radice.AddChild;
      NodoMessaggio.Data := Pointer(AggiungiVoce(Voce));
      if FMessaggi[Indice].Autore <> '' then
        NodoMessaggio.Values[0] := FMessaggi[Indice].EtichettaBreve + ' - ' + FMessaggi[Indice].Autore
      else
        NodoMessaggio.Values[0] := FMessaggi[Indice].EtichettaBreve;
      NodoMessaggio.Values[1] := DataOraTesto(FMessaggi[Indice].Data, FormatoDataOraBreve);
      NodoMessaggio.ImageIndex := IndiceMessaggio(FMessaggi[Indice].Tipo);
      NodoMessaggio.SelectedIndex := NodoMessaggio.ImageIndex;

      for Allegato in FMessaggi[Indice].Allegati do
      begin
        Voce := Default (TVoceConversazione);
        Voce.Tipo := vtAllegato;
        Voce.IndiceMessaggio := Indice;
        Voce.Allegato := Allegato;
        NodoAllegato := NodoMessaggio.AddChild;
        NodoAllegato.Data := Pointer(AggiungiVoce(Voce));
        NodoAllegato.Values[0] := Allegato.Nome;
        NodoAllegato.Values[1] := MantisDimensioneTesto(Allegato.Dimensione);
        NodoAllegato.ImageIndex := IndiceAllegato(Allegato.Nome);
        NodoAllegato.SelectedIndex := NodoAllegato.ImageIndex;
      end;
    end;

    treeConversazione.FullExpand;
  finally
    treeConversazione.EndUpdate;
  end;

  // Si parte dalla conversazione intera: e' la lettura piu' naturale.
  Radice.Focused := True;
end;

procedure TzTicketAssistenzaForm.MostraDettaglio(AId: Integer);
var
  Issue: TMantisIssue;
  Motivo: string;
begin
  // La risposta in corso sul ticket precedente resta in bozza.
  SalvaBozza;
  // Ricalcolati a ogni ticket: seguono un cambio di skin a form aperta.
  AggiornaColori;
  FMessaggi := [];
  FVoci := [];
  treeConversazione.Clear;

  if AId = 0 then
  begin
    RipristinaBozza(0);
    lblTitolo.Caption := '';
    lblInfo.Caption := '';
    pnlAvviso.Visible := False;
    lblAnteprima.Caption := '';
    pcAnteprima.ActivePage := tabTesto;
    if Length(FLocali) = 0 then
      CaricaHtml(MantisHtmlAvviso('Nessuna richiesta di assistenza aperta da questo utente. ' +
        'Per chiedere qualcosa all''assistenza usa "Nuova richiesta".', FColori))
    else
      CaricaHtml(MantisHtmlAvviso('Nessuna segnalazione con il filtro attuale: le chiuse si vedono con ' +
        '"Mostra chiuse".', FColori));
    AggiornaComandi;
    Exit;
  end;

  // Ticket chiusi: lettura a richiesta, la prima volta che vengono aperti.
  if (not FDettagli.ContainsKey(AId)) and (not FErrori.ContainsKey(AId)) then
    LeggiDaMantis(AId);

  if FDettagli.TryGetValue(AId, Issue) then
  begin
    // Prima la conversazione: la testata ne legge l'ultima risposta.
    CostruisciConversazione(Issue);
    MostraTestata(Issue);
    SegnaVisto(AId);
  end
  else
  begin
    MostraTestataLocale(AId);
    if not FErrori.TryGetValue(AId, Motivo) then
      Motivo := '';
    lblAnteprima.Caption := '';
    pcAnteprima.ActivePage := tabTesto;
    CaricaHtml(MantisHtmlAvviso(('Il dettaglio non e'' disponibile: il servizio di assistenza non ha risposto. ' + Motivo).Trim, FColori));
  end;

  RipristinaBozza(AId);
  AggiornaComandi;
end;

procedure TzTicketAssistenzaForm.SalvaBozza;
var
  Bozza: TBozzaRisposta;
begin
  if (FIdMostrato = 0) or (FAllegatiRisposta = nil) then
    Exit;
  Bozza.Testo := memoRisposta.Text;
  Bozza.Allegati := FAllegatiRisposta.ToStringArray;
  if (Trim(Bozza.Testo) = '') and (Length(Bozza.Allegati) = 0) then
    ElencoBozze.Remove(FIdMostrato)
  else
    ElencoBozze.AddOrSetValue(FIdMostrato, Bozza);
end;

procedure TzTicketAssistenzaForm.RipristinaBozza(AId: Integer);
var
  Bozza: TBozzaRisposta;
  Percorso: string;
begin
  FIdMostrato := AId;
  FAllegatiRisposta.Clear;
  if (AId <> 0) and ElencoBozze.TryGetValue(AId, Bozza) then
  begin
    memoRisposta.Text := Bozza.Testo;
    // Un file tolto dal disco nel frattempo non si ripresenta.
    for Percorso in Bozza.Allegati do
      if TFile.Exists(Percorso) then
        FAllegatiRisposta.Add(Percorso);
  end
  else
    memoRisposta.Clear;
  AggiornaAllegatiRisposta;
end;

procedure TzTicketAssistenzaForm.SegnaVisto(AId: Integer);
var
  Indice: Integer;
begin
  // L'utente ha visto il ticket: le novita' fino a qui sono lette.
  Indice := IndiceLocale(AId);
  if (Indice < 0) or not FLocali[Indice].Novita then
    Exit;
  try
    FStore.Visto(AId);
  except
    on E: Exception do
      ConfirmOk('Aggiornamento della copia locale non riuscito:' + sLineBreak + E.Message, mtWarning);
  end;
  FLocali[Indice].UltimoAggiornamentoVisto := FLocali[Indice].AggiornatoIl;
  if treeTicket.FocusedNode <> nil then
    AggiornaRiga(treeTicket.FocusedNode, FLocali[Indice]);
  AggiornaTitolo;
end;

procedure TzTicketAssistenzaForm.AggiornaColori;

  function Html(AColore: TColor): string;
  var
    Rgb: Integer;
  begin
    Rgb := ColorToRGB(AColore);
    Result := Format('#%.2x%.2x%.2x', [GetRValue(Rgb), GetGValue(Rgb), GetBValue(Rgb)]);
  end;

  // Mescola due colori: APeso = quota di ASopra, da 0 a 100.
  function Mescola(ASotto, ASopra: TColor; APeso: Integer): TColor;
  var
    Sotto, Sopra: Integer;
  begin
    Sotto := ColorToRGB(ASotto);
    Sopra := ColorToRGB(ASopra);
    Result := RGB((GetRValue(Sotto) * (100 - APeso) + GetRValue(Sopra) * APeso) div 100,
      (GetGValue(Sotto) * (100 - APeso) + GetGValue(Sopra) * APeso) div 100,
      (GetBValue(Sotto) * (100 - APeso) + GetBValue(Sopra) * APeso) div 100);
  end;

const
  // Accenti dei riquadri e dell'avviso: gli stessi delle icone MDI (Blue,
  // Yellow), mescolati col fondo della skin perche' reggano sia sul chiaro
  // sia sullo scuro.
  Azzurro = TColor($D77711);
  Giallo = TColor($15B1FF);
  Grigio = TColor($8A8A8A);
var
  Painter: TcxCustomLookAndFeelPainter;
  Sfondo: TColor;
begin
  // Senza skin (stile nativo di Windows) resta lo schema chiaro.
  Painter := RootLookAndFeel.SkinPainter;
  if Painter = nil then
  begin
    FColori := TMantisColoriHtml.Chiari;
    pnlAvviso.Color := Mescola(clWindow, Giallo, 30);
    Exit;
  end;

  // Stessi colori del painter usati da zMarkdownViewer per l'anteprima.
  Sfondo := Painter.DefaultContentColor;
  FColori.Sfondo := Html(Sfondo);
  FColori.Testo := Html(Painter.DefaultContentTextColor);
  FColori.TestoSecondario := Html(Painter.DefaultInactiveTextColor);
  FColori.Titolo := Html(Painter.DefaultHyperlinkTextColor);
  FColori.Collegamento := Html(Painter.DefaultHyperlinkTextColor);
  FColori.FondoCodice := Html(Painter.DefaultControlColor);
  FColori.TestoCodice := Html(Painter.DefaultControlTextColor);
  FColori.Bordo := Html(Painter.DefaultGridLineColor);
  FColori.FondoIntestazioneTabella := Html(Painter.DefaultHeaderColor);
  FColori.TestoIntestazioneTabella := Html(Painter.DefaultHeaderTextColor);
  FColori.FondoAssistenza := Html(Mescola(Sfondo, Azzurro, 22));
  FColori.BordoAssistenza := Html(Azzurro);
  FColori.FondoCliente := Html(Mescola(Sfondo, Grigio, 22));
  FColori.BordoCliente := Html(Grigio);
  // La striscia di avviso: giallo tenue sul fondo della skin, testo della skin.
  pnlAvviso.Color := Mescola(Sfondo, Giallo, 30);
  lblAvviso.Style.TextColor := Painter.DefaultContentTextColor;
end;

procedure TzTicketAssistenzaForm.CaricaHtml(const AHtml: string);
var
  Flusso: TStringStream;
begin
  Flusso := TStringStream.Create(AHtml, TEncoding.UTF8, False);
  try
    richAnteprima.Document.LoadDocument(Flusso, TdxRichEditDocumentFormat.Html, '');
  finally
    Flusso.Free;
  end;
end;

procedure TzTicketAssistenzaForm.MostraVoce;
var
  Voce: TVoceConversazione;
begin
  if not VoceSelezionata(Voce) then
    Exit;

  case Voce.Tipo of
    vtConversazione:
      begin
        lblAnteprima.Caption := 'Conversazione completa';
        pcAnteprima.ActivePage := tabTesto;
        CaricaHtml(MantisHtmlConversazione(FMessaggi, FColori));
        // Si legge dall'ultimo messaggio, che e' quello che conta adesso.
        richAnteprima.Document.CaretPosition := richAnteprima.Document.Range.&End;
      end;
    vtMessaggio:
      begin
        lblAnteprima.Caption := FMessaggi[Voce.IndiceMessaggio].Etichetta;
        pcAnteprima.ActivePage := tabTesto;
        CaricaHtml(MantisHtmlMessaggio(FMessaggi[Voce.IndiceMessaggio], FColori));
      end;
    vtAllegato:
      MostraAllegato(IdSelezionato, Voce.Allegato);
  end;
  AggiornaComandi;
end;

function TzTicketAssistenzaForm.FileAllegato(AId: Integer; const AAllegato: TMantisAllegato): string;
var
  Cartella: string;
  CursorePrecedente: TCursor;
begin
  // Un allegato di Mantis non cambia: una volta scaricato si riusa.
  Cartella := TPath.Combine(TPath.Combine(TPath.GetTempPath, 'zMantis'), AId.ToString);
  ForceDirectories(Cartella);
  Result := TPath.Combine(Cartella, Format('%d_%s', [AAllegato.Id, NomeFileSicuro(AAllegato.Nome)]));
  if FileExists(Result) then
    Exit;

  CursorePrecedente := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    try
      FApi.DownloadFile(AId, AAllegato.Id, Result);
    except
      // Un file scritto a meta' verrebbe riusato la volta dopo.
      if FileExists(Result) then
        System.SysUtils.DeleteFile(Result);
      raise;
    end;
  finally
    Screen.Cursor := CursorePrecedente;
  end;
end;

procedure TzTicketAssistenzaForm.MostraAllegato(AId: Integer; const AAllegato: TMantisAllegato);
var
  Percorso: string;
begin
  lblAnteprima.Caption := AAllegato.Nome + ' (' + MantisDimensioneTesto(AAllegato.Dimensione) + ')';

  if MantisAllegatoEseguibile(AAllegato.Nome) then
  begin
    pcAnteprima.ActivePage := tabTesto;
    CaricaHtml(MantisHtmlAvviso('Questo allegato e'' un programma o uno script: per sicurezza non si apre da qui. ' +
      'Se ti serve, salvalo con "Salva con nome" e fallo controllare prima di eseguirlo.', FColori));
    Exit;
  end;

  if MantisFormatoAllegato(AAllegato.Nome) = faAltro then
  begin
    pcAnteprima.ActivePage := tabTesto;
    CaricaHtml(MantisHtmlAvviso('Anteprima non disponibile per questo tipo di file: usa "Apri" per aprirlo con il programma predefinito, oppure "Salva con nome".', FColori));
    Exit;
  end;

  try
    Percorso := FileAllegato(AId, AAllegato);
  except
    on E: Exception do
    begin
      pcAnteprima.ActivePage := tabTesto;
      CaricaHtml(MantisHtmlAvviso('Scaricamento dell''allegato non riuscito: ' + E.Message, FColori));
      Exit;
    end;
  end;

  try
    case MantisFormatoAllegato(AAllegato.Nome) of
      faPdf:
        begin
          pdfAnteprima.LoadFromFile(Percorso);
          pcAnteprima.ActivePage := tabPdf;
        end;
      faImmagine:
        begin
          imgAnteprima.Picture.LoadFromFile(Percorso);
          pcAnteprima.ActivePage := tabImmagine;
        end;
      faMarkdown, faTesto:
        begin
          pcAnteprima.ActivePage := tabTesto;
          if TFile.GetSize(Percorso) > DimensioneMassimaAnteprimaTesto then
            CaricaHtml(MantisHtmlAvviso('File troppo grande per l''anteprima: usa "Apri" per aprirlo con il programma predefinito.', FColori))
          else
            if MantisFormatoAllegato(AAllegato.Nome) = faMarkdown then
              CaricaHtml(MantisHtmlMarkdown(MantisLeggiTesto(Percorso), FColori))
            else
              CaricaHtml(MantisHtmlTestoSemplice(MantisLeggiTesto(Percorso), FColori));
        end;
    end;
  except
    on E: Exception do
    begin
      pcAnteprima.ActivePage := tabTesto;
      CaricaHtml(MantisHtmlAvviso('Anteprima non riuscita: ' + E.Message, FColori));
    end;
  end;
end;

procedure TzTicketAssistenzaForm.RileggiSelezionato;
var
  Id: Integer;
  Indice: Integer;
begin
  Id := IdSelezionato;
  if Id = 0 then
    Exit;

  LeggiDaMantis(Id);
  Indice := IndiceLocale(Id);
  if (Indice >= 0) and (treeTicket.FocusedNode <> nil) then
    AggiornaRiga(treeTicket.FocusedNode, FLocali[Indice]);
  MostraDettaglio(Id);
end;

procedure TzTicketAssistenzaForm.AggiornaComandi;
var
  Issue: TMantisIssue;
  Voce: TVoceConversazione;
  ConDettaglio, PuoRispondere, SuAllegato: Boolean;
begin
  ConDettaglio := DettaglioSelezionato(Issue);
  PuoRispondere := ConDettaglio and not Issue.Chiuso;
  SuAllegato := ConDettaglio and VoceSelezionata(Voce) and (Voce.Tipo = vtAllegato);

  // Il reporter puo' chiudere solo un ticket gia' risolto dall'assistenza.
  btnChiudiTicket.Enabled := ConDettaglio and Issue.Risolto;
  btnBrowser.Enabled := (IdSelezionato > 0) and (FApi <> nil);
  btnApriAllegato.Enabled := SuAllegato and not MantisAllegatoEseguibile(Voce.Allegato.Nome);
  btnSalvaAllegato.Enabled := SuAllegato;
  btnEsportaPdf.Enabled := ConDettaglio and (Length(FMessaggi) > 0);

  memoRisposta.Enabled := PuoRispondere;
  btnAllegaFile.Enabled := PuoRispondere;
  btnSchermata.Enabled := PuoRispondere;
  btnRegistro.Enabled := PuoRispondere;
  btnTogliAllegato.Enabled := PuoRispondere and (lstAllegatiRisposta.ItemIndex >= 0);
  btnInvia.Enabled := PuoRispondere and ((Trim(memoRisposta.Text) <> '') or (FAllegatiRisposta.Count > 0));

  if not ConDettaglio then
    lblStatoRisposta.Caption := ''
  else
    if Issue.Chiuso then
      lblStatoRisposta.Caption := 'Segnalazione chiusa: non si possono aggiungere risposte.'
    else
      if FAllegatiRisposta.Count > 0 then
        lblStatoRisposta.Caption := Format('%d file da allegare alla risposta.', [FAllegatiRisposta.Count])
      else
        lblStatoRisposta.Caption := 'Puoi anche trascinare i file sulla finestra o incollarli con Ctrl+V.';
end;

procedure TzTicketAssistenzaForm.AggiungiAllegatiRisposta(const APercorsi: array of string);
var
  Percorso, Scartati: string;
begin
  Scartati := '';
  for Percorso in APercorsi do
  begin
    if not FileExists(Percorso) or (FAllegatiRisposta.IndexOf(Percorso) >= 0) then
      Continue;
    // Il limite si controlla subito: scoprirlo all'invio farebbe perdere
    // anche la risposta scritta, che Mantis rifiuta per intero.
    if (FLimiteFile > 0) and (TFile.GetSize(Percorso) > FLimiteFile) then
    begin
      Scartati := Scartati + sLineBreak + ExtractFileName(Percorso) + ' (' + MantisDimensioneTesto(TFile.GetSize(Percorso)) + ')';
      Continue;
    end;
    FAllegatiRisposta.Add(Percorso);
  end;
  if Scartati <> '' then
    ConfirmOk(Format('Questi file superano il limite di %s del servizio di assistenza e non sono stati aggiunti:%s',
      [MantisDimensioneTesto(FLimiteFile), Scartati]), mtWarning);
  AggiornaAllegatiRisposta;
end;

procedure TzTicketAssistenzaForm.AggiornaAllegatiRisposta;
var
  Percorso: string;
begin
  lstAllegatiRisposta.Items.BeginUpdate;
  try
    lstAllegatiRisposta.Items.Clear;
    for Percorso in FAllegatiRisposta do
      lstAllegatiRisposta.Items.Add(ExtractFileName(Percorso) + ' (' + MantisDimensioneTesto(TFile.GetSize(Percorso)) + ')');
  finally
    lstAllegatiRisposta.Items.EndUpdate;
  end;
  AggiornaComandi;
end;

procedure TzTicketAssistenzaForm.WMDropFiles(var Msg: TWMDropFiles);
var
  Quanti, Indice: Integer;
  Nome: array [0 .. MAX_PATH] of Char;
  Percorsi: TArray<string>;
begin
  try
    if not memoRisposta.Enabled then
      Exit;
    Percorsi := [];
    Quanti := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
    for Indice := 0 to Quanti - 1 do
      if DragQueryFile(Msg.Drop, Indice, Nome, Length(Nome)) > 0 then
        Percorsi := Percorsi + [string(Nome)];
    AggiungiAllegatiRisposta(Percorsi);
  finally
    DragFinish(Msg.Drop);
    Msg.Result := 0;
  end;
end;

procedure TzTicketAssistenzaForm.treeTicketSelectionChanged(Sender: TObject);
begin
  MostraDettaglio(IdSelezionato);
end;

procedure TzTicketAssistenzaForm.treeConversazioneSelectionChanged(Sender: TObject);
begin
  MostraVoce;
end;

procedure TzTicketAssistenzaForm.treeConversazioneDblClick(Sender: TObject);
begin
  if btnApriAllegato.Enabled then
    btnApriAllegatoClick(Sender);
end;

procedure TzTicketAssistenzaForm.memoRispostaPropertiesChange(Sender: TObject);
begin
  AggiornaComandi;
end;

procedure TzTicketAssistenzaForm.lstAllegatiRispostaClick(Sender: TObject);
begin
  AggiornaComandi;
end;

procedure TzTicketAssistenzaForm.btnAggiornaClick(Sender: TObject);
begin
  CaricaElenco;
end;

procedure TzTicketAssistenzaForm.btnAllegaFileClick(Sender: TObject);
begin
  if dlgApri.Execute then
    AggiungiAllegatiRisposta(dlgApri.Files.ToStringArray);
end;

procedure TzTicketAssistenzaForm.btnTogliAllegatoClick(Sender: TObject);
begin
  if (lstAllegatiRisposta.ItemIndex < 0) or (lstAllegatiRisposta.ItemIndex >= FAllegatiRisposta.Count) then
    Exit;
  FAllegatiRisposta.Delete(lstAllegatiRisposta.ItemIndex);
  AggiornaAllegatiRisposta;
end;

procedure TzTicketAssistenzaForm.btnInviaClick(Sender: TObject);
var
  Id: Integer;
  Testo: string;
  CursorePrecedente: TCursor;
  Issue: TMantisIssue;
  EraRisolto: Boolean;
begin
  Id := IdSelezionato;
  if (Id = 0) or not btnInvia.Enabled then
    Exit;

  Testo := Trim(memoRisposta.Text);
  if Testo = '' then
    Testo := 'Invio i file allegati.';
  EraRisolto := DettaglioSelezionato(Issue) and Issue.Risolto;

  CursorePrecedente := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    try
      // La nota esce a nome dell'utente di servizio: il prefisso dice chi
      // l'ha scritta davvero, ed e' anche quello che la distingue dalle
      // risposte dell'assistenza. I file restano legati a questa nota.
      FApi.AddNoteConAllegati(Id, MantisPrefissoCliente(FStore.NomeUtente) + Testo, FAllegatiRisposta.ToStringArray);
    except
      on E: Exception do
      begin
        ConfirmOk('Invio della risposta non riuscito:' + sLineBreak + E.Message, mtError);
        Exit;
      end;
    end;
  finally
    Screen.Cursor := CursorePrecedente;
  end;

  memoRisposta.Clear;
  FAllegatiRisposta.Clear;
  AggiornaAllegatiRisposta;
  ElencoBozze.Remove(Id);
  RileggiSelezionato;

  // Il reporter non puo' riaprire: lo dice all'utente, che altrimenti
  // vedrebbe il ticket restare "Risolta" e penserebbe di non essere letto.
  if EraRisolto then
    ConfirmOk('Risposta inviata. La segnalazione risulta ancora risolta: l''assistenza riceve il tuo messaggio ' +
      'e la riapre se serve.', mtInformation);
end;

procedure TzTicketAssistenzaForm.memoRispostaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Ctrl+V con file copiati o un'immagine negli appunti: diventano allegati
  // invece di finire (o non finire) nel testo.
  if (Key = Ord('V')) and (Shift = [ssCtrl]) and MantisAppuntiConAllegati then
  begin
    Key := 0;
    try
      AggiungiAllegatiRisposta(MantisAllegatiDagliAppunti);
    except
      on E: Exception do
        ConfirmOk('Lettura degli appunti non riuscita:' + sLineBreak + E.Message, mtWarning);
    end;
  end;
end;

procedure TzTicketAssistenzaForm.btnSchermataClick(Sender: TObject);
begin
  try
    AggiungiAllegatiRisposta([MantisCatturaSchermata(Handle)]);
  except
    on E: Exception do
      ConfirmOk('Schermata non riuscita:' + sLineBreak + E.Message, mtWarning);
  end;
end;

procedure TzTicketAssistenzaForm.AggiornaRegistro;
var
  Sessione: TzSessioneLog;
begin
  Sessione := TzSessioneLog.Istanza;
  btnRegistro.Visible := Sessione.Disponibile;
  if Sessione.Attiva then
  begin
    btnRegistro.Caption := 'Allega registro';
    btnRegistro.Hint := 'Chiude la registrazione in corso e la allega alla risposta';
  end
  else
  begin
    btnRegistro.Caption := 'Registra';
    btnRegistro.Hint := 'Avvia la registrazione di cio'' che fa il programma, da allegare dopo aver riprodotto il problema';
  end;
end;

procedure TzTicketAssistenzaForm.btnRegistroClick(Sender: TObject);
var
  Sessione: TzSessioneLog;
  Log, Sil, Csv, Archivio: string;
begin
  Sessione := TzSessioneLog.Istanza;
  if not Sessione.Attiva then
  begin
    // La form e' modale: per riprodurre il problema va chiusa. La risposta
    // scritta resta in bozza e si ritrova riaprendola.
    if not ConfirmYesNo('La registrazione annota cosa fa il programma e aiuta l''assistenza a capire il problema.' +
      sLineBreak + sLineBreak + 'Avvio la registrazione? Poi chiudi questa finestra, ripeti le operazioni che danno ' +
      'il problema, riapri "Le mie segnalazioni" e premi "Allega registro": la risposta che hai scritto resta qui.',
      mtConfirmation) then
      Exit;
    Sessione.Avvia(ocMenu);
    AggiornaRegistro;
    Exit;
  end;

  // I percorsi si leggono prima di Annulla, che chiude la sessione.
  Log := Sessione.FileLog;
  Sil := Sessione.FileSil;
  Csv := Sessione.FileCsv;
  Archivio := TPath.Combine(MantisCartellaTemporanea('registri'), 'Registro ' + Sessione.Identificativo + '.zip');
  Sessione.Annulla;
  try
    MantisArchivia(Archivio, [Log, Sil, Csv]);
    AggiungiAllegatiRisposta([Archivio]);
  except
    on E: Exception do
      ConfirmOk('Preparazione del registro non riuscita:' + sLineBreak + E.Message, mtWarning);
  end;
  AggiornaRegistro;
end;

procedure TzTicketAssistenzaForm.txtCercaPropertiesChange(Sender: TObject);
begin
  ApplicaFiltro;
end;

procedure TzTicketAssistenzaForm.chkMostraChiusePropertiesChange(Sender: TObject);
begin
  ApplicaFiltro;
end;

procedure TzTicketAssistenzaForm.btnNuovaRichiestaClick(Sender: TObject);
var
  Richiesta: TMantisNuovaRichiesta;
  Segnalazione: TMantisReport;
  Descrizione: TStringList;
  NonRiusciti: TArray<string>;
  Id: Integer;
  Prefisso: string;
  CursorePrecedente: TCursor;
begin
  if not MantisChiediNuovaRichiesta(Immagini, idxAllega, idxSchermata, idxTogli, idxInvia, FLimiteFile, Richiesta) then
    Exit;

  // Stesso progetto, reporter e forma dei ticket aperti dagli errori
  // (TzExceptionManager.InviaMantis), cosi' l'assistenza li tratta allo
  // stesso modo e la form li riconosce.
  Segnalazione := Default (TMantisReport);
  Segnalazione.ProjectName := ClientName;
  if Trim(Segnalazione.ProjectName) = '' then
    Segnalazione.ProjectName := DbName;
  Segnalazione.ReporterUser := UserName;
  Segnalazione.ReporterEmail := UserEmail;
  Segnalazione.ReporterRealName := UserName;
  Prefisso := '[' + ModuleName;
  if Trim(UserName) <> '' then
    Prefisso := Prefisso + ' - ' + Trim(UserName);
  Prefisso := Prefisso + '] ';
  Segnalazione.Summary := Copy(Prefisso + Richiesta.Oggetto, 1, LunghezzaMassimaOggetto);
  Descrizione := TStringList.Create;
  try
    Descrizione.Add(Richiesta.Descrizione);
    Descrizione.Add('');
    Descrizione.Add(''.PadLeft(60, '_'));
    Descrizione.Add('');
    Descrizione.AddPair('DB', DbName);
    Descrizione.AddPair('Utente', UserName);
    Descrizione.AddPair('Email utente', UserEmail);
    Descrizione.AddPair('Utente sistema', SysUserName);
    Descrizione.AddPair('Computer', ComputerName);
    Descrizione.AddPair('Modulo', ModuleName);
    Descrizione.AddPair('Versione', VersionInfo);
    Descrizione.AddPair('Data', DateTimeToStr(Now));
    Descrizione.AddPair('Origine', 'Nuova richiesta da "Le mie segnalazioni"');
    Segnalazione.Description := Descrizione.Text;
  finally
    Descrizione.Free;
  end;
  Segnalazione.Attachments := Richiesta.Allegati;

  CursorePrecedente := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    try
      Id := SegnalaSuMantis(FParametri, Segnalazione, NonRiusciti);
    except
      on E: Exception do
      begin
        ConfirmOk('Invio della richiesta non riuscito:' + sLineBreak + E.Message, mtError);
        Exit;
      end;
    end;
  finally
    Screen.Cursor := CursorePrecedente;
  end;

  // Senza registrazione la richiesta esiste su Mantis ma non comparirebbe
  // qui: lo si dice, con il numero, invece di tacere.
  try
    FStore.Registra(Id, Segnalazione.Summary);
  except
    on E: Exception do
      ConfirmOk(Format('La richiesta n. %d e'' stata inviata, ma non e'' stato possibile registrarla in questo ' +
        'programma:%s%s', [Id, sLineBreak, E.Message]), mtWarning);
  end;
  if Length(NonRiusciti) > 0 then
    ConfirmOk(Format('La richiesta n. %d e'' stata inviata, ma questi allegati sono stati rifiutati:%s%s',
      [Id, sLineBreak, string.Join(sLineBreak, NonRiusciti)]), mtWarning);

  CaricaElenco;
  SelezionaTicket(Id);
end;

procedure TzTicketAssistenzaForm.btnEsportaPdfClick(Sender: TObject);
var
  Issue: TMantisIssue;
  Copia: TdxRichEditControl;
  Stampante: TdxComponentPrinter;
  Collegamento: TBasedxReportLink;
  Flusso: TStringStream;
  Html, Dettaglio: string;
begin
  if not DettaglioSelezionato(Issue) or (Length(FMessaggi) = 0) then
    Exit;

  dlgSalva.Filter := 'Documenti PDF (*.pdf)|*.pdf';
  dlgSalva.Title := 'Esporta la conversazione in PDF';
  dlgSalva.DefaultExt := 'pdf';
  dlgSalva.FileName := Format('Segnalazione %d.pdf', [Issue.Id]);
  if not dlgSalva.Execute then
    Exit;

  // Sempre a colori chiari: il PDF si stampa e si archivia, la skin scura
  // della postazione non deve finirci dentro.
  Dettaglio := 'Stato: ' + MantisStatoEtichetta(Issue.Stato) + ' - aperta il ' + DataOraTesto(Issue.CreatoIl) +
    ' - esportata il ' + DataOraTesto(Now);
  Html := MantisHtmlConversazioneConTitolo(Format('Segnalazione n. %d - %s', [Issue.Id,
    MantisOggettoSenzaPrefisso(Issue.Oggetto)]), Dettaglio, FMessaggi, TMantisColoriHtml.Chiari);

  // Una copia nascosta del RichEdit, perche' quello a video segue la skin;
  // e il component printer creato ora, non nel .dfm: AddLink interroga la
  // stampante predefinita, che con le stampanti di rete costa secondi.
  Copia := TdxRichEditControl.Create(nil);
  Stampante := TdxComponentPrinter.Create(nil);
  try
    Copia.Visible := False;
    Copia.Parent := Self;
    Copia.SetBounds(0, 0, 800, 600);
    Copia.Options.Import.Html.AsyncImageLoading := False;
    Flusso := TStringStream.Create(Html, TEncoding.UTF8, False);
    try
      Copia.Document.LoadDocument(Flusso, TdxRichEditDocumentFormat.Html, '');
    finally
      Flusso.Free;
    end;
    // Senza la clessidra del printer: il suo contatore e' globale e puo'
    // restare acceso su tutta l'applicazione.
    Stampante.Options := Stampante.Options - [cpoShowHourGlass];
    Collegamento := Stampante.AddLink(Copia);
    try
      Collegamento.ExportToPDF(dlgSalva.FileName, False);
    except
      on E: Exception do
      begin
        ConfirmOk('Esportazione in PDF non riuscita:' + sLineBreak + E.Message, mtError);
        Exit;
      end;
    end;
  finally
    Stampante.Free;
    Copia.Free;
  end;

  if ConfirmYesNo('Conversazione esportata in:' + sLineBreak + dlgSalva.FileName + sLineBreak + sLineBreak + 'Aprirla adesso?',
    mtConfirmation) then
    ShellExecute(0, 'open', PChar(dlgSalva.FileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TzTicketAssistenzaForm.btnApriAllegatoClick(Sender: TObject);
var
  Voce: TVoceConversazione;
  Percorso: string;
begin
  if not VoceSelezionata(Voce) or (Voce.Tipo <> vtAllegato) then
    Exit;
  // Difesa anche qui, non solo sul pulsante: il doppio clic arriva lo stesso.
  if MantisAllegatoEseguibile(Voce.Allegato.Nome) then
    Exit;
  try
    Percorso := FileAllegato(IdSelezionato, Voce.Allegato);
  except
    on E: Exception do
    begin
      ConfirmOk('Scaricamento dell''allegato non riuscito:' + sLineBreak + E.Message, mtError);
      Exit;
    end;
  end;
  ShellExecute(0, 'open', PChar(Percorso), nil, nil, SW_SHOWNORMAL);
end;

procedure TzTicketAssistenzaForm.btnSalvaAllegatoClick(Sender: TObject);
var
  Voce: TVoceConversazione;
  Percorso: string;
begin
  if not VoceSelezionata(Voce) or (Voce.Tipo <> vtAllegato) then
    Exit;
  dlgSalva.Filter := 'Tutti i file (*.*)|*.*';
  dlgSalva.Title := 'Salva l''allegato';
  dlgSalva.FileName := NomeFileSicuro(Voce.Allegato.Nome);
  dlgSalva.DefaultExt := ExtractFileExt(Voce.Allegato.Nome).TrimLeft(['.']);
  if not dlgSalva.Execute then
    Exit;
  try
    Percorso := FileAllegato(IdSelezionato, Voce.Allegato);
    TFile.Copy(Percorso, dlgSalva.FileName, True);
  except
    on E: Exception do
      ConfirmOk('Salvataggio dell''allegato non riuscito:' + sLineBreak + E.Message, mtError);
  end;
end;

procedure TzTicketAssistenzaForm.btnChiudiTicketClick(Sender: TObject);
var
  Id: Integer;
  Issue: TMantisIssue;
  CursorePrecedente: TCursor;
begin
  Id := IdSelezionato;
  if not DettaglioSelezionato(Issue) or not Issue.Risolto then
    Exit;

  if not ConfirmYesNo(Format('Confermi che la segnalazione n. %d e'' risolta?' + sLineBreak + 'Verra'' chiusa e non sara'' piu'' possibile rispondere.', [Id]), mtConfirmation) then
    Exit;

  CursorePrecedente := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    try
      FApi.CloseIssue(Id);
    except
      on E: Exception do
      begin
        ConfirmOk('Chiusura non riuscita:' + sLineBreak + E.Message, mtError);
        Exit;
      end;
    end;
  finally
    Screen.Cursor := CursorePrecedente;
  end;

  RileggiSelezionato;
end;

procedure TzTicketAssistenzaForm.btnBrowserClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := IdSelezionato;
  if (Id = 0) or (FApi = nil) then
    Exit;
  ShellExecute(0, 'open', PChar(FApi.ViewUrl(Id)), nil, nil, SW_SHOWNORMAL);
end;

procedure TzTicketAssistenzaForm.btnEsciClick(Sender: TObject);
begin
  Close;
end;

initialization

finalization

FreeAndNil(Bozze);

end.
