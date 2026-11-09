// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-02
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Log
//
// Sessione di registrazione avviata dall'utente da una sola voce di menu:
//
//   prima pressione  -> avvia la registrazione su file (SmartInspect) piu'
//                       il CSV delle durate (zDiagnostica.Log.Perf);
//   seconda pressione -> chiude i file, calcola il riepilogo, li raccoglie
//                       in un unico .zip e apre un ticket su MantisBT in
//                       categoria LOG allegando lo zip.
//
// In alternativa la registrazione si puo' chiedere per il PROSSIMO AVVIO
// (RichiediAlProssimoAvvio): serve quando il problema nasce prima che
// l'utente possa premere qualunque cosa (accesso, caricamento del
// dizionario LZ, creazione dei moduli dati). La richiesta e' un file nella
// cartella dei log, con utente Windows e computer nel nome, che il .dpr
// consuma chiamando AvviaAllAvvio prima di creare qualunque modulo.
//
// DUE FILE DI REGISTRO NELLA STESSA SESSIONE
// SmartInspect accetta piu' destinazioni nella stessa stringa di
// connessione, separate da virgola. La sessione ne apre due:
//  - "file": il .sil binario, completo, compresi i blocchi allegati alle
//    voci (LogStringList, LogSql, dataset). E' quello che serve per i
//    difetti di dati e di configurazione (origini dei campi, maschere,
//    dizionario caricato). Si legge con la Console SmartInspect o con
//    log_summary del server MCP zsrc;
//  - "text": il .log di testo, una riga per voce secondo il "pattern".
//    Verificato sul sorgente (TSiTextFormatter): nel testo finisce SOLO il
//    titolo della voce, mai i dati allegati. Per questo le informazioni di
//    sistema si scrivono come titoli (LogString compone "nome = 'valore'"),
//    non con LogSystem. Serve alla lettura veloce e all'analisi automatica.
// Se all'avvio della sessione e' gia' attiva una destinazione "file" (il
// .sil chiesto con -log sulla riga di comando) viene conservata accanto
// alle due della sessione, invece di essere sostituita.
//
// LIMITE DI DIMENSIONE
// Non si usa l'opzione "maxsize" del protocollo: farebbe ruotare il log su
// piu' file numerati e non ci sarebbe piu' un unico file da allegare. Il
// limite lo controlla il battito qui sotto, che chiude la sessione quando
// .sil e .log insieme superano DimensioneMassimaMb. Zippati si riducono di
// 14-20 volte (misurato su registri reali di Gesty).
//
// CARTELLA CONDIVISA
// La cartella dei log sta accanto all'eseguibile, che presso i clienti e'
// spesso su una cartella di rete usata da tutte le postazioni. Per questo
// ogni nome di file porta utente Windows e computer, e le sessioni rimaste
// aperte si propongono solo alla postazione che le ha create.
//
// FILMATO
// Se l'applicazione lo prevede (VideoDisponibile) la finestra delle opzioni
// offre anche il filmato delle finestre del programma (zDiagnostica.Video),
// che si accende solo con il codice dell'assistenza
// (zDiagnostica.Video.Sblocco). Mai dalla scorciatoia o dal prossimo avvio:
// sono avvii senza finestra, e l'utente non avrebbe visto l'avviso. La
// cattura parte dopo AttivaMonitorFireDAC, cosi' la riconnessione al
// database non entra nel filmato. Il filmato si scrive in parti MP4 da 4 MB
// accanto al log; le parti non vanno nello zip (sono gia' compresse e lo
// renderebbero inallegabile): si caricano dopo l'apertura del ticket, in un
// thread, una alla volta. Il ticket con lo zip esiste quindi gia' se l'invio
// del filmato si interrompe. Tutti i file restano su disco anche dopo
// l'invio, e li pulisce EliminaFileVecchi dopo GiorniConservazione giorni.
//
// Unit autonoma: usa RTL, VCL e la famiglia zExceptions (utils, context,
// mantis), non le unit delle applicazioni.
//
// ***************************************************************************

unit zDiagnostica.Log;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  Vcl.ExtCtrls,
  // SmartInspect.Core serve per i tipi TSiLevel e TSiClockResolution: la unit
  // SmartInspect.Vcl li usa ma non li riesporta.
  SmartInspect.Core,
  SmartInspect.Vcl,
  zDiagnostica.Log.Perf,
  zDiagnostica.Video,
  zDiagnostica.Video.Sblocco;

type
  // Richiesta della nota all'utente: False = annulla l'invio.
  TzRichiestaNota = reference to function(out ANota: string): boolean;
  // Richiesta di conferma: False = non procedere.
  TzRichiestaConferma = reference to function(const ATesto: string): boolean;

  // Mantis #183 - 2026-10-08: scelte dell'utente all'avvio dal menu (cosa
  // registrare in piu', cosa fare alla chiusura). AMonitorDisponibile dice se
  // l'applicazione sa accendere il monitor FireDAC (OnMonitorFireDAC
  // assegnato). False = non avviare. Se non assegnata si usa la finestra di
  // zDiagnostica.Log.OpzioniForm.
  TzRichiestaOpzioni = reference to function(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: boolean): boolean;

  // Mantis #183 - 2026-10-08: accensione (AAttiva=True, AFile = file da
  // scrivere nella cartella della sessione) e spegnimento del monitor FireDAC
  // su file. Lo fa l'applicazione: il collegamento al monitor sta nel suo
  // modulo di configurazione e cambiare MonitorBy richiede la riconnessione.
  TzMonitorFireDAC = reference to procedure(AAttiva: boolean; const AFile: string);

  // Da dove arriva il comando. Cambia due cose: la scorciatoia non chiede
  // conferma prima di avviare (chi la premuta sa cosa sta facendo) e i
  // messaggi informativi compaiono come finestra di avviso invece che come
  // dialogo modale, per non interrompere il lavoro in corso.
  TzOrigineComando = (ocMenu, ocScorciatoia);

  TzTipoMessaggio = (tmInformazione, tmAvviso, tmErrore);

  // Consegna di un messaggio informativo. Se assegnato sostituisce del tutto
  // il comportamento predefinito (finestra di avviso o dialogo modale).
  TzMessaggioSessione = reference to procedure(const ATitolo, ATesto: string; ATipo: TzTipoMessaggio);

  // Tempo che manca al primo limite che chiudera' la registrazione o
  // fermera' il filmato. Secondi = -1 quando non c'e' nessuna registrazione.
  // Totale e' la durata complessiva stimata di quel limite (trascorso piu'
  // residuo), per una barra che si svuota; Motivo dice quale limite scatta
  // ("si ferma il filmato: 20 MB").
  TzTempoResiduo = record
    Secondi: Integer;
    Totale: Integer;
    Motivo: string;
  end;

  TzSessioneLog = class
  strict private
    class var FIstanza: TzSessioneLog;
  private
    FAttiva: boolean;
    FIdentificativo: string;
    FFileLog: string;
    FFileSil: string;
    FFileCsv: string;
    FFileMarcatore: string;
    FInizio: TDateTime;
    FConnessioniPrecedenti: string;
    FLivelloPrecedente: TSiLevel;
    FLivelloPredefinitoPrecedente: TSiLevel;
    FRisoluzionePrecedente: TSiClockResolution;
    FBattito: TTimer;
    FUltimoBattito: Cardinal;
    FUltimoCampionamento: Cardinal;
    FGestoreFormAttiva: TNotifyEvent;
    FInterrottaPerLimite: boolean;
    FMotivoInterruzione: string;
    FOrigineCorrente: TzOrigineComando;
    // Sessione partita dal file di richiesta, prima dell'accesso: utente,
    // database e cliente non erano ancora noti e vanno scritti dopo.
    FAvviataAllAvvio: boolean;
    FIdentitaCompletata: boolean;

    FCartellaLog: string;
    FCategoriaMantis: string;
    FSogliaOperazioneLentaMs: Integer;
    FSogliaBloccoMs: Integer;
    FIntervalloCampionamentoSecondi: Integer;
    FDurataMassimaMinuti: Integer;
    FDimensioneMassimaMb: Integer;
    FRegistraValoriParametri: boolean;
    FGiorniConservazione: Integer;
    FTestoScorciatoia: string;
    FTestoScorciatoiaSegnalibro: string;
    FProssimoAvvioNellaProcedura: boolean;

    FOnStatoCambiato: TNotifyEvent;
    FOnChiediNota: TzRichiestaNota;
    FOnChiediConferma: TzRichiestaConferma;
    FOnMessaggio: TzMessaggioSessione;

    // Mantis #183 - 2026-10-08: scelte della sessione in corso e file del
    // monitor FireDAC (vuoto se spento).
    FOpzioni: TzOpzioniRegistrazione;
    FFileMonitor: string;
    // File rimasti fuori dallo zip perche' ancora aperti da un altro
    // processo, con il motivo: li riporta la descrizione del ticket.
    FFileFuoriArchivio: TArray<string>;
    FOnChiediOpzioni: TzRichiestaOpzioni;
    FOnMonitorFireDAC: TzMonitorFireDAC;

    // Filmato (zDiagnostica.Video). FRegistratore esiste solo mentre il
    // filmato registra; FPartiVideo e FStatisticheVideo restano dopo la
    // fermata, per il riepilogo e l'invio.
    FVideoDisponibile: boolean;
    FDurataMassimaVideoMinuti: Integer;
    FDimensioneMassimaVideoMb: Integer;
    FRegistratore: TzRegistratoreVideo;
    FInizioVideo: TDateTime;
    FPartiScritte: Integer;
    FPartiVideo: TArray<string>;
    FStatisticheVideo: TzStatisticheVideo;
    FMotivoFermoVideo: string;
    FSblocco: TzSbloccoVideo;
    FCodiceVideo: string;
    FSbloccoVideoAlle: TDateTime;

    // Crescita dei file nell'ultimo intervallo di misura, in MB al secondo:
    // serve a stimare quando scattano i limiti di dimensione.
    FMisuraTick: Cardinal;
    FMisuraLogMb: Double;
    FMisuraVideoMb: Double;
    FCrescitaLog: Double;
    FCrescitaVideo: Double;
    FAvvisoLimiteDato: boolean;

    // Invio delle parti del filmato dopo l'apertura del ticket (TThread).
    FInvio: TThread;

    function CartellaEffettiva: string;
    function NomePostazione: string;
    function NuovoIdentificativo: string;
    function FileRichiestaAvvio: string;
    function StringaConnessioni: string;
    function AvviaRegistrazione(AOrigine: TzOrigineComando): boolean;
    procedure ScriviIntestazione;
    procedure ScriviIdentita;
    procedure ScriviContesto(const ATitolo: string);
    procedure ScriviRiepilogo;
    procedure ScriviMarcatore;
    procedure RimuoviMarcatore;
    procedure ChiudiSessione(const ARimuoviMarcatore: boolean);
    procedure EliminaFileVecchi;
    procedure AvviaBattito;
    procedure FermaBattito;
    procedure BattitoScattato(Sender: TObject);
    procedure FormAttivaCambiata(Sender: TObject);
    procedure CampionaRisorse;
    function DimensioneRegistriMb: Double;
    function DescrizioneTicket(const ANota, AArchivio: string; const APartiVideo: TArray<string>): string;
    function OggettoTicket: string;
    function ChiediConferma(const ATesto: string): boolean;
    function ChiediNota(out ANota: string): boolean;
    function ChiediOpzioni(var AOpzioni: TzOpzioniRegistrazione; out AProssimoAvvio: boolean): boolean;
    function ScriviRichiestaAvvio(const AOpzioni: TzOpzioniRegistrazione; AConOpzioni: boolean): boolean;
    function AnnullaRichiestaAvvio: boolean;
    procedure AttivaMonitorFireDAC;
    procedure DisattivaMonitorFireDAC;
    procedure Mostra(const ATitolo, ATesto: string; ATipo: TzTipoMessaggio);
    procedure NotificaStato;
    function CreaArchivio(const AIdentificativo: string; const AFile: array of string): string;
    function InviaAMantis(const ANota: string; const AFileLog, AFileSil, AFileCsv: string;
      const AFileMonitor: string = ''; const APartiVideo: TArray<string> = nil): boolean;
    procedure AvviaVideo;
    procedure FermaVideo(const AMotivo: string);
    procedure RegistraPartiNuove;
    procedure ControllaVideo;
    procedure MisuraCrescita;
    procedure AvvisaLimiteImminente;
    function DimensioneVideoMb: Double;
    function StimaVideo: string;
    procedure AvviaInvioParti(ANumeroTicket: Integer; const AParti: TArray<string>);
    procedure InvioTerminato(Sender: TObject);
    function GetPausaVideo: boolean;
    procedure SetPausaVideo(const AValore: boolean);
    function GetVideoAttivo: boolean;
    function GetInvioInCorso: boolean;
  public
    class function Istanza: TzSessioneLog;
    class procedure Libera;

    constructor Create;
    destructor Destroy; override;

    // Unico metodo che serve alla voce di menu e alla scorciatoia globale:
    // avvia, oppure chiude e segnala.
    procedure Commuta(AOrigine: TzOrigineComando = ocMenu);

    function Avvia(AOrigine: TzOrigineComando = ocMenu): boolean;
    function TerminaESegnala(AOrigine: TzOrigineComando = ocMenu): boolean;
    // Chiude la registrazione senza aprire il ticket (i file restano su disco).
    procedure Annulla;

    // Chiusura ordinata quando l'applicazione termina con la registrazione
    // ancora attiva: scrive il riepilogo e chiude i file, ma lascia il
    // marcatore .inCorso, cosi' al prossimo avvio VerificaSessioneInterrotta
    // propone di inviare la sessione. Va chiamata dal .dpr prima di
    // ExitProcess, che salta le finalization delle unit: senza questa
    // chiamata la sessione restava senza riepilogo.
    procedure ChiudiPerTerminazione;

    // Marcatore "qui e' lento" da agganciare a una scorciatoia da tastiera.
    procedure InserisciSegnalibro(const ATesto: string = ''; AOrigine: TzOrigineComando = ocMenu);

    // Da chiamare dopo l'accesso, con la finestra principale aperta:
    //  - se la registrazione e' partita dall'avvio, completa l'intestazione
    //    con utente, database e cliente (prima non erano noti) e avvisa
    //    l'utente che la registrazione e' in corso;
    //  - altrimenti, se una sessione precedente di questa postazione e'
    //    stata interrotta dalla chiusura dell'applicazione, propone di
    //    inviarla.
    procedure VerificaSessioneInterrotta;

    // Richiesta di registrazione dal prossimo avvio. Scrive (o, se c'e'
    // gia', toglie) il file di richiesta di questa postazione: un comando
    // solo per chiedere e per annullare, come Commuta.
    procedure CommutaRichiestaAvvio;
    // True se questa postazione ha una richiesta in attesa del prossimo avvio.
    function RichiestaAvvioPresente: boolean;

    // Da chiamare nel .dpr subito dopo si.Enabled := True, prima di creare
    // qualunque modulo: se trova il file di richiesta di questa postazione
    // lo cancella (la richiesta vale per un avvio soltanto) e avvia la
    // registrazione senza chiedere niente. Il controllo dei parametri di
    // Mantis qui non si fa: arrivano da una tabella del database e prima
    // dell'accesso non sono noti. Si rifa' alla chiusura, in InviaAMantis.
    function AvviaAllAvvio: boolean;

    // Didascalia e suggerimento per le voci di menu, coerenti con lo stato.
    function DidascaliaVoceMenu: string;
    function SuggerimentoVoceMenu: string;
    function DidascaliaVoceAvvio: string;
    function SuggerimentoVoceAvvio: string;

    // True quando la segnalazione e' possibile, cioe' quando i parametri di
    // collegamento a Mantis sono configurati. La voce di menu e la scorciatoia
    // vanno tenute nascoste quando e' False: il log si potrebbe registrare,
    // ma non ci sarebbe nessun posto dove mandarlo e l'utente resterebbe con
    // due file su disco e nessuna istruzione.
    // Va riletto dopo il collegamento al database: i parametri arrivano da
    // una tabella, non sono noti prima dell'accesso.
    function Disponibile: boolean;

    // Tempo che manca al primo limite (durata o dimensione del log, durata o
    // dimensione del filmato). Vale per WT e Gesty: l'applicazione si limita
    // a mostrarlo, per esempio in una barra che si svuota.
    function TempoResiduo: TzTempoResiduo;
    // True sotto i 2 minuti dal primo limite.
    function LimiteImminente: boolean;
    // Secondi dall'inizio della registrazione in corso, 0 se non ce n'e'.
    function DurataSecondi: Integer;

    // Testo per l'indicatore dell'invio delle parti del filmato ("parte 2 di
    // 3"), vuoto se non c'e' nessun invio in corso.
    function TestoInvio: string;
    // Interrompe l'invio delle parti dopo quella in corso: le altre restano
    // su disco e il messaggio finale dice dove.
    procedure InterrompiInvio;

    property Attiva: boolean read FAttiva;
    property AvviataAllAvvio: boolean read FAvviataAllAvvio;
    property Identificativo: string read FIdentificativo;
    property FileLog: string read FFileLog;
    property FileSil: string read FFileSil;
    property FileCsv: string read FFileCsv;
    // Mantis #183 - 2026-10-08: traccia FireDAC della sessione, vuoto se il
    // monitor non e' stato acceso.
    property FileMonitor: string read FFileMonitor;
    property Inizio: TDateTime read FInizio;
    // Scelte fatte all'avvio della sessione in corso (predefinite se la
    // sessione e' partita dalla scorciatoia o dal file di richiesta).
    property Opzioni: TzOpzioniRegistrazione read FOpzioni;

    // Cartella dei file di sessione. Vuota = quella di zExceptionManager
    // (sottocartella "log" accanto all'eseguibile).
    property CartellaLog: string read FCartellaLog write FCartellaLog;
    // Categoria del ticket. Deve GIA' esistere nel progetto Mantis: la REST
    // API di MantisBT non crea categorie, altrimenti si ripiega in silenzio
    // sulla categoria predefinita dei parametri di connessione.
    property CategoriaMantis: string read FCategoriaMantis write FCategoriaMantis;
    property SogliaOperazioneLentaMs: Integer read FSogliaOperazioneLentaMs write FSogliaOperazioneLentaMs;
    property SogliaBloccoMs: Integer read FSogliaBloccoMs write FSogliaBloccoMs;
    property IntervalloCampionamentoSecondi: Integer read FIntervalloCampionamentoSecondi
      write FIntervalloCampionamentoSecondi;
    property DurataMassimaMinuti: Integer read FDurataMassimaMinuti write FDurataMassimaMinuti;
    // Limite sulla somma di .sil e .log, prima della compressione.
    property DimensioneMassimaMb: Integer read FDimensioneMassimaMb write FDimensioneMassimaMb;
    // False = nel log non finiscono SQL e valori dei parametri. Il ticket e'
    // visibile ad altri e i parametri contengono dati personali.
    property RegistraValoriParametri: boolean read FRegistraValoriParametri write FRegistraValoriParametri;
    property GiorniConservazione: Integer read FGiorniConservazione write FGiorniConservazione;
    // Compare nei messaggi all'utente: va tenuto uguale alla combinazione
    // agganciata davvero in ApplicationEventsShortCut.
    property TestoScorciatoia: string read FTestoScorciatoia write FTestoScorciatoia;
    // 2026-10-29: combinazione del segnalibro, citata nella pagina finale
    // della procedura guidata; vuota = non si cita.
    property TestoScorciatoiaSegnalibro: string read FTestoScorciatoiaSegnalibro write FTestoScorciatoiaSegnalibro;
    // 2026-10-29: True = la prenotazione al prossimo avvio sta nella pagina
    // finale della procedura guidata (con le opzioni e la nota scelte li') e
    // l'applicazione non ha piu' la voce di menu: con una prenotazione in
    // attesa, l'avvio dal menu offre di annullarla. False (WT, zTicser) =
    // come prima, con CommutaRichiestaAvvio dalla voce di menu.
    property ProssimoAvvioNellaProcedura: boolean read FProssimoAvvioNellaProcedura
      write FProssimoAvvioNellaProcedura;

    property OnStatoCambiato: TNotifyEvent read FOnStatoCambiato write FOnStatoCambiato;
    property OnChiediNota: TzRichiestaNota read FOnChiediNota write FOnChiediNota;
    property OnChiediConferma: TzRichiestaConferma read FOnChiediConferma write FOnChiediConferma;
    property OnMessaggio: TzMessaggioSessione read FOnMessaggio write FOnMessaggio;
    // Mantis #183 - 2026-10-08: finestra delle opzioni all'avvio dal menu
    // (predefinita: zDiagnostica.Log.OpzioniForm) e aggancio del monitor
    // FireDAC. Senza OnMonitorFireDAC la casella del monitor resta disabilitata.
    property OnChiediOpzioni: TzRichiestaOpzioni read FOnChiediOpzioni write FOnChiediOpzioni;
    property OnMonitorFireDAC: TzMonitorFireDAC read FOnMonitorFireDAC write FOnMonitorFireDAC;

    // True = l'applicazione prevede il filmato: la finestra delle opzioni
    // mostra la casella. Predefinito False, cosi' le applicazioni che non lo
    // abilitano (WT) non vedono niente di nuovo. Con OnChiediOpzioni
    // assegnato il filmato non si offre: la finestra e' dell'applicazione.
    property VideoDisponibile: boolean read FVideoDisponibile write FVideoDisponibile;
    // Oltre uno dei due limiti si ferma solo il filmato: il log continua fino
    // ai suoi limiti. Durata in tempo vero, pause comprese.
    property DurataMassimaVideoMinuti: Integer read FDurataMassimaVideoMinuti write FDurataMassimaVideoMinuti;
    property DimensioneMassimaVideoMb: Integer read FDimensioneMassimaVideoMb write FDimensioneMassimaVideoMb;
    // Sospende la cattura del filmato senza fermare il log (riservatezza:
    // una schermata che l'utente non vuole mandare). Nel log VIDEO.pausa e
    // VIDEO.ripresa con l'ora.
    property PausaVideo: boolean read GetPausaVideo write SetPausaVideo;
    // True mentre il filmato registra (anche in pausa).
    property VideoAttivo: boolean read GetVideoAttivo;
    property InvioInCorso: boolean read GetInvioInCorso;
  end;

