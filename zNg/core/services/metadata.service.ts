import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { UrlService } from '@zng/core/services/url.service';
import { catchError, Observable, shareReplay, throwError } from 'rxjs';

import { DatasetMetadata } from '../models/metadata.models';

@Injectable({ providedIn: 'root' })
export class MetadataService {
  private http = inject(HttpClient);
  private urlService = inject(UrlService);
  private baseUrl = this.urlService.baseUrl;

  /** Cache: datasetId → Observable<DatasetMetadata> (con shareReplay) */
  private cache = new Map<string, Observable<DatasetMetadata>>();

  // ═══ Metadata ═══

  /**
   * Carica i metadati di un dataset.
   * La risposta viene cachata e condivisa tra i subscriber.
   */
  getMetadata(datasetId: string, forceReload = false): Observable<DatasetMetadata> {
    if (forceReload) {
      this.cache.delete(datasetId);
    }

    let cached = this.cache.get(datasetId);
    if (!cached) {
      // Una lettura non riuscita non resta in cache: la prossima riprova
      const lettura: Observable<DatasetMetadata> = this.http
        .get<DatasetMetadata>(`${this.baseUrl}/data/${datasetId}/metadata`)
        .pipe(
          catchError((errore: unknown) => {
            if (this.cache.get(datasetId) === lettura) {
              this.cache.delete(datasetId);
            }
            return throwError(() => errore);
          }),
          shareReplay(1),
        );
      cached = lettura;
      this.cache.set(datasetId, cached);
    }
    return cached;
  }

  /**
   * Invalida la cache per un dataset specifico o per tutti.
   */
  invalidateCache(datasetId?: string): void {
    if (datasetId) {
      this.cache.delete(datasetId);
    } else {
      this.cache.clear();
    }
  }

}
