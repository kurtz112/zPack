// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-03
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Ispezione
//
// Quello che la sonda sa leggere e fare dentro l'applicazione: form aperte,
// albero dei componenti, azioni, dataset, valori, immagine di una form.
//
// TUTTO SUL THREAD PRINCIPALE. Ogni funzione di questa unit tocca la VCL e
// va chiamata solo dal thread principale: Sonda.Server ce la porta con
// TThread.Queue.
//
// INDIRIZZI. Un componente si indica col percorso dei proprietari separato da
// punti, come in FrmApplicationInspector: "FormAnagrafica.actNuovo". Il primo
// pezzo e' il Name o la classe di una form aperta (o di un DataModule); gli
// altri sono Name di componenti. Se un pezzo non e' fra i componenti posseduti
// direttamente, si cerca anche piu' in profondita' (i frame possiedono i
// propri componenti): "FormAnagrafica.actNuovo" trova l'azione anche se sta
// dentro un frame. Se i candidati sono piu' di uno, l'errore li elenca.
// Un pezzo "ruolo:nome" (es. "FormProgetti.vista:Progetti.Elenco.actDbInsert")
// indica il componente per quello che mostra: lo risolve il ponte
// dell'applicazione (RisolutoreRuoloSonda), perche' solo lui conosce i frame
// generati dal dizionario LZ.
// Un componente senza Name (azioni e voci create dal codice) si indica con
// "(Classe)", "(Classe)#N" (l'N-esimo, da 1) o "(Classe)=Didascalia": gli
// indirizzi restituiti da azioni e componenti usano gia' l'ultima forma.
//
// VOCI DELLE BARRE DEVEXPRESS. Pulsanti, caselle di filtro e gallerie delle
// barre (TdxBarItem) non sono azioni e non hanno una finestra propria: si
// leggono e si azionano per nome con l'RTTI, senza dipendere da DevExpress.
// Premere una voce chiama TdxBarItem.Click, scrivere una casella assegna
// EditValue (che fa scattare OnChange): lo stesso percorso dell'utente.
//
// Unit di libreria: solo RTL e VCL, niente zPack ne' applicazione.
//
// ***************************************************************************

unit Sonda.Ispezione;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Types,
  Data.DB,
  Vcl.Controls,
  Vcl.Forms;

type
  ESonda = class(Exception);

  // Tasti tenuti premuti durante un clic (Ctrl+clic, Maiusc+clic).
  TModificatoreClic = (mcCtrl, mcMaiusc, mcAlt);
  TModificatoriClic = set of TModificatoreClic;

  // Il menu che comparirebbe col clic destro nel Punto (coordinate client di
  // Finestra, la finestra che ha ricevuto il clic): nil se il risolutore non
  // conosce il controllo, e allora vale la regola della VCL (PopupMenu del
  // controllo o dei genitori). Nota, se non vuota, finisce nella risposta (es.
  // la zona della griglia colpita).
  TRisolutoreMenuContestuale = reference to function(Finestra: TWinControl; const Punto: TPoint;
    out Nota: string): TComponent;
  // Le voci di un menu che non e' un TPopupMenu della VCL (TdxBarPopupMenu),
  // nell'ordine in cui l'utente le vede; vuoto se il menu non e' suo.
  TVociMenuContestuale = reference to function(Menu: TComponent): TArray<TComponent>;

  // Indirizzi per ruolo: un pezzo "ruolo:nome" (es. "vista:Progetti.Elenco")
  // indica un componente per quello che mostra, non per il Name che il
  // generatore delle form gli ha dato. Il nome puo' contenere un punto: il
  // pezzo con il ruolo si prende insieme al successivo.
  TRisolutoreRuolo = reference to function(Contenitore: TComponent; const Ruolo, Nome: string): TComponent;
  // Il pezzo "ruolo:nome" di un componente, vuoto se non ne ha uno.
  TDescrittoreRuolo = reference to function(Componente: TComponent): string;

  // Il clic su un componente senza finestra propria che l'utente clicca
  // comunque: la linguetta di una scheda, la cella di una colonna di griglia.
  // Restituisce il resoconto del clic; vuoto se il componente non e' suo, e
  // allora vale il clic normale. X e Y negativi = punto scelto dal clic.
  TClicSpeciale = reference to function(Componente: TComponent; X, Y: Integer; Doppio: Boolean;
    Modificatori: TModificatoriClic): string;

var
  // Li imposta il ponte dell'applicazione (Gesty.Sonda: viste, schede e
  // dataset delle form generate dal dizionario LZ). Senza, gli indirizzi per
  // ruolo non sono disponibili.
  RisolutoreRuoloSonda: TRisolutoreRuolo;
  DescrittoreRuoloSonda: TDescrittoreRuolo;

  // Li imposta Sonda.zBase (RegistraComandiSondaZBase): menu delle griglie
  // DevExpress (TcxGridPopupMenu) e voci dei TdxBarPopupMenu, che il nucleo
  // non conosce. Senza, il menu contestuale segue solo la regola della VCL.
  RisolutoreMenuContestualeSonda: TRisolutoreMenuContestuale;
  VociMenuContestualeSonda: TVociMenuContestuale;

  // Lo imposta Sonda.zBase: schede del layout e dei page control DevExpress,
  // colonne delle griglie. Senza, il clic su quei componenti chiede una
  // finestra che non hanno.
  ClicSpecialeSonda: TClicSpeciale;

// Form e DataModule aperti.
function ElencoForm: TJSONArray;

// Componente dall'indirizzo; solleva ESonda con i candidati se non lo trova.
function TrovaComponente(const Indirizzo: string): TComponent;

// Indirizzo completo di un componente, dalla form (o DataModule) in giu'.
function IndirizzoDi(Componente: TComponent): string;

// Albero dei componenti posseduti, fino a Profondita livelli.
function AlberoComponenti(Radice: TComponent; Profondita: Integer): TJSONObject;

// Azioni possedute dalla radice e dai suoi componenti (frame compresi).
function ElencoAzioni(Radice: TComponent): TJSONArray;
function ElencoAzioniDa(const Azioni: TArray<TBasicAction>): TJSONArray;

// Tutte le azioni possedute (per il menu e per i controlli sulle vietate).
function AzioniPossedute(Radice: TComponent): TArray<TBasicAction>;

// Didascalia leggibile di un componente: Caption, poi Text, poi Name.
function DidascaliaDi(Componente: TComponent): string;

// Esegue un'azione, un pulsante o una voce di menu. Solleva ESonda se il
// componente non si puo' eseguire o l'azione e' disabilitata.
function EseguiComponente(Componente: TComponent): string;

// Stato e contenuto di un dataset; Righe = 0 solo campi e record corrente.
// Campi, se non vuoto, tiene solo quei campi nel record corrente e nelle
// righe, e toglie l'elenco dei campi: i dataset di WT ne hanno piu' di cento.
function DescriviDataset(DataSet: TDataSet; Righe: Integer; const Campi: TArray<string> = nil): TJSONObject;

// Il dataset che un componente mostra: il dataset stesso, il DataSet di una
// sorgente dati, o quello di una vista o di una scheda (proprieta' zDataSet,
// DataSet o DataSource). Solleva ESonda se non ne ha uno.
function DatasetDi(Componente: TComponent): TDataSet;

// Scrive un valore: campo di un dataset in modifica, editor o casella.
function ImpostaValore(Componente: TComponent; const Campo, Valore: string): string;

// Immagine PNG di una form, codificata in base64.
function ImmagineForm(Form: TCustomForm): string;

// Clic (e doppio clic) sinistro spedito con messaggi di Windows, senza
// toccare il mouse vero, alla finestra che Windows sceglierebbe nel punto (la
// figlia piu' interna sotto il punto, poi quella che ha preso la cattura). X
// e Y negativi = centro del controllo; un pulsante senza coordinate riceve
// BM_CLICK. Il clic e' sincrono: i Modificatori e il pulsante sinistro
// risultano premuti solo per il programma in collaudo, solo per la durata del
// clic. Le schede e le colonne di griglia passano da ClicSpecialeSonda.
function ClicSuComponente(Componente: TComponent; X, Y: Integer; Doppio: Boolean;
  Modificatori: TModificatoriClic = []): string;

// Lo stesso clic nel Punto, in coordinate client di Finestra: per chi calcola
// il punto da se' (la cella di una griglia). Descrizione dice nel resoconto
// che cosa si e' cliccato.
function ClicNellaFinestra(Finestra: TWinControl; const Punto: TPoint; Doppio: Boolean;
  Modificatori: TModificatoriClic; const Descrizione: string): string;

// "ctrl maiusc alt" (anche shift, separati da spazi, virgole o +) -> insieme;
// solleva ESonda con un nome sconosciuto.
function ModificatoriDaTesto(const Testo: string): TModificatoriClic;

// Clic destro in (X, Y) senza mostrare il menu: il controllo riceve pressione
// e rilascio del pulsante destro (la griglia porta il fuoco sulla riga), ma
// non WM_CONTEXTMENU. Restituisce il menu che sarebbe comparso e le sue voci;
// con Voce non vuota preme quella voce (didascalia senza &, o Name), come il
// clic dell'utente sul menu aperto. X e Y negativi = centro del controllo.
// Divieto riceve la voce prima che sia premuta: un testo non vuoto la ferma
// (azioni vietate del banco).
function MenuContestuale(Componente: TComponent; X, Y: Integer; const Voce: string;
  Divieto: TFunc<TComponent, string>): TJSONObject;

// Trascinamento sinistro spedito alla finestra del controllo, come il clic:
// pressione in (X, Y), spostamento di (SpostamentoX, SpostamentoY), rilascio.
// Per uno splitter X e Y negativi scelgono un punto di presa fuori dalla zona
// che apre e chiude il pannello, lo spostamento vale solo lungo il suo asse,
// e Dimensione >= 0 indica la misura voluta del pannello (lo spostamento si
// calcola da li'). Il risultato riporta il pannello e la misura prima e dopo.
// Vale anche per gli splitter del layout DevExpress (TdxLayoutSplitterItem),
// che non sono controlli: i messaggi vanno al TdxLayoutControl, sulla barra.
function TrascinaSuComponente(Componente: TComponent; X, Y, SpostamentoX, SpostamentoY, Dimensione: Integer): TJSONObject;

// Il controllo che riceve i tasti: quello indicato o, con indirizzo vuoto, il
// controllo attivo della form attiva secondo la VCL.
function BersaglioTastiera(const Indirizzo: string): TComponent;

// Il pulsante predefinito della form del componente (lo preme Invio), nil se
// non c'e'.
function PulsantePredefinito(Componente: TComponent): TComponent;

// Testo (un WM_CHAR per carattere) e poi tasti nominati separati da spazi
// (Tab Invio Giu), spediti al controllo senza toccare la tastiera vera.
function TastiSuComponente(Componente: TComponent; const Testo, Tasti: string): string;

// Vero se il componente e' una voce di una barra DevExpress (TdxBarItem e
// discendenti), riconosciuta dal nome della classe.
function VoceDiBarra(Componente: TComponent): Boolean;

// Voci di barra possedute dalla radice e dai suoi componenti (frame
// compresi): didascalia, abilitata, visibile, premuto, valore e valori
// ammessi. Senza Tutte solo quelle che l'utente vede (Visible = ivAlways),
// separatori esclusi. Cerca, se c'e', tiene solo le voci che lo contengono
// nell'indirizzo o nella didascalia (una vista ne ha decine, menu compresi).
function ElencoVociBarra(Radice: TComponent; Tutte: Boolean; const Cerca: string = ''): TJSONArray;

implementation

uses
  System.Rtti,
  System.TypInfo,
  System.StrUtils,
  System.Variants,
  System.Actions,
  System.Generics.Collections,
  System.NetEncoding,
  System.DateUtils,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.Graphics,
  Vcl.Imaging.pngimage;

const
  RigheMassime = 200;

function ProprietaTesto(Componente: TObject; const Nome: string; out Valore: string): Boolean;
var
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
  Letto: TValue;
begin
  Result := False;
  Valore := '';
  Proprieta := Contesto.GetType(Componente.ClassType).GetProperty(Nome);
  if (Proprieta = nil) or not Proprieta.IsReadable then
    Exit;
  try
    Letto := Proprieta.GetValue(Componente);
    if Letto.Kind in [tkString, tkLString, tkWString, tkUString, tkChar, tkWChar] then
    begin
      Valore := Letto.AsString;
      Result := True;
    end
    else if Letto.Kind = tkVariant then
    begin
      Valore := VarToStrDef(Letto.AsVariant, '');
      Result := True;
    end;
  except
    // una proprieta' che solleva in lettura (componente a meta') non deve
    // fermare l'ispezione di tutto il resto
    Result := False;
  end;
end;

function DidascaliaDi(Componente: TComponent): string;
begin
  if ProprietaTesto(Componente, 'Caption', Result) and (Result <> '') then
    Exit;
  if ProprietaTesto(Componente, 'Text', Result) and (Result <> '') then
    Exit;
  Result := '';
end;

function ContenitoreRadice(Componente: TComponent): Boolean;
begin
  Result := (Componente is TCustomForm) or (Componente is TDataModule) or (Componente.Owner = nil) or
    (Componente.Owner = Application);
end;

function IndirizzoDi(Componente: TComponent): string;
var
  Corrente: TComponent;
  Pezzo, Didascalia: string;
begin
  Result := '';
  Corrente := Componente;
  while Corrente <> nil do
  begin
    Pezzo := Corrente.Name;
    if Pezzo = '' then
    begin
      // Componente senza Name (azioni e voci create dal codice): si indica con
      // la classe e, se c'e', la didascalia, cosi' l'indirizzo restituito da
      // azioni e componenti si puo' riusare tale e quale (vedi TrovaSenzaNome).
      Pezzo := '(' + Corrente.ClassName + ')';
      Didascalia := StripHotkey(DidascaliaDi(Corrente));
      if (Didascalia <> '') and (Pos('.', Didascalia) = 0) then
        Pezzo := Pezzo + '=' + Didascalia;
    end;
    if Result = '' then
      Result := Pezzo
    else
      Result := Pezzo + '.' + Result;
    if ContenitoreRadice(Corrente) then
      Break;
    Corrente := Corrente.Owner;
  end;
end;

function Radici: TArray<TComponent>;
var
  Elenco: TList<TComponent>;
  Indice: Integer;
begin
  Elenco := TList<TComponent>.Create;
  try
    for Indice := 0 to Screen.CustomFormCount - 1 do
      Elenco.Add(Screen.CustomForms[Indice]);
    for Indice := 0 to Screen.DataModuleCount - 1 do
      Elenco.Add(Screen.DataModules[Indice]);
    Result := Elenco.ToArray;
  finally
    Elenco.Free;
  end;
end;

function ElencoForm: TJSONArray;
var
  Indice: Integer;
  Form: TCustomForm;
  Voce: TJSONObject;
begin
  Result := TJSONArray.Create;
  for Indice := 0 to Screen.CustomFormCount - 1 do
  begin
    Form := Screen.CustomForms[Indice];
    Voce := TJSONObject.Create;
    Voce.AddPair('nome', Form.Name);
    Voce.AddPair('classe', Form.ClassName);
    Voce.AddPair('titolo', Form.Caption);
    Voce.AddPair('visibile', TJSONBool.Create(Form.Visible));
    Voce.AddPair('modale', TJSONBool.Create(fsModal in Form.FormState));
    Voce.AddPair('attiva', TJSONBool.Create(Form = Screen.ActiveCustomForm));
    Voce.AddPair('principale', TJSONBool.Create(Form = Application.MainForm));
    Result.AddElement(Voce);
  end;
  for Indice := 0 to Screen.DataModuleCount - 1 do
  begin
    Voce := TJSONObject.Create;
    Voce.AddPair('nome', Screen.DataModules[Indice].Name);
    Voce.AddPair('classe', Screen.DataModules[Indice].ClassName);
    Voce.AddPair('datamodule', TJSONBool.Create(True));
    Result.AddElement(Voce);
  end;
end;

function NomeCorrisponde(Componente: TComponent; const Nome: string): Boolean;
begin
  Result := SameText(Componente.Name, Nome) or SameText(Componente.ClassName, Nome);
