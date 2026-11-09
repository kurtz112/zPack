unit zParamsHelper;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  Data.DB,
  FireDAC.Stan.Param,
  zFbDataSet;

type
  // Mantis #141 - 2026-09-20: valore incompatibile con il tipo del parametro.
  // Viene sollevata da TzParamValue.Assegna nel momento in cui il valore
  // sbagliato viene scritto, non alla prossima apertura del cursore.
  EzParamTypeMismatch = class(Exception);

  // Mantis #141 - 2026-09-20
  //
  // PERCHE' ESISTE
  // TFDParam.Value non converte e non valida: se il tipo del parametro e' gia'
  // noto (lo fissa la descrizione dell'istruzione fatta dal server) il variante
  // viene memorizzato com'e'. La conversione avviene solo quando il driver
  // compone il blocco dei parametri, cioe' all'apertura del cursore: li'
  // GetAsIntegers chiama VarToInteger e su una stringa non numerica solleva
  // "Could not convert variant of type (String) into type (Integer)".
  //
  // L'errore arriva quindi lontano da chi ha scritto il valore, e non nomina
  // ne' il dataset, ne' il parametro, ne' il valore. Il ticket 141 e' nato
  // cosi': l'eccezione usciva dalla ricostruzione dei filtri toolbar, molte
  // schermate dopo il punto che aveva scritto il valore incompatibile.
  //
  // Qui la conversione e' esplicita, guidata dal tipo del parametro, e il
  // fallimento e' immediato e parlante.
  TzParamValue = class
  public
    /// <summary>
    /// Converte Valore nel tipo TipoDato. False se la conversione non e'
    /// possibile: in quel caso Convertito non e' significativo.
    /// Nullo, non assegnato e stringa vuota danno sempre True con Convertito
    /// nullo: "nessun valore" e' valido per qualunque tipo.
    /// </summary>
    class function TryConvert(const Valore: Variant; TipoDato: TFieldType; out Convertito: Variant): Boolean; static;

    /// <summary>
    /// Assegna Valore a Param convertendolo al tipo del parametro. Se la
    /// conversione non e' possibile azzera il parametro e solleva
    /// EzParamTypeMismatch, citando Contesto, nome del parametro, tipo atteso
    /// e valore ricevuto.
    /// </summary>
    class procedure Assegna(Param: TFDParam; const Valore: Variant; const Contesto: string); static;

    /// <summary>Nome leggibile del tipo ('Integer', 'String', ...).</summary>
    class function DescrizioneTipo(TipoDato: TFieldType): string; static;

    /// <summary>
    /// Elenco 'NOME (Tipo) = valore', una riga per parametro. Serve a dare un
    /// contesto leggibile agli errori di apertura.
    /// </summary>
    class function Descrivi(Params: TFDParams): string; static;
  end;

  TzParamsHelper = class helper for TParams
  public
    // TFDParams
    procedure LoadParams(Params: TFDParams; HiddenParams: TStrings; const IncludeOutputParams: boolean = false); overload;
    procedure LoadParams(Params: TFDParams; HiddenParams: string; const IncludeOutputParams: boolean = false); overload;
    // TParams
    procedure LoadParams(Params: TParams; HiddenParams: TStrings; const IncludeOutputParams: boolean = false); overload;
    procedure LoadParams(Params: TParams; HiddenParams: string; const IncludeOutputParams: boolean = false); overload;
  public
    procedure SaveParams(Params: TFDParams); overload;
    procedure SaveParams(Params: TParams); overload;
  end;

implementation

uses
  System.TypInfo,
  System.DateUtils;

// ---------------------------------------------------------------------------
// TzParamValue
// ---------------------------------------------------------------------------

class function TzParamValue.DescrizioneTipo(TipoDato: TFieldType): string;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Ord(TipoDato));

  // 'ftInteger' -> 'Integer': il prefisso non aggiunge niente a chi legge
  // il messaggio, che e' chi ha configurato il filtro, non chi legge il codice.
  if Result.StartsWith('ft') then
    Result := Result.Substring(2);
