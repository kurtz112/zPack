import dxNumberBox from 'devextreme/ui/number_box';

// Campi interi: un campo che alimenta una colonna INTERO (chilometri, quantita',
// conteggi) non accetta ne' virgola ne' punto. L'interfaccia li blocca mentre si
// digita e arrotonda quello che si incolla: arrotondare in silenzio al momento del
// salvataggio farebbe registrare "125.001" a chi ha scritto "125000,5".
// Lo usano la direttiva ZzInteriDirective (dx-number-box nei modelli) e il motore
// zz-* (schede e griglie dai metadati) con lo stesso codice.

/** Formato di visualizzazione di un campo intero: migliaia, nessun decimale. */
export const FORMATO_INTERO = '#,##0';

/** Tipi Firebird (FIELD_TYPE_STR di BASE.DATA_DICTIONARY) che memorizzano numeri interi. */
const TIPI_INTERI = new Set(['SHORT', 'LONG', 'INT64', 'INT128']);

/**
 * Vero se la colonna e' un intero senza decimali: tipo intero di Firebird e nessun
 * decimale (un NUMERIC(18,2) e' memorizzato come INT64 ma ha fieldDecimals).
 */
export function colonnaIntera(tipoCampo: string | undefined, decimali: number | undefined): boolean {
  return !!tipoCampo && TIPI_INTERI.has(tipoCampo.toUpperCase()) && !(decimali && decimali > 0);
}

/**
 * Converte un testo incollato in un intero arrotondato, oppure null se non e' un numero.
 * Accetta la scrittura italiana ("125.000,5": punto delle migliaia, virgola dei decimali)
 * e quella con il punto decimale ("125000.5"). Un solo punto seguito da tre cifre
 * ("125.000") e' un separatore di migliaia.
 */
export function testoAIntero(testo: string | null | undefined): number | null {
  let valore = (testo ?? '').replace(/[\s ]/g, '');
  if (!/^[+-]?[\d.,]+$/.test(valore)) return null;
  if (valore.includes(',')) {
    valore = valore.replace(/\./g, '').replace(',', '.');
  } else if (/^[+-]?\d{1,3}(\.\d{3})+$/.test(valore)) {
    valore = valore.replace(/\./g, '');
  }
  const numero = Number(valore);
  return Number.isFinite(numero) ? Math.round(numero) : null;
}

/**
 * Rende intero un dxNumberBox gia' creato: blocca virgola e punto mentre si digita
 * (tastiera, tastiera del telefono), arrotonda l'incollato e porta a intero ogni
 * valore con decimali che arrivi in altro modo (trascinato, assegnato dal programma).
 * Restituisce la funzione che toglie i gestori.
 */
export function agganciaCampoIntero(elemento: HTMLElement, istanza: dxNumberBox): () => void {
  const alTasto = (evento: KeyboardEvent): void => {
    if (evento.ctrlKey || evento.metaKey) return;
    if (evento.key === ',' || evento.key === '.' || evento.key === 'Decimal') evento.preventDefault();
  };
  // tastiere dei telefoni: il tasto arriva come "Unidentified", il testo solo qui
  const primaDelTesto = (evento: InputEvent): void => {
    if (evento.inputType === 'insertText' && evento.data && /[.,]/.test(evento.data)) evento.preventDefault();
  };
  const alIncolla = (evento: ClipboardEvent): void => {
    evento.preventDefault();
    evento.stopPropagation();
    const valore = testoAIntero(evento.clipboardData?.getData('text'));
    if (valore !== null) istanza.option('value', valore);
  };
  const alCambio = (evento: { value?: unknown }): void => {
    const valore = evento.value;
    if (typeof valore === 'number' && !Number.isInteger(valore)) istanza.option('value', Math.round(valore));
  };

  // in cattura: prima dei gestori di DevExtreme, che altrimenti inserirebbero il carattere
  elemento.addEventListener('keydown', alTasto, true);
  elemento.addEventListener('beforeinput', primaDelTesto as EventListener, true);
  elemento.addEventListener('paste', alIncolla as EventListener, true);
  istanza.on('valueChanged', alCambio);

  return () => {
    elemento.removeEventListener('keydown', alTasto, true);
    elemento.removeEventListener('beforeinput', primaDelTesto as EventListener, true);
    elemento.removeEventListener('paste', alIncolla as EventListener, true);
    istanza.off('valueChanged', alCambio);
  };
}
