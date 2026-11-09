unit zz.strings;

interface

uses
  SysUtils;

type
  TCharSet = set of char;

function PadString(const S: string; N: Integer; C: char = '0'): string;

function PadStringRight(const S: string; N: Integer; C: char = '0'): string;

function WordCount(const S: string; const WordDelims: TCharSet): Integer;

function ExtractWord(N: Integer; const S: string; const WordDelims: TCharSet): string;

function RemoveCR(const S: string): string;

function IIF(const Condition: boolean; const ValueTrue: string; const ValueFalse: string): string;

function StartingWith(const S: string; const SubStr: string): boolean;

function RemoveStrings(const S: string; Strings2Remove: array of string): string;

implementation

uses
  StrUtils;

function PadString(const S: string; N: Integer; C: char = '0'): string;
begin
  Result := S.PadLeft(N, C);
end;

function PadStringRight(const S: string; N: Integer; C: char = '0'): string;
begin
  Result := S.PadRight(N, C);
end;

function WordCount(const S: string; const WordDelims: TCharSet): Integer;
var
  SLen, I: Cardinal;
begin
  Result := 0;
  I := 1;
  SLen := Length(S);
  while I <= SLen do
  begin
    while (I <= SLen) and (S[I] in WordDelims) do
      Inc(I);
    if I <= SLen then
      Inc(Result);
    while (I <= SLen) and not(S[I] in WordDelims) do
      Inc(I);
  end;
end;

function ExtractWord(N: Integer; const S: string; const WordDelims: TCharSet): string;
  function WordPosition(const N: Integer; const S: string; const WordDelims: TCharSet): Integer;
  var
    Count, I: Integer;
  begin
    Count := 0;
    I := 1;
    Result := 0;
    while (I <= Length(S)) and (Count <> N) do
    begin
      { skip over delimiters }
      while (I <= Length(S)) and (S[I] in WordDelims) do
        Inc(I);
      { if we're not beyond end of S, we're at the start of a word }
      if I <= Length(S) then
        Inc(Count);
      { if not finished, find the end of the current word }
      if Count <> N then
        while (I <= Length(S)) and not(S[I] in WordDelims) do
          Inc(I)
      else
        Result := I;
    end;
  end;

var
  I: Integer;
  Len: Integer;
begin
  Result := '';
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not(S[I] in WordDelims) do
    begin
      Result := Result + S[I];
      Inc(I);
    end;
end;

function RemoveCR(const S: string): string;
begin
  Result := StringReplace(AdjustLineBreaks(S), #13#10, ' ', [rfReplaceAll]);
end;

function IIF(const Condition: boolean; const ValueTrue: string; const ValueFalse: string): string;
begin
  if Condition then
    Result := ValueTrue
  else
    Result := ValueFalse;
end;

function RemoveStrings(const S: string; Strings2Remove: array of string): string;
var
  tmp: string;
begin
  Result := S;
  for tmp in Strings2Remove do
    Result := StringReplace(Result, tmp, '', [rfReplaceAll, rfIgnoreCase]);
end;

function StartingWith(const S: string; const SubStr: string): boolean;
begin
  Result := S.StartsWith(SubStr, True);
end;

end.
