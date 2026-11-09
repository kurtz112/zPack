// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-11-02
// ---------------------------------------------------------------------------
unit Test.zOffice;

// Test DUnitX del punto di ingresso di zOffice (zOffice.pas e, di
// zOffice.types.pas, il tipo TzFileType con il suo helper): specifica ZOFF-OFF,
// "Punto di ingresso di zOffice.md".
//
// Si provano solo le parti che non aprono finestre: il riconoscimento del tipo
// dal nome, i codici di una lettera, l'indice dell'icona, ViewFile con tipo
// nullo o non gestito (apre col programma di sistema, sostituito da
// SystemOpenProc), i parametri di ViewFileWord e CheckSMTPServerParams. I
// visualizzatori sono finestre modali e restano alla specifica e al collaudo con
// la sonda.
//
// Le variabili globali zOffice.SMTPServerParams e zOffice.SystemOpenProc sono
// stato condiviso: Setup le salva e TearDown le ripristina.
//
// Divergenze corrette: DIV-OFF-1 (tipo non gestito aperto col programma di
// sistema) e DIV-OFF-3 (ViewFileWord con formato rilevato dal contenuto).

interface

uses
  System.SysUtils,
  System.Classes,
  dxRichEdit.NativeApi,
  DUnitX.TestFramework,
  zOffice.types,
  zOffice;

type
  [TestFixture]
  TTestPuntoDiIngressoZOffice = class
  private
    FParametriSalvati: TSMTPServerParams;
    FApriSistemaSalvata: TProc<string>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // ZOFF-OFF-001
    [Test]
    procedure FromFileName_EstensioniNote_TipoAtteso;
    // ZOFF-OFF-001
    [Test]
    procedure FromFileName_MaiuscoleEPercorso_Riconosce;
    // ZOFF-OFF-001
    [Test]
    procedure FromFileName_EstensioneIgnotaONessuna_Nessuno;
    // ZOFF-OFF-001
    [Test]
    procedure FromFileName_CartellaConEstensioneENomeSenza_Nessuno;
    // ZOFF-OFF-001
    [Test]
    procedure TuttiITipi_EscluseNessuno_InZAllFileTypes;
    // ZOFF-OFF-002
    [Test]
    procedure AsString_LeggeEScriveIlCodiceDiUnaLettera;
    // ZOFF-OFF-002
    [Test]
    procedure AsString_CodiceConSpaziEMinuscole_Riconosciuto;
    // ZOFF-OFF-002
    [Test]
    procedure AsString_CodiceSconosciutoOVuoto_Nessuno;
    // ZOFF-OFF-002
    [Test]
    procedure ImageIndex_PerOgniTipo_IndiceDellIcona;
    // ZOFF-OFF-003
    [Test]
    procedure ViewFile_NomeVuoto_NonApreNiente;
    // DIV-OFF-1: corretta, i tipi non gestiti si aprono col programma di sistema
    // ZOFF-OFF-003
    [Test]
    procedure Divergenza_DIV_OFF_1_EstensioneNonGestita_ApreColProgrammaDiSistema;
    // ZOFF-OFF-003
    [Test]
    procedure ViewFile_TipoNessunoEsplicito_ApreColProgrammaDiSistema;
    // DIV-OFF-3: corretta, il formato Word e' rilevato dal contenuto
    // ZOFF-OFF-007
    [Test]
    procedure Divergenza_DIV_OFF_3_ViewFileWord_FormatoRilevatoDalContenuto;
    // ZOFF-OFF-006
    [Test]
    procedure CheckSMTPServerParams_ParametriNonConfigurati_Solleva;
    // ZOFF-OFF-006
    [Test]
    procedure CheckSMTPServerParams_ParametriValidi_NonSolleva;
    // ZOFF-OFF-006
    [Test]
    procedure CheckSMTPServerParams_PortaNonImpostata_Solleva;
  end;

