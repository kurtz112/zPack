// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Video.Sblocco
//
// Codice di sblocco del filmato della registrazione per l'assistenza
// (zDiagnostica.Log). Il filmato parte solo se l'assistenza lo sa: zBuilder
// genera un codice di 8 cifre, l'assistenza lo manda al cliente insieme alle
// istruzioni, e l'utente lo scrive nella finestra delle opzioni quando fa la
// prova. Nessun numero da comunicare prima: il codice si controlla da solo.
//
//   Codice = Base (4 cifre casuali, 1000-9999) + Controllo (4 cifre)
//   Controllo = ((Base x P) mod M) mod 10000
//
// Si scrive 1234-5678; il trattino e gli spazi sono facoltativi.
//
// PERCHE' DUE PRIMI
// Le ultime 4 cifre di Base x P dipendono solo dalle ultime 4 cifre di P:
// con una sola moltiplicazione, chi vede un codice ricava quelle cifre e si
// calcola da solo tutti gli altri. Il resto della divisione per M rimescola
// le cifre e toglie questa scorciatoia.
//
// FINO A QUANDO VALE
// Un codice vale sempre e su qualunque postazione: si puo' mandare in
// anticipo, e il cliente fa la prova quando puo'. Nessun limite di
// tentativi. Una volta accettato, il filmato resta sbloccato fino alla
// chiusura dell'applicazione.
//
// QUANTO PROTEGGE
// La formula sta nell'eseguibile: chi la ricava puo' generarsi i codici. Lo
// scopo e' che il filmato non parta all'insaputa dell'assistenza, non
// resistere a un attacco.
//
// P e M stanno solo in zDiagnostica.Video.Chiavi, condivisa con zBuilder
// che genera i codici: non vanno ripetuti in documenti, ticket o note.
//
// Unit autonoma: solo RTL e zDiagnostica.Video.Chiavi.
//
// ***************************************************************************

unit zDiagnostica.Video.Sblocco;

interface

type
  TzSbloccoVideo = class
  private
    FCodice: string;
    FSbloccato: boolean;
  public
    // True se il codice e' valido; da quel momento il filmato e' sbloccato
    // e Codice riporta il codice accettato (1234-5678).
    function Verifica(const ACodice: string): boolean;

    // Controllo del codice senza stato. ANormalizzato e' il codice nella
    // forma 1234-5678, vuoto se il codice non ha 8 cifre.
    class function CodiceValido(const ACodice: string; out ANormalizzato: string): boolean; static;

    // True quando il codice non va chiesto: applicazione sotto il debugger.
    class function CodiceNonRichiesto: boolean; static;

    property Codice: string read FCodice;
    property Sbloccato: boolean read FSbloccato;
  end;

implementation

uses
  System.SysUtils,
  zDiagnostica.Video.Chiavi;

{$WARN SYMBOL_PLATFORM OFF} // DebugHook: le due applicazioni sono solo Windows

// I due primi stanno in zDiagnostica.Video.Chiavi, condivisa con zBuilder
function ControlloPerBase(ABase: Integer): Integer;
begin
  result := Integer(((Int64(ABase) * SbloccoVideoMoltiplicatore) mod SbloccoVideoModulo) mod 10000);
end;

// TzSbloccoVideo

class function TzSbloccoVideo.CodiceNonRichiesto: boolean;
begin
  result := DebugHook <> 0;
end;

class function TzSbloccoVideo.CodiceValido(const ACodice: string; out ANormalizzato: string): boolean;
var
  Cifre: string;
  Carattere: Char;
  Base, Controllo: Integer;
begin
  ANormalizzato := '';
  // Trattino, spazi e punti li mette chi copia il codice da una mail: si
  // tengono solo le cifre, qualunque altro segno rende il codice non valido.
  Cifre := '';
  for Carattere in ACodice do
    if CharInSet(Carattere, ['0'..'9']) then
      Cifre := Cifre + Carattere
    else if not CharInSet(Carattere, ['-', ' ', '.', #9]) then
      Exit(False);
  if Length(Cifre) <> 8 then
    Exit(False);

  Base := StrToInt(Copy(Cifre, 1, 4));
  Controllo := StrToInt(Copy(Cifre, 5, 4));
  result := (Base >= 1000) and (Controllo = ControlloPerBase(Base));
  if result then
    ANormalizzato := Copy(Cifre, 1, 4) + '-' + Copy(Cifre, 5, 4);
end;

function TzSbloccoVideo.Verifica(const ACodice: string): boolean;
var
  Normalizzato: string;
begin
  if FSbloccato then
    Exit(True);
  result := CodiceValido(ACodice, Normalizzato);
  if result then
  begin
    FCodice := Normalizzato;
    FSbloccato := True;
  end;
end;

end.
