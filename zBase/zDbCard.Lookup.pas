unit zDbCard.Lookup;

// =============================================================================
// Lato "dataset" dei lookup di card (estratto da TzControl).
//
// TzLookupBinding possiede il dataset/datasource di lookup di un campo e
// concentra: creazione e configurazione (props da zSystem), apertura
// on-demand (performance: i lookup restano chiusi finche' non servono),
// assegnazione dei parametri master e verifica/riapertura al cambio dei
// campi master. La parte UI (eventi dei combo, dialog F2, colori) resta su
// TzControl, che delega qui tutte le operazioni sul dataset.
//
// TzMasterFieldsBinder isola il parsing di TzLookup.MasterFields
// ('PARAM@CAMPO;...' oppure 'CAMPO;...') e l'allineamento dei parametri:
// e' una class procedure pura, testabile senza card ne' controlli.
//
// TzCorrispondenzaChiaveLookup isola il confronto fra la chiave del record
// corrente di un lookup e il valore digitato nel controllo (Mantis #312): e'
// una class function pura sui valori, testabile senza dataset ne' controlli.
// =============================================================================

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  zBaseLib,
  zSystem,
  zFbDataSet,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

type
  TzCorrispondenzaChiaveLookup = record
  public
    // Dice se il record corrente di un lookup e' quello del valore digitato.
    // Chiave intera: uguaglianza numerica; se il valore del controllo non e' un
    // intero non c'e' niente da confrontare e la risposta e' vera (come prima).
    // Chiave di testo: uguaglianza senza maiuscole e senza spazi ai bordi.
    // Qualunque altro tipo di chiave: vera. Una chiave nulla vale 0 se intera e
    // testo vuoto se di testo.
    class function Corrisponde(TipoCampoChiave: TFieldType; const ValoreChiave, ValoreControllo: Variant): boolean; static;
  end;

  TzMasterFieldsBinder = record
  public
    // Allinea i parametri di TargetDataSet (dataset di lookup) ai campi di
    // SourceDataSet (dataset della card, risalendo la catena master/detail).
    // ParamsChanged = True se almeno un parametro e' stato modificato.
    class procedure AssignParams(zLookup: TzLookup; SourceDataSet, TargetDataSet: TzFbDataSet; out ParamsChanged: boolean); static;
  end;

  TzLookupBinding = class
  private
    FFieldName: string;
    FIdLookup: string;
    FSystemProvider: TFunc<TzSystem>;
    FCardDataSetProvider: TFunc<TzFbDataSet>;
    FReadTransactionProvider: TFunc<TzFbTransaction>;
    FWriteTransactionProvider: TFunc<TzFbTransaction>;
    FDataSet: TzFbDataSet;
    FDataSource: TDataSource;
    function LookupSystem: TzSystem;
    function CardDataSet: TzFbDataSet;
    function BuildDataSet: TzFbDataSet;
    procedure ApplyDataSetProps(DataSet: TzFbDataSet);
    procedure HandleQueryParams(DataSet: TDataSet);
  public
    constructor Create(const FieldName, IdLookup: string; const SystemProvider: TFunc<TzSystem>; const CardDataSetProvider: TFunc<TzFbDataSet>; const ReadTransactionProvider, WriteTransactionProvider: TFunc<TzFbTransaction>);
    destructor Destroy; override;

    // Dataset principale del binding (quello agganciato al combo).
    procedure CreateMainDataSet;

    // Dataset ausiliario con la stessa configurazione (dialog di lookup,
    // riempimento check-combo). La proprieta' passa al chiamante.
    function CreateAuxiliaryDataSet: TzFbDataSet;

    // Riapplica le props di zSystem al dataset principale (es. dopo che il
    // dialog di lookup puo' averne modificato la definizione).
    procedure ReapplyDataSetProps;

    // Apertura on-demand: attiva il dataset solo se la card e' attiva e
    // l'SQL e' definito (i lookup restano chiusi per performance).
    procedure EnsureOpen;

    procedure AssignMasterParams(TargetDataSet: TzFbDataSet; out ParamsChanged: boolean);

    // Riallinea i parametri master e riapre se cambiati (o se la card e'
    // stata aperta dopo la creazione del lookup).
    procedure VerifyParams;

    property DataSet: TzFbDataSet read FDataSet;
    property DataSource: TDataSource read FDataSource;
    property IdLookup: string read FIdLookup;
  end;

implementation

var
  SiLookup: TSiSession;

  { TzLookupBinding }

