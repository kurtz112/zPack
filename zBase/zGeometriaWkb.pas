// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-14
// ---------------------------------------------------------------------------
unit zGeometriaWkb;

// Lettura delle geometrie in formato WKB (Well Known Binary, il formato
// binario standard OGC delle geometrie), come le salvava TatukGIS nei campi
// WKB_GEOMETRY degli strati GIS su Firebird.
//
// Gestisce punti, linee, poligoni, le loro varianti multiple e le collezioni,
// in entrambi gli ordini dei byte. Le varianti con quota (Z) o misura (M),
// sia nella codifica ISO (1001, 2001, 3001...) sia in quella estesa di PostGIS
// (bit alti e SRID), si leggono scartando le coordinate in piu': sulla mappa
// servono solo X e Y.

interface

uses
  System.SysUtils;

type
  TTipoGeometriaWkb = (tgwSconosciuto, tgwPunto, tgwLinea, tgwPoligono, tgwMultiPunto, tgwMultiLinea, tgwMultiPoligono, tgwCollezione);

  TPuntoWkb = record
    X: Double;
    Y: Double;
  end;

  // Una parte e' una sequenza di punti: il punto singolo, una linea, oppure un
  // anello di un poligono. Esterna distingue il contorno di un poligono dai
  // suoi buchi; per punti e linee e' sempre vera.
  TParteWkb = record
    Punti: TArray<TPuntoWkb>;
    Esterna: Boolean;
  end;

  TGeometriaWkb = record
    Tipo: TTipoGeometriaWkb;
    Parti: TArray<TParteWkb>;
    function NumeroPunti: Integer;
  end;

  EGeometriaWkb = class(Exception);

function LeggiGeometriaWkb(const Dati: TBytes): TGeometriaWkb;

implementation

const
  BitQuotaEstesa = $80000000;
  BitMisuraEstesa = $40000000;
  BitSridEsteso = $20000000;

type
  TLettoreWkb = class
  private
    Dati: TBytes;
    Posizione: Integer;
    OrdineLittleEndian: Boolean;
    Parti: TArray<TParteWkb>;
    procedure Verifica(const Lunghezza: Int64);
    function LeggiByte: Byte;
    function LeggiIntero: Cardinal;
    function LeggiDouble: Double;
    function LeggiPunti(const Quanti: Cardinal; const Dimensioni: Integer): TArray<TPuntoWkb>;
    procedure AggiungiParte(const Punti: TArray<TPuntoWkb>; const Esterna: Boolean);
    function LeggiGeometria: TTipoGeometriaWkb;
  public
    constructor Create(const Origine: TBytes);
  end;

constructor TLettoreWkb.Create(const Origine: TBytes);
begin
  inherited Create;
  Dati := Origine;
  Posizione := 0;
end;

procedure TLettoreWkb.Verifica(const Lunghezza: Int64);
begin
  if Posizione + Lunghezza > Length(Dati) then
    raise EGeometriaWkb.CreateFmt('Geometria WKB troncata: servono %d byte alla posizione %d, il dato ne ha %d', [Lunghezza, Posizione, Length(Dati)]);
end;

function TLettoreWkb.LeggiByte: Byte;
begin
  Verifica(1);
  Result := Dati[Posizione];
  Inc(Posizione);
end;

function TLettoreWkb.LeggiIntero: Cardinal;
var
  Byte0: Cardinal;
  Byte1: Cardinal;
  Byte2: Cardinal;
  Byte3: Cardinal;
begin
  Verifica(4);
  Byte0 := Dati[Posizione];
  Byte1 := Dati[Posizione + 1];
  Byte2 := Dati[Posizione + 2];
  Byte3 := Dati[Posizione + 3];
  Inc(Posizione, 4);

  if OrdineLittleEndian then
    Result := Byte0 or (Byte1 shl 8) or (Byte2 shl 16) or (Byte3 shl 24)
  else
    Result := Byte3 or (Byte2 shl 8) or (Byte1 shl 16) or (Byte0 shl 24);
end;

function TLettoreWkb.LeggiDouble: Double;
var
  Buffer: array [0 .. 7] of Byte;
  Indice: Integer;
begin
  Verifica(8);
  // Il processore e' little endian: i dati big endian si girano
  for Indice := 0 to 7 do
    if OrdineLittleEndian then
      Buffer[Indice] := Dati[Posizione + Indice]
    else
      Buffer[Indice] := Dati[Posizione + 7 - Indice];
  Inc(Posizione, 8);

  Move(Buffer[0], Result, SizeOf(Double));
