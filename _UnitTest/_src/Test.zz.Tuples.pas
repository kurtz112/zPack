// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.Tuples;

// Test DUnitX di zLibs\zz.Tuples.pas: tuple generiche da due a sette valori
// (specifica ZLIBS-TUP, "Tuple generiche.md"). Nessuna dipendenza da
// database o interfaccia.
//
// La proprieta' dei valori oggetto (ZLIBS-TUP-005) si prova con una
// sentinella: un oggetto che scrive in una variabile booleana del test quando
// viene liberato.
//
// Le divergenze (DIV-TUP-1..3) non sono provate: la prima e' il contratto di
// proprieta' stesso (provato da ZLIBS-TUP-005, non un difetto del test), le
// altre due riguardano il codice dei chiamanti.

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DUnitX.TestFramework,
  zz.Tuples;

type
  // Oggetto di prova: all'uscita segnala di essere stato liberato.
  TSentinella = class
  private
    FLiberata: PBoolean;
  public
    constructor Create(Liberata: PBoolean);
    destructor Destroy; override;
  end;

  [TestFixture]
  TTestZzTuples = class
  public
    // ZLIBS-TUP-001
    [Test]
    procedure Creazione_Coppia_ValoriLetti;
    // ZLIBS-TUP-001
    [Test]
    procedure Creazione_Tripla_ValoriLetti;
    // ZLIBS-TUP-001
    [Test]
    procedure Creazione_QuattroECinqueElementi_ValoriLetti;
    // ZLIBS-TUP-001
    [Test]
    procedure Creazione_SeiElementi_ValoriLetti;
    // ZLIBS-TUP-001
    [Test]
    procedure Creazione_SetteElementi_ValoriLetti;
    // ZLIBS-TUP-001
    [Test]
    procedure Creazione_TestoVuotoEZero_ValoriConservati;
    // ZLIBS-TUP-002
    [Test]
    procedure Scrittura_DaInterfaccia_CambiaSoloIlValoreScritto;
    // ZLIBS-TUP-002
    [Test]
    procedure Scrittura_DaClasse_ValoreLetto;
    // ZLIBS-TUP-002
    [Test]
    procedure Scrittura_AdAltaPosizione_ValoreLetto;
    // ZLIBS-TUP-003
    [Test]
    procedure CompatibilitaVersoAlto_TriplaComeCoppia_StessiValori;
    // ZLIBS-TUP-003
    [Test]
    procedure CompatibilitaVersoAlto_SetteElementiComeSei_StessiValori;
    // ZLIBS-TUP-003
    [Test]
    procedure CompatibilitaVersoAlto_ScritturaDallaVistaRidotta_VisibileDallaTripla;
    // ZLIBS-TUP-004
    [Test]
    procedure Lista_Liberata_LibereTuple;
    // ZLIBS-TUP-004
    [Test]
    procedure Lista_ElementoRimosso_TuplaLiberata;
    // ZLIBS-TUP-004
    [Test]
    procedure Lista_RiempitaInUnCiclo_ValoriLettiNellOrdine;
    // ZLIBS-TUP-005
    [Test]
    procedure Proprieta_OggettiNelleDuePrimePosizioni_Liberati;
    // ZLIBS-TUP-005
    [Test]
    procedure Proprieta_OggettoInTerzaPosizione_Liberato;
    // ZLIBS-TUP-005
    [Test]
    procedure Proprieta_OggettoInSettimaPosizione_Liberato;
    // ZLIBS-TUP-005
    [Test]
    procedure Proprieta_ValoriNonOggetto_NessunErrore;
    // ZLIBS-TUP-005
    [Test]
    procedure Proprieta_ValoreNil_NessunErrore;
    // ZLIBS-TUP-005
    [Test]
    procedure Proprieta_OggettoSostituito_QuelloVecchioNonLiberatoDallaTupla;
  end;

implementation

// TSentinella

constructor TSentinella.Create(Liberata: PBoolean);
begin
  inherited Create;
  FLiberata := Liberata;
end;

destructor TSentinella.Destroy;
begin
  if Assigned(FLiberata) then
    FLiberata^ := True;
  inherited;
end;

// TTestZzTuples

procedure TTestZzTuples.Creazione_Coppia_ValoriLetti;
var
  Tupla: ITuple<Integer, string>;
