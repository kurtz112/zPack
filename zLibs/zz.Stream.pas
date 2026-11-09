unit zz.Stream;

interface

uses
  system.sysUtils,
  system.Classes,
  Web.HTTPApp;

procedure ReadStreamFromRequest(Request: TWebRequest; Stream: TStream);

procedure EncodeStream(Stream: TMemoryStream);
procedure DecodeStream(Stream: TMemoryStream);

procedure CompressStream(Stream: TMemoryStream);
procedure DecompressStream(Stream: TMemoryStream);

procedure CompressAndEncode(InputStream, OutputStream: TStream);

procedure DecompressAndDecode(InputStream, OutputStream: TStream; const Decompress: boolean = false; const Decode: boolean = false; const FileName: string = ''); overload;
procedure DecompressAndDecode(ARequest: TWebRequest; OutputStream: TStream; const Decompress: boolean = false; const Decode: boolean = false; const FileName: string = '')overload;

procedure DumpStream(Stream: TStream; FileName: String);

implementation

uses
  system.ZLib,
  system.NetEncoding,
  system.Math,
  system.IOUtils,
  zz.SmartInspect;

procedure oldReadStreamFromRequest(Request: TWebRequest; Stream: TStream);
var
  BytesRead, ContentLength: integer;
  Buffer: array [0 .. 1023] of Byte;
begin
  if Stream is TMemoryStream then
    TMemoryStream(Stream).Clear;

  siMain.LogInteger('Request.ContentLength', Request.ContentLength);
  ContentLength := Request.ContentLength;

  while ContentLength > 0 do
  begin
    BytesRead := Request.ReadClient(Buffer[0], Min(ContentLength, SizeOf(Buffer)));

    siMain.LogInteger('BytesRead', BytesRead);
    if BytesRead < 1 then
      Break;

    Stream.WriteBuffer(Buffer[0], BytesRead);
    Dec(ContentLength, BytesRead);
  end;

  Stream.Position := 0;
end;

procedure ReadStreamFromRequest(Request: TWebRequest; Stream: TStream);
var
  TotalBytesRead, BytesRead: integer;
  Buffer: TBytes;
  tmpStream: TMemoryStream;
begin
  if Stream is TMemoryStream then
    TMemoryStream(Stream).Clear;

  siMain.LogInteger('Request.ContentLength', Request.ContentLength);

  if Request.ContentLength = 0 then
    Exit;

  // content contiene i primi x bytes
  if Request.Content.Length < Request.ContentLength then
  begin
    siMain.LogVerbose('BytesRead < Request.ContentLength');

    SetLength(Buffer, Request.ContentLength);
    TotalBytesRead := Request.Content.Length;
    Stream.Write(Request.RawContent[0], TotalBytesRead);

    repeat

      if Request.ContentLength - TotalBytesRead > 0 then
      begin
        BytesRead := Request.ReadClient(Buffer[0], Request.ContentLength - TotalBytesRead);

        if BytesRead > 0 then
        begin
          Stream.Write(Buffer[0], BytesRead);
          Inc(TotalBytesRead, BytesRead);
        end;
      end
      else
        BytesRead := -1;

    until BytesRead = -1;
  end
  else
  begin
    siMain.LogVerbose('Stream.Write(Request.RawContent[1], BytesRead);');
    Stream.Write(Request.RawContent[0], Request.Content.Length);
  end;

  Stream.Position := 0;
end;

procedure CompressAndEncode(InputStream, OutputStream: TStream);
var
  tmpStream: TStream;
begin
  Assert(Assigned(InputStream));
  Assert(Assigned(OutputStream));

  tmpStream := TMemoryStream.Create;
  try
    // compressione
    InputStream.Position := 0;
    ZCompressStream(InputStream, tmpStream);
    /// ////////////////////
    /// base64
    tmpStream.Position := 0;
    TNetEncoding.Base64.Encode(tmpStream, OutputStream);
    //
    OutputStream.Position := 0;
  finally
    FreeAndNil(tmpStream);
  end;
end;

procedure DecompressAndDecode(InputStream, OutputStream: TStream; const Decompress: boolean = false; const Decode: boolean = false; const FileName: string = '');
var
  tmpStream: TStream;
