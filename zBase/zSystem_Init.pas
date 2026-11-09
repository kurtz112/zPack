unit zSystem_Init;

interface

uses
  Classes,
  SysUtils,
  zMetaData,
  zSystem,
  dialogs,
  zBaseLib;

type
  TzSystemInitializer = record
  private
    FMetaData: TzMetaData;
    FzSystem: TzSystem;
  private
    function ExtractTableNameFromGeneratorName(const GeneratorName: string): string;

    procedure GenerateLookupObjects(const fkName: string; Lookup: TzmdLookup);

    function AddLookupDataSet(const fkName: string; Lookup: TzmdLookup): TzDataSet; overload;
    function AddLookupDataSet(Lookup: TzLookup): TzDataSet; overload;
    function AddLookupCard(const fkName: string; Lookup: TzmdLookup): TzDbCardProps; overload;
    function AddLookupCard(Lookup: TzLookup): TzDbCardProps; overload;
    function AddLookupView(const fkName: string; Lookup: TzmdLookup): TzDbViewProps; overload;
    function AddLookupView(Lookup: TzLookup): TzDbViewProps; overload;
  private
    Procedure DeleteNonExistentLookups;
  public
    procedure InitGenerators();
    procedure InitPickLists();
    procedure InitLookups();
    procedure InitDataDictionary();
    procedure AssignTableNameToDataset();

    procedure SISTEMAZIONI;

    property zSystem: TzSystem read FzSystem write FzSystem;
    property MetaData: TzMetaData read FMetaData write FMetaData;
  end;

procedure Init_zSystem(zSystem: TzSystem; MetaData: TzMetaData; callback: TProc<string>);

implementation

uses
  System.Generics.Collections,
  Data.DB,
  Vcl.StdCtrls,
  zCollection,
  zSqlLib,
  zMetaData.Types,
  zMsg,
  SmartInspect.Vcl.SiAuto;

procedure Init_zSystem(zSystem: TzSystem; MetaData: TzMetaData; callback: TProc<string>);
  procedure doCallBack(const msg: string);
  begin
    if Assigned(callback) then
      callback(msg);
  end;

var
  zSystemInitializer: TzSystemInitializer;
begin
  zSystemInitializer.zSystem := zSystem;
  zSystemInitializer.MetaData := MetaData;

  doCallBack('Inizializzazione Generators');
  zSystemInitializer.InitGenerators();
  doCallBack('Inizializzazione PickLists');
  zSystemInitializer.InitPickLists();
  doCallBack('Inizializzazione Lookups');
  zSystemInitializer.InitLookups();
  doCallBack('Inizializzazione DataDictionary');
  zSystemInitializer.InitDataDictionary();
  doCallBack('Aggiornamento TableName');
  zSystemInitializer.AssignTableNameToDataset();
  doCallBack('Sistemazioni finali');
  zSystemInitializer.SISTEMAZIONI;
end;

{ TzSystemInitializer }

function TzSystemInitializer.ExtractTableNameFromGeneratorName(const GeneratorName: string): string;
const
  GenSuffix = '_ID';
  GenPrefix = 'GEN_';
var
  s: string;
begin
  Result := '';

  s := GeneratorName;

  // toglie GEN_
  if Pos(GenPrefix, GeneratorName) = 1 then
    s := Copy(s, Length(GenPrefix) + 1, Length(s));

  // toglie _ID
  if Pos(GenSuffix, s) = (Length(s) - (Length(GenSuffix)) + 1) then
    s := System.Copy(s, 1, Length(s) - Length(GenSuffix));

  Result := s;
end;

procedure TzSystemInitializer.InitGenerators;
var
  i: integer;
  idx: integer;
  item: TzGenerator;
  s: string;
  GeneratorName: string;
  TableName: string;
  idxTable: integer;
