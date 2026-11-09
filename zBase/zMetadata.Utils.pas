unit zMetadata.Utils;

interface

uses
  DB;

const
  RDB_VARCHAR = 37;
  RDB_VARCHAR2 = 38;
  RDB_CSTRING = 40;
  RDB_CSTRING2 = 41;
  RDB_CHAR = 14;
  RDB_CHAR2 = 15;
  RDB_D_FLOAT = 11;
  RDB_DOUBLE = 27;
  RDB_FLOAT = 10;
  RDB_INT64 = 16;
  RDB_QUAD = 9;
  RDB_BLOB_ID = 45;
  RDB_INTEGER = 8;
  RDB_SMALLINT = 7;
  RDB_DATE = 12;
  RDB_TIME = 13;
  RDB_TIMESTAMP = 35;
  RDB_BOOLEAN = 17;
  RDB_BLOB = 261;
  //
  CS_NONE = 0;
  CS_BINARY = 1;
  CS_ASCII = 2;
  CS_UNICODE_FSS = 3;
  CS_METADATA = CS_UNICODE_FSS;
  //
  RDB_BLOB_NONE = 0;
  RDB_BLOB_TEXT = 1;
  RDB_BLOB_BLR = 2;
  RDB_BLOB_ACL = 3;
  RDB_BLOB_RESERVED = 4;
  RDB_BLOB_ENCODED = 5;
  RDB_BLOB_DESCRIPTION = 6;
  RDB_NUMBERS_NONE = 0;
  RDB_NUMBERS_NUMERIC = 1;
  RDB_NUMBERS_DECIMAL = 2;

type
  TZSQLType = (stUnknown, stBoolean, stByte, stShort, stInteger, stLong, stFloat, stDouble, stBigDecimal, stString, stUnicodeString, stBytes, stDate, stTime, stTimestamp,
    stAsciiStream, stUnicodeStream, stBinaryStream);

function GetDataType(const SqlType, SqlSubType: Integer): TFieldType;
function GetFirebirdDataType(const SqlType, SqlSubType, FieldLength, Precision, Scale, SegmentLength: Integer): string;

implementation

uses
  SysUtils;

function GetDataType(const SqlType, SqlSubType: Integer): TFieldType;

  function ConvertSqlType2DataType(Value: TZSQLType): TFieldType;
  begin
    case Value of
      stBoolean:
        Result := ftBoolean;
      stByte, stShort:
        Result := ftSmallInt;
      stInteger:
        Result := ftInteger;
      stLong:
        Result := ftLargeInt;
      stFloat, stDouble, stBigDecimal:
        Result := ftFloat;
      stString:
        Result := ftString;
      stBytes:
        Result := ftBytes;
      stDate:
        Result := ftDate;
      stTime:
        Result := ftTime;
      stTimestamp:
        Result := ftDateTime;
      stAsciiStream:
        Result := ftMemo;
      stBinaryStream:
        Result := ftBlob;
      stUnicodeString, stUnicodeStream:
        Result := ftWideString;
    else
      Result := ftUnknown;
    end;
  end;

  function ConvertFireBirdToSqlType(SqlType, SqlSubType: Integer): TZSQLType;
  begin
    Result := stUnknown;

    case SqlType of
      23:
        Result := stBoolean;
      RDB_BOOLEAN:
        Result := stBoolean;
      RDB_VARCHAR2, RDB_VARCHAR, RDB_CSTRING, RDB_CSTRING2:
        Result := stString;
      RDB_CHAR, RDB_CHAR2:
        begin
          case SqlSubType of
            CS_NONE:
              Result := stString;
            CS_BINARY:
              Result := stBytes;
            CS_ASCII:
              Result := stString;
            CS_UNICODE_FSS:
              Result := stUnicodeString;
          end;
        end;
      RDB_D_FLOAT:
        Result := stDouble;
      RDB_DOUBLE:
        Result := stDouble;
      RDB_FLOAT:
        Result := stFloat;
      RDB_BLOB_ID, RDB_QUAD:
        Result := stLong;
      RDB_INT64:
        begin
          case SqlSubType of
            RDB_NUMBERS_NONE:
              Result := stLong;
            RDB_NUMBERS_NUMERIC:
              Result := stDouble;
            RDB_NUMBERS_DECIMAL:
              Result := stBigDecimal;
          end;
        end;
      RDB_INTEGER:
        begin
          case SqlSubType of
            RDB_NUMBERS_NONE:
              Result := stInteger;
            RDB_NUMBERS_NUMERIC:
              Result := stDouble;
            RDB_NUMBERS_DECIMAL:
              Result := stBigDecimal;
          end;
        end;
      RDB_SMALLINT:
        begin
          case SqlSubType of
            RDB_NUMBERS_NONE:
              Result := stShort;
            RDB_NUMBERS_NUMERIC:
              Result := stFloat;
            RDB_NUMBERS_DECIMAL:
              Result := stDouble;
          end;
        end;
      RDB_DATE:
        Result := stDate;
      RDB_TIME:
        Result := stTime;
      RDB_TIMESTAMP:
        Result := stTimestamp;
      RDB_BLOB:
        begin
          case SqlSubType of
            RDB_BLOB_NONE:
              Result := stBinaryStream;
            RDB_BLOB_TEXT:
              Result := stAsciiStream;
            RDB_BLOB_BLR:
              Result := stBinaryStream;
            RDB_BLOB_ACL:
              Result := stAsciiStream;
            RDB_BLOB_RESERVED:
              Result := stUnknown;
            RDB_BLOB_ENCODED:
              Result := stAsciiStream;
            RDB_BLOB_DESCRIPTION:
              Result := stAsciiStream;
          end;
        end;
    else
      Result := stUnknown;
    end;
  end;

