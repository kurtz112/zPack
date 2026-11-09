unit zDocumentale.Messaggi.Smtp;

// Provider PEC standard: invio via SMTP/S (TzOfficeMailWriter, Indy) e
// lettura delle ricevute via IMAP/S dalla casella del mittente.
// Riusabile da entrambe le applicazioni (nessuna dipendenza applicativa);
// DESTINAZIONE: package zOffice (usa zOffice.Mail.Utils, che porta con se'
// il RichEdit DevExpress — non puo' stare in zBase_Common).
//
// Il provider non tocca mai il database: il ponte applicativo registra la
// spedizione PRIMA di Invia (stato 'P', idempotenza), trasforma gli .eml
// delle ricevute in versioni RIC della catena e applica gli stati con
// OBJ_FILES_MAIL_E_MESSAGGI_RICEVUTA_ADD. Il log passa da OnLogRequest/OnLogResponse.
//
// Parametri di configurazione (OBJ_FILES_MAIL_E_MESSAGGI_CONFIG_PARAMETRI):
// SMTP_HOST, SMTP_PORT (default 465), SMTP_SSL (S/N, default S),
// SMTP_SSL_VERSIONE (default TLSv1_2), SMTP_AUTENTICAZIONE (default LOGIN)
// IMAP_HOST, IMAP_PORT (default 993), IMAP_SSL (S/N, default S),
// IMAP_CARTELLA (default INBOX)
// LeggiRicevute rilegge tutta la cartella a ogni polling: i duplicati sono
// assorbiti dall'idempotenza di OBJ_FILES_MAIL_E_MESSAGGI_RICEVUTA_ADD (una gestione a
// "solo non letti" o per data e' un'ottimizzazione futura).
// Utente, password e casella mittente stanno in OBJ_FILES_MAIL_E_MESSAGGI_CONFIGURAZIONE.
//
// Riconoscimento delle ricevute (standard PEC): header X-Ricevuta
// (accettazione / avvenuta-consegna / non-accettazione / errore-consegna;
// preavviso-errore-consegna viene ignorato perche' non definitivo) e
// X-Riferimento-Message-ID; in mancanza degli header si legge daticert.xml
// (tag <postacert tipo=...>, <msgid>, <consegna>).
//
// Auto-registrazione: basta includere questa unit nel .dpr.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  IdIMAP4,
  IdMessage,
  IdMessageParts,
  IdAttachment,
  IdExplicitTLSClientServerBase,
  IdSSL,
  zNet.Tls,
  zOffice.types,
  zOffice.Mail.Utils,
  zDocumentale.Messaggi.types,
  zDocumentale.Messaggi.Intf,
  zDocumentale.Messaggi.ProviderBase,
  zDocumentale.Messaggi.Factory;

const
  MESSAGGIO_FORNITORE_SMTP = 'SMTP';

type
  TzMessaggioSmtpProvider = class(TzMessaggioProviderBase)
  private
    function ParametroBoolean(const Chiave: string; const Default: Boolean): Boolean;
    function ParametroIntero(const Chiave: string; const Default: Integer): Integer;

    function CostruisciSmtpParams: TSMTPServerParams;
    function CreaImap: TIdIMAP4;

    // estrae i dati della ricevuta da un messaggio della casella;
    // False = il messaggio non e' una ricevuta PEC (o non e' definitiva)
    function EstraiRicevuta(IdMessage: TIdMessage; out Ricevuta: TzMessaggioRicevuta): Boolean;
  public
    function Nome: string; override;
    function Funzionalita: TzMessaggioFunzionalitaSet; override;
    procedure TestConnessione; override;

    function Invia(const Messaggio: TzMessaggio): TzMessaggioEsito; override;
    function LeggiRicevute(const MessageIds: TArray<string>): TArray<TzMessaggioRicevuta>; override;
  end;

implementation

// il confronto tra Message-ID ignora le parentesi angolari e il maiuscolo
function NormalizzaMessageId(const MessageId: string): string;
begin
  result := MessageId.Trim.TrimLeft(['<']).TrimRight(['>']).ToUpper;
end;

// estrae il contenuto del primo tag XML richiesto (parsing leggero di
// daticert.xml: struttura piatta e controllata dallo standard PEC)
function ContenutoTag(const Xml, Tag: string): string;
var
  inizio: Integer;
  fine: Integer;
