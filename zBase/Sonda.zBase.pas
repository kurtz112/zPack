// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.zBase
//
// I comandi della sonda di collaudo (zPack\zLibs\Sonda.*) sui componenti di
// zBase, che la sonda da sola non conosce: la registra il ponte
// dell'applicazione (Gesty.Sonda) con RegistraComandiSondaZBase, prima di
// AvviaSonda. Senza la direttiva SONDA nessuno la usa e non entra
// nell'eseguibile.
//
//   - filtro: legge, aggiunge o toglie le condizioni del filtro di una vista
//     (TzDbView). Scrive come il "Filtro per valore" (F3): stesso metodo
//     (AddFilterCondition), stesse regole sul testo (maiuscolo, "inizia per",
//     asterisco in fondo per "contiene") quando l'operatore non e' indicato.
//     Il generatore dei filtri (F4) disegna le condizioni dentro un controllo
//     unico che la sonda non sa compilare: questo comando ne prende il posto.
//     La vista riapre il dataset con un messaggio differito, quindi il
//     risultato (testo del filtro, record) arriva nel campo "dopo".
//   - colonna: la colonna attiva della vista, quella su cui lavora F3; senza
//     campo elenca le colonne visibili.
//   - skin: senza nome elenca le skin e dice quella in uso; con il nome la
//     applica dal selettore del ribbon della form principale (SetSkin, lo
//     stesso percorso del clic, con il salvataggio nella configurazione), o
//     da zDX se il programma non ha il selettore.
//   - menu contestuale delle griglie: il comando menu_contestuale del nucleo
//     (Sonda.Ispezione) chiede qui quale menu comparirebbe col clic destro.
//     TcxGridPopupMenu lo sceglie dalla zona della griglia colpita
//     (intestazione, riga, pannello del raggruppamento): la sonda rifa' il
//     suo DoPopup, ma col punto del clic invece del cursore vero, e senza
//     aprire il menu. Le voci dei TdxBarPopupMenu (popGrid delle viste) sono
//     le voci della barra dei loro ItemLinks.
//   - scheda: attiva una scheda per didascalia o nome, o elenca le schede di
//     un controllo a schede. Tre tipi: i gruppi a schede del layout
//     (TdxLayoutGroup con LayoutDirection = ldTabbed, come Contabilita' in
//     Intestatari di WT, che non e' un controllo e non ha una finestra),
//     TcxPageControl e TPageControl della VCL. Il cambio passa da dove passa
//     il clic dell'utente sulla linguetta: TabIndex delle proprieta' delle
//     schede DevExpress (CanChange, quindi OnTabChanging e OnPageChanging,
//     poi OnTabChanged), CanChange e Change di TPageControl. Con l'indirizzo
//     di una form o di un frame la sonda cerca la scheda in tutti i
//     controlli a schede che possiede, e preferisce quelli che si vedono.
//   - cella: clic su una cella di griglia per riga e colonna. La sonda porta
//     in vista riga e colonna, calcola il rettangolo della cella dal ViewInfo
//     e clicca li' con il clic del nucleo, che va alla finestra giusta. Le
//     celle-collegamento (Id Documento, Id Doc Storno) aprono il collegamento
//     come col mouse: con un clic se la colonna e' modificabile (l'editor
//     TcxHyperLinkEdit della cella, che si apre solo se il rilascio cade sul
//     testo: senza x il punto sta sul testo, a destra per le colonne allineate
//     a destra), col doppio clic della vista se non lo e' (le viste in sola
//     lettura), e la sonda lo fa da se'.
//   - clic su una scheda o su una colonna (ClicSpecialeSonda del nucleo):
//     app_clic su un gruppo del layout, un TcxTabSheet o un TTabSheet senza
//     coordinate attiva la scheda; su una colonna clicca la cella della riga
//     attiva.
//
// Analisi: D:\AI\Analisi\COLLAUDO,
// D:\AI\OUT\20261027-sonda-filtri-barra-skin\,
// D:\AI\OUT\20261027-sonda-menu-contestuale-e-modificatori\ e
// D:\AI\OUT\20261103-sonda-schede-celle-dataset\.
//
// ***************************************************************************

unit Sonda.zBase;

interface

// Registra filtro, colonna, skin, scheda e cella fra i comandi della sonda, il
// risolutore del menu contestuale delle griglie DevExpress e il clic su
// schede e colonne.
procedure RegistraComandiSondaZBase;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.Variants,
  System.TypInfo,
  System.Rtti,
  System.DateUtils,
  System.JSON,
  System.Types,
  System.Generics.Collections,
  Winapi.Windows,
  Data.DB,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.ComCtrls,
  cxEdit,
  cxHyperLinkEdit,
  cxFilter,
  cxPC,
  cxGrid,
  cxGridCustomView,
  cxGridCustomTableView,
  cxGridTableView,
  cxGridCustomPopupMenu,
  cxGridPopupMenu,
  cxGridDBTableView,
  dxLayoutContainer,
  dxBar,
  dxSkinChooserGallery,
  zSystem,
  zDbView,
  zDbView.Filter,
  zDX,
  Sonda.Protocollo,
  Sonda.Server,
  Sonda.Ispezione;

const
  Veri: array [0 .. 4] of string = ('1', 'true', 'si', 'sì', 'vero');
  TipiTesto = [ftString, ftFixedChar, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftGuid];
  TipiData = [ftDate, ftTime, ftDateTime, ftTimeStamp];
  TipiIntero = [ftAutoInc, ftSmallint, ftInteger, ftWord, ftLargeint, ftShortint, ftByte, ftLongWord];
  TipiDecimale = [ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle];

type
  TOperatoreSonda = record
    Nome: string;
    Operatore: TcxFilterOperatorKind;
    SenzaValore: Boolean;
  end;

