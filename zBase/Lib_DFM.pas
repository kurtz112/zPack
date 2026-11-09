unit Lib_DFM;

interface

uses
  SysUtils,
  TypInfo,
  RTLConsts,
  Classes;

procedure ComponentToDFM(Component: TComponent; FileName: string);
//function ObjectBinaryToXML(Input: TStream): IXMLDocument;

implementation

procedure ComponentToDFM(Component: TComponent; FileName: string);
var
  FileStream: TFileStream;
  TempStream: TMemoryStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try

    TempStream := TMemoryStream.Create;
    try
      TempStream.WriteComponent(Component);
      TempStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(TempStream, FileStream);
    finally
      TempStream.Free;
    end;

  finally
    FileStream.Free;
  end;
end;

{
function ObjectBinaryToXML(Input: TStream): IXMLDocument;
var
  Reader: TReader;
  ObjectName, PropName: string; //for error reporting

  procedure ConvertProperty(const Parent: IXMLNode); forward;

  procedure ConvertValue(Current: IXMLNode; Independence: Boolean);

    function ConvertBinary: string;
    const
      BytesPerLine = 32;
    var
      I: Integer;
      Count: Longint;
      Buffer: array[0..BytesPerLine - 1] of Char;
      Text: array[0..BytesPerLine * 2 - 1] of Char;
      Temp: string;
    begin
      Reader.ReadValue;
      Reader.Read(Count, SizeOf(Count));
      Result := '';
      while Count > 0 do
      begin
        if Count > BytesPerLine then I := BytesPerLine else I := Count;
        Reader.Read(Buffer, I);
        BinToHex(Buffer, Text, I);
        SetString(Temp, Text, I * 2);
        Result := Result + Temp;
        Dec(Count, I);
        if Count > 0 then Result := Result + SLineBreak;
      end;
    end;

    function ConvertSet: string;
    var
      S: string;
    begin
      Reader.ReadValue;
      Result := '';
      while True do
      begin
        S := Reader.ReadStr;
        if S = '' then Break;
        if Result <> '' then Result := Result + ', ';
        Result := Result + S;
      end;
    end;

    procedure ConvertDate;
    var
      D: TDateTime;
    begin
      D := Reader.ReadDate;
      Current.Attributes['value'] := FloatToStr(D);
      Current.Attributes['date'] := DateTimeToStr(D);
    end;

    procedure ConvertCollection;
    var
      Item: IXMLNode;
    begin
      Reader.ReadValue;
      while not Reader.EndOfList do
      begin
        Item := Current.AddChild('item');
        if Reader.NextValue in [vaInt8, vaInt16, vaInt32] then
          Item.Attributes['id'] := Reader.ReadInteger;
        Reader.CheckValue(vaList);
        while not Reader.EndOfList do ConvertProperty(Item);
        Reader.ReadListEnd;
      end;
      Reader.ReadListEnd;
    end;

    procedure SetType(const s: string);
    begin
      if Independence then
      begin
        if s <> '' then
          Current := Current.AddChild(s)
        else
          Current := Current.AddChild('ident')
      end
      else if s <> '' then
        Current.Attributes['type'] := s;
    end;

  begin
    case Reader.NextValue of
    vaList:
    begin
      SetType('list');
      Reader.ReadValue;
      while not Reader.EndOfList do
        ConvertValue(Current, True);
      Reader.ReadListEnd;
    end;
    vaInt8, vaInt16, vaInt32:
    begin
      SetType('integer');
      Current.Attributes['value'] := IntToStr(Reader.ReadInteger);
    end;
    vaInt64:
    begin
      SetType('integer');
      Current.Attributes['value'] := IntToStr(Reader.ReadInt64);
    end;
    vaExtended:
    begin
      SetType('real');
      Current.Attributes['value'] := FloatToStr(Reader.ReadFloat);
    end;
    vaSingle:
    begin
      SetType('real');
      Current.Attributes['precision'] := 'single';
      Current.Attributes['value'] := FloatToStr(Reader.ReadFloat);
    end;
    vaCurrency:
    begin
      SetType('real');
      Current.Attributes['precision'] := 'currency';
      Current.Attributes['value'] := CurrToStr(Reader.ReadCurrency);
    end;
    vaDate:
    begin
      SetType('real');
      Current.Attributes['precision'] := 'date';
      ConvertDate;
    end;
    vaWString, vaUTF8String:
    begin
      SetType('string');
      Current.Attributes['value'] := Reader.ReadWideString;
    end;
    vaString, vaLString:
    begin
      SetType('string');
      Current.Attributes['charset'] := 'locale';
      Current.Attributes['value'] := Reader.ReadString;
    end;
    vaIdent, vaFalse, vaTrue, vaNil, vaNull:
    begin
      SetType('');
      Current.Attributes['value'] := Reader.ReadIdent;
    end;
    vaBinary:
    begin
      SetType('binary');
      Current.Text := ConvertBinary
    end;
    vaSet:
    begin
      SetType('set');
      Current.Attributes['value'] := ConvertSet;
    end;
    vaCollection:
    begin
      SetType('collection');
      ConvertCollection;
    end;
    else
      raise EReadError.CreateFmt(sPropertyException,
        [ObjectName, DotSep, PropName, IntToStr(Ord(Reader.NextValue))]);
    end;
  end;

  procedure ConvertProperty(const Parent: IXMLNode);
  var
    Current: IXMLNode;
  begin
    PropName := Reader.ReadStr;
    Current := Parent.AddChild(PropName);
    ConvertValue(Current, False);
  end;

  procedure ConvertObject(const Parent: IXMLNode);
  var
    Current: IXMLNode;
    ClassName: string;
    Flags: TFilerFlags;
    Position: Integer;
  begin
    Current := Parent.AddChild('object');

    Reader.ReadPrefix(Flags, Position);
    ClassName := Reader.ReadStr;
    ObjectName := Reader.ReadStr;

    if ObjectName <> '' then
      Current.Attributes['name'] := ObjectName;

    Current.Attributes['class'] := ClassName;

    if ffInherited in Flags then
      Current.Attributes['kind'] := 'inherited'
    else if ffInline in Flags then
      Current.Attributes['kind'] := 'inline';

    if ffChildPos in Flags then
      Current.Attributes['position'] := IntToStr(Position);

    while not Reader.EndOfList do ConvertProperty(Current);
    Reader.ReadListEnd;
    while not Reader.EndOfList do ConvertObject(Current);
    Reader.ReadListEnd;
  end;

var
  SaveSeparator: Char;
begin
  Reader := TReader.Create(Input, 4096);
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Result := NewXMLDocument;
    Result.Encoding := 'UTF-8';
    Reader.ReadSignature;
    ConvertObject(Result.AddChild('dfm'));
  finally
    DecimalSeparator := SaveSeparator;
    Reader.Free;
  end;
end;
}
end.

