// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-30
// ---------------------------------------------------------------------------
unit zStorage;

interface

uses
  SysUtils,
  Classes,
  Controls,
  ExtCtrls,
  Forms,
  cxSplitter;

type
  TzStorage = class
  private
    class function FindSplittedControl(Splitter: TcxSplitter): TControl;
  public
    class function ProfiloDiSchermo: string;
    class function NomeSezione(Ctrl: TControl): string;
    class procedure SaveControlToIni(const IniFileName: string; Ctrl: TWinControl);
    class procedure LoadControlFromIni(const IniFileName: string; Ctrl: TWinControl; const MaxWidth, MaxHeight: integer);
  end;

implementation

uses
  Windows,
  Types,
  IniFiles,
  Math;

// Disposizione adattiva 2026-10-29: regole per decidere dove riaprire una form
// a partire dai limiti salvati. Prima (rilascio 002) il rettangolo si stringeva
// e si spostava sempre dentro il monitor piu' vicino; con i limiti di una
// finestra salvata mentre era ridotta a icona (-32000, -32000, circa 160x28)
// la form finiva in alto a sinistra grande come un francobollo. Ora:
// - una misura sotto il minimo non e' credibile e si torna a quella di progetto;
// - se la barra del titolo e' raggiungibile su un monitor la form resta dove
//   era, stretta solo se non ci sta;
// - altrimenti (monitor scollegato, desktop remoto) si centra sul monitor della
//   finestra principale con la sua misura.
const
  LarghezzaMinimaForm = 200;
  AltezzaMinimaForm = 150;
  AltezzaBarraTitolo = 30;
  LarghezzaBarraAfferrabile = 100;
  CoordinataRidottaAIcona = -30000;

function BarraDelTitoloRaggiungibile(const Rettangolo: TRect): boolean;
var
  I: integer;
  Barra, Comune: TRect;
begin
  Result := false;

  Barra := Rect(Rettangolo.Left, Rettangolo.Top, Rettangolo.Right, Rettangolo.Top + AltezzaBarraTitolo);

  for I := 0 to Screen.MonitorCount - 1 do
    if IntersectRect(Comune, Barra, Screen.Monitors[I].WorkareaRect) then
      if (Comune.Width >= LarghezzaBarraAfferrabile) and (Comune.Height >= AltezzaBarraTitolo) then
        Exit(true);
end;

function MonitorDellaFinestraPrincipale: TMonitor;
begin
  Result := nil;

  if Assigned(Application.MainForm) and Application.MainForm.HandleAllocated then
    Result := Screen.MonitorFromWindow(Application.MainForm.Handle, mdNearest);

  if not Assigned(Result) then
    Result := Screen.PrimaryMonitor;
end;

// stringe il rettangolo se e' piu' grande dell'area utile, poi lo sposta se sborda
function RettangoloNellAreaUtile(const Rettangolo, AreaUtile: TRect): TRect;
var
  Larghezza, Altezza: integer;
begin
  Larghezza := Min(Rettangolo.Width, AreaUtile.Width);
  Altezza := Min(Rettangolo.Height, AreaUtile.Height);

  Result.Left := Rettangolo.Left;
  if Result.Left + Larghezza > AreaUtile.Right then
    Result.Left := AreaUtile.Right - Larghezza;
  if Result.Left < AreaUtile.Left then
    Result.Left := AreaUtile.Left;

  Result.Top := Rettangolo.Top;
  if Result.Top + Altezza > AreaUtile.Bottom then
    Result.Top := AreaUtile.Bottom - Altezza;
  if Result.Top < AreaUtile.Top then
    Result.Top := AreaUtile.Top;

  Result.Right := Result.Left + Larghezza;
  Result.Bottom := Result.Top + Altezza;
end;

function RettangoloCentrato(const Larghezza, Altezza: integer; const AreaUtile: TRect): TRect;
var
  LarghezzaUtile, AltezzaUtile: integer;