end;

procedure CercaInProfondita(Contenitore: TComponent; const Nome: string; Trovati: TList<TComponent>);
var
  Indice: Integer;
  Figlio: TComponent;
begin
  for Indice := 0 to Contenitore.ComponentCount - 1 do
  begin
    Figlio := Contenitore.Components[Indice];
    if SameText(Figlio.Name, Nome) then
      Trovati.Add(Figlio);
    if Figlio.ComponentCount > 0 then
      CercaInProfondita(Figlio, Nome, Trovati);
  end;
end;

procedure RaccogliSenzaNome(Contenitore: TComponent; const Classe: string; Trovati: TList<TComponent>);
var
  Indice: Integer;
  Figlio: TComponent;
begin
  for Indice := 0 to Contenitore.ComponentCount - 1 do
  begin
    Figlio := Contenitore.Components[Indice];
    if (Figlio.Name = '') and SameText(Figlio.ClassName, Classe) then
      Trovati.Add(Figlio);
    if Figlio.ComponentCount > 0 then
      RaccogliSenzaNome(Figlio, Classe, Trovati);
  end;
end;

// Sceglie fra i candidati senza Name della classe indicata il pezzo
// "(Classe)" se e' l'unico di quella classe, "(Classe)#N" per l'N-esimo (da 1,
// nell'ordine in cui sono posseduti), "(Classe)=Didascalia" per quello con
// quella didascalia (senza &). La didascalia non puo' contenere punti: il
// punto separa i pezzi. Dove dice in quale contenitore si e' cercato, per i
// messaggi (vuoto per le form senza nome, che non hanno un contenitore).
function ScegliSenzaNome(Trovati: TList<TComponent>; const Pezzo, Dove: string): TComponent;
var
  Fine, Numero, Posizione: Integer;
  Classe, Resto, Prefisso, Elenco, Didascalia: string;
  Scelti: TList<TComponent>;
  Candidato: TComponent;
begin
  Fine := Pos(')', Pezzo);
  if Fine < 2 then
    raise ESonda.CreateFmt('Pezzo "%s" non valido: atteso (Classe), (Classe)#N o (Classe)=Didascalia.', [Pezzo]);
  Classe := Copy(Pezzo, 2, Fine - 2);
  Resto := Copy(Pezzo, Fine + 1, MaxInt);
  if Dove = '' then
    Prefisso := ''
  else
    Prefisso := Dove + '.';

  Scelti := TList<TComponent>.Create;
  try
    if Resto = '' then
      Scelti.AddRange(Trovati)
    else if Resto[1] = '#' then
    begin
      Numero := StrToIntDef(Copy(Resto, 2, MaxInt), 0);
      if (Numero >= 1) and (Numero <= Trovati.Count) then
        Scelti.Add(Trovati[Numero - 1]);
    end
    else if Resto[1] = '=' then
    begin
      for Candidato in Trovati do
        if SameText(StripHotkey(DidascaliaDi(Candidato)), Copy(Resto, 2, MaxInt)) then
          Scelti.Add(Candidato);
    end
    else
      raise ESonda.CreateFmt('Pezzo "%s" non valido: dopo (Classe) atteso #N o =Didascalia.', [Pezzo]);

    if Scelti.Count = 1 then
      Exit(Scelti[0]);

    if Scelti.Count = 0 then
      raise ESonda.CreateFmt('Nessun componente senza nome %s %s(ce ne sono %d di quella classe).',
        [Pezzo, IfThen(Dove = '', 'fra le form aperte ', 'dentro ' + Dove + ' '), Trovati.Count]);

    // ogni candidato con il numero d'ordine (#N) che lo indica senza dubbi,
    // anche quando non ha didascalia e gli indirizzi sarebbero tutti uguali
    Elenco := '';
    for Candidato in Scelti do
    begin
      Posizione := Trovati.IndexOf(Candidato) + 1;
      Didascalia := StripHotkey(DidascaliaDi(Candidato));
      Elenco := Elenco + sLineBreak + '  ' + Prefisso + '(' + Classe + ')#' + IntToStr(Posizione);
      if Didascalia <> '' then
        Elenco := Elenco + '  (didascalia "' + Didascalia + '")';
    end;
    raise ESonda.CreateFmt('%s e'' ambiguo %s, aggiungi #N o =Didascalia:%s',
      [Pezzo, IfThen(Dove = '', 'fra le form aperte', 'dentro ' + Dove), Elenco]);
  finally
    Scelti.Free;
  end;
end;

function ClasseDelPezzo(const Pezzo: string): string;
var
  Fine: Integer;
begin
  Fine := Pos(')', Pezzo);
  if Fine < 2 then
    raise ESonda.CreateFmt('Pezzo "%s" non valido: atteso (Classe), (Classe)#N o (Classe)=Didascalia.', [Pezzo]);
  Result := Copy(Pezzo, 2, Fine - 2);
end;

// Pezzo di un componente senza Name dentro un contenitore.
function TrovaSenzaNome(Contenitore: TComponent; const Pezzo: string): TComponent;
var
  Trovati: TList<TComponent>;
begin
  Trovati := TList<TComponent>.Create;
  try
    RaccogliSenzaNome(Contenitore, ClasseDelPezzo(Pezzo), Trovati);
    Result := ScegliSenzaNome(Trovati, Pezzo, IndirizzoDi(Contenitore));
  finally
    Trovati.Free;
  end;
end;

// Form (o DataModule) aperta senza Name, come i dialoghi creati dal codice:
// "(TInputDialog)=Tipo Risorsa", dove la didascalia e' il titolo della form.
function TrovaRadiceSenzaNome(const Pezzo: string): TComponent;
var
  Trovati: TList<TComponent>;
  Classe: string;
  Candidato: TComponent;
begin
  Classe := ClasseDelPezzo(Pezzo);
  Trovati := TList<TComponent>.Create;
  try
    for Candidato in Radici do
      if (Candidato.Name = '') and SameText(Candidato.ClassName, Classe) then
        Trovati.Add(Candidato);
    Result := ScegliSenzaNome(Trovati, Pezzo, '');
  finally
    Trovati.Free;
  end;
end;

function TrovaComponente(const Indirizzo: string): TComponent;
var
  Pezzi: TArray<string>;
  Indice: Integer;
  Candidato: TComponent;
  Trovati: TList<TComponent>;
  Elenco, Ruolo, Nome: string;
  Separatore: Integer;
begin
  Pezzi := Indirizzo.Trim.Split(['.']);
  if Length(Pezzi) = 0 then
    raise ESonda.Create('Indirizzo vuoto.');

  Result := nil;
  // form senza Name (dialoghi creati dal codice): lo stesso pezzo
  // "(Classe)", "(Classe)#N" o "(Classe)=Titolo" dei componenti senza nome
  if (Pezzi[0] <> '') and (Pezzi[0][1] = '(') then
    Result := TrovaRadiceSenzaNome(Pezzi[0])
  // la form attiva prima, poi le altre: con due istanze della stessa classe
  // vince quella che l'utente sta guardando
  else if (Screen.ActiveCustomForm <> nil) and NomeCorrisponde(Screen.ActiveCustomForm, Pezzi[0]) then
    Result := Screen.ActiveCustomForm
  else
    for Candidato in Radici do
      if NomeCorrisponde(Candidato, Pezzi[0]) then
      begin
        Result := Candidato;
        Break;
      end;
  if Result = nil then
    raise ESonda.CreateFmt('Nessuna form o DataModule aperto si chiama "%s". Usa il comando form per l''elenco.',
      [Pezzi[0]]);

  Indice := 1;
  while Indice <= High(Pezzi) do
  begin
    // componente senza Name: prima di "ruolo:nome", perche' una didascalia
    // puo' contenere i due punti
    if (Pezzi[Indice] <> '') and (Pezzi[Indice][1] = '(') then
    begin
      Result := TrovaSenzaNome(Result, Pezzi[Indice]);
      Inc(Indice);
      Continue;
    end;
    Separatore := Pezzi[Indice].IndexOf(':');
    if Separatore > 0 then
    begin
      Ruolo := Copy(Pezzi[Indice], 1, Separatore);
      Nome := Copy(Pezzi[Indice], Separatore + 2, MaxInt);
      if Indice < High(Pezzi) then
      begin
        Inc(Indice);
        Nome := Nome + '.' + Pezzi[Indice];
      end;
      if not Assigned(RisolutoreRuoloSonda) then
        raise ESonda.CreateFmt('Indirizzi per ruolo (%s:) non disponibili in questa applicazione.', [Ruolo]);
      Candidato := RisolutoreRuoloSonda(Result, Ruolo, Nome);
      if Candidato = nil then
        raise ESonda.CreateFmt('Nessun componente con ruolo %s:%s dentro %s. Usa componenti per vedere i ruoli.',
          [Ruolo, Nome, IndirizzoDi(Result)]);
      Result := Candidato;
      Inc(Indice);
      Continue;
    end;
    Candidato := Result.FindComponent(Pezzi[Indice]);
    if Candidato = nil then
    begin
      Trovati := TList<TComponent>.Create;
      try
        CercaInProfondita(Result, Pezzi[Indice], Trovati);
        if Trovati.Count = 1 then
          Candidato := Trovati[0]
        else if Trovati.Count > 1 then
        begin
          Elenco := '';
          for Candidato in Trovati do
            Elenco := Elenco + sLineBreak + '  ' + IndirizzoDi(Candidato);
          raise ESonda.CreateFmt('"%s" e'' ambiguo dentro %s, scegli uno di questi:%s',
            [Pezzi[Indice], IndirizzoDi(Result), Elenco]);
        end;
      finally
        Trovati.Free;
      end;
    end;
    if Candidato = nil then
      raise ESonda.CreateFmt('"%s" non trovato dentro %s. Usa componenti o azioni per vedere cosa contiene.',
        [Pezzi[Indice], IndirizzoDi(Result)]);
    Result := Candidato;
    Inc(Indice);
  end;
end;

function RuoloDi(Componente: TComponent): string;
begin
  Result := '';
  if Assigned(DescrittoreRuoloSonda) then
    try
      Result := DescrittoreRuoloSonda(Componente);
    except
      // un componente a meta' non deve fermare l'elenco
      Result := '';
    end;
end;

function RadiceDi(Componente: TComponent): TComponent;
begin
  Result := Componente;
  while (Result <> nil) and not ContenitoreRadice(Result) do
    Result := Result.Owner;
end;

// ----- voci delle barre DevExpress ---------------------------------------------------

function InvocaSenzaParametri(Componente: TObject; const Nome: string): Boolean; forward;

function DiscendeDa(Classe: TClass; const NomeAntenato: string): Boolean;
begin
  while Classe <> nil do
  begin
    if SameText(Classe.ClassName, NomeAntenato) then
      Exit(True);
    Classe := Classe.ClassParent;
  end;
  Result := False;
end;

function VoceDiBarra(Componente: TComponent): Boolean;
begin
  Result := (Componente <> nil) and DiscendeDa(Componente.ClassType, 'TdxBarItem');
end;

// Valore di una proprieta' per nome; vuoto se non c'e' o se solleva.
function LeggiProprieta(Oggetto: TObject; const Nome: string): TValue;
var
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
begin
  Result := TValue.Empty;
  if Oggetto = nil then
    Exit;
  Proprieta := Contesto.GetType(Oggetto.ClassType).GetProperty(Nome);
  if (Proprieta = nil) or not Proprieta.IsReadable then
    Exit;
  try
    Result := Proprieta.GetValue(Oggetto);
  except
    // una proprieta' che solleva in lettura vale come assente
    Result := TValue.Empty;
  end;
end;

function LeggiBooleano(Oggetto: TObject; const Nome: string; Predefinito: Boolean): Boolean;
var
  Valore: TValue;
begin
  Valore := LeggiProprieta(Oggetto, Nome);
  if Valore.IsEmpty or (Valore.TypeInfo <> TypeInfo(Boolean)) then
    Exit(Predefinito);
  Result := Valore.AsBoolean;
end;

function LeggiOggetto(Oggetto: TObject; const Nome: string): TObject;
var
  Valore: TValue;
begin
  Valore := LeggiProprieta(Oggetto, Nome);
  if Valore.IsEmpty or not Valore.IsObject then
    Exit(nil);
  Result := Valore.AsObject;
end;

function LeggiVariant(Oggetto: TObject; const Nome: string): Variant;
var
  Valore: TValue;
begin
  Valore := LeggiProprieta(Oggetto, Nome);
  if Valore.IsEmpty then
    Exit(Null);
  try
    Result := Valore.AsVariant;
  except
    // tipo che non si converte in Variant: come assente
    Result := Null;
  end;
end;

function StessoValore(const Primo, Secondo: Variant): Boolean;
begin
  if VarIsNull(Primo) or VarIsNull(Secondo) then
    Exit(VarIsNull(Primo) and VarIsNull(Secondo));
  try
    Result := VarCompareValue(Primo, Secondo) = vrEqual;
  except
    // tipi che non si confrontano (testo e numero): si confronta il testo
    Result := SameText(VarToStr(Primo), VarToStr(Secondo));
  end;
end;

// Visible della voce come nome (ivAlways, ivNever, ivInCustomizing).
function VisibilitaVoce(Voce: TComponent): string;
var
  Valore: TValue;
begin
  Valore := LeggiProprieta(Voce, 'Visible');
  if Valore.IsEmpty then
    Exit('');
  Result := Valore.ToString;
end;

// Pulsante a spunta: ButtonStyle bsChecked o bsCheckedDropDown.
function VoceASpunta(Voce: TComponent): Boolean;
var
  Valore: TValue;
begin
  Valore := LeggiProprieta(Voce, 'ButtonStyle');
  Result := not Valore.IsEmpty and ContainsText(Valore.ToString, 'Checked');
end;

// Le proprieta' dell'editor di una casella (TcxBarEditItem.Properties); nil
// se la voce non ha un valore da scrivere.
function EditorDellaVoce(Voce: TComponent): TObject;
begin
  Result := nil;
  if LeggiProprieta(Voce, 'EditValue').IsEmpty then
    Exit;
  Result := LeggiOggetto(Voce, 'Properties');
end;

// Elementi di un elenco a tendina con valore e descrizione (ImageComboBox),
// nil se l'editor non ne ha.
function ElementiConValore(Editor: TObject): TCollection;
var
  Elementi: TObject;
begin
  Elementi := LeggiOggetto(Editor, 'Items');
  if (Elementi is TCollection) and (TCollection(Elementi).Count > 0) and
    not LeggiProprieta(TCollection(Elementi).Items[0], 'Value').IsEmpty then
    Result := TCollection(Elementi)
  else
    Result := nil;
end;

function DescrizioneElemento(Elemento: TCollectionItem): string;
begin
  if not ProprietaTesto(Elemento, 'Description', Result) or (Result = '') then
    Result := VarToStr(LeggiVariant(Elemento, 'Value'));
end;

// Il valore della casella come lo vede l'utente: per un elenco a tendina la
// descrizione dell'elemento scelto.
function TestoValoreVoce(Voce: TComponent; Editor: TObject): string;
var
  Valore: Variant;
  Elementi: TCollection;
  Indice: Integer;
begin
  Valore := LeggiVariant(Voce, 'EditValue');
  if VarIsNull(Valore) or VarIsEmpty(Valore) then
    Exit('');
  Elementi := ElementiConValore(Editor);
  if Elementi <> nil then
    for Indice := 0 to Elementi.Count - 1 do
      if StessoValore(LeggiVariant(Elementi.Items[Indice], 'Value'), Valore) then
        Exit(DescrizioneElemento(Elementi.Items[Indice]));
  Result := VarToStr(Valore);
end;

function ValoriAmmessi(Editor: TObject): TJSONArray;
var
  Elementi: TObject;
  Indice: Integer;
begin
  Result := nil;
  Elementi := LeggiOggetto(Editor, 'Items');
  if Elementi is TStrings then
  begin
    Result := TJSONArray.Create;
    for Indice := 0 to TStrings(Elementi).Count - 1 do
      Result.Add(TStrings(Elementi)[Indice]);
  end
  else if Elementi is TCollection then
  begin
    Result := TJSONArray.Create;
    for Indice := 0 to TCollection(Elementi).Count - 1 do
      Result.Add(DescrizioneElemento(TCollection(Elementi).Items[Indice]));
  end;
