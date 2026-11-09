// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-29
// ---------------------------------------------------------------------------
unit zSql.SelectOrigins;

// Risoluzione dell'origine (TABELLA.COLONNA) delle colonne del risultato di una
// SELECT a partire dal solo testo della query.
//
// Serve da ripiego quando il descrittore restituito dal server non riporta la
// tabella di provenienza di una colonna: FireDAC in quel caso lascia vuoti
// OriginTabName e OriginColName, e tutto cio' che si appoggia a Field.Origin
// (filtri della griglia, ricerche, ordinamenti, dizionario dati) resta senza
// qualificatore.
//
// Il testo viene scomposto in token, cosi' che virgole e parentesi dentro le
// funzioni, i letterali fra apici e i commenti non confondano la lettura della
// lista campi e della clausola FROM. Gli identificatori non fra virgolette
// vengono riportati in maiuscolo, come fa il server, cosi' che l'origine
// ricavata dal testo coincida con quella che FireDAC restituisce quando c'e'.
//
// Forme riconosciute nella lista campi:
//   TABELLA.COLONNA           -> origine TABELLA.COLONNA
//   ALIAS.COLONNA             -> l'alias viene risolto sulla clausola FROM
//   TABELLA.COLONNA [AS] NOME -> il campo nel risultato si chiama NOME
//   COLONNA                   -> risolta solo se il FROM ha una sola sorgente
//   TABELLA.*                 -> le colonne non nominate esplicitamente si
//                                attribuiscono alla tabella dell'asterisco;
//                                con piu' asterischi occorre l'elenco delle
//                                colonne (TTableColumnsProvider)
//   *  con piu' sorgenti      -> le colonne di tutte le sorgenti nell'ordine
//                                del FROM, come le restituisce il server; serve
//                                l'elenco delle colonne, e si rinuncia davanti
//                                a tabelle derivate, procedure e alias
//   espressione [AS] NOME     -> nessuna origine
//
// Nella clausola FROM si riconoscono tabelle, procedure selezionabili con gli
// argomenti fra parentesi, tabelle derivate e gli alias, con o senza AS.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TSelectItemKind = (ikColumn, ikStar, ikExpression);

  TSelectItem = record
    Kind: TSelectItemKind;
    // Testo dell'espressione cosi' come scritto, senza l'alias
    Expression: string;
    // Alias esplicito ([AS] NOME), vuoto se assente
    Alias: string;
    // Per ikColumn e ikStar: qualificatore come scritto (tabella o alias), vuoto se assente
    Qualifier: string;
    // Per ikColumn: nome della colonna come scritto
    ColumnName: string;
    // Nome della colonna nel risultato: l'alias se c'e', altrimenti il nome della colonna
    function ResultName: string;
  end;

  TFromSource = record
    // Nome della tabella o della procedura; vuoto per una tabella derivata
    Name: string;
    // Alias, vuoto se assente
    Alias: string;
    IsProcedure: boolean;
    IsDerived: boolean;
    // Nome con cui la sorgente viene qualificata nel resto della query
    function Qualifier: string;
  end;

  // Riempie Columns con i nomi delle colonne di TableName; serve solo quando la
  // lista campi contiene asterischi su piu' di una sorgente, o un asterisco
  // senza qualificatore su un FROM con piu' sorgenti
  TTableColumnsProvider = reference to procedure(const TableName: string; Columns: TStrings);

  TSelectOriginResolver = class
  private
    type
      TTokenKind = (tkIdentifier, tkQuotedIdentifier, tkNumber, tkString, tkParameter, tkSymbol);

      TToken = record
        Kind: TTokenKind;
        Text: string;
        function IsKeyword(const Keyword: string): boolean;
        function IsSymbol(const Symbol: string): boolean;
        function IsName: boolean;
      end;

      TTokenList = TList<TToken>;
  private
    FItems: TArray<TSelectItem>;
    FSources: TArray<TFromSource>;
    FSelectList: string;
    FFromClause: string;
    FColumnsProvider: TTableColumnsProvider;
    FColumnsCache: TObjectDictionary<string, TStringList>;
    class function Tokenize(const SQL: string): TTokenList;
    class function TokensText(Tokens: TTokenList; FromIndex, ToIndex: integer): string;
    class function SkipGroup(Tokens: TTokenList; OpenIndex: integer): integer;
    procedure Parse(const SQL: string);
    procedure ParseSelectList(Tokens: TTokenList; FromIndex, ToIndex: integer);
    procedure ParseItem(Tokens: TTokenList; FromIndex, ToIndex: integer);
    procedure ParseFrom(Tokens: TTokenList; FromIndex, ToIndex: integer);
    function SingleSourceName: string;
    function TableOfUnqualifiedColumn(const ColumnName: string): string;
    function TableOfStar(const Item: TSelectItem): string;
    function OriginOfColumnItem(const Item: TSelectItem): string;
    function TableColumns(const TableName: string): TStringList;
    function StarHasColumn(const Item: TSelectItem; const ResultName: string; StarCount: integer): boolean;
    function BareStarOrigin(const ResultName: string; Occurrence: integer; var Found: integer; out Origin: string): boolean;
  public
    constructor Create(const SQL: string; ColumnsProvider: TTableColumnsProvider = nil);
    destructor Destroy; override;

    // Tabella reale dietro un qualificatore (alias o nome); il qualificatore stesso se non compare nel FROM
    function TableOfQualifier(const Qualifier: string): string;

    // Voce della lista campi che produce la colonna ResultName; Occurrence
    // distingue le colonne omonime (0 = prima occorrenza)
    function FindItem(const ResultName: string; Occurrence: integer; out Item: TSelectItem): boolean;

    // Origine 'TABELLA.COLONNA' della colonna ResultName del risultato, vuota
    // se non determinabile dal testo
    function OriginOf(const ResultName: string; Occurrence: integer = 0): string;

    property Items: TArray<TSelectItem> read FItems;
    property Sources: TArray<TFromSource> read FSources;
    property SelectList: string read FSelectList;
    property FromClause: string read FFromClause;
  end;

