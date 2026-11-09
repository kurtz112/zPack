/**
 * zz-data-grid.component.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Grid metadata-driven basata su DevExtreme dx-data-grid.
 *
 * FIX applicati:
 *  1. Pulsante "Nuovo" apriva anche la form di default di DevExtreme:
 *     - allowAdding è ora SEMPRE false nella config dxo-editing
 *     - onInitNewRow cancella l'evento E NON richiama openForm (evita doppio open)
 *     - onEditingStart cancella SEMPRE quando useFormForEdit=true
 *  2. Colonna button "Visualizza" lenta:
 *     - openForm ora non causa un re-render della grid
 *     - La zz-form embedded usa [deferRendering]="false" (già nel template)
 *     - Aggiunto preload dei metadata form nel _loadDataset per eliminare
 *       il delay alla prima apertura
 *  3. Context menu DevTools: aggiunto id unico con counter per evitare
 *     conflitti quando più grid sono nella stessa pagina
 *  4. formVisible gestito in modo più pulito con guard anti-doppio-set
 * ─────────────────────────────────────────────────────────────────────────────
 */

import {
  Component, ViewChild, NgZone, OnInit, OnChanges, SimpleChanges,
  inject, signal, computed, input, output, model, ChangeDetectorRef, effect, untracked
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

import { DxDataGridModule, DxDataGridComponent } from 'devextreme-angular/ui/data-grid';
import { DxFilterBuilderModule, DxFilterBuilderComponent } from 'devextreme-angular/ui/filter-builder';
import { DxPopupModule } from 'devextreme-angular/ui/popup';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxToolbarModule } from 'devextreme-angular/ui/toolbar';
import { DxContextMenuModule, DxContextMenuTypes } from 'devextreme-angular/ui/context-menu';

import { DxDataGridTypes } from 'devextreme-angular/ui/data-grid';
import { exportDataGrid as exportXlsx } from 'devextreme/common/export/excel';
import { exportDataGrid as exportPdf } from 'devextreme/pdf_exporter';
import { jsPDF } from 'jspdf';
import { Workbook } from 'exceljs';
import saveAs from 'file-saver';
import CustomStore from 'devextreme/data/custom_store';
import { firstValueFrom } from 'rxjs';
import notify from 'devextreme/ui/notify';
import { Field } from 'devextreme/ui/filter_builder';
import { GridsEditMode } from 'devextreme/common/grids';

import { MetadataService } from '@zng/core/services/metadata.service';
import { DatasetMetadata, FieldMetadata, LookupConfig } from '@zng/core/models/metadata.models';
import { UrlService } from '@zng/core/services/url.service';
import { UserCapabilitiesService } from '@zng/core/services/user-capabilities.service';
import { ActionButton, ActionButtonEvent } from '@zng/core/models/action-button.model';
import { RegolaColore, TonalitaColore } from '@zng/core/models/regola-colore.model';
import { MenuBuilder, MenuItem, IMenuItem } from '@zng/core/helper/menu-builder';
import { FORMATO_INTERO, agganciaCampoIntero, colonnaIntera } from '@zng/core/helper/campo-intero';
import { ZzFormComponent, ZzFormMode } from '../zz-form/zz-form.component';
import { ZServerService } from '@zng/core/services/zserver.service';
import { validationRulesOf } from '@zng/core/services/form-items-builder.service';
import {
  chiediConferma,
  erroreGiaMostrato,
  messaggioErrore,
  mostraAvviso,
} from '@zng/core/services/avviso';
import { ZzMetaInLocoService } from '@zng/zz/meta-editor/meta-in-loco.service';
// ─── Tipo clipboard per incollaImpostazioni ────────────────────────────────

interface IColumnFromClipboard {
  dataField: string;
  viewIndex: number;
  viewVisible: boolean;
}

// Counter globale per ID univoci
let _gridInstanceCounter = 0;

// Toni leggibili su tema chiaro e scuro; l'applicazione puo' ridefinirli con le variabili CSS.
const COLORI_TONALITA: Record<TonalitaColore, string> = {
  positivo: 'var(--zz-colore-positivo, #2e9d4f)',
  attenzione: 'var(--zz-colore-attenzione, #e0a100)',
  negativo: 'var(--zz-colore-negativo, #d93a3a)',
  neutro: 'var(--zz-colore-neutro, #8a8f98)'
};

// Data prima di oggi e importo aperto maggiore di zero nella stessa riga.
function scadutaENonPagata(cella: any, campiSaldo: string | string[]): boolean {
  const data = cella.value instanceof Date ? cella.value : new Date(String(cella.value ?? ''));
  const oggi = new Date();
  oggi.setHours(0, 0, 0, 0);
  if (isNaN(data.getTime()) || data >= oggi) return false;
  const campi = Array.isArray(campiSaldo) ? campiSaldo : [campiSaldo];
  const campo = campi.find(nome => cella.data && nome in cella.data);
  return campo !== undefined && Number(cella.data[campo]) > 0;
}

// Cella colorata secondo una regola. Stili in linea perche' la cella nasce fuori dalla vista
// Angular e non riceve gli stili del componente; il testo e' quello formattato dalla griglia.
function cellaColorata(regola: RegolaColore) {
  return (contenitore: HTMLElement, cella: any) => {
    const testo = cella.text ?? (cella.value == null ? '' : String(cella.value));
    let tonalita: TonalitaColore | undefined;
    if (regola.tipo === 'scaduto') {
      if (scadutaENonPagata(cella, regola.saldo)) tonalita = 'negativo';
    } else if (regola.tipo === 'segno') {
      const numero = Number(cella.value);
      if (cella.value != null && cella.value !== '' && !isNaN(numero) && numero !== 0) {
        const negativo = regola.invertito ? numero > 0 : numero < 0;
        tonalita = negativo ? 'negativo' : 'positivo';
      }
    } else {
      const chiave = String(cella.value ?? '').trim().toUpperCase();
      tonalita = regola.mappa[chiave] ?? regola.altri;
    }
    if (!tonalita) {
      contenitore.textContent = testo;
      return;
    }
    const colore = COLORI_TONALITA[tonalita];
    const etichetta = document.createElement('span');
    etichetta.textContent = testo;
    if (regola.tipo === 'mappa' && regola.cerchio) {
      const cerchio = document.createElement('span');
      cerchio.style.cssText = 'display:inline-block; width:10px; height:10px; margin-right:6px;'
        + ' vertical-align:middle; border-radius:50%;';
      cerchio.style.backgroundColor = colore;
      contenitore.append(cerchio, etichetta);
    } else {
      etichetta.style.color = colore;
      etichetta.style.fontWeight = '600';
      if (regola.tipo === 'scaduto') etichetta.title = 'Scaduta e non pagata';
      contenitore.append(etichetta);
    }
  };
}

