// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Log.Perf
//
// Raccolta delle misure di durata durante una sessione di registrazione
// avviata dall'utente (vedi zDiagnostica.Log).
//
// Produce due cose:
//  1) una riga per evento nel file CSV della sessione, a campi separati da
//     punto e virgola, pensata per essere ordinata e sommata da uno strumento
//     esterno senza interpretare l'albero EnterMethod/LeaveMethod;
//  2) un riepilogo aggregato in memoria (conteggio, totale, massimo, media
//     per operazione) che viene scritto in coda al log e nella descrizione
//     del ticket. L'aggregazione la fa questa unit, non chi legge il log.
//
// L'aggregazione comprende SEMPRE tutti gli eventi; la soglia riguarda solo
// quali eventi finiscono nel log testuale di SmartInspect, che altrimenti
// diventa illeggibile. Il numero di eventi non scritti viene riportato nel
// riepilogo: nessun taglio silenzioso.
//
// Unit autonoma: dipende solo dalla RTL. Chi misura (l'innesto in
// TzFbDataSet, i ponti dei servizi esterni, le stampe) chiama
// SegnalaOperazione dopo aver verificato RegistrazionePrestazioniAttiva,
// cosi' a registrazione spenta il costo e' la lettura di un booleano.
//
// ***************************************************************************

unit zDiagnostica.Log.Perf;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections;

