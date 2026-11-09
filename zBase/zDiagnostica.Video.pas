// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Video
//
// Filmato della registrazione per l'assistenza (zDiagnostica.Log): riprende
// il monitor su cui sta l'applicazione e lo scrive in MP4 H.264 con Media
// Foundation, a parti di dimensione limitata.
//
// COSA SI RIPRENDE
// Il monitor intero, perche' il filmato ha dimensioni fisse e le form
// modali e i menu a tendina sono finestre a se', che possono uscire dal
// rettangolo della finestra principale. Tutto cio' che non appartiene al
// processo indicato (Processo) diventa nero: si scorrono le finestre di
// primo livello in ordine di profondita' e di quelle del processo resta solo
// la parte non coperta da finestre di altri processi. Cosi' la posta, il
// browser e la barra delle applicazioni non finiscono nel filmato. Processo
// = 0 spegne la mascheratura (solo per le prove).
// I tasti premuti non si registrano: si disegnano solo il puntatore e i clic.
//
// UN THREAD PROPRIO
// Cattura e codifica girano qui, non in un timer del thread principale: se
// l'applicazione si blocca il timer non scatterebbe e il filmato salterebbe
// proprio i momenti che interessano. Il thread continua a riprendere la
// finestra bloccata, come la vede l'utente.
//
// TEMPI MORTI
// Un fotogramma uguale al precedente (confronto senza puntatore e senza
// orologio) non si scrive. Se lo schermo resta fermo piu' di
// SogliaTempoMortoMs, quel tratto occupa nel filmato al massimo
// DurataTempoMortoMs: lo spostamento del mouse verso un menu, l'attesa prima
// di cliccare, la riconnessione del database. Un clic conta come
// cambiamento e lascia un cerchio sul punto cliccato. L'ora vera e' stampata
// nell'angolo, cosi' filmato e log si confrontano anche dopo l'accelerazione.
//
// Unit autonoma: RTL, VCL e Media Foundation, nessuna unit delle applicazioni.
//
// ***************************************************************************

unit zDiagnostica.Video;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Diagnostics,
  System.Generics.Collections;

