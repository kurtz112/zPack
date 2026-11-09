/**
 * dependency-engine.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Gestisce le dipendenze tra campi del form (show/hide/enable/require/setValue).
 *
 * Funziona in due fasi:
 *  1. build(meta) — analizza i metadati e costruisce la mappa interna
 *  2. apply(changedField, value, formInstance) — applica le regole
 *
 * Nessuna dipendenza da Angular DI.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { DatasetMetadata, DependencyRule } from '@zng/core/models/metadata.models';

// ─── Tipo interno: regola arricchita con il campo target ────────────────────

interface ResolvedRule extends DependencyRule {
  _targetField: string;
}

// ─────────────────────────────────────────────────────────────────────────────

export class DependencyEngine {

  /** Mappa sourceField → regole (con _targetField già risolto) */
  private map = new Map<string, ResolvedRule[]>();

  /** true se ci sono regole configurate */
  get hasRules(): boolean { return this.map.size > 0; }

  // ─── Costruzione ──────────────────────────────────────────────────────────

  /**
   * Analizza il metadata e popola la mappa interna.
   * Da chiamare ogni volta che cambiano i metadati.
   */
  build(meta: DatasetMetadata): void {
    this.map.clear();
    for (const field of meta.fields) {
      for (const dep of field.control.dependsOn ?? []) {
        const rules = this.map.get(dep.sourceField) ?? [];
        rules.push({ ...dep, _targetField: field.dataField });
        this.map.set(dep.sourceField, rules);
      }
    }
  }

  /** Svuota la mappa (da chiamare su reset/reload) */
  clear(): void {
    this.map.clear();
  }

  // ─── Applicazione ─────────────────────────────────────────────────────────

  /**
   * Applica le regole dipendenti dal campo `changedField` con il valore `value`
   * all'istanza del dx-form fornita.
   */
  apply(changedField: string, value: any, formInstance: any): void {
    const rules = this.map.get(changedField);
    if (!rules?.length || !formInstance) return;

    for (const rule of rules) {
      const tf  = rule._targetField;
      const met = this._evaluate(rule.condition, value);

      switch (rule.action) {
        case 'show':
          formInstance.itemOption(tf, 'visible', met);
          break;
        case 'hide':
          formInstance.itemOption(tf, 'visible', !met);
          break;
        case 'enable':
          formInstance.itemOption(tf, 'editorOptions.readOnly', !met);
          break;
        case 'disable':
          formInstance.itemOption(tf, 'editorOptions.readOnly', met);
          break;
        case 'require':
          formInstance.itemOption(tf, 'isRequired', met);
          break;
        case 'setValue':
          if (met && rule.targetValue !== undefined)
            formInstance.updateData(tf, rule.targetValue);
          break;
      }
    }
  }

  /**
   * Applica tutte le regole configurate usando i valori correnti di `formData`.
   * Va chiamato dopo il rendering iniziale per allineare visibilità/stato
   * con i dati precaricati.
   */
  applyAll(formData: Record<string, any>, formInstance: any): void {
    for (const [src] of this.map)
      this.apply(src, formData?.[src], formInstance);
  }

  // ─── Evaluazione condizione ──────────────────────────────────────────────

  private _evaluate(cond: DependencyRule['condition'], value: any): boolean {
    switch (cond.operator) {
      case '==':       return value == cond.value;
      case '!=':       return value != cond.value;
      case '>':        return value >  cond.value;
      case '<':        return value <  cond.value;
      case '>=':       return value >= cond.value;
      case '<=':       return value <= cond.value;
      case 'contains': return String(value ?? '').includes(String(cond.value));
      case 'notEmpty': return value != null && value !== '';
      case 'empty':    return value == null || value === '';
      default:         return false;
    }
  }
}
