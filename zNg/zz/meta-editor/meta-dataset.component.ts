// Scheda di un dataset BaseWeb: dati generali e SQL, autorizzazione, campi
// (con "Genera campi dalla SELECT"), colonne della griglia, posizioni dei campi
// nella form, anteprima del JSON che il client riceve. Con "Personalizzazioni
// del cliente" accesa ogni parte mostra accanto alle righe di base le righe
// _CUSTOM del database corrente, che il trasporto dal master non tocca mai.
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  input,
  output,
  signal,
  untracked,
} from '@angular/core';
import { chiediConferma } from '@zng/core/services/avviso';
import notify from 'devextreme/ui/notify';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxCheckBoxModule } from 'devextreme-angular/ui/check-box';
import { DxDataGridModule, DxDataGridTypes } from 'devextreme-angular/ui/data-grid';
import { DxFormModule, DxFormTypes } from 'devextreme-angular/ui/form';
import { DxPopupModule } from 'devextreme-angular/ui/popup';
import { DxSelectBoxModule } from 'devextreme-angular/ui/select-box';
import { DxTabPanelModule } from 'devextreme-angular/ui/tab-panel';
import { DxTextAreaModule } from 'devextreme-angular/ui/text-area';

import {
  AnteprimaSincronizzazione,
  ColonnaMeta,
  COLONNE_DATASET,
  ElencoMeta,
  EsitoVerificaSql,
  RigaMeta,
  SEZIONE_CAMPI,
  SEZIONE_CAMPI_FORM,
  SEZIONE_COLONNE_GRIGLIA,
  testoDi,
  ValoreDominio,
} from './meta-editor.models';
import { MetaEditorService } from './meta-editor.service';
import { colonneGrigliaDaMetadati, MetadatiDataset } from './meta-runtime';
import { MetaTabellaComponent } from './meta-tabella.component';

type ElementoForm = DxFormTypes.SimpleItem | DxFormTypes.GroupItem;

const SCHEDE = [
  { id: 'generale', title: 'Dataset', icon: 'columnproperties' },
  { id: 'campi', title: 'Campi', icon: 'fields' },
  { id: 'griglia', title: 'Griglia', icon: 'datausage' },
  { id: 'form', title: 'Form', icon: 'detailslayout' },
  { id: 'anteprima', title: 'Anteprima', icon: 'eyeopen' },
];

// Raggruppamento delle colonne del dataset nella scheda, per prefisso del nome
const GRUPPI_DATASET: { titolo: string; appartiene: (nome: string) => boolean }[] = [
  {
    titolo: 'Generale',
    appartiene: (n) =>
      !n.startsWith('SQL_') && !n.startsWith('GRID_') && !n.startsWith('FORM_') && n !== 'NOTE',
  },
  { titolo: 'Istruzioni SQL', appartiene: (n) => n.startsWith('SQL_') },
  { titolo: 'Griglia', appartiene: (n) => n.startsWith('GRID_') },
  { titolo: 'Scheda', appartiene: (n) => n.startsWith('FORM_') },
  { titolo: 'Note', appartiene: (n) => n === 'NOTE' },
];

// Colonne calcolate o gestite a parte: non tornano mai nel corpo del salvataggio
const COLONNE_NON_SALVATE = ['DM', 'NAME', 'META', 'AUTHORIZATION'];

@Component({
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-dataset',
  templateUrl: './meta-dataset.component.html',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    DxButtonModule,
    DxCheckBoxModule,
    DxDataGridModule,
    DxFormModule,
    DxPopupModule,
    DxSelectBoxModule,
    DxTabPanelModule,
    DxTextAreaModule,
    MetaTabellaComponent,
  ],
})
export class MetaDatasetComponent {
  private api = inject(MetaEditorService);

  /** Nome del dataset (Modulo.Nome); null = dataset nuovo. */
  readonly datasetId = input<string | null>(null);
  readonly schedaIniziale = input<string | null>(null);
  /** Campo da evidenziare nelle griglie di campi, colonne e posizioni nella form. */
  readonly campoIniziale = input<string | null>(null);
  readonly domini = input<Map<string, ValoreDominio[]>>(new Map());
  readonly elenchiComuni = input<Partial<Record<ElencoMeta, ValoreDominio[]>>>({});

