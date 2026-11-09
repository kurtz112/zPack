{ ------------------------------------------------------------------------------------- }
{ A "JustOne" component for Delphi32. }
{ Copyright 1996, Patrick Brisacier.  All Rights Reserved. }
{ This component can be freely used and distributed in commercial and private }
{ environments, provided this notice is not modified in any way. }
{ ------------------------------------------------------------------------------------- }
{ Feel free to contact me if you have any questions, comments or suggestions at }
{ PBrisacier@mail.dotcom.fr (Patrick Brisacier) }
{ ------------------------------------------------------------------------------------- }
{ Date last modified:  10/08/96 }
{ ------------------------------------------------------------------------------------- }

{ ------------------------------------------------------------------------------------- }
{ TPBJustOne v1.00 }
{ ------------------------------------------------------------------------------------- }
{ Description: }
{ A component that enables only one unique instance of an application at each time. }
{ ------------------------------------------------------------------------------------- }
{ Revision History: }
{ 1.00:  + Initial release }
{ ------------------------------------------------------------------------------------- }

unit PBJustOne;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs;

procedure CheckIstance;

implementation

const
  AllowedInstances = 1;

var
  MyAppName, MyClassName: array [0 .. 255] of Char;
  NumFound: Integer;
  LastFound, MyPopup: HWND;

function LookAtAllWindows(Handle: HWND; Temp: LongInt): BOOL; stdcall;
var
  WindowName, ClassName: array [0 .. 255] of Char;
begin
  result := true;

  // Go get the windows class name
  if GetClassName(Handle, ClassName, SizeOf(ClassName)) > 0 then
    // Is the window class the same ?
    if StrComp(ClassName, MyClassName) = 0 then
      // Get its window caption
      if GetWindowText(Handle, WindowName, SizeOf(WindowName)) > 0 then
        // Does this have the same window title ?
        if StrComp(WindowName, MyAppName) = 0 then
        begin
          inc(NumFound);
          // Are the handles different ?
          if Handle <> Application.Handle then
            // Save it so we can bring it to the top later.
            LastFound := Handle;
        end;
end;

procedure CheckIstance;
begin
  NumFound := 0;
  LastFound := 0;
  // First, determine what this application'name is.
  GetWindowText(Application.Handle, MyAppName, SizeOf(MyAppName));
  // Now determine the class name for this application
  GetClassName(Application.Handle, MyClassName, SizeOf(MyClassName));
  // Now count how many others out there are Delphi apps with this title
  EnumWindows(@LookAtAllWindows, 0);
  if NumFound > AllowedInstances then
  // there is another instance running, bring it to the front !
  begin
    MyPopup := GetLastActivePopup(LastFound);
    // Bring it to the top in the Z-Order
    BringWindowToTop(LastFound);
    // Is the window iconized ?
    if IsIconic(MyPopup) then
      // Restore it to its original position
      ShowWindow(MyPopup, SW_RESTORE)
    else
      // Bring it to the front
      SetForegroundWindow(MyPopup);
    // Halt this instance
    Halt;
  end
end;

end.