implementation

type
  TCoppiaEstensione = record
    Nome: string;
    Tipo: TzFileType;
  end;

procedure TTestPuntoDiIngressoZOffice.Setup;
begin
  FParametriSalvati := zOffice.SMTPServerParams;
  FApriSistemaSalvata := zOffice.SystemOpenProc;
end;

procedure TTestPuntoDiIngressoZOffice.TearDown;
begin
  zOffice.SMTPServerParams := FParametriSalvati;
  zOffice.SystemOpenProc := FApriSistemaSalvata;
end;

procedure TTestPuntoDiIngressoZOffice.FromFileName_EstensioniNote_TipoAtteso;
const
  Coppie: array [0 .. 14] of TCoppiaEstensione = (
    (Nome: 'a.pdf'; Tipo: ftPdf),
    (Nome: 'a.doc'; Tipo: ftWord),
    (Nome: 'a.docx'; Tipo: ftWord),
    (Nome: 'a.rtf'; Tipo: ftWord),
    (Nome: 'a.xls'; Tipo: ftExcel),
    (Nome: 'a.xlsx'; Tipo: ftExcel),
    (Nome: 'a.csv'; Tipo: ftExcel),
    (Nome: 'a.bmp'; Tipo: ftImage),
    (Nome: 'a.png'; Tipo: ftImage),
    (Nome: 'a.jpeg'; Tipo: ftImage),
    (Nome: 'a.jpg'; Tipo: ftImage),
    (Nome: 'a.eml'; Tipo: ftMail),
    (Nome: 'a.txt'; Tipo: ftTXT),
    (Nome: 'a.xml'; Tipo: ftXML),
    (Nome: 'a.json'; Tipo: ftJSON));
var
  Indice: Integer;
begin
  for Indice := Low(Coppie) to High(Coppie) do
    Assert.IsTrue(TzFileType.FromFileName(Coppie[Indice].Nome) = Coppie[Indice].Tipo, Coppie[Indice].Nome);
end;

procedure TTestPuntoDiIngressoZOffice.FromFileName_MaiuscoleEPercorso_Riconosce;
begin
  Assert.IsTrue(TzFileType.FromFileName('C:\Dati\Lettera.DOCX') = ftWord);
  Assert.IsTrue(TzFileType.FromFileName('relazione.Pdf') = ftPdf);
  Assert.IsTrue(TzFileType.FromFileName('C:\cartella.con.punti\nota.TXT') = ftTXT);
  Assert.IsTrue(TzFileType.FromFileName('archivio.versione.2.json') = ftJSON);
end;

procedure TTestPuntoDiIngressoZOffice.FromFileName_EstensioneIgnotaONessuna_Nessuno;
const
  Nomi: array [0 .. 8] of string = ('foto.gif', 'registro.log', 'foglio.xlsm', 'archivio.zip', 'senzaestensione', '',
    'punto.', '.', 'messaggio.msg');
var
  Indice: Integer;
begin
  for Indice := Low(Nomi) to High(Nomi) do
    Assert.IsTrue(TzFileType.FromFileName(Nomi[Indice]) = ftNone, '"' + Nomi[Indice] + '"');
end;

procedure TTestPuntoDiIngressoZOffice.FromFileName_CartellaConEstensioneENomeSenza_Nessuno;
begin
  // si guarda l'estensione dell'ultimo elemento, non quella di una cartella
  Assert.IsTrue(TzFileType.FromFileName('C:\posta.eml\nome') = ftNone);
end;

procedure TTestPuntoDiIngressoZOffice.TuttiITipi_EscluseNessuno_InZAllFileTypes;
var
  Tipo: TzFileType;
begin
  Assert.IsFalse(ftNone in zAllFileTypes, 'ftNone non e'' un tipo da aprire');
  for Tipo := Succ(Low(TzFileType)) to High(TzFileType) do
    Assert.IsTrue(Tipo in zAllFileTypes, 'tipo ' + Ord(Tipo).ToString);
