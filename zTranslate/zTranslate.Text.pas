// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-11
// ---------------------------------------------------------------------------
unit zTranslate.Text;

// Regole sul testo condivise dalla libreria di esecuzione e dal programma
// zTranslate: formato delle righe di italiano.txt e segnaposto di Format.
// Usa solo la RTL.

interface

const
  // Prima riga di italiano.txt: #zTranslate lingua=italiano formato=1 ...
  TextHeaderPrefix = '#zTranslate';
  TextFormatVersion = 1;

// Una riga di italiano.txt: famiglia.nome=testo, con \n, \r, \t e \\.
function EscapeText(const Value: string): string;
function UnescapeText(const Value: string): string;
function FormatTextLine(const Id, Value: string): string;
function ParseTextLine(const Line: string; out Id, Value: string): boolean;

// L'id e' famiglia.nome: il nome di una costante non contiene punti, la
// famiglia si', quindi si divide all'ultimo punto.
function MakeId(const Family, Name: string): string;
function SplitId(const Id: string; out Family, Name: string): boolean;

// Segnaposto di Format normalizzati come "indice:tipo" (0:s, 1:d...), senza
// doppioni e in ordine: "%s di %s" e "%1:s di %0:s" danno lo stesso elenco.
// Un * di larghezza o precisione consuma un argomento intero e compare come d.
function FormatPlaceholders(const Value: string): TArray<string>;
// I segnaposto cosi' come compaiono nel testo, nell'ordine: %s, %0:d, %-10s
function FormatPlaceholderTokens(const Value: string): TArray<string>;
function SamePlaceholders(const English, Translated: string): boolean;
function PlaceholdersText(const Value: string): string;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults;

function EscapeText(const Value: string): string;
var
  Builder: TStringBuilder;
  Character: Char;
begin
  Builder := TStringBuilder.Create(Length(Value) + 16);
  try
    for Character in Value do
      case Character of
        '\':
          Builder.Append('\\');
        #10:
          Builder.Append('\n');
        #13:
          Builder.Append('\r');
        #9:
          Builder.Append('\t');
      else
        Builder.Append(Character);
      end;
    result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function UnescapeText(const Value: string): string;
var
  Builder: TStringBuilder;
  Index: integer;
