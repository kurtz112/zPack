// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-29
// ---------------------------------------------------------------------------
unit zNet.Tls.SChannel;

// Provider TLS basato su SChannel (il motore TLS di Windows: secur32.dll,
// crypt32.dll), aggancio Indy standard. Nessuna DLL da distribuire: a
// differenza di zNet.Tls.OpenSsl, non c'e' libeay32.dll/ssleay32.dll da
// tenere aggiornata e nessuna superficie CVE di OpenSSL da monitorare, il
// requisito di fondo del Cyber Resilience Act (Regolamento UE 2024/2847)
// sulla gestione delle vulnerabilita' nei componenti software distribuiti.
//
// Portato da sgcSSL_SChannel_Indy.pas (sgcWebSockets Enterprise Single
// 2023.8.0, licenza Softline S.r.l.) come previsto dalla sezione 7.4
// dell'analisi "Eliminazione Dipendenza OpenSSL In Gesty E WinTarif". Nella
// libreria sgc questa unit si aggancia, a seconda della configurazione, alla
// copia privata di Indy distribuita con sgc (sgcIdSSL, sgcIdGlobal, ...) o
// alla Indy standard di RAD Studio: la EULA sgc (punto 1.c) ammette la
// modifica del sorgente per uso proprio. Qui il ramo scelto e' sempre
// quello della Indy standard (IdSSL, IdGlobal, IdURI,
// IdCustomTransparentProxy), l'unico che i componenti Indy di Gesty e
// WinTarif (TIdSMTP, TIdIMAP4, TIdFTP) possano usare.
//
// Auto-registrazione con codice 'SCHANNEL': va inclusa nel .dpr sempre
// insieme a zNet.Tls.OpenSsl (non al suo posto), cosi' l'installazione puo'
// scegliere il motore in configurazione. Registrarsi non basta ad attivare
// il motore: l'applicazione deve chiamare
// zNet.Tls.SelezionaProviderTls('SCHANNEL') con il valore letto dalla
// propria configurazione (vedi zPack\LEGGIMI.md).
//
// Due difetti noti dell'originale sgc, corretti qui (sezione 7.3/7.5
// dell'analisi):
// 1. Clone non copiava TLSVersion, Certificate ne' CipherList sull'istanza
//    clonata. TIdFTP chiama Clone per il canale dati (ftpdpsPrivate): senza
//    questa correzione il canale dati negozierebbe con i valori di default
//    (oggi corretti, ma comunque diversi da quelli scelti per il canale di
//    controllo) invece di ereditare quelli del socket di controllo.
// 2. Default TLSVersion a costruzione: tls1_2 invece di tls1_0.
//    Su Windows 10 e precedenti SCHANNEL_CRED (legacy) applica la versione
//    alla lettera: tls1_0 abilita SOLO TLS 1.0 (SP_PROT_SSL3TLS1), che
//    nessun server accetta piu'. Su Windows 11/Server 2022 in su la
//    versione e' comunque ignorata (Windows negozia da solo con
//    SCH_CREDENTIALS), quindi il default piu' alto non cambia nulla la'
//    dove non serve e ripara la connessione dove serve.
//
// Correzioni del 29/9/2026, emerse dal collaudo FTPS verso un Synology (con
// SCHANNEL il primo trasferimento falliva, con OPENSSL no):
// 3. Ripresa della sessione TLS sul canale dati FTPS, come SSL_copy_session_id
//    di IdSSLOpenSSL: Clone prende dal canale di controllo un riferimento
//    alle sue credenziali SChannel e il suo nome del server, e il canale dati
//    li usa entrambi (la cache delle sessioni di Schannel li vuole identici).
//    Risolve anche il limite noto del nome del server: prima il canale dati
//    usava l'indirizzo IP della risposta PASV.
// 4. Readable come TIdSSLIOHandlerSocketOpenSSL.Readable: prima i dati gia'
//    arrivati, poi la select di Indy sul socket con la sua semantica dei
//    tempi. L'originale con AMSec = 0 eseguiva una recv bloccante, e dopo la
//    chiusura del server rispondeva False: con attesa illimitata ReadLn di
//    Indy lo interpreta come timeout e ricomincia senza fine.
// 5. Close manda il close_notify prima di chiudere il socket, come
//    SSL_shutdown nel provider OpenSSL.
// 6. SO_RCVTIMEO/SO_SNDTIMEO sul socket cifrato (ReadTimeout, o 30 secondi),
//    come OpenEncodedConnection di IdSSLOpenSSL: una lettura cominciata dopo
//    la select non puo' piu' restare ferma per sempre.

