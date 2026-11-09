// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------
unit EsportazioneContabile.Mexal.Analitica;

// Quarto file del caricamento ASCII di Passepartout Mexal: le righe di
// contabilita' analitica.
//
// Perche' serve solo a Gesty. In WinTarif la contabilita' analitica non c'e' e
// il file resta non prodotto (lo dice EsportazioneContabile.Mexal: "Dati Intra
// e contabilita' analitica non riguardano l'export da WinTarif"). In Gesty
// invece ogni movimento porta con se' il progetto e il centro di costo, ed e'
// esattamente il dato che il commercialista non ha e che l'ente vuole vedere
// anche nel gestionale: senza questo file l'imputazione ai progetti si ferma
// sulla soglia dello studio.
//
// Riferimento: manuale edupass.it, "Servizi > Trasferimento archivi >
// Caricamento ASCII (CSV) > Prima nota": i file della prima nota sono quattro
// (testate, testate dati Intra, righe, righe di contabilita' analitica), gli
// ultimi due facoltativi, con lo stesso separatore configurabile.
//
// Non e' un discendente di TzEsportatoreContabileMexal: e' un fratello, cosi'
// l'unit del gestionale resta quella che e' e non va forcata. Il ponte chiama
// prima l'esportatore Mexal e poi questo, quando il parametro
// ESPORTA_ANALITICA vale S.
//
// >> RICHIEDE la modifica a EsportazioneContabile.Types elencata nell'analisi:
//    TzRigaContabile deve avere CodiceCommessa e CodiceCentroDiCosto.
//
// >> DA COMPLETARE: sequenza esatta delle colonne dal capitolo "tracciati
//    record" del manuale completo edupass. Qui i campi certi, nell'ordine
//    provvisorio, come nell'esportatore Mexal delle testate e delle righe.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  EsportazioneContabile.Types,
  EsportazioneContabile.Base;

type
  TzEsportatoreAnaliticaMexal = class(TzEsportatoreContabileBase)
  private
    function Separatore: Char;
  public
    function Gestionale: string; override;
    function Descrizione: string; override;

    // Scrive il solo file delle righe di contabilita' analitica.
    // Restituisce un elemento con ruolo ANALITICA, oppure un elenco vuoto se
    // nessun movimento porta imputazione analitica: un file vuoto in ingresso
    // a Mexal e' un errore, meglio non produrlo.
    function EsportaPrimaNota(Movimenti: TObjectList<TzMovimentoContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; override;

    function EsportaAnagrafiche(Anagrafiche: TObjectList<TzAnagraficaContabile>;
      const CartellaDestinazione: string): TArray<TzFileEsportato>; override;
  end;

implementation

uses
  System.IOUtils;

const
  ParametroSeparatore = 'SEPARATORE';        // 1 = ';'  2 = ':'  3 = ','
  ParametroPrefissoNomeFile = 'PREFISSO_NOME_FILE';

function TzEsportatoreAnaliticaMexal.Gestionale: string;
begin
  Result := 'MEXAL';
end;

function TzEsportatoreAnaliticaMexal.Descrizione: string;
begin
  Result := 'Passepartout Mexal - righe di contabilita analitica';
end;

function TzEsportatoreAnaliticaMexal.Separatore: Char;
begin
  case StrToIntDef(Parametro(ParametroSeparatore, '1'), 1) of
    2: Result := ':';
    3: Result := ',';
  else
    Result := ';';
  end;
end;

function TzEsportatoreAnaliticaMexal.EsportaPrimaNota(
  Movimenti: TObjectList<TzMovimentoContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
var
  NomeFileCompleto: string;
  Scrittore: TStreamWriter;
  Movimento: TzMovimentoContabile;
  Riga: TzRigaContabile;
  RigheScritte: Integer;
begin
  SetLength(Result, 0);
  RigheScritte := 0;

  NomeFileCompleto := TPath.Combine(CartellaDestinazione,
    Parametro(ParametroPrefissoNomeFile, 'GEPN') + '_ANALITICA.csv');

  Scrittore := CreaScrittore(NomeFileCompleto);
  try
    // Stesso ordine di testate e righe: il file resta allineato per chiave
    // primaria, come richiede l'opzione "file righe allineato = S".
    for Movimento in Movimenti do
      for Riga in Movimento.Righe do
      begin
        // solo le righe che hanno davvero un'imputazione analitica
        if (Riga.CodiceCommessa = '') and (Riga.CodiceCentroDiCosto = '') then
          Continue;

        Scrittore.WriteLine(RigaCsv([
          FormatDateTime('yyyymmdd', Movimento.DataRegistrazione),
          Movimento.NumeroDocumento,
          Traduci(crConto, Riga.CodiceConto),
          Riga.CodiceCommessa,
          Riga.CodiceCentroDiCosto,
          CampoNumeroCsv(Riga.ImportoDare, 2),
          CampoNumeroCsv(Riga.ImportoAvere, 2),
          Riga.DescrizioneRiga
        ], Separatore));

        Inc(RigheScritte);
      end;
  finally
    Scrittore.Free;
  end;

  if RigheScritte = 0 then
  begin
    TFile.Delete(NomeFileCompleto);
    Exit;
  end;

  SetLength(Result, 1);
  Result[0].NomeFile := NomeFileCompleto;
  Result[0].Ruolo := 'ANALITICA';
end;

function TzEsportatoreAnaliticaMexal.EsportaAnagrafiche(
  Anagrafiche: TObjectList<TzAnagraficaContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
begin
  raise EzEsportazioneContabile.Create(
    'Le anagrafiche non passano dal file di contabilita analitica');
end;

end.
