// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Video.Chiavi
//
// I due primi segreti della formula del codice di sblocco del filmato della
// registrazione per l'assistenza:
//
//   Controllo = ((Base x SbloccoVideoMoltiplicatore) mod SbloccoVideoModulo) mod 10000
//
// Stanno qui da soli perche' servono a due programmi: a zPack
// (zDiagnostica.Video.Sblocco), che controlla il codice, e a zBuilder
// (scheda Ticket, Codice filmato), che lo genera per l'assistenza. Cambiati
// qui, cambiano insieme in tutti e due. Il motivo dei due primi e il
// funzionamento del codice sono descritti in zDiagnostica.Video.Sblocco.
//
// P di 9 cifre, M di 8: il prodotto con una base di 4 cifre sta in 13
// cifre, dentro Int64 e dentro la precisione di Excel.
//
// I valori non vanno ripetuti in documenti, ticket o note.
//
// Unit autonoma: nessuna uses.
//
// ***************************************************************************

unit zDiagnostica.Video.Chiavi;

interface

const
  SbloccoVideoMoltiplicatore: Int64 = 412982137;
  SbloccoVideoModulo: Int64 = 28213747;

implementation

end.
