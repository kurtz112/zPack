unit zOffice.Image.Frame;

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
  Vcl.ImgList,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.StdActns,
  Data.DB,
  cxFontNameComboBox,
  cxDropDownEdit,
  cxDrawTextUtils,
  cxImageList,
  cxGraphics,
  cxClasses,
  cxBarEditItem,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
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
  dxPSPrVwStd,
  dxPSPrVwAdv,
  dxPSPrVwRibbon,
  dxPScxPageControlProducer,
  dxPScxEditorLnks,
  dxPScxEditorProducers,
  dxPScxExtEditorProducers,
  dxPSCore,
  dxPSGraphicLnk,
  dxGallery,
  dxRibbonGallery,
  dxBar,
  dxRibbonColorGallery,
  dxBarExtItems,
  dxStatusBar,
  dxPSBaseGridLnk,
  dxPSdxSpreadSheetLnk,
  dxActivityIndicator,
  dxFileActions,
  dxPSdxPDFViewerLnk,
  dxPSRichEditControlLnk,
  dxUIAClasses,
  zOffice.types,
  SmartInspect.Vcl,
  SmartInspect.Vcl.SiAuto;

type
  TzViewerImageFrame = class;
  TImportFileImageEvent = procedure(sender: TzViewerImageFrame; const FileName: string) of object;

  TzViewerImageFrame = class(TFrame, izViewerFrame)
    cxImage: TcxImage;
    dxBarManager: TdxBarManager;
    biStatusBarCurrentZoom: TdxBarStatic;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton5: TdxBarLargeButton;
    dxBarSubItem14: TdxBarSubItem;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarLargeButton4: TdxBarLargeButton;
    dxBarLargeButton6: TdxBarLargeButton;
    dxBarLargeButton7: TdxBarLargeButton;
    dxBarLargeButton8: TdxBarLargeButton;
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
    ActionList: TActionList;
    SalvaConNome: TAction;
    Anteprima: TAction;
    Chiudi: TAction;
    Taglia: TAction;
    Copia: TAction;
    Incolla: TAction;
    Elimina: TAction;
    Centra: TAction;
    Trasparente: TAction;
    Proporzionale: TAction;
    Stretch: TAction;
    StatusBar: TdxStatusBar;
    dxBarManagerBar: TdxBar;
    Importa: TdxFileOpen;
    Apri: TAction;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxBarButton11: TdxBarButton;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    procedure AnteprimaExecute(sender: TObject);
    procedure ApriConExcelExecute(sender: TObject);
    procedure ApriExecute(sender: TObject);
    procedure CentraExecute(sender: TObject);
    procedure CopiaExecute(sender: TObject);
    procedure EliminaExecute(sender: TObject);
    procedure ImportaAccept(sender: TObject);
    procedure ImportaUpdate(sender: TObject);
    procedure IncollaExecute(sender: TObject);
    procedure ProporzionaleExecute(sender: TObject);
    procedure SalvaConNomeExecute(sender: TObject);
    procedure StretchExecute(sender: TObject);
    procedure TagliaExecute(sender: TObject);
    procedure TrasparenteExecute(sender: TObject);
  private
    // Stampa DevExpress a creazione differita.
    // Il TdxComponentPrinter e il suo collegamento di stampa non stanno piu' nel
    // .dfm: crearli mentre il frame si apre fa leggere subito la stampante
    // predefinita di Windows (TdxPrinterPage chiama GetDefaultPrinter, OpenPrinter
    // e GetPrinter di livello 9), e se la predefinita e' di rete, condivisa o
    // reindirizzata Windows apre la propria finestra di configurazione mentre
    // l'utente sta soltanto aprendo la form. Ora quella lettura avviene solo
    // quando si stampa o si esporta davvero.
    FComponentPrinter: TdxComponentPrinter;
    FComponentPrinterLink: TcxImageReportLink;
  public
    // Creato al primo uso: vedi la nota sui campi privati qui sopra.
    function ComponentPrinter: TdxComponentPrinter;
  private
    FFileName: string;
    FOnImportFile: TImportFileImageEvent;
    procedure SetFileName(const Value: string);
  private
    procedure UpdateStatusBar;
  protected
  public // izViewerFrame
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
  public
    constructor Create(aOwner: TComponent); override;
  public
    function AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
  published
    property FileName: string read FFileName write SetFileName stored False;
    property OnImportFile: TImportFileImageEvent read FOnImportFile write FOnImportFile;
  end;

implementation

uses
  Winapi.ShellAPI,
  zdx,
  zBaseLib,
  zOffice.utils,
  zOffice;

{$R *.dfm}

function TzViewerImageFrame.ComponentPrinter: TdxComponentPrinter;
begin
  if not Assigned(FComponentPrinter) then
  begin
    FComponentPrinter := TdxComponentPrinter.Create(Self);
    FComponentPrinter.Name := 'dxComponentPrinter';
    dx.InitPrinter(FComponentPrinter);

    FComponentPrinterLink := FComponentPrinter.AddLink(cxImage) as TcxImageReportLink;
    FComponentPrinterLink.Name := 'dxComponentPrinterLink';
    // unico valore che il .dfm assegnava oltre ai predefiniti DevExpress
    FComponentPrinterLink.PrinterPage.GrayShading := True;
  end;

  result := FComponentPrinter;
