unit zDbView.Storage;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  cxGrid,
  cxGridDBTableView,
  dxPScxGridLnk,
  data.DB,
  zSystem,
  dxBar,
  zDataController;

type
  // Snapshot serializzabile di una colonna: separa la persistenza su ini
  // dall'iterazione delle colonne grid, cosi' la serializzazione e'
  // testabile con un TMemIniFile senza DevExpress.
  TzColumnLayoutItem = record
    FieldName: string;
    Index: integer; // -1 = colonna nascosta
    Width: integer;
    Visible: boolean;
    // Valorizzato da ReadLayoutFromIni: true solo se la chiave esisteva
    // nella sezione. Le colonne non trovate NON vanno toccate in
    // applicazione (il vecchio codice le saltava del tutto).
    Found: boolean;
  end;

  TzColumnLayout = TArray<TzColumnLayoutItem>;

  TzDbViewStorage = class(TObject)
  private
    FView: TcxGridDBTableView;
    FDataController: TzDataController;
  private
    FIniFileName: string;
    FLayoutPersonaleTrovato: boolean;
    procedure SetIniFileName(const Value: string);
    function GetIniFileName: string;
  private
    FCardID: string;
    FCustomLoadCallback: TProc;
    FCustomSaveCallback: TProc;
    FzDbViewProps: TzDbViewProps;
    procedure SetCardID(const Value: string);
    function GetViewID: string;
    procedure SetViewID(const Value: string);
    procedure InitProps;
  private
    procedure UpdateProps(Flags: TzDbViewFlags);
    procedure InternalSaveProps(const Silent: Boolean; const SaveToLZ: Boolean; const Async: Boolean);
  private
    procedure InternalLoadProperties;
    procedure InternalSaveProperties(const SaveToLZ: Boolean);
    function GridColumnsToLayout: TzColumnLayout;
  public
    constructor Create(aDataController: TzDataController; aView: TcxGridDBTableView);
    destructor Destroy; override;

    procedure Load(Flags: TzDbViewFlags);
    procedure Save(Flags: TzDbViewFlags; Silent: Boolean; const SaveToLZ: Boolean);

    function EditProps(Flags: TzDbViewFlags): Boolean;

    procedure ClearIniSectionAllUsers;
    procedure LoadFromIni;
    procedure SaveToIni;
    property IniFileName: string read GetIniFileName write SetIniFileName;
    // Valorizzato da LoadFromIni: true se l'INI dell'utente ha la sezione di
    // questa vista, cioe' se l'utente ha gia' un layout suo
    property LayoutPersonaleTrovato: boolean read FLayoutPersonaleTrovato;

    // Serializzazione pura del layout colonne: logica estratta da
    // SaveToIni/LoadFromIni, testabile in round-trip su TMemIniFile.
    class procedure WriteLayoutToIni(Ini: TCustomIniFile; const Section: string; const Layout: TzColumnLayout); static;
    class function ReadLayoutFromIni(Ini: TCustomIniFile; const Section: string; const Current: TzColumnLayout): TzColumnLayout; static;
  public
    property CardID: string read FCardID write SetCardID;
    property ViewID: string read GetViewID write SetViewID;

    property DataController: TzDataController read FDataController write FDataController;
    property View: TcxGridDBTableView read FView;
    property zDbViewProps: TzDbViewProps read FzDbViewProps;

    property CustomSaveCallback: TProc read FCustomSaveCallback write FCustomSaveCallback;
    property CustomLoadCallback: TProc read FCustomLoadCallback write FCustomLoadCallback;
  end;

implementation

uses
  System.UITypes,
  System.Actions,
  Vcl.Forms,
  Vcl.ActnList,
  cxCustomData,
  zFbDataSet,
  zBaseLib,
  zz.base.editor._form;

{ TzDbViewStorage }

type
  TcxGridDBTableViewAccess = class(TcxGridDBTableView);

constructor TzDbViewStorage.Create(aDataController: TzDataController; aView: TcxGridDBTableView);
begin
  inherited Create;
  Assert(Assigned(aDataController));
  Assert(Assigned(aView));

  FCustomSaveCallback := nil;
  FCustomLoadCallback := nil;

  FDataController := aDataController;
  FView := aView;
  FCardID := '';
  FLayoutPersonaleTrovato := false;
  FzDbViewProps := TzDbViewProps.Create(nil);
end;

destructor TzDbViewStorage.Destroy;
begin
  FreeAndNil(FzDbViewProps);
  inherited;
end;

procedure TzDbViewStorage.ClearIniSectionAllUsers;
var
  FileName: string;
  i: integer;
  UsersFolder, CartellaUtente: string;
  Ini: TIniFile;
  SectionName: string;
