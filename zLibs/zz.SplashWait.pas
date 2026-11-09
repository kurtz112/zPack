// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-27
// ---------------------------------------------------------------------------
unit zz.SplashWait;

// Schermata di avvio (TdxSplashForm) e finestra di attesa (TdxWaitForm) di
// DevExpress, in un solo punto per tutti i programmi. Sostituisce
// SplashFormHelper (quattro copie divergenti) e la parte comune delle SplashFm
// di WT, Gesty, zTicser e Analysir.
//
// Sta in zLibs e non in zBase perche' non dipende da niente di zPack (solo
// RTL, VCL e DevExpress): la usano anche zBuilder, zShellEditor e
// zMarkdownViewer, che zBase non lo usano.
//
//   TWorkingMonitor   - il monitor su cui l'utente lavora, ricordato fra un
//                       avvio e l'altro
//   TSmartSplashForm  - schermata di avvio
//   TSmartWaitForm    - finestra di attesa sopra un form o un controllo
//
// COME LA LIBRERIA POSIZIONA LA SCHERMATA (verificato su dxSplashForms):
// - Position = Default: centro dell'area di lavoro del monitor di
//   GetForegroundWindow, letto nel thread della schermata. All'avvio quella
//   finestra e' Esplora risorse o la console da cui si e' lanciato il
//   programma: e' la causa della schermata sul monitor sbagliato.
// - Position = MainMonitorCenter: ramo vuoto, si comporta come Custom.
// - Position = Custom: Left e Top sono l'angolo, ma la libreria ne ricava il
//   centro come Left + Width div 2, dove Width e' Content.Width al momento
//   della Show, e solo dopo riscala per il DPI del monitor tenendo fermo quel
//   centro. Left e Top vanno quindi calcolati sulla Content.Width corrente,
//   NON su una dimensione riscalata a mano: con la riscalatura la schermata
//   finisce spostata di mezza differenza sui monitor al 125% o 150%.
// - Dopo la prima comparsa Content.Width resta alla scala dell'ultimo
//   monitor: Left e Top vanno ricalcolati a OGNI comparsa, altrimenti la
//   schermata rimessa dopo la finestra di accesso esce scentrata.
// - Una Show con la schermata gia' a video non la riposiziona.
//
// Visible: dopo Hide torna False solo quando l'animazione di uscita e'
// finita (circa 64 ms senza dissolvenza, 420 ms con). Lo stato di comparsa
// lo tiene quindi questa unit, e Visible non viene interrogata.
//
// Tutti i metodi vanno chiamati dal thread principale.
//
// FINESTRA DI ATTESA PERSA (Mantis #238): TdxWaitForm disegna in un thread
// suo, il cui ciclo dei messaggi non intercetta le eccezioni. Un errore di
// disegno chiude il thread e distrugge la finestra, ma l'oggetto conserva
// l'handle vecchio e non ricrea mai il thread: da li' ogni Show, SetBounds e
// Hide solleva "PostMessage failed. Win32Error=1400" fino alla chiusura del
// programma. TSmartWaitForm se ne accorge, sostituisce la finestra persa con
// una nuova dallo stesso contenuto e non lascia mai uscire le eccezioni della
// libreria: un'attesa che non compare non deve fermare il lavoro.
//
// ANIMAZIONE SENZA IMMAGINE (zBuilder, rilascio
// OUT/20261017-zbuilder-blocco-animazione-attesa/001): un elemento
// TAnimation senza immagine usa la GIF predefinita di DevExpress
// (DXSPLASHLOADING). Il thread di disegno non azzera il tempo alla
// ricomparsa (TWindowThread.StartAnimationTimer lascia FLastTick
// com'era), quindi il primo fotogramma dopo una lunga pausa recupera tutti i
// fotogrammi del tempo passato a finestra nascosta, standby compreso:
// TAnimation.DrawContent chiama SetActiveFrame di GDI+ una volta per ognuno,
// tenendo il lucchetto del contenuto, e il thread principale lo aspetta. In
// zBuilder i blocchi sono durati da 30 a 300 secondi. Con un'immagine di un
// solo fotogramma DrawContent prende invece il ramo della rotazione, a costo
// costante. Per questo, prima di ogni comparsa, UseStaticAnimation da' il
// cerchio SVG di questa unit a ogni animazione rimasta senza immagine, nella
// schermata di avvio e nella finestra di attesa di ogni programma (WT, Gesty
// e gli altri che hanno ancora l'Animation1 vuota). Un'immagine scelta nella
// definizione resta: e' responsabilita' di chi la sceglie non usare una GIF
// animata.

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Math,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  dxGDIPlusClasses,
  dxSplashForms;

