unit zMemoDialog;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.UITypes,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.ImgList,
  Vcl.StdActns,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxTextEdit,
  cxMemo,
  dxBar,
  cxClasses,
  cxImageList,
  dxRibbonForm,
  dxFileActions,
  OkCancel,
  zFindReplace.Helper,
  dxBarExtItems;

const
  // azione personalizzata da eseguire appena il dialogo e' visibile
  WM_ESEGUI_AZIONE_INIZIALE = WM_USER + 101;

type
  TzMemoForm = class(TdxRibbonForm)
    ActionList: TActionList;
    dxBarManager: TdxBarManager;
    dxBarPopupMenu: TdxBarPopupMenu;
    OkCancel: TOkCancel;
    cxMemo: TcxMemo;
    EditCut: TEditCut;
    EditCopy: TEditCopy;
    EditPaste: TEditPaste;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    EditDelete: TEditDelete;
    FileOpen: TdxFileOpen;
    FileSaveAs: TdxFileSaveAs;
    dxBarManagerBarToolbar: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton11: TdxBarButton;
    dxBarButton7: TdxBarButton;
    Trova: TAction;
    Sostituisci: TAction;
    Successivo: TAction;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarManagerBarFree: TdxBar;
    dxBarStatic1: TdxBarStatic;
    dxBarStatic2: TdxBarStatic;
    procedure FileOpenAccept(Sender: TObject);
    procedure FileSaveAsAccept(Sender: TObject);
    procedure SostituisciExecute(Sender: TObject);
    procedure SostituisciUpdate(Sender: TObject);
    procedure SuccessivoExecute(Sender: TObject);
    procedure TrovaExecute(Sender: TObject);
  private
    FindReplaceHelper: TFindReplaceHelper;
    // Mantis #257 - 2026-10-19: testo all'apertura e conferma data dalla domanda di uscita
    TestoIniziale: string;
    TestoConfermato: boolean;

    // Importa dal menu del tasto destro della scheda: l'azione parte a dialogo
    // aperto, cosi' lavora sul suo memo come se l'utente avesse premuto il pulsante
    AzioneIniziale: TBasicAction;

    procedure InitCustomActions(CustomActions: TArray<TBasicAction>; ImageList: TCustomImageList);
    procedure EseguiAzioneIniziale(var Message: TMessage); message WM_ESEGUI_AZIONE_INIZIALE;
  protected
    function CloseQuery: boolean; override;
    procedure DoShow; override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function Execute(aMemo: TcxCustomMemo = nil; CustomActions: TArray < TBasicAction >= nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False; Iniziale: TBasicAction = nil): boolean;
  end;

  TzMemoDialog = class(TComponent)
  private
    // FDataLink: TFieldDataLink;
    FCaption: String;

    FOnInitDialog: TNotifyEvent;
    FOnCloseDialog: TNotifyEvent;
    FLines: TStrings;
    procedure SetLines(Value: TStrings);
  protected
    zMemoForm: TzMemoForm;
    procedure SetCaption(Value: String);
    procedure DoInitDialog;
    procedure DoCloseDialog;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(cxMemo: TcxCustomMemo = nil; CustomActions: TArray < TBasicAction >= nil; ImageList: TCustomImageList = nil): boolean;
  published
    property Caption: string read FCaption write SetCaption;
    property Lines: TStrings read FLines write SetLines;

    property OnInitDialog: TNotifyEvent read FOnInitDialog write FOnInitDialog;
    property OnCloseDialog: TNotifyEvent read FOnCloseDialog write FOnCloseDialog;
  end;

function zExecuteMemoDialog(cxMemo: TcxCustomMemo; const Caption: string = ''; CustomActions: TArray<TBasicAction> = nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False; AzioneIniziale: TBasicAction = nil): boolean; overload;

function zExecuteMemoDialog(Lines: TStrings; const Caption: string = ''; CustomActions: TArray < TBasicAction >= nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False): boolean; overload;

