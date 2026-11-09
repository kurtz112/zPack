unit zLayoutMaintenance;

{ -----------------------------------------------------------------------------
  Contratto generico di manutenzione layout.

  Chi possiede e genera un TdxLayoutControl (oggi TLayoutController in
  zFormController, domani il nuovo TzDbCard) implementa IzLayoutMaintenance
  e si registra nel registro associandosi al proprio layout control.

  La TzLayoutCustomizeForm risolve l'handler partendo da Container.Owner
  (il TdxLayoutControl in customizzazione) e invoca Reset/Repair senza
  conoscere il proprietario concreto.

  La unit dipende solo dalla RTL: nessun riferimento a DevExpress o zSystem.
  ----------------------------------------------------------------------------- }

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  IzLayoutMaintenance = interface
    ['{7A3C2F4E-9B1D-4E6A-8C5F-2D0E1A6B7C90}']
    function CanMaintainLayout: boolean;

    /// Ricrea il layout "ex novo": cancella le personalizzazioni salvate
    /// e ricostruisce la struttura canonica.
    /// Se la customizzazione e' attiva l'operazione viene accodata ed
    /// eseguita alla chiusura del form di customize.
    procedure ResetLayout;

    /// Risistema il layout esistente: elimina i record incoerenti
    /// (gruppi sganciati/orfani) e ripristina l'ordine logico dei dataset,
    /// preservando le personalizzazioni valide dell'utente.
    procedure RepairLayout;
  end;

  TzLayoutMaintenanceRegistry = class sealed
  private
    class var FHandlers: TDictionary<TComponent, IzLayoutMaintenance>;
    class function Handlers: TDictionary<TComponent, IzLayoutMaintenance>; static;
  public
    class destructor Destroy;

    class procedure RegisterHandler(LayoutControl: TComponent; const Handler: IzLayoutMaintenance); static;
    class procedure UnregisterHandler(LayoutControl: TComponent); static;
    class function FindHandler(LayoutControl: TComponent): IzLayoutMaintenance; static;
  end;

implementation

{ TzLayoutMaintenanceRegistry }

class function TzLayoutMaintenanceRegistry.Handlers: TDictionary<TComponent, IzLayoutMaintenance>;
begin
  if not assigned(FHandlers) then
    FHandlers := TDictionary<TComponent, IzLayoutMaintenance>.Create;

  result := FHandlers;
end;

class destructor TzLayoutMaintenanceRegistry.Destroy;
begin
  FreeAndNil(FHandlers);
end;

class procedure TzLayoutMaintenanceRegistry.RegisterHandler(LayoutControl: TComponent; const Handler: IzLayoutMaintenance);
begin
  if assigned(LayoutControl) and assigned(Handler) then
    Handlers.AddOrSetValue(LayoutControl, Handler);
end;

class procedure TzLayoutMaintenanceRegistry.UnregisterHandler(LayoutControl: TComponent);
begin
  if assigned(FHandlers) and assigned(LayoutControl) then
    FHandlers.Remove(LayoutControl);
end;

class function TzLayoutMaintenanceRegistry.FindHandler(LayoutControl: TComponent): IzLayoutMaintenance;
begin
  result := nil;

  if assigned(FHandlers) and assigned(LayoutControl) then
    FHandlers.TryGetValue(LayoutControl, result);
end;

end.
