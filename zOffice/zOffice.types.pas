unit zOffice.Types;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  IdMessage,
  dxRichEdit.NativeApi,
  dxRichEdit.Utils.UriStreamService,
  dxRichEdit.Control,
  dxSpreadSheet,
  dxBar,
  zOffice.Reports.ActionsBarHelper, // TzDocumentActionsBarHelper (hook azioni)
  zOffice.Reports.Progress, // IzReportProgress (avanzamento + annullamento)
  zOffice.Word.UriStreamProvider;

type
  // DEFINIRE DefaultFileTypes per inizializzare

  // \\--- procedure ViewFile(const FileName: string; const ReadOnly: Boolean = false);
  // \\--- procedure ViewFileImage(const FileName: string; const ReadOnly: Boolean = false);
  // \\ zOffice [implementare viewer e form]
  // \\ zOffice.Mail.Editor // per ImageIndex; servono altre icone
  // \\ zOffice.Mail.Utils  // sembra ok
  // \\ zSystem, classe TDbFile: aggiungere TzFileTypes
  // --- xml, json, txt
  TzFileType = (ftNone, ftPdf, ftWord, ftExcel, ftImage, ftMail, ftTXT, ftXML, ftJSON);
  TzFileTypes = set of TzFileType;

const
  zAllFileTypes: TzFileTypes = [ftPdf, ftWord, ftExcel, ftImage, ftMail, ftTXT, ftXML, ftJSON];

