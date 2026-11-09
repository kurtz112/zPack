/**
 * zz-lookup.component.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Lookup multicolonna Angular 17+ standalone.
 * Pattern: dx-drop-down-box + dx-data-grid embedded nel dropdown.
 * Implementa ControlValueAccessor → usabile con formControlName / ngModel.
 *
 * LookupConfig (metadata.models.ts):
 *  - dataset      → dataset ZServer da cui caricare i dati
 *  - valueExpr    → campo chiave (solo il primo se multipli separati da virgola)
 *  - displayExpr  → colonne grid, separate da virgola; testo input = join " - "
 *  - params       → cascata: "destParam=sourceField;..."   (opzionale)
 *  - mappings     → "formField=storeField;..."             (opzionale)
 *  - filter       → filtro fisso JSON                      (opzionale)
 *  - pageSize     → default 50
 * ─────────────────────────────────────────────────────────────────────────────
 */

import {
  Component, inject, input, output, signal, computed, effect, untracked,
  ViewChild, forwardRef, ChangeDetectionStrategy, OnDestroy,
} from '@angular/core';
import { NG_VALUE_ACCESSOR, ControlValueAccessor, FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import DataSource from 'devextreme/data/data_source';
import CustomStore from 'devextreme/data/custom_store';
import { firstValueFrom } from 'rxjs';
import {
  DxDropDownBoxModule,
  DxDataGridModule,
  DxDropDownBoxComponent,
} from 'devextreme-angular';

import { LookupConfig } from '@zng/core/models/metadata.models';
import { UrlService } from '@zng/core/services/url.service';

// ─── Tipo colonna grid interna ────────────────────────────────────────────────

export interface LookupColumn {
  dataField: string;
  caption:   string;
  width?:    number | string;
  visible?:  boolean;
}

// ─────────────────────────────────────────────────────────────────────────────

@Component({
  selector: 'zz-lookup',
  standalone: true,
  imports: [FormsModule, DxDropDownBoxModule, DxDataGridModule],
  templateUrl: './zz-lookup.component.html',
  styleUrl:    './zz-lookup.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [{
    provide:     NG_VALUE_ACCESSOR,
    useExisting: forwardRef(() => ZzLookupComponent),
    multi:       true,
  }],
})
export class ZzLookupComponent implements ControlValueAccessor, OnDestroy {

  // ── Input signals ──────────────────────────────────────────────────────────

  /** Configurazione lookup dal metadata — obbligatoria */
  readonly config       = input.required<LookupConfig>();
  /** Dati correnti del form padre (per params a cascata) */
  readonly formData     = input<Record<string, any>>({});
  /** Parametri extra fissi aggiunti a ogni request */
  readonly extraParams  = input<Record<string, any>>({});
  /** Override colonne grid — se vuoto le ricava da displayExpr */
  readonly columns      = input<LookupColumn[]>([]);

  readonly readOnly       = input(false);
  readonly disabled       = input(false);
  readonly placeholder    = input('Seleziona...');
  readonly width          = input<number | string>('100%');
  readonly dropDownWidth  = input<number | string>(640);
  readonly dropDownHeight = input<number | string>(380);

  // ── Output ─────────────────────────────────────────────────────────────────

  /**
   * Emesso alla selezione con i valori da mappare su altri campi form.
   * Uso tipico: (onMappings)="form.patchValue($event)"
   */
  readonly onMappings  = output<Record<string, any>>();
  readonly valueChange = output<any>();

  // ── ViewChild ──────────────────────────────────────────────────────────────

  @ViewChild(DxDropDownBoxComponent) dropDownBox?: DxDropDownBoxComponent;

  // ── State signals ──────────────────────────────────────────────────────────

  readonly currentValue = signal<any>(null);
  readonly displayText  = signal('');
  readonly dataSource   = signal<DataSource | null>(null);

  // ── Computed ──────────────────────────────────────────────────────────────

  /** Primo campo di valueExpr — usato come chiave FK */
  readonly valueField = computed(() =>
    (this.config().valueExpr ?? '').split(',')[0].trim()
  );

  /** Array dei campi displayExpr — usati come colonne e per il testo */
  readonly displayFields = computed(() =>
    (this.config().displayExpr ?? '').split(',').map(s => s.trim()).filter(Boolean)
  );

  /** Colonne effettive per la dx-data-grid interna */
  readonly effectiveColumns = computed<LookupColumn[]>(() => {
    if (this.columns().length) return this.columns();
    const fields = [...new Set([this.valueField(), ...this.displayFields()])].filter(Boolean);
    return fields.map(f => ({ dataField: f, caption: this._formatCaption(f) }));
  });

  // ── Privato ────────────────────────────────────────────────────────────────

  private readonly http = inject(HttpClient);
  private readonly urlService = inject(UrlService);

  /**
   * Parametri dinamici a cascata.
   * Oggetto mutabile condiviso per referenza con la closure load() del CustomStore:
   * ogni aggiornamento è immediatamente visibile senza ricostruire il DataSource.
   */
  private _dynParams: Record<string, any> = {};

  private _onChange:   (v: any) => void = () => {};
  private _onTouched: () => void         = () => {};

  // ─────────────────────────────────────────────────────────────────────────

