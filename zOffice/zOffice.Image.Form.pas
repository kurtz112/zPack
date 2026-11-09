unit zOffice.Image.Form;

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
  cxOI;

type
  TzViewerImageForm = class(TForm)
    cxImage: TcxImage;
    dxRibbonStatusBar: TdxRibbonStatusBar;
    Printer: TdxComponentPrinter;
    ActionList: TActionList;
    Chiudi: TAction;
    dxBarManager: TdxBarManager;
    cxBarEditItemFont: TcxBarEditItem;
    cxBarEditItemFontSize: TcxBarEditItem;
    dxBarSubItem1: TdxBarSubItem;
    dxRibbonColorGalleryItemTextHighlightColor: TdxRibbonColorGalleryItem;
    dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem;
    dxBarSubItem2: TdxBarSubItem;
    dxRibbonGalleryItemQuickStyles: TdxRibbonGalleryItem;
    dxRibbonGalleryItemQuickStylesGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemMargins: TdxRibbonGalleryItem;
    dxRibbonGalleryItemMarginsGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemMarginsGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemMarginsGroup1Item4: TdxRibbonGalleryGroupItem;
    dxBarSubItem3: TdxBarSubItem;
    dxRibbonGalleryItemSize: TdxRibbonGalleryItem;
    dxRibbonGalleryItemSizeGroup1: TdxRibbonGalleryGroup;
    dxRibbonGalleryItemSizeGroup1Item1: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item2: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item3: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item4: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item5: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item6: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item7: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item8: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item9: TdxRibbonGalleryGroupItem;
    dxRibbonGalleryItemSizeGroup1Item10: TdxRibbonGalleryGroupItem;
    dxBarSubItem4: TdxBarSubItem;
    dxBarSubItem5: TdxBarSubItem;
    dxBarSubItem6: TdxBarSubItem;
    dxRibbonColorGalleryItemPageColor: TdxRibbonColorGalleryItem;
    dxBarSubItem7: TdxBarSubItem;
    dxBarSubItem8: TdxBarSubItem;
    dxRibbonGalleryItemTableStyles: TdxRibbonGalleryItem;
    dxRibbonGalleryItemTableStylesGroup1: TdxRibbonGalleryGroup;
    dxBarSubItem9: TdxBarSubItem;
    dxRibbonColorGalleryItemShapeFill: TdxRibbonColorGalleryItem;
    dxRibbonColorGalleryItemShapeOutline: TdxRibbonColorGalleryItem;
    dxBarSubItem10: TdxBarSubItem;
    dxBarSubItem11: TdxBarSubItem;
    dxBarSubItem12: TdxBarSubItem;
    dxBarSubItem13: TdxBarSubItem;
    biStatusBarZoom: TdxBar;
    biStatusBarCurrentZoom: TdxBarStatic;

    PrinterLink: TcxImageReportLink;
    dxRibbonTabFile: TdxRibbonTab;
    dxRibbon: TdxRibbon;
    dxBarManagerBarZoom: TdxBar;
    tbZoom: TdxZoomTrackBar;
    dxRibbonStatusBarContainer1: TdxStatusBarContainerControl;
    dxBarManagerBarFile: TdxBar;
    dxBarManagerBarImage: TdxBar;
    dxBarManagerBarChiudi: TdxBar;
    dxBarLargeButton1: TdxBarLargeButton;
    Taglia: TAction;
    Copia: TAction;
    Incolla: TAction;
    Elimina: TAction;
    Centra: TAction;
    Trasparente: TAction;
    SalvaConNome: TAction;
    Anteprima: TAction;
    dxBarManagerBarEdita: TdxBar;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton5: TdxBarLargeButton;
    dxBarSubItem14: TdxBarSubItem;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarLargeButton4: TdxBarLargeButton;
    dxBarLargeButton6: TdxBarLargeButton;
    Proporzionale: TAction;
    Stretch: TAction;
    dxBarLargeButton7: TdxBarLargeButton;
    dxBarLargeButton8: TdxBarLargeButton;
    actShellExecute: TAction;
    dxBarLargeButton9: TdxBarLargeButton;
    procedure actShellExecuteExecute(Sender: TObject);
    procedure AnteprimaExecute(Sender: TObject);
    procedure CentraExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
    procedure CopiaExecute(Sender: TObject);
    procedure EliminaExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IncollaExecute(Sender: TObject);
    procedure ProporzionaleExecute(Sender: TObject);
    procedure SalvaConNomeExecute(Sender: TObject);
    procedure StretchExecute(Sender: TObject);
    procedure TagliaExecute(Sender: TObject);
    procedure tbZoomPropertiesChange(Sender: TObject);
    procedure TrasparenteExecute(Sender: TObject);
  private
    FFileName: string;
    function GetReadOnly: boolean;
    procedure SetReadOnly(const Value: boolean);
  public
    constructor Create(aOwner: TComponent); override;
    function ShowModal: Integer; override;
    procedure LoadFile(const FileName: string);
    procedure ShowFile(const FileName: string; const ReadOnly: boolean = false);

    property FileName: string read FFileName;
    property ReadOnly: boolean read GetReadOnly write SetReadOnly;
  end;

