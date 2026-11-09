unit zExceptions.fib;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.IBCli;

function TranslateFIBError(E: EIBNativeException): string;

// Catena "At procedure 'X' line: N" del messaggio di Firebird riscritta in italiano, una riga per
// livello ("procedura X, riga N" + "chiamata da: ..."); stringa vuota se il messaggio non la contiene.
// Esposta per i test di zPackTests (R-136): e' la stessa funzione usata dai messaggi di troncamento.
function EstraiPercorsoChiamate(const Messaggio: string): string;

implementation

uses
  System.RegularExpressions,
  zSystem;

type
  TFBErrorParser = class
  public
    class function RemoveStartingLineBreak(const s: String): string;
    class function RemoveAtTriggerProcFunc(const s: String): string;
  public
    class function ExtractFkValue(const Value: string): string;
    class function GetConstraintName(const ExceptionMsg: string): string;
    class function GetExceptionMessage(E: EIBNativeException): string;
    class function GetTokenError(E: EIBNativeException): string;
    class function GetTransactionNumber(E: EIBNativeException): integer;
  public
    class function Translate_CheckConstraint(E: EIBNativeException): string;
    class function Translate_DeadLock(E: EIBNativeException): string;
    class function Translate_Exception(E: EIBNativeException): string;
    class function Translate_ForeignKey(E: EIBNativeException): string;
    class function Translate_NotPermission(E: EIBNativeException): string;
    class function Translate_Token_Unknow(E: EIBNativeException): string;
    class function Translate_UniqueViolation(E: EIBNativeException): string;
    class function Translate_ValidationErrorForColumn(E: EIBNativeException): string;
    class function Translate_StringTruncation(E: EIBNativeException): string;
    class function Translate_Generic(E: EIBNativeException): string;
  private
    class function ExtractStringTruncationInfo(E: EIBNativeException; out TruncationType, ExpectedLen, ActualLen: string): boolean; static;
    class function ExtractCallPath(const Messaggio: string): string; static;
    class function BuildStringTruncationMessage(E: EIBNativeException; const TruncType, ExpLen, ActLen: string): string;
  end;

  /// ////////////////////////////////////////////////

class function TFBErrorParser.RemoveStartingLineBreak(const s: String): string;
begin
  result := s;

  if result.StartsWith(sLineBreak) then
    result := result.Replace(sLineBreak, '', []);
end;

class function TFBErrorParser.RemoveAtTriggerProcFunc(const s: String): string;

  function min(idx, idxNew: integer): integer;
  begin

    if idx <= 0 then
      result := idxNew
    else
      if idxNew <= 0 then
        result := idx
      else
        if idx < idxNew then
          result := idx
        else
          result := idxNew;
  end;

var
  idx: integer;
begin
  // toglie la parte successiva al testo dell'eccezione: 'at proedure', 'at trigger' etc
  result := s;

  idx := 0;
  idx := min(idx, result.ToLower.IndexOf('at procedure'));
  idx := min(idx, result.ToLower.IndexOf('at trigger'));
  idx := min(idx, result.ToLower.IndexOf('at function'));

  if (idx > 0) then
    result := result.Substring(0, idx);
end;

/// ////////////////////////////////////////////////

class function TFBErrorParser.ExtractFkValue(const Value: string): string;
const
  substr = 'Problematic key value is';
var
  idx: integer;
begin
  result := '';

  idx := AnsiPos(substr, Value);
  if idx > 0 then
    result := Value.Substring(idx + substr.length).Trim;
end;

/// ////////////////////////////////////////////////

class function TFBErrorParser.GetConstraintName(const ExceptionMsg: string): string;
var
  c: Char;
  Lexem: string;
  InConstrName: Boolean;