constructor TzLookupBinding.Create(const FieldName, IdLookup: string; const SystemProvider: TFunc<TzSystem>; const CardDataSetProvider: TFunc<TzFbDataSet>; const ReadTransactionProvider, WriteTransactionProvider: TFunc<TzFbTransaction>);
begin
  inherited Create;
  FFieldName := FieldName;
  FIdLookup := IdLookup;
  FSystemProvider := SystemProvider;
  FCardDataSetProvider := CardDataSetProvider;
  FReadTransactionProvider := ReadTransactionProvider;
  FWriteTransactionProvider := WriteTransactionProvider;
end;

destructor TzLookupBinding.Destroy;
begin
  FreeAndNil(FDataSource);
  FreeAndNil(FDataSet);
  inherited;
end;

function TzLookupBinding.LookupSystem: TzSystem;
begin
  result := nil;
  if Assigned(FSystemProvider) then
    result := FSystemProvider();
end;

function TzLookupBinding.CardDataSet: TzFbDataSet;
begin
  result := nil;
  if Assigned(FCardDataSetProvider) then
    result := FCardDataSetProvider();
end;

function TzLookupBinding.BuildDataSet: TzFbDataSet;
var
  SistemaLookup: TzSystem;
begin
  SistemaLookup := LookupSystem;
  if not Assigned(SistemaLookup) then
    raise Exception.Create('Lookup ' + FIdLookup + ': provider di zSystem non assegnato');

  result := CreateFbDataSet(nil, SistemaLookup.zFbDatabase, FReadTransactionProvider(), FWriteTransactionProvider());
  result.name := ValidateComponentName('LK_' + FIdLookup);
  ApplyDataSetProps(result);
end;

procedure TzLookupBinding.ApplyDataSetProps(DataSet: TzFbDataSet);
var
  Lookup: TzLookup;
begin
  Lookup := LookupSystem.zLookups.Get(FIdLookup, false);

  if Assigned(Lookup) then
    DataSet.IdDataSet := Lookup.DataSet;

  DataSet.AutoCommit := true;
  LookupSystem.DataSetLoadProps(DataSet);
  // DataSetLoadProps assegna l'evento standard, occorre forzare il nostro
  DataSet.OnGetQueryParams := HandleQueryParams;
  DataSet.UseSqlLocate := true;
end;

procedure TzLookupBinding.HandleQueryParams(DataSet: TDataSet);
var
  ParamsChanged: boolean;
begin
  if Assigned(DataSet) then
  begin
    AssignMasterParams(DataSet as TzFbDataSet, ParamsChanged);
    // richiama quello di default
    LookupSystem.DataSetQueryParams(DataSet as TzFbDataSet);
  end;
end;

procedure TzLookupBinding.CreateMainDataSet;
begin
  if Assigned(FDataSet) then
    Exit;

  FDataSet := BuildDataSet;
  FDataSource := TDataSource.Create(nil);
  FDataSource.name := FDataSet.name + 'Src';
  FDataSource.DataSet := FDataSet;
end;

function TzLookupBinding.CreateAuxiliaryDataSet: TzFbDataSet;
begin
  result := BuildDataSet;
end;

procedure TzLookupBinding.ReapplyDataSetProps;
begin
  if Assigned(FDataSet) then
    ApplyDataSetProps(FDataSet);
end;

procedure TzLookupBinding.EnsureOpen;
begin
  if not Assigned(FDataSet) then
    Exit;

  if FDataSet.Active then
    Exit;

  if not((CardDataSet <> nil) and (CardDataSet.Active)) then
    Exit;

  if FDataSet.SelectSQL.Count = 0 then
    Exit;

  SiLookup.LogString('EnsureOpen', FFieldName);
  try
    FDataSet.Active := true;
  except
    on e: Exception do
    begin
      SiLookup.LogException(e);
      SiLookup.LogStringList(' Lookup ', FDataSet.SelectSQL);
      raise;
    end;
  end;
end;

procedure TzLookupBinding.AssignMasterParams(TargetDataSet: TzFbDataSet; out ParamsChanged: boolean);
var
  zLookup: TzLookup;
begin
  ParamsChanged := false;

  zLookup := LookupSystem.zLookups.Get(FIdLookup);
  if not Assigned(zLookup) then
    Exit;

  TzMasterFieldsBinder.AssignParams(zLookup, CardDataSet, TargetDataSet, ParamsChanged);
end;

procedure TzLookupBinding.VerifyParams;
var
  ParamsChanged: boolean;
