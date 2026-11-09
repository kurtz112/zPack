/**
 * user-capabilities.service.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Deriva i permessi UI dal ruolo utente presente nel JWT.
 *
 * Centralizza la logica "chi può fare cosa" in un unico punto.
 * Espone signal computed reattivi che si aggiornano automaticamente
 * quando l'utente si autentica o cambia ruolo.
 *
 * I componenti (zz-data-grid, zz-form, ecc.) iniettano questo servizio
 * e leggono i signal — nessun input manuale [showDevTools] necessario.
 *
 * Il ruolo arriva da ZZ_RUOLO_UTENTE: di norma il tipo_user del token
 * dell'AuthService di zNg. Un'applicazione con un altro accesso lo fornisce
 * in app.config.ts; la funzione deve leggere un signal, così i computed qui
 * sotto si aggiornano da soli all'accesso e all'uscita.
 *
 * Configurazione ruoli:
 *  - I ruoli abilitati al devTools sono definiti in DEV_TOOLS_ROLES
 *  - Per aggiungere un ruolo, basta aggiungerlo al Set
 *  - Il claim JWT atteso è 'tipo_user' (stringa singola)
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { computed, inject, Injectable, InjectionToken } from '@angular/core';

import { AuthService } from './auth.service';

/** Ruolo dell'utente collegato (tipo_user del JWT), stringa vuota se nessuno. */
export const ZZ_RUOLO_UTENTE = new InjectionToken<() => string>('ZZ_RUOLO_UTENTE', {
  providedIn: 'root',
  factory: () => {
    const auth = inject(AuthService);
    return () => (auth.currentUser()?.['tipo_user'] as string) ?? '';
  },
});

// ── Ruoli abilitati ai Dev Tools ─────────────────────────────────────────────
// Valori di tipo_user nel JWT:
//   'A' = Amministratore
//   'D' = Developer
//   'U' = Utente standard
// Modificare questo Set per cambiare chi ha accesso ai menu di design-time.

const DEV_TOOLS_ROLES: ReadonlySet<string> = new Set([
  'X', // Super
  'Y', // non usato
]);

// ─────────────────────────────────────────────────────────────────────────────

@Injectable({ providedIn: 'root' })
export class UserCapabilitiesService {
  private ruoloUtente = inject(ZZ_RUOLO_UTENTE);

  // ── Signal derivati dal ruolo utente ─────────────────────────────────────

  /** Ruolo corrente dell'utente (mappato da tipo_user nel JWT) */
  readonly role = computed(() => this.ruoloUtente());

  /** Abilitazione DevTools (menu design-time, anteprima JSON, ecc.) */
  readonly canDevTools = computed(() => DEV_TOOLS_ROLES.has(this.role()));

  /** Abilitazione export dati */
  readonly canExport = computed(() => this.role() !== '');

  /** Abilitazione scrittura (insert/update/delete) — tutti tranne ospiti */
  readonly canWrite = computed(() => ['A', 'D', 'U'].includes(this.role()));
}
