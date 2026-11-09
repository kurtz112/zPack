// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-18
// ---------------------------------------------------------------------------

unit zSecurity.FasceOrarie;

// Controllo della fascia oraria di accesso durante la sessione di lavoro.
//
// Subito dopo il login la classe chiede al server se l'utente e' dentro la sua
// fascia e fra quanti secondi il verdetto puo' cambiare. Conta quei secondi e,
// quando scadono, rifa' la stessa domanda: la risposta porta con se' il nuovo
// intervallo e il giro ricomincia.
//
// La domanda si fa qui e non dentro USR_LOGIN di proposito: la firma del login
// resta quella che e' sempre stata, e nessuno dei suoi chiamanti - compresi i
// wrapper generati e le applicazioni web - va ritoccato. Il prezzo e' una
// chiamata in piu' all'avvio, che e' nulla rispetto al rischio di toccare la
// procedura da cui passa ogni accesso.
//
// Perche' non un'interrogazione a intervallo fisso: una sessione di otto ore
// costerebbe centinaia di query per scoprire, quasi sempre, che non e'
// cambiato niente. Cosi' invece se ne fanno una all'avvio e una per ogni
// confine attraversato, tipicamente una o due in una giornata.
//
// I secondi si contano con un cronometro monotono e non confrontando
// timestamp con l'orologio di sistema: spostare indietro l'ora del PC non
// deve allungare la sessione.
//
// Sui database che non conoscono ancora le fasce orarie la procedura non
// esiste: la classe se ne accorge prima di chiamarla e resta spenta, senza
// sollevare niente.
//
// La classe non chiude niente e non mostra niente: solleva gli eventi
// OnAvviso e OnAccessoScaduto, e chi la usa decide cosa farne. In WinTarif e
// in Gesty vengono agganciati alla finestra di avviso e alla chiusura
// ordinata gia' usate da SHUTDOWN.

interface

uses
  System.Classes,
  System.SysUtils,
  System.Diagnostics,
  Vcl.ExtCtrls,
  FireDAC.Comp.Client,
  SmartInspect.Vcl.SiAuto,
  zFbDataSet;

type
  TzFasciaOrariaAvvisoEvent = procedure(Sender: TObject; SecondiResidui: integer) of object;

  TzControlloFasciaOraria = class(TComponent)
  private
    FApplicazione: string;
    FAvvisoBreveDato: boolean;
    FAvvisoLungoDato: boolean;
    FCronometro: TStopwatch;
    FDatabase: TzFbDatabase;
    FOnAccessoScaduto: TNotifyEvent;
    FOnAvviso: TzFasciaOrariaAvvisoEvent;
    FSecondiConcessi: integer;
    FTimer: TTimer;
    FTransaction: TzFbTransaction;
    FUserID: Int64;
    function ProceduraDisponibile: boolean;
    procedure Riarma(const SecondiAllaProssimaVerifica: integer);
    function SecondiResidui: integer;
    procedure TimerTimer(Sender: TObject);
    procedure Verifica;
    function VerificaSulServer(out SecondiAllaProssimaVerifica: integer): boolean;
  public
    constructor Create(AOwner: TComponent; aDatabase: TzFbDatabase; aTransaction: TzFbTransaction); reintroduce;
    procedure Avvia(const Applicazione: string; const UserID: Int64);
    procedure Ferma;
    function Attivo: boolean;
    property OnAccessoScaduto: TNotifyEvent read FOnAccessoScaduto write FOnAccessoScaduto;
    property OnAvviso: TzFasciaOrariaAvvisoEvent read FOnAvviso write FOnAvviso;
  end;

const
  // Nome dell'evento Firebird con cui il server annuncia a un singolo utente
  // che e' rimasto fuori fascia. Va completato con il nome dell'utente, come
  // fa SHUTDOWN_. E' distinto da SHUTDOWN di proposito: il messaggio mostrato
  // deve dire perche' l'applicazione si chiude.
  EventoFasciaOraria = 'FASCIA_ORARIA_';

  // La procedura che risponde alla domanda. Se non esiste, il database non
  // conosce le fasce orarie e il controllo resta spento.
  ProceduraVerificaFascia = 'USR_FASCIA_ACCESSO_CHECK';

  // Ogni quanto la classe guarda il cronometro. Non e' una query: e' un
  // confronto locale, il server viene interpellato solo allo scadere.
  IntervalloControlloLocale = 10 * 1000;

  // Preavvisi all'utente, in secondi prima della scadenza.
  SecondiAvvisoLungo = 10 * 60;
  SecondiAvvisoBreve = 60;

  // Se il server non risponde non si chiude niente: si riprova.
  SecondiRitentaDopoErrore = 60;

implementation

constructor TzControlloFasciaOraria.Create(AOwner: TComponent; aDatabase: TzFbDatabase; aTransaction: TzFbTransaction);
begin
  inherited Create(AOwner);

  FDatabase := aDatabase;
  FTransaction := aTransaction;

  FTimer := TTimer.Create(self);
  FTimer.Enabled := False;
  FTimer.Interval := IntervalloControlloLocale;
  FTimer.OnTimer := TimerTimer;
end;