interface

uses
  Classes, SysUtils, System.SyncObjs,
  IdGlobal, IdSSL, IdURI, IdCustomTransparentProxy,
  zNet.Tls.SChannel.Engine;

type
  SChannelError = class(Exception)
  public
    CertStatus: Cardinal;
    constructor Create(AMsg: string; AStatus: Cardinal);
  end;

  TCredentialsEvent = procedure(Sender: TObject) of object;

  // Sostituisce TsgcThreadSafeBase (sgcWebSocket_Classes_SyncObjs): un
  // semplice possessore di handle protetto da sezione critica, usato per
  // serializzare l'accesso all'handle SChannel fra il thread del socket e
  // un eventuale thread esterno che chiami Close/Connected in parallelo.
  TzSChannelHandle = class
  private
    FHandle: THandle;
    FCriticalSection: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DoEnterCS;
    procedure DoLeaveCS;
    function TryEnterCS: Boolean;
    property Handle: THandle read FHandle write FHandle;
  end;

  TIdSSLIOHandlerSocketSChannel = class(TIdSSLIOHandlerSocketBase)
  private
    FALPNProtocols: TStringList;
    FOnCredentials: TCredentialsEvent;
    FCertificate: TsgcSChannelCertificate;
    FCipherList: string;
    FSSL: TzSChannelHandle;
    FTLSVersion: TzSChannelTlsVersione;
    // Riferimento alle credenziali del canale di controllo (SSLCondividiSessione)
    // e suo nome del server, preso da Clone: il canale dati FTPS li usa per
    // riprenderne la sessione TLS. 0 e '' per un handler non clonato.
    FSessioneCondivisa: THandle;
    FNomeServerCondiviso: string;
    procedure SetCredentials(aValue: TCredentialsEvent);
    procedure ConnectSSL;
    procedure CloseSSL;
    function GetALPNProtocols: TStringList;
    function GetSSL: TzSChannelHandle;
    function GetTargetHost: string;
    procedure SetALPNProtocols(const Value: TStringList);
    procedure SetCertificate(const Value: TsgcSChannelCertificate);
  protected
    property SSL: TzSChannelHandle read GetSSL write FSSL;
    procedure SetPassThrough(const Value: Boolean); override;
    function RecvEnc(var ABuffer: TIdBytes): Integer; override;
    function SendEnc(const ABuffer: TIdBytes; const AOffset, ALength: Integer)
      : Integer; override;
    procedure ConnectClient; override;
  public
    constructor Create(aOwner: TComponent); reintroduce;
    destructor Destroy; override;
  public
    function Clone: TIdSSLIOHandlerSocketBase; override;
    procedure StartSSL; override;
    procedure Close; override;
    function Connected: Boolean; override;
    function Readable(AMSec: Integer = IdTimeoutDefault): Boolean; override;
    function GetALPNProtocol: String;
    function GetInfo: TsgcSChannelConnectionInfo;
    // True se la sessione TLS in corso e' la ripresa di una precedente (sul
    // canale dati FTPS: quella del canale di controllo)
    function SessioneRipresa: Boolean;
    property OnCredentials: TCredentialsEvent read FOnCredentials
      write SetCredentials;
  public
    property ALPNProtocols: TStringList read GetALPNProtocols
      write SetALPNProtocols;
    property Certificate: TsgcSChannelCertificate read FCertificate
      write SetCertificate;
    property CipherList: string read FCipherList write FCipherList;
    property TLSVersion: TzSChannelTlsVersione read FTLSVersion
      write FTLSVersion;
  end;

implementation

uses
  Winsock,
  zNet.Tls;

const
  // Timeout di lettura/scrittura sul socket cifrato quando ReadTimeout non
  // ne indica uno: lo stesso valore di IdSSLOpenSSL.OpenEncodedConnection
  CS_TIMEOUT_SOCKET_PREDEFINITO = 30000;

{ TzSChannelHandle }

constructor TzSChannelHandle.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TzSChannelHandle.Destroy;
begin
  FreeAndNil(FCriticalSection);
  inherited;