type
  TzModoCodifica = (mcQualita, mcBitrate, mcPredefinito);

  TzStatisticheVideo = record
    FotogrammiCatturati: Integer;
    FotogrammiScritti: Integer;
    TempiMortiAccorciati: Integer;
    // Tempo vero tolto al filmato dall'accelerazione dei tempi morti.
    MillisecondiTolti: Int64;
    MillisecondiCatturaTotali: Int64;
    MillisecondiCodificaTotali: Int64;
    MillisecondiCatturaMassimi: Int64;
    DurataVeraMs: Int64;
    DurataFilmatoMs: Int64;
    LarghezzaFilmato: Integer;
    AltezzaFilmato: Integer;
    Parti: TArray<string>;
  end;

  TzRegistratoreVideo = class(TThread)
  public const
    // Bit al secondo del codificatore: con il bitrate fisso e' anche il tetto
    // certo della dimensione, che zDiagnostica.Log usa per le stime.
    BitratePredefinito = 1000000;
  private
    FCartella: string;
    FPrefisso: string;
    FProcesso: DWORD;
    FMonitor: TRect;
    FFotogrammiAlSecondo: Integer;
    FLarghezzaMassima: Integer;
    FDimensioneParteByte: Int64;
    FModo: TzModoCodifica;
    FQualita: Integer;
    FBitrate: Integer;
    FSogliaTempoMortoMs: Integer;
    FDurataTempoMortoMs: Integer;
    FSogliaPixelCambiati: Integer;
    FCatturaFinestreALivelli: boolean;
    FPausa: boolean;
    FErrore: string;
    FFermata: TEvent;
    FBlocco: TCriticalSection;
    FStatistiche: TzStatisticheVideo;
    procedure Registra;
    function GetStatistiche: TzStatisticheVideo;
  protected
    procedure Execute; override;
  public
    // AProcesso = processo le cui finestre restano visibili (0 = nessuna
    // mascheratura). AMonitor = rettangolo del monitor in coordinate dello
    // schermo, in pixel fisici: il processo deve essere consapevole dei DPI.
    constructor Create(const ACartella, APrefisso: string; AProcesso: DWORD; const AMonitor: TRect);
    destructor Destroy; override;

    // Chiede al thread di chiudere l'ultima parte e uscire. Va seguita da WaitFor.
    procedure Ferma;

    // True se Media Foundation c'e'; AMotivo dice perche' no.
    class function Disponibile(out AMotivo: string): boolean;

    property FotogrammiAlSecondo: Integer read FFotogrammiAlSecondo write FFotogrammiAlSecondo;
    property LarghezzaMassima: Integer read FLarghezzaMassima write FLarghezzaMassima;
    property DimensioneParteByte: Int64 read FDimensioneParteByte write FDimensioneParteByte;
    property Modo: TzModoCodifica read FModo write FModo;
    // 0-100, solo con mcQualita.
    property Qualita: Integer read FQualita write FQualita;
    // Bit al secondo, con mcBitrate e come valore indicativo negli altri modi.
    property Bitrate: Integer read FBitrate write FBitrate;
    property SogliaTempoMortoMs: Integer read FSogliaTempoMortoMs write FSogliaTempoMortoMs;
    property DurataTempoMortoMs: Integer read FDurataTempoMortoMs write FDurataTempoMortoMs;
    // Un fotogramma con al massimo tanti pixel diversi dal precedente conta
    // come uguale. Serve per il cursore lampeggiante di un campo di testo, che
    // altrimenti renderebbe diverso ogni fotogramma e il filmato non avrebbe
    // mai tempi morti (verificato con la prova del 2026-10-29). I cambiamenti
    // piccoli non si perdono: si sommano, perche' il confronto e' sempre con
    // l'ultimo fotogramma scritto.
    property SogliaPixelCambiati: Integer read FSogliaPixelCambiati write FSogliaPixelCambiati;
    // CAPTUREBLT: comprende le finestre a livelli (suggerimenti, avvisi,
    // ombre dei menu), ma rende la cattura piu' lenta.
    property CatturaFinestreALivelli: boolean read FCatturaFinestreALivelli write FCatturaFinestreALivelli;
    // In pausa non si cattura: alla ripresa il tratto conta come tempo morto.
    property Pausa: boolean read FPausa write FPausa;
    // Vuoto se il thread e' finito senza errori.
    property Errore: string read FErrore;
    property Statistiche: TzStatisticheVideo read GetStatistiche;
  end;

implementation

uses
  Winapi.ActiveX,
  Winapi.DwmApi,
  System.Win.ComObj,
  System.Math,
  zDiagnostica.Video.MediaFoundation;

const
  DWMWA_CLOAKED = 14;
  CAPTUREBLT = $40000000; // wingdi.h, non dichiarata in Winapi.Windows
  // Unita' di tempo di Media Foundation: 100 nanosecondi.
  UnitaPerMillisecondo = 10000;

type
  // Stato passato alla funzione di EnumWindows per costruire la regione
  // visibile delle finestre del processo.
  TStatoMaschera = record
    Processo: DWORD;
    Nostra: HRGN; // parti visibili delle finestre del processo
    Coperta: HRGN; // tutto cio' che sta sopra la finestra in esame
  end;
  PStatoMaschera = ^TStatoMaschera;

  // Bitmap DIB a 32 bit dall'alto in basso, con il suo DC.
  TSuperficie = record
    DC: HDC;
    Bitmap: HBITMAP;
    Vecchia: HGDIOBJ;
    Bit: PByte;
    Larghezza: Integer;
    Altezza: Integer;
    procedure Crea(ALarghezza, AAltezza: Integer);
    procedure Libera;
    function Dimensione: Integer;
  end;

procedure TSuperficie.Crea(ALarghezza, AAltezza: Integer);
var
  Info: TBitmapInfo;
  Schermo: HDC;
