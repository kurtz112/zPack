unit zExceptions.form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdActns,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.ActnList,
  Vcl.StdCtrls,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxCustomData,
  cxStyles,
  dxScrollbarAnnotations,
  cxTL,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxClasses,
  dxLayoutContainer,
  dxLayoutControl,
  dxLayoutControlAdapters,
  cxTextEdit,
  cxSpinEdit,
  cxImageList,
  cxButtons,
  dxLayoutcxEditAdapters,
  cxContainer,
  cxEdit,
  cxMemo,
  zExceptions,
  zCollection,
  dxLayoutLookAndFeels,
  dxFileActions,
  dxShellDialogs,
  cxFilter,
  dxForms;

type
  TzExceptionDetailForm = class(TdxForm)
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    treeStack: TcxTreeList;
    dxLayoutItemStack: TdxLayoutItem;
    btnSalva: TcxButton;
    btnOk: TcxButton;
    ActionList: TActionList;
    dxLayoutItemSaveLog: TdxLayoutItem;
    dxLayoutItemOk: TdxLayoutItem;
    dxLayoutGroupButtons: TdxLayoutGroup;
    dxLayoutEmptySpaceItem1: TdxLayoutEmptySpaceItem;
    stackCallAddress: TcxTreeListColumn;
    stackBaseName: TcxTreeListColumn;
    stackUnitName: TcxTreeListColumn;
    stackSourceFile: TcxTreeListColumn;
    stackSymbolName: TcxTreeListColumn;
    stackLineNumber: TcxTreeListColumn;
    stackRelLineNumber: TcxTreeListColumn;
    memoErrorMessage: TcxMemo;
    dxLayoutItemErrorMessage: TdxLayoutItem;
    dxLayoutSplitterItem1: TdxLayoutSplitterItem;
    dxLayoutItemSQLCode: TdxLayoutItem;
    edSQLCode: TcxTextEdit;
    dxLayoutItemSQLState: TdxLayoutItem;
    edSQLState: TcxTextEdit;
    dxLayoutItemSQLMessage: TdxLayoutItem;
    edSQLMessage: TcxTextEdit;
    dxLayoutItemIBErrorCode: TdxLayoutItem;
    edIBErrorCode: TcxTextEdit;
    dxLayoutItemIBMessage: TdxLayoutItem;
    dxLayoutGroupFIB: TdxLayoutGroup;
    dxLayoutGroupIBError: TdxLayoutGroup;
    dxLayoutGroupSQL: TdxLayoutGroup;
    dxLayoutGroupMessage: TdxLayoutGroup;
    memoIBMessage: TcxMemo;
    Salva: TdxFileSaveAs;
    dxLayoutEmptySpaceItem2: TdxLayoutEmptySpaceItem;
    dxLayoutGroupStack: TdxLayoutGroup;
    dxLayoutGroupEccezione: TdxLayoutGroup;
    dxLayoutLookAndFeelList: TdxLayoutLookAndFeelList;
    dxLayoutSkinLookAndFeel: TdxLayoutSkinLookAndFeel;
    Invia: TAction;
    btnMail: TcxButton;
    dxLayoutItemInviaMail: TdxLayoutItem;
    Copia: TAction;
    btnCopia: TcxButton;
    dxLayoutItemCopia: TdxLayoutItem;
    edDatamodule: TcxTextEdit;
    edDataset: TcxTextEdit;
    dxLayoutItemDatamodule: TdxLayoutItem;
    dxLayoutItemDataset: TdxLayoutItem;
    dxLayoutGroupDataset: TdxLayoutGroup;
    ModificaDataSet: TAction;
    btnModificaDataSet: TcxButton;
    dxLayoutItemModificaDataSet: TdxLayoutItem;
    RichiestaAssistenza: TAction;
    btnRichiestaAssistenza: TcxButton;
    dxLayoutItemRichiestaAssistenza: TdxLayoutItem;
    procedure CopiaExecute(Sender: TObject);
    procedure RichiestaAssistenzaExecute(Sender: TObject);
    procedure dxLayoutGroupFIBButton0Click(Sender: TObject);
    procedure dxLayoutGroupStackButton0Click(Sender: TObject);
    procedure InviaExecute(Sender: TObject);
    procedure SalvaAccept(Sender: TObject);
    procedure SalvaBeforeExecute(Sender: TObject);
    procedure ModificaDataSetExecute(Sender: TObject);
  private
    zExceptionManager: TzExceptionManager;
    procedure DisplayException;
    procedure LoadStack;
    procedure ResizeIbMessage;
    // True solo per un amministratore dell'LZ con i privilegi attivi
    // (TzSystem.IsAdmin tiene gia' conto di IsAdminDisabled). False anche
    // quando l'LZ non e' caricato.
    function UtenteAmministratore: boolean;
    // Voce dell'LZ del dataset che ha generato l'errore, oppure nil quando
    // non c'e' niente da aprire: utente non amministratore, LZ non caricato,
    // errore che non nasce da un dataset dell'LZ.
    function FailedDataSetItem: TzCollectionItem;
    // Allinea il comando al ticket eventualmente gia' aperto per l'errore.
    procedure AggiornaRichiestaAssistenza;
  public
    constructor Create(aOwner: TComponent); override;
    procedure ShowExceptionDetails(aExceptionManager: TzExceptionManager);
  end;

