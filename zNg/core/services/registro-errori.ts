/**
 * registro-errori.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Ultimi errori dell'applicazione, tenuti in memoria (al massimo 50) per
 * poterli copiare e incollare in una segnalazione senza ricopiarli a mano.
 *
 * Chi registra:
 *  - errorInterceptor, per gli errori delle chiamate a zServer;
 *  - RegistroErroriHandler, per gli errori imprevisti del codice.
 *
 * Solo in sviluppo (isDevMode):
 *  - la notifica dell'errore si copia con un clic;
 *  - Ctrl+Maiusc+E copia l'ultimo errore da qualunque punto della pagina;
 *  - <nome>Errori() nella console del browser copia tutti gli errori
 *    registrati (agoraErrori() in Agorà, gestywebErrori() in GestyWeb).
 * Ctrl+Alt non si usa: sulle tastiere italiane e' AltGr, e AltGr+E scrive €.
 *
 * Il nome dell'applicazione (ZZ_ACCESSO_CONFIG.nomeApplicazione) lo imposta
 * chi ha l'iniettore: RegistroErroriHandler all'avvio, errorInterceptor alla
 * prima richiesta.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { ErrorHandler, inject, Injectable, isDevMode } from '@angular/core';
import { custom } from 'devextreme/ui/dialog';
import notify from 'devextreme/ui/notify';

import { isAppError } from '../models/app-error.model';
import { ZZ_ACCESSO_CONFIG } from './accesso.config';

export interface VoceErrore {
  quando: Date;
  pagina: string;
  testo: string;
  /** Numero del ticket Mantis, dopo che l'utente ha segnalato l'errore (0 = inviato, numero non noto). */
  segnalazione?: number;
}

const MASSIMO_VOCI = 50;
const voci: VoceErrore[] = [];

let nomeApplicazione = 'Applicazione';
// Il nome senza accenti, spazi e simboli: per gli id della pagina e la funzione della console
let identificativo = 'applicazione';

/** Nome in testa al testo copiato; in sviluppo registra anche `<nome>Errori()` nella console. */
export function impostaNomeApplicazione(nome: string): void {
  if (nome === nomeApplicazione) {
    return;
  }
  const precedente = identificativo;
  nomeApplicazione = nome;
  identificativo =
    nome
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/[^a-z0-9]/gi, '')
      .toLowerCase() || 'applicazione';

  if (isDevMode()) {
    const finestra = window as unknown as Record<string, unknown>;
    delete finestra[`${precedente}Errori`];
    finestra[`${identificativo}Errori`] = copiaTuttiGliErrori;
  }
}

function copiaTuttiGliErrori(): string {
  const testo = voci.map(testoDaCopiare).join('\n\n----------\n\n') || 'Nessun errore registrato';
  void copiaConAvviso(testo, `${voci.length} errori copiati`);
  return testo;
}

export function registraErrore(testo: string): VoceErrore {
  const voce: VoceErrore = { quando: new Date(), pagina: window.location.href, testo };
  voci.push(voce);
  if (voci.length > MASSIMO_VOCI) {
    voci.shift();
  }
  return voce;
}

/** Testo completo da incollare in una segnalazione: ora, pagina e dettaglio. */
export function testoDaCopiare(voce: VoceErrore): string {
  return [
    `${nomeApplicazione} - ${voce.quando.toLocaleString('it-IT')}`,
    `Pagina: ${voce.pagina}`,
    voce.testo,
  ].join('\n');
}

async function copiaNegliAppunti(testo: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(testo);
    return true;
  } catch {
    // navigator.clipboard richiede https o localhost: su http con un altro
    // indirizzo resta la copia alla vecchia maniera.
    const area = document.createElement('textarea');
    area.value = testo;
    area.style.position = 'fixed';
    area.style.opacity = '0';
    document.body.appendChild(area);
    area.select();
    const copiato = document.execCommand('copy');
    area.remove();
    return copiato;
  }
}