function SessioneLog: TzSessioneLog;

implementation

uses
  Winapi.Windows,
  Winapi.MultiMon,
  Winapi.PsAPI,
  System.IOUtils,
  System.DateUtils,
  System.Zip,
  System.Math,
  System.IniFiles,
  System.Diagnostics,
  System.NetEncoding,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Controls,
  SmartInspect.Vcl.SiAuto,
  zDX, // dx.Alert: finestra di avviso non modale
  zMsg, // dialoghi con l'aspetto DevExpress usato dalle due applicazioni
  zExceptions,
  zExceptions.utils,
  zExceptions.context,
  zExceptions.mantis,
  zDiagnostica.Log.OpzioniForm; // Mantis #183: finestra predefinita delle opzioni

const
  // Una riga per voce: istante, livello, thread, sessione, titolo.
  PatternTesto = '%timestamp% | %level% | %thread% | %session% | %title%';

  EstensioneLog = '.log';
  EstensioneSil = '.sil';
  EstensioneCsv = '-perf.csv';
  EstensioneMonitor = '-firedac.txt'; // Mantis #183: traccia del monitor FireDAC
  EstensioneZip = '.zip';
  EstensioneMarcatore = '.inCorso';
  EstensioneRichiesta = '.richiesta';
  PrefissoRichiesta = 'LOG-avvio-';

  // Istruzioni per chi analizzera' il ticket: viaggiano nella descrizione
  // cosi' l'analisi non va riformulata ogni volta.
  IstruzioniAnalisi = 'ISTRUZIONI PER L''ANALISI' + sLineBreak + sLineBreak +
    '0. L''allegato .zip contiene tre file della stessa sessione: il .sil (registro SmartInspect completo,' +
    sLineBreak + '   compresi i blocchi allegati alle voci: si legge con log_summary del server MCP zsrc o con la' +
    sLineBreak + '   Console SmartInspect), il .log (stesso registro in testo, solo i titoli delle voci) e il -perf.csv.' +
    sLineBreak + '   Per difetti di dati o di configurazione parti dal .sil; per la lentezza dal -perf.csv.' + sLineBreak +
    '1. Leggi l''allegato -perf.csv: una riga per operazione misurata, campi separati da punto e virgola' + sLineBreak +
    '   (istante;categoria;nome;ms;righe;modulo;dettaglio).' + sLineBreak +
    '2. Somma e ordina per "nome" dentro ogni "categoria": contano le ripetizioni, non solo le durate. Una query' +
    sLineBreak + '   da 20 ms eseguita 400 volte pesa piu'' di una query da 3 secondi eseguita una volta sola.' +
    sLineBreak + '3. Confronta il risultato con la sezione OPERAZIONI PIU COSTOSE qui sotto, calcolata' + sLineBreak +
    '   dall''applicazione: se non coincide, fidati del CSV e spiega la differenza.' + sLineBreak +
    '4. Per le SQL sospette prendi il testo dalla colonna "dettaglio" e chiedi il piano di esecuzione al server' +
    sLineBreak + '   MCP firebird (get_query_plan), poi valuta indici e selettivita''.' + sLineBreak +
    '5. Le righe di categoria "blocco" sono i momenti in cui l''interfaccia non ha risposto, con il modulo attivo' +
    sLineBreak + '   in quel momento; le righe "segnalibro" sono i punti segnati dall''utente; le righe "risorse"' +
    sLineBreak + '   servono a vedere se memoria e handle crescono senza tornare indietro.' + sLineBreak +
    '6. Nel .log e nel .sil c''e'' la cronologia completa: le righe META.* in testa dicono versione, database,' +
    sLineBreak + '   utente e computer. Se META.avvio = "dal prossimo avvio" la registrazione copre anche l''accesso e il' +
    sLineBreak + '   caricamento del dizionario LZ, e utente e database compaiono in un secondo blocco META dopo l''accesso.' +
    sLineBreak + '7. Gli allegati -video-NN.mp4, se ci sono, sono il filmato delle finestre del programma, caricato dopo lo' +
    sLineBreak + '   zip: le altre applicazioni sono nere. L''ora vera e'' stampata in basso a sinistra e si confronta con' +
    sLineBreak + '   il log; i tratti di schermo fermo oltre 2 secondi durano 1 secondo nel filmato, e un cerchio giallo' +
    sLineBreak + '   segna i clic. Le righe VIDEO.* del log dicono quando e'' iniziata ogni parte e quando era in pausa.';

  // Filmato: limite delle parti (Mantis con i valori predefiniti accetta
  // 5.000.000 byte per file e 8 MB per richiesta, e il base64 del JSON pesa
  // 1,37 volte il file) e fattore del base64 per la stima del tempo di invio.
  FattoreBase64 = 1.37;
  // Velocita' di invio usata finche' la postazione non ne ha misurata una:
  // 1 Mbit/s, prudente per una linea d'ufficio.
  BytePerSecondoPrudenti = 125000;
  // Velocita' minima ammessa per calcolare il tempo massimo di una richiesta:
  // 0,5 Mbit/s. Sotto, la parte si considera non inviata.
  BytePerSecondoMinimi = 62500;
  // Ogni quanto si misura la crescita dei file per stimare i limiti.
  IntervalloMisuraCrescitaMs = 30000;

function DimensioneFile(const ANomeFile: string): Int64; forward;

// Impostazioni della postazione (velocita' di invio misurata, peso medio
// del filmato): in %LOCALAPPDATA% e non nella cartella dei log, che spesso
// e' condivisa in rete fra postazioni con linee diverse.
function FileImpostazioniLocali: string;
begin
  result := TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'zDiagnostica');
  ForceDirectories(result);
  result := TPath.Combine(result, 'Registrazione.ini');
end;

function LeggiImpostazioneLocale(const ASezione, AChiave: string; ADefault: Int64): Int64;
var
  Impostazioni: TIniFile;
begin
  result := ADefault;
  try
    Impostazioni := TIniFile.Create(FileImpostazioniLocali);
    try
      result := StrToInt64Def(Impostazioni.ReadString(ASezione, AChiave, ''), ADefault);
    finally
      FreeAndNil(Impostazioni);
    end;
  except
  end;
end;

procedure ScriviImpostazioneLocale(const ASezione, AChiave: string; AValore: Int64);
var
  Impostazioni: TIniFile;
begin
  try
    Impostazioni := TIniFile.Create(FileImpostazioniLocali);
    try
      Impostazioni.WriteString(ASezione, AChiave, AValore.ToString);
    finally
      FreeAndNil(Impostazioni);
    end;
  except
  end;
end;

// Velocita' di invio di questa postazione, l'ultima misurata.
function BytePerSecondoInvio(out AMisurata: boolean): Int64;
begin
  result := LeggiImpostazioneLocale('Invio', 'BytePerSecondo', 0);
  AMisurata := result > 0;
  if not AMisurata then
    result := BytePerSecondoPrudenti;
end;

