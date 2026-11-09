// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.Nullable;

// Test DUnitX di zLibs\zz.Nullable.pas: il tipo generico TNullable<T> visto
// "per tipo" (specifica ZLIBS-NUL, "Nullable generico.md"). Il comportamento
// di base (valore o nulla, nullo uguale al predefinito, layout dei campi per
// TzStoredProc) e' descritto da ZFIB-NUL-001..007 in "Valori nullable.md" di
// zFIB; qui si provano i confronti, l'ordinamento e le conversioni sui tipi
// effettivamente usati (stringhe, numeri, date, valute, GUID).
//
// Nessuna dipendenza da database o interfaccia.
//
// Le divergenze DIV-NUL-1, 2 e 4 sono gia' coperte dalla specifica di zFIB
// (DIV-NUL-2 e' il contenuto stesso di ZLIBS-NUL-001 e 002). DIV-NUL-6 e 7
// riguardano codice non raggiungibile da fuori (ramo morto, clausola uses).
// DIV-NUL-5 e' fotografata dall'ultima prova: va capovolta quando il codice
// sara' corretto.

interface

uses
  System.SysUtils,
  System.Variants,
  DUnitX.TestFramework,
  zz.Nullable;

type
  [TestFixture]
  TTestZzNullable = class
  private
    // Restituisce il nome della classe dell'eccezione sollevata, o stringa
    // vuota se la procedura termina senza errori.
    function EccezioneDi(const Procedura: TProc): string;
  public
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_StringheCheDifferisconoPerMaiuscole_NonUguali;
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_StringaConSpazioFinale_NonUguale;
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_Decimali_ConfrontoEsatto;
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_DataOra_UgualeSoloLoStessoIstante;
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_Guid_NulloUgualeAlGuidVuoto;
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_Valuta_UgualeAlValoreEquivalente;
    // ZLIBS-NUL-001
    [Test]
    procedure Uguaglianza_AnsiString_UgualeAlTestoEquivalente;
    // ZLIBS-NUL-002
    [Test]
    procedure Ordine_NulloControNegativo_NulloMaggiore;
    // ZLIBS-NUL-002
    [Test]
    procedure Ordine_NulloControPositivo_NulloMinore;
    // ZLIBS-NUL-002
    [Test]
    procedure Ordine_StringheMaiuscoleEMinuscole_OrdineOrdinale;
    // ZLIBS-NUL-002
    [Test]
    procedure Ordine_Date_PrimaEDopo;
    // ZLIBS-NUL-002
    [Test]
    procedure Ordine_DueNullable_ConfrontoSuiValori;
    // ZLIBS-NUL-002
    [Test]
    procedure Ordine_ValoriUguali_MinoreOUgualeEMaggioreOUgualeVeri;
    // ZLIBS-NUL-003
    [Test]
    procedure ValoreASinistra_UgualeEDiverso_ComeAGestra;
    // ZLIBS-NUL-003
    [Test]
    procedure ValoreASinistra_Ordine_ComeADestra;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_Stringa_TestoConservato;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_Intero_ValoreConservato;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_DataOra_ValoreConservato;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_Valuta_ValoreConservato;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_Booleano_ValoreConservato;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_Nullo_VariantNullPerOgniTipo;
    // ZLIBS-NUL-004
    [Test]
    procedure VersoVariant_ValorePredefinitoPresente_NonDiventaNull;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_DataOra_ValoreConservato;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_Valuta_ValoreConservato;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_Booleano_ValoreConservato;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_InteroInNullableInt64_ValoreConservato;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_NullEUnassigned_NulloPerOgniTipo;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_SoloSpazio_NonNullo;
    // ZLIBS-NUL-005
    [Test]
    procedure DaVariant_ViaDiAndataERitorno_ValoreEPresenzaConservati;
    // ZLIBS-NUL-006
    [Test]
    procedure Copia_AssegnazioneFraNullable_IndipendenteDalSorgente;
    // ZLIBS-NUL-006
    [Test]
    procedure Clear_DopoUnValore_ValoreAzzeratoERiassegnabile;
    // ZLIBS-NUL-006
    [Test]
    procedure Assegnazione_ValorePredefinitoDelTipo_HaValore;
    // ZLIBS-NUL-006
    [Test]
    procedure GetValueOrDefault_ConValorePredefinitoPresente_RestituisceIlValore;
    // ZLIBS-NUL-007
    [Test]
    procedure Puntatore_Nil_DiventaNullo;
    // ZLIBS-NUL-007
    [Test]
    procedure Puntatore_NonNil_SollevaEInvalidOperation;
    // ZLIBS-NUL-008
    [Test]
    procedure Sigle_OgnunaIdenticaAlGenericoEInizialmenteNulla;
    // ZLIBS-NUL-008
    [Test]
    procedure Sigle_ConValore_ValoreLetto;
    // DIV-NUL-5 (da capovolgere quando il codice sara' corretto)
    [Test]
    procedure Divergenza_DIV_NUL_5_GuidVersoVariant_SollevaEccezione;
  end;

