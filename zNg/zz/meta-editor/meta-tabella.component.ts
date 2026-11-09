// Griglia di modifica di una tabella BaseWeb, costruita dalla descrizione
// della sezione (meta-editor.models.ts). Due modi:
//  - 'base': le righe della tabella, con tutte le colonne;
//  - 'custom': le righe _CUSTOM dello stesso dataset, con le sole colonne che
//    la personalizzazione puo' sovrascrivere. Una cella vuota eredita il valore
//    di base, che si vede in corsivo: e' la vista affiancata base/cliente.
// Il salvataggio e la cancellazione li fa il chiamante (salva, elimina); la
// griglia avvisa con 'cambiate' e il chiamante rilegge le righe dal server,
// cosi' quello che si vede e' sempre la riga riletta dal database.
import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';
import notify from 'devextreme/ui/notify';
import { DxDataGridModule, DxDataGridTypes } from 'devextreme-angular/ui/data-grid';

import {
  ColonnaMeta,
  ElencoMeta,
  RigaMeta,
  SezioneMeta,
  testoDi,
  ValoreDominio,
} from './meta-editor.models';

type ColonnaGriglia = DxDataGridTypes.Column;

const VALORI_SI_NO = [
  { value: true, text: 'Sì' },
  { value: false, text: 'No' },
];

@Component({
  // Prefisso zz come il resto della cartella: lo stesso sorgente sta in Agorà e in GestyWeb
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-tabella',
  templateUrl: './meta-tabella.component.html',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DxDataGridModule],
})
export class MetaTabellaComponent {
  readonly sezione = input.required<SezioneMeta>();
  readonly righe = input<RigaMeta[]>([]);
  readonly modo = input<'base' | 'custom'>('base');
  /** Nel modo 'custom': le righe di base, per i valori ereditati e le chiavi ammesse. */
  readonly righeBase = input<RigaMeta[]>([]);
  readonly domini = input<Map<string, ValoreDominio[]>>(new Map());
  readonly elenchi = input<Partial<Record<ElencoMeta, ValoreDominio[]>>>({});
  readonly consentiNuove = input(true);
  readonly consentiCancellazione = input(true);
  readonly titoloScheda = input('Modifica');
  readonly testoVuoto = input('Nessuna riga');
  /** Chiave della riga da evidenziare e portare in vista (editor aperto da un campo). */
  readonly evidenziata = input<string | null>(null);
  readonly salva =
    input.required<(chiave: string, valori: RigaMeta, nuova: boolean) => Promise<unknown>>();
  readonly elimina = input.required<(chiave: string) => Promise<unknown>>();

  readonly cambiate = output<void>();

  readonly chiave = computed(() => this.sezione().chiave);

  /** Copia delle righe: la griglia modifica il suo array, non quello del chiamante. */
  readonly dati = computed(() => this.righe().map((riga) => ({ ...riga })));

  private readonly basePerChiave = computed(() => {
    const mappa = new Map<string, RigaMeta>();
    for (const riga of this.righeBase()) mappa.set(testoDi(riga, this.chiave()), riga);
    return mappa;
  });

  readonly colonne = computed<ColonnaGriglia[]>(() => {
    const sezione = this.sezione();
    const custom = this.modo() === 'custom';
    const ammesse = new Set(sezione.colonneCustom ?? []);
    return sezione.colonne
      .filter((c) => !custom || c.nome === sezione.chiave || ammesse.has(c.nome))
      .map((c) => this.colonnaGriglia(c, c.nome === sezione.chiave, custom));
  });

  readonly modifica = computed(() => ({
    mode: 'popup' as const,
    useIcons: true,
    allowAdding: this.consentiNuove(),
    allowUpdating: true,
    allowDeleting: this.consentiCancellazione(),
    confirmDelete: true,
    popup: { title: this.titoloScheda(), showTitle: true, width: 760, height: 'auto' },
    form: { colCount: 2 },
    texts: {
      confirmDeleteMessage:
        this.modo() === 'custom'
          ? 'Togliere la personalizzazione? Torna a valere il valore di base.'
          : 'Eliminare la riga?',
    },
  }));

