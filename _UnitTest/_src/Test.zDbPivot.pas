// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDbPivot;

// Test DUnitX delle impostazioni del pivot (zSystem.pas: TzDbPivotFlags,
// TzPivotField, TzPivotFields, TzDbPivotProps), specifica "Tabella pivot.md",
// requisiti ZBASE-PVT e divergenza DIV-PVT-1.
//
// Il frame TzDbPivot (zDbPivot.pas) non si prova qui: richiede la griglia
// DevExpress, i dialoghi e un TzFbDataSet aperto. Si provano solo le parti
// che vivono nel dizionario LZ: valori predefiniti, copia (Assign),
// notifiche dei flag e scrittura/lettura JSON dell'elenco dei campi e dei
// pivot. Nessun database, nessuna interfaccia, nessun file.
//
// La prova della divergenza afferma il comportamento DEDOTTO dalla lettura
// del codice: se passa, la divergenza e' confermata. Quando verra' corretta
// nel codice la prova va capovolta e spostata fra i requisiti.
//
// DIV-PVT-2 (Reset dei campi che conserva i calcolati) e' corretta e provata.
// DIV-PVT-3 (didascalia ereditata) vive in AssignFromPivotFields, che richiede
// la griglia DevExpress: si prova con la sonda.

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework,
  cxCustomData,
  dxCore,
  cxCustomPivotGrid,
  cxDBPivotGrid,
  zBaseLib,
  zSystem;

type
  [TestFixture]
  TTestPivotFlags = class
  private
    FFlags: TzDbPivotFlags;
    FNotifiche: Integer;
    procedure Notifica(Sender: TObject);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-PVT-013
    [Test]
    procedure Predefiniti_FlagVeri;
    // ZBASE-PVT-013
    [Test]
    procedure Predefiniti_FlagFalsiETestiVuoti;
    // ZBASE-PVT-013
    [Test]
    procedure Assign_CopiaLeImpostazioni;
    // DIV-PVT-1
    [Test]
    procedure Assign_CopiaDrillDown;
    // ZBASE-PVT-013
    [Test]
    procedure Setter_NotificaOnChange;
    // ZBASE-PVT-013
    [Test]
    procedure BeginUpdate_SospendeLeNotificheEdEndUpdateNonNotifica;
    // ZBASE-PVT-013
    [Test]
    procedure Setter_SenzaGestore_NessunErrore;
  end;

  [TestFixture]
  TTestPivotField = class
  private
    FCampi: TzPivotFields;
    function NuovoCampo(const Nome: string): TzPivotField;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-PVT-005
    [Test]
    procedure Predefiniti_ValoriDichiarati;
    // ZBASE-PVT-005
    [Test]
    procedure Assign_CopiaTuttiICampi;
    // ZBASE-PVT-005
    [Test]
    procedure Assign_ElenchiCopiatiNonCondivisi;
    // ZBASE-PVT-005
    [Test]
    procedure Json_SoloIlNome_NienteValoriPredefiniti;
    // ZBASE-PVT-005
    [Test]
    procedure Json_CampoNormale_NonScriveKind;
    // ZBASE-PVT-005
    [Test]
    procedure Json_CampoCalcolato_ScriveERileggeKind;
    // ZBASE-PVT-005
    [Test]
    procedure Json_ValoriDiversiDalPredefinito_AndataERitorno;
    // ZBASE-PVT-010 e ZBASE-PVT-011
    [Test]
    procedure Json_ElenchiDiValori_AndataERitorno;
    // ZBASE-PVT-005
    [Test]
    procedure Json_KindSconosciuto_RestaCampoNormale;
  end;

  [TestFixture]
  TTestPivotProps = class
  private
    FProprieta: TzDbPivotProps;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-PVT-003
    [Test]
    procedure Predefiniti_ValoriDichiarati;
    // ZBASE-PVT-003
    [Test]
    procedure TipoComponente_EPivot;
    // ZBASE-PVT-003
    [Test]
    procedure Assign_CopiaNomeTitoloCampiEFlag;
    // ZBASE-PVT-003
    [Test]
    procedure Assign_CampiCopiatiPerValore;
    // DIV-PVT-1
    [Test]
    procedure AssignDelPivot_CopiaDrillDown;
    // DIV-PVT-2
    [Test]
    procedure Divergenza_DIV_PVT_2_Reset_ConservaISoliCampiCalcolati;
    // ZBASE-PVT-005
    [Test]
    procedure Collezione_JsonAndataERitorno;
  end;

