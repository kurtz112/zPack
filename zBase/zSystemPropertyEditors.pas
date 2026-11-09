unit zSystemPropertyEditors;

{
  Migrazione da TzPropEditor / TzClassPropEditor (zObjectInspector)
  a TcxPropertyEditor (cxOI / DevExpress ExpressVerticalGrid).

  ═══════════════════════════════════════════════════════════════════════════
  MAPPA CONCETTUALE VECCHIO → NUOVO
  ═══════════════════════════════════════════════════════════════════════════

  TzPropAttr           → TcxPropertyAttribute
  ─────────────────────────────────────────────────────────────────
  zpaDialog            → ipaDialog
  zpaReadOnly          → ipaReadOnly
  zpaMultiSelect       → ipaMultiSelect
  zpaSubProperties     → ipaSubProperties
  zpaValueList         → ipaValueList
  zpaSortList          → ipaSortList
  zpaAutoUpdate        → ipaAutoUpdate
  ─────────────────────────────────────────────────────────────────
  (zpaComponentRef e zpaVolatileSubProperties non hanno equivalente
  diretto in TcxPropertyAttributes: ignorati o gestiti internamente
  da DevExpress.)

  TzClassPropEditor    → TcxPropertyEditor     (classe base generica)
  oppure sotto-classi già disponibili in cxOI:
  TcxClassProperty, TcxComponentProperty, …

  GetOrdValue(I)       → GetOrdValueAt(I)
  SetOrdValue(V)       → SetOrdValue(V)        [stessa firma]
  GetAttrs             → GetAttributes         [rinominato]
  Modified             → PostChangedNotification  [o lasciare vuoto:
  il framework lo chiama automaticamente
  dopo SetValue / SetOrdValue]

  PropCount            → PropCount             [invariato]
  GetValue / SetValue  → GetValue / SetValue   [invariati]

  zRegisterClassEditor → cxRegisterPropertyEditor  (registrazione globale
  nell'initialization, per tipo/classe/nome proprietà)

  ═══════════════════════════════════════════════════════════════════════════
  NOTE DI COMPATIBILITÀ
  ═══════════════════════════════════════════════════════════════════════════

  1.  TcxPropertyEditor.GetOrdValue non accetta indice (restituisce il valore
  del primo istanza). Per accedere agli N oggetti multi-select si usa
  GetOrdValueAt(Index: Integer) che mappa su FPropList[Index].

  2.  Modified() nel vecchio codice chiamava FOnModified: nel nuovo il
  framework notifica automaticamente al termine di SetOrdValue/SetValue.
  Le chiamate a Modified() residue possono essere rimosse o sostituite
  con PostChangedNotification.

  3.  La logica "class-based dispatch" di GetClassEditor / GetClassIndex
  (che era in Frame_ObjectInspector) è sostituita dalla registrazione
  globale nell'initialization di questa unit tramite cxRegisterPropertyEditor.
  Non serve più il parametro AEditorClass in nessun evento del Frame.

  4.  inherited Edit in TzClassPropEditor espandeva le sub-proprietà.
  In TcxPropertyEditor "inherited Edit" non fa nulla di utile (base class
  ha Edit vuoto): si può togliere oppure lasciare per sicurezza.

  5.  TStrings: DevExpress registra già TcxStringsProperty di default.
  L'editor TzStringListEditor originale (basato su InputMemo) può essere
  portato come TcxStringsPropertyCustom (vedi sezione separata) se si
  vuole mantenere il comportamento InputMemo.
}

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Classes,
  Vcl.Dialogs,
  dxCore,
  dxShellDialogs,
  cxEdit,
  cxTextEdit,
  cxOI,
  zSystem;

type

  { ── Editor "CollectionItem" (ex TzCollectionItemPropertyEditor) ──────── }

  TzCollectionItemPropertyEditor = class(TcxPropertyEditor)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    function GetValue: string; override;
  end;

  { ── Editor con dialog di selezione lookup ─────────────────────────────── }

  TzLookupPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzDataSetPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzDbViewPropPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzGeneratorsPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzFieldPropsPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzDbCardsPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzDbViewsPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  TzPickListPropertyEditor = class(TzCollectionItemPropertyEditor)
  public
    procedure Edit; override;
  end;

  { ── Editor collection custom (ex TzCustomCollectionPropertyEditor) ──────── }

  TzCustomCollectionPropertyEditor = class(TcxPropertyEditor)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

  { ── Editor PickValues (ex TzPickValuesPropertyEditor) ───────────────────── }

  TzPickValuesPropertyEditor = class(TcxPropertyEditor)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

  // ── Editor per una proprieta' stringa che contiene un percorso di file ────
  // La riga resta scrivibile a mano; il bottone apre il dialogo di apertura
  // DevExpress (TdxOpenFileDialog, con lo skin dell'applicazione) e il file
  // scelto finisce nella proprieta'. Le classi derivate fissano filtro e titolo.

  TzFileNamePropertyEditor = class(TcxStringProperty)
  protected
    function DialogFilter: string; virtual;
    function DialogTitle: string; virtual;
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure Edit; override;
  end;

  // TzConnection.ClientLibrary
  TzClientLibraryPropertyEditor = class(TzFileNamePropertyEditor)
  protected
    function DialogFilter: string; override;
    function DialogTitle: string; override;
  end;

  // TzConnection.DataBase
  TzDatabaseFilePropertyEditor = class(TzFileNamePropertyEditor)
  protected
    function DialogFilter: string; override;
    function DialogTitle: string; override;
  end;

  // ── Editor per una password ─────────────────────────────────────────────
  // La riga mostra asterischi, sia nella visualizzazione sia in modifica; il
  // bottone di rivelazione e' quello di serie di TcxTextEdit (lo stesso della
  // form di accesso), che mostra il testo finche' resta premuto.

  TzPasswordPropertyEditor = class(TcxStringProperty)
  protected
    procedure AdjustInnerEditProperties(AProperties: TcxCustomEditProperties); override;
  end;

  // ── Editor per TzControlProps.ImageName ─────────────────────────────────
  // La riga resta scrivibile a mano; il bottone apre la scelta dell'icona
  // dal catalogo dx.Immagini, con la ricerca per nome e le icone a 24 px.

  TzImageNamePropertyEditor = class(TcxStringProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure Edit; override;
  end;

procedure SetGlobalzSystem(zSystem: TzSystem);
procedure InitPropertyEditors;

implementation

uses
  Winapi.Windows,
  System.UITypes,
  System.Math,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  cxGraphics,
  cxLabel,
  cxButtons,
  cxListView,
  zDX,
  zCollection,
  frmLookupCollectionItem,
  Frame_ObjectInspector, {per compatibilità; può essere rimosso se non serve}
  zFormEditor_ComboItems,
  zFrmCollection;

var
  Global_zSystem: TzSystem;

  { ═══════════════════════════════════════════════════════════════════════════
    TzCollectionItemPropertyEditor
    ═══════════════════════════════════════════════════════════════════════════ }

function TzCollectionItemPropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  { ex: [zpaMultiSelect, zpaSubProperties, zpaDialog, zpaReadOnly] }
  Result := [ipaMultiSelect, ipaSubProperties, ipaDialog, ipaReadOnly];
end;

function TzCollectionItemPropertyEditor.GetValue: string;
var
  Item: TzCollectionItem;
begin
  Result := '';
  { GetOrdValueAt(0) → ex GetOrdValue(0) }
  Item := TzCollectionItem(GetOrdValueAt(0));
  if Assigned(Item) then
    Result := Item.Name;
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TzLookupPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzLookupPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  { "inherited Edit" nella classe base TcxPropertyEditor non fa nulla:
    rimosso per pulizia. }
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zLookups, Item) then
  begin
    SetOrdValue(TdxNativeInt(Item));
    { PostChangedNotification è chiamata automaticamente dal framework
      dopo SetOrdValue; non serve Modified esplicito. }
  end;
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TzDataSetPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzDataSetPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zDataSets, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxGeneratorsPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzGeneratorsPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zGenerators, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxFieldPropsPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzFieldPropsPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zDataDictionary, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TzDbViewPropPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzDbViewPropPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zDbViews, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxDbCardsPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzDbCardsPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zDbCards, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxDbViewsPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzDbViewsPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzLookup(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zDbViews, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxPickListPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzPickListPropertyEditor.Edit;
var
  Item: TzCollectionItem;
begin
  Item := TzPickList(GetOrdValueAt(0));
  if zExecuteLookupCollectionItem(Global_zSystem.zPickLists, Item) then
    SetOrdValue(TdxNativeInt(Item));
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxPickValuesPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

function TzPickValuesPropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  { ex: [zpaMultiSelect, zpaSubProperties, zpaDialog, zpaReadOnly] }
  Result := [ipaMultiSelect, ipaSubProperties, ipaDialog, ipaReadOnly];
end;

function TzPickValuesPropertyEditor.GetValue: string;
var
  Item: TzPickValues;
begin
  Result := '';
  Item := TzPickValues(GetOrdValueAt(0));
  if Assigned(Item) then
    Result := IntToStr(Item.Count) + ' items';
end;

procedure TzPickValuesPropertyEditor.Edit;
var
  Description: string;
  TempItems: TzPickValues;
  I: Integer;
begin
  Description := TzPickValues(GetOrdValueAt(0)).GetPickListDescription;

  TempItems := TzPickValues.Create(TzPickValue, 'PickValues', -1, nil);
  try
    TempItems.Sorted := False;
    TempItems.Assign(TzPickValues(GetOrdValueAt(0)));
    if EditComboItems(Global_zSystem, Description, TempItems) then
    begin
      for I := 0 to PropCount - 1 do
        TzPickValues(GetOrdValueAt(I)).Assign(TempItems);
      PostChangedNotification;
    end;
  finally
    FreeAndNil(TempItems);
  end;
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TcxCustomCollectionPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

function TzCustomCollectionPropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  { ex: [zpaMultiSelect, zpaDialog] }
  Result := [ipaMultiSelect, ipaDialog];
end;

function TzCustomCollectionPropertyEditor.GetValue: string;
var
  Collection: TzCustomCollection;
begin
  Result := inherited GetValue;
  Collection := TzCustomCollection(GetOrdValueAt(0));
  if Assigned(Collection) then
    Result := Collection.Count.ToString + ' items - ' + Result;
end;

procedure TzCustomCollectionPropertyEditor.Edit;
var
  Collection: TzCustomCollection;
begin
  Collection := TzCustomCollection(GetOrdValueAt(0));
  if Edit_zCollections([Collection]) then
    PostChangedNotification;
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TzFileNamePropertyEditor e derivati
  ═══════════════════════════════════════════════════════════════════════════ }

function TzFileNamePropertyEditor.DialogFilter: string;
begin
  Result := 'Tutti i file (*.*)|*.*';
end;

function TzFileNamePropertyEditor.DialogTitle: string;
begin
  Result := GetName;
end;

function TzFileNamePropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  // ipaDialog fa comparire il bottone sulla riga; il resto (multiselezione,
  // ripristino) e' quello di una stringa qualunque.
  Result := inherited GetAttributes + [ipaDialog];
end;

procedure TzFileNamePropertyEditor.Edit;
var
  Dialog: TdxOpenFileDialog;
  ValoreAttuale: string;
begin
  Dialog := TdxOpenFileDialog.Create(nil);
  try
    Dialog.Title := DialogTitle;
    Dialog.Filter := DialogFilter;
    Dialog.Options := Dialog.Options + [ofFileMustExist, ofPathMustExist];

    // Parte dalla cartella del valore corrente, se ne ha una: per
    // ClientLibrary il predefinito 'fbclient.dll' non ha percorso e il
    // dialogo si apre dove capita.
    ValoreAttuale := GetStrValue;
    if not ValoreAttuale.IsEmpty then
    begin
      Dialog.InitialDir := ExtractFilePath(ValoreAttuale);
      Dialog.FileName := ExtractFileName(ValoreAttuale);
    end;

    if Dialog.Execute then
      SetValue(Dialog.FileName); // scrive su tutte le istanze selezionate
  finally
    Dialog.Free;
  end;
end;

function TzClientLibraryPropertyEditor.DialogFilter: string;
begin
  Result := 'Libreria client Firebird (fbclient.dll)|fbclient.dll|Librerie (*.dll)|*.dll|Tutti i file (*.*)|*.*';
end;

function TzClientLibraryPropertyEditor.DialogTitle: string;
begin
  Result := 'Libreria client Firebird';
end;

function TzDatabaseFilePropertyEditor.DialogFilter: string;
begin
  Result := 'Database Firebird (*.fdb;*.gdb)|*.fdb;*.gdb|Tutti i file (*.*)|*.*';
end;

function TzDatabaseFilePropertyEditor.DialogTitle: string;
begin
  Result := 'Database';
end;

{ ═══════════════════════════════════════════════════════════════════════════
  TzPasswordPropertyEditor
  ═══════════════════════════════════════════════════════════════════════════ }

procedure TzPasswordPropertyEditor.AdjustInnerEditProperties(AProperties: TcxCustomEditProperties);
begin
  inherited AdjustInnerEditProperties(AProperties);

  // cxOI chiama questo metodo sulle proprieta' dell'editor della riga, sia
  // per il disegno del valore sia per la modifica: l'EchoMode maschera
  // entrambi.
  if AProperties is TcxCustomTextEditProperties then
  begin
    TcxCustomTextEditProperties(AProperties).EchoMode := eemPassword;
    TcxCustomTextEditProperties(AProperties).PasswordChar := '*';
    TcxCustomTextEditProperties(AProperties).ShowPasswordRevealButton := True;
  end;
end;

// ═══════════════════════════════════════════════════════════════════════════
// Scelta dell'icona (TzImageNamePropertyEditor)
// ═══════════════════════════════════════════════════════════════════════════

const
  LATO_ICONA_RICERCA = 24; // px a 96 dpi delle icone del dialogo

type
  // Dialogo senza DFM (CreateNew): il catalogo ha oltre mille icone, quindi
  // si cerca per parole nel nome mentre si scrive; ogni parola deve comparire
  // nel nome, con '_' e '-' trattati come spazi ('home cust' trova
  // 'home__customers'). Invio o doppio clic scelgono, Esc annulla,
  // "Nessuna icona" svuota la proprieta'.
  TzFormSceltaIcona = class(TForm)
  private
    Ricerca: TcxTextEdit;
    Elenco: TcxListView;
    Conteggio: TcxLabel;
    PannelloPulsanti: TPanel;
    PulsanteNessunaIcona: TcxButton;
    PulsanteConferma: TcxButton;
    PulsanteAnnulla: TcxButton;
    TimerRicerca: TTimer;
    Nomi: TArray<string>;
    NomeIniziale: string;
    NomeScelto: string;
    procedure CreaControlli;
    procedure Filtra;
    function CorrispondeAllaRicerca(const Nome: string; const Parole: TArray<string>): boolean;
    procedure RicercaPropertiesChange(Sender: TObject);
    procedure RicercaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerRicercaTimer(Sender: TObject);
    procedure PulsanteConfermaClick(Sender: TObject);
    procedure PulsanteNessunaIconaClick(Sender: TObject);
  public
    constructor CreaDialogo(const NomeAttuale: string);
    // True se l'utente ha confermato; Nome = icona scelta, '' = nessuna icona
    class function Scegli(var Nome: string): boolean;
  end;

var
  // Copia a 24 px del catalogo, creata alla prima apertura e tenuta: ricopiare
  // e ridisegnare oltre mille SVG a ogni apertura renderebbe lento il dialogo.
  // Si rifa' se il catalogo cambia numero di icone o se cambia il DPI.
  ImmaginiRicerca: TcxImageList = nil;

function ImmaginiPerLaRicerca: TcxImageList;
var
  Lato: integer;
begin
  Lato := MulDiv(LATO_ICONA_RICERCA, Screen.PixelsPerInch, 96);
  if Assigned(ImmaginiRicerca) and ((ImmaginiRicerca.Count <> dx.Immagini.Count) or (ImmaginiRicerca.Width <> Lato)) then
    FreeAndNil(ImmaginiRicerca);

  if not Assigned(ImmaginiRicerca) then
  begin
    ImmaginiRicerca := TcxImageList.Create(nil);
    ImmaginiRicerca.Width := Lato;
    ImmaginiRicerca.Height := Lato;
    ImmaginiRicerca.CopyImages(dx.Immagini);
  end;
  result := ImmaginiRicerca;
end;

constructor TzFormSceltaIcona.CreaDialogo(const NomeAttuale: string);
var
  Posizione: integer;
begin
  inherited CreateNew(nil);
  NomeIniziale := NomeAttuale;
  NomeScelto := NomeAttuale;

  SetLength(Nomi, dx.Immagini.Count);
  for Posizione := 0 to dx.Immagini.Count - 1 do
    Nomi[Posizione] := ChangeFileExt(dx.Immagini.GetSourceFileName(Posizione), '');

  CreaControlli;
  Filtra;
end;

procedure TzFormSceltaIcona.CreaControlli;
var
  PannelloRicerca: TPanel;
begin
  Caption := 'Scegli l''icona';
  BorderStyle := bsSizeable;
  BorderIcons := [biSystemMenu];
  Position := poMainFormCenter;
  ClientWidth := MulDiv(760, Screen.PixelsPerInch, 96);
  ClientHeight := MulDiv(540, Screen.PixelsPerInch, 96);

  PannelloRicerca := TPanel.Create(Self);
  PannelloRicerca.Parent := Self;
  PannelloRicerca.Align := alTop;
  PannelloRicerca.BevelOuter := bvNone;
  PannelloRicerca.ParentBackground := true;
  PannelloRicerca.Height := MulDiv(40, Screen.PixelsPerInch, 96);
  PannelloRicerca.Padding.SetBounds(8, 8, 8, 4);

  Conteggio := TcxLabel.Create(Self);
  Conteggio.Parent := PannelloRicerca;
  Conteggio.Align := alRight;
  Conteggio.Properties.Alignment.Vert := taVCenter;
  Conteggio.AutoSize := false;
  Conteggio.Width := MulDiv(130, Screen.PixelsPerInch, 96);
  Conteggio.Transparent := true;

  Ricerca := TcxTextEdit.Create(Self);
  Ricerca.Parent := PannelloRicerca;
  Ricerca.Align := alClient;
  Ricerca.Properties.OnChange := RicercaPropertiesChange;
  Ricerca.OnKeyDown := RicercaKeyDown;
  Ricerca.TextHint := 'Cerca per nome (es. home, factory, user add)';

  PannelloPulsanti := TPanel.Create(Self);
  PannelloPulsanti.Parent := Self;
  PannelloPulsanti.Align := alBottom;
  PannelloPulsanti.BevelOuter := bvNone;
  PannelloPulsanti.ParentBackground := true;
  PannelloPulsanti.Height := MulDiv(44, Screen.PixelsPerInch, 96);
  PannelloPulsanti.Padding.SetBounds(8, 6, 8, 8);

  PulsanteAnnulla := TcxButton.Create(Self);
  PulsanteAnnulla.Parent := PannelloPulsanti;
  PulsanteAnnulla.Align := alRight;
  PulsanteAnnulla.Caption := 'Annulla';
  PulsanteAnnulla.Cancel := true;
  PulsanteAnnulla.ModalResult := mrCancel;

  PulsanteConferma := TcxButton.Create(Self);
  PulsanteConferma.Parent := PannelloPulsanti;
  PulsanteConferma.Align := alRight;
  PulsanteConferma.AlignWithMargins := true;
  PulsanteConferma.Margins.SetBounds(0, 0, 6, 0);
  PulsanteConferma.Caption := 'Scegli';
  PulsanteConferma.Default := true;
  PulsanteConferma.OnClick := PulsanteConfermaClick;

  PulsanteNessunaIcona := TcxButton.Create(Self);
  PulsanteNessunaIcona.Parent := PannelloPulsanti;
  PulsanteNessunaIcona.Align := alLeft;
  PulsanteNessunaIcona.Width := MulDiv(110, Screen.PixelsPerInch, 96);
  PulsanteNessunaIcona.Caption := 'Nessuna icona';
  PulsanteNessunaIcona.OnClick := PulsanteNessunaIconaClick;

  Elenco := TcxListView.Create(Self);
  Elenco.Parent := Self;
  Elenco.Align := alClient;
  Elenco.AlignWithMargins := true;
  Elenco.Margins.SetBounds(8, 0, 8, 0);
  Elenco.ViewStyle := vsIcon;
  Elenco.ReadOnly := true;
  Elenco.HideSelection := false;
  Elenco.MultiSelect := false;
  Elenco.LargeImages := ImmaginiPerLaRicerca;
  Elenco.OnDblClick := PulsanteConfermaClick;

  // Pausa breve dopo l'ultimo tasto: con mille voci rifare l'elenco a ogni
  // carattere rallenta la scrittura.
  TimerRicerca := TTimer.Create(Self);
  TimerRicerca.Enabled := false;
  TimerRicerca.Interval := 150;
  TimerRicerca.OnTimer := TimerRicercaTimer;

  ActiveControl := Ricerca;
end;

function TzFormSceltaIcona.CorrispondeAllaRicerca(const Nome: string; const Parole: TArray<string>): boolean;
var
  NomeNormalizzato: string;
  Parola: string;
begin
  NomeNormalizzato := Nome.ToLower.Replace('_', ' ').Replace('-', ' ');
  for Parola in Parole do
    if not NomeNormalizzato.Contains(Parola) then
      Exit(false);
  result := true;
end;

procedure TzFormSceltaIcona.Filtra;
var
  Parole: TArray<string>;
  Posizione: integer;
  Voce, VoceIniziale: TListItem;
begin
  Parole := string(Ricerca.Text).Trim.ToLower.Replace('_', ' ').Replace('-', ' ').Split([' '], TStringSplitOptions.ExcludeEmpty);
  VoceIniziale := nil;

  Elenco.Items.BeginUpdate;
  try
    Elenco.Items.Clear;
    for Posizione := 0 to High(Nomi) do
      if CorrispondeAllaRicerca(Nomi[Posizione], Parole) then
      begin
        Voce := Elenco.Items.Add;
        Voce.Caption := Nomi[Posizione];
        Voce.ImageIndex := Posizione; // stessa posizione nel catalogo e nella copia a 24 px
        if SameText(Nomi[Posizione], NomeIniziale) then
          VoceIniziale := Voce;
      end;
  finally
    Elenco.Items.EndUpdate;
  end;

  // Selezione: l'icona attuale se e' fra i risultati, altrimenti la prima,
  // cosi' Invio sceglie subito quando la ricerca ne lascia una sola.
  if Assigned(VoceIniziale) then
    Elenco.Selected := VoceIniziale
  else if Elenco.Items.Count > 0 then
    Elenco.Selected := Elenco.Items[0];
  if Assigned(Elenco.Selected) then
    Elenco.Selected.MakeVisible(false);

  Conteggio.Caption := Format('%d di %d icone', [Elenco.Items.Count, Length(Nomi)]);
end;

procedure TzFormSceltaIcona.RicercaPropertiesChange(Sender: TObject);
begin
  TimerRicerca.Enabled := false;
  TimerRicerca.Enabled := true;
end;

procedure TzFormSceltaIcona.TimerRicercaTimer(Sender: TObject);
begin
  TimerRicerca.Enabled := false;
  Filtra;
end;

procedure TzFormSceltaIcona.RicercaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Freccia giu': dalla ricerca all'elenco, per muoversi fra i risultati
  if Key = VK_DOWN then
  begin
    if TimerRicerca.Enabled then
      TimerRicercaTimer(TimerRicerca);
    Elenco.SetFocus;
    Key := 0;
  end;
end;

procedure TzFormSceltaIcona.PulsanteConfermaClick(Sender: TObject);
begin
  // Invio subito dopo l'ultimo tasto: la ricerca in sospeso va applicata,
  // altrimenti si sceglierebbe dai risultati di prima.
  if TimerRicerca.Enabled then
    TimerRicercaTimer(TimerRicerca);

  if not Assigned(Elenco.Selected) then
    Exit;
  NomeScelto := Elenco.Selected.Caption;
  ModalResult := mrOk;
end;

procedure TzFormSceltaIcona.PulsanteNessunaIconaClick(Sender: TObject);
begin
  NomeScelto := '';
  ModalResult := mrOk;
end;

class function TzFormSceltaIcona.Scegli(var Nome: string): boolean;
var
  Dialogo: TzFormSceltaIcona;
begin
  Dialogo := TzFormSceltaIcona.CreaDialogo(Nome);
  try
    result := Dialogo.ShowModal = mrOk;
    if result then
      Nome := Dialogo.NomeScelto;
  finally
    Dialogo.Free;
  end;
end;

function TzImageNamePropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  result := inherited GetAttributes + [ipaDialog];
end;

procedure TzImageNamePropertyEditor.Edit;
var
  Nome: string;
begin
  Nome := GetStrValue;
  if TzFormSceltaIcona.Scegli(Nome) then
    SetValue(Nome); // scrive su tutte le istanze selezionate
end;

{ ═══════════════════════════════════════════════════════════════════════════
  Utilities
  ═══════════════════════════════════════════════════════════════════════════ }

procedure SetGlobalzSystem(zSystem: TzSystem);
begin
  Global_zSystem := zSystem;
end;

procedure InitPropertyEditors;
begin
  { Sostituisce zRegisterClassEditor con cxRegisterPropertyEditor (cxOI).
    La registrazione è per tipo RTTI: il parametro AObjectClass = nil significa
    "qualsiasi oggetto che abbia una proprietà di quel tipo".
    Il parametro APropName = '' significa "qualsiasi nome di proprietà". }

  cxRegisterPropertyEditor(TypeInfo(TzDomain), nil, '', TzFieldPropsPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzLookup), nil, '', TzLookupPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzDataSet), nil, '', TzDataSetPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzDbViewProps), nil, '', TzDbViewPropPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzGenerator), nil, '', TzGeneratorsPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzDbCardProps), nil, '', TzDbCardsPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzPickList), nil, '', TzPickListPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzPickValues), nil, '', TzPickValuesPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(TzCustomCollection), nil, '', TzCustomCollectionPropertyEditor);

  // Registrazione per classe e nome di proprieta': solo queste due stringhe
  // di TzConnection ricevono il bottone che apre il dialogo di apertura.
  cxRegisterPropertyEditor(TypeInfo(string), TzConnection, 'ClientLibrary', TzClientLibraryPropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(string), TzConnection, 'DataBase', TzDatabaseFilePropertyEditor);
  cxRegisterPropertyEditor(TypeInfo(string), TzConnection, 'dbPassword', TzPasswordPropertyEditor);

  // Icona dei controlli delle schede: scelta dal catalogo dx.Immagini
  cxRegisterPropertyEditor(TypeInfo(string), TzControlProps, 'ImageName', TzImageNamePropertyEditor);

  { NOTA: nel vecchio codice TzDbViewsPropertyEditor e TzDbViewPropPropertyEditor
    erano registrati entrambi per TzDbViewProps, con TzDbViewsPropertyEditor
    come seconda registrazione che sovrascriveva la prima.
    Qui è mantenuto solo TzDbViewPropPropertyEditor (coerente con l'intenzione).
    Se occorre TcxDbViewsPropertyEditor separato, registrarlo con un TypeInfo
    distinto o un nome di proprietà specifico. }
end;

initialization

Global_zSystem := nil;

finalization

FreeAndNil(ImmaginiRicerca);

end.