function zExecuteMemoDialog(var Text: String; const Caption: string = ''; CustomActions: TArray<TBasicAction> = nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False): boolean; overload;

implementation

uses
  zDX,
  zMsg;

{$R *.dfm}

function zExecuteMemoDialog(cxMemo: TcxCustomMemo; const Caption: string = ''; CustomActions: TArray<TBasicAction> = nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False; AzioneIniziale: TBasicAction = nil): boolean;
var
  zMemoForm: TzMemoForm;
begin
  zMemoForm := TzMemoForm.Create(Nil);
  try
    zMemoForm.Caption := Caption;

    Result := zMemoForm.Execute(cxMemo, CustomActions, ImageList, MandaACapo, AzioneIniziale);

    if Result then
      if Assigned(cxMemo) then
      begin
        // cxMemo.Lines.Assign(zMemoForm.cxMemo.Lines); // no, sformatta: usare .Text
        cxMemo.Text := zMemoForm.cxMemo.Text;
      end;
  finally
    FreeAndNil(zMemoForm);
  end;
end;

function zExecuteMemoDialog(Lines: TStrings; const Caption: string = ''; CustomActions: TArray<TBasicAction> = nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False): boolean;
var
  zMemoForm: TzMemoForm;
begin
  // DIV-MDG-1: senza lista non c'e' nulla da mostrare ne' da riscrivere
  if not Assigned(Lines) then
    Exit(False);

  zMemoForm := TzMemoForm.Create(Nil);
  try
    zMemoForm.Caption := Caption;
    zMemoForm.cxMemo.Text := Lines.Text;

    Result := zMemoForm.Execute(nil, CustomActions, ImageList, MandaACapo);

    if Result then
      // cxMemo.Lines.Assign(zMemoForm.cxMemo.Lines); // no, sformatta: usare .Text
      Lines.Text := zMemoForm.cxMemo.Text;
  finally
    FreeAndNil(zMemoForm);
  end;
end;

function zExecuteMemoDialog(var Text: String; const Caption: string = ''; CustomActions: TArray<TBasicAction> = nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False): boolean;
var
  zMemoForm: TzMemoForm;
begin
  zMemoForm := TzMemoForm.Create(Nil);
  try
    zMemoForm.Caption := Caption;
    zMemoForm.cxMemo.Text := Text;

    Result := zMemoForm.Execute(nil, CustomActions, ImageList, MandaACapo);

    if Result then
      Text := zMemoForm.cxMemo.Text;
  finally
    FreeAndNil(zMemoForm);
  end;
end;

constructor TzMemoForm.Create(aOwner: TComponent);
  procedure InitBar(bar: TdxBar);
  begin
    dx.InitBar(bar);
    bar.WholeRow := false;
    bar.Row := 0;
  end;

begin
  inherited;
  dx.AgganciaImmagini(Self);
  FindReplaceHelper := TFindReplaceHelper.Create(Self, cxMemo);

  InitBar(dxBarManagerBarToolbar);
  InitBar(dxBarManagerBarFree);
end;

destructor TzMemoForm.Destroy;
begin
  FreeAndNil(FindReplaceHelper);
  inherited;
end;

