// Lookup BaseWeb: elenco, scheda (dataset sorgente, tabella, campi valore e
// descrizione, parametri) e colonne della discesa. Un lookup usato da un campo
// non si cancella: il database lo rifiuta e il messaggio arriva cosi' com'e'.
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
  signal,
} from '@angular/core';
import { chiediConferma } from '@zng/core/services/avviso';
import notify from 'devextreme/ui/notify';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxDataGridModule, DxDataGridTypes } from 'devextreme-angular/ui/data-grid';
import { DxFormModule, DxFormTypes } from 'devextreme-angular/ui/form';

import {
  ElencoMeta,
  RigaMeta,
  SEZIONE_COLONNE_LOOKUP,
  SEZIONE_LOOKUP,
  testoDi,
  ValoreDominio,
} from './meta-editor.models';
import { MetaEditorService } from './meta-editor.service';
import { MetaTabellaComponent } from './meta-tabella.component';

@Component({
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-lookup',
  template: `
    <div class="zz-meta-divisa">
      <div class="zz-meta-divisa__elenco">
        <div class="zz-meta-azioni">
          <dx-button text="Nuovo lookup" icon="add" (onClick)="nuovo()"></dx-button>
        </div>
        <dx-data-grid
          [dataSource]="righe()"
          keyExpr="LOOKUP"
          [showBorders]="true"
          [hoverStateEnabled]="true"
          [focusedRowEnabled]="true"
          [focusedRowKey]="scelto()"
          [height]="600"
          noDataText="Nessun lookup"
          (onRowClick)="scegli($event)"
        >
          <dxo-search-panel [visible]="true" placeholder="Cerca..."></dxo-search-panel>
          <dxo-scrolling mode="virtual"></dxo-scrolling>
          <dxi-column dataField="LOOKUP" caption="Lookup"></dxi-column>
          <dxi-column dataField="DATASET" caption="Dataset sorgente"></dxi-column>
        </dx-data-grid>
      </div>

      <div class="zz-meta-divisa__dettaglio">
        @if (bozza(); as riga) {
          <div class="zz-meta-azioni">
            <dx-button text="Salva" icon="save" type="default" (onClick)="salva()"></dx-button>
            @if (!eNuovo()) {
              <dx-button
                text="Elimina"
                icon="trash"
                type="danger"
                stylingMode="outlined"
                (onClick)="elimina()"
              ></dx-button>
            }
          </div>
          <dx-form
            [formData]="riga"
            [items]="elementi()"
            [colCount]="2"
            labelLocation="top"
          ></dx-form>
          @if (!eNuovo()) {
            <h4>Colonne della discesa</h4>
            <zz-meta-tabella
              [sezione]="sezioneColonne"
              [righe]="colonne()"
              [domini]="domini()"
              titoloScheda="Colonna del lookup"
              testoVuoto="Nessuna colonna: la discesa mostra il campo descrizione"
              [salva]="salvaColonna"
              [elimina]="eliminaColonna"
              (cambiate)="apri(scelto())"
            />
          }
        } @else {
          <p class="zz-meta-nota">Scegli un lookup dall'elenco o creane uno nuovo.</p>
        }
      </div>
    </div>
  `,
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DxButtonModule, DxDataGridModule, DxFormModule, MetaTabellaComponent],
})
export class MetaLookupComponent {
  private api = inject(MetaEditorService);

  readonly righe = input<RigaMeta[]>([]);
  readonly domini = input<Map<string, ValoreDominio[]>>(new Map());
  readonly elenchi = input<Partial<Record<ElencoMeta, ValoreDominio[]>>>({});
  /** L'elenco dei lookup e' cambiato: il chiamante lo rilegge. */
  readonly cambiati = output<void>();

  readonly sezioneColonne = SEZIONE_COLONNE_LOOKUP;
  readonly scelto = signal<string | null>(null);
  readonly bozza = signal<RigaMeta | null>(null);
  readonly colonne = signal<RigaMeta[]>([]);
  readonly eNuovo = computed(() => this.scelto() === null && this.bozza() !== null);

  readonly elementi = computed<DxFormTypes.SimpleItem[]>(() =>
    SEZIONE_LOOKUP.colonne.map((c) => {
      const elemento: DxFormTypes.SimpleItem = { dataField: c.nome, label: { text: c.titolo } };
      if (c.nome === 'LOOKUP') {
        elemento.editorOptions = { readOnly: !this.eNuovo() };
        elemento.validationRules = [{ type: 'required' }];
      } else if (c.tipo === 'elenco') {
        elemento.editorType = 'dxSelectBox';
        elemento.editorOptions = {
          items: this.elenchi()[c.elenco as ElencoMeta] ?? [],
          valueExpr: 'value',
          displayExpr: 'text',
          searchEnabled: true,
          showClearButton: true,
        };
      } else if (c.tipo === 'intero') {
        elemento.editorType = 'dxNumberBox';
        elemento.editorOptions = { showSpinButtons: true, format: '#0' };
      } else if (c.tipo === 'memo') {
        elemento.editorType = 'dxTextArea';
        elemento.colSpan = 2;
        elemento.editorOptions = {
          height: 80,
          spellcheck: false,
          elementAttr: { class: 'zz-meta-sql' },
        };
      }
      return elemento;
    }),
  );

  readonly salvaColonna = (campo: string, valori: RigaMeta) =>
    this.api.salvaColonnaLookup(this.scelto() ?? '', campo, valori);
  readonly eliminaColonna = (campo: string) =>
    this.api.eliminaColonnaLookup(this.scelto() ?? '', campo);

  scegli(e: DxDataGridTypes.RowClickEvent) {
    if (e.rowType === 'data') void this.apri(testoDi(e.data, 'LOOKUP'));
  }

  async apri(id: string | null) {
    if (id === null) return;
    const riga = await this.api.lookup(id);
    const { columns, ...dati } = riga;
    this.scelto.set(id);
    this.colonne.set(columns ?? []);
    this.bozza.set({ ...dati });
  }

  nuovo() {
    this.scelto.set(null);
    this.colonne.set([]);
    this.bozza.set({ PAGESIZE: 20 });
  }

  async salva() {
    const riga = this.bozza();
    if (!riga) return;
    const id = testoDi(riga, 'LOOKUP').trim();
    if (!id) {
      notify('Nome del lookup obbligatorio', 'warning', 2500);
      return;
    }
    await this.api.salvaLookup(id, riga, this.eNuovo());
    notify('Lookup salvato', 'success', 1500);
    this.cambiati.emit();
    await this.apri(id);
  }

  async elimina() {
    const id = this.scelto();
    if (!id) return;
    const conferma = await chiediConferma('Elimina lookup', `Eliminare il lookup "${id}"?`, {
      si: 'Elimina',
      pericolo: true,
    });
    if (!conferma) return;
    await this.api.eliminaLookup(id);
    this.scelto.set(null);
    this.bozza.set(null);
    this.cambiati.emit();
  }
}
