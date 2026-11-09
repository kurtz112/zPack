// Indirizzo di base di zServer: l'unico punto da cui i servizi e il motore
// zz-* leggono l'URL. Il valore viene dalla configurazione dell'installazione
// (config.json, altrimenti i predefiniti passati dall'applicazione), gia'
// letta in main.ts prima dell'avvio: vedi configurazione.ts.
import { Injectable } from '@angular/core';

import { configurazione } from './configurazione';

@Injectable({ providedIn: 'root' })
export class UrlService {
  readonly baseUrl: string = configurazione().apiUrl;
}