end;

procedure TzSChannelHandle.DoEnterCS;
begin
  FCriticalSection.Enter;
end;

procedure TzSChannelHandle.DoLeaveCS;
begin
  FCriticalSection.Leave;
end;

function TzSChannelHandle.TryEnterCS: Boolean;
begin
  Result := FCriticalSection.TryEnter;
end;

{ TIdSSLIOHandlerSocketSChannel }

function TIdSSLIOHandlerSocketSChannel.Clone: TIdSSLIOHandlerSocketBase;
var
  Handler: TIdSSLIOHandlerSocketSChannel;
begin
  // Mantis: corretto rispetto all'originale sgc, che restituiva
  // un'istanza con i soli valori di default. TIdFTP chiama Clone per il
  // canale dati (ftpdpsPrivate): senza propagare TLSVersion/Certificate/
  // CipherList il canale dati userebbe valori diversi da quelli del canale
  // di controllo.
  //
  // Ripresa della sessione TLS (29/9/2026): molti server FTPS (il Synology
  // del collaudo, vsftpd con require_ssl_reuse, ProFTPD) rifiutano un canale
  // dati che non riprende la sessione del canale di controllo. IdSSLOpenSSL
  // la riprende con SSL_copy_session_id; in Schannel la ripresa avviene se
  // la connessione nuova usa lo stesso handle di credenziali e lo stesso
  // nome del server (documentazione di InitializeSecurityContext
  // (Schannel)). Il clone prende quindi un riferimento alle credenziali del
  // canale di controllo e il suo nome del server: cosi' si risolve anche il
  // vecchio limite per cui il canale dati usava come nome del server
  // l'indirizzo IP della risposta PASV/EPSV (issue #8 di
  // Execute.IdSSLSChannel, sezione 7.5 dell'analisi).
  Handler := TIdSSLIOHandlerSocketSChannel.Create(nil);
  Handler.TLSVersion := TLSVersion;
  Handler.CipherList := CipherList;
  Handler.Certificate.Assign(Certificate);
  Handler.ALPNProtocols.Assign(ALPNProtocols);
  if not Passthrough then
  begin
    SSL.DoEnterCS;
    Try
      if SSL.Handle <> 0 then
        Handler.FSessioneCondivisa := SSLCondividiSessione(SSL.Handle,
          Handler.FNomeServerCondiviso);
    Finally
      SSL.DoLeaveCS;
    End;
  end;
  Result := Handler;
end;

procedure TIdSSLIOHandlerSocketSChannel.CloseSSL;
begin
  // FSSL e non la proprieta' SSL: dal distruttore FSSL puo' essere gia'
  // liberato, e la proprieta' ne creerebbe uno nuovo solo per chiuderlo
  if not Assigned(FSSL) then
    Exit;
  FSSL.DoEnterCS;
  Try
    if FSSL.Handle <> 0 then
    begin
      Try
        SSLClose(FSSL.Handle);
      Finally
        FSSL.Handle := 0;
      End;
    end;
  Finally
    FSSL.DoLeaveCS;
  End;
end;

procedure TIdSSLIOHandlerSocketSChannel.Close;
begin
  // close_notify al server prima di chiudere il socket, come SSL_shutdown
  // di TIdSSLIOHandlerSocketOpenSSL.Close. Solo se nessun altro thread sta
  // usando la connessione: un thread fermo in lettura tiene la sezione
  // critica, e aspettarlo bloccherebbe proprio la chiusura del socket che
  // deve sbloccarlo. In quel caso si chiude senza close_notify, come prima.
  if (not Passthrough) and BindingAllocated and Assigned(FSSL) and
    FSSL.TryEnterCS then
  begin
    Try
      if FSSL.Handle <> 0 then
        SSLInviaChiusura(FSSL.Handle);
    Finally
      FSSL.DoLeaveCS;
    End;
  end;
  inherited;
  // chiudere prima il socket, poi liberare gli oggetti
  CloseSSL;
end;

procedure TIdSSLIOHandlerSocketSChannel.ConnectClient;
var
  LPassThrough: Boolean;
begin
  LPassThrough := fPassThrough;
  fPassThrough := True;
  try
    inherited ConnectClient;
  finally
    fPassThrough := LPassThrough;
  end;
  StartSSL;
end;

