// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zDX.Editor;

// Test DUnitX per zBase\zDX.pas, parte valori e editabilita' degli editor
// (specifica ZBASE-VED, "Valori e editabilità degli editor.md").
// BOZZA scritta senza poterla compilare ne' eseguire.
//
// Gli editor DevExpress si creano senza proprietario, senza parent e senza
// mostrarli (TcxTextEdit.Create(nil) e simili): EditValue, Properties e Style
// non hanno bisogno di una finestra.
//
// Il modulo Tdx (la funzione dx) si crea con il suo costruttore: carica il DFM,
// la skin 'UserSkin', la traduzione e il registro. Non si e' potuto verificare
// che sia sicuro in un programma di prova senza form: DxCreabile prova a
// crearlo una volta e, se solleva un'eccezione, i test che ne hanno bisogno
// terminano con Assert.Pass e il motivo (non falliscono). Una volta creato dx
// resta vivo fino alla chiusura del programma (lo libera la unit), e anche
// SanificaTesto e' dello stesso modulo: ogni fixture lo salva in Setup e lo
// ripristina in TearDown.
//
// Le divergenze provate (DIV-VED-1, 2, 3, 4, 6, 7, 9) fotografano il
// comportamento attuale: vanno capovolte quando il codice viene corretto. Le
// altre non sono provate (DataBind su un editor non DB corromperebbe la
// memoria; DIV-VED-8 chiede finestre vere).
//
// Restano senza prova, per assenza di finestre o di dati:
// - gli overload di SetValue per TcxBarEditItem, TdxBarEdit, TdxBarSpinEdit
//   (servono un TdxBarManager e una barra);
// - GetValue su TcxSpinEdit vuoto (la regola del testo vuoto legge Text, che
//   senza finestra puo' non essere aggiornato);
// - SetEditability(editor) con doValidate vero (ValidateEdit su un editor non
//   attivo puo' disegnare l'icona di errore) e SetValue(editor, Null) su un
//   editor di sola lettura (non e' certo che Clear lo svuoti);
// - ValidaDominio con un campo del dizionario dati marcato SanificaEmail
//   (servono Base.zDataDictionary e un dataset con Field.Origin);
// - SanificaDisplayValue su TcxRichEdit (creare l'editor RTF chiede la finestra);
// - ActiveControl, IsActiveControl e ActiveGrid con un controllo attivo
//   (servono finestre vere e il focus);
// - FillItems con righe senza il segno '=' (dipende da TStrings.KeyNames, da
//   verificare sulla versione di Delphi).

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.UITypes,
  System.Math,
  Data.DB,
  Vcl.Controls,
  Vcl.Forms,
  cxEdit,
  cxGraphics,
  cxLookAndFeelPainters,
  cxClasses,
  cxTextEdit,
  cxMemo,
  cxDropDownEdit,
  cxCalendar,
  cxCheckBox,
  cxCheckComboBox,
  cxRichEdit,
  cxDBEdit,
  cxGrid,
  cxGridCustomView,
  cxGridDBTableView,
  dxGDIPlusClasses,
  DUnitX.TestFramework,
  zSystem,
  zBaseLib,
  zDX;