// Origine 'TABELLA.COLONNA' della colonna ResultName di SQL, vuota se non determinabile
function SelectColumnOrigin(const SQL, ResultName: string; Occurrence: integer = 0; ColumnsProvider: TTableColumnsProvider = nil): string;

implementation

uses
  System.Character,
  System.Generics.Defaults;

const
  // Parole che non possono essere un alias di colonna o di tabella
  ReservedWords: array [0 .. 56] of string = ('SELECT', 'FROM', 'WHERE', 'GROUP', 'HAVING', 'ORDER', 'BY', 'ROWS', 'UNION', 'PLAN', 'FETCH', 'OFFSET',
    'FOR', 'WITH', 'INTO', 'RETURNING', 'AS', 'ON', 'USING', 'INNER', 'LEFT', 'RIGHT', 'FULL', 'OUTER', 'CROSS', 'NATURAL', 'JOIN', 'LATERAL', 'AND',
    'OR', 'NOT', 'IS', 'NULL', 'LIKE', 'IN', 'BETWEEN', 'ESCAPE', 'COLLATE', 'DISTINCT', 'ALL', 'FIRST', 'SKIP', 'CASE', 'END',
    // letterali e valori di contesto: sono espressioni, non colonne
    'TRUE', 'FALSE', 'UNKNOWN', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURRENT_ROLE', 'CURRENT_CONNECTION',
    'CURRENT_TRANSACTION', 'LOCALTIME', 'LOCALTIMESTAMP', 'ROW_COUNT');

  // Parole che chiudono la clausola FROM
  FromTerminators: array [0 .. 10] of string = ('WHERE', 'GROUP', 'HAVING', 'ORDER', 'ROWS', 'UNION', 'PLAN', 'FETCH', 'OFFSET', 'FOR', 'INTO');

function IsReservedWord(const Word: string): boolean;
var
  Reserved: string;
begin
  for Reserved in ReservedWords do
    if SameText(Reserved, Word) then
      Exit(true);

  Result := false;
end;

function IsFromTerminator(const Word: string): boolean;
var
  Terminator: string;
begin
  for Terminator in FromTerminators do
    if SameText(Terminator, Word) then
      Exit(true);

  Result := false;
end;

function SelectColumnOrigin(const SQL, ResultName: string; Occurrence: integer; ColumnsProvider: TTableColumnsProvider): string;
var
  Resolver: TSelectOriginResolver;
