// ═══════════════════════════════════════════════════════════════════════════════
// menu-builder.ts
//
// Builder generico per costruire array di items compatibili con dx-context-menu
// e dx-menu di DevExtreme.
//
// Pattern d'uso:
//
//   this.menuItems = MenuBuilder.create()
//     .item({ text: 'Modifica', icon: 'edit', onClick: () => this.edit() })
//     .separator()
//     .item({ text: 'Elimina',  icon: 'minus', onClick: () => this.delete() })
//     .build();
//
// Oppure tramite i metodi statici di convenienza:
//
//   MenuBuilder.item('Salva', 'save', () => this.save())
//
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Tipi pubblici ────────────────────────────────────────────────────────────

/** Item standard con testo, icona e handler */
export interface IMenuItem {
  /** Identificatore opzionale, usato per trovare/rimuovere l'item */
  id?: string;
  text: string;
  icon?: string;
  /** Se true, disegna una linea separatrice sopra l'item */
  beginGroup?: boolean;
  disabled?: boolean;
  visible?: boolean;
  /** Sotto-menu */
  items?: MenuItem[];
  /** Handler chiamato al click. DevExtreme lo invoca via onItemClick. */
  onItemClick?: (e?: any) => void;
}

/** Item con un componente Angular nel template (usato per input inline nel menu) */
export interface IMenuTemplateItem {
  id?: string;
  /** Nome del template Angular da usare (corrisponde a *dxTemplate="let d of 'nomeTemplate'") */
  template: string;
  /** Se false, il menu rimane aperto dopo il click sull'area del template */
  closeMenuOnClick: boolean;
  beginGroup?: boolean;
  /** Aggiunto per supportare una caption text all'interno del template */
  text?: string;
}

/** Unione dei due tipi — array compatibile con [items] di dx-context-menu */
export type MenuItem = IMenuItem | IMenuTemplateItem;

// ─── Guard di tipo ────────────────────────────────────────────────────────────

export function isMenuTemplateItem(item: MenuItem): item is IMenuTemplateItem {
  return 'template' in item;
}

export function isMenuItem(item: MenuItem): item is IMenuItem {
  return 'text' in item && !isMenuTemplateItem(item);
}

// ─── Interfaccia di configurazione per i metodi statici ──────────────────────

export interface IMenuItemConfig {
  id?: string;
  text: string;
  icon?: string;
  beginGroup?: boolean;
  disabled?: boolean;
  visible?: boolean;
  items?: IMenuItem[];
  onClick?: (e?: any) => void;
}

// ─── Builder (fluent API) ─────────────────────────────────────────────────────

export class MenuBuilder {

  private _items: MenuItem[] = [];

  // ── Costruttore privato — usa MenuBuilder.create() ──────────────────────────
  private constructor() {}

  /** Crea una nuova istanza del builder (fluent API) */
  static create(): MenuBuilder {
    return new MenuBuilder();
  }

  // ── Metodi fluent ────────────────────────────────────────────────────────────

  /** Aggiunge un item standard */
  item(config: IMenuItemConfig): this {
    this._items.push(MenuBuilder.buildItem(config));
    return this;
  }

  /** Aggiunge un separatore (beginGroup sul prossimo item).
   *  Shortcut: equivale a impostare beginGroup=true sull'item successivo.
   *  Se l'array è vuoto non fa nulla (non ha senso un separatore iniziale). */
  separator(): this {
    if (this._items.length > 0) {
      this._nextBeginGroup = true;
    }
    return this;
  }

  /** Aggiunge un item di template (per input Angular inline nel menu) */
  templateItem(config: Omit<IMenuTemplateItem, 'closeMenuOnClick'> & { closeMenuOnClick?: boolean }): this {
    this._items.push({
      id: config.id,
      template: config.template,
      closeMenuOnClick: config.closeMenuOnClick ?? false,
      beginGroup: this._consumeBeginGroup(config.beginGroup),
      text: config.text, // Modifica per includere text nell'oggetto pushato
    });
    return this;
  }

  /** Aggiunge un sotto-menu */
  subMenu(config: Omit<IMenuItemConfig, 'onClick'>, children: MenuItem[]): this {
    const item = MenuBuilder.buildItem({ ...config, beginGroup: this._consumeBeginGroup(config.beginGroup) });
    item.items = children;
    this._items.push(item);
    return this;
  }

