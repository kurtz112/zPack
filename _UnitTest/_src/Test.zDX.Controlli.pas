// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDX.Controlli;

// Test DUnitX per zBase\zDX.pas (specifica ZBASE-ICO, "Icone, barre e
// inizializzazione dei controlli.md").
// BOZZA scritta senza poterla compilare ne' eseguire.
//
// Due modi di avere un Tdx senza finestre:
// - Tdx.CreateNew(nil): modulo senza DFM e senza il corpo del costruttore di
//   Tdx (nessun componente creato, campi nil). Basta per le funzioni che non
//   toccano i componenti del modulo: mappatura delle classi (ZBASE-ICO-011),
//   InitProperties (012, 013), InitDateEdit, InitTimeEdit, InitButtonEdit,
//   InitColorCombo (014, 015), GetBitmap e Visible (003). Per ctLookupHyperLink
//   e ctPickListImage (usano Glyphs e Immagini) serve il modulo completo.
// - dx: il modulo completo, creato dal costruttore vero (DFM, stili, look and
//   feel dei layout, correttore ortografico). Si crea una sola volta per
//   fixture e vive fino alla chiusura del programma di prova. Se la creazione
//   non riesce in un programma console (skin, traduzione), cadono tutte le
//   prove della fixture TTestzDXModulo e restano valide le altre.
//
// I controlli si creano con Create(Finestra) su una TForm creata con CreateNew
// e mai mostrata: niente parent e niente handle. Quindi non si provano gli
// effetti che richiedono una finestra vera (ActivePageIndex di InitPageControl,
// controllo realizzato di una barra, misure di LayoutControlHeigth con elementi).
//
// Le divergenze provate (DIV-ICO-1, 2, 10, 11) fotografano il comportamento
// attuale: vanno capovolte quando il codice viene corretto.
//
// Restano senza prova, perche' richiedono una finestra, un file di skin o la
// sonda: InitSkinChooserGalleryItem, InitRibbonSkinSelector,
// RibbonSkinSelectorApplySkin (file .skinres e ribbon), InitScheduler (basta il
// controllo ma e' un componente pesante e con 4 usi), Alert (mostra una
// finestra), ShowSpellingOptionsDialog, PrepareSpellCheckerPopup, dxBarMouseDown
// (privato nella pratica: serve un controllo di barra realizzato),
// DrawBandSeparator (serve un canvas e le informazioni di disegno), ReadState
// (si prova solo ricaricando il DFM con PixelsPerInch diverso da 0),
// ApplicazioneModalBegin (privato), il ramo della picklist di InitProperties
// con dominio (serve il dizionario con le liste di valori) e
// zzSmartTextToDateFunc (dipende dalle impostazioni regionali: 'D' e 'L'
// dipendono dalla data odierna e il resto da TryStrToDateTime).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.TypInfo,
  System.Types,
  Winapi.Windows,
  Data.DB,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.StdCtrls,
  cxGraphics,
  cxControls,
  cxContainer,
  cxLookAndFeels,
  cxClasses,
  cxStyles,
  cxEdit,
  cxGridDBDataDefinitions,
  cxTextEdit,
  cxMaskEdit,
  cxSpinEdit,
  cxCalendar,
  cxTimeEdit,
  cxDropDownEdit,
  cxImageComboBox,
  cxButtonEdit,
  cxCheckBox,
  cxColorComboBox,
  cxCheckComboBox,
  cxImage,
  cxHyperLinkEdit,
  cxLookupEdit,
  cxDBLookupComboBox,
  cxDBExtLookupComboBox,
  cxRadioGroup,
  cxMemo,
  cxRichEdit,
  cxProgressBar,
  cxShellComboBox,
  cxCheckGroup,
  cxLabel,
  cxPC,
  cxSplitter,
  cxFilterControl,
  cxTL,
  cxDBTL,
  cxDBPivotGrid,
  cxDBData,
  cxGridCustomTableView,
  cxGridTableView,
  cxGridDBTableView,
  cxDBEdit,
  cxDBRichEdit,
  cxDBProgressBar,
  cxDBColorComboBox,
  cxDBCheckComboBox,
  cxDBShellComboBox,
  cxDBCheckGroup,
  dxRatingControl,
  dxDBRatingControl,
  dxToggleSwitch,
  dxDBToggleSwitch,
  dxDateTimeWheelPicker,
  dxDBDateTimeWheelPicker,
  dxTokenEdit,
  dxDBTokenEdit,
  dxFormattedLabel,
  dxDBFormattedLabel,
  dxCheckGroupBox,
  dxDBCheckGroupBox,
  dxBar,
  dxGDIPlusClasses,
  dxLayoutCommon,
  dxLayoutContainer,
  dxLayoutControl,
  dxLayoutLookAndFeels,
  dxLayoutPainters,
  dxPSCore,
  DUnitX.TestFramework,
  zBaseLib,
  zSystem,
  zDxLayoutCustomizeFrm,
  zDX;

type
  TCoppiaClasse = record
    Tipo: TzCtrlType;
    Classe: TClass;
  end;

  TElencoCoppie = TArray<TCoppiaClasse>;

  // Gestore di OnButtonClick per InitButtonEdit
  TGestorePulsante = class
  public
    procedure PulsanteCliccato(Sender: TObject; AButtonIndex: integer);
  end;

  [TestFixture]
  TTestzDXClassi = class
  private
    FModulo: Tdx;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-ICO-011
    [Test]
    procedure GetCustomEditClass_ConDatiCollegati_ClasseDelTipo;
    // ZBASE-ICO-011
    [Test]
    procedure GetCustomEditClass_Libero_ClasseLiberaPerITipiDaDefaultACustomDlg;
    // ZBASE-ICO-011 e DIV-ICO-1
    [Test]
    procedure Divergenza_DIV_ICO_1_Libero_DieciTipiRestanoCollegatiAiDati;
    // ZBASE-ICO-011
    [Test]
    procedure GetPropertiesClass_PerOgniTipo_ClasseDelleProprieta;
    // ZBASE-ICO-011
    [Test]
    procedure TipiDiDisposizione_SenzaClasse_Nil;
    // ZBASE-ICO-011
    [Test]
    procedure EditorEProprieta_ConClasseOgniTipo_HannoEntrambi;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_PerOgniTipoConClasseGiusta_NonSolleva;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctDate_DataSenzaOraConTastoOggi;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctTime_OreEMinutiConIncrementoADestra;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctPickList_SenzaImmaginiEConfermaImmediata;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctComboDlg_CancellaConDelEsolaLettura;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctLookup_DieciRigheEPulsanteDiTreTipi;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctLookup_DueChiamate_UnSoloPulsanteAggiunto;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctLookupExt_GridModeVeroERotellinaSpenta;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctCheckBox_SenzaTerzoStatoENessunaDidascalia;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctImage_ProporzioniEClasseGrafica;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctHyperLink_MaiPrefissoUnClic;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctRating_DieciElementi;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctCheckComboBox_ValoriEGestori;
    // ZBASE-ICO-012 e DIV-ICO-11
    [Test]
    procedure Divergenza_DIV_ICO_11_ToggleSwitch_SiSenzaAccento;
    // ZBASE-ICO-012 e DIV-ICO-10
    [Test]
    procedure Divergenza_DIV_ICO_10_BarraDiAvanzamento_PercentualeDoppia;
    // ZBASE-ICO-014
    [Test]
    procedure InitDateEdit_AggiungeIlTastoOggiESpegneLOra;
    // ZBASE-ICO-014
    [Test]
    procedure InitTimeEdit_OreEMinutiConIncrementoADestra;
    // ZBASE-ICO-015
    [Test]
    procedure InitButtonEdit_NonModificabile_SolaLetturaESenzaCursore;
    // ZBASE-ICO-015
    [Test]
    procedure InitButtonEdit_Modificabile_LetturaEScrittura;
    // ZBASE-ICO-015
    [Test]
    procedure InitColorCombo_ValoriFissi;
    // ZBASE-ICO-003
    [Test]
    procedure Visible_BooleanoInVisibilitaDellaVoce;
    // ZBASE-ICO-003
    [Test]
    procedure GetBitmap_ImmagineDellaLista_GlifoPienoDellaStessaLarghezza;
  end;

  [TestFixture]
  TTestzDXDominio = class
  private
    FModulo: Tdx;
    FSistema: TzSystem;
    FDominio: TzDomain;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_Testo_AllineamentoMaiuscoleEFormati;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_SolaLetturaDelDominio_Riportata;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_Email_SempreMinuscolo;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_ConPasswordChar_ModoPassword;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_SenzaPasswordChar_ModoNormale;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_Spin_MinimoEMassimoDelDominio;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_CasellaSuCampoDiTesto_SeNo;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_CasellaSuCampoIntero_VeroFalso;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_CasellaSenzaCampoEDominioSiNo_SeNo;
    // ZBASE-ICO-013
    [Test]
    procedure InitPropertiesDominio_CasellaSenzaCampoEAltroDominio_VeroFalso;
  end;

  [TestFixture]
  TTestzDXModulo = class
  private
    FFinestra: TForm;
    FGestore: TGestorePulsante;
    function NuovoLayout: TdxLayoutControl;
    function NuovoGruppo(Layout: TdxLayoutControl): TdxLayoutGroup;
  public
    [SetupFixture]
    procedure SetupFixture;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-ICO-001
    [Test]
    procedure IndiceIcona_NomeInesistente_MenoUno;
    // ZBASE-ICO-001
    [Test]
    procedure IndiceIcona_NomeEsistente_PosizioneDellIcona;
    // ZBASE-ICO-001
    [Test]
    procedure IndiceIcona_MaiuscoleEMinuscole_StessaIcona;
    // ZBASE-ICO-001
    [Test]
    procedure IndiceIcona_ConEstensione_MenoUno;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_RadiceNil_NonSolleva;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_ListaDiAzioniSenzaImmagini_Immagini;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_ListaDiAzioniGiaAssegnata_Resta;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_MenuSenzaIcone_ImmaginiVuote;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_MenuConIconaInUnaSottovoce_Immagini;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_MenuConImmaginiGiaAssegnate_Resta;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_GestoreDiBarreSenzaPulsantiGrandi_SoloImmagini;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_PulsanteGrandeConIndice_AncheLargeImages;
    // ZBASE-ICO-002
    [Test]
    procedure AgganciaImmagini_MenuDiBarre_Immagini;
    // ZBASE-ICO-004
    [Test]
    procedure InitLayoutControl_LayoutNuovo_ImpostazioniFisse;
    // ZBASE-ICO-004
    [Test]
    procedure InitLayoutControl_ListaDellaForm_Resta;
    // ZBASE-ICO-004
    [Test]
    procedure InitLayoutControl_GestoriDelleProprietaSalvate_Collegati;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_ElencoPerTipoDiElemento;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_LayoutLookAndFeel_ScritturaELettura;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_LookAndFeel_ScritturaELettura;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_NomeSconosciutoOVuoto_Ignorato;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_GruppoSenzaLookAndFeel_StringaVuota;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_ImageIndex_ScritturaELettura;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_VisibleElements_ScritturaELettura;
    // ZBASE-ICO-005
    [Test]
    procedure ProprietaSalvate_HideTabsEScorrimento_ScritturaELettura;
    // ZBASE-ICO-006
    [Test]
    procedure LookAndFeel_DueIstanzeConNomiEPresentiNellElenco;
    // ZBASE-ICO-006
    [Test]
    procedure LookAndFeel_StileUltraFlatEStileNativoSpento;
    // ZBASE-ICO-006
    [Test]
    procedure LookAndFeel_SenzaBordoDeiGruppi_OffsetZero;
    // ZBASE-ICO-006
    [Test]
    procedure LookAndFeel_IlDisegnoDeiGruppiEQuelloStandard;
    // ZBASE-ICO-006
    [Test]
    [Ignore('R-214: LayoutControlHeigth con layout vuoto solleva una violazione di accesso, da indagare (ZBASE-ICO-006)')]
    procedure LayoutControlHeigth_LayoutVuoto_NonNegativo;
    // ZBASE-ICO-007
    [Test]
    procedure InitBar_BarraNuova_ImpostazioniFisse;
    // ZBASE-ICO-007
    [Test]
    procedure dxBarAssignPopupMenu_BarraSenzaControllo_NonSolleva;
    // ZBASE-ICO-007
    [Test]
    procedure dxBarRequiredWidth_BarraNilOSenzaControllo_Zero;
    // ZBASE-ICO-008
    [Test]
    procedure InitPrinter_StampanteNuova_ImpostazioniFisse;
    // ZBASE-ICO-009
    [Test]
    procedure InitGrid_VistaConDatabase_StiliEGridMode;
    // ZBASE-ICO-009
    [Test]
    procedure InitGrid_VistaSenzaDatabase_NienteIntestazioneEPiede;
    // ZBASE-ICO-009
    [Test]
    procedure InitTreeList_AlberoSenzaDatabase_UltraFlatEStili;
    // ZBASE-ICO-009
    [Test]
    procedure InitTreeList_ApplyStylesFalso_StiliInvariati;
    // ZBASE-ICO-009 e DIV-ICO-2
    [Test]
    procedure Divergenza_DIV_ICO_2_AlberoConDatabase_FlatEInattivoDelControllo;
    // ZBASE-ICO-009
    [Test]
    procedure InitPivot_StiliEBordo;
    // ZBASE-ICO-010
    [Test]
    procedure InitLabel_AutoSizeFalso_PuntiniETrasparente;
    // ZBASE-ICO-010
    [Test]
    procedure InitLabel_AutoSizeVero_SenzaPuntini;
    // ZBASE-ICO-010
    [Test]
    procedure InitTitleEInitSeparator_ControllerDiStileETrasparenzaFalsa;
    // ZBASE-ICO-010
    [Test]
    procedure InitPageControl_LinguetteInAlto_ImpostazioniFisseEUnaRiga;
    // ZBASE-ICO-010
    [Test]
    procedure InitPageControl_LinguetteInBasso_MultiLineResta;
    // ZBASE-ICO-010
    [Test]
    procedure InitSplitter_InAlto_AltezzaSette;
    // ZBASE-ICO-010
    [Test]
    procedure InitSplitter_ASinistra_LarghezzaSette;
    // ZBASE-ICO-010
    [Test]
    procedure SetFilterControlFonts_CaratteriDelloStileMedio;
    // ZBASE-ICO-010
    [Test]
    procedure SetFilterControlFonts_FiltroNil_NonSolleva;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctPickListImage_ListaImmagini;
    // ZBASE-ICO-012
    [Test]
    procedure InitProperties_ctLookupHyperLink_TrePulsanti;
    // ZBASE-ICO-017
    [Test]
    procedure InitSpellChecker_SenzaFileDelDizionario_Spento;
    // ZBASE-ICO-018
    [Test]
    procedure ChiudiFiltriAperti_SenzaFinestreAperte_NonSolleva;
  end;

