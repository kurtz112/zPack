/**
 * metadata-patch.service.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Persistenza delle modifiche di design-time ai metadati verso il backend.
 *
 * Chiamato da ZzFormComponent ogni volta che l'utente modifica una proprietà
 * tramite il context menu di design (tasto destro sul form body).
 *
 * Endpoint target (TMetadataPatchController.pas):
 *   PATCH /api/data/{datasetId}/metadata/fields
 *   PATCH /api/data/{datasetId}/metadata/settings
 *
 * Funzionamento:
 *  - Le modifiche vengono accumulate in un buffer locale (Map per i campi,
 *    oggetto per le settings) e inviate con debounce (default 800 ms).
 *  - N click rapidi → 1 sola request HTTP (merge automatico per dataField).
 *  - flushNow() forza l'invio immediato (es. prima di navigare al meta-editor).
 *  - hasPendingChanges segnala se ci sono modifiche in attesa.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import notify from 'devextreme/ui/notify';

import { UrlService } from '@zng/core/services/url.service';

// ─── DTO ─────────────────────────────────────────────────────────────────────

/**
 * Patch parziale per un singolo campo.
 * Corrisponde ai campi di ZZ_WEB_DATASETS_FIELDS modificabili da design-time.
 * Solo le proprietà presenti nel payload vengono aggiornate (PATCH semantico).
 */
export interface FieldPatch {
  dataField:  string;   // obbligatorio: identifica il record (→ FIELD)
  caption?:   string;   // → CAPTION
  visible?:   boolean;  // → CARD_VISIBLE
  readOnly?:  boolean;  // → READONLY
  required?:  boolean;  // → REQUIRED
  colSpan?:   number;   // → COL_SPAN
  lineBreak?: boolean;  // → LINEBREAK
  cardIndex?: number;   // → CARD_INDEX
}

/**
 * Patch parziale per le impostazioni globali del form.
 * Corrisponde ai campi FORM_* di ZZ_WEB_DATASETS.
 */
export interface FormSettingsPatch {
  colCount?: number;  // → FORM_COL_COUNT
  // Estendibile: labelLocation → FORM_LABEL_LOC, showColon → FORM_LABEL_COLON, ...
}

export interface MetadataPatchOptions {
  /** Ritardo debounce in ms prima di inviare le modifiche accumulate (default: 800) */
  debounceMs?: number;
  /** Mostra notify DevExtreme al successo/errore (default: true) */
  showNotify?: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────

@Injectable({ providedIn: 'root' })
export class MetadataPatchService {

  private http       = inject(HttpClient);
  private urlService = inject(UrlService);
  private baseUrl    = this.urlService.baseUrl;

  // ── Stato interno ────────────────────────────────────────────────────────

  private _datasetId = '';
  private _opts: Required<MetadataPatchOptions> = { debounceMs: 800, showNotify: true };

  /**
   * Buffer campi: dataField → FieldPatch.
   * Le chiamate successive per lo stesso campo vengono unite (spread merge):
   *   patchField('X', { caption: 'A' })  → { dataField:'X', caption:'A' }
   *   patchField('X', { colSpan: 2 })    → { dataField:'X', caption:'A', colSpan:2 }
   */
  private _fieldBuffer    = new Map<string, FieldPatch>();

  /** Buffer settings: proprietà da aggiornare in ZZ_WEB_DATASETS */
  private _settingsBuffer: FormSettingsPatch = {};

  private _timer: ReturnType<typeof setTimeout> | null = null;

  // ─── Configurazione ───────────────────────────────────────────────────────

  /**
   * Collega il servizio a un dataset specifico.
   * Da chiamare in _loadMetadata() di ZzFormComponent subito dopo
   * this.metadataLoaded.emit(meta).
   * Se il datasetId cambia, svuota il buffer senza inviarlo.
   */
  attach(datasetId: string, opts: MetadataPatchOptions = {}): void {
    console.log('[MetaPatch] attach() →', datasetId);   // DIAG 
    if (this._datasetId !== datasetId) {
      this._cancelPending();
      this._fieldBuffer.clear();
      this._settingsBuffer = {};
    }
    this._datasetId = datasetId;
    this._opts = { ...this._opts, ...opts };
  }

  // ─── API pubblica ─────────────────────────────────────────────────────────