async function copiaConAvviso(testo: string, cosa: string): Promise<void> {
  const copiato = await copiaNegliAppunti(testo);
  notify(
    copiato ? `${cosa} negli appunti` : "Copia non riuscita: il testo e' nella console",
    copiato ? 'success' : 'warning',
    2000,
  );
  if (!copiato) {
    console.log(testo);
  }
}

export function copiaErrore(voce: VoceErrore): Promise<void> {
  return copiaConAvviso(testoDaCopiare(voce), 'Errore copiato');
}

/**
 * Chi sa inviare una segnalazione all'assistenza (SegnalazioniService). Tenuto
 * come interfaccia perche' questo file non deve importare il servizio: il
 * servizio passa dall'interceptor, che importa questo file.
 */
export interface Segnalatore {
  abilitata(): boolean;
  segnala(dati: { pagina: string; testo: string }, nota: string): Promise<number>;
}

/**
 * Chiede all'utente una nota facoltativa prima di inviare. Restituisce il testo
 * (anche vuoto) se conferma, null se annulla.
 */
async function chiediNota(): Promise<string | null> {
  const IDENTIFICATIVO_NOTA = `${identificativo}-nota-segnalazione`;
  let nota = '';
  const dialogo = custom({
    title: "Segnala all'assistenza",
    messageHtml:
      '<div style="max-width:420px">' +
      "<p>Verranno inviati all'assistenza l'errore e la pagina in cui è comparso. " +
      'Se vuoi, aggiungi una nota su cosa stavi facendo.</p>' +
      `<textarea id="${IDENTIFICATIVO_NOTA}" rows="4" maxlength="2000" ` +
      'style="width:100%;box-sizing:border-box;font:inherit"></textarea></div>',
    buttons: [
      {
        text: 'Invia',
        type: 'default',
        stylingMode: 'contained',
        onClick: () => {
          const campo = document.getElementById(IDENTIFICATIVO_NOTA) as HTMLTextAreaElement | null;
          nota = campo?.value.trim() ?? '';
          return 'invia';
        },
      },
      { text: 'Annulla', stylingMode: 'text', onClick: () => 'annulla' },
    ],
  });

  const scelta = await dialogo.show();
  return scelta === 'invia' ? nota : null;
}

/** Chiede la nota e invia la segnalazione (anche dall'avviso modale degli errori). */
export async function inviaSegnalazione(voce: VoceErrore, segnalatore: Segnalatore): Promise<void> {
  const nota = await chiediNota();
  if (nota === null) {
    return;
  }

  try {
    const idTicket = await segnalatore.segnala(voce, nota);
    voce.segnalazione = idTicket;
    notify(
      idTicket > 0
        ? `Segnalazione n. ${idTicket} inviata all'assistenza`
        : "Segnalazione inviata all'assistenza",
      'success',
      4000,
    );
  } catch (errore) {
    notify(errore instanceof Error ? errore.message : 'Segnalazione non riuscita', 'warning', 6000);
  }
}

const IDENTIFICATIVO_STILE = 'segnala-assistenza-stile';

// Lo stile del pulsante sta in un foglio proprio perche' hover, pressione e
// focus da tastiera non si possono scrivere in uno style inline.
function assicuraStilePulsante(): void {
  if (document.getElementById(IDENTIFICATIVO_STILE)) {
    return;
  }
  const stile = document.createElement('style');
  stile.id = IDENTIFICATIVO_STILE;
  stile.textContent =
    '.segnala-assistenza{display:inline-flex;align-items:center;gap:8px;background:#fff;color:#1b1b1b;' +
    'border:0;border-radius:999px;padding:8px 18px 8px 14px;font:inherit;font-weight:600;' +
    'letter-spacing:.01em;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.25);' +
    'transition:transform .12s ease,box-shadow .12s ease}' +
    '.segnala-assistenza:hover{transform:translateY(-1px);box-shadow:0 3px 8px rgba(0,0,0,.3)}' +
    '.segnala-assistenza:active{transform:none;box-shadow:0 1px 2px rgba(0,0,0,.3)}' +
    '.segnala-assistenza:focus-visible{outline:2px solid #fff;outline-offset:2px}' +
    '.segnala-assistenza .dx-icon{font-size:16px;width:16px;height:16px;line-height:16px}';
  document.head.appendChild(stile);
}