implementation

const
  GuidProva: TGUID = '{6F9619FF-8B86-D011-B42D-00C04FC964FF}';
  AltroGuid: TGUID = '{11111111-2222-3333-4444-555555555555}';

// TTestZzNullable

function TTestZzNullable.EccezioneDi(const Procedura: TProc): string;
begin
  Result := '';
  try
    Procedura();
  except
    on E: Exception do
      Result := E.ClassName;
  end;
end;

procedure TTestZzNullable.Uguaglianza_StringheCheDifferisconoPerMaiuscole_NonUguali;
var
  Testo: TNullableString;
begin
  Testo := 'Abc';

  Assert.IsTrue(Testo = 'Abc', 'stesso testo');
  Assert.IsFalse(Testo = 'abc', 'maiuscole diverse: non uguale');
  Assert.IsTrue(Testo <> 'abc', 'maiuscole diverse: diverso');
end;

procedure TTestZzNullable.Uguaglianza_StringaConSpazioFinale_NonUguale;
var
  Testo: TNullableString;
begin
  Testo := 'Abc ';

  Assert.IsFalse(Testo = 'Abc', 'lo spazio finale conta');
  Assert.IsTrue(Testo = 'Abc ', 'stesso testo con lo spazio');
end;

procedure TTestZzNullable.Uguaglianza_Decimali_ConfrontoEsatto;
var
  Numero: TNullableDouble;
  Uguale: Double;
  Vicino: Double;
begin
  Uguale := 1.5;
  Vicino := 1.5000001;
  Numero := Uguale;

  Assert.IsTrue(Numero = Uguale, 'stesso valore');
  Assert.IsFalse(Numero = Vicino, 'nessuna tolleranza: un valore vicino e'' diverso');
  Assert.IsTrue(Numero <> Vicino, 'diverso da un valore vicino');
end;

procedure TTestZzNullable.Uguaglianza_DataOra_UgualeSoloLoStessoIstante;
var
  Istante: TNullableDateTime;
  Stesso: TDateTime;
  UnSecondoDopo: TDateTime;
begin
  Stesso := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 0, 0);
  UnSecondoDopo := Stesso + EncodeTime(0, 0, 1, 0);
  Istante := Stesso;

  Assert.IsTrue(Istante = Stesso, 'stesso istante');
  Assert.IsFalse(Istante = UnSecondoDopo, 'un secondo dopo: non uguale');
end;

procedure TTestZzNullable.Uguaglianza_Guid_NulloUgualeAlGuidVuoto;
var
  Identificativo: TNullableGuid;
  Vuoto: TGUID;
  Prova: TGUID;
  Altro: TGUID;
begin
  Prova := GuidProva;
  Altro := AltroGuid;
  Vuoto := TGUID.Empty;

  Identificativo := Prova;
  Assert.IsTrue(Identificativo = Prova, 'stesso GUID');
  Assert.IsFalse(Identificativo = Altro, 'GUID diverso');

  // il nullo vale il GUID vuoto (tutti zeri), come il nullo vale 0 per i numeri
  Identificativo.Clear;
  Assert.IsTrue(Identificativo = Vuoto, 'nullo uguale al GUID vuoto');
  Assert.IsFalse(Identificativo = Prova, 'nullo diverso da un GUID vero');
end;

procedure TTestZzNullable.Uguaglianza_Valuta_UgualeAlValoreEquivalente;
var
  Importo: TNullableCurrency;
  Atteso: Currency;
