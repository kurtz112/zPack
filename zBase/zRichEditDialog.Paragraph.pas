unit zRichEditDialog.Paragraph;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  cxRichEdit,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  dxLayoutContainer,
  dxLayoutControlAdapters,
  cxClasses,
  dxLayoutControl,
  cxContainer,
  cxEdit,
  dxLayoutcxEditAdapters,
  cxTextEdit,
  cxMaskEdit,
  cxDropDownEdit,
  cxDBEdit,
  Vcl.Menus,
  cxButtons,
  cxSpinEdit,
  cxStyles;

type
  TzRichEditParagraphDialog = class(TForm)
    OKBtn: TcxButton;
    CancelBtn: TcxButton;
    comboAlignment: TcxComboBox;
    edLeftIndent: TcxSpinEdit;
    edRightIndent: TcxSpinEdit;
    edFirstIndent: TcxSpinEdit;
    edAfterParagraph: TcxSpinEdit;
    edBeforeParagraph: TcxSpinEdit;
    edLineSpacing: TcxSpinEdit;
    comboLineSpacingRule: TcxComboBox;
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    dxLayoutItemAllineamento: TdxLayoutItem;
    dxLayoutItemStotto: TdxLayoutItem;
    dxLayoutItemSopra: TdxLayoutItem;
    dxLayoutItemSpaziaturaTipoInterlinea: TdxLayoutItem;
    dxLayoutItemSpaziaturaInterlinea: TdxLayoutItem;
    dxLayoutItemOk: TdxLayoutItem;
    dxLayoutItemAnnulla: TdxLayoutItem;
    dxLayoutItemRientroSX: TdxLayoutItem;
    dxLayoutItemRientroDX: TdxLayoutItem;
    dxLayoutItemRientroPrimaRiga: TdxLayoutItem;
    dxLayoutGroupRientri: TdxLayoutGroup;
    dxLayoutGroupBottoni: TdxLayoutGroup;
    dxLayoutGroupSpaziatura: TdxLayoutGroup;
    dxLayoutGroupDistanza: TdxLayoutGroup;
    dxLayoutGroupAllineamento: TdxLayoutGroup;
    dxLayoutGroupImpostazioni: TdxLayoutGroup;
    btnApplica: TcxButton;
    dxLayoutItemApplica: TdxLayoutItem;
    procedure edLineSpacingPropertiesEditValueChanged(Sender: TObject);
    procedure comboLineSpacingRulePropertiesEditValueChanged(Sender: TObject);
    procedure btnApplicaClick(Sender: TObject);
  private
    cxRichEdit: TcxRichEdit;
    procedure Load;
    procedure Save;
  public
    function Edit(RichEdit: TcxRichEdit): boolean;
  end;

var
  zRichEditParagraphDialog: TzRichEditParagraphDialog;

Function EditRichEditParagraph(cxRichEdit: TcxRichEdit): boolean;

implementation

uses
  cxRichEditUtils;

{$R *.DFM}

Function EditRichEditParagraph(cxRichEdit: TcxRichEdit): boolean;
var
  zRichEditParagraphDialog: TzRichEditParagraphDialog;
begin
  Application.CreateForm(TzRichEditParagraphDialog, zRichEditParagraphDialog);
  try
    result := zRichEditParagraphDialog.Edit(cxRichEdit);
  finally
    FreeAndNil(zRichEditParagraphDialog);
  end;
end;

function TzRichEditParagraphDialog.Edit(RichEdit: TcxRichEdit): boolean;
begin
  cxRichEdit := RichEdit;

  Load;
  result := ShowModal = mrOK;

  if result then
    Save;
end;

procedure TzRichEditParagraphDialog.Load;
begin
  edLeftIndent.Value := cxRichEdit.Paragraph.LeftIndent;
  edRightIndent.Value := cxRichEdit.Paragraph.RightIndent;
  edFirstIndent.Value := cxRichEdit.Paragraph.FirstIndent;

  edBeforeParagraph.Value := cxRichEdit.Paragraph2.SpaceBefore;
  edAfterParagraph.Value := cxRichEdit.Paragraph2.SpaceAfter;

  comboLineSpacingRule.ItemIndex := ord(cxRichEdit.Paragraph2.LineSpacingRule);
  edLineSpacing.Value := cxRichEdit.Paragraph2.LineSpacing;

  comboAlignment.ItemIndex := ord(cxRichEdit.Paragraph.Alignment);
end;

procedure TzRichEditParagraphDialog.Save;
begin
  cxRichEdit.Paragraph.LeftIndent := edLeftIndent.Value;
  cxRichEdit.Paragraph.RightIndent := edRightIndent.Value;
  cxRichEdit.Paragraph.FirstIndent := edFirstIndent.Value;

  cxRichEdit.Paragraph2.SpaceBefore := edBeforeParagraph.Value;
  cxRichEdit.Paragraph2.SpaceAfter := edAfterParagraph.Value;

  cxRichEdit.Paragraph2.LineSpacingRule := TcxParaFormat2LineSpacingRule(comboLineSpacingRule.ItemIndex);
  cxRichEdit.Paragraph2.LineSpacing := edLineSpacing.Value;

  cxRichEdit.Paragraph.Alignment := TAlignment(comboAlignment.ItemIndex);
end;

procedure TzRichEditParagraphDialog.edLineSpacingPropertiesEditValueChanged(Sender: TObject);
begin
  if edLineSpacing.Value <> 0 then
    comboLineSpacingRule.ItemIndex := 3;
end;

procedure TzRichEditParagraphDialog.btnApplicaClick(Sender: TObject);
begin
  Save;
end;

procedure TzRichEditParagraphDialog.comboLineSpacingRulePropertiesEditValueChanged(Sender: TObject);
begin
  if comboLineSpacingRule.ItemIndex = 3 then
    edLineSpacing.Value := 0;
end;

end.
