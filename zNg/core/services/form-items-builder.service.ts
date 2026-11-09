import { Injectable, inject } from '@angular/core';
import {
  DatasetMetadata, FieldMetadata, FormItem, FormGroupItem, FormTabbedItem, FormSimpleItem, FormEmptyItem, FormButtonItem
} from '@zng/core/models/metadata.models';
import { LookupHelperService } from './lookup.helper.service';
import { DependencyEngine } from '@zng/core/components/zz-form/dependency-engine';
import { FORMATO_INTERO, agganciaCampoIntero, colonnaIntera } from '@zng/core/helper/campo-intero';

/**
 * Vero per i campi a casella (booleani). Non sono mai obbligatori, qualunque cosa
 * dicano i metadati: la RequiredRule di DevExtreme rifiuta false, e la casella
 * tolta non si salverebbe. Vale per la scheda e per la griglia (zz-data-grid).
 */
export function isBooleanField(field: FieldMetadata): boolean {
  const editor = field.control?.editorType;
  return field.dataType === 'boolean' || editor === 'dxCheckBox' || editor === 'dxSwitch';
}

/**
 * Classe dei campi a casella con l'etichetta accanto (zz-form.component.scss):
 * li allinea alla riga dei campi vicini invece che alla riga delle etichette.
 */
export const CLASSE_CAMPO_CASELLA = 'zz-campo-casella';

/** Regole di validazione dei metadati, senza 'required' sui booleani. */
export function validationRulesOf(field: FieldMetadata): any[] {
  const rules = field.control?.validation ?? [];
  return isBooleanField(field) ? rules.filter(r => r.type !== 'required') : rules;
}

export type ItemPostProcessor =(item: any, field?: FieldMetadata) => void;
export interface FormItemsResult {
  items: any[];
  itemPaths: Map<string, string>;
}

@Injectable({ providedIn: 'root' })
export class FormItemsBuilderService {
  private readonly lookupHelper = inject(LookupHelperService);
  /** Posizione delle etichette della scheda in costruzione (formSettings.labelLocation). */
  private _labelLocation?: string;

  /**
   * Costruisce gli item per il dx-form partendo dall'albero V8 del DB.
   * @param meta Metadati del dataset.
   * @param engine Istanza del DependencyEngine per gestire le regole dinamiche.
   * @param postProcess Callback facoltativo per personalizzare ogni item dopo la costruzione.
   */
  build(meta: DatasetMetadata, engine: DependencyEngine, postProcess?: ItemPostProcessor): FormItemsResult {
    engine.build(meta);
    // la costruzione e' sincrona: il valore vale per questa chiamata soltanto
    this._labelLocation = meta.formSettings.labelLocation;
    
    const items: any[] = [];
    const itemPaths = new Map<string, string>();
    
    const rootItems = meta.formSettings.items || [];
    
    // Elaborazione ricorsiva dei nodi
    for (const item of rootItems) {
      const processedItem = this._processNode(item, meta, engine, '', itemPaths, postProcess);
      if (processedItem) {
        items.push(processedItem);
      }
    }
    
    // Aggiungi i campi non mappati nell'albero (orfani)
    this._injectOrphans(meta, items, itemPaths, engine, postProcess);

    return { items, itemPaths };
  }