type
  TzFileTypeHelper = record helper for TzFileType
  private
    function GetAsString: string;
    procedure SetAsString(const Value: string);
  public
    class function FromFileName(const FileName: string): TzFileType; static;
    function ImageIndex(): integer;
    property AsString: string read GetAsString write SetAsString;
  end;

  TzPdfFontEmbedding = (zfeNone, zfeFull, zfeSubset);

  TzPdfFontEmbeddingHelper = record helper for TzPdfFontEmbedding
  public
    function Description: string;
    function ToString: string;
    class function FromString(const s: String): TzPdfFontEmbedding; static;
  end;

  TzOfficeVariable = record
  private
    function Separator: char;
  private
    FVariableName: string;
    function GetDataSetName: string;
    function GetFieldName: string;
  public
    procedure Init; overload;
    procedure Init(const VariableName: string); overload;
    procedure Init(const DataSetName, FieldName: string); overload;
  public
    property VariableName: string read FVariableName;
    property DataSetName: string read GetDataSetName;
    property FieldName: string read GetFieldName;
  end;

  TPdfParams = record
  public type
    TMethodToGetFileName = (mgfDialog, mgfFileName, mgfFieldName, mgfTempFile);
  public
    procedure Init;
    procedure Assign(src: TPdfParams);
  public
    Method: TMethodToGetFileName;
    FieldName: String;
    FileName: String;
    FontEmbedding: TzPdfFontEmbedding;
    OpenFileAfterExport: boolean;
    ShowMessageAfterExport: boolean;
    AfterExportProc: TProc<string>;
  end;

  TWordFragment = record
  private
    FTemplateFileName: string;
    procedure SetTemplateFileName(const Value: string);
  public
    VariableName: string;

    DataSetName: string;

    property TemplateFileName: string read FTemplateFileName write
        SetTemplateFileName;
  end;

  // Azioni documentali (Firma/Protocolla/Conserva/InviaPec/InviaMail):
  // hook assegnato dal ReportsManager e invocato dal viewer alla sua apertura.
  // Il viewer porta a mano nel DFM il gruppo "Documento" (TdxBar + bottoni +
  // TAction); qui riceve l'helper (presenter) da agganciare all'OnUpdate e
  // all'OnExecute di quelle azioni. Passa se stesso come Owner (l'helper si
  // libera con la form) e la funzione che esporta il documento visualizzato in
  // un PDF temporaneo (per la persistenza pigra; il file viene eliminato dal
  // chiamante dopo l'uso).
  // Ritorna nil se le azioni non sono configurate (nessun controller
  // applicativo o nodo "azioni" assente nel template): in quel caso il viewer
  // nasconde il proprio gruppo "Documento".
  TzSetupAzioniDocumentoProc = reference to function(AOwner: TComponent;
    EsportaPdfTemporaneo: TFunc<string>): TzDocumentActionsBarHelper;

  TWordParams = record
  private
    FBeforeShowProc: TProc<string, TdxRichEditControl>;
    FDocumentFormat: TdxRichEditDocumentFormat;
    FFileName: String;
    FOnSetupAzioniDocumento: TzSetupAzioniDocumentoProc;

    FOnGetDataSet: TFunc<string, TDataSet>;
    FOnGetDataSetList: TProc<TStrings>;
    FOnGetDataSetName: TFunc<string, string>;
    FOnGetHyperLink: TFunc<string, string, string, string, boolean>;
    FOnGetImages: TProc<string, TDataSet, TImageUriStreamProvider>;
    FOnGetVariable: TFunc<string, variant>;
    FOnAddFragment: TFunc<string, string>;
    FOnRemoveFragment: TFunc<string, Boolean>;
    FReadOnly: boolean;
    FTemplateFileName: String;
    FDefaultFolder: String;
    FFragments: TArray<TWordFragment>;
    FProgress: IzReportProgress;
  public
    procedure Init;
    procedure Assign(src: TWordParams);

    function GetVariable(const VariableName: string; out Value: variant): boolean;
    function GetHyperLink(const TextVariableName, UrlVariableName: string; out text, url: string): boolean;
    function GetDataSet(const VariableName: string): TDataSet;
    function GetDataSetName(const VariableName: string): string;
    function GetField(const VariableName: string): TField;
    function GetImage(const URI: string): TStream;
    procedure GetDataSetList(DataSets: TStrings);
  public
    Pdf: TPdfParams;

    property TemplateFileName: String read FTemplateFileName write FTemplateFileName;
    // Cartella in cui l'editor propone di salvare un template nuovo (senza nome
    // file) e da cui apre la finestra "Apri template" quando il nome e' vuoto.
    property DefaultFolder: String read FDefaultFolder write FDefaultFolder;
    property FileName: String read FFileName write FFileName;
    property BeforeShowProc: TProc<string, TdxRichEditControl> read FBeforeShowProc write FBeforeShowProc;
    property OnGetHyperLink: TFunc<string, string, string, string, boolean> read FOnGetHyperLink write FOnGetHyperLink;
    property OnGetVariable: TFunc<string, variant> read FOnGetVariable write FOnGetVariable;
    property OnGetDataSet: TFunc<string, TDataSet> read FOnGetDataSet write FOnGetDataSet;
    property OnGetDataSetName: TFunc<string, string> read FOnGetDataSetName write FOnGetDataSetName;
    property OnGetDataSetList: TProc<TStrings> read FOnGetDataSetList write FOnGetDataSetList;
    property OnGetImages: TProc<string, TDataSet, TImageUriStreamProvider> read FOnGetImages write FOnGetImages;
    property OnAddFragment: TFunc<string, string> read FOnAddFragment write FOnAddFragment;
    // Toglie il fragment (nome della variabile) dalla configurazione del report;
    // ritorna False se non c'e' riuscito. Non assegnato = nessuna configurazione
    // da aggiornare (convenzione del solo nome file).
    property OnRemoveFragment: TFunc<string, Boolean> read FOnRemoveFragment write FOnRemoveFragment;
    property DocumentFormat: TdxRichEditDocumentFormat read FDocumentFormat write FDocumentFormat;
    property ReadOnly: boolean read FReadOnly write FReadOnly;
    property Fragments: TArray<TWordFragment> read FFragments write FFragments;
    function FindFragment(const VariableName: string; out Fragment: TWordFragment): Boolean;

    // azioni documentali (gruppo "Documento" costruito dal ReportsManager)
    property OnSetupAzioniDocumento: TzSetupAzioniDocumentoProc read FOnSetupAzioniDocumento write FOnSetupAzioniDocumento;

    // avanzamento + annullamento della generazione (guidato dal ReportsManager)
    property Progress: IzReportProgress read FProgress write FProgress;
  end; //

  TExcelParams = record
  private
    FAllowBuildReport: TFunc<string, boolean>;
    FAfterBuild: TProc<string, TdxSpreadSheet>;
    FBeforeBuild: TProc<string, TdxSpreadSheet>;
    FBeforeShow: TProc<string, TdxSpreadSheet>;
    FFileName: String;
    FOnGetDataSet: TFunc<string, TDataSet>;
    FOnGetDataSource: TFunc<string, TDataSource>;
    FOnGetVariable: TFunc<string, variant>;
    FOnSaveDataBinding: TFunc<string, boolean>;
    FOnLoadDataBinding: TFunc<string>;
    FPdf: TPdfParams;
    FReadOnly: boolean;
    FTemplateFileName: String;
    FDefaultFolder: String;
    FOnSetupAzioniDocumento: TzSetupAzioniDocumentoProc;
    FProgress: IzReportProgress;
  public
    procedure Init;
    procedure Assign(src: TExcelParams);

    function GetVariable(const VariableName: string; out Value: variant): boolean;
    function GetDataSet(const VariableName: string): TDataSet;
    function GetDataSource(const VariableName: string): TDataSource;
    function GetField(const VariableName: string): TField;
  public
    property TemplateFileName: String read FTemplateFileName write FTemplateFileName;
    // Cartella in cui l'editor propone di salvare un template nuovo (senza nome
    // file) e da cui apre le finestre "Apri" e "Salva con nome" quando il nome e' vuoto.
    property DefaultFolder: String read FDefaultFolder write FDefaultFolder;
    property FileName: String read FFileName write FFileName;

    property AllowBuildReport: TFunc<string, boolean> read FAllowBuildReport write FAllowBuildReport;
    property BeforeBuild: TProc<string, TdxSpreadSheet> read FBeforeBuild write FBeforeBuild;
    property AfterBuild: TProc<string, TdxSpreadSheet> read FAfterBuild write FAfterBuild;
    property BeforeShow: TProc<string, TdxSpreadSheet> read FBeforeShow write FBeforeShow;

    property OnGetDataSet: TFunc<string, TDataSet> read FOnGetDataSet write FOnGetDataSet;
    property OnGetDataSource: TFunc<string, TDataSource> read FOnGetDataSource write FOnGetDataSource;
    property OnGetVariable: TFunc<string, variant> read FOnGetVariable write FOnGetVariable;
    property ReadOnly: boolean read FReadOnly write FReadOnly;
    property OnSaveDataBinding: TFunc<string, boolean> read FOnSaveDataBinding write FOnSaveDataBinding;
    property OnLoadDataBinding: TFunc<string> read FOnLoadDataBinding write FOnLoadDataBinding;
    property Pdf: TPdfParams read FPdf write FPdf;
    // azioni documentali (gruppo "Documento" costruito dal ReportsManager)
    property OnSetupAzioniDocumento: TzSetupAzioniDocumentoProc read FOnSetupAzioniDocumento write FOnSetupAzioniDocumento;

    // avanzamento + annullamento della generazione (guidato dal ReportsManager)
    property Progress: IzReportProgress read FProgress write FProgress;
  end;

  TSMTPServerParams = record
  private
    FAuthenticationType: string;
    FFrom: string;
    FFromAddress: string;
    FHost: string;
    FPassword: string;
    FPort: integer;
    FReceiptRecipient: string;
    FReplyTo: string;
    Fssl: string;
    Fssl_ver: string;
    FUserName: string;
  public
    procedure Init; overload;
    procedure Init(aFrom, aFromAddress, aReplyTo, aReceiptRecipient, aHost: string; aPort: integer; aUserName, aPassword, aAuthenticationType, aSsl, aSsl_ver: string); overload;
    procedure Assign(src: TSMTPServerParams);
    function IsValid: boolean;
  public
    property From: string read FFrom write FFrom;
    property FromAddress: string read FFromAddress write FFromAddress;
    property ReplyTo: string read FReplyTo write FReplyTo;
    property ReceiptRecipient: string read FReceiptRecipient write FReceiptRecipient;
    property Host: string read FHost write FHost;
    property Port: integer read FPort write FPort;
    property UserName: string read FUserName write FUserName;
    property Password: string read FPassword write FPassword;
    property AuthenticationType: string read FAuthenticationType write FAuthenticationType;
    property ssl: string read Fssl write Fssl;
    property ssl_ver: string read Fssl_ver write Fssl_ver;
  end;

  TMailForwardType = (mfNone, mfReply, mfForward);
  TMailAllowedForwardingType = (afReply, afForward);
  TMailAllowedForwardingTypes = set of TMailAllowedForwardingType;

  TMail = record
  private
    FA: string;
    FAllegati: string;
    FAllowForward: boolean;
    FAllowReplay: boolean;
    FCC: string;
    FCCN: string;
    FConfermaLettura: boolean;
    FCorpoHtml: string;
    FCorpoTxt: string;
    FOggetto: string;
    FPriorita: TIdMessagePriority;
  public
    procedure Init;
    procedure Assign(src: TMail);
  public
    property A: string read FA write FA;
    property CC: string read FCC write FCC;
    property CCN: string read FCCN write FCCN;
    property Oggetto: string read FOggetto write FOggetto;
    property CorpoHtml: string read FCorpoHtml write FCorpoHtml;
    property CorpoTxt: string read FCorpoTxt write FCorpoTxt;
    property Allegati: string read FAllegati write FAllegati;

    property Priorita: TIdMessagePriority read FPriorita write FPriorita;
    property ConfermaLettura: boolean read FConfermaLettura write FConfermaLettura;

    property AllowReplay: boolean read FAllowReplay write FAllowReplay;
    property AllowForward: boolean read FAllowForward write FAllowForward;
  end;

  izViewerFrame = interface
    procedure OpenFile(const FileName: string);
    procedure CloseFile;
    procedure Print;
    procedure SetAllowedImportFileTypes(FileTypes: TzFileTypes);
    // manca a Excel e SynEdit
    // function AddToolbarButton(Action: TAction; const Position: integer = 0): TdxBarButton;
    ['{CB6ED3B8-6EF5-4CBC-B14E-FD0692FF8075}']
  end;

  izViewerForm = interface
    ['{AC5B657E-A218-47B4-8625-76BBED186E2D}']
  end;

