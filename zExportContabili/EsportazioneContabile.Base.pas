// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------

unit EsportazioneContabile.Base;

// Classe base degli esportatori: formattazione dei campi secondo le due
// famiglie di tracciato incontrate nei gestionali italiani.
//
// 1) Tracciati a lunghezza fissa (SDF) - es. Ad Hoc, manuale "Procedure di
//    Import" cap. 1 "Convenzioni sul Formato Dati ASCII":
//    - campi a lunghezza fissa, record chiusi da CR+LF;
//    - numerici allineati a destra, senza zeri di riempimento, virgola come
//      separatore decimale, niente separatore delle migliaia, segno '-'
//      davanti alla prima cifra;
//    - alfanumerici allineati a sinistra, riempiti con spazi a destra;
//    - date in formato AAAAMMGG con zeri di riempimento.
// 2) Tracciati delimitati (CSV) - es. Mexal/Passcom, manuale edupass
//    "Caricamento ASCII (CSV)": separatore configurabile fra ';' ':' ',',
//    file distinti per testate e righe.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  EsportazioneContabile.Types;

type
  TzEsportatoreContabileBase = class(TInterfacedObject, IzEsportatoreContabile)
  private
    FCorrispondenze: IzCorrispondenzeContabili;
  protected
    // --- campi a lunghezza fissa (SDF) ---
    function CampoTestoFisso(const Valore: string; Lunghezza: Integer): string;
    function CampoNumeroFisso(Valore: Currency; Lunghezza, Decimali: Integer): string;
    function CampoDataFissa(Valore: TDate): string;   // AAAAMMGG, vuoto se zero

    // --- campi delimitati (CSV) ---
    function RigaCsv(const Campi: array of string; Separatore: Char): string;
    function CampoNumeroCsv(Valore: Currency; Decimali: Integer): string;

    // I tracciati sono ASCII: scrittura in ANSI, righe chiuse da CR+LF.
    function CreaScrittore(const NomeFileCompleto: string): TStreamWriter;

    function Traduci(Tipo: TzTipoCorrispondenza; const CodiceInterno: string): string;
    function Parametro(const Chiave, ValorePredefinito: string): string;

    property Corrispondenze: IzCorrispondenzeContabili read FCorrispondenze;
  public
    constructor Create(Corrispondenze: IzCorrispondenzeContabili);

    // IzEsportatoreContabile: i discendenti implementano il tracciato.
    function Gestionale: string; virtual; abstract;
    function Descrizione: string; virtual; abstract;
    function EsportaPrimaNota(Movimenti: TObjectList<TzMovimentoContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; virtual; abstract;
    function EsportaAnagrafiche(Anagrafiche: TObjectList<TzAnagraficaContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; virtual; abstract;
  end;

  TzEsportatoreContabileClasse = class of TzEsportatoreContabileBase;

implementation

constructor TzEsportatoreContabileBase.Create(Corrispondenze: IzCorrispondenzeContabili);
begin
  inherited Create;
  if Corrispondenze = nil then
    raise EzEsportazioneContabile.Create('Esportatore creato senza tabella di corrispondenze');
  FCorrispondenze := Corrispondenze;
end;

// --- campi a lunghezza fissa -------------------------------------------------

function TzEsportatoreContabileBase.CampoTestoFisso(const Valore: string;
  Lunghezza: Integer): string;
begin
  // Allineamento a sinistra, spazi a destra; i caratteri in eccesso si
  // troncano (stessa regola della procedura di import di destinazione).
  if Length(Valore) > Lunghezza then
    Result := Copy(Valore, 1, Lunghezza)
  else
    Result := Valore + StringOfChar(' ', Lunghezza - Length(Valore));
end;

function TzEsportatoreContabileBase.CampoNumeroFisso(Valore: Currency;
  Lunghezza, Decimali: Integer): string;
var
  Formato: TFormatSettings;
  Testo: string;
begin
  // Virgola decimale, nessun separatore delle migliaia, allineamento a destra.
  // Il valore zero puo' restare campo vuoto: le convenzioni Ad Hoc lo ammettono
  // e cosi' si evita che finisca in campi carattere come zero spurio.
  if Valore = 0 then
    Exit(StringOfChar(' ', Lunghezza));

  Formato := TFormatSettings.Create;
  Formato.DecimalSeparator := ',';
  Formato.ThousandSeparator := #0;
  Testo := CurrToStrF(Valore, ffFixed, Decimali, Formato);

  if Length(Testo) > Lunghezza then
    raise EzEsportazioneContabile.CreateFmt(
      'Importo %s troppo lungo per un campo di %d caratteri', [Testo, Lunghezza]);
  Result := StringOfChar(' ', Lunghezza - Length(Testo)) + Testo;
end;

function TzEsportatoreContabileBase.CampoDataFissa(Valore: TDate): string;
begin
  if Valore = 0 then
    Result := StringOfChar(' ', 8)
  else
    Result := FormatDateTime('yyyymmdd', Valore);
end;

// --- campi delimitati ----------------------------------------------------------

function TzEsportatoreContabileBase.RigaCsv(const Campi: array of string;
  Separatore: Char): string;
var
  Indice: Integer;
begin
  Result := '';
  for Indice := Low(Campi) to High(Campi) do
  begin
    if Pos(Separatore, Campi[Indice]) > 0 then
      raise EzEsportazioneContabile.CreateFmt(
        'Il valore "%s" contiene il separatore "%s"', [Campi[Indice], Separatore]);
    if Indice > Low(Campi) then
      Result := Result + Separatore;
    Result := Result + Campi[Indice];
  end;
end;

function TzEsportatoreContabileBase.CampoNumeroCsv(Valore: Currency;
  Decimali: Integer): string;
var
  Formato: TFormatSettings;
begin
  Formato := TFormatSettings.Create;
  Formato.DecimalSeparator := ',';
  Formato.ThousandSeparator := #0;
  Result := CurrToStrF(Valore, ffFixed, Decimali, Formato);
end;

// --- servizi -------------------------------------------------------------------

function TzEsportatoreContabileBase.CreaScrittore(
  const NomeFileCompleto: string): TStreamWriter;
begin
  Result := TStreamWriter.Create(NomeFileCompleto, False, TEncoding.ANSI);
  Result.NewLine := #13#10;
end;

function TzEsportatoreContabileBase.Traduci(Tipo: TzTipoCorrispondenza;
  const CodiceInterno: string): string;
begin
  Result := FCorrispondenze.CodiceEsterno(Tipo, CodiceInterno);
end;

function TzEsportatoreContabileBase.Parametro(const Chiave,
  ValorePredefinito: string): string;
begin
  Result := FCorrispondenze.Parametro(Chiave, ValorePredefinito);
end;

end.
