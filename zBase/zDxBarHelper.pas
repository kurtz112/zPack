unit zDxBarHelper;

{
  Helper centralizzato per la manipolazione di TdxBar, TdxBarManager e TdxBarItemLink.
  Utilizzato da zToolActions e zFilterHelper per evitare duplicazioni di codice.

  Responsabilita':
  - Aggiunta e rimozione di item a TdxBar (ItemLink management)
  - Lookup di item per nome su TdxBarManager
  - Enumerazione di item filtrati per prefisso
  - Creazione di TdxBarButton con impostazione glyph/action
  - Creazione di TcxBarEditItem generici e specializzati
  (Combo/ImageCombo, Spin, Date) su TdxBar
  - Utilita' comuni (BeginGroup, Index, PaintStyle, ClearButtons)
}

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.ActnList,
  Vcl.Controls,
  Vcl.ImgList,
  dxBar,
  cxBarEditItem,
  cxImageComboBox,
  cxDropDownEdit,
  cxSpinEdit,
  cxCalendar;

type
  /// <summary>
  /// Classe di utilita' statica per operazioni comuni su TdxBar, TdxBarManager
  /// e TdxBarItemLink. Non istanziabile.
  /// </summary>
  TzDxBarHelper = class
  private
    constructor Create; // non istanziabile

    // ------------------------------------------------------------------
    // Metodo base interno (usato dai Create* specializzati)
    // ------------------------------------------------------------------
    class function InternalCreateEditItem(dxBarToolbar: TdxBar; const Name, Caption, Hint: string; const Position: Integer; const BeginGroup: Boolean): TcxBarEditItem; static;

  public
    // ------------------------------------------------------------------
    // Lookup
    // ------------------------------------------------------------------

    /// <summary>
    /// Restituisce True se esiste un item con il nome indicato nel BarManager
    /// della toolbar indicata.
    /// </summary>
    class function ItemExists(dxBarToolbar: TdxBar; const Name: string): Boolean; static;

    /// <summary>
    /// Restituisce l'item con il nome indicato, o nil se non trovato.
    /// </summary>
    class function FindItem(dxBarManager: TdxBarManager; const Name: string): TdxBarItem; static;

    // ------------------------------------------------------------------
    // Aggiunta ItemLink
    // ------------------------------------------------------------------

    /// <summary>
    /// Aggiunge un TdxBarItem a una TdxBar nella posizione indicata.
    /// Se Position = -1 l'item viene inserito in seconda posizione (index 1).
    /// Restituisce il TdxBarItemLink creato.
    /// </summary>
    class function AddItemLink(dxBarToolbar: TdxBar; Item: TdxBarItem; const Position: Integer; const BeginGroup: Boolean = False): TdxBarItemLink; static;

    /// <summary>
    /// Aggiunge un TdxBarButton a una TdxBar nella posizione indicata.
    /// Restituisce il TdxBarItemLink creato, o nil se dxBarToolbar non assegnato.
    /// </summary>
    class function AddButtonLink(dxBarToolbar: TdxBar; btn: TdxBarButton; const Position: Integer = -1; const BeginGroup: Boolean = False): TdxBarItemLink; static;

    /// <summary>
    /// Aggiunge un TdxBarItem al popup menu.
    /// Se InsertAtBegin = True l'item viene inserito in testa (index 0).
    /// Restituisce il TdxBarItemLink creato, o nil se popup non assegnato.
    /// </summary>
    class function AddPopupLink(popup: TdxBarPopupMenu; Item: TdxBarItem; const InsertAtBegin: Boolean = True): TdxBarItemLink; static;

    // ------------------------------------------------------------------
    // Creazione TdxBarButton
    // ------------------------------------------------------------------

    /// <summary>
    /// Crea un TdxBarButton associato all'owner indicato.
    /// Configura PaintStyle in base a ShowCaption, e ButtonStyle/Down
    /// se Action.AutoCheck = True.
    /// Il glyph viene estratto dall'ImageList se Action.ImageIndex >= 0.
    /// NON aggiunge l'item a nessuna bar: usa AddButtonLink / AddPopupLink.
    /// </summary>
    class function CreateBarButton(AOwner: TComponent; BarManager: TdxBarManager; Action: TCustomAction; ImageList: TCustomImageList; const ShowCaption: Boolean = True): TdxBarButton; static;

    /// <summary>
    /// Libera tutti i TdxBarButton contenuti nella lista e svuota la lista stessa.
    /// </summary>
    class procedure ClearButtons(Buttons: TList<TdxBarButton>); static;

    // ------------------------------------------------------------------
    // Creazione TcxBarEditItem generici e specializzati
    // ------------------------------------------------------------------

    /// <summary>
    /// Crea un TcxBarEditItem base su dxBarToolbar, lo aggiunge nella
    /// posizione indicata con BeginGroup = True e ShowCaption = True.
    /// Il PropertiesClass non e' impostato: rimane TcxTextEditProperties.
    /// Utile come punto di partenza per editor custom.
    /// </summary>
    class function CreateEditItem(dxBarToolbar: TdxBar; const Name, Caption, Hint: string; const Position: Integer = -1; const BeginGroup: Boolean = True): TcxBarEditItem; static;

    /// <summary>
    /// Crea un TcxBarEditItem con PropertiesClass = TcxImageComboBoxProperties.
    /// Configura DropDownListStyle = lsEditFixedList, Sorted = False,
    /// ImmediateDropDown attivi.
    /// Se UseImages = True assegna dx.Immagini come sorgente immagini;
    /// altrimenti riduce la larghezza di 10px (nessuna colonna icona).
    /// </summary>
    class function CreateCombo(dxBarToolbar: TdxBar; const Name, Caption, Hint: string; const Position: Integer = -1; const UseImages: Boolean = False): TcxBarEditItem; static;

    /// <summary>
    /// Crea un TcxBarEditItem con PropertiesClass = TcxSpinEditProperties.
    /// Configura ImmediatePost = True, ClearKey = VK_DELETE,
    /// NullString = 'Tutti', UseNullString = True.
    /// </summary>
    class function CreateSpin(dxBarToolbar: TdxBar; const Name, Caption, Hint: string; const Position: Integer = -1): TcxBarEditItem; static;

    /// <summary>
    /// Crea un TcxBarEditItem con PropertiesClass = TcxDateEditProperties.
    /// Configura ImmediatePost = True, ClearKey = VK_DELETE,
    /// NullString = '', UseNullString = False.
    /// </summary>
    class function CreateDate(dxBarToolbar: TdxBar; const Name, Caption, Hint: string; const Position: Integer = -1): TcxBarEditItem; static;

    // ------------------------------------------------------------------
    // Enumerazione
    // ------------------------------------------------------------------

    /// <summary>
    /// Aggiunge a Dest i Caption di tutti gli item il cui Name inizia
    /// con il prefisso indicato (confronto case-insensitive).
    /// Svuota Dest prima di popolarla.
    /// </summary>
    class procedure EnumItemsByPrefix(dxBarManager: TdxBarManager; const Prefix: string; Dest: TStrings); static;

    /// <summary>
    /// Chiude il gruppo dei filtri: mette BeginGroup sul primo item che segue
    /// l'ultimo filtro della barra.
    ///
    /// PERCHE' SERVE. Una barra con MultiLine attivo manda a capo per gruppi
    /// interi, non per singoli item. Ogni filtro apre un gruppo suo
    /// (InternalCreateEditItem mette BeginGroup = True), mentre le azioni
    /// hanno BeginGroup a False di serie: l'ultimo filtro e TUTTE le azioni
    /// finiscono percio' in un unico gruppo, che o ci sta o va a capo
    /// intero. E' il motivo per cui la riga dei filtri restava a meta' e
    /// l'ultimo filtro scendeva insieme ai pulsanti.
    ///
    /// Aprendo un gruppo sulla prima azione, i filtri restano un gruppo per
    /// conto loro e si dispongono tutti sulla stessa riga.
    ///
    /// Non fa niente se la barra non ha filtri, o se i filtri sono in coda.
    /// Si puo' chiamare quante volte si vuole: scrive solo quando trova
    /// BeginGroup gia' diverso da quello che serve.
    /// </summary>
    class procedure ChiudiGruppoDeiFiltri(dxBarToolbar: TdxBar); static;

    /// <summary>
    /// Aggiunge a Dest i Name di tutti gli item il cui Name inizia
    /// con il prefisso indicato (confronto case-insensitive).
    /// Svuota Dest prima di popolarla.
    /// </summary>
    class procedure EnumItemNamesByPrefix(dxBarManager: TdxBarManager; const Prefix: string; Dest: TStrings); static;

  end;

