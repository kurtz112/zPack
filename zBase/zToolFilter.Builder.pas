// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-09-20
// ---------------------------------------------------------------------------
unit zToolFilter.Builder;

{
  TzToolFilterBuilder — unico orchestratore della costruzione dei filtri
  toolbar a partire da una TzToolFiltersProps.

  PERCHE' ESISTE
  Prima, ogni componente filtrabile riscriveva la stessa procedura:

    TzDbView.CreateFiltersFromProps  + TzDbView.ApplyFilterProps
    TzDbPivot.CreateFiltersFromProps + TzDbPivot.ApplyFilterProps
    TzDbCard.CreateFiltersFromProps

  Tre copie divergenti dello stesso algoritmo:
  - View e Pivot deduplicavano, Card no;
  - View e Pivot registravano un avviso per la classe non registrata,
    Card lasciava salire l'eccezione e bloccava il caricamento della form;
  - View e Pivot iteravano DUE volte la stessa collezione (GetDbViewProps.ToolFilters
    e ToolFilters sono lo stesso oggetto: GetToolFilters restituisce il primo),
    con un dizionario di deduplicazione che serviva solo a neutralizzare
    il secondo giro;
  - nessuna delle tre gestiva le istanze multiple della stessa classe.

  Ora la logica sta qui e i tre componenti fanno una sola chiamata. Qualunque
  nuovo componente che implementi IzBaseFilterableComponent la riusa senza
  ricopiare nulla.

  COSA FA
  1. ripulisce dalla toolbar i controlli creati da una costruzione precedente
     (prefisso ToolFilterPrefix) — idempotente;
  2. sospende le riaperture del dataset mentre imposta i valori iniziali;
  3. per ogni elemento: salta gli invisibili, risolve la CLASSE
     (EffectiveFilterName), scarta i duplicati di ISTANZA (Name), avvisa e
     prosegue se la classe non e' registrata, applica;
  4. riapre il dataset una volta sola, alla fine, se ha applicato qualcosa.

  Non conosce ne' TzDbView ne' TzDbCard ne' TzDbPivot: riceve la collezione,
  il componente (che i filtri concreti usano via IzBaseComponent.GetToolbar),
  il TdxBarManager e il dataset.

  ---------------------------------------------------------------------------
  16.09.2026 — LE USCITE SILENZIOSE

  Fino a ieri questa procedura poteva non applicare niente senza lasciare
  traccia, e succedeva in tre punti:

    1. BarManager non assegnato          -> Exit muto
    2. Filters non assegnata o vuota     -> Exit muto
    3. Filter.Apply che esce subito      -> invisibile da qui

  Il terzo e' il piu' insidioso. Ogni filtro concreto comincia con:

      bar := GetToolbar(Component);
      if not Assigned(bar) then Exit;
      if TzDxBarHelper.ItemExists(bar, NomeItem) then Exit;

  cioe' se il componente non espone una dxBar, oppure se il controllo esiste
  gia', il filtro non fa nulla e non lo dice a nessuno. Il chiamante conta
  l'applicazione come riuscita, la funzione restituisce un numero maggiore di
  zero, e chi guarda vede una griglia senza filtri e nessun errore da nessuna
  parte.

  Diagnosticarlo dall'esterno era impossibile: la configurazione LZ e' giusta,
  le classi sono registrate, il log tace. Si finisce a leggere il sorgente di
  zPack per esclusione, ed e' esattamente quello che non deve servire.

  La correzione non cambia il comportamento: cambia quello che si sa del
  comportamento.

  - i due Exit muti ora scrivono il motivo;
  - dopo ogni Apply si contano i controlli con il prefisso sulla barra: se
    non sono aumentati, il filtro non ha creato niente e lo si segnala con
    le due cause possibili;
  - il conteggio restituito e' quello dei filtri che hanno prodotto un
    controllo davvero, non quello delle chiamate ad Apply andate a buon fine;
  - quando il totale applicato non coincide con quello configurato, una riga
    di riepilogo lo dice.

  Quando tutto funziona il log resta muto: un canale di avvisi che parla
  anche quando va bene smette di essere letto.
}

interface

uses
  System.SysUtils,
  System.Classes,
  dxBar,
  zFbDataSet,
  zSystem;

type
  TzToolFilterBuilder = class
  private
    /// <summary>
    /// Quanti controlli con il prefisso ToolFilterPrefix ci sono adesso sulla
    /// barra. Serve a capire se un Apply ha prodotto qualcosa: e' l'unico
    /// modo, perche' i filtri concreti non restituiscono niente.
    /// </summary>
    class function ContaControlliFiltro(BarManager: TdxBarManager): Integer; static;
  public
    /// <summary>
    /// Ricostruisce sulla toolbar tutti i filtri di Filters.
    /// Restituisce il numero di filtri che hanno effettivamente creato un
    /// controllo sulla barra.
    /// </summary>
    /// <param name="Filters">collezione persistita del componente (puo' essere nil o vuota)</param>
    /// <param name="Component">il componente filtrabile: i filtri concreti ne ricavano la dxBar</param>
    /// <param name="BarManager">bar manager da ripulire dai controlli della costruzione precedente</param>
    /// <param name="DataSet">dataset a cui agganciare i filtri (Tag del TcxBarEditItem)</param>
    /// <param name="LogWarning">callback per le segnalazioni non bloccanti; nil = silenzioso</param>
    /// <param name="ReopenDataSet">False per rimandare la riapertura al chiamante</param>
    class function Build(Filters: TzToolFiltersProps; Component: TComponent; BarManager: TdxBarManager; DataSet: TzFbDataSet; const LogWarning: TProc<string> = nil;
      const ReopenDataSet: Boolean = True): Integer; static;
  end;