end;

function NumeroDaTesto(const Testo: string; out Numero: Variant): Boolean;
var
  Intero: Int64;
  Decimale: Double;
begin
  Result := True;
  if TryStrToInt64(Testo, Intero) then
    Numero := Intero
  // il punto e la virgola valgono tutti e due come separatore dei decimali
  else if TryStrToFloat(Testo.Replace(',', '.'), Decimale, TFormatSettings.Invariant) then
    Numero := Decimale
  else
    Result := False;
end;

// Il testo scritto dall'utente nel tipo che la casella si aspetta: il valore
// di un elemento della tendina (cercato per descrizione o per valore), una
// data, un numero, vero o falso per una casella di spunta.
function ConvertiValoreVoce(Voce: TComponent; Editor: TObject; const Testo: string): Variant;
const
  Veri: array [0 .. 4] of string = ('1', 'true', 'si', 'sì', 'vero');
var
  Elementi: TCollection;
  Indice: Integer;
  Valore, Attuale: Variant;
  Descrizioni: TStringList;
  Data: TDateTime;
  NomeEditor: string;
begin
  if Testo = '' then
    Exit(Null);

  Elementi := ElementiConValore(Editor);
  if Elementi <> nil then
  begin
    for Indice := 0 to Elementi.Count - 1 do
    begin
      Valore := LeggiVariant(Elementi.Items[Indice], 'Value');
      if SameText(DescrizioneElemento(Elementi.Items[Indice]), Testo) or SameText(VarToStr(Valore), Testo) then
        Exit(Valore);
    end;
    Descrizioni := TStringList.Create;
    try
      for Indice := 0 to Elementi.Count - 1 do
        Descrizioni.Add('"' + DescrizioneElemento(Elementi.Items[Indice]) + '"');
      raise ESonda.CreateFmt('"%s" non e'' fra i valori di %s: %s.',
        [Testo, IndirizzoDi(Voce), string.Join(', ', Descrizioni.ToStringArray)]);
    finally
      Descrizioni.Free;
    end;
  end;

  NomeEditor := Editor.ClassName;
  if ContainsText(NomeEditor, 'CheckBox') then
  begin
    if MatchText(Testo, Veri) then
      Result := LeggiVariant(Editor, 'ValueChecked')
    else
      Result := LeggiVariant(Editor, 'ValueUnchecked');
    if VarIsNull(Result) then
      Result := MatchText(Testo, Veri);
    Exit;
  end;

  if ContainsText(NomeEditor, 'DateEdit') or ContainsText(NomeEditor, 'TimeEdit') then
  begin
    // ISO con AReturnUTC vero: il testo senza fuso vale com'e' scritto (con
    // falso si convertirebbe in ora locale, un'ora avanti)
    if not TryStrToDateTime(Testo, Data) and not TryISO8601ToDate(Testo, Data, True) then
      raise ESonda.CreateFmt('"%s" non e'' una data per %s: scrivila come %s o aaaa-mm-gg.',
        [Testo, IndirizzoDi(Voce), FormatSettings.ShortDateFormat]);
    Exit(Data);
  end;

  if ContainsText(NomeEditor, 'SpinEdit') or ContainsText(NomeEditor, 'CurrencyEdit') or
    ContainsText(NomeEditor, 'CalcEdit') then
  begin
    if not NumeroDaTesto(Testo, Result) then
      raise ESonda.CreateFmt('"%s" non e'' un numero per %s.', [Testo, IndirizzoDi(Voce)]);
    Exit;
  end;

  // altri editor: un numero resta un numero se lo era gia' il valore attuale
  Attuale := LeggiVariant(Voce, 'EditValue');
  if not VarIsNull(Attuale) and not VarIsEmpty(Attuale) and VarIsNumeric(Attuale) and NumeroDaTesto(Testo, Valore) then
    Exit(Valore);
  Result := Testo;
end;

function DescriviVoceBarra(Voce: TComponent): TJSONObject;
var
  Editor: TObject;
  Testo: string;
  Ammessi: TJSONArray;
begin
  Result := TJSONObject.Create;
  Result.AddPair('indirizzo', IndirizzoDi(Voce));
  Result.AddPair('classe', Voce.ClassName);
  Testo := StripHotkey(DidascaliaDi(Voce));
  if Testo <> '' then
    Result.AddPair('didascalia', Testo);
  if ProprietaTesto(Voce, 'Hint', Testo) and (Testo <> '') then
    Result.AddPair('suggerimento', Testo);
  Result.AddPair('abilitata', TJSONBool.Create(LeggiBooleano(Voce, 'Enabled', True)));
  Result.AddPair('visibile', VisibilitaVoce(Voce));
  if VoceASpunta(Voce) then
    Result.AddPair('premuto', TJSONBool.Create(LeggiBooleano(Voce, 'Down', False)));
  Editor := EditorDellaVoce(Voce);
  if Editor <> nil then
  begin
    Result.AddPair('editor', Editor.ClassName);
    Result.AddPair('valore', TestoValoreVoce(Voce, Editor));
    Ammessi := ValoriAmmessi(Editor);
    if Ammessi <> nil then
      Result.AddPair('valori_ammessi', Ammessi);
  end;
end;

procedure RaccogliVociBarra(Contenitore: TComponent; Voci: TList<TComponent>);
var
  Indice: Integer;
  Figlio: TComponent;
begin
  for Indice := 0 to Contenitore.ComponentCount - 1 do
  begin
    Figlio := Contenitore.Components[Indice];
    if VoceDiBarra(Figlio) then
      Voci.Add(Figlio);
    if Figlio.ComponentCount > 0 then
      RaccogliVociBarra(Figlio, Voci);
  end;
end;

function ElencoVociBarra(Radice: TComponent; Tutte: Boolean; const Cerca: string): TJSONArray;
var
  Voci: TList<TComponent>;
  Voce: TComponent;
begin
  Result := TJSONArray.Create;
  Voci := TList<TComponent>.Create;
  try
    if VoceDiBarra(Radice) then
      Voci.Add(Radice)
    else
      RaccogliVociBarra(Radice, Voci);
    for Voce in Voci do
    begin
      if not Tutte and (not SameText(VisibilitaVoce(Voce), 'ivAlways') or DiscendeDa(Voce.ClassType, 'TdxBarSeparator')) then
        Continue;
      if (Cerca <> '') and not ContainsText(IndirizzoDi(Voce), Cerca) and not ContainsText(DidascaliaDi(Voce), Cerca) then
        Continue;
      Result.AddElement(DescriviVoceBarra(Voce));
    end;
  finally
    Voci.Free;
  end;
end;

// Preme una voce come farebbe l'utente: TdxBarItem.Click esegue l'azione
// collegata o OnClick.
function PremiVoceBarra(Voce: TComponent): string;
var
  Indirizzo: string;
  Spunta, Prima: Boolean;
begin
  Indirizzo := IndirizzoDi(Voce);
  if EditorDellaVoce(Voce) <> nil then
    raise ESonda.CreateFmt('%s e'' una casella (%s): il valore si scrive con imposta.',
      [Indirizzo, EditorDellaVoce(Voce).ClassName]);
  if not LeggiBooleano(Voce, 'Enabled', True) then
    raise ESonda.CreateFmt('La voce %s e'' disabilitata.', [Indirizzo]);
  if SameText(VisibilitaVoce(Voce), 'ivNever') then
    raise ESonda.CreateFmt('La voce %s non e'' visibile all''utente (Visible = ivNever).', [Indirizzo]);
  Spunta := VoceASpunta(Voce);
  Prima := LeggiBooleano(Voce, 'Down', False);
  if not InvocaSenzaParametri(Voce, 'Click') then
    raise ESonda.CreateFmt('Non so premere %s (%s): manca il metodo Click.', [Indirizzo, Voce.ClassName]);
  Result := 'voce della barra premuta: ' + Indirizzo;
  // dopo il clic la voce potrebbe non esserci piu' (una form chiusa): lo
  // stato si rilegge solo per i pulsanti a spunta, che restano
  if Spunta then
    Result := Result + Format(' (premuto: %s -> %s)', [IfThen(Prima, 'si', 'no'),
      IfThen(LeggiBooleano(Voce, 'Down', False), 'si', 'no')]);
end;

// Scrive il valore di una casella della barra: assegnare EditValue fa
// scattare OnChange, come quando l'utente sceglie dalla tendina.
function ImpostaVoceBarra(Voce: TComponent; const Testo: string): string;
var
  Editor: TObject;
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
  Nuovo: Variant;
begin
  Editor := EditorDellaVoce(Voce);
  if Editor = nil then
    raise ESonda.CreateFmt('%s e'' una voce della barra senza valore: per premerla usa esegui.', [IndirizzoDi(Voce)]);
  if not LeggiBooleano(Voce, 'Enabled', True) then
    raise ESonda.CreateFmt('La casella %s e'' disabilitata.', [IndirizzoDi(Voce)]);
  Nuovo := ConvertiValoreVoce(Voce, Editor, Testo);
  Proprieta := Contesto.GetType(Voce.ClassType).GetProperty('EditValue');
  if (Proprieta = nil) or not Proprieta.IsWritable then
    raise ESonda.CreateFmt('Non so scrivere il valore di %s.', [IndirizzoDi(Voce)]);
  Proprieta.SetValue(Voce, TValue.From<Variant>(Nuovo));
  Result := Format('%s = %s', [IndirizzoDi(Voce), TestoValoreVoce(Voce, Editor)]);
end;

// Lato, pannello e misura di uno splitter; nil se il componente non lo e'.
function DescriviSplitter(Componente: TComponent): TJSONObject; forward;

function DescriviComponente(Componente: TComponent): TJSONObject;
var
  Testo: string;
  Splitter: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('nome', Componente.Name);
  Result.AddPair('classe', Componente.ClassName);
  Testo := RuoloDi(Componente);
  if Testo <> '' then
    Result.AddPair('ruolo', Testo);
  Testo := DidascaliaDi(Componente);
  if Testo <> '' then
    Result.AddPair('testo', Testo);
  if Componente is TControl then
  begin
    Result.AddPair('visibile', TJSONBool.Create(TControl(Componente).Visible));
    Result.AddPair('abilitato', TJSONBool.Create(TControl(Componente).Enabled));
    if (Componente is TWinControl) and TWinControl(Componente).Focused then
      Result.AddPair('fuoco', TJSONBool.Create(True));
  end;
  if Componente is TDataSet then
  begin
    Result.AddPair('attivo', TJSONBool.Create(TDataSet(Componente).Active));
    Result.AddPair('stato', GetEnumName(TypeInfo(TDataSetState), Ord(TDataSet(Componente).State)));
  end;
  if Componente is TContainedAction then
    Result.AddPair('abilitata', TJSONBool.Create(TContainedAction(Componente).Enabled));
  if VoceDiBarra(Componente) then
  begin
    Result.AddPair('abilitata', TJSONBool.Create(LeggiBooleano(Componente, 'Enabled', True)));
    if EditorDellaVoce(Componente) <> nil then
      Result.AddPair('valore', TestoValoreVoce(Componente, EditorDellaVoce(Componente)));
  end;
  Splitter := DescriviSplitter(Componente);
  if Splitter <> nil then
    Result.AddPair('splitter', Splitter);
end;

function AlberoComponenti(Radice: TComponent; Profondita: Integer): TJSONObject;
var
  Figli: TJSONArray;
  Indice: Integer;
begin
  Result := DescriviComponente(Radice);
  Result.AddPair('indirizzo', IndirizzoDi(Radice));
  if Radice.ComponentCount = 0 then
    Exit;
  if Profondita <= 0 then
  begin
    Result.AddPair('figli_non_mostrati', TJSONNumber.Create(Radice.ComponentCount));
    Exit;
  end;
  Figli := TJSONArray.Create;
  Result.AddPair('figli', Figli);
  for Indice := 0 to Radice.ComponentCount - 1 do
    if Radice.Components[Indice].ComponentCount > 0 then
      Figli.AddElement(AlberoComponenti(Radice.Components[Indice], Profondita - 1))
    else
      Figli.AddElement(DescriviComponente(Radice.Components[Indice]));
end;

procedure RaccogliAzioni(Contenitore: TComponent; Azioni: TList<TBasicAction>);
var
  Indice: Integer;
  Figlio: TComponent;
begin
  for Indice := 0 to Contenitore.ComponentCount - 1 do
  begin
    Figlio := Contenitore.Components[Indice];
    if Figlio is TBasicAction then
      Azioni.Add(TBasicAction(Figlio));
    if Figlio.ComponentCount > 0 then
      RaccogliAzioni(Figlio, Azioni);
  end;
end;

function AzioniPossedute(Radice: TComponent): TArray<TBasicAction>;
var
  Azioni: TList<TBasicAction>;
begin
  Azioni := TList<TBasicAction>.Create;
  try
    RaccogliAzioni(Radice, Azioni);
    Result := Azioni.ToArray;
  finally
    Azioni.Free;
  end;
end;

function DescriviAzione(Azione: TBasicAction): TJSONObject;
var
  Contenuta: TContainedAction;
  Ruolo: string;
  Proprietario: TComponent;
begin
  // Update fa girare OnUpdate: abilitazione e visibilita' sono quelle che
  // vedrebbe l'utente in questo momento, non quelle del DFM
  try
    Azione.Update;
  except
    // un OnUpdate che solleva non deve impedire l'elenco
  end;
  Result := TJSONObject.Create;
  Result.AddPair('indirizzo', IndirizzoDi(Azione));
  // nelle form LZ il Name del frame cambia col layout; l'indirizzo per
  // ruolo resta lo stesso
  Ruolo := '';
  Proprietario := Azione.Owner;
  while (Proprietario <> nil) and (Ruolo = '') and not ContenitoreRadice(Proprietario) do
  begin
    Ruolo := RuoloDi(Proprietario);
    if Ruolo = '' then
      Proprietario := Proprietario.Owner;
  end;
  if Ruolo <> '' then
    Result.AddPair('indirizzo_ruolo', IndirizzoDi(RadiceDi(Proprietario)) + '.' + Ruolo + '.' + Azione.Name);
  Result.AddPair('classe', Azione.ClassName);
  if Azione is TContainedAction then
  begin
    Contenuta := TContainedAction(Azione);
    Result.AddPair('didascalia', StripHotkey(Contenuta.Caption));
    Result.AddPair('abilitata', TJSONBool.Create(Contenuta.Enabled));
    Result.AddPair('visibile', TJSONBool.Create(Contenuta.Visible));
    if Contenuta.Category <> '' then
      Result.AddPair('categoria', Contenuta.Category);
    if Contenuta.ShortCut <> 0 then
      Result.AddPair('scorciatoia', ShortCutToText(Contenuta.ShortCut));
  end;
end;

function ElencoAzioniDa(const Azioni: TArray<TBasicAction>): TJSONArray;
var
  Azione: TBasicAction;
begin
  Result := TJSONArray.Create;
  for Azione in Azioni do
    Result.AddElement(DescriviAzione(Azione));
end;

function ElencoAzioni(Radice: TComponent): TJSONArray;
begin
  Result := ElencoAzioniDa(AzioniPossedute(Radice));
end;

function EseguiComponente(Componente: TComponent): string;
begin
  if Componente is TBasicAction then
  begin
    TBasicAction(Componente).Update;
    if (Componente is TContainedAction) and not TContainedAction(Componente).Enabled then
      raise ESonda.CreateFmt('L''azione %s e'' disabilitata.', [IndirizzoDi(Componente)]);
    TBasicAction(Componente).Execute;
    Exit('azione eseguita: ' + IndirizzoDi(Componente));
  end;
  if VoceDiBarra(Componente) then
    Exit(PremiVoceBarra(Componente));
  if Componente is TControl then
    if not TControl(Componente).Enabled then
      raise ESonda.CreateFmt('Il controllo %s e'' disabilitato.', [IndirizzoDi(Componente)]);
  if Componente is TButton then
  begin
    TButton(Componente).Click;
    Exit('pulsante premuto: ' + IndirizzoDi(Componente));
  end;
  if Componente is TMenuItem then
  begin
    TMenuItem(Componente).Click;
    Exit('voce di menu eseguita: ' + IndirizzoDi(Componente));
  end;
  raise ESonda.CreateFmt('%s (%s) non e'' un''azione, un pulsante o una voce di menu.',
    [IndirizzoDi(Componente), Componente.ClassName]);