implementation

function NomeTipo(Tipo: TzCtrlType): string;
begin
  Result := GetEnumName(TypeInfo(TzCtrlType), Ord(Tipo));
end;

procedure Aggiungi(var Elenco: TElencoCoppie; Tipo: TzCtrlType; Classe: TClass);
begin
  SetLength(Elenco, Length(Elenco) + 1);
  Elenco[High(Elenco)].Tipo := Tipo;
  Elenco[High(Elenco)].Classe := Classe;
end;

// Mappatura attesa con i dati collegati (ZBASE-ICO-011)
function ClassiEditorCollegati: TElencoCoppie;
begin
  Result := nil;
  Aggiungi(Result, ctDefault, TcxDBTextEdit);
  Aggiungi(Result, ctEdit, TcxDBTextEdit);
  Aggiungi(Result, ctSpin, TcxDBSpinEdit);
  Aggiungi(Result, ctDate, TcxDBDateEdit);
  Aggiungi(Result, ctTime, TcxDBTimeEdit);
  Aggiungi(Result, ctDateTime, TcxDBDateEdit);
  Aggiungi(Result, ctComboBox, TcxDBComboBox);
  Aggiungi(Result, ctPickList, TcxDBImageComboBox);
  Aggiungi(Result, ctPickListImage, TcxDBImageComboBox);
  Aggiungi(Result, ctRadioGroup, TcxDBRadioGroup);
  Aggiungi(Result, ctComboDlg, TcxDBButtonEdit);
  Aggiungi(Result, ctLookup, TcxDBLookupComboBox);
  Aggiungi(Result, ctLookupExt, TcxDBExtLookupComboBox);
  Aggiungi(Result, ctLookupHyperLink, TcxDBExtLookupComboBox);
  Aggiungi(Result, ctCheckBox, TcxDBCheckBox);
  Aggiungi(Result, ctMemo, TcxDBMemo);
  Aggiungi(Result, ctRTF, TcxDBRichEdit);
  Aggiungi(Result, ctImage, TcxDBImage);
  Aggiungi(Result, ctHyperLink, TcxDBHyperLinkEdit);
  Aggiungi(Result, ctProgressBar, TcxDBProgressBar);
  Aggiungi(Result, ctRating, TdxDBRatingControl);
  Aggiungi(Result, ctColorCombo, TcxDBColorComboBox);
  Aggiungi(Result, ctCustomDlg, TcxDBButtonEdit);
  Aggiungi(Result, ctCheckComboBox, TcxDBCheckComboBox);
  Aggiungi(Result, ctToggleSwitch, TdxDBToggleSwitch);
  Aggiungi(Result, ctDateTimeWheelPicker, TdxDBDateTimeWheelPicker);
  Aggiungi(Result, ctTokenEdit, TdxDBTokenEdit);
  Aggiungi(Result, ctFormattedLabel, TdxDBFormattedLabel);
  Aggiungi(Result, ctCheckGroupBox, TdxDBCheckGroupBox);
  Aggiungi(Result, ctButtonEdit, TcxDBButtonEdit);
  Aggiungi(Result, ctMaskEdit, TcxDBMaskEdit);
  Aggiungi(Result, ctCheckGroup, TcxDBCheckGroup);
  Aggiungi(Result, ctShellComboBox, TcxDBShellComboBox);
end;

// Mappatura attesa senza i dati collegati, per i tipi da ctDefault a ctCustomDlg
function ClassiEditorLiberi: TElencoCoppie;
begin
  Result := nil;
  Aggiungi(Result, ctDefault, TcxTextEdit);
  Aggiungi(Result, ctEdit, TcxTextEdit);
  Aggiungi(Result, ctSpin, TcxSpinEdit);
  Aggiungi(Result, ctDate, TcxDateEdit);
  Aggiungi(Result, ctTime, TcxTimeEdit);
  Aggiungi(Result, ctDateTime, TcxDateEdit);
  Aggiungi(Result, ctComboBox, TcxComboBox);
  Aggiungi(Result, ctPickList, TcxImageComboBox);
  Aggiungi(Result, ctPickListImage, TcxImageComboBox);
  Aggiungi(Result, ctRadioGroup, TcxRadioGroup);
  Aggiungi(Result, ctComboDlg, TcxButtonEdit);
  Aggiungi(Result, ctLookup, TcxLookupComboBox);
  Aggiungi(Result, ctLookupExt, TcxExtLookupComboBox);
  Aggiungi(Result, ctLookupHyperLink, TcxExtLookupComboBox);
  Aggiungi(Result, ctCheckBox, TcxCheckBox);
  Aggiungi(Result, ctMemo, TcxMemo);
  Aggiungi(Result, ctRTF, TcxRichEdit);
  Aggiungi(Result, ctImage, TcxImage);
  Aggiungi(Result, ctHyperLink, TcxHyperLinkEdit);
  Aggiungi(Result, ctProgressBar, TcxProgressBar);
  Aggiungi(Result, ctRating, TdxRatingControl);
  Aggiungi(Result, ctColorCombo, TcxColorComboBox);
  Aggiungi(Result, ctCustomDlg, TcxButtonEdit);
end;

function ClassiProprieta: TElencoCoppie;
begin
  Result := nil;
  Aggiungi(Result, ctDefault, TcxTextEditProperties);
  Aggiungi(Result, ctEdit, TcxTextEditProperties);
  Aggiungi(Result, ctSpin, TcxSpinEditProperties);
  Aggiungi(Result, ctDate, TcxDateEditProperties);
  Aggiungi(Result, ctTime, TcxTimeEditProperties);
  Aggiungi(Result, ctDateTime, TcxDateEditProperties);
  Aggiungi(Result, ctComboBox, TcxComboBoxProperties);
  Aggiungi(Result, ctPickList, TcxImageComboBoxProperties);
  Aggiungi(Result, ctPickListImage, TcxImageComboBoxProperties);
  Aggiungi(Result, ctRadioGroup, TcxRadioGroupProperties);
  Aggiungi(Result, ctComboDlg, TcxButtonEditProperties);
  Aggiungi(Result, ctLookup, TcxLookupComboBoxProperties);
  Aggiungi(Result, ctLookupExt, TcxExtLookupComboBoxProperties);
  Aggiungi(Result, ctLookupHyperLink, TcxExtLookupComboBoxProperties);
  Aggiungi(Result, ctCheckBox, TcxCheckBoxProperties);
  Aggiungi(Result, ctMemo, TcxMemoProperties);
  Aggiungi(Result, ctRTF, TcxRichEditProperties);
  Aggiungi(Result, ctImage, TcxImageProperties);
  Aggiungi(Result, ctHyperLink, TcxHyperLinkEditProperties);
  Aggiungi(Result, ctProgressBar, TcxProgressBarProperties);
  Aggiungi(Result, ctRating, TdxRatingControlProperties);
  Aggiungi(Result, ctColorCombo, TcxColorComboBoxProperties);
  Aggiungi(Result, ctCustomDlg, TcxButtonEditProperties);
  Aggiungi(Result, ctCheckComboBox, TcxCheckComboBoxProperties);
  Aggiungi(Result, ctToggleSwitch, TdxToggleSwitchProperties);
  Aggiungi(Result, ctDateTimeWheelPicker, TdxDateTimeWheelPickerProperties);
  Aggiungi(Result, ctTokenEdit, TdxTokenEditProperties);
  Aggiungi(Result, ctFormattedLabel, TdxFormattedLabelProperties);
  Aggiungi(Result, ctCheckGroupBox, TdxCheckGroupBoxProperties);
  Aggiungi(Result, ctButtonEdit, TcxButtonEditProperties);
  Aggiungi(Result, ctMaskEdit, TcxMaskEditProperties);
  Aggiungi(Result, ctCheckGroup, TcxCheckGroupProperties);
  Aggiungi(Result, ctShellComboBox, TcxShellComboBoxProperties);
end;

// TGestorePulsante

procedure TGestorePulsante.PulsanteCliccato(Sender: TObject; AButtonIndex: integer);
begin
  // gestore vuoto: serve solo a essere assegnato a OnButtonClick
end;

// TTestzDXClassi

procedure TTestzDXClassi.Setup;
begin
  FModulo := Tdx.CreateNew(nil);
end;

procedure TTestzDXClassi.TearDown;
begin
  FreeAndNil(FModulo);
