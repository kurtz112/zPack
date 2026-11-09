unit zImageDialog;

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
  OkCancel,
  dxBar,
  cxClasses,
  System.ImageList,
  Vcl.ImgList,
  cxImageList,
  dxRibbonForm,
  cxDBEdit,
  cxImage,
  Vcl.StdActns;

type
  TzImageForm = class(TdxRibbonForm)
    OkCancel: TOkCancel;
    cxImage: TcxImage;
    ActionList: TActionList;
    FileOpen: TAction;
    FileSaveAs: TAction;
    EditCut: TAction;
    EditCopy: TAction;
    EditPaste: TAction;
    EditDelete: TAction;
    dxBarManager: TdxBarManager;
    dxBarManagerBarToolbar: TdxBar;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton11: TdxBarButton;
    dxBarPopupMenu: TdxBarPopupMenu;
    procedure EditCopyExecute(Sender: TObject);
    procedure EditCutExecute(Sender: TObject);
    procedure EditDeleteExecute(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure FileOpenExecute(Sender: TObject);
    procedure FileSaveAsExecute(Sender: TObject);
  public
    constructor Create(aOwner: TComponent); override;
    function Execute(aImage: TcxCustomImage = nil; const ReadOnly: boolean = false): boolean;
  end;

  TzImageDialog = class(TComponent)
  private
    FCaption: string;
    FOnInitDialog: TNotifyEvent;
    FOnCloseDialog: TNotifyEvent;
    FReadOnly: boolean;
  protected
    zImageForm: TzImageForm;
    procedure DoInitDialog;
    procedure DoCloseDialog;
  public
    constructor Create(AOwner: TComponent); override;
    function Execute(cxImage: TcxCustomImage = nil): boolean;
  published
    property Caption: string read FCaption write FCaption;
    property ReadOnly: boolean read FReadOnly write FReadOnly;

    property OnInitDialog: TNotifyEvent read FOnInitDialog write FOnInitDialog;
    property OnCloseDialog: TNotifyEvent read FOnCloseDialog write FOnCloseDialog;
  end;

function zExecuteImageDialog(cxImage: TcxCustomImage; const Caption: string = ''; const ReadOnly: boolean = false): boolean; overload;

implementation


uses
  zDX;
{$R *.dfm}

function zExecuteImageDialog(cxImage: TcxCustomImage; const Caption: string = ''; const ReadOnly: boolean = false): boolean;
var
  zImageForm: TzImageForm;
begin
  zImageForm := TzImageForm.Create(Nil);
  try
    zImageForm.Caption := Caption;

    Result := zImageForm.Execute(cxImage, ReadOnly);

    if Result then
      if Assigned(cxImage) then
        cxImage.Picture.Assign(zImageForm.cxImage.Picture);
  finally
    FreeAndNil(zImageForm);
  end;
end;

constructor TzImageForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
end;

procedure TzImageForm.EditCopyExecute(Sender: TObject);
begin
  cxImage.CopyToClipboard;
end;

procedure TzImageForm.EditCutExecute(Sender: TObject);
begin
  cxImage.CutToClipboard;
end;

procedure TzImageForm.EditDeleteExecute(Sender: TObject);
begin
  cxImage.Clear;
end;

procedure TzImageForm.EditPasteExecute(Sender: TObject);
begin
  cxImage.PasteFromClipboard;
end;

function TzImageForm.Execute(aImage: TcxCustomImage = nil; const ReadOnly: boolean = false): boolean;
begin
  // Init;

  FileOpen.Visible := not Readonly;
  FileSaveAs.Visible := true;
  EditCut.Visible := not Readonly;
  EditCopy.Visible := true;
  EditPaste.Visible := not Readonly;
  EditDelete.Visible := not Readonly;

  if Assigned(aImage) then
  begin
    cxImage.Properties.Assign(aImage.Properties);
    cxImage.Picture.Assign(aImage.Picture);
  end;

  Result := ShowModal = mrOk;
end;

procedure TzImageForm.FileOpenExecute(Sender: TObject);
begin
  cxImage.LoadFromFile;
end;

procedure TzImageForm.FileSaveAsExecute(Sender: TObject);
begin
  cxImage.SaveToFile;
end;

constructor TzImageDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCaption := '';
  FReadOnly := false;
end;

function TzImageDialog.Execute(cxImage: TcxCustomImage = nil): boolean;
begin
  DoInitDialog;

  zImageForm := TzImageForm.Create(Nil);
  try
    zImageForm.Caption := Caption;
    zImageForm.cxImage.Picture.Assign(cxImage.Picture);

    Result := zImageForm.Execute(cxImage, ReadOnly);

    if Result then
      cxImage.Picture.Assign(zImageForm.cxImage.Picture);
  finally
    FreeAndNil(zImageForm);
  end;

  DoCloseDialog;
end;

Procedure TzImageDialog.DoInitDialog;
begin
  if Assigned(FOnInitDialog) then
    OnInitDialog(Self);
end;

Procedure TzImageDialog.DoCloseDialog;
begin
  if Assigned(FOnCloseDialog) then
    OnCloseDialog(Self);
end;

end.

  WebCam

  zdbcardcx