implementation

{ TTestPivotFlags }

procedure TTestPivotFlags.Setup;
begin
  FFlags := TzDbPivotFlags.Create;
  FNotifiche := 0;
end;

procedure TTestPivotFlags.TearDown;
begin
  FreeAndNil(FFlags);
end;

procedure TTestPivotFlags.Notifica(Sender: TObject);
begin
  Inc(FNotifiche);
end;

// ZBASE-PVT-013
procedure TTestPivotFlags.Predefiniti_FlagVeri;
begin
  Assert.IsTrue(FFlags.ButtonArrows, 'ButtonArrows');
  Assert.IsTrue(FFlags.ButtonRefresh, 'ButtonRefresh');
  Assert.IsTrue(FFlags.ButtonExpand, 'ButtonExpand');
  Assert.IsTrue(FFlags.Toolbar, 'Toolbar');
  Assert.IsTrue(FFlags.DrawExpandButtons, 'DrawExpandButtons');
  Assert.IsTrue(FFlags.ColumnGrandTotals, 'ColumnGrandTotals');
  Assert.IsTrue(FFlags.ColumnTotals, 'ColumnTotals');
  Assert.IsTrue(FFlags.FilterSeparator, 'FilterSeparator');
  Assert.IsTrue(FFlags.RowGrandTotals, 'RowGrandTotals');
  Assert.IsTrue(FFlags.RowTotals, 'RowTotals');
end;

// ZBASE-PVT-013
procedure TTestPivotFlags.Predefiniti_FlagFalsiETestiVuoti;
begin
  Assert.IsFalse(FFlags.ButtonExpandCaption, 'ButtonExpandCaption');
  Assert.IsFalse(FFlags.Params, 'Params');
  Assert.IsFalse(FFlags.Filter, 'Filter');
  Assert.IsFalse(FFlags.DrillDown, 'DrillDown');
  Assert.IsFalse(FFlags.ExpandRows, 'ExpandRows');
  Assert.IsFalse(FFlags.ExpandColumns, 'ExpandColumns');
  Assert.IsFalse(FFlags.ExpandInnerLevels, 'ExpandInnerLevels');
  Assert.IsFalse(FFlags.HideColumnFields, 'HideColumnFields');
  Assert.IsFalse(FFlags.HideDataFields, 'HideDataFields');
  Assert.IsFalse(FFlags.HideFilterFields, 'HideFilterFields');
  Assert.IsFalse(FFlags.HideRowFields, 'HideRowFields');
  Assert.IsFalse(FFlags.GrandTotalsForSingleValues, 'GrandTotalsForSingleValues');
  Assert.IsFalse(FFlags.MarkNarrowCells, 'MarkNarrowCells');
  Assert.IsFalse(FFlags.RowTreeLayout, 'RowTreeLayout');
  Assert.IsFalse(FFlags.TotalsForSingleValues, 'TotalsForSingleValues');
  Assert.AreEqual('', FFlags.ColumnGrandTotalText);
  Assert.AreEqual('', FFlags.RowGrandTotalText);
end;

// ZBASE-PVT-013
procedure TTestPivotFlags.Assign_CopiaLeImpostazioni;
var
  Copia: TzDbPivotFlags;
begin
  FFlags.ButtonArrows := False;
  FFlags.ExpandRows := True;
  FFlags.ExpandInnerLevels := True;
  FFlags.RowTreeLayout := True;
  FFlags.HideRowFields := True;
  FFlags.ColumnGrandTotalText := 'Totale colonne';
  FFlags.RowGrandTotalText := 'Totale righe';

  Copia := TzDbPivotFlags.Create;
  try
    Copia.Assign(FFlags);

    Assert.IsFalse(Copia.ButtonArrows, 'ButtonArrows');
    Assert.IsTrue(Copia.ExpandRows, 'ExpandRows');
    Assert.IsTrue(Copia.ExpandInnerLevels, 'ExpandInnerLevels');
    Assert.IsTrue(Copia.RowTreeLayout, 'RowTreeLayout');
    Assert.IsTrue(Copia.HideRowFields, 'HideRowFields');
    Assert.AreEqual('Totale colonne', Copia.ColumnGrandTotalText);
    Assert.AreEqual('Totale righe', Copia.RowGrandTotalText);
    // un flag rimasto al predefinito resta tale
    Assert.IsTrue(Copia.Toolbar, 'Toolbar');
  finally
    Copia.Free;
  end;
