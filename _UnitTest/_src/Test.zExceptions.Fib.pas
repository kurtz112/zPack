// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-23
// ---------------------------------------------------------------------------
unit Test.zExceptions.Fib;

// Test DUnitX per la lettura della catena "At procedure 'X' line: N" dai
// messaggi di Firebird (zExceptions.fib.EstraiPercorsoChiamate, Mantis #259,
// voce R-136). La funzione lavora sul solo testo del messaggio: nessun
// database, nessuna eccezione FireDAC da costruire.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  zExceptions.fib;

type
  [TestFixture]
  TTestEstraiPercorsoChiamate = class
  public
    [Test]
    procedure SenzaCatena_StringaVuota;
    [Test]
    procedure ProceduraERiga;
    [Test]
    procedure CatenaDiDueLivelli;
    [Test]
    procedure FunzioneInterna;
    [Test]
    procedure ProceduraInternaEFunzione;
    [Test]
    procedure MessaggioConAcapoLF;
    [Test]
    procedure TipoMaiuscolo_Riconosciuto;
  end;

implementation

const
  Troncamento = 'arithmetic exception, numeric overflow, or string truncation' + sLineBreak +
                'string right truncation' + sLineBreak +
                'expected length 2, actual 5';

procedure TTestEstraiPercorsoChiamate.SenzaCatena_StringaVuota;
begin
  Assert.AreEqual('', EstraiPercorsoChiamate(Troncamento));
  Assert.AreEqual('', EstraiPercorsoChiamate(''));
end;

procedure TTestEstraiPercorsoChiamate.ProceduraERiga;
begin
  Assert.AreEqual('procedura GRS_IMPORT_FILES_VALIDA_TESTO, riga 42',
    EstraiPercorsoChiamate(Troncamento + sLineBreak +
      'At procedure ''GRS_IMPORT_FILES_VALIDA_TESTO'' line: 42, col: 5'));
end;

procedure TTestEstraiPercorsoChiamate.CatenaDiDueLivelli;
begin
  // Firebird elenca prima il punto in cui si e' fermato, poi chi l'ha chiamato
  Assert.AreEqual('trigger GRS_IMPORT_RIGHE_BI0, riga 7' + sLineBreak +
                  'chiamata da: procedura GRS_IMPORT_FILE, riga 120',
    EstraiPercorsoChiamate(Troncamento + sLineBreak +
      'At trigger ''GRS_IMPORT_RIGHE_BI0'' line: 7, col: 3' + sLineBreak +
      'At procedure ''GRS_IMPORT_FILE'' line: 120, col: 9'));
end;

procedure TTestEstraiPercorsoChiamate.FunzioneInterna;
begin
  // "sub function" non deve essere letto come "function"
  Assert.AreEqual('funzione interna CAMPO, riga 3' + sLineBreak +
                  'chiamata da: procedura GRS_IMPORT_FILES_VALIDA_TESTO, riga 88',
    EstraiPercorsoChiamate(Troncamento + sLineBreak +
      'At sub function ''CAMPO'' line: 3, col: 7' + sLineBreak +
      'At procedure ''GRS_IMPORT_FILES_VALIDA_TESTO'' line: 88, col: 5'));
end;

procedure TTestEstraiPercorsoChiamate.ProceduraInternaEFunzione;
begin
  Assert.AreEqual('procedura interna RIGA, riga 12' + sLineBreak +
                  'chiamata da: funzione NORMALIZZA, riga 4',
    EstraiPercorsoChiamate(Troncamento + sLineBreak +
      'At sub procedure ''RIGA'' line: 12, col: 1' + sLineBreak +
      'At function ''NORMALIZZA'' line: 4, col: 2'));
end;

procedure TTestEstraiPercorsoChiamate.MessaggioConAcapoLF;
begin
  // I messaggi di Firebird arrivano con a capo LF: il risultato usa sLineBreak
  Assert.AreEqual('procedura A, riga 1' + sLineBreak + 'chiamata da: trigger B, riga 2',
    EstraiPercorsoChiamate('string right truncation'#10 +
      'At procedure ''A'' line: 1, col: 1'#10 +
      'At trigger ''B'' line: 2, col: 1'));
end;

procedure TTestEstraiPercorsoChiamate.TipoMaiuscolo_Riconosciuto;
begin
  Assert.AreEqual('procedura P, riga 5',
    EstraiPercorsoChiamate('AT PROCEDURE ''P'' LINE: 5, col: 1'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestEstraiPercorsoChiamate);

end.