begin
  Tupla := TTuple<Integer, string>.Create(7, 'Rossi');

  Assert.AreEqual(7, Tupla.Value1);
  Assert.AreEqual('Rossi', Tupla.Value2);
end;

procedure TTestZzTuples.Creazione_Tripla_ValoriLetti;
var
  Tupla: ITuple<Integer, string, Boolean>;
begin
  Tupla := TTuple<Integer, string, Boolean>.Create(3, 'x', True);

  Assert.AreEqual(3, Tupla.Value1);
  Assert.AreEqual('x', Tupla.Value2);
  Assert.IsTrue(Tupla.Value3, 'terzo valore');
end;

procedure TTestZzTuples.Creazione_QuattroECinqueElementi_ValoriLetti;
var
  Quattro: ITuple<Integer, string, Boolean, Double>;
  Cinque: ITuple<Integer, string, Boolean, Double, Integer>;
begin
  Quattro := TTuple<Integer, string, Boolean, Double>.Create(1, 'due', False, 4.5);
  Cinque := TTuple<Integer, string, Boolean, Double, Integer>.Create(1, 'due', True, 4.5, 99);

  Assert.AreEqual(1, Quattro.Value1, 'quattro: primo');
  Assert.AreEqual('due', Quattro.Value2, 'quattro: secondo');
  Assert.IsFalse(Quattro.Value3, 'quattro: terzo');
  Assert.AreEqual(Double(4.5), Double(Quattro.Value4), 0.0001, 'quattro: quarto');

  Assert.IsTrue(Cinque.Value3, 'cinque: terzo');
  Assert.AreEqual(Double(4.5), Double(Cinque.Value4), 0.0001, 'cinque: quarto');
  Assert.AreEqual(99, Cinque.Value5, 'cinque: quinto');
end;

procedure TTestZzTuples.Creazione_SeiElementi_ValoriLetti;
var
  Tupla: ITuple<Integer, string, Boolean, Double, Integer, string>;
begin
  Tupla := TTuple<Integer, string, Boolean, Double, Integer, string>.Create(1, 'due', True, 4.5, 5, 'sei');

  Assert.AreEqual(5, Tupla.Value5, 'quinto');
  Assert.AreEqual('sei', Tupla.Value6, 'sesto');
  Assert.AreEqual(1, Tupla.Value1, 'primo');
end;

procedure TTestZzTuples.Creazione_SetteElementi_ValoriLetti;
var
  Tupla: ITuple<Integer, string, Boolean, Double, Int64, Char, Currency>;
begin
  Tupla := TTuple<Integer, string, Boolean, Double, Int64, Char, Currency>.Create(
    1, 'due', True, 4.5, 5000000000, 'Z', 7.25);

  Assert.AreEqual(1, Tupla.Value1, 'primo');
  Assert.AreEqual('due', Tupla.Value2, 'secondo');
  Assert.IsTrue(Tupla.Value3, 'terzo');
  Assert.AreEqual(Double(4.5), Double(Tupla.Value4), 0.0001, 'quarto');
  Assert.IsTrue(Tupla.Value5 = 5000000000, 'quinto');
  Assert.IsTrue(Tupla.Value6 = 'Z', 'sesto');
  Assert.IsTrue(Tupla.Value7 = 7.25, 'settimo');
end;

procedure TTestZzTuples.Creazione_TestoVuotoEZero_ValoriConservati;
var
  Tupla: ITuple<Integer, string>;
begin
  Tupla := TTuple<Integer, string>.Create(0, '');

  Assert.AreEqual(0, Tupla.Value1);
  Assert.AreEqual('', Tupla.Value2);
end;

procedure TTestZzTuples.Scrittura_DaInterfaccia_CambiaSoloIlValoreScritto;
var
  Tupla: ITuple<Integer, string>;
begin
  Tupla := TTuple<Integer, string>.Create(1, 'a');

  Tupla.Value2 := 'b';

  Assert.AreEqual('b', Tupla.Value2, 'valore scritto');
  Assert.AreEqual(1, Tupla.Value1, 'l''altro valore non cambia');
end;

procedure TTestZzTuples.Scrittura_DaClasse_ValoreLetto;
var
  Tupla: TTuple<Integer, string>;
begin
  // riferimento di classe: nessuna interfaccia lo libera, si libera a mano
  Tupla := TTuple<Integer, string>.Create(1, 'a');
  try
    Tupla.Value1 := 5;

    Assert.AreEqual(5, Tupla.Value1, 'dalla classe');
    Assert.AreEqual('a', Tupla.Value2, 'l''altro valore non cambia');
  finally
    Tupla.Free;
  end;
