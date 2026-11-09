/**
 * error.interceptor.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Interceptor HTTP funzionale (Angular 17+) che gestisce globalmente tutti
 * gli errori HTTP non-401.
 *
 * RESPONSABILITÀ:
 *  1. Trasforma HttpErrorResponse → AppError (con messaggio dev o prod)
 *  2. Mostra una notifica DevExtreme all'utente (notify)
 *  3. Logga il dettaglio tecnico in console (sempre, anche in prod)
 *  4. Lascia passare i 401 senza toccarli: li gestisce authInterceptor
 *
 * ORDINE DI REGISTRAZIONE in app.config.ts:
 *   provideHttpClient(
 *     withInterceptors([
 *       authInterceptor,   // 1° — aggiunge token, gestisce 401/refresh/logout
 *       errorInterceptor,  // 2° — gestisce tutti gli altri errori
 *     ])
 *   )
 *
 * Il 401 che arriva qui è già stato processato da authInterceptor
 * (refresh tentato e fallito → logout già eseguito). errorInterceptor
 * lo ignora semplicemente, poiché l'utente viene già reindirizzato al login.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { HttpErrorResponse, HttpInterceptorFn, HttpResponse } from '@angular/common/http';
import { inject, isDevMode } from '@angular/core';
import notify from 'devextreme/ui/notify';
import { throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';

import { AppError, AppErrorCategory } from '../models/app-error.model';
import { ConfigurazioneAccesso, ZZ_ACCESSO_CONFIG } from '../services/accesso.config';
import { mostraAvviso } from '../services/avviso';
import { registraRichiesta } from '../services/diagnostica';
import {
  impostaNomeApplicazione,
  inviaSegnalazione,
  mostraErrore,
  registraErrore,
  VoceErrore,
} from '../services/registro-errori';
import { SegnalazioniService } from '../services/segnalazioni.service';
import { ERRORE_SILENZIOSO } from './errore-silenzioso';

// ─────────────────────────────────────────────────────────────────────────────

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  // Serve a sapere se offrire il pulsante "Segnala all'assistenza" (sezione
  // "mantis" attiva su zServer). Un interceptor funzionale gira in un contesto
  // di iniezione, quindi inject() vale qui, non dentro catchError.
  const segnalazioni = inject(SegnalazioniService);
  const accesso = inject(ZZ_ACCESSO_CONFIG);
  impostaNomeApplicazione(accesso.nomeApplicazione);

  const inizio = performance.now();

  return next(req).pipe(
    // Le ultime richieste finiscono nei dati tecnici di una segnalazione
    tap({
      next: (evento) => {
        if (evento instanceof HttpResponse) {
          registraRichiesta(req.method, req.url, evento.status, performance.now() - inizio);
        }
      },
    }),
    catchError((error) => {
      if (error instanceof HttpErrorResponse) {
        registraRichiesta(req.method, req.url, error.status, performance.now() - inizio);
      }

      // ── AppError già costruito (da un interceptor precedente) ─────────────
      // Non riprocessare — può capitare se la catena di interceptor è
      // configurata in modo non standard.
      if (error?.isAppError) {
        return throwError(() => error);
      }

      // ── 401: lascialo passare — authInterceptor ha già fatto logout ───────
      // Non mostrare notify, non loggare: la redirect al login è sufficiente.
      if (error instanceof HttpErrorResponse && error.status === 401) {
        return throwError(() => error);
      }

      // ── Tutto il resto: trasforma in AppError ─────────────────────────────
      if (error instanceof HttpErrorResponse) {
        const appError = buildAppError(error, req.method, req.url);

        if (req.context.get(ERRORE_SILENZIOSO)) {
          return throwError(() => appError);
        }

        // Registro degli errori: in sviluppo la notifica si copia con un clic.
        // Il testo e' sempre quello tecnico, anche in produzione (dove
        // AppError.devDetail e' vuoto): e' quello che l'utente puo' segnalare.
        const voce = registraErrore(
          dettaglioTecnico(error, req.method, req.url) || appError.message,
        );

        // Una scrittura non riuscita ferma l'operazione: avviso modale. Una
        // lettura resta notifica, per non interrompere chi sta lavorando.
        // (l'accesso, /auth/, ha le sue pagine e i suoi messaggi). Si spegne
        // con ZZ_ACCESSO_CONFIG.avvisoModaleSuScrittura.
        if (
          accesso.avvisoModaleSuScrittura &&
          METODI_DI_SCRITTURA.has(req.method.toUpperCase()) &&
          !req.url.includes('/auth/')
        ) {
          void mostraAvvisoScrittura(appError, voce, segnalazioni, accesso);
        } else {
          showNotify(appError, voce, segnalazioni);
        }

        // Log completo sempre in console (per diagnostica anche in prod)
        console.error(`[HTTP Error] ${appError.devDetail || appError.message}`);

        return throwError(() => appError);
      }

      // ── Errore non-HTTP (es. bug nel codice RxJS) ─────────────────────────
      console.error('[Unexpected Error]', error);
      return throwError(() => error);
    }),
  );
};

// ─── Costruisce AppError da HttpErrorResponse ─────────────────────────────────

function buildAppError(error: HttpErrorResponse, method: string, url: string): AppError {
  const dev = isDevMode();
  const status = error.status;
  const category = resolveCategory(status, error);

  // Estrae il messaggio utile dal corpo della risposta
  const serverMessage = extractServerMessage(error);

  // Dettaglio tecnico completo (sempre costruito, usato per console + dev UI)
  const devDetail = dettaglioTecnico(error, method, url);

  // Messaggio utente
  const userMessage = buildUserMessage(status, category, serverMessage, devDetail, dev);

  return new AppError(userMessage, status, category, dev ? devDetail : '');
}

// ─── Dettaglio tecnico ────────────────────────────────────────────────────────

/** Richiesta, stato e messaggio del server: il testo che si copia o si segnala. */
function dettaglioTecnico(error: HttpErrorResponse, method: string, url: string): string {
  const serverMessage = extractServerMessage(error);

  return [
    `${method} ${url}`,
    `HTTP ${error.status} ${error.statusText || ''}`.trimEnd(),
    serverMessage ? `Server: ${serverMessage}` : '',
    error.error && typeof error.error === 'object' && !serverMessage
      ? `Body: ${JSON.stringify(error.error)}`
      : '',
  ]
    .filter(Boolean)
    .join('\n');
}