type
  // Categoria dell'operazione misurata: raggruppa il riepilogo e riempie la
  // colonna "categoria" del CSV.
  TCategoriaOperazione = (
    coDataSet, // apertura di un dataset
    coStoredProcedure, // esecuzione di una stored procedure
    coReport, // anteprima o stampa
    coServizioEsterno, // chiamata a un servizio esterno (REST/SOAP)
    coInterfaccia, // costruzione di griglie, layout, card
    coBloccoInterfaccia, // interfaccia non rispondente rilevata dal battito
    coRisorse, // campionamento memoria e handle
    coSegnalibro, // marcatore inserito dall'utente
    coAltro);

  // Mantis #183 - 2026-10-08: cosa registrare in piu' durante la sessione.
  // Le scelte le fa l'utente nella finestra di avvio della registrazione
  // (zDiagnostica.Log.OpzioniForm) e le legge chi misura, con
  // RegistrazioneFetchAttiva e RegistrazioneGrigliaAttiva, allo stesso costo
  // di RegistrazionePrestazioniAttiva: un booleano. I valori predefiniti sono
  // il comportamento di prima: nessuna misura in piu', commento e invio del
  // ticket alla chiusura.
  TzOpzioniRegistrazione = record
    // Durata e righe di ogni rowset letto dal server da TzFbDataSet, il primo
    // (esecuzione e ordinamento sul server) distinto dai successivi.
    TempiFetch: boolean;
    // Caricamento del buffer della griglia in TzDbView (GridMode), dalla
    // attivazione del collegamento dati alla fine del primo aggiornamento.
    TempiGriglia: boolean;
    // Traccia FireDAC su file nella cartella della sessione, con ekVendor ed
    // ekCmdDataIn. La accende l'applicazione, che per cambiare MonitorBy deve
    // riconnettersi: vedi OnMonitorFireDAC in zDiagnostica.Log.
    MonitorFireDAC: boolean;
    // Alla chiusura chiede la nota per il ticket. Dal 2026-10-29 la procedura
    // guidata la fa scrivere all'avvio (Nota) e spegne questa domanda; resta
    // accesa per gli avvii senza finestra (scorciatoia, prossimo avvio), dove
    // la chiusura e' l'unico momento in cui l'utente puo' scriverla.
    ChiediCommento: boolean;
    // Nota dell'utente scritta all'avvio nella procedura guidata: va nel
    // ticket come "Segnalazione dell'utente" e nel marcatore .inCorso, cosi'
    // una sessione interrotta la ritrova. Vuota negli avvii senza finestra.
    Nota: string;
    // Alla chiusura comprime i file e apre il ticket su Mantis. Spento, i
    // file restano nella cartella dei log, pronti per log_summary.
    InviaAllaFine: boolean;
    // Filmato della finestra (zDiagnostica.Video), sbloccato con il codice
    // dell'assistenza. Spento sia in Predefinite sia in Tutte: va scelto,
    // non proposto acceso, e gli avvii senza finestra non lo accendono mai,
    // perche' l'utente non avrebbe visto l'avviso.
    Video: boolean;
    class function Predefinite: TzOpzioniRegistrazione; static;
    // Tutte le caselle accese: e' lo stato proposto dalla finestra di avvio
    // (richiesta dell'utente del 2026-10-08), mentre Predefinite resta per gli
    // avvii senza finestra (scorciatoia, prossimo avvio), dove accendere il
    // monitor FireDAC riaprirebbe la connessione senza che nessuno l'abbia visto.
    class function Tutte: TzOpzioniRegistrazione; static;
    // Stato proposto dalla procedura guidata (2026-10-29): come Tutte ma con
    // il registro dettagliato del database spento, da accendere solo su
    // richiesta dell'assistenza perche' chiude e riapre la connessione.
    class function Proposte: TzOpzioniRegistrazione; static;
    // True se e' accesa almeno una misura in piu' rispetto a prima.
    function MisureAggiuntive: boolean;
    // Elenco leggibile delle scelte, per il log e la descrizione del ticket.
    function Descrizione: string;
  end;

  // Riga del riepilogo: una per coppia categoria+nome.
  TVoceRiepilogo = record
    Categoria: TCategoriaOperazione;
    Nome: string;
    Conteggio: Integer;
    TotaleMs: Int64;
    MassimoMs: Int64;
    MinimoMs: Int64;
    RigheTotali: Int64;
    DettaglioPeggiore: string; // dettaglio dell'esecuzione piu' lenta
    function MediaMs: Double;
  end;

  TzRaccoltaPrestazioni = class
  strict private
    class var FIstanza: TzRaccoltaPrestazioni;
  strict private
    FLock: TCriticalSection;
    FVoci: TDictionary<string, TVoceRiepilogo>;
    FScrittore: TStreamWriter;
    FAttiva: boolean;
    FSogliaMs: Integer;
    FMassimoRigheCsv: Integer;
    FRigheScritte: Integer;
    FEventiTotali: Integer;
    FEventiFuoriCsv: Integer;
    FEventiSottoSoglia: Integer;
    FRegistraDettaglio: boolean;
    FModuloCorrente: string;
    FOpzioni: TzOpzioniRegistrazione;
    function GetModuloCorrente: string;
    procedure SetModuloCorrente(const Value: string);
  public
    class function Istanza: TzRaccoltaPrestazioni;
    class procedure Libera;

    constructor Create;
    destructor Destroy; override;

    // Apre il CSV e azzera il riepilogo. ASogliaMs e' la soglia oltre la
    // quale l'evento viene scritto anche nel log testuale.
    // ARegistraDettaglio a False omette SQL e valori dei parametri: serve
    // quando il log finira' su un ticket visibile ad altri (dati personali).
    procedure Avvia(const AFileCsv: string; ASogliaMs: Integer; ARegistraDettaglio: boolean);
    procedure Termina;

    // Registra un evento misurato. Non solleva mai eccezioni: una misura
    // persa non deve far fallire l'operazione misurata.
    procedure Registra(ACategoria: TCategoriaOperazione; const ANome: string; ADurataMs: Int64;
      const ADettaglio: string = ''; ARighe: Integer = -1);

    // Riepilogo ordinato per tempo totale decrescente.
    function ElencoOrdinato: TArray<TVoceRiepilogo>;

    // Riepilogo pronto da scrivere in coda al log e nel ticket:
    // operazioni piu' costose, totali per categoria, ripetizioni sospette.
    function TestoRiepilogo(AMassimeVoci: Integer = 20): string;

    property Attiva: boolean read FAttiva;
    property EventiTotali: Integer read FEventiTotali;
    property EventiFuoriCsv: Integer read FEventiFuoriCsv;
    property EventiSottoSoglia: Integer read FEventiSottoSoglia;
    property SogliaMs: Integer read FSogliaMs write FSogliaMs;
    property MassimoRigheCsv: Integer read FMassimoRigheCsv write FMassimoRigheCsv;
    property RegistraDettaglio: boolean read FRegistraDettaglio write FRegistraDettaglio;
    // Nome della form attiva al momento dell'evento: lo aggiorna
    // zDiagnostica.Log agganciandosi a Screen.OnActiveFormChange.
    property ModuloCorrente: string read GetModuloCorrente write SetModuloCorrente;
    // Mantis #183 - 2026-10-08: scelte dell'utente per la sessione in corso.
    // Le imposta zDiagnostica.Log prima di Avvia; a sessione spenta non
    // contano, perche' le funzioni qui sotto le leggono insieme ad Attiva.
    property Opzioni: TzOpzioniRegistrazione read FOpzioni write FOpzioni;
  end;

  // Nome breve della categoria, usato nel CSV e nel riepilogo.
