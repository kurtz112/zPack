unit zDocumentale.Conservazione.Types;

// Tipi del motore di conservazione sostitutiva multi-fornitore.
// NESSUNA dipendenza applicativa: configurazione e persistenza iniettate
// dal ponte applicativo (dmConservazione).
// Il versamento e' asincrono per natura: si versa, poi arriva il rapporto.
// Riferimento: analisi_completa_documentale_wt_gesty.md, PARTE II §6.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  EzConservazioneErrore = class(Exception);
  EzConservazioneNonSupportato = class(EzConservazioneErrore);

  TzConservazioneFunzionalita = (cfVersa, cfVerificaEsito, cfEsibisci,
    cfScaricaRapporto, cfAnnulla);
  TzConservazioneFunzionalitaSet = set of TzConservazioneFunzionalita;

const
  // stati del pacchetto (dominio OBJ_FILES_CONSERVAZIONE_STATO)
  CONSERVAZIONE_STATO_INSERITO   = 'INS';
  CONSERVAZIONE_STATO_GENERATO   = 'GEN';
  CONSERVAZIONE_STATO_INVIATO    = 'INV';
  CONSERVAZIONE_STATO_ACCETTATO  = 'ACC';
  CONSERVAZIONE_STATO_RIFIUTATO  = 'RIF';
  CONSERVAZIONE_STATO_CONSERVATO = 'CON';
  CONSERVAZIONE_STATO_ANNULLATO  = 'ANN';

  // esito per singolo documento (dominio OBJ_FILES_CONSERVAZIONE_ESITO)
  CONSERVAZIONE_ESITO_ACCETTATO = 'A';
  CONSERVAZIONE_ESITO_SCARTATO  = 'S';
  CONSERVAZIONE_ESITO_IN_ATTESA = 'W';

type
  // metadato AgID congelato al momento del versamento
  TzConservazioneMetadato = record
    Chiave: string;
    Valore: string;
    procedure Clear;
  end;

  TzConservazioneDocumento = record
    // la VERSIONE conservata (riga di OBJ_FILES), scelta da
    // TIPO_VERSIONE_DA_CONSERVARE con fallback PRO -> FIR -> ORI
    IdObjectFile: Int64;
    FullFileName: string;
    NomeOriginale: string;
    // hash congelato al versamento: l'unico modo per accorgersi in seguito
    // di file cambiati o corrotti
    HashSha256: string;
    Metadati: TArray<TzConservazioneMetadato>;
    procedure Clear;
  end;

  TzConservazionePacchetto = record
    IdPacchetto: Int64;             // OBJ_FILES_CONSERVAZIONE_PACCHETTI (gia' creato in stato INS)
    IdTenant: Integer;              // WT: ID_AZIENDA (AZIENDE) - Gesty: ID_ENTE
    ClasseDocumentale: string;      // valore logico: il provider lo traduce con le corrispondenze
    TipoArchiviazione: string;
    NomeFileArchivio: string;
    Documenti: TArray<TzConservazioneDocumento>;
    Metadati: TArray<TzConservazioneMetadato>;   // metadati AgID a livello di pacchetto
    procedure Clear;
  end;

  TzConservazioneEsitoDocumento = record
    IdObjectFile: Int64;
    Esito: string;                  // 'A' / 'S' / 'W'
    MotivoScarto: string;
    // l'identificativo che il conservatore assegna al documento:
    // il dato che serve per esibirlo a distanza di anni
    IdDocumentoEsterno: string;
    procedure Clear;
  end;

  TzConservazioneEsito = record
    Ok: Boolean;
    Stato: string;                  // INS/GEN/INV/ACC/RIF/CON/ANN
    StatoEsterno: string;           // testo grezzo del conservatore
    IdPacchettoEsterno: string;
    Messaggio: string;
    EsitiDocumenti: TArray<TzConservazioneEsitoDocumento>;
    procedure Clear;
  end;

  // log tecnico: agganciato dal ponte alle SP
  // OBJ_FILES_CONSERVAZIONE_LOG_REQUEST_ADD / _RESPONSE_ADD
  TzConservazioneLogRequestFunc = reference to function(const Operazione, Endpoint,
    Richiesta: string): Int64;
  TzConservazioneLogResponseProc = reference to procedure(IdLogRequest: Int64;
    HttpStatus: Integer; const Risposta, Errore: string);

  TzConservazioneConfigurazione = record
    Fornitore: string;
    IdTenant: Integer;
    UrlBase: string;
    Utente: string;
    Password: string;
    // regola di scelta della versione da versare (es. 'PRO'), con fallback a cascata
    TipoVersioneDaConservare: string;
    Parametri: TDictionary<string, string>;
    // classe documentale interna -> tipologia documentale del conservatore
    Corrispondenze: TDictionary<string, string>;
    procedure Inizializza;
    procedure Finalizza;
    function Parametro(const Chiave: string; const Default: string = ''): string;
    function Corrispondenza(const Tipo, CodiceInterno: string): string;
  end;

implementation

{ TzConservazioneMetadato }

procedure TzConservazioneMetadato.Clear;
begin
  Self := Default(TzConservazioneMetadato);
end;

{ TzConservazioneDocumento }

procedure TzConservazioneDocumento.Clear;
begin
  Self := Default(TzConservazioneDocumento);
end;

{ TzConservazionePacchetto }

procedure TzConservazionePacchetto.Clear;
begin
  Self := Default(TzConservazionePacchetto);
end;

{ TzConservazioneEsitoDocumento }

procedure TzConservazioneEsitoDocumento.Clear;
begin
  Self := Default(TzConservazioneEsitoDocumento);
end;

{ TzConservazioneEsito }

procedure TzConservazioneEsito.Clear;
begin
  Self := Default(TzConservazioneEsito);
end;

{ TzConservazioneConfigurazione }

procedure TzConservazioneConfigurazione.Inizializza;
begin
  Self := Default(TzConservazioneConfigurazione);
  Parametri := TDictionary<string, string>.Create;
  Corrispondenze := TDictionary<string, string>.Create;
end;

procedure TzConservazioneConfigurazione.Finalizza;
begin
  FreeAndNil(Parametri);
  FreeAndNil(Corrispondenze);
end;

function TzConservazioneConfigurazione.Parametro(const Chiave: string;
  const Default: string): string;
begin
  result := Default;
  if assigned(Parametri) then
    if not Parametri.TryGetValue(Chiave.ToUpper, result) then
      result := Default;
end;

function TzConservazioneConfigurazione.Corrispondenza(const Tipo,
  CodiceInterno: string): string;
begin
  result := '';
  if assigned(Corrispondenze) then
    if not Corrispondenze.TryGetValue(Tipo.ToUpper + '|' + CodiceInterno.ToUpper, result) then
      result := '';
end;

end.