begin
  Lexem := '';
  InConstrName := false;

  for c in ExceptionMsg do
    case c of
      ' ', #13, #10:
        begin
          if SameText(Lexem, 'constraint') or SameText(Lexem, 'index') then
          begin
            InConstrName := True;
            Lexem := '';
          end
          else
            if not InConstrName then
              Lexem := ''
            else
              Break
        end;
    else
      if c <> '"' then
        Lexem := Lexem + c;
    end;

  if not Lexem.IsEmpty then
    if Lexem.EndsWith('.') then
      Lexem := Lexem.Substring(0, Lexem.length - 1);

  result := Lexem;
end;

/// ////////////////////////////////////////////////
class function TFBErrorParser.GetExceptionMessage(E: EIBNativeException): string;
var
  idx: integer;
begin
  //
  result := E.Message; // FDAC IBMessage;

  result := AdjustLineBreaks(result);

  /// ////////////////////////////////////////////////////////
  // toglie sino all'ultima "exception". Lo spazio è per evitare che becchi la funzioneDOC_RAISE_EXCEPTION
  idx := result.ToLower.LastIndexOf('exception ');

  if idx > 0 then
    result := result.Substring(idx + 10);

  /// ////////////////////////////////////////////////////////

  result := RemoveAtTriggerProcFunc(result);

  /// ////////////////////////////////////////////////////////
  /// exception 1
  if result.StartsWith('1') then
    result := result.Replace('1', '', []);

  result := RemoveStartingLineBreak(result);
  /// ////////////////////////////////////////////////////////
  /// exception E
  if result.StartsWith('E') then
    result := result.Replace('E', '', []);

  /// ////////////////////////////////////////////////////////
  /// validation error for column "ZZ_REGISTRI_IVA"."TIPO_IVA", value "*** null ***"'

  if result.Contains('validation error for column "') then
  begin
    result := result.Replace('validation error for column "', 'Valore non valido per il campo ');
    result := result.Replace('"."', '.'); // la parte centrale: ZZ_REGISTRI_IVA"."TIPO_IVA
    result := result.Replace('", value ', ', valore ');
  end;

  /// ////////////////////////////////////////////////////////
  /// [FireDAC][Phys][FB]

  result := result.Replace('[FireDAC]', '');
  result := result.Replace('[Phys]', '');
  result := result.Replace('[FB]', '');

  /// ////////////////////////////////////////////////////////
  result := RemoveStartingLineBreak(result);
  /// ////////////////////////////////////////////////////////
end;

/// ////////////////////////////////////////////////

class function TFBErrorParser.GetTransactionNumber(E: EIBNativeException): integer;
const
  Token = 'concurrent transaction number is ';
var
  s: String;
  idx: integer;
begin

  s := E.Message; // FDAC IBMessage;

  idx := s.ToLower.IndexOf(Token);

  if idx <> -1 then
    s := s.Substring(idx + Token.length);

  s := s.Replace(sLineBreak, '', [rfReplaceAll]);

  if s.EndsWith('.') then
    s := s.Substring(0, s.length - 1);

  if not TryStrToInt(s, result) then
    result := -1;
end;

/// ////////////////////////////////////////////////

class function TFBErrorParser.GetTokenError(E: EIBNativeException): string;
const
  Token = 'token unknown - ';
var
  idx: integer;
  s: String;
begin
  result := '';

  s := E.Message; // FDAC IBMessage;
  s := AdjustLineBreaks(s);


  // SQL error state =42000
  // Dynamic SQL Error.
  // SQL error code = -104.
  // Token unknown - line 1, column 56.
  // ).

  idx := s.ToLower.IndexOf(Token);

  if idx > -1 then
  begin
    s := s.Substring(idx + Token.length);
    s := s.Replace('line', ' linea');
    s := s.Replace('column', 'colonna');

    idx := s.ToLower.IndexOf(sLineBreak);
    s.Insert(idx + length(sLineBreak), 'Token: ');

    result := s;
  end;
end;

/// ////////////////////////////////////////////////

/// // Generica
class function TFBErrorParser.Translate_Generic(E: EIBNativeException): string;
var
  TruncType, ExpLen, ActLen: string;
