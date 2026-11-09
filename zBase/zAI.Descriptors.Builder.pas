unit zAI.Descriptors.Builder;

{
  Passo 2 del layer di descrizione AI.

  Costruisce i record neutri di zAI.Descriptors a partire dalla configurazione
  dichiarativa dei componenti (i props), risolvendo le azioni sull'owner.

  Due ingressi simmetrici:

    - DescribeComponent(IzBaseComponent): per i componenti VIVI gia' presenti
      sulla form. Ricava props, owner, tipo e titolo dall'interfaccia.

    - DescribeProps(props, owner, kind, title): per la descrizione "a freddo",
      dai soli TzBaseComponentProps (es. TzDiagramDataSet.DbViews[i].zDbViewProps)
      senza istanziare alcun componente. Owner e titolo li fornisce il chiamante
      (la form e' l'owner naturale: le TAction vivono sempre li').

  Entrambi convergono sulla stessa logica: per ogni TzToolActionProps si risolve
  la TCustomAction via TzActionOwnerResolver.FindAction sull'owner, da cui
  Caption/Hint/ShortCut; la riga riassuntiva (Caption + Hint + [solo card]/
  [solo view]) e' ricomposta dai flag in TzToolActionProps.ToolbarProps,
  replicando TzToolAction.Description del runtime. I filtri si leggono dai props
  filtrabili (TzBaseFilterableComponentProps.ToolFilters).

  Vantaggio dell'ingresso a freddo: nessun componente da creare/inizializzare
  (niente InitView/LZ), nessuna UI, nessun effetto su LZ. Funziona identico sui
  componenti vivi e sui props del diagram.

  Questa unit non usa HelpGen.*, ne' provider AI, ne' UI.
}

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Menus,            // ShortCutToText
  Vcl.ActnList,
  zSystem,            // IzBaseComponent, IzBaseFilterableComponent, props
  zToolActions,       // TzToolActionsProps, TzToolActionProps, TzActionOwnerResolver
  zAI.Descriptors;

type
  TAIDescriptorBuilder = record
  private
    class function ComposeActionDescription(const AAction: TCustomAction;
      const AProps: TzToolActionProps): string; static;

    // Popola le azioni di ADesc dai props dichiarativi, risolvendo ogni azione
    // sull'owner fornito. Base condivisa dai due ingressi pubblici.
    class procedure FillActionsFromProps(const AActionsProps: TzToolActionsProps;
      const AOwner: TComponent; var ADesc: TAIComponentDescriptor); static;

    // Popola i filtri di ADesc dai props dei filtri. Accoda.
    class procedure FillFiltersFromProps(const AToolFilters: TzToolFiltersProps;
      var ADesc: TAIComponentDescriptor); static;
  public
    // Ingresso "a freddo": descrive dai soli props, senza componente runtime.
    // AOwner risolve le azioni (tipicamente la form); AKind e ATitle li
    // fornisce il chiamante (il titolo non ha un nome uniforme tra i props).
    // Se AProps e' TzBaseFilterableComponentProps, include i filtri.
    class function DescribeProps(const AProps: TzBaseComponentProps;
      const AOwner: TComponent; const AKind: TzComponentType;
      const ATitle: string): TAIComponentDescriptor; static;

    // Ingresso per componente vivo: ricava props, owner, tipo e titolo
    // dall'interfaccia e delega a DescribeProps.
    class function DescribeComponent(
      const AComp: IzBaseComponent): TAIComponentDescriptor; static;
  end;

implementation

{ TAIDescriptorBuilder }

class function TAIDescriptorBuilder.ComposeActionDescription(
  const AAction: TCustomAction; const AProps: TzToolActionProps): string;
begin
  // Replica la logica di TzToolAction.Description (runtime): caption, hint,
  // e suffisso di visibilita' solo se l'azione e' esclusa da uno dei contesti.
  Result := AAction.Caption;

  if AAction.Hint <> '' then
    Result := Result + ' — ' + AAction.Hint;

  if Assigned(AProps) and Assigned(AProps.ToolbarProps) then
  begin
    if not AProps.ToolbarProps.VisibleInView then
      Result := Result + ' [solo card]'
    else
      if not AProps.ToolbarProps.VisibleInCard then
        Result := Result + ' [solo view]';
  end;
end;

class procedure TAIDescriptorBuilder.FillActionsFromProps(
  const AActionsProps: TzToolActionsProps; const AOwner: TComponent;
  var ADesc: TAIComponentDescriptor);
var
  ActionProps: TzToolActionProps;
  Action: TCustomAction;
  ShortCutStr: string;
begin
  if not Assigned(AActionsProps) or (AActionsProps.Count = 0) then
    Exit;

  for ActionProps in AActionsProps do
  begin
    Action := TzActionOwnerResolver.FindAction(AOwner, ActionProps.Name);
    if not Assigned(Action) then
      Continue; // azione non risolvibile sull'owner: la si salta

    ShortCutStr := '';
    if Action.ShortCut <> 0 then
      ShortCutStr := ShortCutToText(Action.ShortCut);

    ADesc.AddAction(
      Action.Name,
      Action.Caption,
      Action.Hint,                                       // hint grezzo
      ShortCutStr,
      ComposeActionDescription(Action, ActionProps)      // riga riassuntiva
    );
  end;
end;

class procedure TAIDescriptorBuilder.FillFiltersFromProps(
  const AToolFilters: TzToolFiltersProps; var ADesc: TAIComponentDescriptor);
var
  Filter: TzToolFilterProps;
begin
  if not Assigned(AToolFilters) or (AToolFilters.Count = 0) then
    Exit;

  for Filter in AToolFilters do
    ADesc.AddFilter(Filter.Name, Filter.Description);
end;

class function TAIDescriptorBuilder.DescribeProps(
  const AProps: TzBaseComponentProps; const AOwner: TComponent;
  const AKind: TzComponentType; const ATitle: string): TAIComponentDescriptor;
var
  Filterable: TzBaseFilterableComponentProps;
begin
  Assert(Assigned(AProps), 'DescribeProps: AProps non assegnato');

  Result := Default(TAIComponentDescriptor);
  Result.Kind := AKind;
  Result.Title := ATitle;
  Result.Description := AProps.DescriptionText;

  // AOwner e' gia' l'owner risolto su cui cercare le TAction: per il componente
  // vivo e' IzBaseComponent.ActionOwner; a freddo e' la form (o l'override gia'
  // risolto dal chiamante). DescribeProps non lo ri-risolve.
  FillActionsFromProps(AProps.ToolActions, AOwner, Result);

  // I filtri esistono solo sui props filtrabili (View, Pivot).
  if AProps is TzBaseFilterableComponentProps then
  begin
    Filterable := TzBaseFilterableComponentProps(AProps);
    FillFiltersFromProps(Filterable.ToolFilters, Result);
  end;
end;

class function TAIDescriptorBuilder.DescribeComponent(
  const AComp: IzBaseComponent): TAIComponentDescriptor;
begin
  Assert(Assigned(AComp), 'DescribeComponent: AComp non assegnato');

  Result := DescribeProps(
    AComp.Props,
    AComp.ActionOwner,
    AComp.ComponentType,
    AComp.ConfigTitle);
end;

end.
