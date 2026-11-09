unit zz.DataSetClassGenerator;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  zz.GenericCollection;

type
  TFramework = (VCL, FMX);

  TDataSetClass = class(TCollectionItem)
  private
    FDataSet: TDataSet;
    FClassName: string;
    FEnabled: boolean;
  public
    constructor Create(Collection: TCollection); overload; override;
    procedure Assign(Source: TPersistent); override;

    function FullClassname: string;
  public
    property ClassName: string read FClassName write FClassName;
    property DataSet: TDataSet read FDataSet write FDataSet;
    property Enabled: boolean read FEnabled write FEnabled;
  end;

  TDataSetClassGenerator = class
  private
    FAdditionalUnits: string;
    FAncestorClassName: string;
    FUnitName: string;
    FDataSetClasses: TzGenericCollection<TDataSetClass>;
    FFramework: TFramework;
    FUseNullables: boolean;
    function IsMemo(Field: TField): boolean;
    function IsBitmap(Field: TField): boolean;
    function GetPropertyType(Field: TField): string;
    function HasBlob(DataSet: TDataSet): boolean;
    function GetImplementation: String;
    function GetEnd: String;
  private
    function WriteUnitHeader(const UnitName: string; const AdditionalUnits: string): string;
    function WriteInterface(DataSetClass: TDataSetClass): String;
    function WriteImplementation(DataSetClass: TDataSetClass): String;
  public
    Constructor Create;
    Destructor Destroy; override;

    procedure AddDataSet(DataSet: TDataSet; const ClassName: string; const Enabled: boolean = true);
    function DataSetExist(DataSet: TDataSet): boolean;

    property DataSetClasses: TzGenericCollection<TDataSetClass> read FDataSetClasses;
  public
    procedure SaveToStrings(Strings: TStrings);
    procedure SaveToFile(const FileName: string);
    procedure SaveToFolder(const Folder: string);
  public
    property UnitName: string read FUnitName write FUnitName;
    property AdditionalUnits: string read FAdditionalUnits write FAdditionalUnits;
    property AncestorClass: string read FAncestorClassName write FAncestorClassName;
  public
    property Framework: TFramework read FFramework write FFramework;
    property UseNullables: boolean read FUseNullables write FUseNullables;
  end;

implementation

uses
  System.IOUtils;

function TDataSetClass.FullClassname: string;
begin
  result := 'T' + ClassName;
end;

constructor TDataSetClass.Create(Collection: TCollection);
begin
  inherited;
  FEnabled := true;
  FDataSet := nil;
  FClassName := '';
end;

procedure TDataSetClass.Assign(Source: TPersistent);
var
  item: TDataSetClass;
begin
  inherited;
  if Source is TDataSetClass then
  begin
    item := Source as TDataSetClass;
    FEnabled := item.Enabled;
    FDataSet := item.DataSet;
    FClassName := item.FullClassname;
  end
  else
    inherited Assign(Source);
end;

{ TDataSetClassGenerator }

constructor TDataSetClassGenerator.Create;
begin
  inherited;
  FFramework := TFramework.VCL;
  FUseNullables := true;
  FAdditionalUnits := '';
  FAncestorClassName := '';
  FUnitName := '';
  FDataSetClasses := TzGenericCollection<TDataSetClass>.Create(TDataSetClass);
end;

function TDataSetClassGenerator.DataSetExist(DataSet: TDataSet): boolean;
var
  item: TDataSetClass;
begin
  result := False;

  for item in DataSetClasses do
    if item.DataSet = DataSet then
    begin
      result := true;
      exit;
    end;
end;

destructor TDataSetClassGenerator.Destroy;
begin
  FreeAndNil(FDataSetClasses);
  inherited;
end;

procedure TDataSetClassGenerator.AddDataSet(DataSet: TDataSet; const ClassName: string; const Enabled: boolean = true);
var
  item: TDataSetClass;
begin
  item := DataSetClasses.Add;
  item.Enabled := Enabled;
  item.DataSet := DataSet;
  item.ClassName := ClassName;
end;

function TDataSetClassGenerator.IsBitmap(Field: TField): boolean;
begin
  result := (Field is TBlobField) and not IsMemo(Field);
end;

function TDataSetClassGenerator.IsMemo(Field: TField): boolean;
begin
  result := (Field is TMemoField) or (Field is TWideMemoField);
