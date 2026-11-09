// Configurazione di DevExtreme comune ad Agorà e GestyWeb, da chiamare in
// main.ts prima dell'avvio: aspetto degli editor, valuta, testi in italiano,
// griglie e popup su tablet e telefono. La chiave di licenza resta
// dell'applicazione (devextreme-license.ts, generata dal suo
// strumenti\genera-chiave-devextreme.cmd) ed entra per parametro.
//
// La griglia non si importa qui: devextreme/ui/data_grid porta con se' circa
// 1 MB di codice (griglia, costruttore di filtri, assistente IA) e da main.ts
// finiva nel caricamento iniziale anche delle pagine che non hanno griglie.
// Le sue impostazioni predefinite si applicano appena il modulo e' arrivato,
// in parallelo all'avvio (vedi configuraDevExtreme).
import config from 'devextreme/core/config';
import { loadMessages, locale } from 'devextreme/localization';
import itMessages from 'devextreme/localization/messages/it.json';
import Popup from 'devextreme/ui/popup';

export interface OpzioniDevExtreme {
  /** Chiave di esecuzione dell'applicazione. */
  licenseKey: string;
  /** Aspetto degli editor; predefinito 'outlined', il bordo su tutti i lati. */
  editorStylingMode?: 'outlined' | 'filled' | 'underlined';
}

/**
 * Imposta DevExtreme. La promessa si risolve quando anche le impostazioni della
 * griglia sono applicate: l'applicazione di norma non la aspetta, perche'
 * nessuna griglia nasce prima che l'utente abbia fatto l'accesso, e il modulo
 * della griglia (lo stesso che le pagine importano) arriva molto prima.
 */
export function configuraDevExtreme(opzioni: OpzioniDevExtreme): Promise<void> {
  config({
    licenseKey: opzioni.licenseKey,
    editorStylingMode: opzioni.editorStylingMode ?? 'outlined',
    defaultCurrency: 'EUR',
  });

  // senza il dizionario i testi di DevExtreme (Salva, Annulla, Nessun dato...) restano in inglese
  loadMessages(itMessages);
  locale('it');

  // Tablet e telefono: le griglie nascondono le colonne che non ci stanno (si leggono nella
  // riga di dettaglio "...") invece di scorrere di lato. Il testo va a capo: la griglia
  // misura ogni colonna sul suo testo e, senza a capo, una descrizione lunga basta a far
  // nascondere tutto il resto. La regola si valuta alla creazione di ogni griglia; sopra
  // i 1280 px resta lo scorrimento di sempre. Quanto una griglia imposta nel proprio
  // template vince su questa regola.
  const griglia = import('devextreme/ui/data_grid').then(({ default: DataGrid }) => {
    DataGrid.defaultOptions({
      device: () => window.matchMedia('(max-width: 1279.98px)').matches,
      options: { columnHidingEnabled: true, wordWrapEnabled: true },
    });
  }).catch((errore: unknown) => {
    // Senza rete il modulo non arriva: le griglie non si aprirebbero comunque,
    // e l'avvio non deve fermarsi per questo
    console.error('Impostazioni della griglia DevExtreme non applicate', errore);
  });

  // Nessun popup piu' largo dello schermo: la larghezza fissata da ciascuno (350-425 px)
  // resta quella di sempre, ma sul telefono si ferma a 12 px dai bordi
  Popup.defaultOptions({
    options: { maxWidth: 'calc(100vw - 24px)' },
  });

  return griglia;
}
