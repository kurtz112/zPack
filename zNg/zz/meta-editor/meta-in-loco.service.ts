// Editor dei metadati "in loco": il tasto destro su una griglia o su una scheda
// costruita dai metadati di un dataset BaseWeb apre un menu con i comandi
// rapidi (etichetta, visibile, larghezza, ordine, obbligatorio...), salvati
// subito, e in fondo "Modifica metadati...", che apre l'editor completo in una
// finestra gia' sul dataset e sul campo.
//
// Il servizio lo fornisce la pagina che ospita le griglie, insieme a
// MetaEditorService e a ZZ_META_EDITOR_CONFIG, e nella stessa pagina va messo
// <zz-meta-in-loco />, che disegna le finestre. Le griglie lo chiedono con
// inject(..., { optional: true }): senza, il menu resta quello di DevExtreme.
//
// Dove si salva:
//  - colonne della griglia: PUT /api/meta/datasets/{ds}/grid/columns/{campo}
//    (salva i soli valori inviati); le PATCH non hanno larghezza, visibilita'
//    e ordine delle colonne;
//  - campi della scheda: PATCH /api/data/{ds}/metadata/fields e /settings di
//    Metadata.Patch.Controller, lo stesso contratto del menu di zz-form.
// I trigger del database rigenerano BASE_WEB_DATASETS_META: dopo ogni
// salvataggio la pagina rilegge i metadati (segnale 'cambiato').
import { inject, Injectable, signal } from '@angular/core';
import notify from 'devextreme/ui/notify';
import { DxDataGridTypes } from 'devextreme-angular/ui/data-grid';

import { ZZ_META_EDITOR_CONFIG } from './meta-editor.config';
import { MetaEditorService, PatchCampo } from './meta-editor.service';
import {
  campiDi,
  campoDaElemento,
  CampoMetadati,
  eBooleano,
  haCampi,
  MetadatiDataset,
  numeroColonneScheda,
  titoloColonna,
  titoloScheda,
} from './meta-runtime';

/** Una voce dei menu in loco; 'azione' la esegue il menu che la mostra. */
export interface VoceInLoco {
  text: string;
  icon?: string;
  beginGroup?: boolean;
  disabled?: boolean;
  items?: VoceInLoco[];
  azione?: () => void;
}

/** Richiesta di un valore (etichetta, posizione) alla finestra di <zz-meta-in-loco>. */
export interface DomandaInLoco {
  titolo: string;
  etichetta: string;
  tipo: 'testo' | 'numero';
  valore: string | number | null;
  /** Il valore digitato nella finestra; parte da quello proposto. */
  risposta: unknown;
  risolvi: (valore: string | number | null | undefined) => void;
}

/** L'editor completo da aprire in finestra. */
export interface EditorInLoco {
  dataset: string;
  scheda: 'campi' | 'griglia' | 'form';
  campo: string | null;
}

@Injectable()
export class ZzMetaInLocoService {
  private api = inject(MetaEditorService);
  private config = inject(ZZ_META_EDITOR_CONFIG);

  readonly editor = signal<EditorInLoco | null>(null);
  readonly domanda = signal<DomandaInLoco | null>(null);
  readonly menuScheda = signal<{ voci: VoceInLoco[]; evento: MouseEvent } | null>(null);
  /** Ultimo dataset i cui metadati sono cambiati: chi lo mostra li rilegge. */
  readonly cambiato = signal<{ dataset: string; volta: number } | null>(null);

  private volta = 0;

  abilitato(): boolean {
    return this.config.abilitato?.() ?? false;
  }

  // ─── Griglia ──────────────────────────────────────────────────────────────