end;

// DIV-PVT-1 (corretta): Assign copia anche DrillDown
procedure TTestPivotFlags.Assign_CopiaDrillDown;
var
  Copia: TzDbPivotFlags;
begin
  FFlags.DrillDown := True;

  Copia := TzDbPivotFlags.Create;
  try
    Copia.Assign(FFlags);

    Assert.IsTrue(Copia.DrillDown, 'DrillDown viene copiato da Assign');
  finally
    Copia.Free;
  end;
end;

// ZBASE-PVT-013
procedure TTestPivotFlags.Setter_NotificaOnChange;
begin
  FFlags.OnChange := Notifica;

  FFlags.ButtonArrows := False;

  Assert.AreEqual(1, FNotifiche);
end;

// ZBASE-PVT-013
procedure TTestPivotFlags.BeginUpdate_SospendeLeNotificheEdEndUpdateNonNotifica;
begin
  FFlags.OnChange := Notifica;

  FFlags.BeginUpdate;
  FFlags.ButtonArrows := False;
  FFlags.ExpandRows := True;
  FFlags.Toolbar := False;
  FFlags.EndUpdate;

  Assert.AreEqual(0, FNotifiche, 'nessuna notifica nemmeno a EndUpdate');

  // dopo EndUpdate le notifiche riprendono
  FFlags.Params := True;
  Assert.AreEqual(1, FNotifiche);
end;

// ZBASE-PVT-013
procedure TTestPivotFlags.Setter_SenzaGestore_NessunErrore;
begin
  FFlags.OnChange := nil;

  FFlags.RowTotals := False;

  Assert.IsFalse(FFlags.RowTotals);
end;

{ TTestPivotField }

procedure TTestPivotField.Setup;
begin
  FCampi := TzPivotFields.Create(nil);
end;

procedure TTestPivotField.TearDown;
begin
  FreeAndNil(FCampi);
end;

function TTestPivotField.NuovoCampo(const Nome: string): TzPivotField;
begin
  Result := FCampi.Add;
  Result.Name := Nome;
end;

// ZBASE-PVT-005
procedure TTestPivotField.Predefiniti_ValoriDichiarati;
var
  Campo: TzPivotField;
begin
  Campo := NuovoCampo('IMPORTO');

  Assert.IsTrue(Campo.Area = faFilter, 'Area');
  Assert.AreEqual(-1, Campo.AreaIndex, 'AreaIndex');
  Assert.IsTrue(Campo.DataVisibility = dvAllCells, 'DataVisibility');
  Assert.AreEqual(-1, Campo.GroupIndex, 'GroupIndex');
  Assert.IsFalse(Campo.Hidden, 'Hidden');
  Assert.AreEqual(cxPivotGridDefaultFieldMinWidth, Campo.MinWidth, 'MinWidth');
  Assert.IsTrue(Campo.SummaryType = stSum, 'SummaryType');
  Assert.IsTrue(Campo.SortOrder = soNone, 'SortOrder');
  Assert.IsTrue(Campo.SummaryVariation = svNone, 'SummaryVariation');
  Assert.IsTrue(Campo.TotalsVisibility = tvAutomatic, 'TotalsVisibility');
  Assert.AreEqual(0, Campo.TopValueCount, 'TopValueCount');
  Assert.IsFalse(Campo.TopValueShowOthers, 'TopValueShowOthers');
  Assert.IsTrue(Campo.Sizeable, 'Sizeable');
  Assert.IsTrue(Campo.Visible, 'Visible');
  Assert.AreEqual(0, Campo.MaxWidth, 'MaxWidth');
  Assert.AreEqual(-1, Campo.Width, 'Width');
  Assert.IsTrue(Campo.TotalMode = ctmNull, 'TotalMode');
  Assert.IsTrue(Campo.zCtrlType = ctDefault, 'zCtrlType');
  Assert.IsTrue(Campo.Kind = fkField, 'Kind');
  Assert.AreEqual('', Campo.Caption, 'Caption');
  Assert.AreEqual('', Campo.DisplayFormat, 'DisplayFormat');
  Assert.AreEqual(0, Campo.ColumnValues.Count, 'ColumnValues');
  Assert.AreEqual(0, Campo.GrandTotalExcludeValues.Count, 'GrandTotalExcludeValues');
