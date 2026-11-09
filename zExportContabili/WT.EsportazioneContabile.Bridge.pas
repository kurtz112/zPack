// ---------------------------------------------------------------------------
// Copyright (c) 2026 Softline S.r.l. - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------

unit WT.EsportazioneContabile.Bridge;

// DataModule ponte fra WinTarif e il motore EsportazioneContabile.*:
// - legge la configurazione dell'azienda di lavoro
//   (ESPORTAZIONI_CONTABILI_CONFIGURAZIONE) e crea l'esportatore del
//   gestionale ATTIVO tramite il registro;
// - implementa IzCorrispondenzeContabili sulle tabelle
//   ESPORTAZIONI_CONTABILI_CORRISPONDENZE e _CONFIG_PARAMETRI;
// - registra l'esito in ESPORTAZIONI_CONTABILI_REGISTRAZIONI (+ _FILES,
//   + _DOCUMENTI).
//
// Il motore non conosce WinTarif: tutte le dipendenze applicative
// (Config, dmCommon, AziendaDiLavoro) restano in questa unit.
//
// SCHELETRO: le query sono indicate come costanti SQL; l'esecuzione con
// TzFbDataSet/TzStoredProc va completata in IDE sul modello degli altri
// DataModule (transazioni di lettura/scrittura di TBaseDbDataModule,
// Commit/Rollback del DataModule, mai della transazione).

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  EsportazioneContabile.Types, EsportazioneContabile.Base,
  EsportazioneContabile.Registry;

type
  TdmEsportazioneContabileBridge = class(TDataModule, IzCorrispondenzeContabili)
  private
    FGestionaleAttivo: string;
    FCartellaDestinazione: string;
    procedure CaricaConfigurazione;
  public
    // IzCorrispondenzeContabili
    function CodiceEsterno(Tipo: TzTipoCorrispondenza;
      const CodiceInterno: string): string;
    function Parametro(const Chiave, ValorePredefinito: string): string;

    // Crea l'esportatore del gestionale attivo per l'azienda di lavoro.
    // Solleva EzEsportazioneContabile se la configurazione manca o il
    // gestionale non ha un esportatore registrato.
    function EsportatoreCorrente: IzEsportatoreContabile;

    property GestionaleAttivo: string read FGestionaleAttivo;
    property CartellaDestinazione: string read FCartellaDestinazione;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

const
  SqlConfigurazione =
    'SELECT ' +
    '    ESPORTAZIONI_CONTABILI_CONFIGURAZIONE.GESTIONALE, ' +
    '    ESPORTAZIONI_CONTABILI_CONFIGURAZIONE.ATTIVO, ' +
    '    ESPORTAZIONI_CONTABILI_CONFIGURAZIONE.CARTELLA_DESTINAZIONE ' +
    'FROM ' +
    '    ESPORTAZIONI_CONTABILI_CONFIGURAZIONE ' +
    'WHERE ' +
    '    ESPORTAZIONI_CONTABILI_CONFIGURAZIONE.ID_AZIENDA = :ID_AZIENDA';

  SqlCorrispondenza =
    'SELECT ' +
    '    ESPORTAZIONI_CONTABILI_CORRISPONDENZE.CODICE_ESTERNO ' +
    'FROM ' +
    '    ESPORTAZIONI_CONTABILI_CORRISPONDENZE ' +
    'WHERE ' +
    '    ESPORTAZIONI_CONTABILI_CORRISPONDENZE.ID_AZIENDA = :ID_AZIENDA AND ' +
    '    ESPORTAZIONI_CONTABILI_CORRISPONDENZE.GESTIONALE = :GESTIONALE AND ' +
    '    ESPORTAZIONI_CONTABILI_CORRISPONDENZE.TIPO = :TIPO AND ' +
    '    ESPORTAZIONI_CONTABILI_CORRISPONDENZE.CODICE_INTERNO = :CODICE_INTERNO';

  SqlParametro =
    'SELECT ' +
    '    ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI.VALORE ' +
    'FROM ' +
    '    ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI ' +
    'WHERE ' +
    '    ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI.ID_AZIENDA = :ID_AZIENDA AND ' +
    '    ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI.GESTIONALE = :GESTIONALE AND ' +
    '    ESPORTAZIONI_CONTABILI_CONFIG_PARAMETRI.CHIAVE = :CHIAVE';

const
  CodiciTipoCorrispondenza: array[TzTipoCorrispondenza] of string =
    ('CONTO', 'CAUSALE', 'CODICE_IVA', 'PAGAMENTO', 'REGISTRO_IVA');

procedure TdmEsportazioneContabileBridge.CaricaConfigurazione;
begin
  // >> DA COMPLETARE in IDE: eseguire SqlConfigurazione con
  //    :ID_AZIENDA = AziendaDiLavoro (WT.Globals) su Config.Database.
  //    Se non c'e' la riga, o ATTIVO e' falso, sollevare:
  raise EzEsportazioneContabile.Create(
    'Esportazione contabile non configurata per l''azienda di lavoro ' +
    '(tabella ESPORTAZIONI_CONTABILI_CONFIGURAZIONE)');
end;

function TdmEsportazioneContabileBridge.EsportatoreCorrente: IzEsportatoreContabile;
begin
  CaricaConfigurazione;
  Result := TzEsportatoriContabili.Crea(FGestionaleAttivo, Self);
end;

function TdmEsportazioneContabileBridge.CodiceEsterno(
  Tipo: TzTipoCorrispondenza; const CodiceInterno: string): string;
begin
  // Il codice IVA e il pagamento possono legittimamente essere vuoti in
  // ingresso: in quel caso si restituisce vuoto senza interrogare.
  if CodiceInterno = '' then
    Exit('');

  // >> DA COMPLETARE in IDE: eseguire SqlCorrispondenza con
  //    :TIPO = CodiciTipoCorrispondenza[Tipo].
  //    Se la corrispondenza manca l'esportazione DEVE fermarsi:
  raise EzEsportazioneContabile.CreateFmt(
    'Corrispondenza mancante: %s "%s" non ha un codice %s ' +
    '(tabella ESPORTAZIONI_CONTABILI_CORRISPONDENZE)',
    [CodiciTipoCorrispondenza[Tipo], CodiceInterno, FGestionaleAttivo]);
end;

function TdmEsportazioneContabileBridge.Parametro(const Chiave,
  ValorePredefinito: string): string;
begin
  // >> DA COMPLETARE in IDE: eseguire SqlParametro; se assente restituire
  //    il valore predefinito.
  Result := ValorePredefinito;
end;

end.
