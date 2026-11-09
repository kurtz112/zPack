unit zOffice.Reports.ActionsBarHelper;

// TzDocumentActionsBarHelper: presenter delle azioni documentali.
//
// NON costruisce piu' bar ne' bottoni. Ogni viewer (Word, Pdf, Excel,
// FastReport) porta a mano nel proprio DFM il gruppo "Documento" (una TdxBar),
// i TdxBarLargeButton e le TAction con la loro ImageIndex. L'helper fornisce
// solo i metodi da richiamare:
//
// - nell'OnUpdate della TAction  -> stabilisce Visible/Enabled/Caption/Hint
// - nell'OnExecute della TAction -> esegue il lavoro
//
// cosi' la logica di presentazione (il mapping stato -> aspetto del comando)
// resta scritta una volta sola, condivisa dai quattro viewer, mentre i
// componenti visivi restano nel DFM sotto il controllo di chi progetta la form.
//
// Le cinque azioni documentali (Firma/Protocolla/Conserva/InviaPec/InviaMail)
// condividono un'unica coppia di handler: la TAction porta nel Tag il valore
// Ord(TzAzioneDocumento) e l'handler lo rilegge. I due comandi di supporto
// ("Aggiorna stato" e "Versioni") hanno una coppia di metodi dedicata.
//
// CONFERMA: prima di eseguire una delle cinque azioni documentali l'helper
// chiede conferma all'operatore con ConfirmOkCancel (zMsg). La domanda sta
// qui, e non nei singoli viewer, perche' e' l'unico punto di passaggio comune
// a Word, Excel, FastReport e MultiViewer. Si puo' spegnere (per esempio in
// un flusso automatico) con RichiediConferma := False. "Vedi estremi",
// "Aggiorna stato" e "Versioni" sono di sola lettura e non chiedono nulla.
//
// Mapping stato -> aspetto (analisi_controlli_base_e_azioni_preview.md §3.2):
// adsNonDisponibile  comando nascosto (Visible := False)
// adsBloccata        visibile, disabilitato, Hint = motivo del blocco
// adsDisponibile     attivo, Caption dell'azione
// adsInCorso         disabilitato, Hint = motivo; comando "Aggiorna stato" visibile
// adsCompletata      azione non ripetibile: attivo, Caption "Vedi estremi - ..."
// azione ripetibile: attivo, Caption normale, Hint = ultimo esito
//
// Comandi di supporto:
// "Aggiorna stato"   visibile se almeno un'azione e' in corso; interroga il
// fornitore per tutte le azioni in attesa di esito esterno
// "Versioni"         visibile appena il documento e' persistito; mostra la
// catena OBJ_FILES_VERSIONI (delegato al chiamante)

interface

uses
  System.SysUtils,
  System.Classes,
  System.Actions,
  System.UITypes,
  Vcl.ActnList,
  zMsg,
  zOffice.Reports.Controller;

const
  CAPTION_VEDI_ESTREMI = 'Vedi estremi';
  CAPTION_AGGIORNA_STATO = 'Aggiorna stato';
  CAPTION_VERSIONI = 'Versioni';

  // Nomi convenzionali che le TAction devono avere nel DFM del viewer: e' su
  // questi che InizializzaAzioniDocumento le ritrova nell'ActionList. Le 5 azioni
  // documentali sono indicizzate per TzAzioneDocumento.
  NomeAzioneDocumento: array [TzAzioneDocumento] of string = ('actDocFirma', 'actDocProtocolla', 'actDocConserva', 'actDocInviaPec', 'actDocInviaMail');
  NOME_ACTION_AGGIORNA_STATO = 'actDocAggiornaStato';
  NOME_ACTION_VERSIONI = 'actDocVersioni';

  NOME_ACTION_GENERA_ALLEGATO = 'actDocGeneraAllegato';
  CAPTION_GENERA_ALLEGATO = 'Genera allegato';

  // Domanda posta all'operatore prima di eseguire ciascuna azione documentale
  // (vedi ConfermaAzioneDocumento).
  DomandaConfermaAzioneDocumento: array [TzAzioneDocumento] of string = ('Procedere con la firma del documento?', 'Procedere con la protocollazione del documento?', 'Procedere con l''invio in conservazione del documento?',
    'Procedere con l''invio del documento tramite PEC?', 'Procedere con l''invio del documento tramite mail?');

