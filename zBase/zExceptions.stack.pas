unit zExceptions.stack;

interface

uses
  System.SysUtils,
  System.classes;

type
  TCallStackItem = class(TCollectionItem)
  private
    FBaseName: string;
    FCallAddress: string;
    FLineNumber: integer;
    FRelLineNumber: integer;
    FSourceFile: string;
    FSymbolName: string;
    FUnitName: string;
  public
    constructor Create(Collection: TCollection); override;

    function Titles: string;
    function ToString: string; override;
  public
    property CallAddress: string read FCallAddress;
    property BaseName: string read FBaseName;
    property UnitName: string read FUnitName;
    property SourceFile: string read FSourceFile;
    property SymbolName: string read FSymbolName;
    property LineNumber: integer read FLineNumber;
    property RelLineNumber: integer read FRelLineNumber;
  end;

  TCallStack = class(TCollection)
  private type
    TCollectionEnumerator = class
    private
      index: integer;
      Collection: TCallStack;
    public
      constructor Create(ACollection: TCallStack);
      function GetCurrent: TCallStackItem;
      function MoveNext: Boolean;
      property Current: TCallStackItem read GetCurrent;
    end;
  public
    function GetEnumerator: TCollectionEnumerator; inline;
  private
    function GetItem(index: integer): TCallStackItem;
    procedure SetItem(index: integer; const Value: TCallStackItem);

    procedure ParseStackTraceJCL(e: Exception);
    procedure ParseStackTraceDebugEngine(e: Exception);
    procedure ParseStackTrace(e: Exception);
  public
    constructor Create(e: Exception);

    function Add: TCallStackItem;
    function Insert(index: integer): TCallStackItem;
    property Items[index: integer]: TCallStackItem read GetItem write SetItem; default;
  end;

implementation

uses
  JclDebug;

{ TCallStackItem }

constructor TCallStackItem.Create(Collection: TCollection);
begin
  inherited;
  FCallAddress := '';
  FBaseName := '';
  FUnitName := '';
  FSourceFile := '';
  FSymbolName := '';
  FLineNumber := 0;
  FRelLineNumber := 0;
end;

/// /////////////////////////////////////////////////////////////

constructor TCallStack.TCollectionEnumerator.Create(ACollection: TCallStack);
begin
  inherited Create;
  index := -1;
  Collection := ACollection;
end;

function TCallStack.TCollectionEnumerator.GetCurrent: TCallStackItem;
begin
  Result := Collection.Items[index] as TCallStackItem;
end;

function TCallStack.TCollectionEnumerator.MoveNext: Boolean;
begin
  Result := index < Collection.Count - 1;
  if Result then
    Inc(index);
end;

/// /////////////////////////////////////////////////////////////

constructor TCallStack.Create(e: Exception);
begin
  inherited Create(TCallStackItem);
  ParseStackTrace(e);
end;

function TCallStack.GetEnumerator: TCollectionEnumerator;
begin
  Result := TCollectionEnumerator.Create(Self);
end;

function TCallStack.Add: TCallStackItem;
var
  Item: TCollectionItem;
begin
  Item := inherited Add;
  Result := TCallStackItem(Item);
end;

function TCallStack.GetItem(index: integer): TCallStackItem;
begin
  Result := inherited Items[index] as TCallStackItem;
end;

function TCallStack.Insert(index: integer): TCallStackItem;
begin
  Result := inherited Insert(index) as TCallStackItem;
end;

procedure TCallStack.SetItem(index: integer; const Value: TCallStackItem);
begin
  Items[index].Assign(Value);
end;

procedure TCallStack.ParseStackTrace(e: Exception);
begin
  // ParseStackTraceDebugEngine(e);
  ParseStackTraceJCL(e);
end;

procedure TCallStack.ParseStackTraceDebugEngine(e: Exception);
var
  Item: TCallStackItem;
  StackTrace, Tokens: TStringList;
  s: String;