end;

procedure TTestzDXClassi.GetCustomEditClass_ConDatiCollegati_ClasseDelTipo;
var
  Coppia: TCoppiaClasse;
begin
  for Coppia in ClassiEditorCollegati do
    Assert.IsTrue(TClass(FModulo.GetCustomEditClass(Coppia.Tipo, True)) = Coppia.Classe, NomeTipo(Coppia.Tipo));
end;

procedure TTestzDXClassi.GetCustomEditClass_Libero_ClasseLiberaPerITipiDaDefaultACustomDlg;
var
  Coppia: TCoppiaClasse;
begin
  for Coppia in ClassiEditorLiberi do
    Assert.IsTrue(TClass(FModulo.GetCustomEditClass(Coppia.Tipo, False)) = Coppia.Classe, NomeTipo(Coppia.Tipo));
end;

procedure TTestzDXClassi.Divergenza_DIV_ICO_1_Libero_DieciTipiRestanoCollegatiAiDati;
var
  Coppia: TCoppiaClasse;
begin
  // Fotografia: per questi dieci tipi la risposta "libera" e' la classe collegata
  // ai dati. Va capovolta quando il ramo libero viene corretto.
  for Coppia in ClassiEditorCollegati do
    if Coppia.Tipo in [ctCheckComboBox, ctToggleSwitch, ctDateTimeWheelPicker, ctTokenEdit, ctFormattedLabel, ctCheckGroupBox, ctButtonEdit, ctMaskEdit, ctCheckGroup, ctShellComboBox] then
      Assert.IsTrue(TClass(FModulo.GetCustomEditClass(Coppia.Tipo, False)) = Coppia.Classe, NomeTipo(Coppia.Tipo));
end;

procedure TTestzDXClassi.GetPropertiesClass_PerOgniTipo_ClasseDelleProprieta;
var
  Coppia: TCoppiaClasse;
begin
  for Coppia in ClassiProprieta do
    Assert.IsTrue(TClass(FModulo.GetPropertiesClass(Coppia.Tipo)) = Coppia.Classe, NomeTipo(Coppia.Tipo));
end;

procedure TTestzDXClassi.TipiDiDisposizione_SenzaClasse_Nil;
var
  Tipo: TzCtrlType;
begin
  for Tipo in [ctGroupBox, ctButton, ctSeparator, ctLineBreak] do
  begin
    Assert.IsTrue(FModulo.GetCustomEditClass(Tipo, True) = nil, 'editor collegato, ' + NomeTipo(Tipo));
    Assert.IsTrue(FModulo.GetCustomEditClass(Tipo, False) = nil, 'editor libero, ' + NomeTipo(Tipo));
    Assert.IsTrue(FModulo.GetPropertiesClass(Tipo) = nil, 'proprieta, ' + NomeTipo(Tipo));
  end;
end;

procedure TTestzDXClassi.EditorEProprieta_ConClasseOgniTipo_HannoEntrambi;
var
  Tipo: TzCtrlType;
begin
  // InitProperties converte le proprieta' con un cast senza controllo del tipo:
  // per ogni tipo con un editor deve esistere anche la classe delle proprieta'
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
    if FModulo.GetCustomEditClass(Tipo, True) <> nil then
      Assert.IsTrue(FModulo.GetPropertiesClass(Tipo) <> nil, NomeTipo(Tipo))
    else
      Assert.IsTrue(FModulo.GetPropertiesClass(Tipo) = nil, NomeTipo(Tipo));
end;

procedure TTestzDXClassi.InitProperties_PerOgniTipoConClasseGiusta_NonSolleva;
var
  Tipo: TzCtrlType;
  Classe: TcxCustomEditPropertiesClass;
  Proprieta: TcxCustomEditProperties;
begin
  for Tipo := Low(TzCtrlType) to High(TzCtrlType) do
  begin
    // ctLookupHyperLink usa la lista Glyphs del modulo completo: ha la sua prova
    if Tipo = ctLookupHyperLink then
      Continue;

    Classe := FModulo.GetPropertiesClass(Tipo);
    if Classe = nil then
      Continue;

    Proprieta := Classe.Create(nil);
    try
      try
        FModulo.InitProperties(Tipo, Proprieta);
      except
        on E: Exception do
          Assert.Fail(NomeTipo(Tipo) + ': ' + E.ClassName + ' ' + E.Message);
      end;
    finally
      Proprieta.Free;
    end;
  end;
  Assert.Pass('nessun tipo solleva');
end;

procedure TTestzDXClassi.InitProperties_ctDate_DataSenzaOraConTastoOggi;
var
  Proprieta: TcxDateEditProperties;
begin
  Proprieta := TcxDateEditProperties.Create(nil);
  try
    Proprieta.DateButtons := [btnClear];
    Proprieta.Kind := ckDateTime;
    Proprieta.SaveTime := True;
    Proprieta.ShowTime := True;
    Proprieta.ShowToday := False;

    FModulo.InitProperties(ctDate, Proprieta);

    Assert.IsTrue(btnToday in Proprieta.DateButtons, 'tasto Oggi');
    Assert.IsTrue(btnClear in Proprieta.DateButtons, 'il tasto che c''era resta');
    Assert.AreEqual(Ord(ckDate), Ord(Proprieta.Kind), 'Kind');
    Assert.IsFalse(Proprieta.SaveTime, 'SaveTime');
    Assert.IsFalse(Proprieta.ShowTime, 'ShowTime');
    Assert.IsTrue(Proprieta.ShowToday, 'ShowToday');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctTime_OreEMinutiConIncrementoADestra;
var
  Proprieta: TcxTimeEditProperties;
begin
  Proprieta := TcxTimeEditProperties.Create(nil);
  try
    FModulo.InitProperties(ctTime, Proprieta);

    Assert.AreEqual(Ord(tfHourMin), Ord(Proprieta.TimeFormat), 'TimeFormat');
    Assert.AreEqual(Ord(sbpHorzRight), Ord(Proprieta.SpinButtons.Position), 'posizione dei pulsanti');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctPickList_SenzaImmaginiEConfermaImmediata;
var
  Proprieta: TcxImageComboBoxProperties;
  Lista: TcxImageList;
begin
  Lista := TcxImageList.Create(nil);
  Proprieta := TcxImageComboBoxProperties.Create(nil);
  try
    Proprieta.Images := Lista;
    Proprieta.ImmediatePost := False;

    FModulo.InitProperties(ctPickList, Proprieta);

    Assert.IsTrue(Proprieta.Images = nil, 'Images');
    Assert.IsTrue(Proprieta.ImmediatePost, 'ImmediatePost');
  finally
    Proprieta.Free;
    Lista.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctComboDlg_CancellaConDelEsolaLettura;
var
  Proprieta: TcxButtonEditProperties;
begin
  Proprieta := TcxButtonEditProperties.Create(nil);
  try
    FModulo.InitProperties(ctComboDlg, Proprieta);

    Assert.AreEqual(Integer(VK_DELETE), Integer(Proprieta.ClearKey), 'ClearKey');
    Assert.IsTrue(Proprieta.ReadOnly, 'ReadOnly');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctLookup_DieciRigheEPulsanteDiTreTipi;
var
  Proprieta: TcxLookupComboBoxProperties;
begin
  Proprieta := TcxLookupComboBoxProperties.Create(nil);
  try
    Assert.AreEqual(1, Proprieta.Buttons.Count, 'prima: il solo pulsante di apertura');

    FModulo.InitProperties(ctLookup, Proprieta);

    Assert.AreEqual(10, Proprieta.DropDownRows, 'DropDownRows');
    Assert.AreEqual(Ord(lsEditList), Ord(Proprieta.DropDownListStyle), 'stile modificabile');
    Assert.IsFalse(Proprieta.IncrementalFiltering, 'IncrementalFiltering');
    Assert.IsTrue(Proprieta.Revertable, 'Revertable');
    Assert.IsTrue(Proprieta.ImmediatePost, 'ImmediatePost');
    Assert.IsFalse(Proprieta.GridMode, 'GridMode');
    Assert.AreEqual(2, Proprieta.Buttons.Count, 'pulsanti');
    Assert.AreEqual(Ord(bkEllipsis), Ord(Proprieta.Buttons[1].Kind), 'tipo del secondo pulsante');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctLookup_DueChiamate_UnSoloPulsanteAggiunto;
var
  Proprieta: TcxLookupComboBoxProperties;
begin
  Proprieta := TcxLookupComboBoxProperties.Create(nil);
  try
    FModulo.InitProperties(ctLookup, Proprieta);
    FModulo.InitProperties(ctLookup, Proprieta);

    // il pulsante si aggiunge solo se ce n'e' uno
    Assert.AreEqual(2, Proprieta.Buttons.Count);
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctLookupExt_GridModeVeroERotellinaSpenta;
var
  Proprieta: TcxExtLookupComboBoxProperties;
begin
  Proprieta := TcxExtLookupComboBoxProperties.Create(nil);
  try
    FModulo.InitProperties(ctLookupExt, Proprieta);

    Assert.AreEqual(10, Proprieta.DropDownRows, 'DropDownRows');
    Assert.IsTrue(Proprieta.GridMode, 'GridMode');
    Assert.IsFalse(Proprieta.UseMouseWheel, 'UseMouseWheel');
    Assert.IsTrue(Proprieta.Revertable, 'Revertable');
    Assert.IsTrue(Proprieta.ImmediatePost, 'ImmediatePost');
    Assert.AreEqual(2, Proprieta.Buttons.Count, 'pulsanti');
    Assert.AreEqual(Ord(bkEllipsis), Ord(Proprieta.Buttons[1].Kind), 'tipo del secondo pulsante');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctCheckBox_SenzaTerzoStatoENessunaDidascalia;
var
  Proprieta: TcxCheckBoxProperties;
begin
  Proprieta := TcxCheckBoxProperties.Create(nil);
  try
    Proprieta.AllowGrayed := True;
    Proprieta.Caption := 'Testo';

    FModulo.InitProperties(ctCheckBox, Proprieta);

    Assert.IsFalse(Proprieta.AllowGrayed, 'AllowGrayed');
    Assert.AreEqual('', Proprieta.Caption, 'Caption');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctImage_ProporzioniEClasseGrafica;
var
  Proprieta: TcxImageProperties;
begin
  Proprieta := TcxImageProperties.Create(nil);
  try
    FModulo.InitProperties(ctImage, Proprieta);

    Assert.AreEqual(Ord(ifmProportionalStretch), Ord(Proprieta.FitMode), 'FitMode');
    Assert.AreEqual('TdxSmartImage', Proprieta.GraphicClassName, 'GraphicClassName');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctHyperLink_MaiPrefissoUnClic;
var
  Proprieta: TcxHyperLinkEditProperties;
begin
  Proprieta := TcxHyperLinkEditProperties.Create(nil);
  try
    FModulo.InitProperties(ctHyperLink, Proprieta);

    Assert.AreEqual(Ord(upNever), Ord(Proprieta.UsePrefix), 'UsePrefix');
    Assert.IsTrue(Proprieta.SingleClick, 'SingleClick');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctRating_DieciElementi;
var
  Proprieta: TdxRatingControlProperties;
begin
  Proprieta := TdxRatingControlProperties.Create(nil);
  try
    FModulo.InitProperties(ctRating, Proprieta);

    Assert.AreEqual(10, Proprieta.ItemCount, 'ItemCount');
    Assert.IsTrue(Proprieta.ImmediatePost, 'ImmediatePost');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitProperties_ctCheckComboBox_ValoriEGestori;
var
  Proprieta: TcxCheckComboBoxProperties;
