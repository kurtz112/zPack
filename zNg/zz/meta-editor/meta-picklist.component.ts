// Picklist BaseWeb. ITEMS e' testo "Nome=Valore", una voce per riga: i trigger
// del database lo spezzano nelle voci (BASE_WEB_PICKLISTS_ITEMS) e generano il
// JSON. Un JSON incollato al posto del testo passerebbe il parser e darebbe
// voci spezzate: la scheda controlla il formato prima di salvare e, dopo,
// mostra le voci come le ha generate il database.
import { ChangeDetectionStrategy, Component, inject, input, output, signal } from '@angular/core';
import { chiediConferma } from '@zng/core/services/avviso';
import notify from 'devextreme/ui/notify';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxCheckBoxModule } from 'devextreme-angular/ui/check-box';
import { DxDataGridModule, DxDataGridTypes } from 'devextreme-angular/ui/data-grid';
import { DxTextAreaModule } from 'devextreme-angular/ui/text-area';
import { DxTextBoxModule } from 'devextreme-angular/ui/text-box';

import { RigaMeta, testoDi } from './meta-editor.models';
import { MetaEditorService } from './meta-editor.service';

@Component({
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-picklist',
  template: `
    <div class="zz-meta-divisa">
      <div class="zz-meta-divisa__elenco">
        <div class="zz-meta-azioni">
          <dx-button text="Nuova picklist" icon="add" (onClick)="nuova()"></dx-button>
        </div>
        <dx-data-grid
          [dataSource]="righe()"
          keyExpr="PICKLIST"
          [showBorders]="true"
          [hoverStateEnabled]="true"
          [focusedRowEnabled]="true"
          [focusedRowKey]="scelta()"
          [height]="600"
          noDataText="Nessuna picklist"
          (onRowClick)="scegli($event)"
        >
          <dxo-search-panel [visible]="true" placeholder="Cerca..."></dxo-search-panel>
          <dxo-scrolling mode="virtual"></dxo-scrolling>
          <dxi-column dataField="PICKLIST" caption="Picklist"></dxi-column>
          <dxi-column
            dataField="HAS_ICONS"
            caption="Icone"
            dataType="boolean"
            [width]="70"
          ></dxi-column>
        </dx-data-grid>
      </div>

      <div class="zz-meta-divisa__dettaglio">
        @if (aperta()) {
          <div class="zz-meta-azioni">
            <dx-button text="Salva" icon="save" type="default" (onClick)="salva()"></dx-button>
            @if (scelta()) {
              <dx-button
                text="Elimina"
                icon="trash"
                type="danger"
                stylingMode="outlined"
                (onClick)="elimina()"
              ></dx-button>
            }
          </div>
          <dx-text-box
            [value]="nome()"
            (onValueChanged)="nome.set($event.value)"
            [readOnly]="!!scelta()"
            label="Nome della picklist"
            labelMode="static"
          ></dx-text-box>
          <dx-check-box
            text="Le voci hanno un'icona (terzo valore: Nome=Valore=icona)"
            [value]="conIcone()"
            (onValueChanged)="conIcone.set($event.value)"
          ></dx-check-box>
          <dx-text-area
            [value]="voci()"
            (onValueChanged)="voci.set($event.value)"
            [height]="220"
            [spellcheck]="false"
            label="Voci, una per riga: Descrizione=VALORE"
            labelMode="static"
            [elementAttr]="{ class: 'zz-meta-sql' }"
          ></dx-text-area>
          @if (scelta()) {
            <h4>Voci generate dal database</h4>
            <dx-data-grid
              [dataSource]="vociGenerate()"
              [showBorders]="true"
              [columnAutoWidth]="true"
              noDataText="Nessuna voce"
            >
              <dxi-column dataField="NOME" caption="Descrizione"></dxi-column>
              <dxi-column dataField="VALORE" caption="Valore"></dxi-column>
              <dxi-column dataField="ICONA" caption="Icona"></dxi-column>
            </dx-data-grid>
          }
        } @else {
          <p class="zz-meta-nota">Scegli una picklist dall'elenco o creane una nuova.</p>
        }
      </div>
    </div>
  `,
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DxButtonModule, DxCheckBoxModule, DxDataGridModule, DxTextAreaModule, DxTextBoxModule],
})
export class MetaPicklistComponent {
  private api = inject(MetaEditorService);

  readonly righe = input<RigaMeta[]>([]);
  readonly cambiate = output<void>();

  readonly scelta = signal<string | null>(null);
  readonly aperta = signal(false);
  readonly nome = signal('');
  readonly voci = signal('');
  readonly conIcone = signal(false);
  readonly vociGenerate = signal<RigaMeta[]>([]);

  scegli(e: DxDataGridTypes.RowClickEvent) {
    if (e.rowType === 'data') void this.apri(testoDi(e.data, 'PICKLIST'));
  }

  async apri(id: string) {
    const riga = await this.api.picklist(id);
    this.scelta.set(id);
    this.nome.set(id);
    this.voci.set(testoDi(riga, 'ITEMS'));
    this.conIcone.set(riga['HAS_ICONS'] === true);
    this.vociGenerate.set(riga.items ?? []);
    this.aperta.set(true);
  }

  nuova() {
    this.scelta.set(null);
    this.nome.set('');
    this.voci.set('');
    this.conIcone.set(false);
    this.vociGenerate.set([]);
    this.aperta.set(true);
  }

  /** Righe che non rispettano il formato Nome=Valore, numerate da 1. */
  private righeSbagliate(testo: string): number[] {
    return testo
      .split(/\r?\n/)
      .map((riga, indice) => ({ riga: riga.trim(), numero: indice + 1 }))
      .filter((r) => r.riga !== '' && (r.riga.indexOf('=') <= 0 || /^[[{]/.test(r.riga)))
      .map((r) => r.numero);
  }

  async salva() {
    const id = this.nome().trim();
    if (!id) {
      notify('Nome della picklist obbligatorio', 'warning', 2500);
      return;
    }
    const sbagliate = this.righeSbagliate(this.voci());
    if (sbagliate.length) {
      notify(
        `Formato Descrizione=VALORE non rispettato alle righe ${sbagliate.join(', ')}`,
        'warning',
        4000,
      );
      return;
    }
    const nuova = this.scelta() === null;
    await this.api.salvaPicklist(id, { ITEMS: this.voci(), HAS_ICONS: this.conIcone() }, nuova);
    notify('Picklist salvata', 'success', 1500);
    this.cambiate.emit();
    await this.apri(id);
  }

  async elimina() {
    const id = this.scelta();
    if (!id) return;
    const conferma = await chiediConferma('Elimina picklist', `Eliminare la picklist "${id}"?`, {
      si: 'Elimina',
      pericolo: true,
    });
    if (!conferma) return;
    await this.api.eliminaPicklist(id);
    this.aperta.set(false);
    this.scelta.set(null);
    this.cambiate.emit();
  }
}