// Errori che arrivano nello stesso istante (per esempio piu' richieste che
// falliscono aprendo una pagina) diventano una sola notifica con un solo
// pulsante: la segnalazione porta tutti i testi.
interface ErroreInAttesa {
  voce: VoceErrore;
  messaggio: string;
  tipo: 'error' | 'warning';
  durata: number;
  conCopia: boolean;
  segnalatore: Segnalatore;
}

const ATTESA_RAGGRUPPAMENTO_MS = 400;
const MASSIMO_TESTI_RAGGRUPPATI = 10;
// Il tempo di notare il pulsante e premerlo.
const DURATA_NOTIFICA_SEGNALABILE_MS = 30000;

let erroriInAttesa: ErroreInAttesa[] = [];
let timerRaggruppamento: ReturnType<typeof setTimeout> | undefined;

function mostraGruppo(): void {
  const gruppo = erroriInAttesa;
  erroriInAttesa = [];
  timerRaggruppamento = undefined;
  if (gruppo.length === 0) {
    return;
  }

  const primo = gruppo[0];
  const durata = Math.max(primo.durata, DURATA_NOTIFICA_SEGNALABILE_MS);
  if (gruppo.length === 1) {
    mostraNotifica(
      primo.voce,
      primo.messaggio,
      primo.tipo,
      durata,
      primo.conCopia,
      primo.segnalatore,
    );
    return;
  }

  const altri = gruppo.length - 1;
  const unita: VoceErrore = {
    quando: primo.voce.quando,
    pagina: primo.voce.pagina,
    testo: gruppo
      .slice(0, MASSIMO_TESTI_RAGGRUPPATI)
      .map((errore, indice) => `[${indice + 1} di ${gruppo.length}] ${errore.voce.testo}`)
      .join('\n\n----------\n\n'),
  };
  mostraNotifica(
    unita,
    `${primo.messaggio}\n\n+ altri ${altri} ${altri === 1 ? 'errore' : 'errori'} nello stesso momento`,
    gruppo.some((errore) => errore.tipo === 'error') ? 'error' : 'warning',
    durata,
    primo.conCopia,
    primo.segnalatore,
  );
}

/**
 * Notifica di un errore. Se conCopia (sviluppo), un clic copia il testo
 * completo, anche la parte che la notifica taglia. Se il segnalatore e'
 * attivo compare il pulsante "Segnala all'assistenza", che invia l'errore a
 * zServer e da li' a Mantis; una volta inviato mostra il numero del ticket
 * invece di proporre di nuovo l'invio. Con il segnalatore attivo la notifica
 * resta 30 secondi e gli errori ravvicinati si raggruppano in una sola.
 */
export function mostraErrore(
  voce: VoceErrore,
  messaggio: string,
  tipo: 'error' | 'warning',
  durata: number,
  conCopia: boolean,
  segnalatore?: Segnalatore,
): void {
  if (!segnalatore?.abilitata()) {
    mostraNotifica(voce, messaggio, tipo, durata, conCopia, segnalatore);
    return;
  }

  erroriInAttesa.push({ voce, messaggio, tipo, durata, conCopia, segnalatore });
  if (timerRaggruppamento === undefined) {
    timerRaggruppamento = setTimeout(mostraGruppo, ATTESA_RAGGRUPPAMENTO_MS);
  }
}

