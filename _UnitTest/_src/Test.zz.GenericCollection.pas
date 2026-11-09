// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.GenericCollection;

// Test DUnitX di zLibs\zz.GenericCollection.pas: la collezione tipizzata
// TzGenericCollection<T> con cui WT e Gesty costruiscono i loro elenchi di
// oggetti (specifica ZLIBS-GCO, "Collezione generica.md"). Nessuna dipendenza
// da database o interfaccia; i file di prova stanno nella cartella temporanea.
//
// Le classi di prova (TVoce e le raccolte derivate) imitano lo schema dei
// chiamanti: un elemento con proprieta' pubblicate, una raccolta che ridefinisce
// Compare, una che non lo ridefinisce. Come nei chiamanti, la raccolta si crea
// con la classe dell'elemento: TVoci.Create(TVoce).
//
// Il compilatore segnala (avviso, non errore) che le raccolte contengono i
// metodi astratti Decode e Encode di TJSONCollection: e' il comportamento reale
// dei chiamanti (ZLIBS-GCO-008).
//
// DIV-GCO-1 e' fotografata da una prova che va capovolta quando il codice
// sara' corretto. Le altre divergenze (IndexOf e Remove con valore nullo,
// ordinamento non stabile, classe dell'elemento non legata a T, codice morto)
// non sono provate: le prime due sollevano violazioni di accesso, le altre
// sono questioni di struttura.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  DUnitX.TestFramework,
  zz.GenericCollection;