implementation

uses
  SysUtils,
  System.Math,
  Vcl.Graphics,
  zDX, // per dx.GetBitmap e dx.Immagini
  zSystem;

{ TzDxBarHelper }

constructor TzDxBarHelper.Create;
begin
  // non istanziabile - costruttore privato
end;

// --------------------------------------------------------------------------
// Lookup
// --------------------------------------------------------------------------

class function TzDxBarHelper.ItemExists(dxBarToolbar: TdxBar; const Name: string): Boolean;
begin
  Assert(Assigned(dxBarToolbar));
  Result := Assigned(dxBarToolbar.BarManager.GetItemByName(Name));
end;

class function TzDxBarHelper.FindItem(dxBarManager: TdxBarManager; const Name: string): TdxBarItem;
begin
  Assert(Assigned(dxBarManager));
  Result := dxBarManager.GetItemByName(Name);
end;

// --------------------------------------------------------------------------
// Aggiunta ItemLink
// --------------------------------------------------------------------------

class function TzDxBarHelper.AddItemLink(dxBarToolbar: TdxBar; Item: TdxBarItem; const Position: Integer; const BeginGroup: Boolean = False): TdxBarItemLink;
begin
  Assert(Assigned(dxBarToolbar));
  Assert(Assigned(Item));

  Result := dxBarToolbar.ItemLinks.Add(Item);

  // Vedi InternalCreateEditItem: con Position = -1 l'item resta in coda;
  // forzare Index := 1 su una collection di un solo elemento esplode.
  if Position >= 0 then
    Result.Index := Min(Position, dxBarToolbar.ItemLinks.Count - 1);

  Result.BeginGroup := BeginGroup;
