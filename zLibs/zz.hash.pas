unit zz.hash;

interface

function MD5(const s: String): string;

function SHA1(const s: String): string;

implementation

uses
  IdGlobal,
  IdHash,
  IdHashMessageDigest,
  IdHashSHA;

function MD5(const s: String): string;
var
  hashMessageDigest5: TIdHashMessageDigest5;
begin
  hashMessageDigest5 := nil;
  try
    hashMessageDigest5 := TIdHashMessageDigest5.Create;
    Result := IdGlobal.IndyLowerCase(hashMessageDigest5.HashStringAsHex(s));
  finally
    hashMessageDigest5.Free;
  end;
end;

function SHA1(const s: String): string;
var
  SHA1: TIdHashSHA1;
begin
  SHA1 := TIdHashSHA1.Create;
  try
    Result := SHA1.HashStringAsHex(s);
  finally
    SHA1.Free;
  end;
end;

end.