begin
  Clear;

  StackTrace := TStringList.Create;
  try
    StackTrace.text := e.StackTrace;

    Tokens := TStringList.Create;
    try
      Tokens.Delimiter := #9;

      for s in StackTrace do
      begin
        Tokens.delimitedText := s;

        Item := Add;
        Item.FCallAddress := Tokens[0];
        Item.FBaseName := Tokens[1];

        if Tokens.Count > 3 then
        begin
          Item.FUnitName := Tokens[2];

          if Tokens.Count > 4 then
          begin
            Item.FSourceFile := Tokens[3];
            Item.FLineNumber := Tokens[4].ToInteger();

            if Tokens.Count > 6 then
            begin
              Item.FRelLineNumber := Tokens[5].Replace('+', '').ToInteger();
              Item.FSymbolName := Tokens[6];
            end
            else
              Item.FSymbolName := Tokens[5];
          end;
        end;
      end;
    finally
      FreeAndNil(Tokens);
    end;
  finally
    FreeAndNil(StackTrace);
  end;
end;

procedure TCallStack.ParseStackTraceJCL(e: Exception);
var
  i: integer;
  List: TJclStackInfoList;
  Info: TJclLocationInfo;
  Item: TCallStackItem;
begin
  Clear;

  List := JclLastExceptStackList; // non e' da eliminare

  for i := 0 to List.Count - 1 do
  begin
    // Prima si aggiungeva l'item solo se GetLocationInfo riusciva a
    // risolvere l'indirizzo: un frame senza debug info spariva del tutto,
    // lasciando un "salto" invisibile nella catena di chiamata (es. tra il
    // click di un bottone e l'errore FireDAC, senza vedere quale metodo
    // applicativo ha invocato la query). Ora il frame si registra sempre:
    // se non risolvibile, si riporta almeno l'indirizzo raw, cosi' il buco
    // e' visibile invece che silenzioso.
    Item := Add;
    if GetLocationInfo(List.Items[i].CallerAddr, Info) then
    begin
      Item.FBaseName := Info.BinaryFileName;
      Item.FUnitName := Info.UnitName;
      Item.FSourceFile := Info.SourceName;
      Item.FSymbolName := Info.ProcedureName;
      Item.FLineNumber := Info.LineNumber;
      Item.FRelLineNumber := Info.OffsetFromLineNumber;
    end
    else
      Item.FSymbolName := '<non risolto: 0x' + IntToHex(NativeUInt(List.Items[i].CallerAddr), SizeOf(Pointer) * 2) + '>';
  end;
end;

function TCallStackItem.Titles: string;
begin
  // Result := 'SymbolName' + #9#9 + 'LineNumber' + #9#9 + 'RelLineNumber' + #9#9 + 'UnitName' + #9#9 + 'SourceFile' + #9#9 + 'BaseName';// + #9#9 + 'CallAddress';
  Result := 'SymbolName'.PadRight(70, ' ') + 'LineNumber'.PadRight(15, ' ') + 'RelLineNumber'.PadRight(15, ' ') + 'UnitName'.PadRight(35, ' ') + 'SourceFile'.PadRight(50, ' ');
end;

function TCallStackItem.ToString: string;
begin
  Result := SymbolName + #9#9 + LineNumber.ToString + #9#9 + RelLineNumber.ToString + #9#9 + UnitName + #9#9 + SourceFile + #9#9 + BaseName; // + #9#9 + CallAddress;
  Result := SymbolName.PadRight(70, ' ') + LineNumber.ToString.PadRight(15, ' ') + RelLineNumber.ToString.PadRight(15, ' ') + UnitName.PadRight(35, ' ') + SourceFile.PadRight(50, ' ');
  // BaseName.PadRight(50, ' ');
  // + #9#9 + CallAddress;
end;

initialization

// Enable raw mode (default mode uses stack frames which aren't always generated by the compiler)
Include(JclStackTrackingOptions, stRawMode);
// Disable stack tracking in dynamically loaded modules (it makes stack tracking code a bit faster)
Include(JclStackTrackingOptions, stStaticModuleList);

// Initialize Exception tracking
JclStartExceptionTracking;

finalization

// Uninitialize Exception tracking
JclStopExceptionTracking;

end.