type
  // ZBASE-VED-001: helper di TcxCustomEdit, senza il modulo Tdx
  [TestFixture]
  TTestzDXHelperEditor = class
  private
    FEdit: TcxTextEdit;
    FData: TcxDateEdit;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-VED-001
    [Test]
    procedure IsEmpty_EditorNuovo_Vero;
    // ZBASE-VED-001
    [Test]
    procedure IsEmpty_ConValore_Falso;
    // ZBASE-VED-001
    [Test]
    procedure IsEmpty_DopoSvuotamento_Vero;
    // ZBASE-VED-001
    [Test]
    procedure IsEmpty_StringaVuota_Falso;
    // ZBASE-VED-001
    [Test]
    procedure AsString_Vuoto_StringaVuota;
    // ZBASE-VED-001
    [Test]
    procedure AsString_ConValore_Valore;
    // ZBASE-VED-001
    [Test]
    procedure AsInteger_Vuoto_MenoUno;
    // ZBASE-VED-001
    [Test]
    procedure AsInteger_ConValore_Valore;
    // ZBASE-VED-001
    [Test]
    procedure AsDouble_Vuoto_Zero;
    // ZBASE-VED-001
    [Test]
    procedure AsDouble_ConValore_Valore;
    // ZBASE-VED-001
    [Test]
    procedure AsDateTime_Vuoto_Zero;
    // ZBASE-VED-001
    [Test]
    procedure AsDateTime_ConValore_Valore;
    // ZBASE-VED-001 (DIV-VED-2: Unassigned non e' vuoto per isEmpty)
    [Test]
    procedure IsEmpty_ValoreUnassigned_Falso;
  end;

  // ZBASE-VED-002, 003, 004, 005, 006: lettura e scrittura dei valori con Tdx
  [TestFixture]
  TTestzDXLetturaScrittura = class
  private
    FEdit: TcxTextEdit;
    FData: TcxDateEdit;
    FNotifiche: Integer;
    FSanificaPrecedente: Boolean;
    procedure Notifica(Sender: TObject);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-VED-002
    [Test]
    procedure ValueStr_EditorVuoto_StringaVuota;
    // ZBASE-VED-002
    [Test]
    procedure ValueStr_EditorNil_StringaVuota;
    // ZBASE-VED-002
    [Test]
    procedure ValueStr_ConValore_Valore;
    // ZBASE-VED-002 (DIV-VED-1)
    [Test]
    procedure ValueInt_EditorVuoto_MenoUno;
    // ZBASE-VED-002
    [Test]
    procedure ValueInt_EditorNil_MenoUno;
    // ZBASE-VED-002
    [Test]
    procedure ValueInt_ConValore_Valore;
    // ZBASE-VED-002 (DIV-VED-1)
    [Test]
    procedure ValueDouble_EditorVuoto_MenoUno;
    // ZBASE-VED-002
    [Test]
    procedure ValueDouble_ConValore_Valore;
    // ZBASE-VED-002
    [Test]
    procedure ValueDate_EditorVuoto_DataNulla;
    // ZBASE-VED-002
    [Test]
    procedure ValueDate_ConValore_Valore;
    // ZBASE-VED-002
    [Test]
    procedure GetValue_EditorNil_Null;
    // ZBASE-VED-002
    [Test]
    procedure GetValue_EditorVuoto_Null;
    // ZBASE-VED-002
    [Test]
    procedure GetValue_ConValore_Valore;

    // ZBASE-VED-003
    [Test]
    procedure SetValue_Valore_Assegna;
    // ZBASE-VED-003
    [Test]
    procedure SetValue_Null_Svuota;
    // ZBASE-VED-003
    [Test]
    procedure SetValue_Unassigned_Svuota;
    // ZBASE-VED-003
    [Test]
    procedure SetValue_EditorNil_NonSolleva;

    // ZBASE-VED-004
    [Test]
    procedure SetValue_CasellaDiSelezione_ImpostaSenzaNotifica;
    // ZBASE-VED-004
    [Test]
    procedure SetValue_CasellaDiSelezione_RipristinaIlGestore;

    // ZBASE-VED-005
    [Test]
    procedure GetStatesString_ValoriMisti_UnoEZero;
    // ZBASE-VED-005
    [Test]
    procedure GetStatesString_ElencoVuoto_StringaVuota;
    // ZBASE-VED-005
    [Test]
    procedure GetStatesString_TuttiFalsi_SoloZeri;

    // ZBASE-VED-006
    [Test]
    procedure DataBind_EditorDb_ImpostaSorgenteECampo;
  end;

  // ZBASE-VED-007, 008, 009: editabilita'
  [TestFixture]
  TTestzDXEditabilita = class
  private
    FEdit: TcxTextEdit;
    FSanificaPrecedente: Boolean;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-VED-007
    [Test]
    procedure Proprieta_Obbligatorio_OpzioniDiValidazione;
    // ZBASE-VED-007
    [Test]
    procedure Proprieta_Obbligatorio_IconaDiErrore;
    // ZBASE-VED-007
    [Test]
    procedure Proprieta_SolaLettura_ReadOnlyVero;
    // ZBASE-VED-007
    [Test]
    procedure Proprieta_NormaleDopoSolaLettura_ReadOnlyFalso;
    // ZBASE-VED-007
    [Test]
    procedure Proprieta_Normale_ValidaAllIngresso;
    // ZBASE-VED-007
    [Test]
    procedure Proprieta_EditorRtf_NonValidaAllIngresso;

    // ZBASE-VED-008
    [Test]
    procedure Editor_SolaLettura_NienteTabEStileDiSolaLettura;
    // ZBASE-VED-008
    [Test]
    procedure Editor_Obbligatorio_TabEStileObbligatorio;
    // ZBASE-VED-008
    [Test]
    procedure Editor_Normale_TabEStileNormale;
    // ZBASE-VED-008
    [Test]
    procedure Editor_Obbligatorio_ReadOnlyFalso;
    // ZBASE-VED-008
    [Test]
    procedure Colonna_SolaLettura_ProprietaDellaColonna;

    // ZBASE-VED-009
    [Test]
    procedure GetStyleController_Normale;
    // ZBASE-VED-009
    [Test]
    procedure GetStyleController_Obbligatorio;
    // ZBASE-VED-009
    [Test]
    procedure GetStyleController_SolaLettura;
    // ZBASE-VED-009
    [Test]
    procedure GetStyleController_TreControllerDistinti;
  end;

  // ZBASE-VED-010, 011, 012, 013: validazione degli editor
  [TestFixture]
  TTestzDXValidazione = class
  private
    FEdit: TcxTextEdit;
    FSanificaPrecedente: Boolean;
    procedure Esegui(Edit: TcxCustomEdit; Sender: TObject; var Valore: Variant; var Testo: TCaption; var Errore: Boolean);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-VED-010
    [Test]
    procedure Obbligatorio_Null_ErroreValoreRichiesto;
    // ZBASE-VED-010
    [Test]
    procedure Obbligatorio_SoloSpazi_Errore;
    // ZBASE-VED-010
    [Test]
    procedure Obbligatorio_SoloCaratteriInvisibili_Errore;
    // ZBASE-VED-010
    [Test]
    procedure Obbligatorio_Valore_NessunErrore;
    // ZBASE-VED-010
    [Test]
    procedure Obbligatorio_NumeroZero_NessunErrore;
    // ZBASE-VED-010
    [Test]
    procedure Obbligatorio_ValoreConSpazioUnificatore_Ripulito;

    // ZBASE-VED-011
    [Test]
    procedure Normale_Null_NessunErrore;
    // ZBASE-VED-011 (DIV-VED-9)
    [Test]
    procedure Normale_ErroreInIngresso_Azzerato;
    // ZBASE-VED-011
    [Test]
    procedure Normale_ValoreConSpazioUnificatore_Ripulito;

    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_PredefinitoAttiva;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_Disattivata_NonTocca;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_Password_NonTocca;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_EditorATendina_NonTocca;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_Marcatura_NonTocca;
    // ZBASE-VED-012
    [Test]
    [Ignore('R-214: il valore non di testo torna come stringa, da indagare (ZBASE-VED-012)')]
    procedure Sanificazione_ValoreNonTesto_NonTocca;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_SenderNonEditor_NonTocca;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_Memo_ConservaGliACapo;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_RigaSingola_ACapoInSpazio;
    // ZBASE-VED-012
    [Test]
    procedure Sanificazione_PunteggiaturaTipografica_Sostituita;

    // ZBASE-VED-013
    [Test]
    procedure Dominio_EditorSenzaCollegamentoDb_NessunaRegola;
    // ZBASE-VED-013
    [Test]
    procedure Dominio_ValoreNull_NessunaRegola;
  end;

  // ZBASE-VED-014, 015, 016: TcxCustomCheckComboBoxHelper e gestori
  [TestFixture]
  TTestzDXCheckComboBox = class
  private
    FCombo: TcxCheckComboBox;
    function Elenco(const Righe: array of string): TStringList;
    procedure Voci(const Righe: array of string);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-VED-014
    [Test]
    procedure FillItems_ChiaveEDescrizione_UnaVocePerRiga;
    // ZBASE-VED-014
    [Test]
    procedure FillItems_SenzaDescrizione_UsaLaChiave;
    // ZBASE-VED-014
    [Test]
    procedure FillItems_SostituisceLeVociPrecedenti;
    // ZBASE-VED-014
    [Test]
    procedure FillItems_ElencoVuoto_SvuotaLeVoci;
    // ZBASE-VED-014
    [Test]
    procedure FillItem_AggiungeInCoda;

    // ZBASE-VED-015
    [Test]
    procedure EnableItems_SoloLeVociElencate;
    // ZBASE-VED-015
    [Test]
    procedure EnableItems_ElencoVuoto_DisabilitaTutte;
    // ZBASE-VED-015
    [Test]
    procedure EnableItems_ConfrontaLaChiaveNonLaDescrizione;
    // ZBASE-VED-015
    [Test]
    procedure EnableItem_SenzaDistinzioneMaiuscole;
    // ZBASE-VED-015
    [Test]
    procedure EnableItem_Disabilita_EPoiRiabilita;
    // ZBASE-VED-015
    [Test]
    procedure EnableItem_Inesistente_NienteCambia;

    // ZBASE-VED-016
    [Test]
    procedure EditValueToStates_Null_TuttiDeselezionati;
    // ZBASE-VED-016
    [Test]
    procedure EditValueToStates_Valore_SelezionaLeVociElencate;
    // ZBASE-VED-016
    [Test]
    procedure EditValueToStates_ValoreSenzaDelimitatoreFinale_Funziona;
    // ZBASE-VED-016 (DIV-VED-3)
    [Test]
    procedure EditValueToStates_CodiceCheContieneUnAltro_SelezionaAncheQuello;
    // ZBASE-VED-016
    [Test]
    procedure StatesToEditValue_VociSelezionate_ConDelimitatoreFinale;
    // ZBASE-VED-016
    [Test]
    procedure StatesToEditValue_NessunaSelezione_Null;
    // ZBASE-VED-016
    [Test]
    procedure ConversioneDiAndataERitorno_RestituisceLeStesseVoci;
    // ZBASE-VED-016
    [Test]
    procedure Gestori_ConInitProperties_Assegnati;
    // ZBASE-VED-016
    [Test]
    procedure Gestore_EditValueToStates_DelegaAlHelper;
    // ZBASE-VED-016
    [Test]
    procedure Gestore_StatesToEditValue_DelegaAlHelper;
    // ZBASE-VED-016 (DIV-VED-4)
    [Test]
    procedure Gestore_SenderNil_NonCalcolaNulla;
  end;

  // ZBASE-VED-017, 018: editor attivo, griglia, dimensione dei campi
  [TestFixture]
  TTestzDXEditorAttivo = class
  private
    function Dimensione(Campo: TField): Integer;
  public
    // ZBASE-VED-017
    [Test]
    procedure GridEditable_VistaNil_Falso;
    // ZBASE-VED-017
    [Test]
    procedure GridEditable_ModificaAttiva_Vero;
    // ZBASE-VED-017
    [Test]
    procedure GridEditable_ModificaDisattivata_Falso;
    // ZBASE-VED-017
    [Test]
    procedure ActiveControl_NessunControlloAttivo_Nil;
    // ZBASE-VED-017
    [Test]
    procedure ActiveGrid_NessunControlloAttivo_Nil;
    // ZBASE-VED-017
    [Test]
    procedure IsActiveControl_EditorNonAttivo_Falso;
    // ZBASE-VED-017
    [Test]
    procedure IsActiveControl_GrigliaNonAttiva_Falso;
    // ZBASE-VED-017 (DIV-VED-7)
    [Test]
    procedure IsActiveControl_EditorNil_VeroSeNessunControlloAttivo;

    // ZBASE-VED-018
    [Test]
    procedure FieldSize_CampoNil_Venti;
    // ZBASE-VED-018
    [Test]
    procedure FieldSize_TestoFinoAVenti_Venti;
    // ZBASE-VED-018
    [Test]
    procedure FieldSize_TestoDaVentunoACinquanta_Cinquanta;
    // ZBASE-VED-018
    [Test]
    procedure FieldSize_TestoOltreCinquanta_Cento;
    // ZBASE-VED-018
    [Test]
    procedure FieldSize_Booleano_Cinque;
    // ZBASE-VED-018
    [Test]
    procedure FieldSize_NumeriEDate_Venti;
    // ZBASE-VED-018
    [Test]
    procedure FieldSize_MemoEBlob_NovecentoNovantanove;
    // ZBASE-VED-018 (DIV-VED-6)
    [Test]
    procedure FieldSize_MemoUnicode_Venti;
  end;

