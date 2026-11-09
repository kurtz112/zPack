unit zOffice.Word.Utils;

interface

uses
  system.SysUtils,
  system.Classes,
  Vcl.Dialogs,
  dxGDIPlusClasses,
  dxRichEdit.Control,
  dxRichEdit.NativeApi,
  cxGeometry;

type
  TdxRichEditControlHelper = class helper for TdxRichEditControl
  public
    function CreateTable(const RowCount, ColCount: Integer; borderStyle: TdxRichEditTableBorderLineStyle = TdxRichEditTableBorderLineStyle.Dotted): IdxRichEditTable;

    procedure AddParagraph(const styleName: string);

    procedure AddText(const text: string; const AddNewLine: Boolean = true); overload;
    procedure AddText(const styleName, text: string; const AddNewLine: Boolean = true); overload;

    procedure AddImage(dxSmartImage: TdxSmartImage);
    procedure NewLine;
    procedure NewPage;
    procedure ResetMargins(paragraph: IdxRichEditParagraph);

    procedure CopyTable(srcTable, destTable: IdxRichEditTable; const CopyRows: Boolean = true);

    procedure CopyTableBorders(srcBorders, destBorders: IdxRichEditTableBorders);
    procedure CopyTableBorder(srcBorder, destBorder: IdxRichEditTableBorder);

    procedure CopyRow(srcRow, destRow: IdxRichEditTableRow);
    procedure CopyCell(srcCell, destCell: IdxRichEditTableCell);
    procedure CopyCellText(srcCell, destCell: IdxRichEditTableCell);
    procedure CopyCellBorders(srcBorders, destBorders: IdxRichEditTableCellBorders);
    procedure CopyCellBorder(srcBorder, destBorder: IdxRichEditTableCellBorder);

    function SetCellText(Cell: IdxRichEditTableCell; Value: string; const WordWrap: Boolean = false; const VerticalAlignment: TdxRichEditTableCellVerticalAlignment = TdxRichEditTableCellVerticalAlignment.Center): IdxRichEditTableCell; overload;

    function SetCellText(table: IdxRichEditTable; const Row, col: Integer; Value: string; const WordWrap: Boolean = false; const VerticalAlignment: TdxRichEditTableCellVerticalAlignment = TdxRichEditTableCellVerticalAlignment.Center)
      : IdxRichEditTableCell; overload;

    procedure AppendFile(const FileName: string);
  public
  end;

  TFragmentHelper = record
  private const
    sep = '~~~';
  public
    class function FileName(const TemplateFileName, VariableName: string): string; static;
    class function Exists(const TemplateFileName, VariableName: string): Boolean; static;
    class function SearchPattern(const TemplateFileName: string): string; static;
    class function IsFragment(const FileName: string): Boolean; static;

    class function DataSetNameFromFileName(const FileNameNoExt: string): string; static;
    class function MasterNameFromFileName(const FileNameNoExt: string): string; static;
  end;

  // Suffisso " @L:A" (centimetri) accodato al codice del campo INCLUDEPICTURE e
  // riportato nell'Uri dell'immagine: e' la sola memoria della misura voluta,
  // perche' ogni aggiornamento del campo ricarica l'immagine alla misura naturale.
  // Forme ammesse: "@L:A" (larghezza e altezza) e "@L" (solo larghezza, altezza
  // in proporzione all'immagine originale). In scrittura il separatore decimale
  // e' sempre il punto; in lettura si accetta anche la virgola dei template
  // salvati in passato con la cultura locale.
  // Lo stesso marcatore "@" e' usato da "@hidden" (campi nascosti): un suffisso
  // che non e' una misura si lascia intatto.
  TImageSizeTag = record
  public const
    Marcatore = '@';
    Separatore = ':';
  public
    // Testo prima del marcatore, senza spazi ai lati
    class function Strip(const Testo: string): string; static;
    // Testo dopo il marcatore, senza spazi; '' se il marcatore manca
    class function Suffisso(const Testo: string): string; static;
    // True se il suffisso e' una misura; Altezza = 0 quando c'e' solo la larghezza
    class function Parse(const Testo: string; out Larghezza, Altezza: Single): Boolean; static;
    // True se c'e' un suffisso che non e' una misura (es. "@hidden")
    class function HaSuffissoNonMisura(const Testo: string): Boolean; static;
    // Testo ripulito + " @L:A", oppure " @L" se Altezza = 0
    class function Append(const Testo: string; Larghezza, Altezza: Single): string; static;
  end;

  // Misura di un'immagine raccolta dal template prima della stampa unione:
  // Ambito = sotto-documento ('C' corpo, 'H<n>' intestazione, 'F<n>' pie' di
  // pagina della sezione n), Chiave = primo argomento del campo INCLUDEPICTURE
  // normalizzato (senza virgolette, minuscolo), che nel documento unito e'
  // l'Uri dell'immagine. Il suffisso @L:A non entra nell'Uri: DevExpress prende
  // come Uri solo il primo argomento (TdxIncludePictureField.Initialize).
  TzMisuraImmagine = record
    Ambito: string;
    Chiave: string;
    Larghezza: Single;
    Altezza: Single;
  end;

  // Operazioni sulle immagini di un documento (corpo, intestazioni e pie' di
  // pagina di tutte le sezioni), condivise fra editor, visualizzatore e motore
  // di stampa unione. Le misure sono in centimetri: il documento viene portato
  // in centimetri per la durata dell'operazione e poi riportato com'era.
  TzWordImmagini = record
  private
    class function LarghezzaUtile(Section: IdxRichEditSection): Single; static;
    class procedure PerOgniSottoDocumento(Document: IdxRichEditDocument; Azione: TProc<IdxRichEditSubDocument, IdxRichEditSection, string>); static;
    class function ECampoImmagine(SubDoc: IdxRichEditSubDocument; Field: IdxRichEditField; out Codice: string): Boolean; static;
    class function ChiaveImmagine(const CodiceOUri: string): string; static;
    class function Proporzionale(Image: IdxRichEditDocumentImage): Boolean; static;
    class function StessaMisura(const Codice: string; Image: IdxRichEditDocumentImage): Boolean; static;
    class procedure ApplicaMisura(Image: IdxRichEditDocumentImage; Larghezza, Altezza: Single); static;
    class procedure RiduciSottoDocumento(SubDoc: IdxRichEditSubDocument; LarghezzaUtile: Single); static;
    class procedure ApplicaDaiCampi(SubDoc: IdxRichEditSubDocument); static;
    class procedure RaccogliSottoDocumento(SubDoc: IdxRichEditSubDocument; const Ambito: string; var Misure: TArray<TzMisuraImmagine>); static;
    class procedure ApplicaSottoDocumento(SubDoc: IdxRichEditSubDocument; const Ambito: string; const Misure: TArray<TzMisuraImmagine>); static;
    class procedure SincronizzaSottoDocumento(SubDoc: IdxRichEditSubDocument; var Modificato: Boolean); static;
    class procedure SopprimiSottoDocumento(SubDoc: IdxRichEditSubDocument); static;
  public
    // Riduce al vivo pagina, in proporzione, le immagini piu' larghe dello spazio fra i margini
    class procedure RiduciAlVivoPagina(Document: IdxRichEditDocument); static;
    // Template con i campi: applica a ogni immagine la misura del suffisso @L:A
    // del suo campo INCLUDEPICTURE (editor e visualizzatore)
    class procedure ApplicaDimensioni(Document: IdxRichEditDocument); static;
    // Stampa unione, prima del merge: raccoglie dal template le misure dei campi
    // INCLUDEPICTURE, sotto-documento per sotto-documento
    class function RaccogliMisure(Document: IdxRichEditDocument): TArray<TzMisuraImmagine>; static;
    // Stampa unione, dopo il merge e prima del salvataggio: applica le misure al
    // documento unito, dove i campi non ci sono piu'. Abbina per Uri
    // dell'immagine (vale solo in memoria: il docx salvato non lo conserva);
    // le immagini con Uri non abbinate prendono le misure rimaste nell'ordine
    // del template; se nessuna immagine ha l'Uri si va per posizione su tutte,
    // come faceva il vecchio ApplyImageSizes.
    class procedure ApplicaMisure(Document: IdxRichEditDocument; const Misure: TArray<TzMisuraImmagine>); static;
    // Scrive nel codice di ogni campo INCLUDEPICTURE la misura corrente della sua
    // immagine (WYSIWYG). Salta i campi senza immagine (dati uniti spenti), quelli
    // con un suffisso che non e' una misura (@hidden) e quelli gia' allineati
    // entro 0,01 cm. Ritorna True se ha modificato qualcosa.
    class function SincronizzaDimensioni(Document: IdxRichEditDocument): Boolean; static;
    // Toglie il quadratino segnaposto alle immagini vuote dei campi INCLUDEPICTURE
    class procedure SopprimiSegnaposto(Document: IdxRichEditDocument); static;
  end;

