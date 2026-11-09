// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-27
// ---------------------------------------------------------------------------
unit zOffice.Ocr.Tesseract;

// Driver OCR che richiama direttamente l'eseguibile tesseract.exe.
// Sostituisce l'uso di Envision (EnOcrEng + EnConsoleOcr.TTesseractOcrDriver),
// che faceva esattamente la stessa cosa: salvava l'immagine in un file
// temporaneo, lanciava tesseract.exe e rileggeva il .txt prodotto.
//
// Rispetto al driver Envision:
// - stessa riga di comando ("<exe>" "<immagine>" "<base output>" -l <lingua> --psm <n>)
// - stessa variabile d'ambiente TESSDATA_PREFIX (richiesta da Tesseract 4/5),
// qui pero' impostata e poi ripristinata al valore precedente
// - stessa lettura del file di uscita come UTF-8
// - in piu': finestra della console nascosta e timeout sull'attesa.
//
// Requisito di installazione (identico a prima): tesseract.exe e la cartella
// tessdata con il file della lingua (ita.traineddata).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IOUtils,
  Winapi.Windows,
  Vcl.Imaging.pngimage,
  Vcl.Graphics,
  zOffice.Ocr.Intf;

type
  TzOcrDriverTesseract = class(TInterfacedObject, IzOcrDriver)
  strict private
    FCartella: string;
    FSegmentazione: string;
    FTimeoutMs: Cardinal;
    function Eseguibile: string;
    function CartellaDatiLingua(const Lingua: string): string;
  public
    // CartellaTesseract vuota: ricerca automatica (vedi Eseguibile).
    constructor Create(const CartellaTesseract: string = '');

    function Disponibile(const Lingua: string): boolean;
    function Riconosci(const Immagine: TBitmap; const Lingua: string): string;
    function Nome: string;

    // Valore --psm di Tesseract. 3 = pagina intera, segmentazione automatica.
    property Segmentazione: string read FSegmentazione write FSegmentazione;
    // Attesa massima per il riconoscimento di una singola immagine.
    property TimeoutMs: Cardinal read FTimeoutMs write FTimeoutMs;
  end;

  // Converte un codice lingua BCP-47 ('it', 'it-IT') nel codice a 3 lettere usato
  // da Tesseract ('ita'). Un codice gia' a 3 lettere viene lasciato invariato.
function CodiceLinguaTesseract(const Lingua: string): string;

implementation

uses
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

const
  CartellaPredefinita = 'Tesseract-OCR';
  TimeoutPredefinitoMs = 120000;

function CodiceLinguaTesseract(const Lingua: string): string;
var
  Codice: string;
begin
  Codice := Trim(LowerCase(Lingua));

  if Codice = '' then
    Exit('ita');

  // 'it-IT' -> 'it'
  if Pos('-', Codice) > 0 then
    Codice := Copy(Codice, 1, Pos('-', Codice) - 1);

  if Length(Codice) >= 3 then
    Exit(Codice);

  if Codice = 'it' then
    result := 'ita'
  else
    if Codice = 'en' then
      result := 'eng'
    else
      if Codice = 'fr' then
        result := 'fra'
      else
        if Codice = 'de' then
          result := 'deu'
        else
          if Codice = 'es' then
            result := 'spa'
          else
            if Codice = 'pt' then
              result := 'por'
            else
              result := Codice;
end;

// Esegue una riga di comando senza mostrare la finestra della console e
// attende la fine del processo (o il timeout, nel qual caso lo termina).
function EseguiNascosto(const RigaComando: string; const TimeoutMs: Cardinal; out CodiceUscita: Cardinal): boolean;
var
  InfoAvvio: TStartupInfo;
  InfoProcesso: TProcessInformation;
  Comando: string;
  Esito: Cardinal;
