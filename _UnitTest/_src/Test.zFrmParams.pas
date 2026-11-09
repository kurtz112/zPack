// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit Test.zFrmParams;

// Test DUnitX per zBase\zFrmParams.pas (specifica ZBASE-PAR, "Dialogo dei
// parametri.md"). BOZZA scritta senza poterla compilare ne' eseguire.
//
// COME SI RAGGIUNGONO GLI EDITOR SENZA APRIRE LA FINESTRA MODALE
// ParamCaption, CreateEditor, CreateEditors e SaveParamValues sono privati e non
// si chiamano dal test. Ma Execute chiama BeforeShowParamsProc dopo aver
// costruito gli editor e prima di zDialog.Execute (cioe' prima di ShowModal):
// le prove passano da li' con una procedura che ispeziona il dialogo
// (GetEditor, Enum, zDialog.zFormBuilder) e poi solleva EInterruzioneProva, che
// esce da ShowParams senza mai mostrare la finestra. L'etichetta di un
// parametro si legge dall'elemento di layout dell'editor.
//
// Ogni prova usa un dialogo nuovo e chiama ShowParams una sola volta: costruire
// gli editor due volte sullo stesso dialogo passa da TzFormBuilder.Clear con
// editor presenti, che libera due volte i controlli (DIV-FRB-1 di ZBASE-FRB).
//
// Si provano: le due forme per TParams e TFDParams, il caso senza parametri
// (ritorna True senza finestra, anche con le funzioni libere), quali parametri
// compaiono, le etichette, il tipo di editor, i valori iniziali, GetEditor, Enum,
// ChangeEditorType, il fatto che i parametri del chiamante non cambiano prima
// della conferma e i valori iniziali della finestra interna.
//
// Restano senza prova: ShowModal, conferma e annullamento, il ritorno dei valori
// nei parametri (SaveParamValues e SaveParams, che si eseguono solo dopo mrOk),
// i quattro overload che richiedono un dataset o una procedura preparati
// (TzFbDataSet, TFDQuery, TFDStoredProc, TzStoredProc: servono database, Prepare,
// Base.QueryParams), la posizione salvata nel file .Dlgs e la conferma di
// TzStoredProc.ApplyInternalStoredProcParams. Si collaudano con la sonda zapp sul
// banco.
//
// DIPENDENZE: TzParamDialog.Create crea un TzDialog (TdxRibbonForm con DFM) che
// nel costruttore e nel DFM passa dal modulo globale dx (zDX): la prima prova
// crea quel modulo con tutti i suoi stili. Se in un programma di prova senza
// la sua inizializzazione il modulo non si crea, tutte le prove di questa unit
// falliscono in Setup. Le funzioni libere usano Application.CreateForm con una
// classe che non e' una form.
//
// Le prove "Divergenza_DIV_PAR_n_*" fotografano il comportamento attuale: vanno
// capovolte quando il codice viene corretto.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  FireDAC.Stan.Param,
  Vcl.Forms,
  cxEdit,
  cxTextEdit,
  cxSpinEdit,
  cxCheckBox,
  cxCalendar,
  cxTimeEdit,
  cxMemo,
  dxLayoutContainer,
  dxLayoutControl,
  DUnitX.TestFramework,
  zBaseLib,
  zFormBuilder,
  zDialog,
  zFrmParams;

