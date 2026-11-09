// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-28
// ---------------------------------------------------------------------------

// Implementazione su Firebird di IMantisSegnalazioniStore.
//
// Riceve dall'applicazione connessione, transazioni e utente corrente: non
// dipende da ConfigModule ne' da altre unit applicative, cosi' la stessa
// classe serve a WT e a Gesty. Tabella MANTIS_SEGNALAZIONI, vista
// MANTIS_SEGNALAZIONI_ELENCO e procedure MANTIS_SEGNALAZIONI_ADD,
// MANTIS_SEGNALAZIONI_AGGIORNA, MANTIS_SEGNALAZIONI_VISTO: script
// 04-mantis-segnalazioni.sql della consegna.
//
// Va usata solo dal thread principale: la connessione e' quella
// dell'applicazione.

unit Mantis.Segnalazioni.Store;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Comp.Client,
  Mantis.Segnalazioni.Types;

type
  TMantisSegnalazioniStoreFirebird = class(TInterfacedObject, IMantisSegnalazioniStore)
  private
    FConnection: TFDConnection;
    FReadTrans: TFDCustomTransaction;
    FWriteTrans: TFDCustomTransaction;
    FUsrId: Integer;
    FNomeUtente: string;
  public
    constructor Create(AConnection: TFDConnection; AReadTrans, AWriteTrans: TFDCustomTransaction; AUsrId: Integer; const ANomeUtente: string);
    function Elenco: TArray<TMantisSegnalazioneLocale>;
    procedure Registra(AIdTicket: Integer; const AOggetto: string);
    procedure Aggiorna(AIdTicket: Integer; const AStato, AAssegnatoA: string; AAggiornatoIl: TDateTime);
    procedure Visto(AIdTicket: Integer);
    function NomeUtente: string;
  end;

implementation

uses
  Data.DB,
  zFbDataSet;

{ TMantisSegnalazioniStoreFirebird }

constructor TMantisSegnalazioniStoreFirebird.Create(AConnection: TFDConnection; AReadTrans, AWriteTrans: TFDCustomTransaction; AUsrId: Integer; const ANomeUtente: string);
begin
  inherited Create;
  FConnection := AConnection;
  FReadTrans := AReadTrans;
  FWriteTrans := AWriteTrans;
  FUsrId := AUsrId;
  FNomeUtente := ANomeUtente;
end;

function TMantisSegnalazioniStoreFirebird.NomeUtente: string;
begin
  Result := FNomeUtente;
end;

function TMantisSegnalazioniStoreFirebird.Elenco: TArray<TMantisSegnalazioneLocale>;
var
  DataSet: TzFbDataSet;
  Segnalazione: TMantisSegnalazioneLocale;
begin
  Result := [];
  DataSet := CreateFbDataSet(nil, FConnection, FReadTrans, FWriteTrans, True);
  try
    DataSet.SelectSQL.Text :=
      'SELECT' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.ID_TICKET,' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.DATA_APERTURA,' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.OGGETTO,' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.STATO,' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.ASSEGNATO_A,' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.AGGIORNATO_IL,' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.ULTIMO_AGGIORNAMENTO_VISTO' + sLineBreak +
      'FROM' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO' + sLineBreak +
      'WHERE' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.USER_ID = :USER_ID' + sLineBreak +
      'ORDER BY' + sLineBreak +
      '    MANTIS_SEGNALAZIONI_ELENCO.DATA_APERTURA DESC';
    DataSet.ParamByName('USER_ID').AsInteger := FUsrId;
    DataSet.Active := True;

    while not DataSet.Eof do
    begin
      Segnalazione := Default (TMantisSegnalazioneLocale);
      Segnalazione.IdTicket := DataSet.FieldByName('ID_TICKET').AsInteger;
      Segnalazione.DataApertura := DataSet.FieldByName('DATA_APERTURA').AsDateTime;
      Segnalazione.Oggetto := DataSet.FieldByName('OGGETTO').AsString;
      Segnalazione.Stato := DataSet.FieldByName('STATO').AsString;
      Segnalazione.AssegnatoA := DataSet.FieldByName('ASSEGNATO_A').AsString;
      Segnalazione.AggiornatoIl := DataSet.FieldByName('AGGIORNATO_IL').AsDateTime;
      Segnalazione.UltimoAggiornamentoVisto := DataSet.FieldByName('ULTIMO_AGGIORNAMENTO_VISTO').AsDateTime;
      Result := Result + [Segnalazione];
      DataSet.Next;
    end;
    DataSet.Active := False;
  finally
    FreeAndNil(DataSet);
  end;
end;

procedure TMantisSegnalazioniStoreFirebird.Registra(AIdTicket: Integer; const AOggetto: string);
begin
  FConnection.ExecSQL('EXECUTE PROCEDURE MANTIS_SEGNALAZIONI_ADD(:USER_ID, :ID_TICKET, :OGGETTO)', [FUsrId, AIdTicket, AOggetto]);
end;

procedure TMantisSegnalazioniStoreFirebird.Aggiorna(AIdTicket: Integer; const AStato, AAssegnatoA: string; AAggiornatoIl: TDateTime);
begin
  FConnection.ExecSQL('EXECUTE PROCEDURE MANTIS_SEGNALAZIONI_AGGIORNA(:ID_TICKET, :STATO, :ASSEGNATO_A, :AGGIORNATO_IL)', [AIdTicket, AStato, AAssegnatoA, AAggiornatoIl]);
end;

procedure TMantisSegnalazioniStoreFirebird.Visto(AIdTicket: Integer);
begin
  FConnection.ExecSQL('EXECUTE PROCEDURE MANTIS_SEGNALAZIONI_VISTO(:ID_TICKET)', [AIdTicket]);
end;

end.
