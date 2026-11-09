// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-27
// ---------------------------------------------------------------------------
unit zOffice.Ocr.WindowsMedia;

// Driver OCR basato su Windows.Media.Ocr, il motore incluso nel sistema
// operativo: non c'e' niente da distribuire insieme all'applicazione.
//
// Prerequisiti sulla macchina:
// - Windows 10/11, oppure Windows Server con Desktop Experience e la
// funzionalita' a richiesta "OCR" installata;
// - language pack della lingua richiesta (it-IT);
// - su Windows Server Core NON e' disponibile: si ripiega su Tesseract.
// Se manca qualcosa, Disponibile restituisce False e Riconosci stringa vuota:
// nessuna eccezione esce da questa unit.
//
// NOTA SULLE INTERFACCE WinRT
// La RTL di Delphi non contiene le proiezioni di Windows.Media.Ocr, quindi
// IOcrEngineStatics / IOcrEngine / IOcrResult sono dichiarate qui a mano.
// Su queste interfacce non viene MAI eseguita una QueryInterface: l'oggetto
// arriva sempre come puntatore all'interfaccia predefinita restituito dal
// metodo precedente. Di conseguenza:
// - l'unico IID che conta davvero e' quello di IOcrEngineStatics, usato con
// RoGetActivationFactory (verificato con il programma di prova
// test\TestWinOcr.dpr);
// - gli altri IID sono segnaposto e non vengono usati;
// - conta invece l'ORDINE dei metodi, che deve corrispondere al metadata del
// Windows SDK (vedi il commento su IOcrResult).

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Winapi.WinRT,
  Winapi.CommonTypes,
  Winapi.Foundation,
  Winapi.GraphicsRT,
  Winapi.Globalization,
  Vcl.Graphics,
  zOffice.Ocr.Intf;

type
  TzOcrDriverWindowsMedia = class(TInterfacedObject, IzOcrDriver)
  strict private
    FTimeoutMs: Cardinal;
  public
    constructor Create;

    function Disponibile(const Lingua: string): boolean;
    function Riconosci(const Immagine: TBitmap; const Lingua: string): string;
    function Nome: string;

    // Attesa massima del riconoscimento di una singola immagine.
    property TimeoutMs: Cardinal read FTimeoutMs write FTimeoutMs;
  end;

implementation

uses
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

const
  ClasseOcrEngine = 'Windows.Media.Ocr.OcrEngine';
  TimeoutPredefinitoMs = 120000;
  RPC_E_CHANGED_MODE = HRESULT($80010106);