function NomeCategoria(ACategoria: TCategoriaOperazione): string;

// Da verificare PRIMA di calcolare qualunque dettaglio costoso da passare a
// SegnalaOperazione.
function RegistrazionePrestazioniAttiva: boolean;

// Mantis #183 - 2026-10-08: misure in piu', accese dall'utente all'avvio della
// sessione. Stesso costo di RegistrazionePrestazioniAttiva: si leggono prima
// di avviare un cronometro o di comporre un dettaglio.
function RegistrazioneFetchAttiva: boolean;
function RegistrazioneGrigliaAttiva: boolean;

// Punto di ingresso per chi misura.
procedure SegnalaOperazione(ACategoria: TCategoriaOperazione; const ANome: string; ADurataMs: Int64;
  const ADettaglio: string = ''; ARighe: Integer = -1);

// Marcatore inserito dall'utente ("qui e' lento"): allinea la percezione
// dell'utente con i millisecondi misurati.
procedure SegnalaSegnalibro(const ATesto: string);

implementation

uses
  System.Generics.Defaults,
  System.Math;

const
  SeparatoreCsv = ';';
  MassimeRigheCsvDefault = 50000;
  MassimaLunghezzaDettaglio = 1000;

  // Intestazione del CSV: una riga per evento.
  IntestazioneCsv = 'istante' + SeparatoreCsv + 'categoria' + SeparatoreCsv + 'nome' + SeparatoreCsv + 'ms' +
    SeparatoreCsv + 'righe' + SeparatoreCsv + 'modulo' + SeparatoreCsv + 'dettaglio';

function NomeCategoria(ACategoria: TCategoriaOperazione): string;
begin
  case ACategoria of
    coDataSet:
      result := 'dataset';
    coStoredProcedure:
      result := 'procedura';
    coReport:
      result := 'stampa';
    coServizioEsterno:
      result := 'servizio';
    coInterfaccia:
      result := 'interfaccia';
    coBloccoInterfaccia:
      result := 'blocco';
    coRisorse:
      result := 'risorse';
    coSegnalibro:
      result := 'segnalibro';
  else
    result := 'altro';
  end;
end;

function RegistrazionePrestazioniAttiva: boolean;
begin
  result := TzRaccoltaPrestazioni.Istanza.Attiva;
end;

function RegistrazioneFetchAttiva: boolean;
begin
  result := TzRaccoltaPrestazioni.Istanza.Attiva and TzRaccoltaPrestazioni.Istanza.Opzioni.TempiFetch;
end;

function RegistrazioneGrigliaAttiva: boolean;
begin
  result := TzRaccoltaPrestazioni.Istanza.Attiva and TzRaccoltaPrestazioni.Istanza.Opzioni.TempiGriglia;
end;

{ TzOpzioniRegistrazione }

class function TzOpzioniRegistrazione.Predefinite: TzOpzioniRegistrazione;
begin
  result.TempiFetch := False;
  result.TempiGriglia := False;
  result.MonitorFireDAC := False;
  result.ChiediCommento := True;
  result.Nota := '';
  result.InviaAllaFine := True;
  result.Video := False;
end;

class function TzOpzioniRegistrazione.Tutte: TzOpzioniRegistrazione;
begin
  result.TempiFetch := True;
  result.TempiGriglia := True;
  result.MonitorFireDAC := True;
  result.ChiediCommento := True;
  result.Nota := '';
  result.InviaAllaFine := True;
  result.Video := False;
end;

class function TzOpzioniRegistrazione.Proposte: TzOpzioniRegistrazione;
begin
  result := Tutte;
  result.MonitorFireDAC := False;
end;

