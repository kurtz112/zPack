// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-02
// ---------------------------------------------------------------------------
unit zDbLookupEditors;

// Lookup del dizionario (TzDomain.Lookup) negli editor delle celle: righe di
// TzDbRecordView, colonne di TzDbTree. Fino al 2026-10-02 le celle con un
// dominio di lookup diventavano caselle di testo, come in TzDbView, perche'
// mancava il dataset di appoggio che la scheda crea per ogni campo.
//
// Riusa i pezzi della scheda, senza la scheda:
// - TzLookupBinding (zDbCard.Lookup): dataset e datasource del lookup, con le
//   props di zSystem, parametri master e apertura su richiesta;
// - dx.InitLookup: proprieta' del combo (chiave, colonne, solo dall'elenco,
//   pulsante di ricerca F2, tendina della griglia);
// - TzFbDataSet.CopyMappingFields: a valore scelto, i campi mappati del
//   lookup passano nel record (es. la descrizione accanto all'identificativo).
//
// Il dataset di lookup ha UseSqlLocate spento: la Locate via SQL di
// TzFbDataSet lascerebbe nel dataset il solo record cercato e la tendina
// mostrerebbe un'unica riga.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  Data.DB,
  cxEdit,
  cxDBLookupComboBox,
  cxDBExtLookupComboBox,
  zSystem,
  zFbDataSet,
  zDbCard.Lookup;

type
  TzLookupEditors = class
  private type
    TItem = class
    public
      FieldName: string;
      IdLookup: string;
      Binding: TzLookupBinding;
      Properties: TcxCustomEditProperties;
      destructor Destroy; override;
    end;
  private
    FItems: TObjectList<TItem>;
    FSystemProvider: TFunc<TzSystem>;
    FDataSetProvider: TFunc<TzFbDataSet>;
    FFocusedFieldProvider: TFunc<string>;
    FReadTrans: TzFbTransaction;
    FWriteTrans: TzFbTransaction;
    FChanging: Boolean;
    function LookupSystem: TzSystem;
    function MainDataSet: TzFbDataSet;
    function GetReadTrans: TzFbTransaction;
    function GetWriteTrans: TzFbTransaction;
    function Find(const FieldName: string): TItem;
    function FocusedItem: TItem;
    procedure PropertiesInitPopup(Sender: TObject);
    procedure PropertiesEditValueChanged(Sender: TObject);
    procedure Detach(Item: TItem);
  public
    // SystemProvider e DataSetProvider come in TzLookupBinding: si leggono al
    // momento dell'uso. FocusedFieldProvider dice di quale campo e' la cella
    // in modifica: l'editor della cella non porta il nome del campo
    constructor Create(const SystemProvider: TFunc<TzSystem>; const DataSetProvider: TFunc<TzFbDataSet>; const FocusedFieldProvider: TFunc<string>);
    destructor Destroy; override;

    // Prepara l'editor della cella per il lookup del dominio. False se il
    // lookup non e' definito o non si puo' usare: il chiamante ripiega sulla
    // casella di testo, come prima
    function Configure(Properties: TcxCustomEditProperties; const FieldName, IdLookup: string; const HyperLink: Boolean): Boolean;

    // Apre i dataset di lookup (a dataset principale aperto): servono anche
    // solo per mostrare la descrizione nelle celle
    procedure EnsureOpen;

    // Sgancia gli editor e libera i dataset. Da chiamare finche' le righe o
    // le colonne esistono ancora (prima di ricrearle e alla distruzione)
    procedure Clear;
  end;

implementation

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  cxDropDownEdit,
  cxGridDBTableView,
  zDX;

{ TzLookupEditors.TItem }

destructor TzLookupEditors.TItem.Destroy;
begin
  FreeAndNil(Binding);
  inherited;
end;

{ TzLookupEditors }

