// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-23
// ---------------------------------------------------------------------------
unit zTranslate.Apply;

// Traduzione in esecuzione delle resourcestring di DevExpress e di Delphi.
//
// I testi stanno nella risorsa ITALIANO (italiano.res, generata dal programma
// zTranslate): una riga famiglia.nome=testo per costante. Translate scorre le
// famiglie registrate in dxResourceStringsRepository, cioe' solo quelle che il
// programma linka davvero, e per ogni costante con un testo nella risorsa
// sostituisce il testo in memoria con PatchResourceString. Fanno eccezione i
// nomi delle funzioni del foglio di calcolo, tradotti con cxSetResourceString
// (vedi TranslateResString).
//
// Non usa nessuna unit DevExpress di testo: un programma non si porta dietro
// i prodotti che non usa. Le famiglie di Delphi le registra
// zTranslate.DelphiConsts, che questa unit usa.
//
// Va chiamata all'avvio, prima di creare le form, e non dall'initialization:
// le unit DevExpress di testo si registrano nella loro initialization e quelle
// che venissero dopo resterebbero in inglese.

interface

type
  TTranslationReport = record
    Families: integer;
    Constants: integer;
    Applied: integer;
    // costanti linkate senza testo nella risorsa: restano in inglese
    Untranslated: integer;
    // id scartati perche' i segnaposto non coincidono con l'inglese linkato
    Rejected: TArray<string>;
    // id che non si sono potuti scrivere in memoria
    Failed: TArray<string>;
    // risorsa mancante o illeggibile: niente e' stato tradotto
    Error: string;
    function Summary: string;
  end;

const
  DefaultResourceName = 'ITALIANO';

// Traduce con la risorsa linkata nel programma.
function Translate(const ResourceName: string = DefaultResourceName): TTranslationReport;

// Traduce con un testo nel formato di italiano.txt: per le prove e per
// l'anteprima del programma zTranslate.
function TranslateText(const Text: string): TTranslationReport;

// Esito dell'ultima traduzione, per chi la chiama dentro un try/except.
function LastTranslationReport: TTranslationReport;

implementation

{$R italiano.res}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  dxCore,
  zTranslate.Text,
  zTranslate.ResourceStrings,
  zTranslate.DelphiConsts;

type
  // Classe di accesso: Translate del prodotto e' protetto
  TProductResourceStringsAccess = class(TdxProductResourceStrings);

  // Gestore dell'evento del repository: un metodo di istanza, mai una class
  // procedure (un TMethod con il riferimento di classe in Data non regge).
  TTranslator = class
  private
    Texts: TDictionary<string, string>;
    Family: string;
    Report: TTranslationReport;
    Rejected: TList<string>;
    Failed: TList<string>;
    procedure TranslateResString(const AResStringName: string; AResString: Pointer);
    function IsSpreadSheetFunctionName(const AResStringName: string): boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadText(const Text: string);
    function Run: TTranslationReport;
  end;

var
  LastReport: TTranslationReport;

function TTranslationReport.Summary: string;
begin
  if Error <> '' then
    exit('Traduzione non eseguita: ' + Error);

  result := Format('Famiglie %d, costanti %d, tradotte %d, senza testo %d, scartate %d, non scritte %d',
    [Families, Constants, Applied, Untranslated, Length(Rejected), Length(Failed)]);
end;

constructor TTranslator.Create;
begin
  inherited Create;
  Texts := TDictionary<string, string>.Create;
  Rejected := TList<string>.Create;
  Failed := TList<string>.Create;
end;

destructor TTranslator.Destroy;
begin
  Failed.Free;
  Rejected.Free;
  Texts.Free;
  inherited;
end;

procedure TTranslator.LoadText(const Text: string);
var
  Start, Index, Finish: integer;
  Line, Id, Value: string;