  private colonnaGriglia(c: ColonnaMeta, eChiave: boolean, custom: boolean): ColonnaGriglia {
    const colonna: ColonnaGriglia = {
      dataField: c.nome,
      caption: c.titolo,
      visible: !c.soloScheda && c.tipo !== 'memo',
      width: c.larghezza,
    };
    if (eChiave) {
      colonna.validationRules = [{ type: 'required' }];
      colonna.fixed = true;
      if (custom) {
        // la personalizzazione si crea solo su una riga di base che esiste
        colonna.lookup = {
          dataSource: () =>
            this.righeBase().map((r) => ({ value: testoDi(r, c.nome), text: testoDi(r, c.nome) })),
          valueExpr: 'value',
          displayExpr: 'text',
        };
      }
      return colonna;
    }

    if (custom) colonna.cellTemplate = 'cellaCustom';

    switch (c.tipo) {
      case 'siNo':
        if (custom) {
          // tre stati: Sì, No, vuoto = come la base
          colonna.lookup = {
            dataSource: VALORI_SI_NO,
            valueExpr: 'value',
            displayExpr: 'text',
            allowClearing: true,
          };
        } else {
          colonna.dataType = 'boolean';
        }
        break;
      case 'intero':
        colonna.dataType = 'number';
        break;
      case 'memo':
        colonna.formItem = {
          editorType: 'dxTextArea',
          colSpan: 2,
          editorOptions: { height: 90, spellcheck: false },
        };
        break;
      case 'dominio':
        colonna.lookup = {
          dataSource: this.domini().get(c.dominio ?? '') ?? [],
          valueExpr: 'value',
          displayExpr: 'text',
          allowClearing: true,
        };
        break;
      case 'elenco':
        colonna.lookup = {
          dataSource: this.elenchi()[c.elenco as ElencoMeta] ?? [],
          valueExpr: 'value',
          displayExpr: 'text',
          allowClearing: true,
        };
        break;
      default:
        colonna.dataType = 'string';
    }
    return colonna;
  }

  /** Il valore di base che una cella _CUSTOM vuota eredita, in chiaro. */
  ereditato(cella: { column: { dataField?: string }; data: RigaMeta }): string {
    const campo = cella.column.dataField ?? '';
    const base = this.basePerChiave().get(testoDi(cella.data, this.chiave()));
    const valore = base?.[campo];
    if (valore === null || valore === undefined || valore === '') return '';
    if (typeof valore === 'boolean') return valore ? 'Sì' : 'No';
    const descrizione = this.sezione().colonne.find((c) => c.nome === campo);
    if (descrizione?.tipo === 'dominio') {
      const voce = this.domini()
        .get(descrizione.dominio ?? '')
        ?.find((v) => v.value === String(valore));
      if (voce) return voce.text;
    }
    return String(valore);
  }

  onEditorPreparing(e: DxDataGridTypes.EditorPreparingEvent) {
    // la chiave si sceglie solo su una riga nuova: rinominare vuol dire creare e cancellare
    if (e.parentType === 'dataRow' && e.dataField === this.chiave() && !e.row?.isNewRow) {
      e.editorOptions.readOnly = true;
    }
  }

  onRowInserting(e: DxDataGridTypes.RowInsertingEvent) {
    const chiave = testoDi(e.data, this.chiave()).trim();
    e.cancel = this.esegui(() => this.salva()(chiave, { ...e.data }, true), 'Riga salvata');
  }

  onRowUpdating(e: DxDataGridTypes.RowUpdatingEvent) {
    const chiave = testoDi(e.oldData, this.chiave());
    // solo i valori cambiati: il server rilegge la riga e li sovrappone
    e.cancel = this.esegui(() => this.salva()(chiave, { ...e.newData }, false), 'Riga salvata');
  }

  onRowRemoving(e: DxDataGridTypes.RowRemovingEvent) {
    const chiave = testoDi(e.data, this.chiave());
    e.cancel = this.esegui(() => this.elimina()(chiave), 'Riga eliminata');
  }

  // Promise<boolean> per e.cancel: false = la griglia applica la modifica,
  // true = la annulla (l'errore lo ha gia' mostrato l'intercettore HTTP)
  private async esegui(azione: () => Promise<unknown>, messaggio: string): Promise<boolean> {
    try {
      await azione();
      notify(messaggio, 'success', 1500);
      this.cambiate.emit();
      return false;
    } catch (_errore) {
      return true;
    }
  }
}
