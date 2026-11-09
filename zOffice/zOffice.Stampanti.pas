unit zOffice.Stampanti;

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
  Vcl.ComCtrls,
  Vcl.ActnList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxShellListView,
  System.Actions,
  System.ImageList,
  cxEdit,
  cxListView,
  dxStatusBar,
  cxClasses,
  dxBar,
  cxImageList;

type
  TFormStampanti = class(TForm)
    StatusBar: TdxStatusBar;
    ActionList: TActionList;
    actIcon: TAction;
    actSmallIcon: TAction;
    actList: TAction;
    actReport: TAction;
    cxShellListView: TcxShellListView;
    cxImageList: TcxImageList;
    dxBarManager: TdxBarManager;
    dxBarManagerBar: TdxBar;
    PopupMenu: TdxBarPopupMenu;
    dxBarButton1: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    Chiudi: TAction;
    dxBarButton5: TdxBarButton;
    procedure actIconExecute(Sender: TObject);
    procedure actListExecute(Sender: TObject);
    procedure actReportExecute(Sender: TObject);
    procedure actSmallIconExecute(Sender: TObject);
    procedure ChiudiExecute(Sender: TObject);
  private
  public
  end;

var
  FormStampanti: TFormStampanti;

procedure MostraProprietaStampanti;

implementation

{$R *.dfm}

procedure MostraProprietaStampanti;
begin
  Application.CreateForm(TFormStampanti, FormStampanti);
  try
    FormStampanti.ShowModal;
  finally
    FreeAndNil(FormStampanti);
  end;
end;

procedure TFormStampanti.actIconExecute(Sender: TObject);
begin
  cxShellListView.ViewStyle := vsIcon;
end;

procedure TFormStampanti.actListExecute(Sender: TObject);
begin
  cxShellListView.ViewStyle := vsList;
end;

procedure TFormStampanti.actReportExecute(Sender: TObject);
begin
  cxShellListView.ViewStyle := vsReport;
end;

procedure TFormStampanti.actSmallIconExecute(Sender: TObject);
begin
  cxShellListView.ViewStyle := vsSmallIcon;
end;

procedure TFormStampanti.ChiudiExecute(Sender: TObject);
begin
  Close;
end;

end.