begin
  result := False;
  CodiceUscita := Cardinal(-1);

  // CreateProcess puo' scrivere nel buffer della riga di comando: serve una
  // copia con conteggio riferimenti pari a 1.
  Comando := RigaComando;
  UniqueString(Comando);

  FillChar(InfoAvvio, SizeOf(InfoAvvio), 0);
  InfoAvvio.cb := SizeOf(InfoAvvio);
  InfoAvvio.dwFlags := STARTF_USESHOWWINDOW;
  InfoAvvio.wShowWindow := SW_HIDE;

  if not CreateProcess(nil, PChar(Comando), nil, nil, False, CREATE_NO_WINDOW, nil, nil, InfoAvvio, InfoProcesso) then
    Exit;

  try
    Esito := WaitForSingleObject(InfoProcesso.hProcess, TimeoutMs);

    if Esito = WAIT_TIMEOUT then
    begin
      TerminateProcess(InfoProcesso.hProcess, 1);
      Exit;
    end;

    if Esito <> WAIT_OBJECT_0 then
      Exit;

    result := GetExitCodeProcess(InfoProcesso.hProcess, CodiceUscita);
  finally
    CloseHandle(InfoProcesso.hThread);
    CloseHandle(InfoProcesso.hProcess);
  end;
end;

// Salva l'immagine in PNG a 24 bit. La copia a 24 bit su fondo bianco evita che
// un canale alfa azzerato (tipico delle pagine PDF rese via GDI+) renda il PNG
// completamente trasparente e quindi illeggibile per Tesseract.
procedure SalvaPng(const Immagine: TBitmap; const NomeFile: string);
var
  Copia: TBitmap;
  Png: TPngImage;
begin
  Copia := TBitmap.Create;
  try
    Copia.PixelFormat := pf24bit;
    Copia.SetSize(Immagine.Width, Immagine.Height);
    Copia.Canvas.Brush.Color := clWhite;
    Copia.Canvas.FillRect(Rect(0, 0, Copia.Width, Copia.Height));
    Copia.Canvas.Draw(0, 0, Immagine);

    Png := TPngImage.Create;
    try
      Png.Assign(Copia);
      Png.SaveToFile(NomeFile);
    finally
      FreeAndNil(Png);
    end;
  finally
    FreeAndNil(Copia);
  end;
end;

// Cancellazione senza conseguenze: un temporaneo che non si riesce a togliere
// non e' un motivo per far fallire l'operazione in corso.
procedure EliminaSeEsiste(const NomeFile: string);
begin
  try
    if (NomeFile <> '') and TFile.Exists(NomeFile) then
      TFile.Delete(NomeFile);
  except
    on e: Exception do
      siMain.LogVerbose('Temporaneo OCR non eliminato: ' + NomeFile + ' (' + e.Message + ')');
  end;
end;

{ TzOcrDriverTesseract }

constructor TzOcrDriverTesseract.Create(const CartellaTesseract: string = '');
begin
  inherited Create;

  FCartella := CartellaTesseract;
  FSegmentazione := '3';
  FTimeoutMs := TimeoutPredefinitoMs;
end;

function TzOcrDriverTesseract.Nome: string;
begin
  result := 'Tesseract';
end;

// Ordine di ricerca dell'eseguibile:
// 1. cartella indicata alla costruzione (configurazione dell'applicazione)
// 2. sottocartella Tesseract-OCR dell'applicazione (installazione xcopy)
// 3. %ProgramFiles%\Tesseract-OCR
// 4. %ProgramFiles(x86)%\Tesseract-OCR  (percorso usato da Envision)
// 5. tesseract.exe raggiungibile dal PATH
function TzOcrDriverTesseract.Eseguibile: string;
var
  Trovato: string;
  Buffer: array [0 .. MAX_PATH] of Char;
  ParteFile: PChar;
begin
  result := '';

  if (FCartella <> '') and TFile.Exists(TPath.Combine(FCartella, 'tesseract.exe')) then
    Exit(TPath.Combine(FCartella, 'tesseract.exe'));

  Trovato := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), CartellaPredefinita), 'tesseract.exe');
  if TFile.Exists(Trovato) then
    Exit(Trovato);

  Trovato := TPath.Combine(TPath.Combine(System.SysUtils.GetEnvironmentVariable('ProgramFiles'), CartellaPredefinita), 'tesseract.exe');
  if TFile.Exists(Trovato) then
    Exit(Trovato);

  Trovato := TPath.Combine(TPath.Combine(System.SysUtils.GetEnvironmentVariable('ProgramFiles(x86)'), CartellaPredefinita), 'tesseract.exe');
  if TFile.Exists(Trovato) then
    Exit(Trovato);

  ParteFile := nil;
  if SearchPath(nil, 'tesseract.exe', nil, Length(Buffer), Buffer, ParteFile) > 0 then
    result := Buffer;
