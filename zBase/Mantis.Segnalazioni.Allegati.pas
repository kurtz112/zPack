// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------

// File che entrano ed escono dalle segnalazioni di assistenza: cartella
// temporanea e sua pulizia, schermata, file e immagini dagli appunti,
// riconoscimento dei programmi, archivio zip. Servono alla form
// "Le mie segnalazioni" e alla finestra di nuova richiesta.

unit Mantis.Segnalazioni.Allegati;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes;

// %TEMP%\zMantis\<ASottocartella>, creata se manca.
function MantisCartellaTemporanea(const ASottocartella: string): string;

// Toglie da %TEMP%\zMantis i file piu' vecchi di AGiorni e le cartelle
// rimaste vuote. Non solleva: un file in uso resta dov'e'.
procedure MantisPulisciCartellaTemporanea(AGiorni: Integer);

// Fotografa lo schermo su cui sta AFinestra, dopo averla nascosta un istante
// perche' nella foto si veda cio' che c'e' dietro (la finestra del
// programma). Salva un PNG nella cartella temporanea e ne restituisce il
// percorso.
function MantisCatturaSchermata(AFinestra: HWND): string;

// True se negli appunti c'e' qualcosa da allegare: file copiati da Esplora
// risorse o un'immagine.
function MantisAppuntiConAllegati: Boolean;
// File da allegare presi dagli appunti: i file copiati cosi' come sono,
// un'immagine salvata come PNG nella cartella temporanea.
function MantisAllegatiDagliAppunti: TArray<string>;

// True per i file che Windows eseguirebbe con un doppio clic: programmi,
// script, installatori, collegamenti. Non si aprono mai dalla form.
function MantisAllegatoEseguibile(const ANome: string): Boolean;

// Comprime i file esistenti di AFile in AArchivio (sovrascritto).
procedure MantisArchivia(const AArchivio: string; const AFile: array of string);

implementation

uses
  Winapi.ShellAPI,
  System.IOUtils,
  System.StrUtils,
  System.Zip,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Clipbrd,
  Vcl.Imaging.pngimage;

const
  CartellaRadice = 'zMantis';

  // Estensioni che ShellExecute farebbe partire. Il file arriva da Internet:
  // basta un account Mantis compromesso perche' un "documento" sia un
  // programma.
  EstensioniEseguibili: array [0 .. 27] of string = ('.exe', '.com', '.bat', '.cmd', '.pif', '.scr', '.msi', '.msp',
    '.msc', '.cpl', '.dll', '.ocx', '.sys', '.js', '.jse', '.vbs', '.vbe', '.wsf', '.wsh', '.ps1', '.psm1', '.hta',
    '.lnk', '.url', '.reg', '.jar', '.appref-ms', '.application');

function NomeConData(const APrefisso, AEstensione: string): string;
begin
  Result := APrefisso + ' ' + FormatDateTime('yyyymmdd hhnnss', Now) + AEstensione;
end;

function MantisCartellaTemporanea(const ASottocartella: string): string;
begin
  Result := TPath.Combine(TPath.GetTempPath, CartellaRadice);
  if ASottocartella <> '' then
    Result := TPath.Combine(Result, ASottocartella);
  ForceDirectories(Result);
end;

procedure MantisPulisciCartellaTemporanea(AGiorni: Integer);
var
  Radice, Percorso: string;
  Limite: TDateTime;
  Cartelle: TArray<string>;
  Indice: Integer;
begin
  Radice := TPath.Combine(TPath.GetTempPath, CartellaRadice);
  if not TDirectory.Exists(Radice) then
    Exit;
  Limite := Now - AGiorni;
  try
    for Percorso in TDirectory.GetFiles(Radice, '*', TSearchOption.soAllDirectories) do
      try
        if TFile.GetLastWriteTime(Percorso) < Limite then
          TFile.Delete(Percorso);
      except
        // In uso o protetto: resta per la prossima volta.
      end;
    // Dalle piu' profonde, cosi' una cartella si svuota prima della madre.
    Cartelle := TDirectory.GetDirectories(Radice, '*', TSearchOption.soAllDirectories);
    for Indice := High(Cartelle) downto 0 do
      try
        if TDirectory.IsEmpty(Cartelle[Indice]) then
          TDirectory.Delete(Cartelle[Indice]);
      except
      end;
  except
    // La pulizia non deve mai impedire di aprire la form.
  end;
