/**
 * segnalazioni.service.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Segnalazione di un errore all'assistenza, a scelta dell'utente.
 *
 * Il browser non parla mai con Mantis: manda l'errore a zServer
 * (POST /api/segnalazioni) e il ticket lo apre zServer, con indirizzo, token e
 * progetto letti dal proprio file di configurazione (sezione "mantis"). Qui
 * non c'e' nessun segreto, e non ci puo' essere: il token non arriva al
 * browser in nessuna risposta.
 *
 * Il pulsante "Segnala all'assistenza" compare solo se zServer risponde che la
 * funzione e' attiva (GET /api/segnalazioni/abilitata): sul server dove la
 * sezione "mantis" manca o e' spenta l'interfaccia resta com'era. Il controllo
 * si ripete da solo a ogni accesso, perche' dipende dal server a cui ci si
 * collega: l'applicazione non deve chiamare verifica().
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { HttpClient, HttpContext } from '@angular/common/http';
import { effect, inject, Injectable, signal, untracked } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { ERRORE_SILENZIOSO } from '../interceptors/errore-silenzioso';
import { isAppError } from '../models/app-error.model';
import { AuthService } from './auth.service';
import { raccogliDatiTecnici } from './diagnostica';
import { UrlService } from './url.service';

/** Cio' che serve a una segnalazione: la pagina e il testo dell'errore. */
export interface DatiSegnalazione {
  pagina: string;
  testo: string;
}

@Injectable({ providedIn: 'root' })
export class SegnalazioniService {
  private http = inject(HttpClient);
  private auth = inject(AuthService);
  private baseUrl = inject(UrlService).baseUrl;

  readonly abilitata = signal(false);

  constructor() {
    // Ogni volta che un utente accede si chiede a zServer se la funzione e'
    // attiva; all'uscita il pulsante sparisce.
    effect(() => {
      const utente = this.auth.currentUser();
      untracked(() => {
        if (utente) {
          void this.verifica();
        } else {
          this.abilitata.set(false);
        }
      });
    });
  }

  async verifica(): Promise<boolean> {
    try {
      const risposta = await firstValueFrom(
        this.http.get<{ abilitata?: boolean }>(`${this.baseUrl}/segnalazioni/abilitata`, {
          context: new HttpContext().set(ERRORE_SILENZIOSO, true),
        }),
      );
      this.abilitata.set(risposta?.abilitata === true);
    } catch (_errore) {
      this.abilitata.set(false);
    }
    return this.abilitata();
  }

  /**
   * Invia la segnalazione e restituisce il numero del ticket. In caso di
   * errore solleva un Error con un messaggio gia' pronto per l'utente: la
   * richiesta e' silenziosa, altrimenti un errore della segnalazione
   * proporrebbe a sua volta di segnalarsi.
   */
  async segnala(dati: DatiSegnalazione, nota: string): Promise<number> {
    try {
      const risposta = await firstValueFrom(
        this.http.post<{ idTicket?: number }>(
          `${this.baseUrl}/segnalazioni`,
          {
            // senza parametri dell'indirizzo ne' ancora: possono contenere dati di persone
            pagina: dati.pagina.split(/[?#]/)[0],
            testo: dati.testo,
            nota,
            // ora, schermo, richieste recenti (senza parametri) e console
            tecnici: raccogliDatiTecnici(),
          },
          { context: new HttpContext().set(ERRORE_SILENZIOSO, true) },
        ),
      );
      return risposta?.idTicket ?? 0;
    } catch (errore) {
      const stato = isAppError(errore) ? errore.statusCode : 0;
      if (stato === 429) {
        throw new Error('Troppe segnalazioni in poco tempo. Attendere un minuto e riprovare.', {
          cause: errore,
        });
      }
      if (stato === 503) {
        throw new Error('La segnalazione degli errori non è attiva su questo server.', {
          cause: errore,
        });
      }
      throw new Error('Segnalazione non riuscita. Riprovare più tardi o avvisare l’assistenza.', {
        cause: errore,
      });
    }
  }
}