// ─────────────────────────────────────────────────────────────────────────────

@Component({
  selector: 'zz-data-grid',
  standalone: true,
  imports: [
    CommonModule,
    DxDataGridModule,
    DxFilterBuilderModule,
    DxPopupModule,
    DxButtonModule,
    DxToolbarModule,
    DxContextMenuModule,
    ZzFormComponent,
  ],
  templateUrl: './zz-data-grid.component.html',
  styleUrl: './zz-data-grid.component.scss',
})
export class ZzDataGridComponent implements OnInit, OnChanges {

  // ─── VIEW CHILDREN ────────────────────────────────────────────────────────

  @ViewChild('grid') grid!: DxDataGridComponent;
  @ViewChild('filterBuilder') filterBuilderRef!: DxFilterBuilderComponent;
  @ViewChild('embeddedForm') embeddedForm?: ZzFormComponent;

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT — signal-based (Angular 17+)
  // ═══════════════════════════════════════════════════════════════════════════

  readonly dataset = input.required<string>();
  readonly height = input<string | number>(500);

  readonly modal = input(false);
  readonly visible = model(false);
  readonly popupTitle = input<string | undefined>(undefined);
  readonly popupWidth = input<number | string>('90vw');
  readonly popupHeight = input<number | string>('85vh');

  readonly forceFormForEdit = input<boolean | undefined>(undefined);
  readonly dblClickMode = input<'edit' | 'view'>('edit');
  readonly allowView = input<boolean | undefined>(undefined);
  // Griglia di dettaglio: senza casella di ricerca, riga dei filtri e pulsanti nella
  // barra (filtri, esportazione, colonne). Le voci restano nel menu del tasto destro.
  readonly compatta = input(false);
  readonly enableGridLookups = input(false);
  readonly showDevToolsOverride = input<boolean | undefined>(undefined, { alias: 'showDevTools' });
  readonly customButtons = input<ActionButton[]>([]);
  readonly downloadFileField = input<string>('');
  // Colore per colonna (chiave = campo del dataset): per segno o secondo il valore.
  readonly regoleColore = input<Record<string, RegolaColore>>({});
  // Griglia senza righe: testo e icona (nome di un'icona di DevExtreme) scelti dalla pagina.
  // Con filtri o ricerca attivi compare invece "Nessun risultato" col pulsante per toglierli.
  readonly testoVuoto = input<string | undefined>(undefined);
  readonly iconaVuota = input<string | undefined>(undefined);

  // ═══════════════════════════════════════════════════════════════════════════
  // OUTPUT
  // ═══════════════════════════════════════════════════════════════════════════
  readonly beforeLoad = output<{ dataset: string; extraParams: Record<string, any> }>();
  readonly rowClicked = output<DxDataGridTypes.RowClickEvent>();
  readonly rowDblClicked = output<DxDataGridTypes.RowDblClickEvent>();
  readonly selectionChanged = output<DxDataGridTypes.SelectionChangedEvent>();
  readonly focusedRowChanged = output<Record<string, any>>();
  readonly rowInserted = output<{ mode: ZzFormMode; data: Record<string, any> }>();
  readonly rowUpdated = output<{ mode: ZzFormMode; data: Record<string, any> }>();
  readonly rowRemoved = output<any>();
  readonly metadataLoaded = output<DatasetMetadata>();
  readonly actionButtonClick = output<ActionButtonEvent>();
  // Righe mostrate a ogni contenuto pronto (primo caricamento, filtri, ricerca, ordinamento,
  // pagina, rilettura): la pagina puo' verificare che la riga scelta sia ancora fra queste.
  // chiave = campo della chiave primaria del dataset (vuoto finche' i metadati non ci sono).
  readonly righeMostrate = output<{ chiave: string; righe: Record<string, unknown>[] }>();
  readonly downloadFile = output<any>();

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVIZI
  // ═══════════════════════════════════════════════════════════════════════════

  private metadataSvc = inject(MetadataService);
  private http = inject(HttpClient);
  private urlService = inject(UrlService);
  private router = inject(Router);
  private zone = inject(NgZone);
  private cdr = inject(ChangeDetectorRef);
  private capabilities = inject(UserCapabilitiesService);
  // Editor dei metadati in loco (tasto destro): senza il servizio il menu resta quello normale
  private inLoco = inject(ZzMetaInLocoService, { optional: true });
  private _ultimaModificaLetta = 0;