  /** Il dataset e' stato creato o rinominato: il chiamante rilegge l'elenco. */
  readonly salvato = output<string>();
  readonly eliminato = output<string>();

  readonly schede = SCHEDE;
  readonly schedaAttiva = signal(0);
  readonly mostraCustom = signal(false);
  readonly caricamento = signal(false);

  // Riga del dataset come l'ha restituita il server, e bozze dei due moduli
  readonly dataset = signal<RigaMeta | null>(null);
  bozza: RigaMeta = {};
  bozzaCustom: RigaMeta = {};
  readonly esisteCustom = signal(false);
  autorizzazione: string | null = null;

  readonly campi = signal<RigaMeta[]>([]);
  readonly colonneGriglia = signal<RigaMeta[]>([]);
  readonly fasce = signal<RigaMeta[]>([]);
  readonly campiForm = signal<RigaMeta[]>([]);
  readonly contenitori = signal<RigaMeta[]>([]);
  readonly custom = signal<Record<string, RigaMeta[]>>({});

  readonly anteprima = signal<Record<string, unknown> | null>(null);
  readonly sincronizzazione = signal<AnteprimaSincronizzazione | null>(null);
  readonly verificaSql = signal<EsitoVerificaSql[] | null>(null);

  readonly sezioneCampi = SEZIONE_CAMPI;
  readonly sezioneColonne = SEZIONE_COLONNE_GRIGLIA;
  readonly sezioneCampiForm = SEZIONE_CAMPI_FORM;

  readonly nuovo = computed(() => this.datasetId() === null);
  // un dataset nuovo ha solo la scheda generale: le altre parti vogliono la riga salvata
  readonly schedeVisibili = computed(() => (this.nuovo() ? SCHEDE.slice(0, 1) : SCHEDE));

  readonly elenchi = computed<Partial<Record<ElencoMeta, ValoreDominio[]>>>(() => ({
    ...this.elenchiComuni(),
    bands: this.fasce().map((f) => ({
      value: testoDi(f, 'BAND_NAME'),
      text: testoDi(f, 'CAPTION') || testoDi(f, 'BAND_NAME'),
    })),
    containers: this.contenitori().map((c) => ({
      value: testoDi(c, 'CONTAINER_NAME'),
      text: `${testoDi(c, 'CONTAINER_NAME')} (${testoDi(c, 'CONTAINER_TYPE')})`,
    })),
  }));

  readonly elementiForm = computed(() => this.costruisciForm(false));
  readonly elementiFormCustom = computed(() => this.costruisciForm(true));

  readonly anteprimaForm = computed(() => this.elementiAnteprimaForm());
  readonly anteprimaColonne = computed(() => this.colonneAnteprimaGriglia());
  readonly anteprimaTesto = computed(() => JSON.stringify(this.anteprima(), null, 2));

  // Funzioni passate alle griglie: legate qui perche' le griglie le chiamano senza 'this'
  readonly salvaCampo = (chiave: string, valori: RigaMeta) =>
    this.api.salvaRiga(this.id(), 'fields', chiave, valori);
  readonly eliminaCampo = (chiave: string) => this.api.eliminaRiga(this.id(), 'fields', chiave);
  readonly salvaColonna = (chiave: string, valori: RigaMeta) =>
    this.api.salvaRiga(this.id(), 'gridColumns', chiave, valori);
  readonly eliminaColonna = (chiave: string) =>
    this.api.eliminaRiga(this.id(), 'gridColumns', chiave);
  readonly salvaCampoForm = (chiave: string, valori: RigaMeta) =>
    this.api.salvaRiga(this.id(), 'formFields', chiave, valori);
  readonly eliminaCampoForm = (chiave: string) =>
    this.api.eliminaRiga(this.id(), 'formFields', chiave);
  readonly salvaCustomDi = (sezione: string) => (chiave: string, valori: RigaMeta) =>
    this.api.salvaCustom(this.id(), sezione, chiave, valori);
  readonly eliminaCustomDi = (sezione: string) => (chiave: string) =>
    this.api.eliminaCustom(this.id(), sezione, chiave);