type
  IOcrResult = interface;
  IAsyncOperation_1__IOcrResult = interface;
  IOcrEngine = interface;

  // Windows.Media.Ocr.OcrResult
  // Ordine dei metodi come nel metadata: Lines, TextAngle, Text.
  // E' l'unica assunzione non verificabile da codice: se cambiasse, la lettura
  // del testo chiamerebbe il metodo sbagliato. Va confermata con il programma
  // di prova prima di attivare questo driver in produzione.
  IOcrResult = interface(IInspectable)
    ['{7C0F2B4E-1D6A-4F3B-9E27-5A81C4D0E611}']
    function get_Lines(out value: IInspectable): HRESULT; stdcall;
    function get_TextAngle(out value: IInspectable): HRESULT; stdcall;
    function get_Text(out value: HSTRING): HRESULT; stdcall;
  end;

  // Windows.Foundation.IAsyncOperation`1<Windows.Media.Ocr.OcrResult>
  IAsyncOperation_1__IOcrResult = interface(IInspectable)
    ['{3F1B6D22-70C9-4E58-8D33-2C4A9F5B7E08}']
    function put_Completed(handler: IUnknown): HRESULT; stdcall;
    function get_Completed(out handler: IUnknown): HRESULT; stdcall;
    function GetResults(out value: IOcrResult): HRESULT; stdcall;
  end;

  // Windows.Media.Ocr.OcrEngine
  IOcrEngine = interface(IInspectable)
    ['{8A5D0E93-52B1-4C77-B0A6-1E9D3F62C4A5}']
    function RecognizeAsync(bitmap: Imaging_ISoftwareBitmap; out value: IAsyncOperation_1__IOcrResult): HRESULT; stdcall;
    function get_RecognizerLanguage(out value: ILanguage): HRESULT; stdcall;
  end;

  // Membri statici di Windows.Media.Ocr.OcrEngine.
  // Questo IID e' reale: serve a RoGetActivationFactory.
  IOcrEngineStatics = interface(IInspectable)
    ['{5BFFA85A-3384-3540-9940-699120D428A8}']
    function get_MaxImageDimension(out value: Cardinal): HRESULT; stdcall;
    function get_AvailableRecognizerLanguages(out value: IInspectable): HRESULT; stdcall;
    function IsLanguageSupported(language: ILanguage; out value: Byte): HRESULT; stdcall;
    function TryCreateFromLanguage(language: ILanguage; out value: IOcrEngine): HRESULT; stdcall;
    function TryCreateFromUserProfileLanguages(out value: IOcrEngine): HRESULT; stdcall;
  end;

  // robuffer.h: accesso ai byte grezzi di un IBuffer. IID reale e stabile.
  IBufferByteAccess = interface(IUnknown)
    ['{905A0FEF-BC53-11DF-8C49-001E4FC686DA}']
    function Buffer(out value: PByte): HRESULT; stdcall;
  end;

  // Implementazione locale di IBuffer: evita di dover attivare la classe
  // Windows.Storage.Streams.Buffer (e quindi di conoscerne l'IID di fabbrica).
  // WinRT accetta un IBuffer fornito dal chiamante purche' esponga anche
  // IBufferByteAccess, che e' il modo in cui SoftwareBitmap legge i pixel.
  TzWinRTBuffer = class(TInterfacedObject, IBuffer, IBufferByteAccess)
  strict private
    FDati: TBytes;
    FLunghezza: Cardinal;
  protected
    // IInspectable
    function GetIids(out iidCount: Cardinal; out iids: PGUID): HRESULT; stdcall;
    function GetRuntimeClassName(out className: HSTRING): HRESULT; stdcall;
    function GetTrustLevel(out trust: TrustLevel): HRESULT; stdcall;
    // IBuffer
    function get_Capacity: Cardinal; safecall;
    function get_Length: Cardinal; safecall;
    procedure put_Length(value: Cardinal); safecall;
    // IBufferByteAccess
    function Buffer(out value: PByte): HRESULT; stdcall;
  public
    constructor Create(const Dimensione: Integer);
    function Primo: PByte;
  end;

  { TzWinRTBuffer }

constructor TzWinRTBuffer.Create(const Dimensione: Integer);
begin
  inherited Create;

  SetLength(FDati, Dimensione);
  FLunghezza := Dimensione;
end;

function TzWinRTBuffer.Primo: PByte;
begin
  if Length(FDati) = 0 then
    result := nil
  else
    result := @FDati[0];
end;

function TzWinRTBuffer.GetIids(out iidCount: Cardinal; out iids: PGUID): HRESULT;
begin
  iidCount := 0;
  iids := nil;
  result := E_NOTIMPL;
end;

function TzWinRTBuffer.GetRuntimeClassName(out className: HSTRING): HRESULT;
begin
  className := 0;
  result := E_NOTIMPL;
end;

function TzWinRTBuffer.GetTrustLevel(out trust: TrustLevel): HRESULT;
begin
  trust := BaseTrust;
  result := S_OK;
end;

function TzWinRTBuffer.get_Capacity: Cardinal;
begin
  result := Length(FDati);
end;

function TzWinRTBuffer.get_Length: Cardinal;
begin
  result := FLunghezza;
end;

procedure TzWinRTBuffer.put_Length(value: Cardinal);
begin
  if value <= Cardinal(Length(FDati)) then
    FLunghezza := value;
end;

function TzWinRTBuffer.Buffer(out value: PByte): HRESULT;
begin
  value := Primo;
  result := S_OK;
end;

// ---------------------------------------------------------------------------
// Funzioni di appoggio WinRT
// ---------------------------------------------------------------------------