type
  // Elemento di prova, con Assign ridefinito come fanno i chiamanti.
  TVoce = class(TCollectionItem)
  private
    FNome: string;
    FValore: Integer;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Nome: string read FNome write FNome;
    property Valore: Integer read FValore write FValore;
  end;

  // Raccolta senza Compare ridefinito.
  TVoci = class(TzGenericCollection<TVoce>)
  end;

  // Raccolta che ordina per Valore crescente.
  TVociOrdinate = class(TzGenericCollection<TVoce>)
  protected
    function Compare(Item1, Item2: TVoce): Integer; override;
  end;

  // Elemento senza Assign ridefinito: eredita quello di TCollectionItem.
  TVoceNuda = class(TCollectionItem)
  private
    FNome: string;
  published
    property Nome: string read FNome write FNome;
  end;

  TVociNude = class(TzGenericCollection<TVoceNuda>)
  end;

  [TestFixture]
  TTestZzGenericCollection = class
  private
    FVoci: TVoci;
    function Aggiungi(const Collezione: TVoci; const Nome: string; const Valore: Integer): TVoce;
    function NomiDi(const Collezione: TzGenericCollection<TVoce>): string;
    function EccezioneDi(const Procedura: TProc): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZLIBS-GCO-001
    [Test]
    procedure Add_DueElementi_ClasseDellElementoEOrdineDiInserimento;
    // ZLIBS-GCO-001
    [Test]
    procedure Insert_InPrimaPosizione_ElementoAlPrimoPosto;
    // ZLIBS-GCO-001
    [Test]
    procedure Items_ProprietaPredefinita_EquivaleAItems;
    // ZLIBS-GCO-001
    [Test]
    procedure Remove_ElementoPresente_Eliminato;
    // ZLIBS-GCO-002
    [Test]
    procedure ForIn_ElementiPresenti_PercorsiNelOrdine;
    // ZLIBS-GCO-002
    [Test]
    procedure ForIn_CollezioneVuota_NessunGiro;
    // ZLIBS-GCO-003
    [Test]
    procedure IndexOf_Trovato_RestituisceIlPrimoIndice;
    // ZLIBS-GCO-003
    [Test]
    procedure IndexOf_NonTrovato_MenoUno;
    // ZLIBS-GCO-003
    [Test]
    procedure Get_Trovato_RestituisceLElemento;
    // ZLIBS-GCO-003
    [Test]
    procedure Get_NonTrovatoSenzaAggiunta_Nil;
    // ZLIBS-GCO-003
    [Test]
    procedure Get_NonTrovatoConAggiunta_AggiungeERestituisceIlNuovo;
    // ZLIBS-GCO-004
    [Test]
    procedure ForEach_FunzioneSempreVera_PercorreTutto;
    // ZLIBS-GCO-004
    [Test]
    procedure ForEach_FunzioneFalsa_InterrompeIlGiro;
    // ZLIBS-GCO-005
    [Test]
    procedure Sort_CompareRidefinita_OrdinaPerValore;
    // ZLIBS-GCO-005
    [Test]
    procedure Sort_GiaOrdinata_RestaInvariata;
    // ZLIBS-GCO-005
    [Test]
    procedure Sort_CompareNonRidefinita_NessunElementoPerso;
    // ZLIBS-GCO-006
    [Test]
    procedure SetItem_ConAssignRidefinito_CopiaIValori;
    // ZLIBS-GCO-006
    [Test]
    procedure SetItem_SenzaAssignRidefinito_NonCopiaLeProprieta;
    // ZLIBS-GCO-007
    [Test]
    procedure SaveLoadStream_ElementiEProprieta_Ripristinati;
    // ZLIBS-GCO-007
    [Test]
    procedure AsText_ViaDiAndataERitorno_ElementiUguali;
    // ZLIBS-GCO-007
    [Test]
    procedure AsText_Lettura_ContieneNomiEValoriDelleProprieta;
    // ZLIBS-GCO-007
    [Test]
    procedure AsText_Accentate_ConservateNelViaggio;
    // ZLIBS-GCO-007
    [Test]
    procedure AsText_TestoVuoto_SvuotaLaCollezione;
    // ZLIBS-GCO-007
    [Test]
    procedure LoadFromStream_ConElementi_SostituisceQuelliPresenti;
    // ZLIBS-GCO-007
    [Test]
    procedure SaveLoadFile_ElementiEProprieta_Ripristinati;
    // ZLIBS-GCO-007
    [Test]
    procedure LoadFromFile_FileInesistente_SollevaEccezione;
    // ZLIBS-GCO-007
    [Test]
    procedure StreamNullo_SaveELoad_NessunEffettoNessunErrore;
    // ZLIBS-GCO-008
    [Test]
    procedure Encode_NellaBase_SollevaEAbstractError;
    // ZLIBS-GCO-008
    [Test]
    procedure Decode_NellaBase_SollevaEAbstractError;
    // ZLIBS-GCO-008
    [Test]
    procedure Json_Proprieta_ConservaIlTesto;
    // DIV-GCO-1 (da capovolgere quando il codice sara' corretto)
    [Test]
    procedure Divergenza_DIV_GCO_1_TestoDiCollezioneVuota_NonSvuotaLaCollezione;
  end;

implementation

// TVoce

procedure TVoce.Assign(Source: TPersistent);
begin
  if Source is TVoce then
  begin
    FNome := TVoce(Source).Nome;
    FValore := TVoce(Source).Valore;
  end
  else
    inherited Assign(Source);
end;

// TVociOrdinate

function TVociOrdinate.Compare(Item1, Item2: TVoce): Integer;
begin
  Result := Item1.Valore - Item2.Valore;
end;

// TTestZzGenericCollection

procedure TTestZzGenericCollection.Setup;
begin
  FVoci := TVoci.Create(TVoce);
end;

procedure TTestZzGenericCollection.TearDown;
begin
  FreeAndNil(FVoci);
end;

function TTestZzGenericCollection.Aggiungi(const Collezione: TVoci; const Nome: string; const Valore: Integer): TVoce;
begin
  Result := Collezione.Add;
  Result.Nome := Nome;
  Result.Valore := Valore;
end;

function TTestZzGenericCollection.NomiDi(const Collezione: TzGenericCollection<TVoce>): string;
var
  Voce: TVoce;
begin
  Result := '';
  for Voce in Collezione do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + Voce.Nome;
  end;
end;