type
  // Errore di configurazione del viewer (azione attesa mancante nell'ActionList).
  EzDocumentActionsConfig = class(Exception);

  // Fornitori di dato passati dal manager: l'helper non conosce il modello,
  // interroga queste funzioni ad ogni OnUpdate (cosi' un'azione appena
  // completata sblocca la successiva nella stessa sessione, senza ricalcoli
  // manuali: e' il framework delle Action a richiamare l'OnUpdate).
  TzStatoAzioneFunc = TFunc<TzAzioneDocumento, TzAzioneDocumentoStato>;
  TzMotivoAzioneFunc = TFunc<TzAzioneDocumento, string>;
  TzEstremiAzioneFunc = TFunc<TzAzioneDocumento, string>;
  TzDocumentoPersistitoFunc = TFunc<Boolean>;

  // TComponent: creato con Owner = form del viewer, si libera con lei.
  TzDocumentActionsBarHelper = class(TComponent)
  private
    // fornitori di dato (dal manager)
    FStatoFunc: TzStatoAzioneFunc;
    FMotivoFunc: TzMotivoAzioneFunc;
    FEstremiFunc: TzEstremiAzioneFunc;
    FDocumentoPersistitoFunc: TzDocumentoPersistitoFunc;

    // callback di lavoro (dal manager)
    FOnEsegui: TProc<TzAzioneDocumento>;
    FOnVediEstremi: TProc<TzAzioneDocumento>;
    FOnAggiornaStato: TProc<TzAzioneDocumento>;
    FOnVediVersioni: TProc;

    function Stato(Azione: TzAzioneDocumento): TzAzioneDocumentoStato;
    function Motivo(Azione: TzAzioneDocumento): string;
    function Estremi(Azione: TzAzioneDocumento): string;
    function DocumentoPersistito: Boolean;
    function EsisteAzioneInCorso: Boolean;
    function TrovaAzione(ActionList: TCustomActionList; const Nome: string): TCustomAction;
  private
    FOnGeneraAllegato: TProc;
    FPuoGenerareFunc: TFunc<Boolean>;
    function TrovaAzioneOpzionale(ActionList: TCustomActionList; const Nome: string): TCustomAction;
  private
    FRichiediConferma: Boolean;
    // chiede conferma all'operatore (ConfirmOkCancel di zMsg); vero = procedere
    function ConfermaAzioneDocumento(Azione: TzAzioneDocumento): Boolean;
    // conferma e, se accordata, richiama FOnEsegui
    procedure EseguiAzioneConfermata(Azione: TzAzioneDocumento);
  public
    // StatoFunc e' l'unico fornitore obbligatorio; gli altri possono essere nil.
    constructor Create(AOwner: TComponent; StatoFunc: TzStatoAzioneFunc; MotivoFunc: TzMotivoAzioneFunc; EstremiFunc: TzEstremiAzioneFunc; DocumentoPersistitoFunc: TzDocumentoPersistitoFunc); reintroduce;

    // ---- inizializzazione (una volta, alla creazione dell'helper) ----

    // Ritrova nell'ActionList del viewer (per nome convenzionale, vedi
    // NomeAzioneDocumento / NOME_ACTION_*) le 7 azioni documentali e ne imposta
    // il Tag (Ord(Azione) per le 5 documentali) e la caption iniziale. Cosi'
    // il Tag non sta piu' nel DFM: unica fonte di verita' qui. Solleva
    // EzDocumentActionsConfig se un'azione attesa non c'e'.
    procedure InizializzaAzioniDocumento(ActionList: TCustomActionList);

    // ---- da richiamare nell'OnUpdate delle TAction ----

    // Cinque azioni documentali: Action.Tag deve valere Ord(Azione).
    procedure AggiornaAzioneDocumento(Azione: TzAzioneDocumento; Action: TCustomAction);
    // Comando "Aggiorna stato".
    procedure AggiornaComandoAggiornaStato(Action: TCustomAction);
    // Comando "Versioni".
    procedure AggiornaComandoVersioni(Action: TCustomAction);

    // Comando "Genera allegato" (facoltativo: i viewer che non lo espongono
    // continuano a funzionare senza modifiche).
    procedure AggiornaComandoGeneraAllegato(Action: TCustomAction);
    procedure EseguiComandoGeneraAllegato;
    // vero se il comando e' utilizzabile adesso (usato anche dal bivio sul
    // pulsante PDF del viewer)
    function GeneraAllegatoDisponibile: Boolean;

    // ---- da richiamare nell'OnExecute delle TAction ----

    // Cinque azioni documentali: esegue o mostra gli estremi secondo lo stato
    // corrente (rivalutato adesso, non fidandosi dell'ultimo OnUpdate).
    // L'esecuzione passa prima dalla conferma dell'operatore (RichiediConferma).
    procedure EseguiAzioneDocumento(Azione: TzAzioneDocumento);
    // Comando "Aggiorna stato": interroga il fornitore per ogni azione in corso.
    procedure EseguiComandoAggiornaStato;
    // Comando "Versioni".
    procedure EseguiComandoVersioni;

    // callback di lavoro, assegnate dal manager
    property OnEsegui: TProc<TzAzioneDocumento> read FOnEsegui write FOnEsegui;
    property OnVediEstremi: TProc<TzAzioneDocumento> read FOnVediEstremi write FOnVediEstremi;
    property OnAggiornaStato: TProc<TzAzioneDocumento> read FOnAggiornaStato write FOnAggiornaStato;
    property OnVediVersioni: TProc read FOnVediVersioni write FOnVediVersioni;

    property OnGeneraAllegato: TProc read FOnGeneraAllegato write FOnGeneraAllegato;
    property PuoGenerareAllegatoFunc: TFunc<Boolean> read FPuoGenerareFunc write FPuoGenerareFunc;

    // True (predefinito): prima di eseguire Firma/Protocolla/Conserva/InviaPec/
    // InviaMail viene chiesta conferma con ConfirmOkCancel. False per i flussi
    // che hanno gia' raccolto il consenso a monte.
    property RichiediConferma: Boolean read FRichiediConferma write FRichiediConferma;
  end;

