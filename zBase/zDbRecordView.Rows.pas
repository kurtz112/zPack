// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-02
// ---------------------------------------------------------------------------
unit zDbRecordView.Rows;

// Costruzione delle righe di TcxDBVerticalGrid a partire da TzDbRecordViewProps
// e lettura inversa (dalla griglia alle props) dopo la personalizzazione.
//
// Regole verificate nelle prove della fase 0 (Fase 0 - 20261001 - Prove TzDbVerticalGrid.md):
// - la sola lettura per riga funziona con Properties.Options.Editing e con
//   EditProperties.ReadOnly; non si usano ShowEdit e ShowEditByKey, che portano
//   il dataset in modifica prima di consultare OnEditing;
// - un campo fkLookup riceve da solo TcxLookupComboBoxProperties se non si
//   assegna EditPropertiesClass: per quei campi la classe non va toccata.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  cxEdit,
  cxVGrid,
  cxDBVGrid,
  zBaseLib,
  zSystem,
  zDataController,
  zDbLookupEditors;

type
  TzRecordViewRowCreatedEvent = procedure(Sender: TObject; Row: TcxCustomRow; Item: TzRecordViewRow; Field: TField) of object;

  TzDbRecordViewRowsBuilder = class
  private
    FGrid: TcxDBVerticalGrid;
    FDataController: TzDataController;
    // Name dell'item delle props -> riga della griglia, e il contrario
    FRowsByItem: TDictionary<string, TcxCustomRow>;
    FItemsByRow: TDictionary<TcxCustomRow, string>;
    FRowCounter: integer;
    FLookupEditors: TzLookupEditors;
    function NewRowName(const ItemName: string): string;
    function FieldCaption(Item: TzRecordViewRow; Field: TField): string;
    function IsItemReadOnly(Item: TzRecordViewRow; Field: TField; const ReadOnlyOverall: boolean): boolean;
    procedure ConfigureEditorProperties(EditorProperties: TcxCustomEditorRowProperties; Item: TzRecordViewRow; Field: TField;
      const ReadOnlyOverall: boolean);
    function CreateCategoryRow(Item: TzRecordViewRow): TcxCategoryRow;
    function CreateFieldRow(Item: TzRecordViewRow; const ReadOnlyOverall: boolean): TcxDBEditorRow;
    function CreateMultiFieldRow(Item: TzRecordViewRow; const ReadOnlyOverall: boolean): TcxDBMultiEditorRow;
    procedure Register(Row: TcxCustomRow; const ItemName: string);
  public
    constructor Create(aGrid: TcxDBVerticalGrid; aDataController: TzDataController);
    destructor Destroy; override;

    // Ricrea tutte le righe dalle props. Le props devono essere gia' allineate
    // al dataset (TzRecordViewRows.ValidateDataset).
    procedure Build(Props: TzDbRecordViewProps; const ReadOnlyOverall: boolean; OnRowCreated: TzRecordViewRowCreatedEvent);

    // Riporta nelle props ordine, appartenenza alle categorie, visibilita',
    // altezza ed espansione delle righe, anche quelle create o spostate con il
    // modulo di personalizzazione della griglia
    procedure AssignToProps(Props: TzDbRecordViewProps);

    procedure ApplyRowEditability(Row: TcxCustomRow; const IsReadOnly: boolean);

    function RowOfItem(const ItemName: string): TcxCustomRow;
    function ItemOfRow(Row: TcxCustomRow): string;
    // Riga del campo, anche se il campo e' dentro una riga multipla
    function EditorPropertiesOfField(const FieldName: string): TcxCustomEditorRowProperties;

    // Lookup del dizionario nelle celle (della vista record): senza, i campi
    // di lookup restano caselle di testo
    property LookupEditors: TzLookupEditors read FLookupEditors write FLookupEditors;
  end;

// Options e' protetta in TcxCustomEditorRowProperties e pubblicata solo nelle
// classi derivate (riga singola, campo di una riga multipla): queste due
// funzioni valgono per entrambe
function EditorRowEditing(EditorProperties: TcxCustomEditorRowProperties): boolean;
procedure SetEditorRowEditing(EditorProperties: TcxCustomEditorRowProperties; const Value: boolean);

implementation

uses
  System.Generics.Defaults,
  zDX,
  zOverrides;

type
  TcxCustomEditorRowPropertiesAccess = class(TcxCustomEditorRowProperties);