end;

class function TzDxBarHelper.AddButtonLink(dxBarToolbar: TdxBar; btn: TdxBarButton; const Position: Integer = -1; const BeginGroup: Boolean = False): TdxBarItemLink;
begin
  Result := nil;

  if not Assigned(dxBarToolbar) then
    Exit;

  Assert(Assigned(btn));

  Result := dxBarToolbar.ItemLinks.Add(btn);

  if Position <> -1 then
    Result.Index := Position;

  Result.BeginGroup := BeginGroup;
end;

class function TzDxBarHelper.AddPopupLink(popup: TdxBarPopupMenu; Item: TdxBarItem; const InsertAtBegin: Boolean = True): TdxBarItemLink;
begin
  Result := nil;

  if not Assigned(popup) then
    Exit;

  Assert(Assigned(Item));

  Result := popup.ItemLinks.Add;
  Result.Item := Item;

  if InsertAtBegin then
    Result.Index := 0;
end;

// --------------------------------------------------------------------------
// Creazione TdxBarButton
// --------------------------------------------------------------------------

class function TzDxBarHelper.CreateBarButton(AOwner: TComponent; BarManager: TdxBarManager; Action: TCustomAction; ImageList: TCustomImageList; const ShowCaption: Boolean = True): TdxBarButton;
begin
  Assert(Assigned(AOwner));

  Result := TdxBarButton.Create(AOwner);
  Result.BarManager := BarManager;

  if Assigned(Action) then
  begin
    Result.Caption := Action.Caption;

    // Assegnazione Action solo se BarManager e' disponibile (evita AV al caricamento form)
    if Assigned(Result.BarManager) then
      Result.Action := Action;
  end;

  if ShowCaption then
    Result.PaintStyle := psCaptionGlyph
  else
    Result.PaintStyle := psStandard;

  if Assigned(Action) and Action.AutoCheck then
  begin
    Result.ButtonStyle := bsChecked;
    Result.Down := Action.Checked;
  end;

  if Assigned(Action) and (Action.ImageIndex >= 0) and Assigned(ImageList) then
  begin
    dx.GetBitmap(Result.Glyph, ImageList, Action.ImageIndex);
    Result.ImageIndex := -1;
  end;