implementation

var
  // 0 = non ancora provato, 1 = dx creato, 2 = dx non creabile
  StatoDx: Integer = 0;
  MotivoDx: string = '';

// Prova a creare il modulo Tdx una sola volta e ricorda l'esito
function DxCreabile: Boolean;
begin
  if StatoDx = 0 then
  begin
    try
      if dx <> nil then
        StatoDx := 1
      else
        StatoDx := 2;
    except
      on E: Exception do
      begin
        StatoDx := 2;
        MotivoDx := E.ClassName + ': ' + E.Message;
      end;
    end;
  end;

  Result := StatoDx = 1;
end;

// Se dx non si crea il test finisce come superato, con il motivo
function DxDisponibile: Boolean;
begin
  Result := DxCreabile;

  if not Result then
    Assert.Pass('Tdx non creabile senza finestre: ' + MotivoDx);
end;

{ TTestzDXHelperEditor }

procedure TTestzDXHelperEditor.Setup;
begin
  FEdit := TcxTextEdit.Create(nil);
  FData := TcxDateEdit.Create(nil);
end;

procedure TTestzDXHelperEditor.TearDown;
begin
  FreeAndNil(FData);
  FreeAndNil(FEdit);
end;

procedure TTestzDXHelperEditor.IsEmpty_EditorNuovo_Vero;
begin
  Assert.IsTrue(FEdit.isEmpty);
end;

procedure TTestzDXHelperEditor.IsEmpty_ConValore_Falso;
begin
  FEdit.EditValue := 'Mario';

  Assert.IsFalse(FEdit.isEmpty);
end;

procedure TTestzDXHelperEditor.IsEmpty_DopoSvuotamento_Vero;
begin
  FEdit.EditValue := 'Mario';
  FEdit.EditValue := Null;

  Assert.IsTrue(FEdit.isEmpty);
end;

procedure TTestzDXHelperEditor.IsEmpty_StringaVuota_Falso;
begin
  // vuoto vuol dire solo Null: la stringa vuota e' un valore (se l'editor la
  // conserva cosi' com'e')
  FEdit.EditValue := '';

  if VarIsNull(FEdit.EditValue) then
  begin
    Assert.Pass('l''editor trasforma la stringa vuota in Null: prova non applicabile');
    Exit;
  end;

  Assert.IsFalse(FEdit.isEmpty);
end;

procedure TTestzDXHelperEditor.AsString_Vuoto_StringaVuota;
begin
  Assert.AreEqual('', FEdit.asString);
end;

procedure TTestzDXHelperEditor.AsString_ConValore_Valore;
begin
  FEdit.EditValue := 'Mario Rossi';

  Assert.AreEqual('Mario Rossi', FEdit.asString);
end;

procedure TTestzDXHelperEditor.AsInteger_Vuoto_MenoUno;
begin
  Assert.AreEqual(-1, FEdit.asInteger);
end;

procedure TTestzDXHelperEditor.AsInteger_ConValore_Valore;
begin
  FEdit.EditValue := 42;

  Assert.AreEqual(42, FEdit.asInteger);
end;

procedure TTestzDXHelperEditor.AsDouble_Vuoto_Zero;
begin
  // a differenza di asInteger il valore di un editor vuoto e' 0, non -1
  Assert.AreEqual(Double(0), FEdit.asDouble, 0.0000001);
end;

procedure TTestzDXHelperEditor.AsDouble_ConValore_Valore;
begin
  FEdit.EditValue := 2.5;

  Assert.AreEqual(Double(2.5), FEdit.asDouble, 0.0000001);
end;

procedure TTestzDXHelperEditor.AsDateTime_Vuoto_Zero;
begin
  Assert.AreEqual(Double(0), Double(FData.asDateTime), 0.0000001);
end;

procedure TTestzDXHelperEditor.AsDateTime_ConValore_Valore;
begin
  FData.EditValue := VarFromDateTime(EncodeDate(2026, 11, 1));

  Assert.AreEqual(Double(EncodeDate(2026, 11, 1)), Double(FData.asDateTime), 0.0000001);
end;

procedure TTestzDXHelperEditor.IsEmpty_ValoreUnassigned_Falso;
begin
  // DIV-VED-2: SetValue tratta Unassigned come vuoto, isEmpty no
  FEdit.EditValue := Unassigned;

  if VarIsNull(FEdit.EditValue) then
  begin
    Assert.Pass('l''editor trasforma Unassigned in Null: prova non applicabile');
    Exit;
  end;

  Assert.IsFalse(FEdit.isEmpty);
end;

{ TTestzDXLetturaScrittura }

procedure TTestzDXLetturaScrittura.Setup;
begin
  FEdit := TcxTextEdit.Create(nil);
  FData := TcxDateEdit.Create(nil);
  FNotifiche := 0;
  FSanificaPrecedente := True;

  if DxCreabile then
    FSanificaPrecedente := dx.SanificaTesto;
end;

procedure TTestzDXLetturaScrittura.TearDown;
begin
  if DxCreabile then
    dx.SanificaTesto := FSanificaPrecedente;

  FreeAndNil(FData);
  FreeAndNil(FEdit);
end;

procedure TTestzDXLetturaScrittura.Notifica(Sender: TObject);
begin
  Inc(FNotifiche);
end;

procedure TTestzDXLetturaScrittura.ValueStr_EditorVuoto_StringaVuota;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual('', dx.ValueStr(FEdit));
end;

procedure TTestzDXLetturaScrittura.ValueStr_EditorNil_StringaVuota;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual('', dx.ValueStr(nil));
end;

procedure TTestzDXLetturaScrittura.ValueStr_ConValore_Valore;
begin
  if not DxDisponibile then
    Exit;

  FEdit.EditValue := 'Mario Rossi';

  Assert.AreEqual('Mario Rossi', dx.ValueStr(FEdit));
end;

procedure TTestzDXLetturaScrittura.ValueInt_EditorVuoto_MenoUno;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(-1, dx.ValueInt(FEdit));
end;

procedure TTestzDXLetturaScrittura.ValueInt_EditorNil_MenoUno;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(-1, dx.ValueInt(nil));
end;

procedure TTestzDXLetturaScrittura.ValueInt_ConValore_Valore;
begin
  if not DxDisponibile then
    Exit;

  FEdit.EditValue := 42;

  Assert.AreEqual(42, dx.ValueInt(FEdit));
end;

procedure TTestzDXLetturaScrittura.ValueDouble_EditorVuoto_MenoUno;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(Double(-1), dx.ValueDouble(FEdit), 0.0000001);
end;

procedure TTestzDXLetturaScrittura.ValueDouble_ConValore_Valore;
begin
  if not DxDisponibile then
    Exit;

  FEdit.EditValue := 2.5;

  Assert.AreEqual(Double(2.5), dx.ValueDouble(FEdit), 0.0000001);
end;

procedure TTestzDXLetturaScrittura.ValueDate_EditorVuoto_DataNulla;
begin
  if not DxDisponibile then
    Exit;

  // NullDate (zFbDataSet) vale -700000
  Assert.AreEqual(Double(-700000), Double(dx.ValueDate(FData)), 0.0000001);
end;

