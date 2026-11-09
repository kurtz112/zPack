unit zOffice.Reports.Progress;

// Contratto minimo di avanzamento + annullamento condiviso dai tre motori di
// anteprima (FastReport / Word / Excel).
//
// Viene implementato UNA SOLA volta dal ReportsManager sopra il proprio
// TProgressBox (vedi TzProgressBoxAdapter in zOffice.Reports.pas); i motori lo
// ricevono e lo pilotano senza dipendere dalla UI del dialogo.
//
// Motivazione: durante la preparazione di report molto lunghi si vedeva
// scorrere il dataset senza poter intervenire. Con questo contratto ogni
// motore, mentre scorre i record, aggiorna la barra e legge se l'utente ha
// premuto Annulla.

interface

type
  IzReportProgress = interface
    ['{6F1B7A42-9C3E-4E58-9B1D-2A7C4D0E5F31}']

    // Mostra il box.
    // Max = numero di record atteso; Max <= 0 = barra indeterminata.
    procedure Start(const Caption: string; Max: Integer);

    // Aggiorna la posizione (Info = didascalia secondaria opzionale) e
    // restituisce False se l'utente ha chiesto di interrompere.
    function Step(Position: Integer; const Info: string): Boolean;

    // Chiude il box. Va SEMPRE invocato, anche su eccezione o annullamento
    // (metterlo nel finally del chiamante).
    procedure Done;
  end;

implementation

end.