implementation

uses
  System.Variants,
  Data.DB,
  System.StrUtils,
  System.Generics.Collections,
  zParamsHelper,
  zToolFilter,
  zToolFilterHelper;

class function TzToolFilterBuilder.ContaControlliFiltro(BarManager: TdxBarManager): Integer;
var
  i: Integer;
begin
  Result := 0;

  if not Assigned(BarManager) then
    Exit;

  for i := 0 to BarManager.ItemCount - 1 do
    if StartsText(ToolFilterPrefix, BarManager.Items[i].Name) then
      Inc(Result);
end;

class function TzToolFilterBuilder.Build(Filters: TzToolFiltersProps; Component: TComponent; BarManager: TdxBarManager; DataSet: TzFbDataSet; const LogWarning: TProc<string>;
  const ReopenDataSet: Boolean): Integer;
var
  Props: TzToolFilterProps;
  Applicate: TDictionary<string, Boolean>;
  Chiave: string;
  NomeClasse: string;
  Filter: TzToolFilter;
  Configurati: Integer;
  PrimaDiApply: Integer;
  ValoriPrima: TParams;
  ParametriCambiati: Boolean;

  procedure Avvisa(const Testo: string);
  begin
    if Assigned(LogWarning) then
      LogWarning(Testo);
  end;

  // Il nome del componente nei messaggi: senza, un avviso in un log pieno di
  // griglie non dice su quale griglia sia successo.
  function Chi: string;
  begin
    if Assigned(Component) and (Component.Name <> '') then
      Result := Component.Name
    else if Assigned(Component) then
      Result := Component.ClassName
    else
      Result := '(componente non assegnato)';
  end;

  // True se almeno un parametro del dataset ha un valore diverso da quello
  // fotografato prima di applicare i filtri. Nullo contro nullo e' uguale.
  // Se il confronto fra tipi diversi fallisce si considera cambiato, cioe'
  // si riapre: e' il comportamento precedente, mai piu' pericoloso di esso.
  function ValoriDiversi: Boolean;
  var
    i: Integer;
    Precedente: TParam;
  begin
    Result := True;
    if not Assigned(DataSet) or not Assigned(ValoriPrima) then
      Exit;

    for i := 0 to DataSet.ParamCount - 1 do
    begin
      Precedente := ValoriPrima.FindParam(DataSet.Params[i].Name);
      if not Assigned(Precedente) then
        Exit;
      if Precedente.IsNull <> DataSet.Params[i].IsNull then
        Exit;
      if not DataSet.Params[i].IsNull then
        try
          if VarCompareValue(Precedente.Value, DataSet.Params[i].Value) <> vrEqual then
            Exit;
        except
          Exit;
        end;
    end;

    Result := False;
  end;