end;

class function TzParamValue.Descrivi(Params: TFDParams): string;
var
  i: Integer;
  Riga: string;
begin
  Result := '';

  if not Assigned(Params) then
    Exit;

  for i := 0 to Params.Count - 1 do
  begin
    if Params[i].IsNull then
      Riga := Format('  %s (%s) = <nullo>', [Params[i].Name, DescrizioneTipo(Params[i].DataType)])
    else
      try
        Riga := Format('  %s (%s) = %s', [Params[i].Name, DescrizioneTipo(Params[i].DataType), VarToStr(Params[i].Value)]);
      except
        // Il valore non e' nemmeno rappresentabile come testo: e' proprio il
        // caso che stiamo diagnosticando, non deve far fallire la diagnosi.
        on E: Exception do
          Riga := Format('  %s (%s) = <valore non leggibile: %s>', [Params[i].Name, DescrizioneTipo(Params[i].DataType), E.Message]);
      end;

    if Result = '' then
      Result := Riga
    else
      Result := Result + sLineBreak + Riga;
  end;
end;

class function TzParamValue.TryConvert(const Valore: Variant; TipoDato: TFieldType; out Convertito: Variant): Boolean;
var
  Testo: string;
  Intero: Int64;
  Numero: Double;
  Momento: TDateTime;
  Booleano: Boolean;
begin
  Result := True;
  Convertito := Valore;

  if VarIsNull(Valore) or VarIsEmpty(Valore) then
  begin
    Convertito := Null;
    Exit;
  end;

  if not VarIsStr(Valore) then
  begin
    // Un numero verso un parametro testuale: la direzione che non perde mai
    // niente, e la sola che serve convertire quando il valore non e' testo.
    if TipoDato in [ftString, ftWideString, ftFixedChar, ftFixedWideChar, ftMemo, ftWideMemo] then
      Convertito := VarToStr(Valore);
    Exit;
  end;

  Testo := VarToStr(Valore).Trim;

  if Testo.IsEmpty then
  begin
    // Stringa vuota e nullo sono la stessa cosa: "nessun filtro".
    Convertito := Null;
    Exit;
  end;

  case TipoDato of
    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftByte, ftShortint, ftLongWord:
      begin
        Result := TryStrToInt64(Testo, Intero);
        if Result then
          Convertito := Intero;
      end;

    // System.TypInfo dichiara a sua volta ftSingle e ftExtended (sono membri di
    // TFloatType) e, stando piu' avanti nella uses, vince sui simboli di
    // Data.DB: senza la qualificazione il compilatore legge qui due costanti di
    // un altro tipo enumerato ed esce con E2010.
    ftFloat, Data.DB.ftSingle, Data.DB.ftExtended, ftCurrency, ftBCD, ftFMTBcd:
      begin
        Result := TryStrToFloat(Testo, Numero);
        if Result then
          Convertito := Numero;
      end;

    ftDate, ftTime, ftDateTime, ftTimeStamp:
      begin
        if TryISO8601ToDate(Testo, Momento, False) then
          Convertito := Momento
        else
          if TryStrToDateTime(Testo, Momento) then
            Convertito := Momento
          else
            Result := False;
      end;

    ftBoolean:
      begin
        Result := TryStrToBool(Testo, Booleano);
        if Result then
          Convertito := Booleano;
      end;

    ftString, ftWideString, ftFixedChar, ftFixedWideChar, ftMemo, ftWideMemo:
      Convertito := Testo;
  end;
end;

class procedure TzParamValue.Assegna(Param: TFDParam; const Valore: Variant; const Contesto: string);
var
  Convertito: Variant;
  Dove: string;