function TIdSSLIOHandlerSocketSChannel.Connected: Boolean;
begin
  if Passthrough then
    Result := inherited Connected
  else
  begin
    SSL.DoEnterCS;
    Try
      Result := SSL.Handle <> 0;
    Finally
      SSL.DoLeaveCS;
    End;
  end;
end;

function TIdSSLIOHandlerSocketSChannel.Readable(AMSec: Integer): Boolean;
begin
  // Come TIdSSLIOHandlerSocketOpenSSL.Readable: prima quello che il motore
  // puo' consegnare senza toccare il socket (dati gia' decifrati, record gia'
  // ricevuti, chiusura del server), poi la select di Indy sul socket con la
  // sua semantica dei tempi (0 = sola verifica, IdTimeoutInfinite = attesa
  // senza limite). Indy chiama Readable(0) e Readable(100) per sondare la
  // connessione (CheckForDataOnSource in TIdFTP.DisconnectNotifyPeer) e
  // l'originale, con AMSec = 0, restava fermo in una recv.
  // La chiusura del server risponde True: la lettura che segue restituisce
  // 0 byte e Indy chiude in modo ordinato. Con False, ReadFromSource la
  // prende per un timeout e ReadLn con attesa illimitata ricomincia senza
  // fine.
  // La select fuori dalla sezione critica: puo' attendere, e nel frattempo
  // Close da un altro thread deve poter entrare.
  SSL.DoEnterCS;
  Try
    if (SSL.Handle <> 0) and not Passthrough and SSLDatiInAttesa(SSL.Handle) then
      Exit(True);
  Finally
    SSL.DoLeaveCS;
  End;
  Result := inherited Readable(AMSec);
end;

function TIdSSLIOHandlerSocketSChannel.RecvEnc(var ABuffer: TIdBytes): Integer;
begin
  Result := 0;

  SSL.DoEnterCS;
  Try
    if SSL.Handle <> 0 then
      Result := SSLRead(SSL.Handle, ABuffer[0], Length(ABuffer));
  Finally
    SSL.DoLeaveCS;
  End;
  // ... evita l'errore 10004 (chiamata di sistema interrotta)
  if Result = CS_SChannel_ERROR_INTERRUPTED_SYSTEM_CALL * (-1) then
    Result := 0;
end;

function TIdSSLIOHandlerSocketSChannel.SendEnc(const ABuffer: TIdBytes;
  const AOffset, ALength: Integer): Integer;
var
  vOfs: Integer;
  vLen: Integer;
  vCnt: Integer;
begin
  vOfs := AOffset;
  vLen := ALength;
  while vLen > 0 do
  begin
    SSL.DoEnterCS;
    Try
      vCnt := 0;
      if SSL.Handle <> 0 then
        vCnt := SSLWrite(SSL.Handle, ABuffer[vOfs], vLen);
    Finally
      SSL.DoLeaveCS;
    End;
    if vCnt <= 0 then
    begin
      Result := vCnt;
      Exit;
    end;
    Inc(vOfs, vCnt);
    Dec(vLen, vCnt);
  end;
  Result := vOfs - AOffset;
end;

procedure DoCredentials(SSL: THandle; UserData: Pointer);
begin
  with TIdSSLIOHandlerSocketSChannel(UserData) do
  begin
    if Assigned(FOnCredentials) then
      FOnCredentials(TIdSSLIOHandlerSocketSChannel(UserData));
  end;
end;

constructor TIdSSLIOHandlerSocketSChannel.Create(aOwner: TComponent);
begin
  inherited;
  // Su Windows 11/Server 2022 in su Windows negozia da solo (SCH_CREDENTIALS
  // ignora TLSVersion): il default conta solo su Windows 10 e precedenti,
  // dove SCHANNEL_CRED legacy lo applica alla lettera. tls1_0 (default
  // originale sgc) abilita SOLO TLS 1.0: nessun server attuale lo accetta.
  TLSVersion := tls1_2;
  FCertificate := TsgcSChannelCertificate.Create;
end;

destructor TIdSSLIOHandlerSocketSChannel.Destroy;
begin
  // Prima la sessione TLS ancora aperta (contesto e credenziali): l'originale
  // liberava FSSL senza chiuderla, e il Close chiamato poi da
  // TIdIOHandler.Destroy non la trovava piu'.
  CloseSSL;
  if FSessioneCondivisa <> 0 then
  begin
    SSLRilasciaSessione(FSessioneCondivisa);
    FSessioneCondivisa := 0;
  end;
  FreeAndNil(FALPNProtocols);
  FreeAndNil(FCertificate);
  FreeAndNil(FSSL);
  inherited;