end;

procedure TTestZzTuples.Scrittura_AdAltaPosizione_ValoreLetto;
var
  Tupla: ITuple<Integer, string, Boolean, Double, Integer>;
begin
  Tupla := TTuple<Integer, string, Boolean, Double, Integer>.Create(1, 'due', False, 4.5, 5);

  Tupla.Value5 := 50;
  Tupla.Value3 := True;

  Assert.AreEqual(50, Tupla.Value5, 'quinto');
  Assert.IsTrue(Tupla.Value3, 'terzo');
  Assert.AreEqual('due', Tupla.Value2, 'secondo invariato');
end;

procedure TTestZzTuples.CompatibilitaVersoAlto_TriplaComeCoppia_StessiValori;
var
  Coppia: ITuple<Integer, string>;
begin
  Coppia := TTuple<Integer, string, Boolean>.Create(3, 'x', True);

  Assert.AreEqual(3, Coppia.Value1);
  Assert.AreEqual('x', Coppia.Value2);
end;

procedure TTestZzTuples.CompatibilitaVersoAlto_SetteElementiComeSei_StessiValori;
var
  Sei: ITuple<Integer, string, Boolean, Double, Int64, Char>;
begin
  Sei := TTuple<Integer, string, Boolean, Double, Int64, Char, Currency>.Create(
    1, 'due', True, 4.5, 5000000000, 'Z', 7.25);

  Assert.AreEqual('due', Sei.Value2, 'secondo');
  Assert.IsTrue(Sei.Value5 = 5000000000, 'quinto');
  Assert.IsTrue(Sei.Value6 = 'Z', 'sesto');
end;

procedure TTestZzTuples.CompatibilitaVersoAlto_ScritturaDallaVistaRidotta_VisibileDallaTripla;
var
  Tripla: ITuple<Integer, string, Boolean>;
  Coppia: ITuple<Integer, string>;
begin
  Tripla := TTuple<Integer, string, Boolean>.Create(3, 'x', True);
  Coppia := Tripla;

  Coppia.Value1 := 30;

  Assert.AreEqual(30, Tripla.Value1);
end;

procedure TTestZzTuples.Lista_Liberata_LibereTuple;
var
  Lista: TList<ITuple<Integer, TSentinella>>;
  Prima, Seconda, Terza: Boolean;
begin
  Prima := False;
  Seconda := False;
  Terza := False;

  Lista := TList<ITuple<Integer, TSentinella>>.Create;
  try
    Lista.Add(TTuple<Integer, TSentinella>.Create(1, TSentinella.Create(@Prima)));
    Lista.Add(TTuple<Integer, TSentinella>.Create(2, TSentinella.Create(@Seconda)));
    Lista.Add(TTuple<Integer, TSentinella>.Create(3, TSentinella.Create(@Terza)));

    Assert.IsFalse(Prima or Seconda or Terza, 'finche'' la lista le tiene, le tuple vivono');
  finally
    Lista.Free;
  end;

  Assert.IsTrue(Prima, 'prima tupla');
  Assert.IsTrue(Seconda, 'seconda tupla');
  Assert.IsTrue(Terza, 'terza tupla');
end;

procedure TTestZzTuples.Lista_ElementoRimosso_TuplaLiberata;
var
  Lista: TList<ITuple<Integer, TSentinella>>;
  Prima, Seconda: Boolean;
begin
  Prima := False;
  Seconda := False;

  Lista := TList<ITuple<Integer, TSentinella>>.Create;
  try
    Lista.Add(TTuple<Integer, TSentinella>.Create(1, TSentinella.Create(@Prima)));
    Lista.Add(TTuple<Integer, TSentinella>.Create(2, TSentinella.Create(@Seconda)));

    Lista.Delete(0);

    Assert.IsTrue(Prima, 'la tupla tolta dalla lista e'' liberata');
    Assert.IsFalse(Seconda, 'l''altra resta viva');
    Assert.AreEqual(2, Lista[0].Value1, 'l''elemento rimasto e'' il secondo');
  finally
    Lista.Free;
  end;
end;

procedure TTestZzTuples.Lista_RiempitaInUnCiclo_ValoriLettiNellOrdine;
var
  Lista: TList<ITuple<Integer, Integer>>;
  Tupla: ITuple<Integer, Integer>;
  Indice: Integer;
  Somma: Integer;
