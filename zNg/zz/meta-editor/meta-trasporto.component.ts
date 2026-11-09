// Trasporto dei metadati dal master ai clienti (sezione 10.1 dell'analisi).
// Esporta: il pacchetto JSON (o lo script SQL equivalente) delle tabelle di
// base, senza _CUSTOM. Importa: il pacchetto in una transazione; le righe di
// base assenti dal file vengono eliminate, le _CUSTOM del database restano.
import { ChangeDetectionStrategy, Component, inject, input, signal } from '@angular/core';
import { chiediConferma } from '@zng/core/services/avviso';
import notify from 'devextreme/ui/notify';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxRadioGroupModule } from 'devextreme-angular/ui/radio-group';
import { DxTagBoxModule } from 'devextreme-angular/ui/tag-box';

import { ZZ_META_EDITOR_CONFIG } from './meta-editor.config';
import { EsitoImportazione, scaricaTesto, ValoreDominio } from './meta-editor.models';
import { MetaEditorService } from './meta-editor.service';

interface PacchettoLetto {
  nomeFile: string;
  contenuto: Record<string, unknown>;
  descrizione: string;
}

@Component({
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-trasporto',
  template: `
    <div class="zz-meta-trasporto">
      <section class="dx-card zz-meta-riquadro">
        <h3>Esporta</h3>
        <p class="zz-meta-nota">
          Le tabelle di base dei dataset scelti, con i lookup e le picklist che usano. Le
          personalizzazioni del cliente (_CUSTOM) non entrano mai nel pacchetto. Nessun filtro =
          tutto, e importandolo il database di destinazione perde i dataset che il pacchetto non
          contiene.
        </p>
        <dx-tag-box
          [items]="datasets()"
          valueExpr="value"
          displayExpr="text"
          [searchEnabled]="true"
          [showSelectionControls]="true"
          [value]="sceltiDatasets()"
          (onValueChanged)="sceltiDatasets.set($event.value)"
          label="Dataset (vuoto = tutti)"
          labelMode="static"
        ></dx-tag-box>
        <dx-tag-box
          [items]="moduli()"
          [value]="sceltiDm()"
          (onValueChanged)="sceltiDm.set($event.value)"
          label="Solo i moduli"
          labelMode="static"
        ></dx-tag-box>
        <dx-tag-box
          [items]="moduli()"
          [value]="esclusiDm()"
          (onValueChanged)="esclusiDm.set($event.value)"
          label="Escludi i moduli"
          labelMode="static"
        ></dx-tag-box>
        <dx-radio-group
          [items]="formati"
          valueExpr="value"
          displayExpr="text"
          layout="horizontal"
          [value]="formato()"
          (onValueChanged)="formato.set($event.value)"
        ></dx-radio-group>
        <div class="zz-meta-azioni">
          <dx-button
            text="Scarica"
            icon="download"
            type="default"
            (onClick)="esporta()"
          ></dx-button>
        </div>
      </section>

      <section class="dx-card zz-meta-riquadro">
        <h3>Importa</h3>
        <p class="zz-meta-nota">
          Un pacchetto JSON esportato dal master. Tutto in una transazione: o entra intero o non
          cambia niente.
        </p>
        <label class="zz-meta-file">
          <span>Pacchetto JSON</span>
          <input type="file" accept=".json,application/json" (change)="leggiFile($event)" />
        </label>
        @if (pacchetto(); as p) {
          <p>
            <b>{{ p.nomeFile }}</b
            >: {{ p.descrizione }}
          </p>
          <div class="zz-meta-azioni">
            <dx-button
              text="Importa in questo database"
              icon="upload"
              type="default"
              (onClick)="importa()"
            ></dx-button>
            <dx-button
              text="Genera lo script SQL"
              icon="doc"
              hint="Per i database senza zServer: lo script equivalente, da eseguire con zBuilder o IBEScript"
              (onClick)="script()"
            ></dx-button>
          </div>
        }
        @if (esito(); as e) {
          <h4>Esito</h4>
          <table class="zz-meta-esito">
            <thead>
              <tr>
                <th>Sezione</th>
                <th>Salvate</th>
                <th>Eliminate</th>
              </tr>
            </thead>
            <tbody>
              @for (sezione of sezioniEsito(e); track sezione) {
                <tr>
                  <td>{{ sezione }}</td>
                  <td>{{ e.salvate?.[sezione] ?? 0 }}</td>
                  <td>{{ e.eliminate?.[sezione] ?? 0 }}</td>
                </tr>
              }
            </tbody>
          </table>
        }
      </section>
    </div>
  `,
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DxButtonModule, DxRadioGroupModule, DxTagBoxModule],
})
export class MetaTrasportoComponent {
  private api = inject(MetaEditorService);