  // Le funzioni di sopra servono gia' pronte nel modello: una per sezione
  readonly salvaCustomCampi = this.salvaCustomDi('fields');
  readonly eliminaCustomCampi = this.eliminaCustomDi('fields');
  readonly salvaCustomColonne = this.salvaCustomDi('gridColumns');
  readonly eliminaCustomColonne = this.eliminaCustomDi('gridColumns');
  readonly salvaCustomCampiForm = this.salvaCustomDi('formFields');
  readonly eliminaCustomCampiForm = this.eliminaCustomDi('formFields');

  constructor() {
    effect(() => {
      const id = this.datasetId();
      const scheda = this.schedaIniziale();
      untracked(() => {
        const indice = SCHEDE.findIndex((s) => s.id === scheda);
        this.schedaAttiva.set(indice >= 0 ? indice : 0);
        void this.carica(id);
      });
    });
  }

  private id(): string {
    return this.datasetId() ?? '';
  }

  // ─── Caricamento ─────────────────────────────────────────────────────────

  async carica(id: string | null) {
    this.anteprima.set(null);
    this.verificaSql.set(null);
    if (id === null) {
      this.dataset.set({});
      this.bozza = { CAN_INSERT: true, CAN_UPDATE: true, CAN_DELETE: true };
      this.bozzaCustom = {};
      this.esisteCustom.set(false);
      this.autorizzazione = null;
      for (const s of [
        this.campi,
        this.colonneGriglia,
        this.fasce,
        this.campiForm,
        this.contenitori,
      ])
        s.set([]);
      this.custom.set({});
      return;
    }
    this.caricamento.set(true);
    try {
      const [riga, campi, griglia, form, custom] = await Promise.all([
        this.api.dataset(id),
        this.api.campi(id),
        this.api.griglia(id),
        this.api.form(id),
        this.api.custom(id),
      ]);
      this.dataset.set(riga);
      this.bozza = { ...riga };
      this.autorizzazione = (riga['AUTHORIZATION'] as string | null) ?? null;
      this.campi.set(campi);
      this.colonneGriglia.set(griglia.columns ?? []);
      this.fasce.set(griglia.bands ?? []);
      this.campiForm.set(form['fields'] ?? []);
      this.contenitori.set(form['containers'] ?? []);
      this.impostaCustom(custom);
    } finally {
      this.caricamento.set(false);
    }
  }

  private impostaCustom(custom: Record<string, RigaMeta[]>) {
    this.custom.set(custom);
    const rigaCustom = custom['datasets']?.[0];
    this.esisteCustom.set(!!rigaCustom);
    this.bozzaCustom = rigaCustom ? { ...rigaCustom } : {};
  }

  async ricaricaCampi() {
    const id = this.id();
    const [campi, griglia, form] = await Promise.all([
      this.api.campi(id),
      this.api.griglia(id),
      this.api.form(id),
    ]);
    this.campi.set(campi);
    this.colonneGriglia.set(griglia.columns ?? []);
    this.fasce.set(griglia.bands ?? []);
    this.campiForm.set(form['fields'] ?? []);
    this.contenitori.set(form['containers'] ?? []);
  }

  async ricaricaColonne() {
    const griglia = await this.api.griglia(this.id());
    this.colonneGriglia.set(griglia.columns ?? []);
    this.fasce.set(griglia.bands ?? []);
  }

  async ricaricaCampiForm() {
    const form = await this.api.form(this.id());
    this.campiForm.set(form['fields'] ?? []);
    this.contenitori.set(form['containers'] ?? []);
  }

  async ricaricaCustom() {
    this.impostaCustom(await this.api.custom(this.id()));
  }

  // ─── Scheda del dataset ──────────────────────────────────────────────────

  private costruisciForm(custom: boolean): ElementoForm[] {
    const base = this.dataset() ?? {};
    const colonne = COLONNE_DATASET.filter((c) => !custom || c.nome !== 'DATASET');
    return GRUPPI_DATASET.map((gruppo) => ({
      itemType: 'group' as const,
      caption: gruppo.titolo,
      colCount: 2,
      items: colonne
        .filter((c) => gruppo.appartiene(c.nome))
        .map((c) => this.elementoDataset(c, custom, base)),
    })).filter((g) => g.items.length > 0);
  }

