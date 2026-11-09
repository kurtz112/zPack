// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-08
// ---------------------------------------------------------------------------
unit zNet.Tls;

// Punto unico di creazione dell'handler TLS per i componenti Indy
// (TIdSMTP, TIdIMAP4, TIdFTP, TIdHTTP).
//
// Le unit di zPack e delle applicazioni chiedono solo CreaIOHandlerTls e
// lavorano sul tipo base TIdSSLIOHandlerSocketBase: non sanno quale motore
// TLS c'e' sotto. Ogni implementazione concreta (oggi OpenSSL 1.0.2 tramite
// IdSSLOpenSSL in zNet.Tls.OpenSsl, e SChannel - il TLS nativo di Windows -
// in zNet.Tls.SChannel) si annuncia con RegistraProviderTls nella propria
// sezione initialization, con un codice breve che la identifica.
//
// SCELTA DEL MOTORE: e' un'impostazione dell'installazione (prodotto X sul
// server Y), non del compilatore. Entrambe le unit provider vanno incluse
// nel .dpr sempre insieme (si limitano a registrarsi, senza costo se non
// selezionate): l'applicazione, all'avvio, legge da dove tiene la propria
// configurazione (INI, tabella database, o altro - zNet.Tls non lo sa e non
// gli interessa) il codice del motore da usare e chiama una sola volta
// SelezionaProviderTls(Codice) prima di aprire la prima connessione. Da
// quel momento CreaIOHandlerTls usa sempre quel motore, per tutte le
// comunicazioni del processo. Non e' pensata per cambiare motore a
// connessioni gia' aperte o da piu' thread in corsa: e' una scelta fatta
// una volta sola all'avvio, come la connessione al database.
//
// Qui sono raccolte anche le traduzioni dei valori di configurazione letti
// dal database (colonne SSL / SSL_VER, TLS / TLS_VERSIONE, parametri PEC),
// che prima erano ripetute in piu' unit con formati diversi.

interface

uses
  System.SysUtils,
  System.Classes,
  IdSSL,
  IdExplicitTLSClientServerBase;

type
  // Versione TLS da richiedere al server. tlsVersioneDefault lascia al
  // provider la versione piu' alta che conosce (TLS 1.2 con OpenSSL 1.0.2,
  // quella negoziata da Windows con SChannel).
  TzTlsVersione = (tlsVersioneDefault, tlsVersione1_0, tlsVersione1_1, tlsVersione1_2, tlsVersione1_3);

  TzTlsVersioneHelper = record helper for TzTlsVersione
  public
    // Accetta tutti i formati presenti nei dati:
    // codici delle procedure SQL      '1', '11', '12', '13'
    // nomi della colonna TLS_VERSIONE 'TLSv1', 'TLSv1_1', 'TLSv1_2', 'TLSv1_3'
    // nomi Indy                       'sslvTLSv1_2', ...
    // valori SSL obsoleti             '2', '22', '23', '3', 'SSLv2', 'SSLv23', 'SSLv3'
    // I valori SSL e le stringhe sconosciute vengono ricondotti al default:
    // nessun server li accetta piu' e in passato producevano un risultato
    // indefinito.
    function FromString(const Valore: string): TzTlsVersione;
    function ToString: string;
  end;

  TIdUseTLSHelper = record helper for TIdUseTLS
  public
    // Accetta i codici delle procedure SQL ('N', 'I', 'E', 'R'), i valori
    // della colonna EMAIL_ACCOUNT.TLS ('NoTLS', 'ImplicitTLS', 'ExplicitTLS',
    // 'RequireTLS') e i nomi Indy ('utNoTLSSupport', 'utUseImplicitTLS', ...),
    // senza distinzione di maiuscole. Sconosciuto = nessun TLS, come prima.
    function FromString(const Valore: string): TIdUseTLS;
    function ToString: string;
  end;

  // Firma della funzione che costruisce l'handler concreto.
  // Proprietario: componente che possiede l'handler (di norma il client Indy).
  // VerificaCertificato: True = il certificato del server viene controllato;
  // oggi tutte le chiamate passano False, come il vecchio VerifyMode = [].
  TzTlsCreaIOHandler = function(Proprietario: TComponent; Versione: TzTlsVersione; VerificaCertificato: Boolean): TIdSSLIOHandlerSocketBase;

  EzTlsProviderNonRegistrato = class(Exception);
  EzTlsProviderNonSelezionato = class(Exception);

  // Alcuni motori TLS (oggi OpenSSL) cercano le proprie librerie in una
  // cartella specifica; altri (SChannel) non ne hanno bisogno perche' usano
  // il TLS di Windows. Il provider registra questa funzione solo se gli serve.
  TzTlsImpostaCartellaLibrerieTLS = procedure(const Cartella: string);

  // Registrazione di un motore TLS disponibile nel progetto: la chiama la
  // unit del provider nella propria sezione initialization. Codice e' la
  // chiave stabile usata da SelezionaProviderTls (e quindi dalla
  // configurazione dell'installazione): breve, maiuscolo per convenzione,
  // stabile fra le versioni (oggi 'OPENSSL' e 'SCHANNEL'). Descrizione e' il
  // testo esteso per registri e messaggi di collaudo. Una seconda
  // registrazione con lo stesso Codice sostituisce la prima. La
  // registrazione da sola non attiva il motore: serve comunque
  // SelezionaProviderTls.
