// Configurazione dell'editor dei metadati, fornita dall'applicazione che lo
// ospita (Agorà, GestyWeb) nella rotta che lo apre. Il componente non legge
// environment ne' servizi dell'applicazione: cosi' la cartella zz/meta-editor
// e' identica nei due progetti e si copia senza modifiche.
import { InjectionToken } from '@angular/core';

export interface ZzMetaEditorConfig {
  /** Base delle rotte dell'editor, per esempio 'http://localhost:8443/api/meta'. */
  apiUrl: string;
  /**
   * Base delle rotte dei dati, per le PATCH dei metadati
   * (/api/data/{dataset}/metadata/fields e /settings). Vuota = apiUrl con
   * '/data' al posto del '/meta' finale.
   */
  datiUrl?: string;
  /**
   * Dice se l'utente puo' modificare i metadati (autorizzazione
   * BASE_WEB_METADATI): senza, il menu in loco non aggiunge niente. Il
   * controllo vero lo fa comunque il server. Vuota = sempre falso.
   */
  abilitato?: () => boolean;
  /** Moduli (DM) da escludere di norma dall'esportazione, per esempio ['Agora'] in Gesty. */
  escludiDmPredefiniti?: string[];
}

export const ZZ_META_EDITOR_CONFIG = new InjectionToken<ZzMetaEditorConfig>(
  'ZZ_META_EDITOR_CONFIG',
);