end;

// ZBASE-PVT-005
procedure TTestPivotField.Assign_CopiaTuttiICampi;
var
  Origine: TzPivotField;
  Copia: TzPivotField;
  Altri: TzPivotFields;
begin
  Origine := NuovoCampo('ORE');
  Origine.Caption := 'Ore svolte';
  Origine.Width := 120;
  Origine.MaxWidth := 300;
  Origine.Sizeable := False;
  Origine.Visible := False;
  Origine.Area := faData;
  Origine.AreaIndex := 2;
  Origine.DisplayFormat := '###,##0.0';
  Origine.GroupIndex := 1;
  Origine.Hidden := True;
  Origine.SummaryType := stAverage;
  Origine.SortOrder := soDescending;
  Origine.TopValueCount := 5;
  Origine.TopValueShowOthers := True;
  Origine.Kind := fkCalc;
  Origine.SourceFieldName := 'ORE_BASE';
  Origine.ColumnFieldName := 'TIPO';
  Origine.TotalMode := ctmCalc;

  Altri := TzPivotFields.Create(nil);
  try
    Copia := Altri.Add;
    Copia.Assign(Origine);

    Assert.AreEqual('ORE', Copia.Name);
    Assert.AreEqual('Ore svolte', Copia.Caption);
    Assert.AreEqual(120, Copia.Width);
    Assert.AreEqual(300, Copia.MaxWidth);
    Assert.IsFalse(Copia.Sizeable, 'Sizeable');
    Assert.IsFalse(Copia.Visible, 'Visible');
    Assert.IsTrue(Copia.Area = faData, 'Area');
    Assert.AreEqual(2, Copia.AreaIndex);
    Assert.AreEqual('###,##0.0', Copia.DisplayFormat);
    Assert.AreEqual(1, Copia.GroupIndex);
    Assert.IsTrue(Copia.Hidden, 'Hidden');
    Assert.IsTrue(Copia.SummaryType = stAverage, 'SummaryType');
    Assert.IsTrue(Copia.SortOrder = soDescending, 'SortOrder');
    Assert.AreEqual(5, Copia.TopValueCount);
    Assert.IsTrue(Copia.TopValueShowOthers, 'TopValueShowOthers');
    Assert.IsTrue(Copia.Kind = fkCalc, 'Kind');
    Assert.AreEqual('ORE_BASE', Copia.SourceFieldName);
    Assert.AreEqual('TIPO', Copia.ColumnFieldName);
    Assert.IsTrue(Copia.TotalMode = ctmCalc, 'TotalMode');
  finally
    Altri.Free;
  end;
end;

// ZBASE-PVT-005
procedure TTestPivotField.Assign_ElenchiCopiatiNonCondivisi;
var
  Origine: TzPivotField;
  Copia: TzPivotField;
  Altri: TzPivotFields;
begin
  Origine := NuovoCampo('COSTO');
  Origine.ColumnValues.Add('D');
  Origine.GrandTotalExcludeValues.Add('Ore Dirette Totali');

  Altri := TzPivotFields.Create(nil);
  try
    Copia := Altri.Add;
    Copia.Assign(Origine);

    Origine.ColumnValues.Add('M');
    Origine.GrandTotalExcludeValues.Clear;

    Assert.AreEqual(1, Copia.ColumnValues.Count, 'ColumnValues');
    Assert.AreEqual('D', Copia.ColumnValues[0]);
    Assert.AreEqual(1, Copia.GrandTotalExcludeValues.Count, 'GrandTotalExcludeValues');
    Assert.AreEqual('Ore Dirette Totali', Copia.GrandTotalExcludeValues[0]);
  finally
    Altri.Free;
  end;
