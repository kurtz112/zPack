unit zStoredProcCodeFactory;

interface

uses
  SysUtils,
  Classes,
  zMetadata,
  DB;

type
  TzStoredProcCodeFactory = class
  private
    function FormatProcName(const StoredProcName: string): string;
    function FormatParamName(const ParamName: string): string;

    function GetParamType(prm: TzmdParam): string;
    function GetParamTypePiatto(prm: TzmdParam): string;
    function HasBlobParam(proc: TzmdProcedure): boolean;
    function HasBlobInputParam(proc: TzmdProcedure): boolean;
  private
    FFileName: string;
    FMetadata: TzMetadata;
    FSourceDB: string;
    ResultCode: TStringList;
    procedure SetSourceDB(const Value: string);
    procedure WriteHeader;
    procedure WriteClassInterfaces;
    procedure WriteClassInterface(proc: TzmdProcedure);
    procedure WriteImplementation;
    procedure WriteClassImplementations;
    procedure WriteClassImplementation(proc: TzmdProcedure);
    procedure WriteEndUnit;
    //
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
  published
    property FileName: string read FFileName write FFileName;
    property Metadata: TzMetadata read FMetadata write FMetadata;
    property SourceDB: string read FSourceDB write SetSourceDB;
  end;

procedure GenerateStoredProcCode(Metadata: TzMetadata; const FileName: string; SourceDB: string);

implementation

const
  procPrefix = 'TSP_';

procedure GenerateStoredProcCode(Metadata: TzMetadata; const FileName: string; SourceDB: string);
var
  zStoredProcCodeFactory: TzStoredProcCodeFactory;
begin
  zStoredProcCodeFactory := TzStoredProcCodeFactory.Create;
  try
    zStoredProcCodeFactory.Metadata := Metadata;
    zStoredProcCodeFactory.FileName := FileName;
    zStoredProcCodeFactory.SourceDB := SourceDB;
    zStoredProcCodeFactory.Execute;
  finally
    FreeAndNil(zStoredProcCodeFactory);
  end;
end;

constructor TzStoredProcCodeFactory.Create;
begin
  inherited;

  FFileName := '';
  FMetadata := nil;
  FSourceDB := '';

  ResultCode := TStringList.Create;
end;

destructor TzStoredProcCodeFactory.Destroy;
begin
  FreeAndNil(ResultCode);
  inherited;
end;

procedure TzStoredProcCodeFactory.Execute;
begin
  Assert(Assigned(Metadata));
  Assert(FileName <> '');

  ResultCode.Clear;

  WriteHeader;
  WriteClassInterfaces;
  WriteImplementation;
  WriteClassImplementations;
  WriteEndUnit;

  ResultCode.SaveToFile(FileName);
end;

function TzStoredProcCodeFactory.FormatParamName(const ParamName: string): string;
var
  LastChar: Char;
  c: Char;
begin
  Result := '';

  if trim(ParamName) = '' then
    Exit;

  LastChar := ' ';

  for c in ParamName do
  begin
    if not(c in [' ']) then
    begin
      if (LastChar in [' ', '_']) then
        Result := Result + UpperCase(c)
      else
        Result := Result + LowerCase(c);
    end;
    LastChar := c;
  end;
end;

function TzStoredProcCodeFactory.FormatProcName(const StoredProcName: string): string;
var
  LastChar: Char;
  c: Char;
begin
  // ZZ_TESSERE_WT_TO_GBCOM
  // TProc_zz_Tessere_Wt_To_Gbcom

  Result := '';

  if trim(StoredProcName) = '' then
    Exit;

  LastChar := ' ';

  // Firebird Package
  for c in LowerCase(StoredProcName.Replace('.', '__')) do
  begin

    if LastChar = '_' then
      Result := Result + UpCase(c)
    else
      Result := Result + c;

    LastChar := c;
  end;
end;