type
  // Il monitor su cui l'utente lavora. All'avvio non esiste nessuna finestra
  // dell'applicazione a cui chiederlo, e il puntatore del mouse non aiuta:
  // chi lancia il programma da un'icona sul primo schermo e lavora sul quarto
  // ha il mouse sul primo. L'unica risposta affidabile e' dove stava la
  // finestra principale alla chiusura precedente.
  //
  // Ordine di ricerca: posizione ricordata, finestra principale, finestra
  // attiva, puntatore del mouse, monitor primario. La scelta si fa una volta
  // per avvio, cosi' schermata, finestra di accesso e finestra principale
  // finiscono tutte sullo stesso monitor.
  TWorkingMonitor = class abstract
  strict private
    class var FFileName: string;
    class var FSection: string;
    class var FKey: string;
    // Si conserva il punto e non il TMonitor: Screen ricrea gli oggetti
    // TMonitor quando cambia la configurazione degli schermi, e un
    // riferimento tenuto da parte diventerebbe un puntatore a memoria liberata
    class var FChosenPoint: TPoint;
    class var FChosen: Boolean;
    class function EffectiveFileName: string;
    class function EffectiveSection: string;
    class function EffectiveKey: string;
    class function LastSessionMonitor: TMonitor;
    class function FindMonitor: TMonitor;
  public
    // Dove ricordare la posizione. Senza chiamata: il file .login accanto
    // all'eseguibile, sezione nome del computer, voce SchermoDiLavoro - gli
    // stessi in cui zPack tiene utente, connessione e skin.
    class procedure Configure(const FileName: string; const Section: string = '';
      const Key: string = '');

    // Il monitor di lavoro, scelto alla prima richiesta e poi mantenuto
    class function Monitor: TMonitor;

    // Segna dove sta la finestra, per il prossimo avvio. Da chiamare quando la
    // finestra principale si chiude.
    class procedure Remember(Form: TCustomForm);

    // Centra la finestra sull'area di lavoro del monitor indicato (nil = il
    // monitor di lavoro). Mette Position a poDesigned: con poScreenCenter,
    // finche' Application.MainForm e' nil, il monitor lo sceglierebbe Windows.
    class procedure CenterForm(Form: TForm; TargetMonitor: TMonitor = nil);

    // Dimentica la scelta fatta in questo avvio: la prossima richiesta rifa'
    // la ricerca
    class procedure Forget;
  end;

  // Funzionalita' comuni a schermata di avvio e finestra di attesa
  TSmartSplashBase = class abstract
  strict protected
    // Ricerca degli item senza sollevare eccezioni: i metodi nativi Text() e
    // Progress() sollevano EdxException se l'item non esiste.
    // ItemName vuoto = l'item predefinito.
    class function FindTextItem(SplashForm: TdxSplashFormBase;
      const ItemName: string = ''): TdxSplashFormBase.TText;
    class function FindProgressItem(SplashForm: TdxSplashFormBase;
      const ItemName: string = ''): TdxSplashFormBase.TProgress;

    // Imposta il testo dell'item indicato, o di quello predefinito se l'item
    // con quel nome non esiste. Ignora i testi vuoti.
    class procedure ApplyText(SplashForm: TdxSplashFormBase;
      const MessageText: string; const ItemName: string = '');
  public
    // Da' il cerchio SVG di questa unit (un solo fotogramma, fatto ruotare
    // da DevExpress) a ogni animazione senza immagine: con la GIF
    // predefinita la ricomparsa dopo una lunga pausa blocca il programma
    // (vedi l'intestazione). Le animazioni con un'immagine restano come sono.
    // La chiamano da sole le Show di questa unit; e' pubblica per chi usa
    // TdxSplashFormManager direttamente.
    class procedure UseStaticAnimation(SplashForm: TdxSplashFormBase);
  end;

  // Schermata di avvio: da usare nel .dpr dopo Application.Initialize, prima
  // della creazione dei moduli dati.
  TSmartSplashForm = class(TSmartSplashBase)
  strict private
    class var FShowing: Boolean;
    class var FPrepared: Boolean;
    class var FFormName: string;
    class var FLightFormName: string;
    class var FDarkFormName: string;
    class var FStatusItemName: string;
    class var FBeforeFirstShow: TProc;
    // Centro del monitor dell'ultima comparsa, per rimetterla li' dopo una
    // sospensione
    class var FLastShowCenter: TPoint;
    class function SplashForm: TdxSplashForm;
    class procedure Prepare;
    class procedure PlaceOn(TargetMonitor: TMonitor);
    class procedure ShowOn(TargetMonitor: TMonitor; const MessageText: string);
  public
    // Seleziona una schermata registrata nel gestore ('' = la predefinita)
    class procedure UseForm(const FormName: string);

    // Sceglie alla prima comparsa fra due schermate in base allo skin attivo:
    // quella scura se il fondo dello skin e' scuro. Se il nome non esiste
    // nella definizione resta la predefinita.
    class procedure UseFormForSkin(const LightFormName, DarkFormName: string);

    // True se il fondo dello skin attivo e' scuro: e' il criterio di
    // UseFormForSkin, pubblico perche' il programma scelga con lo stesso
    // criterio le proprie immagini (loghi chiari o scuri)
    class function IsDarkSkin: Boolean;

    // Nome dell'item di testo in cui scrivere i messaggi di stato ('' =
    // l'item predefinito). Nelle schermate di WT, Gesty e zTicser e' 'Stato'.
    class procedure UseStatusText(const ItemName: string);

    // Procedura eseguita una sola volta, prima che la definizione della
    // schermata venga letta: e' il posto per applicare lo skin dell'ultima
    // sessione. I colori Default della definizione li decide il painter
    // attivo quando la definizione si carica, e il fondo chiaro o scuro
    // decide anche la scelta di UseFormForSkin.
    class procedure BeforeFirstShow(Proc: TProc);

    // Mostra la schermata al centro del monitor di lavoro
    class procedure Show(const MessageText: string = '');
    // Mostra la schermata al centro del monitor indicato
    class procedure ShowOnMonitor(TargetMonitor: TMonitor;
      const MessageText: string = '');
    // Mostra la schermata sul monitor che ospita il controllo indicato
    class procedure ShowOnMonitorOf(AnchorControl: TWinControl;
      const MessageText: string = '');

    // Aggiorna il testo di stato; non fa niente se la schermata non e' a video
    class procedure Update(const MessageText: string); overload;
    class procedure Update(const FormatText: string;
      const Arguments: array of const); overload;

    // Passa la barra di avanzamento in modalita' determinata e ne imposta il
    // valore; il messaggio, se indicato, viene aggiornato insieme
    class procedure UpdateProgress(Value: Int64; const MessageText: string = '');
    class procedure SetProgressRange(MinValue, MaxValue: Int64);
    // Riporta la barra di avanzamento in modalita' indeterminata
    class procedure SetIndeterminate;

    class procedure Hide;
    class function IsShowing: Boolean;

    // Nasconde la schermata per lasciare il posto a una finestra modale (la
    // finestra di accesso, un dialogo): la schermata e' sempre sopra, e la
    // finestra le finirebbe sotto. Restituisce True se era a video, e in
    // TargetMonitor il monitor su cui stava, dove aprire la finestra modale.
    class function Suspend(out TargetMonitor: TMonitor): Boolean;
    // Rimette la schermata, sullo stesso monitor, se Suspend l'aveva tolta
    class procedure Resume(WasShowing: Boolean);
  end;

  // Finestra di attesa centrata su un controllo.
  //
  // Show e Hide sono bilanciati da un contatore: le chiamate annidate sono
  // sicure e la finestra scompare solo quando ogni Show ha avuto la sua Hide.
  // I messaggi delle chiamate annidate sono gestiti a pila: alla Hide torna
  // il messaggio della chiamata esterna.
  //
  // Il bersaglio si sceglie fra il controllo indicato, il suo form, il form
  // attivo e la finestra principale, scartando quelli senza finestra, nascosti
  // o ridotti a icona. Se non ce n'e' nessuno e la schermata di avvio e' a
  // video, i messaggi vanno sulla schermata: e' il caso delle attese chieste
  // dai moduli dati durante l'avvio. Se il bersaglio viene distrutto mentre
  // l'attesa e' a video, la finestra si sposta su un altro bersaglio valido.
  //
  // La larghezza della finestra segue il testo: quella della definizione e'
  // pensata per il messaggio piu' lungo, e con "Attendere..." resterebbe quasi
  // vuota. Ad ogni messaggio la larghezza viene ricalcolata (minimo 120 pixel
  // di testo a 96 DPI, massimo meta' dell'area di lavoro del monitor) e il
  // testo che non ci sta viene troncato con i puntini di sospensione.
  TSmartWaitForm = class(TSmartSplashBase)
  strict private
    type
      // Dove si vede l'attesa: nessun posto, la finestra di attesa, la riga
      // di stato della schermata di avvio
      TWaitDestination = (wdNone, wdWaitForm, wdSplashForm);
    class var FShowCount: Integer;
    class var FFormName: string;
    class var FMessages: TList<string>;
    class var FDestination: TWaitDestination;
    // Controllo richiesto dalla Show esterna, per rimettere l'attesa sullo
    // stesso bersaglio dopo un dialogo, e controllo su cui l'attesa e' a
    // video. Sorvegliati entrambi: un riferimento a un controllo distrutto
    // verrebbe letto alla ripresa.
    class var FTarget: TWinControl;
    class var FShownTarget: TWinControl;
    class var FDialogCount: Integer;
    class var FSplashSuspendedForDialog: Boolean;
    // Finestre di attesa create al posto di quelle perse, per dare un nome
    // univoco alla successiva; dopo una sostituzione fallita non si riprova
    class var FRecoveryCount: Integer;
    class var FRecoveryFailed: Boolean;
    class constructor Create;
    class destructor Destroy;
    // La finestra di attesa in uso; se quella del gestore e' stata persa la
    // sostituisce prima di restituirla
    class function WaitForm: TdxWaitForm;
    class function ReplaceLostWaitForm(LostForm: TdxWaitForm;
      const Reason: string): TdxWaitForm;
    // Esegue Action sulla finestra di attesa senza lasciar uscire le
    // eccezioni della libreria: le registra e restituisce False
    class function TryWaitForm(const Operation: string;
      const Action: TProc<TdxWaitForm>): Boolean;
    class procedure ReportProblem(const Text: string);
    class function IsValidTarget(Control: TWinControl): Boolean;
    class function ResolveTarget(TargetControl: TWinControl): TWinControl;
    class function IsSuspended: Boolean;
    // Tronca con "..." le righe piu' larghe di MaximumWidth e restituisce in
    // LongestLine la larghezza in pixel della riga piu' larga rimasta
    class function FitMessage(const MessageText: string;
      TextItem: TdxSplashFormBase.TText; MaximumWidth: Integer;
      out LongestLine: Integer): string;
    // Adatta la larghezza della finestra di attesa al messaggio e lo applica.
    // TargetControl <> nil = prima della Show (la finestra viene posizionata
    // dalla Show); nil = finestra gia' a video, che viene allargata restando
    // centrata.
    class procedure ApplyMessage(const MessageText: string;
      TargetControl: TWinControl);
    class procedure ShowText(const MessageText: string);
    class procedure ShowOn(Target: TWinControl);
    class procedure UpdateWatch;
  private
    // Chiamata dall'osservatore interno (stessa unit)
    class procedure ComponentDestroyed(Component: TComponent);
  public
    // Avviso dei guasti della finestra di attesa (finestra persa, eccezione
    // della libreria), per il registro del programma: il testo dice anche
    // quale eccezione ha chiuso il thread di disegno. Senza gestore i guasti
    // vanno solo in OutputDebugString.
    class var OnProblem: TProc<string>;
  public
    // Seleziona una finestra di attesa registrata nel gestore ('' = la
    // predefinita)
    class procedure UseForm(const FormName: string);

    // Rete di sicurezza per i programmi con StartWait senza try/finally:
    // quando l'applicazione torna inattiva (coda dei messaggi vuota nel ciclo
    // principale o in un ciclo modale) nessun lavoro e' in corso nel thread
    // principale, quindi un'attesa ancora a video e' una StopWait mancata, e
    // la si chiude. Spenta di serie: un dialogo aperto a meta' lavoro la fa
    // scattare.
    class procedure CloseWhenIdle(Enabled: Boolean);

    // Mostra la finestra di attesa centrata sul form attivo (o sulla
    // finestra principale)
    class procedure Show(const MessageText: string = ''); overload;
    // Mostra la finestra di attesa centrata sul controllo indicato
    class procedure Show(TargetControl: TWinControl;
      const MessageText: string = ''); overload;

    // Aggiorna il messaggio corrente
    class procedure Update(const MessageText: string); overload;
    class procedure Update(const FormatText: string;
      const Arguments: array of const); overload;

    // Aggiorna l'item Progress, se la finestra di attesa ne contiene uno
    // (quella predefinita non lo ha)
    class procedure UpdateProgress(Value: Int64; MaxValue: Int64 = 100);

    // Decrementa il contatore e nasconde la finestra quando arriva a zero;
    // con ForceHide = True azzera il contatore e nasconde subito
    class procedure Hide(ForceHide: Boolean = False);

    // Mostra la finestra di attesa, esegue Work e garantisce la Hide finale
    class procedure Execute(const MessageText: string; Work: TProc); overload;
    class procedure Execute(TargetControl: TWinControl;
      const MessageText: string; Work: TProc); overload;

    class function IsShowing: Boolean;

    // La finestra di attesa in uso (dopo una sostituzione non e' piu' quella
    // registrata nel gestore con il nome scelto da UseForm)
    class function ActiveWaitForm: TdxWaitForm;

    // Da chiamare attorno a ogni dialogo modale (zMsg.Confirm lo fa per
    // tutti i ConfirmOk, ConfirmYesNo e simili). La finestra di attesa non e'
    // modale e non sta sopra le altre: un dialogo aperto a meta' lavoro
    // comparirebbe con "Attendere..." accanto, e l'utente non capirebbe se
    // tocca a lui. La schermata di avvio invece sta sopra, e il dialogo le
    // finirebbe sotto. Le due chiamate nascondono e rimettono le finestre
    // senza toccare il contatore: Show e Hide fatte nel frattempo restano
    // valide, e alla ResumeAfterDialog l'attesa torna solo se e' ancora
    // aperta. Si possono annidare.
    class procedure SuspendForDialog;
    class procedure ResumeAfterDialog;
  end;