function TTestZzGenericCollection.EccezioneDi(const Procedura: TProc): string;
begin
  Result := '';
  try
    Procedura();
  except
    on E: Exception do
      Result := E.ClassName;
  end;
end;

procedure TTestZzGenericCollection.Add_DueElementi_ClasseDellElementoEOrdineDiInserimento;
var
  Primo: TVoce;
  Secondo: TVoce;
begin
  Primo := Aggiungi(FVoci, 'Rossi', 3);
  Secondo := Aggiungi(FVoci, 'Bianchi', 1);

  Assert.AreEqual(2, FVoci.Count, 'due elementi');
  Assert.IsTrue(Primo.ClassType = TVoce, 'Add restituisce gia'' il tipo dell''elemento');
  Assert.IsTrue(FVoci.Items[0] = Primo, 'il primo e'' in posizione 0');
  Assert.IsTrue(FVoci.Items[1] = Secondo, 'il secondo e'' in posizione 1');
  Assert.AreEqual('Rossi,Bianchi', NomiDi(FVoci));
end;

procedure TTestZzGenericCollection.Insert_InPrimaPosizione_ElementoAlPrimoPosto;
var
  Nuovo: TVoce;
begin
  Aggiungi(FVoci, 'B', 2);
  Aggiungi(FVoci, 'C', 3);

  Nuovo := FVoci.Insert(0);
  Nuovo.Nome := 'A';

  Assert.AreEqual(3, FVoci.Count, 'tre elementi');
  Assert.AreEqual('A,B,C', NomiDi(FVoci));
  Assert.AreEqual(0, Nuovo.Index, 'indice del nuovo elemento');
end;

procedure TTestZzGenericCollection.Items_ProprietaPredefinita_EquivaleAItems;
begin
  Aggiungi(FVoci, 'Rossi', 3);
  Aggiungi(FVoci, 'Bianchi', 1);

  // FVoci[1] e' la proprieta' predefinita Items[1]
  Assert.AreEqual('Bianchi', FVoci[1].Nome);
  Assert.AreEqual(1, FVoci[1].Valore);
end;

procedure TTestZzGenericCollection.Remove_ElementoPresente_Eliminato;
var
  Voce: TVoce;
begin
  Aggiungi(FVoci, 'A', 1);
  Voce := Aggiungi(FVoci, 'B', 2);
  Aggiungi(FVoci, 'C', 3);

  FVoci.Remove(Voce);

  Assert.AreEqual(2, FVoci.Count, 'due elementi rimasti');
  Assert.AreEqual('A,C', NomiDi(FVoci));
end;

procedure TTestZzGenericCollection.ForIn_ElementiPresenti_PercorsiNelOrdine;
var
  Voce: TVoce;
  Somma: Integer;
  Giri: Integer;
begin
  Aggiungi(FVoci, 'A', 10);
  Aggiungi(FVoci, 'B', 20);
  Aggiungi(FVoci, 'C', 30);

  Somma := 0;
  Giri := 0;
  for Voce in FVoci do
  begin
    Inc(Giri);
    Somma := Somma + Voce.Valore;
  end;

  Assert.AreEqual(3, Giri, 'tre giri');
  Assert.AreEqual(60, Somma, 'somma dei valori');
  Assert.AreEqual('A,B,C', NomiDi(FVoci), 'ordine di inserimento');
end;

procedure TTestZzGenericCollection.ForIn_CollezioneVuota_NessunGiro;
var
  Voce: TVoce;
  Giri: Integer;
begin
  Giri := 0;
  for Voce in FVoci do
    Inc(Giri);

  Assert.AreEqual(0, Giri);
end;

procedure TTestZzGenericCollection.IndexOf_Trovato_RestituisceIlPrimoIndice;
begin
  Aggiungi(FVoci, 'A', 5);
  Aggiungi(FVoci, 'B', 7);
  Aggiungi(FVoci, 'C', 7);

  Assert.AreEqual(1, FVoci.IndexOf(
    function(Voce: TVoce): Boolean
    begin
      Result := Voce.Valore = 7;
    end), 'primo elemento con valore 7');
