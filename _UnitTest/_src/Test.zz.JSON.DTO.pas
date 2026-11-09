// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zz.JSON.DTO;

// Test DUnitX di zLibs\zz.JSON.DTO.pas: classe base TJsonDTO, TArrayMapper e
// attributi GenericListReflect e SuppressZero (specifica ZLIBS-DTO, "DTO JSON.md").
// Nessuna dipendenza da rete, database o interfaccia.
//
// Le classi di prova imitano gli schemi dei chiamanti:
// - TDtoProva: campi semplici con JSONName (come TOpenApi_Geocode);
// - TDtoDataSuppressZero: data con [SuppressZero] (come TBilancio);
// - TDtoConListe: lista di numeri come TGps e lista di oggetti con
//   [GenericListReflect] come TOpenApi_Imprese_Autocomplete.
//
// Le divergenze (DIV-DTO-1..9) non sono provate: descrivono difetti dedotti
// dalla lettura del codice, che non si vuole imporre come comportamento atteso.
// DIV-DTO-5 (testo non valido ignorato in silenzio) e' invece il comportamento
// dichiarato da ZLIBS-DTO-003 e come tale e' provato.

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.DateUtils,
  System.Generics.Collections,
  REST.Json.Types,
  REST.Json,
  REST.JsonReflect,
  DUnitX.TestFramework,
  zz.JSON.DTO;