function EditorRowEditing(EditorProperties: TcxCustomEditorRowProperties): boolean;
begin
  result := Assigned(EditorProperties) and TcxCustomEditorRowPropertiesAccess(EditorProperties).Options.Editing;
end;

procedure SetEditorRowEditing(EditorProperties: TcxCustomEditorRowProperties; const Value: boolean);
begin
  if Assigned(EditorProperties) then
    TcxCustomEditorRowPropertiesAccess(EditorProperties).Options.Editing := Value;
end;

{ TzDbRecordViewRowsBuilder }

constructor TzDbRecordViewRowsBuilder.Create(aGrid: TcxDBVerticalGrid; aDataController: TzDataController);
begin
  inherited Create;
  FGrid := aGrid;
  FDataController := aDataController;
  FRowsByItem := TDictionary<string, TcxCustomRow>.Create;
  FItemsByRow := TDictionary<TcxCustomRow, string>.Create;
  FRowCounter := 0;
  FLookupEditors := nil;
end;

destructor TzDbRecordViewRowsBuilder.Destroy;
begin
  FreeAndNil(FItemsByRow);
  FreeAndNil(FRowsByItem);
  inherited;
end;

function TzDbRecordViewRowsBuilder.NewRowName(const ItemName: string): string;
var
  Carattere: Char;
  Pulito: string;