begin
  // Prova a estrarre info da errori di truncation/overflow anche se non specificamente gestiti
  if ExtractStringTruncationInfo(E, TruncType, ExpLen, ActLen) then
    result := BuildStringTruncationMessage(E, TruncType, ExpLen, ActLen)
  else
    result := GetExceptionMessage(E);
end;

/// // Eccezioni lanciate da procedure/trigger
class function TFBErrorParser.Translate_Exception(E: EIBNativeException): string;
begin
  result := GetExceptionMessage(E);
end;

/// // Foreign Key
class function TFBErrorParser.Translate_ForeignKey(E: EIBNativeException): string;

  function ProblematicValues(const s: string): string;
  const
    substr = 'Problematic key value is';
  var
    idx: integer;
  begin
    result := '';

    idx := AnsiPos(substr, s);
    if idx > 0 then
      result := s.Substring(idx + substr.length).Trim;
  end;

var
  FK: string;
  Tabella: string;
  TabellaFK: string;
  FieldNames: string;
  idx: integer;
  Values: String;
begin
  result := '';

  // 'Violation of FOREIGN KEY constraint "FK_CBI_ESITI_MAV_CBI_FLUSSI_ESI" on table "CBI_ESITI_MAV".'#$D#$A'Positive numeric value required.'#$D#$A'Password required.'#$D#$A
  // 'Violation of FOREIGN KEY constraint "FK_CBI_ESITI_MAV_CBI_FLUSSI_ESI" on table "CBI_ESITI_MAV".'#$D#$A'Number of transactions per sweep required.'#$D#$A }

  // 'SQL error state =23000'#$D#$A'Violation of FOREIGN KEY constraint "FK_TUTOR_DOCENTI" on table "TUTOR".'#$D#$A
  // 'Foreign key reference target does not exist.'#$D#$A
  // 'Problematic key value is ("ID_TUTOR" = 99999).'#$D#$A

  FK := GetConstraintName(E.Message); // FDAC IBMessage

  if Base.MetaData.ExtractFkParams(FK, Tabella, TabellaFK, FieldNames) then
  begin
    result := 'Relazione violata tra le tabelle ' + Tabella + ' e ' + TabellaFK + '.' + sLineBreak;

    if FieldNames.Contains(',') then
      result := result + 'Campi: ' + FieldNames + '.'
    else
      result := result + 'Campo ' + FieldNames + '.';

    Values := ExtractFkValue(E.Message); // FDAC IBMessage;

    //
    if not Values.IsEmpty then
      result := result + sLineBreak + Values;

    result := RemoveAtTriggerProcFunc(result);
  end
  else
    result := Translate_Generic(E);
end;

/// // Unique

class function TFBErrorParser.Translate_UniqueViolation(E: EIBNativeException): string;
var
  ConstraintName: string;
  FieldNames: string;
  l: string;
  Tabella: string;
  Values: string;
begin
  result := '';
  // violazione pk/unique sulla tabella/campi
  ConstraintName := GetConstraintName(E.Message); // FDAC IBMessage

  if Base.MetaData.ExtractUniqueParams(ConstraintName, Tabella, FieldNames) then
  begin
    result := 'Violazione del vincolo di univocità ' + ConstraintName + '.' + sLineBreak;
    result := result + 'Tentativo di inserire valori duplicati nella tabella ' + Tabella + '.' + sLineBreak;
    result := result + sLineBreak;

    FieldNames := FieldNames.Replace('"', '', [rfReplaceAll]);

    if FieldNames.Contains(',') then
      result := result + 'Campi: ' + FieldNames + '.'
    else
      result := result + 'Campo ' + FieldNames + '.';

    Values := ExtractFkValue(E.Message); // FDAC IBMessage

    if not Values.IsEmpty then
      result := result + sLineBreak + 'Valori: ' + Values;
  end
  else
    result := Translate_Generic(E);
end;

/// // Check Constraint

