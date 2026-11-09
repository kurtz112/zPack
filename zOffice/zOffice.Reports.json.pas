unit zOffice.Reports.json;

interface

uses
  System.Classes,
  System.json.Serializers,
  System.Generics.Collections,
  System.json.Converters,
  System.json;

type
  TzJsonReportParams = class;
  TzWordFragment = class;
  TzReportDataset = class;

{$IF Declared(CompilerVersion) and (CompilerVersion >= 37)} // Delphi 13+
  TJsonListConverterstring = class(TJsonListConverter<string>);
  TJsonListConverterTPippoRoot = class(TJsonListConverter<TzJsonReportParams>);
  TJsonListConverterTzWordFragment = class(TJsonListConverter<TzWordFragment>);
  TJsonListConverterTzReportDataset = class(TJsonListConverter<TzReportDataset>);
{$ELSE} // Delphi 12
  TJsonListConverterstring = class(TJsonTypedListConverter<string>);
  TJsonListConverterTPippoRoot = class(TJsonTypedListConverter<TzJsonReportParams>);
  TJsonListConverterTzWordFragment = class(TJsonTypedListConverter<TzWordFragment>);
  TJsonListConverterTzReportDataset = class(TJsonTypedListConverter<TzReportDataset>);
{$IFEND}

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzPdfParams = class(TPersistent)
  private
    Fmethod: string;
    FfieldName: string;
    FfileName: string;
    FfontEmbedding: string;
    FopenFileAfterExport: Boolean;
    FshowMessageAfterExport: Boolean;
  public
    property method: string read Fmethod write Fmethod;
    property fieldName: string read FfieldName write FfieldName;
    property fileName: string read FfileName write FfileName;
    property fontEmbedding: string read FfontEmbedding write FfontEmbedding;
    property openFileAfterExport: Boolean read FopenFileAfterExport write FopenFileAfterExport;
    property showMessageAfterExport: Boolean read FshowMessageAfterExport write FshowMessageAfterExport;
  end;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzReportDataset = class(TPersistent)
  private
    Fname: string;
    Fclose: Boolean;
  public
    property name: string read Fname write Fname;
    property close: Boolean read Fclose write Fclose;
  end;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzWordFragment = class(TPersistent)
  private
    Fvariable: string;
    Ftemplate: string;
    Fdataset: string;
  public
    property variable: string read Fvariable write Fvariable;
    property template: string read Ftemplate write Ftemplate;
    property dataset: string read Fdataset write Fdataset;
  end;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzWordParams = class(TPersistent)
  private
    FreadOnly: Boolean;
    Ffirma: Boolean;
    FinviaMail: Boolean;
    Fpdf: TzPdfParams;
    Ffragments: TList<TzWordFragment>;
  public
    constructor Create;
    destructor Destroy; override;
    property readOnly: Boolean read FreadOnly write FreadOnly;
    property firma: Boolean read Ffirma write Ffirma;
    property inviaMail: Boolean read FinviaMail write FinviaMail;
    property pdf: TzPdfParams read Fpdf;
    [JsonConverter(TJsonListConverterTzWordFragment)]
    property fragments: TList<TzWordFragment> read Ffragments;
  end;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzExcelParams = class(TPersistent)
  private
    FreadOnly: Boolean;
    FallowBuildReport: Boolean;
    Fpdf: TzPdfParams;
    Fdatabinding: TJSONObject;
  public
    constructor Create;
    destructor Destroy; override;
    property readOnly: Boolean read FreadOnly write FreadOnly;
    property allowBuildReport: Boolean read FallowBuildReport write FallowBuildReport;
    property pdf: TzPdfParams read Fpdf;
    property databinding: TJSONObject read Fdatabinding write Fdatabinding;
  end;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzFastreportParams = class(TPersistent)
  private
    FshowDialog: Boolean;
    FopenAfterExport: Boolean;
    FembeddedFonts: Boolean;
    FoverwritePrompt: Boolean;
  public
    property showDialog: Boolean read FshowDialog write FshowDialog;
    property openAfterExport: Boolean read FopenAfterExport write FopenAfterExport;
    property embeddedFonts: Boolean read FembeddedFonts write FembeddedFonts;
    property overwritePrompt: Boolean read FoverwritePrompt write FoverwritePrompt;
  end;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TzJsonReportParams = class(TPersistent)
  private
    Fid: string;
    Fgroup: string;
    FmainDataset: string;
    Fdatasets: TObjectList<TzReportDataset>;
    Fword: TzWordParams;
    Fexcel: TzExcelParams;
    Ffastreport: TzFastreportParams;
  public
    constructor Create;
    destructor Destroy; override;
    class function FromJSON(const AValue: TJSONValue): TzJsonReportParams; overload; static;
    class function FromJSON(const AValue: string): TzJsonReportParams; overload; static;
    function ToJSONObject: TJSONValue;
    function ToJSONString: string;
    property id: string read Fid write Fid;
    property group: string read Fgroup write Fgroup;
    property mainDataset: string read FmainDataset write FmainDataset;
    [JsonConverter(TJsonListConverterTzReportDataset)]
    property datasets: TObjectList<TzReportDataset> read Fdatasets;
    property word: TzWordParams read Fword write Fword;
    property excel: TzExcelParams read Fexcel write Fexcel;
    property fastreport: TzFastreportParams read Ffastreport write Ffastreport;
  end;

implementation

uses
  System.SysUtils;

constructor TzWordParams.Create;
begin
  inherited Create;
  Fpdf := TzPdfParams.Create;
  Ffragments := TList<TzWordFragment>.Create;
end;

destructor TzWordParams.Destroy;
begin
  FreeAndNil(Fpdf);
  FreeAndNil(Ffragments);
  inherited Destroy;
end;

constructor TzExcelParams.Create;
begin
  inherited Create;
  Fpdf := TzPdfParams.Create;
  Fdatabinding := nil;
end;

destructor TzExcelParams.Destroy;
begin
  FreeAndNil(Fpdf);
  FreeAndNil(Fdatabinding);
  inherited Destroy;
end;

constructor TzJsonReportParams.Create;
begin
  inherited Create;
  Fdatasets := TObjectList<TzReportDataset>.Create(True);
  Fword := nil;
  Fexcel := nil;
  Ffastreport := nil;
end;

destructor TzJsonReportParams.Destroy;
begin
  FreeAndNil(Fdatasets);
  FreeAndNil(Fword);
  FreeAndNil(Fexcel);
  FreeAndNil(Ffastreport);
  inherited Destroy;
end;

class function TzJsonReportParams.FromJSON(const AValue: TJSONValue): TzJsonReportParams;
begin
  Result := TJSONMapper<TzJsonReportParams>.Default.FromObject(AValue);
end;

class function TzJsonReportParams.FromJSON(const AValue: string): TzJsonReportParams;
begin
  Result := TJSONMapper<TzJsonReportParams>.Default.FromObject(AValue);
end;

function TzJsonReportParams.ToJSONObject: TJSONValue;
begin
  Result := TJSONMapper<TzJsonReportParams>.Default.ToObject(Self);
end;

function TzJsonReportParams.ToJSONString: string;
begin
  Result := TJSONMapper<TzJsonReportParams>.Default.ToString(Self, 4);
end;

initialization

TJSONMapper<TzJsonReportParams>.SetDefaultLibrary('System.JSON.Serializers');

RegisterClass(TzPdfParams);
RegisterClass(TzWordParams);
RegisterClass(TzWordFragment);
RegisterClass(TzExcelParams);
RegisterClass(TzFastreportParams);
RegisterClass(TzReportDataset);
RegisterClass(TzJsonReportParams);

end.