begin
  LarghezzaUtile := Min(Larghezza, AreaUtile.Width);
  AltezzaUtile := Min(Altezza, AreaUtile.Height);

  Result.Left := AreaUtile.Left + (AreaUtile.Width - LarghezzaUtile) div 2;
  Result.Top := AreaUtile.Top + (AreaUtile.Height - AltezzaUtile) div 2;
  Result.Right := Result.Left + LarghezzaUtile;
  Result.Bottom := Result.Top + AltezzaUtile;
end;

function PosizioneDiRiapertura(const Salvato, Progettato: TRect): TRect;
var
  Rettangolo: TRect;
  Monitor: TMonitor;
begin
  Rettangolo := Salvato;

  if (Rettangolo.Width < LarghezzaMinimaForm) or (Rettangolo.Height < AltezzaMinimaForm) then
  begin
    Rettangolo.Width := Progettato.Width;
    Rettangolo.Height := Progettato.Height;
  end;

  if (Rettangolo.Left > CoordinataRidottaAIcona) and (Rettangolo.Top > CoordinataRidottaAIcona) and BarraDelTitoloRaggiungibile(Rettangolo) then
  begin
    Monitor := Screen.MonitorFromRect(Rettangolo, mdNearest);
    if Assigned(Monitor) then
      Result := RettangoloNellAreaUtile(Rettangolo, Monitor.WorkareaRect)
    else
      Result := Rettangolo;
  end
  else
  begin
    Monitor := MonitorDellaFinestraPrincipale;
    if Assigned(Monitor) then
      Result := RettangoloCentrato(Rettangolo.Width, Rettangolo.Height, Monitor.WorkareaRect)
    else
      Result := Rettangolo;
  end;
end;

const
  PixelPerPollicePredefiniti = 96;

// Profili di schermo 2026-10-30: una sezione di profilo e' utilizzabile solo se
// dichiara in che PPI sono state scritte le misure (chiave PPI). Il rilascio 005
// scriveva le sezioni di profilo senza PPI: contengono pixel presi a un PPI
// ignoto (nel ticket Mantis #310 pixel a 96 PPI letti poi a 192, quindi form
// dimezzate) e si scartano; chi le sovrascrive alla chiusura le ripulisce.
function ProfiloUtilizzabile(IniFile: TIniFile; const SezioneProfilo: string): boolean;
begin
  Result := IniFile.ReadInteger(SezioneProfilo, 'PPI', 0) > 0;
end;

// Profili di schermo 2026-10-30: un valore che non dipende dalla scala (posizione,
// stato) si cerca prima nella sezione del profilo corrente, se utilizzabile, poi
// nella sezione senza profilo del formato vecchio, che resta come punto di
// partenza per i profili non ancora salvati
function LeggiIntero(IniFile: TIniFile; const SezioneProfilo, SezioneVecchia, Chiave: string; const UsaProfilo: boolean; const Predefinito: integer): integer;
begin
  if UsaProfilo and IniFile.ValueExists(SezioneProfilo, Chiave) then
    Result := IniFile.ReadInteger(SezioneProfilo, Chiave, Predefinito)
  else
    Result := IniFile.ReadInteger(SezioneVecchia, Chiave, Predefinito);
end;

// Una misura (larghezza, altezza, splitter) e' in pixel fisici del PPI in cui e'
// stata scritta: il portatile in desktop remoto e' a 192 PPI (schermo 2880x1920 al
// 200%) e il fisso a 96, quindi 1028 pixel salvati sul fisso occupano meta' della
// larghezza che avevano sul portatile. Si riporta al PPI attuale con
// PPI attuale / PPI salvato; la sezione senza profilo del formato vecchio non
// dichiara il PPI e vale 96, come ogni installazione prima dei profili.
function LeggiMisura(IniFile: TIniFile; const SezioneProfilo, SezioneVecchia, Chiave: string; const UsaProfilo: boolean; const PixelPerPolliceAttuale, Predefinito: integer): integer;
var
  Sezione: string;
  PixelPerPolliceSalvato: integer;