implementation

uses
  System.Variants;

{ TzPdfFontEmbeddingHelper }

function TzPdfFontEmbeddingHelper.Description: string;
begin
  case Self of
    zfeNone:
      result := '';
    zfeFull:
      result := '';
    zfeSubset:
      result := '';
  end;
end;

function TzPdfFontEmbeddingHelper.ToString: string;
begin
  case Self of
    zfeNone:
      result := 'N';
    zfeFull:
      result := 'F';
    zfeSubset:
      result := 'S';
  end;
end;

class function TzPdfFontEmbeddingHelper.FromString(const s: String): TzPdfFontEmbedding;
begin
  result := zfeNone;

  if SameText(s, 'N') then
    result := zfeNone
  else
    if SameText(s, 'F') then
      result := zfeFull
    else
      if SameText(s, 'S') then
        result := zfeSubset;
end;

class function TzFileTypeHelper.FromFileName(const FileName: string): TzFileType;
var
  ext: string;
begin
  result := ftNone;

  ext := ExtractFileExt(FileName).ToLower;

  if ext = '.pdf' then
    result := ftPdf
  else
    if ext = '.doc' then
      result := ftWord
    else
      if ext = '.docx' then
        result := ftWord
      else
        if ext = '.rtf' then
          result := ftWord
        else
          if ext = '.xls' then
            result := ftExcel
          else
            if ext = '.xlsx' then
              result := ftExcel
            else
              if ext = '.csv' then
                result := ftExcel
              else
                if ext = '.bmp' then
                  result := ftImage
                else
                  if ext = '.png' then
                    result := ftImage
                  else
                    if ext = '.jpeg' then
                      result := ftImage
                    else
                      if ext = '.jpg' then
                        result := ftImage
                      else
                        if ext = '.eml' then
                          result := ftMail
                        else
                          if ext = '.txt' then
                            result := ftTXT
                          else
                            if ext = '.xml' then
                              result := ftXML
                            else
                              if ext = '.json' then
                                result := ftJSON;
