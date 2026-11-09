unit zAI.Context.SmokeTest;

{
  Smoke test del contesto runtime (troncone B) — unit GENERICA.

  Scopo: serializzare il TAIContext di una form viva in JSON e ispezionarlo, per
  verificare su dati reali la raccolta dei componenti vivi, RowCount, record
  corrente e l'oscuramento GDPR.

  Questa unit NON contiene logica di progetto: riceve un TAIContextSetup che il
  progetto (Gesty.AI.Resolvers, WT.AI.Resolvers, ...) costruisce con le proprie
  scelte (classificatore, resolver del record-context, policy, livello-form).

  L'enumerazione dei componenti vivi resta QUI perche' e' comune a tutti i
  progetti basati su TBaseForm: usa BaseForm.ForEach<T>, lo stesso meccanismo di
  HelpGen (EnumFormComps). Il progetto fornisce il "cosa classificare", lo smoke
  test sa il "come enumerare".
}

interface

uses
  System.SysUtils,
  System.Classes,
  BaseFrm, // TBaseForm, ForEach<T>
  zSystem, // IzBaseComponent
  zDbView,
  zDbCard,
  zDbPivot,
  zAI.Types,
  zAI.Context,
  zAI.Context.Builder, // TAIRecordContextResolver
  zGdpr.Classifier,
  zAI.Context.Orchestrator;

type
  // Tutto cio' che un progetto deve fornire per costruire il contesto. Raccolto
  // in un record cosi' che aggiungere input futuri non cambi la firma di
  // RunSmokeTest. Lo costruisce la unit di progetto (es. GestyAISetup).
  TAIContextSetup = record
    Classifier: IzGdprClassifier;
    RecordResolver: TAIRecordContextResolver;
    Provider: TAIProviderConstraints;
    User: TAIUserConstraints;
    FormMinLevel: TAISensitivity;
  end;

  // Costruisce e ritorna il JSON del contesto della form, usando le scelte di
  // progetto in ASetup. Generica: non sa nulla di Gesty/WT.
function BuildContextJSON(const ABaseForm: TBaseForm; const ASetup: TAIContextSetup): string;

// Come sopra, ma stampa anche il risultato via SmartInspect (comodo per il
// collaudo). La BaseForm di ciascun progetto chiama questa, passando il setup
// costruito dalla propria unit di resolver.
function RunSmokeTest(const ABaseForm: TBaseForm; const ASetup: TAIContextSetup): string;

implementation

uses
  zz.VCL,
  SmartInspect.VCL.SiAuto;

// Enumeratore dei componenti vivi della form, su ForEach<T>. Generico: vale per
// qualunque TBaseForm. Il focus e' best-effort (False): non essenziale al
// collaudo GDPR.
function MakeLiveEnumerator(const ABaseForm: TBaseForm): TAILiveComponentEnumerator;
begin
  Result := procedure(const ACallback: TAILiveComponentProc)
    begin
      ABaseForm.ForEach<TzDbView>(
        procedure(view: TzDbView)
        var
          comp: IzBaseComponent;
        begin
          if Supports(view, IzBaseComponent, comp) then
            ACallback(comp, False);
        end);

      ABaseForm.ForEach<TzDbCard>(
        procedure(card: TzDbCard)
        var
          comp: IzBaseComponent;
        begin
          if Supports(card, IzBaseComponent, comp) then
            ACallback(comp, False);
        end);

      ABaseForm.ForEach<TzDbPivot>(
        procedure(pivot: TzDbPivot)
        var
          comp: IzBaseComponent;
        begin
          if Supports(pivot, IzBaseComponent, comp) then
            ACallback(comp, False);
        end);
    end;
end;

function BuildContextJSON(const ABaseForm: TBaseForm; const ASetup: TAIContextSetup): string;
var
  policy: TAIContextPolicy;
begin
  Assert(Assigned(ABaseForm), 'SmokeTest: form non assegnata');

  policy := TAIContextOrchestrator.ResolvePolicy(ASetup.Provider, ASetup.User);

  Result := TAIContextOrchestrator.BuildFormContextJSON(ABaseForm.Name, ABaseForm.Caption, policy, ASetup.FormMinLevel, ASetup.Classifier, ASetup.RecordResolver, MakeLiveEnumerator(ABaseForm));
end;

function RunSmokeTest(const ABaseForm: TBaseForm; const ASetup: TAIContextSetup): string;
begin
  Result := BuildContextJSON(ABaseForm, ASetup);
  SiMain.LogString('AIContext (smoke)', Result);
end;

end.