constructor TzLookupEditors.Create(const SystemProvider: TFunc<TzSystem>; const DataSetProvider: TFunc<TzFbDataSet>; const FocusedFieldProvider: TFunc<string>);
begin
  inherited Create;
  FItems := TObjectList<TItem>.Create(True);
  FSystemProvider := SystemProvider;
  FDataSetProvider := DataSetProvider;
  FFocusedFieldProvider := FocusedFieldProvider;
  FReadTrans := nil;
  FWriteTrans := nil;
  FChanging := False;
end;

destructor TzLookupEditors.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  FreeAndNil(FWriteTrans);
  FreeAndNil(FReadTrans);
  inherited;
end;

function TzLookupEditors.LookupSystem: TzSystem;
begin
  result := nil;
  if Assigned(FSystemProvider) then
    result := FSystemProvider();
end;

function TzLookupEditors.MainDataSet: TzFbDataSet;
begin
  result := nil;
  if Assigned(FDataSetProvider) then
    result := FDataSetProvider();
end;

function TzLookupEditors.GetReadTrans: TzFbTransaction;
begin
  // come TzControls della scheda: transazioni proprie in lettura confermata
  if not Assigned(FReadTrans) then
  begin
    FReadTrans := TzFbTransaction.Create(nil);
    FReadTrans.Options.Isolation := xiReadCommitted;
    if LookupSystem <> nil then
      FReadTrans.Connection := LookupSystem.zFbDatabase;
  end;

  result := FReadTrans;
end;

function TzLookupEditors.GetWriteTrans: TzFbTransaction;
begin
  if not Assigned(FWriteTrans) then
  begin
    FWriteTrans := TzFbTransaction.Create(nil);
    FWriteTrans.Options.Isolation := xiReadCommitted;
    if LookupSystem <> nil then
      FWriteTrans.Connection := LookupSystem.zFbDatabase;
  end;

  result := FWriteTrans;
end;

function TzLookupEditors.Find(const FieldName: string): TItem;
var
  Item: TItem;
begin
  result := nil;

  for Item in FItems do
    if SameText(Item.FieldName, FieldName) then
      Exit(Item);
end;

function TzLookupEditors.FocusedItem: TItem;
begin
  result := nil;

  if Assigned(FFocusedFieldProvider) then
    result := Find(FFocusedFieldProvider());
end;

function TzLookupEditors.Configure(Properties: TcxCustomEditProperties; const FieldName, IdLookup: string; const HyperLink: Boolean): Boolean;
var
  zLookup: TzLookup;
  Item: TItem;
begin
  result := False;

  if not Assigned(Properties) or (Trim(IdLookup) = '') or (LookupSystem = nil) then
    Exit;

  zLookup := LookupSystem.zLookups.Get(IdLookup, False);
  if not Assigned(zLookup) or not Assigned(zLookup.DataSet_Obj) then
    Exit;

  if not((Properties is TcxLookupComboBoxProperties) or (Properties is TcxExtLookupComboBoxProperties)) then
    Exit;

  // un campo, un dataset di lookup: alla ricostruzione si riparte da capo
  Item := Find(FieldName);
  if Assigned(Item) then
  begin
    Detach(Item);
    FItems.Remove(Item);
  end;

  Item := TItem.Create;
  Item.FieldName := FieldName;
  Item.IdLookup := IdLookup;
  Item.Properties := Properties;
  Item.Binding := TzLookupBinding.Create(FieldName, IdLookup, FSystemProvider, FDataSetProvider,
    function: TzFbTransaction
    begin
      result := GetReadTrans;
    end,
    function: TzFbTransaction
    begin
      result := GetWriteTrans;
    end);
  FItems.Add(Item);

  try
    Item.Binding.CreateMainDataSet;

    // vedi l'intestazione della unit
    Item.Binding.DataSet.UseSqlLocate := False;

    if Properties is TcxExtLookupComboBoxProperties then
      dx.InitLookup(IdLookup, TcxExtLookupComboBoxProperties(Properties), FieldName, Item.Binding.DataSet, Item.Binding.DataSource, zLookup.FieldNamesFK,
        zLookup.DisplayColumns, nil, HyperLink)
    else
      dx.InitLookup(IdLookup, TcxLookupComboBoxProperties(Properties), FieldName, Item.Binding.DataSet, Item.Binding.DataSource, zLookup.FieldNamesFK,
        zLookup.DisplayColumns, HyperLink);

    // la scelta finisce subito nel campo: poi si copiano i campi mappati
    Properties.ImmediatePost := True;
    Properties.OnEditValueChanged := PropertiesEditValueChanged;
    TcxCustomDropDownEditProperties(Properties).OnInitPopup := PropertiesInitPopup;

    Item.Binding.EnsureOpen;
    result := True;
  except
    // lookup non utilizzabile (SQL mancante, colonne inesistenti): la cella
    // resta una casella di testo e la vista si apre comunque
    on Exception do
    begin
      Detach(Item);
      FItems.Remove(Item);
      result := False;
    end;
  end;