begin
  if not Assigned(FDataSet) then
    Exit;

  AssignMasterParams(FDataSet, ParamsChanged);

  // se parametri modificati oppure se e' stato aperto il dataset della card
  if ParamsChanged or ((not FDataSet.Active) and (CardDataSet <> nil) and (CardDataSet.Active)) then
  begin
    SiLookup.LogString('VerifyParams', 'ParamsChanged per: ' + FFieldName);
    FDataSet.ReOpen();
  end;
end;

{ TzCorrispondenzaChiaveLookup }

// Mantis #312 - 2026-11-02: confronto estratto da TzControl.CopyMappingFields per poterlo coprire con test
class function TzCorrispondenzaChiaveLookup.Corrisponde(TipoCampoChiave: TFieldType; const ValoreChiave, ValoreControllo: Variant): boolean;
var
  ChiaveIntera, ControlloIntero: Int64;
begin
  result := true;

  if TipoCampoChiave in [ftSmallint, ftInteger, ftLargeint, ftWord, ftAutoInc, ftShortint, ftByte, ftLongWord] then
  begin
    // se il valore del controllo non e' un intero non c'e' niente da confrontare: si lascia come prima
    if TryStrToInt64(Trim(VarToStr(ValoreControllo)), ControlloIntero) then
    begin
      ChiaveIntera := 0;
      if not VarIsNull(ValoreChiave) and not VarIsEmpty(ValoreChiave) then
        ChiaveIntera := VarAsType(ValoreChiave, varInt64);

      result := ChiaveIntera = ControlloIntero;
    end;

    Exit;
  end;

  if not IsStringType(TipoCampoChiave) then
    Exit;

  result := SameText(Trim(VarToStr(ValoreChiave)), Trim(VarToStr(ValoreControllo)));
end;

{ TzMasterFieldsBinder }

class procedure TzMasterFieldsBinder.AssignParams(zLookup: TzLookup; SourceDataSet, TargetDataSet: TzFbDataSet; out ParamsChanged: boolean);

  function GetSourceField(DataSet: TDataSet; const FieldName: string): TField;
  var
    MasterField: TField;
  begin
    // scorre la sequenza master/detail per trovare il campo sorgente
    result := nil;

    if not Assigned(DataSet) then
      Exit;

    result := DataSet.FindField(FieldName);

    // Mantis #298 - 2026-10-30: un dataset vuoto (nessuna riga e nessun
    // inserimento in corso) ha il campo ma non un valore: prima il campo nullo
    // azzerava il parametro che l'evento BeforeOpen del lookup aveva appena
    // impostato, e il lookup si apriva vuoto (pagina Corsi della Rettifica
    // incarico, incarico senza corsi, tendina aperta prima di "Aggiungi").
    // In quel caso il valore si prende dal master, se lo ha.
    if Assigned(result) then
      if DataSet.Active and DataSet.IsEmpty and (DataSet.State = dsBrowse) then
        if Assigned(DataSet.DataSource) then
          if Assigned(DataSet.DataSource.DataSet) then
          begin
            MasterField := GetSourceField(DataSet.DataSource.DataSet, FieldName);
            if Assigned(MasterField) then
              result := MasterField;
          end;

    if not Assigned(result) then
      // se non lo trova nel dataset stesso prova a cercare nell'eventuale master
      if Assigned(DataSet.DataSource) then
        if Assigned(DataSet.DataSource.DataSet) then
          result := GetSourceField(DataSet.DataSource.DataSet, FieldName);
  end;

var
  s: string;
  i: integer;
  MasterFieldsList: TStringList;
  FieldTokens: TStringList;
  SrcField, DestParam: string;
  Field: TField;
  MasterFields: string;