begin
  // InitProps;
  //
  // SectionName := zDbViewProps.Name;
  // UsersFolder := Base.ConfigRoot_UserPersonalData;
  //
  // ForceDirectories(UsersFolder);
  // if not DirectoryExists(UsersFolder) then
  // Exit;
  //
  // occorre un metodo per enumerare gli utenti/percorsi
  //
  // for i := 0 to Base.zSecurity.zUsers.Count - 1 do
  // begin
  // CartellaUtente := CalcPath(UsersFolder + Base.zSecurity.zUsers[i].GetFolder);
  // ForceDirectories(CartellaUtente);
  //
  // FileName := CartellaUtente + ChangeFileExt(ExtractFileName(Application.ExeName), '.Columns');
  //
  // if FileExists(FileName) then
  // begin
  // Ini := TIniFile.Create(FileName);
  // try
  // Ini.EraseSection(SectionName);
  // finally
  // FreeAndNil(Ini);
  // end;
  // end;
  // end;
end;

function TzDbViewStorage.GetIniFileName: string;
begin
  result := FIniFileName;

  if result.IsEmpty then
    result := base.ConfigFileName('.Columns');
end;

function TzDbViewStorage.GetViewID: string;
begin
  if zDbViewProps.Name = '' then
    zDbViewProps.Name := DataController.IdDataSet;

  result := zDbViewProps.Name;
end;

procedure TzDbViewStorage.InitProps;
begin
  if zDbViewProps.Name = '' then
    zDbViewProps.Name := ViewID;

  if zDbViewProps.DataSet = '' then
    zDbViewProps.DataSet := DataController.IdDataSet;
end;

procedure TzDbViewStorage.SetCardID(const Value: string);
begin
  FCardID := Value;
  // zDbCardDlg.CardID := CardID; // !!!!!!!!!!!
end;

procedure TzDbViewStorage.SetIniFileName(const Value: string);
begin
  FIniFileName := Value;
end;

procedure TzDbViewStorage.SetViewID(const Value: string);
begin
  zDbViewProps.Name := Value;
end;

procedure TzDbViewStorage.UpdateProps(Flags: TzDbViewFlags);
begin
  InitProps;
  zDbViewProps.Columns.AssignFromGridColumns(DataController.IdDataSet, View, ViewID);
  zDbViewProps.Flags.Assign(Flags);
end;

function TzDbViewStorage.GridColumnsToLayout: TzColumnLayout;
var
  i: integer;
begin
  SetLength(result, View.ColumnCount);

  for i := 0 to View.ColumnCount - 1 do
  begin
    result[i].FieldName := View.Columns[i].DataBinding.FieldName;
    result[i].Index := View.Columns[i].Index;
    result[i].Width := View.Columns[i].Width;
    result[i].Visible := View.Columns[i].Visible;
    result[i].Found := false;
  end;
end;

class procedure TzDbViewStorage.WriteLayoutToIni(Ini: TCustomIniFile; const Section: string; const Layout: TzColumnLayout);
var
  item: TzColumnLayoutItem;
begin
  Ini.EraseSection(Section);

  for item in Layout do
    if item.Visible then
    begin
      Ini.WriteInteger(Section, item.FieldName, item.Index);
      Ini.WriteInteger(Section, item.FieldName + '_Width', item.Width);
    end
    else
    begin
      Ini.WriteInteger(Section, item.FieldName, -1);
      Ini.WriteInteger(Section, item.FieldName + '_Width', 100);
    end;
end;

class function TzDbViewStorage.ReadLayoutFromIni(Ini: TCustomIniFile; const Section: string; const Current: TzColumnLayout): TzColumnLayout;
var
  i: integer;
  idx: integer;
  w: integer;
begin
  result := Copy(Current);

  for i := 0 to High(result) do
  begin
    result[i].Found := Ini.ValueExists(Section, result[i].FieldName);

    if not result[i].Found then
      Continue;

    idx := Ini.ReadInteger(Section, result[i].FieldName, -1);

    result[i].Visible := idx <> -1;
    result[i].Index := idx;

    w := Ini.ReadInteger(Section, result[i].FieldName + '_Width', result[i].Width);

    if w > 2000 then
      w := 2000;

    result[i].Width := w;
  end;
end;

procedure TzDbViewStorage.SaveToIni;
var
  Ini: TMemIniFile;