procedure ShowExceptionDetails(aExceptionManager: TzExceptionManager);

implementation

uses
  Vcl.Clipbrd,
  zExceptions.stack,
  zOffice,
  zMsg,
  // Scorciatoia all'editor del dataset che ha fallito: zSystem per l'LZ
  // (Base, zDataSets, IsAdmin, SaveZip), zz.base.editor._form per l'editor.
  // Sono dipendenze di sola implementazione: l'interfaccia di questa unit
  // resta indipendente dall'LZ.
  zSystem,
  zz.base.editor._form,
  zDX;

{$R *.dfm}

type
  TcxHackTreeList = class(TcxCustomTreeList);

procedure ShowExceptionDetails(aExceptionManager: TzExceptionManager);
var
  zExceptionDetailForm: TzExceptionDetailForm;
begin

  Application.CreateForm(TzExceptionDetailForm, zExceptionDetailForm);
  try
    zExceptionDetailForm.ShowExceptionDetails(aExceptionManager);
  finally
    FreeAndNil(zExceptionDetailForm);
  end;
end;

{ TzExceptionDetailForm }

constructor TzExceptionDetailForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  zExceptionManager := nil;

  dxLayoutControl.OptionsStoring.StoreToIniFile := False;
  dxLayoutControl.OptionsItem.AutoControlAreaAlignment := True;
  dxLayoutControl.OptionsItem.AutoControlTabOrders := True;
  dxLayoutControl.OptionsItem.FocusControlOnItemCaptionClick := True;
  dxLayoutControl.OptionsItem.SizableHorz := True;
  dxLayoutControl.OptionsItem.SizableVert := True;
  dxLayoutControl.BevelInner := bvNone;
  dxLayoutControl.BevelOuter := bvNone;

  treeStack.BorderStyle := cxcbsNone;
  treeStack.LookAndFeel.Kind := lfFlat;
  treeStack.OptionsSelection.HideFocusRect := False;

  // Stessa didascalia del pulsante del messaggio d'errore: la costante sta in
  // zExceptions perche' il testo non diverga fra i due punti.
  RichiestaAssistenza.Caption := CaptionRichiestaAssistenza;
end;

procedure TzExceptionDetailForm.LoadStack;
var
  node: TcxTreeListNode;
  item: TCallStackItem;
begin

  treeStack.BeginUpdate;
  try
    treeStack.Clear;

    for item in zExceptionManager.stack do
    begin
      node := treeStack.Root.AddChild;

      node.Values[0] := item.SymbolName;
      node.Values[1] := item.LineNumber;
      node.Values[2] := item.RelLineNumber;
      node.Values[3] := item.UnitName;
      node.Values[4] := item.SourceFile;
      node.Values[5] := item.BaseName;
      node.Values[6] := item.CallAddress;
    end;
  finally
    treeStack.EndUpdate;
  end;