procedure RegistraVelocitaInvio(AByte: Int64; AMillisecondi: Int64);
begin
  // Invii troppo piccoli o troppo rapidi misurano la latenza, non la linea.
  if (AByte < 200 * 1024) or (AMillisecondi < 500) then
    Exit;
  ScriviImpostazioneLocale('Invio', 'BytePerSecondo', Round(AByte * FattoreBase64 / (AMillisecondi / 1000)));
end;

function TestoDurata(ASecondi: Int64): string;
begin
  if ASecondi < 60 then
    result := Format('%d s', [ASecondi])
  else if ASecondi < 3600 then
    result := Format('%d min %d s', [ASecondi div 60, ASecondi mod 60])
  else
    result := Format('%d h %d min', [ASecondi div 3600, (ASecondi mod 3600) div 60]);
end;

// ZC 30.10.2026: prima il contesto si raccoglieva senza form ne' controllo, e
// il ticket diceva "nessuna form catturata al momento dell'eccezione" anche con
// una form aperta e nessuna eccezione. Ora si passano la form attiva e il
// controllo col focus; nelle applicazioni MDI la form attiva e' la principale,
// quindi si prende la finestra figlia in primo piano.
function ContestoAttuale: string;
var
  Form: TCustomForm;
begin
  Form := Screen.ActiveCustomForm;
  if (Form is TForm) and (TForm(Form).FormStyle = fsMDIForm) and (TForm(Form).ActiveMDIChild <> nil) then
    Form := TForm(Form).ActiveMDIChild;
  result := CollectRuntimeContext(Form, Screen.ActiveControl);
end;

function TestoMb(AByte: Double): string;
begin
  result := FormatFloat('0.0', AByte / 1024 / 1024) + ' MB';
end;

function TestoParti(ANumero: Integer): string;
begin
  if ANumero = 1 then
    result := '1 parte'
  else
    result := Format('%d parti', [ANumero]);
end;

function SecondiDiInvio(AByte: Double): Int64;
var
  Misurata: boolean;
begin
  result := Ceil(AByte * FattoreBase64 / BytePerSecondoInvio(Misurata));
end;

type
  // Invio delle parti del filmato a un ticket gia' aperto. Lavora solo sui
  // propri dati: la sessione legge ParteCorrente e il resto dopo la fine,
  // nel thread principale (OnTerminate).
  TzInvioPartiVideo = class(TThread)
  private
    FParametri: TMantisServerParams;
    FTicket: Integer;
    FSessione: string;
    FParti: TArray<string>;
    FParteCorrente: Integer;
    FInviate: TArray<string>;
    FNonInviate: TArray<string>;
    FErrori: TArray<string>;
  protected
    procedure Execute; override;
  public
    constructor Create(const AParametri: TMantisServerParams; ATicket: Integer; const ASessione: string;
      const AParti: TArray<string>);
    property Ticket: Integer read FTicket;
    property Parti: TArray<string> read FParti;
    property ParteCorrente: Integer read FParteCorrente;
    property Inviate: TArray<string> read FInviate;
    property NonInviate: TArray<string> read FNonInviate;
    property Errori: TArray<string> read FErrori;
  end;

constructor TzInvioPartiVideo.Create(const AParametri: TMantisServerParams; ATicket: Integer; const ASessione: string;
  const AParti: TArray<string>);
begin
  inherited Create(True);
  FParametri := AParametri;
  FTicket := ATicket;
  FSessione := ASessione;
  FParti := AParti;
  // Si libera da solo dopo OnTerminate: la sessione toglie il riferimento
  // in OnTerminate, che gira nel thread principale prima della liberazione.
  FreeOnTerminate := True;
end;

procedure TzInvioPartiVideo.Execute;
var
  Indice: Integer;
  Parte: string;
  Dimensione: Int64;
  TempoMassimoMs: Integer;
  Orologio: TStopwatch;
  Nota: TStringList;
begin
  NameThreadForDebugging('zDiagnostica.Log.InvioFilmato');
  for Indice := 0 to High(FParti) do
  begin
    Parte := FParti[Indice];
    if Terminated then
    begin
      FNonInviate := FNonInviate + [Parte];
      Continue;
    end;
    FParteCorrente := Indice + 1;
    Dimensione := DimensioneFile(Parte);
    // Tempo massimo dalla dimensione alla velocita' minima ammessa, invece
    // dei 30 secondi fissi, che non bastano per 5,5 MB sotto 1,5 Mbit/s.
    TempoMassimoMs := Max(30000, Round(Dimensione * FattoreBase64 / BytePerSecondoMinimi * 1000) + 15000);
    Orologio := TStopwatch.StartNew;
    try
      AllegaATicketMantis(FParametri, FTicket, Parte, TempoMassimoMs);
      FInviate := FInviate + [Parte];
      RegistraVelocitaInvio(Dimensione, Orologio.ElapsedMilliseconds);
    except
      on E: Exception do
      begin
        FNonInviate := FNonInviate + [Parte];
        FErrori := FErrori + [ExtractFileName(Parte) + ': ' + E.Message];
      end;
    end;
  end;

  // La nota dice cosa e' arrivato: chi apre il ticket vede subito se il
  // filmato e' completo, senza contare gli allegati.
  if Length(FInviate) = 0 then
    Exit;
  Nota := TStringList.Create;
  try
    Nota.Add(Format('Filmato della sessione %s: allegate %d su %s.', [FSessione, Length(FInviate),
      TestoParti(Length(FParti))]));
    for Parte in FInviate do
      Nota.Add(Format('- %s (%s)', [ExtractFileName(Parte), TestoMb(DimensioneFile(Parte))]));
    if Length(FNonInviate) > 0 then
    begin
      Nota.Add('Non inviate, rimaste sulla postazione:');
      for Parte in FNonInviate do
        Nota.Add('- ' + ExtractFileName(Parte));
    end;
    try
      AggiungiNotaATicketMantis(FParametri, FTicket, Nota.Text);
    except
    end;
  finally
    FreeAndNil(Nota);
  end;
end;

function SessioneLog: TzSessioneLog;
begin
  result := TzSessioneLog.Istanza;
end;

// Dimensione di un file senza aprirlo: il log e' tenuto aperto da
// SmartInspect e un TFileStream potrebbe non ottenere la condivisione.
function DimensioneFile(const ANomeFile: string): Int64;
var
  Attributi: TWin32FileAttributeData;
begin
  result := 0;
  if ANomeFile = '' then
    Exit;
  if not GetFileAttributesEx(PChar(ANomeFile), GetFileExInfoStandard, @Attributi) then
    Exit;
  result := Int64(Attributi.nFileSizeHigh) shl 32 + Attributi.nFileSizeLow;
end;

function DimensioneTotale(const AFile: TArray<string>): Int64;
var
  Nome: string;
begin
  result := 0;
  for Nome in AFile do
    Inc(result, DimensioneFile(Nome));
end;

// True se il file e' ancora aperto in scrittura da un altro processo: e' il
// caso di una seconda istanza dell'applicazione, sulla stessa postazione, con
// la registrazione ancora in corso. La sua sessione non va toccata.
function FileInUso(const ANomeFile: string): boolean;
var
  Flusso: TFileStream;
begin
  result := False;
  if (ANomeFile = '') or not TFile.Exists(ANomeFile) then
    Exit;
  try
    Flusso := TFileStream.Create(ANomeFile, fmOpenRead or fmShareExclusive);
    Flusso.Free;
  except
    result := True;
  end;
end;

// True se il file MP4 ha l'atomo 'moov' fra quelli di primo livello. Il
// codificatore di Media Foundation lo scrive solo alla chiusura della parte:
// la parte che si stava scrivendo quando l'applicazione e' terminata non lo
// ha e nessun lettore la apre.
function FilmatoCompleto(const ANomeFile: string): boolean;
var
  Flusso: TFileStream;
  Intestazione: array[0..7] of Byte;
  Esteso: array[0..7] of Byte;
  Dimensione: Int64;
  Tipo: AnsiString;
  Indice: Integer;
begin
  result := False;
  try
    Flusso := TFileStream.Create(ANomeFile, fmOpenRead or fmShareDenyWrite);
    try
      while Flusso.Position + 8 <= Flusso.Size do
      begin
        Flusso.ReadBuffer(Intestazione, 8);
        Dimensione := (Int64(Intestazione[0]) shl 24) or (Intestazione[1] shl 16) or (Intestazione[2] shl 8) or
          Intestazione[3];
        SetString(Tipo, PAnsiChar(@Intestazione[4]), 4);
        if Tipo = 'moov' then
          Exit(True);
        // Dimensione 1: la vera dimensione sta nei 64 bit che seguono;
        // dimensione 0: l'atomo arriva fino alla fine del file.
        if Dimensione = 1 then
        begin
          if Flusso.Position + 8 > Flusso.Size then
            Exit;
          Flusso.ReadBuffer(Esteso, 8);
          Dimensione := 0;
          for Indice := 0 to 7 do
            Dimensione := (Dimensione shl 8) or Esteso[Indice];
          if Dimensione < 16 then
            Exit;
          Flusso.Position := Flusso.Position - 16 + Dimensione;
        end
        else if (Dimensione = 0) or (Dimensione < 8) then
          Exit
        else
          Flusso.Position := Flusso.Position - 8 + Dimensione;
      end;
    finally
      FreeAndNil(Flusso);
    end;
  except
    result := False;
  end;
end;

// Parti del filmato di una sessione rimaste sul disco, in ordine. I nomi
// sono fissi (<sessione>-video-NN.mp4), quindi non serve scriverli nel
// marcatore. Le parti incomplete (vedi FilmatoCompleto) vanno in AEscluse.
function PartiFilmatoSuDisco(const ACartella, ASessione: string; out AEscluse: TArray<string>): TArray<string>;
var
  Elenco: TStringList;
  Nome: string;
begin
  result := nil;
  AEscluse := nil;
  if not TDirectory.Exists(ACartella) then
    Exit;
  Elenco := TStringList.Create;
  try
    for Nome in TDirectory.GetFiles(ACartella, ASessione + '-video-*.mp4') do
      Elenco.Add(Nome);
    Elenco.Sort;
    for Nome in Elenco do
      if (DimensioneFile(Nome) > 0) and FilmatoCompleto(Nome) then
        result := result + [Nome]
      else
        AEscluse := AEscluse + [Nome];
  finally
    FreeAndNil(Elenco);
  end;
end;

// Riduce un testo ai caratteri sicuri in un nome di file: utente e computer
// finiscono nel nome, e un nome utente di dominio o con spazi non deve
// produrre un percorso non valido.
function PerNomeFile(const ATesto: string): string;
var
  Carattere: Char;
begin
  result := '';
  for Carattere in ATesto.Trim do
    if CharInSet(Carattere, ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.']) then
      result := result + Carattere
    else
      result := result + '_';
  if result = '' then
    result := 'sconosciuto';
end;

// Scrive una voce nel log della sessione. Il titolo e' l'unica parte che il
// protocollo "text" scrive su file.
procedure Traccia(const ATitolo: string);
begin
  SmartInspect.Vcl.SiAuto.SiMain.LogMessage(ATitolo);
end;

procedure TracciaValore(const ANome, AValore: string);
begin
  SmartInspect.Vcl.SiAuto.SiMain.LogString(ANome, AValore);
end;

{ TzSessioneLog }

class function TzSessioneLog.Istanza: TzSessioneLog;
begin
  if FIstanza = nil then
    FIstanza := TzSessioneLog.Create;
  result := FIstanza;
end;

class procedure TzSessioneLog.Libera;
begin
  FreeAndNil(FIstanza);
end;

constructor TzSessioneLog.Create;
begin
  inherited Create;
  FCategoriaMantis := 'LOG';
  FSogliaOperazioneLentaMs := 300;
  FSogliaBloccoMs := 1500;
  FIntervalloCampionamentoSecondi := 15;
  FDurataMassimaMinuti := 120;
  FDimensioneMassimaMb := 40;
  // Mantis non indicato - 2026-11-01: i valori dei parametri sono dati personali, di norma non si registrano
  FRegistraValoriParametri := False;
  FGiorniConservazione := 30;
  FTestoScorciatoia := 'Ctrl+Shift+L';
  FVideoDisponibile := False;
  FDurataMassimaVideoMinuti := 15;
  FDimensioneMassimaVideoMb := 20;
end;

destructor TzSessioneLog.Destroy;
begin
  // Distruzione con la registrazione attiva: l'applicazione sta terminando
  // senza che l'utente l'abbia chiusa, quindi il marcatore resta.
  if FAttiva then
    ChiudiSessione(False);
  // Invio del filmato ancora in corso alla chiusura dell'applicazione: non
  // si aspetta la parte in viaggio (potrebbe durare minuti) e il thread non
  // deve piu' richiamare la sessione. Le parti restano su disco.
  if FInvio <> nil then
  begin
    FInvio.OnTerminate := nil;
    FInvio.Terminate;
    FInvio := nil;
  end;
  FreeAndNil(FSblocco);
  FreeAndNil(FBattito);
  inherited;
end;

// Riconverte la data scritta nel marcatore, che usa sempre il formato
// yyyy-mm-dd hh:nn:ss indipendentemente dalle impostazioni locali.
function DataDaMarcatore(const ATesto: string; ADefault: TDateTime): TDateTime;
var
  Formato: TFormatSettings;
begin
  Formato := TFormatSettings.Create;
  Formato.DateSeparator := '-';
  Formato.TimeSeparator := ':';
  Formato.ShortDateFormat := 'yyyy-mm-dd';
  Formato.ShortTimeFormat := 'hh:nn:ss';
  result := StrToDateTimeDef(ATesto, ADefault, Formato);
end;

// 2026-10-29: nota dell'utente nel marcatore, in Base64 UTF-8 senza a capo
// (CharsPerLine 0), perche' il marcatore ha una voce nome=valore per riga.
function NotaPerMarcatore(const ANota: string): string;
var
  Codifica: TBase64Encoding;
begin
  Codifica := TBase64Encoding.Create(0);
  try
    result := Codifica.EncodeBytesToString(TEncoding.UTF8.GetBytes(ANota));
  finally
    FreeAndNil(Codifica);
  end;
end;

// Vuota se la voce manca (marcatori scritti prima del 2026-10-29) o non si
// riesce a decodificare: in quel caso la nota si richiede come prima.
function NotaDaMarcatore(const ATesto: string): string;
var
  Codifica: TBase64Encoding;
begin
  result := '';
  if ATesto.Trim = '' then
    Exit;
  Codifica := TBase64Encoding.Create(0);
  try
    try
      result := TEncoding.UTF8.GetString(Codifica.DecodeStringToBytes(ATesto));
    except
      result := '';
    end;
  finally
    FreeAndNil(Codifica);
  end;
end;

function TzSessioneLog.CartellaEffettiva: string;
begin
  result := FCartellaLog;
  if result.Trim.IsEmpty then
    result := TzExceptionManager.LogFolder;
  if result.Trim.IsEmpty then
    result := TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'log');
  result := IncludeTrailingPathDelimiter(result);
  ForceDirectories(result);
