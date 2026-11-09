// Editor dei metadati BaseWeb (zz-meta-editor): un componente autonomo, lo
// stesso sorgente in Agorà e in GestyWeb. L'applicazione lo apre da una rotta
// che fornisce ZZ_META_EDITOR_CONFIG (base delle API); i parametri della rotta
// tab, dataset e subtab sono quelli con cui zz-form e zz-data-grid di
// GestyWeb aprono l'editor da un campo. Dentro una finestra (editor in loco)
// gli stessi valori arrivano dagli ingressi datasetIniziale, schedaIniziale e
// campoIniziale, che prevalgono sui parametri della rotta.
// Versione e storia in VERSIONE.md.
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  OnInit,
  signal,
  ViewEncapsulation,
} from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { chiediConferma } from '@zng/core/services/avviso';
import notify from 'devextreme/ui/notify';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxDataGridModule, DxDataGridTypes } from 'devextreme-angular/ui/data-grid';
import { DxTabPanelModule } from 'devextreme-angular/ui/tab-panel';

import { MetaDatasetComponent } from './meta-dataset.component';
import { ElencoMeta, RigaMeta, testoDi, ValoreDominio } from './meta-editor.models';
import { MetaEditorService } from './meta-editor.service';
import { MetaLookupComponent } from './meta-lookup.component';
import { MetaPicklistComponent } from './meta-picklist.component';
import { MetaTrasportoComponent } from './meta-trasporto.component';

const SEZIONI = [
  { id: 'datasets', title: 'Dataset', icon: 'datafield' },
  { id: 'lookups', title: 'Lookup', icon: 'search' },
  { id: 'picklists', title: 'Picklist', icon: 'bulletlist' },
  { id: 'trasporto', title: 'Esporta e importa', icon: 'export' },
];

@Component({
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-editor',
  templateUrl: './meta-editor.component.html',
  styleUrls: ['./meta-editor.component.scss'],
  // gli stili valgono anche nei componenti figli: stanno tutti sotto .zz-meta-editor
  encapsulation: ViewEncapsulation.None,
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MetaEditorService],
  imports: [
    DxButtonModule,
    DxDataGridModule,
    DxTabPanelModule,
    MetaDatasetComponent,
    MetaLookupComponent,
    MetaPicklistComponent,
    MetaTrasportoComponent,
  ],
})
export class MetaEditorComponent implements OnInit {
  private api = inject(MetaEditorService);
  private rotta = inject(ActivatedRoute);

  /** Dataset da aprire subito (editor in finestra); vuoto = parametro 'dataset' della rotta. */
  readonly datasetIniziale = input<string | null>(null);
  /** Scheda del dataset: generale, campi, griglia, form, anteprima. */
  readonly schedaIniziale = input<string | null>(null);
  /** Campo da evidenziare nella scheda aperta. */
  readonly campoIniziale = input<string | null>(null);
  readonly campoEvidenziato = signal<string | null>(null);

  readonly sezioni = SEZIONI;
  readonly sezioneAttiva = signal(0);
  readonly pronto = signal(false);
  readonly erroreAvvio = signal<string | null>(null);

  readonly domini = signal<Map<string, ValoreDominio[]>>(new Map());
  readonly datasets = signal<RigaMeta[]>([]);
  readonly lookups = signal<RigaMeta[]>([]);
  readonly picklists = signal<RigaMeta[]>([]);
  readonly autorizzazioni = signal<RigaMeta[]>([]);

  /** Dataset aperto: undefined = nessuno, null = nuovo. */
  readonly datasetScelto = signal<string | null | undefined>(undefined);
  readonly schedaDataset = signal<string | null>(null);

  readonly elenchi = computed<Partial<Record<ElencoMeta, ValoreDominio[]>>>(() => ({
    datasets: this.datasets().map((d) => ({
      value: testoDi(d, 'DATASET'),
      text: testoDi(d, 'DATASET'),
    })),
    lookups: this.lookups().map((l) => ({
      value: testoDi(l, 'LOOKUP'),
      text: testoDi(l, 'LOOKUP'),
    })),
    picklists: this.picklists().map((p) => ({
      value: testoDi(p, 'PICKLIST'),
      text: testoDi(p, 'PICKLIST'),
    })),
    authorizations: this.autorizzazioni().map((a) => ({
      value: testoDi(a, 'AUTHORIZATION'),
      text: testoDi(a, 'NOTE')
        ? `${testoDi(a, 'AUTHORIZATION')} - ${testoDi(a, 'NOTE')}`
        : testoDi(a, 'AUTHORIZATION'),
    })),
  }));

  readonly moduli = computed(() =>
    Array.from(
      new Set(
        this.datasets()
          .map((d) => testoDi(d, 'DM'))
          .filter((m) => m),
      ),
    ).sort(),
  );

  async ngOnInit() {
    const parametri = this.rotta.snapshot.queryParamMap;
    const tab = SEZIONI.findIndex((s) => s.id === parametri.get('tab'));
    if (tab >= 0) this.sezioneAttiva.set(tab);
    try {
      const [domini, datasets, lookups, picklists, autorizzazioni] = await Promise.all([
        this.api.domini(),
        this.api.datasets(),
        this.api.lookups(),
        this.api.picklists(),
        this.api.autorizzazioni(),
      ]);
      this.domini.set(new Map(domini.map((d) => [d.domain, d.values])));
      this.datasets.set(datasets);
      this.lookups.set(lookups);
      this.picklists.set(picklists);
      this.autorizzazioni.set(autorizzazioni);
      this.pronto.set(true);
    } catch (errore) {
      // Schema del database non allineato o autorizzazione mancante: lo si dice
      // in chiaro invece di mostrare griglie vuote
      const messaggio = (errore as { message?: string })?.message ?? String(errore);
      this.erroreAvvio.set(messaggio);
      return;
    }
    const dataset = this.datasetIniziale() ?? parametri.get('dataset');
    if (dataset) {
      this.schedaDataset.set(this.schedaIniziale() ?? parametri.get('subtab'));
      this.campoEvidenziato.set(this.campoIniziale() ?? parametri.get('field'));
      this.datasetScelto.set(dataset);
    }
  }

  async ricaricaDatasets(scegli?: string) {
    this.datasets.set(await this.api.datasets());
    if (scegli !== undefined) this.datasetScelto.set(scegli);
  }

  async ricaricaLookups() {
    this.lookups.set(await this.api.lookups());
  }

  async ricaricaPicklists() {
    this.picklists.set(await this.api.picklists());
  }

  scegliDataset(e: DxDataGridTypes.RowClickEvent) {
    if (e.rowType !== 'data') return;
    this.schedaDataset.set(null);
    this.campoEvidenziato.set(null);
    this.datasetScelto.set(testoDi(e.data, 'DATASET'));
  }

  nuovoDataset() {
    this.schedaDataset.set(null);
    this.campoEvidenziato.set(null);
    this.datasetScelto.set(null);
  }

  datasetEliminato() {
    this.datasetScelto.set(undefined);
    void this.ricaricaDatasets();
  }

  async rigeneraTutti() {
    if (!(await chiediConferma('Rigenera', 'Rigenerare il JSON dei metadati di tutti i dataset?'))) {
      return;
    }
    await this.api.rigeneraTutti();
    notify('Metadati rigenerati', 'success', 1500);
  }
}
