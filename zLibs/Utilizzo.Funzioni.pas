// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-18
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Utilizzo.Funzioni
//
// Conta quante volte e a che ora ogni azione del programma viene eseguita, per
// ricavare le funzioni piu usate e stabilire i collaudi da superare prima di un
// rilascio.
//
// Come funziona: un TApplicationEvents (che affianca quello gia' presente
// nell'applicazione, senza sostituirlo) riceve OnActionExecute, cioe' ogni
// esecuzione di una TAction, da qualunque lista e da qualunque form: menu,
// viste, frame. Il conteggio resta in memoria, per ora e azione, e viene
// consegnato a chi usa la unit a blocchi (a intervalli e alla chiusura),
// mai a ogni clic.
//
// L'evento scatta quando l'azione parte: non sa se ha avuto successo ne' quanto
// e' durata. Non vede i pulsanti che reagiscono a OnClick senza azione.
//
// La unit non conosce l'applicazione ne' il database: chi la usa dice come
// descrivere un'azione (modulo, funzione, se registrarla) e come scrivere i
// conteggi. Per questo sta in zLibs e serve identica a Gesty e a WT.
//
// Analisi: D:\AI\OUT\20261018-funzionalita-piu-usate-e-collaudo\
//
// ***************************************************************************

unit Utilizzo.Funzioni;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Actions,
  System.Generics.Collections,
  Vcl.ExtCtrls,
  Vcl.AppEvnts;

type
  // Conteggio delle esecuzioni di una azione in una certa ora.
  TUtilizzoFunzione = record
    // Inizio dell'ora a cui si riferisce il conteggio.
    Ora: TDateTime;
    // Voce del menu dei moduli, se l'azione apre un modulo; altrimenti vuoto.
    Modulo: string;
    // Form, frame o vista a cui appartiene l'azione.
    Funzione: string;
    Azione: string;
    Esecuzioni: Integer;
    // Momento esatto dell'ultima esecuzione dell'ora.
    UltimaEsecuzione: TDateTime;
  end;

  // Chi usa la unit descrive l'azione: Modulo e Funzione partono vuoti e
  // Registrare parte True; si mette Registrare a False per ignorarla.
  TDescriviAzioneEvent = reference to procedure(Azione: TBasicAction; var Modulo, Funzione: string;
    var Registrare: Boolean);

  // Scrive un conteggio. Se solleva un'eccezione il conteggio resta in memoria
  // e viene riprovato alla scrittura successiva.
  TScriviUtilizzoEvent = reference to procedure(const Utilizzo: TUtilizzoFunzione);

  TRegistroUtilizzi = class
  strict private
    FContatori: TDictionary<string, TUtilizzoFunzione>;
    FEventiApplicazione: TApplicationEvents;
    FTimer: TTimer;
    FDescrivi: TDescriviAzioneEvent;
    FScrivi: TScriviUtilizzoEvent;
    FInScrittura: Boolean;
    function ChiaveDi(const Utilizzo: TUtilizzoFunzione): string;
    function GetPendenti: Integer;
    procedure AggiungiConteggio(const Utilizzo: TUtilizzoFunzione);
    procedure AzioneEseguita(Azione: TBasicAction; var Handled: Boolean);
    procedure ScadenzaTimer(Sender: TObject);
  public
    constructor Create(const Descrivi: TDescriviAzioneEvent; const Scrivi: TScriviUtilizzoEvent;
      const IntervalloMinuti: Integer = 5);
    destructor Destroy; override;
    // Conta una esecuzione. Non solleva mai eccezioni.
    procedure Registra(Azione: TBasicAction);
    // Consegna i conteggi accumulati a chi li scrive. Non solleva mai eccezioni.
    procedure Scrivi;
    // Conteggi in memoria, non ancora consegnati.
    property Pendenti: Integer read GetPendenti;
  end;

implementation

uses
  System.DateUtils;

{ TRegistroUtilizzi }

constructor TRegistroUtilizzi.Create(const Descrivi: TDescriviAzioneEvent;
  const Scrivi: TScriviUtilizzoEvent; const IntervalloMinuti: Integer);
