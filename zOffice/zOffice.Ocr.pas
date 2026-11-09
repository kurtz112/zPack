// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-27
// ---------------------------------------------------------------------------
unit zOffice.Ocr;

// Punto di accesso unico all'OCR: sceglie il driver, rende le pagine del PDF a
// immagine con il motore PDF DevExpress (TdxPDFDocument) e restituisce il testo.
//
// Non dipende da Envision: il rendering della pagina, che prima passava da
// TImageScrollBox, e' fatto con dxPDFDocumentExportToImageEx.
//
// Uso tipico:
//   Testo := TzOcr.EstraiTestoDaPdf(NomeFile);
//     - prima prova il livello di testo del PDF (nessun OCR, immediato);
//     - se il PDF e' una scansione senza testo, passa all'OCR pagina per pagina.
//
// Configurazione (in genere una volta sola all'avvio dell'applicazione):
//   TzOcr.Engine := oeWindowsMedia;      // predefinito: oeTesseract
//   TzOcr.CartellaTesseract := '...';    // vuota = ricerca automatica
//   TzOcr.Lingua := 'it';
//   TzOcr.Dpi := 300;
//   TzOcr.MaxPagineOcr := 20;

interface

uses
  Vcl.Graphics,
  dxPDFDocument,
  zOffice.Ocr.Intf;

type
  TzOcrEngine = (
    // Nessun OCR: si estrae solo il livello di testo del PDF.
    oeNessuno,
    // tesseract.exe: gira ovunque, anche su Windows Server Core.
    oeTesseract,
    // Engine incluso in Windows: niente da distribuire, ma non c'e' su Server Core
    // e sui Server richiede la funzionalita' a richiesta "OCR" piu' il language pack.
    oeWindowsMedia,
    // Prova prima Windows.Media.Ocr, ripiega su Tesseract se non disponibile.
    oeAutomatico);

  TzOcr = class
  strict private
    class var FDriver: IzOcrDriver;
    class var FEngineDelDriver: TzOcrEngine;
    class var FLinguaDelDriver: string;
    class function CreaDriver(const Engine: TzOcrEngine): IzOcrDriver; static;
    class function RenderizzaPagina(const Pdf: TdxPDFDocument; const Indice: integer; const Immagine: TBitmap): boolean; static;
  public
    class var Engine: TzOcrEngine;
    class var Lingua: string;
    class var Dpi: integer;
    class var CartellaTesseract: string;
    // Numero massimo di pagine sottoposte a OCR in un singolo documento
    // (l'OCR costa qualche secondo a pagina). 0 = nessun limite.
    class var MaxPagineOcr: integer;

    class constructor Create;

    // Driver attivo, creato alla prima richiesta e riusato finche' non cambiano
    // engine o lingua. Puo' restituire nil (engine oeNessuno o nessun driver
    // utilizzabile sulla macchina).
    class function Driver: IzOcrDriver; static;
    class function Disponibile: boolean; static;
    class function NomeEngine: string; static;

    // OCR di una singola immagine gia' pronta.
    class function RiconosciImmagine(const Immagine: TBitmap): string; static;
    // OCR delle pagine del PDF (ignora il livello di testo eventualmente presente).
    class function RiconosciPdf(const NomeFile: string): string; static;
    // Solo livello di testo del PDF, senza OCR.
    class function EstraiTestoLayerPdf(const NomeFile: string): string; static;
    // Livello di testo e, se vuoto, OCR: e' il comportamento usato all'importazione.
    class function EstraiTestoDaPdf(const NomeFile: string): string; static;
  end;

implementation

uses
  System.SysUtils,
  System.Types,
  System.IOUtils,
  dxGDIPlusClasses,
  zOffice.Ocr.Tesseract,
  zOffice.Ocr.WindowsMedia,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

{ TzOcr }

class constructor TzOcr.Create;
begin
  // Predefinito prudente: Tesseract e' l'engine gia' in uso e funziona su
  // qualunque edizione di Windows, server compresi.
  Engine := oeTesseract;
  Lingua := 'it';
  Dpi := 300;
  CartellaTesseract := '';
  MaxPagineOcr := 20;

  FEngineDelDriver := oeNessuno;
  FLinguaDelDriver := '';
end;

class function TzOcr.CreaDriver(const Engine: TzOcrEngine): IzOcrDriver;
var
  Candidato: IzOcrDriver;
begin
  result := nil;

  case Engine of
    oeNessuno:
      Exit;

    oeTesseract:
      begin
        Candidato := TzOcrDriverTesseract.Create(CartellaTesseract);
        if Candidato.Disponibile(Lingua) then
          result := Candidato;
      end;

    oeWindowsMedia:
      begin
        Candidato := TzOcrDriverWindowsMedia.Create;
        if Candidato.Disponibile(Lingua) then
          result := Candidato;
      end;

    oeAutomatico:
      begin
        Candidato := TzOcrDriverWindowsMedia.Create;
        if Candidato.Disponibile(Lingua) then
          Exit(Candidato);

        Candidato := TzOcrDriverTesseract.Create(CartellaTesseract);
        if Candidato.Disponibile(Lingua) then
          result := Candidato;
      end;
  end;
end;