end;

function TestoCampo(Campo: TField): string;
begin
  if Campo.IsNull then
    Exit('');
  if Campo.IsBlob then
    Exit(Format('(blob, %d byte)', [Campo.DataSize]));
  Result := Campo.DisplayText;
end;

// I campi da descrivere: tutti, o quelli chiesti nell'ordine chiesto. Un nome
// che non c'e' ferma il comando con l'elenco dei campi veri, perche' un campo
// assente letto come vuoto direbbe una cosa falsa sul documento mostrato.
function CampiScelti(DataSet: TDataSet; const Nomi: TArray<string>): TArray<TField>;
var
  Nome, Disponibili: string;
  Campo: TField;
begin
  Result := nil;
  if Length(Nomi) = 0 then
  begin
    for Campo in DataSet.Fields do
      Result := Result + [Campo];
    Exit;
  end;
  for Nome in Nomi do
  begin
    Campo := DataSet.FindField(Nome.Trim);
    if Campo = nil then
    begin
      Disponibili := '';
      for Campo in DataSet.Fields do
        Disponibili := Disponibili + IfThen(Disponibili <> '', ', ') + Campo.FieldName;
      raise ESonda.CreateFmt('Il dataset %s non ha il campo "%s". Campi: %s.', [IndirizzoDi(DataSet), Nome.Trim,
        Disponibili]);
    end;
    Result := Result + [Campo];
  end;
end;

function DescriviDataset(DataSet: TDataSet; Righe: Integer; const Campi: TArray<string>): TJSONObject;
var
  Elenco: TJSONArray;
  Riga: TJSONObject;
  Campo: TField;
  Scelti: TArray<TField>;
  Segnalibro: TBookmark;
  Conteggio: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('indirizzo', IndirizzoDi(DataSet));
  Result.AddPair('attivo', TJSONBool.Create(DataSet.Active));
  Result.AddPair('stato', GetEnumName(TypeInfo(TDataSetState), Ord(DataSet.State)));
  if not DataSet.Active then
    Exit;
  Result.AddPair('record', TJSONNumber.Create(DataSet.RecordCount));
  Result.AddPair('posizione', TJSONNumber.Create(DataSet.RecNo));

  Scelti := CampiScelti(DataSet, Campi);
  if Length(Campi) = 0 then
  begin
    Elenco := TJSONArray.Create;
    Result.AddPair('campi', Elenco);
    for Campo in DataSet.Fields do
    begin
      Riga := TJSONObject.Create;
      Riga.AddPair('nome', Campo.FieldName);
      Riga.AddPair('tipo', GetEnumName(TypeInfo(TFieldType), Ord(Campo.DataType)));
      if not Campo.Visible then
        Riga.AddPair('visibile', TJSONBool.Create(False));
      if Campo.ReadOnly then
        Riga.AddPair('sola_lettura', TJSONBool.Create(True));
      if Campo.Required then
        Riga.AddPair('obbligatorio', TJSONBool.Create(True));
      Elenco.AddElement(Riga);
    end;
  end;
  Riga := TJSONObject.Create;
  for Campo in Scelti do
    Riga.AddPair(Campo.FieldName, TestoCampo(Campo));
  Result.AddPair('corrente', Riga);

  // le righe si leggono solo in consultazione: scorrere un dataset in
  // modifica lo costringerebbe a confermare o annullare
  if (Righe <= 0) or (DataSet.State <> dsBrowse) then
    Exit;
  if Righe > RigheMassime then
    Righe := RigheMassime;
  Elenco := TJSONArray.Create;
  Result.AddPair('righe', Elenco);
  DataSet.DisableControls;
  try
    Segnalibro := DataSet.GetBookmark;
    try
      DataSet.First;
      Conteggio := 0;
      while not DataSet.Eof and (Conteggio < Righe) do
      begin
        Riga := TJSONObject.Create;
        for Campo in Scelti do
          Riga.AddPair(Campo.FieldName, TestoCampo(Campo));
        Elenco.AddElement(Riga);
        Inc(Conteggio);
        DataSet.Next;
      end;
      if DataSet.BookmarkValid(Segnalibro) then
        DataSet.GotoBookmark(Segnalibro);
    finally
      DataSet.FreeBookmark(Segnalibro);
    end;
  finally
    DataSet.EnableControls;
  end;
end;

function DatasetDi(Componente: TComponent): TDataSet;
var
  Letto: TObject;
begin
  if Componente is TDataSet then
    Exit(TDataSet(Componente));
  if Componente is TDataSource then
    Letto := TDataSource(Componente).DataSet
  else
  begin
    // le viste e le schede di zBase hanno zDataSet; i controlli legati ai
    // dati DataSource
    Letto := LeggiOggetto(Componente, 'zDataSet');
    if not (Letto is TDataSet) then
      Letto := LeggiOggetto(Componente, 'DataSet');
    if not (Letto is TDataSet) and (LeggiOggetto(Componente, 'DataSource') is TDataSource) then
      Letto := TDataSource(LeggiOggetto(Componente, 'DataSource')).DataSet;
  end;
  if not (Letto is TDataSet) then
    raise ESonda.CreateFmt('%s (%s) non e'' un dataset e non ne mostra uno (niente zDataSet, DataSet o DataSource).',
      [IndirizzoDi(Componente), Componente.ClassName]);
  Result := TDataSet(Letto);
end;

function ImpostaProprietaTesto(Componente: TObject; const Nome, Valore: string): Boolean;
var
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
begin
  Proprieta := Contesto.GetType(Componente.ClassType).GetProperty(Nome);
  Result := (Proprieta <> nil) and Proprieta.IsWritable and
    (Proprieta.PropertyType.TypeKind in [tkString, tkLString, tkWString, tkUString, tkVariant]);
  if not Result then
    Exit;
  if Proprieta.PropertyType.TypeKind = tkVariant then
    Proprieta.SetValue(Componente, TValue.From<Variant>(Valore))
  else
    Proprieta.SetValue(Componente, Valore);
end;

// Chiama per nome un metodo pubblico senza parametri, se c'e'. False se non esiste.
function InvocaSenzaParametri(Componente: TObject; const Nome: string): Boolean;
var
  Contesto: TRttiContext;
  Metodo: TRttiMethod;
begin
  Metodo := Contesto.GetType(Componente.ClassType).GetMethod(Nome);
  Result := (Metodo <> nil) and (Length(Metodo.GetParameters) = 0);
  if Result then
    Metodo.Invoke(Componente, []);
end;

// Campo del dataset a cui un editor e' legato (DataBinding.DataSource e
// DataBinding.DataField degli editor DevExpress); nil se non e' legato.
function CampoCollegato(Componente: TComponent): TField;
var
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
  Legame: TObject;
  Origine: TObject;
  NomeCampo: string;
begin
  Result := nil;
  Proprieta := Contesto.GetType(Componente.ClassType).GetProperty('DataBinding');
  if (Proprieta = nil) or not Proprieta.IsReadable or (Proprieta.PropertyType.TypeKind <> tkClass) then
    Exit;
  Legame := Proprieta.GetValue(Componente).AsObject;
  if Legame = nil then
    Exit;
  Proprieta := Contesto.GetType(Legame.ClassType).GetProperty('DataSource');
  if (Proprieta = nil) or not Proprieta.IsReadable then
    Exit;
  Origine := Proprieta.GetValue(Legame).AsObject;
  if not (Origine is TDataSource) or (TDataSource(Origine).DataSet = nil) then
    Exit;
  if not ProprietaTesto(Legame, 'DataField', NomeCampo) or (NomeCampo = '') then
    Exit;
  Result := TDataSource(Origine).DataSet.FindField(NomeCampo);
end;

function ImpostaValore(Componente: TComponent; const Campo, Valore: string): string;
var
  DataSet: TDataSet;
  CampoDataSet: TField;
begin
  if Componente is TDataSet then
  begin
    DataSet := TDataSet(Componente);
    if Campo = '' then
      raise ESonda.Create('Per un dataset serve il nome del campo.');
    if not (DataSet.State in dsEditModes) then
      raise ESonda.CreateFmt('%s e'' in stato %s: esegui prima l''azione di modifica o inserimento.',
        [IndirizzoDi(DataSet), GetEnumName(TypeInfo(TDataSetState), Ord(DataSet.State))]);
    DataSet.FieldByName(Campo).AsString := Valore;
    Exit(Format('%s.%s = %s', [IndirizzoDi(DataSet), Campo, DataSet.FieldByName(Campo).DisplayText]));
  end;
  if Componente is TField then
  begin
    TField(Componente).AsString := Valore;
    Exit(Format('%s = %s', [IndirizzoDi(Componente), TField(Componente).DisplayText]));
  end;
  // le caselle delle barre (filtri) prima del ramo generico: il valore va
  // convertito nel tipo dell'editor, altrimenti una tendina a codici o una
  // data ricevono un testo che non combacia
  if VoceDiBarra(Componente) then
    Exit(ImpostaVoceBarra(Componente, Valore));
  if Componente is TCheckBox then
  begin
    TCheckBox(Componente).Checked := MatchText(Valore, ['1', 'true', 'si', 'sì', 'vero']);
    Exit(Format('%s = %s', [IndirizzoDi(Componente), BoolToStr(TCheckBox(Componente).Checked, True)]));
  end;
  // editor VCL e DevExpress: EditValue per i cx, Text per gli altri
  if ImpostaProprietaTesto(Componente, 'EditValue', Valore) or ImpostaProprietaTesto(Componente, 'Text', Valore) then
  begin
    // un editor DevExpress legato a un campo lo aggiorna solo a modifica
    // chiusa: PostEditValue la chiude, come quando l'utente esce dal campo
    InvocaSenzaParametri(Componente, 'PostEditValue');
    Result := Format('%s = %s', [IndirizzoDi(Componente), Valore]);
    // l'esito vero: se l'editor e' legato a un campo, si dice cosa contiene
    // il dataset (un valore non registrato non deve passare per riuscito)
    CampoDataSet := CampoCollegato(Componente);
    if (CampoDataSet <> nil) and not SameText(CampoDataSet.AsString, Valore) then
      Result := Result + Format(' ATTENZIONE: il campo %s del dataset vale "%s", non "%s": ' +
        'l''editor e'' stato impostato ma il valore non e'' arrivato nel dataset (nessun evento da utente).',
        [CampoDataSet.FieldName, CampoDataSet.AsString, Valore]);
    Exit;
  end;
  raise ESonda.CreateFmt('Non so scrivere un valore in %s (%s).', [IndirizzoDi(Componente), Componente.ClassName]);
end;

// Winapi.Windows non dichiara PrintWindow
function PrintWindow(Finestra: HWND; ContestoDisegno: HDC; Opzioni: UINT): BOOL; stdcall; external 'user32.dll' name 'PrintWindow';

// Ripiego: copia dallo schermo i pixel dell'area interna della form, come
// vede l'utente. Porta la finestra in primo piano, altrimenti una finestra
// sovrapposta finirebbe nell'immagine.
function CatturaDalloSchermo(Form: TCustomForm; Immagine: TBitmap): Boolean;
var
  Radice: HWND;
  ContestoSchermo: HDC;
  Origine: TPoint;
begin
  Radice := GetAncestor(Form.Handle, GA_ROOT);
  if IsIconic(Radice) then
    ShowWindow(Radice, SW_RESTORE);
  SetForegroundWindow(Radice);
  Application.ProcessMessages;
  Sleep(300);
  Origine := Form.ClientOrigin;
  Immagine.SetSize(Form.ClientWidth, Form.ClientHeight);
  ContestoSchermo := GetDC(0);
  try
    Result := BitBlt(Immagine.Canvas.Handle, 0, 0, Immagine.Width, Immagine.Height,
      ContestoSchermo, Origine.X, Origine.Y, SRCCOPY or $40000000); // $40000000 = CAPTUREBLT, include le finestre a strati
  finally
    ReleaseDC(0, ContestoSchermo);
  end;
end;

// Area interna di una form catturata con PrintWindow sulla finestra di primo
// livello che la contiene (per una form figlia MDI e' la finestra principale),
// poi ritagliata. Serve ai componenti DevExpress, che con PaintTo restano
// vuoti. Restituisce False se PrintWindow non riesce: il chiamante ripiega
// sulla copia dallo schermo e poi su PaintTo.
function CatturaConPrintWindow(Form: TCustomForm; Immagine: TBitmap): Boolean;
const
  RenderizzaContenutoCompleto = 2; // PW_RENDERFULLCONTENT
var
  Radice: HWND;
  RettangoloRadice: TRect;
  ContestoSchermo: HDC;
  ContestoMemoria: HDC;
  BitmapFinestra: HBITMAP;
  BitmapPrecedente: HGDIOBJ;
  Origine: TPoint;
begin
  Result := False;
  Radice := GetAncestor(Form.Handle, GA_ROOT);
  if (Radice = 0) or not GetWindowRect(Radice, RettangoloRadice) then
    Exit;
  ContestoSchermo := GetDC(0);
  try
    ContestoMemoria := CreateCompatibleDC(ContestoSchermo);
    BitmapFinestra := CreateCompatibleBitmap(ContestoSchermo, RettangoloRadice.Width, RettangoloRadice.Height);
    BitmapPrecedente := SelectObject(ContestoMemoria, BitmapFinestra);
    try
      if not PrintWindow(Radice, ContestoMemoria, RenderizzaContenutoCompleto) then
        Exit;
      Origine := Form.ClientOrigin;
      Immagine.SetSize(Form.ClientWidth, Form.ClientHeight);
      Result := BitBlt(Immagine.Canvas.Handle, 0, 0, Immagine.Width, Immagine.Height,
        ContestoMemoria, Origine.X - RettangoloRadice.Left, Origine.Y - RettangoloRadice.Top, SRCCOPY);
    finally
      SelectObject(ContestoMemoria, BitmapPrecedente);
      DeleteObject(BitmapFinestra);
      DeleteDC(ContestoMemoria);
    end;
  finally
    ReleaseDC(0, ContestoSchermo);
  end;
end;

function ImmagineForm(Form: TCustomForm): string;
var
  Immagine: TBitmap;
  Png: TPngImage;
  Flusso: TBytesStream;
  Codifica: TBase64Encoding;
begin
  if not Form.Visible then
    raise ESonda.CreateFmt('La form %s non e'' visibile.', [Form.Name]);
  Immagine := TBitmap.Create;
  try
    Immagine.PixelFormat := pf24bit;
    // solo l'area interna. PaintTo lascia vuoti i componenti DevExpress e,
    // sulla form principale, solleva "Il canvas non consente il disegno"
    // (barra di stato del ribbon): provato su Gesty il 2026-10-18. Si prova
    // PrintWindow con una bitmap compatibile con lo schermo; PrintWindow con
    // una bitmap TBitmap (24 o 32 bit) fallisce con PW_RENDERFULLCONTENT o
    // restituisce bianco, e il flag 0 restituisce bianco. Se anche cosi'
    // non riesce, copia dallo schermo; PaintTo resta come ultimo ripiego
    if not CatturaConPrintWindow(Form, Immagine) and not CatturaDalloSchermo(Form, Immagine) then
    begin
      Immagine.SetSize(Form.ClientWidth, Form.ClientHeight);
      Form.PaintTo(Immagine.Canvas.Handle, 0, 0);
    end;
    Png := TPngImage.Create;
    Flusso := TBytesStream.Create;
    try
      Png.Assign(Immagine);
      Png.SaveToStream(Flusso);
      Codifica := TBase64Encoding.Create(0);
      try
        Result := Codifica.EncodeBytesToString(Copy(Flusso.Bytes, 0, Flusso.Size));
      finally
        Codifica.Free;
      end;
    finally
      Flusso.Free;
      Png.Free;
    end;
  finally
    Immagine.Free;
  end;
