// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-16
// ---------------------------------------------------------------------------
unit zz.PercorsiLunghi;

{
  TzPercorsiLunghi
  ----------------
  Operazioni su file e cartelle che restano valide anche oltre i 260 caratteri
  del vecchio limite MAX_PATH di Windows.

  Le funzioni di System.IOUtils (TFile.Copy, TFile.Exists) e System.SysUtils
  (ForceDirectories) si appoggiano alle API Win32 classiche, che rifiutano i
  percorsi piu' lunghi di 260 caratteri restituendo ERROR_PATH_NOT_FOUND:
  l'utente vede "Impossibile trovare il percorso specificato" anche quando il
  file c'e' e la cartella esiste.

  Qui il percorso viene riscritto con il prefisso esteso di Windows prima di
  arrivare all'API: "\\?\" per i dischi locali, "\\?\UNC\" per le condivisioni
  di rete. Con quel prefisso il limite sale a circa 32.000 caratteri, senza
  dipendere dal criterio di gruppo "Enable Win32 long paths" ne' dal manifesto
  dell'applicazione, che sulle macchine dei clienti non si controllano.

  Attenzione: il prefisso esteso disattiva la normalizzazione del percorso da
  parte di Windows. I percorsi passati devono essere assoluti e non contenere
  i segmenti "." e "..".
}

interface

type
  TzPercorsiLunghi = class
  private const
    PrefissoLocale = '\\?\';
    PrefissoRete = '\\?\UNC\';
  private
    class function EAssoluto(const Percorso: string): Boolean; static;
    class function ERadice(const Percorso: string): Boolean; static;
  public
    // Restituisce il percorso preceduto dal prefisso esteso, pronto per le API Win32.
    class function Esteso(const Percorso: string): string; static;

    class function FileEsiste(const NomeFile: string): Boolean; static;
    class function CartellaEsiste(const Cartella: string): Boolean; static;

    // Crea la cartella e tutte le cartelle intermedie mancanti.
    class function ForzaCartelle(const Cartella: string): Boolean; static;

    // Copia il file sollevando l'errore di sistema in caso di esito negativo,
    // come fa TFile.Copy.
    class procedure CopiaFile(const Origine, Destinazione: string; const SovrascriviEsistente: Boolean = False); static;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  System.IOUtils;

{ TzPercorsiLunghi }

class function TzPercorsiLunghi.EAssoluto(const Percorso: string): Boolean;
begin
  Result := Percorso.StartsWith('\\') or ((Length(Percorso) >= 3) and (Percorso[2] = ':') and (Percorso[3] = '\'));
end;

class function TzPercorsiLunghi.ERadice(const Percorso: string): Boolean;
var
  Resto: string;
begin
  if Percorso.StartsWith('\\') then
  begin
    // \\server\condivisione e' una radice e non si puo' creare;
    // \\server\condivisione\cartella no.
    Resto := Percorso.Substring(2);
    Result := Resto.CountChar('\') <= 1;
  end
  else
    // C: oppure C:\
    Result := Length(ExcludeTrailingPathDelimiter(Percorso)) <= 2;
end;

class function TzPercorsiLunghi.Esteso(const Percorso: string): string;
begin
  Result := Percorso;

  if Result = '' then
    exit;

  if Result.StartsWith(PrefissoLocale) then
    exit;

  Result := Result.Replace('/', '\', [rfReplaceAll]);

  // Un percorso relativo va risolto prima, perche' il prefisso esteso ammette
  // solo percorsi assoluti. Un percorso relativo resta comunque ben sotto i
  // 260 caratteri, quindi la risoluzione non puo' fallire per lunghezza.
  if not EAssoluto(Result) then
    Result := TPath.GetFullPath(Result);

  if Result.StartsWith('\\') then
    Result := PrefissoRete + Result.Substring(2)
  else
    Result := PrefissoLocale + Result;
end;

class function TzPercorsiLunghi.FileEsiste(const NomeFile: string): Boolean;
var
  Attributi: Cardinal;
begin
  if NomeFile = '' then
    exit(False);

  Attributi := GetFileAttributes(PChar(Esteso(NomeFile)));

  Result := (Attributi <> INVALID_FILE_ATTRIBUTES) and ((Attributi and FILE_ATTRIBUTE_DIRECTORY) = 0);
end;

class function TzPercorsiLunghi.CartellaEsiste(const Cartella: string): Boolean;
var
  Attributi: Cardinal;
begin
  if Cartella = '' then
    exit(False);

  Attributi := GetFileAttributes(PChar(Esteso(ExcludeTrailingPathDelimiter(Cartella))));

  Result := (Attributi <> INVALID_FILE_ATTRIBUTES) and ((Attributi and FILE_ATTRIBUTE_DIRECTORY) <> 0);
end;

class function TzPercorsiLunghi.ForzaCartelle(const Cartella: string): Boolean;
var
  Normalizzata: string;
  Padre: string;
begin
  if Cartella = '' then
    exit(False);

  Normalizzata := ExcludeTrailingPathDelimiter(Cartella.Replace('/', '\', [rfReplaceAll]));

  if not EAssoluto(Normalizzata) then
    Normalizzata := ExcludeTrailingPathDelimiter(TPath.GetFullPath(Normalizzata));

  if CartellaEsiste(Normalizzata) then
    exit(True);

  // Sulla radice (C:\ oppure \\server\condivisione) non si sale oltre: se non
  // esiste, il problema e' di collegamento o di permessi, non di lunghezza.
  if ERadice(Normalizzata) then
    exit(False);

  Padre := ExcludeTrailingPathDelimiter(ExtractFilePath(Normalizzata));

  if (Padre = '') or SameText(Padre, Normalizzata) then
    exit(False);

  if not ForzaCartelle(Padre) then
    exit(False);

  Result := CreateDirectory(PChar(Esteso(Normalizzata)), nil);

  if not Result then
    Result := GetLastError = ERROR_ALREADY_EXISTS;
end;

class procedure TzPercorsiLunghi.CopiaFile(const Origine, Destinazione: string; const SovrascriviEsistente: Boolean = False);
begin
  if not CopyFile(PChar(Esteso(Origine)), PChar(Esteso(Destinazione)), not SovrascriviEsistente) then
    RaiseLastOSError;
end;

end.