type
  // interrompe ShowParams dentro BeforeShowParamsProc, prima della finestra
  EInterruzioneProva = class(Exception);

  TIspettore = reference to procedure(ParamDialog: TzParamDialog);

  [TestFixture]
  TTestzFrmParams = class
  private
    FDialogo: TzParamDialog;
    FParametri: TParams;
    function NuovoParametro(Parametri: TParams; const Nome: string; Tipo: TFieldType;
      Direzione: Data.DB.TParamType = Data.DB.TParamType.ptInput): TParam;
    // chiama ShowParams e si ferma dentro BeforeShowParamsProc, dopo l'ispezione
    procedure Ispeziona(Dialogo: TzParamDialog; Parametri: TParams; const Nascosti: string;
      const IncludiUscita: Boolean; Ispettore: TIspettore);
    function EtichettaDi(const Nome: string): string;
    function EtichettaDellEditor(ParamDialog: TzParamDialog; const Nome: string): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-PAR-001
    [Test]
    procedure Creazione_FinestraInternaAssegnataENessunEditor;
    // ZBASE-PAR-009
    [Test]
    procedure FinestraInterna_ValoriIniziali_InvioComeTabEPulsantiPredefiniti;

    // ZBASE-PAR-004
    [Test]
    procedure SenzaParametri_RestituisceTrueSenzaPassareDallaPersonalizzazione;
    // ZBASE-PAR-003 e ZBASE-PAR-004
    [Test]
    procedure TuttiNascosti_RestituisceTrueSenzaPassareDallaPersonalizzazione;
    // ZBASE-PAR-002 e ZBASE-PAR-004
    [Test]
    procedure FunzioneLibera_SenzaParametri_RestituisceTrue;
    // ZBASE-PAR-002 e ZBASE-PAR-003
    [Test]
    procedure FunzioneLibera_ConTParams_InoltraHideParams;
    // DIV-PAR-12 (ZBASE-PAR-003)
    [Test]
    procedure Divergenza_DIV_PAR_12_SoliParametriDiUscita_NienteFinestra;

    // ZBASE-PAR-003
    [Test]
    procedure Nascosti_UnNome_NonHaEditorGliAltriSi;
    // ZBASE-PAR-003
    [Test]
    procedure Nascosti_VirgolaEPuntoEVirgola_TuttiEsclusi;
    // ZBASE-PAR-003
    [Test]
    procedure Nascosti_MaiuscoleEMinuscole_NonContano;
    // ZBASE-PAR-003
    [Test]
    procedure Uscita_SenzaInclusione_NonCompare;
    // ZBASE-PAR-003 e ZBASE-PAR-006
    [Test]
    procedure Uscita_ConInclusione_CompareInSolaLettura;

    // ZBASE-PAR-005
    [Test]
    procedure Etichetta_PrefissoPARAM_VieneTolto;
    // ZBASE-PAR-005
    [Test]
    procedure Etichetta_NomeMaiuscoloConSottolineature_InizialiMaiuscole;
    // ZBASE-PAR-005
    [Test]
    procedure Etichetta_NomeConIniziali_SottolineatureDiventanoSpazi;
    // ZBASE-PAR-005
    [Test]
    procedure Etichetta_NomeTuttoMaiuscolo_PrimaMaiuscolaERestoMinuscolo;
    // DIV-PAR-5 (ZBASE-PAR-005)
    [Test]
    procedure Divergenza_DIV_PAR_5_NomeInMaiuscoleInterne_NonInserisceLoSpazio;

    // ZBASE-PAR-006
    [Test]
    procedure Tipi_Testo_StringaEParametroSconosciuto;
    // ZBASE-PAR-006
    [Test]
    procedure Tipi_Interi_SpinConValoriInteri;
    // ZBASE-PAR-006
    [Test]
    procedure Tipi_Decimali_SpinConValoriDecimali;
    // ZBASE-PAR-006
    [Test]
    procedure Tipi_BooleanoDataOraMemo_EditorDedicati;
    // DIV-PAR-6 (ZBASE-PAR-006)
    [Test]
    procedure Divergenza_DIV_PAR_6_TipiNonMappati_CasellaDiTesto;
    // ZBASE-PAR-006
    [Test]
    procedure ValoreIniziale_VieneMostratoNegliEditor;
    // ZBASE-PAR-006
    [Test]
    procedure ValoreIniziale_SpinNullo_ResteNullo;
    // ZBASE-PAR-006
    [Test]
    procedure IngressoPresente_NonInSolaLettura;

    // ZBASE-PAR-007
    [Test]
    procedure PersonalizzazioneChiamataUnaVolta_ConDialogoEdEditorGiaCreati;
    // ZBASE-PAR-007
    [Test]
    procedure GetEditor_NonDistingueMaiuscole_NomeInesistenteDaNil;
    // ZBASE-PAR-007
    [Test]
    procedure Enum_VisitaIParametriMostratiConIlLoroEditor;
    // ZBASE-PAR-007
    [Test]
    procedure ChangeEditorType_SostituisceEditorEMantieneEtichetta;
    // DIV-PAR-4 (ZBASE-PAR-007)
    [Test]
    procedure Divergenza_DIV_PAR_4_ChangeEditorType_NomeInesistenteSolleva;
    // DIV-PAR-9 (ZBASE-PAR-007)
    [Test]
    procedure Divergenza_DIV_PAR_9_ChangeEditorType_PerdeLaSolaLettura;

    // ZBASE-PAR-008
    [Test]
    procedure Interruzione_NonModificaIParametriDelChiamante;
    // DIV-PAR-3 (ZBASE-PAR-006)
    [Test]
    procedure Divergenza_DIV_PAR_3_FireDAC_UscitaNonInSolaLettura;
  end;