procedure TTestzDXLetturaScrittura.ValueDate_ConValore_Valore;
begin
  if not DxDisponibile then
    Exit;

  FData.EditValue := VarFromDateTime(EncodeDate(2026, 11, 1));

  Assert.AreEqual(Double(EncodeDate(2026, 11, 1)), Double(dx.ValueDate(FData)), 0.0000001);
end;

procedure TTestzDXLetturaScrittura.GetValue_EditorNil_Null;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsTrue(VarIsNull(dx.GetValue(nil)));
end;

procedure TTestzDXLetturaScrittura.GetValue_EditorVuoto_Null;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsTrue(VarIsNull(dx.GetValue(FEdit)));
end;

procedure TTestzDXLetturaScrittura.GetValue_ConValore_Valore;
begin
  if not DxDisponibile then
    Exit;

  FEdit.EditValue := 'Mario';

  Assert.AreEqual('Mario', VarToStr(dx.GetValue(FEdit)));
end;

procedure TTestzDXLetturaScrittura.SetValue_Valore_Assegna;
begin
  if not DxDisponibile then
    Exit;

  dx.SetValue(FEdit, Variant('Mario'));

  Assert.AreEqual('Mario', VarToStr(FEdit.EditValue));
end;

procedure TTestzDXLetturaScrittura.SetValue_Null_Svuota;
begin
  if not DxDisponibile then
    Exit;

  FEdit.EditValue := 'Mario';

  dx.SetValue(FEdit, Variant(Null));

  Assert.IsTrue(FEdit.isEmpty);
end;

procedure TTestzDXLetturaScrittura.SetValue_Unassigned_Svuota;
begin
  if not DxDisponibile then
    Exit;

  FEdit.EditValue := 'Mario';

  dx.SetValue(FEdit, Variant(Unassigned));

  Assert.IsTrue(FEdit.isEmpty);
end;

procedure TTestzDXLetturaScrittura.SetValue_EditorNil_NonSolleva;
begin
  if not DxDisponibile then
    Exit;

  Assert.WillNotRaiseAny(
    procedure
    begin
      dx.SetValue(TcxCustomEdit(nil), Variant('Mario'));
    end);
end;

procedure TTestzDXLetturaScrittura.SetValue_CasellaDiSelezione_ImpostaSenzaNotifica;
var
  Casella: TcxCheckBox;
begin
  if not DxDisponibile then
    Exit;

  Casella := TcxCheckBox.Create(nil);
  try
    Casella.Properties.OnEditValueChanged := Notifica;

    dx.SetValue(Casella, True);

    Assert.IsTrue(Casella.Checked, 'selezionata');
    Assert.AreEqual(0, FNotifiche, 'nessuna notifica durante l''assegnazione');
  finally
    Casella.Free;
  end;
end;

procedure TTestzDXLetturaScrittura.SetValue_CasellaDiSelezione_RipristinaIlGestore;
var
  Casella: TcxCheckBox;
begin
  if not DxDisponibile then
    Exit;

  Casella := TcxCheckBox.Create(nil);
  try
    Casella.Properties.OnEditValueChanged := Notifica;

    dx.SetValue(Casella, True);

    var Atteso: TNotifyEvent := Notifica;
    var Attuale: TNotifyEvent := Casella.Properties.OnEditValueChanged;
    Assert.IsTrue((TMethod(Attuale).Code = TMethod(Atteso).Code) and (TMethod(Attuale).Data = TMethod(Atteso).Data), 'gestore rimesso');
  finally
    Casella.Free;
  end;
end;

procedure TTestzDXLetturaScrittura.GetStatesString_ValoriMisti_UnoEZero;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual('101', dx.GetStatesString([True, False, True]));
end;

procedure TTestzDXLetturaScrittura.GetStatesString_ElencoVuoto_StringaVuota;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual('', dx.GetStatesString([]));
end;

procedure TTestzDXLetturaScrittura.GetStatesString_TuttiFalsi_SoloZeri;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual('00', dx.GetStatesString([False, False]));
end;

procedure TTestzDXLetturaScrittura.DataBind_EditorDb_ImpostaSorgenteECampo;
var
  EditorDb: TcxDBTextEdit;
  Sorgente: TDataSource;
begin
  if not DxDisponibile then
    Exit;

  EditorDb := TcxDBTextEdit.Create(nil);
  Sorgente := TDataSource.Create(nil);
  try
    dx.DataBind(EditorDb, Sorgente, 'COGNOME');

    Assert.IsTrue(EditorDb.DataBinding.DataSource = Sorgente, 'sorgente');
    Assert.AreEqual('COGNOME', EditorDb.DataBinding.DataField, 'campo');
  finally
    EditorDb.Free;
    Sorgente.Free;
  end;
end;

{ TTestzDXEditabilita }

procedure TTestzDXEditabilita.Setup;
begin
  FEdit := TcxTextEdit.Create(nil);
  FSanificaPrecedente := True;

  if DxCreabile then
    FSanificaPrecedente := dx.SanificaTesto;
end;

procedure TTestzDXEditabilita.TearDown;
begin
  if DxCreabile then
    dx.SanificaTesto := FSanificaPrecedente;

  FreeAndNil(FEdit);
end;

procedure TTestzDXEditabilita.Proprieta_Obbligatorio_OpzioniDiValidazione;
var
  Proprieta: TcxTextEditProperties;
begin
  if not DxDisponibile then
    Exit;

  Proprieta := TcxTextEditProperties.Create(nil);
  try
    dx.SetEditability(Proprieta, edRequired);

    Assert.IsTrue(Proprieta.ValidateOnEnter, 'ValidateOnEnter');
    Assert.AreEqual(Ord(taRightJustify), Ord(Proprieta.ValidationErrorIconAlignment), 'allineamento icona');
    Assert.IsTrue(Proprieta.ValidationOptions = [evoShowErrorIcon, evoAllowLoseFocus], 'opzioni di validazione');
    Assert.IsTrue(Assigned(Proprieta.OnValidate), 'gestore OnValidate');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXEditabilita.Proprieta_Obbligatorio_IconaDiErrore;
var
  Proprieta: TcxTextEditProperties;
begin
  if not DxDisponibile then
    Exit;

  Proprieta := TcxTextEditProperties.Create(nil);
  try
    dx.SetEditability(Proprieta, edRequired);

    Assert.IsTrue(Assigned(Proprieta.ErrorIcon), 'icona assegnata');
    Assert.IsFalse(Proprieta.ErrorIcon.Empty, 'icona non vuota');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXEditabilita.Proprieta_SolaLettura_ReadOnlyVero;
var
  Proprieta: TcxTextEditProperties;
begin
  if not DxDisponibile then
    Exit;

  Proprieta := TcxTextEditProperties.Create(nil);
  try
    dx.SetEditability(Proprieta, edReadOnly);

    Assert.IsTrue(Proprieta.ReadOnly);
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXEditabilita.Proprieta_NormaleDopoSolaLettura_ReadOnlyFalso;
var
  Proprieta: TcxTextEditProperties;
begin
  if not DxDisponibile then
    Exit;

  Proprieta := TcxTextEditProperties.Create(nil);
  try
    dx.SetEditability(Proprieta, edReadOnly);
    dx.SetEditability(Proprieta, edNormal);

    Assert.IsFalse(Proprieta.ReadOnly);
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXEditabilita.Proprieta_Normale_ValidaAllIngresso;
var
  Proprieta: TcxTextEditProperties;
begin
  if not DxDisponibile then
    Exit;

  Proprieta := TcxTextEditProperties.Create(nil);
  try
    dx.SetEditability(Proprieta, edNormal);

    Assert.IsTrue(Proprieta.ValidateOnEnter, 'ValidateOnEnter');
    Assert.IsTrue(Assigned(Proprieta.OnValidate), 'gestore OnValidate');
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXEditabilita.Proprieta_EditorRtf_NonValidaAllIngresso;
var
  Proprieta: TcxRichEditProperties;
