unit zToolFilterHelper;

{
  Gestione filtri su TcxBarEditItem collegati a TzFbDataSet.

  Responsabilita' rimaste in questa unit:
  - AddPickListValue: aggiunta voci a TcxImageComboBoxProperties
  - ImpostaFiltro:    handler standard OnChange che aggiorna il param del dataset
  - FiltroChanged:    variante con callback TProc per logica custom pre-reopen
  - enumFilters:      elenca i filtri attivi per HelpGen (delega a TzDxBarHelper)
  - DisableImpostaFiltro: flag globale per sospendere il firing dei filtri
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  dxBar,
  cxBarEditItem,
  cxImageComboBox,
  zFbDataSet;

type
  TzToolFilterHelper = class
  private
    class var FDisableImpostaFiltro: Boolean;
    class var FDisableReopen: Boolean;

  public
    // ------------------------------------------------------------------
    // Utilita' per combo con picklist
    // ------------------------------------------------------------------

    /// <summary>
    /// Aggiunge una voce a una TcxImageComboBoxProperties.
    /// ImageIndex e' impostato a -1 (nessuna icona).
    /// </summary>
    class procedure AddPickListValue(Props: TcxImageComboBoxProperties; const Value: Variant; const Desc: String); static;

    // ------------------------------------------------------------------
    // Gestione filtro <-> dataset
    // ------------------------------------------------------------------

    /// <summary>
    /// Handler standard da assegnare all'evento OnChange di un TcxBarEditItem
    /// usato come filtro. Legge EditValue, aggiorna il parametro ParamName
    /// del TzFbDataSet collegato via Tag, e chiama Reopen se il dataset e' attivo.
    /// Supporta prefissi parametro '##' e '__' oltre al nome diretto.
    /// Non fa nulla se DisableImpostaFiltro = True.
    /// </summary>
    class procedure ImpostaFiltro(Sender: TObject; const ParamName: string); static;

    /// <summary>
    /// Variante di ImpostaFiltro con callback custom.
    /// Prima di chiamare Reopen esegue Proc(ParamName, Value),
    /// permettendo logica aggiuntiva (es. aggiornare altri parametri correlati).
    /// </summary>
    class procedure FiltroChanged(Sender: TObject; const ParamName: string; Proc: TProc<string, Variant>); static;

    // ------------------------------------------------------------------
    // Enumerazione filtri (per HelpGen)
    // ------------------------------------------------------------------

    /// <summary>
    /// Popola Filtri con i Caption di tutti gli item del BarManager
    /// il cui Name inizia con ToolFilterPrefix.
    /// Delega a TzDxBarHelper.EnumItemsByPrefix.
    /// </summary>
    class procedure enumFilters(dxBarManager: TdxBarManager; Filtri: TStrings); static;

    // ------------------------------------------------------------------

    class procedure ClearFilterItems(dxBarManager: TdxBarManager); static;

    // ------------------------------------------------------------------

    class function HasFilterItems(dxBarManager: TdxBarManager): Boolean; static;

    // ------------------------------------------------------------------

    class function FilterItemExists(dxBarManager: TdxBarManager; const ParamName: string): Boolean;

    // ------------------------------------------------------------------
    // Proprieta'
    // ------------------------------------------------------------------

    /// <summary>
    /// Se True, ImpostaFiltro e FiltroChanged non eseguono alcuna azione.
    /// Utile durante l'inizializzazione dei controlli per evitare
    /// riaperture premature del dataset.
    /// </summary>
    class property DisableImpostaFiltro: Boolean read FDisableImpostaFiltro write FDisableImpostaFiltro;
    class property DisableReopen: Boolean read FDisableReopen write FDisableReopen;
  end;

const
  ToolFilterPrefix = 'toolFilter__';

implementation

uses
  System.Variants,
  zSystem,
  zDxBarHelper,
  zBaseLib,
  zParamsHelper,
  System.StrUtils;

// --------------------------------------------------------------------------

class procedure TzToolFilterHelper.AddPickListValue(Props: TcxImageComboBoxProperties; const Value: Variant; const Desc: String);
var
  Item: TcxImageComboBoxItem;
begin
  Item := Props.Items.Add;
  Item.Description := Desc;
  Item.Value := Value;
  Item.ImageIndex := -1;
end;

// --------------------------------------------------------------------------

class procedure TzToolFilterHelper.ImpostaFiltro(Sender: TObject; const ParamName: string);
var
  BarEditItem: TcxBarEditItem;
  DataSet: TzFbDataSet;
  IsNull: Boolean;
  Param: TFDParam;
  Cambiato: Boolean;

  function GetParam: TFDParam;
  begin
    Result := nil;

    if DataSet.ParamExists(ParamName) then
      Result := DataSet.ParamByName(ParamName)
    else
      if DataSet.ParamExists('##' + ParamName) then
        Result := DataSet.ParamByName('##' + ParamName)
      else
        if DataSet.ParamExists('__' + ParamName) then
          Result := DataSet.ParamByName('__' + ParamName);
  end;

  // Da dove arriva il valore, per il messaggio d'errore: il nome dell'item sulla
  // barra non dice niente a chi legge, la sua etichetta si'.
  function DescrizioneFiltro: string;
  begin
    Result := BarEditItem.Caption.Trim;

    if Result.EndsWith(':') then
      Result := Result.Substring(0, Result.Length - 1).Trim;

    if Result.IsEmpty then
      Result := BarEditItem.Name;

    Result := Format('Filtro "%s"', [Result]);

    if Assigned(DataSet) and (DataSet.Name <> '') then
      Result := Result + Format(' del dataset "%s"', [DataSet.Name]);
  end;

  // True se il nuovo valore e' diverso da quello gia' nel parametro. Nullo e
  // stringa vuota valgono entrambi "nessun filtro": IsNull li ha gia'
  // unificati. Se il confronto fra tipi diversi fallisce si riapre, che e' il
  // comportamento precedente.
  function ValoreCambiato: Boolean;
  begin
    Result := True;
    if Param.IsNull and IsNull then
      Exit(False);
    if Param.IsNull <> IsNull then
      Exit;
    try
      Result := VarCompareValue(Param.Value, BarEditItem.EditValue) <> vrEqual;
    except
      Result := True;
    end;
  end;

begin
  if DisableImpostaFiltro then
    Exit;

  Assert(Sender is TComponent);
  Assert(TComponent(TComponent(Sender).Tag) is TzFbDataSet);

  BarEditItem := Sender as TcxBarEditItem;
  DataSet := TComponent(BarEditItem.Tag) as TzFbDataSet;
  Param := GetParam;

  if not Assigned(DataSet) then
    Exit;
  if not Assigned(Param) then
    Exit;

  IsNull := VarIsNull(BarEditItem.EditValue);
  if not IsNull then
    if VarIsStr(BarEditItem.EditValue) then
      IsNull := BarEditItem.EditValue = '';

  // Riapertura solo se il valore cambia davvero: riselezionare lo stesso
  // valore, o riapplicare i filtri dalle proprieta', non deve costare una
  // lettura dal server. Il confronto precede l'assegnazione.
  Cambiato := ValoreCambiato;

  // Mantis #141 - 2026-09-20: l'assegnazione passa dalla conversione guidata dal
  // tipo del parametro. Prima il variante della combo entrava intatto e, se era
  // una stringa su un parametro numerico (pick list su campo alfanumerico,
  // valore iniziale personalizzato, nome campo riscritto nel dialogo di
  // configurazione), l'errore "Could not convert variant of type (String) into
  // type (Integer)" usciva alla riapertura successiva, senza nominare ne' il
  // dataset ne' il parametro.
  if not IsNull then
    TzParamValue.Assegna(Param, BarEditItem.EditValue, DescrizioneFiltro)
  else
    Param.Clear;

  if Cambiato and DataSet.Active and not DisableReopen then
  begin
    StartWait('Attendere...', True);
    try
      DataSet.Reopen(False); // non deve forzare l'apertura
    finally
      StopWait;
    end;
  end;
end;

class function TzToolFilterHelper.FilterItemExists(dxBarManager: TdxBarManager; const ParamName: string): Boolean;
begin
  Result := Assigned(dxBarManager.GetItemByName(ToolFilterPrefix + ParamName));

  if not result then { TODO : Rimuovere dopo conversione }
  Result := Assigned(dxBarManager.GetItemByName('toolFilter_OLD_' + ParamName));
end;

// --------------------------------------------------------------------------

class procedure TzToolFilterHelper.FiltroChanged(Sender: TObject; const ParamName: string; Proc: TProc<string, Variant>);
var
  BarEditItem: TcxBarEditItem;
  DataSet: TzFbDataSet;
  IsNull: Boolean;
  Value: Variant;
begin
  Assert(Sender is TComponent);
  Assert(TComponent(TComponent(Sender).Tag) is TzFbDataSet);
  Assert(Assigned(Proc));

  BarEditItem := Sender as TcxBarEditItem;
  DataSet := TComponent(BarEditItem.Tag) as TzFbDataSet;

  IsNull := VarIsNull(BarEditItem.EditValue);
  if not IsNull then
    if VarIsStr(BarEditItem.EditValue) then
      IsNull := BarEditItem.EditValue = '';

  if not IsNull then
    Value := BarEditItem.EditValue
  else
    Value := Null;

  Proc(ParamName, Value);

  if Assigned(DataSet) and DataSet.Active and not DisableReopen then
  begin
    StartWait('Attendere...', True);
    try
      DataSet.Reopen(False); // non deve forzare l'apertura
    finally
      StopWait;
    end;
  end;
end;

// --------------------------------------------------------------------------

class procedure TzToolFilterHelper.enumFilters(dxBarManager: TdxBarManager; Filtri: TStrings);
begin
  TzDxBarHelper.EnumItemsByPrefix(dxBarManager, ToolFilterPrefix, Filtri);
end;

// --------------------------------------------------------------------------

class procedure TzToolFilterHelper.ClearFilterItems(dxBarManager: TdxBarManager);
var
  i: Integer;
begin
  // Rimuove tutti gli item il cui Name inizia con ToolFilterPrefix.
  // Si scorre all'indietro per poter rimuovere in sicurezza.
  for i := dxBarManager.ItemCount - 1 downto 0 do
    if StartsText(ToolFilterPrefix, dxBarManager.Items[i].Name) then
      dxBarManager.Items[i].Free;
end;

// --------------------------------------------------------------------------
class function TzToolFilterHelper.HasFilterItems(dxBarManager: TdxBarManager): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to dxBarManager.ItemCount - 1 do
    if StartsText(ToolFilterPrefix, dxBarManager.Items[i].Name) then
      Exit(True);
end;

// --------------------------------------------------------------------------

initialization

TzToolFilterHelper.DisableImpostaFiltro := False;
TzToolFilterHelper.DisableReopen := False;

end.