implementation

uses
  zDX;

// TTestzFrmParams

procedure TTestzFrmParams.Setup;
begin
  FDialogo := TzParamDialog.Create(nil);
  FParametri := TParams.Create(nil);
end;

procedure TTestzFrmParams.TearDown;
begin
  FreeAndNil(FParametri);
  FreeAndNil(FDialogo);
end;

function TTestzFrmParams.NuovoParametro(Parametri: TParams; const Nome: string; Tipo: TFieldType;
  Direzione: Data.DB.TParamType): TParam;
begin
  Result := Parametri.CreateParam(Tipo, Nome, Direzione);
end;

procedure TTestzFrmParams.Ispeziona(Dialogo: TzParamDialog; Parametri: TParams; const Nascosti: string;
  const IncludiUscita: Boolean; Ispettore: TIspettore);
var
  Interrotto: Boolean;
begin
  Interrotto := False;

  try
    Dialogo.ShowParams('Prova', Parametri, 'Titolo',
      procedure(ParamDialog: TzParamDialog)
      begin
        Ispettore(ParamDialog);
        raise EInterruzioneProva.Create('interruzione di prova prima della finestra modale');
      end, IncludiUscita, Nascosti);
  except
    on EInterruzioneProva do
      Interrotto := True;
  end;

  Assert.IsTrue(Interrotto, 'il dialogo doveva fermarsi dentro la procedura di personalizzazione');
end;

function TTestzFrmParams.EtichettaDellEditor(ParamDialog: TzParamDialog; const Nome: string): string;
var
  Elemento: TdxCustomLayoutItem;
begin
  Elemento := ParamDialog.zDialog.zFormBuilder.LayoutItemByControl(ParamDialog.GetEditor(Nome));
  Result := (Elemento as TdxLayoutItem).Caption;
end;

function TTestzFrmParams.EtichettaDi(const Nome: string): string;
var
  Dialogo: TzParamDialog;
  Parametri: TParams;
  Etichetta: string;
begin
  Etichetta := '';
  Dialogo := TzParamDialog.Create(nil);
  Parametri := TParams.Create(nil);
  try
    NuovoParametro(Parametri, Nome, ftString);

    Ispeziona(Dialogo, Parametri, '', False,
      procedure(ParamDialog: TzParamDialog)
      begin
        Etichetta := EtichettaDellEditor(ParamDialog, Nome);
      end);
  finally
    FreeAndNil(Parametri);
    FreeAndNil(Dialogo);
  end;

  Result := Etichetta;
end;

// ZBASE-PAR-001

procedure TTestzFrmParams.Creazione_FinestraInternaAssegnataENessunEditor;
begin
  Assert.IsTrue(Assigned(FDialogo.zDialog), 'zDialog');
  Assert.IsTrue(FDialogo.GetEditor('QUALSIASI') = nil, 'nessun editor prima di ShowParams');
end;

// ZBASE-PAR-009

procedure TTestzFrmParams.FinestraInterna_ValoriIniziali_InvioComeTabEPulsantiPredefiniti;
begin
  Assert.IsTrue(FDialogo.zDialog.EnterAsTab, 'EnterAsTab');
  // DefaultOk e DefaultCancel vengono dal DFM di TzDialog
  Assert.IsTrue(FDialogo.zDialog.OkCancel.OkBtn.Default, 'Ok predefinito');
  Assert.IsTrue(FDialogo.zDialog.OkCancel.CancelBtn.Cancel, 'Annulla risponde a Esc');
  Assert.AreEqual('', FDialogo.zDialog.zFormBuilder.LayoutID, 'LayoutID');
end;

// ZBASE-PAR-004

procedure TTestzFrmParams.SenzaParametri_RestituisceTrueSenzaPassareDallaPersonalizzazione;
var
  Chiamata: Boolean;
  Risultato: Boolean;
begin
  Chiamata := False;

  Risultato := FDialogo.ShowParams('Prova', FParametri, 'Titolo',
    procedure(ParamDialog: TzParamDialog)
    begin
      Chiamata := True;
    end, False, '');

  Assert.IsTrue(Risultato, 'risultato');
  Assert.IsFalse(Chiamata, 'BeforeShowParamsProc non va chiamata');
