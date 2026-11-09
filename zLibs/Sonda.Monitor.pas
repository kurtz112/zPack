// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-20
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Monitor
//
// Tiene le finestre del programma in collaudo su un monitor scelto, cosi'
// chi lavora sul computer mentre la sonda opera ha libero il monitor
// principale.
//
// COME. Il monitor lo sceglie chi avvia il programma (Monitor=N in
// zMCP_App.ini; "stato" li elenca). N e' il numero che Windows da' al
// monitor, la cifra finale del nome di dispositivo \\.\DISPLAYN, e di solito
// coincide con quello mostrato in Impostazioni > Schermo. Non e' l'ordine di
// Screen.Monitors: fino al 2026-10-20 lo era, e Monitor=1 portava le finestre
// sul primo monitor enumerato, che non e' detto sia l'1 di Windows. Ogni
// finestra con la barra del titolo (form, dialoghi, MessageBox) che compare
// su un altro monitor viene spostata su quello scelto, una volta sola: se poi
// la sposta qualcuno, resta dove e'. Una finestra massimizzata riempie l'area
// di lavoro del monitor scelto. Due meccanismi insieme:
//
//   gancio WinEvent    EVENT_OBJECT_SHOW dentro il processo: la finestra si
//                      sposta appena compare, senza aspettare il controllo
//                      periodico. Le funzioni di richiamo girano sul thread
//                      principale, nel suo ciclo dei messaggi (anche dentro
//                      ShowModal e MessageBox);
//   controllo          SpostaFinestreSulMonitor, chiamato dal battito della
//                      sonda: prende le finestre gia' aperte quando il monitor
//                      viene impostato, e quelle sfuggite al gancio.
//
// Gli spostamenti non attivano la finestra (SWP_NOACTIVATE): non cambia
// quale finestra ha il fuoco. Che il programma non rubi il fuoco all'utente
// quando mostra una finestra nuova non dipende da questa unit: ProgrammaInPrimoPiano
// permette di misurarlo ("in_primo_piano" nello stato).
//
// TUTTO SUL THREAD PRINCIPALE. ImpostaMonitorSonda va chiamata dal thread
// principale (il gancio e l'elenco delle finestre sono di quel thread).
//
// ***************************************************************************

unit Sonda.Monitor;

interface

uses
  System.JSON;

// Numero di Windows del monitor (N = \\.\DISPLAYN); 0 spegne lo
// spostamento. Un numero che non corrisponde a un monitor collegato solleva
// ESonda.
procedure ImpostaMonitorSonda(Numero: Integer);

function MonitorSonda: Integer;

// Sposta le finestre con la barra del titolo che non sono sul monitor scelto.
// Senza effetto se il monitor non e' impostato.
procedure SpostaFinestreSulMonitor;

// I monitor collegati: numero di Windows, dispositivo, primario, posizione e
// misure.
function ElencoMonitor: TJSONArray;

// Vero se la finestra in primo piano di Windows e' di questo programma.
function ProgrammaInPrimoPiano: Boolean;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Types,
  System.Generics.Collections,
  Winapi.Windows,
  Winapi.MultiMon,
  Vcl.Forms,
  Sonda.Ispezione;

const
  EVENT_OBJECT_SHOW = $8002;
  WINEVENT_OUTOFCONTEXT = $0000;
  OBJID_WINDOW = 0;
  CHILDID_SELF = 0;

type
  TFunzioneEventoFinestra = procedure(Gancio: THandle; Evento: DWORD; Finestra: HWND; Oggetto, Figlio: LONG;
    ThreadEvento, Tempo: DWORD); stdcall;

function SetWinEventHook(EventoMinimo, EventoMassimo: DWORD; Modulo: HMODULE; Funzione: TFunzioneEventoFinestra;
  Processo, Thread, Opzioni: DWORD): THandle; stdcall; external user32 name 'SetWinEventHook';
function UnhookWinEvent(Gancio: THandle): BOOL; stdcall; external user32 name 'UnhookWinEvent';

var
  NumeroMonitor: Integer;
  ThreadPrincipale: DWORD;
  Gancio: THandle;
  // finestre gia' portate sul monitor: si spostano una volta sola
  GiaSpostate: TDictionary<HWND, Byte>;