implementation

{ TzDocumentActionsBarHelper }

constructor TzDocumentActionsBarHelper.Create(AOwner: TComponent; StatoFunc: TzStatoAzioneFunc; MotivoFunc: TzMotivoAzioneFunc; EstremiFunc: TzEstremiAzioneFunc; DocumentoPersistitoFunc: TzDocumentoPersistitoFunc);
begin
  inherited Create(AOwner);
  Assert(assigned(StatoFunc));

  FStatoFunc := StatoFunc;
  FMotivoFunc := MotivoFunc;
  FEstremiFunc := EstremiFunc;
  FDocumentoPersistitoFunc := DocumentoPersistitoFunc;
  FRichiediConferma := True;
end;

// ---------------------------------------------------------------------------
// Inizializzazione
// ---------------------------------------------------------------------------

function TzDocumentActionsBarHelper.TrovaAzione(ActionList: TCustomActionList; const Nome: string): TCustomAction;
var
  indice: Integer;
  Azione: TContainedAction;
begin
  Assert(assigned(ActionList));

  for indice := 0 to ActionList.ActionCount - 1 do
  begin
    Azione := ActionList.Actions[indice];
    if SameText(Azione.Name, Nome) then
    begin
      if not(Azione is TCustomAction) then
        raise EzDocumentActionsConfig.CreateFmt('L''azione "%s" non e'' una TCustomAction (Caption/Tag non impostabili)', [Nome]);
      exit(TCustomAction(Azione));
    end;
  end;

  raise EzDocumentActionsConfig.CreateFmt('Azione documentale "%s" non trovata nell''ActionList del viewer', [Nome]);
end;

procedure TzDocumentActionsBarHelper.InizializzaAzioniDocumento(ActionList: TCustomActionList);
var
  Azione: TzAzioneDocumento;
  Action: TCustomAction;
