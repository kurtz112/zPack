/**
 * zz-form.component.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Form generico metadata-driven basato su DevExtreme dx-form.
 * Supporta modalità inline e popup (modal).
 *
 * FIX applicati:
 *  1. onFieldChanged: rimosso formData.update(d => ({...d})) che causava
 *     loop infinito di change detection (NG0103). Ora usa _formDataRef
 *     stabile e aggiorna solo quando necessario (fields2Clear).
 *  2. _mountLookups: aggiunto retry con setTimeout per inline mode dove
 *     il ViewChild formBodyEl non è ancora assegnato al primo content ready.
 *  3. onFormContentReady: usa Promise.resolve().then() anche in inline
 *     per dare tempo al DOM di stabilizzarsi (come faceva già in modale).
 *  4. _rebuildVisibleCustomButtons: chiamato anche in ngOnInit e dopo
 *     _loadMetadata per garantire che i pulsanti siano sempre visibili.
 *  5. devToolsBtnId: id unico generato con counter per evitare conflitti
 *     quando più form sono nella stessa pagina.
 *  6. Gestione showSaveButton inline: in inline mode mostra Salva se
 *     mode !== 'view'.
 * ─────────────────────────────────────────────────────────────────────────────
 */

import {
  Component, ViewChild, AfterViewInit,
  OnInit, OnChanges, SimpleChanges, OnDestroy,
  inject, signal, computed, input, output, model, ElementRef, ChangeDetectorRef,
  effect, untracked,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';

import { DxFormModule, DxFormComponent } from 'devextreme-angular/ui/form';
import { DxValidationGroupModule } from 'devextreme-angular/ui/validation-group';
import { DxPopupModule } from 'devextreme-angular/ui/popup';
import { DxScrollViewModule } from 'devextreme-angular/ui/scroll-view';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxToolbarModule } from 'devextreme-angular/ui/toolbar';
import { DxContextMenuModule, DxContextMenuTypes } from 'devextreme-angular/ui/context-menu';
import notify from 'devextreme/ui/notify';

import { MetadataService } from '@zng/core/services/metadata.service';
import { MetadataPatchService } from '@zng/core/services/metadata-patch.service';
import { DatasetMetadata, ControlConfig, FieldMetadata } from '@zng/core/models/metadata.models';
import { UrlService } from '@zng/core/services/url.service';
import { UserCapabilitiesService } from '@zng/core/services/user-capabilities.service';

import { ActionButton, ActionButtonEvent } from '@zng/core/models/action-button.model';
import { FormFocusTracker } from './form-focus-tracker';
import { DependencyEngine } from './dependency-engine';
import { buildDesignMenu, DesignMenuActions, TMPL_COL_COUNT, TMPL_CAPTION, TMPL_CARD_INDEX } from './design-menu.builder';
import { MenuBuilder, MenuItem, IMenuItem } from '@zng/core/helper/menu-builder';
import { FormItemsBuilderService } from '@zng/core/services/form-items-builder.service';
import { ZServerService } from '@zng/core/services/zserver.service';
import { erroreGiaMostrato, messaggioErrore, mostraAvviso } from '@zng/core/services/avviso';
import { ZzMetaInLocoService } from '@zng/zz/meta-editor/meta-in-loco.service';
import { PREFISSO_CLASSE_CAMPO } from '@zng/zz/meta-editor/meta-runtime';
import { CustomStore } from 'devextreme/common/data';

export type ZzFormMode = 'insert' | 'edit' | 'view';

// Counter globale per ID univoci dei bottoni DevTools
let _formInstanceCounter = 0;

// ─────────────────────────────────────────────────────────────────────────────

@Component({
  selector: 'zz-form',
  standalone: true,
  imports: [
    CommonModule,
    DxFormModule, DxValidationGroupModule,
    DxPopupModule, DxScrollViewModule, DxButtonModule,
    DxToolbarModule, DxContextMenuModule
  ],
  templateUrl: './zz-form.component.html',
  styleUrl: './zz-form.component.scss',
})
export class ZzFormComponent implements OnInit, OnChanges, AfterViewInit {

  // ── ViewChildren ───────────────────────────────────────────────────────────

  @ViewChild('form') form!: DxFormComponent;

  @ViewChild('formBodyEl')
  set formBodyEl(el: ElementRef<HTMLDivElement> | undefined) {
    this._formBodyEl = el;
    // Con designMenuTarget come signal, il cambio viene tracciato
    // correttamente da Angular e non causa NG0100
    this._syncMenuTarget();
  }
  private _formBodyEl?: ElementRef<HTMLDivElement>;