  /**
   * Da chiamare in onContextMenuPreparing di una dx-data-grid costruita dai
   * metadati: aggiunge in coda le voci in loco. meta = null o senza campi:
   * c'e' solo la voce che apre l'editor, per generare i campi.
   */
  vociGriglia(
    e: DxDataGridTypes.ContextMenuPreparingEvent,
    dataset: string,
    meta: MetadatiDataset | null,
  ) {
    if (!this.abilitato() || (e.target !== 'header' && e.target !== 'content')) return;
    const voci: VoceInLoco[] = [];
    const campo = this.campo(meta, e.column?.dataField);

    if (campo) {
      voci.push({
        text: `Colonna «${titoloColonna(campo)}»`,
        icon: 'columnproperties',
        items: this.vociColonna(e, dataset, campo),
      });
    }
    const nascoste = campiDi(meta).filter((c) => c.column?.visible === false);
    if (nascoste.length) {
      voci.push({
        text: 'Mostra colonna',
        icon: 'eyeopen',
        items: nascoste.map((c) => ({
          text: titoloColonna(c),
          azione: () => this.salvaColonna(dataset, c.dataField, { VISIBLE: true }),
        })),
      });
    }
    if (haCampi(meta)) {
      voci.push({
        text: "Salva l'ordine e le larghezze delle colonne come le vedi",
        icon: 'save',
        azione: () => this.salvaDisposizione(e.component, dataset, meta!),
      });
    }
    voci.push({
      text: haCampi(meta) ? 'Modifica metadati...' : 'Genera i campi nei metadati...',
      icon: 'preferences',
      azione: () =>
        this.apriEditor(dataset, haCampi(meta) ? 'griglia' : 'campi', campo?.dataField ?? null),
    });

    voci[0].beginGroup = true;
    const elenco = (e.items ??= []) as unknown as Record<string, unknown>[];
    elenco.push(...voci.map((v) => this.vocePerGriglia(v)));
  }

  private vociColonna(
    e: DxDataGridTypes.ContextMenuPreparingEvent,
    dataset: string,
    campo: CampoMetadati,
  ): VoceInLoco[] {
    const nome = campo.dataField;
    const larghezza = Math.round(Number(e.component.columnOption(nome, 'visibleWidth')) || 0);
    const obbligatorio = !!campo.control?.required;
    return [
      {
        text: 'Etichetta...',
        icon: 'edit',
        azione: async () => {
          const testo = await this.chiedi(
            'Etichetta della colonna',
            'Etichetta',
            'testo',
            titoloColonna(campo),
          );
          if (testo !== undefined)
            await this.salvaColonna(dataset, nome, { CAPTION: testo === '' ? null : testo });
        },
      },
      {
        text: 'Nascondi',
        icon: 'eyeclose',
        azione: () => this.salvaColonna(dataset, nome, { VISIBLE: false }),
      },
      {
        text: larghezza
          ? `Fissa la larghezza attuale (${larghezza} px)`
          : 'Fissa la larghezza attuale',
        icon: 'columnfield',
        disabled: !larghezza,
        azione: () => this.salvaColonna(dataset, nome, { WIDTH: larghezza }),
      },
      {
        text: 'Larghezza automatica',
        icon: 'autolayout',
        disabled: !campo.column?.width,
        azione: () => this.salvaColonna(dataset, nome, { WIDTH: null }),
      },
      // i booleani non sono mai obbligatori (eBooleano): la voce non serve
      ...(eBooleano(campo)
        ? []
        : [
            {
              text: obbligatorio ? 'Rendi facoltativo' : 'Rendi obbligatorio',
              icon: 'isblank',
              beginGroup: true,
              azione: () => this.patchCampo(dataset, { dataField: nome, required: !obbligatorio }),
            },
          ]),
    ];
  }

  // Ordine come lo mostra la griglia (anche dopo un trascinamento), le nascoste
  // in coda nell'ordine che avevano; larghezza solo dove l'utente l'ha fissata.
  // Una colonna alla volta: ogni salvataggio fa riscrivere dal trigger la
  // stessa riga di BASE_WEB_DATASETS_META, e richieste in parallelo vanno in
  // conflitto fra loro (deadlock, salvata una colonna sola).
  private async salvaDisposizione(
    griglia: DxDataGridTypes.ContextMenuPreparingEvent['component'],
    dataset: string,
    meta: MetadatiDataset,
  ) {
    const visibili = griglia
      .getVisibleColumns()
      .map((c) => c.dataField)
      .filter((nome): nome is string => !!nome && !!this.campo(meta, nome));
    const nascoste = [...campiDi(meta)]
      .sort((a, b) => (a.column?.sortOrder ?? 0) - (b.column?.sortOrder ?? 0))
      .map((c) => c.dataField)
      .filter((nome) => !visibili.includes(nome));
    await this.esegui(dataset, async () => {
      const ordine = [...visibili, ...nascoste];
      for (const [indice, nome] of ordine.entries()) {
        const valori: Record<string, unknown> = { SORT_ORDER: (indice + 1) * 10 };
        const larghezza = griglia.columnOption(nome, 'width');
        if (typeof larghezza === 'number') valori['WIDTH'] = Math.round(larghezza);
        await this.api.salvaRiga(dataset, 'gridColumns', nome, valori);
      }
    });
  }