begin
  if Pos('\', Value) = 0 then
    exit(Value);

  Builder := TStringBuilder.Create(Length(Value));
  try
    Index := 1;
    while Index <= Length(Value) do
    begin
      if (Value[Index] = '\') and (Index < Length(Value)) then
      begin
        Inc(Index);
        case Value[Index] of
          'n':
            Builder.Append(#10);
          'r':
            Builder.Append(#13);
          't':
            Builder.Append(#9);
          '\':
            Builder.Append('\');
        else
          // Sequenza sconosciuta: si tiene com'e', il programma non la scrive mai
          Builder.Append('\').Append(Value[Index]);
        end;
      end
      else
        Builder.Append(Value[Index]);
      Inc(Index);
    end;
    result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function FormatTextLine(const Id, Value: string): string;
begin
  result := Id + '=' + EscapeText(Value);
end;

function ParseTextLine(const Line: string; out Id, Value: string): boolean;
var
  Separator: integer;
begin
  result := false;
  Id := '';
  Value := '';

  if (Line = '') or (Line[1] = '#') then
    exit;

  Separator := Pos('=', Line);
  if Separator <= 1 then
    exit;

  Id := Copy(Line, 1, Separator - 1);
  Value := UnescapeText(Copy(Line, Separator + 1, MaxInt));
  result := true;
end;

function MakeId(const Family, Name: string): string;
begin
  result := Family + '.' + Name;
end;

function SplitId(const Id: string; out Family, Name: string): boolean;
var
  Separator: integer;
begin
  Separator := LastDelimiter('.', Id);
  result := (Separator > 1) and (Separator < Length(Id));

  if result then
  begin
    Family := Copy(Id, 1, Separator - 1);
    Name := Copy(Id, Separator + 1, MaxInt);
  end
  else
  begin
    Family := '';
    Name := '';
  end;
end;

procedure ScanPlaceholders(const Value: string; out Normalized, Raw: TArray<string>); forward;

function FormatPlaceholders(const Value: string): TArray<string>;
var
  Raw: TArray<string>;
begin
  ScanPlaceholders(Value, result, Raw);
end;

function FormatPlaceholderTokens(const Value: string): TArray<string>;
var
  Normalized: TArray<string>;
begin
  ScanPlaceholders(Value, Normalized, result);
end;

procedure ScanPlaceholders(const Value: string; out Normalized, Raw: TArray<string>);
var
  Found: TList<string>;
  Tokens: TList<string>;
  Index, Start, NextArgument, Number: integer;
  HasNumber, IsStar: boolean;

  procedure ReadNumber;
  begin
    HasNumber := false;
    IsStar := false;
    Number := 0;

    if (Index <= Length(Value)) and (Value[Index] = '*') then
    begin
      IsStar := true;
      Inc(Index);
      exit;
    end;

    while (Index <= Length(Value)) and CharInSet(Value[Index], ['0'..'9']) do
    begin
      HasNumber := true;
      Number := Number * 10 + Ord(Value[Index]) - Ord('0');
      Inc(Index);
    end;
  end;

  procedure AddArgument(const Kind: Char);
  var
    Item: string;
  begin
    Item := IntToStr(NextArgument) + ':' + Kind;
    if not Found.Contains(Item) then
      Found.Add(Item);
    Inc(NextArgument);
  end;

var
  Candidates: TList<string>;
  SavedNext: integer;
begin
  Found := TList<string>.Create;
  Tokens := TList<string>.Create;
  try
    Index := 1;
    NextArgument := 0;

    while Index <= Length(Value) do
    begin
      if Value[Index] <> '%' then
      begin
        Inc(Index);
        continue;
      end;

      Inc(Index);
      if Index > Length(Value) then
        break;

      if Value[Index] = '%' then
      begin
        Inc(Index);
        continue;
      end;

      // Un segnaposto non valido ("100% pieno") non e' un segnaposto: si
      // riprende la scansione subito dopo il %, senza contare argomenti.
      Start := Index;
      SavedNext := NextArgument;
      Candidates := TList<string>.Create;
      try
        // indice esplicito, larghezza con *, precisione con *
        ReadNumber;
        if (Index <= Length(Value)) and (Value[Index] = ':') and (HasNumber or IsStar) then
        begin
          if HasNumber then
            NextArgument := Number;
          Inc(Index);
          ReadNumber;
        end;

        if (Index <= Length(Value)) and (Value[Index] = '-') then
        begin
          Inc(Index);
          ReadNumber;
        end;
        if IsStar then
          Candidates.Add('d');

        if (Index <= Length(Value)) and (Value[Index] = '.') then
        begin
          Inc(Index);
          ReadNumber;
          if IsStar then
            Candidates.Add('d');
        end;

        if (Index <= Length(Value)) and CharInSet(Value[Index], ['d', 'u', 'e', 'f', 'g', 'n', 'm', 'p', 's', 'x', 'D', 'U', 'E', 'F', 'G', 'N', 'M', 'P', 'S', 'X']) then
        begin
          for var Kind in Candidates do
            AddArgument(Kind[1]);
          AddArgument(LowerCase(Value[Index])[1]);
          Inc(Index);
          Tokens.Add(Copy(Value, Start - 1, Index - Start + 1));
        end
        else
        begin
          NextArgument := SavedNext;
          Index := Start;
        end;
      finally
        Candidates.Free;
      end;
    end;

    Found.Sort(TComparer<string>.Default);
    Normalized := Found.ToArray;
    Raw := Tokens.ToArray;
  finally
    Tokens.Free;
    Found.Free;
  end;
end;

function PlaceholdersText(const Value: string): string;
begin
  result := string.Join(' ', FormatPlaceholders(Value));
end;

function SamePlaceholders(const English, Translated: string): boolean;
var
  EnglishPlaceholders, TranslatedPlaceholders: TArray<string>;
  Index: integer;
begin
  EnglishPlaceholders := FormatPlaceholders(English);
  TranslatedPlaceholders := FormatPlaceholders(Translated);

  result := Length(EnglishPlaceholders) = Length(TranslatedPlaceholders);
  if result then
    for Index := 0 to High(EnglishPlaceholders) do
      if EnglishPlaceholders[Index] <> TranslatedPlaceholders[Index] then
        exit(false);
end;

end.