function TzStoredProcCodeFactory.GetParamType(prm: TzmdParam): string;
begin
  Assert(Assigned(prm));

  Result := '';

  case prm.DataType of
    ftUnknown:
      Result := 'TNullableInteger';
    ftString:
      Result := 'TNullableString';
    ftSmallint:
      Result := 'TNullableInteger';
    ftInteger:
      Result := 'TNullableInteger';
    ftWord:
      Result := 'TNullableInteger';
    ftBoolean:
      Result := 'TNullableBoolean';
    ftFloat:
      Result := 'TNullableDouble';
    ftCurrency:
      Result := 'TNullableCurrency';
    ftBCD:
      Result := 'bcd';
    ftDate:
      Result := 'TNullableDate';
    ftTime:
      Result := 'TNullableTime';
    ftDateTime:
      Result := 'TNullableDateTime';
    ftBytes:
      Result := 'bytes';
    ftVarBytes:
      Result := 'varBytes';
    ftAutoInc:
      Result := 'TNullableInteger';
    ftBlob:
      Result := 'TPicture';
    ftMemo:
      Result := 'TStringList';
    ftGraphic:
      Result := 'TPicture';
    ftFmtMemo:
      Result := 'fmtMemo';
    ftParadoxOle:
      Result := 'paradoxOle';
    ftDBaseOle:
      Result := 'dBaseOle';
    ftTypedBinary:
      Result := 'typedBinary';
    ftCursor:
      Result := 'cursor';
    ftFixedChar:
      Result := 'FixedChar';
    ftWideString:
      Result := 'TNullableWideString';
    ftLargeint:
      Result := 'TNullableInt64';
    ftADT:
      Result := 'ADT';
    ftArray:
      Result := 'Array';
    ftReference:
      Result := 'reference';
    ftDataSet:
      Result := 'DataSet';
    ftOraBlob:
      Result := 'OraBlob';
    ftOraClob:
      Result := 'OraClob';
    ftVariant:
      Result := 'Variant';
    ftInterface:
      Result := 'interface';
    ftIDispatch:
      Result := 'IDispatch';
    ftGuid:
      Result := 'TNullableGuid';
    ftTimeStamp:
      Result := 'TNullableDateTime';
    ftFMTBcd:
      Result := 'frmBCD';
    ftFixedWideChar:
      Result := 'FixedWideChar';
    ftWideMemo:
      Result := 'TStringList';
    ftOraTimeStamp:
      Result := 'OraTimeStamp';
    ftOraInterval:
      Result := 'OraInterval';
    ftLongWord:
      Result := 'LongWord';
    ftShortint:
      Result := 'TNullableInteger';
    ftByte:
      Result := 'byte';
    ftExtended:
      Result := 'extended';
    ftConnection:
      Result := 'Connection';
    ftParams:
      Result := 'Params';
    ftStream:
      Result := 'Stream';
    ftTimeStampOffset:
      Result := 'TimeStampOffset';
    ftObject:
      Result := 'Object';
    ftSingle:
      Result := 'Single';
  end;
end;