implementation

uses
  System.IniFiles,
  Vcl.AppEvnts,
  cxLookAndFeels,
  cxLookAndFeelPainters;

const
  LastSessionExtension = '.login';
  // Il valore resta in italiano: e' la voce gia' scritta nei file .login
  WorkingMonitorKey = 'SchermoDiLavoro';

  // Cerchio grigio con un arco blu, 32 x 32, un solo fotogramma: lo stesso
  // dato ad Animation1 di zBuilder il 2026-10-17
  StaticAnimationSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">' +
    '<circle cx="16" cy="16" r="12" fill="none" stroke="#C8CDD2" stroke-width="4"/>' +
    '<path d="M16,4 A12,12 0 0 1 28,16" fill="none" stroke="#2B7CD3" stroke-width="4" stroke-linecap="round"/>' +
    '</svg>';

type
  // Riceve gli avvisi che una classe con soli metodi di classe non puo'
  // ricevere: la distruzione del bersaglio dell'attesa (FreeNotification) e
  // l'inattivita' dell'applicazione. Metodi di istanza e non class procedure:
  // un gestore di evento di classe metterebbe il riferimento di classe nel
  // campo Data del TMethod.
  TSmartSplashWaitObserver = class(TComponent)
  strict private
    FWatched: TList<TComponent>;
    FApplicationEvents: TApplicationEvents;
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Sorveglia solo i componenti indicati (i nil sono ignorati)
    procedure WatchOnly(const Targets: array of TComponent);
    procedure SetCloseWhenIdle(Enabled: Boolean);
  end;

  // Thread e Wnd sono strict protected in TdxSplashFormBase: li raggiunge un
  // metodo di una discendente, non una classe di solo cast. Si usa con un cast
  // sulla TdxWaitForm del gestore: nessun campo in piu', nessun metodo
  // virtuale.
  TWaitFormAccess = class(TdxWaitForm)
  public
    // True se la finestra e' stata creata e non esiste piu' (thread di disegno
    // finito, oppure finestra mai pronta: anche allora ogni chiamata
    // solleverebbe "Target HWND is 0"). In Reason l'eccezione che ha chiuso
    // il thread, se c'e'.
    function WindowLost(out Reason: string): Boolean;
  end;

var
  Observer: TSmartSplashWaitObserver = nil;

function ActiveObserver: TSmartSplashWaitObserver;
begin
  if Observer = nil then
    Observer := TSmartSplashWaitObserver.Create(nil);
  Result := Observer;
end;

function ComputerName: string;
var
  Buffer: array [0 .. MAX_COMPUTERNAME_LENGTH] of Char;
  Size: DWORD;
begin
  // Stessa forma di zSystem.ComputerName (maiuscolo), che e' la sezione del
  // file .login
  Size := Length(Buffer);
  if GetComputerName(Buffer, Size) then
    SetString(Result, Buffer, Size)
  else
    Result := '';
  Result := UpperCase(Result);
end;

// ---------------------------------------------------------------------------
// TSmartSplashWaitObserver
// ---------------------------------------------------------------------------

constructor TSmartSplashWaitObserver.Create(AOwner: TComponent);
begin
  inherited;
  FWatched := TList<TComponent>.Create;
end;

destructor TSmartSplashWaitObserver.Destroy;
begin
  WatchOnly([]);
  FreeAndNil(FWatched);
  inherited;