end;

class procedure TzDxBarHelper.ClearButtons(Buttons: TList<TdxBarButton>);
var
  i: Integer;
  btn: TdxBarButton;
begin
  Assert(Assigned(Buttons));

  for i := Buttons.Count - 1 downto 0 do
  begin
    btn := Buttons[i];
    Buttons.Remove(btn);
    FreeAndNil(btn);
  end;

  Buttons.Clear;
end;

// --------------------------------------------------------------------------
// Metodo base interno per TcxBarEditItem
// --------------------------------------------------------------------------

class function TzDxBarHelper.InternalCreateEditItem(dxBarToolbar: TdxBar; const Name, Caption, Hint: string; const Position: Integer; const BeginGroup: Boolean): TcxBarEditItem;
var
  ItemLink: TdxBarItemLink;
begin
  Assert(Assigned(dxBarToolbar));

  Result := TcxBarEditItem.Create(dxBarToolbar.BarManager);
  Result.Name := Name;
  Result.Caption := Caption;
  Result.Hint := Hint;
  Result.ShowCaption := True;

  ItemLink := dxBarToolbar.ItemLinks.Add(Result);

  // Position = -1 significa "in coda": l'item è già stato aggiunto in ultima
  // posizione da Add, quindi non si tocca l'Index. Forzare Index := 1 su una
  // collection con un solo elemento (l'unico indice valido è 0) provoca
  // "index out of bounds" in TCollectionItem.SetIndex / InternalMove.
  if Position >= 0 then
    ItemLink.Index := Min(Position, dxBarToolbar.ItemLinks.Count - 1);

  ItemLink.BeginGroup := BeginGroup;
end;

// --------------------------------------------------------------------------
// Creazione TcxBarEditItem specializzati
// --------------------------------------------------------------------------

class function TzDxBarHelper.CreateEditItem(dxBarToolbar: TdxBar; const Name,
    Caption, Hint: string; const Position: Integer = -1; const BeginGroup:
    Boolean = True): TcxBarEditItem;
begin
  Result := InternalCreateEditItem(dxBarToolbar, Name, Caption, Hint, Position, BeginGroup);
  // PropertiesClass non impostato: resta TcxTextEditProperties
end;

class function TzDxBarHelper.CreateCombo(dxBarToolbar: TdxBar; const Name,
    Caption, Hint: string; const Position: Integer = -1; const UseImages:
    Boolean = False): TcxBarEditItem;
var
  Props: TcxImageComboBoxProperties;
begin
  Result := InternalCreateEditItem(dxBarToolbar, Name, Caption, Hint, Position, True);

  Result.PropertiesClass := TcxImageComboBoxProperties;
  Props := Result.Properties as TcxImageComboBoxProperties;

  Props.DropDownListStyle := lsEditFixedList;
  Props.Sorted := False;
  Props.ImmediateDropDownWhenActivated := True;
  Props.ImmediateDropDownWhenKeyPressed := True;

  if UseImages then
    Props.Images := dx.Immagini
  else
    Result.Width := Result.Width - 10; // nessuna colonna icona: riduce la larghezza