end;

procedure TIdSSLIOHandlerSocketSChannel.SetCredentials(aValue: TCredentialsEvent);
begin
  FOnCredentials := aValue;
  SSL.DoEnterCS;
  Try
    if SSL.Handle <> 0 then
    begin
      if Assigned(FOnCredentials) then
        SSLCredentialsCallBack(SSL.Handle, DoCredentials, Self)
      else
        SSLCredentialsCallBack(SSL.Handle, nil, nil);
    end;
  Finally
    SSL.DoLeaveCS;
  End;
end;

procedure TIdSSLIOHandlerSocketSChannel.SetPassThrough(const Value: Boolean);
begin
  if fPassThrough <> Value then
  begin
    if not Value then
    begin
      if BindingAllocated then
      begin
        ConnectSSL;
      end;
    end;
    fPassThrough := Value;
  end;
end;

procedure TIdSSLIOHandlerSocketSChannel.StartSSL;
begin
  if not Passthrough then
    ConnectSSL;
end;

procedure TIdSSLIOHandlerSocketSChannel.ConnectSSL;
var
  vHost: AnsiString;
  AttesaSocket: Integer;
begin
  vHost := AnsiString(GetTargetHost);

  // Come IdSSLOpenSSL.OpenEncodedConnection: le letture e scritture sul
  // socket cifrato cominciano dopo la select di Indy ma possono dover
  // attendere il resto di un record (o, nell'handshake, la risposta del
  // server). Con un limite, un server che tace diventa un errore di
  // timeout invece di un blocco senza fine.
  AttesaSocket := ReadTimeout;
  if AttesaSocket <= 0 then
    AttesaSocket := CS_TIMEOUT_SOCKET_PREDEFINITO;
  Winsock.setsockopt(Binding.Handle, Winsock.SOL_SOCKET, Winsock.SO_RCVTIMEO,
    PAnsiChar(@AttesaSocket), SizeOf(AttesaSocket));
  Winsock.setsockopt(Binding.Handle, Winsock.SOL_SOCKET, Winsock.SO_SNDTIMEO,
    PAnsiChar(@AttesaSocket), SizeOf(AttesaSocket));

  SSL.DoEnterCS;
  Try
    // FSessioneCondivisa <> 0 solo sul clone (canale dati FTPS): riprende la
    // sessione del canale di controllo
    SSL.Handle := SSLStart(Binding.Handle, Certificate, vHost, TLSVersion,
      ALPNProtocols, CipherList, FSessioneCondivisa);
    if SSL.Handle = 0 then
      raise SChannelError.Create('SChannel initialization error: ' + vMsgError,
        CertStatus);
    if Assigned(FOnCredentials) then
      SSLCredentialsCallBack(SSL.Handle, DoCredentials, Self);
  Finally
    SSL.DoLeaveCS;
  End;
end;

function TIdSSLIOHandlerSocketSChannel.GetALPNProtocol: String;
begin
  SSL.DoEnterCS;
  Try
    Result := GetALPN(SSL.Handle);
  Finally
    SSL.DoLeaveCS;
  End;
end;

function TIdSSLIOHandlerSocketSChannel.GetALPNProtocols: TStringList;
begin
  if not Assigned(FALPNProtocols) then
    FALPNProtocols := TStringList.Create;
  Result := FALPNProtocols;
end;

function TIdSSLIOHandlerSocketSChannel.GetInfo: TsgcSChannelConnectionInfo;
begin
  SSL.DoEnterCS;
  Try
    Result := nil;
    if SSL.Handle <> 0 then
      Result := zNet.Tls.SChannel.Engine.GetConnectionInfo(SSL.Handle);
  Finally
    SSL.DoLeaveCS;
  End;
end;

function TIdSSLIOHandlerSocketSChannel.SessioneRipresa: Boolean;
begin
  SSL.DoEnterCS;
  Try
    Result := (SSL.Handle <> 0) and SSLSessioneRipresa(SSL.Handle);
  Finally
    SSL.DoLeaveCS;
  End;
end;

