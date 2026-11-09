/**
 * Regole di colore di una colonna di zz-data-grid (input `regoleColore`).
 * La chiave e' il nome del campo del dataset.
 */

/** Tonalita' disponibili: la griglia le traduce in un colore leggibile su tema chiaro e scuro. */
export type TonalitaColore = 'positivo' | 'attenzione' | 'negativo' | 'neutro';

/** Colora il numero per segno: negativo in rosso, positivo in verde, zero senza colore. */
export interface RegolaColoreSegno {
  tipo: 'segno';
  /** Con vero i colori si scambiano: positivo in rosso (un importo ancora da incassare), negativo in verde. */
  invertito?: boolean;
}

/** Colora il testo secondo il valore della cella (confronto senza maiuscole e spazi ai lati). */
export interface RegolaColoreMappa {
  tipo: 'mappa';
  mappa: Record<string, TonalitaColore>;
  /** Tonalita' dei valori non in mappa; senza, restano senza colore. */
  altri?: TonalitaColore;
  /** Con vero un cerchio colorato precede il testo, che resta del colore normale. */
  cerchio?: boolean;
}

/**
 * Mette in rilievo una data gia' passata la cui riga ha ancora un importo da incassare
 * (scadenza scaduta e non pagata): testo rosso in grassetto.
 */
export interface RegolaColoreScaduto {
  tipo: 'scaduto';
  /** Campo (o campi, il primo presente nella riga) con l'importo ancora aperto. */
  saldo: string | string[];
}

export type RegolaColore = RegolaColoreSegno | RegolaColoreMappa | RegolaColoreScaduto;