begin
  Proprieta := TcxCheckComboBoxProperties.Create(nil);
  try
    FModulo.InitProperties(ctCheckComboBox, Proprieta);

    Assert.AreEqual('; ', Proprieta.Delimiter, 'Delimiter');
    Assert.AreEqual(12, Proprieta.DropDownRows, 'DropDownRows');
    Assert.IsTrue(Proprieta.DropDownSizeable, 'DropDownSizeable');
    Assert.IsTrue(Proprieta.ImmediatePost, 'ImmediatePost');
    Assert.IsFalse(Proprieta.ShowEmptyText, 'ShowEmptyText');
    Assert.AreEqual(Ord(cvfIndices), Ord(Proprieta.EditValueFormat), 'EditValueFormat');
    Assert.IsTrue(Assigned(Proprieta.OnEditValueToStates), 'OnEditValueToStates');
    Assert.IsTrue(Assigned(Proprieta.OnStatesToEditValue), 'OnStatesToEditValue');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.Divergenza_DIV_ICO_11_ToggleSwitch_SiSenzaAccento;
var
  Proprieta: TdxToggleSwitchProperties;
begin
  Proprieta := TdxToggleSwitchProperties.Create(nil);
  try
    FModulo.InitProperties(ctToggleSwitch, Proprieta);

    Assert.AreEqual('', Proprieta.Caption, 'Caption');
    Assert.AreEqual('No', Proprieta.StateIndicator.OffText, 'OffText');
    // fotografia: manca l'accento ("Si'" e non "Sì"); da capovolgere alla correzione
    Assert.AreEqual('Si', Proprieta.StateIndicator.OnText, 'OnText');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.Divergenza_DIV_ICO_10_BarraDiAvanzamento_PercentualeDoppia;
var
  Barra: TcxProgressBar;
  Finestra: TForm;
begin
  Finestra := TForm.CreateNew(nil);
  try
    Barra := TcxProgressBar.Create(Finestra);
    FModulo.InitProperties(ctProgressBar, Barra.Properties);
    Assert.IsTrue(Assigned(Barra.Properties.OnEditValueChanged), 'gestore collegato');

    Barra.EditValue := 50;
    Barra.Properties.OnEditValueChanged(Barra);

    // fotografia: il simbolo e' aggiunto due volte; da capovolgere ('50%') alla correzione
    Assert.AreEqual('50%%', Barra.Properties.Text);
  finally
    Finestra.Free;
  end;
end;

procedure TTestzDXClassi.InitDateEdit_AggiungeIlTastoOggiESpegneLOra;
var
  Proprieta: TcxDateEditProperties;
begin
  Proprieta := TcxDateEditProperties.Create(nil);
  try
    Proprieta.DateButtons := [btnClear];
    Proprieta.Kind := ckDateTime;
    Proprieta.SaveTime := True;
    Proprieta.ShowTime := True;
    Proprieta.ShowToday := False;

    FModulo.InitDateEdit(Proprieta);

    Assert.IsTrue(btnToday in Proprieta.DateButtons, 'tasto Oggi');
    Assert.IsTrue(btnClear in Proprieta.DateButtons, 'il tasto che c''era resta');
    Assert.AreEqual(Ord(ckDate), Ord(Proprieta.Kind), 'Kind');
    Assert.IsFalse(Proprieta.SaveTime, 'SaveTime');
    Assert.IsFalse(Proprieta.ShowTime, 'ShowTime');
    Assert.IsTrue(Proprieta.ShowToday, 'ShowToday');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitTimeEdit_OreEMinutiConIncrementoADestra;
var
  Proprieta: TcxTimeEditProperties;
begin
  Proprieta := TcxTimeEditProperties.Create(nil);
  try
    FModulo.InitTimeEdit(Proprieta);

    Assert.AreEqual(Ord(tfHourMin), Ord(Proprieta.TimeFormat), 'TimeFormat');
    Assert.AreEqual(Ord(sbpHorzRight), Ord(Proprieta.SpinButtons.Position), 'posizione dei pulsanti');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitButtonEdit_NonModificabile_SolaLetturaESenzaCursore;
var
  Proprieta: TcxButtonEditProperties;
  Gestore: TGestorePulsante;
begin
  Proprieta := TcxButtonEditProperties.Create(nil);
  Gestore := TGestorePulsante.Create;
  try
    FModulo.InitButtonEdit(Proprieta, Gestore.PulsanteCliccato, False);

    Assert.IsTrue(Assigned(Proprieta.OnButtonClick), 'OnButtonClick');
    Assert.IsTrue(Proprieta.Buttons.Count >= 1, 'almeno un pulsante');
    Assert.AreEqual(Ord(bkEllipsis), Ord(Proprieta.Buttons[0].Kind), 'tipo del primo pulsante');
    Assert.IsTrue(Proprieta.ReadOnly, 'ReadOnly');
    Assert.AreEqual(Ord(vsHideCursor), Ord(Proprieta.ViewStyle), 'ViewStyle');
  finally
    Gestore.Free;
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitButtonEdit_Modificabile_LetturaEScrittura;
var
  Proprieta: TcxButtonEditProperties;
  Gestore: TGestorePulsante;
begin
  Proprieta := TcxButtonEditProperties.Create(nil);
  Gestore := TGestorePulsante.Create;
  try
    FModulo.InitButtonEdit(Proprieta, Gestore.PulsanteCliccato, True);

    Assert.IsFalse(Proprieta.ReadOnly, 'ReadOnly');
    Assert.AreEqual(Ord(vsNormal), Ord(Proprieta.ViewStyle), 'ViewStyle');
  finally
    Gestore.Free;
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.InitColorCombo_ValoriFissi;
var
  Proprieta: TcxColorComboBoxProperties;
begin
  Proprieta := TcxColorComboBoxProperties.Create(nil);
  try
    FModulo.InitColorCombo(Proprieta);

    Assert.IsTrue(Proprieta.AllowSelectColor, 'AllowSelectColor');
    Assert.AreEqual(Ord(cxccsComboList), Ord(Proprieta.ColorComboStyle), 'ColorComboStyle');
    Assert.IsTrue(Proprieta.ColorDialogShowFull, 'ColorDialogShowFull');
    Assert.AreEqual(12, Proprieta.DropDownRows, 'DropDownRows');
    Assert.IsTrue(Proprieta.DropDownSizeable, 'DropDownSizeable');
    Assert.AreEqual(Ord(cxncX11), Ord(Proprieta.NamingConvention), 'NamingConvention');
    Assert.AreEqual(Ord(cxplX11), Ord(Proprieta.PrepareList), 'PrepareList');
    Assert.IsFalse(Proprieta.ShowDescriptions, 'ShowDescriptions');
    Assert.AreEqual(Ord(cxcvInteger), Ord(Proprieta.ColorValueFormat), 'ColorValueFormat');
    Assert.IsTrue(Assigned(Proprieta.OnSelectCustomColor), 'OnSelectCustomColor');
    Assert.IsTrue(Assigned(Proprieta.OnEditValueChanged), 'OnEditValueChanged');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXClassi.Visible_BooleanoInVisibilitaDellaVoce;
begin
  Assert.AreEqual(Ord(ivAlways), Ord(FModulo.Visible(True)), 'vero');
  Assert.AreEqual(Ord(ivNever), Ord(FModulo.Visible(False)), 'falso');
end;

procedure TTestzDXClassi.GetBitmap_ImmagineDellaLista_GlifoPienoDellaStessaLarghezza;
var
  Lista: TImageList;
  Immagine: TBitmap;
  Glifo: TdxSmartGlyph;
begin
  Lista := TImageList.Create(nil);
  Immagine := TBitmap.Create;
  Glifo := TdxSmartGlyph.Create;
  try
    Lista.Width := 16;
    Lista.Height := 16;
    Immagine.SetSize(16, 16);
    Immagine.Canvas.Brush.Color := clRed;
    Immagine.Canvas.FillRect(Rect(0, 0, 16, 16));
    Lista.Add(Immagine, nil);

    FModulo.GetBitmap(Glifo, Lista, 0);

    Assert.IsFalse(Glifo.Empty, 'glifo vuoto');
    Assert.AreEqual(16, Glifo.Width, 'larghezza');
    Assert.AreEqual(16, Glifo.Height, 'altezza');
  finally
    Glifo.Free;
    Immagine.Free;
    Lista.Free;
  end;
end;

// TTestzDXDominio

procedure TTestzDXDominio.Setup;
begin
  FModulo := Tdx.CreateNew(nil);
  // TzSystem e' un oggetto unico di processo (variabile Base): si crea e si
  // libera a ogni prova, come in Test.zSystem.Dizionario
  FSistema := TzSystem.Create(nil);
  FDominio := FSistema.zDataDictionary.Add;
  FDominio.Name := 'PROVE.CAMPO';
end;

procedure TTestzDXDominio.TearDown;
begin
  FreeAndNil(FSistema);
  FreeAndNil(FModulo);
end;

procedure TTestzDXDominio.InitPropertiesDominio_Testo_AllineamentoMaiuscoleEFormati;
var
  Proprieta: TcxTextEditProperties;
begin
  Proprieta := TcxTextEditProperties.Create(nil);
  try
    FDominio.Alignment := taRightJustify;
    FDominio.CharCase := ecUpperCase;
    FDominio.DisplayFormat := '###,##0.00';
    FDominio.EditFormat := '0.00';

    FModulo.InitProperties(ctEdit, Proprieta, FDominio, nil);

    Assert.AreEqual(Ord(taRightJustify), Ord(Proprieta.Alignment.Horz), 'allineamento');
    Assert.AreEqual(Ord(ecUpperCase), Ord(Proprieta.CharCase), 'CharCase');
    Assert.AreEqual('###,##0.00', Proprieta.DisplayFormat, 'DisplayFormat');
    Assert.AreEqual('0.00', Proprieta.EditFormat, 'EditFormat');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_SolaLetturaDelDominio_Riportata;
var
  Proprieta: TcxTextEditProperties;
begin
  Proprieta := TcxTextEditProperties.Create(nil);
  try
    FDominio.ReadOnlyOverride := boTrue;

    FModulo.InitProperties(ctEdit, Proprieta, FDominio, nil);

    Assert.IsTrue(Proprieta.ReadOnly);
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_Email_SempreMinuscolo;
var
  Proprieta: TcxTextEditProperties;
begin
  Proprieta := TcxTextEditProperties.Create(nil);
  try
    FDominio.CharCase := ecUpperCase;
    FDominio.SanificaEmail := True;

    FModulo.InitProperties(ctEdit, Proprieta, FDominio, nil);

    Assert.AreEqual(Ord(ecLowerCase), Ord(Proprieta.CharCase));
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_ConPasswordChar_ModoPassword;
var
  Proprieta: TcxTextEditProperties;
begin
  Proprieta := TcxTextEditProperties.Create(nil);
  try
    FDominio.PasswordChar := '*';

    FModulo.InitProperties(ctEdit, Proprieta, FDominio, nil);

    Assert.IsTrue(Proprieta.PasswordChar = '*', 'carattere');
    Assert.AreEqual(Ord(eemPassword), Ord(Proprieta.EchoMode), 'EchoMode');
    Assert.IsTrue(Proprieta.ShowPasswordRevealButton, 'pulsante per scoprire la password');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_SenzaPasswordChar_ModoNormale;
var
  Proprieta: TcxTextEditProperties;
begin
  Proprieta := TcxTextEditProperties.Create(nil);
  try
    FDominio.PasswordChar := '';

    FModulo.InitProperties(ctEdit, Proprieta, FDominio, nil);

    Assert.AreEqual(Ord(eemNormal), Ord(Proprieta.EchoMode), 'EchoMode');
    Assert.IsFalse(Proprieta.ShowPasswordRevealButton, 'pulsante per scoprire la password');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_Spin_MinimoEMassimoDelDominio;
