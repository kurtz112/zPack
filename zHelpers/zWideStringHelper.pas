unit zWideStringHelper;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TWideStringHelper = record helper for widestring
  private
    function GetLength: Integer; inline;
  public
    property Length: Integer read GetLength;

    function PadLeft(TotalWidth: Integer): string; overload; inline;
    function PadLeft(TotalWidth: Integer; PaddingChar: Char): string; overload; inline;

    function PadRight(TotalWidth: Integer): string; overload; inline;
    function PadRight(TotalWidth: Integer; PaddingChar: Char): string; overload; inline;
  end;

implementation

function TWideStringHelper.GetLength: Integer;
begin
  Result := System.Length(Self);
end;

function TWideStringHelper.PadLeft(TotalWidth: Integer): string;
begin
  Result := PadLeft(TotalWidth, ' ');
end;

function TWideStringHelper.PadLeft(TotalWidth: Integer; PaddingChar: Char): string;
begin
  TotalWidth := TotalWidth - Length;
  if TotalWidth > 0 then
    Result := System.StringOfChar(PaddingChar, TotalWidth) + Self
  else
    Result := Self;
end;

function TWideStringHelper.PadRight(TotalWidth: Integer): string;
begin
  Result := PadRight(TotalWidth, ' ');
end;

function TWideStringHelper.PadRight(TotalWidth: Integer; PaddingChar: Char): string;
begin
  TotalWidth := TotalWidth - Length;
  if TotalWidth > 0 then
    Result := Self + System.StringOfChar(PaddingChar, TotalWidth)
  else
    Result := Self;
end;

end.
