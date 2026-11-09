// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-14
// ---------------------------------------------------------------------------
unit zCoordinateGeografiche;

// Conversione fra coordinate geografiche WGS84 (latitudine e longitudine in
// gradi) e coordinate piane UTM WGS84 (est e nord in metri), emisfero nord.
//
// Sostituisce le conversioni che prima si facevano con TatukGIS
// (EPSG 4326 <-> EPSG 32632). Usa le serie di Krueger al quarto ordine in n
// (coefficienti di Karney, 2011), la stessa impostazione delle librerie
// geodetiche correnti, e ricava la latitudine per iterazione esatta: dentro il
// fuso l'errore resta sotto il decimo di millimetro, molto al di sotto della
// precisione dei dati catastali e delle mappe su cui si disegnano. Collaudo in
// D:\AI\SandBox\ProvaSostituzioneTatukGis.

interface

type
  TCoordinataGeografica = record
    Latitudine: Double;
    Longitudine: Double;
  end;

  TCoordinataUtm = record
    Est: Double;
    Nord: Double;
  end;

  TEstensioneUtm = record
    EstMinimo: Double;
    NordMinimo: Double;
    EstMassimo: Double;
    NordMassimo: Double;
    function Vuota: Boolean;
  end;

const
  // Fuso UTM dell'Italia nord-occidentale e centrale, quello in cui sono
  // salvati gli strati GIS dei database di WinTarif (EPSG 32632)
  FusoUtmPredefinito = 32;

function UtmDaGeografica(const Latitudine, Longitudine: Double; const Fuso: Integer = FusoUtmPredefinito): TCoordinataUtm;
function GeograficaDaUtm(const Est, Nord: Double; const Fuso: Integer = FusoUtmPredefinito): TCoordinataGeografica;

implementation

uses
  System.Math;

const
  // Ellissoide WGS84
  SemiasseMaggiore = 6378137.0;
  Schiacciamento = 1 / 298.257223563;

  // Proiezione UTM
  FattoreScala = 0.9996;
  FalsoEst = 500000.0;

var
  // Coefficienti delle serie, calcolati una volta sola all'avvio
  RaggioRettificante: Double;
  Alfa: array [1 .. 4] of Double;
  Beta: array [1 .. 4] of Double;
  Delta: array [1 .. 3] of Double;
  CoefficienteEccentricita: Double;

procedure CalcolaCoefficienti;
var
  N: Double;
  N2: Double;
  N3: Double;
  N4: Double;
begin
  N := Schiacciamento / (2 - Schiacciamento);
  N2 := N * N;
  N3 := N2 * N;
  N4 := N3 * N;

  RaggioRettificante := SemiasseMaggiore / (1 + N) * (1 + N2 / 4 + N4 / 64);

  // Serie diretta e inversa al quarto ordine in N (Karney, 2011)
  Alfa[1] := N / 2 - 2 / 3 * N2 + 5 / 16 * N3 + 41 / 180 * N4;
  Alfa[2] := 13 / 48 * N2 - 3 / 5 * N3 + 557 / 1440 * N4;
  Alfa[3] := 61 / 240 * N3 - 103 / 140 * N4;
  Alfa[4] := 49561 / 161280 * N4;

  Beta[1] := N / 2 - 2 / 3 * N2 + 37 / 96 * N3 - 1 / 360 * N4;
  Beta[2] := 1 / 48 * N2 + 1 / 15 * N3 - 437 / 1440 * N4;
  Beta[3] := 17 / 480 * N3 - 37 / 840 * N4;
  Beta[4] := 4397 / 161280 * N4;

  Delta[1] := 2 * N - 2 / 3 * N2 - 2 * N3;
  Delta[2] := 7 / 3 * N2 - 8 / 5 * N3;
  Delta[3] := 56 / 15 * N3;

  CoefficienteEccentricita := 2 * Sqrt(N) / (1 + N);
end;

function MeridianoCentrale(const Fuso: Integer): Double;
var
  Gradi: Double;
begin
  // In radianti: il fuso 32 e' centrato su 9 gradi est. Il passaggio da una
  // variabile Double serve: con un argomento intero DegToRad sceglie la
  // versione Single e sposta tutto di due centimetri verso ovest
  Gradi := Fuso * 6 - 183;
  Result := DegToRad(Gradi);
end;

