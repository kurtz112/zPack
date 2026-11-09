unit zOffice.Mail.Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  IdBaseComponent,
  IdMessage,
  IdAttachmentFile,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdExplicitTLSClientServerBase,
  IdMessageClient,
  IdSMTPBase,
  IdSMTP,
  IdSASL,
  IdUserPassProvider,
  dxRichEdit.Control,
  zOffice.types,
  zNet.Tls,
  zProgressBox,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TIdAttachmentFileHelper = class helper for TIdAttachmentFile
  private
    function GetImageIndex: integer;
    function GetFileType: TzFileType;
    function GetCid: string;

    function GetIsImage: boolean;
    function GetIsContentImage: boolean;
    function GetIsRealAttachemnt: boolean;
  public
    procedure ShowAttachmentFile;

    property cid: string read GetCid;
    property FileType: TzFileType read GetFileType;
    property ImageIndex: integer read GetImageIndex;

    property IsImage: boolean read GetIsImage;

    property IsContentImage: boolean read GetIsContentImage;

    property IsRealAttachemnt: boolean read GetIsRealAttachemnt;
  end;

  // le traduzioni dei valori TLS letti dal database (TIdUseTLS e
  // TzTlsVersione) stanno in zNet.Tls, insieme alla fabbrica dell'handler

  TIdSMTPAuthenticationTypeHelper = record helper for TIdSMTPAuthenticationType
  public
    function FromString(const s: string): TIdSMTPAuthenticationType;
  end;

  TIdSASLClass = class of TIdSASL;

  // TIdMessagePriority = (mpHighest, mpHigh, mpNormal, mpLow, mpLowest);
  // TIdMessagePriorityHelper = record helper for TIdMessagePriority
  // end;

  TzOfficeMailReader = class(TObject)
  private
    FAttachments: TList<TIdAttachmentFile>;
    FContentImages: TDictionary<string, string>;
    FIdMessage: TIdMessage;
    FMessageBody: string;
    FMessageDate: TDateTime;
    FMessageFrom: string;
    FMessageBodyIsHTML: boolean;
    FMessageCC: string;
    FMessageCCN: string;
    FMessageSubject: string;
    FMessageTo: string;
    function GetAttachmentTempDirectory: string;
    procedure SetAttachmentTempDirectory(const Value: string);
  private
    function GetMessageBodyAsText: string;
    procedure ParseAttachments;
    procedure PrepareImageUriStreamProvider(dxRichEditControl: TdxRichEditControl);

    function LoadHTML: string;
    procedure LoadBody;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearFolder;
    procedure LoadFileEML(const FileName: String; dxRichEditControl: TdxRichEditControl);
    procedure GetMessagePartsInfo(Strings: TStrings);
  public
    property IdMessage: TIdMessage read FIdMessage;
    property AttachmentTempDirectory: string read GetAttachmentTempDirectory write SetAttachmentTempDirectory;

    property MessageFrom: string read FMessageFrom;
    property MessageTo: string read FMessageTo;
    property MessageCC: string read FMessageCC;
    property MessageCCN: string read FMessageCCN;
    property MessageSubject: string read FMessageSubject;
    property MessageDate: TDateTime read FMessageDate;
    property MessageBody: string read FMessageBody;
    property MessageBodyAsText: string read GetMessageBodyAsText;
    property MessageBodyIsHTML: boolean read FMessageBodyIsHTML;

    property ContentImages: TDictionary<string, string> read FContentImages;
    property Attachments: TList<TIdAttachmentFile> read FAttachments;
  end;

  TzOfficeMailWriter = class(TComponent)
  private
    LogProc: TProc<string>;
    procedure Log(const AName: UnicodeString; const AValue: String);
    procedure Progress(s: string; ProgressBox: TProgressBox);
    procedure IdSMTPStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IOHandlerTlsStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdLogEventStatus(ASender: TComponent; const AText: string);
    procedure IdLogEventSent(ASender: TComponent; const AText, AData: string);
    procedure IdLogEventReceived(ASender: TComponent; const AText, AData: string);
  private
    function CreateMessage(Mail: TMail; params: TSMTPServerParams): TIdMessage;
    function MsgID(const address: string): string;
  private
    SMTP: TIdSMTP;
    SocketTls: TIdSSLIOHandlerSocketBase;
  private
    procedure ConnectSMTPServer(params: TSMTPServerParams; ProgressBox: TProgressBox);
    procedure DisconnectSMTPServer(ProgressBox: TProgressBox);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function SendMail(Mail: TMail; params: TSMTPServerParams; ProgressBox: TProgressBox = nil; aLogProc: TProc<string> = nil): boolean; overload;

    // overload per la PEC (zDocumentale.Messaggi.Smtp): imposta un Message-ID
    // proprio sul messaggio e lo ritorna — le ricevute del gestore
    // referenziano l'invio proprio tramite quel Message-ID
    function SendMail(Mail: TMail; params: TSMTPServerParams; out MessageId: string; ProgressBox: TProgressBox = nil; aLogProc: TProc<string> = nil): boolean; overload;
  end;