var
  zSQLType: TZSQLType;
begin
  Result := ftUnknown;
  zSQLType := ConvertFireBirdToSqlType(SqlType, SqlSubType);
  Result := ConvertSqlType2DataType(zSQLType);
end;

function GetFirebirdDataType(const SqlType, SqlSubType, FieldLength, Precision, Scale, SegmentLength: Integer): string;
  function FormatNumeric(Precision, Scale: Integer): string;
  begin
    Result := IntToStr(Precision) + ',' + IntToStr(Abs(Scale));
  end;

begin
  // 007	SHORT
  // 008	LONG
  // 010	FLOAT
  // 012	DATE
  // 013	TIME
  // 014	TEXT
  // 016	INT64
  // 023	BOOLEAN
  // 027	DOUBLE
  // 035	TIMESTAMP
  // 037	VARYING
  // 261	BLOB

  Result := '<unknown>';

  case SqlType of
    RDB_SMALLINT:
      Result := 'SMALLINT';
    RDB_INTEGER:
      begin
        if SqlSubType = 0 then
          Result := 'INTEGER'
        else
          Result := 'NUMERIC(' + FormatNumeric(Precision, Scale) + ')';
      end;

    RDB_FLOAT:
      Result := 'FLOAT';
    RDB_DATE:
      Result := 'DATE';
    RDB_TIME:
      Result := 'TIME';
    RDB_CHAR:
      Result := 'CHAR(' + IntToStr(FieldLength div 4) + ')';
    RDB_INT64:
      begin
        if SqlSubType = 0 then
          Result := 'BIGINT'
        else
          Result := 'NUMERIC(' + FormatNumeric(Precision, Scale) + ')';
      end;
    RDB_BOOLEAN:
      Result := 'BOOLEAN';
    RDB_DOUBLE:
      Result := 'DOUBLE PRECISION';
    RDB_TIMESTAMP:
      Result := 'TIMESTAMP';
    RDB_VARCHAR:
      Result := 'VARCHAR(' + IntToStr(FieldLength div 4) + ')';
    RDB_BLOB:
      Result := 'BLOB SUB_TYPE ' + IntToStr(SqlSubType) + ' SEGMENT SIZE ' + IntToStr(SegmentLength);
  end;
end;

end.