end;

// ZBASE-PAR-003 e ZBASE-PAR-004

procedure TTestzFrmParams.TuttiNascosti_RestituisceTrueSenzaPassareDallaPersonalizzazione;
var
  Chiamata: Boolean;
  Risultato: Boolean;
begin
  NuovoParametro(FParametri, 'P1', ftString);
  NuovoParametro(FParametri, 'P2', ftInteger);
  Chiamata := False;

  Risultato := FDialogo.ShowParams('Prova', FParametri, 'Titolo',
    procedure(ParamDialog: TzParamDialog)
    begin
      Chiamata := True;
    end, False, 'P1;P2');

  Assert.IsTrue(Risultato, 'risultato');
  Assert.IsFalse(Chiamata, 'BeforeShowParamsProc non va chiamata');
end;

// ZBASE-PAR-002 e ZBASE-PAR-004

procedure TTestzFrmParams.FunzioneLibera_SenzaParametri_RestituisceTrue;
begin
  // la funzione libera crea un dialogo con Application.CreateForm e lo libera
  Assert.IsTrue(zFrmParams.ShowParams('Prova', FParametri), 'risultato');
end;

// ZBASE-PAR-002 e ZBASE-PAR-003

procedure TTestzFrmParams.FunzioneLibera_ConTParams_InoltraHideParams;
begin
  NuovoParametro(FParametri, 'P1', ftString);
  NuovoParametro(FParametri, 'P2', ftInteger);

  // tutti nascosti: se HideParams non fosse inoltrato comparirebbe la finestra
  // modale. Per TParams la funzione libera lo inoltra (per le altre quattro
  // forme no: DIV-PAR-1, non provabile qui)
  Assert.IsTrue(zFrmParams.ShowParams('Prova', FParametri, 'Titolo', nil, False, 'P1,P2'), 'risultato');
end;

// DIV-PAR-12

procedure TTestzFrmParams.Divergenza_DIV_PAR_12_SoliParametriDiUscita_NienteFinestra;
var
  Chiamata: Boolean;
  Risultato: Boolean;
begin
  // come resultParams di dmFattureElettroniche: tutti ptOutput
  NuovoParametro(FParametri, 'Numero_Documenti', ftInteger, Data.DB.TParamType.ptOutput);
  NuovoParametro(FParametri, 'Imposta_di_Bollo', ftCurrency, Data.DB.TParamType.ptOutput);
  Chiamata := False;

  // senza IncludeOutputParams: nessun parametro da chiedere, True senza finestra
  // (e' il motivo per cui il chiamante ora passa IncludeOutputParams = True)
  Risultato := FDialogo.ShowParams('Prova_result', FParametri, 'Risultati',
    procedure(ParamDialog: TzParamDialog)
    begin
      Chiamata := True;
    end, False, '');

  Assert.IsTrue(Risultato, 'DIV-PAR-12: risultato True');
  Assert.IsFalse(Chiamata, 'DIV-PAR-12: nessun editor, nessuna finestra');

  // la conferma ha sostituito la lista del chiamante con quella interna, vuota
  // (DIV-PAR-2): si ricrea
  FParametri.Clear;
  NuovoParametro(FParametri, 'Numero_Documenti', ftInteger, Data.DB.TParamType.ptOutput);
  NuovoParametro(FParametri, 'Imposta_di_Bollo', ftCurrency, Data.DB.TParamType.ptOutput);

  // come il chiamante corretto: con IncludeOutputParams i due editor ci sono
  Ispeziona(FDialogo, FParametri, '', True,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('Numero_Documenti') <> nil, 'DIV-PAR-12: editor Numero_Documenti');
      Assert.IsTrue(ParamDialog.GetEditor('Imposta_di_Bollo') <> nil, 'DIV-PAR-12: editor Imposta_di_Bollo');
    end);
end;

// ZBASE-PAR-003

procedure TTestzFrmParams.Nascosti_UnNome_NonHaEditorGliAltriSi;
begin
  NuovoParametro(FParametri, 'DATA_INIZIO', ftDate);
  NuovoParametro(FParametri, 'DATA_FINE', ftDate);
  NuovoParametro(FParametri, 'NASCOSTO', ftInteger);

  Ispeziona(FDialogo, FParametri, 'NASCOSTO', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('DATA_INIZIO') <> nil, 'DATA_INIZIO');
      Assert.IsTrue(ParamDialog.GetEditor('DATA_FINE') <> nil, 'DATA_FINE');
      Assert.IsTrue(ParamDialog.GetEditor('NASCOSTO') = nil, 'NASCOSTO non ha editor');
    end);

  // il parametro nascosto resta nella lista del chiamante
  Assert.AreEqual(3, FParametri.Count, 'parametri del chiamante');