// ─── Categoria semantica ──────────────────────────────────────────────────────

function resolveCategory(status: number, error: HttpErrorResponse): AppErrorCategory {
  if (status === 0 || error.error instanceof ErrorEvent) return 'network';
  if (status === 401) return 'auth';
  if (status === 403) return 'forbidden';
  if (status === 404) return 'not-found';
  if (status === 400 || status === 422) return 'validation';
  if (status >= 500) return 'server';
  return 'unknown';
}

// ─── Estrae messaggio dal body della risposta ─────────────────────────────────

function extractServerMessage(error: HttpErrorResponse): string {
  if (typeof error.error === 'string' && error.error.trim()) {
    return error.error.trim();
  }
  if (error.error && typeof error.error === 'object') {
    return (
      error.error.message || error.error.title || error.error.detail || error.error.error || ''
    );
  }
  return '';
}

// ─── Messaggio utente: completo in dev, generico in prod ──────────────────────

function buildUserMessage(
  status: number,
  category: AppErrorCategory,
  serverMessage: string,
  devDetail: string,
  dev: boolean,
): string {
  switch (category) {
    case 'network':
      return dev
        ? `Errore di rete\n${devDetail}`
        : 'Impossibile contattare il server. Verificare la connessione.';

    case 'forbidden':
      return dev
        ? `Accesso negato (403)\n${devDetail}`
        : "Operazione non consentita. Contattare l'amministratore.";

    case 'not-found':
      return dev ? `Risorsa non trovata (404)\n${devDetail}` : 'Risorsa non trovata.';

    case 'validation': {
      // Il messaggio del server è utile anche in prod (es. "Campo X obbligatorio")
      const base = serverMessage || `Dati non validi (${status})`;
      return dev ? `${base}\n${devDetail}` : base;
    }

    case 'server':
      return dev
        ? `Errore server (${status})\n${devDetail}`
        : "Si è verificato un errore sul server. Riprovare o contattare l'assistenza.";

    default:
      return dev
        ? `Errore ${status}\n${devDetail}`
        : `Si è verificato un errore (${status}). Riprovare.`;
  }
}