end;

procedure TTestPuntoDiIngressoZOffice.AsString_LeggeEScriveIlCodiceDiUnaLettera;
var
  Ritorno: TzFileType;
  Tipo: TzFileType;
begin
  Tipo := ftNone;
  Assert.AreEqual('', Tipo.AsString);
  Tipo := ftPdf;
  Assert.AreEqual('P', Tipo.AsString);
  Tipo := ftWord;
  Assert.AreEqual('W', Tipo.AsString);
  Tipo := ftExcel;
  Assert.AreEqual('E', Tipo.AsString);
  Tipo := ftImage;
  Assert.AreEqual('I', Tipo.AsString);
  Tipo := ftMail;
  Assert.AreEqual('M', Tipo.AsString);
  Tipo := ftTXT;
  Assert.AreEqual('T', Tipo.AsString);
  Tipo := ftXML;
  Assert.AreEqual('X', Tipo.AsString);
  Tipo := ftJSON;
  Assert.AreEqual('J', Tipo.AsString);

  // andata e ritorno per ogni tipo
  for Tipo := Low(TzFileType) to High(TzFileType) do
  begin
    Ritorno := ftNone;
    Ritorno.AsString := Tipo.AsString;
    Assert.IsTrue(Ritorno = Tipo, 'andata e ritorno del tipo ' + Ord(Tipo).ToString);
  end;
end;

procedure TTestPuntoDiIngressoZOffice.AsString_CodiceConSpaziEMinuscole_Riconosciuto;
var
  Tipo: TzFileType;
begin
  Tipo := ftNone;
  Tipo.AsString := ' w ';
  Assert.IsTrue(Tipo = ftWord);
  Tipo.AsString := 'p';
  Assert.IsTrue(Tipo = ftPdf);
  Tipo.AsString := #9'j'#9;
  Assert.IsTrue(Tipo = ftJSON);
end;

procedure TTestPuntoDiIngressoZOffice.AsString_CodiceSconosciutoOVuoto_Nessuno;
var
  Tipo: TzFileType;
begin
  Tipo := ftPdf;
  Tipo.AsString := 'Z';
  Assert.IsTrue(Tipo = ftNone, 'codice sconosciuto');
  Tipo := ftPdf;
  Tipo.AsString := '';
  Assert.IsTrue(Tipo = ftNone, 'codice vuoto');
  Tipo := ftPdf;
  Tipo.AsString := 'PW';
  Assert.IsTrue(Tipo = ftNone, 'due lettere non sono un codice');
end;

procedure TTestPuntoDiIngressoZOffice.ImageIndex_PerOgniTipo_IndiceDellIcona;
var
  Tipo: TzFileType;
begin
  Tipo := ftNone;
  Assert.AreEqual(0, Tipo.ImageIndex);
  Tipo := ftPdf;
  Assert.AreEqual(1, Tipo.ImageIndex);
  Tipo := ftWord;
  Assert.AreEqual(2, Tipo.ImageIndex);
  Tipo := ftExcel;
  Assert.AreEqual(3, Tipo.ImageIndex);
  Tipo := ftImage;
  Assert.AreEqual(4, Tipo.ImageIndex);
  Tipo := ftMail;
  Assert.AreEqual(5, Tipo.ImageIndex);
  Tipo := ftTXT;
  Assert.AreEqual(6, Tipo.ImageIndex);
  Tipo := ftXML;
  Assert.AreEqual(7, Tipo.ImageIndex);
  Tipo := ftJSON;
  Assert.AreEqual(8, Tipo.ImageIndex);
end;

procedure TTestPuntoDiIngressoZOffice.ViewFile_NomeVuoto_NonApreNiente;
var
  Chiamate: Integer;
