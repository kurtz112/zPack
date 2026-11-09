// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------

unit EsportazioneContabile.Gestionale1;

// Esportatore per Zucchetti Gestionale 1.
//
// Riferimento: help in rete gestionale1.it, "Import Dati" (verificato il
// 31/07/2026):
// - la procedura importa piano dei conti, anagrafiche clienti/fornitori,
//   causali contabili e movimenti di prima nota da un unico file prodotto
//   dalla contabilita' dello studio;
// - due tracciati: LEMCO (contabilita' ordinaria) e LEMSE (semplificata),
//   scelti nei Parametri di Collegamento del G1;
// - prima dell'import il G1 richiede la "tabella di conversione" dei mastri
//   clienti/fornitori: la controparte lato WinTarif e' la tabella
//   ESPORTAZIONI_CONTABILI_CORRISPONDENZE.
//
// >> DA COMPLETARE: l'help pubblico documenta la PROCEDURA ma non pubblica il
//    tracciato campo per campo dei file LEMCO/LEMSE. Il tracciato va chiesto
//    all'assistenza Zucchetti o ricavato da un export di esempio del modulo
//    "Collegamento Studio". Fino ad allora l'esportatore e' volutamente
//    disattivato e ogni chiamata solleva un errore chiaro.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  EsportazioneContabile.Types, EsportazioneContabile.Base;

type
  TzEsportatoreContabileGestionale1 = class(TzEsportatoreContabileBase)
  public
    function Gestionale: string; override;
    function Descrizione: string; override;
    function EsportaPrimaNota(Movimenti: TObjectList<TzMovimentoContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; override;
    function EsportaAnagrafiche(Anagrafiche: TObjectList<TzAnagraficaContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; override;
  end;

implementation

uses
  EsportazioneContabile.Registry;

function TzEsportatoreContabileGestionale1.Gestionale: string;
begin
  Result := 'GESTIONALE1';
end;

function TzEsportatoreContabileGestionale1.Descrizione: string;
begin
  Result := 'Zucchetti Gestionale 1 (tracciato LEMCO/LEMSE)';
end;

function TzEsportatoreContabileGestionale1.EsportaPrimaNota(
  Movimenti: TObjectList<TzMovimentoContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
begin
  raise EzEsportazioneContabile.Create(
    'Tracciato LEMCO/LEMSE non ancora disponibile: ' +
    'richiedere le specifiche del formato all''assistenza Zucchetti');
end;

function TzEsportatoreContabileGestionale1.EsportaAnagrafiche(
  Anagrafiche: TObjectList<TzAnagraficaContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
begin
  raise EzEsportazioneContabile.Create(
    'Tracciato LEMCO/LEMSE non ancora disponibile: ' +
    'richiedere le specifiche del formato all''assistenza Zucchetti');
end;

initialization
  TzEsportatoriContabili.Registra('GESTIONALE1', TzEsportatoreContabileGestionale1);

end.