var
  Proprieta: TcxSpinEditProperties;
begin
  Proprieta := TcxSpinEditProperties.Create(nil);
  try
    FDominio.MinValue := 1;
    FDominio.MaxValue := 99;

    FModulo.InitProperties(ctSpin, Proprieta, FDominio, nil);

    Assert.IsTrue(Proprieta.MinValue = 1, 'MinValue');
    Assert.IsTrue(Proprieta.MaxValue = 99, 'MaxValue');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_CasellaSuCampoDiTesto_SeNo;
var
  Proprieta: TcxCheckBoxProperties;
  Campo: TStringField;
begin
  Proprieta := TcxCheckBoxProperties.Create(nil);
  Campo := TStringField.Create(nil);
  try
    FDominio.Domain := 'ALTRO_DOMINIO';

    FModulo.InitProperties(ctCheckBox, Proprieta, FDominio, Campo);

    Assert.AreEqual('', Proprieta.Caption, 'Caption');
    Assert.AreEqual('S', VarToStr(Proprieta.ValueChecked), 'ValueChecked');
    Assert.AreEqual('N', VarToStr(Proprieta.ValueUnchecked), 'ValueUnchecked');
  finally
    Campo.Free;
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_CasellaSuCampoIntero_VeroFalso;
var
  Proprieta: TcxCheckBoxProperties;
  Campo: TIntegerField;
begin
  Proprieta := TcxCheckBoxProperties.Create(nil);
  Campo := TIntegerField.Create(nil);
  try
    // il campo prevale sul nome del dominio
    FDominio.Domain := 'SI_NO';

    FModulo.InitProperties(ctCheckBox, Proprieta, FDominio, Campo);

    Assert.IsTrue(VarIsType(Proprieta.ValueChecked, varBoolean), 'tipo di ValueChecked');
    Assert.IsTrue(Boolean(Proprieta.ValueChecked), 'ValueChecked');
    Assert.IsFalse(Boolean(Proprieta.ValueUnchecked), 'ValueUnchecked');
  finally
    Campo.Free;
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_CasellaSenzaCampoEDominioSiNo_SeNo;
var
  Proprieta: TcxCheckBoxProperties;
begin
  Proprieta := TcxCheckBoxProperties.Create(nil);
  try
    FDominio.Domain := 'SI_NO';

    FModulo.InitProperties(ctCheckBox, Proprieta, FDominio, nil);

    Assert.AreEqual('S', VarToStr(Proprieta.ValueChecked), 'ValueChecked');
    Assert.AreEqual('N', VarToStr(Proprieta.ValueUnchecked), 'ValueUnchecked');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXDominio.InitPropertiesDominio_CasellaSenzaCampoEAltroDominio_VeroFalso;
var
  Proprieta: TcxCheckBoxProperties;
begin
  Proprieta := TcxCheckBoxProperties.Create(nil);
  try
    FDominio.Domain := 'BOOLEANO';

    FModulo.InitProperties(ctCheckBox, Proprieta, FDominio, nil);

    Assert.IsTrue(VarIsType(Proprieta.ValueChecked, varBoolean), 'tipo di ValueChecked');
    Assert.IsTrue(Boolean(Proprieta.ValueChecked), 'ValueChecked');
    Assert.IsFalse(Boolean(Proprieta.ValueUnchecked), 'ValueUnchecked');
  finally
    Proprieta.Free;
  end;
end;

// TTestzDXModulo

procedure TTestzDXModulo.SetupFixture;
begin
  // crea il modulo completo una sola volta; vive fino alla chiusura del programma
  Assert.IsTrue(dx <> nil, 'creazione del modulo zDX');
end;

procedure TTestzDXModulo.Setup;
begin
  FFinestra := TForm.CreateNew(nil);
  FGestore := TGestorePulsante.Create;
end;

procedure TTestzDXModulo.TearDown;
begin
  FreeAndNil(FGestore);
  FreeAndNil(FFinestra);
end;

function TTestzDXModulo.NuovoLayout: TdxLayoutControl;
begin
  Result := TdxLayoutControl.Create(FFinestra);
end;

function TTestzDXModulo.NuovoGruppo(Layout: TdxLayoutControl): TdxLayoutGroup;
begin
  Result := Layout.CreateGroup(TdxLayoutGroup, Layout.Items) as TdxLayoutGroup;
end;

// --- ZBASE-ICO-001

procedure TTestzDXModulo.IndiceIcona_NomeInesistente_MenoUno;
begin
  Assert.AreEqual(-1, dx.IndiceIcona('icona-che-non-esiste-xyz'));
end;

procedure TTestzDXModulo.IndiceIcona_NomeEsistente_PosizioneDellIcona;
var
  Nome: string;
  Indice: integer;
begin
  if dx.Immagini.Count = 0 then
  begin
    Assert.Pass('la lista Immagini e'' vuota, prova non applicabile');
    Exit;
  end;

  Nome := ChangeFileExt(dx.Immagini.GetSourceFileName(0), '');
  Indice := dx.IndiceIcona(Nome);

  Assert.IsTrue(Indice >= 0, 'trovata');
  // con nomi doppi vale la prima corrispondenza: non puo' stare oltre la posizione 0
  Assert.AreEqual(0, Indice, 'prima corrispondenza');
end;

procedure TTestzDXModulo.IndiceIcona_MaiuscoleEMinuscole_StessaIcona;
var
  Nome: string;
begin
  if dx.Immagini.Count = 0 then
  begin
    Assert.Pass('la lista Immagini e'' vuota, prova non applicabile');
    Exit;
  end;

  Nome := ChangeFileExt(dx.Immagini.GetSourceFileName(0), '');

  Assert.AreEqual(dx.IndiceIcona(Nome), dx.IndiceIcona(UpperCase(Nome)), 'maiuscole');
  Assert.AreEqual(dx.IndiceIcona(Nome), dx.IndiceIcona(LowerCase(Nome)), 'minuscole');
end;

procedure TTestzDXModulo.IndiceIcona_ConEstensione_MenoUno;
var
  Nome: string;
begin
  if dx.Immagini.Count = 0 then
  begin
    Assert.Pass('la lista Immagini e'' vuota, prova non applicabile');
    Exit;
  end;

  Nome := ChangeFileExt(dx.Immagini.GetSourceFileName(0), '');
  if Nome = '' then
  begin
    Assert.Pass('la prima icona non ha nome di file, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual(-1, dx.IndiceIcona(Nome + '.svg'));
end;

// --- ZBASE-ICO-002

procedure TTestzDXModulo.AgganciaImmagini_RadiceNil_NonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      dx.AgganciaImmagini(nil);
    end);
end;

procedure TTestzDXModulo.AgganciaImmagini_ListaDiAzioniSenzaImmagini_Immagini;
var
  Lista: TActionList;
begin
  Lista := TActionList.Create(FFinestra);

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Lista.Images = TCustomImageList(dx.Immagini));
end;

procedure TTestzDXModulo.AgganciaImmagini_ListaDiAzioniGiaAssegnata_Resta;
var
  Lista: TActionList;
  Altra: TcxImageList;
begin
  Altra := TcxImageList.Create(FFinestra);
  Lista := TActionList.Create(FFinestra);
  Lista.Images := Altra;

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Lista.Images = TCustomImageList(Altra));
end;

procedure TTestzDXModulo.AgganciaImmagini_MenuSenzaIcone_ImmaginiVuote;
var
  Menu: TPopupMenu;
  Voce: TMenuItem;
begin
  Menu := TPopupMenu.Create(FFinestra);
  Voce := TMenuItem.Create(FFinestra);
  Menu.Items.Add(Voce);

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Menu.Images = nil);
end;

procedure TTestzDXModulo.AgganciaImmagini_MenuConIconaInUnaSottovoce_Immagini;
var
  Menu: TPopupMenu;
  Voce, Sottovoce: TMenuItem;
begin
  Menu := TPopupMenu.Create(FFinestra);
  Voce := TMenuItem.Create(FFinestra);
  Menu.Items.Add(Voce);
  Sottovoce := TMenuItem.Create(FFinestra);
  Voce.Add(Sottovoce);
  Sottovoce.ImageIndex := 1;

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Menu.Images = TCustomImageList(dx.Immagini));
end;

procedure TTestzDXModulo.AgganciaImmagini_MenuConImmaginiGiaAssegnate_Resta;
var
  Menu: TPopupMenu;
  Voce: TMenuItem;
  Altra: TcxImageList;
begin
  Altra := TcxImageList.Create(FFinestra);
  Menu := TPopupMenu.Create(FFinestra);
  Menu.Images := Altra;
  Voce := TMenuItem.Create(FFinestra);
  Menu.Items.Add(Voce);
  Voce.ImageIndex := 0;

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Menu.Images = TCustomImageList(Altra));
end;

procedure TTestzDXModulo.AgganciaImmagini_GestoreDiBarreSenzaPulsantiGrandi_SoloImmagini;
var
  Gestore: TdxBarManager;
begin
  Gestore := TdxBarManager.Create(FFinestra);

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Gestore.ImageOptions.Images = TCustomImageList(dx.Immagini), 'Images');
  Assert.IsTrue(Gestore.ImageOptions.LargeImages = nil, 'LargeImages');
end;

procedure TTestzDXModulo.AgganciaImmagini_PulsanteGrandeConIndice_AncheLargeImages;
var
  Gestore: TdxBarManager;
  Pulsante: TdxBarLargeButton;
begin
  Gestore := TdxBarManager.Create(FFinestra);
  Pulsante := Gestore.AddItem(TdxBarLargeButton) as TdxBarLargeButton;
  Pulsante.LargeImageIndex := 3;

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Gestore.ImageOptions.Images = TCustomImageList(dx.Immagini), 'Images');
  Assert.IsTrue(Gestore.ImageOptions.LargeImages = TCustomImageList(dx.Immagini), 'LargeImages');
end;

procedure TTestzDXModulo.AgganciaImmagini_MenuDiBarre_Immagini;
var
  Menu: TdxBarPopupMenu;
begin
  Menu := TdxBarPopupMenu.Create(FFinestra);

  dx.AgganciaImmagini(FFinestra);

  Assert.IsTrue(Menu.Images = TCustomImageList(dx.Immagini));
end;

// --- ZBASE-ICO-004

procedure TTestzDXModulo.InitLayoutControl_LayoutNuovo_ImpostazioniFisse;
var
  Layout: TdxLayoutControl;
begin
  Layout := NuovoLayout;
  Layout.OptionsStoring.StoreToIniFile := True;
  Layout.OptionsItem.SizableHorz := False;
  Layout.OptionsItem.SizableVert := False;

  dx.InitLayoutControl(Layout);

  Assert.IsTrue(Layout.CustomizeFormClass = TzLayoutCustomizeForm, 'classe della finestra di personalizzazione');
  Assert.IsFalse(Layout.CustomizeFormTabbedView, 'vista a schede');
  Assert.IsFalse(Layout.OptionsStoring.StoreToIniFile, 'StoreToIniFile');
  Assert.IsTrue(Layout.OptionsItem.AutoControlAreaAlignment, 'AutoControlAreaAlignment');
  Assert.IsTrue(Layout.OptionsItem.AutoControlTabOrders, 'AutoControlTabOrders');
  Assert.IsTrue(Layout.OptionsItem.FocusControlOnItemCaptionClick, 'FocusControlOnItemCaptionClick');
  Assert.IsTrue(Layout.OptionsItem.SizableHorz, 'SizableHorz');
  Assert.IsTrue(Layout.OptionsItem.SizableVert, 'SizableVert');
  Assert.AreEqual(Ord(bvNone), Ord(Layout.BevelInner), 'BevelInner');
  Assert.AreEqual(Ord(bvNone), Ord(Layout.BevelOuter), 'BevelOuter');
  Assert.IsTrue(Layout.LayoutLookAndFeel = dx.LayoutLookAndFeelNormal, 'LayoutLookAndFeel');
  Assert.IsTrue(Layout.OptionsImage.Images = TCustomImageList(dx.Immagini), 'OptionsImage.Images');
