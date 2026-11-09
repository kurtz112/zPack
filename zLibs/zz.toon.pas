unit zz.toon;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

type
  TzToon = class
  private
    class procedure WriteValue(const ASB: TStringBuilder; const AValue: TJSONValue;
      AIndent: Integer; AInline: Boolean); static;
    class procedure WriteObject(const ASB: TStringBuilder; const AObj: TJSONObject;
      AIndent: Integer); static;
    // Scrive un oggetto potendo saltare il rientro della PRIMA coppia: serve
    // agli elementi di un elenco, dove la prima chiave prosegue dopo il "- "
    class procedure WriteObjectEx(const ASB: TStringBuilder; const AObj: TJSONObject;
      AIndent: Integer; const ASkipFirstIndent: Boolean); static;
    // Scrive il valore di una coppia gia' aperta: l'intestazione di un array
    // ([N]{...}:) prosegue sulla riga della chiave
    class procedure WriteValueKeyed(const ASB: TStringBuilder; const AValue: TJSONValue;
      AIndent: Integer); static;
    class procedure WriteArray(const ASB: TStringBuilder; const AArr: TJSONArray;
      AIndent: Integer); static;
    class function Indent(ALevel: Integer): string; static;
    class function FormatScalar(const AValue: TJSONValue): string; static;
    class function NeedsQuoting(const AStr: string): Boolean; static;
    class function QuoteString(const AStr: string): string; static;
    class function IsScalar(const AValue: TJSONValue): Boolean; static;
    class function IsTabularArray(const AArr: TJSONArray; out AKeys: TArray<string>): Boolean; static;
  public
    class function FromJsonValue(const AValue: TJSONValue): string; static;
    class function FromJsonObject(const AObj: TJSONObject): string; static;
    class function FromJsonArray(const AArr: TJSONArray): string; static;
    class function FromString(const AJson: string): string; static;

    // --- lettura: TOON -> JSON ---------------------------------------------
    // Il verso inverso serve per le risposte di un modello AI, che il TOON lo
    // scrive di suo pugno e quindi ogni tanto lo sbaglia: il lettore e' percio'
    // TOLLERANTE (vedi le note in implementazione).
    // Il valore ritornato da ToJsonValue e' del chiamante, che lo libera.
    class function ToJsonValue(const AToon: string): TJSONValue; static;
    class function ToJsonString(const AToon: string; const AFormatIndent: Integer = 0): string; static;
  end;

implementation

const
  INDENT_UNIT = '  '; // 2 spazi

{ TzToon }