function TzControlloFasciaOraria.Attivo: boolean;
begin
  result := FTimer.Enabled;
end;

procedure TzControlloFasciaOraria.Avvia(const Applicazione: string; const UserID: Int64);
begin
  FApplicazione := Applicazione;
  FUserID := UserID;

  FTimer.Enabled := False;

  if not ProceduraDisponibile then
    Exit;

  Verifica;
end;

procedure TzControlloFasciaOraria.Ferma;
begin
  FTimer.Enabled := False;
end;

function TzControlloFasciaOraria.ProceduraDisponibile: boolean;
begin
  // Si guarda nel dizionario invece di provare e ingoiare l'errore: cosi' le
  // eccezioni vere non passano inosservate.
  result := FDatabase.ExecSQLScalar('SELECT COUNT(*) FROM RDB$PROCEDURES WHERE RDB$PROCEDURE_NAME = ' + QuotedStr(ProceduraVerificaFascia)) > 0;
end;

procedure TzControlloFasciaOraria.Riarma(const SecondiAllaProssimaVerifica: integer);
begin
  // Zero significa nessun limite: l'utente non ha fasce associate e il
  // controllo resta spento per tutta la sessione.
  if SecondiAllaProssimaVerifica <= 0 then
  begin
    FTimer.Enabled := False;
    Exit;
  end;

  FSecondiConcessi := SecondiAllaProssimaVerifica;
  FAvvisoLungoDato := False;
  FAvvisoBreveDato := False;
  FCronometro := TStopwatch.StartNew;
  FTimer.Enabled := true;
end;

function TzControlloFasciaOraria.SecondiResidui: integer;
begin
  result := FSecondiConcessi - trunc(FCronometro.Elapsed.TotalSeconds);
end;

function TzControlloFasciaOraria.VerificaSulServer(out SecondiAllaProssimaVerifica: integer): boolean;
var
  Query: TFDQuery;
begin
  SecondiAllaProssimaVerifica := 0;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabase;
    Query.Transaction := FTransaction;

    Query.SQL.Text := 'SELECT' + sLineBreak + //
      '    USR_FASCIA_ACCESSO_CHECK.ACCESSO_AUTORIZZATO,' + sLineBreak + //
      '    USR_FASCIA_ACCESSO_CHECK.SECONDI_ALLA_PROSSIMA_VERIFICA' + sLineBreak + //
      'FROM' + sLineBreak + //
      '    USR_FASCIA_ACCESSO_CHECK(:APP, :USER_ID, CURRENT_TIMESTAMP)';

    Query.ParamByName('APP').AsString := FApplicazione;
    Query.ParamByName('USER_ID').AsLargeInt := FUserID;

    Query.Open;

    result := Query.FieldByName('ACCESSO_AUTORIZZATO').AsBoolean;
    SecondiAllaProssimaVerifica := Query.FieldByName('SECONDI_ALLA_PROSSIMA_VERIFICA').AsInteger;
  finally
    FreeAndNil(Query);
  end;
end;

procedure TzControlloFasciaOraria.Verifica;
var
  AccessoAutorizzato: boolean;
  SecondiAllaProssimaVerifica: integer;
begin
  FTimer.Enabled := False;

  try
    AccessoAutorizzato := VerificaSulServer(SecondiAllaProssimaVerifica);
  except
    // Database irraggiungibile: non e' un motivo per chiudere l'applicazione.
    // 2026-11-01 (DIV-FAS-1): l'errore va nel registro. Prima veniva
    // ingoiato senza traccia, anche quando era permanente (permessi,
    // parametri della procedura cambiati) e il controllo non sarebbe mai
    // piu' riuscito.
    on e: Exception do
    begin
      siMain.LogWarning('Fascia oraria: verifica sul server non riuscita, nuovo tentativo fra %d secondi', [SecondiRitentaDopoErrore]);
      siMain.LogException(e);
      Riarma(SecondiRitentaDopoErrore);
      Exit;
    end;
  end;

  if AccessoAutorizzato then
    Riarma(SecondiAllaProssimaVerifica)
  else
    if assigned(FOnAccessoScaduto) then
      FOnAccessoScaduto(self);
end;

procedure TzControlloFasciaOraria.TimerTimer(Sender: TObject);
var
  Residui: integer;
begin
  Residui := SecondiResidui;

  // Preavvisi. Chiudere di colpo un programma con una scheda aperta in
  // modifica significa far perdere il lavoro all'utente.
  if (Residui > 0) and (Residui <= SecondiAvvisoBreve) and not FAvvisoBreveDato then
  begin
    FAvvisoBreveDato := true;
    if assigned(FOnAvviso) then
      FOnAvviso(self, Residui);
  end
  else
    if (Residui > SecondiAvvisoBreve) and (Residui <= SecondiAvvisoLungo) and not FAvvisoLungoDato then
    begin
      FAvvisoLungoDato := true;
      if assigned(FOnAvviso) then
        FOnAvviso(self, Residui);
    end;

  if Residui > 0 then
    Exit;

  // Tempo scaduto: si chiede al server, che e' l'unico a sapere se nel
  // frattempo e' arrivata una deroga.
  Verifica;
end;

end.