  /**
   * Accoda una patch parziale per un singolo campo.
   * Le chiamate successive per lo stesso dataField vengono unite (merge).
   *
   * Esempi in ZzFormComponent:
   *   this.metaPatch.patchField(fi.dataField, { visible: fi.visible });
   *   this.metaPatch.patchField(fi.dataField, { caption });
   *   this.metaPatch.patchField(fi.dataField, { colSpan: span });
   */
  patchField(dataField: string, patch: Omit<FieldPatch, 'dataField'>): void {
    console.log('[MetaPatch] patchField()', dataField, patch, '| _datasetId:', this._datasetId);  // DIAG
    const existing = this._fieldBuffer.get(dataField) ?? { dataField };
    this._fieldBuffer.set(dataField, { ...existing, ...patch });
    this._scheduleSave();
  }

  /**
   * Accoda una patch parziale per le formSettings (ZZ_WEB_DATASETS).
   *
   * Esempio in ZzFormComponent:
   *   this.metaPatch.patchSettings({ colCount: value });
   */
  patchSettings(patch: FormSettingsPatch): void {
    this._settingsBuffer = { ...this._settingsBuffer, ...patch };
    this._scheduleSave();
  }

  /**
   * Forza l'invio immediato del buffer, cancellando il timer debounce.
   * Usato da ZzFormComponent._navigate() prima di andare al meta-editor,
   * così il meta-editor trova già i dati aggiornati nel DB.
   */
  async flushNow(): Promise<void> {
    this._cancelPending();
    await this._sendAll();
  }

  /** True se ci sono modifiche in attesa di essere inviate al server. */
  get hasPendingChanges(): boolean {
    return this._fieldBuffer.size > 0 || Object.keys(this._settingsBuffer).length > 0;
  }

  // ─── Internals ────────────────────────────────────────────────────────────

  private _scheduleSave(): void {
    console.log('[MetaPatch] _scheduleSave() — debounce', this._opts.debounceMs, 'ms');  // DIAG
    this._cancelPending();
    this._timer = setTimeout(() => this._sendAll(), this._opts.debounceMs);
  }

  private _cancelPending(): void {
    if (this._timer !== null) {
      clearTimeout(this._timer);
      this._timer = null;
    }
  }

  private async _sendAll(): Promise<void> {
    console.log('[MetaPatch] _sendAll() — _datasetId:', this._datasetId,
      '| fields:', [...this._fieldBuffer.values()],
      '| settings:', this._settingsBuffer);  // DIAG

    if (!this._datasetId) {
      console.warn('[MetaPatch] _sendAll() abortito: _datasetId vuoto!');  // DIAG
      return;
    }

    const fieldPatches  = [...this._fieldBuffer.values()];
    const settingsPatch = { ...this._settingsBuffer };
    const hasFields     = fieldPatches.length > 0;
    const hasSettings   = Object.keys(settingsPatch).length > 0;

    if (!hasFields && !hasSettings) {
      console.warn('[MetaPatch] _sendAll() abortito: buffer vuoto');  // DIAG
      return;
    }

    console.log('[MetaPatch] invio HTTP PATCH →', `${this.baseUrl}/data/${this._datasetId}/metadata`);  // DIAG

    // Svuota il buffer PRIMA della request: eventuali modifiche successive
    // durante l'attesa HTTP vengono accodate nel buffer ora vuoto.
    this._fieldBuffer.clear();
    this._settingsBuffer = {};

    const base = `${this.baseUrl}/data/${this._datasetId}/metadata`;

    try {
      await Promise.all([
        hasFields
          ? firstValueFrom(this.http.patch(`${base}/fields`,   fieldPatches))
          : Promise.resolve(),
        hasSettings
          ? firstValueFrom(this.http.patch(`${base}/settings`, settingsPatch))
          : Promise.resolve(),
      ]);

      console.log('[MetaPatch] salvataggio OK');  // DIAG
      if (this._opts.showNotify) {
        notify('Impostazioni form salvate', 'success', 1500);
      }
    } catch (err: any) {
      const msg = err?.error?.message ?? err?.message ?? 'Errore salvataggio metadati';
      console.error('[MetadataPatchService]', msg, err);
      if (this._opts.showNotify) {
        notify(`Errore salvataggio: ${msg}`, 'error', 4000);
      }
    }
  }
}
