// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-07
// ---------------------------------------------------------------------------
unit zSanificazione;

// Sanificazione generale del testo digitato o incollato dall'utente.
//
// Problema: il testo copiato da mail, PDF, Word ed Excel porta con se' caratteri
// che non stanno sulla tastiera e che l'occhio non vede: spazi unificatori (U+00A0),
// caratteri di controllo, zero width, BOM, segni di direzione del testo, simboli
// dei font PDF (area a uso privato), lettere accentate scomposte (e + accento),
// virgolette e trattini tipografici, legature (fi, fl). In un database UTF8 entrano
// senza errore e poi rompono ricerche, confronti, tracciati a lunghezza fissa,
// XML verso enti esterni, stampe.
//
// Due livelli, scelti tramite le opzioni:
//   OpzioniSicure       nessuna perdita di significato: si puo' applicare ovunque, anche
//                       in automatico al salvataggio (BeforePost).
//   OpzioniPredefinite  sicure + punteggiatura tipografica e legature ricondotte ai tasti
//                       della tastiera: per i campi di testo compilati dall'utente.
//
// Unit riusabile: solo RTL e Windows, nessuna dipendenza da unit applicative.
// Da NON applicare a RTF, HTML generato, JSON, XML, script: vedere TzSanificazione.SembraMarcatura.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Character;

type
  TOpzioneSanificazione = (
    // caratteri di controllo C0 e C1 (tranne CR, LF, TAB nei testi multiriga) e DEL: eliminati
    osRimuoviControlli,
    // caratteri di formato invisibili (categoria Cf: zero width, soft hyphen, BOM, bidi): eliminati
    osRimuoviFormato,
    // spazi Unicode (U+00A0, U+2000..U+200A, U+202F, U+3000, ...) ricondotti allo spazio ASCII
    osSpaziUnicode,
    // area a uso privato (U+E000..U+F8FF) e carattere di sostituzione U+FFFD: eliminati
    // (sono i pallini e i simboli dei font PDF e Wingdings, senza significato testuale)
    osRimuoviUsoPrivato,
    // lettere accentate scomposte (e + U+0301) ricomposte nella forma canonica NFC
    osNormalizzaNFC,
    // virgolette, apostrofi, trattini, puntini di sospensione, segno meno: equivalenti da tastiera
    osPunteggiaturaTipografica,
    // legature tipografiche (fi fl ff ffi ffl) sciolte nelle lettere componenti
    osLegature,
    // spazi ripetuti ridotti a uno, spazi prima di CR/LF eliminati
    osComprimiSpazi,
    // spazi ai bordi eliminati
    osTrim);

  TOpzioniSanificazione = set of TOpzioneSanificazione;

  TCarattereAnomalo = record
    Posizione: integer;  // 1-based, in code unit UTF-16 come Pos()
    CodePoint: integer;
    Descrizione: string; // es. 'Spazio unificatore (U+00A0)'
  end;

  TzSanificazione = class
  public const
    OpzioniSicure: TOpzioniSanificazione = [osRimuoviControlli, osRimuoviFormato, osSpaziUnicode, osRimuoviUsoPrivato, osNormalizzaNFC];
    OpzioniPredefinite: TOpzioniSanificazione = [osRimuoviControlli, osRimuoviFormato, osSpaziUnicode, osRimuoviUsoPrivato, osNormalizzaNFC,
      osPunteggiaturaTipografica, osLegature, osComprimiSpazi, osTrim];
  public
    // Multiriga = True conserva CR, LF e TAB; False li trasforma in spazio (campo a riga singola).
    class function Sanifica(const Testo: string; Multiriga: boolean; Opzioni: TOpzioniSanificazione): string; overload;
    class function Sanifica(const Testo: string; Multiriga: boolean = False): string; overload;

    // True se Sanifica cambierebbe qualcosa: comodo per evidenziare il campo senza modificarlo.
    class function ContieneAnomalie(const Testo: string; Multiriga: boolean; Opzioni: TOpzioniSanificazione): boolean; overload;
    class function ContieneAnomalie(const Testo: string; Multiriga: boolean = False): boolean; overload;

    // Elenco dei caratteri sospetti con posizione e descrizione, per diagnostica e per il
    // suggerimento all'utente ("trovati 2 spazi unificatori e 1 carattere di controllo").
    class function Analizza(const Testo: string; Multiriga: boolean = False): TArray<TCarattereAnomalo>;

    // Descrizione compatta dell'esito di Analizza, vuota se non ci sono anomalie.
    class function DescriviAnomalie(const Testo: string; Multiriga: boolean = False): string;

    // True se il testo sembra un contenuto strutturato da non toccare: RTF, HTML o XML,
    // JSON. Le pulizie tipografiche cambierebbero il significato del contenuto.
    class function SembraMarcatura(const Testo: string): boolean;

    // Forma canonica NFC tramite Windows (Normaliz.dll). Se la chiamata fallisce restituisce il testo com'e'.
    class function NormalizzaNFC(const Testo: string): string;

    // Sostituzione da tastiera di un carattere tipografico, '' se il carattere non e' tipografico.
    class function EquivalenteTastiera(Carattere: Char): string;
  end;

