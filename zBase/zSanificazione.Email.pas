// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-07
// ---------------------------------------------------------------------------
unit zSanificazione.Email;

// Sanificazione e validazione degli indirizzi e-mail.
//
// La regola di validita' e' la regular expression di riferimento, la stessa
// implementata lato database dalla funzione ZZ_EMAIL_VALIDA (01_funzioni_email.sql):
// i due livelli devono dare lo stesso esito sullo stesso valore.
//
// Traduzione da sintassi JavaScript a PCRE (motore di System.RegularExpressions):
//   - \uXXXX  ->  \x{XXXX}   (PCRE non riconosce \u se non con opzioni speciali)
//   - $       ->  \z         (in PCRE $ accetta anche un a-capo finale, \z no)
// Il lookahead (?=...) e i lookbehind (?<!...) sono supportati da PCRE e restano
// identici all'originale.
//
// Unit riusabile: nessuna dipendenza da unit applicative (WT.Globals, ConfigModule,
// dmCommon). L'aggancio all'interfaccia (OnValidate degli editor, BeforePost dei
// dataset) sta nel livello zPack/applicazione, vedi documento di analisi.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Character,
  System.RegularExpressions;

type
  TEsitoEmail = (eeValida, eeVuota, eeNonValida);

  TEsitoSanificazioneEmail = record
    Originale: string;
    Normalizzato: string;
    Esito: TEsitoEmail;
    // Motivo leggibile per l'utente quando Esito = eeNonValida
    Motivo: string;
    function Valida: boolean;
  end;

  TzSanificazioneEmail = class
  public const
    // Regex di riferimento tradotta in PCRE. L'apostrofo e' raddoppiato per la sintassi Delphi.
    RegexEmail =
      '^[a-zA-Z\x{00A0}-\x{D7FF}\x{E000}-\x{FFFF}0-9.!#$%&''*+\-\/=?^_`{|}~]+@' +
      '(?=[a-z0-9A-Z\x{00A0}-\x{D7FF}\x{E000}-\x{FFFF}])' +
      '(?:[a-z0-9A-Z\x{00A0}-\x{D7FF}\x{E000}-\x{FFFF}]|(?<![.-])\.|(?<!\.)-)*' +
      '[a-z0-9A-Z\x{00A0}-\x{D7FF}\x{E000}-\x{FFFF}]\z';
  public
    // Normalizzazione conservativa, idempotente, identica a ZZ_EMAIL_NORMALIZZA:
    //  - elimina caratteri di controllo e caratteri di formato invisibili
    //    (soft hyphen, zero width, BOM, controlli bidirezionali)
    //  - riconduce gli spazi Unicode (NBSP compreso) allo spazio ASCII, cosi' il
    //    Trim li toglie ai bordi e la regex li rifiuta all'interno
    //  - toglie il prefisso "mailto:"
    //  - da "Nome Cognome <indirizzo>" tiene solo l'indirizzo
    //  - toglie virgolette e parentesi angolari ai bordi e la punteggiatura finale (. , ;)
    //  - minuscolo
    // Non corregge spazi interni, virgole al posto del punto, @ mancante o doppia:
    // sono anomalie da segnalare, non da indovinare. Restituisce '' se vuoto.
    class function Normalizza(const Indirizzo: string): string;

    // True se l'indirizzo (gia' normalizzato o meno: qui non si normalizza) rispetta
    // la regex di riferimento. RichiediPuntoNelDominio esclude "nome@localhost",
    // che la regex di riferimento accetterebbe: consigliato True per PEC e invii reali.
    class function Valido(const Indirizzo: string; RichiediPuntoNelDominio: boolean = False): boolean;

    // Normalizza e valida, restituendo anche il motivo dell'eventuale scarto.
    class function Sanifica(const Indirizzo: string; RichiediPuntoNelDominio: boolean = False): TEsitoSanificazioneEmail;

    // Elenchi di indirizzi separati da ; oppure , (es. CONFIG.EMAIL_GESTIONE_ATTREZZATURE_CC).
    // Ogni elemento viene normalizzato; gli elementi vuoti vengono scartati.
    class function EstraiIndirizzi(const Elenco: string): TArray<string>;

    // Restituisce l'elenco dei soli indirizzi validi, separati da "; ", e in NonValidi
    // quelli scartati (normalizzati), per mostrarli all'utente.
    class function SanificaElenco(const Elenco: string; out NonValidi: TArray<string>;
      RichiediPuntoNelDominio: boolean = False): string;
  end;

implementation

{ TEsitoSanificazioneEmail }

function TEsitoSanificazioneEmail.Valida: boolean;
begin
  Result := Esito = eeValida;
end;

{ TzSanificazioneEmail }

class function TzSanificazioneEmail.Normalizza(const Indirizzo: string): string;
var
  Carattere: Char;
  Costruttore: TStringBuilder;
  PosizioneApertura: integer;
  PosizioneChiusura: integer;
