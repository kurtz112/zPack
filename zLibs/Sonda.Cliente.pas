// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-17
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Cliente
//
// Il lato di chi interroga la sonda (zMCP_App, programmi di collaudo): si
// collega alla named pipe, manda una richiesta per riga e aspetta la
// risposta con un tempo massimo. Mai un'attesa senza fine: se la sonda non
// risponde, la chiamata solleva e chi chiama decide (di solito chiude il
// processo).
//
// Solo RTL e Winapi: si usa da un programma a console.
//
// ***************************************************************************

unit Sonda.Cliente;

interface

uses
  System.SysUtils,
  System.JSON,
  System.SyncObjs,
  Winapi.Windows;

type
  EClienteSonda = class(Exception);

  TClienteSonda = class
  private
    FNomePipe: string;
    FPipe: THandle;
    FProssimoId: Int64;
    FBlocco: TCriticalSection;
    function Attendi(var Sovrapposto: TOverlapped; out Trasferiti: DWORD; TempoMs: Cardinal): Boolean;
    procedure Scrivi(const Dati: TBytes; TempoMs: Cardinal);
    function LeggiRiga(TempoMs: Cardinal): TBytes;
  public
    constructor Create(const Nome: string);
    destructor Destroy; override;
    // Riprova finche' la pipe esiste, il processo e' vivo e il tempo non e'
    // scaduto. Processo = 0: non controlla il processo.
    function Connetti(TempoMs: Cardinal; Processo: THandle): Boolean;
    procedure Chiudi;
    function Collegato: Boolean;
    // Argomenti passa alla richiesta e viene liberato qui (anche nil).
    // TempoMs: quanto aspettare la risposta, oltre l'attesa chiesta alla sonda.
    function Richiesta(const Comando: string; Argomenti: TJSONObject; TempoMs: Cardinal): TJSONObject;
  end;

implementation

uses
  System.Classes,
  Sonda.Protocollo;

constructor TClienteSonda.Create(const Nome: string);
begin
  inherited Create;
  FNomePipe := NomePipeSonda(Nome);
  FPipe := INVALID_HANDLE_VALUE;
  FBlocco := TCriticalSection.Create;
end;

destructor TClienteSonda.Destroy;
begin
  Chiudi;
  FBlocco.Free;
  inherited;
end;

function TClienteSonda.Collegato: Boolean;
begin
  Result := FPipe <> INVALID_HANDLE_VALUE;
end;

procedure TClienteSonda.Chiudi;
begin
  if FPipe <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FPipe);
    FPipe := INVALID_HANDLE_VALUE;
  end;
end;

function TClienteSonda.Connetti(TempoMs: Cardinal; Processo: THandle): Boolean;
var
  Scadenza: UInt64;
begin
  Chiudi;
  Scadenza := GetTickCount64 + TempoMs;
  repeat
    FPipe := CreateFile(PChar(FNomePipe), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING,
      FILE_FLAG_OVERLAPPED, 0);
    if FPipe <> INVALID_HANDLE_VALUE then
      Exit(True);
    // la sonda serve un client per volta: ERROR_PIPE_BUSY vuol dire che un
    // altro e' collegato, e si aspetta come per una pipe non ancora creata
    if (Processo <> 0) and (WaitForSingleObject(Processo, 0) = WAIT_OBJECT_0) then
      Exit(False);
    Sleep(100);
  until GetTickCount64 >= Scadenza;
  Result := False;
end;

function TClienteSonda.Attendi(var Sovrapposto: TOverlapped; out Trasferiti: DWORD; TempoMs: Cardinal): Boolean;
begin
  Trasferiti := 0;
  if WaitForSingleObject(Sovrapposto.hEvent, TempoMs) = WAIT_OBJECT_0 then
    Exit(GetOverlappedResult(FPipe, Sovrapposto, Trasferiti, False));
  CancelIoEx(FPipe, @Sovrapposto);
  GetOverlappedResult(FPipe, Sovrapposto, Trasferiti, True);
  Result := False;
end;

procedure TClienteSonda.Scrivi(const Dati: TBytes; TempoMs: Cardinal);
var
  Sovrapposto: TOverlapped;
  Scritti: DWORD;
  Inviati: Integer;