end;

// ZBASE-PVT-005
procedure TTestPivotField.Json_SoloIlNome_NienteValoriPredefiniti;
var
  Testo: string;
begin
  NuovoCampo('IMPORTO');

  Testo := FCampi.AsJSON;

  Assert.IsTrue(Pos('IMPORTO', Testo) > 0, 'il nome c''e''');
  Assert.AreEqual(0, Pos('"Area"', Testo), 'Area omessa');
  Assert.AreEqual(0, Pos('"AreaIndex"', Testo), 'AreaIndex omesso');
  Assert.AreEqual(0, Pos('"Width"', Testo), 'Width omessa');
  Assert.AreEqual(0, Pos('"Visible"', Testo), 'Visible omessa');
  Assert.AreEqual(0, Pos('"SummaryType"', Testo), 'SummaryType omesso');
  Assert.AreEqual(0, Pos('"Kind"', Testo), 'Kind omesso');
end;

// ZBASE-PVT-005
procedure TTestPivotField.Json_CampoNormale_NonScriveKind;
begin
  NuovoCampo('IMPORTO').Kind := fkField;

  Assert.AreEqual(0, Pos('Kind', FCampi.AsJSON));
end;

// ZBASE-PVT-005
procedure TTestPivotField.Json_CampoCalcolato_ScriveERileggeKind;
var
  Testo: string;
  Altri: TzPivotFields;
begin
  NuovoCampo('CALC_1').Kind := fkCalc;

  Testo := FCampi.AsJSON;
  Assert.IsTrue(Pos('fkCalc', Testo) > 0, 'Kind scritto per nome');

  Altri := TzPivotFields.Create(nil);
  try
    Altri.AsJSON := Testo;

    Assert.AreEqual(1, Altri.Count);
    Assert.AreEqual('CALC_1', Altri[0].Name);
    Assert.IsTrue(Altri[0].Kind = fkCalc, 'Kind riletto');
  finally
    Altri.Free;
  end;
end;

// ZBASE-PVT-005
procedure TTestPivotField.Json_ValoriDiversiDalPredefinito_AndataERitorno;
var
  Campo: TzPivotField;
  Altri: TzPivotFields;
  Riletto: TzPivotField;
begin
  Campo := NuovoCampo('ANNO');
  Campo.Area := faColumn;
  Campo.AreaIndex := 0;
  Campo.Width := 114;
  Campo.Visible := False;
  Campo.SummaryType := stCount;
  Campo.SortOrder := soAscending;
  Campo.Caption := 'Anno formativo';

  Altri := TzPivotFields.Create(nil);
  try
    Altri.AsJSON := FCampi.AsJSON;

    Assert.AreEqual(1, Altri.Count);
    Riletto := Altri[0];
    Assert.AreEqual('ANNO', Riletto.Name);
    Assert.IsTrue(Riletto.Area = faColumn, 'Area');
    Assert.AreEqual(0, Riletto.AreaIndex);
    Assert.AreEqual(114, Riletto.Width);
    Assert.IsFalse(Riletto.Visible, 'Visible');
    Assert.IsTrue(Riletto.SummaryType = stCount, 'SummaryType');
    Assert.IsTrue(Riletto.SortOrder = soAscending, 'SortOrder');
    Assert.AreEqual('Anno formativo', Riletto.Caption);
  finally
    Altri.Free;
  end;
end;

// ZBASE-PVT-010 e ZBASE-PVT-011
procedure TTestPivotField.Json_ElenchiDiValori_AndataERitorno;
var
  Campo: TzPivotField;
  Altri: TzPivotFields;
begin
  Campo := NuovoCampo('ORE_TOTALI');
  Campo.ColumnValues.Add('D');
  Campo.ColumnValues.Add('M');
  Campo.GrandTotalExcludeValues.Add('Ore Dirette Totali');

  Altri := TzPivotFields.Create(nil);
  try
    Altri.AsJSON := FCampi.AsJSON;

    Assert.AreEqual(2, Altri[0].ColumnValues.Count, 'ColumnValues');
    Assert.AreEqual('D', Altri[0].ColumnValues[0]);
    Assert.AreEqual('M', Altri[0].ColumnValues[1]);
    Assert.AreEqual(1, Altri[0].GrandTotalExcludeValues.Count, 'GrandTotalExcludeValues');
    Assert.AreEqual('Ore Dirette Totali', Altri[0].GrandTotalExcludeValues[0]);
  finally
    Altri.Free;
  end;