function TIdSSLIOHandlerSocketSChannel.GetSSL: TzSChannelHandle;
begin
  if not Assigned(FSSL) then
    FSSL := TzSChannelHandle.Create;
  Result := FSSL;
end;

function TIdSSLIOHandlerSocketSChannel.GetTargetHost: string;
var
  oURI: TIdURI;
  oTransparentProxy, oNextTransparentProxy: TIdCustomTransparentProxy;
begin
  // Clone del canale di controllo (canale dati FTPS): lo stesso nome del
  // server di quel canale, non l'indirizzo IP della risposta PASV. E' anche
  // la chiave con cui Schannel ritrova la sessione da riprendere.
  if FNomeServerCondiviso <> '' then
  begin
    Result := FNomeServerCondiviso;
    Exit;
  end;

  Result := '';

  if URIToCheck <> '' then
  begin
    oURI := TIdURI.Create(URIToCheck);
    try
      Result := oURI.Host;
    finally
      oURI.Free;
    end;
    if Result <> '' then
      Exit;
  end;

  oTransparentProxy := FTransparentProxy;
  if Assigned(oTransparentProxy) then
  begin
    if oTransparentProxy.Enabled then
    begin
      repeat
        oNextTransparentProxy := oTransparentProxy.ChainedProxy;
        if not Assigned(oNextTransparentProxy) then
          Break;
        if not oNextTransparentProxy.Enabled then
          Break;
        oTransparentProxy := oNextTransparentProxy;
      until False;
      Result := oTransparentProxy.Host;
      if Result <> '' then
        Exit;
    end;
  end;

  Result := Host;
end;

procedure TIdSSLIOHandlerSocketSChannel.SetALPNProtocols(const Value: TStringList);
begin
  if Assigned(FALPNProtocols) then
    FALPNProtocols.Assign(Value);
end;

procedure TIdSSLIOHandlerSocketSChannel.SetCertificate(const Value: TsgcSChannelCertificate);
begin
  if Assigned(FCertificate) then
    FCertificate.Assign(Value);
end;

{ SChannelError }

constructor SChannelError.Create(AMsg: string; AStatus: Cardinal);
begin
  CertStatus := AStatus;
  inherited Create(AMsg);
end;

// Traduzione fra la versione TLS del provider (TzTlsVersione, zNet.Tls) e
// quella del motore SChannel (TzSChannelTlsVersione). tlsVersioneDefault
// mappa su tls1_2: la scelta piu' alta accettata alla lettera anche su
// Windows 10 legacy (vedi commento al costruttore); su Windows 11/Server
// 2022 in su non cambia nulla, perche' la versione e' comunque ignorata.
function TraduciVersione(Versione: TzTlsVersione): TzSChannelTlsVersione;
begin
  case Versione of
    tlsVersione1_0:
      Result := tls1_0;
    tlsVersione1_1:
      Result := tls1_1;
    tlsVersione1_3:
      Result := tls1_3;
  else
    Result := tls1_2;
  end;
end;

function CreaIOHandlerSChannel(Proprietario: TComponent; Versione: TzTlsVersione; VerificaCertificato: Boolean): TIdSSLIOHandlerSocketBase;
var
  Handler: TIdSSLIOHandlerSocketSChannel;
begin
  Handler := TIdSSLIOHandlerSocketSChannel.Create(Proprietario);
  try
    Handler.TLSVersion := TraduciVersione(Versione);

    // SChannel usa l'archivio certificati di Windows: nessun archivio di
    // radici da distribuire con l'applicazione, a differenza del provider
    // OpenSSL (vedi zNet.Tls.OpenSsl.CreaIOHandlerOpenSsl).
    Handler.Certificate.VerifyCertificate := VerificaCertificato;
  except
    Handler.Free;
    raise;
  end;

  Result := Handler;
end;

initialization

// Codice 'SCHANNEL': e' il valore che la configurazione dell'installazione
// deve passare a zNet.Tls.SelezionaProviderTls per attivare questo motore.
// Nessuna libreria da individuare (SChannel usa il TLS di Windows): ultimo
// parametro omesso, come previsto da zNet.Tls (l'aggancio e' facoltativo).
RegistraProviderTls('SCHANNEL', 'SChannel (Windows secur32.dll/crypt32.dll)', CreaIOHandlerSChannel);

end.