class function TFBErrorParser.Translate_CheckConstraint(E: EIBNativeException): string;
var
  ConstraintName: string;
  Tabella: string;
  CheckConstraint: string;
begin
  // Messaggio più astratto, fornendo il nome del constraint
  ConstraintName := GetConstraintName(E.Message); // FDAC IBMessage

  if Base.MetaData.ExtractCheckConstraintParams(ConstraintName, Tabella, CheckConstraint) then
  begin
    result := Tabella + ': violazione della regola:' + sLineBreak + sLineBreak;
    result := result + CheckConstraint;
  end
  else
    result := Translate_Generic(E);
end;

/// // Permission

class function TFBErrorParser.Translate_NotPermission(E: EIBNativeException): string;
begin
  // Fornire un messaggio più specifico
  result := Translate_Generic(E);
end;

/// // DeadLock

class function TFBErrorParser.Translate_DeadLock(E: EIBNativeException): string;
var
  idTransazione: integer;
  s: String;
begin
  // Mantis #334 - 2026-11-09: il testo dice cosa e' successo e cosa fare. Il
  // salvataggio di un dataset arriva qui solo dopo i tentativi ripetuti di
  // TzFbDataSet (TentativiSuConflitto); i valori inseriti restano nella scheda,
  // che rimane in modifica (verificato sul banco).
  result := 'Un altro utente o un''elaborazione sta modificando gli stessi dati in questo momento.' + sLineBreak + //
    'Le modifiche non sono state salvate: attendere qualche secondo e riprovare.';

  // il numero della transazione serve a chi analizza il problema, non all'utente
  // che legge il messaggio: resta in fondo, separato
  idTransazione := GetTransactionNumber(E);

  if (idTransazione <> -1) then
    result := result + sLineBreak + sLineBreak + '(transazione concorrente: ' + idTransazione.ToString + ')';
end;

/// // Token Unknow

class function TFBErrorParser.Translate_Token_Unknow(E: EIBNativeException): string;
var
  info: string;
begin
  result := 'Errore Sql';

  info := GetTokenError(E);

  if not info.IsEmpty then
    result := result + ' - ' + info
  else
    result := result + '.';
end;

/// //

class function TFBErrorParser.Translate_ValidationErrorForColumn(E: EIBNativeException): string;
  function CopyRight(const s, substr: string): string;
  var
    idx: integer;
  begin
    result := s;

    idx := s.ToUpper.IndexOf(substr.ToUpper);

    if idx <> -1 then
      result := s.Substring(idx + substr.length);
  end;

  function CopyLeft(const s, substr: string): string;
  var
    idx: integer;
  begin
    result := s;

    idx := s.ToUpper.IndexOf(substr.ToUpper);

    if idx <> -1 then
      result := s.Substring(0, idx);
  end;

  function ClearStr(const s: string): string;
  begin
    result := s;
    result := result.Replace('"', '', [rfReplaceAll]);
    result := result.Replace('***', '', [rfReplaceAll]);

    if result.StartsWith(sLineBreak) then
      result := result.Replace(sLineBreak, '', [rfReplaceAll]);

    if result.EndsWith(sLineBreak) then
      result := result.Substring(0, result.length - length(sLineBreak));
  end;

const
  constColumn = 'Validation error for column ';
var
  idx: integer;
  s: string;
  Token: string;
  fieldName: string;
  Value: string;
begin
  // 'SQL error state =23000'#$D#$A'Validation error for column "GERA_MANUTENZIONI"."DESC_MANUTENZIONE", value "*** null ***".'#$D#$A'At trigger ''GERA_MANUTENZIONI_ELENCO_BIUD0'' line: 32, col: 5.'#$D#$A
  result := E.Message; // FDAC IBMessage

  s := AdjustLineBreaks(E.Message); // FDAC IBMessage

  // estrazione del nome del campo
  s := CopyRight(s, 'Validation error for column ');
  fieldName := ClearStr(CopyLeft(s, ', value '));

  s := CopyRight(s, ', value ');
  s := CopyLeft(s, '.' + sLineBreak);
  s := CopyLeft(s, 'at ');
  Value := ClearStr(s);

  result := 'Valore ' + Value + ' non valido per il campo ' + fieldName + '.';