begin
  Assert(Assigned(InputStream));
  Assert(Assigned(OutputStream));

  tmpStream := TMemoryStream.Create;
  try
    // base 64
    InputStream.Position := 0;

    if Decode then
      TNetEncoding.Base64.Decode(InputStream, tmpStream)
    else
      tmpStream.CopyFrom(InputStream, InputStream.size);

    tmpStream.Position := 0;

    /// /////////////////////////

    if not FileName.IsEmpty then
      DumpStream(tmpStream, ChangeFileExt(FileName, '.base64'));

    /// /////////////////////////
    // decompressione
    if Decompress and (tmpStream.size > 0) then
    begin
      ZDecompressStream(tmpStream, OutputStream);

      if not FileName.IsEmpty then
        DumpStream(OutputStream, ChangeFileExt(FileName, '.decompress'));
    end
    else
      OutputStream.CopyFrom(tmpStream, tmpStream.size);
    //
    OutputStream.Position := 0;
  finally
    FreeAndNil(tmpStream);
  end;
end;
//
//procedure DecompressAndDecode(ARequest: TWebRequest; OutputStream: TStream; const Decompress: boolean = false; const Decode: boolean = false; const FileName: string = '');
//var
//  tmpStream: TStream;
//begin
//  Assert(Assigned(ARequest));
//  Assert(Assigned(OutputStream));
//  ReadStreamFromRequest(ARequest, OutputStream, Decompress, Decode);
//end;

procedure DecompressAndDecode(ARequest: TWebRequest; OutputStream: TStream; const Decompress: boolean = false; const Decode: boolean = false; const FileName: string = '');
var
  tmpStream: TStream;
begin
  Assert(Assigned(ARequest));
  Assert(Assigned(OutputStream));

  tmpStream := TMemoryStream.Create;
  try
    ReadStreamFromRequest(ARequest, tmpStream);

    if not FileName.IsEmpty then
      DumpStream(tmpStream, ChangeFileExt(FileName, '.raw'));

    DecompressAndDecode(tmpStream, OutputStream, Decompress, Decode, FileName);
  finally
    FreeAndNil(tmpStream);
  end;
end;
procedure DumpStream(Stream: TStream; FileName: String);
var
  tmp: TStream;
begin
  siMain.LogString('DumpStream', FileName);

  if TFile.Exists(FileName) then
    TFile.Delete(FileName);

  if Stream.size = 0 then
  begin
    siMain.LogVerbose(FileName + ' Size=0');
    Exit;
  end;

  tmp := TFileStream.Create(FileName, fmCreate);
  try
    Stream.Position := 0;
    tmp.CopyFrom(Stream, Stream.size);
    Stream.Position := 0;
  finally
    tmp.Free;
  end;
end;

procedure EncodeStream(Stream: TMemoryStream);
var
  tmpStream: TStream;
begin
  Assert(Assigned(Stream));

  tmpStream := TMemoryStream.Create;
  try
    // base 64
    Stream.Position := 0;
    TNetEncoding.Base64.Decode(Stream, tmpStream);
    tmpStream.Position := 0;

    Stream.Clear;
    Stream.CopyFrom(tmpStream, tmpStream.size);
    Stream.Position := 0;
  finally
    FreeAndNil(tmpStream);
  end;
end;

procedure DecodeStream(Stream: TMemoryStream);
var
  tmpStream: TStream;
begin
  Assert(Assigned(Stream));

  tmpStream := TMemoryStream.Create;
  try
    // base 64
    Stream.Position := 0;
    TNetEncoding.Base64.Encode(Stream, tmpStream);
    tmpStream.Position := 0;

    Stream.Clear;
    Stream.CopyFrom(tmpStream, tmpStream.size);
    Stream.Position := 0;
  finally
    FreeAndNil(tmpStream);
  end;
end;

procedure CompressStream(Stream: TMemoryStream);
var
  tmpStream: TStream;
begin
  Assert(Assigned(Stream));

  tmpStream := TMemoryStream.Create;
  try
    // base 64
    Stream.Position := 0;
    ZCompressStream(Stream, tmpStream);
    tmpStream.Position := 0;

    Stream.Clear;
    Stream.CopyFrom(tmpStream, tmpStream.size);
    Stream.Position := 0;
  finally
    FreeAndNil(tmpStream);
  end;
end;

procedure DecompressStream(Stream: TMemoryStream);
var
  tmpStream: TStream;
begin
  Assert(Assigned(Stream));

  tmpStream := TMemoryStream.Create;
  try
    // base 64
    Stream.Position := 0;
    ZDecompressStream(Stream, tmpStream);
    tmpStream.Position := 0;

    Stream.Clear;
    Stream.CopyFrom(tmpStream, tmpStream.size);
    Stream.Position := 0;
  finally
    FreeAndNil(tmpStream);
  end;
end;

end.