begin
  // Il nome di un componente accetta solo lettere, cifre e sottolineato: le
  // categorie possono avere spazi o accenti nel nome. Il contatore evita i
  // doppioni fra frame diversi e fra ricostruzioni successive.
  Pulito := '';
  for Carattere in ItemName do
    if CharInSet(Carattere, ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_']) then
      Pulito := Pulito + Carattere;

  Inc(FRowCounter);
  result := Format('row%s_%d', [Pulito, FRowCounter]);
end;

procedure TzDbRecordViewRowsBuilder.Register(Row: TcxCustomRow; const ItemName: string);
begin
  FRowsByItem.AddOrSetValue(UpperCase(ItemName), Row);
  FItemsByRow.AddOrSetValue(Row, ItemName);
end;

function TzDbRecordViewRowsBuilder.RowOfItem(const ItemName: string): TcxCustomRow;
begin
  if not FRowsByItem.TryGetValue(UpperCase(ItemName), result) then
    result := nil;
end;

function TzDbRecordViewRowsBuilder.ItemOfRow(Row: TcxCustomRow): string;
begin
  if not FItemsByRow.TryGetValue(Row, result) then
    result := '';
end;

function TzDbRecordViewRowsBuilder.EditorPropertiesOfField(const FieldName: string): TcxCustomEditorRowProperties;
var
  i, j: integer;
  Row: TcxCustomRow;
  MultiRow: TcxDBMultiEditorRow;
begin
  result := nil;

  for i := 0 to FGrid.Rows.Count - 1 do
  begin
    Row := FGrid.Rows[i];

    if Row is TcxDBEditorRow then
    begin
      if SameText(TcxDBEditorRow(Row).Properties.DataBinding.FieldName, FieldName) then
        Exit(TcxDBEditorRow(Row).Properties);
    end
    else
      if Row is TcxDBMultiEditorRow then
      begin
        MultiRow := TcxDBMultiEditorRow(Row);
        for j := 0 to MultiRow.Properties.Editors.Count - 1 do
          if SameText(MultiRow.Properties.Editors[j].DataBinding.FieldName, FieldName) then
            Exit(MultiRow.Properties.Editors[j]);
      end;
  end;
end;

function TzDbRecordViewRowsBuilder.FieldCaption(Item: TzRecordViewRow; Field: TField): string;
begin
  // Stessa gerarchia di TzDbView e TzDbCard:
  // 1. override del cliente; 2. didascalia della riga o del dominio; 3. etichetta del campo
  result := '';

  if Assigned(Field) and FDataController.DataSetOk then
    result := Overrides.CaptionCard(FDataController.IdDataSet, Field.FieldName);

  if result.IsEmpty and Assigned(Item) then
    result := Item.Caption;

  if result.IsEmpty and Assigned(Field) then
    result := Field.DisplayLabel;
end;

function TzDbRecordViewRowsBuilder.IsItemReadOnly(Item: TzRecordViewRow; Field: TField; const ReadOnlyOverall: boolean): boolean;
begin
  result := ReadOnlyOverall;

  if Assigned(Item) and Item.ReadOnly then
    result := true;

  if Assigned(Item) and Assigned(Item.Domain) and Item.Domain.ReadOnly then
    result := true;

  if Assigned(Field) and Field.ReadOnly then
    result := true;
end;

procedure TzDbRecordViewRowsBuilder.ConfigureEditorProperties(EditorProperties: TcxCustomEditorRowProperties; Item: TzRecordViewRow;
  Field: TField; const ReadOnlyOverall: boolean);
var
  CtrlType: TzCtrlType;
  PropertiesClass: TcxCustomEditPropertiesClass;
  Domain: TzDomain;
  IsReadOnly: boolean;
  LookupReady: boolean;
begin
  Domain := nil;
  if Assigned(Item) then
    Domain := Item.Domain;

  EditorProperties.Caption := FieldCaption(Item, Field);

  if Assigned(Item) and (Item.Hint <> '') then
    EditorProperties.Hint := Item.Hint;

  // I campi di lookup del dataset hanno gia' l'editor giusto: non si tocca
  if not(Assigned(Field) and (Field.FieldKind = fkLookup)) then
  begin
    if Assigned(Item) then
      CtrlType := Item.zCtrlType
    else
      if Assigned(Domain) then
        CtrlType := Domain.zCtrlType
      else
        CtrlType := ctDefault;

    // Il lookup del dizionario ha bisogno del dataset di appoggio, che
    // prepara TzLookupEditors (zDbLookupEditors); se non si puo' la cella
    // resta una casella di testo, come in TzDbView
    LookupReady := False;

    if CtrlType.IsLookup then
    begin
      if Assigned(FLookupEditors) and Assigned(Domain) and Assigned(Field) and (Trim(Domain.Lookup) <> '') then
      begin
        PropertiesClass := dx.GetPropertiesClass(CtrlType);

        if Assigned(PropertiesClass) then
        begin
          EditorProperties.EditPropertiesClass := PropertiesClass;
          LookupReady := FLookupEditors.Configure(EditorProperties.EditProperties, Field.FieldName, Domain.Lookup, CtrlType = ctLookupHyperLink);
        end;
      end;

      if not LookupReady then
        CtrlType := ctEdit;
    end;

    if not LookupReady then
    begin
      PropertiesClass := dx.GetPropertiesClass(CtrlType);

      if Assigned(PropertiesClass) then
      begin
        EditorProperties.EditPropertiesClass := PropertiesClass;
        dx.InitProperties(CtrlType, EditorProperties.EditProperties, Domain, Field);
      end;
    end;
  end;

  IsReadOnly := IsItemReadOnly(Item, Field, ReadOnlyOverall);

  SetEditorRowEditing(EditorProperties, not IsReadOnly);
  if Assigned(EditorProperties.EditProperties) then
    EditorProperties.EditProperties.ReadOnly := IsReadOnly;
end;

function TzDbRecordViewRowsBuilder.CreateCategoryRow(Item: TzRecordViewRow): TcxCategoryRow;
begin
  result := FGrid.Add(TcxCategoryRow) as TcxCategoryRow;
  result.Name := NewRowName(Item.Name);
  result.Properties.Caption := Item.Caption;

  if Item.Hint <> '' then
    result.Properties.Hint := Item.Hint;

  result.Visible := Item.Visible;
  result.Expanded := Item.Expanded;

  if Item.Height > 0 then
    result.Height := Item.Height;

  Register(result, Item.Name);
end;

function TzDbRecordViewRowsBuilder.CreateFieldRow(Item: TzRecordViewRow; const ReadOnlyOverall: boolean): TcxDBEditorRow;
var
  Field: TField;
begin
  Field := nil;
  FDataController.TryGetField(Item.Name, Field);

  result := FGrid.Add(TcxDBEditorRow) as TcxDBEditorRow;
  result.Name := NewRowName(Item.Name);
  result.Properties.DataBinding.FieldName := Item.Name;

  ConfigureEditorProperties(result.Properties, Item, Field, ReadOnlyOverall);

  result.Visible := Item.Visible;

  if Item.Height > 0 then
    result.Height := Item.Height;

  Register(result, Item.Name);
end;

function TzDbRecordViewRowsBuilder.CreateMultiFieldRow(Item: TzRecordViewRow; const ReadOnlyOverall: boolean): TcxDBMultiEditorRow;
var
  i: integer;
  FieldName: string;
  Field: TField;
  EditorProperties: TcxDBEditorRowItemProperties;
  MemberItem: TzRecordViewRow;
begin
  result := FGrid.Add(TcxDBMultiEditorRow) as TcxDBMultiEditorRow;
  result.Name := NewRowName(Item.Name);

  for i := 0 to Item.Members.Count - 1 do
  begin
    FieldName := Trim(Item.Members[i]);
    if FieldName.IsEmpty then
      Continue;

    Field := nil;
    FDataController.TryGetField(FieldName, Field);

    EditorProperties := result.Properties.Editors.Add;
    EditorProperties.DataBinding.FieldName := FieldName;

    // Il campo affiancato prende didascalia, editor e sola lettura dalla
    // propria riga di campo, se esiste (anche nascosta)
    MemberItem := nil;
    if Item.Collection is TzRecordViewRows then
      MemberItem := TzRecordViewRows(Item.Collection).FieldRow(FieldName);

    ConfigureEditorProperties(EditorProperties, MemberItem, Field, ReadOnlyOverall or Item.ReadOnly);
  end;

  result.Visible := Item.Visible;

  if Item.Height > 0 then
    result.Height := Item.Height;

  Register(result, Item.Name);
end;

procedure TzDbRecordViewRowsBuilder.Build(Props: TzDbRecordViewProps; const ReadOnlyOverall: boolean; OnRowCreated: TzRecordViewRowCreatedEvent);
var
  Item: TzRecordViewRow;
  Row, ParentRow: TcxCustomRow;
  Field: TField;
  Counters: TDictionary<TObject, integer>;
  Position: integer;
  ParentKey: TObject;
begin
  FGrid.BeginUpdate;
  try
    // gli editor dei lookup si sganciano finche' le righe esistono ancora
    if Assigned(FLookupEditors) then
      FLookupEditors.Clear;

    FGrid.ClearRows;
    FRowsByItem.Clear;
    FItemsByRow.Clear;

    if not Assigned(Props) then
      Exit;

    // 1. categorie, poi campi: una riga figlia trova sempre il padre gia' creato
    for Item in Props.Rows do
      if Item.RowKind = rkCategory then
        CreateCategoryRow(Item);

    for Item in Props.Rows do
      case Item.RowKind of
        rkField:
          CreateFieldRow(Item, ReadOnlyOverall);
        rkMultiField:
          if Item.Members.Count > 0 then
            CreateMultiFieldRow(Item, ReadOnlyOverall);
      end;

    // 2. appartenenza alle categorie (anche categoria dentro categoria)
    for Item in Props.Rows do
    begin
      if Item.ParentName.IsEmpty then
        Continue;

      Row := RowOfItem(Item.Name);
      ParentRow := RowOfItem(Item.ParentName);

      if Assigned(Row) and Assigned(ParentRow) and (ParentRow is TcxCategoryRow) and (ParentRow <> Row) and not Row.IsParent(ParentRow) then
        Row.Parent := ParentRow;
    end;

    // 3. ordine: quello della collezione, livello per livello. Il padre delle
    // righe di primo livello e' nil: la chiave diventa la griglia stessa.
    Counters := TDictionary<TObject, integer>.Create;
    try
      for Item in Props.Rows do
      begin
        Row := RowOfItem(Item.Name);
        if not Assigned(Row) then
          Continue;

        if Assigned(Row.Parent) then
          ParentKey := Row.Parent
        else
          ParentKey := FGrid;

        if not Counters.TryGetValue(ParentKey, Position) then
          Position := 0;

        Row.Index := Position;
        Counters.AddOrSetValue(ParentKey, Position + 1);
      end;
    finally
      FreeAndNil(Counters);
    end;

    // 4. notifica alla form, a righe complete
    if Assigned(OnRowCreated) then
      for Item in Props.Rows do
      begin
        Row := RowOfItem(Item.Name);
        if not Assigned(Row) then
          Continue;

        Field := nil;
        if Item.IsField then
          FDataController.TryGetField(Item.Name, Field);

        OnRowCreated(FGrid, Row, Item, Field);
      end;
  finally
    FGrid.EndUpdate;
  end;
end;

procedure TzDbRecordViewRowsBuilder.AssignToProps(Props: TzDbRecordViewProps);
var
  Backup: TzRecordViewRows;
  Ordered: TList<TcxCustomRow>;
  Row: TcxCustomRow;
  Item, OldItem: TzRecordViewRow;
  ItemName: string;
  i, j: integer;
  CategoryCounter: integer;

  procedure CollectChildren(Parent: TcxCustomRow);
  var
    k: integer;
  begin
    for k := 0 to Parent.Count - 1 do
    begin
      Ordered.Add(Parent.Rows[k]);
      CollectChildren(Parent.Rows[k]);
    end;
  end;

  // La radice della griglia non e' pubblica: le righe di primo livello sono
  // quelle senza padre, nell'ordine del loro Index
  procedure CollectTopLevel;
  var
    TopLevel: TList<TcxCustomRow>;
    k: integer;
    TopRow: TcxCustomRow;
  begin
    TopLevel := TList<TcxCustomRow>.Create;
    try
      for k := 0 to FGrid.Rows.Count - 1 do
        if FGrid.Rows[k].Parent = nil then
          TopLevel.Add(FGrid.Rows[k]);

      TopLevel.Sort(TComparer<TcxCustomRow>.Construct(
        function(const Left, Right: TcxCustomRow): integer
        begin
          result := Left.Index - Right.Index;
        end));

      for TopRow in TopLevel do
      begin
        Ordered.Add(TopRow);
        CollectChildren(TopRow);
      end;
    finally
      FreeAndNil(TopLevel);
    end;
  end;

begin
  if not Assigned(Props) then
    Exit;

  Backup := TzRecordViewRows.Create(nil);
  Ordered := TList<TcxCustomRow>.Create;
  try
    Backup.Assign(Props.Rows);

    // righe in ordine di visualizzazione
    CollectTopLevel;

    CategoryCounter := 0;

    Props.Rows.BeginUpdate;
    try
      Props.Rows.Clear;

      for Row in Ordered do
      begin
        ItemName := ItemOfRow(Row);

        // categoria nata nel modulo di personalizzazione: nome nuovo
        if ItemName.IsEmpty and (Row is TcxCategoryRow) then
        begin
          repeat
            Inc(CategoryCounter);
            ItemName := Format('CATEGORIA_%d', [CategoryCounter]);
          until (Backup.get(ItemName, False) = nil) and (Props.Rows.get(ItemName, False) = nil);

          Register(Row, ItemName);
        end;

        if ItemName.IsEmpty then
          Continue;

        Item := Props.Rows.Add;

        OldItem := Backup.get(ItemName, False);
        if Assigned(OldItem) then
          Item.Assign(OldItem)
        else
        begin
          Item.Name := ItemName;
          if Row is TcxCategoryRow then
            Item.RowKind := rkCategory;
        end;

        if Row is TcxCategoryRow then
          Item.Caption := TcxCategoryRow(Row).Properties.Caption;

        Item.Visible := Row.Visible;
        Item.Expanded := Row.Expanded;
        Item.Height := Row.Height;

        if Assigned(Row.Parent) then
          Item.ParentName := ItemOfRow(Row.Parent)
        else
          Item.ParentName := '';
      end;

      // le righe che non sono a video (per esempio di campi senza riga) restano in coda
      for i := 0 to Backup.Count - 1 do
        if Props.Rows.get(Backup[i].Name, False) = nil then
        begin
          Item := Props.Rows.Add;
          Item.Assign(Backup[i]);
        end;

      // un campo affiancato in una riga multipla non va perso
      for i := 0 to Props.Rows.Count - 1 do
        if Props.Rows[i].RowKind = rkMultiField then
          for j := Props.Rows[i].Members.Count - 1 downto 0 do
            if Trim(Props.Rows[i].Members[j]).IsEmpty then
              Props.Rows[i].Members.Delete(j);
    finally
      Props.Rows.EndUpdate;
    end;
  finally
    FreeAndNil(Ordered);
    FreeAndNil(Backup);
  end;
end;

procedure TzDbRecordViewRowsBuilder.ApplyRowEditability(Row: TcxCustomRow; const IsReadOnly: boolean);
var
  i: integer;
  MultiRow: TcxDBMultiEditorRow;
begin
  if Row is TcxDBEditorRow then
  begin
    TcxDBEditorRow(Row).Properties.Options.Editing := not IsReadOnly;
    if Assigned(TcxDBEditorRow(Row).Properties.EditProperties) then
      TcxDBEditorRow(Row).Properties.EditProperties.ReadOnly := IsReadOnly;
  end
  else
    if Row is TcxDBMultiEditorRow then
    begin
      MultiRow := TcxDBMultiEditorRow(Row);
      for i := 0 to MultiRow.Properties.Editors.Count - 1 do
      begin
        MultiRow.Properties.Editors[i].Options.Editing := not IsReadOnly;
        if Assigned(MultiRow.Properties.Editors[i].EditProperties) then
          MultiRow.Properties.Editors[i].EditProperties.ReadOnly := IsReadOnly;
      end;
    end;
end;

end.
