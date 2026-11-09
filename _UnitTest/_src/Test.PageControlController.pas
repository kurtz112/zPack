// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.PageControlController;

// Test DUnitX di zBase\PageControlController (specifica ZBASE-PGC,
// "Controller delle pagine.md").
//
// La form e' creata con CreateNew e mai mostrata; i contenitori a schede
// (TcxPageControl) non hanno genitore ne' handle. Si provano:
//   - i valori iniziali e l'aggancio dell'evento OnChange con ripresa del
//     gestore originale (ZBASE-PGC-001);
//   - ActivateDataSets senza schede di dati (ZBASE-PGC-002, solo "non
//     solleva");
//   - il ritorno alla prima pagina visibile (ZBASE-PGC-003);
//   - il calcolo dell'altezza che non parte senza finestra o con
//     allineamento diverso (ZBASE-PGC-004) e quando e' sospeso
//     (ZBASE-PGC-005).
// Restano senza prova l'attivazione vera dei dataset (richiede TzDbCard,
// TzDbView e il database) e il calcolo vero dell'altezza (richiede un handle).
//
// DIV-PGC-4 fotografa il comportamento attuale: va capovolta quando il
// codice non sovrascrive piu' Tag. DIV-PGC-1 (ricorsione infinita del gestore
// al secondo aggancio) e' corretta ed e' provata come comportamento voluto.

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,
  cxPC,
  DUnitX.TestFramework,
  zDbCard,
  PageControlController;

type
  TzDbCardProva = class(TzDbCard)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    class var HandleGenitore: HWND;
  end;

  [TestFixture]
  TTestPageControlController = class
  private
    FForm: TForm;
    FController: TPageControlController;
    FConteggio: Integer;
    procedure ContaCambiamenti(Sender: TObject);
    function NuovoContenitore: TcxPageControl;
    function NuovaPagina(Contenitore: TcxPageControl): TcxTabSheet;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-PGC-001
    [Test]
    procedure Creazione_DisableCalcSizeFalso;
    // ZBASE-PGC-001
    [Test]
    procedure InitForm_ConGestoreOriginale_LoRichiamaDopoQuelloDelController;
    // ZBASE-PGC-001
    [Test]
    procedure InitForm_SenzaGestoreOriginale_IlCambioSchedaNonSolleva;
    // ZBASE-PGC-001 e DIV-PGC-1
    [Test]
    procedure InitForm_ChiamatoDueVolteSenzaGestoreOriginale_IlCambioSchedaNonVaInRicorsione;
    // ZBASE-PGC-001 e DIV-PGC-1
    [Test]
    procedure InitForm_ChiamatoDueVolteConGestoreOriginale_LoRichiamaUnaVoltaSola;
    // ZBASE-PGC-001
    [Test]
    procedure InitForm_ContenitoriDiAltroProprietario_NonSonoAgganciati;
    // ZBASE-PGC-002
    [Test]
    procedure ActivateDataSets_SenzaSchedeDiDati_NonSolleva;
    // ZBASE-PGC-002
    [Test]
    procedure ActivateDataSets_ContenitoreNascosto_NonSolleva;
    // ZBASE-PGC-003
    [Test]
    [Ignore('R-213: senza finestra il TcxPageControl non applica ActivePageIndex; da provare con la sonda')]
    procedure ResetActivePages_PrimaPaginaVisibile_LaAttiva;
    // ZBASE-PGC-003
    [Test]
    procedure ResetActivePages_ContenitoreVuoto_NonSolleva;
    // ZBASE-PGC-004
    [Test]
    procedure AutoSizePageControls_SenzaFinestra_LAltezzaNonCambia;
    // ZBASE-PGC-004
    [Test]
    procedure AutoSizePageControls_AllineamentoClient_LAltezzaNonCambia;
    // ZBASE-PGC-005
    [Test]
    procedure DisableCalcSize_Vero_ICambiSchedaNonModificanoLAltezza;
    // ZBASE-PGC-004 e DIV-PGC-3
    [Test]
    procedure InitForm_SchedaDiDatiPossedutaDallaForm_TagUgualeAllAltezza;
    // DIV-PGC-4
    [Test]
    procedure Divergenza_DIV_PGC_4_LAggancioSovrascriveTag;
  end;

