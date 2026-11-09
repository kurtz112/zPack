// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-30
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// Sonda.Dialoghi
//
// Riconosce i dialoghi modali aperti dall'applicazione e risponde al posto
// dell'utente. Due famiglie:
//
//   - form VCL modali (fsModal in FormState): i dialoghi DevExpress di
//     zMsg.Confirm* (TdxMessageDialogForm), la finestra di login, il dialogo
//     delle eccezioni, i MessageDlg della VCL quando non usano TaskDialog.
//     Testo dalla proprieta' Message se c'e', altrimenti dalle etichette;
//     pulsanti dai componenti con Caption e ModalResult.
//
//   - finestre native di classe #32770 del thread principale: MessageBox,
//     Application.MessageBox, TaskDialog, dialoghi dei file. Testo dai
//     controlli Static, pulsanti dai controlli Button. Il TaskDialog disegna
//     tutto in un solo controllo DirectUIHWND: il testo non si legge, ma si
//     risponde con TDM_CLICK_BUTTON e l'identificativo del pulsante.
//
// Le finestre di altri processi (Word, Acrobat, browser) non sono di
// competenza della sonda.
//
// TUTTO SUL THREAD PRINCIPALE, come Sonda.Ispezione. Funziona anche mentre un
// dialogo e' aperto perche' il ciclo modale della VCL e quello nativo di
// MessageBox continuano a eseguire la coda di TThread.Queue (WM_NULL alla
// finestra dell'applicazione -> CheckSynchronize).
//
// ***************************************************************************

unit Sonda.Dialoghi;

interface

uses
  System.SysUtils,
  System.JSON,
  Winapi.Windows;

// Dialoghi modali aperti, dal piu' recente.
function ElencoDialoghi: TJSONArray;

// Vero se c'e' almeno un dialogo modale aperto.
function CiSonoDialoghi: Boolean;

// Testo di tutti i dialoghi aperti, per le regole di risposta automatica.
function TestoDialogoPiuRecente(out Finestra: HWND): string;

// Risponde al dialogo piu' recente (o a quello indicato da Finestra) premendo
// il pulsante con quella didascalia o quel risultato (OK, Si', No, Annulla,
// mrYes...). Testo, se valorizzato, va prima nel primo campo modificabile.
function RispondiDialogo(const Pulsante, Testo: string; Finestra: HWND): string;

implementation

uses
  System.Types,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  System.StrUtils,
  System.Generics.Collections,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Menus,
  Sonda.Ispezione;

const
  ClasseDialogoNativo = '#32770';
  TDM_CLICK_BUTTON = WM_USER + 102;

type
  TPulsanteDialogo = record
    Testo: string;
    // il risultato che il pulsante produce, anche quando non e' nel suo
    // ModalResult (i pulsanti di TdxMessageDialogForm lo calcolano nel clic
    // dal Tag, e si chiamano Yes, No, OK, Cancel...)
    Risultato: Integer;
    ModalResult: Integer;
    Componente: TComponent;
    Finestra: HWND;
  end;

  TDialogo = record
    Finestra: HWND;
    Nativo: Boolean;
    TaskDialog: Boolean;
    Form: TCustomForm;
    Classe: string;
    Titolo: string;
    Testo: string;
    Pulsanti: TArray<TPulsanteDialogo>;
  end;

// ----- nomi dei risultati -----------------------------------------------------

function RisultatoDaNome(const Nome: string): Integer;
var
  Pulito: string;
begin
  Pulito := LowerCase(StripHotkey(Nome).Trim);
  if Pulito.StartsWith('mr') then
    Delete(Pulito, 1, 2);
  if MatchText(Pulito, ['ok']) then
    Exit(IDOK);
  if MatchText(Pulito, ['annulla', 'cancel']) then
    Exit(IDCANCEL);
  if MatchText(Pulito, ['sì', 'si', 'yes']) then
    Exit(IDYES);
  if MatchText(Pulito, ['no']) then
    Exit(IDNO);
  if MatchText(Pulito, ['interrompi', 'abort']) then
    Exit(IDABORT);
  if MatchText(Pulito, ['riprova', 'retry']) then
    Exit(IDRETRY);
  if MatchText(Pulito, ['ignora', 'ignore']) then
    Exit(IDIGNORE);
  if MatchText(Pulito, ['chiudi', 'close']) then
    Exit(IDCLOSE);
  Result := 0;
