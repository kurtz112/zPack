unit zDocumentale.Protocollo.Intf;

// Contratto del provider di protocollazione. I metodi non supportati dal
// fornitore sollevano EzProtocolloNonSupportato; la UI si regola su Funzionalita.

interface

uses
  System.SysUtils,
  zDocumentale.Protocollo.Types;

type
  IzProtocolloProvider = interface
    ['{7E1A4C0B-9D2F-4B7A-8C31-5A6E0D48F214}']
    function Nome: string;
    function Funzionalita: TzProtocolloFunzionalitaSet;

    procedure Configura(const Configurazione: TzProtocolloConfigurazione);
    procedure Connetti;
    procedure Disconnetti;
    function Connesso: Boolean;
    procedure TestConnessione;

    // uscita
    function Protocolla(const Documento: TzProtocolloDocumento): TzProtocolloEsito;
    function PrenotaNumero(const Documento: TzProtocolloDocumento): TzProtocolloEsito;
    function AggiungiAllegato(const IdDocumentoEsterno: string;
      const Allegato: TzProtocolloAllegato): Boolean;
    function AggiornaEstremi(const IdDocumentoEsterno: string): TzProtocolloEsito;
    function Annulla(const IdDocumentoEsterno, Motivo: string): Boolean;

    // entrata (import): ricerca restituisce gli estremi dei documenti trovati;
    // gli allegati si scaricano poi con ScaricaAllegati (in una cartella
    // temporanea) e li registra il ponte come OBJ_FILES.
    function RicercaPerSoggetto(const ChiaveRicerca: string): TArray<TzProtocolloDocumentoTrovato>;
    function RicercaPerPeriodo(const DalGiorno, AlGiorno: TDate): TArray<TzProtocolloDocumentoTrovato>;
    function ScaricaAllegati(const IdDocumentoEsterno,
      CartellaDestinazione: string): TArray<TzProtocolloAllegato>;
  end;

implementation

end.