implementation

procedure TzDbCardProva.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Params.WndParent = 0 then
    Params.WndParent := HandleGenitore;
end;

// TTestPageControlController

procedure TTestPageControlController.Setup;
begin
  FForm := TForm.CreateNew(nil);
  FController := TPageControlController.Create(FForm);
  FConteggio := 0;
end;

procedure TTestPageControlController.TearDown;
begin
  // Il controller e' un componente della form e si libera con lei
  FreeAndNil(FForm);
end;

procedure TTestPageControlController.ContaCambiamenti(Sender: TObject);
begin
  Inc(FConteggio);
end;

function TTestPageControlController.NuovoContenitore: TcxPageControl;
begin
  Result := TcxPageControl.Create(FForm);
end;

function TTestPageControlController.NuovaPagina(Contenitore: TcxPageControl): TcxTabSheet;
begin
  Result := TcxTabSheet.Create(FForm);
  Result.PageControl := Contenitore;
end;

procedure TTestPageControlController.Creazione_DisableCalcSizeFalso;
begin
  Assert.IsFalse(FController.DisableCalcSize);
end;

procedure TTestPageControlController.InitForm_ConGestoreOriginale_LoRichiamaDopoQuelloDelController;
var
  Contenitore: TcxPageControl;
  Originale: TNotifyEvent;
begin
  // Calcolo sospeso: il gestore del controller non tocca l'altezza
  FController.DisableCalcSize := True;
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Originale := ContaCambiamenti;
  Contenitore.OnChange := Originale;

  FController.InitForm(FForm);

  // L'evento del contenitore e' ora quello del controller...
  Assert.IsTrue(TMethod(Contenitore.OnChange).Code <> TMethod(Originale).Code);

  // ...che richiama quello originale una volta sola
  Contenitore.OnChange(Contenitore);
  Assert.AreEqual(1, FConteggio);
end;

procedure TTestPageControlController.InitForm_SenzaGestoreOriginale_IlCambioSchedaNonSolleva;
var
  Contenitore: TcxPageControl;
begin
  FController.DisableCalcSize := True;
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);

  FController.InitForm(FForm);

  Assert.IsTrue(Assigned(Contenitore.OnChange));
  Assert.WillNotRaiseAny(
    procedure
    begin
      Contenitore.OnChange(Contenitore);
    end);
end;

procedure TTestPageControlController.InitForm_ChiamatoDueVolteSenzaGestoreOriginale_IlCambioSchedaNonVaInRicorsione;
var
  Contenitore: TcxPageControl;
begin
  FController.DisableCalcSize := True;
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);

  // Prima della correzione il secondo aggancio leggeva come «originale» il
  // gestore del controller e il cambio scheda andava in overflow dello stack
  FController.InitForm(FForm);
  FController.InitForm(FForm);

  Assert.WillNotRaiseAny(
    procedure
    begin
      Contenitore.OnChange(Contenitore);
    end);
end;

procedure TTestPageControlController.InitForm_ChiamatoDueVolteConGestoreOriginale_LoRichiamaUnaVoltaSola;
var
  Contenitore: TcxPageControl;
begin
  FController.DisableCalcSize := True;
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Contenitore.OnChange := ContaCambiamenti;

  FController.InitForm(FForm);
  FController.InitForm(FForm);

  Contenitore.OnChange(Contenitore);
  Assert.AreEqual(1, FConteggio);
end;

procedure TTestPageControlController.InitForm_ContenitoriDiAltroProprietario_NonSonoAgganciati;
var
  Altro: TComponent;
  Contenitore: TcxPageControl;
begin
  // Un contenitore posseduto da un altro componente non e' fra quelli del proprietario
  Altro := TComponent.Create(nil);
  try
    Contenitore := TcxPageControl.Create(Altro);

    FController.InitForm(FForm);

    Assert.IsFalse(Assigned(Contenitore.OnChange));
  finally
    Altro.Free;
  end;
end;

procedure TTestPageControlController.ActivateDataSets_SenzaSchedeDiDati_NonSolleva;
var
  Contenitore: TcxPageControl;
begin
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);

  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.ActivateDataSets;
    end);
end;