function TzOpzioniRegistrazione.MisureAggiuntive: boolean;
begin
  result := TempiFetch or TempiGriglia or MonitorFireDAC;
end;

function TzOpzioniRegistrazione.Descrizione: string;

  procedure Aggiungi(const AVoce: string; AAcceso: boolean);
  begin
    if result <> '' then
      result := result + ', ';
    if AAcceso then
      result := result + AVoce
    else
      result := result + 'no ' + AVoce;
  end;

begin
  result := '';
  Aggiungi('tempi fetch', TempiFetch);
  Aggiungi('tempi griglia', TempiGriglia);
  Aggiungi('monitor FireDAC', MonitorFireDAC);
  if Nota.Trim <> '' then
    Aggiungi('nota all''avvio', True)
  else
    Aggiungi('nota alla fine', ChiediCommento);
  Aggiungi('invio alla fine', InviaAllaFine);
  Aggiungi('filmato', Video);
end;

procedure SegnalaOperazione(ACategoria: TCategoriaOperazione; const ANome: string; ADurataMs: Int64;
  const ADettaglio: string = ''; ARighe: Integer = -1);
begin
  TzRaccoltaPrestazioni.Istanza.Registra(ACategoria, ANome, ADurataMs, ADettaglio, ARighe);
end;

procedure SegnalaSegnalibro(const ATesto: string);
begin
  TzRaccoltaPrestazioni.Istanza.Registra(coSegnalibro, 'segnalibro utente', 0, ATesto);
end;

{ TVoceRiepilogo }

function TVoceRiepilogo.MediaMs: Double;
begin
  if Conteggio <= 0 then
    result := 0
  else
    result := TotaleMs / Conteggio;
end;

{ TzRaccoltaPrestazioni }

class function TzRaccoltaPrestazioni.Istanza: TzRaccoltaPrestazioni;
begin
  if FIstanza = nil then
    FIstanza := TzRaccoltaPrestazioni.Create;
  result := FIstanza;
end;

class procedure TzRaccoltaPrestazioni.Libera;
begin
  FreeAndNil(FIstanza);
end;

constructor TzRaccoltaPrestazioni.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FVoci := TDictionary<string, TVoceRiepilogo>.Create;
  FSogliaMs := 300;
  FMassimoRigheCsv := MassimeRigheCsvDefault;
  FRegistraDettaglio := True;
  FOpzioni := TzOpzioniRegistrazione.Predefinite;
end;

destructor TzRaccoltaPrestazioni.Destroy;
begin
  Termina;
  FreeAndNil(FVoci);
  FreeAndNil(FLock);
  inherited;
end;

function TzRaccoltaPrestazioni.GetModuloCorrente: string;
begin
  FLock.Enter;
  try
    result := FModuloCorrente;
  finally
    FLock.Leave;
  end;
end;

procedure TzRaccoltaPrestazioni.SetModuloCorrente(const Value: string);
begin
  FLock.Enter;
  try
    FModuloCorrente := Value;
  finally
    FLock.Leave;
  end;
end;

procedure TzRaccoltaPrestazioni.Avvia(const AFileCsv: string; ASogliaMs: Integer; ARegistraDettaglio: boolean);
begin
  Termina;

  FLock.Enter;
  try
    FVoci.Clear;
    FRigheScritte := 0;
    FEventiTotali := 0;
    FEventiFuoriCsv := 0;
    FEventiSottoSoglia := 0;
    FSogliaMs := ASogliaMs;
    FRegistraDettaglio := ARegistraDettaglio;

    // TEncoding.UTF8 scrive il BOM: serve perche' Excel apra il CSV con gli
    // accenti corretti.
    FScrittore := TStreamWriter.Create(AFileCsv, False, TEncoding.UTF8);
    FScrittore.WriteLine(IntestazioneCsv);
    FScrittore.Flush;

    FAttiva := True;
  finally
    FLock.Leave;
  end;
end;