type
  // DTO con un campo per ogni tipo semplice
  TDtoProva = class(TJsonDTO)
  private
    [JSONName('nome')]
    FNome: string;
    [JSONName('quantita')]
    FQuantita: Integer;
    [JSONName('importo')]
    FImporto: Double;
    [JSONName('attivo')]
    FAttivo: Boolean;
    [JSONName('data_nascita')]
    FDataNascita: TDateTime;
  published
    property Nome: string read FNome write FNome;
    property Quantita: Integer read FQuantita write FQuantita;
    property Importo: Double read FImporto write FImporto;
    property Attivo: Boolean read FAttivo write FAttivo;
    property DataNascita: TDateTime read FDataNascita write FDataNascita;
  end;

  // DTO con una data che a zero non va scritta
  TDtoDataSuppressZero = class(TJsonDTO)
  private
    [SuppressZero, JSONName('data_chiusura')]
    FDataChiusura: TDateTime;
  published
    property DataChiusura: TDateTime read FDataChiusura write FDataChiusura;
  end;

  // Elemento di una lista di oggetti
  TDtoVoce = class
  private
    [JSONName('codice')]
    FCodice: string;
  published
    property Codice: string read FCodice write FCodice;
  end;

  // DTO con le due forme di lista dei chiamanti
  TDtoConListe = class(TJsonDTO)
  private
    // schema di TGps: l'array porta il nome JSON, la lista non si scrive
    [JSONName('numeri')]
    FNumeriArray: TArray<Double>;
    [JSONMarshalled(False)]
    FNumeri: TList<Double>;
    // schema di TOpenApi_Imprese_Autocomplete: l'array serve alla lettura,
    // la lista si scrive con l'interceptor
    [JSONName('voci'), JSONMarshalled(False)]
    FVociArray: TArray<TDtoVoce>;
    [GenericListReflect]
    FVoci: TObjectList<TDtoVoce>;
    function GetNumeri: TList<Double>;
    function GetVoci: TObjectList<TDtoVoce>;
  protected
    function GetAsJson: string; override;
  published
    property Numeri: TList<Double> read GetNumeri;
    property Voci: TObjectList<TDtoVoce> read GetVoci;
  public
    destructor Destroy; override;
  end;

  // Oggetto che segnala di essere stato liberato
  TOggettoControllato = class
  private
    FLiberato: PBoolean;
  public
    constructor Create(Liberato: PBoolean);
    destructor Destroy; override;
  end;

  // Espone i metodi protetti di TArrayMapper
  TMapperProva = class(TArrayMapper)
  public
    function ListaDiInteri(var Lista: TList<Integer>; const Origine: TArray<Integer>): TList<Integer>;
    function ListaDiOggetti(var Lista: TObjectList<TOggettoControllato>; const Origine: TArray<TOggettoControllato>): TObjectList<TOggettoControllato>;
    procedure AggiornaArray(Lista: TList<Integer>; var Destinazione: TArray<Integer>);
  end;

  [TestFixture]
  TTestJsonDto = class
  public
    // ZLIBS-DTO-001
    [Test]
    procedure Scrittura_CampiSemplici_MembriConTipoGiusto;
    // ZLIBS-DTO-001
    [Test]
    procedure ToString_UgualeAAsJson;
    // ZLIBS-DTO-002
    [Test]
    procedure Lettura_RispostaDiUnServizio_CampiValorizzati;
    // ZLIBS-DTO-002
    [Test]
    procedure AndataERitorno_CaratteriSpeciali_NomeIdentico;
    // ZLIBS-DTO-002
    [Test]
    procedure AndataERitorno_TuttiICampi_ValoriUguali;
    // ZLIBS-DTO-003
    [Test]
    procedure Lettura_TestoVuotoONonValidoONull_NienteECampiInvariati;
    // ZLIBS-DTO-003
    [Test]
    procedure Lettura_ValoreSemplice_SollevaErroreDiConversione;
    // ZLIBS-DTO-004
    [Test]
    procedure Rimpaginazione_OggettoSemplice_RientriEVirgole;
    // ZLIBS-DTO-004
    [Test]
    procedure Rimpaginazione_OggettoAnnidato_RientroDiDueSpazi;
    // ZLIBS-DTO-004
    [Test]
    procedure Rimpaginazione_OggettoVuoto_DueRighe;
    // ZLIBS-DTO-004
    [Test]
    procedure Rimpaginazione_TestoNonValido_StringaVuota;
    // ZLIBS-DTO-004
    [Test]
    procedure Rimpaginazione_ConArray_StessiDatiDopoLaRilettura;
    // ZLIBS-DTO-005
    [Test]
    procedure Data_AndataERitorno_StessaDataEOra;
    // ZLIBS-DTO-005
    [Test]
    procedure Data_NelJson_TestoIsoConTEZ;
    // ZLIBS-DTO-006
    [Test]
    procedure SuppressZero_DataZero_StringaVuota;
    // ZLIBS-DTO-006
    [Test]
    procedure SuppressZero_DataValorizzata_AndataERitorno;
    // ZLIBS-DTO-006
    [Test]
    procedure SuppressZero_StringaVuotaInLettura_DataZero;
  end;

  [TestFixture]
  TTestArrayMapper = class
  public
    // ZLIBS-DTO-007
    [Test]
    procedure Lista_Nulla_CreataConGliElementiDellArray;
    // ZLIBS-DTO-007
    [Test]
    procedure Lista_Esistente_RestituitaSenzaRileggereLArray;
    // ZLIBS-DTO-007
    [Test]
    procedure ListaDiOggetti_Liberata_LiberaGliOggetti;
    // ZLIBS-DTO-007
    [Test]
    procedure RefreshArray_ListaEsistente_CopiaGliElementi;
    // ZLIBS-DTO-007
    [Test]
    procedure RefreshArray_ListaNulla_ArrayInvariato;
  end;

  [TestFixture]
  TTestJsonDtoListe = class
  public
    // ZLIBS-DTO-007
    [Test]
    procedure ListaDiNumeri_Lettura_ElementiNellOrdine;
    // ZLIBS-DTO-007
    [Test]
    procedure ListaDiNumeri_Scrittura_ArrayNelJson;
    // ZLIBS-DTO-007
    [Test]
    procedure ListaDiNumeri_AndataERitorno_StessiValori;
    // ZLIBS-DTO-008
    [Test]
    procedure ListaDiOggetti_Scrittura_ArrayDiOggetti;
    // ZLIBS-DTO-008
    [Test]
    procedure ListaDiOggetti_Lettura_VociValorizzate;
    // ZLIBS-DTO-008
    [Test]
    procedure ListaDiOggetti_Vuota_AndataERitorno;
  end;

implementation

// funzioni di appoggio

// Legge un testo come oggetto JSON; fallisce la prova se non lo e'.
function LeggiOggetto(const Json: string): TJSONObject;
var
  Valore: TJSONValue;
begin
  Result := nil;
  Valore := TJSONObject.ParseJSONValue(Json);
  if not (Valore is TJSONObject) then
  begin
    Valore.Free;
    Assert.Fail('il testo non e'' un oggetto JSON: ' + Json);
  end
  else
    Result := TJSONObject(Valore);
end;

