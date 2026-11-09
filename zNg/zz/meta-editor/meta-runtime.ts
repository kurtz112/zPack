// Lettura dei metadati di un dataset come li consegna zServer
// (GET /api/data/{dataset}/metadata, il JSON di BASE_WEB_DATASETS_META) e
// conversione in colonne di dx-data-grid ed elementi di dx-form. Servono alle
// pagine che costruiscono griglia e scheda dai metadati e all'anteprima
// dell'editor: cosi' l'anteprima mostra la stessa griglia che la pagina vede.
import { DxDataGridTypes } from 'devextreme-angular/ui/data-grid';
import { DxFormTypes } from 'devextreme-angular/ui/form';

/** Proprieta' della colonna di griglia (BASE_WEB_GRID_COLUMNS, con la _CUSTOM). */
export interface ColonnaMetadati {
  caption?: string;
  visible?: boolean;
  sortOrder?: number;
  width?: number;
  minWidth?: number;
  alignment?: 'left' | 'center' | 'right';
  format?: string;
  allowEditing?: boolean;
  allowFiltering?: boolean;
  allowSorting?: boolean;
  fixed?: boolean;
  fixedPosition?: 'left' | 'right';
  groupIndex?: number;
  cssClass?: string;
  encodeHtml?: boolean;
  fieldDecimals?: number;
}

/** Proprieta' del campo nella scheda (BASE_WEB_FORM_FIELDS, con la _CUSTOM). */
export interface ControlloMetadati {
  editorType?: string;
  container?: string;
  visible?: boolean;
  sortOrder?: number;
  readOnly?: boolean;
  required?: boolean;
  colSpan?: number;
  lineBreak?: boolean;
  label?: string;
  placeholder?: string;
  helpText?: string;
  editorOptions?: Record<string, unknown>;
  validation?: Record<string, unknown>[];
}

export interface CampoMetadati {
  dataField: string;
  caption?: string;
  dataType?: string;
  isPrimaryKey?: boolean;
  column?: ColonnaMetadati;
  control?: ControlloMetadati;
  picklist?: { name?: string; items?: { value: unknown; text: string }[] };
  lookup?: Record<string, unknown>;
}

export interface MetadatiDataset {
  datasetId?: string;
  caption?: string;
  primaryKey?: string;
  fields?: CampoMetadati[];
  gridSettings?: Record<string, unknown> & { editing?: Record<string, boolean> };
  formSettings?: Record<string, unknown> & { colCount?: number };
}

/** Classe CSS che identifica il campo di un elemento della scheda (menu in loco). */
export const PREFISSO_CLASSE_CAMPO = 'zz-meta-campo--';

/** Vero se il dataset ha i campi in BASE_WEB_DATASETS_FIELDS. */
export function haCampi(meta: MetadatiDataset | null | undefined): boolean {
  return Array.isArray(meta?.fields) && meta.fields.length > 0;
}

export function campiDi(meta: MetadatiDataset | null | undefined): CampoMetadati[] {
  return Array.isArray(meta?.fields) ? meta.fields : [];
}

export function titoloColonna(campo: CampoMetadati): string {
  return campo.column?.caption ?? campo.caption ?? campo.dataField;
}

export function titoloScheda(campo: CampoMetadati): string {
  return campo.control?.label ?? campo.caption ?? campo.dataField;
}

/**
 * Vero per i campi a casella (booleani). Non sono mai obbligatori: la regola
 * required di DevExtreme rifiuta false, e la casella tolta non si salverebbe.
 */
export function eBooleano(campo: CampoMetadati): boolean {
  const editor = campo.control?.editorType;
  return campo.dataType === 'boolean' || editor === 'dxCheckBox' || editor === 'dxSwitch';
}

export function numeroColonneScheda(meta: MetadatiDataset | null | undefined): number {
  return Number(meta?.formSettings?.colCount ?? 2) || 2;
}

// dataType di BaseWeb (MAP_DX_DATATYPE) -> dataType di dx-data-grid
function tipoGriglia(tipo: string | undefined): DxDataGridTypes.Column['dataType'] {
  switch (tipo) {
    case 'number':
    case 'boolean':
    case 'date':
    case 'datetime':
    case 'string':
      return tipo;
    default:
      return 'string';
  }
}

/**
 * Colonne di dx-data-grid nell'ordine di sortOrder. Le colonne nascoste restano
 * nell'elenco con visible: false, perche' la scheda di modifica della griglia
 * puo' comunque mostrare il campo.
 */
