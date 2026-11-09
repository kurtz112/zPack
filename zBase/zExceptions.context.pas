unit zExceptions.context;

{
  Raccolta del contesto runtime al momento di un'eccezione:
  - dataset/query che ha generato l'errore (se disponibile)
  - form attiva e catena form (evidenziando i discendenti di TBaseForm)
  - datamodule caricati (Screen.DataModules, evidenziando i TBaseDataModule)
  - controllo col focus
  - info di sistema: memoria processo, handle GDI/USER, thread, monitor attivo
  - contesto DB (via hook, per non legare questa unit a FireDAC)

  Nota disaccoppiamento: per riconoscere TBaseForm / TBaseDataModule NON si fa
  uses delle unit base. Si risale ClassParent confrontando i nomi classe, così
  questa unit resta a basso livello.
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  Vcl.Forms,
  Vcl.Controls;

type
  // Hook opzionale: il layer applicativo può iniettare il contesto DB
  // (connessioni / transazioni FireDAC aperte) senza che questa unit
  // dipenda da FireDAC.
  TContextProvider = TFunc<string>;

var
  // Impostabili dal layer base/app. Se nil, la sezione viene saltata.
  OnCollectDbContext: TContextProvider = nil;
  OnCollectAppContext: TContextProvider = nil;

  // Nomi delle classi base da evidenziare. Modificabili se cambiano i nomi.
  BaseFormClassName: string = 'TBaseForm';
  BaseDataModuleClassName: string = 'TBaseDataModule';

  // Restituisce l'intero contesto runtime formattato.
  // AForm/AControl: form e controllo catturati al momento dell'eccezione
  // (PRIMA che si apra il dialog di errore). Se nil, si ripiega su Screen.*.
// AFailedDataSetDump: dump del dataset che ha fallito, GIA' prelevato dal
// chiamante con TakeLastFailedDataSetDump (lo fa TzExceptionManager nel
// costruttore). Non viene letto qui dalla variabile globale: il log viene
// scritto DUE volte per la stessa eccezione - una in automatico da
// ShowException e una quando l'utente preme Salva - e leggendo una
// variabile "one-shot" al momento della scrittura la seconda copia usciva
// senza la sezione del dataset.
function CollectRuntimeContext(AForm: TCustomForm = nil; AControl: TWinControl = nil;
  const AFailedDataSetDump: string = ''): string;

// Apre una sezione del log: riga vuota, riga di separazione, titolo fra
// parentesi quadre e riga vuota. Esposta perche' anche la parte di log
// scritta da zExceptions.pas (segnalazione, errore, dettaglio Firebird,
// stack) usi le stesse sezioni del contesto: prima quelle in testa al file
// non avevano ne' titolo ne' separazione ed era difficile capire dove
// finisse un blocco e cominciasse il successivo.
procedure AppendSezione(SL: TStrings; const ATitolo: string);

// Rettangolo (coord. schermo) del monitor che contiene AForm.
// Se AForm = nil, usa la form attiva; in mancanza, il monitor primario.
function ActiveMonitorBounds(AForm: TCustomForm = nil): TRect;

// Registra il dump (SQL + record corrente) del dataset/comando che ha
// generato l'errore in corso. Da chiamare PRIMA del raise, tipicamente
// nell'OnError della connessione (vedi zExceptions.firedac.CaptureFailedDataSet)
// o del dataset stesso (vedi zExceptions.firedac.HandleDataSetError).
// E' "one-shot": CollectRuntimeContext lo legge e lo azzera subito dopo,
// così non sopravvive e non si "appiccica" all'eccezione successiva.
procedure SetLastFailedDataSetDump(const ADump: string);

// Peek (SENZA azzerare) se un dump è già stato registrato per l'errore
// in corso. Usato da zExceptions.firedac.CaptureFailedDataSet per non
// sovrascrivere un dump già catturato con precisione maggiore da un
// livello più specifico (es. HandleDataSetError, agganciato direttamente
// all'OnError del dataset: identifica il dataset con certezza, mentre il
// livello connessione a volte può solo elencare "candidati").
function HasLastFailedDataSetDump: Boolean;

// Preleva il dump e azzera la variabile. Va chiamata UNA volta per
// eccezione, al momento in cui l'eccezione viene presa in carico
// (TzExceptionManager.Create), non al momento in cui si scrive il log:
// il log della stessa eccezione viene prodotto piu' volte (una in
// automatico da ShowException, una a ogni Salva) e con l'azzeramento a
// tempo di scrittura solo la prima copia conteneva la sezione.
function TakeLastFailedDataSetDump: string;

// Legge il dump SENZA azzerarlo. Serve a chi vuole accodarci qualcosa
// (es. la segnalazione di un errore avvenuto durante la cattura stessa).
function PeekLastFailedDataSetDump: string;

// Se AClass discende (per nome) da ABaseClassName (tipicamente
// BaseFormClassName o BaseDataModuleClassName), restituisce il "nome
// modulo" normalizzato: il nome della classe con il prefisso convenzionale
// tolto (es. "TFormRisorse" -> "Risorse", "TRisorse" -> "Risorse").
// Se AClass non discende da ABaseClassName (o è nil), restituisce ''.
// Usato per derivare la categoria/tag Mantis dal form o dal datamodule
// applicativo coinvolto nell'eccezione.
function ModuleNameFromClass(AClass: TClass; const ABaseClassName: string): string;

// Registra il nome modulo (già normalizzato da ModuleNameFromClass) del
// datamodule proprietario del dataset/comando che ha generato l'errore
// (fallback quando non c'è una form attiva riconducibile a TBaseForm,
// tipico di operazioni schedulate/di sfondo). Popolato da
// zExceptions.firedac.CaptureFailedDataSet.
procedure SetLastFailedDataSetOwnerModuleName(const AName: string);

// Legge e azzera (one-shot) il nome impostato da
// SetLastFailedDataSetOwnerModuleName.
function TakeLastFailedDataSetOwnerModuleName: string;

// Registra il nome completo della classe DataModule proprietario del dataset
procedure SetLastFailedDataSetDataModuleName(const AName: string);

// Legge e azzera (one-shot) il nome DataModule
function TakeLastFailedDataSetDataModuleName: string;

// Registra il nome del dataset
procedure SetLastFailedDataSetName(const AName: string);

// Legge e azzera (one-shot) il nome del dataset
function TakeLastFailedDataSetName: string;

// Registra l'identificativo LZ del dataset, cioe' la chiave con cui
// TzSystem.zDataSets ritrova le sue proprieta' (nella forma
// NomeDataModule.NomeDataSet). E' l'unico dato che permette di aprire
// l'editor dell'SQL partendo dall'eccezione: il nome del componente e la
// classe del datamodule, gia' registrati qui sopra, servono a farsi
// un'idea leggendo il log, ma non identificano la voce dell'LZ.
procedure SetLastFailedDataSetId(const AId: string);

// Legge e azzera (one-shot) l'identificativo LZ del dataset
function TakeLastFailedDataSetId: string;

implementation

uses
  System.StrUtils,
  System.TypInfo,
  Winapi.Windows,
  Winapi.PsAPI;

var
  GLastFailedDataSetDump: string = '';
  GLastFailedDataSetOwnerModuleName: string = '';
  GLastFailedDataSetDataModuleName: string = '';
  GLastFailedDataSetName: string = '';
  GLastFailedDataSetId: string = '';

procedure SetLastFailedDataSetDump(const ADump: string);
begin
  GLastFailedDataSetDump := ADump;
end;

function HasLastFailedDataSetDump: Boolean;
begin
  Result := GLastFailedDataSetDump.Trim <> '';
end;

function PeekLastFailedDataSetDump: string;
begin
  Result := GLastFailedDataSetDump;
end;

function TakeLastFailedDataSetDump: string;
begin
  Result := GLastFailedDataSetDump;
  GLastFailedDataSetDump := ''; // one-shot
end;

procedure SetLastFailedDataSetOwnerModuleName(const AName: string);
begin
  GLastFailedDataSetOwnerModuleName := AName;
end;

function TakeLastFailedDataSetOwnerModuleName: string;
begin
  Result := GLastFailedDataSetOwnerModuleName;
  GLastFailedDataSetOwnerModuleName := ''; // one-shot
end;

procedure SetLastFailedDataSetDataModuleName(const AName: string);
begin
  GLastFailedDataSetDataModuleName := AName;
end;

function TakeLastFailedDataSetDataModuleName: string;
begin
  Result := GLastFailedDataSetDataModuleName;
  GLastFailedDataSetDataModuleName := '';
end;

procedure SetLastFailedDataSetName(const AName: string);
begin
  GLastFailedDataSetName := AName;
end;

function TakeLastFailedDataSetName: string;
begin
  Result := GLastFailedDataSetName;
  GLastFailedDataSetName := '';
end;

procedure SetLastFailedDataSetId(const AId: string);
begin
  GLastFailedDataSetId := AId;
end;

function TakeLastFailedDataSetId: string;
begin
  Result := GLastFailedDataSetId;
  GLastFailedDataSetId := '';
end;

// --- helper: una classe discende (per nome) da una classe base? ------------
function InheritsFromName(AClass: TClass; const ABaseName: string): boolean;
begin
  result := false;
  while AClass <> nil do
  begin
    if SameText(AClass.ClassName, ABaseName) then
      Exit(True);
    AClass := AClass.ClassParent;
  end;
end;

// Toglie il prefisso convenzionale dal nome classe. Ordine dal più al
// meno specifico per non tagliare a metà un prefisso più lungo.
// Convenzione osservata nei sorgenti Gesty/WT: form = "TForm" + Nome,
// datamodule = "T" + Nome (nessun infisso "DM"); si gestiscono anche le
// varianti meno comuni "Tfrm"/"TDM" per sicurezza.
function StripModulePrefix(const AClassName: string): string;
begin
  Result := AClassName;
  if Result.StartsWith('TForm', true) then
    Result := Result.Substring(5)
  else if Result.StartsWith('Tfrm', true) then
    Result := Result.Substring(4)
  else if Result.StartsWith('TDM', true) then
    Result := Result.Substring(3)
  else if Result.StartsWith('T') then
    Result := Result.Substring(1);
end;

function ModuleNameFromClass(AClass: TClass; const ABaseClassName: string): string;
begin
  Result := '';
  if (AClass = nil) or not InheritsFromName(AClass, ABaseClassName) then
    Exit;
  Result := StripModulePrefix(AClass.ClassName).Trim;
end;

// --- sezioni --------------------------------------------------------------

procedure AppendSezione(SL: TStrings; const ATitolo: string);
begin
  SL.Add('');
  SL.Add(''.PadLeft(100, '_'));
  if not ATitolo.IsEmpty then
    SL.Add('[ ' + ATitolo + ' ]');
  SL.Add('');
end;

procedure AppendSeparator(SL: TStrings; const Title: string);
begin
  AppendSezione(SL, Title);
end;

function VisibleLabel(AVisible: boolean): string;
begin
  if AVisible then
    result := 'visibile'
  else
    result := 'non visibile';
end;

// Dataset/query che ha generato l'errore corrente (se qualcuno l'ha
// valorizzato con SetLastFailedDataSetDump). E' la sezione più utile per
// capire COSA stava facendo l'applicazione, quindi va per prima.
procedure CollectFailedDataSet(SL: TStrings; const ADump: string);
begin
  if ADump.Trim = '' then
    Exit;

  AppendSeparator(SL, 'DATASET/QUERY CHE HA GENERATO L''ERRORE');
  SL.Add(ADump);
end;

procedure CollectActiveForm(SL: TStrings; AForm: TCustomForm);
var
  F: TCustomForm;
begin
  AppendSeparator(SL, 'FORM ATTIVA');

  // NON rileggere Screen: a questo punto la form attiva è il dialog di
  // errore. Usiamo solo ciò che è stato catturato all'inizio.
  F := AForm;
  if F = nil then
  begin
    // ZC 30.10.2026: senza "al momento dell'eccezione": il contesto finisce
    // anche nel ticket della registrazione per l'assistenza, dove di eccezioni
    // non ce ne sono.
    SL.Add('(nessuna form catturata)');
    Exit;
  end;

  SL.AddPair('Classe', F.ClassName);
  SL.AddPair('Name', F.Name);
  SL.AddPair('Caption', F.Caption);
  SL.AddPair('IsBaseForm', BoolToStr(InheritsFromName(F.ClassType, BaseFormClassName), True));
  SL.AddPair('Stato', VisibleLabel(F.Visible));
  if fsModal in F.FormState then
    SL.AddPair('Modale', 'modale');
  SL.AddPair('WindowState', GetEnumName(TypeInfo(TWindowState), Ord(F.WindowState)));
  SL.AddPair('BoundsRect', Format('(%d,%d)-(%d,%d)', [F.Left, F.Top, F.Left + F.Width, F.Top + F.Height]));
end;

procedure CollectFocusedControl(SL: TStrings; AControl: TWinControl);
var
  C: TWinControl;
begin
  AppendSeparator(SL, 'CONTROLLO COL FOCUS');

  // Come sopra: solo ciò che è stato catturato, mai Screen riletto qui.
  C := AControl;
  if C = nil then
  begin
    SL.Add('(nessun controllo catturato)');
    Exit;
  end;

  SL.AddPair('Classe', C.ClassName);
  SL.AddPair('Name', C.Name);
  if C.Parent <> nil then
    SL.AddPair('Parent', C.Parent.Name + ' (' + C.Parent.ClassName + ')');
end;

procedure CollectForms(SL: TStrings);

  procedure AddForm(F: TCustomForm);
  var
    extra: string;
  begin
    extra := VisibleLabel(F.Visible);
    if fsModal in F.FormState then
      extra := extra + ', modale';
    SL.Add(Format('  %-28s %-24s %s', [F.ClassName, F.Name, extra]));
  end;

  // Finestre di servizio (tendine, dialoghi, avanzamento) che non dicono
  // niente su cosa stava facendo l'utente.
  function DiServizio(F: TCustomForm): boolean;
  begin
    result := MatchStr(F.ClassName, ['TcxCheckComboBoxPopupWindow', 'TcxComboBoxPopupWindow', 'TcxDateEditPopupWindow', 'TcxFilterControlDropDownMenu', 'TcxGridFilterPopup', 'TdxMessageDialogForm', 'TdxRibbonTabGroupsPopupWindow',
      'TfrmFDGUIxFormsAsyncExecute', 'TfrxParentForm', 'TPlaceForm', 'TProgressDlg']);
  end;

var
  i, nBase, nOther: integer;
  F: TCustomForm;
begin
  // ZC 30.10.2026: prima i conteggi includevano le finestre di servizio che
  // l'elenco poi salta: il ticket 7366 diceva "FORM APERTE (52)" e "altre form
  // (51)" e ne elencava 3. Ora i conteggi sono quelli delle righe elencate.
  nBase := 0;
  nOther := 0;
  for i := 0 to Screen.CustomFormCount - 1 do
    if InheritsFromName(Screen.CustomForms[i].ClassType, BaseFormClassName) then
      Inc(nBase)
    else if not DiServizio(Screen.CustomForms[i]) then
      Inc(nOther);

  AppendSeparator(SL, Format('FORM APERTE (%d)', [nBase + nOther]));

  SL.Add(Format('-- discendenti di %s (%d) --', [BaseFormClassName, nBase]));
  for i := 0 to Screen.CustomFormCount - 1 do
  begin
    F := Screen.CustomForms[i];
    if InheritsFromName(F.ClassType, BaseFormClassName) then
      AddForm(F);
  end;

  SL.Add('');
  SL.Add(Format('-- altre form (%d) --', [nOther]));
  for i := 0 to Screen.CustomFormCount - 1 do
  begin
    F := Screen.CustomForms[i];

    if not DiServizio(F) then
      if not InheritsFromName(F.ClassType, BaseFormClassName) then
        AddForm(F);
  end;
end;

procedure CollectDataModules(SL: TStrings);
var
  i, nBase, nOther: integer;
  DM: TDataModule;
begin
  AppendSeparator(SL, Format('DATAMODULE CARICATI (%d)', [Screen.DataModuleCount]));

  nBase := 0;
  nOther := 0;
  for i := 0 to Screen.DataModuleCount - 1 do
    if InheritsFromName(Screen.DataModules[i].ClassType, BaseDataModuleClassName) then
      Inc(nBase)
    else
      Inc(nOther);

  SL.Add(Format('-- discendenti di %s (%d) --', [BaseDataModuleClassName, nBase]));
  for i := 0 to Screen.DataModuleCount - 1 do
  begin
    DM := Screen.DataModules[i];
    if InheritsFromName(DM.ClassType, BaseDataModuleClassName) then
      SL.Add(Format('  %-32s %s', [DM.ClassName, DM.Name]));
  end;

  SL.Add('');
  SL.Add(Format('-- altri datamodule (%d) --', [nOther]));
  for i := 0 to Screen.DataModuleCount - 1 do
  begin
    DM := Screen.DataModules[i];
    if not InheritsFromName(DM.ClassType, BaseDataModuleClassName) then
      SL.Add(Format('  %-32s %s', [DM.ClassName, DM.Name]));
  end;
end;

procedure CollectMonitors(SL: TStrings; AForm: TCustomForm);
var
  i: integer;
  M, AM: TMonitor;
  F: TCustomForm;
begin
  AppendSeparator(SL, 'MONITOR');

  F := AForm;
  if F = nil then
    F := Screen.ActiveCustomForm;
  AM := nil;
  if F <> nil then
    AM := Screen.MonitorFromWindow(F.Handle);

  for i := 0 to Screen.MonitorCount - 1 do
  begin
    M := Screen.Monitors[i];
    SL.Add(Format('%s monitor %d: %dx%d @ (%d,%d) DPI=%d %s', [IfThen((AM <> nil) and (M.Handle = AM.Handle), '*', ' '), i, M.Width, M.Height, M.Left, M.Top, M.PixelsPerInch, IfThen(M.Primary, '[primary]', '')]));
  end;
  SL.Add('');
  SL.Add('(* = monitor della form attiva)');
end;

procedure CollectSystem(SL: TStrings);
var
  pmc: TProcessMemoryCounters;
  guiGDI, guiUSER: DWORD;
begin
  AppendSeparator(SL, 'SISTEMA / PROCESSO');

  // Memoria processo
  FillChar(pmc, SizeOf(pmc), 0);
  pmc.cb := SizeOf(pmc);
  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
  begin
    SL.AddPair('WorkingSet (MB)', Format('%.1f', [pmc.WorkingSetSize / 1024 / 1024]));
    SL.AddPair('PeakWorkingSet (MB)', Format('%.1f', [pmc.PeakWorkingSetSize / 1024 / 1024]));
    SL.AddPair('PagefileUsage (MB)', Format('%.1f', [pmc.PagefileUsage / 1024 / 1024]));
  end;

  // Handle GDI / USER (leak diagnostics)
  guiGDI := GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS);
  guiUSER := GetGuiResources(GetCurrentProcess, GR_USEROBJECTS);
  SL.AddPair('GDI handles', guiGDI.ToString);
  SL.AddPair('USER handles', guiUSER.ToString);

  // Thread
  SL.AddPair('Current ThreadId', GetCurrentThreadId.ToString);
  SL.AddPair('Main ThreadId', MainThreadID.ToString);
  SL.AddPair('In main thread', BoolToStr(GetCurrentThreadId = MainThreadID, True));

  // Uptime applicazione (ms dal boot meno tick di avvio non disponibile qui:
  // riportiamo il tick di sistema come riferimento relativo nei log)
  SL.AddPair('TickCount (ms)', GetTickCount64.ToString);