end;

// Utente Windows e computer. Si usa l'utente Windows e non quello
// dell'applicazione perche' il file di richiesta si legge all'avvio, prima
// dell'accesso, quando l'utente dell'applicazione non e' ancora noto. Il
// computer serve perche' piu' postazioni possono usare lo stesso account
// Windows generico e la stessa cartella di rete.
function TzSessioneLog.NomePostazione: string;
begin
  result := PerNomeFile(SysUserName) + '-' + PerNomeFile(ComputerName);
end;

function TzSessioneLog.NuovoIdentificativo: string;
begin
  result := 'LOG-' + FormatDateTime('yyyymmdd-hhnnss', now) + '-' + NomePostazione;
end;

function TzSessioneLog.FileRichiestaAvvio: string;
begin
  result := CartellaEffettiva + PrefissoRichiesta + NomePostazione + EstensioneRichiesta;
end;

function TzSessioneLog.StringaConnessioni: string;
begin
  // Due destinazioni: il .sil completo e il .log di testo. Niente "maxsize",
  // che spezzerebbe i registri su piu' file numerati (vedi nota in testa).
  result := Format('file(filename="%s", append="false"), ' +
    'text(filename="%s", append="false", indent="true", pattern="%s")', [FFileSil, FFileLog, PatternTesto]);

  // Un .sil chiesto con -log sulla riga di comando resta attivo accanto a
  // quelli della sessione: sostituirlo lo lascerebbe vuoto proprio nel tratto
  // registrato. La destinazione predefinita di SiAuto ("pipe", verso la
  // Console) invece non si conserva: presso i clienti la Console non c'e'.
  if FConnessioniPrecedenti.ToLower.Contains('file(') then
    result := FConnessioniPrecedenti + ', ' + result;
end;

function TzSessioneLog.ChiediConferma(const ATesto: string): boolean;
begin
  if Assigned(FOnChiediConferma) then
    result := FOnChiediConferma(ATesto)
  else
    result := ConfirmYesNo(ATesto, mtConfirmation);
end;

function TzSessioneLog.ChiediNota(out ANota: string): boolean;
var
  Nota: string;
begin
  ANota := '';
  if Assigned(FOnChiediNota) then
    Exit(FOnChiediNota(ANota));

  Nota := '';
  result := InputString('Segnalazione per l''assistenza', 'Descrivi in una riga il problema o cosa risultava lento:', Nota);
  if result then
    ANota := Nota;
end;

// Mantis #183 - 2026-10-08: al posto della conferma, la finestra con le
// caselle. Dal 2026-10-29 e' una procedura guidata: l'avviso di prima (a cosa
// serve, rallentamento, dati nel log) e' il testo della sua prima pagina e
// non si passa piu' da qui, per non scriverlo due volte.
function TzSessioneLog.ChiediOpzioni(var AOpzioni: TzOpzioniRegistrazione; out AProssimoAvvio: boolean): boolean;
var
  Video: TzVideoNellaFinestra;
  Chiusura: TzChiusuraNellaFinestra;
begin
  AProssimoAvvio := False;
  FCodiceVideo := '';
  if Assigned(FOnChiediOpzioni) then
  begin
    result := FOnChiediOpzioni(AOpzioni, Assigned(FOnMonitorFireDAC));
    AOpzioni.Video := False; // la finestra dell'applicazione non chiede il codice
    Exit;
  end;

  Video := TzVideoNellaFinestra.Assente;
  if FVideoDisponibile then
  begin
    Video.Previsto := True;
    Video.Disponibile := TzRegistratoreVideo.Disponibile(Video.Motivo);
    Video.Stima := StimaVideo;
    // Il codice lo da' l'assistenza in anticipo e vale sempre: una volta
    // accettato resta valido fino alla chiusura dell'applicazione, e la
    // finestra non lo richiede piu'. Sotto il debugger il codice non si
    // chiede (prove dello sviluppatore).
    if not TzSbloccoVideo.CodiceNonRichiesto then
    begin
      if FSblocco = nil then
        FSblocco := TzSbloccoVideo.Create;
      Video.Sblocco := FSblocco;
    end;
  end;

  Chiusura.Scorciatoia := FTestoScorciatoia;
  // Le applicazioni che prevedono il filmato (Gesty) hanno anche il pulsante
  // rosso REC accanto al titolo, con la pausa del filmato; WT non ha ne' l'uno
  // ne' l'altro e chiude dalla voce di menu o dalla scorciatoia.
  Chiusura.PulsanteRec := FVideoDisponibile;
  Chiusura.DurataMassimaMinuti := FDurataMassimaMinuti;
  if FVideoDisponibile then
    Chiusura.DurataMassimaVideoMinuti := FDurataMassimaVideoMinuti
  else
    Chiusura.DurataMassimaVideoMinuti := 0;
  Chiusura.Segnalibro := FTestoScorciatoiaSegnalibro;
  Chiusura.ProssimoAvvio := FProssimoAvvioNellaProcedura;

  result := ChiediOpzioniRegistrazione(AOpzioni, Assigned(FOnMonitorFireDAC), '', Video, Chiusura, AProssimoAvvio);
  if result and AOpzioni.Video then
  begin
    if Video.Sblocco <> nil then
      FCodiceVideo := Video.Sblocco.Codice;
    FSbloccoVideoAlle := now;
  end;
end;

// Testo sotto il codice di sblocco: solo il limite di tempo. Fino al
// 2026-10-29 c'erano anche il peso al minuto, il tetto in MB e il tempo di
// invio stimato, che all'utente non servivano per decidere.
function TzSessioneLog.StimaVideo: string;
begin
  result := Format('Il filmato si ferma da solo dopo %d minuti.', [FDurataMassimaVideoMinuti]);
end;

// Mantis #183 - 2026-10-08: il monitor lo accende l'applicazione, che per
// cambiare MonitorBy si riconnette. Un errore qui non ferma la registrazione:
// si avvisa e si prosegue senza traccia FireDAC.
procedure TzSessioneLog.AttivaMonitorFireDAC;
begin
  FFileMonitor := '';
  if not FOpzioni.MonitorFireDAC or not Assigned(FOnMonitorFireDAC) then
    Exit;

  FFileMonitor := CartellaEffettiva + FIdentificativo + EstensioneMonitor;
  try
    FOnMonitorFireDAC(True, FFileMonitor);
    TracciaValore('META.fileMonitor', ExtractFileName(FFileMonitor));
  except
    on E: Exception do
    begin
      FFileMonitor := '';
      TracciaValore('META.fileMonitor', 'non attivato: ' + E.Message);
      Mostra('Monitor FireDAC non attivato', 'La registrazione prosegue senza la traccia FireDAC:' + sLineBreak + E.Message,
        tmAvviso);
    end;
  end;
end;

procedure TzSessioneLog.DisattivaMonitorFireDAC;
begin
  if (FFileMonitor = '') or not Assigned(FOnMonitorFireDAC) then
    Exit;
  try
    FOnMonitorFireDAC(False, '');
  except
    on E: Exception do
      Traccia('Monitor FireDAC: spegnimento non riuscito - ' + E.Message);
  end;
end;

procedure TzSessioneLog.Mostra(const ATitolo, ATesto: string; ATipo: TzTipoMessaggio);
begin
  if Assigned(FOnMessaggio) then
  begin
    FOnMessaggio(ATitolo, ATesto, ATipo);
    Exit;
  end;

  // Gli errori restano modali anche da scorciatoia: contengono il percorso dei
  // file rimasti su disco e vanno letti, non intravisti.
  if (FOrigineCorrente = ocScorciatoia) and (ATipo <> tmErrore) then
    dx.Alert(ATitolo, ATesto)
  else
    case ATipo of
      tmErrore:
        ConfirmOk(ATitolo + sLineBreak + sLineBreak + ATesto, mtError);
      tmAvviso:
        ConfirmOk(ATitolo + sLineBreak + sLineBreak + ATesto, mtWarning);
    else
      ConfirmOk(ATitolo + sLineBreak + sLineBreak + ATesto, mtInformation);
    end;
end;

procedure TzSessioneLog.NotificaStato;
begin
  if Assigned(FOnStatoCambiato) then
    FOnStatoCambiato(Self);
end;

function TzSessioneLog.Disponibile: boolean;
begin
  result := TzExceptionManager.MantisServerParams.IsValid;
end;

function TzSessioneLog.DidascaliaVoceMenu: string;
begin
  if FAttiva then
    result := 'Termina registrazione e segnala'
  else
    result := 'Avvia registrazione per l''assistenza';
end;

function TzSessioneLog.SuggerimentoVoceMenu: string;
begin
  if FAttiva then
    result := Format('Registrazione in corso da %s (sessione %s). Premi, o usa %s, per chiudere il log e aprire il ticket.',
      [FormatDateTime('nn:ss', now - FInizio), FIdentificativo, FTestoScorciatoia])
  else
    result := Format('Registra un log dettagliato di quello che fai e lo invia all''assistenza (anche con %s). ' +
      'Mentre e'' attiva l''applicazione risulta piu'' lenta.', [FTestoScorciatoia]);
end;

function TzSessioneLog.DidascaliaVoceAvvio: string;
begin
  if RichiestaAvvioPresente then
    result := 'Annulla registrazione dal prossimo avvio'
  else
    result := 'Registra dal prossimo avvio';
end;

function TzSessioneLog.SuggerimentoVoceAvvio: string;
begin
  if RichiestaAvvioPresente then
    result := 'La registrazione partira'' da sola alla prossima apertura dell''applicazione su questo computer. ' +
      'Premi per annullare la richiesta.'
  else
    result := 'Per i problemi che compaiono all''apertura: chiudi e riapri l''applicazione e la registrazione ' +
      'partira'' da sola, comprendendo anche l''accesso e il caricamento delle impostazioni.';
end;

procedure TzSessioneLog.Commuta(AOrigine: TzOrigineComando);
begin
  if FAttiva then
    TerminaESegnala(AOrigine)
  else
    Avvia(AOrigine);
end;

function TzSessioneLog.Avvia(AOrigine: TzOrigineComando): boolean;
var
  ProssimoAvvio: boolean;