  private elementoDataset(c: ColonnaMeta, custom: boolean, base: RigaMeta): DxFormTypes.SimpleItem {
    const elemento: DxFormTypes.SimpleItem = {
      dataField: c.nome,
      label: { text: c.titolo },
      editorOptions: {},
    };
    const opzioni = elemento.editorOptions as Record<string, unknown>;
    // nella personalizzazione il valore di base fa da segnaposto: vuoto = eredita
    if (custom) opzioni['placeholder'] = testoDi(base, c.nome) || '(come la base)';

    switch (c.tipo) {
      case 'siNo':
        if (custom) {
          elemento.editorType = 'dxSelectBox';
          Object.assign(opzioni, {
            items: [
              { value: true, text: 'Sì' },
              { value: false, text: 'No' },
            ],
            valueExpr: 'value',
            displayExpr: 'text',
            showClearButton: true,
            placeholder:
              base[c.nome] === true ? 'Sì (base)' : base[c.nome] === false ? 'No (base)' : '',
          });
        } else {
          elemento.editorType = 'dxCheckBox';
        }
        break;
      case 'intero':
        elemento.editorType = 'dxNumberBox';
        Object.assign(opzioni, { showSpinButtons: true, format: '#0' });
        break;
      case 'memo':
        elemento.editorType = 'dxTextArea';
        elemento.colSpan = 2;
        Object.assign(opzioni, {
          height: c.nome.startsWith('SQL_') ? 150 : 80,
          spellcheck: false,
          elementAttr: { class: 'zz-meta-sql' },
        });
        break;
      case 'dominio':
        elemento.editorType = 'dxSelectBox';
        Object.assign(opzioni, {
          items: this.domini().get(c.dominio ?? '') ?? [],
          valueExpr: 'value',
          displayExpr: 'text',
          showClearButton: true,
          acceptCustomValue: false,
        });
        break;
      default:
        elemento.editorType = 'dxTextBox';
    }
    if (c.nome === 'DATASET') {
      opzioni['readOnly'] = !this.nuovo();
      elemento.validationRules = [{ type: 'required', message: 'Nome del dataset obbligatorio' }];
      elemento.helpText = 'Nella forma Modulo.Nome, per esempio Agora.ConfigSquadre';
    }
    return elemento;
  }

  async salvaDataset() {
    const id = testoDi(this.bozza, 'DATASET').trim();
    if (!id.includes('.')) {
      notify('Il nome del dataset va scritto nella forma Modulo.Nome', 'warning', 3000);
      return;
    }
    const corpo: RigaMeta = { ...this.bozza };
    for (const colonna of COLONNE_NON_SALVATE) delete corpo[colonna];
    const nuovo = this.nuovo();
    await this.api.salvaDataset(id, corpo, nuovo);
    notify('Dataset salvato', 'success', 1500);
    if (nuovo) {
      this.salvato.emit(id);
    } else {
      await this.carica(id);
      this.salvato.emit(id);
    }
  }

  async salvaAutorizzazione() {
    const riga = await this.api.impostaAutorizzazione(this.id(), this.autorizzazione);
    this.dataset.update((d) => ({ ...d, AUTHORIZATION: riga['AUTHORIZATION'] }));
    notify(
      this.autorizzazione
        ? `Il dataset richiede ora l'autorizzazione ${this.autorizzazione}`
        : 'Il dataset non richiede piu’ un’autorizzazione',
      'success',
      2500,
    );
  }

  async eliminaDataset() {
    const id = this.id();
    const conferma = await chiediConferma(
      'Elimina dataset',
      `Eliminare il dataset "${id}" con campi, colonne, form e personalizzazioni?`,
      { si: 'Elimina', pericolo: true },
    );
    if (!conferma) return;
    await this.api.eliminaDataset(id);
    notify('Dataset eliminato', 'success', 1500);
    this.eliminato.emit(id);
  }