end;

procedure TTestzFrmParams.Nascosti_VirgolaEPuntoEVirgola_TuttiEsclusi;
begin
  NuovoParametro(FParametri, 'A', ftString);
  NuovoParametro(FParametri, 'B', ftString);
  NuovoParametro(FParametri, 'C', ftString);
  NuovoParametro(FParametri, 'D', ftString);

  Ispeziona(FDialogo, FParametri, 'A,B;C', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('A') = nil, 'A');
      Assert.IsTrue(ParamDialog.GetEditor('B') = nil, 'B');
      Assert.IsTrue(ParamDialog.GetEditor('C') = nil, 'C');
      Assert.IsTrue(ParamDialog.GetEditor('D') <> nil, 'D resta');
    end);
end;

procedure TTestzFrmParams.Nascosti_MaiuscoleEMinuscole_NonContano;
begin
  NuovoParametro(FParametri, 'NASCOSTO', ftString);
  NuovoParametro(FParametri, 'VISIBILE', ftString);

  Ispeziona(FDialogo, FParametri, 'nascosto', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('NASCOSTO') = nil, 'NASCOSTO');
      Assert.IsTrue(ParamDialog.GetEditor('VISIBILE') <> nil, 'VISIBILE');
    end);
end;

procedure TTestzFrmParams.Uscita_SenzaInclusione_NonCompare;
begin
  NuovoParametro(FParametri, 'INGRESSO', ftString);
  NuovoParametro(FParametri, 'RISULTATO', ftString, Data.DB.TParamType.ptOutput);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('INGRESSO') <> nil, 'INGRESSO');
      Assert.IsTrue(ParamDialog.GetEditor('RISULTATO') = nil, 'RISULTATO non compare');
    end);
end;

procedure TTestzFrmParams.Uscita_ConInclusione_CompareInSolaLettura;
begin
  NuovoParametro(FParametri, 'INGRESSO', ftString);
  NuovoParametro(FParametri, 'RISULTATO', ftString, Data.DB.TParamType.ptOutput);

  Ispeziona(FDialogo, FParametri, '', True,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('INGRESSO') <> nil, 'INGRESSO');
      Assert.IsTrue(ParamDialog.GetEditor('RISULTATO') <> nil, 'RISULTATO compare');
      Assert.IsTrue(ParamDialog.GetEditor('RISULTATO').ActiveProperties.ReadOnly, 'RISULTATO in sola lettura');
      Assert.IsFalse(ParamDialog.GetEditor('INGRESSO').ActiveProperties.ReadOnly, 'INGRESSO modificabile');
    end);
end;

// ZBASE-PAR-005

procedure TTestzFrmParams.Etichetta_PrefissoPARAM_VieneTolto;
begin
  Assert.AreEqual('Data Inizio', EtichettaDi('PARAM_DATA_INIZIO'));
end;

procedure TTestzFrmParams.Etichetta_NomeMaiuscoloConSottolineature_InizialiMaiuscole;
begin
  Assert.AreEqual('Costo Orario', EtichettaDi('COSTO_ORARIO'));
end;

procedure TTestzFrmParams.Etichetta_NomeConIniziali_SottolineatureDiventanoSpazi;
begin
  Assert.AreEqual('Data Evasione', EtichettaDi('Data_Evasione'));
end;

procedure TTestzFrmParams.Etichetta_NomeTuttoMaiuscolo_PrimaMaiuscolaERestoMinuscolo;
begin
  Assert.AreEqual('Id Incarico', EtichettaDi('ID_INCARICO'));
end;

procedure TTestzFrmParams.Divergenza_DIV_PAR_5_NomeInMaiuscoleInterne_NonInserisceLoSpazio;
begin
  // fotografia del comportamento attuale: InserisciSpazioTraMaiuscole non
  // cambia mai il testo, perche' zzCapFirst ha gia' messo in minuscolo le
  // lettere interne. Da capovolgere ('Data Fine') quando il codice sara' corretto.
  Assert.AreEqual('Datafine', EtichettaDi('DataFine'), 'DIV-PAR-5');