begin
  if UsaProfilo and IniFile.ValueExists(SezioneProfilo, Chiave) then
    Sezione := SezioneProfilo
  else if IniFile.ValueExists(SezioneVecchia, Chiave) then
    Sezione := SezioneVecchia
  else
    Exit(Predefinito);

  PixelPerPolliceSalvato := IniFile.ReadInteger(Sezione, 'PPI', PixelPerPollicePredefiniti);
  if PixelPerPolliceSalvato <= 0 then
    PixelPerPolliceSalvato := PixelPerPollicePredefiniti;

  Result := MulDiv(IniFile.ReadInteger(Sezione, Chiave, Predefinito), PixelPerPolliceAttuale, PixelPerPolliceSalvato);
end;

function PixelPerPolliceDellaForm(Ctrl: TControl): integer;
begin
  Result := Ctrl.CurrentPPI;
  if Result <= 0 then
    Result := PixelPerPollicePredefiniti;
end;

// Profili di schermo 2026-10-30: prima ogni form aveva una sola sezione nel file
// delle impostazioni, con posizione e misure assolute e nessun riferimento allo
// schermo. Chi lavora in ufficio con piu' monitor e da casa sul portatile o in
// desktop remoto sovrascriveva a ogni chiusura la disposizione dell'altro posto,
// e al rientro la form si riapriva fuori dallo schermo (il "programma bloccato"
// delle segnalazioni) o con misure prese a un'altra risoluzione o DPI.
// Ora la sezione porta il profilo dello schermo: numero di monitor, misura del
// desktop virtuale, DPI del monitor principale e RDP per la sessione remota,
// per esempio TWizInserimentoIncaricoForm@4M-7680x1440-96 in ufficio e
// TWizInserimentoIncaricoForm@1M-1440x960-96-RDP da casa. Ogni profilo conserva
// la sua disposizione; il controllo di PosizioneDiRiapertura vale comunque.
class function TzStorage.ProfiloDiSchermo: string;
var
  PixelPerPollice: integer;
begin
  if Assigned(Screen.PrimaryMonitor) then
    PixelPerPollice := Screen.PrimaryMonitor.PixelsPerInch
  else
    PixelPerPollice := Screen.PixelsPerInch;

  Result := Format('%dM-%dx%d-%d', [Screen.MonitorCount, Screen.DesktopWidth, Screen.DesktopHeight, PixelPerPollice]);

  if GetSystemMetrics(SM_REMOTESESSION) <> 0 then
    Result := Result + '-RDP';
end;

class function TzStorage.NomeSezione(Ctrl: TControl): string;
begin
  Result := '';

  if Assigned(Ctrl) and (Ctrl.Name <> '') then
    Result := Ctrl.Name + '@' + ProfiloDiSchermo;
end;

class function TzStorage.FindSplittedControl(Splitter: TcxSplitter): TControl;
var
  P: TPoint;
  I: integer;
  R: TRect;
begin
  Result := nil;

  if not Assigned(Splitter) then
    Exit;

  if Assigned(Splitter.Control) then
  begin
    Result := Splitter.Control;
    Exit;
  end;

  P := Point(Splitter.Left, Splitter.Top);
  case Splitter.AlignSplitter of
    sAlLeft:
      Dec(P.X);
    sAlRight:
      Inc(P.X, Splitter.Width);
    sAlTop:
      Dec(P.Y);
    sAlBottom:
      Inc(P.Y, Splitter.Height);
  else
    Exit;
  end;

  for I := 0 to Splitter.Parent.ControlCount - 1 do
  begin
    Result := Splitter.Parent.Controls[I];

    if Result.Visible and Result.Enabled and (Result.Align <> alClient) then
    begin
      R := Result.BoundsRect;

      if (R.Right - R.Left) = 0 then
        if Splitter.AlignSplitter in [sAlTop, sAlLeft] then
          Dec(R.Left)
        else
          Inc(R.Right);

      if (R.Bottom - R.Top) = 0 then
        if Splitter.AlignSplitter in [sAlTop, sAlLeft] then
          Dec(R.Top)
        else
          Inc(R.Bottom);

      if Result.AlignWithMargins then
      begin
        Dec(R.Top, Result.Margins.Top);
        Dec(R.Left, Result.Margins.Left);
        Inc(R.Right, Result.Margins.Right);
        Inc(R.Bottom, Result.Margins.Bottom);
      end;

      if PtInRect(R, P) then
        Exit;
    end;
  end;
  Result := nil;