end;

procedure SalvaPng(ABitmap: TBitmap; const APercorso: string);
var
  Png: TPngImage;
begin
  Png := TPngImage.Create;
  try
    Png.Assign(ABitmap);
    Png.SaveToFile(APercorso);
  finally
    Png.Free;
  end;
end;

function MantisCatturaSchermata(AFinestra: HWND): string;
var
  Schermo: TMonitor;
  Area: TRect;
  Bitmap: TBitmap;
  Dc: HDC;
  Fine: Cardinal;
begin
  Schermo := Screen.MonitorFromWindow(AFinestra);
  if Schermo <> nil then
    Area := Schermo.BoundsRect
  else
    Area := Screen.DesktopRect;

  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.SetSize(Area.Width, Area.Height);
    // ShowWindow e non Visible: la finestra puo' essere modale, e Visible
    // su una finestra modale solleva.
    ShowWindow(AFinestra, SW_HIDE);
    try
      // Il tempo perche' Windows ridisegni cio' che stava sotto.
      Fine := GetTickCount + 350;
      while GetTickCount < Fine do
      begin
        Application.ProcessMessages;
        Sleep(20);
      end;
      Dc := GetDC(0);
      try
        BitBlt(Bitmap.Canvas.Handle, 0, 0, Area.Width, Area.Height, Dc, Area.Left, Area.Top, SRCCOPY);
      finally
        ReleaseDC(0, Dc);
      end;
    finally
      ShowWindow(AFinestra, SW_SHOW);
      SetForegroundWindow(AFinestra);
    end;
    Result := TPath.Combine(MantisCartellaTemporanea('schermate'), NomeConData('Schermata', '.png'));
    SalvaPng(Bitmap, Result);
  finally
    Bitmap.Free;
  end;
end;

function MantisAppuntiConAllegati: Boolean;
begin
  Result := Clipboard.HasFormat(CF_HDROP) or Clipboard.HasFormat(CF_BITMAP);
end;

function MantisAllegatiDagliAppunti: TArray<string>;
var
  Elenco: HDROP;
  Quanti, Indice: Integer;
  Nome: array [0 .. MAX_PATH] of Char;
  Bitmap: TBitmap;
  Percorso: string;
begin
  Result := [];
  Clipboard.Open;
  try
    if Clipboard.HasFormat(CF_HDROP) then
    begin
      Elenco := Clipboard.GetAsHandle(CF_HDROP);
      if Elenco <> 0 then
      begin
        Quanti := DragQueryFile(Elenco, $FFFFFFFF, nil, 0);
        for Indice := 0 to Quanti - 1 do
          if DragQueryFile(Elenco, Indice, Nome, Length(Nome)) > 0 then
            if TFile.Exists(string(Nome)) then
              Result := Result + [string(Nome)];
      end;
      Exit;
    end;

    if Clipboard.HasFormat(CF_BITMAP) then
    begin
      Bitmap := TBitmap.Create;
      try
        Bitmap.Assign(Clipboard);
        Percorso := TPath.Combine(MantisCartellaTemporanea('schermate'), NomeConData('Immagine', '.png'));
        SalvaPng(Bitmap, Percorso);
        Result := [Percorso];
      finally
        Bitmap.Free;
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

function MantisAllegatoEseguibile(const ANome: string): Boolean;
begin
  Result := MatchText(ExtractFileExt(ANome), EstensioniEseguibili);
end;

procedure MantisArchivia(const AArchivio: string; const AFile: array of string);
var
  Archivio: TZipFile;
  Percorso: string;
begin
  if TFile.Exists(AArchivio) then
    TFile.Delete(AArchivio);
  Archivio := TZipFile.Create;
  try
    Archivio.Open(AArchivio, zmWrite);
    for Percorso in AFile do
      if (Percorso <> '') and TFile.Exists(Percorso) then
        Archivio.Add(Percorso, ExtractFileName(Percorso));
    Archivio.Close;
  finally
    Archivio.Free;
  end;
end;

end.