begin
  Atteso := 10.5;
  Importo := Atteso;

  Assert.IsTrue(Importo = Atteso, 'stesso importo');
  Atteso := 10.51;
  Assert.IsFalse(Importo = Atteso, 'un centesimo di differenza');
end;

procedure TTestZzNullable.Uguaglianza_AnsiString_UgualeAlTestoEquivalente;
var
  Testo: TNullableAnsiString;
  Atteso: AnsiString;
begin
  Atteso := 'codice';
  Testo := Atteso;

  Assert.IsTrue(Testo = Atteso, 'stesso testo');
  Atteso := 'Codice';
  Assert.IsFalse(Testo = Atteso, 'maiuscole diverse');
end;

procedure TTestZzNullable.Ordine_NulloControNegativo_NulloMaggiore;
var
  Numero: TNullableInt64;
  Negativo: Int64;
begin
  Negativo := -1;
  Numero.Clear;

  // il nullo vale 0, quindi sta sopra un numero negativo
  Assert.IsTrue(Numero > Negativo, 'nullo maggiore di -1');
  Assert.IsFalse(Numero < Negativo, 'nullo non minore di -1');
  Assert.IsTrue(Numero >= Negativo, 'nullo maggiore o uguale a -1');
  Assert.IsFalse(Numero <= Negativo, 'nullo non minore o uguale a -1');
end;

procedure TTestZzNullable.Ordine_NulloControPositivo_NulloMinore;
var
  Numero: TNullableInt64;
  Positivo: Int64;
begin
  Positivo := 1;
  Numero.Clear;

  Assert.IsTrue(Numero < Positivo, 'nullo minore di 1');
  Assert.IsTrue(Numero <= Positivo, 'nullo minore o uguale a 1');
  Assert.IsFalse(Numero > Positivo, 'nullo non maggiore di 1');
  Assert.IsFalse(Numero >= Positivo, 'nullo non maggiore o uguale a 1');
end;

procedure TTestZzNullable.Ordine_StringheMaiuscoleEMinuscole_OrdineOrdinale;
var
  Testo: TNullableString;
begin
  // confronto ordinale sui codici dei caratteri: 'B' (66) viene prima di 'a' (97)
  Testo := 'B';
  Assert.IsTrue(Testo < 'a', 'B prima di a');
  Assert.IsFalse(Testo > 'a', 'B non dopo a');

  Testo := 'abc';
  Assert.IsTrue(Testo < 'abd', 'abc prima di abd');
  Assert.IsTrue(Testo > 'ab', 'abc dopo ab');
end;

procedure TTestZzNullable.Ordine_Date_PrimaEDopo;
var
  Data: TNullableDate;
  Prima: TDate;
  Dopo: TDate;
begin
  Prima := EncodeDate(2026, 1, 1);
  Dopo := EncodeDate(2026, 12, 31);
  Data := EncodeDate(2026, 6, 15);

  Assert.IsTrue(Data > Prima, 'dopo il primo gennaio');
  Assert.IsTrue(Data < Dopo, 'prima del 31 dicembre');

  // il nullo vale la data zero (30 dicembre 1899): prima di qualunque data vera
  Data.Clear;
  Assert.IsTrue(Data < Prima, 'nullo prima di una data vera');
end;

procedure TTestZzNullable.Ordine_DueNullable_ConfrontoSuiValori;
var
  Piccolo: TNullableInteger;
  Grande: TNullableInteger;
  Nullo: TNullableInteger;
begin
  Piccolo := 3;
  Grande := 8;
  Nullo.Clear;

  Assert.IsTrue(Piccolo < Grande, '3 < 8');
  Assert.IsTrue(Grande > Piccolo, '8 > 3');
  Assert.IsTrue(Nullo < Piccolo, 'nullo (0) < 3');
  Assert.IsFalse(Piccolo < Nullo, '3 non minore del nullo (0)');
end;

procedure TTestZzNullable.Ordine_ValoriUguali_MinoreOUgualeEMaggioreOUgualeVeri;
var
  Primo: TNullableInteger;
  Secondo: TNullableInteger;
