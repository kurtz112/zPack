unit zRestrictions.Types;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  zCollection;

type
  TAccessLevel = (alNone, alRead, alFull);

  TAccessLevelHelper = record helper for TAccessLevel
  public
    function ToString: string;
    function Parse(Const s: string): TAccessLevel;
  end;

  TzComponentClass = (ccUnknown, ccTabSheet, ccAction, ccFormController, ccView, ccCard, ccCube, ccFilePdf, ccGisMap);

  TzComponentClassHelper = record helper for TzComponentClass
  public
    function ToString: string;
    function Description: string;
    function Parse(Const s: string): TzComponentClass;
  end;

implementation

function StrToChar(s: string): char;
begin
  Result := #0;
  if s <> '' then
    Result := s[low(s)];
end;

function TAccessLevelHelper.Parse(Const s: string): TAccessLevel;
begin
  Result := alFull;
  case StrToChar(s) of
    'X':
      Result := alNone;
    'R':
      Result := alRead;
    'W':
      Result := alFull;
  end;
end;

function TAccessLevelHelper.ToString: string;
begin
  case Self of
    alNone:
      Result := 'X';
    alRead:
      Result := 'R';
    alFull:
      Result := 'W';
  end;
end;

function TzComponentClassHelper.Description: string;
begin
  Result := '';

  case Self of
    ccUnknown:
      Result := 'Varie';
    ccTabSheet:
      Result := 'TabSheet';
    ccAction:
      Result := 'Menù/Pulsanti'; //     Result := 'Action';
    ccFormController:
      Result := 'View/Schede';
    ccView:
      Result := 'View';
    ccCard:
      Result := 'Schede';
    ccCube:
      Result := 'Cubi Pivot';
    ccFilePdf:
      Result := 'Visualizzatori Pdf';
    ccGisMap:
      Result := 'Mappe';
  end;
end;

function TzComponentClassHelper.Parse(Const s: string): TzComponentClass;
begin
  Result := ccUnknown;
  case StrToChar(s) of
    '?':
      Result := ccUnknown;
    'T':
      Result := ccTabSheet;
    'A':
      Result := ccAction;
    'D':
      Result := ccFormController;
    'V':
      Result := ccView;
    'C':
      Result := ccCard;
    'U':
      Result := ccCube;
    'P':
      Result := ccFilePdf;
    'G':
      Result := ccGisMap;
  end;
end;

function TzComponentClassHelper.ToString: string;
begin
  case Self of
    ccUnknown:
      Result := '?';
    ccTabSheet:
      Result := 'T';
    ccAction:
      Result := 'A';
    ccFormController:
      Result := 'D';
    ccView:
      Result := 'V';
    ccCard:
      Result := 'C';
    ccCube:
      Result := 'U';
    ccFilePdf:
      Result := 'P';
    ccGisMap:
      Result := 'G';
  end;
end;

end.