procedure TzRaccoltaPrestazioni.Termina;
begin
  FLock.Enter;
  try
    FAttiva := False;
    if FScrittore <> nil then
    begin
      try
        FScrittore.Flush;
      except
      end;
      FreeAndNil(FScrittore);
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TzRaccoltaPrestazioni.Registra(ACategoria: TCategoriaOperazione; const ANome: string; ADurataMs: Int64;
  const ADettaglio: string; ARighe: Integer);

  // Il dettaglio finisce in una colonna CSV: via i ritorni a capo e i
  // separatori, e taglio alla lunghezza massima.
  function DettaglioPerCsv(const ATesto: string): string;
  begin
    result := ATesto.Replace(#13#10, ' ').Replace(#13, ' ').Replace(#10, ' ').Replace(SeparatoreCsv, ',').Replace('"', '''');
    while result.Contains('  ') do
      result := result.Replace('  ', ' ');
    result := result.Trim;
    if result.Length > MassimaLunghezzaDettaglio then
      result := result.Substring(0, MassimaLunghezzaDettaglio) + '...[troncato]';
  end;

var
  Chiave: string;
  Voce: TVoceRiepilogo;
  Dettaglio: string;
  Riga: string;
begin
  if not FAttiva then
    Exit;

  try
    if FRegistraDettaglio then
      Dettaglio := DettaglioPerCsv(ADettaglio)
    else
      Dettaglio := '';

    FLock.Enter;
    try
      if not FAttiva then
        Exit;

      Inc(FEventiTotali);

      // Aggregazione: comprende tutti gli eventi, anche sotto soglia,
      // perche' il conteggio delle ripetizioni e' l'informazione che
      // smaschera la query breve eseguita centinaia di volte.
      Chiave := NomeCategoria(ACategoria) + '|' + ANome;
      if not FVoci.TryGetValue(Chiave, Voce) then
      begin
        Voce := Default (TVoceRiepilogo);
        Voce.Categoria := ACategoria;
        Voce.Nome := ANome;
        Voce.MinimoMs := ADurataMs;
      end;

      Inc(Voce.Conteggio);
      Voce.TotaleMs := Voce.TotaleMs + ADurataMs;
      if ADurataMs > Voce.MassimoMs then
      begin
        Voce.MassimoMs := ADurataMs;
        Voce.DettaglioPeggiore := Dettaglio;
      end;
      if ADurataMs < Voce.MinimoMs then
        Voce.MinimoMs := ADurataMs;
      if ARighe >= 0 then
        Voce.RigheTotali := Voce.RigheTotali + ARighe;

      FVoci.AddOrSetValue(Chiave, Voce);

      if ADurataMs < FSogliaMs then
        Inc(FEventiSottoSoglia);

      // Riga CSV. Il tetto sulle righe esiste per non produrre file
      // ingestibili: quante ne sono state scartate finisce nel riepilogo.
      if (FScrittore <> nil) and (FRigheScritte < FMassimoRigheCsv) then
      begin
        Riga := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', now) + SeparatoreCsv + NomeCategoria(ACategoria) +
          SeparatoreCsv + ANome.Replace(SeparatoreCsv, ',') + SeparatoreCsv + ADurataMs.ToString + SeparatoreCsv;

        if ARighe >= 0 then
          Riga := Riga + ARighe.ToString;

        Riga := Riga + SeparatoreCsv + FModuloCorrente.Replace(SeparatoreCsv, ',') + SeparatoreCsv + Dettaglio;

        FScrittore.WriteLine(Riga);
        FScrittore.Flush; // il CSV deve restare valido anche se l'applicazione muore
        Inc(FRigheScritte);
      end
      else
        Inc(FEventiFuoriCsv);
    finally
      FLock.Leave;
    end;
  except
    // Una misura persa non deve mai far fallire l'operazione misurata.
  end;
end;

function TzRaccoltaPrestazioni.ElencoOrdinato: TArray<TVoceRiepilogo>;
var
  Elenco: TArray<TVoceRiepilogo>;
begin
  FLock.Enter;
  try
    Elenco := FVoci.Values.ToArray;
  finally
    FLock.Leave;
  end;

  TArray.Sort<TVoceRiepilogo>(Elenco, TComparer<TVoceRiepilogo>.Construct(
    function(const A, B: TVoceRiepilogo): Integer
    begin
      result := CompareValue(B.TotaleMs, A.TotaleMs);
      if result = 0 then
        result := CompareValue(B.Conteggio, A.Conteggio);
    end));

  result := Elenco;
end;

function TzRaccoltaPrestazioni.TestoRiepilogo(AMassimeVoci: Integer): string;
var
  Elenco: TArray<TVoceRiepilogo>;
  Voce: TVoceRiepilogo;
  Testo: TStringList;
  TotaliCategoria: TDictionary<string, Int64>;
  ConteggiCategoria: TDictionary<string, Integer>;
  Categoria: string;
  Totale: Int64;
  Conteggio: Integer;
  i: Integer;
  RipetizioniTrovate: boolean;
begin
  Elenco := ElencoOrdinato;

  Testo := TStringList.Create;
  TotaliCategoria := TDictionary<string, Int64>.Create;
  ConteggiCategoria := TDictionary<string, Integer>.Create;
  try
    Testo.Add('OPERAZIONI PIU COSTOSE (per tempo totale)');
    Testo.Add('');
    Testo.Add(Format('%-9s %10s %7s %10s %10s %10s  %s', ['categoria', 'totale ms', 'volte', 'media ms', 'max ms', 'righe',
      'nome']));
    Testo.Add(''.PadLeft(110, '-'));

    for i := 0 to High(Elenco) do
    begin
      if i >= AMassimeVoci then
        Break;
      Voce := Elenco[i];
      Testo.Add(Format('%-9s %10d %7d %10.0f %10d %10d  %s', [NomeCategoria(Voce.Categoria), Voce.TotaleMs, Voce.Conteggio,
        Voce.MediaMs, Voce.MassimoMs, Voce.RigheTotali, Voce.Nome]));
    end;

    if Length(Elenco) > AMassimeVoci then
    begin
      Testo.Add('');
      Testo.Add(Format('(altre %d operazioni non elencate: sono nel file CSV allegato)', [Length(Elenco) - AMassimeVoci]));
    end;

    // Totali per categoria: indirizzano il sospetto su database, stampe,
    // servizi esterni o interfaccia prima di guardare le singole voci.
    for Voce in Elenco do
    begin
      Categoria := NomeCategoria(Voce.Categoria);
      TotaliCategoria.TryGetValue(Categoria, Totale);
      TotaliCategoria.AddOrSetValue(Categoria, Totale + Voce.TotaleMs);
      ConteggiCategoria.TryGetValue(Categoria, Conteggio);
      ConteggiCategoria.AddOrSetValue(Categoria, Conteggio + Voce.Conteggio);
    end;

    Testo.Add('');
    Testo.Add('TOTALI PER CATEGORIA');
    Testo.Add('');
    Testo.Add(Format('%-9s %12s %10s', ['categoria', 'totale ms', 'volte']));
    Testo.Add(''.PadLeft(35, '-'));
    for Categoria in TotaliCategoria.Keys do
      Testo.Add(Format('%-9s %12d %10d', [Categoria, TotaliCategoria[Categoria], ConteggiCategoria[Categoria]]));

    // Ripetizioni sospette: operazione breve ripetuta molte volte. E' il
    // difetto tipico delle maschere master/dettaglio con i lookup, e non si
    // vede guardando le singole durate.
    Testo.Add('');
    Testo.Add('RIPETIZIONI SOSPETTE (breve ma ripetuta: candidata a essere accorpata)');
    Testo.Add('');
    RipetizioniTrovate := False;
    for Voce in Elenco do
      if (Voce.Conteggio >= 20) and (Voce.MediaMs < 50) and (Voce.Categoria in [coDataSet, coStoredProcedure]) then
      begin
        Testo.Add(Format('%5d volte x %5.0f ms = %8d ms  %s', [Voce.Conteggio, Voce.MediaMs, Voce.TotaleMs, Voce.Nome]));
        RipetizioniTrovate := True;
      end;
    if not RipetizioniTrovate then
      Testo.Add('(nessuna)');

    Testo.Add('');
    Testo.Add(Format('Eventi misurati: %d - sotto la soglia di %d ms: %d - non scritti nel CSV per raggiunto limite di %d righe: %d',
      [FEventiTotali, FSogliaMs, FEventiSottoSoglia, FMassimoRigheCsv, FEventiFuoriCsv]));

    result := Testo.Text;
  finally
    FreeAndNil(ConteggiCategoria);
    FreeAndNil(TotaliCategoria);
    FreeAndNil(Testo);
  end;
end;

initialization

finalization

TzRaccoltaPrestazioni.Libera;

end.