implementation

uses
  System.IOUtils,
  System.DateUtils,
  System.StrUtils,
  Vcl.Forms,
  REST.types,
  IdText,
  IdMessageParts,
  IdGlobal,
  IdSASLLogin,
  IdEMailAddress,
  IdSASLAnonymous,
  IdSASLDigest,
  IdSASLOTP,
  IdSASL_CRAM_MD5,
  IdSASLPlain,
  IdSASL_CRAM_SHA1,
  IdSASLSKey,
  IdLogEvent,
  dxRichEdit.Utils.UriStreamService,
  zOffice.Word.UriStreamProvider,
  zOffice,
  IdSASLUserPass;

{ TIdAttachmentFileHelper }

function TIdAttachmentFileHelper.GetCid: string;
begin
  Result := ContentID;

  if Result.StartsWith('<') and Result.EndsWith('>') then
  begin
    Result := Result.Replace('<', '', []);
    Result := Result.Remove(Result.Length - 1);
  end;
end;

function TIdAttachmentFileHelper.GetFileType: TzFileType;
begin
  Result := TzFileType.FromFileName(FileName);
end;

function TIdAttachmentFileHelper.GetImageIndex: integer;
begin
  Result := FileType.ImageIndex;
end;

function TIdAttachmentFileHelper.GetIsImage: boolean;
begin
  Result := IndexText(ContentType, [CONTENTTYPE_IMAGE_GIF, CONTENTTYPE_IMAGE_JPEG, CONTENTTYPE_IMAGE_PJPEG, CONTENTTYPE_IMAGE_PNG, CONTENTTYPE_IMAGE_SVG_XML, CONTENTTYPE_IMAGE_TIFF]) <> -1;
end;

function TIdAttachmentFileHelper.GetIsContentImage: boolean;
begin
  Result := IsImage and (not ContentID.IsEmpty);
end;

function TIdAttachmentFileHelper.GetIsRealAttachemnt: boolean;
begin
  Result := not(IsImage and (not ContentID.IsEmpty));
end;

procedure TIdAttachmentFileHelper.ShowAttachmentFile;
var
  TmpFileName: string;
begin

  TmpFileName := IncludeTrailingPathDelimiter(ExtractFilePath(StoredPathName)) + FileName;

  if FileExists(TmpFileName) then
    TFile.Delete(TmpFileName);

  TFile.Copy(StoredPathName, TmpFileName);
  try
    ViewFile(TmpFileName);
  finally
    // i tipi non gestiti si aprono col programma di sistema e ViewFile torna subito:
    // eliminare la copia ora la toglierebbe al programma prima che la apra
    if TzFileType.FromFileName(TmpFileName) <> ftNone then
      TFile.Delete(TmpFileName);
  end;
end;

{ TIdSMTPAuthenticationTypeHelper }

function TIdSMTPAuthenticationTypeHelper.FromString(const s: string): TIdSMTPAuthenticationType;
begin
  Result := satNone;

  if s = 'N' then
    Result := satNone
  else
    if s = 'D' then
      Result := satDefault
    else
      if s = 'S' then
        Result := satSASL;
end;

