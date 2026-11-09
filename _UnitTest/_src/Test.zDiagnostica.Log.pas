// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-02
// ---------------------------------------------------------------------------
unit Test.zDiagnostica.Log;

// Test DUnitX di zBase\zDiagnostica.Log.pas: sessione di registrazione per
// l'assistenza (specifica ZBASE-LOG, "Registro diagnostico.md").
//
// Ogni prova crea una istanza propria di TzSessioneLog (non il singleton
// SessioneLog) con una cartella temporanea come cartella dei log, e sostituisce
// le finestre con le funzioni di aggancio dell'applicazione (OnMessaggio,
// OnChiediConferma, OnChiediOpzioni, OnChiediNota): nessun dialogo, nessuna
// rete. NON si avvia mai la registrazione vera (Avvia con opzioni confermate,
// AvviaAllAvvio con una richiesta presente): tocca SmartInspect globale, Screen
// e il timer, e si puo' provare solo nel programma intero (collaudo).
//
// I parametri Mantis sono lo stato globale TzExceptionManager.MantisServerParams:
// Setup li salva e li sostituisce con valori di prova, TearDown li ripristina.
//
// La prova della divergenza DIV-LOG-4 presuppone che TDirectory.GetFiles
// elenchi i file in ordine alfabetico, come fa NTFS.

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  DUnitX.TestFramework,
  zExceptions,
  zExceptions.Utils,
  zExceptions.Mantis,
  zDiagnostica.Log,
  zDiagnostica.Log.Perf;

