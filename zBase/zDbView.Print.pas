unit zDbView.Print;

interface

uses
  System.SysUtils,
  vcl.Printers,
  frxClass,
  frxDBSet,
  frxDesgn,
  zDbView;

procedure Print_zDbView(zDbView: TzDbView);

implementation

uses
  cxGridDBTableView;

procedure Print_zDbView(zDbView: TzDbView);
var
  Page: TfrxReportPage;
  HeaderBand: TfrxBand;
  DataBand: TfrxMasterData;
  Memo, dbMemo: TfrxMemoView;
  frxReport1: TfrxReport;
  frxDBDataset1: TfrxDBDataset;
  i: integer;
  Column: TcxGridDBColumn;
  Fieldname: string;
  DisplayLabel: string;
  MaxWidth: Extended;
  aWidth: integer;
  aLeft: integer;
begin
  if not Assigned(zDbView) then
    exit;

  if not Assigned(zDbView.zDataSet) then
    exit;

  frxReport1 := TfrxReport.Create(zDbView);
  try
    frxReport1.Name := 'DbGridFrxReport';
    frxDBDataset1 := TfrxDBDataset.Create(zDbView);
    try
      frxDBDataset1.Name := 'DbGridFrxDBDataset';
      frxDBDataset1.DataSet := zDbView.zDataSet;
      frxDBDataset1.UserName := zDbView.ViewID;

      { clear a report }
      frxReport1.Clear;

      { add a dataset to the list of ones accessible for a report }
      frxReport1.DataSets.Add(frxDBDataset1);

      { add a page }
      Page := TfrxReportPage.Create(frxReport1);
      { create a unique name }
      Page.CreateUniqueName;
      { set sizes of fields, paper and orientation by default }
      Page.SetDefaults;
      { modify paper’s orientation }
      Page.Orientation := poLandscape;
      MaxWidth := (Page.PaperWidth - Page.LeftMargin - Page.RightMargin) * fr01cm;

      { add a report title band }
      HeaderBand := TfrxHeader.Create(Page);
      HeaderBand.CreateUniqueName;
      { it is sufficient to set the «Top» coordinate and height for a band }
      { both coordinates are in pixels }
      HeaderBand.Top := 0;
      HeaderBand.Height := 20;
      { add the masterdata band }
      DataBand := TfrxMasterData.Create(Page);
      DataBand.CreateUniqueName;
      DataBand.DataSet := frxDBDataset1;
      { the Top coordinate should be greater than the previously added band’s
        top + height }
      DataBand.Top := 100;
      DataBand.Height := 20;

      aLeft := 0;
      for i := 0 to zDbView.cxGridDBTableView.VisibleColumnCount - 1 do
      begin
        Column := TcxGridDBColumn(zDbView.cxGridDBTableView.VisibleColumns[i]);

        Fieldname := Column.DataBinding.Fieldname;
        aWidth := Column.Width;
        DisplayLabel := Column.Caption;

        if (aLeft + aWidth) >= MaxWidth then
          Break;

        // label
        Memo := TfrxMemoView.Create(HeaderBand);
        Memo.CreateUniqueName;
        Memo.Text := DisplayLabel;
        Memo.SetBounds(aLeft, 0, aWidth, 20);
        Memo.Frame.Typ := [ftLeft, ftRight, ftTop, ftBottom];
        // Memo.HAlign := haRight;
        // db field
        dbMemo := TfrxMemoView.Create(DataBand);
        dbMemo.CreateUniqueName;
        dbMemo.DataSet := frxDBDataset1;
        dbMemo.DataField := Fieldname;
        dbMemo.SetBounds(aLeft, 0, aWidth, 20);
        // dbMemo.HAlign := haRight;
        aLeft := aLeft + aWidth;
      end;

      frxReport1.ShowReport;

    finally
      FreeAndNil(frxDBDataset1);
    end;
  finally
    FreeAndNil(frxReport1);
  end;
end;

end.