end;

procedure TSmartSplashWaitObserver.WatchOnly(const Targets: array of TComponent);
var
  Item: TComponent;
begin
  for Item in FWatched do
    Item.RemoveFreeNotification(Self);
  FWatched.Clear;

  for Item in Targets do
    if (Item <> nil) and (FWatched.IndexOf(Item) < 0) then
    begin
      FWatched.Add(Item);
      Item.FreeNotification(Self);
    end;
end;

procedure TSmartSplashWaitObserver.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  // FWatched e' nil durante la distruzione dell'osservatore stesso
  if (Operation = opRemove) and (FWatched <> nil) and (FWatched.Remove(AComponent) >= 0) then
    TSmartWaitForm.ComponentDestroyed(AComponent);
end;

procedure TSmartSplashWaitObserver.SetCloseWhenIdle(Enabled: Boolean);
begin
  if Enabled and (FApplicationEvents = nil) then
  begin
    FApplicationEvents := TApplicationEvents.Create(Self);
    FApplicationEvents.OnIdle := ApplicationIdle;
  end
  else
    if not Enabled then
      FreeAndNil(FApplicationEvents);
end;

procedure TSmartSplashWaitObserver.ApplicationIdle(Sender: TObject;
  var Done: Boolean);
begin
  if TSmartWaitForm.IsShowing then
  begin
    OutputDebugString('zz.SplashWait: attesa chiusa all''inattivita'', manca una StopWait');
    TSmartWaitForm.Hide(True);
  end;
end;

// ---------------------------------------------------------------------------
// TWaitFormAccess
// ---------------------------------------------------------------------------

function TWaitFormAccess.WindowLost(out Reason: string): Boolean;
begin
  Reason := '';

  // Mai mostrata: il thread nasce alla prima Show
  if Thread = nil then
    Exit(False);

  Result := Thread.Finished or (Wnd = 0) or not IsWindow(Wnd);
  if Result and (Thread.FatalException is Exception) then
    Reason := Exception(Thread.FatalException).ClassName + ': ' +
      Exception(Thread.FatalException).Message;
end;

// ---------------------------------------------------------------------------
// TWorkingMonitor
// ---------------------------------------------------------------------------

class procedure TWorkingMonitor.Configure(const FileName, Section, Key: string);
begin
  FFileName := FileName;
  FSection := Section;
  FKey := Key;
end;

class function TWorkingMonitor.EffectiveFileName: string;
begin
  Result := FFileName;
  if Result = '' then
    Result := ChangeFileExt(Application.ExeName, LastSessionExtension);
end;

class function TWorkingMonitor.EffectiveSection: string;
begin
  Result := FSection;
  if Result = '' then
    Result := ComputerName;
end;

class function TWorkingMonitor.EffectiveKey: string;
begin
  Result := FKey;
  if Result = '' then
    Result := WorkingMonitorKey;
end;

class procedure TWorkingMonitor.Remember(Form: TCustomForm);
var
  Ini: TIniFile;
begin
  if Form = nil then
    Exit;

  // Ridotta a icona Left e Top valgono -32000: non dicono niente
  if Form.WindowState = wsMinimized then
    Exit;

  try
    Ini := TIniFile.Create(EffectiveFileName);
    try
      // Il centro, non l'angolo: una finestra ingrandita ha l'angolo sul
      // bordo del monitor, e con i monitor affiancati il bordo appartiene gia'
      // a quello accanto
      Ini.WriteString(EffectiveSection, EffectiveKey,
        Format('%d,%d', [Form.Left + Form.Width div 2, Form.Top + Form.Height div 2]));
    finally
      FreeAndNil(Ini);
    end;
  except
    // Cartella in sola lettura o file bloccato: perdere la posizione non deve
    // impedire la chiusura del programma
  end;
end;

class function TWorkingMonitor.LastSessionMonitor: TMonitor;
var
  Ini: TIniFile;
  SavedValue: string;
  Parts: TArray<string>;
  Point: TPoint;
begin
  Result := nil;

  Ini := TIniFile.Create(EffectiveFileName);
  try
    SavedValue := Ini.ReadString(EffectiveSection, EffectiveKey, '');
  finally
    FreeAndNil(Ini);
  end;

  Parts := SavedValue.Split([',']);
  if Length(Parts) < 2 then
    Exit;

  Point.X := StrToIntDef(Parts[0].Trim, MaxInt);
  Point.Y := StrToIntDef(Parts[1].Trim, MaxInt);
  if (Point.X = MaxInt) or (Point.Y = MaxInt) then
    Exit;

  // mdNull: un monitor staccato fa cadere il punto nel vuoto, e allora non si
  // usa invece di ripiegare sul piu' vicino, che potrebbe essere sbagliato
  Result := Screen.MonitorFromPoint(Point, mdNull);
end;

class function TWorkingMonitor.FindMonitor: TMonitor;
begin
  Result := LastSessionMonitor;

  if (Result = nil) and (Application.MainForm <> nil) and Application.MainForm.HandleAllocated then
    Result := Screen.MonitorFromWindow(Application.MainForm.Handle, mdNull);

  if (Result = nil) and (Screen.ActiveCustomForm <> nil) and Screen.ActiveCustomForm.HandleAllocated then
    Result := Screen.MonitorFromWindow(Screen.ActiveCustomForm.Handle, mdNull);

  if Result = nil then
    Result := Screen.MonitorFromPoint(Mouse.CursorPos, mdNull);

  if Result = nil then
    Result := Screen.PrimaryMonitor;
end;

class function TWorkingMonitor.Monitor: TMonitor;
begin
  if FChosen then
  begin
    // mdNearest: se nel frattempo il monitor e' stato staccato si ripiega su
    // quello piu' vicino, invece di restare senza risposta
    Result := Screen.MonitorFromPoint(FChosenPoint, mdNearest);
    if Result <> nil then
      Exit;
  end;

  Result := FindMonitor;
  FChosenPoint := Result.WorkareaRect.CenterPoint;
  FChosen := True;
end;

class procedure TWorkingMonitor.Forget;
begin
  FChosen := False;
end;

class procedure TWorkingMonitor.CenterForm(Form: TForm; TargetMonitor: TMonitor);
var
  WorkArea: TRect;
begin
  if Form = nil then
    Exit;

  if TargetMonitor = nil then
    TargetMonitor := Monitor;

  WorkArea := TargetMonitor.WorkareaRect;

  // poDesigned, altrimenti alla comparsa poScreenCenter o poDesktopCenter
  // ricentrerebbero la finestra buttando via la posizione decisa qui
  Form.Position := poDesigned;
  Form.SetBounds(WorkArea.Left + (WorkArea.Width - Form.Width) div 2,
    WorkArea.Top + (WorkArea.Height - Form.Height) div 2, Form.Width, Form.Height);
end;

// ---------------------------------------------------------------------------
// TSmartSplashBase
// ---------------------------------------------------------------------------

class function TSmartSplashBase.FindTextItem(SplashForm: TdxSplashFormBase;
  const ItemName: string): TdxSplashFormBase.TText;
var
  Item: TdxSplashFormBase.TContentItem;
begin
  Result := nil;
  if SplashForm = nil then
    Exit;

  // Stessa logica di TdxSplashFormBase.FindItem, ma senza eccezione quando
  // l'item non esiste
  for Item in SplashForm.Content.Items do
    if Item is TdxSplashFormBase.TText then
      if ((ItemName = '') and Item.Default) or SameText(Item.Name, ItemName) then
        Exit(TdxSplashFormBase.TText(Item));