end;

function TzFileTypeHelper.ImageIndex: integer;
begin
  result := -1;

  case Self of
    ftNone:
      result := 0;
    ftPdf:
      result := 1;
    ftWord:
      result := 2;
    ftExcel:
      result := 3;
    ftImage:
      result := 4;
    ftMail:
      result := 5;
    ftTXT:
      result := 6;
    ftXML:
      result := 7;
    ftJSON:
      result := 8;
  end;
end;

procedure TzFileTypeHelper.SetAsString(const Value: string);
var
  s: string;
begin
  s := Value.trim.ToUpper;

  Self := ftNone;

  if s = 'P' then
    Self := ftPdf
  else
    if s = 'W' then
      Self := ftWord
    else
      if s = 'E' then
        Self := ftExcel
      else
        if s = 'I' then
          Self := ftImage
        else
          if s = 'M' then
            Self := ftMail
          else
            if s = 'T' then
              Self := ftTXT
            else
              if s = 'X' then
                Self := ftXML
              else
                if s = 'J' then
                  Self := ftJSON;
end;

function TzFileTypeHelper.GetAsString: string;
begin
  case Self of
    ftNone:
      result := '';
    ftPdf:
      result := 'P';
    ftWord:
      result := 'W';
    ftExcel:
      result := 'E';
    ftImage:
      result := 'I';
    ftMail:
      result := 'M';
    ftTXT:
      result := 'T';
    ftXML:
      result := 'X';
    ftJSON:
      result := 'J';
  end;