end;

// ZBASE-PAR-006

procedure TTestzFrmParams.Tipi_Testo_StringaEParametroSconosciuto;
begin
  NuovoParametro(FParametri, 'TESTO', ftString);
  NuovoParametro(FParametri, 'LARGO', ftWideString);
  NuovoParametro(FParametri, 'SCONOSCIUTO', ftUnknown);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('TESTO').ClassType = TcxTextEdit, 'ftString');
      Assert.IsTrue(ParamDialog.GetEditor('LARGO').ClassType = TcxTextEdit, 'ftWideString');
      Assert.IsTrue(ParamDialog.GetEditor('SCONOSCIUTO').ClassType = TcxTextEdit, 'ftUnknown');
    end);
end;

procedure TTestzFrmParams.Tipi_Interi_SpinConValoriInteri;
begin
  NuovoParametro(FParametri, 'PICCOLO', ftSmallint);
  NuovoParametro(FParametri, 'NUMERO', ftInteger);
  NuovoParametro(FParametri, 'GRANDE', ftLargeint);
  NuovoParametro(FParametri, 'SENZASEGNO', ftWord);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    var
      Nome: string;
    begin
      for Nome in ['PICCOLO', 'NUMERO', 'GRANDE', 'SENZASEGNO'] do
      begin
        Assert.IsTrue(ParamDialog.GetEditor(Nome).ClassType = TcxSpinEdit, Nome + ': classe');
        Assert.IsFalse(TcxSpinEdit(ParamDialog.GetEditor(Nome)).Properties.ValueType = vtFloat, Nome + ': valori interi');
        Assert.IsTrue(TcxSpinEdit(ParamDialog.GetEditor(Nome)).Properties.UseNullString, Nome + ': UseNullString');
      end;
    end);
end;

procedure TTestzFrmParams.Tipi_Decimali_SpinConValoriDecimali;
begin
  NuovoParametro(FParametri, 'VIRGOLA', ftFloat);
  NuovoParametro(FParametri, 'IMPORTO', ftCurrency);
  NuovoParametro(FParametri, 'DECIMALE', ftBCD);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    var
      Nome: string;
    begin
      for Nome in ['VIRGOLA', 'IMPORTO', 'DECIMALE'] do
      begin
        Assert.IsTrue(ParamDialog.GetEditor(Nome).ClassType = TcxSpinEdit, Nome + ': classe');
        Assert.IsTrue(TcxSpinEdit(ParamDialog.GetEditor(Nome)).Properties.ValueType = vtFloat, Nome + ': vtFloat');
        Assert.IsTrue(TcxSpinEdit(ParamDialog.GetEditor(Nome)).Properties.UseNullString, Nome + ': UseNullString');
      end;
    end);
end;

procedure TTestzFrmParams.Tipi_BooleanoDataOraMemo_EditorDedicati;
begin
  NuovoParametro(FParametri, 'ATTIVO', ftBoolean);
  NuovoParametro(FParametri, 'DAL', ftDate);
  NuovoParametro(FParametri, 'ALLE', ftTime);
  NuovoParametro(FParametri, 'QUANDO', ftDateTime);
  NuovoParametro(FParametri, 'NOTE', ftMemo);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('ATTIVO').ClassType = TcxCheckBox, 'ftBoolean');
      Assert.IsTrue(ParamDialog.GetEditor('DAL').ClassType = TcxDateEdit, 'ftDate');
      Assert.IsTrue(ParamDialog.GetEditor('ALLE').ClassType = TcxTimeEdit, 'ftTime');
      Assert.IsTrue(ParamDialog.GetEditor('QUANDO').ClassType = TcxDateEdit, 'ftDateTime');
      Assert.IsTrue(ParamDialog.GetEditor('NOTE').ClassType = TcxMemo, 'ftMemo');
    end);
end;