end;

class function TSmartSplashBase.FindProgressItem(SplashForm: TdxSplashFormBase;
  const ItemName: string): TdxSplashFormBase.TProgress;
var
  Item: TdxSplashFormBase.TContentItem;
begin
  Result := nil;
  if SplashForm = nil then
    Exit;

  for Item in SplashForm.Content.Items do
    if Item is TdxSplashFormBase.TProgress then
      if ((ItemName = '') and Item.Default) or SameText(Item.Name, ItemName) then
        Exit(TdxSplashFormBase.TProgress(Item));
end;

class procedure TSmartSplashBase.ApplyText(SplashForm: TdxSplashFormBase;
  const MessageText, ItemName: string);
var
  TextItem: TdxSplashFormBase.TText;
begin
  if MessageText.IsEmpty then
    Exit;

  TextItem := nil;
  if ItemName <> '' then
    TextItem := FindTextItem(SplashForm, ItemName);
  if TextItem = nil then
    TextItem := FindTextItem(SplashForm);

  if (TextItem <> nil) and (TextItem.Text <> MessageText) then
    TextItem.Text := MessageText;
end;

class procedure TSmartSplashBase.UseStaticAnimation(SplashForm: TdxSplashFormBase);
var
  Item: TdxSplashFormBase.TContentItem;
  Animation: TdxSplashFormBase.TAnimation;
  Circle: TdxSmartImage;
  Stream: TStringStream;
begin
  if SplashForm = nil then
    Exit;

  Circle := nil;
  try
    try
      for Item in SplashForm.Content.Items do
      begin
        if not (Item is TdxSplashFormBase.TAnimation) then
          Continue;
        Animation := TdxSplashFormBase.TAnimation(Item);
        // Dopo la prima assegnazione l'immagine c'e': le comparse successive
        // non toccano piu' il contenuto (l'assegnazione prende il lucchetto)
        if not Animation.Image.Empty then
          Continue;

        if Circle = nil then
        begin
          Circle := TdxSmartImage.Create;
          Stream := TStringStream.Create(StaticAnimationSvg, TEncoding.UTF8);
          try
            Circle.LoadFromStream(Stream);
          finally
            Stream.Free;
          end;
        end;
        // SetImage copia l'immagine (Assign)
        Animation.Image := Circle;
      end;
    except
      on E: Exception do
        // Senza cerchio resta la GIF predefinita: la comparsa non deve fallire
        OutputDebugString(PChar('zz.SplashWait: cerchio di attesa non assegnato: ' +
          E.ClassName + ': ' + E.Message));
    end;
  finally
    Circle.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TSmartSplashForm
// ---------------------------------------------------------------------------

class function TSmartSplashForm.SplashForm: TdxSplashForm;
begin
  Result := TdxSplashFormManager.SplashForm(FFormName);
end;

class procedure TSmartSplashForm.UseForm(const FormName: string);
begin
  if FShowing then
    Exit;
  FFormName := FormName;
end;

class procedure TSmartSplashForm.UseFormForSkin(const LightFormName, DarkFormName: string);
begin
  FLightFormName := LightFormName;
  FDarkFormName := DarkFormName;
end;

class procedure TSmartSplashForm.UseStatusText(const ItemName: string);
begin
  FStatusItemName := ItemName;
end;

class procedure TSmartSplashForm.BeforeFirstShow(Proc: TProc);
begin
  FBeforeFirstShow := Proc;
end;

class function TSmartSplashForm.IsDarkSkin: Boolean;
var
  Painter: TcxCustomLookAndFeelPainter;
  Background: TColor;
begin
  Painter := RootLookAndFeel.Painter;
  if Painter = nil then
    Exit(False);

  // Lo stesso colore da cui la schermata prende il fondo Default
  // (TContent.UpdateDefaultColors usa LayoutControlEmptyAreaColor)
  Background := Painter.LayoutControlEmptyAreaColor;
  // Lo skin restituisce il colore del layout anche quando non e' valorizzato:
  // clDefault e clNone non sono convertiti da ColorToRGB e darebbero
  // luminosita' 0, cioe' sempre "scuro" anche su un fondo chiaro
  if (Background = clDefault) or (Background = clNone) then
    Background := Painter.DefaultContentColor;
  Background := ColorToRGB(Background);

  // Luminosita' percepita (pesi ITU-R BT.601), da 0 a 255
  Result := (GetRValue(Background) * 299 + GetGValue(Background) * 587 + GetBValue(Background) * 114) div 1000 < 128;
end;

class procedure TSmartSplashForm.Prepare;
var
  FormName: string;
  Candidate: TdxSplashFormBase;
begin
  if FPrepared then
    Exit;
  FPrepared := True;

  // Prima di qualunque accesso a TdxSplashFormManager: e' il primo accesso a
  // caricare la definizione con i colori del painter attivo in quel momento
  if Assigned(FBeforeFirstShow) then
    FBeforeFirstShow();

  if (FLightFormName = '') and (FDarkFormName = '') then
    Exit;

  if IsDarkSkin then
    FormName := FDarkFormName
  else
    FormName := FLightFormName;

  if FormName = '' then
    Exit;

  // FindSplashForm e non SplashForm(FormName): se la voce manca nella
  // definizione si resta sulla predefinita invece di sollevare un'eccezione
  // all'avvio
  Candidate := TdxSplashFormManager.FindSplashForm(TdxSplashFormKind.Splash, FormName);
  if Candidate <> nil then
  begin
    FFormName := FormName;
    // Anche predefinita, per chi chiama ancora TdxSplashFormManager.SplashForm
    // senza nome
    Candidate.Default := True;
  end;
end;

class procedure TSmartSplashForm.PlaceOn(TargetMonitor: TMonitor);
var
  Splash: TdxSplashForm;
  Center: TPoint;
begin
  Splash := SplashForm;

  // Custom: la posizione la decide questa unit. Con Default la libreria
  // centrerebbe sul monitor della finestra in primo piano, che all'avvio non
  // e' dell'applicazione.
  Splash.Position := TdxSplashFormPosition.Custom;

  Center := TargetMonitor.WorkareaRect.CenterPoint;

  // Content.Width corrente, non riscalata: e' lo stesso valore che la
  // libreria assegna a Width nella Show e da cui ricava il centro. Width e
  // Height della schermata non vanno usate: prima della prima comparsa
  // valgono i 468 x 338 del costruttore, dopo comprendono bordo e scala.
  Splash.Left := Center.X - Splash.Content.Width div 2;
  Splash.Top := Center.Y - Splash.Content.Height div 2;

  FLastShowCenter := Center;
end;

class procedure TSmartSplashForm.ShowOn(TargetMonitor: TMonitor;
  const MessageText: string);
begin
  if FShowing then
  begin
    // A video non si riposiziona: la libreria ignorerebbe comunque la nuova
    // posizione fino alla prossima comparsa
    Update(MessageText);
    Exit;
  end;

  Prepare;
  UseStaticAnimation(SplashForm);

  if TargetMonitor = nil then
    TargetMonitor := TWorkingMonitor.Monitor;

  // Ricalcolata a ogni comparsa: dopo la prima Content.Width e' alla scala
  // dell'ultimo monitor, e una Left vecchia scentrerebbe la schermata
  PlaceOn(TargetMonitor);

  // Testo impostato prima della Show per evitare il lampo del testo di
  // definizione
  ApplyText(SplashForm, MessageText, FStatusItemName);
  SplashForm.Show;
  FShowing := True;
end;