end;

function NomeRisultato(Risultato: Integer): string;
begin
  case Risultato of
    IDOK: Result := 'OK';
    IDCANCEL: Result := 'Annulla';
    IDABORT: Result := 'Interrompi';
    IDRETRY: Result := 'Riprova';
    IDIGNORE: Result := 'Ignora';
    IDYES: Result := 'Sì';
    IDNO: Result := 'No';
    IDCLOSE: Result := 'Chiudi';
  else
    Result := '';
  end;
end;

// ----- finestre native ----------------------------------------------------------

function ClasseFinestra(Finestra: HWND): string;
var
  Buffer: array [0 .. 255] of Char;
begin
  SetString(Result, Buffer, GetClassName(Finestra, Buffer, Length(Buffer)));
end;

function TestoFinestra(Finestra: HWND): string;
var
  Lunghezza: Integer;
begin
  Lunghezza := GetWindowTextLength(Finestra);
  SetLength(Result, Lunghezza);
  if Lunghezza > 0 then
    SetLength(Result, GetWindowText(Finestra, PChar(Result), Lunghezza + 1));
end;

type
  TRaccolta = class
    Finestre: TList<HWND>;
    constructor Create;
    destructor Destroy; override;
  end;

constructor TRaccolta.Create;
begin
  inherited;
  Finestre := TList<HWND>.Create;
end;

destructor TRaccolta.Destroy;
begin
  Finestre.Free;
  inherited;
end;

function RaccogliFinestra(Finestra: HWND; Dati: LPARAM): BOOL; stdcall;
begin
  TRaccolta(Dati).Finestre.Add(Finestra);
  Result := True;
end;

function FinestreFiglie(Finestra: HWND): TArray<HWND>;
var
  Raccolta: TRaccolta;
begin
  Raccolta := TRaccolta.Create;
  try
    EnumChildWindows(Finestra, @RaccogliFinestra, LPARAM(Raccolta));
    Result := Raccolta.Finestre.ToArray;
  finally
    Raccolta.Free;
  end;
end;

function FinestreDelThreadPrincipale: TArray<HWND>;
var
  Raccolta: TRaccolta;
begin
  Raccolta := TRaccolta.Create;
  try
    EnumThreadWindows(MainThreadID, @RaccogliFinestra, LPARAM(Raccolta));
    Result := Raccolta.Finestre.ToArray;
  finally
    Raccolta.Free;
  end;
end;

function DialogoNativo(Finestra: HWND): TDialogo;
var
  Figlia: HWND;
  Classe, Testo: string;
  Pulsante: TPulsanteDialogo;
  Pulsanti: TList<TPulsanteDialogo>;
  Righe: TStringList;
begin
  Result := Default (TDialogo);
  Result.Finestra := Finestra;
  Result.Nativo := True;
  Result.Classe := ClasseDialogoNativo;
  Result.Titolo := TestoFinestra(Finestra);
  Pulsanti := TList<TPulsanteDialogo>.Create;
  Righe := TStringList.Create;
  try
    for Figlia in FinestreFiglie(Finestra) do
    begin
      if not IsWindowVisible(Figlia) then
        Continue;
      Classe := ClasseFinestra(Figlia);
      Testo := TestoFinestra(Figlia);
      if SameText(Classe, 'Static') and (Testo <> '') then
        Righe.Add(Testo)
      else if SameText(Classe, 'Button') and (Testo <> '') then
      begin
        Pulsante := Default (TPulsanteDialogo);
        Pulsante.Testo := StripHotkey(Testo);
        Pulsante.Risultato := GetDlgCtrlID(Figlia);
        Pulsante.Finestra := Figlia;
        Pulsanti.Add(Pulsante);
      end
      else if SameText(Classe, 'DirectUIHWND') then
        Result.TaskDialog := True;
    end;
    Result.Testo := Righe.Text.Trim;
    Result.Pulsanti := Pulsanti.ToArray;
    if Result.TaskDialog then
      Result.Classe := 'TaskDialog';
  finally
    Righe.Free;
    Pulsanti.Free;
  end;
end;

