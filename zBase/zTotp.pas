// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-16
// ---------------------------------------------------------------------------
unit zTotp;

// Strumenti del secondo fattore con app di autenticazione (TOTP, RFC 6238)
// che il database non puo' fare da solo: la casualita' crittografica per il
// segreto e per i codici di recupero, e la codifica base32 del segreto.
// Il calcolo e la verifica dei codici stanno nel database (USR_TOTP_*):
// questa unit non conosce ne' il database ne' l'interfaccia.
//
// Il nome non comincia con "zSecurity.": TzSystem ha un campo zSecurity, e un
// prefisso di unit uguale renderebbe ambigue le espressioni zSecurity.Xxx.

interface

uses
  System.SysUtils;

const
  // 20 byte = 160 bit, la lunghezza dell'impronta SHA1 consigliata dalla RFC 4226
  TotpLunghezzaSegretoByte = 20;
  TotpNumeroCodiciRecupero = 10;
  // 16 caratteri su un alfabeto di 31 simboli: circa 79 bit per codice
  TotpLunghezzaCodiceRecupero = 16;

// Byte presi dalla sorgente casuale del sistema operativo (BCryptGenRandom).
// Solleva un'eccezione se la sorgente non risponde: un segreto debole non va
// mai generato in silenzio al suo posto.
function GeneraByteCasuali(const NumeroByte: integer): TBytes;

// Codifica base32 della RFC 4648 (A-Z, 2-7), senza '=' di riempimento: e' la
// forma che le app di autenticazione si aspettano nel parametro secret.
function Base32Codifica(const Dati: TBytes): string;

// Segreto TOTP nuovo, gia' in base32.
function GeneraSegretoTotp: string;

// Segreto a gruppi di quattro caratteri, per chi lo digita a mano nell'app.
function SegretoAGruppi(const SegretoBase32: string): string;

// Codici di recupero monouso nella forma XXXX-XXXX-XXXX-XXXX. L'alfabeto esclude
// i caratteri che si confondono leggendo un foglio stampato (0/O, 1/I/L).
function GeneraCodiciRecupero(const NumeroCodici: integer = TotpNumeroCodiciRecupero): TArray<string>;

implementation

uses
  Winapi.Windows;

const
  BCRYPT_USE_SYSTEM_PREFERRED_RNG = $00000002;
  AlfabetoBase32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  AlfabetoCodiciRecupero = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

function BCryptGenRandom(Algoritmo: Pointer; Buffer: PByte; LunghezzaBuffer: ULONG; Opzioni: ULONG): LONG; stdcall; external 'bcrypt.dll' name 'BCryptGenRandom';

function GeneraByteCasuali(const NumeroByte: integer): TBytes;
var
  Esito: LONG;
begin
  if NumeroByte <= 0 then
    raise Exception.Create('GeneraByteCasuali: numero di byte non valido.');

  SetLength(result, NumeroByte);

  Esito := BCryptGenRandom(nil, @result[0], NumeroByte, BCRYPT_USE_SYSTEM_PREFERRED_RNG);

  if Esito <> 0 then
    raise Exception.CreateFmt('La sorgente casuale di Windows non ha risposto (BCryptGenRandom, codice %x).', [Cardinal(Esito)]);
end;

function Base32Codifica(const Dati: TBytes): string;
var
  Builder: TStringBuilder;
  Accumulatore: Cardinal;
  BitAccumulati: integer;
  Indice: integer;
begin
  Builder := TStringBuilder.Create;
  try
    Accumulatore := 0;
    BitAccumulati := 0;

    for Indice := 0 to High(Dati) do
    begin
      Accumulatore := ((Accumulatore shl 8) or Dati[Indice]) and $FFFF;
      Inc(BitAccumulati, 8);

      while BitAccumulati >= 5 do
      begin
        Builder.Append(AlfabetoBase32[((Accumulatore shr (BitAccumulati - 5)) and $1F) + 1]);
        Dec(BitAccumulati, 5);
      end;
    end;

    // Bit rimasti: si completano a destra con zeri, come prevede la RFC
    if BitAccumulati > 0 then
      Builder.Append(AlfabetoBase32[((Accumulatore shl (5 - BitAccumulati)) and $1F) + 1]);

    result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function GeneraSegretoTotp: string;
var
  Segreto: TBytes;
begin
  Segreto := GeneraByteCasuali(TotpLunghezzaSegretoByte);
  try
    result := Base32Codifica(Segreto);
  finally
    // Il segreto in chiaro non resta in memoria piu' del necessario
    FillChar(Segreto[0], Length(Segreto), 0);
  end;
end;

function SegretoAGruppi(const SegretoBase32: string): string;
var
  Indice: integer;
begin
  result := '';

  for Indice := 1 to Length(SegretoBase32) do
  begin
    if (Indice > 1) and ((Indice - 1) mod 4 = 0) then
      result := result + ' ';

    result := result + SegretoBase32[Indice];
  end;
end;

function GeneraCodiciRecupero(const NumeroCodici: integer): TArray<string>;
var
  LunghezzaAlfabeto: integer;
  Soglia: integer;
  Casuali: TBytes;
  PosizioneCasuale: integer;
  IndiceCodice: integer;
  Codice: string;

  function CarattereCasuale: Char;
  var
    Valore: integer;
  begin
    // Scarto dei valori oltre il multiplo piu' alto dell'alfabeto: senza, i
    // primi simboli uscirebbero piu' spesso degli altri
    repeat
      if PosizioneCasuale > High(Casuali) then
      begin
        Casuali := GeneraByteCasuali(64);
        PosizioneCasuale := 0;
      end;

      Valore := Casuali[PosizioneCasuale];
      Inc(PosizioneCasuale);
    until Valore < Soglia;

    result := AlfabetoCodiciRecupero[(Valore mod LunghezzaAlfabeto) + 1];
  end;

begin
  LunghezzaAlfabeto := Length(AlfabetoCodiciRecupero);
  Soglia := (256 div LunghezzaAlfabeto) * LunghezzaAlfabeto;
  Casuali := nil;
  PosizioneCasuale := 0;

  SetLength(result, NumeroCodici);

  for IndiceCodice := 0 to NumeroCodici - 1 do
  begin
    Codice := '';

    while Length(Codice) < TotpLunghezzaCodiceRecupero do
      Codice := Codice + CarattereCasuale;

    result[IndiceCodice] := Copy(Codice, 1, 4) + '-' + Copy(Codice, 5, 4) + '-' + Copy(Codice, 9, 4) + '-' + Copy(Codice, 13, 4);
  end;

  if Length(Casuali) > 0 then
    FillChar(Casuali[0], Length(Casuali), 0);
end;

end.
