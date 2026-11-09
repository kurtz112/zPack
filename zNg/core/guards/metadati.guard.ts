// Rotte degli strumenti di sviluppo (dashboard di prova, vetrina dei metadati,
// editor dei metadati): solo per chi ha l'autorizzazione BASE_WEB_METADATI.
// Va messa dopo authGuard: la verifica chiede a zServer, quindi serve il token.
// Il controllo vero resta quello del server; questa guardia evita che un
// collaboratore apra pagine che per lui darebbero solo errori.
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { AccessoMetadatiService } from '../services/accesso-metadati.service';

export const metadatiGuard: CanActivateFn = async () => {
  const accesso = inject(AccessoMetadatiService);
  const router = inject(Router);

  if (await accesso.verifica()) {
    return true;
  }

  return router.createUrlTree(['/']);
};