begin
  Larghezza := ALarghezza;
  Altezza := AAltezza;
  FillChar(Info, SizeOf(Info), 0);
  Info.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  Info.bmiHeader.biWidth := ALarghezza;
  Info.bmiHeader.biHeight := -AAltezza; // negativo = dall'alto in basso, come vuole MF_MT_DEFAULT_STRIDE positivo
  Info.bmiHeader.biPlanes := 1;
  Info.bmiHeader.biBitCount := 32;
  Info.bmiHeader.biCompression := BI_RGB;
  Schermo := GetDC(0);
  try
    DC := CreateCompatibleDC(Schermo);
  finally
    ReleaseDC(0, Schermo);
  end;
  Bitmap := CreateDIBSection(DC, Info, DIB_RGB_COLORS, Pointer(Bit), 0, 0);
  if Bitmap = 0 then
    RaiseLastOSError;
  Vecchia := SelectObject(DC, Bitmap);
end;

procedure TSuperficie.Libera;
begin
  if DC <> 0 then
  begin
    SelectObject(DC, Vecchia);
    DeleteDC(DC);
    DC := 0;
  end;
  if Bitmap <> 0 then
  begin
    DeleteObject(Bitmap);
    Bitmap := 0;
  end;
end;

function TSuperficie.Dimensione: Integer;
begin
  result := Larghezza * Altezza * 4;
end;

// Numero di pixel diversi fra due fotogrammi, contato fino a ALimite + 1:
// oltre non serve sapere quanti sono, basta sapere che sono troppi.
function PixelCambiati(APrimo, ASecondo: PCardinal; APixel, ALimite: Integer): Integer;
var
  Indice: Integer;
begin
  result := 0;
  for Indice := 0 to APixel - 1 do
  begin
    if APrimo^ <> ASecondo^ then
    begin
      Inc(result);
      if result > ALimite then
        Exit;
    end;
    Inc(APrimo);
    Inc(ASecondo);
  end;
end;

// Rettangolo visibile di una finestra: senza i bordi invisibili di
// ridimensionamento che GetWindowRect comprende. Con GetWindowRect una
// striscia di qualche pixel di un'altra applicazione resterebbe visibile
// accanto alle finestre del processo.
function RettangoloVisibile(AFinestra: HWND; out ARettangolo: TRect): boolean;
begin
  result := Succeeded(DwmGetWindowAttribute(AFinestra, DWMWA_EXTENDED_FRAME_BOUNDS, @ARettangolo,
    SizeOf(ARettangolo)));
  if not result then
    result := GetWindowRect(AFinestra, ARettangolo);
end;

function FinestraNascosta(AFinestra: HWND): boolean;
var
  Nascosta: DWORD;
begin
  if not IsWindowVisible(AFinestra) or IsIconic(AFinestra) then
    Exit(True);
  // Finestre "visibili" ma nascoste da DWM: altri desktop virtuali, app
  // sospese. Senza questo controllo annerirebbero zone che sullo schermo
  // mostrano l'applicazione.
  Nascosta := 0;
  if Succeeded(DwmGetWindowAttribute(AFinestra, DWMWA_CLOAKED, @Nascosta, SizeOf(Nascosta))) and (Nascosta <> 0) then
    Exit(True);
  // Finestre trasparenti che lasciano passare i clic (layered + transparent):
  // sono velature sopra lo schermo, non finestre che coprono l'applicazione.
  // La tela della scrittura a penna di Windows (TabTip, "Shell Handwriting
  // Canvas") occupa tutto il monitor principale, in primo piano: contata come
  // finestra estranea anneriva l'intero filmato (ticket Gesty #299).
  if GetWindowLong(AFinestra, GWL_EXSTYLE) and (WS_EX_LAYERED or WS_EX_TRANSPARENT) = (WS_EX_LAYERED or WS_EX_TRANSPARENT) then
    Exit(True);
  result := False;
end;

function RaccogliFinestra(AFinestra: HWND; AParametro: LPARAM): BOOL; stdcall;
var
  Stato: PStatoMaschera;
  Rettangolo: TRect;
  Regione, Scoperta: HRGN;
  Processo: DWORD;
