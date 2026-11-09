// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------
unit zSql.UpdateParziale;

// Mantis #257 - 2026-10-29: composizione dell'UPDATE con le sole colonne
// cambiate, usata da TzFbDataSet.InternalPost sui dataset con UPDATE
// automatico (zSqlLib.Build_Sql_Update) e UpdateChangedFields accesa.
//
// L'UPDATE automatico scrive tutte le colonne della tabella o della vista: una
// scheda aperta prima che un'altra finestra salvasse riscriveva cosi' anche i
// campi che non aveva toccato, con i valori vecchi che aveva in memoria (la
// nota persa del ticket). Con le sole colonne cambiate il resto della riga
// resta quello del database, trigger delle viste compresi (in Firebird NEW
// porta per le colonne assenti dal SET i valori attuali della riga).
//
// Il testo ha la stessa forma di Build_Sql_Update: con tutte le colonne il
// risultato e' identico, riga per riga. Funzione pura, senza dataset ne'
// dizionario, provata da Test.zFbDataSet.UpdateParziale.

interface

uses
  System.SysUtils,
  System.Classes;

// UPDATE di Tabella con Colonne nel SET, nell'ordine ricevuto, seguito da
// Where (gia' completo della parola WHERE, come lo restituisce
// Calc_WhereByKeyFields) e da RETURNING con le colonne di Returning.
// - Colonne vuoto: SET delle sole Chiavi (CHIAVE=:CHIAVE). Non cambia niente,
//   perche' la WHERE impone gia' che la chiave sia quella letta, ma l'UPDATE
//   parte, e trigger, USR_DATA_MDF, RETURNING e conteggio delle righe si
//   comportano come un salvataggio senza modifiche di prima.
// - Colonne e Chiavi vuoti, o Tabella vuota: testo vuoto. Chi chiama deve
//   tenere l'UPDATE completo: un ModifySQL vuoto farebbe eseguire a FireDAC il
//   comando precedente.
// - Returning vuoto o nil: niente RETURNING (Build_Sql_Update in quel caso
//   scrive la parola da sola, che non e' SQL valido).
// Le chiavi possono essere qualificate (TABELLA.COLONNA, come le da'
// Get_KeyFields): nel SET va il solo nome della colonna.
function ComponiUpdateParziale(const Tabella: string; Colonne, Chiavi: TStrings; const Where: string; Returning: TStrings): string;

// Nome della colonna senza il nome della tabella davanti (TABELLA.ID -> ID)
function ColonnaSenzaTabella(const Nome: string): string;

implementation

function ColonnaSenzaTabella(const Nome: string): string;
var
  Punto: Integer;
begin
  Result := Trim(Nome);
  Punto := Pos('.', Result);
  if Punto <> 0 then
    Result := Copy(Result, Punto + 1, Length(Result));
end;

function ComponiUpdateParziale(const Tabella: string; Colonne, Chiavi: TStrings; const Where: string; Returning: TStrings): string;
var
  NelSet: TStringList;
  Righe: TStringList;
  Colonna: string;
  Riga: string;
  i: Integer;
begin
  Result := '';

  if Trim(Tabella) = '' then
    Exit;

  NelSet := TStringList.Create;
  Righe := TStringList.Create;
  try
    if Assigned(Colonne) then
      for i := 0 to Colonne.Count - 1 do
      begin
        Colonna := Trim(Colonne[i]);
        if Colonna <> '' then
          NelSet.Add(Colonna);
      end;

    if (NelSet.Count = 0) and Assigned(Chiavi) then
      for i := 0 to Chiavi.Count - 1 do
      begin
        Colonna := ColonnaSenzaTabella(Chiavi[i]);
        if Colonna <> '' then
          NelSet.Add(Colonna);
      end;

    if NelSet.Count = 0 then
      Exit;

    // stessa forma di Build_Sql_Update (zSqlLib)
    Righe.Add('UPDATE ' + Tabella);
    Righe.Add('SET');
    for i := 0 to NelSet.Count - 1 do
      if i <> NelSet.Count - 1 then
        Righe.Add(' ' + NelSet[i] + '=:' + NelSet[i] + ',')
      else
        Righe.Add(' ' + NelSet[i] + '=:' + NelSet[i]);

    if Trim(Where) <> '' then
      Righe.Add(Where);

    if Assigned(Returning) and (Returning.Count > 0) then
    begin
      Righe.Add('RETURNING ');
      for i := 0 to Returning.Count - 1 do
      begin
        Riga := '  ' + Returning[i];
        if i <> Returning.Count - 1 then
          Riga := Riga + ',';
        Righe.Add(Riga);
      end;
    end;

    Result := Righe.Text;
  finally
    FreeAndNil(Righe);
    FreeAndNil(NelSet);
  end;
end;

end.