// Inizializza WinRT sul thread corrente. In una applicazione VCL il thread
// principale e' gia' inizializzato come STA: RoInitialize risponde
// RPC_E_CHANGED_MODE e va bene comunque, WinRT funziona anche in STA.
function InizializzaWinRT: boolean;
var
  hr: HRESULT;
begin
  hr := RoInitialize(RO_INIT_MULTITHREADED);
  result := Succeeded(hr) or (hr = RPC_E_CHANGED_MODE);
  // Nessuna RoUninitialize: chiudere l'apartment mentre sono ancora vive
  // interfacce WinRT provoca violazioni di accesso in uscita.
end;

function CreaHString(const Testo: string; out Stringa: HSTRING): boolean;
begin
  Stringa := 0;
  result := Succeeded(WindowsCreateString(PWideChar(Testo), Length(Testo), Stringa));
end;

function HStringToString(const Stringa: HSTRING): string;
var
  Lunghezza: Cardinal;
  Testo: PWideChar;
begin
  result := '';

  if Stringa = 0 then
    Exit;

  Lunghezza := 0;
  Testo := WindowsGetStringRawBuffer(Stringa, @Lunghezza);

  if (Testo <> nil) and (Lunghezza > 0) then
    SetString(result, Testo, Lunghezza);
end;

function OttieniStatics(out Statics: IOcrEngineStatics): boolean;
var
  Classe: HSTRING;
  Fabbrica: IInspectable;
begin
  result := False;
  Statics := nil;

  if not CreaHString(ClasseOcrEngine, Classe) then
    Exit;

  try
    if not Succeeded(RoGetActivationFactory(Classe, IOcrEngineStatics, Fabbrica)) then
      Exit;

    if Fabbrica = nil then
      Exit;

    // La fabbrica e' gia' stata restituita come IOcrEngineStatics (l'IID e'
    // stato passato a RoGetActivationFactory): nessuna QueryInterface.
    Statics := IOcrEngineStatics(Pointer(Fabbrica));
    result := True;
  finally
    WindowsDeleteString(Classe);
  end;
end;

function CreaLingua(const Lingua: string): ILanguage;
var
  Etichetta: HSTRING;
begin
  result := nil;

  if not CreaHString(Lingua, Etichetta) then
    Exit;

  try
    try
      result := TLanguage.CreateLanguage(Etichetta);
    except
      on e: Exception do
      begin
        siMain.LogVerbose('Lingua non riconosciuta da WinRT: ' + Lingua + ' (' + e.Message + ')');
        result := nil;
      end;
    end;
  finally
    WindowsDeleteString(Etichetta);
  end;
end;

// Attende la fine di una operazione asincrona WinRT interrogando IAsyncInfo
// (IID standard: nessuna interfaccia dichiarata a mano e' coinvolta).
function AttendiCompletamento(const Operazione: IInterface; const TimeoutMs: Cardinal): boolean;
var
  Info: IAsyncInfo;
  Scadenza: UInt64;
begin
  result := False;

  if not Supports(Operazione, IAsyncInfo, Info) then
    Exit;

  Scadenza := GetTickCount64 + TimeoutMs;

  while Info.Status = AsyncStatus.Started do
  begin
    if GetTickCount64 > Scadenza then
    begin
      Info.Cancel;
      siMain.LogWarning('Windows.Media.Ocr: timeout di riconoscimento');
      Exit;
    end;

    Sleep(10);
  end;

  result := Info.Status = AsyncStatus.Completed;
end;

// Copia il TBitmap in un SoftwareBitmap Bgra8. Il canale alfa viene forzato a
// opaco: le pagine PDF rese via GDI+ possono arrivare con alfa a zero, che il
// motore OCR interpreterebbe come immagine vuota.
function CreaSoftwareBitmap(const Immagine: TBitmap): Imaging_ISoftwareBitmap;
var
  Buffer: TzWinRTBuffer;
  Contenitore: IBuffer;
  Destinazione: PByte;
  Riga: PByte;
  ByteRiga: Integer;
  x, y: Integer;
