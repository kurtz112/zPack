unit Frame_ObjectInspector;

{
  Migrazione da TzPropertyInspector (zObjectInspector) a TzObjectInspector (zz.Inspector).

  Differenze architetturali principali:
  ─────────────────────────────────────────────────────────────────────────────
  VECCHIO (TzPropertyInspector)               NUOVO (TzObjectInspector)
  ─────────────────────────────────────────────────────────────────────────────
  OnGetCaptionColor                           → non esiste: usare OnFilterPropertyEx
                                                o OnDrawRowHeader per colorazione custom
  OnGetEditorClass (class-map interno)        → non esiste: usare cxRegisterPropertyEditor
                                                (registrazione globale in cxOI) oppure
                                                OnFilterPropertyEx per escludere righe
  ComponentRefColor                           → cxComponentPropertyRowTextColor (costante)
  Clear / Add(AObject)                        → Clear / Add(AObject)           [invariati]
  UpdateRow                                   → Refresh                         [rinominato]
  PropKinds = [pkProperties, pkReadOnly]      → filtro tramite OnFilterPropertyEx
  SortProperties = False                      → OptionsBehavior (nessuna prop diretta)
  TzPropEditorClass                           → TcxPropertyEditorClass          [da cxOI]
  zRegisterClassEditor / GetClassEditor       → cxRegisterPropertyEditor        [da cxOI]
  ─────────────────────────────────────────────────────────────────────────────

  NOTE IMPORTANTI:
  1.  TzObjectInspector eredita da TcxCustomRTTIInspector (cxOI) e NON espone
      OnGetCaptionColor né OnGetEditorClass: la colorazione per tipo va gestita
      tramite OnDrawRowHeader; la selezione dell'editor va gestita registrando
      le classi con cxRegisterPropertyEditor nell'initialization.

  2.  La gestione "class→editor" di zRegisterClassEditor è sostituita dalla
      registrazione globale DevExpress. zRegisterClassEditor e GetClassEditor
      sono stati rimossi; InitPropertyEditors (zSystemPropertyEditors) dovrà
      chiamare cxRegisterPropertyEditor al posto di zRegisterClassEditor.

  3.  OnModified → OnPropertyChanged (TNotifyEvent-compatibile tramite wrapper).

  4.  UpdateRow → Refresh (metodo pubblico di TzObjectInspector).

  5.  Il DFM è stato semplificato: il componente è creato a run-time in
      AfterConstruction per evitare dipendenze DFM dal vecchio TzPropertyInspector.
}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  cxOI,
  cxVGrid,
  cxGraphics,
  cxLookAndFeels,
  zz.Inspector,
  zTypes,
  zCollection;

type
  TFrameObjectInspector = class(TFrame)
  private
    FObjectInspector : TzObjectInspector;
    FOnModified      : TNotifyEvent;
    { Classe dell'ultimo oggetto caricato. Quando cambia, forza un Clear
      esplicito prima di Add: garantisce che ReleaseComponentProperties
      (in InternalRefresh) non operi su righe di tipo eterogeneo. }
    FLastObjectClass : TClass;

    function GetSortProperties: boolean;
    procedure InspectorPropertyChanged(Sender: TObject);
    procedure InspectorFilterPropertyEx(Sender: TObject; APropertyEditor: TcxPropertyEditor; var AIncludeProp: boolean);
    procedure SetSortProperties(const Value: boolean);
    function GetInspectedObject: TPersistent;
    procedure SetInspectedObject(Value: TPersistent);
  public
    constructor Create(AOwner: TComponent); override;
    procedure AfterConstruction; override;

    procedure Clear;
    procedure Add(AObject: TPersistent);
    procedure Refresh; // ex-UpdateRow
    procedure UpdateRow; // alias per compatibilità chiamanti esistenti

    procedure RefreshInspectedProperties;

    property SortProperties: boolean read GetSortProperties write SetSortProperties;

    property OnModified: TNotifyEvent read FOnModified write FOnModified;

    { OnGetCaptionColor non esiste nel nuovo componente.
      La colorazione dei tipi TzCollectionItem può essere implementata
      sovrascrivendo OnDrawRowHeader sul frame figlio, oppure tramite
      cxComponentPropertyRowTextColor / cxSubComponentPropertyRowTextColor
      che DevExpress applica già automaticamente ai TComponent/sub-component. }

    property ObjectInspector: TzObjectInspector read FObjectInspector;
    // eliminare dopo conv
    property zPropertyInspector: TzObjectInspector read FObjectInspector;
    property InspectedObject: TPersistent read GetInspectedObject write SetInspectedObject;
  end;

implementation

uses
  zMsg;

{$R *.dfm}
{ ── TFrameObjectInspector ───────────────────────────────────────────────── }

constructor TFrameObjectInspector.Create(AOwner: TComponent);
begin
  inherited;
  FOnModified      := nil;
  FLastObjectClass := nil;
end;

function TFrameObjectInspector.GetInspectedObject: TPersistent;
begin
  if FObjectInspector.ObjectCount > 0 then
    Result := FObjectInspector.Objects[0]
  else
    Result := nil;