implementation

uses
  Winapi.Windows,
  System.Generics.Collections;

const
  NormalizationC = 1;

// Dichiarazione locale per non dipendere dalla versione della RTL
function NormalizeStringWin(NormForm: integer; SrcString: PWideChar; SrcLength: integer; DstString: PWideChar; DstLength: integer): integer; stdcall;
  external 'Normaliz.dll' name 'NormalizeString';

{ TzSanificazione }

class function TzSanificazione.EquivalenteTastiera(Carattere: Char): string;
begin
  case Carattere of
    // apostrofi e virgolette singole
    #$2018, #$2019, #$201A, #$201B, #$2032, #$00B4, #$02BC, #$02BB:
      Result := '''';
    // virgolette doppie
    #$201C, #$201D, #$201E, #$201F, #$2033, #$00AB, #$00BB:
      Result := '"';
    // trattini e segno meno
    #$2010, #$2011, #$2012, #$2013, #$2014, #$2015, #$2212, #$FE58, #$FE63, #$FF0D:
      Result := '-';
    // puntini di sospensione
    #$2026:
      Result := '...';
    // punto elenco e simili, tipici dei PDF
    #$2022, #$2023, #$25E6, #$2043, #$00B7:
      Result := '-';
    // barra di frazione, slash tipografici
    #$2044, #$2215:
      Result := '/';
    // legature latine
    #$FB00:
      Result := 'ff';
    #$FB01:
      Result := 'fi';
    #$FB02:
      Result := 'fl';
    #$FB03:
      Result := 'ffi';
    #$FB04:
      Result := 'ffl';
    #$FB05, #$FB06:
      Result := 'st';
  else
    Result := '';
  end;
end;

class function TzSanificazione.NormalizzaNFC(const Testo: string): string;
var
  LunghezzaRichiesta: integer;
  LunghezzaOttenuta: integer;
begin
  if Testo = '' then
    Exit('');

  // prima chiamata: stima della lunghezza; seconda: conversione
  LunghezzaRichiesta := NormalizeStringWin(NormalizationC, PWideChar(Testo), Length(Testo), nil, 0);
  if LunghezzaRichiesta <= 0 then
    Exit(Testo);

  SetLength(Result, LunghezzaRichiesta);
  LunghezzaOttenuta := NormalizeStringWin(NormalizationC, PWideChar(Testo), Length(Testo), PWideChar(Result), LunghezzaRichiesta);
  if LunghezzaOttenuta <= 0 then
    Exit(Testo);

  SetLength(Result, LunghezzaOttenuta);
end;

class function TzSanificazione.SembraMarcatura(const Testo: string): boolean;
var
  Inizio: string;
begin
  Inizio := Testo.TrimLeft;
  if Inizio.Length > 64 then
    Inizio := Inizio.Substring(0, 64);

  Result := Inizio.StartsWith('{\rtf') or
    Inizio.StartsWith('<?xml', True) or
    Inizio.StartsWith('<!DOCTYPE', True) or
    Inizio.StartsWith('<html', True) or
    Inizio.StartsWith('{"') or
    Inizio.StartsWith('[{') or
    Inizio.StartsWith('[]') or
    Inizio.StartsWith('{}');
end;

class function TzSanificazione.Sanifica(const Testo: string; Multiriga: boolean; Opzioni: TOpzioniSanificazione): string;
var
  Carattere: Char;
  Costruttore: TStringBuilder;
  Sostituzione: string;
  UltimoEraSpazio: boolean;
  Categoria: TUnicodeCategory;
  Sorgente: string;
begin
  if Testo = '' then
    Exit('');

  Sorgente := Testo;

  // la ricomposizione NFC va fatta per prima: dopo, i singoli caratteri si valutano gia' composti
  if osNormalizzaNFC in Opzioni then
    Sorgente := NormalizzaNFC(Sorgente);

  Costruttore := TStringBuilder.Create(Sorgente.Length);
  try
    UltimoEraSpazio := False;

    for Carattere in Sorgente do
    begin
      Sostituzione := Carattere;

      // 1. controlli: CR, LF e TAB sopravvivono solo nei testi multiriga
      if Carattere.IsControl then
      begin
        if Multiriga and CharInSet(Carattere, [#9, #10, #13]) then
          Sostituzione := Carattere
        else
          if osRimuoviControlli in Opzioni then
          begin
            // VT e FF (fine pagina dei PDF) e i controlli di riga in campo singolo diventano spazio,
            // cosi' due parole separate da un a-capo non si incollano
            if CharInSet(Carattere, [#9, #10, #11, #12, #13]) then
              Sostituzione := ' '
            else
              Sostituzione := '';
          end;
      end
      else
      begin
        Categoria := Carattere.GetUnicodeCategory;

        // 2. caratteri di formato invisibili
        if (osRimuoviFormato in Opzioni) and (Categoria = TUnicodeCategory.ucFormat) then
          Sostituzione := ''
        else
          // 3. spazi Unicode (IsWhiteSpace comprende anche U+2028 e U+2029)
          if (osSpaziUnicode in Opzioni) and Carattere.IsWhiteSpace and (Carattere <> ' ') then
            Sostituzione := ' '
          else
            // 4. uso privato e carattere di sostituzione
            if (osRimuoviUsoPrivato in Opzioni) and ((Categoria = TUnicodeCategory.ucPrivateUse) or (Carattere = #$FFFD)) then
              Sostituzione := ''
            else
              // 5. punteggiatura tipografica e legature
              if (osPunteggiaturaTipografica in Opzioni) or (osLegature in Opzioni) then
              begin
                Sostituzione := EquivalenteTastiera(Carattere);
                if Sostituzione = '' then
                  Sostituzione := Carattere
                else
                  if (Carattere >= #$FB00) and (Carattere <= #$FB06) then
                  begin
                    if not (osLegature in Opzioni) then
                      Sostituzione := Carattere;
                  end
                  else
                    if not (osPunteggiaturaTipografica in Opzioni) then
                      Sostituzione := Carattere;
              end;
      end;

      // 6. compressione degli spazi ripetuti
      if osComprimiSpazi in Opzioni then
      begin
        if Sostituzione = ' ' then
        begin
          if UltimoEraSpazio then
            Continue;
          UltimoEraSpazio := True;
        end
        else
          if Sostituzione <> '' then
          begin
            // spazi prima di un a-capo: eliminati
            if UltimoEraSpazio and CharInSet(Sostituzione[1], [#10, #13]) and (Costruttore.Length > 0) then
              Costruttore.Length := Costruttore.Length - 1;
            UltimoEraSpazio := False;
          end;
      end;

      Costruttore.Append(Sostituzione);
    end;

    Result := Costruttore.ToString;
  finally
    Costruttore.Free;
  end;

  // nei testi multiriga si tolgono anche le righe vuote iniziali e finali;
  // gli spazi prima di CR/LF sono gia' stati tolti al punto 6
  if osTrim in Opzioni then
    Result := Result.Trim([' ', #9, #10, #13]);
end;

class function TzSanificazione.Sanifica(const Testo: string; Multiriga: boolean): string;
begin
  Result := Sanifica(Testo, Multiriga, OpzioniPredefinite);
end;

class function TzSanificazione.ContieneAnomalie(const Testo: string; Multiriga: boolean; Opzioni: TOpzioniSanificazione): boolean;
begin
  Result := Sanifica(Testo, Multiriga, Opzioni) <> Testo;
end;

class function TzSanificazione.ContieneAnomalie(const Testo: string; Multiriga: boolean): boolean;
begin
  Result := ContieneAnomalie(Testo, Multiriga, OpzioniPredefinite);
end;

class function TzSanificazione.Analizza(const Testo: string; Multiriga: boolean): TArray<TCarattereAnomalo>;
var
  Indice: integer;
  Carattere: Char;
  Anomalia: TCarattereAnomalo;
  Elenco: TList<TCarattereAnomalo>;
  Descrizione: string;
  Categoria: TUnicodeCategory;
begin
  Elenco := TList<TCarattereAnomalo>.Create;
  try
    for Indice := 1 to Testo.Length do
    begin
      Carattere := Testo[Indice];
      Descrizione := '';

      if Carattere.IsControl then
      begin
        if not (Multiriga and CharInSet(Carattere, [#9, #10, #13])) then
          Descrizione := 'Carattere di controllo';
      end
      else
      begin
        Categoria := Carattere.GetUnicodeCategory;
        if Categoria = TUnicodeCategory.ucFormat then
          Descrizione := 'Carattere di formato invisibile'
        else
          if Carattere = #$00A0 then
            Descrizione := 'Spazio unificatore'
          else
            if Carattere.IsWhiteSpace and (Carattere <> ' ') then
              Descrizione := 'Spazio non standard'
            else
              if Categoria = TUnicodeCategory.ucPrivateUse then
                Descrizione := 'Simbolo di font (uso privato)'
              else
                if Carattere = #$FFFD then
                  Descrizione := 'Carattere di sostituzione'
                else
                  if (Categoria = TUnicodeCategory.ucNonSpacingMark) then
                    Descrizione := 'Accento scomposto'
                  else
                    if (Carattere >= #$FB00) and (Carattere <= #$FB06) then
                      Descrizione := 'Legatura tipografica'
                    else
                      if EquivalenteTastiera(Carattere) <> '' then
                        Descrizione := 'Punteggiatura tipografica';
      end;

      if Descrizione <> '' then
      begin
        Anomalia.Posizione := Indice;
        Anomalia.CodePoint := Ord(Carattere);
        Anomalia.Descrizione := Format('%s (U+%.4X)', [Descrizione, Ord(Carattere)]);
        Elenco.Add(Anomalia);
      end;
    end;

    Result := Elenco.ToArray;
  finally
    Elenco.Free;
  end;
end;

class function TzSanificazione.DescriviAnomalie(const Testo: string; Multiriga: boolean): string;
var
  Anomalie: TArray<TCarattereAnomalo>;
  Conteggi: TStringList;
  Anomalia: TCarattereAnomalo;
  Chiave: string;
  Indice: integer;
  Parti: TStringList;
begin
  Result := '';
  Anomalie := Analizza(Testo, Multiriga);
  if Length(Anomalie) = 0 then
    Exit;

  Conteggi := TStringList.Create;
  Parti := TStringList.Create;
  try
    // raggruppa per descrizione (senza il code point) e conta
    for Anomalia in Anomalie do
    begin
      Chiave := Anomalia.Descrizione.Substring(0, Anomalia.Descrizione.LastIndexOf(' ('));
      Indice := Conteggi.IndexOfName(Chiave);
      if Indice < 0 then
        Conteggi.AddPair(Chiave, '1')
      else
        Conteggi.ValueFromIndex[Indice] := IntToStr(StrToInt(Conteggi.ValueFromIndex[Indice]) + 1);
    end;

    for Indice := 0 to Conteggi.Count - 1 do
      Parti.Add(Format('%s x%s', [Conteggi.Names[Indice], Conteggi.ValueFromIndex[Indice]]));

    Result := string.Join(', ', Parti.ToStringArray);
  finally
    Parti.Free;
    Conteggi.Free;
  end;
end;

end.
