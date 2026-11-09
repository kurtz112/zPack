// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-11
// ---------------------------------------------------------------------------
unit zTranslate.ResourceStrings;

// Sostituzione in memoria del testo delle resourcestring, per RTL, VCL, Data
// e DevExpress.
//
// Il record di una resourcestring (TResStringRec) contiene il modulo e un
// identificativo: sotto 64K e' il numero della risorsa da leggere, sopra e'
// l'indirizzo del testo, che LoadResString restituisce cosi' com'e'.
// PatchResourceString scrive nel record l'indirizzo di un testo conservato
// dalla unit. Vale anche per DevExpress: cxGetResourceString, se la costante
// non e' nella tabella di cxSetResourceString, ricade su LoadResString.
//
// Ripresa da dxItalian.ResourceStrings (rilascio 001, mai integrato), che a sua
// volta sostituiva zBaseLib.ChangeResourceString correggendo il troncamento
// del puntatore in Win64, il testo non conservato e il record lasciato
// modificato dopo la chiusura.

interface

// Sostituisce il testo della resourcestring indicata (@SNomeCostante).
// Il testo viene conservato dalla unit: puo' essere anche una stringa costruita
// in esecuzione. Restituisce False se la pagina di memoria non e' scrivibile.
function PatchResourceString(ResString: PResStringRec; const Value: string): boolean;

// Rimette il testo originale della costante. Restituisce False se non era
// stata sostituita o se la pagina di memoria non e' scrivibile.
function RestoreResourceString(ResString: PResStringRec): boolean;

// Testo originale della costante, quello della libreria linkata, anche dopo
// una sostituzione: serve a confrontare i segnaposto con la traduzione.
function OriginalResourceString(ResString: PResStringRec): string;

function IsResourceStringPatched(ResString: PResStringRec): boolean;

implementation

uses
  Winapi.Windows,
  System.Generics.Collections;

type
  TResourceStringPatch = class
    ResString: PResStringRec;
    OriginalIdentifier: NativeUInt;
    Text: string;
  end;

var
  // Testi in uso e identificativi originali, per tenerli vivi finche' il record
  // punta a loro e per rimettere a posto i record alla chiusura.
  // Un dizionario e non una lista: si traducono migliaia di costanti all'avvio.
  Patches: TObjectDictionary<PResStringRec, TResourceStringPatch>;

function WriteIdentifier(ResString: PResStringRec; Identifier: NativeUInt): boolean;
var
  OldProtect: DWORD;
begin
  // PAGE_EXECUTE_READWRITE e non PAGE_READWRITE: i record possono stare in una
  // pagina che contiene anche codice, e togliere l'esecuzione anche per un
  // istante farebbe cadere un altro thread che la sta eseguendo.
  result := VirtualProtect(ResString, SizeOf(TResStringRec), PAGE_EXECUTE_READWRITE, @OldProtect);

  if result then
  begin
    ResString^.Identifier := Identifier;
    VirtualProtect(ResString, SizeOf(TResStringRec), OldProtect, @OldProtect);
  end;
end;

function PatchResourceString(ResString: PResStringRec; const Value: string): boolean;
var
  Patch: TResourceStringPatch;
  IsNew: boolean;
begin
  result := false;

  if ResString = nil then
    exit;

  // Una seconda traduzione della stessa costante (Translate chiamata due volte)
  // deve ricordare l'identificativo vero, non il puntatore della prima.
  IsNew := not Patches.TryGetValue(ResString, Patch);
  if IsNew then
  begin
    Patch := TResourceStringPatch.Create;
    Patch.ResString := ResString;
    Patch.OriginalIdentifier := ResString^.Identifier;
  end;

  // Il riferimento conservato nell'oggetto tiene vivo il testo anche quando
  // non e' una costante. PChar('') punta comunque a memoria sopra i 64K, quindi
  // LoadResString non lo scambia per un identificativo di risorsa.
  Patch.Text := Value;

  result := WriteIdentifier(ResString, NativeUInt(PChar(Patch.Text)));

  if IsNew then
  begin
    if result then
      Patches.Add(ResString, Patch)
    else
      Patch.Free;
  end;
end;

function RestoreResourceString(ResString: PResStringRec): boolean;
var
  Patch: TResourceStringPatch;
begin
  result := (ResString <> nil) and Patches.TryGetValue(ResString, Patch);

  if not result then
    exit;

  result := WriteIdentifier(ResString, Patch.OriginalIdentifier);

  if result then
    Patches.Remove(ResString);
end;

function OriginalResourceString(ResString: PResStringRec): string;
var
  Patch: TResourceStringPatch;
  Original: TResStringRec;
begin
  if ResString = nil then
    exit('');

  if not Patches.TryGetValue(ResString, Patch) then
    exit(LoadResString(ResString));

  // Copia del record con l'identificativo originale: LoadResString la legge
  // dalla risorsa del modulo senza toccare il record vero.
  Original.Module := ResString^.Module;
  Original.Identifier := Patch.OriginalIdentifier;
  result := LoadResString(@Original);
end;

function IsResourceStringPatched(ResString: PResStringRec): boolean;
begin
  result := (ResString <> nil) and Patches.ContainsKey(ResString);
end;

procedure RestoreAll;
var
  Patch: TResourceStringPatch;
begin
  // Le unit RTL si chiudono dopo questa: se nella loro finalizzazione leggessero
  // una resourcestring ancora rivolta a un testo liberato, leggerebbero memoria
  // non piu' valida. Si rimettono gli identificativi originali prima di liberare.
  for Patch in Patches.Values do
    WriteIdentifier(Patch.ResString, Patch.OriginalIdentifier);
end;

initialization

Patches := TObjectDictionary<PResStringRec, TResourceStringPatch>.Create([doOwnsValues]);

finalization

RestoreAll;
Patches.Free;

end.