function Spostate: TDictionary<HWND, Byte>;
begin
  if GiaSpostate = nil then
    GiaSpostate := TDictionary<HWND, Byte>.Create;
  Result := GiaSpostate;
end;

function NomeDispositivo(Monitor: TMonitor): string;
var
  Informazioni: TMonitorInfoEx;
begin
  FillChar(Informazioni, SizeOf(Informazioni), 0);
  Informazioni.cbSize := SizeOf(Informazioni);
  if GetMonitorInfo(Monitor.Handle, PMonitorInfo(@Informazioni)) then
    Result := Informazioni.szDevice
  else
    Result := '';
end;

// Il numero che Windows da' al monitor: la cifra finale di \\.\DISPLAYN.
// 0 se il nome del dispositivo non ha quella forma.
function NumeroWindows(Monitor: TMonitor): Integer;
const
  Prefisso = 'DISPLAY';
var
  Nome: string;
  Posizione: Integer;
begin
  Nome := UpperCase(NomeDispositivo(Monitor));
  Posizione := Pos(Prefisso, Nome);
  if Posizione = 0 then
    Exit(0);
  Result := StrToIntDef(Copy(Nome, Posizione + Length(Prefisso), MaxInt), 0);
end;

// Il monitor collegato con quel numero di Windows, nil se non c'e'.
function MonitorDaNumero(Numero: Integer): TMonitor;
var
  Indice: Integer;
begin
  Result := nil;
  if Numero < 1 then
    Exit;
  for Indice := 0 to Screen.MonitorCount - 1 do
    if NumeroWindows(Screen.Monitors[Indice]) = Numero then
      Exit(Screen.Monitors[Indice]);
end;

// Finestra di primo livello (anche con un proprietario, come un dialogo)
// con la barra del titolo: form, dialoghi e MessageBox. I popup senza titolo
// (elenchi a discesa, suggerimenti) seguono il loro controllo e non si toccano.
function FinestraDaSpostare(Finestra: HWND): Boolean;
begin
  Result := IsWindowVisible(Finestra) and (GetAncestor(Finestra, GA_PARENT) = GetDesktopWindow) and
    ((GetWindowLong(Finestra, GWL_STYLE) and WS_CAPTION) = WS_CAPTION);
end;

procedure PortaSulMonitor(Finestra: HWND);
var
  Destinazione: TMonitor;
  Area, Rettangolo: TRect;
  Larghezza, Altezza: Integer;
  Posizionamento: TWindowPlacement;
