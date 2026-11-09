// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-29
// ---------------------------------------------------------------------------
unit zNet.Tls.SChannel.Engine;

// Motore TLS via SChannel (secur32.dll/crypt32.dll di Windows): credenziali,
// handshake, lettura/scrittura cifrata, verifica del certificato. Nessuna
// dipendenza da OpenSSL o da altre DLL di terze parti.
//
// Portata da sgcSSL_SChannel.pas (sgcWebSockets Enterprise Single 2023.8.0,
// licenza Softline S.r.l.) come previsto dalla sezione 7.4 dell'analisi
// "Eliminazione Dipendenza OpenSSL In Gesty E WinTarif". Il file originale
// dipende solo da sgcSSL_WinSSPI (qui zNet.Tls.SChannel.WinApi, copiata
// senza modifiche funzionali) e da sgcWebSocket_Types per il solo tipo
// TwsTLSVersions, qui sostituito dal tipo proprio TzSChannelTlsVersione
// (stessi nomi di valore: tlsUndefined, tls1_0, tls1_1, tls1_2, tls1_3).
// Le utility sgcFree/sgcMove diventano FreeAndNil/Move della RTL.
// Tolti i rami per compilatori piu' vecchi di RAD Studio 10.3 Rio (D7,
// Lazarus) e il ramo non-pointer-math: il pointer math e' sempre disponibile
// da Delphi 2010 in poi, quindi resta attivo senza condizione.
//
// Difetto noto dell'originale, corretto qui: Clone (in
// zNet.Tls.SChannel.pas, l'handler Indy) non copiava TLSVersion, Certificate
// ne' CipherList sull'istanza clonata, usata da TIdFTP per il canale dati
// (ftpdpsPrivate). Qui il motore resta identico all'originale: la
// correzione sta nell'handler, non nel motore.
//
// Aggiunta dell'8/9/2026, non presente nell'originale sgc: verifica del
// certificato piu' granulare (TzSChannelCertCheckIgnoreFlags, esclusioni
// singole invece del solo booleano VerifyCertificate) e pinning per host
// (TzSChannelTrustedCerts). Idea confrontata con CheckServerCert/
// TCertCheckIgnoreFlag di Fr0sT-Brutal Delphi_SChannelTLS (MIT) durante la
// valutazione di quella libreria come alternativa: stessa coppia di API
// Windows che DoVerifyCertificate gia' chiamava (CertGetCertificateChain,
// CertVerifyCertificateChainPolicy), qui riscritta senza copiare codice da
// quella libreria - solo i nomi dei flag standard SECURITY_FLAG_IGNORE_*
// di WinInet/WinHTTP (dichiarati in zNet.Tls.SChannel.WinApi). Non usata da
// nessun chiamante oggi: CreaIOHandlerSChannel in zNet.Tls.SChannel.pas
// passa solo il booleano VerifyCertificate, sempre False nelle chiamate
// attuali di zNet.Tls.CreaIOHandlerTls. Resta disponibile per un uso futuro
// tramite Handler.Certificate.CertCheckIgnoreFlags/TrustedCerts.
//
// Correzioni del 29/9/2026, emerse dal collaudo FTPS verso un Synology (il
// canale dati falliva al primo trasferimento, con OpenSSL no):
// 1. Ripresa della sessione TLS. La cache delle sessioni di Schannel riprende
//    una sessione solo se la connessione nuova usa lo STESSO handle di
//    credenziali e lo stesso nome del server di quella che l'ha negoziata
//    (documentazione di InitializeSecurityContext (Schannel), parametro
//    pszTargetName). Qui ogni connessione acquisiva credenziali proprie,
//    quindi il canale dati FTPS non riprendeva mai la sessione del canale di
//    controllo, che molti server FTPS pretendono. Ora le credenziali sono un
//    oggetto con conteggio dei riferimenti (TzSChannelCredenziali):
//    SSLCondividiSessione ne da' un riferimento con il nome del server,
//    SSLStart lo riusa, e l'handle si libera solo quando nessuna connessione
//    lo usa piu'. E' l'equivalente di SSL_copy_session_id di IdSSLOpenSSL.
// 2. Messaggi TLS 1.3 successivi all'handshake (il biglietto di sessione):
//    DecryptMessage risponde SEC_I_RENEGOTIATE e il messaggio decifrato va
//    passato a InitializeSecurityContext (documentazione di DecryptMessage
//    (Schannel)). L'originale lo accodava ai dati dell'applicazione e poi
//    si fermava in lettura sul socket: senza biglietto, niente ripresa della
//    sessione in TLS 1.3.
// 3. Readable non si blocca piu' quando il chiamante chiede una sola
//    verifica: con timeout 0 l'originale eseguiva una recv bloccante. La
//    chiusura del server (close_notify) ora vale come fine ordinata della
//    connessione (0 byte, come SSL_read), non come errore.
// 4. Chiusura: SSLInviaChiusura manda il close_notify come SSL_shutdown, e
//    il contesto si cancella sempre (l'originale lo faceva solo dopo
//    SEC_E_ILLEGAL_MESSAGE e ne lasciava uno aperto per ogni connessione).
// 5. SendData sottraeva il totale gia' inviato invece dell'ultimo invio
//    parziale, troncando i dati quando send non li spediva tutti in una volta.

interface

{$POINTERMATH ON}

uses
  Classes, SysUtils, Windows, Winsock, System.Types, System.SyncObjs,
  zNet.Tls.SChannel.WinApi;

type
  // Versione TLS richiesta al motore SChannel. tlsUndefined lascia scegliere
  // a Windows la versione piu' alta che conosce (solo su Windows 11/Server
  // 2022 in su: sotto, SCHANNEL_CRED legacy lo traduce in 1.0-1.2, mai 1.3).
  TzSChannelTlsVersione = (tlsUndefined, tls1_0, tls1_1, tls1_2, tls1_3);

  TzSChannelCertStoreName = (scsnMY, scsnRoot, scsnTrust, scsnCA);
  TzSChannelCertStorePath = (scspStoreCurrentUser, scspStoreLocalMachine);

  // Esclusioni singole dalla verifica del certificato, valutate da
  // DoVerifyCertificate. Idea portata da CheckServerCert/TCertCheckIgnoreFlag
  // di Fr0sT-Brutal Delphi_SChannelTLS (MIT): stessa API Windows che questo
  // motore gia' chiama (CertVerifyCertificateChainPolicy con
  // CERT_CHAIN_POLICY_SSL), qui riscritta senza copiare codice da quella
  // libreria - solo i nomi dei flag standard di WinInet/WinHTTP.
  TzSChannelCertCheckIgnoreFlag = (ignRevoca, ignAutoritaSconosciuta,
    ignUsoErrato, ignNomeComuneNonValido, ignDataNonValida);
  TzSChannelCertCheckIgnoreFlags = set of TzSChannelCertCheckIgnoreFlag;

  // Elenco di certificati considerati fidati a prescindere dalla catena di
  // attendibilita' (pinning): se il certificato del server e' in elenco per
  // quell'host, DoVerifyCertificate lo accetta senza altre verifiche. Thread
  // safe: la stessa istanza puo' essere condivisa fra piu' handler (per
  // esempio piu' connessioni verso lo stesso servizio) senza sincronizzarla
  // a mano.
  TzSChannelTrustedCerts = class
  strict private
    FCriticalSection: TCriticalSection;
    FCerti: array of record
      Host: string;
      Dati: TBytes;
    end;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Aggiungi(const Host: string; const Dati: TBytes);
    function Contiene(const Host: string; Dati: Pointer; DimensioneDati: Integer): Boolean;
    procedure Svuota;
  end;

  TSSLValidator = class
  public
    constructor Create;
    destructor Destroy; override;
    function ValidateChain(Chain: PCCERT_CHAIN_CONTEXT;
      var Status: CERT_CHAIN_POLICY_STATUS): Boolean; virtual;
    function ValidateElement(Element: PCERT_CHAIN_ELEMENT): Boolean; virtual;
  end;

  TsgcSChannelConnectionInfo = class
  private
    FCiperStrength: Cardinal;
    FCipher: String;
    FCipherId: Cardinal;
    FExchange: string;
    FExchangeId: Cardinal;
    FExchangeStrength: Cardinal;
    FHash: string;
    FHashId: Cardinal;
    FHashStrength: Cardinal;
    FProtocol: TzSChannelTlsVersione;
  protected
    procedure SetProtocol(aValue: Cardinal); virtual;
    procedure SetCipher(aValue: Cardinal); virtual;
    procedure SetHash(aValue: Cardinal); virtual;
    procedure SetExchange(aValue: Cardinal); virtual;
  protected
    property HashId: Cardinal read FHashId write FHashId;
    property CipherId: Cardinal read FCipherId write FCipherId;
    property ExchangeId: Cardinal read FExchangeId write FExchangeId;
  public
    property CiperStrength: Cardinal read FCiperStrength write FCiperStrength;
    property Cipher: String read FCipher write FCipher;
    property Exchange: string read FExchange write FExchange;
    property ExchangeStrength: Cardinal read FExchangeStrength
      write FExchangeStrength;
    property Hash: string read FHash write FHash;
    property HashStrength: Cardinal read FHashStrength write FHashStrength;
    property Protocol: TzSChannelTlsVersione read FProtocol write FProtocol;
  end;

  TsgcSChannelCertificate = class(TPersistent)
  private
    FCertFilePassword: string;
    FCertHash: String;
    FCertFile: String;
    FCertStoreName: TzSChannelCertStoreName;
    FCertStorePath: TzSChannelCertStorePath;
    FVerifyCertificate: Boolean;
    FCertCheckIgnoreFlags: TzSChannelCertCheckIgnoreFlags;
    FTrustedCerts: TzSChannelTrustedCerts;
  public
    procedure Assign(aSource: TPersistent); override;
  public
    property CertFilePassword: string read FCertFilePassword
      write FCertFilePassword;
    property CertHash: String read FCertHash write FCertHash;
    property CertFile: String read FCertFile write FCertFile;
    property CertStoreName: TzSChannelCertStoreName read FCertStoreName
      write FCertStoreName;
    property CertStorePath: TzSChannelCertStorePath read FCertStorePath
      write FCertStorePath;
    property VerifyCertificate: Boolean read FVerifyCertificate
      write FVerifyCertificate;
    // Esclusioni granulari dalla verifica (revoca, autorita' sconosciuta,
    // uso errato, nome comune non valido, certificato scaduto). Applicate
    // solo se VerifyCertificate = True.
    property CertCheckIgnoreFlags: TzSChannelCertCheckIgnoreFlags
      read FCertCheckIgnoreFlags write FCertCheckIgnoreFlags;
    // Elenco di certificati fidati a prescindere dalla catena (pinning).
    // Riferimento, non posseduto: il chiamante crea e libera l'istanza,
    // eventualmente condivisa fra piu' handler. nil (default) = nessun
    // pinning, si applica solo la verifica ordinaria della catena.
    property TrustedCerts: TzSChannelTrustedCerts read FTrustedCerts
      write FTrustedCerts;
  end;

  TsgcSChannelStream = class
  private
    FData: PByte;
    FDataSize: Integer;
  protected
    procedure DoFinalize;
    procedure DoInitialize(aSize: Integer);
  public
    destructor Destroy; override;
  public
    procedure LoadFromStream(const aSource: TStream);
    procedure LoadFromFile(const aFileName: String);
  public
    property Data: PByte read FData;
    property DataSize: Integer read FDataSize;
  end;

  TCredentialsCallBack = procedure(SSL: THandle; UserData: Pointer);