type
  [TestFixture]
  TTestRegistroDiagnostico = class
  private
    FCartella: string;
    FSessione: TzSessioneLog;
    FMantisSalvati: TMantisServerParams;
    FMessaggi: TStringList;
    FConferme: TStringList;
    FRispostaConferma: Boolean;
    FRichiesteOpzioni: Integer;
    FOpzioniRicevute: TzOpzioniRegistrazione;
    FMonitorRicevuto: Boolean;
    FStatiCambiati: Integer;
    procedure StatoCambiato(Sender: TObject);
    function NomePostazione: string;
    function FileRichiesta(const Postazione: string): string;
    function PercorsoMarcatore(const NomeSessione: string): string;
    procedure ScriviRichiesta(const Postazione: string);
    procedure ScriviMarcatore(const NomeSessione, Postazione, FileLog, FileSil: string);
    function NumeroFileInCartella: Integer;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZBASE-LOG-003
    [Test]
    procedure Creazione_IstanzaNuova_ValoriPredefiniti;
    // ZBASE-LOG-002
    [Test]
    procedure Disponibile_SegueValiditaDeiParametriMantis;
    // ZBASE-LOG-002
    [Test]
    procedure Avvia_SenzaParametriMantis_FalsoSenzaFinestreNeFile;
    // ZBASE-LOG-003
    [Test]
    procedure Avvia_DalMenu_ProponeLeOpzioniDellaProceduraGuidata;
    // ZBASE-LOG-003
    [Test]
    procedure Avvia_DalMenuConMonitorAgganciato_LoSegnalaDisponibile;
    // ZBASE-LOG-003
    [Test]
    procedure Avvia_OpzioniAnnullate_FalsoENienteFile;
    // ZBASE-LOG-003
    [Test]
    procedure Avvia_PrenotazionePresenteConfermata_AnnullaSenzaMostrareLeOpzioni;
    // ZBASE-LOG-003
    [Test]
    procedure Avvia_PrenotazionePresenteNonAnnullata_ProseguiConLeOpzioni;
    // ZBASE-LOG-001, ZBASE-LOG-007
    [Test]
    procedure StatoARiposo_NessunaRegistrazione_ValoriNulli;
    // ZBASE-LOG-001
    [Test]
    procedure TerminaESegnala_SenzaRegistrazione_FalsoSenzaEffetti;
    // ZBASE-LOG-006
    [Test]
    procedure InserisciSegnalibro_SenzaRegistrazione_AvvisaConLaScorciatoia;
    // ZBASE-LOG-017
    [Test]
    procedure Messaggio_ConOnMessaggio_NessunaFinestraPropria;
    // ZBASE-LOG-011
    [Test]
    procedure RichiestaAvvioPresente_SoloFileDellaPostazione;
    // ZBASE-LOG-011
    [Test]
    procedure DidascaliaVoceAvvio_SegueLaRichiesta;
    // ZBASE-LOG-001
    [Test]
    procedure DidascaliaVoceMenu_ARiposo_CitaLaScorciatoia;
    // ZBASE-LOG-011
    [Test]
    procedure CommutaRichiestaAvvio_ConConferma_ScriveLaRichiesta;
    // ZBASE-LOG-011
    [Test]
    procedure CommutaRichiestaAvvio_ConfermaNegata_NienteFile;
    // ZBASE-LOG-011
    [Test]
    procedure CommutaRichiestaAvvio_RichiestaPresente_LaAnnullaSenzaChiedere;
    // ZBASE-LOG-011
    [Test]
    procedure CommutaRichiestaAvvio_SenzaParametriMantis_NonScrive;
    // ZBASE-LOG-011
    [Test]
    procedure CommutaRichiestaAvvio_SenzaParametriMantis_AnnullaComunque;
    // ZBASE-LOG-011
    [Test]
    procedure AvviaAllAvvio_SenzaRichiesta_FalsoENienteFile;
    // ZBASE-LOG-011
    [Test]
    procedure AvviaAllAvvio_RichiestaDiUnAltroComputer_NonLaConsuma;
    // ZBASE-LOG-012
    [Test]
    procedure VerificaSessioneInterrotta_MarcatoreDiAltraPostazione_Resta;
    // ZBASE-LOG-012
    [Test]
    procedure VerificaSessioneInterrotta_FileSpariti_EliminaIlMarcatoreSenzaDomande;
    // ZBASE-LOG-012
    [Test]
    procedure VerificaSessioneInterrotta_UtenteRifiuta_EliminaMarcatoreEConservaIFile;
    // ZBASE-LOG-012
    [Test]
    procedure VerificaSessioneInterrotta_SenzaParametriMantis_LasciaIMarcatori;
    // DIV-LOG-4: corretta, un marcatore illeggibile non ferma la scansione
    // ZBASE-LOG-012
    [Test]
    procedure Divergenza_DIV_LOG_4_MarcatoreIllegibile_NonInterrompeLaScansione;
  end;

implementation

// Stessa regola di PerNomeFile in zDiagnostica.Log (privata): caratteri
// ammessi a-z A-Z 0-9 - _ . ; ogni altro diventa _ ; vuoto = sconosciuto.
function PerNomeFileAtteso(const Testo: string): string;
var
  Carattere: Char;