begin
  Primo := 5;
  Secondo := 5;

  Assert.IsTrue(Primo <= Secondo, 'minore o uguale');
  Assert.IsTrue(Primo >= Secondo, 'maggiore o uguale');
  Assert.IsFalse(Primo < Secondo, 'non minore');
  Assert.IsFalse(Primo > Secondo, 'non maggiore');
  Assert.IsTrue(Primo = Secondo, 'uguali');
end;

procedure TTestZzNullable.ValoreASinistra_UgualeEDiverso_ComeAGestra;
var
  Numero: TNullableInt64;
  Cinque: Int64;
  Sei: Int64;
begin
  Cinque := 5;
  Sei := 6;
  Numero := Cinque;

  Assert.IsTrue(Cinque = Numero, '5 = n');
  Assert.IsFalse(Sei = Numero, '6 = n');
  Assert.IsTrue(Sei <> Numero, '6 <> n');
  Assert.IsFalse(Cinque <> Numero, '5 <> n');
end;

procedure TTestZzNullable.ValoreASinistra_Ordine_ComeADestra;
var
  Numero: TNullableInt64;
  Quattro: Int64;
  Sei: Int64;
begin
  Quattro := 4;
  Sei := 6;
  Numero := 5;

  Assert.IsTrue(Quattro < Numero, '4 < n');
  Assert.IsTrue(Sei > Numero, '6 > n');
  Assert.IsTrue(Quattro <= Numero, '4 <= n');
  Assert.IsTrue(Sei >= Numero, '6 >= n');
  Assert.IsFalse(Sei < Numero, '6 < n');
end;

procedure TTestZzNullable.VersoVariant_Stringa_TestoConservato;
var
  Testo: TNullableString;
  Valore: Variant;
begin
  Testo := 'Rossi';
  Valore := Testo;

  Assert.IsFalse(VarIsNull(Valore), 'non e'' Null');
  Assert.AreEqual('Rossi', string(Valore));
end;

procedure TTestZzNullable.VersoVariant_Intero_ValoreConservato;
var
  Numero: TNullableInteger;
  Valore: Variant;
begin
  Numero := 42;
  Valore := Numero;

  Assert.AreEqual(42, Integer(Valore));
end;

procedure TTestZzNullable.VersoVariant_DataOra_ValoreConservato;
var
  Istante: TNullableDateTime;
  Valore: Variant;
  Atteso: TDateTime;
begin
  Atteso := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 0, 0);
  Istante := Atteso;
  Valore := Istante;

  Assert.AreEqual(Double(Atteso), Double(Valore), 0.000001);
end;

procedure TTestZzNullable.VersoVariant_Valuta_ValoreConservato;
var
  Importo: TNullableCurrency;
  Valore: Variant;
  Atteso: Currency;
begin
  Atteso := 1234.56;
  Importo := Atteso;
  Valore := Importo;

  Assert.IsTrue(Currency(Valore) = Atteso, 'importo conservato');
end;

procedure TTestZzNullable.VersoVariant_Booleano_ValoreConservato;
var
  Flag: TNullableBoolean;
  Valore: Variant;
begin
  Flag := True;
  Valore := Flag;
  Assert.IsTrue(Boolean(Valore), 'vero');

  Flag := False;
  Valore := Flag;
  Assert.IsFalse(VarIsNull(Valore), 'falso presente: non e'' Null');
  Assert.IsFalse(Boolean(Valore), 'falso');
end;

procedure TTestZzNullable.VersoVariant_Nullo_VariantNullPerOgniTipo;
var
  Testo: TNullableString;
  Intero: TNullableInteger;
  Grande: TNullableInt64;
  Decimale: TNullableDouble;
  Istante: TNullableDateTime;
  Valuta: TNullableCurrency;
  Flag: TNullableBoolean;
  Valore: Variant;
begin
  Testo.Clear;
  Intero.Clear;
  Grande.Clear;
  Decimale.Clear;
  Istante.Clear;
  Valuta.Clear;
  Flag.Clear;

  Valore := Testo;
  Assert.IsTrue(VarIsNull(Valore), 'stringa');
  Valore := Intero;
  Assert.IsTrue(VarIsNull(Valore), 'intero');
  Valore := Grande;
  Assert.IsTrue(VarIsNull(Valore), 'intero a 64 bit');
  Valore := Decimale;
  Assert.IsTrue(VarIsNull(Valore), 'decimale');
  Valore := Istante;
  Assert.IsTrue(VarIsNull(Valore), 'data e ora');
  Valore := Valuta;
  Assert.IsTrue(VarIsNull(Valore), 'valuta');
  Valore := Flag;
  Assert.IsTrue(VarIsNull(Valore), 'booleano');