  // Store principale della form
  private _dataStore: CustomStore | null = null;
  private _currentData: any = {};

  // ── Input ──────────────────────────────────────────────────────────────────

  readonly dataset = input.required<string>();
  readonly formData = model<Record<string, any>>({});
  readonly readOnly = input(false);
  readonly modal = input(false);
  readonly visible = model(false);
  readonly mode = model<ZzFormMode>('edit');
  readonly popupTitle = input<string | undefined>(undefined);
  readonly popupWidth = input<number | string | undefined>(undefined);
  readonly popupHeight = input<number | string | undefined>(undefined);
  readonly showDevToolsOverride = input<boolean | undefined>(undefined, { alias: 'showDevTools' });

  /** Pulsanti custom da mostrare nella toolbar del popup */
  readonly customButtons = input<ActionButton[]>([]);

  // ── Output ─────────────────────────────────────────────────────────────────
  readonly beforeLoad = output<{ dataset: string; extraParams: Record<string, any> }>();
  readonly metadataLoaded = output<DatasetMetadata>();
  readonly fieldDataChanged = output<{ dataField: string; value: any }>();
  readonly saved = output<{ mode: ZzFormMode; data: Record<string, any> }>();
  readonly cancelled = output<void>();
  readonly actionButtonClick = output<ActionButtonEvent>();

  // ── Servizi ────────────────────────────────────────────────────────────────
  private readonly zserver = inject(ZServerService);
  private metadataSvc = inject(MetadataService);
  private metaPatch = inject(MetadataPatchService);
  private http = inject(HttpClient);
  private urlService = inject(UrlService);
  private router = inject(Router);
  private cdr = inject(ChangeDetectorRef);
  private capabilities = inject(UserCapabilitiesService);
  private itemsBuilder = inject(FormItemsBuilderService);
  // Editor dei metadati in loco (tasto destro): senza il servizio resta il menu di design
  private inLoco = inject(ZzMetaInLocoService, { optional: true });
  private _ultimaModificaLetta = 0;
  private _elementoMenuInLoco: HTMLElement | null = null;