begin
  Resolver := TSelectOriginResolver.Create(SQL, ColumnsProvider);
  try
    Result := Resolver.OriginOf(ResultName, Occurrence);
  finally
    Resolver.Free;
  end;
end;

{ TSelectItem }

function TSelectItem.ResultName: string;
begin
  if Alias <> '' then
    Result := Alias
  else
    if Kind = ikColumn then
      Result := ColumnName
    else
      Result := '';
end;

{ TFromSource }

function TFromSource.Qualifier: string;
begin
  if Alias <> '' then
    Result := Alias
  else
    Result := Name;
end;

{ TSelectOriginResolver.TToken }

function TSelectOriginResolver.TToken.IsKeyword(const Keyword: string): boolean;
begin
  Result := (Kind = tkIdentifier) and SameText(Text, Keyword);
end;

function TSelectOriginResolver.TToken.IsSymbol(const Symbol: string): boolean;
begin
  Result := (Kind = tkSymbol) and (Text = Symbol);
end;

// Identificatore utilizzabile come nome di tabella, colonna o alias
function TSelectOriginResolver.TToken.IsName: boolean;
begin
  Result := (Kind = tkQuotedIdentifier) or ((Kind = tkIdentifier) and not IsReservedWord(Text));
end;

{ TSelectOriginResolver }

constructor TSelectOriginResolver.Create(const SQL: string; ColumnsProvider: TTableColumnsProvider);
begin
  inherited Create;
  FColumnsProvider := ColumnsProvider;
  FColumnsCache := TObjectDictionary<string, TStringList>.Create([doOwnsValues], TIStringComparer.Ordinal);
  Parse(SQL);
end;

destructor TSelectOriginResolver.Destroy;
begin
  FreeAndNil(FColumnsCache);
  inherited;
end;

class function TSelectOriginResolver.Tokenize(const SQL: string): TTokenList;

  function IsNameChar(c: Char): boolean;
  begin
    Result := c.IsLetterOrDigit or (c = '_') or (c = '$');
  end;

  function IsNameStart(c: Char): boolean;
  begin
    Result := c.IsLetter or (c = '_');
  end;

var
  i, Start, Len: integer;
  Token: TToken;
  c: Char;
