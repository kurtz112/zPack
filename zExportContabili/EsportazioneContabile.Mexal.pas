// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------

unit EsportazioneContabile.Mexal;

// Esportatore per Passepartout Mexal / Passcom.
//
// Riferimento: manuale prodotto edupass.it, "Servizi > Trasferimento archivi >
// Caricamento ASCII (CSV) > Prima nota" (verificato il 31/07/2026):
// - la funzione di Mexal accoda registrazioni da file ASCII CSV secondo un
//   tracciato record standard, aggiornando i progressivi Dare/Avere;
// - file distinti: TESTATE, TESTATE DATI INTRA, RIGHE, RIGHE CONT. ANALITICA;
// - separatore configurabile: 1 = ';'  2 = ':'  3 = ',';
// - il file righe puo' essere ordinato per chiave primaria ("file righe
//   allineato" = S): questo esportatore lo produce SEMPRE ordinato;
// - lato Mexal esistono import di prova (definitivo = N), protocollo IVA
//   automatico e aggiornamento scadenzario.
//
// >> DA COMPLETARE: l'elenco campo per campo delle colonne di testata e riga
//    sta nel capitolo "tracciati record" del manuale completo scaricabile da
//    edupass.it. Le costanti di colonna qui sotto vanno allineate a quel
//    documento prima del collaudo.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  EsportazioneContabile.Types, EsportazioneContabile.Base;

type
  TzEsportatoreContabileMexal = class(TzEsportatoreContabileBase)
  private
    function Separatore: Char;
    function NomeFile(const CartellaDestinazione, Suffisso: string): string;
    procedure ScriviTestate(Movimenti: TObjectList<TzMovimentoContabile>;
      const NomeFileCompleto: string);
    procedure ScriviRighe(Movimenti: TObjectList<TzMovimentoContabile>;
      const NomeFileCompleto: string);
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
  // Parametri in ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI, gestionale MEXAL
  ParametroSeparatore = 'SEPARATORE';        // 1 = ';'  2 = ':'  3 = ','
  ParametroPrefissoNomeFile = 'PREFISSO_NOME_FILE';

function TzEsportatoreContabileMexal.Gestionale: string;
begin
  Result := 'MEXAL';
end;

function TzEsportatoreContabileMexal.Descrizione: string;
begin
  Result := 'Passepartout Mexal / Passcom';
end;

function TzEsportatoreContabileMexal.Separatore: Char;
begin
  case StrToIntDef(Parametro(ParametroSeparatore, '1'), 1) of
    2: Result := ':';
    3: Result := ',';
  else
    Result := ';';
  end;
end;

function TzEsportatoreContabileMexal.NomeFile(const CartellaDestinazione,
  Suffisso: string): string;
begin
  Result := TPath.Combine(CartellaDestinazione,
    Parametro(ParametroPrefissoNomeFile, 'WTPN') + Suffisso + '.csv');
end;

function TzEsportatoreContabileMexal.EsportaPrimaNota(
  Movimenti: TObjectList<TzMovimentoContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
var
  FileTestate: string;
  FileRighe: string;
begin
  FileTestate := NomeFile(CartellaDestinazione, '_TESTATE');
  FileRighe := NomeFile(CartellaDestinazione, '_RIGHE');

  ScriviTestate(Movimenti, FileTestate);
  ScriviRighe(Movimenti, FileRighe);

  // Dati Intra e contabilita' analitica non riguardano l'export da WinTarif:
  // i due file restano volutamente non prodotti (in Mexal sono facoltativi).
  SetLength(Result, 2);
  Result[0].NomeFile := FileTestate;
  Result[0].Ruolo := 'TESTATE';
  Result[1].NomeFile := FileRighe;
  Result[1].Ruolo := 'RIGHE';
end;

procedure TzEsportatoreContabileMexal.ScriviTestate(
  Movimenti: TObjectList<TzMovimentoContabile>; const NomeFileCompleto: string);
var
  Scrittore: TStreamWriter;
  Movimento: TzMovimentoContabile;
begin
  Scrittore := CreaScrittore(NomeFileCompleto);
  try
    for Movimento in Movimenti do
      // >> DA COMPLETARE: sequenza e numero dei campi dal tracciato record
      //    ufficiale. Qui i campi certi, nell'ordine provvisorio.
      Scrittore.WriteLine(RigaCsv([
        FormatDateTime('yyyymmdd', Movimento.DataRegistrazione),
        Traduci(crCausale, Movimento.CodiceCausale),
        Movimento.NumeroDocumento,
        CampoDataFissa(Movimento.DataDocumento),
        Traduci(crConto, Movimento.CodiceClienteFornitore),
        CampoNumeroCsv(Movimento.TotaleDocumento, 2),
        Movimento.DescrizioneTestata
      ], Separatore));
  finally
    Scrittore.Free;
  end;
end;

procedure TzEsportatoreContabileMexal.ScriviRighe(
  Movimenti: TObjectList<TzMovimentoContabile>; const NomeFileCompleto: string);
var
  Scrittore: TStreamWriter;
  Movimento: TzMovimentoContabile;
  Riga: TzRigaContabile;
begin
  // Il file righe viene scritto nello stesso ordine delle testate: rispetta
  // il requisito "file righe allineato = S" e permette a Mexal l'import in
  // un passaggio solo.
  Scrittore := CreaScrittore(NomeFileCompleto);
  try
    for Movimento in Movimenti do
      for Riga in Movimento.Righe do
        // >> DA COMPLETARE: chiave primaria di aggancio testata/riga secondo
        //    il tracciato record ufficiale.
        Scrittore.WriteLine(RigaCsv([
          FormatDateTime('yyyymmdd', Movimento.DataRegistrazione),
          Movimento.NumeroDocumento,
          Traduci(crConto, Riga.CodiceConto),
          CampoNumeroCsv(Riga.ImportoDare, 2),
          CampoNumeroCsv(Riga.ImportoAvere, 2),
          Traduci(crCodiceIva, Riga.CodiceIva),
          Riga.DescrizioneRiga
        ], Separatore));
  finally
    Scrittore.Free;
  end;
end;

function TzEsportatoreContabileMexal.EsportaAnagrafiche(
  Anagrafiche: TObjectList<TzAnagraficaContabile>;
  const CartellaDestinazione: string): TArray<TzFileEsportato>;
begin
  // Mexal ha il caricamento "Rubrica piano dei conti" da ASCII CSV, stessa
  // famiglia di tracciato della prima nota.
  // >> DA COMPLETARE con il tracciato record della rubrica.
  raise EzEsportazioneContabile.Create(
    'Esportazione anagrafiche verso Mexal non ancora implementata');
end;

initialization
  TzEsportatoriContabili.Registra('MEXAL', TzEsportatoreContabileMexal);

end.
