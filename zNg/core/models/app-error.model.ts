/**
 * app-error.model.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Definisce AppError, il tipo di errore applicativo condiviso da tutti i
 * servizi HTTP e dagli interceptor.
 *
 * FLUSSO:
 *   HttpErrorResponse
 *     └─► authInterceptor   → gestisce 401 (refresh / logout), passa il resto
 *     └─► errorInterceptor  → trasforma ogni HttpErrorResponse in AppError,
 *                             mostra notify, logga in console
 *     └─► AppError          → arriva al componente / service chiamante
 *
 * I SERVIZI non devono più fare catchError/handleError: ci pensa
 * errorInterceptor per tutti.
 * ─────────────────────────────────────────────────────────────────────────────
 */

// ─── Categorie di errore ──────────────────────────────────────────────────────

export type AppErrorCategory =
  | 'network' // status 0, CORS, server non raggiungibile
  | 'auth' // 401 (dopo che refreshToken fallisce → logout)
  | 'forbidden' // 403
  | 'not-found' // 404
  | 'validation' // 400, 422
  | 'server' // 5xx
  | 'unknown'; // tutto il resto

// ─── Classe principale ────────────────────────────────────────────────────────

/**
 * Errore applicativo normalizzato.
 *
 * Proprietà chiave per gli interceptor:
 * - `isAppError`  → guard type-safe (evita instanceof cross-bundle)
 * - `category`    → permette al chiamante di reagire in modo specifico
 * - `statusCode`  → codice HTTP originale (0 se network error)
 * - `devDetail`   → stringa tecnica completa, disponibile solo in devMode
 *
 * Esempio d'uso nel componente:
 *
 *   this.dataSvc.load().subscribe({
 *     error: (err: AppError) => {
 *       // err.message è già il messaggio corretto (dev o prod)
 *       // err.category può guidare comportamenti specifici
 *       if (err.category === 'validation') this.showFormErrors(err);
 *     }
 *   });
 */
export class AppError extends Error {
  /** Guard type-safe — preferibile a instanceof cross-bundle */
  readonly isAppError = true as const;

  /** Categoria semantica dell'errore */
  readonly category: AppErrorCategory;

  /** Codice HTTP originale (0 = errore di rete) */
  readonly statusCode: number;

  /**
   * Dettaglio tecnico completo: method, url, status, body del server.
   * Valorizzato solo in devMode (isDevMode() === true), stringa vuota in prod.
   */
  readonly devDetail: string;

  constructor(message: string, statusCode: number, category: AppErrorCategory, devDetail: string) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.category = category;
    this.devDetail = devDetail;
  }
}

// ─── Helper type-guard ────────────────────────────────────────────────────────

/** Ritorna true se `err` è un AppError (type-safe, cross-bundle) */
export function isAppError(err: unknown): err is AppError {
  return err instanceof AppError || (err as any)?.isAppError === true;
}