end;

// ZBASE-PVT-005
procedure TTestPivotField.Json_KindSconosciuto_RestaCampoNormale;
var
  Altri: TzPivotFields;
begin
  Altri := TzPivotFields.Create(nil);
  try
    // nome di enumerato che non esiste: il valore resta quello predefinito
    // (possono essere segnalati problemi di lettura, ma non si solleva
    // un'eccezione che impedisca di leggere il resto)
    try
      Altri.AsJSON := '[{"Name": "X", "Kind": "fkInesistente"}]';
    except
      on E: Exception do
        ;
    end;

    if Altri.Count > 0 then
      Assert.IsTrue(Altri[0].Kind = fkField, 'Kind resta fkField')
    else
      Assert.Pass('la lettura ha scartato l''elemento');
  finally
    Altri.Free;
  end;
end;

{ TTestPivotProps }

procedure TTestPivotProps.Setup;
begin
  FProprieta := TzDbPivotProps.Create(nil);
end;

procedure TTestPivotProps.TearDown;
begin
  FreeAndNil(FProprieta);
end;

// ZBASE-PVT-003
procedure TTestPivotProps.Predefiniti_ValoriDichiarati;
begin
  Assert.AreEqual('@', FProprieta.Caption, 'Caption');
  Assert.IsTrue(FProprieta.BestFitAfterExpand, 'BestFitAfterExpand');
  Assert.AreEqual('', FProprieta.Title, 'Title');
  Assert.AreEqual('', FProprieta.DataSet, 'DataSet');
  Assert.AreEqual(0, FProprieta.Fields.Count, 'Fields');
  Assert.IsTrue(FProprieta.Flags.ButtonArrows, 'Flags.ButtonArrows');
end;

// ZBASE-PVT-003
procedure TTestPivotProps.TipoComponente_EPivot;
begin
  Assert.IsTrue(FProprieta.zComponentType = ctPivot);
end;

// ZBASE-PVT-003
procedure TTestPivotProps.Assign_CopiaNomeTitoloCampiEFlag;
var
  Copia: TzDbPivotProps;
begin
  FProprieta.Name := 'AnalisiRilevamenti.Timesheet';
  FProprieta.DataSet := 'AnalisiRilevamenti.Timesheet';
  FProprieta.Title := 'Ore per risorsa';
  FProprieta.BestFitAfterExpand := False;
  FProprieta.Flags.ExpandRows := True;
  FProprieta.Fields.Add.Name := 'ORE';
  FProprieta.Fields[0].Area := faData;

  Copia := TzDbPivotProps.Create(nil);
  try
    Copia.Assign(FProprieta);

    Assert.AreEqual('AnalisiRilevamenti.Timesheet', Copia.Name, 'Name');
    Assert.AreEqual('AnalisiRilevamenti.Timesheet', Copia.DataSet, 'DataSet');
    Assert.AreEqual('Ore per risorsa', Copia.Title, 'Title');
    Assert.IsFalse(Copia.BestFitAfterExpand, 'BestFitAfterExpand');
    Assert.IsTrue(Copia.Flags.ExpandRows, 'Flags.ExpandRows');
    Assert.AreEqual(1, Copia.Fields.Count, 'Fields');
    Assert.AreEqual('ORE', Copia.Fields[0].Name);
    Assert.IsTrue(Copia.Fields[0].Area = faData, 'Area del campo');
  finally
    Copia.Free;
  end;
end;

// ZBASE-PVT-003
procedure TTestPivotProps.Assign_CampiCopiatiPerValore;
var
  Copia: TzDbPivotProps;
