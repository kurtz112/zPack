// Accesso HTTP alle rotte /api/meta di zServer (Metadata.Editor.Controller).
// Ogni rotta, lettura compresa, richiede l'autorizzazione BASE_WEB_METADATI:
// il controllo lo fa il server. Gli errori li mostra l'intercettore
// dell'applicazione; i rifiuti del database (contenitore con figli, lookup o
// picklist in uso) arrivano come 400 con il messaggio da mostrare cosi' com'e'.
import { HttpClient, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { ZZ_META_EDITOR_CONFIG } from './meta-editor.config';
import {
  AnteprimaSincronizzazione,
  base64Utf16,
  COLONNE_SQL,
  DominioMeta,
  EsitoImportazione,
  EsitoVerificaSql,
  RigaMeta,
} from './meta-editor.models';
import { MetadatiDataset } from './meta-runtime';

/** Una voce della PATCH dei campi: solo le proprieta' presenti cambiano. */
export interface PatchCampo {
  dataField: string;
  caption?: string;
  readOnly?: boolean;
  required?: boolean;
  visible?: boolean;
  colSpan?: number;
  lineBreak?: boolean;
  cardIndex?: number;
}

/** Filtri dell'esportazione: elenchi separati da virgola lato server. */
export interface FiltroEsportazione {
  datasets?: string[];
  dm?: string[];
  escludiDm?: string[];
}

@Injectable()
export class MetaEditorService {
  private http = inject(HttpClient);
  private config = inject(ZZ_META_EDITOR_CONFIG);
  private base = this.config.apiUrl.replace(/\/+$/, '');
  private baseDati = (this.config.datiUrl ?? this.base.replace(/\/meta$/, '/data')).replace(
    /\/+$/,
    '',
  );

  // ─── Servizio ─────────────────────────────────────────────────────────────

  domini(): Promise<DominioMeta[]> {
    return this.get<DominioMeta[]>('/domains');
  }

  autorizzazioni(): Promise<RigaMeta[]> {
    return this.get<RigaMeta[]>('/authorizations');
  }

  // ─── Dataset ──────────────────────────────────────────────────────────────

  datasets(): Promise<RigaMeta[]> {
    return this.get<RigaMeta[]>('/datasets');
  }

  dataset(id: string): Promise<RigaMeta> {
    return this.get<RigaMeta>(`/datasets/${this.k(id)}`);
  }

  /** Crea (nuovo = true) o aggiorna un dataset; le SQL viaggiano in Base64. */
  salvaDataset(id: string, valori: RigaMeta, nuovo: boolean): Promise<RigaMeta> {
    const corpo = this.conSqlCodificate(valori);
    return nuovo
      ? this.post<RigaMeta>('/datasets', { ...corpo, DATASET: id })
      : this.put<RigaMeta>(`/datasets/${this.k(id)}`, corpo);
  }

  eliminaDataset(id: string): Promise<void> {
    return this.del(`/datasets/${this.k(id)}`);
  }

  impostaAutorizzazione(id: string, autorizzazione: string | null): Promise<RigaMeta> {
    return this.put<RigaMeta>(`/datasets/${this.k(id)}/authorization`, {
      AUTHORIZATION: autorizzazione || null,
    });
  }

  anteprima(id: string): Promise<Record<string, unknown>> {
    return this.get<Record<string, unknown>>(`/datasets/${this.k(id)}/preview`);
  }

  rigeneraMeta(id: string): Promise<void> {
    return this.post<void>(`/datasets/${this.k(id)}/rebuild-meta`, {});
  }

  rigeneraTutti(): Promise<void> {
    return this.post<void>('/rebuild-all', {});
  }

  /** Prepara le SQL senza eseguirle; senza valori prova quelle salvate. */
  verificaSql(id: string, valori?: RigaMeta): Promise<EsitoVerificaSql[]> {
    return this.post<EsitoVerificaSql[]>(
      `/datasets/${this.k(id)}/check-sql`,
      valori ? this.conSqlCodificate(valori) : {},
    );
  }

  // ─── Campi ────────────────────────────────────────────────────────────────

  campi(id: string): Promise<RigaMeta[]> {
    return this.get<RigaMeta[]>(`/datasets/${this.k(id)}/fields`);
  }

  anteprimaSincronizzazione(id: string): Promise<AnteprimaSincronizzazione> {
    return this.get<AnteprimaSincronizzazione>(`/datasets/${this.k(id)}/fields/sync-preview`);
  }

  sincronizzaCampi(id: string): Promise<RigaMeta[]> {
    return this.post<RigaMeta[]>(`/datasets/${this.k(id)}/fields/sync`, {});
  }

  // ─── Righe dentro il dataset: campi, griglia, form ───────────────────────

  /**
   * Percorso di una riga del dataset per sezione: fields/{f},
   * grid/columns/{f}, grid/bands/{b}, form/fields/{f} e cosi' via.
   */
  private percorsoSezione(sezione: string): string {
    switch (sezione) {
      case 'fields':
        return 'fields';
      case 'gridColumns':
        return 'grid/columns';
      case 'gridBands':
        return 'grid/bands';
      case 'formGroups':
        return 'form/groups';
      case 'formTabbed':
        return 'form/tabbed';
      case 'formTabs':
        return 'form/tabs';
      case 'formFields':
        return 'form/fields';
      case 'formButtons':
        return 'form/buttons';
      case 'formEmpty':
        return 'form/empty';
      default:
        throw new Error(`Sezione dei metadati sconosciuta: ${sezione}`);
    }
  }

  griglia(id: string): Promise<{ bands: RigaMeta[]; columns: RigaMeta[] }> {
    return this.get(`/datasets/${this.k(id)}/grid`);
  }

  form(id: string): Promise<Record<string, RigaMeta[]>> {
    return this.get(`/datasets/${this.k(id)}/form`);
  }

  salvaRiga(id: string, sezione: string, chiave: string, valori: RigaMeta): Promise<RigaMeta> {
    return this.put<RigaMeta>(
      `/datasets/${this.k(id)}/${this.percorsoSezione(sezione)}/${this.k(chiave)}`,
      valori,
    );
  }

  eliminaRiga(id: string, sezione: string, chiave: string): Promise<void> {
    return this.del(`/datasets/${this.k(id)}/${this.percorsoSezione(sezione)}/${this.k(chiave)}`);
  }

  // ─── Personalizzazioni per cliente (_CUSTOM) ─────────────────────────────

  /** Tutte le righe _CUSTOM del dataset, una sezione per tabella. */
  custom(id: string): Promise<Record<string, RigaMeta[]>> {
    return this.get(`/datasets/${this.k(id)}/custom`);
  }

  /**
   * chiave null = la riga _CUSTOM del dataset stesso (sezione 'datasets').
   * Qui le SQL viaggiano in chiaro, non in Base64: con SQL_BASE64 zServer
   * decodifica anche un null e lo scrive come testo vuoto, e in una _CUSTOM il
   * testo vuoto non eredita la base ma la sovrascrive (COALESCE lo prende).
   */
  salvaCustom(id: string, sezione: string, chiave: string | null, valori: RigaMeta) {
    return this.put<RigaMeta>(this.percorsoCustom(id, sezione, chiave), valori);
  }

  eliminaCustom(id: string, sezione: string, chiave: string | null): Promise<void> {
    return this.del(this.percorsoCustom(id, sezione, chiave));
  }

  private percorsoCustom(id: string, sezione: string, chiave: string | null): string {
    const radice = `/datasets/${this.k(id)}/custom/${sezione}`;
    return chiave === null ? radice : `${radice}/${this.k(chiave)}`;
  }

  // ─── Lookup ───────────────────────────────────────────────────────────────

  lookups(): Promise<RigaMeta[]> {
    return this.get<RigaMeta[]>('/lookups');
  }

  /** Il lookup con le sue colonne (columns). */
  lookup(id: string): Promise<RigaMeta & { columns?: RigaMeta[] }> {
    return this.get(`/lookups/${this.k(id)}`);
  }

  salvaLookup(id: string, valori: RigaMeta, nuovo: boolean): Promise<RigaMeta> {
    return nuovo
      ? this.post<RigaMeta>('/lookups', { ...valori, LOOKUP: id })
      : this.put<RigaMeta>(`/lookups/${this.k(id)}`, valori);
  }

  eliminaLookup(id: string): Promise<void> {
    return this.del(`/lookups/${this.k(id)}`);
  }

  salvaColonnaLookup(id: string, campo: string, valori: RigaMeta): Promise<RigaMeta> {
    return this.put<RigaMeta>(`/lookups/${this.k(id)}/columns/${this.k(campo)}`, valori);
  }

  eliminaColonnaLookup(id: string, campo: string): Promise<void> {
    return this.del(`/lookups/${this.k(id)}/columns/${this.k(campo)}`);
  }

  // ─── Picklist ─────────────────────────────────────────────────────────────

  picklists(): Promise<RigaMeta[]> {
    return this.get<RigaMeta[]>('/picklists');
  }

  /** La picklist con le voci generate dai trigger (items). */
  picklist(id: string): Promise<RigaMeta & { items?: RigaMeta[] }> {
    return this.get(`/picklists/${this.k(id)}`);
  }

  salvaPicklist(id: string, valori: RigaMeta, nuovo: boolean): Promise<RigaMeta> {
    return nuovo
      ? this.post<RigaMeta>('/picklists', { ...valori, PICKLIST: id })
      : this.put<RigaMeta>(`/picklists/${this.k(id)}`, valori);
  }

  eliminaPicklist(id: string): Promise<void> {
    return this.del(`/picklists/${this.k(id)}`);
  }

  // ─── Trasporto ────────────────────────────────────────────────────────────

  esporta(filtro: FiltroEsportazione, formato: 'json' | 'sql'): Promise<string> {
    let params = new HttpParams().set('format', formato);
    if (filtro.datasets?.length) params = params.set('datasets', filtro.datasets.join(','));
    if (filtro.dm?.length) params = params.set('dm', filtro.dm.join(','));
    if (filtro.escludiDm?.length) params = params.set('escludi_dm', filtro.escludiDm.join(','));
    return firstValueFrom(this.http.get(`${this.base}/export`, { params, responseType: 'text' }));
  }

  importa(pacchetto: unknown): Promise<EsitoImportazione> {
    return this.post<EsitoImportazione>('/import', pacchetto);
  }

  scriptDaPacchetto(pacchetto: unknown): Promise<string> {
    return firstValueFrom(
      this.http.post(`${this.base}/import/script`, pacchetto, { responseType: 'text' }),
    );
  }

  // ─── Metadati come li legge la pagina, e PATCH del menu in loco ──────────

  /** Il JSON dei metadati che le pagine ricevono (BASE_WEB_DATASETS_META). */
  metadati(id: string): Promise<MetadatiDataset> {
    return firstValueFrom(
      this.http.get<MetadatiDataset>(`${this.baseDati}/${this.k(id)}/metadata`),
    );
  }

  /**
   * PATCH di Metadata.Patch.Controller: caption, readOnly, required sul campo;
   * visible, colSpan, lineBreak, cardIndex sulla sua posizione nella scheda.
   */
  patchCampi(id: string, campi: PatchCampo[]): Promise<unknown> {
    return firstValueFrom(this.http.patch(`${this.baseDati}/${this.k(id)}/metadata/fields`, campi));
  }

  /** PATCH delle impostazioni della scheda (colCount, labelLocation, formWidth...). */
  patchImpostazioni(id: string, impostazioni: Record<string, unknown>): Promise<unknown> {
    return firstValueFrom(
      this.http.patch(`${this.baseDati}/${this.k(id)}/metadata/settings`, impostazioni),
    );
  }

  // ─── Appoggio ─────────────────────────────────────────────────────────────

  private k(chiave: string): string {
    return encodeURIComponent(chiave);
  }

  private conSqlCodificate(valori: RigaMeta): RigaMeta {
    const corpo: RigaMeta = { ...valori };
    let codificate = false;
    for (const colonna of COLONNE_SQL) {
      if (colonna in corpo) {
        corpo[colonna] = base64Utf16(String(corpo[colonna] ?? ''));
        codificate = true;
      }
    }
    if (codificate) corpo['SQL_BASE64'] = true;
    return corpo;
  }

  private get<T>(percorso: string): Promise<T> {
    return firstValueFrom(this.http.get<T>(this.base + percorso));
  }

  private post<T>(percorso: string, corpo: unknown): Promise<T> {
    return firstValueFrom(this.http.post<T>(this.base + percorso, corpo));
  }

  private put<T>(percorso: string, corpo: unknown): Promise<T> {
    return firstValueFrom(this.http.put<T>(this.base + percorso, corpo));
  }

  private async del(percorso: string): Promise<void> {
    await firstValueFrom(this.http.delete(this.base + percorso));
  }
}
