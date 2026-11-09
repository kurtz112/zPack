unit zOffice.Word.MailMerge;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Types,
  Data.DB,
  dxCore,
  dxCoreClasses,
  dxRichEdit.Utils.UriStreamService,
  dxRichEdit.NativeApi,
  dxRichEdit.Types,
  dxRichEdit.PlainText,
  dxRichEdit.DocumentServer,
  dxRichEdit.Control,
  zOffice.Types,
  zOffice.Word.UriStreamProvider;

type
  TMailMergeEngine = class(TDataModule)
    dxRichEditDocumentServer: TdxRichEditDocumentServer;
    MainDataSource: TDataSource;
    procedure dxRichEditDocumentServerCalculateDocumentVariable(Sender: TObject; E: TdxCalculateDocumentVariableEventArgs);
  private
    procedure CalculateHyperlinkVariables(Document: IdxRichEditDocument);
  private
    FParams: TWordParams;

    // avanzamento + annullamento (via FParams.Progress)
    FMergeCount: Integer;
    FMergeCancelled: Boolean;
    procedure DoMailMergeStarted(Sender: TObject; const Args: TdxMailMergeStartedEventArgs);
    procedure DoMailMergeRecordStarted(Sender: TObject; const Args: TdxMailMergeRecordStartedEventArgs);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function MailMerge(Params: TWordParams): TMemoryStream;
  public
    property Params: TWordParams read FParams;
  end;

function MailMerge(Params: TWordParams): TMemoryStream;

implementation

uses
  System.Rtti,
  System.IOUtils,
  System.Variants,
  Vcl.Dialogs,
  dxRichEdit.DocumentModel.RichEditDocumentServer,
  zMsg,
  zOffice.Word.Utils,
  SmartInspect.Vcl.SiAuto,
  SmartInspect.Vcl;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function MailMerge(Params: TWordParams): TMemoryStream;
var
  MailMergeEngine: TMailMergeEngine;
begin
  MailMergeEngine := TMailMergeEngine.Create(nil);
  try
    result := MailMergeEngine.MailMerge(Params);
  finally
    FreeAndNil(MailMergeEngine);
  end;
end;

constructor TMailMergeEngine.Create(aOwner: TComponent);
begin
  inherited;
  Params.Init;
end;

destructor TMailMergeEngine.Destroy;
begin
  inherited;
end;

// Contatore azzerato all'avvio del merge dal document server.
procedure TMailMergeEngine.DoMailMergeStarted(Sender: TObject; const Args: TdxMailMergeStartedEventArgs);
begin
  FMergeCount := 0;
end;

// Ad ogni record: aggiorna la barra e, se l'utente ha premuto Annulla, chiede
// l'interruzione del merge (Args.Cancel = True).
procedure TMailMergeEngine.DoMailMergeRecordStarted(Sender: TObject; const Args: TdxMailMergeRecordStartedEventArgs);
begin
  Inc(FMergeCount);

  if not assigned(FParams.Progress) then
    exit;

  if not FParams.Progress.Step(FMergeCount, '') then
  begin
    FMergeCancelled := True;
    Args.Cancel := True;
  end;
end;

function TMailMergeEngine.MailMerge(Params: TWordParams): TMemoryStream;
var
  Options: IdxRichEditMailMergeOptions;
  Service: IdxUriStreamService;
  Provider: TImageUriStreamProvider;
  Destinazione: TdxRichEditDocumentServer;
  Misure: TArray<TzMisuraImmagine>;
