// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-01
// ---------------------------------------------------------------------------
unit zSystem.Patcher;

// ==============================================================================
// Applicazione di una patch JSON (zCollection.Patcher) al dizionario LZ caricato
// da TzSystem, riservata all'amministratore.
//
// Sequenza: lettura del testo (file o appunti) -> verifica completa con
// annullamento -> anteprima dell'esito -> applicazione -> salvataggio delle
// sole collection toccate con SaveZip, che fa anche la copia di sicurezza
// dell'archivio e scrive la riga nel registro Log.txt.
//
// Gli esiti finali (non applicabile, applicata, non applicata) sono finestre
// di messaggio con l'icona di errore o di informazione, non memo da scorrere:
// il resoconto completo si apre solo su richiesta.
//
// Uso tipico da due azioni di menù:
//   ApplyPatchFromFile(Config.zSystem);
//   ApplyPatchFromClipboard(Config.zSystem);
//
// Terza via, il trascinamento di un file sulla finestra principale: la form
// abilita la ricezione con AcceptPatchDrop e inoltra WM_DROPFILES a
// ApplyPatchFromDrop, che avvia lo stesso flusso della voce "Da file".
//
// Le collection ammesse e il risolutore stanno in zSystem.Collections, senza
// interfaccia grafica, perché li usano anche i programmi senza finestre.
// ==============================================================================

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.SysUtils,
  zSystem;

// Chiede il file .json, verifica, mostra l'anteprima e, confermata, applica e salva.
procedure ApplyPatchFromFile(zSystem: TzSystem);

// Come ApplyPatchFromFile, ma il file è già scelto (percorso completo).
procedure ApplyPatchFile(zSystem: TzSystem; const FileName: string);

// Come ApplyPatchFromFile, ma il testo della patch è quello negli appunti.
procedure ApplyPatchFromClipboard(zSystem: TzSystem);

// Nucleo comune: Source compare nei messaggi (nome del file o "appunti").
procedure ApplyPatchText(zSystem: TzSystem; const JsonText: string; const Source: string);

// Abilita sulla finestra il trascinamento di file da Esplora risorse, solo se
// l'utente è amministratore. Da richiamare alla creazione della finestra e dopo
// ogni accesso, perché l'amministratore si riconosce solo dopo il login.
procedure AcceptPatchDrop(zSystem: TzSystem; WindowHandle: HWND);

// Da chiamare dal gestore di WM_DROPFILES della finestra principale: ogni file
// .json trascinato segue il flusso di ApplyPatchFile, gli altri vengono
// segnalati. Rilascia sempre il gestore del trascinamento (DragFinish) prima
// di aprire le finestre di conferma, che sono modali.
procedure ApplyPatchFromDrop(zSystem: TzSystem; Drop: HDROP);

implementation

uses
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  dxShellDialogs,
  zCollection,
  zCollection.Patcher,
  zMemoDialog,
  zMsg,
  zSystem.Collections;

const
  // Operazioni da correggere elencate nella finestra di errore; le altre restano nel resoconto completo.
  MaxProblemsShown = 8;

procedure SaveTouchedCollections(zSystem: TzSystem; Patch: TzCollectionPatch);
var
  Touched: TArray<TzCustomCollection>;
  Collection: TzCustomCollection;
  Entry: TLzCollection;
  Scopes: TList<TCollection2Save>;
  Scope: TCollection2Save;
  LogMessage: string;
begin
  LogMessage := 'Patch ' + Patch.Id;
  if Patch.Ticket <> '' then
    LogMessage := LogMessage + ' (ticket ' + Patch.Ticket + ')';
  if Patch.Description <> '' then
    LogMessage := LogMessage + ': ' + Patch.Description;

  Touched := Patch.TouchedCollections;

  Scopes := TList<TCollection2Save>.Create;
  try
    for Collection in Touched do
      for Entry in LzCollections(zSystem) do
        if (Entry.Collection = Collection) and not Scopes.Contains(Entry.SaveScope) then
          Scopes.Add(Entry.SaveScope);

    // una chiamata per voce: si riscrivono solo i membri toccati dell'archivio
    for Scope in Scopes do
      zSystem.SaveZip(Scope, LogMessage);
  finally
    Scopes.Free;
  end;
end;

// Mostra il resoconto; True se l'utente conferma con OK.
function ShowReport(const Caption, Text: string): Boolean;
var
  ReportText: string;
begin
  ReportText := Text;
  Result := zExecuteMemoDialog(ReportText, Caption, nil, nil, True);
end;

procedure ApplyPatchText(zSystem: TzSystem; const JsonText: string; const Source: string);
var
  Patch: TzCollectionPatch;
  Resolver: TzCollectionResolver;
  Verified: Boolean;