end;

procedure TTestZzNullable.VersoVariant_ValorePredefinitoPresente_NonDiventaNull;
var
  Zero: TNullableInteger;
  Vuoto: TNullableString;
  Valore: Variant;
begin
  // un parametro 0 o '' e' un valore per il server, diverso da NULL
  Zero := 0;
  Valore := Zero;
  Assert.IsFalse(VarIsNull(Valore), 'zero presente');
  Assert.AreEqual(0, Integer(Valore));

  Vuoto := '';
  Valore := Vuoto;
  Assert.IsFalse(VarIsNull(Valore), 'stringa vuota presente');
  Assert.AreEqual('', string(Valore));
end;

procedure TTestZzNullable.DaVariant_DataOra_ValoreConservato;
var
  Origine: Variant;
  Istante: TNullableDateTime;
  Atteso: TDateTime;
begin
  Atteso := EncodeDate(2026, 11, 1) + EncodeTime(10, 30, 0, 0);
  Origine := VarFromDateTime(Atteso);

  Istante := TNullableDateTime.Create(Origine);

  Assert.IsTrue(Istante.HasValue, 'ha valore');
  Assert.AreEqual(Double(Atteso), Double(Istante.Value), 0.000001);
end;

procedure TTestZzNullable.DaVariant_Valuta_ValoreConservato;
var
  Origine: Variant;
  Importo: TNullableCurrency;
  Atteso: Currency;
begin
  Atteso := 99.99;
  Origine := Atteso;

  Importo := TNullableCurrency.Create(Origine);

  Assert.IsTrue(Importo.HasValue, 'ha valore');
  Assert.IsTrue(Importo.Value = Atteso, 'importo conservato');
end;

procedure TTestZzNullable.DaVariant_Booleano_ValoreConservato;
var
  Origine: Variant;
  Flag: TNullableBoolean;
begin
  Origine := True;
  Flag := TNullableBoolean.Create(Origine);
  Assert.IsTrue(Flag.HasValue, 'vero: ha valore');
  Assert.IsTrue(Flag.Value, 'vero');

  Origine := False;
  Flag := TNullableBoolean.Create(Origine);
  Assert.IsTrue(Flag.HasValue, 'falso: ha valore');
  Assert.IsFalse(Flag.Value, 'falso');
end;

procedure TTestZzNullable.DaVariant_InteroInNullableInt64_ValoreConservato;
var
  Origine: Variant;
  Numero: TNullableInt64;
begin
  Origine := 123456;

  Numero := TNullableInt64.Create(Origine);

  Assert.IsTrue(Numero.HasValue, 'ha valore');
  Assert.IsTrue(Numero.Value = 123456, 'valore conservato');
end;

procedure TTestZzNullable.DaVariant_NullEUnassigned_NulloPerOgniTipo;
var
  ValoreNull: Variant;
  ValoreVuoto: Variant;
  Testo: TNullableString;
  Intero: TNullableInteger;
  Istante: TNullableDateTime;
  Flag: TNullableBoolean;
begin
  ValoreNull := Null;
  ValoreVuoto := Unassigned;

  Testo := TNullableString.Create(ValoreNull);
  Assert.IsTrue(Testo.IsNull, 'stringa da Null');
  Testo := TNullableString.Create(ValoreVuoto);
  Assert.IsTrue(Testo.IsNull, 'stringa da Unassigned');

  Intero := TNullableInteger.Create(ValoreNull);
  Assert.IsTrue(Intero.IsNull, 'intero da Null');
  Intero := TNullableInteger.Create(ValoreVuoto);
  Assert.IsTrue(Intero.IsNull, 'intero da Unassigned');

  Istante := TNullableDateTime.Create(ValoreNull);
  Assert.IsTrue(Istante.IsNull, 'data da Null');

  Flag := TNullableBoolean.Create(ValoreNull);
  Assert.IsTrue(Flag.IsNull, 'booleano da Null');
end;

