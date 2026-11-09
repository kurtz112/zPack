// Richieste il cui errore fa parte del funzionamento normale e non va mostrato
// con la notifica: per esempio il controllo dell'autorizzazione all'editor dei
// metadati, dove un 403 vuol dire solo "nascondi la voce di menu", o il
// controllo "la segnalazione degli errori e' attiva?", che su uno zServer piu'
// vecchio risponde 404. L'errore arriva comunque al chiamante come AppError.
//
// L'interceptor degli errori resta nell'applicazione e legge questo token:
// sta in zNg perche' lo usano anche ZServerService (leggi con silenzioso) e i
// servizi dell'applicazione, e definirlo nell'interceptor creerebbe un giro di
// importazioni fra l'interceptor e SegnalazioniService.
import { HttpContextToken } from '@angular/common/http';

export const ERRORE_SILENZIOSO = new HttpContextToken<boolean>(() => false);