function TzMemoForm.Execute(aMemo: TcxCustomMemo = nil; CustomActions: TArray < TBasicAction >= nil; ImageList: TCustomImageList = nil; MandaACapo: boolean = False; Iniziale: TBasicAction = nil): boolean;
begin
  // Init;

  // LoadFormPosition(Self, zSystem.GetUserFileName(Ext_Dlgs));

  InitCustomActions(CustomActions, ImageList);
  AzioneIniziale := Iniziale;

  if Assigned(aMemo) then
  begin
    cxMemo.Properties.Assign(aMemo.Properties);
    cxMemo.Properties.ScrollBars := TScrollStyle.ssBoth;
    // cxMemo.Lines.Assign(aMemo.Lines);  // no, sformatta: usare .Text
    cxMemo.Text := aMemo.Text;
  end;

  // Mantis #152 - 2026-09-21: su richiesta il testo va a capo da solo, invece di
  // sbordare a destra costringendo a scorrere in orizzontale. WordWrap e' gia'
  // True per difetto su TcxMemo: e' la barra di scorrimento orizzontale ad
  // annullarlo, perche' DevExpress applica CXTO_WORDBREAK solo quando ScrollBars
  // non e' ssHorizontal ne' ssBoth (si veda cxMemo.pas). Per questo qui si tocca
  // anche ScrollBars, e non basta WordWrap.
  //
  // ATTENZIONE: da usare per i riquadri di sola lettura (esiti, registri, messaggi).
  // Sul percorso di modifica dei memo dei dataset lasciare False: le Lines di una
  // memo VCL, con WordWrap attivo, restituiscono anche le andate a capo aggiunte
  // dal componente, e riscriverle nel campo ne cambierebbe il contenuto. E' lo
  // stesso inciampo per cui qui sotto si assegna .Text e non .Lines.
  if MandaACapo then
  begin
    cxMemo.Properties.WordWrap := True;
    cxMemo.Properties.ScrollBars := TScrollStyle.ssVertical;
  end;

  TestoIniziale := cxMemo.Text;
  TestoConfermato := False;

  // TestoConfermato vale quando l'utente, uscendo con la X o con Annulla dopo aver
  // modificato il testo, risponde Si' alla domanda: ShowModal in quel caso non
  // restituisce mrOk, perche' Close imposta mrCancel dopo CloseQuery.
  Result := (ShowModal = mrOk) or TestoConfermato;
  // SaveFormPosition(Self, zSystem.GetUserFileName(Ext_Dlgs));
end;

// Mantis #257 - 2026-10-19: chiudere la finestra con la X o con Annulla dopo aver
// modificato il testo lo scartava senza avvisi (il campo della scheda si aggiorna
// solo con OK). Ora si chiede conferma, solo se il testo e' davvero cambiato e il
// riquadro non e' di sola lettura.
function TzMemoForm.CloseQuery: boolean;
begin
  Result := inherited CloseQuery;

  if not Result then
    Exit;

  if (ModalResult = mrOk) or cxMemo.Properties.ReadOnly or (cxMemo.Text = TestoIniziale) then
    Exit;

  case ConfirmYesNoCancel('Il testo e'' stato modificato ma non confermato.' + sLineBreak + sLineBreak +
    'Si'' = conferma il testo e chiudi' + sLineBreak +
    'No = chiudi senza salvare le modifiche' + sLineBreak +
    'Annulla = torna al testo', mtConfirmation) of
    mrYes:
      TestoConfermato := True;
    mrNo:
      ;
  else
    Result := False;
  end;
end;

procedure TzMemoForm.DoShow;
begin
  inherited;

  // postato: l'azione apre a sua volta un dialogo modale, che deve partire
  // a finestra gia' mostrata e non dentro la sua comparsa
  if Assigned(AzioneIniziale) then
    PostMessage(Handle, WM_ESEGUI_AZIONE_INIZIALE, 0, 0);
end;

procedure TzMemoForm.EseguiAzioneIniziale(var Message: TMessage);
var
  Azione: TBasicAction;
begin
  Azione := AzioneIniziale;
  AzioneIniziale := nil;

  if Assigned(Azione) then
    Azione.Execute;
end;

procedure TzMemoForm.FileOpenAccept(Sender: TObject);
var
  CodificaUtf8: TEncoding;
begin
  // DIV-MDG-2: il BOM decide se c'e'; senza BOM si prova UTF-8 rigoroso e, se il
  // file non e' UTF-8 valido, si ricade sulla tabella ANSI del sistema
  CodificaUtf8 := TUTF8Encoding.Create(CP_UTF8, MB_ERR_INVALID_CHARS, 0);
  try
    try
      cxMemo.Lines.LoadFromFile(FileOpen.Dialog.FileName, CodificaUtf8);
    except
      on EEncodingError do
        cxMemo.Lines.LoadFromFile(FileOpen.Dialog.FileName);
    end;
  finally
    CodificaUtf8.Free;
  end;