begin
  result := True;
  Stato := PStatoMaschera(AParametro);
  if FinestraNascosta(AFinestra) then
    Exit;
  if not RettangoloVisibile(AFinestra, Rettangolo) or Rettangolo.IsEmpty then
    Exit;

  Regione := CreateRectRgnIndirect(Rettangolo);
  try
    GetWindowThreadProcessId(AFinestra, Processo);
    if Processo = Stato.Processo then
    begin
      // Della finestra del processo resta la parte non coperta da quelle
      // che stanno sopra (EnumWindows le restituisce dall'alto in basso).
      Scoperta := CreateRectRgn(0, 0, 0, 0);
      try
        CombineRgn(Scoperta, Regione, Stato.Coperta, RGN_DIFF);
        CombineRgn(Stato.Nostra, Stato.Nostra, Scoperta, RGN_OR);
      finally
        DeleteObject(Scoperta);
      end;
    end;
    CombineRgn(Stato.Coperta, Stato.Coperta, Regione, RGN_OR);
  finally
    DeleteObject(Regione);
  end;
end;

// Annerisce in ASuperficie (che contiene il monitor AMonitor) tutto cio' che
// non appartiene al processo.
procedure MascheraFinestreEstranee(const ASuperficie: TSuperficie; const AMonitor: TRect; AProcesso: DWORD);
var
  Stato: TStatoMaschera;
  Estranea: HRGN;
  Nero: HBRUSH;
begin
  Stato.Processo := AProcesso;
  Stato.Nostra := CreateRectRgn(0, 0, 0, 0);
  Stato.Coperta := CreateRectRgn(0, 0, 0, 0);
  Estranea := CreateRectRgnIndirect(AMonitor);
  Nero := GetStockObject(BLACK_BRUSH);
  try
    EnumWindows(@RaccogliFinestra, LPARAM(@Stato));
    CombineRgn(Estranea, Estranea, Stato.Nostra, RGN_DIFF);
    OffsetRgn(Estranea, -AMonitor.Left, -AMonitor.Top);
    FillRgn(ASuperficie.DC, Estranea, Nero);
  finally
    DeleteObject(Estranea);
    DeleteObject(Stato.Coperta);
    DeleteObject(Stato.Nostra);
  end;
end;

procedure DisegnaPuntatore(const ASuperficie: TSuperficie; const AMonitor: TRect; AScala: Double; AClic: boolean);
var
  Puntatore: TCursorInfo;
  Icona: TIconInfo;
  X, Y: Integer;
  Penna, VecchiaPenna, VecchioPennello: HGDIOBJ;
begin
  FillChar(Puntatore, SizeOf(Puntatore), 0);
  Puntatore.cbSize := SizeOf(Puntatore);
  if not GetCursorInfo(Puntatore) or (Puntatore.flags and CURSOR_SHOWING = 0) then
    Exit;
  X := Round((Puntatore.ptScreenPos.X - AMonitor.Left) * AScala);
  Y := Round((Puntatore.ptScreenPos.Y - AMonitor.Top) * AScala);

  if AClic then
  begin
    // Cerchio giallo sul punto cliccato: accelerando i tempi morti e' l'unico
    // modo di vedere dove l'utente ha premuto.
    Penna := CreatePen(PS_SOLID, 3, RGB(255, 200, 0));
    VecchiaPenna := SelectObject(ASuperficie.DC, Penna);
    VecchioPennello := SelectObject(ASuperficie.DC, GetStockObject(NULL_BRUSH));
    Ellipse(ASuperficie.DC, X - 14, Y - 14, X + 14, Y + 14);
    SelectObject(ASuperficie.DC, VecchioPennello);
    SelectObject(ASuperficie.DC, VecchiaPenna);
    DeleteObject(Penna);
  end;

  if GetIconInfo(Puntatore.hCursor, Icona) then
  begin
    try
      DrawIconEx(ASuperficie.DC, X - Integer(Icona.xHotspot), Y - Integer(Icona.yHotspot), Puntatore.hCursor, 0, 0, 0, 0,
        DI_NORMAL);
    finally
      if Icona.hbmMask <> 0 then
        DeleteObject(Icona.hbmMask);
      if Icona.hbmColor <> 0 then
        DeleteObject(Icona.hbmColor);
    end;
  end;
