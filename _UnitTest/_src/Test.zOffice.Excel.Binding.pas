// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-23
// ---------------------------------------------------------------------------
unit Test.zOffice.Excel.Binding;

// Test DUnitX per zOffice.Excel.Editor.binding: lettura e scrittura del
// databinding dei modelli Excel (nodo excel.databinding del .xlsx.json).
// Il campo sortOrder si scrive come ordinale, ma si deve poter leggere anche
// come nome dell'enumerato (soAscending) e nella forma breve (ascending).

interface

uses
  System.SysUtils,
  System.JSON,
  DUnitX.TestFramework,
  dxCore,
  zOffice.Excel.Editor.binding;

type
  [TestFixture]
  TTestDataBindingSortOrder = class
  private
    function Leggi(const Json: string): TDataBinding;
    function SortField(const SortOrder: string): string;
  public
    [Test]
    procedure Ordinale_Letto;
    // Mantis #280 - 2026-10-23: "soAscending" nel dettaglio bloccava l'anteprima
    [Test]
    procedure NomeEnumerato_NelDettaglio_Letto;
    [Test]
    procedure NomeEnumerato_SenzaDistinzioneMaiuscole;
    [Test]
    procedure FormaBreve_Letta;
    [Test]
    procedure DataGroup_NomeEnumerato_Letto;
    [Test]
    procedure Null_DiventaNessunOrdinamento;
    [Test]
    procedure ValoreSconosciuto_Errore;
    [Test]
    procedure OrdinaleFuoriIntervallo_Errore;
    [Test]
    procedure Scrittura_ResaOrdinale;
  end;

implementation

function TTestDataBindingSortOrder.Leggi(const Json: string): TDataBinding;
begin
  result := TDataBinding.FromJSON(Json);
end;

function TTestDataBindingSortOrder.SortField(const SortOrder: string): string;
begin
  result := '{"dataSource": "dsMaster", "sortFields": [{"fieldName": "CAMPO", "sortOrder": ' + SortOrder + '}]}';
end;

procedure TTestDataBindingSortOrder.Ordinale_Letto;
var
  DataBinding: TDataBinding;
begin
  DataBinding := Leggi(SortField('2'));
  try
    Assert.AreEqual(1, DataBinding.sortFields.Count);
    Assert.AreEqual(Ord(soDescending), Ord(DataBinding.sortFields[0].sortOrder));
  finally
    DataBinding.Free;
  end;
end;

procedure TTestDataBindingSortOrder.NomeEnumerato_NelDettaglio_Letto;
var
  DataBinding: TDataBinding;
begin
  // stessa forma del modello del ticket: details[0].sortFields[0].sortOrder
  DataBinding := Leggi(
    '{"dataSource": "dsMaster", "details": [{"dataSource": "dsDettaglio", "sectionId": 1, ' +
    '"sortFields": [{"fieldName": "GIORNO", "sortOrder": "soAscending"}]}]}');
  try
    Assert.AreEqual(1, DataBinding.details.Count);
    Assert.AreEqual(1, DataBinding.details[0].sortFields.Count);
    Assert.AreEqual('GIORNO', DataBinding.details[0].sortFields[0].fieldName);
    Assert.AreEqual(Ord(soAscending), Ord(DataBinding.details[0].sortFields[0].sortOrder));
  finally
    DataBinding.Free;
  end;
end;

procedure TTestDataBindingSortOrder.NomeEnumerato_SenzaDistinzioneMaiuscole;
var
  DataBinding: TDataBinding;
begin
  DataBinding := Leggi(SortField('"SODESCENDING"'));
  try
    Assert.AreEqual(Ord(soDescending), Ord(DataBinding.sortFields[0].sortOrder));
  finally
    DataBinding.Free;
  end;
end;

procedure TTestDataBindingSortOrder.FormaBreve_Letta;
var
  DataBinding: TDataBinding;
begin
  DataBinding := Leggi(SortField('"ascending"'));
  try
    Assert.AreEqual(Ord(soAscending), Ord(DataBinding.sortFields[0].sortOrder));
  finally
    DataBinding.Free;
  end;
end;

procedure TTestDataBindingSortOrder.DataGroup_NomeEnumerato_Letto;
var
  DataBinding: TDataBinding;
begin
  DataBinding := Leggi('{"dataSource": "dsMaster", "dataGroups": [{"fieldName": "PROGETTO", "sortOrder": "soDescending", "sectionId": 0}]}');
  try
    Assert.AreEqual(1, DataBinding.dataGroups.Count);
    Assert.AreEqual(Ord(soDescending), Ord(DataBinding.dataGroups[0].sortOrder));
  finally
    DataBinding.Free;
  end;
end;

procedure TTestDataBindingSortOrder.Null_DiventaNessunOrdinamento;
var
  DataBinding: TDataBinding;
begin
  DataBinding := Leggi(SortField('null'));
  try
    Assert.AreEqual(Ord(soNone), Ord(DataBinding.sortFields[0].sortOrder));
  finally
    DataBinding.Free;
  end;
end;

procedure TTestDataBindingSortOrder.ValoreSconosciuto_Errore;
begin
  Assert.WillRaiseAny(
    procedure
    begin
      Leggi(SortField('"crescente"')).Free;
    end);
end;

procedure TTestDataBindingSortOrder.OrdinaleFuoriIntervallo_Errore;
begin
  Assert.WillRaiseAny(
    procedure
    begin
      Leggi(SortField('7')).Free;
    end);
end;

procedure TTestDataBindingSortOrder.Scrittura_ResaOrdinale;
var
  DataBinding: TDataBinding;
  Json: TJSONValue;
  Valore: TJSONValue;
begin
  // il file salvato resta leggibile dalle versioni precedenti, che accettano
  // solo l'ordinale
  DataBinding := Leggi(SortField('"soAscending"'));
  try
    Json := TJSONObject.ParseJSONValue(DataBinding.ToJSONString);
    try
      Valore := Json.FindValue('sortFields[0].sortOrder');
      Assert.IsNotNull(Valore);
      Assert.IsTrue(Valore is TJSONNumber, 'sortOrder scritto come ' + Valore.ClassName);
      Assert.AreEqual(Ord(soAscending), (Valore as TJSONNumber).AsInt);
    finally
      Json.Free;
    end;
  finally
    DataBinding.Free;
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TTestDataBindingSortOrder);

end.
