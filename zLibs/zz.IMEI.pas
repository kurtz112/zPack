unit zz.IMEI;

interface

uses
{$IFDEF ANDROID}
  Androidapi.Jni.JavaTypes,
  Androidapi.JniBridge,
{$ENDIF}
  System.SysUtils,
  System.Classes,
  System.Messaging,
  System.Permissions,
  System.Types,
  System.UITypes;

type
  TDispositivo = class
  private const
    PERMISSIONS_REQUEST = 1;
  private
    FAndroid_ID: string;
    FIdDispositivo: Integer;
    FIMEI: string;
    FInitialized: boolean;
    FMarca: string;
    FModello: string;
    FSeriale: string;
    function GetDescrizione: string;
    function GetIdentificativo: string;
    function GetAsString: string;
  private
    property Identificativo: string read GetIdentificativo;
  public
    constructor Create;
    procedure SetIdDispositivo(idDispositivo: Integer);

    property Initialized: boolean read FInitialized;
    property AsString: string read GetAsString;
  public
    property idDispositivo: Integer read FIdDispositivo;
    property IMEI: string read FIMEI;
    property Marca: string read FMarca;
    property Modello: string read FModello;
    property Seriale: string read FSeriale;
    property Android_ID: string read FAndroid_ID;

    property Descrizione: string read GetDescrizione;
  end;

implementation

uses
{$IFDEF ANDROID}
  Androidapi.Jni.Os,
  Androidapi.Jni.GraphicsContentViewText,
  Androidapi.Jni.Telephony,
  Androidapi.Jni.Provider,
  Androidapi.Helpers,
  FMX.Helpers.Android,
{$ENDIF}
  FMX.Forms,
  FMX.DialogService;

{ TDispositivo }

constructor TDispositivo.Create;
begin
  inherited;
  FInitialized := False;
  FIdDispositivo := -1;
  FMarca := 'Marca Sconosciuta';
  FModello := 'Modello Sconosciuto';
  FSeriale := 'Seriale Sconosciuto';
  FAndroid_ID := '000000000000000';
  FIMEI := '000000000000000';

{$IFDEF ANDROID}
  FMarca := JStringToString(TJBuild.JavaClass.brand);
  FModello := JStringToString(TJBuild.JavaClass.MODEL);
  FSeriale := JStringToString(TJBuild.JavaClass.SERIAL);
  FAndroid_ID := JStringToString(TJSettings_Secure.JavaClass.getString(SharedActivity.getContentResolver, TJSettings_Secure.JavaClass.Android_ID));
  FIMEI := FAndroid_ID;
{$ENDIF}
  FInitialized := True;
end;

function TDispositivo.GetAsString: string;
begin
  Result := 'Marca=' + Marca + #13#10 + 'Modello=' + Modello + #13#10 + 'Seriale=' + Seriale + #13#10 + 'IMEI=' + IMEI + #13#10 + 'Android_ID=' + Android_ID;
end;

function TDispositivo.GetDescrizione: string;
begin
  Result := Marca + ' ' + Modello;
end;

function TDispositivo.GetIdentificativo: string;
begin
  Result := IMEI;

  if Result.IsEmpty then
    Result := Android_ID;

  if Result.IsEmpty then
    Result := Seriale;
end;

procedure TDispositivo.SetIdDispositivo(idDispositivo: Integer);
begin
  // chiamato da Server.VerificaDispositivo
  FIdDispositivo := idDispositivo;
end;

end.
