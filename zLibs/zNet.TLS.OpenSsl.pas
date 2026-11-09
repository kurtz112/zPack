// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-08
// ---------------------------------------------------------------------------
unit zNet.Tls.OpenSsl;

// Provider TLS basato sull'handler Indy IdSSLOpenSSL, che carica
// libeay32.dll e ssleay32.dll (OpenSSL 1.0.2).
//
// E' l'unica unit di zPack autorizzata a usare IdSSLOpenSSL.
//
// Auto-registrazione con codice 'OPENSSL': basta includere questa unit nel
// .dpr, insieme a zNet.Tls.SChannel se l'installazione deve poter scegliere
// fra i due motori. La registrazione da sola non lo rende attivo: serve
// comunque che l'applicazione chiami zNet.Tls.SelezionaProviderTls('OPENSSL')
// (o 'SCHANNEL') con il valore letto dalla configurazione dell'installazione.

interface

implementation

uses
  System.SysUtils,
  System.Classes,
  IdSSL,
  IdSSLOpenSSL,
  IdSSLOpenSSLHeaders,
  zNet.Tls;

function CreaIOHandlerOpenSsl(Proprietario: TComponent; Versione: TzTlsVersione; VerificaCertificato: Boolean): TIdSSLIOHandlerSocketBase;
var
  Handler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Handler := TIdSSLIOHandlerSocketOpenSSL.Create(Proprietario);
  try
    Handler.SSLOptions.Mode := sslmClient;
    Handler.SSLOptions.VerifyDepth := 0;

    // Con OpenSSL la verifica richiede anche un archivio di certificati
    // radice (SSLOptions.RootCertFile), che oggi non viene distribuito:
    // il parametro e' previsto per il provider SChannel, che usa l'archivio
    // di Windows. Qui resta il comportamento storico (nessuna verifica).
    if VerificaCertificato then
      Handler.SSLOptions.VerifyMode := [sslvrfPeer]
    else
      Handler.SSLOptions.VerifyMode := [];

    // Method imposta anche SSLVersions sulla sola versione indicata.
    // OpenSSL 1.0.2 non conosce TLS 1.3: la richiesta scende a 1.2.
    case Versione of
      tlsVersione1_0:
        Handler.SSLOptions.Method := sslvTLSv1;
      tlsVersione1_1:
        Handler.SSLOptions.Method := sslvTLSv1_1;
    else
      Handler.SSLOptions.Method := sslvTLSv1_2;
    end;
  except
    Handler.Free;
    raise;
  end;

  Result := Handler;
end;

// Indica a Indy dove cercare libeay32.dll e ssleay32.dll. Prima era
// IdOpenSSLSetLibPath chiamata a mano in MainFrm.pas (GestyTools) e in
// Server_Module.pas (Gesty Server): ora e' l'unica unit che conosce
// IdSSLOpenSSLHeaders, come da disegno.
procedure ImpostaCartellaLibrerieTLSOpenSsl(const Cartella: string);
begin
  IdOpenSSLSetLibPath(Cartella);
end;

initialization

RegistraProviderTls('OPENSSL', 'OpenSSL 1.0.2 (IdSSLOpenSSL)', CreaIOHandlerOpenSsl, ImpostaCartellaLibrerieTLSOpenSsl);

// default: la cartella dell'eseguibile, lo stesso comportamento che
// MainFrm.pas (GestyTools) impostava a mano a ogni avvio. Chi ha bisogno
// di un percorso diverso (Gesty Server, che lo legge da INI) lo sovrascrive
// chiamando zNet.Tls.ImpostaCartellaLibrerieTLS in un punto successivo. Vale
// anche se il motore selezionato e' SChannel: la chiamata non ha effetto
// finche' OPENSSL non e' il motore scelto con SelezionaProviderTls.
ImpostaCartellaLibrerieTLSOpenSsl(ExtractFilePath(ParamStr(0)));

end.
