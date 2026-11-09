/**
 * auth.service.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Sessione verso zServer: login con JWT, rinnovo automatico due minuti prima
 * della scadenza, logout che revoca il token di rinnovo sul server. I token
 * stanno in sessionStorage (si perdono alla chiusura della scheda); se
 * sessionStorage non c'e' (navigazione privata, anteprime) la sessione vive
 * solo in memoria.
 *
 * Pagina di login e pagina iniziale arrivano da ZZ_ACCESSO_CONFIG. Un'
 * applicazione che ha bisogno di altri metodi (Agorà: quelli dei form del
 * modello DevExtreme) estende questa classe e la fornisce al suo posto in
 * app.config.ts, con { provide: AuthService, useExisting: <classe> }: cosi'
 * guardia, intercettori e motore usano la stessa istanza.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { HttpClient, HttpContext } from '@angular/common/http';
import { computed, inject, Injectable, OnDestroy, signal } from '@angular/core';
import { Router } from '@angular/router';
import {
  BehaviorSubject,
  catchError,
  filter,
  map,
  Observable,
  of,
  switchMap,
  take,
  tap,
  throwError,
} from 'rxjs';

import { ERRORE_SILENZIOSO } from '../interceptors/errore-silenzioso';
import { JwtPayload, LoginResponse, RefreshResponse } from '../models/auth.models';
import { ZZ_ACCESSO_CONFIG } from './accesso.config';
import { MetadataService } from './metadata.service';
import { UrlService } from './url.service';

@Injectable({ providedIn: 'root' })
export class AuthService implements OnDestroy {
  private http = inject(HttpClient);
  protected router = inject(Router);
  protected accesso = inject(ZZ_ACCESSO_CONFIG);
  private baseUrl = inject(UrlService).baseUrl;
  private metadati = inject(MetadataService);

  private refreshTimer: ReturnType<typeof setTimeout> | null = null;

  // Rinnovi concorrenti: il secondo aspetta il risultato del primo.
  // null = rinnovo in corso, false = rinnovo fallito: chi aspetta deve
  // ricevere anche il fallimento, altrimenti la sua richiesta resta sospesa
  // per sempre (e MetadataService la conserverebbe cosi' nella cache).
  private isRefreshing = false;
  private refreshSubject = new BehaviorSubject<string | null | false>(null);

  // ═══ Stato (signal) ═══
  private _accessToken = signal<string>(this.leggiSessione('access_token'));
  private _refreshToken = signal<string>(this.leggiSessione('refresh_token'));

  readonly accessToken = this._accessToken.asReadonly();
  readonly isAuthenticated = computed(() => {
    const token = this._accessToken();
    return token ? !this.isTokenExpired(token) : false;
  });
  readonly currentUser = computed(() => {
    const token = this._accessToken();
    return token ? this.decodeToken(token) : null;
  });

  /** Pagina da riaprire dopo il login (la imposta la guardia). */
  lastAuthenticatedPath: string = this.accesso.percorsoIniziale;

  constructor() {
    if (this._accessToken()) {
      this.scheduleRefresh();
    }
  }

  ngOnDestroy(): void {
    this.clearRefreshTimer();
  }

  // ═══ Login ═══

  login(username: string, password: string): Observable<LoginResponse> {
    // Il middleware DMVC accetta "jwtusername" e "jwtpassword" nel corpo JSON
    return this.http
      .post<LoginResponse>(`${this.baseUrl}/auth/login`, {
        jwtusername: username,
        jwtpassword: password,
      })
      .pipe(
        tap((response) => this.salvaToken(response.token, response.refresh_token)),
        catchError((error: unknown) => {
          console.error('Login non riuscito:', error);
          return throwError(() => error);
        }),
      );
  }

  // ═══ Rinnovo ═══

  refreshAccessToken(): Observable<RefreshResponse> {
    const currentRefreshToken = this._refreshToken();
    if (!currentRefreshToken) {
      this.forceLogout('no_refresh_token');
      return throwError(() => new Error('Nessun token di rinnovo'));
    }

    // Se un rinnovo e' gia' in corso, si aspetta il suo risultato
    if (this.isRefreshing) {
      return this.refreshSubject.pipe(
        filter((esito): esito is string | false => esito !== null),
        take(1),
        switchMap((esito) =>
          esito === false
            ? throwError(() => new Error('Rinnovo del token non riuscito'))
            : of<RefreshResponse>({ token: esito, refresh_token: this._refreshToken() }),
        ),
      );
    }

    this.isRefreshing = true;
    this.refreshSubject.next(null);

    return this.http
      .post<RefreshResponse>(`${this.baseUrl}/auth/refresh`, {
        refresh_token: currentRefreshToken,
      })
      .pipe(
        tap((response) => {
          this.salvaToken(response.token, response.refresh_token);
          this.isRefreshing = false;
          this.refreshSubject.next(response.token);
        }),
        catchError((error: { status?: number }) => {
          this.isRefreshing = false;
          this.refreshSubject.next(false);
          if (error?.status === 401) {
            this.forceLogout('session_expired');
          }
          return throwError(() => error);
        }),
      );
  }

  // ═══ Cambio password ═══

  /**
   * Cambia la password dell'utente collegato (POST /auth/password di zServer:
   * utente e sessione li prende dal token). Un rifiuto arriva come AppError
   * senza notifica: lo mostra la pagina, accanto al modulo. La sessione resta
   * aperta, la nuova password vale dal prossimo login.
   */
  cambiaPassword(attuale: string, nuova: string): Observable<void> {
    return this.http
      .post<unknown>(
        `${this.baseUrl}/auth/password`,
        { oldPassword: attuale, newPassword: nuova },
        { context: new HttpContext().set(ERRORE_SILENZIOSO, true) },
      )
      .pipe(map(() => undefined));
  }

  // ═══ Logout ═══

  logout(): void {
    const rt = this._refreshToken();
    if (rt) {
      this.http.post(`${this.baseUrl}/auth/logout`, { refresh_token: rt }).subscribe({
        error: () => {
          // il token locale si cancella comunque: l'errore del server non conta
        },
      });
    }
    this.clearSession();
    this.router.navigate([this.accesso.percorsoLogin]);
  }

  /**
   * Chiude la sessione scaduta e porta al login con ?reason=session_expired,
   * che la pagina di login usa per l'avviso. Se la sessione e' gia' chiusa non
   * fa nulla: una seconda navigazione al login perderebbe il motivo.
   */
  sessioneScaduta(): void {
    if (this._accessToken() || this._refreshToken()) {
      this.forceLogout('session_expired');
    }
  }

  // ═══ Lettori per gli intercettori ═══

  getAccessToken(): string {
    return this._accessToken();
  }

  getRefreshToken(): string {
    return this._refreshToken();
  }

  decodeToken(token: string): JwtPayload | null {
    try {
      // il payload JWT e' base64url: va riportato a base64 prima di atob
      const base64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
      return JSON.parse(atob(base64)) as JwtPayload;
    } catch {
      return null;
    }
  }

  // ═══ Privati ═══

  private salvaToken(token: string, refreshToken: string): void {
    this.scriviSessione('access_token', token);
    this.scriviSessione('refresh_token', refreshToken);
    this._accessToken.set(token);
    this._refreshToken.set(refreshToken);
    this.scheduleRefresh();
  }

  private clearSession(): void {
    this.clearRefreshTimer();
    this.scriviSessione('access_token', '');
    this.scriviSessione('refresh_token', '');
    this._accessToken.set('');
    this._refreshToken.set('');
    // I metadati letti con la sessione chiusa (anche quelli rimasti a meta')
    // non devono servire al prossimo accesso
    this.metadati.invalidateCache();
  }

  private forceLogout(reason: string): void {
    this.clearSession();
    this.router.navigate([this.accesso.percorsoLogin], { queryParams: { reason } });
  }

  private scheduleRefresh(): void {
    this.clearRefreshTimer();
    const token = this._accessToken();
    if (!token) return;

    const payload = this.decodeToken(token);
    if (!payload) return;

    const expiresAt = payload.exp * 1000;
    const bufferMs = 2 * 60 * 1000; // due minuti prima della scadenza
    const delay = expiresAt - Date.now() - bufferMs;

    if (delay <= 0) {
      this.refreshAccessToken().subscribe({
        error: () => console.error('Rinnovo immediato del token non riuscito'),
      });
    } else {
      this.refreshTimer = setTimeout(() => {
        this.refreshAccessToken().subscribe({
          error: () => console.error('Rinnovo programmato del token non riuscito'),
        });
      }, delay);
    }
  }

  private clearRefreshTimer(): void {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = null;
    }
  }

  private isTokenExpired(token: string): boolean {
    const payload = this.decodeToken(token);
    return !payload || payload.exp * 1000 < Date.now();
  }

  // sessionStorage puo' non esistere o sollevare (navigazione privata, anteprime)
  private leggiSessione(chiave: string): string {
    try {
      return sessionStorage.getItem(chiave) ?? '';
    } catch {
      return '';
    }
  }

  private scriviSessione(chiave: string, valore: string): void {
    try {
      if (valore) sessionStorage.setItem(chiave, valore);
      else sessionStorage.removeItem(chiave);
    } catch {
      // senza sessionStorage la sessione vive solo in memoria
    }
  }
}