procedure RegistraProviderTls(const Codice, Descrizione: string; CreaIOHandler: TzTlsCreaIOHandler; ImpostaCartellaLibrerieTLS: TzTlsImpostaCartellaLibrerieTLS = nil);

// Sceglie, per nome, quale motore fra quelli registrati va usato da
// CreaIOHandlerTls da questo momento in poi. Va chiamata una sola volta,
// all'avvio dell'applicazione, con il valore letto dalla configurazione
// dell'installazione (INI, tabella database o altro: a decidere e' chi
// chiama, non questa unit). Solleva EzTlsProviderNonRegistrato se il
// codice non corrisponde a nessun provider incluso nel progetto - il
// messaggio elenca quelli disponibili, utile per un refuso in
// configurazione.
procedure SelezionaProviderTls(const Codice: string);

// Codice del motore attualmente selezionato ('' se nessuno): utile per
// verificare a runtime cosa e' davvero attivo (i log non bastano, vedi
// ProviderTlsSelezionatoDescrizione per un testo piu' leggibile).
function ProviderTlsSelezionato: string;

// Descrizione estesa del motore selezionato ('' se nessuno): per i
// registri e i messaggi di collaudo.
function ProviderTlsSelezionatoDescrizione: string;

// Alias storico di ProviderTlsSelezionatoDescrizione, mantenuto per le
// unit e i test gia' scritti contro il nome precedente.
function NomeProviderTls: string;

// Codici di tutti i motori inclusi nel progetto (registrati), nell'ordine
// di registrazione. Utile per validare la configurazione dell'installazione
// e per elencare le scelte possibili nei registri di avvio.
function ElencoProviderTlsRegistrati: TArray<string>;

// Crea l'handler TLS con il motore selezionato. Solleva
// EzTlsProviderNonRegistrato se l'applicazione non ha incluso nessun
// provider nel .dpr, EzTlsProviderNonSelezionato se ne ha inclusi ma
// nessuno e' stato scelto con SelezionaProviderTls: in entrambi i casi
// meglio un errore chiaro che una connessione in chiaro.
function CreaIOHandlerTls(Proprietario: TComponent; Versione: TzTlsVersione = tlsVersioneDefault; VerificaCertificato: Boolean = False): TIdSSLIOHandlerSocketBase;

// Indica al motore TLS selezionato dove cercare le proprie librerie (oggi
// libeay32.dll/ssleay32.dll per OpenSSL). Se il motore selezionato non ne
// ha bisogno (SChannel) o non e' ancora stato scelto, non fa nulla: e'
// sempre sicuro chiamarla, anche prima di SelezionaProviderTls.
procedure ImpostaCartellaLibrerieTLS(const Cartella: string);

implementation

uses
  System.StrUtils,
  System.Generics.Collections;

type
  TProviderRegistrato = record
    Codice: string;
    Descrizione: string;
    CreaIOHandler: TzTlsCreaIOHandler;
    ImpostaCartellaLibrerieTLS: TzTlsImpostaCartellaLibrerieTLS;
  end;

var
  ProviderRegistrati: TList<TProviderRegistrato> = nil;
  IndiceProviderSelezionato: Integer = -1;