begin
  result := '';
  inizio := Xml.ToLower.IndexOf('<' + Tag.ToLower);
  if inizio < 0 then
    exit;
  inizio := Xml.IndexOf('>', inizio);
  if inizio < 0 then
    exit;
  fine := Xml.ToLower.IndexOf('</' + Tag.ToLower, inizio);
  if fine < 0 then
    exit;
  result := Xml.Substring(inizio + 1, fine - inizio - 1).Trim;
end;

// estrae il valore di un attributo dal primo tag richiesto
function AttributoTag(const Xml, Tag, Attributo: string): string;
var
  inizioTag: Integer;
  fineTag: Integer;
  inizioValore: Integer;
  fineValore: Integer;
  testoTag: string;
begin
  result := '';
  inizioTag := Xml.ToLower.IndexOf('<' + Tag.ToLower);
  if inizioTag < 0 then
    exit;
  fineTag := Xml.IndexOf('>', inizioTag);
  if fineTag < 0 then
    exit;
  testoTag := Xml.Substring(inizioTag, fineTag - inizioTag);
  inizioValore := testoTag.ToLower.IndexOf(Attributo.ToLower + '="');
  if inizioValore < 0 then
    exit;
  inizioValore := inizioValore + Attributo.Length + 2;
  fineValore := testoTag.IndexOf('"', inizioValore);
  if fineValore < 0 then
    exit;
  result := testoTag.Substring(inizioValore, fineValore - inizioValore).Trim;
end;

{ TzMessaggioSmtpProvider }

function TzMessaggioSmtpProvider.Nome: string;
begin
  result := MESSAGGIO_FORNITORE_SMTP;
end;

function TzMessaggioSmtpProvider.Funzionalita: TzMessaggioFunzionalitaSet;
begin
  result := [pecInvia, pecLeggiRicevute];
end;

function TzMessaggioSmtpProvider.ParametroBoolean(const Chiave: string; const Default: Boolean): Boolean;
begin
  result := SameText(FConfigurazione.Parametro(Chiave, IfThen(Default, 'S', 'N')), 'S');
end;

function TzMessaggioSmtpProvider.ParametroIntero(const Chiave: string; const Default: Integer): Integer;
begin
  result := StrToIntDef(FConfigurazione.Parametro(Chiave, Default.ToString), Default);
end;

function TzMessaggioSmtpProvider.CostruisciSmtpParams: TSMTPServerParams;
begin
  result.Init;
  result.From := FConfigurazione.IndirizzoMittente;
  result.FromAddress := FConfigurazione.IndirizzoMittente;
  result.Host := FConfigurazione.Parametro('SMTP_HOST');
  result.Port := ParametroIntero('SMTP_PORT', 465);
  result.UserName := FConfigurazione.Utente;
  result.Password := FConfigurazione.Password;
  result.AuthenticationType := FConfigurazione.Parametro('SMTP_AUTENTICAZIONE', 'LOGIN');
  // codici delle procedure SQL: 'I' = TLS implicito (porta 465), 'N' = nessuno.
  // Prima venivano passati i nomi Indy, che il traduttore non riconosceva
  // e riconduceva a 'nessun TLS'.
  result.Ssl := IfThen(ParametroBoolean('SMTP_SSL', True), 'I', 'N');
  result.Ssl_Ver := FConfigurazione.Parametro('SMTP_SSL_VERSIONE', 'TLSv1_2');

  if result.Host.IsEmpty then
    raise EzMessaggioErrore.Create('PEC: parametro SMTP_HOST non configurato');
end;

function TzMessaggioSmtpProvider.CreaImap: TIdIMAP4;
var
  socketTls: TIdSSLIOHandlerSocketBase;
begin
  result := TIdIMAP4.Create(nil);
  try
    result.Host := FConfigurazione.Parametro('IMAP_HOST');
    result.Port := ParametroIntero('IMAP_PORT', 993);
    result.UserName := FConfigurazione.Utente;
    result.Password := FConfigurazione.Password;

    if result.Host.IsEmpty then
      raise EzMessaggioErrore.Create('PEC: parametro IMAP_HOST non configurato');

    if ParametroBoolean('IMAP_SSL', True) then
    begin
      socketTls := CreaIOHandlerTls(result, tlsVersione1_2);
      result.IOHandler := socketTls;
      result.UseTLS := utUseImplicitTLS;
    end;
  except
    FreeAndNil(result);
    raise;
  end;
end;

procedure TzMessaggioSmtpProvider.TestConnessione;
var
  imap: TIdIMAP4;