begin
  // doppio controllo: la voce di menù è già nascosta, ma la funzione è pubblica
  if not zSystem.IsAdmin then
    raise EzCollectionPatchError.Create('Le patch del dizionario LZ può applicarle solo un amministratore.');

  if not FileExists(zSystem.FileName) then
    raise EzCollectionPatchError.CreateFmt('L''archivio %s non esiste: non c''è un dizionario da correggere.', [zSystem.FileName]);

  Patch := TzCollectionPatch.Create(JsonText);
  try
    if not SameText(Patch.ApplicationName, zSystem.AppName) then
      raise EzCollectionPatchError.CreateFmt('La patch %s è scritta per "%s", questo programma è "%s".', [Patch.Id, Patch.ApplicationName, zSystem.AppName]);

    Resolver := LzCollectionResolver(zSystem);

    Verified := Patch.Verify(Resolver);

    if not Verified then
    begin
      if ConfirmYesNo('Patch ' + Patch.Id + ' NON APPLICABILE (' + Source + ').' + sLineBreak + 'Il dizionario non è stato modificato.' + sLineBreak + sLineBreak + Patch.ProblemsSummary(MaxProblemsShown) + sLineBreak + 'Aprire il resoconto completo?', mtError) then
        ShowReport('Patch non applicabile (' + Source + ')', Patch.Report + sLineBreak + 'Il dizionario non è stato modificato.' + sLineBreak + 'Collection ammesse: ' + LzCollectionNames(zSystem));
      Exit;
    end;

    if not Patch.HasChanges then
    begin
      ConfirmOk('La patch ' + Patch.Id + ' è già applicata: niente da fare.', mtInformation);
      Exit;
    end;

    if not ShowReport('Anteprima patch (' + Source + ') - OK per applicare e salvare', Patch.Report) then
      Exit;

    // Apply rifà ogni controllo: se qualcosa non torna annulla tutto e solleva
    Patch.Apply(Resolver);
    SaveTouchedCollections(zSystem, Patch);

    ConfirmOk('Patch ' + Patch.Id + ' applicata e salvata.' + sLineBreak + sLineBreak + 'Esito: ' + Patch.OutcomeText + '.' + sLineBreak + 'Archivio salvato, con copia di sicurezza del giorno.' + sLineBreak + 'Le finestre già aperte usano ancora le impostazioni precedenti: chiuderle e riaprirle.', mtInformation);
  finally
    Patch.Free;
  end;
end;

procedure ShowFailure(E: Exception);
begin
  ConfirmOk('Patch non applicata.' + sLineBreak + sLineBreak + E.Message, mtError);
end;

procedure ApplyPatchFromFile(zSystem: TzSystem);
var
  Dialog: TdxOpenFileDialog;
  FileName: string;
begin
  Dialog := TdxOpenFileDialog.Create(nil);
  try
    Dialog.DefaultExt := 'json';
    Dialog.Filter := 'Patch dizionario LZ (*.json)|*.json|Tutti i file (*.*)|*.*';
    Dialog.Title := 'Patch del dizionario LZ';

    if not Dialog.Execute then
      Exit;

    FileName := Dialog.FileName;
  finally
    Dialog.Free;
  end;

  ApplyPatchFile(zSystem, FileName);
end;

procedure ApplyPatchFile(zSystem: TzSystem; const FileName: string);
var
  JsonText: string;
begin
  try
    try
      // UTF-8 con o senza BOM; un file in altra codifica fa sollevare EEncodingError
      JsonText := TFile.ReadAllText(FileName, TEncoding.UTF8);
    except
      on E: EEncodingError do
        raise EzCollectionPatchError.CreateFmt('Il file %s non è in UTF-8.', [FileName]);
    end;

    ApplyPatchText(zSystem, JsonText, ExtractFileName(FileName));
  except
    on E: Exception do
      ShowFailure(E);
  end;
end;

procedure AcceptPatchDrop(zSystem: TzSystem; WindowHandle: HWND);
begin
  DragAcceptFiles(WindowHandle, zSystem.IsAdmin);
end;

procedure ApplyPatchFromDrop(zSystem: TzSystem; Drop: HDROP);
var
  FileNames: TStringList;
  FileName: string;
  Buffer: string;
  FileCount: Integer;
  NameLength: Integer;
  Index: Integer;
begin
  FileNames := TStringList.Create;
  try
    // si copiano i nomi e si rilascia subito il trascinamento: le finestre che
    // seguono sono modali e non devono tenere occupato Esplora risorse
    try
      FileCount := DragQueryFile(Drop, $FFFFFFFF, nil, 0);

      for Index := 0 to FileCount - 1 do
      begin
        NameLength := DragQueryFile(Drop, Index, nil, 0);
        SetLength(Buffer, NameLength);
        DragQueryFile(Drop, Index, PChar(Buffer), NameLength + 1);
        FileNames.Add(Buffer);
      end;
    finally
      DragFinish(Drop);
    end;

    // la ricezione è abilitata solo all'amministratore; il controllo si ripete
    // perché la patch riscrive l'archivio LZ della postazione
    if not zSystem.IsAdmin then
      Exit;

    for FileName in FileNames do
    begin
      if SameText(ExtractFileExt(FileName), '.json') then
        ApplyPatchFile(zSystem, FileName)
      else
        ConfirmOk('Il file ' + ExtractFileName(FileName) + ' non è una patch del dizionario LZ: serve un file .json nel formato zCollection.Patch.', mtInformation);
    end;
  finally
    FileNames.Free;
  end;
end;

procedure ApplyPatchFromClipboard(zSystem: TzSystem);
var
  JsonText: string;
begin
  try
    JsonText := Clipboard.AsText;

    if Trim(JsonText) = '' then
      raise EzCollectionPatchError.Create('Negli appunti non c''è testo: copiare prima il JSON della patch.');

    ApplyPatchText(zSystem, JsonText, 'appunti');
  except
    on E: Exception do
      ShowFailure(E);
  end;
end;

end.