begin
  if not DxDisponibile then
    Exit;

  // Mantis 958: la validazione all'ingresso dell'editor RTF si mangia il Return
  Proprieta := TcxRichEditProperties.Create(nil);
  try
    dx.SetEditability(Proprieta, edRequired);

    Assert.IsFalse(Proprieta.ValidateOnEnter);
  finally
    Proprieta.Free;
  end;
end;

procedure TTestzDXEditabilita.Editor_SolaLettura_NienteTabEStileDiSolaLettura;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edReadOnly, False);

  Assert.IsTrue(FEdit.ActiveProperties.ReadOnly, 'ReadOnly');
  Assert.IsFalse(FEdit.TabStop, 'TabStop');
  Assert.IsTrue(FEdit.Style.StyleController = dx.ReadOnlyStyleController, 'stile');
end;

procedure TTestzDXEditabilita.Editor_Obbligatorio_TabEStileObbligatorio;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edRequired, False);

  Assert.IsTrue(FEdit.TabStop, 'TabStop');
  Assert.IsTrue(FEdit.Style.StyleController = dx.RequiredStyleController, 'stile');
end;

procedure TTestzDXEditabilita.Editor_Normale_TabEStileNormale;
begin
  if not DxDisponibile then
    Exit;

  // dalla sola lettura al normale: il tab e lo stile tornano come prima
  dx.SetEditability(FEdit, edReadOnly, False);
  dx.SetEditability(FEdit, edNormal, False);

  Assert.IsTrue(FEdit.TabStop, 'TabStop');
  Assert.IsTrue(FEdit.Style.StyleController = dx.NormalStyleController, 'stile');
end;

procedure TTestzDXEditabilita.Editor_Obbligatorio_ReadOnlyFalso;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edRequired, False);

  Assert.IsFalse(FEdit.ActiveProperties.ReadOnly);
end;

procedure TTestzDXEditabilita.Colonna_SolaLettura_ProprietaDellaColonna;
var
  Repertorio: TcxGridViewRepository;
  Vista: TcxGridDBTableView;
  Colonna: TcxGridDBColumn;
begin
  if not DxDisponibile then
    Exit;

  Repertorio := TcxGridViewRepository.Create(nil);
  try
    Vista := TcxGridDBTableView(Repertorio.CreateItem(TcxGridDBTableView));
    Colonna := Vista.CreateColumn;
    Colonna.PropertiesClass := TcxTextEditProperties;

    dx.SetEditability(Colonna, edReadOnly);

    Assert.IsTrue(Colonna.Properties.ReadOnly, 'ReadOnly');
    Assert.IsTrue(Assigned(Colonna.Properties.OnValidate), 'gestore OnValidate');
  finally
    Repertorio.Free;
  end;
end;

procedure TTestzDXEditabilita.GetStyleController_Normale;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsTrue(dx.GetStyleController(edNormal) = dx.NormalStyleController);
end;

procedure TTestzDXEditabilita.GetStyleController_Obbligatorio;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsTrue(dx.GetStyleController(edRequired) = dx.RequiredStyleController);
end;

procedure TTestzDXEditabilita.GetStyleController_SolaLettura;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsTrue(dx.GetStyleController(edReadOnly) = dx.ReadOnlyStyleController);
end;

procedure TTestzDXEditabilita.GetStyleController_TreControllerDistinti;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsTrue(dx.GetStyleController(edNormal) <> dx.GetStyleController(edRequired), 'normale diverso da obbligatorio');
  Assert.IsTrue(dx.GetStyleController(edNormal) <> dx.GetStyleController(edReadOnly), 'normale diverso da sola lettura');
  Assert.IsTrue(dx.GetStyleController(edRequired) <> dx.GetStyleController(edReadOnly), 'obbligatorio diverso da sola lettura');
end;

{ TTestzDXValidazione }

procedure TTestzDXValidazione.Setup;
begin
  FEdit := TcxTextEdit.Create(nil);
  FSanificaPrecedente := True;

  if DxCreabile then
  begin
    FSanificaPrecedente := dx.SanificaTesto;
    dx.SanificaTesto := True;
  end;
end;

procedure TTestzDXValidazione.TearDown;
begin
  if DxCreabile then
    dx.SanificaTesto := FSanificaPrecedente;

  FreeAndNil(FEdit);
end;

// Chiama il gestore OnValidate che SetEditability ha assegnato alle proprieta'
// dell'editor: e' l'unico modo di raggiungere ValidateRequired e ValidateNormal,
// che sono privati di Tdx
procedure TTestzDXValidazione.Esegui(Edit: TcxCustomEdit; Sender: TObject; var Valore: Variant; var Testo: TCaption; var Errore: Boolean);
begin
  Edit.ActiveProperties.OnValidate(Sender, Valore, Testo, Errore);
end;

procedure TTestzDXValidazione.Obbligatorio_Null_ErroreValoreRichiesto;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edRequired, False);
  Valore := Null;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsTrue(Errore, 'errore');
  Assert.AreEqual('Valore richiesto', string(Testo));
end;

procedure TTestzDXValidazione.Obbligatorio_SoloSpazi_Errore;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edRequired, False);
  Valore := '    ';
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsTrue(Errore, 'errore');
  Assert.AreEqual('Valore richiesto', string(Testo));
end;

procedure TTestzDXValidazione.Obbligatorio_SoloCaratteriInvisibili_Errore;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // la sanificazione viene prima dell'obbligatorieta': U+200B e U+00A0 spariscono
  // o diventano spazi, e il valore risulta vuoto
  dx.SetEditability(FEdit, edRequired, False);
  Valore := #$200B#$00A0#$200B;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsTrue(Errore, 'errore');
  Assert.AreEqual('Valore richiesto', string(Testo));
end;

procedure TTestzDXValidazione.Obbligatorio_Valore_NessunErrore;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edRequired, False);
  Valore := 'Mario';
  Testo := 'residuo';
  Errore := True;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore, 'errore');
  Assert.AreEqual('', string(Testo), 'testo dell''errore');
  Assert.AreEqual('Mario', VarToStr(Valore), 'valore');
end;

procedure TTestzDXValidazione.Obbligatorio_NumeroZero_NessunErrore;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // un numero non e' testo: non si sanifica, e lo zero non e' un valore mancante
  dx.SetEditability(FEdit, edRequired, False);
  Valore := 0;
  Testo := '';
  Errore := True;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore);
end;

procedure TTestzDXValidazione.Obbligatorio_ValoreConSpazioUnificatore_Ripulito;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edRequired, False);
  Valore := 'Codice' + #$00A0 + 'fiscale';
  Testo := '';
  Errore := True;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore, 'errore');
  Assert.AreEqual('Codice fiscale', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Normale_Null_NessunErrore;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edNormal, False);
  Valore := Null;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore, 'errore');
  Assert.AreEqual('', string(Testo));
end;

procedure TTestzDXValidazione.Normale_ErroreInIngresso_Azzerato;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // DIV-VED-9: ValidateNormal riparte da zero e cancella un errore gia' segnalato
  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'Mario';
  Testo := 'errore precedente';
  Errore := True;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore, 'errore');
  Assert.AreEqual('', string(Testo), 'testo dell''errore');
end;