end;

procedure CollectInjected(SL: TStrings);
var
  s: string;
begin
  if Assigned(OnCollectDbContext) then
  begin
    AppendSeparator(SL, 'CONTESTO DB');
    try
      s := OnCollectDbContext();
    except
      on E: Exception do
        s := '(errore raccolta DB context: ' + E.Message + ')';
    end;
    SL.Add(s);
  end;

  if Assigned(OnCollectAppContext) then
  begin
    AppendSeparator(SL, 'CONTESTO APPLICAZIONE');
    try
      s := OnCollectAppContext();
    except
      on E: Exception do
        s := '(errore raccolta App context: ' + E.Message + ')';
    end;
    SL.Add(s);
  end;
end;

// --- API ------------------------------------------------------------------

function CollectRuntimeContext(AForm: TCustomForm = nil; AControl: TWinControl = nil;
  const AFailedDataSetDump: string = ''): string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    try
      CollectFailedDataSet(SL, AFailedDataSetDump);
    except
    end;
    try
      CollectActiveForm(SL, AForm);
    except
    end;
    try
      CollectFocusedControl(SL, AControl);
    except
    end;
    try
      CollectForms(SL);
    except
    end;
    try
      CollectDataModules(SL);
    except
    end;
    try
      CollectMonitors(SL, AForm);
    except
    end;
    try
      CollectSystem(SL);
    except
    end;
    try
      CollectInjected(SL);
    except
    end;
    result := SL.Text;
  finally
    FreeAndNil(SL);
  end;
end;

function ActiveMonitorBounds(AForm: TCustomForm = nil): TRect;
var
  M: TMonitor;
  F: TCustomForm;
begin
  F := AForm;
  if F = nil then
    F := Screen.ActiveCustomForm;
  M := nil;
  if F <> nil then
    M := Screen.MonitorFromWindow(F.Handle);
  if M = nil then
    M := Screen.PrimaryMonitor;
  result := M.BoundsRect;
end;

end.
