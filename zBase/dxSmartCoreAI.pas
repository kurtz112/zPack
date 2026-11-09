unit dxSmartCoreAI;

interface

uses
  System.Threading,
  System.SyncObjs,
  System.Classes,
  System.SysUtils,
  dxAI,
  dxAI.Commands.Text,
  SmartCoreAI.Comp.Connection,
  SmartCoreAI.Types,
  SmartCoreAI.Comp.Chat;

var
  // IN CHE LINGUA DEVE RISPONDERE L'ASSISTENTE DEI CONTROLLI.
  //
  // I comandi di DevExpress -- Riassumi, Correggi, Cambia stile -- mandano al
  // modello una richiesta scritta in inglese, e non dicono in che lingua
  // rispondere. Un modello che riceve un'istruzione in inglese risponde in
  // inglese, e su un testo italiano non riscrive: traduce. Chiedendo di
  // cambiare stile a una frase italiana tornava la stessa frase in inglese.
  //
  // Qui si dichiara la lingua una volta per tutta l'applicazione, e finisce
  // in coda a ogni richiesta. Vuota = nessuna imposizione, cioe' il
  // comportamento di prima.
  //
  // E' una variabile e non una costante perche' un domani l'applicazione
  // potrebbe volerla cambiare da un'impostazione, senza ricompilare la
  // libreria.
  dxSmartCoreAILingua: string = '';

type

  { TdxSmartCoreAIChatClient }

  TdxSmartCoreAIChatClient = class(TdxAIChatClient)
  private
    FConnection: TAIConnection;
    FRequest: TAIChatRequest;
    FResponseEvent: TEvent;
    FLastResponse: string;
    FLastError: string;
    function EstraiTesto(const ATesto: string): string;
    function ConvertResponse(const AResponseText: string): TdxAIChatResponse;
    function ConvertError(const AErrorMessage: string): TdxAIChatResponse;
    function GetCombinedPrompt(const AMessages: IEnumerable<TdxAIChatMessage>): string;
    function PerformChatRequest(const AMessages: IEnumerable<TdxAIChatMessage>; const AOptions: TdxAIChatOptions): TdxAIChatResponse;
    procedure ResponseHandler(ASender: TObject; const AText: string);
    procedure ErrorHandler(ASender: TObject; const AErrorMessage: string);
  public
    constructor Create(ADriver: TAIDriver);
    destructor Destroy; override;
    function GetResponseAsync(const AMessages: IEnumerable<TdxAIChatMessage>; const AOptions: TdxAIChatOptions = nil; const ACancellationToken: TObject = nil): IFuture<TdxAIChatResponse>; override;
  end;

implementation

uses
  // JSON per EstraiTesto, che spacchetta le risposte impacchettate dal
  // modello.
  System.JSON;

{ TdxSmartCoreAIChatClient }

constructor TdxSmartCoreAIChatClient.Create(ADriver: TAIDriver);
begin
  inherited Create;
  FConnection := TAIConnection.Create(nil);
  FRequest := TAIChatRequest.Create(nil);
  FResponseEvent := TEvent.Create;
  FRequest.OnResponse := ResponseHandler;
  FRequest.OnError := ErrorHandler;
  FConnection.Driver := ADriver;
  FRequest.Connection := FConnection;
end;

destructor TdxSmartCoreAIChatClient.Destroy;
begin
  FResponseEvent.Free;
  FConnection.Free;
  FRequest.Free;
  inherited;
end;

function TdxSmartCoreAIChatClient.GetResponseAsync(const AMessages: IEnumerable<TdxAIChatMessage>; const AOptions: TdxAIChatOptions; const ACancellationToken: TObject): IFuture<TdxAIChatResponse>;
begin
  Result := TTask.Future<TdxAIChatResponse>(
    function: TdxAIChatResponse
    begin
      Result := PerformChatRequest(AMessages, AOptions);
    end);
end;

// IL TESTO DELLA RISPOSTA, ANCHE QUANDO IL MODELLO SI IMPACCHETTA DA SOLO.
//
// Un modello dovrebbe rispondere con il testo e basta. I modelli piccoli, e
// quelli che girano in locale, ogni tanto rispondono con il messaggio intero
// nel formato in cui l'hanno imparato:
//
//   {"role": "assistant", "content": "Hey, we'll just ask you..."}
//
// Senza questo controllo quel JSON finisce tale e quale nella finestra
// dell'assistente, e da li' nel documento se si preme Sostituisci.
//
// Si guarda solo la forma piu' comune -- un oggetto con "content" -- e alla
// prima difficolta' si restituisce il testo com'e': una risposta strana e'
// meglio di una risposta persa.
function TdxSmartCoreAIChatClient.EstraiTesto(const ATesto: string): string;
const
  // I nomi con cui i modelli chiamano il campo che contiene la risposta. Non
  // esiste uno standard: ognuno usa il suo, e questi sono quelli visti.
  CampiNoti: array [0 .. 7] of string = ('content', 'answer', 'text',
    'response', 'result', 'output', 'summary', 'translation');
