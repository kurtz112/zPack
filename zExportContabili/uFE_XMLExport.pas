// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-07-31
// ---------------------------------------------------------------------------
unit uFE_XMLExport;

//  Classe TFEXmlExport: genera il file XML di fattura elettronica italiana
//  (schema FPA12 / FPR12 versione 1.2.x) leggendo le tabelle FE_* del database.
//
//  E' il modulo gemello di uFE_XMLImport: legge le stesse tabelle al contrario.
//  L'importazione scrive con le procedure FE_*_ADD, l'esportazione legge con
//  query dirette, perche' in lettura non serve incapsulare nulla.
//
//  Utilizzo:
//    var Esportatore: TFEXmlExport;
//    begin
//      Esportatore := TFEXmlExport.Create(Config.Database, Config.ReadTransaction);
//      try
//        Esportatore.EsportaSuFile(IdFattura, 'D:\uscita\IT01234567890_00001.xml');
//      finally
//        Esportatore.Free;
//      end;
//    end;
//
//  Dipendenze:
//    - zFbDataSet             (TzFbDatabase, TzFbTransaction, TzFbDataSet)
//    - Xml.XMLDoc, Xml.XMLIntf (TXMLDocument)
//
//  Nota sul contenuto: la libreria FE non modella i DatiCassaPrevidenziale in
//  forma ripetibile, ha il solo campo FE_DATI_GENERALI.IMPORTO_CASSA. Se il
//  cedente ha una cassa previdenziale da esporre nel tracciato, la tabella va
//  estesa: il punto e' segnalato nel codice con MANCA_IN_LIBRERIA.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  Xml.XMLDoc,
  Xml.XMLIntf,
  zFbDataSet;

type
  EFEExportError = class(Exception);

  TFEXmlExport = class
  private
    FDatabase: TzFbDatabase;
    FTransaction: TzFbTransaction;
    FFormatoNumerico: TFormatSettings;

    // Accesso ai dati
    function ApriQuery(const Sql: string; const Parametri: array of Variant): TzFbDataSet;

    // Helper XML: nessun nodo viene creato se il valore e' vuoto,
    // perche' il tracciato rifiuta gli elementi vuoti
    function AggiungiNodo(const Padre: IXMLNode; const Nome: string): IXMLNode;
    procedure ScriviTesto(const Padre: IXMLNode; const Nome, Valore: string);
    procedure ScriviData(const Padre: IXMLNode; const Nome: string; const Campo: TField);
    procedure ScriviImporto(const Padre: IXMLNode; const Nome: string; const Campo: TField; Decimali: Integer = 2);
    procedure ScriviCampo(const Padre: IXMLNode; const Nome: string; const Campo: TField);
    procedure ScriviBooleano(const Padre: IXMLNode; const Nome: string; const Campo: TField);

    function FormattaImporto(Valore: Double; Decimali: Integer): string;

    // Sezioni dell'intestazione
    procedure EsportaTrasmissione(const Header: IXMLNode; IdFattura: Int64);
    procedure EsportaCedente(const Header: IXMLNode; IdFattura: Int64);
    procedure EsportaCessionario(const Header: IXMLNode; IdFattura: Int64);
    procedure EsportaIntermediari(const Header: IXMLNode; IdFattura: Int64);
    procedure EsportaAnagrafica(const Padre: IXMLNode; const Dati: TzFbDataSet;
      const Prefisso: string; PartitaIvaObbligatoria: Boolean);
    procedure EsportaSede(const Padre: IXMLNode; const Dati: TzFbDataSet;
      const NomeNodo, Prefisso: string);

    // Sezioni del corpo
    procedure EsportaBody(const Radice: IXMLNode; IdFatturaBody: Int64);
    procedure EsportaDatiGenerali(const Body: IXMLNode; IdFatturaBody: Int64);
    procedure EsportaDocumentiCorrelati(const DatiGenerali: IXMLNode; IdDatiGenerali: Int64);
    procedure EsportaDatiVeicoli(const DatiGenerali: IXMLNode; IdDatiGenerali: Int64);
    procedure EsportaScontiMaggiorazioni(const Padre: IXMLNode;
      const NomeColonna: string; IdRiferimento: Int64);
    procedure EsportaBeniServizi(const Body: IXMLNode; IdFatturaBody: Int64);
    procedure EsportaRiepilogoIva(const DatiBeniServizi: IXMLNode; IdFatturaBody: Int64);
    procedure EsportaPagamenti(const Body: IXMLNode; IdFatturaBody: Int64);
    procedure EsportaAllegati(const Body: IXMLNode; IdFatturaBody: Int64);
  public
    constructor Create(ADatabase: TzFbDatabase; ATransaction: TzFbTransaction);

    // Restituisce il documento XML completo
    function EsportaXml(IdFattura: Int64): string;

    // Scrive il documento XML sul percorso indicato
    procedure EsportaSuFile(IdFattura: Int64; const NomeFile: string);

    // Nome del file secondo le specifiche: IdPaese + IdCodice + '_' + progressivo in base 36
    function ComponiNomeFile(IdFattura: Int64): string;

    property Database: TzFbDatabase read FDatabase write FDatabase;
    property Transaction: TzFbTransaction read FTransaction write FTransaction;
  end;

implementation

