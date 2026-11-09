// Servizio HTTP verso zServer: dataset (CustomStore per griglie e caselle a
// discesa, lettura semplice con leggi()), rotte dedicate in JSON e stored
// procedure. Unica copia per tutte le applicazioni, nata dalla fusione delle
// versioni di Agora' e GestyWeb (zNg 1.1.0).
//
// Gestione errori, fuori da qui:
//  - l'interceptor degli errori dell'applicazione trasforma HttpErrorResponse
//    in AppError e mostra la notifica, salvo le richieste marcate con
//    ERRORE_SILENZIOSO;
//  - l'interceptor di autenticazione aggiunge il token e gestisce il 401.
//
// Le righe arrivano con i nomi delle colonne in maiuscolo (RigaZServer): la
// traduzione nel modello del client e' compito dell'applicazione, non di
// questo servizio.

import { HttpClient, HttpContext, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import CustomStore from 'devextreme/data/custom_store';
import { LoadOptions } from 'devextreme/data/load_options';
import { firstValueFrom, Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { ERRORE_SILENZIOSO } from '../interceptors/errore-silenzioso';
import { UrlService } from './url.service';

/** Una riga come la restituisce zServer: nomi delle colonne in maiuscolo. */
export type RigaZServer = Record<string, unknown>;

export interface StoredProcParam {
  name: string;
  value: unknown;
  dataType: 'string' | 'integer' | 'float' | 'boolean' | 'datetime';
}

export interface StoredProcRequest {
  inputParams: StoredProcParam[];
  outputParams: { name: string; dataType: string }[];
}

export interface DevExtremeResponse {
  data: RigaZServer[];
  totalCount?: number;
  groupCount?: number;
  summary?: unknown[];
}

/** Opzioni di lettura di un dataset, nel formato DevExtreme che zServer capisce. */
export interface OpzioniLettura {
  /** Filtro DevExtreme, per esempio ['ID_INTESTATARIO', '=', 12]. */
  filter?: unknown[];
  /** Ordinamento DevExtreme, per esempio [{ selector: 'NOME_VIA', desc: false }]. */
  sort?: unknown[];
  skip?: number;
  take?: number;
  /** Parametri aggiuntivi in query string: belfiore, idAzienda. */
  extraParams?: Record<string, string | number | boolean | null | undefined>;
  /**
   * Errore atteso, da non mostrare con la notifica: per esempio un 403 su un
   * dataset che solo alcuni utenti possono leggere. Il chiamante lo riceve
   * comunque come AppError.
   */
  silenzioso?: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────

@Injectable({ providedIn: 'root' })
export class ZServerService {
  private http = inject(HttpClient);
  private urlService = inject(UrlService);

  readonly baseUrl = this.urlService.baseUrl;

  // ═══════════════════════════════════════════════════════════════════════════
  // DataStore per le griglie e le caselle a discesa con ricerca sul server
  // ═══════════════════════════════════════════════════════════════════════════

  /**
   * Crea un CustomStore DevExtreme collegato a /api/data/{datasetId}.
   * Paginazione, filtri e ricerca (searchExpr/searchValue) li fa il server.
   * filtroPerChiave sostituisce il filtro [keyField, '=', chiave] della lettura
   * di una riga: serve ai collegamenti con chiave composta.
   */
  createDataStore(
    datasetId: string,
    keyField: string,
    extraParams?: Record<string, unknown>,
    filtroPerChiave?: (key: unknown) => unknown[],
  ): CustomStore {
    return new CustomStore({
      key: keyField,
      load: (opts) => this._loadData(datasetId, opts, extraParams),
      byKey: (key) =>
        filtroPerChiave
          ? this._loadData(datasetId, { filter: filtroPerChiave(key), take: 1 }, extraParams).then(
              (risposta) => (risposta.data as RigaZServer[])[0],
            )
          : this._byKey(datasetId, keyField, key, extraParams),
      insert: (values) => this._insertData(datasetId, values),
      update: (key, values) => this._updateData(datasetId, key, values),
      remove: (key) => this._deleteData(datasetId, key),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Lettura semplice di un dataset
  // ═══════════════════════════════════════════════════════════════════════════

  /** Legge le righe di un dataset (GET /api/data/{datasetId}). */
  leggi(datasetId: string, opzioni: OpzioniLettura = {}): Promise<RigaZServer[]> {
    let params = new HttpParams();

    if (opzioni.filter) params = params.set('filter', JSON.stringify(opzioni.filter));
    if (opzioni.sort) params = params.set('sort', JSON.stringify(opzioni.sort));
    if (opzioni.skip !== undefined) params = params.set('skip', String(opzioni.skip));
    if (opzioni.take !== undefined) params = params.set('take', String(opzioni.take));

    for (const [chiave, valore] of Object.entries(opzioni.extraParams ?? {})) {
      if (valore !== undefined && valore !== null && valore !== '') {
        params = params.set(chiave, String(valore));
      }
    }

    return firstValueFrom(
      this.http
        .get<DevExtremeResponse>(`${this.baseUrl}/data/${datasetId}`, {
          params,
          context: new HttpContext().set(ERRORE_SILENZIOSO, opzioni.silenzioso === true),
        })
        .pipe(map((risposta) => risposta?.data ?? [])),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Rotte dedicate (controller di prodotto, es. /api/wt/agora)
  // ═══════════════════════════════════════════════════════════════════════════

  getJson<T>(percorso: string): Promise<T> {
    return firstValueFrom(this.http.get<T>(`${this.baseUrl}${percorso}`));
  }

  postJson<T>(percorso: string, corpo: unknown): Promise<T> {
    return firstValueFrom(this.http.post<T>(`${this.baseUrl}${percorso}`, corpo ?? {}));
  }

  putJson<T>(percorso: string, corpo: unknown): Promise<T> {
    return firstValueFrom(this.http.put<T>(`${this.baseUrl}${percorso}`, corpo ?? {}));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD del CustomStore
  // ═══════════════════════════════════════════════════════════════════════════

  private _loadData(
    datasetId: string,
    opts: LoadOptions,
    extraParams?: Record<string, unknown>,
  ): Promise<DevExtremeResponse> {
    const url = `${this.baseUrl}/data/${datasetId}`;
    let params = new HttpParams();

    if (opts.skip !== undefined) params = params.set('skip', opts.skip.toString());
    if (opts.take !== undefined) params = params.set('take', opts.take.toString());
    if (opts.requireTotalCount) params = params.set('requireTotalCount', 'true');
    if (opts.requireGroupCount) params = params.set('requireGroupCount', 'true');
    if (opts.sort) params = params.set('sort', JSON.stringify(opts.sort));
    if (opts.filter) params = params.set('filter', JSON.stringify(opts.filter));
    if (opts.group) params = params.set('group', JSON.stringify(opts.group));
    if (opts.select) params = params.set('select', JSON.stringify(opts.select));
    // ricerca delle caselle a discesa: zServer accetta un solo campo
    if (opts.searchExpr) params = params.set('searchExpr', JSON.stringify(opts.searchExpr));
    if (opts.searchOperation) params = params.set('searchOperation', opts.searchOperation);
    if (opts.searchValue) params = params.set('searchValue', String(opts.searchValue));

    if (extraParams) {
      Object.keys(extraParams).forEach((key) => {
        const val = extraParams[key];
        if (val !== undefined && val !== null) {
          // un oggetto o un elenco si serializza, il resto va come testo
          const valueToSend = typeof val === 'object' ? JSON.stringify(val) : String(val);
          params = params.set(key, valueToSend);
        }
      });
    }

    const request = this.http.get<DevExtremeResponse>(url, { params }).pipe(
      map((r) => {
        const data = r.data ?? [];
        this.autoConvertDates(data);
        return {
          data,
          totalCount: r.totalCount,
          groupCount: r.groupCount,
          summary: r.summary,
        };
      }),
    );

    return firstValueFrom(request);
  }

  // zServer non ha GET /api/data/{dataset}/{chiave} (solo PUT e DELETE):
  // la riga si legge con il filtro sulla chiave, che GetData gestisce.
  private _byKey(
    datasetId: string,
    keyField: string,
    key: unknown,
    extraParams?: Record<string, unknown>,
  ): Promise<RigaZServer | undefined> {
    return this._loadData(datasetId, { filter: [keyField, '=', key], take: 1 }, extraParams).then(
      (risposta) => (risposta.data as RigaZServer[])[0],
    );
  }

  private _insertData(datasetId: string, values: unknown): Promise<RigaZServer> {
    return firstValueFrom(this.http.post<RigaZServer>(`${this.baseUrl}/data/${datasetId}`, values));
  }

  private _updateData(datasetId: string, key: unknown, values: unknown): Promise<RigaZServer> {
    return firstValueFrom(
      this.http.put<RigaZServer>(`${this.baseUrl}/data/${datasetId}/${key}`, values),
    );
  }

  private _deleteData(datasetId: string, key: unknown): Promise<void> {
    return firstValueFrom(this.http.delete<void>(`${this.baseUrl}/data/${datasetId}/${key}`));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Stored procedure
  // ═══════════════════════════════════════════════════════════════════════════

  executeStoredProcedure(procName: string, request: StoredProcRequest): Observable<unknown> {
    return this.http.post(`${this.baseUrl}/data/sp/${procName}`, request);
  }

  // ═══════════════════════════════════════════════════════════════════════════

  // Le date arrivano come testo ISO con fuso; quelle del 30/12/1899 sono ore
  // pure (colonne TIME). Il tipo di ogni campo si decide dal primo record.
  private autoConvertDates(data: RigaZServer[]): void {
    if (!data?.length) return;

    const first = data[0];
    const isoDateRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[+-]\d{2}:\d{2}$/;

    const timeFields: string[] = [];
    const dateFields: string[] = [];

    Object.keys(first).forEach((key) => {
      const val = first[key];
      if (typeof val !== 'string' || !isoDateRegex.test(val)) return;

      if (val.startsWith('1899-12-30T')) {
        timeFields.push(key);
      } else {
        dateFields.push(key);
      }
    });

    if (!timeFields.length && !dateFields.length) return;

    data.forEach((row) => {
      timeFields.forEach((field) => {
        const valore = row[field];
        if (typeof valore === 'string') {
          const match = valore.match(/T(\d{2}):(\d{2}):(\d{2})/);
          if (match) {
            const d = new Date();
            d.setHours(+match[1], +match[2], +match[3], 0);
            row[field] = d;
          }
        }
      });

      dateFields.forEach((field) => {
        const valore = row[field];
        if (typeof valore === 'string') {
          row[field] = new Date(valore);
        }
      });
    });
  }
}
