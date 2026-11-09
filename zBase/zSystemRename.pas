unit zSystemRename;

{
  zSqlRename
  ----------
  Motore di rinomina massiva di un nome di CAMPO o TABELLA negli script SQL
  dei dataset (SQL_Select/Insert/Update/Delete/Refresh) e delle stored proc.

  PRINCIPI (concordati):
  - Scope SOLO SQL: nessun metadato (TableName, FieldNamesFK, ...) viene toccato.
  - Match per CONFINI DI PAROLA: 'IMPORTO' non matcha dentro 'IMPORTO_LORDO'.
  - Opzione case-sensitive (per identificatori Firebird quotati).
  - CAMPO in due modalità:
      rmFieldGlobal    -> ogni \bNOME\b
      rmFieldQualified -> solo \bPREFISSO.NOME\b dove il prefisso (tabella/alias)
                          è ESPLICITO nel testo. I campi 'nudi' (senza prefisso)
                          NON vengono toccati: vengono elencati come ambigui.
  - TABELLA: ogni \bNOME\b (un nome-tabella è di norma univoco).
  - Esecuzione in due tempi: Preview() raccoglie le occorrenze SENZA modificare;
    Apply() applica solo le occorrenze confermate. La persistenza (SaveZip) e il
    backup (BackupZip) sono responsabilità del chiamante.

  Nessuna dipendenza dalla UI.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.RegularExpressions,
  zCollection,
  zSystem;

type
  TzRenameMode = (rmTable, rmFieldGlobal, rmFieldQualified);

  // dove si trova un'occorrenza, per l'anteprima e per l'applicazione
  TzRenameScriptKind = (rskSelect, rskInsert, rskUpdate, rskDelete, rskRefresh,
    rskStoredProc);

  TzRenameOccurrence = record
    ObjectName: string;            // nome dataset / storedproc
    Item: TzCollectionItem;        // per navigazione UI
    ScriptKind: TzRenameScriptKind;
    LineNo: Integer;               // 1-based, dentro lo script
    LineBefore: string;            // riga originale
    LinePreview: string;           // riga come sarebbe dopo il rename
    HitCount: Integer;             // occorrenze su questa riga
    Ambiguous: Boolean;            // campo nudo non toccato (solo qualified)
  end;

  TzRenameOccurrences = TList<TzRenameOccurrence>;

  TzSqlRenameEngine = class
  private
    FzSystem: TzSystem;
    FMode: TzRenameMode;
    FOldName: string;
    FNewName: string;
    FQualifier: string;            // tabella/alias per rmFieldQualified
    FCaseSensitive: Boolean;
    FRegex: TRegEx;                // match "vero" (con prefisso per qualified)
    FBareRegex: TRegEx;           // match dei campi nudi (per segnalarli)
    FUseBareDetection: Boolean;

    function BuildOptions: TRegExOptions;
    procedure BuildRegex;
    function ReplaceInLine(const Line: string; out HitCount: Integer): string;
    function CountBare(const Line: string): Integer;

    // scorre uno script, accodando le occorrenze trovate
    procedure ScanScript(const ObjectName: string; Item: TzCollectionItem;
      Kind: TzRenameScriptKind; const SQL: string;
      Occurrences: TzRenameOccurrences);

    // applica il rename su uno script e restituisce il nuovo testo
    function ApplyToScript(const SQL: string): string;
  public
    constructor Create(azSystem: TzSystem);

    // Configura l'operazione. Per rmFieldQualified passare Qualifier (tabella/alias).
    procedure Configure(Mode: TzRenameMode; const OldName, NewName: string;
      CaseSensitive: Boolean; const Qualifier: string = '');

    // Raccoglie tutte le occorrenze SENZA modificare nulla.
    function Preview: TzRenameOccurrences;

    // Applica il rename a tutti gli script. Restituisce il numero di script
    // modificati. NON persiste: il chiamante chiama SaveZip dopo.
    // Le collezioni effettivamente toccate sono riportate in TouchedCollections.
    function Apply(out TouchedDataSets, TouchedStoredProcs: Boolean): Integer;

    function Describe: string;     // riepilogo testuale dell'operazione

    property Mode: TzRenameMode read FMode;
    property OldName: string read FOldName;
    property NewName: string read FNewName;
  end;

function RenameModeName(M: TzRenameMode): string;
function ScriptKindToStr(K: TzRenameScriptKind): string;

implementation

function ScriptKindToStr(K: TzRenameScriptKind): string;
begin
  case K of
    rskSelect: Result := 'SQL_Select';
    rskInsert: Result := 'SQL_Insert';
    rskUpdate: Result := 'SQL_Update';
    rskDelete: Result := 'SQL_Delete';
    rskRefresh: Result := 'SQL_Refresh';
    rskStoredProc: Result := 'StoredProc';
  else
    Result := '?';
  end;
end;

function RenameModeName(M: TzRenameMode): string;
begin
  case M of
    rmTable: Result := 'Tabella';
    rmFieldGlobal: Result := 'Campo (globale)';
    rmFieldQualified: Result := 'Campo (qualificato)';
  else
    Result := '?';
  end;
end;

{ TzSqlRenameEngine }

constructor TzSqlRenameEngine.Create(azSystem: TzSystem);
begin
  inherited Create;
  FzSystem := azSystem;
  FCaseSensitive := False;
end;

procedure TzSqlRenameEngine.Configure(Mode: TzRenameMode;
  const OldName, NewName: string; CaseSensitive: Boolean;
  const Qualifier: string);
begin
  FMode := Mode;
  FOldName := Trim(OldName);
  FNewName := Trim(NewName);
  FQualifier := Trim(Qualifier);
  FCaseSensitive := CaseSensitive;
  BuildRegex;
end;

function TzSqlRenameEngine.BuildOptions: TRegExOptions;
begin
  Result := [];
  if not FCaseSensitive then
    Result := [roIgnoreCase];
end;

procedure TzSqlRenameEngine.BuildRegex;
var
  pattern, bare: string;
begin
  FUseBareDetection := False;

  case FMode of
    rmTable, rmFieldGlobal:
      // \bNOME\b — confini di parola attorno al nome
      pattern := '\b' + TRegEx.Escape(FOldName) + '\b';

    rmFieldQualified:
      begin
        // \bPREFISSO\.NOME\b — il prefisso (tabella o alias) deve essere
        // esplicito. Se Qualifier è vuoto, non possiamo qualificare: trattiamo
        // come "qualunque prefisso seguito da .NOME".
        if FQualifier <> '' then
          pattern := '\b' + TRegEx.Escape(FQualifier) + '\.' +
            TRegEx.Escape(FOldName) + '\b'
        else
          pattern := '\b[A-Za-z_][A-Za-z0-9_]*\.' +
            TRegEx.Escape(FOldName) + '\b';

        // campi nudi: \bNOME\b NON preceduto da '.' — per segnalarli come ambigui
        bare := '(?<![\.\w])' + TRegEx.Escape(FOldName) + '\b';
        FBareRegex := TRegEx.Create(bare, BuildOptions);
        FUseBareDetection := True;
      end;
  end;

  FRegex := TRegEx.Create(pattern, BuildOptions);
end;

// Sostituisce nel testo scorrendo i match manualmente (niente MatchEvaluator,
// che richiederebbe un metodo 'of object' e non potrebbe contare gli hit).
// Per qualified conserva il prefisso e cambia solo la parte dopo il punto.
function TzSqlRenameEngine.ReplaceInLine(const Line: string;
  out HitCount: Integer): string;
var
  m: TMatch;
  lastPos: Integer;       // 1-based: prossimo carattere non ancora copiato
  dot: Integer;
  prefix, repl: string;
begin
  HitCount := 0;
  Result := '';
  lastPos := 1;

  m := FRegex.Match(Line);
  while m.Success do
  begin
    // copia il tratto invariato prima del match
    Result := Result + Copy(Line, lastPos, m.Index - lastPos);

    if FMode = rmFieldQualified then
    begin
      dot := LastDelimiter('.', m.Value);
      prefix := Copy(m.Value, 1, dot);   // include il '.'
      repl := prefix + FNewName;
    end
    else
      repl := FNewName;

    Result := Result + repl;
    Inc(HitCount);

    lastPos := m.Index + m.Length;       // dopo il match originale
    m := m.NextMatch;
  end;

  // coda dopo l'ultimo match
  Result := Result + Copy(Line, lastPos, MaxInt);
end;

function TzSqlRenameEngine.CountBare(const Line: string): Integer;
var
  m: TMatch;
begin
  Result := 0;
  if not FUseBareDetection then
    Exit;
  m := FBareRegex.Match(Line);
  while m.Success do
  begin
    Inc(Result);
    m := m.NextMatch;
  end;
end;

procedure TzSqlRenameEngine.ScanScript(const ObjectName: string;
  Item: TzCollectionItem; Kind: TzRenameScriptKind; const SQL: string;
  Occurrences: TzRenameOccurrences);
var
  Lines: TStringList;
  i, hits, bareHits: Integer;
  newLine: string;
  occ: TzRenameOccurrence;
begin
  if Trim(SQL) = '' then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := SQL;
    for i := 0 to Lines.Count - 1 do
    begin
      newLine := ReplaceInLine(Lines[i], hits);
      bareHits := CountBare(Lines[i]);

      if (hits = 0) and (bareHits = 0) then
        Continue;

      // riga con match reali
      if hits > 0 then
      begin
        occ := Default(TzRenameOccurrence);
        occ.ObjectName := ObjectName;
        occ.Item := Item;
        occ.ScriptKind := Kind;
        occ.LineNo := i + 1;
        occ.LineBefore := Lines[i];
        occ.LinePreview := newLine;
        occ.HitCount := hits;
        occ.Ambiguous := False;
        Occurrences.Add(occ);
      end;

      // riga con campi nudi ambigui (solo qualified): segnalata, non toccata
      if bareHits > 0 then
      begin
        occ := Default(TzRenameOccurrence);
        occ.ObjectName := ObjectName;
        occ.Item := Item;
        occ.ScriptKind := Kind;
        occ.LineNo := i + 1;
        occ.LineBefore := Lines[i];
        occ.LinePreview := Lines[i];  // invariata
        occ.HitCount := bareHits;
        occ.Ambiguous := True;
        Occurrences.Add(occ);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

function TzSqlRenameEngine.Preview: TzRenameOccurrences;
var
  i: Integer;
  ds: TzDataSet;
  sp: TzStoredProc;
begin
  Result := TzRenameOccurrences.Create;

  if (FOldName = '') or (FNewName = '') then
    Exit;

  for i := 0 to FzSystem.zDataSets.Count - 1 do
  begin
    ds := FzSystem.zDataSets[i];
    ScanScript(ds.Name, ds, rskSelect, ds.SQL_Select.Text, Result);
    ScanScript(ds.Name, ds, rskInsert, ds.SQL_Insert.Text, Result);
    ScanScript(ds.Name, ds, rskUpdate, ds.SQL_Update.Text, Result);
    ScanScript(ds.Name, ds, rskDelete, ds.SQL_Delete.Text, Result);
    ScanScript(ds.Name, ds, rskRefresh, ds.SQL_Refresh.Text, Result);
  end;

  for i := 0 to FzSystem.zStoredProcs.Count - 1 do
  begin
    sp := FzSystem.zStoredProcs[i];
    ScanScript(sp.Name, sp, rskStoredProc, sp.SQL.Text, Result);
  end;
end;

function TzSqlRenameEngine.ApplyToScript(const SQL: string): string;
var
  Lines: TStringList;
  i, hits: Integer;
begin
  if Trim(SQL) = '' then
    Exit(SQL);

  Lines := TStringList.Create;
  try
    Lines.Text := SQL;
    for i := 0 to Lines.Count - 1 do
      Lines[i] := ReplaceInLine(Lines[i], hits);  // i nudi non vengono toccati
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function TzSqlRenameEngine.Apply(out TouchedDataSets,
  TouchedStoredProcs: Boolean): Integer;
var
  i: Integer;
  ds: TzDataSet;
  sp: TzStoredProc;
  before, after: string;

  procedure DoOne(const Old: string; Setter: TProc<string>; var anyTouched: Boolean);
  begin
    after := ApplyToScript(Old);
    if after <> Old then
    begin
      Setter(after);
      anyTouched := True;
      Inc(Result);
    end;
  end;

begin
  Result := 0;
  TouchedDataSets := False;
  TouchedStoredProcs := False;

  if (FOldName = '') or (FNewName = '') then
    Exit;

  for i := 0 to FzSystem.zDataSets.Count - 1 do
  begin
    ds := FzSystem.zDataSets[i];
    DoOne(ds.SQL_Select.Text,  procedure(s: string) begin ds.SQL_Select.Text := s; end,  TouchedDataSets);
    DoOne(ds.SQL_Insert.Text,  procedure(s: string) begin ds.SQL_Insert.Text := s; end,  TouchedDataSets);
    DoOne(ds.SQL_Update.Text,  procedure(s: string) begin ds.SQL_Update.Text := s; end,  TouchedDataSets);
    DoOne(ds.SQL_Delete.Text,  procedure(s: string) begin ds.SQL_Delete.Text := s; end,  TouchedDataSets);
    DoOne(ds.SQL_Refresh.Text, procedure(s: string) begin ds.SQL_Refresh.Text := s; end, TouchedDataSets);
  end;

  for i := 0 to FzSystem.zStoredProcs.Count - 1 do
  begin
    sp := FzSystem.zStoredProcs[i];
    before := sp.SQL.Text;
    after := ApplyToScript(before);
    if after <> before then
    begin
      sp.SQL.Text := after;
      TouchedStoredProcs := True;
      Inc(Result);
    end;
  end;
end;

function TzSqlRenameEngine.Describe: string;
begin
  case FMode of
    rmTable:
      Result := Format('Rinomina TABELLA "%s" -> "%s" negli SQL',
        [FOldName, FNewName]);
    rmFieldGlobal:
      Result := Format('Rinomina CAMPO (globale) "%s" -> "%s" negli SQL',
        [FOldName, FNewName]);
    rmFieldQualified:
      Result := Format('Rinomina CAMPO "%s.%s" -> "%s.%s" negli SQL ' +
        '(campi nudi non toccati)',
        [FQualifier, FOldName, FQualifier, FNewName]);
  end;
  if FCaseSensitive then
    Result := Result + ' [case-sensitive]';
end;

end.
