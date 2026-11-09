// Tipi e descrizione delle colonne delle tabelle BaseWeb, come le espongono le
// _LOAD del pacchetto BASE_WEB_TABLE_IO (nomi in maiuscolo). La griglia e le
// schede dell'editor si costruiscono da queste descrizioni: una colonna nuova
// nel pacchetto si aggiunge qui e compare dappertutto.

/** Una riga come la restituisce zServer: nomi delle colonne in maiuscolo. */
export type RigaMeta = Record<string, unknown>;

/** Un valore ammesso di un dominio BASE_WEB_* (GET /domains). */
export interface ValoreDominio {
  value: string;
  text: string;
}

export interface DominioMeta {
  domain: string;
  values: ValoreDominio[];
}

/** Elenchi di valori che non sono domini ma righe di altre tabelle. */
export type ElencoMeta =
  'picklists' | 'lookups' | 'datasets' | 'authorizations' | 'bands' | 'containers';

export type TipoColonnaMeta = 'testo' | 'memo' | 'siNo' | 'intero' | 'dominio' | 'elenco';

export interface ColonnaMeta {
  nome: string;
  titolo: string;
  tipo: TipoColonnaMeta;
  /** Dominio da cui prendere i valori ammessi (tipo 'dominio'). */
  dominio?: string;
  /** Elenco da cui prendere i valori (tipo 'elenco'). */
  elenco?: ElencoMeta;
  /** Solo nella scheda di modifica, non fra le colonne della griglia. */
  soloScheda?: boolean;
  larghezza?: number;
}

/**
 * Una tabella BaseWeb vista dall'editor: la sezione e' il nome che usa zServer
 * (catalogo di Metadata.Transfer.Service), la chiave e' la colonna che
 * identifica la riga dentro il dataset (o dentro il lookup).
 */
export interface SezioneMeta {
  sezione: string;
  chiave: string;
  colonne: ColonnaMeta[];
  /** Colonne che la tabella _CUSTOM puo' sovrascrivere; assente = nessuna _CUSTOM. */
  colonneCustom?: string[];
}

/** Esito di "Genera campi dalla SELECT" in anteprima (GET fields/sync-preview). */
export interface AnteprimaSincronizzazione {
  campi: { FIELD: string; FIELD_ORIGIN: string; DATA_TYPE: string; esistente: boolean }[];
  daEliminare: string[];
}

/** Esito della verifica delle SQL (POST check-sql). */
export interface EsitoVerificaSql {
  istruzione: string;
  ok: boolean;
  messaggio: string;
  campi?: { FIELD: string; FIELD_ORIGIN: string; DATA_TYPE: string }[];
}

/** Esito dell'importazione (POST /import): righe salvate ed eliminate per sezione. */
export interface EsitoImportazione {
  salvate?: Record<string, number>;
  eliminate?: Record<string, number>;
}

// ─── Colonne ────────────────────────────────────────────────────────────────

const siNo = (nome: string, titolo: string, soloScheda = false): ColonnaMeta => ({
  nome,
  titolo,
  tipo: 'siNo',
  soloScheda,
});