end;

class procedure TzStorage.SaveControlToIni(const IniFileName: string; Ctrl: TWinControl);
  procedure SaveControls(IniFile: TIniFile; Section: string; parentCtrl: TWinControl);
  var
    I: integer;
    Ctrl: TControl;
    AName: string;
    Idx: integer;
  begin
    for I := 0 to parentCtrl.ControlCount - 1 do
    begin
      Ctrl := nil;

      if parentCtrl.Controls[I] is TcxSplitter then
        Ctrl := FindSplittedControl(parentCtrl.Controls[I] as TcxSplitter);

      if Assigned(Ctrl) then
        if Ctrl.Align <> alClient then
        begin
          AName := Ctrl.Name;
          case Ctrl.Align of
            AlNone:
              begin
              end;
            AlTop:
              begin
                IniFile.WriteInteger(Section, Ctrl.Name + '_Height', Ctrl.Height);
              end;
            AlBottom:
              begin
                IniFile.WriteInteger(Section, Ctrl.Name + '_Height', Ctrl.Height);
              end;
            AlLeft:
              begin
                IniFile.WriteInteger(Section, Ctrl.Name + '_Width', Ctrl.Width);
              end;
            AlRight:
              begin
                IniFile.WriteInteger(Section, Ctrl.Name + '_Width', Ctrl.Width);
              end;
            alClient:
              begin
              end;
            AlCustom:
              begin
              end;
          end;
        end; // Saved

      if parentCtrl.Controls[I] is TWinControl then
        SaveControls(IniFile, Section, parentCtrl.Controls[I] as TWinControl);
    end;
  end;

var
  IniFile: TIniFile;
  Section: string;
  ws: TWindowState;
begin
  if IniFileName = '' then
    Exit;

  if not Assigned(Ctrl) then
    Exit;

  // Profili di schermo 2026-10-30: si scrive solo la sezione del profilo
  // corrente; quella senza profilo del formato vecchio non si tocca piu'
  Section := NomeSezione(Ctrl);
  if Section = '' then
    Exit;

  IniFile := TIniFile.Create(IniFileName);
  try
    // Una sezione scritta senza PPI (rilascio 005) ha misure a PPI ignoto: si
    // butta, altrimenti le chiavi che questa chiusura non riscrive (form ridotta
    // a icona) resterebbero con il PPI nuovo e sarebbero lette alla scala sbagliata
    if not ProfiloUtilizzabile(IniFile, Section) then
      IniFile.EraseSection(Section);

    IniFile.WriteInteger(Section, 'PPI', PixelPerPolliceDellaForm(Ctrl));

    if Ctrl is TForm then
    begin
      ws := TForm(Ctrl).WindowState;
      IniFile.WriteInteger(Section, 'State', integer(ws));
    end
    else
      ws := wsNormal;

    /// ////////////////////
    // Disposizione adattiva 2026-10-29: una form ridotta a icona ha WindowState
    // ancora wsNormal ma limiti fittizi (-32000, -32000, circa 160x28): salvarli
    // la faceva riaprire minuscola o fuori dallo schermo. In quel caso si tengono
    // i limiti salvati l'ultima volta.
    if (ws = wsNormal) and not ((Ctrl is TForm) and Ctrl.HandleAllocated and IsIconic(Ctrl.Handle)) and (Ctrl.Left > CoordinataRidottaAIcona) and (Ctrl.Top > CoordinataRidottaAIcona) then
    begin
      IniFile.WriteInteger(Section, 'Top', Ctrl.Top);
      IniFile.WriteInteger(Section, 'Left', Ctrl.Left);
      IniFile.WriteInteger(Section, 'Height', Ctrl.Height);
      IniFile.WriteInteger(Section, 'Width', Ctrl.Width);
    end;
    SaveControls(IniFile, Section, Ctrl);
  finally
    FreeAndNil(IniFile);
  end;