procedure TTestzFrmParams.Divergenza_DIV_PAR_6_TipiNonMappati_CasellaDiTesto;
begin
  NuovoParametro(FParametri, 'SINGOLO', ftSingle);
  NuovoParametro(FParametri, 'NUMERICO', ftFMTBcd);
  NuovoParametro(FParametri, 'MEMOLARGO', ftWideMemo);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      // fotografia del comportamento attuale: nessuno di questi tipi e' mappato
      // in GetCtrlType, quindi ctDefault, cioe' TcxTextEdit
      Assert.IsTrue(ParamDialog.GetEditor('SINGOLO').ClassType = TcxTextEdit, 'DIV-PAR-6: ftSingle');
      Assert.IsTrue(ParamDialog.GetEditor('NUMERICO').ClassType = TcxTextEdit, 'DIV-PAR-6: ftFMTBcd');
      Assert.IsTrue(ParamDialog.GetEditor('MEMOLARGO').ClassType = TcxTextEdit, 'DIV-PAR-6: ftWideMemo');
    end);
end;

procedure TTestzFrmParams.ValoreIniziale_VieneMostratoNegliEditor;
begin
  NuovoParametro(FParametri, 'NUMERO', ftInteger).AsInteger := 42;
  NuovoParametro(FParametri, 'NOME', ftString).AsString := 'Mario';

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.AreEqual(42, Integer(ParamDialog.GetEditor('NUMERO').EditValue), 'NUMERO');
      Assert.AreEqual('Mario', VarToStr(ParamDialog.GetEditor('NOME').EditValue), 'NOME');
    end);
end;

procedure TTestzFrmParams.ValoreIniziale_SpinNullo_ResteNullo;
begin
  NuovoParametro(FParametri, 'VUOTO', ftInteger);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      // dx.GetValue e' quello che usa SaveParamValues: uno spin vuoto da' nullo,
      // non 0
      Assert.IsTrue(VarIsNull(dx.GetValue(ParamDialog.GetEditor('VUOTO'))), 'VUOTO');
    end);
end;

procedure TTestzFrmParams.IngressoPresente_NonInSolaLettura;
begin
  NuovoParametro(FParametri, 'INGRESSO', ftString);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsFalse(ParamDialog.GetEditor('INGRESSO').ActiveProperties.ReadOnly);
    end);
end;

// ZBASE-PAR-007

procedure TTestzFrmParams.PersonalizzazioneChiamataUnaVolta_ConDialogoEdEditorGiaCreati;
var
  Chiamate: Integer;
begin
  NuovoParametro(FParametri, 'NUMERO', ftInteger);
  Chiamate := 0;

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Inc(Chiamate);
      Assert.IsTrue(ParamDialog = FDialogo, 'riceve il dialogo stesso');
      Assert.IsTrue(ParamDialog.GetEditor('NUMERO') <> nil, 'gli editor ci sono gia''');
    end);

  Assert.AreEqual(1, Chiamate, 'numero di chiamate');
end;

procedure TTestzFrmParams.GetEditor_NonDistingueMaiuscole_NomeInesistenteDaNil;
begin
  NuovoParametro(FParametri, 'NUMERO', ftInteger);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      Assert.IsTrue(ParamDialog.GetEditor('numero') <> nil, 'minuscolo');
      Assert.IsTrue(ParamDialog.GetEditor('INESISTENTE') = nil, 'nome inesistente');
    end);
end;

procedure TTestzFrmParams.Enum_VisitaIParametriMostratiConIlLoroEditor;
begin
  NuovoParametro(FParametri, 'A', ftString);
  NuovoParametro(FParametri, 'B', ftString);
  NuovoParametro(FParametri, 'C', ftString);

  Ispeziona(FDialogo, FParametri, 'B', False,
    procedure(ParamDialog: TzParamDialog)
    var
      Nomi: string;
    begin
      Nomi := '';

      ParamDialog.Enum(
        procedure(Parametro: TParam; Editor: TcxCustomEdit)
        begin
          Assert.IsTrue(Editor = ParamDialog.GetEditor(Parametro.Name), 'editor di ' + Parametro.Name);
          Nomi := Nomi + Parametro.Name + ';';
        end);

      // B e' nascosto: non e' nell'elenco interno
      Assert.AreEqual('A;C;', Nomi, 'ordine e parametri visitati');
    end);
end;

procedure TTestzFrmParams.ChangeEditorType_SostituisceEditorEMantieneEtichetta;
begin
  NuovoParametro(FParametri, 'ANNO', ftString);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    var
      Nuovo: TcxCustomEdit;
    begin
      Assert.IsTrue(ParamDialog.GetEditor('ANNO').ClassType = TcxTextEdit, 'prima: testo');

      Nuovo := ParamDialog.ChangeEditorType('ANNO', ctSpin);

      Assert.IsTrue(Nuovo.ClassType = TcxSpinEdit, 'classe del nuovo editor');
      Assert.IsTrue(ParamDialog.GetEditor('ANNO') = Nuovo, 'GetEditor restituisce il nuovo editor');
      Assert.AreEqual('Anno', EtichettaDellEditor(ParamDialog, 'ANNO'), 'etichetta mantenuta');
    end);