const
  Operatori: array [0 .. 11] of TOperatoreSonda = (
    (Nome: 'uguale'; Operatore: foEqual; SenzaValore: False),
    (Nome: 'diverso'; Operatore: foNotEqual; SenzaValore: False),
    (Nome: 'inizia'; Operatore: foBeginsWith; SenzaValore: False),
    (Nome: 'contiene'; Operatore: foContains; SenzaValore: False),
    (Nome: 'non_contiene'; Operatore: foNotContains; SenzaValore: False),
    (Nome: 'finisce'; Operatore: foEndsWith; SenzaValore: False),
    (Nome: 'maggiore'; Operatore: foGreater; SenzaValore: False),
    (Nome: 'maggiore_uguale'; Operatore: foGreaterEqual; SenzaValore: False),
    (Nome: 'minore'; Operatore: foLess; SenzaValore: False),
    (Nome: 'minore_uguale'; Operatore: foLessEqual; SenzaValore: False),
    (Nome: 'vuoto'; Operatore: foEqual; SenzaValore: True),
    (Nome: 'non_vuoto'; Operatore: foNotEqual; SenzaValore: True));

function NomiOperatori: string;
var
  Voce: TOperatoreSonda;
begin
  Result := '';
  for Voce in Operatori do
    Result := Result + IfThen(Result <> '', ', ') + Voce.Nome;
end;

function VistaDa(Argomenti: TJSONObject): TzDbView;
var
  Componente: TComponent;
begin
  Componente := TrovaComponente(Argomenti.GetValue<string>('indirizzo', ''));
  if not (Componente is TzDbView) then
    raise ESonda.CreateFmt('%s (%s) non e'' una vista (TzDbView): indica la vista, anche per ruolo ' +
      '(Form.vista:Modulo.Dataset).', [IndirizzoDi(Componente), Componente.ClassName]);
  Result := TzDbView(Componente);
end;

function ColonnaDa(Vista: TzDbView; const Campo: string): TcxGridDBColumn;
begin
  Result := Vista.ColumnByName(Campo);
  if Result = nil then
    raise ESonda.CreateFmt('La vista %s non ha una colonna sul campo "%s": l''elenco lo da'' il comando colonna ' +
      'senza campo.', [IndirizzoDi(Vista), Campo]);
end;

// Le modifiche in sospeso si chiudono come fanno F3 e F4 (CloseQuery), prima
// di cambiare il filtro: la domanda "Salvo le modifiche?" arriva alla sonda
// come dialogo.
procedure ChiudiModifiche(Vista: TzDbView);
begin
  if not Vista.DataController.CloseQuery then
    raise ESonda.CreateFmt('Le modifiche in sospeso su %s non sono state chiuse: filtro non cambiato.',
      [IndirizzoDi(Vista)]);
end;

// Il testo dell'utente nel tipo del campo. SenzaOperatore = come F3: il testo
// in maiuscolo, "inizia per", con l'asterisco in fondo "contiene".
function ValoreFiltro(Campo: TField; const Testo: string; SenzaOperatore: Boolean;
  var Operatore: TcxFilterOperatorKind): Variant;
var
  Pulito: string;
  Data: TDateTime;
  Intero: Int64;
  Decimale: Double;
begin
  Pulito := Testo.Trim;
  if Pulito = '' then
    Exit(Null);

  if Campo.DataType in TipiData then
  begin
    // ISO con AReturnUTC vero: il testo senza fuso vale com'e' scritto (con
    // falso si convertirebbe in ora locale, un'ora avanti)
    if not TryStrToDateTime(Pulito, Data) and not TryISO8601ToDate(Pulito, Data, True) then
      raise ESonda.CreateFmt('"%s" non e'' una data per il campo %s: scrivila come %s o aaaa-mm-gg.',
        [Testo, Campo.FieldName, FormatSettings.ShortDateFormat]);
    Exit(Data);
  end;

  if Campo.DataType in TipiIntero then
  begin
    if not TryStrToInt64(Pulito, Intero) then
      raise ESonda.CreateFmt('"%s" non e'' un numero intero per il campo %s.', [Testo, Campo.FieldName]);
    Exit(Intero);
  end;

  if Campo.DataType in TipiDecimale then
  begin
    // il punto e la virgola valgono tutti e due come separatore dei decimali
    if not TryStrToFloat(Pulito.Replace(',', '.'), Decimale, TFormatSettings.Invariant) then
      raise ESonda.CreateFmt('"%s" non e'' un numero per il campo %s.', [Testo, Campo.FieldName]);
    Exit(Decimale);
  end;

  if Campo.DataType = ftBoolean then
    Exit(MatchText(Pulito, Veri));

  if SenzaOperatore and (Campo.DataType in TipiTesto) then
  begin
    Pulito := Pulito.ToUpper;
    TzDbViewFilterController.ParseStringFilterValue(Pulito, Operatore);
    if Pulito = '' then
      Exit(Null);
  end;
  Result := Pulito;
end;

function DescriviFiltro(Vista: TzDbView): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('vista', IndirizzoDi(Vista));
  with Vista.cxGridDBTableView.DataController do
    Result.AddPair('filtro', IfThen(Filter.Active, Filter.FilterCaption, ''));
  Result.AddPair('condizioni', TJSONNumber.Create(Vista.FilterCount));
  Result.AddPair('filtri_ammessi', TJSONBool.Create(Vista.Flags.Filters));
  if Vista.zDataSet <> nil then
    Result.AddPair('dataset', GetEnumName(TypeInfo(TDataSetState), Ord(Vista.zDataSet.State)));
  Result.AddPair('record', TJSONNumber.Create(Vista.DataController.GetRecordCount));
end;

function EseguiFiltro(Argomenti: TJSONObject): TJSONValue;
var
  Vista: TzDbView;
  NomeCampo, NomeOperatore: string;
  Colonna: TcxGridDBColumn;
  Campo: TField;
  Voce: TOperatoreSonda;
  Trovato, Aggiungi: Boolean;
  Operatore: TcxFilterOperatorKind;
  Valore: Variant;