const
  NAMESPACE_FATTURA = 'http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2';

  // Corrispondenza fra il tipo del documento correlato e il nodo del tracciato
  TIPI_DOCUMENTO_CORRELATO: array [0 .. 6] of record
    Tipo: string;
    Nodo: string;
  end = (
    (Tipo: 'ORD'; Nodo: 'DatiOrdineAcquisto'),
    (Tipo: 'CON'; Nodo: 'DatiContratto'),
    (Tipo: 'CVZ'; Nodo: 'DatiConvenzione'),
    (Tipo: 'RIC'; Nodo: 'DatiRicezione'),
    (Tipo: 'FAC'; Nodo: 'DatiFattureCollegate'),
    (Tipo: 'SAL'; Nodo: 'DatiSAL'),
    (Tipo: 'FPR'; Nodo: 'FatturaPrincipale'));

{ TFEXmlExport }

constructor TFEXmlExport.Create(ADatabase: TzFbDatabase; ATransaction: TzFbTransaction);
begin
  inherited Create;

  FDatabase := ADatabase;
  FTransaction := ATransaction;

  // il tracciato vuole sempre il punto come separatore decimale
  FFormatoNumerico := TFormatSettings.Invariant;
end;

function TFEXmlExport.ApriQuery(const Sql: string; const Parametri: array of Variant): TzFbDataSet;
var
  Indice: Integer;
begin
  Result := TzFbDataSet.Create(nil);
  try
    Result.Connection := FDatabase;
    Result.Transaction := FTransaction;
    Result.FetchOptions.UniDirectional := True;
    Result.Sql.Text := Sql;

    for Indice := 0 to High(Parametri) do
      Result.Params[Indice].Value := Parametri[Indice];

    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

function TFEXmlExport.AggiungiNodo(const Padre: IXMLNode; const Nome: string): IXMLNode;
begin
  Result := Padre.AddChild(Nome);
end;

procedure TFEXmlExport.ScriviTesto(const Padre: IXMLNode; const Nome, Valore: string);
begin
  if Trim(Valore) = '' then
    Exit;

  Padre.AddChild(Nome).Text := Trim(Valore);
end;

procedure TFEXmlExport.ScriviCampo(const Padre: IXMLNode; const Nome: string; const Campo: TField);
begin
  if (Campo = nil) or Campo.IsNull then
    Exit;

  ScriviTesto(Padre, Nome, Campo.AsString);
end;

procedure TFEXmlExport.ScriviData(const Padre: IXMLNode; const Nome: string; const Campo: TField);
begin
  if (Campo = nil) or Campo.IsNull then
    Exit;

  Padre.AddChild(Nome).Text := FormatDateTime('yyyy-mm-dd', Campo.AsDateTime);
end;

function TFEXmlExport.FormattaImporto(Valore: Double; Decimali: Integer): string;
begin
  Result := FormatFloat('0.' + StringOfChar('0', Decimali), Valore, FFormatoNumerico);
end;

procedure TFEXmlExport.ScriviImporto(const Padre: IXMLNode; const Nome: string;
  const Campo: TField; Decimali: Integer);
begin
  if (Campo = nil) or Campo.IsNull then
    Exit;

  Padre.AddChild(Nome).Text := FormattaImporto(Campo.AsFloat, Decimali);
end;

procedure TFEXmlExport.ScriviBooleano(const Padre: IXMLNode; const Nome: string; const Campo: TField);
begin
  if (Campo = nil) or Campo.IsNull then
    Exit;

  if Campo.AsBoolean then
    Padre.AddChild(Nome).Text := 'SI';
end;

// ---------------------------------------------------------------------------
// Documento
// ---------------------------------------------------------------------------

function TFEXmlExport.EsportaXml(IdFattura: Int64): string;
var
  Documento: TXMLDocument;
  Interfaccia: IXMLDocument;
  Radice: IXMLNode;
  Header: IXMLNode;
  Testata: TzFbDataSet;
  Corpi: TzFbDataSet;
begin
  Documento := TXMLDocument.Create(nil);
  Interfaccia := Documento;
  Interfaccia.Active := True;
  Interfaccia.Version := '1.0';
  Interfaccia.Encoding := 'UTF-8';
  Interfaccia.Options := Interfaccia.Options + [doNodeAutoIndent];

  Testata := ApriQuery(
    'SELECT FE_FATTURA.ID_FATTURA, FE_FATTURA.VERSIONE, ' +
    '       FE_TRASMISSIONE.FORMATO ' +
    'FROM FE_FATTURA ' +
    '     LEFT JOIN FE_TRASMISSIONE ON FE_TRASMISSIONE.ID_FATTURA = FE_FATTURA.ID_FATTURA ' +
    'WHERE FE_FATTURA.ID_FATTURA = :ID_FATTURA', [IdFattura]);
  try
    if Testata.IsEmpty then
      raise EFEExportError.CreateFmt('Fattura %d non trovata', [IdFattura]);

    Radice := Interfaccia.AddChild('p:FatturaElettronica');
    Radice.Attributes['xmlns:p'] := NAMESPACE_FATTURA;
    Radice.Attributes['xmlns:ds'] := 'http://www.w3.org/2000/09/xmldsig#';
    Radice.Attributes['xmlns:xsi'] := 'http://www.w3.org/2001/XMLSchema-instance';

    // la versione del documento e' il formato di trasmissione: FPA12 o FPR12
    if not Testata.FieldByName('FORMATO').IsNull then
      Radice.Attributes['versione'] := Testata.FieldByName('FORMATO').AsString
    else
      Radice.Attributes['versione'] := Testata.FieldByName('VERSIONE').AsString;

    Header := AggiungiNodo(Radice, 'FatturaElettronicaHeader');

    EsportaTrasmissione(Header, IdFattura);
    EsportaCedente(Header, IdFattura);
    EsportaIntermediari(Header, IdFattura);
    EsportaCessionario(Header, IdFattura);
  finally
    Testata.Free;
  end;

  Corpi := ApriQuery(
    'SELECT FE_FATTURA_BODY.ID_FATTURA_BODY ' +
    'FROM FE_FATTURA_BODY ' +
    'WHERE FE_FATTURA_BODY.ID_FATTURA = :ID_FATTURA ' +
    'ORDER BY FE_FATTURA_BODY.PROGRESSIVO', [IdFattura]);
  try
    if Corpi.IsEmpty then
      raise EFEExportError.CreateFmt('La fattura %d non ha alcun corpo', [IdFattura]);

    while not Corpi.Eof do
    begin
      EsportaBody(Radice, Corpi.FieldByName('ID_FATTURA_BODY').AsLargeInt);
      Corpi.Next;
    end;
  finally
    Corpi.Free;
  end;

  Interfaccia.SaveToXML(Result);