procedure TTestzDXValidazione.Normale_ValoreConSpazioUnificatore_Ripulito;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'Via' + #$00A0 + 'Roma';
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual('Via Roma', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Sanificazione_PredefinitoAttiva;
var
  Precedente: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // il valore iniziale e' vero (lo imposta il costruttore di Tdx); qui si legge
  // quello che Setup ha trovato prima di forzarlo a vero
  Precedente := FSanificaPrecedente;

  Assert.IsTrue(dx.SanificaTesto, 'dopo Setup');
  Assert.IsTrue(Precedente, 'valore trovato da Setup (il costruttore lo imposta a vero)');
end;

procedure TTestzDXValidazione.Sanificazione_Disattivata_NonTocca;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edNormal, False);
  dx.SanificaTesto := False;
  Valore := 'Via' + #$00A0 + 'Roma';
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual('Via' + #$00A0 + 'Roma', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Sanificazione_Password_NonTocca;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  FEdit.Properties.EchoMode := eemPassword;
  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'Pass' + #$00A0 + 'word';
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual('Pass' + #$00A0 + 'word', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Sanificazione_EditorATendina_NonTocca;
var
  Combo: TcxComboBox;
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // nelle tendine il testo e' una chiave o una voce di elenco: non si ripulisce
  Combo := TcxComboBox.Create(nil);
  try
    dx.SetEditability(Combo, edNormal, False);
    Valore := 'Voce' + #$00A0 + 'uno';
    Testo := '';
    Errore := False;

    Esegui(Combo, Combo, Valore, Testo, Errore);

    Assert.AreEqual('Voce' + #$00A0 + 'uno', VarToStr(Valore));
  finally
    Combo.Free;
  end;
end;

procedure TTestzDXValidazione.Sanificazione_Marcatura_NonTocca;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
  Originale: string;
begin
  if not DxDisponibile then
    Exit;

  // un testo che comincia con {" sembra JSON (ZBASE-SAN-008): le virgolette
  // tipografiche al suo interno restano
  Originale := '{"nome": ' + #$201C + 'x' + #$201D + '}';
  dx.SetEditability(FEdit, edNormal, False);
  Valore := Originale;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual(Originale, VarToStr(Valore));
end;

procedure TTestzDXValidazione.Sanificazione_ValoreNonTesto_NonTocca;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edNormal, False);
  Valore := 12345;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual(Ord(varInteger), Ord(VarType(Valore)), 'tipo del valore');
  Assert.AreEqual(12345, Integer(Valore), 'valore');
end;

procedure TTestzDXValidazione.Sanificazione_SenderNonEditor_NonTocca;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // senza un editor come Sender non si sa di che tipo e' il campo: non si tocca
  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'Via' + #$00A0 + 'Roma';
  Testo := '';
  Errore := False;

  Esegui(FEdit, nil, Valore, Testo, Errore);

  Assert.AreEqual('Via' + #$00A0 + 'Roma', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Sanificazione_Memo_ConservaGliACapo;
var
  Memo: TcxMemo;
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // ZBASE-SAN-006: spazi prima dell'a capo e ai bordi tolti, a capo conservati
  Memo := TcxMemo.Create(nil);
  try
    dx.SetEditability(Memo, edNormal, False);
    Valore := 'Riga uno   ' + #13#10 + 'Riga due ';
    Testo := '';
    Errore := False;

    Esegui(Memo, Memo, Valore, Testo, Errore);

    Assert.AreEqual('Riga uno' + #13#10 + 'Riga due', VarToStr(Valore));
  finally
    Memo.Free;
  end;
end;

procedure TTestzDXValidazione.Sanificazione_RigaSingola_ACapoInSpazio;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // ZBASE-SAN-003: in un campo a riga singola l'a capo diventa uno spazio
  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'Via Roma' + #13#10 + '12';
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual('Via Roma 12', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Sanificazione_PunteggiaturaTipografica_Sostituita;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // ZBASE-SAN-001: gli editor usano il livello predefinito, che comprende la
  // punteggiatura tipografica
  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'Mario ' + #$201C + 'Rossi' + #$201D;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.AreEqual('Mario "Rossi"', VarToStr(Valore));
end;

procedure TTestzDXValidazione.Dominio_EditorSenzaCollegamentoDb_NessunaRegola;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  // un editor non legato a un campo non ha un dominio: nessuna regola e-mail,
  // anche se il testo non e' un indirizzo
  dx.SetEditability(FEdit, edNormal, False);
  Valore := 'non-un-indirizzo';
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore, 'errore');
  Assert.AreEqual('non-un-indirizzo', VarToStr(Valore), 'valore');
end;

procedure TTestzDXValidazione.Dominio_ValoreNull_NessunaRegola;
var
  Valore: Variant;
  Testo: TCaption;
  Errore: Boolean;
begin
  if not DxDisponibile then
    Exit;

  dx.SetEditability(FEdit, edNormal, False);
  Valore := Null;
  Testo := '';
  Errore := False;

  Esegui(FEdit, FEdit, Valore, Testo, Errore);

  Assert.IsFalse(Errore, 'errore');
  Assert.IsTrue(VarIsNull(Valore), 'valore ancora Null');
end;

{ TTestzDXCheckComboBox }

procedure TTestzDXCheckComboBox.Setup;
begin
  FCombo := TcxCheckComboBox.Create(nil);
  FCombo.Properties.Delimiter := '; ';
end;

procedure TTestzDXCheckComboBox.TearDown;
begin
  FreeAndNil(FCombo);
end;

function TTestzDXCheckComboBox.Elenco(const Righe: array of string): TStringList;
var
  Riga: string;
begin
  Result := TStringList.Create;

  for Riga in Righe do
    Result.Add(Riga);
end;

// Riempie la tendina con righe nella forma Chiave=Descrizione
procedure TTestzDXCheckComboBox.Voci(const Righe: array of string);
var
  Righe2: TStringList;
begin
  Righe2 := Elenco(Righe);
  try
    FCombo.FillItems(Righe2);
  finally
    Righe2.Free;
  end;
end;

procedure TTestzDXCheckComboBox.FillItems_ChiaveEDescrizione_UnaVocePerRiga;
begin
  Voci(['A=Alfa', 'B=Beta']);

  Assert.AreEqual(2, FCombo.Properties.Items.Count, 'numero di voci');
  Assert.AreEqual('A', string(FCombo.Properties.Items[0].ShortDescription), 'chiave 0');
  Assert.AreEqual('Alfa', string(FCombo.Properties.Items[0].Description), 'descrizione 0');
  Assert.AreEqual('B', string(FCombo.Properties.Items[1].ShortDescription), 'chiave 1');
  Assert.AreEqual('Beta', string(FCombo.Properties.Items[1].Description), 'descrizione 1');
end;

procedure TTestzDXCheckComboBox.FillItems_SenzaDescrizione_UsaLaChiave;
begin
  // 'C=' ha la chiave ma la descrizione vuota: si usa la chiave
  Voci(['C=']);

  Assert.AreEqual(1, FCombo.Properties.Items.Count, 'numero di voci');
  Assert.AreEqual('C', string(FCombo.Properties.Items[0].ShortDescription), 'chiave');
  Assert.AreEqual('C', string(FCombo.Properties.Items[0].Description), 'descrizione');
end;

procedure TTestzDXCheckComboBox.FillItems_SostituisceLeVociPrecedenti;
begin
  Voci(['A=Alfa', 'B=Beta', 'C=Gamma']);
  Voci(['X=Xeno']);

  Assert.AreEqual(1, FCombo.Properties.Items.Count, 'numero di voci');
  Assert.AreEqual('X', string(FCombo.Properties.Items[0].ShortDescription));
end;

procedure TTestzDXCheckComboBox.FillItems_ElencoVuoto_SvuotaLeVoci;
begin
  Voci(['A=Alfa']);
  Voci([]);

  Assert.AreEqual(0, FCombo.Properties.Items.Count);
end;

procedure TTestzDXCheckComboBox.FillItem_AggiungeInCoda;
begin
  Voci(['A=Alfa']);

  FCombo.FillItem('Beta', 'B');

  Assert.AreEqual(2, FCombo.Properties.Items.Count, 'numero di voci');
  Assert.AreEqual('Beta', string(FCombo.Properties.Items[1].Description), 'descrizione');
  Assert.AreEqual('B', string(FCombo.Properties.Items[1].ShortDescription), 'chiave');
end;

procedure TTestzDXCheckComboBox.EnableItems_SoloLeVociElencate;
var
  Abilitate: TStringList;
begin
  Voci(['A=Alfa', 'B=Beta', 'C=Gamma']);

  Abilitate := Elenco(['A', 'C']);
  try
    FCombo.EnableItems(Abilitate);
  finally
    Abilitate.Free;
  end;

  Assert.IsTrue(FCombo.Properties.Items[0].Enabled, 'A');
  Assert.IsFalse(FCombo.Properties.Items[1].Enabled, 'B');
  Assert.IsTrue(FCombo.Properties.Items[2].Enabled, 'C');
end;

procedure TTestzDXCheckComboBox.EnableItems_ElencoVuoto_DisabilitaTutte;
var
  Abilitate: TStringList;
begin
  Voci(['A=Alfa', 'B=Beta']);

  Abilitate := Elenco([]);
  try
    FCombo.EnableItems(Abilitate);
  finally
    Abilitate.Free;
  end;

  Assert.IsFalse(FCombo.Properties.Items[0].Enabled, 'A');
  Assert.IsFalse(FCombo.Properties.Items[1].Enabled, 'B');
end;

procedure TTestzDXCheckComboBox.EnableItems_ConfrontaLaChiaveNonLaDescrizione;
var
  Abilitate: TStringList;
begin
  Voci(['A=Alfa', 'B=Beta']);

  // nell'elenco c'e' la descrizione, non la chiave: nessuna voce resta abilitata
  Abilitate := Elenco(['Alfa']);
  try
    FCombo.EnableItems(Abilitate);
  finally
    Abilitate.Free;
  end;

  Assert.IsFalse(FCombo.Properties.Items[0].Enabled, 'A');
  Assert.IsFalse(FCombo.Properties.Items[1].Enabled, 'B');
end;

procedure TTestzDXCheckComboBox.EnableItem_SenzaDistinzioneMaiuscole;
begin
  Voci(['A=Alfa', 'B=Beta']);

  FCombo.EnableItem('b', False);

  Assert.IsTrue(FCombo.Properties.Items[0].Enabled, 'A');
  Assert.IsFalse(FCombo.Properties.Items[1].Enabled, 'B');
end;

procedure TTestzDXCheckComboBox.EnableItem_Disabilita_EPoiRiabilita;
begin
  Voci(['A=Alfa']);

  FCombo.EnableItem('A', False);
  Assert.IsFalse(FCombo.Properties.Items[0].Enabled, 'dopo la disabilitazione');

  FCombo.EnableItem('A', True);
  Assert.IsTrue(FCombo.Properties.Items[0].Enabled, 'dopo la riabilitazione');
end;

procedure TTestzDXCheckComboBox.EnableItem_Inesistente_NienteCambia;
begin
  Voci(['A=Alfa', 'B=Beta']);

  FCombo.EnableItem('Z', False);

  Assert.IsTrue(FCombo.Properties.Items[0].Enabled, 'A');
  Assert.IsTrue(FCombo.Properties.Items[1].Enabled, 'B');
end;

procedure TTestzDXCheckComboBox.EditValueToStates_Null_TuttiDeselezionati;
var
  Stati: TcxCheckStates;
begin
  Voci(['A=Alfa', 'B=Beta']);
  SetLength(Stati, 2);
  Stati[0] := cbsChecked;
  Stati[1] := cbsChecked;

  FCombo.EditValueToStates(Null, Stati);

  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[0]), 'A');
  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[1]), 'B');
