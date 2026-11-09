// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------

// Conversazione di un ticket di assistenza e sua resa in HTML per la form
// "Le mie segnalazioni" (zMantis.TicketAssistenza.form).
//
// Un ticket diventa una sequenza di messaggi: la richiesta iniziale (la
// descrizione scritta da zExceptions), poi le note in ordine cronologico.
// Mantis non sa chi ha scritto una nota dalla postazione del cliente: il
// reporter e' l'utente di servizio del token, uguale per tutti. Lo dice il
// prefisso "[Nome] " che la form mette davanti a ogni risposta del cliente;
// le note senza prefisso sono dell'assistenza, scritte dal sito di Mantis.
//
// Il testo delle note si rende come Markdown (con gli a capo mantenuti, come
// fa Mantis con MantisCoreFormatting), cosi' una risposta dell'assistenza
// puo' avere titoli, elenchi e tabelle. La descrizione invece resta testo
// semplice: e' prodotta da zExceptions e contiene righe come "DB=MASTER" e
// separatori che il Markdown deformerebbe.
//
// HTML pensato per l'importatore di TdxRichEditControl, che interpreta un
// sottoinsieme dei CSS (stessi accorgimenti di Markdown.Html di
// zMarkdownViewer). La conversione Markdown e' della libreria delphi-markdown
// (Grahame Grieve, licenza BSD-3, X:\Druido\Lib\GIT\delphi-markdown\source).
// L'HTML scritto dentro il testo non viene interpretato ma mostrato come
// testo: i messaggi arrivano da fuori e non devono poter iniettare nulla.

unit Mantis.Segnalazioni.Html;

interface

uses
  System.SysUtils,
  System.Classes,
  Mantis.Api;

type
  TMantisTipoMessaggio = (tmRichiesta, tmRispostaAssistenza, tmNotaCliente);

  TMantisMessaggio = record
    Tipo: TMantisTipoMessaggio;
    IdNota: Integer; // 0 per la richiesta iniziale
    Autore: string;
    Data: TDateTime;
    Testo: string; // senza il prefisso "[Nome] " delle note del cliente
    Allegati: TArray<TMantisAllegato>;
    // Etichetta del messaggio: "Richiesta iniziale", "Risposta dell'assistenza"...
    function Etichetta: string;
    // Etichetta per l'albero, dove lo spazio e' poco: "Assistenza", "Risposta".
    function EtichettaBreve: string;
  end;

  TMantisFormatoAllegato = (faPdf, faMarkdown, faImmagine, faTesto, faAltro);

  // Colori della pagina HTML, in notazione #RRGGBB. La form li ricava dalla
  // skin attiva, cosi' l'anteprima segue lo schema chiaro o scuro del
  // programma; la unit resta senza dipendenze da DevExpress.
  TMantisColoriHtml = record
    Sfondo: string;
    Testo: string;
    TestoSecondario: string; // date, elenco degli allegati, avvisi, citazioni
    Titolo: string;
    Collegamento: string;
    FondoCodice: string;
    TestoCodice: string;
    Bordo: string; // tabelle, righe orizzontali, barra delle citazioni
    FondoIntestazioneTabella: string;
    TestoIntestazioneTabella: string;
    // Intestazione dei riquadri della conversazione.
    FondoAssistenza: string;
    BordoAssistenza: string;
    FondoCliente: string;
    BordoCliente: string;
    // Schema chiaro, usato senza skin.
    class function Chiari: TMantisColoriHtml; static;
  end;

// Messaggi del ticket, dal primo all'ultimo.
function MantisConversazione(const AIssue: TMantisIssue): TArray<TMantisMessaggio>;

// Prefisso che la form mette davanti alle note scritte dal cliente.
function MantisPrefissoCliente(const ANomeUtente: string): string;

// Oggetto senza il prefisso "[Modulo - Utente] " scritto da zExceptions.
function MantisOggettoSenzaPrefisso(const AOggetto: string): string;

// Formato di un allegato, dall'estensione del nome.
function MantisFormatoAllegato(const ANome: string): TMantisFormatoAllegato;

// Dimensione leggibile: "850 byte", "12 KB", "3,4 MB".
function MantisDimensioneTesto(AByte: Int64): string;