  constructor() {
    // Ricostruisce il DataSource quando config o extraParams cambiano.
    // Usa untracked per la scrittura su dataSource signal, evitando che
    // Angular marki dirty la view durante l'esecuzione dell'effect.
    effect(() => {
      const cfg = this.config();
      const extra = this.extraParams();
      // Scrittura fuori dal tracking reattivo
      untracked(() => this._initDataSource(cfg, extra));
    });

    // Aggiorna _dynParams al cambio di formData; se qualcosa è cambiato
    // azzera il valore corrente e ricarica il DataSource.
    effect(() => {
      const cfg = this.config();
      const fd = this.formData();
      untracked(() => {
        const changed = this._applyParams(cfg, fd);
        if (changed) {
          if (this.currentValue() != null) this._clearValue();
          this.dataSource()?.reload();
        }
      });
    });
  }

  ngOnDestroy(): void {
    this.dataSource()?.dispose?.();
  }

  // ── ControlValueAccessor ──────────────────────────────────────────────────

  writeValue(val: any): void {
    this.currentValue.set(val ?? null);
    if (val != null) this._resolveDisplayText(val);
    else             this.displayText.set('');
  }

  registerOnChange(fn: any):     void { this._onChange  = fn; }
  registerOnTouched(fn: any):    void { this._onTouched = fn; }
  setDisabledState(_d: boolean): void { /* gestito tramite disabled() input */ }

  // ── Handler template ──────────────────────────────────────────────────────

  onGridSelectionChanged(e: any): void {
    const record = e.selectedRowsData?.[0];
    if (!record) return;

    const newValue = record[this.valueField()];
    this.displayText.set(this._buildDisplayText(record));
    this.currentValue.set(newValue);
    this._onChange(newValue);
    this._onTouched();
    this.valueChange.emit(newValue);

    const mappings = this._buildMappings(record);
    if (Object.keys(mappings).length) this.onMappings.emit(mappings);

    this.dropDownBox?.instance?.close();
  }

  onValueCleared(): void   { this._clearValue(); }
  onDropDownOpened(): void { this._onTouched(); }

  // ── Privato ───────────────────────────────────────────────────────────────

  private _initDataSource(cfg: LookupConfig, extras: Record<string, any>): void {
    // Smaltisce il DataSource precedente prima di crearne uno nuovo
    this.dataSource()?.dispose?.();

    const baseUrl  = `${this.urlService.baseUrl}/data/lk/${cfg.dataset}`;
    const valueKey = (cfg.valueExpr ?? '').split(',')[0].trim();
    const self     = this;  // referenza stabile per la closure del CustomStore

    const store = new CustomStore({
      key: valueKey,

      load: async (loadOpts) => {
        const params: Record<string, any> = {
          ...extras,
          ...self._dynParams,           // ← aggiornato per referenza, sempre fresco
          take:              loadOpts.take ?? cfg.pageSize ?? 50,
          skip:              loadOpts.skip ?? 0,
          requireTotalCount: true,
        };
        if (loadOpts.searchValue && loadOpts.searchExpr) {
          params['searchExpr']  = loadOpts.searchExpr;
          params['searchValue'] = loadOpts.searchValue;
        }
        if (cfg.filter) params['filter'] = JSON.stringify(cfg.filter);

        const result = await firstValueFrom(self.http.get<any>(baseUrl, { params }));
        return Array.isArray(result)
          ? result
          : { data: result.data ?? result, totalCount: result.totalCount };
      },

      byKey: async (key) => {
        try {
          return await firstValueFrom(
            self.http.get<any>(`${baseUrl}/${encodeURIComponent(key)}`, {
              params: { ...extras, ...self._dynParams },
            })
          );
        } catch { return null; }
      },
    });

    this.dataSource.set(new DataSource({
      store,
      paginate: true,
      pageSize: cfg.pageSize ?? 50,
    }));
  }

  /**
   * Aggiorna _dynParams confrontando i valori in formData con config.params.
   * Restituisce true se almeno un valore è cambiato → il chiamante decide se
   * ricaricare il DataSource.
   */
  private _applyParams(cfg: LookupConfig, fd: Record<string, any>): boolean {
    if (!cfg?.params) return false;
    let changed = false;
    for (const pair of cfg.params.replace(/,/g, ';').split(';')) {
      const [dest, src] = pair.trim().split('=');
      const newVal      = fd?.[(src ?? dest).trim()] ?? null;
      const destParam   = dest.trim();
      if (this._dynParams[destParam] !== newVal) {
        this._dynParams[destParam] = newVal;
        changed = true;
      }
    }
    return changed;
  }

  private _buildDisplayText(record: any): string {
    return this.displayFields()
      .map(f => record[f])
      .filter(v => v != null && v !== '')
      .join(' - ');
  }

  private _buildMappings(record: any): Record<string, any> {
    const ms = this.config().mappings;
    if (!ms || !record) return {};
    const result: Record<string, any> = {};
    for (const pair of ms.replace(/,/g, ';').split(';')) {
      const [ff, sf] = pair.trim().split('=');
      const storeF   = (sf ?? ff).trim();
      const formF    = ff.trim();
      if (formF && storeF && storeF in record) result[formF] = record[storeF];
    }
    return result;
  }

  private async _resolveDisplayText(key: any): Promise<void> {
    try {
      const record = await (this.dataSource()?.store() as any)?.byKey?.(key);
      if (record) this.displayText.set(this._buildDisplayText(record));
    } catch {
      this.displayText.set(String(key ?? ''));
    }
  }

  private _clearValue(): void {
    this.currentValue.set(null);
    this.displayText.set('');
    this._onChange(null);
    this._onTouched();
    this.valueChange.emit(null);
  }

  private _formatCaption(field: string): string {
    return field.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
  }
}
