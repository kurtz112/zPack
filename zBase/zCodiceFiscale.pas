unit zCodiceFiscale;

interface

function CodiceFiscaleValido(const CodiceFiscale: string; const Estero: boolean = false): boolean;
function PartitaIvaValida(const PartitaIVA: string; const Estero: boolean = false): boolean;
function PartitaIvaEstera(const PartitaIVA: string): boolean;
function StatoEstero(const SiglaStato: string): boolean;

function CalcolaCodiceFiscale(const Cognome, Nome: string; const Sesso: string; const DataNascita: TDateTime; const CodiceComune: string): string;

function EstraiDataNascitaDaCodiceFiscale(const CodiceFiscale: string): TDateTime;
function EstraiBelfioreNascitaDaCodiceFiscale(const CodiceFiscale: string): string;
function EstraiSessoDaCodiceFiscale(const CodiceFiscale: string): string;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  System.StrUtils;

type
  TSetCaratteri = set of Char;

const
  InsiemeConsonanti: TSetCaratteri = ['A' .. 'Z'] - ['A', 'E', 'I', 'O', 'U'];
  InsiemeVocali: TSetCaratteri = ['A', 'E', 'I', 'O', 'U'];

const
  CodiciMesi: string = 'ABCDEHLMPRST';
  CodiciControllo: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  CodiciOmocodia: string = 'LMNPQRSTUV';

function ValoreCarPosPari(C: Char): Integer;
begin
  Result := -1;
  case C of
    '0':
      Result := 0;
    '1':
      Result := 1;
    '2':
      Result := 2;
    '3':
      Result := 3;
    '4':
      Result := 4;
    '5':
      Result := 5;
    '6':
      Result := 6;
    '7':
      Result := 7;
    '8':
      Result := 8;
    '9':
      Result := 9;
    'A':
      Result := 0;
    'B':
      Result := 1;
    'C':
      Result := 2;
    'D':
      Result := 3;
    'E':
      Result := 4;
    'F':
      Result := 5;
    'G':
      Result := 6;
    'H':
      Result := 7;
    'I':
      Result := 8;
    'J':
      Result := 9;
    'K':
      Result := 10;
    'L':
      Result := 11;
    'M':
      Result := 12;
    'N':
      Result := 13;
    'O':
      Result := 14;
    'P':
      Result := 15;
    'Q':
      Result := 16;
    'R':
      Result := 17;
    'S':
      Result := 18;
    'T':
      Result := 19;
    'U':
      Result := 20;
    'V':
      Result := 21;
    'W':
      Result := 22;
    'X':
      Result := 23;
    'Y':
      Result := 24;
    'Z':
      Result := 25;
  end;
end;

function ValoreCarPosDispari(C: Char): Integer;
begin
  Result := -1;
  case C of
    '0':
      Result := 1;
    '1':
      Result := 0;
    '2':
      Result := 5;
    '3':
      Result := 7;
    '4':
      Result := 9;
    '5':
      Result := 13;
    '6':
      Result := 15;
    '7':
      Result := 17;
    '8':
      Result := 19;
    '9':
      Result := 21;
    'A':
      Result := 1;
    'B':
      Result := 0;
    'C':
      Result := 5;
    'D':
      Result := 7;
    'E':
      Result := 9;
    'F':
      Result := 13;
    'G':
      Result := 15;
    'H':
      Result := 17;
    'I':
      Result := 19;
    'J':
      Result := 21;
    'K':
      Result := 2;
    'L':
      Result := 4;
    'M':
      Result := 18;
    'N':
      Result := 20;
    'O':
      Result := 11;
    'P':
      Result := 3;
    'Q':
      Result := 6;
    'R':
      Result := 8;
    'S':
      Result := 12;
    'T':
      Result := 14;
    'U':
      Result := 16;
    'V':
      Result := 10;
    'W':
      Result := 22;
    'X':
      Result := 25;
    'Y':
      Result := 24;
    'Z':
      Result := 23;
  end;
end;

function FiltraStringa(S: string; SetCar: TSetCaratteri): string;
var
  I: Integer;
  T: string;
begin
  T := '';
  for I := 1 to Length(S) do
  begin
    if S[I] in SetCar then
      T := T + S[I];
  end;
  Result := T;
end;

function CalcolaCodiceControllo(CodiceFiscale: string): Char;
var
  I, crc: Integer;
begin
  Result := #0;

  crc := 0;

  for I := 1 to Length(CodiceFiscale) do
  begin
    if Odd(I) then
      Inc(crc, ValoreCarPosDispari(CodiceFiscale[I]))
    else
      Inc(crc, ValoreCarPosPari(CodiceFiscale[I]))
  end;

  crc := crc mod 26;

  if (crc >= 0) and (crc < CodiciControllo.Length) then
    Result := CodiciControllo[crc + 1];