begin
  Assert(assigned(ActionList));

  // 5 azioni documentali: il Tag porta Ord(azione) (usato dagli handler
  // condivisi) e la caption iniziale e' quella descrittiva
  for Azione := Low(TzAzioneDocumento) to High(TzAzioneDocumento) do
  begin
    Action := TrovaAzione(ActionList, NomeAzioneDocumento[Azione]);
    Action.Tag := Ord(Azione);
    Action.Caption := DescrizioneAzioneDocumento(Azione);
    Action.Hint := '';
  end;

  // comandi di supporto: solo presenza + caption iniziale (nessun Tag)
  TrovaAzione(ActionList, NOME_ACTION_AGGIORNA_STATO).Caption := CAPTION_AGGIORNA_STATO;
  TrovaAzione(ActionList, NOME_ACTION_VERSIONI).Caption := CAPTION_VERSIONI;
  TrovaAzione(ActionList, NOME_ACTION_GENERA_ALLEGATO).Caption := CAPTION_GENERA_ALLEGATO;
end;

function TzDocumentActionsBarHelper.Stato(Azione: TzAzioneDocumento): TzAzioneDocumentoStato;
begin
  result := FStatoFunc(Azione);
end;

function TzDocumentActionsBarHelper.Motivo(Azione: TzAzioneDocumento): string;
begin
  if assigned(FMotivoFunc) then
    result := FMotivoFunc(Azione)
  else
    result := '';
end;

function TzDocumentActionsBarHelper.Estremi(Azione: TzAzioneDocumento): string;
begin
  if assigned(FEstremiFunc) then
    result := FEstremiFunc(Azione)
  else
    result := '';
end;

function TzDocumentActionsBarHelper.DocumentoPersistito: Boolean;
begin
  result := assigned(FDocumentoPersistitoFunc) and FDocumentoPersistitoFunc();
end;

function TzDocumentActionsBarHelper.EsisteAzioneInCorso: Boolean;
var
  Azione: TzAzioneDocumento;
begin
  result := False;
  for Azione := Low(TzAzioneDocumento) to High(TzAzioneDocumento) do
    if Stato(Azione) = adsInCorso then
      exit(True);
end;

// ---------------------------------------------------------------------------
// OnUpdate
// ---------------------------------------------------------------------------

procedure TzDocumentActionsBarHelper.AggiornaAzioneDocumento(Azione: TzAzioneDocumento; Action: TCustomAction);
var
  statoAzione: TzAzioneDocumentoStato;
  estremiAzione: string;
begin
  Assert(assigned(Action));

  statoAzione := Stato(Azione);

  case statoAzione of
    adsNonDisponibile:
      Action.Visible := False;

    adsBloccata:
      begin
        Action.Visible := True;
        Action.Enabled := False;
        Action.Caption := DescrizioneAzioneDocumento(Azione);
        Action.Hint := Motivo(Azione);
      end;

    adsDisponibile:
      begin
        Action.Visible := True;
        Action.Enabled := True;
        Action.Caption := DescrizioneAzioneDocumento(Azione);
        Action.Hint := '';
      end;

    adsInCorso:
      begin
        Action.Visible := True;
        Action.Enabled := False;
        Action.Caption := DescrizioneAzioneDocumento(Azione);
        Action.Hint := Motivo(Azione);
      end;

    adsCompletata:
      begin
        Action.Visible := True;
        Action.Enabled := True;
        estremiAzione := Estremi(Azione);
        if AzioneRipetibile(Azione) then
        begin
          // resta eseguibile: mostra l'ultimo esito nell'hint
          Action.Caption := DescrizioneAzioneDocumento(Azione);
          if estremiAzione.IsEmpty then
            Action.Hint := ''
          else
            Action.Hint := 'Ultimo esito: ' + estremiAzione;
        end
        else
        begin
          Action.Caption := CAPTION_VEDI_ESTREMI + ' - ' + DescrizioneAzioneDocumento(Azione);
          Action.Hint := estremiAzione;
        end;
      end;
  end;
end;

procedure TzDocumentActionsBarHelper.AggiornaComandoAggiornaStato(Action: TCustomAction);
begin
  Assert(assigned(Action));
  // visibile solo se c'e' almeno un'azione in attesa di esito esterno
  Action.Visible := EsisteAzioneInCorso;
end;

procedure TzDocumentActionsBarHelper.AggiornaComandoVersioni(Action: TCustomAction);
begin
  Assert(assigned(Action));
  // visibile solo se c'e' un gestore (la finestra delle versioni arriva con
  // l'integrazione applicativa) e il documento e' gia' persistito
  Action.Visible := DocumentoPersistito and assigned(FOnVediVersioni);
