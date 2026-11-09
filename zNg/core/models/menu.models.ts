/**
 * menu.models.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Voci del menu laterale delle applicazioni. Il menu resta dell'applicazione
 * (Agorà: dx-drawer con sezioni; GestyWeb: pannello sovrapposto con dx-list):
 * in comune ci sono la forma della voce e la regola delle voci riservate a chi
 * puo' aprire l'editor dei metadati (AccessoMetadatiService).
 *
 * Da non confondere con MenuItem di core/helper/menu-builder.ts, che descrive
 * i menu contestuali del motore zz-*.
 * ─────────────────────────────────────────────────────────────────────────────
 */

export interface VoceMenu {
  text: string;
  /** Rotta della voce; GestyWeb usa anche 'logout', che non e' una rotta. */
  path: string;
  icon: string;
  /** Evidenziata solo sul percorso esatto: serve quando una voce ne contiene un'altra. */
  esatta?: boolean;
  /** Visibile solo se l'utente ha l'autorizzazione all'editor dei metadati (strumenti di sviluppo). */
  soloMetadati?: boolean;
}

/**
 * Le voci che l'utente vede: quelle riservate all'editor dei metadati solo se
 * `metadatiAbilitati` (di norma AccessoMetadatiService.abilitato()).
 */
export function vociMenuVisibili<T extends VoceMenu>(voci: T[], metadatiAbilitati: boolean): T[] {
  return voci.filter((voce) => !voce.soloMetadati || metadatiAbilitati);
}