end;

// ----- clic e tasti ----------------------------------------------------------------
//
// Messaggi di Windows spediti alle finestre del programma, mai il mouse o la
// tastiera veri: il cursore, il fuoco e i tasti dell'utente non si toccano, e
// chi lavora sul computer non se ne accorge. I messaggi passano da tutto il
// percorso normale (VCL, DevExpress, scorciatoie).
//
// QUALE FINESTRA. Windows non da' il messaggio del mouse al controllo che si
// voleva cliccare, ma alla finestra che sta sotto il punto (la figlia piu'
// interna), o a quella che ha preso la cattura del mouse dopo la pressione.
// La sonda fa lo stesso, messaggio per messaggio: per questo il clic e'
// sincrono (SendMessage), perche' la finestra giusta per il rilascio si
// conosce solo dopo che la pressione e' stata elaborata. Il caso che lo
// richiede: le celle-collegamento delle griglie DevExpress (TcxHyperLinkEdit
// con SingleClick). Alla pressione la griglia crea l'editor della cella e gli
// passa la pressione (TcxCustomEdit.ActivateByMouse); il collegamento si apre
// sul rilascio, che deve arrivare all'editor e non alla griglia. Fino al
// 2026-11-03 la sonda spediva tutto alla griglia con PostMessage: la riga si
// selezionava, il collegamento non partiva (R-218, Mantis 6413).
//
// PULSANTE PREMUTO. Fra pressione e rilascio, per il solo thread principale,
// lo stato dei tasti dice che il pulsante sinistro e' premuto, come durante
// il clic vero: ActivateByMouse toglie la cattura all'editor se non lo e'.
//
// CLIC CON CTRL, MAIUSC, ALT. I controlli leggono i modificatori da due parti:
// i flag MK_CONTROL e MK_SHIFT del messaggio (la VCL li passa in Shift a
// MouseDown) e GetKeyState (Alt sempre, e il codice che li controlla da se').
// La sonda mette i flag nei messaggi e, per la durata del clic, cambia con
// SetKeyboardState lo stato dei tasti del solo thread principale: e' uno
// stato per thread, quindi la tastiera dell'utente e gli altri programmi non
// lo vedono.
//
// LIMITI. I tasti di app_tasti restano senza Ctrl, Alt e Maiusc. Il clic
// destro non si spedisce come clic: il menu si posizionerebbe sul cursore
// vero e TcxGridPopupMenu sceglie il menu dalla posizione del cursore vero
// (GetMouseCursorPos). C'e' MenuContestuale, che non mostra il menu. Un
// gestore che legge la posizione del cursore vero (Mouse.CursorPos) invece
// di quella del messaggio vede un altro punto: il doppio clic delle viste di
// zBase legge MouseDownPos dal 2026-11-03 per questo.

type
  TBersaglioMouse = record
    Finestra: HWND;
    // angolo in alto a sinistra del componente, nelle coordinate client della
    // finestra a cui si spediscono i messaggi
    Origine: TPoint;
    Larghezza, Altezza: Integer;
  end;

// Finestra a cui porta una proprieta' di tipo TWinControl (Site delle viste
// di una griglia DevExpress, InnerControl degli editor), nil se non c'e'.
function ControlloDaProprieta(Componente: TObject; const Nome: string): TWinControl;
var
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
  Letto: TObject;
begin
  Result := nil;
  Proprieta := Contesto.GetType(Componente.ClassType).GetProperty(Nome);
  if (Proprieta = nil) or not Proprieta.IsReadable or (Proprieta.PropertyType.TypeKind <> tkClass) then
    Exit;
  try
    Letto := Proprieta.GetValue(Componente).AsObject;
  except
    // una proprieta' che solleva (componente a meta') vale come assente
    Letto := nil;
  end;
  if Letto is TWinControl then
    Result := TWinControl(Letto);
end;

function BersaglioMouseDi(Componente: TComponent): TBersaglioMouse;
var
  Finestra: TWinControl;
begin
  Result := Default (TBersaglioMouse);
  if Componente is TWinControl then
  begin
    Finestra := TWinControl(Componente);
    Result.Larghezza := Finestra.ClientWidth;
    Result.Altezza := Finestra.ClientHeight;
  end
  else if Componente is TControl then
  begin
    // controllo senza finestra: i messaggi vanno al genitore, alle coordinate
    // del controllo dentro il genitore
    Finestra := TControl(Componente).Parent;
    Result.Origine := Point(TControl(Componente).Left, TControl(Componente).Top);
    Result.Larghezza := TControl(Componente).Width;
    Result.Altezza := TControl(Componente).Height;
  end
  else
  begin
    // componenti non visuali che hanno una finestra propria (la vista di una
    // griglia ha il Site)
    Finestra := ControlloDaProprieta(Componente, 'Site');
    if Finestra = nil then
      Finestra := ControlloDaProprieta(Componente, 'Control');
    if Finestra <> nil then
    begin
      Result.Larghezza := Finestra.ClientWidth;
      Result.Altezza := Finestra.ClientHeight;
    end;
  end;
  if Finestra = nil then
    raise ESonda.CreateFmt('%s (%s) non ha una finestra a cui spedire un clic: per le azioni usa esegui.',
      [IndirizzoDi(Componente), Componente.ClassName]);
  if not Finestra.HandleAllocated or not IsWindowVisible(Finestra.Handle) then
    raise ESonda.CreateFmt('%s non e'' visibile: non si puo'' cliccare.', [IndirizzoDi(Componente)]);
  Result.Finestra := Finestra.Handle;
end;

function ModificatoriDaTesto(const Testo: string): TModificatoriClic;
var
  Pezzo: string;
begin
  Result := [];
  for Pezzo in Testo.Split([' ', ',', '+', ';'], TStringSplitOptions.ExcludeEmpty) do
    if MatchText(Pezzo, ['ctrl', 'control', 'controllo']) then
      Include(Result, mcCtrl)
    else if MatchText(Pezzo, ['maiusc', 'shift']) then
      Include(Result, mcMaiusc)
    else if MatchText(Pezzo, ['alt']) then
      Include(Result, mcAlt)
    else
      raise ESonda.CreateFmt('Modificatore sconosciuto "%s": ammessi ctrl, maiusc (shift), alt.', [Pezzo]);
end;

function TestoModificatori(Modificatori: TModificatoriClic): string;
begin
  Result := '';
  if mcCtrl in Modificatori then
    Result := Result + 'Ctrl+';
  if mcMaiusc in Modificatori then
    Result := Result + 'Maiusc+';
  if mcAlt in Modificatori then
    Result := Result + 'Alt+';
end;

// I flag del mouse che dicono quali modificatori sono premuti.
function FlagModificatori(Modificatori: TModificatoriClic): WPARAM;
begin
  Result := 0;
  if mcCtrl in Modificatori then
    Result := Result or MK_CONTROL;
  if mcMaiusc in Modificatori then
    Result := Result or MK_SHIFT;
end;

// La finestra a cui Windows darebbe un messaggio del mouse nel punto (in
// coordinate dello schermo): quella che ha la cattura nel thread, se c'e';
// altrimenti la figlia piu' interna, visibile e abilitata, sotto il punto,
// partendo da Radice.
function FinestraNelPunto(Radice: HWND; const Schermo: TPoint): HWND;
var
  Figlia: HWND;
  Locale: TPoint;
begin
  Result := GetCapture;
  if Result <> 0 then
    Exit;
  Result := Radice;
  repeat
    Locale := Schermo;
    Winapi.Windows.ScreenToClient(Result, Locale);
    Figlia := ChildWindowFromPointEx(Result, Locale, CWP_SKIPINVISIBLE or CWP_SKIPDISABLED or CWP_SKIPTRANSPARENT);
    if (Figlia = 0) or (Figlia = Result) then
      Break;
    Result := Figlia;
  until False;
end;

// Il controllo VCL di una finestra, per il resoconto: indirizzo, o la classe
// della finestra se non e' della VCL.
function DescriviFinestra(Finestra: HWND): string;
var
  Controllo: TWinControl;
  Classe: array [0 .. 255] of Char;
begin
  Controllo := FindControl(Finestra);
  if Controllo <> nil then
  begin
    Result := IndirizzoDi(Controllo);
    if Controllo.Name = '' then
      Result := Result + ' (' + Controllo.ClassName + ')';
    Exit;
  end;
  SetString(Result, Classe, GetClassName(Finestra, Classe, Length(Classe)));
  Result := 'finestra ' + Result;
end;

// Clic sincrono nel punto dello schermo Schermo: ogni messaggio va alla
// finestra che Windows sceglierebbe in quel momento, con i modificatori, e
// fra pressione e rilascio il pulsante sinistro, premuti per il solo thread
// principale. Lo stato dei tasti si rimette com'era anche se il controllo
// solleva. Ricevente e' la finestra che ha avuto la pressione.
procedure ClicInstradato(Radice: HWND; const Schermo: TPoint; Doppio: Boolean; Modificatori: TModificatoriClic;
  out Ricevente: HWND);
const
  Premuto = $80;
var
  Originale, Modificato, ConPulsante: TKeyboardState;
  Flag: WPARAM;
  Destinataria: HWND;

  procedure Spedisci(Messaggio: UINT; PulsantePremuto: Boolean);
  var
    Locale: TPoint;
    Pulsanti: WPARAM;
  begin
    // la pressione puo' aver chiuso la finestra (un collegamento che chiude la
    // form): il resto del clic non ha piu' dove andare
    if not IsWindow(Radice) and (GetCapture = 0) then
      Exit;
    Pulsanti := Flag;
    if PulsantePremuto then
    begin
      SetKeyboardState(ConPulsante);
      Pulsanti := Pulsanti or MK_LBUTTON;
    end
    else
      SetKeyboardState(Modificato);
    Destinataria := FinestraNelPunto(Radice, Schermo);
    Locale := Schermo;
    Winapi.Windows.ScreenToClient(Destinataria, Locale);
    SendMessage(Destinataria, Messaggio, Pulsanti, LPARAM(MakeLong(Word(Locale.X), Word(Locale.Y))));
  end;

begin
  GetKeyboardState(Originale);
  Modificato := Originale;
  if mcCtrl in Modificatori then
  begin
    Modificato[VK_CONTROL] := Modificato[VK_CONTROL] or Premuto;
    Modificato[VK_LCONTROL] := Modificato[VK_LCONTROL] or Premuto;
  end;
  if mcMaiusc in Modificatori then
  begin
    Modificato[VK_SHIFT] := Modificato[VK_SHIFT] or Premuto;
    Modificato[VK_LSHIFT] := Modificato[VK_LSHIFT] or Premuto;
  end;
  if mcAlt in Modificatori then
  begin
    Modificato[VK_MENU] := Modificato[VK_MENU] or Premuto;
    Modificato[VK_LMENU] := Modificato[VK_LMENU] or Premuto;
  end;
  ConPulsante := Modificato;
  ConPulsante[VK_LBUTTON] := ConPulsante[VK_LBUTTON] or Premuto;
  Flag := FlagModificatori(Modificatori);
  Destinataria := Radice;
  try
    // prima uno spostamento, perche' i controlli che evidenziano la riga sotto
    // il cursore (griglie, liste) lo aspettano prima del pulsante
    Spedisci(WM_MOUSEMOVE, False);
    Spedisci(WM_LBUTTONDOWN, True);
    Ricevente := Destinataria;
    Spedisci(WM_LBUTTONUP, False);
    if Doppio then
    begin
      Spedisci(WM_LBUTTONDBLCLK, True);
      Spedisci(WM_LBUTTONUP, False);
    end;
  finally
    SetKeyboardState(Originale);
  end;
end;

function PuntoNelBersaglio(Componente: TComponent; const Bersaglio: TBersaglioMouse; var X, Y: Integer): TPoint;
begin
  if X < 0 then
    X := Bersaglio.Larghezza div 2;
  if Y < 0 then
    Y := Bersaglio.Altezza div 2;
  if (X >= Bersaglio.Larghezza) or (Y >= Bersaglio.Altezza) then
    raise ESonda.CreateFmt('Il punto (%d, %d) e'' fuori da %s, che misura %d x %d.',
      [X, Y, IndirizzoDi(Componente), Bersaglio.Larghezza, Bersaglio.Altezza]);
  Result := Point(Bersaglio.Origine.X + X, Bersaglio.Origine.Y + Y);
end;

function ResocontoClic(Ricevente: HWND; Doppio: Boolean; Modificatori: TModificatoriClic;
  const Descrizione: string): string;
begin
  Result := Format('%s%s su %s', [TestoModificatori(Modificatori), IfThen(Doppio, 'doppio clic', 'clic'),
    Descrizione]);
  if Ricevente <> 0 then
    Result := Result + ', ricevuto da ' + DescriviFinestra(Ricevente);
end;

function ClicNellaFinestra(Finestra: TWinControl; const Punto: TPoint; Doppio: Boolean;
  Modificatori: TModificatoriClic; const Descrizione: string): string;
var
  Ricevente: HWND;
begin
  if not Finestra.HandleAllocated or not IsWindowVisible(Finestra.Handle) then
    raise ESonda.CreateFmt('%s non e'' visibile: non si puo'' cliccare.', [IndirizzoDi(Finestra)]);
  ClicInstradato(Finestra.Handle, Finestra.ClientToScreen(Punto), Doppio, Modificatori, Ricevente);
  Result := ResocontoClic(Ricevente, Doppio, Modificatori, Descrizione);
end;

// X e Y negativi = centro del componente.
function ClicSuComponente(Componente: TComponent; X, Y: Integer; Doppio: Boolean;
  Modificatori: TModificatoriClic): string;
var
  Bersaglio: TBersaglioMouse;
  Punto, Schermo: TPoint;
  Ricevente: HWND;
begin
  if (Componente is TControl) and not TControl(Componente).Enabled then
    raise ESonda.CreateFmt('Il controllo %s e'' disabilitato.', [IndirizzoDi(Componente)]);

  // schede e colonne di griglia: le conosce Sonda.zBase
  if Assigned(ClicSpecialeSonda) then
  begin
    Result := ClicSpecialeSonda(Componente, X, Y, Doppio, Modificatori);
    if Result <> '' then
      Exit;
  end;

  // un pulsante senza coordinate: BM_CLICK e' il suo clic, senza dover
  // indovinare dove sta il punto sensibile
  if (X < 0) and (Y < 0) and not Doppio and (Modificatori = []) and (Componente is TButtonControl) and
    TWinControl(Componente).HandleAllocated and IsWindowVisible(TWinControl(Componente).Handle) then
  begin
    PostMessage(TWinControl(Componente).Handle, BM_CLICK, 0, 0);
    Exit('pulsante premuto: ' + IndirizzoDi(Componente));
  end;

  Bersaglio := BersaglioMouseDi(Componente);
  Punto := PuntoNelBersaglio(Componente, Bersaglio, X, Y);
  Schermo := Punto;
  Winapi.Windows.ClientToScreen(Bersaglio.Finestra, Schermo);
  ClicInstradato(Bersaglio.Finestra, Schermo, Doppio, Modificatori, Ricevente);
  Result := ResocontoClic(Ricevente, Doppio, Modificatori, Format('%s a (%d, %d)', [IndirizzoDi(Componente), X, Y]));
end;