end;

function TLettoreWkb.LeggiPunti(const Quanti: Cardinal; const Dimensioni: Integer): TArray<TPuntoWkb>;
var
  Indice: Integer;
  Extra: Integer;
begin
  // Controllo prima di allocare: un conteggio corrotto non deve chiedere
  // gigabyte di memoria
  Verifica(Int64(Quanti) * Dimensioni * 8);

  SetLength(Result, Quanti);
  for Indice := 0 to Integer(Quanti) - 1 do
  begin
    Result[Indice].X := LeggiDouble;
    Result[Indice].Y := LeggiDouble;
    for Extra := 3 to Dimensioni do
      LeggiDouble;
  end;
end;

procedure TLettoreWkb.AggiungiParte(const Punti: TArray<TPuntoWkb>; const Esterna: Boolean);
var
  Parte: TParteWkb;
begin
  Parte.Punti := Punti;
  Parte.Esterna := Esterna;
  Parti := Parti + [Parte];
end;

function TLettoreWkb.LeggiGeometria: TTipoGeometriaWkb;
var
  Ordine: Byte;
  CodiceGrezzo: Cardinal;
  Codice: Cardinal;
  Dimensioni: Integer;
  Quanti: Cardinal;
  Anelli: Cardinal;
  Indice: Cardinal;
  Anello: Cardinal;
begin
  Ordine := LeggiByte;
  if Ordine > 1 then
    raise EGeometriaWkb.CreateFmt('Geometria WKB non valida: ordine dei byte %d alla posizione %d', [Ordine, Posizione - 1]);
  OrdineLittleEndian := Ordine = 1;

  CodiceGrezzo := LeggiIntero;

  Dimensioni := 2;
  if (CodiceGrezzo and BitQuotaEstesa) <> 0 then
    Inc(Dimensioni);
  if (CodiceGrezzo and BitMisuraEstesa) <> 0 then
    Inc(Dimensioni);
  if (CodiceGrezzo and BitSridEsteso) <> 0 then
    LeggiIntero;

  Codice := CodiceGrezzo and $0FFFFFFF;
  case Codice div 1000 of
    1, 2:
      Inc(Dimensioni);
    3:
      Inc(Dimensioni, 2);
  end;
  Codice := Codice mod 1000;

  case Codice of
    1:
      begin
        Result := tgwPunto;
        AggiungiParte(LeggiPunti(1, Dimensioni), True);
      end;
    2:
      begin
        Result := tgwLinea;
        Quanti := LeggiIntero;
        AggiungiParte(LeggiPunti(Quanti, Dimensioni), True);
      end;
    3:
      begin
        Result := tgwPoligono;
        Anelli := LeggiIntero;
        for Anello := 1 to Anelli do
        begin
          Quanti := LeggiIntero;
          AggiungiParte(LeggiPunti(Quanti, Dimensioni), Anello = 1);
        end;
      end;
    4, 5, 6, 7:
      begin
        case Codice of
          4:
            Result := tgwMultiPunto;
          5:
            Result := tgwMultiLinea;
          6:
            Result := tgwMultiPoligono;
        else
          Result := tgwCollezione;
        end;

        // Ogni elemento di una geometria multipla e' una geometria WKB
        // completa, con il suo ordine dei byte
        Quanti := LeggiIntero;
        for Indice := 1 to Quanti do
          LeggiGeometria;
      end;
  else
    raise EGeometriaWkb.CreateFmt('Tipo di geometria WKB non gestito: %d', [CodiceGrezzo]);
  end;
end;

function LeggiGeometriaWkb(const Dati: TBytes): TGeometriaWkb;
var
  Lettore: TLettoreWkb;
begin
  Result.Tipo := tgwSconosciuto;
  Result.Parti := nil;

  if Length(Dati) = 0 then
    Exit;

  Lettore := TLettoreWkb.Create(Dati);
  try
    Result.Tipo := Lettore.LeggiGeometria;
    Result.Parti := Lettore.Parti;
  finally
    FreeAndNil(Lettore);
  end;
end;

// TGeometriaWkb

function TGeometriaWkb.NumeroPunti: Integer;
var
  Parte: TParteWkb;
begin
  Result := 0;
  for Parte in Parti do
    Inc(Result, Length(Parte.Punti));
end;

end.
