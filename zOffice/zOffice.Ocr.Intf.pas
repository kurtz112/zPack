// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-27
// ---------------------------------------------------------------------------
unit zOffice.Ocr.Intf;

// Astrazione del motore OCR: permette di scegliere il driver (tesseract.exe
// oppure Windows.Media.Ocr) senza toccare il codice chiamante.
// L'acquisizione dell'immagine (rendering della pagina PDF a bitmap) resta
// esterna: il driver riceve gia' un TBitmap.

interface

uses
  Vcl.Graphics;

type
  IzOcrDriver = interface
    ['{2C7B9E14-4A55-49B1-8E3A-9D6F0B1C7A22}']
    // True se il motore e' effettivamente utilizzabile su questa macchina
    // (tesseract.exe + file della lingua presenti, oppure capability OCR di
    // Windows + language pack installati).
    function Disponibile(const Lingua: string): boolean;
    // Riconosce il testo dell'immagine. Lingua in formato BCP-47 ('it', 'it-IT')
    // o codice Tesseract ('ita'): ogni driver converte nel formato che gli serve.
    // Non solleva eccezioni: in caso di errore restituisce stringa vuota.
    function Riconosci(const Immagine: TBitmap; const Lingua: string): string;
    // Nome del driver, per log e diagnostica.
    function Nome: string;
  end;

implementation

end.