// Trova un membro (anche con percorso a punti); fallisce la prova se manca.
function Membro(Radice: TJSONObject; const Percorso: string): TJSONValue;
begin
  Result := Radice.FindValue(Percorso);
  Assert.IsNotNull(Result, 'manca il membro ' + Percorso);
end;

// TDtoConListe

destructor TDtoConListe.Destroy;
begin
  // come i chiamanti: GetVoci crea la lista dall'array se serve, cosi' gli
  // oggetti letti da JSON hanno un proprietario che li libera
  GetVoci.Free;
  FNumeri.Free;
  inherited;
end;

function TDtoConListe.GetAsJson: string;
begin
  RefreshArray<Double>(FNumeri, FNumeriArray);
  RefreshArray<TDtoVoce>(FVoci, FVociArray);
  Result := inherited;
end;

function TDtoConListe.GetNumeri: TList<Double>;
begin
  Result := List<Double>(FNumeri, FNumeriArray);
end;

function TDtoConListe.GetVoci: TObjectList<TDtoVoce>;
begin
  Result := ObjectList<TDtoVoce>(FVoci, FVociArray);
end;

// TOggettoControllato

constructor TOggettoControllato.Create(Liberato: PBoolean);
begin
  inherited Create;
  FLiberato := Liberato;
end;

destructor TOggettoControllato.Destroy;
begin
  if Assigned(FLiberato) then
    FLiberato^ := True;
  inherited;
end;

// TMapperProva

function TMapperProva.ListaDiInteri(var Lista: TList<Integer>; const Origine: TArray<Integer>): TList<Integer>;
begin
  Result := List<Integer>(Lista, Origine);
end;

function TMapperProva.ListaDiOggetti(var Lista: TObjectList<TOggettoControllato>; const Origine: TArray<TOggettoControllato>): TObjectList<TOggettoControllato>;
begin
  Result := ObjectList<TOggettoControllato>(Lista, Origine);
end;

procedure TMapperProva.AggiornaArray(Lista: TList<Integer>; var Destinazione: TArray<Integer>);
begin
  RefreshArray<Integer>(Lista, Destinazione);
end;

// TTestJsonDto

procedure TTestJsonDto.Scrittura_CampiSemplici_MembriConTipoGiusto;
var
  Dto: TDtoProva;
  Radice: TJSONObject;
begin
  Dto := TDtoProva.Create;
  try
    Dto.Nome := 'Rossi';
    Dto.Quantita := 3;
    Dto.Importo := 12.5;
    Dto.Attivo := True;

    Radice := LeggiOggetto(Dto.AsJson);
    try
      Assert.IsTrue(Membro(Radice, 'nome') is TJSONString, 'nome e'' una stringa');
      Assert.AreEqual('Rossi', Membro(Radice, 'nome').Value, 'nome');
      Assert.IsTrue(Membro(Radice, 'quantita') is TJSONNumber, 'quantita e'' un numero');
      Assert.AreEqual(3, (Membro(Radice, 'quantita') as TJSONNumber).AsInt, 'quantita');
      Assert.IsTrue(Membro(Radice, 'importo') is TJSONNumber, 'importo e'' un numero');
      Assert.AreEqual(Double(12.5), Double((Membro(Radice, 'importo') as TJSONNumber).AsDouble), 0.0001, 'importo');
      Assert.IsTrue(Membro(Radice, 'attivo') is TJSONTrue, 'attivo e'' il booleano vero');
    finally
      Radice.Free;
    end;
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.ToString_UgualeAAsJson;
var
  Dto: TDtoProva;
begin
  Dto := TDtoProva.Create;
  try
    Dto.Nome := 'Rossi';
    Dto.Quantita := 3;

    Assert.AreEqual(Dto.AsJson, Dto.ToString);
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.Lettura_RispostaDiUnServizio_CampiValorizzati;
var
  Dto: TDtoProva;
begin
  Dto := TDtoProva.Create;
  try
    // si parte da valori diversi, per vedere che la lettura li cambia
    Dto.Attivo := True;

    Dto.AsJson := '{"nome":"Bianchi","quantita":7,"importo":2.5,"attivo":false}';

    Assert.AreEqual('Bianchi', Dto.Nome, 'nome');
    Assert.AreEqual(7, Dto.Quantita, 'quantita');
    Assert.AreEqual(Double(2.5), Double(Dto.Importo), 0.0001, 'importo');
    Assert.IsFalse(Dto.Attivo, 'attivo');
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.AndataERitorno_CaratteriSpeciali_NomeIdentico;
var
  Origine, Destinazione: TDtoProva;
