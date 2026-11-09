# Motore zz-* (zz-data-grid, zz-form, zz-lookup)

Griglia, scheda e ricerca costruite dai metadati BaseWeb di zServer (`GET /api/data/{dataset}/metadata`).

Dalla 2.0.0 il motore sta in zNg, una copia sola per tutte le applicazioni: si importa da `@zng/core/...`. Una correzione si fa qui e va compilata in tutte le applicazioni prima del rilascio (copie di prova in SandBox con `zng` in giunzione, DevExtreme 26.1).

## File del motore
| Cartella di zNg | File |
|---|---|
| `core\components` | `index.ts`, `zz-data-grid\*`, `zz-form\*` (`dependency-engine.ts`, `design-menu.builder.ts`, `form-focus-tracker.ts`), `zz-lookup\*` |
| `core\services` | `avviso.ts`, `form-items-builder.service.ts`, `lookup.helper.service.ts`, `metadata.service.ts`, `metadata-patch.service.ts`, `user-capabilities.service.ts` |
| `core\helper` | `menu-builder.ts`, `campo-intero.ts` |
| `core\models` | `action-button.model.ts`, `metadata.models.ts` |

Usa anche, sempre da zNg, `ZServerService`, `UrlService` e `zz\meta-editor` (`ZzMetaInLocoService`, `PREFISSO_CLASSE_CAMPO`).

## Cosa l'applicazione deve fornire
- niente per il ruolo, se l'accesso e' l'`AuthService` di zNg: `ZZ_RUOLO_UTENTE` restituisce da solo il `tipo_user` del token e decide strumenti di progettazione, esportazione e scrittura (`UserCapabilitiesService`). Un'applicazione con un altro accesso lo fornisce in `app.config.ts`, con una funzione che legge un signal e restituisce stringa vuota se nessuno e' collegato;
- il pacchetto `jspdf` (esportazione PDF della griglia) e l'import di `devextreme/ui/color_box` in `main.ts` (editor `dxColorBox` delle schede);
- un intercettore HTTP che mostra gli errori del server e li rilancia come `AppError` (`isAppError: true`): il motore non li mostra una seconda volta.

## Regole
- I booleani non sono mai obbligatori, qualunque cosa dicano i metadati (`isBooleanField`, `validationRulesOf`): la regola required di DevExtreme rifiuta `false`.
- Gli errori che fermano un'operazione vanno in `mostraAvviso` (avviso modale), non in una notifica.

## Versioni
| Versione | Data | Contenuto |
|---|---|---|
| 2.5.0 | 2026-11-04 | Colonne intere (`column.fieldType` Firebird intero e senza `fieldDecimals`): l'editor di scheda e di griglia non accetta virgola ne' punto e arrotonda l'incollato (`core/helper/campo-intero.ts`, ZNG-SCH-016). BASE_WEB emette `fieldType` dal rilascio `OUT/20261104-base-web-fieldtype/001` (script `WT-BASE-WEB-12` e `GESTY-BASE-WEB-12`, che rigenerano i metadati): finche' lo script non e' applicato a un database, il motore non cambia comportamento su quel database |
| 2.4.0 | 2026-11-03 | `zz-data-grid`: uscita `righeMostrate` (`{ chiave, righe }`) a ogni contenuto pronto: primo caricamento, filtri, ricerca, ordinamento, pagina, rilettura. Serve alla pagina per togliere la riga scelta quando la griglia non la mostra piu'. Facoltativa: chi non la ascolta non vede cambiamenti. Nata in Pipa |
| 2.3.0 | 2026-11-03 | `zz-data-grid`: input `regoleColore` (colore per colonna: `segno`, anche invertito, `mappa` valore-colore con cerchio facoltativo, `scaduto` per date passate con importo aperto; tipi in `core/models/regola-colore.model.ts`) e griglia senza righe con icona e testo (`testoVuoto`, `iconaVuota`; con filtri o ricerca attivi "Nessun risultato" e pulsante "Togli i filtri"; altrimenti "Nessun dato da mostrare"). Tutto facoltativo: senza i nuovi input cambia solo il testo della griglia vuota. Nata in Pipa |
| 2.2.0 | 2026-11-03 | `zz-data-grid` ha l'opzione `compatta` (predefinita spenta, nessun cambiamento per chi non la usa): toglie la casella di ricerca, la riga dei filtri per colonna e dalla barra i pulsanti (filtri avanzati, esportazione, gestione colonne), e nasconde la barra se non ha altro da mostrare (pulsante Nuovo, pulsanti propri). Le stesse voci restano nel menu del tasto destro. Per le griglie di dettaglio sotto un elenco. Nata in Pipa |
| 2.1.0 | 2026-10-28 | `ZZ_RUOLO_UTENTE` ha un valore predefinito: il `tipo_user` dell'`AuthService` di zNg, entrato in zNg con l'accesso (zNg 1.3.0). Le applicazioni non lo forniscono piu' |
| 2.0.0 | 2026-10-28 | Il motore passa in zNg (`zPack\zNg\core`), import da `@zng/core/...`. Il ruolo dell'utente non arriva piu' dall'`AuthService` dell'applicazione ma dal token `ZZ_RUOLO_UTENTE`, che l'applicazione fornisce |
| 1.1.6 | 2026-10-28 | Casella con l'etichetta accanto nelle schede a etichette sopra il campo (`CLASSE_CAMPO_CASELLA`, `zz-campo-casella`): prima restava un quadratino da solo all'altezza delle etichette; ora ha il testo accanto ed e' allineata ai campi della riga. Non per `dxSwitch`. Nata in Agorà, ora anche in GestyWeb |
| 1.1.5 | 2026-10-28 | Scheda in finestra: margine interno di 20 px (prima i campi toccavano i bordi), bordo normale per i campi non modificabili (non piu' tratteggiato), regola del tema scuro per sfondo e bordi dei campi, bordo del piede dei pulsanti dal tema. Il motore chiede all'applicazione di importare `devextreme/ui/color_box` in `main.ts` (editor `dxColorBox` delle schede) |
| 1.1.4 | 2026-10-28 | Indirizzo di zServer solo da `UrlService.baseUrl` (scheda, griglia, ricerca), non piu' da `environment.apiUrl`: segue il `config.json` dell'installazione |
| 1.1.3 | 2026-10-27 | Decodifica dei campi collegati con il filtro sulla chiave (scheda e griglia): prima chiedeva a zServer una rotta che non esiste e la casella restava vuota. Campi collegati di sola lettura davvero non modificabili e mostrati come tali. Avviso dei campi non validi con il nome del campo ("Nome: obbligatorio") e con il margine interno |
| 1.1.0 | 2026-10-27 | Prima copia in Agorà. Booleani mai obbligatori (scheda, griglia, menu di progettazione). Chiave di sola lettura in modifica e campi di sola lettura visibili come tali (sfondo grigio, bordo tratteggiato, "(non modificabile)"). Avviso modale per i campi non validi al salvataggio, con il fuoco sul primo, e per gli errori di salvataggio e di cancellazione non già mostrati dall'intercettore |
| 1.0.0 | — | Il motore com'era in GestyWeb fino al 2026-10-25 |