  private _processNode(
    node: FormItem,
    meta: DatasetMetadata,
    engine: DependencyEngine,
    pathPrefix: string,
    itemPaths: Map<string, string>,
    postProcess?: ItemPostProcessor
  ): any {
    if (node.visible === false) return null;

    if (node.itemType === 'group') {
      const groupNode = node as FormGroupItem;
      const currentPath = pathPrefix ? `${pathPrefix}.${groupNode.name || 'group'}` : (groupNode.name || 'group');
      
      const childItems = [];
      for (const child of (groupNode.items || [])) {
        const processed = this._processNode(child, meta, engine, currentPath, itemPaths, postProcess);
        if (processed) childItems.push(processed);
      }
      
      if (childItems.length === 0) return null;

      const resultOpts: any = {
        itemType: 'group',
        name: groupNode.name,
        caption: groupNode.caption,
        icon: groupNode.icon,
        colCount: groupNode.colCount || meta.formSettings.colCount,
        items: childItems
      };
      
      if (groupNode.colSpan) resultOpts.colSpan = groupNode.colSpan;
      if (groupNode.cssClass) resultOpts.cssClass = groupNode.cssClass;
      if (groupNode.baseWebCollapsible) {
        resultOpts.cssClass = (resultOpts.cssClass ? resultOpts.cssClass + ' ' : '') + 'collapsible-group';
        // DevExtreme non ha direttamente collapsible groups nativi a questo livello senza template, ma si può usare cssClass per personalizzarlo
      }
      return resultOpts;
    }

    if (node.itemType === 'tabbed') {
      const tabbedNode = node as FormTabbedItem;
      const currentPath = pathPrefix ? `${pathPrefix}.${tabbedNode.name || 'tabbed'}` : (tabbedNode.name || 'tabbed');
      
      const renderedTabs = [];
      for (const tab of (tabbedNode.tabs || [])) {
        if (tab.visible === false) continue;
        
        const tabPath = `${currentPath}.${tab.title || 'tab'}`;
        const tabChildItems = [];
        for (const child of (tab.items || [])) {
          const processed = this._processNode(child, meta, engine, tabPath, itemPaths, postProcess);
          if (processed) tabChildItems.push(processed);
        }
        
        const renderedTab: any = {
          title: tab.title,
          icon: tab.icon,
          badge: tab.badge,
          disabled: tab.disabled,
          items: tabChildItems
        };
        if (tab.colSpan) renderedTab.colSpan = tab.colSpan;
        if (tab.cssClass) renderedTab.cssClass = tab.cssClass;
        renderedTabs.push(renderedTab);
      }

      if (renderedTabs.length === 0) return null;

      const resultTabbed: any = {
        itemType: 'tabbed',
        name: tabbedNode.name,
        tabs: renderedTabs
      };
      if (tabbedNode.colSpan) resultTabbed.colSpan = tabbedNode.colSpan;
      if (tabbedNode.cssClass) resultTabbed.cssClass = tabbedNode.cssClass;
      if (tabbedNode.tabPanelOptions) resultTabbed.tabPanelOptions = tabbedNode.tabPanelOptions;
      return resultTabbed;
    }

    if (node.itemType === 'empty') {
      const emptyNode = node as FormEmptyItem;
      return {
        itemType: 'empty',
        name: emptyNode.name,
        colSpan: emptyNode.colSpan,
        cssClass: emptyNode.cssClass
      };
    }

    if (node.itemType === 'button') {
      const buttonNode = node as FormButtonItem;
      return {
        itemType: 'button',
        name: buttonNode.name,
        colSpan: buttonNode.colSpan,
        cssClass: buttonNode.cssClass,
        buttonOptions: buttonNode.buttonOptions
      };
    }

    // Default: simple item (dataField)
    const simpleNode = node as FormSimpleItem;
    const field = meta.fields.find(f => f.dataField === simpleNode.dataField);
    
    if (!field) {
      console.warn(`[FormBuilder] Campo non trovato nei metadata: ${simpleNode.dataField}`);
      return null;
    }
    
    // Controlla la visibilità a livello di campo
    if (field.control && field.control.visible === false) {
      return null;
    }

    const fieldPath = pathPrefix ? `${pathPrefix}.${field.dataField}` : field.dataField;
    itemPaths.set(field.dataField, fieldPath);
    
    const renderedItem = this._buildFormItem(field, simpleNode, engine, postProcess);
    return renderedItem;
  }

  // ─── Core Item Builder ─────────────────────────────────────────────────────

  /**
   * Casella con l'etichetta sopra: nelle schede a etichette sopra il campo
   * restava un quadratino solo in mezzo a una colonna vuota, a meta' fra
   * l'etichetta e i campi della riga. Il testo passa accanto alla casella
   * (opzione text di dxCheckBox) e la classe la porta all'altezza dei campi
   * vicini. Non per dxSwitch, che non ha un testo proprio.
   */
  private _etichettaAccantoAllaCasella(item: any, field: FieldMetadata): void {
    const editor = field.control?.editorType;
    if (editor === 'dxSwitch' || !isBooleanField(field)) return;
    item.editorType = 'dxCheckBox';
    item.editorOptions = { ...item.editorOptions, text: item.label.text };
    item.label = { ...item.label, visible: false };
    item.cssClass = [item.cssClass, CLASSE_CAMPO_CASELLA].filter(Boolean).join(' ');
  }