end;

procedure TPdfParams.Init;
begin
  Method := mgfDialog;
  FileName := '';
  FieldName := '';
  FontEmbedding := zfeSubset;
  OpenFileAfterExport := False;
  ShowMessageAfterExport := True;
  AfterExportProc := nil;
end;

procedure TPdfParams.Assign(src: TPdfParams);
begin
  Method := src.Method;
  FileName := src.FileName;
  FieldName := src.FieldName;
  FontEmbedding := src.FontEmbedding;
  OpenFileAfterExport := src.OpenFileAfterExport;
  ShowMessageAfterExport := src.ShowMessageAfterExport;
  AfterExportProc := src.AfterExportProc;
end;

procedure TWordParams.Init;
begin
  TemplateFileName := '';
  DefaultFolder := '';
  FileName := '';
  OnGetDataSet := nil;
  OnGetDataSetName := nil;
  OnGetDataSetList := nil;
  OnGetVariable := nil;
  OnGetImages := nil;
  OnAddFragment := nil;
  OnRemoveFragment := nil;
  BeforeShowProc := nil;
  DocumentFormat := TdxRichEditDocumentFormat.OpenXML;
  ReadOnly := False;
  OnSetupAzioniDocumento := nil;
  Progress := nil;

  Pdf.Init;
  FFragments := nil;
end;

procedure TWordParams.Assign(src: TWordParams);
begin
  TemplateFileName := src.TemplateFileName;
  DefaultFolder := src.DefaultFolder;
  FileName := src.FileName;
  OnGetDataSet := src.OnGetDataSet;
  OnGetDataSetName := src.OnGetDataSetName;
  OnGetDataSetList := src.OnGetDataSetList;
  OnGetVariable := src.OnGetVariable;
  OnGetImages := src.OnGetImages;
  OnAddFragment := src.OnAddFragment;
  OnRemoveFragment := src.OnRemoveFragment;
  BeforeShowProc := src.BeforeShowProc;
  DocumentFormat := src.DocumentFormat;
  ReadOnly := src.ReadOnly;
  OnSetupAzioniDocumento := src.OnSetupAzioniDocumento;
  Progress := src.Progress;

  Pdf.Assign(src.Pdf);
  FFragments := src.FFragments;
end;

function TWordParams.GetDataSet(const VariableName: string): TDataSet;
begin
  result := nil;

  if assigned(FOnGetDataSet) then
    result := OnGetDataSet(VariableName);
end;

function TWordParams.FindFragment(const VariableName: string; out Fragment: TWordFragment): Boolean;
var
  f: TWordFragment;
begin
  result := False;
  for f in FFragments do
    if SameText(f.VariableName, VariableName) then
    begin
      Fragment := f;
      result := True;
      Break;
    end;
end;

procedure TWordParams.GetDataSetList(DataSets: TStrings);
begin
  assert(assigned(DataSets));

  if assigned(FOnGetDataSetList) then
    OnGetDataSetList(DataSets);
end;

function TWordParams.GetDataSetName(const VariableName: string): string;
begin
  result := '';

  if assigned(FOnGetDataSetName) then
    result := OnGetDataSetName(VariableName);
end;

function TWordParams.GetField(const VariableName: string): TField;
var
  Variable: TzOfficeVariable;
  DataSet: TDataSet;
