unit RTTI_Lib;

{ Don't forget to check out Danny Thorpe's
  book for much more info on RTTI:

  Delphi Component Design, Addison-Wesley, 1996 }

interface

uses
  SysUtils;

procedure SetDefaults(Obj: TObject);

procedure CopyObject(ObjFrom, ObjTo: TObject);

type
  EPropertyError = class(Exception);

implementation

uses
  TypInfo,
  Forms;

const
  NoDefault = -MaxLongint - 1;
  tkPropsWithDefault = [tkInteger, tkChar, tkSet, tkEnumeration];

procedure SetDefaults(Obj: TObject);
var
  PropInfos: PPropList;
  Count, Loop: Integer;
  MethodVal: TMethod;
begin
  { Find out how many properties we'll be considering }
//  Count := GetPropList(Obj.ClassInfo, tkPropsWithDefault, nil);
  Count := GetPropList(Obj.ClassInfo, tkAny, nil);
  { Allocate memory to hold their RTTI data }
  GetMem(PropInfos, Count * SizeOf(PPropInfo));
  try
    { Get hold of the property list in our new buffer }
//    GetPropList(Obj.ClassInfo, tkPropsWithDefault, PropInfos);
    GetPropList(Obj.ClassInfo, tkAny, PropInfos);

    { Loop through all the selected properties }
    for Loop := 0 to Count - 1 do
    begin
      { If there is supposed to be a default value... }
      if PropInfos^[Loop]^.Default <> NoDefault then
        { ...then jolly well set it }
        SetOrdProp(Obj, PropInfos^[Loop], PropInfos^[Loop]^.Default)
      else
      begin
        case PropInfos^[Loop]^.PropType^.Kind of
          tkInteger: SetOrdProp(Obj, PropInfos^[Loop]^.Name, -1);
          tkInt64: SetInt64Prop(Obj, PropInfos^[Loop]^.Name, -1);
          tkFloat: SetFloatProp(Obj, PropInfos^[Loop]^.Name, 0);
          tkEnumeration, tkSet: SetOrdProp(Obj, PropInfos^[Loop]^.Name, 0);
          tkWChar,
            tkLString,
            tkWString,
            tkString,
            tkChar:
            begin
              { Avoid copying 'Name' - components must have unique names }
              if SameText(PropInfos^[Loop]^.Name, 'Name') then
                Continue;
              SetStrProp(Obj, PropInfos^[Loop]^.Name, '');
            end;
          tkMethod:
            begin
              MethodVal := GetMethodProp(Obj, PropInfos^[Loop]);
              MethodVal.Code := nil;
              MethodVal.Data := nil;
              SetMethodProp(Obj, PropInfos^[Loop]^.Name, MethodVal);
            end;
          tkClass,
            tkVariant,
            tkArray,
            tkRecord,
            tkInterface,
            tkDynArray:
            begin
            end;
        end
      end
    end;
  finally
    FreeMem(PropInfos, Count * SizeOf(PPropInfo));
  end;
end;

procedure CopyObject(ObjFrom, ObjTo: TObject);
var
  PropInfos: PPropList;
  PropInfo: PPropInfo;
  Count, Loop: Integer;
  OrdVal: Longint;
  StrVal: string;
  FloatVal: Extended;
  MethodVal: TMethod;
begin
  { Iterate thru all published fields and properties of source }
  { copying them to target }

  { Find out how many properties we'll be considering }
  Count := GetPropList(ObjFrom.ClassInfo, tkAny, nil);
  { Allocate memory to hold their RTTI data }
  GetMem(PropInfos, Count * SizeOf(PPropInfo));
  try
    { Get hold of the property list in our new buffer }
    GetPropList(ObjFrom.ClassInfo, tkAny, PropInfos);
    { Loop through all the selected properties }
    for Loop := 0 to Count - 1 do
    begin
      PropInfo := GetPropInfo(ObjTo.ClassInfo, PropInfos^[Loop]^.Name);
      { Check the general type of the property }
      { and read/write it in an appropriate way }
      case PropInfos^[Loop]^.PropType^.Kind of
        tkInteger, tkChar, tkEnumeration,
          tkSet, tkClass, tkWChar:
          begin
            OrdVal := GetOrdProp(ObjFrom, PropInfos^[Loop]);
            if Assigned(PropInfo) then
              SetOrdProp(ObjTo, PropInfo, OrdVal);
          end;
        tkFloat:
          begin
            FloatVal := GetFloatProp(ObjFrom, PropInfos^[Loop]);
            if Assigned(PropInfo) then
              SetFloatProp(ObjTo, PropInfo, FloatVal);
          end;
        tkWString,
          tkLString,
          tkString:
          begin
            { Avoid copying 'Name' - components must have unique names }
            if UpperCase(PropInfos^[Loop]^.Name) = 'NAME' then
              Continue;
            StrVal := GetStrProp(ObjFrom, PropInfos^[Loop]);
            if Assigned(PropInfo) then
              SetStrProp(ObjTo, PropInfo, StrVal);
          end;
        tkMethod:
          begin
            MethodVal := GetMethodProp(ObjFrom, PropInfos^[Loop]);
            if Assigned(PropInfo) then
              SetMethodProp(ObjTo, PropInfo, MethodVal);
          end
      end
    end
  finally
    FreeMem(PropInfos, Count * SizeOf(PPropInfo));
  end;
end;

end.