end;

procedure DisegnaOrologio(const ASuperficie: TSuperficie; AIstante: TDateTime);
var
  Testo: string;
begin
  Testo := ' ' + FormatDateTime('hh:nn:ss', AIstante) + ' ';
  SetBkMode(ASuperficie.DC, OPAQUE);
  SetBkColor(ASuperficie.DC, RGB(0, 0, 0));
  SetTextColor(ASuperficie.DC, RGB(255, 255, 255));
  TextOut(ASuperficie.DC, 4, ASuperficie.Altezza - 20, PChar(Testo), Length(Testo));
end;

// TzRegistratoreVideo

constructor TzRegistratoreVideo.Create(const ACartella, APrefisso: string; AProcesso: DWORD; const AMonitor: TRect);
begin
  inherited Create(True);
  FCartella := IncludeTrailingPathDelimiter(ACartella);
  FPrefisso := APrefisso;
  FProcesso := AProcesso;
  FMonitor := AMonitor;
  FFotogrammiAlSecondo := 3;
  // Risoluzione piena fino a 1920 px e bitrate fisso di 1 Mbit/s: a 1280 px
  // e 300 kbit/s il testo delle griglie era illeggibile, e la qualita'
  // costante dava file piu' grandi del bitrate fisso (prove del 2026-10-29).
  FLarghezzaMassima := 1920;
  FDimensioneParteByte := 4 * 1024 * 1024;
  FModo := mcPredefinito;
  FQualita := 60;
  FBitrate := BitratePredefinito;
  FSogliaTempoMortoMs := 2000;
  FDurataTempoMortoMs := 1000;
  FSogliaPixelCambiati := 60;
  FCatturaFinestreALivelli := True;
  FFermata := TEvent.Create(nil, True, False, '');
  FBlocco := TCriticalSection.Create;
end;

destructor TzRegistratoreVideo.Destroy;
begin
  inherited;
  FreeAndNil(FFermata);
  FreeAndNil(FBlocco);
end;

class function TzRegistratoreVideo.Disponibile(out AMotivo: string): boolean;
begin
  result := MediaFoundationPresente(AMotivo);
end;

procedure TzRegistratoreVideo.Ferma;
begin
  Terminate;
  FFermata.SetEvent;
end;

function TzRegistratoreVideo.GetStatistiche: TzStatisticheVideo;
begin
  FBlocco.Enter;
  try
    result := FStatistiche;
  finally
    FBlocco.Leave;
  end;
end;

procedure TzRegistratoreVideo.Execute;
begin
  NameThreadForDebugging('zDiagnostica.Video');
  // Un registratore creato e liberato senza Start arriva qui gia' terminato
  // (TThread.Destroy lo fa ripartire per chiuderlo): non deve creare file.
  if Terminated then
    Exit;
  try
    OleCheck(CoInitializeEx(nil, COINIT_MULTITHREADED));
    try
      OleCheck(MFStartup(MF_VERSION, MFSTARTUP_LITE));
      try
        Registra;
      finally
        MFShutdown;
      end;
    finally
      CoUninitialize;
    end;
  except
    on E: Exception do
      FErrore := E.ClassName + ': ' + E.Message;
  end;
end;