begin
  inherited Create;
  FDescrivi := Descrivi;
  FScrivi := Scrivi;
  FContatori := TDictionary<string, TUtilizzoFunzione>.Create;

  FEventiApplicazione := TApplicationEvents.Create(nil);
  FEventiApplicazione.OnActionExecute := AzioneEseguita;

  FTimer := TTimer.Create(nil);
  FTimer.Interval := IntervalloMinuti * 60 * 1000;
  FTimer.OnTimer := ScadenzaTimer;
  FTimer.Enabled := True;
end;

destructor TRegistroUtilizzi.Destroy;
begin
  FreeAndNil(FTimer);
  FreeAndNil(FEventiApplicazione);
  FreeAndNil(FContatori);
  inherited;
end;

function TRegistroUtilizzi.ChiaveDi(const Utilizzo: TUtilizzoFunzione): string;
begin
  // L'ora entra nella chiave come numero di ore dall'origine dei TDateTime:
  // due esecuzioni della stessa ora hanno la stessa chiave.
  Result := IntToStr(Round(Utilizzo.Ora * 24)) + '|' + Utilizzo.Modulo + '|' + Utilizzo.Funzione + '|' +
    Utilizzo.Azione;
end;

function TRegistroUtilizzi.GetPendenti: Integer;
begin
  Result := FContatori.Count;
end;

procedure TRegistroUtilizzi.AggiungiConteggio(const Utilizzo: TUtilizzoFunzione);
var
  Esistente: TUtilizzoFunzione;
  Chiave: string;
begin
  Chiave := ChiaveDi(Utilizzo);
  if FContatori.TryGetValue(Chiave, Esistente) then
  begin
    Esistente.Esecuzioni := Esistente.Esecuzioni + Utilizzo.Esecuzioni;
    if Utilizzo.UltimaEsecuzione > Esistente.UltimaEsecuzione then
      Esistente.UltimaEsecuzione := Utilizzo.UltimaEsecuzione;
    FContatori.AddOrSetValue(Chiave, Esistente);
  end
  else
    FContatori.Add(Chiave, Utilizzo);
end;

procedure TRegistroUtilizzi.AzioneEseguita(Azione: TBasicAction; var Handled: Boolean);
begin
  // Handled non si tocca: l'azione deve proseguire come se noi non ci fossimo.
  Registra(Azione);
end;

procedure TRegistroUtilizzi.ScadenzaTimer(Sender: TObject);
begin
  Scrivi;
end;

procedure TRegistroUtilizzi.Registra(Azione: TBasicAction);
var
  Utilizzo: TUtilizzoFunzione;
  Registrare: Boolean;
  Adesso: TDateTime;
begin
  try
    if (Azione = nil) or (Azione.Name = '') or not Assigned(FDescrivi) then
      Exit;

    Utilizzo := Default(TUtilizzoFunzione);
    Registrare := True;
    FDescrivi(Azione, Utilizzo.Modulo, Utilizzo.Funzione, Registrare);
    if not Registrare then
      Exit;

    Adesso := Now;
    Utilizzo.Ora := RecodeTime(Adesso, HourOf(Adesso), 0, 0, 0);
    Utilizzo.Azione := Azione.Name;
    Utilizzo.Esecuzioni := 1;
    Utilizzo.UltimaEsecuzione := Adesso;
    AggiungiConteggio(Utilizzo);
  except
    // Contare non deve mai disturbare chi sta lavorando: un'azione non
    // registrata e' un'esecuzione in meno nelle statistiche, niente di piu'.
  end;
end;

procedure TRegistroUtilizzi.Scrivi;
var
  Utilizzi: TArray<TUtilizzoFunzione>;
  Indice: Integer;
  Successivo: Integer;
begin
  // Il database puo' far girare i messaggi mentre risponde: senza questa
  // guardia il timer rientrerebbe in una scrittura gia' in corso.
  if FInScrittura or (FContatori.Count = 0) or not Assigned(FScrivi) then
    Exit;

  FInScrittura := True;
  try
    Utilizzi := FContatori.Values.ToArray;
    FContatori.Clear;

    for Indice := 0 to High(Utilizzi) do
      try
        FScrivi(Utilizzi[Indice]);
      except
        // Se il database non risponde, e' inutile riprovare con gli altri:
        // i conteggi non scritti tornano in memoria per la volta successiva.
        for Successivo := Indice to High(Utilizzi) do
          AggiungiConteggio(Utilizzi[Successivo]);
        Break;
      end;
  finally
    FInScrittura := False;
  end;
end;

end.