begin
  Result := '';
  for Carattere in Testo.Trim do
    if CharInSet(Carattere, ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.']) then
      Result := Result + Carattere
    else
      Result := Result + '_';
  if Result = '' then
    Result := 'sconosciuto';
end;

{ TTestRegistroDiagnostico }

procedure TTestRegistroDiagnostico.Setup;
begin
  FMantisSalvati := TzExceptionManager.MantisServerParams;
  TzExceptionManager.MantisServerParams.Init('http://mantis.prova.invalid/', 'chiave-di-prova', 'LOG', 1000);

  FCartella := TPath.Combine(TPath.GetTempPath, 'zDiagnosticaLog-' + TGUID.NewGuid.ToString.Substring(1, 36));
  ForceDirectories(FCartella);

  FMessaggi := TStringList.Create;
  FConferme := TStringList.Create;
  FRispostaConferma := True;
  FRichiesteOpzioni := 0;
  FMonitorRicevuto := False;
  FStatiCambiati := 0;

  FSessione := TzSessioneLog.Create;
  FSessione.CartellaLog := FCartella;
  FSessione.OnStatoCambiato := StatoCambiato;
  FSessione.OnMessaggio := procedure(const ATitolo, ATesto: string; ATipo: TzTipoMessaggio)
    begin
      FMessaggi.Add(ATitolo + '|' + ATesto);
    end;
  FSessione.OnChiediConferma := function(const ATesto: string): Boolean
    begin
      FConferme.Add(ATesto);
      Result := FRispostaConferma;
    end;
  FSessione.OnChiediNota := function(out ANota: string): Boolean
    begin
      ANota := '';
      Result := False;
    end;
  FSessione.OnChiediOpzioni := function(var AOpzioni: TzOpzioniRegistrazione; AMonitorDisponibile: Boolean): Boolean
    begin
      Inc(FRichiesteOpzioni);
      FOpzioniRicevute := AOpzioni;
      FMonitorRicevuto := AMonitorDisponibile;
      // l'utente annulla la procedura: nessuna registrazione parte
      Result := False;
    end;
end;

procedure TTestRegistroDiagnostico.TearDown;
begin
  FreeAndNil(FSessione);
  TzExceptionManager.MantisServerParams := FMantisSalvati;
  FreeAndNil(FMessaggi);
  FreeAndNil(FConferme);
  try
    TDirectory.Delete(FCartella, True);
  except
    // cartella temporanea: se resta qualcosa lo toglie il sistema
  end;
end;

procedure TTestRegistroDiagnostico.StatoCambiato(Sender: TObject);
begin
  Inc(FStatiCambiati);
end;

function TTestRegistroDiagnostico.NomePostazione: string;
begin
  Result := PerNomeFileAtteso(SysUserName) + '-' + PerNomeFileAtteso(ComputerName);
end;

function TTestRegistroDiagnostico.FileRichiesta(const Postazione: string): string;
begin
  Result := TPath.Combine(FCartella, 'LOG-avvio-' + Postazione + '.richiesta');
end;

function TTestRegistroDiagnostico.PercorsoMarcatore(const NomeSessione: string): string;
begin
  Result := TPath.Combine(FCartella, NomeSessione + '.inCorso');
end;

procedure TTestRegistroDiagnostico.ScriviRichiesta(const Postazione: string);
begin
  TFile.WriteAllText(FileRichiesta(Postazione), 'richiesta=2026-11-01 10:00:00' + sLineBreak + 'postazione=' + Postazione,
    TEncoding.UTF8);
end;

procedure TTestRegistroDiagnostico.ScriviMarcatore(const NomeSessione, Postazione, FileLog, FileSil: string);
var
  Contenuto: TStringList;
begin
  Contenuto := TStringList.Create;
  try
    Contenuto.AddPair('sessione', NomeSessione);
    Contenuto.AddPair('postazione', Postazione);
    Contenuto.AddPair('inizio', '2026-11-01 10:00:00');
    Contenuto.AddPair('log', FileLog);
    Contenuto.AddPair('sil', FileSil);
    Contenuto.AddPair('csv', '');
    Contenuto.AddPair('monitor', '');
    Contenuto.SaveToFile(PercorsoMarcatore(NomeSessione), TEncoding.UTF8);
  finally
    FreeAndNil(Contenuto);
  end;
end;

function TTestRegistroDiagnostico.NumeroFileInCartella: Integer;
begin
  Result := Length(TDirectory.GetFiles(FCartella));
end;

procedure TTestRegistroDiagnostico.Creazione_IstanzaNuova_ValoriPredefiniti;
var
  Nuova: TzSessioneLog;
begin
  Nuova := TzSessioneLog.Create;
  try
    Assert.AreEqual('LOG', Nuova.CategoriaMantis);
    Assert.AreEqual(300, Nuova.SogliaOperazioneLentaMs);
    Assert.AreEqual(1500, Nuova.SogliaBloccoMs);
    Assert.AreEqual(15, Nuova.IntervalloCampionamentoSecondi);
    Assert.AreEqual(120, Nuova.DurataMassimaMinuti);
    Assert.AreEqual(40, Nuova.DimensioneMassimaMb);
    Assert.IsFalse(Nuova.RegistraValoriParametri, 'i valori dei parametri (dati personali) non si registrano di norma');
    Assert.AreEqual(30, Nuova.GiorniConservazione);
    Assert.AreEqual('Ctrl+Shift+L', Nuova.TestoScorciatoia);
    Assert.IsFalse(Nuova.VideoDisponibile);
    Assert.AreEqual(15, Nuova.DurataMassimaVideoMinuti);
    Assert.AreEqual(20, Nuova.DimensioneMassimaVideoMb);
    Assert.IsFalse(Nuova.ProssimoAvvioNellaProcedura);
    Assert.AreEqual('', Nuova.CartellaLog);
    Assert.IsFalse(Nuova.Attiva);
  finally
    FreeAndNil(Nuova);
  end;
end;

procedure TTestRegistroDiagnostico.Disponibile_SegueValiditaDeiParametriMantis;
begin
  Assert.IsTrue(FSessione.Disponibile, 'indirizzo e chiave presenti');

  TzExceptionManager.MantisServerParams.Init('http://mantis.prova.invalid/', '', 'LOG', 1000);
  Assert.IsFalse(FSessione.Disponibile, 'chiave vuota');

  TzExceptionManager.MantisServerParams.Init('', 'chiave-di-prova', 'LOG', 1000);
  Assert.IsFalse(FSessione.Disponibile, 'indirizzo vuoto');

  TzExceptionManager.MantisServerParams.Init('', '', 'LOG', 1000);
  Assert.IsFalse(FSessione.Disponibile, 'nessun parametro');
end;

procedure TTestRegistroDiagnostico.Avvia_SenzaParametriMantis_FalsoSenzaFinestreNeFile;
begin
  TzExceptionManager.MantisServerParams.Init('', '', 'LOG', 1000);

  Assert.IsFalse(FSessione.Avvia(ocMenu));

  Assert.IsFalse(FSessione.Attiva);
  Assert.AreEqual(0, FRichiesteOpzioni, 'la procedura guidata non deve comparire');
  Assert.AreEqual(0, FMessaggi.Count, 'esce in silenzio');
  Assert.AreEqual(0, NumeroFileInCartella);
end;

procedure TTestRegistroDiagnostico.Avvia_DalMenu_ProponeLeOpzioniDellaProceduraGuidata;
begin
  Assert.IsFalse(FSessione.Avvia(ocMenu), 'l''utente annulla la procedura');

  Assert.AreEqual(1, FRichiesteOpzioni);
  Assert.IsTrue(FOpzioniRicevute.TempiFetch);
  Assert.IsTrue(FOpzioniRicevute.TempiGriglia);
  Assert.IsFalse(FOpzioniRicevute.MonitorFireDAC, 'il monitor FireDAC riapre la connessione: parte spento');
  Assert.IsTrue(FOpzioniRicevute.ChiediCommento);
  Assert.IsTrue(FOpzioniRicevute.InviaAllaFine);
  Assert.IsFalse(FOpzioniRicevute.Video);
  Assert.AreEqual('', FOpzioniRicevute.Nota);
end;

procedure TTestRegistroDiagnostico.Avvia_DalMenuConMonitorAgganciato_LoSegnalaDisponibile;
begin
  FSessione.OnMonitorFireDAC := procedure(AAttiva: Boolean; const AFile: string)
    begin
    end;

  FSessione.Avvia(ocMenu);

  Assert.AreEqual(1, FRichiesteOpzioni);
  Assert.IsTrue(FMonitorRicevuto);
end;

procedure TTestRegistroDiagnostico.Avvia_OpzioniAnnullate_FalsoENienteFile;
begin
  Assert.IsFalse(FSessione.Avvia(ocMenu));

  Assert.IsFalse(FSessione.Attiva);
  Assert.AreEqual('', FSessione.FileSil, 'nessun file assegnato');
  Assert.AreEqual(0, NumeroFileInCartella);
  Assert.AreEqual(0, FMessaggi.Count);
end;

procedure TTestRegistroDiagnostico.Avvia_PrenotazionePresenteConfermata_AnnullaSenzaMostrareLeOpzioni;
begin
  FSessione.ProssimoAvvioNellaProcedura := True;
  ScriviRichiesta(NomePostazione);
  FRispostaConferma := True;

  Assert.IsFalse(FSessione.Avvia(ocMenu));

  Assert.AreEqual(1, FConferme.Count);
  Assert.IsTrue(FConferme[0].Contains('prenotata'), 'la domanda parla della prenotazione');
  Assert.IsFalse(TFile.Exists(FileRichiesta(NomePostazione)), 'la richiesta e'' stata cancellata');
  Assert.AreEqual(0, FRichiesteOpzioni, 'le opzioni non si mostrano');
  Assert.AreEqual(1, FMessaggi.Count);
  Assert.IsTrue(FMessaggi[0].StartsWith('Prenotazione annullata|'), FMessaggi[0]);
end;

procedure TTestRegistroDiagnostico.Avvia_PrenotazionePresenteNonAnnullata_ProseguiConLeOpzioni;
begin
  FSessione.ProssimoAvvioNellaProcedura := True;
  ScriviRichiesta(NomePostazione);
  FRispostaConferma := False;

  FSessione.Avvia(ocMenu);

  Assert.AreEqual(1, FConferme.Count);
  Assert.IsTrue(TFile.Exists(FileRichiesta(NomePostazione)), 'la prenotazione resta');
  Assert.AreEqual(1, FRichiesteOpzioni, 'si prosegue con la procedura di registrazione');
end;

procedure TTestRegistroDiagnostico.StatoARiposo_NessunaRegistrazione_ValoriNulli;
var
  Residuo: TzTempoResiduo;
begin
  Assert.IsFalse(FSessione.Attiva);
  Assert.IsFalse(FSessione.AvviataAllAvvio);
  Assert.AreEqual('', FSessione.Identificativo);
  Assert.AreEqual(0, FSessione.DurataSecondi);
  Assert.IsFalse(FSessione.LimiteImminente);
  Assert.IsFalse(FSessione.VideoAttivo);
  Assert.IsFalse(FSessione.PausaVideo);
  Assert.IsFalse(FSessione.InvioInCorso);
  Assert.AreEqual('', FSessione.TestoInvio);

  Residuo := FSessione.TempoResiduo;
  Assert.AreEqual(-1, Residuo.Secondi);
  Assert.AreEqual(0, Residuo.Totale);
  Assert.AreEqual('', Residuo.Motivo);

  // non fanno niente e non sollevano
  FSessione.InterrompiInvio;
  FSessione.PausaVideo := True;
  Assert.IsFalse(FSessione.PausaVideo, 'senza filmato la pausa non si accende');
end;

procedure TTestRegistroDiagnostico.TerminaESegnala_SenzaRegistrazione_FalsoSenzaEffetti;
begin
  Assert.IsFalse(FSessione.TerminaESegnala(ocMenu));
  Assert.AreEqual(0, FMessaggi.Count);
  Assert.AreEqual(0, FConferme.Count);
  Assert.AreEqual(0, NumeroFileInCartella);
end;

procedure TTestRegistroDiagnostico.InserisciSegnalibro_SenzaRegistrazione_AvvisaConLaScorciatoia;
begin
  FSessione.TestoScorciatoia := 'Ctrl+Alt+Q';

  FSessione.InserisciSegnalibro('qui e'' lento', ocScorciatoia);

  Assert.AreEqual(1, FMessaggi.Count);
  Assert.IsTrue(FMessaggi[0].StartsWith('Nessuna registrazione in corso|'), FMessaggi[0]);
  Assert.IsTrue(FMessaggi[0].Contains('Ctrl+Alt+Q'), 'il testo indica la scorciatoia per avviare');
end;

procedure TTestRegistroDiagnostico.Messaggio_ConOnMessaggio_NessunaFinestraPropria;
begin
  // OnMessaggio sostituisce del tutto le finestre della unit: se ne comparisse
  // una, la prova resterebbe ferma su un dialogo. Qui il messaggio arriva
  // all'applicazione con titolo e testo.
  FSessione.InserisciSegnalibro('x', ocMenu);

  Assert.AreEqual(1, FMessaggi.Count);
  Assert.IsTrue(FMessaggi[0].Contains('|'), 'titolo e testo separati');
end;

procedure TTestRegistroDiagnostico.RichiestaAvvioPresente_SoloFileDellaPostazione;
begin
  Assert.IsFalse(FSessione.RichiestaAvvioPresente, 'cartella vuota');

  ScriviRichiesta('altro.utente-ALTRO-PC');
  Assert.IsFalse(FSessione.RichiestaAvvioPresente, 'la richiesta e'' di un altro computer');

  ScriviRichiesta(NomePostazione);
  Assert.IsTrue(FSessione.RichiestaAvvioPresente);
end;

procedure TTestRegistroDiagnostico.DidascaliaVoceAvvio_SegueLaRichiesta;
begin
  Assert.AreEqual('Registra dal prossimo avvio', FSessione.DidascaliaVoceAvvio);

  ScriviRichiesta(NomePostazione);
  Assert.AreEqual('Annulla registrazione dal prossimo avvio', FSessione.DidascaliaVoceAvvio);
end;

procedure TTestRegistroDiagnostico.DidascaliaVoceMenu_ARiposo_CitaLaScorciatoia;
begin
  FSessione.TestoScorciatoia := 'Ctrl+Alt+Q';

  Assert.AreEqual('Avvia registrazione per l''assistenza', FSessione.DidascaliaVoceMenu);
  Assert.IsTrue(FSessione.SuggerimentoVoceMenu.Contains('Ctrl+Alt+Q'));
end;

procedure TTestRegistroDiagnostico.CommutaRichiestaAvvio_ConConferma_ScriveLaRichiesta;
var
  Richiesta: TStringList;
  Data: string;
begin
  FRispostaConferma := True;

  FSessione.CommutaRichiestaAvvio;

  Assert.AreEqual(1, FConferme.Count);
  Assert.IsTrue(FConferme[0].Contains('Procedo?'));
  Assert.IsTrue(TFile.Exists(FileRichiesta(NomePostazione)), 'richiesta scritta');
  Assert.IsTrue(FSessione.RichiestaAvvioPresente);
  Assert.AreEqual(1, FStatiCambiati, 'lo stato cambia una volta sola');
  Assert.AreEqual(1, FMessaggi.Count);
  Assert.IsTrue(FMessaggi[0].StartsWith('Registrazione richiesta|'), FMessaggi[0]);

  Richiesta := TStringList.Create;
  try
    Richiesta.LoadFromFile(FileRichiesta(NomePostazione), TEncoding.UTF8);
    Assert.AreEqual(NomePostazione, Richiesta.Values['postazione']);
    Assert.IsTrue(Richiesta.IndexOfName('utente') >= 0, 'voce utente presente');
    Assert.AreEqual('', Richiesta.Values['opzioni'], 'dal menu la richiesta non porta opzioni');
    // aaaa-mm-gg hh:nn:ss
    Data := Richiesta.Values['richiesta'];
    Assert.AreEqual(19, Length(Data));
    Assert.IsTrue(Data[5] = '-');
    Assert.IsTrue(Data[8] = '-');
    Assert.IsTrue(Data[11] = ' ');
    Assert.IsTrue(Data[14] = ':');
    Assert.IsTrue(Data[17] = ':');
  finally
    FreeAndNil(Richiesta);
  end;
end;

procedure TTestRegistroDiagnostico.CommutaRichiestaAvvio_ConfermaNegata_NienteFile;
begin
  FRispostaConferma := False;

  FSessione.CommutaRichiestaAvvio;

  Assert.AreEqual(1, FConferme.Count);
  Assert.IsFalse(TFile.Exists(FileRichiesta(NomePostazione)));
  Assert.AreEqual(0, FMessaggi.Count);
  Assert.AreEqual(0, FStatiCambiati);
end;

procedure TTestRegistroDiagnostico.CommutaRichiestaAvvio_RichiestaPresente_LaAnnullaSenzaChiedere;
begin
  ScriviRichiesta(NomePostazione);

  FSessione.CommutaRichiestaAvvio;

  Assert.AreEqual(0, FConferme.Count, 'annullare non chiede conferma');
  Assert.IsFalse(TFile.Exists(FileRichiesta(NomePostazione)));
  Assert.AreEqual(1, FMessaggi.Count);
  Assert.IsTrue(FMessaggi[0].StartsWith('Richiesta annullata|'), FMessaggi[0]);
  Assert.AreEqual(1, FStatiCambiati);
end;

procedure TTestRegistroDiagnostico.CommutaRichiestaAvvio_SenzaParametriMantis_NonScrive;
begin
  TzExceptionManager.MantisServerParams.Init('', '', 'LOG', 1000);

  FSessione.CommutaRichiestaAvvio;

  Assert.AreEqual(0, FConferme.Count, 'nemmeno la domanda');
  Assert.IsFalse(TFile.Exists(FileRichiesta(NomePostazione)));
  Assert.AreEqual(0, FMessaggi.Count);
end;

procedure TTestRegistroDiagnostico.CommutaRichiestaAvvio_SenzaParametriMantis_AnnullaComunque;
begin
  ScriviRichiesta(NomePostazione);
  TzExceptionManager.MantisServerParams.Init('', '', 'LOG', 1000);

  FSessione.CommutaRichiestaAvvio;

  Assert.IsFalse(TFile.Exists(FileRichiesta(NomePostazione)), 'l''annullamento non dipende da Mantis');
end;

procedure TTestRegistroDiagnostico.AvviaAllAvvio_SenzaRichiesta_FalsoENienteFile;
begin
  Assert.IsFalse(FSessione.AvviaAllAvvio);

  Assert.IsFalse(FSessione.Attiva);
  Assert.AreEqual(0, NumeroFileInCartella);
  Assert.AreEqual(0, FMessaggi.Count);
end;

procedure TTestRegistroDiagnostico.AvviaAllAvvio_RichiestaDiUnAltroComputer_NonLaConsuma;
begin
  ScriviRichiesta('altro.utente-ALTRO-PC');

  Assert.IsFalse(FSessione.AvviaAllAvvio);

  Assert.IsTrue(TFile.Exists(FileRichiesta('altro.utente-ALTRO-PC')), 'la richiesta altrui resta');
  Assert.IsFalse(FSessione.Attiva);
end;

procedure TTestRegistroDiagnostico.VerificaSessioneInterrotta_MarcatoreDiAltraPostazione_Resta;
var
  Sessione: string;
  FileSil: string;
begin
  Sessione := 'LOG-20261101-100000-altro.utente-ALTRO-PC';
  FileSil := TPath.Combine(FCartella, Sessione + '.sil');
  TFile.WriteAllText(FileSil, 'registro');
  ScriviMarcatore(Sessione, 'altro.utente-ALTRO-PC', TPath.Combine(FCartella, Sessione + '.log'), FileSil);

  FSessione.VerificaSessioneInterrotta;

  Assert.AreEqual(0, FConferme.Count, 'nessuna domanda per le sessioni altrui');
  Assert.IsTrue(TFile.Exists(PercorsoMarcatore(Sessione)), 'il marcatore altrui non si tocca');
  Assert.IsTrue(TFile.Exists(FileSil));
end;

procedure TTestRegistroDiagnostico.VerificaSessioneInterrotta_FileSpariti_EliminaIlMarcatoreSenzaDomande;
var
  Sessione: string;
begin
  Sessione := 'LOG-20261101-100000-' + NomePostazione;
  ScriviMarcatore(Sessione, NomePostazione, TPath.Combine(FCartella, Sessione + '.log'),
    TPath.Combine(FCartella, Sessione + '.sil'));

  FSessione.VerificaSessioneInterrotta;

  Assert.AreEqual(0, FConferme.Count);
  Assert.IsFalse(TFile.Exists(PercorsoMarcatore(Sessione)), 'senza file il marcatore non serve piu''');
end;

procedure TTestRegistroDiagnostico.VerificaSessioneInterrotta_UtenteRifiuta_EliminaMarcatoreEConservaIFile;
var
  Sessione: string;
  FileSil: string;
begin
  Sessione := 'LOG-20261101-100000-' + NomePostazione;
  FileSil := TPath.Combine(FCartella, Sessione + '.sil');
  TFile.WriteAllText(FileSil, 'registro');
  ScriviMarcatore(Sessione, NomePostazione, TPath.Combine(FCartella, Sessione + '.log'), FileSil);
  FRispostaConferma := False;

  FSessione.VerificaSessioneInterrotta;

  Assert.AreEqual(1, FConferme.Count);
  Assert.IsTrue(FConferme[0].Contains(Sessione), 'la domanda cita la sessione');
  Assert.IsFalse(TFile.Exists(PercorsoMarcatore(Sessione)), 'il marcatore si elimina anche con il rifiuto');
  Assert.IsTrue(TFile.Exists(FileSil), 'il registro resta su disco fino alla pulizia per eta''');
  Assert.AreEqual(0, FMessaggi.Count, 'nessun invio, nessun messaggio');
end;

procedure TTestRegistroDiagnostico.VerificaSessioneInterrotta_SenzaParametriMantis_LasciaIMarcatori;
var
  Sessione: string;
  FileSil: string;
begin
  Sessione := 'LOG-20261101-100000-' + NomePostazione;
  FileSil := TPath.Combine(FCartella, Sessione + '.sil');
  TFile.WriteAllText(FileSil, 'registro');
  ScriviMarcatore(Sessione, NomePostazione, TPath.Combine(FCartella, Sessione + '.log'), FileSil);
  TzExceptionManager.MantisServerParams.Init('', '', 'LOG', 1000);

  FSessione.VerificaSessioneInterrotta;

  Assert.AreEqual(0, FConferme.Count);
  Assert.IsTrue(TFile.Exists(PercorsoMarcatore(Sessione)), 'una configurazione successiva potra'' recuperarla');
end;

procedure TTestRegistroDiagnostico.Divergenza_DIV_LOG_4_MarcatoreIllegibile_NonInterrompeLaScansione;
var
  Bloccato: TFileStream;
  SessionePropria: string;
begin
  // Il primo marcatore (in ordine alfabetico) e' aperto in esclusiva: la sua
  // lettura solleva. Il secondo e' della postazione e senza file: va eliminato
  // comunque, perche' la scansione prosegue.
  Bloccato := TFileStream.Create(PercorsoMarcatore('LOG-a-bloccato'), fmCreate or fmShareExclusive);
  try
    SessionePropria := 'LOG-b-' + NomePostazione;
    ScriviMarcatore(SessionePropria, NomePostazione, TPath.Combine(FCartella, SessionePropria + '.log'),
      TPath.Combine(FCartella, SessionePropria + '.sil'));

    FSessione.VerificaSessioneInterrotta;

    Assert.IsFalse(TFile.Exists(PercorsoMarcatore(SessionePropria)), 'il marcatore proprio e'' trattato anche dopo uno illeggibile');
    Assert.IsTrue(TFile.Exists(PercorsoMarcatore('LOG-a-bloccato')), 'il marcatore illeggibile resta dov''e''');
  finally
    FreeAndNil(Bloccato);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRegistroDiagnostico);

end.
