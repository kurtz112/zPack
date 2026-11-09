unit zDocumentale.Messaggi.Types;

// Tipi del motore di invio PEC multi-fornitore.
// L'invio PEC e' un ciclo asincrono: si invia, poi arrivano le ricevute
// (accettazione dal gestore mittente, consegna PER DESTINATARIO).
// La ricevuta e' un documento (.eml firmato dal gestore): il ponte
// applicativo (dmPec) la registra come versione RIC della catena OBJ_FILES.
// Riferimento: analisi_completa_documentale_wt_gesty.md, PARTE II §8.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  EzMessaggioErrore = class(Exception);
  EzMessaggioNonSupportato = class(EzMessaggioErrore);

  TzMessaggioFunzionalita = (pecInvia, pecLeggiRicevute, pecVerificaConsegna);
  TzMessaggioFunzionalitaSet = set of TzMessaggioFunzionalita;

const
  // stati della spedizione (dominio OBJ_FILES_MAIL_E_MESSAGGI_STATO)
  MESSAGGIO_STATO_PREPARATA  = 'P';   // registrata, non ancora inviata
  MESSAGGIO_STATO_INVIATA    = 'I';   // accettata dal server di invio, in attesa di ricevute
  MESSAGGIO_STATO_ACCETTATA  = 'A';   // ricevuta di accettazione del gestore mittente
  MESSAGGIO_STATO_CONSEGNATA = 'C';   // consegna per tutti i destinatari principali
  MESSAGGIO_STATO_ERRORE     = 'E';   // errore di invio o mancata consegna
  MESSAGGIO_STATO_ANNULLATA  = 'X';

type
  TzMessaggioTipoDestinatario = (pdDestinatario, pdCopiaConoscenza);

  TzMessaggioTipoRicevuta = (prAccettazione, prConsegna, prNonAccettazione, prMancataConsegna);

  TzMessaggioDestinatario = record
    Indirizzo: string;
    Tipo: TzMessaggioTipoDestinatario;
    procedure Clear;
  end;

  TzMessaggioAllegato = record
    // la VERSIONE spedita (riga di OBJ_FILES), non "il documento"
    IdObjectFile: Int64;
    FullFileName: string;
    NomeOriginale: string;
    Principale: Boolean;
    procedure Clear;
  end;

  TzMessaggio = record
    Oggetto: string;
    Corpo: string;
    Destinatari: TArray<TzMessaggioDestinatario>;
    Allegati: TArray<TzMessaggioAllegato>;
    Oid: Int64;
    procedure Clear;
  end;

  TzMessaggioRicevuta = record
    Tipo: TzMessaggioTipoRicevuta;
    IndirizzoDestinatario: string;  // valorizzato per consegna / mancata consegna
    DataOra: TDateTime;
    MessageId: string;              // il Message-ID del messaggio originale
    FileRicevuta: string;           // path temporaneo dell'.eml scaricato:
                                    // il ponte lo trasforma in versione RIC
    procedure Clear;
  end;

  TzMessaggioEsito = record
    Ok: Boolean;
    Stato: string;                  // P/I/A/C/E/X
    StatoEsterno: string;           // testo grezzo del fornitore/gestore
    MessageId: string;
    Messaggio: string;
    procedure Clear;
  end;

  // log tecnico: agganciato dal ponte alle SP
  // OBJ_FILES_MAIL_E_MESSAGGI_LOG_REQUEST_ADD / _RESPONSE_ADD
  TzMessaggioLogRequestFunc = reference to function(const Operazione, Endpoint,
    Richiesta: string): Int64;
  TzMessaggioLogResponseProc = reference to procedure(IdLogRequest: Int64;
    HttpStatus: Integer; const Risposta, Errore: string);

  TzMessaggioConfigurazione = record
    Fornitore: string;
    IdTenant: Integer;              // WT: ID_AZIENDA (AZIENDE) - Gesty: ID_ENTE
    IndirizzoMittente: string;
    Utente: string;
    Password: string;
    // server, porte, sicurezza e ogni altro dettaglio: chiave/valore
    // (OBJ_FILES_MAIL_E_MESSAGGI_CONFIG_PARAMETRI)
    Parametri: TDictionary<string, string>;
    procedure Inizializza;
    procedure Finalizza;
    function Parametro(const Chiave: string; const Default: string = ''): string;
  end;

implementation

{ TzMessaggioDestinatario }

procedure TzMessaggioDestinatario.Clear;
begin
  Self := Default(TzMessaggioDestinatario);
end;

{ TzMessaggioAllegato }

procedure TzMessaggioAllegato.Clear;
begin
  Self := Default(TzMessaggioAllegato);
end;

{ TzMessaggio }

procedure TzMessaggio.Clear;
begin
  Self := Default(TzMessaggio);
end;

{ TzMessaggioRicevuta }

procedure TzMessaggioRicevuta.Clear;
begin
  Self := Default(TzMessaggioRicevuta);
end;

{ TzMessaggioEsito }

procedure TzMessaggioEsito.Clear;
begin
  Self := Default(TzMessaggioEsito);
end;

{ TzMessaggioConfigurazione }

procedure TzMessaggioConfigurazione.Inizializza;
begin
  Self := Default(TzMessaggioConfigurazione);
  Parametri := TDictionary<string, string>.Create;
end;

procedure TzMessaggioConfigurazione.Finalizza;
begin
  FreeAndNil(Parametri);
end;

function TzMessaggioConfigurazione.Parametro(const Chiave: string;
  const Default: string): string;
begin
  result := Default;
  if assigned(Parametri) then
    if not Parametri.TryGetValue(Chiave.ToUpper, result) then
      result := Default;
end;

end.
