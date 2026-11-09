// Configurazione dell'installazione: l'unica fonte dei valori che cambiano da
// un server all'altro (indirizzo di zServer e le voci proprie di ciascuna
// applicazione, per esempio la chiave di Google Maps di Agorà).
//
// I valori predefiniti li passa l'applicazione da main.ts, di norma presi da
// environment*.ts: zNg non conosce l'environment di nessuno. Un file
// config.json accanto a index.html, scritto dal sistemista, li sostituisce
// voce per voce, senza ricompilare. Il file si legge in main.ts PRIMA di
// avviare l'applicazione: cosi' ogni servizio trova i valori gia' pronti, senza
// attese e senza dipendere dall'ordine degli inizializzatori.
//
// Il pacchetto distribuito contiene solo config.esempio.json: un
// aggiornamento non sovrascrive mai il config.json dell'installazione.
//
// L'indirizzo di zServer si legge sempre da UrlService.baseUrl (il motore zz-*
// lo chiede con quel nome); configurazione() serve agli altri valori.

// Le voci comuni a ogni applicazione. Un'applicazione con voci proprie estende
// l'interfaccia (tutte testi) e legge con configurazione<LaSua>().
export interface ConfigurazioneInstallazione {
  // Indirizzo del server REST zServer, senza barra finale: assoluto
  // (http://server:8443/api) o relativo al sito (/api, dietro un proxy)
  apiUrl: string;
}

// Da dove vengono i valori: chi controlla un'installazione vede subito se il
// suo config.json e' stato letto (in Agorà la pagina Info). 'dispositivo' =
// indirizzo di zServer scelto sul telefono (impostaIndirizzoServer)
export type OrigineConfigurazione = 'config.json' | 'predefinita' | 'dispositivo';

export const FILE_CONFIGURAZIONE = 'config.json';

let valori: ConfigurazioneInstallazione = { apiUrl: '' };
let origine: OrigineConfigurazione = 'predefinita';
let vociIgnorate: string[] = [];

export function configurazione<
  T extends ConfigurazioneInstallazione = ConfigurazioneInstallazione,
>(): Readonly<T> {
  return valori as T;
}

export function origineConfigurazione(): OrigineConfigurazione {
  return origine;
}

// Le voci di config.json che il programma non conosce (un nome scritto male,
// per esempio "apiURL"): restano senza effetto, e si possono mostrare
export function vociConfigurazioneIgnorate(): readonly string[] {
  return vociIgnorate;
}

// Prende i predefiniti dell'applicazione, poi legge config.json. Senza file
// restano i predefiniti; un file che c'e' ma non e' valido ferma l'avvio con
// il motivo, perche' un'installazione che parte con l'indirizzo sbagliato
// sembra funzionare e poi non trova zServer.
export async function caricaConfigurazione<T extends ConfigurazioneInstallazione>(
  predefiniti: T,
): Promise<void> {
  valori = { ...predefiniti };

  let risposta: Response;
  try {
    // Accanto a index.html (base href), non accanto alla pagina aperta: chi
    // ricarica /anagrafica/123 cercherebbe /anagrafica/config.json
    risposta = await fetch(new URL(FILE_CONFIGURAZIONE, document.baseURI), { cache: 'no-store' });
  } catch {
    return;
  }
  // Un file che manca puo' tornare come 404 o, con la riscrittura degli
  // indirizzi verso index.html (IIS, ng serve), come pagina HTML: in tutti e
  // due i casi non c'e' una configurazione dell'installazione
  const tipo = risposta.headers.get('content-type') ?? '';
  if (!risposta.ok || !tipo.includes('json')) {
    return;
  }

  let letto: unknown;
  try {
    letto = JSON.parse(await risposta.text());
  } catch (errore) {
    throw new Error(`${FILE_CONFIGURAZIONE} non è un JSON valido: ${(errore as Error).message}`, {
      cause: errore,
    });
  }
  if (typeof letto !== 'object' || letto === null || Array.isArray(letto)) {
    throw new Error(`${FILE_CONFIGURAZIONE} deve contenere un oggetto { "apiUrl": "...", ... }`);
  }

  // Le voci ammesse sono quelle dei predefiniti: l'applicazione le dichiara
  // tutte, anche quelle vuote
  const nuovi: Record<string, string> = { ...(valori as unknown as Record<string, string>) };
  const ignorate: string[] = [];
  for (const [nome, valore] of Object.entries(letto)) {
    // Le voci che cominciano con _ sono note per chi legge il file
    if (nome.startsWith('_')) {
      continue;
    }
    if (!(nome in nuovi)) {
      ignorate.push(nome);
      continue;
    }
    if (typeof valore !== 'string') {
      throw new Error(`${FILE_CONFIGURAZIONE}: "${nome}" deve essere un testo fra virgolette`);
    }
    nuovi[nome] = valore.trim();
  }
  const apiUrl = (nuovi['apiUrl'] ?? '').replace(/\/+$/, '');
  if (apiUrl === '') {
    throw new Error(`${FILE_CONFIGURAZIONE}: "apiUrl" non può essere vuoto`);
  }
  nuovi['apiUrl'] = apiUrl;

  valori = nuovi as unknown as ConfigurazioneInstallazione;
  origine = 'config.json';
  vociIgnorate = ignorate;
  if (ignorate.length > 0) {
    console.warn(`${FILE_CONFIGURAZIONE}: voci sconosciute, ignorate: ${ignorate.join(', ')}`);
  }
}

// Indirizzo di zServer scelto sul dispositivo. Serve alle app installate sul
// telefono (GeCo di Pipa), dove l'indirizzo cambia da cliente a cliente e da
// una macchina di prova all'altra e non si puo' compilare nel pacchetto:
// l'applicazione lo legge dalla sua memoria dopo caricaConfigurazione e lo
// passa qui, sempre prima dell'avvio, perche' UrlService lo legge una volta
// sola. Vince su config.json e sui predefiniti. Per cambiarlo in esecuzione
// l'applicazione lo salva e ricarica la pagina.
export function impostaIndirizzoServer(apiUrl: string): void {
  const indirizzo = normalizzaIndirizzoServer(apiUrl);
  if (indirizzo === null) {
    throw new Error(`Indirizzo del server non valido: "${apiUrl}"`);
  }
  valori = { ...valori, apiUrl: indirizzo };
  origine = 'dispositivo';
}

// Da un indirizzo scritto dall'utente a quello di zServer: deve cominciare con
// http:// o https://, senza parametri; se manca il percorso si aggiunge /api,
// e la barra finale si toglie. null = non valido, da far correggere a chi scrive
export function normalizzaIndirizzoServer(testo: string): string | null {
  const scritto = testo.trim();
  if (!/^https?:\/\/[^/]/i.test(scritto)) {
    return null;
  }
  let indirizzo: URL;
  try {
    indirizzo = new URL(scritto);
  } catch {
    return null;
  }
  if (indirizzo.search !== '' || indirizzo.hash !== '' || indirizzo.username !== '') {
    return null;
  }
  const percorso = indirizzo.pathname.replace(/\/+$/, '');
  return `${indirizzo.protocol}//${indirizzo.host}${percorso === '' ? '/api' : percorso}`;
}