begin
  Origine := TDtoProva.Create;
  Destinazione := TDtoProva.Create;
  try
    // lettera accentata, euro, virgoletta, barra rovesciata, a capo
    Origine.Nome := 'Citt' + #$00E0 + ' ' + #$20AC + ' "virgolette" \ barra' + #13#10 + 'riga due';

    Destinazione.AsJson := Origine.AsJson;

    Assert.AreEqual(Origine.Nome, Destinazione.Nome);
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestJsonDto.AndataERitorno_TuttiICampi_ValoriUguali;
var
  Origine, Destinazione: TDtoProva;
begin
  Origine := TDtoProva.Create;
  Destinazione := TDtoProva.Create;
  try
    Origine.Nome := 'Verdi';
    Origine.Quantita := -42;
    Origine.Importo := 1234.56;
    Origine.Attivo := True;

    Destinazione.AsJson := Origine.AsJson;

    Assert.AreEqual('Verdi', Destinazione.Nome, 'nome');
    Assert.AreEqual(-42, Destinazione.Quantita, 'quantita negativa');
    Assert.AreEqual(Double(1234.56), Double(Destinazione.Importo), 0.0001, 'importo');
    Assert.IsTrue(Destinazione.Attivo, 'attivo');
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestJsonDto.Lettura_TestoVuotoONonValidoONull_NienteECampiInvariati;
var
  Dto: TDtoProva;
begin
  Dto := TDtoProva.Create;
  try
    Dto.Nome := 'x';
    Dto.Quantita := 9;

    Dto.AsJson := '';
    Assert.AreEqual('x', Dto.Nome, 'testo vuoto');

    Dto.AsJson := '<html>errore</html>';
    Assert.AreEqual('x', Dto.Nome, 'testo non valido');

    Dto.AsJson := 'null';
    Assert.AreEqual('x', Dto.Nome, 'null: nome');
    Assert.AreEqual(9, Dto.Quantita, 'null: quantita');
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.Lettura_ValoreSemplice_SollevaErroreDiConversione;
var
  Dto: TDtoProva;
begin
  Dto := TDtoProva.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        Dto.AsJson := '123';
      end, EConversionError, 'numero alla radice');

    Assert.WillRaise(
      procedure
      begin
        Dto.AsJson := '"testo"';
      end, EConversionError, 'stringa alla radice');

    Assert.WillRaise(
      procedure
      begin
        Dto.AsJson := 'true';
      end, EConversionError, 'booleano alla radice');
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.Rimpaginazione_OggettoSemplice_RientriEVirgole;
var
  Atteso: string;
begin
  Atteso :=
    '  {' + sLineBreak +
    '    "a":1,' + sLineBreak +
    '    "b":"x"' + sLineBreak +
    '  }' + sLineBreak;

  Assert.AreEqual(Atteso, TJsonDTO.PrettyPrintJSON('{"a":1,"b":"x"}'));
end;

procedure TTestJsonDto.Rimpaginazione_OggettoAnnidato_RientroDiDueSpazi;
var
  Atteso: string;
begin
  Atteso :=
    '  {' + sLineBreak +
    '    "o":{' + sLineBreak +
    '      "c":2' + sLineBreak +
    '    }' + sLineBreak +
    '  }' + sLineBreak;

  Assert.AreEqual(Atteso, TJsonDTO.PrettyPrintJSON('{"o":{"c":2}}'));
end;

procedure TTestJsonDto.Rimpaginazione_OggettoVuoto_DueRighe;
begin
  Assert.AreEqual('  {' + sLineBreak + '  }' + sLineBreak, TJsonDTO.PrettyPrintJSON('{}'));
end;

procedure TTestJsonDto.Rimpaginazione_TestoNonValido_StringaVuota;
begin
  Assert.AreEqual('', TJsonDTO.PrettyPrintJSON('non json'), 'testo non JSON');
  Assert.AreEqual('', TJsonDTO.PrettyPrintJSON(''), 'testo vuoto');
end;

procedure TTestJsonDto.Rimpaginazione_ConArray_StessiDatiDopoLaRilettura;
const
  Originale = '{"v":[1,{"k":"z"},[2,3]],"s":"t"}';
