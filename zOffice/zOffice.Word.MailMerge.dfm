object MailMergeEngine: TMailMergeEngine
  Height = 190
  Width = 223
  object dxRichEditDocumentServer: TdxRichEditDocumentServer
    Options.DocumentSaveOptions.DefaultFormat = OpenXml
    Options.Fields.UseCurrentCultureDateTimeFormat = True
    Options.MailMerge.KeepLastParagraph = True
    Options.MailMerge.ViewMergedData = True
    OnCalculateDocumentVariable = dxRichEditDocumentServerCalculateDocumentVariable
    Left = 80
    Top = 44
  end
  object MainDataSource: TDataSource
    Left = 80
    Top = 112
  end
end
