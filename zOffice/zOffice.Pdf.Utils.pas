unit zOffice.Pdf.Utils;

// Modifica del 2026-07-27: eliminate le dipendenze dalla libreria Envision
// (EnPdfGr, EnPngGr, EnOcrEng, EnConsoleOcr, EnImgScr), che servivano solo alla
// funzione ExtractTextFromPDF.
// ExtractTextFromPDF e' stata rimossa da questa unit: era un doppione mai
// richiamato (l'unico chiamante, Files.Lib di Gesty, ne aveva una copia propria)
// ed e' ora in zOffice.Ocr, che rende le pagine con il motore PDF DevExpress e
// puo' usare tesseract.exe oppure il motore OCR incluso in Windows.
//   testo del PDF + OCR ->  TzOcr.EstraiTestoDaPdf(NomeFile)
//   solo testo          ->  TzOcr.EstraiTestoLayerPdf(NomeFile)
//   solo OCR            ->  TzOcr.RiconosciPdf(NomeFile)
//
// Resta qui la sola FindOversizedPdfPage, che non ha bisogno di nulla nella
// sezione interface: la vecchia lista di uses (Vcl.Dialogs, Vcl.Graphics,
// Vcl.Controls, Vcl.Forms, Data.DB, zFbDataSet, SmartInspect) serviva alle
// funzioni ora spostate e obbligava chiunque includesse questa unit a
// trascinarsi dietro VCL e livello dati.

interface

// Oltre questa soglia (in pollici, su ciascun lato) una pagina PDF viene considerata anomala:
// nessun formato di stampa reale la supera; e' tipicamente il sintomo di un file generato male,
// dove il MediaBox e' stato impostato 1:1 con i pixel di un'immagine incorporata ad alta
// risoluzione (es. una scansione) invece di essere calcolato in base ai DPI di scansione.
// Caricare una pagina simile nel PDF Viewer DevExpress puo' far fallire GdipCreateBitmap con
// "Invalid operation in GDI+ (Code: 2; InvalidParameter)" per esaurimento risorse GDI+/memoria
// (vedi Mantis Gesty #26).
const
  MaxSanePdfPageSizeInches = 60;

  // Analizza (senza renderizzare) le dimensioni di ogni pagina del PDF e restituisce True se ne
  // trova una fuori scala. Non modifica/rasterizza il documento: usa solo la struttura del file,
  // quindi e' sicura da chiamare anche su file di grandi dimensioni prima di passarli a un viewer.
function FindOversizedPdfPage(const AFileName: string; out APageIndex: Integer; out AWidthIn, AHeightIn: Double; const AMaxSizeInches: Double = MaxSanePdfPageSizeInches): Boolean;

implementation

uses
  System.SysUtils,

  dxPDFDocument,

  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

function FindOversizedPdfPage(const AFileName: string; out APageIndex: Integer; out AWidthIn, AHeightIn: Double; const AMaxSizeInches: Double = MaxSanePdfPageSizeInches): Boolean;
var
  Pdf: TdxPDFDocument;
  i: Integer;
  WidthIn, HeightIn: Double;
begin
  siMain.EnterMethod('FindOversizedPdfPage');
  siMain.LogString('FileName', AFileName);

  Result := False;
  APageIndex := -1;
  AWidthIn := 0;
  AHeightIn := 0;

  Pdf := TdxPDFDocument.Create;
  try
    Pdf.LoadFromFile(AFileName);

    for i := 0 to Pdf.PageCount - 1 do
    begin
      // Size e' espresso in "user unit" (1/72 di pollice, salvo diversa indicazione nel PDF stesso).
      WidthIn := Pdf.PageInfo[i].Size.X / 72;
      HeightIn := Pdf.PageInfo[i].Size.Y / 72;

      if (WidthIn > AMaxSizeInches) or (HeightIn > AMaxSizeInches) then
      begin
        Result := True;
        APageIndex := i;
        AWidthIn := WidthIn;
        AHeightIn := HeightIn;

        siMain.LogString('Pagina anomala', Format('Indice=%d Larghezza=%.1f" Altezza=%.1f"', [i, WidthIn, HeightIn]));

        Break;
      end;
    end;
  finally
    FreeAndNil(Pdf);
  end;

  siMain.LeaveMethod('FindOversizedPdfPage');
end;

end.