function LatitudineDaConforme(const Chi: Double; const Partenza: Double): Double;
var
  Eccentricita: Double;
  TangenteConforme: Double;
  Precedente: Double;
  SenoFi: Double;
  Passo: Integer;
begin
  // tan(pi/4 + Chi/2) = tan(pi/4 + Fi/2) * ((1 - e sin Fi) / (1 + e sin Fi))^(e/2),
  // risolta per Fi con la sostituzione successiva
  Eccentricita := Sqrt(Schiacciamento * (2 - Schiacciamento));
  TangenteConforme := Tan(Pi / 4 + Chi / 2);

  Result := Partenza;
  for Passo := 1 to 20 do
  begin
    Precedente := Result;
    SenoFi := Sin(Result);
    Result := 2 * ArcTan(TangenteConforme * Power((1 + Eccentricita * SenoFi) / (1 - Eccentricita * SenoFi), Eccentricita / 2)) - Pi / 2;
    if Abs(Result - Precedente) < 1E-15 then
      Break;
  end;
end;

function UtmDaGeografica(const Latitudine, Longitudine: Double; const Fuso: Integer): TCoordinataUtm;
var
  Fi: Double;
  DeltaLambda: Double;
  T: Double;
  XiPrimo: Double;
  EtaPrimo: Double;
  SommaEst: Double;
  SommaNord: Double;
  J: Integer;
begin
  Fi := DegToRad(Latitudine);
  DeltaLambda := DegToRad(Longitudine) - MeridianoCentrale(Fuso);

  // Latitudine conforme espressa come tangente
  T := Sinh(ArcTanh(Sin(Fi)) - CoefficienteEccentricita * ArcTanh(CoefficienteEccentricita * Sin(Fi)));

  XiPrimo := ArcTan2(T, Cos(DeltaLambda));
  EtaPrimo := ArcTanh(Sin(DeltaLambda) / Sqrt(1 + T * T));

  SommaEst := EtaPrimo;
  SommaNord := XiPrimo;
  for J := 1 to 4 do
  begin
    SommaEst := SommaEst + Alfa[J] * Cos(2 * J * XiPrimo) * Sinh(2 * J * EtaPrimo);
    SommaNord := SommaNord + Alfa[J] * Sin(2 * J * XiPrimo) * Cosh(2 * J * EtaPrimo);
  end;

  Result.Est := FalsoEst + FattoreScala * RaggioRettificante * SommaEst;
  Result.Nord := FattoreScala * RaggioRettificante * SommaNord;
end;

function GeograficaDaUtm(const Est, Nord: Double; const Fuso: Integer): TCoordinataGeografica;
var
  Xi: Double;
  Eta: Double;
  XiPrimo: Double;
  EtaPrimo: Double;
  Chi: Double;
  Fi: Double;
  J: Integer;
begin
  Xi := Nord / (FattoreScala * RaggioRettificante);
  Eta := (Est - FalsoEst) / (FattoreScala * RaggioRettificante);

  XiPrimo := Xi;
  EtaPrimo := Eta;
  for J := 1 to 4 do
  begin
    XiPrimo := XiPrimo - Beta[J] * Sin(2 * J * Xi) * Cosh(2 * J * Eta);
    EtaPrimo := EtaPrimo - Beta[J] * Cos(2 * J * Xi) * Sinh(2 * J * Eta);
  end;

  // Latitudine conforme, poi la latitudine geodetica: la serie inversa dà il
  // punto di partenza, l'iterazione sulla formula esatta toglie l'errore di
  // troncamento della serie (mezzo millimetro), in due o tre passi
  Chi := ArcSin(Sin(XiPrimo) / Cosh(EtaPrimo));
  Fi := Chi;
  for J := 1 to 3 do
    Fi := Fi + Delta[J] * Sin(2 * J * Chi);

  Result.Latitudine := RadToDeg(LatitudineDaConforme(Chi, Fi));
  Result.Longitudine := RadToDeg(MeridianoCentrale(Fuso) + ArcTan2(Sinh(EtaPrimo), Cos(XiPrimo)));
end;

// TEstensioneUtm

function TEstensioneUtm.Vuota: Boolean;
begin
  Result := (EstMassimo <= EstMinimo) or (NordMassimo <= NordMinimo);
end;

initialization

CalcolaCoefficienti;

end.