function TzStoredProcCodeFactory.GetParamTypePiatto(prm: TzmdParam): string;
begin
  Assert(Assigned(prm));

  Result := '';

  case prm.DataType of
    ftUnknown:
      Result := 'integer';
    ftString:
      Result := 'string';
    ftSmallint:
      Result := 'smallint';
    ftInteger:
      Result := 'integer';
    ftWord:
      Result := 'word';
    ftBoolean:
      Result := 'boolean';
    ftFloat:
      Result := 'double';
    ftCurrency:
      Result := 'currency';
    ftBCD:
      Result := 'bcd';
    ftDate:
      Result := 'TDateTime';
    ftTime:
      Result := 'TDateTime';
    ftDateTime:
      Result := 'TDateTime';
    ftBytes:
      Result := 'bytes';
    ftVarBytes:
      Result := 'varBytes';
    ftAutoInc:
      Result := 'integer';
    ftBlob:
      Result := 'TPicture';
    ftMemo:
      Result := 'TStringList';
    ftGraphic:
      Result := 'TPicture';
    ftFmtMemo:
      Result := 'fmtMemo';
    ftParadoxOle:
      Result := 'paradoxOle';
    ftDBaseOle:
      Result := 'dBaseOle';
    ftTypedBinary:
      Result := 'typedBinary';
    ftCursor:
      Result := 'cursor';
    ftFixedChar:
      Result := 'FixedChar';
    ftWideString:
      Result := 'wideString';
    ftLargeint:
      Result := 'Int64';
    ftADT:
      Result := 'ADT';
    ftArray:
      Result := 'Array';
    ftReference:
      Result := 'reference';
    ftDataSet:
      Result := 'DataSet';
    ftOraBlob:
      Result := 'OraBlob';
    ftOraClob:
      Result := 'OraClob';
    ftVariant:
      Result := 'Variant';
    ftInterface:
      Result := 'interface';
    ftIDispatch:
      Result := 'IDispatch';
    ftGuid:
      Result := 'Guid';
    ftTimeStamp:
      Result := 'TDateTime';
    ftFMTBcd:
      Result := 'frmBCD';
    ftFixedWideChar:
      Result := 'FixedWideChar';
    ftWideMemo:
      Result := 'TStringList';
    ftOraTimeStamp:
      Result := 'OraTimeStamp';
    ftOraInterval:
      Result := 'OraInterval';
    ftLongWord:
      Result := 'LongWord';
    ftShortint:
      Result := 'ShortInt';
    ftByte:
      Result := 'byte';
    ftExtended:
      Result := 'extended';
    ftConnection:
      Result := 'Connection';
    ftParams:
      Result := 'Params';
    ftStream:
      Result := 'Stream';
    ftTimeStampOffset:
      Result := 'TimeStampOffset';
    ftObject:
      Result := 'Object';
    ftSingle:
      Result := 'Single';
  end;
end;

function TzStoredProcCodeFactory.HasBlobInputParam(proc: TzmdProcedure): boolean;
var
  i: integer;
begin
  Assert(Assigned(proc));

  Result := False;

  for i := 0 to proc.ParamsInput.Count - 1 do
    if proc.ParamsInput[i].IsBlob then
      Exit(True);
end;

function TzStoredProcCodeFactory.HasBlobParam(proc: TzmdProcedure): boolean;
var
  i: integer;
begin
  Assert(Assigned(proc));

  Result := False;

  for i := 0 to proc.ParamsInput.Count - 1 do
    if proc.ParamsInput[i].IsBlob then
      Exit(True);

  for i := 0 to proc.ParamsOutput.Count - 1 do
    if proc.ParamsOutput[i].IsBlob then
      Exit(True);
end;

procedure TzStoredProcCodeFactory.SetSourceDB(const Value: string);
begin
  FSourceDB := Value;
end;

/// //////////////////////////////////////////////////////////////////////////////////////////////
/// //////////////////////////////////////////////////////////////////////////////////////////////
/// //////////////////////////////////////////////////////////////////////////////////////////////

procedure TzStoredProcCodeFactory.WriteHeader;
begin
  // Niente data di generazione (2026-10-13): cambiava il file a ogni
  // rigenerazione anche senza procedure nuove, con un commit inutile e un
  // falso conflitto per i rilasci che toccano il wrapper. La data la da' git.
  ResultCode.Add(Format('// DataBase: %s', [SourceDB]));
  ResultCode.Add('unit ' + ChangeFileExt(ExtractFileName(FileName), '') + ';');
  ResultCode.Add('');
  ResultCode.Add('interface');
  ResultCode.Add('');
  ResultCode.Add('Uses SysUtils, Classes, Graphics, zStoredProc, zz.Nullable;');
  ResultCode.Add('');
  ResultCode.Add('type ');
end;

procedure TzStoredProcCodeFactory.WriteClassInterfaces;
var
  i: integer;
  proc: TzmdProcedure;