  constructor() {
    // Dopo un comando in loco i metadati del dataset sono cambiati: la griglia li
    // rilegge senza ricaricare la pagina
    effect(() => {
      const cambiato = this.inLoco?.cambiato();
      // il resto si legge senza tracciarlo: reload() cambia i metadati e rilancerebbe l'effetto
      untracked(() => {
        if (!cambiato || cambiato.volta === this._ultimaModificaLetta) return;
        this._ultimaModificaLetta = cambiato.volta;
        if (cambiato.dataset === this.dataset() && this.metadata()) this.reload();
      });
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATO
  // ═══════════════════════════════════════════════════════════════════════════
  private readonly zserver = inject(ZServerService);
  readonly metadata = signal<DatasetMetadata | null>(null);
  readonly loading = signal(false);
  readonly error = signal('');

  // Griglia vuota: righe a zero a caricamento finito. `vuotaConFiltri` distingue il caso in
  // cui le righe ci sono ma filtri o ricerca le nascondono.
  readonly vuota = signal(false);
  readonly vuotaConFiltri = signal(false);
  readonly vuotaSopra = signal(0);

  dataStore: CustomStore | null = null;
  gridColumns: any[] = [];

  focusedRowData: Record<string, any> = {};
  private _focusedColumnField?: string;

  filterVisible = false;
  filterFields: Field[] = [];
  private _filterSyncLock = false;

  selectedRowKeys: any[] = [];

  contextMenuItems: MenuItem[] = [];
  devToolsMenuItems: MenuItem[] = [];

  formVisible = false;
  formMode: ZzFormMode = 'edit';
  formData: Record<string, any> = {};

  readonly remoteOps = { filtering: true, sorting: true, paging: true, grouping: false, summary: false };

  /**
   * FIX #3: ID univoci per i bottoni DevTools, evita conflitti DOM
   */
  readonly gridDevBtnId = `gridDevBtn_${++_gridInstanceCounter}`;

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPUTED GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  readonly showDevTools = computed(() => {
    const override = this.showDevToolsOverride();
    return override !== undefined ? override : this.capabilities.canDevTools();
  });

  get gridTitle(): string {
    return this.popupTitle() ?? this.metadata()?.caption ?? this.dataset();
  }

  get gridPopupWidth(): number | string { return this.popupWidth(); }
  get gridPopupHeight(): number | string { return this.popupHeight(); }

  get useFormForEdit(): boolean {
    const forced = this.forceFormForEdit();
    if (forced !== undefined) return forced;
    return this.metadata()?.gridSettings?.editing?.useFormForEdit ?? true;
  }

  get allowAdding(): boolean { return this.metadata()?.gridSettings?.editing?.allowAdding ?? false; }
  get allowUpdating(): boolean { return this.metadata()?.gridSettings?.editing?.allowUpdating ?? false; }
  get allowDeleting(): boolean { return this.metadata()?.gridSettings?.editing?.allowDeleting ?? false; }

  get _allowView(): boolean {
    const override = this.allowView();
    return override !== undefined ? override : (this.metadata()?.gridSettings?.editing?.allowView ?? true);
  }

  get hasSelection(): boolean { return this.selectedRowKeys.length > 0; }
  get selectionCount(): number { return this.selectedRowKeys.length; }

  get editingMode(): GridsEditMode {
    return this.metadata()?.gridSettings?.editing?.mode ?? 'popup';
  }

  visibleGridButtons: ActionButton[] = [];
  formPassthroughButtons: ActionButton[] = [];
  hasFocusedRow = false;

  private _rebuildCustomButtons(): void {
    this.visibleGridButtons = this.customButtons().filter(b => {
      if (b.visible === false) return false;
      const target = b.target ?? 'both';
      return target === 'grid' || target === 'both';
    });

    this.formPassthroughButtons = this.customButtons().filter(b => {
      const target = b.target ?? 'both';
      if (target !== 'form' && target !== 'both') return false;
      return b.passToForm !== false;
    });
  }

  // ── Custom button handlers ─────────────────────────────────────────────────

  onGridCustomButtonClick(button: ActionButton): void {
    this.actionButtonClick.emit({
      button,
      data: { ...this.focusedRowData },
      source: 'grid',
    });
  }

  onFormActionButtonClick(event: ActionButtonEvent): void {
    this.actionButtonClick.emit(event);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  ngOnInit(): void {
    if (!this.modal() || this.visible()) {
      this._loadDataset();
    }
    this._buildDevToolsMenu();
    this._rebuildCustomButtons();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['dataset'] && !changes['dataset'].firstChange) {
      this._loadDataset();
    }
    if (changes['customButtons']) {
      this._rebuildCustomButtons();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════

  refresh(): void { this.grid?.instance?.refresh(); }

  reload(): void {
    this.metadataSvc.invalidateCache(this.dataset());
    this._loadDataset();
  }

  get instance() { return this.grid?.instance; }

  open(): void {
    this.visible.set(true);
    if (!this.metadata()) this._loadDataset();
  }

  close(): void { this.visible.set(false); }

  getFocusedRowData(): Record<string, any> { return this.focusedRowData; }
  getSelectedRowsData(): any[] { return this.grid?.instance?.getSelectedRowsData() ?? []; }

  setFilter(dataField: string, operator: string, value: any): void {
    this.grid?.instance?.columnOption(dataField, 'selectedFilterOperation', operator);
    this.grid?.instance?.columnOption(dataField, 'filterValue', value);
    if (this.filterBuilderRef?.instance) {
      this.filterBuilderRef.instance.option('value', this.grid.filterValue);
      const expr = this.filterBuilderRef.instance.getFilterExpression();
      this.filterVisible = !!expr;
    }
  }

  clearFilter(dataField?: string): void {
    dataField ? this.setFilter(dataField, '=', null) : this.grid?.instance?.clearFilter();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GRID POPUP EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  onGridPopupHiding(): void { this.visible.set(false); }

  onGridPopupShown(): void {
    if (!this.metadata()) this._loadDataset();
    setTimeout(() => this.grid?.instance?.updateDimensions());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROW EVENTS
  // ═══════════════════════════════════════════════════════════════════════════

  handleRowClick(e: DxDataGridTypes.RowClickEvent): void {
    this.rowClicked.emit(e);
  }

  handleRowDblClick(e: DxDataGridTypes.RowDblClickEvent): void {
    window.getSelection()?.empty?.();
    this.rowDblClicked.emit(e);
    if (e.data) {
      e.event?.stopImmediatePropagation();
      this.openForm(this.dblClickMode(), e.data);
    }
  }

  onGridFocusedRowChanged(e: DxDataGridTypes.FocusedRowChangedEvent): void {
    this.focusedRowData = e.row?.data ?? {};
    this.hasFocusedRow = !!e.row?.data;
    this.focusedRowChanged.emit(this.focusedRowData);
    this._buildContextMenu();
  }

  onGridFocusedCellChanged(e: DxDataGridTypes.FocusedCellChangedEvent): void {
    this._focusedColumnField = (e.column as any)?.dataField;
  }

  handleSelectionChanged(e: DxDataGridTypes.SelectionChangedEvent): void {
    this.selectedRowKeys = this.grid?.instance?.getSelectedRowKeys() ?? [];
    this.selectionChanged.emit(e);
    this._buildContextMenu();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KEYBOARD NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  onKeyDown(e: DxDataGridTypes.KeyDownEvent): void {
    if (!e.event) return;
    if (e.event.key === 'Enter') {
      e.handled = true;
      this._modifica();
    } else if (e.event.key === 'F3') {
      e.handled = true;
      e.event.preventDefault();
      e.event.stopPropagation();
      this._filtraPerValore();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INSERT — FIX #1
  // ═══════════════════════════════════════════════════════════════════════════

  /**
   * FIX #1: Pulsante custom "Nuovo" nella toolbar.
   * Apre SOLO la zz-form, NON chiama mai grid.addRow().
   * Questo evita che DevExtreme apra anche il suo editing form.
   */
  readonly onInsertClick = (): void => {
    // Apri sempre la zz-form — non delegare MAI a grid.addRow()
    this.openForm('insert', {});
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // ROW BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  readonly onEditRowClick = (e: any): void => {
    if (this.useFormForEdit) {
      this.openForm('edit', e.row.data);
    } else {
      this.grid?.instance?.editRow(e.row.rowIndex);
    }
  };

  readonly onViewRowClick = (e: any): void => { this.openForm('view', e.row.data); };
  readonly onDeleteRowClick = async (e: any): Promise<void> => { await this._deleteRows([e.row.data]); };

  // ═══════════════════════════════════════════════════════════════════════════
  // BATCH DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  async deleteSelected(): Promise<void> {
    const rows = this.getSelectedRowsData();
    if (!rows.length) return;
    await this._deleteRows(rows, true);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FORM DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  /**
   * Apre la form embedded.
   *
   * FIX: DevExtreme chiama i callback dei column-buttons fuori dalla zona
   * Angular. Anche wrappando con zone.run(), il binding [visible]="formVisible"
   * (plain boolean → signal model) non viene propagato in tempo al child.
   *
   * Soluzione: usiamo il metodo open() della zz-form via ViewChild, che
   * setta internamente mode, formData e visible come signal.
   * In più forziamo detectChanges() per garantire che Angular propaghi
   * tutto subito, senza aspettare il prossimo tick.
   */
  openForm(mode: ZzFormMode, data: Record<string, any> = {}): void {
    this.formMode = mode;
    this.formData = mode === 'insert' ? {} : { ...data };
    this.formVisible = true;

    // Se il ViewChild è disponibile, usa il metodo imperativo open()
    // che setta i signal internamente — più affidabile del binding
    if (this.embeddedForm) {
      this.embeddedForm.open(mode, mode === 'insert' ? undefined : data);
    }

    // Forza Angular a propagare il cambio ADESSO
    this.cdr.detectChanges();
  }

  onFormSaved(event: { mode: ZzFormMode; data: Record<string, any> }): void {
    this.formVisible = false;
    this.grid?.instance?.refresh();
    if (event.mode === 'insert') this.rowInserted.emit(event);
    else if (event.mode === 'edit') this.rowUpdated.emit(event);
  }

  onFormCancelled(): void {
    this.formVisible = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EDITING NATIVO — FIX #1
  // ═══════════════════════════════════════════════════════════════════════════

  /**
   * FIX #1: Intercetta SEMPRE l'initNewRow nativo di DevExtreme.
   * Cancella l'evento senza aprire la form (che viene aperta solo dal
   * pulsante custom "Nuovo" via onInsertClick).
   * Prima: e.cancel = true + openForm('insert') → doppia apertura.
   * Ora: solo e.cancel = true.
   */
  onInitNewRow(e: any): void {
    e.cancel = true;
    // NON chiamare openForm qui — viene già gestito da onInsertClick
  }

  /**
   * FIX #1: Intercetta SEMPRE l'editing start nativo.
   * Quando useFormForEdit=true, blocca l'editing DevExtreme.
   * Quando useFormForEdit=false, lascia passare l'editing nativo.
   */
  onEditingStart(e: any): void {
    if (this.useFormForEdit) {
      e.cancel = true;
      // NON aprire la form qui — viene aperta da dblClick/Enter/bottone riga
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  onFilterBuilderOptionChanged(e: any): void {
    if (this._filterSyncLock) return;
    if (this.filterVisible) this.grid!.filterValue = this.filterBuilderRef?.value;
  }

  onGridOptionChanged(e: DxDataGridTypes.OptionChangedEvent): void {
    if (e.name === 'filterValue') {
      this._filterSyncLock = true;
      this.filterBuilderRef?.instance?.option('value', this.grid?.filterValue);
      if (!this.grid?.filterValue) this.filterVisible = false;
      this._filterSyncLock = false;
    }
  }

  toggleFilterPanel(): void { this.filterVisible = !this.filterVisible; }

  // A contenuto pronto (anche dopo filtri, ricerca, ordinamento) decide se mostrare il
  // riquadro "nessun dato". Il riquadro sta sotto l'intestazione, che puo' avere altezza diversa.
  onGridContentReady(e: any): void {
    const istanza = e.component;
    const caricamento = istanza.getDataSource()?.isLoading?.() ?? false;
    const senzaRighe = !caricamento && istanza.getVisibleRows().length === 0;
    const righe = istanza.element().querySelector('.dx-datagrid-rowsview') as HTMLElement | null;
    this.vuotaSopra.set(righe?.offsetTop ?? 0);
    this.vuotaConFiltri.set(senzaRighe && this._filtriAttivi(istanza));
    this.vuota.set(senzaRighe);
    if (!caricamento) {
      const righeDati = (istanza.getVisibleRows() as { rowType: string; data: Record<string, unknown> }[])
        .filter((riga) => riga.rowType === 'data')
        .map((riga) => riga.data);
      this.righeMostrate.emit({ chiave: this.metadata()?.primaryKey ?? '', righe: righeDati });
    }
  }

  togliFiltri(): void {
    const istanza = this.grid?.instance;
    if (!istanza) return;
    istanza.clearFilter();
    istanza.option('searchPanel.text', '');
  }

  private _filtriAttivi(istanza: any): boolean {
    return !!istanza.getCombinedFilter() || !!istanza.option('searchPanel.text');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTEXT MENU
  // ═══════════════════════════════════════════════════════════════════════════

  onContextMenuPreparing(e: DxDataGridTypes.ContextMenuPreparingEvent): void {
    this._buildContextMenu();
    // copia: le voci in loco si aggiungono in coda a ogni apertura del menu
    e.items = [...this.contextMenuItems] as any[];
    this.inLoco?.vociGriglia(e, this.dataset(), this.metadata() as any);
  }

  onContextMenuItemClick(e: DxContextMenuTypes.ItemClickEvent): void {
    const item = e.itemData as IMenuItem;
    if (item?.onItemClick) item.onItemClick(e);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEV TOOLS
  // ═══════════════════════════════════════════════════════════════════════════

  onDevToolsItemClick(e: DxContextMenuTypes.ItemClickEvent): void {
    const item = e.itemData as IMenuItem;
    if (item?.onItemClick) item.onItemClick(e);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPORT
  // ═══════════════════════════════════════════════════════════════════════════

  exportExcel(): void {
    const filename = (this.metadata()?.caption ?? this.dataset()) + '.xlsx';
    const wb = new Workbook();
    exportXlsx({ component: this.grid.instance, worksheet: wb.addWorksheet('Foglio 1') })
      .then(() => wb.xlsx.writeBuffer())
      .then(buf => saveAs(new Blob([buf], { type: 'application/octet-stream' }), filename));
  }

  exportCSV(): void {
    const filename = (this.metadata()?.caption ?? this.dataset()) + '.csv';
    const wb = new Workbook();
    exportXlsx({ component: this.grid.instance, worksheet: wb.addWorksheet('Foglio 1'), encodeExecutableContent: true })
      .then(() => wb.csv.writeBuffer())
      .then(buf => saveAs(new Blob([buf], { type: 'application/octet-stream' }), filename));
  }

  exportPDF(): void {
    const filename = (this.metadata()?.caption ?? this.dataset()) + '.pdf';
    const doc = new jsPDF();
    exportPdf({ jsPDFDocument: doc, component: this.grid.instance, indent: 5 })
      .then(() => doc.save(filename));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INCOLLA IMPOSTAZIONI COLONNE
  // ═══════════════════════════════════════════════════════════════════════════

  incollaImpostazioni(): void {
    navigator.clipboard.readText().then(text => {
      try {
        const cols: IColumnFromClipboard[] = JSON.parse(text);
        const meta = this.metadata();
        if (!meta?.fields) return;
        cols.forEach(c => {
          const field = meta.fields.find(f => f.dataField === c.dataField);
          if (field) {
            field.column.sortOrder = c.viewIndex;
            field.column.visible = c.viewVisible;
          }
        });
        this.gridColumns = this._buildColumns(meta);
        notify('Impostazioni colonne applicate', 'success', 2000);
      } catch {
        notify('Errore: clipboard non valido', 'error', 3000);
      }
    }).catch(() => notify('Impossibile leggere il clipboard', 'error', 3000));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE
  // ═══════════════════════════════════════════════════════════════════════════

  private _loadDataset(): void {
    this.loading.set(true);
    this.error.set('');
    this.metadata.set(null);
    this.dataStore = null;
    this.gridColumns = [];
    this.filterFields = [];
    this.selectedRowKeys = [];
    this.focusedRowData = {};

    this.metadataSvc.getMetadata(this.dataset()).subscribe({
      next: (meta) => {
        this.metadata.set(meta);

        const params: Record<string, any> = {};
        this.beforeLoad.emit({ dataset: this.dataset(), extraParams: params });

        this.dataStore = this.zserver.createDataStore(meta.datasetId, meta.primaryKey, params);

        this.gridColumns = this._buildColumns(meta);
        this.filterFields = this._buildFilterFields(meta);
        this._buildContextMenu();
        this.loading.set(false);
        this.metadataLoaded.emit(meta);
      },
      error: (err) => {
        this.error.set(`Errore metadati "${this.dataset()}": ${err.message ?? err}`);
        this.loading.set(false);
      },
    });
  }

  // ── Colonne ────────────────────────────────────────────────────────────────

  // private _buildColumns(meta: DatasetMetadata): any[] {
  //   const fields = [...meta.fields]
  //     .filter(f => (f.column.visible !== false) || f.isPrimaryKey)
  //     .sort((a, b) => (a.column.sortOrder ?? 0) - (b.column.sortOrder ?? 0));

  //   const cols: any[] = fields.map(f => {
  //     const col: any = {
  //       dataField:      f.dataField,
  //       caption:        f.caption,
  //       dataType:       f.dataType,
  //       visible:        f.isPrimaryKey ? false : (f.column.visible ?? true),
  //       alignment:      f.column.alignment,
  //       allowEditing:   f.column.allowEditing,
  //       allowFiltering: f.column.allowFiltering,
  //       allowSorting:   f.column.allowSorting,
  //     };

  //     if (f.isPrimaryKey)            { col.allowEditing = false; col.formItem = { visible: false }; }
  //     if (f.column.minWidth)           col.minWidth    = f.column.minWidth;
  //     if (f.column.format)             col.format      = f.column.format;
  //     if (f.column.groupIndex != null) col.groupIndex  = f.column.groupIndex;
  //     if (f.column.fixed) {
  //       col.fixed = true;
  //       col.fixedPosition = f.column.fixedPosition ?? 'left';
  //     }

  //     if (f.lookup && this.enableGridLookups()) {
  //       col.lookup = this._buildGridLookup(f);
  //     }
  //     if (f.picklist && !f.lookup) {
  //       col.lookup = { dataSource: f.picklist.items, valueExpr: 'value', displayExpr: 'text' };
  //     }
  //     if (f.control.validation?.length) {
  //       col.validationRules = f.control.validation.map(v => {
  //         const r: any = { type: v.type };
  //         if (v.message) r.message = v.message;
  //         if (v.pattern) r.pattern = v.pattern;
  //         if (v.min !== undefined) r.min = v.min;
  //         if (v.max !== undefined) r.max = v.max;
  //         return r;
  //       });
  //     }
  //     return col;
  //   });

  //   // Colonna azioni (type: buttons)
  //   // FIX: tutti gli onClick wrappati in zone.run() perché DevExtreme
  //   // chiama i callback fuori dalla zona Angular → formVisible cambia
  //   // ma Angular non rileva il cambio finché un altro evento non forza CD.
  //   const buttons: any[] = [];
  //   if (this._allowView) {
  //     buttons.push({ icon: 'eyeopen', hint: 'Visualizza', onClick: (e: any) => this.zone.run(() => this.onViewRowClick(e)) });
  //   }
  //   if (this.allowUpdating && this.useFormForEdit) {
  //     buttons.push({ icon: 'edit', hint: 'Modifica', onClick: (e: any) => this.zone.run(() => this.onEditRowClick(e)) });
  //   }
  //   if (this.allowDeleting && this.useFormForEdit) {
  //     buttons.push({ icon: 'trash', hint: 'Elimina', cssClass: 'btn-danger', onClick: (e: any) => this.zone.run(() => this.onDeleteRowClick(e)) });
  //   }
  //   if (buttons.length) {
  //     cols.push({
  //       type: 'buttons', caption: '',
  //       width: Math.max(buttons.length * 36 + 16, 60),
  //       fixed: true, fixedPosition: 'right',
  //       buttons,
  //     });
  //   }

  //   return cols;
  // }

  private _buildColumns(meta: DatasetMetadata): any[] {
    const fields = [...meta.fields]
      .filter(f => (f.column.visible !== false) || f.isPrimaryKey)
      .sort((a, b) => (a.column.sortOrder ?? 0) - (b.column.sortOrder ?? 0));

    const cols: any[] = fields.map(f => {
      const ctrl = f.control;
      const col: any = {
        dataField: f.dataField,
        caption: f.caption,
        dataType: f.dataType,
        visible: f.isPrimaryKey ? false : (f.column.visible ?? true),
        alignment: f.column.alignment,
        allowEditing: f.column.allowEditing,
        allowFiltering: f.column.allowFiltering,
        allowSorting: f.column.allowSorting,
        // Inizializziamo editorOptions per mantenere la coerenza con il form
        editorOptions: { ...(ctrl.editorOptions ?? {}) }
      };

      // ─── GESTIONE FORMATI E EDITOR (Allineato a FormItemsBuilder) ───

      // 1. Gestione Date, DateTime e Time
      if (f.dataType === 'datetime') {
        col.format = 'dd/MM/yyyy HH:mm';
        col.editorOptions.type = 'datetime';
      } else if (f.dataType === 'time') {
        col.format = 'HH:mm';
        col.editorOptions.type = 'time';
        col.editorOptions.pickerType = 'list';
      } else if (f.dataType === 'date') {
        col.format = 'dd/MM/yyyy';
        col.editorOptions.type = 'date';
      }

      // 2. Gestione Numeri e Decimali
      if (f.dataType === 'number' && f.column.fieldDecimals) {
        const precision = f.column.fieldDecimals;
        const formatStr = '#,##0.' + '0'.repeat(precision);
        col.format = formatStr;
        col.editorOptions.format = formatStr;
        col.editorOptions.precision = precision;
      }

      // Colonna intera: l'editor non accetta virgola ne' punto (ZNG-SCH-016)
      if (f.dataType === 'number' && colonnaIntera(f.column.fieldType, f.column.fieldDecimals)) {
        col.format = col.format ?? FORMATO_INTERO;
        col.editorOptions.format = FORMATO_INTERO;
        const inizialeDeiMetadati = col.editorOptions.onInitialized;
        col.editorOptions.onInitialized = (e: any) => {
          agganciaCampoIntero(e.element, e.component);
          if (typeof inizialeDeiMetadati === 'function') inizialeDeiMetadati(e);
        };
      }

      // ─── CONFIGURAZIONI COLONNA ESISTENTI ───

      if (f.isPrimaryKey) {
        col.allowEditing = false;
        col.formItem = { visible: false };
      }

      if (f.column.minWidth) col.minWidth = f.column.minWidth;

      // Sovrascrive il formato automatico se specificato esplicitamente nei metadati
      if (f.column.format) col.format = f.column.format;

      if (f.column.groupIndex != null) col.groupIndex = f.column.groupIndex;

      if (f.column.fixed) {
        col.fixed = true;
        col.fixedPosition = f.column.fixedPosition ?? 'left';
      }

      // 3. Lookup e Picklist
      // In griglia si decodifica solo il collegamento a chiave semplice sul
      // campo stesso: con una chiave composta (SETTORE; CATEGORIA_SERVIZIO;
      // CODICE_SERVIZIO) il lookup cercherebbe ogni colonna sul primo campo
      // della chiave e mostrerebbe descrizioni sbagliate; resta il codice.
      if (f.lookup && this.enableGridLookups() && this._lookupSemplice(f)) {
        col.lookup = this._buildGridLookup(f);
      } else if (f.picklist) {
        col.lookup = {
          dataSource: f.picklist.items,
          valueExpr: 'value',
          displayExpr: 'text'
        };
        // Allineamento editorOptions per picklist
        col.editorOptions.dataSource = f.picklist.items;
        col.editorOptions.valueExpr = 'value';
        col.editorOptions.displayExpr = 'text';
      }

      // Colore: campione accanto al codice esadecimale, come nella scheda.
      // Stili in linea perche' la cella nasce fuori dalla vista Angular e
      // non riceve gli stili del componente.
      if (ctrl.editorType === 'dxColorBox') {
        col.cellTemplate = (contenitore: HTMLElement, cella: any) => {
          const valore = cella.value;
          if (!valore) return;
          const campione = document.createElement('span');
          campione.style.cssText = 'display:inline-block; width:14px; height:14px; margin-right:6px;'
            + ' vertical-align:middle; border-radius:3px; border:1px solid rgba(128,128,128,.5);';
          campione.style.backgroundColor = String(valore);
          contenitore.append(campione, document.createTextNode(String(valore)));
        };
      }

      // Regola di colore dichiarata dalla pagina (non sul campione dei colori)
      const regolaColore = this.regoleColore()[f.dataField];
      if (regolaColore && ctrl.editorType !== 'dxColorBox') {
        col.cellTemplate = cellaColorata(regolaColore);
      }

      // 4. Validazione
      // (mai 'required' sui booleani: validationRulesOf)
      const rules = validationRulesOf(f);
      if (rules.length) {
        col.validationRules = rules.map(v => ({
          type: v.type,
          message: v.message,
          pattern: v.pattern,
          min: v.min,
          max: v.max
        }));
      }

      return col;
    });

    const buttons: any[] = [];
    // ─── COLONNA Download (TYPE: BUTTONS) ───
    if (this.downloadFileField() != '') {
      buttons.push({
        icon: 'download', // o l'icona che preferisci
        hint: 'Scarica file',
        visible: (e: any) => {
          // Attiva solo se il campo file ha un valore
          if (!e.row || e.row.rowType !== 'data') return false;
          const val = e.row.data[this.downloadFileField()];
          return val !== null && val !== undefined && val !== '' && val !== 0;
        },
        disabled: false,
        onClick: (e: any) => {
          e.event?.stopPropagation();
          this.downloadFile.emit(e.row.data);
        }
      });
    }
    // ─── COLONNA AZIONI (TYPE: BUTTONS) ───

    if (this._allowView) {
      buttons.push({ icon: 'eyeopen', hint: 'Visualizza', onClick: (e: any) => this.zone.run(() => this.onViewRowClick(e)) });
    }
    if (this.allowUpdating && this.useFormForEdit) {
      buttons.push({ icon: 'edit', hint: 'Modifica', onClick: (e: any) => this.zone.run(() => this.onEditRowClick(e)) });
    }
    if (this.allowDeleting && this.useFormForEdit) {
      buttons.push({ icon: 'trash', hint: 'Elimina', cssClass: 'btn-danger', onClick: (e: any) => this.zone.run(() => this.onDeleteRowClick(e)) });
    }

    if (buttons.length) {
      cols.push({
        type: 'buttons',
        caption: '',
        width: Math.max(buttons.length * 36 + 16, 60),
        fixed: true,
        fixedPosition: 'right',
        buttons,
      });
    }

    return cols;
  }

  // ── Grid lookup ─────────────────────────────────────────────────────────

  private _lookupSemplice(field: FieldMetadata): boolean {
    const chiave = (field.lookup?.valueExpr ?? '').split(';').map(s => s.trim()).filter(Boolean);
    return chiave.length === 1 && chiave[0] === field.dataField;
  }

  private _buildGridLookup(field: FieldMetadata): any {
    const lk = field.lookup!;

    const veFields = (lk.valueExpr ?? '').split(';').map(s => s.trim()).filter(Boolean);
    const deFields = (lk.displayExpr ?? '').split(';').map(s => s.trim()).filter(Boolean);

    const valueField = veFields[0];
    const displayField = deFields[0] ?? valueField;
    const baseUrl = `${this.urlService.baseUrl}/data/${lk.dataset}`;
    const pageSize = lk.pageSize ?? 0;
    const paginated = pageSize > 0;

    const http = this.http;

    const storeConfig: any = {
      key: valueField,

      // zServer non ha GET {dataset}/{chiave}: si filtra sulla chiave
      byKey: (key: any) => firstValueFrom(
        http.get<any>(baseUrl, { params: { filter: JSON.stringify([valueField, '=', key]), take: '1' } })
      ).then(result => (Array.isArray(result) ? result : result?.data ?? [])[0] ?? null)
        .catch(() => null),
    };

    if (paginated) {
      storeConfig.load = (loadOpts: any) => {
        const params: Record<string, any> = {
          skip: loadOpts.skip ?? 0,
          take: loadOpts.take ?? pageSize,
          requireTotalCount: true,
        };
        if (loadOpts.filter) params['filter'] = JSON.stringify(loadOpts.filter);
        if (loadOpts.sort) params['sort'] = JSON.stringify(loadOpts.sort);
        if (loadOpts.searchValue && loadOpts.searchExpr) {
          params['filter'] = JSON.stringify([loadOpts.searchExpr, 'contains', loadOpts.searchValue]);
        }
        return firstValueFrom(
          http.get<any>(baseUrl, { params })
        ).then(result => {
          if (Array.isArray(result)) return result;
          return { data: result.data ?? result, totalCount: result.totalCount };
        });
      };
    } else {
      storeConfig.loadMode = 'raw';
      storeConfig.load = () => firstValueFrom(
        http.get<any>(baseUrl, { params: { take: '0' } })
      ).then(result => {
        if (Array.isArray(result)) return result;
        return result.data ?? result;
      });
    }

    const store = new CustomStore(storeConfig);

    const displayExpr = deFields.length > 1
      ? (item: any) => {
        if (!item) return '';
        return deFields
          .map(df => item[df])
          .filter(v => v != null && v !== '')
          .join(' - ');
      }
      : displayField;

    const dsConfig: any = { store, sort: displayField };
    if (paginated) {
      dsConfig.paginate = true;
      dsConfig.pageSize = pageSize;
    }

    return {
      dataSource: dsConfig,
      valueExpr: valueField,
      displayExpr,
      allowClearing: true,
      searchEnabled: true,
      ...(deFields.length > 1 ? { searchExpr: deFields } : {}),
    };
  }

  // ── Filter fields ──────────────────────────────────────────────────────────

  private _buildFilterFields(meta: DatasetMetadata): Field[] {
    return meta.fields
      .filter(f => f.column.allowFiltering !== false && !f.isPrimaryKey)
      .map(f => ({ dataField: f.dataField, caption: f.caption, dataType: f.dataType as any }));
  }

  // ── Context menu ───────────────────────────────────────────────────────────

  private _buildContextMenu(): void {
    const hasRow = Object.keys(this.focusedRowData).length > 0;
    const selCount = this.selectedRowKeys.length;
    const builder = MenuBuilder.create();

    if (this.allowUpdating && hasRow && selCount <= 1) {
      builder.item({ text: 'Modifica', icon: 'edit', onClick: () => this._modifica() });
    }
    if (this.allowAdding) {
      builder.item({ text: 'Inserisci', icon: 'plus', onClick: () => this.onInsertClick() });
    }
    if (this.allowDeleting) {
      if (selCount > 1) {
        builder.item({ text: `Elimina ${selCount} selezionati`, icon: 'trash', onClick: () => this.deleteSelected() });
      } else if (hasRow) {
        builder.item({ text: 'Elimina', icon: 'trash', onClick: () => this._deleteRows([this.focusedRowData]) });
      }
    }

    builder
      .separator()
      .item({ text: 'Aggiorna', icon: 'refresh', onClick: () => this.refresh() })
      .item({ text: 'Seleziona tutto', icon: 'selectall', onClick: () => this.grid?.instance?.selectAll(), beginGroup: true })
      .item({ text: 'Deseleziona', icon: 'unselectall', onClick: () => this.grid?.instance?.clearSelection() })
      .item({ text: 'Filtro per valore', icon: 'filter', onClick: () => this._filtraPerValore(), beginGroup: true })
      .item({ text: 'Mostra/nascondi filtri', icon: 'filterpanel', onClick: () => this.toggleFilterPanel() });

    const exportItems = MenuBuilder.create()
      .item({ text: 'Excel (.xlsx)', icon: 'xlsxfile', onClick: () => this.exportExcel() })
      .item({ text: 'CSV', icon: 'txtfile', onClick: () => this.exportCSV() })
      .item({ text: 'PDF', icon: 'pdffile', onClick: () => this.exportPDF() })
      .build();
    builder.subMenu({ text: 'Esporta', icon: 'export', beginGroup: true }, exportItems);

    builder.item({
      text: 'Gestione colonne', icon: 'columnchooser', beginGroup: true,
      onClick: () => this.grid?.instance?.showColumnChooser(),
    });

    if (this.showDevTools()) {
      builder
        .separator()
        .item({ text: 'Incolla impostazioni colonne', icon: 'paste', onClick: () => this.incollaImpostazioni() })
        .item({ text: 'Ricarica metadati', icon: 'refresh', onClick: () => { this.reload(); notify('Metadati ricaricati', 'info', 1500); } });
    }

    this.contextMenuItems = builder.build();
  }

  // ── Dev tools menu ─────────────────────────────────────────────────────────

  private _buildDevToolsMenu(): void {
    this.devToolsMenuItems = MenuBuilder.create()
      .item({ text: 'Modifica dataset', icon: 'folder', onClick: () => this._navigate('dataset') })
      .item({ text: 'Modifica campi', icon: 'columnfield', onClick: () => this._navigate('fields') })
      .item({ text: 'Modifica gruppi form', icon: 'group', onClick: () => this._navigate('groups') })
      .item({ text: 'Anteprima JSON', icon: 'eyeopen', onClick: () => this._navigate('preview') })
      .item({ text: 'Ricarica metadati', icon: 'refresh', onClick: () => { this.reload(); notify('Metadati ricaricati', 'info', 1500); } })
      .build();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  private _modifica(): void {
    if (!Object.keys(this.focusedRowData).length) return;
    this.openForm(this.dblClickMode(), this.focusedRowData);
  }

  // Nome della voce per la conferma di eliminazione: il valore della prima
  // colonna visibile non vuota, nell'ordine della griglia (di norma la
  // descrizione). Senza, la conferma non diceva che cosa si stava per
  // eliminare. Il testo e' protetto perche' la conferma lo mostra come HTML.
  // Prima le colonne di testo libero: un collegamento o un elenco di scelta
  // in riga contiene il codice e non la descrizione (in Aziende la prima
  // colonna e' Tipo Risorsa e la conferma diceva "Eliminare P"). Solo se
  // nessuna di quelle e' valorizzata si ripiega sulle altre colonne.
  private _descrizioneRiga(row: Record<string, any>): string {
    const visibili = [...(this.metadata()?.fields ?? [])]
      .filter(f => !f.isPrimaryKey && f.column.visible !== false && f.dataType !== 'boolean')
      .sort((a, b) => (a.column.sortOrder ?? 0) - (b.column.sortOrder ?? 0));
    const testoLibero = visibili.filter(f => f.dataType === 'string' && !f.lookup && !f.picklist);
    for (const campo of [...testoLibero, ...visibili]) {
      const valore = row?.[campo.dataField];
      if (valore === null || valore === undefined || String(valore).trim() === '') continue;
      const testo = String(valore).trim();
      return (testo.length > 80 ? testo.slice(0, 80) + '...' : testo)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
    return '';
  }

  private async _deleteRows(rows: Record<string, any>[], batch = false): Promise<void> {
    const meta = this.metadata();
    const caption = meta?.caption ?? this.dataset();
    const count = rows.length;
    const voce = count === 1 ? this._descrizioneRiga(rows[0]) : '';
    const msg = count === 1
      ? (voce
        ? `Eliminare "${voce}" da "${caption}"?`
        : `Eliminare questo record da "${caption}"?`)
      : `Eliminare i ${count} record selezionati da "${caption}"?`;

    const ok = await chiediConferma('Conferma eliminazione', msg, { si: 'Elimina', pericolo: true });
    if (!ok) return;

    const pkFields = (meta?.primaryKey ?? 'ID').split(',').map(k => k.trim());
    try {
      for (const row of rows) {
        const key = pkFields.length === 1
          ? row[pkFields[0]]
          : pkFields.map(k => row[k]).join(',');
        await this.dataStore?.remove(key);
      }
      this.grid?.instance?.refresh();
      this.grid?.instance?.clearSelection();
      this.selectedRowKeys = [];
      this.focusedRowData = {};
      const msg2 = count === 1 ? 'Record eliminato' : `${count} record eliminati`;
      notify({ message: msg2, type: 'success' }, 'success', 2500);
      this.rowRemoved.emit(count === 1 ? rows[0] : rows);
    } catch (err: any) {
      // le righe gia' cancellate prima dell'errore non devono restare a video
      this.grid?.instance?.refresh();
      // l'errore del server lo mostra gia' l'intercettore dell'applicazione
      if (!erroreGiaMostrato(err))
        await mostraAvviso('Eliminazione non riuscita', [messaggioErrore(err, 'Errore durante l\'eliminazione')]);
    }
  }

  private _filtraPerValore(): void {
    if (!this._focusedColumnField) return;
    const df = this._focusedColumnField;
    const dataType = this.grid?.instance?.columnOption(df, 'dataType') as string ?? 'string';
    const value = this.focusedRowData[df];
    const op = ['number', 'date', 'datetime', 'boolean'].includes(dataType) ? '=' : 'contains';
    this.setFilter(df, op, value);
    this.filterVisible = true;
  }

  private _navigate(tab: 'dataset' | 'fields' | 'groups' | 'preview'): void {
    // subtab con i nomi delle schede di zz/meta-editor (campi, form, anteprima)
    const base: Record<string, string> = { tab: 'datasets', dataset: this.dataset() };
    const extras: Record<string, Record<string, string>> = {
      fields: { ...base, subtab: 'campi' },
      groups: { ...base, subtab: 'form' },
      preview: { ...base, subtab: 'anteprima' },
    };
    this.router.navigate(['/meta-editor'], { queryParams: extras[tab] ?? base });
  }

  private buildDownloadColumn(): any | null {
    // Se nessuno si è sottoscritto all'evento, non aggiungere la colonna
    if (this.downloadFileField() == '') {
      return null;
    }

    return {
      type: 'buttons',
      width: 45,
      caption: '',
      allowReordering: false,
      allowResizing: false,
      allowHiding: false,
      buttons: [{
        icon: 'pdffile',       // icona DevExtreme built-in; alternative: 'download', 'file'
        hint: 'Scarica file',
        visible: (e: any) => {
          // Attiva solo se il campo file ha un valore
          if (!e.row || e.row.rowType !== 'data') return false;
          const val = e.row.data[this.downloadFileField()];
          return val !== null && val !== undefined && val !== '' && val !== 0;
        },
        disabled: false,
        onClick: (e: any) => {
          e.event?.stopPropagation();
          this.downloadFile.emit(e.row.data);
        }
      }]
    };
  }
}