// ─── Notifica DevExtreme ──────────────────────────────────────────────────────

/**
 * Mostra una notifica dx-notify appropriata per categoria.
 *
 * Regole:
 * - validation (400/422): 'warning', timeout lungo (6s) — l'utente deve leggere
 * - server (5xx):         'error',   timeout 5s
 * - network:              'error',   timeout 5s
 * - forbidden/not-found:  'warning', timeout 4s
 * - altri:                'error',   timeout 4s
 *
 * I messaggi di dettaglio tecnico in dev vengono troncati a 300 caratteri
 * per evitare notify enormi; il testo completo è sempre in console.
 */
function showNotify(appError: AppError, voce: VoceErrore, segnalazioni: SegnalazioniService): void {
  const dev = isDevMode();
  const maxLength = 300;

  // In dev mostra il dettaglio tecnico (troncato); in prod il messaggio utente
  const rawMessage = dev && appError.devDetail ? appError.devDetail : appError.message;

  const displayMessage =
    rawMessage.length > maxLength ? rawMessage.slice(0, maxLength) + '…' : rawMessage;

  const { type, displayTime } = notifyConfig(appError.category);

  // In sviluppo la notifica resta di piu' e si copia con un clic, testo
  // completo compreso (registro-errori.ts)
  if (dev) {
    mostraErrore(voce, displayMessage, type, Math.max(displayTime, 10000), true, segnalazioni);
    return;
  }

  // In produzione, se zServer ha la segnalazione attiva, la notifica porta il
  // pulsante "Segnala all'assistenza" e resta il tempo di premerlo.
  if (segnalazioni.abilitata()) {
    mostraErrore(voce, displayMessage, type, Math.max(displayTime, 10000), false, segnalazioni);
    return;
  }

  notify(
    {
      message: displayMessage,
      type,
      displayTime,
      position: { at: 'bottom right', my: 'bottom right', offset: '-12 -12' },
      closeOnClick: true,
    },
    type,
    displayTime,
  );
}

const METODI_DI_SCRITTURA = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);

// Firebird: "violation of FOREIGN KEY constraint ... on table ..."
const VIOLAZIONE_CHIAVE_ESTERNA = /FOREIGN KEY/i;

/**
 * Avviso modale per un errore su una scrittura (inserimento, modifica,
 * cancellazione). La violazione di una chiave esterna diventa le righe di
 * ZZ_ACCESSO_CONFIG.messaggioChiaveEsterna: la voce e' usata altrove e non si
 * puo' cancellare. In sviluppo si mostra il dettaglio tecnico, in produzione
 * il messaggio per l'utente; se zServer ha la segnalazione attiva, l'avviso
 * porta "Segnala all'assistenza".
 */
async function mostraAvvisoScrittura(
  appError: AppError,
  voce: VoceErrore,
  segnalazioni: SegnalazioniService,
  accesso: ConfigurazioneAccesso,
): Promise<void> {
  const tecnico = `${appError.devDetail} ${appError.message}`;
  const righe = VIOLAZIONE_CHIAVE_ESTERNA.test(tecnico)
    ? accesso.messaggioChiaveEsterna
    : [isDevMode() && appError.devDetail ? appError.devDetail : appError.message];
  const azioni = segnalazioni.abilitata()
    ? [{ testo: "Segnala all'assistenza", azione: () => inviaSegnalazione(voce, segnalazioni) }]
    : [];
  await mostraAvviso('Operazione non riuscita', righe, azioni);
}

function notifyConfig(category: AppErrorCategory): {
  type: 'error' | 'warning';
  displayTime: number;
} {
  switch (category) {
    case 'validation':
      return { type: 'warning', displayTime: 6000 };
    case 'forbidden':
      return { type: 'warning', displayTime: 4000 };
    case 'not-found':
      return { type: 'warning', displayTime: 4000 };
    case 'network':
      return { type: 'error', displayTime: 5000 };
    case 'server':
      return { type: 'error', displayTime: 5000 };
    default:
      return { type: 'error', displayTime: 4000 };
  }
}