procedure TTestZzNullable.DaVariant_SoloSpazio_NonNullo;
var
  Origine: Variant;
  Testo: TNullableString;
begin
  // il parametro che toglierebbe gli spazi non e' mai usato: solo Null e
  // Unassigned danno un nullo
  Origine := '   ';

  Testo := TNullableString.Create(Origine);

  Assert.IsTrue(Testo.HasValue, 'ha valore');
  Assert.AreEqual('   ', Testo.Value);
end;

procedure TTestZzNullable.DaVariant_ViaDiAndataERitorno_ValoreEPresenzaConservati;
var
  Intero: TNullableInteger;
  Ritorno: TNullableInteger;
  Valore: Variant;
begin
  // con valore
  Intero := 77;
  Valore := Intero;
  Ritorno := TNullableInteger.Create(Valore);
  Assert.IsTrue(Ritorno.HasValue, 'con valore: presente');
  Assert.AreEqual(77, Ritorno.Value);

  // nullo
  Intero.Clear;
  Valore := Intero;
  Ritorno := TNullableInteger.Create(Valore);
  Assert.IsTrue(Ritorno.IsNull, 'nullo: resta nullo');
end;

procedure TTestZzNullable.Copia_AssegnazioneFraNullable_IndipendenteDalSorgente;
var
  Originale: TNullableString;
  Copia: TNullableString;
begin
  Originale := 'primo';
  Copia := Originale;

  Originale := 'secondo';
  Assert.AreEqual('primo', Copia.Value, 'la copia non segue il sorgente');

  Originale.Clear;
  Assert.IsTrue(Copia.HasValue, 'la copia ha ancora valore dopo il Clear del sorgente');
  Assert.AreEqual('primo', Copia.Value);

  // copiare un nullo da' un nullo
  Copia := Originale;
  Assert.IsTrue(Copia.IsNull, 'copia di un nullo');
end;

procedure TTestZzNullable.Clear_DopoUnValore_ValoreAzzeratoERiassegnabile;
var
  Numero: TNullableInt64;
begin
  Numero := 99;
  Assert.IsTrue(Numero.HasValue, 'prima del Clear');

  Numero.Clear;

  Assert.IsFalse(Numero.HasValue, 'dopo il Clear');
  Assert.IsTrue(Numero.IsNull, 'IsNull dopo il Clear');
  Assert.IsTrue(Numero.IsEmpty, 'IsEmpty dopo il Clear');
  Assert.IsTrue(Numero.Value = 0, 'Value torna al predefinito');
  Assert.IsTrue(Numero.GetValueOrDefault(7) = 7, 'predefinito indicato');

  Numero := 5;
  Assert.IsTrue(Numero.HasValue, 'riassegnato');
  Assert.IsTrue(Numero.Value = 5, 'nuovo valore');
end;

procedure TTestZzNullable.Assegnazione_ValorePredefinitoDelTipo_HaValore;
var
  Numero: TNullableInteger;
  Testo: TNullableString;
  Flag: TNullableBoolean;
begin
  Numero := 0;
  Testo := '';
  Flag := False;

  Assert.IsTrue(Numero.HasValue, 'zero ha valore');
  Assert.IsFalse(Numero.IsNull, 'zero non e'' nullo');
  Assert.IsTrue(Testo.HasValue, 'stringa vuota ha valore');
  Assert.IsTrue(Flag.HasValue, 'falso ha valore');
  Assert.IsFalse(Flag.IsNull, 'falso non e'' nullo');
end;

procedure TTestZzNullable.GetValueOrDefault_ConValorePredefinitoPresente_RestituisceIlValore;
var
  Numero: TNullableInteger;
begin
  Numero := 0;

  // lo zero e' un valore presente: il predefinito indicato non lo sostituisce
  Assert.AreEqual(0, Numero.GetValueOrDefault(7));
end;

procedure TTestZzNullable.Puntatore_Nil_DiventaNullo;
var
  Numero: TNullableInt64;
begin
  Numero := 10;

  Numero := nil;

  Assert.IsTrue(Numero.IsNull, 'dopo l''assegnazione di nil');
end;

procedure TTestZzNullable.Puntatore_NonNil_SollevaEInvalidOperation;
var
  Numero: TNullableInt64;
  Altro: Pointer;
  Classe: string;