function FileNameNoExt(FileName: string): string;
function ExtractTextFromHTML(const html: string): string;

implementation

uses
  System.Math,
  dxCoreGraphics,
  dxCoreClasses,
  dxCharacters,
  dxRichEdit.DocumentModel.ParagraphFormatting,
  dxRichEdit.DocumentServer,
  zMsg;

{ TFragmentHelper }

class function TFragmentHelper.FileName(const TemplateFileName, VariableName: string): string;
var
  Folder: string;
  FileNameNoExt: string;
  FileExt: string;
begin
  Folder := IncludeTrailingPathDelimiter(ExtractFilePath(TemplateFileName));
  FileNameNoExt := ChangeFileExt(ExtractFileName(TemplateFileName), '');
  FileExt := ExtractFileExt(TemplateFileName);

  // consente di differenziare una variabile da un fragment.
  // Se prefissiamo con @ il campo/variabile non verranno coinvolti
  Result := Folder + FileNameNoExt + sep + VariableName.Replace(sep, '') + FileExt;
end;

class function TFragmentHelper.IsFragment(const FileName: string): Boolean;
begin
  Result := FileName.Contains(sep);
end;

class function TFragmentHelper.Exists(const TemplateFileName, VariableName: string): Boolean;
begin
  Result := FileExists(TFragmentHelper.FileName(TemplateFileName, VariableName));
end;

class function TFragmentHelper.SearchPattern(const TemplateFileName: string): string;
begin
  Result := FileNameNoExt(TemplateFileName) + sep + '*.docx';