begin
  // Gli a capo veri separano le righe; quelli dei testi sono scritti come \n
  Start := 1;
  for Index := 1 to Length(Text) + 1 do
    if (Index > Length(Text)) or (Text[Index] = #10) then
    begin
      Finish := Index;
      if (Finish > Start) and (Text[Finish - 1] = #13) then
        Dec(Finish);
      Line := Copy(Text, Start, Finish - Start);
      if ParseTextLine(Line, Id, Value) then
        Texts.AddOrSetValue(Id, Value);
      Start := Index + 1;
    end;
end;

procedure TTranslator.TranslateResString(const AResStringName: string; AResString: Pointer);
var
  Id, Italian, English: string;
begin
  Inc(Report.Constants);
  Id := MakeId(Family, AResStringName);

  if not Texts.TryGetValue(Id, Italian) then
  begin
    Inc(Report.Untranslated);
    exit;
  end;

  // L'inglese della libreria linkata, non quello su cui e' stata fatta la
  // traduzione: se DevExpress ha cambiato i segnaposto, la traduzione vecchia
  // farebbe fallire Format. Meglio l'inglese che un errore.
  English := OriginalResourceString(AResString);
  if not SamePlaceholders(English, Italian) then
  begin
    Rejected.Add(Id);
    exit;
  end;

  // I nomi delle funzioni del foglio di calcolo (sfnSum=SOMMA) valgono due volte:
  // DevExpress li legge con cxGetResourceString per quello che vede e scrive
  // l'utente, e con LoadResString per leggere e scrivere i file XLSX, dove i nomi
  // sono sempre inglesi. Sostituire il record li tradurrebbe anche nei file: un
  // modello con SUM(...) si caricherebbe con una funzione sconosciuta (#NOME?) e
  // un foglio salvato conterrebbe SOMMA(...), che Excel non riconosce.
  // cxSetResourceString traduce solo il primo uso.
  if IsSpreadSheetFunctionName(AResStringName) then
  begin
    cxSetResourceString(AResString, Italian);
    Inc(Report.Applied);
    exit;
  end;

  if PatchResourceString(AResString, Italian) then
    Inc(Report.Applied)
  else
    Failed.Add(Id);
end;

function TTranslator.IsSpreadSheetFunctionName(const AResStringName: string): boolean;
begin
  // sfn* della famiglia ExpressSpreadSheet: nomi, descrizioni, parametri e
  // categorie delle funzioni, tutti letti da DevExpress con cxGetResourceString
  result := Family.StartsWith('ExpressSpreadSheet', true) and AResStringName.StartsWith('sfn', true);
end;

function TTranslator.Run: TTranslationReport;
var
  Repository: TdxResourceStringsRepository;
  PreviousHandler: TdxLocalizationTranslateResStringEvent;
  Index: integer;
begin
  Repository := dxResourceStringsRepository;

  // Il repository ha un solo evento: se qualcun altro lo usa, lo si rimette.
  PreviousHandler := Repository.OnTranslateResString;
  Repository.OnTranslateResString := TranslateResString;
  try
    for Index := 0 to Repository.ProductsCount - 1 do
    begin
      Family := Repository.Products[Index].Name;
      Inc(Report.Families);
      TProductResourceStringsAccess(Repository.Products[Index]).Translate;
    end;
  finally
    Repository.OnTranslateResString := PreviousHandler;
  end;

  // I componenti DevExpress che ascoltano il repository rileggono i testi
  Repository.NotifyListeners;

  Report.Rejected := Rejected.ToArray;
  Report.Failed := Failed.ToArray;
  result := Report;
end;

function ReadResourceText(const ResourceName: string; out Text, Error: string): boolean;
var
  Module: HMODULE;
  Stream: TResourceStream;
  Bytes: TBytes;
  Start: integer;
begin
  result := false;
  Text := '';
  Error := '';

  // HInstance e' il modulo che contiene questa unit (un pacchetto, se la unit
  // sta in un pacchetto), MainInstance l'eseguibile: la risorsa sta in quello
  // che ha linkato italiano.res.
  Module := HInstance;
  if FindResource(Module, PChar(ResourceName), RT_RCDATA) = 0 then
  begin
    Module := MainInstance;
    if FindResource(Module, PChar(ResourceName), RT_RCDATA) = 0 then
    begin
      Error := Format('risorsa %s non trovata', [ResourceName]);
      exit;
    end;
  end;

  try
    Stream := TResourceStream.Create(Module, ResourceName, RT_RCDATA);
    try
      SetLength(Bytes, Stream.Size);
      if Stream.Size > 0 then
        Stream.ReadBuffer(Bytes[0], Stream.Size);
    finally
      Stream.Free;
    end;

    Start := 0;
    if (Length(Bytes) >= 3) and (Bytes[0] = $EF) and (Bytes[1] = $BB) and (Bytes[2] = $BF) then
      Start := 3;
    Text := TEncoding.UTF8.GetString(Bytes, Start, Length(Bytes) - Start);
    result := true;
  except
    on E: Exception do
      Error := Format('risorsa %s illeggibile: %s', [ResourceName, E.Message]);
  end;
end;

function TranslateText(const Text: string): TTranslationReport;
var
  Translator: TTranslator;
begin
  Translator := TTranslator.Create;
  try
    Translator.LoadText(Text);
    result := Translator.Run;
  finally
    Translator.Free;
  end;
  LastReport := result;
end;

function Translate(const ResourceName: string): TTranslationReport;
var
  Text, Error: string;
begin
  if not ReadResourceText(ResourceName, Text, Error) then
  begin
    result := Default(TTranslationReport);
    result.Error := Error;
    LastReport := result;
    exit;
  end;

  result := TranslateText(Text);
end;

function LastTranslationReport: TTranslationReport;
begin
  result := LastReport;
end;

end.