begin
  // l'invio non ha un handshake separabile: si verifica la casella IMAP
  imap := CreaImap;
  try
    imap.Connect;
    imap.Disconnect;
  finally
    FreeAndNil(imap);
  end;
end;

function TzMessaggioSmtpProvider.Invia(const Messaggio: TzMessaggio): TzMessaggioEsito;
var
  writer: TzOfficeMailWriter;
  Mail: TMail;
  smtpParams: TSMTPServerParams;
  allegato: TzMessaggioAllegato;
  destinatario: TzMessaggioDestinatario;
  destinatariA: string;
  destinatariC: string;
  allegati: string;
  MessageId: string;
  idLogRequest: Int64;
begin
  result.Clear;

  destinatariA := '';
  destinatariC := '';
  for destinatario in Messaggio.Destinatari do
    if destinatario.Tipo = pdDestinatario then
      destinatariA := destinatariA + IfThen(destinatariA.IsEmpty, '', ';') + destinatario.Indirizzo
    else
      destinatariC := destinatariC + IfThen(destinatariC.IsEmpty, '', ';') + destinatario.Indirizzo;

  if destinatariA.IsEmpty then
    raise EzMessaggioErrore.Create('PEC: nessun destinatario principale');

  allegati := '';
  for allegato in Messaggio.allegati do
  begin
    if allegato.FullFileName.IsEmpty or not TFile.Exists(allegato.FullFileName) then
      raise EzMessaggioErrore.CreateFmt('PEC: allegato non trovato: "%s"', [allegato.FullFileName]);
    allegati := allegati + IfThen(allegati.IsEmpty, '', ';') + allegato.FullFileName;
  end;

  Mail.Init;
  Mail.A := destinatariA;
  Mail.CC := destinatariC;
  Mail.Oggetto := Messaggio.Oggetto;
  Mail.CorpoTxt := Messaggio.Corpo;
  Mail.allegati := allegati;

  smtpParams := CostruisciSmtpParams;

  writer := TzOfficeMailWriter.Create(nil);
  try
    idLogRequest := LogRequest('INVIO', smtpParams.Host + ':' + smtpParams.Port.ToString, 'A: ' + destinatariA + IfThen(destinatariC.IsEmpty, '', ' CC: ' + destinatariC) + ' Oggetto: ' + Messaggio.Oggetto);
    try
      if not writer.SendMail(Mail, smtpParams, MessageId) then
        raise EzMessaggioErrore.Create('PEC: il server SMTP ha rifiutato l''invio');
    except
      on E: Exception do
      begin
        LogResponse(idLogRequest, 0, '', E.Message);
        raise;
      end;
    end;
    LogResponse(idLogRequest, 0, 'Message-ID: ' + MessageId, '');
  finally
    FreeAndNil(writer);
  end;

  result.Ok := True;
  result.Stato := MESSAGGIO_STATO_INVIATA; // 'I': in attesa delle ricevute
  result.StatoEsterno := 'Inviata al gestore';
  result.MessageId := MessageId;
end;

function TzMessaggioSmtpProvider.EstraiRicevuta(IdMessage: TIdMessage; out Ricevuta: TzMessaggioRicevuta): Boolean;
var
  tipoRicevuta: string;
  riferimento: string;
  datiCert: string;
  indiceParte: Integer;
  parte: TIdMessagePart;
  streamDati: TStringStream;
