unit zSecurityFrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  zSystem,
  zCollection,
  vcl.ActnList,
  vcl.ImgList,
  OkCancel,
  vcl.ComCtrls,
  Frame_ObjectInspector,
  Frame_Collection,
  zFbDataSet,
  cxClasses,
  dxBar,
  ExplorerDrop,
  System.ImageList,
  System.Actions,
  FireDAC.Phys.FB,
  cxGraphics,
  cxImageList,
  cxTL;

type
  TzSecurityForm = class(TForm)
    ActionList: TActionList;
    ImageList: TImageList;
    FrameCollection: TFrameCollection;
    TestConnessione: TAction;
    dxBarManager: TdxBarManager;
    dxBarButtonTestConnessione: TdxBarButton;
    Toolbar: TdxBar;
    ExplorerDrop: TExplorerDrop;
    OkCancel: TOkCancel;
    DockControlToolbar: TdxBarDockControl;
    CollectionImageList: TcxImageList;
    procedure FormCreate(Sender: TObject);
    procedure ExplorerDropDropped(Sender: TObject; Files: TStrings; FileCount, x, y: Integer);
    procedure OkCancelApply(Sender: TObject);
    procedure TestConnessioneExecute(Sender: TObject);
  private
    FzSecurity: TzSecurity;
    procedure SetzSecurity(const Value: TzSecurity);
    procedure FrameCollectionSelectNode(Sender: TObject);
    function ConnessioneSelezionata: TzConnection;
    procedure AggiornaAlbero(Seleziona: TzCollectionItem);
    procedure AggiungiDatabase(Files: TStrings);
    procedure RaccogliDatabase(const Percorso: string; Trovati: TStrings);
  public
    function Edit: Boolean;
    property zSecurity: TzSecurity read FzSecurity write SetzSecurity;
  end;

function ShowSecurityForm(zSecurity: TzSecurity): Boolean;
function SecurityFormVisible: Boolean;

implementation

uses
  System.IOUtils,
  zBaseLib,
  zMsg;
{$R *.dfm}

var
  zSecurityForm: TzSecurityForm;
  // Progressivo per l'identificativo del driver di ogni test di connessione.
  ContatoreDriverTest: Integer = 0;

function ShowSecurityForm(zSecurity: TzSecurity): Boolean;
begin
  result := false;

  if Assigned(zSecurityForm) then // evita ricorsione
    exit;

  zSecurityForm := TzSecurityForm.create(Application);
  try
    zSecurityForm.zSecurity := zSecurity;
    result := zSecurityForm.Edit;
  finally
    FreeAndNil(zSecurityForm);
  end;
end;

function SecurityFormVisible: Boolean;
begin
  result := Assigned(zSecurityForm);
end;

procedure TzSecurityForm.FormCreate(Sender: TObject);
begin
  // La barra con "Test connessione" sta sotto l'ispettore delle proprieta',
  // nella scheda del frame. Nel DFM il TdxBarDockControl e' figlio della form
  // (il frame e' un componente incorporato e a disegno non accetta figli):
  // qui viene spostato dentro la scheda e allineato in basso.
  DockControlToolbar.Parent := FrameCollection.tabInspector;
  DockControlToolbar.Align := TdxBarDockAlign.dalBottom;

  // La scheda "Editor" del frame serve agli oggetti del dizionario LZ, che
  // hanno un editor di dettaglio; per una connessione non ce n'e' e restava
  // una scheda vuota. Il frame la nasconde solo in SetEditor(nil), che qui
  // non si chiama mai.
  FrameCollection.tabEditor.TabVisible := False;

  // Icone dell'albero: l'indice 0 e' quello di img_SecurityConnections.
  FrameCollection.ImageList := CollectionImageList;

  // Le proprieta' della connessione nell'ordine in cui TzConnection le
  // dichiara (Name, poi server e protocollo, database, utente e password,
  // ruolo, set di caratteri, libreria, parametri), non in ordine alfabetico.
  FrameCollection.FrameObjectInspector.SortProperties := False;
  FrameCollection.OnSelectNode := FrameCollectionSelectNode;
  TestConnessione.Enabled := false;
end;

/// /////////

procedure TzSecurityForm.SetzSecurity(const Value: TzSecurity);
begin
  FzSecurity := Value;
end;

function TzSecurityForm.Edit: Boolean;
begin
  if Assigned(zSecurity) then
    AggiornaAlbero(nil);

  // Il fuoco all'albero lo da' ActiveControl quando la form compare: prima
  // di ShowModal un SetFocus solleverebbe "Cannot focus a disabled or
  // invisible window" (segnalazione del 2026-10-01 dalla form di accesso).
  ActiveControl := FrameCollection.TreeList;

  result := ShowModal = mrOk;
  FrameCollection.Clear;
end;

procedure TzSecurityForm.AggiornaAlbero(Seleziona: TzCollectionItem);
var
  Node: TcxTreeListNode;
begin
  FrameCollection.AddCollections([zSecurity.zConnections]);

  // Il nodo delle connessioni e' quello che serve quasi sempre: si apre
  // subito, gia' selezionato. Se e' appena stata aggiunta una connessione, la
  // selezione va su quella, cosi' l'ispettore la mostra senza altri clic.
  // Niente FrameCollection.SelectCollection: chiama TreeList.SetFocus, e qui
  // si passa anche prima di ShowModal, quando la form non e' ancora visibile.
  Node := nil;
  if Assigned(Seleziona) then
    Node := FrameCollection.FindNodeByInstance(Seleziona);

  if not Assigned(Node) and (FrameCollection.TreeList.Root.Count > 0) then
    Node := FrameCollection.TreeList.Root.Items[0]; // nodo della collezione Connections

  if Assigned(Node) then
  begin
    Node.Expand(True);
    Node.MakeVisible;
    Node.Selected := True;
  end;

  if Visible and FrameCollection.TreeList.CanFocus then
    FrameCollection.TreeList.SetFocus;