end;

class procedure TzStorage.LoadControlFromIni(const IniFileName: string; Ctrl: TWinControl; const MaxWidth, MaxHeight: integer);
const
  MinWidth = 100;
  MinHeight = 100;

  function CalcMaxWidth(Ctrl: TControl): integer;
  var
    Parent: TControl;
  begin
    Result := MaxWidth;

    Parent := Ctrl.Parent;

    while Assigned(Parent) do
    begin

      if Result > Parent.ClientWidth then
        Result := Parent.ClientWidth;

      Parent := Parent.Parent;
    end;
  end;

  function CalcMaxHeight(Ctrl: TControl): integer;
  var
    Parent: TControl;
  begin
    Result := MaxHeight;

    Parent := Ctrl.Parent;

    while Assigned(Parent) do
    begin

      if Result > Parent.ClientHeight then
        Result := Parent.ClientHeight;

      Parent := Parent.Parent;
    end;
  end;

  procedure SetCtrlHeight(Ctrl: TControl; h: integer);
  var
    tmp: integer;
  begin
    // min
    tmp := min(h, CalcMaxHeight(Ctrl) - MinHeight);

    // che si veda un minimo..
    tmp := max(tmp, MinHeight);

    Ctrl.Height := tmp;
  end;

  procedure SetCtrlWidth(Ctrl: TControl; w: integer);
  var
    tmp: integer;
  begin
    tmp := min(w, CalcMaxWidth(Ctrl) - MinWidth);

    // che si veda un minimo..
    tmp := max(tmp, MinWidth);

    Ctrl.Width := tmp;
  end;

  procedure LoadControls(IniFile: TIniFile; const SezioneProfilo, Section: string; const UsaProfilo: boolean; const PixelPerPolliceAttuale: integer; aControl: TWinControl);
  var
    I: integer;
    Ctrl: TControl;
    AName: string;
    Idx: integer;
    Splitter: TcxSplitter;
  begin
    for I := 0 to aControl.ControlCount - 1 do
    begin
      Ctrl := nil;

      if aControl.Controls[I] is TcxSplitter then
        Ctrl := FindSplittedControl(aControl.Controls[I] as TcxSplitter);

      if Assigned(Ctrl) then
        if Ctrl.Align <> alClient then
        begin // Saving
          AName := Ctrl.Name; // FullComponentName(Ctrl);
          case Ctrl.Align of
            AlNone:
              begin
              end;
            AlTop:
              begin
                SetCtrlHeight(Ctrl, LeggiMisura(IniFile, SezioneProfilo, Section, Ctrl.Name + '_Height', UsaProfilo, PixelPerPolliceAttuale, Ctrl.Height));
              end;
            AlBottom:
              begin
                SetCtrlHeight(Ctrl, LeggiMisura(IniFile, SezioneProfilo, Section, Ctrl.Name + '_Height', UsaProfilo, PixelPerPolliceAttuale, Ctrl.Height));
              end;
            AlLeft:
              begin
                SetCtrlWidth(Ctrl, LeggiMisura(IniFile, SezioneProfilo, Section, Ctrl.Name + '_Width', UsaProfilo, PixelPerPolliceAttuale, Ctrl.Width));
              end;
            AlRight:
              begin
                SetCtrlWidth(Ctrl, LeggiMisura(IniFile, SezioneProfilo, Section, Ctrl.Name + '_Width', UsaProfilo, PixelPerPolliceAttuale, Ctrl.Width));
              end;
            alClient:
              begin
              end;
            AlCustom:
              begin
              end;
          end;
        end; // Saved

      if aControl.Controls[I] is TWinControl then
        LoadControls(IniFile, SezioneProfilo, Section, UsaProfilo, PixelPerPolliceAttuale, aControl.Controls[I] as TWinControl);
    end;
  end;

