/**
 * tema.service.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Tema chiaro e scuro comune ad Agorà e GestyWeb: lo stato in un signal, la
 * scelta ricordata dal browser e allineata fra le schede aperte, e sul
 * documento l'attributo data-theme sull'elemento html, le classi
 * dx-theme-light / dx-theme-dark sul body e, se l'applicazione li indica, il
 * foglio del tema DevExtreme (tema.config.ts).
 *
 * Il foglio di `fogli` si aggiunge in fondo all'head, dopo gli stili dell'applicazione:
 * le regole dell'applicazione che correggono il tema devono quindi essere piu'
 * specifiche di quelle del foglio (in GestyWeb stanno sotto .dx-viewport).
 *
 * Il foglio scuro dei temi a classi (`foglioScuro`) si aggiunge invece prima
 * degli stili dell'applicazione, nello stesso punto in cui stava quando era
 * negli stili iniziali: le correzioni dell'applicazione continuano a vincere
 * come prima. Per non mostrare un lampo chiaro, index.html lo aggiunge gia'
 * prima dell'avvio, con un link che ha l'id ID_FOGLIO_SCURO (il servizio lo
 * ritrova e non lo ripete). Script da mettere nell'head, prima degli stili,
 * con la chiave di memoria e il foglio dell'applicazione:
 *
 *   <script>
 *     (function () {
 *       var tema;
 *       try { tema = localStorage.getItem('pipa.tema'); } catch (e) {}
 *       if (tema !== 'light' && tema !== 'dark') {
 *         tema = window.matchMedia && matchMedia('(prefers-color-scheme: dark)').matches
 *           ? 'dark' : 'light';
 *       }
 *       document.documentElement.setAttribute('data-theme', tema);
 *       if (tema === 'dark') {
 *         var foglio = document.createElement('link');
 *         foglio.id = 'zng-tema-scuro';
 *         foglio.rel = 'stylesheet';
 *         foglio.href = 'tema-scuro.css';
 *         document.head.appendChild(foglio);
 *       }
 *     })();
 *   </script>
 *
 * Mentre il browser legge l'head, appendChild mette il link prima degli stili
 * che Angular scrive in fondo all'head. Il ramo del sistema operativo serve
 * solo con temaIniziale 'sistema'.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { DOCUMENT } from '@angular/common';
import {
  computed,
  DestroyRef,
  effect,
  EnvironmentProviders,
  inject,
  Injectable,
  makeEnvironmentProviders,
  provideAppInitializer,
  signal,
} from '@angular/core';

import {
  CONFIGURAZIONE_TEMA_PREDEFINITA,
  ConfigurazioneTema,
  Tema,
  ZZ_TEMA_CONFIG,
} from './tema.config';

const ID_FOGLIO = 'dx-theme';
/** Id del link al foglio scuro dei temi a classi (anche nello script di index.html). */
export const ID_FOGLIO_SCURO = 'zng-tema-scuro';

function eTema(valore: unknown): valore is Tema {
  return valore === 'light' || valore === 'dark';
}

@Injectable({ providedIn: 'root' })
export class TemaService {
  private readonly document = inject(DOCUMENT);
  private readonly config = inject(ZZ_TEMA_CONFIG);

  private readonly stato = signal<Tema>(this.temaDiPartenza());

  /** Tema attivo. */
  readonly tema = this.stato.asReadonly();
  /** Vero con il tema scuro: icona e suggerimento del pulsante che lo cambia. */
  readonly scuro = computed(() => this.stato() === 'dark');

  constructor() {
    effect(() => {
      const tema = this.stato();
      this.applica(tema);
      this.salva(tema);
    });

    // Un'altra scheda della stessa applicazione cambia tema: si allinea anche questa
    const window = this.document.defaultView;
    if (window) {
      const allinea = (evento: StorageEvent) => {
        if (evento.key === this.config.chiaveMemoria && eTema(evento.newValue)) {
          this.stato.set(evento.newValue);
        }
      };
      window.addEventListener('storage', allinea);
      inject(DestroyRef).onDestroy(() => window.removeEventListener('storage', allinea));
    }
  }

