unit zFbMonitor;

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
  cxClasses,
  dxLayoutContainer,
  dxLayoutControl,
  FireDAC.Moni.Custom,
  FireDAC.Moni.FlatFile,
  FireDAC.Moni.Base,
  FireDAC.Stan.Intf,
  FireDAC.Moni.RemoteClient,
  dxStatusBar,
  dxLayoutcxEditAdapters,
  dxLayoutControlAdapters,
  Vcl.Menus,
  cxStyles,
  cxFilter,
  dxScrollbarAnnotations,
  cxEdit,
  cxContainer,
  cxTextEdit,
  cxMaskEdit,
  cxDropDownEdit,
  cxImageComboBox,
  cxInplaceContainer,
  cxVGrid,
  cxOI,
  System.ImageList,
  Vcl.ImgList,
  cxImageList,
  Vcl.StdCtrls,
  cxButtons,
  Frame_ObjectInspector;

type
  TFormFireDacMonitor = class(TForm)
    dxLayoutControlGroup_Root: TdxLayoutGroup;
    dxLayoutControl: TdxLayoutControl;
    dxStatusBar: TdxStatusBar;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    cxImageList: TcxImageList;
    cxRTTIInspector: TFrameObjectInspector;
    edTipoMonitor: TcxImageComboBox;
    dxLayoutItemTipoMonitor: TdxLayoutItem;
    dxLayoutItemRTTIInspector: TdxLayoutItem;
    dxLayoutItemOk: TdxLayoutItem;
    dxLayoutItemAnnulla: TdxLayoutItem;
    dxLayoutGroup1: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure edTipoMonitorPropertiesEditValueChanged(Sender: TObject);
  private
    FDMoniRemoteClientLink: TFDMoniRemoteClientLink;
    FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink;
    FDMoniCustomClientLink: TFDMoniCustomClientLink;
    FMonitorBy: TFDMonitorBy;
    procedure SetMonitorBy(const Value: TFDMonitorBy);
  private
  public
    function EditFbMonitor(var aMonitorBy: TFDMonitorBy; aFDMoniRemoteClientLink: TFDMoniRemoteClientLink; aFDMoniFlatFileClientLink: TFDMoniFlatFileClientLink; aFDMoniCustomClientLink: TFDMoniCustomClientLink): boolean;

    property MonitorBy: TFDMonitorBy read FMonitorBy write SetMonitorBy;
  end;

function EditFbMonitor(var MonitorBy: TFDMonitorBy; FDMoniRemoteClientLink: TFDMoniRemoteClientLink; FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink; FDMoniCustomClientLink: TFDMoniCustomClientLink): boolean;

implementation

uses
  zDx;
{$R *.dfm}

function EditFbMonitor(var MonitorBy: TFDMonitorBy; FDMoniRemoteClientLink: TFDMoniRemoteClientLink; FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink; FDMoniCustomClientLink: TFDMoniCustomClientLink): boolean;
var
  FormFbMonitor: TFormFireDacMonitor;
begin
  // Application.CreateForm(TFormFbMonitor, FormFbMonitor);
  FormFbMonitor := TFormFireDacMonitor.Create(Application);
  try
    result := FormFbMonitor.EditFbMonitor(MonitorBy, FDMoniRemoteClientLink, FDMoniFlatFileClientLink, FDMoniCustomClientLink);
  finally
    FreeAndNil(FormFbMonitor);
  end;
end;

procedure TFormFireDacMonitor.FormCreate(Sender: TObject);
begin
  MonitorBy := TFDMonitorBy.mbNone;
  FDMoniRemoteClientLink := nil;
  FDMoniFlatFileClientLink := nil;
  FDMoniCustomClientLink := nil;

  dx.InitLayoutControl(dxLayoutControl);
  cxRTTIInspector.ObjectInspector.OptionsView.RowHeaderWidth := 155;
end;

procedure TFormFireDacMonitor.edTipoMonitorPropertiesEditValueChanged(Sender: TObject);
var
  idx: integer;
begin
  idx := edTipoMonitor.ItemIndex;

  if idx = 0 then
    MonitorBy := TFDMonitorBy.mbNone
  else
    if idx = 1 then
      MonitorBy := TFDMonitorBy.mbRemote
    else
      if idx = 2 then
        MonitorBy := TFDMonitorBy.mbFlatFile
      else
        if idx = 3 then
          MonitorBy := TFDMonitorBy.mbCustom;
end;

type
  { Wrapper per compilazione/cast nel file di monitoraggio }
  IFDMonitor = interface
  end;

function TFormFireDacMonitor.EditFbMonitor(var aMonitorBy: TFDMonitorBy; aFDMoniRemoteClientLink: TFDMoniRemoteClientLink; aFDMoniFlatFileClientLink: TFDMoniFlatFileClientLink; aFDMoniCustomClientLink: TFDMoniCustomClientLink): boolean;
begin
  FDMoniRemoteClientLink := aFDMoniRemoteClientLink;
  FDMoniFlatFileClientLink := aFDMoniFlatFileClientLink;
  FDMoniCustomClientLink := aFDMoniCustomClientLink;

  MonitorBy := aMonitorBy;

  case MonitorBy of
    TFDMonitorBy.mbNone:
      edTipoMonitor.ItemIndex := 0;
    TFDMonitorBy.mbRemote:
      edTipoMonitor.ItemIndex := 1;
    TFDMonitorBy.mbFlatFile:
      edTipoMonitor.ItemIndex := 2;
    TFDMonitorBy.mbCustom:
      edTipoMonitor.ItemIndex := 3;
  end;

  result := ShowModal = mrOK;

  if result then
    aMonitorBy := MonitorBy;
end;

procedure TFormFireDacMonitor.SetMonitorBy(const Value: TFDMonitorBy);
begin
  FMonitorBy := Value;

  case MonitorBy of
    TFDMonitorBy.mbNone:
      cxRTTIInspector.inspectedObject := nil;
    TFDMonitorBy.mbFlatFile:
      cxRTTIInspector.inspectedObject := FDMoniFlatFileClientLink;
    TFDMonitorBy.mbRemote:
      cxRTTIInspector.inspectedObject := FDMoniRemoteClientLink;
    TFDMonitorBy.mbCustom:
      cxRTTIInspector.inspectedObject := FDMoniCustomClientLink;
  end;
end;

end.
