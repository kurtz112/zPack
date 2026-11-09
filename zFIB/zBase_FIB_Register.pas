unit zBase_FIB_Register;

interface

procedure Register;

implementation

uses
  Classes,
  DesignIntf,
  zFbDataSet;

procedure Register;
begin
  RegisterComponents('zBase_FIB', [TzFbDatabase, TzFbTransaction, TzFbDataSet, TzFbStoredProc]);
end;

end.