end;

procedure TTestzDXModulo.InitLayoutControl_ListaDellaForm_Resta;
var
  Layout: TdxLayoutControl;
  Altra: TcxImageList;
begin
  Altra := TcxImageList.Create(FFinestra);
  Layout := NuovoLayout;
  Layout.OptionsImage.Images := Altra;

  dx.InitLayoutControl(Layout);

  Assert.IsTrue(Layout.OptionsImage.Images = TCustomImageList(Altra));
end;

procedure TTestzDXModulo.InitLayoutControl_GestoriDelleProprietaSalvate_Collegati;
var
  Layout: TdxLayoutControl;
begin
  Layout := NuovoLayout;

  dx.InitLayoutControl(Layout);

  Assert.IsTrue(Assigned(Layout.OnGetItemStoredProperties), 'OnGetItemStoredProperties');
  Assert.IsTrue(Assigned(Layout.OnGetItemStoredPropertyValue), 'OnGetItemStoredPropertyValue');
  Assert.IsTrue(Assigned(Layout.OnSetItemStoredPropertyValue), 'OnSetItemStoredPropertyValue');
end;

// --- ZBASE-ICO-005

procedure TTestzDXModulo.ProprietaSalvate_ElencoPerTipoDiElemento;
var
  Layout: TdxLayoutControl;
  Gruppo: TdxLayoutGroup;
  Elemento: TdxLayoutItem;
  Spazio: TdxLayoutEmptySpaceItem;
  Elenco: TStringList;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Gruppo := NuovoGruppo(Layout);
  Elemento := Layout.CreateItem(TdxLayoutItem, Gruppo) as TdxLayoutItem;
  Spazio := Layout.CreateItem(TdxLayoutEmptySpaceItem, Gruppo) as TdxLayoutEmptySpaceItem;
  Elenco := TStringList.Create;
  try
    Layout.OnGetItemStoredProperties(Layout, Gruppo, Elenco);
    Assert.AreEqual(7, Elenco.Count, 'gruppo');
    Assert.IsTrue(Elenco.IndexOf('LookAndFeel') >= 0, 'gruppo: LookAndFeel');
    Assert.IsTrue(Elenco.IndexOf('LayoutLookAndFeel') >= 0, 'gruppo: LayoutLookAndFeel');
    Assert.IsTrue(Elenco.IndexOf('HideTabs') >= 0, 'gruppo: HideTabs');
    Assert.IsTrue(Elenco.IndexOf('ImageIndex') >= 0, 'gruppo: ImageIndex');
    Assert.IsTrue(Elenco.IndexOf('VisibleElements') >= 0, 'gruppo: VisibleElements');
    Assert.IsTrue(Elenco.IndexOf('ScrollOptionsHorizontal') >= 0, 'gruppo: ScrollOptionsHorizontal');
    Assert.IsTrue(Elenco.IndexOf('ScrollOptionsVertical') >= 0, 'gruppo: ScrollOptionsVertical');

    Elenco.Clear;
    Layout.OnGetItemStoredProperties(Layout, Elemento, Elenco);
    Assert.AreEqual(2, Elenco.Count, 'elemento');
    Assert.IsTrue(Elenco.IndexOf('ImageIndex') >= 0, 'elemento: ImageIndex');
    Assert.IsTrue(Elenco.IndexOf('VisibleElements') >= 0, 'elemento: VisibleElements');

    Elenco.Clear;
    Layout.OnGetItemStoredProperties(Layout, Spazio, Elenco);
    Assert.AreEqual(0, Elenco.Count, 'spazio vuoto');
  finally
    Elenco.Free;
  end;
end;

procedure TTestzDXModulo.ProprietaSalvate_LayoutLookAndFeel_ScritturaELettura;
var
  Layout: TdxLayoutControl;
  Origine, Destinazione: TdxLayoutGroup;
  Valore: Variant;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Origine := NuovoGruppo(Layout);
  Destinazione := NuovoGruppo(Layout);
  Origine.LayoutLookAndFeel := dx.LayoutLookAndFeelNoGroupBorder;

  Layout.OnGetItemStoredPropertyValue(Layout, Origine, 'LayoutLookAndFeel', Valore);
  Assert.AreEqual('LayoutLookAndFeelNoBorder', VarToStr(Valore), 'nome salvato');

  Layout.OnSetItemStoredPropertyValue(Layout, Destinazione, 'LayoutLookAndFeel', Valore);
  Assert.IsTrue(Destinazione.LayoutLookAndFeel = dx.LayoutLookAndFeelNoGroupBorder, 'look and feel ripristinato');
end;

procedure TTestzDXModulo.ProprietaSalvate_LookAndFeel_ScritturaELettura;
var
  Layout: TdxLayoutControl;
  Origine, Destinazione: TdxLayoutGroup;
  Valore: Variant;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Origine := NuovoGruppo(Layout);
  Destinazione := NuovoGruppo(Layout);
  Origine.LookAndFeel := dx.LayoutLookAndFeelNormal;

  Layout.OnGetItemStoredPropertyValue(Layout, Origine, 'LookAndFeel', Valore);
  Assert.AreEqual('LayoutLookAndFeelNormal', VarToStr(Valore), 'nome salvato');

  Layout.OnSetItemStoredPropertyValue(Layout, Destinazione, 'LookAndFeel', Valore);
  Assert.IsTrue(Destinazione.LookAndFeel = dx.LayoutLookAndFeelNormal, 'look and feel ripristinato');
end;

procedure TTestzDXModulo.ProprietaSalvate_NomeSconosciutoOVuoto_Ignorato;
var
  Layout: TdxLayoutControl;
  Gruppo: TdxLayoutGroup;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Gruppo := NuovoGruppo(Layout);

  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'LayoutLookAndFeel', 'Inesistente');
  Assert.IsTrue(Gruppo.LayoutLookAndFeel = nil, 'nome sconosciuto');

  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'LayoutLookAndFeel', '');
  Assert.IsTrue(Gruppo.LayoutLookAndFeel = nil, 'nome vuoto');

  // DIV-ICO-14: un nome vuoto non toglie un look and feel gia' assegnato
  Gruppo.LayoutLookAndFeel := dx.LayoutLookAndFeelNoGroupBorder;
  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'LayoutLookAndFeel', '');
  Assert.IsTrue(Gruppo.LayoutLookAndFeel = dx.LayoutLookAndFeelNoGroupBorder, 'nome vuoto con look and feel presente');

  // un nome di proprieta' sconosciuto e' ignorato
  Gruppo.LayoutLookAndFeel := nil;
  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'ProprietaCheNonEsiste', 'LayoutLookAndFeelNormal');
  Assert.IsTrue(Gruppo.LayoutLookAndFeel = nil, 'proprieta sconosciuta');
end;

procedure TTestzDXModulo.ProprietaSalvate_GruppoSenzaLookAndFeel_StringaVuota;
var
  Layout: TdxLayoutControl;
  Gruppo: TdxLayoutGroup;
  Valore: Variant;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Gruppo := NuovoGruppo(Layout);
  Gruppo.LayoutLookAndFeel := nil;

  Layout.OnGetItemStoredPropertyValue(Layout, Gruppo, 'LayoutLookAndFeel', Valore);

  Assert.AreEqual('', VarToStr(Valore));
end;

procedure TTestzDXModulo.ProprietaSalvate_ImageIndex_ScritturaELettura;
var
  Layout: TdxLayoutControl;
  Gruppo: TdxLayoutGroup;
  Elemento: TdxLayoutItem;
  Valore: Variant;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Gruppo := NuovoGruppo(Layout);
  Elemento := Layout.CreateItem(TdxLayoutItem, Gruppo) as TdxLayoutItem;

  Elemento.CaptionOptions.ImageIndex := 5;
  Layout.OnGetItemStoredPropertyValue(Layout, Elemento, 'ImageIndex', Valore);
  Assert.AreEqual(5, Integer(Valore), 'elemento, lettura');
  Layout.OnSetItemStoredPropertyValue(Layout, Elemento, 'ImageIndex', 7);
  Assert.AreEqual(7, Integer(Elemento.CaptionOptions.ImageIndex), 'elemento, scrittura');

  Gruppo.CaptionOptions.ImageIndex := 9;
  Layout.OnGetItemStoredPropertyValue(Layout, Gruppo, 'ImageIndex', Valore);
  Assert.AreEqual(9, Integer(Valore), 'gruppo, lettura');
  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'ImageIndex', 11);
  Assert.AreEqual(11, Integer(Gruppo.CaptionOptions.ImageIndex), 'gruppo, scrittura');
end;

procedure TTestzDXModulo.ProprietaSalvate_VisibleElements_ScritturaELettura;
var
  Layout: TdxLayoutControl;
  Gruppo: TdxLayoutGroup;
  Elemento: TdxLayoutItem;
  Originale: TdxLayoutItemCaptionVisibleElements;
  Valore: Variant;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Gruppo := NuovoGruppo(Layout);
  Elemento := Layout.CreateItem(TdxLayoutItem, Gruppo) as TdxLayoutItem;

  Originale := Elemento.CaptionOptions.VisibleElements;
  Layout.OnGetItemStoredPropertyValue(Layout, Elemento, 'VisibleElements', Valore);
  Assert.IsTrue(VarIsStr(Valore), 'il valore salvato e'' un testo');

  Elemento.CaptionOptions.VisibleElements := [];
  Layout.OnSetItemStoredPropertyValue(Layout, Elemento, 'VisibleElements', Valore);

  Assert.IsTrue(Elemento.CaptionOptions.VisibleElements = Originale);
end;

procedure TTestzDXModulo.ProprietaSalvate_HideTabsEScorrimento_ScritturaELettura;
var
  Layout: TdxLayoutControl;
  Gruppo: TdxLayoutGroup;
  Valore: Variant;
begin
  Layout := NuovoLayout;
  dx.InitLayoutControl(Layout);
  Gruppo := NuovoGruppo(Layout);

  Gruppo.TabbedOptions.HideTabs := True;
  Layout.OnGetItemStoredPropertyValue(Layout, Gruppo, 'HideTabs', Valore);
  Assert.IsTrue(Boolean(Valore), 'HideTabs letto');
  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'HideTabs', False);
  Assert.IsFalse(Gruppo.TabbedOptions.HideTabs, 'HideTabs scritto');

  // il valore e' il numero dell'enumerazione
  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'ScrollOptionsHorizontal', 1);
  Layout.OnGetItemStoredPropertyValue(Layout, Gruppo, 'ScrollOptionsHorizontal', Valore);
  Assert.AreEqual(1, Integer(Valore), 'scorrimento orizzontale');

  Layout.OnSetItemStoredPropertyValue(Layout, Gruppo, 'ScrollOptionsVertical', 1);
  Layout.OnGetItemStoredPropertyValue(Layout, Gruppo, 'ScrollOptionsVertical', Valore);
  Assert.AreEqual(1, Integer(Valore), 'scorrimento verticale');
end;

// --- ZBASE-ICO-006

