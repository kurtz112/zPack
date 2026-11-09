unit zAI.Context.Orchestrator;

{
  Orchestrazione del contesto AI: mette insieme policy + livello-form +
  componenti vivi e produce il TAIContext (e il suo JSON).

  Tre responsabilita':

   1. RISOLUZIONE POLICY — combina i vincoli del PROVIDER e dell'UTENTE con la
      regola "il piu' restrittivo vince" (mai un OR permissivo). E' il punto di
      sicurezza: una policy risolta male e' una falla. La disclosure risultante
      e' la PIU' restrittiva (Min, perche' ddFull<ddMasked<ddNone come ordine di
      permissivita' decrescente -> piu' restrittivo = Ord piu' alto = Max
      sull'enum); AllowActions e' un AND (serve il consenso di entrambi).

   2. LIVELLO-FORM — legge il minimo di sensibilita' dichiarato dalla form
      (TFormOptions.AIMinSensitivity). Le form che non lo dichiarano -> slNone.

   3. COSTRUZIONE — istanzia TAIContextBuilder e scorre i componenti vivi della
      form, raccogliendo il contesto di ciascuno.

  Nota: la lettura concreta di "provider", "utente", "componenti vivi della
  form" dipende da API che variano e/o sono in evoluzione (vedi migrazione D13).
  Qui l'orchestratore espone gli ingressi come dati gia' estratti
  (TAIProviderConstraints, TAIUserConstraints) e un enumeratore di componenti
  iniettabile, cosi' resta indipendente dalle sorgenti e testabile.
}

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  zSystem,            // IzBaseComponent
  zAI.Context,
  zAI.Context.Builder, // TAIRecordContextResolver
  zGdpr.Classifier;

type
  // Vincoli che il PROVIDER AI impone (es. Ollama locale permissivo, Claude/
  // Vertex remoti restrittivi). Estratti a monte da chi sceglie il provider.
  TAIProviderConstraints = record
    MaxDisclosure: TAIDataDisclosure; // massimo livello di disclosure concesso
    AllowActions: Boolean;
    class function Create(AMaxDisclosure: TAIDataDisclosure;
      AAllowActions: Boolean): TAIProviderConstraints; static;
  end;

  // Vincoli che l'UTENTE/ruolo impone.
  TAIUserConstraints = record
    MaxDisclosure: TAIDataDisclosure;
    AllowActions: Boolean;
    class function Create(AMaxDisclosure: TAIDataDisclosure;
      AAllowActions: Boolean): TAIUserConstraints; static;
  end;

  // Callback invocato per ogni componente vivo: (componente, ha il focus).
  // Tipo esplicito (con const) invece di TProc<,> perche' i parametri const
  // cambiano la firma e TProc<,> non li userebbe.
  TAILiveComponentProc = reference to procedure(
    const AComp: IzBaseComponent; const AIsFocused: Boolean);

  // Enumeratore dei componenti vivi di una form, con indicazione del focus.
  // Iniettato dal chiamante (la sorgente varia: TzFormController, ForEach<>,
  // ecc.). Per ogni componente vivo invoca ACallback.
  TAILiveComponentEnumerator = reference to procedure(
    const ACallback: TAILiveComponentProc);

  TAIContextOrchestrator = record
  public
    // Combina i vincoli di provider e utente: disclosure piu' restrittiva,
    // azioni consentite solo se entrambi le consentono.
    class function ResolvePolicy(const AProvider: TAIProviderConstraints;
      const AUser: TAIUserConstraints;
      const AMaskHook: TAIMaskHook = nil): TAIContextPolicy; static;

    // Costruisce il contesto completo di una form.
    //  AFormId/AFormTitle : identificazione della form attiva
    //  APolicy            : gia' risolta (vedi ResolvePolicy)
    //  AFormMinLevel      : TFormOptions.AIMinSensitivity della form
    //  AClassifier        : il classificatore GDPR (di norma TGdprClassifier)
    //  AEnumLiveComponents: enumeratore dei componenti vivi
    class function BuildFormContext(
      const AFormId, AFormTitle: string;
      const APolicy: TAIContextPolicy;
      const AFormMinLevel: TAISensitivity;
      const AClassifier: IzGdprClassifier;
      const ARecordResolver: TAIRecordContextResolver;
      const AEnumLiveComponents: TAILiveComponentEnumerator): TAIContext; static;

    // Comodo: costruisce il contesto e ne ritorna il JSON indentato (per lo
    // smoke test / log). L'oggetto JSON e' liberato internamente.
    class function BuildFormContextJSON(
      const AFormId, AFormTitle: string;
      const APolicy: TAIContextPolicy;
      const AFormMinLevel: TAISensitivity;
      const AClassifier: IzGdprClassifier;
      const ARecordResolver: TAIRecordContextResolver;
      const AEnumLiveComponents: TAILiveComponentEnumerator): string; static;
  end;

implementation

{ TAIProviderConstraints }

class function TAIProviderConstraints.Create(AMaxDisclosure: TAIDataDisclosure;
  AAllowActions: Boolean): TAIProviderConstraints;
begin
  Result.MaxDisclosure := AMaxDisclosure;
  Result.AllowActions := AAllowActions;
end;

{ TAIUserConstraints }

class function TAIUserConstraints.Create(AMaxDisclosure: TAIDataDisclosure;
  AAllowActions: Boolean): TAIUserConstraints;
begin
  Result.MaxDisclosure := AMaxDisclosure;
  Result.AllowActions := AAllowActions;
end;

{ TAIContextOrchestrator }

class function TAIContextOrchestrator.ResolvePolicy(
  const AProvider: TAIProviderConstraints; const AUser: TAIUserConstraints;
  const AMaskHook: TAIMaskHook): TAIContextPolicy;
var
  disclosure: TAIDataDisclosure;
begin
  // ddFull(0) < ddMasked(1) < ddNone(2): l'Ord piu' alto e' il piu' restrittivo.
  // "Il piu' restrittivo vince" => si prende il massimo Ord dei due vincoli.
  if Ord(AProvider.MaxDisclosure) >= Ord(AUser.MaxDisclosure) then
    disclosure := AProvider.MaxDisclosure
  else
    disclosure := AUser.MaxDisclosure;

  // Azioni consentite solo se ENTRAMBI le consentono.
  Result := TAIContextPolicy.Create(
    disclosure,
    AProvider.AllowActions and AUser.AllowActions,
    AMaskHook);
end;

class function TAIContextOrchestrator.BuildFormContext(
  const AFormId, AFormTitle: string; const APolicy: TAIContextPolicy;
  const AFormMinLevel: TAISensitivity; const AClassifier: IzGdprClassifier;
  const ARecordResolver: TAIRecordContextResolver;
  const AEnumLiveComponents: TAILiveComponentEnumerator): TAIContext;
var
  builder: TAIContextBuilder;
  ctx: TAIContext;
begin
  ctx := Default(TAIContext);
  ctx.FormId := AFormId;
  ctx.FormTitle := AFormTitle;
  ctx.Policy := APolicy;

  builder := TAIContextBuilder.Create(AClassifier, APolicy, AFormMinLevel, ARecordResolver);

  if Assigned(AEnumLiveComponents) then
    AEnumLiveComponents(
      procedure(const AComp: IzBaseComponent; const AIsFocused: Boolean)
      var
        compCtx: TAIComponentContext;
        ok: Boolean;
      begin
        compCtx := builder.BuildComponentContext(AComp, AIsFocused, ok);
        if ok then
          ctx.AddComponent(compCtx);
      end);

  Result := ctx;
end;

class function TAIContextOrchestrator.BuildFormContextJSON(
  const AFormId, AFormTitle: string; const APolicy: TAIContextPolicy;
  const AFormMinLevel: TAISensitivity; const AClassifier: IzGdprClassifier;
  const ARecordResolver: TAIRecordContextResolver;
  const AEnumLiveComponents: TAILiveComponentEnumerator): string;
var
  ctx: TAIContext;
  obj: TJSONObject;
begin
  ctx := BuildFormContext(AFormId, AFormTitle, APolicy, AFormMinLevel,
    AClassifier, ARecordResolver, AEnumLiveComponents);
  obj := ctx.ToJSON;
  try
    Result := obj.Format(2);
  finally
    obj.Free;
  end;
end;

end.
