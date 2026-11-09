unit zDbView.Filter;

interface

uses
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Winapi.Windows,
  data.db,
  cxGridDBTableView,
  cxFilter,
  cxDBData,
  dxBar,
  cxFilterControl,
  cxFilterControlUtils,
  Vcl.ExtCtrls,
  Vcl.Controls,
  dxMessages,
  zDataController;

const
  // verifica differita del cambiamento del filtro (vedi TzFilterControl.DoLayoutChange)
  ZM_FILTER_CHECKCHANGED = WM_USER + 1841;

type
  TzFilterControl = class(TcxFilterControl)
  private
    FOnChange: TNotifyEvent;
    FUpdateLinkComponentCount: Integer;
  private
    LastFilterText: string;
    Changing: boolean;
  protected
    function IsUpdatingLinkComponent: boolean;
  private
    { Nessuna modifica ai sorgenti DevExpress: AddCondition e ValueEditorHide di
      cxFilterControl non sono virtual, ma sono protected e quindi chiamabili.
      I punti in cui il controllo li invoca vengono intercettati cosi':

      - value editor: SelectValue (virtual) crea l'editor e gli assegna gli
        handler privati OnExit/OnKeyDown/OnAfterKeyDown, che chiamano
        ValueEditorHide(True). Qui si riagganciano a handler propri che prima
        pre-validano il valore (Mantis #41) e dopo notificano il cambiamento.
      - ApplyFilter (BuildFromRows chiama ValueEditorHide(True)): reintrodotto
        con la stessa pre-validazione.
      - AddCondition / Remove da tastiera e mouse: KeyDown e MouseDown (virtual).
      - AddCondition / AddGroup / Remove dal menu: WMDropDownMenuClosed.
      - rete di sicurezza: DoLayoutChange (virtual) posta una verifica
        differita; Changed confronta comunque il testo del filtro con l'ultimo
        notificato, quindi i trigger ridondanti non producono OnChange doppi. }
    FOrigValueEditorExit: TNotifyEvent;
    FOrigValueEditorKeyDown: TKeyEvent;
    FOrigValueEditorAfterKeyDown: TKeyEvent;
    FCheckChangedPosted: boolean;
    procedure ValueEditorExitHook(Sender: TObject);
    procedure ValueEditorKeyDownHook(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ValueEditorAfterKeyDownHook(Sender: TObject; var Key: Word; Shift: TShiftState);
    // Mantis #41: se il valore digitato non e' applicabile e non e' recuperabile,
    // chiude l'editor senza accettare (ValueEditorHide(False)) PRIMA che il
    // codice DevExpress lo accetti.
    procedure PreparaAccettazioneValore;
    procedure PostaVerificaCambiamento;
    procedure ZMCheckChanged(var Message: TMessage); message ZM_FILTER_CHECKCHANGED;
  protected
    procedure SelectValue(AActivateKind: TcxActivateValueEditKind; AKey: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoLayoutChange; override;
    // non esiste override per i messaggi: il corpo replica quello originale
    procedure WMDropDownMenuClosed(var Message: TMessage); message DXWM_FILTERCONTROL_DROPDOWNMENUCLOSED;
    procedure InternalChanged;

    // Mantis Gesty 37
    procedure MouseLeave(AControl: TControl); override;
    ///

    // Mantis #41 - 2026-07-23: valore filtro data fuori scala -> Calc a meta' -> AV in paint
    function IsValueEditorValueValid: boolean;
    function TryNormalizeValueEditorDate: boolean;
    procedure Paint; override;
    ///
  public
    constructor Create(AOwner: TComponent); override;

    // reintroduce: BuildFromRows chiama ValueEditorHide(True) senza passare
    // dagli handler dell'editor, quindi la pre-validazione va fatta qui
    procedure ApplyFilter;

    procedure Changed;

    procedure BeginUpdateLinkComponent;
    procedure EndUpdateLinkComponent;
    procedure LinkComponentChanged;
    // altezza
    function RequiredHeight: Integer;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TzDbViewFilterController = class(TObject)
  private
    SubMenuButtons: TList<TdxBarButton>;
    DisableFilter: boolean;
    FDataController: TzDataController;
    FView: TcxGridDBTableView;
    procedure FormatFilterTextValue(Sender: TcxDBDataFilterCriteria; AItem: TcxFilterCriteriaItem; const AValue: Variant; var ADisplayValue: string);
    function CanFilter: boolean;
    procedure MenuFilterClick(Sender: TObject);

    function AddFilter(column: TcxGridDBColumn; OperatorKind: TcxFilterOperatorKind; const AValue: Variant; const ADisplayValue: string): TcxFilterCriteriaItem;
  public
    // Promossa a class function pubblica per testabilita': non usa stato
    // dell'istanza, interpreta solo la sintassi del testo digitato
    // (asterisco finale = ricerca "contiene").
    class procedure ParseStringFilterValue(var s: string; var FilterOperatorKind: TcxFilterOperatorKind); static;
    // Mantis #4777 - 2026-11-02: valore della condizione creata dal menu dei filtri
    // (tasto destro sulla colonna). "e' vuoto" e "non e' vuoto" vogliono Null, non il
    // valore della cella; "fra" e "nell'elenco" vogliono un array; gli altri il valore.
    class function ValoreFiltroDaMenu(Operatore: TcxFilterControlOperator; const ValoreCampo: Variant): Variant; static;
    // Finestra del "Filtro per valore" (F3), in comune fra zDbView e zDbPivot
    // (dal 2026-09-30). Origine e' l'origine del campo nel dizionario, Etichetta
    // il nome mostrato, Proposto il valore iniziale (Null = nessuno). Il
    // risultato:
    //   False                -> annullato, non si cambia niente;
    //   True, Valore = Null  -> valore svuotato, la condizione sul campo si toglie;
    //   True, Valore         -> condizione Operatore con quel valore.
    // Elenchi di scelta e Si'/No: foEqual. Date e ore: foEqual, senza Proposto
    // oggi o adesso. Testo: in maiuscolo, "inizia per", con * in fondo
    // "contiene". Numeri: caselle numeriche e foEqual, oppure con
    // NumeriComeTesto come il testo (nel pivot un numero e' un'etichetta:
    // anno, codice, classe; "3" deve trovare anche 30).
    class function ChiediFiltroPerValore(Campo: TField; const Origine, Etichetta: string; const Proposto: Variant;
      out Valore: Variant; out Operatore: TcxFilterOperatorKind): boolean; overload; static;
    class function ChiediFiltroPerValore(Campo: TField; const Origine, Etichetta: string; const Proposto: Variant;
      NumeriComeTesto: boolean; out Valore: Variant; out Operatore: TcxFilterOperatorKind): boolean; overload; static;
  public
    constructor Create(aDataController: TzDataController; aView: TcxGridDBTableView);
    destructor Destroy; override;
    procedure InitFilters;
    procedure ApplyFilter;
    procedure Clear; overload;
    procedure FilterByValue;
    procedure FilterByFindText;
    procedure OpenFilterDialog;
    //
    procedure BeginUpdate;
    procedure EndUpdate;
    function FilterCount: Integer;

    procedure AddFilterCondition(FieldName: string; OperatorKind: TcxFilterOperatorKind; Value: Variant; Checked: boolean = true; Overwrite: boolean = true);
    procedure DeleteConditionsForField(FieldName: string);
    // procedure SetAdditionalFilter(const AdditionalFilter: string);

    procedure PrepareFilterMenuForField(FieldName: string; SubMenu: TdxBarSubItem);

    procedure RevertSQL;

    property DataController: TzDataController read FDataController write FDataController;
    property View: TcxGridDBTableView read FView write FView;
  end;

implementation

uses
  System.Rtti,
  System.Types,
  System.UITypes,
  System.StrUtils,
  System.Variants,
  System.DateUtils,
  data.DBConsts,
  Vcl.Forms,
  cxCustomData,
  cxTextEdit,
  cxDB,
  cxDBFilter,
  cxEdit,
  cxDropDownEdit,
  cxImageComboBox,
  zLocalizer.Helper,
  zMsg,
  zFbDataSet,
  zSystem,
  zBaseLib,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

var
  siFilter: TSiSession;

  /// /////////////////////////////////////////////////////////////////////////////
  /// gestione IS NULL/IS NOT NULL e LIKE/CONTAINING

type
  TcxFilterControlDropDownMenuAccess = class(TcxFilterControlDropDownMenu);

  TcxFilterContainingOperator = class(TcxFilterLikeOperator)
  public
    function FilterText: string; override;
  end;

  TcxFilterNotContainingOperator = class(TcxFilterNotLikeOperator)
  public
    function FilterText: string; override;
  end;

  TzFbDataSetFilterOperatorAdapter = class(TcxDBFilterOperatorAdapter)
  public
    procedure PrepareOperatorClass(ASender: TObject; ADataSet: TDataSet; var AOperatorClass: TcxFilterOperatorClass); override;
  end;

  { TcxFilterContainingOperator }

function TcxFilterContainingOperator.FilterText: string;
begin
  Result := 'CONTAINING';
end;

{ TcxFilterNotContainingOperator }

function TcxFilterNotContainingOperator.FilterText: string;
begin
  Result := 'NOT CONTAINING';
end;

{ TzFbDataSetFilterOperatorAdapter }

procedure TzFbDataSetFilterOperatorAdapter.PrepareOperatorClass(ASender: TObject; ADataSet: TDataSet; var AOperatorClass: TcxFilterOperatorClass);
var
  CriteriaItem: TcxFilterCriteriaItem;
begin

  if AOperatorClass.InheritsFrom(TcxFilterNotNullOperator) then
    AOperatorClass := TcxFilterSQLNotNullOperator
  else
    if AOperatorClass.InheritsFrom(TcxFilterNullOperator) then
      AOperatorClass := TcxFilterSQLNullOperator
    else
    begin
      CriteriaItem := ASender as TcxFilterCriteriaItem;

      case CriteriaItem.OperatorKind of
        foEqual:
          ;
        foNotEqual:
          ;
        foLess:
          ;
        foLessEqual:
          ;
        foGreater:
          ;
        foGreaterEqual:
          ;
        foLike:
          AOperatorClass := TcxFilterContainingOperator; // ZZ 24.05.2019 Mantis 752
        foNotLike:
          AOperatorClass := TcxFilterNotContainingOperator;
        foBetween:
          ;
        foNotBetween:
          ;
        foInList:
          ;
        foNotInList:
          ;
        foYesterday:
          ;
        foToday:
          ;
        foTomorrow:
          ;
        foLast7Days:
          ;
        foLastWeek:
          ;
        foLast14Days:
          ;
        foLastTwoWeeks:
          ;
        foLast30Days:
          ;
        foLastMonth:
          ;
        foLastYear:
          ;
        foInPast:
          ;
        foThisWeek:
          ;
        foThisMonth:
          ;
        foThisYear:
          ;
        foNext7Days:
          ;
        foNextWeek:
          ;
        foNext14Days:
          ;
        foNextTwoWeeks:
          ;
        foNext30Days:
          ;
        foNextMonth:
          ;
        foNextYear:
          ;
        foInFuture:
          ;
        foContains:
          AOperatorClass := TcxFilterContainingOperator;
        foNotContains:
          AOperatorClass := TcxFilterNotContainingOperator;
        foBeginsWith:
          ;
        foEndsWith:
          ;
      end;

      // // 'TcxGridDBDataFilterCriteriaItem'
      // if AOperatorClass.InheritsFrom(TcxFilterNullOperator) then
      // AOperatorClass := TcxFilterSQLNullOperator
      // else
      // if AOperatorClass.InheritsFrom(TcxFilterNotNullOperator) then
      // AOperatorClass := TcxFilterSQLNotNullOperator
      // else
      // if AOperatorClass.InheritsFrom(TcxFilterContainsOperator) or AOperatorClass.InheritsFrom(TcxFilterLikeOperator) then
      // AOperatorClass := TcxFilterContainingOperator
      // else
      // if AOperatorClass.InheritsFrom(TcxFilterNotContainsOperator) or AOperatorClass.InheritsFrom(TcxFilterNotLikeOperator) then
      // AOperatorClass := TcxFilterNotContainingOperator;
    end;
end;

/// /////////////////////////////////////////////////////////////////////////////

{ TzDbViewFilterController }

constructor TzDbViewFilterController.Create(aDataController: TzDataController; aView: TcxGridDBTableView);
begin
  inherited Create;
  Assert(Assigned(aDataController));
  Assert(Assigned(aView));

  FDataController := aDataController;
  FView := aView;
  View.DataController.Filter.OnFormatFilterTextValue := FormatFilterTextValue;

  SubMenuButtons := TList<TdxBarButton>.Create;

  DisableFilter := false;
end;

destructor TzDbViewFilterController.Destroy;
begin
  FreeAndNil(SubMenuButtons);
  inherited;
end;

procedure TzDbViewFilterController.AddFilterCondition(FieldName: string; OperatorKind: TcxFilterOperatorKind; Value: Variant; Checked: boolean = true; Overwrite: boolean = true);
var
  column: TcxGridDBColumn;
  item: TcxFilterCriteriaItem;
  DisplayValue: string;
begin
  column := View.GetColumnByFieldName(FieldName);
  if not Assigned(column) then
    Exit;

  if Overwrite then
    View.DataController.Filter.RemoveItemByItemLink(column);

  if varIsNull(Value) then
    DisplayValue := ''
  else
    DisplayValue := VarToStr(Value);

  item := AddFilter(column, OperatorKind, Value, DisplayValue); // DisplayText); se viene variato displaytext non � pi� attuale

  // se il filtro � stato disattivato non funziona pk & co
  View.DataController.Filter.Active := true;
end;

function TzDbViewFilterController.CanFilter: boolean;
begin
  Result := DataController.DataSetOk and (not DisableFilter);
end;

procedure TzDbViewFilterController.Clear;
begin
  if not CanFilter then
    Exit;

  View.DataController.Filter.Clear;
end;

procedure TzDbViewFilterController.FormatFilterTextValue(Sender: TcxDBDataFilterCriteria; AItem: TcxFilterCriteriaItem; const AValue: Variant; var ADisplayValue: string);
var
  FormatSettings: TFormatSettings;
  Field: TField;
begin
  if varIsNull(AValue) then
    Exit
  else
    if VarIsFloat(AValue) then
    begin
      GetLocaleFormatSettings(GetThreadLocale, FormatSettings);
      FormatSettings.DecimalSeparator := '.';
      ADisplayValue := FloatToStr(AValue, FormatSettings);
    end
    else
    begin
      if not Assigned(AItem.Itemlink) then
        Exit;

      if AItem.Itemlink is TcxGridDBColumn then
      begin
        Field := TcxGridDBColumn(AItem.Itemlink).DataBinding.Field;
        if not Assigned(Field) then
          Exit;

        if Field.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
        begin
          FormatSettings.DateSeparator := '.';
          FormatSettings.TimeSeparator := ':';
          FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
          FormatSettings.LongTimeFormat := 'hh:nn';

          case Field.DataType of
            ftDate:
              ADisplayValue := DateToStr(AValue, FormatSettings);
            ftTime:
              ADisplayValue := TimeToStr(AValue, FormatSettings);
            ftDateTime, ftTimeStamp:
              begin
                // FormatSettings.ShortDateFormat := 'dd.mm.yyyy hh:nn';
                // ADisplayValue := DateTimeToStr(AValue, FormatSettings);
                // Mantis 5286

                // if aItem. then
                // IgnoreTimeForFiltering

                ADisplayValue := FormatDateTime('dd.mm.yyyy hh:nn:ss.zzzz', AValue);
              end;
          end;

          AItem.Criteria.DateTimeFormat := '';
          ADisplayValue := ADisplayValue.QuotedString(#39);
        end;
      end;
    end;
end;

procedure TzDbViewFilterController.ApplyFilter;
begin
  if not CanFilter then
    Exit;

  // if View.DataController.Filter.Active then
  // DataController.SQL_Where := View.DataController.Filter.FilterText
  // else
  // DataController.SQL_Where := '';

  if View.DataController.Filter.Active then
    DataController.ApplyFilter(View.DataController.Filter.FilterText)
  else
    DataController.ApplyFilter('');
end;

procedure TzDbViewFilterController.BeginUpdate;
begin
  View.DataController.Filter.BeginUpdate;
end;

procedure TzDbViewFilterController.DeleteConditionsForField(FieldName: string);
var
  column: TcxGridDBColumn;
begin
  column := View.GetColumnByFieldName(FieldName);
  if Assigned(column) then
    View.DataController.Filter.RemoveItemByItemLink(column);
end;

procedure TzDbViewFilterController.EndUpdate;
begin
  View.DataController.Filter.EndUpdate;
end;

procedure TzDbViewFilterController.InitFilters;
var
  FieldName: string;
  i: Integer;
  OrderBy: string;
  Str: TStringList;
  SortOrder: TcxDataSortOrder;
  column: TcxGridDBColumn;
  s: string;
begin
  DisableFilter := true;
  try
    View.DataController.Filter.Options := [fcoCaseInsensitive, fcoShowOperatorDescription];
    // View.DataController.Filter.OnChanged := ViewDataControllerFilterChanged;
    View.DataController.Filter.Active := true;
    // View.DataController.Filter.DateTimeFormat := 'dd.mm.yyyy hh:nn';
    View.DataController.Filter.IgnoreOrigin := false;
  finally
    DisableFilter := false;
  end;
end;

procedure TzDbViewFilterController.FilterByFindText;
var
  column: TcxGridDBColumn;
  Field: TField;
  UsareLike: boolean;
  Value: Variant;
  s: string;
  i: Integer;
  i64: Int64;
  f: Double;
  d: TDateTime;
  FilterOperatorKind: TcxFilterOperatorKind;
begin

  s := View.DataController.FindCriteria.Text;
  FilterOperatorKind := foEqual;
  column := TcxGridDBColumn(View.Controller.FocusedColumn);

  if not Assigned(column) then // RowSelected
    Exit;

  Field := column.DataBinding.Field;
  if not Assigned(Field) then
    Exit;

  Value := null;

  if not s.IsEmpty then
  begin
    case Field.DataType of
      ftUnknown:
        ;
      ftString, ftBoolean, ftGuid, ftMemo, ftFmtMemo, ftFixedChar, ftWideString, ftWideMemo:
        begin
          FilterOperatorKind := foBeginsWith;
          ParseStringFilterValue(s, FilterOperatorKind);
          Value := s;
        end;
      ftAutoInc, ftSmallint, ftInteger, ftWord:
        begin
          i := s.Replace('.', '', [rfReplaceAll]).ToInteger();
          Value := i;
        end;
      ftLargeint:
        begin
          i64 := s.Replace('.', '', [rfReplaceAll]).ToInt64();
          Value := i64;
        end;

      ftFloat, ftCurrency, ftBCD, ftFMTBcd:
        begin
          f := s.ToDouble(s);
          Value := f;
        end;
      ftDate, ftTime, ftDateTime, ftTimeStamp:
        begin
          if s.IsEmpty then
          begin
            case Field.DataType of
              ftDate:
                d := System.SysUtils.Date;
              ftTime:
                d := System.SysUtils.Time;
              ftDateTime, ftTimeStamp:
                d := System.SysUtils.Now;
            end;
          end
          else
            d := StrToDateTime(s);

          Value := d;
        end;
    end;
  end;

  View.DataController.Filter.RemoveItemByItemLink(column);

  if not varIsNull(Value) then
    AddFilter(column, FilterOperatorKind, Value, VarToStr(Value)); // DisplayText); se viene variato displaytext non � pi� attuale
end;

procedure TzDbViewFilterController.FilterByValue;
var
  column: TcxGridDBColumn;
  Field: TField;
  Value: Variant;
  FilterOperatorKind: TcxFilterOperatorKind;
begin
  column := TcxGridDBColumn(View.Controller.FocusedColumn);

  if not Assigned(column) then
    Exit;

  Field := column.DataBinding.Field;

  // Il valore proposto e' quello del record corrente
  if not ChiediFiltroPerValore(Field, DataController.GetFieldOrigin(Field), Field.DisplayLabel, Field.Value, Value,
    FilterOperatorKind) then
    Exit;

  View.DataController.Filter.RemoveItemByItemLink(column);

  if not varIsNull(Value) then
    AddFilter(column, FilterOperatorKind, Value, VarToStr(Value)); // DisplayText: se viene variato displaytext non e' piu' attuale
end;

class function TzDbViewFilterController.ChiediFiltroPerValore(Campo: TField; const Origine, Etichetta: string;
  const Proposto: Variant; out Valore: Variant; out Operatore: TcxFilterOperatorKind): boolean;
begin
  Result := ChiediFiltroPerValore(Campo, Origine, Etichetta, Proposto, false, Valore, Operatore);
end;

class function TzDbViewFilterController.ChiediFiltroPerValore(Campo: TField; const Origine, Etichetta: string;
  const Proposto: Variant; NumeriComeTesto: boolean; out Valore: Variant; out Operatore: TcxFilterOperatorKind): boolean;
const
  TitoloFinestra = 'Filtro per valore';
  TipiTesto = [ftUnknown, ftString, ftBoolean, ftGuid, ftMemo, ftFmtMemo, ftFixedChar, ftWideString, ftWideMemo];
  TipiData = [ftDate, ftTime, ftDateTime, ftTimeStamp];
  TipiNumero = [ftAutoInc, ftSmallint, ftInteger, ftWord, ftLargeint, ftFloat, ftCurrency, ftBCD, ftFMTBcd];
var
  Domain: TzDomain;
  Items: TStringList;
  Testo: string;
  Intero: Integer;
  Intero64: Int64;
  Decimale: Double;
  DataScelta: TDateTime;
  ComeTesto: boolean;
begin
  Result := false;
  Valore := null;
  Operatore := foEqual;

  if not Assigned(Campo) then
    Exit;

  Domain := base.zDataDictionary.Get(Origine, true); // al massimo non verra' salvato

  // Elenco di scelta e Si'/No
  if Domain.zCtrlType in [ctPickList, ctPickListImage, ctCheckBox] then
  begin
    Items := TStringList.Create;
    try
      if Domain.zCtrlType = ctCheckBox then
      begin
        if Campo is TBooleanField then
        begin
          Items.AddPair('S'#$00EC, STextTrue);
          Items.AddPair('No', STextFalse);
        end
        else
        begin
          Items.AddPair('S'#$00EC, 'S');
          Items.AddPair('No', 'N');
        end;
      end
      else
        if Assigned(Domain.PickList_Obj) then
          Domain.PickList_Obj.AssignToStrings(Items);

      Testo := VarToStr(Proposto);
      if Testo.IsEmpty and (Campo is TBooleanField) then
        Testo := STextFalse;

      if not InputCombo(TitoloFinestra, Etichetta, Testo, Items) then
        Exit;

      Testo := Testo.Trim;
      if not Testo.IsEmpty then
        if Campo is TBooleanField then
          Valore := Testo = STextTrue
        else
          Valore := Testo;
    finally
      FreeAndNil(Items);
    end;

    Exit(true);
  end;

  // Testo: i tipi di testo; con NumeriComeTesto tutto quello che non e' una
  // data o un'ora, come faceva il pivot
  if NumeriComeTesto then
    ComeTesto := not (Campo.DataType in TipiData)
  else
    ComeTesto := Campo.DataType in TipiTesto;

  case Campo.DataType of
    ftDate:
      begin
        DataScelta := System.SysUtils.Date;
        if not VarIsNull(Proposto) then
          DataScelta := DateOf(VarToDateTime(Proposto));
        if not zMsg.InputDate(TitoloFinestra, Etichetta, DataScelta, dkDate) then
          Exit;
        Valore := DataScelta;
      end;
    ftTime:
      begin
        DataScelta := System.SysUtils.Time;
        if not VarIsNull(Proposto) then
          DataScelta := TimeOf(VarToDateTime(Proposto));
        if not zMsg.InputDate(TitoloFinestra, Etichetta, DataScelta, dkTime) then
          Exit;
        Valore := DataScelta;
      end;
    ftDateTime, ftTimeStamp:
      begin
        DataScelta := System.SysUtils.Now;
        if not VarIsNull(Proposto) then
          DataScelta := VarToDateTime(Proposto);
        if not zMsg.InputDate(TitoloFinestra, Etichetta, DataScelta, dkDateTime) then
          Exit;
        Valore := DataScelta;
      end;
    ftAutoInc, ftSmallint, ftInteger, ftWord:
      if not ComeTesto then
      begin
        Intero := 0;
        if not VarIsNull(Proposto) then
          Intero := Proposto;
        if not InputInteger(TitoloFinestra, Etichetta, Intero) then
          Exit;
        Valore := Intero;
      end;
    ftLargeint:
      if not ComeTesto then
      begin
        Intero64 := 0;
        if not VarIsNull(Proposto) then
          Intero64 := Proposto;
        if not InputInt64(TitoloFinestra, Etichetta, Intero64) then
          Exit;
        Valore := Intero64;
      end;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd:
      if not ComeTesto then
      begin
        Decimale := 0;
        if not VarIsNull(Proposto) then
          Decimale := Proposto;
        if not InputDouble(TitoloFinestra, Etichetta, Decimale) then
          Exit;
        Valore := Decimale;
      end;
  end;

  if ComeTesto then
  begin
    // testo: in maiuscolo, "inizia per", con * in fondo "contiene"; il solo *
    // equivale a svuotare
    Testo := VarToStr(Proposto);
    if not InputString(TitoloFinestra, Etichetta + ' (* per contiene)', Testo) then
      Exit;

    Testo := Testo.ToUpper.Trim;
    if not Testo.IsEmpty then
    begin
      ParseStringFilterValue(Testo, Operatore);
      if not Testo.IsEmpty then
        Valore := Testo;
    end;
  end
  else
    if not (Campo.DataType in TipiData + TipiNumero) then
      // tipo che la finestra non sa chiedere (blob, oggetti): nessuna finestra,
      // niente da cambiare
      Exit;

  Result := true;
end;

function TzDbViewFilterController.FilterCount: Integer;
begin
  Result := View.DataController.Filter.Root.Count;
end;

procedure TzDbViewFilterController.OpenFilterDialog;
begin
  View.Filtering.RunCustomizeDialog;
end;

procedure TzDbViewFilterController.RevertSQL;
begin
  InitFilters;
end;

class procedure TzDbViewFilterController.ParseStringFilterValue(var s: string; var FilterOperatorKind: TcxFilterOperatorKind);
begin
  FilterOperatorKind := foBeginsWith;

  if s.EndsWith('*') then
  begin
    FilterOperatorKind := foContains;
    s := System.Copy(s, 0, Length(s) - 1);
  end;
  // if s.EndsWith('*') then // ZZ 06.05.2019
  // begin
  // FilterOperatorKind := foLike;
  // s := '%' + System.Copy(s, 0, Length(s) - 1) + '%';
  // end
  // else
  // s := s + '%';
end;

procedure TzDbViewFilterController.PrepareFilterMenuForField(FieldName: string; SubMenu: TdxBarSubItem);
var
  MenuItem: TdxBarButton;
  i: Integer;
  Field: TField;
  FilterEditHelper: TcxCustomFilterEditHelperClass;
  FilterControlOperators: TcxFilterControlOperators;
  FilterControlOperator: TcxFilterControlOperator;

  Categoria: string;
  columm: TcxGridDBColumn;
begin

  for i := SubMenuButtons.Count - 1 downto 0 do
  begin
    MenuItem := SubMenuButtons[i];
    SubMenuButtons.Remove(MenuItem);
    FreeAndNil(MenuItem);
  end;

  SubMenuButtons.Clear;

  /// ////////////////////////////////////////////////////

  if not Assigned(SubMenu) then
    Exit;

  if not DataController.TryGetField(FieldName, Field) then
    Exit;

  columm := TcxGridDBColumn(View.Controller.FocusedColumn);
  FilterEditHelper := FilterEditsController.FindHelper(columm.PropertiesClass);

  if not Assigned(FilterEditHelper) then
    FilterEditHelper := TcxFilterTextEditHelper;

  // 04.09.2020: aggiunto l'ultimo parametro per aggiungere betweeen & co
  FilterControlOperators := FilterEditHelper.GetSupportedFilterOperators(columm.Properties, columm.DataBinding.ValueTypeClass, true);

  Categoria := columm.DataBinding.ValueTypeClass.Caption;
  SubMenu.Caption := 'Filtri ' + Categoria;

  for FilterControlOperator in FilterControlOperators do
    if not(FilterControlOperator in [fcoLike, fcoNotLike]) then // caso TcxFilterMemoHelper.GetSupportedFilterOperators: vengono esposti like e contains
    begin
      MenuItem := TdxBarButton.Create(SubMenu.Owner);
      SubMenuButtons.Add(MenuItem);
      SubMenu.ItemLinks.Add(MenuItem);

      MenuItem.PaintStyle := psCaptionGlyph;

      // MenuItem.Caption := GetFilterControlOperatorText(FilterControlOperator);
      MenuItem.Caption := FilterControlOperator.GetTranslation;

      MenuItem.Tag := Integer(FilterControlOperator);;

      // if GetParamCountForTemplate(PSCFltBld, Categoria, PSCFltBld.Templates[i].CaptionID) > 0 then
      // MenuItem.Caption := MenuItem.Caption + '...';

      // function GetFilterControlOperatorText(AOperator: TcxFilterControlOperator): string;

      MenuItem.OnClick := MenuFilterClick;
    end;
end;

procedure TzDbViewFilterController.MenuFilterClick(Sender: TObject);
var
  column: TcxGridDBColumn;
  Field: TField;
  Value: Variant;
  DisplayValue: string;
  FilterControlOperator: TcxFilterControlOperator;
  FilterOperatorKind: TcxFilterOperatorKind;
begin
  if not(Sender is TdxBarButton) then
    Exit;

  FilterControlOperator := TcxFilterControlOperator((Sender as TdxBarButton).Tag);
  FilterOperatorKind := GetFilterOperatorKind(FilterControlOperator);

  column := TcxGridDBColumn(View.Controller.FocusedColumn);
  Field := column.DataBinding.Field;

  if not Assigned(Field) then
    Exit;

  // zz 04.09.2020: tentativo di funzionare con i memo
  // if Field.IsBlob then
  // Exit;

  Value := ValoreFiltroDaMenu(FilterControlOperator, Field.Value);

  if FilterControlOperator in [fcoBlanks, fcoNonBlanks] then
    DisplayValue := ''
  else
    DisplayValue := Field.AsString;

  AddFilter(column, FilterOperatorKind, Value, DisplayValue);
end;

class function TzDbViewFilterController.ValoreFiltroDaMenu(Operatore: TcxFilterControlOperator; const ValoreCampo: Variant): Variant;
begin
  // Mantis #4777 - 2026-11-02: fcoNonBlanks riceveva il valore della cella e diventava
  // "diverso da <valore>" invece di "non e' vuoto"
  if Operatore in [fcoBlanks, fcoNonBlanks] then
    Result := null
  else
    if Operatore in [fcoBetween, fcoNotBetween] then
    begin
      Result := VarArrayCreate([0, 2], varVariant);
      Result[0] := ValoreCampo;
      Result[1] := ValoreCampo;
    end
    else
      if Operatore in [fcoInList, fcoNotInList] then
      begin
        Result := VarArrayCreate([0, 1], varVariant);
        Result[0] := ValoreCampo;
      end
      else
        Result := ValoreCampo;
end;

function TzDbViewFilterController.AddFilter(column: TcxGridDBColumn; OperatorKind: TcxFilterOperatorKind; const AValue: Variant; const ADisplayValue: string): TcxFilterCriteriaItem;
var
  Value: Variant;
  DisplayValue: string;
begin
  Value := AValue;
  DisplayValue := ADisplayValue;

  Result := View.DataController.Filter.Root.AddItem(column, OperatorKind, Value, DisplayValue);

  if Assigned(column.DataBinding.Field) then
    case column.DataBinding.Field.DataType of
      ftDate:
        begin
          // Result.Criteria.DateTimeFormat := 'dd.mm.yyyy'; // altrimenti pone il filtro con /
        end;
      ftTime:
        begin
          Result.Criteria.DateTimeFormat := 'hh:nn'; // altrimenti pone come filtro 31.12.1899
        end;
      ftDateTime, ftTimeStamp:
        begin
          Result.Criteria.DateTimeFormat := 'dd.mm.yyyy hh:nn';
        end;
    end;

  // Nota sandro settembre 2022
  View.DataController.Filter.Active := true;
end;

/// ///////////////////////////////////////////////////////////////////

constructor TzFilterControl.Create(AOwner: TComponent);
begin
  inherited;
  LastFilterText := '';
  Changing := false;
  FOnChange := nil;
end;

function TzFilterControl.RequiredHeight: Integer;
var
  i: Integer;
begin
  siFilter.logInteger('rowCount', RowCount);
  siFilter.logInteger('RowHeight', ViewInfo.RowHeight);
  siFilter.logInteger('AddConditionRect', ViewInfo.AddConditionRect.Bottom);

  // for i := 1 to RowCount - 1 do
  // siFilter.LogString(i.toString, Rows[i].Condition.ItemText);

  Result := ViewInfo.RowHeight * (2 + RowCount);

  // ViewInfo.Calc;
  // Result := ViewInfo.AddConditionRect.Bottom + 5;

  if AlignWithMargins then
    Result := Result + Margins.Top + Margins.Bottom;

  siFilter.logInteger('RequiredHeight', Result);
end;

procedure TzFilterControl.BeginUpdateLinkComponent;
begin
  Inc(FUpdateLinkComponentCount);
end;

procedure TzFilterControl.EndUpdateLinkComponent;
begin
  Dec(FUpdateLinkComponentCount);
end;

function TzFilterControl.IsUpdatingLinkComponent: boolean;
begin
  Result := FUpdateLinkComponentCount > 0;
end;

procedure TzFilterControl.LinkComponentChanged;
begin
  UpdateFilter; // ZZ 10.12.2021: non aggiornava dopo l'eliminazione dei filtri

  if Assigned(FocusedRow) then
    if FocusedRow is TcxGroupViewInfo then
    begin
      // UpdateFilter;
      LastFilterText := GetFilterText;
    end;
end;

procedure TzFilterControl.MouseLeave(AControl: TControl);
begin
  siFilter.EnterMethod(self, 'TzFilterControl.MouseLeave');
  try
    inherited;
  except
    // ad esempio, eccezione nella compilazione di date senza separatore
    on E: Exception do
      siFilter.LogException(E, 'MouseLeave: eccezione ignorata (valore filtro non ancora convertibile, es. data incompleta durante la digitazione)');
  end;
  // Mantis #41 - 2026-07-23: NON chiamare qui ValueEditorHide per "riparare" lo stato.
  // Questo MouseLeave viene rientrato in modo sincrono DA DENTRO ValueEditorHide (il
  // FValueEditor.Parent := nil distrugge la finestra dell'editor -> WM_DESTROY ->
  // FinishMouseTracking -> CM_MOUSELEAVE): richiamare ValueEditorHide da qui rientra in
  // un SetParent gia' in corso di svolgimento e produce un Access Violation.
  siFilter.leaveMethod(self, 'TzFilterControl.MouseLeave');
end;

// Mantis #41 - 2026-07-23: verifica se il valore digitato nel value editor e' applicabile.
// Oltre alla validazione standard DevExpress (IsValueValid) controlla che, sui campi data/ora,
// il valore rientri nell'intervallo rappresentabile da TDateTime: digitando una data senza
// separatori (es. "11021971") il testo viene interpretato come numero seriale di data, che e'
// formalmente valido ma fuori scala. Ogni successiva formattazione (DateToWStrViaOS) fallisce.
//
// Attenzione: qui NON si puo' usare EditorHelper.GetFilterValue, perche' calcola anche il
// display text (GetDisplayText -> dxVariantToString) ed e' proprio quella la conversione che
// solleva l'eccezione che stiamo cercando di evitare. Si legge direttamente EditValue.
function TzFilterControl.IsValueEditorValueValid: boolean;
var
  Condition: TcxConditionViewInfo;
  Value: Variant;
  DateValue: Double;
begin
  Result := true;

  if not Assigned(ValueEditor) then
    Exit;

  if not(FocusedRow is TcxConditionViewInfo) then
    Exit;

  Condition := TcxConditionViewInfo(FocusedRow);

  if Condition.ValueType = nil then
    Exit;

  if Condition.EditorHelper = nil then
    Exit;

  // stessi operatori che FilterControlValidateValue esclude dalla validazione (confronti su testo)
  if Condition.&Operator in [fcoLike, fcoNotLike, fcoContains, fcoNotContains, fcoBeginsWith, fcoEndsWith] then
    Exit;

  Value := ValueEditor.EditValue;

  // valore vuoto: nessuna conversione da validare
  if varIsNull(Value) or (VarIsStr(Value) and (VarToStr(Value) = '')) then
    Exit;

  Result := Condition.EditorHelper.IsValueValid(Condition.ValueType, Value);
  if not Result then
    Exit;

  // campi data/ora: il valore deve essere una data rappresentabile, altrimenti la formattazione
  // fallira' al primo ricalcolo del layout lasciando il ViewInfo a meta' e il repaint in AV
  if Condition.EditorHelper.GetFilterDataType(Condition.ValueType) in [fdtDate, fdtTime] then
    if VarIsType(Value, varDate) or VarIsNumeric(Value) then
    begin
      DateValue := Value;
      Result := (DateValue >= MinDateTime) and (DateValue <= MaxDateTime);
    end;
end;

// Mantis #41 - 2026-07-23: tentativo di RECUPERO invece dello scarto.
// Quando l'utente digita una data senza separatori (es. "11021971") il testo viene interpretato
// come numero seriale di data, fuori scala. Qui si prova a reinterpretarlo come dd mm yyyy secondo
// le impostazioni locali, reinserendo i separatori: se ne esce una data valida la si assegna al
// value editor e il filtro viene applicato normalmente; altrimenti il chiamante scarta il valore.
//
// Le cifre digitate si ricostruiscono dal valore corrente: se e' testo lo si legge direttamente,
// se e' gia' stato coartato a numero se ne prende la forma intera. L'unico zero iniziale che una
// data a 8 cifre puo' perdere (giorno 01..09) viene ripristinato col padding.
function TzFilterControl.TryNormalizeValueEditorDate: boolean;
var
  Condition: TcxConditionViewInfo;
  Value: Variant;
  Digits, Candidate: string;
  c: Char;
  yearDigits, expectedLen: Integer;
  FormatSettings: TFormatSettings;
  d: TDateTime;
  serial: Double;
begin
  Result := false;

  if not Assigned(ValueEditor) then
    Exit;

  if not(FocusedRow is TcxConditionViewInfo) then
    Exit;

  Condition := TcxConditionViewInfo(FocusedRow);

  if (Condition.ValueType = nil) or (Condition.EditorHelper = nil) then
    Exit;

  // solo campi data (non ora, non testo): "1230" su un'ora avrebbe tutta un'altra segmentazione
  if Condition.EditorHelper.GetFilterDataType(Condition.ValueType) <> fdtDate then
    Exit;

  Value := ValueEditor.EditValue;
  if varIsNull(Value) then
    Exit;

  // ricostruzione delle sole cifre digitate
  if VarIsStr(Value) then
    Candidate := VarToStr(Value)
  else
  begin
    serial := Value;
    Candidate := IntToStr(Trunc(serial));
  end;

  Digits := '';
  for c in Candidate do
    if CharInSet(c, ['0' .. '9']) then
      Digits := Digits + c;

  if Digits = '' then
    Exit;

  GetLocaleFormatSettings(GetThreadLocale, FormatSettings);

  // quante cifre di anno prevede il formato breve locale (yyyy -> 4, yy -> 2)
  yearDigits := 0;
  for c in FormatSettings.ShortDateFormat do
    if CharInSet(c, ['y', 'Y']) then
      Inc(yearDigits);
  if yearDigits >= 4 then
    expectedLen := 8 // dd mm yyyy
  else
    expectedLen := 6; // dd mm yy

  // ripristina l'unico zero iniziale che il giorno 01..09 puo' aver perso
  if Length(Digits) = expectedLen - 1 then
    Digits := '0' + Digits;

  if Length(Digits) <> expectedLen then
    Exit;

  // reinserisce i separatori (giorno-mese-resto); l'ordine effettivo lo applica StrToDate
  // seguendo ShortDateFormat, quindi la segmentazione fissa 2-2-resto e' coerente col locale
  Candidate := System.Copy(Digits, 1, 2) + FormatSettings.DateSeparator + System.Copy(Digits, 3, 2) +
    FormatSettings.DateSeparator + System.Copy(Digits, 5, MaxInt);

  if TryStrToDate(Candidate, d, FormatSettings) then
  begin
    ValueEditor.EditValue := d;
    Result := true;
  end;
end;

// Mantis #41 - 2026-07-23: rete di sicurezza. Nessun valore residuo non renderizzabile deve poter
// abbattere l'applicazione durante il disegno del filtro (TcxFilterControlPainter.DrawValues).
procedure TzFilterControl.Paint;
begin
  try
    inherited;
  except
    on E: Exception do
      siFilter.LogException(E, 'Paint: eccezione ignorata durante il disegno del filtro');
  end;
end;

procedure TzFilterControl.Changed;
var
  i: Integer;
  CurrentFilterText: string;
  // cxConditionViewInfo: TcxConditionViewInfo;
begin

  siFilter.EnterMethod(self, 'TzFilterControl.Changed');
  try
    // for i := 0 to RowCount - 1 do
    // if Rows[i] is TcxConditionViewInfo then
    // begin
    // cxConditionViewInfo := TcxConditionViewInfo(Rows[i]);
    // cxConditionViewInfo.EditorProperties.ImmediatePost := true;
    // end;

    if Changing then
      Exit;

    siFilter.LogString('State', TRttiEnumerationType.GetName(State));
    if State <> fcsNormal then
      Exit;

    Changing := true;
    try
      BeginUpdate;
      try
        if IsValid then
          if IsNeedSynchronize then
            if not IsUpdatingLinkComponent then
              if Assigned(FOnChange) then
              begin
                CurrentFilterText := GetFilterText;
                siFilter.LogString('CurrentFilterText ', CurrentFilterText);

                if LastFilterText <> CurrentFilterText then
                begin
                  siFilter.LogVerbose('OnChange');

                  LastFilterText := CurrentFilterText;

                  i := TopVisibleRow; // questa senza try/finally
                  OnChange(self);
                  TopVisibleRow := i;
                end;
              end;
      finally
        EndUpdate;
      end;
    finally
      Changing := false;
    end;

  finally
    siFilter.leaveMethod(self, 'Changed');
  end;
end;

{ --- Value editor: pre-validazione (Mantis #41) e notifica ------------------ }

// Mantis #41 - 2026-07-23: quando il valore viene accettato, cxFilterControl lo memorizza nella
// condizione e subito dopo sgancia l'editor (FValueEditor.Parent := nil). Lo sgancio distrugge
// la finestra dell'editor e fa rientrare MouseLeave -> LayoutChanged -> Calc, che prova a
// formattare il valore appena memorizzato: se e' una data fuori scala (es. "11021971" digitato
// senza separatori) la formattazione fallisce e lascia il ViewInfo calcolato a meta', con
// Access Violation al primo repaint. Chiudendo qui l'editor con ValueEditorHide(False) il valore
// non viene memorizzato, la condizione mantiene quello precedente e il successivo
// ValueEditorHide(True) del codice DevExpress trova l'editor gia' chiuso e non fa nulla.
procedure TzFilterControl.PreparaAccettazioneValore;
begin
  if ValueEditor = nil then
    Exit;

  if IsValueEditorValueValid then
    Exit;

  // prima di scartare, prova a recuperare una data digitata senza separatori (es. 11021971 -> 11/02/1971)
  if TryNormalizeValueEditorDate then
    siFilter.LogString('Valore data normalizzato reinserendo i separatori', '')
  else
  begin
    siFilter.LogWarning('Valore della condizione non valido: scartato senza applicare il filtro');
    ValueEditorHide(false);
  end;
end;

procedure TzFilterControl.SelectValue(AActivateKind: TcxActivateValueEditKind; AKey: Char);
begin
  inherited SelectValue(AActivateKind, AKey);

  // ValueEditorInit (private) ha appena assegnato gli handler DevExpress:
  // li si conserva e li si incapsula
  if ValueEditor = nil then
    Exit;

  FOrigValueEditorExit := ValueEditor.OnExit;
  FOrigValueEditorKeyDown := ValueEditor.OnKeyDown;
  FOrigValueEditorAfterKeyDown := ValueEditor.OnAfterKeyDown;

  ValueEditor.OnExit := ValueEditorExitHook;
  ValueEditor.OnKeyDown := ValueEditorKeyDownHook;
  ValueEditor.OnAfterKeyDown := ValueEditorAfterKeyDownHook;
end;

procedure TzFilterControl.ValueEditorExitHook(Sender: TObject);
begin
  siFilter.EnterMethod(self, 'TzFilterControl.ValueEditorExitHook');
  // l'originale chiama ValueEditorHide(True)
  PreparaAccettazioneValore;
  if Assigned(FOrigValueEditorExit) then
    FOrigValueEditorExit(Sender);
  InternalChanged;
  siFilter.leaveMethod(self, 'TzFilterControl.ValueEditorExitHook');
end;

procedure TzFilterControl.ValueEditorKeyDownHook(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Accetta: boolean;
begin
  // l'originale: VK_RETURN e VK_TAB -> ValueEditorHide(True); VK_ESCAPE -> ValueEditorHide(False);
  // Ctrl+VK_DELETE -> ValueEditorHide(False) + Remove
  Accetta := (Key = VK_RETURN) or ((Key = VK_TAB) and WantTabs);
  if Accetta then
    PreparaAccettazioneValore;
  if Assigned(FOrigValueEditorKeyDown) then
    FOrigValueEditorKeyDown(Sender, Key, Shift);
  if Accetta or ((Key = VK_DELETE) and (Shift = [ssCtrl])) then
    InternalChanged;
end;

procedure TzFilterControl.ValueEditorAfterKeyDownHook(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Accetta: boolean;
begin
  // l'originale: VK_UP e VK_DOWN -> ValueEditorHide(True) + navigazione
  Accetta := (Key = VK_UP) or (Key = VK_DOWN);
  if Accetta then
    PreparaAccettazioneValore;
  if Assigned(FOrigValueEditorAfterKeyDown) then
    FOrigValueEditorAfterKeyDown(Sender, Key, Shift);
  if Accetta then
    InternalChanged;
end;

procedure TzFilterControl.ApplyFilter;
begin
  // BuildFromRows chiama ValueEditorHide(True) direttamente
  PreparaAccettazioneValore;
  inherited ApplyFilter;
end;

{ --- Aggiunta/rimozione condizioni da tastiera e mouse ----------------------- }

procedure TzFilterControl.KeyDown(var Key: Word; Shift: TShiftState);
var
  Modifica: boolean;
begin
  // VK_INSERT -> AddCondition; Ctrl+VK_DELETE -> Remove (cxFilterControl.KeyDown)
  Modifica := ((Key = VK_INSERT) and (Shift = [])) or ((Key = VK_DELETE) and (ssCtrl in Shift));
  inherited KeyDown(Key, Shift);
  if Modifica then
    InternalChanged;
end;

procedure TzFilterControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Info: TcxFilterControlHitTestInfo;
begin
  // l'hit test va letto prima: dopo AddCondition il layout e' cambiato
  ViewInfo.GetHitTestInfo(Shift, Point(X, Y), Info);
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and (Info.HitTest in [fhtAddCondition, fhtRemoveButton]) then
    InternalChanged;
end;

{ --- Rete di sicurezza differita -------------------------------------------- }

procedure TzFilterControl.DoLayoutChange;
begin
  inherited DoLayoutChange;
  PostaVerificaCambiamento;
end;

procedure TzFilterControl.PostaVerificaCambiamento;
begin
  // Changed chiama EndUpdate -> LayoutChanged -> DoLayoutChange: con Changing
  // attivo non si riposta, altrimenti si innescherebbe un ciclo di messaggi
  if Changing or FCheckChangedPosted or (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  FCheckChangedPosted := true;
  PostMessage(Handle, ZM_FILTER_CHECKCHANGED, 0, 0);
end;

procedure TzFilterControl.ZMCheckChanged(var Message: TMessage);
begin
  FCheckChangedPosted := false;
  if csDestroying in ComponentState then
    Exit;
  InternalChanged;
end;

procedure TzFilterControl.WMDropDownMenuClosed(var Message: TMessage);
begin
  siFilter.EnterMethod(self, 'TzFilterControl.WMDropDownMenuClosed');
  // non esiste override per i messaggi, � copiata dal codice originale

  if not DropDownMenu.Visible then
  begin
    TcxFilterControlDropDownMenuAccess(DropDownMenu).ClearDroppedInfo;
    if UseTokens and (FocusedInfo.HitTest = fhtButton) then
      RowNavigate(fhtBoolOperator);
  end;

  InternalChanged;
  siFilter.leaveMethod(self, 'TzFilterControl.WMDropDownMenuClosed');
end;

procedure TzFilterControl.InternalChanged;
begin
  Changed;
end;

initialization

siFilter := Si.AddSession('Filter', true);
siFilter.color := TColors.Green;

cxFilterOperatorAdapters.RegisterAdapter(TzFbDataSet, TzFbDataSetFilterOperatorAdapter);

finalization

cxFilterOperatorAdapters.UnregisterAdapter(TzFbDataSet, TzFbDataSetFilterOperatorAdapter);

siFilter := nil;

end.

  zz.json

// Per attivare uno specifico Filtro
// https://supportcenter.devexpress.com/ticket/details/q50800/filtercontrol-keyboard-focus-activate-value-editor-in-code
type
  TcxFilterControlAccess = class(TcxFilterControl);
.. .with TcxFilterControlAccess(<cxFilterControl>)
do

begin
  SetFocus;
  FocusedRow := Rows[1]; // The first condition row
  RowNavigate(fhtValue);
end;

/// /////////////////////////////////////
/// /////////////////////////////////////
/// In caso di problemi guardare anche TzDbViewFilterController.FormatFilterTextValue
/// zsystem
///
zDbView
