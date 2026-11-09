unit zOffice.SynEdit.Form;

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
  dxStatusBar,
  cxImage,
  dxPSGlbl,
  dxPSUtl,
  dxPSEngn,
  dxPrnPg,
  dxBkgnd,
  dxWrap,
  dxPrnDev,
  dxPSCompsProvider,
  dxPSFillPatterns,
  dxPSEdgePatterns,
  dxPSPDFExportCore,
  dxPSPDFExport,
  cxDrawTextUtils,
  dxPSPrVwStd,
  dxPSPrVwAdv,
  dxPSPrVwRibbon,
  dxPScxPageControlProducer,
  dxPSRichEditControlLnk,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  cxFontNameComboBox,
  cxDropDownEdit,
  dxGallery,
  dxRibbonGallery,
  dxBar,
  dxRibbonColorGallery,
  cxBarEditItem,
  dxBarExtItems,
  cxClasses,
  System.Actions,
  Vcl.ActnList,
  System.ImageList,
  Vcl.ImgList,
  cxImageList,
  dxPSCore,
  dxPScxEditorLnks,
  dxPSGraphicLnk,
  dxRibbonStatusBar,
  dxPSdxPDFViewerLnk,
  dxCore,
  dxRibbonSkins,
  dxRibbonCustomizationForm,
  dxRibbon,
  cxTrackBar,
  dxZoomTrackBar,
  dxPSdxSpreadSheetLnk,
  cxStyles,
  cxFilter,
  dxScrollbarAnnotations,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  dxUIAClasses,
  zOffice.SynEdit.Frame;

type
  TzViewerSynEditForm = class(TForm)
    zViewerSynEditFrame: TzViewerSynEditFrame;
    dxRibbon: TdxRibbon;
    dxRibbonTabHome: TdxRibbonTab;
    dxBarManagerForm: TdxBarManager;
    dxBarManagerFormBar2: TdxBar;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarButton1: TdxBarButton;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton4: TdxBarLargeButton;
    dxBarLargeButton5: TdxBarLargeButton;
    ActionListForm: TActionList;
    Chiudi: TAction;
    dxBarLargeButton6: TdxBarLargeButton;
    procedure ChiudiExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FFileName: string;
  public
    constructor Create(aOwner: TComponent); override;
    function ShowModal: Integer; override;
    procedure ShowFile(const FileName: string);

    property FileName: string read FFileName;
  end;

procedure ViewFileSynEdit(const FileName: string);

implementation

uses
  Winapi.ShellAPI,
  dxSmartImage,
  zdx;

{$R *.dfm}

procedure ViewFileSynEdit(const FileName: string);
var
  zViewerSynEditForm: TzViewerSynEditForm;
begin
  Application.CreateForm(TzViewerSynEditForm, zViewerSynEditForm);
  try
    zViewerSynEditForm.ShowFile(FileName);
  finally
    FreeAndNil(zViewerSynEditForm);
  end;
end;

constructor TzViewerSynEditForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);

  dxRibbonTabHome.Active := True;

  zViewerSynEditFrame.StatusBar.SizeGrip := True;

  WindowState := wsMaximized;
end;

procedure TzViewerSynEditForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerSynEditForm.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

procedure TzViewerSynEditForm.ShowFile(const FileName: string);
begin
  zViewerSynEditFrame.FileName := FileName;

  ShowModal;
end;

function TzViewerSynEditForm.ShowModal: Integer;
begin
  dxRibbon.ActiveTab := dxRibbonTabHome;
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  Result := inherited ShowModal;
end;

end.