begin
  if not Assigned(Param) then
    Exit;

  if not TryConvert(Valore, Param.DataType, Convertito) then
  begin
    Dove := Contesto.Trim;
    if Dove.IsEmpty then
      Dove := 'Impostazione dei parametri';

    // Il parametro resta senza valore di proposito: una selezione non applicata
    // si vede e si corregge, un parametro avvelenato fa invece fallire ogni
    // apertura successiva in un punto che non ha piu' niente a che vedere con
    // chi ha scritto il valore.
    Param.Clear;

    raise EzParamTypeMismatch.CreateFmt('%s: il parametro "%s" e'' di tipo %s e non accetta il valore "%s".' + sLineBreak +
      'Il valore non e'' stato applicato.', [Dove, Param.Name, DescrizioneTipo(Param.DataType), VarToStr(Valore)]);
  end;

  if VarIsNull(Convertito) or VarIsEmpty(Convertito) then
    Param.Clear
  else
    Param.Value := Convertito;
end;

// ---------------------------------------------------------------------------
// TzParamsHelper
// ---------------------------------------------------------------------------

procedure TzParamsHelper.LoadParams(Params: TFDParams; HiddenParams: TStrings; const IncludeOutputParams: boolean = false);
var
  i: Integer;
  InternalParam: TParam;
  Param: TFDParam;
begin
  Clear;

  for i := 0 to Params.Count - 1 do
  begin
    Param := Params[i];

    if Assigned(HiddenParams) and (HiddenParams.IndexOf(Params[i].Name) <> -1) then
      Continue;

    if Param.ParamType in [ptOutput, ptResult] then
      if not IncludeOutputParams then
        Continue;

    InternalParam := Self.AddParameter;
    InternalParam.ParamType := ptInputOutput;
    InternalParam.Name := Param.Name;
    InternalParam.DataType := Param.DataType;
    InternalParam.Size := Param.Size;
    InternalParam.NumericScale := Param.NumericScale;
    InternalParam.Precision := Param.Precision;

    if Param.IsNull then
      InternalParam.Clear
    else
      InternalParam.Value := Param.Value;
  end;
end;

procedure TzParamsHelper.LoadParams(Params: TParams; HiddenParams: TStrings; const IncludeOutputParams: boolean = false);
var
  i: Integer;
begin
  Clear;

  for i := 0 to Params.Count - 1 do
  begin
    if Assigned(HiddenParams) and (HiddenParams.IndexOf(Params[i].Name) <> -1) then
      Continue;

    if Params[i].ParamType in [ptOutput, ptResult] then
      if not IncludeOutputParams then
        Continue;

    Self.AddParameter.Assign(Params[i]);
  end;
end;

procedure TzParamsHelper.LoadParams(Params: TParams; HiddenParams: string; const IncludeOutputParams: boolean = false);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.Delimiter := ';';
    StringList.DelimitedText := HiddenParams.replace(',', ';');

    LoadParams(Params, StringList, IncludeOutputParams);
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzParamsHelper.LoadParams(Params: TFDParams; HiddenParams: string; const IncludeOutputParams: boolean = false);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.Delimiter := ';';
    StringList.DelimitedText := HiddenParams.replace(',', ';');

    LoadParams(Params, StringList, IncludeOutputParams);
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TzParamsHelper.SaveParams(Params: TFDParams);
var
  i: Integer;
  InternalParam: TParam;
  Param: TFDParam;
begin
  if not Assigned(Params) then
    Exit;

  for i := 0 to Count - 1 do
  begin
    InternalParam := Self[i];
    Param := Params.ParamByName(InternalParam.Name);

    if Assigned(Param) then
      // Mantis #141 - 2026-09-20: conversione guidata dal tipo del parametro.
      // Il dialogo dei parametri costruisce una casella di testo per ogni
      // parametro che il server non ha ancora descritto (DataType ftUnknown,
      // tipico di una SQL appena modificata su un dataset amManual mai aperto):
      // quello che l'utente digita entrava nel parametro come stringa e
      // l'apertura falliva dopo, senza dire su quale parametro.
      TzParamValue.Assegna(Param, InternalParam.Value, Format('Parametro "%s"', [InternalParam.Name]));
  end;
end;

procedure TzParamsHelper.SaveParams(Params: TParams);
begin
  if Assigned(Params) then
    Params.Assign(Self);
end;

end.