begin
  Vista := VistaDa(Argomenti);
  NomeCampo := Argomenti.GetValue<string>('campo', '').Trim;

  if Argomenti.GetValue<Boolean>('elimina', False) then
  begin
    ChiudiModifiche(Vista);
    if NomeCampo = '' then
    begin
      Vista.ClearFilter(True);
      Exit(TJSONString.Create('filtro della vista tolto: ' + IndirizzoDi(Vista)));
    end;
    ColonnaDa(Vista, NomeCampo);
    Vista.DeleteConditionsForField(NomeCampo);
    Exit(TJSONString.Create(Format('condizioni sul campo %s tolte', [NomeCampo])));
  end;

  // senza campo: solo lettura, il filtro attuale arriva in "dopo"
  if NomeCampo = '' then
    Exit(TJSONString.Create('filtro letto: ' + IndirizzoDi(Vista)));

  if not Vista.Flags.Filters then
    raise ESonda.CreateFmt('La vista %s non ammette filtri (Flags.Filters spento): l''utente non potrebbe filtrarla.',
      [IndirizzoDi(Vista)]);
  Colonna := ColonnaDa(Vista, NomeCampo);
  Campo := Colonna.DataBinding.Field;
  if Campo = nil then
    raise ESonda.CreateFmt('La colonna %s non e'' legata a un campo del dataset.', [NomeCampo]);

  NomeOperatore := Argomenti.GetValue<string>('operatore', '').Trim;
  Operatore := foEqual;
  Voce := Default (TOperatoreSonda);
  if NomeOperatore <> '' then
  begin
    Trovato := False;
    for Voce in Operatori do
      if SameText(Voce.Nome, NomeOperatore) then
      begin
        Trovato := True;
        Break;
      end;
    if not Trovato then
      raise ESonda.CreateFmt('Operatore "%s" sconosciuto: %s.', [NomeOperatore, NomiOperatori]);
    Operatore := Voce.Operatore;
  end;

  if Voce.SenzaValore then
    Valore := Null
  else
  begin
    Valore := ValoreFiltro(Campo, Argomenti.GetValue<string>('valore', ''), NomeOperatore = '', Operatore);
    if VarIsNull(Valore) then
      raise ESonda.Create('Serve un valore (per togliere le condizioni del campo usa elimina, per i valori ' +
        'assenti l''operatore vuoto).');
  end;

  Aggiungi := Argomenti.GetValue<Boolean>('aggiungi', False);
  ChiudiModifiche(Vista);
  Vista.AddFilterCondition(NomeCampo, Operatore, Valore, True, not Aggiungi);
  Result := TJSONString.Create(Format('condizione %s %s "%s" %s sulla vista %s',
    [NomeCampo, IfThen(NomeOperatore = '', 'come F3', NomeOperatore), VarToStr(Valore),
    IfThen(Aggiungi, 'aggiunta', 'impostata'), IndirizzoDi(Vista)]));
end;

function EsitoFiltro(Argomenti: TJSONObject): TJSONValue;
begin
  Result := DescriviFiltro(VistaDa(Argomenti));
end;

function EseguiColonna(Argomenti: TJSONObject): TJSONValue;
var
  Vista: TzDbView;
  Griglia: TcxGridDBTableView;
  NomeCampo: string;
  Colonna: TcxGridDBColumn;
  Elenco: TJSONArray;
  Voce, Risposta: TJSONObject;
  Indice: Integer;
begin
  Vista := VistaDa(Argomenti);
  Griglia := Vista.cxGridDBTableView;
  NomeCampo := Argomenti.GetValue<string>('campo', '').Trim;

  if NomeCampo <> '' then
  begin
    Colonna := ColonnaDa(Vista, NomeCampo);
    if not Colonna.Visible then
      raise ESonda.CreateFmt('La colonna %s e'' nascosta: l''utente non la puo'' rendere attiva.', [NomeCampo]);
    Griglia.Controller.FocusedColumn := Colonna;
  end;

  Risposta := TJSONObject.Create;
  if Griglia.Controller.FocusedColumn is TcxGridDBColumn then
  begin
    Colonna := TcxGridDBColumn(Griglia.Controller.FocusedColumn);
    Risposta.AddPair('attiva', Colonna.DataBinding.FieldName);
    Risposta.AddPair('intestazione', Colonna.Caption);
  end;
  if NomeCampo = '' then
  begin
    Elenco := TJSONArray.Create;
    for Indice := 0 to Griglia.VisibleColumnCount - 1 do
      if Griglia.VisibleColumns[Indice] is TcxGridDBColumn then
      begin
        Colonna := TcxGridDBColumn(Griglia.VisibleColumns[Indice]);
        Voce := TJSONObject.Create;
        Voce.AddPair('campo', Colonna.DataBinding.FieldName);
        Voce.AddPair('intestazione', Colonna.Caption);
        Elenco.AddElement(Voce);
      end;
    Risposta.AddPair('colonne', Elenco);
  end;
  Result := Risposta;
end;

// Il selettore delle skin del ribbon della form principale, nil se non c'e'.
function SelettoreSkin: TdxRibbonSkinSelector;
var
  Indice: Integer;
begin
  Result := nil;
  if Application.MainForm = nil then
    Exit;
  for Indice := 0 to Application.MainForm.ComponentCount - 1 do
    if Application.MainForm.Components[Indice] is TdxRibbonSkinSelector then
      Exit(TdxRibbonSkinSelector(Application.MainForm.Components[Indice]));
end;

function DescriviSkin(ConElenco: Boolean): TJSONObject;
var
  Nomi: TStringList;
  Elenco: TJSONArray;
  Nome: string;
begin
  Result := TJSONObject.Create;
  Result.AddPair('attuale', dx.SkinName);
  Result.AddPair('tavolozza', dx.SkinPaletteName);
  Result.AddPair('skin_attiva', TJSONBool.Create(dx.SkinActive));
  if not ConElenco then
    Exit;
  Nomi := TStringList.Create;
  try
    dx.GetSkinNames(Nomi);
    Elenco := TJSONArray.Create;
    for Nome in Nomi do
      Elenco.Add(Nome);
    Result.AddPair('disponibili', Elenco);
  finally
    Nomi.Free;
  end;
end;

function EseguiSkin(Argomenti: TJSONObject): TJSONValue;
var
  Nome, Tavolozza, Avviso: string;
  Nomi: TStringList;
  Selettore: TdxRibbonSkinSelector;
begin
  Nome := Argomenti.GetValue<string>('nome', '').Trim;
  Tavolozza := Argomenti.GetValue<string>('tavolozza', '').Trim;
  if Nome = '' then
    Exit(DescriviSkin(True));

  Avviso := '';
  Nomi := TStringList.Create;
  try
    dx.GetSkinNames(Nomi);
    if Nomi.IndexOf(Nome) < 0 then
      Avviso := Format(' ATTENZIONE: "%s" non e'' fra le skin del file (%s): se non esiste il programma torna ' +
        'all''aspetto predefinito.', [Nome, Nomi.CommaText])
    else
      Nome := Nomi[Nomi.IndexOf(Nome)];
  finally
    Nomi.Free;
  end;

  Selettore := SelettoreSkin;
  if Selettore <> nil then
  begin
    Selettore.SetSkin(Nome, Tavolozza);
    Result := TJSONString.Create(Format('skin %s scelta dal selettore %s%s',
      [Nome, IndirizzoDi(Selettore), Avviso]));
  end
  else
  begin
    if Tavolozza <> '' then
      dx.SkinPaletteName := Tavolozza;
    dx.SkinName := Nome;
    Result := TJSONString.Create(Format('skin %s applicata da zDX (nessun selettore nella form principale)%s',
      [Nome, Avviso]));
  end;