  /** Aggiunge un item condizionalmente */
  itemIf(condition: boolean, config: IMenuItemConfig): this {
    if (condition) this.item(config);
    return this;
  }

  /** Aggiunge un sotto-menu condizionalmente */
  subMenuIf(condition: boolean, config: Omit<IMenuItemConfig, 'onClick'>, children: MenuItem[]): this {
    if (condition) this.subMenu(config, children);
    return this;
  }

  /** Aggiunge un array di items già costruiti */
  append(items: MenuItem[]): this {
    this._items.push(...items);
    return this;
  }

  /** Restituisce l'array finale da assegnare a [items] del dx-context-menu */
  build(): MenuItem[] {
    return [...this._items];
  }

  // ── Stato interno del builder ─────────────────────────────────────────────

  private _nextBeginGroup = false;

  private _consumeBeginGroup(explicit?: boolean): boolean {
    const result = explicit || this._nextBeginGroup;
    this._nextBeginGroup = false;
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // METODI STATICI DI UTILITÀ
  // Permettono di costruire singoli item senza istanziare il builder,
  // utile quando si assemblano array di items manualmente.
  // ═══════════════════════════════════════════════════════════════════════════

  /** Costruisce un singolo IMenuItem */
  static buildItem(config: IMenuItemConfig): IMenuItem {
    return {
      id:         config.id,
      text:       config.text,
      icon:       config.icon,
      beginGroup: config.beginGroup ?? false,
      disabled:   config.disabled  ?? false,
      visible:    config.visible   ?? true,
      items:      config.items,
      onItemClick: config.onClick,
    };
  }

  /** Shorthand statico: crea un item e lo restituisce */
  static item(text: string, icon: string, onClick: (e?: any) => void, beginGroup = false): IMenuItem {
    return this.buildItem({ text, icon, onClick, beginGroup });
  }

  /** Crea un item di template per l'uso con *dxTemplate Angular */
  static templateItem(template: string, id?: string, beginGroup = false, text?: string): IMenuTemplateItem {
    return {
      id,
      template,
      closeMenuOnClick: false,
      beginGroup,
      text, // Aggiunto per permettere custom caption sui template
    };
  }

  /**
   * Rimuove un item dall'array cercandolo per `id` (priorità) o per `text`.
   * Modifica l'array in-place e restituisce true se l'item è stato trovato.
   */
  static remove(items: MenuItem[], idOrText: string): boolean {
    const idx = items.findIndex(item =>
      isMenuItem(item) && ((item as IMenuItem).id === idOrText || (item as IMenuItem).text === idOrText)
    );
    if (idx !== -1) {
      items.splice(idx, 1);
      return true;
    }
    return false;
  }

  /**
   * Trova un item nell'array (ricerca ricorsiva nei sotto-menu)
   * cercando per `id` (priorità) o per `text`.
   */
  static find(items: MenuItem[], idOrText: string): IMenuItem | undefined {
    for (const item of items) {
      if (!isMenuItem(item)) continue;
      const iItem = item as IMenuItem;
      if (iItem.id === idOrText || iItem.text === idOrText) return iItem;
      if (iItem.items?.length) {
        const found = this.find(iItem.items, idOrText);
        if (found) return found;
      }
    }
    return undefined;
  }

  /**
   * Aggiorna un item esistente (ricerca per id o text).
   * Restituisce true se l'item è stato trovato e aggiornato.
   */
  static update(items: MenuItem[], idOrText: string, patch: Partial<IMenuItem>): boolean {
    const item = this.find(items, idOrText);
    if (item) {
      Object.assign(item, patch);
      return true;
    }
    return false;
  }

  /**
   * Imposta la proprietà `disabled` su un item (ricerca per id o text).
   */
  static setDisabled(items: MenuItem[], idOrText: string, disabled: boolean): boolean {
    return this.update(items, idOrText, { disabled });
  }

  /**
   * Imposta la proprietà `visible` su un item (ricerca per id o text).
   */
  static setVisible(items: MenuItem[], idOrText: string, visible: boolean): boolean {
    return this.update(items, idOrText, { visible });
  }
}