end;

class function TzDxBarHelper.CreateSpin(dxBarToolbar: TdxBar; const Name,
    Caption, Hint: string; const Position: Integer = -1): TcxBarEditItem;
var
  Props: TcxSpinEditProperties;
begin
  Result := InternalCreateEditItem(dxBarToolbar, Name, Caption, Hint, Position, True);

  Result.PropertiesClass := TcxSpinEditProperties;
  Props := Result.Properties as TcxSpinEditProperties;

  Props.ImmediatePost := True;
  Props.ClearKey := 46; // VK_DELETE
  Props.Nullstring := 'Tutti';
  Props.UseNullString := True;
end;

class function TzDxBarHelper.CreateDate(dxBarToolbar: TdxBar; const Name,
    Caption, Hint: string; const Position: Integer = -1): TcxBarEditItem;
var
  Props: TcxDateEditProperties;
begin
  Result := InternalCreateEditItem(dxBarToolbar, Name, Caption, Hint, Position, True);

  Result.PropertiesClass := TcxDateEditProperties;
  Props := Result.Properties as TcxDateEditProperties;

  Props.ImmediatePost := True;
  Props.ClearKey := 46; // VK_DELETE
  Props.Nullstring := '';
  Props.UseNullString := False;
end;

// --------------------------------------------------------------------------
// Enumerazione
// --------------------------------------------------------------------------

class procedure TzDxBarHelper.ChiudiGruppoDeiFiltri(dxBarToolbar: TdxBar);
var
  Indice: Integer;
  UltimoFiltro: Integer;
begin
  if not Assigned(dxBarToolbar) then
    Exit;

  // Un filtro e' un item di modifica: combo, data, numero. I pulsanti delle
  // azioni non lo sono, ed e' l'unico modo per distinguerli senza sapere
  // niente del meccanismo dei filtri, che qui dentro non si conosce.
  UltimoFiltro := -1;
  for Indice := 0 to dxBarToolbar.ItemLinks.Count - 1 do
    if dxBarToolbar.ItemLinks[Indice].Item is TcxBarEditItem then
      UltimoFiltro := Indice;

  if (UltimoFiltro < 0) or (UltimoFiltro = dxBarToolbar.ItemLinks.Count - 1) then
    Exit;

  if not dxBarToolbar.ItemLinks[UltimoFiltro + 1].BeginGroup then
    dxBarToolbar.ItemLinks[UltimoFiltro + 1].BeginGroup := True;
end;

class procedure TzDxBarHelper.EnumItemsByPrefix(dxBarManager: TdxBarManager; const Prefix: string; Dest: TStrings);
var
  i: Integer;
  s: String;
begin
  Assert(Assigned(dxBarManager));
  Assert(Assigned(Dest));

  Dest.Clear;

  for i := 0 to dxBarManager.ItemCount - 1 do
  begin
    s := dxBarManager.Items[i].Name;
    if s.ToUpper.StartsWith(Prefix.ToUpper) then
      Dest.Add(dxBarManager.Items[i].Caption);
  end;
end;

class procedure TzDxBarHelper.EnumItemNamesByPrefix(dxBarManager: TdxBarManager; const Prefix: string; Dest: TStrings);
var
  i: Integer;
  s: string;
begin
  Assert(Assigned(dxBarManager));
  Assert(Assigned(Dest));

  Dest.Clear;

  for i := 0 to dxBarManager.ItemCount - 1 do
  begin
    s := dxBarManager.Items[i].Name;
    if s.ToUpper.StartsWith(Prefix.ToUpper) then
      Dest.Add(dxBarManager.Items[i].Name);
  end;
end;

end.