end;

procedure TzMemoForm.FileSaveAsAccept(Sender: TObject);
var
  CodificaUtf8: TEncoding;
begin
  // DIV-MDG-2: UTF-8 senza BOM, cosi' i caratteri fuori dalla tabella ANSI si conservano
  CodificaUtf8 := TUTF8Encoding.Create(False);
  try
    cxMemo.Lines.SaveToFile(FileSaveAs.Dialog.FileName, CodificaUtf8);
  finally
    CodificaUtf8.Free;
  end;
end;

constructor TzMemoDialog.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FLines := TStringlist.Create;
end;

destructor TzMemoDialog.Destroy;
begin
  FreeAndNil(FLines);
  inherited Destroy;
end;

procedure TzMemoDialog.SetCaption(Value: String);
begin
  FCaption := Value;
end;

function TzMemoDialog.Execute(cxMemo: TcxCustomMemo = nil; CustomActions: TArray < TBasicAction >= nil; ImageList: TCustomImageList = nil): boolean;
begin
  DoInitDialog;

  zMemoForm := TzMemoForm.Create(Nil);
  try
    // zMemoForm.cxMemo.Lines.Assign(Lines);  // no, sformatta: usare .Text
    zMemoForm.cxMemo.Text := Lines.Text;

    Result := zMemoForm.Execute(cxMemo, CustomActions, ImageList);

    if Result then
      Lines.Text := zMemoForm.cxMemo.Text;
  finally
    FreeAndNil(zMemoForm);
  end;

  DoCloseDialog;
end;

Procedure TzMemoDialog.DoInitDialog;
begin
  if Assigned(FOnInitDialog) then
    OnInitDialog(Self);
end;

Procedure TzMemoDialog.DoCloseDialog;
begin
  if Assigned(FOnCloseDialog) then
    OnCloseDialog(Self);
end;

procedure TzMemoDialog.SetLines(Value: TStrings);
begin
  FLines.Assign(Value);
end;

procedure TzMemoForm.InitCustomActions(CustomActions: TArray<TBasicAction>; ImageList: TCustomImageList);
var
  basicAction: TBasicAction;
  Action: TAction;
  btn: TdxBarButton;
  link: TdxBarItemLink;
  idx: Integer;
begin

  if Assigned(CustomActions) then
  begin
    idx := 0;

    dxBarManagerBarFree.Images := ImageList;

    // !!!!!!!!!!!!
    for basicAction in CustomActions do
    begin
      basicAction.Tag := NativeInt(cxMemo);

      btn := TdxBarButton.Create(dxBarManager);
      btn.BarManager := dxBarManager;

      btn.PaintStyle := psCaptionGlyph;
      btn.Action := basicAction;

      if basicAction is TAction then
      begin
        Action := TAction(basicAction);

        if Action.AutoCheck then
        begin
          btn.ButtonStyle := bsChecked;
          btn.Down := Action.Checked;
        end;
      end;

      link := dxBarManagerBarFree.ItemLinks.Add(btn);
      link.BeginGroup := idx = 0;
      link := dxBarPopupMenu.ItemLinks.Add(btn);
      link.BeginGroup := idx = 0;
      link.index := idx;
      Inc(idx);
    end;
  end;
end;

procedure TzMemoForm.TrovaExecute(Sender: TObject);
begin
  FindReplaceHelper.ExecuteFind;
end;

procedure TzMemoForm.SostituisciExecute(Sender: TObject);
begin
  FindReplaceHelper.ExecuteReplace;
end;

procedure TzMemoForm.SostituisciUpdate(Sender: TObject);
begin
  Sostituisci.Enabled := not cxMemo.Properties.ReadOnly;
end;

procedure TzMemoForm.SuccessivoExecute(Sender: TObject);
begin
  FindReplaceHelper.FindNext;
end;

end.