end;

// Codici omocodici: per distinguere due persone con lo stesso codice l'Agenzia
// delle Entrate sostituisce le cifre con lettere (L=0, M=1 ... V=9), partendo
// da destra, nelle sole posizioni numeriche: anno (7-8), giorno (10-11) e
// numero del comune (13-15). Prima di leggere data, sesso e comune le lettere
// vanno riportate alle cifre; il carattere di controllo resta quello calcolato
// sul codice con le lettere.
function NormalizzaOmocodia(const CodiceFiscale: string): string;
const
  PosizioniNumeriche: array [0 .. 6] of Integer = (7, 8, 10, 11, 13, 14, 15);
var
  Posizione: Integer;
  Indice: Integer;
begin
  Result := UpperCase(CodiceFiscale);

  for Posizione in PosizioniNumeriche do
    if Posizione <= Length(Result) then
    begin
      Indice := Pos(Result[Posizione], CodiciOmocodia);

      if Indice > 0 then
        Result[Posizione] := Char(Ord('0') + Indice - 1);
    end;
end;

//
// ------ Interfaccia
//

function CalcolaCodiceFiscale(const Cognome, Nome: string; const Sesso: string; const DataNascita: TDateTime; const CodiceComune: string): string;
var
  tmpCognome: string;
  tmpNome: string;

  ConsonantiCognome: string;
  ConsonantiNome: string;
  VocaliCognome: string;
  VocaliNome: string;
  CodiceCognome: string;
  CodiceNome: string;
  CodiceAnno: string;
  CodiceMese: string;
  CodiceGiorno: string;
  Giorno, Mese, Anno: Word;
begin
  Result := '';

  if (Sesso = '') or (Cognome = '') or (Nome = '') then
    Exit;

  DecodeDate(DataNascita, Anno, Mese, Giorno);
  if SameText(Sesso, 'F') then
    Giorno := Giorno + 40;

  tmpCognome := FiltraStringa(UpperCase(Trim(Cognome)), ['A' .. 'Z']);
  tmpNome := FiltraStringa(UpperCase(Trim(Nome)), ['A' .. 'Z']);

  ConsonantiCognome := FiltraStringa(tmpCognome, InsiemeConsonanti);
  ConsonantiNome := FiltraStringa(tmpNome, InsiemeConsonanti);

  VocaliCognome := FiltraStringa(tmpCognome, InsiemeVocali);
  VocaliNome := FiltraStringa(tmpNome, InsiemeVocali);

  CodiceCognome := Copy(ConsonantiCognome + VocaliCognome + 'XX', 1, 3);
  // Il nome segue una regola sua: con quattro o piu' consonanti si prendono la
  // prima, la terza e la quarta (Francesco -> FNC, Gianfranco -> GFR); con
  // meno consonanti vale la stessa regola del cognome
  if Length(ConsonantiNome) >= 4 then
    CodiceNome := ConsonantiNome[1] + ConsonantiNome[3] + ConsonantiNome[4]
  else
    CodiceNome := Copy(ConsonantiNome + VocaliNome + 'XX', 1, 3);

  CodiceAnno := Format('%.2d', [Anno mod 100]);
  CodiceMese := CodiciMesi[Mese];
  CodiceGiorno := Format('%.2d', [Giorno]);

  Result := CodiceCognome + CodiceNome + CodiceAnno + CodiceMese + CodiceGiorno + CodiceComune;
  Result := Result + CalcolaCodiceControllo(Result);
  if not CodiceFiscaleValido(Result) then
    Result := '';
end;

function CodiceFiscaleValido(const CodiceFiscale: string; const Estero: boolean = false): boolean;
begin
  if CodiceFiscale = '' then
    Exit(false)
  else
    if Estero then
      Exit(True)
    else
      // senza il controllo di lunghezza un testo piu' lungo o piu' corto passava
      // quando il suo ultimo carattere coincideva per caso col controllo dei precedenti
      Result := (Length(CodiceFiscale) = 16) and
        SameText(CalcolaCodiceControllo(Copy(CodiceFiscale, 1, Length(CodiceFiscale) - 1)), CodiceFiscale[Length(CodiceFiscale)]);
end;

function PartitaIvaEstera(const PartitaIVA: string): boolean;
var
  S: string;
const
  PaesiEuropei: TArray<string> = ['AT', 'BE', 'BG', 'HR', 'CZ', 'CY', 'DK', 'EE', 'FI', 'FR', 'DE', 'EL', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES',
    'SE', 'GB'];