var
  Pulito: string;
  Oggetto: TJSONObject;
  Coppia: TJSONPair;
  Contenuto: TJSONValue;
  Nome: string;
  Unica: TJSONString;
  Quante: Integer;
begin
  Result := ATesto;
  Pulito := Trim(ATesto);

  // Un blocco di codice attorno all'oggetto: capita, e sotto c'e' comunque un
  // JSON.
  if Pulito.StartsWith('```') then
  begin
    Pulito := Trim(Pulito.Substring(Pulito.IndexOf(#10) + 1));
    if Pulito.EndsWith('```') then
      Pulito := Trim(Pulito.Substring(0, Length(Pulito) - 3));
  end;

  if (Pulito = '') or (Pulito[1] <> '{') then
    Exit;

  Oggetto := TJSONObject.ParseJSONValue(Pulito) as TJSONObject;
  if not Assigned(Oggetto) then
    Exit;

  try
    // 1. Uno dei nomi conosciuti.
    for Nome in CampiNoti do
    begin
      Contenuto := Oggetto.GetValue(Nome);
      if Contenuto is TJSONString then
        Exit(TJSONString(Contenuto).Value);
    end;

    // 2. Un oggetto con UN SOLO campo di testo: qualunque nome abbia, la
    // risposta e' quella. E' il caso di {"risposta": "..."} e di tutte le
    // varianti che non si possono elencare.
    Quante := 0;
    Unica := nil;
    for Coppia in Oggetto do
      if Coppia.JsonValue is TJSONString then
      begin
        Inc(Quante);
        Unica := TJSONString(Coppia.JsonValue);
      end;

    if (Quante = 1) and Assigned(Unica) then
      Exit(Unica.Value);

    // 3. Nient'altro. Restituire il JSON com'e' sarebbe inutile a chi legge,
    // ma inventarsi quale pezzo tenere lo sarebbe di piu': con una struttura
    // a passi, per dire, il testo utile non c'e' proprio -- il modello ha
    // raccontato come avrebbe fatto il lavoro invece di farlo.
  finally
    Oggetto.Free;
  end;
end;

function TdxSmartCoreAIChatClient.ConvertResponse(const AResponseText: string): TdxAIChatResponse;
var
  AMessage: TdxAIChatMessage;
begin
  AMessage := TdxAIChatMessage.Create(TdxAIChatRole.Assistant, EstraiTesto(AResponseText));
  Result := TdxAIChatResponse.Create(AMessage, TdxAIChatFinishReason.Stop);
end;

function TdxSmartCoreAIChatClient.ConvertError(const AErrorMessage: string): TdxAIChatResponse;
var
  AMessage: TdxAIChatMessage;
begin
  AMessage := TdxAIChatMessage.Create(TdxAIChatRole.Assistant, AErrorMessage);
  Result := TdxAIChatResponse.Create(AMessage, TdxAIChatFinishReason.Error);
end;

function TdxSmartCoreAIChatClient.GetCombinedPrompt(const AMessages: IEnumerable<TdxAIChatMessage>): string;
var
  AMessage: TdxAIChatMessage;
  AStrings: TStrings;
begin
  Result := '';
  AStrings := TStringList.Create;
  try
    for AMessage in AMessages do
      AStrings.Add(AMessage.Text);

    // La lingua in coda e non in testa: e' l'ultima cosa che il modello legge
    // prima di rispondere, ed e' li' che pesa di piu'.
    if dxSmartCoreAILingua <> '' then
      AStrings.Add(Format('Rispondi in %s.', [dxSmartCoreAILingua]));

    Result := AStrings.Text;
  finally
    AStrings.Free;
  end;
end;

function TdxSmartCoreAIChatClient.PerformChatRequest(const AMessages: IEnumerable<TdxAIChatMessage>; const AOptions: TdxAIChatOptions): TdxAIChatResponse;
var
  ACombinedPrompt: string;
begin
  FResponseEvent.ResetEvent;
  FLastError := '';
  FLastResponse := '';
  ACombinedPrompt := GetCombinedPrompt(AMessages);
  FRequest.Chat(ACombinedPrompt);
  if FResponseEvent.WaitFor(60_000) <> wrTimeout then
  begin
    if FLastError <> '' then
      Result := ConvertError(FLastError)
    else
      Result := ConvertResponse(FLastResponse)
  end
  else
    raise Exception.Create('Timeout for a response from the model has been reached.');
end;

procedure TdxSmartCoreAIChatClient.ResponseHandler(ASender: TObject; const AText: string);
begin
  FLastResponse := AText;
  FResponseEvent.SetEvent;
end;

procedure TdxSmartCoreAIChatClient.ErrorHandler(ASender: TObject; const AErrorMessage: string);
begin
  FLastError := AErrorMessage;
  FResponseEvent.SetEvent;
end;

end.