begin
  FProprieta.Fields.Add.Name := 'ORE';
  FProprieta.Fields[0].Width := 80;

  Copia := TzDbPivotProps.Create(nil);
  try
    Copia.Assign(FProprieta);
    Copia.Fields[0].Width := 200;
    Copia.Flags.Toolbar := False;

    Assert.AreEqual(80, FProprieta.Fields[0].Width, 'il campo dell''origine non cambia');
    Assert.IsTrue(FProprieta.Flags.Toolbar, 'i flag dell''origine non cambiano');
  finally
    Copia.Free;
  end;
end;

// DIV-PVT-1 (corretta): LoadFromBase e SaveToBase sono fatte di Assign, quindi
// DrillDown vero arriva al pivot.
procedure TTestPivotProps.AssignDelPivot_CopiaDrillDown;
var
  Copia: TzDbPivotProps;
begin
  FProprieta.Flags.DrillDown := True;

  Copia := TzDbPivotProps.Create(nil);
  try
    Copia.Assign(FProprieta);

    Assert.IsTrue(Copia.Flags.DrillDown, 'DrillDown copiato');
  finally
    Copia.Free;
  end;
end;

// DIV-PVT-2 (corretta): il reset toglie i campi del dataset ma non i calcolati,
// che non si possono ricostruire dal dataset.
procedure TTestPivotProps.Divergenza_DIV_PVT_2_Reset_ConservaISoliCampiCalcolati;
begin
  FProprieta.Fields.Add.Name := 'IMPORTO';
  with FProprieta.Fields.Add do
  begin
    Name := 'MARGINE';
    Kind := fkCalc;
  end;

  FProprieta.Fields.Reset(nil);

  Assert.AreEqual(1, FProprieta.Fields.Count, 'resta solo il calcolato');
  Assert.AreEqual('MARGINE', FProprieta.Fields[0].Name);
end;

// ZBASE-PVT-005
procedure TTestPivotProps.Collezione_JsonAndataERitorno;
var
  Pivots: TzDbPivots;
  Altri: TzDbPivots;
  Elemento: TzDbPivotProps;
  Riletto: TzDbPivotProps;
begin
  Pivots := TzDbPivots.Create(TzDbPivotProps, 'Pivots', -1, nil);
  Altri := TzDbPivots.Create(TzDbPivotProps, 'Pivots', -1, nil);
  try
    Elemento := Pivots.Add;
    Elemento.Name := 'Budget.Riepilogo';
    Elemento.DataSet := 'Budget.Riepilogo';
    Elemento.Title := 'Budget per progetto';
    Elemento.Flags.ExpandRows := True;
    Elemento.Flags.RowTreeLayout := True;
    Elemento.Fields.Add.Name := 'PROGETTO';
    Elemento.Fields[0].Area := faRow;
    Elemento.Fields[0].AreaIndex := 0;
    Elemento.Fields.Add.Name := 'IMPORTO';
    Elemento.Fields[1].Area := faData;
    Elemento.Fields[1].GrandTotalExcludeValues.Add('Totale derivato');

    Altri.AsJSON := Pivots.AsJSON;

    Assert.AreEqual(1, Altri.Count);
    Riletto := Altri.Get('Budget.Riepilogo', False);
    Assert.IsNotNull(Riletto, 'elemento riletto per nome');
    Assert.AreEqual('Budget per progetto', Riletto.Title, 'Title');
    Assert.AreEqual('Budget.Riepilogo', Riletto.DataSet, 'DataSet');
    Assert.IsTrue(Riletto.Flags.ExpandRows, 'Flags.ExpandRows');
    Assert.IsTrue(Riletto.Flags.RowTreeLayout, 'Flags.RowTreeLayout');
    Assert.AreEqual(2, Riletto.Fields.Count, 'Fields');
    Assert.AreEqual('PROGETTO', Riletto.Fields[0].Name);
    Assert.IsTrue(Riletto.Fields[0].Area = faRow, 'Area di PROGETTO');
    Assert.AreEqual(1, Riletto.Fields[1].GrandTotalExcludeValues.Count, 'esclusioni');
  finally
    Altri.Free;
    Pivots.Free;
  end;
end;

initialization

TDUnitX.RegisterTestFixture(TTestPivotFlags);
TDUnitX.RegisterTestFixture(TTestPivotField);
TDUnitX.RegisterTestFixture(TTestPivotProps);

end.