begin
  for item in zSystem.zGenerators do
    item.Exists := false;

  // aggiunge quelli inseriti nel db
  for i := 0 to MetaData.Generators.Count - 1 do
  begin
    idx := zSystem.zGenerators.FindItemByGeneratorName(MetaData.Generators[i].Name);

    if idx = -1 then
    begin
      item := zSystem.zGenerators.Add;
      item.Exists := True;
      item.Name := MetaData.Generators[i].Name;
      item.GeneratorName := MetaData.Generators[i].Name;

      // GEN_%TABLE_NAME%_ID
      TableName := ExtractTableNameFromGeneratorName(item.GeneratorName);

      idxTable := MetaData.Tables.IndexOf(TableName, 0, -1, True);
      if idxTable <> -1 then
      begin
        item.TableName := MetaData.Tables[idxTable].Name; // (1) Era erroneamente TableName
        if MetaData.Tables[idxTable].PrimaryKey.Count = 1 then
          item.FieldName := MetaData.Tables[idxTable].PrimaryKey[0].Name;
      end;
    end
    else
    begin // conferma l'esistenza
      item := zSystem.zGenerators.Items[idx];
      item.Exists := True;

      // verifica l'esistenza del fieldname
      if item.AutoFieldName then
      begin

        idxTable := MetaData.Tables.IndexOf(item.TableName);
        if idxTable <> -1 then
          if MetaData.Tables[idxTable].PrimaryKey.Count = 1 then
            item.FieldName := MetaData.Tables[idxTable].PrimaryKey[0].Name;
      end;

      // // serve a correzione di (1)
      // item := zSystem.zGenerators[idx];
      // if (item.TableName = '') or (MetaData.Tables.IndexOf(item.TableName) = -1) then
      // begin
      //
      // TableName := ExtractTableNameFromGeneratorName(item.GeneratorName);
      //
      // idxTable := MetaData.Tables.IndexOfPartial(TableName);
      // if idxTable <> -1 then
      // begin
      // item.TableName := MetaData.Tables[idxTable].Name;
      // if MetaData.Tables[idxTable].PrimaryKey.Count = 1 then
      // item.FieldName := MetaData.Tables[idxTable].PrimaryKey[0].Name;
      // end;
      // end;
    end;
  end;
end;

procedure TzSystemInitializer.GenerateLookupObjects(const fkName: string; Lookup: TzmdLookup);
begin
  AddLookupDataSet(fkName, Lookup);
  AddLookupCard(fkName, Lookup);
  AddLookupView(fkName, Lookup);
end;

function TzSystemInitializer.AddLookupDataSet(const fkName: string; Lookup: TzmdLookup): TzDataSet;
var
  idx, i: integer;
begin
  Result := zSystem.zDataSets.Get(fkName, True);

  if Lookup.IsNew then
  begin
    Result.Name := fkName;
    Result.TableName := Lookup.TableNameFK;

    idx := zSystem.zGenerators.FindItemByTableName(Lookup.TableNameFK);
    if idx <> -1 then
      Result.Generator := zSystem.zGenerators[idx].Name;

    Result.BuildSQL(MetaData); // crea anche ins, upd e delete

    if not Lookup.SelectSQL.text.IsEmpty then
      Result.SQL_Select.text := Lookup.SelectSQL.text;
  end;
end;

function TzSystemInitializer.AddLookupCard(const fkName: string; Lookup: TzmdLookup): TzDbCardProps;
begin
  Result := zSystem.zDbCards.Get(fkName, True);

  if Result.IsNew then
  begin
    Result.DataSet := fkName;
    Result.Caption := CapFirst(Lookup.TableNameFK);
  end;
end;

function TzSystemInitializer.AddLookupCard(Lookup: TzLookup): TzDbCardProps;
begin
  Result := zSystem.zDbCards.Get(Lookup.DbCard, True);

  if Result.IsNew then
  begin
    Result.Name := Lookup.DbCard;
    Result.DataSet := Lookup.DataSet;
    Result.Caption := CapFirst(Lookup.TableNameFK);
  end;
end;

function TzSystemInitializer.AddLookupDataSet(Lookup: TzLookup): TzDataSet;
var
  idx, i: integer;
begin
  Result := zSystem.zDataSets.Get(Lookup.DataSet, True);

  if Lookup.IsNew then
  begin
    Result.Name := Lookup.DataSet;
    Result.TableName := Lookup.TableNameFK;

    if not Result.TableName.IsEmpty then
    begin
      idx := zSystem.zGenerators.FindItemByTableName(Lookup.TableNameFK);
      if idx <> -1 then
        Result.Generator := zSystem.zGenerators[idx].Name;

      Result.BuildSQL(MetaData); // crea anche ins, upd e delete
    end;
  end;
end;