procedure TTestzDXModulo.LookAndFeel_DueIstanzeConNomiEPresentiNellElenco;
begin
  Assert.IsTrue(dx.LayoutLookAndFeelNormal <> dx.LayoutLookAndFeelNoGroupBorder, 'due istanze');
  Assert.AreEqual('LayoutLookAndFeelNormal', dx.LayoutLookAndFeelNormal.Name, 'nome del normale');
  Assert.AreEqual('LayoutLookAndFeelNoBorder', dx.LayoutLookAndFeelNoGroupBorder.Name, 'nome senza bordo');

  // il ripristino delle proprieta' salvate cerca i nomi proprio qui
  Assert.IsTrue(dx.dxLayoutLookAndFeelList.FindComponent('LayoutLookAndFeelNormal') = TComponent(dx.LayoutLookAndFeelNormal), 'elenco: normale');
  Assert.IsTrue(dx.dxLayoutLookAndFeelList.FindComponent('LayoutLookAndFeelNoBorder') = TComponent(dx.LayoutLookAndFeelNoGroupBorder), 'elenco: senza bordo');

  Assert.IsFalse((dx.LayoutLookAndFeelNormal as TzLayoutLookAndFeel).HideGroupBorder, 'HideGroupBorder del normale');
  Assert.IsTrue((dx.LayoutLookAndFeelNoGroupBorder as TzLayoutLookAndFeel).HideGroupBorder, 'HideGroupBorder senza bordo');
end;

procedure TTestzDXModulo.LookAndFeel_StileUltraFlatEStileNativoSpento;
var
  Normale, SenzaBordo: TzLayoutLookAndFeel;
begin
  Normale := dx.LayoutLookAndFeelNormal as TzLayoutLookAndFeel;
  SenzaBordo := dx.LayoutLookAndFeelNoGroupBorder as TzLayoutLookAndFeel;

  Assert.AreEqual(Ord(lfUltraFlat), Ord(Normale.LookAndFeel.Kind), 'normale: stile');
  Assert.IsFalse(Normale.LookAndFeel.NativeStyle, 'normale: stile nativo');
  Assert.AreEqual(Ord(lfUltraFlat), Ord(SenzaBordo.LookAndFeel.Kind), 'senza bordo: stile');
  Assert.IsFalse(SenzaBordo.LookAndFeel.NativeStyle, 'senza bordo: stile nativo');
end;

procedure TTestzDXModulo.LookAndFeel_SenzaBordoDeiGruppi_OffsetZero;
var
  Aspetto: TzLayoutLookAndFeel;
begin
  Aspetto := dx.LayoutLookAndFeelNoGroupBorder as TzLayoutLookAndFeel;

  Assert.AreEqual(0, Aspetto.GetGroupBorderOffset(nil, TdxLayoutSide(0), TdxLayoutSide(0)), 'primo lato');
  Assert.AreEqual(0, Aspetto.GetGroupBorderOffset(nil, TdxLayoutSide(2), TdxLayoutSide(0)), 'terzo lato');
end;

procedure TTestzDXModulo.LookAndFeel_IlDisegnoDeiGruppiEQuelloStandard;
begin
  Assert.IsTrue((dx.LayoutLookAndFeelNormal as TzLayoutLookAndFeel).GetGroupPainterClass = TdxLayoutGroupStandardPainter, 'normale');
  Assert.IsTrue((dx.LayoutLookAndFeelNoGroupBorder as TzLayoutLookAndFeel).GetGroupPainterClass = TdxLayoutGroupStandardPainter, 'senza bordo');
end;

procedure TTestzDXModulo.LayoutControlHeigth_LayoutVuoto_NonNegativo;
var
  Layout: TdxLayoutControl;
  Altezza: integer;
begin
  Layout := NuovoLayout;
  Altezza := -1;

  Assert.WillNotRaiseAny(
    procedure
    begin
      Altezza := dx.LayoutControlHeigth(Layout);
    end);

  Assert.IsTrue(Altezza >= 0, 'altezza non negativa');
end;

// --- ZBASE-ICO-007

procedure TTestzDXModulo.InitBar_BarraNuova_ImpostazioniFisse;
var
  Gestore: TdxBarManager;
  Barra: TdxBar;
begin
  Gestore := TdxBarManager.Create(FFinestra);
  Barra := Gestore.Bars.Add;
  Barra.AllowClose := True;
  Barra.AllowCustomizing := True;
  Barra.AllowQuickCustomizing := True;
  Barra.AllowReset := True;
  Barra.ShowMark := True;
  Barra.WholeRow := False;
  Barra.OneOnRow := False;
  Barra.UseRestSpace := False;

  dx.InitBar(Barra);

  Assert.IsFalse(Barra.AllowClose, 'AllowClose');
  Assert.IsFalse(Barra.AllowCustomizing, 'AllowCustomizing');
  Assert.IsFalse(Barra.AllowQuickCustomizing, 'AllowQuickCustomizing');
  Assert.IsFalse(Barra.AllowReset, 'AllowReset');
  Assert.IsFalse(Barra.ShowMark, 'ShowMark');
  Assert.IsTrue(Barra.WholeRow, 'WholeRow');
  Assert.IsTrue(Barra.OneOnRow, 'OneOnRow');
  Assert.IsTrue(Barra.UseRestSpace, 'UseRestSpace');
  Assert.AreEqual(Ord(bbsNone), Ord(Barra.BorderStyle), 'BorderStyle');
end;

procedure TTestzDXModulo.dxBarAssignPopupMenu_BarraSenzaControllo_NonSolleva;
var
  Gestore: TdxBarManager;
  Barra: TdxBar;
  Menu: TdxBarPopupMenu;
begin
  Gestore := TdxBarManager.Create(FFinestra);
  Barra := Gestore.Bars.Add;
  Menu := TdxBarPopupMenu.Create(FFinestra);

  if Barra.Control <> nil then
  begin
    Assert.Pass('la barra ha gia'' un controllo, prova non applicabile');
    Exit;
  end;

  // DIV-ICO-3: senza controllo non fa nulla e non lo segnala
  Assert.WillNotRaiseAny(
    procedure
    begin
      dx.dxBarAssignPopupMenu(Barra, Menu);
    end);
  Assert.IsTrue(Barra.Control = nil, 'il controllo non e'' stato creato');
end;

procedure TTestzDXModulo.dxBarRequiredWidth_BarraNilOSenzaControllo_Zero;
var
  Gestore: TdxBarManager;
  Barra: TdxBar;
begin
  Assert.AreEqual(0, dx.dxBarRequiredWidth(nil), 'barra nil');

  Gestore := TdxBarManager.Create(FFinestra);
  Barra := Gestore.Bars.Add;
  if Barra.Control <> nil then
  begin
    Assert.Pass('la barra ha gia'' un controllo, prova non applicabile');
    Exit;
  end;

  Assert.AreEqual(0, dx.dxBarRequiredWidth(Barra), 'barra senza controllo');
end;

// --- ZBASE-ICO-008

procedure TTestzDXModulo.InitPrinter_StampanteNuova_ImpostazioniFisse;
var
  Stampante: TdxComponentPrinter;
begin
  Stampante := TdxComponentPrinter.Create(FFinestra);
  Stampante.Options := Stampante.Options + [cpoShowHourGlass];
  Stampante.PreviewOptions.SaveZoomPosition := True;
  Stampante.PreviewOptions.Caption := 'Altro titolo';

  dx.InitPrinter(Stampante);

  Assert.IsFalse(cpoShowHourGlass in Stampante.Options, 'clessidra');
  Assert.IsFalse(Stampante.PreviewOptions.SaveZoomPosition, 'SaveZoomPosition');
  Assert.AreEqual('Anteprima', Stampante.PreviewOptions.Caption, 'titolo');
  Assert.AreEqual(Ord(wsMaximized), Ord(Stampante.PreviewOptions.WindowState), 'WindowState');
  Assert.AreEqual(800, Stampante.PreviewOptions.Width, 'larghezza');
  Assert.AreEqual(0, Stampante.PreviewOptions.Left, 'sinistra');
  Assert.AreEqual(0, Stampante.PreviewOptions.Top, 'alto');
end;

// --- ZBASE-ICO-009

procedure TTestzDXModulo.InitGrid_VistaConDatabase_StiliEGridMode;
var
  Vista: TcxGridDBTableView;
begin
  Vista := TcxGridDBTableView.Create(FFinestra);

  dx.InitGrid(Vista);

  Assert.AreEqual(50, Vista.OptionsBehavior.BestFitMaxRecordCount, 'BestFitMaxRecordCount');
  Assert.AreEqual('dd.mm.yyyy', Vista.DataController.Filter.DateTimeFormat, 'formato dei filtri sulle date');
  Assert.IsTrue(Vista.OptionsSelection.CellSelect, 'CellSelect');
  Assert.IsFalse(Vista.OptionsSelection.HideSelection, 'HideSelection');
  Assert.IsTrue(TcxGridDBDataController(Vista.DataController).DataModeController.GridMode, 'GridMode');
  Assert.IsTrue(Vista.Styles.Background = dx.cxStyleContent, 'sfondo');
  Assert.IsTrue(Vista.Styles.Content = dx.cxStyleContent, 'contenuto');
  Assert.IsTrue(Vista.Styles.ContentEven = dx.cxStyleContentEven, 'righe pari');
  Assert.IsTrue(Vista.Styles.ContentOdd = dx.cxStyleContentOdd, 'righe dispari');
  Assert.IsTrue(Vista.Styles.FilterBox = dx.cxStyleFilterBox, 'riquadro filtro');
  Assert.IsTrue(Vista.Styles.Header = dx.cxStyleHeader, 'intestazione');
  Assert.IsTrue(Vista.Styles.Footer = dx.cxStyleFooter, 'piede');
end;

procedure TTestzDXModulo.InitGrid_VistaSenzaDatabase_NienteIntestazioneEPiede;
var
  Vista: TcxGridTableView;
begin
  Vista := TcxGridTableView.Create(FFinestra);

  dx.InitGrid(Vista);

  Assert.AreEqual(50, Vista.OptionsBehavior.BestFitMaxRecordCount, 'BestFitMaxRecordCount');
  Assert.IsTrue(Vista.Styles.Content = dx.cxStyleContent, 'contenuto');
  Assert.IsTrue(Vista.Styles.Header = nil, 'intestazione');
  Assert.IsTrue(Vista.Styles.Footer = nil, 'piede');
end;

procedure TTestzDXModulo.InitTreeList_AlberoSenzaDatabase_UltraFlatEStili;
var
  Albero: TcxTreeList;
begin
  Albero := TcxTreeList.Create(FFinestra);

  dx.InitTreeList(Albero);

  Assert.AreEqual(Ord(cxcbsNone), Ord(Albero.BorderStyle), 'bordo');
  Assert.AreEqual(Ord(lfUltraFlat), Ord(Albero.LookAndFeel.Kind), 'stile');
  Assert.IsFalse(Albero.OptionsSelection.HideFocusRect, 'HideFocusRect');
  Assert.IsTrue(Albero.Styles.Background = dx.GetStyle(scControl), 'sfondo');
  Assert.IsTrue(Albero.Styles.Content = dx.GetStyle(scControl), 'contenuto');
  Assert.IsTrue(Albero.Styles.Footer = dx.GetStyle(scFooter), 'piede');
  Assert.IsTrue(Albero.Styles.Inactive = dx.cxStyleTreeListInactive, 'inattivo');
end;

procedure TTestzDXModulo.InitTreeList_ApplyStylesFalso_StiliInvariati;
var
  Albero: TcxTreeList;