end;

function EsitoSkin(Argomenti: TJSONObject): TJSONValue;
begin
  // l'elenco senza nome dice gia' tutto: niente "dopo"
  if Argomenti.GetValue<string>('nome', '').Trim = '' then
    Exit(nil);
  Result := DescriviSkin(False);
end;

// ----- menu contestuale delle griglie -----------------------------------------

type
  TPopupMenuAccess = class(TPopupMenu);

// I menu predefiniti della griglia (intestazione, piede, raggruppamento)
// leggono HitGridView e HitTest del TcxGridPopupMenu attivo gia' quando
// FindPopupMenuInfo chiede se possono comparire (CanPopup), e poi in DoPopup.
// HitGridView e HitPoint sono campi privati che solo il suo DoPopup scrive:
// la sonda li scrive con l'RTTI, prima di cercare il menu. Falso se i campi
// non ci sono (versione di DevExpress diversa): allora il menu non si cerca,
// perche' le voci leggerebbero una vista nil (violazione di accesso).
function ImpostaZonaColpita(Popup: TcxGridPopupMenu; Vista: TcxCustomGridView; const Punto: TPoint;
  Tipo: TcxGridViewHitType): Boolean;
var
  Contesto: TRttiContext;
  Tipologia: TRttiType;
  CampoVista, CampoPunto, CampoTipo: TRttiField;
begin
  Tipologia := Contesto.GetType(TcxGridPopupMenu);
  CampoVista := Tipologia.GetField('FHitGridView');
  CampoPunto := Tipologia.GetField('FHitPoint');
  CampoTipo := Tipologia.GetField('FHitType');
  Result := (CampoVista <> nil) and (CampoPunto <> nil) and (CampoTipo <> nil);
  if not Result then
    Exit;
  CampoVista.SetValue(Popup, Vista);
  CampoPunto.SetValue(Popup, TValue.From<TPoint>(Punto));
  CampoTipo.SetValue(Popup, TValue.From<TcxGridViewHitType>(Tipo));
end;

function GrigliaDi(Finestra: TWinControl): TcxGrid;
var
  Controllo: TWinControl;
begin
  Controllo := Finestra;
  while (Controllo <> nil) and not (Controllo is TcxGrid) do
    Controllo := Controllo.Parent;
  Result := TcxGrid(Controllo);
end;

function CercaPopupGriglia(Contenitore: TComponent; Griglia: TcxGrid): TcxGridPopupMenu;
var
  Indice: Integer;
begin
  Result := nil;
  if Contenitore = nil then
    Exit;
  for Indice := 0 to Contenitore.ComponentCount - 1 do
  begin
    if (Contenitore.Components[Indice] is TcxGridPopupMenu) and
      (TcxGridPopupMenu(Contenitore.Components[Indice]).Grid = Griglia) then
      Exit(TcxGridPopupMenu(Contenitore.Components[Indice]));
    Result := CercaPopupGriglia(Contenitore.Components[Indice], Griglia);
    if Result <> nil then
      Exit;
  end;
end;

// Il TcxGridPopupMenu della griglia: di solito ha lo stesso proprietario
// (il frame della vista), altrimenti sta da qualche parte nella form.
function PopupDellaGriglia(Griglia: TcxGrid): TcxGridPopupMenu;
begin
  Result := CercaPopupGriglia(Griglia.Owner, Griglia);
  if Result = nil then
    Result := CercaPopupGriglia(GetParentForm(Griglia), Griglia);
end;

// TcxGridPopupMenu.DoPopup senza il cursore vero e senza Popup: la zona
// colpita, il menu registrato per la vista e per la zona, PopupComponent e
// HitTest come li imposta lui (le voci dei menu predefiniti leggono HitTest).
// Nil, con la nota, se la griglia non ha un menu per quella zona: allora vale
// la regola della VCL (PopupMenu della griglia), come fa la griglia quando
// DoPopup non gestisce il clic.
function RisolviMenuGriglia(Finestra: TWinControl; const Punto: TPoint; out Nota: string): TComponent;
var
  Griglia: TcxGrid;
  Popup: TcxGridPopupMenu;
  Vista: TcxCustomGridView;
  Schermo, PuntoGriglia: TPoint;
  Colpito: TcxCustomGridHitTest;
  Codice: Integer;
  Permesso: Boolean;
  Tipo: TcxGridViewHitType;
  Informazioni: TcxPopupMenuInfo;
