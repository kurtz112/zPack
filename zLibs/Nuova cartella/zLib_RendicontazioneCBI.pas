unit zLib_RendicontazioneCBI;

interface

type
  TTipoFlusso = (ttNullo, ttRiba, ttMAV, ttRID, ttAltri, ttBollettinoBancario, ttAllineamento, ttRiconciliazione);

function IsFileCBI(const FileName: string): boolean;
function GetTipoFlusso(const Header: string): TTipoFlusso;
function GetTipoFlussoFromFileName(const FileName: string): TTipoFlusso;
function TipoFlussoStr(TipoFlusso: TTipoFlusso): string;

implementation
uses SysUtils;

function IsFileCBI(const FileName: string): boolean;
begin
  result := GetTipoFlussoFromFileName(FileName) <> ttNullo;
end;

function GetTipoFlusso(const Header: string): TTipoFlusso;
var
  TipoRecord: string;
begin
  result := ttNullo;

  if trim(Header) = '' then
    Exit;

  TipoRecord := System.Copy(Header, 2, 2);

  if AnsiCompareText(TipoRecord, 'IB') = 0 then
    Result := ttRiba
  else
    if AnsiCompareText(TipoRecord, 'IM') = 0 then
      Result := ttMAV
    else
      if AnsiCompareText(TipoRecord, 'IR') = 0 then
        Result := ttRID
      else
        if AnsiCompareText(TipoRecord, 'ID') = 0 then
          Result := ttAltri
        else
          if AnsiCompareText(TipoRecord, 'BB') = 0 then
            Result := ttBollettinoBancario
          else
            if AnsiCompareText(TipoRecord, 'AL') = 0 then
              Result := ttAllineamento
            else
              if AnsiCompareText(TipoRecord, 'RH') = 0 then
                Result := ttRiconciliazione;
end;

function GetTipoFlussoFromFileName(const FileName: string): TTipoFlusso;
var
  Header: string;
  f: TextFile;
begin
  result := ttNullo;

  if FileName = '' then
    exit;

  if not FileExists(FileName) then
    exit;

  AssignFile(F, FileName);
  try
    Reset(F);
    Readln(f, Header);
  finally
    CloseFile(F)
  end;

  result := GetTipoFlusso(Header);
end;

function TipoFlussoStr(TipoFlusso: TTipoFlusso): string;
begin
  result := '';
  case TipoFlusso of
    ttNullo: result := '000';
    ttRiba: result := 'RIB';
    ttMAV: result := 'MAV';
    ttRID: result := 'RID';
    ttAltri: result := 'ALT';
    ttBollettinoBancario: result := 'BB';
    ttAllineamento: result := 'ALL';
    ttRiconciliazione: result := 'RIC';
  end;
end;

end.