begin
  SiLookup.EnterMethod('TzMasterFieldsBinder.AssignParams');
  try
    ParamsChanged := false;

    if not Assigned(zLookup) then
      Exit;

    if not Assigned(TargetDataSet) then
      Exit;

    if not Assigned(SourceDataSet) then
      Exit;

    if TargetDataSet.SelectSQL.Text = '' then
      Exit;

    if not TargetDataSet.Active then
      TargetDataSet.Prepare;

    if trim(zLookup.MasterFields) = '' then
      Exit;

    SiLookup.LogString('MasterFields', zLookup.MasterFields);

    MasterFieldsList := TStringList.Create;
    try
      FieldTokens := TStringList.Create;
      try
        MasterFields := zLookup.MasterFields;

        MasterFields := MasterFields.Replace(',', ';');
        MasterFields := MasterFields.Replace('@', '=');
        MasterFields := MasterFields.Replace(' ', '');

        FieldTokens.Delimiter := '=';
        MasterFieldsList.Delimiter := ';';
        MasterFieldsList.DelimitedText := MasterFields;

        for i := 0 to MasterFieldsList.Count - 1 do
        begin
          s := trim(MasterFieldsList[i]);
          FieldTokens.DelimitedText := s;

          SiLookup.LogString('Assegnamento', s);

          // M2: azzerati a ogni giro, cosi' un token malformato non riusa i
          // valori dell'iterazione precedente.
          DestParam := '';
          SrcField := '';

          if FieldTokens.Count = 1 then
          begin
            DestParam := s;
            SrcField := s;
          end
          else
            if FieldTokens.Count = 2 then
            begin
              DestParam := FieldTokens[0];
              SrcField := FieldTokens[1];
            end
            else
            begin
              SiLookup.LogVerbose('Token MasterFields non riconosciuto: ' + s);
              Continue;
            end;

          SiLookup.LogString('SrcField', SrcField);
          SiLookup.LogString('DestParam', DestParam);

          // dest e' il parametro della tabella lookup
          if TargetDataSet.ParamExists(DestParam) then
          begin
            Field := GetSourceField(SourceDataSet, SrcField);

            // src e' il campo della tabella sul quale verra' applicato l'esito del lookup
            if Assigned(Field) then
            begin
              SiLookup.LogValue(Field.FieldName, Field.asString);

              if Field.isNull then
              begin
                // TParam.IsNull puo' restituire False anche se il Value e'
                // Null/Unassigned, oppure la libreria db puo' inizializzare i
                // parametri stringa a '' o gli interi a '0': si verifica che
                // il parametro abbia davvero un valore prima del Clear.
                if (not TargetDataSet.ParamByName(DestParam).isNull) and (not VarIsNull(TargetDataSet.ParamByName(DestParam).Value)) and (not VarIsEmpty(TargetDataSet.ParamByName(DestParam).Value)) and
                  (trim(VarToStrDef(TargetDataSet.ParamByName(DestParam).Value, '')) <> '') and (trim(VarToStrDef(TargetDataSet.ParamByName(DestParam).Value, '')) <> '0') then
                begin
                  SiLookup.LogString('AssignParam', 'Field is Null, Param is NOT Null/Empty -> Clearing Param');
                  TargetDataSet.ParamByName(DestParam).Clear;
                  ParamsChanged := true;
                end
                else
                  SiLookup.LogString('AssignParam', 'Field is Null, Param is Null/Empty -> No Change');
              end
              else
              begin
                // L'assegnazione di '' a un parametro Date lo converte in Null,
                // creando un loop infinito perche' Null <> '' e' sempre True al
                // giro successivo: i valori funzionalmente equivalenti
                // (Null/''/'0' vs stringa vuota) non vanno riassegnati.
                if (VarIsNull(TargetDataSet.ParamByName(DestParam).Value) or VarIsEmpty(TargetDataSet.ParamByName(DestParam).Value) or (trim(VarToStrDef(TargetDataSet.ParamByName(DestParam).Value, '')) = '0')) and
                  (trim(VarToStrDef(Field.Value, '')) = '') then
                  SiLookup.LogString('AssignParam', 'Param is Null/Empty/0, Field is Empty String -> No Change')
                else
                  if trim(VarToStrDef(TargetDataSet.ParamByName(DestParam).Value, '')) <> trim(VarToStrDef(Field.Value, '')) then
                  begin
                    SiLookup.LogString('AssignParam', 'Param Value <> Field Value -> Updating Param');
                    TargetDataSet.ParamByName(DestParam).Value := Field.Value;
                    ParamsChanged := true;
                  end
                  else
                    SiLookup.LogString('AssignParam', 'Param Value == Field Value -> No Change');
              end;
            end
            else
              SiLookup.LogVerbose('Campo sorgente non trovato: ' + SrcField);
          end
          else
            SiLookup.LogVerbose('Parametro destinazione non trovato: ' + DestParam);
        end;
      finally
        FreeAndNil(FieldTokens);
      end;
    finally
      FreeAndNil(MasterFieldsList);
    end;
  finally
    SiLookup.LeaveMethod('TzMasterFieldsBinder.AssignParams');
  end;
end;

initialization

SiLookup := Si.AddSession('zDbCard.Lookup', true);

finalization

SiLookup := nil;

end.