procedure TTestPageControlController.ActivateDataSets_ContenitoreNascosto_NonSolleva;
var
  Contenitore: TcxPageControl;
begin
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Contenitore.Visible := False;

  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.ActivateDataSets;
    end);
end;

procedure TTestPageControlController.ResetActivePages_PrimaPaginaVisibile_LaAttiva;
var
  Contenitore: TcxPageControl;
  PaginaUno, PaginaDue, PaginaTre: TcxTabSheet;
begin
  Contenitore := NuovoContenitore;
  PaginaUno := NuovaPagina(Contenitore);
  PaginaDue := NuovaPagina(Contenitore);
  PaginaTre := NuovaPagina(Contenitore);
  PaginaUno.TabVisible := False;
  Assert.IsFalse(PaginaUno.Visible, 'precondizione: la prima pagina deve risultare nascosta');
  Contenitore.ActivePage := PaginaTre;

  FController.ResetActivePages;

  Assert.AreEqual(1, Contenitore.ActivePageIndex);
  Assert.AreSame(TObject(PaginaDue), TObject(Contenitore.ActivePage));
end;

procedure TTestPageControlController.ResetActivePages_ContenitoreVuoto_NonSolleva;
begin
  NuovoContenitore;

  Assert.WillNotRaiseAny(
    procedure
    begin
      FController.ResetActivePages;
    end);
end;

procedure TTestPageControlController.AutoSizePageControls_SenzaFinestra_LAltezzaNonCambia;
var
  Contenitore: TcxPageControl;
begin
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Contenitore.Align := alTop;
  Contenitore.Height := 120;

  FController.AutoSizePageControls;

  Assert.AreEqual(120, Contenitore.Height);
end;

procedure TTestPageControlController.AutoSizePageControls_AllineamentoClient_LAltezzaNonCambia;
var
  Contenitore: TcxPageControl;
begin
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Contenitore.Align := alClient;
  Contenitore.Height := 150;
  Assert.AreEqual(150, Contenitore.Height, 'precondizione');

  FController.AutoSizePageControls;

  Assert.AreEqual(150, Contenitore.Height);
end;

procedure TTestPageControlController.DisableCalcSize_Vero_ICambiSchedaNonModificanoLAltezza;
var
  Contenitore: TcxPageControl;
begin
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Contenitore.Align := alTop;
  Contenitore.Height := 90;
  FController.InitForm(FForm);
  FController.DisableCalcSize := True;

  Contenitore.OnChange(Contenitore);
  FController.AutoSizePageControls;

  Assert.AreEqual(90, Contenitore.Height);
end;

// DIV-PGC-3 corretta: la scheda di dati e' posseduta dalla form ma sta dentro
// il contenitore, e l'aggancio la trova.
procedure TTestPageControlController.InitForm_SchedaDiDatiPossedutaDallaForm_TagUgualeAllAltezza;
var
  Contenitore: TcxPageControl;
  Pagina: TcxTabSheet;
  Scheda: TzDbCard;
begin
  // la scheda di dati e' un frame e chiede una finestra genitore gia' nel
  // costruttore: la fornisce la finestra della form di prova
  FForm.HandleNeeded;
  TzDbCardProva.HandleGenitore := FForm.Handle;
  Contenitore := NuovoContenitore;
  Contenitore.Align := alTop;
  Contenitore.Height := 90;
  Pagina := NuovaPagina(Contenitore);
  Scheda := TzDbCardProva.Create(FForm);
  Scheda.Parent := Pagina;

  FController.InitForm(FForm);

  Assert.AreEqual(90, Contenitore.Tag);
end;

procedure TTestPageControlController.Divergenza_DIV_PGC_4_LAggancioSovrascriveTag;
var
  Contenitore: TcxPageControl;
begin
  Contenitore := NuovoContenitore;
  NuovaPagina(Contenitore);
  Contenitore.Align := alTop;
  Contenitore.Tag := 77;

  FController.InitForm(FForm);

  // Oggi il Tag impostato dal chiamante viene cancellato (nessuna scheda di
  // dati: diventa 0). Quando il codice usa un campo proprio al posto di Tag,
  // questo test va capovolto (Tag deve restare 77).
  Assert.AreEqual(0, Contenitore.Tag);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPageControlController);

end.
