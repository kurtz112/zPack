unit zMetadata.ScriptGenerator;

interface

uses
  System.SysUtils,
  System.Classes,
  zMetadata,
  zCollection;

const
  msgErrore = '@ERRORE!!!';
  msgNotNull = '@NOT NULL!!!';

type
  TScriptGenerator = record
    class function Sequence(generator: TzmdGenerator): string; static;
    class function Domain(Domain: TzmdDomain): string; static; static;

    // Table
    class function CreateTable(tbl: TzmdTable): string; static;
    class function CreateTableField(Field: TzmdTableField; skipNotNull: Boolean = false): string; static;

    class function CreatePrimaryKey(tbl: TzmdTable): string; static;
    class function CreateForeignKey(fk: TzmdForeignKey): string; static;
    class function CreateTableUnique(unique: TzmdUniqueConstraint): string; static;
    class function CreateTableCheck(check: TzmdCheckConstraint): string; static;
    class function CreateTableIndex(tableIndex: TzmdTableIndex): string; static;

    // Func
    class function CreateFunctionIntf(func: TzmdFunction; const UseDomains: Boolean = true): string; static;
    class function CreateFunctionImpl(func: TzmdFunction): string; static;

    // Proc
    class function CreateProcIntf(proc: TzmdProcedure; const UseDomains: Boolean = true): string; static;
    class function CreateProcImpl(proc: TzmdProcedure): string; static;

    // View
    class function CreateView(view: TzmdView): string; static;
    class function CreateTrigger(trigger: TzmdTrigger): string; static;

    // Package
    class function CreatePackage(package: TzmdPackage): string; static;
    // alter
    class function AlterDomainType(Domain: TzmdDomain): string; static;
    class function AlterDomainAddCheckConstraint(Domain: TzmdDomain): string; static;
    class function AlterDomainDropCheckConstraint(Domain: TzmdDomain): string; static;
    class function AlterTableFieldDefault(Fld: TzmdTableField): string; static;
    class function AlterTableFieldNotNull(Fld: TzmdTableField): string; static;
    class function AlterTableFieldType(Fld: TzmdTableField): string; static;

    // drop
    class function DropSequence(Sequence: TzmdGenerator): string; static;
    class function DropDomain(Domain: TzmdDomain): string; static;
    class function DropTable(tbl: TzmdTable): string; static;
    class function DropTableField(Fld: TzmdTableField): string; static;
    class function DropTableConstraint(constraint: TzmdTableConstraint): string; static;
    class function DropTablePrimatyKey(tbl: TzmdTable): string; static;
    class function DropTableIndex(tblIndex: TzmdTableIndex): string; static;
    class function DropView(view: TzmdView): string; static;
    class function DropProc(prc: TzmdProcedure): string; static;
    class function DropFunction(func: TzmdFunction): string; static;
    class function DropTrigger(trigger: TzmdTrigger): string; static;
    class function DropPackage(package: TzmdPackage): string; static;

    // Comment
    class function Comment(const objectType: string; item: TzMetadataItem): string; static;
    class function CommentView(view: TzmdView): string; static;
    class function CommentProc(proc: TzmdProcedure): string; static;
    class function CommentFunction(func: TzmdFunction): string; static;

    // Varie
    // class function Header(StatementKind: TStatementKind; ObjectKind: TObjectKind): string;
    class function SetTerm(const open: Boolean): string; static;

    // DML
    class function InitializeNotNull(const TableName: string; Fields: TStrings): string; static;
  end;

implementation

uses
  System.Math,
  System.StrUtils;

const
  Sep04 = '    ';

function getText(strings: TStrings): String;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to strings.Count - 1 do
  begin
    Result := Result + strings[i];
    if i < (strings.Count - 1) then
      Result := Result + strings.linebreak;
  end;
end;