end;

procedure TzSecurityForm.OkCancelApply(Sender: TObject);
begin
  if Assigned(FzSecurity) then
    zSecurity.SaveZip;
end;

/// ///////// Registrazione dei database trascinati da Esplora risorse

procedure TzSecurityForm.ExplorerDropDropped(Sender: TObject; Files: TStrings; FileCount, x, y: Integer);
begin
  AggiungiDatabase(Files);
end;

procedure TzSecurityForm.RaccogliDatabase(const Percorso: string; Trovati: TStrings);
var
  Nome: string;
  Estensione: string;
begin
  // Una cartella viene esplorata per intero, sottocartelle comprese; di un
  // file si accetta solo l'estensione di un database Firebird.
  if DirectoryExists(Percorso) then
  begin
    for Nome in TDirectory.GetFiles(Percorso, '*.*', TSearchOption.soAllDirectories) do
      RaccogliDatabase(Nome, Trovati);
    exit;
  end;

  Estensione := ExtractFileExt(Percorso).ToLower;
  if (Estensione = '.fdb') or (Estensione = '.gdb') then
    Trovati.Add(Percorso);
end;

procedure TzSecurityForm.AggiungiDatabase(Files: TStrings);
var
  i: Integer;
  Trovati: TStringList;
  Connection: TzConnection;
begin
  if not Assigned(zSecurity) then
    exit;

  if not Assigned(Files) then
    exit;

  Connection := nil;
  Trovati := TStringList.Create;
  try
    StartWait;
    try
      for i := 0 to Files.Count - 1 do
        RaccogliDatabase(Files[i], Trovati);
    finally
      StopWait;
    end;

    if Trovati.Count = 0 then
    begin
      ConfirmOk('Nessun database Firebird (*.fdb, *.gdb) fra i file trascinati.');
      exit;
    end;

    // Una connessione per file, con i valori predefiniti di TzConnection
    // (SYSDBA, masterkey, fbclient.dll) e il server locale: quello che non
    // torna si corregge subito dopo nell'ispettore.
    for i := 0 to Trovati.Count - 1 do
    begin
      Connection := zSecurity.zConnections.Add;
      Connection.ServerName := 'localhost';
      Connection.DataBase := Trovati[i];
      Connection.Name := ExtractFileName(Trovati[i]) + ' (in ' + ExtractFilePath(Trovati[i]) + ')';
    end;
  finally
    FreeAndNil(Trovati);
  end;

  AggiornaAlbero(Connection);
end;

/// ///////// Test della connessione selezionata

function TzSecurityForm.ConnessioneSelezionata: TzConnection;
var
  Item: TzCollectionItem;
begin
  result := nil;

  Item := FrameCollection.GetCollectionItem(FrameCollection.SelectedNode);
  if Item is TzConnection then
    result := TzConnection(Item);
end;

procedure TzSecurityForm.FrameCollectionSelectNode(Sender: TObject);
begin
  // Il test ha senso solo su una connessione: non sul nodo della collezione,
  // non su una voce FTP.
  TestConnessione.Enabled := ConnessioneSelezionata <> nil;
end;

procedure TzSecurityForm.TestConnessioneExecute(Sender: TObject);
var
  DB: TzFbDatabase;
  Connection: TzConnection;
  FDPhysFBDriverLink: TFDPhysFBDriverLink;
  dbPassword: string;
  dbUsername: string;
begin
  // Il pulsante della barra non prende il fuoco: se l'ultimo valore scritto
  // nell'ispettore e' ancora nell'editor della cella, non e' ancora arrivato
  // alla connessione e il test girerebbe col valore di prima. HideEdit chiude
  // l'editor confermando il valore.
  FrameCollection.FrameObjectInspector.ObjectInspector.HideEdit;

  Connection := ConnessioneSelezionata;
  if not Assigned(Connection) then
    exit;

  TestConnessione.Enabled := false;
  try
    // FireDAC applica la libreria client (VendorLib) solo quando crea il
    // driver, e il link deve esistere in quel momento: prima veniva liberato
    // subito dopo InitDataBase, quindi ClientLibrary era ignorata. Il driver
    // ha un identificativo suo, nuovo a ogni prova: con "FB", quello
    // dell'applicazione, gia' caricato dopo l'accesso, il test avrebbe usato
    // la libreria della connessione corrente e non quella indicata.
    Inc(ContatoreDriverTest);
    FDPhysFBDriverLink := TFDPhysFBDriverLink.create(nil);
    try
      FDPhysFBDriverLink.DriverID := 'FB_TEST_' + IntToStr(ContatoreDriverTest);

      DB := TzFbDatabase.create(Self);
      try
        Connection.GetUserAndPassword(zSecurity.LoginParams.UserName, dbUsername, dbPassword);
        Connection.InitDataBase(DB, FDPhysFBDriverLink, dbUsername, dbPassword);
        DB.Params.Values['DriverID'] := FDPhysFBDriverLink.DriverID;

        DB.LoginPrompt := false;

        DB.Connected := True;
        DB.Connected := false;
      finally
        FreeAndNil(DB);
      end;

      // Senza connessioni aperte il driver si scarica: la libreria della
      // prova non resta caricata nel processo.
      FDPhysFBDriverLink.Release;
    finally
      FreeAndNil(FDPhysFBDriverLink);
    end;

    ConfirmOk('Connessione riuscita.');
  finally
    TestConnessione.Enabled := True;
  end;
end;

end.
