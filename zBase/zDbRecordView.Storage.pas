// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-01
// ---------------------------------------------------------------------------
unit zDbRecordView.Storage;

// Layout personale dell'utente per una vista record: larghezza delle etichette,
// larghezza dei record affiancati e categorie chiuse.
//
// Quello che decide l'amministratore (righe, ordine, categorie, visibilita')
// sta nel dizionario LZ (TzDbRecordViewProps); qui resta solo cio' che ogni
// utente regola per se'. Un file per vista, con l'identificativo nel nome:
// a differenza del file .conditionalFormatting di TzDbView (difetto D6) due
// viste non possono sovrascriversi a vicenda.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles;

type
  TzRecordViewUserLayout = record
    HeaderWidth: integer; // 0 = non salvata
    ValueWidth: integer; // 0 = non salvata
    CollapsedCategories: TArray<string>; // Name degli item di categoria chiusi
    procedure Clear;
    function IsCollapsed(const CategoryName: string): boolean;
  end;

  TzDbRecordViewStorage = class
  private
    FFolder: string;
    FRecordViewID: string;
    function GetFileName: string;
  public
    const
      SectionLayout = 'Layout';

    // Scrittura e lettura separate dal file, per poterle provare da sole
    class procedure WriteLayout(Ini: TCustomIniFile; const Layout: TzRecordViewUserLayout); static;
    class function ReadLayout(Ini: TCustomIniFile): TzRecordViewUserLayout; static;

    function Load: TzRecordViewUserLayout;
    // Falso se il file non si e' potuto scrivere (cartella in sola lettura,
    // file bloccato): il layout personale non si salva, ma la vista non
    // riceve nessuna eccezione
    function Save(const Layout: TzRecordViewUserLayout): boolean;
    // Cancella il layout personale: la vista torna a quello del dizionario
    procedure Reset;

    // Cartella personale dell'utente (TzSystem.PersonalFolder)
    property Folder: string read FFolder write FFolder;
    property RecordViewID: string read FRecordViewID write FRecordViewID;
    property FileName: string read GetFileName;
  end;

implementation

{ TzRecordViewUserLayout }

procedure TzRecordViewUserLayout.Clear;
begin
  HeaderWidth := 0;
  ValueWidth := 0;
  CollapsedCategories := nil;
end;

function TzRecordViewUserLayout.IsCollapsed(const CategoryName: string): boolean;
var
  Name: string;
begin
  result := False;

  for Name in CollapsedCategories do
    if SameText(Name, CategoryName) then
      Exit(true);
end;

{ TzDbRecordViewStorage }

function TzDbRecordViewStorage.GetFileName: string;
var
  SafeID: string;
  Carattere: Char;
begin
  result := '';

  if FFolder.IsEmpty or FRecordViewID.IsEmpty then
    Exit;

  // L'identificativo e' del tipo Modulo.DataSet: il punto resta nel nome
  // (ChangeFileExt lo scambierebbe per l'estensione e fonderebbe le viste
  // dello stesso modulo dati); si tolgono solo i caratteri non ammessi.
  SafeID := '';
  for Carattere in FRecordViewID do
    if CharInSet(Carattere, ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then
      SafeID := SafeID + '_'
    else
      SafeID := SafeID + Carattere;

  result := IncludeTrailingPathDelimiter(FFolder) + SafeID + '.recordview';
end;

class procedure TzDbRecordViewStorage.WriteLayout(Ini: TCustomIniFile; const Layout: TzRecordViewUserLayout);
begin
  if not Assigned(Ini) then
    Exit;

  Ini.EraseSection(SectionLayout);
  Ini.WriteInteger(SectionLayout, 'HeaderWidth', Layout.HeaderWidth);
  Ini.WriteInteger(SectionLayout, 'ValueWidth', Layout.ValueWidth);
  Ini.WriteString(SectionLayout, 'CollapsedCategories', string.Join(';', Layout.CollapsedCategories));
end;

class function TzDbRecordViewStorage.ReadLayout(Ini: TCustomIniFile): TzRecordViewUserLayout;
var
  Elenco: string;
begin
  result.Clear;

  if not Assigned(Ini) then
    Exit;

  if not Ini.SectionExists(SectionLayout) then
    Exit;

  result.HeaderWidth := Ini.ReadInteger(SectionLayout, 'HeaderWidth', 0);
  result.ValueWidth := Ini.ReadInteger(SectionLayout, 'ValueWidth', 0);

  Elenco := Ini.ReadString(SectionLayout, 'CollapsedCategories', '');
  if not Elenco.IsEmpty then
    result.CollapsedCategories := Elenco.Split([';'], TStringSplitOptions.ExcludeEmpty);
end;

function TzDbRecordViewStorage.Load: TzRecordViewUserLayout;
var
  Ini: TMemIniFile;
begin
  result.Clear;

  if FileName.IsEmpty or not FileExists(FileName) then
    Exit;

  // TEncoding.UTF8 solleva su byte non validi: un file rovinato non deve
  // impedire l'apertura della vista, che torna al layout del dizionario.
  // Vale anche per un file che non si riesce ad aprire (bloccato, senza permessi).
  try
    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      result := ReadLayout(Ini);
    finally
      FreeAndNil(Ini);
    end;
  except
    on EEncodingError do
      result.Clear;
    on EStreamError do
      result.Clear;
    on EInOutError do
      result.Clear;
    on EOSError do
      result.Clear;
  end;
end;

function TzDbRecordViewStorage.Save(const Layout: TzRecordViewUserLayout): boolean;
var
  Ini: TMemIniFile;
begin
  result := False;

  if FileName.IsEmpty then
    Exit;

  try
    ForceDirectories(ExtractFilePath(FileName));

    Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
    try
      WriteLayout(Ini, Layout);
      Ini.UpdateFile;
    finally
      FreeAndNil(Ini);
    end;

    result := True;
  except
    on EStreamError do
      result := False;
    on EInOutError do
      result := False;
    on EOSError do
      result := False;
  end;
end;

procedure TzDbRecordViewStorage.Reset;
begin
  if (not FileName.IsEmpty) and FileExists(FileName) then
    System.SysUtils.DeleteFile(FileName);
end;

end.