end;

// Cartella che contiene i file .traineddata: quella indicata da TESSDATA_PREFIX
// se valorizzata, altrimenti la sottocartella tessdata dell'eseguibile.
function TzOcrDriverTesseract.CartellaDatiLingua(const Lingua: string): string;
var
  Exe: string;
  Prefisso: string;
begin
  result := '';

  Exe := Eseguibile;
  if Exe = '' then
    Exit;

  Prefisso := System.SysUtils.GetEnvironmentVariable('TESSDATA_PREFIX');
  if (Prefisso <> '') and TFile.Exists(TPath.Combine(Prefisso, CodiceLinguaTesseract(Lingua) + '.traineddata')) then
    Exit(Prefisso);

  result := TPath.Combine(ExtractFilePath(Exe), 'tessdata');
end;

function TzOcrDriverTesseract.Disponibile(const Lingua: string): boolean;
var
  Dati: string;
begin
  result := Eseguibile <> '';

  if result then
  begin
    Dati := CartellaDatiLingua(Lingua);
    result := (Dati <> '') and TFile.Exists(TPath.Combine(Dati, CodiceLinguaTesseract(Lingua) + '.traineddata'));
  end;
end;

function TzOcrDriverTesseract.Riconosci(const Immagine: TBitmap; const Lingua: string): string;
var
  FileImmagine: string;
  BaseUscita: string;
  FileTesto: string;
  RigaComando: string;
  PrefissoPrecedente: string;
  CodiceUscita: Cardinal;
begin
  result := '';

  if (Immagine = nil) or (Immagine.Width = 0) or (Immagine.Height = 0) then
    Exit;

  // Da qui in poi nessuna eccezione esce dal metodo: un OCR che non riesce vale
  // "nessun testo", non un errore per chi ha chiesto di allegare il documento.
  try
    if not Disponibile(Lingua) then
    begin
      siMain.LogVerbose('Tesseract non disponibile (eseguibile o file lingua mancanti)');
      Exit;
    end;

    FileImmagine := TPath.Combine(TPath.GetTempPath, 'zocr_' + TPath.GetGUIDFileName(False) + '.png');
    BaseUscita := TPath.Combine(TPath.GetTempPath, 'zocr_' + TPath.GetGUIDFileName(False));
    FileTesto := BaseUscita + '.txt';

    PrefissoPrecedente := System.SysUtils.GetEnvironmentVariable('TESSDATA_PREFIX');
    try
      SalvaPng(Immagine, FileImmagine);

      SetEnvironmentVariable('TESSDATA_PREFIX', PChar(CartellaDatiLingua(Lingua)));

      RigaComando := Format('"%s" "%s" "%s" -l %s --psm %s', [Eseguibile, FileImmagine, BaseUscita, CodiceLinguaTesseract(Lingua), FSegmentazione]);

      if not EseguiNascosto(RigaComando, FTimeoutMs, CodiceUscita) then
      begin
        siMain.LogWarning('Esecuzione di Tesseract fallita: ' + RigaComando);
        Exit;
      end;

      if CodiceUscita <> 0 then
      begin
        siMain.LogWarning(Format('Tesseract terminato con codice %d: %s', [CodiceUscita, RigaComando]));
        Exit;
      end;

      if not TFile.Exists(FileTesto) then
      begin
        siMain.LogWarning('Tesseract non ha prodotto il file di uscita: ' + FileTesto);
        Exit;
      end;

      result := TFile.ReadAllText(FileTesto, TEncoding.UTF8).Trim;
    finally
      SetEnvironmentVariable('TESSDATA_PREFIX', PChar(PrefissoPrecedente));

      // La pulizia dei temporanei non deve mai far fallire il riconoscimento:
      // il file puo' essere ancora agganciato dall'antivirus.
      EliminaSeEsiste(FileImmagine);
      EliminaSeEsiste(FileTesto);
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