begin
  result := nil;

  Immagine.PixelFormat := pf32bit;
  ByteRiga := Immagine.Width * 4;

  Buffer := TzWinRTBuffer.Create(ByteRiga * Immagine.Height);
  Contenitore := Buffer;

  Destinazione := Buffer.Primo;
  if Destinazione = nil then
    Exit;

  for y := 0 to Immagine.Height - 1 do
  begin
    Riga := Immagine.ScanLine[y];
    Move(Riga^, Destinazione^, ByteRiga);

    for x := 0 to Immagine.Width - 1 do
      Destinazione[x * 4 + 3] := 255;

    Inc(Destinazione, ByteRiga);
  end;

  result := TImaging_SoftwareBitmap.CreateCopyFromBuffer(Contenitore, Imaging_BitmapPixelFormat.Bgra8, Immagine.Width, Immagine.Height, Imaging_BitmapAlphaMode.Premultiplied);
end;

{ TzOcrDriverWindowsMedia }

constructor TzOcrDriverWindowsMedia.Create;
begin
  inherited Create;

  FTimeoutMs := TimeoutPredefinitoMs;
end;

function TzOcrDriverWindowsMedia.Nome: string;
begin
  result := 'Windows.Media.Ocr';
end;

function TzOcrDriverWindowsMedia.Disponibile(const Lingua: string): boolean;
var
  Statics: IOcrEngineStatics;
  Idioma: ILanguage;
  Engine: IOcrEngine;
begin
  result := False;

  try
    if not InizializzaWinRT then
      Exit;

    if not OttieniStatics(Statics) then
      Exit;

    Idioma := CreaLingua(Lingua);
    if Idioma = nil then
      Exit;

    // Prova definitiva: il motore per quella lingua e' creabile solo se la
    // capability OCR e il language pack sono installati.
    result := Succeeded(Statics.TryCreateFromLanguage(Idioma, Engine)) and (Engine <> nil);
  except
    on e: Exception do
    begin
      siMain.LogVerbose('Windows.Media.Ocr non disponibile: ' + e.Message);
      result := False;
    end;
  end;
end;

function TzOcrDriverWindowsMedia.Riconosci(const Immagine: TBitmap; const Lingua: string): string;
var
  Statics: IOcrEngineStatics;
  Idioma: ILanguage;
  Engine: IOcrEngine;
  bitmap: Imaging_ISoftwareBitmap;
  Operazione: IAsyncOperation_1__IOcrResult;
  Esito: IOcrResult;
  Testo: HSTRING;
  DimensioneMassima: Cardinal;
begin
  result := '';

  if (Immagine = nil) or (Immagine.Width = 0) or (Immagine.Height = 0) then
    Exit;

  try
    if not InizializzaWinRT then
      Exit;

    if not OttieniStatics(Statics) then
      Exit;

    Idioma := CreaLingua(Lingua);
    if Idioma = nil then
      Exit;

    if not Succeeded(Statics.TryCreateFromLanguage(Idioma, Engine)) or (Engine = nil) then
      Exit;

    DimensioneMassima := 0;
    Statics.get_MaxImageDimension(DimensioneMassima);

    if (DimensioneMassima > 0) and ((Cardinal(Immagine.Width) > DimensioneMassima) or (Cardinal(Immagine.Height) > DimensioneMassima)) then
    begin
      siMain.LogWarning(Format('Windows.Media.Ocr: immagine %dx%d oltre il limite di %d px', [Immagine.Width, Immagine.Height, DimensioneMassima]));
      Exit;
    end;

    bitmap := CreaSoftwareBitmap(Immagine);
    if bitmap = nil then
      Exit;

    if not Succeeded(Engine.RecognizeAsync(bitmap, Operazione)) or (Operazione = nil) then
      Exit;

    if not AttendiCompletamento(Operazione, FTimeoutMs) then
      Exit;

    if not Succeeded(Operazione.GetResults(Esito)) or (Esito = nil) then
      Exit;

    Testo := 0;
    if not Succeeded(Esito.get_Text(Testo)) then
      Exit;

    try
      result := HStringToString(Testo).Trim;
    finally
      WindowsDeleteString(Testo);
    end;
  except
    on e: Exception do
    begin
      siMain.LogException(e);
      result := '';
    end;
  end;
end;

end.