var
  IniFile: TIniFile;
  ws: TWindowState;
  Section: string;
  SezioneProfilo: string;
  UsaProfilo: boolean;
  PixelPerPolliceAttuale: integer;
  Rettangolo: TRect;
begin
  if IniFileName = '' then
    Exit;

  if not Assigned(Ctrl) then
    Exit;

  Section := Ctrl.Name;
  if Section = '' then
    Exit;

  // Profili di schermo 2026-10-30: si legge la sezione del profilo corrente;
  // i valori che mancano si prendono dalla sezione senza profilo (LeggiIntero)
  SezioneProfilo := NomeSezione(Ctrl);

  IniFile := TIniFile.Create(IniFileName);
  try
    UsaProfilo := ProfiloUtilizzabile(IniFile, SezioneProfilo);

    if not (UsaProfilo or IniFile.SectionExists(Section)) then
      Exit;

    PixelPerPolliceAttuale := PixelPerPolliceDellaForm(Ctrl);

    if Ctrl is TForm then
      TForm(Ctrl).Position := poDesigned;

    Rettangolo := Rect(0, 0, 0, 0);
    // Left e Top restano pixel fisici del desktop, su cui decide PosizioneDiRiapertura;
    // Width e Height si riportano al PPI attuale (vedi LeggiMisura)
    Rettangolo.Left := LeggiIntero(IniFile, SezioneProfilo, Section, 'Left', UsaProfilo, Ctrl.Left);
    Rettangolo.Top := LeggiIntero(IniFile, SezioneProfilo, Section, 'Top', UsaProfilo, Ctrl.Top);
    Rettangolo.Width := LeggiMisura(IniFile, SezioneProfilo, Section, 'Width', UsaProfilo, PixelPerPolliceAttuale, Ctrl.Width);
    Rettangolo.Height := LeggiMisura(IniFile, SezioneProfilo, Section, 'Height', UsaProfilo, PixelPerPolliceAttuale, Ctrl.Height);

    // Disposizione adattiva 2026-10-29: prima i limiti salvati si applicavano
    // cosi' com'erano. Una form chiusa su un monitor che ora non c'e' (desktop
    // remoto da un portatile verso un fisso con piu' monitor) si riapriva fuori
    // dallo schermo: con un dialogo modale, come la Rettifica dell'incarico, il
    // programma sembrava bloccato senza consumare CPU. Le regole stanno in
    // PosizioneDiRiapertura; i limiti di progetto sono quelli che la form ha
    // prima di leggere il file.
    if Ctrl is TForm then
      Rettangolo := PosizioneDiRiapertura(Rettangolo, Ctrl.BoundsRect);

    Ctrl.SetBounds(Rettangolo.Left, Rettangolo.Top, Rettangolo.Width, Rettangolo.Height);

    if Ctrl is TForm then
    begin
      ws := TForm(Ctrl).WindowState;
      TForm(Ctrl).WindowState := wsNormal;

      if (UsaProfilo and IniFile.ValueExists(SezioneProfilo, 'State')) or IniFile.ValueExists(Section, 'State') then
        ws := TWindowState(LeggiIntero(IniFile, SezioneProfilo, Section, 'State', UsaProfilo, integer(ws)))
      else
      begin
        // compatibilità con
        if IniFile.ValueExists(Section, 'ShowCmd') then
          if IniFile.ReadInteger(Section, 'ShowCmd', -1) = 3 then
            ws := wsMaximized;
      end;

      // if ws in [wsMaximized, wsMinimized] then
      if ws = wsMaximized then
        TForm(Ctrl).WindowState := wsMaximized
      else
        TForm(Ctrl).WindowState := wsNormal;
    end;

    LoadControls(IniFile, SezioneProfilo, Section, UsaProfilo, PixelPerPolliceAttuale, Ctrl);
  finally
    FreeAndNil(IniFile);
  end;
end;

end.