  /** Passa dal tema chiaro allo scuro e viceversa. */
  cambiaTema(): void {
    this.stato.update((tema) => (tema === 'dark' ? 'light' : 'dark'));
  }

  imposta(tema: Tema): void {
    this.stato.set(tema);
  }

  private temaDiPartenza(): Tema {
    const salvato = this.leggi();
    if (salvato) return salvato;

    const precedente = this.config.temaPrecedente?.();
    if (eTema(precedente)) return precedente;

    if (this.config.temaIniziale === 'sistema') {
      return this.document.defaultView?.matchMedia?.('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light';
    }
    return this.config.temaIniziale;
  }

  // Se il browser non lascia usare il localStorage (navigazione privata, dati
  // bloccati) il tema resta quello scelto fino alla chiusura della pagina
  private leggi(): Tema | undefined {
    try {
      const valore = localStorage.getItem(this.config.chiaveMemoria);
      return eTema(valore) ? valore : undefined;
    } catch {
      return undefined;
    }
  }

  private salva(tema: Tema): void {
    try {
      localStorage.setItem(this.config.chiaveMemoria, tema);
    } catch {
      // vedi leggi()
    }
  }

  private applica(tema: Tema): void {
    this.document.documentElement.setAttribute('data-theme', tema);

    const body = this.document.body;
    body.classList.remove('dx-theme-light', 'dx-theme-dark');
    body.classList.add(`dx-theme-${tema}`);

    const fogli = this.config.fogli;
    if (!fogli) {
      // Temi a classi dx-swatch-* (Agorà, Pipa): i dialoghi di
      // devextreme/ui/dialog nascono nel body, fuori dall'elemento .app che
      // porta la classe, e restavano chiari anche col tema scuro
      body.classList.remove('dx-swatch-light', 'dx-swatch-dark');
      body.classList.add(`dx-swatch-${tema}`);
      if (tema === 'dark' && this.config.foglioScuro) {
        this.caricaFoglioScuro(this.config.foglioScuro);
      }
      return;
    }
    let foglio = this.document.getElementById(ID_FOGLIO) as HTMLLinkElement | null;
    if (!foglio) {
      foglio = this.document.createElement('link');
      foglio.id = ID_FOGLIO;
      foglio.rel = 'stylesheet';
      this.document.head.appendChild(foglio);
    }
    foglio.href = fogli[tema];
  }

  // Una volta caricato il foglio scuro resta: le sue regole valgono solo
  // sotto .dx-swatch-dark, e toglierlo farebbe riscaricarlo a ogni cambio
  private caricaFoglioScuro(href: string): void {
    if (this.document.getElementById(ID_FOGLIO_SCURO)) return;
    const head = this.document.head;
    const foglio = this.document.createElement('link');
    foglio.id = ID_FOGLIO_SCURO;
    foglio.rel = 'stylesheet';
    foglio.href = href;
    // Prima del primo foglio della pagina: e' il posto che il tema scuro
    // aveva negli stili iniziali, prima del tema chiaro e degli stili
    // dell'applicazione
    head.insertBefore(foglio, head.querySelector('link[rel="stylesheet"], style'));
  }
}

/**
 * Provider di ZZ_TEMA_CONFIG (le voci indicate, le altre dai predefiniti) e
 * creazione di TemaService all'avvio, da mettere in app.config.ts.
 */
export function fornisciConfigurazioneTema(
  voci: Partial<ConfigurazioneTema>,
): EnvironmentProviders {
  return makeEnvironmentProviders([
    { provide: ZZ_TEMA_CONFIG, useValue: { ...CONFIGURAZIONE_TEMA_PREDEFINITA, ...voci } },
    provideAppInitializer(() => {
      inject(TemaService);
    }),
  ]);
}
