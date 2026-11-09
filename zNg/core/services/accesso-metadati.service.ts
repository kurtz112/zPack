// Dice se l'utente collegato puo' aprire l'editor dei metadati, cioe' se ha
// l'autorizzazione BASE_WEB_METADATI. Il token porta solo il ruolo, non le
// autorizzazioni: lo chiede a zServer (GET /api/meta/access, 200 o 403).
// Serve solo a nascondere le voci di menu e gli strumenti di sviluppo; il
// controllo vero lo fa il server su ogni rotta dell'editor.
import { HttpClient, HttpContext } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { ERRORE_SILENZIOSO } from '../interceptors/errore-silenzioso';
import { UrlService } from './url.service';

@Injectable({ providedIn: 'root' })
export class AccessoMetadatiService {
  private http = inject(HttpClient);
  private baseUrl = inject(UrlService).baseUrl;

  readonly abilitato = signal(false);

  /** Da richiamare dopo ogni accesso: l'autorizzazione dipende dall'utente. */
  async verifica(): Promise<boolean> {
    try {
      await firstValueFrom(
        this.http.get(`${this.baseUrl}/meta/access`, {
          context: new HttpContext().set(ERRORE_SILENZIOSO, true),
        }),
      );
      this.abilitato.set(true);
    } catch (_errore) {
      this.abilitato.set(false);
    }
    return this.abilitato();
  }
}