begin
  Result := nil;
  Nota := '';
  Griglia := GrigliaDi(Finestra);
  if Griglia = nil then
    Exit;
  Popup := PopupDellaGriglia(Griglia);
  Vista := Griglia.FocusedView;
  if (Popup = nil) or (Vista = nil) then
  begin
    Nota := 'griglia senza TcxGridPopupMenu: vale il PopupMenu della griglia';
    Exit;
  end;

  Schermo := Finestra.ClientToScreen(Punto);
  PuntoGriglia := Griglia.ScreenToClient(Schermo);
  Colpito := Griglia.ViewInfo.GetHitTest(PuntoGriglia.X, PuntoGriglia.Y);
  Codice := Colpito.HitTestCode;
  if not PtInRect(Vista.Site.ClientRect, Vista.Site.ScreenToClient(Schermo)) then
    Inc(Codice, cxhtGridBase);
  Tipo := GetHitTypeByHitCode(Codice);
  if Ord(Tipo) > Ord(High(TcxGridViewHitType)) then
  begin
    Nota := Format('zona della griglia non riconosciuta (codice %d)', [Codice]);
    Exit;
  end;
  Nota := 'zona ' + GetEnumName(TypeInfo(TcxGridViewHitType), Ord(Tipo)) + ' della vista ' + IndirizzoDi(Vista);

  // lo stato che DoPopup prepara prima di cercare il menu
  ActiveGridPopupMenu := Popup;
  Popup.HitTest := Colpito;
  if not ImpostaZonaColpita(Popup, Vista, PuntoGriglia, Tipo) then
  begin
    Nota := Nota + ', menu non calcolabile (campi di TcxGridPopupMenu non trovati)';
    Exit;
  end;

  Informazioni := Popup.FindPopupMenuInfo(Vista.PatternGridView, Tipo, Popup.HitTest);
  if (Informazioni = nil) or (Informazioni.PopupMenu = nil) then
  begin
    Nota := Nota + IfThen(Informazioni = nil, ', nessun menu registrato per questa zona',
      ', menu costruito dal codice (OnPopup) e non leggibile');
    Exit;
  end;

  // OnPopup di TcxGridPopupMenu, come DoOnPopup prima di aprire: zDbView li'
  // nasconde voci del menu dell'intestazione, e puo' vietare il menu
  Permesso := True;
  if Assigned(Popup.OnPopup) then
    Popup.OnPopup(Informazioni.PopupMenu, Popup.HitTest, Schermo.X, Schermo.Y, Permesso);
  if not Permesso then
  begin
    Nota := Nota + ', menu vietato da OnPopup di ' + IndirizzoDi(Popup);
    Exit;
  end;

  Result := Informazioni.PopupMenu;
  if Result is TPopupMenu then
  begin
    // le voci si preparano come all'apertura vera (DoPopup, senza Popup)
    TPopupMenu(Result).PopupComponent := Vista;
    TPopupMenuAccess(Result).DoPopup(Result);
  end;
  if Informazioni.IsBuiltIn then
    Nota := Nota + ', menu predefinito della griglia';
end;

// Le voci di un TdxBarPopupMenu, nell'ordine dei suoi collegamenti.
function VociMenuBarra(Menu: TComponent): TArray<TComponent>;
var
  Indice: Integer;
  Voce: TdxBarItem;
begin
  Result := nil;
  if not (Menu is TdxBarPopupMenu) then
    Exit;
  for Indice := 0 to TdxBarPopupMenu(Menu).ItemLinks.Count - 1 do
  begin
    Voce := TdxBarPopupMenu(Menu).ItemLinks[Indice].Item;
    if (Voce <> nil) and (Voce.Visible = ivAlways) and not (Voce is TdxBarSeparator) then
      Result := Result + [Voce];
  end;
end;

// ----- schede -----------------------------------------------------------------

type
  // TabIndex delle proprieta' delle schede DevExpress e' protetto: e' la
  // strada del clic sulla linguetta (CanChange, poi il cambio)
  TProprietaSchedeAccess = class(TcxCustomTabControlProperties);
  TPageControlAccess = class(TPageControl);

function GruppoASchede(Componente: TComponent): Boolean;
begin
  Result := (Componente is TdxCustomLayoutGroup) and
    (TdxCustomLayoutGroup(Componente).LayoutDirection = ldTabbed);
end;

function ControlloASchede(Componente: TComponent): Boolean;
begin
  Result := GruppoASchede(Componente) or (Componente is TcxPageControl) or (Componente is TPageControl);
end;

// Il controllo a schede di una scheda; nil se il componente non e' una scheda.
function ContenitoreDellaScheda(Scheda: TComponent): TComponent;
begin
  Result := nil;
  if (Scheda is TdxCustomLayoutItem) and GruppoASchede(TdxCustomLayoutItem(Scheda).Parent) then
    Result := TdxCustomLayoutItem(Scheda).Parent
  else if Scheda is TcxTabSheet then
    Result := TcxTabSheet(Scheda).PageControl
  else if Scheda is TTabSheet then
    Result := TTabSheet(Scheda).PageControl;
end;

function NumeroSchede(Contenitore: TComponent): Integer;
begin
  if Contenitore is TdxCustomLayoutGroup then
    Result := TdxCustomLayoutGroup(Contenitore).Count
  else if Contenitore is TcxPageControl then
    Result := TcxPageControl(Contenitore).PageCount
  else
    Result := TPageControl(Contenitore).PageCount;
end;

function SchedaNumero(Contenitore: TComponent; Indice: Integer): TComponent;
begin
  if Contenitore is TdxCustomLayoutGroup then
    Result := TdxCustomLayoutGroup(Contenitore).Items[Indice]
  else if Contenitore is TcxPageControl then
    Result := TcxPageControl(Contenitore).Pages[Indice]
  else
    Result := TPageControl(Contenitore).Pages[Indice];
end;

function DidascaliaScheda(Scheda: TComponent): string;
begin
  if Scheda is TdxCustomLayoutItem then
    Result := TdxCustomLayoutItem(Scheda).Caption
  else if Scheda is TcxTabSheet then
    Result := TcxTabSheet(Scheda).Caption
  else
    Result := TTabSheet(Scheda).Caption;
  Result := StripHotkey(Result);
end;

// La linguetta c'e': l'utente la vede e la puo' cliccare.
function LinguettaVisibile(Scheda: TComponent): Boolean;
begin
  if Scheda is TdxCustomLayoutItem then
    Result := TdxCustomLayoutItem(Scheda).Visible
  else if Scheda is TcxTabSheet then
    Result := TcxTabSheet(Scheda).TabVisible
  else
    Result := TTabSheet(Scheda).TabVisible;
end;

function SchedaAttiva(Contenitore: TComponent): TComponent;
var
  Indice: Integer;
begin
  Result := nil;
  if Contenitore is TdxCustomLayoutGroup then
  begin
    Indice := TdxCustomLayoutGroup(Contenitore).ItemIndex;
    if (Indice >= 0) and (Indice < TdxCustomLayoutGroup(Contenitore).Count) then
      Result := TdxCustomLayoutGroup(Contenitore).Items[Indice];
  end
  else if Contenitore is TcxPageControl then
    Result := TcxPageControl(Contenitore).ActivePage
  else
    Result := TPageControl(Contenitore).ActivePage;
end;

// Il controllo a schede si vede (un gruppo del layout dentro una scheda non
// attiva non si vede, e nemmeno le sue schede).
function ContenitoreVisibile(Contenitore: TComponent): Boolean;
begin
  if Contenitore is TdxCustomLayoutGroup then
    Result := TdxCustomLayoutGroup(Contenitore).ActuallyVisible
  else
    Result := TWinControl(Contenitore).Showing;
