unit zGdpr.Classifier;

{
  Classificatore di sensibilita' GDPR — DATA LAYER.

  Regola di precedenza a DUE FASI (NON un Max puro):

    FASE 1 — livello ESPLICITO del campo (classificazione del DATO):
        se override-per-campo (origin) e' classificato  -> quello
        elif il domain e' classificato                   -> il domain
        else                                              -> NON CLASSIFICATO

    FASE 2 — applicazione di form e minore eta':
        se NON classificato  -> livello = livello-form (il default di prudenza)
        altrimenti           -> livello = livello esplicito (VINCE anche se piu'
                                basso del livello-form: un dato dichiarato non
                                personale resta tale anche in form sensibile)
        poi SEMPRE: livello = Max(livello, escalation-minore)

  Distinzione cruciale NON-CLASSIFICATO vs slNone-ESPLICITO (sono OPPOSTI):
    - non classificato -> eredita il livello-form (in form sensibile e' protetto)
    - slNone esplicito -> vince sul livello-form (resta visibile)
  Per questo il livello esplicito e' un OPZIONALE (TAISensitivityOpt), non un
  semplice TAISensitivity: serve un terzo stato "assente".

  La minore eta' resta l'unico vincolo sopra tutto (e' legge): innalza ad almeno
  slRedacted anche un campo esplicitamente piu' basso; slSpecial resta slSpecial.

  Sorgente del livello esplicito: TzSystem.GetDomain(Field) ritorna l'item del
  data dictionary (TzDomain — nome storico fuorviante: e' un item PER-CAMPO, non
  un domain SQL). L'item espone HasSensitivity + Sensitivity, popolati da
  zSystem_Init dalla colonna SENSITIVITY della DATA_DICTIONARY (NULL ->
  HasSensitivity=False). La precedenza origin>domain e' gia' risolta dal package,
  quindi qui basta leggere l'item.

  PREREQUISITI lato sorgenti (utente), gia' individuati:
    - TzmdDataDictionaryItem (zMetadata): + HasSensitivity, + Sensitivity;
      Fill_DataDictionary legge SENSITIVITY con test IsNull (NULL=non classificato).
    - TzDomain (zSystem): + HasSensitivity, + Sensitivity (public);
      InitDataDictionary le versa da metaDict, fuori dal blocco IsNew.
    - package BASE: SENSITIVITY nella RETURNS, COALESCE(field, domain) senza 0.
}

interface

uses
  System.SysUtils,
  Data.DB,
  zSystem,       // TzSystem (Base), TzDomain
  zAI.Types;     // TAISensitivity

type
  // Livello di sensibilita' OPZIONALE: rappresenta i tre stati
  // (assente / presente con valore). "assente" = non classificato.
  TAISensitivityOpt = record
    HasValue: Boolean;
    Level: TAISensitivity;
    class function None: TAISensitivityOpt; static;            // non classificato
    class function Some(ALevel: TAISensitivity): TAISensitivityOpt; static;
  end;

  // Risolutore del livello esplicito di un campo: ritorna l'opzionale combinato
  // (override-origin con priorita' sul domain). "assente" se ne' origin ne'
  // domain classificano il campo.
  TAIFieldLevelResolver = reference to function(
    const AField: TField): TAISensitivityOpt;

  // Contesto del record per gli strati che dipendono dal record, non dal campo.
  // Cresce con i fatti del soggetto che modulano la sensibilita':
  //  - IsMinor       : la minore eta' innalza i dati personali (vincolo di legge)
  //  - IsLegalEntity : azienda vs persona fisica. Lo stesso dato pesa diverso
  //                    (es. una ragione sociale o una morosita' d'impresa sono
  //                    meno protette degli equivalenti su persona fisica). Il
  //                    canale e' predisposto; come moduli la sensibilita' e' una
  //                    decisione di merito successiva.
  TGdprRecordContext = record
    IsMinor: Boolean;
    IsLegalEntity: Boolean;
    class function Create(AIsMinor: Boolean;
      AIsLegalEntity: Boolean = False): TGdprRecordContext; static;
    class function Empty: TGdprRecordContext; static;
  end;

  IzGdprClassifier = interface
    ['{2D9C4F18-6B53-4E7A-9F02-8A1C5E3D7B64}']
    function Classify(const AField: TField; const AFormMinLevel: TAISensitivity;
      const ARecord: TGdprRecordContext): TAISensitivity;
  end;

  TGdprClassifier = class(TInterfacedObject, IzGdprClassifier)
  private
    FResolveLevel: TAIFieldLevelResolver;
    function MinorEscalate(ALevel: TAISensitivity): TAISensitivity;
  public
    // AResolveLevel opzionale: se nil usa il default basato su Base.GetDomain.
    constructor Create(const AResolveLevel: TAIFieldLevelResolver = nil);
    function Classify(const AField: TField; const AFormMinLevel: TAISensitivity;
      const ARecord: TGdprRecordContext): TAISensitivity;
  end;

function MaxSensitivity(A, B: TAISensitivity): TAISensitivity;

// Risolutore di default: usa Base.GetDomain e legge il livello esplicito dal
// TzDomain. NB: l'accesso concreto al livello del domain dipende dal modello
// che l'utente scegliera' su TzDomain (vedi prerequisito in intestazione);
// questa funzione e' il punto unico da adattare.
function DefaultFieldLevelResolver(const AField: TField): TAISensitivityOpt;

implementation

function MaxSensitivity(A, B: TAISensitivity): TAISensitivity;
begin
  if Ord(A) >= Ord(B) then
    Result := A
  else
    Result := B;
end;

{ TAISensitivityOpt }

class function TAISensitivityOpt.None: TAISensitivityOpt;
begin
  Result.HasValue := False;
  Result.Level := slNone;
end;

class function TAISensitivityOpt.Some(ALevel: TAISensitivity): TAISensitivityOpt;
begin
  Result.HasValue := True;
  Result.Level := ALevel;
end;

function DefaultFieldLevelResolver(const AField: TField): TAISensitivityOpt;
var
  domain: TzDomain;
begin
  Result := TAISensitivityOpt.None;
  if not Assigned(Base) then
    Exit;

  // TzSystem.GetDomain risolve Field -> FIELD_ORIGIN -> zDataDictionary, che e'
  // una collezione PER-CAMPO (TzDomain e' un item del data dictionary, non un
  // domain SQL). La sensibilita' e' gia' risolta dal package con precedenza
  // origin > domain e versata sull'item, quindi l'override per-campo e'
  // preservato: leggere qui non perde granularita'.
  domain := Base.GetDomain(AField);
  if not Assigned(domain) then
    Exit; // nessun item risolvibile -> non classificato (campi calcolati, ecc.)

  // HasSensitivity distingue "non classificato" (NULL nel registro) da
  // "slNone esplicito": solo il primo eredita il livello-form.
  if domain.HasSensitivity then
    Result := TAISensitivityOpt.Some(domain.Sensitivity);
end;

{ TGdprRecordContext }

class function TGdprRecordContext.Create(AIsMinor: Boolean;
  AIsLegalEntity: Boolean): TGdprRecordContext;
begin
  Result.IsMinor := AIsMinor;
  Result.IsLegalEntity := AIsLegalEntity;
end;

class function TGdprRecordContext.Empty: TGdprRecordContext;
begin
  Result.IsMinor := False;
  Result.IsLegalEntity := False;
end;

{ TGdprClassifier }

constructor TGdprClassifier.Create(const AResolveLevel: TAIFieldLevelResolver);
begin
  inherited Create;
  if Assigned(AResolveLevel) then
    FResolveLevel := AResolveLevel
  else
    FResolveLevel := DefaultFieldLevelResolver;
end;

function TGdprClassifier.MinorEscalate(ALevel: TAISensitivity): TAISensitivity;
begin
  if ALevel = slSpecial then
    Result := slSpecial
  else
    Result := MaxSensitivity(ALevel, slRedacted);
end;

function TGdprClassifier.Classify(const AField: TField;
  const AFormMinLevel: TAISensitivity;
  const ARecord: TGdprRecordContext): TAISensitivity;
var
  explicitLevel: TAISensitivityOpt;
  level: TAISensitivity;
begin
  // FASE 1 — livello esplicito del campo (override-origin > domain), opzionale.
  if Assigned(FResolveLevel) then
    explicitLevel := FResolveLevel(AField)
  else
    explicitLevel := TAISensitivityOpt.None;

  // FASE 2 — form e minore.
  if explicitLevel.HasValue then
    level := explicitLevel.Level     // l'esplicito VINCE, anche se < form
  else
    level := AFormMinLevel;          // non classificato -> default di prudenza

  if ARecord.IsMinor then
    level := MinorEscalate(level);   // la minore eta' resta sopra tutto

  Result := level;
end;

end.