begin
  Costruttore := TStringBuilder.Create(Length(Indirizzo));
  try
    for Carattere in Indirizzo do
    begin
      // caratteri di controllo (C0, DEL, C1) e caratteri di formato invisibili: eliminati
      if Carattere.IsControl or (Carattere.GetUnicodeCategory = TUnicodeCategory.ucFormat) then
        Continue;

      // spazi Unicode (U+00A0, U+2000..U+200A, U+3000, ...) ricondotti allo spazio ASCII
      if Carattere.IsWhiteSpace then
        Costruttore.Append(' ')
      else
        Costruttore.Append(Carattere);
    end;
    Result := Costruttore.ToString;
  finally
    Costruttore.Free;
  end;

  Result := Result.Trim;

  // prefisso "mailto:" copiato da un collegamento
  if Result.StartsWith('mailto:', True) then
    Result := Result.Substring(7).Trim;

  // forma "Nome Cognome <indirizzo>": si tiene solo cio' che sta fra le ultime parentesi angolari
  PosizioneApertura := Result.LastIndexOf('<');
  PosizioneChiusura := Result.LastIndexOf('>');
  if (PosizioneApertura >= 0) and (PosizioneChiusura > PosizioneApertura) then
    Result := Result.Substring(PosizioneApertura + 1, PosizioneChiusura - PosizioneApertura - 1).Trim;

  // virgolette e parentesi angolari residue ai bordi
  Result := Result.Trim(['"', '''', '<', '>']);

  // punteggiatura di chiusura lasciata dall'utente ("nome@dominio.it." oppure "nome@dominio.it;")
  Result := Result.TrimRight(['.', ',', ';']);

  Result := Result.Trim.ToLower;
end;

class function TzSanificazioneEmail.Valido(const Indirizzo: string; RichiediPuntoNelDominio: boolean): boolean;
var
  PosizioneChiocciola: integer;
begin
  // TRegEx.IsMatch statico: compila il pattern a ogni chiamata (qualche decina di
  // microsecondi). Per bonifiche massive creare un TRegEx locale al ciclo; un'istanza
  // condivisa fra thread non e' sicura perche' TPerlRegEx conserva lo stato del match.
  Result := (Indirizzo <> '') and TRegEx.IsMatch(Indirizzo, RegexEmail);

  if Result and RichiediPuntoNelDominio then
  begin
    // la regex garantisce una sola @: cio' che segue e' il dominio
    PosizioneChiocciola := Indirizzo.LastIndexOf('@');
    Result := Indirizzo.IndexOf('.', PosizioneChiocciola + 1) >= 0;
  end;
end;

class function TzSanificazioneEmail.Sanifica(const Indirizzo: string; RichiediPuntoNelDominio: boolean): TEsitoSanificazioneEmail;
var
  NumeroChiocciole: integer;
  Carattere: Char;
begin
  Result.Originale := Indirizzo;
  Result.Normalizzato := Normalizza(Indirizzo);
  Result.Motivo := '';

  if Result.Normalizzato = '' then
  begin
    Result.Esito := eeVuota;
    Exit;
  end;

  if Valido(Result.Normalizzato, RichiediPuntoNelDominio) then
  begin
    Result.Esito := eeValida;
    Exit;
  end;

  Result.Esito := eeNonValida;

  // motivo piu' probabile, nello stesso ordine della query di dettaglio in 02_ricognizione_anomalie.sql
  NumeroChiocciole := 0;
  for Carattere in Result.Normalizzato do
    if Carattere = '@' then
      Inc(NumeroChiocciole);

  if NumeroChiocciole = 0 then
    Result.Motivo := 'Manca il carattere @'
  else
    if NumeroChiocciole > 1 then
      Result.Motivo := 'Contiene piu'' di un carattere @'
    else
      if Result.Normalizzato.Contains(' ') then
        Result.Motivo := 'Contiene spazi'
      else
        if Result.Normalizzato.Contains(',') or Result.Normalizzato.Contains(';') then
          Result.Motivo := 'Contiene separatori , o ; (un solo indirizzo per campo)'
        else
          if RichiediPuntoNelDominio and (Result.Normalizzato.IndexOf('.', Result.Normalizzato.IndexOf('@')) < 0) then
            Result.Motivo := 'Il dominio non contiene un punto'
          else
            Result.Motivo := 'Formato non conforme';
end;

class function TzSanificazioneEmail.EstraiIndirizzi(const Elenco: string): TArray<string>;
var
  Elementi: TArray<string>;
  Elemento: string;
  Normalizzato: string;
  Conteggio: integer;
begin
  Elementi := Elenco.Split([';', ','], TStringSplitOptions.ExcludeEmpty);
  SetLength(Result, Length(Elementi));
  Conteggio := 0;

  for Elemento in Elementi do
  begin
    Normalizzato := Normalizza(Elemento);
    if Normalizzato <> '' then
    begin
      Result[Conteggio] := Normalizzato;
      Inc(Conteggio);
    end;
  end;

  SetLength(Result, Conteggio);
end;

class function TzSanificazioneEmail.SanificaElenco(const Elenco: string; out NonValidi: TArray<string>;
  RichiediPuntoNelDominio: boolean): string;
var
  Indirizzo: string;
  Validi: TStringList;
  Scartati: TStringList;
begin
  Validi := TStringList.Create;
  Scartati := TStringList.Create;
  try
    for Indirizzo in EstraiIndirizzi(Elenco) do
      if Valido(Indirizzo, RichiediPuntoNelDominio) then
        Validi.Add(Indirizzo)
      else
        Scartati.Add(Indirizzo);

    NonValidi := Scartati.ToStringArray;
    Result := string.Join('; ', Validi.ToStringArray);
  finally
    Scartati.Free;
    Validi.Free;
  end;
end;

end.