// Documento HTML con tutta la conversazione, un riquadro per messaggio.
function MantisHtmlConversazione(const AMessaggi: TArray<TMantisMessaggio>; const AColori: TMantisColoriHtml): string;
// Come sopra, con titolo e una riga di dettaglio in testa: per l'export in
// PDF, che esce dalla finestra e deve dire da solo di quale ticket parla.
function MantisHtmlConversazioneConTitolo(const ATitolo, ADettaglio: string; const AMessaggi: TArray<TMantisMessaggio>;
  const AColori: TMantisColoriHtml): string;
// Documento HTML con un solo messaggio.
function MantisHtmlMessaggio(const AMessaggio: TMantisMessaggio; const AColori: TMantisColoriHtml): string;
// Documento HTML di un file Markdown.
function MantisHtmlMarkdown(const ATesto: string; const AColori: TMantisColoriHtml): string;
// Documento HTML di un file di testo, a spaziatura fissa.
function MantisHtmlTestoSemplice(const ATesto: string; const AColori: TMantisColoriHtml): string;
// Documento HTML con un solo paragrafo di avviso.
function MantisHtmlAvviso(const ATesto: string; const AColori: TMantisColoriHtml): string;

// Testo di un file di provenienza ignota: UTF-8 (con o senza BOM) se i byte
// lo sono davvero, altrimenti code page 1252. Non solleva sulla codifica.
function MantisLeggiTesto(const APercorso: string): string;

implementation

uses
  System.IOUtils,
  System.StrUtils,
  System.RegularExpressions,
  MarkdownProcessor;

const
  FormatoDataOra = 'dd/mm/yyyy hh:nn';

  // Lunghezza massima del nome dentro il prefisso "[Nome] ": oltre, una
  // parentesi quadra in testa alla nota e' testo dell'assistenza.
  LunghezzaMassimaNome = 60;

{ TMantisColoriHtml }

class function TMantisColoriHtml.Chiari: TMantisColoriHtml;
begin
  Result.Sfondo := '#FFFFFF';
  Result.Testo := '#202020';
  Result.TestoSecondario := '#6A6A6A';
  Result.Titolo := '#1F4E79';
  Result.Collegamento := '#0563C1';
  Result.FondoCodice := '#F3F3F3';
  Result.TestoCodice := '#A31515';
  Result.Bordo := '#C8C8C8';
  Result.FondoIntestazioneTabella := '#EDEDED';
  Result.TestoIntestazioneTabella := '#202020';
  // L'assistenza in azzurro, il cliente in grigio.
  Result.FondoAssistenza := '#EAF2FB';
  Result.BordoAssistenza := '#1177D7';
  Result.FondoCliente := '#F1F1F1';
  Result.BordoCliente := '#8A8A8A';
end;

{ TMantisMessaggio }

function TMantisMessaggio.Etichetta: string;
begin
  case Tipo of
    tmRichiesta:
      Result := 'Richiesta iniziale';
    tmRispostaAssistenza:
      Result := 'Risposta dell''assistenza';
  else
    Result := 'Risposta del cliente';
  end;
end;

function TMantisMessaggio.EtichettaBreve: string;
begin
  case Tipo of
    tmRichiesta:
      Result := 'Richiesta iniziale';
    tmRispostaAssistenza:
      Result := 'Assistenza';
  else
    Result := 'Risposta';
  end;
end;

{ Funzioni di servizio }

function DataOraTesto(AValore: TDateTime): string;
begin
  if AValore = 0 then
    Result := ''
  else
    Result := FormatDateTime(FormatoDataOra, AValore);
end;

function HtmlEscape(const ATesto: string): string;
begin
  Result := ATesto.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;');
end;

function MantisPrefissoCliente(const ANomeUtente: string): string;
begin
  Result := '[' + ANomeUtente.Trim + '] ';
end;

// Prefisso "[Modulo - Utente] " dell'oggetto scritto da zExceptions: True
// se c'e', con l'utente e il resto dell'oggetto.
function SeparaPrefissoOggetto(const AOggetto: string; out AUtente, AResto: string): Boolean;
var
  Chiusa, Trattino: Integer;
  Dentro: string;
begin
  Result := False;
  AUtente := '';
  AResto := AOggetto;
  if not AOggetto.StartsWith('[') then
    Exit;
  Chiusa := AOggetto.IndexOf(']');
  if Chiusa < 2 then
    Exit;
  Dentro := AOggetto.Substring(1, Chiusa - 1);
  Trattino := Dentro.LastIndexOf(' - ');
  if Trattino >= 0 then
    AUtente := Dentro.Substring(Trattino + 3).Trim;
  AResto := AOggetto.Substring(Chiusa + 1).Trim;
  Result := AResto <> '';