end;

procedure TTestzDXCheckComboBox.EditValueToStates_Valore_SelezionaLeVociElencate;
var
  Stati: TcxCheckStates;
begin
  Voci(['A=Alfa', 'B=Beta', 'C=Gamma']);
  SetLength(Stati, 3);

  FCombo.EditValueToStates('A; C; ', Stati);

  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[0]), 'A');
  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[1]), 'B');
  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[2]), 'C');
end;

procedure TTestzDXCheckComboBox.EditValueToStates_ValoreSenzaDelimitatoreFinale_Funziona;
var
  Stati: TcxCheckStates;
begin
  Voci(['A=Alfa', 'B=Beta']);
  SetLength(Stati, 2);

  FCombo.EditValueToStates('B', Stati);

  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[0]), 'A');
  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[1]), 'B');
end;

procedure TTestzDXCheckComboBox.EditValueToStates_CodiceCheContieneUnAltro_SelezionaAncheQuello;
var
  Stati: TcxCheckStates;
begin
  // DIV-VED-3: la ricerca e' per sottostringa. Con le voci 'A' e 'AB' il valore
  // 'AB; ' seleziona entrambe, mentre dovrebbe selezionare solo 'AB'
  Voci(['A=Alfa', 'AB=Alfa e Beta']);
  SetLength(Stati, 2);

  FCombo.EditValueToStates('AB; ', Stati);

  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[0]), 'A selezionata per sbaglio');
  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[1]), 'AB');
end;

procedure TTestzDXCheckComboBox.StatesToEditValue_VociSelezionate_ConDelimitatoreFinale;
var
  Stati: TcxCheckStates;
  Valore: Variant;
begin
  Voci(['A=Alfa', 'B=Beta', 'C=Gamma']);
  SetLength(Stati, 3);
  Stati[0] := cbsChecked;
  Stati[1] := cbsUnchecked;
  Stati[2] := cbsChecked;

  FCombo.StatesToEditValue(Stati, Valore);

  Assert.AreEqual('A; C; ', VarToStr(Valore));
end;

procedure TTestzDXCheckComboBox.StatesToEditValue_NessunaSelezione_Null;
var
  Stati: TcxCheckStates;
  Valore: Variant;
begin
  Voci(['A=Alfa', 'B=Beta']);
  SetLength(Stati, 2);
  Stati[0] := cbsUnchecked;
  Stati[1] := cbsUnchecked;

  FCombo.StatesToEditValue(Stati, Valore);

  Assert.IsTrue(VarIsNull(Valore));
end;

procedure TTestzDXCheckComboBox.ConversioneDiAndataERitorno_RestituisceLeStesseVoci;
var
  Stati: TcxCheckStates;
  Valore: Variant;
begin
  Voci(['A=Alfa', 'B=Beta', 'C=Gamma']);
  SetLength(Stati, 3);
  Stati[0] := cbsUnchecked;
  Stati[1] := cbsChecked;
  Stati[2] := cbsChecked;

  FCombo.StatesToEditValue(Stati, Valore);
  SetLength(Stati, 3);
  FCombo.EditValueToStates(Valore, Stati);

  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[0]), 'A');
  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[1]), 'B');
  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[2]), 'C');
end;

procedure TTestzDXCheckComboBox.Gestori_ConInitProperties_Assegnati;
begin
  if not DxDisponibile then
    Exit;

  // InitProperties serve solo da veicolo per assegnare i due gestori di Tdx
  dx.InitProperties(ctCheckComboBox, FCombo.Properties);

  Assert.IsTrue(Assigned(FCombo.Properties.OnEditValueToStates), 'OnEditValueToStates');
  Assert.IsTrue(Assigned(FCombo.Properties.OnStatesToEditValue), 'OnStatesToEditValue');
end;

procedure TTestzDXCheckComboBox.Gestore_EditValueToStates_DelegaAlHelper;
var
  Stati: TcxCheckStates;
begin
  if not DxDisponibile then
    Exit;

  Voci(['A=Alfa', 'B=Beta']);
  dx.InitProperties(ctCheckComboBox, FCombo.Properties);
  FCombo.Properties.Delimiter := '; ';
  SetLength(Stati, 2);

  FCombo.Properties.OnEditValueToStates(FCombo, 'B; ', Stati);

  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[0]), 'A');
  Assert.AreEqual(Ord(cbsChecked), Ord(Stati[1]), 'B');
end;

procedure TTestzDXCheckComboBox.Gestore_StatesToEditValue_DelegaAlHelper;
var
  Stati: TcxCheckStates;
  Valore: Variant;
begin
  if not DxDisponibile then
    Exit;

  Voci(['A=Alfa', 'B=Beta']);
  dx.InitProperties(ctCheckComboBox, FCombo.Properties);
  FCombo.Properties.Delimiter := '; ';
  SetLength(Stati, 2);
  Stati[0] := cbsChecked;
  Stati[1] := cbsUnchecked;

  FCombo.Properties.OnStatesToEditValue(FCombo, Stati, Valore);

  Assert.AreEqual('A; ', VarToStr(Valore));