  private _buildFormItem(field: FieldMetadata, node: FormSimpleItem, engine: DependencyEngine, postProcess?: ItemPostProcessor): any {
    const etichettaSopra = (this._labelLocation ?? 'top') === 'top';
    const ctrl = field.control;
    const item: any = {
      dataField: field.dataField,
      label: { text: ctrl.label || field.caption }, // Usa label se esplicitato in V8, altrimenti caption standard
      isRequired: ctrl.required && !isBooleanField(field),
      visible: ctrl.visible ?? true,
    };

    // Il nodo V8 potrebbe sovrascrivere il colSpan del campo
    const finalColSpan = node.colSpan || ctrl.colSpan;
    if (finalColSpan && finalColSpan > 1) item.colSpan = finalColSpan;
    
    if (node.cssClass) item.cssClass = node.cssClass;

    const onValueChanged = (e: any) => {
      const form = e.component.option('formInstance');
      if (form) {
        engine.apply(field.dataField, e.value, form);
      }
    };

    if (field.lookup) {
      item.editorType = ctrl.editorType || 'dxSelectBox';

      // I mappings portano nel modulo le altre colonne della riga scelta (per esempio
      // le altre parti di una chiave composta). Un valore che il collegamento non trova
      // non cancella niente: si svuotano i campi solo quando l'utente svuota la casella.
      const lookupOptions = this.lookupHelper.getEditorOptions(field.lookup, (selectedItem: any, e: any) => {
        if (!field.lookup?.mappings) return;
        if (!selectedItem && e?.component?.option('value') != null) return;
        const form = this.lookupHelper.moduloDi(e?.element);
        if (form) this.lookupHelper.applicaMappings(field.lookup.mappings, selectedItem, form, field.dataField);
      }, field.dataField);

      item.editorOptions = {
        ...lookupOptions,
        readOnly: ctrl.readOnly,
        ...ctrl.editorOptions,
        onValueChanged: onValueChanged
      };
    } else {
      item.editorType = ctrl.editorType;
      item.editorOptions = {
        ...this._buildStandardOptions(field),
        onValueChanged: onValueChanged
      };
    }

    item.validationRules = this._buildValidationRules(validationRulesOf(field));

    if (etichettaSopra) this._etichettaAccantoAllaCasella(item, field);

    // Post-processing: permette al chiamante di personalizzare l'item
    if (postProcess) {
      postProcess(item, field);
    }

    return item;
  }

  private _buildStandardOptions(field: FieldMetadata): any {
    const ctrl = field.control;
    const opts: any = { readOnly: ctrl.readOnly, ...(ctrl.editorOptions ?? {}) };

    if (field.picklist) {
      opts.dataSource = field.picklist.items;
      opts.valueExpr = 'value';
      opts.displayExpr = 'text';
    }

    if (ctrl.editorType === 'dxDateBox') {
      // Gestione differenziata per datetime, date e time
      if (field.dataType === 'datetime') {
        opts.type = 'datetime';
        opts.displayFormat = 'dd/MM/yyyy HH:mm';
      } else if (field.dataType === 'time') {
        opts.type = 'time';           // Imposta il widget in modalità orologio
        opts.displayFormat = 'HH:mm'; // Formato visualizzazione 24h
        opts.pickerType = 'list';      // Opzionale: 'list', 'rollers' o 'calendar' (default)
      } else {
        opts.type = 'date';
        opts.displayFormat = 'dd/MM/yyyy';
      }
    }

    if (ctrl.editorType === 'dxNumberBox' && field.column.fieldDecimals) {
      opts.format = '#,##0.' + '0'.repeat(field.column.fieldDecimals);
    }

    // Colonna intera: niente virgola ne' punto (ZNG-SCH-016). Il gestore si aggancia
    // all'editor quando nasce; se i metadati hanno gia' un onInitialized si chiamano entrambi.
    if (ctrl.editorType === 'dxNumberBox' && colonnaIntera(field.column.fieldType, field.column.fieldDecimals)) {
      opts.format = FORMATO_INTERO;
      const inizialeDeiMetadati = opts.onInitialized;
      opts.onInitialized = (e: any) => {
        agganciaCampoIntero(e.element, e.component);
        if (typeof inizialeDeiMetadati === 'function') inizialeDeiMetadati(e);
      };
    }

    if (ctrl.placeholder) opts.placeholder = ctrl.placeholder;

    return opts;
  }

  // ─── Utilities ─────────────────────────────────────────────────────────────

  private _visibleFields(meta: DatasetMetadata): FieldMetadata[] {
    return meta.fields
      .filter(f => f.control.visible !== false && !f.isPrimaryKey)
      .sort((a, b) => (a.control.sortOrder || 0) - (b.control.sortOrder || 0));
  }

  private _injectOrphans(
    meta: DatasetMetadata, 
    items: any[], 
    paths: Map<string, string>, 
    engine: DependencyEngine, 
    postProcess?: ItemPostProcessor
  ): void {
    // I campi mappati dentro "paths" sono quelli già costruiti.
    // L'orfano è colui visibile in form ma non ancora appeso all'albero
    const orphans = this._visibleFields(meta).filter(f => !paths.has(f.dataField));

    if (orphans.length) {
      items.push({
        itemType: 'group',
        caption: 'Altro',
        items: orphans.map(f => {
          paths.set(f.dataField, f.dataField);
          // pass an artificial FormSimpleItem node
          return this._buildFormItem(f, { itemType: 'simple', dataField: f.dataField } as FormSimpleItem, engine, postProcess);
        })
      });
    }
  }

  private _buildValidationRules(rules?: any[]): any[] {
    return rules?.map(r => ({
      type: r.type,
      message: r.message,
      pattern: r.pattern,
      min: r.min,
      max: r.max
    })) ?? [];
  }
}