// ----- form VCL --------------------------------------------------------------------

function LeggiProprieta(Oggetto: TObject; const Nome: string; out Valore: TValue): Boolean;
var
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
begin
  Proprieta := Contesto.GetType(Oggetto.ClassType).GetProperty(Nome);
  Result := (Proprieta <> nil) and Proprieta.IsReadable;
  if Result then
    try
      Valore := Proprieta.GetValue(Oggetto);
    except
      Result := False;
    end;
end;

function SembraEtichetta(Componente: TComponent): Boolean;
begin
  Result := ContainsText(Componente.ClassName, 'Label') or (Componente is TCustomStaticText);
end;

procedure RaccogliDaForm(Contenitore: TComponent; Righe: TStrings; Pulsanti: TList<TPulsanteDialogo>);
var
  Indice: Integer;
  Figlio: TComponent;
  Didascalia, Risultato: TValue;
  Pulsante: TPulsanteDialogo;
begin
  for Indice := 0 to Contenitore.ComponentCount - 1 do
  begin
    Figlio := Contenitore.Components[Indice];
    if (Figlio is TControl) and not TControl(Figlio).Visible then
      Continue;
    if LeggiProprieta(Figlio, 'ModalResult', Risultato) and LeggiProprieta(Figlio, 'Caption', Didascalia) and
      (Didascalia.AsString <> '') then
    begin
      Pulsante := Default (TPulsanteDialogo);
      Pulsante.Testo := StripHotkey(Didascalia.AsString);
      Pulsante.ModalResult := Risultato.AsOrdinal;
      Pulsante.Risultato := Pulsante.ModalResult;
      if Pulsante.Risultato = mrNone then
        Pulsante.Risultato := RisultatoDaNome(Figlio.Name);
      if Pulsante.Risultato = mrNone then
        Pulsante.Risultato := RisultatoDaNome(Pulsante.Testo);
      Pulsante.Componente := Figlio;
      Pulsanti.Add(Pulsante);
    end
    else if SembraEtichetta(Figlio) and LeggiProprieta(Figlio, 'Caption', Didascalia) and
      (Didascalia.AsString <> '') then
      Righe.Add(Didascalia.AsString);
    if Figlio.ComponentCount > 0 then
      RaccogliDaForm(Figlio, Righe, Pulsanti);
  end;
end;

function DialogoVcl(Form: TCustomForm): TDialogo;
var
  Messaggio: TValue;
  Righe: TStringList;
  Pulsanti: TList<TPulsanteDialogo>;
begin
  Result := Default (TDialogo);
  Result.Form := Form;
  Result.Finestra := Form.Handle;
  Result.Classe := Form.ClassName;
  Result.Titolo := Form.Caption;
  Righe := TStringList.Create;
  Pulsanti := TList<TPulsanteDialogo>.Create;
  try
    RaccogliDaForm(Form, Righe, Pulsanti);
    // TdxMessageDialogForm.Message: il testo intero, non spezzato fra
    // etichette e voci del layout
    if LeggiProprieta(Form, 'Message', Messaggio) and (Messaggio.Kind in [tkUString, tkString, tkLString, tkWString]) and
      (Messaggio.AsString <> '') then
      Result.Testo := Messaggio.AsString
    else
      Result.Testo := Righe.Text.Trim;
    Result.Pulsanti := Pulsanti.ToArray;
  finally
    Pulsanti.Free;
    Righe.Free;
  end;
end;

// ----- elenco ----------------------------------------------------------------------

function Dialoghi: TArray<TDialogo>;
var
  Elenco: TList<TDialogo>;
  Indice: Integer;
  Form: TCustomForm;
  Finestra: HWND;
begin
  Elenco := TList<TDialogo>.Create;
  try
    // Screen.CustomForms e' in ordine di attivazione: la prima e' la piu' recente
    for Indice := 0 to Screen.CustomFormCount - 1 do
    begin
      Form := Screen.CustomForms[Indice];
      if Form.Visible and (fsModal in Form.FormState) then
        Elenco.Add(DialogoVcl(Form));
    end;
    // le finestre native nell'ordine Z: la prima e' quella in primo piano
    for Finestra in FinestreDelThreadPrincipale do
      if IsWindowVisible(Finestra) and SameText(ClasseFinestra(Finestra), ClasseDialogoNativo) then
        Elenco.Insert(0, DialogoNativo(Finestra));
    Result := Elenco.ToArray;
  finally
    Elenco.Free;
  end;