end;

function DescriviSchede(Contenitore: TComponent): TJSONObject;
var
  Elenco: TJSONArray;
  Voce: TJSONObject;
  Scheda, Attiva: TComponent;
  Indice: Integer;
begin
  Attiva := SchedaAttiva(Contenitore);
  Result := TJSONObject.Create;
  Result.AddPair('contenitore', IndirizzoDi(Contenitore));
  Result.AddPair('classe', Contenitore.ClassName);
  Result.AddPair('visibile', TJSONBool.Create(ContenitoreVisibile(Contenitore)));
  if Attiva <> nil then
    Result.AddPair('attiva', DidascaliaScheda(Attiva));
  Elenco := TJSONArray.Create;
  for Indice := 0 to NumeroSchede(Contenitore) - 1 do
  begin
    Scheda := SchedaNumero(Contenitore, Indice);
    Voce := TJSONObject.Create;
    Voce.AddPair('didascalia', DidascaliaScheda(Scheda));
    Voce.AddPair('indirizzo', IndirizzoDi(Scheda));
    if not LinguettaVisibile(Scheda) then
      Voce.AddPair('nascosta', TJSONBool.Create(True));
    if Scheda = Attiva then
      Voce.AddPair('attiva', TJSONBool.Create(True));
    Elenco.AddElement(Voce);
  end;
  Result.AddPair('schede', Elenco);
end;

// Attiva la scheda dalla strada del clic sulla linguetta, cosi' il programma
// puo' rifiutare il cambio come farebbe con l'utente.
procedure AttivaScheda(Scheda: TComponent);
var
  Contenitore: TComponent;
begin
  Contenitore := ContenitoreDellaScheda(Scheda);
  if not LinguettaVisibile(Scheda) then
    raise ESonda.CreateFmt('La scheda "%s" (%s) e'' nascosta: l''utente non la puo'' scegliere.',
      [DidascaliaScheda(Scheda), IndirizzoDi(Scheda)]);
  if not ContenitoreVisibile(Contenitore) then
    raise ESonda.CreateFmt('Le schede di %s non si vedono (stanno in una scheda non attiva o in un gruppo ' +
      'nascosto): attiva prima la scheda che le contiene.', [IndirizzoDi(Contenitore)]);
  if Contenitore is TdxCustomLayoutGroup then
    TProprietaSchedeAccess(TdxCustomLayoutGroup(Contenitore).TabbedOptions).TabIndex :=
      TdxCustomLayoutItem(Scheda).Index
  else if Contenitore is TcxPageControl then
    TProprietaSchedeAccess(TcxPageControl(Contenitore).Properties).TabIndex := TcxTabSheet(Scheda).PageIndex
  else if TPageControlAccess(Contenitore).CanChange then
  begin
    TPageControl(Contenitore).ActivePage := TTabSheet(Scheda);
    TPageControlAccess(Contenitore).Change;
  end;
  if SchedaAttiva(Contenitore) <> Scheda then
    raise ESonda.CreateFmt('Il programma non ha cambiato scheda: %s mostra ancora "%s" (OnTabChanging o ' +
      'OnChanging ha rifiutato?).', [IndirizzoDi(Contenitore), DidascaliaScheda(SchedaAttiva(Contenitore))]);
end;

procedure RaccogliContenitori(Radice: TComponent; Trovati: TList<TComponent>);
var
  Indice: Integer;
begin
  for Indice := 0 to Radice.ComponentCount - 1 do
  begin
    if ControlloASchede(Radice.Components[Indice]) then
      Trovati.Add(Radice.Components[Indice]);
    RaccogliContenitori(Radice.Components[Indice], Trovati);
  end;
end;

function SchedaCorrisponde(Scheda: TComponent; const Cercata: string): Boolean;
begin
  Result := SameText(DidascaliaScheda(Scheda), StripHotkey(Cercata)) or SameText(Scheda.Name, Cercata);
end;

// La scheda cercata sotto Radice: in Radice stessa se e' un controllo a
// schede, altrimenti in tutti quelli che possiede. Fra piu' schede con la
// stessa didascalia vince l'unica che l'utente vede; se sono ancora piu' di
// una, l'errore le elenca.
function CercaScheda(Radice: TComponent; const Cercata: string): TComponent;
var
  Contenitori: TList<TComponent>;
  Trovate, Visibili: TList<TComponent>;
  Contenitore, Scheda: TComponent;
  Indice: Integer;
  Elenco: string;
begin
  Contenitori := TList<TComponent>.Create;
  Trovate := TList<TComponent>.Create;
  Visibili := TList<TComponent>.Create;
  try
    if ControlloASchede(Radice) then
      Contenitori.Add(Radice)
    else
      RaccogliContenitori(Radice, Contenitori);
    for Contenitore in Contenitori do
      for Indice := 0 to NumeroSchede(Contenitore) - 1 do
      begin
        Scheda := SchedaNumero(Contenitore, Indice);
        if SchedaCorrisponde(Scheda, Cercata) then
        begin
          Trovate.Add(Scheda);
          if LinguettaVisibile(Scheda) and ContenitoreVisibile(Contenitore) then
            Visibili.Add(Scheda);
        end;
      end;
    if Trovate.Count = 0 then
    begin
      Elenco := '';
      for Contenitore in Contenitori do
        if ContenitoreVisibile(Contenitore) then
          for Indice := 0 to NumeroSchede(Contenitore) - 1 do
            Elenco := Elenco + IfThen(Elenco <> '', ', ') + '"' + DidascaliaScheda(SchedaNumero(Contenitore, Indice)) + '"';
      raise ESonda.CreateFmt('Nessuna scheda "%s" sotto %s. Schede che si vedono: %s.',
        [Cercata, IndirizzoDi(Radice), IfThen(Elenco <> '', Elenco, 'nessuna')]);
    end;
    if Trovate.Count = 1 then
      Exit(Trovate[0]);
    if Visibili.Count = 1 then
      Exit(Visibili[0]);
    Elenco := '';
    for Scheda in Trovate do
      Elenco := Elenco + IfThen(Elenco <> '', ', ') + IndirizzoDi(Scheda);
    raise ESonda.CreateFmt('Piu'' schede "%s" sotto %s: %s. Indica il controllo a schede o la scheda.',
      [Cercata, IndirizzoDi(Radice), Elenco]);
  finally
    Visibili.Free;
    Trovate.Free;
    Contenitori.Free;
  end;