var
  secur32: THandle;

function SSLAvailable: Boolean;
// aSessione: riferimento ottenuto da SSLCondividiSessione su un'altra
// connessione (0 = credenziali nuove). Con un riferimento la connessione usa
// le credenziali di quella, e Schannel ne riprende la sessione se anche Host
// e' lo stesso nome del server.
function SSLStart(aSocket: TSocket; aCertificate: TsgcSChannelCertificate;
    const Host: AnsiString = ''; aVersion: TzSChannelTlsVersione = tls1_0;
    aALPNProtocols: TStrings = nil; aCipherList: String = '';
    aSessione: THandle = 0): THandle;
procedure SSLCredentialsCallBack(SSL: THandle; CallBack: TCredentialsCallBack;
  UserData: Pointer);
// AMSec < 0 attende i dati senza limite; >= 0 attesa massima in ms, 0 = sola
// verifica.
function SSLPending(SSL: THandle; AMSec: Integer): Boolean;
// True se c'e' qualcosa da consegnare senza leggere dal socket: dati gia'
// decifrati, un record gia' ricevuto che ne contiene, la chiusura del server
// o un errore da riportare. Non si blocca mai.
function SSLDatiInAttesa(SSL: THandle): Boolean;
// Manda il close_notify al server (chiusura ordinata della sessione TLS).
// Va chiamata prima di chiudere il socket.
function SSLInviaChiusura(SSL: THandle): Boolean;
// Riferimento alle credenziali della connessione, con il nome del server da
// usare per riprenderne la sessione. 0 se la connessione non ha credenziali.
// Ogni riferimento ottenuto va restituito con SSLRilasciaSessione.
function SSLCondividiSessione(SSL: THandle; out NomeServer: string): THandle;
procedure SSLRilasciaSessione(Sessione: THandle);
// True se l'handshake ha ripreso una sessione precedente invece di
// negoziarne una nuova (SECPKG_ATTR_SESSION_INFO, SSL_SESSION_RECONNECT).
// Serve alla diagnosi del canale dati FTPS.
function SSLSessioneRipresa(SSL: THandle): Boolean;
function SSLRead(SSL: THandle; var Data; Size: Integer): Integer;
function SSLWrite(SSL: THandle; var Data; Size: Integer): Integer;
function SSLClose(SSL: THandle): Integer;
function GetALPN(SSL: THandle): String;
function GetConnectionInfo(SSL: THandle): TsgcSChannelConnectionInfo;

var
  CertStatus: Cardinal;
  vMsgError: string;
  oError: HRESULT;

const
  CS_SChannel_Ciphers: Array [0 .. 49] of String = ('CALG_3DES',
    'CALG_3DES_112', 'CALG_AES', 'CALG_AES_128', 'CALG_AES_192', 'CALG_AES_256',
    'CALG_AGREEDKEY_ANY', 'CALG_CYLINK_MEK', 'CALG_DES', 'CALG_DESX',
    'CALG_DH_EPHEM', 'CALG_DH_SF', 'CALG_DSS_SIGN', 'CALG_ECDH',
    'CALG_ECDH_EPHEM', 'CALG_ECDSA', 'CALG_ECMQV', 'CALG_HASH_REPLACE_OWF',
    'CALG_HUGHES_MD5', 'CALG_HMAC', 'CALG_KEA_KEYX', 'CALG_MAC', 'CALG_MD2',
    'CALG_MD4', 'CALG_MD5', 'CALG_NO_SIGN', 'CALG_OID_INFO_CNG_ONLY',
    'CALG_OID_INFO_PARAMETERS', 'CALG_PCT1_MASTER', 'CALG_RC2', 'CALG_RC4',
    'CALG_RC5', 'CALG_RSA_KEYX', 'CALG_RSA_SIGN', 'CALG_SCHANNEL_ENC_KEY',
    'CALG_SCHANNEL_MAC_KEY', 'CALG_SCHANNEL_MASTER_HASH', 'CALG_SEAL',
    'CALG_SHA', 'CALG_SHA1', 'CALG_SHA_256', 'CALG_SHA_384', 'CALG_SHA_512',
    'CALG_SKIPJACK', 'CALG_SSL2_MASTER', 'CALG_SSL3_MASTER', 'CALG_SSL3_SHAMD5',
    'CALG_TEK', 'CALG_TLS1_MASTER', 'CALG_TLS1PRF');

  CS_SChannel_CiphersId: Array [0 .. 49] of Cardinal = ($00006603, $00006609,
    $00006611, $0000660E, $0000660F, $00006610, $0000AA03, $0000660C, $00006601,
    $00006604, $0000AA02, $0000AA01, $00002200, $0000AA05, $0000AE06, $00002203,
    $0000A001, $0000800B, $0000A003, $00008009, $0000AA04, $00008005, $00008001,
    $00008002, $00008003, $00002000, $FFFFFFFF, $FFFFFFFE, $00004C04, $00006602,
    $00006801, $0000660D, $0000A400, $00002400, $00004C07, $00004C03, $00004C02,
    $00006802, $00008004, $00008004, $0000800C, $0000800D, $0000800E, $0000660A,
    $00004C05, $00004C01, $00008008, $0000660B, $00004C06, $0000800A);

const
  CS_SChannel_ERROR_INTERRUPTED_SYSTEM_CALL = 10004;

implementation

const
  CS_IO_BUFFER_SIZE = $10000;

type
  CRYPT_HASH_BLOB = record
    cbData: DWORD;
    pbData: PByte;
  end;

var
  oValidators: TList;
  vInitialized: Boolean;
  oSSPI: PSecurityFunctionTable;
  oMyStore: HCERTSTORE;
  vIsLegacyDone: Boolean = False;
  vIsLegacy: Boolean = False;

function IsLegacy(aVersion: Integer = 10; aBuild: Integer = 20348): Boolean;
var
  vInfoSize: Cardinal;
  vValueSize: Cardinal;
  vDummy: Cardinal;
  oVerInfo: Pointer;
  oVerValue: PVSFixedFileInfo;
  vPath: string;
