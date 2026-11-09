# zz-meta-editor

Editor dei metadati BaseWeb, sulle rotte `/api/meta` di zServer (`Metadata.Editor.Controller`, rilascio zServer `OUT/20261016-agora-editor-metadati-e-sicurezza/002`).

La cartella è **identica** in Agorà e in GestyWeb: la copia di riferimento è quella di Agorà, GestyWeb la riceve con un rilascio. Prima di un rilascio verso GestyWeb, confrontare le due cartelle e compilare anche in `SandBox\GestyWeb` (DevExtreme 25.2).

## Regole della cartella
- Nessun import dall'applicazione (`environment`, `AuthService`, `zz-form`, `zz-data-grid`): la base delle API arriva da `ZZ_META_EDITOR_CONFIG`, che l'applicazione fornisce nella rotta.
- Solo componenti DevExtreme presenti in 25.2 e 26.1.
- Gli errori HTTP li mostra l'intercettore dell'applicazione; i rifiuti del database (400) si mostrano così come arrivano.

## Uso
```ts
{
  path: 'configurazione/metadati',
  component: MetaEditorComponent,
  providers: [{ provide: ZZ_META_EDITOR_CONFIG, useFactory: () => ({ apiUrl: inject(UrlService).baseUrl + '/meta' }) }],
}
```
Parametri della rotta accettati: `tab` (`datasets`, `lookups`, `picklists`, `trasporto`), `dataset`, `subtab` (`generale`, `campi`, `griglia`, `form`, `anteprima`), `field`. Dentro una finestra gli stessi valori arrivano dagli ingressi `datasetIniziale`, `schedaIniziale`, `campoIniziale`.

## Editor in loco
Una pagina che costruisce griglia e scheda dai metadati (`meta-runtime.ts`: `colonneGrigliaDaMetadati`, `elementiSchedaDaMetadati`) fornisce nella sua rotta `ZZ_META_EDITOR_CONFIG` (con `abilitato`), `MetaEditorService` e `ZzMetaInLocoService`, e mette `<zz-meta-in-loco />` nel suo modello. Poi:
- griglia: `(onContextMenuPreparing)` chiama `vociGriglia(e, dataset, metadati)`; i comandi delle colonne salvano con `PUT /api/meta/datasets/{ds}/grid/columns/{campo}`;
- scheda: sul `contextmenu` del contenuto si chiama `apriMenuScheda(evento, dataset, metadati)`; i comandi salvano con le PATCH di `/api/data/{ds}/metadata/fields` e `/settings`;
- dopo ogni salvataggio, e alla chiusura dell'editor in finestra, il segnale `cambiato` dice quale dataset rileggere.

## Versioni
| Versione | Data | Contenuto |
|---|---|---|
| 1.1.2 | 2026-10-27 | Booleani mai obbligatori (`eBooleano` in `meta-runtime.ts`): niente `isRequired` nella scheda, niente regola `required` nella griglia, anche se i metadati dicono `required`, e niente "Rendi obbligatorio" nei menu in loco. La regola required di DevExtreme rifiuta `false`, e la casella tolta non si salvava |
| 1.1.1 | 2026-10-16 | `elementiSchedaDaMetadati` accetta `escludi`: i campi tolti dalla scheda non contano piu' nel calcolo delle righe (con 3 colonne la chiave automatica lasciava una colonna vuota a sinistra in ogni riga) |
| 1.1.0 | 2026-10-16 | Editor in loco (menu col tasto destro su griglia e scheda, editor completo in finestra aperto sul dataset e sul campo), `meta-runtime.ts` con la conversione dei metadati in colonne e scheda, PATCH nel servizio, anteprima della griglia corretta (le colonne non avevano `dataField` ne' titolo) |
| 1.0.0 | 2026-10-16 | Prima consegna: dataset con autorizzazione e verifica SQL, campi con "Genera campi dalla SELECT", colonne della griglia, posizioni dei campi nella form, personalizzazioni `_CUSTOM` affiancate, anteprima e rigenera, lookup con colonne, picklist, esporta (JSON e SQL) e importa |