function TzSystemInitializer.AddLookupView(const fkName: string; Lookup: TzmdLookup): TzDbViewProps;
begin
  Result := zSystem.zDbViews.Get(fkName, True);

  if Result.IsNew then
  begin
    Result.DataSet := fkName;
    Result.Title := CapFirst(Lookup.TableNameFK);
  end;
end;

function TzSystemInitializer.AddLookupView(Lookup: TzLookup): TzDbViewProps;
begin
  Result := zSystem.zDbViews.Get(Lookup.DbView, True);

  if Result.IsNew then
  begin
    Result.DataSet := Lookup.DataSet;
    Result.Title := CapFirst(Lookup.TableNameFK);
  end;
end;

procedure TzSystemInitializer.AssignTableNameToDataset;
var
  DataSet: TzDataSet;
  i: integer;
  idx: integer;
  TableName: string;
begin

  for i := 0 to zSystem.zDataSets.Count - 1 do
  begin
    DataSet := zSystem.zDataSets[i];
    //

    TableName := DataSet.TableName;

    if (MetaData.Tables.IndexOf(TableName) = -1) and (MetaData.Views.IndexOf(TableName) = -1) and (MetaData.Procedures.IndexOf(TableName) = -1) then
      if zSqlLib.Get_TableNameFromSQL(zSystem.MetaData, DataSet.SQL_Select.text, TableName, false) then
      begin
        DataSet.TableName := TableName;

        idx := zSystem.zGenerators.FindItemByTableName(TableName);
        if idx <> -1 then
          DataSet.Generator := zSystem.zGenerators[idx].GeneratorName;
      end;
  end;
end;

procedure TzSystemInitializer.InitPickLists;
var
  PickList: TzmdPicklist;
  zPickList: TzPickList;
begin

  for PickList in MetaData.PickLists do
  begin
    zPickList := zSystem.zPickLists.Get(PickList.Name, True);

    // Una lista nuova viene generata per intero; su una esistente le voci seguono
    // il commento del dominio solo se non sono state personalizzate a mano
    if not zPickList.UpdateDescription(PickList.Description) then
      siMain.LogWarning('InitPickLists: il commento del dominio ' + PickList.Name +
        ' è cambiato, ma le voci sono personalizzate e non sono state riallineate');
  end;
end;

procedure TzSystemInitializer.InitDataDictionary;
  procedure ApplyDomain(var Domain: TzDomain);
  begin

    if Domain.Domain.StartsWith('VALUTA_') then
    begin
      Domain.DisplayFormat := '€ ###,##0.00';
      Domain.Currency := True;
    end
    else
      if SameText(Domain.Domain, 'SI_NO') then
      begin
        Domain.zCtrlType := ctCheckBox;
      end
      else
        if SameText(Domain.Domain, 'TRUE_FALSE') then
        begin
          Domain.zCtrlType := ctCheckBox;
        end
        else
          if SameText(Domain.Domain, 'ANNO') then
          begin
            Domain.DisplayFormat := ''; // altrimenti produce, ad es. 1.971
          end
          else
            if SameText(Domain.Domain, 'NOTE') or SameText(Domain.Domain, 'MEMO') then
            begin
              if not Domain.zCtrlType.IsMemo then
                Domain.zCtrlType := ctMemo;
              Domain.BlobType := ftMemo
            end
            else
              if SameText(Domain.Domain, 'IMMAGINE') then
              begin
                Domain.zCtrlType := ctImage;
                Domain.BlobType := ftGraphic;
              end;
  end;

var
  metaDict: TzmdDataDictionaryItem;
  Domain: TzDomain;
  i: integer;