class function TzOcr.Driver: IzOcrDriver;
begin
  if (FDriver = nil) or (FEngineDelDriver <> Engine) or (FLinguaDelDriver <> Lingua) then
  begin
    // La ricerca dell'eseguibile e l'interrogazione di WinRT non devono poter
    // far fallire il chiamante: al massimo restano senza engine.
    try
      FDriver := CreaDriver(Engine);
    except
      on e: Exception do
      begin
        siMain.LogException(e);
        FDriver := nil;
      end;
    end;

    FEngineDelDriver := Engine;
    FLinguaDelDriver := Lingua;

    if FDriver = nil then
      siMain.LogVerbose('OCR: nessun engine disponibile su questa macchina')
    else
      siMain.LogVerbose('OCR: engine attivo ' + FDriver.Nome);
  end;

  result := FDriver;
end;

class function TzOcr.Disponibile: boolean;
begin
  result := Driver <> nil;
end;

class function TzOcr.NomeEngine: string;
var
  Attivo: IzOcrDriver;
begin
  Attivo := Driver;

  if Attivo = nil then
    result := 'nessuno'
  else
    result := Attivo.Nome;
end;

class function TzOcr.RiconosciImmagine(const Immagine: TBitmap): string;
var
  Attivo: IzOcrDriver;
begin
  result := '';

  try
    Attivo := Driver;
    if Attivo = nil then
      Exit;

    result := Attivo.Riconosci(Immagine, Lingua);
  except
    on e: Exception do
    begin
      siMain.LogException(e);
      result := '';
    end;
  end;
end;

// Rende la pagina a immagine con il motore PDF DevExpress. Il fattore di zoom 1
// corrisponde a 96 dpi (vedi TdxPDFDocumentExport.CreateRenderParameters).
class function TzOcr.RenderizzaPagina(const Pdf: TdxPDFDocument; const Indice: integer; const Immagine: TBitmap): boolean;
var
  Pagina: TdxSmartImage;
  Zoom: Double;
begin
  result := False;

  Zoom := Dpi / 96;
  if Zoom <= 0 then
    Zoom := 1;

  Pagina := TdxSmartImage.Create;
  try
    if not dxPDFDocumentExportToImageEx(Pdf, Indice, Zoom, Pagina) then
      Exit;

    if (Pagina.Width = 0) or (Pagina.Height = 0) then
      Exit;

    Immagine.PixelFormat := pf32bit;
    Immagine.SetSize(Pagina.Width, Pagina.Height);
    Immagine.Canvas.Brush.Color := clWhite;
    Immagine.Canvas.FillRect(Rect(0, 0, Immagine.Width, Immagine.Height));
    Immagine.Canvas.Draw(0, 0, Pagina);

    result := True;
  finally
    FreeAndNil(Pagina);
  end;
end;

class function TzOcr.RiconosciPdf(const NomeFile: string): string;
var
  Attivo: IzOcrDriver;
  Pdf: TdxPDFDocument;
  Immagine: TBitmap;
  Testo: string;
  Pagine: integer;
  i: integer;
begin
  result := '';

  siMain.EnterMethod('TzOcr.RiconosciPdf');
  try
    try
      Attivo := Driver;
      if Attivo = nil then
        Exit;

      if not TFile.Exists(NomeFile) then
        Exit;

      Pdf := TdxPDFDocument.Create;
      try
        Pdf.LoadFromFile(NomeFile);

        Pagine := Pdf.PageCount;
        if (MaxPagineOcr > 0) and (Pagine > MaxPagineOcr) then
        begin
          siMain.LogWarning(Format('OCR limitato alle prime %d pagine di %d: %s', [MaxPagineOcr, Pagine, NomeFile]));
          Pagine := MaxPagineOcr;
        end;

        for i := 0 to Pagine - 1 do
        begin
          Immagine := TBitmap.Create;
          try
            if not RenderizzaPagina(Pdf, i, Immagine) then
              Continue;

            Testo := Attivo.Riconosci(Immagine, Lingua).Trim;
          finally
            FreeAndNil(Immagine);
          end;

          if Testo = '' then
            Continue;

          if result <> '' then
            result := result + sLineBreak;

          result := result + Testo;
        end;
      finally
        FreeAndNil(Pdf);
      end;

      result := result.Trim;
    except
      on e: Exception do
      begin
        siMain.LogException(e);
        result := '';
      end;
    end;
  finally
    siMain.LeaveMethod('TzOcr.RiconosciPdf');
  end;
end;

class function TzOcr.EstraiTestoLayerPdf(const NomeFile: string): string;
var
  Pdf: TdxPDFDocument;
  i: integer;
begin
  result := '';

  if not TFile.Exists(NomeFile) then
    Exit;

  try
    Pdf := TdxPDFDocument.Create;
    try
      Pdf.LoadFromFile(NomeFile);

      for i := 0 to Pdf.PageCount - 1 do
      begin
        result := result + Pdf.Pages[i].Text;

        if i < Pdf.PageCount then
          if not result.IsEmpty then
            result := result + sLineBreak;
      end;

      result := result.Trim;
    finally
      FreeAndNil(Pdf);
    end;
  except
    on e: Exception do
    begin
      siMain.LogException(e);
      result := '';
    end;
  end;
end;

// Confine di garanzia verso l'applicazione: qualunque cosa vada storta nel PDF,
// nel rendering o nell'OCR, questa funzione restituisce al massimo stringa vuota
// e lascia una riga nel registro. Non solleva eccezioni e non mostra messaggi:
// l'estrazione del testo non deve mai impedire di allegare un documento.
class function TzOcr.EstraiTestoDaPdf(const NomeFile: string): string;
begin
  result := '';

  try
    result := EstraiTestoLayerPdf(NomeFile);

    if result.IsEmpty then
      result := RiconosciPdf(NomeFile);
  except
    on e: Exception do
    begin
      siMain.LogException(e);
      result := '';
    end;
  end;
end;

end.