procedure ViewFileImage(const FileName: string; const ReadOnly: boolean = false);

implementation

uses
  Winapi.ShellAPI,
  dxSmartImage,
  zdx,
  zMsg;

{$R *.dfm}

procedure ViewFileImage(const FileName: string; const ReadOnly: boolean = false);
var
  zViewerImageForm: TzViewerImageForm;
begin
  Application.CreateForm(TzViewerImageForm, zViewerImageForm);
  try
    zViewerImageForm.ShowFile(FileName, ReadOnly);
  finally
    FreeAndNil(zViewerImageForm);
  end;
end;

constructor TzViewerImageForm.Create(aOwner: TComponent);
begin
  inherited;
  dx.AgganciaImmagini(Self);
  FFileName := '';

  // senza la clessidra globale di ExpressPrinting, come gli altri visualizzatori:
  // vedi Tdx.InitPrinter
  dx.InitPrinter(Printer);

  biStatusBarCurrentZoom.Caption := IntToStr(cxImage.ZoomingOptions.ZoomPercent) + '%';
  tbZoom.Position := cxImage.ZoomingOptions.ZoomPercent;

  dxRibbonTabFile.Active := True;

  Centra.Checked := cxImage.Properties.Center;
  Trasparente.Checked := cxImage.Transparent;
  Proporzionale.Checked := cxImage.Properties.Proportional;
  Stretch.Checked := cxImage.Properties.Stretch;

  WindowState := wsMaximized;
end;

procedure TzViewerImageForm.actShellExecuteExecute(Sender: TObject);
begin

  if not FileName.IsEmpty then
    if ConfirmYesNo('Si desidera aprire il file con l''editor di sistema associato?', mtWarning) then
      ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerImageForm.AnteprimaExecute(Sender: TObject);
begin
  Printer.Preview();
end;

procedure TzViewerImageForm.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

procedure TzViewerImageForm.FormShow(Sender: TObject);
begin
  dxRibbon.ColorSchemeName := dx.RibbonColorSchemeName;
end;

function TzViewerImageForm.GetReadOnly: boolean;
begin
  Result := cxImage.Properties.ReadOnly;
end;

procedure TzViewerImageForm.SetReadOnly(const Value: boolean);
begin
  cxImage.Properties.ReadOnly := Value;
end;

procedure TzViewerImageForm.LoadFile(const FileName: string);
begin

  if FileExists(FileName) then
  begin
    cxImage.Picture.LoadFromFile(FileName);
    FFileName := FileName;

    tbZoom.Position := cxImage.ZoomingOptions.ZoomPercent;
  end;
end;

procedure TzViewerImageForm.ShowFile(const FileName: string; const ReadOnly: boolean = false);
begin
  LoadFile(FileName);

  ShowModal;
end;

procedure TzViewerImageForm.tbZoomPropertiesChange(Sender: TObject);
begin
  biStatusBarCurrentZoom.Caption := IntToStr(tbZoom.Position) + '%';
  cxImage.ZoomingOptions.ZoomPercent := tbZoom.Position;
end;

procedure TzViewerImageForm.TrasparenteExecute(Sender: TObject);
begin
  cxImage.Transparent := Trasparente.Checked;
end;

procedure TzViewerImageForm.CentraExecute(Sender: TObject);
begin
  cxImage.Properties.Center := Centra.Checked;
end;

procedure TzViewerImageForm.StretchExecute(Sender: TObject);
begin
  cxImage.Properties.Stretch := Stretch.Checked;
end;

procedure TzViewerImageForm.ProporzionaleExecute(Sender: TObject);
begin
  cxImage.Properties.Proportional := Proporzionale.Checked;
end;

procedure TzViewerImageForm.CopiaExecute(Sender: TObject);
begin
  cxImage.CopyToClipboard;
end;

procedure TzViewerImageForm.EliminaExecute(Sender: TObject);
begin

  if not cxImage.Properties.ReadOnly then
    cxImage.Picture.Graphic := nil;
end;

procedure TzViewerImageForm.IncollaExecute(Sender: TObject);
begin

  if not cxImage.Properties.ReadOnly then
    cxImage.PasteFromClipboard;
end;

procedure TzViewerImageForm.SalvaConNomeExecute(Sender: TObject);
begin
  cxImage.SaveToFile;
end;

function TzViewerImageForm.ShowModal: Integer;
begin
  dxRibbon.ActiveTab := dxRibbonTabFile;
  Screen.Cursor := crDefault; // ShowModal fa un gioco strano sul cursore
  Result := inherited ShowModal;
end;

procedure TzViewerImageForm.TagliaExecute(Sender: TObject);
begin

  if not cxImage.Properties.ReadOnly then
    cxImage.CutToClipboard;
end;

end.

// saveAs
// taglia/copia/incolla/elimina
// assign from camera

// FitMode := ifmProportionalStretch
// Center
// Transparent
// Proporzionale
// stretch  allungamento?

  zdx