  // ─── Scheda ───────────────────────────────────────────────────────────────

  /**
   * Da chiamare sul 'contextmenu' di una scheda costruita con
   * elementiSchedaDaMetadati: riconosce il campo dalla classe dell'elemento e
   * apre il menu. Restituisce true se il menu e' stato aperto (allora il
   * chiamante annulla il menu del browser).
   */
  apriMenuScheda(evento: MouseEvent, dataset: string, meta: MetadatiDataset | null): boolean {
    if (!this.abilitato()) return false;
    const campo = this.campo(meta, campoDaElemento(evento.target));
    const voci: VoceInLoco[] = [];
    if (campo) {
      voci.push({ text: `Campo «${titoloScheda(campo)}»`, icon: 'fields', disabled: true });
      voci.push(...this.vociCampoScheda(dataset, campo, numeroColonneScheda(meta)));
    }
    const nascosti = campiDi(meta).filter((c) => c.control?.visible === false);
    if (nascosti.length) {
      voci.push({
        text: 'Mostra nella scheda',
        icon: 'eyeopen',
        beginGroup: true,
        items: nascosti.map((c) => ({
          text: titoloScheda(c),
          azione: () => this.patchCampo(dataset, { dataField: c.dataField, visible: true }),
        })),
      });
    }
    if (haCampi(meta)) {
      const attuali = numeroColonneScheda(meta);
      voci.push({
        text: 'Colonne della scheda',
        icon: 'detailslayout',
        beginGroup: !nascosti.length,
        items: [1, 2, 3, 4].map((n) => ({
          text: n === attuali ? `${n} (attuale)` : String(n),
          disabled: n === attuali,
          azione: () =>
            this.esegui(dataset, () => this.api.patchImpostazioni(dataset, { colCount: n })),
        })),
      });
    }
    voci.push({
      text: haCampi(meta) ? 'Modifica metadati...' : 'Genera i campi nei metadati...',
      icon: 'preferences',
      beginGroup: true,
      azione: () =>
        this.apriEditor(dataset, haCampi(meta) ? 'form' : 'campi', campo?.dataField ?? null),
    });
    // un menu gia' aperto si chiude e si riapre nel punto nuovo
    this.menuScheda.set(null);
    setTimeout(() => this.menuScheda.set({ voci, evento }));
    return true;
  }