end;

function TDataSetClassGenerator.GetPropertyType(Field: TField): string;
begin
  assert(assigned(Field));

  if UseNullables then
  begin

    result := 'TNullableString';

    if Field is TIntegerField then
      result := 'TNullableInteger'
    else
      if Field is TLargeIntField then
        result := 'TNullableInt64'
      else
        if Field is TNumericField then
          result := 'TNullableDouble'
        else
          if Field is TBooleanField then
            result := 'TNullableBoolean'
          else
            if Field is TDateTimeField then
              result := 'TNullableDateTime'
            else
              if Field is TSQLTimeStampField then
                result := 'TNullableDateTime'
              else
                if Field is TWideStringField then
                  result := 'TNullableWideString'
                else
                  if Field is TWideMemoField then
                    result := 'TBlobStrings'
                  else
                    if Field is TMemoField then
                      result := 'TBlobStrings'
                    else
                      if Field is TBlobField then
                        result := 'TBlobImage';
  end
  else
  begin
    result := 'string';

    if Field is TIntegerField then
      result := 'integer'
    else
      if Field is TNumericField then
        result := 'double'
      else
        if Field is TBooleanField then
          result := 'boolean'
        else
          if Field is TDateTimeField then
            result := 'TDateTime'
          else
            if Field is TSQLTimeStampField then
              result := 'TDateTime'
            else
              if Field is TMemoField then
                result := 'TBlobStrings'
              else
                if Field is TWideMemoField then
                  result := 'TBlobStrings'
                else
                  if Field is TBlobField then
                    result := 'TBlobImage';
  end;
end;

function TDataSetClassGenerator.HasBlob(DataSet: TDataSet): boolean;
var
  Field: TField;
begin
  assert(assigned(DataSet));

  result := False;

  for Field in DataSet.Fields do
    if Field is TBlobField then
      exit(true);
end;

function TDataSetClassGenerator.GetImplementation: String;
begin
  result := 'implementation';
end;

function TDataSetClassGenerator.GetEnd: String;
begin
  result := 'end.';
end;

function TDataSetClassGenerator.WriteUnitHeader(const UnitName: string; const AdditionalUnits: string): string;
begin
  result := 'unit ' + UnitName + ';' + sLineBreak + sLineBreak;
  result := result + 'interface ' + sLineBreak + sLineBreak;
  result := result + 'uses' + sLineBreak;
  result := result + '  System.SysUtils,' + sLineBreak;
  result := result + '  System.Classes,' + sLineBreak;
  result := result + '  zz.Blob,' + sLineBreak;

  if Framework = TFramework.VCL then
    result := result + '  zz.Blob.Vcl,' + sLineBreak
  else
    result := result + '  zz.Blob.FMX,' + sLineBreak;

  if AdditionalUnits.isEmpty then
    result := result + '  zz.Nullable;' + sLineBreak
  else
  begin
    result := result + '  zz.Nullable,' + sLineBreak;
    result := result + '  ' + AdditionalUnits + ';' + sLineBreak;
  end;

  if DataSetClasses.Count > 0 then
  begin
    result := result + sLineBreak;
    result := result + 'type';
  end;
end;

function TDataSetClassGenerator.WriteInterface(DataSetClass: TDataSetClass): String;
var
  Field: TField;
  PropertyType: string;
begin
  result := '  ' + DataSetClass.FullClassname + ' = class(' + AncestorClass + ')' + sLineBreak;
  result := result + '  private' + sLineBreak;

  for Field in DataSetClass.DataSet.Fields do
  begin
    PropertyType := GetPropertyType(Field);
    result := result + '    F' + Field.FieldName + ': ' + PropertyType + ';' + sLineBreak;
  end;

  if HasBlob(DataSetClass.DataSet) then
  begin
    result := result + '  private' + sLineBreak;
    for Field in DataSetClass.DataSet.Fields do
      if Field is TBlobField then
      begin
        PropertyType := GetPropertyType(Field);
        result := result + '    procedure Set' + Field.FieldName + '(Value: ' + PropertyType + ');' + sLineBreak;
      end;

    result := result + '  public' + sLineBreak;
    result := result + '    constructor  Create; override;' + sLineBreak;
    result := result + '    destructor Destroy; override;' + sLineBreak;
  end;

  result := result + '  public' + sLineBreak;

  for Field in DataSetClass.DataSet.Fields do
  begin
    PropertyType := GetPropertyType(Field);

    if Field is TBlobField then

      result := result + '    property ' + Field.FieldName + ': ' + PropertyType + ' read F' + Field.FieldName + ' write Set' + Field.FieldName + ';' + sLineBreak
    else
      result := result + '    property ' + Field.FieldName + ': ' + PropertyType + ' read F' + Field.FieldName + ' write F' + Field.FieldName + ';' + sLineBreak;
  end;

  result := result + '  end;' + sLineBreak;