begin
  result := False;
  if FAttiva then
    Exit;

  // Senza i parametri di Mantis il comando non dovrebbe nemmeno essere
  // raggiungibile: qui si esce in silenzio, come rete di sicurezza.
  if not Disponibile then
    Exit;

  FOrigineCorrente := AOrigine;

  // Dal menu si mostra la finestra delle opzioni (Mantis #183 - 2026-10-08,
  // prima una semplice conferma): e' il punto in cui l'utente viene avvisato
  // del rallentamento e del fatto che nel log finiscono anche i dati usati
  // come filtro, e sceglie cosa registrare in piu' e cosa fare alla chiusura.
  // Dalla scorciatoia l'avviso arriva dopo, nella finestra di avviso, e le
  // opzioni sono quelle predefinite (il comportamento di prima): la
  // combinazione di tasti e' un gesto deliberato. Nella finestra le caselle
  // sono tutte accese (richiesta dell'utente del 2026-10-08): chi passa dal
  // menu vuole di norma la registrazione completa, e spegne quello che non serve.
  // Dal 2026-10-29 (procedura guidata) il monitor FireDAC parte spento: si
  // accende solo su richiesta dell'assistenza, perche' riapre la connessione.
  if AOrigine = ocMenu then
  begin
    // 2026-10-29: senza la voce di menu "Registra dal prossimo avvio" questo
    // e' l'unico posto in cui annullare una prenotazione in attesa.
    if FProssimoAvvioNellaProcedura and RichiestaAvvioPresente then
      if ChiediConferma('E'' gi'#$00E0' prenotata una registrazione per la prossima apertura del programma ' +
        'su questo computer.' + sLineBreak + sLineBreak + 'Vuoi annullare la prenotazione?' + sLineBreak + sLineBreak +
        'S'#$00EC' = annulla la prenotazione' + sLineBreak + 'No = prosegui con la procedura di registrazione') then
      begin
        if AnnullaRichiestaAvvio then
          Mostra('Prenotazione annullata', 'Alla prossima apertura la registrazione non partir'#$00E0'.', tmInformazione);
        Exit;
      end;

    FOpzioni := TzOpzioniRegistrazione.Proposte;
    if not ChiediOpzioni(FOpzioni, ProssimoAvvio) then
      Exit;
    // Prenotata nella pagina finale: si scrive la richiesta con le scelte e
    // la nota, e la registrazione la avvia AvviaAllAvvio alla prossima apertura.
    if ProssimoAvvio then
    begin
      if ScriviRichiestaAvvio(FOpzioni, True) then
        Mostra('Registrazione prenotata', 'Chiudi il programma e riaprilo: la registrazione partir'#$00E0' da sola.' +
          sLineBreak + 'Dopo l''accesso comparir'#$00E0' un avviso; quando hai riprodotto il problema, chiudi la ' +
          'registrazione come indicato nella procedura.', tmInformazione);
      Exit;
    end;
  end
  else
    FOpzioni := TzOpzioniRegistrazione.Predefinite;

  FAvviataAllAvvio := False;
  FIdentitaCompletata := True;

  if not AvviaRegistrazione(AOrigine) then
    Exit;

  // 2026-10-29: dal menu l'ultima pagina della procedura guidata ha appena
  // detto come chiudere la registrazione: un altro messaggio da confermare
  // sarebbe solo un clic in piu'. Resta per la scorciatoia, dove e' l'unico avviso.
  if AOrigine = ocMenu then
    Exit(True);

  Mostra('Registrazione log avviata', Format('Sessione %s.' + sLineBreak +
    'Ora l''applicazione risulta piu'' lenta e nel log finiscono anche i dati usati come filtro.' + sLineBreak +
    'Ripremi %s per chiudere la registrazione.', [FIdentificativo, FTestoScorciatoia]), tmInformazione);

  result := True;
end;

function TzSessioneLog.AvviaAllAvvio: boolean;
var
  Richiesta: string;
  Contenuto: TStringList;
  Opzioni: TzOpzioniRegistrazione;
begin
  result := False;
  if FAttiva then
    Exit;

  // 2026-10-29: la richiesta scritta dalla procedura guidata porta le scelte
  // e la nota (voce opzioni=1); quelle scritte dalla voce di menu (WT,
  // zTicser) e le vecchie non le hanno, e valgono le predefinite come prima.
  // Filmato e monitor FireDAC restano spenti comunque: all'avvio non c'e'
  // ancora una finestra da riprendere ne' una connessione da riaprire.
  Opzioni := TzOpzioniRegistrazione.Predefinite;

  // La richiesta si consuma subito, prima di avviare: vale per un avvio solo.
  // Se non si riesce a cancellarla (cartella senza permesso di scrittura) la
  // registrazione non parte, altrimenti ripartirebbe a ogni avvio e l'utente
  // lavorerebbe rallentato per sempre.
  try
    Richiesta := FileRichiestaAvvio;
    if not TFile.Exists(Richiesta) then
      Exit;
    Contenuto := TStringList.Create;
    try
      try
        Contenuto.LoadFromFile(Richiesta, TEncoding.UTF8);
        if Contenuto.Values['opzioni'] = '1' then
        begin
          Opzioni.TempiFetch := Contenuto.Values['tempiFetch'] = '1';
          Opzioni.TempiGriglia := Contenuto.Values['tempiGriglia'] = '1';
          Opzioni.InviaAllaFine := Contenuto.Values['invio'] = '1';
          Opzioni.Nota := NotaDaMarcatore(Contenuto.Values['nota']);
          // Come nella procedura: la nota scritta li' sostituisce la domanda
          // alla chiusura.
          Opzioni.ChiediCommento := False;
        end;
      except
        // Una richiesta illeggibile vale come una vecchia: opzioni predefinite.
        Opzioni := TzOpzioniRegistrazione.Predefinite;
      end;
    finally
      FreeAndNil(Contenuto);
    end;
    TFile.Delete(Richiesta);
  except
    Exit;
  end;
  Opzioni.Video := False;
  Opzioni.MonitorFireDAC := False;

  // Nessuna conferma e nessun messaggio: l'utente ha gia' confermato quando
  // ha chiesto la registrazione, e qui non c'e' ancora nessuna finestra.
  // L'avviso arriva dopo l'accesso, da VerificaSessioneInterrotta. Le opzioni
  // sono quelle lette sopra: prima dell'accesso non c'e' nessuno a cui
  // chiederle e la connessione al database non esiste ancora.
  FAvviataAllAvvio := True;
  FIdentitaCompletata := False;
  FOpzioni := Opzioni;
  result := AvviaRegistrazione(ocScorciatoia);
end;

function TzSessioneLog.AvviaRegistrazione(AOrigine: TzOrigineComando): boolean;
begin
  result := False;
  FOrigineCorrente := AOrigine;

  EliminaFileVecchi;

  FIdentificativo := NuovoIdentificativo;
  FInizio := now;
  FInterrottaPerLimite := False;
  FMotivoInterruzione := '';
  FFileLog := CartellaEffettiva + FIdentificativo + EstensioneLog;
  FFileSil := CartellaEffettiva + FIdentificativo + EstensioneSil;
  FFileCsv := CartellaEffettiva + FIdentificativo + EstensioneCsv;
  FFileMarcatore := CartellaEffettiva + FIdentificativo + EstensioneMarcatore;

  FConnessioniPrecedenti := si.Connections;
  FLivelloPrecedente := si.Level;
  FLivelloPredefinitoPrecedente := si.DefaultLevel;
  FRisoluzionePrecedente := si.Resolution;

  try
    si.Level := lvDebug;
    si.DefaultLevel := lvMessage;
    si.Resolution := crHigh; // durate al microsecondo dentro questo processo
    si.Connections := StringaConnessioni;
    si.Enabled := True;
  except
    on E: Exception do
    begin
      try
        si.Connections := FConnessioniPrecedenti;
      except
      end;
      si.Level := FLivelloPrecedente;
      si.DefaultLevel := FLivelloPredefinitoPrecedente;
      si.Resolution := FRisoluzionePrecedente;
      // All'avvio non c'e' nessuno a cui mostrare l'errore: si rinuncia in
      // silenzio, l'applicazione deve partire comunque.
      if not FAvviataAllAvvio then
        Mostra('Registrazione non avviata', 'Attivazione del log non riuscita:' + sLineBreak + E.Message, tmErrore);
      Exit;
    end;
  end;

  // Mantis #183 - 2026-10-08: le scelte vanno nella raccolta prima di Avvia,
  // cosi' RegistrazioneFetchAttiva e RegistrazioneGrigliaAttiva rispondono
  // dal primo dataset aperto dopo l'avvio.
  TzRaccoltaPrestazioni.Istanza.Opzioni := FOpzioni;
  TzRaccoltaPrestazioni.Istanza.Avvia(FFileCsv, FSogliaOperazioneLentaMs, FRegistraValoriParametri);

  FAttiva := True;

  ScriviIntestazione;
  ScriviMarcatore;

  // Mantis #183 - 2026-10-08: dopo l'intestazione, cosi' la riconnessione
  // fatta dall'applicazione per accendere il monitor finisce nel registro.
  AttivaMonitorFireDAC;
  if FFileMonitor <> '' then
    ScriviMarcatore; // il marcatore deve conoscere anche il file del monitor

  FGestoreFormAttiva := Screen.OnActiveFormChange;
  Screen.OnActiveFormChange := FormAttivaCambiata;
  FormAttivaCambiata(Screen);

  // Dopo la riconnessione del monitor FireDAC: chiudere e riaprire le
  // connessioni non deve entrare nel filmato.
  AvviaVideo;

  FMisuraTick := GetTickCount;
  FMisuraLogMb := DimensioneRegistriMb;
  FMisuraVideoMb := 0;
  FCrescitaLog := 0;
  FCrescitaVideo := 0;
  FAvvisoLimiteDato := False;

  AvviaBattito;
  NotificaStato;

  result := True;
end;

procedure TzSessioneLog.ScriviIdentita;
begin
  TracciaValore('META.database', DbName);
  TracciaValore('META.cliente', ClientName);
  TracciaValore('META.utente', UserName);
end;

procedure TzSessioneLog.ScriviContesto(const ATitolo: string);
var
  Contesto: string;
begin
  // Il contesto completo (form e datamodule aperti, memoria, handle, stato
  // delle connessioni) e' multiriga: nel log ci va comunque, delimitato,
  // perche' serve a ricostruire da dove si parte. Protetto: all'avvio non
  // esiste ancora nessuna finestra, e un errore qui non deve fermare
  // l'applicazione.
  try
    Contesto := ContestoAttuale;
  except
    on E: Exception do
      Contesto := 'contesto non disponibile: ' + E.Message;
  end;
  Traccia('--- INIZIO ' + ATitolo + ' ---');
  Traccia(Contesto);
  Traccia('--- FINE ' + ATitolo + ' ---');
end;

procedure TzSessioneLog.ScriviIntestazione;
begin
  Traccia('=== INIZIO SESSIONE DI REGISTRAZIONE ===');

  TracciaValore('META.sessione', FIdentificativo);
  TracciaValore('META.inizio', FormatDateTime('yyyy-mm-dd hh:nn:ss', FInizio));
  if FAvviataAllAvvio then
    TracciaValore('META.avvio', 'dal prossimo avvio')
  else
    TracciaValore('META.avvio', 'dal menu');
  TracciaValore('META.applicazione', ModuleName);
  TracciaValore('META.versione', VersionInfo);
  TracciaValore('META.eseguibile', GetModuleName(HInstance));
  TracciaValore('META.rigaDiComando', GetCommandLine);
  // All'avvio questi tre sono ancora vuoti: si riscrivono dopo l'accesso.
  ScriviIdentita;
  TracciaValore('META.utenteSistema', SysUserName);
  TracciaValore('META.computer', ComputerName);
  TracciaValore('META.dpi', Screen.PrimaryMonitor.PixelsPerInch.ToString);
  TracciaValore('META.monitor', Screen.MonitorCount.ToString);
  TracciaValore('META.sogliaOperazioneLentaMs', FSogliaOperazioneLentaMs.ToString);
  TracciaValore('META.sogliaBloccoMs', FSogliaBloccoMs.ToString);
  TracciaValore('META.valoriParametriRegistrati', BoolToStr(FRegistraValoriParametri, True));
  TracciaValore('META.fileSil', ExtractFileName(FFileSil));
  TracciaValore('META.fileCsv', ExtractFileName(FFileCsv));
  // Mantis #183 - 2026-10-08: chi legge il registro deve sapere quali misure
  // in piu' erano accese, altrimenti l'assenza delle righe "fetch" sembra un
  // difetto della misura.
  TracciaValore('META.opzioni', FOpzioni.Descrizione);
  // Dal 2026-10-29 la nota si scrive all'avvio: nel registro c'e' anche
  // quando la registrazione non si invia e i file arrivano a mano.
  if FOpzioni.Nota.Trim <> '' then
    TracciaValore('META.notaUtente', FOpzioni.Nota);

  ScriviContesto('CONTESTO INIZIALE');

  CampionaRisorse;
end;

procedure TzSessioneLog.ScriviRiepilogo;
begin
  Traccia('--- RIEPILOGO SESSIONE ' + FIdentificativo + ' ---');
  TracciaValore('RIEPILOGO.durataMinuti', FormatFloat('0.0', MinutesBetween(now, FInizio)));
  TracciaValore('RIEPILOGO.eventiMisurati', TzRaccoltaPrestazioni.Istanza.EventiTotali.ToString);
  if FInterrottaPerLimite then
    TracciaValore('RIEPILOGO.interrotta', FMotivoInterruzione);
  Traccia(TzRaccoltaPrestazioni.Istanza.TestoRiepilogo(20));
  Traccia('=== FINE SESSIONE DI REGISTRAZIONE ===');
end;

procedure TzSessioneLog.ScriviMarcatore;
var
  Contenuto: TStringList;
begin
  Contenuto := TStringList.Create;
  try
    Contenuto.AddPair('sessione', FIdentificativo);
    // Serve a VerificaSessioneInterrotta: nella cartella condivisa ci sono i
    // marcatori di tutte le postazioni, e ognuna deve vedere solo i propri.
    Contenuto.AddPair('postazione', NomePostazione);
    Contenuto.AddPair('inizio', FormatDateTime('yyyy-mm-dd hh:nn:ss', FInizio));
    Contenuto.AddPair('log', FFileLog);
    Contenuto.AddPair('sil', FFileSil);
    Contenuto.AddPair('csv', FFileCsv);
    Contenuto.AddPair('monitor', FFileMonitor); // Mantis #183: vuoto se spento
    // 2026-10-29: la nota scritta all'avvio, cosi' una sessione interrotta
    // la reinvia senza richiederla. In Base64 su una riga: la nota puo'
    // avere piu' righe e il marcatore e' un elenco nome=valore.
    if FOpzioni.Nota.Trim <> '' then
      Contenuto.AddPair('nota', NotaPerMarcatore(FOpzioni.Nota));
    try
      Contenuto.SaveToFile(FFileMarcatore, TEncoding.UTF8);
    except
    end;
  finally
    FreeAndNil(Contenuto);
  end;
end;

procedure TzSessioneLog.RimuoviMarcatore;
begin
  try
    if (FFileMarcatore <> '') and TFile.Exists(FFileMarcatore) then
      TFile.Delete(FFileMarcatore);
  except
  end;
end;

procedure TzSessioneLog.EliminaFileVecchi;
var
  Cartella, Nome: string;
  Limite: TDateTime;
begin
  // Tocca anche i file delle altre postazioni della cartella condivisa: il
  // criterio e' solo l'eta', e un file di oltre GiorniConservazione giorni
  // non serve piu' a nessuno.
  try
    Cartella := CartellaEffettiva;
    Limite := now - FGiorniConservazione;
    for Nome in TDirectory.GetFiles(Cartella, 'LOG-*.*') do
      if TFile.GetLastWriteTime(Nome) < Limite then
        try
          TFile.Delete(Nome);
        except
        end;
  except
  end;
end;

procedure TzSessioneLog.AvviaBattito;
begin
  if FBattito = nil then
  begin
    FBattito := TTimer.Create(nil);
    FBattito.Interval := 500;
    // Gestore di evento come metodo di istanza: un class procedure in un
    // TMethod porterebbe il riferimento di CLASSE in Data e mandarebbe in
    // errore il registratore.
    FBattito.OnTimer := BattitoScattato;
  end;
  FUltimoBattito := GetTickCount;
  FUltimoCampionamento := FUltimoBattito;
  FBattito.Enabled := True;
end;

procedure TzSessioneLog.FermaBattito;
begin
  if FBattito <> nil then
    FBattito.Enabled := False;
end;

procedure TzSessioneLog.BattitoScattato(Sender: TObject);
var
  Adesso, Divario: Cardinal;
begin
  if not FAttiva then
    Exit;

  Adesso := GetTickCount;
  Divario := Adesso - FUltimoBattito;
  FUltimoBattito := Adesso;

  // Il timer scatta nel thread principale: se il divario fra due battiti
  // supera la soglia, in quel tempo l'interfaccia non ha risposto. E' la
  // misura piu' vicina a quello che l'utente chiama "si blocca".
  if Divario > Cardinal(FSogliaBloccoMs) then
    SegnalaOperazione(coBloccoInterfaccia, 'interfaccia non rispondente', Divario,
      'modulo attivo: ' + TzRaccoltaPrestazioni.Istanza.ModuloCorrente);

  if (Adesso - FUltimoCampionamento) >= Cardinal(FIntervalloCampionamentoSecondi * 1000) then
  begin
    FUltimoCampionamento := Adesso;
    CampionaRisorse;
  end;

  ControllaVideo;
  MisuraCrescita;
  AvvisaLimiteImminente;

  // Limiti di sicurezza: chi dimentica la registrazione attiva lavorerebbe
  // rallentato per giorni, e il file diventerebbe inallegabile.
  if MinutesBetween(now, FInizio) >= FDurataMassimaMinuti then
  begin
    FInterrottaPerLimite := True;
    FMotivoInterruzione := Format('durata massima di %d minuti raggiunta', [FDurataMassimaMinuti]);
  end
  else if DimensioneRegistriMb >= FDimensioneMassimaMb then
  begin
    FInterrottaPerLimite := True;
    FMotivoInterruzione := Format('dimensione massima di %d MB raggiunta', [FDimensioneMassimaMb]);
  end;

  if FInterrottaPerLimite then
  begin
    FermaBattito;
    // Mantis #183 - 2026-10-08: se all'avvio l'utente ha escluso l'invio, non
    // ha senso chiederglielo qui: si chiude e si dice dove sono i file.
    if not FOpzioni.InviaAllaFine then
      TerminaESegnala
    else if not ChiediConferma('La registrazione si e'' chiusa da sola: ' + FMotivoInterruzione + '.' + sLineBreak + sLineBreak +
      'Invio ora la segnalazione all''assistenza?') then
      Annulla
    else if not TerminaESegnala then
      // L'utente ha annullato la nota: la registrazione va chiusa comunque,
      // il limite e' stato raggiunto e il battito e' fermo.
      Annulla;
  end;
end;

procedure TzSessioneLog.CampionaRisorse;
var
  Memoria: TProcessMemoryCounters;
  Dettaglio: string;
begin
  Dettaglio := '';
  FillChar(Memoria, SizeOf(Memoria), 0);
  Memoria.cb := SizeOf(Memoria);
  if GetProcessMemoryInfo(GetCurrentProcess, @Memoria, SizeOf(Memoria)) then
    Dettaglio := Format('workingSetMb=%.1f picoMb=%.1f pagefileMb=%.1f',
      [Memoria.WorkingSetSize / 1024 / 1024, Memoria.PeakWorkingSetSize / 1024 / 1024, Memoria.PagefileUsage / 1024 / 1024]);

  Dettaglio := Dettaglio + Format(' gdi=%d user=%d',
    [GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS), GetGuiResources(GetCurrentProcess, GR_USEROBJECTS)]);

  // Durata zero: non e' una misura di tempo ma un campione di risorse. La
  // crescita fra un campione e l'altro e' quello che interessa.
  SegnalaOperazione(coRisorse, 'campione risorse', 0, Dettaglio);
  TracciaValore('RISORSE', Dettaglio);
end;

function TzSessioneLog.DimensioneRegistriMb: Double;
begin
  result := (DimensioneFile(FFileLog) + DimensioneFile(FFileSil)) / 1024 / 1024;
end;

procedure TzSessioneLog.FormAttivaCambiata(Sender: TObject);
var
  Nome: string;
begin
  try
    if Screen.ActiveCustomForm <> nil then
    begin
      Nome := Screen.ActiveCustomForm.Name;
      if Nome.IsEmpty then
        Nome := Screen.ActiveCustomForm.ClassName;
    end
    else
      Nome := '(nessuna)';

    if Nome <> TzRaccoltaPrestazioni.Istanza.ModuloCorrente then
    begin
      TzRaccoltaPrestazioni.Istanza.ModuloCorrente := Nome;
      TracciaValore('NAVIGAZIONE.formAttiva', Nome);
    end;
  except
  end;

  // La catena va sempre rispettata: qualcun altro potrebbe essere gia'
  // agganciato a questo evento.
  if Assigned(FGestoreFormAttiva) then
    FGestoreFormAttiva(Sender);
end;

procedure TzSessioneLog.InserisciSegnalibro(const ATesto: string; AOrigine: TzOrigineComando);
var
  Testo: string;
begin
  FOrigineCorrente := AOrigine;

  if not FAttiva then
  begin
    Mostra('Nessuna registrazione in corso', Format('Avvia prima la registrazione con %s.', [FTestoScorciatoia]), tmAvviso);
    Exit;
  end;

  Testo := ATesto;
  if Testo.Trim.IsEmpty then
    if not InputString('Segnalibro', 'Cosa e'' successo qui?', Testo) then
      Exit;

  SegnalaSegnalibro(Testo);
  TracciaValore('SEGNALIBRO', Testo);

  Mostra('Segnalibro inserito', Testo, tmInformazione);
end;

procedure TzSessioneLog.Annulla;
begin
  ChiudiSessione(True);
end;

procedure TzSessioneLog.ChiudiPerTerminazione;
begin
  ChiudiSessione(False);
end;

procedure TzSessioneLog.ChiudiSessione(const ARimuoviMarcatore: boolean);
begin
  if not FAttiva then
    Exit;

  // Ogni passo e' protetto da solo: un errore nel riepilogo o nel ripristino
  // di SmartInspect non deve impedire la chiusura del CSV, l'azzeramento
  // dello stato e la gestione del marcatore. Senza protezione un passo
  // fallito lasciava la sessione formalmente aperta e il file .inCorso sul
  // disco.
  try
    try
      FermaBattito;
    except
    end;

    // Mantis #183 - 2026-10-08: prima del riepilogo, cosi' la riconnessione
    // di spegnimento resta nel registro e il file del monitor e' chiuso quando
    // si passa a comprimerlo.
    try
      DisattivaMonitorFireDAC;
    except
    end;

    // Prima del riepilogo, cosi' le righe VIDEO.fine finiscono nel log e
    // l'ultima parte e' chiusa quando si passa a inviarla.
    try
      FermaVideo('fine della registrazione');
    except
    end;

    try
      Screen.OnActiveFormChange := FGestoreFormAttiva;
      FGestoreFormAttiva := nil;
    except
    end;

    try
      ScriviRiepilogo;
    except
    end;

    try
      TzRaccoltaPrestazioni.Istanza.Termina;
    except
    end;

    // Il ripristino delle connessioni chiude .sil e .log: da qui in poi si
    // possono aprire e zippare.
    try
      si.Connections := FConnessioniPrecedenti;
      si.Level := FLivelloPrecedente;
      si.DefaultLevel := FLivelloPredefinitoPrecedente;
      si.Resolution := FRisoluzionePrecedente;
    except
    end;
  finally
    FAttiva := False;
    FAvviataAllAvvio := False;

    if ARimuoviMarcatore then
      RimuoviMarcatore;

    try
      NotificaStato;
    except
    end;
  end;
end;

function TzSessioneLog.TerminaESegnala(AOrigine: TzOrigineComando): boolean;
var
  Nota: string;
  Log, Sil, Csv, Monitor: string;
  Elenco: string;
  Parti: TArray<string>;
  Parte: string;
begin
  result := False;
  if not FAttiva then
    Exit;

  FOrigineCorrente := AOrigine;

  // La nota si chiede sempre con un dialogo, anche da scorciatoia: e' l'unico
  // modo per ottenere del testo, ed e' il campo piu' utile del ticket.
  // Mantis #183 - 2026-10-08: salvo che l'utente l'abbia esclusa all'avvio.
  // Dal 2026-10-29 la procedura guidata la fa scrivere all'avvio e spegne
  // ChiediCommento: qui si chiede solo per gli avvii senza finestra
  // (scorciatoia, prossimo avvio), dove non c'e' stato un altro momento.
  Nota := FOpzioni.Nota;
  if (Nota.Trim = '') and FOpzioni.ChiediCommento then
    if not ChiediNota(Nota) then
    begin
      // L'utente ha annullato: la registrazione resta attiva, altrimenti
      // perderebbe il lavoro fatto finora senza volerlo.
      Exit;
    end;

  Log := FFileLog;
  Sil := FFileSil;
  Csv := FFileCsv;
  Monitor := FFileMonitor;

  Annulla; // chiude i file e ripristina SmartInspect, ferma il filmato
  Parti := FPartiVideo;

  // Mantis #183 - 2026-10-08: senza invio i file restano dove sono, non
  // compressi, pronti per log_summary; si dice all'utente dove.
  if not FOpzioni.InviaAllaFine then
  begin
    Elenco := ExtractFileName(Sil) + sLineBreak + ExtractFileName(Log) + sLineBreak + ExtractFileName(Csv);
    if Monitor <> '' then
      Elenco := Elenco + sLineBreak + ExtractFileName(Monitor);
    for Parte in Parti do
      Elenco := Elenco + sLineBreak + ExtractFileName(Parte);
    // 2026-10-29: alla chiusura non si chiede piu' niente, quindi il
    // messaggio dice sempre cosa e' successo (testi dell'analisi).
    Mostra('Registrazione chiusa', 'Non ho inviato niente, come avevi scelto. I file sono nella cartella' + sLineBreak +
      ExtractFilePath(Sil) + sLineBreak + 'Mandali all''assistenza se te li chiede.' + sLineBreak + sLineBreak + Elenco,
      tmInformazione);
    Exit(True);
  end;

  // 2026-10-29: fino al rilascio OUT/20261029-procedura-guidata-registrazione-assistenza/002
  // qui si chiedeva se inviare il filmato (Si' = log e filmato, No = solo il
  // log, Annulla = niente), con dimensione e tempo di invio veri. Con la
  // procedura guidata alla chiusura non si chiede piu' niente: l'utente ha
  // gia' scelto filmato e invio all'avvio, il filmato ha il suo limite di
  // durata e si carica dopo il log senza bloccare il programma.
  result := InviaAMantis(Nota, Log, Sil, Csv, Monitor, Parti);
end;

function TzSessioneLog.OggettoTicket: string;
begin
  result := Format('[LOG] %s - %s - %s - %s', [ModuleName, ClientName, UserName, FIdentificativo]);
  result := Copy(result.Replace(#13, ' ').Replace(#10, ' '), 1, 120);
end;

function TzSessioneLog.DescrizioneTicket(const ANota, AArchivio: string; const APartiVideo: TArray<string>): string;
var
  Descrizione: TStringList;
  Parte: string;
begin
  Descrizione := TStringList.Create;
  try
    if ANota.Trim <> '' then
    begin
      Descrizione.Add('Segnalazione dell''utente:');
      Descrizione.Add(ANota);
      Descrizione.Add('');
      Descrizione.Add(''.PadLeft(70, '_'));
      Descrizione.Add('');
    end;

    Descrizione.AddPair('Sessione', FIdentificativo);
    // Mantis #183 - 2026-10-08: chi analizza deve sapere che nel CSV ci sono
    // anche le righe dei fetch e della griglia, e che nello zip c'e' la
    // traccia FireDAC.
    if FOpzioni.MisureAggiuntive then
      Descrizione.AddPair('Misure aggiuntive', FOpzioni.Descrizione);
    Descrizione.AddPair('Applicazione', ModuleName);
    Descrizione.AddPair('Versione', VersionInfo);
    Descrizione.AddPair('Database', DbName);
    Descrizione.AddPair('Cliente', ClientName);
    Descrizione.AddPair('Utente', UserName);
    Descrizione.AddPair('Utente sistema', SysUserName);
    Descrizione.AddPair('Computer', ComputerName);
    Descrizione.AddPair('Inizio', FormatDateTime('yyyy-mm-dd hh:nn:ss', FInizio));
    // ZC 30.10.2026: prima "Durata (minuti)" con MinutesBetween, che conta i
    // minuti interi: una sessione di 16 secondi usciva "0,0". Ora la durata
    // e' scritta come quella del filmato (16 s, 3 min 20 s, 1 h 5 min).
    Descrizione.AddPair('Durata', TestoDurata(SecondsBetween(now, FInizio)));
    Descrizione.AddPair('Eventi misurati', TzRaccoltaPrestazioni.Istanza.EventiTotali.ToString);
    Descrizione.AddPair('Valori dei parametri nel log', BoolToStr(FRegistraValoriParametri, True));
    Descrizione.AddPair('Allegato', ExtractFileName(AArchivio));
    if Length(FFileFuoriArchivio) > 0 then
    begin
      Descrizione.Add('File non compressi nello zip (restano sul computer):');
      for Parte in FFileFuoriArchivio do
        Descrizione.Add('  ' + Parte);
    end;
    if FInterrottaPerLimite then
      Descrizione.AddPair('Registrazione interrotta', FMotivoInterruzione);
    // Le parti arrivano dopo l'apertura del ticket: chi lo legge deve sapere
    // quante aspettarne, e la nota finale dice quante sono arrivate.
    if Length(APartiVideo) > 0 then
    begin
      // Durate a zero: sessione interrotta, le statistiche del filmato sono
      // andate perse con l'applicazione e restano solo le parti.
      if FStatisticheVideo.DurataVeraMs = 0 then
        Descrizione.AddPair('Filmato', Format('%s, allegate dopo lo zip (sessione interrotta, durata non nota)',
          [TestoParti(Length(APartiVideo))]))
      else
        Descrizione.AddPair('Filmato', Format('%s, allegate dopo lo zip (%s di filmato, %s di registrazione)',
          [TestoParti(Length(APartiVideo)), TestoDurata(FStatisticheVideo.DurataFilmatoMs div 1000),
          TestoDurata(FStatisticheVideo.DurataVeraMs div 1000)]));
      for Parte in APartiVideo do
        Descrizione.Add('  ' + ExtractFileName(Parte) + ' (' + TestoMb(DimensioneFile(Parte)) + ')');
      if FCodiceVideo <> '' then
        Descrizione.AddPair('Filmato sbloccato con il codice', FCodiceVideo);
    end;

    Descrizione.Add('');
    Descrizione.Add(''.PadLeft(70, '_'));
    Descrizione.Add('');
    Descrizione.Add(TzRaccoltaPrestazioni.Istanza.TestoRiepilogo(20));

    Descrizione.Add('');
    Descrizione.Add(''.PadLeft(70, '_'));
    Descrizione.Add('');
    Descrizione.Add(IstruzioniAnalisi);

    Descrizione.Add('');
    Descrizione.Add(''.PadLeft(70, '_'));
    Descrizione.Add('');
    Descrizione.Add('CONTESTO ALLA CHIUSURA DELLA SESSIONE');
    Descrizione.Add('');
    Descrizione.Add(ContestoAttuale);

    result := Descrizione.Text;
  finally
    FreeAndNil(Descrizione);
  end;
end;

// Raccoglie i file della sessione in un unico zip, accanto a loro, e se lo
// zip e' riuscito cancella gli originali: sono tutti dentro, e la cartella
// dei log e' spesso condivisa da molte postazioni. Se lo zip non riesce gli
// originali restano e la funzione solleva l'eccezione.
// Un file ancora aperto da un altro processo (la traccia FireDAC, che il
// tracciatore chiude nel suo thread) si riprova per circa due secondi; se
// resta bloccato si lascia fuori, sul disco, e finisce in FFileFuoriArchivio
// invece di far fallire tutto lo zip: prima bastava il -firedac.txt aperto
// per perdere anche .sil, .log e .csv.
function TzSessioneLog.CreaArchivio(const AIdentificativo: string; const AFile: array of string): string;
const
  TentativiFileBloccato = 10;
  AttesaFileBloccatoMs = 200;
var
  Archivio: TZipFile;
  Nome: string;
  Compressi: TArray<string>;
  Tentativo: Integer;
begin
  FFileFuoriArchivio := nil;
  Compressi := nil;
  result := CartellaEffettiva + AIdentificativo + EstensioneZip;
  if TFile.Exists(result) then
    TFile.Delete(result);

  Archivio := TZipFile.Create;
  try
    Archivio.Open(result, zmWrite);
    for Nome in AFile do
      if (Nome <> '') and TFile.Exists(Nome) then
        for Tentativo := 1 to TentativiFileBloccato do
          try
            Archivio.Add(Nome, ExtractFileName(Nome), zcDeflate);
            Compressi := Compressi + [Nome];
            Break;
          except
            on E: EFileStreamError do
              if Tentativo < TentativiFileBloccato then
                Sleep(AttesaFileBloccatoMs)
              else
              begin
                FFileFuoriArchivio := FFileFuoriArchivio + [ExtractFileName(Nome) + ' - ' + E.Message];
                Traccia('Zip della sessione: ' + ExtractFileName(Nome) + ' lasciato fuori - ' + E.Message);
              end;
          end;
    Archivio.Close;
  finally
    FreeAndNil(Archivio);
  end;

  // Si cancellano solo i file entrati nello zip.
  for Nome in Compressi do
    try
      if TFile.Exists(Nome) then
        TFile.Delete(Nome);
    except
    end;
end;

function TzSessioneLog.InviaAMantis(const ANota: string; const AFileLog, AFileSil, AFileCsv: string;
  const AFileMonitor: string; const APartiVideo: TArray<string>): boolean;
var
  Segnalazione: TMantisReport;
  Progetto: string;
  Archivio: string;
  AllegatiNonRiusciti: TArray<string>;
  NumeroTicket: Integer;
  CursorePrecedente: TCursor;
  Orologio: TStopwatch;
begin
  result := False;

  // Lo zip si fa comunque, anche senza Mantis: e' il file da mandare a mano.
  // Mantis #183 - 2026-10-08: dentro anche la traccia FireDAC, se c'e'
  // (CreaArchivio salta i nomi vuoti e i file che non esistono).
  try
    Archivio := CreaArchivio(FIdentificativo, [AFileSil, AFileLog, AFileCsv, AFileMonitor]);
  except
    on E: Exception do
    begin
      Mostra('Ticket non aperto', 'Compressione dei file del log non riuscita:' + sLineBreak + E.Message + sLineBreak +
        sLineBreak + 'I file restano su disco:' + sLineBreak + AFileLog, tmErrore);
      Exit;
    end;
  end;

  if not TzExceptionManager.MantisServerParams.IsValid then
  begin
    Mostra('Ticket non aperto', 'I parametri di collegamento a Mantis non sono configurati: ' +
      'il log resta su disco e va inviato a mano all''assistenza.' + sLineBreak + sLineBreak + Archivio, tmErrore);
    Exit;
  end;

  // Progetto Mantis = cliente/ente, con ripiego sul nome del database
  // (stessa regola della segnalazione delle eccezioni).
  Progetto := ClientName;
  if Progetto.Trim = '' then
    Progetto := DbName;

  Segnalazione.ProjectName := Progetto;
  Segnalazione.ReporterUser := UserName;
  Segnalazione.ReporterEmail := UserEmail;
  Segnalazione.ReporterRealName := UserName;
  Segnalazione.Summary := OggettoTicket;
  Segnalazione.Description := DescrizioneTicket(ANota, Archivio, APartiVideo);
  Segnalazione.Category := FCategoriaMantis;
  Segnalazione.Attachments := [Archivio];
  // Ticket privato: il .sil contiene SQL, valori dei parametri e dati usati
  // come filtro, cioe' dati personali. Lo vedono chi lo ha aperto e chi ha
  // il livello di accesso ai ticket privati del progetto.
  Segnalazione.ViewState := 'private';

  CursorePrecedente := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    try
      Orologio := TStopwatch.StartNew;
      NumeroTicket := SegnalaSuMantis(TzExceptionManager.MantisServerParams, Segnalazione, AllegatiNonRiusciti);
      // Velocita' della linea misurata sullo zip: corregge la stima del
      // tempo di invio del filmato. Comprende anche l'apertura del ticket,
      // quindi sbaglia per difetto, cioe' dalla parte prudente.
      if Length(AllegatiNonRiusciti) = 0 then
        RegistraVelocitaInvio(DimensioneFile(Archivio), Orologio.ElapsedMilliseconds);
      result := True;
    except
      on E: Exception do
      begin
        Mostra('Ticket non aperto', 'Apertura del ticket non riuscita:' + sLineBreak + E.Message + sLineBreak + sLineBreak +
          'Il log resta su disco:' + sLineBreak + Archivio, tmErrore);
        Exit;
      end;
    end;
  finally
    Screen.Cursor := CursorePrecedente;
  end;

  // Un allegato rifiutato (di solito per dimensione) non annulla il ticket,
  // ma l'utente deve saperlo: senza lo zip il ticket non serve a niente.
  if Length(AllegatiNonRiusciti) > 0 then
    Mostra('Log non allegato', Format('Ticket #%d aperto su Mantis, ma il log non e'' stato allegato:' + sLineBreak +
      '%s' + sLineBreak + sLineBreak + 'Il file resta su disco e va inviato a mano all''assistenza:' + sLineBreak + '%s',
      [NumeroTicket, string.Join(sLineBreak, AllegatiNonRiusciti), Archivio]), tmErrore)
  // 2026-10-29: testi per l'utente (tabella "Messaggio alla chiusura"
  // dell'analisi), senza Mantis e categoria; la sessione resta per l'assistenza.
  else if Length(APartiVideo) > 0 then
    Mostra('Registrazione chiusa e inviata', Format('L''assistenza ha ricevuto la segnalazione n. %d.' + sLineBreak +
      'Il filmato (%s, circa %s) si sta caricando: puoi continuare a lavorare, ' +
      'l''avanzamento si vede accanto al pulsante REC.', [NumeroTicket, TestoParti(Length(APartiVideo)),
      TestoDurata(SecondiDiInvio(DimensioneTotale(APartiVideo)))]), tmInformazione)
  else
    Mostra('Registrazione chiusa e inviata', Format('L''assistenza ha ricevuto la segnalazione n. %d.' + sLineBreak +
      'Grazie: verrai ricontattato appena sar' + #$00E0 + ' esaminata.' + sLineBreak + sLineBreak + 'Sessione %s.',
      [NumeroTicket, FIdentificativo]), tmInformazione);

  // Il filmato parte dopo lo zip anche se lo zip e' stato rifiutato: il
  // ticket esiste, e una parte arrivata e' meglio di niente.
  if Length(APartiVideo) > 0 then
    AvviaInvioParti(NumeroTicket, APartiVideo);
end;

// Monitor su cui sta la finestra principale, in pixel fisici (le
// applicazioni sono consapevoli dei DPI per monitor).
function MonitorDellaFinestraPrincipale: TRect;
var
  Monitor: HMONITOR;
  Informazioni: TMonitorInfo;
  Finestra: HWND;
begin
  Finestra := 0;
  if Application.MainForm <> nil then
    Finestra := Application.MainForm.Handle;
  Monitor := MonitorFromWindow(Finestra, MONITOR_DEFAULTTOPRIMARY);
  FillChar(Informazioni, SizeOf(Informazioni), 0);
  Informazioni.cbSize := SizeOf(Informazioni);
  if not GetMonitorInfo(Monitor, @Informazioni) then
    RaiseLastOSError;
  result := Informazioni.rcMonitor;
end;

procedure TzSessioneLog.AvviaVideo;
var
  Motivo: string;
begin
  FPartiVideo := nil;
  FPartiScritte := 0;
  FMotivoFermoVideo := '';
  FillChar(FStatisticheVideo, SizeOf(FStatisticheVideo), 0);
  FStatisticheVideo.Parti := nil;
  if not FOpzioni.Video then
    Exit;

  if FCodiceVideo <> '' then
    TracciaValore('VIDEO.codice', FCodiceVideo)
  else
    TracciaValore('VIDEO.codice', 'nessuno (applicazione sotto il debugger)');
  TracciaValore('VIDEO.sbloccato', FormatDateTime('yyyy-mm-dd hh:nn:ss', FSbloccoVideoAlle));

  try
    if not TzRegistratoreVideo.Disponibile(Motivo) then
      raise Exception.Create(Motivo);
    FRegistratore := TzRegistratoreVideo.Create(CartellaEffettiva, FIdentificativo, GetCurrentProcessId,
      MonitorDellaFinestraPrincipale);
    FRegistratore.Start;
    FInizioVideo := now;
    TracciaValore('VIDEO.avvio', Format('%d fotogrammi al secondo, %d kbit/s, parti da %d MB, limite %d minuti o %d MB',
      [FRegistratore.FotogrammiAlSecondo, FRegistratore.Bitrate div 1000, FRegistratore.DimensioneParteByte div 1024 div 1024,
      FDurataMassimaVideoMinuti, FDimensioneMassimaVideoMb]));
  except
    on E: Exception do
    begin
      FreeAndNil(FRegistratore);
      FOpzioni.Video := False;
      TracciaValore('VIDEO.avvio', 'non riuscito: ' + E.Message);
      Mostra('Filmato non avviato', 'La registrazione prosegue senza il filmato:' + sLineBreak + E.Message, tmAvviso);
    end;
  end;
end;

// Una riga VIDEO.parte per ogni parte nuova, con l'ora vera di inizio: e'
// quello che lega il filmato al log.
procedure TzSessioneLog.RegistraPartiNuove;
var
  Parti: TArray<string>;
  Indice: Integer;
begin
  if FRegistratore = nil then
    Exit;
  Parti := FRegistratore.Statistiche.Parti;
  for Indice := FPartiScritte to High(Parti) do
    TracciaValore('VIDEO.parte', ExtractFileName(Parti[Indice]) + ' dalle ' + FormatDateTime('hh:nn:ss', now));
  FPartiScritte := Length(Parti);
end;

procedure TzSessioneLog.FermaVideo(const AMotivo: string);
var
  Parte: string;
  MinutiVeri: Double;
  MilliMb, MilliMbPrecedenti: Int64;
begin
  if FRegistratore = nil then
    Exit;
  RegistraPartiNuove;
  FRegistratore.Ferma;
  FRegistratore.WaitFor;
  FStatisticheVideo := FRegistratore.Statistiche;
  if FRegistratore.Errore <> '' then
    TracciaValore('VIDEO.errore', FRegistratore.Errore);
  FreeAndNil(FRegistratore);
  FMotivoFermoVideo := AMotivo;

  // Una parte aperta e mai scritta (errore del codificatore) non si allega.
  FPartiVideo := nil;
  for Parte in FStatisticheVideo.Parti do
    if DimensioneFile(Parte) > 0 then
      FPartiVideo := FPartiVideo + [Parte];

  TracciaValore('VIDEO.fine', Format('%s; %s, %s, %s di filmato su %s catturati, %d fotogrammi scritti su %d, %dx%d',
    [AMotivo, TestoParti(Length(FPartiVideo)), TestoMb(DimensioneTotale(FPartiVideo)), TestoDurata(FStatisticheVideo.DurataFilmatoMs div 1000),
    TestoDurata(FStatisticheVideo.DurataVeraMs div 1000), FStatisticheVideo.FotogrammiScritti,
    FStatisticheVideo.FotogrammiCatturati, FStatisticheVideo.LarghezzaFilmato, FStatisticheVideo.AltezzaFilmato]));

  // Peso medio per minuto di registrazione su questa postazione, per la
  // stima della prossima volta: media con il valore precedente.
  MinutiVeri := FStatisticheVideo.DurataVeraMs / 60000;
  if MinutiVeri >= 1 then
  begin
    MilliMb := Round(DimensioneTotale(FPartiVideo) / 1024 / 1024 * 1000 / MinutiVeri);
    MilliMbPrecedenti := LeggiImpostazioneLocale('Filmato', 'MilliMbAlMinuto', 0);
    if MilliMbPrecedenti > 0 then
      MilliMb := (MilliMb + MilliMbPrecedenti) div 2;
    ScriviImpostazioneLocale('Filmato', 'MilliMbAlMinuto', MilliMb);
  end;

  // L'avviso del limite imminente vale per il limite successivo, quello del log.
  FAvvisoLimiteDato := False;
  NotificaStato;
end;

// Dal battito: parti nuove, fine anticipata del thread (errore del
// codificatore) e limiti del filmato. Al limite si ferma solo il filmato.
procedure TzSessioneLog.ControllaVideo;
var
  Motivo: string;
begin
  if FRegistratore = nil then
    Exit;
  RegistraPartiNuove;

  Motivo := '';
  if FRegistratore.Finished then
    Motivo := 'interrotto da un errore'
  else if SecondsBetween(now, FInizioVideo) >= FDurataMassimaVideoMinuti * 60 then
    Motivo := Format('durata massima di %d minuti raggiunta', [FDurataMassimaVideoMinuti])
  else if DimensioneVideoMb >= FDimensioneMassimaVideoMb then
    Motivo := Format('dimensione massima di %d MB raggiunta', [FDimensioneMassimaVideoMb]);
  if Motivo = '' then
    Exit;

  FermaVideo(Motivo);
  dx.Alert('Filmato fermato', 'Il filmato si e'' fermato: ' + Motivo + '.' + sLineBreak +
    'La registrazione del log continua; le parti gia'' registrate si inviano alla chiusura.');
end;

function TzSessioneLog.DimensioneVideoMb: Double;
begin
  if FRegistratore <> nil then
    result := DimensioneTotale(FRegistratore.Statistiche.Parti) / 1024 / 1024
  else
    result := DimensioneTotale(FPartiVideo) / 1024 / 1024;
end;

procedure TzSessioneLog.MisuraCrescita;
var
  Adesso: Cardinal;
  Secondi, LogMb, VideoMb: Double;
begin
  Adesso := GetTickCount;
  if Adesso - FMisuraTick < IntervalloMisuraCrescitaMs then
    Exit;
  Secondi := (Adesso - FMisuraTick) / 1000;
  LogMb := DimensioneRegistriMb;
  VideoMb := DimensioneVideoMb;
  FCrescitaLog := Max(0, (LogMb - FMisuraLogMb) / Secondi);
  if FRegistratore <> nil then
    FCrescitaVideo := Max(0, (VideoMb - FMisuraVideoMb) / Secondi)
  else
    FCrescitaVideo := 0;
  FMisuraTick := Adesso;
  FMisuraLogMb := LogMb;
  FMisuraVideoMb := VideoMb;
end;

function TzSessioneLog.TempoResiduo: TzTempoResiduo;

  procedure Considera(ATrascorsi, AResidui: Double; const AMotivo: string);
  begin
    AResidui := Max(0, AResidui);
    if (result.Secondi < 0) or (AResidui < result.Secondi) then
    begin
      result.Secondi := Round(AResidui);
      result.Totale := Max(1, Round(ATrascorsi + AResidui));
      result.Motivo := AMotivo;
    end;
  end;

var
  Trascorsi: Double;
begin
  result.Secondi := -1;
  result.Totale := 0;
  result.Motivo := '';
  if not FAttiva then
    Exit;

  Trascorsi := SecondsBetween(now, FInizio);
  Considera(Trascorsi, FDurataMassimaMinuti * 60 - Trascorsi, Format('si chiude la registrazione: %d minuti',
    [FDurataMassimaMinuti]));
  if FCrescitaLog > 0 then
    Considera(Trascorsi, (FDimensioneMassimaMb - DimensioneRegistriMb) / FCrescitaLog,
      Format('si chiude la registrazione: %d MB', [FDimensioneMassimaMb]));

  if FRegistratore <> nil then
  begin
    Trascorsi := SecondsBetween(now, FInizioVideo);
    Considera(Trascorsi, FDurataMassimaVideoMinuti * 60 - Trascorsi, Format('si ferma il filmato: %d minuti',
      [FDurataMassimaVideoMinuti]));
    if FCrescitaVideo > 0 then
      Considera(Trascorsi, (FDimensioneMassimaVideoMb - DimensioneVideoMb) / FCrescitaVideo,
        Format('si ferma il filmato: %d MB', [FDimensioneMassimaVideoMb]));
  end;
end;

function TzSessioneLog.LimiteImminente: boolean;
var
  Residuo: TzTempoResiduo;
begin
  Residuo := TempoResiduo;
  result := (Residuo.Secondi >= 0) and (Residuo.Secondi < 120);
end;

// A un minuto dal limite: avviso non modale, cosi' l'utente ha il tempo di
// mettere un segnalibro o di chiudere lui la registrazione.
procedure TzSessioneLog.AvvisaLimiteImminente;
var
  Residuo: TzTempoResiduo;
begin
  if FAvvisoLimiteDato then
    Exit;
  Residuo := TempoResiduo;
  if (Residuo.Secondi < 0) or (Residuo.Secondi > 60) then
    Exit;
  FAvvisoLimiteDato := True;
  dx.Alert('Registrazione quasi al limite', Format('Fra circa %s %s.' + sLineBreak +
    'Se il problema non si e'' ancora presentato, metti un segnalibro o chiudi tu la registrazione con %s.',
    [TestoDurata(Residuo.Secondi), Residuo.Motivo, FTestoScorciatoia]));
end;

function TzSessioneLog.DurataSecondi: Integer;
begin
  if FAttiva then
    result := SecondsBetween(now, FInizio)
  else
    result := 0;
end;

function TzSessioneLog.GetPausaVideo: boolean;
begin
  result := (FRegistratore <> nil) and FRegistratore.Pausa;
end;

procedure TzSessioneLog.SetPausaVideo(const AValore: boolean);
begin
  if (FRegistratore = nil) or (FRegistratore.Pausa = AValore) then
    Exit;
  FRegistratore.Pausa := AValore;
  if AValore then
    TracciaValore('VIDEO.pausa', FormatDateTime('hh:nn:ss', now))
  else
    TracciaValore('VIDEO.ripresa', FormatDateTime('hh:nn:ss', now));
  NotificaStato;
end;

function TzSessioneLog.GetVideoAttivo: boolean;
begin
  result := FRegistratore <> nil;
end;

function TzSessioneLog.GetInvioInCorso: boolean;
begin
  result := FInvio <> nil;
end;

function TzSessioneLog.TestoInvio: string;
var
  Invio: TzInvioPartiVideo;
begin
  result := '';
  if FInvio = nil then
    Exit;
  Invio := TzInvioPartiVideo(FInvio);
  result := Format('Invio filmato: parte %d di %d', [Max(1, Invio.ParteCorrente), Length(Invio.Parti)]);
  if Invio.Terminated then
    result := result + ' (interruzione dopo questa parte)';
end;

procedure TzSessioneLog.InterrompiInvio;
begin
  if FInvio <> nil then
    FInvio.Terminate;
end;

procedure TzSessioneLog.AvviaInvioParti(ANumeroTicket: Integer; const AParti: TArray<string>);
begin
  // Un invio precedente ancora in corso (registrazione breve chiusa subito
  // dopo un'altra) va avanti da solo; il nuovo parte comunque.
  if FInvio <> nil then
    FInvio.OnTerminate := nil;
  FInvio := TzInvioPartiVideo.Create(TzExceptionManager.MantisServerParams, ANumeroTicket, FIdentificativo, AParti);
  FInvio.OnTerminate := InvioTerminato;
  FInvio.Start;
  NotificaStato;
end;

// Nel thread principale (OnTerminate): esito all'utente. I file restano su
// disco in ogni caso; il messaggio dice dove, se qualcosa non e' arrivato.
procedure TzSessioneLog.InvioTerminato(Sender: TObject);
var
  Invio: TzInvioPartiVideo;
  Elenco: string;
  Parte: string;
begin
  // Il thread si libera da solo subito dopo (FreeOnTerminate): qui si
  // leggono gli esiti e si toglie il riferimento.
  Invio := TzInvioPartiVideo(Sender);
  if FInvio = Invio then
    FInvio := nil;

  FOrigineCorrente := ocScorciatoia; // avviso non modale: l'utente sta lavorando
  if Length(Invio.NonInviate) = 0 then
    Mostra('Filmato inviato', Format('Ticket #%d: %d parti del filmato allegate.', [Invio.Ticket, Length(Invio.Inviate)]),
      tmInformazione)
  else
  begin
    Elenco := '';
    for Parte in Invio.NonInviate do
      Elenco := Elenco + sLineBreak + ExtractFileName(Parte);
    Mostra('Filmato inviato in parte', Format('Ticket #%d: %d parti allegate su %d.', [Invio.Ticket, Length(Invio.Inviate),
      Length(Invio.Parti)]) + sLineBreak + string.Join(sLineBreak, Invio.Errori) + sLineBreak + sLineBreak +
      'Le parti non inviate restano in' + sLineBreak + ExtractFilePath(Invio.NonInviate[0]) + Elenco, tmAvviso);
  end;
  NotificaStato;
end;

procedure TzSessioneLog.VerificaSessioneInterrotta;
var
  Cartella, Nome: string;
  Marcatore: TStringList;
  Log, Sil, Csv, Monitor, Sessione, Postazione: string;
  Nota, NotaAvvio: string;
  Parti, Escluse: TArray<string>;
  Parte: string;
begin
  if FAttiva then
  begin
    // Registrazione partita dall'avvio: ora l'accesso e' fatto, si completa
    // l'intestazione e si avvisa l'utente, che altrimenti non saprebbe
    // perche' l'applicazione e' piu' lenta. Le sessioni interrotte si
    // lasciano al prossimo avvio: fra i marcatori c'e' anche quello della
    // sessione in corso.
    if FAvviataAllAvvio and not FIdentitaCompletata then
    begin
      FIdentitaCompletata := True;
      Traccia('--- ACCESSO COMPLETATO ---');
      ScriviIdentita;
      ScriviContesto('CONTESTO DOPO L''ACCESSO');
      FOrigineCorrente := ocScorciatoia;
      Mostra('Registrazione per l''assistenza in corso', Format('Sessione %s, avviata con l''applicazione come richiesto.' +
        sLineBreak + 'Riproduci il problema, poi premi %s o usa la voce di menu per chiudere il log e inviare la segnalazione.',
        [FIdentificativo, FTestoScorciatoia]), tmInformazione);
    end;
    Exit;
  end;

  // Se Mantis non e' configurato i marcatori restano dove sono: una
  // configurazione successiva potra' ancora recuperare quelle sessioni.
  if not Disponibile then
    Exit;

  try
    Cartella := CartellaEffettiva;
    for Nome in TDirectory.GetFiles(Cartella, '*' + EstensioneMarcatore) do
    begin
      Marcatore := TStringList.Create;
      try
        try
          Marcatore.LoadFromFile(Nome, TEncoding.UTF8);
        except
          // Marcatore illeggibile (file bloccato da antivirus o da un altro
          // processo, accesso negato): si passa al successivo, senza fermare
          // la scansione. Resta dov'e' e lo toglie la pulizia per eta'.
          Continue;
        end;
        Sessione := Marcatore.Values['sessione'];
        Postazione := Marcatore.Values['postazione'];
        Log := Marcatore.Values['log'];
        Sil := Marcatore.Values['sil'];
        Csv := Marcatore.Values['csv'];
        Monitor := Marcatore.Values['monitor']; // Mantis #183: assente nei marcatori vecchi
        NotaAvvio := NotaDaMarcatore(Marcatore.Values['nota']); // 2026-10-29: assente nei marcatori vecchi
        FInizio := DataDaMarcatore(Marcatore.Values['inizio'], now);
      finally
        FreeAndNil(Marcatore);
      end;

      // La cartella e' condivisa: le sessioni delle altre postazioni non si
      // toccano, nemmeno per cancellarne il marcatore. Quelle scritte prima
      // di questa versione non hanno la postazione e restano fino alla
      // pulizia per eta'.
      if not SameText(Postazione, NomePostazione) then
        Continue;

      // Stessa postazione ma un'altra istanza dell'applicazione ancora
      // aperta, con la registrazione in corso: la sessione non e' interrotta.
      if FileInUso(Log) or FileInUso(Sil) then
        Continue;

      // Il marcatore c'e' ancora: l'applicazione e' stata chiusa mentre la
      // registrazione era attiva.
      if TFile.Exists(Log) or TFile.Exists(Sil) then
        if ChiediConferma('La registrazione ' + Sessione + ' non e'' stata chiusa: ' +
          'l''applicazione e'' terminata mentre era attiva.' + sLineBreak + sLineBreak +
          'Invio ora la segnalazione all''assistenza?') then
        begin
          FIdentificativo := Sessione;
          // Anche il filmato, se c'era: senza, la sessione interrotta si
          // reinviava solo con il log. Le statistiche del filmato non ci sono
          // piu', quindi la descrizione ne riporta solo le parti.
          Parti := PartiFilmatoSuDisco(Cartella, Sessione, Escluse);
          FStatisticheVideo.Parti := nil;
          FillChar(FStatisticheVideo, SizeOf(FStatisticheVideo), 0);
          // Un invio di parti alla volta: con due sessioni interrotte la
          // seconda parte con il solo log, il filmato resta sul disco.
          if InvioInCorso and (Length(Parti) > 0) then
          begin
            Traccia('Sessione interrotta ' + Sessione + ': filmato non inviato, invio di un altro filmato in corso');
            Parti := nil;
          end;
          for Parte in Escluse do
            Traccia('Sessione interrotta ' + Sessione + ': parte del filmato incompleta, non inviata - ' +
              ExtractFileName(Parte));
          // 2026-10-29: la nota scritta all'avvio nella procedura guidata
          // e' nel marcatore e si reinvia cosi' com'e', senza chiederla di
          // nuovo; le sessioni avviate senza finestra (o scritte prima) non
          // ce l'hanno, e per loro la richiesta resta l'unico modo di averla.
          if NotaAvvio.Trim <> '' then
            InviaAMantis(NotaAvvio, Log, Sil, Csv, Monitor, Parti)
          else if ChiediNota(Nota) then
            InviaAMantis(Nota, Log, Sil, Csv, Monitor, Parti);
        end;

      try
        TFile.Delete(Nome);
      except
      end;
    end;
  except
  end;
end;

function TzSessioneLog.RichiestaAvvioPresente: boolean;
begin
  try
    result := TFile.Exists(FileRichiestaAvvio);
  except
    result := False;
  end;
end;

// 2026-10-29: cancellazione e scrittura della richiesta separate da
// CommutaRichiestaAvvio, perche' le usa anche la procedura guidata (Avvia).
function TzSessioneLog.AnnullaRichiestaAvvio: boolean;
begin
  FOrigineCorrente := ocMenu;
  try
    TFile.Delete(FileRichiestaAvvio);
  except
    on E: Exception do
    begin
      Mostra('Richiesta non annullata', 'Il file di richiesta non si puo'' cancellare:' + sLineBreak + E.Message, tmErrore);
      Exit(False);
    end;
  end;
  NotificaStato;
  result := True;
end;

// AConOpzioni = True: la richiesta porta le scelte e la nota della procedura
// guidata, che AvviaAllAvvio rilegge (voce opzioni=1). La nota e' in Base64
// su una riga, come nel marcatore .inCorso, perche' puo' avere piu' righe.
function TzSessioneLog.ScriviRichiestaAvvio(const AOpzioni: TzOpzioniRegistrazione; AConOpzioni: boolean): boolean;
const
  Valore: array [boolean] of string = ('0', '1');
var
  Contenuto: TStringList;
begin
  result := False;
  FOrigineCorrente := ocMenu;
  Contenuto := TStringList.Create;
  try
    Contenuto.AddPair('richiesta', FormatDateTime('yyyy-mm-dd hh:nn:ss', now));
    Contenuto.AddPair('utente', UserName);
    Contenuto.AddPair('postazione', NomePostazione);
    if AConOpzioni then
    begin
      Contenuto.AddPair('opzioni', '1');
      Contenuto.AddPair('tempiFetch', Valore[AOpzioni.TempiFetch]);
      Contenuto.AddPair('tempiGriglia', Valore[AOpzioni.TempiGriglia]);
      Contenuto.AddPair('invio', Valore[AOpzioni.InviaAllaFine]);
      Contenuto.AddPair('nota', NotaPerMarcatore(AOpzioni.Nota));
    end;
    try
      Contenuto.SaveToFile(FileRichiestaAvvio, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        Mostra('Richiesta non registrata', 'Il file di richiesta non si puo'' scrivere nella cartella dei log:' + sLineBreak +
          FileRichiestaAvvio + sLineBreak + sLineBreak + E.Message, tmErrore);
        Exit;
      end;
    end;
  finally
    FreeAndNil(Contenuto);
  end;
  NotificaStato;
  result := True;
end;

procedure TzSessioneLog.CommutaRichiestaAvvio;
begin
  FOrigineCorrente := ocMenu;

  if RichiestaAvvioPresente then
  begin
    if AnnullaRichiestaAvvio then
      Mostra('Richiesta annullata', 'Al prossimo avvio la registrazione non partira''.', tmInformazione);
    Exit;
  end;

  if not Disponibile then
    Exit;

  if not ChiediConferma('Alla prossima apertura dell''applicazione su questo computer partira'' da sola la registrazione ' +
    'dettagliata per l''assistenza, comprendendo anche l''accesso e il caricamento delle impostazioni.' + sLineBreak +
    sLineBreak + 'Mentre e'' attiva l''applicazione risulta piu'' lenta.' + sLineBreak +
    'Il log registra le operazioni svolte, comprese le ricerche e i dati usati come filtro, e verra'' allegato a un ticket visibile all''assistenza.'
    + sLineBreak + sLineBreak + 'Procedo?') then
    Exit;

  // Dalla voce di menu: senza opzioni, all'avvio valgono le predefinite.
  if not ScriviRichiestaAvvio(TzOpzioniRegistrazione.Predefinite, False) then
    Exit;

  Mostra('Registrazione richiesta', 'Chiudi l''applicazione e riaprila: la registrazione partira'' da sola.' + sLineBreak +
    'Dopo l''accesso comparira'' un avviso; quando hai riprodotto il problema, chiudi il log dalla voce di menu o con ' +
    FTestoScorciatoia + '.', tmInformazione);
end;

initialization

finalization

TzSessioneLog.Libera;

end.