end;

procedure TTestZzGenericCollection.IndexOf_NonTrovato_MenoUno;
begin
  Aggiungi(FVoci, 'A', 5);

  Assert.AreEqual(-1, FVoci.IndexOf(
    function(Voce: TVoce): Boolean
    begin
      Result := Voce.Valore = 99;
    end), 'nessun elemento con valore 99');

  // collezione vuota
  FVoci.Clear;
  Assert.AreEqual(-1, FVoci.IndexOf(
    function(Voce: TVoce): Boolean
    begin
      Result := True;
    end), 'collezione vuota');
end;

procedure TTestZzGenericCollection.Get_Trovato_RestituisceLElemento;
var
  Trovato: TVoce;
begin
  Aggiungi(FVoci, 'A', 5);
  Aggiungi(FVoci, 'B', 7);

  Trovato := FVoci.Get(
    function(Voce: TVoce): Boolean
    begin
      Result := Voce.Nome = 'B';
    end);

  Assert.IsTrue(Trovato <> nil, 'trovato');
  Assert.AreEqual(7, Trovato.Valore);
  Assert.AreEqual(2, FVoci.Count, 'nessun elemento aggiunto');
end;

procedure TTestZzGenericCollection.Get_NonTrovatoSenzaAggiunta_Nil;
var
  Trovato: TVoce;
begin
  Aggiungi(FVoci, 'A', 5);

  Trovato := FVoci.Get(
    function(Voce: TVoce): Boolean
    begin
      Result := Voce.Nome = 'Z';
    end);

  Assert.IsTrue(Trovato = nil, 'non trovato: nil');
  Assert.AreEqual(1, FVoci.Count, 'nessun elemento aggiunto');
end;

procedure TTestZzGenericCollection.Get_NonTrovatoConAggiunta_AggiungeERestituisceIlNuovo;
var
  Nuovo: TVoce;
begin
  Aggiungi(FVoci, 'A', 5);

  Nuovo := FVoci.Get(
    function(Voce: TVoce): Boolean
    begin
      Result := Voce.Nome = 'Z';
    end, True);

  Assert.IsTrue(Nuovo <> nil, 'creato');
  Assert.AreEqual(2, FVoci.Count, 'un elemento aggiunto');
  Assert.IsTrue(FVoci.Items[1] = Nuovo, 'il nuovo e'' l''ultimo');
  Assert.AreEqual('', Nuovo.Nome, 'il nuovo e'' vuoto: lo riempie il chiamante');
end;

procedure TTestZzGenericCollection.ForEach_FunzioneSempreVera_PercorreTutto;
var
  Visti: Integer;
begin
  Aggiungi(FVoci, 'A', 1);
  Aggiungi(FVoci, 'B', 2);
  Aggiungi(FVoci, 'C', 3);

  Visti := 0;
  FVoci.ForEach(
    function(Voce: TVoce): Boolean
    begin
      Inc(Visti);
      Result := True;
    end);

  Assert.AreEqual(3, Visti);
end;

procedure TTestZzGenericCollection.ForEach_FunzioneFalsa_InterrompeIlGiro;
var
  Visti: Integer;
begin
  Aggiungi(FVoci, 'A', 1);
  Aggiungi(FVoci, 'B', 2);
  Aggiungi(FVoci, 'C', 3);

  Visti := 0;
  FVoci.ForEach(
    function(Voce: TVoce): Boolean
    begin
      Inc(Visti);
      // Falso = fermati: al secondo elemento il giro finisce
      Result := Voce.Valore < 2;
    end);

  Assert.AreEqual(2, Visti, 'il terzo elemento non viene visitato');
end;

procedure TTestZzGenericCollection.Sort_CompareRidefinita_OrdinaPerValore;
var
  Ordinate: TVociOrdinate;
  Voce: TVoce;