class procedure TSmartSplashForm.Show(const MessageText: string);
begin
  ShowOn(nil, MessageText);
end;

class procedure TSmartSplashForm.ShowOnMonitor(TargetMonitor: TMonitor;
  const MessageText: string);
begin
  ShowOn(TargetMonitor, MessageText);
end;

class procedure TSmartSplashForm.ShowOnMonitorOf(AnchorControl: TWinControl;
  const MessageText: string);
var
  TargetMonitor: TMonitor;
begin
  TargetMonitor := nil;
  if (AnchorControl <> nil) and AnchorControl.HandleAllocated then
    TargetMonitor := Screen.MonitorFromWindow(AnchorControl.Handle, mdNull);
  ShowOn(TargetMonitor, MessageText);
end;

class procedure TSmartSplashForm.Update(const MessageText: string);
begin
  // Senza schermata a video non si tocca il gestore: il primo accesso
  // caricherebbe la definizione prima di BeforeFirstShow
  if not FShowing then
    Exit;
  ApplyText(SplashForm, MessageText, FStatusItemName);
end;

class procedure TSmartSplashForm.Update(const FormatText: string;
  const Arguments: array of const);
begin
  Update(Format(FormatText, Arguments));
end;

class procedure TSmartSplashForm.UpdateProgress(Value: Int64;
  const MessageText: string);
var
  ProgressItem: TdxSplashFormBase.TProgress;
begin
  if not FShowing then
    Exit;

  ProgressItem := FindProgressItem(SplashForm);
  if ProgressItem <> nil then
  begin
    if ProgressItem.IndeterminateMode <> TdxSplashFormBase.TProgress.TIndeterminateMode.None then
      ProgressItem.IndeterminateMode := TdxSplashFormBase.TProgress.TIndeterminateMode.None;
    ProgressItem.Value := Value;
  end;

  Update(MessageText);
end;

class procedure TSmartSplashForm.SetProgressRange(MinValue, MaxValue: Int64);
var
  ProgressItem: TdxSplashFormBase.TProgress;
begin
  if not FShowing then
    Exit;

  ProgressItem := FindProgressItem(SplashForm);
  if ProgressItem <> nil then
  begin
    ProgressItem.MinValue := MinValue;
    ProgressItem.MaxValue := MaxValue;
  end;
end;

class procedure TSmartSplashForm.SetIndeterminate;
var
  ProgressItem: TdxSplashFormBase.TProgress;
begin
  if not FShowing then
    Exit;

  ProgressItem := FindProgressItem(SplashForm);
  if ProgressItem <> nil then
    ProgressItem.IndeterminateMode := TdxSplashFormBase.TProgress.TIndeterminateMode.PingPong;
end;

class procedure TSmartSplashForm.Hide;
begin
  if not FShowing then
    Exit;

  FShowing := False;
  SplashForm.Hide;
end;

class function TSmartSplashForm.IsShowing: Boolean;
begin
  Result := FShowing;
end;

class function TSmartSplashForm.Suspend(out TargetMonitor: TMonitor): Boolean;
begin
  TargetMonitor := nil;
  Result := FShowing;
  if not Result then
    Exit;

  TargetMonitor := Screen.MonitorFromPoint(FLastShowCenter, mdNearest);
  Hide;
end;

class procedure TSmartSplashForm.Resume(WasShowing: Boolean);
begin
  if WasShowing then
    ShowOn(Screen.MonitorFromPoint(FLastShowCenter, mdNearest), '');
end;

// ---------------------------------------------------------------------------
// TSmartWaitForm
// ---------------------------------------------------------------------------

class constructor TSmartWaitForm.Create;
begin
  FMessages := TList<string>.Create;
end;

class destructor TSmartWaitForm.Destroy;
begin
  FreeAndNil(Observer);
  FMessages.Free;
end;

class function TSmartWaitForm.WaitForm: TdxWaitForm;
var
  Reason: string;
begin
  Result := TdxSplashFormManager.WaitForm(FFormName);
  if not FRecoveryFailed and TWaitFormAccess(Result).WindowLost(Reason) then
    Result := ReplaceLostWaitForm(Result, Reason);
end;

class function TSmartWaitForm.ActiveWaitForm: TdxWaitForm;
begin
  Result := WaitForm;
end;

class function TSmartWaitForm.ReplaceLostWaitForm(LostForm: TdxWaitForm;
  const Reason: string): TdxWaitForm;
var
  Description: string;
begin
  Description := 'finestra di attesa ' + LostForm.Name +
    ' persa (thread di disegno di DevExpress finito)';
  if Reason <> '' then
    Description := Description + ', causa ' + Reason;

  // La finestra persa non e' piu' a video: Hide non deve cercarla
  if FDestination = wdWaitForm then
    FDestination := wdNone;

  try
    Inc(FRecoveryCount);
    // La vecchia resta nella lista del gestore: toglierla ne chiamerebbe il
    // distruttore e, se era la predefinita, la scelta di un'altra predefinita.
    // Resta un oggetto inutile per ogni guasto, cioe' quasi niente.
    Result := TdxSplashFormManager.AddSplashForm(TdxSplashFormKind.Wait,
      Format('%s_Ripristino%d', [LostForm.Name, FRecoveryCount])) as TdxWaitForm;
    Result.Content.Assign(LostForm.Content);
    Result.BorderStyle := LostForm.BorderStyle;
    // Anche predefinita, per chi chiama TdxSplashFormManager.WaitForm senza nome
    if LostForm.Default then
      Result.Default := True;
    FFormName := Result.Name;
    ReportProblem(Description + ', sostituita da ' + Result.Name);
  except
    on E: Exception do
    begin
      FRecoveryFailed := True;
      ReportProblem(Description + ', sostituzione non riuscita: ' +
        E.ClassName + ': ' + E.Message);
      Result := LostForm;
    end;
  end;
end;

class function TSmartWaitForm.TryWaitForm(const Operation: string;
  const Action: TProc<TdxWaitForm>): Boolean;
begin
  // Ingoiare l'eccezione non lascia stati a meta' (verificato su
  // dxSplashForms): InvokeSync solleva dopo aver rilasciato il suo lucchetto
  // e libera il pacchetto nel finally, DoHide chiude il suo evento nel
  // finally, e i limiti scritti da Prepare li riscrive la Show successiva
  try
    Action(WaitForm);
    Result := True;
  except
    on E: Exception do
    begin
      ReportProblem(Format('finestra di attesa, %s non riuscita: %s: %s',
        [Operation, E.ClassName, E.Message]));
      Result := False;
    end;
  end;
end;

class procedure TSmartWaitForm.ReportProblem(const Text: string);
begin
  OutputDebugString(PChar('zz.SplashWait: ' + Text));
  if Assigned(OnProblem) then
    try
      OnProblem(Text);
    except
      // Il registro del programma non deve rompere l'attesa
    end;
end;

class function TSmartWaitForm.IsValidTarget(Control: TWinControl): Boolean;
begin
  // La libreria legge GetWindowRect del controllo: senza finestra la
  // creerebbe (o solleverebbe "Control has no parent window"), nascosto o
  // ridotto a icona darebbe un rettangolo vecchio o a -32000
  Result := (Control <> nil) and Control.HandleAllocated and
    IsWindowVisible(Control.Handle) and not IsIconic(GetAncestor(Control.Handle, GA_ROOT));
end;

