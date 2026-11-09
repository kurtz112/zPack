unit zOffice.utils;

interface

uses
  System.SysUtils,
  System.Classes,
  zOffice.types;

function DefaultExtForFileTypes(FileTypes: TzFileTypes): string;
function FilterForFileTypes(FileTypes: TzFileTypes): string;

implementation

uses
  Vcl.Graphics,
  cxGraphics,
  cxImage;

function GetDialogFilter: string;
var
  cxImage: TcxImage;
  GraphicClass: TGraphicClass;
begin
  cxImage := TcxImage.Create(nil);
  try
    if cxImage.ActiveProperties.CustomFilter <> '' then
      Result := cxImage.ActiveProperties.CustomFilter
    else
    begin
      GraphicClass := cxImage.ActiveProperties.GraphicClass;

      if GraphicClass = nil then
        GraphicClass := TGraphic;

      Result := cxGraphicFilter(GraphicClass);
    end;
  finally
    FreeAndNil(cxImage);
  end;
end;

function FilterForFileTypes(FileTypes: TzFileTypes): string;
begin
  Result := '';

  if ftPdf in FileTypes then
    Result := Result + 'File PDF (*.pdf)|*.pdf|';
  if ftWord in FileTypes then
    Result := Result + 'File Word (*.doc;*.docx)|*.doc;*.docx|';
  if ftExcel in FileTypes then
    Result := Result + 'File Excel (*.xls;*.xlsx)|*.xls;*.xlsx|';
  if ftImage in FileTypes then
    // result := result + 'File immagine (*.bmp;*.jpg;*.jpeg;*.png;*.gif)|*.bmp;*.jpg;*.jpeg;*.png;*.gif|';
    Result := Result + GetDialogFilter;
  if ftMail in FileTypes then
    Result := Result + 'Email (*.eml)|*.eml|';
  if ftTXT in FileTypes then
    Result := Result + 'File di testo (*.txt)|*.txt|';
  if ftXML in FileTypes then
    Result := Result + 'File XML (*.xml)|*.xml|';
  if ftJSON in FileTypes then
    Result := Result + 'File JSON (*.json)|*.json|';

  Result := Result + 'Tutti i file (*.*)|*.*|';
end;

function DefaultExtForFileTypes(FileTypes: TzFileTypes): string;
begin
  Result := '*';

  if ftPdf in FileTypes then
    Result := Result + '*.pdf'
  else
    if ftWord in FileTypes then
      Result := Result + '*.docx'
    else
      if ftExcel in FileTypes then
        Result := Result + '*.xlsx'
      else
        // if ftImage in FileTypes then
        // result := result + 'File immagine (*.bmp;*.jpg;*.jpeg;*.png;*.gif)|*.bmp;*.jpg;*.jpeg;*.png;*.gif|';
        // Result := Result + GetDialogFilter;
        if ftMail in FileTypes then
          Result := Result + '*.eml'
        else
          if ftTXT in FileTypes then
            Result := Result + '*.txt'
          else
            if ftXML in FileTypes then
              Result := Result + '*.xml'
            else
              if ftJSON in FileTypes then
                Result := Result + '*.json';
end;

end.