{ TzOfficeMailReader }

constructor TzOfficeMailReader.Create;
begin
  inherited;
  FMessageFrom := '';
  FMessageTo := '';
  FMessageCC := '';
  FMessageCCN := '';
  FMessageSubject := '';
  FMessageDate := 0;
  FMessageBody := '';
  FMessageBodyIsHTML := false;

  FIdMessage := TIdMessage.Create(nil);
  FContentImages := TDictionary<string, string>.Create;
  FAttachments := TList<TIdAttachmentFile>.Create;
end;

destructor TzOfficeMailReader.Destroy;
begin
  inherited;
  FreeAndNil(FIdMessage);
  FreeAndNil(FContentImages);
  FreeAndNil(FAttachments);
end;

function TzOfficeMailReader.GetAttachmentTempDirectory: string;
begin
  Result := IdMessage.AttachmentTempDirectory;
end;

procedure TzOfficeMailReader.SetAttachmentTempDirectory(const Value: string);
begin
  IdMessage.AttachmentTempDirectory := Value;
end;

procedure TzOfficeMailReader.ClearFolder;
begin
  { TODO : Implementare }
end;

function TzOfficeMailReader.GetMessageBodyAsText: string;
begin
  Result := MessageBody;

  if MessageBodyIsHTML then
  begin

  end;
end;

procedure TzOfficeMailReader.LoadBody;
begin
  FMessageBody := LoadHTML;
  FMessageBodyIsHTML := not FMessageBody.IsEmpty;

  if not MessageBodyIsHTML then
    FMessageBody := IdMessage.body.Text;
end;

function TzOfficeMailReader.LoadHTML: string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to IdMessage.MessageParts.Count - 1 do
    if IdMessage.MessageParts.Items[i].ContentType = 'text/html' then
      Result := Result + TIdText(IdMessage.MessageParts[i]).body.Text;

  siMain.logString('HTML', Result);

  // Se serve per debug
  // TFile.WriteAllText(IncludeTrailingBackslash(IdMessage.AttachmentTempDirectory) + '__body.html', Result);
end;

procedure TzOfficeMailReader.LoadFileEML(const FileName: String; dxRichEditControl: TdxRichEditControl);
var
  i: integer;
  body: string;
begin
  ClearFolder;
  Attachments.Clear;
  ContentImages.Clear;

  /// //////////////////////////////

  IdMessage.LoadFromFile(FileName);
  // http://www.e-iter.net/knowledge/indy9/007544.html#0004
  FMessageFrom := IdMessage.from.address;
  FMessageTo := IdMessage.Recipients.EMailAddresses;
  FMessageCC := IdMessage.CCList.EMailAddresses;
  FMessageCCN := IdMessage.BCCList.EMailAddresses;

  FMessageSubject := IdMessage.Subject;
  FMessageDate := IdMessage.Date;

  LoadBody;

  ParseAttachments;

  if assigned(dxRichEditControl) then
    PrepareImageUriStreamProvider(dxRichEditControl);
end;

procedure TzOfficeMailReader.ParseAttachments;
var
  i: integer;
  s: String;
  AttachmentFile: TIdAttachmentFile;
  ext: string;
  FileName: string;
begin
  Attachments.Clear;
  ContentImages.Clear;

  for i := 0 to IdMessage.MessageParts.Count - 1 do
    if IdMessage.MessageParts.Items[i] is TIdAttachmentFile then
    begin
      AttachmentFile := TIdAttachmentFile(IdMessage.MessageParts.Items[i]);
      FileName := AttachmentFile.StoredPathName;

      if AttachmentFile.IsContentImage then //
      begin
        if not ContentImages.ContainsKey(AttachmentFile.cid) then
          ContentImages.Add(AttachmentFile.cid, FileName);
      end
      else
        Attachments.Add(AttachmentFile);
    end;
end;

procedure TzOfficeMailReader.PrepareImageUriStreamProvider(dxRichEditControl: TdxRichEditControl);
var
  Service: IdxUriStreamService;
  Provider: TImageUriStreamProvider;

  procedure AddImage(const aUri, FileName: string);
  var
    Stream: TFileStream;
  begin
    Stream := TFileStream.Create(FileName, fmOpenRead);
    try
      Stream.Position := 0;
      Provider.AddImageStream('cid:' + aUri, Stream);
    finally
      FreeAndNil(Stream);
    end;
  end;

