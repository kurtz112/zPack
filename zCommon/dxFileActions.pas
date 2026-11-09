unit dxFileActions;

interface

uses
  system.SysUtils,
  system.Classes,
  Vcl.StdActns,
  dxShellDialogs;

type
  TdxFileOpen = class(TFileAction)
  private
    function GetOpenDialog: TdxOpenFileDialog;
  protected
    function GetDialogClass: TCommonDialogClass; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Dialog: TdxOpenFileDialog read GetOpenDialog;
    property Enabled;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property ImageIndex;
    property ShortCut;
    property SecondaryShortCuts;
    property Visible;
    property BeforeExecute;
    property OnAccept;
    property OnCancel;
    property OnHint;
    property OnUpdate;
  end;

  TdxFileSaveAs = class(TFileAction)
  private
    function GetSaveDialog: TdxSaveFileDialog;
  protected
    function GetDialogClass: TCommonDialogClass; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Dialog: TdxSaveFileDialog read GetSaveDialog;
    property Enabled;
    property HelpContext;
    property Hint;
    property ImageIndex;
    property ShortCut;
    property SecondaryShortCuts;
    property Visible;
    property BeforeExecute;
    property OnAccept;
    property OnCancel;
    property OnHint;
    property OnUpdate;
  end;

  TdxOpenPicture = class(TCommonDialogAction)
  private
    function GetDialog: TdxOpenPictureDialog;
  protected
    function GetDialogClass: TCommonDialogClass; override;
  published
    property Dialog: TdxOpenPictureDialog read GetDialog;
    property Caption;
    property Enabled;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property ImageIndex;
    property ImageName;
    property ShortCut;
    property SecondaryShortCuts;
    property Visible;
    property OnHint;
    property OnUpdate;
    property OnAccept;
    property OnCancel;
  end;

  TdxSavePicture = class(TCommonDialogAction)
  private
    function GetDialog: TdxSavePictureDialog;
  protected
    function GetDialogClass: TCommonDialogClass; override;
  published
    property Dialog: TdxSavePictureDialog read GetDialog;
    property Caption;
    property Enabled;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property ImageIndex;
    property ImageName;
    property ShortCut;
    property SecondaryShortCuts;
    property Visible;
    property OnHint;
    property OnUpdate;
    property OnAccept;
    property OnCancel;
  end;

implementation

{ TFileOpen }

constructor TdxFileOpen.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialog.Name := 'dxOpenDialog';
end;

function TdxFileOpen.GetDialogClass: TCommonDialogClass;
begin
  Result := TdxOpenFileDialog;
end;

function TdxFileOpen.GetOpenDialog: TdxOpenFileDialog;
begin
  Result := TdxOpenFileDialog(FDialog);
end;

{ TFileSaveAs }

constructor TdxFileSaveAs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialog.Name := 'dxSaveDialog';
end;

function TdxFileSaveAs.GetDialogClass: TCommonDialogClass;
begin
  Result := TdxSaveFileDialog;
end;

function TdxFileSaveAs.GetSaveDialog: TdxSaveFileDialog;
begin
  Result := TdxSaveFileDialog(FDialog);
end;

{ TOpenPicture }

function TdxOpenPicture.GetDialog: TdxOpenPictureDialog;
begin
  Result := TdxOpenPictureDialog(FDialog);
end;

function TdxOpenPicture.GetDialogClass: TCommonDialogClass;
begin
  Result := TdxOpenPictureDialog;
end;

{ TSavePicture }

function TdxSavePicture.GetDialog: TdxSavePictureDialog;
begin
  Result := TdxSavePictureDialog(FDialog);
end;

function TdxSavePicture.GetDialogClass: TCommonDialogClass;
begin
  Result := TdxSavePictureDialog;
end;

end.