begin
  Result := false;

  // AT=Austria
  // BE=Belgio
  // BG=Bulgaria
  // HR=Croazia
  // CZ=Repubblica Ceca
  // CY=Cipro
  // DK=Danimarca
  // EE=Estonia
  // FI=Finlandia
  // FR=Francia
  // DE=Germania
  // EL=Grecia
  // HU=Ungheria
  // IE=Irlanda
  // IT=Italia
  // LV=Lettonia
  // LT=Lituania
  // LU=Luxembourg
  // MT=Malta
  // NL=Paesi Bassi
  // PL=Polonia
  // PT=Portogallo
  // RO=Romania
  // SK=Slovacchia
  // SI=Slovenia
  // ES=Spagna
  // SE=Svezia
  // GB=Regno Unito

  S := PartitaIVA.Substring(0, 2).ToUpper.Trim;

  if S.Equals('IT') then
    Exit
  else
    Result := System.StrUtils.AnsiMatchText(S, PaesiEuropei);
end;

function PartitaIvaValida(const PartitaIVA: string; const Estero: boolean = false): boolean;
var
  I: Integer;
  Somma: Integer;
  Cifre: array [1 .. 11] of Integer;
  K: Integer;
  S: string;
begin
  Result := false;

  if Estero then
    Exit(True);

  S := PartitaIVA;

  if PartitaIvaEstera(S) then
  begin
    Result := True;
    Exit;
  end;

  S := S.Replace('IT', '').Trim;

  if Length(S) <> 11 then
    Exit;

  for I := 1 to Length(S) do
    if not(S[I] in ['0' .. '9']) then
      Exit;

  for I := 1 to 11 do
  begin
    Cifre[I] := Ord(S[I]) - Ord('0');
  end;

  Somma := Cifre[1] + Cifre[3] + Cifre[5] + Cifre[7] + Cifre[9];

  I := 2;
  while (I <= 10) do
  begin
    K := 2 * Cifre[I];
    if K > 9 then
      K := K - 9;
    Somma := Somma + K;
    Inc(I, 2);
  end;

  Result := ((10 - Somma mod 10) mod 10) = Cifre[11];
end;

function EstraiDataNascitaDaCodiceFiscale(const CodiceFiscale: string): TDateTime;
var
  strGiorno, strMese, strAnno: string;
  Giorno, Mese, Anno, yy: Integer;
  Data: TDateTime;
  Normalizzato: string;
var
  I: Integer;
begin
  Result := 0;
  if not CodiceFiscaleValido(CodiceFiscale) then
    Exit;

  Normalizzato := NormalizzaOmocodia(CodiceFiscale);

  strAnno := System.Copy(Normalizzato, 7, 2);
  strMese := System.Copy(Normalizzato, 9, 1);
  strGiorno := System.Copy(Normalizzato, 10, 2);

  // Anno
  if not TryStrToInt(strAnno, yy) then
    Exit;


  Anno := 1900 + yy;
  // vedi ZZ_CODICE_FISCALE_ESTRAI_DATI di Gesty. Con '<' chi e' nato
  // nell'anno in corso veniva datato cento anni prima
  if YearOf(Date) - (1900 + yy) >= 90 then
    if (2000 + yy) <= YearOf(Date) then
      Anno := 2000 + yy;

  // Mese
  Mese := 0;
  for I := 1 to 12 do
    if SameText(strMese, CodiciMesi[I]) then
    begin
      Mese := I;
      Break;
    end;

  if Mese = 0 then // se non 'ha trovato
    Exit;
  // Giorno
  if not TryStrToInt(strGiorno, Giorno) then
    Exit;

  if Giorno > 40 then
    Giorno := Giorno - 40;
  // Result
  if TryEncodeDate(Anno, Mese, Giorno, Data) then
    Result := Data;
end;

function EstraiBelfioreNascitaDaCodiceFiscale(const CodiceFiscale: string): string;
begin
  Result := '';

  if CodiceFiscaleValido(CodiceFiscale) then
    Result := System.Copy(NormalizzaOmocodia(CodiceFiscale), 12, 4);
end;

function EstraiSessoDaCodiceFiscale(const CodiceFiscale: string): string;
var
  I: Integer;
begin
  Result := '';

  if not CodiceFiscaleValido(CodiceFiscale) then
    Exit;
  if TryStrToInt(System.Copy(NormalizzaOmocodia(CodiceFiscale), 10, 1), I) then
  begin
    if I >= 4 then
      Result := 'F'
    else
      Result := 'M';
  end;
end;

function StatoEstero(const SiglaStato: string): boolean;
begin
  Result := false;

  if SiglaStato.Trim.IsEmpty then
    Exit
  else
    if SiglaStato.Trim.ToUpper = 'ITA' then
      Exit
    else
      Result := True;
end;

end.