begin
  result := nil;

  Variable.Init(VariableName);

  if Variable.FieldName.IsEmpty then // datasetName potrebbe essere vuoto
    Exit;

  DataSet := GetDataSet(Variable.DataSetName);

  if assigned(DataSet) then
    result := DataSet.FindField(Variable.FieldName);
end;

function TWordParams.GetHyperLink(const TextVariableName, UrlVariableName: string; out text, url: string): boolean;
var
  varText, varUrl: variant;
begin
  result := False;

  if assigned(FOnGetHyperLink) then
    result := OnGetHyperLink(TextVariableName, UrlVariableName, text, url)
  else
  begin
    if GetVariable(TextVariableName, varText) then
      if GetVariable(UrlVariableName, varUrl) then
      begin
        text := varText;
        url := varUrl;
        result := True;
      end;
  end;
end;

function TWordParams.GetImage(const URI: string): TStream;
var
  DataSet: TDataSet;
  Field: TField;
begin
  result := nil;

  Field := GetField(URI);

  if assigned(Field) then
    if Field.IsBlob and (TBlobField(Field).BlobType = ftGraphic) then
      if not Field.IsNull then
      begin
        result := TMemoryStream.Create;
        TBlobField(Field).SaveToStream(result);
        result.position := 0;
      end;
end;

function TWordParams.GetVariable(const VariableName: string; out Value: variant): boolean;
var
  Field: TField;
begin
  result := False;

  if assigned(FOnGetVariable) then
  begin
    Value := OnGetVariable(VariableName);
    result := not VarisNull(Value);
  end;

  if not result then
  begin
    Field := GetField(VariableName);

    if assigned(Field) then
    begin
      result := True;

      if Field.IsBlob and ((Field is TMemoField) or (Field is TWideMemoField)) then
        Value := Field.AsString
      else
        Value := Field.DisplayText;
    end;
  end;
end;

procedure TExcelParams.Init;
begin
  TemplateFileName := '';
  DefaultFolder := '';
  FileName := '';
  OnGetDataSet := nil;
  OnGetDataSource := nil;
  OnGetVariable := nil;
  AllowBuildReport := nil;

  BeforeBuild := nil;
  AfterBuild := nil;
  BeforeShow := nil;
  ReadOnly := False;
  OnSaveDataBinding := nil;
  OnLoadDataBinding := nil;
  OnSetupAzioniDocumento := nil;
  Progress := nil;
  Pdf.Init;
end;

procedure TExcelParams.Assign(src: TExcelParams);
begin
  TemplateFileName := src.TemplateFileName;
  DefaultFolder := src.DefaultFolder;
  FileName := src.FileName;
  OnGetDataSet := src.OnGetDataSet;
  OnGetDataSource := src.OnGetDataSource;
  OnGetVariable := src.OnGetVariable;
  AllowBuildReport := src.AllowBuildReport;
  BeforeBuild := src.BeforeBuild;
  AfterBuild := src.AfterBuild;
  BeforeShow := src.BeforeShow;
  ReadOnly := src.ReadOnly;
  OnSaveDataBinding := src.OnSaveDataBinding;
  OnLoadDataBinding := src.OnLoadDataBinding;
  OnSetupAzioniDocumento := src.OnSetupAzioniDocumento;
  Progress := src.Progress;
  Pdf.Assign(src.Pdf);
end;

function TExcelParams.GetDataSet(const VariableName: string): TDataSet;
begin
  result := nil;

  if assigned(FOnGetDataSet) then
    result := OnGetDataSet(VariableName);
end;

function TExcelParams.GetDataSource(const VariableName: string): TDataSource;
begin
  result := nil;

  if assigned(FOnGetDataSource) then
    result := OnGetDataSource(VariableName);
end;

function TExcelParams.GetField(const VariableName: string): TField;
var
  Variable: TzOfficeVariable;
  DataSet: TDataSet;
begin
  result := nil;

  Variable.Init(VariableName);

  if Variable.FieldName.IsEmpty then // datasetName potrebbe essere vuoto
    Exit;

  DataSet := GetDataSet(Variable.DataSetName);

  if assigned(DataSet) then
    result := DataSet.FindField(Variable.FieldName);
end;