end;

function MantisOggettoSenzaPrefisso(const AOggetto: string): string;
var
  Utente: string;
begin
  if not SeparaPrefissoOggetto(AOggetto, Utente, Result) then
    Result := AOggetto;
end;

// Riconosce il prefisso "[Nome] " e ne separa il nome dal testo.
function SeparaPrefissoCliente(const ATesto: string; out ANome, AResto: string): Boolean;
var
  Chiusa: Integer;
begin
  Result := False;
  ANome := '';
  AResto := ATesto;
  if not ATesto.StartsWith('[') then
    Exit;
  Chiusa := ATesto.IndexOf(']');
  if (Chiusa < 2) or (Chiusa > LunghezzaMassimaNome) then
    Exit;
  // Il nome sta su una riga sola: una parentesi chiusa dopo un a capo e'
  // testo, non prefisso.
  if ATesto.Substring(1, Chiusa - 1).IndexOfAny([#13, #10]) >= 0 then
    Exit;
  ANome := ATesto.Substring(1, Chiusa - 1).Trim;
  AResto := ATesto.Substring(Chiusa + 1).TrimLeft;
  Result := ANome <> '';
end;

function MantisConversazione(const AIssue: TMantisIssue): TArray<TMantisMessaggio>;
var
  Messaggio: TMantisMessaggio;
  Nota: TMantisNota;
  Nome, Resto: string;
begin
  Messaggio := Default (TMantisMessaggio);
  Messaggio.Tipo := tmRichiesta;
  // Chi ha aperto la richiesta lo dice l'oggetto: il reporter di Mantis e'
  // l'utente di servizio, uguale per tutti.
  if not SeparaPrefissoOggetto(AIssue.Oggetto, Nome, Resto) or (Nome = '') then
  begin
    Nome := AIssue.ReporterNomeReale.Trim;
    if Nome = '' then
      Nome := AIssue.Reporter.Trim;
  end;
  Messaggio.Autore := Nome;
  Messaggio.Data := AIssue.CreatoIl;
  Messaggio.Testo := AIssue.Descrizione;
  Messaggio.Allegati := AIssue.AllegatiDellaRichiesta;
  Result := [Messaggio];

  for Nota in AIssue.Note do
  begin
    Messaggio := Default (TMantisMessaggio);
    Messaggio.IdNota := Nota.Id;
    Messaggio.Data := Nota.CreataIl;
    Messaggio.Allegati := Nota.Allegati;
    if SeparaPrefissoCliente(Nota.Testo, Nome, Resto) then
    begin
      Messaggio.Tipo := tmNotaCliente;
      Messaggio.Autore := Nome;
      Messaggio.Testo := Resto;
    end
    else
    begin
      Messaggio.Tipo := tmRispostaAssistenza;
      Messaggio.Autore := Nota.AutoreNomeReale.Trim;
      if Messaggio.Autore = '' then
        Messaggio.Autore := Nota.Autore.Trim;
      Messaggio.Testo := Nota.Testo;
    end;
    Result := Result + [Messaggio];
  end;
end;

function MantisFormatoAllegato(const ANome: string): TMantisFormatoAllegato;
var
  Estensione: string;
begin
  Estensione := ExtractFileExt(ANome).ToLower;
  if Estensione = '.pdf' then
    Result := faPdf
  else
    if MatchStr(Estensione, ['.md', '.markdown']) then
      Result := faMarkdown
    else
      if MatchStr(Estensione, ['.png', '.jpg', '.jpeg', '.gif', '.bmp']) then
        Result := faImmagine
      else
        if MatchStr(Estensione, ['.txt', '.log', '.csv', '.json', '.xml', '.sql', '.ini']) then
          Result := faTesto
        else
          Result := faAltro;
end;

function MantisDimensioneTesto(AByte: Int64): string;
begin
  if AByte < 1024 then
    Result := Format('%d byte', [AByte])
  else
    if AByte < 1024 * 1024 then
      Result := Format('%.0n KB', [AByte / 1024])
    else
      Result := Format('%.1n MB', [AByte / (1024 * 1024)]);
end;

{ Markdown }

// Mantiene gli a capo singoli come fa Mantis: due spazi in fondo a ogni riga
// seguita da un'altra riga di testo (a capo forzato del CommonMark). Fuori
// dai blocchi di codice recintati e dalle righe di tabella, dove gli spazi
// in piu' cambierebbero il significato.
function ConACapoForzati(const ATesto: string): string;
var
  Righe: TStringList;
  Indice: Integer;
  Riga, Successiva: string;
  DentroCodice: Boolean;
begin
  Righe := TStringList.Create;
  try
    Righe.Text := ATesto;
    DentroCodice := False;
    for Indice := 0 to Righe.Count - 2 do
    begin
      Riga := Righe[Indice];
      if Riga.TrimLeft.StartsWith('```') or Riga.TrimLeft.StartsWith('~~~') then
      begin
        DentroCodice := not DentroCodice;
        Continue;
      end;
      if DentroCodice or (Riga.Trim = '') or Riga.TrimLeft.StartsWith('|') then
        Continue;
      Successiva := Righe[Indice + 1];
      if (Successiva.Trim = '') or Successiva.TrimLeft.StartsWith('|') then
        Continue;
      Righe[Indice] := Riga.TrimRight + '  ';
    end;
    Result := Righe.Text;
  finally
    Righe.Free;
  end;
end;

function MarkdownInHtml(const ATesto: string): string;
var
  Processore: TMarkdownProcessor;
begin
  Processore := TMarkdownProcessor.CreateDialect(mdCommonMark);
  try
    // Il dialetto CommonMark della libreria non ammette la modalita' "unsafe":
    // l'HTML scritto nel testo resta testo.
    Result := Processore.process(ConACapoForzati(ATesto));
  finally
    Processore.Free;
  end;
  // <del> del barrato non e' riconosciuto dall'importatore del RichEdit.
  Result := StringReplace(Result, '<del>', '<span style="text-decoration: line-through">', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '</del>', '</span>', [rfReplaceAll, rfIgnoreCase]);
end;

function TestoInHtml(const ATesto: string): string;
var
  Righe: TStringList;
  Riga: string;
  Rientro: Integer;
  Corpo: TStringBuilder;
begin
  Righe := TStringList.Create;
  Corpo := TStringBuilder.Create;
  try
    Righe.Text := ATesto.TrimRight;
    Corpo.Append('<p>');
    for Riga in Righe do
    begin
      // Il rientro iniziale si conserva: l'HTML lo cancellerebbe.
      Rientro := Riga.Length - Riga.TrimLeft.Length;
      Corpo.Append(DupeString('&nbsp;', Rientro)).Append(HtmlEscape(Riga.TrimLeft)).Append('<br>');
    end;
    Corpo.Append('</p>');
    Result := Corpo.ToString;
  finally
    Corpo.Free;
    Righe.Free;
  end;
end;

{ Documenti }

function FoglioDiStile(const AColori: TMantisColoriHtml): string;
begin
  Result :=
    'body { font-family: "Segoe UI", Arial, sans-serif; font-size: 10pt; color: ' + AColori.Testo + '; }' + sLineBreak +
    'h1 { font-size: 16pt; font-weight: bold; color: ' + AColori.Titolo + '; margin: 10pt 0 6pt 0; }' + sLineBreak +
    'h2 { font-size: 13pt; font-weight: bold; color: ' + AColori.Titolo + '; margin: 8pt 0 4pt 0; }' + sLineBreak +
    'h3, h4, h5, h6 { font-size: 11pt; font-weight: bold; color: ' + AColori.Titolo + '; margin: 6pt 0 4pt 0; }' + sLineBreak +
    'p { margin: 0 0 6pt 0; }' + sLineBreak +
    'li { margin: 0 0 2pt 0; }' + sLineBreak +
    'code { font-family: Consolas, "Courier New", monospace; font-size: 90%; background-color: ' + AColori.FondoCodice + '; color: ' + AColori.TestoCodice + '; }' + sLineBreak +
    'pre code { font-size: 100%; }' + sLineBreak +
    'pre { font-family: Consolas, "Courier New", monospace; font-size: 9pt; background-color: ' + AColori.FondoCodice + '; color: ' + AColori.Testo + '; margin: 0; padding: 0 4pt; }' + sLineBreak +
    'blockquote { color: ' + AColori.TestoSecondario + '; border-left: 3px solid ' + AColori.Bordo + '; padding-left: 8pt; margin: 4pt 0 6pt 0; }' + sLineBreak +
    'table { border-collapse: collapse; margin: 4pt 0 6pt 0; }' + sLineBreak +
    'th, td { border: 1px solid ' + AColori.Bordo + '; padding: 2pt 6pt; }' + sLineBreak +
    'th { background-color: ' + AColori.FondoIntestazioneTabella + '; color: ' + AColori.TestoIntestazioneTabella + '; font-weight: bold; }' + sLineBreak +
    'a { color: ' + AColori.Collegamento + '; text-decoration: underline; }' + sLineBreak +
    'hr { border: 0; border-top: 1px solid ' + AColori.Bordo + '; margin: 6pt 0; }' + sLineBreak +
    // Riquadri della conversazione: tabella a una colonna, intestazione e corpo.
    'table.messaggio { border-collapse: collapse; margin: 0 0 10pt 0; }' + sLineBreak +
    'td.intestazione { border: 0; padding: 3pt 8pt; font-size: 9pt; }' + sLineBreak +
    'td.corpo { border: 0; padding: 6pt 8pt 2pt 8pt; }' + sLineBreak +
    'p.allegati { font-size: 9pt; color: ' + AColori.TestoSecondario + '; margin: 4pt 0 2pt 0; }' + sLineBreak +
    'p.avviso { font-size: 10pt; color: ' + AColori.TestoSecondario + '; margin: 12pt 0 0 0; }';
end;

function Documento(const ACorpo: string; const AColori: TMantisColoriHtml): string;
begin
  // Lo sfondo della pagina il RichEdit lo prende da bgcolor, non dal CSS.
  Result :=
    '<!DOCTYPE html>' + sLineBreak +
    '<html><head><meta charset="utf-8"><style>' + sLineBreak +
    FoglioDiStile(AColori) + sLineBreak +
    '</style></head><body bgcolor="' + AColori.Sfondo + '">' + sLineBreak +
    ACorpo + sLineBreak +
    '</body></html>';
end;

function CorpoMessaggio(const AMessaggio: TMantisMessaggio): string;
begin
  if AMessaggio.Testo.Trim = '' then
    Result := ''
  else
    if AMessaggio.Tipo = tmRichiesta then
      Result := TestoInHtml(AMessaggio.Testo)
    else
      Result := MarkdownInHtml(AMessaggio.Testo);
end;

function RiquadroMessaggio(const AMessaggio: TMantisMessaggio; const AColori: TMantisColoriHtml): string;
var
  Bordo, Fondo, Intestazione, Allegati: string;
  Allegato: TMantisAllegato;
begin
  if AMessaggio.Tipo = tmRispostaAssistenza then
  begin
    Bordo := AColori.BordoAssistenza;
    Fondo := AColori.FondoAssistenza;
  end
  else
  begin
    Bordo := AColori.BordoCliente;
    Fondo := AColori.FondoCliente;
  end;

  Intestazione := '<b>' + HtmlEscape(AMessaggio.Etichetta) + '</b>';
  if AMessaggio.Autore <> '' then
    Intestazione := Intestazione + ' &middot; ' + HtmlEscape(AMessaggio.Autore);
  if AMessaggio.Data <> 0 then
    Intestazione := Intestazione + '&nbsp;&nbsp;<span style="color: ' + AColori.TestoSecondario + '">' + DataOraTesto(AMessaggio.Data) + '</span>';

  Allegati := '';
  for Allegato in AMessaggio.Allegati do
  begin
    if Allegati <> '' then
      Allegati := Allegati + ', ';
    Allegati := Allegati + HtmlEscape(Allegato.Nome) + ' (' + MantisDimensioneTesto(Allegato.Dimensione) + ')';
  end;
  if Allegati <> '' then
    Allegati := '<p class="allegati">Allegati: ' + Allegati + '</p>';

  Result :=
    '<table class="messaggio" width="100%" cellspacing="0" cellpadding="0">' +
    '<tr><td class="intestazione" bgcolor="' + Fondo + '" style="border-left: 3px solid ' + Bordo + '">' + Intestazione + '</td></tr>' +
    '<tr><td class="corpo" style="border-left: 3px solid ' + Bordo + '">' + CorpoMessaggio(AMessaggio) + Allegati + '</td></tr>' +
    '</table>';
end;

function MantisHtmlConversazione(const AMessaggi: TArray<TMantisMessaggio>; const AColori: TMantisColoriHtml): string;
var
  Corpo: TStringBuilder;
  Messaggio: TMantisMessaggio;
begin
  Corpo := TStringBuilder.Create;
  try
    for Messaggio in AMessaggi do
      Corpo.AppendLine(RiquadroMessaggio(Messaggio, AColori));
    Result := Documento(Corpo.ToString, AColori);
  finally
    Corpo.Free;
  end;
end;

function MantisHtmlConversazioneConTitolo(const ATitolo, ADettaglio: string; const AMessaggi: TArray<TMantisMessaggio>;
  const AColori: TMantisColoriHtml): string;
var
  Corpo: TStringBuilder;
  Messaggio: TMantisMessaggio;
begin
  Corpo := TStringBuilder.Create;
  try
    Corpo.AppendLine('<h1>' + HtmlEscape(ATitolo) + '</h1>');
    if ADettaglio <> '' then
      Corpo.AppendLine('<p class="allegati">' + HtmlEscape(ADettaglio) + '</p>');
    for Messaggio in AMessaggi do
      Corpo.AppendLine(RiquadroMessaggio(Messaggio, AColori));
    Result := Documento(Corpo.ToString, AColori);
  finally
    Corpo.Free;
  end;
end;

function MantisHtmlMessaggio(const AMessaggio: TMantisMessaggio; const AColori: TMantisColoriHtml): string;
begin
  Result := Documento(RiquadroMessaggio(AMessaggio, AColori), AColori);
end;

function MantisHtmlMarkdown(const ATesto: string; const AColori: TMantisColoriHtml): string;
begin
  Result := Documento(MarkdownInHtml(ATesto), AColori);
end;

function MantisHtmlTestoSemplice(const ATesto: string; const AColori: TMantisColoriHtml): string;
begin
  Result := Documento('<pre>' + HtmlEscape(ATesto.TrimRight) + '</pre>', AColori);
end;

function MantisHtmlAvviso(const ATesto: string; const AColori: TMantisColoriHtml): string;
begin
  Result := Documento('<p class="avviso">' + HtmlEscape(ATesto) + '</p>', AColori);
end;

{ Lettura tollerante }

// Lunghezza del tratto iniziale di byte che forma UTF-8 valido e completo.
function LunghezzaUtf8Valida(const AByte: TBytes; AInizio: Integer): Integer;
var
  Indice, Seguenti, Conto: Integer;
  Primo: Byte;
begin
  Indice := AInizio;
  while Indice < Length(AByte) do
  begin
    Primo := AByte[Indice];
    if Primo < $80 then
      Seguenti := 0
    else
      if (Primo >= $C2) and (Primo <= $DF) then
        Seguenti := 1
      else
        if (Primo >= $E0) and (Primo <= $EF) then
          Seguenti := 2
        else
          if (Primo >= $F0) and (Primo <= $F4) then
            Seguenti := 3
          else
            Break;
    // Sequenza troncata in fondo al file.
    if (Seguenti > 0) and (Indice + Seguenti >= Length(AByte)) then
      Break;
    for Conto := 1 to Seguenti do
      if (AByte[Indice + Conto] and $C0) <> $80 then
        Exit(Indice - AInizio);
    // Forme troppo lunghe, surrogati e oltre U+10FFFF: Windows le rifiuta.
    if ((Primo = $E0) and (AByte[Indice + 1] < $A0)) or ((Primo = $ED) and (AByte[Indice + 1] > $9F)) or
      ((Primo = $F0) and (AByte[Indice + 1] < $90)) or ((Primo = $F4) and (AByte[Indice + 1] > $8F)) then
      Break;
    Inc(Indice, Seguenti + 1);
  end;
  Result := Indice - AInizio;
end;

function MantisLeggiTesto(const APercorso: string): string;
var
  Contenuto: TBytes;
  Inizio: Integer;
  CodePage: TEncoding;
begin
  Contenuto := TFile.ReadAllBytes(APercorso);
  Inizio := 0;
  if (Length(Contenuto) >= 3) and (Contenuto[0] = $EF) and (Contenuto[1] = $BB) and (Contenuto[2] = $BF) then
    Inizio := 3;

  // TEncoding.UTF8 solleva sui byte non validi: si controlla prima.
  if LunghezzaUtf8Valida(Contenuto, Inizio) = Length(Contenuto) - Inizio then
    Exit(TEncoding.UTF8.GetString(Contenuto, Inizio, Length(Contenuto) - Inizio));

  CodePage := TEncoding.GetEncoding(1252);
  try
    Result := CodePage.GetString(Contenuto, Inizio, Length(Contenuto) - Inizio);
  finally
    CodePage.Free;
  end;
end;

end.
