// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-05
// ---------------------------------------------------------------------------
unit Test.zOffice.Reports.Controller;

// Test DUnitX per la cache dei documenti di TzDocumentActionsControllerBase.
// Il controller di prova conta le letture che la base chiede
// all'applicazione (tipi versione della catena, stato della registrazione):
// una lettura in piu' e' una query in piu' in Gesty, a ogni idle.

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework,
  zOffice.Reports.Azioni,
  zOffice.Reports.Controller;

type
  TControllerDiProva = class(TzDocumentActionsControllerBase)
  protected
    function TipiVersioneInCatena(IdObjectFile: Int64): TArray<string>; override;
    function PermessoConcesso(Azione: TzAzioneDocumento): Boolean; override;
    function StatoRegistrazione(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato; override;
  public
    LettureTipiVersione: Integer;
    LettureStato: Integer;

    function PersistDocument(const Contesto: TzDocumentoContesto; const TempFileName: string): Int64; override;
    procedure Esegui(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto); override;
  end;

  [TestFixture]
  TTestCacheDocumentiController = class
  private
    FController: TControllerDiProva;
    function Contesto(IdObjectFile: Int64): TzDocumentoContesto;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure StessoDocumento_CentoVolte_UnaLettura;
    [Test]
    procedure DueDocumentiInAlternanza_UnaLetturaPerDocumento;
    [Test]
    procedure Invalida_SvuotaTuttiIDocumenti;
    [Test]
    procedure VerificaEseguibile_RileggeIlDocumento;
    [Test]
    procedure OltreIlTetto_ScartaIlMenoRecente;
    [Test]
    procedure OltreIlTetto_ConservaIlPiuRecente;
  end;

implementation

{ TControllerDiProva }

function TControllerDiProva.TipiVersioneInCatena(IdObjectFile: Int64): TArray<string>;
begin
  Inc(LettureTipiVersione);
  result := ['ORI'];
end;

function TControllerDiProva.PermessoConcesso(Azione: TzAzioneDocumento): Boolean;
begin
  result := True;
end;

function TControllerDiProva.StatoRegistrazione(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto): TzAzioneDocumentoStato;
begin
  Inc(LettureStato);
  result := adsDisponibile;
end;

function TControllerDiProva.PersistDocument(const Contesto: TzDocumentoContesto; const TempFileName: string): Int64;
begin
  result := 0;
end;

procedure TControllerDiProva.Esegui(Azione: TzAzioneDocumento; const Contesto: TzDocumentoContesto);
begin
  VerificaEseguibile(Azione, Contesto);
end;

{ TTestCacheDocumentiController }

procedure TTestCacheDocumentiController.Setup;
begin
  FController := TControllerDiProva.Create(nil);
end;

procedure TTestCacheDocumentiController.TearDown;
begin
  FreeAndNil(FController);
end;

function TTestCacheDocumentiController.Contesto(IdObjectFile: Int64): TzDocumentoContesto;
begin
  result.Clear;
  result.IdObjectFile := IdObjectFile;
  // firma abilitata dal profilo e con una precondizione di catena: cosi' ogni
  // Stato passa dalla cache dei tipi versione e da quella dello stato
  result.AzioniConfig.Firma.IsPresent := True;
  result.AzioniConfig.Firma.Enabled := True;
  result.AzioniConfig.Firma.Richiede := ['ORI'];
end;

// Mantis #210 - 2026-10-05: un documento chiesto a ogni idle va letto una volta sola
procedure TTestCacheDocumentiController.StessoDocumento_CentoVolte_UnaLettura;
var
  Ripetizione: Integer;
begin
  for Ripetizione := 1 to 100 do
    FController.Stato(adFirma, Contesto(100));

  Assert.AreEqual(1, FController.LettureTipiVersione);
  Assert.AreEqual(1, FController.LettureStato);
end;

// Mantis #210 - 2026-10-05: due documenti in alternanza (due viewer sullo
// stesso controller) non si azzerano a vicenda: una lettura per documento
procedure TTestCacheDocumentiController.DueDocumentiInAlternanza_UnaLetturaPerDocumento;
var
  Ripetizione: Integer;
begin
  for Ripetizione := 1 to 3 do
  begin
    FController.Stato(adFirma, Contesto(100));
    FController.Stato(adFirma, Contesto(200));
  end;

  Assert.AreEqual(2, FController.LettureTipiVersione);
  Assert.AreEqual(2, FController.LettureStato);
end;

// Mantis #210 - 2026-10-05: l'invalidazione dopo un'azione vale per tutti i documenti
procedure TTestCacheDocumentiController.Invalida_SvuotaTuttiIDocumenti;
begin
  FController.Stato(adFirma, Contesto(100));
  FController.Stato(adFirma, Contesto(200));

  FController.InvalidaCacheDocumento;
  FController.Stato(adFirma, Contesto(100));
  FController.Stato(adFirma, Contesto(200));

  Assert.AreEqual(4, FController.LettureTipiVersione);
  Assert.AreEqual(4, FController.LettureStato);
end;

// Mantis #210 - 2026-10-05: l'esecuzione non si fida del video e rilegge lo stato
procedure TTestCacheDocumentiController.VerificaEseguibile_RileggeIlDocumento;
begin
  FController.Stato(adFirma, Contesto(100));
  FController.Stato(adFirma, Contesto(200));

  FController.Esegui(adFirma, Contesto(100));

  Assert.AreEqual(3, FController.LettureTipiVersione);
  Assert.AreEqual(3, FController.LettureStato);
end;

// Mantis #210 - 2026-10-05: tetto di documenti ricordati, il meno recente esce
procedure TTestCacheDocumentiController.OltreIlTetto_ScartaIlMenoRecente;
var
  Documento: Integer;
begin
  // il documento 1 e' il primo e non viene piu' toccato: dopo MassimoDocumentiInCache
  // documenti nuovi e' il meno recente
  for Documento := 1 to TzDocumentActionsControllerBase.MassimoDocumentiInCache + 1 do
    FController.Stato(adFirma, Contesto(Documento));
  Assert.AreEqual(TzDocumentActionsControllerBase.MassimoDocumentiInCache + 1, FController.LettureStato);

  FController.Stato(adFirma, Contesto(1));

  Assert.AreEqual(TzDocumentActionsControllerBase.MassimoDocumentiInCache + 2, FController.LettureStato);
end;

// Mantis #210 - 2026-10-05: un documento riusato di recente resta in cache anche oltre il tetto
procedure TTestCacheDocumentiController.OltreIlTetto_ConservaIlPiuRecente;
var
  Documento: Integer;
begin
  for Documento := 1 to TzDocumentActionsControllerBase.MassimoDocumentiInCache do
    FController.Stato(adFirma, Contesto(Documento));
  // il documento 1 torna in testa, poi arriva un documento nuovo: esce il 2
  FController.Stato(adFirma, Contesto(1));
  FController.Stato(adFirma, Contesto(1000));
  Assert.AreEqual(TzDocumentActionsControllerBase.MassimoDocumentiInCache + 1, FController.LettureStato);

  FController.Stato(adFirma, Contesto(1));
  Assert.AreEqual(TzDocumentActionsControllerBase.MassimoDocumentiInCache + 1, FController.LettureStato);

  FController.Stato(adFirma, Contesto(2));
  Assert.AreEqual(TzDocumentActionsControllerBase.MassimoDocumentiInCache + 2, FController.LettureStato);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCacheDocumentiController);

end.