begin
  if NumeroMonitor < 1 then
    Exit;
  if not FinestraDaSpostare(Finestra) then
    Exit;
  if Spostate.ContainsKey(Finestra) then
    Exit;
  // monitor scollegato dopo la scelta: le finestre restano dove sono
  Destinazione := MonitorDaNumero(NumeroMonitor);
  if Destinazione = nil then
    Exit;
  Spostate.AddOrSetValue(Finestra, 1);
  // gia' sul monitor scelto: niente da fare
  if MonitorFromWindow(Finestra, MONITOR_DEFAULTTONEAREST) = Destinazione.Handle then
    Exit;

  Area := Destinazione.WorkareaRect;
  if IsZoomed(Finestra) then
  begin
    // da massimizzata passa a occupare l'area di lavoro del monitor scelto,
    // senza essere riattivata (SW_SHOWNOACTIVATE)
    Posizionamento.length := SizeOf(Posizionamento);
    if GetWindowPlacement(Finestra, Posizionamento) then
    begin
      Posizionamento.rcNormalPosition := Area;
      Posizionamento.showCmd := SW_SHOWNOACTIVATE;
      SetWindowPlacement(Finestra, Posizionamento);
    end;
    Exit;
  end;

  GetWindowRect(Finestra, Rettangolo);
  Larghezza := Rettangolo.Width;
  Altezza := Rettangolo.Height;
  if Larghezza > Area.Width then
    Larghezza := Area.Width;
  if Altezza > Area.Height then
    Altezza := Area.Height;
  SetWindowPos(Finestra, 0, Area.Left + (Area.Width - Larghezza) div 2, Area.Top + (Area.Height - Altezza) div 2,
    Larghezza, Altezza, SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure EventoFinestra(Gancio: THandle; Evento: DWORD; Finestra: HWND; Oggetto, Figlio: LONG;
  ThreadEvento, Tempo: DWORD); stdcall;
begin
  if (Evento = EVENT_OBJECT_SHOW) and (Oggetto = OBJID_WINDOW) and (Figlio = CHILDID_SELF) and (Finestra <> 0) then
    try
      PortaSulMonitor(Finestra);
    except
      // il gancio gira dentro il ciclo dei messaggi dell'applicazione: un
      // errore qui non deve mai arrivare all'utente
    end;
end;

function EsaminaFinestra(Finestra: HWND; Parametro: LPARAM): BOOL; stdcall;
begin
  PortaSulMonitor(Finestra);
  Result := True;
end;

procedure ImpostaMonitorSonda(Numero: Integer);
var
  Collegati: string;
  Indice: Integer;
begin
  if Numero < 0 then
    Numero := 0;
  if (Numero > 0) and (MonitorDaNumero(Numero) = nil) then
  begin
    Collegati := '';
    for Indice := 0 to Screen.MonitorCount - 1 do
      Collegati := Collegati + IfThen(Collegati <> '', ', ', '') + IntToStr(NumeroWindows(Screen.Monitors[Indice]));
    raise ESonda.CreateFmt('Monitor %d non collegato: i numeri di Windows collegati sono %s (stato li elenca).',
      [Numero, Collegati]);
  end;
  NumeroMonitor := Numero;
  ThreadPrincipale := GetCurrentThreadId;
  Spostate.Clear;
  if (Numero > 0) and (Gancio = 0) then
    Gancio := SetWinEventHook(EVENT_OBJECT_SHOW, EVENT_OBJECT_SHOW, 0, EventoFinestra, GetCurrentProcessId,
      ThreadPrincipale, WINEVENT_OUTOFCONTEXT)
  else if (Numero = 0) and (Gancio <> 0) then
  begin
    UnhookWinEvent(Gancio);
    Gancio := 0;
  end;
  SpostaFinestreSulMonitor;
end;

function MonitorSonda: Integer;
begin
  Result := NumeroMonitor;
end;

procedure SpostaFinestreSulMonitor;
var
  Finestre: TArray<HWND>;
  Finestra: HWND;
begin
  if NumeroMonitor = 0 then
    Exit;
  // si dimenticano le finestre chiuse: l'handle potrebbe essere riusato da una
  // finestra nuova, che va spostata
  Finestre := Spostate.Keys.ToArray;
  for Finestra in Finestre do
    if not IsWindow(Finestra) then
      Spostate.Remove(Finestra);
  EnumThreadWindows(ThreadPrincipale, @EsaminaFinestra, 0);
end;

function ElencoMonitor: TJSONArray;
var
  Indice, Numero: Integer;
  Voce: TJSONObject;
  Area: TRect;
begin
  Result := TJSONArray.Create;
  for Indice := 0 to Screen.MonitorCount - 1 do
  begin
    Area := Screen.Monitors[Indice].BoundsRect;
    Numero := NumeroWindows(Screen.Monitors[Indice]);
    Voce := TJSONObject.Create;
    Voce.AddPair('numero', TJSONNumber.Create(Numero));
    Voce.AddPair('dispositivo', NomeDispositivo(Screen.Monitors[Indice]));
    Voce.AddPair('primario', TJSONBool.Create(Screen.Monitors[Indice].Primary));
    Voce.AddPair('sinistra', TJSONNumber.Create(Area.Left));
    Voce.AddPair('alto', TJSONNumber.Create(Area.Top));
    Voce.AddPair('larghezza', TJSONNumber.Create(Area.Width));
    Voce.AddPair('altezza', TJSONNumber.Create(Area.Height));
    Voce.AddPair('scelto', TJSONBool.Create((NumeroMonitor > 0) and (Numero = NumeroMonitor)));
    Result.AddElement(Voce);
  end;
end;

function ProgrammaInPrimoPiano: Boolean;
var
  Primo: HWND;
  Processo: DWORD;
begin
  Primo := GetForegroundWindow;
  if Primo = 0 then
    Exit(False);
  Processo := 0;
  GetWindowThreadProcessId(Primo, Processo);
  Result := Processo = GetCurrentProcessId;
end;

initialization

finalization

if Gancio <> 0 then
  UnhookWinEvent(Gancio);
GiaSpostate.Free;

end.
