unit zDocumentale.Messaggi.Intf;

// Contratto del provider PEC. I metodi non supportati sollevano
// EzMessaggioNonSupportato; la UI si regola su Funzionalita.

interface

uses
  System.SysUtils,
  zDocumentale.Messaggi.Types;

type
  IzMessaggioProvider = interface
    ['{5C08B7D4-6E92-4A1F-83B5-D174F0C9E623}']
    function Nome: string;
    function Funzionalita: TzMessaggioFunzionalitaSet;

    procedure Configura(const Configurazione: TzMessaggioConfigurazione);
    procedure TestConnessione;

    // Invia il messaggio; la registrazione (stato 'P') e' gia' stata creata
    // dal ponte PRIMA di questa chiamata (idempotenza).
    function Invia(const Messaggio: TzMessaggio): TzMessaggioEsito;

    // Ritorna le ricevute nuove per i message-id indicati
    // (o tutte le ricevute disponibili se l'elenco e' vuoto).
    function LeggiRicevute(const MessageIds: TArray<string>): TArray<TzMessaggioRicevuta>;
  end;

implementation

end.
