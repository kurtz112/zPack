unit zz.JSON;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.RTTI,
  System.JSON;

Type
  TObjectHelper = class helper for TObject
  public
    class function Decode<T: class, constructor>(Obj: T; JsonObject: TJsonObject): T;
    function Encode: TJsonObject;
    function ToJSON: String;
  end;

  TJSON = class
  public
    class function CreateObject<T: class, constructor>(RttiContext: TRttiContext): T;
  public
    class function Decode<T: class, constructor>(Obj: T; JsonObject: TJsonObject): T; overload;
    class function Decode<T: class, constructor>(Obj: T; const JSON: string): T; overload;
    class function DecodeValue(RttiContext: TRttiContext; RttiType: TRttiType; JSONValue: TJSONValue): TValue;

    class function EncodeValue(RttiContext: TRttiContext; RttiType: TRttiType; Value: TValue): TJSONValue;
    class function Encode(Obj: TObject): TJsonObject;
    class function ToJSON(Obj: TObject): string;
  end;

implementation

uses
  System.Variants;

/// /////////////////////////////////////////////////////////

class function TObjectHelper.Decode<T>(Obj: T; JsonObject: TJsonObject): T;
begin
  Result := TJSON.Decode<T>(Obj, JsonObject);
end;

function TObjectHelper.Encode: TJsonObject;
begin
  Result := TJSON.Encode(Self);
end;

function TObjectHelper.ToJSON: String;
begin
  Result := TJSON.ToJSON(Self);
end;

/// /////////////////////////////////////////////////////////
///
class function TJSON.EncodeValue(RttiContext: TRttiContext; RttiType: TRttiType; Value: TValue): TJSONValue;
var
  Obj: TObject;
  v: Variant;
  r: TRttiRecordType;
  rType: TRttiType;
  f: TRttiField;
  FieldName: string;
  i: Integer;
  subValue: TJSONValue;
begin
  Result := nil;

  if Value.IsEmpty then
    Result := TJSONNull.Create
  else
  begin
    case RttiType.TypeKind of
      tkString, tkWChar, tkLString, tkWString, tkChar, tkUString:
        Result := TJSONString.Create(Value.AsString);
      tkInteger:
        Result := TJSONNumber.Create(Value.AsInteger);
      tkInt64:
        Result := TJSONNumber.Create(Value.AsInt64);
      tkFloat:
        begin
          if (Value.TypeInfo = TypeInfo(TDate)) then
            Result := TJSONString.Create(DateToStr(Value.AsExtended))
          else
            if (Value.TypeInfo = TypeInfo(TDateTime)) then
              Result := TJSONString.Create(DateTimeToStr(Value.AsExtended))
            else
              Result := TJSONNumber.Create(Value.AsExtended);
        end;
      tkEnumeration:
        begin
          if Value.IsType<boolean> then
            Result := TJSONBool.Create(Value.AsBoolean)
          else
            Result := TJSONString.Create(Value.ToString);
        end;
      tkSet:
        begin
          Result := TJSONString.Create(Value.ToString);
        end;
      tkVariant:
        begin
          v := Value.AsVariant;

          if VarIsNull(v) or VarIsEmpty(v) then
            Result := TJSONNull.Create
          else
            Result := TJSONString.Create(VarToStr(v))
        end;
      tkRecord:
        begin
          rType := RttiContext.GetType(Value.TypeInfo);
          r := rType.AsRecord;

          Result := TJsonObject.Create;

          for f in r.GetFields do
          begin
            FieldName := f.Name;

            subValue := EncodeValue(RttiContext, f.FieldType, f.GetValue(r));

            if assigned(subValue) then
              TJsonObject(Result).AddPair(f.Name, subValue);
          end;
        end;

      tkClass:
        begin
          if RttiType.IsInstance then
          begin
            Obj := Value.AsObject;
            Result := Encode(Obj);
          end;
        end;
      tkArray, tkDynArray:
        begin

          Result := TJSONArray.Create;

          for i := 0 to Value.GetArrayLength - 1 do
          begin
            subValue := EncodeValue(RttiContext, RttiType, Value.GetArrayElement(i));
            TJSONArray(Result).AddElement(subValue);
          end;
        end;

      tkMethod: // skip
        ;
      tkInterface: // skip
        ;
      tkClassRef: // skip
        ;
      tkPointer: // skip
        ;
      tkProcedure: // skip
        ;
    else
      raise Exception.Create('Encode: Property ' + RttiType.ToJSON + ' - ' + TRttiEnumerationType.GetName(Value.TypeInfo^.Kind));
    end;
  end;
end;

class function TJSON.Encode(Obj: TObject): TJsonObject;
var
  RttiContext: TRttiContext;
  This: TRttiType;
  prop: TRttiProperty;
  Value: TValue;
  JSONValue: TJSONValue;
begin
  RttiContext := TRttiContext.Create;
  try
    This := RttiContext.GetType(Obj.ClassInfo);

    Result := TJsonObject.Create;

    for prop in This.GetProperties do
      if prop.Visibility = mvPublished then
        if prop.IsWritable then
        begin
          Value := prop.GetValue(Obj);
          JSONValue := EncodeValue(RttiContext, prop.PropertyType, Value);

          if assigned(JSONValue) then
            Result.AddPair(prop.Name, JSONValue);
        end;
  finally
    RttiContext.Free;
  end;
