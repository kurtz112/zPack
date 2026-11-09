unit zDxConditionalFormatting;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxStyles,
  cxCustomData,
  cxFilter,
  cxData,
  cxDataStorage,
  cxEdit,
  cxNavigator,
  dxDateRanges,
  dxScrollbarAnnotations,
  cxDBData,
  cxGridCustomTableView,
  cxGridTableView,
  cxGridDBTableView,
  cxGridLevel,
  cxClasses,
  cxGridCustomView,
  cxGrid,
  dxBarBuiltInMenu,
  cxCustomPivotGrid,
  cxDBPivotGrid;

// TcxGridDBTableView
type
  TzDxConditionalFormattings = record
  public
    procedure SaveConditionalFormattingsToFile(cxGridDBTableView: TcxGridDBTableView; const FileName: string); overload;
    procedure LoadConditionalFormattingsFromFile(cxGridDBTableView: TcxGridDBTableView; const FileName: string); overload;

    function GetConditionalFormattings(cxGridDBTableView: TcxGridDBTableView): string; overload;
    procedure SetConditionalFormattings(cxGridDBTableView: TcxGridDBTableView; const ConditionalFormattings: string); overload;
  end;

var
  zDxConditionalFormattings: TzDxConditionalFormattings;

implementation

uses
  dxSpreadSheetConditionalFormatting,
  cxDataControllerConditionalFormattingRulesManagerDialog;

type
  TcxGridConditionalFormattingProviderAccess = class(TcxGridConditionalFormattingProvider);

procedure TzDxConditionalFormattings.LoadConditionalFormattingsFromFile(cxGridDBTableView: TcxGridDBTableView; const FileName: string);
begin
  assert(assigned(cxGridDBTableView));
  assert(FileName <> '');

  If TFile.Exists(FileName) then
    SetConditionalFormattings(cxGridDBTableView, TFile.ReadAllText(FileName));
end;

procedure TzDxConditionalFormattings.SaveConditionalFormattingsToFile(cxGridDBTableView: TcxGridDBTableView; const FileName: string);
var
  ConditionalFormattings: string;
begin
  assert(assigned(cxGridDBTableView));
  assert(FileName <> '');

  ConditionalFormattings := GetConditionalFormattings(cxGridDBTableView);

  if not ConditionalFormattings.IsEmpty then
    TFile.WriteAllText(FileName, ConditionalFormattings)
  else
    If TFile.Exists(FileName) then
      TFile.Delete(FileName);
end;

procedure TzDxConditionalFormattings.SetConditionalFormattings(cxGridDBTableView: TcxGridDBTableView; const ConditionalFormattings: string);
var
  stream: TStringStream;
  owner: IdxSpreadSheetConditionalFormattingOwner;
begin
  assert(assigned(cxGridDBTableView));

  if ConditionalFormattings.IsEmpty then
    cxGridDBTableView.ConditionalFormatting.Clear
  else
  begin
    stream := TStringStream.Create(ConditionalFormattings);
    try
      owner := cxGridDBTableView.ConditionalFormatting.owner;
      TcxGridConditionalFormattingProviderAccess(owner as TObject).Read(stream);
      TcxGridConditionalFormattingProviderAccess(owner as TObject).Recalculate;
    finally
      stream.Free;
    end;
  end;
end;

function TzDxConditionalFormattings.GetConditionalFormattings(cxGridDBTableView: TcxGridDBTableView): string;
var
  stream: TStringStream;
  owner: IdxSpreadSheetConditionalFormattingOwner;
begin
  assert(assigned(cxGridDBTableView));
  Result := '';

  stream := TStringStream.Create;
  try
    owner := cxGridDBTableView.ConditionalFormatting.owner;
    TcxGridConditionalFormattingProviderAccess(owner as TObject).Write(stream);
    Result := stream.DataString;
  finally
    stream.Free;
  end;
end;

end.


zrestrictions.form