end;

procedure TFrameObjectInspector.SetInspectedObject(Value: TPersistent);
begin
  Clear;
  if Value <> nil then
    Add(Value);
end;

procedure TFrameObjectInspector.AfterConstruction;
begin
  inherited;

  FObjectInspector := TzObjectInspector.Create(Self);
  FObjectInspector.Align := alClient;
  FObjectInspector.Parent := Self;
  FObjectInspector.AutoSplitter := True;

  { Notifica di modifica }
  FObjectInspector.OnPropertyChanged := InspectorPropertyChanged;

  //
  // Possibilità di escludere particolari proprietà
  // TcxFilterPropertyEvent = procedure(Sender: TObject; const PropertyName: string; var Accept: Boolean) of object;
  // FInspector.OnFilterPropertyEx := InspectorFilterPropertyEx;
end;

{ ── Gestori interni ─────────────────────────────────────────────────────── }

procedure TFrameObjectInspector.InspectorPropertyChanged(Sender: TObject);
begin
  if Assigned(FOnModified) then
    FOnModified(Sender);
end;

procedure TFrameObjectInspector.InspectorFilterPropertyEx(Sender: TObject; APropertyEditor: TcxPropertyEditor; var AIncludeProp: boolean);
var
  Attrs: TcxPropertyAttributes;
begin
  { Replica il comportamento di PropKinds = [pkProperties, pkReadOnly]:
    include tutte le proprietà visibili, esclude eventi (tkMethod).
    Se nel vecchio codice si nascondevano le read-only, rimuovere il commento
    sulla riga ipaReadOnly qui sotto. }
  if APropertyEditor.GetPropType^.Kind = tkMethod then
  begin
    AIncludeProp := False;
    Exit;
  end;

  Attrs := APropertyEditor.GetAttributes;

  { Opzionale: escludere le proprietà non scrivibili
    if ipaReadOnly in Attrs then
    AIncludeProp := False; }
end;

{ ── API pubblica ────────────────────────────────────────────────────────── }

procedure TFrameObjectInspector.Clear;
begin
  FLastObjectClass := nil;
  FObjectInspector.Clear;
end;

procedure TFrameObjectInspector.Add(AObject: TPersistent);
begin
  if not Assigned(AObject) then
    Exit;

  { Se il tipo è cambiato rispetto all'ultimo oggetto caricato, forza un
    Clear prima di Add. Senza questo, InternalRefresh chiamerebbe
    ReleaseComponentProperties su righe costruite per il tipo precedente
    mentre il nuovo oggetto ha una struttura di proprietà diversa,
    causando accessi a indici non validi nel TcxCustomRTTIInspector. }
  if Assigned(FLastObjectClass) and (FLastObjectClass <> AObject.ClassType) then
  begin
    FLastObjectClass := nil;
    FObjectInspector.Clear;
  end;

  FLastObjectClass := AObject.ClassType;
  FObjectInspector.Add(AObject);
end;

procedure TFrameObjectInspector.Refresh;
begin
  FObjectInspector.Refresh;
end;

procedure TFrameObjectInspector.SetSortProperties(const Value: boolean);
begin
  ObjectInspector.OptionsView.Sorted := Value;
end;

function TFrameObjectInspector.GetSortProperties: boolean;
begin
  Result := ObjectInspector.OptionsView.Sorted;
end;

procedure TFrameObjectInspector.RefreshInspectedProperties;
begin
  { RefreshInspectedProperties di cxOI non e' virtual e, con InspectedObject
    nil come usa TzObjectInspector, non ricostruisce nulla: il refresh
    multi-oggetto e' Refresh. }
  ObjectInspector.Refresh;
end;

procedure TFrameObjectInspector.UpdateRow;
begin
  { Alias per compatibilità con i chiamanti che usavano UpdateRow.
    Il nuovo componente non ha il concetto di "aggiornare solo la riga corrente":
    Refresh ri-renderizza l'intero inspector in modo efficiente. }
  FObjectInspector.Refresh;
end;

{ ── Initialization ──────────────────────────────────────────────────────── }
{
  La registrazione globale degli editor di proprietà è stata spostata in
  zSystemPropertyEditors.InitPropertyEditors, che chiamerà
  cxRegisterPropertyEditor al posto di zRegisterClassEditor.

  L'editor TStrings era registrato qui nel vecchio codice:
  zRegisterClassEditor(TStrings, TzStringListEditor)
  Nel mondo DevExpress cxOI, TcxStringsProperty is già registrato di default
  per TStrings nell'initialization di cxOI.pas. Se si vuole un editor custom,
  chiamare cxRegisterPropertyEditor nella section initialization qui sotto.
}

initialization

{ Esempio: editor custom per TStrings (se si vuole mantenere il comportamento
  originale dell'InputMemo invece di quello DevExpress predefinito):

  cxRegisterPropertyEditor(TypeInfo(TStrings), nil, '', TMyStringsEditor);

  dove TMyStringsEditor è il port di TzStringListEditor su TcxPropertyEditor.
  Vedi nota nella sezione ANALISI del documento di migrazione allegato.
}

end.