var
  Rimpaginato: string;
  ValoreOriginale, ValoreRimpaginato: TJSONValue;
begin
  Rimpaginato := TJsonDTO.PrettyPrintJSON(Originale);

  ValoreOriginale := TJSONObject.ParseJSONValue(Originale);
  ValoreRimpaginato := TJSONObject.ParseJSONValue(Rimpaginato);
  try
    Assert.IsNotNull(ValoreRimpaginato, 'il testo rimpaginato e'' ancora JSON valido: ' + Rimpaginato);
    Assert.AreEqual(ValoreOriginale.ToString, ValoreRimpaginato.ToString);
  finally
    ValoreRimpaginato.Free;
    ValoreOriginale.Free;
  end;
end;

procedure TTestJsonDto.Data_AndataERitorno_StessaDataEOra;
var
  Origine, Destinazione: TDtoProva;
begin
  Origine := TDtoProva.Create;
  Destinazione := TDtoProva.Create;
  try
    Origine.DataNascita := EncodeDateTime(2026, 6, 15, 10, 30, 0, 0);

    Destinazione.AsJson := Origine.AsJson;

    Assert.IsTrue(Abs(Origine.DataNascita - Destinazione.DataNascita) < 2 * OneMillisecond,
      'data letta ' + DateTimeToStr(Destinazione.DataNascita));
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestJsonDto.Data_NelJson_TestoIsoConTEZ;
var
  Dto: TDtoProva;
  Radice: TJSONObject;
  Testo: string;
begin
  Dto := TDtoProva.Create;
  try
    Dto.DataNascita := EncodeDateTime(2026, 6, 15, 10, 30, 0, 0);

    Radice := LeggiOggetto(Dto.AsJson);
    try
      Testo := Membro(Radice, 'data_nascita').Value;
      Assert.IsTrue(Testo.Contains('T') and Testo.EndsWith('Z'), 'atteso ISO 8601 UTC, trovato ' + Testo);
    finally
      Radice.Free;
    end;
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.SuppressZero_DataZero_StringaVuota;
var
  Dto: TDtoDataSuppressZero;
  Radice: TJSONObject;
begin
  Dto := TDtoDataSuppressZero.Create;
  try
    Dto.DataChiusura := 0;

    Radice := LeggiOggetto(Dto.AsJson);
    try
      Assert.IsTrue(Membro(Radice, 'data_chiusura') is TJSONString, 'e'' una stringa');
      Assert.AreEqual('', Membro(Radice, 'data_chiusura').Value);
    finally
      Radice.Free;
    end;
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDto.SuppressZero_DataValorizzata_AndataERitorno;
var
  Origine, Destinazione: TDtoDataSuppressZero;
  Radice: TJSONObject;
  Testo: string;
begin
  Origine := TDtoDataSuppressZero.Create;
  Destinazione := TDtoDataSuppressZero.Create;
  try
    Origine.DataChiusura := EncodeDateTime(2026, 6, 15, 10, 30, 0, 0);

    Radice := LeggiOggetto(Origine.AsJson);
    try
      Testo := Membro(Radice, 'data_chiusura').Value;
      Assert.IsTrue(Testo.Contains('T') and Testo.EndsWith('Z'), 'atteso ISO 8601 UTC, trovato ' + Testo);
    finally
      Radice.Free;
    end;

    Destinazione.AsJson := Origine.AsJson;

    Assert.IsTrue(Abs(Origine.DataChiusura - Destinazione.DataChiusura) < 2 * OneMillisecond,
      'data letta ' + DateTimeToStr(Destinazione.DataChiusura));
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestJsonDto.SuppressZero_StringaVuotaInLettura_DataZero;
var
  Dto: TDtoDataSuppressZero;
begin
  Dto := TDtoDataSuppressZero.Create;
  try
    Dto.DataChiusura := EncodeDate(2026, 1, 1);

    Dto.AsJson := '{"data_chiusura":""}';

    Assert.AreEqual(Double(0), Double(Dto.DataChiusura));
  finally
    Dto.Free;
  end;
end;

// TTestArrayMapper

procedure TTestArrayMapper.Lista_Nulla_CreataConGliElementiDellArray;
var
  Mapper: TMapperProva;
  Lista, Restituita: TList<Integer>;
  Origine: TArray<Integer>;