end;

function EseguiScheda(Argomenti: TJSONObject): TJSONValue;
var
  Componente, Scheda, Contenitore: TComponent;
  Cercata: string;
  Risposta: TJSONObject;
begin
  Componente := TrovaComponente(Argomenti.GetValue<string>('indirizzo', ''));
  Cercata := Argomenti.GetValue<string>('scheda', '').Trim;

  if Cercata = '' then
  begin
    // un controllo a schede: l'elenco; una scheda: la si attiva
    if ControlloASchede(Componente) then
      Exit(DescriviSchede(Componente));
    if ContenitoreDellaScheda(Componente) = nil then
      raise ESonda.CreateFmt('%s (%s) non e'' una scheda ne'' un controllo a schede: indica la didascalia in ' +
        'scheda, e la sonda la cerca.', [IndirizzoDi(Componente), Componente.ClassName]);
    Scheda := Componente;
  end
  else
    Scheda := CercaScheda(Componente, Cercata);

  Contenitore := ContenitoreDellaScheda(Scheda);
  AttivaScheda(Scheda);
  Risposta := DescriviSchede(Contenitore);
  Risposta.AddPair('attivata', DidascaliaScheda(Scheda));
  Result := Risposta;
end;

// ----- celle delle griglie ----------------------------------------------------

function VistaGriglia(Componente: TComponent): TcxGridTableView;
begin
  if Componente is TzDbView then
    Result := TzDbView(Componente).cxGridDBTableView
  else if Componente is TcxGridTableView then
    Result := TcxGridTableView(Componente)
  else if Componente is TcxGridColumn then
    Result := TcxGridColumn(Componente).GridView
  else
    raise ESonda.CreateFmt('%s (%s) non e'' una griglia: indica la vista (TzDbView, anche per ruolo ' +
      'Form.vista:Modulo.Dataset) o la sua TcxGridDBTableView.', [IndirizzoDi(Componente), Componente.ClassName]);
end;

// La colonna per nome del campo, intestazione o Name.
function ColonnaGriglia(Vista: TcxGridTableView; const Cercata: string): TcxGridColumn;
var
  Indice: Integer;
  Colonna: TcxGridColumn;
  Elenco: string;
begin
  for Indice := 0 to Vista.ColumnCount - 1 do
  begin
    Colonna := Vista.Columns[Indice];
    if ((Colonna is TcxGridDBColumn) and SameText(TcxGridDBColumn(Colonna).DataBinding.FieldName, Cercata)) or
      SameText(Colonna.Caption, Cercata) or SameText(Colonna.Name, Cercata) then
      Exit(Colonna);
  end;
  Elenco := '';
  for Indice := 0 to Vista.VisibleColumnCount - 1 do
  begin
    Colonna := Vista.VisibleColumns[Indice];
    if Colonna is TcxGridDBColumn then
      Elenco := Elenco + IfThen(Elenco <> '', ', ') + TcxGridDBColumn(Colonna).DataBinding.FieldName
    else
      Elenco := Elenco + IfThen(Elenco <> '', ', ') + Colonna.Caption;
  end;
  raise ESonda.CreateFmt('La griglia %s non ha la colonna "%s". Colonne visibili: %s.',
    [IndirizzoDi(Vista), Cercata, Elenco]);
end;

function NomeColonna(Colonna: TcxGridColumn): string;
begin
  if Colonna is TcxGridDBColumn then
    Result := TcxGridDBColumn(Colonna).DataBinding.FieldName
  else
    Result := Colonna.Caption;
end;

// La prima riga di dati (in ordine di griglia) con quel testo nella colonna.
function RigaConValore(Vista: TcxGridTableView; Colonna: TcxGridColumn; const Valore: string): Integer;
var
  Indice: Integer;
begin
  for Indice := 0 to Vista.ViewData.RowCount - 1 do
    if (Vista.ViewData.Rows[Indice] is TcxGridDataRow) and
      SameText(Vista.ViewData.Rows[Indice].DisplayTexts[Colonna.Index].Trim, Valore.Trim) then
      Exit(Indice);
  raise ESonda.CreateFmt('Nessuna riga di %s ha "%s" nella colonna %s (righe: %d).',
    [IndirizzoDi(Vista), Valore, NomeColonna(Colonna), Vista.ViewData.RowCount]);
end;

// Clic sulla cella: riga negativa = la riga attiva; X e Y negativi = sul
// testo (il collegamento si apre solo li') a meta' altezza.
function ClicSuCella(Vista: TcxGridTableView; Colonna: TcxGridColumn; Riga, X, Y: Integer; Doppio: Boolean;
  Modificatori: TModificatoriClic): TJSONObject;
const
  Margine = 6;
var
  RigaGriglia: TcxCustomGridRecord;
  Cella: TcxGridTableDataCellViewInfo;
  Rettangolo: TRect;
  Testo: string;
  Collegamento, DoppioPerCollegamento: Boolean;