end;

function TDataSetClassGenerator.WriteImplementation(DataSetClass: TDataSetClass): String;
var
  Field: TField;
  PropertyType: string;
begin
  result := '';

  if HasBlob(DataSetClass.DataSet) then
  begin

    // Set
    for Field in DataSetClass.DataSet.Fields do
      if Field is TBlobField then
      begin
        PropertyType := GetPropertyType(Field);
        result := result + ' procedure ' + DataSetClass.FullClassname + '.Set' + Field.FieldName + '(Value: ' + PropertyType + ');' + sLineBreak;
        result := result + ' begin' + sLineBreak;
        result := result + '   F' + Field.FieldName + '.Assign(Value);' + sLineBreak;
        result := result + ' end;' + sLineBreak + sLineBreak;
      end;

    // constructor
    result := result + ' constructor ' + DataSetClass.FullClassname + '.Create;' + sLineBreak;
    result := result + ' begin' + sLineBreak;
    result := result + '   inherited;' + sLineBreak;
    for Field in DataSetClass.DataSet.Fields do
      if Field is TBlobField then
      begin
        if IsMemo(Field) then
          result := result + '   F' + Field.FieldName + ' := TBlobStrings.Create;' + sLineBreak
        else
          if IsBitmap(Field) then
            result := result + '   F' + Field.FieldName + ' := TBlobImage.Create;' + sLineBreak
      end;
    result := result + ' end;' + sLineBreak + sLineBreak;

    // destructor
    result := result + ' destructor ' + DataSetClass.FullClassname + '.Destroy;' + sLineBreak;
    result := result + ' begin' + sLineBreak;
    result := result + '   inherited;' + sLineBreak;
    for Field in DataSetClass.DataSet.Fields do
      if Field is TBlobField then
        result := result + '   FreeAndNil(F' + Field.FieldName + ');' + sLineBreak;
    result := result + ' end;' + sLineBreak + sLineBreak;
  end;
end;

procedure TDataSetClassGenerator.SaveToStrings(Strings: TStrings);
var
  DataSetClass: TDataSetClass;
begin
  assert(assigned(Strings));

  Strings.Add(WriteUnitHeader(UnitName, AdditionalUnits));

  for DataSetClass in DataSetClasses do
    if DataSetClass.Enabled then
      Strings.Add(WriteInterface(DataSetClass));

  Strings.Add('');
  Strings.Add(GetImplementation);
  Strings.Add('');

  for DataSetClass in DataSetClasses do
    if DataSetClass.Enabled then
      if HasBlob(DataSetClass.DataSet) then
        Strings.Add(WriteImplementation(DataSetClass));

  Strings.Add('');
  Strings.Add(GetEnd);
end;

procedure TDataSetClassGenerator.SaveToFile(const FileName: string);

  function UniqueFileName(FileName: string): string;
  var
    i: integer;
  begin
    result := FileName;

    for i := 1 to MaxInt do
    begin
      result := ChangeFileExt(FileName, '') + '__' + inttostr(i) + ExtractFileExt(FileName);

      if not TFile.Exists(result) then
        exit;
    end;
  end;

var
  Strings: TStrings;
begin
  if TFile.Exists(FileName) then
    TFile.Move(FileName, UniqueFileName(FileName));

  Strings := TStringList.Create;
  try
    SaveToStrings(Strings);
    Strings.SaveToFile(FileName);
  finally
    FreeAndNil(Strings);
  end;

end;

procedure TDataSetClassGenerator.SaveToFolder(const Folder: string);
begin
  SaveToFile(IncludeTrailingPathDelimiter(Folder) + UnitName + '.pas');
end;

end.

  zstoredprocs