begin
  Ordinate := TVociOrdinate.Create(TVoce);
  try
    Voce := Ordinate.Add;
    Voce.Nome := 'C';
    Voce.Valore := 3;
    Voce := Ordinate.Add;
    Voce.Nome := 'A';
    Voce.Valore := 1;
    Voce := Ordinate.Add;
    Voce.Nome := 'B';
    Voce.Valore := 2;
    Voce := Ordinate.Add;
    Voce.Nome := 'D';
    Voce.Valore := 4;

    Ordinate.Sort;

    Assert.AreEqual('A,B,C,D', NomiDi(Ordinate));
    Assert.AreEqual(0, Ordinate.Items[0].Index, 'indice aggiornato dopo l''ordinamento');
  finally
    Ordinate.Free;
  end;
end;

procedure TTestZzGenericCollection.Sort_GiaOrdinata_RestaInvariata;
var
  Ordinate: TVociOrdinate;
  Voce: TVoce;
begin
  Ordinate := TVociOrdinate.Create(TVoce);
  try
    Voce := Ordinate.Add;
    Voce.Nome := 'A';
    Voce.Valore := 1;
    Voce := Ordinate.Add;
    Voce.Nome := 'B';
    Voce.Valore := 2;
    Voce := Ordinate.Add;
    Voce.Nome := 'C';
    Voce.Valore := 3;

    Ordinate.Sort;

    Assert.AreEqual('A,B,C', NomiDi(Ordinate));
  finally
    Ordinate.Free;
  end;
end;

procedure TTestZzGenericCollection.Sort_CompareNonRidefinita_NessunElementoPerso;
var
  Somma: Integer;
  Voce: TVoce;
begin
  // con la Compare della base (sempre 0) l'ordine non e' garantito, ma gli
  // elementi restano tutti
  Aggiungi(FVoci, 'A', 1);
  Aggiungi(FVoci, 'B', 2);
  Aggiungi(FVoci, 'C', 3);

  FVoci.Sort;

  Somma := 0;
  for Voce in FVoci do
    Somma := Somma + Voce.Valore;
  Assert.AreEqual(3, FVoci.Count, 'tre elementi');
  Assert.AreEqual(6, Somma, 'stessi valori');
end;

procedure TTestZzGenericCollection.SetItem_ConAssignRidefinito_CopiaIValori;
var
  Sorgente: TVoce;
begin
  Aggiungi(FVoci, 'A', 1);
  Sorgente := Aggiungi(FVoci, 'B', 2);

  FVoci[0] := Sorgente;

  Assert.AreEqual(2, FVoci.Count, 'nessun elemento aggiunto');
  Assert.AreEqual('B', FVoci[0].Nome, 'nome copiato');
  Assert.AreEqual(2, FVoci[0].Valore, 'valore copiato');
  Assert.IsFalse(FVoci[0] = Sorgente, 'e'' una copia, non lo stesso oggetto');
end;

procedure TTestZzGenericCollection.SetItem_SenzaAssignRidefinito_NonCopiaLeProprieta;
var
  Nude: TVociNude;
  Prima: TVoceNuda;
  Seconda: TVoceNuda;
begin
  Nude := TVociNude.Create(TVoceNuda);
  try
    Prima := Nude.Add;
    Prima.Nome := 'A';
    Seconda := Nude.Add;
    Seconda.Nome := 'B';

    // l'Assign di TCollectionItem non e' ridefinito dal discendente: l'assegnazione
    // solleva EConvertError (i discendenti devono ridefinirlo) e il nome non cambia
    Assert.WillRaise(
      procedure
      begin
        Nude[0] := Seconda;
      end,
      EConvertError);
    Assert.AreEqual('A', Nude[0].Nome, 'il nome non e'' stato copiato');
  finally
    Nude.Free;
  end;
end;

procedure TTestZzGenericCollection.SaveLoadStream_ElementiEProprieta_Ripristinati;
var
  Flusso: TMemoryStream;
  Letti: TVoci;