begin
  if not Vista.Site.HandleAllocated or not Vista.Site.Showing then
    raise ESonda.CreateFmt('La griglia %s non si vede: attiva prima la sua scheda.', [IndirizzoDi(Vista)]);
  if not Colonna.Visible then
    raise ESonda.CreateFmt('La colonna %s e'' nascosta: l''utente non la puo'' cliccare.', [NomeColonna(Colonna)]);
  if Riga < 0 then
    Riga := Vista.Controller.FocusedRowIndex;
  if Riga < 0 then
    Riga := 0;
  if Riga >= Vista.ViewData.RowCount then
    raise ESonda.CreateFmt('La griglia %s ha %d righe: la riga %d non c''e'' (si conta da 0).',
      [IndirizzoDi(Vista), Vista.ViewData.RowCount, Riga]);

  RigaGriglia := Vista.ViewData.Rows[Riga];
  RigaGriglia.MakeVisible;
  Vista.Controller.MakeItemVisible(Colonna);
  if RigaGriglia.ViewInfo = nil then
    raise ESonda.CreateFmt('La riga %d di %s non si e'' portata in vista.', [Riga, IndirizzoDi(Vista)]);
  Cella := RigaGriglia.ViewInfo.GetCellViewInfoByItem(Colonna);
  if Cella = nil then
    raise ESonda.CreateFmt('La cella della colonna %s, riga %d, non si vede.', [NomeColonna(Colonna), Riga]);
  Rettangolo := Cella.Bounds;
  Testo := RigaGriglia.DisplayTexts[Colonna.Index];

  if X < 0 then
    case Colonna.GetProperties.Alignment.Horz of
      taRightJustify:
        X := Rettangolo.Width - Margine;
      taCenter:
        X := Rettangolo.Width div 2;
    else
      X := Margine;
    end;
  if Y < 0 then
    Y := Rettangolo.Height div 2;
  if (X >= Rettangolo.Width) or (Y >= Rettangolo.Height) then
    raise ESonda.CreateFmt('Il punto (%d, %d) e'' fuori dalla cella, che misura %d x %d.',
      [X, Y, Rettangolo.Width, Rettangolo.Height]);

  // Un collegamento parte in due modi. Colonna modificabile: clic singolo,
  // perche' la griglia crea l'editor della cella (TcxHyperLinkEdit con
  // SingleClick) e il rilascio lo apre. Colonna non modificabile (le viste in
  // sola lettura, come Saldo Documenti di WT): la griglia non crea l'editor e
  // il collegamento lo apre il doppio clic della vista
  // (TzDbView.cxGridDBTableViewDblClick). E' quello che fa l'utente, e la
  // sonda lo fa da se'.
  Collegamento := Colonna.GetProperties is TcxCustomHyperLinkEditProperties;
  DoppioPerCollegamento := Collegamento and not Colonna.Editable and not Doppio;

  Result := TJSONObject.Create;
  Result.AddPair('griglia', IndirizzoDi(Vista));
  Result.AddPair('riga', TJSONNumber.Create(Riga));
  Result.AddPair('colonna', NomeColonna(Colonna));
  Result.AddPair('testo', Testo);
  Result.AddPair('collegamento', TJSONBool.Create(Collegamento));
  Result.AddPair('modificabile', TJSONBool.Create(Colonna.Editable));
  Result.AddPair('clic', ClicNellaFinestra(Vista.Site, Point(Rettangolo.Left + X, Rettangolo.Top + Y),
    Doppio or DoppioPerCollegamento, Modificatori, Format('cella %s della riga %d di %s ("%s")%s',
    [NomeColonna(Colonna), Riga, IndirizzoDi(Vista), Testo, IfThen(DoppioPerCollegamento,
    ' (doppio clic: il collegamento di una colonna non modificabile si apre cosi'')', '')])));
end;

function EseguiCella(Argomenti: TJSONObject): TJSONValue;
var
  Vista: TcxGridTableView;
  Componente: TComponent;
  Colonna: TcxGridColumn;
  NomeCampo, Valore: string;
  Riga: Integer;
begin
  Componente := TrovaComponente(Argomenti.GetValue<string>('indirizzo', ''));
  Vista := VistaGriglia(Componente);
  NomeCampo := Argomenti.GetValue<string>('campo', '').Trim;
  if NomeCampo <> '' then
    Colonna := ColonnaGriglia(Vista, NomeCampo)
  else if Componente is TcxGridColumn then
    Colonna := TcxGridColumn(Componente)
  else if Vista.Controller.FocusedColumn is TcxGridColumn then
    Colonna := TcxGridColumn(Vista.Controller.FocusedColumn)
  else
    raise ESonda.Create('Indica la colonna in campo (nome del campo o intestazione).');

  Valore := Argomenti.GetValue<string>('valore', '');
  if Valore <> '' then
    Riga := RigaConValore(Vista, Colonna, Valore)
  else
    Riga := Argomenti.GetValue<Integer>('riga', -1);
  Result := ClicSuCella(Vista, Colonna, Riga, Argomenti.GetValue<Integer>('x', -1),
    Argomenti.GetValue<Integer>('y', -1), Argomenti.GetValue<Boolean>('doppio', False),
    ModificatoriDaTesto(Argomenti.GetValue<string>('modificatori', '')));
end;

// Dopo il clic: un collegamento apre la sua form con un messaggio differito,
// quindi la form attiva si legge qui.
function EsitoCella(Argomenti: TJSONObject): TJSONValue;
var
  Risposta: TJSONObject;
begin
  Risposta := TJSONObject.Create;
  if Screen.ActiveCustomForm <> nil then
  begin
    Risposta.AddPair('form_attiva', IndirizzoDi(Screen.ActiveCustomForm));
    Risposta.AddPair('titolo', Screen.ActiveCustomForm.Caption);
  end;
  Result := Risposta;
end;

// app_clic su una scheda senza coordinate la attiva; su una colonna clicca la
// cella della riga attiva.
function ClicSpeciale(Componente: TComponent; X, Y: Integer; Doppio: Boolean;
  Modificatori: TModificatoriClic): string;
var
  Cella: TJSONObject;
begin
  Result := '';
  if (ContenitoreDellaScheda(Componente) <> nil) and (X < 0) and (Y < 0) and not Doppio then
  begin
    AttivaScheda(Componente);
    Exit(Format('scheda "%s" attivata in %s', [DidascaliaScheda(Componente),
      IndirizzoDi(ContenitoreDellaScheda(Componente))]));
  end;
  if Componente is TcxGridColumn then
  begin
    Cella := ClicSuCella(TcxGridColumn(Componente).GridView, TcxGridColumn(Componente), -1, X, Y, Doppio,
      Modificatori);
    try
      Result := Cella.GetValue<string>('clic', '');
    finally
      Cella.Free;
    end;
  end;
end;

procedure RegistraComandiSondaZBase;
begin
  RisolutoreMenuContestualeSonda := RisolviMenuGriglia;
  VociMenuContestualeSonda := VociMenuBarra;
  ClicSpecialeSonda := ClicSpeciale;
  RegistraComandoSonda(ComandoFiltro, EseguiFiltro, EsitoFiltro);
  RegistraComandoSonda(ComandoColonna, EseguiColonna);
  RegistraComandoSonda(ComandoSkin, EseguiSkin, EsitoSkin);
  RegistraComandoSonda(ComandoScheda, EseguiScheda);
  RegistraComandoSonda(ComandoCella, EseguiCella, EsitoCella);
end;

end.