export const COLONNE_DATASET: ColonnaMeta[] = [
  { nome: 'DATASET', titolo: 'Dataset', tipo: 'testo' },
  { nome: 'CAPTION', titolo: 'Titolo', tipo: 'testo' },
  { nome: 'PK_FIELDS', titolo: 'Chiave primaria', tipo: 'testo' },
  { nome: 'RELATION_NAME', titolo: 'Tabella', tipo: 'testo' },
  { nome: 'SEQUENCE_NAME', titolo: 'Sequenza', tipo: 'testo' },
  siNo('CAN_INSERT', 'Inserimento'),
  siNo('CAN_UPDATE', 'Modifica'),
  siNo('CAN_DELETE', 'Cancellazione'),
  { nome: 'SQL_SELECT', titolo: 'SELECT', tipo: 'memo' },
  { nome: 'SQL_COUNT', titolo: 'COUNT', tipo: 'memo' },
  { nome: 'SQL_INSERT', titolo: 'INSERT', tipo: 'memo' },
  { nome: 'SQL_UPDATE', titolo: 'UPDATE', tipo: 'memo' },
  { nome: 'SQL_DELETE', titolo: 'DELETE', tipo: 'memo' },
  siNo('GRID_ALLOW_VIEW', 'Consultazione'),
  {
    nome: 'GRID_EDIT_MODE',
    titolo: 'Modo di modifica',
    tipo: 'dominio',
    dominio: 'BASE_WEB_GRID_EDIT_MODE',
  },
  siNo('GRID_USE_FORM_EDIT', 'Modifica nella scheda'),
  siNo('GRID_CONFIRM_DELETE', 'Conferma cancellazione'),
  {
    nome: 'GRID_SELECTION_MODE',
    titolo: 'Selezione',
    tipo: 'dominio',
    dominio: 'BASE_WEB_GRID_SELECTION_MODE',
  },
  {
    nome: 'GRID_SELECTION_CHECKBOX',
    titolo: 'Caselle di selezione',
    tipo: 'dominio',
    dominio: 'BASE_WEB_GRID_SELECTION_CHECKBOX',
  },
  {
    nome: 'GRID_SELECTION_SELECTALL',
    titolo: 'Seleziona tutto',
    tipo: 'dominio',
    dominio: 'BASE_WEB_GRID_SELECTION_SELECTALL',
  },
  siNo('GRID_EXPORT_ENABLED', 'Esportazione'),
  siNo('GRID_EXPORT_SELECTED', 'Esporta selezionate'),
  { nome: 'GRID_EXPORT_FILENAME', titolo: 'Nome del file esportato', tipo: 'testo' },
  {
    nome: 'GRID_EXPORT_FORMATS',
    titolo: 'Formati di esportazione',
    tipo: 'dominio',
    dominio: 'BASE_WEB_GRID_EXPORT_FORMATS',
  },
  { nome: 'GRID_PAGE_SIZE', titolo: 'Righe per pagina', tipo: 'intero' },
  { nome: 'GRID_PAGE_SIZES', titolo: 'Righe per pagina ammesse', tipo: 'testo' },
  { nome: 'FORM_COL_COUNT', titolo: 'Colonne della scheda', tipo: 'intero' },
  {
    nome: 'FORM_LABEL_LOC',
    titolo: 'Posizione etichette',
    tipo: 'dominio',
    dominio: 'BASE_WEB_FORM_LABEL_LOC',
  },
  siNo('FORM_LABEL_COLON', 'Due punti dopo le etichette'),
  {
    nome: 'FORM_LAYOUT',
    titolo: 'Impaginazione',
    tipo: 'dominio',
    dominio: 'BASE_WEB_FORM_LAYOUT',
  },
  { nome: 'FORM_WIDTH', titolo: 'Larghezza scheda', tipo: 'intero' },
  { nome: 'FORM_HEIGHT', titolo: 'Altezza scheda', tipo: 'intero' },
  { nome: 'NOTE', titolo: 'Note', tipo: 'memo' },
];

/** Le cinque istruzioni SQL del dataset: viaggiano in Base64 verso zServer. */
export const COLONNE_SQL = ['SQL_SELECT', 'SQL_COUNT', 'SQL_INSERT', 'SQL_UPDATE', 'SQL_DELETE'];

export const SEZIONE_CAMPI: SezioneMeta = {
  sezione: 'fields',
  chiave: 'FIELD',
  colonne: [
    { nome: 'FIELD', titolo: 'Campo', tipo: 'testo' },
    { nome: 'FIELD_ORIGIN', titolo: 'Origine', tipo: 'testo' },
    { nome: 'CAPTION', titolo: 'Titolo', tipo: 'testo' },
    siNo('REQUIRED', 'Obbligatorio'),
    siNo('READONLY', 'Sola lettura'),
    { nome: 'EDITOR_TYPE', titolo: 'Editor', tipo: 'dominio', dominio: 'BASE_WEB_EDITOR_TYPE' },
    { nome: 'PICKLIST', titolo: 'Picklist', tipo: 'elenco', elenco: 'picklists' },
    { nome: 'LOOKUP', titolo: 'Lookup', tipo: 'elenco', elenco: 'lookups' },
    { nome: 'FORM_PLACEHOLDER', titolo: 'Segnaposto', tipo: 'testo', soloScheda: true },
    { nome: 'FORM_HELP_TEXT', titolo: 'Aiuto', tipo: 'testo', soloScheda: true },
    { nome: 'FIELDS_2_CLEAR', titolo: 'Campi da svuotare', tipo: 'testo', soloScheda: true },
    { nome: 'EDITOR_OPTIONS', titolo: "Opzioni dell'editor (JSON)", tipo: 'memo' },
    { nome: 'VALIDATION', titolo: 'Validazione (JSON)', tipo: 'memo' },
    { nome: 'DEPENDS_ON', titolo: 'Dipendenze (JSON)', tipo: 'memo' },
  ],
  colonneCustom: [
    'CAPTION',
    'REQUIRED',
    'READONLY',
    'FIELDS_2_CLEAR',
    'EDITOR_TYPE',
    'FORM_PLACEHOLDER',
    'FORM_HELP_TEXT',
    'EDITOR_OPTIONS',
    'VALIDATION',
    'DEPENDS_ON',
  ],
};

