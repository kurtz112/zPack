// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-08-24
// ---------------------------------------------------------------------------

unit EsportazioneContabile.Types;

// Tipi comuni del motore di esportazione contabile multi-gestionale.
// Unit riusabile: nessuna dipendenza da unit applicative (WT.Globals,
// ConfigModule, dmCommon). L'aggancio all'applicazione sta nel DataModule
// ponte (WT.EsportazioneContabile.Bridge).
//
// Riferimento: Analisi - 20260731 - Integrazione WT Con Gestionali Commerciali.md

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  EzEsportazioneContabile = class(Exception);

  // Codici della tabella ESPORTAZIONI_CONTABILI_GESTIONALI: il registro degli
  // esportatori usa la stringa, non un tipo enumerato, cosi' aggiungere un
  // gestionale non richiede di toccare questa unit.
  TzTipoContoContabile = (tcCliente, tcFornitore, tcGenerico);

  TzTipoCorrispondenza = (crConto, crCausale, crCodiceIva, crPagamento, crRegistroIva);

  // Una riga del castelletto contabile di una registrazione.
  TzRigaContabile = class
  public
    TipoConto: TzTipoContoContabile;
    CodiceConto: string;          // codice WinTarif, tradotto dall'esportatore via corrispondenze
    ImportoDare: Currency;
    ImportoAvere: Currency;
    DescrizioneRiga: string;
    CodiceIva: string;            // vuoto per le righe senza IVA
    Imponibile: Currency;         // valorizzato solo sulle righe IVA
    // Imputazione analitica: additivi, WT li lascia vuoti. Alimentano il
    // quarto file di Mexal (EsportazioneContabile.Mexal.Analitica).
    CodiceCommessa: string;       // progetto Gesty, tradotto via corrispondenze
    CodiceCentroDiCosto: string;  // centro di costo del movimento
  end;

  // Una registrazione di prima nota pronta per l'esportazione.
  // Il riempimento (da incassi, fatture emesse, ...) e' compito del ponte
  // applicativo; il motore si limita a scriverla nel tracciato di destinazione.
  TzMovimentoContabile = class
  private
    FRighe: TObjectList<TzRigaContabile>;
  public
    DataRegistrazione: TDate;
    CodiceCausale: string;        // codice WinTarif, tradotto via corrispondenze
    DescrizioneTestata: string;
    NumeroDocumento: string;
    DataDocumento: TDate;
    CodiceClienteFornitore: string;
    TotaleDocumento: Currency;
    // Aggancio al documento WinTarif di origine, per il registro delle
    // esportazioni (ESPORTAZIONI_CONTABILI_REGISTRAZIONI_DOCUMENTI).
    OidOrigine: string;
    IdDocumentoOrigine: Integer;

    constructor Create;
    destructor Destroy; override;

    function AggiungiRiga: TzRigaContabile;
    property Righe: TObjectList<TzRigaContabile> read FRighe;
  end;

  // Anagrafica cliente da esportare (contribuente WinTarif).
  TzAnagraficaContabile = class
  public
    CodiceInterno: string;
    RagioneSociale: string;
    Indirizzo: string;
    Cap: string;
    Comune: string;
    Provincia: string;
    CodiceFiscale: string;
    PartitaIva: string;
    CodicePagamento: string;
  end;

  // Traduzione dei codici WinTarif nei codici del gestionale di destinazione.
  // Implementata dal ponte applicativo sulla tabella
  // ESPORTAZIONI_CONTABILI_CORRISPONDENZE.
  IzCorrispondenzeContabili = interface
    ['{7E7C2E1A-5B7D-4A83-9C7B-2A9E4F6D0C11}']
    // Solleva EzEsportazioneContabile se la corrispondenza manca:
    // un codice non mappato non deve mai finire silenziosamente nel file.
    function CodiceEsterno(Tipo: TzTipoCorrispondenza; const CodiceInterno: string): string;
    // Parametri di ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI per il gestionale attivo.
    function Parametro(const Chiave, ValorePredefinito: string): string;
  end;

  // Esito di una esportazione: nomi dei file prodotti con il loro ruolo
  // (TESTATE, RIGHE, INTRA, ANALITICA, UNICO) per il registro.
  TzFileEsportato = record
    NomeFile: string;
    Ruolo: string;
  end;

  // Contratto degli esportatori. Un'implementazione per gestionale,
  // registrata in EsportazioneContabile.Registry con il codice della
  // tabella ESPORTAZIONI_CONTABILI_GESTIONALI.
  IzEsportatoreContabile = interface
    ['{B4A15E92-30F1-4C56-8A4D-9D2E7C31F844}']
    function Gestionale: string;
    function Descrizione: string;

    function EsportaPrimaNota(Movimenti: TObjectList<TzMovimentoContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>;
    function EsportaAnagrafiche(Anagrafiche: TObjectList<TzAnagraficaContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>;
  end;

implementation

// --- TzMovimentoContabile ---------------------------------------------------

constructor TzMovimentoContabile.Create;
begin
  inherited Create;
  FRighe := TObjectList<TzRigaContabile>.Create(True);
end;

destructor TzMovimentoContabile.Destroy;
begin
  FRighe.Free;
  inherited Destroy;
end;

function TzMovimentoContabile.AggiungiRiga: TzRigaContabile;
begin
  Result := TzRigaContabile.Create;
  FRighe.Add(Result);
end;

end.