  constructor() {
    // Dopo un comando in loco i metadati del dataset sono cambiati: la scheda li
    // rilegge e ricostruisce i campi, senza perdere i valori digitati
    effect(() => {
      const cambiato = this.inLoco?.cambiato();
      untracked(() => {
        if (!cambiato || cambiato.volta === this._ultimaModificaLetta) return;
        this._ultimaModificaLetta = cambiato.volta;
        if (cambiato.dataset === this.dataset() && this.metadata()) this._rileggiMetadati();
      });
    });
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  readonly showDevTools = computed(() => {
    const override = this.showDevToolsOverride();
    return override !== undefined ? override : this.capabilities.canDevTools();
  });

  // ── Stato reattivo ─────────────────────────────────────────────────────────

  readonly metadata = signal<DatasetMetadata | null>(null);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  formItems: any[] = [];
  itemPaths: Map<string, string> = new Map();

  // ── Helper esterni ─────────────────────────────────────────────────────────

  readonly focusTracker = new FormFocusTracker();
  private readonly depEngine = new DependencyEngine();

  // ── Dev tools ──────────────────────────────────────────────────────────────

  /**
   * FIX #5: ID univoco per il bottone DevTools, evita conflitti DOM
   * quando più istanze di zz-form coesistono nella stessa pagina
   * (es. inline + modale, oppure tab diversi).
   */
  readonly devToolsBtnId = `formDevToolsBtn_${++_formInstanceCounter}`;

  designMenuItems: MenuItem[] = [];
  readonly tmplColCount = TMPL_COL_COUNT;
  readonly tmplCaption = TMPL_CAPTION;
  readonly tmplCardIndex = TMPL_CARD_INDEX;
  /**
   * Signal per il target del context menu di design.
   * Usare un signal evita NG0100: Angular traccia la dipendenza e
   * non si lamenta quando cambia tra CD cycles diversi.
   */
  readonly designMenuTarget = signal<HTMLElement | null>(null);

  readonly devToolsMenuItems: MenuItem[] = MenuBuilder.create()
    .item({
      id: 'copy',
      text: 'Copia Identificativo dataset',
      icon: 'copy',
      onClick: () => {
        const dsName = this.dataset();
        navigator.clipboard.writeText(dsName).then(() => {
          notify(`Nome dataset '${dsName}' copiato negli appunti!`, 'success', 2000);
        });
      }
    })
    .build();

  // ── Guard anti-loop ────────────────────────────────────────────────────────

  private _fieldChangedEnabled = true;
  disableFieldChanged(): void { this._fieldChangedEnabled = false; }
  enableFieldChanged(): void { this._fieldChangedEnabled = true; }
  fieldChangedDisabled(): boolean { return !this._fieldChangedEnabled; }

  // ── Computed ───────────────────────────────────────────────────────────────

  get computedTitle(): string {
    if (this.popupTitle()) return this.popupTitle()!;
    const caption = this.metadata()?.caption ?? this.dataset();
    switch (this.mode()) {
      case 'insert': return `Nuovo — ${caption}`;
      case 'edit': return `Modifica — ${caption}`;
      case 'view': return caption;
    }
  }

  get computedWidth(): number | string {
    if (this.popupWidth()) return this.popupWidth()!;
    if (this.metadata()?.formSettings?.width) return this.metadata()!.formSettings!.width!;
    
    // Algoritmo: consideriamo il colCount del form per non eccedere la larghezza disponibile.
    const colCount = this.metadata()?.formSettings?.colCount || 1;
    let fallbackWidth = 0;
    
    if (typeof window !== 'undefined') {
      const maxAvailableWidth = window.innerWidth * 0.9;
      // Stima base di larghezza per colonna + padding
      const estimatedWidth = colCount * 400 + 100;
      fallbackWidth = Math.min(estimatedWidth, maxAvailableWidth);
    } else {
      fallbackWidth = colCount * 400 + 100;
    }
    
    return fallbackWidth > 0 ? fallbackWidth : 900;
  }

  get computedHeight(): number | string {
    if (this.popupHeight()) return this.popupHeight()!;
    if (this.metadata()?.formSettings?.height) return this.metadata()!.formSettings!.height!;
    return 'auto';
  }

  get computedResizable(): boolean { return this.metadata()?.formSettings?.resizable ?? true; } //*** POPUP

  // Dissolvenza al posto dell'animazione 'pop' predefinita su desktop, che
  // apre il popup in scala 0.55 e lo allarga in circa 350 ms: in quel tempo
  // i pulsanti non sono ancora al loro posto e un clic (per esempio su
  // Annulla) cade a vuoto o su un altro controllo. Con la dissolvenza la
  // scheda ha subito la dimensione e la posizione finali.
  readonly animazionePopup = {
    show: { type: 'fade', duration: 150, from: 0, to: 1 },
    hide: { type: 'fade', duration: 100, from: 1, to: 0 },
  } as const;
  get isReadOnly(): boolean { return this.readOnly() || this.mode() === 'view'; }
  get showSaveButton(): boolean { return this.mode() !== 'view'; }

  /** Testo del pulsante di chiusura/annullamento in base al mode */
  get closeButtonText(): string { return this.mode() === 'view' ? 'Chiudi' : 'Annulla'; }
  get closeButtonIcon(): string { return this.mode() === 'view' ? 'close' : 'revert'; }

  /** Pulsanti custom filtrati per contesto form e mode corrente */
  visibleCustomButtons: ActionButton[] = [];

  /** Ricostruisce la lista dei pulsanti custom visibili nella form */
  private _rebuildVisibleCustomButtons(): void {
    const mode = this.mode();
    this.visibleCustomButtons = this.customButtons().filter(b => {
      if (b.visible === false) return false;
      const target = b.target ?? 'both';
      if (target !== 'form' && target !== 'both') return false;
      if (b.formModes?.length && !b.formModes.includes(mode)) return false;
      return true;
    });
  }

  // ── Custom button handler ──────────────────────────────────────────────────

  onCustomButtonClick(button: ActionButton): void {
    this.actionButtonClick.emit({
      button,
      data: { ...this.formData() },
      formMode: this.mode(),
      source: 'form',
    });
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  ngOnInit(): void {
    this._rebuildVisibleCustomButtons();   // FIX #4: rebuild subito
    if (this.dataset() && (!this.modal() || this.visible())) {
      this._loadMetadata();
    }
  }

  ngAfterViewInit(): void {
    if (!this.modal()) this._syncMenuTarget();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['dataset'] && !changes['dataset'].firstChange) {
      this._loadMetadata();
    }
    if (changes['visible'] && this.visible() && this.modal()) {
      if (!this.metadata()) this._loadMetadata();
      if (this.mode() === 'insert' && changes['visible'].currentValue && !changes['visible'].previousValue) {
        this.formData.set({});
      }
      this._rebuildVisibleCustomButtons();
    }
    if (changes['mode'] || changes['customButtons']) {
      this._rebuildVisibleCustomButtons();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  validate(): any { return this.form?.instance?.validate(); }
  resetValidation(): void { this.form?.instance?.repaint(); }
  get instance() { return this.form?.instance; }
  isValid(): boolean { return this.form?.instance?.validate()?.isValid ?? false; }
  focusField(df: string): void { this.form?.instance?.getEditor(df)?.focus(); }
  fieldExists(df: string): boolean { return Object.prototype.hasOwnProperty.call(this.formData(), df); }
  fieldValue(df: string): any { return this.formData()?.[df] ?? null; }
  updateValue(df: string, value: any): void { this.formData.update(d => ({ ...d, [df]: value })); }

  oldopen(mode: ZzFormMode, data?: Record<string, any>): void {
    this.disableFieldChanged();
    this.mode.set(mode);
    this.formData.set(mode === 'insert' ? {} : { ...(data ?? {}) });
    this._rebuildVisibleCustomButtons();
    this.visible.set(true);
  }

  open(mode: ZzFormMode, data?: any): void {
    this.mode.set(mode);
    this.visible.set(true);

    const datasetName = this.dataset();
    const params: Record<string, any> = {};

    // 1. Emettiamo l'evento per i parametri
    this.beforeLoad.emit({ dataset: datasetName, extraParams: params });

    // 2. Creiamo lo store tramite il servizio (usando i parametri extra)
    // Nota: usiamo 'ID' come default se i metadata non sono ancora pronti
    const pk = this.metadata()?.primaryKey ?? 'ID';
    this._dataStore = this.zserver.createDataStore(datasetName, pk, params);

    if (mode === 'insert') {
      this._currentData = {};
      this.formData.set({});
    } else {
      // CASO A: Passi l'oggetto completo (es. dalla grid)
      if (data && typeof data === 'object') {
        this._currentData = { ...data };
        this.formData.set({ ...data });
      }
      // CASO B: Passi solo l'ID (es. 123)
      else if (data !== undefined && data !== null) {
        this._dataStore.byKey(data).then((res: any) => {
          this._currentData = { ...res };
          this.formData.set({ ...res });
        });
      }
      // --- CASO C: Nessun dato passato -> Carica il primo record disponibile
      else {
        // Chiamiamo load() invece di byKey()
        // Passiamo take: 1 per ottimizzare la query lato server
        this._dataStore.load({ take: 1 }).then((res: any) => {
          // DevExtreme può restituire un array semplice o { data: [...], totalCount: ... }
          const items = Array.isArray(res) ? res : res.data;

          if (items && items.length > 0) {
            console.log("Caso C - Record caricato:", items[0]);
            this.formData.set({ ...items[0] });
          } else {
            console.warn("Caso C - Nessun record trovato nel dataset:", datasetName);
            this.formData.set({});
          }
        });
      }
    }
    // Caricamento metadata se necessario
    if (!this.metadata()) {
      this._loadMetadata();
    } else {
      this._rebuildItems();
    }
    setTimeout(() => this._applicaSolaLetturaChiave());
  }
  ///////////////

  close(): void { this.visible.set(false); }

  // ── Popup events ───────────────────────────────────────────────────────────

  onPopupHiding(): void {
    this.visible.set(false);
    this.cancelled.emit();
  }

  onPopupShown(): void {
    this._rebuildVisibleCustomButtons();
    this.disableFieldChanged();
    this._applicaValoriIniziali();
    Promise.resolve().then(() => {
      this._syncMenuTarget();
      this._applyAllDeps();
      this.enableFieldChanged();
    });
  }

  /**
   * FIX #3: Anche in inline usa Promise.resolve per dare tempo al DOM.
   * In più, se il bodyEl non è ancora disponibile, schedula un retry.
   */
  onFormContentReady(): void {
    Promise.resolve().then(() => {
      this._syncMenuTarget();
      this._agganciaMenuInLoco();
      this._applicaSolaLetturaChiave();
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  async save(): Promise<void> {
    const esito = this.form?.instance?.validate();
    if (!esito?.isValid) {
      await this._avvisaCampiNonValidi(esito);
      return;
    }
    const meta = this.metadata();
    if (!meta) return;

    this.saving.set(true);
    const data = this.formData();

    try {
      if (this.mode() === 'insert') {
        await this.http.post(`${this.urlService.baseUrl}/data/${meta.datasetId}`, data).toPromise();
        notify({ message: 'Record inserito', type: 'success' }, 'success', 2500);
      } else if (this.mode() === 'edit') {
        const pkFields = meta.primaryKey.split(',');
        const key = pkFields.length === 1
          ? data[meta.primaryKey]
          : pkFields.map(k => data[k.trim()]).join(',');
        await this.http.put(`${this.urlService.baseUrl}/data/${meta.datasetId}/${key}`, data).toPromise();
        notify({ message: 'Record aggiornato', type: 'success' }, 'success', 2500);
      }
      this.saving.set(false);
      this.saved.emit({ mode: this.mode(), data: { ...data } });
      this.close();
    } catch (err: any) {
      this.saving.set(false);
      // l'errore del server lo mostra gia' l'intercettore dell'applicazione
      if (!erroreGiaMostrato(err))
        await mostraAvviso('Salvataggio non riuscito', [messaggioErrore(err, 'Errore durante il salvataggio')]);
    }
  }

  // Un avviso con i campi da sistemare ("Materiale: obbligatorio"), poi il
  // fuoco sul primo: il solo bordo rosso non si vede se il campo non ha il fuoco
  private async _avvisaCampiNonValidi(esito: any): Promise<void> {
    const regole: any[] = esito?.brokenRules ?? [];
    const campi = this.metadata()?.fields ?? [];
    const righe = regole.map(regola => {
      const dataField: string | undefined = this._campoDellaRegola(regola);
      const campo = campi.find(f => f.dataField === dataField);
      const etichetta = campo ? (campo.control?.label || campo.caption) : '';
      // il messaggio predefinito di DevExtreme per required e' un generico "Richiesto"
      const motivo = regola.type === 'required' ? 'obbligatorio' : (regola.message || 'valore non valido');
      return etichetta && !motivo.includes(etichetta) ? `${etichetta}: ${motivo}` : motivo;
    });
    await mostraAvviso('Dati da completare', righe.length ? [...new Set(righe)] : ['Alcuni campi non sono validi.']);
    regole[0]?.validator?.focus?.();
  }

  // Il validatore del dx-form non porta il nome del campo: lo si legge
  // dall'attributo name della casella, che il dx-form imposta al dataField
  private _campoDellaRegola(regola: any): string | undefined {
    const elemento = regola.validator?.element?.();
    const radice: HTMLElement | undefined = elemento?.[0] ?? elemento;
    return radice?.querySelector?.('input[name]')?.getAttribute('name') ?? undefined;
  }

  // ── Sola lettura visibile ──────────────────────────────────────────────────

  /**
   * La chiave non si cambia in modifica (zServer la esclude dalla UPDATE): la
   * casella diventa di sola lettura, e lo stile .zz-form--modificabile la
   * mostra come tale. In inserimento resta modificabile, salvo READONLY dei
   * metadati. Si applica a ogni apertura, perche' i campi si costruiscono una
   * volta sola e la modalita' cambia.
   */
  private _applicaSolaLetturaChiave(): void {
    const meta = this.metadata();
    const form = this.form?.instance;
    if (!meta || !form) return;
    const chiavi = (meta.primaryKey ?? '').split(',').map(k => k.trim()).filter(Boolean);
    for (const chiave of chiavi) {
      const campo = meta.fields.find(f => f.dataField === chiave);
      const editor = form.getEditor(this.itemPaths.get(chiave) ?? chiave);
      editor?.option('readOnly', this.mode() !== 'insert' || !!campo?.control?.readOnly);
    }
  }

  // ── Field changed ──────────────────────────────────────────────────────────

  /**
   * FIX #1: RIMOSSO il `formData.update(d => ({...d}))` generico che creava
   * un nuovo reference ad ogni field change, causando:
   *   - DevExtreme a ri-settare formData → nuovo onFieldDataChanged → loop
   *   - NG0103 Infinite change detection
   *
   * Ora il formData signal viene aggiornato SOLO quando serve davvero
   * (fields2Clear), e i lookup vengono notificati direttamente.
   */
  onFieldChanged(e: any): void {
    if (this.fieldChangedDisabled()) return;

    // Emetti l'evento per il consumatore
    this.fieldDataChanged.emit({ dataField: e.dataField, value: e.value });

    // Applica dipendenze
    this.depEngine.apply(e.dataField, e.value, this.form?.instance);

    const meta = this.metadata();
    if (!meta) return;

    // Gestisci fields2Clear: quando un campo cambia, azzera i campi dipendenti
    const changedField = meta.fields.find(f => f.dataField === e.dataField);
    if (changedField?.fields2Clear?.length) {
      this.disableFieldChanged();
      for (const df of changedField.fields2Clear) {
        this.form?.instance?.updateData(df, null);
      }
      // Qui SÌ aggiorniamo formData perché abbiamo azzerato campi
      this.formData.update(d => {
        const copy = { ...d };
        for (const df of changedField.fields2Clear!) copy[df] = null;
        return copy;
      });
      this.enableFieldChanged();
    }
  }

  // ── Mouse down ────────c─────────────────────────────────────────────────────

  onFormMouseDown(e: MouseEvent): void {
    this.focusTracker.onFormMouseDown(e);
  }

  // ── Context menu design ────────────────────────────────────────────────────

  onMenuItemClick(e: DxContextMenuTypes.ItemClickEvent): void {
    const item = e.itemData as IMenuItem;
    if (item?.onItemClick) item.onItemClick(e);
  }

  onDesignColCountChange(e: Event): void {
    const value = parseInt((e.target as HTMLInputElement).value, 10);
    if (!isNaN(value) && value > 0) {
      const meta = this.metadata();
      if (!meta) return;
      meta.formSettings.colCount = value;
      this.metadata.set({ ...meta });
      this._rebuildItems();
      this.metaPatch.patchSettings({ colCount: value });
    }
  }

  onDesignCaptionChange(e: Event): void {
    const fi = this.focusTracker.info;
    if (!fi) return;
    const caption = (e.target as HTMLInputElement).value.trim();
    fi.caption = caption;
    this._itemOption(fi.dataField, 'label', { text: caption });
    this._patchField(fi.dataField, f => { f.caption = caption; });
    this.metaPatch.patchField(fi.dataField, { caption });
  }

  onDesignCardIndexChange(e: Event): void {
    const fi = this.focusTracker.info;
    if (!fi) return;
    const index = parseInt((e.target as HTMLInputElement).value, 10);
    if (!isNaN(index)) {
      fi.cardIndex = index;
      this._patch(fi.dataField, c => { c.cardIndex = index; });
      this._rebuildItems();
      this.metaPatch.patchField(fi.dataField, { cardIndex: index });
    }
  }

  onDesignMenuShowing(): void {
    if (!this.showDevTools()) { this.designMenuItems = []; return; }
    this.designMenuItems = buildDesignMenu(
      this.focusTracker.info,
      this.metadata()?.formSettings?.colCount ?? 3,
      this.dataset(),
      {
        copyDatasetName: (name) => {
          navigator.clipboard.writeText(name).then(() => {
            notify(`Nome dataset '${name}' copiato negli appunti!`, 'success', 2000);
          });
        },

        setColCount: (count) => {
          const meta = this.metadata();
          if (!meta) return;
          meta.formSettings.colCount = count;
          this.metadata.set({ ...meta });
          this._rebuildItems();
          this.metaPatch.patchSettings({ colCount: count });
        },

        incollaImpostazioni: () => this._incollaImpostazioni(),

        toggleVisible: (fi) => {
          fi.visible = !fi.visible;
          this._itemOption(fi.dataField, 'visible', fi.visible);
          this._patch(fi.dataField, c => { c.visible = fi.visible; });
          this.metaPatch.patchField(fi.dataField, { visible: fi.visible });
        },

        toggleReadOnly: (fi) => {
          fi.readOnly = !fi.readOnly;
          this._itemOption(fi.dataField, 'editorOptions.readOnly', fi.readOnly);
          this._patch(fi.dataField, c => { c.readOnly = fi.readOnly; });
          this.metaPatch.patchField(fi.dataField, { readOnly: fi.readOnly });
        },

        toggleRequired: (fi) => {
          fi.required = !fi.required;
          this._itemOption(fi.dataField, 'isRequired', fi.required);
          this._patch(fi.dataField, c => { c.required = fi.required; });
          this.metaPatch.patchField(fi.dataField, { required: fi.required });
        },

        toggleLineBreak: (fi) => {
          fi.lineBreak = !fi.lineBreak;
          this._patch(fi.dataField, c => { c.lineBreak = fi.lineBreak; });
          this._rebuildItems();
          this.metaPatch.patchField(fi.dataField, { lineBreak: fi.lineBreak });
        },

        setColSpan: (fi, span) => {
          fi.colSpan = span;
          this._itemOption(fi.dataField, 'colSpan', span);
          this._patch(fi.dataField, c => { c.colSpan = span; });
          this.metaPatch.patchField(fi.dataField, { colSpan: span });
        },

        setCaption: (fi, caption) => {
          fi.caption = caption;
          this._itemOption(fi.dataField, 'label', { text: caption });
          this._patchField(fi.dataField, f => { f.caption = caption; });
          this.metaPatch.patchField(fi.dataField, { caption });
        },

        setCardIndex: (fi, index) => {
          fi.cardIndex = index;
          this._patchField(fi.dataField, f => { f.control.cardIndex = index; });
          this._rebuildItems();
          this.metaPatch.patchField(fi.dataField, { cardIndex: index });
        },

      } satisfies DesignMenuActions,
    );
  }

  // ── Privato ────────────────────────────────────────────────────────────────

  private _loadMetadata(): void {
    this.loading.set(true);
    this.error.set('');
    this.metadata.set(null);
    this.formItems = [];
    this.itemPaths = new Map();
    this.designMenuTarget.set(null);
    this.focusTracker.clear();
    this.depEngine.clear();

    this.metadataSvc.getMetadata(this.dataset()).subscribe({
      next: (meta) => {
        this.metadata.set(meta);

        const result = this.itemsBuilder.build(meta, this.depEngine, this._focusPostProcessor);
        
        //*** POPUP Fix: forza i gruppi a incolonnarsi verticalmente e previene overflow form
        const colCount = meta.formSettings.colCount || 1;
        const fixColSpan = (items: any[], currentColCount: number) => {
          items.forEach(item => {
            if (item.itemType === 'group' && !item.colSpan) {
              item.colSpan = currentColCount;
            }
            if (item.colSpan && item.colSpan > currentColCount) {
              item.colSpan = currentColCount;
            }
            if (item.items) {
              fixColSpan(item.items, item.colCount || currentColCount);
            }
          });
        };
        fixColSpan(result.items, colCount);

        this.formItems = result.items;
        this.itemPaths = result.itemPaths;

        this.depEngine.build(meta);
        this.loading.set(false);
        this.metadataLoaded.emit(meta);
        this.metaPatch.attach(meta.datasetId);

        // FIX #4: rebuild custom buttons dopo il caricamento metadata
        this._rebuildVisibleCustomButtons();

        // la scheda Nuovo aperta prima dei metadati riceve qui i valori iniziali
        if (this.visible()) this._applicaValoriIniziali();

        Promise.resolve().then(() => {
          this._applyAllDeps();
          this.cdr.detectChanges();
        });
      },
      error: (err) => {
        this.error.set(`Errore metadati form per "${this.dataset()}": ${err.message ?? err}`);
        this.loading.set(false);
      },
    });
  }

  private _applyAllDeps(): void {
    this.depEngine.applyAll(this.formData(), this.form?.instance);
  }

  // Valori iniziali della scheda Nuovo: editorOptions.value dei metadati
  // (BASE_WEB_DATASETS_FIELDS.EDITOR_OPTIONS, per esempio {"value": true} per
  // la spunta Attivo, che nel database vale TRUE se non la si manda). Senza,
  // la casella partiva vuota e sembrava che la voce nascesse non attiva. Si
  // riempiono solo i campi ancora assenti: quello che l'operatore ha gia'
  // scritto resta.
  private _applicaValoriIniziali(): void {
    const meta = this.metadata();
    if (!meta || this.mode() !== 'insert') return;
    const iniziali: Record<string, any> = {};
    for (const campo of meta.fields) {
      const valore = campo.control?.editorOptions?.['value'];
      if (valore !== undefined) iniziali[campo.dataField] = valore;
    }
    if (!Object.keys(iniziali).length) return;
    const correnti = this.formData();
    if (Object.keys(iniziali).every(chiave => correnti?.[chiave] !== undefined)) return;
    this.formData.set({ ...iniziali, ...(correnti ?? {}) });
  }

  private readonly _focusPostProcessor = (item: any, field?: FieldMetadata): void => {
    if (field) {
      this.focusTracker.asPostProcessor(item, field);
      // la classe con il nome del campo e' come il menu in loco riconosce il campo cliccato
      item.cssClass = [item.cssClass, PREFISSO_CLASSE_CAMPO + field.dataField].filter(Boolean).join(' ');
    }
  };

  // Rilegge i metadati del dataset e ricostruisce i campi tenendo i valori della scheda
  private _rileggiMetadati(): void {
    this.metadataSvc.getMetadata(this.dataset(), true).subscribe({
      next: (meta) => {
        this.metadata.set(meta);
        this._rebuildItems();
        this.depEngine.build(meta);
        Promise.resolve().then(() => {
          this._applyAllDeps();
          this.cdr.detectChanges();
        });
      },
    });
  }

  // Tasto destro su un campo: il menu dei comandi rapidi. L'ascoltatore sta in
  // fase di cattura sull'elemento della scheda e ferma l'evento, cosi' non si
  // apre il menu di design e il popup della scheda (fuori dal componente) e' coperto.
  private _agganciaMenuInLoco(): void {
    const elemento = this.form?.instance?.element() as HTMLElement | undefined;
    if (!this.inLoco || !elemento || elemento === this._elementoMenuInLoco) return;
    this._elementoMenuInLoco = elemento;
    elemento.addEventListener('contextmenu', (evento) => {
      if (this.inLoco?.apriMenuScheda(evento, this.dataset(), this.metadata() as any)) {
        evento.preventDefault();
        evento.stopPropagation();
      }
    }, true);
  }

  private _rebuildItems(): void {
    const meta = this.metadata();
    if (!meta) return;
    const result = this.itemsBuilder.build(meta, this.depEngine, this._focusPostProcessor);

    //*** POPUP Fix: forza i gruppi a incolonnarsi verticalmente e previene overflow form
    const colCount = meta.formSettings.colCount || 1;
    const fixColSpan = (items: any[], currentColCount: number) => {
      items.forEach(item => {
        if (item.itemType === 'group' && !item.colSpan) {
          item.colSpan = currentColCount;
        }
        if (item.colSpan && item.colSpan > currentColCount) {
          item.colSpan = currentColCount;
        }
        if (item.items) {
          fixColSpan(item.items, item.colCount || currentColCount);
        }
      });
    };
    fixColSpan(result.items, colCount);

    this.formItems = result.items;
    this.itemPaths = result.itemPaths;
  }

  private async _navigate(tab: 'dataset' | 'fields' | 'groups' | 'preview'): Promise<void> {
    if (this.metaPatch.hasPendingChanges) {
      await this.metaPatch.flushNow();
    }
    // subtab con i nomi delle schede di zz/meta-editor (campi, form, anteprima)
    const base = { tab: 'datasets', dataset: this.dataset() };
    const extras: Record<string, any> = {
      fields: { ...base, subtab: 'campi' },
      groups: { ...base, subtab: 'form' },
      preview: { ...base, subtab: 'anteprima' },
    };
    this.router.navigate(['/meta-editor'], { queryParams: extras[tab] ?? base });
  }

  private _syncMenuTarget(): void {
    const el = this._formBodyEl?.nativeElement ?? null;
    if (el && el !== this.designMenuTarget()) this.designMenuTarget.set(el);
  }

  private _patch(dataField: string, patcher: (ctrl: ControlConfig) => void): void {
    const field = this.metadata()?.fields.find(f => f.dataField === dataField);
    if (field?.control) patcher(field.control);
  }

  private _itemOption(dataField: string, option: string, value: any): void {
    const path = this.itemPaths.get(dataField) ?? dataField;
    this.form?.instance?.itemOption(path, option, value);
  }

  private _patchField(dataField: string, patcher: (field: any) => void): void {
    const field = this.metadata()?.fields.find(f => f.dataField === dataField);
    if (field) patcher(field);
  }

  private _incollaImpostazioni(): void {
    navigator.clipboard.readText().then(text => {
      try {
        const items: Array<{
          dataField: string;
          cardIndex?: number;
          cardVisible?: boolean;
          readOnly?: boolean;
          required?: boolean;
          lineBreak?: boolean;
        }> = JSON.parse(text);

        const meta = this.metadata();
        if (!meta?.fields) return;

        meta.fields.forEach(f => { f.control.cardIndex = 999; });
        items.forEach(item => {
          const field = meta.fields.find(f => f.dataField === item.dataField);
          if (!field) return;
          if (item.cardIndex !== undefined) field.control.cardIndex = item.cardIndex;
          if (item.cardVisible !== undefined) field.control.visible = item.cardVisible;
          if (item.readOnly !== undefined) field.control.readOnly = item.readOnly;
          if (item.required !== undefined) field.control.required = item.required;
          if (item.lineBreak !== undefined) field.control.lineBreak = item.lineBreak;
        });

        this.metadata.set({ ...meta });
        this._rebuildItems();
        notify('Impostazioni applicate', 'success', 2000);
      } catch {
        notify('Errore: contenuto clipboard non valido', 'error', 3000);
      }
    }).catch(() => {
      notify('Impossibile leggere il clipboard', 'error', 3000);
    });
  }

}