begin
  if not vIsLegacyDone then
  begin
    vPath := GetEnvironmentVariable('windir') + '\system32\ntoskrnl.exe';
    vInfoSize := GetFileVersionInfoSize(PChar(vPath), vDummy);
    GetMem(oVerInfo, vInfoSize);
    try
      if GetFileVersionInfo(PChar(vPath), 0, vInfoSize, oVerInfo) then
      begin
        if VerQueryValue(oVerInfo, '\', Pointer(oVerValue), vValueSize) then
        begin
          if HiWord(oVerValue^.dwFileVersionMS) < aVersion then
            vIsLegacy := True
          else if (HiWord(oVerValue^.dwFileVersionMS) = aVersion) and
            (HiWord(oVerValue^.dwFileVersionLS) < aBuild) then
            vIsLegacy := True;
        end;
      end;
    finally
      FreeMem(oVerInfo, vInfoSize);
    end;

    vIsLegacyDone := True;
  end;

  Result := vIsLegacy;
end;

function GetCertStoreName(aValue: TzSChannelCertStoreName): string;
begin
  Result := '';
  case aValue of
    scsnMY:
      Result := 'MY';
    scsnRoot:
      Result := 'Root';
    scsnTrust:
      Result := 'Trust';
    scsnCA:
      Result := 'CA';
  end;
end;

function GetCertStorePath(aValue: TzSChannelCertStorePath): DWORD;
begin
  Result := 0;
  case aValue of
    scspStoreCurrentUser:
      Result := CERT_SYSTEM_STORE_CURRENT_USER;
    scspStoreLocalMachine:
      Result := CERT_SYSTEM_STORE_LOCAL_MACHINE;
  end;
end;

procedure FreeValidators;
var
  i: Integer;
begin
  if oValidators = nil then
    Exit;
  for i := oValidators.Count - 1 downto 0 do
    TSSLValidator(oValidators[i]).Free;
  FreeAndNil(oValidators);
end;

function Validate(Chain: PCCERT_CHAIN_CONTEXT;
  var Status: CERT_CHAIN_POLICY_STATUS): Boolean;
var
  i: Integer;
begin
  Result := True;
  if oValidators <> nil then
  begin
    for i := oValidators.Count - 1 downto 0 do
    begin
      if TSSLValidator(oValidators[i]).ValidateChain(Chain, Status) then
        Exit;
    end;
  end;
  Result := False;
end;

{ TSSLValidator }

constructor TSSLValidator.Create;
begin
  inherited;
  if oValidators = nil then
    oValidators := TList.Create;
  oValidators.Add(Self);
end;

destructor TSSLValidator.Destroy;
begin
  oValidators.Remove(Self);
  inherited;
end;

function TSSLValidator.ValidateChain(Chain: PCCERT_CHAIN_CONTEXT;
  var Status: CERT_CHAIN_POLICY_STATUS): Boolean;
begin
  Result := False;
  if Status.dwError <> CERT_E_UNTRUSTEDROOT then
    Exit;
  if (Status.lChainIndex < 0) or (DWORD(Status.lChainIndex) > Chain.cChain) then
    Exit;
  if (Status.lElementIndex < 0) or
    (DWORD(Status.lElementIndex) > Chain.rgpChain[Status.lChainIndex].cElement)
  then
    Exit;
  Result := ValidateElement(Chain.rgpChain[Status.lChainIndex].rgpElement
    [Status.lElementIndex]);
end;

function TSSLValidator.ValidateElement(Element: PCERT_CHAIN_ELEMENT): Boolean;
begin
  Result := False;
end;

function SendData(Socket: TSocket; Data: PByte; Size: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  while Size > 0 do
  begin
    i := send(Socket, Data[Result], Size, 0);
    if i <= 0 then
    begin
      oError := 0;
      vMsgError := 'send returns ' + IntToStr(WSAGetLastError);
      Result := i;
      Exit;
    end;
    Inc(Result, i);
    Dec(Size, i);
  end;
end;

function SendSecBuffer(Socket: TSocket; var Buffer: TSecBuffer): Boolean;
begin
  Result := True;
  if (Buffer.cbBuffer > 0) and (Buffer.pvBuffer <> nil) then
  begin
    if SendData(Socket, PByte(Buffer.pvBuffer), Buffer.cbBuffer) <= 0 then
    begin
      Result := False;
      Exit;
    end;
    oSSPI.FreeContextBuffer(Buffer.pvBuffer);
    Buffer.pvBuffer := nil;
  end;
end;

const
  // Richieste a InitializeSecurityContext, uguali in tutte le chiamate
  CS_ISC_FLAGS = ISC_REQ_SEQUENCE_DETECT or ISC_REQ_REPLAY_DETECT or
    ISC_REQ_CONFIDENTIALITY or ISC_RET_EXTENDED_ERROR or
    ISC_REQ_ALLOCATE_MEMORY or ISC_REQ_STREAM;

type
  // Handle di credenziali SChannel con conteggio dei riferimenti. La cache
  // delle sessioni di Schannel riprende una sessione solo se la connessione
  // nuova usa lo stesso handle di credenziali (e lo stesso nome del server)
  // di quella che l'ha negoziata: per il canale dati FTPS l'handle del canale
  // di controllo va quindi condiviso, e liberato solo quando nessuna delle
  // connessioni lo usa piu', in qualunque ordine si chiudano.
  TzSChannelCredenziali = class
  private
    FHandle: TCredHandle;
    FRiferimenti: Integer;
  public
    constructor Create(const Handle: TCredHandle);
    procedure Aggiungi;
    procedure Rilascia;
    property Handle: TCredHandle read FHandle;
  end;

constructor TzSChannelCredenziali.Create(const Handle: TCredHandle);
begin
  inherited Create;
  FHandle := Handle;
  FRiferimenti := 1;
end;

procedure TzSChannelCredenziali.Aggiungi;
begin
  AtomicIncrement(FRiferimenti);
end;

procedure TzSChannelCredenziali.Rilascia;
begin
  if AtomicDecrement(FRiferimenti) = 0 then
  begin
    oSSPI.FreeCredentialsHandle(@FHandle);
    Free;
  end;
end;

type
  TSSLInit = set of (iCredentials, iContext);

  TSSLInfo = record
    Init: TSSLInit;
    Error: Cardinal;
    // CredentialsHandle
    CredentialsCallBack: TCredentialsCallBack;
    UserData: Pointer;
    // Socket connesso
    Socket: TSocket;
    // Nome del server remoto
    Servername: string;
    // Credenziali
    CredentialsPtr: Pointer;
    CredentialsLegacy: SCHANNEL_CRED;
    Credentials: SCH_CREDENTIALS;
    // Algoritmi e parametri TLS puntati da CredentialsLegacy/Credentials.
    // Stanno qui e non in variabili locali di Start perche'
    // AcquireCredentialsHandle si richiama anche dopo Start, quando il
    // server chiede il certificato del client (DoGetCertificate e simili):
    // con le variabili locali i puntatori restavano appesi.
    Algoritmi: array of ALG_ID;
    ParametriTls: array of TLS_PARAMETERS;
    // Credenziali possedute o condivise con un'altra connessione;
    // CredentialsHandle ne e' la copia usata nelle chiamate SSPI
    Credenziali: TzSChannelCredenziali;
    // CredentialsHandle
    CredentialsHandle: TCredHandle;
    // Contesto TLS
    Context: TCtxtHandle;
    // Dati ricevuti dal socket (cifrati)
    RecvBuffer: array of AnsiChar;
    RecvCount: Integer;
    // RecvBuffer contiene un record incompleto: servono altri byte dal socket
    // prima di poterlo decifrare
    RecvIncompleto: Boolean;
    // Il server ha chiuso la sessione TLS (close_notify)
    Chiusa: Boolean;
    // Errore di decifratura irreversibile: la connessione non e' piu' usabile
    Guasta: Boolean;
    // Dati decifrati
    DataBuffer: array of AnsiChar;
    DataCount: Integer;
    DataStart: Integer;
    // Buffer di uscita
    BuffSizes: TSecPkgContextStreamSizes;
    SendBuffer: array of Byte;
    // versione
    Version: TzSChannelTlsVersione;
    // buffer alpn
    ALPNProtocols: TStrings;
    alpn_result: TSecPkgContext_ApplicationProtocol;
    // certificato
    CertVerify: Boolean;
    CertHash: string;
    CertFile: string;
    CertFilePassword: string;
    CertStorePath: TzSChannelCertStorePath;
    CertStoreName: TzSChannelCertStoreName;
    CertCheckIgnoreFlags: TzSChannelCertCheckIgnoreFlags;
    TrustedCerts: TzSChannelTrustedCerts;
    // elenco cifrari
    CipherList: string;
    // info
    ConnectionInfo: TsgcSChannelConnectionInfo;

    procedure Clean;
    procedure SostituisciCredenziali(const Nuove: TCredHandle);
    function GetCipherId(const aCipher: string): Cardinal;
    function Read: Integer;
    function ReadLoop(LeggiPrima: Boolean = True): Integer;
    function InitBuffer: Boolean;
    function DoGetCertificateFromChainStore: Boolean;
    function DoGetCertificate: Boolean;
    function DoImportCertPFX(const aFileName, aPassword: String): Boolean;
    function DoVerifyCertificate: Boolean;
    function SocketLeggibile(Attesa: Integer): Boolean;
    function DecifraBuffer: Integer;
    function ElaboraPostHandshake(const Token: TBytes): Boolean;
    function DatiInAttesa: Boolean;
    function InviaChiusura: Boolean;
    function Readable(aTimeout: Integer = -1): Integer;
    function Decrypt(var Data; Size: Integer): Integer;
    function Encrypt(var Data; Size: Integer): Integer;
    function GetALPN: String;
    function GetConnectionInfo: TsgcSChannelConnectionInfo;
  private
    function Start: Boolean;
  end;

  PSSLInfo = ^TSSLInfo;

function TSSLInfo.Start: Boolean;
var
  WHost: string;
  inBuffers: array [0 .. 0] of TSecBuffer;
  inBuffer: TSecBufferDesc;
  OutBuffers: array [0 .. 0] of TSecBuffer;
  OutBuffer: TSecBufferDesc;
  Flags: DWORD;
  Error: Cardinal;
  i: Integer;
  ALPNBuffer: Array [0 .. 127] of Byte;
  vOffSet: Integer;
  vLength, vLengthTotal: Integer;
  oCiphers: TStringList;
  vCipherId: Cardinal;
begin
  Result := False;

  if Assigned(CredentialsCallBack) then
  begin
    CertCloseStore(oMyStore, 0);
    CredentialsCallBack(THandle(@Self), UserData);
    oMyStore := CertOpenSystemStore(0, 'MY');
    if oMyStore = 0 then
    begin
      oError := 0;
      vMsgError := 'CertOpenSystemStore(0, ''MY'') returns 0';
      Exit;
    end;
  end;

  // ... credenziali legacy
  if IsLegacy then
  begin
    FillChar(CredentialsLegacy, SizeOf(CredentialsLegacy), 0);
    CredentialsLegacy.dwVersion := SCHANNEL_CRED_VERSION;
    case Version of
      tls1_0:
        CredentialsLegacy.grbitEnabledProtocols := SP_PROT_SSL3TLS1;
      tls1_1:
        CredentialsLegacy.grbitEnabledProtocols := SP_PROT_TLS1_1;
      tls1_2, tls1_3:
        CredentialsLegacy.grbitEnabledProtocols := SP_PROT_TLS1_2;
      tlsUndefined:
        CredentialsLegacy.grbitEnabledProtocols :=
          SP_PROT_SSL3TLS1 or SP_PROT_TLS1_1 or SP_PROT_TLS1_2;
    end;
    CredentialsLegacy.dwFlags :=
      SCH_CRED_NO_DEFAULT_CREDS or SCH_CRED_MANUAL_CRED_VALIDATION;

    // elenco cifrari
    CredentialsLegacy.palgSupportedAlgs := nil;
    CredentialsLegacy.cSupportedAlgs := 0;
    if CipherList <> '' then
    begin
      oCiphers := TStringList.Create;
      Try
        oCiphers.Delimiter := ':';
        oCiphers.DelimitedText := CipherList;
        for i := 0 to oCiphers.Count - 1 do
        begin
          vCipherId := GetCipherId(oCiphers[i]);
          if vCipherId > 0 then
          begin
            SetLength(Algoritmi, Length(Algoritmi) + 1);
            Algoritmi[Length(Algoritmi) - 1] := vCipherId;
          end;
        end;

        if Length(Algoritmi) > 0 then
        begin
          CredentialsLegacy.palgSupportedAlgs := @Algoritmi[0];
          CredentialsLegacy.cSupportedAlgs := Length(Algoritmi);
        end;
      Finally
        FreeAndNil(oCiphers);
      End;
    end;

    CredentialsPtr := @CredentialsLegacy;
  end
  else
  // ... sch_credentials
  begin
    FillChar(Credentials, SizeOf(Credentials), 0);
    Credentials.dwVersion := SCH_CREDENTIALS_VERSION;
    Credentials.dwFlags :=
      SCH_CRED_NO_DEFAULT_CREDS or SCH_CRED_MANUAL_CRED_VALIDATION;
    SetLength(ParametriTls, 1);
    // ParametriTls[0].grbitDisabledProtocols := SP_PROT_TLS1_3_CLIENT;
    ParametriTls[0].dwFlags :=
      SCH_CRED_NO_DEFAULT_CREDS or SCH_CRED_MANUAL_CRED_VALIDATION;
    Credentials.cTlsParameters := 1;
    Credentials.pTlsParameters := @ParametriTls[0];

    CredentialsPtr := @Credentials;
  end;

  if Assigned(Credenziali) then
  begin
    // Ripresa della sessione di un'altra connessione (canale dati FTPS):
    // stesso handle di credenziali, gia' acquisito da quella. Le strutture
    // qui sopra servono lo stesso, se il server chiede il certificato del
    // client e le credenziali vanno riacquisite.
    CredentialsHandle := Credenziali.Handle;
  end
  else
  begin
    Error := oSSPI.AcquireCredentialsHandle(nil, UNISP_NAME,
      SECPKG_CRED_OUTBOUND, nil, CredentialsPtr, nil, nil,
      @CredentialsHandle, nil);
    if Error <> SEC_E_OK then
    begin
      oError := Error;
      vMsgError := 'AcquireCredentialsHandle returns ' + IntToHex(Error, 8);
      Exit;
    end;
    Credenziali := TzSChannelCredenziali.Create(CredentialsHandle);
  end;
  Init := [iCredentials];

  // ... alpn
  if Assigned(ALPNProtocols) and (ALPNProtocols.Count > 0) then
  begin
    vOffSet := 10;
    vLengthTotal := 0;
    FillChar(ALPNBuffer, SizeOf(ALPNBuffer), 0);
    if ALPNProtocols.Count > 0 then
    begin
      for i := 0 to ALPNProtocols.Count - 1 do
      begin
        vLength := Length(ALPNProtocols[i]);
        if vLength > 0 then
        begin
          ALPNBuffer[vOffSet] := vLength;
          vOffSet := vOffSet + 1;
          Move(AnsiString(ALPNProtocols[i])[1], ALPNBuffer[vOffSet], vLength);
          vOffSet := vOffSet + vLength;
          vLengthTotal := vLengthTotal + vLength + 1;
        end;
      end;
      // ... i primi quattro byte sono un intero senza segno con il numero
      // ... di byte di dati nel resto del buffer.
      ALPNBuffer[0] := vLengthTotal + 4 + 2;
      // ... i quattro byte successivi indicano che il buffer contiene dati
      // ... ALPN, non NPN.
      ALPNBuffer[4] := 2;
      // SecApplicationProtocolNegotiationExt_ALPN
      // ... i due byte successivi sono un intero senza segno a 16 bit con il
      // ... numero di byte usati per elencare i protocolli preferiti.
      ALPNBuffer[8] := vLengthTotal;
    end;

    inBuffer.ulVersion := SECBUFFER_VERSION;
    inBuffer.cBuffers := 1;
    inBuffer.pBuffers := Addr(inBuffers[0]);

    inBuffers[0].cbBuffer := vOffSet;
    inBuffers[0].BufferType := SECBUFFER_APPLICATION_PROTOCOLS;
    inBuffers[0].pvBuffer := @ALPNBuffer;
  end
  else
    FillChar(inBuffer, SizeOf(inBuffer), 0);

  // ... buffer di uscita
  OutBuffer.ulVersion := SECBUFFER_VERSION;
  OutBuffer.cBuffers := 1;
  OutBuffer.pBuffers := Addr(OutBuffers[0]);

  OutBuffers[0].cbBuffer := 0;
  OutBuffers[0].BufferType := SECBUFFER_TOKEN;
  OutBuffers[0].pvBuffer := nil;

  WHost := Servername;

  Error := oSSPI.InitializeSecurityContext(@CredentialsHandle, nil,
    PWideChar(WideString(WHost)),
    ISC_REQ_SEQUENCE_DETECT or ISC_REQ_REPLAY_DETECT or
    ISC_REQ_CONFIDENTIALITY or ISC_RET_EXTENDED_ERROR or
    ISC_REQ_ALLOCATE_MEMORY or ISC_REQ_STREAM, 0,
    SECURITY_NATIVE_DREP, @inBuffer, 0, @Context,
    @OutBuffer, Flags, nil);

  if (Error <> SEC_I_CONTINUE_NEEDED) then
  begin
    oError := Error;
    vMsgError := 'First call to InitializeSecurityContext returns ' +
      IntToHex(Error, 8);
    Exit;
  end;
  Init := Init + [iContext];

  if not SendSecBuffer(Socket, OutBuffers[0]) then
  begin
    Exit;
  end;

  SetLength(RecvBuffer, CS_IO_BUFFER_SIZE);
  RecvCount := 0;

  if ReadLoop < 0 then
    Exit;

  if CertVerify then
  begin
    if DoVerifyCertificate = False then
      Exit;
  end;

  if InitBuffer = False then
    Exit;

  Result := True;
end;

procedure TSSLInfo.Clean;
begin
  // Il contesto si cancella sempre, come chiede la documentazione di
  // InitializeSecurityContext (Schannel): l'originale sgc lo faceva solo
  // dopo SEC_E_ILLEGAL_MESSAGE e ne lasciava uno aperto per ogni
  // connessione. Prima il contesto, poi le credenziali da cui e' nato; le
  // credenziali condivise restano vive finche' un'altra connessione le usa.
  if iContext in Init then
    oSSPI.DeleteSecurityContext(@Context);
  if Assigned(Credenziali) then
  begin
    Credenziali.Rilascia;
    Credenziali := nil;
  end;
  Init := [];
  FreeAndNil(ConnectionInfo);
end;

procedure TSSLInfo.SostituisciCredenziali(const Nuove: TCredHandle);
begin
  // Credenziali riacquisite con il certificato del client: la connessione
  // lascia quelle di prima (liberate se nessun'altra le usa) e possiede le
  // nuove.
  if Assigned(Credenziali) then
    Credenziali.Rilascia;
  Credenziali := TzSChannelCredenziali.Create(Nuove);
  CredentialsHandle := Nuove;
end;

function TSSLInfo.Read: Integer;
begin
  Result := recv(Socket, RecvBuffer[RecvCount],
    Length(RecvBuffer) - RecvCount, 0);
  if Result > 0 then
    Inc(RecvCount, Result)
  else
  begin
    Error := WSAGetLastError;
    // non sollevare per l'interruzione di una system call
    if Error = CS_SChannel_ERROR_INTERRUPTED_SYSTEM_CALL then
      Result := CS_SChannel_ERROR_INTERRUPTED_SYSTEM_CALL * (-1);
    oError := 0;
    vMsgError := 'recv returns ' + IntToHex(Error, 8);
  end;
end;

function TSSLInfo.SocketLeggibile(Attesa: Integer): Boolean;
var
  oFDSet: TFDSet;
  oTime: TTimeVal;
begin
  FD_ZERO(oFDSet);
  FD_SET(Socket, oFDSet);
  oTime.tv_sec := Attesa div 1000;
  oTime.tv_usec := (Attesa mod 1000) * 1000;
  Result := select(0, @oFDSet, nil, nil, @oTime) > 0;
end;

// Una DecryptMessage sui byte gia' ricevuti (RecvBuffer), senza leggere dal
// socket. Restituisce i byte decifrati disponibili (> 0), 0 se per ora non
// c'e' niente da consegnare (record incompleto, messaggio TLS che non porta
// dati, chiusura del server: vedi RecvIncompleto e Chiusa), -1 su errore.
// Si chiama solo con DataCount = 0: i dati decifrati si accodano da zero.
function TSSLInfo.DecifraBuffer: Integer;
var
  vBuffers: array [0 .. 3] of TSecBuffer;
  VBuffer: TSecBufferDesc;
  i: Integer;
  pDati: PSecBuffer;
  pExtra: PSecBuffer;
  Token: TBytes;
begin
  Result := 0;

  FillChar(vBuffers, SizeOf(vBuffers), 0);
  vBuffers[0].cbBuffer := RecvCount;
  vBuffers[0].BufferType := SECBUFFER_DATA;
  vBuffers[0].pvBuffer := @RecvBuffer[0];

  VBuffer.ulVersion := SECBUFFER_VERSION;
  VBuffer.cBuffers := 4;
  VBuffer.pBuffers := Addr(vBuffers[0]);

  Error := oSSPI.DecryptMessage(@Context, @VBuffer, 0, nil);

  if Error = SEC_E_INCOMPLETE_MESSAGE then
  begin
    // record non ancora completo: il buffer resta com'e', servono altri byte
    RecvIncompleto := True;
    Exit;
  end;
  RecvIncompleto := False;

  pDati := nil;
  pExtra := nil;
  for i := 1 to 3 do
  begin
    case vBuffers[i].BufferType of
      SECBUFFER_DATA:
        pDati := @vBuffers[i];
      SECBUFFER_EXTRA:
        pExtra := @vBuffers[i];
    end;
  end;

  if Error = SEC_I_CONTEXT_EXPIRED then
  begin
    // close_notify del server: fine ordinata della connessione. Si consegna
    // come 0 byte, lo stesso di SSL_read, e Indy la tratta come chiusura
    // (ClosedGracefully) invece che come errore.
    Chiusa := True;
    RecvCount := 0;
    Exit;
  end;

  if (Error <> SEC_E_OK) and (Error <> SEC_I_RENEGOTIATE) then
  begin
    oError := Error;
    vMsgError := 'DecryptMessage returns ' + IntToHex(Error, 8);
    Guasta := True;
    Result := -1;
    Exit;
  end;

  // I byte decifrati e quelli in eccesso stanno entrambi dentro RecvBuffer:
  // prima si copiano i decifrati, poi si spostano in testa quelli in eccesso.
  if Error = SEC_I_RENEGOTIATE then
  begin
    // Messaggio TLS successivo all'handshake (in TLS 1.3 il biglietto di
    // sessione, che serve proprio a riprendere la sessione su un'altra
    // connessione): il messaggio decifrato non e' un dato dell'applicazione
    // e va passato a InitializeSecurityContext come SECBUFFER_TOKEN
    // (documentazione di DecryptMessage (Schannel)). Fino a quella chiamata
    // ogni altra DecryptMessage fallisce.
    if Assigned(pDati) and (pDati.cbBuffer > 0) then
    begin
      SetLength(Token, pDati.cbBuffer);
      Move(pDati.pvBuffer^, Token[0], pDati.cbBuffer);
    end;
  end
  else if Assigned(pDati) and (pDati.cbBuffer > 0) then
  begin
    if DataCount + Integer(pDati.cbBuffer) > Length(DataBuffer) then
      SetLength(DataBuffer, DataCount + Integer(pDati.cbBuffer));
    Move(pDati.pvBuffer^, DataBuffer[DataCount], pDati.cbBuffer);
    Inc(DataCount, pDati.cbBuffer);
  end;

  if Assigned(pExtra) and (pExtra.cbBuffer > 0) then
  begin
    Assert(Integer(pExtra.cbBuffer) <= Length(RecvBuffer));
    RecvCount := pExtra.cbBuffer;
    Move(pExtra.pvBuffer^, RecvBuffer[0], RecvCount);
  end
  else
    RecvCount := 0;

  if Error = SEC_I_RENEGOTIATE then
  begin
    if not ElaboraPostHandshake(Token) then
    begin
      Guasta := True;
      Result := -1;
    end;
    Exit;
  end;

  Result := DataCount;
end;

function TSSLInfo.ElaboraPostHandshake(const Token: TBytes): Boolean;
var
  vInBuffers: array [0 .. 1] of TSecBuffer;
  vInBuffer: TSecBufferDesc;
  vOutBuffers: array [0 .. 0] of TSecBuffer;
  vOutBuffer: TSecBufferDesc;
  vFlags: DWORD;
  vError: Cardinal;
begin
  if Length(Token) = 0 then
  begin
    // Rinegoziazione TLS 1.2 chiesta dal server: si riprende il ciclo
    // dell'handshake, partendo dai byte gia' ricevuti se ce ne sono (come
    // l'esempio WebClient di Microsoft), altrimenti leggendo dal socket.
    Result := ReadLoop(RecvCount = 0) >= 0;
    Exit;
  end;

  vInBuffers[0].cbBuffer := Length(Token);
  vInBuffers[0].BufferType := SECBUFFER_TOKEN;
  vInBuffers[0].pvBuffer := @Token[0];
  vInBuffers[1].cbBuffer := 0;
  vInBuffers[1].BufferType := SECBUFFER_EMPTY;
  vInBuffers[1].pvBuffer := nil;
  vInBuffer.ulVersion := SECBUFFER_VERSION;
  vInBuffer.cBuffers := 2;
  vInBuffer.pBuffers := Addr(vInBuffers[0]);

  vOutBuffers[0].cbBuffer := 0;
  vOutBuffers[0].BufferType := SECBUFFER_TOKEN;
  vOutBuffers[0].pvBuffer := nil;
  vOutBuffer.ulVersion := SECBUFFER_VERSION;
  vOutBuffer.cBuffers := 1;
  vOutBuffer.pBuffers := Addr(vOutBuffers[0]);

  vError := oSSPI.InitializeSecurityContext(@CredentialsHandle, @Context,
    PWideChar(WideString(Servername)), CS_ISC_FLAGS, 0, SECURITY_NATIVE_DREP,
    @vInBuffer, 0, nil, @vOutBuffer, vFlags, nil);

  if not SendSecBuffer(Socket, vOutBuffers[0]) then
  begin
    Result := False;
    Exit;
  end;

  if vError = SEC_E_OK then
    Result := True
  else if vError = SEC_I_CONTINUE_NEEDED then
    Result := ReadLoop(RecvCount = 0) >= 0
  else
  begin
    oError := vError;
    vMsgError := 'InitializeSecurityContext (post-handshake) returns ' +
      IntToHex(vError, 8);
    Result := False;
  end;
end;

// Dati da consegnare senza toccare il socket: si decifrano i record gia'
// ricevuti per intero (per esempio due risposte arrivate nello stesso
// pacchetto: la seconda resta in RecvBuffer). Non si blocca mai, salvo il
// caso raro di una rinegoziazione TLS 1.2 chiesta dal server in quel record.
function TSSLInfo.DatiInAttesa: Boolean;
begin
  if DataCount - DataStart <= 0 then
  begin
    DataCount := 0;
    DataStart := 0;
    while (DataCount = 0) and (RecvCount > 0) and not RecvIncompleto and
      not Chiusa and not Guasta do
      DecifraBuffer;
  end;
  // anche la chiusura e l'errore vanno consegnati: chi legge ricevera' 0
  // byte (chiusura ordinata) o -1 (errore) invece di restare in attesa
  Result := (DataCount - DataStart > 0) or Chiusa or Guasta;
end;

// Chiusura ordinata della sessione TLS (documentazione "Shutting Down an
// Schannel Connection"): ApplyControlToken(SCHANNEL_SHUTDOWN), poi
// InitializeSecurityContext produce il close_notify da mandare al server.
// Il contesto si cancella dopo, in Clean.
function TSSLInfo.InviaChiusura: Boolean;
var
  vTipo: DWORD;
  vBuffers: array [0 .. 0] of TSecBuffer;
  vBuffer: TSecBufferDesc;
  vOutBuffers: array [0 .. 0] of TSecBuffer;
  vOutBuffer: TSecBufferDesc;
  vFlags: DWORD;
  vError: Cardinal;
begin
  Result := False;
  if not (iContext in Init) or Guasta then
    Exit;

  vTipo := SCHANNEL_SHUTDOWN;
  vBuffers[0].cbBuffer := SizeOf(vTipo);
  vBuffers[0].BufferType := SECBUFFER_TOKEN;
  vBuffers[0].pvBuffer := @vTipo;
  vBuffer.ulVersion := SECBUFFER_VERSION;
  vBuffer.cBuffers := 1;
  vBuffer.pBuffers := Addr(vBuffers[0]);

  if oSSPI.ApplyControlToken(@Context, @vBuffer) <> SEC_E_OK then
    Exit;

  vOutBuffers[0].cbBuffer := 0;
  vOutBuffers[0].BufferType := SECBUFFER_TOKEN;
  vOutBuffers[0].pvBuffer := nil;
  vOutBuffer.ulVersion := SECBUFFER_VERSION;
  vOutBuffer.cBuffers := 1;
  vOutBuffer.pBuffers := Addr(vOutBuffers[0]);

  vError := oSSPI.InitializeSecurityContext(@CredentialsHandle, @Context,
    PWideChar(WideString(Servername)), CS_ISC_FLAGS, 0, SECURITY_NATIVE_DREP,
    nil, 0, @Context, @vOutBuffer, vFlags, nil);

  if (vError = SEC_E_OK) or (vError = SEC_I_CONTEXT_EXPIRED) then
    Result := SendSecBuffer(Socket, vOutBuffers[0]);

  // SendSecBuffer libera il buffer solo se l'invio riesce
  if vOutBuffers[0].pvBuffer <> nil then
    oSSPI.FreeContextBuffer(vOutBuffers[0].pvBuffer);
end;

// Byte decifrati disponibili (> 0), 0 se non ne arrivano (chiusura del
// server, o nessun dato entro aTimeout), < 0 su errore.
// aTimeout < 0: attende i dati senza limite (lettura vera e propria);
// aTimeout >= 0: attesa massima in ms sul socket, 0 = sola verifica senza
// attesa. L'originale sgc trattava 0 come "nessuna select" ed eseguiva una
// recv bloccante proprio quando il chiamante chiedeva di non aspettare.
function TSSLInfo.Readable(aTimeout: Integer = -1): Integer;
begin
  Result := DataCount - DataStart;
  if Result > 0 then
    Exit;

  DataCount := 0;
  DataStart := 0;

  repeat
    if Guasta then
      Exit(-1);
    if Chiusa then
      Exit(0);

    // prima i record gia' ricevuti
    if (RecvCount > 0) and not RecvIncompleto then
    begin
      Result := DecifraBuffer;
      if Result <> 0 then
        Exit;
      Continue;
    end;

    // poi altri byte dal socket
    if (aTimeout >= 0) and not SocketLeggibile(aTimeout) then
      Exit(0);
    Result := Read;
    if Result <= 0 then
      Exit;
    RecvIncompleto := False;
  until False;
end;

function TSSLInfo.ReadLoop(LeggiPrima: Boolean = True): Integer;
var
  vInBuffers: array [0 .. 1] of TSecBuffer;
  vInBuffer: TSecBufferDesc;
  vOutBuffers: array [0 .. 0] of TSecBuffer;
  vOutBuffer: TSecBufferDesc;
  vRead: Boolean;
  vFlags: DWORD;
  vError: Cardinal;
  vSource: PByte;
begin
  vInBuffer.ulVersion := SECBUFFER_VERSION;
  vInBuffer.cBuffers := 2;
  vInBuffer.pBuffers := Addr(vInBuffers[0]);

  vOutBuffer.ulVersion := SECBUFFER_VERSION;
  vOutBuffer.cBuffers := 1;
  vOutBuffer.pBuffers := Addr(vOutBuffers[0]);

  // LeggiPrima = False quando RecvBuffer contiene gia' i byte da passare
  // (rinegoziazione con byte in eccesso): leggere prima dal socket
  // bloccherebbe in attesa di dati che il server non manda.
  vRead := LeggiPrima;
  repeat
    if vRead then
    begin
      vRead := False;
      Result := Read;
      if Result <= 0 then
        Exit;
    end;

    vInBuffers[0].cbBuffer := RecvCount;
    vInBuffers[0].BufferType := SECBUFFER_TOKEN;
    vInBuffers[0].pvBuffer := @RecvBuffer[0];

    vInBuffers[1].cbBuffer := 0;
    vInBuffers[1].BufferType := SECBUFFER_EMPTY;
    vInBuffers[1].pvBuffer := nil;

    vOutBuffers[0].cbBuffer := 0;
    vOutBuffers[0].BufferType := SECBUFFER_TOKEN;
    vOutBuffers[0].pvBuffer := nil;

    // Il nome del server si ripassa a ogni chiamata, come fanno .NET
    // (SslStream) e curl: e' la chiave con cui Schannel registra la sessione
    // nella sua cache.
    vError := oSSPI.InitializeSecurityContext(@CredentialsHandle, @Context,
      PWideChar(WideString(Servername)), CS_ISC_FLAGS, 0,
      SECURITY_NATIVE_DREP, @vInBuffer, 0, nil,
      @vOutBuffer, vFlags, nil);

    if not SendSecBuffer(Socket, vOutBuffers[0]) then
    begin
      Result := -1;
      Exit;
    end;

    if (vInBuffers[1].cbBuffer > 0) and
      (vInBuffers[1].BufferType = SECBUFFER_EXTRA) then
    begin
      vSource := @RecvBuffer[RecvCount - Integer(vInBuffers[1].cbBuffer)];
      RecvCount := vInBuffers[1].cbBuffer;
      Move(vSource^, RecvBuffer[0], RecvCount);
    end
    else
    begin
      if vError <> SEC_E_INCOMPLETE_MESSAGE then
        RecvCount := 0;
    end;

    if (vError = SEC_E_INCOMPLETE_MESSAGE) or
      (vError = SEC_I_CONTINUE_NEEDED) or
      (vError = SEC_E_INCOMPLETE_MESSAGE) then
    begin
      vRead := True;
      Continue;
    end;

    if vError = SEC_I_INCOMPLETE_CREDENTIALS then
    begin
      if CertHash <> '' then
      begin
        if not DoGetCertificate then
        begin
          Result := -1;
          Exit;
        end;
      end
      else if CertFile <> '' then
      begin
        if not DoImportCertPFX(CertFile, CertFilePassword) then
        begin
          Result := -1;
          Exit;
        end;
      end
      else
        // ... prova a ottenere il certificato dall'archivio della catena
        // ... se non trovato, prova comunque a proseguire
        DoGetCertificateFromChainStore;
      Assert(vRead = False);
      Continue;
    end;

    if FAILED(vError) then
    begin
      oError := vError;
      vMsgError := 'InitializeSecurityContext returns ' + IntToHex(vError, 8);
      Result := -1;
      Exit;
    end;

  until vError = SEC_E_OK;

  Result := 0;
end;

function TSSLInfo.DoGetCertificateFromChainStore: Boolean;
var
  vError: Integer;
  oIssuer: TSecPkgContextIssuerListInfoEx;
  vChainPara: CERT_CHAIN_FIND_BY_ISSUER_PARA;
  vChainCtxt: PCCERT_CHAIN_CONTEXT;
  vChainIndex: DWORD;
  vElementIndex: DWORD;
  pCertContext: PCCERT_CONTEXT;
  vCreds: TCredHandle;
begin
  if Assigned(CredentialsCallBack) then
    CredentialsCallBack(THandle(@Self), UserData);

  FillChar(oIssuer, SizeOf(oIssuer), 0);
  vError := oSSPI.QueryContextAttributes(@Context,
    SECPKG_ATTR_ISSUER_LIST_EX, @oIssuer);
  if vError <> SEC_E_OK then
  begin
    oError := Error;
    vMsgError := 'QueryContextAttributes(SECPKG_ATTR_ISSUER_LIST_EX) returns '
      + IntToHex(vError, 8);
    Result := False;
    Exit;
  end;
  FillChar(vChainPara, SizeOf(vChainPara), 0);
  vChainPara.cbSize := SizeOf(vChainPara);
  vChainPara.pszUsageIdentifier := szOID_PKIX_KP_CLIENT_AUTH;
  vChainPara.cIssuer := oIssuer.cIssuers;
  vChainPara.rgIssuer := oIssuer.aIssuers;
  vChainPara.pdwIssuerChainIndex := @vChainIndex;
  vChainPara.pdwIssuerElementIndex := @vElementIndex;
  vChainIndex := 0;
  vElementIndex := 0;

  vChainCtxt := nil;
  repeat
    vChainCtxt := CertFindChainInStore(oMyStore, X509_ASN_ENCODING, 0,
      CERT_CHAIN_FIND_BY_ISSUER, @vChainPara, vChainCtxt);
    if vChainCtxt = nil then
    begin
      oError := 0;
      vMsgError := 'CertFindChainInStore returns nil';
      Result := False;
      Exit;
    end;

    pCertContext := vChainCtxt.rgpChain[0].rgpElement[0].pCertContext;
    if IsLegacy then
    begin
      CredentialsLegacy.dwVersion := SCHANNEL_CRED_VERSION;
      CredentialsLegacy.cCreds := 1;
      CredentialsLegacy.paCred := @pCertContext;
    end;

    vError := oSSPI.AcquireCredentialsHandle(nil, UNISP_NAME,
      SECPKG_CRED_OUTBOUND, nil, CredentialsPtr, nil, nil, @vCreds, nil);
  until vError = SEC_E_OK;
  SostituisciCredenziali(vCreds);
  Result := True;
end;

function TSSLInfo.DoVerifyCertificate: Boolean;
const
  USAGES: array [0 .. 2] of PAnsiChar =
    (szOID_PKIX_KP_SERVER_AUTH, szOID_SERVER_GATED_CRYPTO, szOID_SGC_NETSCAPE);
var
  vError: Integer;
  pServer: PCCERT_CONTEXT;
  vChainPara: CERT_CHAIN_PARA;
  vChain: PCCERT_CHAIN_CONTEXT;
  vHTTPS: HTTPSPolicyCallbackData;
  vPolicy: CERT_CHAIN_POLICY_PARA;
  vStatus: CERT_CHAIN_POLICY_STATUS;
  vFlagsIgnora: DWORD;
begin
  pServer := nil;
  vError := oSSPI.QueryContextAttributes(@Context,
    SECPKG_ATTR_REMOTE_CERT_CONTEXT, @pServer);
  if vError <> 0 then
  begin
    oError := Error;
    vMsgError := 'QueryCredentialsAttributes returns ' + IntToHex(vError, 8);
    Result := False;
    Exit;
  end;

  // Pinning: se il certificato del server e' nell'elenco fidato per questo
  // host, si accetta senza costruire ne' verificare la catena.
  if Assigned(TrustedCerts) and
    TrustedCerts.Contiene(Servername, pServer.pbCertEncoded, pServer.cbCertEncoded)
  then
  begin
    Result := True;
    CertFreeCertificateContext(pServer);
    Exit;
  end;

  FillChar(vChainPara, SizeOf(vChainPara), 0);
  vChainPara.cbSize := SizeOf(vChainPara);
  vChainPara.RequestedUsage.dwType := USAGE_MATCH_TYPE_OR;
  vChainPara.RequestedUsage.Usage.cUsageIdentifier := Length(USAGES);
  vChainPara.RequestedUsage.Usage.rgpszUsageIdentifier := PAnsiChar(@USAGES);

  Result := CertGetCertificateChain(0, pServer, nil, pServer.HCERTSTORE,
    vChainPara, 0, nil, vChain);

  if Result then
  begin
    // Esclusioni granulari (CertCheckIgnoreFlags): stessi flag di
    // WinInet/WinHTTP applicati a HTTPSPolicyCallbackData.fdwChecks. Se
    // Servername e' vuoto (verifica senza nome, oggi non usata da questo
    // provider) si esclude comunque il controllo sul nome comune, altrimenti
    // fallirebbe sempre per un motivo che non dipende dal certificato.
    vFlagsIgnora := 0;
    if ignRevoca in CertCheckIgnoreFlags then
      vFlagsIgnora := vFlagsIgnora or SECURITY_FLAG_IGNORE_REVOCATION;
    if ignAutoritaSconosciuta in CertCheckIgnoreFlags then
      vFlagsIgnora := vFlagsIgnora or SECURITY_FLAG_IGNORE_UNKNOWN_CA;
    if ignUsoErrato in CertCheckIgnoreFlags then
      vFlagsIgnora := vFlagsIgnora or SECURITY_FLAG_IGNORE_WRONG_USAGE;
    if (ignNomeComuneNonValido in CertCheckIgnoreFlags) or (Servername = '') then
      vFlagsIgnora := vFlagsIgnora or SECURITY_FLAG_IGNORE_CERT_CN_INVALID;
    if ignDataNonValida in CertCheckIgnoreFlags then
      vFlagsIgnora := vFlagsIgnora or SECURITY_FLAG_IGNORE_CERT_DATE_INVALID;

    FillChar(vHTTPS, SizeOf(vHTTPS), 0);
    vHTTPS.cbSize := SizeOf(vHTTPS);
    vHTTPS.dwAuthType := AUTHTYPE_SERVER;
    vHTTPS.fdwChecks := vFlagsIgnora;
    vHTTPS.pwszServerName := PWideChar(WideString(Servername));

    FillChar(vPolicy, SizeOf(vPolicy), 0);
    vPolicy.cbSize := SizeOf(vPolicy);
    vPolicy.pvExtraPolicyPara := @vHTTPS;

    FillChar(vStatus, SizeOf(vStatus), 0);
    vStatus.cbSize := SizeOf(vStatus);

    Result := CertVerifyCertificateChainPolicy(CERT_CHAIN_POLICY_SSL, vChain,
      vPolicy, vStatus);

    if Result then
    begin
      CertStatus := vStatus.dwError;
      if vStatus.dwError = CERT_E_UNTRUSTEDROOT then
        Result := Validate(vChain, vStatus)
      else
        Result := vStatus.dwError = 0;
      if Result = False then
      begin
        oError := vStatus.dwError;
        vMsgError := 'CertVerifyCertificateChainPolicy.vStatus = ' +
          IntToHex(vStatus.dwError, 8);
      end;
    end;

    CertFreeCertificateChain(vChain);
  end;

  CertFreeCertificateContext(pServer);
end;

function TSSLInfo.InitBuffer: Boolean;
var
  vError: Integer;
begin
  vError := oSSPI.QueryContextAttributes(@Context,
    SECPKG_ATTR_STREAM_SIZES, @BuffSizes);
  if vError <> SEC_E_OK then
  begin
    oError := Error;
    vMsgError := 'QueryContextAttributes(SECPKG_ATTR_STREAM_SIZES) returns '
      + IntToHex(vError, 8);
    Result := False;
    Exit;
  end;
  SetLength(RecvBuffer, BuffSizes.cbHeader + BuffSizes.cbMaximumMessage +
    BuffSizes.cbTrailer);
  SetLength(SendBuffer, BuffSizes.cbHeader + BuffSizes.cbMaximumMessage +
    BuffSizes.cbTrailer);
  // RecvCount non si azzera qui: potrebbero restare dati ancora da decifrare
  DataCount := 0;
  DataStart := 0;
  Result := True;
end;

function TSSLInfo.Decrypt(var Data; Size: Integer): Integer;
begin
  // lettura vera e propria: attende i dati senza limite (lo limita il
  // SO_RCVTIMEO impostato dall'handler)
  Result := Readable(-1);
  if Result > 0 then
  begin
    if Result > Size then
      Result := Size;
    Move(DataBuffer[DataStart], Data, Result);
    Inc(DataStart, Result);
  end;
end;

function TSSLInfo.DoGetCertificate: Boolean;
var
  oCertContext: Array [0 .. 0] of PCCERT_CONTEXT;
  oBytes: Array [0 .. 19] of Byte;
  oHash: CRYPT_HASH_BLOB;
  vError: Integer;
  vCreds: TCredHandle;
begin
  Result := False;
  if CertHash <> '' then
  begin
    oMyStore := CertOpenStore(CERT_STORE_PROV_SYSTEM,
      X509_ASN_ENCODING or PKCS_7_ASN_ENCODING, 0,
      CERT_STORE_OPEN_EXISTING_FLAG or GetCertStorePath(CertStorePath),
      PWideChar(WideString(GetCertStoreName(CertStoreName))));
    Try
      if oMyStore = 0 then
      begin
        vMsgError := 'Cannot Open Certificate Store.';
        Exit;
      end;

      if Length(CertHash) <> CERT_THUMBPRINT_DATA_LEN * 2 then
      begin
        vMsgError := Format('Invalid Certificate Hash Length, must be %d.',
          [CERT_THUMBPRINT_DATA_LEN * 2]);
        Exit;
      end;

      FillChar(oHash, SizeOf(oHash), 0);
      oHash.pbData := @oBytes[0];
      oHash.cbData := CERT_THUMBPRINT_DATA_LEN;
      if not CryptStringToBinary(PWideChar(WideString(CertHash)),
        Length(CertHash), CRYPT_STRING_HEX, @oBytes[0], oHash.cbData, nil, nil)
      then
      begin
        vMsgError := 'Error calling method CryptStringToBinary.';
        Exit;
      end;

      oCertContext[0] := CertFindCertificateInStore(oMyStore,
        X509_ASN_ENCODING or PKCS_7_ASN_ENCODING, 0, CERT_FIND_HASH, @oHash,
        nil);

      if not Assigned(oCertContext[0]) then
      begin
        vMsgError := Format('Certificate not found in Store %s with Hash %s',
          [GetCertStoreName(CertStoreName), CertHash]);
        Exit;
      end;

      if IsLegacy then
      begin
        CredentialsLegacy.dwVersion := SCHANNEL_CRED_VERSION;
        CredentialsLegacy.paCred := @oCertContext;
        CredentialsLegacy.cCreds := 1;
      end;

      vError := oSSPI.AcquireCredentialsHandle(nil, UNISP_NAME,
        SECPKG_CRED_OUTBOUND, nil, CredentialsPtr, nil, nil, @vCreds, nil);

      if vError = SEC_E_OK then
        SostituisciCredenziali(vCreds);

      Result := vError = SEC_E_OK;
    Finally
      CertCloseStore(oMyStore, 0);
    End;
  end;
end;

function TSSLInfo.Encrypt(var Data; Size: Integer): Integer;
var
  vSource: PByte;
  i: Integer;
  vBuffers: array [0 .. 3] of TSecBuffer;
  VBuffer: TSecBufferDesc;
begin
  Result := 0;
  vSource := @Data;
  while Size > 0 do
  begin
    if Cardinal(Size) > BuffSizes.cbMaximumMessage then
      i := BuffSizes.cbMaximumMessage
    else
      i := Size;
    Move(vSource[Result], SendBuffer[BuffSizes.cbHeader], i);
    Inc(Result, i);
    Dec(Size, i);

    vBuffers[0].cbBuffer := BuffSizes.cbHeader;
    vBuffers[0].BufferType := SECBUFFER_STREAM_HEADER;
    vBuffers[0].pvBuffer := @SendBuffer[0];

    vBuffers[1].cbBuffer := i;
    vBuffers[1].BufferType := SECBUFFER_DATA;
    vBuffers[1].pvBuffer := @SendBuffer[BuffSizes.cbHeader];

    vBuffers[2].cbBuffer := BuffSizes.cbTrailer;
    vBuffers[2].BufferType := SECBUFFER_STREAM_TRAILER;
    vBuffers[2].pvBuffer := @SendBuffer[Integer(BuffSizes.cbHeader) + i];

    vBuffers[3].BufferType := SECBUFFER_EMPTY;

    VBuffer.ulVersion := SECBUFFER_VERSION;
    VBuffer.cBuffers := 4;
    VBuffer.pBuffers := Addr(vBuffers[0]);

    Error := oSSPI.EncryptMessage(@Context, 0, @VBuffer, 0);
    if FAILED(Error) then
    begin
      oError := Error;
      vMsgError := 'EncryptMessage returns ' + IntToHex(Error, 8);
      Result := -1;
      Exit;
    end;

    i := SendData(Socket, PByte(SendBuffer),
      vBuffers[0].cbBuffer + vBuffers[1].cbBuffer + vBuffers[2].cbBuffer);
    if i <= 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TSSLInfo.GetALPN: String;
var
  i: Integer;
  vArray: TBytes;
begin
  Result := '';
  FillChar(alpn_result, SizeOf(alpn_result), 0);
  Error := oSSPI.QueryContextAttributes(@Context,
    SECPKG_ATTR_APPLICATION_PROTOCOL, @alpn_result);
  if Error <> SEC_E_OK then
  begin
    vMsgError :=
      'QueryContextAttributes(SECPKG_ATTR_APPLICATION_PROTOCOL) returns ' +
      IntToHex(Error, 8);
  end
  else
  begin
    if alpn_result.ProtoNegoStatus =
      Ord(SecApplicationProtocolNegotiationStatus_Success) then
    begin
      if alpn_result.ProtoNegoExt =
        Ord(SecApplicationProtocolNegotiationExt_ALPN) then
      begin
        SetLength(vArray, alpn_result.ProtocolIdSize);
        for i := 0 to alpn_result.ProtocolIdSize - 1 do
          vArray[i] := alpn_result.ProtocolId[i];
        Result := TEncoding.UTF8.GetString(vArray);
      end;
    end;
  end;
end;

function TSSLInfo.DoImportCertPFX(const aFileName, aPassword: String): Boolean;
var
  oPFX: CRYPT_DATA_BLOB;
  oStream: TsgcSChannelStream;
  vPassword: PWideChar;
  oCertContext: Array [0 .. 0] of PCCERT_CONTEXT;
  vCreds: TCredHandle;
  vError: Integer;
begin
  Result := False;

  oStream := TsgcSChannelStream.Create;
  try
    oStream.LoadFromFile(aFileName);

    oPFX.cbData := oStream.DataSize;
    oPFX.pbData := oStream.Data;
    vPassword := PWideChar(WideString(aPassword));

    oMyStore := PFXImportCertStore(oPFX, vPassword, 0);
    Try
      if (oMyStore = 0) and (aPassword = '') then
        oMyStore := PFXImportCertStore(oPFX, nil, 0);
      if oMyStore = 0 then
      begin
        vMsgError := 'Cannot import the certificate.';
        Exit;
      end;

      oCertContext[0] := CertFindCertificateInStore(oMyStore,
        X509_ASN_ENCODING or PKCS_7_ASN_ENCODING, 0, CERT_FIND_ANY, nil, nil);

      if not Assigned(oCertContext[0]) then
      begin
        vMsgError := 'Cannot import the certificate.';
        Exit;
      end;

      if IsLegacy then
      begin
        CredentialsLegacy.dwVersion := SCHANNEL_CRED_VERSION;
        CredentialsLegacy.paCred := @oCertContext;
        CredentialsLegacy.cCreds := 1;
      end;

      vError := oSSPI.AcquireCredentialsHandle(nil, UNISP_NAME,
        SECPKG_CRED_OUTBOUND, nil, CredentialsPtr, nil, nil, @vCreds, nil);

      if vError = SEC_E_OK then
        SostituisciCredenziali(vCreds);

      Result := vError = SEC_E_OK;
    Finally
      CertCloseStore(oMyStore, 0);
    end;
  Finally
    FreeAndNil(oStream);
  end;
end;

function TSSLInfo.GetCipherId(const aCipher: string): Cardinal;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(CS_SChannel_Ciphers) to High(CS_SChannel_Ciphers) do
  begin
    if CS_SChannel_Ciphers[i] = aCipher then
    begin
      Result := CS_SChannel_CiphersId[i];
      break;
    end;
  end;
end;

function TSSLInfo.GetConnectionInfo: TsgcSChannelConnectionInfo;
var
  oInfo: TSecPkgContextConnectionInfo;
begin
  Result := ConnectionInfo;
  if not Assigned(Result) then
  begin
    if oSSPI.QueryContextAttributes(@Context, SECPKG_ATTR_CONNECTION_INFO,
      @oInfo) = SEC_E_OK then
    begin
      ConnectionInfo := TsgcSChannelConnectionInfo.Create;
      ConnectionInfo.SetProtocol(oInfo.dwProtocol);
      ConnectionInfo.SetCipher(oInfo.aiCipher);
      ConnectionInfo.CiperStrength := oInfo.dwCipherStrength;
      ConnectionInfo.SetHash(oInfo.aiHash);
      ConnectionInfo.HashStrength := oInfo.dwHashStrength;
      ConnectionInfo.SetExchange(oInfo.aiExch);
      ConnectionInfo.ExchangeStrength := oInfo.dwExchStrength;

      Result := ConnectionInfo;
    end;
  end;
end;

function SSLAvailable: Boolean;
var
  Init: function: PSecurityFunctionTable; stdcall;
begin
  Result := vInitialized;
  oError := 0;
  if not vInitialized then
  begin
    vInitialized := True;

    secur32 := LoadLibrary('secur32.dll');
    @Init := GetProcAddress(secur32, 'InitSecurityInterfaceW');

    if @Init = nil then
    begin
      vMsgError := 'InitSecurityInterface() not found';
      Exit;
    end;

    oSSPI := Init();
    if oSSPI = nil then
    begin
      vMsgError := 'InitSecurityInterface() returns nil';
      Exit;
    end;

    oMyStore := CertOpenSystemStore(0, 'MY');
    if oMyStore = 0 then
    begin
      vMsgError := 'CertOpenSystemStore(0, ''MY'') returns 0';
      Exit;
    end;

    Result := True;
  end;
end;

procedure SSLShutdown;
begin
  if vInitialized then
  begin
    FreeLibrary(secur32);
    secur32 := 0;
    vInitialized := False;
  end;
end;

function SSLStart(aSocket: TSocket; aCertificate: TsgcSChannelCertificate;
    const Host: AnsiString = ''; aVersion: TzSChannelTlsVersione = tls1_0;
    aALPNProtocols: TStrings = nil; aCipherList: String = '';
    aSessione: THandle = 0): THandle;
var
  pInfo: PSSLInfo;
begin
  Result := 0;
  CertStatus := 0;
  oError := 0;
  vMsgError := '';

  if SSLAvailable = False then
    Exit;

  New(pInfo);
  FillChar(pInfo^, SizeOf(TSSLInfo), 0);
  pInfo.Socket := aSocket;
  pInfo.Servername := string(Host);
  pInfo.Version := aVersion;
  pInfo.ALPNProtocols := aALPNProtocols;
  pInfo.CertVerify := aCertificate.VerifyCertificate;
  pInfo.CertHash := aCertificate.CertHash;
  pInfo.CertFile := aCertificate.CertFile;
  pInfo.CertFilePassword := aCertificate.CertFilePassword;
  pInfo.CertStorePath := aCertificate.CertStorePath;
  pInfo.CertStoreName := aCertificate.CertStoreName;
  pInfo.CertCheckIgnoreFlags := aCertificate.CertCheckIgnoreFlags;
  pInfo.TrustedCerts := aCertificate.TrustedCerts;
  pInfo.CipherList := aCipherList;
  if aSessione <> 0 then
  begin
    // riferimento proprio della connessione, restituito da Clean
    pInfo.Credenziali := TzSChannelCredenziali(Pointer(aSessione));
    pInfo.Credenziali.Aggiungi;
  end;
  if not pInfo.Start then
  begin
    pInfo.Clean;
    Dispose(pInfo);
    if (oError = HRESULT(SEC_E_ILLEGAL_MESSAGE)) or
      (oError = HRESULT(SEC_E_INTERNAL_ERROR)) then
      SSLShutdown;
    Exit;
  end;

  Result := THandle(pInfo);
end;

procedure SSLCredentialsCallBack(SSL: THandle; CallBack: TCredentialsCallBack;
  UserData: Pointer);
var
  pInfo: PSSLInfo absolute SSL;
begin
  if SSL <> 0 then
  begin
    pInfo.CredentialsCallBack := CallBack;
    pInfo.UserData := UserData;
  end;
end;

function SSLPending(SSL: THandle; AMSec: Integer): Boolean;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := (pInfo <> nil) and (pInfo.Readable(AMSec) > 0);
end;

function SSLDatiInAttesa(SSL: THandle): Boolean;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := (pInfo <> nil) and pInfo.DatiInAttesa;
end;

function SSLInviaChiusura(SSL: THandle): Boolean;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := (pInfo <> nil) and pInfo.InviaChiusura;
end;

function SSLCondividiSessione(SSL: THandle; out NomeServer: string): THandle;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := 0;
  NomeServer := '';
  if (pInfo = nil) or not Assigned(pInfo.Credenziali) then
    Exit;
  pInfo.Credenziali.Aggiungi;
  NomeServer := pInfo.Servername;
  Result := THandle(Pointer(pInfo.Credenziali));
end;

procedure SSLRilasciaSessione(Sessione: THandle);
begin
  if Sessione <> 0 then
    TzSChannelCredenziali(Pointer(Sessione)).Rilascia;
end;

function SSLSessioneRipresa(SSL: THandle): Boolean;
const
  // schannel.h: non dichiarati in zNet.Tls.SChannel.WinApi
  SECPKG_ATTR_SESSION_INFO = $5D;
  SSL_SESSION_RECONNECT = 1;
type
  TSecPkgContextSessionInfo = record
    dwFlags: DWORD;
    cbSessionId: DWORD;
    rgbSessionId: array [0 .. 31] of Byte;
  end;
var
  pInfo: PSSLInfo absolute SSL;
  Informazioni: TSecPkgContextSessionInfo;
begin
  Result := False;
  if (pInfo = nil) or not (iContext in pInfo.Init) then
    Exit;
  FillChar(Informazioni, SizeOf(Informazioni), 0);
  if oSSPI.QueryContextAttributes(@pInfo.Context, SECPKG_ATTR_SESSION_INFO,
    @Informazioni) = SEC_E_OK then
    Result := (Informazioni.dwFlags and SSL_SESSION_RECONNECT) <> 0;
end;

function SSLRead(SSL: THandle; var Data; Size: Integer): Integer;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := pInfo.Decrypt(Data, Size);
end;

function SSLWrite(SSL: THandle; var Data; Size: Integer): Integer;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := pInfo.Encrypt(Data, Size);
end;

function SSLClose(SSL: THandle): Integer;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := 0;
  if SSL = 0 then
    Exit;
  pInfo.Clean;
  Dispose(pInfo);
end;

function GetALPN(SSL: THandle): String;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := '';
  if Assigned(pInfo) then
    Result := pInfo.GetALPN;
end;

function GetConnectionInfo(SSL: THandle): TsgcSChannelConnectionInfo;
var
  pInfo: PSSLInfo absolute SSL;
begin
  Result := nil;
  if Assigned(pInfo) then
    Result := pInfo.GetConnectionInfo;
end;

procedure TsgcSChannelCertificate.Assign(aSource: TPersistent);
begin
  if aSource is TsgcSChannelCertificate then
  begin
    VerifyCertificate := TsgcSChannelCertificate(aSource).VerifyCertificate;
    CertStoreName := TsgcSChannelCertificate(aSource).CertStoreName;
    CertStorePath := TsgcSChannelCertificate(aSource).CertStorePath;
    CertHash := TsgcSChannelCertificate(aSource).CertHash;
    CertFile := TsgcSChannelCertificate(aSource).CertFile;
    CertFilePassword := TsgcSChannelCertificate(aSource).CertFilePassword;
    CertCheckIgnoreFlags := TsgcSChannelCertificate(aSource).CertCheckIgnoreFlags;
    TrustedCerts := TsgcSChannelCertificate(aSource).TrustedCerts;
  end
  else
    inherited Assign(aSource);
end;

{ TzSChannelTrustedCerts }

constructor TzSChannelTrustedCerts.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TzSChannelTrustedCerts.Destroy;
begin
  FreeAndNil(FCriticalSection);
  inherited;
end;

procedure TzSChannelTrustedCerts.Aggiungi(const Host: string; const Dati: TBytes);
begin
  FCriticalSection.Enter;
  Try
    SetLength(FCerti, Length(FCerti) + 1);
    FCerti[High(FCerti)].Host := Host;
    FCerti[High(FCerti)].Dati := Copy(Dati);
  Finally
    FCriticalSection.Leave;
  End;
end;

function TzSChannelTrustedCerts.Contiene(const Host: string; Dati: Pointer;
  DimensioneDati: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  FCriticalSection.Enter;
  Try
    for i := 0 to High(FCerti) do
    begin
      if not SameText(FCerti[i].Host, Host) then
        Continue;
      if Length(FCerti[i].Dati) <> DimensioneDati then
        Continue;
      if (DimensioneDati = 0) or
        CompareMem(@FCerti[i].Dati[0], Dati, DimensioneDati) then
      begin
        Result := True;
        Exit;
      end;
    end;
  Finally
    FCriticalSection.Leave;
  End;
end;

procedure TzSChannelTrustedCerts.Svuota;
begin
  FCriticalSection.Enter;
  Try
    SetLength(FCerti, 0);
  Finally
    FCriticalSection.Leave;
  End;
end;

{ TsgcSChannelStream }

destructor TsgcSChannelStream.Destroy;
begin
  DoFinalize;
  inherited;
end;

procedure TsgcSChannelStream.DoInitialize(aSize: Integer);
begin
  DoFinalize();
  FDataSize := aSize;
  if (FDataSize > 0) then
    GetMem(FData, FDataSize);
end;

procedure TsgcSChannelStream.DoFinalize;
begin
  FreeMem(FData);
  FData := nil;
  FDataSize := 0;
end;

procedure TsgcSChannelStream.LoadFromFile(const aFileName: String);
var
  oFileStream: TFileStream;
begin
  oFileStream := TFileStream.Create(aFileName, fmOpenRead);
  Try
    LoadFromStream(oFileStream);
  Finally
    FreeAndNil(oFileStream);
  End;
end;

procedure TsgcSChannelStream.LoadFromStream(const aSource: TStream);
var
  i: Integer;
begin
  i := aSource.Size - aSource.Position;
  DoInitialize(i);
  aSource.Read(Data^, i);
end;

procedure TsgcSChannelConnectionInfo.SetCipher(aValue: Cardinal);
var
  i: Integer;
begin
  CipherId := aValue;

  FCipher := '';
  for i := Low(CS_SChannel_CiphersId) to High(CS_SChannel_CiphersId) do
  begin
    if CS_SChannel_CiphersId[i] = aValue then
    begin
      FCipher := CS_SChannel_Ciphers[i];
      break;
    end;
  end;
end;

procedure TsgcSChannelConnectionInfo.SetHash(aValue: Cardinal);
var
  i: Integer;
begin
  HashId := aValue;

  FHash := '';
  for i := Low(CS_SChannel_CiphersId) to High(CS_SChannel_CiphersId) do
  begin
    if CS_SChannel_CiphersId[i] = aValue then
    begin
      FHash := CS_SChannel_Ciphers[i];
      break;
    end;
  end;
end;

procedure TsgcSChannelConnectionInfo.SetExchange(aValue: Cardinal);
var
  i: Integer;
begin
  ExchangeId := aValue;

  FExchange := '';
  for i := Low(CS_SChannel_CiphersId) to High(CS_SChannel_CiphersId) do
  begin
    if CS_SChannel_CiphersId[i] = aValue then
    begin
      FExchange := CS_SChannel_Ciphers[i];
      break;
    end;
  end;
end;

procedure TsgcSChannelConnectionInfo.SetProtocol(aValue: Cardinal);
begin
  case aValue of
    SP_PROT_TLS1_CLIENT:
      FProtocol := tls1_0;
    SP_PROT_TLS1_1_CLIENT:
      FProtocol := tls1_1;
    SP_PROT_TLS1_2_CLIENT:
      FProtocol := tls1_2;
    SP_PROT_TLS1_3_CLIENT:
      FProtocol := tls1_3;
  else
    FProtocol := tlsUndefined;
  end;
end;

initialization

oValidators := nil;

finalization

FreeValidators;

end.