begin
  result := False;
  Ricevuta.Clear;

  tipoRicevuta := IdMessage.Headers.Values['X-Ricevuta'].Trim.ToLower;
  riferimento := IdMessage.Headers.Values['X-Riferimento-Message-ID'].Trim;

  // fallback: daticert.xml allegato alla ricevuta
  if tipoRicevuta.IsEmpty or riferimento.IsEmpty then
    for indiceParte := 0 to IdMessage.MessageParts.Count - 1 do
    begin
      parte := IdMessage.MessageParts.Items[indiceParte];
      if parte is TIdAttachment then
        if SameText(TIdAttachment(parte).FileName, 'daticert.xml') then
        begin
          streamDati := TStringStream.Create('', TEncoding.UTF8);
          try
            TIdAttachment(parte).SaveToStream(streamDati);
            datiCert := streamDati.DataString;
          finally
            FreeAndNil(streamDati);
          end;

          if tipoRicevuta.IsEmpty then
            tipoRicevuta := AttributoTag(datiCert, 'postacert', 'tipo').ToLower;
          if riferimento.IsEmpty then
            riferimento := ContenutoTag(datiCert, 'msgid');
          if Ricevuta.IndirizzoDestinatario.IsEmpty then
            Ricevuta.IndirizzoDestinatario := ContenutoTag(datiCert, 'consegna');
          break;
        end;
    end;

  if tipoRicevuta.IsEmpty or riferimento.IsEmpty then
    exit; // non e' una ricevuta PEC

  if tipoRicevuta = 'accettazione' then
    Ricevuta.Tipo := prAccettazione
  else
    if tipoRicevuta = 'avvenuta-consegna' then
      Ricevuta.Tipo := prConsegna
    else
      if tipoRicevuta = 'non-accettazione' then
        Ricevuta.Tipo := prNonAccettazione
      else
        if (tipoRicevuta = 'errore-consegna') or (tipoRicevuta = 'rilevazione-virus') then
          Ricevuta.Tipo := prMancataConsegna
        else
          exit; // preavviso-errore-consegna e altri tipi non definitivi

  Ricevuta.MessageId := riferimento;
  Ricevuta.DataOra := IdMessage.Date;

  // per consegna/mancata consegna il destinatario, se non gia' letto da
  // daticert, e' il TO della ricevuta originale (best effort)
  if Ricevuta.IndirizzoDestinatario.IsEmpty then
    if Ricevuta.Tipo in [prConsegna, prMancataConsegna] then
      if IdMessage.Recipients.Count > 0 then
        Ricevuta.IndirizzoDestinatario := IdMessage.Recipients.Items[0].Address;

  result := True;
end;

function TzMessaggioSmtpProvider.LeggiRicevute(const MessageIds: TArray<string>): TArray<TzMessaggioRicevuta>;
var
  imap: TIdIMAP4;
  IdMessage: TIdMessage;
  Ricevuta: TzMessaggioRicevuta;
  cartella: string;
  numeroMessaggi: Integer;
  indice: Integer;
  richiesti: TArray<string>;
  MessageId: string;
  interessa: Boolean;
  fileTemporaneo: string;
  idLogRequest: Int64;
begin
  result := nil;

  SetLength(richiesti, Length(MessageIds));
  for indice := 0 to High(MessageIds) do
    richiesti[indice] := NormalizzaMessageId(MessageIds[indice]);

  cartella := FConfigurazione.Parametro('IMAP_CARTELLA', 'INBOX');

  imap := CreaImap;
  try
    idLogRequest := LogRequest('RICEVUTE', imap.Host + ':' + imap.Port.ToString, 'Cartella: ' + cartella);
    try
      imap.Connect;
      try
        if not imap.SelectMailBox(cartella) then
          raise EzMessaggioErrore.CreateFmt('PEC: cartella IMAP "%s" non selezionabile', [cartella]);

        numeroMessaggi := imap.MailBox.TotalMsgs;

        for indice := 1 to numeroMessaggi do
        begin
          IdMessage := TIdMessage.Create(nil);
          try
            if not imap.Retrieve(indice, IdMessage) then
              continue;

            if not EstraiRicevuta(IdMessage, Ricevuta) then
              continue;

            // filtro sui message-id richiesti (elenco vuoto = tutte)
            if Length(richiesti) > 0 then
            begin
              interessa := False;
              for MessageId in richiesti do
                if MessageId = NormalizzaMessageId(Ricevuta.MessageId) then
                begin
                  interessa := True;
                  break;
                end;
              if not interessa then
                continue;
            end;

            // l'.eml integrale (firmato dal gestore) in un temporaneo: il
            // ponte lo trasforma in versione RIC e poi lo elimina
            fileTemporaneo := TPath.ChangeExtension(TPath.GetTempFileName, '.eml');
            IdMessage.SaveToFile(fileTemporaneo);
            Ricevuta.FileRicevuta := fileTemporaneo;

            result := result + [Ricevuta];
          finally
            FreeAndNil(IdMessage);
          end;
        end;
      finally
        imap.Disconnect;
      end;
    except
      on E: Exception do
      begin
        LogResponse(idLogRequest, 0, '', E.Message);
        raise;
      end;
    end;
    LogResponse(idLogRequest, 0, 'Ricevute trovate: ' + Length(result).ToString, '');
  finally
    FreeAndNil(imap);
  end;
end;

initialization

TzMessaggioFactory.Registra(MESSAGGIO_FORNITORE_SMTP, TzMessaggioSmtpProvider);

end.