end;

constructor TzViewerImageFrame.Create(aOwner: TComponent);

  function GetDialogFilter: string;
  var
    GraphicClass: TGraphicClass;
  begin

    if cxImage.ActiveProperties.CustomFilter <> '' then
      Result := cxImage.ActiveProperties.CustomFilter
    else
    begin
      GraphicClass := cxImage.ActiveProperties.GraphicClass;

      if GraphicClass = nil then
        GraphicClass := TGraphic;

      Result := cxGraphicFilter(GraphicClass);
    end;
  end;

begin
  inherited;
  dx.AgganciaImmagini(Self);

  dx.initBar(dxBarManagerBar);

  Centra.Checked := cxImage.Properties.Center;
  Trasparente.Checked := cxImage.Transparent;
  Proporzionale.Checked := cxImage.Properties.Proportional;
  Stretch.Checked := cxImage.Properties.Stretch;

  Importa.Dialog.Filter := GetDialogFilter;
end;

function TzViewerImageFrame.AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
begin
  assert(Assigned(Action));

  Result := TdxBarButton.Create(Self);
  Result.Name := CreateUniqueName(Self, Self, Result, 'btn' + Action.Name, '');
  Result.Action := Action;
  Result.PaintStyle := psCaptionGlyph;

  if Action.AutoCheck then
  begin
    Result.ButtonStyle := bsChecked;
    Result.Down := Action.Checked;
  end;

  dxBarManagerBar.ItemLinks.Add(Result); // .VisibleIndex := Position;
end;

procedure TzViewerImageFrame.AnteprimaExecute(sender: TObject);
begin
  ComponentPrinter.Preview();
end;

procedure TzViewerImageFrame.ApriConExcelExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ShellExecute(0, PCHAR('open'), PCHAR(FileName), nil, nil, SW_RESTORE);
end;

procedure TzViewerImageFrame.ApriExecute(sender: TObject);
begin

  if FileExists(FileName) then
    ViewFile(FileName);
end;

procedure TzViewerImageFrame.CentraExecute(sender: TObject);
begin
  cxImage.Properties.Center := Centra.Checked;
end;

procedure TzViewerImageFrame.CloseFile;
begin
  SiMain.EnterMethod(Self, 'CloseFile');

  FFileName := '';

  cxImage.Clear;

  UpdateStatusBar;

  SiMain.LeaveMethod(Self, 'CloseFile');
end;

procedure TzViewerImageFrame.CopiaExecute(sender: TObject);
begin
  cxImage.CopyToClipboard;
end;

procedure TzViewerImageFrame.EliminaExecute(sender: TObject);
begin

  if not cxImage.Properties.ReadOnly then
    cxImage.Picture.Graphic := nil;
end;

procedure TzViewerImageFrame.ImportaAccept(sender: TObject);
begin

  if Assigned(FOnImportFile) then
    OnImportFile(Self, Importa.Dialog.FileName);
end;

procedure TzViewerImageFrame.ImportaUpdate(sender: TObject);
begin
  Importa.Visible := Assigned(FOnImportFile);
end;

procedure TzViewerImageFrame.IncollaExecute(sender: TObject);
begin

  if not cxImage.Properties.ReadOnly then
    cxImage.PasteFromClipboard;
end;

procedure TzViewerImageFrame.OpenFile(const FileName: string);
begin
  SiMain.EnterMethod(Self, 'OpenFile');

  if FileName.IsEmpty then
    CloseFile
  else
  begin
    SiMain.LogString('TzViewerImageFrame.OpenFile', FileName);
    cxImage.Picture.LoadFromFile(FileName);
    FFileName := FileName;
  end;

  SiMain.LeaveMethod(Self, 'OpenFile');
end;

procedure TzViewerImageFrame.Print;
begin
  Anteprima.Execute;
end;

procedure TzViewerImageFrame.ProporzionaleExecute(sender: TObject);
begin
  cxImage.Properties.Proportional := Proporzionale.Checked;
end;

procedure TzViewerImageFrame.SalvaConNomeExecute(sender: TObject);
begin
  cxImage.SaveToFile;
end;

procedure TzViewerImageFrame.SetAllowedImportFileTypes(FileTypes: TzFileTypes);
begin
  // se impostato da zOffice.MultiViewer
  Importa.dialog.Filter := FilterForFileTypes(FileTypes);
end;

procedure TzViewerImageFrame.SetFileName(const Value: string);
begin
  SiMain.EnterMethod(Self, 'SetFileName');

  if not FileExists(Value) then
    CloseFile
  else
    OpenFile(Value);

  SiMain.LeaveMethod(Self, 'SetFileName');
end;

procedure TzViewerImageFrame.StretchExecute(sender: TObject);
begin
  cxImage.Properties.Stretch := Stretch.Checked;
end;

procedure TzViewerImageFrame.TagliaExecute(sender: TObject);
begin

  if not cxImage.Properties.ReadOnly then
    cxImage.CutToClipboard;
end;

procedure TzViewerImageFrame.TrasparenteExecute(sender: TObject);
begin
  cxImage.Transparent := Trasparente.Checked;
end;

procedure TzViewerImageFrame.UpdateStatusBar;
begin

  if not Assigned(cxImage) then
    Exit;
end;

end.