begin
  FParams.Assign(Params);

  result := TMemoryStream.Create;
  try
    MainDataSource.DataSet := Params.GetDataSet(FileNameNoExt(Params.TemplateFileName));

    if MainDataSource.DataSet = nil then
      MainDataSource.DataSet := Params.GetDataSet('');

    if MainDataSource.DataSet = nil then
    begin
      ConfirmOk('MailMerge: dataset non trovato', mtWarning);
      exit;
    end;

    //
    // begin
    Provider := TImageUriStreamProvider.Create;
    Service := dxRichEditDocumentServer.GetService<IdxUriStreamService>;
    Service.RegisterProvider(Provider);

    Provider.GetImageFunc := function(URI: string): TStream
      begin
        result := Params.GetImage(URI);
      end;

    if assigned(Params.OnGetImages) then
      Params.OnGetImages(Params.TemplateFileName, MainDataSource.DataSet, Provider);
    // end;

    dxRichEditDocumentServer.Options.Fields.UseCurrentCultureDateTimeFormat := true;
    dxRichEditDocumentServer.Options.MailMerge.DataSource := MainDataSource;
    dxRichEditDocumentServer.LoadDocumentTemplate(Params.TemplateFileName, Params.DocumentFormat);

    Options := dxRichEditDocumentServer.Document.CreateMailMergeOptions;
    Options.MergeRecords := TdxRichEditMergeRecords.Selected;


    // dxRichEditDocumentServer.MailMerge(Options, 'C:\Users\Luca\Desktop\Spid\test.docx', Params.DocumentFormat);

    // avanzamento + annullamento: aggancia gli eventi del document server e
    // mostra il box con il numero di record atteso
    FMergeCount := 0;
    FMergeCancelled := False;

    if assigned(FParams.Progress) then
    begin
      FParams.Progress.Start('Generazione documento in corso...',
        MainDataSource.DataSet.RecordCount);
      dxRichEditDocumentServer.OnMailMergeStarted := DoMailMergeStarted;
      dxRichEditDocumentServer.OnMailMergeRecordStarted := DoMailMergeRecordStarted;
    end;

    // toglie il quadratino segnaposto alle immagini vuote dei campi INCLUDEPICTURE
    TzWordImmagini.SopprimiSegnaposto(dxRichEditDocumentServer.Document);

    // Le misure @L:A dei campi INCLUDEPICTURE si leggono dal template PRIMA del
    // merge: nel documento unito i campi non ci sono piu' e l'Uri dell'immagine
    // (primo argomento del campo, senza suffisso) sopravvive solo in memoria, non
    // nel docx. Per questo il merge va in un documento in memoria e le misure si
    // applicano prima del salvataggio.
    Misure := TzWordImmagini.RaccogliMisure(dxRichEditDocumentServer.Document);

    Destinazione := TdxRichEditDocumentServer.Create(nil);
    try
      Destinazione.Options.DocumentSaveOptions.DefaultFormat := Params.DocumentFormat;
      Destinazione.Options.Fields.UseCurrentCultureDateTimeFormat := true;
      Destinazione.OnCalculateDocumentVariable := dxRichEditDocumentServerCalculateDocumentVariable;
      Destinazione.GetService<IdxUriStreamService>.RegisterProvider(Provider);

      try
        dxRichEditDocumentServer.MailMerge(Options, Destinazione.Document);
      finally
        dxRichEditDocumentServer.OnMailMergeStarted := nil;
        dxRichEditDocumentServer.OnMailMergeRecordStarted := nil;
        Destinazione.OnCalculateDocumentVariable := nil;
        if assigned(FParams.Progress) then
          FParams.Progress.Done;
      end;

      // annullamento richiesto: niente documento, il viewer non viene aperto
      if FMergeCancelled then
      begin
        FreeAndNil(result);
        exit;
      end;

      CalculateHyperlinkVariables(Destinazione.Document);

      // ridimensiona le immagini del documento unito con le misure del template
      TzWordImmagini.ApplicaMisure(Destinazione.Document, Misure);

      Destinazione.SaveDocument(result, Params.DocumentFormat);
      result.Position := 0;
    finally
      FreeAndNil(Destinazione);
    end;
  except
    FreeAndNil(result);
    raise;
  end;
end;