end;

procedure TFEXmlExport.EsportaSuFile(IdFattura: Int64; const NomeFile: string);
var
  Contenuto: TStringList;
begin
  Contenuto := TStringList.Create;
  try
    Contenuto.Text := EsportaXml(IdFattura);
    // senza distinta di byte iniziale: alcuni recapitatori la rifiutano
    Contenuto.WriteBOM := False;
    Contenuto.SaveToFile(NomeFile, TEncoding.UTF8);
  finally
    Contenuto.Free;
  end;
end;

function TFEXmlExport.ComponiNomeFile(IdFattura: Int64): string;
var
  Dati: TzFbDataSet;
begin
  Dati := ApriQuery(
    'SELECT FE_TRASMISSIONE.ID_PAESE, FE_TRASMISSIONE.ID_CODICE, FE_TRASMISSIONE.PROGRESSIVO_INVIO ' +
    'FROM FE_TRASMISSIONE ' +
    'WHERE FE_TRASMISSIONE.ID_FATTURA = :ID_FATTURA', [IdFattura]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.CreateFmt('Dati di trasmissione mancanti per la fattura %d', [IdFattura]);

    Result := Dati.FieldByName('ID_PAESE').AsString +
              Dati.FieldByName('ID_CODICE').AsString + '_' +
              Dati.FieldByName('PROGRESSIVO_INVIO').AsString + '.xml';
  finally
    Dati.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Intestazione
// ---------------------------------------------------------------------------

procedure TFEXmlExport.EsportaTrasmissione(const Header: IXMLNode; IdFattura: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
  Identificativo: IXMLNode;
  Contatti: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_TRASMISSIONE.ID_PAESE, FE_TRASMISSIONE.ID_CODICE, FE_TRASMISSIONE.PROGRESSIVO_INVIO, ' +
    '       FE_TRASMISSIONE.FORMATO, FE_TRASMISSIONE.CODICE_DESTINATARIO, FE_TRASMISSIONE.TELEFONO, ' +
    '       FE_TRASMISSIONE.EMAIL, FE_TRASMISSIONE.PEC_DESTINATARIO ' +
    'FROM FE_TRASMISSIONE ' +
    'WHERE FE_TRASMISSIONE.ID_FATTURA = :ID_FATTURA', [IdFattura]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.Create('DatiTrasmissione mancanti');

    Nodo := AggiungiNodo(Header, 'DatiTrasmissione');

    Identificativo := AggiungiNodo(Nodo, 'IdTrasmittente');
    ScriviCampo(Identificativo, 'IdPaese', Dati.FieldByName('ID_PAESE'));
    ScriviCampo(Identificativo, 'IdCodice', Dati.FieldByName('ID_CODICE'));

    ScriviCampo(Nodo, 'ProgressivoInvio', Dati.FieldByName('PROGRESSIVO_INVIO'));
    ScriviCampo(Nodo, 'FormatoTrasmissione', Dati.FieldByName('FORMATO'));
    ScriviCampo(Nodo, 'CodiceDestinatario', Dati.FieldByName('CODICE_DESTINATARIO'));

    if not (Dati.FieldByName('TELEFONO').IsNull and Dati.FieldByName('EMAIL').IsNull) then
    begin
      Contatti := AggiungiNodo(Nodo, 'ContattiTrasmittente');
      ScriviCampo(Contatti, 'Telefono', Dati.FieldByName('TELEFONO'));
      ScriviCampo(Contatti, 'Email', Dati.FieldByName('EMAIL'));
    end;

    ScriviCampo(Nodo, 'PECDestinatario', Dati.FieldByName('PEC_DESTINATARIO'));
  finally
    Dati.Free;
  end;
end;

// Anagrafica comune a cedente, cessionario, rappresentante fiscale e intermediario.
// Il prefisso distingue le colonne quando la stessa tabella ne contiene due gruppi
// (per esempio RF_ per il rappresentante fiscale dentro FE_CESSIONARIO).
procedure TFEXmlExport.EsportaAnagrafica(const Padre: IXMLNode; const Dati: TzFbDataSet;
  const Prefisso: string; PartitaIvaObbligatoria: Boolean);
var
  DatiAnagrafici: IXMLNode;
  IdFiscale: IXMLNode;
  Anagrafica: IXMLNode;
  CampoPaese: TField;
  CampoCodice: TField;
begin
  DatiAnagrafici := AggiungiNodo(Padre, 'DatiAnagrafici');

  CampoPaese := Dati.FindField(Prefisso + 'PIVA_PAESE');
  CampoCodice := Dati.FindField(Prefisso + 'PIVA_CODICE');

  if PartitaIvaObbligatoria or ((CampoCodice <> nil) and (not CampoCodice.IsNull)) then
  begin
    IdFiscale := AggiungiNodo(DatiAnagrafici, 'IdFiscaleIVA');
    ScriviCampo(IdFiscale, 'IdPaese', CampoPaese);
    ScriviCampo(IdFiscale, 'IdCodice', CampoCodice);
  end;

  ScriviCampo(DatiAnagrafici, 'CodiceFiscale', Dati.FindField(Prefisso + 'CODICE_FISCALE'));

  Anagrafica := AggiungiNodo(DatiAnagrafici, 'Anagrafica');
  if not Dati.FieldByName(Prefisso + 'DENOMINAZIONE').IsNull then
    ScriviCampo(Anagrafica, 'Denominazione', Dati.FieldByName(Prefisso + 'DENOMINAZIONE'))
  else
  begin
    ScriviCampo(Anagrafica, 'Nome', Dati.FindField(Prefisso + 'NOME'));
    ScriviCampo(Anagrafica, 'Cognome', Dati.FindField(Prefisso + 'COGNOME'));
  end;
  ScriviCampo(Anagrafica, 'Titolo', Dati.FindField(Prefisso + 'TITOLO'));
  ScriviCampo(Anagrafica, 'CodEORI', Dati.FindField(Prefisso + 'COD_EORI'));

  // le colonne dell'albo esistono solo sul cedente
  ScriviCampo(DatiAnagrafici, 'AlboProfessionale', Dati.FindField('ALBO_PROFESSIONALE'));
  ScriviCampo(DatiAnagrafici, 'ProvinciaAlbo', Dati.FindField('PROVINCIA_ALBO'));
  ScriviCampo(DatiAnagrafici, 'NumeroIscrizioneAlbo', Dati.FindField('NUMERO_ISCRIZIONE_ALBO'));
  ScriviData(DatiAnagrafici, 'DataIscrizioneAlbo', Dati.FindField('DATA_ISCRIZIONE_ALBO'));
  ScriviCampo(DatiAnagrafici, 'RegimeFiscale', Dati.FindField('REGIME_FISCALE'));
end;

procedure TFEXmlExport.EsportaSede(const Padre: IXMLNode; const Dati: TzFbDataSet;
  const NomeNodo, Prefisso: string);
var
  Nodo: IXMLNode;
  CampoIndirizzo: TField;
begin
  CampoIndirizzo := Dati.FindField(Prefisso + 'INDIRIZZO');

  if (CampoIndirizzo = nil) or CampoIndirizzo.IsNull then
    Exit;

  Nodo := AggiungiNodo(Padre, NomeNodo);
  ScriviCampo(Nodo, 'Indirizzo', CampoIndirizzo);
  ScriviCampo(Nodo, 'NumeroCivico', Dati.FindField(Prefisso + 'NUMERO_CIVICO'));
  ScriviCampo(Nodo, 'CAP', Dati.FindField(Prefisso + 'CAP'));
  ScriviCampo(Nodo, 'Comune', Dati.FindField(Prefisso + 'COMUNE'));
  ScriviCampo(Nodo, 'Provincia', Dati.FindField(Prefisso + 'PROVINCIA'));
  ScriviCampo(Nodo, 'Nazione', Dati.FindField(Prefisso + 'NAZIONE'));
end;

procedure TFEXmlExport.EsportaCedente(const Header: IXMLNode; IdFattura: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
  Rea: IXMLNode;
  Contatti: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_CEDENTE.* FROM FE_CEDENTE WHERE FE_CEDENTE.ID_FATTURA = :ID_FATTURA', [IdFattura]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.Create('CedentePrestatore mancante');

    Nodo := AggiungiNodo(Header, 'CedentePrestatore');

    EsportaAnagrafica(Nodo, Dati, '', True);
    EsportaSede(Nodo, Dati, 'Sede', 'SEDE_');
    EsportaSede(Nodo, Dati, 'StabileOrganizzazione', 'SO_');

    if not Dati.FieldByName('REA_NUMERO').IsNull then
    begin
      Rea := AggiungiNodo(Nodo, 'IscrizioneREA');
      ScriviCampo(Rea, 'Ufficio', Dati.FieldByName('REA_UFFICIO'));
      ScriviCampo(Rea, 'NumeroREA', Dati.FieldByName('REA_NUMERO'));
      ScriviImporto(Rea, 'CapitaleSociale', Dati.FieldByName('REA_CAPITALE_SOCIALE'));
      ScriviCampo(Rea, 'SocioUnico', Dati.FieldByName('REA_SOCIO_UNICO'));
      ScriviCampo(Rea, 'StatoLiquidazione', Dati.FieldByName('REA_STATO_LIQUIDAZ'));
    end;

    if not (Dati.FieldByName('TELEFONO').IsNull and Dati.FieldByName('FAX').IsNull and
            Dati.FieldByName('EMAIL').IsNull) then
    begin
      Contatti := AggiungiNodo(Nodo, 'Contatti');
      ScriviCampo(Contatti, 'Telefono', Dati.FieldByName('TELEFONO'));
      ScriviCampo(Contatti, 'Fax', Dati.FieldByName('FAX'));
      ScriviCampo(Contatti, 'Email', Dati.FieldByName('EMAIL'));
    end;

    ScriviCampo(Nodo, 'RiferimentoAmministrazione', Dati.FieldByName('RIF_AMMINISTRAZIONE'));
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaCessionario(const Header: IXMLNode; IdFattura: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
  Rappresentante: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_CESSIONARIO.* FROM FE_CESSIONARIO WHERE FE_CESSIONARIO.ID_FATTURA = :ID_FATTURA', [IdFattura]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.Create('CessionarioCommittente mancante');

    // il rappresentante fiscale del cessionario precede il cessionario stesso
    if not Dati.FieldByName('RF_DENOMINAZIONE').IsNull or
       not Dati.FieldByName('RF_COGNOME').IsNull then
    begin
      Rappresentante := AggiungiNodo(Header, 'RappresentanteFiscale');
      EsportaAnagrafica(Rappresentante, Dati, 'RF_', False);
    end;

    Nodo := AggiungiNodo(Header, 'CessionarioCommittente');
    EsportaAnagrafica(Nodo, Dati, '', False);
    EsportaSede(Nodo, Dati, 'Sede', 'SEDE_');
    EsportaSede(Nodo, Dati, 'StabileOrganizzazione', 'SO_');
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaIntermediari(const Header: IXMLNode; IdFattura: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_INTERMEDIARIO.* FROM FE_INTERMEDIARIO ' +
    'WHERE FE_INTERMEDIARIO.ID_FATTURA = :ID_FATTURA ' +
    'ORDER BY FE_INTERMEDIARIO.TIPO', [IdFattura]);
  try
    while not Dati.Eof do
    begin
      // TI = terzo intermediario o soggetto emittente; RF gia' scritto col cessionario
      if Dati.FieldByName('TIPO').AsString = 'TI' then
      begin
        Nodo := AggiungiNodo(Header, 'TerzoIntermediarioOSoggettoEmittente');
        EsportaAnagrafica(Nodo, Dati, '', False);

        ScriviCampo(Header, 'SoggettoEmittente', Dati.FieldByName('SOGGETTO_EMITTENTE'));
      end;

      Dati.Next;
    end;
  finally
    Dati.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Corpo
// ---------------------------------------------------------------------------

procedure TFEXmlExport.EsportaBody(const Radice: IXMLNode; IdFatturaBody: Int64);
var
  Body: IXMLNode;
begin
  Body := AggiungiNodo(Radice, 'FatturaElettronicaBody');

  EsportaDatiGenerali(Body, IdFatturaBody);
  EsportaBeniServizi(Body, IdFatturaBody);
  EsportaPagamenti(Body, IdFatturaBody);
  EsportaAllegati(Body, IdFatturaBody);
end;

procedure TFEXmlExport.EsportaDatiGenerali(const Body: IXMLNode; IdFatturaBody: Int64);
var
  Dati: TzFbDataSet;
  DatiGenerali: IXMLNode;
  Documento: IXMLNode;
  Ritenuta: IXMLNode;
  Bollo: IXMLNode;
  IdDatiGenerali: Int64;
begin
  Dati := ApriQuery(
    'SELECT FE_DATI_GENERALI.* FROM FE_DATI_GENERALI ' +
    'WHERE FE_DATI_GENERALI.ID_FATTURA_BODY = :ID_FATTURA_BODY', [IdFatturaBody]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.Create('DatiGeneraliDocumento mancanti');

    IdDatiGenerali := Dati.FieldByName('ID_DATI_GENERALI').AsLargeInt;

    DatiGenerali := AggiungiNodo(Body, 'DatiGenerali');
    Documento := AggiungiNodo(DatiGenerali, 'DatiGeneraliDocumento');

    ScriviCampo(Documento, 'TipoDocumento', Dati.FieldByName('TIPO_DOCUMENTO'));
    ScriviCampo(Documento, 'Divisa', Dati.FieldByName('DIVISA'));
    ScriviData(Documento, 'Data', Dati.FieldByName('DATA'));
    ScriviCampo(Documento, 'Numero', Dati.FieldByName('NUMERO'));

    if not Dati.FieldByName('RIT_IMPORTO').IsNull then
    begin
      Ritenuta := AggiungiNodo(Documento, 'DatiRitenuta');
      ScriviCampo(Ritenuta, 'TipoRitenuta', Dati.FieldByName('RIT_TIPO'));
      ScriviImporto(Ritenuta, 'ImportoRitenuta', Dati.FieldByName('RIT_IMPORTO'));
      ScriviImporto(Ritenuta, 'AliquotaRitenuta', Dati.FieldByName('RIT_ALIQUOTA'));
      ScriviCampo(Ritenuta, 'CausalePagamento', Dati.FieldByName('RIT_CAUSALE'));
    end;

    if Dati.FieldByName('BOLLO_VIRTUALE').AsBoolean then
    begin
      Bollo := AggiungiNodo(Documento, 'DatiBollo');
      ScriviTesto(Bollo, 'BolloVirtuale', 'SI');
      ScriviImporto(Bollo, 'ImportoBollo', Dati.FieldByName('BOLLO_IMPORTO'));
    end;

    // MANCA_IN_LIBRERIA: DatiCassaPrevidenziale e' ripetibile nel tracciato ma
    // FE_DATI_GENERALI ha il solo IMPORTO_CASSA. Va aggiunta una tabella
    // dedicata prima di poter esporre la cassa previdenziale.

    EsportaScontiMaggiorazioni(Documento, 'ID_DATI_GENERALI', IdDatiGenerali);

    ScriviImporto(Documento, 'ImportoTotaleDocumento', Dati.FieldByName('IMPORTO_TOTALE'));
    ScriviImporto(Documento, 'Arrotondamento', Dati.FieldByName('ARROTONDAMENTO'));
    ScriviCampo(Documento, 'Causale', Dati.FieldByName('CAUSALE'));
    ScriviBooleano(Documento, 'Art73', Dati.FieldByName('ART73'));

    EsportaDocumentiCorrelati(DatiGenerali, IdDatiGenerali);
    EsportaDatiVeicoli(DatiGenerali, IdDatiGenerali);
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaDocumentiCorrelati(const DatiGenerali: IXMLNode; IdDatiGenerali: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
  Indice: Integer;
  NomeNodo: string;
  Tipo: string;
begin
  Dati := ApriQuery(
    'SELECT FE_DOCUMENTO_CORRELATO.* FROM FE_DOCUMENTO_CORRELATO ' +
    'WHERE FE_DOCUMENTO_CORRELATO.ID_DATI_GENERALI = :ID_DATI_GENERALI ' +
    'ORDER BY FE_DOCUMENTO_CORRELATO.TIPO, FE_DOCUMENTO_CORRELATO.ID_DOCUMENTO_CORRELATO',
    [IdDatiGenerali]);
  try
    while not Dati.Eof do
    begin
      Tipo := Dati.FieldByName('TIPO').AsString;

      NomeNodo := '';
      for Indice := Low(TIPI_DOCUMENTO_CORRELATO) to High(TIPI_DOCUMENTO_CORRELATO) do
        if TIPI_DOCUMENTO_CORRELATO[Indice].Tipo = Tipo then
          NomeNodo := TIPI_DOCUMENTO_CORRELATO[Indice].Nodo;

      if NomeNodo <> '' then
      begin
        Nodo := AggiungiNodo(DatiGenerali, NomeNodo);

        if Tipo = 'SAL' then
          ScriviCampo(Nodo, 'RiferimentoFase', Dati.FieldByName('SAL_RIFERIMENTO'))
        else if Tipo = 'FPR' then
        begin
          ScriviCampo(Nodo, 'NumeroFatturaPrincipale', Dati.FieldByName('ID_DOCUMENTO'));
          ScriviData(Nodo, 'DataFatturaPrincipale', Dati.FieldByName('DATA'));
        end
        else
        begin
          ScriviCampo(Nodo, 'RiferimentoNumeroLinea', Dati.FieldByName('RIF_NUMERO_LINEA'));
          ScriviCampo(Nodo, 'IdDocumento', Dati.FieldByName('ID_DOCUMENTO'));
          ScriviData(Nodo, 'Data', Dati.FieldByName('DATA'));
          ScriviCampo(Nodo, 'NumItem', Dati.FieldByName('NUM_ITEM'));
          ScriviCampo(Nodo, 'CodiceCommessaConvenzione', Dati.FieldByName('CODICE_COMMESSA'));
          ScriviCampo(Nodo, 'CodiceCUP', Dati.FieldByName('CODICE_CUP'));
          ScriviCampo(Nodo, 'CodiceCIG', Dati.FieldByName('CODICE_CIG'));
        end;
      end;

      Dati.Next;
    end;
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaDatiVeicoli(const DatiGenerali: IXMLNode; IdDatiGenerali: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_DATI_VEICOLI.* FROM FE_DATI_VEICOLI ' +
    'WHERE FE_DATI_VEICOLI.ID_DATI_GENERALI = :ID_DATI_GENERALI', [IdDatiGenerali]);
  try
    if Dati.IsEmpty then
      Exit;

    Nodo := AggiungiNodo(DatiGenerali, 'DatiVeicoli');
    ScriviData(Nodo, 'Data', Dati.FieldByName('DATA'));
    ScriviCampo(Nodo, 'TotalePercorso', Dati.FieldByName('TOTALE_PERCORSO'));
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaScontiMaggiorazioni(const Padre: IXMLNode;
  const NomeColonna: string; IdRiferimento: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_SCONTO_MAGGIORAZIONE.TIPO, FE_SCONTO_MAGGIORAZIONE.PERCENTUALE, ' +
    '       FE_SCONTO_MAGGIORAZIONE.IMPORTO ' +
    'FROM FE_SCONTO_MAGGIORAZIONE ' +
    'WHERE FE_SCONTO_MAGGIORAZIONE.' + NomeColonna + ' = :ID_RIFERIMENTO ' +
    'ORDER BY FE_SCONTO_MAGGIORAZIONE.ID_SCONTO_MAGGIORAZIONE', [IdRiferimento]);
  try
    while not Dati.Eof do
    begin
      Nodo := AggiungiNodo(Padre, 'ScontoMaggiorazione');
      ScriviCampo(Nodo, 'Tipo', Dati.FieldByName('TIPO'));
      ScriviImporto(Nodo, 'Percentuale', Dati.FieldByName('PERCENTUALE'));
      ScriviImporto(Nodo, 'Importo', Dati.FieldByName('IMPORTO'));

      Dati.Next;
    end;
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaBeniServizi(const Body: IXMLNode; IdFatturaBody: Int64);
var
  Dati: TzFbDataSet;
  DatiBeniServizi: IXMLNode;
  Linea: IXMLNode;
  Codice: IXMLNode;
  AltriDati: IXMLNode;
begin
  DatiBeniServizi := AggiungiNodo(Body, 'DatiBeniServizi');

  Dati := ApriQuery(
    'SELECT FE_BENE_SERVIZIO.* FROM FE_BENE_SERVIZIO ' +
    'WHERE FE_BENE_SERVIZIO.ID_FATTURA_BODY = :ID_FATTURA_BODY ' +
    'ORDER BY FE_BENE_SERVIZIO.NUMERO_LINEA', [IdFatturaBody]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.Create('DettaglioLinee mancante: la fattura non ha righe');

    while not Dati.Eof do
    begin
      Linea := AggiungiNodo(DatiBeniServizi, 'DettaglioLinee');

      ScriviCampo(Linea, 'NumeroLinea', Dati.FieldByName('NUMERO_LINEA'));
      ScriviCampo(Linea, 'TipoCessionePrestazione', Dati.FieldByName('TIPO_CESSIONE'));

      if not Dati.FieldByName('CODICE_VALORE').IsNull then
      begin
        Codice := AggiungiNodo(Linea, 'CodiceArticolo');
        ScriviCampo(Codice, 'CodiceTipo', Dati.FieldByName('CODICE_TIPO'));
        ScriviCampo(Codice, 'CodiceValore', Dati.FieldByName('CODICE_VALORE'));
      end;

      ScriviCampo(Linea, 'Descrizione', Dati.FieldByName('DESCRIZIONE'));
      ScriviImporto(Linea, 'Quantita', Dati.FieldByName('QUANTITA'), 5);
      ScriviCampo(Linea, 'UnitaMisura', Dati.FieldByName('UNITA_MISURA'));
      ScriviData(Linea, 'DataInizioPeriodo', Dati.FieldByName('DATA_INIZIO_PERIODO'));
      ScriviData(Linea, 'DataFinePeriodo', Dati.FieldByName('DATA_FINE_PERIODO'));
      ScriviImporto(Linea, 'PrezzoUnitario', Dati.FieldByName('PREZZO_UNITARIO'), 5);

      EsportaScontiMaggiorazioni(Linea, 'ID_BENE_SERVIZIO',
        Dati.FieldByName('ID_BENE_SERVIZIO').AsLargeInt);

      ScriviImporto(Linea, 'PrezzoTotale', Dati.FieldByName('PREZZO_TOTALE'), 5);
      ScriviImporto(Linea, 'AliquotaIVA', Dati.FieldByName('ALIQUOTA_IVA'));
      ScriviCampo(Linea, 'Ritenuta', Dati.FieldByName('RITENUTA'));
      ScriviCampo(Linea, 'Natura', Dati.FieldByName('NATURA'));
      ScriviCampo(Linea, 'RiferimentoAmministrazione', Dati.FieldByName('RIFERIMENTO_AMMINISTRAZIONE'));

      if not Dati.FieldByName('TIPO_DATO_AGGIUNTIVO').IsNull then
      begin
        AltriDati := AggiungiNodo(Linea, 'AltriDatiGestionali');
        ScriviCampo(AltriDati, 'TipoDato', Dati.FieldByName('TIPO_DATO_AGGIUNTIVO'));
        ScriviCampo(AltriDati, 'RiferimentoTesto', Dati.FieldByName('RIFERIMENTO_TESTO'));
        ScriviImporto(AltriDati, 'RiferimentoNumero', Dati.FieldByName('RIFERIMENTO_NUMERO'), 5);
        ScriviData(AltriDati, 'RiferimentoData', Dati.FieldByName('RIFERIMENTO_DATA'));
      end;

      Dati.Next;
    end;
  finally
    Dati.Free;
  end;

  EsportaRiepilogoIva(DatiBeniServizi, IdFatturaBody);
end;

procedure TFEXmlExport.EsportaRiepilogoIva(const DatiBeniServizi: IXMLNode; IdFatturaBody: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_RIEPILOGO_IVA.* FROM FE_RIEPILOGO_IVA ' +
    'WHERE FE_RIEPILOGO_IVA.ID_FATTURA_BODY = :ID_FATTURA_BODY ' +
    'ORDER BY FE_RIEPILOGO_IVA.ALIQUOTA_IVA', [IdFatturaBody]);
  try
    if Dati.IsEmpty then
      raise EFEExportError.Create('DatiRiepilogo mancante');

    while not Dati.Eof do
    begin
      Nodo := AggiungiNodo(DatiBeniServizi, 'DatiRiepilogo');

      ScriviImporto(Nodo, 'AliquotaIVA', Dati.FieldByName('ALIQUOTA_IVA'));
      ScriviCampo(Nodo, 'Natura', Dati.FieldByName('NATURA'));
      ScriviImporto(Nodo, 'SpeseAccessorie', Dati.FieldByName('SPESE_ACCESSORIE'));
      ScriviImporto(Nodo, 'Arrotondamento', Dati.FieldByName('ARROTONDAMENTO'), 5);
      ScriviImporto(Nodo, 'ImponibileImporto', Dati.FieldByName('IMPONIBILE'));
      ScriviImporto(Nodo, 'Imposta', Dati.FieldByName('IMPOSTA'));
      ScriviCampo(Nodo, 'EsigibilitaIVA', Dati.FieldByName('ESIGIBILITA_IVA'));
      ScriviCampo(Nodo, 'RiferimentoNormativo', Dati.FieldByName('RIFERIMENTO_NORMA'));

      Dati.Next;
    end;
  finally
    Dati.Free;
  end;
end;

procedure TFEXmlExport.EsportaPagamenti(const Body: IXMLNode; IdFatturaBody: Int64);
var
  Testate: TzFbDataSet;
  Dettagli: TzFbDataSet;
  Nodo: IXMLNode;
  Dettaglio: IXMLNode;
begin
  Testate := ApriQuery(
    'SELECT FE_DATI_PAGAMENTO.ID_DATI_PAGAMENTO, FE_DATI_PAGAMENTO.CONDIZIONI ' +
    'FROM FE_DATI_PAGAMENTO ' +
    'WHERE FE_DATI_PAGAMENTO.ID_FATTURA_BODY = :ID_FATTURA_BODY ' +
    'ORDER BY FE_DATI_PAGAMENTO.ID_DATI_PAGAMENTO', [IdFatturaBody]);
  try
    while not Testate.Eof do
    begin
      Nodo := AggiungiNodo(Body, 'DatiPagamento');
      ScriviCampo(Nodo, 'CondizioniPagamento', Testate.FieldByName('CONDIZIONI'));

      Dettagli := ApriQuery(
        'SELECT FE_DETTAGLIO_PAGAMENTO.* FROM FE_DETTAGLIO_PAGAMENTO ' +
        'WHERE FE_DETTAGLIO_PAGAMENTO.ID_DATI_PAGAMENTO = :ID_DATI_PAGAMENTO ' +
        'ORDER BY FE_DETTAGLIO_PAGAMENTO.DATA_SCADENZA, FE_DETTAGLIO_PAGAMENTO.ID_DETTAGLIO_PAGAMENTO',
        [Testate.FieldByName('ID_DATI_PAGAMENTO').AsLargeInt]);
      try
        while not Dettagli.Eof do
        begin
          Dettaglio := AggiungiNodo(Nodo, 'DettaglioPagamento');

          ScriviCampo(Dettaglio, 'Beneficiario', Dettagli.FieldByName('BENEFICIARIO'));
          ScriviCampo(Dettaglio, 'ModalitaPagamento', Dettagli.FieldByName('MODALITA'));
          // MANCA_IN_LIBRERIA: DataRiferimentoTerminiPagamento non ha colonna in
          // FE_DETTAGLIO_PAGAMENTO; se serve va aggiunta alla tabella
          ScriviCampo(Dettaglio, 'GiorniTerminiPagamento', Dettagli.FieldByName('GIORNI_TERMINE_PAGAMENTO'));
          ScriviData(Dettaglio, 'DataScadenzaPagamento', Dettagli.FieldByName('DATA_SCADENZA'));
          ScriviImporto(Dettaglio, 'ImportoPagamento', Dettagli.FieldByName('IMPORTO'));
          ScriviCampo(Dettaglio, 'CodUfficioPostale', Dettagli.FieldByName('CODICE_UFFICIO_POSTALE'));
          ScriviCampo(Dettaglio, 'CognomeQuietanzante', Dettagli.FieldByName('COGNOME_QUIETANZANTE'));
          ScriviCampo(Dettaglio, 'NomeQuietanzante', Dettagli.FieldByName('NOME_QUIETANZANTE'));
          ScriviCampo(Dettaglio, 'CFQuietanzante', Dettagli.FieldByName('CF_QUIETANZANTE'));
          ScriviCampo(Dettaglio, 'TitoloQuietanzante', Dettagli.FieldByName('TITOLO_QUIETANZANTE'));
          ScriviCampo(Dettaglio, 'IstitutoFinanziario', Dettagli.FieldByName('ISTITUTO_FINANZIARIO'));
          ScriviCampo(Dettaglio, 'IBAN', Dettagli.FieldByName('IBAN'));
          ScriviCampo(Dettaglio, 'ABI', Dettagli.FieldByName('ABI'));
          ScriviCampo(Dettaglio, 'CAB', Dettagli.FieldByName('CAB'));
          ScriviCampo(Dettaglio, 'BIC', Dettagli.FieldByName('BIC'));
          ScriviImporto(Dettaglio, 'ScontoPagamentoAnticipato', Dettagli.FieldByName('SCONTO_PAGAMENTO_ANTICIPATO'));
          ScriviData(Dettaglio, 'DataLimitePagamentoAnticipato', Dettagli.FieldByName('DATA_LIMITE_PAGAMENTO_ANTICIPATO'));
          ScriviImporto(Dettaglio, 'PenalitaPagamentiRitardati', Dettagli.FieldByName('PENALITA'));
          ScriviData(Dettaglio, 'DataDecorrenzaPenale', Dettagli.FieldByName('DATA_DECORRENZA_PENALE'));
          ScriviCampo(Dettaglio, 'CodicePagamento', Dettagli.FieldByName('CODICE_PAGAMENTO'));

          Dettagli.Next;
        end;
      finally
        Dettagli.Free;
      end;

      Testate.Next;
    end;
  finally
    Testate.Free;
  end;
end;

procedure TFEXmlExport.EsportaAllegati(const Body: IXMLNode; IdFatturaBody: Int64);
var
  Dati: TzFbDataSet;
  Nodo: IXMLNode;
begin
  Dati := ApriQuery(
    'SELECT FE_ALLEGATO.* FROM FE_ALLEGATO ' +
    'WHERE FE_ALLEGATO.ID_FATTURA_BODY = :ID_FATTURA_BODY ' +
    'ORDER BY FE_ALLEGATO.ID_ALLEGATO', [IdFatturaBody]);
  try
    while not Dati.Eof do
    begin
      Nodo := AggiungiNodo(Body, 'Allegati');

      ScriviCampo(Nodo, 'NomeAttachment', Dati.FieldByName('NOME_ALLEGATO'));
      ScriviCampo(Nodo, 'AlgoritmoCompressione', Dati.FieldByName('ALGORITMO_COMPRESSIONE'));
      ScriviCampo(Nodo, 'FormatoAttachment', Dati.FieldByName('FORMATO_ALLEGATO'));
      ScriviCampo(Nodo, 'DescrizioneAttachment', Dati.FieldByName('DESCRIZIONE_ALLEGATO'));
      // il contenuto e' gia' conservato in base 64 nella colonna ATTACHMENT
      ScriviCampo(Nodo, 'Attachment', Dati.FieldByName('ATTACHMENT'));

      Dati.Next;
    end;
  finally
    Dati.Free;
  end;
end;

end.
