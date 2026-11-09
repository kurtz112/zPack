unit zOffice.Reports.BatchController;

interface

uses
  System.SysUtils,
  System.Classes;

type
  // Contratto del protocollo GEDO usato da WT (TGeDo_ProtocolloController in
  // GeDo.Reports.pas, agganciato da BaseFrm): NON rimuovere. E' il livello
  // "documentale interno di uscita", distinto da TzDocumentActionsController
  // (zOffice.Reports.Controller), che e' il contratto delle azioni
  // documentali verso i viewer.
  TProtocolloController = class abstract(TComponent)
  public
    procedure Inizializza; virtual; abstract;
    function Protocollato: Boolean; virtual; abstract;
    procedure Protocolla; virtual; abstract;
    procedure CheckProtocollato; virtual; abstract;
    procedure Conferma; virtual; abstract;
    procedure Annulla; virtual; abstract;
    procedure Invia(const MetodoInvio: string; InviaTutti: Boolean); virtual; abstract;
    function GetFileNameProtocollo: string; virtual; abstract;
  end;

  TzBatchController = class(TComponent)
  private
    FRecordCount: integer;
    FMax: integer;
    FInitProc: TProc;
    FNextProc: TProc;
    FFileNamePdfFunc: TFunc<string>;
  public
    constructor Create(aOwner: TComponent); override;
    procedure Init;
    procedure Next;
    function FileNamePdf: String;
    function Count: integer;
    procedure AvvisaSeSuperamentoMax;
  public
    property RecordCount: integer read FRecordCount write FRecordCount;
    property Max: integer read FMax write FMax;

    property InitProc: TProc read FInitProc write FInitProc;
    property NextProc: TProc read FNextProc write FNextProc;
    property FileNamePdfFunc: TFunc<string> read FFileNamePdfFunc write FFileNamePdfFunc;
  end;

implementation

uses
  System.Math, Vcl.Dialogs, zMsg;

{ TStampaMultiplaController }

procedure TzBatchController.AvvisaSeSuperamentoMax;
begin
  if Max > 0 then
    if RecordCount > 0 then
      ConfirmOk('Attenzione: verranno stampati solamenti i primi ' + Max.ToString + ' record.');
end;

function TzBatchController.Count: integer;
begin
  if Max > 0 then
    result := Min(Max, RecordCount)
  else
    result := RecordCount;
end;

constructor TzBatchController.Create(aOwner: TComponent);
begin
  inherited;
  FRecordCount := -1;
  FMax := -1;
  FInitProc := nil;
  FNextProc := nil;
  FFileNamePdfFunc := nil;
end;

function TzBatchController.FileNamePdf: String;
begin
  result := '';
  if assigned(FFileNamePdfFunc) then
    result := FileNamePdfFunc;
end;

procedure TzBatchController.Init;
begin
  FRecordCount := -1;
  if assigned(FInitProc) then
    InitProc;
end;

procedure TzBatchController.Next;
begin
  if assigned(FNextProc) then
    NextProc;
end;

end.
