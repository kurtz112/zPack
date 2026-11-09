// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-26
// ---------------------------------------------------------------------------
unit Test.zMemoriaConScadenza;

// Test DUnitX per TzMemoriaConScadenza (zMemoriaConScadenza), la memoria
// dell'esito usata da TCommon.FirmaElettronicaAmmessa di Gesty (Mantis #254,
// voce R-132). L'orologio e' finto: la scadenza si prova spostando l'ora,
// senza attese. Lettura conta le volte in cui l'esito viene riletto.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  zMemoriaConScadenza;

type
  [TestFixture]
  TTestMemoriaConScadenza = class
  private
    FOra: UInt64;
    FLetture: Integer;
    FEsitoLetto: Boolean;
    FMemoria: TzMemoriaConScadenza;
    function Lettura: Boolean;
  public
    [Setup]
    procedure Prepara;
    [TearDown]
    procedure Libera;

    [Test]
    procedure StessaChiave_EntroLaScadenza_ValoreMemorizzato;
    [Test]
    procedure StessaChiave_DopoLaScadenza_Riletto;
    [Test]
    procedure StessoOid_TipoDiverso_Riletto;
    [Test]
    procedure ChiaveDiversa_Riletto;
  end;

implementation

const
  Durata = 5000;
  OidRisorsa = 1234;
  TipoContratto = 'CONTRATTO';

{ TTestMemoriaConScadenza }

procedure TTestMemoriaConScadenza.Prepara;
begin
  FOra := 100000;
  FLetture := 0;
  FEsitoLetto := true;
  FMemoria := TzMemoriaConScadenza.Create(Durata,
    function: UInt64
    begin
      result := FOra;
    end);
end;

procedure TTestMemoriaConScadenza.Libera;
begin
  FreeAndNil(FMemoria);
end;

function TTestMemoriaConScadenza.Lettura: Boolean;
begin
  Inc(FLetture);
  result := FEsitoLetto;
end;

procedure TTestMemoriaConScadenza.StessaChiave_EntroLaScadenza_ValoreMemorizzato;
begin
  Assert.IsTrue(FMemoria.Ottieni(OidRisorsa, TipoContratto, Lettura));
  Assert.AreEqual(1, FLetture);

  // l'esito sul database cambia, ma la memoria non e' scaduta: resta quello di prima
  FEsitoLetto := false;
  FOra := FOra + Durata - 1;
  Assert.IsTrue(FMemoria.Ottieni(OidRisorsa, TipoContratto, Lettura));
  Assert.AreEqual(1, FLetture);
end;

procedure TTestMemoriaConScadenza.StessaChiave_DopoLaScadenza_Riletto;
begin
  Assert.IsTrue(FMemoria.Ottieni(OidRisorsa, TipoContratto, Lettura));

  // allo scoccare della scadenza la memoria non vale piu': il nuovo esito si legge
  FEsitoLetto := false;
  FOra := FOra + Durata;
  Assert.IsFalse(FMemoria.Ottieni(OidRisorsa, TipoContratto, Lettura));
  Assert.AreEqual(2, FLetture);
end;

procedure TTestMemoriaConScadenza.StessoOid_TipoDiverso_Riletto;
begin
  Assert.IsTrue(FMemoria.Ottieni(OidRisorsa, TipoContratto, Lettura));

  FEsitoLetto := false;
  Assert.IsFalse(FMemoria.Ottieni(OidRisorsa, 'ATTESTATO', Lettura));
  Assert.AreEqual(2, FLetture);
end;

procedure TTestMemoriaConScadenza.ChiaveDiversa_Riletto;
begin
  Assert.IsTrue(FMemoria.Ottieni(OidRisorsa, TipoContratto, Lettura));

  FEsitoLetto := false;
  Assert.IsFalse(FMemoria.Ottieni(OidRisorsa + 1, TipoContratto, Lettura));
  Assert.AreEqual(2, FLetture);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMemoriaConScadenza);

end.
