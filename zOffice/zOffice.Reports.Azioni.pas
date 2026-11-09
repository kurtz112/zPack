unit zOffice.Reports.Azioni;

// Configurazione delle azioni documentali di un documento: capacita'
// statiche (riga presente = ammessa), precondizioni di catena (RICHIEDE),
// versione operativa (AGISCE_SU) e fornitore forzato (FORNITORE).
//
// DAL 30/07/2026 la fonte e' il PROFILO DOCUMENTALE sul database
// (OBJ_FILES_PROFILI_DOCUMENTALI_AZIONI, letta con la procedura
// OBJ_FILES_PROFILO_AZIONI_GET dal ponte applicativo): il nodo JSON
// "azioni" e' stato ritirato senza transizione perche' nessun JSON era
// mai andato in produzione. Il JSON del template dichiara solo le chiavi
// "profilo" e "tipologiaDocumentale" (zOffice.Reports.JsonConfig).
// Record neutri: solo tipi primitivi, nessuna dipendenza.

interface

type
  TzJsonAzioneConfig = record
    Enabled: Boolean;
    // colonna RICHIEDE (ex chiave JSON "req"): TIPO_VERSIONE che devono
    // esistere (non annullati) nella catena prima che l'azione sia
    // eseguibile; piu' valori = AND
    Richiede: TArray<string>;
    // colonna AGISCE_SU (ex chiave JSON "target"): su quale versione
    // l'azione opera; '' = corrente
    VersioneOperativa: string;
    // colonna FORNITORE (ex chiave JSON "engine"): forzatura del fornitore
    // configurato a livello azienda/ente
    Engine: string;
    IsPresent: Boolean;
    procedure Clear;
  end;

  TzJsonAzioniConfig = record
    Firma: TzJsonAzioneConfig;
    Protocollo: TzJsonAzioneConfig;
    Conservazione: TzJsonAzioneConfig;
    InviaPec: TzJsonAzioneConfig;
    InviaMail: TzJsonAzioneConfig;
    IsPresent: Boolean;   // True se il profilo ha almeno un'azione
    procedure Clear;
  end;

implementation

{ TzJsonAzioneConfig }

procedure TzJsonAzioneConfig.Clear;
begin
  Self := Default(TzJsonAzioneConfig);
end;

{ TzJsonAzioniConfig }

procedure TzJsonAzioniConfig.Clear;
begin
  Self := Default(TzJsonAzioniConfig);
end;

end.