begin
  Altro := Pointer(1);

  Classe := EccezioneDi(
    procedure
    begin
      Numero := Altro;
    end);

  Assert.AreEqual('EInvalidOperation', Classe);
end;

procedure TTestZzNullable.Sigle_OgnunaIdenticaAlGenericoEInizialmenteNulla;
var
  Testo: TNullableString;
  TestoAnsi: TNullableAnsiString;
  TestoLungo: TNullableWideString;
  Intero: TNullableInteger;
  Grande: TNullableInt64;
  Nativo: TNullableNativeInt;
  DataOra: TNullableDateTime;
  Data: TNullableDate;
  Ora: TNullableTime;
  Valuta: TNullableCurrency;
  Decimale: TNullableDouble;
  Flag: TNullableBoolean;
  Identificativo: TNullableGuid;
  GenericoIntero: TNullable<Integer>;
  GenericoTesto: TNullable<string>;
begin
  Assert.IsTrue(Testo.IsNull, 'TNullableString');
  Assert.IsTrue(TestoAnsi.IsNull, 'TNullableAnsiString');
  Assert.IsTrue(TestoLungo.IsNull, 'TNullableWideString');
  Assert.IsTrue(Intero.IsNull, 'TNullableInteger');
  Assert.IsTrue(Grande.IsNull, 'TNullableInt64');
  Assert.IsTrue(Nativo.IsNull, 'TNullableNativeInt');
  Assert.IsTrue(DataOra.IsNull, 'TNullableDateTime');
  Assert.IsTrue(Data.IsNull, 'TNullableDate');
  Assert.IsTrue(Ora.IsNull, 'TNullableTime');
  Assert.IsTrue(Valuta.IsNull, 'TNullableCurrency');
  Assert.IsTrue(Decimale.IsNull, 'TNullableDouble');
  Assert.IsTrue(Flag.IsNull, 'TNullableBoolean');
  Assert.IsTrue(Identificativo.IsNull, 'TNullableGuid');

  // le sigle sono lo stesso tipo del generico: l'assegnazione compila e vale
  GenericoIntero := 5;
  Intero := GenericoIntero;
  Assert.AreEqual(5, Intero.Value, 'TNullableInteger e'' TNullable<Integer>');

  GenericoTesto := 'x';
  Testo := GenericoTesto;
  Assert.AreEqual('x', Testo.Value, 'TNullableString e'' TNullable<string>');
end;

procedure TTestZzNullable.Sigle_ConValore_ValoreLetto;
var
  Nativo: TNullableNativeInt;
  Ora: TNullableTime;
  Data: TNullableDate;
  TestoLungo: TNullableWideString;
  OraDiProva: TTime;
  GiornoDato: TDate;
begin
  Nativo := NativeInt(12345);
  Assert.IsTrue(Nativo.HasValue, 'NativeInt: ha valore');
  Assert.IsTrue(Nativo.Value = 12345, 'NativeInt: valore');

  OraDiProva := EncodeTime(8, 15, 0, 0);
  Ora := OraDiProva;
  Assert.AreEqual(Double(OraDiProva), Double(Ora.Value), 0.000001, 'ora');

  GiornoDato := EncodeDate(2026, 11, 1);
  Data := GiornoDato;
  Assert.AreEqual(Double(GiornoDato), Double(Data.Value), 0.000001, 'data');

  TestoLungo := WideString('wide');
  Assert.IsTrue(TestoLungo.HasValue, 'WideString: ha valore');
  Assert.IsTrue(TestoLungo.Value = 'wide', 'WideString: valore');
end;

procedure TTestZzNullable.Divergenza_DIV_NUL_5_GuidVersoVariant_SollevaEccezione;
var
  Identificativo: TNullableGuid;
  Valore: Variant;
  Classe: string;
begin
  // Documenta il comportamento attuale: un GUID presente non si converte in
  // Variant (TValue non sa convertire un record). Da capovolgere quando il
  // codice sara' corretto (per esempio convertendo il GUID in testo).
  Identificativo := TNullableGuid.Create(GuidProva);

  Classe := EccezioneDi(
    procedure
    begin
      Valore := Identificativo;
    end);

  Assert.IsTrue(Classe <> '', 'la conversione solleva un''eccezione');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestZzNullable);

end.
