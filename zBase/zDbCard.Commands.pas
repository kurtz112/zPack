unit zDbCard.Commands;

// =============================================================================
// Coda dei comandi interni differiti della card (estratta da zDbCard).
//
// Semantica (invariata rispetto all'implementazione storica in TzDbCard):
// - un comando gia' postato non viene ripostato finche' il messaggio non e'
//   stato processato (latch di coalescenza);
// - senza HWND o con la card non ancora a video il comando non viene postato
//   ma memorizzato come "deferred" e rilanciato da RepostDeferred alla prima
//   CM_SHOWINGCHANGED utile (es. wizard: Insert prima di ShowForm);
// - alla distruzione dell'HWND (DestroyWnd) i comandi gia' postati andrebbero
//   persi col message queue: MovePostedToDeferred li conserva per il rilancio.
//
// NB: la coalescenza conserva UN solo parametro per comando (l'ultimo
// accettato); un secondo Post dello stesso comando con parametro diverso,
// arrivato a latch alzato, viene scartato (comportamento storico, vedi B7
// nell'analisi: non corretto di proposito in questa revisione).
// =============================================================================

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  Vcl.Controls;

type
  TzDbCardCommand = (cmd_UpdateActions, cmd_DisplayToolbars, cmd_NewLookupDisplayText, cmd_SaveLookupToZip, cmd_SavePickListToZip, cmd_LoadProperties, cmd_PropertiesChange, cmd_ReadOnlyPropertiesChange, cmd_FlagsPropertiesChange,
    cmd_CtrlTypePropertiesChange, cmd_UpdateColors, cmd_Resize, cmd_PersonalizzaCard, cmd_RebuildControls, cmd_RebuildSingleControl, cmd_VerifyLookupsParams, cmd_SaveProperties);

  TzDeferredCommandQueue = class
  private
    FOwner: TWinControl;
    FMessageId: cardinal;
    FPosted: array [TzDbCardCommand] of boolean;
    FDeferred: array [TzDbCardCommand] of boolean;
    FParams: array [TzDbCardCommand] of NativeUInt;
  public
    constructor Create(AOwner: TWinControl; const AMessageId: cardinal);

    // Posta il comando con coalescenza; se l'owner non e' visibile/senza HWND
    // lo memorizza come deferred.
    procedure Post(const Command: TzDbCardCommand; const Param: NativeUInt = 0);

    // Rilascia il latch di un comando: da chiamare nel message handler.
    // Per i comandi che possono rigenerarsi durante il dispatch (cmd_Resize)
    // va rilasciato PRIMA di eseguire, per gli altri dopo (in finally).
    procedure ReleaseLatch(const Command: TzDbCardCommand);

    // DestroyWnd: i messaggi accodati sull'HWND distrutto vanno persi;
    // trasferisce i latch pendenti su deferred invece di scartarli.
    procedure MovePostedToDeferred;

    // CM_SHOWINGCHANGED (owner visibile): rilancia i comandi deferred.
    procedure RepostDeferred;

    // True se il comando e' postato o deferred (es. flush nel distruttore).
    function IsPending(const Command: TzDbCardCommand): boolean;
  end;

implementation

constructor TzDeferredCommandQueue.Create(AOwner: TWinControl; const AMessageId: cardinal);
begin
  inherited Create;
  FOwner := AOwner;
  FMessageId := AMessageId;
  // FPosted/FDeferred/FParams: azzerati dall'allocazione della classe
end;

procedure TzDeferredCommandQueue.Post(const Command: TzDbCardCommand; const Param: NativeUInt);
begin
  if FPosted[Command] then
    Exit;

  if (not FOwner.HandleAllocated) or (not FOwner.Showing) then
  begin
    // Niente HWND o card non ancora a video: non postare e NON latchare,
    // ma ricordare il comando per il rilancio in RepostDeferred.
    FDeferred[Command] := true;
    FParams[Command] := Param;
    Exit;
  end;

  FPosted[Command] := true;
  FParams[Command] := Param; // conservato per un eventuale MovePostedToDeferred
  if not PostMessage(FOwner.Handle, FMessageId, NativeUInt(Command), Param) then
    FPosted[Command] := false; // post fallito: rilascia subito
end;

procedure TzDeferredCommandQueue.ReleaseLatch(const Command: TzDbCardCommand);
begin
  FPosted[Command] := false;
end;

procedure TzDeferredCommandQueue.MovePostedToDeferred;
var
  Command: TzDbCardCommand;
begin
  for Command := Low(TzDbCardCommand) to High(TzDbCardCommand) do
    if FPosted[Command] then
    begin
      FPosted[Command] := false;
      FDeferred[Command] := true;
      // FParams[Command] contiene gia' l'ultimo parametro postato
    end;
end;

procedure TzDeferredCommandQueue.RepostDeferred;
var
  Command: TzDbCardCommand;
begin
  for Command := Low(TzDbCardCommand) to High(TzDbCardCommand) do
    if FDeferred[Command] then
    begin
      FDeferred[Command] := false;
      Post(Command, FParams[Command]);
    end;
end;

function TzDeferredCommandQueue.IsPending(const Command: TzDbCardCommand): boolean;
begin
  result := FPosted[Command] or FDeferred[Command];
end;

end.