function TExcelParams.GetVariable(const VariableName: string; out Value: variant): boolean;
var
  Field: TField;
begin
  result := False;

  if assigned(FOnGetVariable) then
  begin
    Value := OnGetVariable(VariableName);
    result := not VarisNull(Value);
  end;

  if not result then
  begin
    Field := GetField(VariableName);

    if assigned(Field) then
    begin
      result := True;

      if Field.IsBlob and ((Field is TMemoField) or (Field is TWideMemoField)) then
        Value := Field.AsString
      else
        Value := Field.DisplayText;
    end;
  end;
end;

{ TSMTPServerParams }

procedure TSMTPServerParams.Init;
begin
  From := '';
  FromAddress := '';
  ReplyTo := '';
  ReceiptRecipient := '';
  Host := '';
  Port := -1;
  UserName := '';
  Password := '';
  AuthenticationType := 'S';
  ssl := 'N';
  ssl_ver := '1';
end;

procedure TSMTPServerParams.Init(aFrom, aFromAddress, aReplyTo, aReceiptRecipient, aHost: string; aPort: integer; aUserName, aPassword, aAuthenticationType, aSsl, aSsl_ver: string);
begin
  From := aFrom;
  FromAddress := aFromAddress;
  ReplyTo := aReplyTo;
  ReceiptRecipient := aReceiptRecipient;
  Host := aHost;
  Port := aPort;
  UserName := aUserName;
  Password := aPassword;
  AuthenticationType := aAuthenticationType;
  ssl := aSsl;
  ssl_ver := aSsl_ver;
end;

procedure TSMTPServerParams.Assign(src: TSMTPServerParams);
begin
  From := src.From;
  FromAddress := src.FromAddress;
  ReplyTo := src.ReplyTo;
  ReceiptRecipient := src.ReceiptRecipient;
  Host := src.Host;
  Port := src.Port;
  UserName := src.UserName;
  Password := src.Password;
  AuthenticationType := src.AuthenticationType;
  ssl := src.ssl;
  ssl_ver := src.ssl_ver;
end;

function TSMTPServerParams.IsValid: boolean;
begin
  result := (not Host.IsEmpty) and (Port <> -1) and
  // (not FromAddress.IsEmpty) and
  { esistono account senza user/pwd and (not UserName.IsEmpty) and }
    (not ssl.IsEmpty) and (not ssl_ver.IsEmpty);
end;

{ TMail }

procedure TMail.Init;
begin
  A := '';
  CC := '';
  CCN := '';
  Oggetto := '';
  CorpoTxt := '';
  CorpoHtml := '';
  Allegati := '';
  Priorita := mpNormal;
  ConfermaLettura := False;

  AllowReplay := True;
  AllowForward := True;
end;

procedure TMail.Assign(src: TMail);
begin
  A := src.A;
  CC := src.CC;
  CCN := src.CCN;
  Oggetto := src.Oggetto;
  CorpoTxt := src.CorpoTxt;
  CorpoHtml := src.CorpoHtml;
  Allegati := src.Allegati;
  Priorita := src.Priorita;
  ConfermaLettura := src.ConfermaLettura;
  AllowReplay := src.AllowReplay;
  AllowForward := src.AllowForward;
end;

procedure TzOfficeVariable.Init;
begin
  Init('');
end;

procedure TzOfficeVariable.Init(const VariableName: string);
begin
  FVariableName := VariableName.DeQuotedString('"');
end;

procedure TzOfficeVariable.Init(const DataSetName, FieldName: string);
begin
  Init(DataSetName + Separator + FieldName);
end;

function TzOfficeVariable.Separator: char;
begin
  result := '.';
end;

function TzOfficeVariable.GetDataSetName: string;
begin
  result := '';

  if VariableName.Contains(Separator) then
    result := VariableName.Substring(0, VariableName.IndexOf(Separator));
end;

function TzOfficeVariable.GetFieldName: string;
begin
  result := '';

  if VariableName.Contains(Separator) then
    result := VariableName.Substring(VariableName.IndexOf(Separator) + 1)
  else
    result := VariableName;
end;

procedure TWordFragment.SetTemplateFileName(const Value: string);
begin
  FTemplateFileName := Value;
end;

end.

// OnGetDataSetList
// procedure frxGetDataSetList(List: TStrings);