var
  key: string;
begin
  Assert(assigned(dxRichEditControl));

  Provider := TImageUriStreamProvider.Create;

  for key in ContentImages.Keys do
    AddImage(key, ContentImages[key]);

  Service := dxRichEditControl.InnerControl.GetService<IdxUriStreamService>;
  Service.RegisterProvider(Provider);
end;

procedure TzOfficeMailReader.GetMessagePartsInfo(Strings: TStrings);
var
  IdMessagePart: TIdMessagePart;
  i: integer;
  s: string;
begin
  Assert(assigned(Strings));

  Strings.Clear;

  for i := 0 to IdMessage.MessageParts.Count - 1 do
  begin
    IdMessagePart := IdMessage.MessageParts.Items[i];

    s := 'ContentType: ' + IdMessagePart.ContentType;
    s := s + ' - ' + 'ContentID: ' + IdMessagePart.ContentID;
    s := s + ' - ' + 'FileName: ' + IdMessagePart.FileName;
    s := s + ' - ' + 'ContentLocation: ' + IdMessagePart.ContentLocation;
    s := s + ' - ' + 'ContentTransfer: ' + IdMessagePart.ContentTransfer;
    s := s + ' - ' + 'ClassName: ' + IdMessagePart.ClassName;

    Strings.Add(s);
  end;
end;

{ TzOfficeMailWriter }

constructor TzOfficeMailWriter.Create(aOwner: TComponent);
begin
  inherited;
  SMTP := nil;
  SocketTls := nil;
  LogProc := nil;
end;

destructor TzOfficeMailWriter.Destroy;
begin
  FreeAndNil(SMTP);
  FreeAndNil(SocketTls);
  inherited;
end;

procedure TzOfficeMailWriter.ConnectSMTPServer(params: TSMTPServerParams; ProgressBox: TProgressBox);
var
  IdSASLLogin: TIdSASLLogin;
  SASLAnonymous: TIdSASLAnonymous;
  SASLDigest: TIdSASLDigest;
  SASLLogin: TIdSASLLogin;
  SASLOTP: TIdSASLOTP;
  SASLMD5: TIdSASLCRAMMD5;
  SASLPlain: TIdSASLPlain;
  SASLSHA1: TIdSASLCRAMSHA1;
  SASLSkey: TIdSASLSKey;
  UserPassProvider: TIdUserPassProvider;
  AuthenticationType: TIdSMTPAuthenticationType;
  ModalitaTls: TIdUseTLS;
  VersioneTls: TzTlsVersione;
  IdLogEvent: TIdLogEvent;

  procedure AddSASL(IdSASLClass: TIdSASLClass);
  var
    IdSASL: TIdSASL;
  begin
    IdSASL := IdSASLClass.Create(SMTP);
    SMTP.SASLMechanisms.Add.SASL := IdSASL;

    if IdSASL is TIdSASLUserPass then
      TIdSASLUserPass(IdSASL).UserPassProvider := UserPassProvider;
  end;

