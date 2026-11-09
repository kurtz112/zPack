{ ******************************************************* }
{ }
{ zMultiRTTIInspector }
{ }
{ Inspector multi-oggetto basato su TcxCustomRTTIInspector }
{ (cxOI). NON richiede modifiche al sorgente DevExpress: }
{ funziona contro i DCU/DCP di serie. }
{ }
{ Come aggira i membri private di cxOI: }
{ }
{ 1. cxOI e' compilata con la RTTI di default (in cxVer.inc }
{ la direttiva $RTTI EXPLICIT ... FIELDS([]) e' commentata), }
{ quindi i campi privati sono leggibili/scrivibili via }
{ System.Rtti. }
{ Servono 5 campi: FParentRow, FCurrentRow, FLockRefresh di }
{ TcxCustomRTTIInspector; FPropertyEditor, FIsDefaultValue }
{ di TcxPropertyRow. I nomi sono verificati nel costruttore: }
{ se DevExpress li cambia, l'errore e' immediato ed esplicito. }
{ }
{ 2. RefreshInspectedProperties non e' virtual, ma con }
{ InspectedObject = nil (sempre vero qui) e' innocuo: }
{ CreatePropertyRows(nil) non rilascia e non ricrea nulla. }
{ I punti in cui cxOI lo chiama vengono coperti da: }
{ - LookAndFeelChanged (virtual) }
{ - PrepareEditProperties (virtual): riaggancia OnChange, }
{ OnEditValueChanged e OnButtonClick a handler propri }
{ - message DXM_VG_PROPERTYCHANGED (notifica dagli editor }
{ a dialogo) }
{ - controller derivato: DoEditDblClick }
{ - wrapper ShowReadOnlyProperties / Sorted }
{ }
{ Proprieta' published SENZA setter: cxOI 25.x ha gia' }
{ OptionsView.ShowReadOnlyProperties (default False) e marca }
{ ipaReadOnly i loro editor, rendendoli non editabili. }
{ TzObjectInspector accende l'opzione per default e colora }
{ in grigio le righe corrispondenti. }
{ }
{ ******************************************************* }

unit zz.Inspector;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  dxMessages,
  cxOI,
  cxVGrid,
  cxEdit,
  cxTextEdit,
  cxButtonEdit,
  cxInplaceContainer,
  cxGraphics,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxStyles,
  cxControls;

type
  TzPropEditorClass = class of TcxPropertyEditor;

  TzObjectInspector = class;

  { Controller derivato: intercetta il doppio click (che in cxOI apre il
    dialogo del property editor senza passare da eventi pubblici) per
    lanciare il refresh multi-oggetto subito dopo. }
  TzObjectInspectorController = class(TcxRTTIInspectorController)
  protected
    procedure DoEditDblClick(Sender: TObject); override;
  end;

  TzObjectInspector = class(TcxCustomRTTIInspector)
  private
    FObjects: TList;
    FAutoSplitter: Boolean;
    FPendingRefresh: Boolean;
    FRefreshing: Boolean;
    FReadOnlyStyle: TcxStyle;

    // Accesso RTTI ai campi privati di cxOI (risolti una volta in Create)
    FRtti: TRttiContext;
    FFldParentRow: TRttiField; // TcxCustomRTTIInspector.FParentRow
    FFldCurrentRow: TRttiField; // TcxCustomRTTIInspector.FCurrentRow
    FFldLockRefresh: TRttiField; // TcxCustomRTTIInspector.FLockRefresh
    FFldRowPropEditor: TRttiField; // TcxPropertyRow.FPropertyEditor
    FFldRowIsDefault: TRttiField; // TcxPropertyRow.FIsDefaultValue

    // Stato della costruzione righe in corso (sostituisce FParentRow
    // e l'owner passato ai property editor)
    FBuildParentRow: TcxCustomRow;
    FBuildOwner: TComponent;

    function GetObjectCount: Integer;
    function GetObjects(Index: Integer): TPersistent;
    procedure SetObjects(Index: Integer; Value: TPersistent);
    procedure SetAutoSplitter(Value: Boolean);
    function GetShowReadOnlyProperties: Boolean;
    procedure SetShowReadOnlyProperties(Value: Boolean);
    function GetSorted: Boolean;
    procedure SetSorted(Value: Boolean);
    procedure InternalRefresh;

    // --- accesso ai privati di cxOI ---
    procedure RisolviCampiPrivati;
    function CampoObbligatorio(AType: TRttiType; const ANome: string): TRttiField;
    procedure SetParentRow(ARow: TcxCustomRow);
    procedure SetCurrentRow(ARow: TcxPropertyRow);
    procedure SetLockRefresh(AValue: Boolean);
    procedure SetRowPropertyEditor(ARow: TcxPropertyRow; AEditor: TcxPropertyEditor);
    procedure SetRowIsDefaultValue(ARow: TcxPropertyRow; AValue: Boolean);

    // --- sostituti di CreateRows / ReleaseComponentProperties ---
    procedure CreaRiga(APropertyEditor: TcxPropertyEditor);
    procedure RilasciaRighe;

    // --- aggancio dei refresh interni di cxOI ---
    procedure zEditChange(Sender: TObject);
    procedure zEditValueChanged(Sender: TObject);
    procedure zButtonClick(Sender: TObject; AButtonIndex: Integer);
    // True se il doppio click sulla riga corrente ha fatto invocare a cxOI
    // il property editor (stessa condizione di TcxRTTIInspectorController.
    // DoEditDblClick + CanInvokePropertyEditorDlg, entrambi privati)
    function DoppioClickInvocaEditor: Boolean;
    procedure CNPropertyChanged(var AMessage: TMessage); message DXM_VG_PROPERTYCHANGED;

    procedure RegistraFreeNotification(AObject: TPersistent);

    // Percorso univoco di una riga proprieta' (caption concatenate dal
    // padre alla foglia): stesso criterio di IsReadOnlyPropertyRow, la
    // caption della riga e' il nome della proprieta'.
    function PercorsoRiga(ARiga: TcxCustomRow): string;
    // Fotografa lo stato prima del rebuild: percorsi delle righe espanse
    // e percorso della riga focalizzata.
    procedure SalvaStatoEspansione(RigheEspanse: TStringList; out PercorsoFocus: string);
    // Riallinea espansione e focus dopo cxGetComponentProperties.
    procedure RipristinaStatoEspansione(RigheEspanse: TStringList; const PercorsoFocus: string);

    // True se la riga corrisponde a una proprieta' published senza setter
    function IsReadOnlyPropertyRow(ARow: TcxCustomRow): Boolean;
    // colore grigio per le proprieta' senza setter (il blocco dell'editing
    // lo fa gia' cxOI: ProcessPropertyReadOnly -> ipaReadOnly -> ReadOnly
    // sulle edit properties della riga).
    // Firma = TcxvgOnGetContentStyleEvent (cxVGrid): la riga si ricava da
    // AEditProp.Row.
    procedure ReadOnlyGetContentStyle(Sender: TObject; AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean; ARecordIndex: Integer; var AStyle: TcxStyle);

  protected
    procedure CreateWnd; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    function GetControllerClass: TcxCustomControlControllerClass; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues); override;
    procedure PrepareEditProperties(AProperties: TcxCustomEditProperties; APropertyEditor: TcxPropertyEditor); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Add(AObject: TPersistent);
    procedure Remove(AObject: TPersistent);
    procedure Delete(Index: Integer);
    procedure Clear;
    procedure AssignObjects(AList: TList);
    function IndexOf(AObject: TPersistent): Integer;

    procedure Refresh;
    procedure UpdateSplitterPos;

    property ObjectCount: Integer read GetObjectCount;
    property Objects[Index: Integer]: TPersistent read GetObjects write SetObjects;

  published
    property AutoSplitter: Boolean read FAutoSplitter write SetAutoSplitter default true;

    // espone OptionsView.ShowReadOnlyProperties (nativa di cxOI 25.x, default
    // False) portandola a True per default: le proprieta' published senza
    // setter compaiono, cxOI le rende non editabili, questo inspector le
    // colora in grigio (comportamento del vecchio TzPropertyInspector,
    // PropKinds con pkReadOnly). "stored False": la persistenza DFM resta
    // a carico di OptionsView.
    property ShowReadOnlyProperties: Boolean read GetShowReadOnlyProperties write SetShowReadOnlyProperties stored False default true;

    // espone OptionsView.Sorted: il setter nativo chiama un refresh che qui
    // e' inerte, questo wrapper lancia quello multi-oggetto.
    property SortedProperties: Boolean read GetSorted write SetSorted stored False default true;

    property Align;
    property Anchors;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Images;
    property LayoutStyle;
    property LookAndFeel;
    property OptionsView;
    property OptionsBehavior;
    property OptionsData;
    property ParentFont;
    property PopupMenu;
    property Styles;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawBackground;
    property OnDrawRowHeader;
    property OnDrawValue;
    property OnEdited;
    property OnEditing;
    property OnEditValueChanged;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnFilterProperty;
    property OnFilterPropertyEx;
    property OnItemChanged;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnLayoutChanged;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnPropertyChanged;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnTopRowIndexChanged;
  end;

procedure Register;

implementation

type
  // Come in cxOI: OnChange / OnEditValueChanged / ReadOnly delle edit
  // properties sono protected, raggiungibili solo da un discendente.
  TzEditPropertiesAccess = class(TcxCustomEditProperties);

{ ============================================================
  Helper
  ============================================================ }

function FindRootOwner(APersistent: TPersistent): TComponent;
begin
  if APersistent is TComponent then
    Result := TComponent(APersistent).Owner
  else
    Result := nil;
  if Result <> nil then
    while (Result.Owner <> nil) and not(Result is TDataModule) and not(Result is TCustomForm) and not(Result is TCustomFrame) do
      Result := Result.Owner;
end;

{ ============================================================
  TzObjectInspectorController
  ============================================================ }

procedure TzObjectInspectorController.DoEditDblClick(Sender: TObject);
begin
  // Il padre invoca il property editor (TryInvokePropertyEditorDlg, private)
  // solo se l'editor NON e' ipaRevertable, e poi chiama un
  // RefreshInspectedProperties qui inerte: in quel caso il refresh va rifatto.
  // Per gli editor ipaRevertable (booleani, enumerati: TcxEnumProperty) il
  // padre non fa nulla di proposito: e' la combo in-place a ciclare il valore
  // (Revertable, in TcxCustomComboBox.DblClick) DOPO che questo evento e'
  // tornato. Un InternalRefresh incondizionato qui distruggeva l'editor attivo
  // (HideEdit + RilasciaRighe) prima che la combo potesse cambiare il valore:
  // il doppio click restava senza effetto. Il refresh, in quel caso, arriva
  // da zEditValueChanged quando la combo posta il nuovo valore.
  inherited DoEditDblClick(Sender);
  if (Inspector is TzObjectInspector) and TzObjectInspector(Inspector).DoppioClickInvocaEditor then
    TzObjectInspector(Inspector).InternalRefresh;
end;

{ ============================================================
  TzObjectInspector
  ============================================================ }

constructor TzObjectInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RisolviCampiPrivati;

  FObjects := TList.Create;
  FAutoSplitter := true;
  FRefreshing := False;

  // opzione nativa cxOI: include le proprieta' senza setter (ipaReadOnly)
  OptionsView.ShowReadOnlyProperties := true;

  FReadOnlyStyle := TcxStyle.Create(Self);
  FReadOnlyStyle.TextColor := clGrayText;

  Styles.OnGetContentStyle := ReadOnlyGetContentStyle;
end;

destructor TzObjectInspector.Destroy;
begin
  // 2026-09-20 - Access violation in chiusura (TList.IndexOf).
  //
  // FObjects veniva liberata PRIMA di inherited e il campo restava
  // valorizzato: un puntatore a memoria gia' liberata. Durante inherited le
  // notifiche continuano ad arrivare - la classe base distrugge i componenti
  // posseduti (qui lo stile in sola lettura) e scioglie i FreeNotification
  // registrati su ogni oggetto ispezionato - e Notification legge FObjects.
  // La guardia "FObjects <> nil" li' non serviva a niente, perche' nil non
  // c'era mai: il campo puntava a un blocco liberato, spesso gia' riusato da
  // qualcun altro, e TList.IndexOf leggeva un indirizzo qualunque.
  //
  // La lista contiene solo riferimenti, non possiede gli oggetti: tenerla in
  // piedi per tutta la durata di inherited non costa niente ed e' l'unico
  // ordine in cui Notification trova sempre o una lista valida o nil.
  inherited;
  FreeAndNil(FObjects);
  FRtti.Free;
end;

function TzObjectInspector.GetControllerClass: TcxCustomControlControllerClass;
begin
  Result := TzObjectInspectorController;
end;

procedure TzObjectInspector.CreateWnd;
begin
  inherited;

  if FPendingRefresh then
  begin
    FPendingRefresh := False;
    InternalRefresh;
  end;
end;

procedure TzObjectInspector.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);
  // un oggetto ispezionato viene distrutto: lo si toglie dalla lista prima
  // che qualche property editor tenti di leggerlo
  if (AOperation = opRemove) and (FObjects <> nil) and (FObjects.IndexOf(AComponent) >= 0) then
  begin
    FObjects.Remove(AComponent);
    if not(csDestroying in ComponentState) then
      InternalRefresh;
  end;
end;

procedure TzObjectInspector.RegistraFreeNotification(AObject: TPersistent);
begin
  if AObject is TComponent then
    TComponent(AObject).FreeNotification(Self);
end;

{ --- Accesso RTTI ai campi privati di cxOI ------------------ }

function TzObjectInspector.CampoObbligatorio(AType: TRttiType; const ANome: string): TRttiField;
begin
  Result := AType.GetField(ANome);
  if Result = nil then
    raise Exception.CreateFmt('%s: campo privato %s.%s non trovato. ' + 'La versione di cxOI (DevExpress) e'' cambiata: aggiornare zz.Inspector.', [ClassName, AType.Name, ANome]);
end;

procedure TzObjectInspector.RisolviCampiPrivati;
var
  TipoInspector, TipoRiga: TRttiType;
begin
  FRtti := TRttiContext.Create;
  TipoInspector := FRtti.GetType(TcxCustomRTTIInspector);
  TipoRiga := FRtti.GetType(TcxPropertyRow);
  FFldParentRow := CampoObbligatorio(TipoInspector, 'FParentRow');
  FFldCurrentRow := CampoObbligatorio(TipoInspector, 'FCurrentRow');
  FFldLockRefresh := CampoObbligatorio(TipoInspector, 'FLockRefresh');
  FFldRowPropEditor := CampoObbligatorio(TipoRiga, 'FPropertyEditor');
  FFldRowIsDefault := CampoObbligatorio(TipoRiga, 'FIsDefaultValue');
end;

procedure TzObjectInspector.SetParentRow(ARow: TcxCustomRow);
begin
  // letto da GetEditPropertiesClass per comporre il nome completo della
  // proprieta' passato a FilterPropertyEx
  FFldParentRow.SetValue(Self, TValue.From<TcxCustomRow>(ARow));
end;

procedure TzObjectInspector.SetCurrentRow(ARow: TcxPropertyRow);
begin
  // letto da GetStrProc quando PrepareEditProperties riempie le combo
  FFldCurrentRow.SetValue(Self, TValue.From<TcxPropertyRow>(ARow));
end;

procedure TzObjectInspector.SetLockRefresh(AValue: Boolean);
begin
  // letto dal controller (FocusChanged, DoUpdateRowAndCell) per non reagire
  // ai cambi di focus durante la ricostruzione delle righe
  FFldLockRefresh.SetValue(Self, TValue.From<Boolean>(AValue));
end;

procedure TzObjectInspector.SetRowPropertyEditor(ARow: TcxPropertyRow; AEditor: TcxPropertyEditor);
begin
  FFldRowPropEditor.SetValue(ARow, TValue.From<TcxPropertyEditor>(AEditor));
end;

procedure TzObjectInspector.SetRowIsDefaultValue(ARow: TcxPropertyRow; AValue: Boolean);
begin
  FFldRowIsDefault.SetValue(ARow, TValue.From<Boolean>(AValue));
end;

{ --- Sostituti di CreateRows / ReleaseComponentProperties ---- }

procedure TzObjectInspector.CreaRiga(APropertyEditor: TcxPropertyEditor);
{
  Replica di TcxCustomRTTIInspector.CreateRows (private) usando solo
  membri protected/public piu' i campi privati via RTTI.
  Callback di cxGetComponentProperties e, ricorsivamente, di
  TcxPropertyEditor.GetProperties per le sottoproprieta'.
}
var
  AEditPropertiesClass: TcxCustomEditPropertiesClass;
  ARiga: TcxPropertyRow;
begin
  SetParentRow(FBuildParentRow);
  AEditPropertiesClass := GetEditPropertiesClass(APropertyEditor);
  if AEditPropertiesClass = nil then
  begin
    APropertyEditor.Free;
    Exit;
  end;

  ARiga := TcxPropertyRow(AddChild(FBuildParentRow, TcxPropertyRow));
  SetCurrentRow(ARiga);
  ARiga.Properties.Caption := APropertyEditor.GetName;
  SetRowIsDefaultValue(ARiga, APropertyEditor.IsDefaultValue);
  ARiga.Properties.EditPropertiesClass := AEditPropertiesClass;
  PrepareEditProperties(ARiga.Properties.EditProperties, APropertyEditor);
  SetRowPropertyEditor(ARiga, APropertyEditor);
  // Differenza voluta rispetto a cxOI (che mostra il valore del primo
  // oggetto): con piu' oggetti e valori discordanti la cella resta vuota,
  // come nell'Object Inspector dell'IDE. Le proprieta' classe (Font, ...)
  // mantengono la loro etichetta, AllEqual per esse e' sempre False.
  if (APropertyEditor.PropCount > 1) and not(ipaSubProperties in APropertyEditor.GetAttributes) and not APropertyEditor.AllEqual then
    ARiga.Properties.Value := ''
  else
    ARiga.Properties.Value := APropertyEditor.Value;

  if ipaSubProperties in APropertyEditor.GetAttributes then
  begin
    FBuildParentRow := ARiga;
    // cxOI passa APropertyEditor.FOwner (private): e' l'owner dato a
    // cxGetComponentProperties, cioe' FBuildOwner
    APropertyEditor.GetProperties(FBuildOwner, CreaRiga);
    FBuildParentRow := ARiga.Parent;
  end;
end;

procedure TzObjectInspector.RilasciaRighe;
{
  Replica di ReleaseComponentProperties (private): libera i property
  editor azzerando il campo della riga, cosi' durante ClearRows nessun
  FocusChanged puo' leggere un PropertyEditor gia' distrutto.
}
var
  I: Integer;
  ARiga: TcxPropertyRow;
begin
  for I := 0 to Rows.Count - 1 do
    if Rows[I] is TcxPropertyRow then
    begin
      ARiga := TcxPropertyRow(Rows[I]);
      if ARiga.PropertyEditor <> nil then
      begin
        ARiga.PropertyEditor.Free;
        SetRowPropertyEditor(ARiga, nil);
      end;
    end;
  if not(csDestroying in ComponentState) then
    ClearRows;
  SetParentRow(nil);
  SetCurrentRow(nil);
  FBuildParentRow := nil;
end;

{ --- Aggancio dei refresh interni di cxOI -------------------- }

procedure TzObjectInspector.PrepareEditProperties(AProperties: TcxCustomEditProperties; APropertyEditor: TcxPropertyEditor);
begin
  inherited PrepareEditProperties(AProperties, APropertyEditor);
  // cxOI ha assegnato EditChange / EditValueChanged / RowButtonClick, che
  // terminano con un RefreshInspectedProperties qui inerte: si passa per
  // handler propri che richiamano quelli ereditati e poi InternalRefresh.
  TzEditPropertiesAccess(AProperties).OnChange := zEditChange;
  TzEditPropertiesAccess(AProperties).OnEditValueChanged := zEditValueChanged;
  if AProperties is TcxButtonEditProperties then
    TcxButtonEditProperties(AProperties).OnButtonClick := zButtonClick;
end;

procedure TzObjectInspector.zEditChange(Sender: TObject);
var
  AutoUpdate: Boolean;
begin
  AutoUpdate := (PropertyEditor <> nil) and (ipaAutoUpdate in PropertyEditor.GetAttributes);
  EditChange(Sender);
  // stesso criterio di cxOI: per gli editor ipaAutoUpdate non testuali
  // EditChange passa da TrySetValue, che nell'originale ricostruisce le righe
  if AutoUpdate and not(Sender is TcxCustomTextEdit) then
    InternalRefresh;
end;

procedure TzObjectInspector.zEditValueChanged(Sender: TObject);
begin
  EditValueChanged(Sender);
  InternalRefresh;
end;

procedure TzObjectInspector.zButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  // replica di TryInvokePropertyEditorDlg (private)
  if (PropertyEditor <> nil) and ((ipaDialog in PropertyEditor.GetAttributes) or (ipaValueList in PropertyEditor.GetAttributes)) then
  begin
    PropertyEditor.Edit;
    InternalRefresh;
  end;
end;

function TzObjectInspector.DoppioClickInvocaEditor: Boolean;
var
  Attributi: TcxPropertyAttributes;
begin
  Result := False;
  if PropertyEditor = nil then
    Exit;
  Attributi := PropertyEditor.GetAttributes;
  Result := not(ipaRevertable in Attributi) and ((ipaDialog in Attributi) or (ipaValueList in Attributi));
end;

procedure TzObjectInspector.CNPropertyChanged(var AMessage: TMessage);
begin
  // notifica postata dai property editor a dialogo (font, colori, ...)
  inherited;
  InternalRefresh;
end;

procedure TzObjectInspector.LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  // stessa condizione con cui cxOI chiama RefreshInspectedProperties
  if AChangedValues = [lfvKind .. lfvSkinName] then
    InternalRefresh;
end;

{ --- Gestione lista ---------------------------------------- }

function TzObjectInspector.GetObjectCount: Integer;
begin
  Result := FObjects.Count;
end;

function TzObjectInspector.GetObjects(Index: Integer): TPersistent;
begin
  Result := TPersistent(FObjects[Index]);
end;

procedure TzObjectInspector.SetObjects(Index: Integer; Value: TPersistent);
begin
  FObjects[Index] := Value;
  RegistraFreeNotification(Value);
  InternalRefresh;
end;

procedure TzObjectInspector.Add(AObject: TPersistent);
begin
  if (AObject <> nil) and (FObjects.IndexOf(AObject) < 0) then
  begin
    FObjects.Add(AObject);
    RegistraFreeNotification(AObject);
    InternalRefresh;
  end;
end;

procedure TzObjectInspector.Remove(AObject: TPersistent);
var
  Idx: Integer;
begin
  Idx := FObjects.IndexOf(AObject);
  if Idx >= 0 then
    Delete(Idx);
end;

procedure TzObjectInspector.Delete(Index: Integer);
begin
  FObjects.Delete(Index);
  InternalRefresh;
end;

procedure TzObjectInspector.Clear;
begin
  FObjects.Clear;
  InternalRefresh;
end;

procedure TzObjectInspector.AssignObjects(AList: TList);
var
  I: Integer;
begin
  FObjects.Clear;
  if AList <> nil then
    for I := 0 to AList.Count - 1 do
      if AList[I] <> nil then
      begin
        FObjects.Add(AList[I]);
        RegistraFreeNotification(TPersistent(AList[I]));
      end;
  InternalRefresh;
end;

function TzObjectInspector.IndexOf(AObject: TPersistent): Integer;
begin
  Result := FObjects.IndexOf(AObject);
end;

{ --- Stato di espansione ------------------------------------ }

function TzObjectInspector.PercorsoRiga(ARiga: TcxCustomRow): string;
var
  Riga: TcxCustomRow;
begin
  Result := '';
  Riga := ARiga;
  while (Riga <> nil) and (Riga is TcxPropertyRow) do
  begin
    if Result = '' then
      Result := TcxPropertyRow(Riga).Properties.Caption
    else
      Result := TcxPropertyRow(Riga).Properties.Caption + '.' + Result;
    Riga := Riga.Parent;
  end;
end;

procedure TzObjectInspector.SalvaStatoEspansione(RigheEspanse: TStringList; out PercorsoFocus: string);
var
  I: Integer;
begin
  PercorsoFocus := '';

  // Rows enumera l'albero completo (anche le righe figlie): bastano le
  // righe con figli, per le foglie Expanded non ha significato.
  for I := 0 to Rows.Count - 1 do
    if (Rows[I] is TcxPropertyRow) and (Rows[I].Count > 0) and Rows[I].Expanded then
      RigheEspanse.Add(PercorsoRiga(Rows[I]));

  if FocusedRow <> nil then
    PercorsoFocus := PercorsoRiga(FocusedRow);
end;

procedure TzObjectInspector.RipristinaStatoEspansione(RigheEspanse: TStringList; const PercorsoFocus: string);
var
  I: Integer;
begin
  // CreaRiga ha gia' costruito ricorsivamente anche le sottorighe:
  // si riallinea lo stato di espansione riga per riga (le righe non
  // presenti nel salvataggio vengono collassate, default Expanded=True).
  for I := 0 to Rows.Count - 1 do
    if (Rows[I] is TcxPropertyRow) and (Rows[I].Count > 0) then
      Rows[I].Expanded := RigheEspanse.IndexOf(PercorsoRiga(Rows[I])) >= 0;

  if PercorsoFocus <> '' then
    for I := 0 to Rows.Count - 1 do
      if (Rows[I] is TcxPropertyRow) and (PercorsoRiga(Rows[I]) = PercorsoFocus) then
      begin
        FocusedRow := Rows[I];
        Break;
      end;
end;

{ --- InternalRefresh --------------------------------------- }

procedure TzObjectInspector.InternalRefresh;
{
  Per N = 0: InspectedObject := nil usa il percorso standard.

  Per N >= 1: RilasciaRighe libera gli editor esistenti azzerando il
  campo della riga (via RTTI), poi cxGetComponentProperties con CreaRiga
  come callback costruisce le righe come farebbe cxOI.

  Non usa mai SetInspectedObject per N >= 1 perche' chiamerebbe
  CreatePropertyRows(FInspectedObject) con un solo oggetto. Tenere
  InspectedObject = nil e' anche cio' che rende inerte il
  RefreshInspectedProperties originale.

  FLockRefresh viene impostato come fa cxOI durante la ricostruzione, per
  evitare che il controller reagisca ai cambi di focus intermedi.
}
var
  ComponentList: TcxComponentList;
  RootOwner: TComponent;
  I: Integer;
  RigheEspanse: TStringList;
  PercorsoFocus: string;
  AvevaRighe: Boolean;
  TopRow: Integer;
begin
  if ([csLoading, csDestroying, csDesigning] * ComponentState) <> [] then
    Exit;

  if not HandleAllocated then
  begin
    FPendingRefresh := true;
    Exit;
  end;

  if FRefreshing then
    Exit;

  FRefreshing := true;
  RigheEspanse := TStringList.Create;
  try
    if FObjects.Count = 0 then
    begin
      InspectedObject := nil;
      RilasciaRighe;
      Exit;
    end;

    SetLockRefresh(true);
    BeginUpdate;
    try
      // Fotografa espansione e focus prima di distruggere le righe:
      // il refresh scatta anche a ogni modifica di valore (es. doppio
      // click su un booleano) e non deve far perdere lo stato visivo.
      AvevaRighe := Rows.Count > 0;
      TopRow := TopVisibleRowIndex;
      if AvevaRighe then
        SalvaStatoEspansione(RigheEspanse, PercorsoFocus);

      if Controller.IsEditing then
        HideEdit;

      RilasciaRighe;

      ComponentList := TcxComponentList.Create;
      try
        RootOwner := FindRootOwner(TPersistent(FObjects[0]));
        for I := 0 to FObjects.Count - 1 do
        begin
          ComponentList.Add(TPersistent(FObjects[I]));
          if (RootOwner <> nil) and (FindRootOwner(TPersistent(FObjects[I])) <> RootOwner) then
            RootOwner := nil;
        end;
        if RootOwner = nil then
          RootOwner := Self;

        { cxGetComponentProperties:
          - calcola l'intersezione delle proprieta' comuni
          - crea TcxPropertyEditor con PropCount = N
          - chiama CreaRiga per ogni proprieta' comune: costruisce la
          riga, imposta caption, editor, valore, gestisce le
          sottoproprieta' ricorsivamente
          - se valori discordanti: AllEqual = False -> Value = ''
          - SetValue propaga su tutti gli N oggetti }
        FBuildOwner := RootOwner;
        FBuildParentRow := nil;
        cxGetComponentProperties(RootOwner, Self, ComponentList, tkProperties, CreaRiga);
        SetParentRow(nil);
        SetCurrentRow(nil);

        // FullCollapse solo al primo popolamento: sui refresh successivi
        // (cambio valore, look&feel, ...) si ripristina lo stato salvato,
        // altrimenti ogni modifica collasserebbe le sottoproprieta'.
        if AvevaRighe then
        begin
          RipristinaStatoEspansione(RigheEspanse, PercorsoFocus);
          TopVisibleRowIndex := TopRow;
        end
        else
          FullCollapse;
      finally
        ComponentList.Free;
      end;

    finally
      EndUpdate;
      SetLockRefresh(False);
    end;

  finally
    RigheEspanse.Free;
    FRefreshing := False;
  end;

  if FAutoSplitter then
    UpdateSplitterPos;
end;

procedure TzObjectInspector.Refresh;
begin
  InternalRefresh;
end;

{ --- Proprieta' published senza setter --------------------- }

function TzObjectInspector.GetShowReadOnlyProperties: Boolean;
begin
  Result := OptionsView.ShowReadOnlyProperties;
end;

procedure TzObjectInspector.SetShowReadOnlyProperties(Value: Boolean);
begin
  if OptionsView.ShowReadOnlyProperties = Value then
    Exit;
  // il setter di OptionsView chiama RefreshInspectedProperties, qui inerte
  OptionsView.ShowReadOnlyProperties := Value;
  InternalRefresh;
end;

function TzObjectInspector.GetSorted: Boolean;
begin
  Result := OptionsView.Sorted;
end;

procedure TzObjectInspector.SetSorted(Value: Boolean);
begin
  if OptionsView.Sorted = Value then
    Exit;
  OptionsView.Sorted := Value;
  InternalRefresh;
end;

function TzObjectInspector.IsReadOnlyPropertyRow(ARow: TcxCustomRow): Boolean;
var
  Percorso: TArray<string>;
  Riga: TcxCustomRow;
  Istanza: TObject;
  Info: PPropInfo;
  I: Integer;
begin
  Result := False;

  if not OptionsView.ShowReadOnlyProperties then
    Exit;

  if not(ARow is TcxPropertyRow) then
    Exit;

  // 2026-09-20: la lista non c'e' piu' quando lo stile viene interrogato a
  // distruzione avvenuta. Prima il campo era pendente e il controllo su Count
  // leggeva memoria liberata; ora e' nil e va verificato.
  if not Assigned(FObjects) then
    Exit;

  if FObjects.Count = 0 then
    Exit;

  // Le row properties di cxOI non espongono il property editor: si
  // ricostruisce il percorso della proprieta' risalendo le righe padre —
  // la caption della riga e' il nome della proprieta', come nell'Object
  // Inspector dell'IDE — e lo si risolve via RTTI.
  Percorso := nil;
  Riga := ARow;
  while (Riga <> nil) and (Riga is TcxPropertyRow) do
  begin
    Percorso := [TcxPropertyRow(Riga).Properties.Caption] + Percorso;
    Riga := Riga.Parent;
  end;

  if Length(Percorso) = 0 then
    Exit;

  // Risolve i nodi classe intermedi partendo dal primo oggetto ispezionato:
  // per determinare il SetProc un oggetto basta (le proprieta' mostrate
  // sono l'intersezione comune).
  Istanza := TPersistent(FObjects[0]);
  for I := 0 to High(Percorso) - 1 do
  begin
    if Istanza = nil then
      Exit;

    Info := System.TypInfo.GetPropInfo(Istanza.ClassInfo, Percorso[I]);
    if (Info = nil) or (Info^.PropType^.Kind <> tkClass) then
      Exit;

    Istanza := System.TypInfo.GetObjectProp(Istanza, Info);
  end;

  if Istanza = nil then
    Exit;

  Info := System.TypInfo.GetPropInfo(Istanza.ClassInfo, Percorso[High(Percorso)]);
  Result := (Info <> nil) and (Info^.SetProc = nil);
end;

procedure TzObjectInspector.ReadOnlyGetContentStyle(Sender: TObject; AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean; ARecordIndex: Integer; var AStyle: TcxStyle);
begin
  if AEditProp = nil then
    Exit;

  if IsReadOnlyPropertyRow(AEditProp.Row) then
    AStyle := FReadOnlyStyle;
end;

{ --- UpdateSplitterPos ------------------------------------- }

procedure TzObjectInspector.UpdateSplitterPos;
const
  INDENT_PX = 16;
  MARGIN_PX = 28;
  MIN_WIDTH = 60;
  MAX_FRACTION = 0.65;
var
  I: Integer;
  Row: TcxCustomRow;
  Parent: TcxCustomRow;
  Level: Integer;
  CaptW: Integer;
  MaxW: Integer;
  NewW: Integer;
begin
  if Rows.Count = 0 then
    Exit;

  Canvas.Font.Assign(Font);
  MaxW := MIN_WIDTH;

  for I := 0 to Rows.Count - 1 do
  begin
    Row := Rows[I];
    if not(Row is TcxPropertyRow) then
      Continue;

    Level := 0;
    Parent := Row.Parent;
    while Parent <> nil do
    begin
      if Parent is TcxPropertyRow then
        Inc(Level);
      Parent := Parent.Parent;
    end;

    CaptW := Canvas.TextWidth(TcxPropertyRow(Row).Properties.Caption) + Level * INDENT_PX + MARGIN_PX;

    if CaptW > MaxW then
      MaxW := CaptW;
  end;

  NewW := MaxW;
  if NewW < MIN_WIDTH then
    NewW := MIN_WIDTH;
  if (Width > 0) and (NewW > Round(Width * MAX_FRACTION)) then
    NewW := Round(Width * MAX_FRACTION);

  OptionsView.RowHeaderWidth := NewW;
end;

{ --- AutoSplitter ------------------------------------------ }

procedure TzObjectInspector.SetAutoSplitter(Value: Boolean);
begin
  if FAutoSplitter = Value then
    Exit;
  FAutoSplitter := Value;
  if FAutoSplitter then
    UpdateSplitterPos;
end;

{ --- Register ---------------------------------------------- }

procedure Register;
begin
  RegisterComponents('zLibrary', [TzObjectInspector]);
end;

end.
