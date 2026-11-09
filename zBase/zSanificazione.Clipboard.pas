// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-07
// ---------------------------------------------------------------------------
unit zSanificazione.Clipboard;

// Filtro applicativo sugli Clipboard: quando l'utente incolla con la tastiera (Ctrl+V,
// Shift+Ins) in un controllo di testo, il testo negli Clipboard viene ripulito PRIMA
// che il controllo lo riceva. E' l'unico modo di intervenire senza derivare le classi
// degli editor DevExpress: TcxCustomTextEdit.PasteFromClipboard passa WM_PASTE al
// controllo Windows nativo (cxTextEdit.pas), e WM_PASTE e' un messaggio inviato, non
// accodato, quindi non passa da Application.OnMessage. La sequenza di tasti invece si'.
//
// Limiti dichiarati:
// - il comando "Incolla" del menu contestuale non passa di qui: resta coperto dai
// livelli successivi (OnValidate in zDX, BeforePost in zFbDataSet);
// - il filtro modifica il contenuto degli Clipboard dell'utente. Lo fa solo se il
// testo cambierebbe, solo con un controllo di testo attivo, mai su contenuti che
// sembrano marcatura (RTF, HTML, XML, JSON).
//
// Usa un TApplicationEvents proprio: la VCL propaga OnShortCut a tutte le istanze,
// quindi convive con quello di ConfigModule (WT e Gesty) senza toccarlo.
//
// Attivazione: la unit crea l'istanza in initialization con Attivo = True.
// L'applicazione puo' spegnerla o riaccenderla da configurazione:
// FiltroClipboard.Attivo := Config.LeggiBool('SANIFICA_Clipboard', True);

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Clipbrd,
  Vcl.AppEvnts,
  zSanificazione;

type
  TzFiltroClipboard = class
  private
    FApplicationEvents: TApplicationEvents;
    FAttivo: boolean;
    FUltimoTestoRipulito: string;
    FOpzioni: TOpzioniSanificazione;
    procedure ApplicationShortCut(var Msg: TWMKey; var Handled: boolean);
    function IncollaDaTastiera(const Msg: TWMKey): boolean;
    function ControlloDiTestoAttivo(out Multiriga: boolean): boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // Ripulisce il testo negli Clipboard se serve. True se lo ha cambiato.
    // Richiamabile anche a mano (es. dal comando "Incolla" di un menu).
    function RipulisciClipboard(Multiriga: boolean): boolean;

    property Attivo: boolean read FAttivo write FAttivo;
    // Livello di pulizia: predefinito (anche punteggiatura tipografica). Cambiare in
    // TzSanificazione.OpzioniSicure se un ente vuole conservare virgolette e trattini tipografici.
    property Opzioni: TOpzioniSanificazione read FOpzioni write FOpzioni;
  end;

function FiltroClipboard: TzFiltroClipboard;

implementation

var
  IstanzaFiltroClipboard: TzFiltroClipboard = nil;

function FiltroClipboard: TzFiltroClipboard;
begin
  if not Assigned(IstanzaFiltroClipboard) then
    IstanzaFiltroClipboard := TzFiltroClipboard.Create;
  Result := IstanzaFiltroClipboard;
end;

{ TzFiltroClipboard }

constructor TzFiltroClipboard.Create;
begin
  inherited Create;
  FAttivo := True;
  FOpzioni := TzSanificazione.OpzioniPredefinite;
  FApplicationEvents := TApplicationEvents.Create(nil);
  FApplicationEvents.OnShortCut := ApplicationShortCut;
end;

destructor TzFiltroClipboard.Destroy;
begin
  FApplicationEvents.Free;
  inherited;
end;

// Ctrl+V oppure Shift+Ins, senza Alt. OnShortCut riceve WM_KEYDOWN e WM_SYSKEYDOWN
// prima che il tasto arrivi al controllo attivo.
function TzFiltroClipboard.IncollaDaTastiera(const Msg: TWMKey): boolean;
var
  Ctrl: boolean;
  Shift: boolean;
  Alt: boolean;
begin
  Ctrl := GetKeyState(VK_CONTROL) < 0;
  Shift := GetKeyState(VK_SHIFT) < 0;
  Alt := GetKeyState(VK_MENU) < 0;

  Result := (not Alt) and (((Msg.CharCode = Ord('V')) and Ctrl and not Shift) or ((Msg.CharCode = VK_INSERT) and Shift and not Ctrl));
end;

// Il controllo attivo e' un editor di testo nativo (TCustomEdit copre TEdit, TMemo,
// TcxCustomInnerTextEdit di DevExpress e l'editor interno di TcxMemo). Le griglie
// DevExpress in modifica mettono il fuoco sull'editor in linea, quindi rientrano.
// Escluse le caselle password.
function TzFiltroClipboard.ControlloDiTestoAttivo(out Multiriga: boolean): boolean;
var
  Attivo: TWinControl;
  Stile: NativeInt;
begin
  Result := False;
  Multiriga := False;

  Attivo := Screen.ActiveControl;
  if not(Attivo is TCustomEdit) then
    Exit;
  if not Attivo.HandleAllocated then
    Exit;

  Stile := GetWindowLongPtr(Attivo.Handle, GWL_STYLE);
  if (Stile and ES_PASSWORD) <> 0 then
    Exit;
  if (Stile and ES_READONLY) <> 0 then
    Exit;

  Multiriga := (Stile and ES_MULTILINE) <> 0;
  Result := True;
end;

function TzFiltroClipboard.RipulisciClipboard(Multiriga: boolean): boolean;
var
  Testo: string;
  Ripulito: string;
begin
  Result := False;

  if not Clipboard.HasFormat(CF_UNICODETEXT) then
    Exit;

  try
    Testo := Clipboard.AsText;
  except
    // Clipboard occupati da un'altra applicazione: si lascia passare l'incolla originale
    Exit;
  end;

  if (Testo = '') or (Testo = FUltimoTestoRipulito) then
    Exit;
  if TzSanificazione.SembraMarcatura(Testo) then
    Exit;

  Ripulito := TzSanificazione.Sanifica(Testo, Multiriga, FOpzioni);
  if Ripulito = Testo then
    Exit;

  try
    Clipboard.AsText := Ripulito;
    FUltimoTestoRipulito := Ripulito;
    Result := True;
  except
    // impossibile scrivere negli Clipboard: nessun danno, l'incolla procede con il testo originale
  end;
end;

procedure TzFiltroClipboard.ApplicationShortCut(var Msg: TWMKey; var Handled: boolean);
var
  Multiriga: boolean;
begin
  // mai Handled := True: il tasto deve proseguire e fare l'incolla vero
  if not FAttivo then
    Exit;
  if not IncollaDaTastiera(Msg) then
    Exit;
  if not ControlloDiTestoAttivo(Multiriga) then
    Exit;

  RipulisciClipboard(Multiriga);
end;

initialization

FiltroClipboard;

finalization

FreeAndNil(IstanzaFiltroClipboard);

end.
