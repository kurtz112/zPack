/**
 * auth.interceptor.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Interceptor HTTP funzionale (Angular 17+).
 *
 * RESPONSABILITÀ:
 *  1. Inietta il Bearer token in ogni richiesta non-auth
 *  2. Su 401: tenta il refresh del token e riprova la richiesta originale
 *  3. Se il refresh fallisce: sessione scaduta, login con l'avviso
 *  4. Non tocca AppError (già gestiti da errorInterceptor)
 *
 * ORDINE di registrazione (app.config.ts):
 *   withInterceptors([authInterceptor, errorInterceptor])
 *   authInterceptor viene PRIMA così può intercettare il 401 "grezzo"
 *   prima che errorInterceptor lo trasformi.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, switchMap, throwError } from 'rxjs';

import { isAppError } from '../models/app-error.model';
import { AuthService } from '../services/auth.service';
import { UrlService } from '../services/url.service';

// ─────────────────────────────────────────────────────────────────────────────

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth: AuthService = inject(AuthService);

  // ── Endpoint di autenticazione: passa direttamente ────────────────────────
  if (isAuthEndpoint(req.url, inject(UrlService).baseUrl)) {
    return next(req);
  }

  // ── Inietta Bearer token ───────────────────────────────────────────────────
  const token = auth.getAccessToken();
  const authReq = token ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : req;

  return next(authReq).pipe(
    catchError((error) => {
      // ── AppError già processato da errorInterceptor: lascia passare ────────
      // (non dovrebbe capitare con l'ordine corretto, ma è una safety guard)
      if (isAppError(error)) {
        return throwError(() => error);
      }

      // ── 401: tenta refresh, poi riprova; se fallisce → logout ──────────────
      if (error instanceof HttpErrorResponse && error.status === 401) {
        const refreshToken = auth.getRefreshToken();
        if (refreshToken) {
          return auth.refreshAccessToken().pipe(
            switchMap((response) => {
              const retryReq = req.clone({
                setHeaders: { Authorization: `Bearer ${response.token}` },
              });
              return next(retryReq);
            }),
            catchError((refreshError) => {
              // Rinnovo fallito: con un 401 AuthService ha gia' chiuso la
              // sessione e portato al login con il motivo; un secondo logout
              // rinavigherebbe senza motivo e l'avviso andrebbe perso. Resta
              // da chiudere solo se il rinnovo e' fallito per altro (rete).
              if (auth.getRefreshToken()) {
                auth.logout();
              }
              return throwError(() => refreshError);
            }),
          );
        }

        // Nessun token di rinnovo: la sessione e' scaduta (se e' gia' chiusa,
        // sessioneScaduta non fa nulla)
        auth.sessioneScaduta();
      }

      // ── Tutti gli altri errori: passa a errorInterceptor ──────────────────
      return throwError(() => error);
    }),
  );
};

// ─────────────────────────────────────────────────────────────────────────────

// Login, rinnovo e logout di zServer (TMVCJWTRefreshMiddleware) non vogliono il
// token di accesso, e un loro 401 non va rinnovato. Prima si cercava '/login'
// in qualunque indirizzo, che prendeva anche rotte con quel testo nel nome;
// poi si escludeva tutto /auth/, che toglieva il token anche alle rotte che lo
// vogliono (/auth/password, /auth/validate, /auth/logout-all): il cambio
// password partiva senza token e zServer rispondeva 401.
const ROTTE_SENZA_TOKEN = ['/auth/login', '/auth/refresh', '/auth/logout'];

function isAuthEndpoint(url: string, baseUrl: string): boolean {
  const percorso = url.split('?')[0];
  return ROTTE_SENZA_TOKEN.some((rotta) => percorso === `${baseUrl}${rotta}`);
}
