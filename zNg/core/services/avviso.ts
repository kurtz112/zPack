// Avviso modale unico per gli errori che fermano un'operazione: campi non
// validi al salvataggio della scheda, errori del server su una scrittura
// (inserimento, modifica, cancellazione). Gli errori di lettura restano
// notifiche, perche' non devono interrompere chi sta lavorando.
// Accanto, la domanda di conferma (chiediConferma) con la stessa veste: le
// applicazioni non usano alert e confirm di devextreme/ui/dialog direttamente.
//
// Fa parte del motore zz-* condiviso fra Agora', GestyWeb e Pipa: nessun
// import dall'applicazione, solo devextreme/ui/dialog. Larghezza del testo
// min(480px, 92vw - 48px), cosi' l'avviso e' uguale su computer, tablet e
// telefono: i 48 px sono i margini che il tema da' al contenuto del dialogo
// (24 px per lato), che le applicazioni non devono azzerare.
import { custom } from 'devextreme/ui/dialog';

/** Un pulsante in piu' dell'avviso (per esempio "Segnala all'assistenza"). */
export interface AzioneAvviso {
  testo: string;
  azione: () => void | Promise<void>;
}

/** Testi dei pulsanti della conferma e tipo dell'operazione. */
export interface OpzioniConferma {
  /** Pulsante che conferma; predefinito "Sì". */
  si?: string;
  /** Pulsante che rinuncia; predefinito "No". */
  no?: string;
  /** Vero per le operazioni che non si possono annullare: pulsante rosso. */
  pericolo?: boolean;
}

const LARGHEZZA = 'min(480px, calc(92vw - 48px))';

function testoSicuro(testo: string): string {
  const div = document.createElement('div');
  div.textContent = testo;
  return div.innerHTML;
}

function contenitore(corpo: string): string {
  return `<div style="width:${LARGHEZZA};box-sizing:border-box">${corpo}</div>`;
}

/**
 * Mostra l'avviso e si risolve quando l'utente lo chiude. Le righe sono testo
 * semplice (si mostrano cosi' come sono, senza HTML): una riga sola diventa un
 * paragrafo, piu' righe un elenco.
 */
export async function mostraAvviso(
  titolo: string,
  righe: string[],
  azioni: AzioneAvviso[] = [],
): Promise<void> {
  const corpo =
    righe.length === 1
      ? `<p style="margin:0;white-space:pre-wrap">${testoSicuro(righe[0])}</p>`
      : `<ul style="margin:0;padding-left:20px">${righe
          .map((riga) => `<li style="white-space:pre-wrap">${testoSicuro(riga)}</li>`)
          .join('')}</ul>`;

  const dialogo = custom({
    title: titolo,
    messageHtml: contenitore(corpo),
    buttons: [
      ...azioni.map((voce, indice) => ({
        text: voce.testo,
        stylingMode: 'text' as const,
        onClick: () => `azione-${indice}`,
      })),
      { text: 'Ho capito', type: 'default' as const, stylingMode: 'contained' as const, onClick: () => 'chiudi' },
    ],
  });

  const scelta = (await dialogo.show()) as string;
  const indice = scelta?.startsWith('azione-') ? Number(scelta.slice(7)) : -1;
  if (indice >= 0) await azioni[indice].azione();
}

/**
 * Chiede conferma prima di un'operazione e si risolve con vero se l'utente
 * conferma. Il testo e' semplice (senza HTML); con piu' righe ognuna diventa
 * un paragrafo (domanda, poi la conseguenza).
 */
export async function chiediConferma(
  titolo: string,
  testo: string | string[],
  opzioni: OpzioniConferma = {},
): Promise<boolean> {
  const righe = Array.isArray(testo) ? testo : [testo];
  const corpo = righe
    .map(
      (riga, indice) =>
        `<p style="margin:${indice ? '12px' : '0'} 0 0;white-space:pre-wrap">${testoSicuro(riga)}</p>`,
    )
    .join('');

  const dialogo = custom({
    title: titolo,
    messageHtml: contenitore(corpo),
    buttons: [
      { text: opzioni.no ?? 'No', stylingMode: 'text' as const, onClick: () => false },
      {
        text: opzioni.si ?? 'Sì',
        type: opzioni.pericolo ? ('danger' as const) : ('default' as const),
        stylingMode: 'contained' as const,
        onClick: () => true,
      },
    ],
  });

  // Chiuso senza pulsanti (tasto Esc): vale come rinuncia
  try {
    return (await dialogo.show()) === true;
  } catch {
    return false;
  }
}

/**
 * Vero se l'errore e' gia' stato mostrato dall'intercettore HTTP
 * dell'applicazione (AppError): chi l'ha ricevuto non lo mostra una seconda
 * volta. Si riconosce dal campo, senza importare il modello dell'applicazione.
 */
export function erroreGiaMostrato(errore: unknown): boolean {
  return (errore as { isAppError?: boolean } | null)?.isAppError === true;
}

/** Messaggio leggibile di un errore qualunque. */
export function messaggioErrore(errore: unknown, predefinito: string): string {
  const e = errore as { error?: { message?: string }; message?: string } | null;
  return e?.error?.message ?? e?.message ?? predefinito;
}
