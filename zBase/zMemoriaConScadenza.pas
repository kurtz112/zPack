// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-26
// ---------------------------------------------------------------------------
unit zMemoriaConScadenza;

// Memoria di un solo esito booleano, legato a una chiave Oid + TipoDocumento,
// che scade dopo una durata fissa. Serve ai metodi interrogati molte volte al
// secondo (aggiornamento delle azioni della barra) che altrimenti farebbero
// una lettura sul database a ogni giro: entro la scadenza e con la stessa
// chiave si restituisce l'esito memorizzato, altrimenti si rilegge.
//
// L'orologio e' iniettabile (millisecondi monotoni): il predefinito e'
// GetTickCount64, i test ne passano uno finto per far scadere la memoria
// senza attendere. Nessuna dipendenza da database o da unit applicative.

interface

uses
  System.SysUtils;

type
  // orologio in millisecondi, monotono (non torna mai indietro)
  TzOrologioMillisecondi = reference to function: UInt64;

  TzMemoriaConScadenza = class
  private
    FDurataMillisecondi: UInt64;
    FOrologio: TzOrologioMillisecondi;
    FValida: Boolean;
    FOid: Int64;
    FTipoDocumento: string;
    FScadenza: UInt64;
    FValore: Boolean;
  public
    // Orologio nil = GetTickCount64
    constructor Create(DurataMillisecondi: UInt64; Orologio: TzOrologioMillisecondi = nil);

    // Vero se per la chiave c'e' un esito memorizzato non ancora scaduto,
    // restituito in Valore. Scaduto quando l'orologio raggiunge la scadenza.
    function Leggi(Oid: Int64; const TipoDocumento: string; out Valore: Boolean): Boolean;

    // Memorizza l'esito della chiave, al posto di quello precedente, con
    // scadenza da adesso piu' la durata
    procedure Memorizza(Oid: Int64; const TipoDocumento: string; Valore: Boolean);

    // Esito memorizzato se valido, altrimenti chiama Lettura e lo memorizza.
    // Se Lettura solleva un'eccezione non si memorizza niente e l'eccezione
    // prosegue: la memoria resta quella di prima.
    function Ottieni(Oid: Int64; const TipoDocumento: string; const Lettura: TFunc<Boolean>): Boolean;

    // Dimentica l'esito memorizzato: la chiamata successiva rilegge
    procedure Dimentica;

    property DurataMillisecondi: UInt64 read FDurataMillisecondi;
  end;

implementation

uses
  Winapi.Windows;

{ TzMemoriaConScadenza }

constructor TzMemoriaConScadenza.Create(DurataMillisecondi: UInt64; Orologio: TzOrologioMillisecondi);
begin
  inherited Create;
  FDurataMillisecondi := DurataMillisecondi;
  if Assigned(Orologio) then
    FOrologio := Orologio
  else
    FOrologio :=
      function: UInt64
      begin
        result := Winapi.Windows.GetTickCount64;
      end;
  Dimentica;
end;

procedure TzMemoriaConScadenza.Dimentica;
begin
  FValida := false;
  FOid := -1;
  FTipoDocumento := '';
  FScadenza := 0;
  FValore := false;
end;

function TzMemoriaConScadenza.Leggi(Oid: Int64; const TipoDocumento: string; out Valore: Boolean): Boolean;
begin
  result := FValida and (Oid = FOid) and (TipoDocumento = FTipoDocumento) and (FOrologio() < FScadenza);
  if result then
    Valore := FValore
  else
    Valore := false;
end;

procedure TzMemoriaConScadenza.Memorizza(Oid: Int64; const TipoDocumento: string; Valore: Boolean);
begin
  FOid := Oid;
  FTipoDocumento := TipoDocumento;
  FValore := Valore;
  FScadenza := FOrologio() + FDurataMillisecondi;
  FValida := true;
end;

function TzMemoriaConScadenza.Ottieni(Oid: Int64; const TipoDocumento: string; const Lettura: TFunc<Boolean>): Boolean;
begin
  if Leggi(Oid, TipoDocumento, result) then
    exit;

  result := Lettura();
  Memorizza(Oid, TipoDocumento, result);
end;

end.
