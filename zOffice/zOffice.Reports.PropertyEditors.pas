// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-02
// ---------------------------------------------------------------------------
unit zOffice.Reports.PropertyEditors;

// Editor a tendina per Profilo/TipologiaDocumentale di TzReportProprieta
// (zOffice.Reports.Proprieta): interrogano dal vivo i cataloghi
// OBJ_FILES_PROFILI_DOCUMENTALI / OBJ_FILES_TIPOLOGIE_DOCUMENTALI (tabelle
// applicative, non metadati LZ in memoria: non c'e' una collection di
// TzSystem gia' pronta come per zLookups/zDataSets/eccetera).
//
// Gruppo e MainDataset hanno anche loro la tendina, ma i valori non stanno
// sul database: sono le cartelle dei modelli e i dataset registrati nel
// manager dei report. Li espone la form (zOffice.Reports.Form) nelle due
// liste zReportGruppiProposti / zReportDatasetProposti di
// zOffice.Reports.Proprieta, che qui si leggono e basta.
//
// Si autoregistra in initialization: cxRegisterPropertyEditor non ha
// bisogno del sistema live al momento della registrazione (solo GetValues,
// quando l'inspector costruisce la riga, usa Base). Basta che questa unit
// sia linkata perche' l'inspector la trovi: la cita l'implementation di
// zOffice.Reports.Form (prima non la citava nessuno, la unit non entrava
// nell'eseguibile e nessuna delle tendine compariva).

interface

uses
  System.Classes,
  System.TypInfo,
  cxOI,
  zFbDataSet,
  zOffice.Reports.Proprieta;

type
  // Derivano da TcxStringProperty e non da TcxPropertyEditor: la classe base non
  // sa leggere ne' scrivere una stringa (GetValue ritorna un testo segnaposto e
  // SetValue non fa niente), quindi la riga mostrava "(Unknown)" e la scelta
  // dall'elenco non arrivava alla proprieta'. TcxStringProperty gestisce il valore.
  TzProfiloDocumentalePropertyEditor = class(TcxStringProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TzTipologiaDocumentalePropertyEditor = class(TcxStringProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TzReportGruppoPropertyEditor = class(TcxStringProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TzReportDatasetPropertyEditor = class(TcxStringProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

implementation

uses
  System.SysUtils,
  zSystem;

{ TzProfiloDocumentalePropertyEditor }

function TzProfiloDocumentalePropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaValueList];
end;

procedure TzProfiloDocumentalePropertyEditor.GetValues(Proc: TGetStrProc);
const
  sql = 'SELECT OBJ_FILES_PROFILI_DOCUMENTALI.PROFILO FROM OBJ_FILES_PROFILI_DOCUMENTALI ORDER BY OBJ_FILES_PROFILI_DOCUMENTALI.PROFILO';
var
  DataSet: TzFbDataSet;
begin
  if not Assigned(Base) or not Assigned(Base.zFbDatabase) then
    exit;

  DataSet := CreateFbDataSet(nil, Base.zFbDatabase, Base.zFbTransaction, Base.zFbTransaction, True);
  try
    DataSet.SelectSQL.Text := sql;
    DataSet.Open;
    try
      while not DataSet.Eof do
      begin
        Proc(DataSet.FieldByName('PROFILO').AsString);
        DataSet.Next;
      end;
    finally
      DataSet.Close;
    end;
  finally
    FreeAndNil(DataSet);
  end;
end;

{ TzTipologiaDocumentalePropertyEditor }

function TzTipologiaDocumentalePropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaValueList];
end;

procedure TzTipologiaDocumentalePropertyEditor.GetValues(Proc: TGetStrProc);
const
  sql = 'SELECT OBJ_FILES_TIPOLOGIE_DOCUMENTALI.TIPOLOGIA_DOCUMENTALE FROM OBJ_FILES_TIPOLOGIE_DOCUMENTALI ORDER BY OBJ_FILES_TIPOLOGIE_DOCUMENTALI.TIPOLOGIA_DOCUMENTALE';
var
  DataSet: TzFbDataSet;
begin
  if not Assigned(Base) or not Assigned(Base.zFbDatabase) then
    exit;

  DataSet := CreateFbDataSet(nil, Base.zFbDatabase, Base.zFbTransaction, Base.zFbTransaction, True);
  try
    DataSet.SelectSQL.Text := sql;
    DataSet.Open;
    try
      while not DataSet.Eof do
      begin
        Proc(DataSet.FieldByName('TIPOLOGIA_DOCUMENTALE').AsString);
        DataSet.Next;
      end;
    finally
      DataSet.Close;
    end;
  finally
    FreeAndNil(DataSet);
  end;
end;

{ TzReportGruppoPropertyEditor }

function TzReportGruppoPropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaValueList];
end;

procedure TzReportGruppoPropertyEditor.GetValues(Proc: TGetStrProc);
var
  Gruppo: string;
begin
  // lista vuota se la form non l'ha riempita: la tendina non propone niente
  // e il campo resta digitabile, com'era prima
  if not Assigned(zReportGruppiProposti) then
    exit;

  for Gruppo in zReportGruppiProposti do
    Proc(Gruppo);
end;

{ TzReportDatasetPropertyEditor }

function TzReportDatasetPropertyEditor.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaValueList];
end;

procedure TzReportDatasetPropertyEditor.GetValues(Proc: TGetStrProc);
var
  DatasetName: string;
begin
  if not Assigned(zReportDatasetProposti) then
    exit;

  for DatasetName in zReportDatasetProposti do
    Proc(DatasetName);
end;

initialization

cxRegisterPropertyEditor(TypeInfo(TzProfiloDocumentaleNome), nil, '', TzProfiloDocumentalePropertyEditor);
cxRegisterPropertyEditor(TypeInfo(TzTipologiaDocumentaleNome), nil, '', TzTipologiaDocumentalePropertyEditor);
cxRegisterPropertyEditor(TypeInfo(TzReportGruppoNome), nil, '', TzReportGruppoPropertyEditor);
cxRegisterPropertyEditor(TypeInfo(TzReportDatasetNome), nil, '', TzReportDatasetPropertyEditor);

end.
