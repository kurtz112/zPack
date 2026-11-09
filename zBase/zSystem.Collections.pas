// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-02
// ---------------------------------------------------------------------------
unit zSystem.Collections;

// ==============================================================================
// Le collection dell'archivio LZ caricato da TzSystem, ciascuna con la voce di
// SaveZip che la salva.
//
// Unit senza interfaccia grafica: la usano sia zSystem.Patcher (applicazione
// delle patch dall'applicazione) sia i programmi senza finestre che leggono o
// verificano il dizionario (server MCP, console). Così l'elenco vive in un
// posto solo invece di essere ricopiato in ogni programma.
//
// Il nome di una collection è il suo nome di classe (TzDataSets, TzDbViews, ...),
// lo stesso del membro dell'archivio (TzDataSets.dfm/.json) e del campo
// "collection" delle patch JSON.
//
// MetaData resta fuori: è la fotografia del catalogo del database, non un
// insieme di voci da leggere o correggere una per una.
// ==============================================================================

interface

uses
  System.SysUtils,
  zCollection,
  zCollection.Patcher,
  zSystem;

type
  TLzCollection = record
    Collection: TzCustomCollection;
    SaveScope: TCollection2Save;
  end;

// Elenco esplicito, lo stesso di TzSystem.LoadZip: le altre collection di
// TzSystem (connessioni, FTP) vivono altrove e non devono mai essere toccate.
function LzCollections(zSystem: TzSystem): TArray<TLzCollection>;

// Collection dato il nome di classe, senza distinzione fra maiuscole e minuscole; nil se sconosciuta.
function FindLzCollection(zSystem: TzSystem; const CollectionName: string): TzCustomCollection;

// Nomi di classe separati da virgola, per i messaggi ("Collection ammesse: ...").
function LzCollectionNames(zSystem: TzSystem): string;

// Risolutore per TzCollectionPatch.Verify/Apply sulle collection dell'archivio.
function LzCollectionResolver(zSystem: TzSystem): TzCollectionResolver;

implementation

function LzCollection(Collection: TzCustomCollection; const SaveScope: TCollection2Save): TLzCollection;
begin
  Result.Collection := Collection;
  Result.SaveScope := SaveScope;
end;

function LzCollections(zSystem: TzSystem): TArray<TLzCollection>;
begin
  Result := [
    LzCollection(zSystem.zDataDictionary, csDataDictionary),
    LzCollection(zSystem.zDataModules, csDataModules),
    LzCollection(zSystem.zLookups, csLookups),
    LzCollection(zSystem.zStoredProcs, csStoredProcs),
    LzCollection(zSystem.zGenerators, csGenerators),
    LzCollection(zSystem.zDataSets, csDataSets),
    LzCollection(zSystem.zDbViews, csDbViews),
    LzCollection(zSystem.zDbCards, csDbCards),
    LzCollection(zSystem.zDbPivots, csDbPivots),
    LzCollection(zSystem.zDbRecordViews, csDbRecordViews),
    LzCollection(zSystem.zDbTrees, csDbTrees),
    LzCollection(zSystem.zDbCharts, csDbCharts),
    LzCollection(zSystem.zDbSchedulers, csDbSchedulers),
    LzCollection(zSystem.zFiles, csFiles),
    LzCollection(zSystem.zPickLists, csPickLists),
    LzCollection(zSystem.zForms, csForms),
    LzCollection(zSystem.zWizards, csWizards),
    LzCollection(zSystem.zCubes, csCubes),
    LzCollection(zSystem.zMaps, csMaps),
    LzCollection(zSystem.zTatukMaps, csMaps),
    LzCollection(zSystem.zTips, csTips)];
end;

function FindCollectionIn(const Collections: TArray<TLzCollection>; const CollectionName: string): TzCustomCollection;
var
  Entry: TLzCollection;
begin
  Result := nil;
  for Entry in Collections do
    if SameText(Entry.Collection.ClassName, CollectionName) then
      Exit(Entry.Collection);
end;

function FindLzCollection(zSystem: TzSystem; const CollectionName: string): TzCustomCollection;
begin
  Result := FindCollectionIn(LzCollections(zSystem), CollectionName);
end;

function LzCollectionNames(zSystem: TzSystem): string;
var
  Entry: TLzCollection;
begin
  Result := '';
  for Entry in LzCollections(zSystem) do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + Entry.Collection.ClassName;
  end;
end;

function LzCollectionResolver(zSystem: TzSystem): TzCollectionResolver;
var
  Collections: TArray<TLzCollection>;
begin
  // l'elenco si fotografa una volta: Verify e Apply chiamano il risolutore per ogni operazione
  Collections := LzCollections(zSystem);

  Result :=
    function(const CollectionName: string): TzCustomCollection
    begin
      Result := FindCollectionIn(Collections, CollectionName);
    end;
end;

end.