class function TSmartWaitForm.ResolveTarget(TargetControl: TWinControl): TWinControl;
begin
  if IsValidTarget(TargetControl) then
    Exit(TargetControl);

  if TargetControl <> nil then
  begin
    Result := GetParentForm(TargetControl);
    if IsValidTarget(Result) then
      Exit;
  end;

  Result := Screen.ActiveCustomForm;
  if IsValidTarget(Result) then
    Exit;

  Result := Application.MainForm;
  if IsValidTarget(Result) then
    Exit;

  Result := nil;
end;

class function TSmartWaitForm.IsSuspended: Boolean;
begin
  Result := FDialogCount > 0;
end;

class function TSmartWaitForm.FitMessage(const MessageText: string;
  TextItem: TdxSplashFormBase.TText; MaximumWidth: Integer;
  out LongestLine: Integer): string;
const
  Ellipsis = '...';
var
  Bitmap: TBitmap;
  Lines: TArray<string>;
  Index: Integer;
  LowerBound: Integer;
  UpperBound: Integer;
  Middle: Integer;
  Line: string;
begin
  LongestLine := 0;
  Bitmap := TBitmap.Create;
  try
    // Altezza negativa = pixel, come il carattere della finestra di attesa
    // (GDI+ con unita' pixel): la misura coincide a meno di qualche pixel,
    // coperto dal margine aggiunto dal chiamante
    Bitmap.Canvas.Font.Name := TextItem.FontName;
    Bitmap.Canvas.Font.Height := -Abs(TextItem.FontSize);
    if TextItem.FontStyle = TdxGPFontStyle.FontStyleBold then
      Bitmap.Canvas.Font.Style := [fsBold];

    Lines := MessageText.Split([sLineBreak]);
    for Index := 0 to High(Lines) do
    begin
      Line := Lines[Index];
      if Bitmap.Canvas.TextWidth(Line) > MaximumWidth then
      begin
        // Ricerca binaria del prefisso piu' lungo che, con i puntini, sta nel limite
        LowerBound := 0;
        UpperBound := Length(Line);
        while LowerBound < UpperBound do
        begin
          Middle := (LowerBound + UpperBound + 1) div 2;
          if Bitmap.Canvas.TextWidth(Copy(Line, 1, Middle) + Ellipsis) <= MaximumWidth then
            LowerBound := Middle
          else
            UpperBound := Middle - 1;
        end;
        Line := TrimRight(Copy(Line, 1, LowerBound)) + Ellipsis;
      end;
      Lines[Index] := Line;
      LongestLine := Max(LongestLine, Bitmap.Canvas.TextWidth(Line));
    end;
    Result := string.Join(sLineBreak, Lines);
  finally
    Bitmap.Free;
  end;
end;

class procedure TSmartWaitForm.ApplyMessage(const MessageText: string;
  TargetControl: TWinControl);
const
  // Misure a 96 DPI, riscalate sul PPI del contenuto
  RightMargin = 16;
  MeasureTolerance = 8;
  MinimumTextWidth = 120;
var
  Form: TdxWaitForm;
  Content: TdxSplashFormBase.TContent;
  TextItem: TdxSplashFormBase.TText;
  Item: TdxSplashFormBase.TContentItem;
  TargetMonitor: TMonitor;
  ItemBounds: TRect;
  Margin: Integer;
  Tolerance: Integer;
  MinimumText: Integer;
  MaximumText: Integer;
  CurrentText: Integer;
  WantedText: Integer;
  LongestLine: Integer;
  TextRight: Integer;
  Delta: Integer;
  FittedText: string;
begin
  if MessageText.IsEmpty then
    Exit;

  // Letta una volta sola: una sostituzione a meta' lavoro darebbe testo e
  // contenuto di due finestre diverse
  Form := WaitForm;
  TextItem := FindTextItem(Form);
  if TextItem = nil then
    Exit;

  Content := Form.Content;
  // Prima della Show il contenuto passa subito al PPI del controllo (lo
  // farebbe anche la Show): la larghezza massima si calcola in pixel del
  // monitor, e Content.Width e' nella stessa unita'
  if (TargetControl <> nil) and TargetControl.HandleAllocated then
    Content.PPI := TargetControl.CurrentPPI;

  Margin := MulDiv(RightMargin, Content.PPI, 96);
  Tolerance := MulDiv(MeasureTolerance, Content.PPI, 96);
  MinimumText := MulDiv(MinimumTextWidth, Content.PPI, 96);

  // Monitor del controllo su cui compare la finestra (prima della Show) o
  // monitor in cui si trova gia' (negli aggiornamenti)
  TargetMonitor := nil;
  if (TargetControl <> nil) and TargetControl.HandleAllocated then
    TargetMonitor := Screen.MonitorFromWindow(TargetControl.Handle);
  if TargetMonitor = nil then
    TargetMonitor := Screen.MonitorFromPoint(
      Point(Form.Left + Form.Width div 2, Form.Top + Form.Height div 2));
  if TargetMonitor = nil then
    TargetMonitor := Screen.PrimaryMonitor;

  // Spazio disponibile al testo: da dove inizia fino al bordo destro meno il
  // margine
  MaximumText := Max(MinimumText,
    TargetMonitor.WorkareaRect.Width div 2 - TextItem.Bounds.Left - Margin);
  CurrentText := Max(1, Content.Width - TextItem.Bounds.Left - Margin);

  FittedText := FitMessage(MessageText, TextItem, MaximumText - Tolerance, LongestLine);
  WantedText := EnsureRange(LongestLine + Tolerance, MinimumText, MaximumText);

  Delta := WantedText - CurrentText;
  if Delta <> 0 then
  begin
    TextRight := TextItem.Bounds.Left + CurrentText;
    for Item in Content.Items do
    begin
      if Item = TextItem then
        Continue;
      ItemBounds := Item.Bounds;
      if ItemBounds.Left >= TextRight then
        // A destra del testo: si sposta
        ItemBounds.Offset(Delta, 0)
      else if ItemBounds.Right > TextItem.Bounds.Left + CurrentText div 2 then
        // Si estende sotto il testo (per esempio la barra di avanzamento): si allarga
        Inc(ItemBounds.Right, Delta)
      else
        Continue;
      Item.Bounds := ItemBounds;
    end;

    ItemBounds := TextItem.Bounds;
    ItemBounds.Width := WantedText;
    TextItem.Bounds := ItemBounds;

    Content.Width := Content.Width + Delta;

    // Finestra gia' a video: la allarga mantenendola centrata. SetBounds
    // passa dal thread di disegno, e con la finestra persa solleverebbe.
    if (TargetControl = nil) and (FDestination = wdWaitForm) then
      TryWaitForm('SetBounds',
        procedure(ActiveForm: TdxWaitForm)
        begin
          ActiveForm.SetBounds(ActiveForm.Left - Delta div 2, ActiveForm.Top,
            ActiveForm.Width + Delta, ActiveForm.Height);
        end);
  end;

  ApplyText(Form, FittedText);
end;

class procedure TSmartWaitForm.ShowText(const MessageText: string);
begin
  // Anche durante un dialogo: cambiare il testo di una finestra nascosta e'
  // innocuo, e alla ripresa compare quello giusto
  case FDestination of
    wdWaitForm:
      ApplyMessage(MessageText, nil);
    wdSplashForm:
      TSmartSplashForm.Update(MessageText);
  end;
end;

class procedure TSmartWaitForm.UpdateWatch;
begin
  if (FTarget = nil) and (FShownTarget = nil) and (Observer = nil) then
    Exit;
  ActiveObserver.WatchOnly([FTarget, FShownTarget]);
end;