procedure TzRegistratoreVideo.Registra;
var
  Intera, Ridotta: TSuperficie;
  Schermo: HDC;
  Scala: Double;
  LarghezzaMonitor, AltezzaMonitor: Integer;
  Scrittore: IMFSinkWriter;
  Flusso: DWORD;
  NumeroParte: Integer;
  FileParte: string;
  Orologio: TStopwatch;
  Intervallo: Integer;
  ProssimoScatto: Int64;
  Adesso, InizioCattura, InizioCodifica, UltimoScrittoMs, Delta: Int64;
  TempoFilmato: Int64;
  Precedente: TBytes;
  Modalita: DWORD;
  PrimoDellaParte, Clic, InPausa: boolean;

  procedure ApriParte;
  var
    Attributi, Parametri: IMFAttributes;
    Uscita, Ingresso: IMFMediaType;
  begin
    Inc(NumeroParte);
    FileParte := Format('%s%s-video-%.2d.mp4', [FCartella, FPrefisso, NumeroParte]);
    if FileExists(FileParte) then
      DeleteFile(FileParte);

    OleCheck(MFCreateAttributes(Attributi, 2));
    OleCheck(Attributi.SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS, 1));
    // Senza questo lo scrittore rallenta chi chiama per tenere il passo del
    // tempo reale: qui i tempi li decide il registratore.
    OleCheck(Attributi.SetUINT32(MF_SINK_WRITER_DISABLE_THROTTLING, 1));
    OleCheck(MFCreateSinkWriterFromURL(PWideChar(FileParte), nil, Attributi, Scrittore));

    OleCheck(MFCreateMediaType(Uscita));
    OleCheck(Uscita.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
    OleCheck(Uscita.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_H264));
    OleCheck(Uscita.SetUINT32(MF_MT_AVG_BITRATE, FBitrate));
    OleCheck(Uscita.SetUINT32(MF_MT_INTERLACE_MODE, MFVideoInterlace_Progressive));
    OleCheck(Uscita.SetUINT64(MF_MT_FRAME_SIZE, CoppiaUInt64(Ridotta.Larghezza, Ridotta.Altezza)));
    OleCheck(Uscita.SetUINT64(MF_MT_FRAME_RATE, CoppiaUInt64(FFotogrammiAlSecondo, 1)));
    OleCheck(Uscita.SetUINT64(MF_MT_PIXEL_ASPECT_RATIO, CoppiaUInt64(1, 1)));
    OleCheck(Scrittore.AddStream(Uscita, Flusso));

    OleCheck(MFCreateMediaType(Ingresso));
    OleCheck(Ingresso.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
    OleCheck(Ingresso.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32));
    OleCheck(Ingresso.SetUINT32(MF_MT_INTERLACE_MODE, MFVideoInterlace_Progressive));
    OleCheck(Ingresso.SetUINT64(MF_MT_FRAME_SIZE, CoppiaUInt64(Ridotta.Larghezza, Ridotta.Altezza)));
    OleCheck(Ingresso.SetUINT64(MF_MT_FRAME_RATE, CoppiaUInt64(FFotogrammiAlSecondo, 1)));
    OleCheck(Ingresso.SetUINT64(MF_MT_PIXEL_ASPECT_RATIO, CoppiaUInt64(1, 1)));
    // Passo positivo = righe dall'alto in basso, come la DIB ad altezza negativa.
    OleCheck(Ingresso.SetUINT32(MF_MT_DEFAULT_STRIDE, Cardinal(Ridotta.Larghezza * 4)));

    Parametri := nil;
    case FModo of
      mcQualita:
        begin
          // Qualita' costante: uno schermo fermo costa quasi niente, una
          // griglia che scorre costa di piu'. Con il bitrate costante il
          // codificatore spenderebbe sempre la stessa quantita'.
          OleCheck(MFCreateAttributes(Parametri, 2));
          OleCheck(Parametri.SetUINT32(CODECAPI_AVEncCommonRateControlMode, eAVEncCommonRateControlMode_Quality));
          OleCheck(Parametri.SetUINT32(CODECAPI_AVEncCommonQuality, FQualita));
        end;
      mcBitrate:
        begin
          OleCheck(MFCreateAttributes(Parametri, 1));
          OleCheck(Parametri.SetUINT32(CODECAPI_AVEncCommonRateControlMode,
            eAVEncCommonRateControlMode_UnconstrainedVBR));
        end;
    end;
    OleCheck(Scrittore.SetInputMediaType(Flusso, Ingresso, Parametri));
    OleCheck(Scrittore.BeginWriting);

    TempoFilmato := 0;
    PrimoDellaParte := True;
    FBlocco.Enter;
    try
      FStatistiche.Parti := FStatistiche.Parti + [FileParte];
    finally
      FBlocco.Leave;
    end;
  end;

  procedure ChiudiParte;
  var
    Coda: Int64;
  begin
    if Scrittore <> nil then
    begin
      // L'ultimo fotogramma scritto deve durare fino alla chiusura, accorciato
      // come un tempo morto: senza, un filmato che finisce su uno schermo fermo
      // perderebbe la coda e durerebbe zero secondi.
      if not PrimoDellaParte then
      begin
        Coda := Min(Int64(FDurataTempoMortoMs), Orologio.ElapsedMilliseconds - UltimoScrittoMs);
        if Coda > 0 then
          OleCheck(Scrittore.SendStreamTick(Flusso, (TempoFilmato + Coda) * UnitaPerMillisecondo));
        FBlocco.Enter;
        try
          Inc(FStatistiche.DurataFilmatoMs, Coda);
        finally
          FBlocco.Leave;
        end;
      end;
      OleCheck(Scrittore.Finalize);
      Scrittore := nil;
    end;
  end;

  procedure ScriviFotogramma(ADurataMs: Int64);
  var
    Campione: IMFSample;
    Memoria: IMFMediaBuffer;
    Destinazione: PByte;
  begin
    OleCheck(MFCreateMemoryBuffer(Ridotta.Dimensione, Memoria));
    OleCheck(Memoria.Lock(Destinazione, nil, nil));
    try
      Move(Ridotta.Bit^, Destinazione^, Ridotta.Dimensione);
    finally
      Memoria.Unlock;
    end;
    OleCheck(Memoria.SetCurrentLength(Ridotta.Dimensione));
    OleCheck(MFCreateSample(Campione));
    OleCheck(Campione.AddBuffer(Memoria));
    OleCheck(Campione.SetSampleTime(TempoFilmato * UnitaPerMillisecondo));
    OleCheck(Campione.SetSampleDuration(ADurataMs * UnitaPerMillisecondo));
    OleCheck(Scrittore.WriteSample(Flusso, Campione));
  end;

  function DimensioneParte: Int64;
  var
    Attributi: TWin32FileAttributeData;
  begin
    result := 0;
    if GetFileAttributesEx(PChar(FileParte), GetFileExInfoStandard, @Attributi) then
      result := Int64(Attributi.nFileSizeHigh) shl 32 + Attributi.nFileSizeLow;
  end;

