import { Injectable, inject, RendererFactory2, ViewEncapsulation } from '@angular/core';
import { DOCUMENT } from '@angular/common';
import { ZServerService } from '@zng/core/services/zserver.service';
import DataSource from 'devextreme/data/data_source';
import Form from 'devextreme/ui/form';

import { LookupColumn, LookupConfig } from '@zng/core/models/metadata.models';


@Injectable({ providedIn: 'root' })
export class LookupHelperService {
  private readonly zserver = inject(ZServerService);
  private readonly document = inject(DOCUMENT);
  private readonly renderer = inject(RendererFactory2).createRenderer(null, {
    id: 'z-lookup-global-styles',
    encapsulation: ViewEncapsulation.None,
    styles: [],
    data: {}
  });

  constructor() {
    this._ensureStyles();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Pulizia campi
  // ═══════════════════════════════════════════════════════════════════════════

  private getCleanField(field: string | any): string {
    if (typeof field !== 'string') return 'text';
    return field.split(/[;,]/)[0].trim();
  }

  private getSortSelector(config: LookupConfig): string {
    if (config.columns && config.columns.length > 0) {
      return this.getCleanField(config.columns[0].field);
    }
    return this.getCleanField(config.displayExpr);
  }
  // ═══════════════════════════════════════════════════════════════════════════
  // Editor Options per dxSelectBox
  // ═══════════════════════════════════════════════════════════════════════════

  getEditorOptions(config: LookupConfig, onSelect?: (item: any, e?: any) => void, campo?: string): any {
    const hasColumns = config.columns && config.columns.length > 0;

    if (!hasColumns) {
      console.warn('LookupHelper: Configurazione colonne mancante.', config);
    }

    const firstField = this.getSortSelector(config);

    // Chiave composta ("TIPO_RICHIESTA; TIPOLOGIA_RICHIESTA"): la casella vale il solo
    // campo che modifica, e la riga si cerca con tutte le parti della chiave lette dal
    // modulo. Il nome intero usato come campo del filtro faceva rispondere 500 a zServer.
    const chiave = (config.valueExpr ?? '').split(/[;,]/).map(s => s.trim()).filter(Boolean);
    const campoChiave = campo && chiave.includes(campo) ? campo : chiave[0];
    let elemento: Element | undefined;
    const filtroPerChiave = chiave.length > 1
      ? (key: unknown) => this._filtroChiaveComposta(config, chiave, campoChiave, key, elemento)
      : undefined;
    const store = this.zserver.createDataStore(config.dataset, campoChiave, undefined, filtroPerChiave);

    const dataSource = new DataSource({
      store: store,
      filter: config.filter || null,
      sort: [{ selector: firstField, desc: false }],
      pageSize: config.pageSize || 30,
      searchOperation: 'contains',
      searchExpr: firstField,
    });

    const options: any = {
      dataSource: dataSource,
      valueExpr: campoChiave,
      displayExpr: this.getCleanField(config.displayExpr),
      searchEnabled: true,
      showClearButton: true,
      searchExpr: [firstField],
      searchMode: 'contains',
      minSearchLength: 0,
      searchTimeout: 500,
      wrapItemText: false,

      dropDownOptions: {
        width: config.dropDownWidth || 500,
        wrapperAttr: { class: 'z-lookup-popup' }
      },

      onInitialized: (e: any) => {
        elemento = e.element;
      },

      onSelectionChanged: (e: any) => {
        if (onSelect) onSelect(e.selectedItem, e);
      },

      // Disabilita infinite scrolling della List interna +
      // inietta header multi-colonna se configurato
      onOpened: (e: any) => {
        const listInstance = e.component._list;
        if (listInstance) {
          listInstance._dataSource?.paginate(false);
          listInstance._loadNextPage = () => { }; // in pratica: se il server ritorna 2 record, continua a duplicarli in loop
        }

        if (hasColumns) {
          setTimeout(() => this._injectHeader(e.component, config.columns || []), 0);
        }
      }
    };

    if (hasColumns) {
      options.itemTemplate = (data: any) => this._buildRow(data, config.columns || [], false);
    }

    return options;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Mappings
  // ═══════════════════════════════════════════════════════════════════════════

  /** Il dx-form che contiene l'editor, o undefined fuori da un modulo. */
  moduloDi(elemento: Element | undefined): Form | undefined {
    const nodo = elemento?.closest?.('.dx-form');
    return nodo ? (Form.getInstance(nodo) as Form | undefined) : undefined;
  }

  /**
   * Copia nel modulo i campi dei mappings ("CAMPO_MODULO=CAMPO_COLLEGAMENTO;...")
   * dalla riga scelta, saltando il campo della casella stessa e i valori gia' uguali,
   * cosi' le caselle collegate fra loro non si rimandano il cambio all'infinito.
   */
  applicaMappings(mappingStr: string, selectedItem: any, modulo: Form, campo?: string): void {
    const dati = modulo.option('formData') ?? {};
    for (const [campoModulo, campoCollegamento] of this._coppieMappings(mappingStr)) {
      if (campoModulo === campo) continue;
      const valore = selectedItem ? (selectedItem[campoCollegamento] ?? null) : null;
      if ((dati[campoModulo] ?? null) !== valore) modulo.updateData(campoModulo, valore);
    }
  }

  private _coppieMappings(mappingStr: string | undefined): [string, string][] {
    return (mappingStr ?? '')
      .split(/[;\r\n]+/)
      .map(coppia => coppia.split('=').map(s => s.trim()))
      .filter(([campoModulo, campoCollegamento]) => !!campoModulo && !!campoCollegamento)
      .map(([campoModulo, campoCollegamento]) => [campoModulo, campoCollegamento] as [string, string]);
  }

  /** Filtro della riga per una chiave composta: le parti diverse dal campo vengono dal modulo. */
  private _filtroChiaveComposta(
    config: LookupConfig, chiave: string[], campoChiave: string, key: unknown, elemento: Element | undefined,
  ): unknown[] {
    const dati = this.moduloDi(elemento)?.option('formData') ?? {};
    const campoNelModulo = new Map(this._coppieMappings(config.mappings).map(([m, c]) => [c, m]));
    const filtro: unknown[] = [[campoChiave, '=', key]];
    for (const parte of chiave) {
      if (parte === campoChiave) continue;
      const valore = dati[campoNelModulo.get(parte) ?? parte];
      if (valore !== undefined && valore !== null && valore !== '') filtro.push('and', [parte, '=', valore]);
    }
    return filtro.length === 1 ? filtro[0] as unknown[] : filtro;
  }

  executeMappings(mappingStr: string | undefined, selectedItem: any, target: any): void {
    if (!mappingStr || !target) return;

    mappingStr.split(';').forEach(pair => {
      const [tField, sField] = pair.split('=').map(s => s.trim());
      if (!tField || !sField) return;

      const value = selectedItem ? selectedItem[sField] : null;

      if (typeof target[tField] === 'function' && 'set' in target[tField]) {
        target[tField].set(value);
      } else {
        target[tField] = value;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Rendering righe e header
  // ═══════════════════════════════════════════════════════════════════════════

  private _buildRow(item: any, columns: LookupColumn[], isHeader: boolean): HTMLElement {
    const row = this.renderer.createElement('div');
    this.renderer.addClass(row, isHeader ? 'z-lookup-header-row' : 'z-lookup-data-row');

    columns.forEach(col => {
      const cell = this.renderer.createElement('div');
      this.renderer.addClass(cell, 'z-lookup-cell');

      if (col.width) {
        this.renderer.setStyle(cell, 'width', `${col.width}px`);
        this.renderer.setStyle(cell, 'flex', 'none');
      } else {
        this.renderer.setStyle(cell, 'flex', '1');
      }

      if (col.alignment) {
        this.renderer.setStyle(cell, 'textAlign', col.alignment);
      }

      const text = isHeader ? col.caption : (item?.[col.field] ?? '');
      this.renderer.setProperty(cell, 'innerText', text);
      this.renderer.appendChild(row, cell);
    });

    return row;
  }

  private _injectHeader(instance: any, columns: LookupColumn[]): void {
    const content = (instance as any)._popup?.content();
    const popupEl = content instanceof HTMLElement ? content : content?.[0];
    if (!popupEl) return;

    const WRAPPER_CLASS = 'z-lookup-header-wrapper';
    const existing = popupEl.querySelector(`.${WRAPPER_CLASS}`);
    if (existing) this.renderer.removeChild(popupEl, existing);

    const headerContainer = this.renderer.createElement('div');
    this.renderer.addClass(headerContainer, WRAPPER_CLASS);
    this.renderer.appendChild(headerContainer, this._buildRow(null, columns, true));

    const scrollable = popupEl.querySelector('.dx-scrollable');
    if (scrollable) {
      this.renderer.insertBefore(scrollable.parentNode, headerContainer, scrollable);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CSS globale
  // ═══════════════════════════════════════════════════════════════════════════

  private _ensureStyles(): void {
    const STYLE_ID = 'z-lookup-styles-v21';
    if (this.document.getElementById(STYLE_ID)) return;

    const style = this.renderer.createElement('style');
    this.renderer.setProperty(style, 'id', STYLE_ID);
    this.renderer.setProperty(style, 'innerHTML', `
      .z-lookup-header-wrapper { 
        background-color: #f8f9fa; 
        border-bottom: 2px solid #dee2e6; 
        position: sticky; 
        top: 0; 
        z-index: 10; 
      }
      .z-lookup-header-row { display: flex; font-weight: bold; color: #212529; font-size: 0.9em; }
      .z-lookup-data-row { display: flex; border-bottom: 1px solid #f1f3f5; }
      .z-lookup-cell { 
        padding: 10px 12px; 
        overflow: hidden; 
        text-overflow: ellipsis; 
        white-space: nowrap; 
        box-sizing: border-box; 
      }
      .z-lookup-popup .dx-list-item-content { padding: 0 !important; }
      .z-lookup-data-row:hover { background-color: #e9ecef; cursor: pointer; }
    `);
    this.renderer.appendChild(this.document.head, style);
  }
}