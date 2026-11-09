/**
 * Interfacce TypeScript per il JSON generato da BASE_WEB.LOAD_DATASET_METADATA.
 * Aggiornate per supportare la gerarchia form V8 (items tree).
 */

// ═══ Root ═══

export interface DatasetMetadata {
  datasetId: string;
  primaryKey: string;
  caption: string;
  fields: FieldMetadata[];
  gridSettings: GridSettings;
  formSettings: FormSettings;
  masterDetail?: MasterDetailConfig;
}

// ═══ Field ═══

export interface FieldMetadata {
  dataField: string;
  caption: string;
  dataType: 'string' | 'number' | 'date' | 'datetime' | 'time' | 'boolean';
  isPrimaryKey?: boolean;
  column: ColumnConfig;
  control: ControlConfig;
  lookup?: LookupConfig;
  picklist?: PicklistConfig;
  fields2Clear?: string; // Mantenuto per retrocompatibilità, ma ora generato dentro column
  pageSize?: number;
}

// ═══ Column (proprietà Grid) ═══

export interface ColumnConfig {
  caption?: string;
  band?: string; // @@aggiunto (V8)
  visible?: boolean;
  sortOrder: number;
  alignment: 'left' | 'center' | 'right';
  allowEditing?: boolean;
  allowFiltering?: boolean;
  allowSorting: boolean;
  allowResizing?: boolean; // @@aggiunto (V8)
  allowReordering?: boolean; // @@aggiunto (V8)
  allowHiding?: boolean; // @@aggiunto (V8)
  allowGrouping?: boolean; // @@aggiunto (V8)
  showEditorAlways?: boolean; // @@aggiunto (V8)
  width?: number; // @@aggiunto (V8)
  minWidth?: number;
  format?: string;
  fixed?: boolean;
  fixedPosition?: 'left' | 'right';
  groupIndex?: number;
  summaryType?: 'sum' | 'avg' | 'count' | 'min' | 'max';
  fieldSize?: number;
  fieldDecimals?: number;
  /** Tipo Firebird della colonna (FIELD_TYPE_STR: SHORT, LONG, INT64, ...). Con i tipi interi e senza fieldDecimals il campo e' un intero. */
  fieldType?: string;
  cssClass?: string; // @@aggiunto (V8)
  wordWrap?: boolean; // @@aggiunto (V8)
  encodeHtml?: boolean; // @@aggiunto (V8)
  fields2Clear?: string; // @@aggiunto (V8 - posizionamento fixato)
  linebreak?: boolean;
}

// ═══ Control (proprietà Form) ═══

export interface ControlConfig {
  editorType: string;       // dxTextBox, dxNumberBox, dxDateBox, dxSelectBox, ...
  container?: string;       // @@aggiunto (V8)
  visible?: boolean;
  sortOrder: number;        // ordine nel form (CARD_INDEX)
  readOnly?: boolean;
  required?: boolean;
  colSpan?: number;
  label?: string;           // @@aggiunto (V8)
  placeholder?: string;
  helpText?: string;
  editorOptions?: Record<string, any>;
  validation?: ValidationRule[];
  dependsOn?: DependencyRule[];
  cardIndex?: number;
  lineBreak?: boolean;      // @@aggiunto
}

// ═══ Validation ═══

export interface ValidationRule {
  type: 'required' | 'email' | 'numeric' | 'pattern' | 'stringLength' | 'range' | 'compare' | 'custom';
  message?: string;
  pattern?: string;
  min?: number;
  max?: number;
}

// ═══ Dependency ═══

export interface DependencyRule {
  sourceField: string;
  action: 'show' | 'hide' | 'enable' | 'disable' | 'require' | 'setValue';
  condition: {
    operator: '==' | '!=' | '>' | '<' | '>=' | '<=' | 'contains' | 'notEmpty' | 'empty';
    value?: any;
  };
  targetValue?: any;
}

// ═══ Lookup ═══

export interface LookupColumn {
  field: string;
  caption: string;
  width?: number;
  alignment?: 'left' | 'center' | 'right';
}
export interface LookupConfig {
  name: string;
  dataset: string;        // dataset collegato per caricare i dati lookup
  fkTable: string;
  valueExpr: string;
  displayExpr: string;
  params?: string;
  mappings?: string;
  filter?: string; // @@aggiunto
  pageSize?: number; // @@aggiunto
  dropDownWidth?: number;
  columns?: LookupColumn[]; // reso opzionale per evitare crash se il DB non lo fornisce
}

// ═══ Picklist ═══

export interface PicklistConfig {
  name: string;
  items: PicklistItem[];
  hasIcons?: boolean;
}

export interface PicklistItem {
  value: string;
  text: string;
  icon?: string;
}

// ═══ Grid Settings ═══

export interface GridSettings {
  editing: {
    mode: 'popup' | 'row' | 'batch' | 'cell' | 'form';
    allowAdding: boolean;
    allowUpdating: boolean;
    allowDeleting: boolean;
    allowView?: boolean
    useFormForEdit: boolean;
    confirmDelete: boolean;
  };
  selection: {
    mode: 'none' | 'single' | 'multiple';
    showCheckBoxesMode: 'always' | 'onClick' | 'onLongTap' | 'none';
    selectAllMode: 'allPages' | 'page';
  };
  export: {
    enabled: boolean;
    allowExportSelectedData: boolean;
    fileName?: string;
    formats: string[];
  };
  pageSize: number;
  allowedPageSizes: number[];
  bands?: any[]; // Aggiunto per gestire le bands dinamiche del V8
}

// ═══ Form Settings (Aggiornato per V8 Tree) ═══

export interface FormSettings {
  mode: 'flat' | 'groups' | 'tabs';
  colCount: number;
  labelLocation: 'top' | 'left';
  showColonAfterLabel: boolean;
  width?: number;
  height?: number;
  resizable?: boolean; 
  items?: FormItem[]; // L'albero root generato dal DB
}

// Nuova struttura V8 per i nodi del form

export type FormItem = FormGroupItem | FormTabbedItem | FormSimpleItem | FormEmptyItem | FormButtonItem;

export interface FormItemBase {
  itemType?: string;
  name?: string;
  colSpan?: number;
  visible?: boolean;
  cssClass?: string;
}

export interface FormGroupItem extends FormItemBase {
  itemType: 'group';
  caption?: string;
  icon?: string;
  colCount?: number;
  baseWebCollapsible?: boolean;
  baseWebCollapsed?: boolean;
  items: FormItem[];
}

export interface FormTabbedItem extends FormItemBase {
  itemType: 'tabbed';
  tabPanelOptions?: any;
  tabs: FormTabItem[];
}

export interface FormTabItem {
  title?: string;
  icon?: string;
  badge?: string;
  disabled?: boolean;
  visible?: boolean;
  colSpan?: number;
  cssClass?: string;
  items: FormItem[];
}

export interface FormSimpleItem extends FormItemBase {
  itemType?: undefined | 'simple'; // se non c'è, è assumed as dataField / simple
  dataField: string;
}

export interface FormEmptyItem extends FormItemBase {
  itemType: 'empty';
}

export interface FormButtonItem extends FormItemBase {
  itemType: 'button';
  buttonOptions: any;
}

// ═══ Master-Detail ═══

export interface MasterDetailConfig {
  enabled: boolean;
  autoExpandAll: boolean;
  masterDataset: string;
  mappings?: string;
}