begin
  Aggiungi(FVoci, 'Rossi', 3);
  Aggiungi(FVoci, 'Bianchi', 1);

  Flusso := TMemoryStream.Create;
  try
    FVoci.SaveToStream(Flusso);
    Flusso.Position := 0;

    Letti := TVoci.Create(TVoce);
    try
      Letti.LoadFromStream(Flusso);

      Assert.AreEqual(2, Letti.Count, 'due elementi letti');
      Assert.AreEqual('Rossi', Letti[0].Nome, 'primo: nome');
      Assert.AreEqual(3, Letti[0].Valore, 'primo: valore');
      Assert.AreEqual('Bianchi', Letti[1].Nome, 'secondo: nome');
      Assert.AreEqual(1, Letti[1].Valore, 'secondo: valore');
    finally
      Letti.Free;
    end;
  finally
    Flusso.Free;
  end;
end;

procedure TTestZzGenericCollection.AsText_ViaDiAndataERitorno_ElementiUguali;
var
  Testo: string;
  Letti: TVoci;
begin
  Aggiungi(FVoci, 'Rossi', 3);
  Aggiungi(FVoci, 'Bianchi', 1);
  Aggiungi(FVoci, 'Verdi', 2);

  Testo := FVoci.AsText;

  Letti := TVoci.Create(TVoce);
  try
    Letti.AsText := Testo;

    Assert.AreEqual(3, Letti.Count, 'tre elementi');
    Assert.AreEqual('Rossi,Bianchi,Verdi', NomiDi(Letti), 'stesso ordine');
    Assert.AreEqual(2, Letti[2].Valore, 'valore dell''ultimo');
  finally
    Letti.Free;
  end;
end;

procedure TTestZzGenericCollection.AsText_Lettura_ContieneNomiEValoriDelleProprieta;
var
  Testo: string;
begin
  Aggiungi(FVoci, 'Rossi', 3);

  Testo := FVoci.AsText;

  Assert.IsTrue(Pos('Nome', Testo) > 0, 'il nome della proprieta'' Nome');
  Assert.IsTrue(Pos('Rossi', Testo) > 0, 'il valore Rossi');
  Assert.IsTrue(Pos('Valore', Testo) > 0, 'il nome della proprieta'' Valore');
end;

procedure TTestZzGenericCollection.AsText_Accentate_ConservateNelViaggio;
var
  Letti: TVoci;
  Accentata: string;
begin
  // caratteri non ASCII scritti con #$XXXX per tenere il sorgente leggibile
  Accentata := 'Perch' + #$00E9 + ' ' + #$00E0 + #$00F2;
  Aggiungi(FVoci, Accentata, 1);

  Letti := TVoci.Create(TVoce);
  try
    Letti.AsText := FVoci.AsText;

    Assert.AreEqual(1, Letti.Count, 'un elemento');
    Assert.IsTrue(Letti[0].Nome = Accentata, 'testo con accenti conservato');
  finally
    Letti.Free;
  end;
end;

procedure TTestZzGenericCollection.AsText_TestoVuoto_SvuotaLaCollezione;
begin
  Aggiungi(FVoci, 'A', 1);
  Aggiungi(FVoci, 'B', 2);

  FVoci.AsText := '';

  Assert.AreEqual(0, FVoci.Count);
end;

procedure TTestZzGenericCollection.LoadFromStream_ConElementi_SostituisceQuelliPresenti;
var
  Sorgente: TVoci;
  Destinazione: TVoci;
begin
  Sorgente := TVoci.Create(TVoce);
  Destinazione := TVoci.Create(TVoce);
  try
    Aggiungi(Sorgente, 'Nuovo', 9);
    Aggiungi(Destinazione, 'Vecchio1', 1);
    Aggiungi(Destinazione, 'Vecchio2', 2);
    Aggiungi(Destinazione, 'Vecchio3', 3);

    Destinazione.AsText := Sorgente.AsText;

    Assert.AreEqual(1, Destinazione.Count, 'gli elementi presenti sono sostituiti, non accodati');
    Assert.AreEqual('Nuovo', Destinazione[0].Nome);
  finally
    Destinazione.Free;
    Sorgente.Free;
  end;
