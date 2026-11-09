unit OutlookHelper;

interface

uses
  System.SysUtils,
  System.Classes,
  ComObj,
  Variants;

type
  TMailImportance = (miLow, miNormal, miHigh);
  TMailSensitivity = (msNormal, msPersonal, msPrivate, msConfidential);
  TMailSaveFormat = (sfMsg = 3, sfMsgUnicode = 9, sfHTML = 2, sfTXT = 0);

  TOutlookMail = class
  private
    FOutlook: OleVariant;
    FMailItem: OleVariant;
    FIsHTML: Boolean;
    function GetTo: string;
    procedure SetTo(const Value: string);
    function GetCC: string;
    procedure SetCC(const Value: string);
    function GetBCC: string;
    procedure SetBCC(const Value: string);
    function GetSubject: string;
    procedure SetSubject(const Value: string);
    function GetBody: string;
    procedure SetBody(const Value: string);
    function GetImportance: TMailImportance;
    procedure SetImportance(const Value: TMailImportance);
    function GetSensitivity: TMailSensitivity;
    procedure SetSensitivity(const Value: TMailSensitivity);
    function GetReadReceiptRequested: Boolean;
    procedure SetReadReceiptRequested(const Value: Boolean);
    function GetDeliveryReceiptRequested: Boolean;
    procedure SetDeliveryReceiptRequested(const Value: Boolean);
    function GetFlagRequest: string;
    procedure SetFlagRequest(const Value: string);
    function GetReminderSet: Boolean;
    procedure SetReminderSet(const Value: Boolean);
    function GetReminderTime: TDateTime;
    procedure SetReminderTime(const Value: TDateTime);
    function GetCategories: string;
    procedure SetCategories(const Value: string);
    function GetAttachmentCount: Integer;
    function GetIsHTML: Boolean;
    procedure SetIsHTML(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    class function IsOutlookInstalled: Boolean; static;
    class function IsOutlookConfigured: Boolean; static;

    // Gestione destinatari
    procedure AddRecipient(const Email: string);
    procedure AddCC(const Email: string);
    procedure AddBCC(const Email: string);
    procedure ClearRecipients;

    // Gestione allegati
    procedure AddAttachment(const FilePath: string);
    procedure AddAttachmentWithName(const FilePath, DisplayName: string);

    // Firma
    procedure InsertSignature(const SignatureName: string);

    // Azioni
    procedure Display(Modal: Boolean = False);
    procedure Send;
    procedure SaveAsDraft;
    procedure SaveAs(const FilePath: string; Format: TMailSaveFormat = sfMsg);

    // Proprietà
    property MailTo: string read GetTo write SetTo;
    property CC: string read GetCC write SetCC;
    property BCC: string read GetBCC write SetBCC;
    property Subject: string read GetSubject write SetSubject;
    property Body: string read GetBody write SetBody;
    property IsHTML: Boolean read GetIsHTML write SetIsHTML;
    property Importance: TMailImportance read GetImportance write SetImportance;
    property Sensitivity: TMailSensitivity read GetSensitivity write SetSensitivity;
    property ReadReceiptRequested: Boolean read GetReadReceiptRequested write SetReadReceiptRequested;
    property DeliveryReceiptRequested: Boolean read GetDeliveryReceiptRequested write SetDeliveryReceiptRequested;
    property FlagRequest: string read GetFlagRequest write SetFlagRequest;
    property ReminderSet: Boolean read GetReminderSet write SetReminderSet;
    property ReminderTime: TDateTime read GetReminderTime write SetReminderTime;
    property Categories: string read GetCategories write SetCategories;
    property AttachmentCount: Integer read GetAttachmentCount;
  end;

implementation

uses
  Winapi.Windows,
  System.Win.Registry;

const
  olMailItem = 0;
  olImportanceLow = 0;
  olImportanceNormal = 1;
  olImportanceHigh = 2;
  olNormal = 0;
  olPersonal = 1;
  olPrivate = 2;
  olConfidential = 3;
  olFlagMarked = 2;

  { --- Costruttore / Distruttore --- }

constructor TOutlookMail.Create;
begin
  inherited;
  FIsHTML := False;
  try
    FOutlook := CreateOleObject('Outlook.Application');
    FMailItem := FOutlook.CreateItem(olMailItem);
  except
    on E: Exception do
      raise Exception.Create('Errore apertura Outlook: ' + E.Message);
  end;
end;

destructor TOutlookMail.Destroy;
begin
  FMailItem := Unassigned;
  FOutlook := Unassigned;
  inherited;
end;

{ --- Getter / Setter --- }

function TOutlookMail.GetTo: string;
begin
  Result := FMailItem.To;
end;

procedure TOutlookMail.SetTo(const Value: string);
begin
  FMailItem.To := Value;
end;

function TOutlookMail.GetCC: string;
begin
  Result := FMailItem.CC;
end;

procedure TOutlookMail.SetCC(const Value: string);
begin
  FMailItem.CC := Value;
end;

function TOutlookMail.GetBCC: string;
begin
  Result := FMailItem.BCC;
end;

procedure TOutlookMail.SetBCC(const Value: string);
begin
  FMailItem.BCC := Value;
end;

function TOutlookMail.GetSubject: string;
begin
  Result := FMailItem.Subject;
end;

procedure TOutlookMail.SetSubject(const Value: string);
begin
  FMailItem.Subject := Value;
end;

function TOutlookMail.GetIsHTML: Boolean;
begin
  Result := FIsHTML;
end;

procedure TOutlookMail.SetIsHTML(const Value: Boolean);
begin
  FIsHTML := Value;
end;

function TOutlookMail.GetBody: string;
begin
  if FIsHTML then
    Result := FMailItem.HTMLBody
  else
    Result := FMailItem.Body;
end;

procedure TOutlookMail.SetBody(const Value: string);
begin
  if FIsHTML then
    FMailItem.HTMLBody := Value
  else
    FMailItem.Body := Value;
end;

function TOutlookMail.GetImportance: TMailImportance;
begin
  case Integer(FMailItem.Importance) of
    olImportanceLow:
      Result := miLow;
    olImportanceHigh:
      Result := miHigh;
  else
    Result := miNormal;
  end;
end;

procedure TOutlookMail.SetImportance(const Value: TMailImportance);
begin
  case Value of
    miLow:
      FMailItem.Importance := olImportanceLow;
    miNormal:
      FMailItem.Importance := olImportanceNormal;
    miHigh:
      FMailItem.Importance := olImportanceHigh;
  end;
end;

function TOutlookMail.GetSensitivity: TMailSensitivity;
begin
  case Integer(FMailItem.Sensitivity) of
    olPersonal:
      Result := msPersonal;
    olPrivate:
      Result := msPrivate;
    olConfidential:
      Result := msConfidential;
  else
    Result := msNormal;
  end;
end;

procedure TOutlookMail.SetSensitivity(const Value: TMailSensitivity);
begin
  case Value of
    msNormal:
      FMailItem.Sensitivity := olNormal;
    msPersonal:
      FMailItem.Sensitivity := olPersonal;
    msPrivate:
      FMailItem.Sensitivity := olPrivate;
    msConfidential:
      FMailItem.Sensitivity := olConfidential;
  end;
end;

function TOutlookMail.GetReadReceiptRequested: Boolean;
begin
  Result := FMailItem.ReadReceiptRequested;
end;

procedure TOutlookMail.SetReadReceiptRequested(const Value: Boolean);
begin
  FMailItem.ReadReceiptRequested := Value;
end;

function TOutlookMail.GetDeliveryReceiptRequested: Boolean;
begin
  Result := FMailItem.OriginatorDeliveryReportRequested;
end;

procedure TOutlookMail.SetDeliveryReceiptRequested(const Value: Boolean);
begin
  FMailItem.OriginatorDeliveryReportRequested := Value;
end;

function TOutlookMail.GetFlagRequest: string;
begin
  Result := FMailItem.FlagRequest;
end;

procedure TOutlookMail.SetFlagRequest(const Value: string);
begin
  FMailItem.FlagRequest := Value;
  if Value <> '' then
    FMailItem.FlagStatus := olFlagMarked
  else
    FMailItem.FlagStatus := 0; // olNoFlag
end;

function TOutlookMail.GetReminderSet: Boolean;
begin
  Result := FMailItem.ReminderSet;
end;

procedure TOutlookMail.SetReminderSet(const Value: Boolean);
begin
  FMailItem.ReminderSet := Value;
end;

function TOutlookMail.GetReminderTime: TDateTime;
begin
  Result := FMailItem.ReminderTime;
end;

procedure TOutlookMail.SetReminderTime(const Value: TDateTime);
begin
  FMailItem.ReminderTime := Value;
  FMailItem.ReminderSet := True; // attiva automaticamente il reminder
end;

function TOutlookMail.GetCategories: string;
begin
  Result := FMailItem.Categories;
end;

procedure TOutlookMail.SetCategories(const Value: string);
begin
  FMailItem.Categories := Value;
end;

function TOutlookMail.GetAttachmentCount: Integer;
begin
  Result := FMailItem.Attachments.Count;
end;

{ --- Metodi pubblici --- }

procedure TOutlookMail.AddRecipient(const Email: string);
begin
  if FMailItem.To = '' then
    FMailItem.To := Email
  else
    FMailItem.To := FMailItem.To + ';' + Email;
end;

procedure TOutlookMail.AddCC(const Email: string);
begin
  if FMailItem.CC = '' then
    FMailItem.CC := Email
  else
    FMailItem.CC := FMailItem.CC + ';' + Email;
end;

procedure TOutlookMail.AddBCC(const Email: string);
begin
  if FMailItem.BCC = '' then
    FMailItem.BCC := Email
  else
    FMailItem.BCC := FMailItem.BCC + ';' + Email;
end;

procedure TOutlookMail.ClearRecipients;
begin
  FMailItem.To := '';
  FMailItem.CC := '';
  FMailItem.BCC := '';
end;

procedure TOutlookMail.AddAttachment(const FilePath: string);
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File non trovato: %s', [FilePath]);
  FMailItem.Attachments.Add(FilePath);
end;

procedure TOutlookMail.AddAttachmentWithName(const FilePath, DisplayName: string);
var
  Attachment: OleVariant;
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File non trovato: %s', [FilePath]);
  Attachment := FMailItem.Attachments.Add(FilePath);
  Attachment.DisplayName := DisplayName;
end;

procedure TOutlookMail.InsertSignature(const SignatureName: string);
var
  SignaturePath: string;
  SignatureHTML: TStringList;
begin
  SignaturePath := GetEnvironmentVariable('APPDATA') + '\Microsoft\Signatures\' + SignatureName + '.htm';
  if not FileExists(SignaturePath) then
    raise Exception.CreateFmt('Firma non trovata: %s', [SignatureName]);

  SignatureHTML := TStringList.Create;
  try
    SignatureHTML.LoadFromFile(SignaturePath);
    FIsHTML := True;
    FMailItem.HTMLBody := FMailItem.HTMLBody + '<br><br>' + SignatureHTML.Text;
  finally
    SignatureHTML.Free;
  end;
end;

procedure TOutlookMail.Display(Modal: Boolean);
begin
  FMailItem.Display(Modal);
end;

procedure TOutlookMail.Send;
begin
  FMailItem.Send;
end;

procedure TOutlookMail.SaveAsDraft;
begin
  FMailItem.Save;
end;

procedure TOutlookMail.SaveAs(const FilePath: string; Format: TMailSaveFormat);
begin
  FMailItem.SaveAs(FilePath, Ord(Format));
end;

class function TOutlookMail.IsOutlookInstalled: Boolean;
var
  Reg: TRegistry;
begin
   Result := False;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    Result := Reg.KeyExists('Outlook.Application');
  finally
    Reg.Free;
  end;
end;

class function TOutlookMail.IsOutlookConfigured: Boolean;
var
  Reg: TRegistry;
  ProfileKey: string;
begin
  Result := False;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    // Percorso standard per i profili Outlook nelle versioni moderne
    ProfileKey := 'Software\Microsoft\Office\16.0\Outlook\Profiles';

    // Se la versione 16.0 (Office 2016/2019/365) non esiste,
    // si può iterare su versioni precedenti o cercare in 'Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles'

    if Reg.OpenKeyReadOnly(ProfileKey) then
    begin
      Result := Reg.HasSubKeys; // Se ci sono sottochiavi, esiste almeno un profilo
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.