end;

class function TJSON.ToJSON(Obj: TObject): string;
var
  j: TJsonObject;
begin
  Result := '';

  j := Encode(Obj);
  try
    if assigned(j) then
      Result := j.Format();
  finally
    j.Free;
  end;
end;

class function TJSON.CreateObject<T>(RttiContext: TRttiContext): T;
var
  This: TRttiType;
  Method: TRttiMethod;
  metaClass: TClass;
begin
  Result := nil;

  This := RttiContext.GetType(TypeInfo(T));

  if assigned(This) then
    for Method in This.GetMethods do
      if Method.HasExtendedInfo and Method.IsConstructor then
        if Length(Method.GetParameters) = 0 then
        begin
          metaClass := This.AsInstance.MetaclassType;
          Result := T(Method.Invoke(metaClass, []).AsObject);
          Exit;
        end;
end;

class function TJSON.Decode<T>(Obj: T; const JSON: string): T;
var
  JsonObject: TJsonObject;
begin
  JsonObject := TJsonObject.ParseJSONValue(JSON) as TJsonObject;
  try
    Result := Decode<T>(Obj, JsonObject);
  finally
    FreeAndNil(JsonObject);
  end;
end;

class function TJSON.Decode<T>(Obj: T; JsonObject: TJsonObject): T;
var
  RttiContext: TRttiContext;
  This: TRttiType;
  prop: TRttiProperty;
  JSONValue: TJSONValue;
  Value: TValue;
  s: string;
begin

  RttiContext := TRttiContext.Create;
  try
    Result := Obj;

    if not assigned(Result) then
      Result := CreateObject<T>(RttiContext);

    This := RttiContext.GetType(Result.ClassInfo);

    for prop in This.GetProperties do
      if prop.Visibility = mvPublished then
        if prop.IsWritable then
        begin
          JSONValue := JsonObject.GetValue(prop.Name);
          Value := DecodeValue(RttiContext, prop.PropertyType, JSONValue);

          // prop.SetValue(Self, Value);
          // if Value <> nil then
          // prop.SetValue(@Result, Value);
        end;
  finally
    RttiContext.Free;
  end;
end;

class function TJSON.DecodeValue(RttiContext: TRttiContext; RttiType: TRttiType; JSONValue: TJSONValue): TValue;
var
  i: Integer;
  s: string;
begin
  Result := nil;;

  if JSONValue is TJSONNull then
    Result := TValue.Empty
  else
  begin
    case RttiType.TypeKind of

      tkString, tkWChar, tkLString, tkWString, tkChar, tkUString:
        begin
          s := TJSONString(JSONValue).ToString;
          Result := TValue(s);
        end;
      tkInteger:
        Result := TValue(TJSONNumber(JSONValue).AsInt);
      tkInt64:
        Result := TValue(TJSONNumber(JSONValue).AsInt64);
      tkFloat:
        begin
          if JSONValue is TJSONNumber then
            Result := TValue(TJSONNumber(JSONValue).AsDouble)
          else
            if JSONValue is TJSONString then
            begin
              s := TJSONString(JSONValue).ToString;

              if (RttiType.Handle = TypeInfo(TDate)) then
                Result := StrToDate(s)
              else
                if (RttiType.Handle = TypeInfo(TDateTime)) then
                  Result := StrToDateTime(s)
                else
                  Result := strToFloat(s);
            end
        end;
      tkEnumeration:
        begin
          if JSONValue IS TJSONBool then
            Result := TValue(TJSONBool(JSONValue).AsBoolean)
          else
            if JSONValue is TJSONString then
            begin
              s := TJSONString(JSONValue).ToString;
              Result := TValue.FromOrdinal(RttiType.Handle, GetEnumValue(RttiType.Handle, s));
            end;
        end;
      tkSet:
        begin
          s := TJSONString(JSONValue).ToString;
          i := StringToSet(RttiType.Handle, s);
          TValue.Make(@i, RttiType.Handle, Result);
        end;
      tkVariant:
        begin
          s := TJSONString(JSONValue).ToString;
          Result := TValue.FromVariant(s);
        end;
      tkArray, tkDynArray:
        begin
        end;
      tkRecord:
        begin
        end;
      tkClass:
        begin
          // if prop.PropertyType.IsInstance then
          // if JSONValue is TJSONArray then
          // begin
          // Obj := prop.GetValue(Self).AsObject;

          // if obj is TJSONCollection then
          // begin
          // TJSONCollection(obj).Decode(JSONValue as TJSONArray);
          // Continue; // salta l'assegnazione
          // end;
        end;
      tkMethod:
        ; // skip
      tkInterface:
        ; // skip
      tkClassRef:
        ; // skip
      tkPointer:
        ; // skip
      tkProcedure:
        ; // skip
      tkMRecord:
        ; // skip
      // else
      // raise Exception.Create('Decode: Property ' + prop.Name + ' - ' + TRttiEnumerationType.GetName(Result.TypeInfo^.Kind));
    end;
  end;
end;

end.