end;

procedure TzExceptionDetailForm.DisplayException;
begin
  memoErrorMessage.Lines.Text := zExceptionManager.ErrorMessage;

  dxLayoutGroupFIB.Visible := zExceptionManager.IsFIBError;

  if zExceptionManager.IsFIBError then
  begin
    memoIBMessage.Lines.Text := zExceptionManager.IBMessage;

    edIBErrorCode.Text := zExceptionManager.IBErrorCode.ToString;
    edSQLMessage.Text := zExceptionManager.SQLMessage;
    edSQLState.Text := zExceptionManager.SQLState;
    edSQLCode.Text := zExceptionManager.SQLCode.ToString;
  end;

  // Dataset che ha generato l'errore. Si leggono dal manager, non dalle
  // variabili "one-shot" di zExceptions.context: quelle sono gia' state
  // consumate dal log automatico che ShowException scrive prima di aprire
  // questa form.
  edDatamodule.Text := zExceptionManager.FailedDataSetDataModuleName;
  edDataset.Text := zExceptionManager.FailedDataSetName;

  ResizeIbMessage;
  LoadStack;
end;

procedure TzExceptionDetailForm.ResizeIbMessage;
var
  i: integer;
begin
  i := memoIBMessage.Lines.Count + 1;
  if i < 5 then
    i := 5
  else
    if i > 15 then
      i := 15;
  memoIBMessage.Properties.VisibleLineCount := i;
end;

procedure TzExceptionDetailForm.SalvaAccept(Sender: TObject);
begin
  zExceptionManager.LogException(Salva.Dialog.FileName);
end;

procedure TzExceptionDetailForm.SalvaBeforeExecute(Sender: TObject);
begin
  Salva.Dialog.DefaultExt := zExceptionManager.LogExtension;
  Salva.Dialog.Filter := 'Log|*' + zExceptionManager.LogExtension + '|Tutti|*.*';
end;

procedure TzExceptionDetailForm.ShowExceptionDetails(aExceptionManager: TzExceptionManager);
begin
  zExceptionManager := aExceptionManager;
  DisplayException;

  dxLayoutItemInviaMail.Visible := SMTPServerParams.IsValid;

  dxLayoutItemRichiestaAssistenza.Visible := zExceptionManager.RichiestaAssistenzaDisponibile;
  AggiornaRichiestaAssistenza;

  // La scorciatoia all'editor si mostra solo a chi puo' davvero correggere
  // l'LZ e solo quando il dataset responsabile e' stato identificato: fuori
  // da questi due casi il pulsante sparisce invece di aprire un editor vuoto.
  // Si spegne anche l'azione, non solo la voce del layout: un'azione nascosta
  // ma abilitata resta eseguibile da una scorciatoia di tastiera.
  ModificaDataSet.Visible := (FailedDataSetItem <> nil);
  ModificaDataSet.Enabled := ModificaDataSet.Visible;
  dxLayoutItemModificaDataSet.Visible := ModificaDataSet.Visible;

  ShowModal;
end;

procedure TzExceptionDetailForm.AggiornaRichiestaAssistenza;
begin
  RichiestaAssistenza.Enabled := (zExceptionManager.TicketId = 0);
  if zExceptionManager.TicketId > 0 then
    RichiestaAssistenza.Hint := Format('Richiesta di assistenza gia'' aperta: n. %d', [zExceptionManager.TicketId])
  else
    RichiestaAssistenza.Hint := 'Apre una richiesta all''assistenza allegando log e immagine dello schermo';
end;

procedure TzExceptionDetailForm.RichiestaAssistenzaExecute(Sender: TObject);
begin
  zExceptionManager.RichiediAssistenza;
  AggiornaRichiestaAssistenza;
end;

procedure TzExceptionDetailForm.dxLayoutGroupFIBButton0Click(Sender: TObject);
begin
  Clipboard.AsText := memoIBMessage.Lines.Text;
  ConfirmOk('Messaggio di errore copiato nella clipboard.');
end;