class procedure TSmartWaitForm.ShowOn(Target: TWinControl);
begin
  FShownTarget := Target;

  if Target <> nil then
  begin
    UseStaticAnimation(WaitForm);
    // Testo e larghezza impostati prima della Show per evitare il lampo del
    // testo di definizione ("Please wait...") e di una finestra della
    // larghezza sbagliata
    if FMessages.Count > 0 then
      ApplyMessage(FMessages.Last, Target);
    // La destinazione si fissa dopo la Show: se la libreria solleva l'attesa
    // prosegue senza finestra, e la StopWait del chiamante resta bilanciata
    if TryWaitForm('Show',
      procedure(ActiveForm: TdxWaitForm)
      begin
        ActiveForm.Show(Target);
      end) then
      FDestination := wdWaitForm
    else
      FDestination := wdNone;
  end
  else
    if TSmartSplashForm.IsShowing then
    begin
      FDestination := wdSplashForm;
      if FMessages.Count > 0 then
        TSmartSplashForm.Update(FMessages.Last);
    end
    else
      FDestination := wdNone;

  UpdateWatch;
end;

class procedure TSmartWaitForm.UseForm(const FormName: string);
begin
  // Non cambiare finestra mentre e' a video: contatore e pila dei messaggi si
  // riferiscono a quella corrente
  if FShowCount > 0 then
    Exit;
  FFormName := FormName;
end;

class procedure TSmartWaitForm.CloseWhenIdle(Enabled: Boolean);
begin
  ActiveObserver.SetCloseWhenIdle(Enabled);
end;

class procedure TSmartWaitForm.Show(const MessageText: string);
begin
  Show(nil, MessageText);
end;

class procedure TSmartWaitForm.Show(TargetControl: TWinControl;
  const MessageText: string);
var
  DisplayText: string;
begin
  // Chiamata annidata senza messaggio: mantiene il messaggio corrente
  if MessageText.IsEmpty and (FMessages.Count > 0) then
    DisplayText := FMessages.Last
  else
    DisplayText := MessageText;
  FMessages.Add(DisplayText);

  // Il contatore sale anche quando non c'e' niente su cui mostrarsi: la Hide
  // corrispondente arrivera' comunque, e non deve consumare quella di una
  // chiamata esterna
  Inc(FShowCount);

  if FShowCount = 1 then
  begin
    FTarget := TargetControl;
    // Durante un dialogo l'attesa resta in sospeso: la mostra
    // ResumeAfterDialog, se e' ancora aperta
    if IsSuspended then
      UpdateWatch
    else
      ShowOn(ResolveTarget(FTarget));
  end
  else
    ShowText(DisplayText);
end;

class procedure TSmartWaitForm.Update(const MessageText: string);
begin
  if (FShowCount = 0) or MessageText.IsEmpty then
    Exit;

  // Il messaggio aggiornato sostituisce quello in cima alla pila, cosi'
  // resta coerente con le Show e Hide annidate
  FMessages[FMessages.Count - 1] := MessageText;
  ShowText(MessageText);
end;

class procedure TSmartWaitForm.Update(const FormatText: string;
  const Arguments: array of const);
begin
  Update(Format(FormatText, Arguments));
end;

class procedure TSmartWaitForm.UpdateProgress(Value: Int64; MaxValue: Int64);
var
  ProgressItem: TdxSplashFormBase.TProgress;
begin
  if (FShowCount = 0) or (FDestination <> wdWaitForm) then
    Exit;

  ProgressItem := FindProgressItem(WaitForm);
  if ProgressItem = nil then
    Exit;

  if ProgressItem.IndeterminateMode <> TdxSplashFormBase.TProgress.TIndeterminateMode.None then
    ProgressItem.IndeterminateMode := TdxSplashFormBase.TProgress.TIndeterminateMode.None;
  ProgressItem.MaxValue := MaxValue;
  ProgressItem.Value := Value;
end;

class procedure TSmartWaitForm.Hide(ForceHide: Boolean);
begin
  if FShowCount = 0 then
    Exit;

  if ForceHide then
    FShowCount := 0
  else
    Dec(FShowCount);

  if FShowCount = 0 then
  begin
    FMessages.Clear;
    // Durante un dialogo la finestra e' gia' nascosta
    if (FDestination = wdWaitForm) and not IsSuspended then
      TryWaitForm('Hide',
        procedure(ActiveForm: TdxWaitForm)
        begin
          ActiveForm.Hide;
        end);
    FDestination := wdNone;
    FTarget := nil;
    FShownTarget := nil;
    UpdateWatch;
  end
  else
  begin
    // Ripristina il messaggio della chiamata esterna ancora attiva
    FMessages.Delete(FMessages.Count - 1);
    if FMessages.Count > 0 then
      ShowText(FMessages.Last);
  end;
end;

class procedure TSmartWaitForm.ComponentDestroyed(Component: TComponent);
begin
  if Component = FTarget then
    FTarget := nil;

  if Component <> FShownTarget then
    Exit;

  FShownTarget := nil;

  if (FShowCount = 0) or (FDestination <> wdWaitForm) or IsSuspended then
    Exit;

  // Il form su cui stava l'attesa si sta distruggendo: la finestra
  // resterebbe a video sul rettangolo di una finestra che non c'e' piu'.
  // Si sposta su un altro bersaglio valido, se ce n'e' uno. Il form che si
  // distrugge e' escluso da solo: non ha piu' la sua finestra.
  TryWaitForm('Hide',
    procedure(ActiveForm: TdxWaitForm)
    begin
      ActiveForm.Hide;
    end);
  ShowOn(ResolveTarget(FTarget));
end;

class procedure TSmartWaitForm.SuspendForDialog;
var
  SplashMonitor: TMonitor;
begin
  Inc(FDialogCount);
  if FDialogCount > 1 then
    Exit;

  if (FShowCount > 0) and (FDestination = wdWaitForm) then
  begin
    TryWaitForm('Hide',
      procedure(ActiveForm: TdxWaitForm)
      begin
        ActiveForm.Hide;
      end);
    FShownTarget := nil;
    UpdateWatch;
  end;

  // La schermata di avvio sta sopra le altre finestre: un dialogo aperto
  // durante l'avvio (un errore di connessione, una conferma) le finirebbe
  // sotto, e il programma sembrerebbe bloccato
  FSplashSuspendedForDialog := TSmartSplashForm.Suspend(SplashMonitor);
end;

class procedure TSmartWaitForm.ResumeAfterDialog;
begin
  if FDialogCount = 0 then
    Exit;

  Dec(FDialogCount);
  if FDialogCount > 0 then
    Exit;

  // Prima la schermata: se l'attesa non trova un form visibile, i suoi
  // messaggi tornano sulla schermata
  if FSplashSuspendedForDialog then
  begin
    FSplashSuspendedForDialog := False;
    TSmartSplashForm.Resume(True);
  end;

  // Il bersaglio si sceglie di nuovo: il dialogo puo' aver chiuso o
  // distrutto il form su cui stava l'attesa
  if FShowCount > 0 then
    ShowOn(ResolveTarget(FTarget));
end;

class procedure TSmartWaitForm.Execute(const MessageText: string; Work: TProc);
begin
  Execute(nil, MessageText, Work);
end;

class procedure TSmartWaitForm.Execute(TargetControl: TWinControl;
  const MessageText: string; Work: TProc);
begin
  Show(TargetControl, MessageText);
  try
    Work();
  finally
    Hide;
  end;
end;

class function TSmartWaitForm.IsShowing: Boolean;
begin
  Result := FShowCount > 0;
end;

end.