end;

procedure TTestZzGenericCollection.SaveLoadFile_ElementiEProprieta_Ripristinati;
var
  Cartella: string;
  Percorso: string;
  Letti: TVoci;
begin
  Cartella := TPath.Combine(TPath.GetTempPath, 'zPackTest_' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Cartella);
  try
    Percorso := TPath.Combine(Cartella, 'voci.txt');
    Aggiungi(FVoci, 'Rossi', 3);
    Aggiungi(FVoci, 'Bianchi', 1);

    FVoci.SaveToFile(Percorso);
    Assert.IsTrue(TFile.Exists(Percorso), 'il file e'' stato scritto');

    Letti := TVoci.Create(TVoce);
    try
      Letti.LoadFromFile(Percorso);

      Assert.AreEqual(2, Letti.Count, 'due elementi');
      Assert.AreEqual('Rossi,Bianchi', NomiDi(Letti));
      Assert.AreEqual(1, Letti[1].Valore, 'valore del secondo');
    finally
      Letti.Free;
    end;
  finally
    if TDirectory.Exists(Cartella) then
      TDirectory.Delete(Cartella, True);
  end;
end;

procedure TTestZzGenericCollection.LoadFromFile_FileInesistente_SollevaEccezione;
var
  Cartella: string;
  Percorso: string;
  Classe: string;
begin
  Cartella := TPath.Combine(TPath.GetTempPath, 'zPackTest_' + TGUID.NewGuid.ToString);
  Percorso := TPath.Combine(Cartella, 'non-esiste.txt');

  Classe := EccezioneDi(
    procedure
    begin
      FVoci.LoadFromFile(Percorso);
    end);

  Assert.AreEqual('EFOpenError', Classe);
end;

procedure TTestZzGenericCollection.StreamNullo_SaveELoad_NessunEffettoNessunErrore;
begin
  Aggiungi(FVoci, 'A', 1);

  FVoci.SaveToStream(nil);
  FVoci.LoadFromStream(nil);

  Assert.AreEqual(1, FVoci.Count, 'la collezione non cambia');
end;

procedure TTestZzGenericCollection.Encode_NellaBase_SollevaEAbstractError;
var
  Classe: string;
begin
  Classe := EccezioneDi(
    procedure
    begin
      FVoci.Encode;
    end);

  Assert.AreEqual('EAbstractError', Classe);
end;

procedure TTestZzGenericCollection.Decode_NellaBase_SollevaEAbstractError;
var
  Classe: string;
begin
  Classe := EccezioneDi(
    procedure
    begin
      FVoci.Decode(nil);
    end);

  Assert.AreEqual('EAbstractError', Classe);
end;

procedure TTestZzGenericCollection.Json_Proprieta_ConservaIlTesto;
begin
  Assert.AreEqual('', FVoci.JSON, 'inizialmente vuota');

  FVoci.JSON := '{"a":1}';

  Assert.AreEqual('{"a":1}', FVoci.JSON);
end;

procedure TTestZzGenericCollection.Divergenza_DIV_GCO_1_TestoDiCollezioneVuota_NonSvuotaLaCollezione;
var
  Vuota: TVoci;
  TestoVuota: string;
begin
  // Documenta il comportamento attuale: il testo prodotto da una collezione
  // vuota non contiene elementi, e il lettore svuota la destinazione solo
  // quando trova almeno un elemento. Da capovolgere (Count = 0) quando il
  // codice sara' corretto.
  Vuota := TVoci.Create(TVoce);
  try
    TestoVuota := Vuota.AsText;
  finally
    Vuota.Free;
  end;
  Aggiungi(FVoci, 'A', 1);
  Aggiungi(FVoci, 'B', 2);

  FVoci.AsText := TestoVuota;

  Assert.AreEqual(2, FVoci.Count, 'gli elementi presenti restano');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZzGenericCollection);

end.