procedure AddStrings(Src, Dest: TStrings; const Quote: Boolean = false; const Sep: string = '');

  procedure RemoveEmptyLines(strings: TStrings);
  begin
    // rimuove eventuali righe vuote in coda
    if strings.Count > 0 then
      while ((Trim(strings[strings.Count - 1]) = '') or (strings[strings.Count - 1] = #13#10)) do
        strings.Delete(strings.Count - 1);
  end;

var
  tmp: TStringList;
begin
  tmp := TStringList.Create;
  try

    tmp.Assign(Src);

    RemoveEmptyLines(tmp);

    if Quote then
      tmp.Text := AnsiQuotedStr(getText(tmp), #39);

    if Sep <> '' then
      tmp.Text := getText(tmp) + Sep;

    Dest.AddStrings(tmp);
  finally
    FreeAndNil(tmp);
  end;
end;

procedure AddParams(params: TzCollection<TzmdParam>; strings: TStrings; const UseDomains: Boolean = true);
var
  i: Integer;
  len: Integer;
  s: string;
  param: TzmdParam;
begin
  len := 0;
  for i := 0 to params.Count - 1 do
    len := System.Math.Max(len, Length(params[i].Name));

  for i := 0 to params.Count - 1 do
  begin
    param := params[i];

    s := Sep04 + param.Name + System.StrUtils.DupeString(' ', len - Length(param.Name));

    s := s + ' ' + param.ddl(UseDomains);

    if param.DefaultValue <> '' then
      s := s + ' ' + param.DefaultValue;

    if i < (params.Count - 1) then
      s := s + ','
    else
      s := s + ')';

    strings.Add(s);
  end;
end;

class function TScriptGenerator.Comment(const objectType: string; item: TzMetadataItem): string;
var
  strings: TStringList;
begin
  Result := '';

  strings := TStringList.Create;
  try
    if item is TzmdTableField then
      strings.Add('COMMENT ON ' + objectType + ' ' + TzmdTableField(item).Table.Name + '.' + item.Name + ' IS')
    else
      strings.Add('COMMENT ON ' + objectType + ' ' + item.Name + ' IS');
    AddStrings(item.Description, strings, true, ';');

    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateTable(tbl: TzmdTable): string;

var
  i, x: Integer;
  Fld: TzmdTableField;
  len: Integer;
  s: string;
  strings: TStringList;
begin
  Result := '';

  strings := TStringList.Create;
  try

    s := '';

    case tbl.TableType of
      TzmdTable.TTableType.ttPersistent:
        s := 'CREATE TABLE';
      TzmdTable.TTableType.ttPerConnection:
        s := 'CREATE GLOBAL TEMPORARY TABLE';
      TzmdTable.TTableType.ttPerSession:
        s := 'CREATE GLOBAL TEMPORARY TABLE';
    end;

    strings.Add(s + ' ' + tbl.Name + '(');

    len := 0;
    for i := 0 to tbl.Fields.Count - 1 do
      len := System.Math.Max(len, Length(tbl.Fields[i].Name));

    /// //////////////////////////////////////////////////

    for i := 0 to tbl.Fields.Count - 1 do
      if not tbl.Fields[i].Calculated then
      begin
        Fld := tbl.Fields[i];

        s := Fld.Name + ' ' + System.StrUtils.DupeString(' ', len - Length(Fld.Name));

        if Fld.HasDomain then
          s := s + Fld.Domain
        else
          s := s + Fld.FbDataType;

        if Fld.Identity then
        begin
          s := s + ' GENERATED BY DEFAULT AS IDENTITY'
        end
        else
        begin
          if Fld.DefaultFromField <> '' then
            s := s + ' ' + Fld.DefaultFromField;

          if Fld.NotNull then
            s := s + ' NOT NULL';
        end;

        for x := i + 1 to tbl.Fields.Count - 1 do
          if not tbl.Fields[x].Calculated then
          begin
            s := s + ',';
            Break;
          end;

        strings.Add(s);
      end;

    case tbl.TableType of
      TzmdTable.TTableType.ttPersistent:
        strings.Add(');');
      TzmdTable.TTableType.ttPerConnection:
        strings.Add(') ON COMMIT PRESERVE ROWS;');
      TzmdTable.TTableType.ttPerSession:
        strings.Add(') ON COMMIT DELETE ROWS;');
    end;

    for i := 0 to tbl.Fields.Count - 1 do
      if tbl.Fields[i].Calculated then
      begin
        Fld := tbl.Fields[i];

        s := 'ALTER TABLE ' + tbl.Name + ' ADD ' + Fld.Name;

        s := s + ' COMPUTED BY ' + Fld.CalculatedSource + ';';
        strings.Add(s);
      end;
    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateTableField(Field: TzmdTableField; skipNotNull: Boolean = false): string;
var
  s: string;
  strings: TStringList;
begin
  Result := '';

  strings := TStringList.Create;
  try

    s := 'ALTER TABLE ' + Field.Table.Name + ' ADD ' + Field.Name;

    if Field.Calculated then
    begin
      s := s + ' COMPUTED BY ' + Field.CalculatedSource + ';';
      strings.Add(s);
    end
    else
    begin

      if Field.HasDomain then
        s := s + ' ' + Field.Domain
      else
        s := s + ' ' + Field.FbDataType;

      if Field.Identity then
        s := s + ' GENERATED BY DEFAULT AS IDENTITY;'
      else
      begin
        if Field.DefaultFromField <> '' then
          s := s + ' ' + Field.DefaultFromField;

        if Field.NotNull and (not skipNotNull) then
        begin

          s := s + ' NOT NULL; -- @NOT NULL';

          if Field.DefaultFromField <> '' then
            s := s + ' ' + '[DefaultValue]';
        end // \not null
        else
          s := s + ';'; // campo nullable
      end;

      strings.Add(s);
    end; // \not computed by

    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreatePrimaryKey(tbl: TzmdTable): string;
begin
  Result := 'ALTER TABLE ' + tbl.Name + ' ADD CONSTRAINT ' + tbl.PrimaryKeyName + ' PRIMARY KEY (' + tbl.PrimaryKey.ItemNames + ');';
end;

class function TScriptGenerator.CreateForeignKey(fk: TzmdForeignKey): string;
begin;
  Result := 'ALTER TABLE ' + fk.Table.Name + ' ADD CONSTRAINT ' + fk.Name + ' FOREIGN KEY (' + fk.Fields.ItemNames + ') REFERENCES ' + fk.FkTable + ' (' + fk.FkFields.ItemNames + ')';

  IF (not fk.UpdateRule.IsEmpty) and (fk.UpdateRule <> 'RESTRICT') THEN
    Result := Result + ' ON UPDATE ' + fk.UpdateRule;

  IF (not fk.DeleteRule.IsEmpty) and (fk.DeleteRule <> 'RESTRICT') THEN
    Result := Result + ' ON DELETE ' + fk.DeleteRule;

  Result := Result + ';';
end;

class function TScriptGenerator.CreateTableUnique(unique: TzmdUniqueConstraint): string;
begin
  Result := 'ALTER TABLE ' + unique.Table.Name + ' ADD CONSTRAINT ' + unique.Name + ' UNIQUE (' + unique.UniqueFieldNames.ItemNames + ' )';

  if unique.IndexName <> '' then
    Result := Result + ' USING INDEX ' + unique.IndexName;

  Result := Result + ';';
end;

class function TScriptGenerator.CreateTableCheck(check: TzmdCheckConstraint): string;
begin
  Result := 'ALTER TABLE ' + check.Table.Name + ' ADD CONSTRAINT ' + check.Name + ' ' + check.CheckConstraint.Text + ';';
end;

class function TScriptGenerator.CreateTableIndex(tableIndex: TzmdTableIndex): string;
begin
  // CREATE INDEX AZIENDE_IDX1 ON AZIENDE(CAP)
  // CREATE DESCENDING INDEX AZIENDE_IDX1 ON AZIENDE(CAP)
  // CREATE UNIQUE DESCENDING INDEX AZIENDE_IDX1 ON AZIENDE(CAP)
  // CREATE INDEX AZIENDE_IDX1 ON AZIENDE COMPUTED BY(CAP || COMUNE)
  // CREATE UNIQUE INDEX AZIENDE_IDX1 ON AZIENDE COMPUTED BY(CAP || COMUNE)

  Result := 'CREATE';

  if tableIndex.unique then
    Result := Result + ' UNIQUE';

  if tableIndex.Descending then
    Result := Result + ' DESCENDING';

  Result := Result + ' INDEX ' + tableIndex.Name + ' ON ' + tableIndex.Table.Name;

  if tableIndex.IndexExpression <> '' then
    Result := Result + ' COMPUTED BY(' + tableIndex.IndexExpression + ')'
  else
    Result := Result + '(' + tableIndex.IndexFieldNames.ItemNames(', ') + ')';

  Result := Result + ';';
end;

class function TScriptGenerator.CreateFunctionIntf(func: TzmdFunction; const UseDomains: Boolean = true): string;
var
  s: string;
  i: Integer;
  strings: TStringList;
begin
  Result := '';

  strings := TStringList.Create;
  try
    s := 'CREATE OR ALTER FUNCTION ' + func.Name;
    if func.params.Count > 0 then
      s := s + ' (';
    strings.Add(s);

    if func.params.Count > 0 then
      AddParams(func.params, strings, UseDomains);

    if func.ReturnParam.HasDomain and UseDomains then
      s := 'RETURNS ' + func.ReturnParam.Domain
    else
      s := 'RETURNS ' + func.ReturnParam.FbDataType;

    strings.Add(s);
    strings.Add('AS');
    strings.Add('BEGIN');
    strings.Add(' RETURN NULL;');
    strings.Add('END');
    strings.Add('^');
    strings.Add('');

    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateFunctionImpl(func: TzmdFunction): string;
var
  s: string;
  i: Integer;
  strings: TStringList;
begin
  // CREATE OR ALTER FUNCTION INC (
  // I INTERO)
  // RETURNS INTERO
  // AS
  // BEGIN
  // RETURN :I + 1;
  // END
  Result := '';
  strings := TStringList.Create;
  try
    s := 'CREATE OR ALTER FUNCTION ' + func.Name;
    if func.params.Count > 0 then
      s := s + ' (';
    strings.Add(s);

    if func.params.Count > 0 then
      AddParams(func.params, strings);

    s := 'RETURNS ' + func.ReturnParam.ddl(true);
    strings.Add(s);

    s := 'AS';
    strings.Add(s);

    AddStrings(func.Source, strings);
    strings.Add('^');
    strings.Add('');
    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateTrigger(trigger: TzmdTrigger): string;
var
  s: string;
  strings: TStringList;
  tmp: string;

  procedure addToken(const Token: string; const ok: Boolean; var s: string);
  begin
    if ok then
    begin
      if s = '' then
        s := Token
      else
        s := s + ' OR ' + Token;
    end;
  end;

begin
  // CREATE OR ALTER TRIGGER ACC_DENUNCE_ICP_CHECK FOR ACC_DENUNCE_ICP
  // ACTIVE BEFORE INSERT OR UPDATE OR DELETE POSITION 0
  // AS
  // begin
  // EXECUTE PROCEDURE ACC_CHECK_STATO_ACCERTAMENTO(
  // NEW.ID_ACCERTAMENTO);
  // end
  Result := '';
  strings := TStringList.Create;
  try
    s := 'CREATE OR ALTER TRIGGER ' + trigger.Name;

    if not trigger.IsDbTrigger then
      s := s + ' FOR ' + trigger.TableName;

    strings.Add(s);
    //
    if trigger.Active then
      s := 'ACTIVE'
    else
      s := 'INACTIVE';

    s := s + ' ';

    if not trigger.IsDbTrigger then
    begin
      tmp := '';

      case trigger.TriggerKind of
        tkUnknown:
          begin
            raise exception.Create('Errore trigger ' + trigger.Name);
          end;
        tkBefore:
          begin
            s := s + ' BEFORE';
            addToken('INSERT', trigger.BeforeInsert, tmp);
            addToken('UPDATE', trigger.BeforeUpdate, tmp);
            addToken('DELETE', trigger.BeforeDelete, tmp);
          end;
        tkAfter:
          begin
            s := s + ' AFTER';
            addToken('INSERT', trigger.AfterInsert, tmp);
            addToken('UPDATE', trigger.AfterUpdate, tmp);
            addToken('DELETE', trigger.AfterDelete, tmp);
          end;
      end;

      s := s + ' ' + tmp;
    end
    else
      if trigger.OnConnect then
        s := 'ON CONNECT'
      else
        if trigger.OnDisconnect then
          s := 'ON DISCONNECT'
        else
          if trigger.OnTransactionStart then
            s := 'ON TRANSACTION START'
          else
            if trigger.OnTransactionCommit then
              s := 'ON TRANSACTION COMMIT'
            else
              if trigger.OnTransactionRollback then
                s := 'ON TRANSACTION ROLLBACK'
              else
                if trigger.BeforeAnyStatement then
                  s := 'BEFORE ANY DDL STATEMENT'
                else
                  if trigger.AfterAnyStatement then
                    s := 'AFTER ANY DDL STATEMENT';

    s := s + ' POSITION ' + IntToStr(trigger.Position);
    strings.Add(s);
    //
    AddStrings(trigger.Source, strings);
    strings.Add('^');
    strings.Add('');

    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateProcIntf(proc: TzmdProcedure; const UseDomains: Boolean = true): string;
var
  i: Integer;
  s: string;
  strings: TStringList;
begin
  Result := '';
  strings := TStringList.Create;
  try
    s := 'CREATE OR ALTER PROCEDURE ' + proc.Name;
    if proc.ParamsInput.Count > 0 then
      s := s + ' (';
    strings.Add(s);

    if proc.ParamsInput.Count > 0 then
      AddParams(proc.ParamsInput, strings, UseDomains);

    if proc.ParamsOutput.Count > 0 then
    begin
      strings.Add('RETURNS (');
      AddParams(proc.ParamsOutput, strings, UseDomains);
    end;

    //
    strings.Add('AS');
    strings.Add('BEGIN');

    if proc.ParamsOutput.Count = 0 then
      strings.Add('  EXIT;')
    else
      strings.Add('  SUSPEND;');
    strings.Add('END');

    strings.Add('^');
    strings.Add('');
    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateProcImpl(proc: TzmdProcedure): string;
var
  i: Integer;
  s: string;
  strings: TStringList;
begin
  // CREATE OR ALTER PROCEDURE INT_GET_BELFIORE_INTESTATARIO (
  // ID_INTESTATARIO ID)
  // RETURNS (
  // BELFIORE BELFIORE)
  // AS
  // BEGIN
  //
  // SELECT
  // INTESTATARI.BELFIORE
  // FROM
  // INTESTATARI
  // WHERE
  // INTESTATARI.ID_INTESTATARIO = :ID_INTESTATARIO
  // INTO
  // :BELFIORE;
  // END
  Result := '';
  strings := TStringList.Create;
  try

    s := 'CREATE OR ALTER PROCEDURE ' + proc.Name;
    if proc.ParamsInput.Count > 0 then
      s := s + ' (';
    strings.Add(s);

    if proc.ParamsInput.Count > 0 then
      AddParams(proc.ParamsInput, strings);

    if proc.ParamsOutput.Count > 0 then
    begin
      strings.Add('RETURNS (');
      AddParams(proc.ParamsOutput, strings);
    end;

    //
    strings.Add('AS');
    AddStrings(proc.Source, strings);
    strings.Add('^');
    strings.Add('');
    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CreateView(view: TzmdView): string;
var
  i: Integer;
  s: string;
  strings: TStringList;
begin
  // CREATE OR ALTER VIEW NEW_VIEW (
  // ID_AZIENDA,
  // AZIENDA)
  // AS
  // SELECT
  // AZIENDE.ID_AZIENDA,
  // AZIENDE.AZIENDA
  // FROM
  // AZIENDE;
  Result := '';
  strings := TStringList.Create;
  try

    s := 'CREATE OR ALTER VIEW ' + view.Name + ' (';
    strings.Add(s);

    for i := 0 to view.Fields.Count - 1 do
    begin
      s := Sep04 + view.Fields[i].Name;

      if i < (view.Fields.Count - 1) then
        s := s + ','
      else
        s := s + ')';

      strings.Add(s);
    end;

    //
    strings.Add('AS');
    AddStrings(view.Source, strings);
    strings.Add('^');
    strings.Add('');
    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.AlterTableFieldNotNull(Fld: TzmdTableField): string;
begin
  if Fld.NotNull then
    Result := 'ALTER TABLE ' + Fld.Table.Name + ' ALTER ' + Fld.Name + ' SET NOT NULL;'
  else
    Result := 'ALTER TABLE ' + Fld.Table.Name + ' ALTER ' + Fld.Name + ' DROP NOT NULL;';
end;

class function TScriptGenerator.AlterTableFieldDefault(Fld: TzmdTableField): string;
begin
  if Fld.DefaultFromField <> '' then
    Result := 'ALTER TABLE ' + Fld.Table.Name + ' ALTER COLUMN ' + Fld.Name + ' SET' + ' ' + Fld.DefaultFromField + ';'
  else
    Result := 'ALTER TABLE ' + Fld.Table.Name + ' ALTER COLUMN ' + Fld.Name + ' DROP DEFAULT;';
end;

class function TScriptGenerator.AlterTableFieldType(Fld: TzmdTableField): string;
begin
  if Fld.HasDomain then
    Result := 'ALTER TABLE ' + Fld.Table.Name + ' ALTER COLUMN ' + Fld.Name + ' TYPE ' + Fld.Domain + ';'
  else
    Result := 'ALTER TABLE ' + Fld.Table.Name + ' ALTER COLUMN ' + Fld.Name + ' TYPE ' + Fld.FbDataType + ';';

  Result := Result + ' -- @FIELD TYPE';

  if Fld.Identity then
    Result := Result + ' -- @IDENTITY';
end;

class function TScriptGenerator.DropSequence(Sequence: TzmdGenerator): string;
begin
  Result := 'DROP SEQUENCE ' + Sequence.Name + ';';
end;

class function TScriptGenerator.DropDomain(Domain: TzmdDomain): string;
begin
  Result := 'DROP DOMAIN ' + Domain.Name + ';';
end;

class function TScriptGenerator.DropFunction(func: TzmdFunction): string;
begin
  Result := 'DROP FUNCTION ' + func.Name + ';';
end;

class function TScriptGenerator.DropTable(tbl: TzmdTable): string;
begin
  Result := 'DROP TABLE ' + tbl.Name + ';';
end;

class function TScriptGenerator.DropTableField(Fld: TzmdTableField): string;
begin
  Result := 'ALTER TABLE ' + Fld.Table.Name + ' DROP ' + Fld.Name + ';';
end;

class function TScriptGenerator.DropTableConstraint(constraint: TzmdTableConstraint): string;
begin
  Result := 'ALTER TABLE ' + constraint.Table.Name + ' DROP CONSTRAINT ' + constraint.Name + ';';
end;

class function TScriptGenerator.DropTableIndex(tblIndex: TzmdTableIndex): string;
begin
  Result := 'DROP INDEX ' + tblIndex.Name + ';';
end;

class function TScriptGenerator.DropView(view: TzmdView): string;
begin
  Result := 'DROP VIEW ' + view.Name + ';';
end;

class function TScriptGenerator.DropProc(prc: TzmdProcedure): string;
begin
  Result := 'DROP PROCEDURE ' + prc.Name + ';';
end;

class function TScriptGenerator.DropTrigger(trigger: TzmdTrigger): string;
begin
  Result := 'DROP TRIGGER ' + trigger.Name + ';';
end;

class function TScriptGenerator.InitializeNotNull(const TableName: string; Fields: TStrings): string;
var
  i: Integer;
  s: string;
  strings: TStringList;
begin
  Result := '';

  strings := TStringList.Create;
  try

    strings.Add('-- ' + msgNotNull + ' DA DEFINIRE ');
    strings.Add('UPDATE ' + TableName);
    strings.Add('SET');

    for i := 0 to Fields.Count - 1 do
    begin
      s := ' ' + TableName + '.' + Fields[i];
      if i = Fields.Count - 1 then
        s := s + ';'
      else
        s := s + ',';

      strings.Add(s);
    end;

    strings.Add('COMMIT WORK;');
    strings.Add('-- \@NOT NULL');

    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

// class function TScriptGenerator.Header(StatementKind: TStatementKind; ObjectKind: TObjectKind): string;
// begin
// Result := '-- ';
//
// case StatementKind of
// skNone:
// ;
// skCreate:
// Result := Result + 'CREATE';
// skAlter:
// Result := Result + 'ALTER';
// skDrop:
// Result := Result + 'DROP';
// skComment:
// Result := Result + 'COMMENT';
// end;
//
// Result := Result + ' - ';
//
// case ObjectKind of
// okNone:
// ;
// okDomain:
// Result := Result + 'Domains';
// okFunctionIntf:
// Result := Result + 'Functions (interface)';
// okFunctionImpl:
// Result := Result + 'Functions (implementation)';
// okSequence:
// Result := Result + 'Sequences';
// okTable:
// Result := Result + 'Tables';
// okPrimaryKey:
// Result := Result + 'Constraints (PK)';
// okForeignKey:
// Result := Result + 'Constraints (FK)';
// okUnique:
// Result := Result + 'Constraints (Unique)';
// okCheck:
// Result := Result + 'Constraints (Check)';
// okIndex:
// Result := Result + 'Table Indexes';
// okView:
// Result := Result + 'Views';
// okProcedureIntf:
// Result := Result + 'Procedures (interface)';
// okProcedureImpl:
// Result := Result + 'Procedures (implementation)';
// okTrigger:
// Result := Result + 'Triggers';
// end;
// end;

class function TScriptGenerator.SetTerm(const open: Boolean): string;
begin
  if open then
    Result := 'SET TERM ^ ;'
  else
    Result := 'SET TERM ; ^';
end;

class function TScriptGenerator.AlterDomainDropCheckConstraint(Domain: TzmdDomain): string;
begin
  Result := 'ALTER DOMAIN ' + Domain.Name + ' DROP CONSTRAINT;';
end;

class function TScriptGenerator.AlterDomainType(Domain: TzmdDomain): string;
begin
  Result := 'ALTER DOMAIN ' + Domain.Name + ' TYPE ' + Domain.FbDataType + '; --@DOMAIN TYPE';
end;

class function TScriptGenerator.AlterDomainAddCheckConstraint(Domain: TzmdDomain): string;
begin
  Result := 'ALTER DOMAIN ' + Domain.Name + ' ADD ' + Domain.CheckConstraint + ';';
end;

class function TScriptGenerator.DropTablePrimatyKey(tbl: TzmdTable): string;
begin
  Result := 'ALTER TABLE ' + tbl.Name + ' DROP CONSTRAINT ' + tbl.PrimaryKeyName + ';';
end;

class function TScriptGenerator.CommentView(view: TzmdView): string;
var
  i: Integer;
  s: string;
  strings: TStringList;
begin
  Result := '';
  strings := TStringList.Create;
  try
    s := 'CREATE OR ALTER VIEW ' + view.Name + ' (';
    strings.Add(s);

    for i := 0 to view.Fields.Count - 1 do
    begin
      s := Sep04 + view.Fields[i].Name;

      if i < (view.Fields.Count - 1) then
        s := s + ','
      else
        s := s + ')';

      strings.Add(s);
    end;

    //
    strings.Add('AS');
    strings.Add('SELECT');

    for i := 0 to view.Fields.Count - 1 do
      if i < (view.Fields.Count - 1) then
        strings.Add('CAST(NULL AS ' + view.Fields[i].FbDataType + '),')
      else
        strings.Add('CAST(NULL AS ' + view.Fields[i].FbDataType + ')');

    strings.Add('FROM RDB$DATABASE');
    strings.Add('^');
    strings.Add('');
    Result := getText(strings);
  finally
    FreeAndNil(strings);
  end;
end;

class function TScriptGenerator.CommentProc(proc: TzmdProcedure): string;
begin
  Result := TScriptGenerator.CreateProcIntf(proc, false);
end;

class function TScriptGenerator.CommentFunction(func: TzmdFunction): string;
begin
  Result := TScriptGenerator.CreateFunctionIntf(func, false);
end;

class function TScriptGenerator.Sequence(generator: TzmdGenerator): string;
begin
  Result := 'CREATE SEQUENCE ' + generator.Name + ';';
end;

class function TScriptGenerator.Domain(Domain: TzmdDomain): string;
var
  tmp: TStringList;
begin
  Result := 'CREATE DOMAIN ' + Domain.Name + ' AS ' + Domain.FbDataType;

  if Domain.DefaultValue <> '' then
    Result := Result + ' ' + Domain.DefaultValue;

  if Domain.Required then
    Result := Result + ' NOT NULL';

  if Domain.CheckConstraint <> '' then
    Result := Result + ' ' + Domain.CheckConstraint;

  Result := Result + ';';
end;

class function TScriptGenerator.DropPackage(package: TzmdPackage): string;
begin
  Result := 'DROP PACKAGE ' + package.Name +';';
end;

class function TScriptGenerator.CreatePackage(package: TzmdPackage): string;
begin
  Result := 'CREATE OR ALTER PACKAGE ' + package.Name;
  Result := Result + sLineBreak + 'AS';
  Result := Result + sLineBreak + package.Header.Text.Trim;
  Result := Result + sLineBreak + '^';
  Result := Result + sLineBreak + '';

  Result := Result + sLineBreak + 'RECREATE PACKAGE BODY ' + package.Name;
  Result := Result + sLineBreak + 'AS';
  Result := Result + sLineBreak + package.Body.Text.Trim;
  Result := Result + sLineBreak + '^';
  Result := Result + sLineBreak + '';
end;

end.