begin
  Result := 0;
  Configurati := 0;
  ParametriCambiati := True;

  if not Assigned(BarManager) then
  begin
    // Non e' un caso teorico: succede quando il componente viene costruito
    // prima che la sua barra esista. I filtri configurati restano a terra e
    // fino a ieri nessuno lo diceva.
    if Assigned(Filters) and (Filters.Count > 0) then
      Avvisa(Format('%s: nessun bar manager, i %d filtri configurati non sono stati applicati', [Chi, Filters.Count]));
    Exit;
  end;

  // Pulizia dei controlli bar della costruzione precedente. Va fatta anche
  // quando non c'e' nulla da applicare, altrimenti restano appesi i filtri
  // di una configurazione appena svuotata.
  TzToolFilterHelper.ClearFilterItems(BarManager);

  if not Assigned(Filters) then
  begin
    Avvisa(Format('%s: collezione dei filtri non assegnata', [Chi]));
    Exit;
  end;

  if Filters.Count = 0 then
    // Nessun filtro configurato e' la norma, non un problema: si tace.
    Exit;

  Applicate := TDictionary<string, Boolean>.Create;

  // Fotografia dei parametri prima dei filtri: la riapertura finale avviene
  // solo se i filtri hanno cambiato davvero qualcosa. Senza questo controllo
  // ogni ricostruzione della barra (LoadProperties(False), cambio di una
  // spunta, personalizzazione) costava una lettura dal server.
  ValoriPrima := TParams.Create(nil);
  if Assigned(DataSet) then
    DataSet.GetParamValues(ValoriPrima);

  TzToolFilterHelper.DisableReopen := True;
  try
    for Props in Filters do
    begin
      if not Props.Visible then
        Continue;

      Inc(Configurati);

      // CLASSE registrata: FilterName, con ricaduta su Name per le
      // configurazioni LZ scritte prima dello sdoppiamento dell'identita'.
      NomeClasse := Props.EffectiveFilterName;

      if NomeClasse.IsEmpty then
      begin
        Avvisa(Format('%s: filtro senza classe (FilterName e Name vuoti), ignorato', [Chi]));
        Continue;
      end;

      // ISTANZA: e' Name a dover essere univoco, non la classe. E' questo che
      // permette due filtri della stessa classe sullo stesso componente.
      //
      // Quando Name coincide con la classe (configurazioni LZ precedenti, in
      // cui piu' elementi 'PickList' o 'Boolean' potevano convivere distinti
      // solo dal campo) la chiave di deduplicazione include anche pick list e
      // campo, per non scartare come "duplicato" un filtro legittimo.
      Chiave := LowerCase(Props.Name);

      if Chiave.IsEmpty or SameText(Props.Name, NomeClasse) then
        Chiave := LowerCase(NomeClasse + '|' + Props.EffectivePickListName + '|' + Props.EffectiveFieldName);

      if Applicate.ContainsKey(Chiave) then
      begin
        Avvisa(Format('%s: istanza duplicata "%s", ignorata', [Chi, Props.Name]));
        Continue;
      end;

      if not TzToolFilterRegistry.IsRegistered(NomeClasse) then
      begin
        Avvisa(Format('%s: classe di filtro "%s" (istanza "%s") non registrata. ' + 'Verificare che la unit *_Filters sia inclusa nel progetto.', [Chi, NomeClasse, Props.Name]));
        Continue;
      end;

      // Un filtro mal configurato non deve impedire il caricamento del
      // componente: si segnala e si prosegue con gli altri.
      try
        Filter := TzToolFilterRegistry.Resolve(Props);
        try
          PrimaDiApply := ContaControlliFiltro(BarManager);

          Filter.Apply(Component, DataSet);

          if ContaControlliFiltro(BarManager) > PrimaDiApply then
          begin
            Applicate.AddOrSetValue(Chiave, True);
            Inc(Result);
          end
          else
            // Apply e' uscito senza creare niente. Le cause sono due e sono
            // entrambe mute nel codice dei filtri concreti: il componente non
            // espone una dxBar, oppure il controllo esiste gia' sulla barra.
            // Distinguerle da qui non si puo'; nominarle entrambe si'.
            //
            // Il conteggio dei controlli gia' presenti restringe il campo
            // senza aprire il debugger: zero significa che sulla barra non e'
            // mai arrivato niente - e allora si guarda GetToolbar; maggiore di
            // zero significa che la barra c'e' e funziona, e allora e' una
            // collisione di nome fra istanze della stessa classe.
            Avvisa(Format('%s: il filtro "%s" (%s) non ha creato nessun controllo ' +
              '(controlli filtro gia'' sulla barra: %d). ' + 'Il componente non espone una dxBar (GetToolbar nullo) oppure il controllo era gia'' presente.',
              [Chi, Props.Name, NomeClasse, PrimaDiApply]));
        finally
          Filter.Free;
        end;
      except
        on E: Exception do
          Avvisa(Format('%s: filtro "%s" (%s): %s', [Chi, Props.Name, NomeClasse, E.Message]));
      end;
    end;
  finally
    TzToolFilterHelper.DisableReopen := False;
    Applicate.Free;
    // I filtri hanno gia' scritto i parametri: il confronto va fatto qui,
    // prima di liberare la fotografia.
    ParametriCambiati := ValoriDiversi;
    FreeAndNil(ValoriPrima);
  end;

  // Riepilogo solo quando qualcosa non ha funzionato: un canale di avvisi che
  // parla anche quando va tutto bene smette di essere letto.
  if Result < Configurati then
    Avvisa(Format('%s: applicati %d filtri su %d configurati', [Chi, Result, Configurati]));

  // Una sola riapertura alla fine, non una per filtro, e solo se i filtri
  // hanno cambiato almeno un parametro.
  if ReopenDataSet and (Result > 0) and Assigned(DataSet) and DataSet.Active then
    if ParametriCambiati then
      // Mantis #141 - 2026-09-20: ogni Apply e' protetto e registra un avviso,
      // ma questa riapertura era nuda: qualunque errore usciva di qui come
      // eccezione della RTL, senza dire quale dataset stesse aprendo ne' con
      // quali parametri. E' la ragione per cui il ticket 141 e' stato un
      // rompicapo: il messaggio era la sola conversione fallita di un variante.
      try
        DataSet.Reopen(False);
      except
        on E: Exception do
          raise Exception.CreateFmt('%s: riapertura del dataset "%s" dopo i filtri fallita.' + sLineBreak + sLineBreak + '%s' + sLineBreak + sLineBreak +
            'Parametri al momento dell''apertura:' + sLineBreak + '%s', [Chi, DataSet.Name, E.Message, TzParamValue.Descrivi(DataSet.Params)]);
      end;
end;

end.