begin

  if assigned(ProgressBox) then
  begin
    ProgressBox.MaxValue := 3;
    ProgressBox.Show;
  end;

  AuthenticationType := AuthenticationType.FromString(params.AuthenticationType);
  ModalitaTls := ModalitaTls.FromString(params.ssl);
  VersioneTls := VersioneTls.FromString(params.ssl_ver);

  // l'handler TLS lo costruisce il provider registrato in zNet.Tls:
  // questa unit non conosce il motore (OpenSSL oggi, SChannel domani)
  SocketTls := CreaIOHandlerTls(Self, VersioneTls);
  SocketTls.OnStatus := IOHandlerTlsStatus;
  SocketTls.MaxLineAction := maException;

  SMTP := TIdSMTP.Create(Self);
  SMTP.IOHandler := SocketTls;
  SMTP.OnStatus := IdSMTPStatus;
  SMTP.ConnectTimeout := 30000;
  SMTP.useTLS := ModalitaTls; // prima di settare la porta, potrebbe variarla
  SMTP.Host := params.Host;
  SMTP.Port := params.Port;
  SMTP.Username := params.Username;
  SMTP.Password := params.Password;
  SMTP.AuthType := AuthenticationType;
  SMTP.UseEhlo := True; // (https://stackoverflow.com/questions/17734414/using-indy-10-smtp-with-office365)

  UserPassProvider := TIdUserPassProvider.Create;
  UserPassProvider.Username := params.Username;
  UserPassProvider.Password := params.Password;

  // SASL mechanisms are declared and added in descending order of security
  // (as far as that can be known -- not all units give a value for FSecurityLevel).
  AddSASL(TIdSASLOTP);
  AddSASL(TIdSASLSKey);
  AddSASL(TIdSASLCRAMSHA1);
  AddSASL(TIdSASLCRAMMD5);
  AddSASL(TIdSASLLogin);
  AddSASL(TIdSASLDigest);
  AddSASL(TIdSASLPlain);
  AddSASL(TIdSASLAnonymous); // (least secure)

  SMTP.ValidateAuthLoginCapability := false;

  IdLogEvent := TIdLogEvent.Create(SMTP);
  IdLogEvent.OnStatus := IdLogEventStatus;
  IdLogEvent.OnSent := IdLogEventSent;
  IdLogEvent.OnReceived := IdLogEventReceived;

  SMTP.Intercept := IdLogEvent;
  IdLogEvent.Active := True;

  SMTP.Connect;
end;

procedure TzOfficeMailWriter.DisconnectSMTPServer(ProgressBox: TProgressBox);
begin
  Progress('Disconnessione', ProgressBox);

  if SMTP.Connected then
    SMTP.Disconnect;

  if assigned(ProgressBox) then
    ProgressBox.Close;
end;

procedure TzOfficeMailWriter.Progress(s: string; ProgressBox: TProgressBox);
begin
  Application.ProcessMessages;

  if assigned(ProgressBox) then
    ProgressBox.IncProgress(s);

  { TODO : Se annullano bloccare il processo }
end;

function TzOfficeMailWriter.CreateMessage(Mail: TMail; params: TSMTPServerParams): TIdMessage;
var
  addressItem: TIdEMailAddressItem;
  Allegato: string;
  i: integer;
  IdAttachmentFile: TIdAttachmentFile;
  textPart: TIdText;
  s: String;
  StringList: TStringList;
begin
  Result := TIdMessage.Create;
  try
    Result.Subject := Mail.Oggetto;
    Result.from.Name := params.from;
    Result.from.address := params.FromAddress;
    Result.ReplyTo.EMailAddresses := params.ReplyTo;

    if Mail.ConfermaLettura then
      Result.ReceiptRecipient.Text := params.ReceiptRecipient;

    for s in Mail.A.Replace(',', ';', [rfReplaceAll]).Split([';']) do
    begin
      addressItem := Result.Recipients.Add;
      addressItem.address := s;
      addressItem.Name := s;
    end;

    for s in Mail.CC.Replace(',', ';', [rfReplaceAll]).Split([';']) do
    begin
      addressItem := Result.CCList.Add;
      addressItem.address := s;
      addressItem.Name := s;
    end;

    for s in Mail.CCN.Replace(',', ';', [rfReplaceAll]).Split([';']) do
    begin
      addressItem := Result.BCCList.Add;
      addressItem.address := s;
      addressItem.Name := s;
    end;

    Result.ContentType := 'multipart/mixed';
    Result.CharSet := 'utf-8';
    Result.ContentTransferEncoding := 'base64';

    textPart := TIdText.Create(Result.MessageParts, nil);
    textPart.ContentType := 'multipart/alternative';

    // Corpo TXT
    textPart := TIdText.Create(Result.MessageParts, nil);
    textPart.ContentType := 'text/plain';
    textPart.CharSet := 'utf-8';
    textPart.ContentTransfer := 'quoted-printable';
    textPart.body.Text := Mail.CorpoTxt;
    textPart.ParentPart := 0;

    // Corpo HTML
    textPart := TIdText.Create(Result.MessageParts, nil);
    textPart.ContentType := 'text/html';
    textPart.CharSet := 'utf-8';

    if not Mail.CorpoHtml.IsEmpty then
      textPart.body.Text := Mail.CorpoHtml
    else
    begin
      textPart.body.Text := Mail.CorpoTxt;
      textPart.body.Text := textPart.body.Text.Replace(sLineBreak, '<br>', [rfReplaceAll]);
    end;

    textPart.ParentPart := 0;

    // Allegati
    for Allegato in Mail.Allegati.Split([';']) do
      if not Allegato.Trim.IsEmpty then
        IdAttachmentFile := TIdAttachmentFile.Create(Result.MessageParts, Allegato);

    Result.Priority := Mail.Priorita;
    Result.MsgID := MsgID(Result.from.address);
  except
    Result.Free;
    raise;
  end;
