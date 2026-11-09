unit zDocumentale.Firma.Intf;

// Contratto del provider di firma elettronica. I metodi non supportati
// sollevano EzFirmaNonSupportato; la UI si regola su Funzionalita.

interface

uses
  System.SysUtils,
  zDocumentale.Firma.Types;

type
  IzFirmaProvider = interface
    ['{A94D6E27-1B83-4F5C-B0E9-73C2D8461FA5}']
    function Nome: string;
    function Funzionalita: TzFirmaFunzionalitaSet;

    procedure Configura(const Configurazione: TzFirmaConfigurazione);
    procedure TestConnessione;

    // Avvia (o completa, se il fornitore e' sincrono) la firma.
    // Provider a certificato remoto: usa Documento.Credenziale, firma subito,
    //   ritorna Stato = 'F' con IdObjectFileFirmato valorizzato.
    // Provider a busta/envelope: usa Documento.Firmatari, invia la busta,
    //   ritorna Stato = 'D' (in firma) con IdDocumentoEsterno = envelope id.
    function Firma(const Documento: TzFirmaDocumento): TzFirmaEsito;

    // Polling dello stato per i fornitori asincroni (come UPD_STATUS in Gesty):
    // quando la busta risulta firmata, scarica firmato + audit e valorizza
    // IdObjectFileFirmato / IdObjectFileAudit tramite la callback CreaVersione
    // (il Documento porta la versione di partenza, padre delle nuove versioni).
    function AggiornaEstremi(const Documento: TzFirmaDocumento;
      const IdDocumentoEsterno: string): TzFirmaEsito;

    // Solo fornitori a certificato remoto.
    function ScaricaCertificato(const Credenziale: TzFirmaCredenziale): TzFirmaEsito;
  end;

implementation

end.
