unit SQLFormatter;

{
  FirebirdSQLFormatter.pas
  Formattatore SQL per Firebird 5

  Uso:
  var
  Formatted: string;
  begin
  Formatted := FormatFirebirdSQL('select a,b from t where x=1 and y=2');
  end;
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.Character;

type
  TSQLTokenType = (ttUnknown, ttKeyword, ttIdentifier, ttString, // 'testo' oppure Q'{testo}'
    ttLineComment, // -- commento
    ttBlockComment, // /* commento */
    ttNumber, ttOperator, ttDot, // '.'  separatore schema.oggetto — no spazi intorno
    ttParam, ttComma, ttOpenParen, ttCloseParen, ttSemicolon, ttWhitespace, ttEOF);

  TSQLToken = record
    TokenType: TSQLTokenType;
    Value: string;
  end;

  TFirebirdSQLFormatter = class
  private
    FSource: string;
    FPos: Integer;
    FLen: Integer;
    FIndentSize: Integer;
    FUppercase: Boolean;

    function CurrentChar: Char;
    function PeekChar(Offset: Integer = 1): Char;
    procedure Advance(Count: Integer = 1);
    function IsEOF: Boolean;

    function ReadToken: TSQLToken;
    function ReadString: TSQLToken;
    function ReadLineComment: TSQLToken;
    function ReadBlockComment: TSQLToken;
    function ReadNumber: TSQLToken;
    function ReadIdentifierOrKeyword: TSQLToken;
    function ReadOperator: TSQLToken;
    function ReadWhitespace: TSQLToken;

    function IsKeyword(const Word: string): Boolean;
    function IsNewlineKeyword(const Word: string): Boolean;
    function IsIndentKeyword(const Word: string): Boolean;
    function IsJoinKeyword(const Word: string): Boolean;
    function IsDedentKeyword(const Word: string): Boolean;

    function IndentStr(Level: Integer): string;

    function Tokenize: TArray<TSQLToken>;
    function MergeCompoundKeywords(const Tokens: TArray<TSQLToken>): TArray<TSQLToken>;
    function BuildOutput(const Tokens: TArray<TSQLToken>): string;
  public
    constructor Create;

    { IndentSize: numero di spazi per ogni livello (default 2) }
    property IndentSize: Integer read FIndentSize write FIndentSize;
    { UppercaseKeywords: converte le keyword in maiuscolo (default True) }
    property UppercaseKeywords: Boolean read FUppercase write FUppercase;

    function Format(const SQL: string): string;
  end;

  { Funzione di comodo }
function FormatFirebirdSQL(const SQL: string; IndentSize: Integer = 2; UppercaseKeywords: Boolean = True): string;

implementation

const
  // Keyword semplici
  KEYWORDS: array of string = ['SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'NOT', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE', 'JOIN', 'INNER', 'LEFT', 'RIGHT', 'FULL', 'OUTER', 'CROSS', 'ON', 'AS', 'DISTINCT', 'ALL', 'TOP', 'FIRST', 'SKIP',
    'UNION', 'INTERSECT', 'EXCEPT', 'GROUP', 'BY', 'ORDER', 'HAVING', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END', 'IN', 'EXISTS', 'BETWEEN', 'LIKE', 'IS', 'NULL', 'CREATE', 'ALTER', 'DROP', 'RECREATE', 'EXECUTE', 'TABLE', 'VIEW', 'TRIGGER', 'PROCEDURE',
    'FUNCTION', 'INDEX', 'SEQUENCE', 'GENERATOR', 'EXCEPTION', 'DOMAIN', 'PRIMARY', 'KEY', 'FOREIGN', 'REFERENCES', 'UNIQUE', 'CHECK', 'DEFAULT', 'NOT', 'NULL', 'CONSTRAINT', 'BEGIN', 'END', 'DECLARE', 'VARIABLE', 'BLOCK', 'FOR', 'DO', 'WHILE', 'IF',
    'THEN', 'ELSE', 'SUSPEND', 'EXIT', 'LEAVE', 'BREAK', 'RETURNS', 'RETURN', 'WITH', 'COMMIT', 'ROLLBACK', 'SAVEPOINT', 'RELEASE', 'GRANT', 'REVOKE', 'TO', 'OF', 'OPTION', 'CAST', 'EXTRACT', 'SUBSTRING', 'TRIM', 'UPPER', 'LOWER', 'COUNT', 'SUM',
    'AVG', 'MIN', 'MAX', 'COALESCE', 'IIF', 'NULLIF', 'INTEGER', 'BIGINT', 'SMALLINT', 'FLOAT', 'DOUBLE', 'PRECISION', 'NUMERIC', 'DECIMAL', 'CHAR', 'VARCHAR', 'NCHAR', 'NVARCHAR', 'BLOB', 'DATE', 'TIME', 'TIMESTAMP', 'BOOLEAN', 'TRUE', 'FALSE',
    'UNKNOWN', 'NATURAL', 'LATERAL', 'OVER', 'PARTITION', 'ROWS', 'RANGE', 'PRECEDING', 'FOLLOWING', 'UNBOUNDED', 'CURRENT', 'ROW', 'FILTER', 'WITHIN', 'GROUP', 'EXCLUDE', 'WINDOW', 'NEXT', 'VALUE', 'FOR', 'MERGE', 'USING', 'MATCHED', 'SOURCE',
    'TARGET', 'UPDATE', 'INSERT', 'DELETE', 'NOTHING'];

  // Keyword che causano newline + indent al proprio livello
  NEWLINE_KEYWORDS: array of string = ['SELECT', 'FROM', 'WHERE', 'HAVING', 'UNION', 'INTERSECT', 'EXCEPT', 'INSERT INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE FROM', 'MERGE INTO', 'USING', 'WHEN MATCHED', 'WHEN NOT MATCHED', 'DECLARE', 'BEGIN', 'END',
    'FOR', 'WHILE', 'IF', 'ELSE', 'EXECUTE BLOCK', 'CREATE OR ALTER', 'CREATE TABLE', 'ALTER TABLE', 'RECREATE TABLE', 'WITH'];

  // Keyword che causano newline al livello corrente (stessa profondità di SELECT)
  INDENT_KEYWORDS: array of string = ['AND', 'OR', 'INNER JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'FULL JOIN', 'FULL OUTER JOIN', 'LEFT OUTER JOIN', 'RIGHT OUTER JOIN', 'CROSS JOIN', 'NATURAL JOIN', 'JOIN', 'GROUP BY', 'ORDER BY', 'ON'];

  // Keyword che riducono l'indent (tipo END)
  DEDENT_KEYWORDS: array of string = ['END'];

  // ---------------------------------------------------------------------------

function FormatFirebirdSQL(const SQL: string; IndentSize: Integer; UppercaseKeywords: Boolean): string;
var
  Formatter: TFirebirdSQLFormatter;
begin
  Formatter := TFirebirdSQLFormatter.Create;
  try
    Formatter.IndentSize := IndentSize;
    Formatter.UppercaseKeywords := UppercaseKeywords;
    Result := Formatter.Format(SQL);
  finally
    Formatter.Free;
  end;
end;

// ---------------------------------------------------------------------------
{ TFirebirdSQLFormatter }
// ---------------------------------------------------------------------------

constructor TFirebirdSQLFormatter.Create;
begin
  inherited;
  FIndentSize := 2;
  FUppercase := True;
end;

function TFirebirdSQLFormatter.CurrentChar: Char;
begin
  if FPos <= FLen then
    Result := FSource[FPos]
  else
    Result := #0;
end;

function TFirebirdSQLFormatter.PeekChar(Offset: Integer): Char;
begin
  if FPos + Offset <= FLen then
    Result := FSource[FPos + Offset]
  else
    Result := #0;
end;

procedure TFirebirdSQLFormatter.Advance(Count: Integer);
begin
  Inc(FPos, Count);
end;

function TFirebirdSQLFormatter.IsEOF: Boolean;
begin
  Result := FPos > FLen;
end;

// ---------------------------------------------------------------------------

function TFirebirdSQLFormatter.ReadToken: TSQLToken;
var
  Ch: Char;
begin
  if IsEOF then
  begin
    Result.TokenType := ttEOF;
    Result.Value := '';
    Exit;
  end;

  Ch := CurrentChar;

  // Whitespace
  if Ch.IsWhiteSpace then
    Exit(ReadWhitespace);

  // Commento di riga  --
  if (Ch = '-') and (PeekChar = '-') then
    Exit(ReadLineComment);

  // Commento blocco  /* ... */
  if (Ch = '/') and (PeekChar = '*') then
    Exit(ReadBlockComment);

  // Stringa  'xxx'  oppure  Q'{xxx}'  oppure  Q'(xxx)'
  if Ch = '''' then
    Exit(ReadString);

  if (Ch = 'Q') or (Ch = 'q') then
    if PeekChar = '''' then
      Exit(ReadString);

  // Numero
  if Ch.IsDigit or ((Ch = '.') and PeekChar(1).IsDigit) then
    Exit(ReadNumber);

  // Identificatore o keyword (include parole con lettere/cifre/_)
  if Ch.IsLetter or (Ch = '_') or (Ch = '"') then
    Exit(ReadIdentifierOrKeyword);

  // Punto (separatore schema.oggetto)
  if Ch = '.' then
  begin
    // Distingui dal punto decimale: se il char precedente era cifra
    // e il successivo è cifra, è un numero (già gestito da ReadNumber).
    // Qui siamo nel caso  schema.funzione  oppure  schema.tabella.
    Result.TokenType := ttDot;
    Result.Value := '.';
    Advance;
    Exit;
  end;

  // Virgola
  if Ch = ',' then
  begin
    Result.TokenType := ttComma;
    Result.Value := ',';
    Advance;
    Exit;
  end;

  // Parentesi aperta
  if Ch = '(' then
  begin
    Result.TokenType := ttOpenParen;
    Result.Value := '(';
    Advance;
    Exit;
  end;

  // Parentesi chiusa
  if Ch = ')' then
  begin
    Result.TokenType := ttCloseParen;
    Result.Value := ')';
    Advance;
    Exit;
  end;

  // Punto e virgola
  if Ch = ';' then
  begin
    Result.TokenType := ttSemicolon;
    Result.Value := ';';
    Advance;
    Exit;
  end;

  // Parametro named Firebird  :NOME
  if (Ch = ':') and PeekChar.IsLetter then
  begin
    Result.TokenType := ttParam;
    Advance; // consuma ':'
    // riusa ReadIdentifierOrKeyword per leggere il nome
    var
    NameToken := ReadIdentifierOrKeyword;
    Result.Value := ':' + NameToken.Value;
    Exit;
  end;

  // Operatori e tutto il resto
  Result := ReadOperator;
end;

function TFirebirdSQLFormatter.ReadWhitespace: TSQLToken;
var
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    while not IsEOF and CurrentChar.IsWhiteSpace do
    begin
      SB.Append(CurrentChar);
      Advance;
    end;
    Result.TokenType := ttWhitespace;
    Result.Value := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TFirebirdSQLFormatter.ReadLineComment: TSQLToken;
var
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    while not IsEOF and (CurrentChar <> #10) do
    begin
      SB.Append(CurrentChar);
      Advance;
    end;
    // Consuma il newline
    if not IsEOF then
    begin
      SB.Append(CurrentChar);
      Advance;
    end;
    Result.TokenType := ttLineComment;
    Result.Value := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TFirebirdSQLFormatter.ReadBlockComment: TSQLToken;
var
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    // Consuma  /*
    SB.Append(CurrentChar);
    Advance;
    SB.Append(CurrentChar);
    Advance;
    while not IsEOF do
    begin
      if (CurrentChar = '*') and (PeekChar = '/') then
      begin
        SB.Append(CurrentChar);
        Advance;
        SB.Append(CurrentChar);
        Advance;
        Break;
      end;
      SB.Append(CurrentChar);
      Advance;
    end;
    Result.TokenType := ttBlockComment;
    Result.Value := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TFirebirdSQLFormatter.ReadString: TSQLToken;
var
  SB: TStringBuilder;
  QClose: Char;
  IsQString: Boolean;
begin
  SB := TStringBuilder.Create;
  IsQString := False;
  QClose := #0;
  try
    // Q'{ ... }'  oppure  Q'( ... )'
    if (CurrentChar = 'Q') or (CurrentChar = 'q') then
    begin
      IsQString := True;
      SB.Append(CurrentChar);
      Advance; // Q
      SB.Append(CurrentChar);
      Advance; // '
      // Il delimitatore di apertura
      case CurrentChar of
        '{':
          QClose := '}';
        '(':
          QClose := ')';
        '[':
          QClose := ']';
        '<':
          QClose := '>';
      else
        QClose := CurrentChar;
      end;
      SB.Append(CurrentChar);
      Advance;
      while not IsEOF do
      begin
        if (CurrentChar = QClose) and (PeekChar = '''') then
        begin
          SB.Append(CurrentChar);
          Advance;
          SB.Append(CurrentChar);
          Advance;
          Break;
        end;
        SB.Append(CurrentChar);
        Advance;
      end;
    end
    else
    begin
      // Stringa standard 'xxx', con escape ''
      SB.Append(CurrentChar);
      Advance; // apre '
      while not IsEOF do
      begin
        if CurrentChar = '''' then
        begin
          SB.Append(CurrentChar);
          Advance;
          if (not IsEOF) and (CurrentChar = '''') then
          begin
            // Doppio apice = apice letterale
            SB.Append(CurrentChar);
            Advance;
          end
          else
            Break; // Chiude la stringa
        end
        else
        begin
          SB.Append(CurrentChar);
          Advance;
        end;
      end;
    end;

    Result.TokenType := ttString;
    Result.Value := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TFirebirdSQLFormatter.ReadNumber: TSQLToken;
var
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    while not IsEOF and (CurrentChar.IsDigit or (CurrentChar = '.') or (CurrentChar = 'e') or (CurrentChar = 'E') or ((CurrentChar = '+') and ((PeekChar(-1) = 'e') or (PeekChar(-1) = 'E'))) or
      ((CurrentChar = '-') and ((PeekChar(-1) = 'e') or (PeekChar(-1) = 'E')))) do
    begin
      SB.Append(CurrentChar);
      Advance;
    end;
    Result.TokenType := ttNumber;
    Result.Value := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TFirebirdSQLFormatter.ReadIdentifierOrKeyword: TSQLToken;
var
  SB: TStringBuilder;
  Upper: string;
begin
  SB := TStringBuilder.Create;
  try
    // Identificatore quotato  "nome"
    if CurrentChar = '"' then
    begin
      SB.Append(CurrentChar);
      Advance;
      while not IsEOF and (CurrentChar <> '"') do
      begin
        SB.Append(CurrentChar);
        Advance;
      end;
      if not IsEOF then
      begin
        SB.Append(CurrentChar);
        Advance;
      end;
      Result.TokenType := ttIdentifier;
      Result.Value := SB.ToString;
      Exit;
    end;

    // Identificatore normale
    while not IsEOF and (CurrentChar.IsLetterOrDigit or (CurrentChar = '_') or (CurrentChar = '$')) do
    begin
      SB.Append(CurrentChar);
      Advance;
    end;

    Upper := SB.ToString.ToUpper;
    if IsKeyword(Upper) then
    begin
      Result.TokenType := ttKeyword;
      if FUppercase then
        Result.Value := Upper
      else
        Result.Value := SB.ToString;
    end
    else
    begin
      Result.TokenType := ttIdentifier;
      Result.Value := SB.ToString;
    end;
  finally
    SB.Free;
  end;
end;

function TFirebirdSQLFormatter.ReadOperator: TSQLToken;
var
  SB: TStringBuilder;
  Ch: Char;
begin
  SB := TStringBuilder.Create;
  try
    Ch := CurrentChar;
    SB.Append(Ch);
    Advance;

    // Operatori a due caratteri: <>, <=, >=, !=, ||, :=, ~=, ^=, !<, !>
    if not IsEOF then
    begin
      case Ch of
        '<':
          if (CurrentChar = '>') or (CurrentChar = '=') then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
        '>':
          if CurrentChar = '=' then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
        '!':
          if (CurrentChar = '=') or (CurrentChar = '<') or (CurrentChar = '>') then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
        '~':
          if CurrentChar = '=' then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
        '^':
          if CurrentChar = '=' then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
        '|':
          if CurrentChar = '|' then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
        ':':
          if CurrentChar = '=' then
          begin
            SB.Append(CurrentChar);
            Advance;
          end;
      end;
    end;

    Result.TokenType := ttOperator;
    Result.Value := SB.ToString;
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------

function TFirebirdSQLFormatter.IsKeyword(const Word: string): Boolean;
var
  KW: string;
begin
  for KW in KEYWORDS do
    if KW = Word then
      Exit(True);
  Result := False;
end;

function TFirebirdSQLFormatter.IsNewlineKeyword(const Word: string): Boolean;
var
  KW: string;
begin
  for KW in NEWLINE_KEYWORDS do
    if KW = Word then
      Exit(True);
  Result := False;
end;

function TFirebirdSQLFormatter.IsIndentKeyword(const Word: string): Boolean;
var
  KW: string;
begin
  for KW in INDENT_KEYWORDS do
    if KW = Word then
      Exit(True);
  Result := False;
end;

function TFirebirdSQLFormatter.IsDedentKeyword(const Word: string): Boolean;
var
  KW: string;
begin
  for KW in DEDENT_KEYWORDS do
    if KW = Word then
      Exit(True);
  Result := False;
end;

function TFirebirdSQLFormatter.IsJoinKeyword(const Word: string): Boolean;
begin
  Result := Word.EndsWith('JOIN');
end;

// ---------------------------------------------------------------------------

function TFirebirdSQLFormatter.IndentStr(Level: Integer): string;
begin
  Result := StringOfChar(' ', Level * FIndentSize);
end;

// ---------------------------------------------------------------------------

function TFirebirdSQLFormatter.Tokenize: TArray<TSQLToken>;
var
  List: TList<TSQLToken>;
  Token: TSQLToken;
begin
  List := TList<TSQLToken>.Create;
  try
    while not IsEOF do
    begin
      Token := ReadToken;
      // Scarta i whitespace; li rigeneriamo noi durante il formatting
      if Token.TokenType <> ttWhitespace then
        List.Add(Token);
    end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

function TFirebirdSQLFormatter.MergeCompoundKeywords(const Tokens: TArray<TSQLToken>): TArray<TSQLToken>;
{
  Unisce coppie/triple di keyword in keyword composte, es:
  GROUP + BY  -> "GROUP BY"
  ORDER + BY  -> "ORDER BY"
  LEFT + JOIN -> "LEFT JOIN"   etc.
  INSERT + INTO -> "INSERT INTO"
  DELETE + FROM -> "DELETE FROM"
  EXECUTE + BLOCK -> "EXECUTE BLOCK"
  CREATE + OR + ALTER -> "CREATE OR ALTER"
  NOT + NULL  -> "NOT NULL"
  IS + NOT    -> "IS NOT"  (seguito eventualmente da NULL)
}
var
  List: TList<TSQLToken>;
  I: Integer;
  V, V1, V2: string;
  T: TSQLToken;
begin
  List := TList<TSQLToken>.Create;
  try
    I := 0;
    while I <= High(Tokens) do
    begin
      if Tokens[I].TokenType <> ttKeyword then
      begin
        List.Add(Tokens[I]);
        Inc(I);
        Continue;
      end;

      V := Tokens[I].Value.ToUpper;

      // Prova a guardare avanti
      V1 := '';
      V2 := '';
      if (I + 1 <= High(Tokens)) and (Tokens[I + 1].TokenType = ttKeyword) then
        V1 := Tokens[I + 1].Value.ToUpper;
      if (I + 2 <= High(Tokens)) and (Tokens[I + 2].TokenType = ttKeyword) then
        V2 := Tokens[I + 2].Value.ToUpper;

      // Triple: CREATE OR ALTER
      if (V = 'CREATE') and (V1 = 'OR') and (V2 = 'ALTER') then
      begin
        T.TokenType := ttKeyword;
        if FUppercase then
          T.Value := 'CREATE OR ALTER'
        else
          T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value + ' ' + Tokens[I + 2].Value;
        List.Add(T);
        Inc(I, 3);
        Continue;
      end;

      // Triple: IS NOT NULL  — mantieni IS NOT come coppia
      if (V = 'IS') and (V1 = 'NOT') then
      begin
        T.TokenType := ttKeyword;
        if FUppercase then
          T.Value := 'IS NOT'
        else
          T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
        List.Add(T);
        Inc(I, 2);
        Continue;
      end;

      // Coppie
      if V1 <> '' then
      begin
        // GROUP BY / ORDER BY / PARTITION BY
        if ((V = 'GROUP') or (V = 'ORDER') or (V = 'PARTITION')) and (V1 = 'BY') then
        begin
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := V + ' BY'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // JOIN qualificato: INNER, LEFT, RIGHT, FULL, CROSS, NATURAL, LATERAL
        if (V1 = 'JOIN') and ((V = 'INNER') or (V = 'LEFT') or (V = 'RIGHT') or (V = 'FULL') or (V = 'CROSS') or (V = 'NATURAL') or (V = 'LATERAL')) then
        begin
          // Potrebbe essere LEFT OUTER JOIN (tripla)
          if (V2 = 'JOIN') and (V1 = 'OUTER') then
          begin
            T.TokenType := ttKeyword;
            if FUppercase then
              T.Value := V + ' OUTER JOIN'
            else
              T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value + ' ' + Tokens[I + 2].Value;
            List.Add(T);
            Inc(I, 3);
            Continue;
          end;
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := V + ' JOIN'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // INSERT INTO
        if (V = 'INSERT') and (V1 = 'INTO') then
        begin
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := 'INSERT INTO'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // DELETE FROM
        if (V = 'DELETE') and (V1 = 'FROM') then
        begin
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := 'DELETE FROM'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // EXECUTE BLOCK
        if (V = 'EXECUTE') and (V1 = 'BLOCK') then
        begin
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := 'EXECUTE BLOCK'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // MERGE INTO
        if (V = 'MERGE') and (V1 = 'INTO') then
        begin
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := 'MERGE INTO'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // NOT NULL
        if (V = 'NOT') and (V1 = 'NULL') then
        begin
          T.TokenType := ttKeyword;
          if FUppercase then
            T.Value := 'NOT NULL'
          else
            T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
          List.Add(T);
          Inc(I, 2);
          Continue;
        end;

        // WHEN MATCHED  /  WHEN NOT MATCHED
        if (V = 'WHEN') then
        begin
          if (V1 = 'MATCHED') then
          begin
            T.TokenType := ttKeyword;
            if FUppercase then
              T.Value := 'WHEN MATCHED'
            else
              T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value;
            List.Add(T);
            Inc(I, 2);
            Continue;
          end;
          if (V1 = 'NOT') and (V2 = 'MATCHED') then
          begin
            T.TokenType := ttKeyword;
            if FUppercase then
              T.Value := 'WHEN NOT MATCHED'
            else
              T.Value := Tokens[I].Value + ' ' + Tokens[I + 1].Value + ' ' + Tokens[I + 2].Value;
            List.Add(T);
            Inc(I, 3);
            Continue;
          end;
        end;
      end;

      // Nessuna fusione
      List.Add(Tokens[I]);
      Inc(I);
    end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

// ---------------------------------------------------------------------------

function TFirebirdSQLFormatter.BuildOutput(const Tokens: TArray<TSQLToken>): string;
var
  SB: TStringBuilder;
  I: Integer;
  IndentLevel: Integer;
  SubQueryDepth: Integer; // profondità delle subquery (parentesi dopo keyword)
  NewLine: Boolean;
  Token: TSQLToken;
  Upper: string;
  LastMeaningful: TSQLTokenType;
  PrevWasComma: Boolean;
  InSelectList: Boolean;
  SelectDepth: Integer;
  PrevType: TSQLTokenType; // tipo del token immediatamente precedente

  procedure EmitNewLine;
  begin
    SB.AppendLine;
    NewLine := True;
  end;

  procedure EmitIndent(Level: Integer);
  begin
    if NewLine then
    begin
      SB.Append(IndentStr(Level));
      NewLine := False;
    end;
  end;

  procedure EmitSpace;
  begin
    if not NewLine then
      SB.Append(' ');
  end;

begin
  SB := TStringBuilder.Create;
  IndentLevel := 0;
  SubQueryDepth := 0;
  NewLine := True;
  PrevWasComma := False;
  InSelectList := False;
  SelectDepth := 0;
  LastMeaningful := ttUnknown;
  PrevType := ttUnknown;

  try
    I := 0;
    while I <= High(Tokens) do
    begin
      Token := Tokens[I];
      Upper := Token.Value.ToUpper;

      case Token.TokenType of

        ttKeyword:
          begin
            if IsNewlineKeyword(Upper) then
            begin
              if not NewLine then
                EmitNewLine;
              EmitIndent(IndentLevel);
              SB.Append(Token.Value);
              NewLine := False;

              if (Upper = 'BEGIN') then
                Inc(IndentLevel)
              else
                if (Upper = 'SELECT') then
                begin
                  InSelectList := True;
                  SelectDepth := SubQueryDepth;
                end
                else
                  if (Upper = 'FROM') or (Upper = 'WHERE') or (Upper = 'HAVING') then
                    InSelectList := False;
            end
            else
              if IsIndentKeyword(Upper) then
              begin
                if not NewLine then
                  EmitNewLine;
                EmitIndent(IndentLevel);
                SB.Append(Token.Value);
                NewLine := False;
              end
              else
                if IsDedentKeyword(Upper) then
                begin
                  if IndentLevel > 0 then
                    Dec(IndentLevel);
                  if not NewLine then
                    EmitNewLine;
                  EmitIndent(IndentLevel);
                  SB.Append(Token.Value);
                  NewLine := False;
                end
                else
                begin
                  EmitSpace;
                  SB.Append(Token.Value);
                end;
            LastMeaningful := ttKeyword;
            PrevWasComma := False;
            PrevType := ttKeyword;
          end;

        ttIdentifier, ttNumber, ttString:
          begin
            if PrevType = ttDot then
              // Dopo un punto (schema.oggetto): nessuno spazio
              { noop }
            else
              if PrevWasComma then
              begin
                // Dopo la virgola: newline se siamo nella SELECT list, altrimenti spazio
                if InSelectList and (SubQueryDepth = SelectDepth) then
                begin
                  EmitNewLine;
                  EmitIndent(IndentLevel + 1);
                end
                else
                  EmitSpace;
              end
              else
                EmitSpace;
            SB.Append(Token.Value);
            LastMeaningful := Token.TokenType;
            PrevWasComma := False;
            PrevType := Token.TokenType;
          end;

        ttParam:
          begin
            // Nessuno spazio dopo '(' in chiamata funzione
            if PrevType = ttOpenParen then
              { noop }
            else
              if PrevWasComma then
                EmitSpace
              else
                EmitSpace;
            SB.Append(Token.Value);
            LastMeaningful := ttIdentifier;
            PrevWasComma := False;
            PrevType := ttIdentifier;
          end;

        ttDot:
          begin
            // Nessuno spazio né prima né dopo: schema.oggetto
            SB.Append('.');
            PrevWasComma := False;
            LastMeaningful := ttOperator;
            PrevType := ttDot;
          end;

        ttComma:
          begin
            SB.Append(',');
            PrevWasComma := True;
            LastMeaningful := ttComma;
            PrevType := ttComma;
          end;

        ttOpenParen:
          begin
            Inc(SubQueryDepth);
            // Chiamata di funzione: no spazio se il token precedente è identifier o ')'
            if not(PrevType in [ttIdentifier, ttCloseParen]) then
              EmitSpace;
            SB.Append('(');
            // Se la prossima keyword è SELECT → subquery: vai a capo e aumenta indent
            if (I + 1 <= High(Tokens)) and (Tokens[I + 1].TokenType = ttKeyword) and (Tokens[I + 1].Value.ToUpper = 'SELECT') then
            begin
              Inc(IndentLevel);
              EmitNewLine;
            end;
            PrevWasComma := False;
            LastMeaningful := ttOpenParen;
            PrevType := ttOpenParen;
          end;

        ttCloseParen:
          begin
            Dec(SubQueryDepth);
            // Se eravamo in una subquery → riduci indent e vai a capo prima di ')'
            if (I > 0) and (SubQueryDepth < IndentLevel) and (IndentLevel > 0) then
            begin
              Dec(IndentLevel);
              EmitNewLine;
              EmitIndent(IndentLevel);
            end;
            SB.Append(')');
            PrevWasComma := False;
            LastMeaningful := ttCloseParen;
            PrevType := ttCloseParen;
          end;

        ttOperator:
          begin
            // '*' usato come SELECT * → trattalo come elemento della select list
            if (Token.Value = '*') and InSelectList and (SubQueryDepth = SelectDepth) then
            begin
              if PrevWasComma then
              begin
                EmitNewLine;
                EmitIndent(IndentLevel + 1);
              end
              else
                if LastMeaningful = ttKeyword then
                begin
                  // Prima colonna subito dopo SELECT
                  EmitNewLine;
                  EmitIndent(IndentLevel + 1);
                end
                else
                  EmitSpace;
            end
            else
              if PrevType = ttDot then
                { noop — es. schema.* }
              else
                EmitSpace;
            SB.Append(Token.Value);
            PrevWasComma := False;
            LastMeaningful := ttOperator;
            PrevType := ttOperator;
          end;

        ttSemicolon:
          begin
            SB.Append(';');
            EmitNewLine;
            IndentLevel := 0;
            SubQueryDepth := 0;
            InSelectList := False;
            PrevWasComma := False;
            LastMeaningful := ttSemicolon;
          end;

        ttLineComment:
          begin
            EmitSpace;
            SB.Append(TrimRight(Token.Value));
            EmitNewLine;
            EmitIndent(IndentLevel);
            PrevWasComma := False;
          end;

        ttBlockComment:
          begin
            EmitSpace;
            SB.Append(Token.Value);
            PrevWasComma := False;
          end;

      end; // case

      Inc(I);
    end; // while

    Result := Trim(SB.ToString);
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------

function TFirebirdSQLFormatter.Format(const SQL: string): string;
var
  Tokens: TArray<TSQLToken>;
  Merged: TArray<TSQLToken>;
begin
  FSource := SQL;
  FPos := 1;
  FLen := Length(SQL);

  Tokens := Tokenize;
  Merged := MergeCompoundKeywords(Tokens);
  Result := BuildOutput(Merged);
end;

end.