end;

function CiSonoDialoghi: Boolean;
begin
  Result := Length(Dialoghi) > 0;
end;

function ElencoDialoghi: TJSONArray;
var
  Dialogo: TDialogo;
  Voce: TJSONObject;
  Pulsanti: TJSONArray;
  Pulsante: TPulsanteDialogo;
begin
  Result := TJSONArray.Create;
  for Dialogo in Dialoghi do
  begin
    Voce := TJSONObject.Create;
    Voce.AddPair('finestra', TJSONNumber.Create(Int64(Dialogo.Finestra)));
    Voce.AddPair('tipo', IfThen(Dialogo.Nativo, 'nativo', 'vcl'));
    Voce.AddPair('classe', Dialogo.Classe);
    Voce.AddPair('titolo', Dialogo.Titolo);
    Voce.AddPair('testo', Dialogo.Testo);
    if Dialogo.TaskDialog then
      Voce.AddPair('nota', 'TaskDialog: testo e pulsanti non leggibili; si risponde con OK, Sì, No, Annulla');
    if Dialogo.Form <> nil then
      Voce.AddPair('indirizzo', IndirizzoDi(Dialogo.Form));
    Pulsanti := TJSONArray.Create;
    for Pulsante in Dialogo.Pulsanti do
      Pulsanti.Add(Pulsante.Testo);
    Voce.AddPair('pulsanti', Pulsanti);
    Result.AddElement(Voce);
  end;
end;

function TestoDialogoPiuRecente(out Finestra: HWND): string;
var
  Elenco: TArray<TDialogo>;
begin
  Elenco := Dialoghi;
  if Length(Elenco) = 0 then
  begin
    Finestra := 0;
    Exit('');
  end;
  Finestra := Elenco[0].Finestra;
  Result := Elenco[0].Titolo + sLineBreak + Elenco[0].Testo;
end;

// ----- risposta --------------------------------------------------------------------

procedure ScriviNelPrimoCampo(const Dialogo: TDialogo; const Testo: string);
var
  Figlia: HWND;
  Indice: Integer;
  Componente: TComponent;
  Contesto: TRttiContext;
  Proprieta: TRttiProperty;
begin
  if Dialogo.Nativo then
  begin
    for Figlia in FinestreFiglie(Dialogo.Finestra) do
      if SameText(ClasseFinestra(Figlia), 'Edit') and IsWindowVisible(Figlia) then
      begin
        SendMessage(Figlia, WM_SETTEXT, 0, LPARAM(PChar(Testo)));
        Exit;
      end;
    raise ESonda.Create('Il dialogo non ha campi in cui scrivere.');
  end;
  // Il campo col fuoco e' quello che l'utente userebbe: nel dialogo di salvataggio
  // DevExpress il primo "Edit" in ordine di creazione e' la ricerca, mentre "Nome file"
  // e' il controllo attivo. Solo se non c'e' un campo attivo scrivibile si ricade
  // sul primo campo trovato.
  if (Dialogo.Form.ActiveControl <> nil) and Dialogo.Form.ActiveControl.Visible and
    Dialogo.Form.ActiveControl.Enabled and
    ((Dialogo.Form.ActiveControl is TCustomEdit) or ContainsText(Dialogo.Form.ActiveControl.ClassName, 'Edit') or
    ContainsText(Dialogo.Form.ActiveControl.ClassName, 'ComboBox')) then
  begin
    Proprieta := Contesto.GetType(Dialogo.Form.ActiveControl.ClassType).GetProperty('Text');
    if (Proprieta <> nil) and Proprieta.IsWritable then
    begin
      Proprieta.SetValue(Dialogo.Form.ActiveControl, Testo);
      Exit;
    end;
  end;
  for Indice := 0 to Dialogo.Form.ComponentCount - 1 do
  begin
    Componente := Dialogo.Form.Components[Indice];
    if (Componente is TWinControl) and TWinControl(Componente).Visible and TWinControl(Componente).Enabled and
      ((Componente is TCustomEdit) or ContainsText(Componente.ClassName, 'Edit')) then
    begin
      Proprieta := Contesto.GetType(Componente.ClassType).GetProperty('Text');
      if (Proprieta <> nil) and Proprieta.IsWritable then
      begin
        Proprieta.SetValue(Componente, Testo);
        Exit;
      end;
    end;
  end;
  raise ESonda.Create('Il dialogo non ha campi in cui scrivere.');
