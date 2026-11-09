unit zSystemTools;

interface

uses
  SysUtils,
  Classes,
  Dialogs,
  zSystem;

type
  TzSystemTools = class
  public
    // Elimina dalla lista i Dataset con SelectSQL Vuota.
    class Procedure EliminaDataSetSenzaSelect(zSystem: TzSystem; const Salva: boolean = false);
    /// Elimina i Domini dal DAtaDictionary verificando
    /// se la tablename esiste nei metadata (tables, proc o view) e se non è di sistema
    class Procedure EliminaDominiInesistenti(zSystem: TzSystem; const Salva: boolean = false);
    /// Elimina le FK che iniziano per FK_ (cioè prese dal db)
    /// e che non esistono nei metadata
    class procedure EliminaFKInesistenti(zSystem: TzSystem; const Salva: boolean = false);
    /// Get della lista di domini impostati come lookup ma con FK vuota
    class function GetLookupComboSenzaFK(zSystem: TzSystem): string;
    /// Get della lista di domini impostati come lookup ma con FK vuota
    class function GetFkSenzaDataSet(zSystem: TzSystem): string;
    //
    class function GetDataSetSenzaSelect(zSystem: TzSystem): string;
    /// Riassegna il dominio calcolandolo dalla coppia TableName/FieldName
    class procedure RiassegnaDomain(zSystem: TzSystem; const Salva: boolean = false);

  end;

implementation

uses
  zBaseLib, zMsg;

class procedure TzSystemTools.EliminaDataSetSenzaSelect(zSystem: TzSystem; const Salva: boolean = false);
var
  Count: Integer;
  DataSet: TzDataSet;
  i: Integer;
  Str: TStringList;
begin
  Assert(Assigned(zSystem));

  Count := 0;
  Str := TStringList.Create;
  try
    for i := zSystem.zDataSets.Count - 1 downto 0 do
    begin
      DataSet := zSystem.zDataSets[i];

      if DataSet.SQL_Select.Text = '' then
      begin

        Str.Add(DataSet.NAme);
        zSystem.zDataSets.Delete(i);
        Inc(Count);
      end;
    end;

    Str.SaveToFile(path + 'TzSystemTools.EliminaDataSetSenzaSelect.txt');
  finally
    Str.Free;
  end;

  if Salva then
    zSystem.SaveZip(csAll, 'EliminaDataSetSenzaSelect');

  ConfirmOk('DataSet senza Select eliminati: ' + IntToStr(Count));
end;

class procedure TzSystemTools.EliminaDominiInesistenti(zSystem: TzSystem; const Salva: boolean = false);
var
  Count: Integer;
  i: Integer;
  Str: TStringList;
begin
  Assert(Assigned(zSystem));

  // elimina fk inutili
  Count := 0;
  Str := TStringList.Create;
  try
    for i := zSystem.zDataDictionary.Count - 1 downto 0 do
      if not StartingWith(zSystem.zDataDictionary[i].TableName, '<') then
        if zSystem.MetaData.Tables.IndexOf(zSystem.zDataDictionary[i].TableName) = -1 then
          if zSystem.MetaData.Procedures.IndexOf(zSystem.zDataDictionary[i].TableName) = -1 then
            if zSystem.MetaData.Views.IndexOf(zSystem.zDataDictionary[i].TableName) = -1 then
            begin
              Str.Add(zSystem.zDataDictionary[i].NAme + '=' + zSystem.zDataDictionary[i].TableName);
              zSystem.zDataDictionary.Delete(i);
              Inc(Count);
            end;

    Str.SaveToFile(path + 'TzSystemTools.EliminaDominiInesistenti.txt');
  finally
    Str.Free;
  end;

  if Salva then
    zSystem.SaveZip(csAll, 'EliminaDominiInesistenti');

  ConfirmOk('Domain inesistenti eliminati: ' + IntToStr(Count));
end;

class procedure TzSystemTools.EliminaFKInesistenti(zSystem: TzSystem; const Salva: boolean = false);
var
  Count: Integer;
  DataSet: TzDataSet;
  i: Integer;
  idx: Integer;
  j: Integer;
  Str: TStringList;
  trovato: boolean;