export function colonneGrigliaDaMetadati(meta: MetadatiDataset): DxDataGridTypes.Column[] {
  return [...campiDi(meta)]
    .sort((a, b) => (a.column?.sortOrder ?? 0) - (b.column?.sortOrder ?? 0))
    .map((campo) => {
      const proprieta = campo.column ?? {};
      const colonna: DxDataGridTypes.Column = {
        dataField: campo.dataField,
        caption: titoloColonna(campo),
        dataType: tipoGriglia(campo.dataType),
        visible: proprieta.visible !== false,
      };
      if (proprieta.width) colonna.width = proprieta.width;
      if (proprieta.minWidth) colonna.minWidth = proprieta.minWidth;
      if (proprieta.alignment) colonna.alignment = proprieta.alignment;
      if (proprieta.format) colonna.format = proprieta.format;
      if (proprieta.allowEditing === false) colonna.allowEditing = false;
      if (proprieta.allowFiltering === false) colonna.allowFiltering = false;
      if (proprieta.allowSorting === false) colonna.allowSorting = false;
      if (proprieta.fixed) {
        colonna.fixed = true;
        colonna.fixedPosition = proprieta.fixedPosition ?? 'left';
      }
      if (proprieta.groupIndex !== undefined) colonna.groupIndex = proprieta.groupIndex;
      if (proprieta.cssClass) colonna.cssClass = proprieta.cssClass;
      if (proprieta.encodeHtml === false) colonna.encodeHtml = false;
      if (campo.picklist?.items) {
        colonna.lookup = {
          dataSource: campo.picklist.items,
          valueExpr: 'value',
          displayExpr: 'text',
        };
      }
      const regole = regoleDiValidazione(campo);
      if (regole.length) colonna.validationRules = regole;
      return colonna;
    });
}

function regoleDiValidazione(
  campo: CampoMetadati,
): NonNullable<DxDataGridTypes.Column['validationRules']> {
  const regole = (campo.control?.validation ?? []) as NonNullable<
    DxDataGridTypes.Column['validationRules']
  >;
  if (eBooleano(campo)) return regole.filter((r) => r.type !== 'required');
  if (campo.control?.required && !regole.some((r) => r.type === 'required'))
    return [{ type: 'required' }, ...regole];
  return regole;
}

/**
 * Elementi della scheda (dx-form) nell'ordine di control.sortOrder, solo i
 * campi visibili. "A capo" fa cominciare il campo su una riga nuova: si
 * riempie il resto della riga con un elemento vuoto. Ogni elemento porta la
 * classe PREFISSO_CLASSE_CAMPO + nome del campo, che il menu in loco legge.
 * I campi da togliere dalla scheda (la chiave automatica, per esempio) vanno
 * indicati con 'escludi' e non filtrati dopo: le righe si calcolano sui campi
 * che restano, altrimenti gli elementi vuoti messi per andare a capo dopo un
 * campo tolto restano nella scheda come colonne vuote.
 */
export function elementiSchedaDaMetadati(
  meta: MetadatiDataset,
  escludi?: (campo: CampoMetadati) => boolean,
): DxFormTypes.SimpleItem[] {
  const colonne = numeroColonneScheda(meta);
  const elementi: DxFormTypes.SimpleItem[] = [];
  let posizione = 0;
  const campi = [...campiDi(meta)]
    .filter((c) => c.control?.visible !== false && !escludi?.(c))
    .sort((a, b) => (a.control?.sortOrder ?? 0) - (b.control?.sortOrder ?? 0));
  for (const campo of campi) {
    const controllo = campo.control ?? {};
    const ampiezza = Math.min(Math.max(controllo.colSpan ?? 1, 1), colonne);
    const resto = posizione % colonne;
    if ((controllo.lineBreak && resto > 0) || resto + ampiezza > colonne) {
      if (resto > 0) {
        elementi.push({ itemType: 'empty', colSpan: colonne - resto } as DxFormTypes.SimpleItem);
        posizione += colonne - resto;
      }
    }
    const elemento: DxFormTypes.SimpleItem = {
      dataField: campo.dataField,
      label: { text: titoloScheda(campo) },
      colSpan: ampiezza,
      cssClass: PREFISSO_CLASSE_CAMPO + campo.dataField,
    };
    if (controllo.required && !eBooleano(campo)) elemento.isRequired = true;
    if (controllo.helpText) elemento.helpText = controllo.helpText;
    if (controllo.editorType?.startsWith('dx'))
      elemento.editorType = controllo.editorType as DxFormTypes.SimpleItem['editorType'];
    const opzioni: Record<string, unknown> = { ...(controllo.editorOptions ?? {}) };
    if (controllo.readOnly) opzioni['readOnly'] = true;
    if (controllo.placeholder) opzioni['placeholder'] = controllo.placeholder;
    if (campo.picklist?.items) {
      opzioni['dataSource'] = campo.picklist.items;
      opzioni['valueExpr'] = 'value';
      opzioni['displayExpr'] = 'text';
      if (!elemento.editorType) elemento.editorType = 'dxSelectBox';
    }
    if (Object.keys(opzioni).length) elemento.editorOptions = opzioni;
    elementi.push(elemento);
    posizione += ampiezza;
  }
  return elementi;
}

/** Il nome del campo da un elemento della scheda (risale a .dx-field-item). */
export function campoDaElemento(elemento: EventTarget | null): string | null {
  const voce = (elemento as HTMLElement | null)?.closest?.('.dx-field-item');
  if (!voce) return null;
  for (const classe of Array.from(voce.classList)) {
    if (classe.startsWith(PREFISSO_CLASSE_CAMPO)) return classe.slice(PREFISSO_CLASSE_CAMPO.length);
  }
  return null;
}