end;

procedure PremiPulsanteVcl(const Dialogo: TDialogo; const Pulsante: TPulsanteDialogo);
var
  Controllo: TControl;
  Centro: TPoint;
begin
  // un pulsante con ModalResult chiude il dialogo come farebbe il clic; i
  // pulsanti senza (es. "Dettagli") si premono col mouse simulato, cosi'
  // gira anche il loro OnClick
  if Pulsante.ModalResult <> mrNone then
  begin
    Dialogo.Form.ModalResult := Pulsante.ModalResult;
    Exit;
  end;
  if not (Pulsante.Componente is TWinControl) then
    raise ESonda.CreateFmt('Il pulsante "%s" non ha un ModalResult e non si puo'' premere.', [Pulsante.Testo]);
  // sempre messaggi accodati, mai Click diretto: l'OnClick puo' aprire un
  // altro dialogo modale, e la sonda resterebbe ferma dentro la risposta
  if Pulsante.Componente is TButton then
  begin
    PostMessage(TButton(Pulsante.Componente).Handle, BM_CLICK, 0, 0);
    Exit;
  end;
  Controllo := TControl(Pulsante.Componente);
  Centro := Point(Controllo.Width div 2, Controllo.Height div 2);
  PostMessage(TWinControl(Controllo).Handle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(Centro.X, Centro.Y));
  PostMessage(TWinControl(Controllo).Handle, WM_LBUTTONUP, 0, MakeLParam(Centro.X, Centro.Y));
end;

function RispondiDialogo(const Pulsante, Testo: string; Finestra: HWND): string;
var
  Elenco: TArray<TDialogo>;
  Dialogo: TDialogo;
  Candidato: TPulsanteDialogo;
  Trovato: Boolean;
  Atteso: Integer;
  Disponibili: string;
begin
  Elenco := Dialoghi;
  if Length(Elenco) = 0 then
    raise ESonda.Create('Nessun dialogo aperto.');
  Dialogo := Elenco[0];
  if Finestra <> 0 then
  begin
    Trovato := False;
    for Dialogo in Elenco do
      if Dialogo.Finestra = Finestra then
      begin
        Trovato := True;
        Break;
      end;
    if not Trovato then
      raise ESonda.CreateFmt('Il dialogo %d non e'' piu'' aperto.', [Finestra]);
  end;

  if Testo <> '' then
    ScriviNelPrimoCampo(Dialogo, Testo);

  Atteso := RisultatoDaNome(Pulsante);
  for Candidato in Dialogo.Pulsanti do
    if SameText(Candidato.Testo, StripHotkey(Pulsante).Trim) or
      ((Atteso <> 0) and (Candidato.Risultato = Atteso)) then
    begin
      if Dialogo.Nativo then
        PostMessage(Candidato.Finestra, BM_CLICK, 0, 0)
      else
        PremiPulsanteVcl(Dialogo, Candidato);
      Exit(Format('premuto "%s" in "%s"', [Candidato.Testo, Dialogo.Titolo]));
    end;

  // TaskDialog: i pulsanti non si vedono, ma si premono per identificativo
  if Dialogo.TaskDialog and (Atteso <> 0) then
  begin
    PostMessage(Dialogo.Finestra, TDM_CLICK_BUTTON, Atteso, 0);
    Exit(Format('premuto "%s" nel TaskDialog "%s"', [NomeRisultato(Atteso), Dialogo.Titolo]));
  end;

  Disponibili := '';
  for Candidato in Dialogo.Pulsanti do
    Disponibili := Disponibili + IfThen(Disponibili <> '', ', ') + Candidato.Testo;
  raise ESonda.CreateFmt('Nel dialogo "%s" non c''e'' il pulsante "%s". Pulsanti: %s',
    [Dialogo.Titolo, Pulsante, Disponibili]);
end;

end.