  readonly datasets = input<ValoreDominio[]>([]);
  readonly moduli = input<string[]>([]);

  readonly formati = [
    { value: 'json', text: 'Pacchetto JSON' },
    { value: 'sql', text: 'Script SQL' },
  ];
  readonly sceltiDatasets = signal<string[]>([]);
  readonly sceltiDm = signal<string[]>([]);
  readonly esclusiDm = signal<string[]>(inject(ZZ_META_EDITOR_CONFIG).escludiDmPredefiniti ?? []);
  readonly formato = signal<'json' | 'sql'>('json');
  readonly pacchetto = signal<PacchettoLetto | null>(null);
  readonly esito = signal<EsitoImportazione | null>(null);

  async esporta() {
    const formato = this.formato();
    const testo = await this.api.esporta(
      { datasets: this.sceltiDatasets(), dm: this.sceltiDm(), escludiDm: this.esclusiDm() },
      formato,
    );
    const data = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    if (formato === 'sql') {
      scaricaTesto(testo, `baseweb-metadati-${data}.sql`, 'text/plain;charset=utf-8');
    } else {
      scaricaTesto(testo, `baseweb-metadati-${data}.json`, 'application/json;charset=utf-8');
    }
  }

  async leggiFile(evento: Event) {
    this.esito.set(null);
    this.pacchetto.set(null);
    const file = (evento.target as HTMLInputElement).files?.[0];
    if (!file) return;
    let contenuto: Record<string, unknown>;
    try {
      contenuto = JSON.parse(await file.text()) as Record<string, unknown>;
    } catch (_errore) {
      notify('Il file non e’ un JSON valido', 'error', 3000);
      return;
    }
    const tabelle = contenuto['tabelle'] as Record<string, unknown[]> | undefined;
    if (!tabelle || typeof tabelle !== 'object') {
      notify('Il file non e’ un pacchetto di metadati BaseWeb (manca "tabelle")', 'error', 4000);
      return;
    }
    const origine = contenuto['origine'] as Record<string, unknown> | undefined;
    const ambito = contenuto['ambito'] as Record<string, unknown> | undefined;
    const quanti = (sezione: string) =>
      Array.isArray(tabelle[sezione]) ? tabelle[sezione].length : 0;
    this.pacchetto.set({
      nomeFile: file.name,
      contenuto,
      descrizione:
        `${quanti('datasets')} dataset, ${quanti('fields')} campi, ${quanti('lookups')} lookup, ` +
        `${quanti('picklists')} picklist` +
        (origine
          ? `, dal database ${String(origine['database'] ?? '')} del ${String(origine['data'] ?? '').slice(0, 10)}`
          : '') +
        (ambito?.['tutto'] === true
          ? '. Pacchetto completo: i dataset assenti verranno eliminati'
          : ''),
    });
  }

  async importa() {
    const p = this.pacchetto();
    if (!p) return;
    const conferma = await chiediConferma(
      'Importa metadati',
      [
        `Importare "${p.nomeFile}" in questo database?`,
        `${p.descrizione}.`,
        'Le righe di base assenti dal pacchetto vengono eliminate; le personalizzazioni restano.',
      ],
      { si: 'Importa' },
    );
    if (!conferma) return;
    this.esito.set(await this.api.importa(p.contenuto));
    notify('Importazione completata', 'success', 2000);
  }

  async script() {
    const p = this.pacchetto();
    if (!p) return;
    const testo = await this.api.scriptDaPacchetto(p.contenuto);
    scaricaTesto(testo, p.nomeFile.replace(/\.json$/i, '') + '.sql', 'text/plain;charset=utf-8');
  }

  sezioniEsito(e: EsitoImportazione): string[] {
    return Array.from(
      new Set([...Object.keys(e.salvate ?? {}), ...Object.keys(e.eliminate ?? {})]),
    );
  }
}