begin
  Mapper := TMapperProva.Create;
  try
    SetLength(Origine, 3);
    Origine[0] := 10;
    Origine[1] := 20;
    Origine[2] := 30;
    Lista := nil;
    try
      Restituita := Mapper.ListaDiInteri(Lista, Origine);

      Assert.IsTrue(Restituita = Lista, 'restituisce la lista creata');
      Assert.AreEqual(3, Lista.Count, 'numero di elementi');
      Assert.AreEqual(10, Lista[0], 'primo');
      Assert.AreEqual(30, Lista[2], 'ultimo');
    finally
      Lista.Free;
    end;
  finally
    Mapper.Free;
  end;
end;

procedure TTestArrayMapper.Lista_Esistente_RestituitaSenzaRileggereLArray;
var
  Mapper: TMapperProva;
  Lista, Seconda: TList<Integer>;
  Origine, AltraOrigine: TArray<Integer>;
begin
  Mapper := TMapperProva.Create;
  try
    SetLength(Origine, 2);
    Origine[0] := 1;
    Origine[1] := 2;
    SetLength(AltraOrigine, 5);
    Lista := nil;
    try
      Mapper.ListaDiInteri(Lista, Origine);

      Seconda := Mapper.ListaDiInteri(Lista, AltraOrigine);

      Assert.IsTrue(Seconda = Lista, 'stessa lista');
      Assert.AreEqual(2, Lista.Count, 'l''array nuovo non viene riletto');
    finally
      Lista.Free;
    end;
  finally
    Mapper.Free;
  end;
end;

procedure TTestArrayMapper.ListaDiOggetti_Liberata_LiberaGliOggetti;
var
  Mapper: TMapperProva;
  Lista: TObjectList<TOggettoControllato>;
  Origine: TArray<TOggettoControllato>;
  PrimoLiberato, SecondoLiberato: Boolean;
begin
  PrimoLiberato := False;
  SecondoLiberato := False;

  Mapper := TMapperProva.Create;
  try
    SetLength(Origine, 2);
    Origine[0] := TOggettoControllato.Create(@PrimoLiberato);
    Origine[1] := TOggettoControllato.Create(@SecondoLiberato);
    Lista := nil;

    Mapper.ListaDiOggetti(Lista, Origine);
    Assert.AreEqual(2, Lista.Count, 'oggetti nella lista');
    Assert.IsFalse(PrimoLiberato or SecondoLiberato, 'finche'' la lista vive gli oggetti vivono');

    Lista.Free;

    Assert.IsTrue(PrimoLiberato, 'primo oggetto');
    Assert.IsTrue(SecondoLiberato, 'secondo oggetto');
  finally
    Mapper.Free;
  end;
end;

procedure TTestArrayMapper.RefreshArray_ListaEsistente_CopiaGliElementi;
var
  Mapper: TMapperProva;
  Lista: TList<Integer>;
  Destinazione: TArray<Integer>;
begin
  Mapper := TMapperProva.Create;
  Lista := TList<Integer>.Create;
  try
    Lista.Add(7);
    Lista.Add(8);
    SetLength(Destinazione, 5);

    Mapper.AggiornaArray(Lista, Destinazione);

    Assert.AreEqual(2, Length(Destinazione), 'la lunghezza segue la lista');
    Assert.AreEqual(7, Destinazione[0], 'primo');
    Assert.AreEqual(8, Destinazione[1], 'secondo');
  finally
    Lista.Free;
    Mapper.Free;
  end;
end;

procedure TTestArrayMapper.RefreshArray_ListaNulla_ArrayInvariato;
var
  Mapper: TMapperProva;
  Destinazione: TArray<Integer>;
begin
  Mapper := TMapperProva.Create;
  try
    SetLength(Destinazione, 3);
    Destinazione[0] := 4;
    Destinazione[1] := 5;
    Destinazione[2] := 6;

    Mapper.AggiornaArray(nil, Destinazione);

    Assert.AreEqual(3, Length(Destinazione), 'lunghezza');
    Assert.AreEqual(5, Destinazione[1], 'contenuto');
  finally
    Mapper.Free;
  end;
end;

// TTestJsonDtoListe

procedure TTestJsonDtoListe.ListaDiNumeri_Lettura_ElementiNellOrdine;
var
  Dto: TDtoConListe;