  async salvaPersonalizzazione() {
    const corpo: RigaMeta = { ...this.bozzaCustom };
    for (const colonna of [...COLONNE_NON_SALVATE, 'DATASET']) delete corpo[colonna];
    await this.api.salvaCustom(this.id(), 'datasets', null, corpo);
    notify('Personalizzazione salvata', 'success', 1500);
    await this.ricaricaCustom();
  }

  async togliPersonalizzazione() {
    const conferma = await chiediConferma('Personalizzazione', [
      'Togliere la personalizzazione del dataset?',
      'Tornano a valere i valori di base.',
    ]);
    if (!conferma) return;
    await this.api.eliminaCustom(this.id(), 'datasets', null);
    await this.ricaricaCustom();
  }

  async verificaIstruzioni() {
    const valori: RigaMeta = {};
    for (const colonna of ['SQL_SELECT', 'SQL_COUNT', 'SQL_INSERT', 'SQL_UPDATE', 'SQL_DELETE'])
      valori[colonna] = this.bozza[colonna] ?? '';
    this.verificaSql.set(await this.api.verificaSql(this.id(), valori));
  }

  // ─── Genera campi dalla SELECT ───────────────────────────────────────────

  async anteprimaGeneraCampi() {
    this.sincronizzazione.set(await this.api.anteprimaSincronizzazione(this.id()));
  }

  async confermaGeneraCampi() {
    const campi = await this.api.sincronizzaCampi(this.id());
    this.sincronizzazione.set(null);
    this.campi.set(campi);
    await this.ricaricaCampi();
    notify(`Campi generati: ${campi.length}`, 'success', 2000);
  }

  // ─── Anteprima ───────────────────────────────────────────────────────────

  async aggiornaAnteprima() {
    this.anteprima.set(await this.api.anteprima(this.id()));
  }

  async rigenera() {
    await this.api.rigeneraMeta(this.id());
    await this.aggiornaAnteprima();
    notify('Metadati rigenerati', 'success', 1500);
  }

  private campiAnteprima(): Record<string, unknown>[] {
    const campi = this.anteprima()?.['fields'];
    return Array.isArray(campi) ? (campi as Record<string, unknown>[]) : [];
  }

  // La form come la costruirebbe il client: gli elementi di formSettings.items,
  // con editor ed etichetta presi da fields[].control
  private elementiAnteprimaForm(): ElementoForm[] {
    const impostazioni = this.anteprima()?.['formSettings'] as Record<string, unknown> | undefined;
    const elementi = impostazioni?.['items'];
    if (!Array.isArray(elementi)) return [];
    const controlli = new Map<string, Record<string, unknown>>();
    for (const campo of this.campiAnteprima()) {
      const controllo = campo['control'];
      if (controllo && typeof controllo === 'object')
        controlli.set(String(campo['dataField'] ?? ''), controllo as Record<string, unknown>);
    }
    const converti = (elemento: Record<string, unknown>): Record<string, unknown> => {
      const copia: Record<string, unknown> = { ...elemento };
      for (const figli of ['items', 'tabs']) {
        if (Array.isArray(copia[figli]))
          copia[figli] = (copia[figli] as Record<string, unknown>[]).map(converti);
      }
      const controllo = controlli.get(String(copia['dataField'] ?? ''));
      if (controllo) {
        if (controllo['editorType']) copia['editorType'] = controllo['editorType'];
        if (controllo['label'] && !copia['label']) copia['label'] = controllo['label'];
      }
      return copia;
    };
    // gli elementi del JSON sono gia' nel formato di dx-form (group, tabbed, simple...)
    return (elementi as Record<string, unknown>[]).map(converti) as ElementoForm[];
  }

  // Le colonne come le costruisce una pagina che legge i metadati: fields[].column
  // da solo non ha dataField ne' titolo, che stanno sul campo
  private colonneAnteprimaGriglia(): DxDataGridTypes.Column[] {
    const anteprima = this.anteprima();
    return anteprima ? colonneGrigliaDaMetadati(anteprima as MetadatiDataset) : [];
  }

  numeroColonneAnteprima(): number {
    const impostazioni = this.anteprima()?.['formSettings'] as Record<string, unknown> | undefined;
    return Number(impostazioni?.['colCount'] ?? 2) || 2;
  }
}
