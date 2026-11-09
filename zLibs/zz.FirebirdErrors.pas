unit zz.FirebirdErrors;

interface

uses
  System.SysUtils;

function ExtractFirebirdError(e: exception): string;

implementation

uses
  FireDAC.Stan.Error,
  System.StrUtils;

function CleanMessage(Msg: string): string;

  function RemoveStartingText(const StartingText: string; const s: string): string;
    function RemoveStarting1310(const s: string): string;
    var
      c: Char;
      Skip1310: Boolean;
    begin
      result := '';
      Skip1310 := True;

      for c in s do
      begin
        if (c in [#13, #10]) then
        begin
          if not Skip1310 then
            result := result + c;
        end
        else
        begin
          result := result + c;
          Skip1310 := false;
        end;
      end;
    end;

  begin
    result := RemoveStarting1310(s);

    if StartsText(StartingText, result) then
    begin
      result := System.Copy(result, StartingText.Length + 1, s.Length);
      result := RemoveStarting1310(result);
    end
    else
      result := s;
  end;

var
  idx: Integer;
begin
  result := Msg;

  result := RemoveStartingText('[FireDAC][Phys][FB]exception 1' + #13#10 + 'E' + #13#10, result);
  result := RemoveStartingText('[FireDAC][Phys][FB]', result);
  result := RemoveStartingText('Exception 1.', result);
  result := RemoveStartingText('E.', result);
  result := RemoveStartingText('exception 1', result);
  result := StringReplace(result, 'Password required.', '', []);
  //
  idx := AnsiPos('At procedure', result);
  if idx > 0 then
    result := System.Copy(result, 1, idx - 1);
  //
  idx := AnsiPos('At trigger', result);
  if idx > 0 then
    result := System.Copy(result, 1, idx - 1);
  //
  idx := AnsiPos('At function', result);
  if idx > 0 then
    result := System.Copy(result, 1, idx - 1);

  idx := AnsiPos('Can''t format message', result);
  if idx > 0 then
    result := System.Copy(result, 1, idx - 1);

  result := Trim(result);
end;

function ExtractFirebirdError(e: exception): string;
begin
  result := CleanMessage(UTF8Decode(e.Message));
end;

end.

zexceptions