begin
  Chiamate := 0;
  zOffice.SystemOpenProc := procedure(NomeFile: string)
    begin
      Inc(Chiamate);
    end;

  zOffice.ViewFile(ftNone, '', True);
  zOffice.ViewFile('');

  Assert.AreEqual(0, Chiamate);
end;

procedure TTestPuntoDiIngressoZOffice.Divergenza_DIV_OFF_1_EstensioneNonGestita_ApreColProgrammaDiSistema;
var
  Aperti: TStringList;
  Nome: string;
begin
  // DIV-OFF-1: i file con estensione non gestita si aprono col programma
  // associato da Windows; qui il programma e' sostituito da SystemOpenProc.
  Aperti := TStringList.Create;
  try
    zOffice.SystemOpenProc := procedure(NomeFile: string)
      begin
        Aperti.Add(NomeFile);
      end;

    for Nome in ['C:\Dati\archivio.zip', 'allegato.msg', 'foto.gif', 'pagina.htm', 'registro.log', 'senzaestensione'] do
      zOffice.ViewFile(Nome, True);

    Assert.AreEqual(6, Aperti.Count);
    Assert.AreEqual('C:\Dati\archivio.zip', Aperti[0]);
    Assert.AreEqual('allegato.msg', Aperti[1]);
    Assert.AreEqual('senzaestensione', Aperti[5]);
  finally
    FreeAndNil(Aperti);
  end;
end;

procedure TTestPuntoDiIngressoZOffice.ViewFile_TipoNessunoEsplicito_ApreColProgrammaDiSistema;
var
  Aperto: string;
begin
  Aperto := '';
  zOffice.SystemOpenProc := procedure(NomeFile: string)
    begin
      Aperto := NomeFile;
    end;

  zOffice.ViewFile(ftNone, 'C:\Dati\qualcosa.xyz');

  Assert.AreEqual('C:\Dati\qualcosa.xyz', Aperto);
end;

procedure TTestPuntoDiIngressoZOffice.Divergenza_DIV_OFF_3_ViewFileWord_FormatoRilevatoDalContenuto;
var
  Parametri: TWordParams;
begin
  // DIV-OFF-3: il formato non e' piu' OpenXML fisso, cosi' .doc e .rtf si aprono
  Parametri := zOffice.NewWordParamsForFile('C:\Dati\vecchia.doc', True);

  Assert.IsTrue(Parametri.DocumentFormat = TdxRichEditDocumentFormat.Undefined, 'formato');
  Assert.AreEqual('C:\Dati\vecchia.doc', Parametri.FileName);
  Assert.IsTrue(Parametri.ReadOnly, 'sola lettura');
end;

procedure TTestPuntoDiIngressoZOffice.CheckSMTPServerParams_ParametriNonConfigurati_Solleva;
var
  Messaggio: string;
begin
  zOffice.SMTPServerParams.Init;
  Messaggio := '';
  try
    zOffice.CheckSMTPServerParams;
  except
    on E: Exception do
      Messaggio := E.Message;
  end;
  Assert.AreEqual('Parametri SMTP non configurati.', Messaggio);
end;

procedure TTestPuntoDiIngressoZOffice.CheckSMTPServerParams_ParametriValidi_NonSolleva;
begin
  zOffice.SMTPServerParams.Init;
  zOffice.SMTPServerParams.Host := 'smtp.prova.invalid';
  zOffice.SMTPServerParams.Port := 25;

  Assert.WillNotRaise(
    procedure
    begin
      zOffice.CheckSMTPServerParams;
    end);
end;

procedure TTestPuntoDiIngressoZOffice.CheckSMTPServerParams_PortaNonImpostata_Solleva;
begin
  zOffice.SMTPServerParams.Init;
  zOffice.SMTPServerParams.Host := 'smtp.prova.invalid';

  Assert.WillRaise(
    procedure
    begin
      zOffice.CheckSMTPServerParams;
    end,
    Exception);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPuntoDiIngressoZOffice);

end.