procedure TMailMergeEngine.dxRichEditDocumentServerCalculateDocumentVariable(Sender: TObject; E: TdxCalculateDocumentVariableEventArgs);

  procedure EvalVariable;
  var
    v: variant;
  begin
    E.Handled := Params.GetVariable(E.VariableName, v);

    if E.Handled then
      E.Value := TValue.FromVariant(v);
  end;

  procedure EvalFragment;
  var
    DataSource: TDataSource;
    dxRichEditDocumentServer: TdxRichEditDocumentServer;
    DocumentServerDetail: TdxRichEditDocumentServer;
    DocumentServerTemp: TdxRichEditDocumentServer;
    FragmentFileName: string;
    Options: IdxRichEditMailMergeOptions;
    Fragment: TWordFragment;
    HasFragment: Boolean;
  begin
    siMain.EnterMethod('EvalFragment');

    E.Handled := false;

    // se va in loop controllare il SelectedDataSet

    HasFragment := Params.FindFragment(E.VariableName, Fragment);
    if HasFragment or TFragmentHelper.Exists(Params.TemplateFileName, E.VariableName) then
    begin
      if HasFragment then
      begin
        FragmentFileName := Fragment.TemplateFileName;
        if ExtractFilePath(FragmentFileName).IsEmpty then
          FragmentFileName := IncludeTrailingPathDelimiter(ExtractFilePath(Params.TemplateFileName)) + FragmentFileName;
      end
      else
        FragmentFileName := TFragmentHelper.FileName(Params.TemplateFileName, E.VariableName);

      DataSource := TDataSource.Create(nil);
      try
        if HasFragment then
          DataSource.DataSet := Params.GetDataSet(Fragment.DataSetName)
        else
          DataSource.DataSet := Params.GetDataSet(E.VariableName);

        if DataSource.DataSet = nil then
          exit;

        siMain.LogVerbose('TdxRichEditDocumentServer');

        dxRichEditDocumentServer := TdxRichEditDocumentServer.Create(self);
        try
          dxRichEditDocumentServer.Options.DocumentSaveOptions.DefaultFormat := TdxRichEditDocumentFormat.OpenXml;
          dxRichEditDocumentServer.Options.Fields.UseCurrentCultureDateTimeFormat := true;
          dxRichEditDocumentServer.Document.LoadDocument(FragmentFileName, TdxRichEditDocumentFormat.undefined);
          dxRichEditDocumentServer.Options.MailMerge.DataSource := DataSource;

          Options := dxRichEditDocumentServer.Document.CreateMailMergeOptions;
          Options.MergeMode := TdxRichEditMergeMode.JoinTables;

          DocumentServerTemp := TdxRichEditDocumentServer.Create(nil);
          DocumentServerTemp.OnCalculateDocumentVariable := dxRichEditDocumentServerCalculateDocumentVariable;
          try
            dxRichEditDocumentServer.MailMerge(Options, DocumentServerTemp.Document);
          finally
            DocumentServerTemp.OnCalculateDocumentVariable := nil;
          end;

          E.Value := TValue.From(DocumentServerTemp);
          E.Handled := true;
        finally
          FreeAndNil(dxRichEditDocumentServer);
        end;
      finally
        FreeAndNil(DataSource);
      end;
    end;

    siMain.LeaveMethod('EvalFragment');
  end;

begin
  siMain.EnterMethod('dxRichEditDocumentServerCalculateDocumentVariable');
  siMain.LogString('VariableName', E.VariableName);

  EvalVariable;

  siMain.LogBoolean('Handled', E.Handled);
  if not E.Handled then
    EvalFragment;

  siMain.LeaveMethod('dxRichEditDocumentServerCalculateDocumentVariable');
end;

procedure TMailMergeEngine.CalculateHyperlinkVariables(Document: IdxRichEditDocument);

  procedure doCalculate(SubDoc: IdxRichEditSubDocument);
  var
    I: integer;
    Hyperlink: IdxRichEditHyperlink;
    Range: IdxRichEditDocumentRange;
    target, newText, NavigateUri: string;

  const
    HyperLinkVariable = '@';

    function CalculateHyperLinkVariable(const target: string; out Text, NavigateUri: string): boolean;
    var
      s: string;
      TextVariableName: string;
      UrlVariableName: string;
    begin
      result := false;

      s := target.Replace(HyperLinkVariable, '', []);

      TextVariableName := s.Substring(0, s.IndexOf('='));
      UrlVariableName := s.Substring(s.IndexOf('=') + 1);

      result := Params.GetHyperLink(TextVariableName, UrlVariableName, Text, NavigateUri);
    end;

  begin

    for I := SubDoc.Hyperlinks.Count - 1 downto 0 do
    begin
      Hyperlink := SubDoc.Hyperlinks[I];

      if Hyperlink.target.StartsWith(HyperLinkVariable) then
      begin
        target := Hyperlink.target;

        if CalculateHyperLinkVariable(target, newText, NavigateUri) then
        begin
          Range := Hyperlink.Range;
          SubDoc.Replace(Range, newText);
          Hyperlink := SubDoc.CreateHyperlink(Range);
          Hyperlink.target := target;
          Hyperlink.NavigateUri := NavigateUri;
        end
        else
        begin
          Range := Hyperlink.Range;
          SubDoc.Replace(Range, '');
        end;
      end;
    end;
  end;

var
  SubDoc: IdxRichEditSubDocument;
begin
  // header
  SubDoc := Document.Sections[0].BeginUpdateHeader();
  doCalculate(SubDoc);
  Document.Sections[0].EndUpdateHeader(SubDoc);

  // body
  doCalculate(Document);

  // footer
  SubDoc := Document.Sections[0].BeginUpdateFooter();
  doCalculate(SubDoc);
  Document.Sections[0].EndUpdateFooter(SubDoc);
end;

end.

// Parse,
// - se non trova la variabile
// -- se esiste un fragment con nome template + nome variabile
// --- evento getDataset(nome variabile)
// ---- crea/distrugge dxRichEditDocumentServer
// ---- crea/distrugge DataSource Temporanea