end;

procedure TTestzFrmParams.Divergenza_DIV_PAR_4_ChangeEditorType_NomeInesistenteSolleva;
begin
  NuovoParametro(FParametri, 'ANNO', ftString);

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      // fotografia del comportamento attuale: TParams.ParamByName solleva e il
      // controllo Assigned non scatta mai. Da capovolgere (nil) quando il codice
      // sara' corretto.
      Assert.WillRaise(
        procedure
        begin
          ParamDialog.ChangeEditorType('INESISTENTE', ctSpin);
        end, EDatabaseError, 'DIV-PAR-4');
    end);
end;

procedure TTestzFrmParams.Divergenza_DIV_PAR_9_ChangeEditorType_PerdeLaSolaLettura;
begin
  NuovoParametro(FParametri, 'RISULTATO', ftString, Data.DB.TParamType.ptOutput);

  Ispeziona(FDialogo, FParametri, '', True,
    procedure(ParamDialog: TzParamDialog)
    var
      Nuovo: TcxCustomEdit;
    begin
      Assert.IsTrue(ParamDialog.GetEditor('RISULTATO').ActiveProperties.ReadOnly, 'prima: sola lettura');

      Nuovo := ParamDialog.ChangeEditorType('RISULTATO', ctEdit);

      // fotografia del comportamento attuale: il nuovo editor e' creato dal
      // costruttore di form senza ripetere la sola lettura. Da capovolgere
      // (IsTrue) quando il codice sara' corretto.
      Assert.IsFalse(Nuovo.ActiveProperties.ReadOnly, 'DIV-PAR-9: dopo');
    end);
end;

// ZBASE-PAR-008

procedure TTestzFrmParams.Interruzione_NonModificaIParametriDelChiamante;
begin
  NuovoParametro(FParametri, 'NUMERO', ftInteger).AsInteger := 7;
  NuovoParametro(FParametri, 'ALTRO', ftString).AsString := 'abc';

  Ispeziona(FDialogo, FParametri, '', False,
    procedure(ParamDialog: TzParamDialog)
    begin
      // l'utente "cambia" i valori nella finestra: non e' una conferma
      ParamDialog.GetEditor('NUMERO').EditValue := 99;
      ParamDialog.GetEditor('ALTRO').EditValue := 'xyz';
    end);

  Assert.AreEqual(7, FParametri.ParamByName('NUMERO').AsInteger, 'NUMERO');
  Assert.AreEqual('abc', FParametri.ParamByName('ALTRO').AsString, 'ALTRO');
  Assert.AreEqual(2, FParametri.Count, 'numero di parametri');
end;

// DIV-PAR-3

procedure TTestzFrmParams.Divergenza_DIV_PAR_3_FireDAC_UscitaNonInSolaLettura;
var
  Elenco: TFDParams;
  Parametro: TFDParam;
  Interrotto: Boolean;
begin
  Elenco := TFDParams.Create;
  try
    Parametro := TFDParam(Elenco.Add);
    Parametro.Name := 'RISULTATO';
    Parametro.DataType := ftString;
    Parametro.ParamType := Data.DB.TParamType.ptOutput;

    Interrotto := False;
    try
      FDialogo.ShowParams('Prova', Elenco, 'Titolo',
        procedure(ParamDialog: TzParamDialog)
        begin
          // fotografia del comportamento attuale: LoadParams(TFDParams) porta il
          // parametro nell'elenco interno come ptInputOutput, quindi l'editor non
          // e' in sola lettura. Da capovolgere (IsTrue) quando il codice sara'
          // corretto.
          Assert.IsFalse(ParamDialog.GetEditor('RISULTATO').ActiveProperties.ReadOnly, 'DIV-PAR-3');
          raise EInterruzioneProva.Create('interruzione di prova prima della finestra modale');
        end, True, '');
    except
      on EInterruzioneProva do
        Interrotto := True;
    end;

    Assert.IsTrue(Interrotto, 'il dialogo doveva fermarsi dentro la procedura di personalizzazione');
  finally
    FreeAndNil(Elenco);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestzFrmParams);

end.
