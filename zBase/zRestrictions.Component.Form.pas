unit zRestrictions.Component.Form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  vcl.ComCtrls,
  vcl.StdCtrls,
  vcl.ToolWin,
  vcl.ExtCtrls,
  vcl.Menus,
  TypInfo,
  vcl.Buttons,
  WinTypes,
  vcl.ImgList,
  zSystem,
  vcl.ActnList,
  System.Actions,
  System.ImageList,
  cxClasses,
  dxBar,
  cxImageList,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxCustomData,
  cxStyles,
  cxTL,
  cxTextEdit,
  cxTLdxBarBuiltInMenu,
  cxInplaceContainer,
  cxLabel,
  cxEdit,
  cxEditRepositoryItems,
  cxImageComboBox,
  cxDataStorage,
  Generics.Collections,
  SmartInspect.vcl.SiAuto,
  cxButtons,
  System.Variants,
  cxCheckBox,
  cxExtEditRepositoryItems,
  cxImage,
  zRestrictions.Types,
  zRestrictions.Structs,
  zRestrictions,
  cxVGrid,
  cxOI,
  cxDataControllerConditionalFormattingRulesManagerDialog,
  vcl.StdActns,
  OkCancel,
  dxScrollbarAnnotations,
  dxFileActions,
  zDbView,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  zFbDataSet,
  Data.DB,
  FireDAC.Comp.DataSet,
  dxBarBuiltInMenu,
  cxPC;

type
  TzSecComponentRestrictionsForm = class(TForm)
    OkCancel: TOkCancel;
    Utenti: TzFbDataSet;
    Transaction: TzFbTransaction;
    Dettaglio: TzFbDataSet;
    cxPageControl: TcxPageControl;
    tabUtenti: TcxTabSheet;
    tabDettaglio: TcxTabSheet;
    viewUtenti: TzDbView;
    viewDettaglio: TzDbView;
  private
    procedure Prepare(DataSet: TzFbDataSet; View: TzDbView);
    procedure OpenDataSet(DataSet: TzFbDataSet; Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string);
  public
    constructor Create(aOwner: TComponent); override;
    function EditComponentRestrictions(Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string): boolean;
  end;

function zEditComponentRestrictions(Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string): boolean;

implementation

uses
  System.Rtti,
  CommCtrl,
  zMsg,
  zBaseLib;

{$R *.DFM}

function zEditComponentRestrictions(Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string): boolean;
var
  zSecComponentRestrictionsForm: TzSecComponentRestrictionsForm;
begin
  Application.CreateForm(TzSecComponentRestrictionsForm, zSecComponentRestrictionsForm);
  try
    result := zSecComponentRestrictionsForm.EditComponentRestrictions(FormName, ComponentClass, ComponentName);
  finally
    FreeAndNil(zSecComponentRestrictionsForm);
  end;
end;

constructor TzSecComponentRestrictionsForm.Create(aOwner: TComponent);
begin
  inherited;
  Transaction.Connection := base.zFbDatabase;

  Prepare(Utenti, viewUtenti);
  Prepare(Dettaglio, viewDettaglio);
end;

procedure TzSecComponentRestrictionsForm.Prepare(DataSet: TzFbDataSet; View: TzDbView);
begin
  DataSet.Connection := base.zFbDatabase;
  DataSet.idDataSet := Name + '.' + DataSet.Name;
  base.DataSetLoadProps(DataSet);
  DataSet.Prepare;
  DataSet.BuildFields();

  View.zSystem := base;
  View.zDataSet := DataSet;
  View.ViewID := DataSet.idDataSet;
end;

procedure TzSecComponentRestrictionsForm.OpenDataSet(DataSet: TzFbDataSet; Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string);
begin
  DataSet.Active := False;
  DataSet.ParamByName('APP').asString := base.AppName;
  DataSet.ParamByName('FORM').asString := FormName;
  DataSet.ParamByName('COMPONENT').asString := ComponentName;
  DataSet.Active := True;
end;

function TzSecComponentRestrictionsForm.EditComponentRestrictions(Const FormName: string; const ComponentClass: TzComponentClass; const ComponentName: string): boolean;
begin
  cxPageControl.ActivePageIndex := 0;

  OpenDataSet(Utenti, FormName, ComponentClass, ComponentName);
  OpenDataSet(Dettaglio, FormName, ComponentClass, ComponentName);

  Transaction.StartTransaction;

  result := ShowModal = mrOk;

  if result and Transaction.Active then
    Transaction.Commit
  else
    Transaction.Rollback;
end;

end.
