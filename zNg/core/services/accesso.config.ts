/**
 * accesso.config.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Cio' che l'accesso di zNg (AuthService, authGuard, errorInterceptor,
 * registro degli errori) deve sapere dell'applicazione: sono solo testi e
 * percorsi, quindi entrano per token e zNg non importa nulla dell'applicazione.
 *
 * L'applicazione fornisce soltanto le voci che cambiano rispetto ai
 * predefiniti, in app.config.ts:
 *
 *   fornisciConfigurazioneAccesso({
 *     percorsoLogin: '/login-form',
 *     pagineDiAccesso: ['login-form', 'reset-password'],
 *     nomeApplicazione: 'Agorà',
 *   }),
 *
 * Senza provider valgono i predefiniti qui sotto.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { InjectionToken, Provider } from '@angular/core';

export interface ConfigurazioneAccesso {
  /** Pagina di login, con la barra iniziale: ci porta l'uscita o la sessione scaduta. */
  percorsoLogin: string;
  /** Pagina in cui torna chi ha gia' una sessione e apre una pagina di accesso. */
  percorsoIniziale: string;
  /**
   * Percorsi delle rotte di accesso (login, recupero password), come in
   * app.routes.ts e senza barra: con la guardia, chi ha gia' una sessione
   * valida non le vede e torna alla pagina iniziale.
   */
  pagineDiAccesso: string[];
  /**
   * Nome dell'applicazione: in testa al testo copiato di un errore, e da esso
   * l'identificativo della casella della nota e la funzione `<nome>Errori()`
   * della console in sviluppo.
   */
  nomeApplicazione: string;
  /**
   * Vero: un errore su una scrittura (POST, PUT, PATCH, DELETE) diventa un
   * avviso modale, perche' ferma l'operazione. Falso: resta una notifica.
   */
  avvisoModaleSuScrittura: boolean;
  /** Righe dell'avviso quando la scrittura viola una chiave esterna (FOREIGN KEY di Firebird). */
  messaggioChiaveEsterna: string[];
}

export const CONFIGURAZIONE_ACCESSO_PREDEFINITA: ConfigurazioneAccesso = {
  percorsoLogin: '/login',
  percorsoIniziale: '/',
  pagineDiAccesso: ['login'],
  nomeApplicazione: 'Applicazione',
  avvisoModaleSuScrittura: true,
  messaggioChiaveEsterna: ['Il dato è usato da altri dati e non si può eliminare.'],
};

export const ZZ_ACCESSO_CONFIG = new InjectionToken<ConfigurazioneAccesso>('ZZ_ACCESSO_CONFIG', {
  providedIn: 'root',
  factory: () => CONFIGURAZIONE_ACCESSO_PREDEFINITA,
});

/** Provider di ZZ_ACCESSO_CONFIG: le voci indicate, le altre dai predefiniti. */
export function fornisciConfigurazioneAccesso(voci: Partial<ConfigurazioneAccesso>): Provider {
  return {
    provide: ZZ_ACCESSO_CONFIG,
    useValue: { ...CONFIGURAZIONE_ACCESSO_PREDEFINITA, ...voci },
  };
}