end;

procedure TzOfficeMailWriter.IdLogEventReceived(ASender: TComponent; const AText, AData: string);
begin
  Log('IdLogEventReceived', AText + ' - ' + AData);
end;

function TzOfficeMailWriter.SendMail(Mail: TMail; params: TSMTPServerParams; ProgressBox: TProgressBox = nil; aLogProc: TProc<string> = nil): boolean;
var
  IdMessage: TIdMessage;
begin
  Result := false;

  LogProc := aLogProc;

  IdMessage := CreateMessage(Mail, params);
  try
    ConnectSMTPServer(params, ProgressBox);
    try
      Progress('Autenticazione', ProgressBox);

      if SMTP.Authenticate then
      begin
        Progress('Invio', ProgressBox);
        SMTP.Send(IdMessage);
        Result := True;
      end;
    finally
      DisconnectSMTPServer(ProgressBox);
    end;
  finally
    FreeAndNil(IdMessage);
  end;
end;

function TzOfficeMailWriter.SendMail(Mail: TMail; params: TSMTPServerParams; out MessageId: string; ProgressBox: TProgressBox = nil; aLogProc: TProc<string> = nil): boolean;
var
  IdMessage: TIdMessage;
begin
  Result := false;
  MessageId := '';

  LogProc := aLogProc;

  IdMessage := CreateMessage(Mail, params);
  try
    // Message-ID generato in casa e impostato sul messaggio: le ricevute
    // PEC del gestore lo referenziano (X-Riferimento-Message-ID / daticert)
    IdMessage.MsgId := '<' + MsgID(params.FromAddress) + '>';
    MessageId := IdMessage.MsgId;

    ConnectSMTPServer(params, ProgressBox);
    try
      Progress('Autenticazione', ProgressBox);

      if SMTP.Authenticate then
      begin
        Progress('Invio', ProgressBox);
        SMTP.Send(IdMessage);
        Result := True;
      end;
    finally
      DisconnectSMTPServer(ProgressBox);
    end;
  finally
    FreeAndNil(IdMessage);
  end;
end;

procedure TzOfficeMailWriter.IdLogEventSent(ASender: TComponent; const AText, AData: string);
begin
  Log('IdLogEventSent', AData);
end;

procedure TzOfficeMailWriter.IdLogEventStatus(ASender: TComponent; const AText: string);
begin
  Log('IdLogEventStatus', AText);
end;

procedure TzOfficeMailWriter.IdSMTPStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  Log('SMTPServer', AStatusText);
end;

procedure TzOfficeMailWriter.IOHandlerTlsStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  Log('TLS', AStatusText);
end;

function TzOfficeMailWriter.MsgID(const address: string): string;
var
  guid: TGUID;
begin
  Result := '';
  CreateGuid(guid);
  Result := Copy(GuidToString(guid), 2, 36) + Copy(address, Pos('@', address), Length(address) - Pos('@', address) + 1);
end;

procedure TzOfficeMailWriter.Log(const AName: UnicodeString; const AValue: String);
begin
  siMain.logString(AName, AValue);

  if assigned(LogProc) then
    LogProc(AName + ': ' + AValue);
end;

end.
