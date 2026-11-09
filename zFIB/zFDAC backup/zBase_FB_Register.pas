unit zBase_FB_Register;

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  zFbDataSet;

procedure Register;
begin
  RegisterComponents('zBase_FIB', [TzFbDatabase, TzFbTransaction, TzFbDataSet, TzFbStoredProc, TzFbSQL]);
end;

end.