end;

/// // String Truncation e DataType Errors (335544321)

class function TFBErrorParser.ExtractStringTruncationInfo(E: EIBNativeException;
  out TruncationType, ExpectedLen, ActualLen: string): boolean;
var
  msg: string;
  idxExp, idxAct, idx: integer;
begin
  result := false;
  TruncationType := '';
  ExpectedLen := '';
  ActualLen := '';

  msg := AdjustLineBreaks(E.Message);

  // Identifica il tipo di errore
  if msg.ToLower.Contains('string right truncation') then
    TruncationType := 'string right truncation'
  else if msg.ToLower.Contains('string left truncation') then
    TruncationType := 'string left truncation'
  else if msg.ToLower.Contains('arithmetic exception') or msg.ToLower.Contains('numeric overflow') then
    TruncationType := 'numeric overflow'
  else
    Exit;

  result := true;

  // Estrae "expected length X, actual Y".
  // Si salta l'INTERA dicitura 'expected length', non solo fino al primo
  // spazio: fermandosi li' restava dentro anche la parola "length" e il
  // messaggio usciva "Campo definito per length 1 caratteri".
  idxExp := msg.ToLower.IndexOf('expected length');
  if idxExp > -1 then
  begin
    msg := msg.Substring(idxExp + Length('expected length')).Trim;
    idx := msg.IndexOf(',');
    if idx > -1 then
      ExpectedLen := msg.Substring(0, idx).Trim
    else
      ExpectedLen := msg.Trim;
  end;

  idxAct := msg.ToLower.IndexOf('actual');
  if idxAct > -1 then
  begin
    msg := msg.Substring(idxAct);
    idx := msg.IndexOf(' ');
    if idx > -1 then
    begin
      msg := msg.Substring(idx).Trim;
      idx := msg.IndexOf(sLineBreak);
      if idx < 0 then
        idx := msg.IndexOf('.');
      if idx > 0 then
        ActualLen := msg.Substring(0, idx).Trim
      else
        ActualLen := msg.Trim;
    end;
  end;
end;

// Mantis #259 - 2026-10-19: Firebird non dice quale campo e' troppo corto, ma nel messaggio c'e' la
// catena "At procedure 'X' line: N" delle procedure e dei trigger attraversati. GetExceptionMessage la
// toglie (RemoveAtTriggerProcFunc), quindi qui la si legge dal messaggio originale e la si riscrive in
// italiano: l'operatore capisce dove si e' fermato il lavoro, chi risponde al ticket sa dove guardare.
class function TFBErrorParser.ExtractCallPath(const Messaggio: string): string;
var
  Corrispondenza: TMatch;
  Tipo: string;
begin
  result := '';

  for Corrispondenza in TRegEx.Matches(AdjustLineBreaks(Messaggio),
    'At (sub function|sub procedure|procedure|trigger|function) ''([^'']+)'' line: (\d+)', [roIgnoreCase]) do
  begin
    Tipo := Corrispondenza.Groups[1].Value.ToLower;

    if Tipo = 'procedure' then
      Tipo := 'procedura'
    else
      if Tipo = 'function' then
        Tipo := 'funzione'
      else
        if Tipo = 'sub function' then
          Tipo := 'funzione interna'
        else
          if Tipo = 'sub procedure' then
            Tipo := 'procedura interna';

    if not result.IsEmpty then
      result := result + sLineBreak + 'chiamata da: ';

    result := result + Tipo + ' ' + Corrispondenza.Groups[2].Value + ', riga ' + Corrispondenza.Groups[3].Value;
  end;
end;

class function TFBErrorParser.BuildStringTruncationMessage(E: EIBNativeException; const TruncType, ExpLen, ActLen: string): string;
var
  CallPath: string;
