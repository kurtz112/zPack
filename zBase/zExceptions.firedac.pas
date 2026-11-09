unit zExceptions.firedac;

{
  Provider di contesto DB per zExceptions: enumera le connessioni FireDAC
  registrate in FDManager e ne riporta stato, transazioni e dataset aperti.
  Fornisce anche la cattura mirata del dataset/comando che ha generato
  l'errore corrente (CaptureFailedDataSet), da agganciare nell'OnError
  della connessione.

  Uso: basta aggiungere questa unit in un uses qualsiasi del progetto
  (es. nel datamodule principale). L'initialization aggancia da sola
  zExceptions.context.OnCollectDbContext.

  Isola la dipendenza da FireDAC in questa unit: zExceptions.context
  resta pulita.

  Nota (motivata dall'indagine sul Mantis Gesty #46): per gli errori che
  scoppiano durante il FETCH di una riga gia' in corso di lettura (non
  durante l'OPEN/EXECUTE) AInitiator non e' sempre risolvibile a un
  TDataSet: puo' essere nil o un oggetto del layer fisico di FireDAC. In
  quel caso, prima questa unit rinunciava del tutto (nessuna sezione
  "DATASET/QUERY CHE HA GENERATO L'ERRORE" nel log). Ora, quando non si
  riesce a identificare CON CERTEZZA il dataset responsabile, si elencano
  comunque tutti i dataset attivi sulla connessione al momento dell'errore
  come "candidati da verificare" - in prima istanza e' gia' un elenco
  ristretto su cui indagare, invece di nessuna informazione.

  Verificato sul sorgente FireDAC (RAD Studio 23, FireDAC.Comp.Client.pas):
  per un errore "generico" come il nostro (fetch fallito, non un conflitto
  di update/reconcile) AInitiator arriva nil dal layer fisico e resta tale
  fino alla connessione, che a quel punto sostituisce se stessa
  ("FOnError(Self, Self, AException)" in TFDCustomConnection.HandleException)
  - da qui il fallback sopra basato su ASender = connessione.
  C'e' pero' un punto MOLTO piu' preciso: TFDAdaptedDataSet.InternalUpdateErrorHandler
  chiama PRIMA "FOnError(Self, ...)" - dove Self e' il DATASET stesso, sempre,
  senza ambiguita' - e SOLO DOPO risale alla connessione. HandleDataSetError
  sotto e' agganciato a QUELLA property (OnError): TzFbDataSet.Create lo
  assegna gia' a ogni dataset (DIV-ERR-3), quindi l'identificazione certa al
  100% e' in uso; il fallback "candidati da verificare" sopra serve per i
  dataset che non sono TzFbDataSet (TFDQuery nudi).
}

interface

uses
  System.SysUtils,
  Data.DB;

// Dump mirato di un dataset: valori field del record corrente, e se e'
// un TFDQuery (insert/update/delete/select) o un TFDStoredProc:
// - il testo SQL/nome della stored procedure
// - l'elenco dei parametri (nome, valore)
// - una riga SQL "letterale", con i parametri gia' sostituiti dai loro
// valori, pronta da incollare in IBExpert per riprodurre l'errore in
// locale senza dover ricostruire a mano i parametri.
// Da richiamare nei try/except attorno a operazioni su un dataset specifico.
// Non solleva mai eccezioni: ogni sezione che non si riesce a leggere
// (dataset a meta' di un errore di fetch, proprieta' non accessibili)
// viene segnalata nel testo invece di far fallire l'intero dump.
function DumpDataSet(ADS: TDataSet): string;

// Cattura il dataset/comando che ha generato l'errore in corso, cosi' che
// compaia nel log/ticket anche senza intervento manuale nel punto in cui
// l'errore e' stato generato:
// 1) se AInitiator e' un TDataSet, dump mirato di quello (caso comune:
// errori di OPEN/EXECUTE);
// 2) altrimenti, se ASender e' (o espone) una connessione FireDAC, dump
// di tutti i dataset attivi su quella connessione al momento
// dell'errore, come elenco di candidati da verificare (caso tipico:
// errori durante il FETCH, dove AInitiator puo' essere nil o un
// oggetto del layer fisico non riconducibile al TDataSet applicativo);
// 3) in ultima istanza, solo il nome classe di AInitiator (comportamento
// precedente), o un messaggio esplicito se non c'e' nulla da riportare.
//
// Da chiamare nell'OnError della connessione (TConfig.DatabaseError),
// PRIMA del "raise AException", passando ASender e AInitiator cosi' come
// ricevuti dall'evento FireDAC:
//
// procedure TConfig.DatabaseError(ASender, AInitiator: TObject; var AException: Exception);
// begin
// inherited;
// zExceptions.firedac.CaptureFailedDataSet(ASender, AInitiator);
// raise AException;
// end;
procedure CaptureFailedDataSet(ASender, AInitiator: TObject);

// NOTA sulla traccia del dataset in apertura (indagine sul Mantis Gesty #49,
// "string right truncation"): quando l'errore scoppia mentre FireDAC sta
// leggendo le righe di una query appena aperta, nell'OnError della
// connessione arrivano ASender = TzFbDatabase e AInitiator =
// TFDPhysFBCommand (oggetto del layer fisico). Nessuno dei due porta al
// TDataSet applicativo, e il dataset che sta fallendo NON e' ancora Active,
// quindi non compare nemmeno nell'elenco dei "dataset attivi sulla
// connessione" usato come ripiego.
//
// La traccia del dataset in apertura sta in zFbDataSet.CurrentOpeningDataSet,
// che il dataset stesso valorizza prima di aprirsi (e prima di preparare la
// query) e azzera quando ha finito. Questa unit la LEGGE: la dipendenza va in
// un verso solo, da chi raccoglie il contesto verso il livello dati, non
// viceversa. Prima erano due procedure esposte qui e chiamate dal dataset, e
// ogni informazione nuova da tracciare diventava una chiamata in piu' dentro
// zFbDataSet.

// Identificativo LZ del dataset, nella forma NomeDataModule.NomeDataSet. E'
// la chiave di TzSystem.zDataSets e quindi l'unico dato con cui la form di
// dettaglio dell'eccezione puo' aprire l'editor dell'SQL del dataset che ha
// fallito. Stringa vuota se il dataset non e' un dataset dell'LZ.
function IdDataSetOf(ADataSet: TDataSet): string;

// Un evento OnError (TFDErrorEvent) e' un "method pointer" (procedure ..
// of object): non puo' essere una procedura libera, deve appartenere a una
// classe.
//
// ATTENZIONE - perche' HandleDataSetError e' un metodo di ISTANZA e non
// una class procedure: assegnando una class procedure a un evento,
// TMethod.Data non contiene un'istanza ma il RIFERIMENTO DI CLASSE (il
// puntatore alla VMT). Qualunque codice che ispeziona gli eventi via RTTI
// assumendo che Data sia un'istanza - SmartInspect.Core.FillObjectData fa
// esattamente "TObject(LMethod.Data).ClassName" - dereferenzia la VMT come
// se fosse un oggetto e legge memoria casuale: crash sistematico alla
// prima LogObject su un dataset con l'evento assegnato (visto in WT e
// Gesty su TBaseDbDataModule.dbMasterOpenProgress). Con un metodo di
// istanza su singleton, Data e' un oggetto vero e il problema sparisce.
type
  TFireDacDataSetErrorHandler = class
  public
    // Handler da assegnare DIRETTAMENTE alla property OnError di un
    // TFDQuery/TFDTable/TFDStoredProc (o discendenti, es. TzFbDataSet),
    // tramite il singleton di unit:
    //
    // MyDataSet.OnError := zExceptions.firedac.DataSetErrorHandler.HandleDataSetError;
    //
    // A differenza di CaptureFailedDataSet (agganciato all'OnError della
    // CONNESSIONE, dove AInitiator puo' non essere il dataset - vedi nota in
    // testa alla unit), qui ASender e' SEMPRE il dataset stesso: lo garantisce
    // FireDAC (TFDAdaptedDataSet.InternalUpdateErrorHandler chiama
    // "FOnError(Self, ...)" con Self = il dataset, PRIMA di risalire alla
    // connessione). Identificazione certa, zero congetture.
    // Se assegnato a livello di dataset, questo handler cattura il contesto
    // PRIMA che scatti CaptureFailedDataSet a livello di connessione: quella
    // funzione, trovando il dump gia' valorizzato, non lo sovrascrive (vedi
    // zExceptions.context.HasLastFailedDataSetDump).
    // Non solleva mai e non tocca AException: si limita a registrare il dump.
    procedure HandleDataSetError(ASender, AInitiator: TObject; var AException: Exception);
  end;

  // Singleton di unit per l'assegnazione dell'evento: creato pigramente alla
  // prima richiesta (sempre nel main thread: i dataset nascono li'), liberato
  // nella finalization. NON usare la classe direttamente come sorgente
  // dell'evento: vedi ATTENZIONE sopra.
function DataSetErrorHandler: TFireDacDataSetErrorHandler;

implementation

uses
  System.StrUtils,
  System.Classes,
  System.TypInfo,
  System.Variants,
  System.RegularExpressions,
  System.Diagnostics,
  firedac.Comp.Client,
  firedac.Comp.DataSet,
  firedac.Stan.Option,
  firedac.Stan.Intf,
  firedac.Stan.Param,
  zExceptions.context,
  // Solo nell'implementazione: zFbDataSet usa a sua volta questa unit
  // (TzFbDataSet.Create aggancia DataSetErrorHandler all'OnError), e due unit
  // possono riferirsi a vicenda solo se almeno una delle due lo fa qui.
  zFbDataSet,
  SmartInspect.Vcl.SiAuto;

const
  // Limite ai dataset dumpati nel fallback "candidati da verificare": una
  // connessione con decine di dataset aperti (form complesse) non deve
  // produrre un log ingestibile.
  MaxCandidateDataSets = 8;

  // Indentazione del corpo delle sezioni nel dump del dataset: il log si
  // legge a colpo d'occhio solo se titolo e contenuto stanno su due livelli
  // diversi.
  Ind = '    ';

const
  // DIV-ERR-2: dopo questo tempo un dump scritto da HandleDataSetError non vale piu' per l'errore in corso
  FinestraDumpDelGestoreMs = 2000;

var
  GDataSetErrorHandler: TFireDacDataSetErrorHandler = nil;
  GIstanteDumpDelGestore: Int64 = 0;

function DumpDelGestoreRecente: Boolean;
begin
  Result := (GIstanteDumpDelGestore <> 0) and ((TStopwatch.GetTimeStamp - GIstanteDumpDelGestore) * 1000 div TStopwatch.Frequency <= FinestraDumpDelGestoreMs);
end;

function DataSetErrorHandler: TFireDacDataSetErrorHandler;
begin
  if GDataSetErrorHandler = nil then
    GDataSetErrorHandler := TFireDacDataSetErrorHandler.Create;
  result := GDataSetErrorHandler;
end;

function SafeProp(const AGet: TFunc<string>): string;
begin
  try
    result := AGet();
  except
    on E: Exception do
      result := '<' + E.Message + '>';
  end;
end;

function IdDataSetOf(ADataSet: TDataSet): string;
begin
  result := '';

  // Solo i dataset dell'LZ hanno un identificativo: su un TFDQuery qualunque
  // si resta a stringa vuota e la form di dettaglio non offre nessun editor.
  if not(ADataSet is TzFbDataSet) then
    Exit;

  try
    result := Trim(TzFbDataSet(ADataSet).IdDataSet);

    // Stessa ricostruzione di TzSystem.Get_IdDataSet: finche' il dataset non
    // ha caricato le proprieta' dall'LZ, IdDataSet e' ancora vuota - ed e'
    // proprio il caso degli errori che scattano durante quel caricamento.
    if (result = '') and (ADataSet.Owner <> nil) and (ADataSet.Owner.Name <> '') and (ADataSet.Name <> '') then
      result := ADataSet.Owner.Name + '.' + ADataSet.Name;
  except
    // La cattura del contesto non deve mai sollevare: senza identificativo si
    // perde solo la scorciatoia all'editor, non il resto del dettaglio.
    result := '';
  end;
end;

function DataSetStateName(AState: TDataSetState): string;
begin
  result := GetEnumName(TypeInfo(TDataSetState), Ord(AState));
end;

// Titolo di sezione dentro il dump di un dataset. Ogni sezione e' separata
// da una riga vuota sopra e una sotto: nel log precedente SQL, parametri e
// campi erano incollati uno all'altro e non si capiva dove finisse l'uno e
// cominciasse l'altro.
procedure AddTitolo(SL: TStrings; const ATitolo: string);
var
  riempimento: integer;
begin
  riempimento := 68 - ATitolo.Length;
  if riempimento < 3 then
    riempimento := 3;
  SL.Add('--- ' + ATitolo + ' ' + ''.PadLeft(riempimento, '-'));
  SL.Add('');
end;

// Valore pronto per una tabella incolonnata: niente troncamenti (un memo va
// riportato per intero, e' spesso proprio il dato che serve), ma le righe
// successive alla prima rientrano fino alla colonna del valore, cosi' un
// campo multi-riga non manda a sinistra il resto della tabella.
function ValoreIncolonnato(const AValore: string; AColonnaValore: integer): string;
begin
  result := AValore.TrimRight.Replace(#9, ' ');
  result := result.Replace(#13#10, #10).Replace(#13, #10);
  result := result.Replace(#10, sLineBreak + ''.PadLeft(AColonnaValore, ' '));
end;

// Elenco verticale: un elemento per riga, virgola in coda a tutti tranne
// l'ultimo (che prende ASeparatoreFinale, tipicamente vuoto). Un elenco
// mandato a capo solo quando la riga e' piena costringe a contare gli
// elementi per far combaciare una colonna col suo valore.
procedure AddElencoVerticale(SL: TStrings; const APrefix: string; const AItems: TArray<string>; const ASeparatore, ASeparatoreFinale: string);
var
  i: integer;
begin
  for i := 0 to High(AItems) do
    if i < High(AItems) then
      SL.Add(APrefix + AItems[i] + ASeparatore)
    else
      SL.Add(APrefix + AItems[i] + ASeparatoreFinale);
end;

// Campi del record corrente, divisi in due elenchi: quelli valorizzati (uno
// per riga, con nome, tipo e valore incolonnati) e quelli vuoti (solo i nomi,
// a elenco compatto). Sulle viste documentali di Gesty/WT i campi sono spesso
// piu' di duecento e quasi tutti null: elencarli tutti uno per riga rendeva il
// log illeggibile e nascondeva i pochi valori che contano davvero.
procedure DumpFields(SL: TStrings; ADS: TDataSet);
var
  k: integer;
  fld: TField;
  val, nome, tipo: string;
  lungNome, lungTipo, colonnaValore: integer;
  valorizzati: TStringList;
  vuoti: TArray<string>;
  conDefault: TArray<string>; // Mantis #153 - 2026-09-21
  lungNomeVuoti: integer; // Mantis #153 - 2026-09-21
begin
  // In dsInsert/dsEdit il record sta nel buffer di modifica: IsEmpty puo'
  // essere True (nessuna riga letta) e i valori esserci lo stesso.
  if ADS.IsEmpty and not(ADS.State in [dsInsert, dsEdit, dsSetKey]) then
  begin
    AddTitolo(SL, 'Campi del record corrente');
    SL.Add(Ind + '(dataset vuoto)');
    SL.Add('');
    Exit;
  end;

  // Prima passata: larghezza delle due colonne fisse. Incolonnare su misure
  // fisse lasciava buchi sui dataset con nomi corti e mandava a capo quelli
  // con nomi lunghi; le larghezze si prendono dai campi che ci sono davvero.
  lungNome := 0;
  lungTipo := 0;
  for k := 0 to ADS.FieldCount - 1 do
  begin
    fld := ADS.Fields[k];
    if fld.IsNull then
      Continue;
    if fld.FieldName.Length > lungNome then
      lungNome := fld.FieldName.Length;
    tipo := GetEnumName(TypeInfo(TFieldType), Ord(fld.DataType));
    if tipo.Length > lungTipo then
      lungTipo := tipo.Length;
  end;
  colonnaValore := Length(Ind) + lungNome + 1 + lungTipo + 3;

  // Mantis #153 - 2026-09-21: larghezza della colonna dei nomi per l'elenco
  // dei campi vuoti con default previsto, calcolata sui soli campi nulli.
  lungNomeVuoti := 0;
  for k := 0 to ADS.FieldCount - 1 do
  begin
    fld := ADS.Fields[k];
    if not fld.IsNull then
      Continue;
    if fld.FieldName.Length > lungNomeVuoti then
      lungNomeVuoti := fld.FieldName.Length;
  end;

  vuoti := [];
  conDefault := []; // Mantis #153 - 2026-09-21
  valorizzati := TStringList.Create;
  try
    for k := 0 to ADS.FieldCount - 1 do
    begin
      fld := ADS.Fields[k];
      if fld.IsNull then
      begin
        vuoti := vuoti + [fld.FieldName];

        // Mantis #153 - 2026-09-21
        if not fld.DefaultExpression.IsEmpty then
          conDefault := conDefault + [fld.FieldName.PadRight(lungNomeVuoti) + ' = ' + fld.DefaultExpression];

        Continue;
      end;
      nome := fld.FieldName.PadRight(lungNome);
      tipo := GetEnumName(TypeInfo(TFieldType), Ord(fld.DataType)).PadRight(lungTipo);
      val := ValoreIncolonnato(SafeProp(
        function: string
        begin
          result := fld.AsString
        end), colonnaValore);
      valorizzati.Add(Ind + nome + ' ' + tipo + ' = ' + val);
    end;

    AddTitolo(SL, Format('Campi valorizzati del record corrente (%d di %d)', [valorizzati.Count, ADS.FieldCount]));
    if valorizzati.Count = 0 then
      SL.Add(Ind + '(nessun campo valorizzato)')
    else
      SL.AddStrings(valorizzati);
    SL.Add('');

    AddTitolo(SL, Format('Campi vuoti (%d)', [Length(vuoti)]));
    if Length(vuoti) = 0 then
      SL.Add(Ind + '(nessuno)')
    else
      AddElencoVerticale(SL, Ind, vuoti, '', '');
    SL.Add('');

    // Mantis #153 - 2026-09-21: i campi rimasti nulli che avrebbero un valore
    // predefinito. E' la sezione che mancava: senza, un inserimento in cui i
    // default non sono stati applicati si presenta come un normale errore di
    // vincolo su UNA colonna, e la causa vera - la perdita dell'intero gruppo
    // di default del dataset - resta invisibile. Qui si legge a colpo d'occhio
    // se il gruppo c'era e non e' stato applicato, o se non c'era proprio.
    AddTitolo(SL, Format('Campi vuoti con un valore predefinito previsto (%d)', [Length(conDefault)]));
    if Length(conDefault) = 0 then
      SL.Add(Ind + '(nessuno)')
    else
      for k := 0 to High(conDefault) do
        SL.Add(Ind + conDefault[k]);
    SL.Add('');
  finally
    FreeAndNil(valorizzati);
  end;
end;

// Rappresentazione letterale (SQL-safe) del valore di un parametro, per
// costruire una query "pronta all'uso" da incollare in IBExpert.
// Numeri: sempre con il punto come separatore decimale (invariant),
// indipendentemente dalla locale della macchina dove gira l'app.
// Blob/testo lungo: NON sostituiti (valore non affidabile/leggibile in
// chiaro come literal SQL), si lascia un commento e si rimanda all'elenco
// "Parametri" sopra.
// Format settings con separatore decimale/data/ora fissi (punto/trattino/
// due punti), a prescindere dalla locale della macchina: partiamo dalle
// impostazioni di sistema (TFormatSettings.Create) e sovrascriviamo solo i
// tre separatori, cosi' tutti gli altri campi restano validi.
// Nota: non si usa TFormatSettings.Invariant (disponibile solo da Delphi
// 10.4 in poi) per restare compatibile anche con XE10.3 Rio.
function InvariantNumDateSettings: TFormatSettings;
begin
  result := TFormatSettings.Create;
  result.DecimalSeparator := '.';
  result.DateSeparator := '-';
  result.TimeSeparator := ':';
end;

// Nota tipi: TFDQuery.Params e' un TFDParams/TFDParam (FireDAC.Stan.Param),
// NON il TParams/TParam di Data.DB (usato da TQuery/IProviderSupport
// generico) - sono due gerarchie distinte, da qui l'uso esplicito di
// TFDParam invece del piu' "ovvio" TParam.
function QuoteParamLiteral(AParam: TFDParam): string;
var
  InvFmt: TFormatSettings;
begin
  try
    if AParam.IsNull then
      Exit('NULL');

    InvFmt := InvariantNumDateSettings;

    case AParam.DataType of
      ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftLongWord, ftShortint, ftByte:
        result := AParam.AsString;

      ftFloat, ftCurrency, ftBCD, ftFMTBcd, TFieldType.ftSingle, TFieldType.ftExtended:
        result := FloatToStr(AParam.AsFloat, InvFmt);

      ftDate:
        result := '''' + FormatDateTime('yyyy-mm-dd', AParam.AsDateTime, InvFmt) + '''';
      ftTime:
        result := '''' + FormatDateTime('hh:nn:ss', AParam.AsDateTime, InvFmt) + '''';
      ftDateTime, ftTimeStamp:
        result := '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', AParam.AsDateTime, InvFmt) + '''';

      ftBoolean:
        result := IfThen(AParam.AsBoolean, '1', '0');

      ftBlob, ftGraphic, ftMemo, ftWideMemo, ftOraBlob, ftOraClob, ftTypedBinary:
        result := Format('/* BLOB %s: valore non riportabile come literal, vedi Parametri sopra */', [AParam.Name]);

    else
      // fallback prudente: tratta come stringa (copre ftString/ftWideString/
      // ftFixedChar/ftGuid e qualunque tipo non gestito esplicitamente sopra)
      result := '''' + StringReplace(AParam.AsString, '''', '''''', [rfReplaceAll]) + '''';
    end;
  except
    on E: Exception do
      result := Format('/* valore non leggibile (%s) */', [E.Message]);
  end;
end;

// Sostituisce ogni ":NomeParam" nel testo SQL col suo valore letterale.
// \b (word boundary) evita che ":ID" venga sostituito dentro ":ID2"; il
// valore di replacement viene "escapato" per $ perche' TRegEx.Replace
// interpreta $ come inizio di backreference nella stringa di sostituzione
function BuildLiteralSql(const ASql: string; AParams: TFDParams): string;
var
  i: integer;
  literal: string;
begin
  result := ASql;
  for i := 0 to AParams.Count - 1 do
  begin
    literal := QuoteParamLiteral(AParams[i]).Replace('$', '$$', [rfReplaceAll]);
    result := TRegEx.Replace(result, ':' + TRegEx.Escape(AParams[i].Name) + '\b', literal, [roIgnoreCase]);
  end;
end;

// "EXECUTE PROCEDURE NOME(val1, val2, ...);" pronto per IBExpert: solo i
// parametri IN/IN-OUT, nell'ordine di dichiarazione della procedura (quello
// con cui FireDAC popola Params). I parametri OUT non vanno passati nella
// chiamata (sono il risultato, non l'input).
function BuildStoredProcCall(ASP: TFDStoredProc): string;
var
  i: integer;
  args: string;
begin
  args := '';
  for i := 0 to ASP.Params.Count - 1 do
    if ASP.Params[i].ParamType in [ptInput, ptInputOutput, ptUnknown] then
    begin
      if args <> '' then
        args := args + ', ';
      args := args + QuoteParamLiteral(ASP.Params[i]);
    end;
  result := Format('EXECUTE PROCEDURE %s(%s);', [ASP.StoredProcName, args]);
end;

// Accesso ai metodi protetti di TFDDataSet: PSGetTableName e' l'unico punto
// che sa davvero su quale tabella/vista il dataset scrive (UpdateTableName se
// impostata, altrimenti l'origine reale delle colonne rilevata da FireDAC).
type
  TFDDataSetHack = class(TFDDataSet);

  // Tabella/vista su cui il dataset scrive. In Gesty/WT UpdateTableName non e'
  // quasi mai impostata (i TzFbDataSet nascono dai metadati LZ), quindi si
  // ripiega prima su PSGetTableName e poi sul primo nome che segue la FROM
  // della SELECT - che per i dataset documentali e' proprio la vista
  // aggiornabile tramite trigger.
function ResolveUpdateTableName(ADS: TDataSet): string;
var
  m: TMatch;
begin
  result := '';

  if ADS is TFDDataSet then
    try
      result := TFDDataSetHack(ADS).PSGetTableName.Trim;
    except
      result := '';
    end;

  if (result = '') and (ADS is TFDQuery) then
  begin
    m := TRegEx.Match(TFDQuery(ADS).SQL.Text, '\bFROM\s+([A-Za-z_][A-Za-z0-9_$]*)', [roIgnoreCase]);
    if m.Success then
      result := m.Groups[1].Value;
  end;

  if result = '' then
    result := '<TABELLA>';
end;

// True se il campo puo' comparire in una INSERT/UPDATE ricostruita: solo i
// campi reali del dataset (niente calcolati, lookup o aggregati), non di sola
// lettura e marcati da FireDAC come aggiornabili.
function CampoScrivibile(AField: TField): boolean;
begin
  result := (AField.FieldKind = fkData) and (not AField.ReadOnly) and (pfInUpdate in AField.ProviderFlags);
end;

// Rappresentazione letterale (SQL-safe) del valore di un campo, corrente o
// precedente. Stesse regole di QuoteParamLiteral (numeri col punto decimale,
// date in formato ISO, binari non riportati), applicate pero' a un TField.
// Il tipo si controlla PRIMA di leggere il valore: su un campo binario la
// sola lettura caricherebbe il blob in memoria per nulla.
function QuoteFieldLiteral(AField: TField; AVecchio: boolean): string;
var
  InvFmt: TFormatSettings;
  v: Variant;
  testo: string;
begin
  try
    if AField.DataType in [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob, ftBytes, ftVarBytes] then
      Exit(Format('/* %s: contenuto binario, non riportabile come literal */', [AField.FieldName]));

    if AVecchio then
      v := AField.OldValue
    else
      v := AField.Value;

    if VarIsNull(v) or VarIsEmpty(v) then
      Exit('NULL');

    InvFmt := InvariantNumDateSettings;

    case AField.DataType of
      ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftLongWord, ftShortint, ftByte:
        result := VarToStr(v);

      ftFloat, ftCurrency, ftBCD, ftFMTBcd, TFieldType.ftSingle, TFieldType.ftExtended:
        result := FloatToStr(VarAsType(v, varDouble), InvFmt);

      ftDate:
        result := QuotedStr(FormatDateTime('yyyy-mm-dd', VarToDateTime(v), InvFmt));
      ftTime:
        result := QuotedStr(FormatDateTime('hh:nn:ss', VarToDateTime(v), InvFmt));
      ftDateTime, ftTimeStamp:
        result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', VarToDateTime(v), InvFmt));

      ftBoolean:
        result := IfThen(VarAsType(v, varBoolean), '1', '0');

    else
      // Fallback prudente: tratta come stringa (copre ftString/ftWideString/
      // ftFixedChar/ftGuid/ftMemo e qualunque tipo non gestito sopra). Il
      // valore si riporta per intero, a-capo compresi: un memo troncato
      // renderebbe l'istruzione non riproducibile.
      testo := VarToStr(v);
      result := QuotedStr(testo);
    end;
  except
    on E: Exception do
      result := Format('/* valore non leggibile (%s) */', [E.Message]);
  end;
end;

// True se il valore del campo e' cambiato rispetto a quello letto dal
// database. In caso di dubbio (campo non confrontabile) si risponde True:
// meglio un campo di troppo nella UPDATE ricostruita che uno mancante.
function ValoreCambiato(AField: TField): boolean;
begin
  try
    result := not VarSameValue(AField.OldValue, AField.Value);
  except
    result := True;
  end;
end;

// Ricostruisce l'istruzione INSERT o UPDATE che stava fallendo, con i valori
// gia' sostituiti. E' la parte che serve davvero quando l'errore nasce da una
// scrittura: il testo SQL del dataset e' la SELECT e non dice nulla della
// INSERT che il trigger ha rifiutato.
//
// Non e' il testo letterale inviato da FireDAC (che lo genera nel proprio
// layer DApt e non lo espone), ma segue le stesse regole del generatore:
// - INSERT: le sole colonne valorizzate (con UpdateChangedFields attivo, che
// e' il default, FireDAC include solo le colonne assegnate);
// - UPDATE: le sole colonne il cui valore e' cambiato, con WHERE sui campi
// chiave (ProviderFlags pfInKey) e i loro valori PRECEDENTI, come fa
// UpdateMode = upWhereKeyOnly.
// La DELETE non e' ricostruibile: durante TDataSet.Delete lo stato resta
// dsBrowse e non e' distinguibile da una normale navigazione.
procedure DumpDml(SL: TStrings; ADS: TDataSet);
var
  k: integer;
  fld: TField;
  tabella: string;
  colonne, valori, assegnazioni, condizioni: TArray<string>;
  rilassato: boolean;

  // ARilassato = si ignorano ProviderFlags e ReadOnly. Serve come rete di
  // sicurezza: se il dataset non e' stato riconosciuto come aggiornabile
  // (query aperta in sola lettura, campi senza pfInUpdate) il filtro
  // normale non produrrebbe nessuna colonna e la sezione uscirebbe vuota
  // proprio nel caso in cui serve.
  procedure RaccogliCampi(ARilassato: boolean);
  var
    k: integer;
  begin
    colonne := [];
    valori := [];
    assegnazioni := [];
    condizioni := [];

    for k := 0 to ADS.FieldCount - 1 do
    begin
      fld := ADS.Fields[k];
      if ARilassato then
      begin
        if fld.FieldKind <> fkData then
          Continue;
      end
      else
        if not CampoScrivibile(fld) then
          Continue;

      if ADS.State = dsInsert then
      begin
        if fld.IsNull then
          Continue;
        colonne := colonne + [fld.FieldName];
        valori := valori + [QuoteFieldLiteral(fld, False)];
      end
      else
      begin
        if ValoreCambiato(fld) then
          assegnazioni := assegnazioni + [Format('%s = %s', [fld.FieldName, QuoteFieldLiteral(fld, False)])];
        if pfInKey in fld.ProviderFlags then
          condizioni := condizioni + [Format('%s.%s = %s', [tabella, fld.FieldName, QuoteFieldLiteral(fld, True)])];
      end;
    end;
  end;

begin
  if not(ADS.State in [dsInsert, dsEdit]) then
    Exit;

  tabella := ResolveUpdateTableName(ADS);

  RaccogliCampi(False);
  rilassato := (Length(colonne) = 0) and (Length(assegnazioni) = 0);
  if rilassato then
    RaccogliCampi(True);

  AddTitolo(SL, Format('Istruzione ricostruita: cosa stava scrivendo il dataset (%s)', [DataSetStateName(ADS.State)]));
  SL.Add(Ind + 'Ricostruita dai valori del record in memoria, NON e'' il testo esatto');
  SL.Add(Ind + 'inviato da FireDAC. VERIFICARE prima di eseguirla: modifica i dati.');
  if rilassato then
    SL.Add(Ind + 'Nessun campo risultava aggiornabile: elencati tutti i campi dati.');
  SL.Add('');

  if ADS.State = dsInsert then
  begin
    if Length(colonne) = 0 then
      SL.Add(Ind + '(nessun campo valorizzato: INSERT non ricostruibile)')
    else
    begin
      SL.Add(Ind + 'INSERT INTO ' + tabella);
      SL.Add(Ind + '(');
      AddElencoVerticale(SL, Ind + '    ', colonne, ',', '');
      SL.Add(Ind + ')');
      SL.Add(Ind + 'VALUES');
      SL.Add(Ind + '(');
      AddElencoVerticale(SL, Ind + '    ', valori, ',', '');
      SL.Add(Ind + ');');
    end;
  end
  else
  begin
    if Length(assegnazioni) = 0 then
      SL.Add(Ind + '(nessun campo modificato: UPDATE non ricostruibile)')
    else
    begin
      SL.Add(Ind + 'UPDATE ' + tabella + ' SET');
      AddElencoVerticale(SL, Ind + '    ', assegnazioni, ',', '');

      if Length(condizioni) = 0 then
        SL.Add(Ind + 'WHERE /* nessun campo chiave riconosciuto: completare a mano */;')
      else
      begin
        SL.Add(Ind + 'WHERE');
        AddElencoVerticale(SL, Ind + '    ', condizioni, ' AND', ';');
      end;
    end;
  end;
  SL.Add('');
end;

// Elenco dei parametri incolonnato sulle larghezze reali di nome e tipo.
// AConDirezione aggiunge la colonna IN/OUT, che serve solo alle stored
// procedure.
procedure DumpParametri(SL: TStrings; AParams: TFDParams; AConDirezione: boolean);
var
  i, lungNome, lungTipo, lungDir, colonnaValore: integer;
  nome, tipo, dir, val: string;
  prm: TFDParam;
begin
  lungNome := 0;
  lungTipo := 0;
  lungDir := 0;
  for i := 0 to AParams.Count - 1 do
  begin
    if AParams[i].Name.Length > lungNome then
      lungNome := AParams[i].Name.Length;
    tipo := GetEnumName(TypeInfo(TFieldType), Ord(AParams[i].DataType));
    if tipo.Length > lungTipo then
      lungTipo := tipo.Length;
    if AConDirezione then
    begin
      dir := GetEnumName(TypeInfo(TParamType), Ord(AParams[i].ParamType));
      if dir.Length > lungDir then
        lungDir := dir.Length;
    end;
  end;

  // ':' + nome + spazio + [direzione + spazio] + tipo + ' = '
  colonnaValore := Length(Ind) + 1 + lungNome + 1 + lungTipo + 3;
  if AConDirezione then
    Inc(colonnaValore, lungDir + 1);

  for i := 0 to AParams.Count - 1 do
  begin
    prm := AParams[i];
    nome := (':' + prm.Name).PadRight(lungNome + 1);
    tipo := GetEnumName(TypeInfo(TFieldType), Ord(prm.DataType)).PadRight(lungTipo);

    if AConDirezione then
      dir := GetEnumName(TypeInfo(TParamType), Ord(prm.ParamType)).PadRight(lungDir) + ' '
    else
      dir := '';

    if prm.IsNull then
      val := '<null>'
    else
      val := ValoreIncolonnato(SafeProp(
        function: string
        begin
          result := prm.AsString
        end), colonnaValore);

    SL.Add(Ind + nome + ' ' + dir + tipo + ' = ' + val);
  end;
  SL.Add('');
end;

// SQL/EXECUTE PROCEDURE del dataset, con parametri ed equivalente letterale
// pronto per essere incollato in IBExpert.
procedure DumpSql(SL: TStrings; ADS: TDataSet);

// Blocco SQL indentato sotto il proprio titolo, con la nota (facoltativa)
// subito sotto il titolo e una riga vuota di chiusura.
  procedure AddBloccoSql(const ATitolo, ANota, ASql: string);
  begin
    AddTitolo(SL, ATitolo);
    if ANota <> '' then
    begin
      SL.Add(Ind + ANota);
      SL.Add('');
    end;
    SL.Add(Ind + StringReplace(ASql.TrimRight, sLineBreak, sLineBreak + Ind, [rfReplaceAll]));
    SL.Add('');
  end;

begin
  if ADS is TFDStoredProc then
  begin
    AddTitolo(SL, 'Stored procedure');
    SL.Add(Ind + TFDStoredProc(ADS).StoredProcName);
    SL.Add('');

    if TFDStoredProc(ADS).Params.Count > 0 then
    begin
      AddTitolo(SL, Format('Parametri (%d)', [TFDStoredProc(ADS).Params.Count]));
      DumpParametri(SL, TFDStoredProc(ADS).Params, True);
    end;

    AddBloccoSql('Chiamata pronta per IBExpert', 'Parametri IN sostituiti. VERIFICARE prima di eseguire: puo'' avere effetti collaterali.', SafeProp(
      function: string
      begin
        result := BuildStoredProcCall(TFDStoredProc(ADS))
      end));
  end
  else
    if ADS is TFDQuery then
    begin
      AddBloccoSql('SQL del dataset', '', TFDQuery(ADS).SQL.Text);

      // Parametri: fondamentali per capire QUALE record era coinvolto quando
      // il testo SQL da solo non lo dice (es. "WHERE ID = :ID").
      if TFDQuery(ADS).Params.Count > 0 then
      begin
        AddTitolo(SL, Format('Parametri (%d)', [TFDQuery(ADS).Params.Count]));
        DumpParametri(SL, TFDQuery(ADS).Params, False);

        AddBloccoSql('SQL con i parametri sostituiti, pronto per IBExpert', 'VERIFICARE prima di eseguire: su INSERT/UPDATE/DELETE modifica i dati.', SafeProp(
          function: string
          begin
            result := BuildLiteralSql(TFDQuery(ADS).SQL.Text, TFDQuery(ADS).Params)
          end));
      end;
    end;
end;

procedure CollectConnection(SL: TStrings; AConn: TFDCustomConnection);
var
  j, openDS: integer;
  ds: TFDDataSet;
begin
  SL.Add(Format('Connessione: %s', [AConn.Name]));
  SL.Add('  Connected   : ' + BoolToStr(AConn.Connected, True));
  SL.Add('  DriverName  : ' + SafeProp(
    function: string
    begin
      result := AConn.Params.DriverID
    end));
  SL.Add('  Database    : ' + SafeProp(
    function: string
    begin
      result := AConn.Params.Database
    end));

  SL.Add('  InTransaction: ' + BoolToStr(AConn.InTransaction, True));

  openDS := 0;
  for j := 0 to AConn.DataSetCount - 1 do
    if AConn.DataSets[j].Active then
      Inc(openDS);
  SL.Add(Format('  DataSets    : %d (attivi: %d)', [AConn.DataSetCount, openDS]));

  for j := 0 to AConn.DataSetCount - 1 do
  begin
    ds := AConn.DataSets[j];
    SL.Add(Format('    - %-24s [%s] Active=%s State=%s', [ds.Name, ds.ClassName, BoolToStr(ds.Active, True), DataSetStateName(ds.State)]));
  end;

  SL.Add('');
end;

// Non solleva mai: ogni sezione che fallisce viene segnalata nel testo
// invece di interrompere l'intero dump (vedi nota in testa alla unit sugli
// errori di FETCH, dove il dataset puo' trovarsi in uno stato non del
// tutto leggibile nel momento in cui scatta questo dump).
function DumpDataSet(ADS: TDataSet): string;
var
  SL: TStringList;
begin
  if ADS = nil then
    Exit('(dataset = nil)');
  SL := TStringList.Create;
  try
    SL.Add(Format('%-11s: %s [%s]', ['DataSet', SafeProp(
      function: string
      begin
        result := ADS.Name
      end), SafeProp(
      function: string
      begin
        result := ADS.ClassName
      end)]));
    SL.Add(Format('%-11s: Active=%s  State=%s', ['Stato', SafeProp(
      function: string
      begin
        result := BoolToStr(ADS.Active, True)
      end), SafeProp(
      function: string
      begin
        result := DataSetStateName(ADS.State)
      end)]));
    if ADS.Owner <> nil then
      SL.Add(Format('%-11s: %s (%s)', ['DataModule', SafeProp(
        function: string
        begin
          result := ADS.Owner.ClassName
        end), SafeProp(
        function: string
        begin
          result := ADS.Owner.Name
        end)]));
    SL.Add(Format('%-11s: %s', ['Tabella', SafeProp(
      function: string
      begin
        result := ResolveUpdateTableName(ADS)
      end)]));
    SL.Add('');

    try
      DumpSql(SL, ADS);
    except
      on E: Exception do
        SL.Add(Ind + '(impossibile leggere SQL/parametri: ' + E.Message + ')');
    end;

    // Prima i campi, poi la DML? No: la DML ricostruita e' la risposta alla
    // domanda "cosa stava scrivendo", quindi va sopra il dettaglio dei campi.
    try
      DumpDml(SL, ADS);
    except
      on E: Exception do
        SL.Add(Ind + '(impossibile ricostruire l''istruzione DML: ' + E.Message + ')');
    end;

    try
      if ADS.Active then
        DumpFields(SL, ADS)
      else
        SL.Add(Ind + '(dataset non attivo: nessun record da riportare)');
    except
      on E: Exception do
        SL.Add(Ind + '(impossibile leggere i campi del record corrente: ' + E.Message + ')');
    end;

    result := SL.Text;
  finally
    FreeAndNil(SL);
  end;
end;

// Fallback per gli errori di FETCH: quando AInitiator non e' un TDataSet
// utilizzabile, si prova a risalire alla connessione (ASender e' quasi
// sempre la connessione stessa nell'OnError; in subordine il datamodule
// proprietario di AInitiator, se e' un componente) e si dumpano tutti i
// dataset attivi su di essa come elenco di candidati da verificare.
// Restituisce False se non si riesce a risalire ad alcuna connessione
// (a quel punto CaptureFailedDataSet ripiega sul solo nome classe).
function TryDumpOpenDataSetsFallback(ASender, AInitiator: TObject): boolean;
var
  conn: TFDCustomConnection;
  SL: TStringList;
  j, dumped: integer;
  ds: TFDDataSet;
  primoCandidato: TFDDataSet;
  connList: TStrings;
  i: integer;
begin
  result := False;

  conn := nil;

  // Tentativo 1: ASender è una connessione?
  if ASender is TFDCustomConnection then
    conn := TFDCustomConnection(ASender)
    // Tentativo 2: AInitiator è un componente con Owner connessione?
  else
    if (AInitiator is TComponent) and (TComponent(AInitiator).Owner is TFDCustomConnection) then
      conn := TFDCustomConnection(TComponent(AInitiator).Owner)
      // Tentativo 3: ASender è un componente proprietario di una connessione?
    else
      if (ASender is TComponent) and (TComponent(ASender).Owner is TFDCustomConnection) then
        conn := TFDCustomConnection(TComponent(ASender).Owner);

  // Tentativo 4 (NUOVO): Se nulla di quanto sopra, cercare la connessione nel FDManager
  // (quella che è effettivamente in uso). Tipico per errori dove ASender è un DataModule
  // e non la connessione stessa.
  if conn = nil then
  begin
    connList := TStringList.Create;
    try
      if FDManager.Active then
      begin
        FDManager.GetConnectionNames(connList);
        if connList.Count > 0 then
        begin
          try
            conn := FDManager.FindConnection(connList[0]);
            siMain.LogMessage(Format('[TryDumpOpenDataSetsFallback] Connessione trovata in FDManager: %s', [SafeProp(
              function: string
              begin
                result := conn.Name
              end)]));
          except
            on E: Exception do
            begin
              siMain.LogMessage(Format('[TryDumpOpenDataSetsFallback] Errore cercando connessione in FDManager: %s', [E.Message]));
            end;
          end;
        end;
      end;
    finally
      FreeAndNil(connList);
    end;
  end;

  if conn = nil then
  begin
    siMain.LogMessage('[TryDumpOpenDataSetsFallback] Nessuna connessione trovata - fallback non possibile');
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.Add(Format('Dataset che ha generato l''errore non identificabile con certezza (initiator: %s).', [IfThen(AInitiator = nil, '<nil>', SafeProp(
      function: string
      begin
        result := AInitiator.ClassName
      end))]));
    SL.Add(Format('Dataset attivi sulla connessione "%s" al momento dell''errore (candidati da verificare):', [SafeProp(
      function: string
      begin
        result := conn.Name
      end)]));
    SL.Add('');

    dumped := 0;
    primoCandidato := nil;
    for j := 0 to conn.DataSetCount - 1 do
    begin
      // TFDCustomConnection.GetDataSets fa "inherited DataSets[i] as
      // TFDDataSet": se sulla connessione e' registrato un TDataSet che non
      // e' un TFDDataSet, l'"as" solleva EInvalidCast. Senza questa guardia
      // l'eccezione risaliva fino all'except di CaptureFailedDataSet e
      // l'intera cattura veniva persa in silenzio.
      ds := nil;
      try
        ds := conn.DataSets[j];
      except
        on E: Exception do
          SL.Add(Format('  (dataset %d non leggibile: %s)', [j, E.Message]));
      end;
      if ds = nil then
        Continue;

      if not ds.Active then
        Continue;

      Inc(dumped);
      if primoCandidato = nil then
        primoCandidato := ds;
      if dumped > MaxCandidateDataSets then
      begin
        SL.Add(Format('  ... altri dataset attivi omessi (limite %d) ...', [MaxCandidateDataSets]));
        Break;
      end;

      SL.Add(''.PadLeft(80, '='));
      SL.Add(Format('CANDIDATO %d', [dumped]));
      SL.Add(''.PadLeft(80, '='));
      SL.Add('');
      SL.Add(DumpDataSet(ds)); // DumpDataSet non solleva mai, nessun try/except necessario qui
      SL.Add('');
    end;

    if dumped = 0 then
      SL.Add('  (nessun dataset attivo sulla connessione in questo momento)');

    // Anche quando il responsabile non e' certo, i due campi del form di
    // dettaglio vanno riempiti: con un solo candidato e' di fatto quello,
    // con piu' candidati si dichiara apertamente l'incertezza invece di
    // lasciare i campi vuoti (che l'utente legge come "non ha funzionato").
    if dumped = 1 then
    begin
      zExceptions.context.SetLastFailedDataSetName(SafeProp(
        function: string
        begin
          result := primoCandidato.Name
        end));
      zExceptions.context.SetLastFailedDataSetId(IdDataSetOf(primoCandidato));
      if primoCandidato.Owner <> nil then
        zExceptions.context.SetLastFailedDataSetDataModuleName(primoCandidato.Owner.ClassName);
    end
    else
      zExceptions.context.SetLastFailedDataSetName(Format('(%d candidati, vedi log)', [dumped]));

    zExceptions.context.SetLastFailedDataSetDump(SL.Text);
    result := True;
  finally
    FreeAndNil(SL);
  end;
end;

procedure TFireDacDataSetErrorHandler.HandleDataSetError(ASender, AInitiator: TObject; var AException: Exception);
begin
  try
    if ASender is TDataSet then
    begin
      zExceptions.context.SetLastFailedDataSetDump(DumpDataSet(TDataSet(ASender)));
      GIstanteDumpDelGestore := TStopwatch.GetTimeStamp;

      // Quando scatta questo handler, CaptureFailedDataSet trova il dump gia'
      // presente ed esce senza toccare nient'altro: se non si valorizzano qui
      // anche nome, datamodule e id, la form di dettaglio li mostra vuoti
      // proprio nel caso in cui il responsabile e' noto con certezza.
      zExceptions.context.SetLastFailedDataSetName(TDataSet(ASender).Name);
      zExceptions.context.SetLastFailedDataSetId(IdDataSetOf(TDataSet(ASender)));

      if TDataSet(ASender).Owner <> nil then
      begin
        zExceptions.context.SetLastFailedDataSetOwnerModuleName(zExceptions.context.ModuleNameFromClass(TDataSet(ASender).Owner.ClassType, zExceptions.context.BaseDataModuleClassName));
        zExceptions.context.SetLastFailedDataSetDataModuleName(TDataSet(ASender).Owner.ClassName);
      end;
    end;
  except
    // La cattura del contesto non deve mai impedire la gestione originale
    // dell'errore.
  end;
end;

function NomeClasseOppureNil(AOggetto: TObject): string;
begin
  if AOggetto = nil then
    Result := '<nil>'
  else
    Result := AOggetto.ClassName;
end;

procedure CaptureFailedDataSet(ASender, AInitiator: TObject);
var
  dumpedInitiator: boolean;
  diag: string;
  DataSetInCarico: TzFbDataSet;
begin
  try
    // Se HandleDataSetError (agganciato a livello di dataset, vedi sopra)
    // ha gia' catturato il dump per QUESTO stesso errore, e' sicuramente
    // piu' preciso di quello che potremmo ricostruire qui a livello di
    // connessione: non sovrascriverlo.
    // DIV-ERR-1: l'apertura in corso si legge e si consuma subito, qualunque ramo risponda
    DataSetInCarico := zFbDataSet.CurrentOpeningDataSet;
    zFbDataSet.CurrentOpeningDataSet := nil;

    // DIV-ERR-2: il dump vale solo se e' stato scritto per QUESTO errore, cioe' pochi istanti fa;
    // uno piu' vecchio e' di un errore precedente mai consumato e si riscrive
    if zExceptions.context.HasLastFailedDataSetDump and DumpDelGestoreRecente then
    begin
      siMain.LogMessage('[CaptureFailedDataSet] Dump gia'' presente da HandleDataSetError, non riscritto');
      Exit;
    end;

    // Dump MINIMO, scritto subito e prima di qualunque cosa possa fallire.
    // Tutto quello che viene dopo lo arricchisce, ma se qualcosa solleva
    // un'eccezione questa riga resta: la sezione del log non puo' piu'
    // sparire in silenzio. Prima non era cosi', e un errore qui dentro
    // (ingoiato dall'except in fondo) lasciava il log senza alcuna traccia
    // e senza alcuna spiegazione del perche'.
    zExceptions.context.SetLastFailedDataSetDump(Format('ASender=%s, AInitiator=%s (dettaglio non ricostruito)', [SafeProp(
      function: string
      begin
        if ASender = nil then
          result := '<nil>'
        else
          result := ASender.ClassName
      end), SafeProp(
      function: string
      begin
        if AInitiator = nil then
          result := '<nil>'
        else
          result := AInitiator.ClassName
      end)]));

    // DIV-ERR-4: IfThen valuta entrambi i rami, quindi ClassName su un oggetto nullo sollevava una
    // violazione di accesso e la cattura si fermava al dump minimo proprio quando AInitiator e' nil
    // (il caso degli errori di fetch descritto in testa alla unit)
    siMain.LogMessage(Format('[CaptureFailedDataSet] Inizio cattura - ASender=%s, AInitiator=%s', [NomeClasseOppureNil(ASender), NomeClasseOppureNil(AInitiator)]));

    dumpedInitiator := False;

    if AInitiator is TDataSet then
    begin
      siMain.LogMessage(Format('[CaptureFailedDataSet] AInitiator e'' un TDataSet: %s [%s]', [TDataSet(AInitiator).Name, TDataSet(AInitiator).ClassName]));
      zExceptions.context.SetLastFailedDataSetDump(DumpDataSet(TDataSet(AInitiator)));
      zExceptions.context.SetLastFailedDataSetName(TDataSet(AInitiator).Name);
      zExceptions.context.SetLastFailedDataSetId(IdDataSetOf(TDataSet(AInitiator)));
      dumpedInitiator := True;

      // Fallback per la categorizzazione Mantis quando non c'e' una form
      // attiva riconducibile a TBaseForm (es. operazioni di sfondo/timer):
      // il datamodule proprietario del dataset che ha fallito e' spesso
      // il modulo applicativo "giusto" da riportare (es. TFDQuery
      // dichiarata su TEnti -> modulo "Enti").
      if TDataSet(AInitiator).Owner <> nil then
      begin
        zExceptions.context.SetLastFailedDataSetOwnerModuleName(zExceptions.context.ModuleNameFromClass(TDataSet(AInitiator).Owner.ClassType, zExceptions.context.BaseDataModuleClassName));
        zExceptions.context.SetLastFailedDataSetDataModuleName(TDataSet(AInitiator).Owner.ClassName);
      end;
    end;

    // AInitiator non e' un TDataSet (ASender = TzFbDatabase, AInitiator =
    // TFDPhysFBCommand: e' il caso del Mantis Gesty #49). Se pero' c'e' un
    // dataset che ha dichiarato di essere in apertura - o in preparazione
    // della query - il responsabile e' quello, senza ambiguita': l'errore e'
    // scattato fra il suo DoBeforeOpen e il suo DoAfterOpen.
    // La variabile locale e' stata letta (e la globale azzerata) all'inizio.
    if not dumpedInitiator and (DataSetInCarico <> nil) then
    begin
      siMain.LogMessage(Format('[CaptureFailedDataSet] Errore durante l''apertura di %s [%s]', [SafeProp(
        function: string
        begin
          result := DataSetInCarico.Name
        end), SafeProp(
        function: string
        begin
          result := DataSetInCarico.ClassName
        end)]));

      zExceptions.context.SetLastFailedDataSetDump(DumpDataSet(DataSetInCarico));
      zExceptions.context.SetLastFailedDataSetName(SafeProp(
        function: string
        begin
          result := DataSetInCarico.Name
        end));

      zExceptions.context.SetLastFailedDataSetId(IdDataSetOf(DataSetInCarico));

      if DataSetInCarico.Owner <> nil then
      begin
        zExceptions.context.SetLastFailedDataSetOwnerModuleName(zExceptions.context.ModuleNameFromClass(DataSetInCarico.Owner.ClassType, zExceptions.context.BaseDataModuleClassName));
        zExceptions.context.SetLastFailedDataSetDataModuleName(DataSetInCarico.Owner.ClassName);
      end;

      dumpedInitiator := True;
    end;

    // Nessuna apertura in corso: l'errore e' scattato su un dataset gia'
    // aperto (fetch differito, refresh). Si elencano i dataset attivi sulla
    // connessione come candidati da verificare, invece di non riportare nulla.
    if not dumpedInitiator then
    begin
      siMain.LogMessage('[CaptureFailedDataSet] AInitiator non e'' un TDataSet, tentando fallback');
      dumpedInitiator := TryDumpOpenDataSetsFallback(ASender, AInitiator);
      if dumpedInitiator then
        siMain.LogMessage('[CaptureFailedDataSet] Fallback riuscito: dataset candidati dumpati')
      else
        siMain.LogMessage('[CaptureFailedDataSet] Fallback non riuscito: nessuna connessione trovata');
    end;

    // Fallback FINALE: se proprio nulla funziona, registra almeno il messaggio generico
    // cosi' nel form di dettaglio l'utente sa che c'e' stato un problema
    if not dumpedInitiator then
    begin
      if AInitiator <> nil then
      begin
        diag := Format('Initiator: %s (non e'' un TDataSet, nessun dump disponibile - consultare SmartInspect log)', [AInitiator.ClassName]);
        siMain.LogMessage('[CaptureFailedDataSet] Fallback generico: ' + diag);
        zExceptions.context.SetLastFailedDataSetDump(diag);
      end
      else
      begin
        diag := '(nessun dataset o connessione individuabile - consultare SmartInspect log per traccia [CaptureFailedDataSet])';
        siMain.LogMessage('[CaptureFailedDataSet] ' + diag);
        zExceptions.context.SetLastFailedDataSetDump(diag);
      end;
    end;

    siMain.LogMessage('[CaptureFailedDataSet] Fine cattura - dump valorizzato');

  except
    on E: Exception do
    begin
      // La cattura del contesto non deve mai impedire la gestione originale
      // dell'errore (che prosegue subito dopo con "raise AException"), ma
      // il fallimento va SCRITTO NEL LOG DELL'ECCEZIONE, non solo in
      // SmartInspect: altrimenti la sezione sparisce e non si capisce se
      // la cattura non e' partita o e' andata storta.
      siMain.LogMessage(Format('[CaptureFailedDataSet] ERRORE durante cattura: %s', [E.Message]));
      try
        zExceptions.context.SetLastFailedDataSetDump(zExceptions.context.PeekLastFailedDataSetDump + sLineBreak + Format('(cattura del contesto interrotta da %s: %s)', [E.ClassName, E.Message]));
      except
      end;
    end;
  end;
end;

function CollectFireDacContext: string;
var
  SL: TStringList;
  connList: TStrings;
  i: integer;
  conn: TFDCustomConnection;
begin
  SL := TStringList.Create;
  connList := TStringList.Create;
  try
    SL.Add(Format('FDManager.Active = %s, connessioni = %d', [BoolToStr(FDManager.Active, True), FDManager.ConnectionCount]));
    SL.Add('');

    // Enumera le connessioni note al manager (per nome)
    FDManager.GetConnectionNames(connList);
    for i := 0 to connList.Count - 1 do
    begin
      conn := nil;
      try
        // FindConnection non crea, restituisce nil se non istanziata
        conn := FDManager.FindConnection(connList[i]);
      except
        on E: Exception do
          SL.Add(Format('Connessione %s: <%s>', [connList[i], E.Message]));
      end;
      if conn <> nil then
        CollectConnection(SL, conn);
    end;

    result := SL.Text;
  finally
    FreeAndNil(connList);
    FreeAndNil(SL);
  end;
end;

initialization

OnCollectDbContext := CollectFireDacContext;

finalization

OnCollectDbContext := nil;
FreeAndNil(GDataSetErrorHandler);

end.
