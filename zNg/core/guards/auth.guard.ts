/**
 * auth.guard.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Guardia delle rotte (canActivate o canActivateChild):
 *  - pagina protetta, token valido: si entra e la pagina si ricorda per il
 *    ritorno dopo un nuovo login;
 *  - pagina protetta, token scaduto ma rinnovabile: si rinnova e si entra;
 *  - pagina protetta, nessuna sessione: si va al login;
 *  - pagina di accesso (ZZ_ACCESSO_CONFIG.pagineDiAccesso) con sessione
 *    valida: si torna alla pagina iniziale, il login non serve.
 * Restituisce un UrlTree invece di navigare: il router annulla la navigazione
 * in corso e apre l'altra pagina senza un secondo passaggio.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { inject } from '@angular/core';
import {
  ActivatedRouteSnapshot,
  CanActivateFn,
  Router,
  RouterStateSnapshot,
  UrlTree,
} from '@angular/router';
import { firstValueFrom } from 'rxjs';

import { ZZ_ACCESSO_CONFIG } from '../services/accesso.config';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = async (
  route: ActivatedRouteSnapshot,
  state: RouterStateSnapshot,
): Promise<boolean | UrlTree> => {
  const auth = inject(AuthService);
  const router = inject(Router);
  const accesso = inject(ZZ_ACCESSO_CONFIG);

  const percorso = route.routeConfig?.path ?? '';
  const paginaDiAccesso = accesso.pagineDiAccesso.includes(percorso);

  let autenticato = auth.isAuthenticated();

  // Token scaduto ma rinnovabile: si prova a rinnovarlo prima di decidere
  if (!autenticato && auth.getRefreshToken()) {
    try {
      await firstValueFrom(auth.refreshAccessToken());
      autenticato = auth.isAuthenticated();
    } catch {
      autenticato = false;
    }
  }

  if (paginaDiAccesso) {
    return autenticato ? router.parseUrl(accesso.percorsoIniziale) : true;
  }

  if (!autenticato) {
    return router.parseUrl(accesso.percorsoLogin);
  }

  auth.lastAuthenticatedPath = state.url || accesso.percorsoIniziale;
  return true;
};
