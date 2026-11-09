unit zDocumentale.Conservazione.Intf;

// Contratto del provider di conservazione sostitutiva. I metodi non supportati
// sollevano EzConservazioneNonSupportato; la UI si regola su Funzionalita.

interface

uses
  System.SysUtils,
  zDocumentale.Conservazione.Types;

type
  IzConservazioneProvider = interface
    ['{B3F82D91-4C57-4E0A-9B6D-2E718F5A03C6}']
    function Nome: string;
    function Funzionalita: TzConservazioneFunzionalitaSet;

    procedure Configura(const Configurazione: TzConservazioneConfigurazione);
    procedure TestConnessione;

    function Versa(const Pacchetto: TzConservazionePacchetto): TzConservazioneEsito;
    function VerificaEsito(const IdPacchettoEsterno: string): TzConservazioneEsito;
    // scarica il Rapporto di Versamento; ritorna il path del file scaricato.
    // Il RdV e' a sua volta un documento da conservare: il ponte applicativo
    // lo registra come versione RIC della catena
    function ScaricaRapportoDiVersamento(const IdPacchettoEsterno,
      CartellaDestinazione: string): string;
    function Esibisci(const IdDocumentoEsterno, CartellaDestinazione: string): string;
    function Annulla(const IdPacchettoEsterno, Motivo: string): Boolean;
  end;

implementation

end.