procedure TzExceptionDetailForm.dxLayoutGroupStackButton0Click(Sender: TObject);
begin
  treeStack.CopyAllToClipboard;
  ConfirmOk('Stack di errore copiato nella clipboard.');
end;

procedure TzExceptionDetailForm.InviaExecute(Sender: TObject);
begin
  zExceptionManager.InviaMail;
end;

function TzExceptionDetailForm.UtenteAmministratore: boolean;
begin
  // Base e' il TzSystem dell'applicazione: e' nil nei processi che questa
  // form la usano senza avere caricato l'LZ.
  result := Assigned(base) and base.IsAdmin;
end;

function TzExceptionDetailForm.FailedDataSetItem: TzCollectionItem;
var
  Idx: integer;
  Id: string;
begin
  result := nil;

  if not Assigned(zExceptionManager) then
    Exit;

  if not UtenteAmministratore then
    Exit;

  // Identificativo LZ (NomeDataModule.NomeDataSet) catturato da
  // zExceptions.firedac al momento dell'errore. Vuoto se l'errore non nasce
  // da un dataset dell'LZ.
  Id := Trim(zExceptionManager.FailedDataSetId);
  if Id = '' then
    Exit;

  Idx := base.zDataSets.IndexOf(Id);
  if Idx = -1 then
    Exit;

  result := base.zDataSets[Idx];
end;

procedure TzExceptionDetailForm.ModificaDataSetExecute(Sender: TObject);
var
  item: TzCollectionItem;
begin
  // Controllo ripetuto al momento dell'esecuzione, non solo all'apertura
  // della form: e' questo il punto che scrive l'LZ e lo salva su disco.
  if not UtenteAmministratore then
    Exit;

  item := FailedDataSetItem;
  if not Assigned(item) then
    Exit;

  if not Edit_CollectionItem(base, item) then
    Exit;

  // Stesso salvataggio che fa TzSystem.DataSetEditProps dopo la stessa
  // chiamata: qui non c'e' nessuna form dell'LZ aperta che salvi a sua volta,
  // quindi senza questa riga la correzione resterebbe solo in memoria e si
  // perderebbe alla chiusura dell'applicazione.
  base.SaveZip(csDataSets, 'zExceptionDetailForm.ModificaDataSet');

  ConfirmOk('Dataset aggiornato.' + sLineBreak + sLineBreak + 'La nuova SELECT viene usata alla prossima apertura della finestra che ha generato l''errore.');
end;

procedure TzExceptionDetailForm.CopiaExecute(Sender: TObject);
var
  s, stack: String;
begin
  s := zExceptionManager.ErrorMessage;

  // Dataset responsabile: e' la prima cosa che serve a chi deve correggere,
  // e prima veniva perso nel testo copiato.
  if zExceptionManager.FailedDataSetName <> '' then
  begin
    s := s + sLineBreak + sLineBreak;
    s := s + 'DataModule: ' + zExceptionManager.FailedDataSetDataModuleName + sLineBreak;
    s := s + 'Dataset: ' + zExceptionManager.FailedDataSetName;
  end;

  // FB
  if zExceptionManager.IsFIBError then
  begin
    s := s + sLineBreak + sLineBreak + zExceptionManager.IBMessage + sLineBreak;
    s := s + 'IBErrorCode: ' + zExceptionManager.IBErrorCode.ToString + sLineBreak;
    s := s + 'SQLMessage: ' + zExceptionManager.SQLMessage + sLineBreak;
    s := s + 'SQLState: ' + zExceptionManager.SQLState + sLineBreak;
    s := s + 'SQLCode: ' + zExceptionManager.SQLCode.ToString + sLineBreak;
  end;

  // Stack
  TcxHackTreeList(treeStack).DoWriteToText(False, stack, False);

  s := s + sLineBreak + sLineBreak;
  s := s + 'Stack:' + sLineBreak + stack;
  //

  Clipboard.AsText := s;
  // Stessa conferma dei pulsanti di copia dei gruppi DB e Stack: senza,
  // l'utente non sa se il clic ha avuto effetto.
  ConfirmOk('Dettagli dell''errore copiati negli appunti.');
end;

end.