function TrovaProvider(const Codice: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if not Assigned(ProviderRegistrati) then
    Exit;
  for i := 0 to ProviderRegistrati.Count - 1 do
    if SameText(ProviderRegistrati[i].Codice, Codice) then
      Exit(i);
end;

procedure RegistraProviderTls(const Codice, Descrizione: string; CreaIOHandler: TzTlsCreaIOHandler; ImpostaCartellaLibrerieTLS: TzTlsImpostaCartellaLibrerieTLS);
var
  Voce: TProviderRegistrato;
  Indice: Integer;
begin
  if not Assigned(ProviderRegistrati) then
    ProviderRegistrati := TList<TProviderRegistrato>.Create;

  Voce.Codice := Codice;
  Voce.Descrizione := Descrizione;
  Voce.CreaIOHandler := CreaIOHandler;
  Voce.ImpostaCartellaLibrerieTLS := ImpostaCartellaLibrerieTLS;

  Indice := TrovaProvider(Codice);
  if Indice = -1 then
    ProviderRegistrati.Add(Voce)
  else
    ProviderRegistrati[Indice] := Voce; // stesso codice: valori aggiornati, indice invariato
end;

procedure SelezionaProviderTls(const Codice: string);
var
  Indice: Integer;
  Elenco: string;
begin
  Indice := TrovaProvider(Codice);
  if Indice = -1 then
  begin
    Elenco := string.Join(', ', ElencoProviderTlsRegistrati);
    if Elenco = '' then
      Elenco := '(nessuno: nessuna unit provider inclusa nel progetto)';
    raise EzTlsProviderNonRegistrato.CreateFmt('Motore TLS "%s" non riconosciuto. Motori disponibili in questo eseguibile: %s.', [Codice, Elenco]);
  end;
  IndiceProviderSelezionato := Indice;
end;

function ProviderTlsSelezionato: string;
begin
  if (IndiceProviderSelezionato >= 0) and Assigned(ProviderRegistrati) then
    Result := ProviderRegistrati[IndiceProviderSelezionato].Codice
  else
    Result := '';
end;

function ProviderTlsSelezionatoDescrizione: string;
begin
  if (IndiceProviderSelezionato >= 0) and Assigned(ProviderRegistrati) then
    Result := ProviderRegistrati[IndiceProviderSelezionato].Descrizione
  else
    Result := '';
end;

function NomeProviderTls: string;
begin
  Result := ProviderTlsSelezionatoDescrizione;
end;

function ElencoProviderTlsRegistrati: TArray<string>;
var
  i: Integer;
begin
  if not Assigned(ProviderRegistrati) then
    Exit(nil);
  SetLength(Result, ProviderRegistrati.Count);
  for i := 0 to ProviderRegistrati.Count - 1 do
    Result[i] := ProviderRegistrati[i].Codice;
end;

procedure ImpostaCartellaLibrerieTLS(const Cartella: string);
begin
  if (IndiceProviderSelezionato >= 0) and Assigned(ProviderRegistrati) and Assigned(ProviderRegistrati[IndiceProviderSelezionato].ImpostaCartellaLibrerieTLS) then
    ProviderRegistrati[IndiceProviderSelezionato].ImpostaCartellaLibrerieTLS(Cartella);
end;

function CreaIOHandlerTls(Proprietario: TComponent; Versione: TzTlsVersione; VerificaCertificato: Boolean): TIdSSLIOHandlerSocketBase;
begin
  if not Assigned(ProviderRegistrati) or (ProviderRegistrati.Count = 0) then
    raise EzTlsProviderNonRegistrato.Create('Nessun motore TLS incluso nel progetto: aggiungere al .dpr le unit dei provider (zNet.Tls.OpenSsl e/o zNet.Tls.SChannel).');

  if IndiceProviderSelezionato < 0 then
    raise EzTlsProviderNonSelezionato.CreateFmt('Nessun motore TLS selezionato: chiamare zNet.Tls.SelezionaProviderTls con il codice letto dalla configurazione dell''installazione prima di aprire connessioni. Motori disponibili: %s.',
      [string.Join(', ', ElencoProviderTlsRegistrati)]);

  Result := ProviderRegistrati[IndiceProviderSelezionato].CreaIOHandler(Proprietario, Versione, VerificaCertificato);
end;

{ TzTlsVersioneHelper }

function TzTlsVersioneHelper.FromString(const Valore: string): TzTlsVersione;
var
  Testo: string;
begin
  Testo := Valore.Trim;

  if Testo.StartsWith('sslv', True) then
    Testo := Testo.Substring(4);

  if IndexText(Testo, ['1', 'TLSv1', 'TLSv1_0']) <> -1 then
    Exit(tlsVersione1_0);

  if IndexText(Testo, ['11', 'TLSv1_1']) <> -1 then
    Exit(tlsVersione1_1);

  if IndexText(Testo, ['12', 'TLSv1_2']) <> -1 then
    Exit(tlsVersione1_2);

  if IndexText(Testo, ['13', 'TLSv1_3']) <> -1 then
    Exit(tlsVersione1_3);

  // '2', '22', '23', '3', 'SSLv2', 'SSLv23', 'SSLv3', vuoto o sconosciuto
  Result := tlsVersioneDefault;
end;

function TzTlsVersioneHelper.ToString: string;
begin
  case Self of
    tlsVersione1_0:
      Result := 'TLSv1';
    tlsVersione1_1:
      Result := 'TLSv1_1';
    tlsVersione1_2:
      Result := 'TLSv1_2';
    tlsVersione1_3:
      Result := 'TLSv1_3';
  else
    Result := 'Default';
  end;
end;

{ TIdUseTLSHelper }

function TIdUseTLSHelper.FromString(const Valore: string): TIdUseTLS;
var
  Testo: string;
begin
  Testo := Valore.Trim;

  if IndexText(Testo, ['I', 'ImplicitTLS', 'utUseImplicitTLS']) <> -1 then
    Exit(utUseImplicitTLS);

  if IndexText(Testo, ['E', 'ExplicitTLS', 'utUseExplicitTLS']) <> -1 then
    Exit(utUseExplicitTLS);

  if IndexText(Testo, ['R', 'RequireTLS', 'utUseRequireTLS']) <> -1 then
    Exit(utUseRequireTLS);

  // 'N', 'NoTLS', 'utNoTLSSupport', vuoto o sconosciuto
  Result := utNoTLSSupport;
end;

function TIdUseTLSHelper.ToString: string;
begin
  case Self of
    utUseImplicitTLS:
      Result := 'ImplicitTLS';
    utUseExplicitTLS:
      Result := 'ExplicitTLS';
    utUseRequireTLS:
      Result := 'RequireTLS';
  else
    Result := 'NoTLS';
  end;
end;

initialization

finalization

FreeAndNil(ProviderRegistrati);

end.