const COLONNE_GRIGLIA: ColonnaMeta[] = [
  { nome: 'FIELD', titolo: 'Campo', tipo: 'testo' },
  { nome: 'CAPTION', titolo: 'Titolo', tipo: 'testo' },
  { nome: 'DATA_TYPE', titolo: 'Tipo', tipo: 'dominio', dominio: 'BASE_WEB_DATA_TYPE' },
  { nome: 'BAND_NAME', titolo: 'Fascia', tipo: 'elenco', elenco: 'bands' },
  { nome: 'SORT_ORDER', titolo: 'Ordine', tipo: 'intero', larghezza: 80 },
  siNo('VISIBLE', 'Visibile'),
  siNo('FIXED', 'Fissa'),
  {
    nome: 'FIXED_POSITION',
    titolo: 'Lato fisso',
    tipo: 'dominio',
    dominio: 'BASE_WEB_FIXED_POSITION',
  },
  { nome: 'WIDTH', titolo: 'Larghezza', tipo: 'intero', larghezza: 90 },
  { nome: 'MIN_WIDTH', titolo: 'Larghezza minima', tipo: 'intero', soloScheda: true },
  { nome: 'ALIGNMENT', titolo: 'Allineamento', tipo: 'dominio', dominio: 'BASE_WEB_ALIGN' },
  { nome: 'FORMAT_STR', titolo: 'Formato', tipo: 'testo' },
  { nome: 'GROUP_INDEX', titolo: 'Raggruppamento', tipo: 'intero', soloScheda: true },
  {
    nome: 'SUMMARY_TYPE',
    titolo: 'Riepilogo',
    tipo: 'dominio',
    dominio: 'BASE_WEB_SUMMARY_TYPE',
  },
  siNo('ALLOW_FILTER', 'Filtro', true),
  siNo('ALLOW_SORT', 'Ordinamento', true),
  siNo('ALLOW_GROUP', 'Raggruppabile', true),
  siNo('ALLOW_RESIZE', 'Ridimensionabile', true),
  siNo('ALLOW_REORDER', 'Spostabile', true),
  siNo('ALLOW_HIDING', 'Nascondibile', true),
  siNo('HEADER_FILTER', 'Filtro nell’intestazione', true),
  siNo('WORD_WRAP', 'A capo', true),
  siNo('ENCODE_HTML', 'Codifica HTML', true),
  { nome: 'CSS_CLASS', titolo: 'Classe CSS', tipo: 'testo', soloScheda: true },
];

export const SEZIONE_COLONNE_GRIGLIA: SezioneMeta = {
  sezione: 'gridColumns',
  chiave: 'FIELD',
  colonne: COLONNE_GRIGLIA,
  colonneCustom: COLONNE_GRIGLIA.map((c) => c.nome).filter((n) => n !== 'FIELD'),
};

