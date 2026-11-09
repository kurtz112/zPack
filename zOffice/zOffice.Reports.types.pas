unit zOffice.Reports.types;

interface

uses
  System.SysUtils, System.Classes;

const
  REPORT_PREVIEW_EDITING_PERMISSION = 'Report.Preview.Editing';
  REPORT_SYSTEM_MENU_PERMISSION = 'Report.Modifica';

  // Azioni documentali (gate 2): verificate in PermessoConcesso del
  // controller applicativo via zSystem/RestrictionManager. Default
  // consigliati: alNone per le quattro azioni con conseguenze legali
  // (abilitazione esplicita per ruolo), alFull per InviaMail
  // (comportamento odierno: la mail ordinaria e' di uso generale).
  REPORT_AZIONE_FIRMA_PERMISSION      = 'Report.Azione.Firma';
  REPORT_AZIONE_PROTOCOLLA_PERMISSION = 'Report.Azione.Protocolla';
  REPORT_AZIONE_CONSERVA_PERMISSION   = 'Report.Azione.Conserva';
  REPORT_AZIONE_INVIA_PEC_PERMISSION  = 'Report.Azione.InviaPec';
  REPORT_AZIONE_INVIA_MAIL_PERMISSION = 'Report.Azione.InviaMail';

type
  TReportKind = (rkUnknow, rkFastReport, rkWord, rkExcel);
  TReportKinds = set of TReportKind;
  TExcludeFolders = array of string;

  TReportKindHelper = record helper for TReportKind
  public
    function Description: string;
    function ToString: string;
    class function FromString(const s: String): TReportKind; static;
  end;

  TPdfFontEmbedding = (feNone, feFull, feSubset);

  TPdfFontEmbeddingHelper = record helper for TPdfFontEmbedding
  public
    function Description: string;
    function ToString: string;
    class function FromString(const s: String): TPdfFontEmbedding; static;
  end;

  TzReportConfig = record
  private
    FReportRoot: string;
    procedure SetReportRoot(const Value: string);
  public
    property ReportRoot: string read FReportRoot write SetReportRoot;
  end;

var
  zReportConfig: TzReportConfig;

implementation

{ TReportKindHelper }

function TReportKindHelper.Description: string;
begin
  case self of
    rkUnknow:
      result := '';
    rkFastReport:
      result := '.fr3';
    rkWord:
      result := '.docx';
    rkExcel:
      result := '.xlsx';
  end;
end;

function TReportKindHelper.ToString: string;
begin
  case self of
    rkUnknow:
      result := '';
    rkFastReport:
      result := '.fr3';
    rkWord:
      result := '.docx';
    rkExcel:
      result := '.xlsx';
  end;
end;

class function TReportKindHelper.FromString(const s: String): TReportKind;
var
  ext: string;
begin
  result := rkUnknow;

  ext := s.ToLower;

  if ext = '.fr3' then
    result := rkFastReport
  else
    if ext = '.docx' then
      result := rkWord
    else
      if ext = '.xlsx' then
        result := rkExcel;
end;

{ TPdfFontEmbeddingHelper }
function TPdfFontEmbeddingHelper.Description: string;
begin
  case self of
    feNone:
      result := '';
    feFull:
      result := '';
    feSubset:
      result := '';
  end;
end;

function TPdfFontEmbeddingHelper.ToString: string;
begin
  case self of
    feNone:
      result := 'N';
    feFull:
      result := 'F';
    feSubset:
      result := 'S';
  end;
end;

class function TPdfFontEmbeddingHelper.FromString(const s: String): TPdfFontEmbedding;
begin
  result := feNone;

  if sameText(s, 'N') then
    result := feNone
  else
    if sameText(s, 'F') then
      result := feFull
    else
      if sameText(s, 'S') then
        result := feSubset;
end;

procedure TzReportConfig.SetReportRoot(const Value: string);
begin
  FReportRoot := IncludeTrailingPathDelimiter(Value) + 'Reports\';
end;

end.