end;

procedure TzLookupEditors.PropertiesInitPopup(Sender: TObject);
var
  Item: TItem;
begin
  Item := FocusedItem;
  if not Assigned(Item) then
    Exit;

  // come la scheda: parametri master riallineati al record, poi apertura
  Item.Binding.VerifyParams;
  Item.Binding.EnsureOpen;
end;

procedure TzLookupEditors.PropertiesEditValueChanged(Sender: TObject);
var
  Item: TItem;
  zLookup: TzLookup;
  DataSet: TzFbDataSet;
  LookupDataSet: TzFbDataSet;
  Value: Variant;
  Vuoto: Boolean;
begin
  if FChanging then
    Exit;

  Item := FocusedItem;
  if not Assigned(Item) then
    Exit;

  DataSet := MainDataSet;
  if not Assigned(DataSet) or not(DataSet.State in dsEditModes) then
    Exit;

  zLookup := LookupSystem.zLookups.Get(Item.IdLookup, False);
  if not Assigned(zLookup) or (zLookup.Mappings.Count = 0) then
    Exit;

  LookupDataSet := Item.Binding.DataSet;
  if not Assigned(LookupDataSet) or not LookupDataSet.Active then
    Exit;

  Value := Null;
  if Sender is TcxCustomEdit then
    Value := TcxCustomEdit(Sender).EditValue;

  Vuoto := VarIsNull(Value) or VarIsEmpty(Value);

  // il record scelto, in memoria (UseSqlLocate e' spento)
  if not Vuoto then
    if not LookupDataSet.Locate(zLookup.GetKeyFieldForCombo(Item.FieldName), Value, []) then
      Exit;

  FChanging := True;
  try
    DataSet.CopyMappingFields(LookupDataSet, zLookup.Mappings, Vuoto, Item.FieldName);
  finally
    FChanging := False;
  end;
end;

procedure TzLookupEditors.EnsureOpen;
var
  Item: TItem;
begin
  for Item in FItems do
    try
      Item.Binding.VerifyParams;
      Item.Binding.EnsureOpen;
    except
      // un lookup che non si apre non deve bloccare il dataset principale
      on Exception do
        ;
    end;
end;

procedure TzLookupEditors.Detach(Item: TItem);
var
  View: TObject;
begin
  if not Assigned(Item.Properties) then
    Exit;

  // l'editor non deve restare legato a un datasource che sta per sparire
  if Item.Properties is TcxExtLookupComboBoxProperties then
  begin
    View := TcxExtLookupComboBoxProperties(Item.Properties).View;
    TcxExtLookupComboBoxProperties(Item.Properties).View := nil;
    // la vista della tendina la crea dx.InitLookup nel repository comune
    FreeAndNil(View);
  end
  else
    if Item.Properties is TcxLookupComboBoxProperties then
      TcxLookupComboBoxProperties(Item.Properties).ListSource := nil;

  Item.Properties.OnEditValueChanged := nil;
  Item.Properties := nil;
end;

procedure TzLookupEditors.Clear;
var
  Item: TItem;
begin
  for Item in FItems do
    Detach(Item);

  FItems.Clear;
end;

end.