end;

function FileNameNoExt(FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

{ TImageSizeTag }

class function TImageSizeTag.Strip(const Testo: string): string;
var
  Posizione: Integer;
begin
  Posizione := Testo.IndexOf(Marcatore);

  if Posizione >= 0 then
    Result := Testo.Substring(0, Posizione).Trim
  else
    Result := Testo.Trim;
end;

class function TImageSizeTag.Suffisso(const Testo: string): string;
var
  Posizione: Integer;
begin
  Posizione := Testo.IndexOf(Marcatore);

  if Posizione >= 0 then
    Result := Testo.Substring(Posizione + 1).Trim
  else
    Result := '';
end;

class function TImageSizeTag.Parse(const Testo: string; out Larghezza, Altezza: Single): Boolean;

  function LeggiNumero(const Valore: string; out Numero: Single): Boolean;
  begin
    // prima il punto (forma canonica), poi la virgola dei template salvati con la cultura locale
    Result := Single.TryParse(Valore.Trim, Numero, TFormatSettings.Invariant);

    if not Result then
      Result := Single.TryParse(Valore.Trim.Replace(',', '.'), Numero, TFormatSettings.Invariant);
  end;

var
  Coda: string;
  Posizione: Integer;
begin
  Result := False;
  Larghezza := 0;
  Altezza := 0;

  Coda := Suffisso(Testo);

  if Coda.IsEmpty then
    exit;

  Posizione := Coda.IndexOf(Separatore);

  if Posizione < 0 then
    Result := LeggiNumero(Coda, Larghezza)
  else
    Result := LeggiNumero(Coda.Substring(0, Posizione), Larghezza) and LeggiNumero(Coda.Substring(Posizione + 1), Altezza);

  Result := Result and (Larghezza > 0) and (Altezza >= 0);
end;

class function TImageSizeTag.HaSuffissoNonMisura(const Testo: string): Boolean;
var
  Larghezza, Altezza: Single;
begin
  Result := (not Suffisso(Testo).IsEmpty) and (not Parse(Testo, Larghezza, Altezza));
end;

class function TImageSizeTag.Append(const Testo: string; Larghezza, Altezza: Single): string;

  function Numero(const Valore: Single): string;
  begin
    Result := FormatFloat('0.##', Valore, TFormatSettings.Invariant);
  end;

begin
  Result := Strip(Testo) + ' ' + Marcatore + Numero(Larghezza);

  if Altezza > 0 then
    Result := Result + Separatore + Numero(Altezza);
end;

{ TzWordImmagini }

class function TzWordImmagini.LarghezzaUtile(Section: IdxRichEditSection): Single;
begin
  Result := Section.Page.Width - Section.Margins.Left - Section.Margins.Right;
end;

class procedure TzWordImmagini.PerOgniSottoDocumento(Document: IdxRichEditDocument; Azione: TProc<IdxRichEditSubDocument, IdxRichEditSection, string>);
var
  I: Integer;
  Section: IdxRichEditSection;
  SubDoc: IdxRichEditSubDocument;
begin
  // corpo: unico per tutte le sezioni, la larghezza utile e' quella della prima
  Azione(Document, Document.Sections[0], 'C');

  // intestazioni e pie' di pagina di ogni sezione
  for I := 0 to Document.Sections.Count - 1 do
  begin
    Section := Document.Sections[I];

    SubDoc := Section.BeginUpdateHeader;
    try
      Azione(SubDoc, Section, 'H' + I.ToString);
    finally
      Section.EndUpdateHeader(SubDoc);
    end;

    SubDoc := Section.BeginUpdateFooter;
    try
      Azione(SubDoc, Section, 'F' + I.ToString);
    finally
      Section.EndUpdateFooter(SubDoc);
    end;
  end;
end;

class function TzWordImmagini.ECampoImmagine(SubDoc: IdxRichEditSubDocument; Field: IdxRichEditField; out Codice: string): Boolean;
begin
  Codice := SubDoc.GetText(Field.CodeRange);
  Result := Codice.Trim.StartsWith('INCLUDEPICTURE', True);
end;

// Primo argomento del campo (o Uri dell'immagine) in forma confrontabile:
// via la parola chiave, le virgolette, gli spazi e le maiuscole.
// 'INCLUDEPICTURE "dbimg://HEADER"  @17.8:1.98' e 'dbimg://HEADER' danno entrambi 'dbimg://header'.
class function TzWordImmagini.ChiaveImmagine(const CodiceOUri: string): string;
begin
  Result := TImageSizeTag.Strip(CodiceOUri);

  if Result.StartsWith('INCLUDEPICTURE', True) then
    Result := Result.Substring(Length('INCLUDEPICTURE'));

  Result := Result.Replace('"', '').Trim.ToLower;
end;

// Maniglia d'angolo: i due fattori di scala restano uguali e basta la larghezza
class function TzWordImmagini.Proporzionale(Image: IdxRichEditDocumentImage): Boolean;
begin
  Result := Abs(Image.ScaleX - Image.ScaleY) <= 0.01 * Max(Abs(Image.ScaleX), 0.0001);
end;

class function TzWordImmagini.StessaMisura(const Codice: string; Image: IdxRichEditDocumentImage): Boolean;
var
  Larghezza, Altezza: Single;
begin
  Result := False;

  if not TImageSizeTag.Parse(Codice, Larghezza, Altezza) then
    exit;

  if Abs(Larghezza - Image.Size.cx) > 0.01 then
    exit;

  if Altezza > 0 then
    Result := Abs(Altezza - Image.Size.cy) <= 0.01
  else
    Result := Proporzionale(Image);
end;

class procedure TzWordImmagini.ApplicaMisura(Image: IdxRichEditDocumentImage; Larghezza, Altezza: Single);
begin
  if Altezza <= 0 then
  begin
    // solo larghezza: altezza in proporzione all'immagine originale
    if Image.OriginalSize.cx > 0 then
      Altezza := Larghezza * Image.OriginalSize.cy / Image.OriginalSize.cx
    else
      Altezza := Image.Size.cy;
  end;

  Image.Size := TdxSizeF.Create(Larghezza, Altezza);
end;

class procedure TzWordImmagini.RiduciSottoDocumento(SubDoc: IdxRichEditSubDocument; LarghezzaUtile: Single);
var
  I: Integer;
  Image: IdxRichEditDocumentImage;
begin
  for I := 0 to SubDoc.Images.Count - 1 do
  begin
    Image := SubDoc.Images[I];

    if (Image.Size.cx > LarghezzaUtile) and (Image.Size.cx > 0) then
      Image.Size := TdxSizeF.Create(LarghezzaUtile, Image.Size.cy * LarghezzaUtile / Image.Size.cx);
  end;
end;

class procedure TzWordImmagini.ApplicaDaiCampi(SubDoc: IdxRichEditSubDocument);
var
  I: Integer;
  Codice: string;
  Larghezza, Altezza: Single;
  Images: IdxRichEditReadOnlyDocumentImageCollection;
begin
  for I := 0 to SubDoc.Fields.Count - 1 do
    if ECampoImmagine(SubDoc, SubDoc.Fields[I], Codice) then
      if TImageSizeTag.Parse(Codice, Larghezza, Altezza) then
      begin
        Images := SubDoc.GetImages(SubDoc.Fields[I].Range);

        if assigned(Images) and (Images.Count > 0) then
          ApplicaMisura(Images[0], Larghezza, Altezza);
      end;
end;

class procedure TzWordImmagini.RaccogliSottoDocumento(SubDoc: IdxRichEditSubDocument; const Ambito: string; var Misure: TArray<TzMisuraImmagine>);
var
  I: Integer;
  Codice: string;
  Misura: TzMisuraImmagine;
begin
  // nell'ordine dei campi: e' lo stesso ordine con cui le immagini escono dal merge
  for I := 0 to SubDoc.Fields.Count - 1 do
    if ECampoImmagine(SubDoc, SubDoc.Fields[I], Codice) then
      if TImageSizeTag.Parse(Codice, Misura.Larghezza, Misura.Altezza) then
      begin
        Misura.Ambito := Ambito;
        Misura.Chiave := ChiaveImmagine(Codice);
        Misure := Misure + [Misura];
      end;
end;

class procedure TzWordImmagini.ApplicaSottoDocumento(SubDoc: IdxRichEditSubDocument; const Ambito: string; const Misure: TArray<TzMisuraImmagine>);
var
  Candidate: TArray<TzMisuraImmagine>;
  CandidataUsata: TArray<Boolean>;
  ImmagineAbbinata: TArray<Boolean>;
  Misura: TzMisuraImmagine;
  I: Integer;
  J: Integer;
  Image: IdxRichEditDocumentImage;
  Chiave: string;
  ImmaginiConUri: Integer;

  function CandidataLibera(const Chiave: string): Integer;
  var
    K: Integer;
  begin
    // Chiave vuota = la prima candidata libera qualunque sia la sua chiave
    Result := -1;

    for K := 0 to High(Candidate) do
      if (not CandidataUsata[K]) and (Chiave.IsEmpty or (Candidate[K].Chiave = Chiave)) then
        exit(K);
  end;

begin
  Candidate := nil;

  for Misura in Misure do
    if Misura.Ambito = Ambito then
      Candidate := Candidate + [Misura];

  if Length(Candidate) = 0 then
    exit;

  SetLength(CandidataUsata, Length(Candidate));
  SetLength(ImmagineAbbinata, SubDoc.Images.Count);

  // 1. per chiave: l'Uri dell'immagine e' il primo argomento del campo che l'ha generata
  ImmaginiConUri := 0;

  for I := 0 to SubDoc.Images.Count - 1 do
  begin
    Image := SubDoc.Images[I];
    Chiave := ChiaveImmagine(Image.Uri);

    if Chiave.IsEmpty then
      Continue;

    Inc(ImmaginiConUri);
    J := CandidataLibera(Chiave);

    if J >= 0 then
    begin
      CandidataUsata[J] := True;
      ImmagineAbbinata[I] := True;
      ApplicaMisura(Image, Candidate[J].Larghezza, Candidate[J].Altezza);
    end;
  end;

  // 2. per posizione, solo fra le immagini nate da un campo (hanno l'Uri) e non
  //    ancora abbinate, con le misure rimaste nell'ordine del template. Le
  //    immagini statiche (logo incollato, Uri vuoto) non contano: era l'errore
  //    del vecchio indice progressivo
  if ImmaginiConUri > 0 then
  begin
    for I := 0 to SubDoc.Images.Count - 1 do
    begin
      if ImmagineAbbinata[I] then
        Continue;

      Image := SubDoc.Images[I];

      if ChiaveImmagine(Image.Uri).IsEmpty then
        Continue;

      J := CandidataLibera('');

      if J < 0 then
        Break;

      CandidataUsata[J] := True;
      ImmagineAbbinata[I] := True;
      ApplicaMisura(Image, Candidate[J].Larghezza, Candidate[J].Altezza);
    end;

    exit;
  end;

  // 3. nessuna immagine ha l'Uri (documento ricaricato da file): per posizione su
  //    tutte le immagini, come faceva il vecchio ApplyImageSizes
  for I := 0 to Min(SubDoc.Images.Count, Length(Candidate)) - 1 do
    ApplicaMisura(SubDoc.Images[I], Candidate[I].Larghezza, Candidate[I].Altezza);
end;

class procedure TzWordImmagini.SincronizzaSottoDocumento(SubDoc: IdxRichEditSubDocument; var Modificato: Boolean);
var
  I: Integer;
  Field: IdxRichEditField;
  Codice: string;
  NuovoCodice: string;
  Images: IdxRichEditReadOnlyDocumentImageCollection;
  Image: IdxRichEditDocumentImage;
  Larghezza, Altezza: Single;
  Inizio: IdxRichEditDocumentPosition;
begin
  // a ritroso: ricreare un campo sposta gli indici di quelli che seguono
  for I := SubDoc.Fields.Count - 1 downto 0 do
  begin
    Field := SubDoc.Fields[I];

    if not ECampoImmagine(SubDoc, Field, Codice) then
      Continue;

    if TImageSizeTag.HaSuffissoNonMisura(Codice) then
      Continue;

    Images := SubDoc.GetImages(Field.Range);

    if (not assigned(Images)) or (Images.Count = 0) then
      Continue; // dati uniti spenti: il campo mostra il codice, la misura salvata resta

    Image := Images[0];

    if StessaMisura(Codice, Image) then
      Continue;

    Larghezza := Image.Size.cx;

    if Proporzionale(Image) then
      Altezza := 0
    else
      Altezza := Image.Size.cy;

    NuovoCodice := TImageSizeTag.Append(Codice, Larghezza, Altezza);

    // Il codice di un campo non si riscrive sul posto: si ricrea il campo con il
    // codice nuovo, lo si aggiorna (l'immagine torna alla misura naturale) e gli
    // si riapplica la misura. E' lo stesso giro del vecchio "Salva dimensioni".
    Inizio := Field.Range.Start;
    SubDoc.Delete(Field.Range);
    Field := SubDoc.Fields.CreateField(Inizio, NuovoCodice);
    Field.Update;

    Images := SubDoc.GetImages(Field.Range);

    if assigned(Images) and (Images.Count > 0) then
      ApplicaMisura(Images[0], Larghezza, Altezza);

    Modificato := True;
  end;
end;

class procedure TzWordImmagini.SopprimiSottoDocumento(SubDoc: IdxRichEditSubDocument);
var
  I: Integer;
  Codice: string;
  Images: IdxRichEditReadOnlyDocumentImageCollection;
begin
  for I := 0 to SubDoc.Fields.Count - 1 do
    if ECampoImmagine(SubDoc, SubDoc.Fields[I], Codice) then
    begin
      Images := SubDoc.GetImages(SubDoc.Fields[I].Range);

      if assigned(Images) and (Images.Count > 0) then
        Images[0].Image.SuppressStorePlaceholder := True;
    end;
end;

class procedure TzWordImmagini.RiduciAlVivoPagina(Document: IdxRichEditDocument);
begin
  PerOgniSottoDocumento(Document,
    procedure(SubDoc: IdxRichEditSubDocument; Section: IdxRichEditSection; Ambito: string)
    begin
      RiduciSottoDocumento(SubDoc, LarghezzaUtile(Section));
    end);
end;

class procedure TzWordImmagini.ApplicaDimensioni(Document: IdxRichEditDocument);
var
  UnitaOriginale: TdxRichEditDocumentUnit;
begin
  UnitaOriginale := Document.&Unit;
  Document.&Unit := TdxRichEditDocumentUnit.Centimeter;
  try
    PerOgniSottoDocumento(Document,
      procedure(SubDoc: IdxRichEditSubDocument; Section: IdxRichEditSection; Ambito: string)
      begin
        ApplicaDaiCampi(SubDoc);
      end);
  finally
    Document.&Unit := UnitaOriginale;
  end;
end;

class function TzWordImmagini.RaccogliMisure(Document: IdxRichEditDocument): TArray<TzMisuraImmagine>;
var
  Misure: TArray<TzMisuraImmagine>;
begin
  Misure := nil;

  PerOgniSottoDocumento(Document,
    procedure(SubDoc: IdxRichEditSubDocument; Section: IdxRichEditSection; Ambito: string)
    begin
      RaccogliSottoDocumento(SubDoc, Ambito, Misure);
    end);

  Result := Misure;
end;

class procedure TzWordImmagini.ApplicaMisure(Document: IdxRichEditDocument; const Misure: TArray<TzMisuraImmagine>);
var
  UnitaOriginale: TdxRichEditDocumentUnit;
begin
  if Length(Misure) = 0 then
    exit;

  UnitaOriginale := Document.&Unit;
  Document.&Unit := TdxRichEditDocumentUnit.Centimeter;
  try
    PerOgniSottoDocumento(Document,
      procedure(SubDoc: IdxRichEditSubDocument; Section: IdxRichEditSection; Ambito: string)
      begin
        ApplicaSottoDocumento(SubDoc, Ambito, Misure);
      end);
  finally
    Document.&Unit := UnitaOriginale;
  end;
end;

class function TzWordImmagini.SincronizzaDimensioni(Document: IdxRichEditDocument): Boolean;
var
  UnitaOriginale: TdxRichEditDocumentUnit;
  Modificato: Boolean;
begin
  Modificato := False;

  UnitaOriginale := Document.&Unit;
  Document.&Unit := TdxRichEditDocumentUnit.Centimeter;
  try
    PerOgniSottoDocumento(Document,
      procedure(SubDoc: IdxRichEditSubDocument; Section: IdxRichEditSection; Ambito: string)
      begin
        SincronizzaSottoDocumento(SubDoc, Modificato);
      end);
  finally
    Document.&Unit := UnitaOriginale;
  end;

  Result := Modificato;
end;

class procedure TzWordImmagini.SopprimiSegnaposto(Document: IdxRichEditDocument);
begin
  PerOgniSottoDocumento(Document,
    procedure(SubDoc: IdxRichEditSubDocument; Section: IdxRichEditSection; Ambito: string)
    begin
      SopprimiSottoDocumento(SubDoc);
    end);
end;

function TdxRichEditControlHelper.CreateTable(const RowCount, ColCount: Integer; borderStyle: TdxRichEditTableBorderLineStyle = TdxRichEditTableBorderLineStyle.Dotted): IdxRichEditTable;
begin
  Result := Document.Tables.Add(Document.CaretPosition, RowCount, ColCount);

  Result.Borders.InsideHorizontalBorder.LineStyle := borderStyle;
  Result.Borders.InsideVerticalBorder.LineStyle := borderStyle;

  Result.Borders.Top.LineStyle := borderStyle;
  Result.Borders.left.LineStyle := borderStyle;
  Result.Borders.Right.LineStyle := borderStyle;
  Result.Borders.Bottom.LineStyle := borderStyle;
end;

procedure TdxRichEditControlHelper.AddParagraph(const styleName: string);
var
  paragraph: IdxRichEditParagraph;
  style: IdxRichEditParagraphStyle;
begin
  paragraph := Document.AppendParagraph;

  style := Document.ParagraphStyles[styleName];

  if assigned(style) then
    paragraph.style := style
  else
    ConfirmOk('Stile ' + styleName + ' non trovato', mtWarning);

  paragraph.PageBreakBefore := false;
  paragraph.Alignment := TdxParagraphAlignment.left;
end;

procedure TdxRichEditControlHelper.AddText(const text: string; const AddNewLine: Boolean = true);
begin
  Document.AppendSingleLineText(text);

  if AddNewLine then
    Document.AppendSingleLineText(TdxCharacters.LineBreak);
end;

procedure TdxRichEditControlHelper.NewLine;
begin
  Document.AppendSingleLineText(TdxCharacters.LineBreak);
end;

procedure TdxRichEditControlHelper.AddImage(dxSmartImage: TdxSmartImage);
var
  image: IdxRichEditDocumentImage;
  MaxWidth: single;
begin
  image := Document.AppendImage(dxSmartImage);

  MaxWidth := Document.Sections[0].Page.Width - Document.Sections[0].Margins.left - Document.Sections[0].Margins.Right;

  if image.Size.cx > MaxWidth then
  begin
    image.ScaleX := MaxWidth / image.Size.cx;
    image.ScaleY := image.ScaleX;
  end;
end;

procedure TdxRichEditControlHelper.CopyTable(srcTable, destTable: IdxRichEditTable; const CopyRows: Boolean = true);
var
  Row: Integer;
begin
  assert(assigned(srcTable));
  assert(assigned(destTable));

  // copyborders(  destTable.Borders: IdxRichEditTableBorders read GetBorders;

  CopyTableBorders(srcTable.Borders, destTable.Borders);

  destTable.BottomPadding := srcTable.BottomPadding;
  destTable.Indent := srcTable.Indent;
  destTable.LeftPadding := srcTable.LeftPadding;

  destTable.PreferredWidthType := srcTable.PreferredWidthType;
  destTable.PreferredWidth := srcTable.PreferredWidth;

  destTable.RightPadding := srcTable.RightPadding;

  if srcTable.style <> nil then
    destTable.style := srcTable.style;

  destTable.TableAlignment := srcTable.TableAlignment;
  destTable.TableBackgroundColor := srcTable.TableBackgroundColor;
  destTable.TableCellSpacing := srcTable.TableCellSpacing;
  destTable.TableLayout := srcTable.TableLayout;
  destTable.TableLook := srcTable.TableLook;

  destTable.TopPadding := srcTable.TopPadding;

  if CopyRows then
    for Row := 0 to srcTable.rows.Count - 1 do
      CopyRow(srcTable.rows[Row], destTable.rows[Row]);
end;

function TdxRichEditControlHelper.SetCellText(Cell: IdxRichEditTableCell; Value: string; const WordWrap: Boolean = false; const VerticalAlignment: TdxRichEditTableCellVerticalAlignment = TdxRichEditTableCellVerticalAlignment.Center)
  : IdxRichEditTableCell;
var
  Content: string;
begin
  Result := Cell;

  Content := Document.GetText(Cell.ContentRange);

  if Content.IsEmpty then
    Document.InsertText(Cell.ContentRange.Start, Value)
  else
    Document.Replace(Cell.ContentRange, Value);

  Cell.WordWrap := WordWrap;
  Cell.VerticalAlignment := VerticalAlignment;
end;

function TdxRichEditControlHelper.SetCellText(table: IdxRichEditTable; const Row, col: Integer; Value: string; const WordWrap: Boolean = false;
  const VerticalAlignment: TdxRichEditTableCellVerticalAlignment = TdxRichEditTableCellVerticalAlignment.Center): IdxRichEditTableCell;
begin
  Result := nil;

  if Row < table.rows.Count then
    if col < table.rows[Row].Cells.Count then
      Result := table.Cell(Row, col);

  if assigned(Result) then
    Result := SetCellText(Result, Value, WordWrap, VerticalAlignment);
end;

procedure TdxRichEditControlHelper.ResetMargins(paragraph: IdxRichEditParagraph);
var
  section: IdxRichEditSection;
begin
  section := Document.GetSection(paragraph.Range.Start);
  section.Margins.Top := 0;
  section.Margins.left := 0;
  section.Margins.Right := 0;
  section.Margins.Bottom := 0;
end;

procedure TdxRichEditControlHelper.CopyCell(srcCell, destCell: IdxRichEditTableCell);
var
  paragraph: IdxRichEditParagraph;
  Alignment: TdxRichEditParagraphAlignment;
begin
  assert(assigned(srcCell));
  assert(assigned(destCell));

  CopyCellBorders(srcCell.Borders, destCell.Borders);

  destCell.BackgroundColor := srcCell.BackgroundColor;
  destCell.BottomPadding := srcCell.BottomPadding;
  destCell.HeightType := srcCell.HeightType;
  destCell.Height := srcCell.Height;
  destCell.LeftPadding := srcCell.LeftPadding;
  destCell.PreferredWidthType := srcCell.PreferredWidthType;
  destCell.PreferredWidth := srcCell.PreferredWidth;
  destCell.RightPadding := srcCell.RightPadding;

  if srcCell.style <> nil then
    destCell.style := srcCell.style;

  destCell.TopPadding := srcCell.TopPadding;
  destCell.VerticalAlignment := srcCell.VerticalAlignment;
  destCell.WordWrap := srcCell.WordWrap;

  paragraph := Document.GetParagraph(srcCell.Range.Start);
  if assigned(paragraph) then
  begin
    Alignment := paragraph.Alignment;

    paragraph := Document.GetParagraph(destCell.Range.Start);
    if assigned(paragraph) then
      paragraph.Alignment := Alignment;
  end;

  CopyCellText(srcCell, destCell);
end;

procedure TdxRichEditControlHelper.CopyCellBorders(srcBorders, destBorders: IdxRichEditTableCellBorders);
begin
  assert(assigned(srcBorders));
  assert(assigned(destBorders));

  CopyCellBorder(srcBorders.left, destBorders.left);
  CopyCellBorder(srcBorders.Top, destBorders.Top);
  CopyCellBorder(srcBorders.Right, destBorders.Right);
  CopyCellBorder(srcBorders.Bottom, destBorders.Bottom);
end;

procedure TdxRichEditControlHelper.CopyCellBorder(srcBorder, destBorder: IdxRichEditTableCellBorder);
begin
  assert(assigned(srcBorder));
  assert(assigned(destBorder));

  destBorder.LineColor := srcBorder.LineColor;
  destBorder.LineStyle := srcBorder.LineStyle;
  destBorder.LineThickness := srcBorder.LineThickness;
end;

procedure TdxRichEditControlHelper.CopyCellText(srcCell, destCell: IdxRichEditTableCell);
var
  Content: String;
  srcParagraph, destParagraph: IdxRichEditParagraph;
  srcSection, destSection: IdxRichEditSection;
  srcProperties, destProperties: IdxRichEditCharacterProperties;
begin
  assert(assigned(srcCell));
  assert(assigned(destCell));

  Content := Document.GetText(srcCell.ContentRange);
  Document.InsertText(destCell.ContentRange.Start, Content);

  /// ////////////////////////
  srcParagraph := Document.GetParagraph(srcCell.ContentRange.Start);
  destParagraph := Document.GetParagraph(destCell.ContentRange.Start);

  destParagraph.SpacingBefore := srcParagraph.SpacingBefore;
  destParagraph.SpacingAfter := srcParagraph.SpacingAfter;
  destParagraph.LineSpacingRule := srcParagraph.LineSpacingRule;

  /// ////////////////////////
  srcSection := Document.GetSection(srcParagraph.Range.Start);
  destSection := Document.GetSection(destParagraph.Range.Start);

  destSection.Margins.Top := srcSection.Margins.Top;
  destSection.Margins.left := srcSection.Margins.left;
  destSection.Margins.Right := srcSection.Margins.Right;
  destSection.Margins.Bottom := srcSection.Margins.Bottom;
  /// ////////////////////////

  if Content.IsEmpty then
    exit;

  srcProperties := Document.BeginUpdateCharacters(srcCell.ContentRange);
  try
  finally
    Document.EndUpdateCharacters(srcProperties);
  end;

  destProperties := Document.BeginUpdateCharacters(destCell.ContentRange);
  try
    destProperties.AllCaps := srcProperties.AllCaps;
    destProperties.BackColor := srcProperties.BackColor;
    destProperties.Bold := srcProperties.Bold;
    destProperties.FontName := srcProperties.FontName;
    destProperties.FontSize := srcProperties.FontSize;
    destProperties.ForeColor := srcProperties.ForeColor;
    destProperties.Hidden := srcProperties.Hidden;
    destProperties.Italic := srcProperties.Italic;
    destProperties.Strikeout := srcProperties.Strikeout;
    destProperties.StrikeoutColor := srcProperties.StrikeoutColor;
    destProperties.Subscript := srcProperties.Subscript;
    destProperties.Superscript := srcProperties.Superscript;
    destProperties.Underline := srcProperties.Underline;
    destProperties.UnderlineColor := srcProperties.UnderlineColor;
  finally
    Document.EndUpdateCharacters(destProperties);
  end;
end;

procedure TdxRichEditControlHelper.CopyRow(srcRow, destRow: IdxRichEditTableRow);
var
  i: Integer;
  srcCell, destCell: IdxRichEditTableCell;
begin
  assert(assigned(srcRow));
  assert(assigned(destRow));

  destRow.HeightType := srcRow.HeightType;
  destRow.Height := srcRow.Height;
  destRow.TableRowAlignment := srcRow.TableRowAlignment;

  for i := 0 to srcRow.Cells.Count - 1 do
  begin
    srcCell := srcRow.Cells[i];
    destCell := destRow.Cells[i];
    CopyCell(srcCell, destCell);
  end;
end;

procedure TdxRichEditControlHelper.CopyTableBorder(srcBorder, destBorder: IdxRichEditTableBorder);
begin
  assert(assigned(srcBorder));
  assert(assigned(destBorder));

  destBorder.LineColor := srcBorder.LineColor;
  destBorder.LineStyle := srcBorder.LineStyle;
  destBorder.LineThickness := srcBorder.LineThickness;
end;

procedure TdxRichEditControlHelper.CopyTableBorders(srcBorders, destBorders: IdxRichEditTableBorders);
begin
  assert(assigned(srcBorders));
  assert(assigned(destBorders));

  CopyTableBorder(srcBorders.InsideHorizontalBorder, destBorders.InsideHorizontalBorder);
  CopyTableBorder(srcBorders.InsideVerticalBorder, destBorders.InsideVerticalBorder);
  CopyTableBorder(srcBorders.Bottom, destBorders.Bottom);
  CopyTableBorder(srcBorders.left, destBorders.left);
  CopyTableBorder(srcBorders.Right, destBorders.Right);
  CopyTableBorder(srcBorders.Top, destBorders.Top);
end;

procedure TdxRichEditControlHelper.NewPage;
begin
  Document.AppendSingleLineText(TdxCharacters.PageBreak);
end;

function ExtractTextFromHTML(const html: string): string;
var
  Stream: TStringStream;
  dxRichEditDocumentServer: TdxRichEditDocumentServer;
begin
  Stream := TStringStream.Create(html);
  try
    dxRichEditDocumentServer := TdxRichEditDocumentServer.Create(nil);
    try
      dxRichEditDocumentServer.LoadDocument(Stream, TdxRichEditDocumentFormat.html);
      Result := dxRichEditDocumentServer.Document.text;
    finally
      FreeAndNil(dxRichEditDocumentServer);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TdxRichEditControlHelper.AddText(const styleName, text: string; const AddNewLine: Boolean = true);
begin
  AddParagraph(styleName);
  AddText(text, AddNewLine);
end;

procedure TdxRichEditControlHelper.AppendFile(const FileName: string);
begin
  Document.AppendSingleLineText(TdxCharacters.PageBreak);
  Document.AppendDocumentContent(FileName, TdxRichEditDocumentFormat.OpenXML);
end;

class function TFragmentHelper.DataSetNameFromFileName(const FileNameNoExt: string): string;
var
  idx: Integer;
begin
  idx := FileNameNoExt.IndexOf(sep);
  if idx >= 0 then
    Result := FileNameNoExt.Substring(idx + Length(sep))
  else
    Result := '';
end;

class function TFragmentHelper.MasterNameFromFileName(const FileNameNoExt: string): string;
var
  idx: Integer;
begin
  idx := FileNameNoExt.IndexOf(sep);
  if idx >= 0 then
    Result := FileNameNoExt.Substring(0, idx)
  else
    Result := FileNameNoExt;
end;

end.

  zOffice.Word.Form