begin
  Assert(Assigned(zSystem));

  Count := 0;
  Str := TStringList.Create;
  try
    for i := zSystem.zLookups.Count - 1 downto 0 do
      if StartingWith(zSystem.zLookups[i].NAme, 'FK_') then
      begin
        trovato := false;
        for j := 0 to zSystem.MetaData.Tables.Count - 1 do
          if zSystem.MetaData.Tables[j].ForeignKeys.IndexOf(zSystem.zLookups[i].NAme) <> -1 then
          begin
            trovato := True;
            Break;
          end;

        if not trovato then
        begin
          Str.Add(zSystem.zLookups[i].NAme);
          // dataset, view, card
          idx := zSystem.zDataSets.IndexOf(zSystem.zLookups[i].DataSet);
          if idx <> -1 then
            zSystem.zDataSets.Delete(idx);

          idx := zSystem.zDbViews.IndexOf(zSystem.zLookups[i].DbView);
          if idx <> -1 then
            zSystem.zDataSets.Delete(idx);

          zSystem.zLookups.Delete(i);

          Inc(Count);
        end;
      end;

    Str.SaveToFile(path + 'TzSystemTools.EliminaFKInesistenti.txt');
  finally
    Str.Free;
  end;

  if Salva then
    zSystem.SaveZip(csAll, 'EliminaFKInesistenti');

  ConfirmOk('FK inesistenti eliminate: ' + IntToStr(Count));
end;

class function TzSystemTools.GetFkSenzaDataSet(zSystem: TzSystem): string;
var
  i: Integer;
  Str: TStringList;
begin
  Assert(Assigned(zSystem));

  result := '';

  Str := TStringList.Create;
  try
    for i := zSystem.zLookups.Count - 1 downto 0 do
      if not Assigned(zSystem.zLookups[i].DataSet_Obj) then
        Str.Add(zSystem.zLookups[i].NAme);

    result := Str.Text;
  finally
    FreeAndNil(Str);
  end;
end;

class function TzSystemTools.GetLookupComboSenzaFK(zSystem: TzSystem): string;
var
  i: Integer;
  Str: TStringList;
begin
  Assert(Assigned(zSystem));

  result := '';

  Str := TStringList.Create;
  try
    for i := zSystem.zDataDictionary.Count - 1 downto 0 do
      if zSystem.zDataDictionary[i].zCtrlType.IsLookup then
        if zSystem.zDataDictionary[i].Lookup = '' then
          Str.Add(zSystem.zDataDictionary[i].NAme);

    result := Str.Text;
  finally
    FreeAndNil(Str);
  end;
end;

class procedure TzSystemTools.RiassegnaDomain(zSystem: TzSystem; const Salva: boolean);
var
  Count: Integer;
  i: Integer;
  Str: TStringList;
begin
  Assert(Assigned(zSystem));

  // elimina fk inutili
  Count := 0;
  Str := TStringList.Create;
  try

    for i := 0 to zSystem.zDataDictionary.Count - 1 do
      if zSystem.GetSqlDomainFromMetaData(zSystem.zDataDictionary[i].TableName, zSystem.zDataDictionary[i].FieldName) <> '' then
        if zSystem.zDataDictionary[i].Domain <> zSystem.GetSqlDomainFromMetaData(zSystem.zDataDictionary[i].TableName, zSystem.zDataDictionary[i].FieldName) then
        begin
          Str.Add(zSystem.zDataDictionary[i].NAme + '=' + zSystem.zDataDictionary[i].Domain);
          zSystem.zDataDictionary[i].Domain := zSystem.GetSqlDomainFromMetaData(zSystem.zDataDictionary[i].TableName, zSystem.zDataDictionary[i].FieldName);
          Inc(Count);
        end;

    Str.SaveToFile(path + 'TzSystemTools.RiassegnaDomain.txt');
  finally
    Str.Free;
  end;

  if Salva then
    zSystem.SaveZip(csAll, 'RiassegnaDomain');

  ConfirmOk('Domain riassegnati: ' + IntToStr(Count));
end;

class function TzSystemTools.GetDataSetSenzaSelect(zSystem: TzSystem): string;
var
  i: Integer;
  Str: TStringList;
begin
  Assert(Assigned(zSystem));

  Str := TStringList.Create;
  try
    for i := zSystem.zDataSets.Count - 1 downto 0 do
      if zSystem.zDataSets[i].SQL_Select.Text = '' then
        Str.Add(zSystem.zDataSets[i].NAme);

    result := Str.Text;
  finally
    FreeAndNil(Str);
  end;
end;

end.
