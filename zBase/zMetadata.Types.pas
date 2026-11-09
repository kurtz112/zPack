unit zMetadata.Types;

interface

uses
  System.SysUtils,
  zBaseLib;

type
  // Text     = T
  // Numeric  = N
  // Date     = D
  // Time     = H
  // DateTime = @
  // Boolean  = B
  // Picklist = P
  // Lookup   = L
  // Memo     = M
  // Image    = I

  TMetaEditorType = (metText, metNumeric, metDate, metTime, metDateTime, metBoolean, metPickList, metLookup, metMemo, metImage);

  TMetaEditorTypeHelper = record helper for TMetaEditorType
  private
    function GetAsString: string;
    function GetzCtrlType: TzCtrlType;
    procedure SetAsString(const Value: string);
  public
    property AsString: string read GetAsString write SetAsString;
    property zCtrlType: TzCtrlType read GetzCtrlType;
  end;

implementation

function TMetaEditorTypeHelper.GetAsString: string;
begin
  Result := '';

  case self of
    metText:
      Result := 'T';
    metNumeric:
      Result := 'N';
    metDate:
      Result := 'D';
    metTime:
      Result := 'H';
    metDateTime:
      Result := '@';
    metBoolean:
      Result := 'B';
    metPickList:
      Result := 'P';
    metLookup:
      Result := 'L';
    metMemo:
      Result := 'M';
    metImage:
      Result := 'I';
  end;
end;

procedure TMetaEditorTypeHelper.SetAsString(const Value: string);
begin

  if Value = 'T' then
    self := metText
  else
    if Value = 'N' then
      self := metNumeric
    else
      if Value = 'D' then
        self := metDate
      else
        if Value = 'H' then
          self := metTime
        else
          if Value = '@' then
            self := metDateTime
          else
            if Value = 'B' then
              self := metBoolean
            else
              if Value = 'P' then
                self := metPickList
              else
                if Value = 'L' then
                  self := metLookup
                else
                  if Value = 'M' then
                    self := metMemo
                  else
                    if Value = 'I' then
                      self := metImage;
end;

function TMetaEditorTypeHelper.GetzCtrlType: TzCtrlType;
begin
  Result := ctEdit;

  case self of
    metText:
      Result := ctEdit;
    metNumeric:
      Result := ctSpin;
    metDate:
      Result := ctDate;
    metTime:
      Result := ctTime;
    metDateTime:
      Result := ctDateTime;
    metBoolean:
      Result := ctCheckBox;
    metPickList:
      Result := TzCtrlType.DefaultPickListCtrlType;
    metLookup:
      Result := TzCtrlType.DefaultLookupCtrlType;
    metMemo:
      Result := ctMemo;
    metImage:
      Result := ctImage;
  end;
end;

end.