function mostraNotifica(
  voce: VoceErrore,
  messaggio: string,
  tipo: 'error' | 'warning',
  durata: number,
  conCopia: boolean,
  segnalatore?: Segnalatore,
): void {
  notify(
    {
      type: tipo,
      displayTime: durata,
      maxWidth: 560,
      position: { at: 'bottom right', my: 'bottom right', offset: '-12 -12' },
      closeOnClick: true,
      contentTemplate: () => {
        const corpo = document.createElement('div');
        corpo.style.whiteSpace = 'pre-wrap';
        corpo.textContent = messaggio;

        if (conCopia) {
          corpo.style.cursor = 'copy';
          corpo.title = "Clic: copia l'errore completo";
          corpo.addEventListener('click', () => void copiaErrore(voce));

          const suggerimento = document.createElement('div');
          suggerimento.style.marginTop = '6px';
          suggerimento.style.opacity = '0.8';
          suggerimento.style.fontSize = '0.85em';
          suggerimento.textContent = "Clic per copiare - Ctrl+Maiusc+E copia l'ultimo errore";
          corpo.appendChild(suggerimento);
        }

        if (segnalatore?.abilitata()) {
          const riga = document.createElement('div');
          riga.style.marginTop = '8px';

          if (voce.segnalazione !== undefined) {
            riga.style.opacity = '0.85';
            riga.textContent =
              voce.segnalazione > 0 ? `Segnalato (n. ${voce.segnalazione})` : 'Segnalato';
          } else {
            const pulsante = document.createElement('button');
            pulsante.type = 'button';
            pulsante.className = 'segnala-assistenza';
            assicuraStilePulsante();
            const icona = document.createElement('i');
            icona.className = 'dx-icon dx-icon-comment';
            pulsante.appendChild(icona);
            pulsante.appendChild(document.createTextNode("Segnala all'assistenza"));
            pulsante.addEventListener('click', (evento) => {
              // il clic sul pulsante non deve chiudere la notifica ne' copiare l'errore
              evento.stopPropagation();
              void inviaSegnalazione(voce, segnalatore);
            });
            riga.appendChild(pulsante);
          }
          corpo.appendChild(riga);
        }

        return corpo;
      },
    },
    tipo,
    durata,
  );
}

/** Notifica di un errore in sviluppo: un clic copia il testo completo. */
export function mostraErroreSviluppo(
  voce: VoceErrore,
  messaggio: string,
  tipo: 'error' | 'warning',
  durata: number,
): void {
  mostraErrore(voce, messaggio, tipo, durata, true);
}

/** Errori imprevisti del codice: li registra e, in sviluppo, li mostra copiabili. */
@Injectable()
export class RegistroErroriHandler extends ErrorHandler {
  constructor() {
    super();
    impostaNomeApplicazione(inject(ZZ_ACCESSO_CONFIG).nomeApplicazione);
  }

  override handleError(error: unknown): void {
    // Un AppError arriva qui quando chi ha fatto la chiamata non gestisce
    // l'errore: errorInterceptor l'ha gia' registrato e mostrato.
    if (!isAppError(error)) {
      const testo =
        error instanceof Error
          ? `${error.name}: ${error.message}\n${error.stack ?? ''}`
          : String(error);
      const voce = registraErrore(testo);
      if (isDevMode()) {
        mostraErroreSviluppo(
          voce,
          `Errore imprevisto nel codice\n${testo.slice(0, 300)}`,
          'error',
          10000,
        );
      }
    }
    super.handleError(error);
  }
}

if (isDevMode()) {
  document.addEventListener('keydown', (evento: KeyboardEvent) => {
    if (evento.ctrlKey && evento.shiftKey && !evento.altKey && evento.key.toLowerCase() === 'e') {
      evento.preventDefault();
      const ultima = voci[voci.length - 1];
      if (ultima) {
        void copiaErrore(ultima);
      } else {
        notify('Nessun errore registrato', 'info', 2000);
      }
    }
  });

  (window as unknown as Record<string, unknown>)[`${identificativo}Errori`] = copiaTuttiGliErrori;
}
