/**
 * diagnostica.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Dati tecnici del browser da allegare a una segnalazione all'assistenza:
 * servono a ricostruire cosa e' successo prima dell'errore, non solo l'errore.
 *
 * Si tengono in memoria, al massimo 10 per tipo:
 *  - le ultime richieste a zServer (metodo, indirizzo SENZA parametri, stato,
 *    durata), registrate da errorInterceptor;
 *  - gli ultimi messaggi di errore e di avviso della console del browser.
 *
 * Non si registrano mai i corpi delle richieste e delle risposte, ne' le
 * intestazioni, ne' i parametri degli indirizzi: possono contenere dati di
 * persone o credenziali. zServer ripulisce comunque il testo ricevuto.
 *
 * Il file non importa nulla dell'applicazione: lo usano l'interceptor e
 * SegnalazioniService, e nessuno dei due deve poter creare un giro di
 * importazioni.
 * ─────────────────────────────────────────────────────────────────────────────
 */

interface RichiestaRecente {
  ora: string;
  metodo: string;
  indirizzo: string;
  stato: number;
  durataMs: number;
}

const MASSIMO_VOCI = 10;
const LUNGHEZZA_MASSIMA_MESSAGGIO = 200;

const richieste: RichiestaRecente[] = [];
const messaggiConsole: string[] = [];

function oraLocale(quando: Date): string {
  const sfasamento = -quando.getTimezoneOffset();
  const segno = sfasamento >= 0 ? '+' : '-';
  const ore = String(Math.floor(Math.abs(sfasamento) / 60)).padStart(2, '0');
  const minuti = String(Math.abs(sfasamento) % 60).padStart(2, '0');
  const locale = new Date(quando.getTime() + sfasamento * 60000).toISOString().slice(0, 19);
  return `${locale}${segno}${ore}:${minuti}`;
}

function aggiungi<T>(elenco: T[], voce: T): void {
  elenco.push(voce);
  if (elenco.length > MASSIMO_VOCI) {
    elenco.shift();
  }
}

/** Registra una richiesta conclusa. Le richieste delle segnalazioni non contano. */
export function registraRichiesta(
  metodo: string,
  indirizzo: string,
  stato: number,
  durataMs: number,
): void {
  const senzaParametri = indirizzo.split(/[?#]/)[0];
  if (senzaParametri.includes('/segnalazioni')) {
    return;
  }
  aggiungi(richieste, {
    ora: oraLocale(new Date()).slice(11),
    metodo,
    indirizzo: senzaParametri,
    stato,
    durataMs: Math.round(durataMs),
  });
}

function comeTesto(valore: unknown): string {
  if (typeof valore === 'string') {
    return valore;
  }
  if (valore instanceof Error) {
    return `${valore.name}: ${valore.message}`;
  }
  try {
    return JSON.stringify(valore) ?? String(valore);
  } catch {
    return String(valore);
  }
}

function registraMessaggio(livello: 'error' | 'warn', argomenti: unknown[]): void {
  const testo = argomenti.map(comeTesto).join(' ').replace(/\s+/g, ' ').trim();
  // Il dettaglio delle richieste fallite sta gia' nell'errore segnalato.
  if (!testo || testo.startsWith('[HTTP Error]')) {
    return;
  }
  const taglio =
    testo.length > LUNGHEZZA_MASSIMA_MESSAGGIO
      ? `${testo.slice(0, LUNGHEZZA_MASSIMA_MESSAGGIO)}...`
      : testo;
  aggiungi(messaggiConsole, `${oraLocale(new Date()).slice(11)} [${livello}] ${taglio}`);
}

let avviata = false;

/** Comincia a registrare errori e avvisi della console. Si puo' chiamare piu' volte. */
export function avviaDiagnostica(): void {
  if (avviata) {
    return;
  }
  avviata = true;

  for (const livello of ['error', 'warn'] as const) {
    const originale = console[livello].bind(console);
    console[livello] = (...argomenti: unknown[]): void => {
      registraMessaggio(livello, argomenti);
      originale(...argomenti);
    };
  }

  window.addEventListener('error', (evento) => registraMessaggio('error', [evento.message]));
  window.addEventListener('unhandledrejection', (evento) =>
    registraMessaggio('error', [evento.reason]),
  );
}

/** Testo da allegare alla segnalazione: ora, schermo, richieste recenti, console. */
export function raccogliDatiTecnici(): string {
  const righe = [
    `Ora del browser: ${oraLocale(new Date())}`,
    `Schermo: ${window.innerWidth}x${window.innerHeight} (densita' ${window.devicePixelRatio})`,
    `Lingua: ${navigator.language}`,
    '',
    'Ultime richieste a zServer:',
    ...(richieste.length > 0
      ? richieste.map(
          (r) => `  ${r.ora} ${r.metodo} ${r.indirizzo} -> ${r.stato} (${r.durataMs} ms)`,
        )
      : ['  nessuna']),
    '',
    'Ultimi messaggi della console:',
    ...(messaggiConsole.length > 0 ? messaggiConsole.map((m) => `  ${m}`) : ['  nessuno']),
  ];
  return righe.join('\n');
}

avviaDiagnostica();