begin
  for i := 0 to Metadata.Procedures.Count - 1 do
  begin
    proc := Metadata.Procedures[i];
    // if proc.ParamsOutput.Count > 0 then
    // begin
    ResultCode.Add('');
    WriteClassInterface(proc);
    // end;
  end;
end;

procedure TzStoredProcCodeFactory.WriteClassInterface(proc: TzmdProcedure);
// conversione di tipo
var
  i: integer;
  param: TzmdParam;
  prmName: string;
  prmType: string;
  s: string;
begin
  // Mantis #61 - 2026-08-31: le procedure con SUSPEND vanno dichiarate
  // selezionabili, altrimenti il wrapper non sa di dover usare Open + Next
  if proc.ProcedureType = ptSelect then
    ResultCode.Add(Format('[TStoredProcedure(''%s'', True)]', [proc.Name]))
  else
    ResultCode.Add(Format('[TStoredProcedure(''%s'')]', [proc.Name]));

  ResultCode.Add(Format('{$RTTI EXPLICIT PROPERTIES([vcPrivate, vcPublic, vcPublished])}', []));
  ResultCode.Add(Format('%s = class (TzStoredProc)', [procPrefix + FormatProcName(proc.Name)]));
  // Fields
  ResultCode.Add('  private');

  for i := 0 to proc.ParamsInput.Count - 1 do
  begin
    param := proc.ParamsInput[i];
    prmType := GetParamType(param);
    ResultCode.Add('    ' + 'f' + FormatParamName(param.Name) + ': ' + prmType + ';');
  end;

  for i := 0 to proc.ParamsOutput.Count - 1 do
  begin
    param := proc.ParamsOutput[i];
    prmType := GetParamType(param);
    ResultCode.Add('    ' + 'f' + FormatParamName(param.Name) + ': ' + prmType + ';');
  end;

  // Propriet� di output per write
  if proc.ParamsOutput.Count > 0 then
  begin
    ResultCode.Add('  private');

    for i := 0 to proc.ParamsOutput.Count - 1 do
      if not proc.ParamsOutput[i].IsBlob then
      begin
        param := proc.ParamsOutput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);
        s := Format('    property %s: %s read f%s write f%s;', [prmName + '_internal', prmType, prmName, prmName]);
        ResultCode.Add(s);
      end;
  end;

  // Blob
  if HasBlobParam(proc) then
  begin

    if HasBlobInputParam(proc) then
      ResultCode.Add('  private');

    for i := 0 to proc.ParamsInput.Count - 1 do
      if proc.ParamsInput[i].IsBlob then
      begin
        param := proc.ParamsInput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);
        ResultCode.Add(Format('    procedure Set%s(const Value: %s);', [prmName, prmType]));
      end;

    ResultCode.Add('  public');
    ResultCode.Add('    constructor Create; override;');
    ResultCode.Add('    destructor Destroy; override;');
  end;

  ResultCode.Add('  public');
  for i := 0 to proc.ParamsInput.Count - 1 do
  begin
    param := proc.ParamsInput[i];
    prmType := GetParamType(param);
    prmName := FormatParamName(param.Name);
    ResultCode.Add(Format('    //', []));
    ResultCode.Add(Format('    [TParamAttribute(''%s'', ptInput, %s)]', [param.Name, BoolToStr(param.IsBlob, True)])); // IsBlob??

    if param.IsBlob then
      ResultCode.Add(Format('    property %s: %s read f%s write Set%s;', [prmName, prmType, prmName, prmName]))
    else
      ResultCode.Add(Format('    property %s: %s read f%s write f%s;', [prmName, prmType, prmName, prmName]));
  end;

  for i := 0 to proc.ParamsOutput.Count - 1 do
  begin
    param := proc.ParamsOutput[i];
    prmType := GetParamType(param);
    prmName := FormatParamName(param.Name);
    ResultCode.Add(Format('    //', []));
    ResultCode.Add(Format('    [TParamAttribute(''%s'', ptOutput, %s)]', [param.Name, BoolToStr(param.IsBlob, True)])); // IsBlob??
    ResultCode.Add(Format('    property %s: %s read f%s;', [prmName, prmType, prmName]));
  end;

  ResultCode.Add('end;');