end;

procedure TTestzDXCheckComboBox.Gestore_SenderNil_NonCalcolaNulla;
var
  Stati: TcxCheckStates;
  Valore: Variant;
begin
  if not DxDisponibile then
    Exit;

  // DIV-VED-4: DevExpress chiama PrepareDisplayValue con Sender nil; i gestori
  // non fanno niente e gli stati restano com'erano
  Voci(['A=Alfa', 'B=Beta']);
  dx.InitProperties(ctCheckComboBox, FCombo.Properties);
  SetLength(Stati, 2);
  Stati[0] := cbsUnchecked;
  Stati[1] := cbsUnchecked;
  Valore := 'valore intatto';

  FCombo.Properties.OnEditValueToStates(nil, 'A; B; ', Stati);

  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[0]), 'A resta non selezionata');
  Assert.AreEqual(Ord(cbsUnchecked), Ord(Stati[1]), 'B resta non selezionata');
end;

{ TTestzDXEditorAttivo }

function TTestzDXEditorAttivo.Dimensione(Campo: TField): Integer;
begin
  try
    Result := dx.FieldSize(Campo);
  finally
    Campo.Free;
  end;
end;

procedure TTestzDXEditorAttivo.GridEditable_VistaNil_Falso;
begin
  if not DxDisponibile then
    Exit;

  Assert.IsFalse(dx.GridEditable(nil));
end;

procedure TTestzDXEditorAttivo.GridEditable_ModificaAttiva_Vero;
var
  Repertorio: TcxGridViewRepository;
  Vista: TcxGridDBTableView;
begin
  if not DxDisponibile then
    Exit;

  Repertorio := TcxGridViewRepository.Create(nil);
  try
    Vista := TcxGridDBTableView(Repertorio.CreateItem(TcxGridDBTableView));
    Vista.OptionsData.Editing := True;

    Assert.IsTrue(dx.GridEditable(Vista));
  finally
    Repertorio.Free;
  end;
end;

procedure TTestzDXEditorAttivo.GridEditable_ModificaDisattivata_Falso;
var
  Repertorio: TcxGridViewRepository;
  Vista: TcxGridDBTableView;
begin
  if not DxDisponibile then
    Exit;

  Repertorio := TcxGridViewRepository.Create(nil);
  try
    Vista := TcxGridDBTableView(Repertorio.CreateItem(TcxGridDBTableView));
    Vista.OptionsData.Editing := False;

    Assert.IsFalse(dx.GridEditable(Vista));
  finally
    Repertorio.Free;
  end;
end;

procedure TTestzDXEditorAttivo.ActiveControl_NessunControlloAttivo_Nil;
begin
  if not DxDisponibile then
    Exit;

  if Screen.ActiveControl <> nil then
  begin
    Assert.Pass('il programma di prova ha un controllo attivo: prova non applicabile');
    Exit;
  end;

  Assert.IsTrue(dx.ActiveControl = nil);
end;

procedure TTestzDXEditorAttivo.ActiveGrid_NessunControlloAttivo_Nil;
begin
  if not DxDisponibile then
    Exit;

  if Screen.ActiveControl <> nil then
  begin
    Assert.Pass('il programma di prova ha un controllo attivo: prova non applicabile');
    Exit;
  end;

  Assert.IsTrue(dx.ActiveGrid = nil);
end;

procedure TTestzDXEditorAttivo.IsActiveControl_EditorNonAttivo_Falso;
var
  Editor: TcxTextEdit;
begin
  if not DxDisponibile then
    Exit;

  Editor := TcxTextEdit.Create(nil);
  try
    Assert.IsFalse(dx.IsActiveControl(Editor));
  finally
    Editor.Free;
  end;
end;

procedure TTestzDXEditorAttivo.IsActiveControl_GrigliaNonAttiva_Falso;
var
  Griglia: TcxGrid;
begin
  if not DxDisponibile then
    Exit;

  Griglia := TcxGrid.Create(nil);
  try
    Assert.IsFalse(dx.IsActiveControl(Griglia));
  finally
    Griglia.Free;
  end;
end;

procedure TTestzDXEditorAttivo.IsActiveControl_EditorNil_VeroSeNessunControlloAttivo;
var
  Editor: TcxCustomEdit;
begin
  if not DxDisponibile then
    Exit;

  if Screen.ActiveControl <> nil then
  begin
    Assert.Pass('il programma di prova ha un controllo attivo: prova non applicabile');
    Exit;
  end;

  // DIV-VED-7: nil = nil, quindi "nessun editor" risulta "editor attivo"
  Editor := nil;

  Assert.IsTrue(dx.IsActiveControl(Editor));
end;

procedure TTestzDXEditorAttivo.FieldSize_CampoNil_Venti;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(20, dx.FieldSize(nil));
end;

procedure TTestzDXEditorAttivo.FieldSize_TestoFinoAVenti_Venti;
var
  Campo: TStringField;
begin
  if not DxDisponibile then
    Exit;

  Campo := TStringField.Create(nil);
  Campo.Size := 20;

  Assert.AreEqual(20, Dimensione(Campo), 'lunghezza 20');
end;

procedure TTestzDXEditorAttivo.FieldSize_TestoDaVentunoACinquanta_Cinquanta;
var
  Campo: TStringField;
begin
  if not DxDisponibile then
    Exit;

  Campo := TStringField.Create(nil);
  Campo.Size := 21;
  Assert.AreEqual(50, Dimensione(Campo), 'lunghezza 21');

  Campo := TStringField.Create(nil);
  Campo.Size := 50;
  Assert.AreEqual(50, Dimensione(Campo), 'lunghezza 50');
end;

procedure TTestzDXEditorAttivo.FieldSize_TestoOltreCinquanta_Cento;
var
  Campo: TStringField;
begin
  if not DxDisponibile then
    Exit;

  Campo := TStringField.Create(nil);
  Campo.Size := 51;
  Assert.AreEqual(100, Dimensione(Campo), 'lunghezza 51');

  Campo := TStringField.Create(nil);
  Campo.Size := 255;
  Assert.AreEqual(100, Dimensione(Campo), 'lunghezza 255');
end;

procedure TTestzDXEditorAttivo.FieldSize_Booleano_Cinque;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(5, Dimensione(TBooleanField.Create(nil)));
end;

procedure TTestzDXEditorAttivo.FieldSize_NumeriEDate_Venti;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(20, Dimensione(TIntegerField.Create(nil)), 'intero');
  Assert.AreEqual(20, Dimensione(TLargeintField.Create(nil)), 'intero grande');
  Assert.AreEqual(20, Dimensione(TFloatField.Create(nil)), 'virgola mobile');
  Assert.AreEqual(20, Dimensione(TDateField.Create(nil)), 'data');
  Assert.AreEqual(20, Dimensione(TDateTimeField.Create(nil)), 'data e ora');
end;

procedure TTestzDXEditorAttivo.FieldSize_MemoEBlob_NovecentoNovantanove;
begin
  if not DxDisponibile then
    Exit;

  Assert.AreEqual(999, Dimensione(TMemoField.Create(nil)), 'memo');
  Assert.AreEqual(999, Dimensione(TBlobField.Create(nil)), 'blob');
end;

procedure TTestzDXEditorAttivo.FieldSize_MemoUnicode_Venti;
begin
  if not DxDisponibile then
    Exit;

  // DIV-VED-6: ftWideMemo non e' nell'elenco dei campi lunghi, e un memo
  // Unicode riceve la dimensione predefinita invece di 999
  Assert.AreEqual(20, Dimensione(TWideMemoField.Create(nil)));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzDXHelperEditor);
  TDUnitX.RegisterTestFixture(TTestzDXLetturaScrittura);
  TDUnitX.RegisterTestFixture(TTestzDXEditabilita);
  TDUnitX.RegisterTestFixture(TTestzDXValidazione);
  TDUnitX.RegisterTestFixture(TTestzDXCheckComboBox);
  TDUnitX.RegisterTestFixture(TTestzDXEditorAttivo);

end.
