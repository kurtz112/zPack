/**
 * design-menu.builder.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Costruisce i MenuItem del context menu di design (tasto destro sul form body).
 *
 * Funzione pura: non ha stato e non dipende da Angular / DI.
 * Viene chiamata da ZzFormComponent in onDesignMenuShowing().
 *
 * Funzionalità di design-time supportate:
 *  Globali  — colCount (input inline), navigazione al meta-editor, incollaImpostazioni
 *  Per campo — caption (input inline), colSpan, lineBreak, visible, readOnly,
 *              required, cardIndex (input inline)
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { MenuItem, MenuBuilder } from '@zng/core/helper/menu-builder';
import { FocusedFieldInfo }      from './form-focus-tracker';

// ─── Contratto delle azioni di design ────────────────────────────────────────

export interface DesignMenuActions {
  copyDatasetName:      (datasetName: string) => void;
  setColCount:          (count: number) => void;
  incollaImpostazioni:  () => void;
  toggleVisible:        (fi: FocusedFieldInfo) => void;
  toggleReadOnly:       (fi: FocusedFieldInfo) => void;
  toggleRequired:       (fi: FocusedFieldInfo) => void;
  toggleLineBreak:      (fi: FocusedFieldInfo) => void;
  setColSpan:           (fi: FocusedFieldInfo, span: number) => void;
  setCaption:           (fi: FocusedFieldInfo, caption: string) => void;
  setCardIndex:         (fi: FocusedFieldInfo, index: number) => void;
}

// ─── ID template usati nei *dxTemplate del componente ────────────────────────

export const TMPL_COL_COUNT  = 'tplColCount';
export const TMPL_CAPTION    = 'tplCaption';
export const TMPL_CARD_INDEX = 'tplCardIndex';

// ─────────────────────────────────────────────────────────────────────────────

/**
 * Costruisce l'array di MenuItem per il context menu di design.
 *
 * @param fi          Info del campo focalizzato (null se nessun campo è selezionato)
 * @param colCount    colCount corrente del form (per il template inline e "colSpan: intero")
 * @param datasetName Nome del dataset per la copia rapida
 * @param actions     Callback per le azioni
 */
export function buildDesignMenu(
  fi:          FocusedFieldInfo | null,
  colCount:    number,
  datasetName: string,
  actions:     DesignMenuActions,
): MenuItem[] {

  // ── Sezione campo focalizzato ──────────────────────────────────────────────
  const fieldSection: MenuItem[] = fi
    ? MenuBuilder.create()
        // Caption (input inline)
        .templateItem({ template: TMPL_CAPTION, id: 'tmplCaption', text: 'Label', beginGroup: false })
        .separator()
        // Boolean toggles
        .item({
          text:    fi.visible ? 'Nascondi campo' : 'Mostra campo',
          icon:    fi.visible ? 'strike'         : 'eyeopen',
          onClick: () => actions.toggleVisible(fi),
        })
        .item({
          text:    fi.readOnly ? 'Rendi modificabile' : 'Rendi readOnly',
          icon:    'lock',
          onClick: () => actions.toggleReadOnly(fi),
        })
        .item({
          text:    fi.required ? 'Rimuovi obbligatorietà' : 'Rendi obbligatorio',
          icon:    'isblank',
          visible: !fi.boolean,
          onClick: () => actions.toggleRequired(fi),
        })
        .item({
          text:    fi.lineBreak ? 'Rimuovi interruzione riga' : 'Aggiungi interruzione riga',
          icon:    'return',
          onClick: () => actions.toggleLineBreak(fi),
        })
        .separator()
        // ColSpan shortcuts
        .item({ text: 'colSpan: 1',      icon: 'columnfield', onClick: () => actions.setColSpan(fi, 1) })
        .item({ text: 'colSpan: 2',      icon: 'columnfield', onClick: () => actions.setColSpan(fi, 2) })
        .item({ text: 'colSpan: 3',      icon: 'columnfield', onClick: () => actions.setColSpan(fi, 3) })
        .item({ text: 'colSpan: 4',      icon: 'columnfield', onClick: () => actions.setColSpan(fi, 4) })
        .item({ text: 'colSpan: intero', icon: 'expand',      onClick: () => actions.setColSpan(fi, colCount) })
        .separator()
        // CardIndex (input inline)
        .templateItem({ template: TMPL_CARD_INDEX, id: 'tmplCardIndex', text: 'Indice scheda' })
        .build()
    : [];

  // ── Menu principale ────────────────────────────────────────────────────────
  return MenuBuilder.create()
    // colCount inline
    .templateItem({ template: TMPL_COL_COUNT, id: 'tmplColCount', text: 'Numero Colonne' })
    .separator()
    // Azione copia dataset Name e rimozione azioni custom obsolete
    .item({ text: `Copia nome dataset: ${datasetName}`, icon: 'copy', onClick: () => actions.copyDatasetName(datasetName) })
    .separator()
    // Incolla impostazioni
    .item({ text: 'Incolla impostazioni', icon: 'paste', onClick: () => actions.incollaImpostazioni() })
    // Sezione campo
    .subMenuIf(!!fi, {
      text:       'Campo: ' + (fi?.caption || fi?.dataField || ''),
      icon:       'fields',
      beginGroup: true,
    }, fieldSection)
    .itemIf(!fi, {
      text:       'Nessun campo selezionato',
      icon:       'fields',
      beginGroup: true,
      disabled:   true,
    })
    .build();
}