begin
  Inviati := 0;
  FillChar(Sovrapposto, SizeOf(Sovrapposto), 0);
  Sovrapposto.hEvent := CreateEvent(nil, True, False, nil);
  try
    while Inviati < Length(Dati) do
    begin
      ResetEvent(Sovrapposto.hEvent);
      if not WriteFile(FPipe, Dati[Inviati], Length(Dati) - Inviati, Scritti, @Sovrapposto) then
      begin
        if GetLastError <> ERROR_IO_PENDING then
          raise EClienteSonda.CreateFmt('Scrittura verso la sonda fallita: %s', [SysErrorMessage(GetLastError)]);
        if not Attendi(Sovrapposto, Scritti, TempoMs) then
          raise EClienteSonda.Create('Scrittura verso la sonda non conclusa nel tempo massimo.');
      end;
      Inc(Inviati, Scritti);
    end;
  finally
    CloseHandle(Sovrapposto.hEvent);
  end;
end;

function TClienteSonda.LeggiRiga(TempoMs: Cardinal): TBytes;
var
  Buffer: TBytes;
  Accumulo: TBytesStream;
  Sovrapposto: TOverlapped;
  Letti: DWORD;
  Posizione: Integer;
  Scadenza: UInt64;
  Residuo: Int64;
begin
  SetLength(Buffer, 65536);
  Accumulo := TBytesStream.Create;
  FillChar(Sovrapposto, SizeOf(Sovrapposto), 0);
  Sovrapposto.hEvent := CreateEvent(nil, True, False, nil);
  Scadenza := GetTickCount64 + TempoMs;
  try
    while True do
    begin
      Residuo := Int64(Scadenza) - Int64(GetTickCount64);
      if Residuo <= 0 then
        raise EClienteSonda.CreateFmt('La sonda non ha risposto in %d ms.', [TempoMs]);
      ResetEvent(Sovrapposto.hEvent);
      if not ReadFile(FPipe, Buffer[0], Length(Buffer), Letti, @Sovrapposto) then
      begin
        if GetLastError <> ERROR_IO_PENDING then
          raise EClienteSonda.CreateFmt('Lettura dalla sonda fallita (programma chiuso?): %s',
            [SysErrorMessage(GetLastError)]);
        if not Attendi(Sovrapposto, Letti, Residuo) then
          raise EClienteSonda.CreateFmt('La sonda non ha risposto in %d ms.', [TempoMs]);
      end;
      for Posizione := 0 to Integer(Letti) - 1 do
        if Buffer[Posizione] = 10 then
        begin
          Accumulo.WriteBuffer(Buffer[0], Posizione);
          Exit(Copy(Accumulo.Bytes, 0, Accumulo.Size));
        end;
      Accumulo.WriteBuffer(Buffer[0], Letti);
    end;
  finally
    CloseHandle(Sovrapposto.hEvent);
    Accumulo.Free;
  end;
end;

function TClienteSonda.Richiesta(const Comando: string; Argomenti: TJSONObject; TempoMs: Cardinal): TJSONObject;
var
  Messaggio: TJSONObject;
  Id: Int64;
begin
  FBlocco.Enter;
  try
    if not Collegato then
    begin
      Argomenti.Free;
      raise EClienteSonda.Create('Non collegato alla sonda.');
    end;
    Inc(FProssimoId);
    Id := FProssimoId;
    Messaggio := TJSONObject.Create;
    try
      Messaggio.AddPair('id', TJSONNumber.Create(Id));
      Messaggio.AddPair('comando', Comando);
      if Argomenti <> nil then
        Messaggio.AddPair('argomenti', Argomenti);
      Scrivi(RigaDaJson(Messaggio), TempoMs);
    finally
      Messaggio.Free;
    end;
    try
      Result := JsonDaRiga(LeggiRiga(TempoMs));
    except
      // dopo una risposta persa la pipe e' fuori sincronia: meglio
      // ricollegarsi che leggere la risposta di un'altra richiesta
      Chiudi;
      raise;
    end;
    if Result = nil then
      raise EClienteSonda.Create('Risposta della sonda non valida.');
  finally
    FBlocco.Leave;
  end;
end;

end.
