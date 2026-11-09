# zNg

Libreria Angular comune ad Agorà, GestyWeb e ai prodotti futuri: per i siti è quello che zPack è per i programmi Delphi. Una correzione si fa qui una volta sola e vale per tutte le applicazioni.

## Come la vede un'applicazione

zNg non si installa con npm e non ha `package.json` né `node_modules`: la compila ogni applicazione insieme ai propri sorgenti, con i pacchetti del proprio `node_modules`.

| Dove | Cosa |
|---|---|
| giunzione `zng` nella cartella del progetto | `mklink /J <progetto>\zng <zPack>\zNg`, una per ogni posto in cui il progetto vive (produzione, copia di prova) |
| `tsconfig` | `"@zng/*": ["./zng/*"]` in `paths`, `"zng/**/*.ts"` in `include` |
| `angular.json` | `"preserveSymlinks": true` nelle opzioni di `build`: senza, il compilatore segue la giunzione fino alla cartella vera, che non ha `node_modules`, e si ferma |
| `.gitignore` | `zng/`: la storia di zNg sta nel repository di zPack |
| zBuilder | `zng` fra le cartelle escluse Angular, altrimenti la copia in `SRC` duplica zNg dentro ogni progetto; `zNg` fra gli elementi aggiuntivi della voce di zPack |

Gli import si scrivono sempre `@zng/...` (`import { UrlService } from '@zng/core/services/url.service'`).

## Regole

- **zNg non importa mai dall'applicazione**: niente `@env/*`, `@core/*`, `@shared/*`. Quello che serve all'applicazione entra per parametro (i predefiniti di `caricaConfigurazione`) o per token di iniezione.
- Dentro zNg gli import fra file sono relativi o `@zng/...`.
- Niente file ponte con `export *` nelle applicazioni: un file spostato qui sparisce dall'applicazione.
- Ogni rilascio aggiunge una riga a `VERSIONE.md`.
- Una modifica di zNg va compilata in tutte le applicazioni prima del sigillo, e dopo l'integrazione le applicazioni vanno ricompilate e distribuite: zBuilder non lo segnala da solo.

## Contenuto

| Cartella | Cosa |
|---|---|
| `core/services/configurazione.ts` | Configurazione dell'installazione: predefiniti dall'applicazione, `config.json` accanto a `index.html`; per le app sul telefono `impostaIndirizzoServer()` (indirizzo di zServer scelto sul dispositivo, vince su `config.json`) e `normalizzaIndirizzoServer()` |
| `core/services/url.service.ts` | Indirizzo di zServer (`UrlService.baseUrl`) |
| `core/services/zserver.service.ts` | `ZServerService`: CustomStore per griglie e caselle a discesa, `leggi()`, rotte JSON, stored procedure |
| `core/interceptors/errore-silenzioso.ts` | Token `ERRORE_SILENZIOSO`: richieste il cui errore non va notificato; lo legge `errorInterceptor` |
| `core/services/accesso.config.ts` | Token `ZZ_ACCESSO_CONFIG` e `fornisciConfigurazioneAccesso(...)`: pagina di login, pagina iniziale, pagine di accesso, nome dell'applicazione, avviso modale sugli errori di scrittura e sua frase sulla chiave esterna. Senza provider valgono i predefiniti (login su `/login`) |
| `core/services/auth.service.ts`, `core/models/auth.models.ts` | `AuthService`: login JWT su zServer, rinnovo, logout, cambio password (`cambiaPassword()`), token in `sessionStorage`. Un'applicazione con altri metodi la estende e la fornisce con `{ provide: AuthService, useExisting: <classe> }` (Agorà) |
| `core/accesso/zz-cambio-password.component.ts` | `<zz-cambio-password />`: modulo di cambio della password dell'utente collegato (attuale, nuova, conferma) con l'errore del server sotto il modulo. Titolo e riquadro restano della pagina dell'applicazione |
| `core/guards` | `authGuard` (sessione, rinnovo, pagine di accesso, pagina da riaprire) e `metadatiGuard` (autorizzazione `BASE_WEB_METADATI`, da mettere dopo `authGuard`) |
| `core/interceptors/auth.interceptor.ts`, `error.interceptor.ts` | Token nelle richieste e rinnovo sul 401; errori del server trasformati in `AppError` (`core/models/app-error.model.ts`) e mostrati (notifica, avviso modale sulle scritture). Ordine in `app.config.ts`: `withInterceptors([authInterceptor, errorInterceptor])` |
| `core/services/registro-errori.ts`, `diagnostica.ts`, `segnalazioni.service.ts` | Registro degli ultimi errori (`RegistroErroriHandler` come `ErrorHandler`; in sviluppo notifica copiabile, Ctrl+Maiusc+E, `<nome>Errori()` in console), dati tecnici e segnalazione all'assistenza tramite zServer, verificata da sola a ogni accesso |
| `core/services/accesso-metadati.service.ts` | Se l'utente puo' aprire l'editor dei metadati (`GET /api/meta/access`) |
| `core/services/devextreme.ts` | `configuraDevExtreme({ licenseKey })` da `main.ts`: editor `outlined`, euro, testi in italiano, griglie e popup per tablet e telefono |
| `core/services/tema.service.ts`, `tema.config.ts` | `TemaService`: tema chiaro e scuro (`tema()`, `scuro()`, `cambiaTema()`), ricordato dal browser e allineato fra le schede. `fornisciConfigurazioneTema(...)` in `app.config.ts`: chiave di memoria, tema iniziale (o del sistema), fogli DevExtreme da scambiare se l'applicazione ne ha uno per tema |
| `core/components`, `core/helper`, `core/models`, servizi del motore in `core/services` | Motore zz-* (griglia, scheda, ricerca dai metadati BaseWeb), con versione propria in `core/components/VERSIONE.md`; il ruolo dell'utente lo legge dall'`AuthService` di zNg (`ZZ_RUOLO_UTENTE`, sostituibile in `app.config.ts`) |
| `core/directives/zz-interi.directive.ts`, `core/helper/campo-intero.ts` | Campi interi: `<dx-number-box zzInteri>` non accetta virgola ne' punto (blocca mentre si digita, arrotonda l'incollato). Da usare per ogni casella che alimenta una colonna INTERO; il motore zz-* lo applica da solo alle colonne intere dei metadati |
| `core/models/menu.models.ts` | `VoceMenu` e `vociMenuVisibili()`: forma delle voci del menu laterale e voci riservate all'editor dei metadati. Il menu resta dell'applicazione |
| `zz/meta-editor` | Editor dei metadati di BaseWeb (versione propria in `zz/meta-editor/VERSIONE.md`) |

Analisi: `D:\AI\OUT\20261028-libreria-angular-zng\`.
