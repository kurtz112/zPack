unit SynColorDialogForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  SynEdit,
  SynEditHighlighter;

type
  TfrmSynColorDialog = class(TForm)
    Label1: TLabel;
    ListBox1: TListBox;
    SynEdit1: TSynEdit;
    Label2: TLabel;
    ColorBox1: TColorBox;
    Label3: TLabel;
    ColorBox2: TColorBox;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure ColorBox2Change(Sender: TObject);
    procedure ColorBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
  private
    { Private declarations }
    fSynH: TsynCustomHighlighter;
    procedure EnableItems(aenable: boolean);
    procedure SetFontStyle;
  public
    { Public declarations }
    procedure SetHighlighter(SynH: TSynCustomHighlighter);
    function GetHighlighter: TSynCustomHighlighter;
  end;

function SynColorDialogExecute(SynEdit: TCustomSynEdit): boolean;

implementation

{$R *.dfm}

type
  TSynHClass = class of TSynCustomHighlighter;

function SynColorDialogExecute(SynEdit: TCustomSynEdit): boolean;
var
  wFrm: TfrmSynColorDialog;
begin
  result := false;
  if assigned(SynEdit) then
  begin
    if assigned(SynEdit.highlighter) then
    begin
      wFrm := TfrmSynColorDialog.Create(nil);
      try
        wFrm.SetHighlighter(SynEdit.Highlighter);
        Result := (wFrm.ShowModal = mrOK);
        if result then
          SynEdit.Highlighter.assign(wFrm.GetHighlighter);
      finally
        FreeAndNil(wFrm);
      end;
    end
    else
      EInvalidOperation.create('SynEdit.Highligher has not been properly assigned');
  end
  else
    EInvalidOperation.create('SynEdit has not been properly assigned');
end;

{ TfrmSynColorDialog }

procedure TfrmSynColorDialog.SetHighlighter(SynH: TSynCustomHighlighter);
var
  loop: integer;
  wSynClass: TSynHClass;
begin
  wSynClass := TSynHClass(SynH.ClassType);
  fSynH := wSynClass.create(nil);
  fSynH.assign(SynH);
  listbox1.items.BeginUpdate;
  try
    listbox1.itemindex := -1;
    CheckBox1.Checked := false;
    CheckBox2.Checked := false;
    CheckBox3.Checked := false;
    CheckBox4.Checked := false;
    ColorBox1.ItemIndex := -1;
    ColorBox2.itemindex := -1;
    for loop := 0 to fSynH.AttrCount - 1 do
      ListBox1.Items.Add(fSynH.Attribute[loop].Name);
    synedit1.Highlighter := fSynH;
    SynEdit1.Lines.Text := fSynH.SampleSource;
    caption := fSynH.LanguageName + ' Color Definitions';
  finally
    ListBox1.items.EndUpdate;
  end;
end;

procedure TfrmSynColorDialog.FormDestroy(Sender: TObject);
begin
  if Assigned(fSynH) then
    fSynH.free;
end;

function TfrmSynColorDialog.GetHighlighter: TSynCustomHighlighter;
begin
  result := fSynH;
end;

procedure TfrmSynColorDialog.ListBox1Click(Sender: TObject);
var
  wSynAttr: TSynHighlighterAttributes;
begin
  if ListBox1.itemindex <> -1 then
  begin
    EnableItems(true);
    wSynAttr := fSynH.Attribute[listbox1.ItemIndex];
    CheckBox1.Checked := (fsBold in wSynAttr.Style);
    CheckBox2.Checked := (fsItalic in wSynAttr.Style);
    CheckBox3.Checked := (fsUnderline in wSynAttr.Style);
    CheckBox4.Checked := (fsStrikeOut in wSynAttr.Style);
    ColorBox1.Selected := wSynAttr.Foreground;
    ColorBox2.Selected := wSynAttr.Background;
  end
  else
    EnableItems(false);
end;

procedure TfrmSynColorDialog.EnableItems(aenable: boolean);
begin
  ColorBox1.Enabled := aenable;
  ColorBox2.Enabled := aenable;
  CheckBox1.enabled := aenable;
  CheckBox2.enabled := aenable;
  CheckBox3.enabled := aenable;
  CheckBox4.enabled := aenable;
end;

procedure TfrmSynColorDialog.ColorBox1Change(Sender: TObject);
var
  wSynAttr: TSynHighlighterAttributes;
begin
  wSynAttr := fSynH.Attribute[listbox1.ItemIndex];
  wSynAttr.Foreground := ColorBox1.Selected;
end;

procedure TfrmSynColorDialog.ColorBox2Change(Sender: TObject);
var
  wSynAttr: TSynHighlighterAttributes;
begin
  wSynAttr := fSynH.Attribute[listbox1.ItemIndex];
  wSynAttr.Background := ColorBox2.Selected;
end;

procedure TfrmSynColorDialog.ColorBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_delete) and (shift = []) then
  begin
    key := 0;
    TColorBox(sender).Selected := clNone;
    TColorBox(Sender).OnChange(nil);
  end;
end;

procedure TfrmSynColorDialog.CheckBox1Click(Sender: TObject);
begin
  SetFontStyle;
end;

procedure TfrmSynColorDialog.CheckBox2Click(Sender: TObject);
begin
  SetFontStyle;
end;

procedure TfrmSynColorDialog.CheckBox3Click(Sender: TObject);
begin
  SetFontStyle;
end;

procedure TfrmSynColorDialog.CheckBox4Click(Sender: TObject);
begin
  SetFontStyle;
end;

procedure TfrmSynColorDialog.SetFontStyle;
var
  wfs: TFontStyles;
  wSynAttr: TSynHighlighterAttributes;
begin
  wfs := [];
  wSynAttr := fSynH.Attribute[listbox1.ItemIndex];

  if CheckBox1.Checked then
    include(wfs, fsBold);

  if CheckBox2.Checked then
    include(wfs, fsItalic);

  if CheckBox3.Checked then
    include(wfs, fsUnderline);

  if CheckBox4.Checked then
    include(wfs, fsStrikeOut);

  wSynAttr.style := wfs;
end;

end.

