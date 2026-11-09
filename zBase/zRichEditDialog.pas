unit zRichEditDialog;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  System.Actions,
  Vcl.ActnList,
  cxTextEdit,
  cxMemo,
  cxRichEdit,
  OkCancel,
  dxActions,
  dxPrinting,
  cxClasses,
  dxBar,
  System.ImageList,
  Vcl.ImgList,
  cxImageList,
  dxRibbonForm,
  Vcl.StdActns,
  Vcl.ExtActns,
  dxColorEdit,
  cxFontNameComboBox,
  cxSpinEdit,
  cxBarEditItem,
  dxFileActions;

type
  TzRichEditForm = class(TdxRibbonForm)
    cxRichEdit: TcxRichEdit;
    OkCancel: TOkCancel;
    dxBarPopupMenu: TdxBarPopupMenu;
    dxBarManager: TdxBarManager;
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
    ActionList: TActionList;
    FileOpen: TdxFileOpen;
    FileSaveAs: TdxFileSaveAs;
    EditUndo: TAction;
    EditCut: TAction;
    EditCopy: TAction;
    EditPaste: TAction;
    EditDelete: TAction;
    EditSelectAll: TAction;
    FormatRichEditBold: TRichEditBold;
    FormatRichEditItalic: TRichEditItalic;
    FormatRichEditUnderline: TRichEditUnderline;
    FormatRichEditStrikeOut: TRichEditStrikeOut;
    FormatRichEditBullets: TRichEditBullets;
    FormatRichEditAlignLeft: TRichEditAlignLeft;
    FormatRichEditAlignRight: TRichEditAlignRight;
    FormatRichEditAlignCenter: TRichEditAlignCenter;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    dxBarButton15: TdxBarButton;
    dxBarButton16: TdxBarButton;
    dxBarButton17: TdxBarButton;
    dxBarButton18: TdxBarButton;
    dxBarEdit1: TdxBarEdit;
    cxBarEditItemFontColor: TcxBarEditItem;
    cxBarEditItemFontName: TcxBarEditItem;
    cxBarEditItemFontSize: TcxBarEditItem;
    Justify: TAction;
    dxBarButton19: TdxBarButton;
    dxBarButton20: TdxBarButton;
    Numerazione: TAction;
    dxBarButton21: TdxBarButton;
    dxBarButton22: TdxBarButton;
    Paragrafo: TAction;
    procedure EditCopyExecute(Sender: TObject);
    procedure EditCutExecute(Sender: TObject);
    procedure EditDeleteExecute(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure EditSelectAllExecute(Sender: TObject);
    procedure EditUndoExecute(Sender: TObject);
    procedure FileOpenAccept(Sender: TObject);
    procedure FileSaveAsAccept(Sender: TObject);
    procedure cxRichEditPropertiesSelectionChange(Sender: TObject);
    procedure FormatRichEditBoldUpdate(Sender: TObject);
    procedure cxBarEditItemFontNamePropertiesEditValueChanged(Sender: TObject);
    procedure cxBarEditItemFontSizePropertiesEditValueChanged(Sender: TObject);
    procedure cxBarEditItemFontColorPropertiesCloseUp(Sender: TObject);
    procedure FormatRichEditAlignCenterUpdate(Sender: TObject);
    procedure FormatRichEditAlignLeftUpdate(Sender: TObject);
    procedure FormatRichEditAlignRightUpdate(Sender: TObject);
    procedure FormatRichEditBulletsUpdate(Sender: TObject);
    procedure FormatRichEditItalicUpdate(Sender: TObject);
    procedure FormatRichEditStrikeOutUpdate(Sender: TObject);
    procedure FormatRichEditUnderlineUpdate(Sender: TObject);
    procedure JustifyExecute(Sender: TObject);
    procedure JustifyUpdate(Sender: TObject);
    procedure NumerazioneExecute(Sender: TObject);
    procedure NumerazioneUpdate(Sender: TObject);
    procedure ParagrafoExecute(Sender: TObject);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    function Execute(aRichEdit: TcxCustomRichEdit = nil): boolean;
  end;

  TzRichEditDialog = class(TComponent)
  private
    FCaption: String;
    FOnInitDialog: TNotifyEvent;
    FOnCloseDialog: TNotifyEvent;
    FLines: TStrings;
    procedure SetLines(Value: TStrings);
  protected
    zRichEditForm: TzRichEditForm;
    procedure SetCaption(Value: String);
    procedure DoInitDialog;
    procedure DoCloseDialog;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(cxRichEdit: TcxCustomRichEdit = nil): boolean;
  published
    property Caption: string read FCaption write SetCaption;
    property Lines: TStrings read FLines write SetLines;

    property OnInitDialog: TNotifyEvent read FOnInitDialog write FOnInitDialog;
    property OnCloseDialog: TNotifyEvent read FOnCloseDialog write FOnCloseDialog;
  end;

function zExecuteRichEditDialog(cxRichEdit: TcxCustomRichEdit; const Caption: string = ''): boolean; overload;
function zExecuteRichEditDialog(Lines: TStrings; const Caption: string = ''): boolean; overload;
function zExecuteRichEditDialog(var Text: String; const Caption: string = ''): boolean; overload;

implementation

uses
  Vcl.ComCtrls,
  cxRichEditUtils,
  zRichEditDialog.Paragraph,
  zDX;

{$R *.dfm}

function zExecuteRichEditDialog(cxRichEdit: TcxCustomRichEdit; const Caption: string = ''): boolean;
var
  zRichEditForm: TzRichEditForm;
begin
  zRichEditForm := TzRichEditForm.Create(Nil);
  try
    zRichEditForm.Caption := Caption;

    Result := zRichEditForm.Execute(cxRichEdit);

    if Result then
      if Assigned(cxRichEdit) then
      begin
        cxRichEdit.EditValue := zRichEditForm.cxRichEdit.EditValue;
        cxRichEdit.PostEditValue;
      end;
  finally
    FreeAndNil(zRichEditForm);
  end;
end;

function zExecuteRichEditDialog(Lines: TStrings; const Caption: string = ''): boolean;
var
  zRichEditForm: TzRichEditForm;
begin
  zRichEditForm := TzRichEditForm.Create(Nil);
  try
    zRichEditForm.Caption := Caption;
    zRichEditForm.cxRichEdit.Lines.Assign(Lines);

    Result := zRichEditForm.Execute(nil);

    if Result then
      if Assigned(Lines) then
        Lines.Assign(zRichEditForm.cxRichEdit.Lines);
  finally
    FreeAndNil(zRichEditForm);
  end;
end;

function zExecuteRichEditDialog(var Text: String; const Caption: string = ''): boolean;
var
  zRichEditForm: TzRichEditForm;
begin
  zRichEditForm := TzRichEditForm.Create(Nil);
  try
    zRichEditForm.Caption := Caption;
    zRichEditForm.cxRichEdit.Lines.Text := Text;

    Result := zRichEditForm.Execute(nil);

    if Result then
      Text := zRichEditForm.cxRichEdit.Lines.Text;
  finally
    FreeAndNil(zRichEditForm);
  end;
end;

constructor TzRichEditForm.Create(AOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
end;

procedure TzRichEditForm.EditCopyExecute(Sender: TObject);
begin
  cxRichEdit.CopyToClipboard;
end;

procedure TzRichEditForm.EditCutExecute(Sender: TObject);
begin
  cxRichEdit.CutToClipboard;
end;

procedure TzRichEditForm.EditDeleteExecute(Sender: TObject);
begin
  cxRichEdit.ClearSelection;
end;

procedure TzRichEditForm.EditPasteExecute(Sender: TObject);
begin
  cxRichEdit.PasteFromClipboard;
end;

procedure TzRichEditForm.EditSelectAllExecute(Sender: TObject);
begin
  cxRichEdit.SelectAll;
end;

procedure TzRichEditForm.EditUndoExecute(Sender: TObject);
begin
  cxRichEdit.Undo;
end;

function TzRichEditForm.Execute(aRichEdit: TcxCustomRichEdit = nil): boolean;
begin

  if Assigned(aRichEdit) then
  begin
    // zz 01.10.2019 eliminabile, vedi la proc
    // procedure TcxCustomRichEditProperties.DoAssign
    cxRichEdit.Properties.Assign(aRichEdit.Properties);
    cxRichEdit.EditValue := aRichEdit.EditValue;
  end;

  // vedi assign sopra
  cxRichEdit.Properties.OnSelectionChange := cxRichEditPropertiesSelectionChange;
  cxRichEditPropertiesSelectionChange(nil);

  Result := ShowModal = mrOk;
end;

procedure TzRichEditForm.FileOpenAccept(Sender: TObject);
begin
  cxRichEdit.Lines.LoadFromFile(FileOpen.Dialog.FileName);
end;

procedure TzRichEditForm.FileSaveAsAccept(Sender: TObject);
begin
  cxRichEdit.Lines.SaveToFile(FileSaveAs.Dialog.FileName);
end;

procedure TzRichEditForm.FormatRichEditBoldUpdate(Sender: TObject);
begin
  FormatRichEditBold.Checked := fsBold in cxRichEdit.SelAttributes.Style;
end;

constructor TzRichEditDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLines := TStringlist.Create;
end;

destructor TzRichEditDialog.Destroy;
begin
  FreeAndNil(FLines);
  inherited Destroy;
end;

procedure TzRichEditDialog.SetCaption(Value: String);
begin
  FCaption := Value;
end;

function TzRichEditDialog.Execute(cxRichEdit: TcxCustomRichEdit = nil): boolean;
begin
  DoInitDialog;

  zRichEditForm := TzRichEditForm.Create(Nil);
  try
    zRichEditForm.cxRichEdit.Lines.Assign(Lines);

    Result := zRichEditForm.Execute(cxRichEdit);

    if Result then
      Lines.Assign(zRichEditForm.cxRichEdit.Lines);

  finally
    FreeAndNil(zRichEditForm);
  end;

  DoCloseDialog;
end;

Procedure TzRichEditDialog.DoInitDialog;
begin
  if Assigned(FOnInitDialog) then
    OnInitDialog(Self);
end;

Procedure TzRichEditDialog.DoCloseDialog;
begin
  if Assigned(FOnCloseDialog) then
    OnCloseDialog(Self);
end;

procedure TzRichEditDialog.SetLines(Value: TStrings);
begin
  FLines.Assign(Value);
end;

procedure TzRichEditForm.cxRichEditPropertiesSelectionChange(Sender: TObject);
begin
  cxBarEditItemFontName.EditValue := cxRichEdit.SelAttributes.Name;
  cxBarEditItemFontSize.EditValue := cxRichEdit.SelAttributes.Size;
  cxBarEditItemFontColor.EditValue := cxRichEdit.SelAttributes.Color;
end;

procedure TzRichEditForm.cxBarEditItemFontNamePropertiesEditValueChanged(Sender: TObject);
begin
  cxRichEdit.SelAttributes.Name := cxBarEditItemFontName.EditValue;
end;

procedure TzRichEditForm.cxBarEditItemFontSizePropertiesEditValueChanged(Sender: TObject);
begin
  cxRichEdit.SelAttributes.Size := cxBarEditItemFontSize.EditValue;
end;

procedure TzRichEditForm.cxBarEditItemFontColorPropertiesCloseUp(Sender: TObject);
begin
  cxRichEdit.SelAttributes.Color := cxBarEditItemFontColor.EditValue;
end;

procedure TzRichEditForm.FormatRichEditAlignCenterUpdate(Sender: TObject);
begin
  FormatRichEditAlignCenter.Checked := cxRichEdit.Paragraph.Alignment = taCenter;
end;

procedure TzRichEditForm.FormatRichEditAlignLeftUpdate(Sender: TObject);
begin
  FormatRichEditAlignLeft.Checked := cxRichEdit.Paragraph.Alignment = taLeftJustify;
end;

procedure TzRichEditForm.FormatRichEditAlignRightUpdate(Sender: TObject);
begin
  FormatRichEditAlignRight.Checked := cxRichEdit.Paragraph.Alignment = taRightJustify;
end;

procedure TzRichEditForm.JustifyExecute(Sender: TObject);
begin
  cxRichEdit.Paragraph2.Alignment := pfaJustify;
end;

procedure TzRichEditForm.JustifyUpdate(Sender: TObject);
begin
  Justify.Checked := cxRichEdit.Paragraph2.Alignment = pfaJustify;
end;

procedure TzRichEditForm.FormatRichEditBulletsUpdate(Sender: TObject);
begin
  FormatRichEditBullets.Checked := cxRichEdit.Paragraph.Numbering = nsBullet;
end;

procedure TzRichEditForm.FormatRichEditItalicUpdate(Sender: TObject);
begin
  FormatRichEditItalic.Checked := fsItalic in cxRichEdit.SelAttributes.Style;
end;

procedure TzRichEditForm.FormatRichEditStrikeOutUpdate(Sender: TObject);
begin
  FormatRichEditStrikeOut.Checked := fsStrikeOut in cxRichEdit.SelAttributes.Style;
end;

procedure TzRichEditForm.FormatRichEditUnderlineUpdate(Sender: TObject);
begin
  FormatRichEditBold.Checked := fsBold in cxRichEdit.SelAttributes.Style;
end;

procedure TzRichEditForm.NumerazioneExecute(Sender: TObject);
begin
  if cxRichEdit.Paragraph2.NumberingType = pfnNone then
    cxRichEdit.Paragraph2.NumberingType := pfnNumber
  else
    cxRichEdit.Paragraph2.NumberingType := pfnNone;
end;

procedure TzRichEditForm.NumerazioneUpdate(Sender: TObject);
begin
  Numerazione.Checked := cxRichEdit.Paragraph2.NumberingType = pfnNumber;
end;

procedure TzRichEditForm.ParagrafoExecute(Sender: TObject);
begin
  EditRichEditParagraph(cxRichEdit);
end;

end.
