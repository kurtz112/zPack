// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------

unit EsportazioneContabile.AdHoc;

// Esportatore per Zucchetti Ad Hoc Enterprise / Revolution.
//
// Riferimento: manuale "Piattaforma Applicativa Gestionale - Procedure di
// Import, Release 7.0" (adhocenter.com, verificato il 31/07/2026):
// - file ASCII a campi di LUNGHEZZA FISSA (formato SDF), record chiusi da
//   CR+LF (cap. 1, "Convenzioni sul Formato Dati ASCII");
// - numerici: allineati a destra, virgola decimale (accettato anche il
//   punto), niente separatore migliaia, '-' davanti alla prima cifra,
//   il campo del valore zero puo' restare vuoto;
// - alfanumerici: allineati a sinistra, spazi a destra; caratteri in
//   eccesso troncati;
// - date: AAAAMMGG con zeri di riempimento;
// - tracciati record multipli: il TIPO RECORD sta nei PRIMI DUE caratteri;
// - testata/corpo (master/detail): i PRIMI DIECI caratteri del record sono
//   la chiave di associazione fra testate e righe;
// - ATTENZIONE (appendice 5-13): se lo stesso conto compare su righe
//   consecutive con sezioni diverse, l'import lo salda in un'unica riga.
//   L'esportatore deve quindi emettere UNA riga per conto/sezione.
//
// L'import di prima nota alimenta PNT_MAST (testate: PNCODESE, PNNUMRER,
// PNDATREG, PNCODCAU, PNCOMPET, PNNUMDOC, PNDATDOC, PNCODCLF, PNTOTDOC, ...)
// e PNT_DETT (righe: PNTIPCON, PNCODCON, PNIMPDAR, PNIMPAVE, PNDESRIG, ...).
//
// >> DA COMPLETARE: posizioni e lunghezze esatte delle colonne. Nel manuale
//    (appendice "File Ascii Standard Archivi Anagrafici Contabili,
//    Primanota", pagg. 5-3..5-12) i tracciati sono riprodotti come immagini:
//    vanno ricopiati a mano, oppure stampati dalla funzione "Stampa Tracciati
//    Records" di una installazione Ad Hoc (i tracciati standard sono
//    precaricati nella procedura).

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  EsportazioneContabile.Types, EsportazioneContabile.Base;

type
  TzEsportatoreContabileAdHoc = class(TzEsportatoreContabileBase)
  private
    procedure ScriviMovimento(Scrittore: TStreamWriter;
      Movimento: TzMovimentoContabile; Progressivo: Integer);
  public
    function Gestionale: string; override;
    function Descrizione: string; override;
    function EsportaPrimaNota(Movimenti: TObjectList<TzMovimentoContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; override;
    function EsportaAnagrafiche(Anagrafiche: TObjectList<TzAnagraficaContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; override;
  end;

implementation

uses
  System.IOUtils, EsportazioneContabile.Registry;

const
  // Tipo record nei primi due caratteri (convenzione tracciati multipli)
  TipoRecordTestata = 'PT';
  TipoRecordRiga    = 'PR';

  // Chiave testata/riga nei primi dieci caratteri: tipo record (2) +
  // progressivo registrazione (8).
  LunghezzaProgressivo = 8;

  // Parametri in ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI, gestionale ADHOC
  ParametroCodiceEsercizio = 'CODICE_ESERCIZIO';
  ParametroPrefissoNomeFile = 'PREFISSO_NOME_FILE';

function TzEsportatoreContabileAdHoc.Gestionale: string;
begin
  Result := 'ADHOC';
end;

function TzEsportatoreContabileAdHoc.Descrizione: string;
begin
  Result := 'Zucchetti Ad Hoc Enterprise / Revolution';
end;

function TzEsportatoreContabileAdHoc.EsportaPrimaNota(
  Movimenti: TObjectList<TzMovimentoContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
var
  NomeFileCompleto: string;
  Scrittore: TStreamWriter;
  Indice: Integer;
begin
  NomeFileCompleto := TPath.Combine(CartellaDestinazione,
    Parametro(ParametroPrefissoNomeFile, 'WTPN') + '.txt');

  Scrittore := CreaScrittore(NomeFileCompleto);
  try
    for Indice := 0 to Movimenti.Count - 1 do
      ScriviMovimento(Scrittore, Movimenti[Indice], Indice + 1);
  finally
    Scrittore.Free;
  end;

  SetLength(Result, 1);
  Result[0].NomeFile := NomeFileCompleto;
  Result[0].Ruolo := 'UNICO';
end;

procedure TzEsportatoreContabileAdHoc.ScriviMovimento(Scrittore: TStreamWriter;
  Movimento: TzMovimentoContabile; Progressivo: Integer);
var
  Chiave: string;
  Riga: TzRigaContabile;
  TipoConto: string;
begin
  // I primi dieci caratteri (tipo record + progressivo) legano testata e
  // righe: e' la convenzione master/detail della procedura di import.
  Chiave := Format('%.*d', [LunghezzaProgressivo, Progressivo]);

  // --- testata (destinazione PNT_MAST) ---
  // >> DA COMPLETARE: larghezze provvisorie, da allineare al tracciato
  //    standard stampato da Ad Hoc.
  Scrittore.WriteLine(
    TipoRecordTestata +
    Chiave +
    CampoTestoFisso(Parametro(ParametroCodiceEsercizio, ''), 4) +   // PNCODESE
    CampoDataFissa(Movimento.DataRegistrazione) +                   // PNDATREG
    CampoTestoFisso(Traduci(crCausale, Movimento.CodiceCausale), 5) + // PNCODCAU
    CampoTestoFisso(Movimento.NumeroDocumento, 15) +                // PNNUMDOC
    CampoDataFissa(Movimento.DataDocumento) +                       // PNDATDOC
    CampoTestoFisso(Traduci(crConto, Movimento.CodiceClienteFornitore), 15) + // PNCODCLF
    CampoNumeroFisso(Movimento.TotaleDocumento, 18, 2) +            // PNTOTDOC
    CampoTestoFisso(Movimento.DescrizioneTestata, 40));             // PNDESSUP

  // --- righe (destinazione PNT_DETT) ---
  for Riga in Movimento.Righe do
  begin
    case Riga.TipoConto of
      tcCliente:   TipoConto := 'C';
      tcFornitore: TipoConto := 'F';
    else
      TipoConto := 'G';
    end;
    Scrittore.WriteLine(
      TipoRecordRiga +
      Chiave +
      CampoTestoFisso(TipoConto, 1) +                               // PNTIPCON
      CampoTestoFisso(Traduci(crConto, Riga.CodiceConto), 15) +     // PNCODCON
      CampoNumeroFisso(Riga.ImportoDare, 18, 2) +                   // PNIMPDAR
      CampoNumeroFisso(Riga.ImportoAvere, 18, 2) +                  // PNIMPAVE
      CampoTestoFisso(Riga.DescrizioneRiga, 40));                   // PNDESRIG
  end;
end;

function TzEsportatoreContabileAdHoc.EsportaAnagrafiche(
  Anagrafiche: TObjectList<TzAnagraficaContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
begin
  // Il manuale copre anche i file ASCII standard delle anagrafiche contabili
  // (clienti/fornitori). >> DA COMPLETARE con il tracciato standard.
  raise EzEsportazioneContabile.Create(
    'Esportazione anagrafiche verso Ad Hoc non ancora implementata');
end;

initialization
  TzEsportatoriContabili.Registra('ADHOC', TzEsportatoreContabileAdHoc);

end.