  private vociCampoScheda(dataset: string, campo: CampoMetadati, colonne: number): VoceInLoco[] {
    const nome = campo.dataField;
    const controllo = campo.control ?? {};
    const ampiezza = controllo.colSpan ?? 1;
    const patch = (valori: Omit<PatchCampo, 'dataField'>) => () =>
      this.patchCampo(dataset, { dataField: nome, ...valori });
    return [
      {
        text: 'Etichetta...',
        icon: 'edit',
        azione: async () => {
          const testo = await this.chiedi(
            'Etichetta del campo',
            'Etichetta',
            'testo',
            titoloScheda(campo),
          );
          if (testo === undefined) return;
          // un'etichetta propria della scheda (LABEL_TEXT) prevale sul titolo
          // del campo: si cambia quella, altrimenti la modifica non si vedrebbe
          if (controllo.label !== undefined)
            await this.esegui(dataset, () =>
              this.api.salvaRiga(dataset, 'formFields', nome, {
                LABEL_TEXT: testo === '' ? null : testo,
              }),
            );
          else if (testo)
            await this.patchCampo(dataset, { dataField: nome, caption: String(testo) });
        },
      },
      { text: 'Nascondi nella scheda', icon: 'eyeclose', azione: patch({ visible: false }) },
      ...(eBooleano(campo)
        ? []
        : [
            {
              text: controllo.required ? 'Rendi facoltativo' : 'Rendi obbligatorio',
              icon: 'isblank',
              azione: patch({ required: !controllo.required }),
            },
          ]),
      {
        text: controllo.readOnly ? 'Rendi modificabile' : 'Rendi di sola lettura',
        icon: 'lock',
        azione: patch({ readOnly: !controllo.readOnly }),
      },
      {
        text: controllo.lineBreak ? 'Non andare a capo' : 'Comincia su una riga nuova',
        icon: 'return',
        azione: patch({ lineBreak: !controllo.lineBreak }),
      },
      {
        text: 'Larghezza nella scheda',
        icon: 'columnfield',
        items: [
          ...Array.from({ length: Math.max(colonne - 1, 1) }, (_, i) => i + 1).map((n) => ({
            text: n === 1 ? '1 colonna' : `${n} colonne`,
            disabled: n === ampiezza,
            azione: patch({ colSpan: n }),
          })),
          {
            text: 'Tutta la riga',
            disabled: ampiezza >= colonne,
            azione: patch({ colSpan: colonne }),
          },
        ],
      },
      {
        text: 'Posizione...',
        icon: 'sortdown',
        azione: async () => {
          const valore = await this.chiedi(
            'Posizione nella scheda',
            "Ordine (i campi si dispongono dal numero piu' basso)",
            'numero',
            controllo.sortOrder ?? null,
          );
          if (typeof valore === 'number')
            await this.patchCampo(dataset, { dataField: nome, cardIndex: Math.round(valore) });
        },
      },
    ];
  }

  // ─── Finestre ─────────────────────────────────────────────────────────────

  apriEditor(dataset: string, scheda: EditorInLoco['scheda'], campo: string | null) {
    this.editor.set({ dataset, scheda, campo });
  }

  /** Alla chiusura dell'editor la pagina rilegge: le modifiche fatte li' non si contano. */
  chiudiEditor() {
    const aperto = this.editor();
    this.editor.set(null);
    if (aperto) this.segnala(aperto.dataset);
  }

  chiudiMenuScheda() {
    this.menuScheda.set(null);
  }

  private chiedi(
    titolo: string,
    etichetta: string,
    tipo: DomandaInLoco['tipo'],
    valore: string | number | null,
  ): Promise<string | number | null | undefined> {
    return new Promise((risolvi) => {
      this.domanda.set({
        titolo,
        etichetta,
        tipo,
        valore,
        risposta: valore,
        risolvi: (risposta) => {
          this.domanda.set(null);
          risolvi(risposta);
        },
      });
    });
  }

  // ─── Salvataggi ───────────────────────────────────────────────────────────

  private salvaColonna(dataset: string, campo: string, valori: Record<string, unknown>) {
    return this.esegui(dataset, () => this.api.salvaRiga(dataset, 'gridColumns', campo, valori));
  }

  private patchCampo(dataset: string, patch: PatchCampo) {
    return this.esegui(dataset, () => this.api.patchCampi(dataset, [patch]));
  }

  private async esegui(dataset: string, lavoro: () => Promise<unknown>) {
    try {
      await lavoro();
    } catch (_errore) {
      // l'errore lo ha gia' mostrato l'intercettore dell'applicazione;
      // si rilegge comunque, perche' una parte potrebbe essere stata salvata
      this.segnala(dataset);
      return;
    }
    notify('Metadati salvati', 'success', 1500);
    this.segnala(dataset);
  }

  private segnala(dataset: string) {
    this.cambiato.set({ dataset, volta: ++this.volta });
  }

  // ─── Appoggio ─────────────────────────────────────────────────────────────

  private campo(meta: MetadatiDataset | null, nome: string | null | undefined) {
    return nome ? campiDi(meta).find((c) => c.dataField === nome) : undefined;
  }

  // Il menu della griglia vuole onItemClick su ogni voce
  private vocePerGriglia(voce: VoceInLoco): Record<string, unknown> {
    const { azione, items, ...resto } = voce;
    return {
      ...resto,
      ...(items ? { items: items.map((v) => this.vocePerGriglia(v)) } : {}),
      ...(azione ? { onItemClick: () => azione() } : {}),
    };
  }
}
