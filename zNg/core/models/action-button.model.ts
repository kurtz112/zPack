/**
 * action-button.model.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Modello condiviso per i pulsanti azione personalizzabili.
 * Usato sia da zz-data-grid (toolbar + passthrough alla form)
 * sia da zz-form (toolbar bottom del popup).
 *
 * I pulsanti standard (Salva, Annulla, Chiudi) sono generati automaticamente
 * dai componenti in base al mode. Questi pulsanti custom si aggiungono
 * alla toolbar accanto a quelli standard.
 * ─────────────────────────────────────────────────────────────────────────────
 */

export interface ActionButton {
  /** Identificativo univoco del pulsante */
  id: string;

  /** Testo visualizzato */
  text: string;

  /** Icona DevExtreme (es. 'print', 'email', 'doc') */
  icon?: string;

  /** Tipo DevExtreme: 'default' | 'normal' | 'success' | 'danger' */
  type?: 'default' | 'normal' | 'success' | 'danger';

  /** Stile: 'contained' | 'outlined' | 'text' */
  stylingMode?: 'contained' | 'outlined' | 'text';

  /** Disabilitato */
  disabled?: boolean;

  /** Visibile */
  visible?: boolean;

  // ── Contesto di utilizzo ────────────────────────────────────────────────

  /**
   * Dove mostrare il pulsante:
   *  - 'grid'      → solo nella toolbar della grid
   *  - 'form'      → solo nella toolbar della form
   *  - 'both'      → sia grid che form
   *
   * Default: 'both'
   */
  target?: 'grid' | 'form' | 'both';

  /**
   * In quali mode della form è visibile il pulsante.
   * Se omesso, visibile in tutti i mode.
   * Es: ['edit', 'view'] → visibile in modifica e consultazione, non in insert
   */
  formModes?: ('insert' | 'edit' | 'view')[];

  /**
   * Se true, il pulsante richiede che una riga sia selezionata/focalizzata.
   * Nella grid viene disabilitato se non c'è selezione.
   * Nella form è sempre abilitato (ha sempre un record).
   */
  requiresSelection?: boolean;

  /**
   * Posizione nella toolbar:
   *  - 'before' → a sinistra (prima dei pulsanti standard)
   *  - 'after'  → a destra (dopo i pulsanti standard)
   *
   * Default: 'after'
   */
  location?: 'before' | 'after';

  // ── Passthrough grid → form ─────────────────────────────────────────────

  /**
   * Se true, la grid passa questo pulsante alla form embedded
   * quando apre il dialog di edit/insert/view.
   *
   * Default: true (se target è 'form' o 'both')
   */
  passToForm?: boolean;
}

/**
 * Evento emesso al click di un pulsante custom.
 * Contiene il bottone cliccato e il contesto corrente.
 */
export interface ActionButtonEvent {
  /** Il pulsante che è stato cliccato */
  button: ActionButton;

  /** Dati della riga corrente (focusedRow nella grid, formData nella form) */
  data: Record<string, any>;

  /** Mode corrente della form (solo se emesso dalla form) */
  formMode?: 'insert' | 'edit' | 'view';

  /** Sorgente dell'evento */
  source: 'grid' | 'form';
}