begin
  if TruncType = 'numeric overflow' then
    result := 'Un valore numerico supera quello che il campo di destinazione puo'' contenere.' + sLineBreak
  else
    if not ExpLen.IsEmpty and not ActLen.IsEmpty then
      result := 'Un valore e'' piu'' lungo del campo che deve contenerlo: il campo accetta ' + ExpLen +
                ' caratteri, il valore ne ha ' + ActLen + '.' + sLineBreak
    else
      result := 'Un valore e'' piu'' lungo del campo che deve contenerlo.' + sLineBreak;

  CallPath := ExtractCallPath(E.Message);

  if not CallPath.IsEmpty then
    result := result + 'Si e'' verificato in: ' + CallPath + '.' + sLineBreak;

  result := result + sLineBreak + 'Dettaglio tecnico (' + TruncType + '):' + sLineBreak + GetExceptionMessage(E);
end;

class function TFBErrorParser.Translate_StringTruncation(E: EIBNativeException): string;
var
  TruncType, ExpLen, ActLen: string;
begin
  result := GetExceptionMessage(E);

  if ExtractStringTruncationInfo(E, TruncType, ExpLen, ActLen) then
    result := BuildStringTruncationMessage(E, TruncType, ExpLen, ActLen);
end;

/// //
/// //
/// //

function TranslateFIBError(E: EIBNativeException): string;
begin
  E.Message := UTF8ToString(E.Message);

  case E.Errors[0].ErrorCode of // E.SQLCode
    isc_check_constraint: // sqlcode_checkconstraint:
      begin
        result := TFBErrorParser.Translate_CheckConstraint(E);
      end;
    isc_foreign_key, isc_foreign_key_notfound, isc_foreign_key_target_doesnt_exist, isc_foreign_key_references_present: // sqlcode_foreign_or_create_schema:
      begin
        result := TFBErrorParser.Translate_ForeignKey(E);
      end;
    // sqlcode_notpermission: FDAC
    // begin
    // result := Translate_NotPermission(E);
    // end;
    // Mantis #180 - 2026-09-24: un indice univoco senza vincolo (per esempio l'indice parziale
    // UNQ1_AULE_PRENOTAZIONI) solleva isc_no_dup, non isc_unique_key_violation. Il messaggio ha
    // la stessa forma (nome dell'indice e valori in conflitto), GetConstraintName riconosce
    // gia' la parola 'index' e ExtractUniqueParams ripiega sugli indici del dizionario:
    // basta smistare anche questo codice alla stessa traduzione.
    isc_unique_key_violation, // sqlcode_unique_violation: vincolo PRIMARY KEY o UNIQUE
    335544349: // isc_no_dup: indice univoco senza vincolo
      begin
        result := TFBErrorParser.Translate_UniqueViolation(E);
      end;
    // sqlcode_exception: FDAC
    // begin
    // result := Translate_Exception(E);
    // end;
    isc_deadlock: // sqlcode_deadlock:
      begin
        result := TFBErrorParser.Translate_DeadLock(E);
      end;

    -104:
      begin
        result := TFBErrorParser.Translate_Token_Unknow(E);
      end;

    -625:
      begin
        result := TFBErrorParser.Translate_ValidationErrorForColumn(E);
      end;

    335544321: // isc_dsql_datatype_err: String truncation, numeric overflow, etc
      begin
        result := TFBErrorParser.Translate_StringTruncation(E);
      end;

    // sqlcode_902: FDAC
    // begin
    // result := Translate_Generic(E);
    // end;
    // sqlcode_901: FDAC
    // begin
    // result := Translate_Generic(E);
    // end;
  else
    result := TFBErrorParser.Translate_Generic(E);
  end;
end;

function EstraiPercorsoChiamate(const Messaggio: string): string;
begin
  result := TFBErrorParser.ExtractCallPath(Messaggio);
end;

end.