// ----- menu contestuale -------------------------------------------------------------
//
// Il clic destro dell'utente fa due cose: il controllo riceve pressione e
// rilascio del pulsante destro (una griglia porta il fuoco sulla riga), poi
// DefWindowProc, sul rilascio, manda WM_CONTEXTMENU e il menu si apre. La sonda
// fa la prima e toglie la seconda: per la durata del clic WindowProc del
// controllo passa da un filtro, e WM_CONTEXTMENU non arriva al controllo ne'
// ai genitori. SetWindowSubclass no: dentro Gesty rifiuta le finestre della
// VCL. Il menu non compare, quindi non prende il fuoco di Windows
// (Popup chiama SetForegroundWindow) e non si posiziona sul cursore vero.
//
// QUALE MENU. Prima il risolutore registrato da Sonda.zBase (griglie
// DevExpress: TcxGridPopupMenu sceglie il menu dalla zona colpita, intestazione,
// riga, pannello del raggruppamento). Poi la regola della VCL: il controllo
// senza finestra sotto il punto, poi il PopupMenu del controllo o del primo
// genitore che ne ha uno. OnContextPopup NON si chiama: alcuni gestori aprono
// il menu da se' (PopupFromCursorPos), cioe' sul cursore vero.
//
// VOCI. Di un TPopupMenu si chiama OnPopup (DoPopup, che prepara le voci senza
// mostrare niente; per i menu del risolutore lo fa il risolutore), poi si
// leggono le TMenuItem con le sottovoci. Le voci di un
// TdxBarPopupMenu le da' Sonda.zBase; il suo OnPopup scatta solo all'apertura
// vera e non si chiama. Le voci collegate a un'azione sono comunque
// aggiornate: la sonda chiama Update dell'azione prima di descriverla.
//
// PREMERE UNA VOCE. TMenuItem.Click o TdxBarItem.Click, come il clic
// dell'utente sul menu aperto; i menu predefiniti delle griglie (intestazione,
// piede) non hanno un proprietario e non si raggiungono con un indirizzo:
// per questo la voce si preme nello stesso comando.

type
  TPopupMenuAccess = class(TPopupMenu);
  TControlAccess = class(TControl);

  // Filtro messo per la durata del clic destro al posto di WindowProc del
  // controllo: toglie WM_CONTEXTMENU e passa tutto il resto all'originale.
  TFiltroMenuContestuale = class
  private
    FOriginale: TWndMethod;
  public
    Tolti: Integer;
    constructor Create(Originale: TWndMethod);
    procedure Filtra(var Messaggio: TMessage);
  end;

constructor TFiltroMenuContestuale.Create(Originale: TWndMethod);
begin
  inherited Create;
  FOriginale := Originale;
end;

procedure TFiltroMenuContestuale.Filtra(var Messaggio: TMessage);
begin
  if Messaggio.Msg = WM_CONTEXTMENU then
  begin
    Inc(Tolti);
    Messaggio.Result := 0;
    Exit;
  end;
  FOriginale(Messaggio);
end;

// Restituisce quanti WM_CONTEXTMENU ha tolto: 0 vuol dire che il controllo non
// ha chiesto il menu.
function ClicDestroSenzaMenu(Finestra: TWinControl; Posizione: LPARAM): Integer;
var
  Filtro: TFiltroMenuContestuale;
begin
  Filtro := TFiltroMenuContestuale.Create(Finestra.WindowProc);
  try
    Finestra.WindowProc := Filtro.Filtra;
    try
      SendMessage(Finestra.Handle, WM_MOUSEMOVE, 0, Posizione);
      SendMessage(Finestra.Handle, WM_RBUTTONDOWN, MK_RBUTTON, Posizione);
      SendMessage(Finestra.Handle, WM_RBUTTONUP, 0, Posizione);
    finally
      Finestra.WindowProc := Filtro.FOriginale;
    end;
    Result := Filtro.Tolti;
  finally
    Filtro.Free;
  end;
end;

// La regola della VCL (TControl.WMContextMenu): il controllo senza finestra
// sotto il punto, poi il primo PopupMenu risalendo i genitori.
function MenuDellaVcl(Finestra: TWinControl; const Punto: TPoint; out Proprietario: TControl): TPopupMenu;
var
  Controllo: TControl;
begin
  Result := nil;
  Controllo := Finestra.ControlAtPos(Punto, False, True);
  if Controllo = nil then
    Controllo := Finestra;
  while Controllo <> nil do
  begin
    Result := TControlAccess(Controllo).GetPopupMenu;
    if (Result <> nil) and Result.AutoPopup then
    begin
      Proprietario := Controllo;
      Exit;
    end;
    Result := nil;
    Controllo := Controllo.Parent;
  end;
  Proprietario := nil;
end;

function DescriviVoceMenu(Voce: TMenuItem): TJSONObject;
var
  Sottovoci: TJSONArray;
  Indice: Integer;
begin
  if Voce.Action <> nil then
    Voce.Action.Update;
  Result := TJSONObject.Create;
  if Voce.Name <> '' then
    Result.AddPair('nome', Voce.Name);
  Result.AddPair('didascalia', StripHotkey(Voce.Caption));
  Result.AddPair('abilitata', TJSONBool.Create(Voce.Enabled));
  if Voce.Checked then
    Result.AddPair('spuntata', TJSONBool.Create(True));
  if Voce.ShortCut <> 0 then
    Result.AddPair('scorciatoia', ShortCutToText(Voce.ShortCut));
  if Voce.Count > 0 then
  begin
    Sottovoci := TJSONArray.Create;
    for Indice := 0 to Voce.Count - 1 do
      if Voce.Items[Indice].Visible and not Voce.Items[Indice].IsLine then
        Sottovoci.AddElement(DescriviVoceMenu(Voce.Items[Indice]));
    Result.AddPair('voci', Sottovoci);
  end;
end;

function VociDelMenu(Menu: TComponent): TArray<TComponent>;
var
  Elenco: TList<TComponent>;

  procedure Raccogli(Padre: TMenuItem);
  var
    Indice: Integer;
  begin
    for Indice := 0 to Padre.Count - 1 do
      if Padre.Items[Indice].Visible and not Padre.Items[Indice].IsLine then
      begin
        Elenco.Add(Padre.Items[Indice]);
        Raccogli(Padre.Items[Indice]);
      end;
  end;

begin
  if Menu is TPopupMenu then
  begin
    Elenco := TList<TComponent>.Create;
    try
      Raccogli(TPopupMenu(Menu).Items);
      Result := Elenco.ToArray;
    finally
      Elenco.Free;
    end;
  end
  else if Assigned(VociMenuContestualeSonda) then
    Result := VociMenuContestualeSonda(Menu)
  else
    Result := nil;
end;

function NomeVoce(Voce: TComponent): string;
begin
  if Voce is TMenuItem then
    Result := StripHotkey(TMenuItem(Voce).Caption)
  else
    Result := StripHotkey(DidascaliaDi(Voce));
end;

function CercaVoce(Menu: TComponent; const Cercata: string): TComponent;
var
  Voce: TComponent;
  Trovate: TList<TComponent>;
  Nomi: TStringBuilder;
begin
  Trovate := TList<TComponent>.Create;
  try
    for Voce in VociDelMenu(Menu) do
      if SameText(NomeVoce(Voce), Cercata) or ((Voce.Name <> '') and SameText(Voce.Name, Cercata)) then
        Trovate.Add(Voce);
    if Trovate.Count = 1 then
      Exit(Trovate[0]);
    Nomi := TStringBuilder.Create;
    try
      if Trovate.Count = 0 then
      begin
        for Voce in VociDelMenu(Menu) do
          Nomi.Append(IfThen(Nomi.Length > 0, ', ', '')).Append(NomeVoce(Voce));
        raise ESonda.CreateFmt('Il menu %s non ha la voce "%s". Voci: %s.', [Menu.ClassName, Cercata, Nomi.ToString]);
      end;
      for Voce in Trovate do
        Nomi.Append(IfThen(Nomi.Length > 0, ', ', '')).Append(IfThen(Voce.Name <> '', Voce.Name, NomeVoce(Voce)));
      raise ESonda.CreateFmt('Nel menu ci sono %d voci "%s" (%s): indica il Name.', [Trovate.Count, Cercata, Nomi.ToString]);
    finally
      Nomi.Free;
    end;
  finally
    Trovate.Free;
  end;
end;

function PremiVoceMenu(Voce: TComponent): string;
begin
  if Voce is TMenuItem then
  begin
    if TMenuItem(Voce).Action <> nil then
      TMenuItem(Voce).Action.Update;
    if not TMenuItem(Voce).Enabled then
      raise ESonda.CreateFmt('La voce "%s" del menu e'' disabilitata.', [NomeVoce(Voce)]);
    if TMenuItem(Voce).Count > 0 then
      raise ESonda.CreateFmt('"%s" e'' un sottomenu: indica una delle sue voci.', [NomeVoce(Voce)]);
    TMenuItem(Voce).Click;
    Exit(Format('voce del menu contestuale premuta: %s', [NomeVoce(Voce)]));
  end;
  Result := PremiVoceBarra(Voce);
end;

function MenuContestuale(Componente: TComponent; X, Y: Integer; const Voce: string;
  Divieto: TFunc<TComponent, string>): TJSONObject;
var
  Bersaglio: TBersaglioMouse;
  Posizione: LPARAM;
  Finestra: TWinControl;
  Punto: TPoint;
  Menu: TComponent;
  Proprietario: TControl;
  Nota, Motivo: string;
  Voci: TJSONArray;
  Elemento: TComponent;
  Scelta: TComponent;
  Indice, MenuContestualiTolti: Integer;
begin
  if (Componente is TControl) and not TControl(Componente).Enabled then
    raise ESonda.CreateFmt('Il controllo %s e'' disabilitato.', [IndirizzoDi(Componente)]);
  Bersaglio := BersaglioMouseDi(Componente);
  Punto := PuntoNelBersaglio(Componente, Bersaglio, X, Y);
  Posizione := LPARAM(MakeLong(Word(Punto.X), Word(Punto.Y)));
  Finestra := FindControl(Bersaglio.Finestra);
  if Finestra = nil then
    raise ESonda.CreateFmt('La finestra di %s non e'' un controllo della VCL.', [IndirizzoDi(Componente)]);

  MenuContestualiTolti := ClicDestroSenzaMenu(Finestra, Posizione);

  Menu := nil;
  Nota := '';
  Proprietario := nil;
  if Assigned(RisolutoreMenuContestualeSonda) then
    Menu := RisolutoreMenuContestualeSonda(Finestra, Punto, Nota);
  if Menu = nil then
    Menu := MenuDellaVcl(Finestra, Punto, Proprietario);

  Result := TJSONObject.Create;
  try
    Result.AddPair('clic_destro', Format('%s a (%d, %d)', [IndirizzoDi(Componente), X, Y]));
    if Nota <> '' then
      Result.AddPair('zona', Nota);
    if MenuContestualiTolti = 0 then
      // il controllo non ha chiesto il menu: un gestore del clic destro lo
      // avrebbe aperto da se' o non c'e' menu
      Result.AddPair('avviso', 'Il controllo non ha chiesto il menu (nessun WM_CONTEXTMENU): il menu indicato ' +
        'e'' quello configurato, ma il programma potrebbe non mostrarlo.');
    if Menu = nil then
    begin
      Result.AddPair('menu', TJSONNull.Create);
      Result.AddPair('messaggio', 'Nessun menu contestuale in questo punto.');
      if Voce <> '' then
        raise ESonda.CreateFmt('Nessun menu contestuale su %s in (%d, %d): la voce "%s" non si puo'' premere.',
          [IndirizzoDi(Componente), X, Y, Voce]);
      Exit;
    end;

    // PopupComponent e OnPopup come li fa il Popup della VCL; i menu del
    // risolutore li prepara lui (i menu predefiniti delle griglie hanno
    // bisogno della zona colpita prima di DoPopup)
    if (Menu is TPopupMenu) and (Proprietario <> nil) then
    begin
      TPopupMenu(Menu).PopupComponent := Proprietario;
      TPopupMenuAccess(Menu).DoPopup(Menu);
    end;

    Result.AddPair('menu', IfThen(Menu.Name <> '', IndirizzoDi(Menu), '(' + Menu.ClassName + ')'));
    Result.AddPair('classe', Menu.ClassName);

    if Voce <> '' then
    begin
      Scelta := CercaVoce(Menu, Voce);
      if Assigned(Divieto) then
      begin
        Motivo := Divieto(Scelta);
        if Motivo <> '' then
          raise ESonda.Create(Motivo);
      end;
      Result.AddPair('premuta', PremiVoceMenu(Scelta));
      Exit;
    end;

    Voci := TJSONArray.Create;
    Result.AddPair('voci', Voci);
    if Menu is TPopupMenu then
    begin
      for Indice := 0 to TPopupMenu(Menu).Items.Count - 1 do
        if TPopupMenu(Menu).Items[Indice].Visible and not TPopupMenu(Menu).Items[Indice].IsLine then
          Voci.AddElement(DescriviVoceMenu(TPopupMenu(Menu).Items[Indice]));
    end
    else
      for Elemento in VociDelMenu(Menu) do
        Voci.AddElement(DescriviVoceBarra(Elemento));
  except
    Result.Free;
    raise;
  end;
end;

// ----- splitter e trascinamento -----------------------------------------------------
//
// Uno splitter si sposta come lo sposta l'utente: pulsante premuto, qualche
// spostamento col pulsante premuto, rilascio. A differenza del clic i
// messaggi sono sincroni (SendMessage dal thread principale): fra la
// pressione e il rilascio il mouse vero non puo' infilarsi, e alla risposta
// il pannello ha gia' la misura nuova. Cosi' valgono le regole del componente
// (MinSize, OnCanResize, AutoSnap, OnMoved) senza rifarle qui.
//
// SPLITTER RICONOSCIUTI. TSplitter e discendenti (TzSplitter di WT) e, per
// nome di classe senza dipendere da DevExpress, TcxCustomSplitter. Il
// pannello che cambia misura e' Control del TcxSplitter se impostato,
// altrimenti il controllo piu' vicino con lo stesso Align, dalla parte verso
// cui lo splitter e' allineato: la regola di FindControl dei due componenti.
//
// PUNTO DI PRESA. Non il centro: al centro di un TcxSplitter c'e' la zona
// sensibile (HotZone, il 30% centrale), dove un clic chiude o apre il pannello
// invece di spostarlo. Si prende lo splitter a un decimo della lunghezza.
//
// SPLITTER DEL LAYOUT DEVEXPRESS. TdxLayoutSplitterItem non e' un controllo:
// e' un elemento di un TdxLayoutControl, disegnato dentro la sua finestra. Si
// legge tutto con l'RTTI, per nome: la finestra e' Container.ItemsParent, il
// rettangolo e' ViewInfo.Bounds (coordinate client della finestra, scorrimento
// gia' compreso; valido solo se ActuallyVisible, perche' gli elementi di una
// scheda non attiva o di un gruppo chiuso hanno un ViewInfo con misure
// degeneri), IsVertical dice
// se la barra e' verticale (si trascina lungo X). L'elemento che cambia misura
// e' quello vicino (GetNearItem) o lontano (GetFarItem), secondo la regola del
// componente: quello che non riempie lo spazio (AlignHorz/AlignVert diverso da
// Client), il lontano se lo splitter e' allineato a destra o in basso. La
// misura e' ViewInfo.Bounds dell'elemento, la stessa che usa il componente.
// Il TdxLayoutControl trascina solo se ha il fuoco: la sonda glielo da' prima
// della pressione, come lo prenderebbe il clic dell'utente. La presa e' al
// centro della barra: un clic senza movimento la chiuderebbe
// (AllowCloseOnClick), ma il trascinamento si muove sempre.

type
  TLatoSplitter = (lsNessuno, lsSinistra, lsDestra, lsAlto, lsBasso);

  TSplitterLayout = record
    Finestra: TWinControl;
    // la barra, nelle coordinate client della finestra
    Barra: TRect;
    Verticale: Boolean;
    // l'elemento che cambia misura e da che parte sta; nil e lsNessuno se lo
    // splitter non ne ridimensiona nessuno (allineato al centro o Client)
    Elemento: TComponent;
    Lato: TLatoSplitter;
  end;

const
  NomiLatoSplitter: array [TLatoSplitter] of string = ('nessuno', 'sinistra', 'destra', 'alto', 'basso');
  PassiTrascinamento = 4;

function SplitterRiconosciuto(Componente: TComponent): Boolean;
begin
  Result := (Componente is TSplitter) or
    ((Componente is TControl) and DiscendeDa(Componente.ClassType, 'TcxCustomSplitter'));
end;

function SplitterDelLayout(Componente: TComponent): Boolean;
begin
  Result := (Componente <> nil) and DiscendeDa(Componente.ClassType, 'TdxLayoutSplitterItem');
end;

// ViewInfo.Bounds di un elemento del layout; False se l'elemento non si vede.
function RettangoloElemento(Elemento: TObject; out Rettangolo: TRect): Boolean;
var
  Valore: TValue;
