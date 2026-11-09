unit zCustomerPreferences;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms;

type
  TzCustomerPreferences = class
  private
    FCanEditCaptions: boolean;
    FCardCaptions: TStringList;
    FViewCaptions: TStringList;

    function CalcFileName(const Ext: string): string;
    function CardCaptionsFileName: string;
    function ViewCaptionsFileName: string;
    function getId(const Id, FieldName: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reload;

    function GetControlCaption(const CardId, FieldName, DefaultCaption: string): string;
    procedure SetControlCaption(const CardId, FieldName, Caption: string);
    function EditControlCaption(const CardId, FieldName: string; var Caption: string): boolean;

    function GetColumnCaption(const ViewId, FieldName, DefaultCaption: string): string;
    procedure SetColumnCaption(const ViewId, FieldName, Caption: string);
    function EditColumnCaption(const ViewId, FieldName: string; var Caption: string): boolean;
  public
    property CardCaptions: TStringList read FCardCaptions write FCardCaptions;
    property ViewCaptions: TStringList read FViewCaptions write FViewCaptions;

    property CanEditCaptions: boolean read FCanEditCaptions write FCanEditCaptions;
  end;

implementation

uses
  System.IOUtils,
  zMsg;

{ TzCustomerPreferences }

constructor TzCustomerPreferences.Create;
begin
  inherited;
  FCanEditCaptions := true; { TODO : Parametrizzare }
  FCardCaptions := TStringList.Create;
  FViewCaptions := TStringList.Create;

  Reload;
end;

destructor TzCustomerPreferences.Destroy;
begin
  FreeAndNil(FCardCaptions);
  FreeAndNil(FViewCaptions);

  inherited;
end;

procedure TzCustomerPreferences.Reload;
begin

  CardCaptions.Clear;
  if TFile.Exists(CardCaptionsFileName) then
    CardCaptions.LoadFromFile(CardCaptionsFileName);

  ViewCaptions.Clear;
  if TFile.Exists(ViewCaptionsFileName) then
    ViewCaptions.LoadFromFile(ViewCaptionsFileName);
end;

function TzCustomerPreferences.CalcFileName(const Ext: string): string;
begin
  result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.exename)) + ChangeFileExt(ExtractFileName(Application.exename), Ext);
end;

function TzCustomerPreferences.CardCaptionsFileName: string;
begin
  result := CalcFileName('.cardCaptions');
end;

function TzCustomerPreferences.ViewCaptionsFileName: string;
begin
  result := CalcFileName('.viewCaptions');
end;

function TzCustomerPreferences.getId(const Id, FieldName: string): string;
begin
  result := Id + '__' + FieldName;
end;

function TzCustomerPreferences.EditColumnCaption(const ViewId, FieldName: string; var Caption: string): boolean;
begin
  result := InputString('Modifica Titolo', 'Titolo', Caption);

  if result then
    SetColumnCaption(ViewId, FieldName, Caption);
end;

function TzCustomerPreferences.EditControlCaption(const CardId, FieldName: string; var Caption: string): boolean;
begin
  result := InputString('Modifica Titolo', 'Titolo', Caption);

  if result then
    SetControlCaption(CardId, FieldName, Caption);
end;

function TzCustomerPreferences.GetControlCaption(const CardId, FieldName, DefaultCaption: string): string;
var
  Id: string;
begin
  result := DefaultCaption;

  Id := getId(CardId, FieldName);

  if CardCaptions.ContainsName(Id) then
    result := CardCaptions.Values[Id];
end;

procedure TzCustomerPreferences.SetControlCaption(const CardId, FieldName, Caption: string);
var
  Id: string;
begin
  Id := getId(CardId, FieldName);

  CardCaptions.Values[Id] := Caption;

  CardCaptions.Sort;
  CardCaptions.SaveToFile(CardCaptionsFileName);
end;

function TzCustomerPreferences.GetColumnCaption(const ViewId, FieldName, DefaultCaption: string): string;
var
  Id: string;
begin
  result := DefaultCaption;

  Id := getId(ViewId, FieldName);

  if ViewCaptions.ContainsName(Id) then
    result := ViewCaptions.Values[Id];
end;

procedure TzCustomerPreferences.SetColumnCaption(const ViewId, FieldName, Caption: string);
var
  Id: string;
begin
  Id := getId(ViewId, FieldName);

  ViewCaptions.Values[Id] := Caption;

  ViewCaptions.Sort;
  ViewCaptions.SaveToFile(ViewCaptionsFileName);
end;

end.zsystem