class function TzToon.Indent(ALevel: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to ALevel - 1 do
    Result := Result + INDENT_UNIT;
end;

class function TzToon.IsScalar(const AValue: TJSONValue): Boolean;
begin
  Result := not (AValue is TJSONObject) and not (AValue is TJSONArray);
end;

class function TzToon.NeedsQuoting(const AStr: string): Boolean;
var
  C: Char;
begin
  if AStr = '' then
    Exit(True);
  // quoting se contiene caratteri strutturali, spazi iniziali/finali,
  // o sembra un numero/booleano/null
  if (AStr <> Trim(AStr)) then
    Exit(True);
  for C in AStr do
    if CharInSet(C, [':', ',', '[', ']', '{', '}', '"', '#', #9, #10, #13]) then
      Exit(True);
  if SameText(AStr, 'true') or SameText(AStr, 'false') or SameText(AStr, 'null') then
    Exit(True);
  // se è interpretabile come numero va quotato per non confonderlo con un numero
  var D: Double;
  if TryStrToFloat(AStr, D, TFormatSettings.Invariant) then
    Exit(True);
  Result := False;
end;

class function TzToon.QuoteString(const AStr: string): string;
begin
  Result := '"' + AStr
    .Replace('\', '\\', [rfReplaceAll])
    .Replace('"', '\"', [rfReplaceAll])
    .Replace(#13, '\r', [rfReplaceAll])
    .Replace(#10, '\n', [rfReplaceAll])
    .Replace(#9, '\t', [rfReplaceAll]) + '"';
end;

class function TzToon.FormatScalar(const AValue: TJSONValue): string;
begin
  if AValue is TJSONNull then
    Result := 'null'
  else if AValue is TJSONTrue then
    Result := 'true'
  else if AValue is TJSONFalse then
    Result := 'false'
  else if AValue is TJSONNumber then
    Result := TJSONNumber(AValue).ToString
  else if AValue is TJSONString then
  begin
    var S := TJSONString(AValue).Value;
    if NeedsQuoting(S) then
      Result := QuoteString(S)
    else
      Result := S;
  end
  else
    Result := AValue.ToString;
end;

class function TzToon.IsTabularArray(const AArr: TJSONArray;
  out AKeys: TArray<string>): Boolean;
var
  I, J: Integer;
  FirstObj, Obj: TJSONObject;
  Pair: TJSONPair;
begin
  AKeys := nil;
  Result := False;
  if AArr.Count = 0 then
    Exit;

  // tutti gli elementi devono essere oggetti con scalari e stesse chiavi nello stesso ordine
  if not (AArr.Items[0] is TJSONObject) then
    Exit;
  FirstObj := TJSONObject(AArr.Items[0]);
  if FirstObj.Count = 0 then
    Exit;

  SetLength(AKeys, FirstObj.Count);
  for J := 0 to FirstObj.Count - 1 do
  begin
    Pair := FirstObj.Pairs[J];
    if not IsScalar(Pair.JsonValue) then
      Exit;
    AKeys[J] := Pair.JsonString.Value;
  end;

  for I := 1 to AArr.Count - 1 do
  begin
    if not (AArr.Items[I] is TJSONObject) then
      Exit;
    Obj := TJSONObject(AArr.Items[I]);
    if Obj.Count <> Length(AKeys) then
      Exit;
    for J := 0 to Obj.Count - 1 do
    begin
      Pair := Obj.Pairs[J];
      if Pair.JsonString.Value <> AKeys[J] then
        Exit;
      if not IsScalar(Pair.JsonValue) then
        Exit;
    end;
  end;

  Result := True;
end;

class procedure TzToon.WriteArray(const ASB: TStringBuilder;
  const AArr: TJSONArray; AIndent: Integer);
var
  Keys: TArray<string>;
  I, J: Integer;
  Obj: TJSONObject;
  Cells: TArray<string>;
  Item: TJSONValue;
begin
  if IsTabularArray(AArr, Keys) then
  begin
    // forma tabellare: [N]{k1,k2,...}:
    ASB.Append('[').Append(AArr.Count).Append(']{')
       .Append(string.Join(',', Keys)).Append('}:').AppendLine;
    for I := 0 to AArr.Count - 1 do
    begin
      Obj := TJSONObject(AArr.Items[I]);
      SetLength(Cells, Length(Keys));
      for J := 0 to High(Keys) do
        Cells[J] := FormatScalar(Obj.Pairs[J].JsonValue);
      ASB.Append(Indent(AIndent + 1))
         .Append(string.Join(',', Cells)).AppendLine;
    end;
  end
  else
  begin
    // array generico: [N]:
    ASB.Append('[').Append(AArr.Count).Append(']:').AppendLine;
    for I := 0 to AArr.Count - 1 do
    begin
      Item := AArr.Items[I];
      ASB.Append(Indent(AIndent + 1)).Append('- ');
      if IsScalar(Item) then
        ASB.Append(FormatScalar(Item)).AppendLine
      else
        WriteValue(ASB, Item, AIndent + 1, True);
    end;
  end;
end;

class procedure TzToon.WriteObject(const ASB: TStringBuilder;
  const AObj: TJSONObject; AIndent: Integer);
begin
  WriteObjectEx(ASB, AObj, AIndent, False);
end;

class procedure TzToon.WriteObjectEx(const ASB: TStringBuilder;
  const AObj: TJSONObject; AIndent: Integer; const ASkipFirstIndent: Boolean);
var
  I: Integer;
  Pair: TJSONPair;
  Key: string;
begin
  for I := 0 to AObj.Count - 1 do
  begin
    Pair := AObj.Pairs[I];
    Key := Pair.JsonString.Value;
    if NeedsQuoting(Key) then
      Key := QuoteString(Key);

    // la prima coppia di un elemento di elenco prosegue sulla riga del "- "
    if (I > 0) or (not ASkipFirstIndent) then
      ASB.Append(Indent(AIndent));

    ASB.Append(Key);
    if IsScalar(Pair.JsonValue) then
      ASB.Append(': ').Append(FormatScalar(Pair.JsonValue)).AppendLine
    else
    begin
      // oggetto/array annidato: la chiave precede la struttura
      if Pair.JsonValue is TJSONArray then
      begin
        ASB.Append(string.Empty); // l'header [N]... segue sulla stessa riga
        WriteValueKeyed(ASB, Pair.JsonValue, AIndent);
      end
      else
      begin
        ASB.Append(':').AppendLine;
        WriteObject(ASB, TJSONObject(Pair.JsonValue), AIndent + 1);
      end;
    end;
  end;
end;

class procedure TzToon.WriteValueKeyed(const ASB: TStringBuilder;
  const AValue: TJSONValue; AIndent: Integer);
begin
  if AValue is TJSONArray then
    // l'intestazione [N]: oppure [N]{k1,k2}: sta sulla riga della chiave
    WriteArray(ASB, TJSONArray(AValue), AIndent)
  else
    if AValue is TJSONObject then
    begin
      ASB.Append(':').AppendLine;
      WriteObject(ASB, TJSONObject(AValue), AIndent + 1);
    end
    else
      ASB.Append(': ').Append(FormatScalar(AValue)).AppendLine;
end;

class procedure TzToon.WriteValue(const ASB: TStringBuilder;
  const AValue: TJSONValue; AIndent: Integer; AInline: Boolean);
begin

  if IsScalar(AValue) then
  begin
    ASB.Append(FormatScalar(AValue)).AppendLine;
    exit;
  end;

  if AValue is TJSONArray then
    WriteArray(ASB, TJSONArray(AValue), AIndent)
  else
    // AInline vero = si arriva da un "- " gia' scritto: la prima chiave
    // prosegue li', le altre si rientrano di un livello
    WriteObjectEx(ASB, TJSONObject(AValue), AIndent + 1, AInline);
end;

class function TzToon.FromJsonValue(const AValue: TJSONValue): string;
var
  Builder: TStringBuilder;
begin
  Result := '';

  if not Assigned(AValue) then
    exit;

  Builder := TStringBuilder.Create;
  try

    if AValue is TJSONObject then
      WriteObject(Builder, TJSONObject(AValue), 0)
    else
      if AValue is TJSONArray then
        WriteArray(Builder, TJSONArray(AValue), 0)
      else
        Builder.Append(FormatScalar(AValue)).AppendLine;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TzToon.FromJsonObject(const AObj: TJSONObject): string;
begin
  Result := FromJsonValue(AObj);
end;

class function TzToon.FromJsonArray(const AArr: TJSONArray): string;
begin
  Result := FromJsonValue(AArr);
end;

class function TzToon.FromString(const AJson: string): string;
var
  Value: TJSONValue;
begin
  // RaiseExc vero: un JSON malformato deve farsi sentire, non produrre una
  // stringa vuota che poi arriva al modello
  Value := TJSONObject.ParseJSONValue(AJson, False, True);
  try
    Result := FromJsonValue(Value);
  finally
    Value.Free;
  end;
end;

{ ------------------------------------------------------------------------------
  Lettura TOON -> JSON

  Il testo da leggere lo scrive un modello AI, non questa unit: e' quindi
  scontato che ogni tanto sia imperfetto. Il lettore non pretende un TOON
  ineccepibile, recupera dove puo'. In particolare:

   - il conteggio [N] dichiarato viene IGNORATO: contano le righe che ci sono
     davvero, perche' e' il numero la cosa piu' facile da sbagliare;
   - il rientro conta come RELAZIONE (piu' rientrato = figlio), non come
     multiplo esatto di due spazi; le tabulazioni valgono due spazi;
   - righe vuote, recinzioni di codice e la riga con la sola parola del
     formato si saltano;
   - in una riga di tabella, se le celle sono MENO delle colonne le mancanti
     restano vuote; se sono di PIU', le eccedenti si riuniscono nell'ultima
     colonna: e' il recupero del caso piu' frequente, una descrizione con la
     virgola che il modello ha dimenticato di proteggere con le virgolette, e
     che nelle nostre strutture e' sempre l'ultimo campo;
   - una riga che non si lascia interpretare viene saltata invece di far
     fallire tutta la lettura.

  Limite noto, inerente al formato: dentro un elemento di elenco, un oggetto
  il cui PRIMO campo sia a sua volta un elenco non e' distinguibile dai campi
  fratelli, perche' starebbero allo stesso rientro. Le strutture di HelpGen
  non lo fanno mai (il primo campo e' sempre un testo).

  Chi legge deve comunque controllare il risultato: un TOON storpiato produce
  un JSON valido ma povero, non un errore.
  ------------------------------------------------------------------------------ }

type
  TzToonLine = record
    Indent: Integer;
    Text: string;
  end;

  TzToonReader = class
  private
    FLines: TList<TzToonLine>;
    FIndex: Integer;
    procedure LoadLines(const AToon: string);
    function Eof: Boolean;
    function CurrentIndent: Integer;
    function CurrentText: string;
    procedure ReplaceCurrentText(const AText: string);
    // Divide "chiave: resto" oppure "chiave[N]...", tenendo conto della
    // chiave fra virgolette. Falso se la riga non e' una coppia
    function SplitKey(const ALine: string; out AKey, ARest: string): Boolean;
    // Legge l'intestazione di un elenco: "[N]:" oppure "[N]{k1,k2}:"
    function ParseArrayHeader(const ARest: string; out AKeys: TArray<string>): Boolean;
    procedure ParsePair(const AObject: TJSONObject; const AIndent: Integer);
    function ParseObject(const AIndent: Integer): TJSONObject;
    function ParseTable(const AKeys: TArray<string>; const AIndent: Integer): TJSONArray;
    function ParseList(const AIndent: Integer): TJSONArray;
    function ParseListItem(const AItemIndent: Integer): TJSONValue;
  public
    constructor Create(const AToon: string);
    destructor Destroy; override;
    function Parse: TJSONValue;
  end;

function ToonUnquote(const AValue: string): string;
var
  Builder: TStringBuilder;
  I: Integer;
  C: Char;
begin
  Result := AValue;

  if (Length(AValue) < 2) or (AValue[1] <> '"') then
    exit;

  Builder := TStringBuilder.Create;
  try
    I := 2;

    while I <= Length(AValue) do
    begin
      C := AValue[I];

      if (C = '"') and (I = Length(AValue)) then
        Break;

      if (C = '\') and (I < Length(AValue)) then
      begin
        inc(I);

        case AValue[I] of
          'n': Builder.Append(#10);
          'r': Builder.Append(#13);
          't': Builder.Append(#9);
        else
          Builder.Append(AValue[I]);
        end;
      end
      else
        Builder.Append(C);

      inc(I);
    end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

// Divide una riga di tabella sulle virgole che stanno FUORI dalle virgolette
function ToonSplitCells(const ALine: string): TArray<string>;
var
  Cells: TList<string>;
  Builder: TStringBuilder;
  I: Integer;
  C: Char;
  InQuotes: Boolean;
begin
  Cells := TList<string>.Create;
  Builder := TStringBuilder.Create;
  try
    InQuotes := False;
    I := 1;

    while I <= Length(ALine) do
    begin
      C := ALine[I];

      if InQuotes and (C = '\') and (I < Length(ALine)) then
      begin
        Builder.Append(C).Append(ALine[I + 1]);
        inc(I, 2);
        Continue;
      end;

      if C = '"' then
        InQuotes := not InQuotes;

      if (C = ',') and (not InQuotes) then
      begin
        // le celle NON si tagliano qui: se vanno riunite (virgola non
        // protetta) gli spazi originali devono sopravvivere. Il taglio lo fa
        // ToonScalar sul valore singolo
        Cells.Add(Builder.ToString);
        Builder.Clear;
      end
      else
        Builder.Append(C);

      inc(I);
    end;

    Cells.Add(Builder.ToString);
    Result := Cells.ToArray;
  finally
    Builder.Free;
    Cells.Free;
  end;
end;

function ToonScalar(const AText: string): TJSONValue;
var
  Testo: string;
  Numero: Double;
begin
  Testo := AText.Trim;

  if Testo.StartsWith('"') then
    exit(TJSONString.Create(ToonUnquote(Testo)));

  if Testo.IsEmpty or SameText(Testo, 'null') then
    exit(TJSONNull.Create);

  if SameText(Testo, 'true') then
    exit(TJSONTrue.Create);

  if SameText(Testo, 'false') then
    exit(TJSONFalse.Create);

  // La scrittura mette fra virgolette tutto cio' che SEMBRA un numero: un
  // valore nudo che si legge come numero e' quindi davvero un numero
  if TryStrToFloat(Testo, Numero, TFormatSettings.Invariant) then
    exit(TJSONNumber.Create(Testo));

  Result := TJSONString.Create(Testo);
end;

{ TzToonReader }

constructor TzToonReader.Create(const AToon: string);
begin
  inherited Create;
  FLines := TList<TzToonLine>.Create;
  FIndex := 0;
  LoadLines(AToon);
end;

destructor TzToonReader.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TzToonReader.LoadLines(const AToon: string);
var
  Righe: TArray<string>;
  Riga: string;
  Testo: string;
  Voce: TzToonLine;
  Conteggio: Integer;
  I: Integer;
begin
  Righe := AToon.Replace(#9, '  ', [rfReplaceAll]).Replace(#13#10, #10, [rfReplaceAll]).Split([#10]);

  for Riga in Righe do
  begin
    Testo := Riga.TrimRight;

    if Testo.Trim.IsEmpty then
      Continue;

    if Testo.Trim.StartsWith('```') then
      Continue;

    if SameText(Testo.Trim, 'toon') or SameText(Testo.Trim, 'json') then
      Continue;

    Conteggio := 0;

    for I := 1 to Length(Testo) do
      if Testo[I] = ' ' then
        inc(Conteggio)
      else
        Break;

    Voce.Indent := Conteggio;
    Voce.Text := Testo.Trim;
    FLines.Add(Voce);
  end;
end;

function TzToonReader.Eof: Boolean;
begin
  Result := FIndex >= FLines.Count;
end;

function TzToonReader.CurrentIndent: Integer;
begin
  if Eof then
    Result := -1
  else
    Result := FLines[FIndex].Indent;
end;

function TzToonReader.CurrentText: string;
begin
  if Eof then
    Result := ''
  else
    Result := FLines[FIndex].Text;
end;

procedure TzToonReader.ReplaceCurrentText(const AText: string);
var
  Voce: TzToonLine;
begin
  if Eof then
    exit;

  Voce := FLines[FIndex];
  Voce.Text := AText;
  FLines[FIndex] := Voce;
end;

function TzToonReader.SplitKey(const ALine: string; out AKey, ARest: string): Boolean;
var
  I: Integer;
  Fine: Integer;
begin
  AKey := '';
  ARest := '';
  Result := False;

  if ALine.IsEmpty then
    exit;

  if ALine[1] = '"' then
  begin
    Fine := 0;
    I := 2;

    while I <= Length(ALine) do
    begin

      if (ALine[I] = '\') and (I < Length(ALine)) then
      begin
        inc(I, 2);
        Continue;
      end;

      if ALine[I] = '"' then
      begin
        Fine := I;
        Break;
      end;

      inc(I);
    end;

    if Fine = 0 then
      exit;

    ARest := Copy(ALine, Fine + 1, MaxInt).TrimLeft;

    // Dopo la chiusura delle virgolette deve venire ':' o '[': altrimenti non
    // e' una chiave, e' un valore di testo che comincia con le virgolette
    if not (ARest.StartsWith(':') or ARest.StartsWith('[')) then
    begin
      ARest := '';
      exit;
    end;

    AKey := ToonUnquote(Copy(ALine, 1, Fine));
    exit(True);
  end;

  for I := 1 to Length(ALine) do
    if CharInSet(ALine[I], [':', '[']) then
    begin
      AKey := Copy(ALine, 1, I - 1).Trim;
      ARest := Copy(ALine, I, MaxInt);
      exit(not AKey.IsEmpty);
    end;
end;

function TzToonReader.ParseArrayHeader(const ARest: string; out AKeys: TArray<string>): Boolean;
var
  ChiusuraQuadra: Integer;
  Coda: string;
  ChiusuraGraffa: Integer;
  Chiave: string;
  Elenco: TList<string>;
begin
  AKeys := nil;
  Result := False;

  if not ARest.StartsWith('[') then
    exit;

  ChiusuraQuadra := ARest.IndexOf(']');

  if ChiusuraQuadra < 0 then
    exit;

  // Il numero dichiarato fra quadre non si legge: contano le righe vere
  Coda := ARest.Substring(ChiusuraQuadra + 1).Trim;
  Result := True;

  if not Coda.StartsWith('{') then
    exit;

  ChiusuraGraffa := Coda.IndexOf('}');

  if ChiusuraGraffa < 0 then
    exit;

  Elenco := TList<string>.Create;
  try

    for Chiave in Coda.Substring(1, ChiusuraGraffa - 1).Split([',']) do
      Elenco.Add(ToonUnquote(Chiave.Trim));

    AKeys := Elenco.ToArray;
  finally
    Elenco.Free;
  end;
end;

function TzToonReader.ParseTable(const AKeys: TArray<string>; const AIndent: Integer): TJSONArray;
var
  Riga: TJSONObject;
  Celle: TArray<string>;
  I: Integer;
  Ultima: string;
begin
  Result := TJSONArray.Create;

  while (not Eof) and (CurrentIndent > AIndent) and (not CurrentText.StartsWith('- ')) do
  begin
    Celle := ToonSplitCells(CurrentText);
    Riga := TJSONObject.Create;

    for I := 0 to High(AKeys) do
    begin

      if I > High(Celle) then
      begin
        // celle in meno: colonna vuota, meglio di una riga persa
        Riga.AddPair(AKeys[I], TJSONString.Create(''));
        Continue;
      end;

      if (I = High(AKeys)) and (High(Celle) > High(AKeys)) then
      begin
        // celle in piu': si riuniscono nell'ultima colonna
        Ultima := string.Join(',', Copy(Celle, I, Length(Celle) - I));
        Riga.AddPair(AKeys[I], ToonScalar(Ultima));
        Continue;
      end;

      Riga.AddPair(AKeys[I], ToonScalar(Celle[I]));
    end;

    Result.AddElement(Riga);
    inc(FIndex);
  end;
end;

procedure TzToonReader.ParsePair(const AObject: TJSONObject; const AIndent: Integer);
var
  Chiave: string;
  Coda: string;
  Chiavi: TArray<string>;
begin

  if not SplitKey(CurrentText, Chiave, Coda) then
  begin
    inc(FIndex);
    exit;
  end;

  inc(FIndex);

  if Coda.StartsWith('[') then
  begin

    if ParseArrayHeader(Coda, Chiavi) and (Length(Chiavi) > 0) then
      AObject.AddPair(Chiave, ParseTable(Chiavi, AIndent))
    else
      AObject.AddPair(Chiave, ParseList(AIndent));

    exit;
  end;

  if Coda.StartsWith(':') then
  begin
    Coda := Coda.Substring(1).Trim;

    if not Coda.IsEmpty then
    begin
      AObject.AddPair(Chiave, ToonScalar(Coda));
      exit;
    end;

    // valore sulle righe seguenti: oggetto annidato, oppure niente
    if (not Eof) and (CurrentIndent > AIndent) and (not CurrentText.StartsWith('- ')) then
      AObject.AddPair(Chiave, ParseObject(CurrentIndent))
    else
      AObject.AddPair(Chiave, TJSONNull.Create);

    exit;
  end;

  AObject.AddPair(Chiave, TJSONNull.Create);
end;

function TzToonReader.ParseObject(const AIndent: Integer): TJSONObject;
begin
  Result := TJSONObject.Create;

  while (not Eof) and (CurrentIndent >= AIndent) do
  begin

    if CurrentText.StartsWith('- ') then
      Break;

    if CurrentIndent > AIndent then
    begin
      // riga orfana, piu' rientrata di quanto la struttura preveda
      inc(FIndex);
      Continue;
    end;

    ParsePair(Result, AIndent);
  end;
end;

function TzToonReader.ParseListItem(const AItemIndent: Integer): TJSONValue;
var
  Testa: string;
  Chiave: string;
  Coda: string;
  Chiavi: TArray<string>;
  Oggetto: TJSONObject;
  Figli: TJSONObject;
  Coppia: TJSONPair;
begin
  // La riga corrente e' quella dell'elemento, gia' privata del "- "
  if CurrentText.StartsWith('[') then
  begin
    Testa := CurrentText;
    inc(FIndex);

    if ParseArrayHeader(Testa, Chiavi) and (Length(Chiavi) > 0) then
      exit(ParseTable(Chiavi, AItemIndent));

    exit(ParseList(AItemIndent));
  end;

  if not SplitKey(CurrentText, Chiave, Coda) then
  begin
    Result := ToonScalar(CurrentText);
    inc(FIndex);
    exit;
  end;

  // Oggetto: la prima coppia sta sulla riga del trattino, le altre sono le
  // righe piu' rientrate che seguono
  Oggetto := TJSONObject.Create;
  ParsePair(Oggetto, AItemIndent);

  if (not Eof) and (CurrentIndent > AItemIndent) and (not CurrentText.StartsWith('- ')) then
  begin
    Figli := ParseObject(CurrentIndent);
    try

      while Figli.Count > 0 do
      begin
        Coppia := Figli.Pairs[0];
        Figli.RemovePair(Coppia.JsonString.Value);
        Oggetto.AddPair(Coppia);
      end;

    finally
      Figli.Free;
    end;
  end;

  Result := Oggetto;
end;

function TzToonReader.ParseList(const AIndent: Integer): TJSONArray;
var
  IndentVoce: Integer;
begin
  Result := TJSONArray.Create;

  while (not Eof) and (CurrentIndent > AIndent) do
  begin

    if not CurrentText.StartsWith('- ') then
    begin
      // riga inattesa dentro un elenco: si salta invece di perdere tutto
      inc(FIndex);
      Continue;
    end;

    IndentVoce := CurrentIndent;
    // si toglie il trattino: da qui in poi la riga e' una coppia normale
    ReplaceCurrentText(CurrentText.Substring(2).Trim);
    Result.AddElement(ParseListItem(IndentVoce));
  end;
end;

function TzToonReader.Parse: TJSONValue;
var
  Testa: string;
  IndentTesta: Integer;
  Chiavi: TArray<string>;
begin

  if Eof then
    exit(TJSONObject.Create);

  // radice che e' un elenco: la prima riga e' la sua intestazione
  if CurrentText.StartsWith('[') then
  begin
    Testa := CurrentText;
    IndentTesta := CurrentIndent;
    inc(FIndex);

    if ParseArrayHeader(Testa, Chiavi) and (Length(Chiavi) > 0) then
      exit(ParseTable(Chiavi, IndentTesta));

    exit(ParseList(IndentTesta));
  end;

  Result := ParseObject(CurrentIndent);
end;

class function TzToon.ToJsonValue(const AToon: string): TJSONValue;
var
  Reader: TzToonReader;
begin
  Reader := TzToonReader.Create(AToon);
  try
    Result := Reader.Parse;
  finally
    Reader.Free;
  end;
end;

class function TzToon.ToJsonString(const AToon: string; const AFormatIndent: Integer): string;
var
  Value: TJSONValue;
begin
  Value := ToJsonValue(AToon);
  try

    if AFormatIndent > 0 then
      Result := Value.Format(AFormatIndent)
    else
      Result := Value.ToJSON;

  finally
    Value.Free;
  end;
end;

end.