begin
  Result := False;
  Rettangolo := TRect.Empty;
  Valore := LeggiProprieta(LeggiOggetto(Elemento, 'ViewInfo'), 'Bounds');
  if Valore.IsEmpty or (Valore.Kind <> tkRecord) or (Valore.DataSize <> SizeOf(TRect)) then
    Exit;
  Valore.ExtractRawData(@Rettangolo);
  Result := True;
end;

// Chiama per nome un metodo pubblico senza parametri che restituisce un
// oggetto; nil se non c'e' o se solleva.
function OggettoDaMetodo(Oggetto: TObject; const Nome: string): TObject;
var
  Contesto: TRttiContext;
  Metodo: TRttiMethod;
  Valore: TValue;
begin
  Result := nil;
  Metodo := Contesto.GetType(Oggetto.ClassType).GetMethod(Nome);
  if (Metodo = nil) or (Length(Metodo.GetParameters) > 0) then
    Exit;
  try
    Valore := Metodo.Invoke(Oggetto, []);
    if Valore.IsObject then
      Result := Valore.AsObject;
  except
    // un elemento a meta' (senza ViewInfo) vale come assente
    Result := nil;
  end;
end;

// Allineamento dell'elemento lungo l'asse dello splitter, come nome
// (ahLeft, ahClient, avBottom...).
function AllineamentoElemento(Elemento: TObject; Verticale: Boolean): string;
var
  Valore: TValue;
begin
  Result := '';
  if Elemento = nil then
    Exit;
  if Verticale then
    Valore := LeggiProprieta(Elemento, 'AlignHorz')
  else
    Valore := LeggiProprieta(Elemento, 'AlignVert');
  if not Valore.IsEmpty then
    Result := Valore.ToString;
end;

function ElementoRiempie(Elemento: TObject; Verticale: Boolean): Boolean;
begin
  Result := EndsText('Client', AllineamentoElemento(Elemento, Verticale));
end;

function LeggiIntero(Oggetto: TObject; const Nome: string; Predefinito: Integer): Integer;
var
  Valore: TValue;
begin
  Valore := LeggiProprieta(Oggetto, Nome);
  if Valore.IsEmpty or (Valore.Kind <> tkInteger) then
    Exit(Predefinito);
  Result := Valore.AsInteger;
end;

function NomeElementoLayout(Elemento: TObject): string;
begin
  if Elemento is TComponent then
    Result := IndirizzoDi(TComponent(Elemento))
  else
    Result := Elemento.ClassName;
end;

// Perche' uno splitter del layout non si vede; vuoto se si vede. Il ViewInfo
// c'e' anche per gli elementi di una scheda non attiva o di un gruppo chiuso,
// con misure che non valgono (una barra 10 x 0, o un elemento largo 7 che il
// trascinamento non sposta): decide ActuallyVisible, la regola con cui il
// componente disegna (Visible, Expanded dei gruppi, AllowDrawChild del gruppo
// a schede, che disegna solo il figlio con Index = ItemIndex). Si risale ai
// gruppi per dire quale scheda o gruppo lo nasconde.
function MotivoSplitterNascosto(Splitter: TComponent): string;
var
  Elemento, Gruppo: TObject;
  Attiva: Integer;
begin
  Result := '';
  if LeggiBooleano(Splitter, 'ActuallyVisible', True) then
    Exit;
  Elemento := Splitter;
  while Elemento <> nil do
  begin
    if not LeggiBooleano(Elemento, 'Visible', True) then
      Exit(Format('non e'' visibile: %s ha Visible = False', [NomeElementoLayout(Elemento)]));
    Gruppo := LeggiOggetto(Elemento, 'Parent');
    if Gruppo = nil then
      Break;
    if not LeggiBooleano(Gruppo, 'Expanded', True) then
      Exit(Format('non e'' visibile: il gruppo %s e'' chiuso (Expanded = False)', [NomeElementoLayout(Gruppo)]));
    Attiva := LeggiIntero(Gruppo, 'ItemIndex', -1);
    if SameText(LeggiProprieta(Gruppo, 'LayoutDirection').ToString, 'ldTabbed') and
      (LeggiIntero(Elemento, 'Index', Attiva) <> Attiva) then
      Exit(Format('non e'' visibile: sta nella scheda "%s" (%s) del gruppo a schede %s, che mostra la scheda %d: ' +
        'va attivata prima quella dello splitter', [LeggiProprieta(Elemento, 'Caption').ToString,
        NomeElementoLayout(Elemento), NomeElementoLayout(Gruppo), Attiva]));
    Elemento := Gruppo;
  end;
  Result := 'non e'' visibile (nascosto, in una scheda non attiva o in un gruppo chiuso)';
end;

// Finestra, barra ed elemento ridimensionato di uno splitter del layout.
// False, con il motivo, se lo splitter non si vede.
function LeggiSplitterLayout(Splitter: TComponent; out Dati: TSplitterLayout; out Motivo: string): Boolean;
var
  Finestra, Vicino, Lontano: TObject;
  Allineamento: string;
begin
  Result := False;
  Dati := Default (TSplitterLayout);
  Motivo := '';
  Finestra := LeggiOggetto(LeggiOggetto(Splitter, 'Container'), 'ItemsParent');
  if not (Finestra is TWinControl) then
  begin
    Motivo := 'non trovo il TdxLayoutControl che lo contiene (Container.ItemsParent)';
    Exit;
  end;
  Dati.Finestra := TWinControl(Finestra);
  Motivo := MotivoSplitterNascosto(Splitter);
  if Motivo <> '' then
    Exit;
  if not RettangoloElemento(Splitter, Dati.Barra) then
  begin
    Motivo := 'non e'' visibile (nessun ViewInfo: nascosto, in una scheda non attiva o in un gruppo chiuso)';
    Exit;
  end;
  Dati.Verticale := LeggiBooleano(Splitter, 'IsVertical', True);
  // visibile ma senza area: la barra lunga 0 (es. 10 x 0) non si prende
  // nemmeno col mouse; la lunghezza la decide l'allineamento sull'altro asse
  if Dati.Barra.IsEmpty then
  begin
    Motivo := Format('ha una barra di %d x %d pixel: il layout non le da'' spazio (allineamento %s), ' +
      'e non si puo'' prendere nemmeno col mouse', [Dati.Barra.Width, Dati.Barra.Height,
      AllineamentoElemento(Splitter, not Dati.Verticale)]);
    Exit;
  end;

  Allineamento := AllineamentoElemento(Splitter, Dati.Verticale);
  Vicino := OggettoDaMetodo(Splitter, 'GetNearItem');
  Lontano := OggettoDaMetodo(Splitter, 'GetFarItem');
  // uno splitter al centro o Client non ridimensiona niente (lssNone)
  if not (EndsText('Center', Allineamento) or EndsText('Client', Allineamento)) then
  begin
    // si ridimensiona un elemento che non riempie lo spazio: il lontano per
    // gli splitter allineati a destra o in basso, il vicino per gli altri,
    // l'altro se quello preferito manca o riempie
    if (Vicino is TComponent) and not ElementoRiempie(Vicino, Dati.Verticale) and
      not (MatchText(Allineamento, ['ahRight', 'avBottom']) and (Lontano is TComponent) and
      not ElementoRiempie(Lontano, Dati.Verticale)) then
      Dati.Elemento := TComponent(Vicino)
    else if (Lontano is TComponent) and not ElementoRiempie(Lontano, Dati.Verticale) then
      Dati.Elemento := TComponent(Lontano)
    else if (Vicino is TComponent) and (Lontano is TComponent) then
      // riempiono tutti e due: cambiano entrambi, si riporta il vicino
      Dati.Elemento := TComponent(Vicino);
    // un solo vicino che riempie (lo splitter e' in fondo alla sua zona di
    // allineamento): il componente non sposta niente
  end;
  if Dati.Elemento = nil then
    Dati.Lato := lsNessuno
  else if Dati.Elemento = Vicino then
  begin
    if Dati.Verticale then
      Dati.Lato := lsSinistra
    else
      Dati.Lato := lsAlto;
  end
  else if Dati.Verticale then
    Dati.Lato := lsDestra
  else
    Dati.Lato := lsBasso;
  Result := True;
end;

// Larghezza o altezza disegnata di un elemento del layout; -1 se non si vede.
function MisuraElementoLayout(Elemento: TObject; Verticale: Boolean): Integer;
var
  Rettangolo: TRect;
begin
  if not RettangoloElemento(Elemento, Rettangolo) then
    Exit(-1);
  if Verticale then
    Result := Rettangolo.Width
  else
    Result := Rettangolo.Height;
end;

function LatoSplitter(Splitter: TControl): TLatoSplitter;
begin
  case Splitter.Align of
    alLeft:
      Result := lsSinistra;
    alRight:
      Result := lsDestra;
    alTop:
      Result := lsAlto;
    alBottom:
      Result := lsBasso;
  else
    Result := lsNessuno;
  end;
end;

function PannelloDelloSplitter(Splitter: TControl): TControl;
var
  Collegato: TObject;
  Indice: Integer;
  Candidato: TControl;
begin
  Result := nil;
  if Splitter.Parent = nil then
    Exit;
  Collegato := LeggiOggetto(Splitter, 'Control');
  if (Collegato is TControl) and TControl(Collegato).Visible and (TControl(Collegato).Align = Splitter.Align) then
    Exit(TControl(Collegato));
  for Indice := 0 to Splitter.Parent.ControlCount - 1 do
  begin
    Candidato := Splitter.Parent.Controls[Indice];
    if (Candidato = Splitter) or not Candidato.Visible or (Candidato.Align <> Splitter.Align) or
      SplitterRiconosciuto(Candidato) then
      Continue;
    case Splitter.Align of
      alLeft:
        if (Candidato.Left + Candidato.Width <= Splitter.Left + 1) and ((Result = nil) or (Candidato.Left > Result.Left)) then
          Result := Candidato;
      alRight:
        if (Candidato.Left >= Splitter.Left + Splitter.Width - 1) and ((Result = nil) or (Candidato.Left < Result.Left)) then
          Result := Candidato;
      alTop:
        if (Candidato.Top + Candidato.Height <= Splitter.Top + 1) and ((Result = nil) or (Candidato.Top > Result.Top)) then
          Result := Candidato;
      alBottom:
        if (Candidato.Top >= Splitter.Top + Splitter.Height - 1) and ((Result = nil) or (Candidato.Top < Result.Top)) then
          Result := Candidato;
    end;
  end;
end;

// La misura del pannello che lo splitter cambia: larghezza o altezza.
function MisuraPannello(Pannello: TControl; Lato: TLatoSplitter): Integer;
begin
  if Lato in [lsSinistra, lsDestra] then
    Result := Pannello.Width
  else
    Result := Pannello.Height;
end;

procedure AggiungiVicinoLayout(Descrizione: TJSONObject; const Nome: string; Elemento: TObject; Verticale: Boolean);
begin
  if Elemento is TComponent then
    Descrizione.AddPair(Nome, IndirizzoDi(TComponent(Elemento)) + ' (' + AllineamentoElemento(Elemento, Verticale) + ')')
  else
    Descrizione.AddPair(Nome, TJSONNull.Create);
end;

function DescriviSplitterLayout(Splitter: TComponent): TJSONObject;
var
  Dati: TSplitterLayout;
  Motivo: string;
begin
  Result := TJSONObject.Create;
  if not LeggiSplitterLayout(Splitter, Dati, Motivo) then
  begin
    Result.AddPair('visibile', TJSONBool.Create(LeggiBooleano(Splitter, 'ActuallyVisible', True)));
    Result.AddPair('nota', Motivo);
    Exit;
  end;
  Result.AddPair('lato', NomiLatoSplitter[Dati.Lato]);
  if Dati.Elemento <> nil then
  begin
    Result.AddPair('pannello', IndirizzoDi(Dati.Elemento));
    Result.AddPair('dimensione', TJSONNumber.Create(MisuraElementoLayout(Dati.Elemento, Dati.Verticale)));
  end;
  Result.AddPair('chiuso', TJSONBool.Create(LeggiBooleano(Splitter, 'IsClosed', False)));
  // i due elementi ai lati, con l'allineamento: dicono perche' lo splitter
  // ridimensiona quello che ridimensiona, o niente
  AggiungiVicinoLayout(Result, 'vicino', OggettoDaMetodo(Splitter, 'GetNearItem'), Dati.Verticale);
  AggiungiVicinoLayout(Result, 'lontano', OggettoDaMetodo(Splitter, 'GetFarItem'), Dati.Verticale);
end;

function DescriviSplitter(Componente: TComponent): TJSONObject;
var
  Lato: TLatoSplitter;
  Pannello: TControl;
  Stato: TValue;
begin
  if SplitterDelLayout(Componente) then
    Exit(DescriviSplitterLayout(Componente));
  if not SplitterRiconosciuto(Componente) then
    Exit(nil);
  Lato := LatoSplitter(TControl(Componente));
  Result := TJSONObject.Create;
  Result.AddPair('lato', NomiLatoSplitter[Lato]);
  Pannello := PannelloDelloSplitter(TControl(Componente));
  if (Pannello <> nil) and (Lato <> lsNessuno) then
  begin
    Result.AddPair('pannello', IndirizzoDi(Pannello));
    Result.AddPair('dimensione', TJSONNumber.Create(MisuraPannello(Pannello, Lato)));
  end;
  // TcxSplitter: State dice se il pannello e' chiuso dalla zona sensibile
  Stato := LeggiProprieta(Componente, 'State');
  if not Stato.IsEmpty and (Stato.Kind = tkEnumeration) then
    Result.AddPair('chiuso', TJSONBool.Create(SameText(Stato.ToString, 'ssClosed')));
end;

procedure SpedisciTrascinamento(const Bersaglio: TBersaglioMouse; const Partenza, Arrivo: TPoint);

  function Posizione(const Punto: TPoint): LPARAM;
  begin
    // le coordinate possono uscire dal controllo, anche negative: WM_MOUSEMOVE
    // le porta come SmallInt
    Result := LPARAM(MakeLong(Word(Bersaglio.Origine.X + Punto.X), Word(Bersaglio.Origine.Y + Punto.Y)));
  end;

var
  Passo: Integer;
  Punto: TPoint;
begin
  SendMessage(Bersaglio.Finestra, WM_MOUSEMOVE, 0, Posizione(Partenza));
  SendMessage(Bersaglio.Finestra, WM_LBUTTONDOWN, MK_LBUTTON, Posizione(Partenza));
  // piu' passi, perche' i componenti con una soglia di trascinamento
  // (DragThreshold) partono solo dopo qualche pixel
  for Passo := 1 to PassiTrascinamento do
  begin
    Punto.X := Partenza.X + MulDiv(Arrivo.X - Partenza.X, Passo, PassiTrascinamento);
    Punto.Y := Partenza.Y + MulDiv(Arrivo.Y - Partenza.Y, Passo, PassiTrascinamento);
    SendMessage(Bersaglio.Finestra, WM_MOUSEMOVE, MK_LBUTTON, Posizione(Punto));
  end;
  SendMessage(Bersaglio.Finestra, WM_LBUTTONUP, 0, Posizione(Arrivo));
end;

// Spostamento lungo l'asse dello splitter che porta il pannello alla misura
// voluta.
function SpostamentoPerDimensione(Lato: TLatoSplitter; Prima, Dimensione: Integer): Integer;
begin
  case Lato of
    lsSinistra, lsAlto:
      Result := Dimensione - Prima;
    lsDestra, lsBasso:
      Result := Prima - Dimensione;
  else
    Result := 0;
  end;
end;

function TrascinaSplitterLayout(Splitter: TComponent; X, Y, SpostamentoX, SpostamentoY, Dimensione: Integer): TJSONObject;
var
  Dati: TSplitterLayout;
  Motivo, Indirizzo: string;
  Bersaglio: TBersaglioMouse;
  Prima, Dopo: Integer;
