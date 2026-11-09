// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-28
// ---------------------------------------------------------------------------

// Registro locale dei ticket di assistenza aperti dall'utente corrente.
//
// Il reporter dei ticket aperti da WT e Gesty e' l'utente di servizio del
// token, non la persona: Mantis quindi non sa dire "i miei ticket". Lo sa
// l'applicazione, che al ritorno di SegnalaSuMantis registra la coppia
// utente + numero ticket nel proprio database. Questa unit definisce solo il
// contratto: l'implementazione su Firebird sta in Mantis.Segnalazioni.Store,
// la form che lo usa in zMantis.TicketAssistenza.form.

unit Mantis.Segnalazioni.Types;

interface

uses
  System.SysUtils;

type
  TMantisSegnalazioneLocale = record
    IdTicket: Integer;
    DataApertura: TDateTime;
    Oggetto: string;
    Stato: string; // nome interno MantisBT, copia locale dell'ultima lettura
    AssegnatoA: string;
    AggiornatoIl: TDateTime; // updated_at del ticket all'ultima lettura
    UltimoAggiornamentoVisto: TDateTime; // updated_at che l'utente ha gia' visto
    // True se il ticket e' cambiato dopo l'ultima volta che l'utente lo ha aperto.
    function Novita: Boolean;
    function Chiuso: Boolean;
  end;

  IMantisSegnalazioniStore = interface
    ['{8C1F2A54-3B7E-4E0B-9C1D-5F6A7B8C9D01}']
    // Segnalazioni dell'utente corrente, dalla piu' recente.
    function Elenco: TArray<TMantisSegnalazioneLocale>;
    // Registra un ticket appena aperto (chiamata dall'evento di zExceptions).
    procedure Registra(AIdTicket: Integer; const AOggetto: string);
    // Aggiorna la copia locale dopo una lettura da Mantis.
    procedure Aggiorna(AIdTicket: Integer; const AStato, AAssegnatoA: string; AAggiornatoIl: TDateTime);
    // L'utente ha aperto il dettaglio: le novita' fino ad AggiornatoIl sono viste.
    procedure Visto(AIdTicket: Integer);
    // Nome dell'utente applicativo, usato come prefisso delle note.
    function NomeUtente: string;
  end;

implementation

{ TMantisSegnalazioneLocale }

function TMantisSegnalazioneLocale.Novita: Boolean;
begin
  Result := AggiornatoIl > UltimoAggiornamentoVisto;
end;

function TMantisSegnalazioneLocale.Chiuso: Boolean;
begin
  Result := SameText(Stato, 'closed');
end;

end.