end;

// ---------------------------------------------------------------------------
// OnExecute
// ---------------------------------------------------------------------------

function TzDocumentActionsBarHelper.ConfermaAzioneDocumento(Azione: TzAzioneDocumento): Boolean;
var
  domanda: string;
  estremiAzione: string;
begin
  if not FRichiediConferma then
    exit(True);

  domanda := DomandaConfermaAzioneDocumento[Azione];

  // azione ripetibile gia' eseguita: l'operatore deve sapere che la ripete
  if Stato(Azione) = adsCompletata then
  begin
    domanda := domanda + sLineBreak + sLineBreak + 'Attenzione: l''azione "' + DescrizioneAzioneDocumento(Azione) + '" risulta gia'' eseguita per questo documento.';
    estremiAzione := Estremi(Azione);
    if not estremiAzione.IsEmpty then
      domanda := domanda + sLineBreak + 'Ultimo esito: ' + estremiAzione;
  end;

  result := ConfirmOkCancel(domanda);
end;

procedure TzDocumentActionsBarHelper.EseguiAzioneConfermata(Azione: TzAzioneDocumento);
begin
  if not assigned(FOnEsegui) then
    exit;

  if not ConfermaAzioneDocumento(Azione) then
    exit; // annullato dall'operatore

  FOnEsegui(Azione);
end;

procedure TzDocumentActionsBarHelper.EseguiAzioneDocumento(Azione: TzAzioneDocumento);
begin
  // rivaluta lo stato adesso: il disable a video non e' una barriera
  case Stato(Azione) of
    adsDisponibile:
      EseguiAzioneConfermata(Azione);

    adsCompletata:
      if AzioneRipetibile(Azione) then
        EseguiAzioneConfermata(Azione)
      else
        if assigned(FOnVediEstremi) then
          FOnVediEstremi(Azione);
  end;
end;

procedure TzDocumentActionsBarHelper.EseguiComandoAggiornaStato;
var
  Azione: TzAzioneDocumento;
begin
  if not assigned(FOnAggiornaStato) then
    exit;

  // interroga tutte le azioni in attesa di esito esterno
  for Azione := Low(TzAzioneDocumento) to High(TzAzioneDocumento) do
    if Stato(Azione) = adsInCorso then
      FOnAggiornaStato(Azione);
end;

procedure TzDocumentActionsBarHelper.EseguiComandoVersioni;
begin
  if assigned(FOnVediVersioni) then
    FOnVediVersioni;
end;

// gemella di TrovaAzione ma TOLLERANTE: ritorna nil se l'azione non c'e'.
// Serve per i comandi facoltativi: i viewer non ancora aggiornati non devono
// sollevare EzDocumentActionsConfig.
function TzDocumentActionsBarHelper.TrovaAzioneOpzionale(ActionList: TCustomActionList; const Nome: string): TCustomAction;
var
  indice: Integer;
  Azione: TContainedAction;
begin
  result := nil;
  if not assigned(ActionList) then
    exit;

  for indice := 0 to ActionList.ActionCount - 1 do
  begin
    Azione := ActionList.Actions[indice];
    if SameText(Azione.Name, Nome) then
      if Azione is TCustomAction then
        exit(TCustomAction(Azione));
  end;
end;

function TzDocumentActionsBarHelper.GeneraAllegatoDisponibile: Boolean;
begin
  result := assigned(FOnGeneraAllegato);
  if result then
    if assigned(FPuoGenerareFunc) then
      result := FPuoGenerareFunc()
    else
      result := not DocumentoPersistito;
end;

procedure TzDocumentActionsBarHelper.AggiornaComandoGeneraAllegato(Action: TCustomAction);
begin
  if not assigned(Action) then
    exit;

  Action.Visible := assigned(FOnGeneraAllegato);
  Action.Enabled := GeneraAllegatoDisponibile;

  if Action.Enabled then
    Action.Hint := ''
  else
    Action.Hint := 'Allegato gia'' generato per questo documento';
end;

procedure TzDocumentActionsBarHelper.EseguiComandoGeneraAllegato;
begin
  if assigned(FOnGeneraAllegato) then
    FOnGeneraAllegato();
end;

end.