begin
  // il modo d'uso dei chiamanti: un ciclo riempie la lista, un altro la legge
  Lista := TList<ITuple<Integer, Integer>>.Create;
  try
    for Indice := 1 to 5 do
      Lista.Add(TTuple<Integer, Integer>.Create(Indice, Indice * 10));

    Somma := 0;
    Indice := 0;
    for Tupla in Lista do
    begin
      Inc(Indice);
      Assert.AreEqual(Indice, Tupla.Value1, 'ordine');
      Somma := Somma + Tupla.Value2;
    end;

    Assert.AreEqual(150, Somma, 'somma di 10+20+30+40+50');
  finally
    Lista.Free;
  end;
end;

procedure TTestZzTuples.Proprieta_OggettiNelleDuePrimePosizioni_Liberati;
var
  Tupla: ITuple<TSentinella, TSentinella>;
  Primo, Secondo: Boolean;
begin
  Primo := False;
  Secondo := False;

  Tupla := TTuple<TSentinella, TSentinella>.Create(TSentinella.Create(@Primo), TSentinella.Create(@Secondo));
  Assert.IsFalse(Primo or Secondo, 'finche'' la tupla vive gli oggetti vivono');

  Tupla := nil;

  Assert.IsTrue(Primo, 'primo oggetto');
  Assert.IsTrue(Secondo, 'secondo oggetto');
end;

procedure TTestZzTuples.Proprieta_OggettoInTerzaPosizione_Liberato;
var
  Tupla: ITuple<Integer, string, TSentinella>;
  Liberato: Boolean;
begin
  Liberato := False;

  Tupla := TTuple<Integer, string, TSentinella>.Create(1, 'a', TSentinella.Create(@Liberato));
  Tupla := nil;

  Assert.IsTrue(Liberato);
end;

procedure TTestZzTuples.Proprieta_OggettoInSettimaPosizione_Liberato;
var
  Tupla: ITuple<Integer, string, Boolean, Double, Int64, Char, TSentinella>;
  Liberato: Boolean;
begin
  Liberato := False;

  Tupla := TTuple<Integer, string, Boolean, Double, Int64, Char, TSentinella>.Create(
    1, 'due', True, 4.5, 5, 'Z', TSentinella.Create(@Liberato));
  Assert.IsFalse(Liberato, 'vivo finche'' la tupla vive');

  Tupla := nil;

  Assert.IsTrue(Liberato, 'ogni livello libera il proprio valore');
end;

procedure TTestZzTuples.Proprieta_ValoriNonOggetto_NessunErrore;
var
  Tupla: ITuple<Integer, string, Boolean, Currency>;
begin
  Tupla := TTuple<Integer, string, Boolean, Currency>.Create(1, 'a', True, 2.5);

  Tupla := nil;

  Assert.IsTrue(Tupla = nil, 'distrutta senza errori');
end;

procedure TTestZzTuples.Proprieta_ValoreNil_NessunErrore;
var
  Tupla: ITuple<TSentinella, Integer>;
begin
  Tupla := TTuple<TSentinella, Integer>.Create(nil, 1);

  Tupla := nil;

  Assert.IsTrue(Tupla = nil, 'distrutta senza errori');
end;

procedure TTestZzTuples.Proprieta_OggettoSostituito_QuelloVecchioNonLiberatoDallaTupla;
var
  Tupla: ITuple<Integer, TSentinella>;
  Vecchio, Nuovo: Boolean;
  Oggetto: TSentinella;
begin
  Vecchio := False;
  Nuovo := False;

  Oggetto := TSentinella.Create(@Vecchio);
  try
    Tupla := TTuple<Integer, TSentinella>.Create(1, Oggetto);
    // la sostituzione non libera il vecchio oggetto: resta a carico di chi lo ha tolto
    Tupla.Value2 := TSentinella.Create(@Nuovo);

    Assert.IsFalse(Vecchio, 'la scrittura non libera il valore precedente');

    Tupla := nil;

    Assert.IsTrue(Nuovo, 'alla distruzione e'' liberato quello nuovo');
    Assert.IsFalse(Vecchio, 'quello vecchio non appartiene piu'' alla tupla');
  finally
    Oggetto.Free;
  end;
  Assert.IsTrue(Vecchio, 'liberato da chi lo possedeva');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZzTuples);

end.
