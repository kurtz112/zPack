// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Protocollo
//
// Il contratto fra la sonda (dentro l'applicazione in collaudo) e chi la
// interroga (zMCP_App), scritto una volta sola e usato da tutti e due.
//
// TRASPORTO. Una named pipe locale \\.\pipe\zSonda-<nome>, con il nome scelto
// da chi avvia il programma e passato con --sonda <nome>. Un messaggio per
// riga, JSON in UTF-8, chiuso da LF:
//
//   richiesta  {"id": 7, "comando": "esegui", "argomenti": {...}}
//   risposta   {"id": 7, "esito": "completato", "risultato": {...},
//               "messaggio": "...", "dialoghi": [...]}
//
// ESITI. completato: il comando e' finito. dialogo: durante il comando si e'
// aperto un dialogo modale, il comando resta sospeso e "lavoro" ne da'
// l'identificativo. tempo_scaduto: ne' l'uno ne' l'altro entro il tempo
// massimo; "battito_ms" dice da quanto il thread principale non risponde.
// errore: il comando non e' valido o e' fallito; "messaggio" dice perche'.
//
// Unit di libreria: solo RTL, niente VCL, cosi' la usa anche un programma a
// console come zMCP_App.
//
// ***************************************************************************

unit Sonda.Protocollo;

interface

uses
  System.SysUtils,
  System.JSON;

const
  // Cambia solo se cambia il significato di un messaggio esistente: un
  // comando nuovo non la cambia. zMCP_App la confronta all'aggancio.
  VersioneProtocolloSonda = 1;

  // Stringa riconoscibile nell'eseguibile: la ricetta di distribuzione di
  // zBuilder rifiuta un programma che la contiene (versione di collaudo).
  MarcaSondaNelEseguibile = 'zSonda-protocollo-collaudo-v1';

  PrefissoPipeSonda = '\\.\pipe\zSonda-';
  OpzioneSonda = '--sonda';

  EsitoCompletato = 'completato';
  EsitoDialogo = 'dialogo';
  EsitoTempoScaduto = 'tempo_scaduto';
  EsitoErrore = 'errore';

  // Comandi
  ComandoAggancio = 'aggancio';
  ComandoStato = 'stato';
  ComandoConfigura = 'configura';
  ComandoForm = 'form';
  ComandoComponenti = 'componenti';
  ComandoAzioni = 'azioni';
  ComandoMenu = 'menu';
  ComandoEsegui = 'esegui';
  ComandoAttendi = 'attendi';
  ComandoDialoghi = 'dialoghi';
  ComandoRispondi = 'rispondi';
  ComandoRegoleDialoghi = 'regole_dialoghi';
  ComandoDataset = 'dataset';
  ComandoImposta = 'imposta';
  ComandoEccezioni = 'eccezioni';
  ComandoImmagine = 'immagine';
  ComandoChiudi = 'chiudi';
  // clic e tasti spediti alla finestra del controllo, senza il mouse vero
  ComandoClic = 'clic';
  ComandoTasti = 'tasti';
  // trascinamento sincrono alla finestra del controllo: splitter e simili
  ComandoTrascina = 'trascina';
  // clic destro senza mostrare il menu: voci del menu contestuale che
  // comparirebbe nel punto, o pressione di una voce
  ComandoMenuContestuale = 'menu_contestuale';
  // voci delle barre DevExpress di una form o di un frame: elenco con valori
  // e valori ammessi (le si aziona con esegui e imposta)
  ComandoBarra = 'barra';
  // comandi registrati dal ponte dell'applicazione (RegistraComandoSonda):
  // filtro e colonna attiva di una vista, skin del programma
  ComandoFiltro = 'filtro';
  ComandoColonna = 'colonna';
  ComandoSkin = 'skin';
  // schede del layout e dei page control (attiva per didascalia, elenco) e
  // clic su una cella di griglia per riga e colonna, collegamenti compresi
  ComandoScheda = 'scheda';
  ComandoCella = 'cella';

function NomePipeSonda(const Nome: string): string;

// Una riga di protocollo: JSON compatto, senza a capo interni, chiuso da LF.
function RigaDaJson(Oggetto: TJSONObject): TBytes;

// Analizza una riga ricevuta; nil se non e' un oggetto JSON.
function JsonDaRiga(const Riga: TBytes): TJSONObject;

function NuovaRisposta(const Id: Int64; const Esito: string; const Messaggio: string = ''): TJSONObject;

implementation

function NomePipeSonda(const Nome: string): string;
begin
  Result := PrefissoPipeSonda + Nome;
end;

function RigaDaJson(Oggetto: TJSONObject): TBytes;
var
  Testo: string;
begin
  // ToString e non ToJSON: ToJSON trasforma in \uXXXX ogni carattere oltre
  // il 127, e le lettere accentate dei messaggi diventerebbero illeggibili
  // nel registro. Gli a capo dentro le stringhe sono gia' \n.
  Testo := Oggetto.ToString;
  Result := TEncoding.UTF8.GetBytes(Testo + #10);
end;

function JsonDaRiga(const Riga: TBytes): TJSONObject;
var
  Valore: TJSONValue;
begin
  Result := nil;
  Valore := TJSONObject.ParseJSONValue(Riga, 0, Length(Riga));
  if Valore is TJSONObject then
    Result := TJSONObject(Valore)
  else
    Valore.Free;
end;

function NuovaRisposta(const Id: Int64; const Esito: string; const Messaggio: string): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(Id));
  Result.AddPair('esito', Esito);
  if Messaggio <> '' then
    Result.AddPair('messaggio', Messaggio);
end;

end.