begin
  Result := TTokenList.Create;
  Len := Length(SQL);
  i := 1;

  while i <= Len do
  begin
    c := SQL[i];

    // spazi
    if c.IsWhiteSpace then
    begin
      Inc(i);
      Continue;
    end;

    // commento di riga
    if (c = '-') and (i < Len) and (SQL[i + 1] = '-') then
    begin
      while (i <= Len) and (SQL[i] <> #10) do
        Inc(i);
      Continue;
    end;

    // commento di blocco
    if (c = '/') and (i < Len) and (SQL[i + 1] = '*') then
    begin
      Inc(i, 2);
      while (i < Len) and not((SQL[i] = '*') and (SQL[i + 1] = '/')) do
        Inc(i);
      Inc(i, 2);
      Continue;
    end;

    // letterale fra apici, con l'apice raddoppiato come escape
    if c = '''' then
    begin
      Start := i;
      Inc(i);
      while i <= Len do
      begin
        if SQL[i] = '''' then
        begin
          if (i < Len) and (SQL[i + 1] = '''') then
            Inc(i, 2)
          else
            Break;
        end
        else
          Inc(i);
      end;
      Inc(i);
      Token.Kind := tkString;
      Token.Text := Copy(SQL, Start, i - Start);
      Result.Add(Token);
      Continue;
    end;

    // identificatore fra virgolette: il testo resta con le maiuscole originali
    if c = '"' then
    begin
      Start := i + 1;
      Inc(i);
      while (i <= Len) and (SQL[i] <> '"') do
        Inc(i);
      Token.Kind := tkQuotedIdentifier;
      Token.Text := Copy(SQL, Start, i - Start);
      Inc(i);
      Result.Add(Token);
      Continue;
    end;

    // numero
    if c.IsDigit then
    begin
      Start := i;
      while (i <= Len) and (SQL[i].IsDigit or (SQL[i] = '.')) do
        Inc(i);
      Token.Kind := tkNumber;
      Token.Text := Copy(SQL, Start, i - Start);
      Result.Add(Token);
      Continue;
    end;

    // identificatore o parola chiave: in maiuscolo, come fa il server
    if IsNameStart(c) then
    begin
      Start := i;
      while (i <= Len) and IsNameChar(SQL[i]) do
        Inc(i);
      Token.Kind := tkIdentifier;
      Token.Text := UpperCase(Copy(SQL, Start, i - Start));
      Result.Add(Token);
      Continue;
    end;

    // parametro (:NOME, :##NOME) o macro FireDAC (!NOME, &NOME)
    if ((c = ':') or (c = '!') or (c = '&')) and (i < Len) and (IsNameChar(SQL[i + 1]) or (SQL[i + 1] = '#')) then
    begin
      Start := i;
      Inc(i);
      while (i <= Len) and (IsNameChar(SQL[i]) or (SQL[i] = '#')) do
        Inc(i);
      Token.Kind := tkParameter;
      Token.Text := Copy(SQL, Start, i - Start);
      Result.Add(Token);
      Continue;
    end;

    // simboli a due caratteri
    if (i < Len) and (((c = '|') and (SQL[i + 1] = '|')) or ((c = '<') and (SQL[i + 1] = '=')) or ((c = '>') and (SQL[i + 1] = '=')) or
      ((c = '<') and (SQL[i + 1] = '>')) or ((c = '!') and (SQL[i + 1] = '=')) or ((c = '^') and (SQL[i + 1] = '=')) or ((c = '~') and (SQL[i + 1] = '='))) then
    begin
      Token.Kind := tkSymbol;
      Token.Text := Copy(SQL, i, 2);
      Result.Add(Token);
      Inc(i, 2);
      Continue;
    end;

    Token.Kind := tkSymbol;
    Token.Text := c;
    Result.Add(Token);
    Inc(i);
  end;
end;

// Indice della parentesi che chiude quella aperta in OpenIndex (o l'ultimo token se non chiusa)
class function TSelectOriginResolver.SkipGroup(Tokens: TTokenList; OpenIndex: integer): integer;
var
  Depth: integer;
begin
  Depth := 0;
  Result := OpenIndex;
  while Result < Tokens.Count do
  begin
    if Tokens[Result].IsSymbol('(') then
      Inc(Depth)
    else
      if Tokens[Result].IsSymbol(')') then
      begin
        Dec(Depth);
        if Depth = 0 then
          Exit;
      end;
    Inc(Result);
  end;
  Result := Tokens.Count - 1;
end;

// Ricompone il testo dei token fra due indici, con uno spazio fra i token
// tranne attorno al punto e alle parentesi
class function TSelectOriginResolver.TokensText(Tokens: TTokenList; FromIndex, ToIndex: integer): string;
var
  i: integer;
  Text: string;
  Previous: string;
begin
  Result := '';
  Previous := '';
  for i := FromIndex to ToIndex do
  begin
    if Tokens[i].Kind = tkQuotedIdentifier then
      Text := '"' + Tokens[i].Text + '"'
    else
      Text := Tokens[i].Text;

    if (Result <> '') and (Text <> '.') and (Text <> ')') and (Text <> ',') and (Previous <> '.') and (Previous <> '(') then
      Result := Result + ' ';

    Result := Result + Text;
    Previous := Text;
  end;
end;

procedure TSelectOriginResolver.Parse(const SQL: string);
var
  Tokens: TTokenList;
  i, Depth: integer;
  SelectIndex, ListStart, FromIndex, EndIndex: integer;
begin
  FItems := nil;
  FSources := nil;
  FSelectList := '';
  FFromClause := '';

  Tokens := Tokenize(SQL);
  try
    // la SELECT principale e' la prima a profondita' zero: le CTE di una WITH
    // e le sottoquery stanno tutte fra parentesi
    SelectIndex := -1;
    Depth := 0;
    for i := 0 to Tokens.Count - 1 do
    begin
      if Tokens[i].IsSymbol('(') then
        Inc(Depth)
      else
        if Tokens[i].IsSymbol(')') then
          Dec(Depth)
        else
          if (Depth = 0) and Tokens[i].IsKeyword('SELECT') then
          begin
            SelectIndex := i;
            Break;
          end;
    end;

    if SelectIndex = -1 then
      Exit;

    // FIRST n, SKIP n, DISTINCT, ALL
    ListStart := SelectIndex + 1;
    while ListStart < Tokens.Count do
    begin
      if Tokens[ListStart].IsKeyword('FIRST') or Tokens[ListStart].IsKeyword('SKIP') then
      begin
        Inc(ListStart);
        if (ListStart < Tokens.Count) and Tokens[ListStart].IsSymbol('(') then
          ListStart := SkipGroup(Tokens, ListStart) + 1
        else
          Inc(ListStart);
      end
      else
        if Tokens[ListStart].IsKeyword('DISTINCT') or Tokens[ListStart].IsKeyword('ALL') then
          Inc(ListStart)
        else
          Break;
    end;

    // lista campi fino alla FROM (o a un'altra clausola) a profondita' zero
    FromIndex := -1;
    Depth := 0;
    EndIndex := Tokens.Count - 1;
    i := ListStart;
    while i < Tokens.Count do
    begin
      if Tokens[i].IsSymbol('(') then
        Inc(Depth)
      else
        if Tokens[i].IsSymbol(')') then
          Dec(Depth)
        else
          if (Depth = 0) and (Tokens[i].Kind = tkIdentifier) and (Tokens[i].IsKeyword('FROM') or IsFromTerminator(Tokens[i].Text)) then
          begin
            if Tokens[i].IsKeyword('FROM') then
              FromIndex := i;
            EndIndex := i - 1;
            Break;
          end;
      Inc(i);
    end;

    if EndIndex >= ListStart then
    begin
      FSelectList := TokensText(Tokens, ListStart, EndIndex);
      ParseSelectList(Tokens, ListStart, EndIndex);
    end;

    if FromIndex <> -1 then
    begin
      // clausola FROM fino alla prima parola che la chiude, a profondita' zero
      i := FromIndex + 1;
      Depth := 0;
      EndIndex := Tokens.Count - 1;
      while i < Tokens.Count do
      begin
        if Tokens[i].IsSymbol('(') then
          Inc(Depth)
        else
          if Tokens[i].IsSymbol(')') then
            Dec(Depth)
          else
            if (Depth = 0) and (Tokens[i].Kind = tkIdentifier) and IsFromTerminator(Tokens[i].Text) then
            begin
              EndIndex := i - 1;
              Break;
            end;
        Inc(i);
      end;

      if EndIndex >= FromIndex + 1 then
      begin
        FFromClause := TokensText(Tokens, FromIndex + 1, EndIndex);
        ParseFrom(Tokens, FromIndex + 1, EndIndex);
      end;
    end;
  finally
    Tokens.Free;
  end;
end;

procedure TSelectOriginResolver.ParseSelectList(Tokens: TTokenList; FromIndex, ToIndex: integer);
var
  i, Depth, ItemStart: integer;
begin
  Depth := 0;
  ItemStart := FromIndex;
  for i := FromIndex to ToIndex do
  begin
    if Tokens[i].IsSymbol('(') then
      Inc(Depth)
    else
      if Tokens[i].IsSymbol(')') then
        Dec(Depth)
      else
        if (Depth = 0) and Tokens[i].IsSymbol(',') then
        begin
          ParseItem(Tokens, ItemStart, i - 1);
          ItemStart := i + 1;
        end;
  end;

  if ItemStart <= ToIndex then
    ParseItem(Tokens, ItemStart, ToIndex);
end;

procedure TSelectOriginResolver.ParseItem(Tokens: TTokenList; FromIndex, ToIndex: integer);
var
  Item: TSelectItem;
  Last: integer;
  Count: integer;
begin
  if ToIndex < FromIndex then
    Exit;

  Item := Default (TSelectItem);
  Last := ToIndex;

  // alias esplicito: ... AS NOME, oppure ... NOME dove NOME segue un operando
  // completo (identificatore, numero, letterale, parentesi chiusa, END di un CASE)
  if (Last - FromIndex >= 2) and Tokens[Last].IsName and Tokens[Last - 1].IsKeyword('AS') then
  begin
    Item.Alias := Tokens[Last].Text;
    Last := Last - 2;
  end
  else
    if (Last - FromIndex >= 1) and Tokens[Last].IsName and not Tokens[Last - 1].IsSymbol('.') and
      ((Tokens[Last - 1].Kind in [tkIdentifier, tkQuotedIdentifier, tkNumber, tkString, tkParameter]) or Tokens[Last - 1].IsSymbol(')') or Tokens[Last - 1].IsSymbol('*')) and
      not(Tokens[Last - 1].IsKeyword('COLLATE') or Tokens[Last - 1].IsKeyword('AS') or Tokens[Last - 1].IsKeyword('NOT') or Tokens[Last - 1].IsKeyword('IS')) then
    begin
      // "TABELLA.*" non ammette alias: il token prima e' l'asterisco preceduto dal punto
      if not(Tokens[Last - 1].IsSymbol('*') and (Last - 2 >= FromIndex) and Tokens[Last - 2].IsSymbol('.')) then
      begin
        Item.Alias := Tokens[Last].Text;
        Last := Last - 1;
      end;
    end;

  Item.Expression := TokensText(Tokens, FromIndex, Last);

  // "COLONNA COLLATE NOME" resta la colonna: la collazione non cambia la provenienza del valore
  if (Last - FromIndex >= 2) and Tokens[Last - 1].IsKeyword('COLLATE') and (Tokens[Last].Kind in [tkIdentifier, tkQuotedIdentifier]) then
    Last := Last - 2;

  Count := Last - FromIndex + 1;

  if (Count = 1) and Tokens[FromIndex].IsSymbol('*') then
  begin
    Item.Kind := ikStar;
  end
  else
    if (Count = 3) and Tokens[FromIndex].IsName and Tokens[FromIndex + 1].IsSymbol('.') and Tokens[FromIndex + 2].IsSymbol('*') then
    begin
      Item.Kind := ikStar;
      Item.Qualifier := Tokens[FromIndex].Text;
    end
    else
      if (Count = 1) and Tokens[FromIndex].IsName then
      begin
        Item.Kind := ikColumn;
        Item.ColumnName := Tokens[FromIndex].Text;
      end
      else
        if (Count = 3) and Tokens[FromIndex].IsName and Tokens[FromIndex + 1].IsSymbol('.') and Tokens[FromIndex + 2].IsName then
        begin
          Item.Kind := ikColumn;
          Item.Qualifier := Tokens[FromIndex].Text;
          Item.ColumnName := Tokens[FromIndex + 2].Text;
        end
        else
          Item.Kind := ikExpression;

  FItems := FItems + [Item];
end;

procedure TSelectOriginResolver.ParseFrom(Tokens: TTokenList; FromIndex, ToIndex: integer);
var
  i: integer;
  Source: TFromSource;
  ExpectSource: boolean;
begin
  i := FromIndex;
  ExpectSource := true;

  while i <= ToIndex do
  begin
    if ExpectSource then
    begin
      Source := Default (TFromSource);

      if Tokens[i].IsKeyword('LATERAL') then
      begin
        Inc(i);
        Continue;
      end;

      if Tokens[i].IsSymbol('(') then
      begin
        // tabella derivata
        Source.IsDerived := true;
        i := SkipGroup(Tokens, i) + 1;
      end
      else
        if Tokens[i].IsName then
        begin
          Source.Name := Tokens[i].Text;
          Inc(i);
          // nome qualificato (schema o pacchetto)
          while (i + 1 <= ToIndex) and Tokens[i].IsSymbol('.') and Tokens[i + 1].IsName do
          begin
            Source.Name := Source.Name + '.' + Tokens[i + 1].Text;
            Inc(i, 2);
          end;
          // procedura selezionabile con argomenti
          if (i <= ToIndex) and Tokens[i].IsSymbol('(') then
          begin
            Source.IsProcedure := true;
            i := SkipGroup(Tokens, i) + 1;
          end;
        end
        else
        begin
          // token inatteso: si prosegue senza registrare nulla
          Inc(i);
          Continue;
        end;

      // alias, con o senza AS
      if (i <= ToIndex) and Tokens[i].IsKeyword('AS') then
        Inc(i);
      if (i <= ToIndex) and Tokens[i].IsName then
      begin
        Source.Alias := Tokens[i].Text;
        Inc(i);
        // elenco colonne di una tabella derivata: ALIAS (A, B, C)
        if Source.IsDerived and (i <= ToIndex) and Tokens[i].IsSymbol('(') then
          i := SkipGroup(Tokens, i) + 1;
      end;

      FSources := FSources + [Source];
      ExpectSource := false;
    end
    else
    begin
      // fra una sorgente e la successiva: condizioni ON/USING e parole del JOIN,
      // fino alla virgola o al JOIN a profondita' zero
      if Tokens[i].IsSymbol('(') then
        i := SkipGroup(Tokens, i) + 1
      else
        if Tokens[i].IsSymbol(',') or Tokens[i].IsKeyword('JOIN') then
        begin
          ExpectSource := true;
          Inc(i);
        end
        else
          Inc(i);
    end;
  end;
end;

function TSelectOriginResolver.TableOfQualifier(const Qualifier: string): string;
var
  Source: TFromSource;
begin
  if Qualifier = '' then
    Exit('');

  for Source in FSources do
    if SameText(Source.Alias, Qualifier) then
      Exit(Source.Name);

  for Source in FSources do
    if (Source.Alias = '') and SameText(Source.Name, Qualifier) then
      Exit(Source.Name);

  // non compare nel FROM (o il FROM non e' stato letto): si prende per buono
  Result := Qualifier;
end;

// Nome dell'unica sorgente reale del FROM, vuoto se ce n'e' piu' d'una o nessuna
function TSelectOriginResolver.SingleSourceName: string;
var
  Source: TFromSource;
begin
  Result := '';
  if Length(FSources) <> 1 then
    Exit;

  Source := FSources[0];
  if not Source.IsDerived then
    Result := Source.Name;
end;

function TSelectOriginResolver.TableOfStar(const Item: TSelectItem): string;
begin
  if Item.Qualifier = '' then
    Result := SingleSourceName
  else
    Result := TableOfQualifier(Item.Qualifier);
end;

// Tabella che possiede la colonna non qualificata ColumnName: l'unica sorgente
// se il FROM ne ha una sola, altrimenti l'unica fra le sorgenti che la contiene
// secondo l'elenco delle colonne; vuota se indeterminabile o ambigua
function TSelectOriginResolver.TableOfUnqualifiedColumn(const ColumnName: string): string;
var
  Source: TFromSource;
  Columns: TStringList;
begin
  Result := SingleSourceName;
  if (Result <> '') or not Assigned(FColumnsProvider) then
    Exit;

  for Source in FSources do
    if not Source.IsDerived then
    begin
      Columns := TableColumns(Source.Name);
      if Assigned(Columns) and (Columns.IndexOf(ColumnName) <> -1) then
      begin
        if Result <> '' then
          Exit('');
        Result := Source.Name;
      end;
    end;
end;

function TSelectOriginResolver.OriginOfColumnItem(const Item: TSelectItem): string;
var
  Table: string;
begin
  Result := '';
  if Item.Kind <> ikColumn then
    Exit;

  if Item.Qualifier = '' then
    Table := TableOfUnqualifiedColumn(Item.ColumnName)
  else
    Table := TableOfQualifier(Item.Qualifier);

  if Table <> '' then
    Result := Table + '.' + Item.ColumnName;
end;

function TSelectOriginResolver.TableColumns(const TableName: string): TStringList;
begin
  Result := nil;
  if (TableName = '') or not Assigned(FColumnsProvider) then
    Exit;

  if not FColumnsCache.TryGetValue(TableName, Result) then
  begin
    Result := TStringList.Create;
    Result.CaseSensitive := false;
    try
      FColumnsProvider(TableName, Result);
    except
      // un errore del fornitore vale come elenco non disponibile
      Result.Clear;
    end;
    FColumnsCache.Add(TableName, Result);
  end;
end;

// Vero se la colonna ResultName arriva dall'asterisco Item. Con l'elenco delle
// colonne disponibile la risposta e' esatta; senza, si attribuisce all'asterisco
// solo quando e' l'unico della lista campi
function TSelectOriginResolver.StarHasColumn(const Item: TSelectItem; const ResultName: string; StarCount: integer): boolean;
var
  Table: string;
  Columns: TStringList;
begin
  Result := false;
  Table := TableOfStar(Item);
  if Table = '' then
    Exit;

  Columns := TableColumns(Table);
  if Assigned(Columns) and (Columns.Count > 0) then
    Result := Columns.IndexOf(ResultName) <> -1
  else
    Result := StarCount = 1;
end;

// Mantis #193 - 2026-09-29: asterisco senza qualificatore su un FROM con piu' sorgenti
// Il server espande l'asterisco nelle colonne di tutte le sorgenti, nell'ordine
// del FROM: le colonne omonime si contano sorgente per sorgente. True se
// l'occorrenza cercata cade in questo asterisco; Origin e' vuota quando la
// sorgente ha un alias, perche' l'origine si scrive col nome reale della
// tabella e la query conosce solo l'alias. False se l'occorrenza non cade qui
// (Found avanza delle omonime incontrate) oppure se le colonne di una sorgente
// non sono note: in quel caso Found resta com'era e l'asterisco non conta,
// esattamente come prima di questa correzione
function TSelectOriginResolver.BareStarOrigin(const ResultName: string; Occurrence: integer; var Found: integer; out Origin: string): boolean;
var
  Source: TFromSource;
  Columns: TStringList;
  Counted: integer;
begin
  Result := false;
  Origin := '';
  Counted := Found;

  for Source in FSources do
  begin
    Columns := nil;
    if not(Source.IsDerived or Source.IsProcedure) then
      Columns := TableColumns(Source.Name);

    // tabella derivata, procedura o elenco non disponibile: non si sa quante
    // colonne omonime porti la sorgente, e il conteggio non e' piu' affidabile
    if not Assigned(Columns) or (Columns.Count = 0) then
      Exit;

    if Columns.IndexOf(ResultName) <> -1 then
    begin
      if Counted = Occurrence then
      begin
        if (Source.Alias = '') or SameText(Source.Alias, Source.Name) then
          Origin := Source.Name + '.' + ResultName;
        Exit(true);
      end;
      Inc(Counted);
    end;
  end;

  Found := Counted;
end;

function TSelectOriginResolver.FindItem(const ResultName: string; Occurrence: integer; out Item: TSelectItem): boolean;
var
  Candidate: TSelectItem;
  Found: integer;
begin
  Result := false;
  Found := 0;
  for Candidate in FItems do
    if (Candidate.Kind <> ikStar) and SameText(Candidate.ResultName, ResultName) then
    begin
      if Found = Occurrence then
      begin
        Item := Candidate;
        Exit(true);
      end;
      Inc(Found);
    end;
end;

function TSelectOriginResolver.OriginOf(const ResultName: string; Occurrence: integer): string;
var
  Item: TSelectItem;
  Found, StarCount: integer;
  Table: string;
  Origin: string;
  ExactStars: boolean;
begin
  Result := '';
  if Trim(ResultName) = '' then
    Exit;

  StarCount := 0;
  for Item in FItems do
    if Item.Kind = ikStar then
      Inc(StarCount);

  // Con l'elenco delle colonne si scorre la lista nell'ordine reale del
  // risultato, asterischi compresi, e l'occorrenza e' esatta. Senza elenco le
  // colonne nominate hanno la precedenza e l'eventuale asterisco unico
  // raccoglie cio' che resta.
  ExactStars := Assigned(FColumnsProvider);

  if ExactStars then
  begin
    Found := 0;
    for Item in FItems do
      case Item.Kind of
        ikColumn, ikExpression:
          if SameText(Item.ResultName, ResultName) then
          begin
            if Found = Occurrence then
              Exit(OriginOfColumnItem(Item));
            Inc(Found);
          end;
        ikStar:
          if (Item.Qualifier = '') and (Length(FSources) > 1) then
          begin
            // Mantis #193 - 2026-09-29: asterisco nudo su piu' sorgenti
            if BareStarOrigin(ResultName, Occurrence, Found, Origin) then
              Exit(Origin);
          end
          else
            if StarHasColumn(Item, ResultName, StarCount) then
            begin
              if Found = Occurrence then
              begin
                Table := TableOfStar(Item);
                Exit(Table + '.' + ResultName);
              end;
              Inc(Found);
            end;
      end;
    Exit;
  end;

  Found := 0;
  for Item in FItems do
    if (Item.Kind <> ikStar) and SameText(Item.ResultName, ResultName) then
    begin
      if Found = Occurrence then
        Exit(OriginOfColumnItem(Item));
      Inc(Found);
    end;

  if Occurrence <> Found then
    Exit;

  for Item in FItems do
    if (Item.Kind = ikStar) and StarHasColumn(Item, ResultName, StarCount) then
    begin
      Table := TableOfStar(Item);
      Exit(Table + '.' + ResultName);
    end;
end;

end.
