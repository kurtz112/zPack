// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------
unit zFocusedAction;

// Scorciatoie legate al fuoco per i frame con una propria ActionList
// (zDbView, zDbPivot).
//
// La form smista una scorciatoia fra le ActionList di tutti i suoi frame,
// nell'ordine dei componenti e prima del controllo con il fuoco
// (TCustomForm.IsShortCut -> DispatchShortCut); un'azione disabilitata
// risponde False (TCustomAction.Execute restituisce Enabled) e il tasto passa
// all'azione con la stessa scorciatoia del frame successivo. Cosi' Canc su una
// vista in sola lettura cancellava il record della prima vista modificabile
// della form.
//
// L'unico punto in cui la VCL lascia intervenire e' l'azione
// (TContainedAction.HandleShortCut, virtuale): TCustomActionList.IsShortCut non
// lo e'. Per questo il comportamento sta in una classe di azione,
// TzFocusedAction, che il frame dichiara per nome nel .pas e nel .dfm. Nessuna
// ridefinizione di TAction: TzFocusedAction discende da Vcl.ActnList.TAction,
// quindi resta assegnabile a qualunque TAction delle unit che usano il frame.

interface

uses
  System.Classes,
  System.SysUtils,
  System.Actions,
  Vcl.ActnList;

type
  // Segna un frame che tiene per se' le scorciatoie delle proprie azioni
  // TzFocusedAction: con il fuoco dentro il frame le consuma tutte, anche
  // quelle che in quel momento non puo' eseguire; senza il fuoco le lascia
  // agli altri. Non ha metodi: si controlla con Supports.
  IzShortCutConsumer = interface
    ['{98CB0E9B-D8E5-4C16-9070-1F6554C3BF82}']
  end;

  // Azione di un frame IzShortCutConsumer, che deve esserne l'Owner (le azioni
  // del .dfm del frame lo sono). Con la scorciatoia:
  // - fuoco in un frame IzShortCutConsumer diverso dal proprio: False, il tasto
  // resta a quel frame;
  // - fuoco nel proprio frame: l'azione si esegue se puo', e il tasto e'
  // comunque consumato (True): non arriva ad altre ActionList ne' al
  // controllo con il fuoco;
  // - fuoco fuori da ogni frame IzShortCutConsumer, oppure Owner che non lo
  // e': come una TAction della VCL.
  // Fuori dalle scorciatoie (clic su un pulsante, Execute da codice) e' una
  // TAction qualunque.
  TzFocusedAction = class(TAction)
  protected
    function HandleShortCut: Boolean; override;
  end;

implementation

uses
  Vcl.Controls,
  Vcl.Forms;

// Il frame IzShortCutConsumer piu' interno che contiene il controllo con il
// fuoco, nil se il fuoco non e' dentro nessuno di loro.
function FrameDelFuoco: TWinControl;
var
  Controllo: TWinControl;
begin
  Result := nil;
  if Screen = nil then
    Exit;
  Controllo := Screen.ActiveControl;
  while Controllo <> nil do
  begin
    if Supports(Controllo, IzShortCutConsumer) then
      Exit(Controllo);
    Controllo := Controllo.Parent;
  end;
end;

// Vero se Scorciatoia e' la ShortCut o una SecondaryShortCuts di Azione.
function HaScorciatoia(Azione: TCustomAction; Scorciatoia: TShortCut): Boolean;
begin
  Result := (Scorciatoia <> 0) and ((Azione.ShortCut = Scorciatoia) or (Assigned(Azione.SecondaryShortCuts) and (Azione.SecondaryShortCuts.IndexOfShortCut(Scorciatoia) <> -1)));
end;

// Vero se nella stessa ActionList, dopo Azione, c'e' un'altra azione con una
// delle sue scorciatoie: TCustomActionList.IsShortCut le prova in ordine e si
// ferma alla prima che risponde True, quindi chi non ha eseguito deve lasciare
// il turno (in zDbView EditSelectAll e actSelezionaTutto hanno entrambe Ctrl+A).
function AltraAzioneDopo(Azione: TCustomAction): Boolean;
var
  Indice, Secondaria: Integer;
  Altra: TContainedAction;
begin
  Result := False;
  if Azione.ActionList = nil then
    Exit;
  for Indice := Azione.Index + 1 to Azione.ActionList.ActionCount - 1 do
  begin
    Altra := Azione.ActionList.Actions[Indice];
    if not(Altra is TCustomAction) then
      Continue;
    if HaScorciatoia(TCustomAction(Altra), Azione.ShortCut) then
      Exit(True);
    if Assigned(Azione.SecondaryShortCuts) then
      for Secondaria := 0 to Azione.SecondaryShortCuts.Count - 1 do
        if HaScorciatoia(TCustomAction(Altra), Azione.SecondaryShortCuts.ShortCuts[Secondaria]) then
          Exit(True);
  end;
end;

{ TzFocusedAction }

function TzFocusedAction.HandleShortCut: Boolean;
var
  Focused: TWinControl;
begin

  if not Supports(Owner, IzShortCutConsumer) then
    Exit(inherited HandleShortCut);

  Focused := FrameDelFuoco;

  if Focused = nil then
    Exit(inherited HandleShortCut);

  if Focused <> Owner then
    Exit(False);

  if inherited HandleShortCut then
    Exit(True);

  // Non eseguita (disabilitata o senza gestore): il tasto si consuma lo
  // stesso, salvo lasciare il turno a un'azione successiva della stessa lista
  // con la stessa scorciatoia.
  Result := not AltraAzioneDopo(Self);
end;

initialization

  // Il .dfm dei frame nomina la classe: registrata, la si ritrova anche da un
  // .dfm senza il campo pubblicato corrispondente (copia e incolla
  // nell'IDE, azioni aggiunte in una form che incorpora il frame).
  RegisterClass(TzFocusedAction);

end.