begin
  if IniFileName <> '' then
  begin
    InitProps;
    zDbViewProps.Columns.AssignFromGridColumns(DataController.IdDataSet, View, ViewID);

    try
      // TMemIniFile e non TIniFile: il file contiene le sezioni di tutte le
      // viste dell'utente e TIniFile lo rilegge e riscrive per intero a ogni
      // chiave (due per colonna), spesso su una cartella di rete. Cosi' si
      // legge una volta e si scrive una volta, con UpdateFile
      Ini := TMemIniFile.Create(IniFileName);
      try
        WriteLayoutToIni(Ini, ViewID, GridColumnsToLayout);
        Ini.UpdateFile;
      finally
        FreeAndNil(Ini);
      end;
    except
      // sul nuovo server softline da problemi
    end;
  end;
end;

procedure TzDbViewStorage.Load(Flags: TzDbViewFlags);
begin
  // chiamato da Datachange se view.ColumnCount = 0
  // chiamato da LoadProperties
  InitProps;
  InternalLoadProperties;
  zDbViewProps.Columns.ValidateDataset(DataController.zFbDataSet);
  zDbViewProps.Columns.AssignToGridColumns(DataController.IdDataSet, View, ViewID);
  Flags.Assign(zDbViewProps.Flags);
end;

function TzDbViewStorage.EditProps(Flags: TzDbViewFlags): Boolean;
var
  i: integer;
  idx: integer;
begin
  result := False;

  UpdateProps(Flags);

  result := Edit_CollectionItem(base, zDbViewProps);

  if result then
  begin
    InternalSaveProps(False, True, False);
    zDbViewProps.Columns.AssignToGridColumns(DataController.IdDataSet, View, ViewID);

    // l'attribuzione a flags comportera' l'aggiornamento della view
    // Flags.Assign(zDbViewProps.Flags);
    Flags.BeginUpdate;
    try
      Flags.Assign(zDbViewProps.Flags);
    finally
      Flags.EndUpdate;
    end;
  end;
end;

procedure TzDbViewStorage.Save(Flags: TzDbViewFlags; Silent: Boolean; const SaveToLZ: Boolean);
begin
  // da rivedere quando e' il caso di chiamarlo
  // ClearIniSectionAllUsers; // valutare

  UpdateProps(Flags);

  InternalSaveProps(Silent, SaveToLZ, True);
end;

procedure TzDbViewStorage.InternalSaveProps(const Silent: Boolean; const SaveToLZ: Boolean; const Async: Boolean);
begin
  // solo salvataggio su LZ,
  // le colonne e i flags DEVONO essere gia' presenti nelle props

  if not Silent then
    StartWait('Attendere...', True);
  try
    InitProps;

    if not Async then
      InternalSaveProperties(SaveToLZ)
    else
      TThread.CreateAnonymousThread(
        procedure
        begin
          InternalSaveProperties(SaveToLZ);
        end).Start;
  finally
    if not Silent then
      StopWait;
  end;
end;

procedure TzDbViewStorage.LoadFromIni;
var
  i: integer;
  Ini: TMemIniFile;
  Layout: TzColumnLayout;
  column: TcxGridDBColumn;
begin
  // inizializza le props, qualora fossero state appena create

  zDbViewProps.Columns.AssignToGridColumns(DataController.IdDataSet, View, ViewID);

  FLayoutPersonaleTrovato := false;

  if IniFileName <> '' then
    if FileExists(IniFileName) then
    begin
      View.BeginUpdate;
      try
        TcxGridDBTableViewAccess(View).IsRestoring := True;
        try
          try
            Ini := TMemIniFile.Create(IniFileName);
            try
              FLayoutPersonaleTrovato := Ini.SectionExists(ViewID);
              Layout := ReadLayoutFromIni(Ini, ViewID, GridColumnsToLayout);
            finally
              FreeAndNil(Ini);
            end;

            // applica alla grid solo le colonne trovate nella sezione:
            // le altre restano come sono (comportamento storico)
            for i := 0 to High(Layout) do
              if Layout[i].Found then
              begin
                column := View.GetColumnByFieldName(Layout[i].FieldName) as TcxGridDBColumn;

                if not Assigned(column) then
                  Continue;

                column.Visible := Layout[i].Visible;

                if Layout[i].Visible then
                  column.Index := Layout[i].Index;

                column.Width := Layout[i].Width;
              end;
          except
            // sul nuovo server softline da problemi
          end;
        finally
          TcxGridDBTableViewAccess(View).IsRestoring := False;
        end;
      finally
        View.EndUpdate;
      end;
    end;
end;

procedure TzDbViewStorage.InternalLoadProperties;
begin

  if Assigned(FCustomLoadCallback) then
    CustomLoadCallback
  else
    zDbViewProps.LoadFromBase;
end;

procedure TzDbViewStorage.InternalSaveProperties(const SaveToLZ: Boolean);
begin

  if Assigned(FCustomSaveCallback) then
    CustomSaveCallback
  else
    zDbViewProps.SaveToBase(SaveToLZ);
end;

end.