const COLONNE_CAMPI_FORM: ColonnaMeta[] = [
  { nome: 'FIELD', titolo: 'Campo', tipo: 'testo' },
  { nome: 'CONTAINER_NAME', titolo: 'Contenitore', tipo: 'elenco', elenco: 'containers' },
  {
    nome: 'CONTAINER_TYPE',
    titolo: 'Tipo di contenitore',
    tipo: 'dominio',
    dominio: 'BASE_WEB_CONTAINER_TYPE',
  },
  { nome: 'SORT_ORDER', titolo: 'Ordine', tipo: 'intero', larghezza: 80 },
  siNo('VISIBLE', 'Visibile'),
  { nome: 'LABEL_TEXT', titolo: 'Etichetta', tipo: 'testo' },
  { nome: 'COL_SPAN', titolo: 'Colonne occupate', tipo: 'intero', larghezza: 90 },
  siNo('LINEBREAK', 'A capo'),
  siNo('REQUIRED', 'Obbligatorio'),
  { nome: 'PLACEHOLDER', titolo: 'Segnaposto', tipo: 'testo', soloScheda: true },
  { nome: 'HELP_TEXT', titolo: 'Aiuto', tipo: 'testo', soloScheda: true },
  { nome: 'CSS_CLASS', titolo: 'Classe CSS', tipo: 'testo', soloScheda: true },
  { nome: 'EDITOR_OPTIONS', titolo: "Opzioni dell'editor (JSON)", tipo: 'memo' },
];

export const SEZIONE_CAMPI_FORM: SezioneMeta = {
  sezione: 'formFields',
  chiave: 'FIELD',
  colonne: COLONNE_CAMPI_FORM,
  colonneCustom: COLONNE_CAMPI_FORM.map((c) => c.nome).filter((n) => n !== 'FIELD'),
};

export const SEZIONE_LOOKUP: SezioneMeta = {
  sezione: 'lookups',
  chiave: 'LOOKUP',
  colonne: [
    { nome: 'LOOKUP', titolo: 'Lookup', tipo: 'testo' },
    { nome: 'DATASET', titolo: 'Dataset sorgente', tipo: 'elenco', elenco: 'datasets' },
    { nome: 'FK_TABLE', titolo: 'Tabella', tipo: 'testo' },
    { nome: 'VALUE_EXPR', titolo: 'Campo valore', tipo: 'testo' },
    { nome: 'DISPLAY_EXPR', titolo: 'Campo descrizione', tipo: 'testo' },
    { nome: 'PAGESIZE', titolo: 'Righe per pagina', tipo: 'intero' },
    { nome: 'DROPDOWN_WIDTH', titolo: 'Larghezza discesa', tipo: 'intero' },
    { nome: 'PARAMS', titolo: 'Parametri (JSON)', tipo: 'memo' },
    { nome: 'MAPPINGS', titolo: 'Corrispondenze (JSON)', tipo: 'memo' },
  ],
};

export const SEZIONE_COLONNE_LOOKUP: SezioneMeta = {
  sezione: 'lookupColumns',
  chiave: 'FIELD',
  colonne: [
    { nome: 'FIELD', titolo: 'Campo', tipo: 'testo' },
    { nome: 'CAPTION', titolo: 'Titolo', tipo: 'testo' },
    { nome: 'WIDTH', titolo: 'Larghezza', tipo: 'intero' },
    { nome: 'ALIGNMENT', titolo: 'Allineamento', tipo: 'dominio', dominio: 'BASE_WEB_ALIGN' },
  ],
};

// ─── Funzioni di appoggio ───────────────────────────────────────────────────

/** Testo di un valore della riga, vuoto per null e undefined. */
export function testoDi(riga: RigaMeta | null | undefined, colonna: string): string {
  const valore = riga?.[colonna];
  return valore === null || valore === undefined ? '' : String(valore);
}

/**
 * Codifica un testo in Base64 sui byte UTF-16 little endian, come lo decodifica
 * zServer (TEncoding.Unicode). A pezzi, per non superare il limite di argomenti
 * di String.fromCharCode sulle SQL lunghe.
 */
export function base64Utf16(testo: string): string {
  const byte = new Uint8Array(testo.length * 2);
  for (let i = 0; i < testo.length; i++) {
    const codice = testo.charCodeAt(i);
    byte[i * 2] = codice & 0xff;
    byte[i * 2 + 1] = codice >> 8;
  }
  let binario = '';
  const pezzo = 0x8000;
  for (let i = 0; i < byte.length; i += pezzo) {
    binario += String.fromCharCode(...byte.subarray(i, i + pezzo));
  }
  return btoa(binario);
}

/** Salva un testo come file scaricato dal browser. */
export function scaricaTesto(testo: string, nomeFile: string, tipo: string): void {
  const url = URL.createObjectURL(new Blob([testo], { type: tipo }));
  const collegamento = document.createElement('a');
  collegamento.href = url;
  collegamento.download = nomeFile;
  collegamento.click();
  URL.revokeObjectURL(url);
}
