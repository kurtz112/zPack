// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------
unit zOffice.Grafici.Excel;

// Grafici nei modelli Excel: dopo la costruzione del foglio, ogni cella il cui
// testo e' un riferimento chart://Nome (vedi zOffice.Grafici) lascia il posto
// all'immagine del grafico, ancorata a quella cella. La misura si scrive come
// nei modelli Word, in centimetri: "chart://Andamento @16:10"; con la sola
// larghezza l'altezza segue le proporzioni predefinite, senza misura 16 x 10 cm.
// Un grafico che non risponde lascia nella cella un avviso leggibile, cosi' il
// modello sbagliato si vede invece di sparire in silenzio.

interface

uses
  dxSpreadSheetCore;

// Restituisce quante immagini ha inserito
function InserisciGrafici(SpreadSheet: TdxCustomSpreadSheet): Integer;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  dxGDIPlusClasses,
  dxHashUtils,
  dxSpreadSheetContainers,
  zOffice.Grafici;

const
  LarghezzaPredefinitaCm = 16;
  AltezzaPredefinitaCm = 10;
  // misura del contenitore nel foglio: pixel a 96 punti per pollice
  PuntiPerPollicePagina = 96;

// Misura " @L:A" in centimetri; False se manca o non e' valida
function LeggiMisura(const Testo: string; out Larghezza, Altezza: Single): Boolean;

  function LeggiNumero(const Valore: string; out Numero: Single): Boolean;
  begin
    Result := Single.TryParse(Valore.Trim.Replace(',', '.'), Numero, TFormatSettings.Invariant);
  end;

var
  Coda: string;
  Posizione: Integer;
begin
  Result := False;
  Larghezza := 0;
  Altezza := 0;

  Posizione := Testo.IndexOf('@');
  if Posizione < 0 then
    Exit;

  Coda := Testo.Substring(Posizione + 1).Trim;
  Posizione := Coda.IndexOf(':');

  if Posizione < 0 then
    Result := LeggiNumero(Coda, Larghezza)
  else
    Result := LeggiNumero(Coda.Substring(0, Posizione), Larghezza) and LeggiNumero(Coda.Substring(Posizione + 1), Altezza);

  Result := Result and (Larghezza > 0) and (Altezza >= 0);

  // solo la larghezza: altezza nelle proporzioni dell'immagine predefinita
  if Result and (Altezza = 0) then
    Altezza := Larghezza * TzRegistroGrafici.AltezzaPredefinita / TzRegistroGrafici.LarghezzaPredefinita;
end;

function InserisciNellaCella(Foglio: TdxSpreadSheetTableView; Cella: TdxSpreadSheetCell; const Testo: string): Boolean;
var
  Riferimento: TzRiferimentoGrafico;
  LarghezzaCm, AltezzaCm: Single;
  Flusso: TStream;
  Immagine: TdxSmartImage;
  Contenitore: TdxSpreadSheetPictureContainer;
begin
  Result := False;

  if not TzRiferimentoGrafico.Prova(Testo, Riferimento) then
    Exit;

  if not LeggiMisura(Testo, LarghezzaCm, AltezzaCm) then
  begin
    LarghezzaCm := LarghezzaPredefinitaCm;
    AltezzaCm := AltezzaPredefinitaCm;
  end;

  // l'immagine a 300 punti per pollice resta nitida anche stampata; i pixel
  // scritti nel riferimento (?LxA) valgono solo per l'immagine, non per il riquadro
  if Riferimento.Larghezza = 0 then
  begin
    Riferimento.Larghezza := TzRegistroGrafici.PixelDaCentimetri(LarghezzaCm);
    Riferimento.Altezza := TzRegistroGrafici.PixelDaCentimetri(AltezzaCm);
  end;

  // il foglio di calcolo non disegna l'SVG in tutte le versioni di Excel: PNG
  Flusso := TzRegistroGrafici.Immagine(Riferimento.Nome, fgPng, Riferimento.Larghezza, Riferimento.Altezza);

  if not Assigned(Flusso) then
  begin
    Cella.AsString := Format('[grafico "%s" non disponibile: la form che lo mostra deve essere aperta]', [Riferimento.Nome]);
    Exit;
  end;

  try
    Immagine := TdxSmartImage.Create;
    try
      Immagine.LoadFromStream(Flusso);

      Contenitore := Foglio.Containers.Add(TdxSpreadSheetPictureContainer) as TdxSpreadSheetPictureContainer;
      Contenitore.BeginUpdate;
      try
        // la copia dell'immagine la fa il foglio (archivio delle immagini condivise)
        Contenitore.Picture.Image := Immagine;
        Contenitore.AnchorType := catOneCell;
        Contenitore.AnchorPoint1.Cell := Cella;
        Contenitore.AnchorPoint1.Offset := Point(0, 0);
        Contenitore.AnchorPoint2.Offset := Point(TzRegistroGrafici.PixelDaCentimetri(LarghezzaCm, PuntiPerPollicePagina),
          TzRegistroGrafici.PixelDaCentimetri(AltezzaCm, PuntiPerPollicePagina));
      finally
        Contenitore.EndUpdate;
      end;
    finally
      Immagine.Free;
    end;
  finally
    Flusso.Free;
  end;

  // la cella resta (e' l'ancora dell'immagine), il testo del riferimento no
  Cella.Clear;
  Result := True;
end;

function InserisciGrafici(SpreadSheet: TdxCustomSpreadSheet): Integer;
var
  IndiceFoglio: Integer;
  Foglio: TdxSpreadSheetTableView;
  Area: TRect;
  Riga, Colonna: Integer;
  Cella: TdxSpreadSheetCell;
  Testo: string;
begin
  Result := 0;

  if not Assigned(SpreadSheet) then
    Exit;

  for IndiceFoglio := 0 to SpreadSheet.SheetCount - 1 do
  begin
    if not (SpreadSheet.Sheets[IndiceFoglio] is TdxSpreadSheetTableView) then
      Continue;

    Foglio := TdxSpreadSheetTableView(SpreadSheet.Sheets[IndiceFoglio]);

    // Dimensions va da (0, 0) all'ultima riga e all'ultima colonna usate
    Area := Foglio.Dimensions;

    for Riga := 0 to Area.Bottom do
      for Colonna := 0 to Area.Right do
      begin
        Cella := Foglio.Cells[Riga, Colonna];

        if not Assigned(Cella) or Cella.IsEmpty or Cella.IsFormula then
          Continue;

        Testo := Cella.AsString;

        if not Testo.Trim.StartsWith(TzRegistroGrafici.Schema, True) then
          Continue;

        if InserisciNellaCella(Foglio, Cella, Testo) then
          Inc(Result);
      end;
  end;
end;

end.
