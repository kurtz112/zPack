unit zDocumentale.Protocollo.Types;

// Tipi del motore di protocollazione multi-fornitore.
// NESSUNA dipendenza applicativa (no WT.Globals, no ConfigModule, no dmCommon):
// configurazione e persistenza vengono iniettate dal ponte applicativo
// (dmProtocollo), mai lette direttamente dal provider.
// Riferimento: analisi_completa_documentale_wt_gesty.md, PARTE II §5 e PARTE IV §12.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  EzProtocolloErrore = class(Exception);
  EzProtocolloNonSupportato = class(EzProtocolloErrore);

  TzProtocolloDirezione = (pdEntrata, pdUscita, pdInterno);

  TzProtocolloFunzionalita = (pfProtocollaUscita, pfImportaEntrata, pfRicerca,
    pfScaricaAllegati, pfAnnulla, pfAggiungiAllegato, pfPrenotaNumero, pfInviaPec);
  TzProtocolloFunzionalitaSet = set of TzProtocolloFunzionalita;

  TzProtocolloSoggetto = record
    // 'M' = mittente, 'D' = destinatario (dominio OBJ_FILES_PROTOCOLLO_TIPO_SOGGETTO)
    Tipo: string;
    Cognome: string;
    Nome: string;
    CodiceFiscale: string;
    PartitaIva: string;
    IdIntestatario: Integer;
    procedure Clear;
  end;

  TzProtocolloAllegato = record
    // la VERSIONE del file (riga di OBJ_FILES), non "il documento"
    IdObjectFile: Int64;
    FullFileName: string;
    NomeOriginale: string;
    Principale: Boolean;
    IdAllegatoEsterno: string;
    procedure Clear;
  end;

  TzProtocolloDocumento = record
    IdTenant: Integer;
    Direzione: TzProtocolloDirezione;
    Oggetto: string;
    DataDocumento: TDate;
    DataRicezione: TDateTime;       // solo entrata
    ProtocolloMittente: string;     // solo entrata
    Riservato: Boolean;
    Soggetti: TArray<TzProtocolloSoggetto>;
    Allegati: TArray<TzProtocolloAllegato>;
    Oid: Int64;
    IdGedoDocUscita: Integer;       // solo WT (0 = non usato)
    // valori logici: il provider li traduce con OBJ_FILES_PROTOCOLLO_CORRISPONDENZE
    TipoDocumento: string;
    Classifica: string;
    Ufficio: string;
    AreaOrganizzativa: string;
    CanaleInvio: string;
    procedure Clear;
  end;

  TzProtocolloEsito = record
    Ok: Boolean;
    Anno: Integer;
    Numero: Int64;
    Data: TDateTime;
    Registro: string;
    IdDocumentoEsterno: string;
    Messaggio: string;
    InAttesaDiNumero: Boolean;      // Faber "Protocolla Dopo"
    procedure Clear;
    function Estremi: string;       // '1234/2026 del 15/07/2026'
  end;

  // Documento trovato in un archivio di protocollo esterno (IMPORT in entrata).
  // Porta gli estremi gia' assegnati dal protocollo del fornitore piu' il
  // soggetto (mittente). Gli allegati NON sono qui: si scaricano a parte con
  // ScaricaAllegati, perche' e' il ponte a crearli come OBJ_FILES sotto l'OID
  // del documento importato.
  TzProtocolloDocumentoTrovato = record
    IdDocumentoEsterno: string;
    AnnoProtocollo: Integer;
    NumeroProtocollo: Integer;
    DataProtocollo: TDateTime;
    DataInserimento: TDateTime;
    DataAnnullamento: TDateTime;
    TipoDocumento: string;
    Oggetto: string;
    Origine: string;
    AnnoFascicolo: string;
    NumeroFascicolo: string;
    IdSoggetto: Integer;
    Nominativo: string;
    CodiceFiscaleOPartitaIva: string;
    ChiaveAlternativa: string;
    procedure Clear;
  end;

  // Log tecnico: il ponte applicativo aggancia queste callback alle stored
  // procedure OBJ_FILES_PROTOCOLLO_LOG_REQUEST_ADD / _RESPONSE_ADD.
  // Una richiesta senza risposta e' un timeout: dato diagnostico a se' stante.
  TzProtocolloLogRequestFunc = reference to function(const Operazione, Endpoint,
    Richiesta: string): Int64;
  TzProtocolloLogResponseProc = reference to procedure(IdLogRequest: Int64;
    HttpStatus: Integer; const Risposta, Errore: string);

  TzProtocolloConfigurazione = record
    Fornitore: string;
    IdTenant: Integer;              // WT: ID_AZIENDA (AZIENDE) - Gesty: ID_ENTE
    UrlBase: string;
    Utente: string;
    Password: string;
    // CHIAVE -> VALORE (OBJ_FILES_PROTOCOLLO_CONFIG_PARAMETRI)
    Parametri: TDictionary<string, string>;
    // 'TIPO|CODICE_INTERNO' -> CODICE_ESTERNO (OBJ_FILES_PROTOCOLLO_CORRISPONDENZE)
    Corrispondenze: TDictionary<string, string>;
    // i dizionari sono creati e liberati dal ponte applicativo (dmProtocollo)
    procedure Inizializza;
    procedure Finalizza;
    function Parametro(const Chiave: string; const Default: string = ''): string;
    function Corrispondenza(const Tipo, CodiceInterno: string): string;
  end;

implementation

{ TzProtocolloSoggetto }

procedure TzProtocolloSoggetto.Clear;
begin
  Self := Default(TzProtocolloSoggetto);
end;

{ TzProtocolloAllegato }

procedure TzProtocolloAllegato.Clear;
begin
  Self := Default(TzProtocolloAllegato);
end;

{ TzProtocolloDocumento }

procedure TzProtocolloDocumento.Clear;
begin
  Self := Default(TzProtocolloDocumento);
end;

{ TzProtocolloDocumentoTrovato }

procedure TzProtocolloDocumentoTrovato.Clear;
begin
  Self := Default(TzProtocolloDocumentoTrovato);
end;

{ TzProtocolloEsito }

procedure TzProtocolloEsito.Clear;
begin
  Self := Default(TzProtocolloEsito);
end;

function TzProtocolloEsito.Estremi: string;
begin
  result := '';
  if (Numero = 0) and (Anno = 0) then
    exit;
  result := Format('%d/%d', [Numero, Anno]);
  if Data <> 0 then
    result := result + ' del ' + FormatDateTime('dd/mm/yyyy', Data);
end;

{ TzProtocolloConfigurazione }

procedure TzProtocolloConfigurazione.Inizializza;
begin
  Self := Default(TzProtocolloConfigurazione);
  Parametri := TDictionary<string, string>.Create;
  Corrispondenze := TDictionary<string, string>.Create;
end;

procedure TzProtocolloConfigurazione.Finalizza;
begin
  FreeAndNil(Parametri);
  FreeAndNil(Corrispondenze);
end;

function TzProtocolloConfigurazione.Parametro(const Chiave: string;
  const Default: string): string;
begin
  result := Default;
  if assigned(Parametri) then
    if not Parametri.TryGetValue(Chiave.ToUpper, result) then
      result := Default;
end;

function TzProtocolloConfigurazione.Corrispondenza(const Tipo,
  CodiceInterno: string): string;
begin
  result := '';
  if assigned(Corrispondenze) then
    if not Corrispondenze.TryGetValue(Tipo.ToUpper + '|' + CodiceInterno.ToUpper, result) then
      result := '';
end;

end.