begin
  LarghezzaMonitor := FMonitor.Width;
  AltezzaMonitor := FMonitor.Height;
  Scala := Min(1.0, FLarghezzaMassima / LarghezzaMonitor);

  // Il codificatore H.264 vuole dimensioni pari.
  Intera.Crea(LarghezzaMonitor, AltezzaMonitor);
  Ridotta.Crea(Round(LarghezzaMonitor * Scala) and not 1, Round(AltezzaMonitor * Scala) and not 1);
  Schermo := GetDC(0);
  try
    FBlocco.Enter;
    try
      FStatistiche.LarghezzaFilmato := Ridotta.Larghezza;
      FStatistiche.AltezzaFilmato := Ridotta.Altezza;
    finally
      FBlocco.Leave;
    end;

    NumeroParte := 0;
    ApriParte;
    try
      Intervallo := 1000 div Max(1, FFotogrammiAlSecondo);
      Orologio := TStopwatch.StartNew;
      ProssimoScatto := 0;
      UltimoScrittoMs := 0;
      SetLength(Precedente, Ridotta.Dimensione);
      InPausa := False;

      while not Terminated do
      begin
        Adesso := Orologio.ElapsedMilliseconds;
        if ProssimoScatto > Adesso then
          if FFermata.WaitFor(Cardinal(ProssimoScatto - Adesso)) = wrSignaled then
            Break;
        Inc(ProssimoScatto, Intervallo);
        // Se la cattura e' rimasta indietro (computer occupato) non si
        // recuperano gli scatti persi: si riparte da adesso.
        if ProssimoScatto < Orologio.ElapsedMilliseconds then
          ProssimoScatto := Orologio.ElapsedMilliseconds + Intervallo;

        if FPausa then
        begin
          InPausa := True;
          Continue;
        end;

        InizioCattura := Orologio.ElapsedMilliseconds;
        Modalita := SRCCOPY;
        if FCatturaFinestreALivelli then
          Modalita := Modalita or CAPTUREBLT;
        BitBlt(Intera.DC, 0, 0, LarghezzaMonitor, AltezzaMonitor, Schermo, FMonitor.Left, FMonitor.Top, Modalita);
        if FProcesso <> 0 then
          MascheraFinestreEstranee(Intera, FMonitor, FProcesso);
        SetStretchBltMode(Ridotta.DC, HALFTONE);
        SetBrushOrgEx(Ridotta.DC, 0, 0, nil);
        StretchBlt(Ridotta.DC, 0, 0, Ridotta.Larghezza, Ridotta.Altezza, Intera.DC, 0, 0, LarghezzaMonitor,
          AltezzaMonitor, SRCCOPY);
        GdiFlush;
        Clic := (GetAsyncKeyState(VK_LBUTTON) < 0) or (GetAsyncKeyState(VK_RBUTTON) < 0);
        Adesso := Orologio.ElapsedMilliseconds;

        FBlocco.Enter;
        try
          Inc(FStatistiche.FotogrammiCatturati);
          Inc(FStatistiche.MillisecondiCatturaTotali, Adesso - InizioCattura);
          FStatistiche.MillisecondiCatturaMassimi := Max(FStatistiche.MillisecondiCatturaMassimi, Adesso - InizioCattura);
          FStatistiche.DurataVeraMs := Adesso;
        finally
          FBlocco.Leave;
        end;

        // Il confronto si fa prima di disegnare puntatore e orologio: cosi' un
        // fotogramma in cui si e' mosso solo il mouse risulta uguale.
        if not PrimoDellaParte and not Clic and not InPausa and (PixelCambiati(PCardinal(Ridotta.Bit),
          PCardinal(Precedente), Ridotta.Larghezza * Ridotta.Altezza, FSogliaPixelCambiati) <= FSogliaPixelCambiati) then
          Continue;
        Move(Ridotta.Bit^, Precedente[0], Ridotta.Dimensione);

        if PrimoDellaParte then
          Delta := 0
        else
        begin
          Delta := Adesso - UltimoScrittoMs;
          // Tempo morto: schermo fermo oltre la soglia, oppure una pausa.
          if InPausa or (Delta > FSogliaTempoMortoMs) then
          begin
            FBlocco.Enter;
            try
              Inc(FStatistiche.TempiMortiAccorciati);
              Inc(FStatistiche.MillisecondiTolti, Delta - FDurataTempoMortoMs);
            finally
              FBlocco.Leave;
            end;
            Delta := FDurataTempoMortoMs;
          end;
        end;
        Inc(TempoFilmato, Delta);
        InPausa := False;

        DisegnaPuntatore(Ridotta, FMonitor, Scala, Clic);
        DisegnaOrologio(Ridotta, Now);
        GdiFlush;

        InizioCodifica := Orologio.ElapsedMilliseconds;
        ScriviFotogramma(Intervallo);
        PrimoDellaParte := False;
        UltimoScrittoMs := Adesso;

        FBlocco.Enter;
        try
          Inc(FStatistiche.FotogrammiScritti);
          Inc(FStatistiche.MillisecondiCodificaTotali, Orologio.ElapsedMilliseconds - InizioCodifica);
          Inc(FStatistiche.DurataFilmatoMs, Delta);
        finally
          FBlocco.Leave;
        end;

        // Parte piena: si chiude e se ne apre un'altra, che riparte da zero.
        if DimensioneParte >= FDimensioneParteByte then
        begin
          ChiudiParte;
          ApriParte;
        end;
      end;
    finally
      ChiudiParte;
    end;
  finally
    ReleaseDC(0, Schermo);
    Ridotta.Libera;
    Intera.Libera;
  end;
end;

end.