begin
  Albero := TcxTreeList.Create(FFinestra);

  dx.InitTreeList(Albero, False);

  Assert.AreEqual(Ord(lfUltraFlat), Ord(Albero.LookAndFeel.Kind), 'stile');
  Assert.IsTrue(Albero.Styles.Background = nil, 'sfondo');
  Assert.IsTrue(Albero.Styles.Content = nil, 'contenuto');
  Assert.IsTrue(Albero.Styles.Footer = nil, 'piede');
  Assert.IsTrue(Albero.Styles.Inactive = nil, 'inattivo');
end;

procedure TTestzDXModulo.Divergenza_DIV_ICO_2_AlberoConDatabase_FlatEInattivoDelControllo;
var
  Albero: TcxDBTreeList;
begin
  Albero := TcxDBTreeList.Create(FFinestra);

  dx.InitTreeList(Albero);

  Assert.AreEqual(Ord(cxcbsNone), Ord(Albero.BorderStyle), 'bordo');
  Assert.IsFalse(Albero.OptionsSelection.HideFocusRect, 'HideFocusRect');
  Assert.IsTrue(Albero.Styles.Footer = dx.GetStyle(scFooter), 'piede');
  // fotografia: la versione con database usa lfFlat e per l'inattivo lo stile del
  // controllo; quella senza database lfUltraFlat e cxStyleTreeListInactive
  Assert.AreEqual(Ord(lfFlat), Ord(Albero.LookAndFeel.Kind), 'stile');
  Assert.IsTrue(Albero.Styles.Inactive = dx.GetStyle(scControl), 'inattivo');
end;

procedure TTestzDXModulo.InitPivot_StiliEBordo;
var
  Pivot: TcxDBPivotGrid;
begin
  Pivot := TcxDBPivotGrid.Create(FFinestra);

  dx.InitPivot(Pivot);

  Assert.AreEqual(Ord(cxcbsNone), Ord(Pivot.BorderStyle), 'bordo');
  Assert.AreEqual(Ord(lfUltraFlat), Ord(Pivot.LookAndFeel.Kind), 'stile');
  Assert.IsFalse(Pivot.LookAndFeel.NativeStyle, 'stile nativo');
  Assert.IsTrue(Pivot.Styles.Content = dx.cxStyleContent, 'contenuto');
  Assert.IsTrue(Pivot.Styles.Background = dx.cxStyleContent, 'sfondo');
  Assert.IsTrue(Pivot.Styles.FieldHeader = dx.cxStyleHeader, 'intestazione dei campi');
  Assert.IsTrue(Pivot.Styles.ColumnHeader = dx.cxStyleHeader, 'intestazione delle colonne');
  Assert.IsTrue(Pivot.Styles.RowHeader = dx.cxStyleHeader, 'intestazione delle righe');
  Assert.IsTrue(Pivot.Styles.DataHeaderArea = dx.cxStyleHeader, 'area dati');
  Assert.IsTrue(Pivot.Styles.HeaderBackground = dx.cxStyleHeaderBackground, 'sfondo delle intestazioni');
  Assert.IsTrue(Pivot.Styles.Selected = dx.cxStyleHighlight, 'selezione');
end;

// --- ZBASE-ICO-010

procedure TTestzDXModulo.InitLabel_AutoSizeFalso_PuntiniETrasparente;
var
  Etichetta: TcxLabel;
begin
  Etichetta := TcxLabel.Create(FFinestra);
  Etichetta.AutoSize := False;

  dx.InitLabel(Etichetta);

  Assert.IsFalse(Etichetta.ParentFont, 'ParentFont');
  Assert.IsFalse(Etichetta.ParentColor, 'ParentColor');
  Assert.IsTrue(Etichetta.Style.StyleController = dx.LabelStyleController, 'controller di stile');
  Assert.IsTrue(Etichetta.Properties.ShowEndEllipsis, 'ShowEndEllipsis');
  Assert.IsTrue(Etichetta.Transparent, 'Transparent');
end;

procedure TTestzDXModulo.InitLabel_AutoSizeVero_SenzaPuntini;
var
  Etichetta: TcxLabel;
begin
  Etichetta := TcxLabel.Create(FFinestra);
  Etichetta.AutoSize := True;

  dx.InitLabel(Etichetta, False);

  Assert.IsFalse(Etichetta.Properties.ShowEndEllipsis, 'ShowEndEllipsis');
  Assert.IsFalse(Etichetta.Transparent, 'Transparent');
end;

procedure TTestzDXModulo.InitTitleEInitSeparator_ControllerDiStileETrasparenzaFalsa;
var
  Titolo, Separatore: TcxLabel;
begin
  Titolo := TcxLabel.Create(FFinestra);
  Separatore := TcxLabel.Create(FFinestra);

  dx.InitTitle(Titolo);
  dx.InitSeparator(Separatore);

  Assert.IsTrue(Titolo.Style.StyleController = dx.TitleStyleController, 'titolo: controller');
  Assert.IsFalse(Titolo.Transparent, 'titolo: Transparent');
  Assert.IsFalse(Titolo.ParentFont, 'titolo: ParentFont');
  Assert.IsTrue(Separatore.Style.StyleController = dx.SeparatorStyleController, 'separatore: controller');
  Assert.IsFalse(Separatore.Transparent, 'separatore: Transparent');
end;

procedure TTestzDXModulo.InitPageControl_LinguetteInAlto_ImpostazioniFisseEUnaRiga;
var
  Schede: TcxPageControl;
begin
  Schede := TcxPageControl.Create(FFinestra);
  Schede.LookAndFeel.Kind := lfFlat;
  Schede.TabStop := True;
  Schede.HotTrack := False;
  Schede.ShowFrame := True;
  Schede.Properties.RaggedRight := False;
  Schede.MultiLine := True;

  dx.InitPageControl(Schede);

  Assert.IsTrue(Schede.LookAndFeel.AssignedValues = [], 'look and feel azzerato');
  Assert.IsFalse(Schede.TabStop, 'TabStop');
  Assert.IsTrue(Schede.HotTrack, 'HotTrack');
  Assert.IsFalse(Schede.ShowFrame, 'ShowFrame');
  Assert.IsTrue(Schede.Properties.RaggedRight, 'RaggedRight');
  Assert.IsFalse(Schede.MultiLine, 'MultiLine con le linguette in alto');
end;

procedure TTestzDXModulo.InitPageControl_LinguetteInBasso_MultiLineResta;
var
  Schede: TcxPageControl;
begin
  Schede := TcxPageControl.Create(FFinestra);
  Schede.TabPosition := tpBottom;
  Schede.MultiLine := True;

  dx.InitPageControl(Schede);

  Assert.IsTrue(Schede.MultiLine, 'MultiLine');
  Assert.IsFalse(Schede.ShowFrame, 'ShowFrame');
  Assert.IsTrue(Schede.HotTrack, 'HotTrack');
end;

procedure TTestzDXModulo.InitSplitter_InAlto_AltezzaSette;
var
  Divisore: TcxSplitter;
begin
  Divisore := TcxSplitter.Create(FFinestra);
  Divisore.AlignSplitter := salTop;

  dx.InitSplitter(Divisore);

  Assert.AreEqual(7, Divisore.Height, 'altezza');
  Assert.IsTrue(Divisore.HotZoneStyleClass = TcxMediaPlayer9Style, 'stile della zona sensibile');
end;

procedure TTestzDXModulo.InitSplitter_ASinistra_LarghezzaSette;
var
  Divisore: TcxSplitter;
begin
  Divisore := TcxSplitter.Create(FFinestra);
  Divisore.AlignSplitter := salLeft;

  dx.InitSplitter(Divisore);

  Assert.AreEqual(7, Divisore.Width, 'larghezza');
end;

procedure TTestzDXModulo.SetFilterControlFonts_CaratteriDelloStileMedio;
var
  Filtro: TcxFilterControl;
begin
  Filtro := TcxFilterControl.Create(FFinestra);
  Filtro.FontItem.Size := 6;

  dx.SetFilterControlFonts(Filtro);

  Assert.AreEqual(dx.MediumStyleController.Style.Font.Name, Filtro.FontItem.Name, 'voce: nome');
  Assert.AreEqual(dx.MediumStyleController.Style.Font.Size, Filtro.FontItem.Size, 'voce: dimensione');
  Assert.AreEqual(dx.MediumStyleController.Style.Font.Size, Filtro.FontValue.Size, 'valore: dimensione');
  Assert.AreEqual(dx.MediumStyleController.Style.Font.Size, Filtro.FontCondition.Size, 'condizione: dimensione');
  Assert.AreEqual(dx.MediumStyleController.Style.Font.Size, Filtro.FontBoolOperator.Size, 'operatore: dimensione');
  Assert.AreEqual(dx.MediumStyleController.Style.Font.Size, Filtro.Font.Size, 'carattere del controllo');
end;

procedure TTestzDXModulo.SetFilterControlFonts_FiltroNil_NonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      dx.SetFilterControlFonts(nil);
    end);
end;

// --- ZBASE-ICO-012 (rami che usano i componenti del modulo)

procedure TTestzDXModulo.InitProperties_ctPickListImage_ListaImmagini;
var
  Proprieta: TcxImageComboBoxProperties;
begin
  Proprieta := TcxImageComboBoxProperties.Create(nil);
  try
    dx.InitProperties(ctPickListImage, Proprieta);

    Assert.IsTrue(Proprieta.Images = TCustomImageList(dx.Immagini), 'Images');
    Assert.IsTrue(Proprieta.ImmediatePost, 'ImmediatePost');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXModulo.InitProperties_ctLookupHyperLink_TrePulsanti;
var
  Proprieta: TcxExtLookupComboBoxProperties;
begin
  Proprieta := TcxExtLookupComboBoxProperties.Create(nil);
  try
    dx.InitProperties(ctLookupHyperLink, Proprieta);

    Assert.AreEqual(3, Proprieta.Buttons.Count, 'pulsanti');
    Assert.AreEqual(Ord(bkEllipsis), Ord(Proprieta.Buttons[1].Kind), 'secondo pulsante');
    Assert.AreEqual(Ord(bkGlyph), Ord(Proprieta.Buttons[2].Kind), 'terzo pulsante');
    Assert.IsTrue(Proprieta.GridMode, 'GridMode');
  finally
    Proprieta.Free;
  end;
end;

// --- ZBASE-ICO-017

procedure TTestzDXModulo.InitSpellChecker_SenzaFileDelDizionario_Spento;
var
  Cartella: string;
begin
  Cartella := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
  if FileExists(Cartella + 'it_IT.aff') and FileExists(Cartella + 'it_IT.dic') then
  begin
    Assert.Pass('i file del dizionario ci sono accanto all''eseguibile, prova non applicabile');
    Exit;
  end;

  dx.InitSpellChecker('');

  Assert.IsFalse(dx.CorrettoreAttivo, 'CorrettoreAttivo');
  Assert.IsTrue(dx.CorrettoreMotivo.StartsWith('Manca il file'), 'motivo: ' + dx.CorrettoreMotivo);
  Assert.IsTrue(dx.CorrettoreMotivo.Contains('accanto all''eseguibile'), 'il motivo spiega cosa fare');
  Assert.AreEqual(0, dx.dxSpellChecker.DictionaryItems.Count, 'elenco dei dizionari');
end;

// --- ZBASE-ICO-018

procedure TTestzDXModulo.ChiudiFiltriAperti_SenzaFinestreAperte_NonSolleva;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      dx.ChiudiFiltriAperti;
    end);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzDXClassi);
  TDUnitX.RegisterTestFixture(TTestzDXDominio);
  TDUnitX.RegisterTestFixture(TTestzDXModulo);

end.