begin
  zSystem.zDataDictionary.BeginUpdate;
  try
    zSystem.zDataDictionary.IndexEnabled := True;
    try
      for Domain in zSystem.zDataDictionary do
        Domain.Exists := false;

      for metaDict in MetaData.DataDictionary do
      begin
        Domain := zSystem.zDataDictionary.Get(metaDict.Name, True);

        Domain.Exists := True;
        Domain.Name := metaDict.Name;
        Domain.TableName := metaDict.RelationName;
        Domain.FieldName := metaDict.RelationField;
        Domain.DataType := metaDict.FieldType;
        Domain.Size := metaDict.FieldSize;
        Domain.ColSpan := metaDict.ColSpan;
        Domain.Precision := metaDict.FieldDecimals;
        Domain.Calculated := metaDict.Calculated;
        Domain.Identity := metaDict.Identity;
        Domain.SetFieldFlagsFromMetadata(metaDict.ReadOnly, metaDict.Required);

        Domain.HasSensitivity := metaDict.HasSensitivity;
        Domain.Sensitivity := metaDict.Sensitivity;

        if Domain.IsNew then
        begin
          Domain.Domain := metaDict.FieldDomain;
          Domain.Alignment := metaDict.Alignment;
          Domain.DisplayLabel := metaDict.Caption;
          Domain.DefaultExpression := metaDict.DefaultValue;
          Domain.Lookup := metaDict.Lookup;
          Domain.PickList := metaDict.PickList;
          Domain.zCtrlType := metaDict.EditorType.zCtrlType; // ||||

          if isNumeric(Domain.DataType) then
          begin
            if isInteger(Domain.DataType) then
            begin

              if Domain.Name.StartsWith('ID_') then
                Domain.DisplayFormat := '###,###'
              else
                Domain.DisplayFormat := '###,##0';
            end
            else
              Domain.DisplayFormat := '###,##0.00';
          end;

          ApplyDomain(Domain);
        end
        else
        /// //////////////////////////////////////////////
        /// Update
        begin
          // variato il dominio
          if Domain.Domain <> metaDict.FieldDomain then
            ApplyDomain(Domain);

          if not metaDict.DefaultValue.IsEmpty then
            if Domain.DefaultExpression.IsEmpty then
              Domain.DefaultExpression := metaDict.DefaultValue;

          // 25 giugno 2007: cambiata logica
          // se il campo è stato portato a not null deve riflettere,
          // altrimenti lo lascia stare

          { TODO : Ripristinare dopo l'introduzione degli OVERRIDE }
          // if false then
          // if metaDict.Required then
          // Domain.Required := True;
          //
          // // idem per ReadOnly
          // { TODO : Ripristinare dopo l'introduzione degli OVERRIDE }
          // if false then
          // if metaDict.ReadOnly then
          // if metaDict.RelationType = 'T' then // solo per le table
          // Domain.ReadOnly := True;

          // LOOKUP ---------------
          // se è stata aggiunta una fk la assegna
          if Domain.Lookup.IsEmpty then
            if not metaDict.Lookup.IsEmpty then
            begin
              Domain.Lookup := metaDict.Lookup;

              if not Domain.zCtrlType.IsLookup then
                Domain.zCtrlType := TzCtrlType.DefaultLookupCtrlType;
            end;

          // se ora esiste, forza il zCtrlType
          // NO, coperto dal caso sopra: altrimenti impedisca hyperlink o altro
          if false then
            if not Domain.Lookup.IsEmpty then // se assegnato
              if not Domain.zCtrlType.IsLookup then
                if not Domain.ReadOnly then // !
                  Domain.zCtrlType := TzCtrlType.DefaultLookupCtrlType;

          // PICKLIST ---------------
          // se è stata aggiunta una picklist la assegna
          if Domain.PickList.IsEmpty then // se assegnato
            if not metaDict.PickList.IsEmpty then
              Domain.PickList := metaDict.PickList;

          // se ora esiste, forza il zCtrlType
          if not Domain.PickList.IsEmpty then
            if not Domain.zCtrlType.IsPickList then
            begin
              Domain.zCtrlType := TzCtrlType.DefaultPickListCtrlType;
              Domain.CharCase := ecNormal;
            end;
          // note
        end; // \Update
      end;

      for Domain in zSystem.zDataDictionary do
        if Domain.zCtrlType.IsLookup then
          if Domain.Lookup.IsEmpty then
            Domain.zCtrlType := ctEdit;
    finally
      zSystem.zDataDictionary.IndexEnabled := false;
    end;
  finally
    zSystem.zDataDictionary.EndUpdate;
  end;
end;

procedure TzSystemInitializer.DeleteNonExistentLookups;
var
  i, idx: integer;
  zLookup: TzLookup;
begin
  for i := zSystem.zLookups.Count - 1 downto 0 do
  begin
    zLookup := zSystem.zLookups.Items[i];

    if zLookup.IsForeignKey then
      if not zLookup.Exists then
      begin

        begin
          // view
          idx := zSystem.zDbViews.IndexOf(zLookup.DbView);
          if idx <> -1 then
            zSystem.zDbViews.Delete(idx);

          // dataset
          idx := zSystem.zDataSets.IndexOf(zLookup.DataSet);
          if idx <> -1 then
            zSystem.zDataSets.Delete(idx);

          // lk
          zSystem.zLookups.Delete(i);
        end;
      end;
  end;
end;

// procedure TzSystemInitializer.InitLookups;
// var
// i, iTable, iFk, iField: integer;
// item: TzLookup;
// LookupName: string;
// idx: integer;
// KeyField: string;
// ListFields: string;
// ForeignKeyFields: string;
// SearchFields: string;
// fkView: string;
// idxView: integer;
//
// function AddField(const FieldList, FieldName: string): string;
// begin
// Result := FieldList;
// if Trim(Result) <> '' then
// Result := Result + ';';
//
// Result := Result + FieldName;
// end;
//
// begin
// zSystem.zLookups.BeginUpdate;
// try
// for item in zSystem.zLookups do
// item.Exists := false;
//
// for iTable := 0 to MetaData.Tables.Count - 1 do
// for iFk := 0 to MetaData.Tables[iTable].ForeignKeys.Count - 1 do
// begin
// LookupName := MetaData.Tables[iTable].ForeignKeys[iFk].Name;
// SearchFields := '';
// KeyField := '';
// ListFields := '';
//
// for iField := 0 to MetaData.Tables[iTable].ForeignKeys[iFk].Fields.Count - 1 do
// begin
// SearchFields := AddField(SearchFields, MetaData.Tables[iTable].ForeignKeys[iFk].FkFields[iField].Name);
// KeyField := AddField(KeyField, MetaData.Tables[iTable].ForeignKeys[iFk].Fields[iField].Name);
// ListFields := AddField(ListFields, MetaData.Tables[iTable].ForeignKeys[iFk].FkFields[iField].Name);
// ForeignKeyFields := MetaData.Tables[iTable].ForeignKeys[iFk].FkFields[iField].Name + '@' + MetaData.Tables[iTable].ForeignKeys[iFk].Fields[iField].Name + ';';
// end;
//
// fkView := '_lk_' + LookupName;
//
// idx := zSystem.zLookups.IndexOf(LookupName);
// if idx = -1 then
// begin
// item := zSystem.zLookups.Add;
// item.Name := LookupName;
// item.FieldNamesFK := KeyField;
// item.DisplayColumns := ListFields;
// // TODO : BASE.LOOKUPS item.ForeignKeyFields := ForeignKeyFields;
// // TODO : BASE.LOOKUPS item.LookupFields := item.ForeignKeyFields;
//
// item.DataSet := fkView;
// item.DbView := fkView;
//
// AddTable(MetaData.Tables[iTable].ForeignKeys[iFk].FkTable, fkView);
//
// item.OnlyFromLookup := True;
// // TODO : BASE.LOOKUPS item.SearchFields := SearchFields;
// idxView := zSystem.zDbViews.IndexOf(item.DbView);
// if idxView <> -1 then
// zSystem.zDbViews[idxView].SearchFields := SearchFields;
//
// item.TableName := MetaData.Tables[iTable].Name;
// item.TableNameFK := MetaData.Tables[iTable].ForeignKeys[iFk].FkTable;
// end
// else
// begin
// item := zSystem.zLookups.Items[idx];
// // TODO : BASE.LOOKUPS  item.ForeignKeyFields := ForeignKeyFields;
//
// if item.DataSet = '' then
// item.DataSet := fkView;
//
// // se non esiste il dataset di lookup, a seguito di ripuliture, lo ricrea
// if zSystem.zDataSets.IndexOf(item.DataSet) = -1 then
// AddTable(MetaData.Tables[iTable].ForeignKeys[iFk].FkTable, fkView);
// end;
//
// item.Exists := True;
// item.IsForeignKey := True;
// end;
// /// ////////////////////////////////////////////////////////////////
// /// ZZ 27.03.2015: si eliminano le FK che non esistono più
// for i := zSystem.zLookups.Count - 1 downto 0 do
// begin
// item := zSystem.zLookups.Items[i];
// if item.IsForeignKey then
// if not item.Exists then
// begin
// // view
// idx := zSystem.zDbViews.IndexOf(item.DbView);
// if idx <> -1 then
// zSystem.zDbViews.Delete(idx);
// // dataset
// idx := zSystem.zDataSets.IndexOf(item.DataSet);
// if idx <> -1 then
// zSystem.zDataSets.Delete(idx);
// // lk
// zSystem.zLookups.Delete(i);
// end; // \not exists
// end; // for
// /// ////////////////////////////////////////////////////////////////
// finally
// zSystem.zLookups.EndUpdate;
// end;
// end;

procedure TzSystemInitializer.InitLookups;

  function Coalesce(const Value1, Value2: string): string;
  begin

    if Value1.Trim.IsEmpty then
      Result := Value2
    else
      Result := Value1;
  end;

  procedure InitExistFalse;
  var
    zLookup: TzLookup;
  begin
    for zLookup in zSystem.zLookups do
    begin

      if zLookup.IsForeignKey then
        zLookup.Exists := false
      else
        zLookup.Exists := True; // custom
    end;
  end;

  procedure CheckConnectedObjects;
  var
    zLookup: TzLookup;
  begin

    for zLookup in zSystem.zLookups do
    begin
      if zLookup.DataSet.IsEmpty then
        zLookup.DataSet := zLookup.Name;

      if zLookup.DbView.IsEmpty then
        zLookup.DbView := zLookup.Name;

      if zLookup.DbCard.IsEmpty then
        zLookup.DbCard := zLookup.Name;

      //

      if not Assigned(zLookup.DataSet_Obj) then
        zLookup.DataSet_Obj := AddLookupDataSet(zLookup);

      if not Assigned(zLookup.DbView_Obj) then
        zLookup.DbView_Obj := AddLookupView(zLookup);

      if not Assigned(zLookup.DbCard_Obj) then
        zLookup.DbCard_Obj := AddLookupCard(zLookup);
    end;
  end;

  procedure SetSqlIfMissing(zLookup: TzLookup; const SQL: string);
  var
    DataSet: TzDataSet;
  begin
    DataSet := zLookup.DataSet_Obj;

    if Assigned(DataSet) then
      if DataSet.SQL_Select.IsEmpty then
        DataSet.SQL_Select.text := SQL;
  end;

var
  fkName: string;
  Lookup: TzmdLookup;
  zLookup: TzLookup;
begin

  zSystem.zLookups.BeginUpdate;
  try
    InitExistFalse;

    /// //////////////////////////////////////

    for Lookup in MetaData.Lookups do
    begin
      zLookup := zSystem.zLookups.Get(Lookup.Name, True);
      zLookup.Exists := True;
      zLookup.IsForeignKey := True;

      zLookup.FieldNames := Coalesce(zLookup.FieldNames, Lookup.FieldNames);
      zLookup.TableName := Coalesce(zLookup.TableName, Lookup.TableName);
      zLookup.FieldNamesFK := Coalesce(zLookup.FieldNamesFK, Lookup.FieldNamesFK);
      zLookup.TableNameFK := Coalesce(zLookup.TableNameFK, Lookup.TableNameFK);
      zLookup.DisplayColumns := Coalesce(zLookup.DisplayColumns, Lookup.DisplayColumns);
      zLookup.Mappings.text := Coalesce(zLookup.Mappings.text, Lookup.Mappings.text);

      //
      // Proprietà valide anche per i lookup custom
      if zLookup.KeyField.IsEmpty then
      begin
        if zLookup.FieldNames.Contains(';') then
          zLookup.KeyField := zLookup.FieldNames.Substring(0, zLookup.FieldNames.IndexOf(';'))
        else
          zLookup.KeyField := zLookup.FieldNames;
      end;

      if zLookup.DisplayColumns.IsEmpty then
        zLookup.DisplayColumns := zLookup.FieldNamesFK;
      //

      fkName := '_lk_' + Lookup.Name;

      if zLookup.DataSet.IsEmpty then
        zLookup.DataSet := fkName;

      if zLookup.DbView.IsEmpty then
        zLookup.DbView := fkName;

      if zLookup.DbCard.IsEmpty then
        zLookup.DbCard := fkName;

      // // se non esiste il dataset di lookup, a seguito di ripuliture, lo ricrea
      if not zSystem.zDataSets.Exists(fkName) then
        GenerateLookupObjects(fkName, Lookup);
    end;

    DeleteNonExistentLookups;
    CheckConnectedObjects;

    for Lookup in MetaData.Lookups do
    begin
      zLookup := zSystem.zLookups.Get(Lookup.Name, false);

      if Assigned(zLookup) then
        SetSqlIfMissing(zLookup, Lookup.SelectSQL.text);
    end;
  finally
    zSystem.zLookups.EndUpdate;
  end;
end;

procedure TzSystemInitializer.SISTEMAZIONI;

  function getMappings(zLookup: TzLookup): string;
  var
    s: string;
    SourceField, DestField: string;
  begin
    // Result := '';
    //
    // for s in zLookup.LookupFields.Split([';']) do
    // if not s.Trim.IsEmpty then
    // begin
    //
    // if s.Contains('@') then
    // begin
    // DestField := s.Substring(0, s.IndexOf('@'));
    // SourceField := s.Substring(s.IndexOf('@') + 1);
    // end
    // else
    // begin
    // DestField := s;
    // SourceField := s;
    // end;
    //
    // if not Result.IsEmpty then
    // Result := Result + sLineBreak;
    //
    // Result := Result + SourceField + '=' + DestField;
    // end;
    //
    // if Result.IsEmpty then
    // begin
    // var
    // Lookup: TzmdLookup := MetaData.Lookups.Get(zLookup.Name, false);
    //
    // if Assigned(Lookup) then
    // Result := Lookup.Mappings.text;
    // end;
  end;

  function getDisplayColumns(zLookup: TzLookup): string;
  var
    view: TzDbViewProps;
  begin
    Result := zLookup.FieldNamesFK;

    view := zSystem.zDbViews.Get(zLookup.DbView, false);

    if Assigned(view) then
      Result := view.Columns.VisibleFields;
  end;

  procedure SISTEMA_LOOKUPS;

    function getVisibleFields(Lookup: TzLookup): string;
    begin
      Result := '';

      if Lookup.DbView_Obj = nil then
        if not Lookup.DbView.IsEmpty then
          Lookup.DbView_Obj := base.zDbViews.Get(Lookup.DbView, false);

      if Assigned(Lookup.DbView_Obj) then
        Result := Lookup.DbView_Obj.Columns.VisibleFields;
    end;

  var
    zLookup: TzLookup;
  begin
    for zLookup in zSystem.zLookups do
    begin
      // if zLookup.IsForeignKey then
      // begin
      // zLookup.FieldNames := zLookup.KeyField;
      // zLookup.TableName := zLookup.TableRel;
      // zLookup.FieldNamesFK := zLookup.SearchFields;
      // zLookup.TableNameFK := zLookup.TableFK;
      //
      // zLookup.Mappings.text := getMappings(zLookup);
      // zLookup.DisplayColumns := getDisplayColumns(zLookup);
      // end
      // else
      // begin
      // zLookup.FieldNames := zLookup.KeyField;
      // zLookup.TableName := zLookup.TableRel;
      // zLookup.FieldNamesFK := zLookup.SearchFields;
      // zLookup.TableNameFK := zLookup.TableFK;
      //
      // if zLookup.FieldNamesFK.IsEmpty then // es. __ElencoEntiSediPerRisorse
      // zLookup.FieldNamesFK := zLookup.KeyField;
      // end;

      // if zLookup.Mappings.text.IsEmpty then
      // zLookup.Mappings.text := getMappings(zLookup);
      //
      // if zLookup.DisplayColumns.IsEmpty then
      // zLookup.DisplayColumns := zLookup.ListFields;
      //
      // if zLookup.DisplayColumns.IsEmpty then
      // zLookup.DisplayColumns := zLookup.SearchFields;
      //
      // if zLookup.DisplayColumns.IsEmpty then
      // zLookup.DisplayColumns := zLookup.FieldNamesFK;
      //
      // if zLookup.DisplayColumns.IsEmpty then
      // zLookup.DisplayColumns := getVisibleFields(zLookup);

      // if zLookup.DisplayColumns.IsEmpty then
      // ConfirmOk(zLookup.Name);
    end;
  end;

/// /////////////////////////////////////////
  procedure SISTEMA_DATA_DICTIONARY;
  var
    DataDict: TzmdDataDictionaryItem;
    Domain: TzDomain;
    zCtrlType: TzCtrlType;
  begin

    for Domain in zSystem.zDataDictionary do
    begin
      DataDict := MetaData.DataDictionary.Get(Domain.Name, false);

      if Assigned(DataDict) then
      begin
        zCtrlType := DataDict.EditorType.zCtrlType;

        if Domain.zCtrlType <> zCtrlType then
          case DataDict.EditorType of
            metText:
              ;
            metNumeric:
              ;
            metDate:
              begin
                if Domain.zCtrlType <> ctDate then
                  Domain.zCtrlType := ctDate;
              end;
            metTime:
              begin
                if Domain.zCtrlType <> ctTime then
                  Domain.zCtrlType := ctTime;
              end;

            metDateTime:
              begin
                if not(Domain.zCtrlType in [ctDate, ctDateTime]) then
                  Domain.zCtrlType := ctDateTime;
              end;
            metBoolean:
              begin
                if Domain.zCtrlType <> ctCheckBox then
                  if not(Domain.zCtrlType.IsPickList and not Domain.PickList.IsEmpty) then
                    Domain.zCtrlType := ctCheckBox;
              end;
            metPickList:
              begin
                if not Domain.zCtrlType.IsPickList then
                  Domain.zCtrlType := TzCtrlType.DefaultPickListCtrlType;
              end;
            metLookup:
              begin
                // no, caso delle pk delle view
                // if not Domain.zCtrlType.IsLookup then
                // Domain.zCtrlType := TzCtrlType.DefaultLookupCtrlType;
              end;
            metMemo:
              ;
            metImage:
              begin
                if Domain.zCtrlType <> ctImage then
                  Domain.zCtrlType := ctImage;
              end;
          end;

        if Domain.Domain = 'TRUE_FALSE_COLORATO' then
          Domain.zCtrlType := ctPickListImage;

        if DataDict.RelationType = 'V' then
        begin
          Domain.Required := DataDict.Required;
          Domain.ReadOnly := DataDict.ReadOnly;
        end;
      end;
    end;
  end;

/// /////////////////////////////////////////
///
  procedure SISTEMA_DOMAINS;
  var
    DataDict: TzmdDataDictionaryItem;
    Domain: TzDomain;
    zCtrlType: TzCtrlType;
  begin

    for Domain in zSystem.zDataDictionary do
    begin

      if SameText(Domain.Domain, 'SI_NO') then
        Domain.zCtrlType := ctCheckBox
      else
        if SameText(Domain.Domain, 'TRUE_FALSE') then
          Domain.zCtrlType := ctCheckBox
        else
          if SameText(Domain.Domain, 'ANNO') then
            Domain.DisplayFormat := '' // altrimenti produce, ad es. 1.971
          else
            if SameText(Domain.Domain, 'NOTE') or SameText(Domain.Domain, 'MEMO') then
            begin
              if not(Domain.zCtrlType in [ctMemo, ctRTF]) then
                Domain.zCtrlType := ctMemo;
              Domain.BlobType := ftMemo
            end
            else
              if SameText(Domain.Domain, 'IMMAGINE') then
              begin
                Domain.zCtrlType := ctImage;
                Domain.BlobType := ftGraphic;
              end;

      if Domain.DataType = ftBoolean then
        Domain.zCtrlType := ctCheckBox;
    end;
  end;

/// /////////////////////////////////////////
  procedure SISTEMA_OVERRIDE;
  var
    DataDict: TzmdDataDictionaryItem;
    Domain: TzDomain;
    zCtrlType: TzCtrlType;
  begin

    for Domain in zSystem.zDataDictionary do
    begin
      DataDict := MetaData.DataDictionary.Get(Domain.Name, false);

      if Assigned(DataDict) then
      begin

        if Domain.ReadOnlyField = Domain.ReadOnly then
          Domain.ReadOnlyOverride := boNull
        else
          if Domain.ReadOnly then
            Domain.ReadOnlyOverride := boTrue
          else
            Domain.ReadOnlyOverride := boFalse;

        if Domain.RequiredField = Domain.Required then
          Domain.RequiredOverride := boNull
        else
          if Domain.Required then
            Domain.RequiredOverride := boTrue
          else
            Domain.RequiredOverride := boFalse;
      end;
    end;
  end;

/// /////////////////////////////////////////
begin
  exit; // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  SISTEMA_LOOKUPS;
  SISTEMA_DATA_DICTIONARY;
  SISTEMA_DOMAINS;
  SISTEMA_OVERRIDE;
end;

end.
/// //
///
  zz.base.editor._frame, zz.base.editor.Lookup

  for Lookup in MetaData.Lookups do begin zLookup := zSystem.zLookups.Get
(Lookup.Name, True); zSystem zMetaData.loader zSystem_Init

  zSystem zMetaData