begin
  Indirizzo := IndirizzoDi(Splitter);
  if not LeggiBooleano(Splitter, 'Enabled', True) then
    raise ESonda.CreateFmt('Lo splitter %s e'' disabilitato.', [Indirizzo]);
  if not LeggiSplitterLayout(Splitter, Dati, Motivo) then
    raise ESonda.CreateFmt('Lo splitter %s %s.', [Indirizzo, Motivo]);
  if not Dati.Finestra.HandleAllocated or not IsWindowVisible(Dati.Finestra.Handle) then
    raise ESonda.CreateFmt('Il layout di %s non e'' visibile: non si puo'' trascinare.', [Indirizzo]);

  Prima := -1;
  if Dati.Elemento <> nil then
    Prima := MisuraElementoLayout(Dati.Elemento, Dati.Verticale);
  if Dimensione >= 0 then
  begin
    if Dati.Elemento = nil then
      raise ESonda.CreateFmt('Lo splitter %s non ridimensiona un elemento solo (e'' allineato al centro o Client): ' +
        'indica lo spostamento invece della dimensione.', [Indirizzo]);
    if Dati.Verticale then
      SpostamentoX := SpostamentoPerDimensione(Dati.Lato, Prima, Dimensione)
    else
      SpostamentoY := SpostamentoPerDimensione(Dati.Lato, Prima, Dimensione);
  end;
  // la barra si muove su un asse solo
  if Dati.Verticale then
    SpostamentoY := 0
  else
    SpostamentoX := 0;

  Bersaglio := Default (TBersaglioMouse);
  Bersaglio.Finestra := Dati.Finestra.Handle;
  Bersaglio.Origine := Dati.Barra.TopLeft;
  Bersaglio.Larghezza := Dati.Barra.Width;
  Bersaglio.Altezza := Dati.Barra.Height;
  if X < 0 then
    X := Bersaglio.Larghezza div 2;
  if Y < 0 then
    Y := Bersaglio.Altezza div 2;
  if (X >= Bersaglio.Larghezza) or (Y >= Bersaglio.Altezza) then
    raise ESonda.CreateFmt('Il punto (%d, %d) e'' fuori dalla barra di %s, che misura %d x %d.',
      [X, Y, Indirizzo, Bersaglio.Larghezza, Bersaglio.Altezza]);

  Result := TJSONObject.Create;
  try
    Result.AddPair('trascinato', Indirizzo);
    if (SpostamentoX = 0) and (SpostamentoY = 0) then
      Result.AddPair('messaggio', 'Spostamento nullo: niente da trascinare.')
    else
    begin
      // senza fuoco il TdxLayoutControl non comincia il trascinamento: lo
      // prende come lo prenderebbe col clic dell'utente
      if (GetFocus <> Dati.Finestra.Handle) and Dati.Finestra.CanFocus then
        Dati.Finestra.SetFocus;
      if GetFocus <> Dati.Finestra.Handle then
        raise ESonda.CreateFmt('Il layout di %s non prende il fuoco: senza, il trascinamento non parte.', [Indirizzo]);
      SpedisciTrascinamento(Bersaglio, Point(X, Y), Point(X + SpostamentoX, Y + SpostamentoY));
      Result.AddPair('da', TJSONArray.Create.Add(X).Add(Y));
      Result.AddPair('spostamento', TJSONArray.Create.Add(SpostamentoX).Add(SpostamentoY));
    end;
    if Dati.Elemento <> nil then
    begin
      Dopo := MisuraElementoLayout(Dati.Elemento, Dati.Verticale);
      Result.AddPair('pannello', IndirizzoDi(Dati.Elemento));
      Result.AddPair('dimensione_prima', TJSONNumber.Create(Prima));
      Result.AddPair('dimensione_dopo', TJSONNumber.Create(Dopo));
      if (Dimensione >= 0) and (Dopo <> Dimensione) then
        Result.AddPair('nota', Format('L''elemento si e'' fermato a %d invece di %d: lo limitano le misure minime ' +
          'e massime, lo spazio del layout o il programma (OnCanResize).', [Dopo, Dimensione]));
    end;
    Result.AddPair('chiuso', TJSONBool.Create(LeggiBooleano(Splitter, 'IsClosed', False)));
  except
    Result.Free;
    raise;
  end;
end;

function TrascinaSuComponente(Componente: TComponent; X, Y, SpostamentoX, SpostamentoY, Dimensione: Integer): TJSONObject;
var
  Bersaglio: TBersaglioMouse;
  Pannello: TControl;
  Lato: TLatoSplitter;
  Prima, Dopo: Integer;
begin
  if SplitterDelLayout(Componente) then
    Exit(TrascinaSplitterLayout(Componente, X, Y, SpostamentoX, SpostamentoY, Dimensione));
  if (Componente is TControl) and not TControl(Componente).Enabled then
    raise ESonda.CreateFmt('Il controllo %s e'' disabilitato.', [IndirizzoDi(Componente)]);
  Bersaglio := BersaglioMouseDi(Componente);
  Pannello := nil;
  Lato := lsNessuno;
  Prima := 0;

  if SplitterRiconosciuto(Componente) then
  begin
    Lato := LatoSplitter(TControl(Componente));
    if Lato = lsNessuno then
      raise ESonda.CreateFmt('Lo splitter %s non e'' allineato a un lato: non sposta niente.', [IndirizzoDi(Componente)]);
    Pannello := PannelloDelloSplitter(TControl(Componente));
    if Pannello <> nil then
      Prima := MisuraPannello(Pannello, Lato);
    if Dimensione >= 0 then
    begin
      if Pannello = nil then
        raise ESonda.CreateFmt('Non trovo il pannello che %s ridimensiona: indica lo spostamento invece della dimensione.',
          [IndirizzoDi(Componente)]);
      case Lato of
        lsSinistra:
          SpostamentoX := Dimensione - Prima;
        lsDestra:
          SpostamentoX := Prima - Dimensione;
        lsAlto:
          SpostamentoY := Dimensione - Prima;
        lsBasso:
          SpostamentoY := Prima - Dimensione;
      end;
    end;
    // uno splitter si muove su un asse solo
    if Lato in [lsSinistra, lsDestra] then
    begin
      SpostamentoY := 0;
      if X < 0 then
        X := Bersaglio.Larghezza div 2;
      if Y < 0 then
        Y := Bersaglio.Altezza div 10;
    end
    else
    begin
      SpostamentoX := 0;
      if X < 0 then
        X := Bersaglio.Larghezza div 10;
      if Y < 0 then
        Y := Bersaglio.Altezza div 2;
    end;
  end
  else
  begin
    if Dimensione >= 0 then
      raise ESonda.CreateFmt('%s (%s) non e'' uno splitter: la dimensione vale solo per gli splitter, ' +
        'per il resto indica lo spostamento.', [IndirizzoDi(Componente), Componente.ClassName]);
    if X < 0 then
      X := Bersaglio.Larghezza div 2;
    if Y < 0 then
      Y := Bersaglio.Altezza div 2;
  end;
  if (X >= Bersaglio.Larghezza) or (Y >= Bersaglio.Altezza) then
    raise ESonda.CreateFmt('Il punto (%d, %d) e'' fuori da %s, che misura %d x %d.',
      [X, Y, IndirizzoDi(Componente), Bersaglio.Larghezza, Bersaglio.Altezza]);

  Result := TJSONObject.Create;
  try
    Result.AddPair('trascinato', IndirizzoDi(Componente));
    if (SpostamentoX = 0) and (SpostamentoY = 0) then
      Result.AddPair('messaggio', 'Spostamento nullo: niente da trascinare.')
    else
    begin
      SpedisciTrascinamento(Bersaglio, Point(X, Y), Point(X + SpostamentoX, Y + SpostamentoY));
      Result.AddPair('da', TJSONArray.Create.Add(X).Add(Y));
      Result.AddPair('spostamento', TJSONArray.Create.Add(SpostamentoX).Add(SpostamentoY));
    end;
    if Pannello <> nil then
    begin
      Dopo := MisuraPannello(Pannello, Lato);
      Result.AddPair('pannello', IndirizzoDi(Pannello));
      Result.AddPair('dimensione_prima', TJSONNumber.Create(Prima));
      Result.AddPair('dimensione_dopo', TJSONNumber.Create(Dopo));
      if (Dimensione >= 0) and (Dopo <> Dimensione) then
        Result.AddPair('nota', Format('Il pannello si e'' fermato a %d invece di %d: lo limitano il minimo o il massimo ' +
          'dello splitter, lo spazio della form o il programma (OnCanResize).', [Dopo, Dimensione]));
    end;
  except
    Result.Free;
    raise;
  end;
end;

// Il controllo che riceve i tasti: quello indicato (per un editor
// DevExpress, la sua finestra interna) o, senza indirizzo, il controllo
// attivo della form attiva secondo la VCL.
function BersaglioTastiera(const Indirizzo: string): TComponent;
begin
  if Indirizzo <> '' then
    Exit(TrovaComponente(Indirizzo));
  Result := Screen.ActiveControl;
  if Result = nil then
    Result := Screen.ActiveCustomForm;
  if Result = nil then
    raise ESonda.Create('Nessun controllo attivo: indica l''indirizzo del controllo a cui mandare i tasti.');
end;

// Il pulsante predefinito (Default=True) della form del componente: il tasto
// Invio lo preme, anche se il controllo che riceve il tasto e' un altro.
function PulsantePredefinito(Componente: TComponent): TComponent;
var
  Form: TCustomForm;

  function Cerca(Contenitore: TComponent): TComponent;
  var
    Indice: Integer;
    Figlio: TComponent;
  begin
    Result := nil;
    for Indice := 0 to Contenitore.ComponentCount - 1 do
    begin
      Figlio := Contenitore.Components[Indice];
      if (Figlio is TButton) and TButton(Figlio).Default and TButton(Figlio).Enabled and
        TButton(Figlio).Visible then
        Exit(Figlio);
      if Figlio.ComponentCount > 0 then
      begin
        Result := Cerca(Figlio);
        if Result <> nil then
          Exit;
      end;
    end;
  end;

begin
  Result := nil;
  if Componente is TControl then
    Form := GetParentForm(TControl(Componente))
  else
    Form := Screen.ActiveCustomForm;
  if Form <> nil then
    Result := Cerca(Form);
end;

function CodiceTasto(const Nome: string; out Esteso: Boolean): Integer;
var
  Numero: Integer;
begin
  Esteso := False;
  Result := 0;
  if Nome.Contains('+') then
    raise ESonda.CreateFmt('Il tasto "%s" ha un modificatore (Ctrl, Alt, Maiusc): non si puo'' simulare, ' +
      'i controlli leggono quello stato dalla tastiera vera.', [Nome]);
  if SameText(Nome, 'Tab') then
    Result := VK_TAB
  else if SameText(Nome, 'Invio') or SameText(Nome, 'Enter') then
    Result := VK_RETURN
  else if SameText(Nome, 'Esc') or SameText(Nome, 'Esci') then
    Result := VK_ESCAPE
  else if SameText(Nome, 'Spazio') then
    Result := VK_SPACE
  else if SameText(Nome, 'Backspace') then
    Result := VK_BACK
  else if SameText(Nome, 'Canc') or SameText(Nome, 'Del') then
  begin
    Result := VK_DELETE;
    Esteso := True;
  end
  else if SameText(Nome, 'Ins') then
  begin
    Result := VK_INSERT;
    Esteso := True;
  end
  else if SameText(Nome, 'Su') then
  begin
    Result := VK_UP;
    Esteso := True;
  end
  else if SameText(Nome, 'Giu') or SameText(Nome, 'Giù') then
  begin
    Result := VK_DOWN;
    Esteso := True;
  end
  else if SameText(Nome, 'Sinistra') then
  begin
    Result := VK_LEFT;
    Esteso := True;
  end
  else if SameText(Nome, 'Destra') then
  begin
    Result := VK_RIGHT;
    Esteso := True;
  end
  else if SameText(Nome, 'Home') then
  begin
    Result := VK_HOME;
    Esteso := True;
  end
  else if SameText(Nome, 'Fine') or SameText(Nome, 'End') then
  begin
    Result := VK_END;
    Esteso := True;
  end
  else if SameText(Nome, 'PagSu') then
  begin
    Result := VK_PRIOR;
    Esteso := True;
  end
  else if SameText(Nome, 'PagGiu') or SameText(Nome, 'PagGiù') then
  begin
    Result := VK_NEXT;
    Esteso := True;
  end
  else if (Length(Nome) in [2, 3]) and (UpCase(Nome[1]) = 'F') and TryStrToInt(Copy(Nome, 2, MaxInt), Numero) and
    (Numero in [1 .. 12]) then
    Result := VK_F1 + Numero - 1;
  if Result = 0 then
    raise ESonda.CreateFmt('Tasto "%s" sconosciuto. Validi: Tab, Invio, Esc, Spazio, Backspace, Canc, Ins, Su, Giu, ' +
      'Sinistra, Destra, Home, Fine, PagSu, PagGiu, F1-F12. Per le lettere usa testo.', [Nome]);
end;

function ParametroTasto(Codice: Integer; Esteso, Rilascio: Boolean): LPARAM;
var
  Valore: Cardinal;
begin
  Valore := 1 or (MapVirtualKey(Codice, MAPVK_VK_TO_VSC) shl 16);
  if Esteso then
    Valore := Valore or (1 shl 24);
  if Rilascio then
    Valore := Valore or $40000000 or $80000000;
  Result := LPARAM(Valore);
end;

// Prima il testo, un carattere alla volta (WM_CHAR), poi i tasti separati da
// spazi (Tab Invio Giu). Restituisce quanti ne ha spediti.
function TastiSuComponente(Componente: TComponent; const Testo, Tasti: string): string;
var
  Controllo, Interno: TWinControl;
  Finestra: HWND;
  Nome: string;
  Codice, Caratteri, Premuti: Integer;
  Esteso: Boolean;
  Carattere: Char;
begin
  Caratteri := 0;
  Premuti := 0;
  if not (Componente is TWinControl) then
    raise ESonda.CreateFmt('%s (%s) non riceve tasti: indica un controllo con finestra.',
      [IndirizzoDi(Componente), Componente.ClassName]);
  Controllo := TWinControl(Componente);
  // un editor DevExpress passa i tasti alla sua finestra interna
  Interno := ControlloDaProprieta(Controllo, 'InnerControl');
  if Interno <> nil then
    Controllo := Interno;
  if not Controllo.HandleAllocated or not IsWindowVisible(Controllo.Handle) then
    raise ESonda.CreateFmt('%s non e'' visibile: non riceve tasti.', [IndirizzoDi(Componente)]);
  if not Controllo.Enabled then
    raise ESonda.CreateFmt('Il controllo %s e'' disabilitato.', [IndirizzoDi(Componente)]);

  // il fuoco secondo la VCL (non quello di Windows, che resta all'utente):
  // gli editor cambiano comportamento solo se sono "attivi"
  if Controllo.CanFocus and (Screen.ActiveControl <> Controllo) then
    try
      Controllo.SetFocus;
    except
      // un controllo che non puo' prendere il fuoco riceve comunque i messaggi
      Exit(Format('Il controllo %s non ha preso il fuoco: nessun tasto spedito.', [IndirizzoDi(Componente)]));
    end;

  // i nomi dei tasti si controllano tutti prima di spedire il primo: un nome
  // sbagliato in fondo non deve lasciare l'elenco spedito a meta'
  for Nome in Tasti.Split([' ', ',', ';'], TStringSplitOptions.ExcludeEmpty) do
    CodiceTasto(Nome, Esteso);

  Finestra := Controllo.Handle;
  for Carattere in Testo do
  begin
    PostMessage(Finestra, WM_CHAR, Ord(Carattere), 1);
    Inc(Caratteri);
  end;
  for Nome in Tasti.Split([' ', ',', ';'], TStringSplitOptions.ExcludeEmpty) do
  begin
    Codice := CodiceTasto(Nome, Esteso);
    PostMessage(Finestra, WM_KEYDOWN, Codice, ParametroTasto(Codice, Esteso, False));
    PostMessage(Finestra, WM_KEYUP, Codice, ParametroTasto(Codice, Esteso, True));
    Inc(Premuti);
  end;
  Result := Format('%d caratteri e %d tasti spediti a %s', [Caratteri, Premuti, IndirizzoDi(Controllo)]);
end;

end.
