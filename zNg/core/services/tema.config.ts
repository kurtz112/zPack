/**
 * tema.config.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Cio' che il tema chiaro e scuro di zNg (TemaService) deve sapere
 * dell'applicazione. Le due famiglie di temi restano dell'applicazione:
 *
 * - Agorà e Pipa usano i temi Material generati, scelti con le classi
 *   dx-swatch-* sull'elemento .app: le classi le mettono i loro componenti
 *   leggendo TemaService.tema(). zNg mette la stessa classe anche sul body,
 *   per i dialoghi di devextreme/ui/dialog (alert, confirm, custom), che
 *   DevExtreme aggancia al body e non trovano la classe dell'elemento .app.
 *   I fogli scuri (tutti sotto .dx-swatch-dark) possono stare fuori dal
 *   caricamento iniziale: con `foglioScuro` zNg li carica solo quando il
 *   tema diventa scuro (dal 2026-11-07, zNg 1.10.0);
 * - GestyWeb usa il tema Generic, un foglio per tema: zNg scambia il foglio
 *   indicato in `fogli`.
 *
 * L'applicazione fornisce le voci che cambiano, in app.config.ts
 * (fornisciConfigurazioneTema di tema.service.ts):
 *
 *   fornisciConfigurazioneTema({
 *     chiaveMemoria: 'gestyweb.tema',
 *     temaIniziale: 'sistema',
 *     fogli: { light: 'temi/dx.light.css', dark: 'temi/dx.dark.css' },
 *   }),
 *
 * Tema scuro su richiesta (Pipa): in angular.json i fogli scuri diventano un
 * bundle a parte, non iniettato nella pagina,
 *
 *   { "input": "src/themes/generated/theme.base.dark.css",
 *     "bundleName": "tema-scuro", "inject": false },
 *
 * l'applicazione passa `foglioScuro: 'tema-scuro.css'`, e index.html legge la
 * scelta salvata prima dell'avvio con il piccolo script descritto in testa a
 * tema.service.ts, che aggiunge il foglio prima che Angular disegni la
 * pagina: niente lampo chiaro per chi ha scelto il tema scuro.
 *
 * fornisciConfigurazioneTema sta in tema.service.ts, perche' crea anche il
 * servizio all'avvio: cosi' il tema salvato vale gia' nella pagina di accesso.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { InjectionToken } from '@angular/core';

export type Tema = 'light' | 'dark';

export interface ConfigurazioneTema {
  /** Chiave del localStorage in cui il browser ricorda il tema scelto. */
  chiaveMemoria: string;
  /**
   * Tema di chi non ne ha ancora scelto uno: 'sistema' segue l'impostazione
   * chiaro/scuro del sistema operativo.
   */
  temaIniziale: Tema | 'sistema';
  /**
   * Fogli del tema DevExtreme da scambiare (relativi alla pagina). Assente:
   * zNg non tocca fogli, e il tema lo applicano i componenti
   * dell'applicazione leggendo TemaService.tema().
   */
  fogli?: Record<Tema, string>;
  /**
   * Solo con i temi a classi dx-swatch-* (senza `fogli`): foglio con le
   * regole del tema scuro (relativo alla pagina), aggiunto la prima volta che
   * il tema diventa scuro e poi lasciato, perche' vale solo sotto
   * .dx-swatch-dark. Assente: i fogli scuri stanno gia' negli stili iniziali.
   */
  foglioScuro?: string;
  /**
   * Tema salvato altrove da una versione precedente dell'applicazione, letto
   * solo se nella chiave di memoria non c'e' ancora nulla: chi aggiorna
   * l'applicazione non perde la scelta fatta.
   */
  temaPrecedente?: () => Tema | undefined;
}

export const CONFIGURAZIONE_TEMA_PREDEFINITA: ConfigurazioneTema = {
  chiaveMemoria: 'zng.tema',
  temaIniziale: 'light',
};

export const ZZ_TEMA_CONFIG = new InjectionToken<ConfigurazioneTema>('ZZ_TEMA_CONFIG', {
  providedIn: 'root',
  factory: () => CONFIGURAZIONE_TEMA_PREDEFINITA,
});
