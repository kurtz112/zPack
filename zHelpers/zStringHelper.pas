unit zStringHelper;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TzStringHelper = record helper for
    string public class
    function Coalesce(const value1, value2: string): string;
    static;
    class function IIF(const condition: boolean; const valueTrue, valueFalse: string): string; static;
  end;

implementation

class function TzStringHelper.Coalesce(const value1, value2: string): string;
var
  s: String;
begin
  if not value1.isEmpty then
    result := value1
  else
    if not value2.isEmpty then
      result := value2
    else
      result := '';
end;

class function TzStringHelper.IIF(const condition: boolean; const valueTrue, valueFalse: string): string;
begin
  if condition then
    result := valueTrue
  else
    result := valueFalse;
end;

end.