begin
  Dto := TDtoConListe.Create;
  try
    Dto.AsJson := '{"numeri":[1.5,2.5]}';

    Assert.AreEqual(2, Dto.Numeri.Count, 'numero di elementi');
    Assert.AreEqual(Double(1.5), Double(Dto.Numeri[0]), 0.0001, 'primo');
    Assert.AreEqual(Double(2.5), Double(Dto.Numeri[1]), 0.0001, 'secondo');
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDtoListe.ListaDiNumeri_Scrittura_ArrayNelJson;
var
  Dto: TDtoConListe;
  Radice: TJSONObject;
  Elenco: TJSONArray;
begin
  Dto := TDtoConListe.Create;
  try
    Dto.Numeri.Add(1.5);
    Dto.Numeri.Add(2.5);

    Radice := LeggiOggetto(Dto.AsJson);
    try
      Assert.IsTrue(Membro(Radice, 'numeri') is TJSONArray, 'numeri e'' un array');
      Elenco := Membro(Radice, 'numeri') as TJSONArray;
      Assert.AreEqual(2, Elenco.Count, 'numero di elementi');
      Assert.AreEqual(Double(2.5), Double((Elenco.Items[1] as TJSONNumber).AsDouble), 0.0001, 'secondo');
    finally
      Radice.Free;
    end;
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDtoListe.ListaDiNumeri_AndataERitorno_StessiValori;
var
  Origine, Destinazione: TDtoConListe;
begin
  Origine := TDtoConListe.Create;
  Destinazione := TDtoConListe.Create;
  try
    Origine.Numeri.Add(1.5);
    Origine.Numeri.Add(2.5);

    Destinazione.AsJson := Origine.AsJson;

    Assert.AreEqual(2, Destinazione.Numeri.Count, 'numero di elementi');
    Assert.AreEqual(Double(1.5), Double(Destinazione.Numeri[0]), 0.0001, 'primo');
    Assert.AreEqual(Double(2.5), Double(Destinazione.Numeri[1]), 0.0001, 'secondo');
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

procedure TTestJsonDtoListe.ListaDiOggetti_Scrittura_ArrayDiOggetti;
var
  Dto: TDtoConListe;
  Voce: TDtoVoce;
  Radice: TJSONObject;
  Elenco: TJSONArray;
begin
  Dto := TDtoConListe.Create;
  try
    Voce := TDtoVoce.Create;
    Voce.Codice := 'A';
    Dto.Voci.Add(Voce);
    Voce := TDtoVoce.Create;
    Voce.Codice := 'B';
    Dto.Voci.Add(Voce);

    Radice := LeggiOggetto(Dto.AsJson);
    try
      Assert.IsTrue(Membro(Radice, 'voci') is TJSONArray, 'voci e'' un array');
      Elenco := Membro(Radice, 'voci') as TJSONArray;
      Assert.AreEqual(2, Elenco.Count, 'numero di voci');
      Assert.AreEqual('A', Elenco.Items[0].GetValue<string>('codice'), 'prima voce');
      Assert.AreEqual('B', Elenco.Items[1].GetValue<string>('codice'), 'seconda voce');
    finally
      Radice.Free;
    end;
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDtoListe.ListaDiOggetti_Lettura_VociValorizzate;
var
  Dto: TDtoConListe;
begin
  Dto := TDtoConListe.Create;
  try
    Dto.AsJson := '{"voci":[{"codice":"X"},{"codice":"Y"},{"codice":"Z"}]}';

    Assert.AreEqual(3, Dto.Voci.Count, 'numero di voci');
    Assert.AreEqual('X', Dto.Voci[0].Codice, 'prima');
    Assert.AreEqual('Z', Dto.Voci[2].Codice, 'ultima');
  finally
    Dto.Free;
  end;
end;

procedure TTestJsonDtoListe.ListaDiOggetti_Vuota_AndataERitorno;
var
  Origine, Destinazione: TDtoConListe;
begin
  Origine := TDtoConListe.Create;
  Destinazione := TDtoConListe.Create;
  try
    Destinazione.AsJson := Origine.AsJson;

    Assert.AreEqual(0, Destinazione.Voci.Count, 'voci');
    Assert.AreEqual(0, Destinazione.Numeri.Count, 'numeri');
  finally
    Destinazione.Free;
    Origine.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestJsonDto);
  TDUnitX.RegisterTestFixture(TTestArrayMapper);
  TDUnitX.RegisterTestFixture(TTestJsonDtoListe);

end.