end;

procedure TzStoredProcCodeFactory.WriteImplementation;
begin
  ResultCode.Add('');
  ResultCode.Add('implementation');
  ResultCode.Add('');
end;

procedure TzStoredProcCodeFactory.WriteClassImplementations;
var
  i: integer;
  proc: TzmdProcedure;
begin
  for i := 0 to Metadata.Procedures.Count - 1 do
  begin
    proc := Metadata.Procedures[i];
    // if proc.ParamsOutput.Count > 0 then
    // begin
    WriteClassImplementation(proc);
    // end;
  end;
end;

procedure TzStoredProcCodeFactory.WriteClassImplementation(proc: TzmdProcedure);
var
  i: integer;
  param: TzmdParam;
  prmName: string;
  prmType: string;
  ProcName: string;
begin
  ProcName := procPrefix + FormatProcName(proc.Name);

  if HasBlobParam(proc) then
  begin
    /// //////////////////////////////////////////
    // Constructor Create
    ResultCode.Add(Format('constructor %s.Create;', [ProcName]));
    ResultCode.Add('begin');
    ResultCode.Add('  inherited;');

    for i := 0 to proc.ParamsInput.Count - 1 do
      if proc.ParamsInput[i].IsBlob then
      begin
        param := proc.ParamsInput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);

        if param.DataType in [ftMemo, ftWideMemo] then
          ResultCode.Add(Format('  f%s := CreateStringList;', [prmName]))
        else
          ResultCode.Add(Format('  f%s := %s.Create;', [prmName, prmType]));
      end;

    for i := 0 to proc.ParamsOutput.Count - 1 do
      if proc.ParamsOutput[i].IsBlob then
      begin
        param := proc.ParamsOutput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);

        if param.DataType in [ftMemo, ftWideMemo] then
          ResultCode.Add(Format('  f%s := CreateStringList;', [prmName]))
        else
          ResultCode.Add(Format('  f%s := %s.Create;', [prmName, prmType]));
      end;
    ResultCode.Add('end;');
    ResultCode.Add('');
    /// //////////////////////////////////////////
    // Destructor Destroy;
    ResultCode.Add(Format('destructor %s.Destroy;', [ProcName]));
    ResultCode.Add('begin');

    for i := 0 to proc.ParamsInput.Count - 1 do
      if proc.ParamsInput[i].IsBlob then
      begin
        param := proc.ParamsInput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);
        ResultCode.Add(Format('  FreeAndNil(f%s);', [prmName, prmType]));
      end;

    for i := 0 to proc.ParamsOutput.Count - 1 do
      if proc.ParamsOutput[i].IsBlob then
      begin
        param := proc.ParamsOutput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);
        ResultCode.Add(Format('  FreeAndNil(f%s);', [prmName, prmType]));
      end;
    ResultCode.Add('  inherited;');
    ResultCode.Add('end;');
    ResultCode.Add('');
    /// //////////////////////////////////////////
    /// Setter dei parametri di input
    for i := 0 to proc.ParamsInput.Count - 1 do
      if proc.ParamsInput[i].IsBlob then
      begin
        param := proc.ParamsInput[i];
        prmType := GetParamType(param);
        prmName := FormatParamName(param.Name);

        ResultCode.Add(Format('procedure %s.Set%s(const Value: %s);', [ProcName, prmName, prmType]));
        ResultCode.Add('begin');
        ResultCode.Add(Format('  F%S.Assign(Value);', [prmName]));
        ResultCode.Add('end;');
        ResultCode.Add('');
      end;

    /// //////////////////////////////////////////
    ResultCode.Add('');
  end;
end;

procedure TzStoredProcCodeFactory.WriteEndUnit;
begin
  ResultCode.Add('end.');
end;

end.

  zsystemfrm zMetadata.
